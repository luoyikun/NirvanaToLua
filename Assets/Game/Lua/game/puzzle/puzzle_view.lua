require('game/puzzle/puzzle_item_render')

PuzzleView = PuzzleView or BaseClass(BaseView)
local MAX_PUZZLE = 40

local function ExchangeSortList(exchange_num, index)
	return function(a, b)
		local order_a = 100000
		local order_b = 100000
		if a[exchange_num] > b[exchange_num] then
			order_a = order_a + 1000
		elseif a[exchange_num] < b[exchange_num] then
			order_b = order_b + 1000
		else
			if a[index] < b[index] then
				order_a = order_a + 1000
			elseif a[index] > b[index] then
				order_b = order_b + 1000
			end
		end

		return order_a > order_b
	end
end

function PuzzleView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_1"},
		{"uis/views/randomact/puzzle_prefab", "PuzzleContent"},
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_2"},
	}
	self.play_audio = true

	self.puzzle_cell = {}
	self.exchange_cell = {}
	self.reward_cell = {}
	self.exchange_data = {}
	self.puzzle_data_list = {}
	self.select_index = nil
	self.is_modal = true
end

function PuzzleView:__delete()

end

function PuzzleView:ReleaseCallBack()

	self.exchange_data = {}

	self.puzzle_data_list = {}

	for k,v in pairs(self.puzzle_cell) do
		v:DeleteMe()
	end
	self.puzzle_cell = {}

	for k,v in pairs(self.exchange_cell) do
		v:DeleteMe()
	end
	self.exchange_cell = {}

	
	for k,v in pairs(self.reward_cell) do
		v:DeleteMe()
	end
	self.reward_cell = {}

	if self.puzzle_left_time then
		CountDown.Instance:RemoveCountDown(self.puzzle_left_time)
	end

	if self.puzzle_reset_time then
		CountDown.Instance:RemoveCountDown(self.puzzle_reset_time)
	end

end

-------------------回调---------------------
function PuzzleView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	-- self.node_list["ImgTitle"].image:LoadSprite("uis/views/randomact/puzzle/images_atlas","puzzle_title_word.png")
	-- self.node_list["ImgTitle"].transform:SetLocalPosition(70,-5,0)	--设置图片位置
	-- self.node_list["ImgTitle"].image:SetNativeSize()
	self.node_list["Name"].text.text = Language.Puzzle.Title
	-- 创建抽奖网格
	do
		local list_delegate = self.node_list["PuzzleList"].page_simple_delegate
		list_delegate.NumberOfCellsDel = BindTool.Bind(self.PuzzleGetNumberOfCells, self)
		list_delegate.CellRefreshDel = BindTool.Bind(self.PuzzleRefreshCell, self)
		self.node_list["PuzzleList"].list_view:JumpToIndex(0)
		self.node_list["PuzzleList"].list_view:Reload()
	end

	-- 创建兑换显示列表
	self:InitExchangeList()

	-- 创建保底显示列表
	self.reward_cell = {}
	local node_point = self.node_list["RewardView"]
	local count = 0

	for i = 1, 5 do
		local async_loader = AllocAsyncLoader(self, "item_loader" .. i)
		async_loader:Load("uis/views/randomact/puzzle_prefab", "PuzzleRewardItem", function(root_obj)
			if IsNil(root_obj) then
				return
			end
						
			local cell = PuzzleBaoDiItemRender.New(root_obj.gameObject)
			cell:SetInstanceParent(self.node_list["NodeItem" .. i].transform)
			count = count + 1
			self.reward_cell[i] = cell
			if count == 5 then
				self:FlushBaodiRender()
			end
		end)
	end

	-- 注册事件
	self:RegisterAllEvents()
end

-- 注册所有所需事件
function PuzzleView:RegisterAllEvents()
	self.node_list["BtnRestart"].button:AddClickListener(BindTool.Bind(self.OnClickBtnReset, self))
	self.node_list["BtnAuto"].button:AddClickListener(BindTool.Bind(self.OnClickBtnAutoFlip, self))
	self.node_list["Btnhelp"].button:AddClickListener(BindTool.Bind(self.OnClickBtnDescTip, self))
	self.node_list["BtnStore"].button:AddClickListener(BindTool.Bind(self.OnClickBtnCangKu, self))
	self.node_list["BtnAutoFind"].button:AddClickListener(BindTool.Bind(self.ClickOpenFastFlipView, self))
	self.node_list["BtnLucky"].button:AddClickListener(BindTool.Bind(self.OnClickLog, self))
