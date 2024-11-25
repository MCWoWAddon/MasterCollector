MC.mainFrame:EnableMouse(true)
MC.mainFrame:SetResizable(true)
MC.mainFrame:SetMovable(true)
MC.mainFrame:RegisterForDrag("LeftButton")
MC.mainFrame:SetScript("OnDragStart", MC.mainFrame.StartMoving)
MC.mainFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
    MasterCollectorSV.framePosition = {
        point = point,
        relativePoint = relativePoint,
        x = xOfs,
        y = yOfs
    }
end)
MC.mainFrame:SetScript("OnHide", MC.mainFrame.StopMovingOrSizing)
MC.mainFrame:SetClampedToScreen(true)

function MC.UpdateMainFrameSize()
    local tabCount = 0
    local tabsList = { MC.weeklyTab, MC.dailyTab, MC.dailyrepTab, MC.grindMountsTab, MC.eventTab }
    
    for _, tab in ipairs(tabsList) do
        if tab:IsVisible() then
            tabCount = tabCount + 1
        end
    end
    
    local baseWidth = 200
    local dynamicWidth = baseWidth + (tabCount * 50)

    if MC.mainFrame:GetWidth() < dynamicWidth then
        dynamicWidth = math.min(dynamicWidth, UIParent:GetWidth())
        MC.mainFrame:SetWidth(dynamicWidth)
    end
    
    if not MasterCollectorSV.baseHeight then
        MasterCollectorSV.baseHeight = 200
    end

    local dynamicHeight = math.min(MasterCollectorSV.baseHeight, UIParent:GetHeight())
    MC.mainFrame:SetResizeBounds(dynamicWidth, dynamicHeight, UIParent:GetWidth(), UIParent:GetHeight())
end

MC.frameScroll = CreateFrame("ScrollFrame", "MC.frameScroll", MC.mainFrame, "UIPanelScrollFrameTemplate")
MC.frameScroll:SetPoint("TOPLEFT", MC.mainFrame, "TOPLEFT", 3, -40)
MC.frameScroll:SetPoint("BOTTOMRIGHT", MC.mainFrame, "BOTTOMRIGHT", -27, 10)

MC.frameChild = CreateFrame("Frame", "MC.frameChild", MC.frameScroll)
MC.frameChild:SetWidth(MC.mainFrame:GetWidth() - 18)
MC.frameChild:SetPoint("TOPLEFT")
MC.frameChild:SetPoint("BOTTOMRIGHT")
MC.frameScroll:SetScrollChild(MC.frameChild)

MC.mainFrame.text = MC.frameChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
MC.mainFrame.text:SetPoint("TOPLEFT", MC.frameChild, "TOPLEFT", 10, -10)
MC.mainFrame.text:SetWidth(MC.frameChild:GetWidth() - 20)
MC.mainFrame.text:SetJustifyH("LEFT")

function MC.InitializeFramePosition()
    if MasterCollectorSV.framePosition then
        local pos = MasterCollectorSV.framePosition
        MC.mainFrame:ClearAllPoints()
        MC.mainFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y)
    else
        MC.mainFrame:SetPoint("CENTER", UIParent, "CENTER")
    end
end

function MC.CheckFrameVisibility()
    if MasterCollectorSV.frameVisible then
        MC.mainFrame:Show()
    else
        MC.mainFrame:Hide()
    end
end

function MC.UpdateFrameHeight()
    local textHeight = MC.mainFrame.text:GetStringHeight()
    local padding = 40
    MC.frameChild:SetHeight(textHeight + padding)
end

function MC.UpdateTextWrapping()
    if MC.mainFrame.text then
        MC.mainFrame.text:SetWidth(MC.mainFrame:GetWidth() - 20)
    end
end

MC.mainFrame:SetScript("OnSizeChanged", MC.UpdateTextWrapping)

