TreasureData = TreasureData or BaseClass()

TREASURE_MAX_COUNT = 320 --寻宝仓库最大数，服务端为320
TREASURE_ROW = 10 --格子列数
TREASURE_COLUMN = 5 --行数
TREASURE_ALL_ROW = 70 --背包总列数

TREASURE_SHOW_ROW = 5 --格子列数
TREASURE_SHOW_COLUMN = 2 --行数
TREASURE_SHOW_ALL_ROW = 25 --背包总列数
TREASURE_EXCHANGE_CONVER_TYPE = 3  --寻宝兑换类型
TREASURE_EXCHANGE_PRICE_TYPE = 5   --价格类型
RARE_EXCHANGE_TYPE = 9 --珍宝兑换类型
RARE_EXCHANGE_PRICE_TYPE = 5 	--珍宝兑换价格类型

--寻宝种类
TREASURE_TYPE ={
	TREASURE1 = CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP,
	TREASURE2 = CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP1,
	TREASURE3 = CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP2,
}

function TreasureData:__init()
	if TreasureData.Instance then
		print_error("[TreasureData] Attemp to create a singleton twice !")
	end
	TreasureData.Instance = self
	self.turn_id_list = {}
	self.fixed_id_list = {}
	self.treasure_score = 0
	self.treasure_score1 = 0
	self.treasure_score2 = 0
	self.chest_item_info = {}
	self.chest_item_info_index = {}
	self.chest_shop_next_free_time_1 = -1
	self.chest_shop_jl_next_free_time_1 = -1
	self.count = -1
	self.current_chest_item_info = {}
	self.current_chest_count = 0
	self.remain_time = 0
	self.is_shield = false
	self.chest_shop_mode = -1
	self.show_cfg = {}
	self.item_id_list = {}
	self.item_id_list1 = {}
	self.chest_shop_next_free_time_1 = 0
	self.chest_shop_1_next_free_time_1 = 0
	self.chest_shop_2_next_free_time_1 = 0
	self.chest_shop_jl_next_free_time_1 = 0
	-- GlobalEventSystem:Bind(BagFlushEventType.BAG_FLUSH_CONTENT, BindTool.Bind1(self.GetXunBaoRedPoint, self))

	RemindManager.Instance:Register(RemindName.XunBaoTreasure1, BindTool.Bind(self.GetRemindXunBao1, self))
	RemindManager.Instance:Register(RemindName.XunBaoTreasure2, BindTool.Bind(self.GetRemindXunBao2, self))
	RemindManager.Instance:Register(RemindName.XunBaoTreasure3, BindTool.Bind(self.GetRemindXunBao3, self))
	RemindManager.Instance:Register(RemindName.XunBaoWarehouse, BindTool.Bind(self.GetRemindWareHouse, self))
end

function TreasureData:__delete()
	RemindManager.Instance:UnRegister(RemindName.XunBaoTreasure1)
	RemindManager.Instance:UnRegister(RemindName.XunBaoTreasure2)
	RemindManager.Instance:UnRegister(RemindName.XunBaoTreasure3)
	RemindManager.Instance:UnRegister(RemindName.XunBaoWarehouse)

	TreasureData.Instance = nil
end

function TreasureData:ClearData()
	self.current_chest_item_info = {}
end

function TreasureData:GetTreasureScore()
	return self.treasure_score
end

function TreasureData:GetTreasureScore1()
	return self.treasure_score1
end

function TreasureData:GetTreasureScore2()
	return self.treasure_score2
end

function TreasureData:GetIsShield()
	return self.is_shield
end

function TreasureData:SetIsShield(is_shield)
	self.is_shield = is_shield
end

function TreasureData:SetTreasureScore(treasure_score)
	self.treasure_score = treasure_score
end

function TreasureData:SetTreasureScore1(treasure_score)
	self.treasure_score1 = treasure_score
end

function TreasureData:SetTreasureScore2(treasure_score)
	self.treasure_score2 = treasure_score
end

function TreasureData:OnSelfChestShopItemList(protocol)
	self.chest_item_info = protocol.chest_item_info
	self.count = protocol.count
	self.chest_item_info_index = protocol.chest_item_info_index
	self:SetRemindBtnWarehouse()
end

