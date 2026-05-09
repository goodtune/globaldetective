# Game Implementation — Revised Tasks 3–7

> These tasks supersede the Task 3–7 sections in `2026-05-09-game-implementation.md`.
> Tasks 1 (scaffold) and 2 (clues.py) are already complete.

**Design changes from original plan:**
1. Time budget is **168 hours (7 days)**, displayed as "X days, Y hours"
2. Visiting a location shows **3 witnesses**; speaking to one costs time and has a **50% chance** of revealing a clue (if the pool is non-empty). Duds don't drain the pool.
3. Location buttons show **no clue type label** — the player must discover what each location reveals.
4. New session fields: `active_location` (str|None), `last_witness_result` (dict|None)
5. New action: `do_investigate` just sets `active_location` (free). `do_speak` deducts time and draws the clue.
6. New URL: `POST /game/speak/`

---

## Task 3: Case generation and action functions (`game/logic.py`)

**Files:**
- Write: `game/logic.py`
- Modify: `game/tests.py` (append new test classes)

- [ ] **Step 1: Append failing tests to `game/tests.py`**

Add at the end of `game/tests.py`:

```python
from unittest.mock import patch

from game.logic import (
    FLIGHT_COST,
    LOCATION_WITNESSES,
    WRONG_FLIGHT_PENALTY,
    do_arrest,
    do_investigate,
    do_speak,
    do_travel,
    do_warrant,
    format_time,
    generate_case,
)


def make_game(suspect, trail):
    """Build a minimal valid game dict for testing."""
    from game.clues import clues_for_stop
    clues_available = {}
    for i, country in enumerate(trail):
        next_country = trail[i + 1] if i < len(trail) - 1 else None
        clues_available[str(i)] = clues_for_stop(suspect, next_country)
    return {
        "suspect_id": suspect.pk,
        "trail": [c.pk for c in trail],
        "current_stop": 0,
        "clues_seen": [],
        "clues_available": clues_available,
        "active_location": None,
        "last_witness_result": None,
        "time_remaining": 168,
        "warrant_suspect_id": None,
        "status": "active",
    }


class FormatTimeTest(TestCase):
    def test_days_and_hours(self):
        self.assertEqual(format_time(53), "2 days, 5h")

    def test_exact_days(self):
        self.assertEqual(format_time(48), "2 days")

    def test_hours_only(self):
        self.assertEqual(format_time(5), "5h")

    def test_one_day(self):
        self.assertEqual(format_time(24), "1 day")

    def test_one_day_and_hours(self):
        self.assertEqual(format_time(25), "1 day, 1h")


class GenerateCaseTest(TestCase):
    def setUp(self):
        self.suspect = make_suspect()
        self.countries = [make_country(str(i)) for i in range(5)]

    def test_returns_valid_shape(self):
        game = generate_case()
        self.assertIn("suspect_id", game)
        self.assertIn("trail", game)
        self.assertIn("clues_available", game)
        self.assertIn("active_location", game)
        self.assertIn("last_witness_result", game)
        self.assertEqual(game["status"], "active")
        self.assertEqual(game["time_remaining"], 168)
        self.assertIsNone(game["active_location"])

    def test_trail_length_between_3_and_5(self):
        for _ in range(10):
            game = generate_case()
            self.assertGreaterEqual(len(game["trail"]), 3)
            self.assertLessEqual(len(game["trail"]), 5)

    def test_clues_keyed_per_stop(self):
        game = generate_case()
        for i in range(len(game["trail"])):
            self.assertIn(str(i), game["clues_available"])
            stop = game["clues_available"][str(i)]
            self.assertIn("suspect", stop)
            self.assertIn("travel", stop)

    def test_final_stop_has_no_travel_clues(self):
        game = generate_case()
        last = str(len(game["trail"]) - 1)
        self.assertEqual(game["clues_available"][last]["travel"], [])


class DoInvestigateTest(TestCase):
    def setUp(self):
        self.suspect = make_suspect()
        self.countries = [make_country(str(i)) for i in range(3)]

    def test_sets_active_location(self):
        game = make_game(self.suspect, self.countries)
        result = do_investigate(game, "library")
        self.assertEqual(result["active_location"], "library")

    def test_no_time_deducted(self):
        game = make_game(self.suspect, self.countries)
        result = do_investigate(game, "library")
        self.assertEqual(result["time_remaining"], 168)

    def test_clears_last_witness_result(self):
        game = make_game(self.suspect, self.countries)
        game["last_witness_result"] = {"witness": "Someone", "clue": "clue"}
        result = do_investigate(game, "library")
        self.assertIsNone(result["last_witness_result"])

    def test_does_not_mutate_original(self):
        game = make_game(self.suspect, self.countries)
        do_investigate(game, "police")
        self.assertIsNone(game["active_location"])


class DoSpeakTest(TestCase):
    def setUp(self):
        self.suspect = make_suspect()
        self.countries = [make_country(str(i)) for i in range(3)]

    def test_deducts_time_for_police(self):
        game = make_game(self.suspect, self.countries)
        result = do_speak(game, "police", "Officer")
        self.assertEqual(result["time_remaining"], 168 - 3)

    def test_deducts_time_for_library(self):
        game = make_game(self.suspect, self.countries)
        result = do_speak(game, "library", "Librarian")
        self.assertEqual(result["time_remaining"], 168 - 2)

    def test_sets_last_witness_result(self):
        game = make_game(self.suspect, self.countries)
        result = do_speak(game, "police", "Officer")
        self.assertIsNotNone(result["last_witness_result"])
        self.assertEqual(result["last_witness_result"]["witness"], "Officer")

    def test_clue_revealed_when_lucky(self):
        game = make_game(self.suspect, self.countries)
        with patch("game.logic.random") as mock_random:
            mock_random.random.return_value = 0.1
            result = do_speak(game, "police", "Officer")
        self.assertIsNotNone(result["last_witness_result"]["clue"])
        self.assertEqual(len(result["clues_seen"]), 1)

    def test_no_clue_when_unlucky(self):
        game = make_game(self.suspect, self.countries)
        with patch("game.logic.random") as mock_random:
            mock_random.random.return_value = 0.9
            result = do_speak(game, "police", "Officer")
        self.assertIsNone(result["last_witness_result"]["clue"])
        self.assertEqual(len(result["clues_seen"]), 0)

    def test_no_clue_when_pool_empty(self):
        game = make_game(self.suspect, self.countries)
        game["clues_available"]["0"]["suspect"] = []
        with patch("game.logic.random") as mock_random:
            mock_random.random.return_value = 0.1
            result = do_speak(game, "police", "Officer")
        self.assertIsNone(result["last_witness_result"]["clue"])

    def test_clears_active_location(self):
        game = make_game(self.suspect, self.countries)
        game["active_location"] = "police"
        result = do_speak(game, "police", "Officer")
        self.assertIsNone(result["active_location"])

    def test_time_zero_sets_lost(self):
        game = make_game(self.suspect, self.countries)
        game["time_remaining"] = 1
        result = do_speak(game, "police", "Officer")
        self.assertEqual(result["status"], "lost")

    def test_does_not_mutate_original(self):
        game = make_game(self.suspect, self.countries)
        original_time = game["time_remaining"]
        do_speak(game, "police", "Officer")
        self.assertEqual(game["time_remaining"], original_time)


class DoTravelTest(TestCase):
    def setUp(self):
        self.suspect = make_suspect()
        self.countries = [make_country(str(i)) for i in range(3)]

    def test_correct_country_advances_stop(self):
        game = make_game(self.suspect, self.countries)
        correct_pk = self.countries[1].pk
        result = do_travel(game, correct_pk)
        self.assertEqual(result["current_stop"], 1)

    def test_correct_country_deducts_flight_cost(self):
        game = make_game(self.suspect, self.countries)
        correct_pk = self.countries[1].pk
        result = do_travel(game, correct_pk)
        self.assertEqual(result["time_remaining"], 168 - FLIGHT_COST)

    def test_wrong_country_deducts_penalty(self):
        game = make_game(self.suspect, self.countries)
        result = do_travel(game, 99999)
        self.assertEqual(result["time_remaining"], 168 - WRONG_FLIGHT_PENALTY)

    def test_wrong_country_does_not_advance_stop(self):
        game = make_game(self.suspect, self.countries)
        result = do_travel(game, 99999)
        self.assertEqual(result["current_stop"], 0)

    def test_at_final_stop_does_nothing(self):
        game = make_game(self.suspect, self.countries)
        game["current_stop"] = 2
        result = do_travel(game, self.countries[0].pk)
        self.assertEqual(result["current_stop"], 2)
        self.assertEqual(result["time_remaining"], 168)

    def test_time_zero_sets_lost(self):
        game = make_game(self.suspect, self.countries)
        game["time_remaining"] = 1
        result = do_travel(game, 99999)
        self.assertEqual(result["status"], "lost")


class DoWarrantTest(TestCase):
    def setUp(self):
        self.suspect = make_suspect()
        self.countries = [make_country(str(i)) for i in range(3)]

    def test_sets_warrant_suspect_id(self):
        game = make_game(self.suspect, self.countries)
        result = do_warrant(game, self.suspect.pk)
        self.assertEqual(result["warrant_suspect_id"], self.suspect.pk)

    def test_can_change_warrant(self):
        game = make_game(self.suspect, self.countries)
        other = make_suspect(name="Other", sex="MALE")
        game["warrant_suspect_id"] = other.pk
        result = do_warrant(game, self.suspect.pk)
        self.assertEqual(result["warrant_suspect_id"], self.suspect.pk)


class DoArrestTest(TestCase):
    def setUp(self):
        self.suspect = make_suspect()
        self.countries = [make_country(str(i)) for i in range(3)]

    def test_correct_warrant_wins(self):
        game = make_game(self.suspect, self.countries)
        game["warrant_suspect_id"] = self.suspect.pk
        result = do_arrest(game)
        self.assertEqual(result["status"], "won")

    def test_wrong_warrant_loses(self):
        game = make_game(self.suspect, self.countries)
        game["warrant_suspect_id"] = 99999
        result = do_arrest(game)
        self.assertEqual(result["status"], "lost")


class LocationWitnessesTest(TestCase):
    def test_all_locations_have_three_witnesses(self):
        for location in ("library", "police", "airport", "market"):
            self.assertEqual(len(LOCATION_WITNESSES[location]), 3)
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
.venv/bin/python manage.py test game.tests.FormatTimeTest game.tests.GenerateCaseTest game.tests.DoInvestigateTest game.tests.DoSpeakTest game.tests.DoTravelTest game.tests.DoWarrantTest game.tests.DoArrestTest game.tests.LocationWitnessesTest -v 2
```
Expected: `ImportError` — logic.py is empty.

