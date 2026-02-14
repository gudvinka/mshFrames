local addonName, ns = ...


local msh = LibStub("AceAddon-3.0"):NewAddon(ns, addonName, "AceEvent-3.0")

function msh.GetConfigForFrame(frame)
    if not frame or frame:IsForbidden() then return nil end

    local name = frame:GetName() or ""

    -- Фильтр: только рейд и пати фреймы
    if name:find("CompactRaidGroup") or name:find("CompactRaidFrame") then
        return msh.db.profile.raid
    elseif name:find("CompactParty") then
        return msh.db.profile.party
    end

    return nil
end

function msh.ApplyStyle(frame)
    if not frame or frame:IsForbidden() then return end

    local cfg = msh.GetConfigForFrame(frame)
    if not cfg then return end


    -- Передаем конфиг в ns для совместимости
    ns.cfg = cfg

    -- Создаем слои, если их нет
    if msh.CreateUnitLayers then msh.CreateUnitLayers(frame) end
    if msh.CreateHealthLayers then msh.CreateHealthLayers(frame) end

    -- Принудительно обновляем содержимое после стилизации
    msh.UpdateUnitDisplay(frame)
    msh.UpdateHealthDisplay(frame)
    if msh.UpdateAuras then msh.UpdateAuras(frame) end
end

-- Хук на обновление здоровья
hooksecurefunc("CompactUnitFrame_UpdateHealth", function(frame)
    local cfg = msh.GetConfigForFrame(frame)
    if cfg and frame.mshHealthCreated then
        ns.cfg = cfg
        msh.UpdateHealthDisplay(frame)
    end
end)

-- Хук на обновление имени и статуса
hooksecurefunc("CompactUnitFrame_UpdateStatusText", function(frame)
    local cfg = msh.GetConfigForFrame(frame)
    if cfg and frame.mshLayersCreated then
        ns.cfg = cfg
        msh.UpdateUnitDisplay(frame)
    end
end)

-- Хук на обновление аур
hooksecurefunc("CompactUnitFrame_UpdateAuras", function(frame)
    if frame.mshLayersCreated and msh.UpdateAuras then
        -- ns.cfg = msh.GetConfigForFrame(frame)
        msh.UpdateAuras(frame)
    end
end)

-- Хук на инициализацию фрейма (когда он впервые создается игрой)
hooksecurefunc("CompactUnitFrame_SetUpFrame", function(frame)
    msh.ApplyStyle(frame)
end)



hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
    local cfg = msh.GetConfigForFrame(frame)
    if cfg and frame.mshLayersCreated then
        ns.cfg = cfg
        msh.UpdateUnitDisplay(frame)
    end
end)

function msh:Refresh(full)
    if full then
        self:RefreshConfig()
        return
    end

    for i = 1, 5 do
        local pf = _G["CompactPartyFrameMember" .. i]
        if pf then msh.ApplyStyle(pf) end
    end

    -- Обновляем Рейд (Список)
    for i = 1, 40 do
        local rf = _G["CompactRaidFrame" .. i]
        if rf then msh.ApplyStyle(rf) end
    end

    -- Обновляем Рейд (Группы) - ТВОЙ ФИКС
    for g = 1, 8 do
        for m = 1, 5 do
            local rfg = _G["CompactRaidGroup" .. g .. "Member" .. m]
            if rfg then msh.ApplyStyle(rfg) end
        end
    end

    if msh.SyncBlizzardSettings then msh.SyncBlizzardSettings() end
end

function msh:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD", function()
        if msh.SyncBlizzardSettings then msh.SyncBlizzardSettings() end
    end)

    if _G.EditMode and _G.EditMode.Exit then
        hooksecurefunc(_G.EditMode, "Exit", function() msh:Refresh() end)
    end

    -- Хукаем финальное обновление макета
    if _G.EditModeManagerFrame and _G.EditModeManagerFrame.UpdateLayoutInfo then
        hooksecurefunc(_G.EditModeManagerFrame, "UpdateLayoutInfo", function() msh:Refresh() end)
    end

    self:RegisterEvent("GROUP_ROSTER_UPDATE", function()
        C_Timer.After(0.1, function()
            msh:Refresh()
        end)
    end)

    self:RegisterEvent("RAID_TARGET_UPDATE", function()
        -- Обновляем группу (5 человек)
        for i = 1, 5 do
            local pf = _G["CompactPartyFrameMember" .. i]
            if pf and pf:IsShown() and pf.mshLayersCreated then
                msh.UpdateUnitDisplay(pf)
            end
        end

        -- Обновляем рейд списком
        for i = 1, 40 do
            local rf = _G["CompactRaidFrame" .. i]
            if rf and rf:IsShown() and rf.mshLayersCreated then
                msh.UpdateUnitDisplay(rf)
            end
        end

        -- Обновляем рейд по группам
        for g = 1, 8 do
            for m = 1, 5 do
                local rfg = _G["CompactRaidGroup" .. g .. "Member" .. m]
                if rfg and rfg:IsShown() and rfg.mshLayersCreated then
                    msh.UpdateUnitDisplay(rfg)
                end
            end
        end
    end)
end
