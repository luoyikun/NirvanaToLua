ConsumeDiscountView = ConsumeDiscountView or BaseClass(BaseView)
function ConsumeDiscountView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_1"},
		{"uis/views/randomact/consumediscount_prefab", "ConsumeDiscountView"},
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_2"},
	}
	self.play_audio = true
	self.rare_list = {}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function ConsumeDiscountView:__delete()

end

function ConsumeDiscountView:ReleaseCallBack()
	if nil ~= self.extra_gift then
		self.extra_gift:DeleteMe()
		self.extra_gift = nil
	end

	if nil ~= self.consume_gift then
		self.consume_gift:DeleteMe()
		self.consume_gift = nil
	end

	for k,v in pairs(self.rare_list) do
		v:DeleteMe()
	end
	self.rare_list = {}

end

function ConsumeDiscountView:LoadCallBack()

	self.extra_gift = ItemCell.New()
	self.extra_gift:SetInstanceParent(self.node_list["RareItem"])

	self.consume_gift = ItemCell.New()
	self.consume_gift:SetInstanceParent(self.node_list["CurItem"])

	local continue_consume = ConsumeDiscountData.Instance:GetRAContinueConsumeCfg()

	self.rare_list = {}
	for i = 1, 6 do
		self.rare_list[i] = ItemCell.New()
		self.rare_list[i]:SetInstanceParent(self.node_list["RareItemDisplay"])
		if continue_consume[i] then
			self.rare_list[i]:SetData({item_id = continue_consume[i].show_item, is_bind = 0})
		end
		self.rare_list[i].root_node:SetActive(continue_consume[i] ~= nil)
	end

	self.consume_gift:SetData(continue_consume[1].reward_item or {})
	local server_other_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfigOtherCfg()
	self.extra_gift:SetData(server_other_cfg.continue_consume_extra_reward or {})
	self.node_list["TxtNum"].text.text = server_other_cfg.continue_consume_fetch_extra_reward_need_days or 0

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnLeftReward"].button:AddClickListener(BindTool.Bind(self.OnClickToGetReward, self, 0))
	self.node_list["BtnRightReward"].button:AddClickListener(BindTool.Bind(self.OnClickToGetReward, self, 1))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickBtnTips, self))
	self.node_list["Name"].text.text = Language.Activity.LianXiao
end

function ConsumeDiscountView:OpenCallBack()
	if self.consume_discount then
		CountDown.Instance:RemoveCountDown(self.consume_discount)
	end
	local act_cornucopia_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CONSUME) or {}
	if act_cornucopia_info.status == ACTIVITY_STATUS.OPEN then
		local next_time = act_cornucopia_info.next_time or 0
		self:UpdataRollerTime(0, next_time)
		self.consume_discount = CountDown.Instance:AddCountDown(next_time, 1, BindTool.Bind1(self.UpdataRollerTime, self), BindTool.Bind1(self.CompleteRollerTime, self))
	else
		self:CompleteRollerTime()
	end
	local param_t = {
		rand_activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CONSUME,
		opera_type = RA_CONTINUE_CONSUME_OPERA_TYPE.RA_CONTINUME_CONSUME_OPERA_TYPE_QUERY_INFO,
	}
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(param_t.rand_activity_type, param_t.opera_type)
end

function ConsumeDiscountView:CloseCallBack()
	if self.consume_discount then
		CountDown.Instance:RemoveCountDown(self.consume_discount)
	end
end

function ConsumeDiscountView:OnFlush()
	self:FlushPanel()
end

