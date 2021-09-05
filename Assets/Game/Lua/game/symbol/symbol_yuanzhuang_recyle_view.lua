-- RecyclePanel 灵药 子物体
YuanzhuangRecycleView = YuanzhuangRecycleView or  BaseClass(BaseRender)

-- 常亮定义
local BAG_PAGE_NUM = 7					-- 页数
local BAG_ROW = 4						-- 行
local BAG_COLUMN = 4					-- 列
local BAG_PAGE_COUNT = 16				-- 每页个数
local BAG_MAX_GRID_NUM = 112			-- 最大格子数

local BAG_SHOW_STORGE = "show_storge"

function YuanzhuangRecycleView:__init(instance)
	self.current_page = 1
	self.view_state =BAG_SHOW_STORGE
	self.recycle_grid_list = {}

	self.warehouse_list_view_delegate = ListViewDelegate()

	-- 监听UI事件
	for i = 1, BAG_PAGE_NUM do
		self.node_list["PageToggle"..i].toggle:AddClickListener(BindTool.Bind(self.WareJumpPage, self, i))
	end

	self.node_list["BtnRecycleAndClose"].button:AddClickListener(BindTool.Bind(self.RecycleAndClose, self))
	self.node_list["ImgCheckBlue"].button:AddClickListener(BindTool.Bind(self.ClickBlueAndUnder, self))
	self.node_list["ImgCheckPurple"].button:AddClickListener(BindTool.Bind(self.ClickPurple, self))
	self.node_list["ImgCheckOrange"].button:AddClickListener(BindTool.Bind(self.ClickOrange, self))
	self.node_list["ImgCheckMyProfession"].button:AddClickListener(BindTool.Bind(self.ClickRed, self))

	local list_delegate = self.node_list["WarehouseListView"].page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.WareGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.WareRefreshCell, self)

	self.is_blue = true
	self.is_purple = false
	self.is_orange = false
	self.is_profession = false

	self.item_data_list = {}
end

function YuanzhuangRecycleView:__delete()
	if self.global_event ~= nil then
		GlobalEventSystem:UnBind(self.global_event)
		self.global_event = nil
	end

	for k, v in pairs(self.recycle_grid_list) do
		v:DeleteMe()
	end
	self.recycle_grid_list = {}
end

function YuanzhuangRecycleView:OpenCallBack()
	self.node_list["TxtRecycleValue"].text.text = 0
	-- self:ClickBlueAndUnder()
	if self.node_list["WarehouseListView"] and self.node_list["WarehouseListView"].list_page_scroll2.isActiveAndEnabled then
		self.node_list["WarehouseListView"].list_page_scroll2:JumpToPageImmidate(0)
	end

	self:FlushToggleState()
	self:GetAllRecycleList()
end

function YuanzhuangRecycleView:FlushToggleState()
	self.node_list["ImgYes"]:SetActive(true)
	self.node_list["ImgYes4"]:SetActive(false)
	self.node_list["ImgYes2"]:SetActive(false)
	self.node_list["ImgYes3"]:SetActive(false)
end

function YuanzhuangRecycleView:ClickBlueAndUnder()
	self.node_list["ImgYes"]:SetActive(not self.node_list["ImgYes"].gameObject.activeSelf)

	local blue_data_list = SymbolData.Instance:GetBlueAndUnderDataList()
	SymbolData.Instance:SetRecycleItemDataList(not self.is_blue, blue_data_list, 2)
	self:FlushRecycleView()
end

function YuanzhuangRecycleView:ClickPurple()
	self.node_list["ImgYes4"]:SetActive(not self.node_list["ImgYes4"].gameObject.activeSelf)
	local purple_data_list = SymbolData.Instance:GetEquipDataListByColor(3)
	SymbolData.Instance:SetRecycleItemDataList(not self.is_purple, purple_data_list,3)
	self:FlushRecycleView()
end

function YuanzhuangRecycleView:ClickOrange()
	self.node_list["ImgYes2"]:SetActive(not self.node_list["ImgYes2"].gameObject.activeSelf)
	local orange_data_list = SymbolData.Instance:GetEquipDataListByColor(4)
	SymbolData.Instance:SetRecycleItemDataList(not self.is_orange, orange_data_list,4)
	self:FlushRecycleView()
end

function YuanzhuangRecycleView:ClickRed()
	self.node_list["ImgYes3"]:SetActive(not self.node_list["ImgYes3"].gameObject.activeSelf)
	local red_data_list = SymbolData.Instance:GetEquipDataListByColor(5)
	SymbolData.Instance:SetRecycleItemDataList(not self.is_profession, red_data_list, 5)
	self:FlushRecycleView()
