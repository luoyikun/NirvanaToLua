ShenMiContentView = ShenMiContentView or BaseClass(BaseRender)

local EFFECT_CD = 0.3
local PLAY_TIME = 10
local MAX_PAGE = 2

function ShenMiContentView:__init()
	self:InitListView()
	self.disply_cell_list = {}
	self:ChangeScroller()
end

function ShenMiContentView:__delete()
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.item_data = {}

	if self.disply_cell_list then
		for k,v in pairs(self.disply_cell_list) do
			v:DeleteMe()
		end
		self.disply_cell_list = {}
	end

	if self.runquest_auto_move then
		GlobalTimerQuest:CancelQuest(self.runquest_auto_move)
		self.runquest_auto_move = nil
	end
end

function ShenMiContentView:InitListView()
	self.cell_list = {}
	self.item_data = {}
	self.list_view = self.node_list["shenmi_list_view"]

	local list_delegate = self.node_list["shenmi_list_view"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.node_list["ListView"].scroller.scrollerScrollingChanged = function(scroller, is_scrolling)
		if is_scrolling == true then
			if nil ~= self.runquest_auto_move then
				GlobalTimerQuest:CancelQuest(self.runquest_auto_move)
				self.runquest_auto_move = nil
			end
		elseif is_scrolling == false then
			self:PlayPage()
		end
	end

	for i = 1, 2 do
		self.node_list["Toggle" .. i].toggle:AddClickListener(BindTool.Bind(self.OnClickToggle, self, i))
	end
end

function ShenMiContentView:OnClickToggle(i)
	self:PlayPage()
end

function ShenMiContentView:ChangeScroller()
	local delegate = self.node_list["ListView"].list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return MAX_PAGE
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.disply_cell_list[cell]
		if nil == target_cell then
			self.disply_cell_list[cell] = ShopDisPlayCell.New(cell.gameObject)
			target_cell = self.disply_cell_list[cell]
			target_cell:SetShowIndex(data_index)
		end
	end
end

function ShenMiContentView:PlayPage()
	if nil ~= self.runquest_auto_move then
		GlobalTimerQuest:CancelQuest(self.runquest_auto_move)
		self.runquest_auto_move = nil
	end
	self.runquest_auto_move = GlobalTimerQuest:AddRunQuest(function()
		if self.node_list["ListView"] and self.node_list["ListView"].scroller.isActiveAndEnabled then
			local page = self.node_list["ListView"].list_page_scroll:GetNowPage() + 1
			if page >= MAX_PAGE then
				page = 0
			end
			self.node_list["ListView"].list_page_scroll:JumpToPage(page)
		end
	end, PLAY_TIME) 
end



function ShenMiContentView:GetNumberOfCells()
	return math.ceil(#ShopData.Instance:GetShenMiShop().seq_list / 2)
end

function ShenMiContentView:RefreshCell(cell, cell_index)
	local shop_cell = self.cell_list[cell]
	if nil == shop_cell then
		shop_cell = ShenMiItemCellGroup.New(cell.gameObject)
		self.cell_list[cell] = shop_cell
	end
	shop_cell:SetCellIndex(cell_index)
	for i = 1, 2 do
		local index = cell_index * 2 + i
		local data = ShopData.Instance:GetMysteriousShopItemCfg(index)
		shop_cell:SetIndex(i, index)
		shop_cell:SetData(i, data)
	end
end

function ShenMiContentView:PlayEffect()
	local flush_type = ShopData.Instance:GetSendType()
	for k, v in pairs(self.cell_list) do
		if v.index and v.index == 0 and flush_type == 0 then
			v:PlayEffect(1)
		elseif flush_type == 1 then
			v:PlayEffect(1)
			v:PlayEffect(2)
		end
	end
end

function ShenMiContentView:FlushView()
	self.node_list["shenmi_list_view"].scroller:ReloadData(0)
	self.node_list["ListView"].scroller:RefreshActiveCellViews()

	self:PlayPage()
end

-----------------------------ShenMiItemCellGroup--------------------------
ShenMiItemCellGroup = ShenMiItemCellGroup or BaseClass(BaseRender)

function ShenMiItemCellGroup:__init()
	self.cell_list = {}
	for i = 1, 2 do
		local cell = ShenMiItemCell.New(self.node_list["item_" .. i])
		table.insert(self.cell_list, cell)
	end
end

function ShenMiItemCellGroup:__delete()
	for k, v in ipairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function ShenMiItemCellGroup:SetToggleGroup()

end

function ShenMiItemCellGroup:SetData(i, data)
	if data == nil then
		self.cell_list[i]:SetActive(false)
		return
	end
	self.cell_list[i]:SetActive(true)
	self.cell_list[i]:SetData(data)
end

function ShenMiItemCellGroup:SetIndex(i, index)
	self.cell_list[i]:SetIndex(index)
end

function ShenMiItemCellGroup:SetCellIndex(index)
	self.index = index
end

function ShenMiItemCellGroup:PlayEffect(i)
	self.cell_list[i]:PlayEffect()
end

-----------------------------ShenMiItemCell--------------------------
ShenMiItemCell = ShenMiItemCell or BaseClass(BaseCell)
function ShenMiItemCell:__init(instance)
	self.node_list["NodeItem"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["Cellitem"])
	self.item_cell:ShowHighLight(false)
	self.effect_cd = 0
end

function ShenMiItemCell:__delete()
	self.item_cell:DeleteMe()
end

function ShenMiItemCell:OnClick()
	if self.data ~= nil and nil ~= self.data.item then
		local item_cfg = ItemData.Instance:GetItemConfig(self.data.item.item_id)
		local zhekou = self.data.dicount * 0.001
		local zhekou_price = math.max(math.floor(self.data.dicount * 0.0001 * self.data.price), 1)
		ViewManager.Instance:FlushView(ViewName.Shop, "shenmishop_view", {item_cfg, zhekou_price, self.index, self.data.item.num})
	end
end
function ShenMiItemCell:PlayEffect()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		local bundle_name, asset_name = ResPath.GetUiXEffect("UI_bkbx")

		EffectManager.Instance:PlayEffect(
			bundle_name,
			asset_name,
			self.node_list["EffectRoot"].transform,
			function (obj)
				GlobalTimerQuest:AddDelayTimer(function()
					if not IsNil(obj) then
						ResPoolMgr:Release(obj)
					end
				end, 0.5)
		end)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end

function ShenMiItemCell:OnFlush()
	if self.data == nil or self.data.item ==nil then
		return
	end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item.item_id)
	self.root_node.gameObject:SetActive(item_cfg ~= nil)
	if nil == item_cfg then return end
	local zhekou = self.data.dicount * 0.001
	local zhekou_price = math.max(math.floor(self.data.dicount * 0.0001 * self.data.price), 1)
	local shenmi_shop_info = ShopData.Instance:GetShenMiShop()
	if nil == self.data then return end
	local str = ""
	if self.data.item.num == 1 then 
		str = item_cfg.name
	else
		str = string.format("%s*<size=22>%s</size>", item_cfg.name, self.data.item.num)
	end
	self.node_list["TxtName"].text.text = ToColorStr(str, ITEM_COLOR[item_cfg.color])
	self.node_list["TxtValue"].text.text = ToColorStr(self.data.price, "#BA3E07FF")
	self.node_list["TxtValue1"].text.text = ToColorStr(zhekou_price, "#BA3E07FF")
	self.item_cell:SetData(self.data.item)
	self.item_cell:SetCellSize(100)
	self.item_cell:SetRedPoint(false)
	self.node_list["ImgIsBuyy"]:SetActive(shenmi_shop_info.seq_list[self.index].state == 1)

	if zhekou >= 10 then
		self.node_list["ImgZhekou1"]:SetActive(false)
		self.node_list["ImgZhekou3"]:SetActive(false)
		self.node_list["ImRredLine"]:SetActive(false)
		self.node_list["ImgZheKou"]:SetActive(false)
	end

	if zhekou < 10 then
		local zhekou_bundle,zhekou_asset = ResPath.GetZheKou("discount_" .. math.floor(zhekou))
		self.node_list["ImgZheKou"].image:LoadSprite(zhekou_bundle,zhekou_asset, 
			function()
				self.node_list["ImgZheKou"].image:SetNativeSize() 
			end)
		self.node_list["ImgZheKou"]:SetActive(true)
		self.node_list["ImRredLine"]:SetActive(true)
		if self.data.banner == 3 then
			local bundle, asset = ResPath.GetZheKou(self.data.banner)
			self.node_list["ImgZhekou1"]:SetActive(false)
			self.node_list["ImgZhekou3"]:SetActive(true)
			self.node_list["ImgZhekou1"].image:LoadSprite(bundle, asset)
			self.node_list["ImgZhekou3"].image:LoadSprite(bundle, asset)
			self.node_list["ImgZhekou3"].rect.anchoredPosition = Vector3(-15, 15, 0)
			self.node_list["ImgZheKou"].rect.anchoredPosition = Vector3(0, 0, 0)
		else
			local bundle, asset = ResPath.GetZheKou(self.data.banner)
			self.node_list["ImgZhekou1"]:SetActive(true)
			self.node_list["ImgZhekou3"]:SetActive(false)
			self.node_list["ImgZhekou1"].image:LoadSprite(bundle, asset)
			self.node_list["ImgZhekou3"].image:LoadSprite(bundle, asset)
			self.node_list["ImgZhekou3"].rect.anchoredPosition = Vector3(-5, 9, 0)
			self.node_list["ImgZheKou"].rect.anchoredPosition = Vector3(4, -4, 0)
		end
	end
end

-------------------------------------------------ShopDisPlayCell----------------------------
ShopDisPlayCell = ShopDisPlayCell or BaseClass(BaseRender)

function ShopDisPlayCell:__init()
	self.item_cell = {}
	for i = 1, 8 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Item" .. i])
		item:SetData(nil)
		table.insert(self.item_cell, item)
	end
	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display,MODEL_CAMERA_TYPE.BASE)
