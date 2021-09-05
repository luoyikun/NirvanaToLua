require("game/map/map_view")
require("game/map/map_data")

MapCtrl = MapCtrl or BaseClass(BaseController)

function MapCtrl:__init()
	if MapCtrl.Instance ~= nil then
		print_error("[MapCtrl] attempt to create singleton twice!")
		return
	end
	MapCtrl.Instance = self

	self:RegisterAllProtocols()

	self.view = MapView.New(ViewName.Map)
	self.data = MapData.New()
end

function MapCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCYouyouBossInfo, "OnSCYouyouBossInfo")
	self:RegisterProtocol(SCYouyouSceneInfo,"OnSCYouyouSceneInfo")
end

function MapCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	MapCtrl.Instance = nil
end

function MapCtrl:OnSCYouyouBossInfo(protocol)
	self.data:SetYunYouBossInfo(protocol)
	self.view:OnFlushYunYouBoss()
end

function MapCtrl:OnSCYouyouSceneInfo(protocol)
	self.data:SetAllYunYouBossNum(protocol)
	self.view:OnFlushYunYouBossNum()
end

function MapCtrl:SendRandYunyouBossInfo(operate_type,param)
	local protocol = ProtocolPool.Instance:GetProtocol(CSYunyouBossInfo)
	protocol.operate_type = operate_type or 0
	protocol.param = param or 0
	protocol:EncodeAndSend()
end