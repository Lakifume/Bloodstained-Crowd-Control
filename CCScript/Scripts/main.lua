print("Loading CC script")

require("utility")
require("constant")

local displayNotifications = true
local timeDilationActive = false
local postProcessActive = false
local equipmentChangeActive = false
local orlokStandbyActive = false

function CanExecuteCommand()
    local player = GetPlayerCharacter()
	local interfaceHUD = FindFirstOf("PBInterfaceHUD")
	if not IsInList({1, 6, 9}, gameInstance:GetGameModeType()) then return false end
	if not player:IsValid() then return false end
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
	NotifyCrowdControlCommand("Poison Player")
    local player = GetPlayerCharacter()
    player.Step:SetSpecialEffect(FName("Poison"))
	return true
end

function CursePlayer()
	NotifyCrowdControlCommand("Curse Player")
    local player = GetPlayerCharacter()
    player.Step:SetSpecialEffect(FName("Curse"))
	return true
end

function PetrifyPlayer()
	NotifyCrowdControlCommand("Petrify Player")
    local player = GetPlayerCharacter()
    player.Step:SetSpecialEffect(FName("Stone"))
	return true
end

function SlowPlayerDown()
	NotifyCrowdControlCommand("Slow Player Down")
    local player = GetPlayerCharacter()
    player.Step:SetSpecialEffect(FName("Slow"))
	return true
end

function UseWaystone()
	if gameInstance:IsBossBattleNow() then return false end
	NotifyCrowdControlCommand("Use Waystone")
    local player = GetPlayerCharacter()
    player.Step:SetSpecialEffect(FName("WayStone"))
	return true
end

function EmptyHealth()
	NotifyCrowdControlCommand("Empty Health")
    local player = GetPlayerCharacter()
    player.CharacterStatus:SetHitPointForce(1)
	return true
end

function EmptyMagic()
	NotifyCrowdControlCommand("Empty Magic")
    local player = GetPlayerCharacter()
    player.CharacterStatus:SetMagicPointForce(1)
	return true
end

function RefillHealth()
	NotifyCrowdControlCommand("Refill Health")
    local player = GetPlayerCharacter()
    player.CharacterStatus:RecoverHitPoint()
	return true
end

function RefillMagic()
	NotifyCrowdControlCommand("Refill Magic")
    local player = GetPlayerCharacter()
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
	PlayEnemySound(chosenVoice)
	print("Played quote: " .. chosenVoice)
	return true
end

function FlipPlayer(duration)
	NotifyCrowdControlCommand("Flip Player")
	local shouldStopEffect = false
    utility:SetLeftAnalogMirrorFlag(true)
	-- Switching rooms breaks it so enable it back
    local preId1, postId1 = RegisterHook("/Script/ProjectBlood.PBRoomVolume:OnRoomVolumeOverlapEnd", function()
        utility:SetLeftAnalogMirrorFlag(true)
    end)
	local preId2, postId2
	-- End effect after delay
    ExecuteWithDelay(duration, function()
		if shouldStopEffect then return end
        utility:SetLeftAnalogMirrorFlag(false)
		UnregisterHook("/Script/ProjectBlood.PBRoomVolume:OnRoomVolumeOverlapEnd", preId1, postId1)
		UnregisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", preId2, postId2)
    end)
	-- Stop effect early if necessary
	preId2, postId2 = RegisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", function()
		shouldStopEffect = true
        utility:SetLeftAnalogMirrorFlag(false)
		UnregisterHook("/Script/ProjectBlood.PBRoomVolume:OnRoomVolumeOverlapEnd", preId1, postId1)
		UnregisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", preId2, postId2)
	end)
	return true
end