end

function ShopDisPlayCell:__delete()
	for k, v in pairs(self.item_cell) do
		v:DeleteMe()
	end
	self.item_cell = {}

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
end

function ShopDisPlayCell:SetShowIndex(index)
	self.show_index = index
	self:SetDisPlayType()
end

function ShopDisPlayCell:SetDisPlayType()
	self.node_list["ShowGoddess"]:SetActive(self.show_index == 1)
	self.node_list["ShowHightItem"]:SetActive(self.show_index ~= 1)

	if self.show_index == 1 then 
		self.model:ResetRotation()
		ItemData.ChangeModel(self.model, 26406) 					--子豪说写死仙女第七个\
	else
		local item_list = ShopData.Instance:GetTeHuiShopItemCfg()
		if nil == item_list then
			return
		end
		for k, v in pairs(self.item_cell) do
			if item_list[k] then
				self.node_list["Image" .. k]:SetActive(item_list[k].is_new == 1)
				v:SetData(item_list[k])
			else
				self.node_list["Image" .. k]:SetActive(false)
				v:SetData(nil)
			end
		end
	end
end

--------------------------------- 特惠 --------------------------------
TeHuiContentView = TeHuiContentView or BaseClass(BaseRender)

function TeHuiContentView:__init(instance)
	self.contain_cell_list = {}
	self.current_item_id = -1
	self.current_shop_type = 1
	self:InitListView()
	self.cellitem_id = 0
	self.item_list_num = 0
	self.select_seq = -1
