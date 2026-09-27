# EbonClearance

[![Download Latest](https://img.shields.io/github/v/release/powerfulqa/EbonClearance?style=for-the-badge&label=Download&color=orange)](https://github.com/powerfulqa/EbonClearance/releases/latest/download/EbonClearance.zip)
[![Downloads (this release)](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fpowerfulqa%2FEbonClearance%2Fbadge-data%2Flatest.json&style=for-the-badge&color=blue)](https://github.com/powerfulqa/EbonClearance/releases/latest)
[![Downloads (lifetime)](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fpowerfulqa%2FEbonClearance%2Fbadge-data%2Fdownloads.json&style=for-the-badge&color=blue)](https://github.com/powerfulqa/EbonClearance/releases)
[![Licence](https://img.shields.io/badge/Licence-Source--Available-blue?style=for-the-badge)](LICENSE)

**Full bags, every quest hub, every farm session. EbonClearance handles the chore.**

Sells what you don't want. Keeps what you do. Knows the difference because it reads your Project Ebonhold affix and proc state directly. Sensible defaults, deep controls when you want them. No external libraries, stock Blizzard 3.3.5a APIs only.

Runs on any 3.3.5a server. On a realm without Project Ebonhold's affix system the PE-only settings hide themselves and the standard WotLK feature set carries on unchanged - see [Other 3.3.5a servers](#other-335a-servers).

The addon was simplified to the companion summon loop, sell/keep/delete decisions, and the four lists. See [docs/SCOPE_CUT.md](docs/SCOPE_CUT.md).

## How it sells

- **Per-rarity auto-sell rules** (Common / Uncommon / Rare / Epic). Caps follow your equipped iLvl, or set a fixed max.
- **Sell, Keep, and Delete lists**, per-character and account-wide. Bulk-add from your bags by colour.
- **Tooltip says what will happen** before you vendor. `/ec sellinfo` traces every decision, and Alt+Right-Click → **Sell Info** gives the same trace for one item.

## What it protects

- **Affixed Rare/Epic drops.** Affix-keyed Allow-Sell overrides for the ones you've decided you don't need.
- **Chance-on-hit procs you haven't extracted yet**, plus tomes and recipes you haven't learned.
- **Quest items, equipped gear, equipment-manager set members.** Equipment-set protection stays on with no checkbox. Each protection has an Alt+Right-Click → Allow Sell override.

## The loop

- **Greedy Scavenger summon** with auto-rebuy and dismiss-on-mount. Heavy-combat safe.
- **Goblin Merchant summon** when bags fill up. Throttled drain so private-server anti-flood doesn't disconnect you. (Both companions are Project Ebonhold pets; on other realms this leg simply no-ops.)

A complete enumeration of every feature lives in [docs/ADDON_GUIDE.md](docs/ADDON_GUIDE.md). Behaviour history is in [CHANGELOG.md](CHANGELOG.md). For the design lineage, see [NOTICE.md](NOTICE.md).

## Installation

1. Head to the [latest release](https://github.com/powerfulqa/EbonClearance/releases/latest) and download the zip file.
2. Extract the `EbonClearance` folder into your `Interface/AddOns` directory.
3. Log in and type `/ec` to open the settings panel.
4. Sensible defaults are seeded for new characters - Common and Uncommon auto-vendor below your equipped iLvl, equipped gear is auto-Kept, the Scavenger / auto-loot cycle are on. Tune from there.

Per-character on/off: tick / untick the **Enable EbonClearance** checkbox at the top of the main panel, right-click the minimap button, or type `/ec enable` / `/ec disable`. Use `/ec status` to check the current state at any time.

## Configuration

All settings live under `/ec`. Highlights:

- **Lists.** Sell List, Account Sell List, Keep List, Delete List. Items on the Delete List are destroyed when bags are scanned.
- **Merchant Settings.** Per-rarity quality thresholds with `Use equipped iLvl` or fixed-max-iLvl cap, and merchant target (Goblin / normal vendors / both - hidden on a realm without the Goblin Merchant).
- **Keep Settings.** Auto-protect equipped gear, looted upgrades, affixed Rare/Epic items, chance-on-hit items, and unlearned tomes / recipes. Affix-sell control: "Allow selling affixes you already have".
- **Scavenger Settings.** Summon after selling, auto-loot cycle, bag-slot threshold. Hidden on a realm without the companion pets.
- **Bag borders.** Coloured borders by listing status (Sell / Keep / Delete / Account Sell / Junk / Rule, plus Known/Needed Affix when PE is present). Always on; no options.
- **Key Bindings (WoW).** Open settings, toggle enabled, force sell at current merchant, and Target Goblin Merchant (a secure binding that works in combat).
- **Minimap button.** Left: options. Right: toggle Enable. Show/hide via the Main panel checkbox or `/ec minimap`.
- **Alt+Right-Click any bag item** for a quick-action menu (add to Sell / Keep / Delete, Allow Sell on protected items, **Sell Info**).

## Slash Commands

| Command | Description |
|---------|-------------|
| `/ec` | Open the settings panel |
| `/ec status` | Show whether EbonClearance is currently enabled or disabled |
| `/ec enable` | Turn EbonClearance on for this character |
| `/ec disable` | Turn EbonClearance off for this character |
| `/ec clean` | Report any item IDs present in more than one list |
| `/ec clean apply` | Auto-resolve list conflicts using precedence Keep List > Delete List > Sell List |
| `/ec clean upgrades` | Report stale `Keep (upgrade)` Keep List entries |
| `/ec clean upgrades apply` | Manually remove stale `Keep (upgrade)` entries (with confirmation) |
| `/ec bugreport` | Generate a diagnostic report in a copyable window |
| `/ec sellinfo [bag slot]` | Trace why a bag item will or won't sell |
| `/ec minimap on\|off\|reset` | Show, hide, or re-centre the EC minimap button |
| `/ec affixdebug on\|off\|status\|dump\|clear` | Record affix-detection events for bug reports |
| `/ec affixdump` | Diagnostic: print known-affix set + scan bags |
| `/ec affixfind <text>` | Diagnostic: search known-affix descriptions |
| `/ec procdump` | Diagnostic: print PE learned-proc catalog state |
| `/ec scandebug <bag> <slot>` | Diagnostic: dump hidden scan-tooltip lines for a slot |
| `/ec captureproc` | Diagnostic: dump chance-on-hit and affix catalog lines |
| `/ec pairaudit` | Diagnostic: check recorded chance-on-hit itemIDs |
| `/ec paircheck [itemID]` | Diagnostic: suggest an affix from a weapon's proc text (display-only) |
| `/ec autolearnsim <itemID> <spellID>` | Diagnostic: simulate an autolearn event |
| `/ec autolearnpeek` | Dump the chance-on-hit autolearn state |
| `/ec perf` | Show memory, CPU, cache and list sizes |
| `/ec spike` | Show recent frame hitches EbonClearance contributed to |
| `/ec bubbles` | Diagnostic: Scavenger bubble mute tracking |
| `/ec affixfallback on\|off\|status` | Diagnostic: ignore PE affix data / preview non-PE layout |
| `/ec locale [auto\|frFR\|deDE]` | Show or force the addon's display language |
| `/ec help` | Print the slash-command reference in chat |
| `/ecdebug` | Show debug info and run a bag scan |

## Requirements

- World of Warcraft (WotLK client, Interface 30300)
- Project Ebonhold for the affix and proc-extraction features. Everything else runs on any 3.3.5a server.

## Other 3.3.5a servers

EbonClearance was written for Project Ebonhold, but it loads and runs on a plain WotLK realm. It probes for the affix system at runtime and, when it isn't there, removes the settings that depend on it rather than showing you controls that can never do anything.

**Works exactly as documented:** grey auto-sell, the per-rarity rules, Sell / Keep / Delete / Account lists, the vendor cycle, tooltip verdicts, and the localization layer.

**Hidden, because there is nothing for them to act on:** affix protection and "Allow selling affixes you already have", chance-on-hit protection, the "Sell at" merchant-target dropdown (every vendor is allowed instead), the Scavenger panel, and the affix diagnostics.

Chance-on-hit protection is switched off rather than merely hidden. It means "keep this until you extract the proc", and where extraction doesn't exist there is no release path, so leaving it on would wedge every proc weapon in your bags.

Detection isn't just "is the PE addon installed" - affix knowledge is read from your spellbook, which is server-side. If you play on Project Ebonhold without the PE addon loaded, affix protection still works and the settings stay visible.

On Project Ebonhold, `/ec affixfallback on` followed by `/reload` shows you this layout.

## For Contributors

Working on the addon? There's developer documentation under [docs/](docs/):

- [docs/ADDON_GUIDE.md](docs/ADDON_GUIDE.md) is the prescriptive guide for coding in this addon. Read it first.
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) is the file map.
- [docs/CODE_REVIEW.md](docs/CODE_REVIEW.md) is a short list of known follow-up cleanups.
- [docs/SCOPE_CUT.md](docs/SCOPE_CUT.md) records the simplification that has landed (settings cut + feature cut).
- [docs/TRANSLATING.md](docs/TRANSLATING.md) is the guide for translating the addon.

A Luacheck config ([.luacheckrc](.luacheckrc)) and a StyLua formatter config ([stylua.toml](stylua.toml)) are checked in. Run `stylua --check *.lua` and `luacheck *.lua` before opening a PR. The addon ships as 24 `.lua` files after the feature cut; the entry hub is `EbonClearance_Events.lua`. Nine invariant suites run via `lua tests/run_all.lua`.

## Thanks

Feature ideas and bug reports from the Project Ebonhold community shape the addon. Selected community-driven changes:

- **Auto-delete on pickup** - suggested by Sanavesa.
- **Auto-mark PvP gear (Resilience) for deletion** - requested by Murlocked, for cleaning up bag-clutter after farming.
- **Class-restriction self-heal on the Keep-Upgrade sweep** (Druids no longer accumulate bows, Mages no longer accumulate relics) - reported by Murlocked.
- **Auto-mark unsellable affix dupes for deletion** - requested by Broyo.
- **Announce auto-delete / auto-mark in chat** toggle - requested by ayres.
- **2H-narrowing on the upgrade / downgrade predicates** (1H weapons and offhands compare correctly against an equipped 2H instead of misfiring on the locked-empty offhand slot) - reported by "Perfect Bidoof" and Zukii.
- **Hard iLvl ceiling on the affix-sell paths** (a rare high-iLvl item can't sneak past a rarity cap just because its affix is a known dupe) - near item-loss report from Bizzaro.
- **Quickstart Q13 default label fix + Stats-Guild "Sold by Quality" alignment** - reported by Qvintus.

## Changelog

Per-release notes live in [CHANGELOG.md](CHANGELOG.md). For prior-art acknowledgement and the design lineage, see [NOTICE.md](NOTICE.md).

## Notice

EbonClearance ships in a niche where similar inventory-management addons exist for the same private server. [NOTICE.md](NOTICE.md) documents prior art and convergent patterns honestly: which structural elements (the source-available licence shape, the provenance globals form) are adopted from conventions already present in the 3.3.5a addon ecosystem, and which (the fingerprint and watermark mechanism) are specific to this project. Read it before drawing conclusions about influence in either direction.

## Licence

This project is distributed under the EbonClearance Source-Available Attribution Licence. You may use, modify, and redistribute the addon (including in private-server addon-pack bundles) provided you preserve the author credit, the in-game byline, the provenance globals, and the LICENSE file itself, and you do not silently rebrand the addon name, the `/ec` slash command, the SavedVariable names, or the `EC:` import/export prefix. Forks under a new name are welcome as long as attribution to the original author and source URL is preserved. See the [LICENSE](LICENSE) file for the full terms.