function ShuffleControls(duration)
	NotifyCrowdControlCommand("Shuffle Controls")
	local shouldStopEffect = false
    local player = GetPlayerCharacter()
	local configManager = FindFirstOf("PBConfigManager")
	local systemSettings = FindFirstOf("PBSystemSettings")
    local originalAttack = configManager.ConfigData:GetPhysKeyFromActionName(FName("Attack"))
    local originalBackstep = configManager.ConfigData:GetPhysKeyFromActionName(FName("Ability"))
    local originalJump = configManager.ConfigData:GetPhysKeyFromActionName(FName("Jump"))
    local originalTrigger = configManager.ConfigData:GetPhysKeyFromActionName(FName("TriggerShard"))
    local originalDirectional = configManager.ConfigData:GetPhysKeyFromActionName(FName("DirectionalShard"))
    local originalEffective = configManager.ConfigData:GetPhysKeyFromActionName(FName("EffectiveShard"))
    local originalShortcut = configManager.ConfigData:GetPhysKeyFromActionName(FName("Shortcut"))
	local controlList = {originalAttack, originalBackstep, originalJump, originalTrigger, originalDirectional, originalEffective, originalShortcut}
	local currentAttack = PickAndRemove(controlList)
    local currentBackstep = PickAndRemove(controlList)
    local currentJump = PickAndRemove(controlList)
    local currentTrigger = PickAndRemove(controlList)
    local currentDirectional = PickAndRemove(controlList)
    local currentEffective = PickAndRemove(controlList)
    local currentShortcut = PickAndRemove(controlList)
    systemSettings:BindToGamepad_NO_CHECK(0, currentAttack)
    systemSettings:BindToGamepad_NO_CHECK(1, currentBackstep)
    systemSettings:BindToGamepad_NO_CHECK(2, currentJump)
    systemSettings:BindToGamepad_NO_CHECK(3, currentTrigger)
    systemSettings:BindToGamepad_NO_CHECK(4, currentDirectional)
    systemSettings:BindToGamepad_NO_CHECK(5, currentEffective)
    systemSettings:BindToGamepad_NO_CHECK(7, currentShortcut)
	-- Prevent the player from changing them back
    local preId1, postId1 = RegisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", function()
		systemSettings:BindToGamepad_NO_CHECK(0, currentAttack)
		systemSettings:BindToGamepad_NO_CHECK(1, currentBackstep)
		systemSettings:BindToGamepad_NO_CHECK(2, currentJump)
		systemSettings:BindToGamepad_NO_CHECK(3, currentTrigger)
		systemSettings:BindToGamepad_NO_CHECK(4, currentDirectional)
		systemSettings:BindToGamepad_NO_CHECK(5, currentEffective)
		systemSettings:BindToGamepad_NO_CHECK(7, currentShortcut)
    end)
	local preId2, postId2
	-- End effect after delay
    ExecuteWithDelay(duration, function()
		if shouldStopEffect then return end
        if player:IsValid() then 
			systemSettings:BindToGamepad_NO_CHECK(0, originalAttack)
			systemSettings:BindToGamepad_NO_CHECK(1, originalBackstep)
			systemSettings:BindToGamepad_NO_CHECK(2, originalJump)
			systemSettings:BindToGamepad_NO_CHECK(3, originalTrigger)
			systemSettings:BindToGamepad_NO_CHECK(4, originalDirectional)
			systemSettings:BindToGamepad_NO_CHECK(5, originalEffective)
			systemSettings:BindToGamepad_NO_CHECK(7, originalShortcut)
        end
        UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", preId1, postId1)
		UnregisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", preId2, postId2)
    end)
	-- Stop effect early if necessary
	preId2, postId2 = RegisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", function()
		shouldStopEffect = true
        if player:IsValid() then 
			systemSettings:BindToGamepad_NO_CHECK(0, originalAttack)
			systemSettings:BindToGamepad_NO_CHECK(1, originalBackstep)
			systemSettings:BindToGamepad_NO_CHECK(2, originalJump)
			systemSettings:BindToGamepad_NO_CHECK(3, originalTrigger)
			systemSettings:BindToGamepad_NO_CHECK(4, originalDirectional)
			systemSettings:BindToGamepad_NO_CHECK(5, originalEffective)
			systemSettings:BindToGamepad_NO_CHECK(7, originalShortcut)
        end
        UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", preId1, postId1)
		UnregisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", preId2, postId2)
	end)
	return true
end

function UseWitchTime(duration)
	if timeDilationActive then return false end
	NotifyCrowdControlCommand("Use Witch Time")
	timeDilationActive = true
	local shouldStopEffect = false
    local player = GetPlayerCharacter()
    local rate = 0.25
    utility:PBCategorySlomo(1, 0, rate, player)
    utility:PBCategorySlomo(2, 0, rate, player)
    utility:PBCategorySlomo(3, 0, rate, player)
    utility:PBCategorySlomo(4, 0, rate, player)
    utility:PBActorSlomo(player, 0, 1.0)
	local preId, postId
	-- End effect after delay
    ExecuteWithDelay(duration, function()
		if shouldStopEffect then return end
        if player:IsValid() then utility:PBCategorySlomo(7, 0, 1.0, player) end
		UnregisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", preId, postId)
		timeDilationActive = false
    end)
	-- Stop effect early if necessary
	preId, postId = RegisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", function()
		shouldStopEffect = true
        if player:IsValid() then utility:PBCategorySlomo(7, 0, 1.0, player) end
		UnregisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", preId, postId)
		timeDilationActive = false
	end)
	return true
end

