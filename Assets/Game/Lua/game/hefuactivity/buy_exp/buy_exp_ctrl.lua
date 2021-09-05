require("game/serveractivity/buy_exp/buy_exp_data")
require("game/serveractivity/buy_exp/buy_exp_view")

BuyExpCtrl = BuyExpCtrl or BaseClass(BaseController)

function BuyExpCtrl:__init()
	if BuyExpCtrl.Instance then
	print_error("[BuyExpCtrl]:Attempt to create singleton twice!")
	end
	BuyExpCtrl.Instance = self

	self.view = BuyExpView.New(ViewName.BuyExp)
	self.data = BuyExpData.New()

	self:RegisterAllProtocols()

	-- self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpenCreate, self))
end

function BuyExpCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	BuyExpCtrl.Instance = nil
end

function BuyExpCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCCSAExpRefineInfo, "OnSCCSAExpRefineInfo")

end

-- function BuyExpCtrl:MainuiOpenCreate()
-- 	self:SendRAExpRefineReq(CSA_EXP_REFINE_OPERA_TYPE.CSA_EXP_REFINE_OPERA_TYPE_GET_INFO)
-- end


function BuyExpCtrl:OnSCCSAExpRefineInfo(protocol)
	self.data:SetRAExpRefineInfo(protocol)
	if protocol.had_buy == 1 then
		self.view:Close()
	end
	self.view:Flush()
	MainUICtrl.Instance:FlushView("flush_buy_exp")

end
