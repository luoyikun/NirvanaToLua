ForgeJadeListView = ForgeJadeListView or BaseClass(BaseView)

function ForgeJadeListView:__init()
	self.ui_config = {
		-- {"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/forgeview_prefab", "JadeList"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
	self.slot_index = 0
end

function ForgeJadeListView:__delete()
end

function ForgeJadeListView:ReleaseCallBack()
	for k, v in pairs(self.bag_jade_list) do
		v:DeleteMe()
	end
	self.bag_jade_list = {}
end

function ForgeJadeListView:CloseCallBack()
	self.bag_jade_list_data = nil
	self.select_index = nil
	self.select_slot_index = nil
end

function ForgeJadeListView:SetJadeListData(data)
	if nil == data or nil == data.jade_list or nil == data.select_index or nil == data.select_slot_index then
		return
	end

	self.bag_jade_list_data = data.jade_list or {}
	self.select_index = data.select_index
	self.select_slot_index = data.select_slot_index

	self:Open()
end

function ForgeJadeListView:LoadCallBack()
	self.node_list["CloseBtn"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))

	self.bag_jade_list = {}
	local list_view_delegate = self.node_list["BagJadeScroller"].list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshListView, self)
end

function ForgeJadeListView:CloseWindow()
	self:Close()
end

function ForgeJadeListView:OpenCallBack()
	self:Flush()
end

function ForgeJadeListView:GetNumberOfCells()
	return #self.bag_jade_list_data or 0
end

-- 背包玉石列表 
function ForgeJadeListView:RefreshListView(cell, cell_index)
	cell_index = cell_index + 1
	local item_cell = self.bag_jade_list[cell]
	if nil == item_cell then
		item_cell = JadeScrollerCell.New(cell.gameObject)
		item_cell:SetClickCallBack(BindTool.Bind(self.OnClickJadeListCell, self))
		self.bag_jade_list[cell] = item_cell
	end

	local data = self.bag_jade_list_data[cell_index]
	item_cell:SetIndex(cell_index)
	item_cell:SetSelectHL(cell_index == self.select_jade_list_index)
	item_cell:SetData(data)
end

function ForgeJadeListView:OnClickJadeListCell(jade_cell)
	local data = jade_cell:GetData()
	if nil == data then return end

	self.select_jade_bag_index = data.index
	self.select_jade_list_index = jade_cell:GetIndex()
	for k, v in pairs(self.bag_jade_list) do
		v:SetSelectHL(self.select_jade_list_index == v:GetIndex())
	end

	ForgeCtrl.Instance:SendCSZhuanzhiEquipOpe(ZHUANZHI_EQUIP_OPERATE_TYPE.ZHUANZHI_EQUIP_OPERATE_TYPE_INLAY_STONE, self.select_index, self.select_slot_index, self.select_jade_bag_index)

	self:Close()
end

function ForgeJadeListView:OnFlush()
	if self.node_list["BagJadeScroller"] then
		self.node_list["BagJadeScroller"].scroller:ReloadData(0)
	end
end




-----------------------------------------
-- 背包玉石 JadeScrollerCell  obj_name:JadeItem
JadeScrollerCell = JadeScrollerCell or BaseClass(BaseCell)
function JadeScrollerCell:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.item_cell:ListenClick(function()
		self:OnClickCell()
	end)

	self.root_node.button:AddClickListener(BindTool.Bind(self.OnClickCell, self))
end

function JadeScrollerCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
	end
end

function JadeScrollerCell:OnFlush()
	self.item_cell:SetData(self.data)
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg then
		self.node_list["NameTxt"].text.text = item_cfg.name
	end
	
end

function JadeScrollerCell:OnClickCell()
	BaseCell.OnClick(self)
end

function JadeScrollerCell:SetSelectHL(is_hl)
	self.node_list["HLBg"]:SetActive(is_hl)
end

