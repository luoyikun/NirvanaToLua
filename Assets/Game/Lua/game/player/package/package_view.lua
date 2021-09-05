require("game/player/package/warehouse_view")
require("game/player/package/package_recycle_view")

local BAG_MAX_GRID_NUM = 400			-- 最大格子数
local BAG_PAGE_NUM = 16					-- 页数
local BAG_PAGE_COUNT = 25				-- 每页个数
local BAG_ROW = 5						-- 行数
local BAG_COLUMN = 5					-- 列数
local VIP_TYPE_CELL_COUNT = 44 			-- 设置格子个数的vip类型

local BAG_SHOW_STORGE = "show_storge"
local BAG_SHOW_ROLE = "show_role"
local BAG_SHOW_SALE = "show_sale"
local BAG_SHOW_SALE_JL = "show_sale_jl"
local BAG_SHOW_RECYCLE = "show_recycle"

local SHOW_ALL = 1
local SHOW_EQUIP = 2
local SHOW_MATIERAL = 3
local SHOW_CONSUME = 4

local MOVE_TIME = 0.3
local MOVE_DISTANCE = 600
local WARE_DISTANCE = 250
local RECY_DISTANCE = 375

-- 点击类型
local CLICK_TYPE = 
{
	BIND_GOLD = 1,	-- 绑元
	GOLD = 2,		-- 元宝
	STAR = 3,		-- 魔晶
}

PackageView = PackageView or BaseClass(BaseView)

function PackageView:__init()
	self.ui_config = {{"uis/views/packageview_prefab", "PackageView"},}
	self.full_screen = false
	self.play_audio = true
	self.is_modal = true
	self.close_mode = CloseMode.CloseVisible
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUIHigh

-- 初始化数据变量
	self.view_state = BAG_SHOW_ROLE
	self.current_page = 1
	self.is_open_warehouse = false
	self.is_open_recycle = false
	self.bag_cell = {}
	self.recycle_view_state = false

	self.open_tween = self.ShowFromRight
	self.close_tween = self.HideFromLeft
end

function PackageView:ReleaseCallBack()
	if self.item_data_event ~= nil and ItemData.Instance then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if nil ~= self.close_recycle_content_event then
		GlobalEventSystem:UnBind(self.close_recycle_content_event)
		self.close_recycle_content_event = nil
	end

	if nil ~= self.flush_bag_grid_event then
		GlobalEventSystem:UnBind(self.flush_bag_grid_event)
		self.flush_bag_grid_event = nil
	end

	if self.mojing_change_callback and ExchangeCtrl.Instance then
		ExchangeCtrl.Instance:UnNotifyWhenScoreChange(self.mojing_change_callback)
		self.mojing_change_callback = nil
	end

	if self.recycle_view then
		self.recycle_view:DeleteMe()
		self.recycle_view = nil
	end

	if self.warehouse_view then
		self.warehouse_view:DeleteMe()
		self.warehouse_view = nil
	end

	if self.tips_view then
		self.tips_view:DeleteMe()
		self.tips_view = nil
	end

	for k, v in pairs(self.bag_cell) do
		v:DeleteMe()
	end
	self.bag_cell = {}

	self.min_index = 0
	self.max_index = 0

	FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.PackageView)
end

function PackageView.ShowFromRight(self)
	self.root_parent.transform.anchoredPosition = Vector3(MOVE_DISTANCE, 0, 0)

	local tween = self.root_parent.transform:DOAnchorPosX(0, MOVE_TIME)
	tween:SetEase(DG.Tweening.Ease.Linear)

	return tween
end

function PackageView.HideFromLeft(self)
	self.root_parent.transform.anchoredPosition = Vector3(0, 0, 0)

	local tween = self.root_parent.transform:DOAnchorPosX(MOVE_DISTANCE, MOVE_TIME)
	tween:SetEase(DG.Tweening.Ease.Linear)

	return tween
end

