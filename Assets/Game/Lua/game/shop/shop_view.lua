require("game/shop/shop_content_view")
require("game/shop/shenmi_content_view")
ShopView = ShopView or BaseClass(BaseView)

function ShopView:__init()
	self.ui_config = {
		{"uis/views/exchangeview_prefab", "ShopPanelView"},
		{"uis/views/exchangeview_prefab", "ExchangeView"},
	}
	self.full_screen = false
	self.play_audio = true
	self.item_info = {}
	self.buy_num_value = 0
	self.consume_type = 0
	self.discount_seq = 0
	self.my_coin = 0
	self.my_coin_bind = 0
	self.replacement_id = 0
	self.item_index = nil
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp

	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].OpenShop)
	end
	self.other_cfg = ShopData.Instance:GetOtherCfg()
end

function ShopView:__delete()
	
end

function ShopView:ReleaseCallBack()
	if self.shop_content_view ~= nil then
		self.shop_content_view:DeleteMe()
		self.shop_content_view = nil
	end

	if self.shenmi_content_view ~= nil then
		self.shenmi_content_view:DeleteMe()
		self.shenmi_content_view = nil
	end

	if self.tehui_content_view ~= nil then
		self.tehui_content_view:DeleteMe()
		self.tehui_content_view = nil
	end

	if self.star_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.star_count_down)
		self.star_count_down = nil
	end
	self:RemoveCountDown()
	-- 清理变量和对象
	self.toggle_list = nil
	if self.item_cell then
		self.item_cell:DeleteMe()
	end
	-- if self.model then
	-- 	self.model:DeleteMe()
	-- 	self.model = nil
	-- end
end

function ShopView:LoadCallBack()
	-- self.model = RoleModel.New()
	-- self.model:SetDisplay(self.node_list["Display"].ui3d_display,MODEL_CAMERA_TYPE.BASE)
	-- self.model:ResetRotation()
	-- ItemData.ChangeModel(self.model, 26406) 					--子豪说写死仙女第七个

	self.node_list["Name"].text.text = Language.Shop.TitleName
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnCloseBtnClick, self))
	self.shop_content_view = ShopContentView.New(self.node_list["exchange_content_view"])
	self.shenmi_content_view = ShenMiContentView.New(self.node_list["shenmi_content_view"])
	self.tehui_content_view = TeHuiContentView.New(self.node_list["TeHuiContent"])
	for i = 1, 4 do
		self.node_list["toggle_content_" .. i].toggle.onValueChanged:AddListener(BindTool.Bind(self.OnToggleClick, self, i))
	end
	self.node_list["minus"].button:AddClickListener(BindTool.Bind(self.OnPlusOrMinusClick, self, -1))
	self.node_list["plus"].button:AddClickListener(BindTool.Bind(self.OnPlusOrMinusClick, self, 1))
	self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.OnBuyClick, self))
	self.node_list["TextBgImage"].button:AddClickListener(BindTool.Bind(self.OnTextClick, self))
	self.node_list["BtnJifenShop"].button:AddClickListener(BindTool.Bind(self.JiFenShopClick, self))
	self.node_list["BtnFlusOne"].button:AddClickListener(BindTool.Bind(self.FlushShopClickOne, self))
	self.node_list["BtnFlusAll"].button:AddClickListener(BindTool.Bind(self.FlushShopClickAll, self))
	self.node_list["BtnChongZhi"].button:AddClickListener(BindTool.Bind(self.ChongZhi, self))
	self.node_list["BuyBtnText"].text.text = Language.Common.CanPurchase
	self.node_list["InputPanel"]:SetActive(false)
	self.node_list["shenmi_content_view"]:SetActive(false)
	self.node_list["TeHuiContent"]:SetActive(false)
	self.node_list["RawImage"]:SetActive(true)

	local shenmi_shop_info = ShopData.Instance:GetShenMiShop()
	if nil == shenmi_shop_info then
		return
	end

	local shenmi_flushprice = ShopData.Instance:GetFlushPrice()
	if nil == shenmi_flushprice then
		return
	end
	self.node_list["FlushCoin"].text.text = string.format(shenmi_flushprice[1].consume_diamond)
	self.node_list["FlushCoinAll"].text.text = string.format(shenmi_flushprice[1].all_consume_diamond)
	self.replacement_id = shenmi_flushprice[1].replacement_id

	local asset, bundle = ResPath.GetItemIcon(self.replacement_id)
	self.node_list["ImgItem"].image:LoadSprite(asset, bundle)
	self.node_list["ImgItemAll"].image:LoadSprite(asset, bundle)

	self:InitToggle()
	self:TeHuiCountDown()

	self.item_cell = ItemCell.New()
	-- self.item_cell:ListenClick(function() end)
	self.item_cell:SetInstanceParent(self.node_list["itemcell"])
