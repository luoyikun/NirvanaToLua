JiFenShopView = JiFenShopView or BaseClass(BaseView)
function JiFenShopView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondShopView"},
		{"uis/views/jifenshop_prefab", "JiFenShop"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.full_screen = false
	self.play_audio = true
	self.cell_list = {}
	self.jifen_index = nil
	self.jifen_price = nil
end

function JiFenShopView:ReleaseCallBack()
	self.jifenshop = nil
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end

	self.jifen_index = nil
	self.jifen_price = nil
	self.my_jifen = nil

	self.cell_list = {}
end

function JiFenShopView:OpenCallBack()
	self:Flush()
end

function JiFenShopView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(820, 550, 0)
	self.node_list["Txt"].text.text = Language.Shop.JiFenShop

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.ShopClose, self))

	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.node_list["coin_img"].button:AddClickListener(function ()
			TipsCtrl.Instance:OpenItem({item_id = COMMON_CONSTS.VIRTUAL_ITEM_JIFEN})
		end)
end

function JiFenShopView:OnFlush()
	self.node_list["TxtZJifenCount"].text.text = ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.JIFEN)
end

function JiFenShopView:ShopClose()
	self:Close()
end

function JiFenShopView:GetNumberOfCells()
	local num = math.ceil(#ShopData.Instance:GetJifenItemListCfg() / 2)
	if nil ~= num then
		return num
	end
	return 0
end

function JiFenShopView:RefreshCell(cell, cell_index)
	local shop_cell = self.cell_list[cell]
	if nil == shop_cell then
		shop_cell = ShopItemCellGroup.New(cell.gameObject)
		self.cell_list[cell] = shop_cell
	end

	for i = 1, 2 do
		local index = cell_index * 2 + i
		local data = ShopData.Instance:GetJifenItemCfg(index)
		shop_cell:SetData(i, data)
	end
end

-----------------------------ShopItemCellGroup--------------------------
ShopItemCellGroup = ShopItemCellGroup or BaseClass(BaseRender)

function ShopItemCellGroup:__init()
	self.cell_list = {}
	for i = 1, 2 do
		local cell = ShopItemCell.New(self.node_list["item_" .. i])
		table.insert(self.cell_list, cell)
	end
end

function ShopItemCellGroup:__delete()
	for k, v in ipairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function ShopItemCellGroup:SetToggleGroup()

end

function ShopItemCellGroup:SetData(i, data)
	self.cell_list[i]:SetData(data)
end

-----------------------------ShopItemCell--------------------------
ShopItemCell = ShopItemCell or BaseClass(BaseCell)
function ShopItemCell:__init()

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["item"])
	self.item_cell:ShowHighLight(false)
	self.node_list["BtnDuihuan"].button:AddClickListener(BindTool.Bind(self.OnClickExchange, self))
end

function ShopItemCell:__delete()
	self.item_cell:DeleteMe()
end

function ShopItemCell:OnClickExchange()
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg then
		return
	end

	local item_id = self.data.item_id
	local price = ItemData.Instance:GetItemConfig(self.data.item_id).price

	ShopCtrl.Instance:SendMysteriosshopOperate(self.data.conver_type, self.data.seq, 1)
	ExchangeCtrl.Instance:SendGetSocreInfoReq()
end

function ShopItemCell:OnFlush()
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	self.root_node.gameObject:SetActive(item_cfg ~= nil)
	if nil == item_cfg then
		return
	end
	self.node_list["TxtPrice"].text.text = self.data.price
	self.node_list["TxtName"].text.text = ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color])
	local m_data = {}
	m_data.item_id = self.data.item_id

	self.item_cell:SetData(m_data)
	self.item_cell:SetRedPoint(false)
end