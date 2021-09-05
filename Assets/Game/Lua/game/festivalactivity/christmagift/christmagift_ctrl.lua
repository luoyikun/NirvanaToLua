require("game/festivalactivity/christmagift/christmagift_data")
require("game/festivalactivity/christmagift/christma_fb_info")
require("game/festivalactivity/christmagift/gift_fb_skill_view")

ChristmaGiftCtrl = ChristmaGiftCtrl or BaseClass(BaseController)
function ChristmaGiftCtrl:__init()
	if nil ~= ChristmaGiftCtrl.Instance then
		return
	end
	ChristmaGiftCtrl.Instance =  self
	self.data = ChristmaGiftData.New()
	self.fuben_view = GiftFuBenInfoView.New(ViewName.ChristmaGiftFuBenView)
	self:RegisterAllProtocols()
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.RequestLiWuShouGeInfo, self))
end

function ChristmaGiftCtrl:__delete()
	ChristmaGiftCtrl.Instance = nil
	if self.data then
		self.data:DeleteMe()
	end

	if self.fuben_view then
		self.fuben_view:DeleteMe()
	end
end

function ChristmaGiftCtrl:SendGetInfoReq(type_typeact)
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSRAGiftHarvestReq)
	protocol_send.opera_type = type_typeact or 0
	protocol_send.param_0 = 0
	protocol_send:EncodeAndSend()
end

function ChristmaGiftCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAGiftHarvestPlayerInfo, "SCRAGiftHarvestPlayerInfo")
	self:RegisterProtocol(SCRAGiftHarvestRankInfo, "SCRAGiftHarvestRankInfo")
	self:RegisterProtocol(SCGiftHarvestSkill, "SCGiftHarvestSkill")
	self:RegisterProtocol(SCGiftHarvestRoundNotice, "SCGiftHarvestRoundNotice")
end

function ChristmaGiftCtrl:SCGiftHarvestRoundNotice(protocol)
	self.data:SetActiviTime(protocol.round_state, protocol.next_state_timestamp, protocol.round)
	if ViewManager.Instance:IsOpen(ViewName.ChristmaGiftFuBenView) then
		ViewManager.Instance:FlushView(ViewName.ChristmaGiftFuBenView) 
	end

	ViewManager.Instance:FlushView(ViewName.Main, "icon_group_3")
end

function ChristmaGiftCtrl:SCRAGiftHarvestPlayerInfo(protocol)
	self.data:SetMeData(protocol)
	if ViewManager.Instance:IsOpen(ViewName.FestivalView) then
		ViewManager.Instance:FlushView(ViewName.FestivalView) 
	end

	FestivalActivityCtrl.Instance:FlushCrazyHiCelebrationView()
	if ViewManager.Instance:IsOpen(ViewName.ChristmaGiftFuBenView) then
		ViewManager.Instance:FlushView(ViewName.ChristmaGiftFuBenView) 
	end
end

function ChristmaGiftCtrl:SCRAGiftHarvestRankInfo(protocol)
	self.data:SetRankData(protocol)
	FestivalActivityCtrl.Instance:FlushCrazyHiCelebrationView()
	if ViewManager.Instance:IsOpen(ViewName.FestivalView) then
		ViewManager.Instance:FlushView(ViewName.FestivalView)
	end
end
function ChristmaGiftCtrl:SCGiftHarvestSkill(protocol)
	self.data:SetSkillData(protocol)
	if self.fuben_view and self.fuben_view:IsOpen() then
		self.fuben_view:Flush()
	end
end

function ChristmaGiftCtrl:SendEnterSceneOrEeqData(type_act, req_type)
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSRandActivityOperaReq)
	protocol_send.rand_activity_type = type_act or 0
	protocol_send.opera_type = req_type or 0
	protocol_send:EncodeAndSend()
end

-- 请求礼物信息
function ChristmaGiftCtrl:RequestLiWuShouGeInfo()
	CrazyHiCelebrationCtrl.Instance:SendActivityInfoReq()
	self:SendEnterSceneOrEeqData(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LIWUSHOUGE, RA_GIFT_HARVEST_OPERA_TYPE.RA_GIFT_HARVEST_OPERA_TYPE_INFO)
	self:SendEnterSceneOrEeqData(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LIWUSHOUGE, RA_GIFT_HARVEST_OPERA_TYPE.RA_GIFT_HARVEST_OPERA_TYPE_RANK_INFO)
	self:SendEnterSceneOrEeqData(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LIWUSHOUGE, RA_GIFT_HARVEST_OPERA_TYPE.RA_GIFT_HARVEST_OPERA_TYPE_ACT_TIME)
end