function TurboEnemies(duration)
	if timeDilationActive then return false end
	NotifyCrowdControlCommand("Turbo Enemies")
	timeDilationActive = true
	local shouldStopEffect = false
    local rate = 2.0
    local player = GetPlayerCharacter()
    utility:PBCategorySlomo(1, 0, rate, player)
    utility:PBActorSlomo(player, 0, 1.0)
	local preId, postId
	-- End effect after delay
    ExecuteWithDelay(duration, function()
		if shouldStopEffect then return end
        if player:IsValid() then utility:PBCategorySlomo(7, 0, 1.0, player) end
		UnregisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", preId, postId)
		timeDilationActive = false
    end)
	-- Stop effect early if necessary
	preId, postId = RegisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", function()
		shouldStopEffect = true
        if player:IsValid() then utility:PBCategorySlomo(7, 0, 1.0, player) end
		UnregisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", preId, postId)
		timeDilationActive = false
	end)
	return true
end

function UncontrollableSpeed(duration)
	NotifyCrowdControlCommand("Uncontrollable Speed")
    ModifyEquipSpecialAttribute({15, 16, 22}, 4.0, true, duration)
	return true
end

function CriticalMode(duration)
	NotifyCrowdControlCommand("Critical Mode")
    ModifyEquipSpecialAttribute({8}, 999.0, false, duration)
    ModifyEquipSpecialAttribute({107, 108}, -999.0, false, duration)
	return true
end

function GoldRush(duration)
	NotifyCrowdControlCommand("Gold Rush")
	local shouldStopEffect = false
    local player = GetPlayerCharacter()
	local timer = 0
    local tickStep = 200
	local totalTickCount = duration//tickStep
	local coinLossTarget = gameInstance.totalCoins//2
	-- Add a counter for the coins gained
	local coinGainCount = 0
	local damagePopupClass = StaticFindObject("/Game/Core/UI/HUD/Damage/DamagePopup.DamagePopup_C")
	local damagePopup = widgetBlueprintLibrary:Create(player, damagePopupClass, nil)
	damagePopup:SetPositionInViewport({X=540.0, Y=150.0}, false)
	damagePopup:DisplayNumeric(coinGainCount)
	damagePopup:AddToViewport(0)
	-- Convert damage dealt to money
	local preId1, postId1 = RegisterHook("/Game/Core/UI/HUD/Damage/DamagePopup.DamagePopup_C:CustomDamageEvent", function(self, param1, param2)
		local damage = param1:get()
		local color = param2:get()
		if color.R == 1.0 and color.G== 1.0 and color.B == 1.0 then
			local quantity = damage*2
			coinGainCount = coinGainCount + quantity
			damagePopup:DisplayNumeric(coinGainCount)
			gameInstance:AddTotalCoin(quantity)
		end
	end)
	local preId2, postId2
	-- Drain up to half of the player's gold
	LoopAsync(tickStep, function()
		if shouldStopEffect or not player:IsValid() then
			if damagePopup:IsValid() then damagePopup:RemoveFromViewport() end
			UnregisterHook("/Game/Core/UI/HUD/Damage/DamagePopup.DamagePopup_C:CustomDamageEvent", preId1, postId1)
			UnregisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", preId2, postId2)
			return true
		end
		gameInstance:AddTotalCoin(-coinLossTarget//totalTickCount)
		return false
	end)
	-- End effect after delay
    ExecuteWithDelay(duration, function()
		shouldStopEffect = true
	end)
	-- Stop effect early if necessary
	preId2, postId2 = RegisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", function()
		shouldStopEffect = true
	end)
	return true
end

function UseRosario()
	NotifyCrowdControlCommand("Use Rosario")
    local player = GetPlayerCharacter()
	local actorInstances = FindAllOf("PBBaseCharacter")
	-- All enemies found will be defeated instantly
	-- All bosses found will be dealt 10% of health
	ExecuteInGameThread(function()
		for index = 1,#actorInstances,1 do
			local actor = actorInstances[index]
			if actor:IsValid() then
				if actor:IsBoss() then
					actor:DirectDamage(math.floor(actor.CharacterStatus:GetMaxHitPoint()*0.1))
				elseif actor:IsEnemy() then 
					actor:DirectDamage(actor.CharacterStatus.HitPoint)
				end
			end
		end
	end)
	return true
end