- [ ] **Step 3: Write `game/logic.py`**

```python
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
    """Return hours formatted as 'X days, Yh', '1 day', '5h', etc."""
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
    """Activate a location for witness selection. No time cost."""
    game = copy.deepcopy(game)
    game["active_location"] = location
    game["last_witness_result"] = None
    return game


def do_speak(game, location, witness_name):
    """Speak to a witness: deduct time, 50% clue if pool non-empty."""
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
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
.venv/bin/python manage.py test game.tests.FormatTimeTest game.tests.GenerateCaseTest game.tests.DoInvestigateTest game.tests.DoSpeakTest game.tests.DoTravelTest game.tests.DoWarrantTest game.tests.DoArrestTest game.tests.LocationWitnessesTest -v 2
```
Expected: `OK` — all tests pass.

- [ ] **Step 5: Commit**

```bash
git add game/logic.py game/tests.py
git commit -m "feat: add case generation and game action logic"
```

---

## Task 4: Views and URL routing (`game/views.py`)

**Files:**
- Write: `game/views.py`
- Write: `game/urls.py`
- Modify: `game/tests.py` (append view test classes)

- [ ] **Step 1: Append failing view tests to `game/tests.py`**

Add at the end of `game/tests.py`:

```python
class IndexViewTest(TestCase):
    def test_get_returns_200(self):
        response = self.client.get("/game/")
        self.assertEqual(response.status_code, 200)


class NewCaseViewTest(TestCase):
    def setUp(self):
        self.suspect = make_suspect()
        for i in range(5):
            make_country(str(i))

    def test_post_creates_session_and_redirects(self):
        response = self.client.post("/game/new/")
        self.assertRedirects(response, "/game/case/")
        self.assertIn("game", self.client.session)

    def test_get_redirects_to_index(self):
        response = self.client.get("/game/new/")
        self.assertRedirects(response, "/game/")


class CaseViewTest(TestCase):
    def setUp(self):
        self.suspect = make_suspect()
        self.countries = [make_country(str(i)) for i in range(3)]

    def _start_game(self):
        from game.logic import generate_case
        session = self.client.session
        session["game"] = generate_case()
        session.save()

    def test_get_with_active_game_returns_200(self):
        self._start_game()
        response = self.client.get("/game/case/")
        self.assertEqual(response.status_code, 200)

    def test_get_without_game_redirects_to_index(self):
        response = self.client.get("/game/case/")
        self.assertRedirects(response, "/game/")


class InvestigateViewTest(TestCase):
    def setUp(self):
        self.suspect = make_suspect()
        self.countries = [make_country(str(i)) for i in range(3)]

    def _start_game(self):
        from game.logic import generate_case
        session = self.client.session
        session["game"] = generate_case()
        session.save()

    def test_post_sets_active_location(self):
        self._start_game()
        self.client.post("/game/investigate/", {"location": "police"})
        game = self.client.session["game"]
        self.assertEqual(game["active_location"], "police")

    def test_post_does_not_deduct_time(self):
        self._start_game()
        self.client.post("/game/investigate/", {"location": "police"})
        game = self.client.session["game"]
        self.assertEqual(game["time_remaining"], 168)

    def test_post_redirects_to_case(self):
        self._start_game()
        response = self.client.post("/game/investigate/", {"location": "police"})
        self.assertRedirects(response, "/game/case/")

    def test_post_invalid_location_redirects_to_case(self):
        self._start_game()
        response = self.client.post("/game/investigate/", {"location": "bar"})
        self.assertRedirects(response, "/game/case/")


class SpeakViewTest(TestCase):
    def setUp(self):
        self.suspect = make_suspect()
        self.countries = [make_country(str(i)) for i in range(3)]

    def _start_game_at_location(self, location="police"):
        from game.logic import generate_case
        session = self.client.session
        game = generate_case()
        game["active_location"] = location
        session["game"] = game
        session.save()

    def test_post_deducts_time(self):
        self._start_game_at_location("police")
        self.client.post("/game/speak/", {"witness_name": "Officer"})
        game = self.client.session["game"]
        self.assertEqual(game["time_remaining"], 168 - 3)

    def test_post_sets_last_witness_result(self):
        self._start_game_at_location("police")
        self.client.post("/game/speak/", {"witness_name": "Officer"})
        game = self.client.session["game"]
        self.assertIsNotNone(game["last_witness_result"])
        self.assertEqual(game["last_witness_result"]["witness"], "Officer")

    def test_post_clears_active_location(self):
        self._start_game_at_location("police")
        self.client.post("/game/speak/", {"witness_name": "Officer"})
        game = self.client.session["game"]
        self.assertIsNone(game["active_location"])

    def test_post_redirects_to_case(self):
        self._start_game_at_location("police")
        response = self.client.post("/game/speak/", {"witness_name": "Officer"})
        self.assertRedirects(response, "/game/case/")

    def test_post_without_active_location_redirects_to_case(self):
        from game.logic import generate_case
        session = self.client.session
        session["game"] = generate_case()
        session.save()
        response = self.client.post("/game/speak/", {"witness_name": "Officer"})
        self.assertRedirects(response, "/game/case/")


class TravelViewTest(TestCase):
    def setUp(self):
        self.suspect = make_suspect()
        self.countries = [make_country(str(i)) for i in range(3)]

    def _start_game(self):
        from game.logic import generate_case
        session = self.client.session
        session["game"] = generate_case()
        session.save()

    def test_post_wrong_country_deducts_penalty(self):
        self._start_game()
        self.client.post("/game/travel/", {"country_id": "99999"})
        game = self.client.session["game"]
        self.assertEqual(game["time_remaining"], 168 - 4)

    def test_post_correct_country_advances_stop(self):
        self._start_game()
        game = self.client.session["game"]
        next_pk = game["trail"][1]
        self.client.post("/game/travel/", {"country_id": str(next_pk)})
        game = self.client.session["game"]
        self.assertEqual(game["current_stop"], 1)


class WarrantViewTest(TestCase):
    def setUp(self):
        self.suspect = make_suspect()
        self.countries = [make_country(str(i)) for i in range(3)]

    def _start_game(self):
        from game.logic import generate_case
        session = self.client.session
        session["game"] = generate_case()
        session.save()

    def test_post_sets_warrant_and_redirects(self):
        self._start_game()
        response = self.client.post("/game/warrant/", {"suspect_id": str(self.suspect.pk)})
        self.assertRedirects(response, "/game/case/")
        game = self.client.session["game"]
        self.assertEqual(game["warrant_suspect_id"], self.suspect.pk)


class ArrestViewTest(TestCase):
    def setUp(self):
        self.suspect = make_suspect()
        self.countries = [make_country(str(i)) for i in range(3)]

    def _start_game(self):
        from game.logic import generate_case
        session = self.client.session
        session["game"] = generate_case()
        session.save()

    def test_correct_warrant_redirects_to_result_as_won(self):
        self._start_game()
        game = self.client.session["game"]
        suspect_pk = game["suspect_id"]
        session = self.client.session
        session["game"]["warrant_suspect_id"] = suspect_pk
        session.save()
        response = self.client.post("/game/arrest/")
        self.assertRedirects(response, "/game/result/")
        self.assertEqual(self.client.session["game"]["status"], "won")

    def test_wrong_warrant_redirects_to_result_as_lost(self):
        self._start_game()
        session = self.client.session
        session["game"]["warrant_suspect_id"] = 99999
        session.save()
        response = self.client.post("/game/arrest/")
        self.assertRedirects(response, "/game/result/")
        self.assertEqual(self.client.session["game"]["status"], "lost")


class ResultViewTest(TestCase):
    def setUp(self):
        self.suspect = make_suspect()
        self.countries = [make_country(str(i)) for i in range(3)]

    def _set_game(self, status):
        from game.logic import generate_case
        session = self.client.session
        game = generate_case()
        game["status"] = status
        session["game"] = game
        session.save()

    def test_won_game_returns_200(self):
        self._set_game("won")
        response = self.client.get("/game/result/")
        self.assertEqual(response.status_code, 200)

    def test_lost_game_returns_200(self):
        self._set_game("lost")
        response = self.client.get("/game/result/")
        self.assertEqual(response.status_code, 200)

    def test_active_game_redirects_to_index(self):
        self._set_game("active")
        response = self.client.get("/game/result/")
        self.assertRedirects(response, "/game/")

    def test_no_game_redirects_to_index(self):
        response = self.client.get("/game/result/")
        self.assertRedirects(response, "/game/")
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
.venv/bin/python manage.py test game.tests.IndexViewTest game.tests.NewCaseViewTest game.tests.CaseViewTest game.tests.InvestigateViewTest game.tests.SpeakViewTest game.tests.TravelViewTest game.tests.WarrantViewTest game.tests.ArrestViewTest game.tests.ResultViewTest -v 2
```
Expected: errors — views and URLs not wired up yet.

