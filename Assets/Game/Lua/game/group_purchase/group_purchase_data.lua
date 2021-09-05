GroupPurchaseData = GroupPurchaseData or BaseClass()

function GroupPurchaseData:__init()
	if GroupPurchaseData.Instance ~= nil then
		print_error("[GroupPurchaseData] attempt to create singleton twice!")
		return
	end
	GroupPurchaseData.Instance = self

	self.buy_item_num_info_list = {}
	self.cart_info_list = {}
end

function GroupPurchaseData:__delete()
	GroupPurchaseData.Instance = nil
end

--物品已购买数量
function GroupPurchaseData:SetItemHasPurchaseNumData(protocol)
	if protocol and protocol.buy_item_num then
		self.buy_item_num_info_list = protocol.buy_item_num
	end
end

--购物车信息
function GroupPurchaseData:SetCartData(protocol)
	if protocol and protocol.seq_list then
		self.cart_info_list = protocol.seq_list
	end
end

function GroupPurchaseData:GetAllCfg()
	if self.all_buy_discount_cfg and self.all_buy_item_cfg then
		return
	end

	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	self.all_buy_discount_cfg = cfg and cfg.combine_buy_discount
	self.all_buy_item_cfg = cfg and cfg.combine_buy_item
end

--根据开服时间获取组合购买折扣配置  
function GroupPurchaseData:GetBuyDiscountCfg()
	self:GetAllCfg()
	local data_cfg = {}
	if nil == self.all_buy_discount_cfg then
		return data_cfg
	end
	
	data_cfg = ActivityData.Instance:GetRandActivityConfig(self.all_buy_discount_cfg, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GROUP_PURCHASE) or {}
	return data_cfg
end

--根据开服时间获取组合购买物品配置  
function GroupPurchaseData:GetBuyItemCfg()
	self:GetAllCfg()
	local data_cfg = {}
	if nil == self.all_buy_item_cfg then
		return data_cfg
	end
	
	data_cfg = ActivityData.Instance:GetRandActivityConfig(self.all_buy_item_cfg, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GROUP_PURCHASE) or {}
	return data_cfg
end

--根据购买类型获取购买物品配置
function GroupPurchaseData:GetSingleTypeBuyItemCfgByType(buy_type)
	local cfg = self:GetBuyItemCfg()
	local single_cfg = {}
	if nil == cfg or nil == buy_type then
		return single_cfg
	end

	for k,v in pairs(cfg) do
		if v.item_type == buy_type then
			table.insert(single_cfg, v)
		end
	end

	if #single_cfg > 1 then
		table.sort(single_cfg, function(a, b)
			local order_a = 100000
			local order_b = 100000
			local a_seq = a.seq
			local b_seq = b.seq
			local a_is_sell_out = self:IsSellOut(a_seq)
			local b_is_sell_out = self:IsSellOut(b_seq)

			if a_is_sell_out and not b_is_sell_out then
				order_b = order_b + 10000
			elseif not a_is_sell_out and b_is_sell_out then
				order_a = order_a + 10000
			end

			if nil == a_seq or nil == b_seq then
				return order_a > order_b
			end

			if a_seq < b_seq then
				order_a = order_a + 100
			elseif a_seq > b_seq then
				order_b = order_b + 100
			end

			return order_a > order_b
		 end)
	end

	return single_cfg
end

--根据物品seq获取购买物品配置
function GroupPurchaseData:GetSingleTypeBuyItemCfgBySeq(seq)
	local cfg = self:GetBuyItemCfg()
	local single_cfg = {}
	if nil == cfg or nil == seq then
		return single_cfg
	end

	for k,v in pairs(cfg) do
		if v.seq == seq then
			single_cfg = v
			break
		end
	end

	return single_cfg
end

--根据购买数量获取购买折扣配置
function GroupPurchaseData:GetSingleDiscountCfgByBuyNum(num)
	local cfg = self:GetBuyDiscountCfg()
	local single_cfg = {}
	if nil == cfg or nil == num then
		return single_cfg
	end

	for k,v in pairs(cfg) do
		if v.item_count == num then
			single_cfg = v
		end
	end

	return single_cfg
end

--获取所有物品已购买数量(来自协议)
function GroupPurchaseData:GetAllItemHasPurchaseNum()
	local num_info_list = self.buy_item_num_info_list or {}
	return num_info_list
end

--获取单个物品已购买数量(来自协议)
function GroupPurchaseData:GetItemHasPurchaseNumBySeq(seq)
	local item_seq = seq or 0
	local num_info_list = self:GetAllItemHasPurchaseNum()
	local num = num_info_list[item_seq] or 0
	return num
end

--获取购物车信息
function GroupPurchaseData:GetCartData()
	local cart_info_list = self.cart_info_list or {}
	local has_add_cart_list = {}

	for i,v in pairs(cart_info_list) do
		if v > -1 then
			local list = {}
			list.index = i
			list.seq = v
 			table.insert(has_add_cart_list, list)
		end
	end

	return has_add_cart_list
end

--获取购物车内单个物品数量
function GroupPurchaseData:GetCartSingleTypeNumBySeq(seq)
	local num = 0
	local info_list = self:GetCartData()
	if nil == info_list or nil == seq then
		return num
	end

	for k,v in pairs(info_list) do
		if v.seq == seq then
			num = num + 1
		end
	end

	return num
end

--是否能加入购物车
function GroupPurchaseData:GetIsCanBuyBySeq(seq)
	local is_can_buy = false
	if nil == seq then
		return is_can_buy
	end

	local has_buy_num = self:GetItemHasPurchaseNumBySeq(seq)
	local cfg = self:GetSingleTypeBuyItemCfgBySeq(seq)
	local buy_limit_num = cfg and cfg.buy_limit
	if buy_limit_num and buy_limit_num == 0 then
		return true
	end

	local cart_num = self:GetCartSingleTypeNumBySeq(seq)
	if has_buy_num and buy_limit_num and cart_num then
		is_can_buy = (has_buy_num + cart_num) < buy_limit_num
	end

	return is_can_buy
end

--是否售完
function GroupPurchaseData:IsSellOut(seq)
	local is_sell_out = false
	if nil == seq then
		return is_sell_out
	end

	local has_buy_num = self:GetItemHasPurchaseNumBySeq(seq)
	local cfg = self:GetSingleTypeBuyItemCfgBySeq(seq)
	local buy_limit_num = cfg and cfg.buy_limit
	if buy_limit_num and buy_limit_num ~= 0 and has_buy_num >= buy_limit_num then
		is_sell_out = true
	end
	return is_sell_out
end

--获取原价和折后价
function GroupPurchaseData:GetCartAllPriceAndDiscountPrice()
	local cart_info_list = self:GetCartData()
	local all_price = 0
	local is_discount = false
	local dicount_price = 0

	for k,v in pairs(cart_info_list) do
		if v.seq then
			local cfg = self:GetSingleTypeBuyItemCfgBySeq(v.seq)
			if cfg and cfg.price then
				all_price = all_price + cfg.price
			end
		end
	end

	dicount_price = all_price

	local discount_cfg = self:GetSingleDiscountCfgByBuyNum(#cart_info_list)
	local discount = discount_cfg and discount_cfg.discount
	if discount then
		is_discount = true
		dicount_price = math.ceil(all_price * (discount / 100))
	end

	return is_discount, all_price, dicount_price
end