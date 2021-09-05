RareDialView = RareDialView or BaseClass(BaseView)
local COLUMN = 2
function RareDialView:__init()
	self.full_screen = false-- 是否是全屏界面
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour"},
		{"uis/views/zhenxizhuanlun_prefab", "RareDialView"}}
	self.play_audio = true
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function RareDialView:LoadCallBack()

	-- local bundle, asset = "uis/views/zhenxizhuanlun/images_atlas", "zhuanlun_title_text"
	-- self.node_list["ImgTitle"].image:LoadSprite(bundle, asset)
	-- self.node_list["ImgTitle"].image:SetNativeSize()
	
	self.node_list["Name"].text.text = Language.Title.MinYun
	self.is_cancel = false
	self.data = RareDialData.Instance
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	self.rare_data = self.data:GetDrawDataRareByOpenDay(open_day)
	self.return_data = self.data:GetDrawReturnDataByOpenDay(open_day)
	self.total_time = self.data:GetDrawDataMaxNumber()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.node_list["Btn_draw"].button:AddClickListener(BindTool.Bind(self.ClickDraw, self))
	self.node_list["BtnFlush"].button:AddClickListener(BindTool.Bind(self.ClickFlush, self))
	self.node_list["BtnWare"]. button:AddClickListener(BindTool.Bind(self.ClickWare, self))
	self.node_list["ImgCancel"].toggle:AddClickListener(BindTool.Bind(self.ClickCancel, self))
	self.node_list["Btn_question"].button:AddClickListener(BindTool.Bind(self.ClickQuestion, self))
	self.node_list["BtnQuickFlush"].button:AddClickListener(BindTool.Bind(self.ClickQuickFlush, self))
	self.node_list["BtnSop"].button:AddClickListener(BindTool.Bind(self.ClickStopFlush, self))
	self.node_list["BtnLucky"].button:AddClickListener(BindTool.Bind(self.OnClickLog, self))

	self.left_cell_list = {}
	self.node_list["LeftList"].scroll_rect.vertical = true
	self.left_list_view_delegate = self.node_list["LeftList"].list_simple_delegate

	self.right_cell_list = {}
	self.node_list["RightList"].scroll_rect.vertical = true
	self.right_list_view_delegate = self.node_list["RightList"].list_simple_delegate

	self.bg_list = {}
	for i = 1, 10 do
		self.bg_list[i] = self.node_list["Bg" .. i]
		self.bg_list[i]:SetActive(false)
	end

	self.shade_list = {}
	for i = 1, 10 do
		self.shade_list[i] = self.node_list["shade" .. i]
	end

	self.cell_list = {}
	for i = 1, GameEnum.RA_EXTREME_LUCKY_REWARD_COUNT do
		self.cell_list[i] = DrawItem.New(self.node_list["Item" .. i], self)
	end
	
	self.right_list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetRightListNumberOfCells, self)
	self.right_list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshRightListView, self)
	self.left_list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetLeftListNumberOfCells, self)
	self.left_list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshLeftListView, self)
	
end

