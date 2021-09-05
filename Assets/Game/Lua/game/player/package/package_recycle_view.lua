PackageRecycleView = PackageRecycleView or  BaseClass(BaseRender)

-- 常亮定义
local BAG_MAX_GRID_NUM = 144			-- 最大格子数
local BAG_MIX_GRID_NUM = 6			-- 最大格子数
local BAG_PAGE_NUM = 1					-- 页数
local BAG_PAGE_COUNT = 144				-- 每页个数
local BAG_ROW = 4						-- 行
local BAG_COLUMN = 6					-- 列
local BAG_COMMON = 15 					-- 普通装
local BAG_ZHUAN = 10 					-- 转职装
local BAG_RECLYCEL_NUM = 3 				-- 回收种类个数

local BAG_SHOW_STORGE = "show_storge"
local BAG_SHOW_ROLE = "show_role"
local BAG_SHOW_SALE = "show_sale"
local BAG_SHOW_SALE_JL = "show_sale_jl"

function PackageRecycleView:__init(instance, package_init)
	self.package_init = package_init

	self.global_event = GlobalEventSystem:Bind(OtherEventType.RECYCLE_FLUSH_CONTENT, BindTool.Bind(self.FlushRecycleView, self))
	self.open_callback_event = GlobalEventSystem:Bind(OtherEventType.OPEN_RECYCLE_VIEW, BindTool.Bind(self.OpenCallBack, self))
	self.current_page = 1
	self.view_state =BAG_SHOW_STORGE
	self.recycle_grid_list = {}
	self.feixian_list = {}
	self.common_list = {}
	self.get_grid_list = {}
	self.is_auto = false

	-- self.warehouse_list_view_delegate = ListViewDelegate()
	-- self.get_list_view_delegate = ListViewDelegate()

	-- 监听UI事件
	self.node_list["BtnRecycleAndClose"].button:AddClickListener(BindTool.Bind(self.RecycleAndClose, self))
	-- self.node_list["BoxTopBlue"].button:AddClickListener(BindTool.Bind(self.ClickBlueAndUnder, self))
	-- self.node_list["BoxTopGreen"].button:AddClickListener(BindTool.Bind(self.ClickGreen, self))
	-- self.node_list["BoxTopPurple"].button:AddClickListener(BindTool.Bind(self.ClickPurple, self))
	-- self.node_list["BoxTopOrange"].button:AddClickListener(BindTool.Bind(self.ClickOrange, self))
	-- self.node_list["TopMyProfession"].button:AddClickListener(BindTool.Bind(self.ClickRed, self))
	self.node_list["TopAutoRecyc"].button:AddClickListener(BindTool.Bind(self.ClickAuto, self))
	self.node_list["MojingImage"].button:AddClickListener(BindTool.Bind(self.ClickMojing, self))

	local list_delegate = self.node_list["WarehouseListView"].page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.WareGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.WareRefreshCell, self)

	local common_list_delegate = self.node_list["CheckCommon"].list_simple_delegate
	common_list_delegate.NumberOfCellsDel = BindTool.Bind(self.CommonGetCellNumber, self)
	common_list_delegate.CellRefreshDel = BindTool.Bind(self.CommonRefreshDel, self)

	-- local feixian_list_delegate = self.node_list["CheckFeiXian"].list_simple_delegate
	-- feixian_list_delegate.NumberOfCellsDel = BindTool.Bind(self.FeiXianGetCellNumber, self)
	-- feixian_list_delegate.CellRefreshDel = BindTool.Bind(self.FeiXianRefreshDel, self) CheckRecycle

	local feixian_list_delegate = self.node_list["CheckRecycle"].list_simple_delegate
	feixian_list_delegate.NumberOfCellsDel = BindTool.Bind(self.FeiXianGetCellNumber, self)
	feixian_list_delegate.CellRefreshDel = BindTool.Bind(self.FeiXianRefreshDel, self)


	self:InitData()
	self.is_green = true
	self.is_blue = false
	self.is_purple = false
	self.is_orange = false
	self.is_profession = false

	self.item_data_list = {}
	self.item_list = {}
	self.renown_value = 0
end

