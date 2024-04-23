require("utility")
require("constant")
require("variable")

function CanExecuteCommand()
    local player = GetPlayerCharacter()
    local interfaceHUD = FindFirstOf("PBInterfaceHUD")
    if not IsInList({1, 6, 9}, gameInstance:GetGameModeType()) then return false end
    if not player:IsValid() then return false end
    if not IsCharacterAlive(player) then return false end 
    if not interfaceHUD:IsValid() then return false end
    if not interfaceHUD:GetGaugeWidget():GetIsVisible() then return false end
    if gameInstance.LoadingManagerInstance:IsLoadingScreenVisible() then return false end
    return true
end

function NotifyCrowdControlCommand(effectName)
    if not displayNotifications then return end
    local interfaceHUD = FindFirstOf("PBInterfaceHUD")
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
    NotifyCrowdControlCommand("Poison Player")
    player.Step:SetSpecialEffect(FName("Poison"))
    return true
end

function CursePlayer()
    local player = GetPlayerCharacter()
    if player:IsStatusCursed({}, {}) then return false end
    NotifyCrowdControlCommand("Curse Player")
    player.Step:SetSpecialEffect(FName("Curse"))
    return true
end

function PetrifyPlayer()
    local player = GetPlayerCharacter()
    if player:IsStatusStoned({}) then return false end
    NotifyCrowdControlCommand("Petrify Player")
    player.Step:SetSpecialEffect(FName("Stone"))
    return true
end

function SlowPlayerDown()
    local player = GetPlayerCharacter()
    if player:IsStatusSlowed({}, {}) then return false end
    NotifyCrowdControlCommand("Slow Player Down")
    player.Step:SetSpecialEffect(FName("Slow"))
    return true
end

function SlamPlayer()
    if heavenOrHellActive then return false end
    local player = GetPlayerCharacter()
    if player.CharacterStatus.HitPoint <= 1 then return false end
    if not player.Step:CanUpdateNextHitTimer() then return false end
    NotifyCrowdControlCommand("Slam Player")
    player:DirectDamageWithId(1.0, FName("N2008_BackStep"))
    return true
end

function EmptyHealth()
    local player = GetPlayerCharacter()
    if player.CharacterStatus.HitPoint <= 1 then return false end
    NotifyCrowdControlCommand("Empty Health")
    player.CharacterStatus:SetHitPointForce(1)
    return true
end

function EmptyMagic()
    local player = GetPlayerCharacter()
    if player.CharacterStatus.MagicPoint <= 1 then return false end
    NotifyCrowdControlCommand("Empty Magic")
    player.CharacterStatus:SetMagicPointForce(1)
    return true
end

function RefillHealth()
    local player = GetPlayerCharacter()
    if GetCharacterHealthRatio(player) >= 1.0 then return false end
    NotifyCrowdControlCommand("Refill Health")
    player.CharacterStatus:RecoverHitPoint()
    return true
end

function RefillMagic()
    local player = GetPlayerCharacter()
    if GetCharacterMagicRatio(player) >= 1.0 then return false end
    NotifyCrowdControlCommand("Refill Magic")
    player.CharacterStatus:RecoverMagicPoint()
    return true
end

function ShuffleColors()
    NotifyCrowdControlCommand("Shuffle Colors")
    local player = GetPlayerCharacter()
    -- Only shuffle colors and not haircuts to avoid crashes
    ExecuteInGameThread(function()
        for index = 1,6,1 do
            for subindex = 0,2,1 do
                player:SetChromaWheelColorScheme(index, {R=math.random(), G=math.random(), B=math.random()}, subindex, false, false, false)
            end
        end
        player:SetChromaWheelTrim(3, math.random(1, 36), false, false)
        gameInstance.m_SystemSettings:SetBloodColor(math.random(0, 11))
    end)
    return true
end

function FakeFlawlessWin()
    NotifyCrowdControlCommand("Fake Flawless Win")
    local player = GetPlayerCharacter()
    player.Step:NoticeBossBattleNoDamageWin(nullName)
    return true
end

function PlayDeathQuote()
    NotifyCrowdControlCommand("Play Death Quote")
    local player = GetPlayerCharacter()
    local chosenVoice = RandomChoice(voicelist)
    PrintToConsole("Played quote: " .. chosenVoice)
    PlayEnemySound(chosenVoice)
    return true
end

