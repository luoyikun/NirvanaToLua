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
				effectGoName = "attack_1",
				effectAsset = {
					BundleName = "effects/prefab/boss/3025_prefab",
					AssetName = "attack_1",
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
				effectGoName = "magic",
				effectAsset = {
					BundleName = "effects/prefab/boss/3025_prefab",
					AssetName = "magic",
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
				effectGoName = "magic_2",
				effectAsset = {
					BundleName = "effects/prefab/boss/3025_prefab",
					AssetName = "magic_2",
				},
				playerAtTarget = true,
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