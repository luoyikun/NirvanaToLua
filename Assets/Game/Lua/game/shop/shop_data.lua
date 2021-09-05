ShopData = ShopData or BaseClass()

function ShopData:__init()
	if ShopData.Instance then
		print_error("[ShopData] Attemp to create a singleton twice !")
	end
	ShopData.Instance = self
	self.flushtime = 0
	self.flag = 0
	self.mysterious_cfg = ConfigManager.Instance:GetAutoConfig("mysterious_shop_in_mall_auto")
	self.mysterious_item_list_cfg = ListToMap(self.mysterious_cfg.mysterious_shop_item, "seq")
	self.mysterious_other_cfg = self.mysterious_cfg.other
	self.other_cfg = self.mysterious_cfg.other[1] or {}
	self.jifen_item_list_cfg = ExchangeData.Instance:GetItemListByConverType(8)
	RemindManager.Instance:Register(RemindName.ShenmiShop, BindTool.Bind(self.GetShopShenMiRemind, self))
	RemindManager.Instance:Register(RemindName.TeHuiShop, BindTool.Bind(self.GetShopTeHuiRemind, self))
	self.client_remind_flag = 0
	self.today_refresh_level = 1
	self.send_type = -1
	self.item_list_info = {}
	self.audit_shenmi_shop_data = {}
end

function ShopData:__delete()
	ShopData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.ShenmiShop)
	RemindManager.Instance:UnRegister(RemindName.TeHuiShop)

	self.client_remind_flag = 0
	self.send_type = -1
end

SHOP_BIND_TYPE =
{
	BIND = 1,
	NO_BIND = 2,
}
SHOP_COL_ITEM = 2

--获取所有商店item配置
function ShopData:GetAllShopItemCfg()
	return ConfigManager.Instance:GetAutoConfig("shop_auto").item
end

function ShopData:GetAllFenquShopItemCfg()
	return ConfigManager.Instance:GetAutoConfig("shop_auto").fenqu
end

function ShopData:GetAllTehuiShopItemCfg()
	return ConfigManager.Instance:GetAutoConfig("mysterious_shop_in_mall_auto").tehui
end

function ShopData:GetTeHuiShopItemCfg()
	local item_list = {}
	local current_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	for i = #self.mysterious_cfg.show_item, 1, -1 do
		if #item_list >= 8 then
			break
		end
		if self.mysterious_cfg.show_item[i].open_day <= current_open_day then
			table.insert(item_list, TableCopy(self.mysterious_cfg.show_item[i]))
		end
	end

	local item_list_two = {}
	local index = #item_list
	for i = 1, #item_list do
		table.insert(item_list_two, item_list[index])
		index = index - 1
	end
	return item_list_two
end

--获取单个商店item配置
function ShopData:GetShopItemCfg(item_id)
	local all_item_cfg = self:GetAllShopItemCfg()
	for k,v in pairs(all_item_cfg) do
		if v.itemid == item_id then
			return v
		end
	end
end

function ShopData:GetOtherCfg()
	return self.other_cfg
end

--获取单个商店item配置
function ShopData:GetShopItemCfgByIndex(item_id)
	local all_item_cfg = self:GetAllShopItemCfg()
	return all_item_cfg[item_id] or {}
end

