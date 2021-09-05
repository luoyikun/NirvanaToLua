return {
	actorController = {
		projectiles = {
			{
				Action = "attack1",
				HurtPosition = 0,
				Projectile = {
					BundleName = "effects/prefab/boss/3048_prefab",
					AssetName = "3048_attack",
				},
				ProjectilGoName = "3048_attack",
				FromPosHierarchyPath = "buff_middle",
				DelayProjectileEff = 0.5,
				DeleProjectileDelay = 0.0,
				ProjectilNodeHierarchyPath = "GameObject",
				ProjectileBtnName = "按钮",
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
				effectGoName = "3048_xuli",
				effectAsset = {
					BundleName = "effects/prefab/boss/3048_prefab",
					AssetName = "3048_xuli",
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
				triggerDelay = 0.4,
				triggerFreeDelay = 0.0,
				effectGoName = "3048_dazhao",
				effectAsset = {
					BundleName = "effects/prefab/boss/3048_prefab",
					AssetName = "3048_dazhao",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = true,
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