require("game/AdvancedReturn/advanced_return_data")
require("game/AdvancedReturn/advanced_return_view")
AdvancedReturnCtrl = AdvancedReturnCtrl or BaseClass(BaseController)
function AdvancedReturnCtrl:__init()
	if AdvancedReturnCtrl.Instance ~= nil then
		print_error("[AdvancedReturnCtrl] attempt to create singleton twice!")
		return
	end

	AdvancedReturnCtrl.Instance = self

	self.view = AdvancedReturnView.New(ViewName.AdvancedReturn)
	self.data = AdvancedReturnData.New()
	self:RegisterAllProtocols()
	
	
	-- self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	-- RemindManager.Instance:Bind(self.remind_change, RemindName.BPCapabilityRemind)
	self:BindGlobalEvent(OtherEventType.PASS_DAY, BindTool.Bind1(self.OnDayChangeCallBackOne, self))
end

function AdvancedReturnCtrl:__delete()
	AdvancedReturnCtrl.Instance = nil
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	
end

function AdvancedReturnCtrl:OnDayChangeCallBackOne()
	if self.view:IsOpen() then
		self.view:Flush()
		self.view:FlushTextInfo()
	end
end

function AdvancedReturnCtrl:FlushView()
	if self.view then
		self.view:Flush()
	end
end

function AdvancedReturnCtrl:ViewIsOpen()
	if self.view then
		return self.view:IsOpen()
	end
	return false
end

function AdvancedReturnCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAJinJieReturnInfo, "OnSCRAJinJieReturnInfo")
	self:RegisterProtocol(SCUpgradeCardBuyInfo, "OnSCUpgradeCardBuyInfo")
end


function AdvancedReturnCtrl:OnSCRAJinJieReturnInfo(protocol)
	self.data:SetUpGradeReturnInfo(protocol)
	self.view:Flush()
	self.data:GetJiangLiCfg()
	RemindManager.Instance:Fire(RemindName.FanHuan)
end

function AdvancedReturnCtrl:OnSCUpgradeCardBuyInfo(protocol)
	self.data:SetUpgradeCardBuyInfo(protocol)
	self.data:GetJiangLiCfg()	
	AdvancedReturnTwoData.Instance:SetUpgradeCardBuyInfo(protocol)
	AdvancedReturnTwoData.Instance:GetJiangLiCfg()
	self.view:Flush()
	AdvancedReturnTwoCtrl.Instance:OnFlushAdvancedReturnTwo()
	RemindManager.Instance:Fire(RemindName.FanHuan)

	-- self.data:GetUpGradeJiangLiCfg()
end

function AdvancedReturnCtrl:SendRandShopBuyReq(activity_id,item_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSUpgradeCardBuyReq)
	protocol.activity_id = activity_id or 0
	protocol.item_id = item_id or 0
	protocol:EncodeAndSend()
end