- [ ] **Step 3: Write `game/views.py`**

```python
import random

from django.shortcuts import redirect, render

from criminals.models import Suspect
from places.models import Country
from game.logic import (
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
    {"key": "library", "name": "Library", "icon": "📚", "cost": 2, "clue_type": "travel"},
    {"key": "police", "name": "Police Station", "icon": "🚔", "cost": 3, "clue_type": "suspect"},
    {"key": "airport", "name": "Airport", "icon": "✈️", "cost": 1, "clue_type": "travel"},
    {"key": "market", "name": "Market", "icon": "🛒", "cost": 2, "clue_type": "suspect"},
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
        {**loc, "available": bool(clues_at_stop[loc["clue_type"]])}
        for loc in LOCATION_META
    ]

    current_country = Country.objects.get(pk=game["trail"][game["current_stop"]])
    at_final_stop = game["current_stop"] == len(game["trail"]) - 1

    travel_options = []
    if not at_final_stop:
        next_pk = game["trail"][game["current_stop"] + 1]
        decoys = list(Country.objects.exclude(pk__in=game["trail"]).order_by("?")[:5])
        correct = Country.objects.get(pk=next_pk)
        travel_options = decoys + [correct]
        random.shuffle(travel_options)

    warrant_suspect = None
    if game["warrant_suspect_id"]:
        warrant_suspect = Suspect.objects.get(pk=game["warrant_suspect_id"])

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
    request.session["game"] = do_speak(game, location, witness_name)
    request.session.modified = True
    if request.session["game"]["status"] == "lost":
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
    suspect = Suspect.objects.get(pk=game["suspect_id"])
    warrant_suspect = None
    if game["warrant_suspect_id"]:
        warrant_suspect = Suspect.objects.get(pk=game["warrant_suspect_id"])
    context = {
        "game": game,
        "suspect": suspect,
        "warrant_suspect": warrant_suspect,
    }
    return render(request, "game/result.html", context)
```

