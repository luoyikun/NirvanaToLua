GuildMijingData = GuildMijingData or BaseClass()
GuildFbNotifyReason = {
	ENTER = 0,
	WAIT = 1,
	UPDATE = 2,
	FINISH = 3,
	MAX = 4,
}
function GuildMijingData:__init()
	if GuildMijingData.Instance then
		ErrorLog("[GuildMijingData] attempt to create singleton twice!")
		return
	end
	GuildMijingData.Instance =self
	self.guild_fb_data ={}
	self.guild_fb_data.notify_reason =0
	self.guild_fb_data.curr_wave =  0
	self.guild_fb_data.next_wave_time =  0
	self.guild_fb_data.wave_enemy_count =  0
	self.guild_fb_data.wave_enemy_max =  0
	self.guild_fb_data.is_pass =  0
	self.guild_fb_data.is_finish =  0
	self.guild_fb_data.hp = 0
	self.guild_fb_data.max_hp = 0
	self.guild_fb_data.kick_role_time = 0
	self.finish_timestamp = 0

	self.item_list = {}
	self.rank_info_list ={}
end

function GuildMijingData:__delete()
	GuildMijingData.Instance = nil
end

function GuildMijingData:SetGuildMiJingSceneInfo(data)
	self.guild_fb_data = data
end

function GuildMijingData:GetGuildMiJingSceneInfo()
	return self.guild_fb_data
end

function GuildMijingData:SetGuildFbStatus(protocol)
	self.finish_timestamp = protocol.finish_timestamp
end

function GuildMijingData:GetGuildFbStatus()
	return self.finish_timestamp
end

function GuildMijingData:SetFinishDataList(item_list, num)
	if num >= 1 then
		for i = 1, num do
			self.item_list[i] = item_list[i]
		end
	end
end

function GuildMijingData:GetFinishDataList()
	return self.item_list
end

function GuildMijingData:SetRankDataList(rank_info_list)
	self.rank_info_list = rank_info_list
end

function GuildMijingData:GetRankDataList()
	return self.rank_info_list
end

-- function GuildMijingData:GetRankListData(user_id)
-- 	local list_data = self:GetRankDataList()
-- 	for k,v in pairs(list_data) do
-- 		if v.user_id == user_id then

-- 		end
-- 	end
-- end

function GuildMijingData:IsMaxWave()
	local cfg = ConfigManager.Instance:GetAutoConfig("guildfb_auto").wave_cfg
	local max_wave = 0
	if cfg then
		max_wave = #cfg
	end

	if max_wave == self.guild_fb_data.curr_wave + 1 then
		return true
	else
		return false
	end
end