function PackageView:LoadCallBack()
	-- 监听UI事件
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.HandleClose, self))
	self.node_list["BtnBg"].button:AddClickListener(BindTool.Bind(self.HandleClose, self))
	self.node_list["TabAll"].toggle:AddClickListener(BindTool.Bind(self.OnShowAll, self))
	self.node_list["TabEquip"].toggle:AddClickListener(BindTool.Bind(self.OnShowEquip, self))
	self.node_list["TabMaterial"].toggle:AddClickListener(BindTool.Bind(self.OnShowMaterial, self))
	self.node_list["TabComsume"].toggle:AddClickListener(BindTool.Bind(self.OnShowConsume, self))
	self.node_list["BtnWarehouse"].button:AddClickListener(BindTool.Bind(self.HandleOpenWarehouse, self))
	self.node_list["CloseBag"].button:AddClickListener(BindTool.Bind(self.HandleOpenWarehouse, self))
	self.node_list["RecycleButton"].button:AddClickListener(BindTool.Bind(self.HandleOpenRecycle, self))
	self.node_list["CloseRecycle"].button:AddClickListener(BindTool.Bind(self.HandleOpenRecycle, self))
	self.node_list["BtnClean"].button:AddClickListener(BindTool.Bind(self.HandleCombineItems, self))
	self.node_list["BtnBindGold"].button:AddClickListener(BindTool.Bind(self.OnClickGold, self, CLICK_TYPE.BIND_GOLD))
	self.node_list["BtnGold"].button:AddClickListener(BindTool.Bind(self.OnClickGold, self, CLICK_TYPE.GOLD))
	self.node_list["BtnStar"].button:AddClickListener(BindTool.Bind(self.OnClickGold, self, CLICK_TYPE.STAR))

	self.warehouse_view = WarehouseView.New(self.node_list["WarehousePanel"], self)
	self.recycle_view = PackageRecycleView.New(self.node_list["RecyclePanel"], self)

	local list_delegate = self.node_list["ListView"].page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	-- 监听系统事件

	self.mojing_change_callback = BindTool.Bind1(self.MoJingChange, self)
	ExchangeCtrl.Instance:NotifyWhenScoreChange(self.mojing_change_callback)

	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)

	self.close_recycle_content_event = GlobalEventSystem:Bind(RecycleEventType.CLOSE_RECYCLE_CONTENT, BindTool.Bind1(self.HandleCloseRecycle, self))
	self.flush_bag_grid_event = GlobalEventSystem:Bind(OtherEventType.FLUSH_BAG_GRID, BindTool.Bind(self.FlushBagView, self))

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.PackageView, BindTool.Bind(self.GetUiCallBack, self))
end

function PackageView:HandleClose()
	if self.is_open_warehouse and self.node_list["WarehousePanel"].gameObject.activeSelf or 
		self.is_open_recycle and self.node_list["RecyclePanel"].gameObject.activeSelf then
		return
	end
	self:Close()
end

function PackageView:OpenCallBack()
	ForgeData.Instance:SetIsFlushEquipPower(true)
	ForgeData.Instance:SetIsFlushBaiZhanEquipPower(true)

	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	self:MoJingChange()
	
	if self.node_list["ListView"] and self.node_list["ListView"].list_page_scroll2.isActiveAndEnabled then
		self.node_list["ListView"].list_page_scroll2:JumpToPageImmidate(0)
	end
	-- 默认显示全部
	self:SetDefualtShowState()
end

function PackageView:CloseCallBack()
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	self.node_list["WarehousePanel"]:SetActive(false)
	self.node_list["RecyclePanel"]:SetActive(false)

	self:SetBagViewState(BAG_SHOW_ROLE)
	PackageData.Instance:EmptyRecycleList()
	ForgeData.Instance:SetIsFlushEquipPower(false)
	ForgeData.Instance:SetIsFlushBaiZhanEquipPower(false)

	PackageData.Instance:ClearNewItemList()
	GlobalEventSystem:Fire(WarehouseEventType.ROLE_DRESS_CONTENT, true)
	self.recycle_view_state = false
end

function PackageView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "bind_gold" then
		self.node_list["TextBangyuan"].text.text = CommonDataManager.ConverMoney(vo.bind_gold)
	elseif attr_name == "gold" then
		self.node_list["TextYuan1"].text.text = CommonDataManager.ConverMoney(vo.gold)
	end
end

