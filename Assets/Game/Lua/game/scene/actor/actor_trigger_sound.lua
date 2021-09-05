ActorTriggerSound = ActorTriggerSound or BaseClass(ActorTriggerBase)

function ActorTriggerSound:__init(anima_name, is_main_role)
	self.anima_name = anima_name
	self.is_main_role = is_main_role
	self.cur_sound_count = 0
	self.enabled = true

	self.sound_data = nil
end

function ActorTriggerSound:__delete()
	self.sound_data = nil
end

-- 初始化预制体保存的配置数据(单个)
function ActorTriggerSound:Init(sound_data)
	self.sound_data = sound_data
	self.delay = sound_data.soundDelay
end

-- get/set
function ActorTriggerSound:Enalbed(value)
	if value == nil then
		return self.enabled
	end
	self.enabled = value
end

function ActorTriggerSound:OnEventTriggered(source, target, source_obj, target_obj, stateInfo)
	local sound_data = self.sound_data
	if not sound_data or not self.enabled then
		return
	end

	if sound_data.soundAudioAsset and nil == next(sound_data.soundAudioAsset) then
		return
	end

	local bundle_name = sound_data.soundAudioAsset.BundleName
	local asset_name = sound_data.soundAudioAsset.AssetName
	if self.is_main_role then
		AudioManager.PlayAndForget(bundle_name, asset_name, nil, source.transform)

	-- 屏蔽是因为其他角色技能不需要听到技能声音
	-- else
	-- 	if self.cur_sound_count < 2 then
	-- 		self.cur_sound_count = self.cur_sound_count + 1
	-- 		AudioManager.PlayAndForget(bundle_name, asset_name, nil, source.transform, 
	-- 			function ()
	-- 				self.cur_sound_count = self.cur_sound_count - 1
	-- 			end)
	-- 	end
	end
end
