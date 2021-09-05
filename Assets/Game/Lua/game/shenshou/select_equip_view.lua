
SelectEquipView = SelectEquipView or BaseClass(BaseView)

function SelectEquipView:__init()
	self.ui_config = {{"uis/views/shenshouview_prefab", "SelectEquipView"}}
	self.select_data = {}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function SelectEquipView:__delete()

end

function SelectEquipView:ReleaseCallBack()
	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = nil
end

function SelectEquipView:LoadCallBack()
	--self.node_list["ImgBg"].button:AddClickListener(BindTool.Bind(self.BackOnClick, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.BackOnClick, self))

	self.contain_cell_list = {}
	local list_delegate = self.node_list["equip_list"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function SelectEquipView:GetNumberOfCells()
	local data = self.select_data
	local demand_data = ShenShouData.Instance:GetSSEquinHechengItemData(data.compose_equip_best_attr_num, data.item_id)
	local equip_list = {}
	if demand_data then
		equip_list = ShenShouData.Instance:GetSSHechengEquipmentItemList(demand_data)
	end
	return #equip_list
end

function SelectEquipView:RefreshCell(cell, cell_index)
	local data = self.select_data
	local demand_data = ShenShouData.Instance:GetSSEquinHechengItemData(data.compose_equip_best_attr_num, data.item_id)
	local equip_list = ShenShouData.Instance:GetSSHechengEquipmentItemList(demand_data)

	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = ShenshouEquipContain.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	contain_cell:SetData(equip_list[cell_index])
	contain_cell:SetIndex(cell_index)
end

function SelectEquipView:OpenCallBack()
end

function SelectEquipView:CloseCallBack()

end

function SelectEquipView:ItemChange(item_id)
	self:Flush(nil, {item_id})
end

--关闭面板
function SelectEquipView:BackOnClick()
	ViewManager.Instance:Close(ViewName.ShenShouSelectEquip)
end

function SelectEquipView:ShowIndexCallBack(index)
	self.node_list["equip_list"].scroller:RefreshAndReloadActiveCellViews(true)
end


function SelectEquipView:SetHeChengData(select_data)
	self.select_data = select_data
end

ShenshouEquipContain = ShenshouEquipContain or BaseClass(BaseCell)

function ShenshouEquipContain:__init()
	self.item_cell = ShenShouEquip.New()
	self.item_cell:SetInstanceParent(self.node_list["item"])
	self.item_cell:ListenClick(BindTool.Bind(self.OnClick, self))

	self.node_list["ShenShouItem2"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function ShenshouEquipContain:OnClick()
	ShenShouComposeView.Instance:SetSShechengSelecIndexData(self.data)
	ViewManager.Instance:Close(ViewName.ShenShouSelectEquip)
end

function ShenshouEquipContain:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ShenshouEquipContain:OnFlush()
	self.item_cell:SetData(self.data)
	self.item_cell:SetShowStar(self.data.star_count)
	self.item_cell:Flush()
	local shenshou_equip_cfg = ShenShouData.Instance:GetShenShouEqCfg(self.data.item_id)
	self.node_list["TxtName"].text.text = ToColorStr(shenshou_equip_cfg.name, ITEM_COLOR[shenshou_equip_cfg.quality + 1])
	self.item_cell:SetHighLight(false)
end