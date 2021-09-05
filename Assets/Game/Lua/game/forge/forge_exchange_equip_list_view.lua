ForgeExchangeEquipListView = ForgeExchangeEquipListView or BaseClass(BaseView)

function ForgeExchangeEquipListView:__init()
	self.ui_config = {
		{"uis/views/forgeview_prefab", "ComposeEquipList"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
end

function ForgeExchangeEquipListView:__delete()
end

function ForgeExchangeEquipListView:ReleaseCallBack()
	for k, v in pairs(self.bag_equip_list) do
		v:DeleteMe()
	end
	self.bag_equip_list = {}
	self.target_equip_list = {}
end

function ForgeExchangeEquipListView:CloseCallBack()

end

function ForgeExchangeEquipListView:SetListData(data)
	local target_equip = data.target_equip
	local target_attr_num = data.target_attr_num

	if nil == target_equip or nil == target_attr_num then
		return
	end
	local target_equip_cfg = ForgeData.Instance:GetTargetEquipExchangeCfg(target_equip, target_attr_num)
	local equip_cfg = ItemData.Instance:GetItemConfig(target_equip)
	if nil == target_equip_cfg or nil == equip_cfg then return end

	self.target_equip_list = ForgeData.Instance:GetExchangeMaterialEquipList(target_equip_cfg.color, target_equip_cfg.best_attr_count, equip_cfg.order)
	self.call_back = data.call_back

	self:Open()
end

function ForgeExchangeEquipListView:LoadCallBack()
	self.node_list["CloseBtn"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))

	self.bag_equip_list = {}
	local list_view_delegate = self.node_list["BagEquipScroller"].list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshListView, self)
end

function ForgeExchangeEquipListView:CloseWindow()
	self:Close()
end

function ForgeExchangeEquipListView:OpenCallBack()
	self:Flush()
end

function ForgeExchangeEquipListView:GetNumberOfCells()
	return #self.target_equip_list or 0
end

-- 背包玉石列表 
function ForgeExchangeEquipListView:RefreshListView(cell, cell_index)
	cell_index = cell_index + 1
	local item_cell = self.bag_equip_list[cell]
	if nil == item_cell then
		item_cell = EquipScrollerCell.New(cell.gameObject)
		item_cell:SetClickCallBack(BindTool.Bind(self.OnClickEquipListCell, self))
		self.bag_equip_list[cell] = item_cell
	end

	local data = self.target_equip_list[cell_index]
	item_cell:SetIndex(cell_index)
	-- item_cell:SetSelectHL(cell_index == self.select_jade_list_index)
	item_cell:SetData(data)
end

function ForgeExchangeEquipListView:OnClickEquipListCell(equip_cell)
	local data = equip_cell:GetData()
	if nil == data then return end

	-- self.select_jade_bag_index = data.index
	-- self.select_jade_list_index = equip_cell:GetIndex()
	-- for k, v in pairs(self.bag_equip_list) do
	-- 	v:SetSelectHL(self.select_jade_list_index == v:GetIndex())
	-- end
	if self.call_back then
		self.call_back(data)
		self.call_back = nil
	end

	self:Close()
end

function ForgeExchangeEquipListView:OnFlush()
	if self.node_list["BagEquipScroller"] then
		self.node_list["BagEquipScroller"].scroller:ReloadData(0)
	end
end




-----------------------------------------
-- 背包装备 EquipScrollerCell  obj_name:JadeItem
EquipScrollerCell = EquipScrollerCell or BaseClass(BaseCell)
function EquipScrollerCell:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.item_cell:SetFromView(TipsFormDef.FROM_FORGE_EXCHANGE)
	self.item_cell:ListenClick(function()
		self:OnClickCell()
	end)

	self.root_node.button:AddClickListener(BindTool.Bind(self.OnClickCell, self))
end

function EquipScrollerCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
	end
end

function EquipScrollerCell:OnFlush()
	self.item_cell:SetData(self.data)
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg then
		self.node_list["NameTxt"].text.text = item_cfg.name
	end
	
end

function EquipScrollerCell:OnClickCell()
	BaseCell.OnClick(self)
end

function EquipScrollerCell:SetSelectHL(is_hl)
	self.node_list["HLBg"]:SetActive(is_hl)
end