function SummonAmbush()
	if IsInList(rotatingRooms, currentRoom:ToString()) then return false end
	NotifyCrowdControlCommand("Summon Ambush")
	local player = GetPlayerCharacter()
	local playerLocation = player:K2_GetActorLocation()
	local chosenEnemy = RandomChoice(enemylist)
	local enemyLevel = gameInstance.pMapManager:GetRoomTraverseRate({})//2
	print("Spawned enemy: " .. chosenEnemy)
	-- Spawn 2 of the same random enemy with their levels scaling with map completion
	ExecuteInGameThread(function()
		local enemy1 = gameInstance.pCharacterManager:CreateCharacter(FName(chosenEnemy), "", {X = playerLocation.X + 420, Y = playerLocation.Y, Z = playerLocation.Z}, {}, 1, "", nil, false)
		local enemy2 = gameInstance.pCharacterManager:CreateCharacter(FName(chosenEnemy), "", {X = playerLocation.X - 420, Y = playerLocation.Y, Z = playerLocation.Z}, {}, 1, "", nil, false)
		enemy1:SetCharacterWorldRotation(180.0, 0.0)
		enemy1:SetEnemyLevel(ClampValue(enemyLevel, 1, 50))
		enemy1.CharacterStatus:RecoverHitPoint()
		enemy2:SetEnemyLevel(ClampValue(enemyLevel, 1, 50))
		enemy2.CharacterStatus:RecoverHitPoint()
	end)
	return true
end

function RewindTime()
	if gameInstance:IsBossBattleNow() then return false end
	NotifyCrowdControlCommand("Rewind Time")
	-- Warp in the last valid room traversed, 2 rooms back at most
	local chosenRoom
	if     previousRoom2 ~= nullName and not IsInList(rotatingRooms, previousRoom2:ToString()) then
		chosenRoom = previousRoom2
	elseif previousRoom1 ~= nullName and not IsInList(rotatingRooms, previousRoom1:ToString()) then
		chosenRoom = previousRoom1
	else return false end
	ExecuteInGameThread(function()
		gameInstance.pRoomManager:Warp(chosenRoom, false, false, nullName, {R=0.0, G=0.0, B=0.0, A=1.0})
	end)
	return true
end

function SummonRave(duration)
	if postProcessActive then return false end
	NotifyCrowdControlCommand("Summon Rave")
	postProcessActive = true
	local shouldStopEffect = false
	local postProcess = FindFirstOf("PostProcessVolume")
	local timer = 0
	local progress = 0
	local fullcycle = 1500
	local deltaSeconds = gameplayStatics:GetWorldDeltaSeconds(postProcess)
	local preId, postId
	postProcess.Settings.bOverride_ColorGain = 1
	-- Cycle through color gains
	LoopAsync(math.floor(deltaSeconds*1000), function()
		if shouldStopEffect or not postProcess:IsValid() then
			if postProcess:IsValid() then postProcess.Settings.ColorGain = {X=1.0, Y=1.0, Z=1.0} end
			UnregisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", preId, postId)
			postProcessActive = false
			return true
		end
		timer = timer + deltaSeconds*1000
		progress = timer%fullcycle
		color = mathLibrary:HSVToRGB(progress/fullcycle*360, 0.75, 1.0, 1.0)
		postProcess.Settings.ColorGain = {X=color.R, Y=color.G, Z=color.B}
		return false
	end)
	-- End effect after delay
    ExecuteWithDelay(duration, function()
		shouldStopEffect = true
	end)
	-- Stop effect early if necessary
	preId, postId = RegisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", function()
		shouldStopEffect = true
	end)
	return true
end

function SummonDarkness(duration)
	if postProcessActive then return false end
	NotifyCrowdControlCommand("Summon Darkness")
	postProcessActive = true
	local shouldStopEffect = false
	local postProcess = FindFirstOf("PostProcessVolume")
	postProcess.Settings.bOverride_VignetteIntensity = 1
	postProcess.Settings.VignetteIntensity = 5.0
	local preId, postId
	-- End effect after delay
    ExecuteWithDelay(duration, function()
		if shouldStopEffect then return end
        if postProcess:IsValid() then postProcess.Settings.VignetteIntensity = 0.0 end
		UnregisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", preId, postId)
		postProcessActive = false
    end)
	-- Stop effect early if necessary
	preId, postId = RegisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", function()
		shouldStopEffect = true
        if postProcess:IsValid() then postProcess.Settings.VignetteIntensity = 0.0 end
		UnregisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", preId, postId)
		postProcessActive = false
	end)
	return true
end

function TriggerEarthquake(duration)
    local player = GetPlayerCharacter()
	NotifyCrowdControlCommand("Trigger Earthquake")
	player.Step:CameraShake(duration/1000, 0.15, 60.0, 0.3, 40.0, 0.0, 0.0, player.criticalForceFeedback, nullName, false, nullName)
	return true
end