function PackageView:SetRecycleContentState(value)
	self.node_list["RecyclePanel"]:SetActive(value)
	if not value then
		self:SetBagViewState(BAG_SHOW_ROLE)
		PackageData.Instance:EmptyRecycleList()
	end
	self.recycle_view_state = value
end

function PackageView:GetRecycleViewState()
	return self.recycle_view_state
end

function PackageView:SetDefualtShowState()
	self.node_list["TabAll"].toggle.isOn = true
	self:OnShowAll()
end

function PackageView:OnShowAll()
	self.cur_index = -1
	self.show_state = SHOW_ALL
	self.current_page = 1
	self:FlushBagView()
	self.node_list["ListView"].list_page_scroll2:JumpToPageImmidate(0)
end

function PackageView:OnShowEquip()
	self.cur_index = -1
	self.show_state = SHOW_EQUIP
	self.current_page = 1
	self:FlushBagView()
	self.node_list["ListView"].list_page_scroll2:JumpToPageImmidate(0)
end

function PackageView:OnShowMaterial()
	self.cur_index = -1
	self.show_state = SHOW_MATIERAL
	self.current_page = 1
	self:FlushBagView()
	self.node_list["ListView"].list_page_scroll2:JumpToPageImmidate(0)
end

function PackageView:OnShowConsume()
	self.cur_index = -1
	self.show_state = SHOW_CONSUME
	self.current_page = 1
	self:FlushBagView()
	self.node_list["ListView"].list_page_scroll2:JumpToPageImmidate(0)
end

function PackageView:GetWareHourseState()
	if self.node_list["WarehousePanel"] then
		return self.node_list["WarehousePanel"].gameObject.activeSelf
	end
	return false
end

function PackageView:CloseWareHouse()
	if self.warehouse_view then
		self.warehouse_view:WarehouseClose()
		self.is_open_warehouse = false
	end
end

--打开仓库面板
function PackageView:HandleOpenWarehouse()
	if self.is_open_warehouse and self.node_list["WarehousePanel"].gameObject.activeSelf then
		self.node_list["TxtWarehouseButton1"].text.text = Language.Package.Warehouse
		self.node_list["RecycleButton"]:SetActive(true)
		self.is_open_warehouse = false

		self.node_list["WarehousePanel"].transform.anchoredPosition = Vector3(WARE_DISTANCE, 0, 0)
		local tween = self.node_list["WarehousePanel"].transform:DOAnchorPosX(-WARE_DISTANCE, MOVE_TIME)
		tween:SetEase(DG.Tweening.Ease.Linear)
		tween:OnComplete(function ()
			if not self.is_open_warehouse then
				self.warehouse_view:WarehouseClose()
			end
		end)
	else
		self.node_list["WarehousePanel"].transform.anchoredPosition = Vector3(0, 0, 0)
		local tween = self.node_list["WarehousePanel"].transform:DOAnchorPosX(WARE_DISTANCE, MOVE_TIME)
		tween:SetEase(DG.Tweening.Ease.Linear)

		self.node_list["TxtWarehouseButton1"].text.text = Language.Package.CloseWarehouse
		self.node_list["RecycleButton"]:SetActive(false)
		self.node_list["WarehousePanel"]:SetActive(true)
		self:SetBagViewState(BAG_SHOW_STORGE)
		self.is_open_warehouse = true

		GlobalEventSystem:Fire(WarehouseEventType.ROLE_DRESS_CONTENT, false)
		GlobalEventSystem:Fire(OtherEventType.WAREHOUSE_FLUSH_VIEW, ItemData.Instance:GetMaxStorageValidNum())
	end
end

