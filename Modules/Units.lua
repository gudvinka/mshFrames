local _, ns = ...
local msh = ns
local LSM = LibStub("LibSharedMedia-3.0")

function msh.CreateUnitLayers(frame)
    if frame.mshLayersCreated then return end

    frame.mshName = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    if frame.name then frame.name:SetAlpha(0) end

    frame.mshRole = frame:CreateTexture(nil, "OVERLAY", nil, 7)
    frame.mshRaidIcon = frame:CreateTexture(nil, "OVERLAY", nil, 7)
    frame.mshLeader = frame:CreateTexture(nil, "OVERLAY", nil, 7)
    if frame.leaderIcon then frame.leaderIcon:SetAlpha(0) end

    frame.mshLayersCreated = true
end

function msh.UpdateUnitDisplay(frame)
    if not frame or frame:IsForbidden() then return end

    local unit = frame.displayedUnit or frame.unit
    if not unit or not UnitExists(unit) then return end

    local cfg = ns.cfg
    if not cfg then return end

    -- Имя
    local currentRawName = GetUnitName(unit, false)
    local unitGUID = UnitGUID(unit)

    -- ФИКС ДЛЯ МК
    if not currentRawName or not unitGUID or type(currentRawName) == "userdata" or type(unitGUID) == "userdata" then
        return
    end

    -- Теперь склейка cacheKey безопасна
    local cacheKey = currentRawName .. unitGUID .. (cfg.nameLength or "10") .. tostring(cfg.shortenNames)

    if frame.mshCachedKey ~= cacheKey then
        local name = msh.GetShortName(unit)
        frame.mshName:SetText(name)
        frame.mshCachedKey = cacheKey
    end
    frame.mshName:ClearAllPoints()
    frame.mshName:SetPoint(cfg.namePoint or "CENTER", frame, cfg.nameX or 0, cfg.nameY or 0)

    -- УСТАНОВКА ШРИФТА
    local globalFont = msh.db.profile.global.globalFontName
    local localFont  = cfg.fontName
    local activeFont

    if localFont and localFont ~= "Default" and localFont ~= "" then
        activeFont = localFont
    else
        -- Иначе берем глобальный шрифт
        activeFont = (globalFont and globalFont ~= "") and globalFont or "Montserrat-SemiBold"
    end

    local fontPath    = LSM:Fetch("font", activeFont)
    local fontSize    = cfg.fontSizeName or 12
    local fontOutline = cfg.nameOutline or "OUTLINE"

    frame.mshName:SetFont(fontPath, fontSize, fontOutline)

    if frame.name then frame.name:SetAlpha(0) end


    -- РОЛЬ
    local role = UnitGroupRolesAssigned(unit)

    if cfg.useBlizzRole then
        if frame.mshRole then frame.mshRole:Hide() end

        if frame.roleIcon then
            frame.roleIcon:SetAlpha(1)
            frame.roleIcon:Show()
            CompactUnitFrame_UpdateRoleIcon(frame)
        end
    else
        if frame.roleIcon then
            frame.roleIcon:Hide()
            frame.roleIcon:SetAlpha(0)
        end

        local shouldShowCustom = false
        if cfg.showCustomRoleIcon then
            if role == "TANK" and cfg.showRoleTank then
                shouldShowCustom = true
            elseif role == "HEALER" and cfg.showRoleHeal then
                shouldShowCustom = true
            elseif role == "DAMAGER" and cfg.showRoleDamager then
                shouldShowCustom = true
            end
        end

        -- Отрисовка нашей иконки
        if shouldShowCustom and role and role ~= "NONE" then
            if frame.mshRole then
                frame.mshRole:SetTexture([[Interface\LFGFrame\UI-LFG-ICON-PORTRAITROLES]])
                local size = cfg.roleIconSize or 12
                frame.mshRole:SetSize(size, size)
                frame.mshRole:ClearAllPoints()
                frame.mshRole:SetPoint(cfg.roleIconPoint or "TOPLEFT", frame, cfg.roleIconX or 2, cfg.roleIconY or -2)

                -- Установка координат текстуры (Танк, Хил, ДД)
                if role == "TANK" then
                    frame.mshRole:SetTexCoord(0, 19 / 64, 22 / 64, 41 / 64)
                elseif role == "HEALER" then
                    frame.mshRole:SetTexCoord(20 / 64, 39 / 64, 1 / 64, 20 / 64)
                elseif role == "DAMAGER" then
                    frame.mshRole:SetTexCoord(20 / 64, 39 / 64, 22 / 64, 41 / 64)
                end
                frame.mshRole:Show()
            end
        else
            -- Если и кастом выключен (или не прошел фильтр), скрываем всё
            if frame.mshRole then frame.mshRole:Hide() end
        end
    end

    -- РЕЙДОВЫЕ МЕТКИ
    local index = GetRaidTargetIndex(unit)
    if index then
        frame.mshRaidIcon:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
        frame.mshRaidIcon:SetSize(cfg.raidMarkSize or 14, cfg.raidMarkSize or 14)
        frame.mshRaidIcon:ClearAllPoints()
        frame.mshRaidIcon:SetPoint(cfg.raidMarkPoint or "CENTER", frame, cfg.raidMarkX or 0, cfg.raidMarkY or 0)
        SetRaidTargetIconTexture(frame.mshRaidIcon, index)
        frame.mshRaidIcon:Show()
    else
        frame.mshRaidIcon:Hide()
    end

    -- Метка
    local index = GetRaidTargetIndex(unit)
    if index and cfg.showRaidMark then
        frame.mshRaidIcon:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
        SetRaidTargetIconTexture(frame.mshRaidIcon, index)
        frame.mshRaidIcon:SetSize(cfg.raidMarkSize, cfg.raidMarkSize)
        frame.mshRaidIcon:ClearAllPoints()
        frame.mshRaidIcon:SetPoint(cfg.raidMarkPoint, frame, cfg.raidMarkX, cfg.raidMarkY)
        frame.mshRaidIcon:Show()
    else
        frame.mshRaidIcon:Hide()
    end

    -- ОБНОВЛЕНИЕ ИКОНКИ ЛИДЕРА
    if frame.mshLeader then
        local isLeader = UnitIsGroupLeader(unit)
        local isAssistant = UnitIsGroupAssistant(unit) and not IsInRaid(LE_PARTY_CATEGORY_HOME)

        -- Если у тебя в конфиге будет параметр showLeaderIcon (добавим его позже)
        if (isLeader or isAssistant) then
            if isLeader then
                frame.mshLeader:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
            else
                frame.mshLeader:SetTexture("Interface\\GroupFrame\\UI-Group-AssistantIcon")
            end

            -- Настраиваем размер и позицию (пока жестко, потом вынесем в cfg)
            local size = 12
            frame.mshLeader:SetSize(size, size)
            frame.mshLeader:ClearAllPoints()
            -- Ставим, например, рядом с иконкой роли или в угол
            frame.mshLeader:SetPoint("TOPLEFT", frame, 20, -20)
            frame.mshLeader:Show()
        else
            frame.mshLeader:Hide()
        end
    end
end