end

function PuzzleView:OpenCallBack()
	PuzzleCtrl.Instance:SendReq()
	self:FlushFastFlipButtonText()
end

function PuzzleView:CloseCallBack()
	TipsCtrl.Instance:ChangeAutoViewAuto(false)
	TipsCommonAutoView.AUTO_VIEW_STR_T.puzzle_turn = nil
	self.select_index = nil
	PuzzleCtrl.Instance:CacleSendDelayTime()
	PuzzleCtrl.Instance:ClearData()
end

function PuzzleView:PuzzleGetNumberOfCells()
	return MAX_PUZZLE
end

function PuzzleView:PuzzleRefreshCell(index, cellObj)
	-- 构造Cell对象.

	local grid_index = math.floor(index / 8) * 8 + (8 - index % 8)
	local cell = self.puzzle_cell[grid_index]
	if nil == cell then
		cell = PuzzleFlipCellItemRender.New(cellObj)
		self.puzzle_cell[grid_index] = cell
	end
	-- 获取数据信息
	local data = self.puzzle_data_list[grid_index] or {}
	cell:SetIndex(grid_index)
	cell:SetData(data)
	cell:ShowHighLight(false)
	cell.node_list["PuzzleItem"].button:AddClickListener(BindTool.Bind(self.OnClickPuzzleFlipCellItemRender, self, cell))
	if self.select_index and (type(self.select_index) == "table" or grid_index == self.select_index) then
		cell:RunFilpAnim()
		if type(self.select_index) == "table" then
			table.insert(self.select_index, 1)
			if #self.select_index == MAX_PUZZLE then
				self.select_index = nil
			end
		else
			self.select_index = nil
		end
	end
end

function PuzzleView:OnClickPuzzleFlipCellItemRender(item)
	if item.data == nil or item.data.seq_type ~= 0 then return end
	local freetime = PuzzleData.Instance:GetCurFreeFlipTimes()
	
	local puzzle_gold = 20
	if freetime <= 0 then
		local str = string.format(Language.Puzzle.FlipNotice, puzzle_gold)
		TipsCtrl.Instance:ShowCommonAutoView("puzzle_turn", str, BindTool.Bind(self.FlipTheCell, self, item), nil, nil, nil, nil, nil, true)
	else
		self:FlipTheCell(item)
	end
end

function PuzzleView:OnClickLog()
	ActivityCtrl.Instance:SendActivityLogSeq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FANFAN)
end

-- 翻牌
function PuzzleView:FlipTheCell(view)
	self.select_index = view.index
	PuzzleCtrl.Instance:SendReq(RA_FANFAN_OPERA_TYPE.RA_FANFAN_OPERA_TYPE_FAN_ONCE, view.index - 1)
end

function PuzzleView:InitExchangeList()
	local delegate = self.node_list["ExchangeList"].list_simple_delegate
	-- 生成数量
	self.exchange_data = {}
	for i = 0, PuzzleData.Instance:GetWrodInfoCount() - 1 do
		table.insert(self.exchange_data, {index = i, exchange_num = PuzzleData.Instance:GetWrodExchangeNum(i) or 0})
	end
	table.sort(self.exchange_data, ExchangeSortList("exchange_num", "index"))
	PuzzleData.Instance:SetWordList(self.exchange_data)
	delegate.NumberOfCellsDel = function()
		return #self.exchange_data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.exchange_cell[cell]

		if nil == target_cell then
			self.exchange_cell[cell] =  RewardExchangeItemRender.New(cell.gameObject)
			target_cell = self.exchange_cell[cell]
			target_cell:SetToggleGroup(self.node_list["ExchangeList"].toggle_group)
		end
		target_cell:SetData(self.exchange_data[data_index])
		target_cell:ShowHighLight(false)
	end
end

-- 按下一键翻牌按钮事件
function PuzzleView:OnClickBtnAutoFlip()
	local price = 0
	for k,v in pairs(self.puzzle_cell) do
		if not v.is_front then price = price + PuzzleData.Instance:GetFlipConsume() end
	end
	price = math.max(0, price - PuzzleData.Instance:GetCurFreeFlipTimes() * PuzzleData.Instance:GetFlipConsume())
	local str = string.format(Language.Puzzle.AutoFlipNotice, price)
	TipsCtrl.Instance:ShowCommonAutoView("", str, BindTool.Bind1(self.OnAutoFlip, self))
