ZhuanLunQucikFlushView = ZhuanLunQucikFlushView or BaseClass(BaseView)

function ZhuanLunQucikFlushView:__init(  )
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/zhenxizhuanlun_prefab", "ZhuanLunFlushView"}
	}
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function ZhuanLunQucikFlushView:__delete()

end

function ZhuanLunQucikFlushView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(695, 545, 0)
	self.node_list["Txt"].text.text = Language.RareZhuanLun.TipTitle
	local list_delegate = self.node_list["listview"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.rush_item = {}

	self.node_list["BtnCancel"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnStart"].button:AddClickListener(BindTool.Bind(self.ClickStart, self))
end

function ZhuanLunQucikFlushView:ReleaseCallBack()
	for k,v in pairs(self.rush_item) do
		v:DeleteMe()
	end
	self.rush_item = {}
end

function ZhuanLunQucikFlushView:CloseWindow()
	RareDialData.Instance:ClearSelectIdTable()
	self:Close()
end

function ZhuanLunQucikFlushView:OpenCallBack()
	for k, v in pairs(self.rush_item) do
		v:SetHighLight(false)
	end
end

function ZhuanLunQucikFlushView:CloseCallBack()

end

function ZhuanLunQucikFlushView:GetNumberOfCells()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local rare_data = RareDialData.Instance:GetDrawDataRareByOpenDay(open_day) or {}
	local num = #rare_data or 0

	return math.ceil(num / 2)
end

function ZhuanLunQucikFlushView:RefreshCell(cell, cell_index)
	local record_cell = self.rush_item[cell]
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local rare_data = RareDialData.Instance:GetDrawDataRareByOpenDay(open_day) or {}
	if record_cell == nil then
		record_cell = ZhuanLunQucikFlushInfo.New(cell.gameObject)
		self.rush_item[cell] = record_cell
	end

	for i = 1, 2 do
		local index = cell_index * 2 + i
		local data = rare_data[index]
		if data then
			self.rush_item[cell]:SetIndex(index, i)
			self.rush_item[cell]:SetData(data, i)
			self.rush_item[cell]:SetActive(true, i)
			self.rush_item[cell]:SetToggleGroup(self.node_list["listview"].toggle_group, i)
			-- print_error(self.rush_item[cell].cell_list[i].index, self.rush_item[cell].cell_list[i].root_node.toggle.isOn)
		else
			self.rush_item[cell]:SetActive(false, i)
		end
	end

end

function ZhuanLunQucikFlushView:ClickStart()
	local state = RareDialData.Instance:IsHasSelectId()
	local need_money = RareDialData.Instance:GetFlushSpend() or 20
	local role_info = GameVoManager.Instance:GetMainRoleVo()

	if state and role_info.gold >= need_money then
		RareDialCtrl.Instance:ShowQuickFlush(true)
		RareDialCtrl.Instance:QuickFlush(true)
		self:Close()
	elseif state and role_info.gold < need_money then
		TipsCtrl.Instance:ShowLackDiamondView()

	elseif not state then
		SysMsgCtrl.Instance:ErrorRemind(Language.RareZhuanLun.QuickFlsuh)
	end
end


ZhuanLunQucikFlushInfo = ZhuanLunQucikFlushInfo or BaseClass(BaseRender)

function ZhuanLunQucikFlushInfo:__init(  )
	self.cell_list = {}
	for i = 1, 2 do
		local cell = ZhuanLunQucikFlushItem.New(self.node_list["Item" .. i])
		table.insert(self.cell_list, cell)
	end
end

function ZhuanLunQucikFlushInfo:__delete()
	for k, v in ipairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function ZhuanLunQucikFlushInfo:SetToggleGroup(group, i)
	self.node_list["Item" .. i].toggle.group = group
end

function ZhuanLunQucikFlushInfo:SetHighLight(value)
	for i = 1, 2 do
		self.cell_list[i]:SetHighLight(value)
	end
end

function ZhuanLunQucikFlushInfo:SetActive(active, i)
	self.node_list["Item" .. i]:SetActive(active)
end

function ZhuanLunQucikFlushInfo:SetIndex(index, i)
	self.cell_list[i]:SetIndex(index)
end

function ZhuanLunQucikFlushInfo:SetData(data, i)
	-- if data then
		self.cell_list[i]:SetData(data)
	-- else
	-- 	self.node_list["Item" .. i]:SetActive(false)
	-- end
end


ZhuanLunQucikFlushItem = ZhuanLunQucikFlushItem or BaseClass(BaseCell)

function ZhuanLunQucikFlushItem:__init(  )
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.item_cell:ShowHighLight(false)

	self.node_list["ToggleImg"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.item_id = 0
	self.item_seq = -1
end

function ZhuanLunQucikFlushItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
	end
end

function ZhuanLunQucikFlushItem:SetData(data)
	if nil == data then 
		return 
	end
	self.item_id = data.reward_item.item_id
	self.item_seq = data.seq
	local item_info = ItemData.Instance:GetItemConfig(self.item_id)
	local item_name = ToColorStr(item_info.name, ITEM_COLOR[item_info.color])
	self.node_list["TxtName"].text.text = item_name
	self.node_list["TxtNameSelect"].text.text = item_name
	self.item_cell:SetData(data.reward_item)
	local select_list = RareDialData.Instance:GetSelectIdTable()
	for k, v in pairs(select_list) do
		if k == self.item_seq and v == true then
			self.node_list["HL"]:SetActive(true)
			break
		else
			self.node_list["HL"]:SetActive(false)
		end
	end

end

function ZhuanLunQucikFlushItem:OnClick()
	if self.root_node.toggle.isOn then
		self.node_list["HL"]:SetActive(true)
		RareDialData.Instance:InsertSelectId(self.item_seq)
	else
		self.node_list["HL"]:SetActive(false)
		RareDialData.Instance:RemoveSelectId(self.item_seq)
	end
end

function ZhuanLunQucikFlushItem:SetHighLight(state)
	self.root_node.toggle.isOn = state
end