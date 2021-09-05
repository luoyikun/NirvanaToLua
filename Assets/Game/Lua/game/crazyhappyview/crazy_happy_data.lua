CrazyHappyData = CrazyHappyData or BaseClass()

--版本活动排序
local FST_SORT_INDEX_LIST = {
	[1] = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBICHONGZHIONE,				-- 单笔充值1
	[2] = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBICHONGZHITWO,				-- 单笔充值2
	[3] = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBICHONGZHITHREE,				-- 单笔充值3
	[4] = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHIONE,				-- 累计充值1
	[5] = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHITWO,				-- 累计充值2
	[6] = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHITHREE,				-- 累计充值3
}

LEIJI_CHARGE_LIST = {
	[1] = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHIONE,				-- 累计充值1
	[2] = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHITWO,				-- 累计充值2
	[3] = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHITHREE,				-- 累计充值3
}

DANBI_CHARGE_LIST = {
	[1] = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBICHONGZHIONE,				-- 单笔充值1
	[2] = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBICHONGZHITWO,				-- 单笔充值2
	[3] = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBICHONGZHITHREE,				-- 单笔充值3
}

CRZ_ACT_TYPE_INDEX = {
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBICHONGZHIONE] = 1,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBICHONGZHITWO] = 2,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBICHONGZHITHREE] = 3,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHIONE] = 4,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHITWO] = 5,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHITHREE] = 6,
}

function CrazyHappyData:__init()
	if CrazyHappyData.Instance ~= nil then
		print_error("[CrazyHappyData] Attemp to create a singleton twice !")
		return
	end

	CrazyHappyData.Instance = self
	self.total_charge_info = {}
	self.single_charge_info = {}
	self.is_open = true
	RemindManager.Instance:Register(RemindName.CrazyHappyView, BindTool.Bind(self.GetCrazyHappyViewRemind, self))
end

function CrazyHappyData:__delete()
	CrazyHappyData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.CrazyHappyView)
end

function CrazyHappyData:SetIsFirstOpen(enable)
	self.is_open = enable
end

function CrazyHappyData:GetCrazyHappyViewRemind()
	if self.is_open then
		for i = 1, 3 do
			if LEIJI_CHARGE_LIST[i] then
				if self:IsTotalChargeRedPoint(LEIJI_CHARGE_LIST[i]) then
					return 1
				end
			end
		end
	end
end

function CrazyHappyData:SetAllRANewTotalChargeInfo(protocol)
	self.total_charge_info[protocol.activity_type] = {}
	self.total_charge_info[protocol.activity_type].total_charge_value = protocol.total_charge_value or 0
	self.total_charge_info[protocol.activity_type].reward_has_fetch_flag = bit:d2b(protocol.reward_has_fetch_flag)
end

function CrazyHappyData:SetAllRANewSingleChargeInfo(protocol)
	self.single_charge_info[protocol.activity_type] = {}
	self.single_charge_info[protocol.activity_type].single_charge_reward_fetch_flag = bit:d2b(protocol.single_charge_reward_fetch_flag)
end

function CrazyHappyData:GetSingleChargeInfoOne(activity_type)
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().single_charge1
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBICHONGZHIONE)
	local fetch_reward_t = self.single_charge_info[activity_type] and self.single_charge_info[activity_type].single_charge_reward_fetch_flag or {}
	local list = {}

	for i,v in ipairs(cfg) do
		local fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
		local data = TableCopy(v)
		data.fetch_reward_flag = fetch_reward_flag
		table.insert(list, data)
	end
	table.sort(list, SortTools.KeyLowerSorter("fetch_reward_flag", "charge_value"))
	return list 
end

function CrazyHappyData:GetSingleChargeInfoTwo(activity_type)
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().single_charge2
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBICHONGZHITWO)
	local fetch_reward_t = self.single_charge_info[activity_type] and self.single_charge_info[activity_type].single_charge_reward_fetch_flag or {}
	local list = {}

	for i,v in ipairs(cfg) do
		local fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
		local data = TableCopy(v)
		data.fetch_reward_flag = fetch_reward_flag
		table.insert(list, data)
	end
	table.sort(list, SortTools.KeyLowerSorter("fetch_reward_flag", "charge_value"))
	return list
end

function CrazyHappyData:GetSingleChargeInfoThree(activity_type)
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().single_charge3
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBICHONGZHITHREE)
	local fetch_reward_t = self.single_charge_info[activity_type] and self.single_charge_info[activity_type].single_charge_reward_fetch_flag or {}
	local list = {}

	for i,v in ipairs(cfg) do
		local fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
		local data = TableCopy(v)
		data.fetch_reward_flag = fetch_reward_flag
		table.insert(list, data)
	end
	table.sort(list, SortTools.KeyLowerSorter("fetch_reward_flag", "charge_value"))
	return list
end

function CrazyHappyData:GetOpenActTotalChargeOneRewardCfg(activity_type)
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().new_rand_total_chongzhi1
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHIONE)

	local fetch_reward_t = self.total_charge_info[activity_type] and self.total_charge_info[activity_type].reward_has_fetch_flag or {}
	local list = {}

	for i,v in ipairs(cfg) do
		local fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
		local data = TableCopy(v)
		data.fetch_reward_flag = fetch_reward_flag
		table.insert(list, data)
	end
	table.sort(list, SortTools.KeyLowerSorter("fetch_reward_flag", "need_chognzhi"))
	return list
end

function CrazyHappyData:GetOpenActTotalChargeTwoRewardCfg(activity_type)
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().new_rand_total_chongzhi2
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHITWO)

	local fetch_reward_t = self.total_charge_info[activity_type] and self.total_charge_info[activity_type].reward_has_fetch_flag or {}
	local list = {}
	for i,v in ipairs(cfg) do
		local fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
		local data = TableCopy(v)
		data.fetch_reward_flag = fetch_reward_flag
		table.insert(list, data)
	end
	table.sort(list, SortTools.KeyLowerSorter("fetch_reward_flag", "need_chognzhi"))
	return list
