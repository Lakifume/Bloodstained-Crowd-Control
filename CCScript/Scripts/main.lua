print("Loading CC script")

require("utility")
require("constant")

function SetPlayerEffect(EffectID)
    local player = GetPlayerCharacter()
    player.Step:SetSpecialEffect(FName(EffectID))
end

function ForceInvert(duration)
    local player = GetPlayerCharacter()
    if not eventUtility:IsInvertedByPlayerCharacter(0) then player.Step:BeginInvert() end
    player.CharacterInventory:SetSkillOnOff(FName("Invert"), false)
    local preId, postId = RegisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", function()
        player.CharacterInventory:SetSkillOnOff(FName("Invert"), false)
    end)
    ExecuteWithDelay(math.floor(duration*1000), function()
        if player:IsValid() then
            if eventUtility:IsInvertedByPlayerCharacter(0) then player.Step:BeginInvert() end
            player.CharacterInventory:SetSkillOnOff(FName("Invert"), true)
        end
        UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", preId, postId)
    end)
end

function EmptyHealth()
    local player = GetPlayerCharacter()
    player.CharacterStatus:SetHitPointForce(1.0)
end

function EmptyMagic()
    local player = GetPlayerCharacter()
    player.CharacterStatus:SetMagicPointForce(1.0)
end

function RefillHealth()
    local player = GetPlayerCharacter()
    player.CharacterStatus:RecoverHitPoint()
end

function RefillMagic()
    local player = GetPlayerCharacter()
    player.CharacterStatus:RecoverMagicPoint()
end

function ReturnBooks()
    local player = GetPlayerCharacter()
    for index = 1,#player.CharacterInventory.myBorrowedBooks,1 do
        player.CharacterInventory:ReturnTheBook(player.CharacterInventory.myBorrowedBooks[1].ID)
    end
end

function RandomizeColors()
    local player = GetPlayerCharacter()
    for index = 1,6,1 do
        for subindex = 0,2,1 do
            player:SetChromaWheelColorScheme(index, {R=math.random(), G=math.random(), B=math.random(), A=1}, subindex, false, false, false)
        end
    end
    player:SetChromaWheelTrim(3, math.random(1, 36), false, false)
    gameInstance.m_SystemSettings:SetBloodColor(math.random(0, 11))
end

function WitchTime(duration)
    local rate = 0.25
    local player = GetPlayerCharacter()
    utility:PBCategorySlomo(1, 0, rate, player)
    utility:PBCategorySlomo(2, 0, rate, player)
    utility:PBCategorySlomo(3, 0, rate, player)
    utility:PBCategorySlomo(4, 0, rate, player)
    utility:PBActorSlomo(player, 0, 1.0)
    ExecuteWithDelay(math.floor(duration*1000), function()
        if player:IsValid() then RestoreTimeDilation() end
    end)
end

function TurboEnemies(duration)
    local rate = 2.0
    local player = GetPlayerCharacter()
    utility:PBCategorySlomo(1, 0, rate, player)
    utility:PBActorSlomo(player, 0, 1.0)
    ExecuteWithDelay(math.floor(duration*1000), function()
        if player:IsValid() then RestoreTimeDilation() end
    end)
end

function RestoreTimeDilation()
    local player = GetPlayerCharacter()
    utility:PBCategorySlomo(7, 0, 1.0, player)
end

function NoSkillShards(duration)
    local player = GetPlayerCharacter()
    SetAllSkillOnOff(false)
    local preId, postId = RegisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", function()
        SetAllSkillOnOff(false)
    end)
    ExecuteWithDelay(math.floor(duration*1000), function()
        if player:IsValid() then 
            SetAllSkillOnOff(true)
        end
        UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", preId, postId)
    end)
end

function SetAllSkillOnOff(flag)
    local player = GetPlayerCharacter()
    for index = 1,#player.CharacterInventory.mySkills,1 do
        player.CharacterInventory:SetSkillOnOff(player.CharacterInventory.mySkills[index].ID, flag)
    end
end

