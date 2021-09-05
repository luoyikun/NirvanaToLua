BiPingActivityData = BiPingActivityData or BaseClass()


function BiPingActivityData:__init()
	if BiPingActivityData.Instance then
		print_error("[BiPingActivityData] Attempt to create singleton twice!")
		return
	end
	BiPingActivityData.Instance = self
	-- RemindManager.Instance:Register(RemindName.BiPin, BindTool.Bind(self.GetBiPinRemind, self))
	-- RemindManager.Instance:Register(RemindName.BPCapabilityRemind, BindTool.Bind(self.GetBPCapabilityRemind, self))
	self.bipin_show = false
	self.is_first_open = true
	self.toggle_not_is_on = false
	self.image_rank_info = {}
	self.open_day = 3
end

function BiPingActivityData:__delete()

	BiPingActivityData.Instance = nil
	self.is_first_open = true
	self.toggle_not_is_on = nil
end

function BiPingActivityData:SetFirstOpenFlag()
	self.is_first_open = false
end

function BiPingActivityData:GetFirstOpenFlag()
	return self.is_first_open
end


function BiPingActivityData:SetBiPinRank(is_show)
	self.bipin_show = is_show 
end

function BiPingActivityData:GetBiPinRank()
	return self.bipin_show
end

function BiPingActivityData:SetOpenDayCfg(protocol)
	 self.open_day = protocol.opengame_day
end

function BiPingActivityData:GetOpenDayCfg()
	return self.open_day or 0
end

function BiPingActivityData:SetImageRankCfg(list)
	self.image_rank_info = list
end

function BiPingActivityData:GetImageRankCfg()
	return self.image_rank_info
end

function BiPingActivityData:GetImageMyRankCfg()
	local data = self:GetImageRankCfg()
	local my_rank = -1
	local my_id = GameVoManager.Instance:GetMainRoleVo().role_id
	for k,v in pairs(data) do
		if my_id == v.user_id then
			return k , v.rank_value
		end
	end
	return my_rank , 0
end

function BiPingActivityData:GetBiPinCfg(act_day)
	local data_cfg =   ServerActivityData.Instance:GetCurrentRandActivityConfig().image_competition_type
	for k,v in pairs(data_cfg) do 
		if v.opengame_day == act_day  then
			return v
		end
	end
end

function BiPingActivityData:GetBiPinCfgAuto(cell_data)
	local data_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().image_competition_reward
	local day = nil
	local open_day = self:GetOpenDayCfg()
	for k,v in pairs(data_cfg) do 
		if v and (nil == day or v.opengame_day == day) and  v.reward_index == cell_data and v.opengame_day >= open_day then
			day = v.opengame_day
			return v
		end
	end
end
function BiPingActivityData:GetBiPinRankNum()
	local day = nil
	local count_num = 0
	local open_day = self:GetOpenDayCfg() --TimeCtrl.Instance:GetCurOpenServerDay()
	local data_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().image_competition_reward
	for k,v in pairs(data_cfg) do 
		if v and (nil == day or v.opengame_day == day) and open_day <= v.opengame_day then
			day = v.opengame_day
		end
	end
	for k,v in pairs(data_cfg) do
		if day == v.opengame_day then
			count_num = count_num + 1
		end
	end
	return count_num
end

function BiPingActivityData:BiPinItemName()
	local data_list = self:GetBiPinCfg(self.open_day)
	return data_list.show_id
end

function BiPingActivityData:GetWeiYanRes(item_id)
	local data_list = WeiYanData.Instance:GetSpecialImagesCfg()
	for k,v in pairs(data_list) do
		if v.item_id == item_id then
			return v.res_id
		end
	end
	return 0
end

function BiPingActivityData:GetActivitytimes()
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BiPin_ACTIVITY) then
		local chongzhi_time_table = os.date('*t',TimeCtrl.Instance:GetServerTime())
		local chongzhi_cur_time = chongzhi_time_table.hour * 3600 + chongzhi_time_table.min * 60 + chongzhi_time_table.sec
		local time = 24 * 3600 - chongzhi_cur_time
		return time
	end
	return 0
end