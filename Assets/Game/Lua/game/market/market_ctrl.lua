require("game/market/market_view")
require("game/market/market_data")
require("game/market/market_quick_sell_view")

MarketCtrl = MarketCtrl or  BaseClass(BaseController)

function MarketCtrl:__init()
	if MarketCtrl.Instance ~= nil then
		print_error("[MarketCtrl] attempt to create singleton twice!")
		return
	end
	MarketCtrl.Instance = self

	self:RegisterAllProtocols()

	self.view = MarketView.New(ViewName.Market)
	self.quick_sell_view = MarketQuickSellView.New(ViewName.QuickSell)
	self.market_data = MarketData.New()
end

function MarketCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if nil ~= self.quick_sell_view then
		self.quick_sell_view:DeleteMe()
		self.quick_sell_view = nil
	end

	if self.market_data ~= nil then
		self.market_data:DeleteMe()
		self.market_data = nil
	end

	MarketCtrl.Instance = nil
end

function MarketCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSShopBuy)
	self:RegisterProtocol(CSPublicSaleTypeCountReq)
	self:RegisterProtocol(CSPublicSaleSendItemInfoToWorld)
	self:RegisterProtocol(SCAddPublicSaleItemAck, "OnAddPublicSaleItem")
	self:RegisterProtocol(SCPublicSaleTypeCountAck, "OnPublicSaleTypeCountAck")
	self:RegisterProtocol(SCGetPublicSaleItemListAck, "OnGetPublicSaleItemList")
	self:RegisterProtocol(SCPublicSaleSearchAck, "OnPublicSaleSearch")
	self:RegisterProtocol(SCBuyPublicSaleItemAck, "OnBuyPublicSaleItemAck")
	self:RegisterProtocol(SCRemovePublicSaleItemAck, 'OnRemovePublicSaleItemAck')
	self:RegisterProtocol(SCWorldAcquisitionLog, 'OnWorldAcquisitionLog')
end

-- 商店购买请求
function MarketCtrl:SendShopBuy(item_id, item_num, is_bind, is_use)
	local cmd = ProtocolPool.Instance:GetProtocol(CSShopBuy)
	cmd.item_id = item_id
	cmd.item_num = item_num
	cmd.is_bind = is_bind
	cmd.is_use = is_use
	cmd:EncodeAndSend()
end

-- 商店购买请求
function MarketCtrl:SendSaleTypeCountReq()
	local cmd = ProtocolPool.Instance:GetProtocol(CSPublicSaleTypeCountReq)
	cmd:EncodeAndSend()
end

-- 物品上架返回
function MarketCtrl:OnAddPublicSaleItem(protocol)
	if self.view and self.view.sell_view then
		self.view.sell_view:Flush()
	end
	if(protocol.ret == 0) then    										-- 成功返回0
		SysMsgCtrl.Instance:ErrorRemind(Language.Market.JiShouSucc)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Market.JiShouCountLimit)
	end
end

-- 物品上架返回
function MarketCtrl:OnPublicSaleTypeCountAck(protocol)
	self.market_data:SetSaleTypeCountAck(protocol)
	if self.view:IsOpen() then
		self.view:Flush("flush_buy_list")
	end
end

-- 拍卖物品上架
function MarketCtrl:SendAddPublicSaleItemReq(sale_index, knapsack_index, item_num, price, price_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSAddPublicSaleItem)
	protocol.sale_index = sale_index
	protocol.knapsack_index = knapsack_index
	protocol.item_num = item_num
	protocol.gold_price = price
	protocol.price_type = price_type or MarketData.PriceTypeGold
	protocol.sale_item_type = MarketData.SaleItemTypeItem

	protocol:EncodeAndSend()
end

-- 请求获得自己的所有拍卖物品信息
function MarketCtrl:SendPublicSaleGetUserItemListReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSPublicSaleGetUserItemList)
	protocol:EncodeAndSend()
end

-- 获取自己出售物品列表
function MarketCtrl:OnGetPublicSaleItemList(protocol)
	MarketData.Instance:SetSaleItemList(protocol.sale_item_list)
	if self.view then
		self.view:FlushTable()
	end
end

-- 搜素请求
function MarketCtrl:SendPublicSaleSearchReq(flag)
	self.search_flag = flag
	local config = MarketData.Instance:GetSearchConfig()
	local protocol = ProtocolPool.Instance:GetProtocol(CSPublicSaleSearch)
	protocol.item_type = config.item_type
	protocol.req_page = config.req_page
	protocol.total_page = config.total_page
	protocol.color = config.color
	protocol.order = config.order
	protocol.fuzzy_type_count = config.fuzzy_type_count
	protocol.fuzzy_type_list = config.fuzzy_type_list
	protocol.page_item_count = 5
	protocol:EncodeAndSend()
