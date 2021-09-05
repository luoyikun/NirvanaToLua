MainuiActivityHallView = MainuiActivityHallView or BaseClass(BaseView)
local PAGE_COUNT = 10
function MainuiActivityHallView:__init()
	self.ui_config = {{"uis/views/activityview_prefab", "MainuiActivityHall"}}
	-- self.view_layer = UiLayer.Pop
	self.list_cell = {}
	self.data_list = {}

	self.is_modal = false
	-- self.background_opacity = 0
	self.play_audio = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function MainuiActivityHallView:__delete()

end

function MainuiActivityHallView:ReleaseCallBack()
	for k,v in pairs(self.list_cell) do
		if nil ~= v then
			v:DeleteMe()
		end
	end
	self.list_cell = {}
	self.data_list = {}

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end
end

function MainuiActivityHallView:LoadCallBack()
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.ACTIVITY_JUAN_ZHOU)
end

function MainuiActivityHallView:RemindChangeCallBack(remind_name, num)
	self:FlushRankActivityRed()
end

function MainuiActivityHallView:GetNumberOfCells()
	return math.ceil(#ActivityData.Instance:GetActivityHallDatalist() / PAGE_COUNT)
end

function MainuiActivityHallView:RefreshCell(cell, data_index)
	-- 构造Cell对象.
	local item = self.list_cell[cell]
	if nil == item then
		item = MainuiActivityHallGroup.New(cell)
		self.list_cell[cell] = item
	end
	local data = {}
	local data_list = ActivityData.Instance:GetActivityHallDatalist()
	for i = 1, PAGE_COUNT do
		if data_list[data_index * PAGE_COUNT + i] then
			table.insert(data, data_list[data_index * PAGE_COUNT + i])
		else
			break
		end
	end
	item:SetData(data)
end

function MainuiActivityHallView:CloseWindow()
	self:Close()
end

function MainuiActivityHallView:CloseCallBack()
	for k,v in pairs(self.list_cell) do
		if v then
			v:RemoveActTime()
		end
	end
end

function MainuiActivityHallView:OpenCallBack()
	self:Flush()
	RemindManager.Instance:Fire(RemindName.LimitBigGift)
	-- MainuiActivityHallData.Instance:FlushActRedPoint()
end

function MainuiActivityHallView:OnFlush()
	self.data_list = ActivityData.Instance:GetActivityHallDatalist()
	if self.node_list["ListView"] and self.node_list["ListView"].scroller.isActiveAndEnabled then
		local count = math.ceil(#self.data_list / PAGE_COUNT)
		for i = 1,7 do
			self.node_list["ImgPageToggle" .. i]:SetActive(count > 1 and i <= count)
		end
		self.node_list["ListView"].list_page_scroll:SetPageCount(count)
		self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function MainuiActivityHallView:FlushRankActivityRed()
	if not self.is_open then
		return
	end
	if self.node_list["ListView"] and self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function MainuiActivityHallView:FlushRankActivity()
	if not self.is_open then
		return
	end
	if self.node_list["ListView"] and self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

----------------------------------------------------------------------------
--MainuiActivityHallGroup 		列表滚动条格子
----------------------------------------------------------------------------

MainuiActivityHallGroup = MainuiActivityHallGroup or BaseClass(BaseCell)

function MainuiActivityHallGroup:__init()
	self.cell_list = {}
	self.data = {}

	for i = 1, PAGE_COUNT do
		local async_loader = AllocAsyncLoader(self, "icon_loader_" .. i)
		async_loader:Load("uis/views/activityview_prefab", "MainuiActivityHallIcon", function (obj)
			if IsNil(obj) then
				return
			end
			local obj_transform = obj.transform
			obj_transform:SetParent(self.root_node.transform, false)
			local item = MainuiActivityHallCell.New(obj)
			table.insert(self.cell_list, item)
			if #self.cell_list == PAGE_COUNT then
				self:SetData(self.data)
			end
		end)
	end
end

function MainuiActivityHallGroup:RemoveActTime()
	for k,v in pairs(self.cell_list) do
		if v then
			v:RemoveActTime()
		end
	end
end

function MainuiActivityHallGroup:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function MainuiActivityHallGroup:SetData(data)
	self.data = data
	if #self.cell_list < PAGE_COUNT then return end
	for k,v in pairs(self.cell_list) do
		v:SetData(data[k])
		v:SetActive(data[k] ~= nil)
	end
end


----------------------------------------------------------------------------
--MainuiActivityHallCell 		列表滚动条格子
----------------------------------------------------------------------------

MainuiActivityHallCell = MainuiActivityHallCell or BaseClass(BaseCell)

function MainuiActivityHallCell:__init()
	self.node_list["BtnImg"].button:AddClickListener(BindTool.Bind(self.OnButtonClick, self))
end

function MainuiActivityHallCell:__delete()
	if self.act_next_timer then
		GlobalTimerQuest:CancelQuest(self.act_next_timer)
		self.act_next_timer = nil
	end
end

function MainuiActivityHallCell:OnFlush()
	if not self.data or not next(self.data) then return end
	local act_cfg = ActivityData.Instance:GetActivityConfig(self.data.type)
	if act_cfg then
		local bundle, asset = ResPath.GetMainIcon(act_cfg.icon)
		self.node_list["BtnImg"].image:LoadSpriteAsync(bundle, asset .. ".png", function ()
			-- self.node_list["BtnImg"].image:SetNativeSize()
		end)
		self.node_list["ImgName"].image:LoadSpriteAsync(bundle, asset .."Name.png", function ()
			self.node_list["ImgName"].image:SetNativeSize()
		end)
	end

	if (self.data.type == ACTIVITY_TYPE.FUNC_TYPE_LONGXING or self.data.fun_name == ViewName.DailyRebateView) or
	(self.data.type == ACTIVITY_TYPE.FUNC_TYPE_CLOTHE and self.data.fun_name == ViewName.ClothespressView) then
		local bundle, asset = ResPath.GetMainIcon(self.data.icon)
		self.node_list["BtnImg"].image:LoadSpriteAsync(bundle, asset .. ".png", function ()
			-- self.node_list["BtnImg"].image:SetNativeSize()
		end)
		self.node_list["ImgName"].image:LoadSpriteAsync(bundle, asset .."Name.png", function ()
			self.node_list["ImgName"].image:SetNativeSize()
		end)
	end

	self:FlushRedPointInCell()
	self:SetHuoDongActTime(self.data.type)
end

function MainuiActivityHallCell:SetActive(value)
	self.node_list["Panel"]:SetActive(value)
	if self.data ~= nil and (self.data.fun_name ~= ViewName.DailyRebateView or
		self.data.type ~= ACTIVITY_TYPE.FUNC_TYPE_LONGXING or self.data.type == ACTIVITY_TYPE.FUNC_TYPE_CLOTHE) then
		local act_time = self:GetActEndTime(self.data.type)
		if act_time <= 0 then
	  		self.node_list["Panel"]:SetActive(value)
		end
	end
end

-- 红点刷新
function MainuiActivityHallCell:FlushRedPointInCell()
	local show = MainuiActivityHallData.Instance:GetShowOnceEff(self.data.type)
	local act_red = ActivityData.Instance:GetActivityRedPointState(self.data.type)
	local act_num = ActivityData.Instance:GetActivityRedPointNum()
	self:ShowEff(show)
	
	if not show or MainuiActivityHallData.DelayRemindList[self.data.type] then
		self.node_list["ImgRedPoint"]:SetActive(act_red)
	end

	if act_num == 0 then
		-- 开启活动时，卷轴里面的活动默认显示红点
		self.node_list["ImgRedPoint"]:SetActive(true)
	end
end

function MainuiActivityHallCell:ShowEff(value)
	-- if self.node_list["Effect"] then
	-- 	self.node_list["Effect"]:SetActive(value)
	-- end
	if self.node_list["ImgRedPoint"] then
		self.node_list["ImgRedPoint"]:SetActive(value)
	end
end

function MainuiActivityHallCell:OnButtonClick()
	RemindManager.Instance:Fire(RemindName.ACTIVITY_JUAN_ZHOU)
	local act_cfg = ActivityData.Instance:GetActivityConfig(self.data.type)
	if self.data.type == ACTIVITY_TYPE.FUNC_TYPE_LONGXING or self.data.fun_name == ViewName.DailyRebateView 
		or self.data.type == ACTIVITY_TYPE.FUNC_TYPE_CLOTHE then
		ViewManager.Instance:Open(self.data.open_name)
	end
	if act_cfg then
		-- 开服活动处理
		if act_cfg.open_name == ViewName.KaifuActivityView then
			local index = KaifuActivityData.Instance:GetActivityTypeToIndex(act_cfg.act_id)
			KaifuActivityData.Instance:SetDefaultOpenActType(act_cfg.act_id)
			ViewManager.Instance:Open(act_cfg.open_name, index)
		else

			ViewManager.Instance:Open(act_cfg.open_name)
		end

		-- ViewManager.Instance:Open(act_cfg.open_name)
		
		-- MainuiActivityHallData.Instance:SetShowOnceEff(self.data.type, false)
		-- local act_red = ActivityData.Instance:GetActivityRedPointState(self.data.type)
		-- self:ShowEff(act_red)

		local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
		if cur_day > -1 then
			PlayerPrefsUtil.SetInt("activity_hall_day" .. self.data.type, cur_day)
		end
	end
end

function MainuiActivityHallCell:RemoveActTime()
	if self.act_next_timer then
		GlobalTimerQuest:CancelQuest(self.act_next_timer)
		self.act_next_timer = nil
	end
end

-- 活动倒计时
function MainuiActivityHallCell:SetHuoDongActTime(act_type)
	if nil == self.act_next_timer then
		self:FlushNextTime(act_type)
		self.act_next_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self, act_type), 1)
	end
