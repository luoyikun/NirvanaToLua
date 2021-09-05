require("game/AdvancedReturnTwo/advanced_returntwo_data")
require("game/AdvancedReturnTwo/advanced_returntwo_view")
AdvancedReturnTwoCtrl = AdvancedReturnTwoCtrl or BaseClass(BaseController)
function AdvancedReturnTwoCtrl:__init()
	if AdvancedReturnTwoCtrl.Instance ~= nil then
		print_error("[AdvancedReturnTwoCtrl] attempt to create singleton twice!")
		return
	end

	AdvancedReturnTwoCtrl.Instance = self

	self.view = AdvancedReturnTwoView.New(ViewName.AdvancedReturnTwo)
	self.data = AdvancedReturnTwoData.New()
	self:RegisterAllProtocols()
	
	
	-- self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	-- RemindManager.Instance:Bind(self.remind_change, RemindName.BPCapabilityRemind)
	self:BindGlobalEvent(OtherEventType.PASS_DAY, BindTool.Bind1(self.OnDayChangeCallBackTwo, self))
end

function AdvancedReturnTwoCtrl:__delete()
	AdvancedReturnTwoCtrl.Instance = nil
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	
end

function AdvancedReturnTwoCtrl:OnDayChangeCallBackTwo()
	if self.view:IsOpen() then
		self.view:Flush()
		self.view:FlushTextInfo()
	end
end

function AdvancedReturnTwoCtrl:FlushView()
	if self.view then
		self.view:Flush()
	end
end

function AdvancedReturnTwoCtrl:ViewIsOpen()
	if self.view then
		return self.view:IsOpen()
	end
	return false
end

function AdvancedReturnTwoCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAJinJieReturnInfo2, "OnSCRAJinJieReturnInfo2")
end


function AdvancedReturnTwoCtrl:OnSCRAJinJieReturnInfo2(protocol)
	self.data:SetUpGradeReturnInfo(protocol)
	self.view:Flush()
	 AdvancedReturnTwoData.Instance:GetJiangLiCfg()
	RemindManager.Instance:Fire(RemindName.FanHuanTwo)
end
function AdvancedReturnTwoCtrl:OnFlushAdvancedReturnTwo()
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.FanHuanTwo)
end



function AdvancedReturnTwoCtrl:SendRandShopBuyReq(activity_id,item_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSUpgradeCardBuyReq)
	protocol.activity_id = activity_id or 0
	protocol.item_id = item_id or 0
	protocol:EncodeAndSend()
end