end

-- 搜索返回
function MarketCtrl:OnPublicSaleSearch(protocol)
	if (0 == protocol.count and (self.search_flag == nil)) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Market.SelectEmpty)
	end
	self.market_data:SetCurPage(protocol.cur_page or 1)
	self.market_data:SetTotalPage(protocol.total_page or 0)
	self.market_data:SetSaleitemListMarket(protocol.saleitem_list)
	if self.view and self.view.buy_view then
		self.view.buy_view:CloseSearchWindow()
		self.view.buy_view:Flush()
	end
end

-- 购买物品
function MarketCtrl:SendBuyPublicSaleItem(seller_uid, sale_index, item_id, item_num, gold_price, sale_value, sale_item_type, price_type)
	if self:CheckAuthority(gold_price) then
		TipsCtrl.Instance:ShowSystemMsg(Language.Market.GoldLimit)
		return
	end

	local mine_uid = GameVoManager.Instance:GetMainRoleVo().role_id
	if mine_uid == seller_uid then
		SysMsgCtrl.Instance:ErrorRemind(Language.Market.GouMaiTips)
		return
	end

	local protocol = ProtocolPool.Instance:GetProtocol(CSBuyPublicSaleItem)
	protocol.seller_uid = seller_uid
	protocol.sale_index = sale_index

	if MarketData.SaleItemTypeItem == sale_item_type then --只有物品类型需要，否则服务端严格检查时通不过
		protocol.item_id = item_id
		protocol.item_num = item_num
	else
		protocol.item_id = 0
		protocol.item_num = 0
	end

	protocol.gold_price = gold_price
	protocol.sale_value = sale_value or 0
	protocol.sale_item_type = sale_item_type
	protocol.price_type = price_type
	protocol:EncodeAndSend()
end

-- 购买物品返回
function MarketCtrl:OnBuyPublicSaleItemAck(protocol)
	if(protocol.ret == 0) then
		if self.view and self.view.buy_view then
			self.view.buy_view:FlushNextMaxNum()
		end
		self:SendPublicSaleSearchReq()
		SysMsgCtrl.Instance:ErrorRemind(Language.Market.BuySucc)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Market.BuyFail)
	end
end

-- 物品下架
function MarketCtrl:SendRemovePublicSaleItem(sale_index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRemovePublicSaleItem)
	protocol.sale_index = sale_index
	protocol:EncodeAndSend()
end

-- 物品撤回服务器返回
function MarketCtrl:OnRemovePublicSaleItemAck(protocol)
	SysMsgCtrl.Instance:ErrorRemind(Language.Market.RecallSucc)
end

-- 从包裹出售物品
function MarketCtrl:SellFormBag(item_cfg)
	if self.view then
		ViewManager.Instance:Open(ViewName.Market, TabIndex.market_sell)
		self.view:Flush()
	end
	MarketData.Instance:SetItemId(item_cfg.id)
end

-- 发送自己的拍卖物品信息到世界聊天窗
function MarketCtrl:SendPublicSaleSendItemInfoToWorld(sale_index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSPublicSaleSendItemInfoToWorld)
	protocol.sale_index = sale_index
	protocol:EncodeAndSend()
end

function MarketCtrl:SendWorldAcquisitionLogReq(log_str_id, item_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSWorldAcquisitionLogReq)
	protocol.log_type = 0
	protocol.log_str_id = log_str_id or 0
	protocol.item_id = item_id or 0
	protocol:EncodeAndSend()
end

function MarketCtrl:OnWorldAcquisitionLog(protocol)
	self.market_data:SetWorldAcquisitionLog(protocol)
	self.view:Flush("purchase")
end

--检测内部测试号能否购买(返回true表示购买金额超过上限，false表示允许购买)
function MarketCtrl:CheckAuthority(gold_price)
  	local main_role_authority_type = GameVoManager.Instance:GetMainRoleVo().authority_type
  	if main_role_authority_type == AUTHORITY_TYPE.TEST then
		local agent_id = GLOBAL_CONFIG.package_info.config.agent_id 			-- 渠道号
		local deal_limit = MarketData.Instance:GetDealLimitByPlat(agent_id)  	-- 单次购买元宝上限
		if deal_limit >= 0 and gold_price > deal_limit then
			return true
		end
	end
	return false
end