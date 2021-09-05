	TOUZIJIHUA_OPERATE =
{
	NEW_TOUZIJIHUA_OPERATE_BUY = 0,				-- 购买
	NEW_TOUZIJIHUA_OPERATE_FETCH = 1,			-- 领取普通奖励
	NEW_TOUZIJIHUA_OPERATE_FIRST = 2,			-- 获取周卡立返
	NEW_TOUZIJIHUA_OPERATE_VIP_FETCH = 3,		-- 领取vip奖励
}
INVEST_TOTAL_DAYS = 7

InvestData = InvestData or BaseClass()

InvestData.FIRST_LEVEL_REMIND = false		-- 是否有过第一次提醒(等级投资)
InvestData.FIRST_MONTH_REMIND = false		-- 是否有过第一次提醒(周卡投资)
InvestData.FIRST_CHONGZHI_REMIND = false    -- 是否有过第一次提醒(充值)
function InvestData:__init()
	if InvestData.Instance then
		print_error("[InvestData] Attemp to create a singleton twice !")
	end
	InvestData.Instance = self
	self.invest_info = {}
	self.invest_is_opened = false --投资面板是否打开过（本次上线）
	self.plan_cfg = {}
	self.max_level_t = {}
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("touzijihua_auto").plan) do
		self.plan_cfg[v.type] = self.plan_cfg[v.type] or {}
		self.plan_cfg[v.type][v.seq + 1] = v
		if self.max_level_t[v.type] == nil or self.max_level_t[v.type] < v.need_level then
			self.max_level_t[v.type] = v.need_level
		end
	end
	self.nec_plan_cfg = {}
	self.nec_plan_cfg[1] = {
		day_index = -1,
		reward_gold_bind = ConfigManager.Instance:GetAutoConfig("touzijihua_auto").other[1].new_plan_price
	}

	self.plan_config = ListToMap(ConfigManager.Instance:GetAutoConfig("touzijihua_auto").plan, "type", "seq")

	for i,v in ipairs(ConfigManager.Instance:GetAutoConfig("touzijihua_auto").new_plan) do
		table.insert(self.nec_plan_cfg, v)
	end
	self.delay_show_redpoint_time = 15

	RemindManager.Instance:Register(RemindName.Invest, BindTool.Bind(self.GetInvestRemind, self))
	RemindManager.Instance:Register(RemindName.MonthInvest, BindTool.Bind(self.GetInvestRedPointStatus, self))

	self.active_fb_plan = 0
	self.fb_plan_reward_flag = 0
	self.fb_pass_level = 0

	self.active_boss_plan = 0
	self.boss_plan_reward_flag = 0
	self.kill_boss_num = 0

	self.active_shenyu_boss_plan = 0
	self.shenyu_boss_plan_reward_flag = 0
	self.kill_shenyu_boss_num = 0

	self.show_sign = 0
	self.now_seq = 0
end

function InvestData:__delete()
	RemindManager.Instance:UnRegister(RemindName.Invest)
	RemindManager.Instance:UnRegister(RemindName.MonthInvest)
	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end
	InvestData.Instance = nil
	self.show_sign = 0 
	self.now_seq  = 0
end

function InvestData:SetIsOpenStatus(is_open)
	self.invest_is_opened = is_open
end

function InvestData:GetOtherAuto()
	return ConfigManager.Instance:GetAutoConfig("touzijihua_auto").other
end

function InvestData:CanInvestLevel(plan_type)
	return self.max_level_t[plan_type] == nil or self.max_level_t[plan_type] >= PlayerData.Instance.role_vo.level
end

function InvestData:GetMaxLevel()
	return self.max_level_t[1]
end

function InvestData:GetNewPlanAuto()
	return self.nec_plan_cfg
end

function InvestData:GetPlanAuto(plan_type)
	return self.plan_cfg[plan_type] or {}
end

function InvestData:GetRewardInfo(day_index)
	local cfg = self:GetNewPlanAuto()
	for k,v in pairs(cfg) do
		if v.day_index == day_index then
			return v
		end
	end
end