function ShrinkPlayer()
    if sizeChangeActive then return false end
    sizeChangeActive = true
    sizeChangeCurrentModifier = 0.5
    NotifyCrowdControlCommand("Shrink Player")
    SetPlayerScale(false)
    return true
end

function ShrinkPlayerEnd()
    if not sizeChangeActive then return end
    sizeChangeActive = false
    PrintToConsole("ShrinkPlayerEnd")
    if GetPlayerCharacter():IsValid() then SetPlayerScale(true) end
end

function GrowPlayer()
    if sizeChangeActive then return false end
    sizeChangeActive = true
    sizeChangeCurrentModifier = 1.5
    NotifyCrowdControlCommand("Grow Player")
    SetPlayerScale(false)
    return true
end

function GrowPlayerEnd()
    if not sizeChangeActive then return end
    sizeChangeActive = false
    PrintToConsole("GrowPlayerEnd")
    if GetPlayerCharacter():IsValid() then SetPlayerScale(true) end
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
    NotifyCrowdControlCommand("Flip Player")
    utility:SetLeftAnalogMirrorFlag(true)
    -- Switching rooms breaks it so enable it back
    flipPlayerRoomChangePreHook, flipPlayerRoomChangePostHook = RegisterHook("/Script/ProjectBlood.PBRoomVolume:OnRoomVolumeOverlapEnd", function()
        utility:SetLeftAnalogMirrorFlag(true)
    end)
    return true
end

function FlipPlayerEnd()
    if not flipPlayerActive then return end
    flipPlayerActive = false
    PrintToConsole("FlipPlayerEnd")
    utility:SetLeftAnalogMirrorFlag(false)
    UnregisterHook("/Script/ProjectBlood.PBRoomVolume:OnRoomVolumeOverlapEnd", flipPlayerRoomChangePreHook, flipPlayerRoomChangePostHook)
end

function ShuffleControls()
    if shuffleControlsActive then return false end
    shuffleControlsActive = true
    NotifyCrowdControlCommand("Shuffle Controls")
    local player = GetPlayerCharacter()
    local configManager = player:GetConfigManager()
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
    gameInstance.m_SystemSettings:BindToGamepad_NO_CHECK(0, currentAttack)
    gameInstance.m_SystemSettings:BindToGamepad_NO_CHECK(1, currentBackstep)
    gameInstance.m_SystemSettings:BindToGamepad_NO_CHECK(2, currentJump)
    gameInstance.m_SystemSettings:BindToGamepad_NO_CHECK(3, currentTrigger)
    gameInstance.m_SystemSettings:BindToGamepad_NO_CHECK(4, currentDirectional)
    gameInstance.m_SystemSettings:BindToGamepad_NO_CHECK(5, currentEffective)
    gameInstance.m_SystemSettings:BindToGamepad_NO_CHECK(7, currentShortcut)
    -- Prevent the player from changing them back
    shuffleControlsUnpausePreHook, shuffleControlsUnpausePostHook = RegisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", function()
        gameInstance.m_SystemSettings:BindToGamepad_NO_CHECK(0, currentAttack)
        gameInstance.m_SystemSettings:BindToGamepad_NO_CHECK(1, currentBackstep)
        gameInstance.m_SystemSettings:BindToGamepad_NO_CHECK(2, currentJump)
        gameInstance.m_SystemSettings:BindToGamepad_NO_CHECK(3, currentTrigger)
        gameInstance.m_SystemSettings:BindToGamepad_NO_CHECK(4, currentDirectional)
        gameInstance.m_SystemSettings:BindToGamepad_NO_CHECK(5, currentEffective)
        gameInstance.m_SystemSettings:BindToGamepad_NO_CHECK(7, currentShortcut)
    end)
    return true
end

function ShuffleControlsEnd()
    if not shuffleControlsActive then return end
    shuffleControlsActive = false
    PrintToConsole("ShuffleControlsEnd")
    gameInstance.m_SystemSettings:BindToGamepad_NO_CHECK(0, shuffleControlsOriginalAttack)
    gameInstance.m_SystemSettings:BindToGamepad_NO_CHECK(1, shuffleControlsOriginalBackstep)
    gameInstance.m_SystemSettings:BindToGamepad_NO_CHECK(2, shuffleControlsOriginalJump)
    gameInstance.m_SystemSettings:BindToGamepad_NO_CHECK(3, shuffleControlsOriginalTrigger)
    gameInstance.m_SystemSettings:BindToGamepad_NO_CHECK(4, shuffleControlsOriginalDirectional)
    gameInstance.m_SystemSettings:BindToGamepad_NO_CHECK(5, shuffleControlsOriginalEffective)
    gameInstance.m_SystemSettings:BindToGamepad_NO_CHECK(7, shuffleControlsOriginalShortcut)
    UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", shuffleControlsUnpausePreHook, shuffleControlsUnpausePostHook)
