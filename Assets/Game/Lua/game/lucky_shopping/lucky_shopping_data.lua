LuckyShoppingData = LuckyShoppingData or BaseClass()

--初始化
function LuckyShoppingData:__init()
	if LuckyShoppingData.Instance ~= nil then
		print_error("[LuckyShoppingData] attempt to create singleton twice!")
		return
	end
	LuckyShoppingData.Instance = self
	self.name_list = {}
	self.activity_is_open = false
	self.view_is_open = false

	RemindManager.Instance:Register(RemindName.LuckyShoppingRemind, BindTool.Bind(self.GetLuckyShoppingRemind, self))
end

--释放
function LuckyShoppingData:__delete()
	RemindManager.Instance:UnRegister(RemindName.LuckyShoppingRemind)
	LuckyShoppingData.Instance = nil
end

function LuckyShoppingData:OnSCRALuckyCloudBuyInfo(protocol)
	self.seq_info = protocol.seq or 0
	self.buy_self = protocol.buy_self or 0
end

function LuckyShoppingData:OnSCRALuckyCloudBuyBuyList(protocol)
	self.ret_timestamp = protocol.ret_timestamp or 0
	self.total_buy = protocol.total_buy or 0
	self:SetLuckyShoppingNameList(protocol.name_list)
end

function LuckyShoppingData:SetLuckyShoppingNameList(name_list)
	if name_list == nil then
		return
	end

	for k,v in pairs(name_list) do
		local list_num = #self.name_list
		if list_num >= 12 then
			table.remove(self.name_list, 1)
		end
		table.insert(self.name_list, v)
	end
end

--根据开服时间获取配置  
function LuckyShoppingData:GetOpenTakeTimeCfg()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	if nil == cfg and nil == next(cfg) then
		return {}
	end
	
	local lucky_shopping_cfg = ActivityData.Instance:GetRandActivityConfig(cfg.lucky_cloud_buy, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LUCKY_SHOPPING)
	return lucky_shopping_cfg
end

-- 获取奖励
function LuckyShoppingData:GetRewardShow()
	local lucky_shopping_cfg = self:GetOpenTakeTimeCfg()
	if next(lucky_shopping_cfg) == nil then
		return {}
	end

	local reward_list = {}
	local current_round_index = self:GetCurrentRound()
	if current_round_index == -1 then
		return reward_list
	end

	for k,v in pairs(lucky_shopping_cfg) do
		if v.round_index == current_round_index then
			reward_list.round_index = current_round_index
			reward_list.grand_prix_item = v.big_reward_item or {}
			reward_list.big_reward_value = v.big_reward_value or 0
			reward_list.min_reward_item = v.min_reward_item or {}
		end
	end

	return reward_list
end

-- 获取当前轮数
function LuckyShoppingData:GetCurrentRound()
	local time = TimeCtrl.Instance:GetServerTime()
	local sever_hour = tonumber(os.date("%H", time))
	local sever_minute = tonumber(os.date("%M", time))
	local sever_time = sever_hour * 100 + sever_minute

	local cfg = self:GetOpenTakeTimeCfg()
	if cfg == nil then
		return -1
	end

	local total_round = #cfg

	for i,v in ipairs(cfg) do
		local open_time = v.begin_time or 0
		local end_time = v.end_time or 0
		if sever_time >= open_time and sever_time <= end_time then
			if self.activity_is_open then
				return v.round_index or -1
			else
				return v.round_index + 1 >=total_round and 0 or v.round_index + 1
			end
		end
		if sever_time < open_time then
			return v.round_index or -1
		end
	end
	return 0
end

function LuckyShoppingData:GetSelfBuy()
	return self.buy_self or 0
end

function LuckyShoppingData:GetTotalBuy()
	return self.total_buy or 0
end

function LuckyShoppingData:GetNameList()
	return self.name_list or {}
end

function LuckyShoppingData:GetRetTimesTamp()
	return self.ret_timestamp or 0
end

function LuckyShoppingData:GetNeedGold()
	local lucky_shopping_cfg = self:GetOpenTakeTimeCfg()
	if next(lucky_shopping_cfg) == nil then
		return 0, 0
	end

	local current_round_index = self:GetCurrentRound()
	if current_round_index == -1 then
		return 0, 0
	end

	for k,v in pairs(lucky_shopping_cfg) do
		if v.round_index == current_round_index then
			return v.need_gold, v.sale_count
		end
	end

	return 0, 0
end

-- 获取下一轮结束时间
function LuckyShoppingData:LuckyShoppingRoundLeastTime()
	local lucky_shopping_cfg = self:GetOpenTakeTimeCfg()
	if next(lucky_shopping_cfg) == nil then
		return 0
	end

	local end_time = 0
	local cur_round_index = self:GetCurrentRound()
	for k,v in pairs(lucky_shopping_cfg) do
		if v.round_index == cur_round_index then
			end_time = v.end_time
			break
		end
	end

	local end_hour = end_time / 100
	local end_minute = end_time % 100
	local sever_time = TimeCtrl.Instance:GetServerTime()
	local format_time = os.date("*t", sever_time)
	local end_timetamp = os.time({year = format_time.year, month = format_time.month, day = format_time.day, hour = end_hour, min = end_minute, sec = 0})
	return end_timetamp - sever_time
end

-- 获取下一轮开始时间
function LuckyShoppingData:LuckyShoppingRoundNextOpenTime()
	local lucky_shopping_cfg = self:GetOpenTakeTimeCfg()
	if next(lucky_shopping_cfg) == nil then
		return 0
	end

	local open_time = 0
	local cur_round_index = self:GetCurrentRound()
	for k,v in pairs(lucky_shopping_cfg) do
		if v.round_index == cur_round_index then
			open_time = v.begin_time
			break
		end
	end

	local begin_hour = open_time / 100
	local begin_minute = open_time % 100
	local sever_time = TimeCtrl.Instance:GetServerTime()
	local format_time = os.date("*t", sever_time)
	local open_timetamp = os.time({year = format_time.year, month = format_time.month, day = format_time.day, hour = begin_hour, min = begin_minute, sec = 0})
	local least_time = open_timetamp - sever_time
	-- 当天活动已经开完，下一轮为第二天的第一轮
	if least_time < 0 then
		-- -- 活动的最后一天，则最后一轮后直接返回0
		-- local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LUCKY_SHOPPING)
		-- local sever_time = TimeCtrl.Instance:GetServerTime()
		-- local activity_least_time = sever_time - time
		-- if activity_least_time <= 24 * 60 * 60 then
		-- 	return 0
		-- end

		local time1 = begin_hour * 3600 + begin_minute * 60
		local time2 = TimeUtil.NowDayTimeEnd(sever_time) - sever_time
		least_time = time1 + time2
	end

	-- 下一轮活动是否结束
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LUCKY_SHOPPING)
	if least_time >= time then
		return 0
	end

	return least_time
end

function LuckyShoppingData:SetOpenStatus(activity_is_open)
	self.activity_is_open = activity_is_open == 1
end

function LuckyShoppingData:GetLuckyShoppingIsOpen()
	return self.activity_is_open
end

function LuckyShoppingData:GetLuckyShoppingRemind()
	if self.view_is_open == false and self.activity_is_open then
		return 1
	end

	return 0
end

function LuckyShoppingData:SetViewIsOpen(is_open)
	self.view_is_open = is_open
end

--主界面红点刷新
function LuckyShoppingData:FlushHallRedPoindRemind()
	local remind_num = self:GetLuckyShoppingRemind()
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LUCKY_SHOPPING, remind_num > 0)
end