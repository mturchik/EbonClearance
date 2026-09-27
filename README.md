# EbonClearance

[![Licence](https://img.shields.io/badge/Licence-Source--Available-blue?style=for-the-badge)](LICENSE)

**Companion summon loop, vendoring, and sell / keep / delete lists for Project Ebonhold.**

This tree is a thinned fork of [Serv's EbonClearance](https://github.com/powerfulqa/EbonClearance). It keeps the decision core and scavenger / merchant cycle, and drops the larger surface (Process Bags, stats / share, Help, profiles UI, Quickstart, and related pages). Attribution to Serv and the upstream source URL stay intact under the licence. See [NOTICE.md](NOTICE.md).

No external libraries. Stock Blizzard 3.3.5a APIs only (Interface 30300). What ships is listed in [docs/SCOPE_CUT.md](docs/SCOPE_CUT.md).

## What it does

Three jobs:

1. **Summon and keep the Greedy Scavenger** when Enable and Summon Greedy are on (out of combat; restore after loading screens, combat exit, and dungeon / raid entry).
2. **Decide what sells, stays, or is deleted** at a merchant (grey junk, rarity rules, the four lists, PE affix / proc / tome protection when that system is present).
3. **Maintain Sell, Account Sell, Keep, and Delete lists**, with tooltip verdicts and Alt+Right-Click actions.

Bag slots get coloured borders by listing status (always on; no options panel).

## Selling and protection

- **Per-rarity rules** (Common / Uncommon / Rare / Epic) with equipped iLvl or a fixed max iLvl.
- **Four lists:** Sell List, Account Sell List, Keep List, Delete List. Delete List items are destroyed when a vendor run processes them.
- **Always kept or never sold without a checkbox:** greys with a sell price always sell; quest items, locked slots, equipped gear, and equipment-manager set members are protected.
- **Keep Settings (toggles):** equipped gear, bag upgrades, affixed Rare/Epic, chance-on-hit procs, unlearned tomes / recipes, and "Allow selling affixes you already have".
- **Tooltip + `/ec sellinfo`** show the verdict before you vendor. Alt+Right-Click → Allow Sell overrides a protection on one item.

## The scavenger / merchant loop

- Summon Greedy Scavenger after selling (when enabled). Dismiss on mount; restore when you dismount if the addon dismissed it.
- Auto-loot cycle: when free bag slots fall to the threshold, swap to the Goblin Merchant, sell, then bring the Scavenger back.
- Flipping **Enable** off mid-cycle aborts the swap so the merchant step does not keep resummoning the Scavenger.
- Both companion pets are Project Ebonhold critters; on a realm without them that leg no-ops. Merchant target (Goblin / normal / both) is PE-gated the same way.

## Installation

1. Download or clone this repository into `Interface/AddOns/EbonClearance`.
2. Log in and type `/ec`.
3. New characters get Common / Uncommon rules under equipped iLvl, equipped-gear Keep, and Scavenger / auto-loot cycle on. Tune from Merchant, Keep, and Scavenger settings.

Per-character on/off: Main panel **Enable EbonClearance**, right-click the minimap button, or `/ec enable` / `/ec disable`. `/ec status` prints the current state.

## Settings (under `/ec`)

| Page | What it controls |
|------|------------------|
| EbonClearance (main) | Enable, minimap button |
| Merchant Settings | Per-rarity thresholds; Sell at (Goblin / normal / both) when PE companions exist |
| Scavenger Settings | Summon after selling, auto-loot cycle, bag-slot threshold |
| Keep Settings | The six protection toggles above |
| Sell / Account Sell / Keep / Delete | The four lists |

Also: WoW key bindings (settings, enable toggle, force sell, Target Goblin Merchant), minimap left-click for options, Alt+Right-Click on bag items.

## Slash commands

| Command | Description |
|---------|-------------|
| `/ec` | Open settings |
| `/ec status` / `enable` / `disable` | Master Enable for this character |
| `/ec clean` [`apply`] | List (or fix) IDs on more than one list |
| `/ec clean upgrades` [`apply`] | Report or clear stale Keep (upgrade) entries |
| `/ec sellinfo [bag slot]` | Trace one bag slot's sell / keep / delete verdict |
| `/ec bugreport` | Copyable diagnostic dump |
| `/ec minimap on\|off\|reset` | Minimap button |
| `/ec locale [auto\|frFR\|deDE]` | Display language |
| `/ec help` | Slash reference in chat |
| `/ecdebug` | Debug bag scan |

Diagnostics (affix / proc / perf): `/ec affixdebug`, `affixdump`, `affixfind`, `procdump`, `scandebug`, `captureproc`, `pairaudit`, `paircheck`, `autolearnsim`, `autolearnpeek`, `perf`, `spike`, `bubbles`, `affixfallback`.

## Other 3.3.5a servers

Loads on a plain WotLK realm. When the PE affix / companion surface is absent, PE-only Keep Settings, the Scavenger panel, the merchant-target dropdown, and affix diagnostics hide (or chance-on-hit protection turns off so proc weapons are not wedged forever). Grey sell, rarity rules, the four lists, vendor cycle, and tooltips still run.

Affix knowledge is also read from the spellbook (server-side). On Project Ebonhold without the PE addon loaded, affix protection can still work. `/ec affixfallback on` then `/reload` previews the non-PE layout on PE.

## For contributors

- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) - file map
- [docs/ADDON_GUIDE.md](docs/ADDON_GUIDE.md) - 3.3.5a constraints and gotchas
- [docs/SCOPE_CUT.md](docs/SCOPE_CUT.md) - what this fork keeps and removed
- [docs/TRANSLATING.md](docs/TRANSLATING.md) - locale templates

Run `stylua --check *.lua`, `luacheck *.lua`, and `lua tests/run_all.lua` (nine suites). The `.toc` lists every Lua file; the event hub is `EbonClearance_Events.lua`.

## Licence and notice

Source-available attribution licence: [LICENSE](LICENSE). Preserve author credit, in-game byline, provenance globals, and this project's identifiers. Prior art, upstream lineage, and **this fork's scope** are documented in [NOTICE.md](NOTICE.md). Release history: [CHANGELOG.md](CHANGELOG.md).
