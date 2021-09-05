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
				effectGoName = "10022_attack02",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10022_prefab",
					AssetName = "10022_attack02",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "atk1",
			},
			{
				triggerEventName = "attack2/begin",
				triggerDelay = 0.1,
				triggerFreeDelay = 0.0,
				effectGoName = "10022_attack01",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10022_prefab",
					AssetName = "10022_attack01",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "atk2",
			},
			{
				triggerEventName = "combo1_1/begin",
				triggerDelay = 0.3,
				triggerFreeDelay = 0.0,
				effectGoName = "10022_combo",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10022_prefab",
					AssetName = "10022_combo",
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
				triggerDelay = 0.3,
				triggerFreeDelay = 0.0,
				effectGoName = "10022_combo2",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10022_prefab",
					AssetName = "10022_combo2",
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
				triggerDelay = 0.5,
				triggerFreeDelay = 0.0,
				effectGoName = "10022_combo3",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10022_prefab",
					AssetName = "10022_combo3",
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
					BundleName = "audios/sfxs/tianshenskill/tianshen9",
					AssetName = "tianshen9_attack1",
				},
				soundAudioGoName = "tianshen9_attack1",
				soundIsMainRole = false,
			},
			{
				soundEventName = "attack1/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen9",
					AssetName = "tianshen9_skill1",
				},
				soundAudioGoName = "tianshen9_skill1",
				soundIsMainRole = false,
			},
			{
				soundEventName = "attack2/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen9",
					AssetName = "tianshen9_skill2",
				},
				soundAudioGoName = "tianshen9_skill2",
				soundIsMainRole = false,
			},
			{
				soundEventName = "combo1_2/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen9",
					AssetName = "tianshen9_attack2",
				},
				soundAudioGoName = "tianshen9_attack2",
				soundIsMainRole = false,
			},
			{
				soundEventName = "combo1_3/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen9",
					AssetName = "tianshen9_attack3",
				},
				soundAudioGoName = "tianshen9_attack3",
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