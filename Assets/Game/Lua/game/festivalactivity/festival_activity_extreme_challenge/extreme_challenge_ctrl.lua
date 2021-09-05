require("game/festivalactivity/festival_activity_extreme_challenge/extreme_challenge_view")
require("game/festivalactivity/festival_activity_extreme_challenge/extreme_challenge_data")
ExtremeChallengeCtrl = ExtremeChallengeCtrl or BaseClass(BaseController)
function ExtremeChallengeCtrl:__init()
	if nil ~= ExtremeChallengeCtrl.Instance then
		return
	end
	ExtremeChallengeCtrl.Instance = self
	-- self.daily_gift_view = DailyGiftView.New(ViewName.DailyGiftView)
	self.data = ExtremeChallengeData.New()
	self:RegisterAllProtocols()
	--self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.SendExtremeChallengeInfo, self))
end

function ExtremeChallengeCtrl:__delete()
	ExtremeChallengeCtrl.Instance = nil

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
end

function ExtremeChallengeCtrl:RegisterAllProtocols()
	--每日好礼
	self:RegisterProtocol(SCRAExtremeChallengeTaskInfo,"OnRAExremeChallengeTaskInfo")
end

function ExtremeChallengeCtrl:SendExtremeChallengeInfo()
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXTREME_CHALLENGE) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXTREME_CHALLENGE, EXTREMECHALLENGE.EXTREMECHALLENGE_INFO)
	    KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXTREME_CHALLENGE, EXTREMECHALLENGE.EXTREMECHALLENGE_INIT_TASK)
	end
end

function ExtremeChallengeCtrl:OnRAExremeChallengeTaskInfo(protocol)
	self.data:SetExtremeChallengeInfo(protocol)
	FestivalActivityCtrl.Instance:FlushExtremeChallenge()
	--RemindManager.Instance:Fire(RemindName.ExtremeChallengeRemind)
end