--打开回收面板
function PackageView:HandleOpenRecycle()
	if self.is_open_recycle and self.node_list["RecyclePanel"].gameObject.activeSelf then
		self.node_list["TxtRecycle"].text.text = Language.Package.Recycle
		self.node_list["BtnWarehouse"]:SetActive(true)
		self.is_open_recycle = false

		self.node_list["RecyclePanel"].transform.anchoredPosition = Vector3(RECY_DISTANCE, 0, 0)
		local tween = self.node_list["RecyclePanel"].transform:DOAnchorPosX(-RECY_DISTANCE, MOVE_TIME)
		tween:SetEase(DG.Tweening.Ease.Linear)
		tween:OnComplete(function ()
			if not self.is_open_recycle then
				self:HandleCloseRecycle()
			end
		end)
	else
		self.node_list["RecyclePanel"].transform.anchoredPosition = Vector3(0, 0, 0)
		local tween = self.node_list["RecyclePanel"].transform:DOAnchorPosX(RECY_DISTANCE, MOVE_TIME)
		tween:SetEase(DG.Tweening.Ease.Linear)

		self.node_list["TxtRecycle"].text.text = Language.Package.CloseRecycle
		self.node_list["BtnWarehouse"]:SetActive(false)
		self.node_list["RecyclePanel"]:SetActive(true)
		self:SetBagViewState(BAG_SHOW_RECYCLE)
		self.recycle_view_state = true
		self.is_open_recycle = true

		GlobalEventSystem:Fire(OtherEventType.OPEN_RECYCLE_VIEW)
		GlobalEventSystem:Fire(OtherEventType.RECYCLE_FLUSH_CONTENT)
		GlobalEventSystem:Fire(WarehouseEventType.ROLE_DRESS_CONTENT, false)
		
	end
end

--关闭回收面板
function PackageView:HandleCloseRecycle()
	self.node_list["RecyclePanel"]:SetActive(false)
	self:SetBagViewState(BAG_SHOW_ROLE)

	PackageData.Instance:EmptyRecycleList()
	self.cur_index = -1
	self:FlushBagView()

	GlobalEventSystem:Fire(WarehouseEventType.ROLE_DRESS_CONTENT,true)
	self.recycle_view_state = false
end

-- 合并道具
function PackageView:HandleCombineItems()
	-- if IS_ON_CROSSSERVER then
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
	-- 	return
	-- end
	-- local func = function ()
	PackageData.Instance:ClearNewItemList()
	PackageCtrl.Instance:SendKnapsackStoragePutInOrder(GameEnum.STORAGER_TYPE_BAG, 0)  -- GameEnum.STORAGER_TYPE_BAG, 0 屏蔽合并
	self:HandleCleanPackage()
	-- end
	-- local cancelfunc = function ()
		-- self:HandleCleanPackage()
	-- end
	-- TipsCtrl.Instance:ShowCommonAutoView("package", Language.Role.MergeText, func, nil, nil, Language.Package.OKDes, Language.Package.CancelDes, nil, nil, nil,cancelfunc)
end

--整理背包
function PackageView:HandleCleanPackage()
	-- if IS_ON_CROSSSERVER then
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
	-- 	return
	-- end

	local close_callback = function()
		PackageCtrl.Instance:SendKnapsackStoragePutInOrder(GameEnum.STORAGER_TYPE_BAG, 0)
	end
	if #PackageData.Instance:GetQuickUseItem() <= 0 or BAG_SHOW_STORGE == self.view_state then
		close_callback()
		EquipData.Instance:FlushBagEquipUse()
	else
		TipsCtrl.Instance:ShowQuickUsePropView(nil, close_callback)
	end
end

function PackageView:SetBagViewState(view_state)
	if self.view_state == view_state then
		return
	end
	self.view_state = view_state
	if self.view_state == BAG_SHOW_ROLE then
		PackageCtrl.Instance:CloseBagRecycle()
	end
end

function PackageView:GetCurPage()
	for i = 1, BAG_PAGE_NUM do
		if self.node_list["PageToggle" .. i].toggle.isOn then
			self.current_page = i
			return
		end
	end
end

function PackageView:FlushtPageCount(bag_num)
	self.node_list["ListView"].list_page_scroll2:SetPageCount(bag_num)
	self.node_list["ListView"].list_view:Reload()
end