-- 设置异火仓库的红点提示，策划要求寻宝仓库有物品都显示红点
function TreasureData:SetRemindBtnWarehouse()
	local btn_remind = HunQiCtrl.Instance:GetRemindBtnWarehouse()
	if btn_remind then
		btn_remind:SetActive(next(self.chest_item_info) ~= nil)
	end
end

function TreasureData:OnChestShopItemListPerBuy(protocol)
	self.current_chest_item_info = protocol.chest_item_info
	self.current_chest_count = protocol.count

	for k,v in pairs(self.current_chest_item_info) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		v.param.color = 0
		if nil ~= item_cfg then
			v.param.color = item_cfg.color
		end
	end

	local func = function (a, b)
		if a.param.color > b.param.color then
			return true
		else
			return false
		end
	end
	table.sort(self.current_chest_item_info, func)
end

function TreasureData:GetChestShopItemInfo()
	return self.current_chest_item_info
end

function TreasureData:GetCurrentChestCount()
	return self.current_chest_count
end

function TreasureData:OnChestShopFreeInfo(protocol)
	self.chest_shop_next_free_time_1 = protocol.chest_shop_next_free_time_1
	self.chest_shop_1_next_free_time_1 = protocol.chest_shop_1_next_free_time_1
	self.chest_shop_2_next_free_time_1 = protocol.chest_shop_2_next_free_time_1
	self.chest_shop_jl_next_free_time_1 = protocol.chest_shop_jl_next_free_time_1
end

function TreasureData:GetChestFreeTime(index)
	local index = index or self:GetChouJiangIndex()
	if TREASURE_TYPE.TREASURE1 == index then
		return self.chest_shop_next_free_time_1
	elseif TREASURE_TYPE.TREASURE2 == index then
		return self.chest_shop_1_next_free_time_1
	elseif TREASURE_TYPE.TREASURE3 == index then
		return self.chest_shop_2_next_free_time_1
	end
	return 0
end

function TreasureData:GetChestJlFreeTime()
	return self.chest_shop_jl_next_free_time_1
end

function TreasureData:GetChestItemInfo()
	return self.chest_item_info
end

function TreasureData:GetChestItemInfoIndex()
	return self.chest_item_info_index
end

