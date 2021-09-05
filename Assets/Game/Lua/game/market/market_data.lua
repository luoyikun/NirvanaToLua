MarketData = MarketData or BaseClass()

MarketData.MaxPriceCoin = 99999999					-- 价格上限-铜币
MarketData.MaxPriceGold = 99999						-- 价格上限-元宝

MarketData.PriceTypeCoin = 1						-- 价格类型-铜币
MarketData.PriceTypeGold = 2						-- 价格类型-元宝

MarketData.SaleItemTypeCoin = 1						-- 出售物品类型-铜币
MarketData.SaleItemTypeItem = 2						-- 出售物品类型-物品

function MarketData:__init()
	if MarketData.Instance then
		print_error("[MarketData] Attempt to create singleton twice!")
		return
	end
	MarketData.Instance = self
	self.item_list = {}

	self.cur_page = 1
	self.total_page = 0

	self.sale_item_list_market = {}
	self.sale_item_list = {}

	self.publicsale_tax_cfg = ConfigManager.Instance:GetAutoConfig("otherconfig_auto").publicsale_tax

	self.search_config = {
		item_type = 0,
		req_page = 1,
		total_page = 0,
		color = 0,
		order = 0,
		fuzzy_type_count = 0,
		fuzzy_type_list = {},
	}

	self.item_id = 0
	self.purchase_index = 0
	self.data_list = {}
	self.market_type_cfg = {}
	self:InitMarketTypeCfg()
end

function MarketData:__delete()
	MarketData.Instance = nil
	self.data_list = {}
end

function MarketData:SetCurPage(value)
	self.cur_page = value
end

function MarketData:GetCurPage()
	return self.cur_page
end

function MarketData:SetTotalPage(value)
	self.total_page = value
end

function MarketData:GetTotalPage()
	return self.total_page
end

function MarketData:SetSaleitemListMarket(value)
	self.sale_item_list_market = value
	for _, v in pairs(self.sale_item_list_market) do
		if v.sale_item_type == MarketData.SaleItemTypeCoin then
			v.item_id = COMMON_CONSTS.VIRTUAL_ITEM_COIN
			v.num = v.sale_value
			v.color = nil
		end
	end
end

function MarketData:GetSaleitemListMarket()
	return self.sale_item_list_market
end

-- 设置自己拍卖物品列表
function MarketData:SetSaleItemList(value)
	self.sale_item_list = value

	for k, v in pairs(self.sale_item_list) do
		if v.sale_item_type == MarketData.SaleItemTypeCoin then
			v.item_id = COMMON_CONSTS.VIRTUAL_ITEM_COIN
			v.num = v.sale_value
			v.color = nil
		end
	end
end

function MarketData:GetSaleItemList()
	return self.sale_item_list
end

-- 获取一个空位
function MarketData:GetValidIndex()
	local sale_list = {}
	for k, v in pairs(self.sale_item_list) do
		sale_list[v.sale_index] = 1
	end
	for i = 0, COMMON_CONSTS.PUBLICSALE_MAX_ITEM_COUNT - 1 do
		if nil == sale_list[i] then
			return i
		end
	end

	return -1
end

function MarketData:GetSearchConfig()
	return self.search_config
end

-- 市场价格按万来显示
function MarketData.ConverMoney(value)
	if value >= 10000 then
		return math.floor(value / 10000) .. Language.Common.Wan
	end
	return value
end

function MarketData:GetItemAllConfig()
	local item_all_config = {[GameEnum.ITEM_BIGTYPE_EQUIPMENT] = ConfigManager.Instance:GetAutoItemConfig("equipment_auto"),	--装备
						[GameEnum.ITEM_BIGTYPE_EXPENSE] = ConfigManager.Instance:GetAutoItemConfig("expense_auto"),				--消耗
						[GameEnum.ITEM_BIGTYPE_GIF] = ConfigManager.Instance:GetAutoItemConfig("gift_auto"),					--礼包
						[GameEnum.ITEM_BIGTYPE_OTHER] = ConfigManager.Instance:GetAutoItemConfig("other_auto"),					--其他
						[GameEnum.ITEM_BIGTYPE_VIRTUAL] = ConfigManager.Instance:GetAutoItemConfig("virtual_auto"),				--虚拟
					   }
	return item_all_config
end