local minimapRadius = 105
function MC.CreateMinimapButton()
    if MasterCollectorSV.hideMinimapButton then
        if MC.minimapButton then
            MC.minimapButton:Hide()
        end
        return
    end
    if not MC.minimapButton then
        local minimapButton = CreateFrame("Button", "MasterCollectorMinimapButton", Minimap)
        minimapButton:SetSize(24, 24)
        minimapButton:SetFrameStrata("MEDIUM")
        minimapButton:SetFrameLevel(8)
        minimapButton:EnableMouse(true)
        minimapButton.icon = minimapButton:CreateTexture(nil, "BACKGROUND")
        minimapButton.icon:SetAllPoints()
        minimapButton.icon:SetTexture("Interface\\ICONS\\70_professions_scroll_03")
        minimapButton.icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask")
        minimapButton:SetPoint("CENTER", Minimap, "CENTER", minimapRadius, 0)
        minimapButton:SetScript("OnClick", function()
            if MC.mainFrame:IsVisible() then
                MC.mainFrame:Hide()
                MasterCollectorSV.frameVisible = false
            else
                MC.mainFrame:Show()
                MasterCollectorSV.frameVisible = true
                if MasterCollectorSV.lastActiveTab == "Event\nGrinds" then
                    MC.RefreshMCEvents()
                end
            end
        end)
        minimapButton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
            GameTooltip:SetText("Master Collector", 1, 1, 1)
            GameTooltip:AddLine("Click to toggle Master Collector frame", nil, nil, nil, true)
            GameTooltip:Show()
        end)

        minimapButton:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        -- Drag functionality
        minimapButton:RegisterForDrag("LeftButton")
        minimapButton:SetScript("OnDragStart", function(self)
            self.isDragging = true
        end)

        minimapButton:SetScript("OnDragStop", function(self)
            self.isDragging = false
        end)

        minimapButton:SetScript("OnUpdate", function(self)
            if self.isDragging then
                local mx, my = Minimap:GetCenter()
                local cx, cy = GetCursorPosition()
                local scale = UIParent:GetScale()
                cx, cy = cx / scale, cy / scale

                local angle = math.atan2(cy - my, cx - mx)
                MasterCollectorSV.minimapButtonAngle = angle

                local x = math.cos(angle) * minimapRadius
                local y = math.sin(angle) * minimapRadius
                self:SetPoint("CENTER", Minimap, "CENTER", x, y)
            end
        end)

        if MasterCollectorSV.minimapButtonAngle then
            local angle = MasterCollectorSV.minimapButtonAngle
            local x = math.cos(angle) * minimapRadius
            local y = math.sin(angle) * minimapRadius
            minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
        end

        MC.minimapButton = minimapButton
    end
    if not MasterCollectorSV.hideMinimapButton and MC.minimapButton then
        MC.minimapButton:Show()
    end
end

local lockButton = CreateFrame("Button", nil, MC.mainFrame)
lockButton:SetSize(48, 48)
lockButton:SetPoint("TOPLEFT", MC.mainFrame, "TOPLEFT")

local resizeHandle = CreateFrame("Button", "random", MC.mainFrame)
resizeHandle:SetSize(24, 24)
resizeHandle:SetFrameStrata("MEDIUM")
resizeHandle:SetPoint("BOTTOMRIGHT")

resizeHandle:EnableMouse(true)
resizeHandle:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
resizeHandle:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
resizeHandle:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")

resizeHandle:SetScript("OnMouseDown", function(self, button)
    MC.mainFrame:StartSizing("BOTTOMRIGHT")
end)
resizeHandle:SetScript("OnMouseUp", function(self, button)
    MC.mainFrame:StopMovingOrSizing()
    MC.UpdateTextWrapping()
end)

local function UpdateResizeHandleVisibility()
    if MasterCollectorSV.islocked then
        resizeHandle:Hide()
    else
        resizeHandle:Show()
    end
end