- [ ] **Step 4: Write `game/urls.py`**

```python
from django.urls import path

from game import views

app_name = "game"

urlpatterns = [
    path("", views.index, name="index"),
    path("new/", views.new_case, name="new"),
    path("case/", views.case, name="case"),
    path("investigate/", views.investigate, name="investigate"),
    path("speak/", views.speak, name="speak"),
    path("travel/", views.travel, name="travel"),
    path("warrant/", views.warrant, name="warrant"),
    path("arrest/", views.arrest, name="arrest"),
    path("result/", views.result, name="result"),
]
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
.venv/bin/python manage.py test game.tests.IndexViewTest game.tests.NewCaseViewTest game.tests.CaseViewTest game.tests.InvestigateViewTest game.tests.SpeakViewTest game.tests.TravelViewTest game.tests.WarrantViewTest game.tests.ArrestViewTest game.tests.ResultViewTest -v 2
```
Expected: `TemplateDoesNotExist` errors — views resolve correctly but templates not yet created.

- [ ] **Step 6: Commit**

```bash
git add game/views.py game/urls.py game/tests.py
git commit -m "feat: add game views and URL routing"
```

---

## Task 5: Templates — index and result screens

**Files:**
- Create: `game/templates/game/index.html`
- Create: `game/templates/game/result.html`

