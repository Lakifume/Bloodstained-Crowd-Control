require("utility")
require("constant")
require("variable")

function CanExecuteCommand()
    if not IsInList({1, 6, 9}, GetGameInstance():GetGameModeType()) then return false end
    if not GetGameInstance().LoadingManagerInstance:IsValid() then return false end
    if GetGameInstance().LoadingManagerInstance:IsLoadingScreenVisible() then return false end
    local player = GetPlayerCharacter()
    if not player:IsValid() then return false end
    if player.Killed then return false end 
    if player.Step:IsRollingForInvert() then return false end
    if player.CurrentryWarpingByWarpRoom then return false end
    local interfaceHUD = GetPlayerController().MyHUD
    if not interfaceHUD:IsValid() then return false end
    if not interfaceHUD:GetGaugeWidget():IsValid() then return false end
    if not interfaceHUD:GetGaugeWidget():GetIsVisible() then return false end
    return true
end

function NotifyCrowdControlCommand(effectName)
    if not displayNotifications then return end
    local interfaceHUD = GetPlayerController().MyHUD
    interfaceHUD:DisplayItemNameWindow(effectName, 1022)
end

function ToggleDisplayNotifications()
    if displayNotifications then
        NotifyCrowdControlCommand("Notifications Off")
        displayNotifications = false
    else
        displayNotifications = true
        NotifyCrowdControlCommand("Notifications On")
    end
end

function PoisonPlayer()
    local player = GetPlayerCharacter()
    if player:IsStatusPoisoned({}, {}) then return false end
    ExecuteInGameThread(function()
        NotifyCrowdControlCommand("Poison Player")
        player.Step:SetSpecialEffect(FName("Poison"))
    end)
    return true
end

function CursePlayer()
    local player = GetPlayerCharacter()
    if player:IsStatusCursed({}, {}) then return false end
    ExecuteInGameThread(function()
        NotifyCrowdControlCommand("Curse Player")
        player.Step:SetSpecialEffect(FName("Curse"))
    end)
    return true
end

function PetrifyPlayer()
    local player = GetPlayerCharacter()
    if player:IsStatusStoned({}) then return false end
    ExecuteInGameThread(function()
        NotifyCrowdControlCommand("Petrify Player")
        player.Step:SetSpecialEffect(FName("Stone"))
    end)
    return true
end

function SlowPlayerDown()
    local player = GetPlayerCharacter()
    if player:IsStatusSlowed({}, {}) then return false end
    ExecuteInGameThread(function()
        NotifyCrowdControlCommand("Slow Player Down")
        player.Step:SetSpecialEffect(FName("Slow"))
    end)
    return true
end

function SlamPlayer()
    if heavenOrHellActive then return false end
    local player = GetPlayerCharacter()
    if player:IsStatusStoned({}) then return false end
    if player.CharacterStatus.HitPoint <= 1 then return false end
    if not player.Step:CanUpdateNextHitTimer() then return false end
    ExecuteInGameThread(function()
        NotifyCrowdControlCommand("Slam Player")
        player:DirectDamageWithId(1.0, FName("N2008_BackStep"))
    end)
    return true
end

function EmptyHealth()
    local player = GetPlayerCharacter()
    if player.CharacterStatus.HitPoint <= 1 then return false end
    ExecuteInGameThread(function()
        NotifyCrowdControlCommand("Empty Health")
        player.CharacterStatus:SetHitPointForce(1)
    end)
    return true
end

function EmptyMagic()
    local player = GetPlayerCharacter()
    if player.CharacterStatus.MagicPoint <= 1 then return false end
    ExecuteInGameThread(function()
        NotifyCrowdControlCommand("Empty Magic")
        player.CharacterStatus:SetMagicPointForce(1)
    end)
    return true
end

function RefillHealth()
    local player = GetPlayerCharacter()
    if GetCharacterHealthRatio(player) >= 1.0 then return false end
    ExecuteInGameThread(function()
        NotifyCrowdControlCommand("Refill Health")
        player.CharacterStatus:RecoverHitPoint()
    end)
    return true
end

function RefillMagic()
    local player = GetPlayerCharacter()
    if GetCharacterMagicRatio(player) >= 1.0 then return false end
    ExecuteInGameThread(function()
        NotifyCrowdControlCommand("Refill Magic")
        player.CharacterStatus:RecoverMagicPoint()
    end)
    return true
end

function ShuffleColors()
    local player = GetPlayerCharacter()
    -- Only shuffle colors and not haircuts to avoid crashes
    ExecuteInGameThread(function()
        NotifyCrowdControlCommand("Shuffle Colors")
        for index = 1,6,1 do
            for subindex = 0,2,1 do
                player:SetChromaWheelColorScheme(index, {R=math.random(), G=math.random(), B=math.random()}, subindex)
            end
        end
        player:SetChromaWheelTrim(3, math.random(1, 36))
        GetGameInstance().m_SystemSettings:SetBloodColor(math.random(0, 11))
    end)
    return true
end

function FakeFlawlessWin()
    local player = GetPlayerCharacter()
    ExecuteInGameThread(function()
        NotifyCrowdControlCommand("Fake Flawless Win")
        player.Step:NoticeBossBattleNoDamageWin(nullName)
    end)
    return true
end

function PlayDeathQuote()
    local player = GetPlayerCharacter()
    local chosenVoice = RandomChoice(voicelist)
    print("Played quote: " .. chosenVoice)
    NotifyCrowdControlCommand("Play Death Quote")
    PlayEnemySound(chosenVoice)
    return true
end

function ShrinkPlayer()
    if shrinkPlayerActive then return false end
    if growPlayerActive then return false end
    shrinkPlayerActive = true
    sizeChangeCurrentModifier = 0.5
    NotifyCrowdControlCommand("Shrink Player")
    SetPlayerScale(false)
    return true
end

function ShrinkPlayerEnd()
    if not shrinkPlayerActive then return end
    shrinkPlayerActive = false
    if GetPlayerCharacter():IsValid() then SetPlayerScale(true) end
    EndTimedEffect("ShrinkPlayer")
end

function GrowPlayer()
    if growPlayerActive then return false end
    if shrinkPlayerActive then return false end
    growPlayerActive = true
    sizeChangeCurrentModifier = 1.7
    NotifyCrowdControlCommand("Grow Player")
    SetPlayerScale(false)
    return true
end

function GrowPlayerEnd()
    if not growPlayerActive then return end
    growPlayerActive = false
    if GetPlayerCharacter():IsValid() then SetPlayerScale(true) end
    EndTimedEffect("GrowPlayer")
end

function SetPlayerScale(resetScale)
    local player = GetPlayerCharacter()
    local effectiveShard = player.Step:GetEffectiveShard()
    local scaleModifier = resetScale and 1.0 or sizeChangeCurrentModifier
    local scaleVector = {X=scaleModifier, Y=scaleModifier, Z=scaleModifier}
    player.MeshComponent:SetRelativeScale3D(scaleVector)
    -- Update the Bunnymorphosis body scale
    if effectiveShard:IsValid() then
        if GetClassName(effectiveShard) == "EffectiveChangeBunny_C" then
            effectiveShard.SK_ChangeBunny_Body:SetRelativeScale3D(scaleVector)
        end
    end
    -- Reset the Accelerator effect scale
    local bullets = FindAllOf("PBBulletActor")
    for index = 1,#bullets,1 do
        local bullet = bullets[index]
        if bullet.CurrentBulletId == FName("P0000_DASH_EFFECT") then
            bullet.SubActor:SetActorScale3D(scaleVector)
        end
    end
end

