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
				effectGoName = "10005_attack_02_ljf",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10005_prefab",
					AssetName = "10005_attack_02_ljf",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = true,
				triggerStopEvent = "",
				effectBtnName = "Attack_1",
			},
			{
				triggerEventName = "attack2/begin",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "10005_attack_01_ljf_02",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10005_prefab",
					AssetName = "10005_attack_01_ljf_02",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = true,
				triggerStopEvent = "",
				effectBtnName = "Attack_2",
			},
			{
				triggerEventName = "combo1_1/begin",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "10005_Com_01_ljf",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10005_prefab",
					AssetName = "10005_Com_01_ljf",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = true,
				triggerStopEvent = "",
				effectBtnName = "Com_01",
			},
			{
				triggerEventName = "combo1_2/begin",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "10005_Com_02_ljf",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10005_prefab",
					AssetName = "10005_Com_02_ljf",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = true,
				triggerStopEvent = "",
				effectBtnName = "Com_02",
			},
			{
				triggerEventName = "combo1_3/begin",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "10005_Com_03_ljf",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10005_prefab",
					AssetName = "10005_Com_03_ljf",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = true,
				triggerStopEvent = "",
				effectBtnName = "Com_03",
			},
		},
		halts = {},

		sounds = {
			{
				soundEventName = "combo1_1/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen5",
					AssetName = "tianshen5_attack1",
				},
				soundAudioGoName = "tianshen5_attack1",
				soundIsMainRole = false,
			},
			{
				soundEventName = "attack1/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen5",
					AssetName = "tianshen5_skill1",
				},
				soundAudioGoName = "tianshen5_skill1",
				soundIsMainRole = false,
			},
			{
				soundEventName = "attack2/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen5",
					AssetName = "tianshen5_skill2",
				},
				soundAudioGoName = "tianshen5_skill2",
				soundIsMainRole = false,
			},
			{
				soundEventName = "combo1_2/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen5",
					AssetName = "tianshen5_attack2",
				},
				soundAudioGoName = "tianshen5_attack2",
				soundIsMainRole = false,
			},
			{
				soundEventName = "combo1_3/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen5",
					AssetName = "tianshen5_attack3",
				},
				soundAudioGoName = "tianshen5_attack3",
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