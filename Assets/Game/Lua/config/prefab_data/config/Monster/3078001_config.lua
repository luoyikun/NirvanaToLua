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
				triggerDelay = 0.6,
				triggerFreeDelay = 0.0,
				effectGoName = "3078_atk1",
				effectAsset = {
					BundleName = "effects/prefab/boss/3078_prefab",
					AssetName = "3078_atk1",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "atk1",
			},
			{
				triggerEventName = "magic1_2/begin",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "3078_juqi",
				effectAsset = {
					BundleName = "effects/prefab/boss/3078_prefab",
					AssetName = "3078_juqi",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "magic1_2/end",
				effectBtnName = "juqi",
			},
			{
				triggerEventName = "magic1_3/begin",
				triggerDelay = 0.48,
				triggerFreeDelay = 0.0,
				effectGoName = "3078_jineng",
				effectAsset = {
					BundleName = "effects/prefab/boss/3078_prefab",
					AssetName = "3078_jineng",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "jineng",
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