function ForceInvert(duration)
	NotifyCrowdControlCommand("Force Invert")
	local shouldStopEffect = false
    local player = GetPlayerCharacter()
	if not eventUtility:IsInvertedByPlayerCharacter(0) then player.Step:BeginInvert() end
    player.CharacterInventory:SetSkillOnOff(FName("Invert"), false)
	-- Prevent the player from enabling it back
    local preId1, postId1 = RegisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", function()
        player.CharacterInventory:SetSkillOnOff(FName("Invert"), false)
    end)
	local preId2, postId2
	-- End effect after delay
    ExecuteWithDelay(duration, function()
		if shouldStopEffect then return end
        if player:IsValid() then
			if eventUtility:IsInvertedByPlayerCharacter(0) then player.Step:BeginInvert() end
            player.CharacterInventory:SetSkillOnOff(FName("Invert"), true)
        end
        UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", preId1, postId1)
		UnregisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", preId2, postId2)
    end)
	-- Stop effect early if necessary
	preId2, postId2 = RegisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", function()
		shouldStopEffect = true
        if player:IsValid() then
			if eventUtility:IsInvertedByPlayerCharacter(0) then player.Step:BeginInvert() end
            player.CharacterInventory:SetSkillOnOff(FName("Invert"), true)
        end
        UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", preId1, postId1)
		UnregisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", preId2, postId2)
	end)
	return true
end

function NoSkillShards(duration)
	NotifyCrowdControlCommand("No Skill Shards")
	local shouldStopEffect = false
    local player = GetPlayerCharacter()
    SetAllSkillOnOff(false)
	-- Prevent the player from enabling them back
    local preId1, postId1 = RegisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", function()
        SetAllSkillOnOff(false)
    end)
	local preId2, postId2
	-- End effect after delay
    ExecuteWithDelay(duration, function()
		if shouldStopEffect then return end
        if player:IsValid() then SetAllSkillOnOff(true) end
        UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", preId1, postId1)
		UnregisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", preId2, postId2)
    end)
	-- Stop effect early if necessary
	preId2, postId2 = RegisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", function()
		shouldStopEffect = true
        if player:IsValid() then SetAllSkillOnOff(true) end
        UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", preId1, postId1)
		UnregisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", preId2, postId2)
	end)
	return true
end

function SetAllSkillOnOff(flag)
    local player = GetPlayerCharacter()
    for index = 1,#player.CharacterInventory.mySkills,1 do
        player.CharacterInventory:SetSkillOnOff(player.CharacterInventory.mySkills[index].ID, flag)
    end
end

function WeaponsOnly(duration)
	if equipmentChangeActive then return false end
	NotifyCrowdControlCommand("Weapons Only")
	equipmentChangeActive = true
	local shouldStopEffect = false
    local player = GetPlayerCharacter()
	local inventory = player.CharacterInventory
	local interfaceHUD = FindFirstOf("PBInterfaceHUD")
	local triggerShard = inventory.netEquipment.TriggerShard
	local effectiveShard = inventory.netEquipment.EffectiveShard
	local directionalShard = inventory.netEquipment.DirectionalShard
	local enchantShard = inventory.netEquipment.EnchantShard
	local familiarShard = inventory.netEquipment.FamiliarShard
	ExecuteInGameThread(function()
		interfaceHUD:DispShortcutMenu(true)
		UnequipPlayerShards()
	end)
	-- Prevent the player from equipping it back
    local preId1, postId1 = RegisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", function()
		ExecuteInGameThread(function()
			interfaceHUD:DispShortcutMenu(true)
			UnequipPlayerShards()
		end)
    end)
    local preId2, postId2 = RegisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ChangeCurrentShortcut", function() end, function()
		ExecuteInGameThread(function()
			interfaceHUD:DispShortcutMenu(true)
			UnequipPlayerShards()
		end)
    end)
	local preId3, postId3
	-- End effect after delay
    ExecuteWithDelay(duration, function()
		if shouldStopEffect then return end
		if player:IsValid() then
			ExecuteInGameThread(function()
				interfaceHUD:DispShortcutMenu(true)
				EquipPlayerShards(triggerShard, effectiveShard, directionalShard, enchantShard, familiarShard)
			end)
		end
		UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", preId1, postId1)
		UnregisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ChangeCurrentShortcut", preId2, postId2)
		UnregisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", preId3, postId3)
		equipmentChangeActive = false
    end)
	-- Stop effect early if necessary
	preId3, postId3 = RegisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", function()
		shouldStopEffect = true
		if player:IsValid() then
			ExecuteInGameThread(function()
				interfaceHUD:DispShortcutMenu(true)
				EquipPlayerShards(triggerShard, effectiveShard, directionalShard, enchantShard, familiarShard)
			end)
		end
		UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", preId1, postId1)
		UnregisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ChangeCurrentShortcut", preId2, postId2)
		UnregisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", preId3, postId3)
		equipmentChangeActive = false
	end)
	return true
