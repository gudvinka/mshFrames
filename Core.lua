local addonName, ns = ...


local msh = LibStub("AceAddon-3.0"):NewAddon(ns, addonName, "AceEvent-3.0")


function msh.ApplyStyle(frame)
    if not frame or frame:IsForbidden() then return end
    if not msh.db or not msh.db.profile then return end

    local frameName = frame:GetName() or ""

    -- 2. Фильтруем только нужные фреймы (Рейд или Группа)
    local isRaid = frameName:find("CompactRaid")
    local isParty = frameName:find("CompactParty")

    if not (isRaid or isParty) or frameName:find("Pet") then
        return
    end

    -- 3. ДИНАМИЧЕСКОЕ ПЕРЕКЛЮЧЕНИЕ КОНФИГА

    if isRaid then
        ns.cfg = msh.db.profile.raid
    elseif isParty then
        ns.cfg = msh.db.profile.party
    end


    if msh.CreateUnitLayers then msh.CreateUnitLayers(frame) end
    if msh.UpdateUnitDisplay then msh.UpdateUnitDisplay(frame) end
    if msh.UpdateHealthDisplay then msh.UpdateHealthDisplay(frame) end
    if msh.UpdateAuras then msh.UpdateAuras(frame) end
end

-- Основные хуки Blizzard
hooksecurefunc("CompactUnitFrame_UpdateAll", msh.ApplyStyle)
hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
    if frame.mshLayersCreated then msh.UpdateUnitDisplay(frame) end
end)
hooksecurefunc("CompactUnitFrame_UpdateStatusText", function(frame)
    if frame.mshLayersCreated then msh.UpdateHealthDisplay(frame) end
end)
hooksecurefunc("CompactUnitFrame_UpdateAuras", function(frame)
    if frame.mshLayersCreated then msh.UpdateAuras(frame) end
end)

-- Регистрация событий
function msh:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD", function()
        if msh.SyncBlizzardSettings then msh.SyncBlizzardSettings() end
    end)

    self:RegisterEvent("RAID_TARGET_UPDATE", function()
        for i = 1, 40 do
            local raidFrame = _G["CompactRaidFrame" .. i]
            if raidFrame and raidFrame.mshLayersCreated then msh.UpdateUnitDisplay(raidFrame) end

            local partyFrame = _G["CompactPartyFrameMember" .. i]
            if partyFrame and partyFrame.mshLayersCreated then msh.UpdateUnitDisplay(partyFrame) end
        end
    end)

    self:RegisterEvent("GROUP_ROSTER_UPDATE", function()
        C_Timer.After(0.1, function()
            for i = 1, 40 do
                local rf = _G["CompactRaidFrame" .. i]
                if rf and rf:IsShown() then
                    msh.ApplyStyle(rf)
                end

                local pf = _G["CompactPartyFrameMember" .. i]
                if pf and pf:IsShown() then
                    msh.ApplyStyle(pf)
                end
            end
        end)
    end)
end
