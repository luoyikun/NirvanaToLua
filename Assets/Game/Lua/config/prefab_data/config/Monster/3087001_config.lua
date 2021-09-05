return {
	actorController = {
		projectiles = {
			{
				Action = "attack1",
				HurtPosition = 0,
				Projectile = {
					BundleName = "effects/prefab/boss/3087_prefab",
					AssetName = "attack",
				},
				ProjectilGoName = "attack",
				FromPosHierarchyPath = "3087001/Bip001/Bip001Pelvis/Bip001Spine/Bip001Spine1/Bip002/Bip002Pelvis/Bip002Spine/Bip002Spine1/Bip002Neck/Bip002RClavicle/Bip002RUpperArm/Bip002RForearm/Bip002RHand/Bone057/Bone058/Bone059/guadian001",
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
				triggerEventName = "magic1_2/begin",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "xuli",
				effectAsset = {
					BundleName = "effects/prefab/boss/3087_prefab",
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
				effectGoName = "3087_magic",
				effectAsset = {
					BundleName = "effects/prefab/boss/3087_prefab",
					AssetName = "3087_magic",
				},
				playerAtTarget = true,
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