function FlipPlayer()
    if flipPlayerActive then return false end
    flipPlayerActive = true
    ExecuteInGameThread(function()
        NotifyCrowdControlCommand("Flip Player")
        utility:SetLeftAnalogMirrorFlag(true)
    end)
    -- Switching rooms breaks it so enable it back
    flipPlayerRoomChangePreHook, flipPlayerRoomChangePostHook = RegisterHook("/Script/ProjectBlood.PBRoomVolume:OnRoomVolumeOverlapEnd", function()
        ExecuteInGameThread(function() utility:SetLeftAnalogMirrorFlag(true) end)
    end)
    return true
end

function FlipPlayerEnd()
    if not flipPlayerActive then return end
    flipPlayerActive = false
    ExecuteInGameThread(function() utility:SetLeftAnalogMirrorFlag(false) end)
    UnregisterHook("/Script/ProjectBlood.PBRoomVolume:OnRoomVolumeOverlapEnd", flipPlayerRoomChangePreHook, flipPlayerRoomChangePostHook)
    EndTimedEffect("FlipPlayer")
end

function ShuffleControls()
    if shuffleControlsActive then return false end
    shuffleControlsActive = true
    local configManager = GetPlayerCharacter():GetConfigManager()
    shuffleControlsOriginalAttack = configManager.ConfigData:GetPhysKeyFromActionName(FName("Attack"))
    shuffleControlsOriginalBackstep = configManager.ConfigData:GetPhysKeyFromActionName(FName("Ability"))
    shuffleControlsOriginalJump = configManager.ConfigData:GetPhysKeyFromActionName(FName("Jump"))
    shuffleControlsOriginalTrigger = configManager.ConfigData:GetPhysKeyFromActionName(FName("TriggerShard"))
    shuffleControlsOriginalDirectional = configManager.ConfigData:GetPhysKeyFromActionName(FName("DirectionalShard"))
    shuffleControlsOriginalEffective = configManager.ConfigData:GetPhysKeyFromActionName(FName("EffectiveShard"))
    shuffleControlsOriginalShortcut = configManager.ConfigData:GetPhysKeyFromActionName(FName("Shortcut"))
    local controlList = {
        shuffleControlsOriginalAttack,
        shuffleControlsOriginalBackstep,
        shuffleControlsOriginalJump,
        shuffleControlsOriginalTrigger,
        shuffleControlsOriginalDirectional,
        shuffleControlsOriginalEffective,
        shuffleControlsOriginalShortcut
    }
    local currentAttack = PickAndRemove(controlList)
    local currentBackstep = PickAndRemove(controlList)
    local currentJump = PickAndRemove(controlList)
    local currentTrigger = PickAndRemove(controlList)
    local currentDirectional = PickAndRemove(controlList)
    local currentEffective = PickAndRemove(controlList)
    local currentShortcut = PickAndRemove(controlList)
    NotifyCrowdControlCommand("Shuffle Controls")
    GetGameInstance().m_SystemSettings:BindToGamepad_NO_CHECK(0, currentAttack)
    GetGameInstance().m_SystemSettings:BindToGamepad_NO_CHECK(1, currentBackstep)
    GetGameInstance().m_SystemSettings:BindToGamepad_NO_CHECK(2, currentJump)
    GetGameInstance().m_SystemSettings:BindToGamepad_NO_CHECK(3, currentTrigger)
    GetGameInstance().m_SystemSettings:BindToGamepad_NO_CHECK(4, currentDirectional)
    GetGameInstance().m_SystemSettings:BindToGamepad_NO_CHECK(5, currentEffective)
    GetGameInstance().m_SystemSettings:BindToGamepad_NO_CHECK(7, currentShortcut)
    -- Prevent the player from changing them back
    shuffleControlsUnpausePreHook, shuffleControlsUnpausePostHook = RegisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", function()
        GetGameInstance().m_SystemSettings:BindToGamepad_NO_CHECK(0, currentAttack)
        GetGameInstance().m_SystemSettings:BindToGamepad_NO_CHECK(1, currentBackstep)
        GetGameInstance().m_SystemSettings:BindToGamepad_NO_CHECK(2, currentJump)
        GetGameInstance().m_SystemSettings:BindToGamepad_NO_CHECK(3, currentTrigger)
        GetGameInstance().m_SystemSettings:BindToGamepad_NO_CHECK(4, currentDirectional)
        GetGameInstance().m_SystemSettings:BindToGamepad_NO_CHECK(5, currentEffective)
        GetGameInstance().m_SystemSettings:BindToGamepad_NO_CHECK(7, currentShortcut)
    end)
    return true
end

function ShuffleControlsEnd()
    if not shuffleControlsActive then return end
    shuffleControlsActive = false
    GetGameInstance().m_SystemSettings:BindToGamepad_NO_CHECK(0, shuffleControlsOriginalAttack)
    GetGameInstance().m_SystemSettings:BindToGamepad_NO_CHECK(1, shuffleControlsOriginalBackstep)
    GetGameInstance().m_SystemSettings:BindToGamepad_NO_CHECK(2, shuffleControlsOriginalJump)
    GetGameInstance().m_SystemSettings:BindToGamepad_NO_CHECK(3, shuffleControlsOriginalTrigger)
    GetGameInstance().m_SystemSettings:BindToGamepad_NO_CHECK(4, shuffleControlsOriginalDirectional)
    GetGameInstance().m_SystemSettings:BindToGamepad_NO_CHECK(5, shuffleControlsOriginalEffective)
    GetGameInstance().m_SystemSettings:BindToGamepad_NO_CHECK(7, shuffleControlsOriginalShortcut)
    UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", shuffleControlsUnpausePreHook, shuffleControlsUnpausePostHook)
    EndTimedEffect("ShuffleControls")
end

function UseWitchTime()
    if useWitchTimeActive then return false end
    if turboEnemiesActive then return false end
    local postProcess = FindFirstOf("PostProcessVolume")
    if not postProcess:IsValid() then return false end
    useWitchTimeActive = true
    useWitchTimeShouldStopEffect = false
    local player = GetPlayerCharacter()
    local rate = 0.2
    ExecuteInGameThread(function()
        NotifyCrowdControlCommand("Use Witch Time")
        postProcess.Settings.bOverride_SceneFringeIntensity = 1
        postProcess.Settings.SceneFringeIntensity = 5.0
        utility:PBCategorySlomo(1, 0, rate, player)
        utility:PBCategorySlomo(2, 0, rate, player)
        utility:PBCategorySlomo(3, 0, rate, player)
        utility:PBCategorySlomo(4, 0, rate, player)
        utility:PBActorSlomo(player, 0, 1.0)
    end)
    LoopAsync(1000, function()
        if useWitchTimeShouldStopEffect then return true end
        if not CanExecuteCommand() then return false end
        ExecuteInGameThread(function()
            utility:PBCategorySlomo(1, 0, rate, player)
            utility:PBCategorySlomo(2, 0, rate, player)
            utility:PBCategorySlomo(3, 0, rate, player)
            utility:PBCategorySlomo(4, 0, rate, player)
            utility:PBActorSlomo(player, 0, 1.0)
        end)
        return false
    end)
    return true
end

function CanUseWitchTimeEnd()
    return FindFirstOf("PostProcessVolume"):IsValid()
end

function UseWitchTimeEnd()
    if not useWitchTimeActive then return end
    useWitchTimeActive = false
    useWitchTimeShouldStopEffect = true
    local player = GetPlayerCharacter()
    local postProcess = FindFirstOf("PostProcessVolume")
    ExecuteInGameThread(function()
        if player:IsValid() then utility:PBCategorySlomo(7, 0, 1.0, player) end
        if postProcess:IsValid() then
            postProcess.Settings.bOverride_SceneFringeIntensity = 0
            postProcess.Settings.SceneFringeIntensity = 0.0
        end
    end)
    EndTimedEffect("UseWitchTime")
