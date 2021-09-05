return {
	actorController = {
		projectiles = {
			{
				Action = "attack1",
				HurtPosition = 0,
				Projectile = {
					BundleName = "effects/prefab/boss/3057_prefab",
					AssetName = "3057001_Attack01_zidan",
				},
				ProjectilGoName = "3057001_Attack01_zidan",
				FromPosHierarchyPath = "Bip001/Bip001Prop1",
				DelayProjectileEff = 0.6,
				DeleProjectileDelay = 0.0,
				ProjectilNodeHierarchyPath = "guadian",
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
				triggerDelay = 0.6,
				triggerFreeDelay = 0.0,
				effectGoName = "3057001_Attack01",
				effectAsset = {
					BundleName = "effects/prefab/boss/3057_prefab",
					AssetName = "3057001_Attack01",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "attack1",
			},
			{
				triggerEventName = "magic1_1/begin",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "3057001_Magic2_ju",
				effectAsset = {
					BundleName = "effects/prefab/boss/3057_prefab",
					AssetName = "3057001_Magic2_ju",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "magic1_3/begin",
				effectBtnName = "3057001_Magic2_ju",
			},
			{
				triggerEventName = "magic1_3/begin",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "3057001_Magic2",
				effectAsset = {
					BundleName = "effects/prefab/boss/3057_prefab",
					AssetName = "3057001_Magic2",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "Magic2",
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