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
				effectGoName = "W3_3011001_effect_Attack1",
				effectAsset = {
					BundleName = "effects/prefab/boss/3011_prefab",
					AssetName = "W3_3011001_effect_Attack1",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "按钮",
			},
			{
				triggerEventName = "magic1_1/begin",
				triggerDelay = 0.2,
				triggerFreeDelay = 0.0,
				effectGoName = "W3_3011001_effect_01",
				effectAsset = {
					BundleName = "effects/prefab/boss/3011_prefab",
					AssetName = "W3_3011001_effect_01",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "magic1_3/begin",
				effectBtnName = "按钮",
			},
			{
				triggerEventName = "magic1_3/begin",
				triggerDelay = 0.2,
				triggerFreeDelay = 0.0,
				effectGoName = "W3_3011001_effect_02",
				effectAsset = {
					BundleName = "effects/prefab/boss/3011_prefab",
					AssetName = "W3_3011001_effect_02",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "按钮",
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