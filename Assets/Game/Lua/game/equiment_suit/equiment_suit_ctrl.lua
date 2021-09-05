require ("game/equiment_suit/equiment_suit_data")
require ("game/equiment_suit/equiment_suit_view")

EquimentSuitCtrl = EquimentSuitCtrl or BaseClass(BaseController)

function EquimentSuitCtrl:__init()
	if 	EquimentSuitCtrl.Instance ~= nil then
		print("[EquimentSuitCtrl] attempt to create singleton twice!")
		return
	end
	self:RegisterAllProtocols()
	EquimentSuitCtrl.Instance = self
	self.data = EquimentSuitData.New()
	self.view = EquimentSuitView.New(ViewName.EquimentSuitView)
end

function EquimentSuitCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCEquipUplevelSuitInfo,"OnSCEquipUplevelSuitInfo")

end

function EquimentSuitCtrl:OnSCEquipUplevelSuitInfo(protocol)
	self.data:SetEquimentSuitLevel(protocol)
	self:FlusView()
	RemindManager.Instance:Fire(RemindName.EquimentSuit)
	RemindManager.Instance:Fire(RemindName.ForgeAdvance)
end

function EquimentSuitCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	EquimentSuitCtrl.Instance = nil
end

function EquimentSuitCtrl:FlusView()
	if self.view then
		self.view:Flush()
	end
end

function EquimentSuitCtrl:SendGetSuitActiveInfo(active_suit_level)
	local protocol = ProtocolPool.Instance:GetProtocol(CSEquipUplevelSuitActive)
	protocol.active_suit_level = active_suit_level
	protocol:EncodeAndSend()
end

