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
				effectGoName = "3085_Attack_01",
				effectAsset = {
					BundleName = "actors/monster/3085_prefab",
					AssetName = "3085_Attack_01",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = true,
				triggerStopEvent = "",
				effectBtnName = "Attack",
			},
			{
				triggerEventName = "magic1_1/begin",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "3085_skill_juqi",
				effectAsset = {
					BundleName = "actors/monster/3085_prefab",
					AssetName = "3085_skill_juqi",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = true,
				isRotation = true,
				triggerStopEvent = "magic1_3/begin",
				effectBtnName = "skill_juqi",
			},
			{
				triggerEventName = "magic1_3/begin",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "3085_skill_baofa",
				effectAsset = {
					BundleName = "actors/monster/3085_prefab",
					AssetName = "3085_skill_baofa",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = true,
				triggerStopEvent = "",
				effectBtnName = "skill_baofa",
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