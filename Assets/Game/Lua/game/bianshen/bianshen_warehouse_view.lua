--变身仓库-BianShenWarehouseContent
BianShenWarehouseView = BianShenWarehouseView or BaseClass(BaseView)

local MAX_GRID_NUM = 120
local ROW = 4
local COLUMN = 6

function BianShenWarehouseView:__init(instance)
self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/bianshen_prefab", "BianShenWarehouseContent"},
	}
	
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.is_modal = true
	self.is_any_click_close = true
end

function BianShenWarehouseView:LoadCallBack(instance)
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.node_list["TakeOutBtn"].button:AddClickListener(BindTool.Bind(self.OnekeyTakeOutHandle, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Bg"].rect.sizeDelta = Vector3(710, 620, 0)
	self.node_list["Txt"].text.text = Language.BianShen.BianShenCangKu

	self.page_toggle_list = {}
	for i = 1, 5 do
		self.page_toggle_list[i] = self.node_list["PageToggle" .. i].toggle
	end

	self.show_toggle_list = {}
	for i = 6, 10 do
		self.show_toggle_list[i - 5] = self.node_list["PageToggle" .. i]
	end
	self.page_count = 5

	self.cell_list = {}
end

function BianShenWarehouseView:__delete()
	if self.cell_list ~= nil then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
	end
	
	self.cell_list = nil
	self.page_count = nil
end

function BianShenWarehouseView:ReleaseCallBack()
	for i = 1, 5 do
		self.page_toggle_list[i] = nil
	end
	self.page_toggle_list = {}
	
	for i = 6, 10 do
		self.show_toggle_list[i - 5] = nil
	end
	self.show_toggle_list = {}
end

function BianShenWarehouseView:GetNumOfCells()
	local item_list = BianShenData.Instance:GetHuntQingShenWarehouseList()
	local diff = #item_list - MAX_GRID_NUM
	local more_then_num = ((diff > 0)) and (math.ceil(diff / ROW / COLUMN)) or 0
	return (MAX_GRID_NUM + more_then_num * ROW * COLUMN) / ROW
end

function BianShenWarehouseView:RefreshCell(cell, data_index)
	local item_list = BianShenData.Instance:GetHuntQingShenWarehouseList()
	local group = self.cell_list[cell]
	if group == nil then
		group = BianShenItemGrop.New(cell.gameObject)
		group:SetToggleGroup(self.node_list["ListView"].toggle_group)
		self.cell_list[cell] = group
	end

	local page = math.floor(data_index / COLUMN)
	local column = data_index - page * COLUMN
	local grid_count = COLUMN * ROW
	for i = 1, ROW do
		local index = (i - 1) * COLUMN + column + (page * grid_count)
		local data = item_list[index + 1]
		data = data or {}
		if data.index == nil then
			data.index = index
		end
		group:SetData(i, data)
		group:ListenClick(i, BindTool.Bind(self.OnClickCell, self, data, group, i))
		group:SetInteractable(i, nil ~= data.item_id)
		group:SetHighLight(i, self.cur_index == index and nil ~= data.item_id)
	end
end

function BianShenWarehouseView:FlushBagView()
	if self.node_list["ListView"] then
		if self.node_list["ListView"].scroller.isActiveAndEnabled then
			local item_list = BianShenData.Instance:GetHuntQingShenWarehouseList()
			local diff = #item_list - MAX_GRID_NUM
			local more_then_num = ((diff > 0)) and (math.ceil(diff / ROW / COLUMN)) or 0
			local list_page_scroll = self.node_list["ListView"].list_page_scroll

			if more_then_num > 0 and more_then_num <= 5 then
				for i = 1, more_then_num do
					self.show_toggle_list[i]:SetActive(true)
				end
			else
				for i= 1, 5 do
					self.show_toggle_list[i]:SetActive(false)
				end
			end
			list_page_scroll:SetPageCount(more_then_num + 5)

			if self.page_count ~= (more_then_num + 5) then
				self.node_list["ListView"].scroller:ReloadData(0)
				if self.cur_index then
					local page = self.cur_index > 0 and (math.floor(self.cur_index / ROW / COLUMN) + 1) or 1
					if self.cur_index > 0 and self.cur_index % (ROW * COLUMN) == 0 then
						page = page - 1
					end
					list_page_scroll:JumpToPageImmidate(page)
					self.page_toggle_list[page].isOn = true
				end
			else
				self.node_list["ListView"].scroller:RefreshActiveCellViews()
			end

			self.cur_index = -1
			self.page_count = more_then_num + 5
		end
	end
end

function BianShenWarehouseView:OnFlush(param_list)
	self:FlushBagView()
end

function BianShenWarehouseView:OnClickCell(data, group, group_index)
	self.cur_index = data.index
	group:SetHighLight(group_index, self.cur_index == index)
	local close_call_back = function()
		self.cur_index = nil
		group:SetHighLight(group_index, false)
	end
	TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_BAOXIANG, nil, close_call_back)
end

function BianShenWarehouseView:OnekeyTakeOutHandle()
	TreasureCtrl.Instance:SendQuchuItemReq(0, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP, 1)
end

----------------------------------------------------------------------------------------------------------------
-- 仙宠仓库格子
BianShenItemGrop = BianShenItemGrop or BaseClass(BaseRender)

function BianShenItemGrop:__init(instance)
	self.cells = {}
	for i = 1, 4 do
		self.cells[i] = ItemCell.New()
		self.cells[i]:SetInstanceParent(self.node_list["Item" .. i])
	end
end

function BianShenItemGrop:__delete()
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}
end

function BianShenItemGrop:SetData(i, data)
	self.cells[i]:SetData(data)
end

function BianShenItemGrop:ListenClick(i, handler)
	self.cells[i]:ListenClick(handler)
end

function BianShenItemGrop:SetToggleGroup(toggle_group)
	for i = 1, 4 do
		self.cells[i]:SetToggleGroup(toggle_group)
	end
end

function BianShenItemGrop:SetHighLight(i, enable)
	self.cells[i]:SetHighLight(enable)
end

function BianShenItemGrop:ShowHighLight(i, enable)
	self.cells[i]:ShowHighLight(enable)
end

function BianShenItemGrop:SetInteractable(i, enable)
	self.cells[i]:SetInteractable(enable)
end

function BianShenItemGrop:SetToggle(i, enable)
	self.cells[i]:SetToggle(enable)
end