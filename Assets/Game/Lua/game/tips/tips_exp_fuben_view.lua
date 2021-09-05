TipsExpFuBenView = TipsExpFuBenView or BaseClass(BaseView)
local Drop_Id_List =
{
	23091, --3倍经验
	23090, --2.5倍经验
	23089, --2倍经验
	23088, --1.5倍经验
}
--对应上面的id
local EXP_PERCENT = {
	[1] = 300,
	[2] = 200,
	[3] = 100,
	[4] = 0,
}

function TipsExpFuBenView:__init()
	self.ui_config = {{"uis/views/tips/expviewtips_prefab", "ExpFuBenTips"}}
	self.view_layer = UiLayer.Pop
	self.is_modal = true
	self.is_any_click_close = true
end

function TipsExpFuBenView:ReleaseCallBack()
	for i = 1, 4 do
		self.item_cell_list[i].item_cell:DeleteMe()
	end

	if self.fight_effect_change then
		GlobalEventSystem:UnBind(self.fight_effect_change)
		self.fight_effect_change = nil
	end
end

function TipsExpFuBenView:LoadCallBack()
	-- self.node_list["BtnBg"].button:AddClickListener(BindTool.Bind(self.ClickClose, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.ClickClose, self))
	self.item_cell_list = {}
	for i = 1, 4 do
		self.item_cell_list[i] = {}
		self.item_cell_list[i].item_cell = ItemCell.New()
		self.item_cell_list[i].item_cell:SetInstanceParent(self.node_list["item_cell_" .. i])
		self.node_list["BtnUse" .. i].button:AddClickListener(BindTool.Bind(self.OnClickUse, self, i))
		self.node_list["TxtExp" .. i].text.text = string.format(Language.ExpFuBenTips.JingYan, EXP_PERCENT[i])
	end
end

function TipsExpFuBenView:OpenCallBack()
	--监听物品变化
	self.item_change_callback = BindTool.Bind(self.OnItemDataChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change_callback)

	self.fight_effect_change = GlobalEventSystem:Bind(ObjectEventType.FIGHT_EFFECT_CHANGE,
		BindTool.Bind1(self.Flush, self))
	self:Flush()
end

function TipsExpFuBenView:OnItemDataChange(item_id)
	for k,v in pairs(Drop_Id_List) do
		if v == item_id then
			self:Flush()
		end
	end
end

function TipsExpFuBenView:ClickClose()
	self:Close()
end

function TipsExpFuBenView:CloseCallBack()
	if self.fight_effect_change then
		GlobalEventSystem:UnBind(self.fight_effect_change)
		self.fight_effect_change = nil
	end
	if self.item_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_callback)
		self.item_change_callback = nil
	end
end

function TipsExpFuBenView:SetData()
	self.tips_cfg = FuBenData.Instance:GetExpFBTipsCfg()
	self:Flush()
end

function TipsExpFuBenView:OnFlush()
	for i = 1, 4 do
		self.item_cell_list[i].item_cell:SetShowNumTxtLessNum(0)
		local my_count = ItemData.Instance:GetItemNumInBagById(Drop_Id_List[i])
		local data = {}
		data.item_id = Drop_Id_List[i]
		data.num = my_count
		self.item_cell_list[i].item_cell:SetData(data)
		if i <= 2 then
			if my_count > 0 then
				self.node_list["ItemFrame" .. i]:SetActive(true)
			else
				self.node_list["ItemFrame" .. i]:SetActive(false)
			end
		else
			if my_count > 0 then
				self.node_list["TxtBtn" .. i].text.text = Language.Common.Use
				self.node_list["ImgGold" .. i]:SetActive(false)
			else
				self.node_list["TxtBtn" .. i].text.text = Language.Common.CanPurchase
				self.node_list["ImgGold" .. i]:SetActive(true)
			end
			local shop_item_cfg = ShopData.Instance:GetShopItemCfg(Drop_Id_List[i])
			if shop_item_cfg ~= nil then
				if i == 4 then
					self.node_list["TextBindGold"].text.text = shop_item_cfg.bind_gold
				else
					self.node_list["TextGold"].text.text = shop_item_cfg.gold
				end
			end
		end
	end
end

function TipsExpFuBenView:OnClickUse(index)
	local shop_item_gold = ShopData.Instance:GetShopItemCfg(Drop_Id_List[index])
	local bind_gold = GameVoManager.Instance:GetMainRoleVo().bind_gold
	local my_count = ItemData.Instance:GetItemNumInBagById(Drop_Id_List[index])

	local func = function()
		local is_bind_gold = 1
		if shop_item_gold.gold > bind_gold then
			is_bind_gold = 0
		elseif index == 2 then
			is_bind_gold = 1
		end
		ExchangeCtrl.Instance:SendCSShopBuy(Drop_Id_List[index], 1, is_bind_gold, 1)
	end
	if my_count > 0 then
		local bag_index = ItemData.Instance:GetItemIndex(Drop_Id_List[index])
		PackageCtrl.Instance:SendUseItem(bag_index, 1, 0, 0)
	-- elseif index == 1 then
	-- 	if shop_item_gold < bind_gold then
	-- 		TipsCtrl.Instance:ShowShopView(Drop_Id_List[index], 1, nil, 1)
	-- 	else
	-- 		TipsCtrl.Instance:ShowShopView(Drop_Id_List[index], 2, nil, 1)
	-- 	end
	else
		-- local item_cfg = ItemData.Instance:GetItemConfig(Drop_Id_List[index])
		-- local str = string.format(Language.FuBen.BuyExpBuff, shop_item_gold.gold, item_cfg.name)
		-- TipsCtrl.Instance:ShowCommonAutoView("ExpBuff", str, func)
		func()
	end
	self:ClickClose()
end

