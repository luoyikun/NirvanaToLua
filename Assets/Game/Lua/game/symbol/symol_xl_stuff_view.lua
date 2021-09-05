-- 幻灵界面弹出 SelectStuffView
SymbolXilianStuffView = SymbolXilianStuffView or BaseClass(BaseView)

function SymbolXilianStuffView:__init()
	self.ui_config = {{"uis/views/hunqiview_prefab", "SelectStuffView"}}
	self.select_data = {}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function SymbolXilianStuffView:__delete()

end

function SymbolXilianStuffView:ReleaseCallBack()
	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end

	self.contain_cell_list = nil
end

function SymbolXilianStuffView:SetData(call_back)
	self.call_back = call_back
	self:Open()
end

function SymbolXilianStuffView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.BackOnClick, self))

	self.contain_cell_list = {}

	local list_delegate = self.node_list["list"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function SymbolXilianStuffView:GetNumberOfCells()
	local consume_list = SymbolData.Instance:GetSymbolXiLianStuffList()
	return #consume_list
end

function SymbolXilianStuffView:RefreshCell(cell, cell_index)
	local consume_list = SymbolData.Instance:GetSymbolXiLianStuffList()
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = SymbolXilianItem.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
		contain_cell.parent = self
	end
	cell_index = cell_index + 1
	contain_cell:SetData(consume_list[cell_index])
	contain_cell:SetIndex(cell_index)
end

function SymbolXilianStuffView:OpenCallBack()
	self.node_list["list"].scroller:RefreshAndReloadActiveCellViews(true)
end

function SymbolXilianStuffView:CloseCallBack()

end

--关闭面板
function SymbolXilianStuffView:BackOnClick()
	self:Close()
end

function SymbolXilianStuffView:SetHeChengData(select_data)
	self.select_data = select_data
end

function SymbolXilianStuffView:OnSelect(data)
	if self.call_back then
		self.call_back(data)
	end
	self:Close()
end

-------------------------------SelectItem-------------------------------------
SymbolXilianItem = SymbolXilianItem or BaseClass(BaseCell)

function SymbolXilianItem:__init()
	self.node_list["Btn"].button:AddClickListener(BindTool.Bind(self.OnClickSelect, self))
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["item"])
end

function SymbolXilianItem:OnClickSelect()
	self.parent:OnSelect(self.data)
end

function SymbolXilianItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	self.parent = nil
end

function SymbolXilianItem:OnFlush()
	if not self.data then
		return
	end
	self.item_cell:SetData(self.data.consume_item)
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.consume_item.item_id)
	self.node_list["TxtName"].text.text = ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color])
	self.node_list["TxtDesc"].text.text = (string.format(Language.HunQi.MaxStarNum, self.data.max_star_number - 1))
	self.item_cell:SetHighLight(false)
	local num = ItemData.Instance:GetItemNumInBagById(self.data.consume_item.item_id)
	self.item_cell:SetNum(num)
	self.item_cell:SetItemNumVisible(true)
	self.item_cell:SetItemNum(num)
end