function Plunderer(duration)
    local player = GetPlayerCharacter()
    local step = 0.2
	local timer = 0.0
    ModifyEquipSpecialAttribute({9, 59}, 100.0, false, duration)
	LoopAsync(math.floor(1000*step), function()
		timer = timer + step
		gameInstance:AddTotalCoin(-100)
		return timer >= duration or not player:IsValid()
	end)
end

function PlayRandomGameOverQuote()
    local player = GetPlayerCharacter()
	local chosenVoice = RandomChoice(voicelist)
	print("Played quote: " .. chosenVoice)
	-- Character voices don't play unless their sound group is loaded
	gameInstance.pSoundManager:GroupLoad("VOICE", string.sub(chosenVoice, 4, 8))
	gameInstance.pSoundManager:PlaySEForBP(FName(chosenVoice), player)
end

function FlipPlayer(duration)
    utility:SetLeftAnalogMirrorFlag(true)
	-- Switching rooms breaks it so enabled it back
    local preId, postId = RegisterHook("/Script/ProjectBlood.PBRoomVolume:OnRoomVolumeOverlapEnd", function()
        utility:SetLeftAnalogMirrorFlag(true)
    end)
    ExecuteWithDelay(math.floor(duration*1000), function()
        utility:SetLeftAnalogMirrorFlag(false)
		UnregisterHook("/Script/ProjectBlood.PBRoomVolume:OnRoomVolumeOverlapEnd", preId, postId)
    end)
end

function HeavenOrHell(duration)
    local player = GetPlayerCharacter()
	-- Helf chance of OHKO mode
	if math.random() < 0.0 then
		ModifyEquipSpecialAttribute({62, 63, 64, 65, 66, 67, 68, 69}, -100.0, false, duration)
		local preId, postId = RegisterHook("/Game/Core/Character/Common/Template/Step_Root.Step_Root_C:EnterDamaged1Event", function()
			player.Step:Kill()
		end)
		ExecuteWithDelay(math.floor(duration*1000), function()
			UnregisterHook("/Game/Core/Character/Common/Template/Step_Root.Step_Root_C:EnterDamaged1Event", preId, postId)
		end)
	-- Half chance of invincibility
	else
		ModifyEquipSpecialAttribute({62, 63, 64, 65, 66, 67, 68, 69}, 100.0, false, duration)
	end
end

function UncontrollableSpeed(duration)
    ModifyEquipSpecialAttribute({15, 16, 22}, 4.0, true, duration)
end

function CriticalMode(duration)
    ModifyEquipSpecialAttribute({8}, 999.0, false, duration)
    ModifyEquipSpecialAttribute({107, 108}, -999.0, false, duration)
end

function ModifyEquipSpecialAttribute(attributes, differences, multiply, duration)
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
    ExecuteWithDelay(math.floor(duration*1000), function()
		for index = 1,#attributes,1 do
			if player:IsValid() then player:SetEquipSpecialAttribute(attributes[index], originalAttributes[index]) end
		end
		UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", preId1, postId1)
		UnregisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:BorrowTheBook", preId2, postId2)
		UnregisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ChangeCurrentShortcut", preId3, postId3)
    end)
end

function KillAllEnemiesOnScreen()
    local player = GetPlayerCharacter()
	local actorInstances = FindAllOf("PBBaseCharacter")
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
end

function SummonEnemyAmbush()
    local player = GetPlayerCharacter()
	local playerLocation = player:K2_GetActorLocation()
	local chosenEnemy = RandomChoice(enemylist)
	local enemyLevel = math.floor(gameInstance.pMapManager:GetRoomTraverseRate({})/2)
	print("Spawned enemy: " .. chosenEnemy)
    local enemy1 = gameInstance.pCharacterManager:CreateCharacter(FName(chosenEnemy), "", {X = playerLocation.X + 420, Y = playerLocation.Y, Z = playerLocation.Z}, {}, 1, "", nil, false)
    local enemy2 = gameInstance.pCharacterManager:CreateCharacter(FName(chosenEnemy), "", {X = playerLocation.X - 420, Y = playerLocation.Y, Z = playerLocation.Z}, {}, 1, "", nil, false)
	enemy1:SetCharacterWorldRotation(180.0, 0.0)
	enemy1:SetEnemyLevel(enemyLevel)
	enemy1.CharacterStatus:RecoverHitPoint()
	enemy2:SetEnemyLevel(enemyLevel)
	enemy2.CharacterStatus:RecoverHitPoint()
