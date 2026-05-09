import copy
import random

from criminals.models import Suspect
from places.models import Country
from game.clues import clues_for_stop

STARTING_TIME = 168  # 7 days

FLIGHT_COST = 6
WRONG_FLIGHT_PENALTY = 4

LOCATION_COSTS = {
    "library": 2,
    "police": 3,
    "airport": 1,
    "market": 2,
}
LOCATION_CLUE_TYPE = {
    "library": "travel",
    "police": "suspect",
    "airport": "travel",
    "market": "suspect",
}
LOCATION_WITNESSES = {
    "library": ["Librarian", "Student", "Professor"],
    "police": ["Detective", "Officer", "Duty Sergeant"],
    "airport": ["Customs Agent", "Flight Attendant", "Pilot"],
    "market": ["Merchant", "Customer", "Market Inspector"],
}


def format_time(hours):
    days, remaining = divmod(hours, 24)
    if days > 0 and remaining > 0:
        return f"{days} day{'s' if days != 1 else ''}, {remaining}h"
    if days > 0:
        return f"{days} day{'s' if days != 1 else ''}"
    return f"{remaining}h"


def generate_case():
    suspect = random.choice(list(Suspect.objects.all()))
    trail_length = random.randint(3, 5)
    countries = random.sample(list(Country.objects.all()), trail_length)

    clues_available = {}
    for i, country in enumerate(countries):
        next_country = countries[i + 1] if i < len(countries) - 1 else None
        clues_available[str(i)] = clues_for_stop(suspect, next_country)

    return {
        "suspect_id": suspect.pk,
        "trail": [c.pk for c in countries],
        "current_stop": 0,
        "clues_seen": [],
        "clues_available": clues_available,
        "active_location": None,
        "last_witness_result": None,
        "time_remaining": STARTING_TIME,
        "warrant_suspect_id": None,
        "status": "active",
    }


def do_investigate(game, location):
    game = copy.deepcopy(game)
    game["active_location"] = location
    game["last_witness_result"] = None
    return game


def do_speak(game, location, witness_name):
    game = copy.deepcopy(game)
    stop_key = str(game["current_stop"])
    clue_type = LOCATION_CLUE_TYPE[location]
    pool = game["clues_available"][stop_key][clue_type]

    game["active_location"] = None
    game["time_remaining"] -= LOCATION_COSTS[location]

    clue_text = None
    if pool and random.random() < 0.5:
        clue = pool.pop(0)
        clue_text = clue["text"]
        game["clues_seen"].append(clue_text)

    game["last_witness_result"] = {
        "witness": witness_name,
        "clue": clue_text,
    }

    if game["time_remaining"] <= 0:
        game["status"] = "lost"

    return game


def do_travel(game, country_pk):
    game = copy.deepcopy(game)
    current_stop = game["current_stop"]

    if current_stop >= len(game["trail"]) - 1:
        return game

    if country_pk == game["trail"][current_stop + 1]:
        game["current_stop"] += 1
        game["time_remaining"] -= FLIGHT_COST
    else:
        game["time_remaining"] -= WRONG_FLIGHT_PENALTY

    game["active_location"] = None
    game["last_witness_result"] = None

    if game["time_remaining"] <= 0:
        game["status"] = "lost"

    return game


def do_warrant(game, suspect_pk):
    game = copy.deepcopy(game)
    game["warrant_suspect_id"] = suspect_pk
    return game


def do_arrest(game):
    game = copy.deepcopy(game)
    if game["warrant_suspect_id"] == game["suspect_id"]:
        game["status"] = "won"
    else:
        game["status"] = "lost"
    return game
