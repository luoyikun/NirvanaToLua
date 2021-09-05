ImageFulingWindowView = ImageFulingWindowView or BaseClass(BaseView)

function ImageFulingWindowView:__init()
	self.full_screen = false-- 是否是全屏界面
	self.ui_config = {{"uis/views/imagefuling_prefab", "FulingWindow"}}
	-- self.is_async_load = false
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end
function ImageFulingWindowView:LoadCallBack()
	self:InitScrollerWindow()
	self.old_data = nil
	self.select_stuff_cache_list = {}
	self.add_function = BindTool.Bind(self.AddSelectList, self)
	self.window_item_list = {}

	self.node_list["BtnUpLevel"].button:AddClickListener(BindTool.Bind(self.OnUpLevel, self))
	self.node_list["Btn1"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["ToggleSelect"].button:AddClickListener(BindTool.Bind(self.OnSelectAllItem, self))
end
function ImageFulingWindowView:OpenCallBack()
	self.last_flush_window_time = Status.NowTime
	
	self:OnFlushItemWindow()
end

function ImageFulingWindowView:CloseCallBack()
	self:ClearSelectList()
	self:OnFlushItemWindow()
end

function ImageFulingWindowView:__delete()
	self:RemoveWindowDelayTime()
end
function ImageFulingWindowView:ReleaseCallBack()
	for k,v in pairs(self.cell_window_list) do
		v:DeleteMe()
	end
	self.cell_window_list = {}
	self.window_enhanced_cell_type = nil
end

function ImageFulingWindowView:SetCurIndex(cur_fuling_type)
	self.cur_fuling_type = cur_fuling_type
end

function ImageFulingWindowView:OnFlushItemWindow()
	if self.last_flush_window_time + 0.1 <= Status.NowTime then
		self.last_flush_window_time = Status.NowTime
		
		self.window_item_list = ImageFuLingData.Instance:GetCanConsumeStuff(self.cur_fuling_type)
		if self.node_list["item_scroll"].scroller.isActiveAndEnabled then
			self.node_list["item_scroll"].scroller:RefreshAndReloadActiveCellViews(true)
		end
	else
		self.last_flush_window_time = Status.NowTime
		self:RemoveWindowDelayTime()
		self.window_delay_time = GlobalTimerQuest:AddDelayTimer(function() self:OnFlushItemWindow() end, 0.1)
	end
end

function ImageFulingWindowView:RemoveWindowDelayTime()
	if self.window_delay_time then
		GlobalTimerQuest:CancelQuest(self.window_delay_time)
		self.window_delay_time = nil
	end
end


function ImageFulingWindowView:InitScrollerWindow()
	self.cell_window_list = {}
	local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader")
	res_async_loader:Load("uis/views/guildview_prefab", "ItemCellPanel", nil, function (obj)
		if nil == obj then
			return
		end
		local enhanced_cell_type = obj:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))
		
		self.window_enhanced_cell_type = enhanced_cell_type
		self.node_list["item_scroll"].scroller.Delegate = ListViewDelegate()

		self.node_list["item_scroll"].scroller.Delegate.numberOfCellsDel = BindTool.Bind(self.GetWindowNumberOfCells, self)
		self.node_list["item_scroll"].scroller.Delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
		self.node_list["item_scroll"].scroller.Delegate.cellViewDel = BindTool.Bind(self.GetWindowCellView, self)
	end)
end

function ImageFulingWindowView:OnSelectAllItem()
	for k,v in pairs(self.window_item_list) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg then
			v.is_select = true
			self:AddSelectList(v, true)
		end
	end
	self:FlushHighLight()
end

function ImageFulingWindowView:ClearSelectList()
	for k,v in pairs(self.select_stuff_cache_list) do
		v.is_select = false
	end
	self.select_stuff_cache_list = {}
end

function ImageFulingWindowView:AddSelectList(data, switch)
	if data and data.item_id then
		self.select_stuff_cache_list[data] = switch and data or nil
	end
end

function ImageFulingWindowView:FlushHighLight()
	for k,v in pairs(self.cell_window_list) do
		v:FlushHighLight()
	end
end

function ImageFulingWindowView:GetWindowNumberOfCells()
	return 20
end

function ImageFulingWindowView:GetCellSize(data_index)
	return 96
end

