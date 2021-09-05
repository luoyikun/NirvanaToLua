ShengQiKillView = ShengQiKillView or BaseClass(BaseView)

local ROW_NUM = 5

function ShengQiKillView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/shenshouview_prefab", "ShengQiKillView"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.selete_item_list = {}
end

function ShengQiKillView:__delete()

end

function ShengQiKillView:ReleaseCallBack()
	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}
	self.selete_item_list = {}

	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
	self.item_data_event = nil
end

function ShengQiKillView:LoadCallBack()
	self.node_list["Btn_help"].button:AddClickListener(BindTool.Bind(self.ClickHelp, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Btn_fenjie"].button:AddClickListener(BindTool.Bind(self.ClickDecomposeBtn, self))
	self.node_list["Txt"].text.text = Language.ShenShou.ShengQiDecompose
	self.node_list["Bg"].rect.sizeDelta = Vector3(616, 474, 0)

	self.contain_cell_list = {}
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.item_data_event = BindTool.Bind(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
end

function ShengQiKillView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	self:Flush()
end

function ShengQiKillView:OpenCallBack()
	self:Flush()
end

function ShengQiKillView:OnFlush()
	self.selete_item_list = ShenShouData.Instance:GetShengQiDecomposeList()
	self.node_list["ListView"].scroller:ReloadData(0)
	self:FlushUI()
end

function ShengQiKillView:CloseCallBack()

end

function ShengQiKillView:GetNumberOfCells()
	local item_list = ShenShouData.Instance:GetShengQiDecomposeList()
	local row_num = math.ceil(#item_list / ROW_NUM)
	return row_num < 3 and 3 or row_num
end

function ShengQiKillView:RefreshCell(cell, cell_index)
	local item_list = ShenShouData.Instance:GetShengQiDecomposeList()
	
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = ShengQiKillGroup.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	for i = 1, ROW_NUM do
		local index = cell_index * ROW_NUM + i
		contain_cell:SetData(i, item_list[index])
		contain_cell:SetIndex(i, index, cell_index)
		contain_cell:ListenClick(i, BindTool.Bind(self.ClickItem, self, contain_cell, index))
		contain_cell:SetValue(i, nil ~= self.selete_item_list[index])
	end
end

function ShengQiKillView:ClickItem(cell, index)
	if self.selete_item_list[index] then
		self.selete_item_list[index] = nil
	else
		local item_list = ShenShouData.Instance:GetShengQiDecomposeList()
		self.selete_item_list[index] = item_list[index]
	end
	self:FlushUI()
end

function ShengQiKillView:FlushUI()
	local kill_cfg = ShenShouData.Instance:GetShengQiDecomposeCfg()
	if nil  == kill_cfg then return end

	local item_count_list = {}
	for k,v in pairs(kill_cfg) do
		if nil == item_count_list[v.return_item.item_id] then
			item_count_list[v.return_item.item_id] = 0
		end
	end

	for k,v in pairs(self.selete_item_list) do
		local item_id = kill_cfg[v].return_item.item_id
		item_count_list[item_id] = tonumber(kill_cfg[v].return_item.num) + item_count_list[item_id]
	end
	for k, v in pairs(item_count_list) do
		self.node_list["Txt_" .. k].text.text = v
	end

	for k,v in pairs(self.contain_cell_list) do
		for i = 1, ROW_NUM do
			local index = v.index * ROW_NUM + i
			v:SetValue(i, nil ~= self.selete_item_list[index])
		end
	end
end

function ShengQiKillView:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(283)
end

function ShengQiKillView:ClickDecomposeBtn()
	for k,v in pairs(self.selete_item_list) do
		ShenShouCtrl.Instance:SendShengQiEquipReq(ShenShouData.OpenType.OpenTypeDecompose, v, 1)
	end
end

----------------------------------------------------------------------
ShengQiKillGroup  = ShengQiKillGroup or BaseClass(BaseCell)
function ShengQiKillGroup:__init()
	self.item_list = {}
	for i = 1, ROW_NUM do
		self.item_list[i] = ShengQiKillItem.New(self.node_list["ShengQiKillCell" .. i])
	end
end

function ShengQiKillGroup:OnFlush()

end

function ShengQiKillGroup:__delete()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function ShengQiKillGroup:SetIndex(i, index, cell_index)
	self.index = cell_index
	self.item_list[i]:SetIndex(index)
end

function ShengQiKillGroup:SetData(index, data)
	self.item_list[index]:SetData(data)
end

function ShengQiKillGroup:GetData(index)
	return self.item_list[index].data
end

function ShengQiKillGroup:ListenClick(index, handler)
	self.item_list[index]:ListenClick(handler)
end

function ShengQiKillGroup:SetValue(index, value)
	self.item_list[index]:SetValue(value)
end

----------------------------------------------------------------------
ShengQiKillItem = ShengQiKillItem or BaseClass(BaseCell)
function ShengQiKillItem:__init()
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["Item"].gameObject)
	self.item:ListenClick(BindTool.Bind(self.OnClick, self))
end

function ShengQiKillItem:__delete()
	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end
end

function ShengQiKillItem:SetValue(value)
	self.node_list["Img_selected"]:SetActive(value)
end

function ShengQiKillItem:ListenClick(handler)
	self.node_list["ShengQiKillCell"].toggle:AddClickListener(handler)
end

function ShengQiKillItem:OnFlush()
	if self.data then
		local data = {item_id = self.data}
		self.item:SetData(data)
	else
		self.item:SetData({item_id = nil})
	end
end

function ShengQiKillItem:OnClick()

end