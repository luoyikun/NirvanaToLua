TimeLimitGiftData = TimeLimitGiftData or BaseClass()

TIME_LIMIT_GIFT_REWARD_INDEX = 
{	
	ONE_INDEX = RA_TIMELIMIT_GIFT_FETCH_TYPE.RA_TIMELIMIT_GIFT_FETCH_FIRST,			--第一档
	TWO_INDEX = RA_TIMELIMIT_GIFT_FETCH_TYPE.RA_TIMELIMIT_GIFT_FETCH_SECOND,		--第二档
	THREE_INDEX = RA_TIMELIMIT_GIFT_FETCH_TYPE.RA_TIMELIMIT_GIFT_FETCH_THIRDLY,		--第三档
}
function TimeLimitGiftData:__init()
	if TimeLimitGiftData.Instance then
		print_error("[TimeLimitGiftData] Attemp to create a singleton twice !")
	end
	TimeLimitGiftData.Instance = self

	self.time_limit_gift_info = {
		reward_can_fetch_flag1 = 0,
		reward_fetch_flag1 = 0,
		reward_can_fetch_flag2 = 0,
		reward_fetch_flag2 = 0,
		open_flag = 0,
		join_vip_level = 0,
		begin_timestamp = 0,
		reward_can_fetch_flag3 = 0,
		reward_fetch_flag3 = 0,
	}
	self.timelimit_gift_cfg = nil
end

function TimeLimitGiftData:__delete()
	TimeLimitGiftData.Instance = nil
end

--限时礼包的所有配置
function TimeLimitGiftData:GetTimeLimitGiftAllCfg()
	if self.timelimit_gift_cfg then
		return self.timelimit_gift_cfg
	end

	local act_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	if act_cfg then
		self.timelimit_gift_cfg = act_cfg.timelimit_gift
	end
	return self.timelimit_gift_cfg
end

--得到当前开服天数下的符合玩家自身等级的相关配置
function TimeLimitGiftData:GetLimitGiftCfg()
	local data_cfg = {}
	local act_cfg = self:GetTimeLimitGiftAllCfg()
	if nil == act_cfg then
		return data_cfg
	end

	local value = DailyChargeData.Instance:GetLeiJiChongZhiValue()

	local cfg = ActivityData.Instance:GetRandActivityConfig(act_cfg, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_GIFT)
	for i,v in ipairs(cfg) do
		if v.limit_charge_max == -1 and value >= v.limit_charge_min then
			data_cfg = v
			break
		elseif value >= v.limit_charge_min and value <= v.limit_charge_max then
			data_cfg = v
			break
		end
	end

	return data_cfg
end

function TimeLimitGiftData:SetRestTime(time)
	self.rest_time = time
end

function TimeLimitGiftData:GetRestTime()
	return self.rest_time or 0
end

function TimeLimitGiftData:SetTimeLimitGiftInfo(protocol)
	self.time_limit_gift_info.reward_can_fetch_flag1 = protocol.reward_can_fetch_flag1
	self.time_limit_gift_info.reward_fetch_flag1 = protocol.reward_fetch_flag1
	self.time_limit_gift_info.reward_can_fetch_flag2 = protocol.reward_can_fetch_flag2
	self.time_limit_gift_info.reward_fetch_flag2 = protocol.reward_fetch_flag2
	self.time_limit_gift_info.join_vip_level = protocol.join_vip_level
	self.time_limit_gift_info.open_flag = protocol.open_flag
	self.time_limit_gift_info.begin_timestamp = protocol.begin_timestamp
	-- self.time_limit_gift_info.reward_can_fetch_flag3 = protocol.reward_can_fetch_flag3
	-- self.time_limit_gift_info.reward_fetch_flag3 = protocol.reward_fetch_flag3

	local can_reward = (protocol.reward_can_fetch_flag1 ~= 0 and protocol.reward_fetch_flag1 == 0) or 
						(protocol.reward_can_fetch_flag2 ~= 0 and protocol.reward_fetch_flag2 == 0)
						-- (protocol.reward_can_fetch_flag3 ~= 0 and protocol.reward_fetch_flag3 == 0)
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_GIFT, can_reward)
end

function TimeLimitGiftData:GetTimeLimitGiftInfo()
	return self.time_limit_gift_info
end

function TimeLimitGiftData:GetActivityOpenFlag()
	return self.time_limit_gift_info.open_flag
end

--当前为第几档
function TimeLimitGiftData:GetCurAwardIndex()
	if self.time_limit_gift_info.reward_fetch_flag1 == 0 then
		return TIME_LIMIT_GIFT_REWARD_INDEX.ONE_INDEX
	elseif self.time_limit_gift_info.reward_fetch_flag2 == 0 then
		return TIME_LIMIT_GIFT_REWARD_INDEX.TWO_INDEX
	-- elseif self.time_limit_gift_info.reward_fetch_flag3 == 0 then
	-- 	return TIME_LIMIT_GIFT_REWARD_INDEX.THREE_INDEX
	end
end

--界面需要显示的配置
function TimeLimitGiftData:GetShowNeedRelevantCfg()
	local award_index = self:GetCurAwardIndex()
	local cfg = self:GetLimitGiftCfg()
	local cfg_modle = {}
	if nil == next(cfg) then
		return	cfg_modle
	end
	if award_index == TIME_LIMIT_GIFT_REWARD_INDEX.ONE_INDEX then
		cfg_modle.charge_value = cfg.charge_value
		cfg_modle.gift_value = cfg.gift_value
		cfg_modle.reward_item = cfg.reward_item
	elseif award_index == TIME_LIMIT_GIFT_REWARD_INDEX.TWO_INDEX then
		cfg_modle.charge_value = cfg.charge_value2
		cfg_modle.gift_value = cfg.gift_value2
		cfg_modle.reward_item = cfg.reward_item2
	-- else
	-- 	cfg_modle.charge_value = cfg.charge_value3
	-- 	cfg_modle.gift_value = cfg.gift_value3
	-- 	cfg_modle.reward_item = cfg.reward_item3
	end
	return cfg_modle
end

--是否能够领取奖励
function TimeLimitGiftData:IsCanGetAward()
	if (self.time_limit_gift_info.reward_can_fetch_flag1 ~= 0 and self.time_limit_gift_info.reward_fetch_flag1 == 0) or
		(self.time_limit_gift_info.reward_can_fetch_flag2 ~= 0 and self.time_limit_gift_info.reward_fetch_flag2 == 0) then
		-- (self.time_limit_gift_info.reward_can_fetch_flag3 ~= 0 and self.time_limit_gift_info.reward_fetch_flag3 == 0) then
		return true
	end

	return false
end