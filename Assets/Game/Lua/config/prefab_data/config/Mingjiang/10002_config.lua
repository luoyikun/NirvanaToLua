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
				triggerEventName = "combo1_1/begin",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "10002_Combo_01_ljf",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10002_prefab",
					AssetName = "10002_Combo_01_ljf",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = true,
				triggerStopEvent = "",
				effectBtnName = "Combo_1",
			},
			{
				triggerEventName = "combo1_2/begin",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "10002_Combo_02_ljf",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10002_prefab",
					AssetName = "10002_Combo_02_ljf",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = true,
				triggerStopEvent = "",
				effectBtnName = "Combo_2",
			},
			{
				triggerEventName = "combo1_3/begin",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "10002_Combo_03_ljf",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10002_prefab",
					AssetName = "10002_Combo_03_ljf",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = true,
				triggerStopEvent = "",
				effectBtnName = "Combo_3",
			},
			{
				triggerEventName = "attack1/begin",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "10002_atk_1_ljf",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10002_prefab",
					AssetName = "10002_atk_1_ljf",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = true,
				triggerStopEvent = "",
				effectBtnName = "Attack_01",
			},
			{
				triggerEventName = "attack2/begin",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "10002_atk_2_ljf",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10002_prefab",
					AssetName = "10002_atk_2_ljf",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "Attack_02",
			},
		},
		halts = {},

		sounds = {
			{
				soundEventName = "combo1_1/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen2",
					AssetName = "tianshen2_attack1",
				},
				soundAudioGoName = "tianshen2_attack1",
				soundIsMainRole = false,
			},
			{
				soundEventName = "attack1/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen2",
					AssetName = "tianshen2_skill1",
				},
				soundAudioGoName = "tianshen2_skill1",
				soundIsMainRole = false,
			},
			{
				soundEventName = "attack2/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen2",
					AssetName = "tianshen2_skill2",
				},
				soundAudioGoName = "tianshen2_skill2",
				soundIsMainRole = false,
			},
			{
				soundEventName = "combo1_2/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen2",
					AssetName = "tianshen2_attack2",
				},
				soundAudioGoName = "tianshen2_attack2",
				soundIsMainRole = false,
			},
			{
				soundEventName = "combo1_3/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen2",
					AssetName = "tianshen2_attack3",
				},
				soundAudioGoName = "tianshen2_attack3",
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