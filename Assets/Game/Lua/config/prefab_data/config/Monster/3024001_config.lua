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
				effectGoName = "3024001_attack1",
				effectAsset = {
					BundleName = "effects/prefab/boss/3024_prefab",
					AssetName = "3024001_attack1",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "atk1",
			},
			{
				triggerEventName = "magic1_1/begin",
				triggerDelay = 0.4,
				triggerFreeDelay = 0.0,
				effectGoName = "3024_juqi",
				effectAsset = {
					BundleName = "effects/prefab/boss/3024_prefab",
					AssetName = "3024_juqi",
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
				triggerDelay = 0.2,
				triggerFreeDelay = 0.0,
				effectGoName = "3024_magic_02",
				effectAsset = {
					BundleName = "effects/prefab/boss/3024_prefab",
					AssetName = "3024_magic_02",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "gongji",
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