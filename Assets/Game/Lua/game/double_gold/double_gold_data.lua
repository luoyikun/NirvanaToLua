DoubleGoldData = DoubleGoldData or BaseClass()

function DoubleGoldData:__init()
	if DoubleGoldData.Instance then
		print_error("[DoubleGoldData] Attemp to create a singleton twice !")
	end
	DoubleGoldData.Instance = self
	self.fetch_reward_t = {}
	self.active_state = false
end

function DoubleGoldData:__delete()
	DoubleGoldData.Instance = nil
end

function DoubleGoldData:SetRADoubleGetInfo(protocol)
	self.fetch_reward_t = bit:d2b(protocol.double_get_reward_fetch_flag)
end

function DoubleGoldData:GetDoubleGoldCfgDataByDay()
	if self.double_gold_cfg == nil then
		self.double_gold_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().double_get
	end
	local table_data = {} 
	local cfg = ActivityData.Instance:GetRandActivityConfig(self.double_gold_cfg, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DOUBLE_GOLD)
	return cfg
end

function DoubleGoldData:GetDoubleGoldList()
	local cfg = self:GetDoubleGoldCfgDataByDay()
	local list = {}
	for k, v in ipairs(cfg) do
		local data = TableCopy(v)
		data.havechongzhi = self.fetch_reward_t[32 - k + 1] or 0
		table.insert(list, data)
	end
	table.sort(list, SortTools.KeyLowerSorter("havechongzhi", "seq"))
	return list
end

function DoubleGoldData:ListIsHaveWeiLingQu()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DOUBLE_GOLD)
	if not is_open then
		return false
	end
	local cfg = self:GetDoubleGoldCfgDataByDay()
	if nil == next(self.fetch_reward_t) then
		return true
	end
	for k, v in ipairs(cfg) do
		if self.fetch_reward_t[32 - k + 1] ~= 1 then
			return true
		end
	end
	return false
end

function DoubleGoldData:ClearFetchRewatd()
	self.fetch_reward_t = {}
end

function DoubleGoldData:GetActiveState()
	return self.active_state
end

function DoubleGoldData:SetActiveState(state)
	self.active_state = state
end

