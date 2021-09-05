-- 仙宠-猎取-仙宠仓库-WarehouseContent
SpiritWarehouseView = SpiritWarehouseView or BaseClass(BaseView)

local MAX_PAGE_COUNT = 10
local MAX_GRID_NUM = 320
local ROW = 4
local COLUMN = 8

function SpiritWarehouseView:__init(instance)
self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/spiritview_prefab", "WarehouseContent"},
	}
	
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.is_modal = true
	self.is_any_click_close = true
end

function SpiritWarehouseView:LoadCallBack(instance)

	self.list_view = self.node_list["ListView"]
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.node_list["RecoveryBtn"].button:AddClickListener(BindTool.Bind(self.OnClickRecovery, self))
	self.node_list["TakeOutBtn"].button:AddClickListener(BindTool.Bind(self.OnClickTakeOut, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Bg"].rect.sizeDelta = Vector3(870, 620, 0)
	self.node_list["Txt"].text.text = Language.JingLing.TabbarName[10]

	self.page_toggle_list = {}
	for i = 1, MAX_PAGE_COUNT do
		self.page_toggle_list[i] = self.node_list["PageToggle" .. i].toggle
	end

	self.page_count = MAX_PAGE_COUNT

	self.cell_list = {}
end

function SpiritWarehouseView:__delete()
	
end

function SpiritWarehouseView:OpenCallBack()
		-- 计算页数
	local num = self:GetNumOfCells()
	local count = math.ceil(num / COLUMN)
	for i = 1, MAX_PAGE_COUNT do
		if count < i then 
			self.node_list["PageToggle" .. i]:SetActive(false)
		else
			self.node_list["PageToggle" .. i]:SetActive(true)
		end
	end
	self.page_toggle_list[1].isOn = true
	self.list_view.list_page_scroll:SetPageCount(count)
	self.list_view.scroller:ReloadData(0)
	self:Flush()
end

function SpiritWarehouseView:ReleaseCallBack()
	if self.cell_list ~= nil then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
	end

	for i = 1, MAX_PAGE_COUNT do
		self.page_toggle_list[i] = nil
	end
	self.page_toggle_list = {}
	
	self.cell_list = nil
	self.page_count = nil
	self.list_view = nil
end

function SpiritWarehouseView:GetNumOfCells()
	return MAX_GRID_NUM / ROW
end

function SpiritWarehouseView:RefreshCell(cell, data_index)
	local item_list = SpiritData.Instance:GetHuntSpiritWarehouseList()
	local group = self.cell_list[cell]
	if group == nil then
		group = SpiritItemGroup.New(cell.gameObject)
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

function SpiritWarehouseView:FlushBagView()
	if self.node_list["ListView"] then
		if self.node_list["ListView"].scroller.isActiveAndEnabled then
			local item_list = SpiritData.Instance:GetHuntSpiritWarehouseList()
			local diff = #item_list - MAX_GRID_NUM
			local list_page_scroll = self.node_list["ListView"].list_page_scroll

			list_page_scroll:SetPageCount(MAX_PAGE_COUNT)

			if self.page_count ~= MAX_PAGE_COUNT then
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
			self.page_count = MAX_PAGE_COUNT
		end
	end
end

function SpiritWarehouseView:OnFlush(param_list)
	self:FlushBagView()
end

function SpiritWarehouseView:OnClickCell(data, group, group_index)
	self.cur_index = data.index
	group:SetHighLight(group_index, self.cur_index == index)
	local close_call_back = function()
		self.cur_index = nil
		group:SetHighLight(group_index, false)
	end
	TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_STORGE_ON_SPRITRT_STORGE, nil, close_call_back)
end

function SpiritWarehouseView:OnClickRecovery()
	local func1 = function ()
		SpiritCtrl.Instance:SendRecoverySpirit(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING, GameEnum.ITEM_COLOR_PURPLE)
	end
	if self.node_list["AutoPurple"].toggle.isOn then
		TipsCtrl.Instance:ShowCommonTip(func1, nil, Language.JingLing.OneKeyRecylePurple , nil, nil, false, false)
		return
	end
	local func2 = function ()
		SpiritCtrl.Instance:SendRecoverySpirit(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING, GameEnum.ITEM_COLOR_BLUE)
	end
	TipsCtrl.Instance:ShowCommonTip(func2, nil, Language.JingLing.OneKeyRecyle , nil, nil, false, false)
end

function SpiritWarehouseView:OnClickTakeOut()
	SpiritCtrl.Instance:SendTakeOutJingLingReq(-1, 1, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING)
end

----------------------------------------------------------------------------------------------------------------
-- 仙宠仓库格子
SpiritItemGroup = SpiritItemGroup or BaseClass(BaseRender)

function SpiritItemGroup:__init(instance)
	self.cells = {}
	for i = 1, 4 do
		self.cells[i] = ItemCell.New()
		self.cells[i]:SetInstanceParent(self.node_list["Item" .. i])
	end
end

function SpiritItemGroup:__delete()
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}
end

function SpiritItemGroup:SetData(i, data)
	self.cells[i]:SetData(data)
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(data.item_id)
	if item_cfg then
		if item_cfg.color == GameEnum.ITEM_COLOR_ORANGE then
			self.cells[i]:ShowZhuanzhiEquipOrangeEffect(true)
		end
	end
end

function SpiritItemGroup:ListenClick(i, handler)
	self.cells[i]:ListenClick(handler)
end

function SpiritItemGroup:SetToggleGroup(toggle_group)
	for i = 1, 4 do
		self.cells[i]:SetToggleGroup(toggle_group)
	end
end

function SpiritItemGroup:SetHighLight(i, enable)
	if self.cells and self.cells[i] then
		self.cells[i]:SetHighLight(enable)
	end
end

function SpiritItemGroup:ShowHighLight(i, enable)
	self.cells[i]:ShowHighLight(enable)
end

function SpiritItemGroup:SetInteractable(i, enable)
	self.cells[i]:SetInteractable(enable)
end

function SpiritItemGroup:SetToggle(i, enable)
	self.cells[i]:SetToggle(enable)
end