end

function TeHuiContentView:__delete()
	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}
end

function TeHuiContentView:InitListView()
	self.list_view = self.node_list["list_view"]
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function TeHuiContentView:GetNumberOfCells()
	local item_id_num = self.item_list_num
	if item_id_num % SHOP_COL_ITEM ~= 0 then
		return math.floor(item_id_num / SHOP_COL_ITEM) + 1
	else
		return item_id_num / SHOP_COL_ITEM
	end
end

function TeHuiContentView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = TeHuiContain.New(cell.gameObject)
		contain_cell:SetClickCallBack(BindTool.Bind(self.TeHuiShopItemClick, self))
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	local item_id_list = ShopData.Instance:GeITeHuitemListIndex(cell_index)
	contain_cell:InitItems(item_id_list)
end

function TeHuiContentView:TeHuiShopItemClick(cell)
	local cell_data = cell:GetData()
	if cell_data == nil or next(cell_data) == nil then return end

	self.select_seq = cell_data.seq
	self:OnFlushHighLight()
	ViewManager.Instance:FlushView(ViewName.Shop, "xin_xi", {cell.item_id, SHOP_BIND_TYPE.NO_BIND, cell_data})
end

function TeHuiContentView:SetCellID(cell_id)
	self.cellitem_id = cell_id
end

function TeHuiContentView:FlushView()
	self.item_list_num = ShopData.Instance:GetTeHuiItemIdList() or 0
end

function TeHuiContentView:FormatMoney(value)
	return CommonDataManager.ConverMoney(value)
end

function TeHuiContentView:OnFlushListView()
	self.cellitem_id = 0
	self:OnFlushHighLight()
	self.list_view.scroller:ReloadData(0)
end

function TeHuiContentView:OnFlushHighLight()
	for k,v in pairs(self.contain_cell_list) do
		v:FlushHL(self.select_seq)
	end
end

-----------------------------------------------------------------------
TeHuiContain = TeHuiContain  or BaseClass(BaseRender)
function TeHuiContain:__init()
	self.shop_contain_list = {}
	for i = 1, SHOP_COL_ITEM do
		self.shop_contain_list[i] = TeHuiShopItem.New(self.node_list["item_" .. i])
	end
end

