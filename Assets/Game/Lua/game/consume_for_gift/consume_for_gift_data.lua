ConsumeForGiftData = ConsumeForGiftData or BaseClass()

function ConsumeForGiftData:__init()
	if ConsumeForGiftData.Instance then
		ErrorLog("[ConsumeForGiftData] attempt to create singleton twice!")
		return
	end
	self.is_open = false
	ConsumeForGiftData.Instance =self
	RemindManager.Instance:Register(RemindName.CousumeForGiftRemind, BindTool.Bind(self.GetConsumeForGiftRemind, self))

	self.rednume = 0
end

function ConsumeForGiftData:__delete()
	ConsumeForGiftData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.CousumeForGiftRemind)
end

function ConsumeForGiftData:GetConsumeForGiftCfg()
	local rand_act_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().consume_for_gift
	
	if rand_act_cfg == nil then return rand_act_cfg end

	local consume_for_gift_cfg = ActivityData.Instance:GetRandActivityConfig(rand_act_cfg, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_FOR_GIFT) or nil

	return consume_for_gift_cfg
end

function ConsumeForGiftData:SetConsumeForGiftAllInfo(protocol)
	self.consume_for_gift_all_info = {}

	self.consume_for_gift_all_info.total_consume_gold = protocol.total_consume_gold
	self.consume_for_gift_all_info.cur_points = protocol.cur_points
	self.consume_for_gift_all_info.item_exchange_times = protocol.item_exchange_times
end

function ConsumeForGiftData:GetConsumeForGiftAllInfo()
	return self.consume_for_gift_all_info or {}
end

function ConsumeForGiftData:SetRedPoint(rednume)
	self.rednume = rednume
end

function ConsumeForGiftData:GetRedPoint()
	return self.rednume
end

--红点提示
function ConsumeForGiftData:GetConsumeForGiftRemind()
	if self.consume_for_gift_all_info == nil then return 0 end
	local rand_act_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().consume_for_gift
	local consume_for_gift_cfg = ActivityData.Instance:GetRandActivityConfig(rand_act_cfg, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_FOR_GIFT) or {}
	local cfg = self:GetConsumeForGiftAllInfo()
	local remind_num = 0
	if cfg.item_exchange_times == nil then return 0 end
	
	for i = 1,#consume_for_gift_cfg do
		if cfg.item_exchange_times[i] and cfg.item_exchange_times[i] >= consume_for_gift_cfg[i].double_points_need_ex_times then
			if cfg.cur_points >= consume_for_gift_cfg[i].need_points * 2 then
				remind_num = 1
				break
			end
		else
			if cfg.cur_points >= consume_for_gift_cfg[i].need_points then
				remind_num = 1
				break
			end
		end
	end
	if not self.is_open then
		-- ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_FOR_GIFT, true)
		return 1
	else
		-- ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_FOR_GIFT, remind_num > 0)
		return remind_num
	end
end

--主界面红点刷新
function ConsumeForGiftData:FlushHallRedPoindRemind()
	RemindManager.Instance:CreateIntervalRemindTimer(RemindName.CousumeForGiftRemind)
	local remind_num = self:GetConsumeForGiftRemind()
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_FOR_GIFT, remind_num > 0)
	-- ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_FOR_GIFT, not self.is_open)
end

function ConsumeForGiftData:SetIsOpen()
	self.is_open = true
end