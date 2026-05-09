# Game Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Carmen Sandiego-style detective game as a new `game` Django app using sessions for state and standard Django POST→redirect→GET for all actions.

**Architecture:** Game state lives entirely in `request.session["game"]` as a JSON-serializable dict. Pure functions in `logic.py` compute new state from old state + action, making them trivially testable. Views handle HTTP, call logic functions, write back to session, and redirect.

**Tech Stack:** Django 5.1 sessions, Bootstrap 5.3, `.venv/bin/python manage.py test`

---

## File Map

| File | Action | Responsibility |
|---|---|---|
| `game/__init__.py` | Create | Empty |
| `game/apps.py` | Create | App config |
| `game/urls.py` | Create | URL patterns (app_name="game") |
| `game/clues.py` | Create | Clue templates + generation from suspect/country |
| `game/logic.py` | Create | Case generation + pure action functions |
| `game/views.py` | Create | HTTP views (read session → call logic → write session → redirect) |
| `game/tests.py` | Create | All tests |
| `game/templates/game/index.html` | Create | Start screen |
| `game/templates/game/case.html` | Create | Main game screen |
| `game/templates/game/result.html` | Create | Win/lose outcome screen |
| `project/settings.py` | Modify | Add `"game"` to INSTALLED_APPS |
| `project/urls.py` | Modify | Add `path("game/", include("game.urls"))` |
| `templates/base.html` | Modify | Add Game link to navbar |

---

## Task 1: Scaffold the game app

**Files:**
- Create: `game/__init__.py`
- Create: `game/apps.py`
- Create: `game/urls.py`
- Create: `game/clues.py`
- Create: `game/logic.py`
- Create: `game/views.py`
- Create: `game/tests.py`
- Modify: `project/settings.py`
- Modify: `project/urls.py`

- [ ] **Step 1: Create `game/__init__.py`** (empty file)

```python
```

- [ ] **Step 2: Create `game/apps.py`**

```python
from django.apps import AppConfig


class GameConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "game"
```

- [ ] **Step 3: Create `game/urls.py`** (stub — views not written yet)

```python
from django.urls import path

app_name = "game"

urlpatterns = []
```

- [ ] **Step 4: Create stub files**

`game/clues.py`:
```python
```

`game/logic.py`:
```python
```

`game/views.py`:
```python
```

`game/tests.py`:
```python
from django.test import TestCase
```

- [ ] **Step 5: Add `"game"` to INSTALLED_APPS in `project/settings.py`**

Find the line `"factbook",` and add after it:
```python
    "game",
```

- [ ] **Step 6: Add game URL include to `project/urls.py`**

Find `path("dossiers/", include("dossiers.urls")),` and add after it:
```python
    path("game/", include("game.urls")),
```

- [ ] **Step 7: Verify the app loads**

```bash
.venv/bin/python manage.py check
```
Expected: `System check identified no issues (0 silenced).`

- [ ] **Step 8: Commit**

```bash
git add game/ project/settings.py project/urls.py
git commit -m "feat: scaffold game app"
```

---

## Task 2: Clue generation (`game/clues.py`)

**Files:**
- Write: `game/clues.py`
- Write: `game/tests.py`

- [ ] **Step 1: Write failing tests for clue generation**

Replace the contents of `game/tests.py`:

```python
from django.test import TestCase

from criminals.models import Suspect
from places.models import Country, FlagColour
from game.clues import clues_for_stop, suspect_clues, travel_clues


def make_suspect(**kwargs):
    defaults = {
        "name": "Test Criminal",
        "sex": "FEMALE",
        "hair": "RED",
        "hobby": "TENNIS",
        "feature": "TATTOO",
        "auto": "CONVERTIBLE",
        "food": "SEAFOOD",
    }
    defaults.update(kwargs)
    return Suspect.objects.create(**defaults)


def make_country(code, **kwargs):
    defaults = {
        "name": f"Country {code}",
        "common_name": f"Country {code}",
        "currency": "Dollars",
        "exports": "coffee",
        "geography": "mountains",
        "fauna": "lions",
        "flora": "roses",
    }
    defaults.update(kwargs)
    c = Country.objects.create(code=code, **defaults)
    colour = FlagColour.objects.get_or_create(colour="red")[0]
    c.flag_colours.add(colour)
    return c


class SuspectCluesTest(TestCase):
    def test_returns_list_of_dicts(self):
        s = make_suspect()
        result = suspect_clues(s)
        self.assertIsInstance(result, list)
        for clue in result:
            self.assertIn("text", clue)
            self.assertEqual(clue["type"], "suspect")

    def test_covers_all_set_traits(self):
        s = make_suspect()
        result = suspect_clues(s)
        # suspect has sex, hair, hobby, feature, auto, food — all 6 traits
        self.assertEqual(len(result), 6)

    def test_skips_null_traits(self):
        s = make_suspect(hobby=None, auto=None)
        result = suspect_clues(s)
        self.assertEqual(len(result), 4)  # sex, hair, feature, food


class TravelCluesTest(TestCase):
    def test_returns_empty_for_none(self):
        self.assertEqual(travel_clues(None), [])

    def test_returns_list_of_travel_dicts(self):
        c = make_country("TX")
        result = travel_clues(c)
        self.assertIsInstance(result, list)
        for clue in result:
            self.assertIn("text", clue)
            self.assertEqual(clue["type"], "travel")

    def test_includes_currency_clue(self):
        c = make_country("TC")
        texts = [cl["text"] for cl in travel_clues(c)]
        self.assertTrue(any("Dollars" in t for t in texts))

    def test_includes_flag_colour_clue(self):
        c = make_country("FC")
        texts = [cl["text"] for cl in travel_clues(c)]
        self.assertTrue(any("red" in t for t in texts))

    def test_skips_blank_fields(self):
        c = make_country("BK", currency="", exports="", geography="", fauna="", flora="")
        # flag colour still present
        result = travel_clues(c)
        self.assertEqual(len(result), 1)


class CluesForStopTest(TestCase):
    def test_returns_suspect_and_travel_keys(self):
        s = make_suspect()
        c = make_country("CS")
        result = clues_for_stop(s, c)
        self.assertIn("suspect", result)
        self.assertIn("travel", result)
        self.assertTrue(len(result["suspect"]) > 0)
        self.assertTrue(len(result["travel"]) > 0)

    def test_final_stop_has_no_travel_clues(self):
        s = make_suspect()
        result = clues_for_stop(s, None)
        self.assertEqual(result["travel"], [])
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
.venv/bin/python manage.py test game.tests.SuspectCluesTest game.tests.TravelCluesTest game.tests.CluesForStopTest -v 2
```
Expected: `ImportError` or `AttributeError` — functions don't exist yet.

- [ ] **Step 3: Write `game/clues.py`**

