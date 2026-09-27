# Notice - prior art, upstream, and this fork

This file documents the design lineage of EbonClearance honestly, so
that any future "they copied us" or "you copied them" claim has a
record to refer to. Convergence on similar shapes is acknowledged
where it exists; originality is not claimed where the pattern is
shared with the broader WoW 3.3.5a addon ecosystem.

---

## This fork (mturchik / scope cut)

This working tree is a **fork** of Serv's EbonClearance
(https://github.com/powerfulqa/EbonClearance), maintained at
https://github.com/mturchik/EbonClearance for Project Ebonhold play.

**What changed in this iteration**

- The addon is cut down to three jobs: companion summon loop, sell /
  keep / delete decisions, and the four lists. See
  [`docs/SCOPE_CUT.md`](docs/SCOPE_CUT.md).
- Removed from this fork (among other surfaces): Process Bags / Fast
  Loot / auto-open, Quickstart, Help, Sold History / Loot Log, Personal
  / Guild / Server stats and all share transports, update alerts,
  list and settings profile UIs, Import/Export, and the Item
  Highlighting options panel (listing-status bag borders stay, always
  on).
- Settings that used to have checkboxes for "always on" behaviour
  (equipment-set Keep, out-of-combat summon, restore after load, fixed
  sell pace, Delete List destroys) remain as forced behaviour with no
  UI control.
- Scavenger restore also runs on combat exit (queued on combat enter)
  and on dungeon / raid entry when Enable and Summon Greedy are on.
  Disabling mid scavenger / merchant / scavenger cycle aborts the swap.

**What the licence still requires**

Upstream authorship and provenance stay. Per [`LICENSE`](LICENSE),
redistributions must preserve Serv as `## Author:`, the in-game byline,
the provenance globals, the LICENSE file, and this NOTICE. The
canonical upstream URL in provenance / byline remains
https://github.com/powerfulqa/EbonClearance (fingerprint salt and
author credit are part of that contract). This fork does not rebrand
the addon name, `/ec`, or the SavedVariable names.

Behaviour history for upstream releases remains in
[`CHANGELOG.md`](CHANGELOG.md); notes for the thin fork begin at the
v2.78.0 scope-cut stanza.

---

## Convergent patterns in the 3.3.5a niche

EbonClearance ships in a niche that several other addons also
target: automated inventory management for a single private server,
sharing a small set of WoW 3.3.5a APIs and a core gameplay loop (loot,
summon, sell, repeat). Feature parity between addons in this niche -
auto-loot cycles, companion-pet management, mount-aware behaviour,
stuck-detection heuristics, batched selling with disconnect-prevention
caps, two-scope item lists, hand-rolled minimap buttons, keybind
`Bindings.xml` files, and so on - reflects that small API surface and
that loop converging on broadly similar solutions. Convergence on the
same shape is not, in itself, evidence of copying in either direction.

---

## Related projects in the PE auto-vendor niche

Two other addons solve overlapping problems in the same niche. The
comparisons below describe **upstream** EbonClearance's history as well
as patterns that remain in this fork; features named only in upstream
(Process Bags, version-update gossip, and so on) are not present here
after the scope cut.

- [AutoDelete](https://github.com/disarrayed/AutoDelete) (MIT-licensed) -
  whitelist + delete + sell hybrid with a tabbed custom-window UI, an
  Auto-Invite system, and ElvUI bag drag-buttons. Ships features like
  `autoAddEquipped` (sync currently-equipped gear to a Keep list +
  reactive PLAYER_EQUIPMENT_CHANGED) and combat-gated summon toggles.
  Several of these landed in AutoDelete's v3.10-v3.18 series (April 25 -
  May 2, 2026), in some cases days before upstream EbonClearance's
  equivalents shipped (notably `autoAddEquipped`, May 2 in AutoDelete
  vs May 4 in EC v2.10.0).

  EbonClearance's equivalents were written independently against the
  same Blizzard 3.3.5a API surface. The 1-19 inventory slot walk with
  shirt+tabard skip, the one-shot-at-toggle-flip + reactive-event
  split, and the quiet-bulk-vs-chatty-reactive print pattern are all
  shapes the API itself forces; the code that implements them in EC
  uses different storage fields (`blacklistAuto` vs `whitelistText`),
  different add helpers, and different print formatting, and EC carries
  origin-tag extensions (`"equipped"` / `"upgrade"`) that AutoDelete
  does not. EC's out-of-combat summon gate is the polar opposite of
  AutoDelete's in-combat-only summon toggle.