end

-- 按下重置按钮事件
function PuzzleView:OnClickBtnReset()
	if PuzzleData.Instance:CanFanZhuan() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Puzzle.NeedClickToResert)
		return
	end

	local str = string.format(Language.Puzzle.ResetNotice, PuzzleData.Instance:GetResetConsume())
	TipsCtrl.Instance:ShowCommonAutoView("", str, BindTool.Bind1(self.OnResetAllCell, self))
end

-- 按下规则描述按钮事件
function PuzzleView:OnClickBtnDescTip()
	TipsCtrl.Instance:ShowHelpTipView(227)
end

function PuzzleView:OnClickBtnCangKu()
	ViewManager.Instance:Open(ViewName.TipsTreasureWarehouseView)
end

-- 一键翻牌
function PuzzleView:OnAutoFlip()
	self.select_index = {}
	PuzzleCtrl.Instance:SendReq(RA_FANFAN_OPERA_TYPE.RA_FANFAN_OPERA_TYPE_FAN_ALL, 1)
end

-- 重置翻牌
function PuzzleView:OnResetAllCell()
	self.select_index = {}
	PuzzleCtrl.Instance:SendReq(RA_FANFAN_OPERA_TYPE.RA_FANFAN_OPERA_TYPE_REFRESH, 1, -1)
end

-- 一键寻字
function PuzzleView:ClickOpenFastFlipView()
	local state = PuzzleData.Instance:GetFastFilpState()
	local flip_state = PuzzleData.Instance:GetFilpState()
	if not state and not flip_state then
		PuzzleCtrl.Instance:OpenFastFlipView()
	else
		PuzzleCtrl.Instance:EndFastFilp()
	end
end

function PuzzleView:FlushFastFlipButtonText()
	local state = PuzzleData.Instance:GetFastFilpState()
	self.node_list["TxtAutoFind"].text.text = state and Language.Puzzle.BtnText[2] or Language.Puzzle.BtnText[1]
	UI:SetButtonEnabled(self.node_list["BtnRestart"], not state)
	if not state == true then
		local price = 0
		for k,v in pairs(self.puzzle_cell) do
			if not v.is_front then price = price + PuzzleData.Instance:GetFlipConsume() end
		end
		price = math.max(0, price - PuzzleData.Instance:GetCurFreeFlipTimes() * PuzzleData.Instance:GetFlipConsume())
		if price == 0 then
			UI:SetButtonEnabled(self.node_list["BtnAuto"], false)
		else
			UI:SetButtonEnabled(self.node_list["BtnAuto"], true)
		end
	else
		UI:SetButtonEnabled(self.node_list["BtnAuto"], false)
	end
	UI:SetButtonEnabled(self.node_list["BtnStore"], not state)
end

function PuzzleView:SetSelectIndex()
	self.select_index = {}
end

-------------------行为---------------------

-- 刷新
function PuzzleView:OnFlush()
	self:FlushFlipPanel()
	self:FlushExchangeView()

	self:FlushMainInfo()
	self:FlushBaodiRender()
end