end

function MainuiActivityHallCell:FlushNextTime(act_type)
	local act_time = self:GetActEndTime(act_type)
	if self.data == nil then
		return
	end
	
	if (self.data.fun_name == ViewName.DailyRebateView or self.data.type == ACTIVITY_TYPE.FUNC_TYPE_LONGXING 
		or self.data.type == ACTIVITY_TYPE.FUNC_TYPE_CLOTHE) and self.data then
		self.node_list["TxtActTime"]:SetActive(false)
	else
		self.node_list["TxtActTime"]:SetActive(true)
	end
	self.node_list["TxtActTime"].text.text = ActivityData.Instance:GetActTimeShow(act_time)
	if act_time <= 0 then
		if self.act_next_timer then
			GlobalTimerQuest:CancelQuest(self.act_next_timer)
			self.act_next_timer = nil
		end
	end

end

--返回活动结束时间
function MainuiActivityHallCell:GetActEndTime(act_type)
	local act_info = ActivityData.Instance:GetActivityStatuByType(act_type)
	if act_info then
		local next_time = act_info.next_time
		local time = math.max(next_time - TimeCtrl.Instance:GetServerTime() , 0)
		if act_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_2 then
			IncreaseCapabilityData.Instance:SetRestTime(time)
		end
		if act_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_3 then
			IncreaseSuperiorData.Instance:SetRestTime(time)
		end
		if act_type == ACTIVITY_TYPE.RAND_ACTIVITY_LUCKYDRAW then
			LuckyDrawData.Instance:SetRestTime(time)
		end
		if act_type == ACTIVITY_TYPE.RAND_HAPPY_RECHARGE then
			HappyRechargeData.Instance:SetRestTime(time)
		end
		if act_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_BIG_GIFT then
			if TimeLimitBigGiftData.Instance:GetRestTime() then
				time = TimeLimitBigGiftData.Instance:GetRestTime()
			end
		end
		if act_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BiPin_ACTIVITY then
			time = BiPingActivityData.Instance:GetActivitytimes()
		end
		if act_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LUCKY_WISH then
			time = LuckWishingData.Instance:GetActivitytimes()
		end
		if act_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_GIFT then
			local open_flag = TimeLimitGiftData.Instance:GetTimeLimitGiftInfo().open_flag

			if 0 == open_flag then
				local limit_gift_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_GIFT)
				ActivityData.Instance:SetActivityStatus(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_GIFT, ACTIVITY_STATUS.CLOSE,
					limit_gift_info.next_time,limit_gift_info.start_time,limit_gift_info.end_time,limit_gift_info.open_type)
			else
				local data_time = TimeLimitGiftData.Instance:GetLimitGiftCfg().limit_time or 0
				local begin_timestamp = TimeLimitGiftData.Instance:GetTimeLimitGiftInfo().begin_timestamp
				local end_time = begin_timestamp + data_time
				--获取当天的结束时间戳
				local now_day_end_time = TimeUtil.NowDayTimeEnd(TimeCtrl.Instance:GetServerTime())
				end_time = math.min(end_time, now_day_end_time)						
				time = end_time - TimeCtrl.Instance:GetServerTime()
			end
		end
		return time
	else
		if act_type == ACTIVITY_TYPE.KF_KUAFUCONSUME then
			local time = 0 
			local act_info = ActivityData.Instance:GetCrossRandActivityStatusByType(ACTIVITY_TYPE.KF_KUAFUCONSUME)
			if act_info then
				time = act_info.next_time - TimeCtrl.Instance:GetServerTime()
			end
			return time
		end
	end
	return 0
end