end

function TurboEnemies()
    if turboEnemiesActive then return false end
    if useWitchTimeActive then return false end
    turboEnemiesActive = true
    turboEnemiesShouldStopEffect = false
    local player = GetPlayerCharacter()
    local rate = 2.0
    ExecuteInGameThread(function()
        NotifyCrowdControlCommand("Turbo Enemies")
        utility:PBCategorySlomo(1, 0, rate, player)
        utility:PBActorSlomo(player, 0, 1.0)
    end)
    LoopAsync(1000, function()
        if turboEnemiesShouldStopEffect then return true end
        if not CanExecuteCommand() then return false end
        ExecuteInGameThread(function()
            utility:PBCategorySlomo(1, 0, rate, player)
            utility:PBActorSlomo(player, 0, 1.0)
        end)
        return false
    end)
    return true
end

function TurboEnemiesEnd()
    if not turboEnemiesActive then return end
    turboEnemiesActive = false
    turboEnemiesShouldStopEffect = true
    local player = GetPlayerCharacter()
    if player:IsValid() then
        ExecuteInGameThread(function() utility:PBCategorySlomo(7, 0, 1.0, player) end)
    end
    EndTimedEffect("TurboEnemies")
end

function UncontrollableSpeed()
    if uncontrollableSpeedActive then return false end
    uncontrollableSpeedActive = true
    NotifyCrowdControlCommand("Uncontrollable Speed")
    ModifyEquipSpecialAttribute({15, 16, 22}, 4.0, true)
    return true
end

function UncontrollableSpeedEnd()
    if not uncontrollableSpeedActive then return end
    uncontrollableSpeedActive = false
    RestoreEquipSpecialAttribute({15, 16, 22})
    EndTimedEffect("UncontrollableSpeed")
end

function CriticalMode()
    if criticalModeActive then return false end
    criticalModeActive = true
    local player = GetPlayerCharacter()
    NotifyCrowdControlCommand("Critical Mode")
    ModifyEquipSpecialAttribute({8}, 999.0, false)
    player:SetEquipSpecialAttribute(107, -999.0)
    player:SetEquipSpecialAttribute(108, -999.0)
    return true
end

function CriticalModeEnd()
    if not criticalModeActive then return end
    criticalModeActive = false
    RestoreEquipSpecialAttribute({8})
    local player = GetPlayerCharacter()
    if player:IsValid() then
        player:SetEquipSpecialAttribute(107, 0.0)
        player:SetEquipSpecialAttribute(108, 0.0)
    end
    EndTimedEffect("CriticalMode")
end

function GoldRush()
    if goldRushActive then return false end
    goldRushActive = true
    goldRushMoneyGain = 0
    NotifyCrowdControlCommand("Gold Rush")
    -- Add a counter for the coins gained
    local damagePopupClass = StaticFindObject("/Game/Core/UI/HUD/Damage/DamagePopup.DamagePopup_C")
    goldRushDamagePopup = widgetBlueprintLibrary:Create(GetPlayerCharacter(), damagePopupClass, nil)
    goldRushDamagePopup:SetPositionInViewport({X=960.0, Y=160.0}, false)
    goldRushDamagePopup:DisplayNumeric(goldRushMoneyGain)
    goldRushDamagePopup:AddToViewport(0)
    -- Convert damage dealt to money
    goldRushDamagePopupPreHook, goldRushDamagePopupPostHook = RegisterHook("/Game/Core/UI/HUD/Damage/DamagePopup.DamagePopup_C:CustomDamageEvent", function(self, param1, param2)
        local damage = param1:get()
        local color = param2:get()
        if color.R == 1.0 and color.G == 1.0 and color.B == 1.0 then
            local coinModifier = math.max(0.1, GetGameInstance().totalCoins/6666)
            local compModifier = Lerp(0.1, 1, GetGameInstance().pMapManager:GetRoomTraverseRate({})/100)
            local quantity = math.max(1, math.floor(damage*(coinModifier/compModifier)))
            goldRushMoneyGain = goldRushMoneyGain + quantity
            goldRushDamagePopup:DisplayNumeric(math.min(goldRushMoneyGain, 99999))
        end
    end)
    return true
end

function GoldRushEnd()
    if not goldRushActive then return end
    goldRushActive = false
    GetGameInstance():SetTotalCoin(goldRushMoneyGain)
    if goldRushDamagePopup:IsValid() then goldRushDamagePopup:RemoveFromViewport() end
    if GetPlayerCharacter():IsValid() then PlayEnemySound(goldRushMoneyGain > 0 and "SE_N1004_Coin02" or "Vo_N1004_040_jp") end
    UnregisterHook("/Game/Core/UI/HUD/Damage/DamagePopup.DamagePopup_C:CustomDamageEvent", goldRushDamagePopupPreHook, goldRushDamagePopupPostHook)
    EndTimedEffect("GoldRush")
end

function UseWaystone()
    if GetGameInstance():IsBossBattleNow() then return false end
    ExecuteInGameThread(function()
        NotifyCrowdControlCommand("Use Waystone")
        GetPlayerCharacter().Step:SetSpecialEffect(FName("WayStone"))
    end)
    return true
end

function UseRosario()
    local enemiesToKill = {}
    local enemiesToDamage = {}
    local actorInstances = FindAllOf("PBBaseCharacter")
    -- Gather lists of enemies to kill and bosses to damage
    for index = 1,#actorInstances,1 do
        local actor = actorInstances[index]
        if actor:IsValid() then
            if actor.OnTheScreen and not actor.Killed then
                if actor:IsBoss() then table.insert(enemiesToDamage, actor) elseif actor:IsEnemy() then table.insert(enemiesToKill, actor) end
            end
        end
    end
    -- Only execute if a target was found
    local hasFoundTarget = #enemiesToKill > 0 or #enemiesToDamage > 0
    if hasFoundTarget then
        NotifyCrowdControlCommand("Use Rosario")
        ExecuteInGameThread(function()
            -- All enemies found will be defeated instantly
            for index = 1,#enemiesToKill,1 do
                local enemy = enemiesToKill[index]
                if enemy:IsValid() then enemy:DirectDamage(enemy.CharacterStatus.HitPoint) end
            end
            -- All bosses found will be dealt 15% of health
            for index = 1,#enemiesToDamage,1 do
                local enemy = enemiesToDamage[index]
                local damageRatio = enemy.Tags[1] == FName("CC") and 0.1 or 0.15
                if enemy:IsValid() then enemy:DirectDamage(math.floor(enemy.CharacterStatus:GetMaxHitPoint()*damageRatio)) end
            end
            ScreenFlash(0.3)
        end)
    end
    return hasFoundTarget
end

function ScreenFlash(duration)
    local player = GetPlayerCharacter()
    local cameraManager = gameplayStatics:GetPlayerCameraManager(player, 0)
    local subDuration = duration/2
    cameraManager:StartCameraFade(0.0, 1.0, subDuration, {R=1.0, G=1.0, B=0.0}, false, true)
    ExecuteWithDelay(math.floor(subDuration*1000), function() cameraManager:StartCameraFade(1.0, 0.0, subDuration, {R=1.0, G=1.0, B=0.0}, false, false) end)
end

function RewindTime()
    if GetGameInstance():IsBossBattleNow() then return false end
    -- Warp in the last valid room traversed, 2 rooms back at most
    local chosenRoom
    if     IsValidRewindRoom(previousRoom2) then
        chosenRoom = previousRoom2
    elseif IsValidRewindRoom(previousRoom1) then
        chosenRoom = previousRoom1
    else return false end
    ExecuteInGameThread(function()
        NotifyCrowdControlCommand("Rewind Time")
        GetGameInstance().pRoomManager:Warp(chosenRoom, false, false, nullName, {})
    end)
    return true
