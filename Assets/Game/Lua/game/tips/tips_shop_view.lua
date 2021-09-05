TipShopView = TipShopView or BaseClass(BaseView)

function TipShopView:__init()
	self.ui_config = {{"uis/views/tips/shoporexchangetip_prefab", "ShopOrExchangeTip"}}
	self.item_info = {}
	self.buy_num_value = 0
	self.consume_type = 0
	self.close_call_back = nil
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipShopView:__delete()
end

function TipShopView:LoadCallBack()
	local handler = function()
		local close_call_back = function()
			self.item_cell:ShowHighLight(false)
		end
		self.item_cell:ShowHighLight(true)
		TipsCtrl.Instance:OpenItem(self.item_cell:GetData(), nil, nil, close_call_back)
	end
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["item_cell"])
	self.item_cell:ListenClick(handler)
	self.node_list["BtnReduceButton"].button:AddClickListener(BindTool.Bind(self.OnMinusClick, self))
	self.node_list["BtnPlusButton"].button:AddClickListener(BindTool.Bind(self.OnPlusClick, self))
	self.node_list["TxtMaxText"].button:AddClickListener(BindTool.Bind(self.OnMaxClick, self))
	self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.OnBuyClick, self))
	self.node_list["BtnCloseButton"].button:AddClickListener(BindTool.Bind(self.OnCloseClick, self))
	self.node_list["BtnInputClick"].button:AddClickListener(BindTool.Bind(self.OnTextClick, self))

	self.node_list["TxtBuyText"].text.text = Language.Common.CanPurchase
	self.node_list["TxtIconName"].text.text = Language.Common.Shop
end

function TipShopView:ReleaseCallBack()
	self.item_cell:DeleteMe()
	self.item_cell = nil
end

function TipShopView:SetItemId(item_id, consume_type, close_call_back, is_use)
	local data = TableCopy(ItemData.Instance:GetItemConfig(item_id))
	if consume_type == SHOP_BIND_TYPE.BIND then
		data.is_bind = 1
	elseif consume_type == SHOP_BIND_TYPE.NO_BIND then
		data.is_bind = 0
	end
	data.item_id = item_id
	self.item_info = data
	self.close_call_back = close_call_back
	self.consume_type = consume_type
	self.is_use = is_use
end

function TipShopView:CloseCallBack()
	self.close_call_back = nil
	self.item_info = {}
	self.is_use = nil
end

function TipShopView:OpenCallBack()
	local shop_item_cfg = ShopData.Instance:GetShopItemCfg(self.item_info.id)
	local res_id = 0
	local price = 0
	if self.consume_type == SHOP_BIND_TYPE.BIND then
		res_id = "5_bind"
		price = shop_item_cfg.bind_gold
	elseif self.consume_type == SHOP_BIND_TYPE.NO_BIND then
		res_id = 5
		price = shop_item_cfg.gold
	end
	if next(self.item_info) ~= nil then
		self.node_list["TxtProName"].text.text = ToColorStr(self.item_info.name, ITEM_COLOR[self.item_info.color])
		self.node_list["TxtBuyOnePrice"].text.text = price
		self.buy_num_value = 1
		self.node_list["TxtBuyNum"].text.text = self.buy_num_value
		self.node_list["TxtBuyOnePrice"].text.text = price
		self:SetAllPrice()
		self.item_cell:SetData(self.item_info)
		local role_level = GameVoManager.Instance:GetMainRoleVo().level or 0
		local use_level = PlayerData.GetLevelString(self.item_info.limit_level)
		local level_color = role_level < self.item_info.limit_level and TEXT_COLOR.RED or TEXT_COLOR.GREEN
		self.node_list["TxtDesc"].text.text = string.format(Language.Tip.ShiYongDengJi, ToColorStr(use_level, level_color))
	end

	local bundle, asset = ResPath.GetDiamonIcon(res_id)
	self.node_list["ImgCoinIcon1"].image:LoadSprite(bundle, asset)
	self.node_list["ImgCoinIcon2"].image:LoadSprite(bundle, asset)
	self.node_list["ImgCoinIcon3"].image:LoadSprite(bundle, asset)
	self.node_list["TextDesc"].text.text = self.item_info.description

	self:FlushCoin()
end

function TipShopView:FlushCoin()
	local count = 0
	if self.consume_type == SHOP_BIND_TYPE.BIND then
		count = GameVoManager.Instance:GetMainRoleVo().bind_gold
	elseif self.consume_type == SHOP_BIND_TYPE.NO_BIND then
		count = GameVoManager.Instance:GetMainRoleVo().gold
	end
	if count > 99999 and count <= 99999999 then
		count = count / 10000
		count = math.floor(count)
		count = count .. Language.Common.Wan
	elseif count > 99999999 then
		count = count / 100000000
		count = math.floor(count)
		count = count .. Language.Common.Yi
	end
	self.node_list["TxtMyCoin"].text.text = count
