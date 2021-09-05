WarehouseView = WarehouseView or  BaseClass(BaseRender)

-- 常亮定义
local BAG_MAX_GRID_NUM = 150			-- 最大格子数
local BAG_PAGE_NUM = 6					-- 页数
local BAG_PAGE_COUNT = 25				-- 每页格子数
local BAG_ROW = 5						-- 行
local BAG_COLUMN = 5					-- 列

local BAG_SHOW_STORGE = "show_storge"
local BAG_SHOW_ROLE = "show_role"
local BAG_SHOW_SALE = "show_sale"
local BAG_SHOW_SALE_JL = "show_sale_jl"

local SHOW_ALL = 1
local SHOW_EQUIP = 2
local SHOW_MATIERAL = 3
local SHOW_CONSUME = 4

function WarehouseView:__init(instance, package_init)
	self.package_init = package_init

	self.global_event = GlobalEventSystem:Bind(OtherEventType.WAREHOUSE_FLUSH_VIEW, BindTool.Bind(self.FlushBagView, self))
	self.current_page = 0
	self.view_state = BAG_SHOW_STORGE
	self.ware_grid_list = {}

	self.warehouse_list_view_delegate = ListViewDelegate()

	-- 监听UI事件
	self.node_list["TabAll"].toggle:AddClickListener(BindTool.Bind(self.OnShowAll, self))
	self.node_list["TabEquip"].toggle:AddClickListener(BindTool.Bind(self.OnShowEquip, self))
	self.node_list["TabMaterial"].toggle:AddClickListener(BindTool.Bind(self.OnShowMaterial, self))
	self.node_list["TabComsume"].toggle:AddClickListener(BindTool.Bind(self.OnShowConsume, self))
	self.node_list["BtnWarehouseClose"].button:AddClickListener(BindTool.Bind(self.CleanWarehouse, self))

	for i = 1, BAG_PAGE_NUM do
		self.node_list["PageToggle" .. i].toggle:AddClickListener(BindTool.Bind(self.WareJumpPage, self, i))
	end

	local list_delegate = self.node_list["WarehouseListView"].page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.WareGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.WareRefreshCell, self)

	self:OnShowAll()
end

function WarehouseView:__delete()
	if self.global_event ~= nil then
		GlobalEventSystem:UnBind(self.global_event)
		self.global_event = nil
	end
	self.package_init = nil
	self.warehouse_list_view = nil

	for k,v in pairs(self.ware_grid_list) do
		v:DeleteMe()
		v = nil
	end
end

function WarehouseView:SetDefualtShowState()
	self.node_list["TabAll"].toggle.isOn = true
	self:OnShowAll()
end

function WarehouseView:OnShowAll()
	self.cur_index = -1
	self.show_state = SHOW_ALL
	self.current_page = 0
	self:FlushBagView()
	self.node_list["WarehouseListView"].list_page_scroll2:JumpToPageImmidate(0)
end

function WarehouseView:OnShowEquip()
	self.cur_index = -1
	self.show_state = SHOW_EQUIP
	self.current_page = 0
	self:FlushBagView()
	self.node_list["WarehouseListView"].list_page_scroll2:JumpToPageImmidate(0)
end

function WarehouseView:OnShowMaterial()
	self.cur_index = -1
	self.show_state = SHOW_MATIERAL
	self.current_page = 0
	self:FlushBagView()
	self.node_list["WarehouseListView"].list_page_scroll2:JumpToPageImmidate(0)
end

function WarehouseView:OnShowConsume()
	self.cur_index = -1
	self.show_state = SHOW_CONSUME
	self.current_page = 0
	self:FlushBagView()
	self.node_list["WarehouseListView"].list_page_scroll2:JumpToPageImmidate(0)
end


--整理仓库面板
function WarehouseView:CleanWarehouse()
	PackageCtrl.Instance:SendKnapsackStoragePutInOrder(GameEnum.STORAGER_TYPE_STORAGER, 0)
end

--关闭仓库面板
function WarehouseView:WarehouseClose()
	self.root_node:SetActive(false)
	self.package_init:SetBagViewState("show_role")
	GlobalEventSystem:Fire(WarehouseEventType.ROLE_DRESS_CONTENT,true)
end

----------------- ListView逻辑 ----------------
function WarehouseView:WareGetNumberOfCells()
	return BAG_MAX_GRID_NUM
end

