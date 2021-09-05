ShenYinData = ShenYinData or BaseClass(BaseEvent)

ShenYinEnum = {
	SHENYIN_SYSTEM_MAX_YINJI = 10,								-- 神印印记数
}

PASTURE_SPIRIT_MAX_IMPRINT_SLOT_TYPE = {
	"YIN",
	"EARTH",
	"WIND",
	"WATER",
	"MOUNTAINS",
	"YANG",
	"SKY",
	"LIGHTNING",
	"FIRE",
	"POOL",
}

local shenyin_attr = {
	["max_hp"] = 0,								-- 血量上限
	["gong_ji"] = 0,								-- 攻击
	["fang_yu"] = 0,								-- 防御
	["ming_zhong"] = 0,							-- 命中
	["shan_bi"] = 0,								-- 闪避
	["bao_ji"] = 0,								-- 暴击
	["jian_ren"] = 0,								-- 抗暴
}

function ShenYinData:__init()
	if ShenYinData.Instance then
		print_error("[ShenYinData] Attempt to create singleton twice!")
		return
	end
	ShenYinData.Instance = self

	self.tian_xiang_cfg = ConfigManager.Instance:GetAutoConfig("tian_xiang_cfg_auto")
	self.shenyin_exchang_cfg = self.tian_xiang_cfg.imprint_exchange
	self.item_cfg = ListToMap(self.tian_xiang_cfg.item_list, "v_item_id")
	self.item_id_cfg = ListToMap(self.tian_xiang_cfg.item_list, "item_id")
	self.imprint_up_cfg = ListToMap(self.tian_xiang_cfg.imprint_up_star, "slot_ype", "stage", "level")
	self.imprint_base_attr_cfg = self.tian_xiang_cfg.imprint_base_attr
	self.suit_cfg = self.tian_xiang_cfg.suit
	self.imprint_name = self.tian_xiang_cfg.imprint_name
	self.imprint_recycle_cfg = self.tian_xiang_cfg.imprint_recycle
	self.imprint_score = 0
	self.chouhun_score = 0
	self.hunshou = self.tian_xiang_cfg.hunshou
	self.other_cfg = self.tian_xiang_cfg.other[1]
	self.imprint_extra_attr = self.tian_xiang_cfg.imprint_extra_attr
	self.xilian_add_count = self.tian_xiang_cfg.xilian_add_count
	self.liehun_pool = {}
	self.liehun_color = 0
	self.taozhuang_cfg = self.tian_xiang_cfg.new_suit

	RemindManager.Instance:Register(RemindName.ShenYin_ShenYin, BindTool.Bind(self.GetShenYinShenYinRemind, self))
	RemindManager.Instance:Register(RemindName.ShenYin_QiangHua, BindTool.Bind(self.GetShenYinQiangHuaRemind, self))
	RemindManager.Instance:Register(RemindName.ShenYin_XiLian, BindTool.Bind(self.GetShenYinXiLianRemind, self))
	RemindManager.Instance:Register(RemindName.ShenYin_TianXiang, BindTool.Bind(self.GetShenTianXiangRemind, self))
	RemindManager.Instance:Register(RemindName.ShenYin_LieHun, BindTool.Bind(self.GetShenYinLieHunRemind, self))
	RemindManager.Instance:Register(RemindName.ShenYin_Exchange, BindTool.Bind(self.GetShenYinExchangeRemind, self))

	self.attur_number = 0
	self.bead_pos = {}
	self.combine_list = {}
	self.shenyin_recycle_list = {}
	self.xilian_stuff = {}
	self.is_not_click_xilian = true
	self:InitXiLianStuff()
	self:InitShopListInfo()
end

function ShenYinData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ShenYin_ShenYin)
    RemindManager.Instance:UnRegister(RemindName.ShenYin_QiangHua)
    RemindManager.Instance:UnRegister(RemindName.ShenYin_XiLian)
    RemindManager.Instance:UnRegister(RemindName.ShenYin_TianXiang)
    RemindManager.Instance:UnRegister(RemindName.ShenYin_LieHun)
    RemindManager.Instance:UnRegister(RemindName.ShenYin_Exchange)
	ShenYinData.Instance = nil
	self.is_not_click_xilian = true
end

function ShenYinData:InitShopListInfo()
	self.shop_list_info = {}
	for i,v in ipairs(self.shenyin_exchang_cfg) do
		self.shop_list_info[i] = {}
		self.shop_list_info[i].index = v.index
		self.shop_list_info[i].buy_count = 0
		self.shop_list_info[i].timestamp = 0
	end
end

function ShenYinData:SetImprintBagInfo(protocol)
	self.mark_score_info = self.mark_score_info or {}
	self.mark_bag_info = self.mark_bag_info or {}
	self.mark_slot_info = self.mark_slot_info or {}
	if protocol.type == 0 then
	elseif protocol.type == 1 then
		self.mark_score_info.mark_grade = protocol.imprint_grade
		for k,v in pairs(protocol.grid_list) do
			local cfg = self:GetItemCFGByVItemID(v.v_item_id)
			if v.v_item_id ~= -1 and cfg ~= nil then
				self.mark_slot_info[v.param1] = v
				self.mark_slot_info[v.param1].num = v.item_num
				self.mark_slot_info[v.param1].item_id = cfg.item_id
				self.mark_slot_info[v.param1].item_type = cfg.item_type
				self.mark_slot_info[v.param1].stack_num = cfg.stack_num
				self.mark_slot_info[v.param1].quanlity = cfg.quanlity
				self.mark_slot_info[v.param1].imprint_slot = v.param1
				self.mark_slot_info[v.param1].suit_id = cfg.suit_id
				self.mark_slot_info[v.param1].is_have_mark = true
			else
				self.mark_slot_info[v.param1] = v
				self.mark_slot_info[v.param1].is_have_mark = false
				self.mark_slot_info[v.param1].imprint_slot = v.param1
			end
		end
		self:SetSuitAttr()
	end
