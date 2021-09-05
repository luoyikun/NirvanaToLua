TipExchangeView = TipExchangeView or BaseClass(BaseView)

function TipExchangeView:__init()
	self.ui_config = {{"uis/views/tips/shoporexchangetip_prefab", "ShopOrExchangeTip"}}
	self.item_info = {}
	self.buy_num_value = 0
	self.close_call_back = nil
	self.tips_text = Language.Tips.DaDao
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipExchangeView:ReleaseCallBack()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.TipExchangeView)
	end

end

function TipExchangeView:LoadCallBack()
	self.node_list["BtnReduceButton"].button:AddClickListener(BindTool.Bind(self.OnMinusClick, self))
	self.node_list["BtnPlusButton"].button:AddClickListener(BindTool.Bind(self.OnPlusClick, self))
	self.node_list["TxtMaxText"].button:AddClickListener(BindTool.Bind(self.OnMaxClick, self))
	self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.OnBuyClick, self))
	self.node_list["BtnCloseButton"].button:AddClickListener(BindTool.Bind(self.OnCloseClick, self))
	self.node_list["BtnInputClick"].button:AddClickListener(BindTool.Bind(self.OnTextClick, self))
	self.exchange_item_cfg = {}
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["item_cell"])
	local handler = function()
		local close_call_back = function()
			if self.item_cell then
				self.item_cell:ShowHighLight(false)
			end
		end
		if self.item_cell then
			self.item_cell:ShowHighLight(true)
		end
		TipsCtrl.Instance:OpenItem(self.item_cell:GetData(), nil, nil, close_call_back)
	end

	self.item_cell:ListenClick(handler)
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.TipExchangeView, BindTool.Bind(self.GetUiCallBack, self))
end

function TipExchangeView:SetItemId(item_id, price_type, conver_type, close_call_back)
	local exchange_cfg = ExchangeData.Instance:GetExchangeCfg(item_id, price_type)
	local data = TableCopy(ItemData.Instance:GetItemConfig(item_id))
	data.item_id = item_id
	data.is_bind = exchange_cfg.is_bind
	self.price_type = price_type
	self.conver_type = conver_type
	self.item_info = data
	self.close_call_back = close_call_back
end

function TipExchangeView:OpenCallBack()
	self.exchange_item_cfg = ExchangeData.Instance:GetExchangeCfg(self.item_info.id, self.price_type)
	if self.exchange_item_cfg then
		self.is_jingling = self.exchange_item_cfg.conver_type == EXCHANGE_CONVER_TYPE.JING_LING
	end
	if nil ~= next(self.item_info) and self.exchange_item_cfg then
		self.item_cell:SetData(self.item_info)
		self.node_list["TxtProName"].text.text = ToColorStr(self.item_info.name, ITEM_COLOR[self.item_info.color])
		self.node_list["TxtBuyOnePrice"].text.text = self.exchange_item_cfg.price
		local level = GameVoManager.Instance:GetMainRoleVo().level
		-- local lv, zhuan = PlayerData.GetLevelAndRebirth(self.item_info.limit_level)
		local role_level = GameVoManager.Instance:GetMainRoleVo().level or 0
		local use_level = PlayerData.GetLevelString(self.item_info.limit_level)
		local level_color = role_level < self.item_info.limit_level and TEXT_COLOR.RED or TEXT_COLOR.GREEN
		self.node_list["TxtDesc"].text.text = string.format(Language.Tip.ShiYongDengJi, ToColorStr(use_level, level_color))

		if level < self.item_info.limit_level then
			self.node_list["TextDesc"].text.text = ToColorStr(PlayerData.GetLevelString(self.item_info.limit_level), TEXT_COLOR.RED)
		else
			self.node_list["TextDesc"].text.text = ToColorStr(PlayerData.GetLevelString(self.item_info.limit_level), TEXT_COLOR.GREEN)
		end
		
		self.buy_num_value = 1
		self.node_list["TxtBuyNum"].text.text = self.buy_num_value
		if self.is_jingling then
			local score = ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.JINGLING)
			local num = (score - self.exchange_item_cfg.price * self.buy_num_value) <= 0 and 0 or (score - self.exchange_item_cfg.price * self.buy_num_value)
			self.node_list["TxtBuyAllPrice"].text.text = num
			self.node_list["TxtTotal"].text.text = Language.Exchange.TxtTotal[2]
		else
			self.node_list["TxtBuyAllPrice"].text.text = self.exchange_item_cfg.price * self.buy_num_value
			self.node_list["TxtTotal"].text.text = Language.Exchange.TxtTotal[1]
		end
		self.node_list["TextDesc"].text.text = self.item_info.description

		local res = ExchangeData.Instance:GetExchangeRes(self.price_type)
		if self.price_type == EXCHANGE_PRICE_TYPE.WEIJI then
			local vo = GameVoManager.Instance:GetMainRoleVo()
			if vo.sex == 0 then
				res = "WeiJi0"
			end
		end
		local bundle1, asset1 = ResPath.GetExchangeNewIcon(res)
		self.node_list["ImgCoinIcon1"].image:LoadSprite(bundle1, asset1)
		self.node_list["ImgCoinIcon2"].image:LoadSprite(bundle1, asset1)
		self.node_list["ImgCoinIcon3"].image:LoadSprite(bundle1, asset1)
		self:FlushCoin()
	end
