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
				triggerDelay = 0.11,
				triggerFreeDelay = 0.0,
				effectGoName = "3075_atk1",
				effectAsset = {
					BundleName = "effects/prefab/boss/3075_prefab",
					AssetName = "3075_atk1",
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
				effectGoName = "3075_juli",
				effectAsset = {
					BundleName = "effects/prefab/boss/3075_prefab",
					AssetName = "3075_juli",
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
				effectGoName = "3075_jineng",
				effectAsset = {
					BundleName = "effects/prefab/boss/3075_prefab",
					AssetName = "3075_jineng",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "jineng",
			},
			{
				triggerEventName = "magic1_3/begin",
				triggerDelay = 0.7,
				triggerFreeDelay = 0.0,
				effectGoName = "3075_jineng2",
				effectAsset = {
					BundleName = "effects/prefab/boss/3075_prefab",
					AssetName = "3075_jineng2",
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