end

function ShopView:TeHuiCountDown()
	local cur_time = TimeCtrl.Instance:GetServerTime()
	local value = TimeUtil.NowDayTimeStart(cur_time)
	local left_time = 86400 - (cur_time - value)
	local function diff_time_fun(elapse_time, total_time)
		local star_time = math.floor(total_time - elapse_time + 0.5)
		local count_down_text = TimeUtil.FormatSecond(star_time, 13)
		self.node_list["TxtTime"].text.text = count_down_text

		if star_time <= 0 then
			if self.star_count_down ~= nil then
				CountDown.Instance:RemoveCountDown(self.star_count_down)
				self.star_count_down = nil
			end
		end
	end

	if self.star_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.star_count_down)
		self.star_count_down = nil
	end
	self.star_count_down = CountDown.Instance:AddCountDown(left_time, 0.5, diff_time_fun)
end

function ShopView:OnPlusOrMinusClick(num)
	if self.select_index == 1 then
		if (self.buy_num_value >= self:GetCanBuyNum() and num > 0) or (self.buy_num_value <= 1 and num < 0) then
			return
		end
	else
		local item_cfg = ShopData.Instance:GetShopItemCfg(self.item_info.id)
		if nil == item_cfg then
			return
		end

		local my_buy_item_money = 0
		local my_coin = 0
		if self.consume_type == 1 then
			my_buy_item_money = item_cfg.bind_gold * self.buy_num_value
			my_coin = GameVoManager.Instance:GetMainRoleVo().bind_gold
		else
			my_buy_item_money = item_cfg.gold * self.buy_num_value
			my_coin = GameVoManager.Instance:GetMainRoleVo().gold
		end

		if (self.buy_num_value == 999 and num > 0) or (self.buy_num_value == 1 and num < 0) 
			or self.buy_num_value == self:GetCanBuyNum() or my_buy_item_money > my_coin
			then
			return
		end
	end

	self.buy_num_value = self.buy_num_value + num
	self.node_list["NumTxt"].text.text = self.buy_num_value
	self:SetAllPrice()
end

function ShopView:InitToggle()
	self.toggle_list = {}
	for i = 1, 4 do
		self.toggle_list[i] = {}
		self.toggle_list[i].toggle_content = self.node_list["toggle_content_" .. i]
		self.toggle_list[i].toggle_text = self.node_list["HLText" .. i]
		if i == 1 then
			self.toggle_list[i].toggle_text.text.text = Language.Shop.ShopGrowUp
		elseif i == 2 then
			self.toggle_list[i].toggle_text.text.text = Language.Shop.ShopGem
		elseif i == 3 then
			self.toggle_list[i].toggle_text.text.text = Language.Shop.ShopBinding
		end
		if i == 4 then
			self.toggle_list[i].toggle_text.text.text = Language.Shop.ShopYouHui
		end
	end
end

