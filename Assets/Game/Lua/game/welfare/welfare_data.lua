WelfareData = WelfareData or BaseClass()

function WelfareData:__init()
	if WelfareData.Instance then
		print_error("[WelfareData] 尝试创建第二个单例模式")
		return
	end
	WelfareData.Instance = self
	self.welfare_cfg = ConfigManager.Instance:GetAutoConfig("welfare_auto")
	self.welfare_gold_turntablel_cfg = ConfigManager.Instance:GetAutoConfig("zhuanpan_auto").reward_pool
	self.addtime_callback = BindTool.Bind(self.AddTime, self)
	self.time_change_callback = {}
	self.online_time = 0

	self.equip_info = {}
	self.offline_info = {
		["exp_buff_effect_second"] = 0,
		["add_double_exp"] = 0,
		["exp_buff_effect_rate"] = 0,
		["role_level_after_fetch"] = 0,
	}
	self.sign_in_days = 0
	self.change_sign_flag = 0
	self.daily_find_list = {}
	self.happy_tree_growth_val_list = {}
	self.happy_tree_reward = 0
	self.total_happy_tree_growth_val = 0
	self.accmulation_signin_days = 0
	self.total_sign_count = 0
	self.turntable_reward_count = 0
	self.turntable_demond_num = 0
	self.turntable_turn = true
	self.offline_mojing = 0
	self.chongjihaoli_reward_flag_list = {}
	self.chongjihaoji_record_list = {}
	GlobalTimerQuest:AddDelayTimer(function()
		self.add_time_quest = GlobalTimerQuest:AddRunQuest(self.addtime_callback, 1)
	end, 0)

	self.red_point_list = {
		["Sign"] = false,
		-- ["OnlineReward"] = false,
		["FindReward"] = false,
		["HappyTree"] = false,
		["LevelReward"] = false,
		["GoldTurntable"] = false,
	}


	--引用二进制
	self.luabit = require"bit"
	self.tree_exchange_had_click = false

	self.callback = BindTool.Bind(self.SetHappyTreeExchangeRedPoint, self)

	GlobalTimerQuest:AddDelayTimer(function()
		ActivityData.Instance:NotifyActChangeCallback(self.callback)
	end, 0)

	RemindManager.Instance:Register(RemindName.WelfareSign, BindTool.Bind(self.GetSignRemind, self))
	RemindManager.Instance:Register(RemindName.WelfareFind, BindTool.Bind(self.GetFindRemind, self))
	RemindManager.Instance:Register(RemindName.WelfareTurntable, BindTool.Bind(self.GetTurntableRemind, self))
end

function WelfareData:__delete()
	RemindManager.Instance:UnRegister(RemindName.WelfareSign)
	RemindManager.Instance:UnRegister(RemindName.WelfareFind)
	RemindManager.Instance:Register(RemindName.WelfareTurntable)
	if ActivityData.Instance ~= nil then
		ActivityData.Instance:UnNotifyActChangeCallback(self.callback)
	end
	if self.add_time_quest then
		GlobalTimerQuest:CancelQuest(self.add_time_quest)
		self.add_time_quest = nil
	end
	WelfareData.Instance = nil
end

function WelfareData:SetHappyTreeExchangeRedPoint()
	self:CheckHappyTreeRedPoint()
end

function WelfareData:GetLevelRewardCfg()
	return self.welfare_cfg and self.welfare_cfg.chong_level_gift or {}
end

function WelfareData:GetLevelRewardList()
	local cfg = TableCopy(self:GetLevelRewardCfg())
	for i,v in ipairs(cfg) do
		if self.chongjihaoli_reward_flag_list[32 - i + 1] then
			v.flag = self.chongjihaoli_reward_flag_list[32 - i + 1]
		end
	end

	function sortfun(a, b)
		if a.flag < b.flag then
			return true
		elseif a.flag == b.flag then
			return a.level < b.level
		else
			return false
		end
	end
	table.sort(cfg, sortfun)

	return cfg
end