function PackageView:FlushBagView(param)
	if self.node_list["ListView"] and self.node_list["ListView"].list_view and self.node_list["ListView"].list_view.isActiveAndEnabled then
		if param == nil or self.show_state ~= SHOW_ALL then
			self.cur_index = self.cur_index or -1
			local bag_page = math.ceil(ItemData.Instance:GetMaxKnapsackValidNum() / BAG_PAGE_COUNT)
			local bag_num =  bag_page + 4  > BAG_PAGE_NUM and BAG_PAGE_NUM or bag_page + 4
			for i = 1, BAG_PAGE_NUM do 
				self.node_list["PageToggle" .. i]:SetActive(bag_num >= i)
			end
			if -1 == self.cur_index or self.show_state ~= SHOW_ALL then
				self:FlushtPageCount(bag_num)
			end
		else
			for k,v in pairs(param) do
				if type(v) == "string" then
					v = -1
				end
				self.cur_index = v or self.cur_index or -1
				if self.cur_index == -1 then
					break
				end
				self:GetCurPage()
				local max_index = (self.current_page + 1) * BAG_COLUMN * BAG_ROW - 1
				local min_index = max_index - (BAG_COLUMN * BAG_ROW * 3) + 1
				if self.cur_index >= min_index and self.cur_index <= max_index then
					local data = nil
					if self.show_state == SHOW_MATIERAL then
						data = PackageData.Instance:GetCellData(self.cur_index, GameEnum.TOGGLE_INFO.MATERIAL_TOGGLE)
					elseif self.show_state == SHOW_EQUIP then
						data = PackageData.Instance:GetCellData(self.cur_index, GameEnum.TOGGLE_INFO.EQUIP_TOGGLE)
					elseif self.show_state == SHOW_CONSUME then
						data = PackageData.Instance:GetCellData(self.cur_index, GameEnum.TOGGLE_INFO.CONSUME_TOGGLE)
					else
						data = PackageData.Instance:GetCellData(self.cur_index, GameEnum.TOGGLE_INFO.ALL_TOGGLE)
					end
					data = data or {}
					local cell_data = {}
					cell_data.item_id = data.item_id
					cell_data.num = data.num
					cell_data.locked =self.cur_index >= ItemData.Instance:GetMaxKnapsackValidNum()
					cell_data.index = data.index or self.cur_index
					cell_data.param = data.param
					cell_data.is_bind = data.is_bind
					cell_data.invalid_time = data.invalid_time

					local flag = false
					local index = 0
					for k,v in pairs(self.bag_cell) do
						if v:GetActive() then
							v:FlushArrow(true)
							if v:GetData().index == self.cur_index then
								v:ShowQuality(nil ~= cell_data.item_id)
								v:SetData(cell_data, true)
								v:ListenClick(BindTool.Bind(self.HandleBagOnClick, self, cell_data, v))
								v:SetInteractable(nil ~= cell_data.item_id or cell_data.locked)
							end
						end
					end
				end
			end
			if -1 == self.cur_index or self.cur_index >= COMMON_CONSTS.MAX_BAG_COUNT then
				-- self.node_list["ListView"].list_view:JumpToIndex(0)
				self.node_list["ListView"].list_view:Reload()
			end
		end
		self.cur_index = -1
	end
end

---------------- ListView逻辑--------------

function PackageView:BagGetNumberOfCells()
	local bag_page = math.ceil(ItemData.Instance:GetMaxKnapsackValidNum() / BAG_PAGE_COUNT)
	local bag_num =  bag_page + 4  > BAG_PAGE_NUM and BAG_PAGE_NUM or bag_page + 4
	return bag_num * BAG_PAGE_COUNT
end