-- 刷新主面板面板
function PuzzleView:FlushMainInfo()
	local info_baodi_total = PuzzleData.Instance:GetBaodiTotal()
	self.node_list["TxtTurnTimes"].text.text = string.format(Language.Puzzle.BaodiTotal,  info_baodi_total or 0)
	self.node_list["TxtGold"].text.text = string.format(Language.Puzzle.TurnOneNeed, PuzzleData.Instance:GetFlipConsume())
	UI:SetButtonEnabled(self.node_list["BtnRestart"],  not(PuzzleData.Instance:GetResetConsume() == 0))
	self.node_list["TxtFreeTimes"].text.text = string.format(Language.Puzzle.FreeTimes, PuzzleData.Instance:GetCurFreeFlipTimes() or 0 .. "/" .. PuzzleData.Instance:GetAllFreeFlipTimes() or 0)
	self.node_list["TxtGold2"].text.text = PuzzleData.Instance:GetResetConsume()
	local act_cornucopia_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FANFAN) or {}
	if self.puzzle_left_time then
		CountDown.Instance:RemoveCountDown(self.puzzle_left_time)
	end
	if act_cornucopia_info and act_cornucopia_info.status == ACTIVITY_STATUS.OPEN then
		local next_time = act_cornucopia_info.next_time or 0
		self:UpdataRollerTime(TimeCtrl.Instance:GetServerTime(), next_time)
		self.puzzle_left_time = CountDown.Instance:AddCountDown(next_time, 1, BindTool.Bind1(self.UpdataRollerTime, self), BindTool.Bind1(self.CompleteRollerTime, self))
	else
		self:CompleteRollerTime()
	end

	local mul_time = PuzzleData.Instance:GetNextResetTime() - TimeCtrl.Instance:GetServerTime()
	if mul_time > 0 then
		if self.puzzle_reset_time then
			CountDown.Instance:RemoveCountDown(self.puzzle_reset_time)
		end
		self.node_list["TxtResetTime"].text.text = string.format(Language.Puzzle.RestartTime, TimeUtil.FormatSecond2HMS(mul_time))
		self.puzzle_reset_time = CountDown.Instance:AddCountDown(PuzzleData.Instance:GetNextResetTime(), 1, function(elapse_time, total_time)
			if total_time - TimeCtrl.Instance:GetServerTime() > 0 then
				self.node_list["TxtResetTime"].text.text = string.format(Language.Puzzle.RestartTime,TimeUtil.FormatSecond2HMS(total_time - TimeCtrl.Instance:GetServerTime()))
			end
		end,
		function() self.node_list["TxtResetTime"].text.text = string.format(Language.Puzzle.RestartTime, TimeUtil.FormatSecond2HMS(0)) 	end )
	else
		self.node_list["TxtResetTime"].text.text = string.format(Language.Puzzle.RestartTime,TimeUtil.FormatSecond2HMS(0))
	end
	self:FlushFastFlipButtonText()
end

-- 刷新翻转面板
function PuzzleView:FlushFlipPanel()
	self.puzzle_data_list = {}
	local is_flip_all = true
	for i = 0, GameEnum.RA_FANFAN_CARD_COUNT - 1 do
		local seq_type, info = PuzzleData.Instance:GetFlipCell(i)
		local data = {}
		data.seq_type = seq_type
		data.info = info
		self.puzzle_data_list[i + 1] = data

		if seq_type == 0 then is_flip_all = false end
	end
	UI:SetGraphicGrey(self.node_list["BtnAuto"], is_flip_all)

	for k,v in pairs(self.puzzle_cell) do
		if v.data == nil or v.data.seq_type ~= self.puzzle_data_list[k].seq_type then

			v:SetData(self.puzzle_data_list[k])
			if self.select_index and (type(self.select_index) == "table" or k == self.select_index) then
				v:RunFilpAnim()
				if type(self.select_index) == "table" then
					table.insert(self.select_index, 1)
					if #self.select_index == MAX_PUZZLE then
						self.select_index = nil
					end
				else
					self.select_index = nil
				end
			end
		
		end

	end
end

-- 刷新兑换列表
function PuzzleView:FlushExchangeView()
	self.exchange_data = {}
	for i = 0, PuzzleData.Instance:GetWrodInfoCount() - 1 do
		table.insert(self.exchange_data, {index = i, exchange_num = PuzzleData.Instance:GetWrodExchangeNum(i) or 0})
	end
	table.sort(self.exchange_data, ExchangeSortList("exchange_num", "index"))
	if self.node_list["ExchangeList"].scroller.isActiveAndEnabled then
		self.node_list["ExchangeList"].scroller:RefreshAndReloadActiveCellViews(true)
	end
	PuzzleData.Instance:SetWordList(self.exchange_data)
end

function PuzzleView:FlushBaodiRender()
	if #self.reward_cell < 5 then return end
	for k,v in pairs(self.reward_cell) do
		v:SetData(PuzzleData.Instance:GetBaoDiListCfg()[k])
	end
end

function PuzzleView:UpdataRollerTime(elapse_time, next_time)
	local time = next_time - TimeCtrl.Instance:GetServerTime()
	if time > 0 then
		local format_time = TimeUtil.Format2TableDHMS(time)
		local time_str = ""
		if format_time.day > 0 then
			time_str = string.format(Language.Activity.ActivityTime6, format_time.day, format_time.hour)
		else
			time_str = string.format(Language.Activity.ActivityTime5, format_time.hour, format_time.min, format_time.s)
		end
		self.node_list["TxtTime"].text.text = time_str
	end
end

function PuzzleView:CompleteRollerTime()
	self.node_list["TxtTime"].text.text = "00:00:00"
end
