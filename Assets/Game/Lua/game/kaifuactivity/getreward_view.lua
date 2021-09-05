GetRewardView =  GetRewardView or BaseClass(BaseRender)
--消费返利 GetReward
function GetRewardView:__init()
	self.time_quest = nil
	self.node_list["HelpBtn"].button:AddClickListener(BindTool.Bind(self.HelpClick, self))
end

function GetRewardView:__delete()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function GetRewardView:OpenCallBack()
	self:Flush()

end

function GetRewardView:LoadCallBack()
	self.node_list["BtnGoToXiaoFei"].button:AddClickListener(BindTool.Bind(self.ClickReChange, self))
end

function GetRewardView:ClickReChange()
	ViewManager.Instance:Open(ViewName.Shop, TabIndex.shop_youhui)
end

function GetRewardView:OnFlush()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
	end

	self.node_list["TxtCostMoney"].text.text = KaifuActivityData.Instance:GetRewardConsumeGold()
	self.node_list["TxtRebateScale"].text.text = KaifuActivityData.Instance:GetSpecialAppearanceRewardCfg().."%"
	self.node_list["TxtReturenMoney"].text.text = math.floor(KaifuActivityData.Instance:GetRewardConsumeGold()*KaifuActivityData.Instance:GetSpecialAppearanceRewardCfg()/100)
	self.node_list["TxtExplain"].text.text = Language.Activity.Rewardfanli
end

function GetRewardView:OpenRecharge()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function GetRewardView:HelpClick()
	TipsCtrl.Instance:ShowHelpTipView(286)
end

function GetRewardView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_CONSUME_GOLD_FANLI)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	local time_tab = TimeUtil.Format2TableDHMS(time)

	local time_str = nil
	if time_tab.day >= 1 then
		time_str = string.format(Language.Activity.ActivityTime8, time_tab.day, time_tab.hour)
	else
		time_str = string.format(Language.Activity.ActivityTime9, time_tab.hour, time_tab.min, time_tab.s)
	end
	self.node_list["TxtRestTime"].text.text = time_str

end