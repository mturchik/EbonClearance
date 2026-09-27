# Simplification scope

EbonClearance is cut down to three jobs: run the companion summon loop, decide what sells, and maintain the sell, keep, and delete lists.

**Settings cut** and **feature cut** have both landed. Chopped pages, files, bindings, and suites are gone. `NS.features` is gone. The DB proxy is two-tier (per-character / account). Player-facing docs describe the thin addon.

## Baseline

These stay, as settings or as behaviour with the checkbox removed.

### Settings that stay

| Setting | Page |
|---------|------|
| Enable EbonClearance | EbonClearance |
| Show the EbonClearance minimap button | EbonClearance |
| Bag borders by listing status (always on; no options) | (no page) |
| Sell at (Goblin Merchant, normal merchants, or both) | Merchant Settings |
| Summon Greedy Scavenger after selling | Scavenger Settings |
| Enable auto-loot cycle (loot, sell, repeat) | Scavenger Settings |
| Bag slots remaining before selling | Scavenger Settings |
| Quality threshold per rarity, with Use equipped iLvl or a fixed max iLvl | Merchant Settings |
| Keep gear you're wearing | Keep Settings |
| Keep upgrades found in bags | Keep Settings |
| Keep blue/purple items with affixes | Keep Settings |
| Allow selling affixes you already have | Keep Settings |
| Keep items with chance-on-hit procs | Keep Settings |
| Keep unlearned tomes and recipes | Keep Settings |
| Sell List | Sell List |
| Account Sell List | Account Sell List |
| Keep List | Keep List |
| Delete List | Delete List |

Alt+right-click on a bag item stays. The item tooltip still says whether the item will sell, stay, or be deleted.

### Behaviour that stays, with no checkbox

| Behaviour | Notes |
|-----------|-------|
| Grey items with a vendor price always sell | No checkbox. EC-TRAP. |
| Quest items, locked slots, and equipped items are never sold or deleted | No checkbox. |
| Keep items in your saved equipment sets | Always on. |
| Only summon the Greedy Scavenger when out of combat | Always on. Re-summons on combat exit (queued on combat enter) and when entering a dungeon/raid instance, when Enable + Summon Greedy are on. |
| Re-summon the Greedy Scavenger after a loading screen if it was out | Always on. |
| A fixed pause between sells | Safe fixed pace. |
| Items on the Delete List are destroyed | List membership is enough. |

## Removed (feature cut)

These features and their files are deleted. Suites `test_comms_version`, `test_guildshare`, `test_procshare`, and `test_servershare` are gone. Bindings for Process Bags and Loot Log are gone.

- Quickstart, Current Rules, Sold History, Loot Log
- Stats - Personal / Guild / Server and all share transports
- Update alerts, conflicting-addon warning
- Process Bags, Fast Loot, auto-open
- List Profiles, Settings Profiles, Import/Export (settings-profile storage flattened onto per-character fields)
- Help
- Sell known recipes, repair, keep-bags-open, bind filter
- Extra affix / delete automation beyond the baseline Keep Settings toggles
- Item Highlighting options panel (borders stay, always on for every listing-status category; iLvl overlay and item-ID tooltip stay off with no UI)

Bag listing-status borders paint from `EbonClearance_BagDisplay.lua` with no settings page.

### Files deleted

`EbonClearance_QuickstartPanel.lua`, `EbonClearance_HistoryWindow.lua`, `EbonClearance_StatsPanel.lua`, `EbonClearance_GuildPanel.lua`, `EbonClearance_ServerStatsPanel.lua`, `EbonClearance_GuildShare.lua`, `EbonClearance_ProcShare.lua`, `EbonClearance_ServerShare.lua`, `EbonClearance_RealmComms.lua`, `EbonClearance_Comms.lua`, `EbonClearance_Process.lua`, `EbonClearance_ProcessBagsPanel.lua`, `EbonClearance_ProfilesPanel.lua`, `EbonClearance_HelpPanel.lua`, `EbonClearance_ItemHighlightingPanel.lua`.

### Baseline files that stay

`EbonClearance_Companion.lua`, `EbonClearance_Vendor.lua`, `EbonClearance_Decision.lua`, `EbonClearance_Protection.lua`, `EbonClearance_Tooltip.lua`, `EbonClearance_BagContextMenu.lua`, `EbonClearance_Minimap.lua`, `EbonClearance_BagDisplay.lua`, list panels, `EbonClearance_BugReport.lua`, and the thin Main / Merchant / Scavenger / Keep Settings panels.

Pure `NS.Decision.sell` / `deleteEligible` still accept chopped ctx fields so `tests/test_decision.lua` regression fixtures remain. The live adapter (`EC_fillSharedCtx`) does not feed those fields.