end

function CallTheLibrarian()
	local preId, postId
	preId, postId = RegisterHook("/Game/Core/UI/Tutorial/TutorialAPI.TutorialAPI_C:OnSaveRoomEntered", function()
		if not gameInstance.LoadingManagerInstance:IsLoadingScreenVisible() then
			StartSaveRoomBoss()
			UnregisterHook("/Game/Core/UI/Tutorial/TutorialAPI.TutorialAPI_C:OnSaveRoomEntered", preId, postId)
		end
	end)
end

function StartSaveRoomBoss()
    local player = GetPlayerCharacter()
	local playerLocation = player:K2_GetActorLocation()
	local bossID = "N2012"
	local doorClass = FindValidActorClass("/Game/Core/Environment/Gimmick/NewGimmicks/BossDoorBase/PBBossDoor_BP.PBBossDoor_BP_C")
	local doorPosX, doorPosZ = RelativeToAbsoluteLocation(0.0, 240.0)
	local leftDoor = gameInstance.pEventManager:CreateEventObject(doorClass, {X=doorPosX, Z=doorPosZ}, {Yaw=-180.0}, player)
	leftDoor.InBossRoom = true
	leftDoor.BossId = FName(bossID)
	leftDoor.IsRight = false
	leftDoor.YScale = 2
	local doorPosX, doorPosZ = RelativeToAbsoluteLocation(1260.0, 240.0)
	local rightDoor = gameInstance.pEventManager:CreateEventObject(doorClass, {X=doorPosX, Z=doorPosZ}, {}, player)
	rightDoor.InBossRoom = true
	rightDoor.BossId = FName(bossID)
	rightDoor.IsRight = true
	rightDoor.YScale = 2
	saveBoxes = FindAllOf("PBSaveBox_BP_C")
	for index = 1,#saveBoxes,1 do
		saveBoxes[index].HasBeenUsed = true
	end
	-- Spawn OD
	local enemyLevel = math.floor(gameInstance.pMapManager:GetRoomTraverseRate({})/2)
	local bossPosX, bossPosZ = RelativeToAbsoluteLocation(630.0, 120.0)
	local bossOD = gameInstance.pCharacterManager:CreateCharacter(FName(bossID), "", {X=bossPosX, Z=bossPosZ}, {}, 1, "", nil, false)
	bossOD:SetEnemyLevel(enemyLevel)
	bossOD.CharacterStatus:RecoverHitPoint()
	player.m_SoundControlComponent:PlayBGM("BGM_siebel_battle", 0.0, 0)
	player.m_SoundControlComponent:CharaGroupLoad(bossOD, "VOICE", bossID)
	player.m_SoundControlComponent:CharaGroupLoad(bossOD, "ENEMY", bossID)
	local preId, postId
	preId, postId = RegisterHook("/Game/Core/Character/N2012/Data/Step_N2012.Step_N2012_C:OnDamaged", function()
		if GetCharacterHealthRatio(bossOD) < 1/3 then
			EndSaveRoomBoss(bossOD)
			UnregisterHook("/Game/Core/Character/N2012/Data/Step_N2012.Step_N2012_C:OnDamaged", preId, postId)
		end
	end)
	--LoopAsync(5000, function()
	--	bossLocation = bossOD:K2_GetActorLocation()
	--	if bossLocation.Z < RelativeToAbsoluteLocation(0.0, 80.0)[2] then
	--		bossOD.Step:StartMist(1.0, true)
	--	end
	--	return not bossOD:IsValid()
	--end)
end

function EndSaveRoomBoss(bossOD)
    local player = GetPlayerCharacter()
	local saveBoxes = FindAllOf("PBSaveBox_BP_C")
	bossOD.Step:StartMist(1.0, true)
	ExecuteWithDelay(1000, function()
		bossOD:K2_DestroyActor()
		player.m_SoundControlComponent:StopBGM(0.0)
		player.m_SoundControlComponent:CharaGroupRelease(bossOD)
		for index = 1,#saveBoxes,1 do
			saveBoxes[index].HasBeenUsed = false
		end
	end)
