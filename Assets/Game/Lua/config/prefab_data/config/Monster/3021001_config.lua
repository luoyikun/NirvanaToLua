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
				effectGoName = "3021_attack1",
				effectAsset = {
					BundleName = "effects/prefab/boss/3021001_prefab",
					AssetName = "3021_attack1",
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
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "Effect_mag1",
				effectAsset = {
					BundleName = "effects/prefab/boss/3021001_prefab",
					AssetName = "Effect_mag1",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "magic1_3/end",
				effectBtnName = "按钮",
			},
			{
				triggerEventName = "magic1_3/begin",
				triggerDelay = 0.48,
				triggerFreeDelay = 0.0,
				effectGoName = "W3_Effect_Mag2",
				effectAsset = {
					BundleName = "effects/prefab/boss/3021001_prefab",
					AssetName = "W3_Effect_Mag2",
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