function WelfareData:GetExchangeLeftTime()
	self.is_today = false
	local time_cfg = ActivityData.Instance:GetClockActivityByID(22)
	local reward_wdays = {}
	reward_wdays[0] = time_cfg.open_day
	local start_time = Split(time_cfg.open_time, ":")
	local end_time = Split(time_cfg.end_time, ":")
	local time_table = TimeCtrl.Instance:GetServerTimeFormat()
	--本日0点开始已经过了多少秒
	local today_pass_time = time_table.hour * 3600 + time_table.min * 60 + time_table.sec
	--奖励日0点开始到开启活动需多少秒
	local start_interval = start_time[1] * 3600 + start_time[2] * 60
	--奖励日0点开始到结束活动需多少秒
	local end_interval = end_time[1] * 3600 + start_time[2] * 60
	--本日是星期几
	local wday = 0
	if time_table.wday == 1 then
		wday = 7
	else
		wday = time_table.wday - 1
	end

	for k,v in pairs(reward_wdays) do
		if wday == tonumber(v) then
			if today_pass_time > start_interval and today_pass_time < end_interval then
				--在奖励时段
				self.is_today = true
				return end_interval - today_pass_time
			end
		end
	end
	--不在奖励时段
	local reward_wday = 0
	for k,v in pairs(reward_wdays) do
		if tonumber(v) >= wday then
			reward_wday = v
			break
		end
	end

	if reward_wday == 0 then
		local min = 999
		for k,v in pairs(reward_wdays) do
			if tonumber(v) < min then
				min = tonumber(v)
			end
		end
		reward_wday = min
	end

	local left_day = 0
	if tonumber(wday) > tonumber(reward_wday) then
		left_day = 7 - wday + reward_wday - 1
	elseif wday == reward_wday then
		if today_pass_time < start_interval then
			return start_interval - today_pass_time
		else
			left_day = 6
		end
	else
		left_day = reward_wday - wday - 1
	end
	local day_left_time = left_day * 24 * 3600
	local today_end_left_time = 86400 - today_pass_time
	return today_end_left_time + day_left_time + start_interval
end

--设置获取转盘次数
function WelfareData:SetTurnTableRewardCount(value)
	if value ~= nil then
		self.turntable_reward_count = value
		self:CheckGoldTurntableRedPoint()
	end
end

function WelfareData:GetTurnTableRewardCount()
	return self.turntable_reward_count
end

function WelfareData:GetTurnTableDamondNum()
	return self.turntable_demond_num
end

function WelfareData:SetTurnTableDamondNum(value)
	if value ~= nil and value ~= self.turntable_demond_num then
		self.turntable_demond_num = value
		self.turntable_turn = true
	end
end

function WelfareData:SetTurnTableIsTurn(enable)
	self.turntable_turn = enable
end

function WelfareData:GetIsTurn()
	return self.turntable_turn
end

function WelfareData:GetGoldTurnTableCfg()
	return self.welfare_gold_turntablel_cfg
end

