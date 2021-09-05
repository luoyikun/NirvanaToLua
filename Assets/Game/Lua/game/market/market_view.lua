require("game/market/market_sell_view")
require("game/market/market_buy_view")
require("game/market/market_table_view")
require("game/market/market_purchase_view")

local SETTING_TAB_INDEX =
{
	TabIndex.market_buy,
 	TabIndex.market_sell,
 	TabIndex.market_table,
}

MarketView = MarketView or BaseClass(BaseView)

function MarketView:__init()
	self.play_audio = true
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel"},
		{"uis/views/market_prefab", "BuyView", {TabIndex.market_buy}},
		{"uis/views/market_prefab", "SellView", {TabIndex.market_sell}},
		{"uis/views/market_prefab", "TableView", {TabIndex.market_table}},
		{"uis/views/market_prefab", "PurchaseView", {TabIndex.market_purchase}},
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].OpenShichang)
	end
	-- self.money_change_callback = BindTool.Bind(self.PlayerDataChangeCallback, self)
	self.def_index = TabIndex.market_buy
end

function MarketView:__delete()
end

function MarketView:LoadCallBack()

	local tab_cfg = {
		{name =	Language.Market.TabbarName.Buy, tab_index = TabIndex.market_buy},
		{name = Language.Market.TabbarName.Sell, tab_index = TabIndex.market_sell},
		{name = Language.Market.TabbarName.Table, tab_index = TabIndex.market_table},
		{name = Language.Market.TabbarName.Purchase, tab_index = TabIndex.market_purchase},
	}

	self.tabbar = TabBarTwo.New()
	self.tabbar:Init(self, self.node_list["TabPanel"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.Close, self))

	-- 首次刷新数据
	-- self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	-- PlayerData.Instance:ListenerAttrChange(self.money_change_callback)
end

function MarketView:OpenCallBack()
	MarketData.Instance:InitMarketTypeCfg()
	MarketCtrl.Instance:SendSaleTypeCountReq()
end

-- 玩家钻石改变时
-- function MarketView:PlayerDataChangeCallback(attr_name, value)
-- 	if attr_name == "gold" then
-- 	end
-- end

-- function MarketView:FlushGold()
-- 	local vo = GameVoManager.Instance:GetMainRoleVo()
-- 	local gold = vo.gold
-- end

function MarketView:ReleaseCallBack()
	if self.sell_view then
		self.sell_view:DeleteMe()
		self.sell_view = nil
	end
	if self.buy_view then
		self.buy_view:DeleteMe()
		self.buy_view = nil
	end

	if self.table_view then
		self.table_view:DeleteMe()
		self.table_view = nil
	end

	if self.purchase_view then
		self.purchase_view:DeleteMe()
		self.purchase_view = nil
	end

	-- if PlayerData.Instance then
	-- 	PlayerData.Instance:UnlistenerAttrChange(self.money_change_callback)
	-- end

	self.tabbar:DeleteMe()
	self.tabbar = nil
end

function MarketView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)

	if index_nodes then
		if index == TabIndex.market_buy then
			self.buy_view = MarketBuyView.New(index_nodes["BuyView"])
		elseif index == TabIndex.market_sell then
			self.sell_view = MarketSellView.New(index_nodes["SellView"])
		elseif index == TabIndex.market_table then
			self.table_view = MarketTableView.New(index_nodes["TableView"])
		elseif index == TabIndex.market_purchase then
			self.purchase_view = MarketPurchaseView.New(index_nodes["PurchaseView"])
		end
	end

	self.node_list["TitleText"].text.text = Language.Market.Tab
	if index == TabIndex.market_buy then
		self.buy_view:Flush()
		self.buy_view:FlushCurPage()
		self.buy_view:OnSearch(0)
	elseif index == TabIndex.market_sell then
		self.sell_view:Flush()
	elseif index == TabIndex.market_table then
		MarketCtrl.Instance:SendPublicSaleGetUserItemListReq()
		self.table_view:Flush()
	elseif index == TabIndex.market_purchase then
		self.purchase_view:Flush()
	end
end

function MarketView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if self.buy_view then
			self.buy_view:Flush()
			-- self:FlushGold()
		end
		if self.sell_view then
			self.sell_view:Flush()
		end
		if self.table_view then
			self.table_view:Flush()
		end
		if self.purchase_view then
			self.purchase_view:Flush(k, v)
		end
	end
end

function MarketView:FlushTable()
	if self.table_view then
		self.table_view:Flush()
	end
end