end

function IsValidRewindRoom(room)
    if room == nullName or IsInList(rotatingRooms, room:ToString()) then return false end
    if orlokStandbyActive then
        return not IsInArray(GetGameInstance().pMapManager:GetRoomsByType(1), room)
    end
    return true
end

function SummonAmbush()
    if IsInList(rotatingRooms, currentRoom:ToString()) then return false end
    local player = GetPlayerCharacter()
    local playerLocation = player:K2_GetActorLocation()
    local playerScreenPosition = player:GetScreenPosition()
    if playerScreenPosition.X < 1/3 or playerScreenPosition.X > 2/3 then return false end
    local chosenEnemy = RandomChoice(enemylist)
    local enemyLevel = CompletionToEnemyLevel(GetGameInstance().pMapManager:GetRoomTraverseRate({}))
    print("Spawned enemy: " .. chosenEnemy .. " Lv " .. enemyLevel)
    -- Spawn 2 of the same random enemy with their levels scaling with map completion
    ExecuteInGameThread(function()
        NotifyCrowdControlCommand("Summon Ambush")
        local enemy1 = GetGameInstance().pCharacterManager:CreateCharacter(FName(chosenEnemy), "", {X = playerLocation.X + 420, Y = playerLocation.Y, Z = playerLocation.Z}, {}, 1, "", nil, false)
        local enemy2 = GetGameInstance().pCharacterManager:CreateCharacter(FName(chosenEnemy), "", {X = playerLocation.X - 420, Y = playerLocation.Y, Z = playerLocation.Z}, {}, 1, "", nil, false)
        if not enemy1:IsValid() or not enemy2:IsValid() then return false end
        enemy1:SetCharacterWorldRotation(180.0, 0.0)
        enemy1:SetEnemyLevel(enemyLevel)
        enemy1.CharacterStatus:RecoverHitPoint()
        enemy1.Experience = 0
        enemy1.DropID = nullName
        enemy2:SetEnemyLevel(enemyLevel)
        enemy2.CharacterStatus:RecoverHitPoint()
        enemy2.Experience = 0
        enemy2.DropID = nullName
    end)
    return true
end

function SummonRave()
    if summonRaveActive then return false end
    if summonDarknessActive then return false end
    local postProcess = FindFirstOf("PostProcessVolume")
    if not postProcess:IsValid() then return false end
    summonRaveActive = true
    summonRaveShouldStopEffect = false
    local timer = 0
    local progress = 0
    local fullcycle = 1000
    local deltaSeconds = gameplayStatics:GetWorldDeltaSeconds(postProcess)
    NotifyCrowdControlCommand("Summon Rave")
    postProcess.Settings.bOverride_ColorGain = 1
    -- Cycle through color gains
    LoopAsync(math.floor(deltaSeconds*1000), function()
        if summonRaveShouldStopEffect then return true end
        ExecuteInGameThread(function()
            timer = timer + deltaSeconds*1000
            progress = timer%fullcycle
            color = mathLibrary:HSVToRGB(progress/fullcycle*360, 0.75, 1.0, 1.0)
            if not postProcess:IsValid() then postProcess = FindFirstOf("PostProcessVolume") end
            if postProcess:IsValid() then postProcess.Settings.ColorGain = {X=color.R, Y=color.G, Z=color.B} end
        end)
        return false
    end)
    return true
end

function CanSummonRaveEnd()
    return FindFirstOf("PostProcessVolume"):IsValid()
end

function SummonRaveEnd()
    if not summonRaveActive then return end
    summonRaveActive = false
    summonRaveShouldStopEffect = true
    local postProcess = FindFirstOf("PostProcessVolume")
    if postProcess:IsValid() then
        ExecuteInGameThread(function()
            postProcess.Settings.bOverride_ColorGain = 0
            postProcess.Settings.ColorGain = {X=1.0, Y=1.0, Z=1.0}
        end)
    end
    EndTimedEffect("SummonRave")
end

function SummonDarkness()
    if summonDarknessActive then return false end
    if summonRaveActive then return false end
    local postProcess = FindFirstOf("PostProcessVolume")
    if not postProcess:IsValid() then return false end
    summonDarknessActive = true
    ExecuteInGameThread(function()
        NotifyCrowdControlCommand("Summon Darkness")
        postProcess.Settings.bOverride_VignetteIntensity = 1
        postProcess.Settings.VignetteIntensity = 5.0
    end)
    return true
end

function CanSummonDarknessEnd()
    return FindFirstOf("PostProcessVolume"):IsValid()
end

function SummonDarknessEnd()
    if not summonDarknessActive then return end
    summonDarknessActive = false
    local postProcess = FindFirstOf("PostProcessVolume")
    if postProcess:IsValid() then
        ExecuteInGameThread(function()
            postProcess.Settings.bOverride_VignetteIntensity = 0
            postProcess.Settings.VignetteIntensity = 0.0
        end)
    end
    EndTimedEffect("SummonDarkness")
end

function TriggerEarthquake(duration)
    local player = GetPlayerCharacter()
    ExecuteInGameThread(function()
        NotifyCrowdControlCommand("Trigger Earthquake")
        player.Step:CameraShake(duration/1000, 0.15, 60.0, 0.3, 40.0, 0.0, 0.0, player.criticalForceFeedback, nullName, false, nullName)
    end)
    return true
end

function ForceInvert()
    if forceInvertActive then return false end
    if noSkillShardsActive then return false end
    forceInvertActive = true
    local player = GetPlayerCharacter()
    local inventory = player.CharacterInventory
    ExecuteInGameThread(function()
        NotifyCrowdControlCommand("Force Invert")
        if not eventUtility:IsInvertedByPlayerCharacter(0) then player.Step:BeginInvert() end
        inventory:SetSkillOnOff(FName("Invert"), false)
    end)
    -- Prevent the player from enabling it back
    forceInvertUnpausePreHook, forceInvertUnpausePostHook = RegisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", function()
        ExecuteInGameThread(function() inventory:SetSkillOnOff(FName("Invert"), false) end)
    end)
    return true
end

function ForceInvertEnd()
    if not forceInvertActive then return end
    forceInvertActive = false
    local player = GetPlayerCharacter()
    local inventory = player.CharacterInventory
    if player:IsValid() then
        ExecuteInGameThread(function() 
            if eventUtility:IsInvertedByPlayerCharacter(0) then player.Step:BeginInvert() end
            if ItemInInventory(inventory.mySkills, "Invert") then inventory:SetSkillOnOff(FName("Invert"), true) end
        end)
    end
    UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", forceInvertUnpausePreHook, forceInvertUnpausePostHook)
    EndTimedEffect("ForceInvert")
end

function NoSkillShards()
    if noSkillShardsActive then return false end
    if forceInvertActive then return false end
    noSkillShardsActive = true
    ExecuteInGameThread(function()
        NotifyCrowdControlCommand("No Skill Shards")
        if eventUtility:IsInvertedByPlayerCharacter(0) then GetPlayerCharacter().Step:BeginInvert() end
        SetAllSkillOnOff(false)
    end)
    -- Prevent the player from enabling them back
    noSkillShardsUnpausePreHook, noSkillShardsUnpausePostHook = RegisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", function()
        ExecuteInGameThread(function() SetAllSkillOnOff(false) end)
    end)
    return true
end

function NoSkillShardsEnd()
    if not noSkillShardsActive then return end
    noSkillShardsActive = false
    if GetPlayerCharacter():IsValid() then
        ExecuteInGameThread(function() SetAllSkillOnOff(true) end)
    end
    UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", noSkillShardsUnpausePreHook, noSkillShardsUnpausePostHook)
    EndTimedEffect("NoSkillShards")
