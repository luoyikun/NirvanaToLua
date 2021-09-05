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
				triggerEventName = "attack2/begin",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "w3_10007_attack2_1",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10007_prefab",
					AssetName = "w3_10007_attack2_1",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "attack2",
			},
			{
				triggerEventName = "attack2/begin",
				triggerDelay = 0.5,
				triggerFreeDelay = 0.0,
				effectGoName = "w3_10007_attack2_S",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10007_prefab",
					AssetName = "w3_10007_attack2_S",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "attack2",
			},
			{
				triggerEventName = "attack1/begin",
				triggerDelay = 0.25,
				triggerFreeDelay = 0.0,
				effectGoName = "w3_10007_attack1_01_ss",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10007_prefab",
					AssetName = "w3_10007_attack1_01_ss",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "attack1",
			},
			{
				triggerEventName = "attack1/begin",
				triggerDelay = 0.25,
				triggerFreeDelay = 0.0,
				effectGoName = "w3_10007_Attack1_ss",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10007_prefab",
					AssetName = "w3_10007_Attack1_ss",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "attack1",
			},
			{
				triggerEventName = "combo1_1/begin",
				triggerDelay = 0.3,
				triggerFreeDelay = 0.0,
				effectGoName = "w3_10007_combo1_1",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10007_prefab",
					AssetName = "w3_10007_combo1_1",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "combo1_1",
			},
			{
				triggerEventName = "combo1_2/begin",
				triggerDelay = 0.3,
				triggerFreeDelay = 0.0,
				effectGoName = "w3_10007_combo1_2",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10007_prefab",
					AssetName = "w3_10007_combo1_2",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "combo1_2",
			},
			{
				triggerEventName = "combo1_3/begin",
				triggerDelay = 0.5,
				triggerFreeDelay = 0.0,
				effectGoName = "w3_10007_combo1_3",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10007_prefab",
					AssetName = "w3_10007_combo1_3",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "combo1_3",
			},
		},
		halts = {},

		sounds = {
			{
				soundEventName = "combo1_1/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen10",
					AssetName = "tianshen10_attack1",
				},
				soundAudioGoName = "tianshen10_attack1",
				soundIsMainRole = false,
			},
			{
				soundEventName = "attack1/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen10",
					AssetName = "tianshen10_skill1",
				},
				soundAudioGoName = "tianshen10_skill1",
				soundIsMainRole = false,
			},
			{
				soundEventName = "attack2/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen10",
					AssetName = "tianshen10_skill2",
				},
				soundAudioGoName = "tianshen10_skill2",
				soundIsMainRole = false,
			},
			{
				soundEventName = "combo1_2/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen10",
					AssetName = "tianshen10_attack2",
				},
				soundAudioGoName = "tianshen10_attack2",
				soundIsMainRole = false,
			},
			{
				soundEventName = "combo1_3/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen10",
					AssetName = "tianshen10_attack3",
				},
				soundAudioGoName = "tianshen10_attack3",
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