end

function UseWitchTime()
    if useWitchTimeActive then return false end
    if turboEnemiesActive then return false end
    useWitchTimeActive = true
    NotifyCrowdControlCommand("Use Witch Time")
    local player = GetPlayerCharacter()
    local rate = 0.25
    utility:PBCategorySlomo(1, 0, rate, player)
    utility:PBCategorySlomo(2, 0, rate, player)
    utility:PBCategorySlomo(3, 0, rate, player)
    utility:PBCategorySlomo(4, 0, rate, player)
    utility:PBActorSlomo(player, 0, 1.0)
    return true
end

function UseWitchTimeEnd()
    if not useWitchTimeActive then return end
    useWitchTimeActive = false
    PrintToConsole("UseWitchTimeEnd")
    local player = GetPlayerCharacter()
    if player:IsValid() then utility:PBCategorySlomo(7, 0, 1.0, player) end
end

function TurboEnemies()
    if turboEnemiesActive then return false end
    if useWitchTimeActive then return false end
    turboEnemiesActive = true
    NotifyCrowdControlCommand("Turbo Enemies")
    local rate = 2.0
    local player = GetPlayerCharacter()
    utility:PBCategorySlomo(1, 0, rate, player)
    utility:PBActorSlomo(player, 0, 1.0)
    return true
end

function TurboEnemiesEnd()
    if not turboEnemiesActive then return end
    turboEnemiesActive = false
    PrintToConsole("UseWitchTimeEnd")
    local player = GetPlayerCharacter()
    if player:IsValid() then utility:PBCategorySlomo(7, 0, 1.0, player) end
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
    PrintToConsole("UncontrollableSpeedEnd")
    RestoreEquipSpecialAttribute({15, 16, 22})
end

function CriticalMode()
    if criticalModeActive then return false end
    criticalModeActive = true
    NotifyCrowdControlCommand("Critical Mode")
    local player = GetPlayerCharacter()
    ModifyEquipSpecialAttribute({8}, 999.0, false)
    player:SetEquipSpecialAttribute(107, -999.0)
    player:SetEquipSpecialAttribute(108, -999.0)
    return true
end

function CriticalModeEnd()
    if not criticalModeActive then return end
    criticalModeActive = false
    PrintToConsole("CriticalModeEnd")
    RestoreEquipSpecialAttribute({8})
    local player = GetPlayerCharacter()
    if player:IsValid() then
        player:SetEquipSpecialAttribute(107, 0.0)
        player:SetEquipSpecialAttribute(108, 0.0)
    end
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
        if color.R == 1.0 and color.G== 1.0 and color.B == 1.0 then
            local coinModifier = math.max(0.1, gameInstance.totalCoins/6666)
            local compModifier = Lerp(0.1, 1, gameInstance.pMapManager:GetRoomTraverseRate({})/100)
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
    PrintToConsole("GoldRushEnd")
    gameInstance:SetTotalCoin(goldRushMoneyGain)
    if goldRushDamagePopup:IsValid() then goldRushDamagePopup:RemoveFromViewport() end
    if GetPlayerCharacter():IsValid() then PlayEnemySound(goldRushMoneyGain > 0 and "SE_N1004_Coin02" or "Vo_N1004_040_jp") end
    UnregisterHook("/Game/Core/UI/HUD/Damage/DamagePopup.DamagePopup_C:CustomDamageEvent", goldRushDamagePopupPreHook, goldRushDamagePopupPostHook)
end

function UseWaystone()
    if gameInstance:IsBossBattleNow() then return false end
    NotifyCrowdControlCommand("Use Waystone")
    local player = GetPlayerCharacter()
    player.Step:SetSpecialEffect(FName("WayStone"))
    return true
end

