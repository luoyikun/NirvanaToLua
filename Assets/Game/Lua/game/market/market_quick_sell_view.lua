MarketQuickSellView = MarketQuickSellView or BaseClass(BaseView)

function MarketQuickSellView:__init()
	self.ui_config = {{"uis/views/market_prefab", "QuickSell"}}
	self.is_modal = true
	self.play_audio = true
	self.is_any_click_close = true

	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function MarketQuickSellView:__delete()

end

function MarketQuickSellView:LoadCallBack()
	self.select_cell = ItemCell.New()
	self.select_cell:SetFromView(TipsFormDef.FROM_MARKET_JISHOU)
	self.select_cell:SetInstanceParent(self.node_list["SelectCell"])

	self.node_list["BtnPlus"].button:AddClickListener(BindTool.Bind(self.OnPlus, self))
	self.node_list["BtnReduce"].button:AddClickListener(BindTool.Bind(self.OnReduce, self))
	self.node_list["BtnSell"].button:AddClickListener(BindTool.Bind(self.OnSell, self))
	self.node_list["BtnMax"].button:AddClickListener(BindTool.Bind(self.OnSellAll, self))
	self.node_list["Count"].button:AddClickListener(BindTool.Bind(self.OnClickCount, self))
	self.node_list["TotalPrice"].button:AddClickListener(BindTool.Bind(self.OnClickTotalPrice, self))
	-- self.node_list["Price"].button:AddClickListener(BindTool.Bind(self.OnClickSinglePrice, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClose, self))

	self.node_list["Price"]:SetActive(false)
end

function MarketQuickSellView:ReleaseCallBack()
	if self.select_cell then
		self.select_cell:DeleteMe()
		self.select_cell = nil
	end
end

function MarketQuickSellView:OnFlush(param)
	if not param then self:Close() return end
	MarketCtrl.Instance:SendPublicSaleGetUserItemListReq()
	param = param.all
	self.item_index = param.index
	local item_id = param.item_id
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(item_id)

	self.node_list["TxtItemName"].text.text = ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color])
	self.node_list["TxtLevel"].text.text = "LV." .. item_cfg.limit_level

	self.select_cell:SetData({item_id = item_id})

	self.select_item_count = param.num
	self.total_price = 10

	self.node_list["ItemCount"].text.text = "1"
	self.node_list["TxtTotalPrice"].text.text = "10"
	self.node_list["SinglePrice"].text.text = "10"
end

-- 增加数量
function MarketQuickSellView:OnPlus()
	if(self.select_item_count ~= nil) then
		local count = tonumber(self.node_list["ItemCount"].text.text)
		count = count + 1
		if(count > self.select_item_count) then
			count = self.select_item_count
		end
		self.node_list["ItemCount"].text.text = "" .. count
		-- self:OnCountChanged()
	end
end

-- 减少数量
function MarketQuickSellView:OnReduce()
	if(self.select_item_count ~= nil) then
		local count = tonumber(self.node_list["ItemCount"].text.text)
		count = count - 1
		if(count < 1) then
			count = 1
		end
		self.node_list["ItemCount"].text.text = "" .. count
		-- self:OnCountChanged()
	end
end

-- 最大数量
function MarketQuickSellView:OnSellAll()
	if(self.select_item_count ~= nil) then
		local count = self.select_item_count
		self.node_list["ItemCount"].text.text = "" .. count
		-- self:OnCountChanged()
	end
end


-- 点击数量输入框
function MarketQuickSellView:OnClickCount()
	if(self.select_item_count == nil) then
		return
	end
	TipsCtrl.Instance:OpenCommonInputView(nil, BindTool.Bind(self.CountInputEnd, self))
end

-- -- 点击单价输入框
-- function MarketQuickSellView:OnClickSinglePrice()
-- 	if(self.select_item_count == nil) then
-- 		return
-- 	end
-- 	TipsCtrl.Instance:OpenCommonInputView(nil, BindTool.Bind(self.OnSinglePriceEnd, self), nil, MarketData.MaxPriceGold)
-- end

