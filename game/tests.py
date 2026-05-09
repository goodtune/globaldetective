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
