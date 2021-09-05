require("game/single_recharge/single_recharge_view")
require("game/single_recharge/single_recharge_data")

SingleRechargeCtrl = SingleRechargeCtrl or BaseClass(BaseController)
function SingleRechargeCtrl:__init()
	if SingleRechargeCtrl.Instance then
		print_error("[SingleRechargeCtrl] Attemp to create a singleton twice !")
	end
	SingleRechargeCtrl.Instance = self

	self.single_recharge_data = SingleRechargeData.New()
	self.singlerecharge_view = SingleRechargeView.New(ViewName.SingleRechargeView)
	self:RegisterAllProtocols()
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpenCreate, self))
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.DanFanHaoLi)

	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
end

function SingleRechargeCtrl:__delete()
	SingleRechargeCtrl.Instance = nil

	if self.singlerecharge_view then
		self.singlerecharge_view:DeleteMe()
		self.singlerecharge_view = nil
	end

	if self.single_recharge_data then
		self.single_recharge_data:DeleteMe()
		self.single_recharge_data = nil
	end

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	if self.main_view_complete then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end

	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end	
end

function SingleRechargeCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRASingleChongZhiInfo, "OnSCRASingleChongZhiInfo")
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

-- 主界面创建
function SingleRechargeCtrl:MainuiOpenCreate()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHONGZHI)
	local is_all_lingqu = SingleRechargeData.Instance:IsHaveAllChongzhiAndLingQu()
	if is_open then
		KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHONGZHI, RA_SINGLE_CHONGZHI_OPERA_TYPE.RA_SINGLE_CHONGZHI_OPERA_TYPE_INFO)
	end
	MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.SINGLE_CHONGZHI, is_open and not is_all_lingqu)
end

function SingleRechargeCtrl:OnSCRASingleChongZhiInfo(protocol)
	local is_first = SingleRechargeData.Instance:IsFirstSendPro()
	self.single_recharge_data:SetRewardFlag(protocol)
	self.singlerecharge_view:Flush()
	RemindManager.Instance:Fire(RemindName.DanFanHaoLi)
	if is_first then
		local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHONGZHI)
		local is_all_lingqu = SingleRechargeData.Instance:IsHaveAllChongzhiAndLingQu()
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.SINGLE_CHONGZHI, is_open and not is_all_lingqu)
	end
end

function SingleRechargeCtrl:RemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.DanFanHaoLi then
		self.single_recharge_data:FlushHallRedPoindRemind()
	end
end

function SingleRechargeCtrl:ActivityCallBack(activity_type, status)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHONGZHI then
		if status == ACTIVITY_STATUS.OPEN then
			MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.SINGLE_CHONGZHI, true)
		elseif status == ACTIVITY_STATUS.CLOSE then
			MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.SINGLE_CHONGZHI, false)
		end 
	end
end