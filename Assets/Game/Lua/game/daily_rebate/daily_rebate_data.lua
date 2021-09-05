DailyRebateData = DailyRebateData or BaseClass(BaseEvent)

function DailyRebateData:__init()
	if DailyRebateData.Instance then
		print_error("[DailyRebateData] Attempt to create singleton twice!")
		return
	end
	DailyRebateData.Instance = self

	self.day_reward_cfg = ConfigManager.Instance:GetAutoConfig("chongzhireward_auto").chongzhi_day_reward
	self:CalcRareRewardCfg()
	self.server_index_rare_reward_cfg = ListToMap(self.rare_reward_cfg, "index")

	self.chongzhi_day = 0

	RemindManager.Instance:Register(RemindName.DailyRebateRemind, BindTool.Bind(self.CalcRemind, self))
end

function DailyRebateData:__delete()
	RemindManager.Instance:UnRegister(RemindName.DailyRebateRemind)
	
	DailyRebateData.Instance = nil
end

--特殊奖励列表
function DailyRebateData:CalcRareRewardCfg()
	self.rare_reward_cfg = {}
	for _, v in ipairs(self.day_reward_cfg) do
		if nil ~= v.rare_reward_item[0] then
			table.insert(self.rare_reward_cfg, v)
		end
	end
end

--获取每日奖励列表
function DailyRebateData:GetDayRewardCfg()
	return self.day_reward_cfg
end

--获取特殊奖励列表
function DailyRebateData:GetRareRewardCfg()
	return self.rare_reward_cfg
end

--根据client_index获取对应的特殊奖励数据
function DailyRebateData:GetRareRewardCfgInfo(client_index)
	return self.rare_reward_cfg[client_index]
end

function DailyRebateData:SetChongZhiDay(day)
	self.chongzhi_day = day
end

function DailyRebateData:GetChongZhiDay()
	return self.chongzhi_day
end

--每日奖励已领取标记服务器列表
function DailyRebateData:SetDayRewardFlagList(list)
	self.day_reward_flag_list = {}
	for _, v in ipairs(list) do
		local bit_t = bit:d2b(v)
		table.insert(self.day_reward_flag_list, bit_t)
	end
	-- print_error("每日奖励服务器列表", self.day_reward_flag_list)
end

--每日特殊奖励已领取标记服务器列表
function DailyRebateData:SetRareRewardFlagList(list)
	self.rare_reward_flag_list = {}
	for _, v in ipairs(list) do
		local bit_t = bit:d2b(v)
		table.insert(self.rare_reward_flag_list, bit_t)
	end
	-- print_error("特殊奖励服务器列表", self.rare_reward_flag_list)
end

function DailyRebateData:GetDayRewardFlagByIndex(index)
	local flag = 0
	if self.day_reward_flag_list == nil then
		return flag
	end

	local flag_first_index = math.ceil(index / 32)
	local flag_second_index = index % 32
	flag_second_index = index > 0 and flag_second_index == 0 and 32 or flag_second_index
	local first_list = self.day_reward_flag_list[flag_first_index] or {}
	flag = first_list[33 - flag_second_index] or 0

	return flag
end

--是否可领取每日奖励
function DailyRebateData:DayRewardCanFetchByIndex(index)
	if self.day_reward_flag_list == nil then
		return false
	end

	index = index or 0
	local day_reward_cfg_info = self.day_reward_cfg[index]
	if day_reward_cfg_info == nil then
		return false
	end

	local flag = self:GetDayRewardFlagByIndex(index)

	return flag == 0 and self.chongzhi_day >= day_reward_cfg_info.need_chongzhi_day
end

--是否已领取每日奖励
function DailyRebateData:DayRewardIsFetchByIndex(index)
	if self.day_reward_flag_list == nil then
		return false
	end

	index = index or 0

	local flag = self:GetDayRewardFlagByIndex(index)

	return flag == 1
end