local function ToggleLock()
    MasterCollectorSV.islocked = not MasterCollectorSV.islocked
    if MasterCollectorSV.islocked then
        MC.mainFrame:EnableMouse(false)
        MC.mainFrame:SetMovable(false)
        lockButton:SetNormalTexture("Interface\\BUTTONS\\LockButton-Locked-Up")
    else
        MC.mainFrame:EnableMouse(true)
        MC.mainFrame:SetMovable(true)
        lockButton:SetNormalTexture("Interface\\BUTTONS\\LockButton-Unlocked-Up")
    end
    UpdateResizeHandleVisibility()
end

function MC.InitializeLockState()
    if MasterCollectorSV.islocked then
        MC.mainFrame:EnableMouse(false)
        MC.mainFrame:SetMovable(false)
        lockButton:SetNormalTexture("Interface\\BUTTONS\\LockButton-Locked-Up")
    else
        MC.mainFrame:EnableMouse(true)
        MC.mainFrame:SetMovable(true)
        lockButton:SetNormalTexture("Interface\\BUTTONS\\LockButton-Unlocked-Up")
    end
    UpdateResizeHandleVisibility()
end

lockButton:SetScript("OnClick", ToggleLock)

-- Tab Setup
local previousVisibleTab = nil
local tabs = CreateFrame("Frame", "MasterCollectorTabs", MC.mainFrame)
tabs:SetPoint("BOTTOMLEFT", MC.mainFrame, "BOTTOMLEFT", 0, -55)
tabs:SetSize(300, 60)

local function CreateTabButton(text, index, variable)
    local button = CreateFrame("Button", "MasterCollectorTabButton" .. index, tabs)
    button:SetSize(100, 50)
    button:SetText(text)

    local buttonText = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    buttonText:SetText(text)
    buttonText:SetPoint("TOP", button, "TOP", 0, -5)
    
    button:SetFontString(buttonText)
    button:SetNormalFontObject("GameFontHighlight")
    button:SetHighlightFontObject("GameFontHighlight")
    button:SetNormalTexture("Interface\\PaperDollInfoFrame\\UI-Character-InActiveTab")
    button:SetHighlightTexture("Interface\\PaperDollInfoFrame\\UI-Character-ActiveTab")
    
    button:SetScript("OnClick", function(self)
        MC.SetActiveTab(self)
    end)
    button:SetID(index)

    if MasterCollectorSV[variable] then
        if not previousVisibleTab then
            button:SetPoint("TOPLEFT", tabs, "TOPLEFT", 0, 0)
        else
            button:SetPoint("TOPLEFT", previousVisibleTab, "TOPRIGHT", -16, 0)
        end
        previousVisibleTab = button
        button:Show()
    else
        button:Hide()
    end
    return button
end

MC.weeklyTab = CreateTabButton("Weekly\nLockouts", 1, "showWeeklyTab")
MC.dailyTab = CreateTabButton("Daily\nLockouts", 2, "showDailyTab")
MC.dailyrepTab = CreateTabButton("Daily Rep\nGrinds", 3, "showDailyRepTab")
MC.grindMountsTab = CreateTabButton("Anytime\nGrinds", 4, "showAnytimeGrindsTab")
MC.eventTab = CreateTabButton("Event\nGrinds", 5, "showEventTab")

function MC.UpdateTabPositions()
    local previousVisibleTab = nil
    local tabsList = {
        MC.weeklyTab,
        MC.dailyTab,
        MC.dailyrepTab,
        MC.grindMountsTab,
        MC.eventTab
    }

    for _, tab in ipairs(tabsList) do
        if tab:IsShown() then
            if not previousVisibleTab then
                tab:SetPoint("TOPLEFT", tabs, "TOPLEFT", 0, 0)
            else
                tab:SetPoint("TOPLEFT", previousVisibleTab, "TOPRIGHT", -16, 0)
            end
            previousVisibleTab = tab
        end
    end
end