local a_has_reward, b_has_reward = false, false
local a_can_reward, b_can_reward = false, false
local off_a, off_b = 1000, 1000
function InvestData.SortInvestDataList(a, b)
	off_a = 1000
	off_b = 1000
	if a.need_level ~= nil then
		a_has_reward = InvestData.Instance:GetNormalInvestHasReward(a.type, a.seq)
		b_has_reward = InvestData.Instance:GetNormalInvestHasReward(b.type, b.seq)
	else
		a_has_reward = InvestData.Instance:GetMonthCardHasReward(a.day_index)
		b_has_reward = InvestData.Instance:GetMonthCardHasReward(b.day_index)
	end
	if not a_has_reward and b_has_reward then
		off_a = off_a + 10
	elseif a_has_reward and not b_has_reward then
		off_b = off_b + 10
	else
		if a.need_level ~= nil then
			a_can_reward = InvestData.Instance:GetNormalInvestCanReward(a)
			b_can_reward = InvestData.Instance:GetNormalInvestCanReward(b)
		else
			a_can_reward = InvestData.Instance:GetMonthCardCanReward(a.day_index)
			b_can_reward = InvestData.Instance:GetMonthCardCanReward(b.day_index)
		end
		if a_can_reward and not b_can_reward then
			off_a = off_a + 100
		elseif not a_can_reward and b_can_reward then
			off_b = off_b + 100
		end
	end
	if a.need_level ~= nil then
		if a.need_level < b.need_level then
			off_a = off_a + 1
		elseif a.need_level > b.need_level then
			off_b = off_b + 1
		end
	else
		if a.day_index < b.day_index then
			off_a = off_a + 1
		elseif a.day_index > b.day_index then
			off_b = off_b + 1
		end
	end

	return off_a > off_b
end

function InvestData:SortInvestData()
	for k,v in pairs(self.plan_cfg) do
		table.sort(v, InvestData.SortInvestDataList)
	end
	table.sort(self.nec_plan_cfg, InvestData.SortInvestDataList)
end

--获取投资计划是否有奖励可以领取标记（购买起到当天）
function InvestData:GetInvestAwardFlag()
	local day = 1
	local reward_flag = false
	-- local vip_reward_flag = false
	if nil == self.invest_info.buy_time then
		return false
	end
	if 0 ~= self.invest_info.buy_time then
		day = math.floor(TimeCtrl.Instance:GetDayIndex(self.invest_info.buy_time, TimeCtrl.Instance:GetServerTime()) + 1)
		if day > 7 then
			day = 7
		end
	end
	for i=1 ,day do
		if self.invest_info.reward_flag_list[33 - i] == 0 then
			reward_flag = true
		end
		-- if self.invest_info.vip_reward_flag_list[33 - i] == 0 then
		-- 	vip_reward_flag = true
		-- end
	end
	-- local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level

	if reward_flag then --or (vip_reward_flag and vip_level >= 6) then
		return true
	end
	return false
end

function InvestData:SetShowTouZiSign(sign)
		self.show_sign = sign
end
function InvestData:GetShowTouZiSign()
		return self.show_sign 
end

--获取红点标记
function InvestData:GetInvestRedPointStatus()
	return self:GetMonthInvestRemind()--投资过
end

--获取红点标记
function InvestData:GetInvestRemind()
	return self:GetNormalInvestRemind()
end

--7天奖励是否全部领取
function InvestData:GetSevenDayAwardFlag()
	for i = 1, 7 do
		if self.invest_info.reward_flag_list[33 - i] == 0 then
			return false
		end
	end
	return true
end

--vip奖励是否全部领取
function InvestData:GetVipAwardFlag()
	for i = 1, 7 do
		if self.invest_info.vip_reward_flag_list[33 - i] == 0 then
			return false
		end
	end
	return true
end

--判断是否关闭投资计划
function InvestData:IsOpenInvestButton()
	return true
end

function InvestData:OnSCTouZiJiHuaInfo(protocol)
	self.invest_info.active_plan_0 = protocol.active_plan_0
	self.invest_info.active_plan_1 = protocol.active_plan_1
	self.invest_info.active_plan_2 = protocol.active_plan_2
	self.invest_info.active_plan_3 = protocol.active_plan_3
	self.invest_info.new_plan_first_reward_flag = protocol.new_plan_first_reward_flag
	self.invest_info.plan_0_reward_flag = protocol.plan_0_reward_flag
	self.invest_info.plan_1_reward_flag = protocol.plan_1_reward_flag
	self.invest_info.plan_2_reward_flag = protocol.plan_2_reward_flag
	self.invest_info.plan_3_reward_flag = protocol.plan_3_reward_flag
	self.invest_info.active_highest_plan = protocol.active_highest_plan
	self.invest_info.buy_time = protocol.buy_time
	self.invest_info.reward_flag_list = bit:d2b(protocol.reward_flag)
	self.invest_info.vip_reward_flag_list = bit:d2b(protocol.vip_reward_flag)
	self.invest_info.reward_gold_bind_flag = protocol.reward_gold_bind_flag
	self.invest_info.list_len = protocol.list_len
	self.invest_info.foundation_reward_times = protocol.foundation_reward_times
	self:SortInvestData()