- [ ] **Step 1: Create directory**

```bash
mkdir -p game/templates/game
```

- [ ] **Step 2: Create `game/templates/game/index.html`**

```html
{% extends 'base.html' %}

{% block title %}New Case — Global Detective{% endblock %}

{% block content %}
  <h1 class="mb-3">Global Detective Quest</h1>
  <p class="lead">A criminal has struck somewhere in the world. You have one week to track them down.</p>
  <ul class="mb-4">
    <li>Visit locations and speak to witnesses — some know something, some don't</li>
    <li>Use the World Factbook to identify your next destination</li>
    <li>Issue a warrant once you know the culprit, then make the arrest</li>
  </ul>
  <form method="post" action="{% url 'game:new' %}">
    {% csrf_token %}
    <button type="submit" class="btn btn-primary btn-lg">Start New Case</button>
  </form>
{% endblock %}
```

- [ ] **Step 3: Create `game/templates/game/result.html`**

```html
{% extends 'base.html' %}

{% block title %}Case {% if game.status == 'won' %}Solved{% else %}Failed{% endif %}{% endblock %}

{% block content %}
  {% if game.status == 'won' %}
    <h1 class="text-success mb-3">Case Solved!</h1>
    <p class="lead">You correctly identified and arrested <strong>{{ suspect.name }}</strong>.</p>
  {% else %}
    <h1 class="text-danger mb-3">Case Failed</h1>
    {% if game.time_remaining <= 0 %}
      <p class="lead">You ran out of time. The criminal escaped.</p>
    {% else %}
      <p class="lead">Wrong arrest. The real culprit was <strong>{{ suspect.name }}</strong>.</p>
    {% endif %}
    {% if warrant_suspect and warrant_suspect.pk != suspect.pk %}
      <p>You had a warrant for <strong>{{ warrant_suspect.name }}</strong>.</p>
    {% endif %}
  {% endif %}

  <p class="mt-3"><strong>Clues you collected:</strong></p>
  {% if game.clues_seen %}
    <ul>
      {% for clue in game.clues_seen %}
        <li>{{ clue }}</li>
      {% endfor %}
    </ul>
  {% else %}
    <p class="text-muted">No clues collected.</p>
  {% endif %}

  <form method="post" action="{% url 'game:new' %}">
    {% csrf_token %}
    <button type="submit" class="btn btn-primary mt-3">Play Again</button>
  </form>
  <a href="{% url 'index' %}" class="btn btn-secondary mt-3 ms-2">Home</a>
{% endblock %}
```