function PackageRecycleView:__delete()
	if self.global_event ~= nil then
		GlobalEventSystem:UnBind(self.global_event)
		self.global_event = nil
	end
	if self.open_callback_event ~= nil then
		GlobalEventSystem:UnBind(self.open_callback_event)
		self.open_callback_event = nil
	end

	self.package_init = nil
	
	for k, v in pairs(self.recycle_grid_list) do
		v:DeleteMe()
	end
	self.recycle_grid_list = {}

	for k, v in pairs(self.common_list) do
		v:DeleteMe()
	end
	self.common_list = {}

	for k, v in pairs(self.feixian_list) do
		v:DeleteMe()
	end
	self.feixian_list = {}
	
	for k, v in pairs(self.get_grid_list) do
		v:DeleteMe()
	end
	self.get_grid_list = {}

	self.item = nil
	self.rewards_list = nil
end

function PackageRecycleView:OpenCallBack()
	if self.node_list["WarehouseListView"] and self.node_list["WarehouseListView"].list_page_scroll2.isActiveAndEnabled then
		self.node_list["WarehouseListView"].list_page_scroll2:JumpToPageImmidate(0)
	end
	self:FlushToggleState()
	self:GetAllRecycleList()
end

--功能引导按钮
function PackageRecycleView:RecycleAndBtn()
	return self.node_list["BtnRecycleAndClose"], BindTool.Bind(self.RecycleAndClose, self)
end

function PackageRecycleView:ClickMojing()
	TipsCtrl.Instance:OpenItem({item_id = COMMON_CONSTS.VIRTUAL_ITEM_MOJINT})
end

function PackageRecycleView:InitData()
	self.rewards_list = {}
	for i = 1, 6 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.node_list["ListView"])
		item_cell:SetIndex(i)
		item_cell:SetData()
		table.insert(self.rewards_list,item_cell)
	end
end
function PackageRecycleView:FlushToggleState()
	self.is_auto = SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_RECYCLE_EQUIP)
	self.node_list["ImgAutoRecyc"]:SetActive(self.is_auto)
	self.node_list["EffectRecyc"]:SetActive(not self.is_auto)

	self:FlushAllHL()
end

function PackageRecycleView:ClickAuto()
	self.is_auto = self.is_auto == false
	self.node_list["ImgAutoRecyc"]:SetActive(self.is_auto)
	self.node_list["EffectRecyc"]:SetActive(not self.is_auto)

	SettingData.Instance:SetSettingData(SETTING_TYPE.AUTO_RECYCLE_EQUIP, self.is_auto, true)
	PackageData.Instance:SetRecyleDataList()
	for i = 1, BAG_ZHUAN do
		local flag = SettingData.Instance:GetRecycleFlag(i)
		SettingData.Instance:SetRecycleFlag(i, flag)
	end

	for i = 1, BAG_COMMON do
		local flag = SettingData.Instance:GetCommonRecycleFlag(i)
		SettingData.Instance:SetCommonRecycleFlag(i, flag)
	end

	SettingCtrl.Instance:SendHotkeyInfoReq()
	self:FlushToggleState()
	self:FlushRecycleView()

	if self.is_auto then
		self:RecycleAndClose()
	end
end

