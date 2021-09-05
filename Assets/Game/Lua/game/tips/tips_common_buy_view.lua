TipsCommonBuyView = TipsCommonBuyView or BaseClass(BaseView)
TipsCommonBuyView.AUTO_LIST = {}
function TipsCommonBuyView:__init()
	self.ui_config = {{"uis/views/tips/commontips_prefab", "CommonBuyTip"}}
	self.view_layer = UiLayer.Pop
	self.ok_func = nil
	self.item_id = nil
	self.need_sprice = 0
	self.play_audio = true
	self.cell_list = {}
	self.is_modal = true
	self.is_any_click_close = true
end

function TipsCommonBuyView:LoadCallBack()
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightPowerTX"], "FightPower3")
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickCloseButton, self))
	self.node_list["BtnCloseRight"].button:AddClickListener(BindTool.Bind(self.OnClickCloseButton, self))
	self.node_list["BtnUse"].button:AddClickListener(BindTool.Bind(self.OnClickBuyButton, self))
	self.node_list["UseBind"].toggle:AddValueChangedListener(BindTool.Bind(self.OnClickBindGold, self))
	self.node_list["BtnPlus"].button:AddClickListener(BindTool.Bind(self.OnClickPlus, self))
	self.node_list["BtnReduce"].button:AddClickListener(BindTool.Bind(self.OnClickReduce, self))
	self.node_list["BtnBuyNum"].button:AddClickListener(BindTool.Bind(self.OnClickInputField, self))
	self.node_list["BtnGoToYiZhe"].button:AddClickListener(BindTool.Bind(self.OnClickGoToYiZhe, self))
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])

	self.cur_num = 1
	self.max_num = 1
	self.node_list["TxtBuyNum"].text.text = 0
	self:Flush()

end

function TipsCommonBuyView:OpenCallBack()
	DisCountData.Instance:SetRefreshList()
	DisCountData.Instance:IsCloseTipsRightView(true)
end

function TipsCommonBuyView:ReleaseCallBack()
	self.fight_text = nil

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
	end
	self.cell_list = {}
end

function TipsCommonBuyView:CloseCallBack()
	if self.item_id and self.item_id > 0 then
		TipsCommonBuyView.AUTO_LIST[self.item_id] = self.node_list["UseBind"].toggle.isOn
	end
	TipsOtherHelpData.Instance:SetIsAutoBuy(self.node_list["UseBind"].toggle.isOn)

	-- 刷新需要监听自动改变的界面
	-- 先暂时处理，后面做统一界面处理
	AppearanceCtrl.Instance:FlushView("FlsuhAutoBuyToggle")

	self.ok_func = nil
	self.item_id = nil
	self.no_func = nil
	self.max_num = nil
	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
	end
	self.cell_list = {}
	DisCountData.Instance:IsCloseTipsRightView(true)
end

function TipsCommonBuyView:OnClickCloseButton()
	if self.no_func ~= nil then
		self.no_func()
	end
	self:Close()
end

function TipsCommonBuyView:SetInputText(str)
	self.node_list["TxtBuyNum"].text.text = str
	self.cur_num = str
	self:Flush()
end

function TipsCommonBuyView:OnClickBindGold()
	self:Flush()
end

function TipsCommonBuyView:OnClickInputField()
	local ok_func = function (cur_str)
		self:SetCommonBuyViewText(cur_str)
	end
	local cancle_func = function ()
		self:SetCommonBuyViewText(self.cur_num)
	end
	TipsCtrl.Instance:OpenCommonInputView(self.cur_num, ok_func, cancle_func, self.max_num)
end

function TipsCommonBuyView:OnClickGoToYiZhe()
	local _, index = DisCountData.Instance:GetListNumByItemId(self.item_id)
	ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {index})
	self:Close()
end

function TipsCommonBuyView:SetCommonBuyViewText(cur_str)
	self.node_list["TxtBuyNum"].text.text = tonumber(cur_str)
	self.cur_num = tonumber(cur_str)
	if self.need_num then
		self.need_num = tonumber(cur_str)
	end
	self:Flush()
end

