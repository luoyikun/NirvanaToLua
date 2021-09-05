SingleRebateView =  SingleRebateView or BaseClass(BaseView)

function SingleRebateView:__init()
	self.ui_config = {
		-- {"uis/views/commonwidgets_prefab", "BaseActivityPanelTwo_1"},
		{"uis/views/randomact/singlerebate_prefab","SingleRebateView"},
		-- {"uis/views/commonwidgets_prefab", "BaseActivityPanelTwo_2"},
	}
	self.play_audio = true

	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function SingleRebateView:__delete()
end

function SingleRebateView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnRecharge"].button:AddClickListener(BindTool.Bind(self.ClickToRechage, self))
end

function SingleRebateView:OpenCallBack()
	--活动倒计时
	local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_REBATE)
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
		rest_time = rest_time - 1
		self:SetTime(rest_time)
	end)

	--设置返还百分比
	local num = SingleRebateData.Instance:GetRewardPrecent() or 0
	self.node_list["TxtNumber"].text.text = string.format("%s%%", num)

	MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.SingleRebate, false)
end

function SingleRebateView:ReleaseCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

--点击前往充值按钮
function SingleRebateView:ClickToRechage()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

--设置倒计时
function SingleRebateView:SetTime(rest_time)
	local time_str = ""
	local day_second = 24 * 60 * 60 		-- 一天有多少秒
	local left_day = math.floor(rest_time / day_second)
	if left_day > 0 then
		time_str = TimeUtil.FormatSecond(rest_time, 18)
	elseif rest_time < day_second then
		if math.floor(rest_time / 3600) > 0 then
			time_str = TimeUtil.FormatSecond(rest_time, 1)
		else
			time_str = TimeUtil.FormatSecond(rest_time, 2)
		end
	end
	self.node_list["TxtRestTime"].text.text = time_str
end