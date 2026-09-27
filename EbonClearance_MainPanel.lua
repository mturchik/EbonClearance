-- EbonClearance_MainPanel - main "EbonClearance" Interface Options panel.
-- Author:  Serv
-- Source:  https://github.com/powerfulqa/EbonClearance
-- License: see LICENSE; attribution preservation is required.
--
-- Stage 8e-ix-a of the multi-stage file split (docs/CODE_REVIEW.md item 4).
-- The top-level "EbonClearance" panel - the entry point users hit
-- first when opening Interface Options. Hosts the welcome blurb,
-- Enable + minimap toggles, the LICENSE byline, and the Alt+Right-Click tip.
-- Personal Stats (RefreshStats / ResetLifetimeStats) and Help deep-links
-- were removed in the settings cut (docs/SCOPE_CUT.md).
--
-- Moved into this file:
--   * local MainOptions = CreateFrame(...) frame creation
--   * BuildMainPanel function (builds the panel body)
--   * The MainOptions OnShow handler which drives BuildMainPanel through
--     EC_compCache.initPanel
--
-- The panel-infrastructure helpers (EC_PANEL_WIDTH, initPanel,
-- registerWidth, setPanelWidth, etc.) live in
-- EbonClearance_PanelInfra.lua, and the widget primitives (MakeHeader,
-- MakeLabel, AddCheckbox, AddSlider) in EbonClearance_PanelWidgets.lua;
-- both are exposed on NS and shared across every panel.
--
-- Cross-file dependencies satisfied by NS:
--   * NS.compCache (Core) - initPanel, setPanelWidth
--   * NS.DB / NS.ADB captured at OnShow + BuildMainPanel entry
--   * NS.MakeHeader / NS.MakeLabel (8e-i)
--   * NS.FitScrollContent (8e-ii)
--   * NS.GetVersion (Stage 8 era)

local NS = select(2, ...)
local EC_compCache = NS.compCache
local L = NS.L

local MainOptions = CreateFrame("Frame", "EbonClearanceOptionsMain", InterfaceOptionsFramePanelContainer)
MainOptions.name = "EbonClearance"

local function BuildMainPanel(panel, content)
    -- v2.12.0: widgets are created on `content` (the scroll-frame child)
    -- so vertical overflow is handled by the scroll bar.
    -- The `panel` arg is unused for layout but kept in the signature because
    -- EC_compCache.initPanel passes it (and enableCB is hung on it for refresh).
    local addonVersion = NS.GetVersion()
    NS.MakeHeader(content, "EbonClearance " .. addonVersion, -16)

    -- Byline (required by LICENSE; do not remove in derivatives).
    local byline = content:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    byline:SetPoint("TOPLEFT", 16, -32)
    byline:SetText("|cff888866by " .. NS.ADDON_AUTHOR .. "  \194\183  " .. NS.ADDON_URL .. "|r")

    -- v2.76.0 (Serv report): the "Welcome to EbonClearance - bag management
    -- for Project Ebonhold" line is gone. It named PE unconditionally, so on
    -- a plain 3.3.5a realm (where v2.74.0 hides the PE-only settings) the
    -- very first line still claimed to be a Project Ebonhold addon. Rather
    -- than branch the greeting on peFeaturesActive(), the line is dropped
    -- entirely - it only restated the panel heading and the byline above it,
    -- so the description now opens the panel and reads correctly everywhere.
    local descLabel2 = content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    descLabel2:SetPoint("TOPLEFT", 16, -52)
    EC_compCache.setPanelWidth(descLabel2, 16)
    descLabel2:SetJustifyH("LEFT")
    descLabel2:SetJustifyV("TOP")
    if descLabel2.SetWordWrap then
        descLabel2:SetWordWrap(true)
    end
    descLabel2:SetText(
        L["Out of the box it sells your junk and old gear when you visit a merchant, keeps your upgrades, and never touches anything important.\n\n"]
            .. L["Want more control?\n"]
            .. L["  |cffb6ffb6Sell List|r - items you want sold every time.\n"]
            .. L["  |cffb6ffb6Keep List|r - items the addon should never touch.\n"]
            .. L["  |cffb6ffb6Merchant Settings|r - change what counts as old gear.\n"]
            .. L["  |cffb6ffb6Scavenger Settings|r - the companion loot and sell cycle."]
    )

    -- Master Enable toggle. Gates the sell engine, scavenger, and auto-loot.
    local enableCB = NS.AddCheckbox(
        content,
        "EbonClearanceMainEnableCB",
        descLabel2,
        L["Enable EbonClearance"],
        function()
            return NS.DB and NS.DB.enabled ~= false
        end,
        function(v)
            local newState = v and true or false
            local curr = (NS.DB and NS.DB.enabled ~= false) and true or false
            if curr ~= newState and EbonClearance_ToggleEnabled then
                EbonClearance_ToggleEnabled()
            end
        end,
        -14
    )
    panel.enableCB = enableCB

    -- Minimap button show/hide. Right-click on the button toggles Enable
    -- without opening options or typing a command.
    local minimapButtonCB = NS.AddCheckbox(
        content,
        "EbonClearanceMinimapButtonCB",
        enableCB,
        L["Show the EbonClearance minimap button"],
        function()
            return NS.DB and NS.DB.minimapButton ~= false
        end,
        function(v)
            if NS.SetMinimapButtonVisible then
                NS.SetMinimapButtonVisible(v)
            elseif NS.DB then
                NS.DB.minimapButton = v and true or false
            end
        end,
        -8
    )

    -- Tip. Settings cut removed Quickstart, Current Rules, Sold History,
    -- Loot Log, update alert, conflict warning, and the slash catalog
    -- (docs/SCOPE_CUT.md). Minimap button stays.
    local mainTip = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    mainTip:SetPoint("TOPLEFT", minimapButtonCB, "BOTTOMLEFT", 0, -14)
    EC_compCache.setPanelWidth(mainTip, 16)
    mainTip:SetJustifyH("LEFT")
    mainTip:SetJustifyV("TOP")
    if mainTip.SetWordWrap then
        mainTip:SetWordWrap(true)
    end
    mainTip:SetText(
        L["|cff888888Right-click any bag item with Alt held for quick actions. Right-click the minimap button to turn the addon on or off.|r"]
    )

    NS.FitScrollContent(content, mainTip)
end

MainOptions:SetScript("OnShow", function(self)
    EC_compCache.initPanel(self, function(refreshSelf)
        if refreshSelf.enableCB then
            refreshSelf.enableCB:SetChecked(NS.DB and NS.DB.enabled ~= false)
        end
    end, function(buildSelf, content)
        BuildMainPanel(buildSelf, content)
    end, true)
end)