end

function ShardsOnly(duration)
	if equipmentChangeActive then return false end
	NotifyCrowdControlCommand("Shards Only")
	equipmentChangeActive = true
	local shouldStopEffect = false
    local player = GetPlayerCharacter()
	local inventory = player.CharacterInventory
	local interfaceHUD = FindFirstOf("PBInterfaceHUD")
	local originalWeapon = inventory.netEquipment.weapon
	local originalBullet = inventory.netEquipment.Bullet
	ExecuteInGameThread(function()
		interfaceHUD:DispShortcutMenu(true)
		UnequipPlayerWeapon()
	end)
	-- Prevent the player from equipping them back
    local preId1, postId1 = RegisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", function()
		ExecuteInGameThread(function()
			interfaceHUD:DispShortcutMenu(true)
			UnequipPlayerWeapon()
		end)
    end)
    local preId2, postId2 = RegisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ChangeCurrentShortcut", function() end, function()
		ExecuteInGameThread(function()
			interfaceHUD:DispShortcutMenu(true)
			UnequipPlayerWeapon()
		end)
    end)
	local preId3, postId3
	-- End effect after delay
    ExecuteWithDelay(duration, function()
		if shouldStopEffect then return end
		if player:IsValid() then
			ExecuteInGameThread(function()
				interfaceHUD:DispShortcutMenu(true)
				EquipPlayerWeapon(originalWeapon, originalBullet)
			end)
		end
		UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", preId1, postId1)
		UnregisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ChangeCurrentShortcut", preId2, postId2)
		UnregisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", preId3, postId3)
		equipmentChangeActive = false
    end)
	-- Stop effect early if necessary
	preId3, postId3 = RegisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", function()
		shouldStopEffect = true
		if player:IsValid() then
			ExecuteInGameThread(function()
				interfaceHUD:DispShortcutMenu(true)
				EquipPlayerWeapon(originalWeapon, originalBullet)
			end)
		end
		UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", preId1, postId1)
		UnregisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ChangeCurrentShortcut", preId2, postId2)
		UnregisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", preId3, postId3)
		equipmentChangeActive = false
	end)
	return true
end

function ForceEquipment(duration)
	if equipmentChangeActive then return false end
	NotifyCrowdControlCommand("Force Equipment")
	equipmentChangeActive = true
	local shouldStopEffect = false
    local player = GetPlayerCharacter()
	local inventory = player.CharacterInventory
	local interfaceHUD = FindFirstOf("PBInterfaceHUD")
	local originalWeapon = inventory.netEquipment.weapon
	local originalBullet = inventory.netEquipment.Bullet
	local originalTriggerShard = inventory.netEquipment.TriggerShard
	local originalEffectiveShard = inventory.netEquipment.EffectiveShard
	local originalDirectionalShard = inventory.netEquipment.DirectionalShard
	local originalEnchantShard = inventory.netEquipment.EnchantShard
	local originalFamiliarShard = inventory.netEquipment.FamiliarShard
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
		interfaceHUD:DispShortcutMenu(true)
		EquipPlayerWeapon(currentWeapon, currentBullet)
		EquipPlayerShards(currentTriggerShard, currentEffectiveShard, currentDirectionalShard, currentEnchantShard, currentFamiliarShard)
	end)
	-- Prevent the player from changing their equipment
	local preId1, postId1 = RegisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", function()
		ExecuteInGameThread(function()
			interfaceHUD:DispShortcutMenu(true)
			EquipPlayerWeapon(currentWeapon, currentBullet)
			EquipPlayerShards(currentTriggerShard, currentEffectiveShard, currentDirectionalShard, currentEnchantShard, currentFamiliarShard)
		end)
    end)
    local preId2, postId2 = RegisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ChangeCurrentShortcut", function() end, function()
		ExecuteInGameThread(function()
			interfaceHUD:DispShortcutMenu(true)
			EquipPlayerWeapon(currentWeapon, currentBullet)
			EquipPlayerShards(currentTriggerShard, currentEffectiveShard, currentDirectionalShard, currentEnchantShard, currentFamiliarShard)
		end)
    end)
	local preId3, postId3
	-- End effect after delay
    ExecuteWithDelay(duration, function()
		if shouldStopEffect then return end
		if player:IsValid() then
			ExecuteInGameThread(function()
				interfaceHUD:DispShortcutMenu(true)
				EquipPlayerWeapon(originalWeapon, originalBullet)
				EquipPlayerShards(originalTriggerShard, originalEffectiveShard, originalDirectionalShard, originalEnchantShard, originalFamiliarShard)
			end)
		end
	 	UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", preId1, postId1)
	 	UnregisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ChangeCurrentShortcut", preId2, postId2)
		UnregisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", preId3, postId3)
		equipmentChangeActive = false
    end)
	-- Stop effect early if necessary
	preId3, postId3 = RegisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", function()
		shouldStopEffect = true
		if player:IsValid() then
			ExecuteInGameThread(function()
				interfaceHUD:DispShortcutMenu(true)
				EquipPlayerWeapon(originalWeapon, originalBullet)
				EquipPlayerShards(originalTriggerShard, originalEffectiveShard, originalDirectionalShard, originalEnchantShard, originalFamiliarShard)
			end)
		end
	 	UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", preId1, postId1)
	 	UnregisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ChangeCurrentShortcut", preId2, postId2)
		UnregisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", preId3, postId3)
		equipmentChangeActive = false
	end)
	return true
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
		if equipmentList[index].Num > 0 then
			count = count + 1
			validEquipment[count] = equipmentList[index].ID
		end
	end
	if #validEquipment > 0 then
		return RandomChoice(validEquipment)
	end
	return nullName