end

function ShenYinData:SetSuitAttr()
	self.suit_attr = {}
	for k,v in pairs(self.mark_slot_info) do
		if next(v) ~= nil and v.suit_id then
			self.suit_attr[v.suit_id] = self.suit_attr[v.suit_id] or 0
			self.suit_attr[v.suit_id] = self.suit_attr[v.suit_id] + 1
		end
	end
end

function ShenYinData:GetMarkScoreInfo()
	return self.mark_score_info or {}
end

function ShenYinData:GetMarkBagInfo()
	local mark_bag_info = {}
	local bag_item_list = ItemData.Instance:GetBagItemDataList()
	if bag_item_list and next(bag_item_list) then
		local param1 = 1
		for k, v in pairs(bag_item_list) do
			if nil ~= v and v.item_id >= 23900 and v.item_id <= 23959 then
				local cfg = self:GetItemIdCFGByVItemID(v.item_id)
				if cfg ~= nil and next(cfg) then
					mark_bag_info[param1] = v
					mark_bag_info[param1].param1 = param1
					mark_bag_info[param1].num = v.num or 1
					mark_bag_info[param1].item_id = cfg.item_id
					mark_bag_info[param1].item_type = cfg.item_type
					mark_bag_info[param1].stack_num = cfg.stack_num
					mark_bag_info[param1].quanlity = cfg.quanlity
					mark_bag_info[param1].color = cfg.quanlity
					mark_bag_info[param1].imprint_slot = cfg.imprint_slot
					mark_bag_info[param1].suit_id = cfg.suit_id
					mark_bag_info[param1].is_bind = v.is_bind
					mark_bag_info[param1].bag_index = v.index
					local is_more_power = self:MingWenIsMorePower(v)
					mark_bag_info[param1].more_power = is_more_power
					local item_cfg_color = ItemData.Instance:GetItemQuailty(v.item_id)
					mark_bag_info[param1].item_cfg_color = item_cfg_color
					param1 = param1 + 1
				else
					mark_bag_info[param1] = {}
					param1 = param1 + 1
				end
			end
		end
	end
	-- table.sort(mark_bag_info, SortTools.KeyUpperSorter("item_id"))
	table.sort(mark_bag_info, SortTools.KeyUpperSorters("more_power","item_cfg_color", "imprint_slot"))
	self.mark_bag_info = mark_bag_info
	return mark_bag_info
end

function ShenYinData:MingWenIsMorePower(data)
	local power1 = CommonDataManager.GetCapability(self:GetShenYinCapabilityByData(data, true))
	local power2 = CommonDataManager.GetCapability(self:GetShenYinCapabilitySlot(data.imprint_slot))
	return power1 > power2 and 1 or 0
end

function ShenYinData:GetMarkSlotInfo()
	return self.mark_slot_info or {}
end

function ShenYinData:GetSuitAttr()
	return self.suit_attr or {}
end

function ShenYinData:GetShenYinExchangeCfg()
	return self.shenyin_exchang_cfg
end

function ShenYinData:GetImprintName()
	return self.imprint_name
end

function ShenYinData:GetHunShou()
	return self.hunshou or {}
end

function ShenYinData:GetOtherCFG()
	return self.other_cfg or {}
end

function ShenYinData:GetXilianAddCount()
	return self.xilian_add_count or {}
end

function ShenYinData:GetShenYinExchangeContainByIndex(index)
	local cfg_list = {}
	for i = 1, 4 do
		cfg_list[i] = self.shenyin_exchang_cfg[index * 4 + i]
	end
	return cfg_list
end

function ShenYinData:GetShenYinExchangeItemByIndex(index)
	for k,v in pairs(self.shenyin_exchang_cfg) do
		if v.index == index then
			return v
		end
	end
end

function ShenYinData:GetItemCFGByVItemID(v_item_id)
	return self.item_cfg[v_item_id] or {}
end

function ShenYinData:GetItemIdCFGByVItemID(item_id)
	return self.item_id_cfg[item_id] or {}
end

function ShenYinData:GetUpStarCFG(slot, grade, level)
	if self.imprint_up_cfg[slot] and self.imprint_up_cfg[slot][grade] and self.imprint_up_cfg[slot][grade][level] then
		return self.imprint_up_cfg[slot][grade][level]
	end
	return {}
end

function ShenYinData:GetItemBaseAttrCFGBySlotAndQuanlity(slot, quanlity)
	for k,v in pairs(self.imprint_base_attr_cfg) do
		if slot == v.imprint_slot and quanlity == v.quanlity then
			return v
		end
	end
end

