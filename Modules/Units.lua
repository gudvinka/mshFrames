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
    frame.mshDispelIndicator = frame:CreateTexture(nil, "OVERLAY", nil, 7)

    -- frame.mshDispelBorder = CreateFrame("Frame", nil, frame)
    -- frame.mshDispelBorder:SetAllPoints(frame)
    -- frame.mshDispelBorder:SetFrameLevel(frame:GetFrameLevel())
    -- local function CreateBorderLine(f)
    --     local t = f:CreateTexture(nil, "OVERLAY", nil, 1)
    --     t:SetColorTexture(1, 1, 1)
    --     return t
    -- end
    -- -- Верхняя линия
    -- frame.mshDispelBorder.Top = CreateBorderLine(frame.mshDispelBorder)
    -- frame.mshDispelBorder.Top:SetPoint("TOPLEFT", 0, 0)
    -- frame.mshDispelBorder.Top:SetPoint("TOPRIGHT", 0, 0)
    -- frame.mshDispelBorder.Top:SetHeight(5)
    -- -- Нижняя линия
    -- frame.mshDispelBorder.Bottom = CreateBorderLine(frame.mshDispelBorder)
    -- frame.mshDispelBorder.Bottom:SetPoint("BOTTOMLEFT", 0, 0)
    -- frame.mshDispelBorder.Bottom:SetPoint("BOTTOMRIGHT", 0, 0)
    -- frame.mshDispelBorder.Bottom:SetHeight(5)
    -- -- Левая линия
    -- frame.mshDispelBorder.Left = CreateBorderLine(frame.mshDispelBorder)
    -- frame.mshDispelBorder.Left:SetPoint("TOPLEFT", 0, 0)
    -- frame.mshDispelBorder.Left:SetPoint("BOTTOMLEFT", 0, 0)
    -- frame.mshDispelBorder.Left:SetWidth(5)
    -- -- Правая линия
    -- frame.mshDispelBorder.Right = CreateBorderLine(frame.mshDispelBorder)
    -- frame.mshDispelBorder.Right:SetPoint("TOPRIGHT", 0, 0)
    -- frame.mshDispelBorder.Right:SetPoint("BOTTOMRIGHT", 0, 0)
    -- frame.mshDispelBorder.Right:SetWidth(5)
    -- frame.mshDispelBorder:Hide()
    -- local DebuffTypeColor = {
    --     ["Magic"]   = { 0.20, 0.60, 1.00 },
    --     ["Curse"]   = { 0.60, 0.00, 1.00 },
    --     ["Disease"] = { 0.60, 0.40, 0.00 },
    --     ["Poison"]  = { 0.00, 0.60, 0.00 },
    --     [""]        = { 0.70, 0.70, 0.70 },
    -- }

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
        frame.mshRaidIcon:SetAlpha(cfg.raidMarkAlpha or 1)
        frame.mshRaidIcon:ClearAllPoints()
        frame.mshRaidIcon:SetPoint(cfg.raidMarkPoint or "CENTER", frame, cfg.raidMarkX or 0, cfg.raidMarkY or 0)
        SetRaidTargetIconTexture(frame.mshRaidIcon, index)
        frame.mshRaidIcon:Show()
    else
        frame.mshRaidIcon:Hide()
    end

    -- Индикатор диспела
    if frame.mshDispelIndicator then
        local globalMode = msh.db.profile.global.dispelIndicatorMode or "0"

        -- local showOverlay = msh.db.profile.global.dispelIndicatorOverlay
        -- if showOverlay == nil then showOverlay = true end

        if globalMode == "0" then
            frame.mshDispelIndicator:Hide()
            if frame.mshDispelBorder then frame.mshDispelBorder:Hide() end
            if frame.Border then frame.Border:SetAlpha(1) end
            return
        end

        local blizzIcon = frame.dispelDebuffFrames and frame.dispelDebuffFrames[1]

        if blizzIcon and blizzIcon:IsShown() then
            local atlasName = blizzIcon.icon:GetAtlas()
            if atlasName then
                frame.mshDispelIndicator:SetAtlas(atlasName)
            else
                frame.mshDispelIndicator:SetTexture(blizzIcon.icon:GetTexture())
            end

            local size = cfg.dispelIndicatorSize or 18
            local alpha = cfg.dispelIndicatorAlpha or 1
            frame.mshDispelIndicator:SetSize(size, size)
            frame.mshDispelIndicator:SetAlpha(alpha)
            frame.mshDispelIndicator:ClearAllPoints()
            frame.mshDispelIndicator:SetPoint(cfg.dispelIndicatorPoint or "TOPRIGHT", frame, cfg.dispelIndicatorX or 0,
                cfg.dispelIndicatorY or 0)

            frame.mshDispelIndicator:Show()
            blizzIcon:SetAlpha(0)

            -- Рамка
            --     if frame.mshDispelBorder then
            --         if showOverlay then
            --             local auraData = C_UnitAuras.GetAuraDataByIndex(unit, 1, "RAID")
            --             local debuffType = auraData and auraData.dispelName
            --             local r, g, b = 1, 0, 0

            --             if debuffType and _G.DebuffTypeColor[debuffType] then
            --                 local c = _G.DebuffTypeColor[debuffType]
            --                 r, g, b = c.r, c.g, c.b
            --             end

            --             frame.mshDispelBorder.Top:SetVertexColor(r, g, b)
            --             frame.mshDispelBorder.Bottom:SetVertexColor(r, g, b)
            --             frame.mshDispelBorder.Left:SetVertexColor(r, g, b)
            --             frame.mshDispelBorder.Right:SetVertexColor(r, g, b)

            --             frame.mshDispelBorder:Show()
            --             if frame.Border then frame.Border:SetAlpha(0) end
            --         else
            --             frame.mshDispelBorder:Hide()
            --             if frame.Border then frame.Border:SetAlpha(1) end
            --         end
            --     end
            -- else
            --     -- 3. Если дебаффа НЕТ (ОБЯЗАТЕЛЬНО ПРЯЧЕМ ВСЁ)
            --     frame.mshDispelIndicator:Hide()
            --     if frame.mshDispelBorder then
            --         frame.mshDispelBorder:Hide()
            --     end
            -- if frame.Border then
            --     frame.Border:SetAlpha(1)
            -- end
        else
            frame.mshDispelIndicator:Hide()
        end
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
                    frame.mshRole:SetAlpha(cfg.roleIconAlpha or 1)
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


        if (isLeader or isAssistant) and (cfg.showLeaderIcon ~= false) then
            frame.mshLeader:SetAtlas(isLeader and "BuildanAbomination-32x32" or "poi-soulspiritghost")
            frame.mshLeader:SetDrawLayer("OVERLAY", 1)

            local size = cfg.leaderIconSize or 12
            frame.mshLeader:SetSize(size, size)
            frame.mshLeader:SetAlpha(cfg.leaderIconAlpha or 1)
            frame.mshLeader:ClearAllPoints()

            frame.mshLeader:SetPoint(
                cfg.leaderIconPoint or "TOPLEFT",
                frame,
                cfg.leaderIconX or 0,
                cfg.leaderIconY or 0
            )
            frame.mshLeader:Show()
        else
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