end

function HeavenOrHell(duration)
	NotifyCrowdControlCommand("Heaven or Hell")
	local shouldStopEffect = false
    local player = GetPlayerCharacter()
	-- Half chance of OHKO mode
	if math.random() < 0.5 then
		ModifyEquipSpecialAttribute({62, 63, 64, 65, 66, 67, 68, 69}, -100.0, false, duration)
		local preId1, postId1 = RegisterHook("/Game/Core/Character/Common/Template/Step_Root.Step_Root_C:EnterDamaged1Event", function()
			player.Step:Kill()
		end)
		local preId2, postId2
		-- End effect after delay
		ExecuteWithDelay(duration, function()
			if shouldStopEffect then return end
			UnregisterHook("/Game/Core/Character/Common/Template/Step_Root.Step_Root_C:EnterDamaged1Event", preId1, postId1)
			UnregisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", preId2, postId2)
		end)
		-- Stop effect early if necessary
		preId2, postId2 = RegisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", function()
			shouldStopEffect = true
			UnregisterHook("/Game/Core/Character/Common/Template/Step_Root.Step_Root_C:EnterDamaged1Event", preId1, postId1)
			UnregisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", preId2, postId2)
		end)
	-- Half chance of invincibility
	else
		ModifyEquipSpecialAttribute({62, 63, 64, 65, 66, 67, 68, 69}, 100.0, false, duration)
	end
	return true
end

function ReturnBooks()
	NotifyCrowdControlCommand("Return Books")
    local player = GetPlayerCharacter()
    for index = 1,#player.CharacterInventory.myBorrowedBooks,1 do
        player.CharacterInventory:ReturnTheBook(player.CharacterInventory.myBorrowedBooks[1].ID)
    end
	PlayEnemySound("Vo_N2012_047_jp")
	return true
end

