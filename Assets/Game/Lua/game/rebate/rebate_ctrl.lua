require("game/rebate/rebate_data")
require("game/rebate/rebate_view")
RebateCtrl = RebateCtrl or BaseClass(BaseController)
function RebateCtrl:__init()
	if RebateCtrl.Instance then
		print_error("[RebateCtrl] Attemp to create a singleton twice !")
	end
	RebateCtrl.Instance = self
	self.data = RebateData.New()
	self.view = RebateView.New(ViewName.RebateView)
	self:RegisterProtocol(SCBaiBeiFanLiInfo, "OnSCBaiBeiFanLiInfo")

	self.is_buy = true
	self.close_time = 0
end

function RebateCtrl:__delete()
	self.view:DeleteMe()
	self.data:DeleteMe()
	RebateCtrl.Instance = nil
end

function RebateCtrl:OnSCBaiBeiFanLiInfo(protocol)
	self:SetBuyMark(protocol.is_buy)
	self:SetCloseTime(protocol.close_time)
	if self.view and self.view:IsOpen() then
		self.view:Flush()
	end
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_REBATE_BUTTON, self.is_buy)
	RemindManager.Instance:Fire(RemindName.Rebate)	
end

function RebateCtrl:SetBuyMark(is_buy)
	if is_buy ~= nil and is_buy == 0 then
		self.is_buy = true
	else
		self.is_buy = false
		if self.view:IsOpen() then
			self.view:Close()
		end
	end
end

function RebateCtrl:SetCloseTime(close_time)
	self.close_time = close_time
end

function RebateCtrl:GetBuyState()
	return self.is_buy
end

function RebateCtrl:GetCloseTime()
	return self.close_time
end

--百倍返利
function RebateCtrl:SendBaiBeiFanLiBuy()
	local protocol = ProtocolPool.Instance:GetProtocol(CSBaiBeiFanLiBuy)
	protocol:EncodeAndSend()
end