end

function CrazyHappyData:GetOpenActTotalChargeThreeRewardCfg(activity_type)
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().new_rand_total_chongzhi3
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHITHREE)

	local fetch_reward_t = self.total_charge_info[activity_type] and self.total_charge_info[activity_type].reward_has_fetch_flag or {}
	local list = {}
	for i,v in ipairs(cfg) do
		local fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
		local data = TableCopy(v)
		data.fetch_reward_flag = fetch_reward_flag
		table.insert(list, data)
	end
	table.sort(list, SortTools.KeyLowerSorter("fetch_reward_flag", "need_chognzhi"))
	return list
end

function CrazyHappyData:GetTotalChargeInfo(activity_type)
	if self.total_charge_info[activity_type] then
		return self.total_charge_info[activity_type]
	end
end

function CrazyHappyData:ClearData(activity_type)
	if self.total_charge_info[activity_type] then
		self.total_charge_info[activity_type] = {}
	end
end

function CrazyHappyData:ClearSingleChargeData(activity_type)
	if self.single_charge_info[activity_type] then
		self.single_charge_info[activity_type] = {}
	end
end

function CrazyHappyData:IsTotalChargeRedPoint(activity_type)
	if not ActivityData.Instance:GetActivityIsOpen(activity_type) then
		return false
	end

	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().new_rand_total_chongzhi
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, activity_type)
	local flag = false

	local fetch_reward_t = self.total_charge_info[activity_type] and self.total_charge_info[activity_type].reward_has_fetch_flag or {}
	for i,v in ipairs(cfg) do
		fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
		if 0 == fetch_reward_flag and self.total_charge_info[activity_type].total_charge_value and self.total_charge_info[activity_type].total_charge_value >= v.need_chognzhi then
			flag = true
			return flag
		end
	end
	return flag
end

function CrazyHappyData:GetOpenActivityList()
	local temp_list = {}
	for _, v in ipairs(FST_SORT_INDEX_LIST) do
		if ActivityData.Instance:GetActivityIsOpen(v) then
			local list =  {}
			local name = ""
			local activity_cfg = ActivityData.Instance:GetActivityConfig(v)
			if activity_cfg then
				name = activity_cfg.act_name
			end
			list.activity_type = v
			list.name = name
			local is_show = self:GetIsShow(v)
			if is_show then
				table.insert(temp_list, list)
			end
		end
	end
	return temp_list
end

function CrazyHappyData:GetIsShow(activity_type)
	local list = {}
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBICHONGZHIONE then
		list = self:GetSingleChargeInfoOne(activity_type)
	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBICHONGZHITWO then
		list = self:GetSingleChargeInfoTwo(activity_type)
	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBICHONGZHITHREE then
		list = self:GetSingleChargeInfoThree(activity_type)
	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHIONE then
		list = self:GetOpenActTotalChargeOneRewardCfg(activity_type)
	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHITWO then
		list = self:GetOpenActTotalChargeTwoRewardCfg(activity_type)
	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHITHREE then
		list = self:GetOpenActTotalChargeThreeRewardCfg(activity_type)
	end

	if list[1].fetch_reward_flag == 1 then
		return false
	else
		return true
	end
end

function CrazyHappyData:SetSelect(index)
	self.selectindex = index
end

function CrazyHappyData:GetSelectIndex()
	return self.selectindex
end

function CrazyHappyData:GetActivityTypeToIndex(activity_type)
	if activity_type > 100000 then
		activity_type = activity_type - 100000
	end
	local index = CRZ_ACT_TYPE_INDEX[activity_type] or 1

	return index
end

function CrazyHappyData:GetActivityTypeByIndex(open_index)
	for k, v in pairs(CRZ_ACT_TYPE_INDEX) do
		if open_index == v then
			return k
		end
	end
end

function CrazyHappyData:GetBanBenActivityRemind()
	local num = 0
	-- 参考
	-- if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EVERYDAY_NICE_GIFT) then 				-- 每日好礼
	-- 	if KaifuActivityData.Instance:DailyGiftRedPoint() > 0 then
	-- 		num = num +1
	-- 	end
	-- end
	return num
end

--------------------------------单笔充值---------------------------------
function CrazyHappyData:GetDanBiChongZhiOneInfoListByDay()
	local table_data = {}
	local table_data_2 = {}
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().single_charge1
	local data = ActivityData.Instance:GetRandActivityConfig(cfg, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBICHONGZHIONE)
	for k,v in pairs(data) do
		table.insert(table_data, v.reward_item)
		table.insert(table_data_2, v.charge_value)
	end
	return table_data, table_data_2
end

function CrazyHappyData:GetDanBiChongZhiTwoInfoListByDay()
	local table_data = {}
	local table_data_2 = {}
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().single_charge2
	local data = ActivityData.Instance:GetRandActivityConfig(cfg, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBICHONGZHITWO)
	for k,v in pairs(data) do
		table.insert(table_data, v.reward_item)
		table.insert(table_data_2, v.charge_value)
	end
	return table_data, table_data_2
end

function CrazyHappyData:GetDanBiChongZhiThreeInfoListByDay()
	local table_data = {}
	local table_data_2 = {}
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().single_charge3
	local data = ActivityData.Instance:GetRandActivityConfig(cfg, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBICHONGZHITHREE)
	for k,v in pairs(data) do
		table.insert(table_data, v.reward_item)
		table.insert(table_data_2, v.charge_value)
	end
	return table_data, table_data_2
end