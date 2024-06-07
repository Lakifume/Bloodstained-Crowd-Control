timedEffects = {}
timedEffectsWerePaused = false

displayNotifications = true

shrinkPlayerActive = false
growPlayerActive = false
flipPlayerActive = false
shuffleControlsActive = false
useWitchTimeActive = false
turboEnemiesActive = false
uncontrollableSpeedActive = false
criticalModeActive = false
goldRushActive = false
summonRaveActive = false
summonDarknessActive = false
forceInvertActive = false
noSkillShardsActive = false
weaponsOnlyActive = false
shardsOnlyActive = false
forceEquipmentActive = false
heavenOrHellActive = false
orlokStandbyActive = false

sizeChangeCurrentModifier = nil

flipPlayerRoomChangePreHook = nil
flipPlayerRoomChangePostHook = nil

shuffleControlsOriginalAttack = nil
shuffleControlsOriginalBackstep = nil
shuffleControlsOriginalJump = nil
shuffleControlsOriginalTrigger = nil
shuffleControlsOriginalDirectional = nil
shuffleControlsOriginalEffective = nil
shuffleControlsOriginalShortcut = nil
shuffleControlsUnpausePreHook = nil
shuffleControlsUnpausePostHook = nil

useWitchTimeShouldStopEffect = false
turboEnemiesShouldStopEffect = false

goldRushMoneyGain = nil
goldRushDamagePopupPreHook = nil
goldRushDamagePopupPostHook = nil
goldRushDamagePopup = nil

summonRaveShouldStopEffect = false

forceInvertUnpausePreHook = nil
forceInvertUnpausePostHook = nil

noSkillShardsUnpausePreHook = nil
noSkillShardsUnpausePostHook = nil

equipmentChangeUnpausePreHook = nil
equipmentChangeUnpausePostHook = nil
equipmentChangeShortcutPreHook = nil
equipmentChangeShortcutPostHook = nil

equipmentChangeOriginalWeapon = nil
equipmentChangeOriginalBullet = nil
equipmentChangeOriginalTrigger = nil
equipmentChangeOriginalEffective = nil
equipmentChangeOriginalDirectional = nil
equipmentChangeOriginalEnchant = nil
equipmentChangeOriginalFamiliar = nil

heavenOrHellDamageEventPreHook = nil
heavenOrHellDamageEventPostHook = nil

orlokStandbySaveRoomPreHook = nil
orlokStandbySaveRoomPostHook = nil

modifyAttributeOriginalAttribute = {}
modifyAttributeUnpausePreHook = {}
modifyAttributeUnpausePostHook = {}
modifyAttributeShortcutPreHook = {}
modifyAttributeShortcutPostHook = {}
modifyAttributeBorrowPreHook = {}
modifyAttributeBorrowPostHook = {}
modifyAttributeReturnPreHook = {}
modifyAttributeReturnPostHook = {}