function ShopView:OpenCallBack()
	self:SetButtonGrayEnabled()
	-- 发协议告诉服务端点开过特惠商店了,取消已经刷新过物品的红点的标志
	ShopCtrl.Instance:SendMysteriosshopinMallOperate(MYSTERIOUSSHOP_IN_MALL_OPERATE_TYPE.OPERATE_OPEN_VIEW, 0)

	self.node_list["toggle_content_1"]:SetActive(not IS_AUDIT_VERSION)
	self.node_list["toggle_content_2"]:SetActive(not IS_AUDIT_VERSION)
	self.node_list["toggle_content_3"]:SetActive(not IS_AUDIT_VERSION)
end

function ShopView:CloseCallBack()
	if self.star_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.star_count_down)
		self.star_count_down = nil
	end
end

function ShopView:ShowIndexCallBack(index)
	index = index > 0 and index or 1
	if IS_AUDIT_VERSION then
		index = 4
	end
	if self.toggle_list[index] then
		self.toggle_list[index].toggle_content.toggle.isOn = true
	end

	if index == TabIndex.shop_youhui then
		self.toggle_list[4].toggle_content.toggle.isOn = true
	elseif index == TabIndex.shop_chengzhang then
		self.toggle_list[1].toggle_content.toggle.isOn = true
	elseif index == TabIndex.shop_bind then
		self.toggle_list[3].toggle_content.toggle.isOn = true
	elseif index == TabIndex.shop_normal then
		self.toggle_list[2].toggle_content.toggle.isOn = true
	end

	if index == TabIndex.shop_chengzhang and self.tehui_content_view then
		self:OnToggleClick(1, true)
	end
	self:FlushKeyNum()
end

function ShopView:IsShowRedPoint(i, enable)
	if self.node_list["RedPoint" .. i] then
		self.node_list["RedPoint" .. i]:SetActive(enable)
	end
end

--设置关闭的时间
function ShopView:SetCloseBackEvent(callback)
	self.close_callback = callback
end

function ShopView:OnCloseBtnClick()
	if  self.close_callback ~= nil then
		self.close_callback()
	end
	ViewManager.Instance:Close(ViewName.Shop)
end

function ShopView:OnToggleClick(i,is_click)
	self.node_list["Bg"]:SetActive(false)
	if is_click then
		if i == 1 then
			self.node_list["exchange_content_view"]:SetActive(false)
			self.node_list["shenmi_content_view"]:SetActive(false)
			self.node_list["TeHuiContent"]:SetActive(true)
			self.node_list["RawImage"]:SetActive(true)
			self.node_list["RawImage"].raw_image:LoadSprite("uis/rawimages/shop_character_img" .. i, "shop_character_img" .. i .. ".png")
			RemindManager.Instance:SetRemindToday(RemindName.TeHuiShop)
		elseif i == 4 then
			self.node_list["exchange_content_view"]:SetActive(false)
			self.node_list["shenmi_content_view"]:SetActive(true)
			self.node_list["TeHuiContent"]:SetActive(false)
			self.node_list["Bg"]:SetActive(true)
			self.node_list["RawImage"]:SetActive(false)
			-- self.shop_content_view:SetCurrentShopType(i)
			RemindManager.Instance:Fire(RemindName.ShenmiShop)
		else
			self.node_list["RawImage"]:SetActive(true)
			self.node_list["RawImage"].raw_image:LoadSprite("uis/rawimages/shop_character_img" .. i, "shop_character_img" .. i .. ".png")
			self.node_list["exchange_content_view"]:SetActive(true)
			self.node_list["shenmi_content_view"]:SetActive(false)
			self.node_list["TeHuiContent"]:SetActive(false)
			self.shop_content_view:SetCurrentShopType(i)
		end

		if i == 3 then
			local bundle, asset = "uis/images_atlas", "icon_gold_5_bind" 
			self.node_list["ButtonReduce"].image:LoadSprite(bundle,asset)
			self.node_list["Frameicon"].image:LoadSprite(bundle,asset)
			self.node_list["PerPriceCoin"].image:LoadSprite(bundle,asset)
			self.node_list["MyCoin"].text.text = self.my_coin_bind
		else
			local bundle, asset = "uis/images_atlas", "icon_gold_5" 
			self.node_list["ButtonReduce"].image:LoadSprite(bundle,asset)
			self.node_list["Frameicon"].image:LoadSprite(bundle,asset)
			self.node_list["PerPriceCoin"].image:LoadSprite(bundle,asset)
			self.node_list["MyCoin"].text.text = self.my_coin
		end
		
		self:FlushJiFenItem()
		self.buy_num_value = 0
		self.select_index = i
		self.node_list["InputPanel"]:SetActive(false)
		self.node_list["ImgTeHui"]:SetActive(i == 1)
		self.node_list["TimePanle"]:SetActive(i == 1)
		self.node_list["DescTxt"].text.text = ""
		self.node_list["ProNameTxt"].text.text = ""
		self.node_list["Desc"].text.text = ""
		self.node_list["NumTxt"].text.text = 0
		self.node_list["SumPrice"].text.text = 0
		self.shop_content_view:OnFlushListView()
		self:ShenMiItem()
		self:TeHuiItem()
	end
