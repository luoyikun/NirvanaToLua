return {
	actorController = {
		projectiles = {
			{
				Action = "attack1",
				HurtPosition = 0,
				Projectile = {
					BundleName = "effects/prefab/boss/3008_prefab",
					AssetName = "3008_attack01",
				},
				ProjectilGoName = "3008_attack01",
				FromPosHierarchyPath = "buff_middle",
				DelayProjectileEff = 0.6,
				DeleProjectileDelay = 0.0,
				ProjectilNodeHierarchyPath = "guadian",
				ProjectileBtnName = "atk1",
			},
		},
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
				triggerEventName = "magic1_1/begin",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "3008_juqi",
				effectAsset = {
					BundleName = "effects/prefab/boss/3008_prefab",
					AssetName = "3008_juqi",
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
				triggerDelay = 0.3,
				triggerFreeDelay = 0.0,
				effectGoName = "3008_attack03_01",
				effectAsset = {
					BundleName = "effects/prefab/boss/3008_prefab",
					AssetName = "3008_attack03_01",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "atk3",
			},
			{
				triggerEventName = "magic1_3/begin",
				triggerDelay = 1.0,
				triggerFreeDelay = 0.0,
				effectGoName = "3008_attack03_02",
				effectAsset = {
					BundleName = "effects/prefab/boss/3008_prefab",
					AssetName = "3008_attack03_02",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "atk3_1",
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