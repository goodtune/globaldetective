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
        self.countries = [make_country(str(i)) for i in range(5)]

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
        self.countries = [make_country(str(i)) for i in range(5)]

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
        self.countries = [make_country(str(i)) for i in range(5)]

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
        self.countries = [make_country(str(i)) for i in range(5)]

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
        self.countries = [make_country(str(i)) for i in range(5)]

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
        self.countries = [make_country(str(i)) for i in range(5)]

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
        self.countries = [make_country(str(i)) for i in range(5)]

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