end

function SetAllSkillOnOff(flag)
    local player = GetPlayerCharacter()
    local inventory = player.CharacterInventory
    for index = 1,#inventory.mySkills,1 do
        inventory:SetSkillOnOff(inventory.mySkills[index].ID, flag)
    end
end

function WeaponsOnly()
    if weaponsOnlyActive then return false end
    if shardsOnlyActive then return false end
    if forceEquipmentActive then return false end
    if IsShardWindowOpen() then return false end
    weaponsOnlyActive = true
    local inventory = GetPlayerCharacter().CharacterInventory
    local interfaceHUD = GetPlayerController().MyHUD
    equipmentChangeOriginalTrigger = inventory.aEquipShortcuts.TriggerShard
    equipmentChangeOriginalEffective = inventory.aEquipShortcuts.EffectiveShard
    equipmentChangeOriginalDirectional = inventory.aEquipShortcuts.DirectionalShard
    equipmentChangeOriginalEnchant = inventory.aEquipShortcuts.EnchantShard
    equipmentChangeOriginalFamiliar = inventory.aEquipShortcuts.FamiliarShard
    ExecuteInGameThread(function()
        NotifyCrowdControlCommand("Weapons Only")
        interfaceHUD:DispShortcutMenu(true)
        UnequipPlayerShards()
    end)
    -- Prevent the player from equipping it back
    equipmentChangeUnpausePreHook, equipmentChangeUnpausePostHook = RegisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", function()
        ExecuteInGameThread(function()
            interfaceHUD:DispShortcutMenu(true)
            UnequipPlayerShards()
        end)
    end)
    equipmentChangeShortcutPreHook, equipmentChangeShortcutPostHook = RegisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ChangeCurrentShortcut", function() end, function()
        ExecuteInGameThread(function()
            interfaceHUD:DispShortcutMenu(true)
            UnequipPlayerShards()
        end)
    end)
    return true
end

function CanWeaponsOnlyEnd()
    return not IsShardWindowOpen()
end

function WeaponsOnlyEnd()
    if not weaponsOnlyActive then return end
    weaponsOnlyActive = false
    local interfaceHUD = GetPlayerController().MyHUD
    if interfaceHUD:IsValid() then
        ExecuteInGameThread(function()
            interfaceHUD:DispShortcutMenu(true)
            EquipPlayerShards(equipmentChangeOriginalTrigger, equipmentChangeOriginalEffective, equipmentChangeOriginalDirectional, equipmentChangeOriginalEnchant, equipmentChangeOriginalFamiliar)
        end)
    end
    UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", equipmentChangeUnpausePreHook, equipmentChangeUnpausePostHook)
    UnregisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ChangeCurrentShortcut", equipmentChangeShortcutPreHook, equipmentChangeShortcutPostHook)
    EndTimedEffect("WeaponsOnly")
end

function ShardsOnly()
    if shardsOnlyActive then return false end
    if weaponsOnlyActive then return false end
    if forceEquipmentActive then return false end
    if IsShardWindowOpen() then return false end
    shardsOnlyActive = true
    local inventory = GetPlayerCharacter().CharacterInventory
    local interfaceHUD = GetPlayerController().MyHUD
    equipmentChangeOriginalWeapon = inventory.aEquipShortcuts.weapon
    equipmentChangeOriginalBullet = inventory.aEquipShortcuts.Bullet
    ExecuteInGameThread(function()
        NotifyCrowdControlCommand("Shards Only")
        interfaceHUD:DispShortcutMenu(true)
        UnequipPlayerWeapon()
    end)
    -- Prevent the player from equipping them back
    equipmentChangeUnpausePreHook, equipmentChangeUnpausePostHook = RegisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", function()
        ExecuteInGameThread(function()
            interfaceHUD:DispShortcutMenu(true)
            UnequipPlayerWeapon()
        end)
    end)
    equipmentChangeShortcutPreHook, equipmentChangeShortcutPostHook = RegisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ChangeCurrentShortcut", function() end, function()
        ExecuteInGameThread(function()
            interfaceHUD:DispShortcutMenu(true)
            UnequipPlayerWeapon()
        end)
    end)
    return true
end

function CanShardsOnlyEnd()
    return not IsShardWindowOpen()
end

function ShardsOnlyEnd()
    if not shardsOnlyActive then return end
    shardsOnlyActive = false
    local interfaceHUD = GetPlayerController().MyHUD
    if interfaceHUD:IsValid() then
        ExecuteInGameThread(function()
            interfaceHUD:DispShortcutMenu(true)
            EquipPlayerWeapon(equipmentChangeOriginalWeapon, equipmentChangeOriginalBullet)
        end)
    end
    UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", equipmentChangeUnpausePreHook, equipmentChangeUnpausePostHook)
    UnregisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ChangeCurrentShortcut", equipmentChangeShortcutPreHook, equipmentChangeShortcutPostHook)
    EndTimedEffect("ShardsOnly")
end

function ForceEquipment()
    if forceEquipmentActive then return false end
    if weaponsOnlyActive then return false end
    if shardsOnlyActive then return false end
    if IsShardWindowOpen() then return false end
    forceEquipmentActive = true
    local inventory = GetPlayerCharacter().CharacterInventory
    local interfaceHUD = GetPlayerController().MyHUD
    equipmentChangeOriginalWeapon = inventory.aEquipShortcuts.weapon
    equipmentChangeOriginalBullet = inventory.aEquipShortcuts.Bullet
    equipmentChangeOriginalTrigger = inventory.aEquipShortcuts.TriggerShard
    equipmentChangeOriginalEffective = inventory.aEquipShortcuts.EffectiveShard
    equipmentChangeOriginalDirectional = inventory.aEquipShortcuts.DirectionalShard
    equipmentChangeOriginalEnchant = inventory.aEquipShortcuts.EnchantShard
    equipmentChangeOriginalFamiliar = inventory.aEquipShortcuts.FamiliarShard
    local currentWeapon = RandomEquipment(inventory.myWeapons)
    local currentBullet = RandomEquipment(inventory.myBullets)
    local currentTriggerShard = RandomEquipment(inventory.myTriggerShards)
    local currentEffectiveShard = RandomEquipment(inventory.myEffectiveShards)
    local currentDirectionalShard = RandomEquipment(inventory.myDirectionalShards)
    local currentEnchantShard = RandomEquipment(inventory.myEnchantShards)
    local currentFamiliarShard = RandomEquipment(inventory.myFamiliarShards)
    print("Forced weapon: " .. currentWeapon:ToString())
    print("Forced bullet: " .. currentBullet:ToString())
    print("Forced trigger shard: " .. currentTriggerShard:ToString())
    print("Forced effective shard: " .. currentEffectiveShard:ToString())
    print("Forced directional shard: " .. currentDirectionalShard:ToString())
    print("Forced enchant shard: " .. currentEnchantShard:ToString())
    print("Forced familiar shard: " .. currentFamiliarShard:ToString())
    ExecuteInGameThread(function()
        NotifyCrowdControlCommand("Force Equipment")
        interfaceHUD:DispShortcutMenu(true)
        EquipPlayerWeapon(currentWeapon, currentBullet)
        EquipPlayerShards(currentTriggerShard, currentEffectiveShard, currentDirectionalShard, currentEnchantShard, currentFamiliarShard)
    end)
    -- Prevent the player from changing their equipment
    equipmentChangeUnpausePreHook, equipmentChangeUnpausePostHook = RegisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", function()
        ExecuteInGameThread(function()
            interfaceHUD:DispShortcutMenu(true)
            EquipPlayerWeapon(currentWeapon, currentBullet)
            EquipPlayerShards(currentTriggerShard, currentEffectiveShard, currentDirectionalShard, currentEnchantShard, currentFamiliarShard)
        end)
    end)
    equipmentChangeShortcutPreHook, equipmentChangeShortcutPostHook = RegisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ChangeCurrentShortcut", function() end, function()
        ExecuteInGameThread(function()
            interfaceHUD:DispShortcutMenu(true)
            EquipPlayerWeapon(currentWeapon, currentBullet)
            EquipPlayerShards(currentTriggerShard, currentEffectiveShard, currentDirectionalShard, currentEnchantShard, currentFamiliarShard)
        end)
    end)
    return true
