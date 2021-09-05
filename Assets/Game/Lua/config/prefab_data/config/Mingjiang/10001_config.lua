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
				effectGoName = "W3_10001_attack2",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10001_prefab",
					AssetName = "W3_10001_attack2",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "Attack1",
			},
			{
				triggerEventName = "attack2/begin",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "w3_10001_attack1",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10001_prefab",
					AssetName = "w3_10001_attack1",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "Attack2",
			},
			{
				triggerEventName = "combo1_1/begin",
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "w3_10001_com1",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10001_prefab",
					AssetName = "w3_10001_com1",
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
				effectGoName = "w3_10001_com2",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10001_prefab",
					AssetName = "w3_10001_com2",
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
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "w3_10001_com3",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10001_prefab",
					AssetName = "w3_10001_com3",
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
					BundleName = "audios/sfxs/tianshenskill/tianshen1",
					AssetName = "tianshen1_attack1",
				},
				soundAudioGoName = "tianshen1_attack1",
				soundIsMainRole = false,
			},
			{
				soundEventName = "attack1/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen1",
					AssetName = "tianshen1_skill1",
				},
				soundAudioGoName = "tianshen1_skill1",
				soundIsMainRole = false,
			},
			{
				soundEventName = "attack2/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen1",
					AssetName = "tianshen1_skill2",
				},
				soundAudioGoName = "tianshen1_skill2",
				soundIsMainRole = false,
			},
			{
				soundEventName = "combo1_2/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen1",
					AssetName = "tianshen1_attack2",
				},
				soundAudioGoName = "tianshen1_attack2",
				soundIsMainRole = false,
			},
			{
				soundEventName = "combo1_3/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen1",
					AssetName = "tianshen1_attack3",
				},
				soundAudioGoName = "tianshen1_attack3",
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