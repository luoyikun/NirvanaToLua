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
				effectGoName = "w3_10010_attack1_01",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10010_prefab",
					AssetName = "w3_10010_attack1_01",
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
				triggerDelay = 0.0,
				triggerFreeDelay = 1.0,
				effectGoName = "w3_10010_attack1_02",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10010_prefab",
					AssetName = "w3_10010_attack1_02",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "attack1",
			},
			{
				triggerEventName = "attack2/begin",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "w3_10010_attack2_01",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10010_prefab",
					AssetName = "w3_10010_attack2_01",
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
				triggerDelay = 0.4,
				triggerFreeDelay = 0.4,
				effectGoName = "w3_10010_attack2_02",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10010_prefab",
					AssetName = "w3_10010_attack2_02",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "attack2",
			},
			{
				triggerEventName = "combo1_1/begin",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "w3_combo1_1",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10010_prefab",
					AssetName = "w3_combo1_1",
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
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "",
				effectAsset = {},

				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "combo1_2",
			},
			{
				triggerEventName = "combo1_3/begin",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "w3_combo1_3",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10010_prefab",
					AssetName = "w3_combo1_3",
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
					BundleName = "audios/sfxs/tianshenskill/tianshen13",
					AssetName = "tianshen13_attack1",
				},
				soundAudioGoName = "tianshen13_attack1",
				soundIsMainRole = false,
			},
			{
				soundEventName = "attack1/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen13",
					AssetName = "tianshen13_skill1",
				},
				soundAudioGoName = "tianshen13_skill1",
				soundIsMainRole = false,
			},
			{
				soundEventName = "attack2/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen13",
					AssetName = "tianshen13_skill2",
				},
				soundAudioGoName = "tianshen13_skill2",
				soundIsMainRole = false,
			},
			{
				soundEventName = "combo1_2/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen13",
					AssetName = "tianshen13_attack2",
				},
				soundAudioGoName = "tianshen13_attack2",
				soundIsMainRole = false,
			},
			{
				soundEventName = "combo1_3/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen13",
					AssetName = "tianshen13_attack3",
				},
				soundAudioGoName = "tianshen13_attack3",
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