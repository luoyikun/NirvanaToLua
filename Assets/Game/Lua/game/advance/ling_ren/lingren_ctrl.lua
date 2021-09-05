require("game/advance/ling_ren/lingren_data")
LingRenCtrl = LingRenCtrl or BaseClass(BaseController)

function LingRenCtrl:__init()
	if LingRenCtrl.Instance then
		print_error("[LingRenCtrl] Attemp to create a singleton twice !")
	end
	LingRenCtrl.Instance = self
	self.data = LingRenData.New()
	self:RegisterAllProtocols()
end

function LingRenCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil
	LingRenCtrl.Instance = nil
end

function LingRenCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCAllShenBingInfo, "OnSCAllShenBingInfo")
end
function LingRenCtrl:OnSCAllShenBingInfo(protocol)
	local play_effect = self.data:CheckPlayEffect(protocol.level)
	self.data:SetShenBingInfo(protocol)
	ViewManager.Instance:FlushView(ViewName.Advance, "upgraderesult", {flag = play_effect})
	--[[local player_view = PlayerCtrl.Instance:GetView()
	if player_view:IsOpen() then
		player_view:Flush("shen_bing")
		if play_effect == true then player_view:GetShenBingView():PlayUpStarEffect() end
	end--]]
	AdvanceCtrl.Instance:FlushZiZhiTips()
	if ViewManager.Instance:IsOpen(ViewName.TipChengZhang) then
		AdvanceCtrl.Instance:FlushChengZhangTips()
	end
end

function LingRenCtrl:OnUpgradeResult(result)
	ViewManager.Instance:FlushView(ViewName.Advance, "upgraderesult", {result == 1 and true or false})
end

function LingRenCtrl.SentShenBingUpLevel(stuff_index)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSShenBingUpLevel)
	send_protocol.stuff_index = stuff_index
	send_protocol.resevre = 0
	send_protocol:EncodeAndSend()
end

function LingRenCtrl.SentShenBingUseImage(use_image)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSShenBingUseImage)
	send_protocol.use_image = use_image
	send_protocol.resevre = 0
	send_protocol:EncodeAndSend()
end