function UseRosario()
    local hasFoundTarget = false
    local actorInstances = FindAllOf("PBBaseCharacter")
    -- All enemies found will be defeated instantly
    -- All bosses found will be dealt 15% of health
    for index = 1,#actorInstances,1 do
        local actor = actorInstances[index]
        if actor:IsValid() then
            if actor.OnTheScreen and IsCharacterAlive(actor) then
                if actor:IsBoss()then
                    actor:DirectDamage(math.floor(actor.CharacterStatus:GetMaxHitPoint()*0.15))
                    hasFoundTarget = true
                elseif actor:IsEnemy() then
                    actor:DirectDamage(actor.CharacterStatus.HitPoint)
                    hasFoundTarget = true
                end
            end
        end
    end
    if hasFoundTarget then
        NotifyCrowdControlCommand("Use Rosario")
        ScreenFlash(0.3)
    end
    return hasFoundTarget
end

function ScreenFlash(duration)
    local player = GetPlayerCharacter()
    local cameraManager = gameplayStatics:GetPlayerCameraManager(player, 0)
    local subDuration = duration/2
    cameraManager:StartCameraFade(0.0, 1.0, subDuration, {R=1.0, G=1.0, B=1.0}, false, true)
    ExecuteWithDelay(math.floor(subDuration*1000), function() cameraManager:StartCameraFade(1.0, 0.0, subDuration, {R=1.0, G=1.0, B=1.0}, false, false) end)
end

function RewindTime()
    if gameInstance:IsBossBattleNow() then return false end
    -- Warp in the last valid room traversed, 2 rooms back at most
    local chosenRoom
    if     previousRoom2 ~= nullName and not IsInList(rotatingRooms, previousRoom2:ToString()) then
        chosenRoom = previousRoom2
    elseif previousRoom1 ~= nullName and not IsInList(rotatingRooms, previousRoom1:ToString()) then
        chosenRoom = previousRoom1
    else return false end
    NotifyCrowdControlCommand("Rewind Time")
    ExecuteInGameThread(function() gameInstance.pRoomManager:Warp(chosenRoom, false, false, nullName, {}) end)
    return true
end

function SummonAmbush()
    if IsInList(rotatingRooms, currentRoom:ToString()) then return false end
    NotifyCrowdControlCommand("Summon Ambush")
    local player = GetPlayerCharacter()
    local playerLocation = player:K2_GetActorLocation()
    local chosenEnemy = RandomChoice(enemylist)
    local enemyLevel = gameInstance.pMapManager:GetRoomTraverseRate({})//2
    PrintToConsole("Spawned enemy: " .. chosenEnemy)
    -- Spawn 2 of the same random enemy with their levels scaling with map completion
    ExecuteInGameThread(function()
        local enemy1 = gameInstance.pCharacterManager:CreateCharacter(FName(chosenEnemy), "", {X = playerLocation.X + 420, Y = playerLocation.Y, Z = playerLocation.Z}, {}, 1, "", nil, false)
        local enemy2 = gameInstance.pCharacterManager:CreateCharacter(FName(chosenEnemy), "", {X = playerLocation.X - 420, Y = playerLocation.Y, Z = playerLocation.Z}, {}, 1, "", nil, false)
        if not enemy1:IsValid() or not enemy2:IsValid() then return false end
        enemy1:SetCharacterWorldRotation(180.0, 0.0)
        enemy1:SetEnemyLevel(ClampValue(enemyLevel, 1, 50))
        enemy1.CharacterStatus:RecoverHitPoint()
        enemy1.Experience = 0
        enemy2:SetEnemyLevel(ClampValue(enemyLevel, 1, 50))
        enemy2.CharacterStatus:RecoverHitPoint()
        enemy2.Experience = 0
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
    NotifyCrowdControlCommand("Summon Rave")
    local timer = 0
    local progress = 0
    local fullcycle = 1500
    local deltaSeconds = gameplayStatics:GetWorldDeltaSeconds(postProcess)
    postProcess.Settings.bOverride_ColorGain = 1
    -- Cycle through color gains
    LoopAsync(math.floor(deltaSeconds*1000), function()
        if summonRaveShouldStopEffect or not postProcess:IsValid() then return true end
        ExecuteInGameThread(function()
            timer = timer + deltaSeconds*1000
            progress = timer%fullcycle
            color = mathLibrary:HSVToRGB(progress/fullcycle*360, 0.75, 1.0, 1.0)
            postProcess.Settings.ColorGain = {X=color.R, Y=color.G, Z=color.B}
        end)
        return false
    end)
    return true
end

function SummonRaveEnd()
    if not summonRaveActive then return end
    summonRaveActive = false
    summonRaveShouldStopEffect = true
    PrintToConsole("SummonRaveEnd")
    local postProcess = FindFirstOf("PostProcessVolume")
    if postProcess:IsValid() then
        postProcess.Settings.bOverride_ColorGain = 0
        postProcess.Settings.ColorGain = {X=1.0, Y=1.0, Z=1.0}
    end
end

function SummonDarkness()
    if summonDarknessActive then return false end
    if summonRaveActive then return false end
    local postProcess = FindFirstOf("PostProcessVolume")
    if not postProcess:IsValid() then return false end
    summonDarknessActive = true
    NotifyCrowdControlCommand("Summon Darkness")
    postProcess.Settings.bOverride_VignetteIntensity = 1
    postProcess.Settings.VignetteIntensity = 5.0
    return true
end

function SummonDarknessEnd()
    if not summonDarknessActive then return end
    summonDarknessActive = false
    PrintToConsole("SummonDarknessEnd")
    local postProcess = FindFirstOf("PostProcessVolume")
    if postProcess:IsValid() then
        postProcess.Settings.bOverride_VignetteIntensity = 0
        postProcess.Settings.VignetteIntensity = 0.0
    end
end

function TriggerEarthquake(duration)
    local player = GetPlayerCharacter()
    NotifyCrowdControlCommand("Trigger Earthquake")
    player.Step:CameraShake(duration/1000, 0.15, 60.0, 0.3, 40.0, 0.0, 0.0, player.criticalForceFeedback, nullName, false, nullName)
    return true
end

function ForceInvert()
    if forceInvertActive then return false end
    forceInvertActive = true
    NotifyCrowdControlCommand("Force Invert")
    local player = GetPlayerCharacter()
    local inventory = player.CharacterInventory
    if not eventUtility:IsInvertedByPlayerCharacter(0) then player.Step:BeginInvert() end
    inventory:SetSkillOnOff(FName("Invert"), false)
    -- Prevent the player from enabling it back
    forceInvertUnpausePreHook, forceInvertUnpausePostHook = RegisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", function()
        inventory:SetSkillOnOff(FName("Invert"), false)
    end)
    return true