function PackageView:BagRefreshCell(index, cellObj)
	--构造Cell对象.
	local cell = self.bag_cell[cellObj]
	if nil == cell then
		cell = PlayerPackageCell.New(cellObj)
		cell:SetToggleGroup(self.bag_cell.toggle_group)
		cell:SetHideEffect(true)
		self.bag_cell[cellObj] = cell
	end

	if (index + 1) % 5 == 0 then
		for k, v in pairs(self.bag_cell) do
			v:ResetUpArrowAni()
		end
	end

	local page = math.floor(index / BAG_PAGE_COUNT)
	local cur_colunm = math.floor(index / BAG_ROW) + 1 - page * BAG_COLUMN
	local cur_row = math.floor(index % BAG_ROW) + 1
	local grid_index = (cur_row - 1) * BAG_COLUMN - 1 + cur_colunm + page * BAG_ROW * BAG_COLUMN
	-- 获取数据信息
	local data = nil
	if self.show_state == SHOW_MATIERAL then
		data = PackageData.Instance:GetCellData(grid_index, GameEnum.TOGGLE_INFO.MATERIAL_TOGGLE)
	elseif self.show_state == SHOW_EQUIP then
		data = PackageData.Instance:GetCellData(grid_index, GameEnum.TOGGLE_INFO.EQUIP_TOGGLE)
	elseif self.show_state == SHOW_CONSUME then
		data = PackageData.Instance:GetCellData(grid_index, GameEnum.TOGGLE_INFO.CONSUME_TOGGLE)
	else
		data = PackageData.Instance:GetCellData(grid_index, GameEnum.TOGGLE_INFO.ALL_TOGGLE)
	end
	data = data or {}
	local cell_data = {}
	cell_data.item_id = data.item_id
	cell_data.index = data.index or grid_index
	cell_data.param = data.param
	cell_data.num = data.num
	cell_data.locked = grid_index >= ItemData.Instance:GetMaxKnapsackValidNum()
	cell_data.is_bind = data.is_bind
	cell_data.invalid_time = data.invalid_time

	cell:SetIconGrayScale(false)
	cell:ShowQuality(nil ~= cell_data.item_id)
	cell:SetData(cell_data, true)
	cell:ShowHighLight(false)
	cell:SetHighLight(self.cur_index == grid_index and nil ~= cell_data.item_id and self.view_state ~= BAG_SHOW_RECYCLE)
	cell:SetLimitUse()
	cell:ListenClick(BindTool.Bind(self.HandleBagOnClick, self, cell_data, cell))
	cell:SetInteractable((nil ~= cell_data.item_id or cell_data.locked))
	local recycle_list = PackageData.Instance:GetRecycleItemDataList()
	for k,v in pairs(recycle_list) do
		if cell_data.item_id == v.item_id and cell_data.index == v.index then
			cell:SetIconGrayScale(true)
			cell:ShowExtremeEffect(false)
			cell:ShowQuality(false)
		end
	end
end

