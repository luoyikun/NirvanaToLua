ExpenseGiftData = ExpenseGiftData or BaseClass()
function ExpenseGiftData:__init()
	if nil ~= ExpenseGiftData.Instance then
		return
	end
	ExpenseGiftData.Instance = self

	self.consum_gift = ServerActivityData.Instance:GetCurrentRandActivityConfig().consum_gift
	self.consum_gift_list = ListToMap(self.consum_gift, "opengame_day", "act_theme", "seq")
	self.roll_gift = ServerActivityData.Instance:GetCurrentRandActivityConfig().consum_gift_roll_reward_pool
	self.roll_gift_list = ListToMap(self.roll_gift, "opengame_day", "act_theme", "seq")

	self.roll_gift_info = {
		sep = 1,
		reward_gold = 1,
	}
	self.chest_shop_mode = -1
	self.ten_reward = {}
	self.ten_reward_gold = {}
	RemindManager.Instance:Register(RemindName.ExpenseGift, BindTool.Bind(self.GetExpenseGiftRemind, self))
	self.clickexpense = true
end

function ExpenseGiftData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ExpenseGift)
	self.chest_shop_mode = nil
	ExpenseGiftData.Instance = nil
end


function ExpenseGiftData:GetExpenseGiftConfig()
	local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local day = nil
	for k,v in pairs(self.consum_gift) do
		if self.expense_gift_info and self.expense_gift_info.act_theme then
			if v and (nil == day or v.opengame_day == day) and server_open_day <= v.opengame_day and self.expense_gift_info.act_theme == v.act_theme then
				server_open_day = v.opengame_day
				day =  v.opengame_day
			end
		end
	end
	if self.consum_gift_list == nil or self.consum_gift_list[server_open_day] == nil then
		return
	end
	if self.expense_gift_info and self.expense_gift_info.act_theme then
		if nil == self.consum_gift_list[server_open_day][self.expense_gift_info.act_theme] then
			return
		end
		return self.consum_gift_list[server_open_day][self.expense_gift_info.act_theme]
	end
	return {}
end

function ExpenseGiftData:GetExpenseGiftList()
	local list = {}
	local cfg = self:GetExpenseGiftConfig()
	local list_num = GetListNum(cfg)
	for i = list_num, 1, -1 do
		local flag = self:ExpenseInfoRewardCanFetchFlagByIndex(cfg[i-1].seq)
		if flag == 1 then
			table.insert(list, cfg[i-1])
		else
			table.insert(list, 1, cfg[i-1])
		end
	end
	return list
end

function ExpenseGiftData:GetExpenseGiftIsOpen()
	local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_GIFT)
	if is_open then
		for k,v in pairs(self.consum_gift) do
			if self.expense_gift_info and self.expense_gift_info.act_theme then
				if server_open_day <= v.opengame_day and self.expense_gift_info.act_theme == v.act_theme then
					return true
				end
			end
		end
	end
	return false
end

function ExpenseGiftData:GetRollReward()
	local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local day = nil
	for k,v in pairs(self.roll_gift) do
		if self.expense_gift_info and self.expense_gift_info.act_theme then
			if v and (nil == day or v.opengame_day == day) and server_open_day <= v.opengame_day and self.expense_gift_info.act_theme == v.act_theme then
				server_open_day = v.opengame_day
				day = v.opengame_day
			end
		end
	end
	if self.roll_gift_list == nil or self.roll_gift_list[server_open_day] == nil then
		return
	end
	if self.expense_gift_info and self.expense_gift_info.act_theme then
		if nil == self.roll_gift_list[server_open_day][self.expense_gift_info.act_theme] then
			return
		end
		return self.roll_gift_list[server_open_day][self.expense_gift_info.act_theme]
	end
	return {}
end

function ExpenseGiftData:SetExpenseNiceGiftInfo(protocol)
	if not protocol then 
		return 
	end
	if nil == self.expense_gift_info then 
		self.expense_gift_info = {} 
	end
	self.expense_gift_info.consum_gold = protocol.consum_gold
	self.expense_gift_info.act_theme = protocol.act_theme
	self.expense_gift_info.left_roll_times = protocol.left_roll_times
	self.expense_gift_info.reward_fetch_flag = bit:d2b(protocol.reward_fetch_flag)
end

function ExpenseGiftData:GetExpenseNiceGiftInfo()
	return self.expense_gift_info
end

function ExpenseGiftData:ExpenseInfoRewardCanFetchFlagByIndex(index)
	if self.expense_gift_info and self.expense_gift_info.reward_fetch_flag then
		return self.expense_gift_info.reward_fetch_flag[32 - index]
	end
end

function ExpenseGiftData:SetRollGiftInfo(protocol)
	self.roll_gift_info.seq = protocol.seq
	self.roll_gift_info.reward_gold = protocol.decade*10 + protocol.units_digit
end


function ExpenseGiftData:SetRollGiftTenInfo(protocol)
	for i = 1 , GameEnum.MAX_COUNT do
		self.ten_reward[i] = protocol.seq_list[i]
	end

	for i = 1 , GameEnum.MAX_COUNT do
		self.ten_reward_gold[i] = protocol.decade_list[i]*10 + protocol.units_digit_list[i]
	end
end

function ExpenseGiftData:GetRollGiftInfo()
	return self.roll_gift_info
end

function ExpenseGiftData:GetRollGiftTenInfo()
	return self.ten_reward, self.ten_reward_gold
end

--获取奖励展示框的信息
function ExpenseGiftData:GetChestShopItemInfo()
	local cfg = self:GetRollReward()
	local data_list = {}
	local theme = self:GetCurActTheme()
	if cfg then
		for k, v in pairs(self.ten_reward_gold) do
			local data = {}
			if cfg[theme] and cfg[theme].reward_item then
				data.item_id = cfg[theme].reward_item.item_id
				data.is_bind = cfg[theme].reward_item.is_bind
			end
			data.num = v
			table.insert(data_list, data)
		end
	end
	
	return data_list
end

function ExpenseGiftData:ExpenseGiftRemindSign()
	self.clickexpense = false
end

function ExpenseGiftData:GetIsShowRed()
	local cfg = self:GetExpenseGiftConfig()
	if self.expense_gift_info and cfg then
		if self.expense_gift_info.left_roll_times > 0 then
			return true
		end
		for i,v in ipairs(cfg) do
			if self.expense_gift_info.consum_gold >= v.need_gold and self:ExpenseInfoRewardCanFetchFlagByIndex(v.seq) == 0 then
				return true
			end
		end
	end
	return false
end

function ExpenseGiftData:GetExpenseGiftRemind()
	local bool = self:GetIsShowRed()
	if bool and self:GetExpenseGiftIsOpen() then
		return 1
	end
	local is_show = RemindManager.Instance:RemindToday(RemindName.ExpenseGift)
	if not is_show and self:GetExpenseGiftIsOpen() then
		return 1
	end
	return 0
end

function ExpenseGiftData:GetCurActTheme()
	if self.expense_gift_info then
		return self.expense_gift_info.act_theme
	end
	return 1
end

--设置奖励展示框模型
function ExpenseGiftData:SetChestShopMode(mode)
	self.chest_shop_mode = mode
end

--获取奖励展示框模型
function ExpenseGiftData:GetChestShopMode()
	return self.chest_shop_mode
end

function ExpenseGiftData:GetRewardItemCfg(act_id)
	local data_list = self:GetRollReward()
	for k,v in pairs(data_list) do 
		if v.act_theme == act_id and v.seq == 5 then
			return v.reward_item
		end
	end
	return nil
end