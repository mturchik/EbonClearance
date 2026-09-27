-- EbonClearance_MerchantPanel - Merchant Settings Interface Options panel.
-- Author:  Serv
-- Source:  https://github.com/powerfulqa/EbonClearance
-- License: see LICENSE; attribution preservation is required.
--
-- Stage 8e-ii of the multi-stage file split (docs/CODE_REVIEW.md item 4).
-- The Merchant Settings UI panel: vendor mode dropdown, repair toggles,
-- vendor interval / max-items sliders, fast-mode toggle, per-rarity
-- rule rows (White/Green/Blue/Epic with iLvl caps + bind filter +
-- useEquippedILvl toggle).
--
-- Moved into this file:
--   * EC_WHITELIST_QUALITIES dropdown data (rarity labels for the
--     per-rarity rule rows)
--   * MerchantPanel frame (named "EbonClearanceOptionsMerchant")
--   * EC_MERCHANT_MODES dropdown data (Goblin / Normal / All)
--   * The MerchantPanel OnShow handler (the panel-build body that
--     constructs all the dropdowns, sliders, and per-rarity rule rows)
--
-- Cross-file dependencies read inline:
--   * NS.compCache (Core) - initPanel, setPanelWidth, registerWidth,
--     refreshLayouts, getBindType
--   * NS.DB captured at OnShow entry
--   * NS.MakeHeader / NS.MakeLabel (EbonClearance_Events.lua) - panel text;
--     NS-exposed in Stage 8e-i.
--   * NS.AddCheckbox / NS.AddSlider / NS.ColorTextByQuality /
--     NS.StyleInputBox / NS.FitScrollContent (EbonClearance_Events.lua) -
--     panel widget primitives; NS-exposed as Stage 8e-ii prep.
--   * NS.PrintNice / NS.PrintNicef (EbonClearance_Events.lua) - chat output.
--   * Various WoW globals - CreateFrame, UIDropDownMenu_*,
--     PlaySound, GameTooltip, etc.

local NS = select(2, ...)
local EC_compCache = NS.compCache
local L = NS.L

-- Quality-threshold options shared by the Merchant Settings panel.
--
-- The table is constructed inside the OnShow build callback (not at file
-- load time) because this file loads BEFORE EbonClearance_Events.lua and the
-- NS.ColorTextByQuality binding doesn't exist yet at load. Eager table
-- construction would call nil here. The build callback runs lazily on
-- first OnShow, by which time EbonClearance_Events.lua has loaded and NS is
-- fully populated. The OnShow build is gated by initPanel's "build
-- only once" lock so this evaluates exactly once per session, same as
-- the original file-scope upvalue.
local EC_WHITELIST_QUALITIES   -- assigned inside the build callback below

local MerchantPanel = CreateFrame("Frame", "EbonClearanceOptionsMerchant", InterfaceOptionsFramePanelContainer)
MerchantPanel.name = "Merchant Settings"
MerchantPanel.parent = "EbonClearance"

local EC_MERCHANT_MODES = {
    { text = L["|cffb6ffb6Goblin Merchant|r Only"], value = "goblin" },
    { text = L["Normal Merchants Only"], value = "any" },
    -- v2.13.x: renamed from "Both (All Merchants)" and made the new default
    -- in EnsureDB so brand-new users without the Goblin Merchant pet still
    -- get useful auto-vendor behaviour at normal merchants out of the box.
    { text = L["All Merchants"], value = "both" },
}