end

function ForceInvertEnd()
    if not forceInvertActive then return end
    forceInvertActive = false
    PrintToConsole("ForceInvertEnd")
    local player = GetPlayerCharacter()
    local inventory = player.CharacterInventory
    if player:IsValid() then
        if eventUtility:IsInvertedByPlayerCharacter(0) then player.Step:BeginInvert() end
        if ItemInInventory(inventory.mySkills, "Invert") then inventory:SetSkillOnOff(FName("Invert"), true) end
    end
    UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", forceInvertUnpausePreHook, forceInvertUnpausePostHook)
end

function NoSkillShards()
    if noSkillShardsActive then return false end
    noSkillShardsActive = true
    NotifyCrowdControlCommand("No Skill Shards")
    SetAllSkillOnOff(false)
    -- Prevent the player from enabling them back
    noSkillShardsUnpausePreHook, noSkillShardsUnpausePostHook = RegisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", function()
        SetAllSkillOnOff(false)
    end)
    return true
end

function NoSkillShardsEnd()
    if not noSkillShardsActive then return end
    noSkillShardsActive = false
    PrintToConsole("NoSkillShardsEnd")
    if GetPlayerCharacter():IsValid() then SetAllSkillOnOff(true) end
    UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", noSkillShardsUnpausePreHook, noSkillShardsUnpausePostHook)
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
    weaponsOnlyActive = true
    NotifyCrowdControlCommand("Weapons Only")
    local player = GetPlayerCharacter()
    local inventory = player.CharacterInventory
    local interfaceHUD = FindFirstOf("PBInterfaceHUD")
    equipmentChangeOriginalTrigger = inventory.netEquipment.TriggerShard
    equipmentChangeOriginalEffective = inventory.netEquipment.EffectiveShard
    equipmentChangeOriginalDirectional = inventory.netEquipment.DirectionalShard
    equipmentChangeOriginalEnchant = inventory.netEquipment.EnchantShard
    equipmentChangeOriginalFamiliar = inventory.netEquipment.FamiliarShard
    ExecuteInGameThread(function()
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

function WeaponsOnlyEnd()
    if not weaponsOnlyActive then return end
    weaponsOnlyActive = false
    PrintToConsole("WeaponsOnlyEnd")
    local interfaceHUD = FindFirstOf("PBInterfaceHUD")
    if interfaceHUD:IsValid() then
        ExecuteInGameThread(function()
            interfaceHUD:DispShortcutMenu(true)
            EquipPlayerShards(equipmentChangeOriginalTrigger, equipmentChangeOriginalEffective, equipmentChangeOriginalDirectional, equipmentChangeOriginalEnchant, equipmentChangeOriginalFamiliar)
        end)
    end
    UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", equipmentChangeUnpausePreHook, equipmentChangeUnpausePostHook)
    UnregisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ChangeCurrentShortcut", equipmentChangeShortcutPreHook, equipmentChangeShortcutPostHook)
end

function ShardsOnly()
    if shardsOnlyActive then return false end
    if weaponsOnlyActive then return false end
    if forceEquipmentActive then return false end
    shardsOnlyActive = true
    NotifyCrowdControlCommand("Shards Only")
    local player = GetPlayerCharacter()
    local inventory = player.CharacterInventory
    local interfaceHUD = FindFirstOf("PBInterfaceHUD")
    equipmentChangeOriginalWeapon = inventory.netEquipment.weapon
    equipmentChangeOriginalBullet = inventory.netEquipment.Bullet
    ExecuteInGameThread(function()
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

function ShardsOnlyEnd()
    if not shardsOnlyActive then return end
    shardsOnlyActive = false
    PrintToConsole("ShardsOnlyEnd")
    local interfaceHUD = FindFirstOf("PBInterfaceHUD")
    if interfaceHUD:IsValid() then
        ExecuteInGameThread(function()
            interfaceHUD:DispShortcutMenu(true)
            EquipPlayerWeapon(equipmentChangeOriginalWeapon, equipmentChangeOriginalBullet)
        end)
    end
    UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", equipmentChangeUnpausePreHook, equipmentChangeUnpausePostHook)
    UnregisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ChangeCurrentShortcut", equipmentChangeShortcutPreHook, equipmentChangeShortcutPostHook)
end

function ForceEquipment()
    if forceEquipmentActive then return false end
    if weaponsOnlyActive then return false end
    if shardsOnlyActive then return false end
    forceEquipmentActive = true
    NotifyCrowdControlCommand("Force Equipment")
    local player = GetPlayerCharacter()
    local inventory = player.CharacterInventory
    local interfaceHUD = FindFirstOf("PBInterfaceHUD")
    equipmentChangeOriginalWeapon = inventory.netEquipment.weapon
    equipmentChangeOriginalBullet = inventory.netEquipment.Bullet
    equipmentChangeOriginalTrigger = inventory.netEquipment.TriggerShard
    equipmentChangeOriginalEffective = inventory.netEquipment.EffectiveShard
    equipmentChangeOriginalDirectional = inventory.netEquipment.DirectionalShard
    equipmentChangeOriginalEnchant = inventory.netEquipment.EnchantShard
    equipmentChangeOriginalFamiliar = inventory.netEquipment.FamiliarShard
    local currentWeapon = RandomEquipment(inventory.myWeapons)
    local currentBullet = RandomEquipment(inventory.myBullets)
    local currentTriggerShard = RandomEquipment(inventory.myTriggerShards)
    local currentEffectiveShard = RandomEquipment(inventory.myEffectiveShards)
    local currentDirectionalShard = RandomEquipment(inventory.myDirectionalShards)
    local currentEnchantShard = RandomEquipment(inventory.myEnchantShards)
    local currentFamiliarShard = RandomEquipment(inventory.myFamiliarShards)
    PrintToConsole("Forced weapon: " .. currentWeapon:ToString())
    PrintToConsole("Forced bullet: " .. currentBullet:ToString())
    PrintToConsole("Forced trigger shard: " .. currentTriggerShard:ToString())
    PrintToConsole("Forced effective shard: " .. currentEffectiveShard:ToString())
    PrintToConsole("Forced directional shard: " .. currentDirectionalShard:ToString())
    PrintToConsole("Forced enchant shard: " .. currentEnchantShard:ToString())
    PrintToConsole("Forced familiar shard: " .. currentFamiliarShard:ToString())
    ExecuteInGameThread(function()
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

function ForceEquipmentEnd()
    if not forceEquipmentActive then return end
    forceEquipmentActive = false
    PrintToConsole("ForceEquipmentEnd")
    local interfaceHUD = FindFirstOf("PBInterfaceHUD")
    if interfaceHUD:IsValid() then
        ExecuteInGameThread(function()
            interfaceHUD:DispShortcutMenu(true)
            EquipPlayerWeapon(equipmentChangeOriginalWeapon, equipmentChangeOriginalBullet)
            EquipPlayerShards(equipmentChangeOriginalTrigger, equipmentChangeOriginalEffective, equipmentChangeOriginalDirectional, equipmentChangeOriginalEnchant, equipmentChangeOriginalFamiliar)
        end)
    end
    UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", equipmentChangeUnpausePreHook, equipmentChangeUnpausePostHook)
    UnregisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ChangeCurrentShortcut", equipmentChangeShortcutPreHook, equipmentChangeShortcutPostHook)
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

function HeavenOrHell()
    if heavenOrHellActive then return false end
    heavenOrHellActive = true
    NotifyCrowdControlCommand("Heaven or Hell")
    local player = GetPlayerCharacter()
    local isInvincible = math.random() < 0.5
    ModifyEquipSpecialAttribute({62, 63, 64, 65, 66, 67, 68, 69}, isInvincible and 100.0 or -100.0, false)
    heavenOrHellDamageEventPreHook, heavenOrHellDamageEventPostHook = RegisterHook("/Game/Core/Character/Common/Template/Step_Root.Step_Root_C:EnterDamaged1Event", function(self)
        if not isInvincible and GetClassName(self:get()) == GetClassName(player.Step) then player.Step:Kill() end
    end)
    return true
end

function HeavenOrHellEnd()
    if not heavenOrHellActive then return end
    heavenOrHellActive = false
    PrintToConsole("HeavenOrHellEnd")
    RestoreEquipSpecialAttribute({62, 63, 64, 65, 66, 67, 68, 69})
    UnregisterHook("/Game/Core/Character/Common/Template/Step_Root.Step_Root_C:EnterDamaged1Event", heavenOrHellDamageEventPreHook, heavenOrHellDamageEventPostHook)
end

function ReturnBooks()
    local player = GetPlayerCharacter()
    local inventory = player.CharacterInventory
    if #inventory.myBorrowedBooks < 1 then return false end
    NotifyCrowdControlCommand("Return Books")
    for index = 1,#inventory.myBorrowedBooks,1 do
        inventory:ReturnTheBook(inventory.myBorrowedBooks[1].ID)
    end
    PlayEnemySound("Vo_N2012_047_jp")
    return true
end

function CallTheLibrary()
    -- If OD has been defeated then simply warp to library
    if gameInstance:IsCompletedBoss(FName("N2012")) then
        if gameInstance:IsBossBattleNow() then return false end
        NotifyCrowdControlCommand("Call The Library")
        ExecuteInGameThread(function() gameInstance.pRoomManager:Warp(FName("m07LIB_009"), false, false, nullName, {}) end)
        return true
    end
    -- Otherwise put OD on standby in the next save room entered
    if orlokStandbyActive then return false end
    orlokStandbyActive = true
    NotifyCrowdControlCommand("Call The Library")
    orlokStandbySaveRoomPreHook, orlokStandbySaveRoomPostHook = RegisterHook("/Game/Core/UI/Tutorial/TutorialAPI.TutorialAPI_C:OnSaveRoomEntered", function()
        if not gameInstance.LoadingManagerInstance:IsLoadingScreenVisible() then
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
    local playerLocation = player:K2_GetActorLocation()
    -- Turn off room transitions
    gameInstance.pRoomManager:SetDisableRoomChangeByCameraOut(true)
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
    local leftDoor = gameInstance.pEventManager:CreateEventObject(doorClass, {X=doorPosX, Z=doorPosZ}, {}, player)
    leftDoor:K2_AddActorWorldRotation({Yaw=-180}, false, {}, false)
    leftDoor.InBossRoom = true
    leftDoor.BossId = FName(bossID)
    leftDoor.IsRight = false
    leftDoor.YScale = 2
    leftDoor.Tags[1] = FName("CC")
    local doorPosX, doorPosZ = RelativeToAbsoluteLocation(1260.0, 240.0)
    local rightDoor = gameInstance.pEventManager:CreateEventObject(doorClass, {X=doorPosX, Z=doorPosZ}, {}, player)
    rightDoor.InBossRoom = true
    rightDoor.BossId = FName(bossID)
    rightDoor.IsRight = true
    rightDoor.YScale = 2
    rightDoor.Tags[1] = FName("CC")
    -- Spawn OD
    local enemyLevel = gameInstance.pMapManager:GetRoomTraverseRate({})//2
    local bossPosX, bossPosZ = RelativeToAbsoluteLocation(630.0, 120.0)
    local bossOD = gameInstance.pCharacterManager:CreateCharacter(FName(bossID), "", {X=bossPosX, Z=bossPosZ}, {}, 1, "", nil, false)
    bossOD:SetEnemyLevel(ClampValue(enemyLevel, 1, 50))
    bossOD.CharacterStatus:RecoverHitPoint()
    bossOD.Experience = 0
    player.m_SoundControlComponent:PlayBGM("BGM_siebel_battle", 0.0, 0)
    player.m_SoundControlComponent:CharaGroupLoad(bossOD, "VOICE", bossID)
    player.m_SoundControlComponent:CharaGroupLoad(bossOD, "ENEMY", bossID)
    -- Watch the damage to despawn the boss before he truly dies
    local preId, postId
    preId, postId = RegisterHook("/Game/Core/Character/N2012/Data/Step_N2012.Step_N2012_C:OnDamaged", function()
        if GetCharacterHealthRatio(bossOD) <= 1/3 then
            EndSaveRoomBoss(bossOD)
            UnregisterHook("/Game/Core/Character/N2012/Data/Step_N2012.Step_N2012_C:OnDamaged", preId, postId)
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
        gameInstance.pRoomManager:SetDisableRoomChangeByCameraOut(false)
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
    UnregisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:BorrowTheBook", modifyAttributeBorrowPreHook[attributes[1]], modifyAttributeBorrowPostHook[attributes[1]])
    UnregisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ChangeCurrentShortcut", modifyAttributeShortcutPreHook[attributes[1]], modifyAttributeShortcutPostHook[attributes[1]])
end

function PlayEnemySound(soundID)
    local player = GetPlayerCharacter()
    local splitSound = SplitString(soundID, "_")
    local category = splitSound[1] == "Vo" and "VOICE" or "ENEMY"
    local augment = splitSound[2]
    -- Need to do it twice for consistency
    gameInstance.pSoundManager:GroupLoad(category, augment)
    gameInstance.pSoundManager:PlaySEForBP(FName(soundID), player)
    gameInstance.pSoundManager:GroupRelease(category, augment)
    gameInstance.pSoundManager:GroupLoad(category, augment)
    gameInstance.pSoundManager:PlaySEForBP(FName(soundID), player)
    gameInstance.pSoundManager:GroupRelease(category, augment)
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
    ToggleDisplayNotifications()
end)

function isReady()
    return CanExecuteCommand()
end

timed = {}

LoopAsync(10000, function()
    checkConn()
    return false
end)

LoopAsync(50, function()
    if not connected() then return false end
    
    id, code, dur = getEffect()
    
    if code == "" then
        return false
    end
    
    local status, ready = pcall(isReady)
    
    if not status or not ready then
        ccRespond(id, 3)
        return false
    end
    
    if dur > 0 then
        local rec = timed[code]
        if rec ~= nil then 
            ccRespond(id, 3)
            return false
        end
    end
    
    print(code)
    local func =_G[code]
    
    if pcall(function()
        if func ~= nil then
            local res = nil
            if code == "TriggerEarthquake" then
                res = func(dur)
            else
                res = func()
            end
            if res then
                if dur > 0 then
                    ccRespondTimed(id, 0, dur)
                    local entry = {}
                    entry["id"] = id
                    entry["dur"] = dur
                    entry["code"] = code
                    timed[code] = entry
                else
                    ccRespond(id, 0)
                end
            else
                ccRespond(id, 3)
            end
        end
    end) then
        
    else
        ccRespond(id, 3)
    end
    return false
end)

LoopAsync(250, function()
    for code, entry in pairs(timed) do
        entry["dur"] = entry["dur"] - 250
        if entry["dur"] <= 0 then
            local code = entry["code"] .. "End"
            
            local func =_G[code]
            
            if func == nil or pcall(func) then
                ccRespondTimed(entry["id"], 8, 0)
                timed[entry["code"]] = nil
            end
        end
    end
    return false
end)