function CallTheLibrary()
	-- If OD has been defeated then simply warp to library
	if gameInstance:IsCompletedBoss(FName("N2012")) then
		if gameInstance:IsBossBattleNow() then return false end
		NotifyCrowdControlCommand("Call The Library")
		ExecuteInGameThread(function()
			gameInstance.pRoomManager:Warp(FName("m07LIB_009"), false, false, nullName, {})
		end)
	-- Otherwise put OD on standby in the next save room entered
	else
		if orlokStandbyActive then return false end
		NotifyCrowdControlCommand("Call The Library")
		orlokStandbyActive = true
		local preId, postId
		preId, postId = RegisterHook("/Game/Core/UI/Tutorial/TutorialAPI.TutorialAPI_C:OnSaveRoomEntered", function()
			if not gameInstance.LoadingManagerInstance:IsLoadingScreenVisible() then
				orlokStandbyActive = false
				ExecuteInGameThread(function()
					StartSaveRoomBoss()
				end)
				UnregisterHook("/Game/Core/UI/Tutorial/TutorialAPI.TutorialAPI_C:OnSaveRoomEntered", preId, postId)
			end
		end)
	end
	return true
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
	local leftDoor = gameInstance.pEventManager:CreateEventObject(doorClass, {X=doorPosX, Z=doorPosZ}, {Yaw=-180.0}, player)
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
	player.m_SoundControlComponent:PlayBGM("BGM_siebel_battle", 0.0, 0)
	player.m_SoundControlComponent:CharaGroupLoad(bossOD, "VOICE", bossID)
	player.m_SoundControlComponent:CharaGroupLoad(bossOD, "ENEMY", bossID)
	-- Watch the damage to despawn the boss before he truly dies
	local preId, postId
	preId, postId = RegisterHook("/Game/Core/Character/N2012/Data/Step_N2012.Step_N2012_C:OnDamaged", function()
		if GetCharacterHealthRatio(bossOD) <= 1 - 6666/7500 then
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

function ModifyEquipSpecialAttribute(attributes, differences, multiply, duration)
	local shouldStopEffect = false
    local player = GetPlayerCharacter()
	local originalAttributes = {}
	local currentAttributes = {}
	for index = 1,#attributes,1 do
		originalAttributes[index] = player:GetEquipSpecialAttribute(attributes[index])
		difference = type(differences) == "table" and differences[index] or differences
		newAttribute = multiply and originalAttributes[index] * difference or originalAttributes[index] + difference
		player:SetEquipSpecialAttribute(attributes[index], newAttribute)
		currentAttributes[index] = newAttribute
	end
	-- Recalculate the stat if something caused it to be changed
	local preId1, postId1 = RegisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", function() end, function()
		for index = 1,#attributes,1 do
			currentAttribute = player:GetEquipSpecialAttribute(attributes[index])
			if currentAttribute ~= currentAttributes[index] then
				originalAttributes[index] = player:GetEquipSpecialAttribute(attributes[index])
				difference = type(differences) == "table" and differences[index] or differences
				newAttribute = multiply and originalAttributes[index] * difference or originalAttributes[index] + difference
				player:SetEquipSpecialAttribute(attributes[index], newAttribute)
				currentAttributes[index] = newAttribute
			end
		end
	end)
	local preId2, postId2 = RegisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:BorrowTheBook", function() end, function()
		for index = 1,#attributes,1 do
			currentAttribute = player:GetEquipSpecialAttribute(attributes[index])
			if currentAttribute ~= currentAttributes[index] then
				originalAttributes[index] = player:GetEquipSpecialAttribute(attributes[index])
				difference = type(differences) == "table" and differences[index] or differences
				newAttribute = multiply and originalAttributes[index] * difference or originalAttributes[index] + difference
				player:SetEquipSpecialAttribute(attributes[index], newAttribute)
				currentAttributes[index] = newAttribute
			end
		end
	end)
    local preId3, postId3 = RegisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ChangeCurrentShortcut", function() end, function()
		for index = 1,#attributes,1 do
			currentAttribute = player:GetEquipSpecialAttribute(attributes[index])
			if currentAttribute ~= currentAttributes[index] then
				originalAttributes[index] = player:GetEquipSpecialAttribute(attributes[index])
				difference = type(differences) == "table" and differences[index] or differences
				newAttribute = multiply and originalAttributes[index] * difference or originalAttributes[index] + difference
				player:SetEquipSpecialAttribute(attributes[index], newAttribute)
				currentAttributes[index] = newAttribute
			end
		end
    end)
	local preId4, postId4
	-- End effect after delay
    ExecuteWithDelay(duration, function()
		if shouldStopEffect then return end
		for index = 1,#attributes,1 do
			if player:IsValid() then player:SetEquipSpecialAttribute(attributes[index], originalAttributes[index]) end
		end
		UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", preId1, postId1)
		UnregisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:BorrowTheBook", preId2, postId2)
		UnregisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ChangeCurrentShortcut", preId3, postId3)
		UnregisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", preId4, postId4)
    end)
	-- Stop effect early if necessary
    preId4, postId4 = RegisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", function()
		shouldStopEffect = true
		for index = 1,#attributes,1 do
			if player:IsValid() then player:SetEquipSpecialAttribute(attributes[index], originalAttributes[index]) end
		end
		UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", preId1, postId1)
		UnregisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:BorrowTheBook", preId2, postId2)
		UnregisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ChangeCurrentShortcut", preId3, postId3)
		UnregisterHook("/Script/ProjectBlood.PBGameInstance:DEBUG_IsScreenCaptureEnabled", preId4, postId4)
    end)
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

-- End all effects by calling an unused function in the game that every effect listens to
function StopAllEffects()
	gameInstance:DEBUG_IsScreenCaptureEnabled()
end

-- Stop all effects if the game goes to a loading screen
RegisterHook("/Script/ProjectBlood.PBLoadingManager:Init", function()
    StopAllEffects()
end)

-- Toggle CC notifications with F1
RegisterKeyBind(Key.F1, function()
    ToggleDisplayNotifications()
end)

print("CC script loaded")

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
            if dur > 0 then
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
    for code,entry in pairs(timed) do
        entry["dur"] = entry["dur"] - 250
        if entry["dur"] <= 0 then
            local code = entry["code"] .. "_end"
            
            local func =_G[code]
            
            if func == nil or pcall(func) then
                ccRespondTimed(entry["id"], 8, 0)
                timed[entry["code"]] = nil
            end
        end
    end
	return false
end)