end

function FakeNoDamageWin()
    local player = GetPlayerCharacter()
	player.Step:NoticeBossBattleNoDamageWin(nullName)
end

function TriggerEarthquake()
    local player = GetPlayerCharacter()
	player.Step:CameraShake(10.0, 0.15, 60.0, 0.3, 40.0, 0.0, 0.0, player.criticalForceFeedback, nullName, false, nullName)
end

function SummonRave(duration)
	local postProcess = FindFirstOf("PostProcessVolume")
	local timer = 0.0
	local fullcycle = 2.0
	local progress = 0.0
	local deltaSeconds = gameplayStatics:GetWorldDeltaSeconds(postProcess)
	local milliDeltaSeconds = math.floor(deltaSeconds*1000)
	postProcess.Settings.bOverride_ColorGain = 1
	LoopAsync(milliDeltaSeconds, function()
		timer = timer + milliDeltaSeconds/1000
		progress = timer%fullcycle
		color = mathLibrary:HSVToRGB(progress/fullcycle*360, 0.75, 1.0, 1.0)
		postProcess.Settings.ColorGain = {X=color.R, Y=color.G, Z=color.B}
		if timer >= duration or not postProcess:IsValid() then
			if postProcess:IsValid() then postProcess.Settings.ColorGain = {X=1.0, Y=1.0, Z=1.0} end
			return true
		end
		return false
	end)
end

function SummonDarkness(duration)
	local postProcess = FindFirstOf("PostProcessVolume")
	postProcess.Settings.bOverride_VignetteIntensity = 1
	postProcess.Settings.VignetteIntensity = 5.0
    ExecuteWithDelay(math.floor(duration*1000), function()
        if postProcess:IsValid() then postProcess.Settings.VignetteIntensity = 0.0 end
    end)
end

function RewindToPreviousRoom()
	gameInstance.pRoomManager:Warp(previousRoom, false, false, nullName, {R=0.0, G=0.0, B=0.0, A=1.0})
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

function ForceRandomEquipment(duration)
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
	interfaceHUD:DispShortcutMenu(true)
	EquipPlayerWeapon(currentWeapon, currentBullet)
	EquipPlayerShards(currentTriggerShard, currentEffectiveShard, currentDirectionalShard, currentEnchantShard, currentFamiliarShard)
	local preId1, postId1 = RegisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", function()
		interfaceHUD:DispShortcutMenu(true)
		EquipPlayerWeapon(currentWeapon, currentBullet)
		EquipPlayerShards(currentTriggerShard, currentEffectiveShard, currentDirectionalShard, currentEnchantShard, currentFamiliarShard)
    end)
    local preId2, postId2 = RegisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ChangeCurrentShortcut", function() end, function()
		interfaceHUD:DispShortcutMenu(true)
		EquipPlayerWeapon(currentWeapon, currentBullet)
		EquipPlayerShards(currentTriggerShard, currentEffectiveShard, currentDirectionalShard, currentEnchantShard, currentFamiliarShard)
    end)
    ExecuteWithDelay(math.floor(duration*1000), function()
		if player:IsValid() then
			ExecuteInGameThread(function()
				interfaceHUD:DispShortcutMenu(true)
				EquipPlayerWeapon(originalWeapon, originalBullet)
				EquipPlayerShards(originalTriggerShard, originalEffectiveShard, originalDirectionalShard, originalEnchantShard, originalFamiliarShard)
			end)
		end
	 	UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", preId1, postId1)
	 	UnregisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ChangeCurrentShortcut", preId2, postId2)
    end)
end

