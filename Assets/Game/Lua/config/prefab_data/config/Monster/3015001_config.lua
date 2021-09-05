return {
	actorController = {
		projectiles = {},

		hurts = {},

		beHurtEffecct = {},

		hurtEffectName = "",
		beHurtNodeName = "",
		beHurtAttach = false,
		hurtEffectFreeDelay = 0.0,
		QualityCtrlList = {},

	},
	actorTriggers = {
		effects = {
			{
				triggerEventName = "attack1/begin",
				triggerDelay = 0.27,
				triggerFreeDelay = 0.0,
				effectGoName = "3015_attack",
				effectAsset = {
					BundleName = "effects/prefab/boss/3015_prefab",
					AssetName = "3015_attack",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "attack",
			},
			{
				triggerEventName = "magic1_1/begin",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "3015_magic2",
				effectAsset = {
					BundleName = "effects/prefab/boss/3015_prefab",
					AssetName = "3015_magic2",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "magic1_3/begin",
				effectBtnName = "xuli",
			},
			{
				triggerEventName = "magic1_3/begin",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "3015_magic_1",
				effectAsset = {
					BundleName = "effects/prefab/boss/3015_prefab",
					AssetName = "3015_magic_1",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "magic",
			},
			{
				triggerEventName = "magic1_3/begin",
				triggerDelay = 0.5,
				triggerFreeDelay = 0.0,
				effectGoName = "3015_magic_2",
				effectAsset = {
					BundleName = "effects/prefab/boss/3015_prefab",
					AssetName = "3015_magic_2",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = true,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "magic_",
			},
		},
		halts = {},

		sounds = {},

		cameraShakes = {},

		cameraFOVs = {},

		sceneFades = {},

		footsteps = {},

	},
	actorBlinker = {
		blinkFadeIn = 0.0,
		blinkFadeHold = 0.0,
		blinkFadeOut = 0.0,
	},
	TimeLineList = {},

}