end

function CanForceEquipmentEnd()
    return not IsShardWindowOpen()
end

function ForceEquipmentEnd()
    if not forceEquipmentActive then return end
    forceEquipmentActive = false
    local interfaceHUD = GetPlayerController().MyHUD
    if interfaceHUD:IsValid() then
        ExecuteInGameThread(function()
            interfaceHUD:DispShortcutMenu(true)
            EquipPlayerWeapon(equipmentChangeOriginalWeapon, equipmentChangeOriginalBullet)
            EquipPlayerShards(equipmentChangeOriginalTrigger, equipmentChangeOriginalEffective, equipmentChangeOriginalDirectional, equipmentChangeOriginalEnchant, equipmentChangeOriginalFamiliar)
        end)
    end
    UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", equipmentChangeUnpausePreHook, equipmentChangeUnpausePostHook)
    UnregisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ChangeCurrentShortcut", equipmentChangeShortcutPreHook, equipmentChangeShortcutPostHook)
    EndTimedEffect("ForceEquipment")
end

function EquipPlayerWeapon(weaponID, bulletID)
    local player = GetPlayerCharacter()
    player.CharacterInventory:SERVER_EquipToCurrentShortCut(6, weaponID)
    player.CharacterInventory:SERVER_EquipToCurrentShortCut(7, bulletID)
end

function EquipPlayerShards(triggerShardID, effectiveShardID, directionalShardID, enchantShardID, familiarShardID)
    local player = GetPlayerCharacter()
    player.CharacterInventory:SERVER_EquipToCurrentShortCut( 8, triggerShardID)
    player.CharacterInventory:SERVER_EquipToCurrentShortCut( 9, effectiveShardID)
    player.CharacterInventory:SERVER_EquipToCurrentShortCut(10, directionalShardID)
    player.CharacterInventory:SERVER_EquipToCurrentShortCut(11, enchantShardID)
    player.CharacterInventory:SERVER_EquipToCurrentShortCut(12, familiarShardID)
end

function UnequipPlayerWeapon()
    local player = GetPlayerCharacter()
    for index = 6,7,1 do
        player.CharacterInventory:SERVER_EquipToCurrentShortCut(index, nullName)
    end
end

function UnequipPlayerShards()
    local player = GetPlayerCharacter()
    for index = 8,12,1 do
        player.CharacterInventory:SERVER_EquipToCurrentShortCut(index, nullName)
    end
end

function RandomEquipment(equipmentList)
    local validEquipment = {}
    local count = 0
    for index = 1,#equipmentList,1 do
        if equipmentList[index].Num >= 0 then
            count = count + 1
            validEquipment[count] = equipmentList[index].ID
        end
    end
    if #validEquipment > 0 then
        return RandomChoice(validEquipment)
    end
    return nullName
end

function IsShardWindowOpen()
    local shardWindow = FindFirstOf("TutorialShardWindow_C")
    if shardWindow:IsValid() then
        return shardWindow:GetIsVisible()
    end
    return false
end

function HeavenOrHell()
    if heavenOrHellActive then return false end
    heavenOrHellActive = true
    local player = GetPlayerCharacter()
    local isInvincible = math.random() < 0.5
    NotifyCrowdControlCommand("Heaven or Hell")
    ModifyEquipSpecialAttribute({62, 63, 64, 65, 66, 67, 68, 69}, isInvincible and 100.0 or -100.0, false)
    heavenOrHellDamageEventPreHook, heavenOrHellDamageEventPostHook = RegisterHook("/Game/Core/Character/Common/Template/Step_Root.Step_Root_C:EnterDamaged1Event", function(self)
        if not isInvincible and GetClassName(self:get()) == GetClassName(player.Step) then
            ExecuteInGameThread(function() player.Step:Kill() end)
        end
    end)
    return true
end

function HeavenOrHellEnd()
    if not heavenOrHellActive then return end
    heavenOrHellActive = false
    RestoreEquipSpecialAttribute({62, 63, 64, 65, 66, 67, 68, 69})
    UnregisterHook("/Game/Core/Character/Common/Template/Step_Root.Step_Root_C:EnterDamaged1Event", heavenOrHellDamageEventPreHook, heavenOrHellDamageEventPostHook)
    EndTimedEffect("HeavenOrHell")
end

function ReturnBooks()
    local player = GetPlayerCharacter()
    local inventory = player.CharacterInventory
    if #inventory.myBorrowedBooks < 1 then return false end
    ExecuteInGameThread(function()
        NotifyCrowdControlCommand("Return Books")
        for index = 1,#inventory.myBorrowedBooks,1 do
            inventory:ReturnTheBook(inventory.myBorrowedBooks[1].ID)
        end
        PlayEnemySound("Vo_N2012_047_jp")
    end)
    return true
end

function CallTheLibrary()
    -- If OD has been defeated then simply warp to library
    if GetGameInstance():IsCompletedBoss(FName("N2012")) then
        if GetGameInstance():IsBossBattleNow() then return false end
        ExecuteInGameThread(function()
            NotifyCrowdControlCommand("Call The Library")
            GetGameInstance().pRoomManager:Warp(FName("m07LIB_009"), false, false, nullName, {})
        end)
        return true
    end
    -- Otherwise put OD on standby in the next save room entered
    if orlokStandbyActive then return false end
    orlokStandbyActive = true
    NotifyCrowdControlCommand("Call The Library")
    orlokStandbySaveRoomPreHook, orlokStandbySaveRoomPostHook = RegisterHook("/Game/Core/UI/Tutorial/TutorialAPI.TutorialAPI_C:OnSaveRoomEntered", function()
        if not GetGameInstance().LoadingManagerInstance:IsLoadingScreenVisible() then
            orlokStandbyActive = false
            ExecuteInGameThread(StartSaveRoomBoss)
            UnregisterHook("/Game/Core/UI/Tutorial/TutorialAPI.TutorialAPI_C:OnSaveRoomEntered", orlokStandbySaveRoomPreHook, orlokStandbySaveRoomPostHook)
        end
    end)
    return true
end

function CancelOrlokStandby()
    if not orlokStandbyActive then return end
    orlokStandbyActive = false
    UnregisterHook("/Game/Core/UI/Tutorial/TutorialAPI.TutorialAPI_C:OnSaveRoomEntered", orlokStandbySaveRoomPreHook, orlokStandbySaveRoomPostHook)
end

