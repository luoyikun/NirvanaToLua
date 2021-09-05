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
				effectGoName = "3008_zidan",
				effectAsset = {
					BundleName = "effects/prefab/boss/3007_prefab",
					AssetName = "3008_zidan",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "attack_zidan",
			},
			{
				triggerEventName = "attack1/begin",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "3008_baozha",
				effectAsset = {
					BundleName = "effects/prefab/boss/3007_prefab",
					AssetName = "3008_baozha",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = true,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "attack",
			},
			{
				triggerEventName = "magic1_1/begin",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "3007_magic",
				effectAsset = {
					BundleName = "effects/prefab/boss/3007_prefab",
					AssetName = "3007_magic",
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
				triggerDelay = 0.5,
				triggerFreeDelay = 0.0,
				effectGoName = "3008_dazhao",
				effectAsset = {
					BundleName = "effects/prefab/boss/3007_prefab",
					AssetName = "3008_dazhao",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "magic",
			},
			{
				triggerEventName = "magic1_3/begin",
				triggerDelay = 0.6,
				triggerFreeDelay = 0.0,
				effectGoName = "3008_baozha2",
				effectAsset = {
					BundleName = "effects/prefab/boss/3007_prefab",
					AssetName = "3008_baozha2",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = true,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "magic_",
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