end

function ShopView:ItemYes()
	if nil ~= self.item_index then
		ShopCtrl.Instance:SendMysteriosshopinMallOperate(MYSTERIOUSSHOP_IN_MALL_OPERATE_TYPE.OPERATE_TYPE_MONEY, self.item_index - 1)
	end
	self.item_index = nil
end

function ShopView:TeHuiItem()
	if self.tehui_content_view == nil then
		return
	end
	self.tehui_content_view:FlushView()
	self.tehui_content_view:OnFlushListView()
end

function ShopView:TeHuiItemHighLight()
	if self.tehui_content_view == nil then
		return
	end
	self.tehui_content_view:OnFlushHighLight()
end

function ShopView:ShenMiItem()
	if self.shenmi_content_view == nil then
		return
	end
	self.shenmi_content_view:FlushView()
end

function ShopView:PlayEffect()
	if self.shenmi_content_view == nil then
		return
	end
	self.shenmi_content_view:PlayEffect()
end

function ShopView:SetButtonGrayEnabled()
	self.node_list["BtnFlusOne"].button.interactable = true
	self.node_list["BtnFlusAll"].button.interactable = true
end

function ShopView:ChongZhi()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function ShopView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "from_duanzao" then
			self.toggle_list[2].toggle_content.toggle.isOn = true
		elseif k == "xin_xi" then
			self:ItemXinXi(v[1], v[2], v[3])
		elseif k == "shenmishop_view" then
			self:ShopItemBuy(v[1], v[2], v[3], v[4])
		elseif k == "tehui_shop_flush" then
			self:TeHuiItemHighLight()
			local discount_limit = ShopData.Instance:GetDiscounthopItemBuyCount(self.discount_seq)
			local color = discount_limit > 0 and COLOR.GREEN or TEXT_COLOR.PURERED
			self.node_list["TxtLimitNum"].text.text = string.format(Language.Shop.TeHuiBuyLimit, ToColorStr(discount_limit, color))
		end
	end
	self:FlushJiFenItem()
	self.my_coin = GameVoManager.Instance:GetMainRoleVo().gold
	self.my_coin_bind = GameVoManager.Instance:GetMainRoleVo().bind_gold
	self:FlushCoin()
	self:FlushKeyNum()
end

