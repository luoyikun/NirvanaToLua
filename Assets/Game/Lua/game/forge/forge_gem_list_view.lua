ForgeGemListView = ForgeGemListView or BaseClass(BaseView)

function ForgeGemListView:__init()
	self.ui_config = {
		-- {"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/forgeview_prefab", "GemList"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
	self.slot_index = 0
end

function ForgeGemListView:__delete()
end

function ForgeGemListView:ReleaseCallBack()
	for k, v in pairs(self.bag_gem_list) do
		v:DeleteMe()
	end
	self.bag_gem_list = {}
end

function ForgeGemListView:CloseCallBack()
	self.bag_gem_list_data = nil
	self.select_index = nil
	self.select_slot_index = nil
end

function ForgeGemListView:SetGemListData(data)
	if nil == data or nil == data.gem_list or nil == data.select_index or nil == data.select_slot_index then
		return
	end

	self.bag_gem_list_data = data.gem_list or {}
	self.select_index = data.select_index
	self.select_slot_index = data.select_slot_index
	self.replace_flag = data.replace_flag

	self:Open()
end

function ForgeGemListView:LoadCallBack()
	self.node_list["CloseBtn"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))

	self.bag_gem_list = {}
	local list_view_delegate = self.node_list["BagGemScroller"].list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshListView, self)
end

function ForgeGemListView:CloseWindow()
	self:Close()
end

function ForgeGemListView:OpenCallBack()
	self:Flush()
end

function ForgeGemListView:GetNumberOfCells()
	if self.bag_gem_list_data then
		return #self.bag_gem_list_data
	else
		return 0
	end
end

-- 背包宝石列表
function ForgeGemListView:RefreshListView(cell, cell_index)
	cell_index = cell_index + 1
	local item_cell = self.bag_gem_list[cell]
	if nil == item_cell then
		item_cell = GemScrollerCell.New(cell.gameObject)
		item_cell:SetClickCallBack(BindTool.Bind(self.OnClickGemListCell, self))
		self.bag_gem_list[cell] = item_cell
	end

	local data = self.bag_gem_list_data[cell_index]
	item_cell:SetIndex(cell_index)
	item_cell:SetSelectHL(cell_index == self.select_gem_list_index)
	item_cell:SetData(data)
end

function ForgeGemListView:OnClickGemListCell(gem_cell)
	local data = gem_cell:GetData()
	if nil == data then return end

	self.select_gem_bag_index = data.index
	self.select_gem_list_index = gem_cell:GetIndex()
	for k, v in pairs(self.bag_gem_list) do
		v:SetSelectHL(self.select_gem_list_index == v:GetIndex())
	end

	if nil == self.select_index or nil == self.select_slot_index or nil == self.select_gem_bag_index then
		return
	end

	if self.replace_flag then
		ForgeCtrl.Instance:SendStoneInlay(self.select_index, self.select_slot_index, 0, 0)
		self.replace_flag = false
	end

	ForgeCtrl.Instance:SendStoneInlay(self.select_index, self.select_slot_index, self.select_gem_bag_index, 1)	

	self:Close()
end

function ForgeGemListView:OnFlush()
	if self.node_list["BagGemScroller"] then
		self.node_list["BagGemScroller"].scroller:ReloadData(0)
	end
end




-----------------------------------------
-- 背包宝石 GemScrollerCell  obj_name:GemItem
GemScrollerCell = GemScrollerCell or BaseClass(BaseCell)
function GemScrollerCell:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.item_cell:ListenClick(function()
		self:OnClickCell()
	end)

	self.root_node.button:AddClickListener(BindTool.Bind(self.OnClickCell, self))
end

function GemScrollerCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
	end
end

function GemScrollerCell:OnFlush()
	self.item_cell:SetData(self.data)
	self.node_list["NameTxt"].text.text = self.data.cfg.name
end

function GemScrollerCell:OnClickCell()
	self.item_cell:SetHighLight(false)
	BaseCell.OnClick(self)
end

function GemScrollerCell:SetSelectHL(is_hl)
	self.node_list["HLBg"]:SetActive(is_hl)
end