function StartSaveRoomBoss()
    local bossID = "N2012"
    local player = GetPlayerCharacter()
    -- Turn off room transitions
    GetGameInstance().pRoomManager:SetDisableRoomChangeByCameraOut(true)
    -- Turn off saving
    local saveBoxes = FindAllOf("PBSaveBox_BP_C")
    for index = 1,#saveBoxes,1 do
        saveBoxes[index].HasBeenUsed = true
    end
    -- Remove previous boss doors
    local bossDoors = FindAllOf("PBBossDoor_BP_C")
    if bossDoors ~= nil then
        for index = 1,#bossDoors,1 do
            if bossDoors[index].Tags[1] == FName("CC") then
                bossDoors[index]:K2_DestroyActor()
            end
        end
    end
    -- Spawn boss doors
    local doorClass = FindValidActorClass("/Game/Core/Environment/Gimmick/NewGimmicks/BossDoorBase/PBBossDoor_BP.PBBossDoor_BP_C")
    local doorPosX, doorPosZ = RelativeToAbsoluteLocation(0.0, 240.0)
    local leftDoor = GetGameInstance().pEventManager:CreateEventObject(doorClass, {X=doorPosX, Z=doorPosZ}, {}, player)
    leftDoor:K2_AddActorWorldRotation({Yaw=-180}, false, {}, false)
    leftDoor.InBossRoom = true
    leftDoor.BossId = FName(bossID)
    leftDoor.IsRight = false
    leftDoor.YScale = 2
    leftDoor.Tags[1] = FName("CC")
    local doorPosX, doorPosZ = RelativeToAbsoluteLocation(1260.0, 240.0)
    local rightDoor = GetGameInstance().pEventManager:CreateEventObject(doorClass, {X=doorPosX, Z=doorPosZ}, {}, player)
    rightDoor.InBossRoom = true
    rightDoor.BossId = FName(bossID)
    rightDoor.IsRight = true
    rightDoor.YScale = 2
    rightDoor.Tags[1] = FName("CC")
    -- Spawn OD
    local enemyLevel = CompletionToEnemyLevel(GetGameInstance().pMapManager:GetRoomTraverseRate({}))
    local bossPosX, bossPosZ = RelativeToAbsoluteLocation(630.0, 150.0)
    local bossOD = GetGameInstance().pCharacterManager:CreateCharacter(FName(bossID), "", {X=bossPosX, Z=bossPosZ}, {}, 1, "", nil, false)
    bossOD:SetEnemyLevel(enemyLevel)
    bossOD.CharacterStatus.m_TemporaryMaxHP = bossOD.CharacterStatus:GetMaxHitPoint()*1/3
    bossOD.CharacterStatus:RecoverHitPoint()
    bossOD.Experience = 0
    bossOD:SetActorHiddenInGame(true)
    bossOD:UtilityPause(true, 0)
    bossOD.Tags[1] = FName("CC")
    -- Only enable the boss once all doors are closed
    local orlokDoorPreId, orlokDoorPostId
    orlokDoorPreId, orlokDoorPostId = RegisterHook("/Game/Core/Environment/Gimmick/NewGimmicks/BossDoorBase/PBBossDoor_BP.PBBossDoor_BP_C:OnEnterState", function(self, param1, param2)
        if param1:get() == 2 and param2:get() == 3 then
            bossOD:UtilityPause(false, 0)
            ExecuteWithDelay(50, function()
                ExecuteInGameThread(function()
                    bossOD:SetActorHiddenInGame(false)
                    bossOD.Step:StartMist(0.0, true)
                    bossOD.Step:EndMist(1.0)
                end)
            end)
            player.m_SoundControlComponent:PlayBGM("BGM_siebel_battle", 0.0, 0)
            player.m_SoundControlComponent:CharaGroupLoad(bossOD, "VOICE", bossID)
            player.m_SoundControlComponent:CharaGroupLoad(bossOD, "ENEMY", bossID)
            UnregisterHook("/Game/Core/Environment/Gimmick/NewGimmicks/BossDoorBase/PBBossDoor_BP.PBBossDoor_BP_C:OnEnterState", orlokDoorPreId, orlokDoorPostId)
        end
    end)
    -- Watch the damage to despawn the boss before he truly dies
    local orlokDamagePreId, orlokDamagePostId
    orlokDamagePreId, orlokDamagePostId = RegisterHook("/Game/Core/Character/N2012/Data/Step_N2012.Step_N2012_C:OnDamaged", function()
        if GetCharacterHealthRatio(bossOD) <= 0.5 then
            EndSaveRoomBoss(bossOD)
            UnregisterHook("/Game/Core/Character/N2012/Data/Step_N2012.Step_N2012_C:OnDamaged", orlokDamagePreId, orlokDamagePostId)
        end
    end)
end

function EndSaveRoomBoss(bossOD)
    local player = GetPlayerCharacter()
    bossOD.Step:StartMist(1.0, true)
    ExecuteWithDelay(1000, function()
        -- Delete OD
        bossOD:K2_DestroyActor()
        player.m_SoundControlComponent:StopBGM(0.0)
        player.m_SoundControlComponent:CharaGroupRelease(bossOD)
        -- Turn saving back on
        local saveBoxes = FindAllOf("PBSaveBox_BP_C")
        for index = 1,#saveBoxes,1 do
            saveBoxes[index].HasBeenUsed = false
        end
        -- Turn room transitions back on
        GetGameInstance().pRoomManager:SetDisableRoomChangeByCameraOut(false)
    end)
end

function ModifyEquipSpecialAttribute(attributes, difference, multiply)
    local player = GetPlayerCharacter()
    local originalAttributes = {}
    local currentAttributes = {}
    for index = 1,#attributes,1 do
        originalAttributes[index] = player:GetEquipSpecialAttribute(attributes[index])
        modifyAttributeOriginalAttribute[attributes[index]] = originalAttributes[index]
        newAttribute = multiply and originalAttributes[index] * difference or originalAttributes[index] + difference
        player:SetEquipSpecialAttribute(attributes[index], newAttribute)
        currentAttributes[index] = newAttribute
    end
    -- Recalculate the stat if something caused it to be changed
    modifyAttributeUnpausePreHook[attributes[1]], modifyAttributeUnpausePostHook[attributes[1]] = RegisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", function() end, function()
        for index = 1,#attributes,1 do
            currentAttribute = player:GetEquipSpecialAttribute(attributes[index])
            if currentAttribute ~= currentAttributes[index] then
                originalAttributes[index] = player:GetEquipSpecialAttribute(attributes[index])
                modifyAttributeOriginalAttribute[attributes[index]] = originalAttributes[index]
                newAttribute = multiply and originalAttributes[index] * difference or originalAttributes[index] + difference
                player:SetEquipSpecialAttribute(attributes[index], newAttribute)
                currentAttributes[index] = newAttribute
            end
        end
    end)
    modifyAttributeShortcutPreHook[attributes[1]], modifyAttributeShortcutPostHook[attributes[1]] = RegisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ChangeCurrentShortcut", function() end, function()
        for index = 1,#attributes,1 do
            currentAttribute = player:GetEquipSpecialAttribute(attributes[index])
            if currentAttribute ~= currentAttributes[index] then
                originalAttributes[index] = player:GetEquipSpecialAttribute(attributes[index])
                modifyAttributeOriginalAttribute[attributes[index]] = originalAttributes[index]
                newAttribute = multiply and originalAttributes[index] * difference or originalAttributes[index] + difference
                player:SetEquipSpecialAttribute(attributes[index], newAttribute)
                currentAttributes[index] = newAttribute
            end
        end
    end)
    modifyAttributeBorrowPreHook[attributes[1]], modifyAttributeBorrowPostHook[attributes[1]] = RegisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:BorrowTheBook", function() end, function()
        for index = 1,#attributes,1 do
            currentAttribute = player:GetEquipSpecialAttribute(attributes[index])
            if currentAttribute ~= currentAttributes[index] then
                originalAttributes[index] = player:GetEquipSpecialAttribute(attributes[index])
                modifyAttributeOriginalAttribute[attributes[index]] = originalAttributes[index]
                newAttribute = multiply and originalAttributes[index] * difference or originalAttributes[index] + difference
                player:SetEquipSpecialAttribute(attributes[index], newAttribute)
                currentAttributes[index] = newAttribute
            end
        end
    end)
    modifyAttributeReturnPreHook[attributes[1]], modifyAttributeReturnPostHook[attributes[1]] = RegisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ReturnTheBook", function() end, function()
        for index = 1,#attributes,1 do
            currentAttribute = player:GetEquipSpecialAttribute(attributes[index])
            if currentAttribute ~= currentAttributes[index] then
                originalAttributes[index] = player:GetEquipSpecialAttribute(attributes[index])
                modifyAttributeOriginalAttribute[attributes[index]] = originalAttributes[index]
                newAttribute = multiply and originalAttributes[index] * difference or originalAttributes[index] + difference
                player:SetEquipSpecialAttribute(attributes[index], newAttribute)
                currentAttributes[index] = newAttribute
            end
        end
    end)