```python
import random

SUSPECT_TEMPLATES = {
    "sex": {
        "FEMALE": "A hotel clerk said the suspect was a woman.",
        "MALE": "A witness described the suspect as a man.",
    },
    "hair": {
        "RED": "The suspect had red hair, according to a witness.",
        "BLONDE": "A bartender mentioned the suspect was blonde.",
        "BROWN": "The suspect had brown hair.",
        "BLACK": "Several witnesses noted the suspect had black hair.",
        "GREY": "A witness said the suspect had grey hair.",
    },
    "hobby": {
        "TENNIS": "Someone saw the suspect carrying a tennis racket.",
        "MUSIC": "The suspect was heard humming and carrying sheet music.",
        "CLIMBING": "A shop owner sold the suspect mountain climbing gear.",
        "SKYDIVE": "The suspect asked about local skydiving operators.",
        "SWIMMING": "A witness saw the suspect heading to the pool with goggles.",
        "CROQUET": "The suspect was spotted reading a book about croquet.",
    },
    "feature": {
        "LIMP": "Several witnesses noted the suspect walked with a limp.",
        "RING": "The suspect was wearing a distinctive ring.",
        "TATTOO": "A bartender noticed the suspect had a tattoo.",
        "SCAR": "A witness described a scar on the suspect's face.",
        "JEWELERY": "The suspect was wearing a lot of jewellery.",
    },
    "auto": {
        "CONVERTIBLE": "The suspect was spotted driving a convertible.",
        "LIMO": "Someone saw the suspect leave in a limousine.",
        "RACECAR": "The suspect was seen near a racecar.",
        "MOTORBIKE": "A witness saw the suspect riding a motorcycle.",
    },
    "food": {
        "SEAFOOD": "The suspect was seen dining on seafood at the harbour.",
        "MEXICAN": "The hotel chef said the suspect requested Mexican food.",
    },
}


def suspect_clues(suspect):
    """Return a shuffled list of {text, type} dicts from the suspect's traits."""
    clues = []
    for field, templates in SUSPECT_TEMPLATES.items():
        value = getattr(suspect, field, None)
        if value and value in templates:
            clues.append({"text": templates[value], "type": "suspect"})
    random.shuffle(clues)
    return clues


def travel_clues(country):
    """Return a shuffled list of {text, type} dicts hinting at the given country."""
    if country is None:
        return []
    clues = []
    if country.currency:
        clues.append({
            "text": f"They were overheard asking about exchanging money for {country.currency}.",
            "type": "travel",
        })
    if country.exports:
        clues.append({
            "text": f"A customs officer saw the suspect studying brochures about {country.exports}.",
            "type": "travel",
        })
    colours = list(country.flag_colours.values_list("colour", flat=True))
    if colours:
        if len(colours) == 1:
            colour_str = colours[0]
        else:
            colour_str = ", ".join(colours[:-1]) + f" and {colours[-1]}"
        clues.append({
            "text": f"The suspect wore a pin with {colour_str} — like a national flag.",
            "type": "travel",
        })
    if country.geography:
        clues.append({
            "text": f"Someone heard the suspect mention {country.geography}.",
            "type": "travel",
        })
    if country.fauna:
        clues.append({
            "text": f"The suspect had a wildlife guide open to a page about {country.fauna}.",
            "type": "travel",
        })
    if country.flora:
        clues.append({
            "text": f"A florist said the suspect asked about {country.flora}.",
            "type": "travel",
        })
    random.shuffle(clues)
    return clues


def clues_for_stop(suspect, next_country):
    """Return {"suspect": [...], "travel": [...]} clue pools for one trail stop."""
    return {
        "suspect": suspect_clues(suspect),
        "travel": travel_clues(next_country),
    }
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
.venv/bin/python manage.py test game.tests.SuspectCluesTest game.tests.TravelCluesTest game.tests.CluesForStopTest -v 2
```
Expected: `OK` with 8 tests passing.

- [ ] **Step 5: Commit**

```bash
git add game/clues.py game/tests.py
git commit -m "feat: add clue generation"
```

---

## Task 3: Case generation and action functions (`game/logic.py`)

**Files:**
- Write: `game/logic.py`
- Modify: `game/tests.py` (append new test classes)

- [ ] **Step 1: Append failing tests to `game/tests.py`**

Add at the end of `game/tests.py`:

```python
from game.logic import (
    FLIGHT_COST,
    WRONG_FLIGHT_PENALTY,
    do_arrest,
    do_investigate,
    do_travel,
    do_warrant,
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
        "time_remaining": 24,
        "warrant_suspect_id": None,
        "status": "active",
    }


class GenerateCaseTest(TestCase):
    def setUp(self):
        self.suspect = make_suspect()
        self.countries = [make_country(str(i)) for i in range(5)]

    def test_returns_valid_shape(self):
        game = generate_case()
        self.assertIn("suspect_id", game)
        self.assertIn("trail", game)
        self.assertIn("clues_available", game)
        self.assertEqual(game["status"], "active")
        self.assertEqual(game["time_remaining"], 24)

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

    def test_deducts_time(self):
        game = make_game(self.suspect, self.countries)
        result = do_investigate(game, "library")
        self.assertLess(result["time_remaining"], 24)

    def test_adds_clue_to_seen(self):
        game = make_game(self.suspect, self.countries)
        result = do_investigate(game, "police")
        self.assertEqual(len(result["clues_seen"]), 1)

    def test_removes_clue_from_pool(self):
        game = make_game(self.suspect, self.countries)
        before = len(game["clues_available"]["0"]["suspect"])
        result = do_investigate(game, "police")
        after = len(result["clues_available"]["0"]["suspect"])
        self.assertEqual(after, before - 1)

    def test_exhausted_pool_does_nothing(self):
        game = make_game(self.suspect, self.countries)
        game["clues_available"]["0"]["travel"] = []
        result = do_investigate(game, "library")
        self.assertEqual(result["time_remaining"], 24)
        self.assertEqual(result["clues_seen"], [])

    def test_time_zero_sets_lost(self):
        game = make_game(self.suspect, self.countries)
        game["time_remaining"] = 1
        result = do_investigate(game, "police")
        self.assertEqual(result["status"], "lost")

    def test_does_not_mutate_original(self):
        game = make_game(self.suspect, self.countries)
        original_time = game["time_remaining"]
        do_investigate(game, "police")
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
        self.assertEqual(result["time_remaining"], 24 - FLIGHT_COST)

    def test_wrong_country_deducts_penalty(self):
        game = make_game(self.suspect, self.countries)
        result = do_travel(game, 99999)
        self.assertEqual(result["time_remaining"], 24 - WRONG_FLIGHT_PENALTY)

    def test_wrong_country_does_not_advance_stop(self):
        game = make_game(self.suspect, self.countries)
        result = do_travel(game, 99999)
        self.assertEqual(result["current_stop"], 0)

    def test_at_final_stop_does_nothing(self):
        game = make_game(self.suspect, self.countries)
        game["current_stop"] = 2  # final stop for 3-country trail
        result = do_travel(game, self.countries[0].pk)
        self.assertEqual(result["current_stop"], 2)
        self.assertEqual(result["time_remaining"], 24)

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
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
.venv/bin/python manage.py test game.tests.GenerateCaseTest game.tests.DoInvestigateTest game.tests.DoTravelTest game.tests.DoWarrantTest game.tests.DoArrestTest -v 2
```
Expected: `ImportError` — logic.py is empty.

- [ ] **Step 3: Write `game/logic.py`**

```python
import copy
import random

from criminals.models import Suspect
from places.models import Country
from game.clues import clues_for_stop

STARTING_TIME = 24
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
        "time_remaining": STARTING_TIME,
        "warrant_suspect_id": None,
        "status": "active",
    }


def do_investigate(game, location):
    game = copy.deepcopy(game)
    stop_key = str(game["current_stop"])
    clue_type = LOCATION_CLUE_TYPE[location]
    pool = game["clues_available"][stop_key][clue_type]

    if not pool:
        return game

    clue = pool.pop(0)
    game["clues_seen"].append(clue["text"])
    game["time_remaining"] -= LOCATION_COSTS[location]

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
.venv/bin/python manage.py test game.tests.GenerateCaseTest game.tests.DoInvestigateTest game.tests.DoTravelTest game.tests.DoWarrantTest game.tests.DoArrestTest -v 2
```
Expected: `OK` with 20 tests passing.

- [ ] **Step 5: Commit**

```bash
git add game/logic.py game/tests.py
git commit -m "feat: add case generation and game action logic"
```

---

## Task 4: Views

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

    def test_post_valid_location_redirects_to_case(self):
        self._start_game()
        response = self.client.post("/game/investigate/", {"location": "police"})
        self.assertRedirects(response, "/game/case/")

    def test_post_updates_time_in_session(self):
        self._start_game()
        self.client.post("/game/investigate/", {"location": "police"})
        game = self.client.session["game"]
        self.assertLess(game["time_remaining"], 24)

    def test_post_invalid_location_redirects_to_case(self):
        self._start_game()
        response = self.client.post("/game/investigate/", {"location": "bar"})
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
        self.assertEqual(game["time_remaining"], 24 - 4)

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
.venv/bin/python manage.py test game.tests.IndexViewTest game.tests.NewCaseViewTest game.tests.CaseViewTest game.tests.InvestigateViewTest game.tests.TravelViewTest game.tests.WarrantViewTest game.tests.ArrestViewTest game.tests.ResultViewTest -v 2
```
Expected: errors — views and URLs don't exist yet.

- [ ] **Step 3: Write `game/views.py`**

```python
import random

