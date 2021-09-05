require("game/timelimitbiggift/time_limit_big_gift_data")
require("game/timelimitbiggift/time_limit_big_gift_view")

TimeLimitBigGiftCtrl = TimeLimitBigGiftCtrl or BaseClass(BaseController)
function TimeLimitBigGiftCtrl:__init()
	if TimeLimitBigGiftCtrl.Instance then
		print_error("[TimeLimitBigGiftCtrl] Attemp to create a singleton twice !")
	end
	TimeLimitBigGiftCtrl.Instance = self

	self.data = TimeLimitBigGiftData.New()
	self.view = TimeLimitBigGiftView.New(ViewName.TimeLimitBigGiftView)

	self:RegisterAllProtocols()

	self.activity_call_back = BindTool.Bind(self.ActivityChange, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
	self.first_tankuang = true
end

function TimeLimitBigGiftCtrl:__delete()
	TimeLimitBigGiftCtrl.Instance = nil

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end
	self.first_tankuang = true
end


function TimeLimitBigGiftCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRATimeLimitLuxuryGiftBagInfo , "OnSCRATimeLimitLuxuryGiftBagInfo")
end

function TimeLimitBigGiftCtrl:OnSCRATimeLimitLuxuryGiftBagInfo(protocol)
	self.data:SetTimeLimitGiftInfo(protocol)
	if self.view and self.view:IsOpen() then
		self.view:Flush()
	end

	local cfg = ActivityData.Instance:GetActivityConfig(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_BIG_GIFT)
	local level = 130
	if cfg and cfg.min_level then
		level = cfg.min_level
	end

	if 1 == protocol.is_already_buy then
		local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_BIG_GIFT)
		if act_info then
			ActivityData.Instance:SetActivityStatus(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_BIG_GIFT,ACTIVITY_STATUS.CLOSE,
				act_info.next_time,act_info.start_time,act_info.end_time,act_info.open_type)
		end
	elseif protocol.time_limit_luxury_gift_open_flag > 0 and PlayerData.Instance:GetRoleLevel() >= level and not JUST_BACK_FROM_CROSS_SERVER and self.first_tankuang == true then
		self.first_tankuang = false
		ViewManager.Instance:Open(ViewName.TimeLimitBigGiftView)
	end
	RemindManager.Instance:Fire(RemindName.LimitBigGift)
	ViewManager.Instance:FlushView(ViewName.ActivityHall)
end

function TimeLimitBigGiftCtrl:SendBuyOrInfo(seq)
	local send_type = seq and RA_TIMELIMIT_LUXURY_GIFT_BAG_OPERA_TYPE.RA_TIMELIMIT_LUXURY_GIFT_BAG_OPERA_TYPE_BUY or RA_TIMELIMIT_LUXURY_GIFT_BAG_OPERA_TYPE.RA_TIMELIMIT_LUXURY_GIFT_BAG_OPERA_TYPE_QUERY_INFO
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_BIG_GIFT,
				send_type, seq)
end

function TimeLimitBigGiftCtrl:ActivityChange(activity_type, status, next_time, open_type)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_BIG_GIFT then
		-- 活动开启之后才请求
		if status == ACTIVITY_STATUS.OPEN then
			self:SendBuyOrInfo()
		elseif status == ACTIVITY_STATUS.CLOSE then
			ViewManager.Instance:FlushView(ViewName.ActivityHall)
		end
	end
end






