-- 聊天中弹出的道具展示
TipsShowProView = TipsShowProView or BaseClass(BaseView)

local MAX_CELL_NUM = 400
local PRO_COLUMN = 5
local PRO_ROW = 5
local PRO_MAX = 5
local SHOW_EQUIP = 1
local SHOW_PROP = 2

function TipsShowProView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/tips/chattips_prefab", "ShowView"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.view_layer = UiLayer.Pop
	self.show_state = SHOW_PROP
	self.play_audio = true
	self.bag_data = {}
end

function TipsShowProView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(580,640,0)
	self.select_index = -1			-- 记录已选择格子位置
	self:GetBagData()
	self.node_list["BtnPro"].toggle:AddClickListener(BindTool.Bind(self.OnClickProButton, self))
	self.node_list["BtnEquip"].toggle:AddClickListener(BindTool.Bind(self.OnClickEquipButton, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickCloseButton, self))
	self.node_list["Txt"].text.text = Language.Chat.BagPackagePanelName
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.cell_list = {}
	self.equip_group_cell_list = {}

	self.equip_cells = {}
	for i = 1, PRO_MAX do
		self.equip_cells[i] = self.node_list["EquipPropObj"..i]
	end
end

function TipsShowProView:ReleaseCallBack()

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for k, v in pairs(self.equip_group_cell_list) do
		v:DeleteMe()
	end
	self.equip_group_cell_list = {}
	self.bag_data = nil
end

function TipsShowProView:GetNumberOfCells()
	return MAX_CELL_NUM / PRO_ROW
end

function TipsShowProView:OpenCallBack()
	self.node_list["BtnPro"].toggle.isOn = true
	self:GetBagData()
	self:OnClickProButton()
end

function TipsShowProView:CloseCallBack()
	self.show_state = SHOW_PROP
	self.select_index = -1
end

function TipsShowProView:RefreshCell(cell, data_index)
	-- 构造Cell对象
	local group = self.cell_list[cell]
	if nil == group then
		group = ChatShowProViewItem.New(cell.gameObject)
		group.tips_view = self
		group:SetToggleGroup(self.node_list["ListView"].toggle_group)
		self.cell_list[cell] = group
	end

	local page = math.floor(data_index / PRO_COLUMN)
	local column = data_index - page * PRO_COLUMN
	local grid_count = PRO_COLUMN * PRO_ROW
	for i = 1, PRO_ROW do
		local index = (i - 1) * PRO_COLUMN  + column + (page * grid_count)
		local data = nil
		data = self.bag_data[index + 1]
		data = data or {}
		data.locked = index >= ItemData.Instance:GetMaxKnapsackValidNum()
		if nil == data.index then
			data.index = index
		end
		group:SetData(i, data)

		group:SetInteractable(i, true)
		if not data.item_id or data.item_id == 0 then
			group:SetInteractable(i, false)
		end

		group:ListenClick(i, BindTool.Bind(self.HandleItemOnClick, self, data, group, i))
	end
end

function TipsShowProView:HandleItemOnClick(data, group, group_index)
	if self.select_index ~= data.index then
		self.select_index = data.index
	end
	if data.item_id then
		ChatCtrl.Instance:SetChatViewData(data)
		ChatCtrl.Instance:SetGuildViewData(data)
	end
end

function TipsShowProView:OnClickProButton()
	self.show_state = SHOW_PROP
	self.node_list["ListView"]:SetActive(true)
	self.node_list["PanelPageToggles"]:SetActive(true)
	self.node_list["PanelShowEquip"]:SetActive(false)
	self:FlushBagView()
	self.current_page = 1
end

function TipsShowProView:OnClickEquipButton()
	self.show_state = SHOW_EQUIP
	self.node_list["ListView"]:SetActive(false)
	self.node_list["PanelPageToggles"]:SetActive(false)
	self.node_list["PanelShowEquip"]:SetActive(true)
	local temp_equip_list = {}

	for k, v in pairs(ForgeData.Instance:GetZhuanzhiEquipAll()) do
		if v.item_id > 0 then
			table.insert(temp_equip_list, v)
		end
	end

	for k, v in pairs(self.equip_cells) do
		local group = self.equip_group_cell_list[v]
		if nil == group then
			group = ChatShowProViewItem.New(v)
			group.tips_view = self
			group:SetToggleGroup(self.node_list["ListView"].toggle_group)
			self.equip_group_cell_list[v] = group
		end
		local page = math.floor((k - 1) / PRO_COLUMN)
		local column = k - page * PRO_COLUMN - 1
		local grid_count = PRO_COLUMN * PRO_ROW

		for i = 1, PRO_ROW do
			local index = (i - 1) * PRO_COLUMN  + column + (page * grid_count)
			local data = nil
			data = temp_equip_list[index + 1]
			data = data or {}

			group:SetInteractable(i, true)
			if not next(data) then
				group:SetInteractable(i, false)
			end

			group:SetData(i, data)
			group:ListenClick(i, BindTool.Bind(self.OnClickEquipItem, self, data, group, i))
		end
	end
end

function TipsShowProView:OnClickEquipItem(data, group, group_index)
	ChatCtrl.Instance:SetChatViewData(data, true)
	ChatCtrl.Instance:SetGuildViewData(data, true)
end

function TipsShowProView:OnClickCloseButton()
	self:Close()
end

function TipsShowProView:GetBagData()
	self.bag_data = {}
	local data = ItemData.Instance:GetBagItemDataList()
	for k, v in pairs(data) do
		if v ~= nil and v.item_id ~= nil then
			table.insert(self.bag_data, v)
		end
	end
end

function TipsShowProView:FlushBagView()
	self:GetBagData()
	self.node_list["ListView"].scroller:RefreshActiveCellViews()
end

----------------------------------------------------------------------
ChatShowProViewItem = ChatShowProViewItem or BaseClass(BaseRender)

function ChatShowProViewItem:__init()
	self.cells = {}
	for i = 1, PRO_ROW do
		local item_obj = ItemCell.New()
		item_obj:SetInstanceParent(self.node_list["Item" .. i])
		item_obj:ShowHighLight(false)
		self.cells[i] = item_obj
	end
end

function ChatShowProViewItem:__delete()
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}
	self.tips_view = nil
end

function ChatShowProViewItem:SetData(i, data)
	if self.tips_view.show_state and self.tips_view.show_state == SHOW_EQUIP then
		self.cells[i]:SetFromView(nil)
	else
		self.cells[i]:SetFromView(TipsFormDef.FROM_BAG)
	end
	self.cells[i]:SetData(data)
	
	if self.tips_view.show_state == SHOW_PROP then
		if self.cells[i].root_node.toggle.isOn and data.index ~= self.tips_view.select_index then
			self.cells[i].root_node.toggle.isOn = false
		elseif not self.cells[i].root_node.toggle.isOn and data.index == self.tips_view.select_index then
			self.cells[i].root_node.toggle.isOn = true
		end
	end
end

function ChatShowProViewItem:ListenClick(i, handler)
	self.cells[i]:ListenClick(handler)
end

function ChatShowProViewItem:SetToggleGroup(toggle_group)
	for k,v in pairs(self.cells) do
		v:SetToggleGroup(toggle_group)
	end
end

function ChatShowProViewItem:SetInteractable(i, value)
	self.cells[i]:SetInteractable(value)
end
