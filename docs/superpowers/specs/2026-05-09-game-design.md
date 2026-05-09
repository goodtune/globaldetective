# Global Detective Quest — Game Design Spec

**Date:** 2026-05-09  
**Status:** Approved

---

## Overview

A Carmen Sandiego-style deduction game built as a new `game` Django app. The player follows a suspect's trail across countries, gathering clues by investigating locations, then issues a warrant and makes an arrest before time runs out.

---

## Core Gameplay Loop

1. Player starts a new case from the home page.
2. A case is generated server-side: a random suspect and a trail of 3–5 countries are chosen.
3. Player is placed at the first country (the crime scene) with a time budget of **7 days (168 hours)**, displayed as "X days, Y hours".
4. Player investigates locations in the current country. Clicking a location shows 3 witnesses to speak to. Choosing one costs time; the witness either reveals a clue or knows nothing (random).
5. Clues are either **suspect trait clues** (narrowing down the culprit) or **travel clues** (hinting at the next country in the trail via factbook data).
6. Player uses travel clues to identify the next country and flies there (costs time; wrong choice costs a penalty).
7. Repeat until the player has enough suspect clues to identify the culprit.
8. Player issues a **warrant** naming a specific suspect.
9. Player hits **Make Arrest** — can be done from any country once a warrant is issued.
10. **Win**: warrant names the correct suspect and arrest is made before time runs out.
11. **Lose**: time reaches 0, or no arrest made in time.

---

## Architecture

### New app: `game`

No new database models. All game state lives in `request.session`. Existing `Suspect` and `Country` models provide all data.

### Session state

```python
{
    "suspect_id": int,              # PK of the culprit
    "trail": [int, int, ...],       # list of Country PKs, 3–5 entries
    "current_stop": int,            # index into trail (0 = crime scene)
    "clues_seen": [str, ...],       # human-readable clue strings collected
    "clues_available": {            # per stop: remaining clue pool (pre-generated)
        "0": [{"text": str, "type": "suspect"|"travel"}, ...],
        "1": [...],
        ...
    },
    "active_location": str|None,     # location key if witness selection is active, else None
    "last_witness_result": dict|None,  # {"witness": str, "clue": str|None} after speaking
    "time_remaining": int,          # hours remaining (starts at 168)
    "warrant_suspect_id": int|None, # PK of warranted suspect, or None
    "status": str,                  # "active" | "won" | "lost"
}
```

### URL structure

```
GET  /game/               → start screen (new case button)
POST /game/new/           → generate case, store in session, redirect to /game/case/
GET  /game/case/          → main game screen (shows witnesses if active_location is set)
POST /game/investigate/   → activate a location (set active_location, no time cost)
POST /game/speak/         → speak to a witness (deduct time, 50% clue if pool not empty)
POST /game/travel/        → fly to a chosen country (deduct time, penalty if wrong)
POST /game/warrant/       → issue or change warrant (select suspect from dossier)
POST /game/arrest/        → attempt arrest (win/lose resolution)
GET  /game/result/        → outcome screen (win or lose)
```

---

## Case Generation

On `POST /game/new/`:

1. Pick a random `Suspect` as the culprit.
2. Pick a random trail of 3–5 distinct `Country` objects.
3. For each stop `i`, generate a clue pool:
   - **Suspect clues**: one clue per available trait on the culprit (`sex`, `hair`, `hobby`, `feature`, `auto`, `food`) — only traits that are set.
   - **Travel clues** (stops 0 to n-2 only): drawn from the *next* country's factbook fields (`currency`, `exports`, `flag_colours`, `geography`, `fauna`, `flora`).
4. Shuffle each stop's clue pool.
5. Final stop (index n-1) has only suspect clues (no next-country travel clues needed).
6. Store entire generated structure in session.

---

## Investigation Locations

Four fixed location types appear at every country. The player clicks a location to enter it (free), then chooses one of three witnesses to speak to (costs time). The **clue type is never shown** on the location button — the player must discover what each location tends to reveal.

| Location | Time Cost per Conversation | Witness Pool | Clue Type |
|---|---|---|---|
| 📚 Library | 2 hours | Librarian, Student, Professor | Travel clue |
| 🚔 Police Station | 3 hours | Detective, Officer, Duty Sergeant | Suspect trait |
| ✈️ Airport | 1 hour | Customs Agent, Flight Attendant, Pilot | Travel clue |
| 🛒 Market | 2 hours | Merchant, Customer, Market Inspector | Suspect trait |

### Witness mechanic

