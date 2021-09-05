HappyRechargeData = HappyRechargeData or BaseClass()

function HappyRechargeData:__init()
	if HappyRechargeData.Instance then
		print_error("[HappyRechargeData] Attemp to create a singleton twice !")
	end
	HappyRechargeData.Instance = self

	self.cur_can_niu_egg_chongzhi_value = 0
	self.server_total_niu_egg_times = 0
	self.server_reward_has_fetch_reward_flag = 0
	self.history_count = 0
	self.history_list = {}
	self.reward_fetch_list = {}


	RemindManager.Instance:Register(RemindName.CHONGZHIDALETOU, BindTool.Bind(self.GetChongZhiRemind, self))
end

function HappyRechargeData:__delete()
	RemindManager.Instance:UnRegister(RemindName.CHONGZHIDALETOU)

	HappyRechargeData.Instance = nil
end

function HappyRechargeData:GetItemListInfo()
	local table_data = {}
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().charge_niu_egg
	local data = ActivityData.Instance:GetRandActivityConfig(cfg, ACTIVITY_TYPE.RAND_HAPPY_RECHARGE)
	for k,v in pairs(data) do
		if v.show_item == 1 then
			table.insert(table_data, v)
		end
	end
	return table_data
end

function HappyRechargeData:GetCost()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().other
	return cfg[1].niu_egg_need_charge or 0
end

function HappyRechargeData:SetNiuEggInfo(protocol)
	self.cur_can_niu_egg_chongzhi_value = protocol.cur_can_niu_egg_chongzhi_value
	self.server_total_niu_egg_times = protocol.server_total_niu_egg_times
	self.server_reward_has_fetch_reward_flag = protocol.server_reward_has_fetch_reward_flag
	self.history_count = protocol.history_count
	self.history_list = protocol.history_list
	self.reward_fetch_list = bit:d2b(self.server_reward_has_fetch_reward_flag)
end

function HappyRechargeData:GetChongZhiVlaue()
	return self.cur_can_niu_egg_chongzhi_value
end

function HappyRechargeData:GetTotalTimes()
	return self.server_total_niu_egg_times
end

function HappyRechargeData:GetRewardFetchFlagByIndex(index)
	return self.reward_fetch_list[33 - index]
end


function HappyRechargeData:GetHistoryCount()
	return self.history_count
end

function HappyRechargeData:GetHistoryList()
	return self.history_list
end

function HappyRechargeData:GetFetchFlag()
	return self.server_reward_has_fetch_reward_flag
end

function HappyRechargeData:SetRestTime(time)
	self.rest_time = time
end

function HappyRechargeData:GetRestTime()
	return self.rest_time or 0
end

function HappyRechargeData:SetRewardListInfo(list_info)
	self.reward_list_info = list_info
end

function HappyRechargeData:GetRewardListInfo()
	local table_data = {}
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().charge_niu_egg
	local data = ActivityData.Instance:GetRandActivityConfig(cfg, ACTIVITY_TYPE.RAND_HAPPY_RECHARGE)
	for k,v in pairs(self.reward_list_info) do
		table.insert(table_data, data[v + 1].reward_item)
	end
	return table_data
end

function HappyRechargeData:GetLeiJiRewardListInfo()
	local table_data = {}
	for k, v in pairs(self:GetItemListInfo()) do
		if v.cfg_type == 1 then
			table.insert(table_data, v)
		end
	end
	return table_data
end

-- 活动 充值乐翻天红点提示调用
function HappyRechargeData:FlushHallRedPoindRemind()
	local remind_num = self:GetChongZhiRemind()
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_HAPPY_RECHARGE, remind_num > 0)
end

function HappyRechargeData:GetHasCanLingQu()
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	local total_times = self:GetTotalTimes()
	local reward_data = self:GetLeiJiRewardListInfo()
	local buffer = bit:d2b(self:GetFetchFlag())
	local num = #reward_data
	for i = 1, num do
		local vip_flag = vip_level >= reward_data[i].vip_limit
		local times_flag = total_times >= reward_data[i].server_niu_times
		local is_get = buffer[#buffer - i + 1]
		if vip_flag and times_flag and is_get == 0 then
			return true
		end
	end
	return false
end

-- 获取活动状态
function HappyRechargeData:GetChongZhiRemind()
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_HAPPY_RECHARGE) then
		return 0
	end

	local count = self:GetCost()  --充值多少次可以抽取
	if nil == count then 
		return 0 
	end

	if self:GetHasCanLingQu() then
		return 1
	end

	if self.cur_can_niu_egg_chongzhi_value >= count then
		return 1
	end

	return 0
end