end

function TipExchangeView:FlushCoin()
	local count = ExchangeData.Instance:GetCurrentScore(self.price_type)
	local exchange_item_cfg = ExchangeData.Instance:GetExchangeCfg(self.item_info.id, self.price_type)
	local color = TEXT_COLOR.GOLD
	if tonumber(count) < tonumber(exchange_item_cfg.price) then
		color = TEXT_COLOR.RED
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
	self.node_list["TxtMyCoin"].text.text = ToColorStr(count, color)
end

function TipExchangeView:GetBuyNum()
	local num = 0
	local exchange_item_cfg = ExchangeData.Instance:GetExchangeCfg(self.item_info.id, self.price_type)
	if exchange_item_cfg == nil then
		return num
	end

	local current_score = ExchangeData.Instance:GetCurrentScore(self.price_type)
	local money_can_buy_num = math.floor(current_score/exchange_item_cfg.price)

	if exchange_item_cfg and exchange_item_cfg.limit_convert_count ~= 0 then
		local conver_count = ExchangeData.Instance:GetConvertCount(exchange_item_cfg.seq, self.conver_type, self.price_type)
		num = exchange_item_cfg.limit_convert_count - conver_count
		if money_can_buy_num < num then
			num = money_can_buy_num
			self.tips_text = ExchangeData.Instance:GetLackScoreTis(self.price_type)
		end
	else
		if money_can_buy_num > 99 then
			num = 99
		else
			num = money_can_buy_num
		end
		self.tips_text = ExchangeData.Instance:GetLackScoreTis(self.price_type)
	end

	return num
end

function TipExchangeView:CloseCallBack()
	self.buy_num_value = 1
	self.node_list["TxtBuyNum"].text.text = self.buy_num_value
	self.item_info = {}
	if nil ~= self.close_call_back then
		self.close_call_back()
		self.close_call_back = nil
	end
end

function TipExchangeView:OnMinusClick()
	if self.buy_num_value == 1 then
		return
	end

	self.buy_num_value = self.buy_num_value - 1
	self.node_list["TxtBuyNum"].text.text = self.buy_num_value
	self.node_list["TxtBuyAllPrice"].text.text = ExchangeData.Instance:GetExchangeCfg(self.item_info.id, self.price_type).price * self.buy_num_value
end

function TipExchangeView:OnPlusClick()
	local temp = self:GetBuyNum()

	if temp > self.buy_num_value then
		self.buy_num_value = self.buy_num_value + 1
		self.node_list["TxtBuyNum"].text.text = self.buy_num_value
		self.node_list["TxtBuyAllPrice"].text.text = ExchangeData.Instance:GetExchangeCfg(self.item_info.id, self.price_type).price * self.buy_num_value
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Exchange.ErrorMax)
	end
end

function TipExchangeView:OnMaxClick()
	self.buy_num_value = self:GetBuyNum()

	if self.buy_num_value > 999 then
		self.buy_num_value = 999
	elseif self.buy_num_value == 0 then
		self.buy_num_value = 1
	end

	self.node_list["TxtBuyNum"].text.text = self.buy_num_value
	self.node_list["TxtBuyAllPrice"].text.text = ExchangeData.Instance:GetExchangeCfg(self.item_info.id, self.price_type).price * self.buy_num_value
end

function TipExchangeView:OnBuyClick()
	local exchange_item_cfg = ExchangeData.Instance:GetExchangeCfg(self.item_info.id, self.price_type)

	if self.buy_num_value > self:GetBuyNum() then
		TipsCtrl.Instance:ShowSystemMsg(self.tips_text)
	else
		ExchangeCtrl.Instance:SendScoreToItemConvertReq(exchange_item_cfg.conver_type, exchange_item_cfg.seq, self.buy_num_value)
		self.buy_num_value = 1
		self.node_list["TxtBuyNum"].text.text = self.buy_num_value
		self:Close()
	end
	
	self.tips_text = Language.Exchange.CanNotBuy --回到默认状态
end

function TipExchangeView:OnCloseClick()
	self:Close()
end

function TipExchangeView:OnTextClick()
	if self.is_jingling then
		return
	end
	local open_func = function(buy_num)
		self.buy_num_value = buy_num + 0
		self.node_list["TxtBuyNum"].text.text = self.buy_num_value
		self.node_list["TxtBuyAllPrice"].text.text = ExchangeData.Instance:GetExchangeCfg(self.item_info.id, self.price_type).price * self.buy_num_value
	end
	local max = 0
	if self:GetBuyNum() == 0 then
		max = 1
	else
		max = self:GetBuyNum()
	end
	TipsCtrl.Instance:OpenCommonInputView(1, open_func, nil, max)
end

function TipExchangeView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end