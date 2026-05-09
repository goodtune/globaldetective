import random

from django.shortcuts import get_object_or_404, redirect, render

from criminals.models import Suspect
from places.models import Country
from game.logic import (
    LOCATION_CLUE_TYPE,
    LOCATION_WITNESSES,
    MINIGAME_LOCATIONS,
    do_arrest,
    do_investigate,
    do_minigame,
    do_speak,
    do_travel,
    do_warrant,
    format_time,
    generate_case,
)

LOCATION_META = [
    {"key": "library", "name": "Library", "icon": "📚", "cost": 2},
    {"key": "police", "name": "Police Station", "icon": "🚔", "cost": 3},
    {"key": "airport", "name": "Airport", "icon": "✈️", "cost": 1},
    {"key": "market", "name": "Market", "icon": "🛒", "cost": 2},
]

VALID_LOCATIONS = {loc["key"] for loc in LOCATION_META}


def index(request):
    game = request.session.get("game")
    has_active_game = bool(game and game.get("status") == "active")
    return render(request, "game/index.html", {"has_active_game": has_active_game})


def new_case(request):
    if request.method != "POST":
        return redirect("game:index")
    request.session["game"] = generate_case()
    return redirect("game:case")


def case(request):
    game = request.session.get("game")
    if not game or game["status"] != "active":
        return redirect("game:index")

    stop_key = str(game["current_stop"])
    clues_at_stop = game["clues_available"][stop_key]

    locations = [
        {**loc, "available": bool(clues_at_stop[LOCATION_CLUE_TYPE[loc["key"]]])}
        for loc in LOCATION_META
    ]

    current_country = get_object_or_404(Country, pk=game["trail"][game["current_stop"]])
    at_final_stop = game["current_stop"] == len(game["trail"]) - 1

    travel_options = []
    if not at_final_stop:
        next_pk = game["trail"][game["current_stop"] + 1]
        all_non_trail = list(Country.objects.exclude(pk__in=game["trail"]).values_list("pk", flat=True))
        decoy_pks = random.sample(all_non_trail, min(5, len(all_non_trail)))
        decoys = list(Country.objects.filter(pk__in=decoy_pks))
        correct = get_object_or_404(Country, pk=next_pk)
        travel_options = decoys + [correct]
        random.shuffle(travel_options)

    warrant_suspect = None
    if game["warrant_suspect_id"]:
        warrant_suspect = Suspect.objects.filter(pk=game["warrant_suspect_id"]).first()

    active_location = game.get("active_location")
    witnesses = LOCATION_WITNESSES.get(active_location, []) if active_location else []

    suspects = list(Suspect.objects.order_by("name"))
    all_countries = list(Country.objects.prefetch_related("flag_colours").order_by("common_name"))

    context = {
        "game": game,
        "current_country": current_country,
        "locations": locations,
        "travel_options": travel_options,
        "suspects": suspects,
        "warrant_suspect": warrant_suspect,
        "active_location": active_location,
        "witnesses": witnesses,
        "time_display": format_time(game["time_remaining"]),
        "stop_num": game["current_stop"] + 1,
        "trail_total": len(game["trail"]),
        "all_countries": all_countries,
    }
    return render(request, "game/case.html", context)


def investigate(request):
    if request.method != "POST":
        return redirect("game:case")
    game = request.session.get("game")
    if not game or game["status"] != "active":
        return redirect("game:index")
    location = request.POST.get("location")
    if location not in VALID_LOCATIONS:
        return redirect("game:case")
    request.session["game"] = do_investigate(game, location)
    request.session.modified = True
    if MINIGAME_LOCATIONS.get(location):
        return redirect("game:minigame")
    return redirect("game:case")


def minigame(request):
    game = request.session.get("game")
    if not game or game["status"] != "active":
        return redirect("game:index")

    minigame_type = game.get("active_minigame")
    if not minigame_type:
        return redirect("game:case")

    if request.method == "POST":
        action = request.POST.get("action", "skip")
        solved = False
        if action == "solve":
            answer = game.get("minigame_answer")
            if minigame_type == "safe":
                try:
                    user = [int(request.POST.get(f"d{i}", -1)) for i in range(3)]
                    solved = user == answer
                except (ValueError, TypeError):
                    solved = False
            elif minigame_type == "frequency":
                try:
                    user_freq = int(request.POST.get("freq", -1))
                    solved = abs(user_freq - answer) <= 20
                except (ValueError, TypeError):
                    solved = False

        request.session["game"] = do_minigame(game, solved)
        request.session.modified = True
        if request.session["game"]["status"] == "lost":
            return redirect("game:result")
        return redirect("game:case")

    context = {
        "game": game,
        "minigame_type": minigame_type,
        "answer": game.get("minigame_answer"),
        "time_display": format_time(game["time_remaining"]),
    }
    return render(request, "game/minigame.html", context)


def speak(request):
    if request.method != "POST":
        return redirect("game:case")
    game = request.session.get("game")
    if not game or game["status"] != "active":
        return redirect("game:index")
    location = game.get("active_location")
    if not location or location not in VALID_LOCATIONS:
        return redirect("game:case")
    witness_name = request.POST.get("witness_name", "")
    updated_game = do_speak(game, location, witness_name)
    request.session["game"] = updated_game
    request.session.modified = True
    if updated_game["status"] == "lost":
        return redirect("game:result")
    return redirect("game:case")


def travel(request):
    if request.method != "POST":
        return redirect("game:case")
    game = request.session.get("game")
    if not game or game["status"] != "active":
        return redirect("game:index")
    try:
        country_pk = int(request.POST.get("country_id", 0))
    except (ValueError, TypeError):
        return redirect("game:case")
    request.session["game"] = do_travel(game, country_pk)
    request.session.modified = True
    if request.session["game"]["status"] == "lost":
        return redirect("game:result")
    return redirect("game:case")


def warrant(request):
    if request.method != "POST":
        return redirect("game:case")
    game = request.session.get("game")
    if not game or game["status"] != "active":
        return redirect("game:index")
    try:
        suspect_pk = int(request.POST.get("suspect_id", 0))
    except (ValueError, TypeError):
        return redirect("game:case")
    request.session["game"] = do_warrant(game, suspect_pk)
    request.session.modified = True
    return redirect("game:case")


def arrest(request):
    if request.method != "POST":
        return redirect("game:case")
    game = request.session.get("game")
    if not game or game["status"] != "active":
        return redirect("game:index")
    request.session["game"] = do_arrest(game)
    request.session.modified = True
    return redirect("game:result")


def result(request):
    game = request.session.get("game")
    if not game or game["status"] == "active":
        return redirect("game:index")
    suspect = get_object_or_404(Suspect, pk=game["suspect_id"])
    warrant_suspect = None
    if game["warrant_suspect_id"]:
        warrant_suspect = Suspect.objects.filter(pk=game["warrant_suspect_id"]).first()
    trail_countries = list(Country.objects.filter(pk__in=game["trail"]))
    trail_by_pk = {c.pk: c for c in trail_countries}
    trail_ordered = [trail_by_pk[pk] for pk in game["trail"] if pk in trail_by_pk]
    context = {
        "game": game,
        "suspect": suspect,
        "warrant_suspect": warrant_suspect,
        "trail": trail_ordered,
        "time_display": format_time(max(game["time_remaining"], 0)),
    }
    return render(request, "game/result.html", context)
