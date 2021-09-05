-- 锻造 附灵（洗练）
ForgeClearItemListView = ForgeClearItemListView or BaseClass(BaseView)

function ForgeClearItemListView:__init()
	self.ui_config = {
		-- {"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/forgeview_prefab", "ClearItemList"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
	self.slot_index = 0
end

function ForgeClearItemListView:__delete()
end

function ForgeClearItemListView:ReleaseCallBack()
	for k, v in pairs(self.bag_item_list) do
		v:DeleteMe()
	end
	self.bag_item_list = {}
end

function ForgeClearItemListView:CloseCallBack()
	self.item_list_data = nil
end

function ForgeClearItemListView:SetListData(call_back)
	if call_back then
		self.call_back = call_back
	else
		return
	end
	self.item_list_data = ForgeData.Instance:GetHighClearItem()
	self:Open()
end

function ForgeClearItemListView:LoadCallBack()
	self.node_list["CloseBtn"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))

	self.bag_item_list = {}
	local list_view_delegate = self.node_list["ItemScroller"].list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshListView, self)
end

function ForgeClearItemListView:CloseWindow()
	self:Close()
end

function ForgeClearItemListView:OpenCallBack()
	self:Flush()
end

function ForgeClearItemListView:GetNumberOfCells()
	return #self.item_list_data or 0
end

function ForgeClearItemListView:RefreshListView(cell, cell_index)
	cell_index = cell_index + 1
	local item_cell = self.bag_item_list[cell]
	if nil == item_cell then
		item_cell = ClearItemScrollerCell.New(cell.gameObject)
		item_cell:SetClickCallBack(BindTool.Bind(self.OnClickListCell, self))
		self.bag_item_list[cell] = item_cell
	end

	local data = self.item_list_data[cell_index]
	item_cell:SetIndex(cell_index)
	item_cell:SetSelectHL(cell_index == self.select_list_index)
	item_cell:SetData(data)
end

function ForgeClearItemListView:OnClickListCell(cell)
	local data = cell:GetData()
	if nil == data then return end

	self.select_list_index = cell:GetIndex()
	for k, v in pairs(self.bag_item_list) do
		v:SetSelectHL(self.select_list_index == v:GetIndex())
	end

	self.call_back(data.item_id, data.color_seq)

	self:Close()
end

function ForgeClearItemListView:OnFlush()
	if self.node_list["ItemScroller"] then
		self.node_list["ItemScroller"].scroller:ReloadData(0)
	end
end




-----------------------------------------
-- 背包玉石 ClearItemScrollerCell  obj_name:JadeItem
ClearItemScrollerCell = ClearItemScrollerCell or BaseClass(BaseCell)
function ClearItemScrollerCell:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	-- self.item_cell:ListenClick(function()end)

	self.root_node.button:AddClickListener(BindTool.Bind(self.OnClickCell, self))
end

function ClearItemScrollerCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
	end
end

function ClearItemScrollerCell:OnFlush()
	if self.data and next(self.data) then
		self.item_cell:SetData(self.data)
		if self.data.count and self.data.count > 0 then
			self.item_cell:SetNum(self.data.count)
		end
		local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
		self.node_list["NameTxt"].text.text = item_cfg.name
	end
end

function ClearItemScrollerCell:OnClickCell()
	BaseCell.OnClick(self)
end

function ClearItemScrollerCell:SetSelectHL(is_hl)
	self.node_list["HLBg"]:SetActive(is_hl)
end