- [ ] **Step 4: Run index and result view tests**

```bash
.venv/bin/python manage.py test game.tests.IndexViewTest game.tests.ResultViewTest -v 2
```
Expected: `OK`.

- [ ] **Step 5: Commit**

```bash
git add game/templates/
git commit -m "feat: add game index and result templates"
```

---

## Task 6: Main game screen template

**Files:**
- Create: `game/templates/game/case.html`

- [ ] **Step 1: Create `game/templates/game/case.html`**

```html
{% extends 'base.html' %}

{% block title %}Active Case — {{ current_country.common_name }}{% endblock %}

{% block content %}

  {# Top bar #}
  <div class="d-flex justify-content-between align-items-center bg-dark text-white rounded p-3 mb-4">
    <div>
      <small class="text-muted d-block">Current Location</small>
      <strong>{{ current_country.common_name }}</strong>
    </div>
    <div class="text-center">
      <small class="text-muted d-block">Time Remaining</small>
      <strong class="fs-5 {% if game.time_remaining <= 12 %}text-danger{% else %}text-warning{% endif %}">
        {{ time_display }}
      </strong>
    </div>
    <div class="text-end">
      <small class="text-muted d-block">Warrant</small>
      {% if warrant_suspect %}
        <strong class="text-success">{{ warrant_suspect.name }}</strong>
      {% else %}
        <span class="text-muted">None issued</span>
      {% endif %}
    </div>
  </div>

  <div class="row g-4">

    {# Left panel #}
    <div class="col-md-7">

      {% if game.last_witness_result %}
        {% if game.last_witness_result.clue %}
          <div class="alert alert-success">
            <strong>{{ game.last_witness_result.witness }}</strong> told you: "{{ game.last_witness_result.clue }}"
          </div>
        {% else %}
          <div class="alert alert-secondary">
            <strong>{{ game.last_witness_result.witness }}</strong> didn't know anything useful.
          </div>
        {% endif %}
      {% endif %}

      {% if active_location %}
        {# Witness selection mode #}
        {% for loc in locations %}{% if loc.key == active_location %}
          <h5 class="text-uppercase text-muted mb-3" style="font-size:0.8rem;letter-spacing:0.05em">
            {{ loc.icon }} {{ loc.name }} — Choose someone to speak to
          </h5>
        {% endif %}{% endfor %}

        <div class="row g-2 mb-4">
          {% for witness in witnesses %}
            <div class="col-4">
              <form method="post" action="{% url 'game:speak' %}">
                {% csrf_token %}
                <input type="hidden" name="witness_name" value="{{ witness }}">
                <button type="submit" class="btn btn-outline-warning w-100 py-3">
                  👤 {{ witness }}
                </button>
              </form>
            </div>
          {% endfor %}
        </div>

        <form method="post" action="{% url 'game:investigate' %}">
          {% csrf_token %}
          <input type="hidden" name="location" value="">
          <a href="{% url 'game:case' %}" class="btn btn-sm btn-link text-muted">← Back to locations</a>
        </form>

      {% else %}
        {# Normal mode: location buttons #}
        <h5 class="text-uppercase text-muted mb-3" style="font-size:0.8rem;letter-spacing:0.05em">Investigate a Location</h5>
        <div class="row g-2 mb-4">
          {% for loc in locations %}
            <div class="col-6">
              <form method="post" action="{% url 'game:investigate' %}">
                {% csrf_token %}
                <input type="hidden" name="location" value="{{ loc.key }}">
                <button type="submit" class="btn btn-outline-secondary w-100 text-start {% if not loc.available %}disabled{% endif %}" {% if not loc.available %}disabled{% endif %}>
                  <span class="fs-5">{{ loc.icon }}</span>
                  <span class="ms-2 fw-semibold">{{ loc.name }}</span>
                  <br>
                  <small class="text-muted ms-2">
                    {% if loc.available %}
                      {{ loc.cost }}h per conversation
                    {% else %}
                      No leads here
                    {% endif %}
                  </small>
                </button>
              </form>
            </div>
          {% endfor %}
        </div>

        {% if travel_options %}
          <h5 class="text-uppercase text-muted mb-2" style="font-size:0.8rem;letter-spacing:0.05em">Fly to Next Destination</h5>
          <p class="text-muted small mb-3">Use your travel clues to pick the right country. Wrong choice costs 4 hours.</p>
          <div class="row g-2">
            {% for country in travel_options %}
              <div class="col-4">
                <form method="post" action="{% url 'game:travel' %}">
                  {% csrf_token %}
                  <input type="hidden" name="country_id" value="{{ country.pk }}">
                  <button type="submit" class="btn btn-outline-primary w-100">
                    <div class="fw-semibold">{{ country.common_name }}</div>
                    <small class="text-muted">6h flight</small>
                  </button>
                </form>
              </div>
            {% endfor %}
          </div>
        {% else %}
          <div class="alert alert-info">
            You are at the <strong>final location</strong>. Issue a warrant and make the arrest.
          </div>
        {% endif %}

      {% endif %}

    </div>

    {# Right panel: notepad + warrant + arrest #}
    <div class="col-md-5">

      <div class="card border-warning mb-3">
        <div class="card-header bg-warning bg-opacity-25">
          <strong>📓 Notepad</strong>
        </div>
        <div class="card-body" style="max-height:300px;overflow-y:auto">
          {% if game.clues_seen %}
            <ul class="list-unstyled mb-0">
              {% for clue in game.clues_seen %}
                <li class="border-bottom py-2 small">{{ clue }}</li>
              {% endfor %}
            </ul>
          {% else %}
            <p class="text-muted small mb-0">No clues yet. Visit a location and speak to witnesses.</p>
          {% endif %}
        </div>
      </div>

      <div class="card mb-3">
        <div class="card-header"><strong>Issue Warrant</strong></div>
        <div class="card-body">
          <form method="post" action="{% url 'game:warrant' %}">
            {% csrf_token %}
            <select name="suspect_id" class="form-select form-select-sm mb-2">
              <option value="">— Select a suspect —</option>
              {% for s in suspects %}
                <option value="{{ s.pk }}" {% if warrant_suspect and warrant_suspect.pk == s.pk %}selected{% endif %}>
                  {{ s.name }}
                </option>
              {% endfor %}
            </select>
            <button type="submit" class="btn btn-warning btn-sm w-100">Issue Warrant</button>
          </form>
        </div>
      </div>

      {% if warrant_suspect %}
        <form method="post" action="{% url 'game:arrest' %}">
          {% csrf_token %}
          <button type="submit" class="btn btn-danger w-100">
            🚨 Make Arrest — {{ warrant_suspect.name }}
          </button>
        </form>
      {% endif %}

    </div>
  </div>

{% endblock %}
```