function MarketQuickSellView:OnClickTotalPrice()
	if(self.select_item_count == nil) then
		return
	end
	TipsCtrl.Instance:OpenCommonInputView(nil, BindTool.Bind(self.OnTotalPriceEnd, self), nil, MarketData.MaxPriceGold)
end

function MarketQuickSellView:OnTotalPriceEnd(str)
	local price = tonumber(str)
	if (price < 10) or price == nil then
		price = 10
	elseif (price > MarketData.MaxPriceGold) then
		price = MarketData.MaxPriceGold
	end
	self.node_list["TxtTotalPrice"].text.text = price
end

function MarketQuickSellView:CountInputEnd(str)
	local count = tonumber(str)
	if(count < 1) then
		count = 1
	elseif(count > self.select_item_count) then
		count = self.select_item_count
	end
	self.node_list["ItemCount"].text.text = count
	-- self.price = math.floor(self.total_price / count) <= 1 and 1 or math.floor(self.total_price / count)
	-- local total_price = tonumber(self.node_list["SinglePrice"].text.text) * count
	-- self.node_list["TxtTotalPrice"].text.text = tostring(total_price)
	-- self.node_list["SinglePrice"].text.text = "" .. self.price
	-- self:OnCountChanged()
end

-- -- 数量改变时
-- function MarketQuickSellView:OnCountChanged()
-- 	local count = tonumber(self.node_list["ItemCount"].text.text)
-- 	-- self.price = math.floor(self.total_price / count) <= 1 and 1 or math.floor(self.total_price / count)
-- 	local total_price = tonumber(self.node_list["SinglePrice"].text.text) * count
-- 	self.node_list["TxtTotalPrice"].text.text = tostring(total_price)
-- 	-- self.node_list["SinglePrice"].text.text = "" .. self.price
-- 	self.node_list["ItemCount"].text.text = tostring(count)
-- end

-- -- 单价输入完成后
-- function MarketQuickSellView:OnSinglePriceEnd(str)
-- 	local count = tonumber(str)
-- 	if(count < 10) or count == nil then
-- 		count = 10
-- 	elseif(count > MarketData.MaxPriceGold) then
-- 		count = MarketData.MaxPriceGold
-- 	end
-- 	-- self.total_price = count
-- 	self.node_list["SinglePrice"].text.text = count
-- 	local Num = tonumber(self.node_list["ItemCount"].text.text)
-- 	local total_price = tonumber(self.node_list["SinglePrice"].text.text) * Num
-- 	self.node_list["TxtTotalPrice"].text.text = tostring(total_price)
-- 	-- self.price = math.floor(self.total_price / tonumber(self.node_list["ItemCount"].text.text))
-- 	-- self.node_list["SinglePrice"].text.text = self.price <= 1 and 1 or self.price
-- end

-- 出售
function MarketQuickSellView:OnSell()
	local sale_index = MarketData.Instance:GetValidIndex()

	local sale_num = tonumber(self.node_list["ItemCount"].text.text)
	local sale_price = tonumber(self.node_list["TxtTotalPrice"].text.text)
	if nil == sale_num or nil == sale_price then
		return
	end
	if 0 == sale_num and 0 == sale_price then
		SysMsgCtrl.Instance:ErrorRemind(Language.Market.OtherErrors)
		return
	end
	if 0 == sale_num and 0 ~= sale_price then
		SysMsgCtrl.Instance:ErrorRemind(Language.Market.OtherErrors1)
		return
	end
	if 0 ~= sale_num and 0 == sale_price then
		SysMsgCtrl.Instance:ErrorRemind(Language.Market.OtherErrors2)
		return
	end
	if sale_index < 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Market.JiShouCountLimit)
		return
	end
	local price_type = MarketData.PriceTypeGold
	MarketCtrl.Instance:SendAddPublicSaleItemReq(sale_index, self.item_index, sale_num, sale_price, price_type)
	self:Close()
end

function MarketQuickSellView:OnClose()
	self:Close()
end