function TreasureData:GetCurrentChestItemInfo()
	local new_list = {}
	for k,v in pairs(self.current_chest_item_info) do
		new_list[#new_list + 1] = v
	end
	return new_list
end

function TreasureData:SetChestShopMode(mode)
	self.chest_shop_mode = mode
end

function TreasureData:GetChestShopMode()
	return self.chest_shop_mode
end

function TreasureData:GetChestCount()
	return self.count
end

function TreasureData:SortList(is_first)
	if is_first == false then
		local new_list = {}
		new_list[1] = self.turn_id_list[#self.turn_id_list]
		for i = 1, 11 do
			new_list[#new_list + 1] = self.turn_id_list[i]
		end
		self.turn_id_list = {}
		self.turn_id_list = new_list
	end
	return self.turn_id_list
end

function TreasureData:GetTurnIdList()
	return self.turn_id_list
end

--获取需要加载的配置
function TreasureData:GetShowItemCfg(xunbao_type)
	local opengame_day = self:GetUseOpenGameDay(xunbao_type)
	local rare_item_list = self:GetChestshopCfg().rare_item_list
	local new_type_item_list = {}
	for k,v in pairs(rare_item_list) do
		if v.xunbao_type == xunbao_type and v.opengame_day == opengame_day then
			new_type_item_list[#new_type_item_list + 1] = v
		end
	end
	return new_type_item_list
end

--获取物品被动消耗类配置
function TreasureData:GetItemOtherCfg(item_id)
	return ConfigManager.Instance:GetAutoItemConfig("other_auto")[item_id]
end

--获取所有兑换配置
function TreasureData:GetAllExchangeCfg()
	return ConfigManager.Instance:GetAutoConfig("convertshop_auto").convert_shop
end

--获取单个兑换配置
function TreasureData:GetExchangeCfg(item_id)
	local item_list = self:GetAllExchangeCfg()
	for k,v in pairs(item_list) do
		if v.item_id == item_id then
			return v
		end
	end
end

function TreasureData:GetItemIdListByJobAndType(conver_type, price_type, job)
	local all_item_cfg = self:GetAllExchangeCfg()
	local item_id_list = {}
	for k,v in pairs(all_item_cfg) do
		if v.conver_type == conver_type then
			if v.price_type == price_type then
				if v.show_limit == (job % 10) or v.show_limit == 5 then
					local cfg = {v.item_id, v.is_jueban}
					item_id_list[#item_id_list + 1] = cfg
				end
			end
		end
	end

	local is_activity_open = ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RARE_CHANGE)
	if not is_activity_open then
		for i = #item_id_list, 1, -1 do
			local list = item_id_list[i]
			if list[2] == 1 then
				table.remove(item_id_list, i)
			end
		end
	end
	return item_id_list
end

function TreasureData:GetXunbaoListByJobAndType(conver_type,job)
	local all_item_cfg = self:GetAllExchangeCfg()
	local item_id_list = {}
	for k,v in pairs(all_item_cfg) do
		if v.conver_type == conver_type then
				if v.show_limit == (job % 10) or v.show_limit == 5 then
					local cfg = {v.item_id, v.is_jueban}
					item_id_list[#item_id_list + 1] = cfg
				end
		end
	end
	-- local is_activity_open = ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RARE_CHANGE)
	-- if not is_activity_open then
	-- 	for i = #item_id_list, 1, -1 do
	-- 		local list = item_id_list[i]
	-- 		if list[2] == 1 then
	-- 			table.remove(item_id_list, i)
	-- 		end
	-- 	end
	-- end
	return item_id_list
end


--获取珍宝兑换商品
function TreasureData:GetRareChangeList()
	local all_item_cfg = self:GetAllExchangeCfg()
	local item_id_list = {}
	for k,v in pairs(all_item_cfg) do
		if v.conver_type == RARE_EXCHANGE_TYPE then
			if v.price_type == RARE_EXCHANGE_PRICE_TYPE then
				local cfg = {v.item_id, v.is_jueban}
				item_id_list[#item_id_list + 1] = cfg
			end
		end
	end
	return item_id_list
end


function TreasureData:GetXunBaoItemListByJobAndIndex(conver_type, price_type, job, index)
	local item_id_list = {}
	if not next(self.item_id_list) then
		item_id_list = self:GetItemCfgList(conver_type, price_type, job)
	else
		item_id_list = self.item_id_list
	end

	local job_id_list = {}
	if index == 1 then
		for i = 1, 4 do
			if item_id_list[i] ~= nil then
				job_id_list[#job_id_list + 1] = item_id_list[i]
			else
				job_id_list[#job_id_list + 1] = {0, 0}
			end
		end
		return job_id_list
	end
	for i = 1, 4 do
		if item_id_list[(index - 1)*4 + i] == nil then
			item_id_list[(index - 1)*4 + i] = {0, 0}
		end
		job_id_list[#job_id_list + 1] = item_id_list[(index - 1)*4 + i]
	end
	return job_id_list
end

function TreasureData:GetItemListByJobAndIndex(conver_type, price_type, job, index)
	local item_id_list = {}
	if not next(self.item_id_list) then
		item_id_list = self:GetItemCfgList(conver_type, price_type, job)
	else
		item_id_list = self.item_id_list
	end

	local job_id_list = {}
	if index == 1 then
		for i = 1, 4 do
			if item_id_list[i] ~= nil then
				job_id_list[#job_id_list + 1] = item_id_list[i]
			else
				job_id_list[#job_id_list + 1] = {0, 0}
			end
		end
		return job_id_list
	end
	for i = 1, 4 do
		if item_id_list[(index - 1)*4 + i] == nil then
			item_id_list[(index - 1)*4 + i] = {0, 0}
		end
		job_id_list[#job_id_list + 1] = item_id_list[(index - 1)*4 + i]
	end
	return job_id_list
end

function TreasureData:ForgetItemIdList()
	self.item_id_list = {}
end



function TreasureData:GetItemCfgList(conver_type, price_type, job)
	local role_vo_level = PlayerData.Instance:GetRoleVo().level
	if not next(self.item_id_list) then
		--如果有珍宝兑换
		local item_id_list = {}
		if  conver_type ~= 3 then
			 item_id_list = self:GetItemIdListByJobAndType(conver_type, price_type, job)
		else
			 item_id_list = self:GetXunbaoListByJobAndType(conver_type, job)
		end
		if self:IsFlashChange() then
			local all_item_id = {}
			local rare_list = self:GetRareChangeList()
			for k,v in pairs(rare_list) do
				table.insert(all_item_id, v)
			end
			for k,v in pairs(item_id_list) do
				table.insert(all_item_id, v)
			end
			item_id_list = all_item_id
		end
		--兑换次数满，移动到最后，永久兑换的兑换完不显示，等级不够的不显示
		local all_item_id1 = {}
		local all_item_id2 = {}
		for _,v in pairs(item_id_list) do
			local item_info = ExchangeData.Instance:GetExchangeCfg(v[1], EXCHANGE_PRICE_TYPE.TREASURE)
			local conver_value = ExchangeData.Instance:GetConvertCount(item_info.seq, EXCHANGE_CONVER_TYPE.XUN_BAO, EXCHANGE_PRICE_TYPE.TREASURE)
			local lifetime_conver_value = ExchangeData.Instance:GetLifetimeRecordCount(item_info.seq, EXCHANGE_CONVER_TYPE.XUN_BAO, EXCHANGE_PRICE_TYPE.TREASURE)
			if item_info.lifetime_convert_count ~= 0 and lifetime_conver_value >= item_info.lifetime_convert_count then
			elseif role_vo_level < item_info.require_value or role_vo_level > item_info.require_value_max then
			elseif item_info.limit_convert_count ~= 0 and conver_value >= item_info.limit_convert_count then
				table.insert(all_item_id2, v)
			else
				table.insert(all_item_id1, v)
			end
		end
		for _,v in pairs(all_item_id2) do
			table.insert(all_item_id1, v)
		end
		item_id_list = all_item_id1
		self.item_id_list = item_id_list
	end
	return self.item_id_list
end


function TreasureData:GetItemCfgListByIndex(conver_type, price_type, job, index)
	local item_id_list = self.item_id_list
	local role_vo_level = PlayerData.Instance:GetRoleVo().level
	--兑换次数满，移动到最后
	local all_item_id1 = {}
	local all_item_id2 = {}
	for _,v in pairs(item_id_list) do
		local item_info = ExchangeData.Instance:GetExchangeCfg(v[1], EXCHANGE_PRICE_TYPE.TREASURE)
		if item_info then
			local conver_value = ExchangeData.Instance:GetConvertCount(item_info.seq, EXCHANGE_CONVER_TYPE.XUN_BAO, EXCHANGE_PRICE_TYPE.TREASURE)
			local lifetime_conver_value = ExchangeData.Instance:GetLifetimeRecordCount(item_info.seq, EXCHANGE_CONVER_TYPE.XUN_BAO, EXCHANGE_PRICE_TYPE.TREASURE)
			if role_vo_level < item_info.require_value or role_vo_level > item_info.require_value_max then
			elseif item_info.limit_convert_count ~= 0 and conver_value >= item_info.limit_convert_count or 
				item_info.lifetime_convert_count ~= 0 and lifetime_conver_value >= item_info.lifetime_convert_count then
				table.insert(all_item_id2, v)
			else
				table.insert(all_item_id1, v)
			end
		end
	end
	for _,v in pairs(all_item_id2) do
		table.insert(all_item_id1, v)
	end
	item_id_list = all_item_id1
	self.item_id_list = item_id_list
	return self:GetItemListByJobAndIndex(conver_type, price_type, job, index)
end

--通过索引获得展示寻宝格子对应的编号
function TreasureData:GetGridIndexById(item_id)
	for k,v in pairs(self.chest_item_info) do
		if v.item_id == item_id then
			return v.server_grid_index
		end
	end
	return -1
end

--通过索引获得展示寻宝格子对应的编号集合
function TreasureData:GetShowCellIndexList(cell_index)
	local cell_index_list = {}
	local x = math.floor(cell_index/TREASURE_SHOW_ROW)
	if x > 0 and x * TREASURE_SHOW_ROW ~= cell_index then
		cell_index = cell_index + TREASURE_SHOW_ROW * (TREASURE_SHOW_COLUMN - 1) * x
	elseif x > 1 and x * TREASURE_SHOW_ROW == cell_index then
		cell_index = cell_index + TREASURE_SHOW_ROW * (TREASURE_SHOW_COLUMN - 1) * (x - 1)
	end
	for i = 1, 2 do
		if i == 1 then
			cell_index_list[i] = cell_index + i - 1
		else
			cell_index_list[i] = cell_index + TREASURE_SHOW_ROW * (i - 1)
		end
	end
	return cell_index_list
end

--获取寻宝价格
function TreasureData:GetTreasurePrice(chest_shop_mode)
	local other_cfg = self:GetOtherCfg()
	local price = 0
	if chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_1 then
		price = other_cfg.gold_1
	elseif chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_10 then
		price = other_cfg.gold_10
	elseif chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_50 then
		price = other_cfg.gold_30
	elseif chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE1_1 then
		price = other_cfg.gold1_1
	elseif chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE1_10 then
		price = other_cfg.gold1_10
	elseif chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE1_30 then
		price = other_cfg.gold1_30
	elseif chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE2_1 then
		price = other_cfg.gold2_1
	elseif chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE2_10 then
		price = other_cfg.gold2_10
	elseif chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE2_30 then
		price = other_cfg.gold2_30
	end
	return price
end

function TreasureData:GetChestshopCfg()
	if not self.chestshop_cfg then
		self.chestshop_cfg = ConfigManager.Instance:GetAutoConfig("chestshop_auto")
	end
	return self.chestshop_cfg
end

function TreasureData:GetOtherCfg()
	if not self.chestshop_other_cfg then
		self.chestshop_other_cfg = self:GetChestshopCfg().other[1]
	end
	return self.chestshop_other_cfg
end

function TreasureData:GetTreasureLimitLevel()
	return ConfigManager.Instance:GetAutoConfig("convertshop_auto").convert_shop
end

function TreasureData:GetUseOpenGameDay(xunbao_type)
	local rare_item_list = self:GetChestshopCfg().rare_item_list
	local opengame_day_record = {}
	local opengame_day_list = {}
	for k, v in pairs(rare_item_list) do
		if v.xunbao_type == xunbao_type and nil == opengame_day_record[v.opengame_day] then
			opengame_day_record[v.opengame_day] = 1
			table.insert(opengame_day_list, v.opengame_day)
		end
	end

	table.sort(opengame_day_list, function(a, b) return a < b end)

	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	for i, v in ipairs(opengame_day_list) do
		if open_server_day >= v then
			return v
		end
	end
	return opengame_day_list[1]
end

function TreasureData:GetRemindXunBao()
	for k, v in pairs(TREASURE_TYPE) do
		if self:GetXunBaoRedPoint(v) then
			return 1
		end
	end
	return 0
end

function TreasureData:GetRemindXunBao1()
	local fun_is_open = true
	fun_is_open = OpenFunData.Instance:CheckIsHide("treasure")
	return self:GetXunBaoRedPoint(TREASURE_TYPE.TREASURE1) and fun_is_open and 1 or 0
end

function TreasureData:GetRemindXunBao2()
	local fun_is_open = true
	fun_is_open = OpenFunData.Instance:CheckIsHide("df_treasure")
	return self:GetXunBaoRedPoint(TREASURE_TYPE.TREASURE2) and fun_is_open and 1 or 0
end

function TreasureData:GetRemindXunBao3()
	local fun_is_open = true
	fun_is_open = OpenFunData.Instance:CheckIsHide("zz_treasure")
	return self:GetXunBaoRedPoint(TREASURE_TYPE.TREASURE3) and fun_is_open and 1 or 0
end

function TreasureData:GetRemindWareHouse()
	local fun_is_open = true
	fun_is_open = OpenFunData.Instance:CheckIsHide("treasure")
	return self:GetXunBaoWareRedPoint() and fun_is_open and 1 or 0
end

function TreasureData:GetXunBaoWareRedPoint()
	local ware_red_point = false
	if ItemData.Instance:GetEmptyNum() > 0 then
		if self:GetChestCount() > 0 then
			ware_red_point = true
		end
	end
	return ware_red_point
end

function TreasureData:GetXunBaoRedPoint(index)
	local xun_bao_red_point = false
	local can_chest_time = self:GetChestFreeTime(index)
	if can_chest_time - TimeCtrl.Instance:GetServerTime() < 0 then
		xun_bao_red_point = true
	end
	xun_bao_red_point = xun_bao_red_point or self:GetHaveKey(index)
	return xun_bao_red_point
end

function TreasureData:GetHaveKey(index)
	local cfg = self:GetOtherCfg()
	local item_1 = cfg.equip_use_itemid
	local item_2 = cfg.equip_10_use_itemid
	local item_3 = cfg.equip_30_use_itemid
	if index == TREASURE_TYPE.TREASURE2 then
		item_1 = cfg.equip1_use_itemid
		item_2 = cfg.equip1_10_use_itemid
		item_3 = cfg.equip1_30_use_itemid
	elseif index == TREASURE_TYPE.TREASURE3 then
		item_1 = cfg.equip2_use_itemid
		item_2 = cfg.equip2_10_use_itemid
		item_3 = cfg.equip2_30_use_itemid
	end
	local item_data = ItemData.Instance
	local my_item_1_count = item_data:GetItemNumInBagById(item_1)
	local my_item_2_count = item_data:GetItemNumInBagById(item_2)
	local my_item_3_count = item_data:GetItemNumInBagById(item_3)
	return my_item_1_count > 0 or my_item_2_count > 0 or my_item_3_count > 0
end

--获取珍稀物品配置
function TreasureData:GetXunBaoZhenXiCfg()
	return self:GetChestshopCfg().rare_show
end

--获取单个珍稀物品配置
function TreasureData:GetSingleXunBaoZhenXiCfg(id)
	local rare_show = self:GetXunBaoZhenXiCfg()
	for k,v in pairs(rare_show) do
		if v.rare_item_id == id then
			return v
		end
	end
end

function TreasureData:GetShowAllItem(xunbao_type)
	xunbao_type = xunbao_type or 1
	local list = self:GetShowItemCfg(xunbao_type)
	local list_2 = {}
	for k,v in pairs(list) do
		local data = {}
		data.item_id = v.rare_item_id
		data.is_jueban = v.is_jueban
		data.is_specil = v.is_specil
		data.index = -1
		data.param = {}
		if v.is_star == 1 then
			data.param.xianpin_type_list = {1}
		elseif v.is_star == 2 then
			data.param.xianpin_type_list = {2, 1} 
		elseif v.is_star == 3 then
			data.param.xianpin_type_list = {3, 2, 1} 			
		end
		list_2[#list_2 + 1] = data
	end
	return list_2
end

function TreasureData:GetShowCfg(xunbao_type)
	self.show_cfg = self:GetShowAllItem(xunbao_type)
	return self.show_cfg
end

function TreasureData:GetShowCfgByType(xunbao_type)
	xunbao_type = xunbao_type or self:GetChouJiangIndex()
	return self:GetShowAllItem(xunbao_type)
end

function TreasureData:GetModelCfg()
	local cfg = {}
	cfg.position = Vector3(0, -0.25, 0)
	cfg.rotation = Vector3(0, 0, 0)
	cfg.scale = Vector3(3.5, 3.5, 3.5)
	return cfg
end

-- 是否有限时兑换
function TreasureData:IsFlashChange()
	local activity_type = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RARE_CHANGE
	local time_tab = TimeUtil.Format2TableDHMS(ActivityData.Instance:GetActivityResidueTime(activity_type))
	local rareChange_time = time_tab.day * 24 * 3600 + time_tab.hour * 3600 + time_tab.min * 60 + time_tab.s
	return rareChange_time > 0
end

--抽奖的种类
function TreasureData:SetChouJiangIndex(index)
	self.choujiang_index = index or TREASURE_TYPE.TREASURE1
end

function TreasureData:GetChouJiangIndex()
	return self.choujiang_index or TREASURE_TYPE.TREASURE1
end



function TreasureData:GetXunBaoItemCfgList(conver_type, price_type, job)
	local role_vo_level = PlayerData.Instance:GetRoleVo().level
	-- if not next(self.item_id_list1) then
	--如果有珍宝兑换
	local item_id_list = {}
	if  conver_type ~= 3 then
		 item_id_list = self:GetItemIdListByJobAndType(conver_type, price_type, job)
	else
		 item_id_list = self:GetXunbaoListByJobAndType(conver_type, job)
	end
	if self:IsFlashChange() then
		local all_item_id = {}
		local rare_list = self:GetRareChangeList()
		for k,v in pairs(rare_list) do
			table.insert(all_item_id, v)
		end
		for k,v in pairs(item_id_list) do
			table.insert(all_item_id, v)
		end
		item_id_list = all_item_id
	end
	--兑换次数满，移动到最后，永久兑换的兑换完不显示，等级不够的不显示
	local all_item_id1 = {}
	local all_item_id2 = {}
	for _,v in pairs(item_id_list) do
		local item_info = ExchangeData.Instance:GetXunBaoExchangeCfg(v[1], EXCHANGE_CONVER_TYPE.XUN_BAO)
		if item_info then
			local conver_value = ExchangeData.Instance:GetConvertCount(item_info.seq, EXCHANGE_CONVER_TYPE.XUN_BAO, EXCHANGE_PRICE_TYPE.TREASURE)
			local lifetime_conver_value = ExchangeData.Instance:GetLifetimeRecordCount(item_info.seq, EXCHANGE_CONVER_TYPE.XUN_BAO, EXCHANGE_PRICE_TYPE.TREASURE)
			if item_info.lifetime_convert_count ~= 0 and lifetime_conver_value >= item_info.lifetime_convert_count then
			elseif role_vo_level < item_info.require_value or role_vo_level > item_info.require_value_max then
			elseif item_info.limit_convert_count ~= 0 and conver_value >= item_info.limit_convert_count then
				if ExchangeData.Instance:GetIsHasRestTimeByConverTypeAndSeq(item_info.conver_type, item_info.seq) then
					table.insert(all_item_id2, v)
				end
			else
				if ExchangeData.Instance:GetIsHasRestTimeByConverTypeAndSeq(item_info.conver_type, item_info.seq) then
					table.insert(all_item_id1, v)
				end
			end
		end
	end
	for _,v in pairs(all_item_id2) do
		table.insert(all_item_id1, v)
	end
	item_id_list = all_item_id1
	self.item_id_list1 = item_id_list
	-- end
	return self.item_id_list1
end

function TreasureData:GetIXunBaotemListByJobAndIndex(conver_type, price_type, job, index)
	local item_id_list = {}
	if not next(self.item_id_list) then
		item_id_list = self:GetXunBaoItemCfgList(conver_type, price_type, job)
	else
		item_id_list = self.item_id_list1
	end

	local job_id_list = {}
	if index == 1 then
		for i = 1, 4 do
			if item_id_list[i] ~= nil then
				job_id_list[#job_id_list + 1] = item_id_list[i]
			else
				job_id_list[#job_id_list + 1] = {0, 0}
			end
		end
		return job_id_list
	end
	for i = 1, 4 do
		if item_id_list[(index - 1)*4 + i] == nil then
			item_id_list[(index - 1)*4 + i] = {0, 0}
		end
		job_id_list[#job_id_list + 1] = item_id_list[(index - 1)*4 + i]
	end
	return job_id_list
end

function TreasureData:GetXunbaoItemCfgListByIndex(conver_type, price_type, job, index)
	local item_id_list = self.item_id_list1
	local role_vo_level = PlayerData.Instance:GetRoleVo().level
	--兑换次数满，移动到最后
	local all_item_id1 = {}
	local all_item_id2 = {}
	for _,v in pairs(item_id_list) do
		local item_info = ExchangeData.Instance:GetXunBaoExchangeCfg(v[1], EXCHANGE_CONVER_TYPE.XUN_BAO)
		if item_info then
			local conver_value = ExchangeData.Instance:GetConvertCount(item_info.seq, EXCHANGE_CONVER_TYPE.XUN_BAO, EXCHANGE_PRICE_TYPE.TREASURE)
			local lifetime_conver_value = ExchangeData.Instance:GetLifetimeRecordCount(item_info.seq, EXCHANGE_CONVER_TYPE.XUN_BAO, EXCHANGE_PRICE_TYPE.TREASURE)
			if role_vo_level < item_info.require_value or role_vo_level > item_info.require_value_max then
			elseif item_info.limit_convert_count ~= 0 and conver_value >= item_info.limit_convert_count or 
				item_info.lifetime_convert_count ~= 0 and lifetime_conver_value >= item_info.lifetime_convert_count then
				table.insert(all_item_id2, v)
			else
				table.insert(all_item_id1, v)
			end
		end
	end
	for _,v in pairs(all_item_id2) do
		table.insert(all_item_id1, v)
	end
	item_id_list = all_item_id1
	self.item_id_list1 = item_id_list
	return self:GetIXunBaotemListByJobAndIndex(conver_type, price_type, job, index)
end