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
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "attack",
				effectAsset = {
					BundleName = "effects/prefab/boss/3072_prefab",
					AssetName = "attack",
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
				effectGoName = "juqi",
				effectAsset = {
					BundleName = "effects/prefab/boss/3072_prefab",
					AssetName = "juqi",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "magic1_3/begin",
				effectBtnName = "juqi",
			},
			{
				triggerEventName = "magic1_3/begin",
				triggerDelay = 0.65,
				triggerFreeDelay = 0.0,
				effectGoName = "magic",
				effectAsset = {
					BundleName = "effects/prefab/boss/3072_prefab",
					AssetName = "magic",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "magic",
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