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
				triggerDelay = 0.5,
				triggerFreeDelay = 0.0,
				effectGoName = "W3_1000_com1",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10004_prefab",
					AssetName = "W3_1000_com1",
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
				triggerDelay = 0.4,
				triggerFreeDelay = 0.0,
				effectGoName = "W3_1000_com2",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10004_prefab",
					AssetName = "W3_1000_com2",
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
				triggerDelay = 0.3,
				triggerFreeDelay = 0.0,
				effectGoName = "W3_1000_com3",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10004_prefab",
					AssetName = "W3_1000_com3",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "com3",
			},
			{
				triggerEventName = "attack2/begin",
				triggerDelay = 0.7,
				triggerFreeDelay = 0.0,
				effectGoName = "W3_10004_Attack2",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10004_prefab",
					AssetName = "W3_10004_Attack2",
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
				effectGoName = "W3_10004_Attack1_1",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10004_prefab",
					AssetName = "W3_10004_Attack1_1",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "atk1_1",
			},
			{
				triggerEventName = "attack1/begin",
				triggerDelay = 0.9,
				triggerFreeDelay = 0.0,
				effectGoName = "W3_1000_atk1_2",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10004_prefab",
					AssetName = "W3_1000_atk1_2",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "atk1_2",
			},
			{
				triggerEventName = "attack1/begin",
				triggerDelay = 0.5,
				triggerFreeDelay = 0.0,
				effectGoName = "W3_10004_Attack1_3",
				effectAsset = {
					BundleName = "effects/prefab/mingjiang/10004_prefab",
					AssetName = "W3_10004_Attack1_3",
				},
				playerAtTarget = false,
				referenceNodeHierarchyPath = "",
				isAttach = false,
				isRotation = false,
				triggerStopEvent = "",
				effectBtnName = "atk1_3",
			},
		},
		halts = {},

		sounds = {
			{
				soundEventName = "combo1_1/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen4",
					AssetName = "tianshen4_attack1",
				},
				soundAudioGoName = "tianshen4_attack1",
				soundIsMainRole = false,
			},
			{
				soundEventName = "attack1/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen4",
					AssetName = "tianshen4_skill1",
				},
				soundAudioGoName = "tianshen4_skill1",
				soundIsMainRole = false,
			},
			{
				soundEventName = "attack2/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen4",
					AssetName = "tianshen4_skill2",
				},
				soundAudioGoName = "tianshen4_skill2",
				soundIsMainRole = false,
			},
			{
				soundEventName = "combo1_2/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen4",
					AssetName = "tianshen4_attack2",
				},
				soundAudioGoName = "tianshen4_attack2",
				soundIsMainRole = false,
			},
			{
				soundEventName = "combo1_3/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen4",
					AssetName = "tianshen4_attack3",
				},
				soundAudioGoName = "tianshen4_attack3",
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