function ShopView:FlushKeyNum()
	if self.replacement_id == nil or self.select_index == 1 then return end

	local item_count = ItemData.Instance:GetItemNumInBagById(self.replacement_id)
	local today_flush_count = tonumber(ShopData.Instance:GetTodayFlushCount()) or 0
	-- local other_cfg = ShopData.Instance:GetFlushPrice()
	if self.other_cfg and next(self.other_cfg) then
		local item_count_all = self.other_cfg.all_consume_replacement or 0
		local str = item_count >= item_count_all and ToColorStr((Language.Common.X .. item_count_all), TEXT_COLOR.GREEN) or ToColorStr((Language.Common.X .. item_count_all), TEXT_COLOR.RED)
		self.node_list["TextKeyNumAll"].text.text = str
		self.node_list["FlushRedPointAll"]:SetActive(item_count >= item_count_all)
	end
	self.node_list["TextKeyNum"].text.text = Language.Common.X .. item_count
	self.node_list["ItemNum1"]:SetActive(item_count > 0 and today_flush_count <= 0)
	self.node_list["ItemNumAll"]:SetActive(item_count > 0)
	self.node_list["FlushRedPoint"]:SetActive(today_flush_count > 0)
	self.node_list["Consume"]:SetActive(item_count <= 0 and today_flush_count <= 0)
	self.node_list["ConsumeAll"]:SetActive(item_count <= 0)
	
	if today_flush_count > 0 then
		self.node_list["BtnFlushText"].text.text = Language.ShenShou.FreeFlush
	else
		self.node_list["BtnFlushText"].text.text = Language.ShenShou.FlushTxt
	end

	self.node_list["CiShu"]:SetActive(today_flush_count > 0)
	self.node_list["CiShu"].text.text = string.format(Language.Shop.FlushCiShu, today_flush_count)

	local num = ShopData.Instance:GetShopTeHuiRemind()
	self:IsShowRedPoint(1, num > 0)
	self:IsShowRedPoint(4, today_flush_count > 0)
end

function ShopView:ShopItemBuy(item_cfg, price, index, num)
	if nil == item_cfg then
		return
	end

	local item_num = "*" .. num
	if num == 1 then
		item_num = ""
	end

	local content_str = string.format(Language.Shop.ShopGouMai, price, ToColorStr(item_cfg.name .. item_num, ITEM_COLOR[item_cfg.color]))
	local shenmi_shop_info = ShopData.Instance:GetShenMiShop()
	self.item_index = index
	if shenmi_shop_info.seq_list[index].state == 0 then
		TipsCtrl.Instance:ShowCommonAutoView("ShopItemBuy", content_str, BindTool.Bind(self.ItemYes, self), nil, nil, nil ,Language.Common.Cancel ,nil ,true)
	else
		TipsCtrl.Instance:CloseCommonAutoView()
	end
end