function WelfareData:SetWelfareData(protocol)
	self.activity_find_flag = protocol.activity_find_flag
	self.online_reward_mark = protocol.online_reward_mark
	self.continuous_sign_in_days = protocol.continuous_sign_in_days
	self.sing_in_times = protocol.sign_in_today_times
	self.offline_time = protocol.offline_timestamp
	self.offline_exp = protocol.offline_exp
	self.offline_mojing = protocol.offline_mojing
	self.exp_activityfind = protocol.exp_activityfind
	self.role_login_level = protocol.role_login_level

	if protocol.notify_reson == OFFEXP_NOTIFY_REASON.OFFLINE_EXP_NOTICE then
		self.offline_info.exp_buff_effect_second = protocol.exp_buff_effect_second
		self.offline_info.add_double_exp = protocol.add_double_exp
		self.offline_info.exp_buff_effect_rate = protocol.exp_buff_effect_rate / 100 + 1
		self.offline_info.role_level_after_fetch = protocol.role_level_after_fetch
	end

	self.sign_in_reward_mark = protocol.sign_in_reward_mark
	self.sign_in_days = protocol.sign_in_days
	self.change_sign_flag = protocol.change_sign_flag
	self.online_time = protocol.today_online_time
	self.daily_find_list = protocol.daily_find_list
	self.chongzhi_flag = protocol.chongzhi_flag
	self.happy_tree_growth_val_list = protocol.happy_tree_growth_val_list
	self.happy_tree_level = protocol.happy_tree_level
	self.happy_tree_reward = protocol.happy_tree_reward
	self.total_happy_tree_growth_val = protocol.total_happy_tree_growth_val
	self.accmulation_signin_days = protocol.accmulation_signin_days

	self.equip_info.item_count_1 = protocol.green_item_count or 0					-- 离线奖励绿色物品数量
	self.equip_info.item_count_2 = protocol.blue_item_count or 0					-- 离线奖励蓝色物品数量
	self.equip_info.item_count_3 = protocol.purple_item_count or 0					-- 离线紫色装备数量
	self.equip_info.item_count_4 = protocol.orange_item_count or 0					-- 离线金色装备数量
	self.equip_info.item_count_5 = protocol.red_item_count or 0						-- 离线红色装备数量
	self.equip_info.item_count_6 = protocol.pink_item_count or 0					-- 离线奖励粉色物品数量

	self.equip_info.item_resolve_count_1 = protocol.green_item_resolve_count or 0					-- 离线奖励绿色物品分解数量
	self.equip_info.item_resolve_count_2 = protocol.blue_item_resolve_count or 0					-- 离线奖励蓝色物品分解数量
	self.equip_info.item_resolve_count_3 = protocol.purple_item_resolve_count or 0					-- 离线分解紫色装备数量
	self.equip_info.item_resolve_count_4 = protocol.orange_item_resolve_count or 0					-- 离线分解金色装备数量
	self.equip_info.item_resolve_count_5 = protocol.red_item_resolve_count or 0						-- 离线分解红色装备数量
	self.equip_info.item_resolve_count_6 = protocol.pink_item_resolve_count or 0					-- 离线奖励粉色物品分解数量

	self.equip_info.collect_item_count = protocol.collect_item_count or 0							-- 集字物品数量

	self.total_sign_count = 0 				--总签到天数
	local sign_in_flag_list = self:GetSignFlagList()
	for i = 1, 31 do
		if sign_in_flag_list[32-i] ~= 0 then
			self.total_sign_count = self.total_sign_count + 1
		end
	end

	--冲级豪礼
	self.chongjihaoli_reward_flag_list = bit:d2b(protocol.chongjihaoli_reward_mark)
	self.chongjihaoji_record_list = protocol.chongjihaoji_record_list

	self:CheckRedPoint()
end

---------------冲级豪礼--------------------------------
function WelfareData:GetLevelRewardFlag(index)
	return self.chongjihaoli_reward_flag_list[32 - index] or 0
end

function WelfareData:GetHasGetCountByIndex(index)
	return self.chongjihaoji_record_list[index + 1] or 0
end

--等级豪礼红点
function WelfareData:LevelRewardRedPoint()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local can_get = false
	local level_reward_cfg = self:GetLevelRewardCfg()
	for k, v in ipairs(level_reward_cfg) do
		if main_vo.level >= v.level then
			local get_flag = self:GetLevelRewardFlag(v.index)
			if v.is_limit_num == 1 then
				local has_get_count = WelfareData.Instance:GetHasGetCountByIndex(v.index)
				local left_count = v.limit_num - has_get_count
				left_count = left_count < 0 and 0 or left_count
				if left_count > 0 and get_flag == 0 then
					can_get = true
					break
				end
			else
				if get_flag == 0 then
					can_get = true
					break
				end
			end
		end
	end
	self.red_point_list["LevelReward"] = can_get
end
---------------------------------------------------------

function WelfareData:GetEquipInfo()
	return self.equip_info or {}
end

function WelfareData:GetRedPoint(key)
	return self.red_point_list[key]
end

function WelfareData:GetAllRedPoint()
	return self.red_point_list
end

function WelfareData:OnlineTimeRedPoint()
	--在线奖励的红点
	if self.online_reward_mark == nil then
		return
	end
	local online_time_flag = false
	for k,v in pairs(self.welfare_cfg.online_reward) do
		local had_got = self:OnlineRewardMark(v.seq)
		if not had_got then
			local can_get = self:CheckIsCanGetReward(v.minutes)
			if can_get then
				online_time_flag = true
				break
			end
		end
	end
	self.red_point_list["OnlineReward"] = online_time_flag
end

--找回的红点
function WelfareData:CheckFindRedPoint()
	local find_list = self:GetFindData()
	self.red_point_list["FindReward"] = next(find_list) ~= nil
end

--欢乐果树的红点
function WelfareData:CheckHappyTreeRedPoint()
	local apple_list = self:GetHappyTreeRewardCfg()
	if apple_list == nil then
		return
	end
	local tree_flag = false
	for k,v in pairs(apple_list) do
		if not self:GetRewardFetchFlagByType(v.fecth_type) then
			if self.total_happy_tree_growth_val >= v.growth_val then
				tree_flag = true
			end
		end
	end
	if not tree_flag and not self.tree_exchange_had_click then
		tree_flag = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.HAPPYTREE_GROW_EXCHANGE)
	end
	self.red_point_list["HappyTree"] = tree_flag