end

function InvestData:GetNormalActivePlan()
	local plan = -1
	for i = 0, 3 do
		if self.invest_info["active_plan_" .. i] == 1 then
			plan = i
		end
	end
	return plan
end

function InvestData:GetInvestInfo()
	return self.invest_info
end

function InvestData:GetInvestPrice()
	return self:GetOtherAuto()[1].new_plan_price or 0
end

function InvestData:GetInvestRewardList(day_index)
	local cfg = self:GetRewardInfo(day_index)
	local new_list = {}
	for i = 0, 1 do
		new_list[#new_list + 1] = cfg.reward_item[i]
	end
	for i = 0, 1 do
		new_list[#new_list + 1] = cfg.vip_reward_item[i]
	end
	return new_list
end

function InvestData:GetRewardState(day_text)
	local info = self:GetInvestInfo()
	local new_list = {}
	if info.reward_flag_list[32 - day_text] == 0 then
		new_list[#new_list + 1] = false
	else
		new_list[#new_list + 1] = true
	end
	return new_list
end

function InvestData:GetMonthCardHasReward(day_index)
	if day_index < 0 then
		return self.invest_info.new_plan_first_reward_flag == 1
	end
	return bit:_and(1, bit:_rshift(self.invest_info.reward_gold_bind_flag or 0, day_index)) > 0
end


function InvestData:GetMonthCardAllReward()
	return self.invest_info.new_plan_first_reward_flag == 1 and self.invest_info.reward_gold_bind_flag == 127
end

function InvestData:GetMonthCardCanReward(day_index)
	if self.invest_info.buy_time == nil or self.invest_info.buy_time == 0 then
		return false
	end
	local day = TimeCtrl.Instance:GetDayIndex(self.invest_info.buy_time, TimeCtrl.Instance:GetServerTime())
	return day_index <= math.max(day, 0)
end

function InvestData:GetNormalInvestHasReward(plan_type, seq)
	local flag = self.invest_info["plan_" .. plan_type .. "_reward_flag"] or 0
	return bit:_and(1, bit:_rshift(flag, seq)) > 0
end

-- 还有未领取奖励
function InvestData:GetAlsoHasReward(plan_type)
	local plan_cfg = ConfigManager.Instance:GetAutoConfig("touzijihua_auto").plan
	for k,v in pairs(plan_cfg) do
		if plan_type == v.type then
			if not self:GetNormalInvestHasReward(plan_type, v.seq) then
				return false
			end
		end
	end
	return true
end

function InvestData:GetNormalInvestCanReward(data)
	return data.need_level <= PlayerData.Instance.role_vo.level
end


function InvestData:GetChongZhiInvestRemind()
	return InvestData.FIRST_CHONGZHI_REMIND and 0 or 1
end

-- 等级投资红点逻辑：
-- 1.可领取奖励时： 红点提示
-- 2.未投资时：每次登陆红点提示，点击进入界面后，红点消失。
function InvestData:GetNormalInvestRemind()
	if not OpenFunData.Instance:CheckIsHide("investview") then
		return 0
	end

	local level = PlayerData.Instance.role_vo.level
	local max_level = 550
	local original_plan_cfg = ConfigManager.Instance:GetAutoConfig("touzijihua_auto").plan
	
	if KaifuActivityData.Instance:TouZiButtonInfo() then	-- 等级投资活动关闭
		return 0
	end

	if self.invest_info == nil or self.invest_info.active_highest_plan == nil then
		return 0
	end

	local is_remind = RemindManager.Instance:RemindToday(RemindName.Invest)
	if self.invest_info.active_highest_plan < 0 and not is_remind then
		return 1
	end

	local plan_type = self:GetNormalActivePlan()
	local cfg = self.plan_cfg[plan_type]
	if nil == cfg then
		return 0
	end

	local num = 0
	
	for k,v in pairs(cfg) do
		if v.need_level <= level and not self:GetNormalInvestHasReward(plan_type, v.seq) then
			num = num + 1
		end
	end
	return num
end

-- 周卡投资红点逻辑：
-- 1.可领取奖励时： 红点提示
-- 2.未投资时：每次登陆红点提示，点击进入界面后，红点消失。
function InvestData:GetMonthInvestRemind()
	local monthcardinvestment_cfg = ActivityData.Instance:GetClockActivityByID(TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_MONTHCARDINVESTMENT)
	if monthcardinvestment_cfg and monthcardinvestment_cfg.opensever_day and monthcardinvestment_cfg.min_level then
		if (TimeCtrl.Instance:GetCurOpenServerDay() < tonumber(monthcardinvestment_cfg.opensever_day)) then
			return 0
		end
	end

	if not OpenFunData.Instance:CheckIsHide("investview") then
		return 0
	end

	if self.invest_info == nil or self.invest_info.active_highest_plan == nil then
		return 0
	end

	local is_remind = RemindManager.Instance:RemindToday(RemindName.MonthInvest)
	if not is_remind then
		return 1
	end

	if self.invest_info.buy_time == 0 and not is_remind and not self:GetMonthCardAllReward() then
		return 1
	end

	local num = 0
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("touzijihua_auto").new_plan) do
		if self:GetMonthCardCanReward(v.day_index) and not self:GetMonthCardHasReward(v.day_index) then
			num = num + 1
		end
	end
	return num

end

-- 等级投资，投资档次红点提示
function InvestData:GetLevelRemind(plan_type)
	local plan_cfg = ConfigManager.Instance:GetAutoConfig("touzijihua_auto").plan
	local cfg = {}
	for k,v in pairs(plan_cfg) do
		if v.type == plan_type then
			cfg[k] = v
		end
	end
	
	if plan_type == self.invest_info.active_highest_plan then
		local level = PlayerData.Instance.role_vo.level
		for k,v in pairs(cfg) do
			if v.need_level <= level and not self:GetNormalInvestHasReward(plan_type, v.seq) then
				return true
			end
		end
	end
	return false
end

function InvestData:GetActiveHighestPlan()
	return self.invest_info.active_highest_plan or -1
end

-- 根据当前投资类型和索引获取已经领取的投资元宝
function InvestData:GetHasRewardGoldByTypeAndSeq(invest_type, seq)
	local get_gold = 0
	for i = 0, invest_type - 1 do
		local has_reward = self.plan_config[i][seq]
		if self:GetNormalInvestHasReward(i, seq) and has_reward and has_reward.reward_gold_bind then
			get_gold = has_reward.reward_gold_bind
		end
	end

	return get_gold
end

-- 获取投资获得的绑元 周卡投资
function InvestData:GetTouZi()
	local cfg = ConfigManager.Instance:GetAutoConfig("touzijihua_auto").new_plan
	return cfg[1].reward_gold_bind
end

function InvestData:GetNewPlanCfg()
	local cfg = ConfigManager.Instance:GetAutoConfig("touzijihua_auto").other
	return cfg
end

-- 获取itemcell数据 周卡投资
function InvestData:GetItemCellData()
	local week_invest_cfg = {}
	local week_invest_plan_cfg = ConfigManager.Instance:GetAutoConfig("touzijihua_auto").new_plan
	for i=1, #week_invest_plan_cfg do
		week_invest_cfg[i] = TableCopy(week_invest_plan_cfg[i])
	end
	local week_invest_rebate = self:GetNewPlanCfg()[1].new_plan_reward
	local cfg = {new_plan_reward = week_invest_rebate, day_index = -1}
	table.insert(week_invest_cfg, 1, TableCopy(cfg))
	for i=1, #week_invest_cfg do
		if self:GetMonthCardHasReward(week_invest_cfg[i].day_index) then
			week_invest_cfg[i].get_reward = 1
		else
			week_invest_cfg[i].get_reward = 0
		end
	end
	table.sort(week_invest_cfg, SortTools.KeyLowerSorter("get_reward", "day_index"))
	return week_invest_cfg
end

function InvestData:GetDayFanli(index)
	local day_index = index
	local day_count = 0
	local cfg = ConfigManager.Instance:GetAutoConfig("touzijihua_auto").new_plan
	if cfg == nil then return 0 end

	for k,v in pairs(cfg) do
		if v.day_index <= index then
			day_count = day_count + v.reward_gold_bind
		end
	end

	return day_count
end

-- 根据类型和索引获取累积返利 等级投资
function InvestData:GetLeiJiFanLi(type_plane, index)
	local plan_cfg = ConfigManager.Instance:GetAutoConfig("touzijihua_auto").plan
	if nil == plan_cfg then
		return 0
	end
	local plan_cfg_type = {}
	for k, v in pairs(plan_cfg) do
		if type_plane == v.type then
			plan_cfg_type[v.seq] = v
		end
	end

	if plan_cfg_type == nil then
		return 0
	end
	
	local lei_ji_fan_li = 0
	for i = 0, index do
		lei_ji_fan_li = lei_ji_fan_li + plan_cfg_type[i].reward_gold_bind
	end
	return lei_ji_fan_li
end

-- 根据等级计算文字显示 等级投资
function InvestData:GetTextShow(need_level)
	local text_str = ""
	if need_level <= 1 then
		text_str = Language.Activity.CunRuFanLi
	else
		local i, j = math.modf(need_level/100)
		text_str = string.format(Language.Activity.LevelShow, need_level)
	end
	return text_str
end

function InvestData:GetTouZiPlanInfoNum()
	return self.invest_info.list_len
end

function InvestData:GetTouZiPlanInfo()
	return self.invest_info.foundation_reward_times
end


function InvestData:GetCurSeq(level)
	local level_cfg = KaifuActivityData.Instance:GetTouZicfg()
	local cur_seq = -1
	for k, v in pairs(level_cfg) do
		if v.active_level_min <= level and level <= v.active_level_max then
			cur_seq = v.seq
		end
	end
	return cur_seq
end

function InvestData:IsCurReachLevel(level)
	local level_cfg = KaifuActivityData.Instance:GetTouZicfg()
	local flag = false
	for k, v in pairs(level_cfg) do
		if v.active_level_min == level then
			flag = true
		end
	end
	return flag
end

----------------副本boss投资----------------
function InvestData:OnSCTouzijihuaFbBossInfo(protocol)
	self.active_fb_plan = protocol.active_fb_plan
	self.fb_plan_reward_flag = protocol.fb_plan_reward_flag
	self.fb_pass_level = protocol.fb_pass_level

	self.active_boss_plan = protocol.active_boss_plan
	self.boss_plan_reward_flag = protocol.boss_plan_reward_flag
	self.kill_boss_num = protocol.kill_boss_num

	self.active_shenyu_boss_plan = protocol.active_shenyu_boss_plan
	self.shenyu_boss_plan_reward_flag = protocol.shenyu_boss_plan_reward_flag
	self.kill_shenyu_boss_num = protocol.kill_shenyu_boss_num
end

function InvestData:GetFuBenPassLevel()
	return self.fb_pass_level
end

function InvestData:GetBossKillNum()
	return self.kill_boss_num
end

function InvestData:GetShenYuBossKillNum()
	return self.kill_shenyu_boss_num
end

function InvestData:GetActiveFbPlan()
	return self.active_fb_plan > 0
end

function InvestData:GetActiveBossPlan()
	return self.active_boss_plan > 0
end

function InvestData:GetShenYuActiveBossPlan()
	return self.active_shenyu_boss_plan > 0
end

function InvestData:CheckIsActiveFbByID(id)
	if 0 ~= (bit:_and(self.active_fb_plan, bit:_lshift(1, id - 1))) then
		return true
	else
		return false
	end
end

function InvestData:CheckIsActiveBossByID(id)
	if 0 ~= (bit:_and(self.active_boss_plan, bit:_lshift(1, id - 1))) then
		return true
	else
		return false
	end
end

function InvestData:CheckIsFetchedFbByID(id)
	if 0 ~= (bit:_and(self.fb_plan_reward_flag, bit:_lshift(1, id - 1))) then
		return true
	else
		return false
	end
end

function InvestData:CheckIsFetchedBossByID(id)
	if 0 ~= (bit:_and(self.boss_plan_reward_flag, bit:_lshift(1, id - 1))) then
		return true
	else
		return false
	end
end

function InvestData:CheckIsActiveShenYuBossByID(id)
	if 0 ~= (bit:_and(self.active_shenyu_boss_plan, bit:_lshift(1, id - 1))) then
		return true
	else
		return false
	end
end

function InvestData:CheckIsFetchedShenYuBossByID(id)
	if 0 ~= (bit:_and(self.shenyu_boss_plan_reward_flag, bit:_lshift(1, id - 1))) then
		return true
	else
		return false
	end
end
