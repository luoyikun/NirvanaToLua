require("game/serveractivity/activite_hongbao/activite_hongbao_data")
-- require("game/serveractivity/activite_hongbao/activite_hongbao_view")

ActiviteHongBaoCtrl = ActiviteHongBaoCtrl or BaseClass(BaseController)

function ActiviteHongBaoCtrl:__init()
	if ActiviteHongBaoCtrl.Instance then
		print_error("[ActiviteHongBaoCtrl]:Attempt to create singleton twice!")
	end
	ActiviteHongBaoCtrl.Instance = self

	self.data = ActiviteHongBaoData.New()

	self:RegisterAllProtocols()
end

function ActiviteHongBaoCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	ActiviteHongBaoCtrl.Instance = nil
end

function ActiviteHongBaoCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRARedEnvelopeGiftInfo, "OnRARedEnvelopeGiftInfo")
end

function ActiviteHongBaoCtrl:OnRARedEnvelopeGiftInfo(protocol)
	self.data:SetRARedEnvelopeGiftInfo(protocol)

	KaifuActivityCtrl.Instance:GetView():Flush()
end