end

--砖石转盘的红点
function WelfareData:CheckGoldTurntableRedPoint()
	local turntable_flag = false
	if self:GetTurnTableRewardCount() > 0 then
		turntable_flag = true
	end
	self.red_point_list["GoldTurntable"] = turntable_flag
end

function WelfareData:SetHappyTreeExchangeHadClick()
	self.tree_exchange_had_click = true
	self:SetHappyTreeExchangeRedPoint()
end

function WelfareData:GetHappyTreeExchangeHadClick()
	return self.tree_exchange_had_click
end

function WelfareData:GetTotalSignCount()
	return self.total_sign_count
end

function WelfareData:GetCanGetSignReward()
	local can_get = false
	if self.sing_in_times == 0 then
		can_get = true
	-- elseif self.sing_in_times == 1 then
	-- 	if self.chongzhi_flag == 1 then
	-- 		can_get = true
	-- 	end
	end
	return can_get
end

function WelfareData:CheckRedPoint()
	--签到红点
	self:CheckSignRedPoint()
	--找回的红点
	self:CheckFindRedPoint()
	-- --离线经验的红点
	-- self.red_point_list["OfflineExp"] = self.offline_exp > 0
	--欢乐果树的红点
	self:CheckHappyTreeRedPoint()

	--等级豪礼红点
	-- self:LevelRewardRedPoint()

	--钻石转盘红点
	self:CheckGoldTurntableRedPoint()
end

function WelfareData:CheckSignRedPoint()
	local sign_flag = false
	local sign_flag_list = self:GetSignFlagList()
	local total_sign_flag_list = self:GetTotalSignInReardMark()

	local total_sign_reward_list = self:GetTotalSignCfg()

	local now_day = TimeCtrl.Instance:GetServerDay()
	now_day = tonumber(now_day)
	if sign_flag_list[32-now_day] == 0 then
		--当天还没签到
		sign_flag = true
	end
	for k,v in ipairs(total_sign_reward_list) do
		local got_flag = total_sign_flag_list[32-(k-1)]
		if got_flag == 0 then
			local sign_count = self:GetTotalSignCount()
			local can_get = sign_count >= v.total_sign_in
			if can_get then
				sign_flag = true
				break
			end
		end
	end
	self.red_point_list["Sign"] = sign_flag
end

function WelfareData:NotifyWhenTimeChange(callback)
	self.time_change_callback[callback] = callback
end

function WelfareData:UnNotifyWhenTimeChange(callback)
	self.time_change_callback[callback] = nil
end

function WelfareData:GetChongZhiFlag()
	return self.chongzhi_flag
end

--获取福利Cfg
function WelfareData:GetWelfareCfg()
	return self.welfare_cfg
end

function WelfareData:TimeWithZero(num)
	if num < 10 then
		return "0"..num
	else
		return num
	end
end

--把秒转换为00:00:00格式
function WelfareData:TimeFormatWithZero(total_sec)
	local h, m, s = self:TimeFormat(total_sec)
	return self:TimeWithZero(h)..":"..self:TimeWithZero(m)..":"..self:TimeWithZero(s)
end

--把秒转换为时分秒
function WelfareData:TimeFormat(total_sec)
	local time_tab = TimeUtil.Format2TableDHMS(total_sec)
	local hour = time_tab.hour
	local min = time_tab.min
	local sec = time_tab.s
	return hour, min, sec
end

--把秒转换为日时分秒
function WelfareData:TimeFormatWithDay(total_sec)
	local day = math.floor(total_sec/86400)
	local total_sec = total_sec - (day * 86400)
	local h,m,s = self:TimeFormat(total_sec)
	return day, h, m, s
end