function ShardsOnly(duration)
    local player = GetPlayerCharacter()
	local inventory = player.CharacterInventory
	local interfaceHUD = FindFirstOf("PBInterfaceHUD")
	local originalWeapon = inventory.netEquipment.weapon
	local originalBullet = inventory.netEquipment.Bullet
	interfaceHUD:DispShortcutMenu(true)
    UnequipPlayerWeapon()
    local preId1, postId1 = RegisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", function()
		interfaceHUD:DispShortcutMenu(true)
        UnequipPlayerWeapon()
    end)
    local preId2, postId2 = RegisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ChangeCurrentShortcut", function() end, function()
		interfaceHUD:DispShortcutMenu(true)
        UnequipPlayerWeapon()
    end)
    ExecuteWithDelay(math.floor(duration*1000), function()
		if player:IsValid() then
			ExecuteInGameThread(function()
				interfaceHUD:DispShortcutMenu(true)
				EquipPlayerWeapon(originalWeapon, originalBullet)
			end)
		end
		UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", preId1, postId1)
		UnregisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ChangeCurrentShortcut", preId2, postId2)
    end)
end

function WeaponsOnly(duration)
    local player = GetPlayerCharacter()
	local inventory = player.CharacterInventory
	local interfaceHUD = FindFirstOf("PBInterfaceHUD")
	local triggerShard = inventory.netEquipment.TriggerShard
	local effectiveShard = inventory.netEquipment.EffectiveShard
	local directionalShard = inventory.netEquipment.DirectionalShard
	local enchantShard = inventory.netEquipment.EnchantShard
	local familiarShard = inventory.netEquipment.FamiliarShard
	interfaceHUD:DispShortcutMenu(true)
    UnequipPlayerShards()
    local preId1, postId1 = RegisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", function()
		interfaceHUD:DispShortcutMenu(true)
        UnequipPlayerShards()
    end)
    local preId2, postId2 = RegisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ChangeCurrentShortcut", function() end, function()
        interfaceHUD:DispShortcutMenu(true)
		UnequipPlayerShards()
    end)
    ExecuteWithDelay(math.floor(duration*1000), function()
		if player:IsValid() then
			ExecuteInGameThread(function()
				interfaceHUD:DispShortcutMenu(true)
				EquipPlayerShards(triggerShard, effectiveShard, directionalShard, enchantShard, familiarShard)
			end)
		end
		UnregisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", preId1, postId1)
		UnregisterHook("/Script/ProjectBlood.PBCharacterInventoryComponent:ChangeCurrentShortcut", preId2, postId2)
    end)
end

function ShuffleControls(duration)
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
    local preId1, postId1 = RegisterHook("/Script/ProjectBlood.PBInterfaceHUD:CallMenuEndPause", function()
		systemSettings:BindToGamepad_NO_CHECK(0, currentAttack)
		systemSettings:BindToGamepad_NO_CHECK(1, currentBackstep)
		systemSettings:BindToGamepad_NO_CHECK(2, currentJump)
		systemSettings:BindToGamepad_NO_CHECK(3, currentTrigger)
		systemSettings:BindToGamepad_NO_CHECK(4, currentDirectional)
		systemSettings:BindToGamepad_NO_CHECK(5, currentEffective)
		systemSettings:BindToGamepad_NO_CHECK(7, currentShortcut)
    end)
    ExecuteWithDelay(math.floor(duration*1000), function()
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
    end)
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

RegisterKeyBind(Key.F1, function()
    ExecuteInGameThread(function()
        WeaponsOnly(10.0)
    end)
end)

RegisterKeyBind(Key.F2, function()
    ExecuteInGameThread(function()
        ShardsOnly(10.0)
    end)
end)

RegisterKeyBind(Key.F3, function()
    ExecuteInGameThread(function()
        ForceRandomEquipment(10.0)
    end)
end)

RegisterKeyBind(Key.F4, function()
    ExecuteInGameThread(function()
        CallTheLibrarian()
    end)
end)

RegisterKeyBind(Key.F5, function()
    ExecuteInGameThread(function()
        TurboEnemies(10.0)
    end)
end)

RegisterKeyBind(Key.F6, function()
    ExecuteInGameThread(function()
        EmptyHealth()
    end)
end)

RegisterKeyBind(Key.F7, function()
    ExecuteInGameThread(function()
        EmptyMagic()
    end)
end)

RegisterKeyBind(Key.F8, function()
    ExecuteInGameThread(function()
        ReturnBooks()
    end)
end)

RegisterKeyBind(Key.F9, function()
    ExecuteInGameThread(function()
        RandomizeColors()
    end)
end)

print("CC script loaded")