function ShopView:ItemXinXi(item_id, consume_type, data_info)
	local data = TableCopy(ItemData.Instance:GetItemConfig(item_id))
	if data == nil then return end

	self.consume_type = consume_type
	if self.consume_type == SHOP_BIND_TYPE.BIND then
		data.is_bind = 1
	elseif self.consume_type == SHOP_BIND_TYPE.NO_BIND then
		data.is_bind = 0
	end

	self.item_info = data
	self.discount_seq = data_info and data_info.seq or 0

	local shop_item_cfg = ShopData.Instance:GetShopItemCfg(self.item_info.id)
	local res_id = 2
	local price = 0
	data.item_id = item_id
	data.num = data_info and data_info.item and data_info.item.num or 0

	self.is_use = is_use
	if shop_item_cfg ~= nil then
		if self.consume_type == SHOP_BIND_TYPE.BIND then
			res_id = 3
			price = shop_item_cfg.bind_gold
		elseif self.consume_type == SHOP_BIND_TYPE.NO_BIND then
			res_id = 2
			if nil ~= shop_item_cfg then
				price = shop_item_cfg.gold
			end
		end
	end

	if self.select_index == 1 then
		local discount_price = ShopData.Instance:GetDiscounthopItemBuyPrice(self.discount_seq)
		local discount_limit = ShopData.Instance:GetDiscounthopItemBuyCount(self.discount_seq)
		local color = discount_limit > 0 and COLOR.GREEN or TEXT_COLOR.PURERED
		self.item_price = discount_price
		price = discount_price

		self.node_list["TxtLimit"]:SetActive(true)
		self.node_list["TxtLimitNum"].text.text = string.format(Language.Shop.TeHuiBuyLimit, ToColorStr(discount_limit, color))
	else
		self.item_price = price
		self.node_list["TxtLimit"]:SetActive(false)
	end

	if next(self.item_info) ~= nil then
		self.item_cell:SetData(data)
		self.item_cell:SetCellSize(100)
		self.item_cell:SetInteractable(false)
		self.node_list["ProNameTxt"].text.text = ToColorStr(self.item_info.name, ITEM_COLOR[self.item_info.color])
		self.buy_num_value = 1
		self.node_list["NumTxt"].text.text = self.buy_num_value
		self:SetAllPrice()
		local role_level = GameVoManager.Instance:GetMainRoleVo().level or 0
		-- local level_color =role_level < self.item_info.limit_level and "#ff0000" or "#89F201"
		self.node_list["DescTxt"].text.text = PlayerData.GetLevelString(self.item_info.limit_level)
	end
	local des = self.item_info.description
	
	self.node_list["Desc"].text.text = des
	self.node_list["InputPanel"]:SetActive(true)
	self.node_list["RawImage"]:SetActive(false)
	self.node_list["per_price"].text.text = price
	self:FlushCoin()
	self.node_list["ItemInfo"]:GetComponent(typeof(UnityEngine.UI.ScrollRect)).normalizedPosition = Vector2(1, 1)
end

function ShopView:FlushCoin()
	local count = 0
	if self.consume_type == SHOP_BIND_TYPE.BIND then
		count = GameVoManager.Instance:GetMainRoleVo().bind_gold
	elseif self.consume_type == SHOP_BIND_TYPE.NO_BIND then
		count = GameVoManager.Instance:GetMainRoleVo().gold
	end
	self.node_list["MyCoin"].text.text = CommonDataManager.ConverMoney(count)
end

function ShopView:OnBuyClick()
	if self.buy_num_value == 0 then
		return
	end
	local sure_func = function()
		TipsCtrl.Instance:GetRenameView():Close()
	end

	if self.select_index == 1 then
		ShopCtrl.Instance:SendDiscountShopBuy(self.discount_seq, self.buy_num_value)
	else
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
		end
	end

	self.buy_num_value = 1
	self.node_list["NumTxt"].text.text = self.buy_num_value
	self.node_list["SumPrice"].text.text = self.item_price
end

function ShopView:OnTextClick()
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
		self.node_list["NumTxt"].text.text = self.buy_num_value
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
	TipsCtrl.Instance:OpenCommonInputView(0, open_func, close_func, max)
end

function ShopView:JiFenShopClick()
	ShopCtrl.Instance:OpenJifenShop()
end

