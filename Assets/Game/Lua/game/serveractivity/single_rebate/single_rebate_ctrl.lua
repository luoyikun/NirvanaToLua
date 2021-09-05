require("game/serveractivity/single_rebate/single_rebate_data")
require("game/serveractivity/single_rebate/single_rebate_view")

SingleRebateCtrl = SingleRebateCtrl or BaseClass(BaseController)

function SingleRebateCtrl:__init()
	if SingleRebateCtrl.Instance ~= nil then
		print("[SingleRebateCtrl]error:create a singleton twice")
	end

	SingleRebateCtrl.Instance = self
	self.view = SingleRebateView.New(ViewName.SingleRebateView)
	self.data = SingleRebateData.New()
	self.is_open_mainui = false
	self.activity_change_callback = BindTool.Bind(self.ActivityChangeCallback, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_change_callback)

	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
	self.is_first = true
	self:RegisterAllProtocols()
end

function SingleRebateCtrl:__delete()
	if nil ~= self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	if nil ~= self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	SingleRebateCtrl.Instance = nil
	if self.activity_change_callback then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_change_callback)
		self.activity_change_callback = nil
	end
end

function SingleRebateCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCLoveDaily2Info, "OnSCLoveDaily2Info")
end

function SingleRebateCtrl:OnSCLoveDaily2Info(protocol)
	self.data:SetSingleRebateChargeFlag(protocol)
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_REBATE)
	local is_reach_level = ActivityData.Instance:GetIsOpenLevel(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_REBATE)
	if is_open and is_reach_level then
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.SingleRebate, protocol.flag <= 0)
		if protocol.flag <= 0 then
			ViewManager.Instance:Open(ViewName.SingleRebateView)
		else
			ViewManager.Instance:Close(ViewName.SingleRebateView)
		end
	end
end

function SingleRebateCtrl:Open()
	self.view:Open()
end

function SingleRebateCtrl:Close()
	self.view:Close()	
end

function SingleRebateCtrl:ActivityChangeCallback(activity_type, status, next_time, open_type)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_REBATE then
		if status == ACTIVITY_STATUS.CLOSE then
			MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.SingleRebate, false)
		else
			local flag = SingleRebateData.Instance:GetSingleRebateChargeFlag()
			MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.SingleRebate, flag <= 0)
			if self.is_open_mainui then
				if flag <= 0 then
					ViewManager.Instance:Open(ViewName.SingleRebateView)
				else
					ViewManager.Instance:Close(ViewName.SingleRebateView)
				end
			end
		end
	end
end

function SingleRebateCtrl:MainuiOpenCreate()
	self.is_open_mainui = true
end
