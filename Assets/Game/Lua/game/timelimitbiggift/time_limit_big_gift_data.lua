TimeLimitBigGiftData = TimeLimitBigGiftData or BaseClass()

function TimeLimitBigGiftData:__init()
	if TimeLimitBigGiftData.Instance then
		print_error("[TimeLimitBigGiftData] Attemp to create a singleton twice !")
	end
	TimeLimitBigGiftData.Instance = self
	self.reward_fetch_flag = 0
	self.time_limit_big_gift_info = {
		is_already_buy = 0,
		join_vip_level = 0,
		open_flag = 0,
		begin_timestamp = 0,
	}
	RemindManager.Instance:Register(RemindName.LimitBigGift, BindTool.Bind(self.BigGiftFindRedPoint, self))
end

function TimeLimitBigGiftData:__delete()
	TimeLimitBigGiftData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.LimitBigGift)
end

function TimeLimitBigGiftData:BigGiftFindRedPoint()
	-- 策划需求上线需要红点，做成假红点
	return 0
end

function TimeLimitBigGiftData:GetLimitGiftCfg()
	local table_data = {}
	local seq_data = 0
	---等候配表工作完成后，读取相应的随机活动表
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().timelimit_luxury_gift_bag
	local rand_cfg = ActivityData.Instance:GetRandActivityConfig(cfg, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_BIG_GIFT)
	for i,v in ipairs(rand_cfg) do
		if self.time_limit_big_gift_info.join_vip_level <= v.limit_vip_level then
			return v
		end
	end
	return rand_cfg[1]
end

function TimeLimitBigGiftData:GetLimitGiftCfgSeq()
	if self:GetLimitGiftCfg() then
		return self:GetLimitGiftCfg().seq or 0
	end

	return 0
end

function TimeLimitBigGiftData:GetHasFetchFlag()
	return self.reward_fetch_flag
end

function TimeLimitBigGiftData:SetRestTime(time)
	self.rest_time = time
end

function TimeLimitBigGiftData:GetRestTime()
	local cfg = self:GetLimitGiftCfg()
	local info = self:GetTimeLimitGiftInfo()
	local time = nil
	if cfg and info then
		local end_time = info.begin_timestamp + cfg.limit_time
		--获取当天的结束时间戳
		local now_day_end_time = TimeUtil.NowDayTimeEnd(TimeCtrl.Instance:GetServerTime())
		end_time = math.min(end_time, now_day_end_time)		
		time = end_time - TimeCtrl.Instance:GetServerTime()
		return time
	end

	return time
end

function TimeLimitBigGiftData:SetTimeLimitGiftInfo(protocol)
	self.time_limit_big_gift_info.is_already_buy = protocol.is_already_buy or 0
	self.time_limit_big_gift_info.join_vip_level = protocol.join_vip_level or 0
	self.time_limit_big_gift_info.begin_timestamp = protocol.begin_timestamp or 0
	self.time_limit_big_gift_info.open_flag = protocol.time_limit_luxury_gift_open_flag or 0
end

function TimeLimitBigGiftData:GetTimeLimitGiftInfo()
	return self.time_limit_big_gift_info
end