function MC.UpdateTabVisibility()
    local tabsList = {
        { tab = MC.weeklyTab, variable = "hideWeeklyTab" },
        { tab = MC.dailyTab, variable = "hideDailyTab" },
        { tab = MC.dailyrepTab, variable = "hideDailyRepTab" },
        { tab = MC.grindMountsTab, variable = "hideGrindMountsTab" },
        { tab = MC.eventTab, variable = "hideEventTab" }
    }

    for _, tabInfo in ipairs(tabsList) do
        local tab = tabInfo.tab
        local variable = tabInfo.variable

        if MasterCollectorSV[variable] then
            tab:Hide()
        else
            tab:Show()
        end
    end
    MC.UpdateTabPositions() 
    MC.UpdateMainFrameSize() 
end

function MC.SetActiveTab(selectedButton)
    local tabID = selectedButton and selectedButton:GetID() or nil

    if not tabID then
        if MasterCollectorSV.lastActiveTab == "Weekly\nLockouts" then
            tabID = 1
        elseif MasterCollectorSV.lastActiveTab == "Daily\nLockouts" then
            tabID = 2
        elseif MasterCollectorSV.lastActiveTab == "Daily Rep\nGrinds" then
            tabID = 3
        elseif MasterCollectorSV.lastActiveTab == "Anytime\nGrinds" then
            tabID = 4
        elseif MasterCollectorSV.lastActiveTab == "Event\nGrinds" then
            tabID = 5
        end
        selectedButton = _G["MasterCollectorTabButton" .. tabID]
    end

    for i = 1, 5 do
        local button = _G["MasterCollectorTabButton" .. i]
        if button then
            button:SetSize(100, 50)
            button:SetNormalTexture("Interface\\PaperDollInfoFrame\\UI-Character-InActiveTab")
        end
    end

    if selectedButton then
        selectedButton:SetSize(100, 75)
        selectedButton:SetNormalTexture("Interface\\PaperDollInfoFrame\\UI-Character-ActiveTab")
    end

    local tabNames = {
        [1] = { title = "Weekly Lockouts", key = "Weekly\nLockouts", displayFunc = function() 
            C_Timer.After(0.1, function()
                MC.weeklyDisplay()
            end)
        end },
        [2] = { title = "Daily Lockouts", key = "Daily\nLockouts", displayFunc = MC.dailiesDisplay },
        [3] = { title = "Daily Grind Reputation Tracker", key = "Daily Rep\nGrinds", displayFunc = MC.repsDisplay },
        [4] = { title = "Grind When You Have Time", key = "Anytime\nGrinds", displayFunc = function() MC.mainFrame.text:SetText("Coming Soon!") end },
        [5] = { title = "Limited Time - Event Mounts", key = "Event\nGrinds", displayFunc = MC.events }
    }

    local selectedTab = tabNames[tabID]
    if selectedTab then
        MC.txtFrameTitle:SetText(selectedTab.title)
        MC.currentTab = selectedTab.key
        MasterCollectorSV.lastActiveTab = selectedTab.key
        selectedTab.displayFunc()
    end

    MC.UpdateFrameHeight()
end

MC.optionsButton = CreateFrame("Button", nil, MC.mainFrame)
MC.optionsButton:SetSize(24, 24)
MC.optionsButton:SetPoint("TOPRIGHT", MC.mainFrame, "TOPRIGHT", -10, -10)
MC.optionsButton:SetNormalTexture("Interface\\BUTTONS\\UI-OptionsButton")
MC.optionsButton:SetPushedTexture("Interface\\BUTTONS\\UI-OptionsButton-Down")
MC.optionsButton:SetHighlightTexture("Interface\\BUTTONS\\UI-OptionsButton-Highlight")

local function OnCommandButtonClick()
    Settings.OpenToCategory(MC.mainOptionsCategory:GetID())
end

MC.optionsButton:SetScript("OnClick", OnCommandButtonClick)