function ShenYinData:GetItemSuitAttrBySuitId(suit_id)
	local tbl = {}
	for k,v in pairs(self.suit_cfg) do
		if suit_id == v.suit_id then
			tbl[#tbl + 1] = v
		elseif #tbl > 0 then
			return tbl
		end
	end
	return tbl
end

function ShenYinData:GetItemSuitNameBySuitId(suit_id)
	local name = ""
	for k,v in ipairs(self.suit_cfg) do
		if suit_id == v.suit_id then
			name = v.name
			return name
		end
	end
	return name
end

function ShenYinData:GetItemSuitAttrAddBySuitId(suit_id, num)
	local num = num or (self:GetSuitAttr()[suit_id] or 0)
	local tbl = CommonStruct.Attribute()
	if self:GetSuitAttr()[suit_id] then
		for k,v in pairs(self.suit_cfg) do
			if suit_id == v.suit_id and num >= v.count then
				local suit_attr = CommonDataManager.GetAttributteByClass(v)
				tbl = CommonDataManager.AddAttributeAttr(tbl, suit_attr)
			end
		end
	end
	return tbl
end

function ShenYinData:SetSpiritImprintShopInfo(protocol)
	for k,v in pairs(protocol.shop_list) do
		for i2,v2 in ipairs(self.shop_list_info) do
			if v2.index == v.index then
				self.shop_list_info[i2].index = v.index
				self.shop_list_info[i2].buy_count = v.buy_count
				self.shop_list_info[i2].timestamp = v.timestamp
			end
		end
	end
end

function ShenYinData:GetSpiritImprintShopInfo()
	return self.shop_list_info or {}
end

function ShenYinData:SetPastureSpiritImprintScoreInfo(protocol)
	self.imprint_score = protocol.score
	self.chouhun_score = protocol.chouhun_score
end

function ShenYinData:GetPastureSpiritImprintScoreInfo()
	return self.imprint_score
end

function ShenYinData:GetChouHunScoreInfo()
	return self.chouhun_score
end

function ShenYinData:GetSpiritImprintShopItemInfoByIndex(index)
	if nil == self.shop_list_info then return end
	for k,v in pairs(self.shop_list_info) do
		if v.index == index then
			return v
		end
	end
	return nil
end

function ShenYinData:GetShenYinCapabilitySlot(slot, is_total_attr)
	if nil == is_total_attr then
		is_total_attr = false
	end
	local total_attr = CommonStruct.Attribute()
	local data = self:GetMarkSlotInfo()[slot]
	if not data then
		return total_attr
	end

	-- 基础属性
	local upstar_cfg = ShenYinData.Instance:GetUpStarCFG(slot, data.grade, data.level)
	local rate = (upstar_cfg.basics_addition or 0) / 100
	local attr_list = Language.ShenYin.attr_list

	-- 基础属性
	local base_attr = ShenYinData.Instance:GetItemBaseAttrCFGBySlotAndQuanlity(data.imprint_slot, data.quanlity)
	base_attr = CommonDataManager.GetAttributteByClass(base_attr)
	total_attr = CommonDataManager.AddAttributeAttr(total_attr, base_attr)

	if not is_total_attr or (is_total_attr and data.is_have_mark) then
	    -- 强化属性
		total_attr = CommonDataManager.AddAttributeAttr(total_attr, CommonDataManager.GetAttributteByClass(upstar_cfg))
	end

	if is_total_attr then
		-- 强化基础属性百分比加成
		total_attr = CommonDataManager.AddAttributeAttr(total_attr, CommonDataManager.MulAttribute(base_attr, rate))
	end

	if not is_total_attr or (is_total_attr and data.is_have_mark) then
		-- 附加属性(洗练属性)
		local fujia_attr = {}
		local attr_key_list = CommonDataManager.GetAttrKeyList()
		for k,v in pairs(data.attr_param.value_list) do
			if v > 0 and data.attr_param.type_list[k] >= 0 then
				local key = attr_key_list[data.attr_param.type_list[k] + 1]
				fujia_attr[key] = v
			end
		end
		fujia_attr = CommonDataManager.GetAttributteByClass(fujia_attr)
		total_attr = CommonDataManager.AddAttributeAttr(total_attr, fujia_attr)
	end

	if is_total_attr then
		-- 天象基础属性加成
		local tian_xiang_rate = self:GetShenYinTianXiangPerAdd() / 10000
		total_attr = CommonDataManager.AddAttributeAttr(total_attr, CommonDataManager.MulAttribute(base_attr, tian_xiang_rate))
	end

	return total_attr
end

function ShenYinData:GetShenYinCapabilityByData(data, is_equip)
	if nil == is_equip then
		is_equip = true
	end

	local total_attr = CommonStruct.Attribute()
	if not data then
		return total_attr
	end

	local slot_data = self:GetMarkSlotInfo()[data.imprint_slot]
	if not slot_data then
		return total_attr
	end

	local upstar_cfg = ShenYinData.Instance:GetUpStarCFG(data.imprint_slot, slot_data.grade, slot_data.level)
	local rate = (upstar_cfg.basics_addition or 0) / 100
	local attr_list = Language.ShenYin.attr_list

	-- 基础属性
	local base_attr = ShenYinData.Instance:GetItemBaseAttrCFGBySlotAndQuanlity(data.imprint_slot, data.quanlity)
	base_attr = CommonDataManager.GetAttributteByClass(base_attr)
	total_attr = CommonDataManager.AddAttributeAttr(total_attr, base_attr)

	if is_equip then
		-- 强化属性
		total_attr = CommonDataManager.AddAttributeAttr(total_attr, CommonDataManager.GetAttributteByClass(upstar_cfg))

		-- 强化基础属性百分比加成
		-- total_attr = CommonDataManager.AddAttributeAttr(total_attr, CommonDataManager.MulAttribute(base_attr, rate))

		-- 附加属性(洗练属性)
		local fujia_attr = {}
		local attr_key_list = CommonDataManager.GetAttrKeyList()
		for k,v in pairs(slot_data.attr_param.value_list) do
			if v > 0 and slot_data.attr_param.type_list[k] >= 0 then
				local key = attr_key_list[slot_data.attr_param.type_list[k] + 1]
				fujia_attr[key] = v
			end
		end

		fujia_attr = CommonDataManager.GetAttributteByClass(fujia_attr)
		total_attr = CommonDataManager.AddAttributeAttr(total_attr, fujia_attr)
	end
	return total_attr
end

function ShenYinData:GetItemNumInBagById(item_id, bind_type)
	if item_id == nil then return end
	local num = 0
	for k,v in pairs(self:GetMarkBagInfo()) do
		if	v.item_id == item_id then
			if bind_type == nil then
				num = num + v.num
			elseif bind_type == v.is_bind then
				num = num + v.num
			end
		end
	end
	return num
end

function ShenYinData:GetShenYinSuitAttrCapability()
	local suit_info = self:GetSuitAttr()
	local total_attr = CommonStruct.Attribute()
	for k,v in pairs(suit_info) do
		local suit_attr = self:GetItemSuitAttrAddBySuitId(k, v)
		total_attr = CommonDataManager.AddAttributeAttr(total_attr, suit_attr)
	end
	return total_attr
end

function ShenYinData:GetShenYinTotalAttr()
	local total_attr_list = CommonStruct.Attribute()
	-- local mark_slot_info = self:GetMarkSlotInfo()
	for i = 1, ShenYinEnum.SHENYIN_SYSTEM_MAX_YINJI do
		-- local slot_info = mark_slot_info[i - 1] or {}
		local attr_list = ShenYinData.Instance:GetShenYinCapabilitySlot(i - 1, true)
		total_attr_list = CommonDataManager.AddAttributeAttr(total_attr_list, attr_list)
	end
	total_attr_list = CommonDataManager.AddAttributeAttr(total_attr_list, self:GetShenYinSuitAttrCapability())
	for k, v in pairs(shenyin_attr) do
		shenyin_attr[k] = total_attr_list[k]
	end
	return shenyin_attr
end

function ShenYinData:GetShenYinShenRecycle(quanlity, is_suit)
	for i,v in pairs(self.imprint_recycle_cfg) do
		if v.quanlity == quanlity then
			return v.add_imprint_score
		end
	end
	return 0
end

function ShenYinData:GetShenYinRecycle(item_id)
	if self.item_id_cfg and self.item_id_cfg[item_id] then
		return self.item_id_cfg[item_id].return_item_num or 0
	end
	return 0
end

function ShenYinData:GetShenYinShenYinRemind()
	local goal_info =  self:GetGoalInfo()
	if goal_info ~= nil and goal_info.active_flag ~= nil and goal_info.fetch_flag ~= nil then
		if (goal_info.active_flag[0] == 1 and goal_info.fetch_flag[0] == 0) or (goal_info.fetch_flag[0] == 1 and goal_info.active_flag[1] == 1 and goal_info.fetch_flag[1] == 0) then
			return 1
		end
	end

	local grid_list = self:GetMarkBagInfo()
	local up_flag = false
	for k,v in pairs(grid_list) do
		local power1 = CommonDataManager.GetCapability(ShenYinData.Instance:GetShenYinCapabilityByData(v, true))
		local power2 = CommonDataManager.GetCapability(ShenYinData.Instance:GetShenYinCapabilitySlot(v.imprint_slot))
		up_flag = power1 > power2 and nil ~= next(v) and v.item_type == 1
		if up_flag then
	return 1
		end
	end

	return 0
end

function ShenYinData:InitXiLianStuff()
	local other_cfg = self:GetOtherCFG()
	self.xilian_stuff[other_cfg.flush_attr_type_need_v_item_id] = 1
	self.xilian_stuff[other_cfg.flush_attr_value_need_v_item_id] = 1
	self.xilian_stuff[other_cfg.add_attr_type_need_v_item_id] = 1
end

function ShenYinData:GetShenYinQiangHuaRemind()
	local item_info = self:GetMarkSlotInfo()
	for k,v in pairs(item_info) do
		local item_data = item_info[v.imprint_slot]
		if item_data and item_data.is_have_mark then
			local up_star_cfg = self:GetUpStarCFG(v.imprint_slot, item_data.grade, item_data.level)
			if ItemData.Instance:GetItemNumInBagById(up_star_cfg.consume_v_item_id) >= up_star_cfg.need_num then
				if up_star_cfg.need_num ~= 0 then 
					return 1
				end
			end
		end
	end
	return 0
end

function ShenYinData:GetShenYinXiLianRemind()
	for i = 0, ShenYinEnum.SHENYIN_SYSTEM_MAX_YINJI - 1 do
		local num = self:GetHasShenYinXiLianRedPointBySlot(i)
		if 1 == num then
			return 1
		end 
	end

	return 0
end

function ShenYinData:GetHasShenYinXiLianRedPointBySlot(slot)
	local other_cfg = self:GetOtherCFG()
	local add_attr_type_need_v_item_id = other_cfg.add_attr_type_need_v_item_id
	local add_attr_cfg = ShenYinData.Instance:GetXilianAddCount()
	local has_enough_add_attr_type_item = false

	local flush_attr_type_need_v_item_id = other_cfg.flush_attr_type_need_v_item_id
	local flush_attr_value_need_v_item_id = other_cfg.flush_attr_value_need_v_item_id

	local attur_number = 0
	local slot_info = self:GetMarkSlotInfo()[slot]
	if slot_info and slot_info.is_have_mark then
		local item_num = ItemData.Instance:GetItemNumInBagById(add_attr_type_need_v_item_id)
		for k,v in pairs(slot_info.attr_param.value_list) do
			if v > 0 then
				attur_number = attur_number + 1
			end
		end
		has_enough_add_attr_type_item = nil ~= add_attr_cfg[attur_number + 1] and (item_num >= add_attr_cfg[attur_number + 1].consume_num and true or false) or false
		if has_enough_add_attr_type_item then
			return 1
		end

		if not has_enough_add_attr_type_item then
			item_num = ItemData.Instance:GetItemNumInBagById(flush_attr_type_need_v_item_id)
			if item_num >= other_cfg.flush_attr_type_need_v_item_num and attur_number > 0 and self.is_not_click_xilian then
				return 1
			end

			item_num = ItemData.Instance:GetItemNumInBagById(flush_attr_value_need_v_item_id)
			if item_num >= other_cfg.flush_attr_value_need_v_item_num and attur_number > 0 and self.is_not_click_xilian then
				return 1
			end
		end
	end

	return 0	
end

function ShenYinData:GetShenTianXiangRemind()
	return 0
end

function ShenYinData:GetShenYinLieHunRemind()
	local liehun_color = ShenYinData.Instance:GetLieHunColor()
	local cfg = ShenYinData.Instance:GetChouHunCfg()
	local chouhun_score_info = ShenYinData.Instance:GetChouHunScoreInfo()
	for k, v in pairs(cfg) do
		if v.chouhun_color == liehun_color and chouhun_score_info >= v.cost_hun_li then
			return 1
		end
	end
	return 0
end

function ShenYinData:GetShenYinExchangeRemind()
	return 0
end

function ShenYinData:SetXiLianRedPoint(value)
	self.is_not_click_xilian = value
end

function ShenYinData:GetXiLianRedPoint()
	return self.is_not_click_xilian
end

function ShenYinData:GetIsShenYinRecycleItem(item_id)
	local item_cfg = self:GetItemIdCFGByVItemID(item_id)
	if item_cfg.recovery and 1 == item_cfg.recovery then
		return true
	else
		return false
	end
end

function ShenYinData:GetIsShenYinItem(item_id)
	local item_cfg = self:GetItemIdCFGByVItemID(item_id)
	if item_cfg.suit_id and 0 ~= item_cfg.suit_id then
		return item_cfg.suit_id
	end
end		

function ShenYinData:GetXiLianMaxValueByAttrType(attr_type)
	local max_value = 0
	for k,v in pairs(self.imprint_extra_attr or {}) do
		if v.attr_type == attr_type then
			max_value = v.max_value > max_value and v.max_value or max_value
		end
	end
	return max_value
end

function ShenYinData:GetTianXiangCombineAttrCfg()
	if not self.tianxiang_combine_attr_cfg then
		self.tianxiang_combine_attr_cfg = ConfigManager.Instance:GetAutoConfig("tian_xiang_cfg_auto").combine_attr
	end
	return self.tianxiang_combine_attr_cfg
end

function ShenYinData:GetTianXiangCombineCfg()
	if not self.tianxiang_combine_cfg then
		self.tianxiang_combine_cfg = ConfigManager.Instance:GetAutoConfig("tian_xiang_cfg_auto").combine
	end
	return self.tianxiang_combine_cfg
end

function ShenYinData:GetBead(t)
    for _, v in pairs(self:GetBeadCfg()) do
        if v.type == t then
            return v
        end
    end
end

function ShenYinData:SetCombineList(list)
    self.combine_list = list
end

function ShenYinData:GetCombineList()
    return self.combine_list
end

function ShenYinData:SetBeadList(data)
	for k,v in pairs(data) do
		if self.bead_pos[v.y + 1] == nil then
			self.bead_pos[v.y + 1] = {}
		end
		self.bead_pos[v.y + 1][v.x + 1] = v.type
	end
end

function ShenYinData:GetBeadList()
    return self.bead_pos
end

function ShenYinData:GetHaveBollNum()
	local num = 0
	for k_1,v_1 in pairs(self.bead_pos) do
		for k_2,v_2 in pairs(v_1) do
			if v_2 > 0 then
				num = num + 1
			end
		end
	end
	return num
end

function ShenYinData:GetLevelLimitCfg()
	if not self.level_limit_cfg then
		self.level_limit_cfg = ConfigManager.Instance:GetAutoConfig("tian_xiang_cfg_auto").level_limit_cfg
	end
	return self.level_limit_cfg
end

function ShenYinData:GetBeadCfg()
	if not self.bead then
		self.bead = ConfigManager.Instance:GetAutoConfig("tian_xiang_cfg_auto").bead
	end
	return self.bead
end

function ShenYinData:GetTianxianInfoByPos(y, x)
	if self.bead_pos[y] == nil then return 0 end
	return self.bead_pos[y][x] or 0
end

function ShenYinData:GetOtherTianxianBoll(boll_type)
	local other_cfg = {}
	local bead_cfg = self:GetBeadCfg()
	for i = 1, #bead_cfg do
		if bead_cfg[i].type ~= boll_type then
			table.insert(other_cfg, bead_cfg[i])
		end
	end
	return other_cfg
end

function ShenYinData:GetTianxianBollCfg(boll_type)
	local bead_cfg = self:GetBeadCfg()
	for i = 1, #bead_cfg do
		if bead_cfg[i].type == boll_type then
			return bead_cfg[i]
		end
	end
end

function ShenYinData:GetSeasonsCfg(seq)
    if seq >= GameEnum.SEASONS_MIN and seq <= GameEnum.SEASONS_MAX then
        return self:FindCombineCfg(seq)
    end
end

function ShenYinData:GetTianXiangCfg(seq)
    if seq > GameEnum.SEASONS_MAX or seq < GameEnum.SEASONS_MIN then
        return self:FindCombineCfg(seq)
    end
end

function ShenYinData:FindCombineCfg(seq)
    if not seq then
        return
    end
    for _, v in pairs(self:GetTianXiangCombineAttrCfg()) do
        if v.seq == seq then
            return v
        end
    end
end

function ShenYinData:GetAllBollGroupByBollType(boll_type)
	local cfg = self:GetTianXiangCombineCfg()[boll_type] or {}
	local temp_list = {}
	for i = 0, GameEnum.BOLL_GROUP_MAX_NUM do
		if cfg["type_" .. i] and cfg["type_" .. i] > 0 then
			if temp_list[cfg["type_" .. i]] == nil then
				temp_list[cfg["type_" .. i]] = 1
			else
				temp_list[cfg["type_" .. i]] = temp_list[cfg["type_" .. i]] + 1
			end
		end
	end
	return temp_list
end

function ShenYinData:GetShenYinRecycleList()
	return self.shenyin_recycle_list
end

function ShenYinData:ReSetShenYinRecycleList()
	self.shenyin_recycle_list = {}
end

function ShenYinData:SetShenYinJingHuaRecycleList()
	local bag_list = self:GetMarkBagInfo()
	for k,v in pairs(bag_list) do
		if v.quanlity and v.quanlity >= 6 then
			self:AddShenYinRecycleList(v)
		end
	end
end

function ShenYinData:AddShenYinRecycleList(data)
	if not self:GetHasShenYinRecycle(data.param1) then
		table.insert(self.shenyin_recycle_list, data)
	end
end

function ShenYinData:RemoveShenYinRecycleList(index)
	for i,v in ipairs(self.shenyin_recycle_list) do
		if v.param1 == index then
			table.remove(self.shenyin_recycle_list, i)
			return
		end
	end
end

function ShenYinData:GetHasShenYinRecycle(index)
	if not index then
		return false
	end
	for i,v in ipairs(self.shenyin_recycle_list) do
		if v.param1 == index then
			return true
		end
	end
	return false
end

function ShenYinData:GetShenYinRecycleScore()
	local score = 0
	for i,v in ipairs(self.shenyin_recycle_list) do
		if v and v.quanlity ~= nil then
			score = score + self:GetShenYinShenRecycle(v.quanlity, v.suit_id ~= 0 and 1 or 0) * v.num
		end
	end
	return score
end

function ShenYinData:GetShenYinXiLianStuffCfg()
	local other_cfg = self:GetOtherCFG()
	local item_list = {other_cfg.flush_attr_type_need_v_item_id,
		other_cfg.flush_attr_value_need_v_item_id,
		other_cfg.add_attr_type_need_v_item_id}
	local need_num_list = {other_cfg.flush_attr_type_need_v_item_num,
		other_cfg.flush_attr_value_need_v_item_num,
		1}
	return item_list, need_num_list
end

function ShenYinData:GetChouHunCfg()
	return self.tian_xiang_cfg.chouhun or {}
end

function ShenYinData:SetLieHunPoolInfo(protocol)
	self.liehun_color = protocol.liehun_color
	self.liehun_pool = protocol.liehun_pool
end

function ShenYinData:GetLieHunPoolInfo()
	return self.liehun_pool
end

function ShenYinData:GetLieHunColor()
	return self.liehun_color
end

function ShenYinData:GetHunShouVItemIdByIndex(index)
	local cfg = self:GetHunShou()
	for i,v in ipairs(cfg) do
		if v.index == index then
			return v.virtual_item_id
		end
	end
end

function ShenYinData:GetTianXiangGroupCfg()
	if not self.combine_attr_add then
		self.combine_attr_add = ConfigManager.Instance:GetAutoConfig("tian_xiang_cfg_auto").combine_attr_add
	end
	return self.combine_attr_add
end

function ShenYinData:GetTianXiangNameBySeq(seq)
	for k,v in pairs(self:GetTianXiangCombineAttrCfg()) do
		if seq == v.seq then
			return v.name
		end
	end
end

function ShenYinData:CountAtt()
    local count = {}

    for _, row in pairs(self:GetBeadList()) do
        for __, col in pairs(row) do
        	if col and col > 0 then
        		table.insert(count, col)
        	end
        end
    end
    local total = CommonStruct.Attribute()
    for _, v in pairs(count) do
        local cfg = self:GetBead(v)
        total = self:AddAtt(total, cfg)
    end
    return total
end

function ShenYinData:AddAtt(total, cfg)
    local att = CommonDataManager.GetAttributteByClass(cfg)
    return CommonDataManager.AddAttributeAttr(total, att)
end

function ShenYinData:CountSeasonsAndTianXiang()
    local combine_list = self:GetCombineList()
    local count_seasons = {}
    local count_tianxiang = {}
    for _, v in pairs(combine_list or {}) do
        local sea_v = self:GetSeasonsCfg(v.seq)
        if sea_v then
            table.insert(count_seasons, sea_v)
        end

        local tx_v = self:GetTianXiangCfg(v.seq)
        if tx_v then
            table.insert(count_tianxiang, tx_v)
        end
    end

    local seasons_total = CommonStruct.Attribute()
    for _, v in pairs(count_seasons) do
        seasons_total = self:AddAtt(seasons_total, v)
    end

    local tianxiang_total = CommonStruct.Attribute()
    for _, v in pairs(count_tianxiang) do
        tianxiang_total = self:AddAtt(tianxiang_total, v)
    end

    return seasons_total, tianxiang_total, #count_seasons, #count_tianxiang
end

function ShenYinData:GetTianXiangActiveCfg(seq)
	for k,v in pairs(self.combine_list) do
		if seq == v.seq then
			return v
		end
	end
end

function ShenYinData:GetTianXiangAllActiveCfg(seq)
	local temp_cfg = {}
	for k,v in pairs(self.combine_list) do
		if seq == v.seq then
			temp_cfg = v
			break
		end
	end
	if next(temp_cfg) == nil then return end
	local temp_pos_cfg = {}
	for k,v in pairs(self:GetTianXiangCombineCfg()) do
		if temp_cfg.seq == v.seq then
			temp_pos_cfg = v
			break
		end
	end
	local pos_cfg = {}
	for i = 1, 15 do
		if temp_pos_cfg["type_"..(i-1)] > 0 then
			pos_cfg[i] = {}
			pos_cfg[i].x = temp_pos_cfg["x_"..(i-1)] + temp_cfg.x
			pos_cfg[i].y = temp_pos_cfg["y_"..(i-1)] + temp_cfg.y
		end
	end
	return pos_cfg
end

function ShenYinData:GetWearShenYinList()
	local slot_info = {}
	local data = self:GetMarkSlotInfo()
	local num = 0
	for k,v in pairs(data) do
		if -1 ~= v.v_item_id then
			slot_info[num] = v
			num = num + 1
		end
	end
	return slot_info, num
end

function ShenYinData:GetShenYinTianXiangPerAdd()
	local group_cfg = self:GetTianXiangGroupCfg()
	local add_per = 0
	for k, v in ipairs(group_cfg) do
		if ShenYinData.Instance:GetTianXiangActiveCfg(v.combine_seq_1) and ShenYinData.Instance:GetTianXiangActiveCfg(v.combine_seq_2) then
			add_per = add_per + v.attr_add -- 万分比
		end
	end
	return add_per
end

function ShenYinData:GetShenYinQiangHuaMax()
	return self.tian_xiang_cfg.imprint_up_star[#self.tian_xiang_cfg.imprint_up_star]
end

function ShenYinData:GetAllGroupActiveNum()
	local cfg = self:GetTianXiangGroupCfg()
	local is_active_1 = false
	local is_active_2 = false
	local attr_sum = 0
	for i = 1, #cfg do
		is_active_1 = false
		is_active_2 = false
		for k,v in pairs(self.combine_list) do
			if v.seq == cfg[i].combine_seq_1 then
				is_active_1 = true
			end
			if v.seq == cfg[i].combine_seq_2 then
				is_active_2 = true
			end
		end
		if is_active_1 and is_active_2 then
			attr_sum = attr_sum + cfg[i].attr_add / 100
		end
	end
	return attr_sum
end

function ShenYinData:GetShenYinLevelBySeq(seq)
	for k,v in pairs(self:GetMarkSlotInfo()) do
		if v.imprint_slot == seq then
			return v.grade, v.level
		end
	end
end

function ShenYinData:GetShenYinBySlot(slot)
	local need_list = {}
	for k,v in pairs(self:GetMarkBagInfo()) do
		if v.imprint_slot and v.imprint_slot == slot and v.item_type == 1 then 
			table.insert(need_list , v)
		end
	end
	function Sort(a, b)
		local value_a = 0
		local value_b = 0
		if a.quanlity > b.quanlity then 
			value_b = value_b + 10
		else
			value_a = value_a + 10
		end
		return value_a < value_b
	end
	table.sort(need_list , Sort)
	return need_list
end

function ShenYinData:GetShenYinBagCapabilityBySlot(slot , slot_have_yinji )
	local slot_data = self.mark_slot_info[slot]
	local bag_list = self:GetMarkBagInfo()
	--local slot_attr = ShenYinData.Instance:GetShenYinCapabilitySlot(slot)
	local slot_base_attr = ShenYinData.Instance:GetItemBaseAttrCFGBySlotAndQuanlity(slot_data.imprint_slot, slot_data.quanlity)
	slot_base_attr =  CommonDataManager.GetAttributteByClass(slot_base_attr)
	local slot_power =  CommonDataManager.GetCapability(slot_base_attr)

	for k,v in pairs(bag_list) do
		if v.item_type == 1 and nil ~= v.imprint_slot and v.imprint_slot == slot then 
			if not slot_have_yinji then 
				return true
			end
			--local total_attr = CommonStruct.Attribute()
			if not slot_data then
				return true
			end
			--local upstar_cfg = ShenYinData.Instance:GetUpStarCFG(slot, slot_data.grade, slot_data.level)
			-- 基础属性
			local base_attr = ShenYinData.Instance:GetItemBaseAttrCFGBySlotAndQuanlity(v.imprint_slot, v.quanlity)
			base_attr = CommonDataManager.GetAttributteByClass(base_attr)
			local v_power = CommonDataManager.GetCapability(base_attr)
			if v_power > slot_power then 
				return true
			end
		end	
	end
	return false
end
function ShenYinData:GetLockConsume()
	if nil ~= self.other_cfg then 
		return self.other_cfg.lock_consume
	else
		return 0
	end
end

function ShenYinData:SetGoalInfo(protocol)
	self.goal_info = {}
	self.goal_info.open_system_timestamp = protocol.open_system_timestamp
	self.goal_info.active_flag = protocol.active_flag
	self.goal_info.fetch_flag = protocol.fetch_flag
	self.goal_info.active_special_attr_flag = protocol.active_special_attr_flag
end

function ShenYinData:GetGoalInfo()
	return self.goal_info
end

function ShenYinData:GetSuitSingleNameBySuitID(suit_id)
	if suit_id == nil then
		return ""
	end
	for k,v in pairs(self.suit_cfg) do
		if v.suit_id == suit_id then
			return v.name or ""
		end
	end
	return ""
end

-- 获取神印套装总量
function ShenYinData:GetSuitTotalNum()
	if self.suit_cfg == nil then
		return 0
	end

	local num = 0
	local suit_id = -1
	for i,v in ipairs(self.suit_cfg) do
		if v.suit_id ~= suit_id then
			num = num + 1
			suit_id = v.suit_id
		end
	end
	return num
end

-- 获取神印套装数据
function ShenYinData:GetSuitCfgBySuitId(suit_id)
	local suit_info = self:GetSuitAttr()
	if self.suit_cfg == nil or suit_info == nil then
		return {}
	end
	local single_suit_cfg = {}
	for k1,v1 in pairs(self.suit_cfg) do
		for k2,v2 in pairs(self.suit_cfg) do
			if k1 ~= k2 and k1 > k2 and v1.suit_id == v2.suit_id then
				local data = {}
				data.has_suit_num = suit_info[v1.suit_id] or 0
				data.seq = v1.suit_id
				data.info1 = v1
				data.info2 = v2
				table.insert(single_suit_cfg, data)
			end
		end
	end
	
	table.sort(single_suit_cfg, SortTools.KeyUpperSorters("has_suit_num", "seq"))
	return single_suit_cfg
end

-- 根据物品id获取套装id
function ShenYinData:GetSuitIdByItemId(item_id)
	if self.item_id_cfg == nil or item_id == nil then
		return 0
	end

	return self.item_id_cfg[item_id].suit_id or 0
end

function ShenYinData:GetTaoZhuangCfg()
	return self.taozhuang_cfg
end

function ShenYinData:GetTaoZhuangIndexCfg(index)
	local data = {}
	if nil ~= self.taozhuang_cfg then
		for k,v in pairs(self.taozhuang_cfg) do
			if k  == index + 1 then
				return v
			end
		end
	end
end

function ShenYinData:GetTaoZhuangNUM(quality,need_count)
	local data_list = self:GetMarkSlotInfo()
	local count_num = 0
	for  k,v in pairs(data_list) do
		if  -1 ~= v.v_item_id then
			if v.quanlity == quality then 
				count_num = count_num  + 1
			end
		end
	end
	if count_num > need_count then
		return count_num , true
	else
		return count_num , false
	end

end

function ShenYinData:GetTaoZhuangAttr()
	local cfg = self:GetTaoZhuangCfg()
	local shenyin_info = self:GetMarkSlotInfo()
	local color_list = {} 	--3代表橙色, 4红色和粉色
	for k, v in pairs(shenyin_info) do
		if -1 ~= v.v_item_id then
			local color_index = (v.quanlity == 5) and (v.quanlity - 1) or v.quanlity
			color_list[color_index] = color_list[color_index] or 0
			color_list[color_index] = color_list[color_index] + 1
		end
	end
	local attribute = CommonStruct.AttributeNoUnderline()
	if not cfg or not shenyin_info then 
		return attribute
	end
	
	for k, v in pairs(cfg) do
		if v.quality == 3 then
			if color_list[3] and color_list[3] >= v.need_count then
				local temp_attribute = CommonDataManager.GetAttributteNoUnderline(v)
				local per_attribute = CommonDataManager.GetRolePercentAttrNoUnderline(v)
				attribute = CommonDataManager.AddAttributeAttrNoUnderLine(attribute, temp_attribute)
				attribute = CommonDataManager.AddAttributeAttrNoUnderLine(attribute, per_attribute)
			end
		else
			if color_list[4] and color_list[4] >= v.need_count then
				local temp_attribute = CommonDataManager.GetAttributteNoUnderline(v)
				local per_attribute = CommonDataManager.GetRolePercentAttrNoUnderline(v)
				attribute = CommonDataManager.AddAttributeAttrNoUnderLine(attribute, temp_attribute)
				attribute = CommonDataManager.AddAttributeAttrNoUnderLine(attribute, per_attribute)
			end
		end
	end

	return attribute
end

-- 获取铭文总属性
function ShenYinData:GetAllAttr()
	local mark_slot_info = self:GetMarkSlotInfo()
	local total_attr_list = CommonStruct.Attribute()
	local capability = 0 
	for i = 1, ShenYinEnum.SHENYIN_SYSTEM_MAX_YINJI do
		local slot_info = mark_slot_info[i - 1] or {}
		local attr_list =  ShenYinData.Instance:GetShenYinCapabilitySlot(i - 1, true)
		total_attr_list = CommonDataManager.AddAttributeAttr(total_attr_list, attr_list)
	end
	return total_attr_list
end