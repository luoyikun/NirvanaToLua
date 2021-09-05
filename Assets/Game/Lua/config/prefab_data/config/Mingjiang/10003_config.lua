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
				triggerDelay = 0.3,
				triggerFreeDelay = 0.0,
				effectGoName = "10003_attack2",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10003_prefab",
					AssetName = "10003_attack2",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "atk2",
			},
			{
				triggerEventName = "attack1/begin",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "10003_attack2_1",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10003_prefab",
					AssetName = "10003_attack2_1",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "atk2_1",
			},
			{
				triggerEventName = "combo1_1/begin",
				triggerDelay = 0.3,
				triggerFreeDelay = 0.0,
				effectGoName = "10003_combo1",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10003_prefab",
					AssetName = "10003_combo1",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "combo1",
			},
			{
				triggerEventName = "combo1_2/begin",
				triggerDelay = 0.2,
				triggerFreeDelay = 0.0,
				effectGoName = "10003_combo2",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10003_prefab",
					AssetName = "10003_combo2",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "combo2",
			},
			{
				triggerEventName = "combo1_3/begin",
				triggerDelay = 0.4,
				triggerFreeDelay = 0.0,
				effectGoName = "10003_combo3",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10003_prefab",
					AssetName = "10003_combo3",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "combo3",
			},
			{
				triggerEventName = "attack2/begin",
				triggerDelay = 0.3,
				triggerFreeDelay = 0.0,
				effectGoName = "10003_attack02_xc",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10003_prefab",
					AssetName = "10003_attack02_xc",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "a",
			},
		},
		halts = {},

		sounds = {
			{
				soundEventName = "combo1_1/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen3",
					AssetName = "tianshen3_attack1",
				},
				soundAudioGoName = "tianshen3_attack1",
				soundIsMainRole = false,
			},
			{
				soundEventName = "attack1/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen3",
					AssetName = "tianshen3_skill1",
				},
				soundAudioGoName = "tianshen3_skill1",
				soundIsMainRole = false,
			},
			{
				soundEventName = "attack2/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen3",
					AssetName = "tianshen3_skill2",
				},
				soundAudioGoName = "tianshen3_skill2",
				soundIsMainRole = false,
			},
			{
				soundEventName = "combo1_2/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen3",
					AssetName = "tianshen3_attack2",
				},
				soundAudioGoName = "tianshen3_attack2",
				soundIsMainRole = false,
			},
			{
				soundEventName = "combo1_3/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen3",
					AssetName = "tianshen3_attack3",
				},
				soundAudioGoName = "tianshen3_attack3",
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