- [ ] **Step 2: Run all game tests**

```bash
.venv/bin/python manage.py test game -v 2
```
Expected: `OK` — all tests pass.

- [ ] **Step 3: Commit**

```bash
git add game/templates/game/case.html
git commit -m "feat: add main game screen template with witness selection"
```

---

## Task 7: Navigation and final wiring

**Files:**
- Modify: `templates/base.html`

- [ ] **Step 1: Add Game link to navbar in `templates/base.html`**

Find:
```html
            <li class="nav-item"><a class="nav-link" href="{% url 'factbook:index' %}">World Fact Book</a></li>
```

Add after it:
```html
            <li class="nav-item"><a class="nav-link" href="{% url 'game:index' %}">Play Game</a></li>
```

- [ ] **Step 2: Run full test suite**

```bash
.venv/bin/python manage.py test -v 2
```
Expected: all tests pass across all apps.

- [ ] **Step 3: Start dev server and manually verify**

```bash
.venv/bin/python manage.py runserver
```

Visit `http://localhost:8000/game/` and play through a full case:
- Click "Start New Case"
- Click a location, choose a witness, observe the result (clue or nothing)
- Repeat a few times
- Fly to a country using travel clues
- Issue a warrant
- Make an arrest
- Verify result screen shows correct culprit and collected clues

- [ ] **Step 4: Commit**

```bash
git add templates/base.html
git commit -m "feat: add Game link to navigation"
```