function MarketData:InitMarketTypeCfg()
	self.market_type_cfg = {}
	local role_level = GameVoManager.Instance:GetMainRoleVo().level or 0
	local market_type_config = ConfigManager.Instance:GetAutoConfig("markettype_auto")
	for i,v in ipairs(market_type_config.market_father) do
		local vo = {}
		vo.parent_cfg = v
		vo.child_cfg = {}
		for i1,v1 in ipairs(market_type_config.market_child) do
			if v.father_id == v1.father_id and v1.appear_level <= role_level then
				table.insert(vo.child_cfg, v1)
			end
		end
		self.market_type_cfg[#self.market_type_cfg +1] = vo
	end
	table.sort(self.market_type_cfg, function(a,b) return a.parent_cfg.order < b.parent_cfg.order end)
end

function MarketData:GetMarketParentConfig()
	return self.market_type_cfg
end

function MarketData:GetMarketChildConfig(father_id)
	for k,v in pairs(self.market_type_cfg) do
		if v.parent_cfg.father_id == father_id then
			return v.child_cfg
		end
	end
	return {}
end

function MarketData:GetMarketTypeConfig()
	local market_type_config = ConfigManager.Instance:GetAutoConfig("markettype_auto")
	if market_type_config then
		if market_type_config.market_father then
			table.sort(market_type_config.market_father, function(a,b) return a.order < b.order end)
		end
	end
	return market_type_config
end

function MarketData:GetDealLimitByPlat(plat_name)
	local client_config = ConfigManager.Instance:GetAutoConfig("other_config_auto").client_config
	for k,v in pairs(client_config) do
		if v.plat_name == plat_name then
			return v.deal_limit
		end
	end
	plat_name = "default"
	for k,v in pairs(client_config) do
		if v.plat_name == plat_name then
			return v.deal_limit
		end
	end
	return -1
end

function MarketData:GetSaleCount()
	local count = 0
	if self.sale_item_list then
		for k,v in pairs(self.sale_item_list) do
			count = count + 1
		end
	end
	return count
end

function MarketData:SetItemId(item_id)
	self.item_id = item_id
end

function MarketData:GetItemId()
	return self.item_id
end

function MarketData:GetTax(value)
	if value == nil then return 0 end
	local tax = 0
	for i,v in ipairs(self.publicsale_tax_cfg) do
		if value >= v.gold then
			tax = v.tax
		end
	end
	return tax
end

function MarketData:SetSaleTypeCountAck(protocol)
	self.count_list = protocol.info_list
end

function MarketData:GetCountBySaleType(sale_type)
	if self.count_list == nil then return 0 end
	for k,v in pairs(self.count_list) do
		if v.sale_type == sale_type then
			return v.item_count
		end
	end
	return 0
end

-- 保存吆喝时间戳
function MarketData:SetMarketTime(time)
	self.market_time = TimeCtrl.Instance:GetServerTime() + time
end

function MarketData:GetMarketTime()
	return self.market_time or 0
end

function MarketData:SetPurchaseItemId(index)
	self.purchase_index = index
end

-- function MarketData:GetPurchaseItemId()
-- 	return self.purchase_index or 0
-- end

function MarketData:GetPurchaseItemId()
	local item_cfg = self:GetPurchaseCfg()
	if next(item_cfg) == nil or self.purchase_cfg == nil or self.purchase_index <= 0 then return 0, 0 end

	for k,v in pairs(item_cfg) do
		if self.purchase_index == v.show_index then
			return k, v.item_id
		end
	end
	return 0, 0
end

function MarketData:GetPurchaseCfg()
	if self.purchase_cfg then
		return self.purchase_cfg
	end

	local buy_list = {}
	local role_level = GameVoManager.Instance:GetMainRoleVo().level or 0
	local market_buy_list = ConfigManager.Instance:GetAutoConfig("markettype_auto").buy_list
	if market_buy_list then
		for k,v in pairs(market_buy_list) do
			if role_level >= v.level_limit then
				local data = {item_id = v.item_id, is_bind = 0, num = 1, show_index = v.tiaozhuan_id}
				table.insert(buy_list, data)
			end
		end
	end

	self.purchase_cfg = buy_list
	return buy_list
end

function MarketData:SetWorldAcquisitionLog(protocol)
	if next(self.data_list) == nil then
		self.data_list = protocol.data_list
	else
		for k,v in pairs(protocol.data_list) do
			table.insert(self.data_list, v)
		end
	end

end

function MarketData:GetWorldAcquisitionLog()
	return self.data_list
end


function MarketData:ExplainPurchaseText(data)
	if data == nil then
		return ""
	end
	local dec =""
	local str = "{wordcolor;#89F201;%s} "
	local time_str = ""
	local cur_day = os.date("%d", TimeCtrl.Instance:GetServerTime())
	local event_day = os.date("%d", data.timestamp)

	if cur_day == event_day then
		time_str = os.date("%H:%M", data.timestamp)
	else
		time_str = os.date("%m/%d", data.timestamp)
	end
	str = string.format(str, time_str)
	local rank = data.log_str_id <= 0 and 1 or data.log_str_id
	dec = string.format(Language.Market.MarketPurchaseText[rank], str, data.role_name, data.item_id, data.role_id, data.item_id)
	return dec
end
