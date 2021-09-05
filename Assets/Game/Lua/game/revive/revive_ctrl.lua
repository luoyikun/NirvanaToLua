require("game/revive/revive_data")
require("game/revive/revive_view")

ReviveCtrl = ReviveCtrl or BaseClass(BaseController)

function ReviveCtrl:__init()
	if ReviveCtrl.Instance ~= nil then
		print_error("[ReviveCtrl] Attemp to create a singleton twice !")
		return
	end

	ReviveCtrl.Instance = self

	self.revive_data = ReviveData.New()
	self.revive_view = ReviveView.New(ViewName.ReviveView)

	self:RegisterProtocol(SCHuguozhiliInfo, "OnSCHuguozhiliInfo")
end

function ReviveCtrl:__delete()
	self.revive_view:DeleteMe()
	self.revive_view = nil

	self.revive_data:DeleteMe()
	self.revive_data = nil

	ReviveCtrl.Instance = nil
end

function ReviveCtrl:SendDieBuffInfo(operate_type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSHuguozhiliReq)
	send_protocol.opera_type = operate_type
	send_protocol:EncodeAndSend()
end

function ReviveCtrl:OnSCHuguozhiliInfo(protocol)
	self.revive_data:SetDieBuffInfo(protocol)

	if self.revive_view:IsOpen() then
		self.revive_view:Flush()
	end
end

function ReviveCtrl:OnReviveClose()
	if self.revive_view:IsOpen() then
		self.revive_view:Close()
	end
end