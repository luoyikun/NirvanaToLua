DabaoEnterConsumView = DabaoEnterConsumView or BaseClass(BaseView)

function DabaoEnterConsumView:__init()
	self.ui_config = {{"uis/views/bossview_prefab", "DabaoEnterConsumView"}}
	self.ok_func = nil
	self.view_layer = UiLayer.Pop

	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function DabaoEnterConsumView:ReleaseCallBack()
	if nil ~=  self.comsun_cell then 
		self.comsun_cell:DeleteMe()
		self.comsun_cell = nil
	end

	self.tiky_item_id = nil
	self.enter_comsun = nil
	self.map_tip = nil
	self.consum_tip = nil
	self.ok_func = nil
end

function DabaoEnterConsumView:LoadCallBack()
	self.node_list["BtnYes"].button:AddClickListener(BindTool.Bind(self.OnBtnClick, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))

	if nil ~= self.data or nil ~= self.content then
		self:Flush()
	end
	self.node_list["text_dabao_comsun"].text.text = ""

	if nil ==  self.comsun_cell then 
		self.comsun_cell = ItemCell.New()
		self.comsun_cell:SetInstanceParent(self.node_list["Item"])
	end
end

function DabaoEnterConsumView:ShowIndexCallBack()
	self:Flush()
end

function DabaoEnterConsumView:OnFlush()
	local has_tiky_num = ItemData.Instance:GetItemNumInBagById(self.tiky_item_id)
	self.comsun_cell:SetData({item_id = self.tiky_item_id})
	local color = has_tiky_num >= self.enter_comsun and TEXT_COLOR.GREEN or TEXT_COLOR.RED
	self.node_list["text_num"].text.text = ToColorStr(has_tiky_num, color) .. ToColorStr(" / "..self.enter_comsun, TEXT_COLOR.GREEN)

	local item_cfg = ItemData.Instance:GetItemConfig(self.tiky_item_id)
	if item_cfg == nil then return end
	local name = item_cfg.name
	self.node_list["text_dabao_comsun"].text.text = string.format(self.map_tip, name, self.enter_comsun)
	local item_shop_cfg = ShopData.Instance:GetShopItemCfg(self.tiky_item_id)
	local item_price = 0
	if nil == item_shop_cfg.bind_gold or item_shop_cfg.bind_gold == 0 then
		item_price = item_shop_cfg.gold
	else
		item_price = item_shop_cfg.bind_gold
	end
	-- self.node_list["txt_consum_money"].text.text = string.format(self.consum_tip, self.enter_comsun * item_price)
end

function DabaoEnterConsumView:SetEnterBossComsunData(tiky_item_id, enter_comsun, map_tip, consum_tip, ok_func)
	self.tiky_item_id = tiky_item_id
	self.enter_comsun = enter_comsun
	self.map_tip = map_tip
	self.consum_tip = consum_tip
	self.ok_func = ok_func
	self:Open()
end

function DabaoEnterConsumView:OnBtnClick()

	local has_tiky_num = ItemData.Instance:GetItemNumInBagById(self.tiky_item_id)
	if has_tiky_num >= self.enter_comsun then
		self.ok_func()
		self:Close()
		return
	end

	local item_shop_cfg = ShopData.Instance:GetShopItemCfg(self.tiky_item_id)
	local item_price = 0
	if nil == item_shop_cfg.bind_gold or item_shop_cfg.bind_gold == 0 then
		item_price = item_shop_cfg.gold
	else
		item_price = item_shop_cfg.bind_gold
	end
	local price = ToColorStr(tostring(self.enter_comsun * item_price), TEXT_COLOR.YELLOW)
	local item_cfg = ItemData.Instance:GetItemConfig(self.tiky_item_id)
	local name = ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color])
	local num = tostring(self.enter_comsun)

	local describe = string.format(Language.Boss.BossBuyTicket, price, name, num)
	local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
	end
	TipsCtrl.Instance:ShowCommonBuyView(func, self.tiky_item_id, nil, self.enter_comsun)

	-- TipsCtrl.Instance:ShowCommonAutoView(nil, describe, self.ok_func, nil, nil, nil, nil, nil, true, false)
	self:Close()
end

function DabaoEnterConsumView:OnClickClose()
	self:Close()
end