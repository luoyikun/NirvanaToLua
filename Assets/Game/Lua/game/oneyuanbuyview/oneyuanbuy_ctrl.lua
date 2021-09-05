-- 仙尊卡 author Lm
require("game/oneyuanbuyview/oneyuanbuy_view")
require("game/oneyuanbuyview/oneyuanbuy_data")

OneYuanBuyCtrl = OneYuanBuyCtrl or BaseClass(BaseController)
function OneYuanBuyCtrl:__init()
	if OneYuanBuyCtrl.Instance then
		print_error("[OneYuanBuyCtrl] attempt to create singleton twice!")
		return
	end
	OneYuanBuyCtrl.Instance = self

	self.data = OneYuanBuyData.New()
	self.view = OneYuanBuyView.New(ViewName.OneYuanBuyView)

	self:RegisterAllProtocols()

	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

function OneYuanBuyCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	OneYuanBuyCtrl.Instance = nil
end

function OneYuanBuyCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAZeroBuyReturnInfo, "OnSCRAZeroBuyReturnInfo")
end

function OneYuanBuyCtrl:OnSCRAZeroBuyReturnInfo(protocol)
	self.data:SetZeroBuyReturnInfo(protocol)

	if self.view then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.OneYuanBuy)
	GlobalEventSystem:Fire(MainUIEventType.CHANGE_MAINUI_BUTTON, "oneyuan_buy")
end

function OneYuanBuyCtrl:MainuiOpenCreate()
	-- if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ONEYUANBUYVIEW) then
		KaifuActivityCtrl:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ONEYUANBUYVIEW, RA_ZERO_BUY_RETURN_OPERA_TYPE.RA_ZERO_BUY_RETURN_OPERA_TYPE_INFO)
		RemindManager.Instance:Fire(RemindName.OneYuanBuy)
	-- end
end