function TeHuiContain:__delete()
	for i = 1, SHOP_COL_ITEM do
		self.shop_contain_list[i]:DeleteMe()
		self.shop_contain_list[i] = nil
	end
end

function TeHuiContain:InitItems(item_id_list)
	for i = 1, SHOP_COL_ITEM do
		if item_id_list[i] and next(item_id_list[i]) then
			self.shop_contain_list[i]:SetItemId(item_id_list[i])
			self.shop_contain_list[i]:OnFlush()
			self.shop_contain_list[i]:SetActive(true)
		else
			self.shop_contain_list[i]:SetActive(false)
		end
	end
end

function TeHuiContain:OnFlushItems()
	for i = 1, SHOP_COL_ITEM do
		self.shop_contain_list[i]:OnFlush()
	end
end

function TeHuiContain:SetClickCallBack(callback)
	for i = 1, SHOP_COL_ITEM do
		self.shop_contain_list[i]:SetClickCallBack(callback)
	end
end

function TeHuiContain:FlushHL(seq)
	for i = 1, SHOP_COL_ITEM do
		self.shop_contain_list[i]:FlushHighLight(seq)
	end
end
------------------------------------------------------------------
TeHuiShopItem = TeHuiShopItem or BaseClass(BaseCell)
function TeHuiShopItem:__init()
	self.node_list["Item"].button:AddClickListener(BindTool.Bind(self.Click, self))
	self.node_list["LimitBuy"]:SetActive(false)
	self.node_list["highlight"]:SetActive(false)

	self.item_id = 0
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["item"])
	self.item_cell:ShowHighLight(false)
end

function TeHuiShopItem:Click()
	self:OnClick()

	-- TeHuiContentView.Instance:OnFlushHighLight()
end

function TeHuiShopItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	self.item_id = 0
end

function TeHuiShopItem:SetItemId(data)
	self.item_id = data.item and data.item.item_id or 0
	self.data = data
end

function TeHuiShopItem:SetItemIndex(item_index)
	self.item_index = item_index
end

function TeHuiShopItem:FlushHighLight(seq)
	if self.data and self.data.seq and seq then
		self.node_list["highlight"]:SetActive(seq == self.data.seq)
		local count = ShopData.Instance:GetDiscounthopItemBuyCount(self.data.seq)
		self.node_list["ImgIsBuyy"]:SetActive(count <= 0)
	end
end

function TeHuiShopItem:OnFlush()
	self.root_node:SetActive(true)
	local shop_item_data = ShopData.Instance:GetTeHuiShopItemCfg(self.item_id)
	if self.item_id == 0 or shop_item_data == nil or self.data == nil or self.data.item == nil then
		self.root_node:SetActive(false)
		return
	end
	-- local consume_type = ShopData.Instance:GetConsumeType(TeHuiContentView.Instance:GetCurrentShopType())
	local cfg = ItemData.Instance:GetItemConfig(self.item_id)
	local data = {}
	data.item_id = self.item_id
	data.num = self.data.item.num
	data.is_bind = self.data.item.is_bind

	self.node_list["normal_value"].text.text = self.data.earlier_price or 0
	self.node_list["zhekou_value"].text.text = self.data.price or 0
	self.node_list["ItemText"].text.text = ToColorStr(cfg.name, ITEM_COLOR[cfg.color])
	self.item_cell:SetData(data)
	self.item_cell:SetCellSize(100)
	self.item_cell:SetRedPoint(false)
	self.node_list["normal_price"]:SetActive(true)
	self.node_list["zhekou_price"]:SetActive(true)
	self.node_list["GoldPanle"]:SetActive(false)

	local count = ShopData.Instance:GetDiscounthopItemBuyCount(self.data.seq)
	self.node_list["ImgIsBuyy"]:SetActive(count <= 0)
	self:FlushHighLight()

	local zhekou = self.data.banner
	if zhekou >= 10 then
		self.node_list["ImgZhekou1"]:SetActive(false)
		self.node_list["ImgZhekou3"]:SetActive(false)
		self.node_list["ImgZheKou"]:SetActive(false)
	end

	if zhekou < 10 then
		local zhekou_bundle,zhekou_asset = ResPath.GetZheKou("discount_" .. math.floor(zhekou))
		self.node_list["ImgZheKou"].image:LoadSprite(zhekou_bundle,zhekou_asset, 
			function()
				self.node_list["ImgZheKou"].image:SetNativeSize() 
			end)
		self.node_list["ImgZheKou"]:SetActive(true)
		self.node_list["ImgZhekou1"]:SetActive(self.data.banner > 5)
		self.node_list["ImgZhekou3"]:SetActive(self.data.banner <= 5)
	end
end