end

function TipShopView:CloseCallBack()
	self.buy_num_value = 1
	self.node_list["TxtBuyNum"].text.text = self.buy_num_value
	-- if self.close_call_back ~= nil then
	-- 	self.close_call_back()
	-- 	self.close_call_back = nil
	-- end
end

function TipShopView:OnPlusClick()
	local can_buy_num = self:GetCanBuyNum()
	if can_buy_num > self.buy_num_value then
		self.buy_num_value = self.buy_num_value + 1
		if self.buy_num_value > 999 then
			self.buy_num_value = 999
		end
		self.node_list["TxtBuyNum"].text.text = self.buy_num_value
		self:SetAllPrice()
	end
end

function TipShopView:OnMinusClick()
	if self.buy_num_value == 1 then
		return
	end
	self.buy_num_value = self.buy_num_value - 1
	self.node_list["TxtBuyNum"].text.text = self.buy_num_value
	self:SetAllPrice()
end

function TipShopView:OnMaxClick()
	self.buy_num_value = self:GetCanBuyNum()
	if self.buy_num_value > 999 then
		self.buy_num_value = 999
	elseif self.buy_num_value == 0 then
		self.buy_num_value = 1
	end
	self.node_list["TxtBuyNum"].text.text = self.buy_num_value
	self:SetAllPrice()
end

function TipShopView:GetCanBuyNum()
	local can_buy_num = 0
	local money_can_buy = 0
	if self.consume_type == 1 then
		money_can_buy = math.floor(GameVoManager.Instance:GetMainRoleVo().bind_gold /ShopData.Instance:GetShopItemCfg(self.item_info.id).bind_gold)
	else
		money_can_buy = math.floor(GameVoManager.Instance:GetMainRoleVo().gold /ShopData.Instance:GetShopItemCfg(self.item_info.id).gold)
	end
	local pile_limit = self.item_info.pile_limit
	if pile_limit >= money_can_buy then
		can_buy_num = money_can_buy
	else
		can_buy_num = pile_limit
	end
	return can_buy_num
end

function TipShopView:SetAllPrice()
	if self.consume_type == 1 then
		self.node_list["TxtBuyAllPrice"].text.text = ShopData.Instance:GetShopItemCfg(self.item_info.id).bind_gold * self.buy_num_value
	else
		self.node_list["TxtBuyAllPrice"].text.text = ShopData.Instance:GetShopItemCfg(self.item_info.id).gold * self.buy_num_value
	end
end

function TipShopView:OnBuyClick()
	if self.buy_num_value == 0 then
		return
	end
	local sure_func = function()
		TipsCtrl.Instance:GetRenameView():Close()
		if self.close_call_back ~= nil then
			self.close_call_back()
			self.close_call_back = nil
		end
		self:Close()
	end
	if self.buy_num_value > self:GetCanBuyNum() then
		if self.consume_type == 1 then
			TipsCtrl.Instance:ShowSystemMsg(Language.Common.NoBindGold)
		else
			TipsCtrl.Instance:ShowLackDiamondView(sure_func)
		end
	else
		if self.consume_type == 1 then
			ExchangeCtrl.Instance:SendCSShopBuy(self.item_info.id, self.buy_num_value, 1, self.is_use or self.item_info.is_diruse, 0, 0) --使用绑钻
		else
			ExchangeCtrl.Instance:SendCSShopBuy(self.item_info.id, self.buy_num_value, 0, self.is_use or self.item_info.is_diruse, 0, 0) --使用钻石
		end
		self.buy_num_value = 1
		self.node_list["TxtBuyNum"].text.text = self.buy_num_value
		if self.close_call_back ~= nil then
			self.close_call_back()
			self.close_call_back = nil
		end
		self:Close()
	end
end

function TipShopView:OnCloseClick()
	if self.close_call_back ~= nil then
		self.close_call_back = nil
	end
	self:Close()
end

function TipShopView:OnTextClick()
	local open_func = function(buy_num)
		local can_buy_num = self:GetCanBuyNum()
		if buy_num + 0 == 0 then
			self.buy_num_value = 1
			return
		end

		if buy_num + 0 <= can_buy_num then
			self.buy_num_value = buy_num + 0
		else
			if can_buy_num == 0 then
				self.buy_num_value = 1
			else
				self.buy_num_value = can_buy_num
			end
		end
		self.node_list["TxtBuyNum"].text.text = self.buy_num_value
	end

	local close_func = function()
		self:SetAllPrice()
	end

	local max = 0
	if self:GetCanBuyNum() == 0 then
		max = 1
	else
		max = self:GetCanBuyNum()
	end
	TipsCtrl.Instance:OpenCommonInputView(0,open_func,close_func,max)
end