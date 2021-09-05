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
				triggerDelay = 0.4,
				triggerFreeDelay = 0.0,
				effectGoName = "3055_atk_kgh",
				effectAsset = {
					BundleName = "effects/prefab/boss/3055_prefab",
					AssetName = "3055_atk_kgh",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "atk1",
			},
			{
				triggerEventName = "attack1/begin",
				triggerDelay = 1.0,
				triggerFreeDelay = 0.0,
				effectGoName = "3055_atk_kgh",
				effectAsset = {
					BundleName = "effects/prefab/boss/3055_prefab",
					AssetName = "3055_atk_kgh",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "atk1_1",
			},
			{
				triggerEventName = "magic1_1/begin",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "3055_juqi_1",
				effectAsset = {
					BundleName = "effects/prefab/boss/3055_prefab",
					AssetName = "3055_juqi_1",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "magic1_2/end",
				effectBtnName = "juqi",
			},
			{
				triggerEventName = "magic1_3/hit",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "3055_magic1_02",
				effectAsset = {
					BundleName = "effects/prefab/boss/3055_prefab",
					AssetName = "3055_magic1_02",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "guadian",
				isAttach = true,
				isRotation = true,
				triggerStopEvent = "",
				effectBtnName = "atk3",
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