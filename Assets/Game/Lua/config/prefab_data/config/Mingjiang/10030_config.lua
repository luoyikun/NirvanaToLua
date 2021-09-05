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
				triggerDelay = 0.35,
				triggerFreeDelay = 0.0,
				effectGoName = "10030_Attack1",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10030_prefab",
					AssetName = "10030_Attack1",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "atk1",
			},
			{
				triggerEventName = "attack1/begin",
				triggerDelay = 0.3,
				triggerFreeDelay = 0.0,
				effectGoName = "10030_attack1_01",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10030_prefab",
					AssetName = "10030_attack1_01",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "atk1_1",
			},
			{
				triggerEventName = "attack2/begin",
				triggerDelay = 0.4,
				triggerFreeDelay = 0.0,
				effectGoName = "10030_Attack2_02",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10030_prefab",
					AssetName = "10030_Attack2_02",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "atk2_2",
			},
			{
				triggerEventName = "combo1_1/begin",
				triggerDelay = 0.07,
				triggerFreeDelay = 0.0,
				effectGoName = "combo1",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10030_prefab",
					AssetName = "combo1",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "com1",
			},
			{
				triggerEventName = "combo1_2/begin",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "combo2",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10030_prefab",
					AssetName = "combo2",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "com2",
			},
			{
				triggerEventName = "combo1_3/begin",
				triggerDelay = 0.1,
				triggerFreeDelay = 0.0,
				effectGoName = "combo3",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10030_prefab",
					AssetName = "combo3",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "com3",
			},
		},
		halts = {},

		sounds = {
			{
				soundEventName = "combo1_1/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen11",
					AssetName = "tianshen11_attack1",
				},
				soundAudioGoName = "tianshen11_attack1",
				soundIsMainRole = false,
			},
			{
				soundEventName = "attack1/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen11",
					AssetName = "tianshen11_skill1",
				},
				soundAudioGoName = "tianshen11_skill1",
				soundIsMainRole = false,
			},
			{
				soundEventName = "attack2/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen11",
					AssetName = "tianshen11_skill2",
				},
				soundAudioGoName = "tianshen11_skill2",
				soundIsMainRole = false,
			},
			{
				soundEventName = "combo1_2/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen11",
					AssetName = "tianshen11_attack2",
				},
				soundAudioGoName = "tianshen11_attack2",
				soundIsMainRole = false,
			},
			{
				soundEventName = "combo1_3/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen11",
					AssetName = "tianshen11_attack3",
				},
				soundAudioGoName = "tianshen11_attack3",
				soundIsMainRole = false,
			},
		},
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