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

    local cfg = msh.GetConfigForFrame(frame)
    if not cfg then return end

    -- ФИКС МК и имени
    local currentRawName = GetUnitName(unit, false)
    local unitGUID = UnitGUID(unit)
    if not currentRawName or not unitGUID or type(currentRawName) == "userdata" or type(unitGUID) == "userdata" then
        return
    end

    -- РЕЙДОВЫЕ МЕТКИ
    local index = GetRaidTargetIndex(unit)
    if index and cfg.showRaidMark then
        frame.mshRaidIcon:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
        frame.mshRaidIcon:SetSize(cfg.raidMarkSize or 14, cfg.raidMarkSize or 14)
        frame.mshRaidIcon:ClearAllPoints()
        frame.mshRaidIcon:SetPoint(cfg.raidMarkPoint or "CENTER", frame, cfg.raidMarkX or 0, cfg.raidMarkY or 0)
        SetRaidTargetIconTexture(frame.mshRaidIcon, index)
        frame.mshRaidIcon:Show()
    else
        frame.mshRaidIcon:Hide()
    end

    -- РОЛЬ (ТАНК, ХИЛ, ДД)
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

        if shouldShowCustom and role and role ~= "NONE" then
            if frame.mshRole then
                local atlasName
                if role == "TANK" then
                    atlasName = "Warfronts-BaseMapIcons-Horde-Armory-Minimap"
                elseif role == "HEALER" then
                    atlasName = "GreenCross"
                elseif role == "DAMAGER" then
                    atlasName = "Fishing-Hole"
                end
                if atlasName then
                    frame.mshRole:SetAtlas(atlasName)
                    local size = cfg.roleIconSize or 12
                    frame.mshRole:SetSize(size, size)
                    frame.mshRole:ClearAllPoints()
                    frame.mshRole:SetPoint(cfg.roleIconPoint or "TOPLEFT", frame, cfg.roleIconX or 2, cfg.roleIconY or -2)
                    frame.mshRole:Show()
                end
            end
        else
            if frame.mshRole then frame.mshRole:Hide() end
        end
    end

    -- ЛИДЕР И АССИСТЕНТ
    if frame.mshLeader then
        local isLeader = UnitIsGroupLeader(unit)
        local isAssistant = UnitIsGroupAssistant(unit)

        -- Проверяем, включена ли иконка в настройках (по умолчанию true)
        if (isLeader or isAssistant) and (cfg.showLeaderIcon ~= false) then
            -- сначала иконка лидера, потом асиста
            frame.mshLeader:SetAtlas(isLeader and "BuildanAbomination-32x32" or "poi-soulspiritghost")
            frame.mshLeader:SetDrawLayer("OVERLAY", 1)

            -- Подтягиваем размеры и координаты из твоего нового раздела в Config.lua
            local size = cfg.leaderIconSize or 12
            frame.mshLeader:SetSize(size, size)

            frame.mshLeader:ClearAllPoints()
            -- Применяем точку привязки и смещение X/Y из ползунков
            frame.mshLeader:SetPoint(
                cfg.leaderIconPoint or "TOPLEFT",
                frame,
                cfg.leaderIconX or 0,
                cfg.leaderIconY or 0
            )

            frame.mshLeader:Show()
        else
            -- Если игрока разжаловали или иконка выключена в меню — скрываем
            frame.mshLeader:Hide()
        end
    end

    -- КЭШИРОВАНИЕ И ОБНОВЛЕНИЕ ИМЕНИ
    local cacheKey = currentRawName .. unitGUID .. (cfg.nameLength or "10") .. tostring(cfg.shortenNames) .. cfg
        .fontName
    if frame.mshCachedKey ~= cacheKey then
        local name = msh.GetShortName(unit, cfg)
        frame.mshName:SetText(name)
        frame.mshCachedKey = cacheKey
    end
    frame.mshName:ClearAllPoints()
    frame.mshName:SetPoint(cfg.namePoint or "CENTER", frame, cfg.nameX or 0, cfg.nameY or 0)

    -- УСТАНОВКА ШРИФТА
    local fontName = cfg.fontName or "Friz Quadrata TT"
    local fontPath = LSM:Fetch("font", fontName)
    local fontSize = cfg.fontSizeName or 10
    local fontOutline = cfg.nameOutline or "OUTLINE"

    frame.mshName:SetFont(fontPath, fontSize, fontOutline)
    frame.mshName:ClearAllPoints()
    frame.mshName:SetPoint(cfg.namePoint or "CENTER", frame, cfg.nameX or 0, cfg.nameY or 0)
    frame.mshName:SetTextColor(1, 1, 1)

    if frame.name then frame.name:SetAlpha(0) end
end
