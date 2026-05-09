import random

from django.shortcuts import get_object_or_404, redirect, render

from criminals.models import Suspect
from places.models import Country
from game.logic import (
    LOCATION_CLUE_TYPE,
    LOCATION_WITNESSES,
    do_arrest,
    do_investigate,
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
    return render(request, "game/index.html")


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
        warrant_suspect = get_object_or_404(Suspect, pk=game["warrant_suspect_id"])

    active_location = game.get("active_location")
    witnesses = LOCATION_WITNESSES.get(active_location, []) if active_location else []

    context = {
        "game": game,
        "current_country": current_country,
        "locations": locations,
        "travel_options": travel_options,
        "suspects": Suspect.objects.order_by("name"),
        "warrant_suspect": warrant_suspect,
        "active_location": active_location,
        "witnesses": witnesses,
        "time_display": format_time(game["time_remaining"]),
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
    return redirect("game:case")


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
        warrant_suspect = get_object_or_404(Suspect, pk=game["warrant_suspect_id"])
    context = {
        "game": game,
        "suspect": suspect,
        "warrant_suspect": warrant_suspect,
    }
    return render(request, "game/result.html", context)
