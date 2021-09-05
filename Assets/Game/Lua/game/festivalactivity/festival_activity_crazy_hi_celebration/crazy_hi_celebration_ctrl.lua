require("game/festivalactivity/festival_activity_crazy_hi_celebration/crazy_hi_celebration_data")

CrazyHiCelebrationCtrl = CrazyHiCelebrationCtrl or BaseClass(BaseController)
function CrazyHiCelebrationCtrl:__init()
	if nil ~= CrazyHiCelebrationCtrl.Instance then
		return
	end
	CrazyHiCelebrationCtrl.Instance = self
	self.data = CrazyHiCelebrationData.New()
	self:RegisterAllProtocols()
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.SendActivityInfoReq, self))
end

function CrazyHiCelebrationCtrl:__delete()
	CrazyHiCelebrationCtrl.Instance = nil
end

function CrazyHiCelebrationCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAKuangHaiInfo,"OnRAKuangHaiInfo")
end

function CrazyHiCelebrationCtrl:OnRAKuangHaiInfo(protocol)
	self.data:SetCrazyCelebrationInfo(protocol)
	FestivalActivityCtrl.Instance:FlushCrazyHiCelebrationView()
end

function CrazyHiCelebrationCtrl:SendActivityInfoReq()
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_KUANG_HAI_QING_DIAN) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_KUANG_HAI_QING_DIAN, RA_KUANG_HAI_OPERA_TYPE.RA_KUANG_HAI_OPERA_TYPE_INFO)
	end
end