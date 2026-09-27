-- EbonClearance_ProtectionPanel - Keep Settings Interface Options panel.
-- Author:  Serv
-- Source:  https://github.com/powerfulqa/EbonClearance
-- License: see LICENSE; attribution preservation is required.
--
-- Stage 8e-vi of the multi-stage file split (docs/CODE_REVIEW.md item 4).
-- The Keep Settings UI panel (v2.49.3 renamed the sidebar label from
-- "Protection Settings" to "Keep Settings"; internal frame name
-- "EbonClearanceOptionsBlacklistSettings" preserves the v2.15.0 schema
-- and is intentionally NOT renamed - help links / deep-links depend on
-- it). Hosts the auto-protect / keep toggles (autoAddEquipped /
-- autoProtectUpgrades / autoProtectEquipmentSets) and the v2.20.0 affix
-- + chance-on-hit protection toggles + the affixAllowExactDupes setting.
-- v2.49.3: "Sell recipes you already know" (a sell rule) moved OUT to
-- EbonClearance_MerchantPanel.lua.
--
-- Moved into this file:
--   * local BlacklistSettingsPanel = CreateFrame(...) frame creation
--   * The Keep Settings OnShow handler (panel-build body)
--
-- Cross-file dependencies satisfied by NS:
--   * NS.compCache (Core) - initPanel, setPanelWidth, registerWidth,
--     syncEquipped, checkBagsForUpgrades, syncEquipmentSets,
--     peFeaturesVisible (the affix-settings visibility gate)
--   * NS.DB captured at OnShow entry
--   * NS.MakeHeader / NS.MakeLabel (8e-i)
--   * NS.FitScrollContent (8e-ii)
--   * NS.RefreshSellBorders (BagDisplay) - used by the affix /
--     chance-on-hit / affixAllowExactDupes OnClick handlers per the
--     Issue B fix (Test 42 invariant)
--
-- The panel does NOT use AddCheckbox / AddSlider; it builds checkboxes
-- inline because two of the toggles (dupeAffixCB / allTomeCB) carry
-- dynamic status-feedback FontStrings that the flat-row AddCheckbox
-- format can't host. The explanatory notes that used to sit under
-- every toggle were stripped in Task 15 of the help-link refactor;
-- each toggle now links to its Help-panel entry via NS.AddHelpIcon
-- next to the label.

local NS = select(2, ...)
local EC_compCache = NS.compCache
local L = NS.L

-- ============================================================
-- Holds the auto-protect toggles + explanatory notes that previously
-- cluttered the Keep List panel. Schema and behaviour are identical to the
-- pre-v2.15.0 surfacing; this is purely a visual split for consistency with
-- the other list panels' rhythm. The toggles still write to the same DB
-- fields (DB.autoAddEquipped, DB.autoProtectUpgrades, DB.autoProtectEquipmentSets)
-- and still call the same sync helpers (EC_compCache.syncEquipped /
-- checkBagsForUpgrades / syncEquipmentSets), so the PLAYER_EQUIPMENT_CHANGED
-- and EQUIPMENT_SETS_CHANGED reactive paths in the event hub continue to
-- drive the same protection without any wiring changes.
local BlacklistSettingsPanel =
    CreateFrame("Frame", "EbonClearanceOptionsBlacklistSettings", InterfaceOptionsFramePanelContainer)
BlacklistSettingsPanel.name = "Keep Settings"
BlacklistSettingsPanel.parent = "EbonClearance"