end

function RestoreEquipSpecialAttribute(attributes)
    local player = GetPlayerCharacter()
    if player:IsValid() then
        for index = 1,#attributes,1 do
            player:SetEquipSpecialAttribute(attributes[index], modifyAttributeOriginalAttribute[attributes[index]])
        end
    end
    UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", modifyAttributeUnpausePreHook[attributes[1]], modifyAttributeUnpausePostHook[attributes[1]])
    UnregisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ChangeCurrentShortcut", modifyAttributeShortcutPreHook[attributes[1]], modifyAttributeShortcutPostHook[attributes[1]])
    UnregisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:BorrowTheBook", modifyAttributeBorrowPreHook[attributes[1]], modifyAttributeBorrowPostHook[attributes[1]])
    UnregisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ReturnTheBook", modifyAttributeReturnPreHook[attributes[1]], modifyAttributeReturnPostHook[attributes[1]])
end

function PlayEnemySound(soundID)
    local player = GetPlayerCharacter()
    local splitSound = SplitString(soundID, "_")
    local category = splitSound[1] == "Vo" and "VOICE" or "ENEMY"
    local augment = splitSound[2]
    -- Need to do it twice for consistency
    GetGameInstance().pSoundManager:GroupLoad(category, augment)
    GetGameInstance().pSoundManager:PlaySEForBP(FName(soundID), player)
    GetGameInstance().pSoundManager:GroupRelease(category, augment)
    GetGameInstance().pSoundManager:GroupLoad(category, augment)
    GetGameInstance().pSoundManager:PlaySEForBP(FName(soundID), player)
    GetGameInstance().pSoundManager:GroupRelease(category, augment)
end

-- Update the Bunnymorphosis body scale if necessary
NotifyOnNewObject("/Script/ProjectBlood.PBBulletSubActorBase", function(ConstructedObject)
    if GetClassName(ConstructedObject) == "EffectiveChangeBunny_C" and sizeChangeActive then
        ConstructedObject.SK_ChangeBunny_Body:SetRelativeScale3D({X=sizeChangeCurrentModifier, Y=sizeChangeCurrentModifier, Z=sizeChangeCurrentModifier})
    end
end)

-- End all effects
function StopAllEffects()
    ShrinkPlayerEnd()
    GrowPlayerEnd()
    FlipPlayerEnd()
    ShuffleControlsEnd()
    UseWitchTimeEnd()
    TurboEnemiesEnd()
    UncontrollableSpeedEnd()
    CriticalModeEnd()
    GoldRushEnd()
    SummonRaveEnd()
    SummonDarknessEnd()
    ForceInvertEnd()
    NoSkillShardsEnd()
    WeaponsOnlyEnd()
    ShardsOnlyEnd()
    ForceEquipmentEnd()
    HeavenOrHellEnd()
    ResetRoomHistory()
    CancelOrlokStandby()
end

-- Stop all effects if the game goes to a loading screen
RegisterHook("/Script/ProjectBlood.PBLoadingManager:Init", function()
    ShrinkPlayerEnd()
    GrowPlayerEnd()
    FlipPlayerEnd()
    ShuffleControlsEnd()
    UseWitchTimeEnd()
    TurboEnemiesEnd()
    UncontrollableSpeedEnd()
    CriticalModeEnd()
    GoldRushEnd()
    SummonRaveEnd()
    SummonDarknessEnd()
    ForceInvertEnd()
    NoSkillShardsEnd()
    WeaponsOnlyEnd()
    ShardsOnlyEnd()
    ForceEquipmentEnd()
    HeavenOrHellEnd()
    ResetRoomHistory()
end)

-- Stop some effects before saving the game
RegisterHook("/Script/ProjectBlood.PBSaveManager:SaveGameToMemory", function()
    CriticalModeEnd()
    ForceInvertEnd()
    NoSkillShardsEnd()
    WeaponsOnlyEnd()
    ShardsOnlyEnd()
    ForceEquipmentEnd()
end)

-- Toggle CC notifications with F1
RegisterKeyBind(Key.F1, function()
    if CanExecuteCommand() then ToggleDisplayNotifications() end
end)

-- Try to connect to CC periodically
LoopAsync(10000, function()
    checkConn()
    return false
end)

-- Check effects used
LoopAsync(100, function()
    if not connected() then return false end
    
    local id, code, duration = getEffect()
    
    if code == "" then return false end
    
    local success, result = pcall(CanExecuteCommand)
    
    if not success then
        print(result)
        ccRespond(id, 1)
        return false
    end
    
    if not result then
        ccRespond(id, 3)
        return false
    end
    
    if timedEffects[code] ~= nil then
        ccRespond(id, 3)
        return false
    end
    
    local func = _G[code]
    
    if duration > 0 and _G[code .. "End"] == nil then
        success, result = pcall(func, duration)
    else
        success, result = pcall(func)
    end
    
    if not success then
        print(result)
        ccRespond(id, 1)
        return false
    end
    
    if not result then
        ccRespond(id, 3)
        return false
    end
    
    if duration > 0 then
        ccRespondTimed(id, 0, duration)
        timedEffects[code] = {["id"] = id, ["code"] = code, ["duration"] = duration}
    else
        ccRespond(id, 0)
    end
    
    print(code)
    return false
end)

-- Check timed effect status
LoopAsync(1000, function()
    if next(timedEffects) == nil then return false end
    -- Check if commands can be used
    local success, result = pcall(CanExecuteCommand)
    
    if not success then
        print(result)
        return false
    end
    
    local canExecute = result
    -- Loop through active timed effects
    for code, entry in pairs(timedEffects) do
        if canExecute then
            if timedEffectsWerePaused then ccRespondTimed(entry["id"], 7, entry["duration"]) end
            
            entry["duration"] = entry["duration"] - 1000
            if entry["duration"] <= 0 then
                -- Look if there is an extra function to check
                local checkCode = "Can" .. entry["code"] .. "End"
                local checkFunc = _G[checkCode]
                
                if checkFunc ~= nil then
                    success, result = pcall(checkFunc)
                else
                    success, result = true, true
                end
                
                -- Execute end function if it exists
                if success then
                    if result then
                        local endCode = entry["code"] .. "End"
                        local endFunc = _G[endCode]
                        
                        if endFunc ~= nil then
                            success, result = pcall(endFunc)
                            if not success then print(result) end
                        else
                            EndTimedEffect(code)
                        end
                    end
                else
                    print(result)
                end
            end
        else
            if not timedEffectsWerePaused then ccRespondTimed(entry["id"], 6, entry["duration"]) end
        end
    end
    
    timedEffectsWerePaused = not canExecute
    return false
end)

function EndTimedEffect(effectName)
    local entry = timedEffects[effectName]
    if entry ~= nil then
        ccRespondTimed(entry["id"], 8, 0)
        timedEffects[effectName] = nil
        print(entry["code"] .. "End")
    end
end