function ConsumeDiscountView:FlushPanel()
	local consume_info = ConsumeDiscountData.Instance:GetRAContinueConsumeInfo()
	local str = ""
	if consume_info then
		local continue_consume = ConsumeDiscountData.Instance:GetRAContinueConsumeCfg()

		if nil == continue_consume[consume_info.current_day_index] then return end

		self.consume_gift:SetData(continue_consume[consume_info.current_day_index].reward_item)  --连消奖励
		local need_consume_gold = continue_consume[consume_info.current_day_index].need_consume_gold or 0
		self.node_list["TxtRewardDay"].text.text = string.format(Language.ConsumeDiscount.DayLeiJiDay, consume_info.current_day_index)
		self.node_list["TxtRewardLimit"].text.text = string.format(Language.ConsumeDiscount.DayLeiJiCounsume, need_consume_gold)
		self.node_list["TxtConsume"].text.text = string.format(Language.ConsumeDiscount.TodayLeiJiConsume, consume_info.today_consume_gold_total)		--累计消费
		if consume_info.continue_days < 5 then
			str = string.format(Language.Common.ShowRedStr, consume_info.continue_days)
			self.node_list["TxtTips"].text.text = Language.ConsumeDiscount.WeiDaDao
		else
			str = string.format(Language.Common.ShowGreenStr, consume_info.continue_days)
			if consume_info.extra_reward_num > 0 then
				self.node_list["TxtTips"].text.text = Language.ConsumeDiscount.KeLingQu
			else
				self.node_list["TxtTips"].text.text = Language.ConsumeDiscount.LingQu
			end
		end
		self.node_list["TxtSeriesReachDay"].text.text = string.format(Language.ConsumeDiscount.ReachDays, str) 		--连续达标天数

		local percent = consume_info.cur_consume_gold / need_consume_gold * 100
		percent = percent < 100 and percent or 100
		self.node_list["SliderProgressBG"].slider.value = percent / 100 --消费占比

		local color = 0
		if consume_info.cur_consume_gold >= need_consume_gold then
			color = '#89F201FF'
		else
			color = '#F9463BFF'
		end
		self.node_list["TxtTodayConsume"].text.text = string.format(Language.ConsumeDiscount.TodayHasConsume, color, consume_info.cur_consume_gold, need_consume_gold)

		self:JudgeLeftState(math.floor(consume_info.cur_consume_gold / need_consume_gold))
		self:JudgeRightState(consume_info.extra_reward_num)
	end
end

function ConsumeDiscountView:JudgeRightState(RareRewardCount)
	self.node_list["RedRight"]:SetActive(RareRewardCount > 0)
	self.node_list["TxtRightRewardCount"].text.text = string.format(Language.ConsumeDiscount.CanGetExtraReward, RareRewardCount)
	self.node_list["TxtRightRewardCount"]:SetActive(RareRewardCount > 0)
	UI:SetButtonEnabled(self.node_list["BtnRightReward"], RareRewardCount > 0)
end

function ConsumeDiscountView:JudgeLeftState(RewardCount)
	self.node_list["RedLeft"]:SetActive(RewardCount > 0)
	self.node_list["TxtLeftRewardCount"].text.text = string.format(Language.ConsumeDiscount.CanGetReward, RewardCount)
	self.node_list["TxtLeftRewardCount"]:SetActive(RewardCount > 0)
	UI:SetButtonEnabled(self.node_list["BtnLeftReward"], RewardCount > 0)
end

function ConsumeDiscountView:UpdataRollerTime(elapse_time, next_time)
	local time = next_time - TimeCtrl.Instance:GetServerTime()
	if time ~= nil then
		if time > 0 then
			local format_time = TimeUtil.Format2TableDHMS(time)
			local time_str = ""
			if format_time.day >= 1 then
				time_str = string.format(Language.JinYinTa.ActEndTime, format_time.day, format_time.hour)
			else
				time_str = string.format(Language.JinYinTa.ActEndTime2, format_time.hour, format_time.min, format_time.s)
			end
			self.node_list["TxtTime"].text.text = time_str
		end
	end
end

function ConsumeDiscountView:CompleteRollerTime()
	if self.label_time ~= nil then
		self.node_list["TxtTime"].text.text = "0"
	end
end

function ConsumeDiscountView:OnClickToGetReward(num)
	if 0 == num then
		local param_t = {
			rand_activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CONSUME,
			opera_type = RA_CONTINUE_CONSUME_OPERA_TYPE.RA_CONTINUE_CONSUME_OPEAR_TYPE_FETCH_REWARD,
		}
		KaifuActivityCtrl.Instance:SendRandActivityOperaReq(param_t.rand_activity_type, param_t.opera_type)
	elseif 1 == num then
		local param_t = {
			rand_activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CONSUME,
			opera_type = RA_CONTINUE_CONSUME_OPERA_TYPE.RA_CONTINUE_CONSUME_OPEAR_TYPE_FETCH_EXTRA_REWARD,
		}
		KaifuActivityCtrl.Instance:SendRandActivityOperaReq(param_t.rand_activity_type, param_t.opera_type)
	end
end

function ConsumeDiscountView:OnClickBtnTips()
	TipsCtrl.Instance:ShowHelpTipView(229)
end