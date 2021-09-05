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
				triggerDelay = 0.65,
				triggerFreeDelay = 0.0,
				effectGoName = "3022_attack1",
				effectAsset = {
					BundleName = "effects/prefab/boss/3022_prefab",
					AssetName = "3022_attack1",
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
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "3022_juqi",
				effectAsset = {
					BundleName = "effects/prefab/boss/3022_prefab",
					AssetName = "3022_juqi",
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
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "3022_attack2",
				effectAsset = {
					BundleName = "effects/prefab/boss/3022_prefab",
					AssetName = "3022_attack2",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "guadian",
				isAttach = true,
				isRotation = true,
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