1. Player clicks a location button → `active_location` is set in session, page reloads showing 3 witness buttons. No time cost.
2. Player clicks a witness → time is deducted. If the clue pool for this location type is non-empty, there is a **50% chance** the witness reveals the next clue. Otherwise "nothing useful".
3. The clue (or "nothing") is shown as `last_witness_result` on the case page.
4. Player returns to the normal case view and can speak to another witness or go elsewhere.
5. A location button is disabled only when its clue pool is **empty**.
6. Clues are only consumed from the pool when a witness actually reveals one (duds don't drain the pool).

---

## Clue Templates

### Suspect clues

| Trait | Template |
|---|---|
| `sex=FEMALE` | "A hotel clerk said the suspect was a woman." |
| `sex=MALE` | "A witness described the suspect as a man." |
| `hair=RED` | "The suspect had red hair, according to a witness." |
| `hair=BLONDE` | "A bartender mentioned the suspect was blonde." |
| `hair=BROWN` | "The suspect had brown hair." |
| `hair=BLACK` | "Several witnesses noted the suspect had black hair." |
| `hair=GREY` | "A witness said the suspect had grey hair." |
| `hobby=TENNIS` | "Someone saw the suspect carrying a tennis racket." |
| `hobby=MUSIC` | "The suspect was heard humming and carrying sheet music." |
| `hobby=CLIMBING` | "A shop owner sold the suspect mountain climbing gear." |
| `hobby=SKYDIVE` | "The suspect asked about local skydiving operators." |
| `hobby=SWIMMING` | "A witness saw the suspect heading to the pool with goggles." |
| `hobby=CROQUET` | "The suspect was spotted reading a book about croquet." |
| `feature=LIMP` | "Several witnesses noted the suspect walked with a limp." |
| `feature=RING` | "The suspect was wearing a distinctive ring." |
| `feature=TATTOO` | "A bartender noticed the suspect had a tattoo." |
| `feature=SCAR` | "A witness described a scar on the suspect's face." |
| `feature=JEWELERY` | "The suspect was wearing a lot of jewellery." |
| `auto=CONVERTIBLE` | "The suspect was spotted driving a convertible." |
| `auto=LIMO` | "Someone saw the suspect leave in a limousine." |
| `auto=RACECAR` | "The suspect was seen near a racecar." |
| `auto=MOTORBIKE` | "A witness saw the suspect riding a motorcycle." |
| `food=SEAFOOD` | "The suspect was seen dining on seafood at the harbour." |
| `food=MEXICAN` | "The hotel chef said the suspect requested Mexican food." |

### Travel clues (drawn from next country's factbook)

| Field | Template |
|---|---|
| `currency` | "They were overheard asking about exchanging money for {value}." |
| `exports` | "A customs officer saw the suspect studying brochures about {value}." |
| `flag_colours` | "The suspect wore a pin with {value} — like a national flag." |
| `geography` | "Someone heard the suspect mention {value}." |
| `fauna` | "The suspect had a wildlife guide open to a page about {value}." |
| `flora` | "A florist said the suspect asked about {value}." |

For `flag_colours` (M2M), the clue joins up to 3 colours: e.g. "red, white and blue".

---

## Travel Mechanic

When the player is ready to fly:

- The **correct next country** plus **5 random decoy countries** are shown as flight options.
- Each option shows the country name and a flat flight cost of **6 hours**.
- **Correct choice**: `current_stop` advances by 1, time deducted.
- **Wrong choice**: 4-hour penalty, player stays at current stop.

---

## Warrant & Arrest

- The **Issue Warrant** form shows the full suspect list (names only, no pictures or traits).
- The player can issue or change a warrant at any time at no time cost.
- Once a warrant is issued, the **Make Arrest** button appears.
- On arrest:
  - Correct suspect → `status = "won"`, redirect to result screen.
  - Wrong suspect → `status = "lost"`, redirect to result screen.

---

## UI Layout

### Main game screen (`/game/case/`)

- **Top bar**: current country, time remaining as "X days, Y hours" (prominent, turns red below 12h), warrant status.
- **Left panel (normal mode)**: four location buttons (no clue type label shown), followed by travel destination grid.
- **Left panel (witness mode)**: when `active_location` is set, shows 3 witness buttons for that location instead. Location buttons hidden.
- **Last witness result**: shown below the witness buttons (or location buttons after returning) — either the clue text or "Nothing useful from [witness name]."
- **Right panel (notepad)**: all clues collected so far.
- **Bottom of right panel**: Issue Warrant form + Make Arrest button.

### Other screens

- `/game/` — simple landing page with "Start New Case" button.
- `/game/result/` — win or lose message, reveals the correct suspect, "Play Again" button.

---

## Tech Stack

- Django 5.1 sessions (no new models or packages)
- Bootstrap 5.3 (already in base template)
- Standard Django form POST → redirect → GET pattern

---

## Out of Scope

- User accounts or login
- Leaderboards or scoring history
- Multiple simultaneous cases
- Mobile-specific layout optimisation
- Difficulty levels
