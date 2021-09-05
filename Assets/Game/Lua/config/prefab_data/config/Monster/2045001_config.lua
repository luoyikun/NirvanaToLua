return {
	actorController = {
		projectiles = {
			{
				Action = "attack2",
				HurtPosition = 0,
				Projectile = {
					BundleName = "effects/prefab/boss/2045_prefab",
					AssetName = "effect_huoqiu_dc",
				},
				ProjectilGoName = "effect_huoqiu_dc",
				FromPosHierarchyPath = "Bone002/guadian01",
				DelayProjectileEff = 0.0,
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
				triggerEventName = "attack1/begin",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "effect_huoqiu_dc",
				effectAsset = {
					BundleName = "effects/prefab/boss/2045_prefab",
					AssetName = "effect_huoqiu_dc",
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