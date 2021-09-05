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
				triggerDelay = 0.8,
				triggerFreeDelay = 0.0,
				effectGoName = "3050001_attack01",
				effectAsset = {
					BundleName = "effects/prefab/boss/3050_prefab",
					AssetName = "3050001_attack01",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "attack1",
			},
			{
				triggerEventName = "magic1_3/begin",
				triggerDelay = 0.45,
				triggerFreeDelay = 0.0,
				effectGoName = "3050001_Magic1_3",
				effectAsset = {
					BundleName = "effects/prefab/boss/3050_prefab",
					AssetName = "3050001_Magic1_3",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "Magic1_3",
			},
			{
				triggerEventName = "magic1_1/begin",
				triggerDelay = 0.2,
				triggerFreeDelay = 0.0,
				effectGoName = "3050001_Magic1",
				effectAsset = {
					BundleName = "effects/prefab/boss/3050_prefab",
					AssetName = "3050001_Magic1",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "magic1_3/begin",
				effectBtnName = "Magic1_1",
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