--点击格子事件
function PackageView:HandleBagOnClick(data, cell, is_click)
	if not is_click then return end
	if data.locked then
		-- local vip_type = VipData.Instance:GetVipType(VIP_TYPE_CELL_COUNT)
		-- local neex_vip = 0
		-- for i = 15, 1, -1 do
		-- 	if data.index > vip_type["param_" .. i] then
		-- 		break
		-- 	end
		-- 	neex_vip = i
		-- end

		-- TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Vip.OpenMoreBagCell, neex_vip))
		-- VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
		-- ViewManager.Instance:Open(ViewName.VipView)
		local num = data.index - ItemData.Instance:GetMaxKnapsackValidNum() + 1
		local had_item_num = ItemData.Instance:GetItemNumInBagById(ItemDataKnapsackId.Id)
		local item_cfg = ItemData.Instance:GetItemConfig(ItemDataKnapsackId.Id)
		local shop_item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[ItemDataKnapsackId.Id]
		local need_number = PackageData.Instance:GetOpenCellNeedItemNum(ItemDataKnapsackId.Id, data.index)
		local func_gold = function ()
			PackageCtrl.Instance:SendKnapsackStorageExtendGridNum(GameEnum.STORAGER_TYPE_BAG, num, shop_item_cfg.gold * (need_number - had_item_num))
		end
		local func_enough = function ()
			PackageCtrl.Instance:SendKnapsackStorageExtendGridNum(GameEnum.STORAGER_TYPE_BAG, num)
		end
		local close_callback = function()
			cell:SetHighLight(false)
		end
		if item_cfg and num > 0 then
			if need_number - had_item_num > 0 then
				local str = string.format(Language.BackPack.KaiQiBeiBaoBuZu, num, need_number, item_cfg.name, need_number - had_item_num,
					shop_item_cfg.gold * (need_number - had_item_num))
				TipsCtrl.Instance:ShowCommonAutoView(nil, str, func_gold, close_callback)
			else
				local str = string.format(Language.BackPack.KaiQiBeiBaoZu, num, need_number, item_cfg.name, had_item_num)
				TipsCtrl.Instance:ShowCommonAutoView(nil, str, func_enough, close_callback)
			end
		end
		cell:SetHighLight(false)
		return
	end
	if not data or not data.item_id or data.item_id <=  0 then
		return
	end

	cell:SetHighLight(true)
	local close_callback = function ()
		self.cur_index = nil
		cell:SetHighLight(false)
	end

	self.cur_index = data.index
	cell:SetHighLight(self.view_state ~= BAG_SHOW_RECYCLE)
	-- 弹出面板
	local item_cfg1, big_type1 = ItemData.Instance:GetItemConfig(data.item_id)
	if nil ~= item_cfg1 then
		if self.view_state == BAG_SHOW_STORGE then
			TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_BAG_ON_BAG_STORGE, nil, close_callback)
		elseif self.view_state == BAG_SHOW_SALE then
			TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_BAG_ON_BAG_SALE,{{fromIndex = data.index}})
		elseif self.view_state == BAG_SHOW_SALE_JL then
			TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_BAG_ON_BAG_SALE_JL, {fromIndex = data.index})
		elseif (item_cfg1.recycltype == 6 or item_cfg1.recycltype == 9 or item_cfg1.recycltype == 10) and self.view_state == BAG_SHOW_RECYCLE and big_type1 == GameEnum.ITEM_BIGTYPE_EQUIPMENT and not DouQiData.Instance:IsDouqiEqupi(data.item_id) then
			if not cell.quality_enbale then
				TipsCtrl.Instance:ShowSystemMsg(Language.Package.HaveLock)
			else
				PackageData.Instance:AddItemToRecycleList(data)
				cell:SetIconGrayScale(true)
				cell:ShowExtremeEffect(false)
				self:FlushBagView()
				GlobalEventSystem:Fire(OtherEventType.RECYCLE_FLUSH_CONTENT)
			end
		elseif item_cfg1.use_type == GameEnum.TIANSHENHUTI_EQUIP_USE_TYPE then 		-- 周末装备处理
			local equip_cfg = TianshenhutiData.Instance:GetEquipCfgByItemId(item_cfg1.id)
			if equip_cfg then
				data.suit_id = equip_cfg.equip_id
			end
			TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_BAG, nil, close_callback)
		else
			TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_BAG, nil, close_callback)
		end
	end
end

function PackageView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	if self.view_state == BAG_SHOW_STORGE and index < COMMON_CONSTS.MAX_BAG_COUNT then
		-- local page = math.floor(index / (BAG_COLUMN * BAG_ROW)) + 1
		-- self.current_page = page
		-- self.node_list["PageToggle" .. self.current_page].toggle.isOn = true
	elseif self.view_state == BAG_SHOW_STORGE and index - COMMON_CONSTS.MAX_BAG_COUNT >= 0 then
		-- 刷新仓库
		if self.warehouse_view then
			self.warehouse_view:FlushWarehouseView(index)
		end
	end

	self:FlushBagView()
end

function PackageView:BagJumpPage(page)
	if not self.node_list["ListView"].list_view.isActiveAndEnabled then
		return
	end

	self.node_list["ListView"].list_page_scroll2:JumpToPage(page - 1)
end

--刷新声望
function PackageView:MoJingChange()
	local mojing = ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.MOJING)
	local value = tonumber(mojing)
	if self.node_list["TextMojing"] then
		self.node_list["TextMojing"].text.text = CommonDataManager.ConverNum(value)
	end
end

function PackageView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.RecycleButton then
		if self.node_list["RecycleButton"] then
			return self.node_list["RecycleButton"], BindTool.Bind(self.HandleOpenRecycle, self)
		end
	elseif ui_name == GuideUIName.RecycleAndCloseButton then
		if self.recycle_view then
			return self.recycle_view:RecycleAndBtn()
		end
	elseif self.node_list[ui_name] then
		if self.node_list[ui_name].gameObject.activeInHierarchy then
			return self.node_list[ui_name]
		end
	end
end

