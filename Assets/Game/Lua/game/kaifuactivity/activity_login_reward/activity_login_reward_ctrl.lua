require("game/kaifuactivity/activity_login_reward/activity_login_reward_data")
ActivityPanelLoginRewardCtrl = ActivityPanelLoginRewardCtrl or BaseClass(BaseController)

function ActivityPanelLoginRewardCtrl:__init()
	if nil ~= ActivityPanelLoginRewardCtrl.Instance then
		return
	end

	ActivityPanelLoginRewardCtrl.Instance = self
	self.data = ActivityPanelLoginRewardData.New()
	self:RegisterAllProtocols()
end

function ActivityPanelLoginRewardCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
	end
	self.data = nil
	ActivityPanelLoginRewardCtrl.Instance = nil
end

function ActivityPanelLoginRewardCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRALoginGiftInfo, "OnSCRALoginGiftInfo_0")
	-- self:RegisterProtocol(SCRALoginGiftInfo_1, "OnSCRALoginGiftInfo_1")
	-- self:RegisterProtocol(SCRALoginGiftInfo_2, "OnSCRALoginGiftInfo_2")
end

function ActivityPanelLoginRewardCtrl:OnSCRALoginGiftInfo_0(protocol)
	-- print_error(">>>>>>>>>>>>>>>>>>", protocol)
	self.data:SetLoginRewardInfo_0(protocol)
	FestivalActivityCtrl.Instance:FlushLoginReward()
	-- ActivityOnLineCtrl.Instance:FlushView("login_reward")
	-- RemindManager.Instance:Fire(RemindName.RewardGift0)
end

-- function ActivityPanelLoginRewardCtrl:OnSCRALoginGiftInfo_1(protocol)
-- 	self.data:SetLoginRewardInfo_1(protocol)
-- 	ActivityOnLineCtrl.Instance:FlushView("login_reward")
-- 	RemindManager.Instance:Fire(RemindName.RewardGift1)
-- end

-- function ActivityPanelLoginRewardCtrl:OnSCRALoginGiftInfo_2(protocol)
-- 	self.data:SetLoginRewardInfo_2(protocol)
-- 	ActivityOnLineCtrl.Instance:FlushView("login_reward")
-- 	RemindManager.Instance:Fire(RemindName.RewardGift2)
-- end

