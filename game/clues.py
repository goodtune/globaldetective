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
