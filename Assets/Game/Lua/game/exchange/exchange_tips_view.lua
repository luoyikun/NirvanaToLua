ExchangeTipView = ExchangeTipView or BaseClass(BaseView)

function ExchangeTipView:__init()
	self.ui_config = {{"uis/views/exchangeview_prefab", "ExchangeTip"}}
	self.item_info = {}
	self.buy_num_value = 1
	self.close_call_back = nil
	self.tips_text = Language.Exchange.CanNotBuy
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function ExchangeTipView:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ExchangeTipView:ReleaseCallBack()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	-- 清理变量和对象
	self.item_name = nil
	self.use_level = nil
	self.my_coin_text = nil
	self.coin_icon_1 = nil
end

function ExchangeTipView:LoadCallBack()

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["item_cell"])

	self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.OnBuyClick, self))
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.OnCloseClick, self))


	local handler = function()
		local close_call_back = function()
			self.item_cell:ShowHighLight(false)
		end
		self.item_cell:ShowHighLight(true)
		TipsCtrl.Instance:OpenItem(self.item_cell:GetData(), nil, nil, close_call_back)
	end
	self.item_cell:ListenClick(handler)
	self:Flush()
end


function ExchangeTipView:UpdateMultipleTime(item_id, time, is_max)
	-- 根据id是和打开页面时接受的id一致
	if nil ~= time and nil ~= is_max and item_id == self.item_info.item_id then
		self.multiple_time = time
		self.is_max_multiple = is_max
	end
	self:Flush()
end

function ExchangeTipView:SetItemId(item_id, price_type, conver_type, close_call_back, cur_multile_price, multiple_time, is_max_multiple, click_func)
	local exchange_cfg = ExchangeData.Instance:GetExchangeCfg(item_id, price_type)
	local data, big_type = ItemData.Instance:GetItemConfig(item_id)
	
	self.price_type = price_type
	self.conver_type = conver_type
	self.item_info = TableCopy(data)
	self.item_info.item_id = item_id
	self.item_info.is_bind = exchange_cfg.is_bind
	
	self.close_call_back = close_call_back
	self.cur_multile_price = cur_multile_price
	self.multiple_time = multiple_time
	self.is_max_multiple = is_max_multiple
	self.click_func = click_func

	local prof = PlayerData.Instance:GetRoleBaseProf()
	if big_type == GameEnum.ITEM_BIGTYPE_GIF and (self.item_info.description or self.item_info.description == "") then
		if self.item_info.need_gold and self.item_info.need_gold > 0 then
			self.item_info.description = string.format(Language.Tip.GlodGiftTip, self.item_info.need_gold)
		else
			self.item_info.description = Language.Tip.FixGiftTip
			if self.item_info.rand_num and self.item_info.rand_num ~= "" then
				self.item_info.description = string.format(Language.Tip.RandomGiftTip, self.item_info.rand_num)
			end
		end
		for k, v in pairs(ItemData.Instance:GetGiftItemList(item_id)) do
			local item_cfg2 = ItemData.Instance:GetItemConfig(v.item_id)
			if item_cfg2 and (item_cfg2.limit_prof == prof or item_cfg2.limit_prof == 5) then
				local color_name_str = "<color="..SOUL_NAME_COLOR[item_cfg2.color]..">"..item_cfg2.name.."</color>"
				if self.item_info.description ~= "" then
					self.item_info.description = self.item_info.description.."\n"..color_name_str.."X"..v.num
				else
					self.item_info.description = self.item_info.description..color_name_str.."X"..v.num
				end
			end
		end
	end
	self:Flush()
end

