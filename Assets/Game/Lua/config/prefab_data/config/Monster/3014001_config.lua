return {
	actorController = {
		projectiles = {
			{
				Action = "attack1",
				HurtPosition = 0,
				Projectile = {
					BundleName = "effects/prefab/boss/3014_prefab",
					AssetName = "3014001_Attack1_02_zidan",
				},
				ProjectilGoName = "3014001_Attack1_02_zidan",
				FromPosHierarchyPath = "Bip001/Bip001Prop1",
				DelayProjectileEff = 0.7,
				DeleProjectileDelay = 0.0,
				ProjectilNodeHierarchyPath = "",
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
				triggerDelay = 0.69,
				triggerFreeDelay = 0.0,
				effectGoName = "3014001_Attack1_01",
				effectAsset = {
					BundleName = "effects/prefab/boss/3014_prefab",
					AssetName = "3014001_Attack1_01",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "按钮",
			},
			{
				triggerEventName = "",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "3014001_Attack1_02_zidan",
				effectAsset = {
					BundleName = "effects/prefab/boss/3014_prefab",
					AssetName = "3014001_Attack1_02_zidan",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "Bip001/Bip001Prop1",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "按钮",
			},
			{
				triggerEventName = "magic1_1/begin",
				triggerDelay = 0.5,
				triggerFreeDelay = 0.0,
				effectGoName = "3014001_effect_01",
				effectAsset = {
					BundleName = "effects/prefab/boss/3014_prefab",
					AssetName = "3014001_effect_01",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "magic1_3/begin",
				effectBtnName = "按钮",
			},
			{
				triggerEventName = "magic1_3/begin",
				triggerDelay = 0.4,
				triggerFreeDelay = 0.0,
				effectGoName = "3014001_effect_03",
				effectAsset = {
					BundleName = "effects/prefab/boss/3014_prefab",
					AssetName = "3014001_effect_03",
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