from django.shortcuts import redirect, render

from criminals.models import Suspect
from places.models import Country
from game.logic import (
    do_arrest,
    do_investigate,
    do_travel,
    do_warrant,
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

    context = {
        "game": game,
        "current_country": current_country,
        "locations": locations,
        "travel_options": travel_options,
        "suspects": Suspect.objects.order_by("name"),
        "warrant_suspect": warrant_suspect,
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
    path("travel/", views.travel, name="travel"),
    path("warrant/", views.warrant, name="warrant"),
    path("arrest/", views.arrest, name="arrest"),
    path("result/", views.result, name="result"),
]
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
.venv/bin/python manage.py test game.tests.IndexViewTest game.tests.NewCaseViewTest game.tests.CaseViewTest game.tests.InvestigateViewTest game.tests.TravelViewTest game.tests.WarrantViewTest game.tests.ArrestViewTest game.tests.ResultViewTest -v 2
```
Expected: `TemplateDoesNotExist` errors — templates haven't been created yet. Views resolve correctly otherwise.

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

- [ ] **Step 1: Create `game/templates/game/` directory**

```bash
mkdir -p game/templates/game
```

- [ ] **Step 2: Create `game/templates/game/index.html`**

```html
{% extends 'base.html' %}

{% block title %}New Case — Global Detective{% endblock %}

{% block content %}
  <h1 class="mb-3">Global Detective Quest</h1>
  <p class="lead">A criminal has struck somewhere in the world. Track them across the globe, collect clues, and make the arrest before time runs out.</p>
  <ul class="mb-4">
    <li>Investigate locations to reveal <strong>suspect clues</strong> and <strong>travel hints</strong></li>
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

  <p><strong>Clues you collected:</strong></p>
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

- [ ] **Step 4: Run tests — index and result views should now pass fully**

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
      <strong class="fs-4 {% if game.time_remaining <= 6 %}text-danger{% else %}text-warning{% endif %}">
        {{ game.time_remaining }}h
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

    {# Left panel: investigate + travel #}
    <div class="col-md-7">

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
                    Costs {{ loc.cost }}h —
                    {% if loc.clue_type == 'travel' %}
                      <span class="text-warning">travel clue</span>
                    {% else %}
                      <span class="text-info">suspect clue</span>
                    {% endif %}
                  {% else %}
                    No more clues here
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
            <p class="text-muted small mb-0">No clues collected yet. Investigate a location.</p>
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
Expected: `OK` — all tests pass now that templates exist.

- [ ] **Step 3: Commit**

```bash
git add game/templates/game/case.html
git commit -m "feat: add main game screen template"
```

---

## Task 7: Navigation and final wiring

**Files:**
- Modify: `templates/base.html`

- [ ] **Step 1: Add Game link to navbar in `templates/base.html`**

Find the line:
```html
            <li class="nav-item"><a class="nav-link" href="{% url 'factbook:index' %}">World Fact Book</a></li>
```

Add after it:
```html
            <li class="nav-item"><a class="nav-link" href="{% url 'game:index' %}">Play Game</a></li>
```

- [ ] **Step 2: Run the full test suite**

```bash
.venv/bin/python manage.py test -v 2
```
Expected: all tests pass across all apps.

- [ ] **Step 3: Start the dev server and manually verify the game**

```bash
.venv/bin/python manage.py runserver
```

Visit `http://localhost:8000/game/` and play through a full case:
- Click "Start New Case"
- Investigate at least 2 locations (mix of Police Station and Library)
- Note the clues in the Notepad
- Fly to a destination
- Issue a warrant
- Make an arrest
- Verify the result screen shows the correct culprit

- [ ] **Step 4: Commit**

```bash
git add templates/base.html
git commit -m "feat: add Game link to navigation"
```
