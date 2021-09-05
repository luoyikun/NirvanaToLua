DailyLoveView =  DailyLoveView or BaseClass(BaseRender)
--每日一爱
function DailyLoveView:__init()
	
end

function DailyLoveView:__delete()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function DailyLoveView:LoadCallBack()
	MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.DailyLove, false)

	self.node_list["BtnReCharge"].button:AddClickListener(BindTool.Bind(self.OpenRecharge, self))
	self:FlushNextTime()
	ClickOnceRemindList[RemindName.DailyLove] = 0
	RemindManager.Instance:CreateIntervalRemindTimer(RemindName.DailyLove)

end

function DailyLoveView:OnFlush()
	local rand_act_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	if rand_act_cfg then
		self.cfg = rand_act_cfg.daily_love_reward_percent
	end
	
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
	if self.cfg then
		local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
		for k,v in pairs(self.cfg) do
			if server_open_day >= v.opengame_day then
				self.gold_percent = v.gold_percent
			end
		end
	end
	self.node_list["Txt_percent"].text.text = self.gold_percent or 100
end

function DailyLoveView:OpenRecharge()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function DailyLoveView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_DAILY_LOVE)
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
	self.node_list["TxtLastTime"].text.text = time_str
end