--签到--------------------
--获取总签到进度
function WelfareData:GetSignInProcess(total_sign_in_day)
	local count = -1
	for k,v in pairs(self.welfare_cfg.total_sign_in) do
		if v.total_sign_in <= total_sign_in_day then
			count = count + 1
		else
			break
		end
	end
	if count == -1 then
		return 0
	end
	return count/(#self.welfare_cfg.total_sign_in - 2)
end

--获取签到奖励领取信息
function WelfareData:GetSignFlagList()
	return bit:d2b(self.sign_in_days or 0)
end

--获取改变的签到奖励领取情况
function WelfareData:GetChangeSignFlagList()
	return bit:d2b(self.change_sign_flag)
end

--获取总签到奖励领取情况
function WelfareData:GetTotalSignInReardMark()
	return bit:d2b(self.sign_in_reward_mark or 0)
end

--获取某一天的签到奖励
function WelfareData:GetSingleSignReward(month, day)
	local month = month - 1
	for k,v in pairs(self.welfare_cfg.sign_in) do
		if v.month == month and v.day == day then
			return v
		end
	end
end

--获取某个月的签到奖励列表
function WelfareData:GetSingleSignRewardByMonth(month)
	local reward_list = {}
	local month = month - 1
	for k,v in ipairs(self.welfare_cfg.sign_in) do
		if v.month > month then
			break
		end
		if v.month == month then
			table.insert(reward_list, v)
		end
	end
	return reward_list
end

--获取总签到奖励Cfg
function WelfareData:GetTotalSignCfg()
	local total_sign_list = {}
	local time_table = TimeCtrl.Instance:GetServerTimeFormat()
	local now_month = tonumber(time_table.month)
	now_month = now_month - 1
	for k, v in ipairs(self.welfare_cfg.total_sign_in) do
		if v.month > now_month then
			break
		end
		if now_month == v.month then
			table.insert(total_sign_list, v)
		end
	end
	return total_sign_list
end

--获取最大累计签到天数
function WelfareData:GetMaxTotalSignDay()
	local max_day = 0
	if self.welfare_cfg then
		local total_sign_list = self.welfare_cfg.total_sign_in or {}
		local last_tbl = total_sign_list[#total_sign_list] or {}
		max_day = last_tbl.total_sign_in
	end
	return max_day
end

--获取充值签到信息
function WelfareData:GetSignInTimes()
	return self.sing_in_times
end

--获取连续签到日
function WelfareData:GetContinuousSignInDays()
	return self.continuous_sign_in_days
end

--获取该月所有补签奖励列表
function WelfareData:GetAllRecSign()
	local now_day = TimeCtrl.Instance:GetServerDay()
	now_day = tonumber(now_day)
	local time_table = TimeCtrl.Instance:GetServerTimeFormat()
	local sign_flag_list = self:GetSignFlagList()
	local sign_reward_list = self:GetSingleSignRewardByMonth(tonumber(time_table.month))
	local rec_sign_reward_list = {}
	for k, v in ipairs(sign_reward_list) do
		if k < now_day then
			local flag = sign_flag_list[32-k]
			if flag == 0 then
				table.insert(rec_sign_reward_list, v)
			end
		else
			break
		end
	end
	return rec_sign_reward_list
end

--在线奖励----------------
--获取在线奖励Cfg,领取过的会靠下
function WelfareData:GetOnlineRewardCfg()
	local data = {}
	local data_2 = {}
	for k,v in pairs(self.welfare_cfg.online_reward) do
		local mark = self:OnlineRewardMark(v.seq)
		if mark then
			table.insert(data_2, v)
		else
			table.insert(data, v)
		end
	end
	for k,v in pairs(data_2) do
		table.insert(data, v)
	end
	return data
end

--获取在线时间，时分秒格式
function WelfareData:GetOnlineTime()
	return self:TimeFormat(self.online_time)
end

--获取总在线时间
function WelfareData:GetTotalOnlineTime()
	return self.online_time
end

--计时
function WelfareData:AddTime()
	local elapse_time = math.floor(Status.ElapseTime)
	self.online_time = self.online_time + elapse_time + 1
	for k,v in pairs(self.time_change_callback) do
		v()
	end
end

--根据seq获取在线奖励领取情况
function WelfareData:OnlineRewardMark(seq)
	if seq == nil then
		return false
	end
	if self.luabit.band(self.online_reward_mark, self.luabit.lshift(1, seq)) ~= 0 then
		return true
	else
		return false
	end
end

--获取在线奖励数据
function WelfareData:GetOnlineReward()
	local reward_data = {}
	local is_all_get = false
	local online_min = math.floor(self.online_time / 60)
	if not self.online_reward_mark then
		return reward_data, is_all_get
	end
	local online_reward_flag = bit:d2b(self.online_reward_mark)
	for k, v in ipairs(self.welfare_cfg.online_reward) do
		local flag = online_reward_flag[32 - (k - 1)]
		if flag == 0 then
			reward_data = v
			break
		end
	end
	if not next(reward_data) then
		reward_data = self.welfare_cfg.online_reward[#self.welfare_cfg.online_reward]
		is_all_get = true
	end
	return reward_data, is_all_get
end

function WelfareData:CheckIsCanGetReward(min)
	local online_min = math.floor(self.online_time/60)
	return online_min >= min
end

--找回--------------------
--更新找回数据
function WelfareData:UpdateFindData(protocol)
	for k,v in pairs(self.daily_find_list) do
		if v.find_type == protocol.dailyfind_type then
			table.remove(self.daily_find_list, k)
		end
	end
	self:CheckFindRedPoint()
end

local CheckList = {
	[1] = "exp",
	[2] = "honor",
	[3] = "bind_coin",
	[4] = "item_count",
}

--获取找回数据 0、日常找回 1、活动找回
function WelfareData:GetFindData()
	local data = {}
	local count = 1
	local daily_find_list = self.welfare_cfg.daily_find_list
	for k,v in pairs(self.daily_find_list) do
		if self:IsOpen(v.find_type, 0) then
			v.total_type = 0
			for i,j in pairs(daily_find_list) do
				if v.find_type == j.type then
					if j.gold_gongxian_percent == 0 then
						v.guild_gongxian = 0
					elseif j.gold_bind_coin_percent == 0 then
						v.bind_coin = 0
					elseif j.gold_exp_percent == 0 then
						v.exp = 0
					elseif j.gold_honor_percent == 0 then
						v.honor = 0
					end
					v.is_self = j.is_self
					v.show_retrieve = j.show_retrieve
				end
			end
			data[count] = v
			count = count + 1
		end
		-- local is_empty = true
		-- for k2,v2 in pairs(CheckList) do
		-- 	if v[v2] ~= nil and v[v2] > 0 then
		-- 		is_empty = false
		-- 		break
		-- 	end
		-- end
		-- if not is_empty then
		-- 	v.total_type = 0
		-- 	data[count] = v
		-- 	count = count + 1
		-- end
	end
	for k,v in pairs(self.welfare_cfg.activity_find) do
		if self.luabit.band(self.activity_find_flag, self.luabit.lshift(1,v.find_type)) ~= 0 then
			-- local vo = GameVoManager.Instance:GetMainRoleVo()
			local level = self.role_login_level or 0
			local match_cfg = nil
			for k2,v2 in pairs(self.welfare_cfg.activity_find_reward) do
				if v2.find_type == v.find_type then
					if v2.level <= level then
						match_cfg = v2
					end
				end
			end
			local tmp_data = {}
			if match_cfg and next(match_cfg) then
				tmp_data.vo = v
				tmp_data.total_type = 1
				tmp_data.gold_need = match_cfg.cost
				tmp_data.item_list = match_cfg.reward_item

				tmp_data.bind_coin = match_cfg.bind_coin
				-- tmp_data.exp = match_cfg.exp
				tmp_data.exp = 0
				if self.exp_activityfind[match_cfg.find_type] then
					tmp_data.exp = self.exp_activityfind[match_cfg.find_type]
				end
				-- tmp_data.yuanli = match_cfg.yuanli
				-- tmp_data.nvwashi = match_cfg.nvwashi
				tmp_data.honor = match_cfg.honor
				tmp_data.guild_gongxian = match_cfg.guild_gongxian
				tmp_data.cross_honor = match_cfg.cross_honor
				tmp_data.mo_jing = match_cfg.mo_jing
			end
			if self:IsOpen(v.find_type, 1) then
				data[count] = tmp_data
				count = count + 1
			end
		end
	end
	return data
end

--离线--------------------
--获取离线时间,时分秒格式
function WelfareData:GetOffLineTime()
	return self:TimeFormat(self.offline_time or 0)
end

function WelfareData:GetOffLineNormalTime()
	local normal_time = 0
	if self.offline_info and self.offline_info.exp_buff_effect_second then
		normal_time = self.offline_time - (self.offline_info.exp_buff_effect_second)
	end
	return self:TimeFormat(normal_time)
end

function WelfareData:GetOffLineDoublelTime()
	local normal_time = 0
	if self.offline_info and self.offline_info.exp_buff_effect_second then
		normal_time = self.offline_info.exp_buff_effect_second
	end
	local hour, min, sec = self:TimeFormat(normal_time)
	return hour, min, sec
end

--获取离线经验
function WelfareData:GetOffLineExp()
	return self.offline_exp or 0
end

function WelfareData:GetOffLineExpInfo()
	return self.offline_info
end

--获取离线经验
function WelfareData:GetOffLineMojing()
	return self.offline_mojing
end

--获取离线经验Cfg
function WelfareData:GetOffLineExpCfg()
	return self.welfare_cfg.offline_exp
end

--欢乐果树--------------------
--获取果树等级
function WelfareData:GetHappyTreeLevel()
	return self.happy_tree_level or 0
end

--根据奖励类型获取是否领取奖励
function WelfareData:GetRewardFetchFlagByType(fetch_type)
	if self.luabit.band(self.happy_tree_reward,self.luabit.lshift(1,fetch_type - 1)) ~= 0 then
		return true
	else
		return false
	end
end

--获取果树奖励Cfg
function WelfareData:GetHappyTreeRewardCfg()
	if self.happy_tree_level == nil then
		return
	end
	local count = 1
	local reward_list = {}
	for k,v in pairs(self.welfare_cfg.happy_tree) do
		if v.level == self.happy_tree_level then
			reward_list[count] = v
			count = count + 1
		elseif v.level > self.happy_tree_level then
			break
		end
	end
	return reward_list
end

--根据角色果树成长值
function WelfareData:GetHappyTreeGrowValueByType(fetch_type)
	return self.happy_tree_growth_val_list[fetch_type]
end

--根据成长类型果树成长值Cfg
function WelfareData:GetHappyTreeGrowCfgByType(fetch_type)
	for k,v in pairs(self.welfare_cfg.max_growth_val_per_day) do
		if v.level == self.tree_level and v.fetch_type == fetch_type then
			return v
		end
	end
end

--获取果树总成长值
function WelfareData:GetHappyTreeTotalGrowValue()
	return self.total_happy_tree_growth_val
end

--获取成长值比例
function WelfareData:GetHappyTreeTotalGrowScale()
	return self.welfare_cfg.growth_val_config
end

function WelfareData:GetIsExchangeDay()
	return self.is_today
end

-- 得到累计签到天数
function WelfareData:GetAccmulationSigninDays()
	return self.accmulation_signin_days
end

-- 是否显示
function WelfareData:IsOpen(_type, big_type)
	local config = self.welfare_cfg.daily_find_list
	-- 活动找回
	if big_type == 1 then
		config = self.welfare_cfg.activity_find
	end
	if not config then
		return false
	end
	for k,v in pairs(config) do
		if big_type == 1 then
			if v.find_type == _type then
				return v.is_open ~= 0
			end
		else
			if v.type == _type then
				return v.is_open ~= 0
			end
		end
	end
	return false
end

function WelfareData:GetSignRemind()
	if not OpenFunData.Instance:CheckIsHide("welfare") then
		return 0
	end
	return self:GetRedPoint("Sign") and 1 or 0
end

function WelfareData:GetFindRemind()
	if not OpenFunData.Instance:CheckIsHide("welfare") then
		return 0
	end
	return self:GetRedPoint("FindReward") and 1 or 0
end

function WelfareData:GetTurntableRemind()
	if not OpenFunData.Instance:CheckIsHide("welfare") then
		return 0
	end
	return self:GetRedPoint("GoldTurntable") and 1 or 0
end

function WelfareData:GetLevelRewardRemind()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local can_get = false
	local level_reward_cfg = self:GetLevelRewardCfg()
	for k, v in ipairs(level_reward_cfg) do
		if main_vo.level >= v.level then
			local get_flag = self:GetLevelRewardFlag(v.index)
			if v.is_limit_num == 1 then
				local has_get_count = WelfareData.Instance:GetHasGetCountByIndex(v.index)
				local left_count = v.limit_num - has_get_count
				left_count = left_count < 0 and 0 or left_count
				if left_count > 0 and get_flag == 0 then
					can_get = true
					break
				end
			else
				if get_flag == 0 then
					can_get = true
					break
				end
			end
		end
	end
	self.red_point_list["LevelReward"] = can_get

	return can_get and 1 or 0
end

-- 设置是否要显示引导
function WelfareData:SetIsShowGuide(bool)
	self.is_show_guide = bool
end

-- 获取是否要显示引导
function WelfareData:GetIsShowGuide()
	return self.is_show_guide
end