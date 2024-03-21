UEHelpers = require("UEHelpers")

gameInstance = FindFirstOf("PBGameInstance")
utilityClass = StaticFindObject("/Script/ProjectBlood.PBUtility")
utility = StaticConstructObject(utilityClass, gameInstance, 0, 0, 0, nil, false, false, nil)
eventUtilityClass = StaticFindObject("/Script/ProjectBlood.PBEventUtility")
eventUtility = StaticConstructObject(eventUtilityClass, gameInstance, 0, 0, 0, nil, false, false, nil)
datatableUtilityClass = StaticFindObject("/Script/Engine.DataTableFunctionLibrary")
datatableUtility = StaticConstructObject(datatableUtilityClass, gameInstance, 0, 0, 0, nil, false, false, nil)
assetRegistryHelpers = StaticFindObject("/Script/AssetRegistry.Default__AssetRegistryHelpers")
nullName = FName("None")
gameplayStatics = UEHelpers:GetGameplayStatics(false)
mathLibrary = UEHelpers:GetKismetMathLibrary(false)

function GetPlayerCharacter()
    return gameInstance:GetPlayerCharacter(0)
end

previousRoom = nullName
currentRoom = nullName
local tempRoom = nullName
RegisterHook("/Script/ProjectBlood.PBRoomVolume:OnRoomVolumeOverlapEnd", function()
    tempRoom = gameInstance.pRoomManager:GetCurrentRoomId()
	if currentRoom ~= tempRoom then
		previousRoom = currentRoom
		currentRoom = tempRoom
	end
end)

function AbsoluteToRelativeLocation(absoultePosX, absoultePosZ)
	local roomOffsetX, roomOffsetZ = GetCurrentRoomOffsets()
	local relativePosX = absoultePosX - roomOffsetX*1260.0
	local relativePosZ = absoultePosZ - roomOffsetZ*720.0
	return relativePosX, relativePosZ
end

function RelativeToAbsoluteLocation(relativePosX, relativePosZ)
	local roomOffsetX, roomOffsetZ = GetCurrentRoomOffsets()
	local absoultePosX = relativePosX + roomOffsetX*1260.0
	local absoultePosZ = relativePosZ + roomOffsetZ*720.0
	return absoultePosX, absoultePosZ
end

function GetCurrentRoomOffsets()
    local player = GetPlayerCharacter()
	local playerLocation = player:K2_GetActorLocation()
	return playerLocation.X // 1260.0, playerLocation.Z // 720.0
end

function GetCurrentRoomProperties()
	local datatableRow = {}
	local datatable = gameInstance.pMapManager.RoomMasterTable
	datatableUtility:GetDataTableRowFromName(datatable, currentRoom, datatableRow)
	return datatableRow.OutRow
end

function GetCharacterHealthRatio(character)
	return character.CharacterStatus.HitPoint / character.CharacterStatus:GetMaxHitPoint()
end

function SpawnActorFromClass(classPath, location, rotation)
    local actorClass = StaticFindObject(classPath)
    local world = UEHelpers:GetWorld()
    return world:SpawnActor(actorClass, location, rotation)
end

function FindValidActorClass(classPath)
	local assetData = {["ObjectPath"] = FName(classPath)}
	return assetRegistryHelpers:GetAsset(assetData)
end

function RandomChoice(list)
	return list[math.random(#list)]
end

function PickAndRemove(list)
	local chosenIndex = math.random(#list)
	local chosenItem = list[chosenIndex]
	table.remove(list, chosenIndex)
	return chosenItem
end