function PackageView:OnClickGold(click_type)
	if click_type == CLICK_TYPE.BIND_GOLD then
		TipsCtrl.Instance:OpenItem({item_id = COMMON_CONSTS.VIRTUAL_ITEM_BINDGOL})
	elseif click_type == CLICK_TYPE.GOLD then
		TipsCtrl.Instance:OpenItem({item_id = COMMON_CONSTS.VIRTUAL_ITEM_GOLD})
	elseif click_type == CLICK_TYPE.STAR then
		TipsCtrl.Instance:OpenItem({item_id = COMMON_CONSTS.VIRTUAL_ITEM_MOJINT})
	end
end


----------------------PackageCell------------------------------------
PlayerPackageCell = PlayerPackageCell or BaseClass(ItemCell)

function PlayerPackageCell:__init()
end

function PlayerPackageCell:__delete()
	self:Closedelete()
end

function PlayerPackageCell:Closedelete()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	if self.prefab then
		ResMgr:Destroy(self.prefab.gameObject)
		self.prefab = nil
	end
	if self.lock_count_down then
		self.lock_count_down:DeleteMe()
		self.lock_count_down = nil
	end
end

function PlayerPackageCell:SetData(data, ...)
	ItemCell.SetData(self, data, ...)
	self:FlushTime()
end

function PlayerPackageCell:FlushTime()
	if self.data then
		if self.prefab then
			self:Closedelete()
		end

		if self.data.index == ItemData.Instance:GetMaxKnapsackValidNum() then
			self:ShowLockCellCountDown(true)
		else
			self:ShowLockCellCountDown(false)
		end
	end
end

function PlayerPackageCell:ShowLockCellCountDown(enable)
	if enable == true then
		if not self.lock_count_down then
			local async_loader = AllocResAsyncLoader(self, "LockCountDown")
			async_loader:Load("uis/views/player_prefab", "LockCountDown", nil,
				function(prefab)
					if IsNil(self.root_node.transform) then
						ResMgr:Destroy(prefab)
						return
					end

					local obj = U3DObject(ResMgr:Instantiate(prefab))
					obj.transform:SetParent(self.root_node.transform, false)
					self.prefab = obj
				 	self.lock_count_down = LockCountDown.New(obj)
					self:StartCountDown()
				end)
		else
			self.lock_count_down:SetActive(true)
			self:StartCountDown()
		end
	elseif self.lock_count_down then
		self.lock_count_down:DeleteMe()
		self.lock_count_down = nil
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
end

function PlayerPackageCell:StartCountDown()
	if self.time_quest == nil then
		self:FlushLockSlider()
		-- self.lock_count_down.root_node.transform.position = self.root_node.transform.position
		self.time_quest = GlobalTimerQuest:AddRunQuest(function()
			self:FlushLockSlider()
		end, 1)
	end
end
--刷新倒计时
function PlayerPackageCell:FlushLockSlider()
	local online_time = PackageCtrl.Instance:GetOnlineTime() or 0							--人物在线时间
	local next_open_time = PackageData.Instance:GetNextKnapsackAutoAddTime() or 0			--开启当前锁定格子所需的在线时间
	local before_open_time = PackageData.Instance:GetBeforeKnapsackAutoAddTime() or 0		--开启上一个已开启的格子所需的在线时间
	self.lock_count_down.root_node.slider.value = 1 - (online_time - before_open_time) / (next_open_time - before_open_time)
	local need_online_time = next_open_time - online_time
	local str = ""
	if need_online_time >= 0 then
		local time_tab = TimeUtil.Format2TableDHMS(need_online_time)
		if time_tab.day ~= 0 then
			str = string.format(Language.Common.TimeStr8, time_tab.day, time_tab.hour)
		elseif time_tab.hour ~= 0 then
			str = string.format(Language.Common.TimeStr9, time_tab.hour, time_tab.min)
		elseif time_tab.min ~= 0 then
			str = string.format(Language.Common.TimeStr6, time_tab.min, time_tab.s)
		else
			str = string.format(Language.Common.TimeStr7, time_tab.s)
		end
	end
	self.lock_count_down:SetText(str)
end

----------------------LockCountDown------------------------------------
LockCountDown = LockCountDown or BaseClass(BaseRender)

function LockCountDown:__init()
end

function LockCountDown:__delete()
	-- GameObject.Destroy(self.root_node.gameObject)
end

function LockCountDown:SetText(str)
	self.node_list["LockCellCountDownText"].text.text = str
end