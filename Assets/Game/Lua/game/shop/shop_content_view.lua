ShopContentView = ShopContentView or BaseClass(BaseRender)

function ShopContentView:__init(instance)
	ShopContentView.Instance = self
	self.contain_cell_list = {}
	self.current_item_id = -1
	self.current_shop_type = 1
	self:InitListView()
	self.item_data_event = nil
	self.cellitem_id = 0
end

function ShopContentView:__delete()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}
	ShopContentView.Instance = nil
end

function ShopContentView:InitListView()
	self.list_view = self.node_list["list_view"]
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function ShopContentView:GetNumberOfCells()
	local item_id_list = ShopData.Instance:GetItemIdListType(self.current_shop_type)
	if #item_id_list % SHOP_COL_ITEM ~= 0 then
		return math.floor(#item_id_list / SHOP_COL_ITEM) + 1
	else
		return #item_id_list / SHOP_COL_ITEM
	end
end

function ShopContentView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = ShopContain.New(cell.gameObject)
		contain_cell:SetClickCallBack(BindTool.Bind(self.ShopItemClick, self))
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	local item_id_list = ShopData.Instance:GetItemListByTypeAndIndex(self.current_shop_type, cell_index)
	contain_cell:InitItems(item_id_list)
end

function ShopContentView:ShopItemClick(cell)
	local item_id = cell.item_id
	ViewManager.Instance:FlushView(ViewName.Shop, "xin_xi", {item_id, ShopData.Instance:GetConsumeType(self:GetCurrentShopType())})
end

function ShopContentView:SetCellID(cell_id)
	self.cellitem_id = cell_id
end

function ShopContentView:SetCurrentShopType(shop_type)
	self.current_shop_type = shop_type
	local res_id = 0
	local consume_type = ShopData.Instance:GetConsumeType(shop_type)
	if consume_type == 1 then
		res_id = 3
	else
		res_id = 2
	end
end

function ShopContentView:FormatMoney(value)
	return CommonDataManager.ConverMoney(value)
end

function ShopContentView:GetCurrentShopType()
	return self.current_shop_type
end

function ShopContentView:OnFlushListView()
	self.cellitem_id = 0
	self:OnFlushHighLight()
	self.list_view.scroller:ReloadData(0)
end

--移除物品回调
function ShopContentView:RemoveNotifyDataChangeCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

function ShopContentView:OnFlushHighLight()
	for k,v in pairs(self.contain_cell_list) do
		v:FlushHL()
	end
end

-----------------------------------------------------------------------
ShopContain = ShopContain  or BaseClass(BaseRender)
function ShopContain:__init()
	self.shop_contain_list = {}
	for i = 1, SHOP_COL_ITEM do
		self.shop_contain_list[i] = ShopItem.New(self.node_list["item_" .. i])
	end
end

function ShopContain:__delete()
	for i = 1, SHOP_COL_ITEM do
		self.shop_contain_list[i]:DeleteMe()
		self.shop_contain_list[i] = nil
	end
end

function ShopContain:InitItems(item_id_list)
	for i = 1, SHOP_COL_ITEM do
		self.shop_contain_list[i]:SetItemId(item_id_list[i])
		self.shop_contain_list[i]:OnFlush()
	end
end

function ShopContain:OnFlushItems()
	for i = 1, SHOP_COL_ITEM do
		self.shop_contain_list[i]:OnFlush()
	end
end

function ShopContain:SetClickCallBack(callback)
	for i = 1, SHOP_COL_ITEM do
		self.shop_contain_list[i]:SetClickCallBack(callback)
	end
end

function ShopContain:FlushHL()
	for i = 1, SHOP_COL_ITEM do
		self.shop_contain_list[i]:FlushHighLight()
	end
end
------------------------------------------------------------------
ShopItem = ShopItem or BaseClass(BaseCell)
function ShopItem:__init()
	self.node_list["Item"].button:AddClickListener(BindTool.Bind(self.Click, self))
	self.node_list["LimitBuy"]:SetActive(false)
	self.item_id = 0
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["item"])
	self.item_cell:ShowHighLight(false)
	-- self.item_cell:ListenClick(function () self:Click() end)
end

function ShopItem:Click()
	self:OnClick()
	ShopContentView.Instance.cellitem_id = self.item_id
	ShopContentView.Instance:OnFlushHighLight()
end

function ShopItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	self.item_id = 0
end

function ShopItem:SetItemId(item_id)
	self.item_id = item_id or 0
end

function ShopItem:SetItemIndex(item_index)
	self.item_index = item_index
end

function ShopItem:FlushHighLight()
	self.node_list["highlight"]:SetActive(ShopContentView.Instance.cellitem_id == self.item_id)
end

function ShopItem:OnFlush()
	self.root_node:SetActive(true)
	local shop_item_data = ShopData.Instance:GetShopItemCfg(self.item_id)
	if self.item_id == 0 or shop_item_data == nil then
		self.root_node:SetActive(false)
		return
	end
	local consume_type = ShopData.Instance:GetConsumeType(ShopContentView.Instance:GetCurrentShopType())
	local cfg = ItemData.Instance:GetItemConfig(self.item_id)
	local data = {}
	data.item_id = self.item_id
	local res_id = 0
	if consume_type == 1 then
		res_id = '5_bind'
		data.is_bind = 1
	else
		res_id = 5
		data.is_bind = 0
	end
	local bundle, asset = ResPath.GetDiamonIcon(res_id)
	self.node_list["GoldText"].image:LoadSprite(bundle, asset)
	local gold = consume_type == 1 and shop_item_data.bind_gold or shop_item_data.gold
	self.node_list["GoldTextNode"].text.text = gold
	self.node_list["ItemText"].text.text = ToColorStr(cfg.name, ITEM_COLOR[cfg.color])
	self.item_cell:SetData(data)
	self.item_cell:SetCellSize(100)
	self.item_cell:SetRedPoint(false)
	self:FlushHighLight()

	self.node_list["normal_price"]:SetActive(false)
	self.node_list["zhekou_price"]:SetActive(false)
end
