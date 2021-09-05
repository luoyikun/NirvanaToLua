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
				effectGoName = "10020_atk1",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10020_prefab",
					AssetName = "10020_atk1",
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
				triggerDelay = 0.6,
				triggerFreeDelay = 0.0,
				effectGoName = "10020_atk2_02",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10020_prefab",
					AssetName = "10020_atk2_02",
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
				triggerDelay = 0.45,
				triggerFreeDelay = 0.0,
				effectGoName = "10020_atk2_01",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10020_prefab",
					AssetName = "10020_atk2_01",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "attack_1",
			},
			{
				triggerEventName = "combo1_1/begin",
				triggerDelay = 0.15,
				triggerFreeDelay = 0.0,
				effectGoName = "combo1",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10020_prefab",
					AssetName = "combo1",
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
				triggerDelay = 0.0,
				triggerFreeDelay = 0.0,
				effectGoName = "combo2",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10020_prefab",
					AssetName = "combo2",
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
				triggerDelay = 0.05,
				triggerFreeDelay = 0.0,
				effectGoName = "combo3",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10020_prefab",
					AssetName = "combo3",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "combo3",
			},
		},
		halts = {},

		sounds = {
			{
				soundEventName = "combo1_1/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen14",
					AssetName = "tianshen14_attack1",
				},
				soundAudioGoName = "tianshen14_attack1",
				soundIsMainRole = false,
			},
			{
				soundEventName = "attack1/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen14",
					AssetName = "tianshen14_skill1",
				},
				soundAudioGoName = "tianshen14_skill1",
				soundIsMainRole = false,
			},
			{
				soundEventName = "attack2/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen14",
					AssetName = "tianshen14_skill2",
				},
				soundAudioGoName = "tianshen14_skill2",
				soundIsMainRole = false,
			},
			{
				soundEventName = "combo1_2/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen14",
					AssetName = "tianshen14_attack2",
				},
				soundAudioGoName = "tianshen14_attack2",
				soundIsMainRole = false,
			},
			{
				soundEventName = "combo1_3/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen14",
					AssetName = "tianshen14_attack3",
				},
				soundAudioGoName = "tianshen14_attack3",
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