function TipsCommonBuyView:OnClickPlus()
	local shop_item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[self.item_id]

	if shop_item_cfg == nil then
		return
	end

	if tonumber(self.node_list["TxtBuyNum"].text.text) >= self.max_num then
		return
	end

	self.cur_num = tonumber(self.node_list["TxtBuyNum"].text.text) + 1
	self.node_list["TxtBuyNum"].text.text = self.cur_num

	if self.need_num then
		self.need_num = self.need_num + 1
	end
	self:Flush()
end

function TipsCommonBuyView:OnClickReduce()
	if self.node_list["TxtBuyNum"].text.text <= tostring(0) or self.node_list["TxtBuyNum"].text.text == "" then
		return
	end

	local num = tonumber(self.node_list["TxtBuyNum"].text.text)
	if (num - 1) <= 0 then
		return
	end

	self.cur_num = tonumber(self.node_list["TxtBuyNum"].text.text) - 1
	self.node_list["TxtBuyNum"].text.text = self.cur_num

	if self.need_num then
		self.need_num = self.need_num - 1
	end
	self:Flush()
end

function TipsCommonBuyView:OnClickBuyButton()
	local is_bind = 0
	local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)

	if nil ~= self.ok_func then
		if self.need_sprice <= PlayerData.Instance.role_vo.bind_gold then
			local shop_cfg = ShopData.Instance:GetShopItemCfg(self.item_id)
			if shop_cfg and shop_cfg.bind_gold > 0 then
				is_bind = 1
			end
		end
		local is_buy_quick = false
		if self.node_list["UseBind"].toggle.isOn then
			is_buy_quick = true   --绑定参数用于是否自动购买（无论是否绑定，服务端都优先使用绑钻）
		end
		self.ok_func(self.item_id, self.cur_num, is_bind, item_cfg.is_tip_use, is_buy_quick )
	end
	if self.item_id2 then
		self.ok_func = self.ok_func2
		self.item_id = self.item_id2
		self.no_func = self.no_func2
		self.need_num = self.need_num2
		self.is_spec = self.is_spec2

		self.ok_func2 = nil
		self.item_id2 = nil
		self.no_func2 = nil
		self.need_num2 = nil
		self.is_spec2 = nil
		self:Flush()
	else
		self:Close()
	end
end

function TipsCommonBuyView:SetCallBack(callback, item_id, no_func, need_num, is_spec)
	local shop_item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
	if nil == shop_item_cfg then
		TipsCtrl.Instance:ShowItemGetWayView(item_id)
		return
	end
	self.ok_func = callback
	self.item_id = item_id
	self.no_func = no_func
	self.need_num = need_num
	self.is_spec = is_spec or false
	self:Open()
	self:Flush()
end

function TipsCommonBuyView:SetCallBackAgain(callback, item_id, no_func, need_num, is_spec)
	local shop_item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
	if nil == shop_item_cfg then
		return
	end
	self.ok_func2 = callback
	self.item_id2 = item_id
	self.no_func2 = no_func
	self.need_num2 = need_num
	self.is_spec2 = is_spec or false
end