function ShopData:GetItemIdListType(shop_type)
	local all_item_cfg = self:GetAllFenquShopItemCfg()
	local item_id_list = {}
	local open_sever_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	for k,v in pairs(all_item_cfg) do
		if v.shop_type == shop_type then
			if role_level >= v.levelopen_min and role_level <= v.levelopen_max and open_sever_day >= v.openday_min and open_sever_day <= v.openday_max then
				item_id_list[#item_id_list + 1] = v.item_id
			end
		end
	end
	return item_id_list
end

--供滚动条使用
function ShopData:GetItemListByTypeAndIndex(shop_type,index)
	local all_fenqu_cfg = self:GetAllFenquShopItemCfg()
	local item_id_list = {}
	local open_sever_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	for k,v in pairs(all_fenqu_cfg) do
		if v.shop_type == shop_type then
			if role_level >= v.levelopen_min and role_level <= v.levelopen_max and open_sever_day >= v.openday_min and open_sever_day <= v.openday_max then
				item_id_list[#item_id_list + 1] = v.item_id
			end
		end
	end
	local new_id_list = {}
	if index == 1 then
		for i = 1 , SHOP_COL_ITEM do
			new_id_list[#new_id_list + 1] = item_id_list[i]
		end
		return new_id_list
	end
	for i = 1 , SHOP_COL_ITEM do
		if item_id_list[(index -  1 ) * SHOP_COL_ITEM + i] == nil then
			item_id_list[(index -  1 ) * SHOP_COL_ITEM + i] = 0
		end
		new_id_list[#new_id_list + 1] = item_id_list[(index -  1 ) * SHOP_COL_ITEM + i]
	end
	return new_id_list
end

function ShopData:GetTeHuiItemIdList()
	local all_item_cfg = self:GetAllTehuiShopItemCfg()
	local item_num = 0
	local open_sever_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local base_prof = PlayerData.Instance:GetRoleBaseProf()
	local role_level = self.today_refresh_level
	for k,v in pairs(all_item_cfg) do
		if role_level >= v.levelopen_min and role_level <= v.levelopen_max and open_sever_day >= v.openday_min and open_sever_day <= v.openday_max then
			if v.limit_prof ~= "" then
				local split_tbl = Split(v.limit_prof, ",")
				for i, j in ipairs(split_tbl) do
					if base_prof == tonumber(j) then
						item_num = item_num + 1
					end
				end
			else
				item_num = item_num + 1
			end
		end
	end
	return item_num
end

function ShopData:GeITeHuitemListIndex(index)
	local all_tehui_cfg = self:GetAllTehuiShopItemCfg() or {}
	local item_id_list = {}
	local open_sever_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local base_prof = PlayerData.Instance:GetRoleBaseProf()
	local role_level = self.today_refresh_level
	for k,v in pairs(all_tehui_cfg) do
		if role_level >= v.levelopen_min and role_level <= v.levelopen_max and open_sever_day >= v.openday_min and open_sever_day <= v.openday_max then
			if v.limit_prof ~= "" then
				local split_tbl = Split(v.limit_prof, ",")
				for i, j in ipairs(split_tbl) do
					if base_prof == tonumber(j) then
						item_id_list[#item_id_list + 1] = v
					end
				end
			else
				item_id_list[#item_id_list + 1] = v
			end
		end
	end

	local new_id_list = {}
	if index == 1 then
		for i = 1 , SHOP_COL_ITEM do
			new_id_list[#new_id_list + 1] = item_id_list[i]
		end
		return new_id_list
	end
	for i = 1 , SHOP_COL_ITEM do
		if item_id_list[(index -  1 ) * SHOP_COL_ITEM + i] == nil then
			item_id_list[(index -  1 ) * SHOP_COL_ITEM + i] = {}
		end
		new_id_list[#new_id_list + 1] = item_id_list[(index -  1 ) * SHOP_COL_ITEM + i]
	end
	return new_id_list
end

--获取物品被动消耗类配置
function ShopData:GetItemOtherCfg(item_id)
	return ConfigManager.Instance:GetAutoItemConfig("other_auto")[item_id]
end

--获取物品的购买货币类型
function ShopData:GetConsumeType(shop_type)
	local all_fenqu_cfg = self:GetAllFenquShopItemCfg()
	for k,v in pairs(all_fenqu_cfg) do
		if v.shop_type == shop_type then
			return v.consume_type
		end
	end
end

--检查商城中是否有该物品
function ShopData:CheckIsInShop(item_id)
	local cfg = self:GetAllShopItemCfg()
	for k,v in pairs(cfg) do
		if v.itemid == item_id then
			return true
		end
	end
	return false
end

--检测是否够钱买商城的物品,优先使用绑定
function ShopData:CheckCanBuyItem(item_id)
	if not self:CheckIsInShop(item_id) then return end

	local vo = GameVoManager.Instance:GetMainRoleVo()
	local cfg = self:GetShopItemCfg(item_id)
	if cfg.bind_gold ~= 0 then
		if vo.bind_gold >= cfg.bind_gold then
			return SHOP_BIND_TYPE.BIND
		else
			if vo.gold >= cfg.gold then
				return SHOP_BIND_TYPE.NO_BIND
			end
		end
	else
		if vo.gold >= cfg.gold then
			return SHOP_BIND_TYPE.NO_BIND
		end
	end
	return
end

function ShopData:SetShenMiShop(protocol)
	self.info = protocol

	self.audit_shenmi_shop_data = {}
	if self.info and self.info.seq_list then
		for k,v in pairs(self.info.seq_list) do
			local temp_data = {}
			temp_data.seq = k - 1
			temp_data.isbuy_status = v.state
			if v.seq and self.mysterious_item_list_cfg[v.seq] then
				local cfg_data = self.mysterious_item_list_cfg[v.seq]
				local item_cfg = ItemData.Instance:GetItemConfig(cfg_data.item.item_id)
				temp_data.item_name = ""
				if item_cfg then
					temp_data.item_name = item_cfg.name
					temp_data.item_color = item_cfg.color
				end
				temp_data.item_id = cfg_data.item.item_id
				temp_data.num = cfg_data.item.num
				temp_data.is_bind = cfg_data.item.is_bind
				temp_data.item_price = cfg_data.price
				table.insert(self.audit_shenmi_shop_data, temp_data)
			end
		end
	end
	IosAuditSender:UpdateShopData()
end

function ShopData:GetAuditShenMiShop()
	return self.audit_shenmi_shop_data or {}
end

function ShopData:GetShenMiShop()
	-- local open_sever_day = TimeCtrl.Instance:GetCurOpenServerDay()
	-- local role_level = GameVoManager.Instance:GetMainRoleVo().level
	-- for i = #self.info.seq_list, 1, -1 do
	-- 	if self.mysterious_item_list_cfg[self.info.seq_list[i].seq] then
	-- 		if role_level < self.mysterious_item_list_cfg[self.info.seq_list[i].seq].levelopen_min or role_level > self.mysterious_item_list_cfg[self.info.seq_list[i].seq].levelopen_max or 
	-- 			open_sever_day < self.mysterious_item_list_cfg[self.info.seq_list[i].seq].openday_min or open_sever_day > self.mysterious_item_list_cfg[self.info.seq_list[i].seq].openday_max then
	-- 			table.remove(self.info.seq_list, i)
	-- 		end
	-- 	end
	-- end

	return self.info
end

function ShopData:GetTodayFlushCount()
	if self.info then
		return self.info.today_free_count
	end
end

function ShopData:IsMyteriousIsBuyed(cell_index)
	local t = self.info.seq_list[cell_index]
	if nil == t then
		return false
	end

	return 1 == t.state
end

function ShopData:GetMysteriousShopItemCfg(cell_index)
	local t = self.info.seq_list[cell_index]
	if nil == t then
		return nil
	end

	return self.mysterious_item_list_cfg[t.seq]
end

function ShopData:GetMysteriousShopZhenXiStr(is_all)
	local str = ""
	if nil == self.info.seq_list then
		return str
	end
	local str_list = {}
	for i, v in ipairs(self.info.seq_list) do
		local t = self.info.seq_list[i]
		if nil ~= t then
			if is_all == true and self.mysterious_item_list_cfg[t.seq] and self.mysterious_item_list_cfg[t.seq].is_zhenxi == 1 and t.state == 0 then
				local name = ItemData.Instance:GetItemName(self.mysterious_item_list_cfg[t.seq].item.item_id)
				local num = "*" .. self.mysterious_item_list_cfg[t.seq].item.num
				local zhenxi_str = name .. num
				table.insert(str_list, zhenxi_str)
			elseif is_all == false and i == 1 and self.mysterious_item_list_cfg[t.seq] and self.mysterious_item_list_cfg[t.seq].is_zhenxi == 1 and t.state == 0 then
				local name = ItemData.Instance:GetItemName(self.mysterious_item_list_cfg[t.seq].item.item_id)
				local num = "*" .. self.mysterious_item_list_cfg[t.seq].item.num
				local zhenxi_str = name .. num
				table.insert(str_list, zhenxi_str)				
			end
		end
	end
	for i, v in ipairs(str_list) do
		if v and i ~= #str_list then
			str = str .. v .. "、"
		elseif v and i == #str_list then
			str = str .. v
		end
	end
	return str
end

function ShopData:GetJifenItemListCfg()
	return self.jifen_item_list_cfg
end

function ShopData:GetJifenItemCfg(index)
	return self.jifen_item_list_cfg[index]
end

function ShopData:GetShopShenMiRemind()
	if not OpenFunData.Instance:CheckIsHide("shopview") then
		return 0
	end
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local today_free_count = tonumber(self:GetTodayFlushCount()) or 0
	local num1 = 0
	if today_free_count > 0 then
		num1 = 1
	end
	if (self.client_remind_flag > 0 or num1 > 0) and main_vo.level >= 120 then
		return 1
	end
	return 0
end

function ShopData:GetShopTeHuiRemind()
	if not OpenFunData.Instance:CheckIsHide("shopview") then
		return 0
	end
	local cfg = RemindManager.Instance:RemindToday(RemindName.TeHuiShop)
	if not cfg then
		return 1
	end

	return 0
end

function ShopData:GetShopShenMiFlag()
 	return self.flag
end

function ShopData:GetFlushPrice()
	return self.mysterious_other_cfg
end

function ShopData:SetClientRemindFlag(client_remind_flag)
	self.client_remind_flag = client_remind_flag
end

function ShopData:SetSendType(send_type)
	self.send_type = send_type
end

function ShopData:GetSendType()
	return self.send_type
end

function ShopData:SetDiscounthopItemInfo(protocol)
	self.item_list_info = protocol.item_list
	self.today_refresh_level = protocol.today_refresh_level
end

function ShopData:GetDiscounthopItemBuyCount(seq)
	local buy_count = 0
	local tehui_cfg = self:GetAllTehuiShopItemCfg()
	for i,v in ipairs(tehui_cfg) do
		if seq == v.seq then
			buy_count = v.buy_limit
			break
		end
	end

	for i,v in ipairs(self.item_list_info) do
		if seq == v.seq then
			buy_count = buy_count - v.today_buy_count
		end
	end

	return buy_count
end

function ShopData:GetDiscounthopItemBuyPrice(seq)
	local tehui_cfg = self:GetAllTehuiShopItemCfg()
	for i,v in ipairs(tehui_cfg) do
		if seq == v.seq then
			return v.price
		end
	end
	return 9999
end