function ShopView:FlushShopClickOne()
	if self.other_cfg and next(self.other_cfg) then
		local item_id = self.other_cfg.replacement_id or 0
		local one_consume_num = self.other_cfg.consume_replacement or 0
		local num = ItemData.Instance:GetItemNumInBagById(item_id)
		local today_flush_count = tonumber(ShopData.Instance:GetTodayFlushCount()) or 0
		if today_flush_count > 0 then
			local function yes_func()
				self.node_list["BtnFlusOne"].button.interactable = false
				ShopCtrl.Instance:SendMysteriosshopinMallOperate(MYSTERIOUSSHOP_IN_MALL_OPERATE_TYPE.OPERATE_TYPE_REFRESH, 0)
			end
			local str = ShopData.Instance:GetMysteriousShopZhenXiStr(false)
			if str ~= "" then
				local tips = Language.Shop.ZhenXiTips
				TipsCtrl.Instance:ShowCommonAutoView("", tips, yes_func, nil, nil, nil, nil, nil, true)
			else
				yes_func()
			end
		else
			if num >= one_consume_num then
				--物品充足
				local function yes_func()
					self.node_list["BtnFlusOne"].button.interactable = false
					ShopCtrl.Instance:SendMysteriosshopinMallOperate(MYSTERIOUSSHOP_IN_MALL_OPERATE_TYPE.OPERATE_TYPE_REFRESH, 0)
				end
				local function no_func()
				end
				local str = ShopData.Instance:GetMysteriousShopZhenXiStr(false)
				if str ~= "" then
					--local tips = string.format(Language.Shop.ZhenXiTips, str)
					local tips = Language.Shop.ZhenXiTips
					TipsCtrl.Instance:ShowCommonAutoView("", tips, yes_func, nil, nil, nil, nil, nil, true, nil, no_func)
				else
					yes_func()
				end
			else
				--物品不足
				local function ok_callback()
					local function yes_func()
						self.node_list["BtnFlusOne"].button.interactable = false
						ShopCtrl.Instance:SendMysteriosshopinMallOperate(MYSTERIOUSSHOP_IN_MALL_OPERATE_TYPE.OPERATE_TYPE_REFRESH, 0)
					end	
					local function no_func()
					end					
					local str = ShopData.Instance:GetMysteriousShopZhenXiStr(false)
					if str ~= "" then
						--local tips = string.format(Language.Shop.ZhenXiTips, str)
						local tips = Language.Shop.ZhenXiTips
						TipsCtrl.Instance:ShowCommonAutoView("", tips, yes_func, nil, nil, nil, nil, nil, true, nil, no_func)
					else
						yes_func()
					end
				end
				if num == 0 then
					local cost = self.other_cfg.consume_diamond or 0
					local des = string.format(Language.Shop.FlushOnce, cost)
					TipsCtrl.Instance:ShowCommonAutoView("flush_one", des, ok_callback, nil, nil, nil, nil, nil, true, nil, nil)
				else
					local differ_num = one_consume_num - num
					local cost = self.other_cfg.consume_diamond * differ_num
					local des = string.format(Language.Shop.FlushKey, cost)
					TipsCtrl.Instance:ShowCommonAutoView("flush_one", des, ok_callback, nil, nil, nil, nil, nil, true, nil, nil)
				end
			end
		end
		SpiritCtrl.Instance:SendGetSpiritScore()
		ExchangeCtrl.Instance:SendGetSocreInfoReq()
	end
end

function ShopView:FlushShopClickAll()
	if self.other_cfg and next(self.other_cfg) then
		local item_id = self.other_cfg.replacement_id or 0
		local all_consume_num = self.other_cfg.all_consume_replacement or 0
		local num = ItemData.Instance:GetItemNumInBagById(item_id)
		if num >= all_consume_num then
			--物品充足
			local function yes_func()
				self.node_list["BtnFlusAll"].button.interactable = false
				ShopCtrl.Instance:SendMysteriosshopinMallOperate(MYSTERIOUSSHOP_IN_MALL_OPERATE_TYPE.OPERATE_TYPE_REFRESH, 1)
			end
			local function no_func()
			end				
			local str = ShopData.Instance:GetMysteriousShopZhenXiStr(true)
			if str ~= "" then
				--local tips = string.format(Language.Shop.ZhenXiTips, str)
				local tips = Language.Shop.ZhenXiTips
				TipsCtrl.Instance:ShowCommonAutoView("", tips, yes_func, nil, nil, nil, nil, nil, true, nil, no_func)
			else
				yes_func()
			end
		else
			--物品不足
			local function ok_callback()
				local function yes_func()
					self.node_list["BtnFlusAll"].button.interactable = false
					ShopCtrl.Instance:SendMysteriosshopinMallOperate(MYSTERIOUSSHOP_IN_MALL_OPERATE_TYPE.OPERATE_TYPE_REFRESH, 1)
				end
				local function no_func()
				end					
				local str = ShopData.Instance:GetMysteriousShopZhenXiStr(true)
				if str ~= "" then
					--local tips = string.format(Language.Shop.ZhenXiTips, str)
					local tips = Language.Shop.ZhenXiTips
					TipsCtrl.Instance:ShowCommonAutoView("", tips, yes_func, nil, nil, nil, nil, nil, true, nil, no_func)
				else
					yes_func()
				end
			end
			if num == 0 then
				local cost = self.other_cfg.all_consume_diamond or 0
				local des = string.format(Language.Shop.FlushOnce, cost)
				TipsCtrl.Instance:ShowCommonAutoView("flush_ten", des, ok_callback, nil, nil, nil, nil, nil, true, nil, nil)
			else
				local differ_num = all_consume_num - num
				local cost = self.other_cfg.consume_diamond * differ_num
				local des = string.format(Language.Shop.FlushKey, cost)
				TipsCtrl.Instance:ShowCommonAutoView("flush_ten", des, ok_callback, nil, nil, nil, nil, nil, true, nil, nil)
			end
		end
		SpiritCtrl.Instance:SendGetSpiritScore()
		ExchangeCtrl.Instance:SendGetSocreInfoReq()
	end