end

--回收
function YuanzhuangRecycleView:RecycleAndClose()
	local recycle_list = SymbolData.Instance:GetRecycleItemDataList()
	for k,v in pairs(recycle_list) do
		if v and v.item_id then
			SymbolCtrl.Instance:SendEquipRecycle(v.index, v.num)
		end
	end

	SymbolData.Instance:EmptyRecycleList()
	self.item_data_list = {}
	self:FlushRecycleView()
end

function YuanzhuangRecycleView:GetAllRecycleList()
	local blue_data_list = SymbolData.Instance:GetBlueAndUnderDataList()
	SymbolData.Instance:SetRecycleItemDataList(self.node_list["ImgYes"].gameObject.activeSelf, blue_data_list, 2)
	self:FlushRecycleView()

	local purple_data_list = SymbolData.Instance:GetEquipDataListByColor(3)
	SymbolData.Instance:SetRecycleItemDataList(self.node_list["ImgYes4"].gameObject.activeSelf, purple_data_list,3)
	self:FlushRecycleView()

	local orange_data_list = SymbolData.Instance:GetEquipDataListByColor(4)
	SymbolData.Instance:SetRecycleItemDataList(self.node_list["ImgYes2"].gameObject.activeSelf, orange_data_list,4)
	self:FlushRecycleView()

	local red_data_list = SymbolData.Instance:GetEquipDataListByColor(5)
	SymbolData.Instance:SetRecycleItemDataList(self.node_list["ImgYes3"].gameObject.activeSelf, red_data_list, 5)
	self:FlushRecycleView()
end

-----------------------------------
-- ListView逻辑
-----------------------------------
function YuanzhuangRecycleView:WareGetNumberOfCells()
	return BAG_MAX_GRID_NUM
end

function YuanzhuangRecycleView:WareRefreshCell(index, cellObj)
	local cell = self.recycle_grid_list[cellObj]
	if not cell then
		cell = ItemCell.New(cellObj)
		cell:SetToggleGroup(self.node_list["WarehouseListView"].toggle_group)
		self.recycle_grid_list[cellObj] = cell
	end

	local page = math.floor(index / BAG_PAGE_COUNT)
	local cur_colunm = math.floor(index / BAG_ROW) + 1 - page * BAG_COLUMN
	local cur_row = math.floor(index % BAG_ROW) + 1
	local grid_index = (cur_row - 1) * BAG_COLUMN - 1 + cur_colunm  + page * BAG_ROW * BAG_COLUMN

	local data = self.item_data_list[grid_index + 1]
	data = data or {}
	data.locked = false
	data.index = data.index and data.index or grid_index
	cell:SetData(data, true)
	cell:ShowHighLight(false)
	cell:ShowQuality(nil ~= data.item_id)
	cell:ListenClick(BindTool.Bind(self.HandleWareOnClick, self, data, cell))
	cell:SetInteractable((nil ~= data.item_id or data.locked))
end

function YuanzhuangRecycleView:FlushRecycleView()
	self.item_data_list = SymbolData.Instance:GetRecycleItemDataList()

	local renown_value = 0
	for k, v in pairs(self.item_data_list) do
		local num = SymbolData.Instance:GetEquipmentDecomposeReward(v.item_id)
		renown_value = renown_value + num * v.num
	end

	GlobalEventSystem:Fire(OtherEventType.FLUSH_ELEMENT_BAG_GRID, {index = -1})

	self.node_list["TxtRecycleValue"].text.text = renown_value
	if self.node_list["WarehouseListView"] and nil ~= self.node_list["WarehouseListView"].list_view
		and self.node_list["WarehouseListView"].list_view.isActiveAndEnabled then
		self.node_list["WarehouseListView"].list_view:Reload()
	end
end

--滑动翻页
function YuanzhuangRecycleView:WareJumpPage(page)
	self.node_list["WarehouseListView"].list_page_scroll2:JumpToPageImmidate(page - 1)
end

--点击格子
function YuanzhuangRecycleView:HandleWareOnClick(data, cell)
	self.view_state = BAG_SHOW_STORGE
	cell:SetHighLight(self.cur_index == index)
	if data.item_id ~= nil and data.item_id > 0 then
		SymbolData.Instance:RemoveRecycData(data)
		self:FlushRecycleView()
		GlobalEventSystem:Fire(OtherEventType.FLUSH_ELEMENT_BAG_GRID, {index = data.index})
	end
end