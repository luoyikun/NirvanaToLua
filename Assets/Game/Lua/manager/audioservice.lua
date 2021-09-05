require("manager/audio_data")
-- 音频管理
AudioService = AudioService or BaseClass()

function AudioService:__init()
	if AudioService.Instance ~= nil then
		print_error("AudioService to create singleton twice!")
	end
	AudioService.Instance = self

	self.data = AudioData.New()

	self.music_volume = 1.0
	self.sfx_volume = 1.0
	self.master_volume = 1.0
	self.audio_mixer = nil

	local loader = AllocResAsyncLoader(self, "audio_main")
	loader:Load("audios/mixers", "Audio_Main", typeof(UnityEngine.Audio.AudioMixer), BindTool.Bind(self.OnLoadComplete, self))
end

function AudioService:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.audio_player then
		self:StopBgm()
		self.audio_player = nil
	end

	self:ReleaseAudio()
end

function AudioService:OnLoadComplete(mixer)
	self.audio_mixer = mixer
	self.audio_mixer:SetFloat("MusicVolume", self.music_volume)
	self.audio_mixer:SetFloat("SFXVolume", self.sfx_volume)
	self.audio_mixer:SetFloat("MasterVolume", self.master_volume)
end

function AudioService:SetMusicVolume(volume)
	self.music_volume = volume
	if self.audio_mixer ~= nil then
		self.audio_mixer:SetFloat("MusicVolume", 80 * self.music_volume - 80)
	end
end

function AudioService:SetSFXVolume(volume)
	self.sfx_volume = volume
	if self.audio_mixer ~= nil then
		self.audio_mixer:SetFloat("SFXVolume", 80 * self.sfx_volume - 80)
	end
end

-- 播放领取奖励的音效
function AudioService:PlayRewardAudio()
	local audio_config = AudioData.Instance:GetAudioConfig()
	if audio_config then
		AudioManager.PlayAndForget("audios/sfxs/other", audio_config.other[1].Rewards)
	end
end

-- 播放进阶成功的音效
function AudioService:PlayAdvancedAudio()
	local audio_config = AudioData.Instance:GetAudioConfig()
	if audio_config then
		AudioManager.PlayAndForget("audios/sfxs/uis", audio_config.other[1].Advanced)
	end
end

-- 得到当前音效音量
function AudioService:GetSFXVolume()
	return self.sfx_volume
end

--关闭所有声音
function AudioService:SetMasterVolume(volume)
	self.master_volume = volume
	if self.audio_mixer ~= nil then
		self.audio_mixer:SetFloat("MasterVolume", 80 * self.master_volume - 80)
	end
end

--得到当前总音量
function AudioService:GetMasterVolume()
	return self.master_volume
end

-- 播放背景音乐
function AudioService:PlayBgm(bundle, asset)
	self:ReleaseAudio()

	AudioManager.Play(bundle, asset, nil, nil, function(player)
		self.audio_player = player
	end, nil, true)
end

function AudioService:StopBgm()
	self.audio_player:Stop()
end

function AudioService:ReleaseAudio()
	if self.audio_player then
		AudioManager.StopAudio(self.audio_player)
		self.audio_player = nil
	end
end

-- 初始化收费聊天
-- appID：1079581309 
-- appKey：369793e6c89cf9b7c29f27f182149c15
-- ServerInfo：Voice服务器地址，默认为空
-- Language：翻译的语言（ China = 0, Korean = 1, English = 2, Japanese = 3）
function AudioService:InitFeesAudio()
	if IS_FEES_VOICE then
		local appID = "1079581309" 
		local appKey = "369793e6c89cf9b7c29f27f182149c15"
		local ServerInfo = ""
		local Language = "0"

		local user_vo = GameVoManager.Instance:GetUserVo()
		if user_vo then
			local plat_name = user_vo.plat_name or ""
			AudioGVoice.InitFeesVoice(appID, appKey, plat_name, ServerInfo, Language, function (is_succeed, open_id, str)
				if is_succeed then
					print_log("init_fees_voice_succeed", open_id)
				else
					print_warning("init_fees_voice_failed", open_id, str)
				end
			end)
		end
	end
end

function AudioService:PlayFeesAudio(file_id, call_back)
	if call_back then
		call_back(true)
	end
	AudioService.Instance:SetMasterVolume(0.0)

	AudioGVoice.StopPlay()
	AudioGVoice.StartPlay(file_id, function (is_succeed, param1, param2)
		if is_succeed then
			print_log("StartPlay_succeed=", is_succeed, param1, param2)
		else
			print_warning("StartPlay_failed=", is_succeed, param1, param2)
		end
		-- 不管播放成功不成功，回调了就恢复
		AudioService.Instance:SetMasterVolume(1.0)
		if call_back then
			call_back(false)
		end
	end)
end