function DailyRebateData:GetRareRewardFlagByIndex(index)
	local flag = 0
	if self.rare_reward_flag_list == nil then
		return flag
	end

	local flag_first_index = math.ceil(index / 32)
	local flag_second_index = index % 32
	flag_second_index = index > 0 and flag_second_index == 0 and 32 or flag_second_index
	local first_list = self.rare_reward_flag_list[flag_first_index] or {}
	flag = first_list[33 - flag_second_index] or 0

	return flag
end

--是否可领取特殊奖励
function DailyRebateData:RareRewardCanFetchByIndex(index)
	if self.rare_reward_flag_list == nil then
		return false
	end

	index = index or 0
	local rare_reward_cfg_info = self.server_index_rare_reward_cfg[index - 1]
	if rare_reward_cfg_info == nil then
		return false
	end

	local flag = self:GetRareRewardFlagByIndex(index)

	return flag == 0 and self.chongzhi_day >= rare_reward_cfg_info.need_chongzhi_day
end

--是否已领取特殊奖励
function DailyRebateData:RareRewardIsFetchByIndex(index)
	if self.rare_reward_flag_list == nil then
		return false
	end

	index = index or 0

	local flag = self:GetRareRewardFlagByIndex(index)

	return flag == 1
end

--获取下一阶段模型奖励信息
function DailyRebateData:GetNextModelRewardCfgInfo(day)
	day = day or 0

	local data = nil
	for i = 1, #self.day_reward_cfg do
		local temp_data = self.day_reward_cfg[i]
		if temp_data.model_item_id > 0 then
			--先记录最接近的一个有模型奖励的数据
			data = temp_data
			if data.need_chongzhi_day >= day then
				break
			end
		end
	end

	return data
end

--是否已领完每日奖励
function DailyRebateData:IsFetchAllDayReward()
	for _, v in ipairs(self.day_reward_cfg) do
		if self:DayRewardCanFetchByIndex(v.index + 1) then
			return false
		end
	end

	if self.chongzhi_day >= self.day_reward_cfg[#self.day_reward_cfg].need_chongzhi_day then
		return true
	end

	return false
end

--是否已领完特殊奖励
function DailyRebateData:IsFetchAllRareReward()
	for _, v in ipairs(self.rare_reward_cfg) do
		if self:RareRewardCanFetchByIndex(v.index + 1) then
			return false
		end
	end

	if self.chongzhi_day >= self.rare_reward_cfg[#self.rare_reward_cfg].need_chongzhi_day then
		return true
	end

	return false
end

--获取下一个可领取的每日奖励client_index（没有默认设置最近未达成的一个）
function DailyRebateData:GetNextDayRewardClientIndex()
	local client_index = 0
	for k, v in ipairs(self.day_reward_cfg) do
		client_index = k
		if self:DayRewardCanFetchByIndex(v.index + 1) then
			break
		end

		if v.need_chongzhi_day > self.chongzhi_day then
			break
		end
	end

	return client_index
end

--获取下一个可领取的特殊奖励client_index（没有默认设置最近未达成的一个）
function DailyRebateData:GetNextRareRewardClientIndex()
	local client_index = 0
	for k, v in ipairs(self.rare_reward_cfg) do
		client_index = k
		if self:RareRewardCanFetchByIndex(v.index + 1) then
			break
		end

		if v.need_chongzhi_day > self.chongzhi_day then
			break
		end
	end

	return client_index
end

--计算红点
function DailyRebateData:CalcRemind()
	local flag = 0
	--判断是否有每日奖励可领取
	for _, v in ipairs(self.day_reward_cfg) do
		if self:DayRewardCanFetchByIndex(v.index + 1) then
			flag = 1
			break
		end
	end

	if flag == 0 then
		--判断是否有特殊奖励可领取
		for _, v in ipairs(self.rare_reward_cfg) do
			if self:RareRewardCanFetchByIndex(v.index + 1) then
				flag = 1
				break
			end
		end
	end

	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.EVERYDAY_BACK_GOLD, flag == 1)

	return flag
end