function RareDialView:ReleaseCallBack()
	self.left_list_view_delegate = nil
	self.right_list_view_delegate = nil
	self.tweener1 = nil
	self.tweener2 = nil
	self.data = nil

	for k, v in pairs(self.left_cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.left_cell_list = nil 
	for k, v in pairs(self.right_cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.right_cell_list = nil

	for k, v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = nil

	if self.count then
		CountDown.Instance:RemoveCountDown(self.count)
		self.count = nil
	end
	if self.count1 then
		GlobalTimerQuest:CancelQuest(self.count1)
		self.count1 = nil
	end
end


function RareDialView:OpenCallBack()
	UI:SetButtonEnabled(self.node_list["BtnWare"], true)
	UI:SetButtonEnabled(self.node_list["BtnFlush"], true)
	UI:SetButtonEnabled(self.node_list["Btn_draw"], true)
	self:InitData()
end

function RareDialView:CloseCallBack()
	if nil ~= self.rotate_timer then
		GlobalTimerQuest:CancelQuest(self.rotate_timer)
	end
	RareDialCtrl.Instance:QuickFlush(false)
end

function RareDialView:OnFlush(type)
	self:InitData(type)
end

function RareDialView:CloseView()
	self:Close()
end

function RareDialView:OnClickLog()
	ActivityCtrl.Instance:SendActivityLogSeq(ACTIVITY_TYPE.RAND_ACTIVITY_SUPER_LUCKY_STAR)
end

function RareDialView:ShowFlushButton(state)
	self.node_list["BtnSop"]:SetActive(state)
	self.node_list["BtnQuickFlush"]:SetActive(not state)
end

function RareDialView:ClickDraw()
	local quick_flush_state = RareDialCtrl.Instance:QuickFlushState()
	if quick_flush_state then
		return
	end
	RareDialCtrl.Instance:SendInfo(RA_EXTREME_LUCKY_OPERA_TYPE.RA_EXTREME_LUCKY_OPERA_TYPE_DRAW)
end

function RareDialView:ClickFlush()
	local quick_flush_state = RareDialCtrl.Instance:QuickFlushState()
	if quick_flush_state then
		return
	end

	local flush_spend = self.flush_spend
	local str = string.format(Language.RareZhuanLun.FlushSpend, flush_spend)
	TipsCtrl.Instance:ShowCommonAutoView("rare_flush_spend", str, function ()
		RareDialCtrl.Instance:SendInfo(RA_EXTREME_LUCKY_OPERA_TYPE.RA_EXTREME_LUCKY_OPERA_TYPE_GLOD_FLUSH)
	end)
end

function RareDialView:ClickQuestion()
	local tips_id = 210    
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function RareDialView:ClickQuickFlush()
	ViewManager.Instance:Open(ViewName.ZhuanLunQucikFlushView)
end

function RareDialView:ClickStopFlush()
	RareDialCtrl.Instance:QuickFlush(false)
	self.node_list["BtnSop"]:SetActive(false)
	self.node_list["BtnQuickFlush"]:SetActive(true)
	RareDialData.Instance:ClearSelectIdTable()
end

function RareDialView:ClickWare()
	ViewManager.Instance:Open(ViewName.TipsTreasureWarehouseView)
end

function RareDialView:ClickCancel()
	self.is_cancel = not self.is_cancel
end


function RareDialView:GetLeftListNumberOfCells()
	return math.ceil(#self.rare_data / COLUMN)
end

function RareDialView:RefreshLeftListView(cell, data_index)
	local left_cell = self.left_cell_list[cell]
	if left_cell == nil then
		left_cell = RareRewardItem.New(cell.gameObject)
		self.left_cell_list[cell] = left_cell
	end
	for i = 1, COLUMN do
		local index = data_index * COLUMN + i
		local data = self.rare_data[index]
		self.left_cell_list[cell]:SetData(i, data)
	end
end

function RareDialView:GetRightListNumberOfCells()
	return #self.return_data
end

function RareDialView:RefreshRightListView(cell, data_index)
	local right_cell = self.right_cell_list[cell]
	if right_cell == nil then
		right_cell = RareAwardItem.New(cell.gameObject)
		self.right_cell_list[cell] = right_cell
	end
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local data = RareDialData.Instance:GetDrawReturnDataByOpenDay(open_day)
	self.right_cell_list[cell]:SetIndex(data_index)
	self.right_cell_list[cell]:SetData(data[data_index + 1])

end

function RareDialView:InitData(type)
	self:ConstructData()
end

function RareDialView:ConstructData()
	self.corrent_time = self.data:GetCurrentTimes() 
	self.gold_time = self.data:GetGoldTimes()
	self.draw_spend = self.data:GetDrawSpend(self.gold_time)
	self.flush_spend = self.data:GetFlushSpend()
	self.nest_time_num = self.data:GetNextTime() - TimeCtrl.Instance:GetServerTime()
	self.leiji_times = self.data:GetToTalTimes()
	self.free_times = self.data:GetFreeTimes()
	local now_time = TimeCtrl.Instance:GetServerTime()
	self.end_time = ActivityData.Instance:GetActivityStatus()[ACTIVITY_TYPE.RAND_ACTIVITY_SUPER_LUCKY_STAR].end_time - now_time
	self:SetDataView()
end 

function RareDialView:SetDataView()
	--self.node_list["TxtDraw"].text.text = self.corrent_time
	self.node_list["TxtDrawSpend"].text.text = self.draw_spend
	self.node_list["TxtFlushSpend"].text.text = self.flush_spend
	self.node_list["TxtFree"].text.text = string.format(Language.RareDial.FreeTimes, self.free_times)
	self.node_list["TxtDraw"].text.text = string.format(Language.RareDial.TotalTime, self.corrent_time, self.total_time)

	if self.count == nil then
		self.count = CountDown.Instance:AddCountDown(self.nest_time_num, 1, BindTool.Bind(self.FlushTimeView, self))
	else
		CountDown.Instance:RemoveCountDown(self.count)
		self.count = CountDown.Instance:AddCountDown(self.nest_time_num, 1, BindTool.Bind(self.FlushTimeView, self))
	end
	local data = self.data:GetItemInfoList()
	for k, v in pairs(self.cell_list) do
		v:SetData(data[k])
	end
	if self.total_time ~= nil and self.total_time == self.data:GetCurrentTimes() then
		UI:SetButtonEnabled(self.node_list["BtnWare"], false)
		UI:SetButtonEnabled(self.node_list["BtnFlush"], false)
		UI:SetButtonEnabled(self.node_list["Btn_draw"], false)

		GlobalTimerQuest:AddDelayTimer(function ()
			RareDialCtrl.Instance:SendInfo(RA_EXTREME_LUCKY_OPERA_TYPE.RA_EXTREME_LUCKY_OPREA_TYPE_AUTO_FLUSH)
			UI:SetButtonEnabled(self.node_list["BtnWare"], true)
			UI:SetButtonEnabled(self.node_list["BtnFlush"],true)
			UI:SetButtonEnabled(self.node_list["Btn_draw"],true)
		end, 1)
	end

	if self.count1 then
		GlobalTimerQuest:CancelQuest(self.count1)
		self.count1 = nil
	end

	local time_tab = TimeUtil.Format2TableDHMS(self.end_time)
	local RunTick = time_tab.day >= 1 and 60 or 1
	self:FlushUpdataActEndTime()
	self.count1 = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushUpdataActEndTime, self), RunTick)

	self.node_list["RightList"].scroller:RefreshAndReloadActiveCellViews(true)
	self:ShowDataView()
end

function RareDialView:FlushUpdataActEndTime()
	local time_tab = TimeUtil.Format2TableDHMS(self.end_time)
	if time_tab.day >= 1 then
		self.node_list["TxtEnd"].text.text = string.format(Language.JinYinTa.ActEndTime, time_tab.day, time_tab.hour)
	else
		self.node_list["TxtEnd"].text.text = string.format(Language.JinYinTa.ActEndTime2, time_tab.hour, time_tab.min, time_tab.s)
	end
	if self.end_time <= 0  then
		-- 移除计时器
		if self.count1 then
			GlobalTimerQuest:CancelQuest(self.count1)
			self.count1 = nil
		end
	end
end

function RareDialView:FlushTimeView()
	self.nest_time_num = self.nest_time_num - 1
	self.nest_time_time = TimeUtil.FormatSecond(self.nest_time_num - 1)
	self.node_list["TxtNextTime"].text.text = string.format(Language.RareDial.NestTime, self.nest_time_time)
end

function RareDialView:ShowDataView()
	self.node_list["ImgPointRed"]:SetActive(self.free_times > 0)
	self.node_list["RareDialImgGold"]:SetActive(not (self.free_times > 0) )
	self.node_list["TxtFree"]:SetActive(self.free_times > 0)
end

function RareDialView:FlushItem()
	for i = 1, 10 do
		self.cell_list[i].root_node.rect:SetLocalScale(1, 1, 1)
		local target_scale = Vector3(0, 1, 1)
		local target_scale2 = Vector3(1, 1, 1)

		self.tweener1 = self.cell_list[i].root_node.rect:DOScale(target_scale, 0.5)
		local func2 = function()
			self.tweener2 = self.cell_list[i].root_node.rect:DOScale(target_scale2, 0.5)
		end

		self.delay_timer2 = GlobalTimerQuest:AddDelayTimer(func2, 0.5)
	end
end

function RareDialView:FlushRightCell()
	self.node_list["RightList"].scroller:RefreshAndReloadActiveCellViews(true)
end

function RareDialView:PlayItemAnim(index)
	local data = self.data:GetItemInfoList()
	local item_obj = self.cell_list[index]:GetItemNode()
	local item_data = RareDialData.Instance:GetRewardBySeq(data[index].seq)
	local target_obj = self.node_list["BtnWare"]
	TipsCtrl.Instance:OpenMoveItemView(item_data.reward_item, item_obj, target_obj, 1, true, PUT_REASON_TYPE.PUT_REASON_ONLINE_REWARD)
end

function RareDialView:FlushAnimation()
	local index = self.now_index or 1
	local speed_index = index
	local result_index = self.data:GetResultIndex()
	if self.is_cancel then
		if nil == self.cell_list[result_index] then return end
		self.now_index = result_index

		self:PlayItemAnim(result_index)
		if nil ~= self.rotate_timer then
			GlobalTimerQuest:CancelQuest(self.rotate_timer)
		end
		self:InitData()
		for i = 1,10 do
			self.bg_list[i]:SetActive(result_index == i)
		end
		return
	else
		local loop_num = GameMath.Rand(2, 3)
		self.move_motion = function ()
			local quest = self.rotate_timer
			local quest_list = GlobalTimerQuest:GetRunQuest(quest)
			if nil == quest or nil == quest_list then return end
			if index == (loop_num * 10) + result_index then
				if nil == self.cell_list[result_index] then return end
				self.now_index = result_index

				self:PlayItemAnim(result_index)

				if nil ~= self.rotate_timer then
					GlobalTimerQuest:CancelQuest(self.rotate_timer)
					UI:SetButtonEnabled(self.node_list["BtnWare"], true)
					UI:SetButtonEnabled(self.node_list["BtnFlush"],true)
					UI:SetButtonEnabled(self.node_list["Btn_draw"],true)
					self:InitData()
				end
				return
			else
				local read_index = ((index + 1) == 10 and 10) or ((index + 1) % 10 == 0 and 10) or ((index + 1) % 10)
				for i = 1,10 do
					self.bg_list[i]:SetActive(read_index == i and not self.shade_list[i].gameObject.activeSelf)
				end
				-- 速度限制
				if index < speed_index + 3 then
					quest_list[2] = 0.1 -- 0.1 0.25 0.1 0.08
				elseif speed_index + 3 <= index and index <= speed_index + 6 then
					quest_list[2] = 0.1
				elseif index > ((loop_num * 10) + result_index) - 5 then
					quest_list[2] = 0.2
					if index > ((loop_num * 10) + result_index) - 2 then
						quest_list[2] = 0.3
					end
				else
					quest_list[2] = 0.08
				end
				index = index + 1
			end
		end

		if nil ~= self.rotate_timer then
			GlobalTimerQuest:CancelQuest(self.rotate_timer)
		end
		self.rotate_timer = GlobalTimerQuest:AddRunQuest(self.move_motion, 0.08)
		UI:SetButtonEnabled(self.node_list["BtnWare"], false)
		UI:SetButtonEnabled(self.node_list["BtnFlush"],false)
		UI:SetButtonEnabled(self.node_list["Btn_draw"],false)
	end
end

----------------------------------RareRewardItem-------------------------------------
RareRewardItem = RareRewardItem or BaseClass(BaseRender)

function RareRewardItem:__init()
	self.item_list = {}
	for i = 1, COLUMN do
		local item = self.node_list["Item" .. i]
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(item)
		table.insert(self.item_list,item_cell)
	end
   
end

function RareRewardItem:__delete()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list={}
end

function RareRewardItem:SetData(i,data)
	if nil == data then
		return
	end
	self.item_list[i]:SetData(data.reward_item)
	self.item_list[i]:ShowSpecialEffect(true)
	local bunble, asset = ResPath.GetItemActivityEffect()
	self.item_list[i]:SetSpecialEffect(bunble, asset)
end

----------------------------------RareAwardItem-------------------------------------
RareAwardItem = RareAwardItem or BaseClass(BaseRender)

function RareAwardItem:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["Item"])
end

function RareAwardItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
	end
end

function RareAwardItem:SetIndex(data_index)
	self.index = data_index
end

function RareAwardItem:SetData(data)
	local leiji_times = RareDialData.Instance:GetToTalTimes()
	self.node_list["TxtLeiji"].text.text = ToColorStr(leiji_times,TEXT_COLOR.GREEN_4).." / ".. data.draw_times
	local can_get = leiji_times >= data.draw_times

	self.node_list["ImgBase"]:SetActive(false)
	self.node_list["EffectShow"]:SetActive(false)
	self.node_list["TxtTimesTo"]:SetActive(true)
	self.node_list["TxtGet"]:SetActive(false)
	self.node_list["TxtLeiji"]:SetActive(true)
	self.node_list["BtnGet"]:SetActive(false)

	if RareDialData.Instance:GetFetchInfo(data.seq) == 1 then
		self.node_list["Imgnull"]:SetActive(true)
		self.node_list["ImgHaveGot"]:SetActive(true)
		self.node_list["TxtTimesTo"]:SetActive(false)
		self.node_list["TxtLeiji"]:SetActive(false)
	else
		self.node_list["Imgnull"]:SetActive(false)
		self.node_list["ImgHaveGot"]:SetActive(false)
		self.node_list["TxtTimesTo"]:SetActive(true)
		self.node_list["TxtLeiji"]:SetActive(true)
		local click_func = nil
		if can_get then
			click_func = function()
				self.item_cell:SetHighLight(false)
				RareDialCtrl.Instance:SendInfo(RA_EXTREME_LUCKY_OPERA_TYPE.RA_EXTREME_LUCKY_OPREA_TYPE_FETCH_REWARD, data.seq)
				RareDialCtrl.Instance:FetchAward()
				AudioService.Instance:PlayRewardAudio()
			end
		else
			click_func = function()
				TipsCtrl.Instance:OpenItem(data.reward_item)
				self.item_cell:SetHighLight(false)
			end
		end
		self.item_cell:ListenClick(click_func)
		if can_get then
			self.node_list["BtnGet"].button:AddClickListener(BindTool.Bind(click_func, self))
		end
	end
	self:ShowData(can_get and RareDialData.Instance:GetFetchInfo(data.seq) ~= 1)
	self.item_cell:SetData(data.reward_item)