--回收
function PackageRecycleView:RecycleAndClose()
	local recycle_list = PackageData.Instance:GetRecycleItemDataList()
	-- for k,v in pairs(recycle_list) do
	-- 	if v and v.item_id then
	-- 		PackageCtrl.Instance:SendDiscardItem(v.index, v.num, v.item_id, v.num, 1)
	-- 	end
	-- end
	local index_list = {}
	local index_list2 = {}
	for k,v in pairs(recycle_list) do
		if k <= 200 then
			table.insert(index_list, v)
		else
			table.insert(index_list2, v)
		end
	end

	if #recycle_list <= 0 then
		return 0
	end

	if next(index_list) then
		PackageCtrl.Instance:SendBatchDiscardItem(#index_list, index_list)
	elseif next(index_list2) then
		PackageCtrl.Instance:SendBatchDiscardItem(#index_list2, index_list2)
	end

	PackageData.Instance:EmptyRecycleList()
	self.item_list = {}
	self:FlushRecycleView()
end

function PackageRecycleView:GetAllRecycleList()
	PackageData.Instance:SetRecyleDataList()
	self:FlushRecycleView()
end


---------------普通装备 ListView逻辑 -----------------------
function PackageRecycleView:CommonGetCellNumber()
	return BAG_COMMON
end

function PackageRecycleView:CommonRefreshDel(cellObj, index)
	data_index = index + 1
	local cell = self.common_list[cellObj]
	if not cell then
		cell = CommonToggleItem.New(cellObj)
		cell.parent_view = self
		self.common_list[cellObj] = cell
	end
	cell:SetIndex(data_index)
	cell:FlushHL()
	self.common_list[cellObj].node_list["Text"].text.text = Language.Package.CheckCommonTabName[index + 1]
end

---------------转职装备 ListView逻辑 -----------------------
function PackageRecycleView:FeiXianGetCellNumber()					-- 将1-10阶的转职装备回收 取他前2阶
	return BAG_RECLYCEL_NUM
end

function PackageRecycleView:FeiXianRefreshDel(cellObj, index)
	data_index = index + 1
	local cell = self.feixian_list[cellObj]
	if not cell then
		cell = ToggleItem.New(cellObj)
		cell.parent_view = self
		self.feixian_list[cellObj] = cell
	end
	cell:SetIndex(data_index)
	cell:FlushHL()
	-- self.feixian_list[cellObj].node_list["Text"].text.text = Language.Package.CheckTabName[index + 1]
	self.feixian_list[cellObj].node_list["Text"].text.text = Language.Package.CheckRecycleName[index + 1]
end

function PackageRecycleView:FlushAllHL()
	for k,v in pairs(self.feixian_list)do
		v:FlushHL()
	end
end

function PackageRecycleView:WareGetNumberOfCells()
	return BAG_MAX_GRID_NUM
end

function PackageRecycleView:WareRefreshCell(index, cellObj)
	local cell = self.recycle_grid_list[cellObj]
	if not cell then
		cell = ItemCell.New(cellObj)
		cell:SetToggleGroup(self.recycle_grid_list.toggle_group)
		self.recycle_grid_list[cellObj] = cell
	end

	local page = math.floor(index / BAG_PAGE_COUNT)
	local cur_row = math.floor(index / BAG_COLUMN) + 1 - page * BAG_COLUMN
	local cur_colunm = math.floor(index % BAG_COLUMN) + 1
	local grid_index = (cur_row - 1) * BAG_COLUMN - 1 + cur_colunm  + page * BAG_ROW * BAG_COLUMN
	local data = self.item_data_list[grid_index + 1]
	data = data or {}
	data.locked = false
	data.index = data.index and data.index or grid_index
	cell:SetData(data, true)
	cell:SetLimitUse()
	cell:ShowHighLight(false)
	cell:ShowQuality(nil ~= data.item_id)
	cell:ListenClick(BindTool.Bind(self.HandleWareOnClick, self, data, cell))
	cell:SetInteractable((nil ~= data.item_id or data.locked))
end

function PackageRecycleView:FlushRecycleView()
	self.item_data_list = PackageData.Instance:GetRecycleItemDataList()
	self.renown_value = 0
	self.renown_tab = {}
	local orange_crystal_value = 0
	local red_crystal_value = 0
	local now_compose_cfg = nil

	local show_eff = false
	for k, v in pairs(self.item_data_list) do
		local item_cfg, _ = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg then
			if item_cfg.recycltype == 6 then
				self.renown_value = self.renown_value + item_cfg.recyclget
			else
				local recycle_cfg = ForgeData.Instance:GetRecycleItem(item_cfg.recycltype)
				if recycle_cfg then
					local cfg_item_id = recycle_cfg.return_item.item_id
					if self.renown_tab[cfg_item_id] then
						self.renown_tab[cfg_item_id].num = self.renown_tab[cfg_item_id].num + item_cfg.recyclget
					else
						self.renown_tab[cfg_item_id] = {}
						self.renown_tab[cfg_item_id].item_id = cfg_item_id
						self.renown_tab[cfg_item_id].num = item_cfg.recyclget
						self.renown_tab[cfg_item_id].is_bind = 1
					end
				end
			end
		end
		show_eff = true
	end

	GlobalEventSystem:Fire(OtherEventType.FLUSH_BAG_GRID, {index = -1})
	self:GetMoJing()
	if self.node_list["WarehouseListView"] and nil ~= self.node_list["WarehouseListView"].list_view
		and self.node_list["WarehouseListView"].list_view.isActiveAndEnabled then
		self.node_list["WarehouseListView"].list_view:Reload()
	end
	self.node_list["EffectSpecial1"]:SetActive(show_eff)
	self.node_list["EffectSpecial2"]:SetActive(show_eff)
end

function PackageRecycleView:GetCrystalValue(data)
	if nil == data or nil == data.param then return 0 end
	local now_cfg = ForgeData.Instance:GetRedEquipComposeCfg(data.item_id, math.max(#data.param.xianpin_type_list, 0))
	local crystal_value = 0
	if nil ~= now_cfg then
		crystal_value = crystal_value + now_cfg.discard_return[0].num
	end
	return crystal_value
end

--点击格子
function PackageRecycleView:HandleWareOnClick(data, cell)
	if nil == data or nil == data.item_id then
		return
	end

	self.view_state = BAG_SHOW_STORGE
	cell:SetHighLight(self.cur_index == index)
	if data.item_id ~= nil and data.item_id > 0 then
		PackageData.Instance:RemoveRecycData(data)
		self:FlushRecycleView()
		GlobalEventSystem:Fire(OtherEventType.FLUSH_BAG_GRID, {index = data.index})
	end
end

function PackageRecycleView:FlushRecycleViewFromPackage()
	self:FlushRecycleView()
end

function PackageRecycleView:GetMoJing()
	-- local count = 1
	self.item_list = PackageData.Instance:GetXuNiWu()
	self.node_list["GetRecycle"].text.text = self.renown_value or 0
	-- if self.item_list[1] ~= nil and self.renown_value ~= 0 then
	-- 	self.rewards_list[count]:SetData({item_id = self.item_list[1].icon_id,num = self.renown_value})
	-- 	count = count + 1
	-- end

	-- for k, v in pairs(self.renown_tab) do
	-- 	self.rewards_list[count]:SetData(v)
	-- 	count = count + 1
	-- end

	-- for i = count, #self.rewards_list do
	-- 	self.rewards_list[i]:SetData({})
	-- end
end

-----------------------ToggleItem------------------
CommonToggleItem = CommonToggleItem or BaseClass(BaseCell)

function CommonToggleItem:__init()
	self.node_list["Check"].button:AddClickListener(BindTool.Bind(self.ClickBtn, self))
end

function CommonToggleItem:__delete()

end

function CommonToggleItem:ClickBtn()
	local flag = SettingData.Instance:GetCommonRecycleFlag(self.index) == 0 and 1 or 0
	SettingData.Instance:SetCommonRecycleFlag(self.index, flag)
	self:FlushHL()
	PackageData.Instance:SetRecyleDataList()
	self.parent_view:FlushRecycleView()
	SettingCtrl.Instance:SendHotkeyInfoReq()
end

function CommonToggleItem:FlushHL()
	local flag = SettingData.Instance:GetCommonRecycleFlag(self.index)
	self.node_list["Image"]:SetActive(flag == 1)
end

-----------------------ToggleItem------------------
ToggleItem = ToggleItem or BaseClass(BaseCell)

function ToggleItem:__init()
	self.node_list["Check"].button:AddClickListener(BindTool.Bind(self.ClickBtn, self))
end

function ToggleItem:__delete()

end

function ToggleItem:ClickBtn()
	local flag = SettingData.Instance:GetRecycleFlag(self.index) == 0 and 1 or 0
	SettingData.Instance:SetRecycleFlag(self.index, flag)
	self:FlushHL()
	PackageData.Instance:SetRecyleDataList()
	self.parent_view:FlushRecycleView()
	SettingCtrl.Instance:SendHotkeyInfoReq()
	if flag == 1 and self.parent_view.is_auto then
		self.parent_view:RecycleAndClose()
	end
end

function ToggleItem:FlushHL()
	local flag = SettingData.Instance:GetRecycleFlag(self.index)
	self.node_list["Image"]:SetActive(flag == 1)
end