end

function ShopView:FlushJiFenItem()
	local data = ShopData.Instance:GetShenMiShop()
	local severtime = TimeCtrl.Instance:GetServerTime()
	local diff_time = data.next_shop_item_refresh_time - severtime
	self.node_list["My_JiFen"].text.text = string.format(Language.Shop.JiFen, ToColorStr(ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.JIFEN), TEXT_COLOR.GREEN))

	local function diff_time_func (elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0.5 then
				self:RemoveCountDown()
				return
			end
			local s = TimeUtil.FormatSecond(left_time, 0)
			self.node_list["TimeText"].text.text = string.format(Language.Shop.ShuaXinTime, s)
	end

	diff_time_func(0, diff_time)
	self:RemoveCountDown()
	self.montser_count_down_list = CountDown.Instance:AddCountDown(diff_time, 0.5, diff_time_func)
end

function ShopView:RemoveCountDown()
	if self.montser_count_down_list ~= nil then
		CountDown.Instance:RemoveCountDown(self.montser_count_down_list)
	 	self.montser_count_down_list = nil
	end
end

function ShopView:SetAllPrice()
	if self.select_index == 1 then
		self.node_list["SumPrice"].text.text = self.item_price * self.buy_num_value
		return
	end

	local item_cfg = ShopData.Instance:GetShopItemCfg(self.item_info.id)
	if nil == item_cfg then
		return
	end

	if self.consume_type == 1 then
		self.node_list["SumPrice"].text.text = item_cfg.bind_gold * self.buy_num_value
	else
		self.node_list["SumPrice"].text.text = item_cfg.gold * self.buy_num_value
	end
end

function ShopView:GetCanBuyNum()
	if self.select_index == 1 then
		return ShopData.Instance:GetDiscounthopItemBuyCount(self.discount_seq) or 999
	end

	local item_cfg = ShopData.Instance:GetShopItemCfg(self.item_info.id)
	if nil == item_cfg then
		return 0
	end

	local can_buy_num = 0
	local money_can_buy = 0
	if self.consume_type == 1 and item_cfg.bind_gold > 0 then
		money_can_buy = math.floor(GameVoManager.Instance:GetMainRoleVo().bind_gold / item_cfg.bind_gold)
	elseif item_cfg.gold > 0 then
		money_can_buy = math.floor(GameVoManager.Instance:GetMainRoleVo().gold / item_cfg.gold)
	end

	local pile_limit = self.item_info.pile_limit
	if pile_limit >= money_can_buy then
		can_buy_num = money_can_buy
	else
		can_buy_num = pile_limit
	end

	return can_buy_num
end