function WarehouseView:WareRefreshCell(index, cellObj)
	local cell = self.ware_grid_list[cellObj]
	if cell == nil then
		cell = ItemCell.New(cellObj)
		cell:SetToggleGroup(self.ware_grid_list.toggle_group)
		self.ware_grid_list[cellObj] = cell
	end

	local page = math.floor(index / BAG_PAGE_COUNT)
	local cur_colunm = math.floor(index / BAG_ROW) + 1 - page * BAG_COLUMN
	local cur_row = math.floor(index % BAG_ROW) + 1
	local grid_index = (cur_row - 1) * BAG_COLUMN - 1 + cur_colunm  + page * BAG_ROW * BAG_COLUMN
	
	local data = nil
	if self.show_state == SHOW_MATIERAL then
		data = PackageData.Instance:GetWareCellData(grid_index, GameEnum.TOGGLE_INFO.MATERIAL_TOGGLE)
	elseif self.show_state == SHOW_EQUIP then
		data = PackageData.Instance:GetWareCellData(grid_index, GameEnum.TOGGLE_INFO.EQUIP_TOGGLE)
	elseif self.show_state == SHOW_CONSUME then
		data = PackageData.Instance:GetWareCellData(grid_index, GameEnum.TOGGLE_INFO.CONSUME_TOGGLE)
	else
		data = PackageData.Instance:GetWareCellData(grid_index, GameEnum.TOGGLE_INFO.ALL_TOGGLE)
	end
	data = data or {}

	data.locked = grid_index >= ItemData.Instance:GetMaxStorageValidNum()
	data.index = data.index and data.index or grid_index + COMMON_CONSTS.MAX_BAG_COUNT
	cell.param = data.param
	cell:SetData(data, true)
	cell:ShowHighLight(false)
	-- cell:SetHighLight(self.cur_index == grid_index)
	cell:ListenClick(BindTool.Bind(self.HandleWareOnClick, self, data, cell))
	cell:SetInteractable((nil ~= data.item_id or data.locked))

	self.current_page = page
end

--滑动翻页
function WarehouseView:WareJumpPage(page)
	self.node_list["WarehouseListView"].list_page_scroll2:JumpToPageImmidate(page - 1)
end

--点击仓库格子
function WarehouseView:HandleWareOnClick(data, cell, is_click)
	if not is_click then return end

	self.view_state = BAG_SHOW_STORGE

	local close_callback = function ()
		cell:SetHighLight(false)
	end

	if data.locked then
		cell:SetHighLight(true)
		self.cur_index = data.index
		local num = data.index - ItemData.Instance:GetMaxStorageValidNum() + 1 - COMMON_CONSTS.MAX_BAG_COUNT
		local had_item_num = ItemData.Instance:GetItemNumInBagById(ItemDataStorageId.Id)
		local item_cfg = ItemData.Instance:GetItemConfig(ItemDataStorageId.Id)
		local shop_item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[ItemDataStorageId.Id]
		local need_number = PackageData.Instance:GetOpenCellNeedItemNum(GameEnum.STORAGER_TYPE_STORAGER, data.index - COMMON_CONSTS.MAX_BAG_COUNT)

		local func_gold = function ()
			PackageCtrl.Instance:SendKnapsackStorageExtendGridNum(GameEnum.STORAGER_TYPE_STORAGER, num, shop_item_cfg.gold * (need_number - had_item_num))
		end
		local func_enough = function ()
			PackageCtrl.Instance:SendKnapsackStorageExtendGridNum(GameEnum.STORAGER_TYPE_STORAGER, num)
		end
		if need_number - had_item_num > 0 then
			local str = string.format(Language.BackPack.KaiQiCangKuBuZu, num, need_number, item_cfg.name, need_number - had_item_num,
				shop_item_cfg.gold * (need_number - had_item_num))
			TipsCtrl.Instance:ShowCommonAutoView(nil, str, func_gold, close_callback)
		else
			local str = string.format(Language.BackPack.KaiQiCangKuZu, num, need_number, item_cfg.name, had_item_num)
			TipsCtrl.Instance:ShowCommonAutoView(nil, str, func_gold, close_callback)
		end
		return
	end

	if nil == data or nil == data.item_id then
		return
	end
	cell:SetHighLight(true)

	-- 弹出面板
	local item_cfg1, big_type1 = ItemData.Instance:GetItemConfig(data.item_id)
	if nil ~= item_cfg1 then
		if self.view_state == BAG_SHOW_STORGE then
			TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_STORGE_ON_BAG_STORGE, nil, close_callback)
		elseif self.view_state == BAG_SHOW_SALE then
			TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_BAG_ON_BAG_SALE,{{fromIndex = data.index}})
		elseif self.view_state == BAG_SHOW_SALE_JL then
			TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_BAG_ON_BAG_SALE_JL, {fromIndex = data.index})
		else
			TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_BAG)
		end
	end
end

function WarehouseView:FlushBagView()
	if self.node_list["WarehouseListView"] and self.node_list["WarehouseListView"].list_view
		and self.node_list["WarehouseListView"].list_view.isActiveAndEnabled then
		self.node_list["WarehouseListView"].list_view:Reload()
		self.node_list["WarehouseListView"].list_page_scroll2:JumpToPageImmidate(self.current_page)
	end
end

function WarehouseView:FlushWarehouseView(index)
	if self.node_list["WarehouseListView"] and self.node_list["WarehouseListView"].list_view
		and self.node_list["WarehouseListView"].list_view.isActiveAndEnabled then
			self.cur_index = (index - COMMON_CONSTS.MAX_BAG_COUNT) or self.cur_index
			local page = math.floor(self.cur_index / (BAG_COLUMN * BAG_ROW)) + 1
			self.node_list["PageToggle" .. page].toggle.isOn = true
			self:WareJumpPage(page)
			self:FlushBagView()
	end
end