- [AutoLoot](https://github.com/Veronica-Vasilieva/AutoLoot) (license
  per upstream repo) - smaller, blacklist-first auto-vendor with a
  state-machine companion cycle and a custom standalone window.
  Different scope and architecture from EC; no overlapping
  implementation patterns.

Upstream EbonClearance once shipped a version-update nudge on a group
addon channel (v2.39.0), following a long-standing 3.3.5a pattern used
by Auctionator and others. That transport (`NS.Comms` and related share
modules) is **removed in this fork**.

Cross-pollination of ideas in a small private-server addon ecosystem
is normal and acknowledged. Where EbonClearance was inspired by an
idea visible in another addon's behaviour, the implementation was
written from scratch against the Blizzard API; verbatim code from
another addon is not present in this codebase.

The acknowledgement runs both ways. AutoDelete's v3.20 README (May
2026) includes a `Credits` section noting "AutoDelete has been
re-implemented in part by EbonClearance" and "We appreciate the
shoutouts in their source comments", reciprocating early
`EbonholdStuff`-era source-comment mentions. Both projects ship under
their own licences (AutoDelete: MIT; EbonClearance: source-available
attribution licence; see [`LICENSE`](LICENSE)).

---

## Community contributions (upstream)

Where players have shared modifications or prototypes that informed
upstream EC's design, the credit is recorded here. Some of the
resulting features remain in this fork (affix debug trail, "already
known" tooltip cue); others (for example the opt-in item-level
overlay UI) were dropped with the Item Highlighting options panel and
are dormant or absent here.

**Ivo (v2.37.0).** Ivo shared his personally-modified EC fork plus a
small standalone companion addon and gave permission for the patterns
to be adapted back into upstream. Three v2.37.0 features started from
his work:

- **Affix-pipeline event log** (`AffixDebugDump`, `/ec affixdebug`) -
  still present.
- **"Already known by this character" tooltip annotation** - still
  present.
- **Item-level overlay on equippable gear slots** - upstream shipped
  an opt-in UI; this fork has no options panel for it and does not
  expose the overlay as a player setting.

Thanks Ivo. No code from his companion addon was copied into EC
verbatim.

---

## Source-available licence pattern

EbonClearance ships under a custom **source-available attribution
licence**. The structural shape (Grant / Attribution / No-Rebrand /
Forks / Non-commercial / No-Warranty / Termination / Severability)
follows similar source-available licences that have appeared in the
3.3.5a private-server addon ecosystem before this one. EbonClearance
does not claim its licence structure is original; the structure was
adopted because it is the right shape for the same anti-rebrand
pressure other addons in this scene are reacting to.

---

## Provenance globals pattern

EbonClearance writes the following globals at addon load:

```
EBONCLEARANCE_IDENT       = "EbonClearance"
EBONCLEARANCE_AUTHOR      = "Serv"
EBONCLEARANCE_ORIGIN      = "<canonical upstream github url>"
__EbonClearance_origin    = "<canonical upstream github url>"
__EbonClearance_author    = "Serv"
__EbonClearance_watermark = "<derived hex hash>"
```

The `__<addon>_origin` / `__<addon>_author` form is a pattern that has
appeared in other 3.3.5a addons before this one. The
`__EbonClearance_watermark` global and the export-string fingerprint
suffix (`;fp=<6 hex>`) are EbonClearance-specific. See
[`docs/ADDON_GUIDE.md`](docs/ADDON_GUIDE.md) "Fingerprint and
watermark" for verification. This fork keeps those upstream values;
it does not replace them with the fork URL.

---

## Verifiable timeline

Upstream EbonClearance has been on GitHub publicly since 2026-04-05
with full commit history at
https://github.com/powerfulqa/EbonClearance. This fork's history is at
https://github.com/mturchik/EbonClearance. Anyone wishing to check
which features shipped when can clone either repository and review the
commit log.

---

## The honest summary

- **This fork**: thinned Project Ebonhold build of Serv's EbonClearance;
  scope documented in `docs/SCOPE_CUT.md`; maintained at
  `mturchik/EbonClearance` with upstream attribution preserved.
- **Core gameplay loop (summon / sell / lists)**: developed upstream
  with public commit history; retained and adjusted here.
- **Licence structure and provenance globals**: adopted patterns that
  exist elsewhere in the 3.3.5a addon ecosystem with acknowledgement
  (this file), not original to this project.
- **Fingerprint and watermark mechanism**: specific to upstream
  EbonClearance; unchanged in this fork.

If you are reading this file in a further derivative's source tree,
that tree is required by EbonClearance's [LICENSE](LICENSE) to preserve
this file in full and to keep attribution to Serv and
https://github.com/powerfulqa/EbonClearance.
