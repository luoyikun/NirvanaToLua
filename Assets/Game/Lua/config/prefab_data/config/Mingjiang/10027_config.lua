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
				triggerDelay = 0.1,
				triggerFreeDelay = 0.0,
				effectGoName = "10027_attack01",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10027_prefab",
					AssetName = "10027_attack01",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "attack1",
			},
			{
				triggerEventName = "attack2/begin",
				triggerDelay = 0.3,
				triggerFreeDelay = 0.0,
				effectGoName = "10027_attack02",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10027_prefab",
					AssetName = "10027_attack02",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "attack2",
			},
			{
				triggerEventName = "combo1_1/begin",
				triggerDelay = 0.05,
				triggerFreeDelay = 0.0,
				effectGoName = "combo1",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10027_prefab",
					AssetName = "combo1",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "combo1",
			},
			{
				triggerEventName = "combo1_2/begin",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "combo2",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10027_prefab",
					AssetName = "combo2",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "combo2",
			},
			{
				triggerEventName = "combo1_3/begin",
				triggerDelay = 0.1,
				triggerFreeDelay = 0.0,
				effectGoName = "combo3",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10027_prefab",
					AssetName = "combo3",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "combo3",
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