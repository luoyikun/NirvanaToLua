--------------------------------------------------------------------------
--TimeLimitBigGiftView 	限时豪礼面板
--------------------------------------------------------------------------

TimeLimitBigGiftView = TimeLimitBigGiftView or BaseClass(BaseView)

function TimeLimitBigGiftView:__init()
	self.ui_config = {{"uis/views/randomact/timelimitbiggift_prefab", "TimeLimitBigGiftView"}}
	self.play_audio = true
	self.is_modal = true
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.LimitBigGift)
end

function TimeLimitBigGiftView:__delete()
	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end
end

--打开回调函数
function TimeLimitBigGiftView:OpenCallBack()
	self:Flush()
	
	local info = TimeLimitBigGiftData.Instance:GetTimeLimitGiftInfo()
	if info then
		local end_time = info.begin_timestamp + (self.limit_time or 0)
		--获取当天的结束时间戳
		local now_day_end_time = TimeUtil.NowDayTimeEnd(TimeCtrl.Instance:GetServerTime())
		end_time = math.min(end_time, now_day_end_time)		
		local rest_time = end_time - TimeCtrl.Instance:GetServerTime()
		self:SetTime(rest_time)
	    if rest_time >= 0 then
			self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
					rest_time = rest_time - 1
					self:SetTime(rest_time)
			end)
		end
	end
end

--关闭回调函数
function TimeLimitBigGiftView:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function TimeLimitBigGiftView:LoadCallBack()
	self.item_list = {}
	for i = 1, 4 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["item_cell"..i])
	end

	self.node_list["buy_btn"].button:AddClickListener(BindTool.Bind(self.ClickBuy, self))
	self.node_list["btn_close"].button:AddClickListener(BindTool.Bind(self.CloseView, self))

	local cfg = TimeLimitBigGiftData.Instance:GetLimitGiftCfg()
	if cfg then
		self.limit_time	= cfg.limit_time or 0
	end
	-- RemindManager.Instance:SetRemindToday(RemindName.LimitBigGift)
end

--释放回调
function TimeLimitBigGiftView:ReleaseCallBack()
	if self.item_list then
		for i = 1, 4 do
			self.item_list[i]:DeleteMe()
			self.item_list[i] = nil
		end
		self.item_list = nil
	end
end

function TimeLimitBigGiftView:OnFlush()
	local cfg = TimeLimitBigGiftData.Instance:GetLimitGiftCfg()
	
	if cfg and cfg.reward_item and cfg.limit_time and cfg.seq and cfg.need_gold and cfg.gift_value then
		self.show_info_list = cfg.reward_item
		self.show_info_list_seq = cfg.seq
		self.limit_time	= cfg.limit_time
		self.node_list["cost_text"].text.text = cfg.need_gold
		self.node_list["value_text"].text.text = cfg.gift_value

		local num = 0
		for k, v in pairs(cfg.reward_item) do 
			num = num + 1
		end
		if self.item_list and num > 0 then
			for i = 1, 4 do
				if self.item_list[i] then
					self.node_list["item_cell"..i]:SetActive(i <= num)
					self.item_list[i]:SetData(cfg.reward_item[i - 1])
				end	
			end
		end
	end

	self:FlushBuyButton()
end


function TimeLimitBigGiftView:FlushBuyButton()
	self.is_already_buy = TimeLimitBigGiftData.Instance:GetTimeLimitGiftInfo().is_already_buy or 0
	UI:SetButtonEnabled(self.node_list["buy_btn"], self.is_already_buy <= 0)
	local btn_str = self.is_already_buy <= 0 and Language.Common.CanPurchase or Language.Common.AlreadyPurchase
	self.node_list["show_buy_text"].text.text = btn_str
end

--设置时间
function TimeLimitBigGiftView:SetTime(time)
	time_tab = TimeUtil.Format2TableDHMS(time)
	local str = string.format(Language.Activity.ActivityTime10, time_tab.hour, time_tab.min, time_tab.s)
	self.node_list["res_time"].text.text = str
end

function TimeLimitBigGiftView:ClickBuy()
	if self.is_already_buy and self.is_already_buy <= 0 then
		local gold_num = PlayerData.Instance.role_vo["gold"] or 0
		local cfg = TimeLimitBigGiftData.Instance:GetLimitGiftCfg()
		if not cfg or not cfg.need_gold  then
			return 
		end

		if gold_num >= cfg.need_gold then
			local yes_func = function()
				TimeLimitBigGiftCtrl.Instance:SendBuyOrInfo(self.show_info_list_seq or 0)
			end
			local describe = string.format(Language.TimeLimitBigGift.BuyTips, cfg.need_gold) or ""
			TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
		else
			ViewManager.Instance:Open(ViewName.TipsLackDiamondView)
		end
	end
end

--关闭页面
function TimeLimitBigGiftView:CloseView()
	self:Close()
end

function TimeLimitBigGiftView:RemindChangeCallBack(remind_name, num)

	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_BIG_GIFT, num > 0)
end