function TipsCommonBuyView:OnFlush(param_t)
	local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)
	local shop_item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[self.item_id]
	if nil == shop_item_cfg then
		return
	end

	self.node_list["BtnPlus"]:SetActive(not self.is_spec)
	self.node_list["BtnReduce"]:SetActive(not self.is_spec)
	self.node_list["UseBind"]:SetActive(not self.is_spec)

	local money = GameVoManager.Instance:GetMainRoleVo().bind_gold
	local shop_price = shop_item_cfg.bind_gold
	local bundle, asset = ResPath.GetDiamonIcon("5_bind")

	-- self.node_list["UseBind"]:SetActive(true)

	if money < shop_price or shop_item_cfg.bind_gold == 0 then
		money = GameVoManager.Instance:GetMainRoleVo().gold
		bundle, asset = ResPath.GetDiamonIcon("5")
		shop_price = shop_item_cfg.gold
	end
	self.node_list["Imggold"].image:LoadSprite(bundle, asset)
	if nil ~= item_cfg then
		self.pro_name_color = ITEM_COLOR[item_cfg.color]
		self.pro_name = item_cfg.name
		self.node_list["TxtDesc"].text.text = item_cfg.description
		self.have_pro_num = ItemData.Instance:GetItemNumInBagById(self.item_id)
		self.node_list["TxtProName"].text.text = string.format(Language.CommonBuyTip.Name,self.pro_name_color,self.pro_name,self.have_pro_num)
		
		if EquipData.IsXiaoguiEqType(item_cfg.sub_type) then
			local cfg = EquipData.GetXiaoGuiCfgById(self.item_id)
			if cfg then
				local cfg_temp = {}
				for k, v in pairs(cfg) do
					cfg_temp[k] = v
				end
				cfg_temp.per_mianshang = 0
				self.node_list["FightPowerTX"]:SetActive(true)
				if self.fight_text and self.fight_text.text then
					self.fight_text.text.text = CommonDataManager.GetCapability(CommonDataManager.GetAttributteByClass(cfg_temp))
				end
			end
		else
			self.node_list["FightPowerTX"]:SetActive(false)
		end
	end

	local data = ItemData.Instance:GetItem(self.item_id) or {item_id = self.item_id}
	self.item_cell:SetData(data)
	self.node_list["TxtBuyNum"].text.text = self.cur_num or 0
	if money < shop_price then
		self.cur_num = 1
		self.max_num = 1
	else
		if nil ~= item_cfg then
			if item_cfg.pile_limit then
				if item_cfg.pile_limit <= tonumber(self.cur_num) then
					self.cur_num = item_cfg.pile_limit
				end
				if item_cfg.pile_limit <= math.floor(money / shop_price) and item_cfg.pile_limit <= tonumber(self.cur_num) then
					self.cur_num = item_cfg.pile_limit
				end
				if item_cfg.pile_limit <= math.floor(money / shop_price) then
					self.max_num = item_cfg.pile_limit
				else
					self.max_num = math.floor(money / shop_price)
				end
			end
		else
			if math.floor(money / shop_price) >= 999 then
				self.max_num = 999
			end
		end
	end
	if self.need_num then
		if self.need_num > self.max_num then
			self.cur_num = self.max_num
			self.need_num = self.max_num
		else
			self.cur_num = self.need_num
		end
	end
	self.need_sprice = shop_price * self.cur_num
	self.node_list["TxtSumPrice"].text.text = self.need_sprice
	self.node_list["TxtBuyNum"].text.text = self.cur_num
	self.node_list["TxtBuyNum"].text.text = self.cur_num

	-- local discount_list = KaifuActivityData.Instance:GetPersonalActivityCfgBuyItem(self.item_id)
	local discount_list = DisCountData.Instance:GetListNumByItemId(self.item_id)
	if discount_list then
		self.node_list["PanelShowRight"]:SetActive(#discount_list > 0)
		self.node_list["BtnGoToYiZhe"]:SetActive(#discount_list > 0)
		if #discount_list > 0 then
			self:FlushList(discount_list)
			self:FlushRightView()
			DisCountData.Instance:IsCloseTipsRightView(false)
		end
	end
end

function TipsCommonBuyView:FlushList(data_list)
	if data_list then
		local scroller_delegate = self.node_list["DiscountList"].list_simple_delegate
		--生成数量
		scroller_delegate.NumberOfCellsDel = function()
			return #data_list or 0
		end
		--刷新函数
		scroller_delegate.CellRefreshDel = function(cell, data_index, cell_index)
			data_index = data_index + 1

			local detail_cell = self.cell_list[cell]
			if detail_cell == nil then
				detail_cell = TipsCommonBuyDiscountItem.New(cell.gameObject)
				detail_cell.list_detail_view = self
				self.cell_list[cell] = detail_cell
			end

			detail_cell:SetIndex(data_index)
			detail_cell:SetData(data_list[data_index])
		end
	end
end

function TipsCommonBuyView:FlushRightView()
	if self.node_list["DiscountList"] and self.node_list["DiscountList"].scroller and self.node_list["DiscountList"].scroller.isActiveAndEnabled then
		self.node_list["DiscountList"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end
	
--TipsCommonBuyDiscountItem 		列表滚动条格子
----------------------------------------------------------------------------
TipsCommonBuyDiscountItem = TipsCommonBuyDiscountItem or BaseClass(BaseCell)

function TipsCommonBuyDiscountItem:__init()
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["Item"])
	self.list_detail_view = nil
	self.node_list["BtnUse"].button:AddClickListener(BindTool.Bind(self.OnButtonClick, self))
end

function TipsCommonBuyDiscountItem:__delete()
	self.list_detail_view = nil
	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end
end

function TipsCommonBuyDiscountItem:OnFlush()
	if not self.data or not next(self.data) then return end
	local flag = self.data.price <= 0
	local text_cost = flag and Language.Common.Free or self.data.price
	self.node_list["TxtCost"].text.text = string.format(Language.TipsCommonBuyDiscountItem.Cost, text_cost)
	self.node_list["Diamon1"]:SetActive(not flag)

	self.node_list["TxtCost2"].text.text = string.format(Language.TipsCommonBuyDiscountItem.Cost2,self.data.show_price)
	if not flag and self.data.show_price > 0 then
		local discount = math.ceil(self.data.price / self.data.show_price * 10)
		self.node_list["ImgTab"]:SetActive(true)
		self.node_list["TxtDiscount"].text.text = string.format(Language.TipsCommonBuyDiscountItem.Zhe,CommonDataManager.GetDaXie(discount))
	else
		self.node_list["ImgTab"]:SetActive(false)
		self.node_list["TxtDiscount"].text.text = ""
	end

	local limit_num = self.data.buy_limit_count - self.data.buy_count
	local color = limit_num > 0 and TEXT_COLOR.GREEN or TEXT_COLOR.RED_4
	local limit_buy_text = flag and Language.TipsCommonBuyDiscountItem.XianLingQu or Language.TipsCommonBuyDiscountItem.XianGou
	self.node_list["TxtLimitBuy"].text.text = string.format(limit_buy_text, ToColorStr(limit_num, color))

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.reward_item.item_id)
	if item_cfg then
		local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
		self.node_list["TxtName"].text.text = name_str
	end
	self.item:SetData(self.data.reward_item)
	if limit_num <= 0 then
		self.node_list["TxtLimitBuy"]:SetActive(false)
		if flag then
			self.node_list["BtnText"].text.text = Language.Common.YiLingQu
		else
			self.node_list["BtnText"].text.text = Language.TipsCommonBuyDiscountItem.YiGouMai
		end
		UI:SetButtonEnabled(self.node_list["BtnUse"], false)
	else
		self.node_list["TxtLimitBuy"]:SetActive(true)
		if flag then
			self.node_list["BtnText"].text.text = Language.Common.LingQu
		else
			self.node_list["BtnText"].text.text = Language.TipsCommonBuyDiscountItem.GouMai
		end
		UI:SetButtonEnabled(self.node_list["BtnUse"], true)
	end
	--UI:SetButtonEnabled(self.node_list["BtnUse"], not (buy_num >= self.data.limit_buy_count))
end

function TipsCommonBuyDiscountItem:OnButtonClick()
	-- if not self.data or not next(self.data) then return end
	-- local func = function()
	-- 	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.data.activity_type, RA_PERSONAL_PANIC_BUY_OPERA_TYPE.RA_PERSONAL_PANIC_BUY_OPERA_TYPE_BUY_ITEM, self.data.seq)
	-- end
	-- local str = string.format(Language.Activity.BuyGiftTip, self.data.gold_price)
	-- TipsCtrl.Instance:ShowCommonAutoView("personal_auto_buy", str, func)
	if self.data == nil then
		return
	end
	local reward_data = self.data.reward_item
	local item_cfg = ItemData.Instance:GetItemConfig(reward_data.item_id)
	local item_color = GameEnum.ITEM_COLOR_WHITE
	local item_name = ""
	if item_cfg then
		item_color = item_cfg.color
		item_name = item_cfg.name
	end
	if self.data.price <= 0 then
		DisCountCtrl.Instance:SendDiscountBuyReqBuy(self.data.seq)
	else
		local des = string.format(Language.Common.UsedGoldToBuySomething, ToColorStr(self.data.price, TEXT_COLOR.GREEN), ToColorStr(item_name, ITEM_COLOR[item_color]))
		local function ok_callback()
			DisCountCtrl.Instance:SendDiscountBuyReqBuy(self.data.seq)
		end
		TipsCtrl.Instance:ShowCommonAutoView("dis_count", des, ok_callback)
	end
end