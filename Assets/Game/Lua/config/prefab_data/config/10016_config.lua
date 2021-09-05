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
		effects = {},

		halts = {},

		sounds = {
			{
				soundEventName = "attack1/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen7",
					AssetName = "tianshen7_attack1",
				},
				soundAudioGoName = "tianshen7_attack1",
				soundIsMainRole = false,
			},
			{
				soundEventName = "attack2/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen7",
					AssetName = "tianshen7_skill1",
				},
				soundAudioGoName = "tianshen7_skill1",
				soundIsMainRole = false,
			},
			{
				soundEventName = "attack3/begin",
				soundDelay = 0.0,
				soundAudioAsset = {
					BundleName = "audios/sfxs/tianshenskill/tianshen7",
					AssetName = "tianshen7_skill2",
				},
				soundAudioGoName = "tianshen7_skill2",
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