
RechargeReturnRewardView = RechargeReturnRewardView or BaseClass(BaseView)
function RechargeReturnRewardView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_1"},
		{"uis/views/randomact/rechargereturnreward_prefab", "RechargeReturnReward"},
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_2"},
	}
	self.play_audio = true
	self.reward_count = 4
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function RechargeReturnRewardView:__delete()
end

function RechargeReturnRewardView:ReleaseCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function RechargeReturnRewardView:LoadCallBack(index, loaded_times)

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnDress"].button:AddClickListener(BindTool.Bind(self.OpenRecharge, self))
	self.node_list["Name"].text.text = Language.Activity.RechargeReturnReward
end

function RechargeReturnRewardView:OnClickRecharge()
end


function RechargeReturnRewardView:ShowIndexCallBack(index)
	self:Flush(index)
end
	
function RechargeReturnRewardView:OpenCallBack()
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHONGZHI_CRAZY_REBATE, false)
end

function RechargeReturnRewardView:CloseCallBack()
end

function RechargeReturnRewardView:OpenRecharge()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function RechargeReturnRewardView:OnFlush(param_t, index)
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end

	local config = RechargeReturnRewardData.Instance:GetActConfig()
	for i = 1, self.reward_count do
		local cfg = config[i]
		if cfg then
			local desc = ""
			if i <= 3 then
				desc = cfg.gold_low_limit .. "-" .. cfg.gold_high_limit
			else
				desc = cfg.gold_low_limit
			end

			self.node_list["TxtDesc" .. i].text.text = desc
			if i == self.reward_count then
				self.node_list["TxtDesc" .. i].text.text = desc .. Language.Activity.YiShang
			end
			self.node_list["TxtDesc" .. (i + 4)].text.text = cfg.reward_precent .. "%"
		end
	end

	local num = RechargeReturnRewardData.Instance:GetRechargeNum()
	self.node_list["TxtTopUp"].text.text = num or 0
end

function RechargeReturnRewardView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHONGZHI_CRAZY_REBATE)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	local time_type = 1
	if time > 3600 * 24 then
		time_type = 6
	elseif time > 3600 then
		time_type = 1
	else
		time_type = 2
	end
	self.node_list["TxtTime"].text.text =string.format(Language.RechargeCapacity.ReturnActTime, ToColorStr(TimeUtil.FormatSecond(time, time_type), TEXT_COLOR.GREEN))
end
