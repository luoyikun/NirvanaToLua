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
				effectGoName = "3053001_attact01",
				effectAsset = {
					BundleName = "effects/prefab/boss/3053_prefab",
					AssetName = "3053001_attact01",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "Attack1",
			},
			{
				triggerEventName = "magic1_3/begin",
				triggerDelay = 0.1,
				triggerFreeDelay = 0.0,
				effectGoName = "3053001_Magic1_3",
				effectAsset = {
					BundleName = "effects/prefab/boss/3053_prefab",
					AssetName = "3053001_Magic1_3",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "guadian_left_eye",
				isAttach = true,
				isRotation = true,
				triggerStopEvent = "",
				effectBtnName = "Magic1_3",
			},
			{
				triggerEventName = "magic1_1/begin",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "3053001_Magic1",
				effectAsset = {
					BundleName = "effects/prefab/boss/3053_prefab",
					AssetName = "3053001_Magic1",
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