end

function RareAwardItem:ShowData(is_show)
	if self.item_cell and is_show then
		self.item_cell:IsDestroyEffect(true)

		self.node_list["ImgBase"]:SetActive(true)
		self.node_list["EffectShow"]:SetActive(true)
		self.node_list["TxtTimesTo"]:SetActive(false)
		self.node_list["TxtLeiji"]:SetActive(false)
		self.node_list["TxtGet"]:SetActive(true)
		self.node_list["BtnGet"]:SetActive(true)
	end
end

------------------------------DrawItem-------------------------------
DrawItem = DrawItem or BaseClass(BaseRender)

function DrawItem:__init(instance, patent)
	self.patent = patent
	self.item = self.node_list["Item"]
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.item)
end

function DrawItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
	end

	self.patent = nil
end


function DrawItem:SetData(data)
	local reward_data = RareDialData.Instance:GetRewardBySeq(data.seq)
	local name = ItemData.Instance:GetItemName(reward_data.reward_item.item_id)
	self.item_cell:SetData(reward_data.reward_item)
	if reward_data.is_rare == 1 then
		self.item_cell:ShowSpecialEffect(true)
		local bunble, asset = ResPath.GetItemActivityEffect()
		self.item_cell:SetSpecialEffect(bunble, asset)
	else
		self.item_cell:ShowSpecialEffect(false)
	end
	self.node_list["TxtName"].text.text = name
	
	if tonumber(data.has_fetch) == 0 then
		self:ShowGet(false)
	else 
		self:ShowGet(true)
	end
end

function DrawItem:ShowGet(enable)
	self.node_list["ImgGet"]:SetActive(enable)
end

function DrawItem:GetItemNode()
	return self.item
end
