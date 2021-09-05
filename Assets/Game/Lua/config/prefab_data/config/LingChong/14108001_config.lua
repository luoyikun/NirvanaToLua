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
				triggerDelay = 0.5,
				triggerFreeDelay = 0.0,
				effectGoName = "lingchong_jizhong",
				effectAsset = {
					BundleName = "effects/prefab/misc/lingchong_jizhong_prefab",
					AssetName = "lingchong_jizhong",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "attack1/begin",
			},
			{
				triggerEventName = "attack1/begin",
				triggerDelay = 0.55,
				triggerFreeDelay = 0.0,
				effectGoName = "lingchong_zidan",
				effectAsset = {
					BundleName = "effects/prefab/misc/lingchong_zidan_prefab",
					AssetName = "lingchong_zidan",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "attack1/begin",
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