function ExchangeTipView:OnFlush()
	if next(self.item_info) ~= nil then
		self.item_cell:SetData(self.item_info)
		self.node_list["ProName"].text.text = ToColorStr(self.item_info.name, ITEM_COLOR[self.item_info.color])
		self.node_list["SumPrice"].text.text = ToColorStr(ExchangeData.Instance:GetMultilePrice(self.item_info.item_id, self.price_type))
		
		local level = GameVoManager.Instance:GetMainRoleVo().level
		if level < self.item_info.limit_level then
			self.node_list["DescTxt"].text.text = TEXT_COLOR.RED
		
		else
			self.node_list["DescTxt"].text.text = TEXT_COLOR.GREEN
		end
		-- local lv, zhuan = PlayerData.GetLevelAndRebirth(self.item_info.limit_level)
		-- self.node_list["DescTxt"].text.text = string.format(Language.Common.ZhuanShneng, lv, zhuan)
		self.node_list["DescTxt"].text.text = PlayerData.GetLevelString(self.item_info.limit_level)
		self.node_list["BuyNumTxt"].text.text = self.buy_num_value
		self.node_list["Desc"].text.text = self.item_info.description
		self.node_list["CountTxt"].text.text = string.format(Language.Exchange.ExchangeDouble, self.multiple_time)

		local res = ExchangeData.Instance:GetExchangeRes(self.price_type)
		local bundle1, asset1 = ResPath.GetExchangeNewIcon(res)
				if nil ~= asset1 and "" ~= asset1 and nil ~= bundle1 and "" ~= bundle1 then
				self.node_list["ButtonReduce1"].image:LoadSprite(bundle1, asset1 .. ".png")
				self.node_list["ButtonReduce2"].image:LoadSprite(bundle1, asset1 .. ".png")
			end

			if self.node_list["ButtonReduce1"].auto_fit_size then
				self.node_list["ButtonReduce1"].image:SetNativeSize()
			end

			if self.node_list["ButtonReduce1"].auto_disable then
				self.node_list["ButtonReduce1"].image.enabled = (nil ~= self.view.node_list[obj_param.name].image.sprite)
		end

				if self.node_list["ButtonReduce2"].auto_fit_size then
				self.node_list["ButtonReduce2"].image:SetNativeSize()
			end

			if self.node_list["ButtonReduce2"].auto_disable then
				self.node_list["ButtonReduce2"].image.enabled = (nil ~= self.view.node_list[obj_param.name].image.sprite)
		end
		self:FlushCoin()
		self.node_list["CountTxt"]:SetActive(not self.is_max_multiple)
		self.node_list["MaxTxt"]:SetActive(self.is_max_multiple)
	end
	if ExchangeCtrl.Instance.view:IsOpen() then
		ExchangeCtrl.Instance.view:Flush()
	end
end

function ExchangeTipView:FlushCoin()
	local count = ExchangeData.Instance:GetCurrentScore(self.price_type)
	local exchange_item_cfg = ExchangeData.Instance:GetExchangeCfg(self.item_info.id, self.price_type)
	local color = TEXT_COLOR.GOLD
	local all_price = ExchangeData.Instance:GetMultilePrice(self.item_info.id, self.price_type)
	if tonumber(count) < tonumber(all_price) then
		color = TEXT_COLOR.RED
	end
	count = CommonDataManager.ConverMoney(count)
	self.node_list["MyCoin"].text.text = ToColorStr(count, color)
end

function ExchangeTipView:GetBuyNum()
	local num = 0
	local exchange_item_cfg = ExchangeData.Instance:GetExchangeCfg(self.item_info.id, self.price_type)
	local current_score = ExchangeData.Instance:GetCurrentScore(self.price_type)
	local money_can_buy_num = math.floor(current_score/exchange_item_cfg.price)
	if exchange_item_cfg.limit_convert_count ~= 0 then
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

function ExchangeTipView:CloseCallBack()
	self.buy_num_value = 1
	self.node_list["BuyNumTxt"].text.text = self.buy_num_value
	self.item_info = {}
	if self.close_call_back ~= nil then
		self.close_call_back()
		self.close_call_back = nil
	end
end

function ExchangeTipView:OnBuyClick()
	local exchange_item_cfg = ExchangeData.Instance:GetExchangeCfg(self.item_info.id, self.price_type)
	if self.buy_num_value > self:GetBuyNum() then
		TipsCtrl.Instance:ShowSystemMsg(self.tips_text)
	else
		ExchangeCtrl.Instance:SendScoreToItemConvertReq(exchange_item_cfg.conver_type, exchange_item_cfg.seq, self.buy_num_value)
		self.buy_num_value = 1
		self.node_list["BuyNumTxt"].text.text = self.buy_num_value
		if self.click_func then
			self.click_func()
		end
	end
	self.tips_text = Language.Exchange.CanNotBuy --回到默认状态
	ExchangeCtrl.Instance.view:Flush()
end

function ExchangeTipView:OnCloseClick()
	self:Close()
end