require("game/reset_double_chongzhi/reset_double_chongzhi_data")
require("game/reset_double_chongzhi/reset_double_chongzhi_view")

ResetDoubleChongzhiCtrl = ResetDoubleChongzhiCtrl or BaseClass(BaseController)

function ResetDoubleChongzhiCtrl:__init()
	if ResetDoubleChongzhiCtrl.Instance then
		print_error("[PuTianTongQingCtrl] Attemp to create a singleton twice !")
	end
	ResetDoubleChongzhiCtrl.Instance = self

	self.data = ResetDoubleChongzhiData.New()
	self.view = ResetDoubleChongzhiView.New(ViewName.ResetDoubleChongzhiView)

	self:RegisterAllProtocols()

	self.activity_call_back = BindTool.Bind(self.ActivityChange, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
end

function ResetDoubleChongzhiCtrl:__delete()
	ResetDoubleChongzhiCtrl.Instance = nil

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end
end

function ResetDoubleChongzhiCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAResetDoubleChongzhi, "OnSCRAResetDoubleChongzhi")
end

function ResetDoubleChongzhiCtrl:OnSCRAResetDoubleChongzhi(protocol)
	self.data:SetChongzhiInfo(protocol)

	if protocol.open_flag == 1 then
		if self.data:IsShowPuTianTongQing() then
			self.data:SetNum(1)
			RemindManager.Instance:Fire(RemindName.ResetDoubleChongzhi)
			-- 双倍图标
			MainUICtrl.Instance:FlushView("show_double_icon", {true})
		end
	end

	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_REST_DOUBLE_CHONGZHI) then
		if self.data:IsAllRecharge() then
			local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_REST_DOUBLE_CHONGZHI)
			if act_info then
				ActivityData.Instance:SetActivityStatus(ACTIVITY_TYPE.RAND_ACTIVITY_REST_DOUBLE_CHONGZHI,ACTIVITY_STATUS.CLOSE,
					act_info.next_time,act_info.start_time,act_info.end_time,act_info.open_type)
			end
			self.data:SetNum(0)
			RemindManager.Instance:Fire(RemindName.ResetDoubleChongzhi)
			-- 双倍关闭
			MainUICtrl.Instance:FlushView("show_double_icon", {false})
			MainUICtrl.Instance:FlushView("icon_group_player")
		end
	end
	if ViewManager.Instance:IsOpen(ViewName.VipView) then
		ViewManager.Instance:FlushView(ViewName.VipView)
	end
end

function ResetDoubleChongzhiCtrl:ActivityChange(act_type)
	if act_type ~= ACTIVITY_TYPE.RAND_ACTIVITY_REST_DOUBLE_CHONGZHI then return end

	local open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_REST_DOUBLE_CHONGZHI)
	if open then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_REST_DOUBLE_CHONGZHI, RA_REST_DOUBLE_CHATGE_OPERA_TYPE.RA_RESET_DOUBLE_CHONGZHI_OPERA_TYPE_INFO)
	else
		self.data:SetNum(0)
		RemindManager.Instance:Fire(RemindName.ResetDoubleChongzhi)
		-- 双倍关闭
		MainUICtrl.Instance:FlushView("show_double_icon", {false})
	end
	if ViewManager.Instance:IsOpen(ViewName.VipView) then
		ViewManager.Instance:FlushView(ViewName.VipView)
	end
	MainUICtrl.Instance:FlushView("icon_group_player")
end