BlacklistSettingsPanel:SetScript("OnShow", function(self)
    local DB = NS.DB
    EC_compCache.initPanel(self, function(self)
        if self.autoEquipCB then
            self.autoEquipCB:SetChecked(DB.autoAddEquipped)
        end
        if self.autoUpgradeCB then
            self.autoUpgradeCB:SetChecked(DB.autoProtectUpgrades)
        end
        if self.autoAffixCB then
            self.autoAffixCB:SetChecked(DB.protectAffixedRareItems)
        end
        if self.dupeAffixCB then
            self.dupeAffixCB:SetChecked(DB.affixAllowExactDupes)
        end
        if self.UpdateDupeAffixEnabled then
            self:UpdateDupeAffixEnabled()
        end
        if self.procCB then
            self.procCB:SetChecked(DB.protectChanceOnHitItems)
        end
        if self.unlearnedTomeCB then
            self.unlearnedTomeCB:SetChecked(DB.protectUnlearnedTomes)
        end
        -- v2.74.0: re-evaluated on every re-show, so a PE addon that loads
        -- late (or a /ec affixfallback flip) is picked up without a rebuild.
        if self.UpdatePEVisibility then
            self.UpdatePEVisibility()
        end
    end, function(self, content)
        -- Auto-protect handlers used to refresh `self.listUI` directly because
        -- the list lived on the same frame. Now the list lives on the Keep List
        -- panel, so toggles refresh that panel's list if it's been initialized.
        local function refreshKeepListUI()
            local blPanel = _G["EbonClearanceOptionsBlacklist"]
            if blPanel and blPanel.listUI then
                blPanel.listUI:Refresh()
            end
        end

        NS.MakeHeader(content, L["Keep Settings"], -16)
        local desc = NS.MakeLabel(
            content,
            L["Rules that keep specific items safe from selling. You can override any of them on a single item with Alt+Right-Click - Allow Sell."],
            16,
            -44
        )

        -- v2.10.0: auto-protect equipped gear. Toggling on runs a one-shot sync
        -- of every currently equipped slot into the Keep List, then a reactive
        -- PLAYER_EQUIPMENT_CHANGED handler keeps the list in step with future
        -- gear swaps. The blacklist veto in EC_IsSellable prevents auto-rules
        -- from touching anything on this list, so a replaced upgrade sliding
        -- into bags is automatically protected. Tooltip annotation surfaces
        -- "(auto-protected: equipped)" so users who decide they want an
        -- auto-added item sold can see why it's being kept.
        local autoEquipCB = CreateFrame(
            "CheckButton",
            "EbonClearanceAutoProtectEquippedCB",
            content,
            "InterfaceOptionsCheckButtonTemplate"
        )
        autoEquipCB:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -10)
        autoEquipCB:SetChecked(DB.autoAddEquipped)
        local aeText = _G[autoEquipCB:GetName() .. "Text"]
        if aeText then
            aeText:SetText(L["Keep gear you're wearing"])
            EC_compCache.setPanelWidth(aeText, 60)
            aeText:SetJustifyH("LEFT")
        end
        autoEquipCB:SetScript("OnClick", function(cb)
            local on = cb:GetChecked() and true or false
            local wasOff = (DB.autoAddEquipped ~= true)
            DB.autoAddEquipped = on
            PlaySound("igMainMenuOptionCheckBoxOn")
            if on and wasOff then
                EC_compCache.syncEquipped()
                refreshKeepListUI()
            end
        end)
        self.autoEquipCB = autoEquipCB
        if aeText then
            NS.AddHelpIcon(content, aeText, "LEFT", "RIGHT", 6, 0, "gate-equipped-never-sells")
        end

        -- v2.11.0 auto-protect upgrades. The companion to v2.10.0's auto-
        -- protect-equipped: this one watches BAG_UPDATE for items whose iLvl
        -- exceeds the equipped item in any of their candidate slots (rings,
        -- trinkets, weapons compare against the lower of the two equipped
        -- slots so any genuine upgrade triggers). Looted upgrades sitting in
        -- bags are stamped on the Keep list before any iLvl-cap rule on
        -- Merchant Settings can sweep them up. Default off; opt-in.
        local autoUpgradeCB = CreateFrame(
            "CheckButton",
            "EbonClearanceAutoProtectUpgradesCB",
            content,
            "InterfaceOptionsCheckButtonTemplate"
        )
        autoUpgradeCB:SetPoint("TOPLEFT", autoEquipCB, "BOTTOMLEFT", 0, -10)
        autoUpgradeCB:SetChecked(DB.autoProtectUpgrades)
        local auText = _G[autoUpgradeCB:GetName() .. "Text"]
        if auText then
            auText:SetText(L["Keep upgrades found in bags"])
            EC_compCache.setPanelWidth(auText, 60)
            auText:SetJustifyH("LEFT")
        end
        autoUpgradeCB:SetScript("OnClick", function(cb)
            DB.autoProtectUpgrades = cb:GetChecked() and true or false
            PlaySound("igMainMenuOptionCheckBoxOn")
            if DB.autoProtectUpgrades then
                -- Re-check on toggle so existing bag contents are evaluated
                -- immediately rather than waiting for the next BAG_UPDATE.
                EC_compCache.checkBagsForUpgrades()
                refreshKeepListUI()
            end
        end)
        self.autoUpgradeCB = autoUpgradeCB
        if auText then
            NS.AddHelpIcon(content, auText, "LEFT", "RIGHT", 6, 0, "tshoot-upgrade-keep")
        end

        -- Equipment-set protection stays on in the runtime; its checkbox was
        -- removed from this panel (scope cut).

        -- v2.19.0 PE roguelite affix protection. The base itemID of an
        -- affixed item (e.g. "Thorbia's Gauntlets of Fortified by Pain IV")
        -- is identical to the base, plain version. A user with the base
        -- itemID on their Sell List or Delete List would inadvertently
        -- dump the random-affix version, which is meaningfully different
        -- gear. This toggle is a per-decision gate (no one-shot sync;
        -- protection runs at sell/delete time only). No Keep List
        -- entries are stamped - if the user wants the protected items
        -- on the Keep List explicitly, they Alt+Right-Click to add.
        -- Every widget below that only means something when the affix
        -- system is present. UpdatePEVisibility (defined at the end of
        -- this build, once the whole chain exists) hides the run when
        -- EC_compCache.peFeaturesVisible() is false and re-anchors the
        -- widgets that chain off the end of it.
        --
        -- Checkbox label FontStrings are children of their checkbox and
        -- hide with it, so they are not collected here. The [?] help
        -- icons ARE collected: NS.AddHelpIcon parents them to `content`,
        -- not to the label, so they would otherwise float in the gap.
        local peWidgets = {}
        local function markPE(w)
            if w then
                peWidgets[#peWidgets + 1] = w
            end
            return w
        end

        local autoAffixCB = markPE(CreateFrame(
            "CheckButton",
            "EbonClearanceProtectAffixedRareCB",
            content,
            "InterfaceOptionsCheckButtonTemplate"
        ))
        autoAffixCB:SetPoint("TOPLEFT", autoUpgradeCB, "BOTTOMLEFT", 0, -10)
        autoAffixCB:SetChecked(DB.protectAffixedRareItems)
        local aaText = _G[autoAffixCB:GetName() .. "Text"]
        if aaText then
            aaText:SetText(L["Keep blue/purple items with affixes"])
            EC_compCache.setPanelWidth(aaText, 60)
            aaText:SetJustifyH("LEFT")
        end
        autoAffixCB:SetScript("OnClick", function(cb)
            DB.protectAffixedRareItems = cb:GetChecked() and true or false
            PlaySound("igMainMenuOptionCheckBoxOn")
            -- Same refresh as the second autoAffixCB OnClick handler
            -- below (the second SetScript in this build callback). This first handler is replaced by
            -- the second a few lines later within the same build
            -- callback, so the body never runs in practice - but the
            -- refresh is included for symmetry so the verdict-toggle
            -- refresh invariant (Test 42) catches BOTH SetScript sites
            -- without special-casing the dead one. Future contributors
            -- who add a third autoAffixCB:SetScript will get the
            -- refresh by default.
            if NS.RefreshSellBorders then
                NS.RefreshSellBorders()
            end
        end)
        self.autoAffixCB = autoAffixCB
        if aaText then
            markPE(NS.AddHelpIcon(content, aaText, "LEFT", "RIGHT", 6, 0, "gate-affix-protection"))
        end

        -- v2.23.0 child toggle: exact-rank duplicate gate on the affix
        -- protection. Reads PE's PerkService.GetGrantedPerks /
        -- GetLockedPerks (`_G.ProjectEbonhold`) to know which
        -- (affixName, rank) pairs the player owns. When ON AND a bag
        -- item's affix matches exact rank, the protection releases the
        -- item to the normal sell / DE rules. Inert without PE.
        local dupeAffixCB = markPE(CreateFrame(
            "CheckButton",
            "EbonClearanceAffixAllowExactDupesCB",
            content,
            "InterfaceOptionsCheckButtonTemplate"
        ))
        -- Indent further right than the parent toggle so the child sits
        -- a column to the right. (Pre-Task 15 this used the parent's
        -- explanatory note as an indented anchor; the note is gone now,
        -- so we apply the +26 indent directly against the parent CB.)
        dupeAffixCB:SetPoint("TOPLEFT", autoAffixCB, "BOTTOMLEFT", 26, -8)
        dupeAffixCB:SetChecked(DB.affixAllowExactDupes)
        local daText = _G[dupeAffixCB:GetName() .. "Text"]
        if daText then
            daText:SetText(L["Allow selling affixes you already have"])
            EC_compCache.setPanelWidth(daText, 86)
            daText:SetJustifyH("LEFT")
        end
        dupeAffixCB:SetScript("OnClick", function(cb)
            DB.affixAllowExactDupes = cb:GetChecked() and true or false
            PlaySound("igMainMenuOptionCheckBoxOn")
            -- Toggling the dupe-allow flag changes EC_IsSellable's
            -- verdict for every affixed Rare/Epic item the player has
            -- already extracted. Without this refresh, slot tints stay
            -- frozen until the host bag UI repaints (bag close/reopen).
            -- Same rule as the list-mutation refresh invariant.
            if NS.RefreshSellBorders then
                NS.RefreshSellBorders()
            end
            -- v2.44.0: re-evaluate the active-state explainer so the
            -- note shows / clears the moment the toggle flips.
            if self.UpdateDupeAffixEnabled then
                self.UpdateDupeAffixEnabled()
            end
        end)
        self.dupeAffixCB = dupeAffixCB
        if daText then
            markPE(NS.AddHelpIcon(content, daText, "LEFT", "RIGHT", 6, 0, "gate-allow-rank-dupes"))
        end

        -- Status / explainer FontString. Carries both:
        --   * The disabled-state status message ("Turn on affix
        --     protection above"). v2.74.0 dropped the second arm ("PE not
        --     detected") - that state now hides the whole affix run
        --     instead of greying it, so the note is unreachable there.
        --   * v2.44.0 active-state explainer that the toggle is an
        --     independent sell rule (real player feedback: the
        --     toggle and the rank slider felt like they were
        --     fighting; making each one's note explain its scope
        --     resolves the confusion at the point of toggling).
        local dupeAffixNote = markPE(content:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall"))
        dupeAffixNote:SetPoint("TOPLEFT", dupeAffixCB, "BOTTOMLEFT", 26, -2)
        EC_compCache.setPanelWidth(dupeAffixNote, 86)
        dupeAffixNote:SetJustifyH("LEFT")
        if dupeAffixNote.SetWordWrap then
            dupeAffixNote:SetWordWrap(true)
        end
        self.dupeAffixNote = dupeAffixNote

        -- Extra affix rank / BoE / auto-mark controls removed from the UI
        -- (scope cut); DB fields and runtime behaviour are unchanged.

        local function UpdateDupeAffixEnabled()
            local parentOn = DB.protectAffixedRareItems == true
            if parentOn then
                dupeAffixCB:Enable()
                if daText then
                    daText:SetTextColor(1, 1, 1)
                end
                if DB.affixAllowExactDupes then
                    dupeAffixNote:SetText(
                        L["|cff888888Sells affixes at ranks you already own.|r"]
                    )
                else
                    dupeAffixNote:SetText("")
                end
            else
                dupeAffixCB:Disable()
                if daText then
                    daText:SetTextColor(0.5, 0.5, 0.5)
                end
                dupeAffixNote:SetText(L["|cff888888Turn on the affix protection above to use this option.|r"])
            end
        end
        self.UpdateDupeAffixEnabled = UpdateDupeAffixEnabled
        UpdateDupeAffixEnabled()

        -- Wire parent CB's OnClick to keep the child's enabled state in
        -- sync. (Replaces the simpler OnClick the parent had above.)
        autoAffixCB:SetScript("OnClick", function(cb)
            DB.protectAffixedRareItems = cb:GetChecked() and true or false
            PlaySound("igMainMenuOptionCheckBoxOn")
            UpdateDupeAffixEnabled()
            -- Toggling the master affix-protection flag flips
            -- EC_IsSellable's verdict for every affixed Rare/Epic slot.
            -- Repaint so the borders track immediately. Same rule as
            -- the list-mutation refresh invariant.
            if NS.RefreshSellBorders then
                NS.RefreshSellBorders()
            end
        end)

        -- v2.20.0 Chance-on-hit protection. Sibling toggle to the affix
        -- check above: Project Ebonhold lets players extract a weapon's
        -- "Chance on hit:" proc spell and apply it to another item, so an
        -- item with that proc text is meaningfully different from the
        -- base itemID. Same gate-at-decision-time design as the affix
        -- toggle. No quality filter because chance-on-hit is a stable
        -- per-itemID property and extraction works regardless of rarity.
        local procCB = markPE(CreateFrame(
            "CheckButton",
            "EbonClearanceProtectChanceOnHitCB",
            content,
            "InterfaceOptionsCheckButtonTemplate"
        ))
        procCB:SetPoint("TOPLEFT", dupeAffixNote, "BOTTOMLEFT", -26, -10)
        procCB:SetChecked(DB.protectChanceOnHitItems)
        local pcText = _G[procCB:GetName() .. "Text"]
        if pcText then
            pcText:SetText(L["Keep items with chance-on-hit procs"])
            EC_compCache.setPanelWidth(pcText, 60)
            pcText:SetJustifyH("LEFT")
        end
        self.procCB = procCB
        if pcText then
            markPE(NS.AddHelpIcon(content, pcText, "LEFT", "RIGHT", 6, 0, "gate-chance-on-hit"))
        end

        -- v2.26.0 child toggle: exact-proc duplicate gate on the chance-
        -- on-hit protection. When ON AND a bag item's proc description
        -- matches an engraving spell the player has already extracted (via
        -- PE's Extraction Service / spellbook), the protection releases
        -- the item to the normal sell / DE rules. Inert without any
        -- learned procs.
        procCB:SetScript("OnClick", function(cb)
            DB.protectChanceOnHitItems = cb:GetChecked() and true or false
            PlaySound("igMainMenuOptionCheckBoxOn")
            -- Same reasoning as the affix-protection toggles: flipping
            -- this changes EC_IsSellable's verdict for every chance-on-
            -- hit item not on the Allow Sell list. Repaint immediately
            -- so the user sees the effect of their setting change.
            if NS.RefreshSellBorders then
                NS.RefreshSellBorders()
            end
        end)

        local unlearnedTomeCB = CreateFrame(
            "CheckButton",
            "EbonClearanceProtectUnlearnedTomesCB",
            content,
            "InterfaceOptionsCheckButtonTemplate"
        )
        unlearnedTomeCB:SetPoint("TOPLEFT", procCB, "BOTTOMLEFT", 0, -10)
        unlearnedTomeCB:SetChecked(DB.protectUnlearnedTomes)
        local utText = _G[unlearnedTomeCB:GetName() .. "Text"]
        if utText then
            utText:SetText(L["Keep unlearned tomes and recipes"])
            EC_compCache.setPanelWidth(utText, 60)
            utText:SetJustifyH("LEFT")
        end
        self.unlearnedTomeCB = unlearnedTomeCB
        if utText then
            NS.AddHelpIcon(content, utText, "LEFT", "RIGHT", 6, 0, "gate-tome-recipe")
        end

        unlearnedTomeCB:SetScript("OnClick", function(cb)
            DB.protectUnlearnedTomes = cb:GetChecked() and true or false
            PlaySound("igMainMenuOptionCheckBoxOn")
            if NS.RefreshSellBorders then
                NS.RefreshSellBorders()
            end
        end)

        -- v2.74.0: show / hide the affix + proc-extraction run as a block.
        -- On a realm without the affix system those settings can never do
        -- anything, so they are removed rather than left greyed.
        --
        -- The run is contiguous - autoAffixCB through procCB - so the
        -- tome toggle re-anchors below autoUpgradeCB when the run is hidden.
        --
        -- Defined here rather than beside UpdateDupeAffixEnabled because
        -- it needs unlearnedTomeCB, created further down the build.
        local function UpdatePEVisibility()
            local show = EC_compCache.peFeaturesVisible == nil or EC_compCache.peFeaturesVisible()
            for i = 1, #peWidgets do
                local w = peWidgets[i]
                if show then
                    w:Show()
                else
                    w:Hide()
                end
            end
            unlearnedTomeCB:ClearAllPoints()
            if show then
                unlearnedTomeCB:SetPoint("TOPLEFT", procCB, "BOTTOMLEFT", 0, -10)
            else
                unlearnedTomeCB:SetPoint("TOPLEFT", autoUpgradeCB, "BOTTOMLEFT", 0, -10)
            end
        end
        self.UpdatePEVisibility = UpdatePEVisibility
        UpdatePEVisibility()

        NS.FitScrollContent(content, unlearnedTomeCB)
    end, true)
end)