function ImageFulingWindowView:GetWindowCellView(scroller, data_index, cell_index)
	local cell_view = scroller:GetCellView(self.window_enhanced_cell_type)
	local cell = self.cell_window_list[cell_view]
	if cell == nil then
		cell = FuLingScrollItemCell.New(cell_view)
		cell:SetClickFunc(self.add_function)
		self.cell_window_list[cell_view] = cell
	end
	local data = self:GetItemPanelData(self.window_item_list, data_index + 1, 4, 4)
	cell:SetData(data)
	return cell_view
end

function ImageFulingWindowView:GetItemPanelData(item_list, index, row, column)
	if not item_list then return end
	local index1 = math.floor(index / column)
	local index2 = index % column
	if index2 == 0 then
		index1 = index1 - 1
		index2 = column
	end
	local num = index1 * row * column
	local list = {}
	for i = 1, row do
		local index3 = index2 + (i - 1) * column + num
		list[i] = item_list[index3] or {}
	end
	return list
end

function ImageFulingWindowView:OnUpLevel()
	if nil == next(self.select_stuff_cache_list) then
		SysMsgCtrl.Instance:ErrorRemind(Language.MagicCard.InputUpgrade)
		return
	end

	for k,v in pairs(self.select_stuff_cache_list) do
		local stuff_cfg = ImageFuLingData.Instance:GetFuLingStuffItemConfig(self.cur_fuling_type, v.item_id)
		if nil ~= stuff_cfg then
			ImageFuLingCtrl.Instance:SendImgFuLingUpLevelReq(self.cur_fuling_type, stuff_cfg.stuff_index or 0)
		end
	end

	self:Close()
end

----------------------FuLingScrollItemCell --------------------------

FuLingScrollItemCell = FuLingScrollItemCell or BaseClass(BaseCell)

function FuLingScrollItemCell:__init()
	self.root_node.list_cell.refreshCell = BindTool.Bind(self.Flush, self)

	self.item_list = {}
	self.old_data = nil
	for i = 1, 4 do
		self.item_list[i] = {}
		self.item_list[i].cell = ItemCell.New()
		self.item_list[i].cell:SetInstanceParent(self.node_list["ItemCell" .. i])
		self.item_list[i].cell:IsDestroyEffect(true)
		local func = function ()
			if self.data[i].item_id == nil then
				self.item_list[i].cell:SetHighLight(false)
				return
			end
			TipsCtrl.Instance:OpenItem(self.data[i], self.form_type, nil, function() self.item_list[i].cell:SetHighLight(false) end)
		end
		self.item_list[i].cell:ListenClick(func)
	end
end

function FuLingScrollItemCell:__delete()
	for k,v in pairs(self.item_list) do
		if v.cell then
			v.cell:DeleteMe()
		end
	end
	self.item_list = {}
end

function FuLingScrollItemCell:SetToggleGroup(toggle_group)
	for i = 1, 4 do
		self.item_list[i].cell:SetToggleGroup(toggle_group)
	end
end

function FuLingScrollItemCell:OnFlush()
	for i = 1, 4 do
		local data = self.data[i]
		self:FLushCell(i, data)
	end
end

function FuLingScrollItemCell:FLushCell(i, data)
	self.item_list[i].cell:SetData(data)
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	local gamevo = GameVoManager.Instance:GetMainRoleVo()

	if data.item_id == nil and not data.locked then
		self.item_list[i].cell:SetInteractable(false)
	else
		self.item_list[i].cell:SetInteractable(true)
	end

	if self.data[i].is_select then
		self.item_list[i].cell:SetHighLight(true)
	else
		self.item_list[i].cell:SetHighLight(false)
	end
end

function FuLingScrollItemCell:SetClickFunc(func)
	if func then
		for i = 1, 4 do
			local cell = self.item_list[i].cell
			cell:ListenClick(BindTool.Bind(self.SelectFunc, self, i, func))
		end
	end
end

function FuLingScrollItemCell:SelectFunc(i, func)
	if self.data[i].item_id then
		if self.data[i].is_select then
			self.data[i].is_select = false
		else
			self.data[i].is_select = true
		end
		self.item_list[i].cell:SetHighLight(self.data[i].is_select)
		func(self.data[i], self.data[i].is_select)
	end
end

function FuLingScrollItemCell:FlushHighLight()
	for i = 1, 4 do
		local data = self.data[i]
		if data and data.is_select then
			self.item_list[i].cell:SetHighLight(true)
		else
			self.item_list[i].cell:SetHighLight(false)
		end
	end
end