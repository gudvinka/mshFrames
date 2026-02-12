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

function msh:Refresh(full)
    if full then
        self:RefreshConfig()
        return
    end

    -- В обычном случае (msh:Refresh()) просто быстро обновляем визуал
    for i = 1, 40 do
        local rf = _G["CompactRaidFrame" .. i]
        if rf and rf:IsShown() and rf.mshLayersCreated then
            msh.ApplyStyle(rf)
        end

        local pf = _G["CompactPartyFrameMember" .. i]
        if pf and pf:IsShown() and pf.mshLayersCreated then
            msh.ApplyStyle(pf)
        end
    end
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
        -- Даем Blizzard 0.1 сек, чтобы обновить переменные юнитов (кто в какой группе)
        C_Timer.After(0.1, function()
            for i = 1, 40 do
                -- Проверяем рейдовые фреймы
                local rf = _G["CompactRaidFrame" .. i]
                if rf and rf:IsShown() and rf.mshLayersCreated then
                    -- Если фрейм уже существует, обновляем только данные (имя, метку, роль)
                    msh.UpdateUnitDisplay(rf)
                    msh.UpdateHealthDisplay(rf)
                    if msh.UpdateAuras then msh.UpdateAuras(rf) end
                elseif rf and rf:IsShown() then
                    -- Если фрейм только что появился и слоев нет — инициализируем полностью
                    msh.ApplyStyle(rf)
                end

                -- Проверяем пати фреймы
                local pf = _G["CompactPartyFrameMember" .. i]
                if pf and pf:IsShown() and pf.mshLayersCreated then
                    msh.UpdateUnitDisplay(pf)
                    msh.UpdateHealthDisplay(pf)
                    if msh.UpdateAuras then msh.UpdateAuras(pf) end
                elseif pf and pf:IsShown() then
                    msh.ApplyStyle(pf)
                end
            end

            -- Синхронизируем настройки (скрытие заголовков групп и т.д.)
            -- Вызываем ОДИН раз вместо двух
            if msh.SyncBlizzardSettings then
                msh.SyncBlizzardSettings()
            end
        end)
    end)

    self:RegisterEvent("RAID_TARGET_UPDATE", function()
        -- Это событие говорит: "Метки в рейде изменились!"
        -- Мы принудительно обновляем все видимые фреймы
        for i = 1, 40 do
            local rf = _G["CompactRaidFrame" .. i]
            if rf and rf:IsShown() and rf.mshLayersCreated then
                msh.UpdateUnitDisplay(rf)
            end

            local pf = _G["CompactPartyFrameMember" .. i]
            if pf and pf:IsShown() and pf.mshLayersCreated then
                msh.UpdateUnitDisplay(pf)
            end
        end
    end)
end
