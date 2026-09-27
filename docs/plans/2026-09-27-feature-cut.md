# Feature cut (scope cut step 2)

Status: **planned**. Settings cut is done (`NS.features`, thin panels, pages unregistered). This pass deletes chopped code and drops the gates once nothing remains to gate.

Source of truth for what ships: [docs/SCOPE_CUT.md](../SCOPE_CUT.md).

## Review: what players still configure

Pages still registered (Events.lua): Main, Merchant, Scavenger, Sell List, Account Sell List, Keep List, Keep Settings, Delete List.

### Settings that stay (checkboxes / controls)

| Control | Page | Notes |
|---------|------|-------|
| Enable EbonClearance | Main | Per-character. Also toggled by minimap right-click / binding. |
| Show the EbonClearance minimap button | Main | Kept after settings cut so enable/disable needs no `/ec` or options. |
| Sell at (Goblin / normal / both) | Merchant | |
| Quality threshold per rarity + Use equipped iLvl / max iLvl | Merchant | Bind-type dropdowns already removed from UI; `buildCtx` forces `bindFilter = "any"`. |
| Summon Greedy Scavenger after selling | Scavenger | |
| Enable auto-loot cycle | Scavenger | |
| Bag slots remaining before selling | Scavenger | |
| Keep gear you're wearing | Keep Settings | |
| Keep upgrades found in bags | Keep Settings | |
| Keep blue/purple items with affixes | Keep Settings | |
| Allow selling affixes you already have | Keep Settings | |
| Keep items with chance-on-hit procs | Keep Settings | |
| Keep unlearned tomes and recipes | Keep Settings | |
| Sell / Account Sell / Keep / Delete lists | list pages | Edited in-panel and via Alt+right-click. |

Tooltip sell/keep/delete line and Alt+right-click context menu stay.

### Behaviour that stays with no checkbox (already force-on in live path)

| Behaviour | Implementation note |
|-----------|---------------------|
| Equipment-set protection | Always on; checkbox gone. |
| Summon only out of combat | Always on. |
| Restore Scavenger after loading screen | Always on. |
| Fixed sell pace | Fast/Turbo/slider gone; safe fixed pause. |
| Delete List means destroy | `enableDeletion` checkbox gone; list membership is enough. |
| Grey with sell price always sells | Unchanged EC-TRAP. |
| Quest / locked / equipped never sold or deleted | Unchanged. |

### Settings already removed (settings cut)

Two buckets from SCOPE_CUT:

1. **Became automatic** - equipment sets, OOC summon, restore after load, sell pace, allow-delete. Controls gone; behaviour stays.
2. **Left with the feature** - everything on the chopping block (Quickstart, stats, shares, Process Bags, highlighting, profiles, Help, repair, keep-bags-open, bind filter, known recipes, extra affix/delete automation, etc.). UI gone; `NS.features.* = false` so SavedVariables cannot re-enable live paths. **Code still loads.**

`NS.features.minimapButton = true` is the only cut-era flag that stays on.

## Goal of this pass

Make the chopping block real: delete or strip the code, drop dead suites, sync player/contributor docs. After this pass, `NS.features` should shrink to nothing (or be removed) because there is nothing left to force off.

Open decision (pick before Phase C):

- **A (recommended):** Keep `Decision.sell` / `deleteEligible` pure branches for chopped ctx fields; only `buildCtx` / `EC_fillSharedCtx` stop setting them. Fixtures in `test_decision.lua` that exercise affix-rank / known-recipes / known-procs / protectAllTomes stay as regression pins for the pure core.
- **B:** Hard-delete those branches from `Decision.sell` and rewrite/remove the matching fixtures. Smaller decision core; larger test churn; loses pins that still document junkOnly / sellPrice / whitelist interactions.

Recommend **A** unless you want the pure core to literally only know baseline rules.

## Phased plan

### Phase 0 - Prep (no behaviour change)

1. Re-read SCOPE_CUT + this plan. Confirm minimap stays.
2. Snapshot: `lua tests/run_all.lua` green on current master-with-settings-cut.
3. Work on a branch if desired; do not tag until docs + CHANGELOG are ready.

### Phase 1 - Delete leaf feature files

Safe first cut: nothing else should require these at runtime once gated off.

Delete and drop from `EbonClearance.toc`:

| Feature | Files |
|---------|-------|
| Quickstart | `EbonClearance_QuickstartPanel.lua` |
| Sold History | `EbonClearance_HistoryWindow.lua` |
| Personal stats + Loot Log UI | `EbonClearance_StatsPanel.lua` |
| Guild stats | `EbonClearance_GuildPanel.lua` |
| Realm stats | `EbonClearance_ServerStatsPanel.lua` |
| Guild share | `EbonClearance_GuildShare.lua` |
| Proc share | `EbonClearance_ProcShare.lua` |
| Realm share | `EbonClearance_ServerShare.lua`, `EbonClearance_RealmComms.lua` |
| Comms / version alerts | `EbonClearance_Comms.lua` |
| Process Bags | `EbonClearance_Process.lua`, `EbonClearance_ProcessBagsPanel.lua` |
| Item Highlighting page | `EbonClearance_ItemHighlightingPanel.lua` |
| Profiles / import-export | `EbonClearance_ProfilesPanel.lua` |
| Help | `EbonClearance_HelpPanel.lua` |

Also in this phase:

- `Bindings.xml`: remove `CLICK EbonClearanceProcessCastBtn:LeftButton` and `EBONCLEARANCE_TOGGLE_LOOTLOG`.
- Delete suites: `tests/test_comms_version.lua`, `tests/test_guildshare.lua`, `tests/test_procshare.lua`, `tests/test_servershare.lua`. Remove their entries from `tests/run_all.lua`.
- Grep for `NS.Comms`, `NS.RealmComms`, `NS.GuildShare`, `NS.ProcShare`, `NS.ServerShare`, `NS.ShowHistory`, `NS.ShowHelp`, `NS.OpenQuickstart`, Process Cast button globals. Stub or delete call sites in Events so load does not error (Phase 2 finishes the strip; Phase 1 must at least not nil-index).

Verify: `luac -p` on remaining `EbonClearance_*.lua`, then `lua tests/run_all.lua`.

### Phase 2 - Strip chopped logic from files that stay

Work file-by-file. Prefer delete over `if NS.features` once the feature file is gone.

| File | Strip |
|------|-------|
| `EbonClearance_Events.lua` | Loot-log capture / hidden-item set; `/ec rules` + Current Rules; Fast Loot; auto-open; repair + guild-bank repair; keep-bags-open; auto-delete on pickup / grey; auto-mark resilience / affix / recipes; announce deletions; conflict warning; version-alert / share init hooks; Quickstart open-on-load; Process Bags rearm; sold-history slash; Loot Log slash/binding handlers; settings-profile slash helpers that only served the Profiles UI. Keep: event hub, EnsureDB, vendor/companion dispatch, `/ec` open settings, Enable toggle, sellinfo wiring, bugreport hooks, minimap create. |
| `EbonClearance_MainPanel.lua` | Dead slash catalog leftovers if any; **`NS.RefreshStats` / `RefreshStatsTick` / `ResetLifetimeStats` and Main OnShow calls** (owned Personal Stats; Stats panel deleted in Phase 1). Keep Enable + minimap + byline. Decide whether lifetime counters in DB still increment with no UI (bugreport may want session sold/deleted counts - keep writers, drop RefreshStats UI). |
| `EbonClearance_MerchantPanel.lua` | Any residual repair / keep-bags / bind-filter / known-recipes UI. |
| `EbonClearance_ProtectionPanel.lua` | Residual rank-floor / BoE exception / sell-known-procs / keep-learned-tomes / hi-ilvl auto-mark UI. |
| `EbonClearance_KeepDeletePanels.lua` | Delete Settings automation controls if any remain; keep Delete List page. |
| `EbonClearance_BagDisplay.lua` | Bag borders + iLvl overlay. Keep `/ec sellinfo`. |
| `EbonClearance_Tooltip.lua` | Item ID line. Keep sell/keep/delete verdict (English `statusTag` EC-TRAP). |
| `EbonClearance_Decision.lua` | Per open decision A/B above. At minimum `EC_fillSharedCtx` already forces chopped flags off via `NS.features`; after cut, stop reading those DB fields in the adapter. |
| `EbonClearance_Protection.lua` | Runtime helpers used only by chopped sell/mark paths (keep baseline affix/proc/tome protection used by Keep Settings). |
| `EbonClearance_Minimap.lua` | No delete. Confirm Target Goblin Merchant secure button and LDB launcher still build. |

Verify after each major file or at least after Events + Main + Decision: `lua tests/run_all.lua`.

### Phase 3 - Settings-profile storage

Deleting `EbonClearance_ProfilesPanel.lua` does **not** remove `settingsProfiles` / `settingsProfileFields` / the DB proxy in Events.

Options:

1. **Collapse proxy (recommended for scope cut):** Keep `PER_CHAR_FIELDS` routing. Stop routing selling-behaviour fields through `settingsProfiles`; read/write them on the character (or top-level account) namespace directly. Migrate once in `EnsureDB`: copy active profile fields onto the live namespace, leave old `settingsProfiles` table in SavedVariables untouched (downgrade-safe, ignore thereafter). Update `tests/test_dbproxy.lua` to match.
2. **Leave proxy:** Smaller diff, but dead schema and mental load stay.

Do not assign the DB proxy back onto `EbonClearanceDB` (existing EC-TRAP).

### Phase 4 - Remove `NS.features` scaffolding

Once every live gate is gone:

1. Delete `NS.features` from Core (or leave an empty comment pointing at SCOPE_CUT).
2. Remove every `NS.features and NS.features.foo` check.
3. Flip/remove settings-cut pins in `tests/test_perf_guardrails.lua` that asserted "checkbox absent" / "page unregistered" / feature false - replace with "file absent" / "symbol absent" where useful.
4. Grep `NS.features` - must be zero.

### Phase 5 - Static suite + locale cleanup

- `test_perf_guardrails.lua`: drop or rewrite pins that required deleted files (Comms, GuildShare, Stats panel registration, Help, Process Bags, History window, RefreshStats-on-StatsPanel, etc.). Prefer absence pins over rewriting dead behaviour pins.
- `test_affix_resilience.lua`: PE gates stay; anything tied only to deleted panels goes.
- `test_layout_reactivity.lua` / `test_comment_hygiene.lua`: should auto-follow `.toc` file list; confirm SOURCE_PATHS still derive from toc.
- `test_locale_coverage.lua`: either leave orphaned locale keys (harmless templates) or prune keys whose only `L["..."]` call sites died. Pruning is optional; if done, run coverage + integrity.
- `test_decision.lua`: follow decision A or B from above.
- `test_dbproxy.lua`: follow Phase 3.

Target: `lua tests/run_all.lua` green; suite count drops from 13 to 9 if the four share/comms suites are removed.

### Phase 6 - Docs and surface text

Same commit or immediate follow-up (release rules):

- `docs/SCOPE_CUT.md` - mark feature cut landed; move "Code to remove later" to "Removed".
- `README.md` - slash table, feature bullets, install notes.
- `docs/ADDON_GUIDE.md` / `docs/ARCHITECTURE.md` / `CLAUDE.md` - file count, suite list, removed modules.
- `EbonClearance.toc` Notes line - drop "looting / profession processing" claims that no longer apply.
- In-game strings that still advertise chopped panels (Main description is already baseline-shaped).
- `CHANGELOG.md` stanza when tagging (minor bump: schema/docs/surface change).
- Do **not** hand-bump toc Version / `ADDON_VERSION`.

BugReport stays (`EbonClearance_BugReport.lua` is not in this cut). Trim any bugreport sections that only dump chopped feature state if they error after deletion.

### Phase 7 - Verify gate

1. `stylua` on touched Lua.
2. `luacheck EbonClearance_*.lua` at 0 warnings.
3. `luac -p` on every remaining `EbonClearance_*.lua`.
4. `lua tests/run_all.lua`.
5. Grep: no em dash (U+2014); no new third-party addon names in new artefacts; `EC-TRAP:` lines not deleted casually.
6. Manual smoke (in-game): Enable, minimap show/hide + right-click toggle, quality rules, Keep Settings, four lists, companion summon loop, vendor sell, tooltip verdict, Alt+right-click.

## Suggested commit slices

Smaller reviews, still one logical release:

1. Phase 1 (delete leaf files + toc + bindings + four suites) + minimal Events nil-guards.
2. Phase 2 Events/Main/BagDisplay/Tooltip strip.
3. Phase 2 Decision/Protection + test_decision alignment.
4. Phase 3 DB proxy collapse + test_dbproxy.
5. Phase 4 remove `NS.features` + pin updates.
6. Phase 5-6 docs + CHANGELOG.

Or one large commit if preferred; do not tag until docs match.

## Out of scope

- Renaming remaining panels.
- Redesigning Decision API beyond the A/B choice.
- Relicensing / provenance cleanup.
- Implementing anything still listed only in historical `docs/plans/` or `docs/specs/` unrelated to this cut.
- Removing BugReport.

## Done when

- Chopped files are gone from disk and `.toc`.
- Chopped bindings and slash entry points are gone.
- Baseline settings table in SCOPE_CUT matches the live UI.
- Four share/comms suites gone; remaining suites green.
- `NS.features` gone or empty.
- Docs describe the thin addon, not the pre-cut surface.
