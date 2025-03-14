local UEHelpers = require("UEHelpers")
local gameInstance = FindFirstOf("PBGameInstance")

nullName = FName("None")
mathLibrary = UEHelpers:GetKismetMathLibrary(false)
gameplayStatics = UEHelpers:GetGameplayStatics(false)
utilityClass = StaticFindObject("/Script/ProjectBlood.PBUtility")
utility = StaticConstructObject(utilityClass, gameInstance, 0, 0, 0, nil, false, false, nil)
eventUtilityClass = StaticFindObject("/Script/ProjectBlood.PBEventUtility")
eventUtility = StaticConstructObject(eventUtilityClass, gameInstance, 0, 0, 0, nil, false, false, nil)
datatableUtilityClass = StaticFindObject("/Script/Engine.DataTableFunctionLibrary")
datatableUtility = StaticConstructObject(datatableUtilityClass, gameInstance, 0, 0, 0, nil, false, false, nil)
widgetBlueprintLibraryclass = StaticFindObject("/Script/UMG.WidgetBlueprintLibrary")
widgetBlueprintLibrary = StaticConstructObject(widgetBlueprintLibraryclass, gameInstance, 0, 0, 0, nil, false, false, nil)
assetRegistryHelpers = StaticFindObject("/Script/AssetRegistry.Default__AssetRegistryHelpers")

-- Update current room info for every room change

function ResetRoomHistory()
    currentRoom = nullName
    previousRoom1 = nullName
    previousRoom2 = nullName
end

ResetRoomHistory()

RegisterHook("/Script/ProjectBlood.PBRoomVolume:OnRoomVolumeOverlapEnd", function()
    local tempRoom = GetGameInstance().pRoomManager:GetCurrentRoomId()
    if currentRoom ~= tempRoom then
        if previousRoom1 ~= tempRoom then
            previousRoom2 = previousRoom1
        end
        previousRoom1 = currentRoom
        currentRoom = tempRoom
    end
end)

function GetGameInstance()
    if not gameInstance:IsValid() then
        gameInstance = FindFirstOf("PBGameInstance")
    end
    return gameInstance
end

function GetPlayerCharacter()
    return GetGameInstance():GetPlayerCharacter(0)
end

function GetPlayerController()
    return GetGameInstance():GetLocalPlayerController()
end

function GetClassName(object)
    return SplitString(object:GetFullName(), " ")[1]
end

function GetCharacterHealthRatio(character)
    return character.CharacterStatus.HitPoint/character.CharacterStatus:GetMaxHitPoint()
end

function GetCharacterMagicRatio(character)
    return character.CharacterStatus.MagicPoint/character.CharacterStatus:GetMaxMagicPoint()
end

function CompletionToCoinModifier(completion)
    return Lerp(10, 1, InvertSquircle(completion/100, 1.25))
end

function CompletionToEnemyLevel(completion)
    return RoundFloat(Lerp(1, 50, InvertSquircle(completion/100, 1.25)))
end

function GetCurrentRoomProperties()
    local datatableRow = {}
    local datatable = GetGameInstance().pMapManager.RoomMasterTable
    datatableUtility:GetDataTableRowFromName(datatable, currentRoom, datatableRow)
    return datatableRow.OutRow
end

function GetCurrentRoomOffsets()
    local player = GetPlayerCharacter()
    local playerLocation = player:K2_GetActorLocation()
    return playerLocation.X//1260.0, playerLocation.Z//720.0
end

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

function FindValidActorClass(classPath)
    local assetData = {["ObjectPath"] = FName(classPath)}
    return assetRegistryHelpers:GetAsset(assetData)
end

function SpawnActorFromClass(classPath, location, rotation)
    local actorClass = FindValidActorClass(classPath)
    local world = UEHelpers:GetWorld()
    return world:SpawnActor(actorClass, location, rotation)
end

function SetPlayerInputEnabled(flag)
    local playerController = GetPlayerController()
    local controllerID = flag and 0 or 1
    gameplayStatics:SetPlayerControllerID(playerController, controllerID)
end

function RoundFloat(value)
    return math.floor(value + 0.5)
end

function ClampValue(value, minimum, maximum)
    return math.min(math.max(minimum, value), maximum)
end

function Lerp(minimum, maximum, alpha)
    return minimum + (maximum - minimum)*alpha
end

function Squircle(value, exponent)
    return -(1-value^exponent)^(1/exponent)+1
end

function InvertSquircle(value, exponent)
    return (1-(-value+1)^exponent)^(1/exponent)
end

function SplitString(inString, separator)
    local list = {}
    for subString in string.gmatch(inString, "([^"..separator.."]+)") do
        table.insert(list, subString)
    end
    return list
end

function IsInList(list, item)
    for index = 1,#list,1 do
        if list[index] == item then return true end
    end
    return false
end

function IsInArray(array, item)
    for index = 1,#array,1 do
        if array[index]:get() == item then return true end
    end
    return false
end

function ItemInInventory(list, item)
    for index = 1,#list,1 do
        if list[index].ID:ToString() == item and list[index].Num > 0 then return true end
    end
    return false
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