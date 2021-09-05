return {
	actorController = {
		projectiles = {
			{
				Action = "attack1",
				HurtPosition = 0,
				Projectile = {
					BundleName = "effects/prefab/boss/3071_prefab",
					AssetName = "attack",
				},
				ProjectilGoName = "attack",
				FromPosHierarchyPath = "",
				DelayProjectileEff = 0.5,
				DeleProjectileDelay = 0.0,
				ProjectilNodeHierarchyPath = "",
				ProjectileBtnName = "attack",
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
				effectGoName = "xuli",
				effectAsset = {
					BundleName = "effects/prefab/boss/3071_prefab",
					AssetName = "xuli",
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
				effectGoName = "magic",
				effectAsset = {
					BundleName = "effects/prefab/boss/3071_prefab",
					AssetName = "magic",
				},
				playerAtTarget = false,
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