SingleRechargeData = SingleRechargeData or BaseClass()

function SingleRechargeData:__init()
	if SingleRechargeData.Instance then
		ErrorLog("[SingleRechargeData] attempt to create singleton twice!")
		return
	end
	SingleRechargeData.Instance = self
	RemindManager.Instance:Register(RemindName.DanFanHaoLi, BindTool.Bind(self.GetSingleRechargeRemind, self))
	self.reward_flag = {}
	self.is_reward_flag = {}
end

function SingleRechargeData:__delete()
	RemindManager.Instance:UnRegister(RemindName.DanFanHaoLi)
	SingleRechargeData.Instance = nil
end

function SingleRechargeData:SetRewardFlag(protocol)
	self.reward_flag = bit:d2b(protocol.fetch_reward_flag)
	self.is_reward_flag = bit:d2b(protocol.is_fetch_reward_flag)
end

function SingleRechargeData:GetRewardFlag(index)
	return self.reward_flag[32 - index] or 0
end

function SingleRechargeData:GetIsRewardFlag(index)
	return self.is_reward_flag[32 - index] or 0
end

function SingleRechargeData:GetSingleRechargeCfg()
	if self.single_chongzhi == nil then
		self.single_chongzhi = ServerActivityData.Instance:GetCurrentRandActivityConfig().single_chongzhi
	end
	local data = {}
	for i,v in pairs(self.single_chongzhi) do
		data[i] = {}
		data[i].config = v
		data[i].is_can_get_reward = self:GetRewardFlag(v.seq)
		data[i].has_can_get_reward = self:GetIsRewardFlag(v.seq)
	end

	function sort(a, b)
		local order_a, order_b = 0, 0
		if a.has_can_get_reward == 0 then
			order_a = order_a + 100
		end

		if b.has_can_get_reward == 0 then
			order_b = order_b + 100
		end

		if a.is_can_get_reward == 0  then
			order_a = order_a - 100
		end

		if b.is_can_get_reward == 0  then
			order_b = order_b - 100
		end

		if a.config.need_gold < b.config.need_gold then
			order_a = order_a + 10
		else
			order_b = order_b + 10
		end

		return order_a > order_b
	end
	table.sort(data, sort)
	return data
end


function SingleRechargeData:GetSingleRechargeRemind()
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHONGZHI) then
		return 0
	end

	local data = self:GetSingleRechargeCfg()

	for i,v in pairs(data) do
		if data[i].is_can_get_reward == 1 and data[i].has_can_get_reward == 0 then
			return 1
		end
	end
	return 0
end

function SingleRechargeData:FlushHallRedPoindRemind()
	local remind_num = self:GetSingleRechargeRemind()
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHONGZHI, remind_num > 0)
end

function SingleRechargeData:IsHaveAllChongzhiAndLingQu()
	local data = self:GetSingleRechargeCfg()
	if nil == next(self.is_reward_flag) then
		return true
	end 
	for i,v in pairs(data) do
		if data[i].has_can_get_reward ~= 1 then
			return false
		end
	end
	return true
end

function SingleRechargeData:IsFirstSendPro()
	if nil == next(self.is_reward_flag) then
		return true
	end 
	return false
end