MerchantPanel:SetScript("OnShow", function(self)
    local DB = NS.DB
    EC_compCache.initPanel(self, function(self)
        if self.RefreshMerchantModeDropDown then
            self:RefreshMerchantModeDropDown()
        end
        for q = 1, 4 do
            local cb = self["qualityRow" .. q .. "CB"]
            local input = self["qualityRow" .. q .. "Input"]
            local useEqCB = self["qualityRow" .. q .. "UseEq"]
            if cb and DB.qualityRules and DB.qualityRules[q] then
                cb:SetChecked(DB.qualityRules[q].enabled)
            end
            if input and DB.qualityRules and DB.qualityRules[q] then
                input:SetText(tostring(DB.qualityRules[q].maxILvl or 0))
            end
            if useEqCB and DB.qualityRules and DB.qualityRules[q] then
                useEqCB:SetChecked(DB.qualityRules[q].useEquippedILvl == true)
            end
            if cb and cb._applyInputEnabled then
                cb._applyInputEnabled()
            end
        end
    end, function(self, content)
        -- Build-time table population. See the EC_WHITELIST_QUALITIES
        -- declaration above for why this can't run at file load.
        EC_WHITELIST_QUALITIES = {
            { text = NS.ColorTextByQuality(1, L["Common"]), value = 1 },
            { text = NS.ColorTextByQuality(2, L["Uncommon"]), value = 2 },
            { text = NS.ColorTextByQuality(3, L["Rare"]), value = 3 },
            { text = NS.ColorTextByQuality(4, L["Epic"]), value = 4 },
        }

        NS.MakeHeader(content, L["Merchant Settings"], -16)
        -- Panel-specific intro only. Generic "grey junk auto-sells" cross-cut
        -- removed; it's covered on the Main panel.
        NS.MakeLabel(content, L["Change which items sell automatically, and at which merchants."], 16, -44)

        -- Merchant mode dropdown
        local modeLabel = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        modeLabel:SetPoint("TOPLEFT", 16, -76)
        modeLabel:SetText(L["Sell at:"])

        local modeDD = CreateFrame("Frame", "EbonClearanceMerchantModeDD", content, "UIDropDownMenuTemplate")
        modeDD:SetPoint("LEFT", modeLabel, "RIGHT", -8, -2)

        local function GetModeText(mode)
            for _, entry in ipairs(EC_MERCHANT_MODES) do
                if entry.value == mode then
                    return entry.text
                end
            end
            return EC_MERCHANT_MODES[1].text
        end

        local function MerchantModeInit(_frame, level)
            for _, entry in ipairs(EC_MERCHANT_MODES) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = entry.text
                info.value = entry.value
                info.checked = (DB.merchantMode == entry.value)
                info.func = function()
                    DB.merchantMode = entry.value
                    UIDropDownMenu_SetText(modeDD, entry.text)
                    PlaySound("igMainMenuOptionCheckBoxOn")
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end

        UIDropDownMenu_SetWidth(modeDD, 180)
        UIDropDownMenu_SetText(modeDD, GetModeText(DB.merchantMode))
        UIDropDownMenu_Initialize(modeDD, MerchantModeInit)
        -- v2.66.1 iter 3 (Serv report): back to inline [?] next to the
        -- dropdown. Right-edge alignment via setPanelWidth on modeLabel
        -- (iter 2) pushed modeDD off-screen because modeDD anchors to
        -- modeLabel's RIGHT and modeLabel's frame became panel-wide.
        -- Two-anchor SetPoint hack (iter 1) didn't visibly move it
        -- either. Accept the inline position - matches the Scavenger
        -- slider [?] pattern (also inline).
        local modeHelp = NS.AddHelpIcon(content, modeDD, "LEFT", "RIGHT", 4, 2, "gate-merchant-mode")

        self.RefreshMerchantModeDropDown = function()
            UIDropDownMenu_SetText(modeDD, GetModeText(DB.merchantMode))
        end

        -- v2.74.0: two of the three modes exist only to include or exclude
        -- the Goblin Merchant companion, so on a realm without it the whole
        -- choice collapses to "All Merchants". Hide the row rather than
        -- offer a dropdown where two options are unreachable and one is
        -- named after a pet the player cannot summon.
        --
        -- The stored DB.merchantMode is deliberately NOT rewritten - the
        -- same account may play on a realm that does have the companion,
        -- and silently clobbering their choice there would be worse than
        -- ignoring it here. EC_IsMerchantAllowed applies the same gate at
        -- decision time, so a stored "goblin" cannot strand the player with
        -- a vendor cycle that never sells anything.
        local merchantModeShown = EC_compCache.peFeaturesVisible == nil or EC_compCache.peFeaturesVisible()
        if not merchantModeShown then
            modeLabel:Hide()
            modeDD:Hide()
            if modeHelp then
                modeHelp:Hide()
            end
        end

        -- Quality threshold (v2.4.0+): per-rarity rows with optional max iLvl.
        local thresholdHeader = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        if merchantModeShown then
            thresholdHeader:SetPoint("TOPLEFT", modeLabel, "BOTTOMLEFT", 0, -20)
        else
            thresholdHeader:SetPoint("TOPLEFT", 16, -76)
        end
        thresholdHeader:SetText(L["Quality Threshold"])
        NS.AddHelpIcon(content, thresholdHeader, "LEFT", "RIGHT", 6, 0, "gate-quality-rules")

        local function MakeQualityRow(anchor, qualityIdx, labelText, yOff)
            local cb = NS.AddCheckbox(
                content,
                "EbonClearanceQualityRow" .. qualityIdx .. "CB",
                anchor,
                labelText,
                function()
                    return DB.qualityRules[qualityIdx].enabled
                end,
                function(v)
                    DB.qualityRules[qualityIdx].enabled = v
                    -- Per-rarity rule flip changes EC_IsSellable's
                    -- qualityPass for every slot of this rarity.
                    -- Repaint so slot tints track immediately. Same
                    -- rule as the list-mutation refresh invariant.
                    if NS.RefreshSellBorders then
                        NS.RefreshSellBorders()
                    end
                end,
                yOff
            )

            local input =
                CreateFrame("EditBox", "EbonClearanceQualityRow" .. qualityIdx .. "Input", content, "InputBoxTemplate")
            input:SetSize(50, 20)
            -- Anchored to content's right edge with a small margin. Content's
            -- right edge already sits 26 px inside the panel (scrollbar gutter),
            -- so -6 here matches the original panel-anchored -32 offset visually.
            input:SetPoint("RIGHT", content, "RIGHT", -6, 0)
            input:SetPoint("TOP", cb, "TOP", 0, -2)
            input:SetAutoFocus(false)
            input:SetNumeric(true)
            input:SetMaxLetters(3)
            input:SetText(tostring(DB.qualityRules[qualityIdx].maxILvl or 0))
            NS.StyleInputBox(input)

            local lbl = content:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
            lbl:SetPoint("RIGHT", input, "LEFT", -6, 0)
            lbl:SetText(L["max iLvl:"])

            -- v2.12.0: per-rarity "Use equipped iLvl" tickbox. When checked,
            -- the maxILvl input is ignored at runtime and the cap is the
            -- player's currently-equipped iLvl in the same slot (per-item
            -- via EC_compCache.isDowngradeVsEquipped). The input is visibly
            -- disabled while this is checked so the user understands the
            -- maxILvl number isn't being applied.
            local useEqCB = CreateFrame(
                "CheckButton",
                "EbonClearanceQualityRow" .. qualityIdx .. "UseEqCB",
                content,
                "InterfaceOptionsCheckButtonTemplate"
            )
            useEqCB:SetPoint("RIGHT", lbl, "LEFT", -8, 0)
            useEqCB:SetChecked(DB.qualityRules[qualityIdx].useEquippedILvl == true)
            -- The InterfaceOptionsCheckButtonTemplate auto-creates a label
            -- to the RIGHT of the box; that label would extend rightward
            -- into the "max iLvl:" field on this layout. Blank the
            -- auto-generated label and place a separate FontString to the
            -- LEFT of the box instead so the row reads
            -- "<rarity>  Use equipped iLvl [✓]  max iLvl: [   ]".
            local autoLabel = _G[useEqCB:GetName() .. "Text"]
            if autoLabel then
                autoLabel:SetText("")
            end
            local useEqText = content:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
            useEqText:SetPoint("RIGHT", useEqCB, "LEFT", -2, 0)
            useEqText:SetText(L["Use equipped iLvl"])

            -- Help icons are no-ops after the Help panel cut; bound the
            -- rarity label against the "Use equipped iLvl" text directly.
            local rowLabel = _G[cb:GetName() .. "Text"]
            if rowLabel then
                rowLabel:ClearAllPoints()
                rowLabel:SetPoint("LEFT", cb, "RIGHT", 4, 1)
                rowLabel:SetPoint("RIGHT", useEqText, "LEFT", -4, 0)
                rowLabel:SetJustifyH("LEFT")
                if rowLabel.SetWordWrap then
                    rowLabel:SetWordWrap(false)
                end
                if rowLabel.SetNonSpaceWrap then
                    rowLabel:SetNonSpaceWrap(false)
                end
                if EC_compCache.deregisterWidth then
                    EC_compCache.deregisterWidth(rowLabel)
                end
            end

            useEqCB.tooltipText = L["Use equipped iLvl"]
            useEqCB.tooltipRequirement = L["When checked, the cap for this rarity is your currently-equipped iLvl in the same slot. "]
                .. L["Items below auto-sell. Multi-slot items (rings, trinkets, weapons) compare against the "]
                .. L["worst equipped slot. Empty slots are skipped."]

            local function applyInputEnabled()
                local on = DB.qualityRules[qualityIdx].useEquippedILvl == true
                if on then
                    -- 3.3.5a EditBox doesn't expose Enable/Disable - use
                    -- SetEditable + EnableMouse to actually block input,
                    -- and grey both the field text and the "max iLvl:" label
                    -- so the disabled state is obvious.
                    if input.SetEditable then
                        input:SetEditable(false)
                    end
                    input:EnableMouse(false)
                    if input.HasFocus and input:HasFocus() then
                        input:ClearFocus()
                    end
                    input:SetTextColor(0.5, 0.5, 0.5)
                    if lbl.SetTextColor then
                        lbl:SetTextColor(0.5, 0.5, 0.5)
                    end
                else
                    if input.SetEditable then
                        input:SetEditable(true)
                    end
                    input:EnableMouse(true)
                    input:SetTextColor(1, 1, 1)
                    if lbl.SetTextColor then
                        lbl:SetTextColor(1, 0.82, 0)
                    end
                end
            end
            applyInputEnabled()

            useEqCB:SetScript("OnClick", function(self_)
                DB.qualityRules[qualityIdx].useEquippedILvl = self_:GetChecked() and true or false
                applyInputEnabled()
                PlaySound("igMainMenuOptionCheckBoxOn")
                -- Toggling useEquippedILvl switches the per-rarity
                -- rule between fixed-cap and dynamic-cap modes - same
                -- slot verdict can flip either direction. Repaint so
                -- tints track.
                if NS.RefreshSellBorders then
                    NS.RefreshSellBorders()
                end
            end)
            cb._applyInputEnabled = applyInputEnabled

            local function commit()
                local v = tonumber(input:GetText() or "0") or 0
                if v < 0 then
                    v = 0
                end
                if v > 300 then
                    v = 300
                end
                DB.qualityRules[qualityIdx].maxILvl = v
                input:SetText(tostring(v))
                -- Cap change flips qualityPass for every slot at the
                -- threshold; repaint so tints track. Note: this fires
                -- on every focus-lost (every commit), which is the
                -- right granularity - per-keystroke firing would be
                -- wasted work.
                if NS.RefreshSellBorders then
                    NS.RefreshSellBorders()
                end
            end
            input:SetScript("OnEnterPressed", function()
                input:ClearFocus()
            end)
            input:SetScript("OnEscapePressed", function()
                input:SetText(tostring(DB.qualityRules[qualityIdx].maxILvl or 0))
                input:ClearFocus()
            end)
            input:SetScript("OnEditFocusLost", commit)

            return cb, input, useEqCB
        end

        local row1CB, row1Input, row1UseEq =
            MakeQualityRow(thresholdHeader, 1, EC_WHITELIST_QUALITIES[1].text, -16)
        local row2CB, row2Input, row2UseEq =
            MakeQualityRow(thresholdHeader, 2, EC_WHITELIST_QUALITIES[2].text, -50)
        local row3CB, row3Input, row3UseEq =
            MakeQualityRow(thresholdHeader, 3, EC_WHITELIST_QUALITIES[3].text, -84)
        local row4CB, row4Input, row4UseEq =
            MakeQualityRow(thresholdHeader, 4, EC_WHITELIST_QUALITIES[4].text, -118)

        self.qualityRow1CB, self.qualityRow1Input, self.qualityRow1UseEq = row1CB, row1Input, row1UseEq
        self.qualityRow2CB, self.qualityRow2Input, self.qualityRow2UseEq = row2CB, row2Input, row2UseEq
        self.qualityRow3CB, self.qualityRow3Input, self.qualityRow3UseEq = row3CB, row3Input, row3UseEq
        self.qualityRow4CB, self.qualityRow4Input, self.qualityRow4UseEq = row4CB, row4Input, row4UseEq

        NS.FitScrollContent(content, row4CB)
    end, true)
end)
