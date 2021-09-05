ConsumeRewardView = ConsumeRewardView or BaseClass(BaseView)

function ConsumeRewardView:__init()
	self.ui_config = {
		{"uis/views/consumereward_prefab", "ConsumeRewardView"},
	}
	-- self.view_layer = UiLayer.Pop
	self.full_screen = false
	self.play_audio = true
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function ConsumeRewardView:__delete()
	-- body
end

function ConsumeRewardView:LoadCallBack()
	local cfg = ConsumeRewardData.Instance:GetRewardGiftCfg()
	self.show_info_list = cfg.reward_item
	self.item_cell_list = {}
	for i = 1, 3 do
		self.item_cell_list[i] = self.node_list["Item"..i]

		if nil ~= self.item_cell_list[i] then
			local item_cell = ItemCell.New()
			--设置位置
			item_cell:SetInstanceParent(self.item_cell_list[i])
			--设置奖励
			local cfg_index = i - 1
			item_cell:SetData(self.show_info_list[cfg_index])
		end
	end
	self.node_list["ButtonClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.node_list["ButtonConsume"].button:AddClickListener(BindTool.Bind(self.ClickRecharge, self))
	self.node_list["ButtonGetReward"].button:AddClickListener(BindTool.Bind(self.ClickGetReward, self))

	self.node_list["ButtonGetReward"]:SetActive(true)
end

--释放回调
function ConsumeRewardView:ReleaseCallBack()
	self.show_info_list = nil
	self.fetch_reward_flag = nil
	self.consume_gold = nil
end

function ConsumeRewardView:OnFlush()
	local consume_reward_info = ConsumeRewardData.Instance:GetRewardGiftInfo()
	if not consume_reward_info then
		return
	end
    
	self.consume_gold = consume_reward_info.consume_gold or 0
	self.fetch_reward_flag = consume_reward_info.fetch_reward_flag or 1
	local cfg = ConsumeRewardData.Instance:GetRewardGiftCfg()
	if not cfg or not cfg.consume_gold then
		return
    end
    local consume_gold = cfg.consume_gold
	if self.fetch_reward_flag == 0 and self.consume_gold >= consume_gold then
		self.node_list["ButtonGetReward"]:SetActive(true)
		self.node_list["ButtonConsume"]:SetActive(false)
	end

	if self.fetch_reward_flag == 0 and self.consume_gold < consume_gold  then
		self.node_list["ButtonGetReward"]:SetActive(false)
		self.node_list["ButtonConsume"]:SetActive(true)
	end

	if self.fetch_reward_flag ~= 0 then
		UI:SetGraphicGrey(self.node_list["ButtonGetReward"], true)
		self.node_list["ButtonConsume"]:SetActive(false)
	end

	if cfg.consume_gold == nil or cfg.consume_gold - self.consume_gold <= 0 then
		local Ctext = string.format(cfg.consume_gold)
		self.node_list["Cost"].text.text = Ctext
	else
		local Ctext = string.format(cfg.consume_gold - self.consume_gold)
		self.node_list["Cost"].text.text = Ctext
	end

end

--关闭页面
function ConsumeRewardView:CloseView()
	self:Close()
end

--点击消费按钮
function ConsumeRewardView:ClickRecharge()
	self:CloseView()
	ViewManager.Instance:Open(ViewName.Shop, TabIndex.shop_youhui)
end

--设置时间
function ConsumeRewardView:SetTime(time)
	time_tab = TimeUtil.Format2TableDHMS(time)
	-- local str = ""
	local str = string.format(Language.Activity.ActivityTime10, time_tab.hour, time_tab.min, time_tab.s)
	local time_tab = TimeUtil.FormatSecond(time, 10)
    self.node_list["EndTime"].text.text = time_tab
end

function ConsumeRewardView:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end

end

--打开回调函数
function ConsumeRewardView:OpenCallBack()
	local can_reward = self:GetIsReward()
	ConsumeRewardData.Instance:SetIsOpenCousumeReWard()
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_GOLD_FANLI, can_reward)

	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_GOLD_FANLI,
			RA_CONSUME_GOLD_REWARD_OPERATE_TYPE.RA_CONSUME_GOLD_REWARD_OPERATE_TYPE_INFO)
	local activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_GOLD_FANLI
	local time_tab = ActivityData.Instance:GetActivityResidueTime(activity_type)
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

	if time_tab >= 0 then
		self.least_time_timer = CountDown.Instance:AddCountDown(time_tab, 1, function ()
				time_tab = time_tab - 1
				self:SetTime(time_tab)
		end)
	end

end

function ConsumeRewardView:GetIsReward()
	local info = ConsumeRewardData.Instance:GetRewardGiftInfo()
	local cfg = ConsumeRewardData.Instance:GetRewardGiftCfg()
	local can_reward = info.fetch_reward_flag == 0 and info.consume_gold >= cfg.consume_gold
	return can_reward
end

--关闭回调函数
function ConsumeRewardView:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end

end

--点击领取礼包
function ConsumeRewardView:ClickGetReward()
    if self.fetch_reward_flag >= 1 then
        return
    end
   	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_GOLD_FANLI,
				RA_CONSUME_GOLD_REWARD_OPERATE_TYPE.RA_CONSUME_GOLD_REWARD_OPERATE_TYPE_FETCH)
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_GOLD_FANLI,
				RA_CONSUME_GOLD_REWARD_OPERATE_TYPE.RA_CONSUME_GOLD_REWARD_OPERATE_TYPE_INFO)
	self:CloseViewEver()
end

--领取完礼包后界面不再出现
function ConsumeRewardView:CloseViewEver()
	--调用关闭页面函数
	self:CloseView()
end