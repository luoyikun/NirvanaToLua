require("game/timelimitgift/time_limit_gift_view")
require("game/timelimitgift/time_limit_gift_data")

TimeLimitGiftCtrl = TimeLimitGiftCtrl or BaseClass(BaseController)
function TimeLimitGiftCtrl:__init()
	if TimeLimitGiftCtrl.Instance then
		print_error("[TimeLimitGiftCtrl] Attemp to create a singleton twice !")
	end
	TimeLimitGiftCtrl.Instance = self

	self.three_piece_data = TimeLimitGiftData.New()
	self.three_piece_view = TimeLimitGiftView.New(ViewName.TimeLimitGiftView)

	self.activity_call_back = BindTool.Bind(self.ActivityChange, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
	--登陆时候在主界面创建
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))

	self:RegisterAllProtocols()
	self.first_tankuang = true
end

function TimeLimitGiftCtrl:__delete()
	TimeLimitGiftCtrl.Instance = nil
	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end

	if self.three_piece_view then
		self.three_piece_view:DeleteMe()
		self.three_piece_view = nil
	end

	if self.three_piece_data then
		self.three_piece_data:DeleteMe()
		self.three_piece_data = nil
	end
	self.first_tankuang = true
end

function TimeLimitGiftCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRATimeLimitGiftInfo , "OnSCRATimeLimitGiftInfo")
end

function TimeLimitGiftCtrl:OnSCRATimeLimitGiftInfo(protocol)
	self.three_piece_data:SetTimeLimitGiftInfo(protocol)

	if protocol.open_flag > 0 and self.three_piece_view and self.three_piece_view:IsOpen() then
		self.three_piece_view:Flush()
	end
	
	local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_GIFT)
	if nil == act_info then
		return
	end

	local status = protocol.open_flag > 0 and ACTIVITY_STATUS.OPEN or ACTIVITY_STATUS.CLOSE
	if not(protocol.open_flag == 1 and act_info.status == ACTIVITY_STATUS.OPEN) then
		ActivityData.Instance:SetActivityStatus(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_GIFT, status,
			act_info.next_time, act_info.start_time, act_info.end_time, act_info.open_type)
	end

	local cfg = self.three_piece_data:GetLimitGiftCfg()
	local limit_time = cfg.limit_time or 0
	local cur_time = TimeCtrl.Instance:GetServerTime() or 0
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_GIFT) then
		if cur_time > protocol.begin_timestamp + limit_time then
			act_info.status = ACTIVITY_STATUS.CLOSE
		end
	end

	ViewManager.Instance:FlushView(ViewName.ActivityHall)
	--界面打开的情况下 活动关闭 关闭面板
	if protocol.open_flag == 0 and self.three_piece_view and self.three_piece_view:IsOpen() then
		self.three_piece_view:CloseView()
	end 
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local player_level = main_role_vo and main_role_vo.level or 0

	local cfg = ActivityData.Instance:GetActivityConfig(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_GIFT)
	local level = 130
	if cfg and cfg.min_level then
		level = cfg.min_level
	end
	if nil == player_level or player_level < level then
		return
	end

	if protocol.open_flag > 0 and not JUST_BACK_FROM_CROSS_SERVER and self.first_tankuang == true then
		self.first_tankuang = false
		ViewManager.Instance:Open(ViewName.TimeLimitGiftView)
	end
end

function TimeLimitGiftCtrl:ActivityChange(activity_type, status, next_time, open_type)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_GIFT then
		-- 活动开启之后才请求
		if status == ACTIVITY_STATUS.OPEN then
			KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_GIFT,
				RA_TIMELIMIT_GIFT_OPERA_TYPE.RA_TIMELIMIT_GIFT_OPERA_TYPE_QUERY_INFO, 0, 0)
		end
	end
end

-- 主界面创建
function TimeLimitGiftCtrl:MainuiOpenCreate()
	local is_act_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_GIFT)
	if not is_act_open then
		return
	end

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local player_level = main_role_vo and main_role_vo.level or 0

	if nil == player_level or player_level < 130 then
		return
	end
end