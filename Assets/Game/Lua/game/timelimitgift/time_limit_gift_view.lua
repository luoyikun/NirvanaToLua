--------------------------------------------------------------------------
--TimeLimitGiftView 	限时礼包总面板
--------------------------------------------------------------------------

TimeLimitGiftView = TimeLimitGiftView or BaseClass(BaseView)

function TimeLimitGiftView:__init()
	self.ui_config = {{"uis/views/timelimitgiftview_prefab", "TimeLimitGiftView"}}
	self.play_audio = true
	-- self.view_layer = UiLayer.Pop
	self.is_modal = true
end

function TimeLimitGiftView:__delete()

end

function TimeLimitGiftView:LoadCallBack()
	self.node_list["ButtonClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.node_list["Button"].button:AddClickListener(BindTool.Bind(self.ClickRecharge, self))
	self.node_list["Button2"].button:AddClickListener(BindTool.Bind(self.ClickGetReward, self))

	self.item_cell_list = {}
	for i = 1, 4 do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.node_list["Item"..i])
	end
end

function TimeLimitGiftView:ReleaseCallBack()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = nil

	self.reward_cfg = nil
end

function TimeLimitGiftView:CloseCallBack()
	self:RemoveCountDown()
end

function TimeLimitGiftView:OpenCallBack()
	self:SetRelevantData()
end

function TimeLimitGiftView:OnFlush()
	local cfg = TimeLimitGiftData.Instance:GetShowNeedRelevantCfg()
	local reward_index = TimeLimitGiftData.Instance:GetCurAwardIndex()
	local reward_cfg = cfg.reward_item or {}
	local cost = cfg.charge_value or 0
	local money = cfg.gift_value or 0
	local des = Language.TimeLimitGiftView.RewardDes[reward_index]
	local is_get_reward = TimeLimitGiftData.Instance:IsCanGetAward()

	for k,v in pairs(self.item_cell_list) do
		if reward_cfg[k - 1] then
			v:SetData(reward_cfg[k - 1])
			self.node_list["Item"..k]:SetActive(true)
		else
			self.node_list["Item"..k]:SetActive(false)
		end
	end

	self.node_list["Cost"].text.text = cost
	self.node_list["Tips"].text.text = string.format(Language.TimeLimitGift.Tips2, money)
	self.node_list["DecText"].text.text = des
	self.node_list["Button"]:SetActive(not is_get_reward)
	self.node_list["Button2"]:SetActive(is_get_reward)
end

--设置时间
function TimeLimitGiftView:SetTime(time)
	local time_tab = TimeUtil.Format2TableDHMS(time)
	local temp = {}
	for k,v in pairs(time_tab) do
		if k ~= "day" and k ~= "hour" then
			if v < 10 then
				v = tostring('0'..v)
			end
		end
		temp[k] = v
	end
	local str
	if temp.day > 0 then
		str = string.format(Language.Activity.ActivityTime11, temp.day, temp.hour)
	else
		str = string.format(Language.Activity.ActivityTime10, temp.hour, temp.min,temp.s)
	end
	self.node_list["Time"].text.text = str
end

--相关数据显示
function TimeLimitGiftView:SetRelevantData()
	local cfg = TimeLimitGiftData.Instance:GetLimitGiftCfg()
	self.cur_seq = cfg.seq or 0
	self.limit_time	= cfg.limit_time or 0
	self:Flush()

	local info = TimeLimitGiftData.Instance:GetTimeLimitGiftInfo()
	local begin_timestamp = info and info.begin_timestamp or 0
	local end_time = begin_timestamp + self.limit_time
	--获取当天的结束时间戳
	local now_day_end_time = TimeUtil.NowDayTimeEnd(TimeCtrl.Instance:GetServerTime())
	end_time = math.min(end_time, now_day_end_time)	
	local rest_time = end_time - TimeCtrl.Instance:GetServerTime()
	self:RemoveCountDown()
	self:SetTime(rest_time)
    if rest_time >= 0 then
		self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
				rest_time = rest_time - 1
				self:SetTime(rest_time)
		end)
	end	
end

function TimeLimitGiftView:RemoveCountDown()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

--点击领取礼包
function TimeLimitGiftView:ClickGetReward()
	local reward_index = TimeLimitGiftData.Instance:GetCurAwardIndex()

	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_GIFT,
		RA_TIMELIMIT_GIFT_OPERA_TYPE.RA_TIMELIMIT_GIFT_OPERA_TYPE_FETCH_REWARD,
		self.cur_seq, reward_index)
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_GIFT,
				RA_TIMELIMIT_GIFT_OPERA_TYPE.RA_TIMELIMIT_GIFT_OPERA_TYPE_QUERY_INFO)

	if reward_index == TIME_LIMIT_GIFT_REWARD_INDEX.TWO_INDEX then
		self:Close()
	end
end

--点击充值按钮
function TimeLimitGiftView:ClickRecharge()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
	self:Close()
end

function TimeLimitGiftView:CloseView()
	self:Close()
end