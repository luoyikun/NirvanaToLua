ForgeData = ForgeData or BaseClass()

FORGE_TYPE =
{
	STRENGTH = 0,
	GEM = 1,
	SHENZHU = 2,
	SHENGXING = 3,
	TAOZHUANG = 4,
	COMPOSE = 5,
	BASEEQUIP = 6,
}

ForgeData.FORGE_FLY_IMMED_EQUIP = 
{
	["WUQI"] = 1100,
	["KAIJIA"] = 1101,
	["HUSHOU"] = 1102,
	["YAODAI"] = 1103,
	--["HUTUI"] = 1104,
	["TOUKUI"] = 1104,
	["XIANGLIAN"] = 1105,
	["SHOUZHUO"] = 1106,
	["JIEZHI"] = 1107,
	["XIEZI"] = 1108,
	["YUPEI"] = 1109,
}

ForgeData.FORGE_FLY_ID = 
{
	[0] = "WUQI",
	[1] = "KAIJIA",
	[2] = "HUSHOU",
	[3] = "YAODAI",
	[4] = "TOUKUI",
	[5] = "XIANGLIAN",
	[6] = "SHOUZHUO",
	[7] = "JIEZHI",
	[8] = "XIEZI",
	[9] = "YUPEI",
}

ForgeData.FORGE_FLY_GUILD_STATE = 
{
	UNCHECKED_NOT_HAVE = 1,
	UNCHECKED_HAVE = 2,
	CHECKED_HAVE = 3,
}

ForgeData.BASEEQUIPTAG = 
{
	LEVEL = 1,
	QUALITY = -1,
}

function ForgeData:__init()
	if ForgeData.Instance ~= nil then
		print_error("[ForgeData] attempt to create singleton twice!")
		return
	end
	self.true_org = 0
	self.org = 0
	self.total_level = 0
	self.gem_info = {}
	self.suit_info = {}
	self.feixian_info = {}
	self.cells_num = {}
	self.feixian_equip_cfg = {}
	self.feixian_equip_low_cfg = {}
	self.notify_data_change_callback_list = {}
	self.baizhan_notify_data_change_callback_list = {}
	self.notify_data_count_change_callback_list = {}
	self.use_lucky_item_num = 0
	self.eternity_equip_max_level_list = {}
	self.zhuanzhi_equip = {}
	self.baizhan_equip = {}
	self.baizhan_part_order_list = {}
	self.baizhan_order_count_list = {}
	self.power_flush_enable = false
	self.baizhan_power_flush_enable = false
	ForgeData.Instance = self
	self.forge_deity_suit = {}
	self.is_inlay_success = false

	-------普通装备--------
	self.equipforge_auto_cfg = ConfigManager.Instance:GetAutoConfig("equipforge_auto")
	self.equipment_auto_cfg = ConfigManager.Instance:GetAutoItemConfig("equipment_auto")
	self.markettype_auto_cfg = ConfigManager.Instance:GetAutoConfig("markettype_auto")
	self.feixianequip_auto_cfg = ConfigManager.Instance:GetAutoConfig("feixianequip_auto")
	-- 进阶
	self.advance_cfg = ListToMap(self.equipforge_auto_cfg.uplevel, "old_equip_id")
	self.advance_index_cfg = ListToMapList(self.equipforge_auto_cfg.uplevel, "equip_index")
	-- 强化
	self.strength_cfg = ListToMap(self.equipforge_auto_cfg.strength_base, "equip_index", "strength_level")
	self.strength_grade_cfg = ListToMapList(self.equipforge_auto_cfg.strength_base, "equip_index", "need_order")
	-- 宝石
	self.stone_cfg = ListToMap(self.equipforge_auto_cfg.stone, "item_id")
	self.gem_open_limit_cfg = ListToMapList(self.equipforge_auto_cfg.stone_open_limit, "equip_index")
	self.stone_type_level_cfg = ListToMap(self.equipforge_auto_cfg.stone, "stone_type", "level")
	-- 品质
	self.up_quality = ListToMap(self.equipforge_auto_cfg.up_quality, "equip_index","quality")
	self.up_quality_index = ListToMapList(self.equipforge_auto_cfg.up_quality, "equip_index")
	-- 套装（永恒）
	self.eternity_equip_cfg = ListToMap(self.equipforge_auto_cfg.eternity_equip, "equip_index", "eternity_level")
	self.eternity_equip_index = ListToMapList(self.equipforge_auto_cfg.eternity_equip, "equip_index")
	self.eternity_suit_cfg = ListToMap(self.equipforge_auto_cfg.eternity_suit, "suit_level")
	-- 神铸
	self.shen_op_cfg = ListToMap(self.equipforge_auto_cfg.shen_op, "equip_index", "shen_level")

	-------转职装(神装)--------
	self.zhuanzhieuqip_auto_cfg = ConfigManager.Instance:GetAutoConfig("zhuanzhiequipcfg_auto")
	self.zhuanzhieuqip_condition_attr = ListToMap(self.zhuanzhieuqip_auto_cfg.condition_attr, "part_index", "order")
	self.equip_baptize_cfg = ConfigManager.Instance:GetAutoConfig("equip_baptize_cfg_auto")
	self.zhuanzhieuqip_info_cfg = ListToMap(self.zhuanzhieuqip_auto_cfg.zhuanzhi_equip_info, "equip_part", "equip_order")
	self.xianpin_cfg = ListToMap(self.equipforge_auto_cfg.xianpin, "xianpin_type")
	-- 升星
	self.up_star_cfg = ListToMap(self.zhuanzhieuqip_auto_cfg.up_star, "equip_index", "star_level")
	self.up_star_index = ListToMapList(self.zhuanzhieuqip_auto_cfg.up_star, "equip_index")
	-- 玉石
	self.jade_cfg = ListToMap(self.zhuanzhieuqip_auto_cfg.stone, "item_id")
	self.jade_open_limit_cfg = ListToMapList(self.zhuanzhieuqip_auto_cfg.stone_slot_cfg, "part_index")
	self.jade_stone_type_level_cfg = ListToMap(self.zhuanzhieuqip_auto_cfg.stone, "stone_type", "level")
	self.jade_up_level_cfg = ListToMap(self.zhuanzhieuqip_auto_cfg.stone_level_up, "old_stone_item_id")
	-- 玉石精炼
	self.jade_refine_cfg = ListToMap(self.zhuanzhieuqip_auto_cfg.stone_refine, "refine_level")
	self.jade_refine_material_cfg = ListToMapList(self.zhuanzhieuqip_auto_cfg.stone_refine_stuff, "part_index")
	-- 洗练/附灵
	self.baptize_attr_cfg = ListToMap(self.equip_baptize_cfg.baptize_attr, "special_type", "seq")
	self.baptize_suit_cfg = ListToMapList(self.equip_baptize_cfg.baptize_suit, "equip_part")
	--套装
	self.suit_type_cfg = ListToMap(self.zhuanzhieuqip_auto_cfg.suit_part_active, "role_prof", "equip_part", "suit_index", "equip_order")
	self.suit_attr_fang_cfg = ListToMapList(self.zhuanzhieuqip_auto_cfg.suit_attr_fang, "role_prof", "suit_index", "equip_order")
	self.suit_attr_gong_cfg = ListToMapList(self.zhuanzhieuqip_auto_cfg.suit_attr_gong, "suit_index")

	--百战套装
	self.baizhanequip_auto_cfg = ConfigManager.Instance:GetAutoConfig("baizhanequipcfg_auto")
	self.baizhanequip_suit_attr_cfg = ListToMap(self.baizhanequip_auto_cfg.suit_attr, "equip_order", "same_order_num")
	self.baizhanequip_suit_name_cfg = ListToMap(self.baizhanequip_auto_cfg.suit_name, "order")
	self.baizhanequip_level_up_old_cfg = ListToMap(self.baizhanequip_auto_cfg.equip_level_up, "new_equip_item_id")
	self.baizhanequip_level_up_part_cfg = ListToMap(self.baizhanequip_auto_cfg.equip_level_up, "part", "old_equip_item_id")
	self.baizhan_suit_info = self.baizhanequip_auto_cfg.baizhan_equip_info
	self.baizhan_suit = {}
	if self.baizhanequip_suit_name_cfg ~= nil then 											--策划说百战套转预览按阶数从大到小
		for i = #self.baizhanequip_suit_name_cfg, 1, -1 do
			table.insert(self.baizhan_suit, self.baizhanequip_suit_name_cfg[i])
		end
	end

	--至尊套装
	self.extreme_suit_cfg = ListToMapList(self.zhuanzhieuqip_auto_cfg.zhizun_compose_cfg, "limit_prof")
	self.zhizun_equipment_cfg = ListToMap(self.zhuanzhieuqip_auto_cfg.zhizun_cfg, "equip_id")
	self.zhizun_attr_cfg = ListToMap(self.zhuanzhieuqip_auto_cfg.suit_attr_zhizun, "equip_order")
	self.special_equip_id_cfg = ListToMap(self.zhuanzhieuqip_auto_cfg.special_equip_cfg, "equip_id")

	self.jue_xing_attr_cfg = ListToMap(self.zhuanzhieuqip_auto_cfg.wake_attribute, "type", "level")

	-- 装备合成
	self.equip_exchange_cfg = ListToMap(self.zhuanzhieuqip_auto_cfg.equip_exchange, "limit_prof", "compose_equip_best_attr_num", "order")
	self.zhuanzhi_equip_compose_cfg = ListToMap(self.zhuanzhieuqip_auto_cfg.zhuanzhi_equip_compose, "compose_equip_id", "compose_equip_best_attr_num")
	self.exchange_equip_index_list = {}



	self.feixianEquip = ListToMap(self.markettype_auto_cfg.market_child,"child_name","father_id")
	self.feixian_xianpin_type = ListToMap(self.equipforge_auto_cfg.xianpin,"xianpin_type")
	self.total_upstar_cfg = self.equipforge_auto_cfg.total_upstar
	self.all_shen_op_cfg = self.equipforge_auto_cfg.all_shen_op

	local forge_suit_cfg = ConfigManager.Instance:GetAutoConfig("duanzaosuit_auto")
	self.suit_uplevel_cfg = ListToMap(forge_suit_cfg.suit_uplevel, "equip_id")
	self.suit_attr_ss_list_cfg = ListToMap(forge_suit_cfg.suit_attr_ss, "suit_id", "equip_count")
	self.suit_attr_cq_list_cfg = ListToMap(forge_suit_cfg.suit_attr_cq, "suit_id", "equip_count")

	self.xianpin_fix = self.equipforge_auto_cfg.xianpin_fix		-- 固定仙品属性
	self.xianpin_show = self.equipforge_auto_cfg.xianpin_show	-- 仙品属性展示
	

	self.equipment_compose_cfg = ListToMap(self.equipforge_auto_cfg.equiment_compound_cfg, "item_id", "xianpin_count")

	self.equipment_slot_cfg = self.equipforge_auto_cfg.equiment_compound_slot or {}
	self.equiment_zhuang_sheng_cfg = ConfigManager.Instance:GetAutoConfig("zhuansheng_cfg_auto").rand_attr_val
	self.equiment_zs_equip_show_cfg = ConfigManager.Instance:GetAutoConfig("zhuansheng_cfg_auto").equip_show


	self.cur_item_data = nil
	self.cur_open_view = 1
	self.max_eternity_suit_count = 0

	self.last_flush_time = 0

	for k,v in pairs(self.equipment_auto_cfg) do
		local value = v
		if v.sub_type >= 1100 and v.sub_type <= 1109 and v.color == 5 and v.order == 2 then
			if nil == self.feixian_equip_cfg[v.limit_prof] then 
				self.feixian_equip_cfg[v.limit_prof] = {}
			end
		    self.feixian_equip_cfg[v.limit_prof][v.sub_type] = {}
		    self.feixian_equip_cfg[v.limit_prof][v.sub_type] = v
		end
		if v.sub_type >= 1100 and v.sub_type <= 1109 and v.color == 1 and v.order == 1 then
			if nil == self.feixian_equip_low_cfg[v.limit_prof] then 
				self.feixian_equip_low_cfg[v.limit_prof] = {}
			end
		    self.feixian_equip_low_cfg[v.limit_prof][v.sub_type] = {}
		    self.feixian_equip_low_cfg[v.limit_prof][v.sub_type] = v
		end
	end

	-------觉醒装备----------
	self.zhuanzhi_all_equip_awakening_list = {}
	self.zhuanzhi_equip_awakening_list = {}
	----------------------------------------------
	RemindManager.Instance:Register(RemindName.ForgeAdvance, BindTool.Bind(self.GetForgeAdvanceRemind, self))
	RemindManager.Instance:Register(RemindName.ForgeStrengthen, BindTool.Bind(self.GetForgeStrenthenRemind, self))
	RemindManager.Instance:Register(RemindName.ForgeBaoshi, BindTool.Bind(self.GetForgeGemRemind, self))
	RemindManager.Instance:Register(RemindName.ForgeQuality, BindTool.Bind(self.GetForgeQualityRemind, self))
	RemindManager.Instance:Register(RemindName.ForgeYongheng, BindTool.Bind(self.GetForgeYonghengRemind, self))
	RemindManager.Instance:Register(RemindName.ForgeCast, BindTool.Bind(self.GetForgeCastRemind, self))

	RemindManager.Instance:Register(RemindName.ForgeUpStar, BindTool.Bind(self.GetForgeUpStarRemind, self))
	RemindManager.Instance:Register(RemindName.ForgeJade, BindTool.Bind(self.GetForgeJadeRemind, self))
	RemindManager.Instance:Register(RemindName.ForgeJadeRefine, BindTool.Bind(self.GetForgeJadeRefineRemind, self))
	RemindManager.Instance:Register(RemindName.ForgeDeityIntersify, BindTool.Bind(self.GetForgeDeityIntersifyRemind, self))
	RemindManager.Instance:Register(RemindName.ForgeDeitySuit, BindTool.Bind(self.GetForgeDeitySuitRemind, self))
	RemindManager.Instance:Register(RemindName.ForgeJueXing, BindTool.Bind(self.GetForgeJueXingRemind, self))
end

function ForgeData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ForgeAdvance)
	RemindManager.Instance:UnRegister(RemindName.ForgeStrengthen)
	RemindManager.Instance:UnRegister(RemindName.ForgeBaoshi)
	RemindManager.Instance:UnRegister(RemindName.ForgeQuality)
	RemindManager.Instance:UnRegister(RemindName.ForgeYongheng)
	RemindManager.Instance:UnRegister(RemindName.ForgeCast)

	RemindManager.Instance:UnRegister(RemindName.ForgeUpStar)
	RemindManager.Instance:UnRegister(RemindName.ForgeJade)
	RemindManager.Instance:UnRegister(RemindName.ForgeJadeRefine)
	RemindManager.Instance:UnRegister(RemindName.ForgeDeityIntersify)
	RemindManager.Instance:UnRegister(RemindName.ForgeDeitySuit)
	RemindManager.Instance:UnRegister(RemindName.ForgeJueXing)
	ForgeData.Instance = nil

	self.notify_data_change_callback_list = nil
	self.baizhan_notify_data_change_callback_list = nil
	self.notify_data_count_change_callback_list = nil
	self.strength_stone_num = nil
	self.fuling_stone_num = nil
	self.exchange_equip_index_list = {}
end


--传装备的id进来,获取基础装等级的配表
-- function ForgeData:GetBaseEquipLevelData(equip_id)
-- 	local cfg = self.up_level[equip_id]
-- 	return cfg and cfg or nil
-- end

function ForgeData:GetEquipmentCfg()
	return self.equipment_auto_cfg
end

function ForgeData:GetFeixianEquipList(prof)
	return self.feixian_equip_cfg[prof], self.cells_num
end

function ForgeData:GetFeixianRedEquipConsume()
	local table = self.feixianequip_auto_cfg
	return table
end

function ForgeData:GetFeixianEquipCount(really)
	-- local cell_count = 0	
	return 10
end
-- 检查背包中3星飞仙装
function ForgeData:CheckFeixianInPackage(index,item_type,really)
	local itemdata_list = ItemData.Instance:GetBagItemDataList()
	 -- 系列检索
	 for k,v in pairs(itemdata_list) do

	 	local item_cfg = self.equipment_auto_cfg[v.item_id]
	 	if nil ~= item_cfg and nil ~= v.param then 
	 		if item_cfg.sub_type == ForgeData.FORGE_FLY_IMMED_EQUIP[item_type] and v.param.xianpin_star_num == 3 and v.param.really == really and item_cfg.color == 4 then 
	 			if nil ~= self.cells_num[index].cell[v.item_id] then 
	 				self.cells_num[index].cell[v.item_id].num = self.cells_num[index].cell[v.item_id].num + 1
	 				self.cells_num[index].cell[v.item_id].cell[self.cells_num[index].cell[v.item_id].num] = v
	 				self.cells_num[index].cell[v.item_id].cell[self.cells_num[index].cell[v.item_id].num].item_fei_immed_type = 0
	 			else
	 				self.cells_num[index].cell[v.item_id] = {}
	 				self.cells_num[index].cell[v.item_id].num = 1
	 				self.cells_num[index].cell[v.item_id].cell = {}
	 				self.cells_num[index].cell[v.item_id].cell[self.cells_num[index].cell[v.item_id].num] = v
					self.cells_num[index].cell[v.item_id].cell[self.cells_num[index].cell[v.item_id].num].item_fei_immed_type = 0
	 			
	 			end
	 		end
	 	end
	 end
end

function ForgeData:GetEternitySuitIndex(suit_level)
	if nil == suit_level then return 0 end

	if nil == self.eternity_suit_cfg[suit_level] then
		return 0
	end
	return self.eternity_suit_cfg[suit_level].suit_index
end	

function ForgeData:GetFeixianRedComsumeCount(item_id)
	local num = 0
	local itemdata_list = ItemData.Instance:GetBagItemDataList()
	for k,v in pairs(itemdata_list) do
		if v.item_id == item_id then 
			num = num + v.num
		end
	end
	return num or 0
end
function ForgeData:GetCurItemData()
	return self.cur_item_data
end

function ForgeData:GetNameEffectByData(data)
	local cfg = self:GetShenOpSingleCfg(data.index, data.param.shen_level)
	return cfg and cfg.effect or 0
end

--强化 获取受阶数限制后的强化等级
function ForgeData:GetGradeStrengthLevel(equip_index, grid_level)
	-- print(ToColorStr("获取受阶数限制后的强化等级  "..equip_index.." "..grid_level, TEXT_COLOR.PURPLE))
	local equip = EquipData.Instance:GetDataList()[equip_index]
	if equip ~= nil and equip.item_id ~= nil and equip.item_id ~= 0 then
		-- print("有装备")
		local cfg = ItemData.Instance:GetItemConfig(equip.item_id)
		-- print(equip.item_id)
		if nil == cfg then return 0 end
		local max_level = self:GetMaxStrengthLevelByGrade(equip_index, cfg.order)
		-- print(max_level)
		if max_level and grid_level > max_level then
			return max_level
		else
			return grid_level
		end
	end
end

function ForgeData:SetLevelUpLuckyItemUseNum(num)
	self.use_lucky_item_num = num
end

--获取使用的幸运符的个数,方便传在提示框中点击使用的个数
function ForgeData:GetLevelUpLuckyItemUseNum()
	return self.use_lucky_item_num and self.use_lucky_item_num or 0
end

--当达到最大成功率的时候,不能继续添加该物品
function ForgeData:IsMaxSucceedRate(equip_id,num)
	local up_level_cfg = self:GetBaseEquipLevelData(equip_id)
	--先拿到基础成功值
	local succeed_rate = up_level_cfg.base_succ_rate
	local add_succeed_rate = up_level_cfg.lucky_add_rate * num
	succeed_rate = succeed_rate + add_succeed_rate
	return succeed_rate >= 100  	
end

--锻造等级 根据装备列表里面的id获取和锻造等级列表配对的装备
function ForgeData:GetLevelUpBaseEquip(equip_list_data)
	local equip_sort_list = {}
	--拿到有的装备,根据配表筛选
	for k,v in pairs(equip_list_data) do
		if self:GetBaseEquipLevelData(v.item_id) then
			table.insert(equip_sort_list,v)
		end
	end
	return equip_sort_list 	
end

--强化 根据编号获取全身强化配置
function ForgeData:GetTotalStrengthNameByLevel(seq)
	local total_strength_cfg = self.equipforge_auto_cfg.strength_minlevel_reward
	for k,v in pairs(total_strength_cfg) do
		if v.seq == seq then
			return v.name
		end
	end
end

function ForgeData:GetGemTotalLevel()
	return self.gem_total_level or 0
end

function ForgeData:GetBagGemlistByGemInfo(gem_info)
	local bag_all_list = {}
	local bag_all_temp_list = {}
	local has_type_list = {}
	local all_type_list = {}
	for i = 0, 5 do
		table.insert(all_type_list, i)
	end
	if next(gem_info) then
		for k, v in pairs(gem_info) do
			if v.gem_state == 2 then
				local cfg = self:GetGemCfg(v.gem_id)
				if nil ~= cfg then
					table.insert(has_type_list, cfg.stone_type)
				end
			end

		end
	end
	if nil ~= next(has_type_list) then
		for i=#all_type_list,1,-1 do
			for k, v in pairs(has_type_list) do
				if all_type_list[i] and all_type_list[i] == v then
					table.remove(all_type_list, i)
				end
			end
		end
	end
	for k, v in pairs(all_type_list) do
		table.insert(bag_all_temp_list, self:GetGemsInBag(v))
	end
	for k, v in pairs(bag_all_temp_list) do
		if next(v) then
			for k1, v1 in pairs(v) do
				table.insert(bag_all_list, v1)
			end
		end
	end
	if next(bag_all_list) then
		table.sort(bag_all_list, SortTools.KeyLowerSorter("item_id"))
	end
	return bag_all_list
end

--宝石 根据编号获取全身宝石配置
function ForgeData:GetTotalGemCfgByLevel(level)

	local total_gem_cfg = self.equipforge_auto_cfg.stone_ex_add
	for k,v in pairs(total_gem_cfg) do
		if v.stone_level == level then
			return v.name
		end
	end
end

--宝石 设置总宝石战斗力
function ForgeData:SetTotalGemPower()
	local total_power = 0
	for k,v in pairs(self.gem_info) do
		total_power = self:GetEquipGemPower(v) + total_power
	end
	self.gem_power = total_power
	local total_gem_cfg = self.equipforge_auto_cfg.stone_ex_add
end

--宝石 得到总宝石战斗力
function ForgeData:GetTotalGemPower()
	return self.gem_power + self:GetGemSuitPower()
end

--宝石 获取宝石套装战力
function ForgeData:GetGemSuitPower()
	local suit_power = 0
	local suit_id = self:GetGemSuitId()
	if suit_id >= 0 then
		local total_gem_cfg = self.equipforge_auto_cfg.stone_ex_add
		suit_power = CommonDataManager.GetCapabilityCalculation( total_gem_cfg[suit_id] )
	end
	return suit_power
end

--宝石 获取套装id
function ForgeData:GetGemSuitId()
	local suit_id = -1
	local total_gem_cfg = self.equipforge_auto_cfg.stone_ex_add

	--获取全部宝石的总等级
	local total_level = 0
	for k,v in pairs(self.gem_info) do
		for k1,v1 in pairs(v) do
			if v1.stone_id ~= 0 then
				local gem_cfg = self:GetGemCfg(v1.stone_id)
				total_level = total_level + gem_cfg.level
			end
		end
	end

	--获取总等级对应的套装id
	for i = 1 , #total_gem_cfg do
		-- print_error("######获取总等级对应的套装id####",total_level,#total_gem_cfg,total_gem_cfg)
		--等级最高处理
		if total_level >= total_gem_cfg[#total_gem_cfg].total_level then
			suit_id = total_gem_cfg[#total_gem_cfg].seq
			return suit_id
		end
		--等级未达到最高处理
		if total_level >= total_gem_cfg[i].total_level and total_level <= total_gem_cfg[i + 1].total_level then
			suit_id = total_gem_cfg[i].seq
		end
	end
	return suit_id
end

--强化 获取强化套装战力
function ForgeData:GetStrengthSuitPower()
	local suit_power = 0
	local suit_id = self:GetStrengthSuitId()
	if suit_id >= 0 then
		local total_strength_cfg = self.equipforge_auto_cfg.strength_minlevel_reward
		suit_power = CommonDataManager.GetCapabilityCalculation(total_strength_cfg[suit_id + 1] )
	end
	return suit_power
end

--强化获取套装id
function ForgeData:GetStrengthSuitId()
	local suit_id = -1
	local total_strength_cfg = self.equipforge_auto_cfg.strength_minlevel_reward

	--获取全部强化的总等级
	local total_level = 0
	local equiplist = EquipData.Instance:GetDataList()
	for k,v in pairs(equiplist) do
		if v.param.strengthen_level ~= 0 then
			total_level = total_level + v.param.strengthen_level
		end
	end

	--获取总等级对应的套装id
	for i = 1 , #total_strength_cfg do
		--等级最高处理
		if total_level >= total_strength_cfg[#total_strength_cfg].total_strength_level then
			suit_id = total_strength_cfg[#total_strength_cfg].seq
			return suit_id
		end
		--等级未达到最高处理
		if total_level >= total_strength_cfg[i].total_strength_level and total_level <= total_strength_cfg[i + 1].total_strength_level then
			suit_id = total_strength_cfg[i].seq
		end
	end
	return suit_id
end

--神铸 获取神铸套装战力
function ForgeData:GetCastSuitPower()
	local suit_power = 0
	local the_level = self:GetCastSuitId()
	local attr = {}
	if the_level >= 0 then
		local total_cast_cfg = self.equipforge_auto_cfg.all_shen_op
		for k,v in pairs(total_cast_cfg) do
			if v.shen_level == the_level then
				attr = v
			end
		end
		suit_power = CommonDataManager.GetCapabilityCalculation(attr)
	end
	return suit_power
end

--神铸获取套装id
function ForgeData:GetCastSuitId()
	local the_level = -1
	local total_cast_cfg = self.equipforge_auto_cfg.all_shen_op

	--获取全部强化的总等级
	local total_level = 0
	local equiplist = EquipData.Instance:GetDataList()
	for k,v in pairs(equiplist) do
		if v.param.shen_level ~= 0 then
			total_level = total_level + v.param.shen_level
		end
	end
	--获取总等级对应的套装id
	for i = 1 , #total_cast_cfg do
		--等级最高处理
		if total_level >= total_cast_cfg[#total_cast_cfg].shen_level then
			the_level = total_cast_cfg[#total_cast_cfg].shen_level
			return the_level
		end
		--等级未达到最高处理
		if total_level >= total_cast_cfg[i].shen_level and total_level <= total_cast_cfg[i + 1].shen_level then
			the_level = total_cast_cfg[i].shen_level
		end
	end
	return the_level
end

--升星 获取升星套装战力
function ForgeData:GetUpStarSuitPower()
	local suit_power = 0
	local suit_id = self:GetUpStarSuitId()
	if suit_id >= 0 then
		local total_up_star_cfg = self.equipforge_auto_cfg.total_upstar
		suit_power = CommonDataManager.GetCapabilityCalculation(total_up_star_cfg[suit_id + 1] )
	end
	return suit_power
end

--升星获取套装id
function ForgeData:GetUpStarSuitId()
	local suit_id = -1
	local total_up_star_cfg = self.equipforge_auto_cfg.total_upstar

	--获取全部强化的总等级
	local total_level = 0
	local equiplist = EquipData.Instance:GetDataList()
	for k,v in pairs(equiplist) do
		if v.param.shen_level ~= 0 then
			total_level = total_level + v.param.star_level
		end
	end

	--获取总等级对应的套装id
	for i = 1 , #total_up_star_cfg do
		--等级最高处理
		if total_level >= total_up_star_cfg[#total_up_star_cfg].total_star then
			suit_id = total_up_star_cfg[#total_up_star_cfg].seq
			return suit_id
		end
		--等级未达到最高处理
		if total_level >= total_up_star_cfg[i].total_star and total_level <= total_up_star_cfg[i + 1].total_star then
			suit_id = total_up_star_cfg[i].seq
		end
	end
	return suit_id
end

--神铸 获取神铸Cfg
function ForgeData:GetCastCfg(data,is_next)
	if not data or data.item_id == nil or data.item_id == 0 then
		return
	end
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
	local cur_index = data.index
	if equip_index < 0 then
		return nil
	end
	if equip_index ~= data.index then
		cur_index = equip_index
	end
	if is_next then
		cast = data.param.shen_level + 1
	else
		cast = data.param.shen_level
	end

	return self:GetShenOpSingleCfg(cur_index, cast)
end

--神铸 获取装备神铸前缀
function ForgeData:GetQualityFormat(data)
	if data == nil then
		return ""
	end
	--神铸名字
	local cast_prefix = ""
	local cast_cfg = self:GetCastCfg(data)
	if cast_cfg ~= nil then
		cast_prefix = cast_cfg.name
	end
	return cast_prefix
end

--获取神铸等级
function ForgeData:GetQualityNameIndex(data)
	if data == nil then
		return ""
	end
	local shen_level = data.param.shen_level
	if nil == shen_level or shen_level > 10 then
		return 10
	end
	return shen_level
end

function ForgeData:GetCanUpStarByLevelAndIndex(index, level)
	if level >= 500 then return false end
	local mojing = ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.MOJING)
	local need_star_mojing = self:GetUpStarSingleCfg(index, level + 1)
	return mojing >= need_star_mojing.need_shengwang
end

--公用 是否能强化/升品/神铸/宝石提升 0可以 1到达顶级 2不够材料
function ForgeData:CheckIsCanImprove(data, param_type)
	local next_cfg = nil

	if param_type == TabIndex.forge_strengthen then
		return self:CheckStrengthIsCanImprove(data)
	elseif param_type == TabIndex.forge_cast then
		next_cfg = ForgeData.Instance:GetCastCfg(data,true)
	elseif param_type == TabIndex.forge_baoshi then
		local can_improve, improve_type = self:GetEquipGemCanImprove(data)
		return can_improve, improve_type
	elseif param_type == TabIndex.forge_up_star then
		local param = data.param or {}
		local mojing = ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.MOJING)
		if mojing > 0 and param.star_level and param.star_level < 500 then
			local need_star_mojing = self:GetUpStarSingleCfg(data.index, param.star_level + 1)
			if mojing > need_star_mojing.need_shengwang then
				return 0
			else
				return 2
			end
		else
			return 2
		end
	elseif param_type == TabIndex.forge_yongheng then
		-- return self:CaculateEternityRemind()
	end
	--是否满级
	if next_cfg == nil then
		return 1
	end
	--材料
	local item_id = next_cfg["stuff_id"]
	local item_count = next_cfg["stuff_count"]
	local had_item_num = ItemData.Instance:GetItemNumInBagById(item_id)
	if had_item_num < item_count then
		return 2, item_id, (item_count - had_item_num)
	end
	return 0
end

--公用 获取可提升的装备
function ForgeData:GetCanImproveEquip(param_type)
	local equip_data = EquipData.Instance:GetDataList()
	for k,v in pairs(equip_data) do
		if v.item_id ~= nil then
			if self:CheckIsCanImprove(v, param_type) == 0 then
				return v
			end
		end
	end
end
--公用 获取装备的所有加成
function ForgeData:GetForgeAddition(data)
	if not data then return end
	--强化加成
	local strength_cfg = self:GetStrengthCfg(data.index, data.param.strengthen_level)
	--神铸加成
	local cast_cfg = self:GetCastCfg(data)

	--获取角色等级
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local ro_level = vo.level
	--物品基础属性
	local equip_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	local base_result = CommonDataManager.GetAttributteNoUnderline(equip_cfg)
	--基础装不能去掉基础属性
	local base_equip_attr = CommonDataManager.GetAttributteNoUnderline(equip_cfg)
	---------去掉基础属性---------
	for k,v in pairs(base_result) do
		base_result[k] = 0
	end
	---------去掉基础属性--------
	local strength_result = {}
	local cast_result = {}
	for k, v in pairs(base_result) do
		--强化
		local strengthen_addition = 0
		if strength_cfg ~= nil then
			local key = (k == "maxhp") and "max_hp" or k
			strengthen_addition = strength_cfg[key] or 0
		end
		strength_result[k] = strengthen_addition
		--神铸
		local cast_addition_fix = 0
		local cast_addition_per = 0
		if cast_cfg ~= nil then
			cast_addition_fix = cast_cfg[k] or 0
			cast_addition_per = math.floor(cast_cfg.attr_percent * 0.01 * v)
		end
		cast_result[k] = cast_addition_fix + cast_addition_per
	end
	cast_result.shen_level = data.param.shen_level
	cast_result.item_id = data.item_id
	return base_result, strength_result, cast_result,base_equip_attr
end

--公用 获取装备中文属性和战斗力s,is_next为装备升品的时候
function ForgeData:GetEquipAttrAndPower(data, cur_open_view,is_quality_attr)
	cur_open_view = cur_open_view or self.cur_open_view
	local base_result, strength_result, cast_result,base_equip_attr = self:GetForgeAddition(data)
	if strength_result == nil and cast_result == nil then
		return nil, 0
	end

	--装备加成默认值
	local attr_percent = 1
	if data.param.quality > 0 and is_quality_attr then
		local percent = self:GetBaseEquipAttrPercent(data.index,data.param.quality)
		attr_percent = attr_percent + percent/10000
	end

	local total_attr = {}
	local power_attr = {}
	for k,v in pairs(base_result) do
		local value = 0
		if cur_open_view == 1 then
			value = strength_result[k]
		-- elseif self.cur_open_view == 2 then
		elseif cur_open_view == 3 then
			value = cast_result[k]
		elseif cur_open_view == FORGE_TYPE.BASEEQUIP then
		--基础装
			value = base_equip_attr[k] * attr_percent
			value = math.floor(value)
		end
		total_attr[CommonDataManager.GetAttrName(k)] = value
		power_attr[k] = value
	end
	local power = CommonDataManager.GetCapabilityCalculation(power_attr)
	return total_attr, power
end

--获得基础装配表的百分比加成
function ForgeData:GetBaseEquipAttrPercent(equip_index,equip_quality)
	local quality_list = self:GetForgeQualityCfg(equip_index,equip_quality)
	return quality_list.attr_percent and quality_list.attr_percent or 0
end

--设置升星红点
function ForgeData:SetUpStarRedPoint()

end

function ForgeData:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

--获取升星套装属性
function ForgeData:GetTotleStarBySeq(seq)
	local taozhuang_name = ""
	for k, v in ipairs(self.total_upstar_cfg) do
		if v.seq == seq then
			taozhuang_name = v.name
			break
		end
	end
	return taozhuang_name
end

function ForgeData:GetEquipZhanLi()
	local equiplist = EquipData.Instance:GetDataList()
	local capability = 0
	for k,v in pairs(equiplist) do
		capability = capability + EquipData.Instance:GetEquipLegendFightPowerByData(v,true, false)
	end
	local strength_power = self:GetStrengthPower()
	local baoshi_power = self:GetTotalGemPower()
	local cast_power = self:GetShenZhuPower()
	local up_star_power = self:GetUpStarPower()
	local suit_power = self:GetSuitPower()
	capability = capability + strength_power + baoshi_power + cast_power + up_star_power + suit_power
	return capability
end

--强化战力
function ForgeData:GetStrengthPower()
	local equiplist = EquipData.Instance:GetDataList()
	local capability = 0
	for k,v in pairs(equiplist) do
		local _, power = self:GetEquipAttrAndPower(v, 1)
		capability = capability + power
	end
	capability = capability + self:GetStrengthSuitPower()
	return capability
end

--神铸战力
function ForgeData:GetShenZhuPower()
	local equiplist = EquipData.Instance:GetDataList()
	local capability = 0
	for k,v in pairs(equiplist) do
		local _, power = self:GetEquipAttrAndPower(v, 3)
		capability = capability + power
	end
	capability = capability + self:GetCastSuitPower()
	return capability
end

--升星战力
function ForgeData:GetUpStarPower()
	local equiplist = EquipData.Instance:GetDataList()
	local capability = 0
	for k,v in pairs(equiplist) do
		local attr_info = self:GetUpStarSingleCfg(v.index, v.param.star_level)
		if attr_info then
			capability = capability + CommonDataManager.GetCapability(attr_info)
		end
	end
	capability = capability + self:GetUpStarSuitPower()
	return capability
end

--套装战力
function ForgeData:GetSuitPower()
	local capability = 0
	local temp_equip_list_data = self:ReorderEquipList() or {}
	local suit_list = {}
	for k,v in pairs(temp_equip_list_data) do
		local suit_uplevel_cfg = self:GetSuitUpLevelCfgByItemId(v.item_id) or {}
		local suit_id = suit_uplevel_cfg.suit_id or 0
		local suit_type = self:GetCurEquipSuitType(k - 1)
		if suit_id ~= 0 and suit_type ~= 0 then
			suit_list[suit_id] = suit_list[suit_id] or {}
			if suit_type == 2 then
				suit_type = -1
			end
			suit_list[suit_id][suit_type] = suit_list[suit_id][suit_type] and suit_list[suit_id][suit_type] + 1 or 1
		end
	end
	for k1,v1 in pairs(suit_list) do
		for k2,v2 in pairs(v1) do
			local suit_data_cfg = self:GetSuitAttCfg(k1, v2, k2) or {}
			local add_capability = CommonDataManager.GetCapability(suit_data_cfg) or 0
			capability = capability + add_capability
		end
	end
	return capability
end

-------------套装-------------
--套装信息
function ForgeData:SetForgeSuitInfo(protocol)
	self.suit_info = protocol.suit_level_list or {}
	RemindManager.Instance:Fire(RemindName.KaiFu)
end

--获取当前装备的套装类型
function ForgeData:GetCurEquipSuitType(index)
	if not next(self.suit_info) or nil == index then
		return 0
	end
	if not self.suit_info[index] then
		return 0
	 end
	return self.suit_info[index].suit_type
end
-- 设置飞仙装数据
function ForgeData:SetFeixianInfo(protocol)
	self.feixian_info = protocol.equipment_list
	-- RemindManager.Instance:Fire(RemindName.ForgeFeixianEquip)
	-- RemindManager.Instance:Fire(RemindName.ForgeFeixianEquipRed)
	-- RemindManager.Instance:Fire(RemindName.ForgeFeixianEquipOrange)
	-- if nil ~= self.notify_data_change_callback_list then 
	-- 	for k,v in pairs(self.notify_data_change_callback_list) do
	-- 		v()
	-- 	end
	-- end
end

function ForgeData:SetFeixianNeed(really)
	RemindManager.Instance:Fire(RemindName.ForgeFeixianEquip)
	RemindManager.Instance:Fire(RemindName.ForgeFeixianEquipRed)
	RemindManager.Instance:Fire(RemindName.ForgeFeixianEquipOrange)
	self.cells_num = {}
	local equip_on_role = self:GetFeixianInfo()

	for i = 0, 9 do
		self.cells_num[i] = {}
		self.cells_num[i].cell = {}
		self.cells_num[i].ison = false
		self.cells_num[i].red_ison = false
		self.cells_num[i].really_sort = i
		if nil ~= equip_on_role[i] then
			if nil ~= equip_on_role[i].item_id then 
				local item_cfg = self.equipment_auto_cfg[equip_on_role[i].item_id]
				if nil ~= item_cfg then 
					if 0 ~= equip_on_role[i].item_id and equip_on_role[i].param.xianpin_star_num == 3 and v.param.really == really and item_cfg.color == 4 then 
						self.cells_num[i].cell[equip_on_role[i].item_id] = {} 
						self.cells_num[i].cell[equip_on_role[i].item_id].num = 1
						self.cells_num[i].cell[equip_on_role[i].item_id].cell = {}
						self.cells_num[i].cell[equip_on_role[i].item_id].cell[self.cells_num[i].cell[equip_on_role[i].item_id].num] = equip_on_role[i]
						self.cells_num[i].cell[equip_on_role[i].item_id].cell[self.cells_num[i].cell[equip_on_role[i].item_id].num].item_fei_immed_type = 1
					end
				end	
			end			
		end

		self:CheckFeixianInPackage(i,ForgeData.FORGE_FLY_ID[i],really)

		for kz,vz in pairs(self.cells_num[i].cell) do
			if vz.num >= 1 then 
				self.cells_num[i].red_ison = true
			end
			if vz.num >= 2 then 
				self.cells_num[i].ison = true
			end
			-- cell_count = cell_count + 1
		end
	end
	if really == 0 then
		local cells_num_count = 0
		for j=0,9 do
			if self.cells_num[j].ison == true then 
				local cells_empty_box = self.cells_num[cells_num_count]
				self.cells_num[cells_num_count] = self.cells_num[j]
				self.cells_num[j] = cells_empty_box
				cells_num_count = cells_num_count + 1
			end
		end
	elseif really == 1 then
		local cells_num_count = 0
		for j=0,9 do
			if self.cells_num[j].red_ison == true then 
				local cells_empty_box = self.cells_num[cells_num_count]
				self.cells_num[cells_num_count] = self.cells_num[j]
				self.cells_num[j] = cells_empty_box
				cells_num_count = cells_num_count + 1
			end
		end
	end
end
-- 获得飞仙装数据
function ForgeData:GetFeixianInfo()
	return self.feixian_info
end

--获取装备的升级cfg
function ForgeData:GetSuitUpLevelCfgByItemId(item_id)
	return self.suit_uplevel_cfg[item_id]
end

function ForgeData:GetSuitIdByItemId(item_id)
	local cfg = self:GetSuitUpLevelCfgByItemId(item_id)
	return cfg and cfg.suit_id, 0
end

--获取装备的套装名
function ForgeData:GetSuitName(suit_id, suit_type)
	local list = nil
	if suit_type == 1 then
		list = self.suit_attr_ss_list_cfg[suit_id]

	elseif suit_type == -1 then
		list = self.suit_attr_cq_list_cfg[suit_id]
	end

	if nil == list then
		return ""
	end

	local _, cfg = next(list)
	local prof = PlayerData.Instance:GetRoleBaseProf()
	return cfg and cfg["suit_name_" .. prof] or ""
end

--套装石是否足够
function ForgeData:GetItemNumIsEnough(cur_num, need_num)
	if tonumber(cur_num) >= tonumber(need_num) then
		return true
	else
		return false
	end
end

--suit_type:当前界面（1:史诗，-1:传说）equip_data:装备列表
function ForgeData:GetChangeSuitBtnRedPointStatus(equip_data,suit_type)
	for k,v in pairs(equip_data) do
		local strength_data_cfg = ForgeData.Instance:GetSuitUpLevelCfgByItemId(v.item_id)
		if nil ~= strength_data_cfg then
			local cur_num_1, cur_num_2 = ForgeData.Instance:GetCurSuitRockNum(v.item_id, suit_type)
			local rock1_is_enough = ForgeData.Instance:GetItemNumIsEnough(cur_num_1, strength_data_cfg.need_stuff_count_ss)
			local rock2_is_enough = ForgeData.Instance:GetItemNumIsEnough(cur_num_2, strength_data_cfg.need_stuff_count_cq2)
			local red_point_status = ForgeData.Instance:SetRedPointStatus(rock1_is_enough, rock2_is_enough, v.data_index or v.index, suit_type)
			if red_point_status then
				return true
			end
		end
	end
	return false
end

--装备列表重排序
function ForgeData:ReorderEquipList()
	-- 头盔 衣服 护腿 鞋子 武器 腰带  护手 项链 戒指 戒指
	local sort_type_list = {100, 101, 102, 103, 106, 108, 104, 105, 107, 109, 110}
	local equip_type_dic = {}
	for k,v in pairs(sort_type_list) do
		equip_type_dic[v] = k
	end

	local temp_equip_list = {}
	local equip_list_data = EquipData.Instance:GetDataList()
	for k,v in pairs(equip_list_data) do
		if nil ~= v.item_id then
			local t = {}
			local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
			t.sort = equip_type_dic[item_cfg.sub_type]
			t.data = v
			-- local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
			-- if item_cfg.sub_type ~= 106 then --排除武器
				table.insert(temp_equip_list, t)
			-- end
		end
	end

	table.sort(temp_equip_list, SortTools.KeyLowerSorter("sort"))

	local sort_list = {}
	for k,v in pairs(temp_equip_list) do
		sort_list[k] = v.data
	end
	return sort_list
end

function ForgeData:CheckIsSuitRock(item_id)
	if item_id >= 27678 and item_id <= 27687 then
		return true
	end
	return false
end

function ForgeData:GetEquipXianpinAttr(equip_id, gift_item_id)
	local type_list = {}
	local max_xianpin_num = 3
	local is_random = false

	if gift_item_id then
		for k, v in pairs(self.xianpin_fix) do
			if v.equip_id == equip_id and v.param_1 == gift_item_id then
				for i = 1, max_xianpin_num do
					if v["xianpin_type_"..i] > 0 then
						table.insert(type_list, v["xianpin_type_"..i])
					end
				end
				return type_list
			end
		end
		is_random = true
	else
		local item_cfg = ItemData.Instance:GetItemConfig(equip_id)
		if item_cfg then
			local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
			for k, v in pairs(self.xianpin_show) do
				if v.equip_index == equip_index and v.equip_color == item_cfg.color then
					for i = 1, max_xianpin_num do
						if v["xianpin_type_"..i] > 0 then
							table.insert(type_list, v["xianpin_type_"..i])
						end
					end
					return type_list
				end
			end
		end
	end

	if gift_item_id and is_random then
		local item_cfg = ItemData.Instance:GetItemConfig(equip_id)
		if item_cfg then
			local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
			for k, v in pairs(self.xianpin_show) do
				if v.equip_index == equip_index and v.equip_color == item_cfg.color then
					for i = 1, max_xianpin_num do
						if v["xianpin_type_"..i] > 0 then
							table.insert(type_list, v["xianpin_type_"..i])
						end
					end
					return type_list
				end
			end
		end
	end

	return type_list
end

function ForgeData:GetEquipIsNotRandomGift(equip_id, gift_item_id)
	if not equip_id or not gift_item_id then return false end

	for k, v in pairs(self.xianpin_fix) do
		if v.equip_id == equip_id and v.param_1 == gift_item_id then
			return true
		end
	end

	return false
end

function ForgeData:GetEquipXianPinFixInfo(gift_item_id)
	if not gift_item_id then return end

	for k, v in pairs(self.xianpin_fix) do
		if v.param_1 == gift_item_id then
			return v
		end
	end

	return
end

function ForgeData:GetTypeListByIndex(index)
	local equip_list = {}
	for k,v in pairs(self.equipment_compose_cfg) do
		if v.index == index -1 then
			table.insert(equip_list, v)
		end
	end
	return equip_list
end

function ForgeData:GetSlotTypeByIndex(index)
	return self.equipment_slot_cfg[index] and self.equipment_slot_cfg[index].equiment_slot or 0
end

function ForgeData:GetNumOfSlot()
	local count = 0
	for k,v in pairs(self.equipment_slot_cfg) do
		count = count + 1
	end
	return count
end

function ForgeData:GetItemIdByGrade(slot_type, grade)
	local base_prof = PlayerData.Instance:GetRoleBaseProf()
	local equipment_cfg = ConfigManager.Instance:GetAutoItemConfig("equipment_auto")
	local sub_type = 100 + slot_type
	for k,v in pairs(equipment_cfg) do
		if v.color == GameEnum.ITEM_COLOR_RED and grade == v.order and sub_type == v.sub_type then
			if v.limit_prof == base_prof or v.limit_prof == 5 then
				return v.icon_id , v.id
			end
		end
	end
	return 100
end

function ForgeData:GetComposeNeedStuff(grade, star)
	for k,v in pairs(self.equipment_compose_cfg) do
		if grade == v.compound_order and star + 1 == v.compound_star then
			return v
		end
	end
end

function ForgeData:GetBagComposeStuff(grade, star)
	local requst_list = self:GetComposeNeedStuff(grade, star)
	local bag_list = ItemData.Instance:GetItemListByBigType(GameEnum.ITEM_BIGTYPE_EQUIPMENT)
	if nil == bag_list or #bag_list <= 0 then return {} end

	local base_prof = PlayerData.Instance:GetRoleBaseProf()
	local match_list = {}
	for k,v in pairs(bag_list) do
		local equip_cfg = ItemData.Instance:GetItemConfig(v.item_id)

		local star_index = 0
		if v.param.xianpin_type_list and not EquipData.IsJLType(equip_cfg.sub_type) then
			for k1, v1 in pairs(v.param.xianpin_type_list) do
				if v1 ~= nil and v1 > 0 then
					local legend_cfg = self:GetLegendCfgByType(v1)
					if legend_cfg ~= nil and legend_cfg.color == 1 then
						star_index = star_index + 1
					end
				end
			end
		end
		if equip_cfg.color == requst_list.need_color and requst_list.compound_order == equip_cfg.order and requst_list.need_star == star_index then
			if base_prof == equip_cfg.limit_prof or equip_cfg.limit_prof == 5 then
				table.insert(match_list, v)
			end
		end
	end
	return match_list
end

function ForgeData:SetIsComposeSucc(is_succ)
	self.is_succ = is_succ
end

function ForgeData:GetIsComposeSucc()
	if self.is_succ and self.is_succ == 1 then
		return true
	end
	return false
end

function ForgeData:GetZSRandomValueList(equip_level, equip_color, equip_type)
	local list = {}
	local equip_type_list = self:GetShowZSType(equip_level, equip_color, equip_type)
	if #equip_type_list == 0 then return list end
	for k,v in pairs(self.equiment_zhuang_sheng_cfg) do
		if v.equip_color == equip_color and equip_level == v.equip_level then
			if v.attr_type == equip_type_list[1] then
				list[1] = {}
				list[1].attr_value_max = v.attr_value_max
				list[1].attr_value_min = v.attr_value_min
			elseif v.attr_type == equip_type_list[2] then
				list[2] = {}
				list[2].attr_value_max = v.attr_value_max
				list[2].attr_value_min = v.attr_value_min
			elseif v.attr_type == equip_type_list[3] then
				list[3] = {}
				list[3].attr_value_max = v.attr_value_max
				list[3].attr_value_min = v.attr_value_min
			end
			if #list == 3 then
				break
			end
		end
	end
	return list
end

function ForgeData:GetShowZSType(equip_level, equip_color, equip_type)
	local list = {}
	for k,v in pairs(self.equiment_zs_equip_show_cfg) do
		if v.equip_type == equip_type and v.equip_grade == equip_level and v.equip_color == equip_color then
			list[1] = v.suiji_type1
			list[2] = v.suiji_type2
			list[3] = v.suiji_type3
			return list
		end
	end
	return list
end

--展示套装属性
function ForgeData:GetTotalLevelDes(attr_list, is_next, total_level_name, now_level)
	local total_level = attr_list.total_level or attr_list.total_strength_level or attr_list.total_star or attr_list.shen_level or attr_list.level or 0
	local total_level_name = total_level_name ~= "" and total_level_name or Language.Forge.AllTotalLevel
	local suit_name = total_level_name
	local total_level = ToColorStr(total_level.. Language.Common.Ji, TEXT_COLOR.GRAY_WHITE)
	local now_level = ToColorStr(now_level .. Language.Common.Ji, TEXT_COLOR.GREEN_4)
	local total_str = ""
	if is_next then
		total_str =  total_level_name .. "(".. now_level .. "/" .. total_level .. ")"
	else
		now_level = ToColorStr(now_level, TEXT_COLOR.GRAY_WHITE) --  .. Language.Common.Ji
		total_str = total_level_name .. "(" .. now_level .. ")"
	end
	return total_str
end

function ForgeData:GetShowXianPinCfg()
	local decs_list = {}
	local star_value = 0
	for k,v in pairs(self.xianpin_cfg) do
		if v.equip_color == 5
			and (v.xianpin_type == 58 or v.xianpin_type == 59 or v.xianpin_type == 60) then
			if v.xianpin_type == 58 then
				star_value = 1
			elseif v.xianpin_type == 59 then
				star_value = 2
			elseif v.xianpin_type == 60 then
				star_value = 3
			end
			table.insert(decs_list, "<color=#ffff00>" .. star_value .. "★</color>" .. v.desc)
		end
	end
	return decs_list
end

function ForgeData:GetRedEquipComposeCfg(item_id, xianpin_count)
	if nil == item_id or nil == xianpin_count then return nil end

	if nil == self.equipment_compose_cfg[item_id] then
		return nil
	end

	return self.equipment_compose_cfg[item_id][xianpin_count]
end

-- 获取永恒装备套装配置
function ForgeData:GetEternitySuitCfg(suit_level)
	if nil == suit_level then return nil, nil end

	local now_suit_cfg = nil
	local next_suit_cfg = nil

	local suit_index = self:GetEternitySuitIndex(suit_level)
	if suit_index <= 0 then
		next_suit_cfg = self.eternity_suit_cfg[suit_level + 1]
		return now_suit_cfg, next_suit_cfg
	end

	now_suit_cfg = self.eternity_suit_cfg[suit_level]

	if suit_index >= self:GetMaxEternitySuitCount() then
		return now_suit_cfg, next_suit_cfg
	end

	for k, v in pairs(self.eternity_suit_cfg) do
		if v.suit_index > suit_index
			and v.suit_index - suit_index == 1 then

			next_suit_cfg = v
			break
		end
	end
	return now_suit_cfg, next_suit_cfg
end

function ForgeData:GetMaxEternitySuitCount()
	if self.max_eternity_suit_count <= 0 then
		for _, v in pairs(self.eternity_suit_cfg) do
			self.max_eternity_suit_count = self.max_eternity_suit_count + 1
		end
	end
	return self.max_eternity_suit_count
end

--基础装toggle红点状态的激活,往里面传ForgeData.BASEEQUIPTAG里面的参数
function ForgeData:IsShowBaseEquipToggleRedPoint(sub_type)
	local equip_quality_list_data = self:ReorderEquipList()
	if not equip_quality_list_data then
		return false
	end
	--查看提升品质的栏是否达到激活红点的状态
	if sub_type == ForgeData.BASEEQUIPTAG.QUALITY then
		for k,v in pairs(equip_quality_list_data) do
			if self:IsCanUpBaseEquip(v,sub_type) then
				return true
			end
		end
		return false
	--查看提升等级的栏是否达到激活红点的状态
	elseif sub_type == ForgeData.BASEEQUIPTAG.LEVEL then
		local equip_level_list_data = self:GetLevelUpBaseEquip(equip_quality_list_data)
		if not equip_level_list_data then
			return false
		end
		for k,v in pairs(equip_level_list_data) do
			if self:IsCanUpBaseEquip(v,sub_type) then
				return true
			end
		end
		return false
	end
end

function ForgeData:IsCanUpBaseEquip(data,sub_type)
	if sub_type == ForgeData.BASEEQUIPTAG.QUALITY then
		local quality_cfg = nil
		if self:GetIsCanUpEquipQuality(data) then
			quality_cfg = self:GetForgeQualityCfg(data.index,data.param.quality)
		else
			return false
		end

		if quality_cfg then
			local quality_stuff_need_num = quality_cfg.stuff_count
			local quality_stuff_had_num = ItemData.Instance:GetItemNumInBagById(quality_cfg.stuff_id)
			return quality_stuff_had_num >= quality_stuff_need_num 
		else 
			return false		
		end
	end

	if sub_type == ForgeData.BASEEQUIPTAG.LEVEL then
		local level_cfg = nil
		if self:GetIsCanUpEquipLevel(data) then
			level_cfg = self:GetBaseEquipLevelData(data.item_id)
		else
			return false
		end

		if level_cfg then
			local level_stuff_need_num = level_cfg.stuff_count
			local level_stuff_had_num = ItemData.Instance:GetItemNumInBagById(level_cfg.stuff_id)
			return level_stuff_had_num >= level_stuff_need_num
		else
			return false
		end
	end
end

function ForgeData:GetForgeFeiXianEquipRemind()
	self.true_org = self:CheckFeiXian(1)
	self.org = self:CheckFeiXian(0)
	if self.true_org == 0 and self.org == 0 then
		return 0
	else
		return 1
	end
end

function ForgeData:GetForgeFeiXianEquipRemindRed()
	local num = self:CheckFeiXian(1)
	return num
end
function ForgeData:GetForgeFeiXianEquipReminOrange()
	local num = self:CheckFeiXian(0)
	return num
end
function ForgeData:GetFeixianRedPointTab()
	return self.true_org,self.org
end

function ForgeData:CheckFeiXian(really)
	local need_count = 0
	if really == 0 then need_count = 2 
	elseif really == 1 then need_count = 1
	end
	local cells_num = {}
	local equip_on_role = self:GetFeixianInfo()

	for i = 0, 9 do
		cells_num[i] = {}
		cells_num[i].cell = {}
		cells_num[i].ison = false
		if nil ~= equip_on_role[i] then 
			if nil ~= equip_on_role[i].item_id then 
				local item_cfg_on_role = self.equipment_auto_cfg[equip_on_role[i].item_id]
				if nil ~= item_cfg_on_role then 
					if 0 ~= equip_on_role[i].item_id and equip_on_role[i].param.xianpin_star_num == 3 and v.param.really == really and item_cfg_on_role.color == 4 then 
						cells_num[i].cell[equip_on_role[i].item_id] = {} 
						cells_num[i].cell[equip_on_role[i].item_id].num = 1
						cells_num[i].cell[equip_on_role[i].item_id].cell = {}
						cells_num[i].cell[equip_on_role[i].item_id].cell[cells_num[i].cell[equip_on_role[i].item_id].num] = equip_on_role[i]
					end	
				end	
			end		
		end
		local itemdata_list = ItemData.Instance:GetBagItemDataList()
		local feixian_sub_type =  ForgeData.FORGE_FLY_IMMED_EQUIP[ForgeData.FORGE_FLY_ID[i]]
	 	-- 系列检索
	 	for k,v in pairs(itemdata_list) do

	 		local item_cfg = self.equipment_auto_cfg[v.item_id]
	 		if nil ~= item_cfg and nil ~= v.param then 
	 			if item_cfg.sub_type == feixian_sub_type and v.param.xianpin_star_num == 3 and v.param.really == really and item_cfg.color == 4 then 
	 				if nil ~= cells_num[i].cell[v.item_id] then 
	 					cells_num[i].cell[v.item_id].num = cells_num[i].cell[v.item_id].num + 1
	 					cells_num[i].cell[v.item_id].cell[cells_num[i].cell[v.item_id].num] = v
	 				else
	 					cells_num[i].cell[v.item_id] = {}
	 					cells_num[i].cell[v.item_id].num = 1
	 					cells_num[i].cell[v.item_id].cell = {}
	 					cells_num[i].cell[v.item_id].cell[cells_num[i].cell[v.item_id].num] = v

	 				end
	 			end
	 		end
	 	end
	end
	if need_count == 0 then return 0 end
	 	
	for k,v in pairs(cells_num) do
		for kz,vz in pairs(v.cell) do
	 		if vz.num >= need_count then 
	 			return 1
	 		end			
		end
	end
	return 0
end
function ForgeData:GetFeiXianXianPinType()
	return self.feixian_xianpin_type
end




-----------------------
--------共用

-- 获得分解的物品
function ForgeData:GetRecycleItem(item_type)
	local cfg = self.equipforge_auto_cfg.decompose
	for k, v in pairs(cfg) do
		if item_type == v.type then
			return v
		end
	end
end

-- ui tween Cfg
function ForgeData:GetUITweenCfg(panel_tab_index)
	local tween_cfg = {
		[TabIndex.forge_advance] = {["DownPanel"] = Vector3(74, -475, 0), ["UpPanel"] = true, ["MoveTime"] = 0.5},
		[TabIndex.forge_strengthen] = {["DownPanel"] = Vector3(74, -475, 0), ["UpPanel"] = true, ["MoveTime"] = 0.5},
		[TabIndex.forge_gem] = {["DownPanel"] = Vector3(74, -475, 0), ["UpPanel"] = true, ["MoveTime"] = 0.5},
		[TabIndex.forge_quality] = {["DownPanel"] = Vector3(74, -475, 0), ["UpPanel"] = true, ["MoveTime"] = 0.5},
		[TabIndex.forge_yongheng] = {["LeftPanel"] = Vector3(-1083, -24, 0), ["FightPowerLabel"] = Vector3(-860, -319, 0), ["RightPanel"] = Vector3(860, -24, 0), ["MoveTime"] = 0.5},
		[TabIndex.forge_cast] = {["LeftPanel"] = true, ["RightPanel"] = Vector3(383, -23, 0), ["MoveTime"] = 0.5},
		[TabIndex.forge_up_star] = {["LeftPanel"] = Vector3(-1045, -21, 0), ["RightPanel"] = Vector3(225, -21, 0), ["MoveTime"] = 0.5},
		[TabIndex.forge_jade] = {["DownPanel"] = Vector3(74, -475, 0), ["UpPanel"] = true, ["MoveTime"] = 0.5},
		[TabIndex.forge_jade_refine] = {["DownPanel"] = Vector3(71, -563, 0), ["UpPanel"] = Vector3(71, 567, 0), ["MoveTime"] = 0.5},
		[TabIndex.forge_deity_intersify] = {["DownPanel"] = Vector3(68, -573, 0), ["UpPanel"] = true, ["MoveTime"] = 0.5},
		[TabIndex.forge_deity_suit] = {["RightPanel"] = Vector3(840, -28, 0), ["LeftPanel"] = Vector3(-140, -408, 0), ["MidPanel"] = true, ["MoveTime"] = 0.5},
		[TabIndex.forge_extreme_suit] = {["DownPanel"] = Vector3(75, -455, 0), ["UpPanel"] = true, ["LeftPanel"] = Vector3(-100, -389, 0), ["MoveTime"] = 0.5},
	}
	return tween_cfg[panel_tab_index]
end

-- 红点
function ForgeData:CheckFunIsCanImprove(data, view_index)
	if view_index ==TabIndex.forge_advance then
		return self:CheckAdvanceIsCanImprove(data)
	elseif view_index == TabIndex.forge_strengthen then
		return self:CheckStrengthIsCanImprove(data)
	elseif view_index == TabIndex.forge_gem then
		return self:GetEquipGemCanImprove(data)
	elseif view_index == TabIndex.forge_quality then
		return self:GetEquipQualityCanImprove(data)
	elseif view_index == TabIndex.forge_yongheng then
		return self:GetEquipEternityCanImprove(data)
	elseif view_index == TabIndex.forge_cast then
		return self:CheckCastIsCanImprove(data)
	elseif view_index == TabIndex.forge_up_star then
		return self:CheckUpStarIsCanImprove(data)
	elseif view_index == TabIndex.forge_jade then
		return self:GetJadeCanImprove(data)
	elseif view_index == TabIndex.forge_jade_refine then
		return self:GetJadeRefineCanImprove(data)
	elseif view_index == TabIndex.forge_deity_intersify then
		return self:GetDeityIntersifyCanImprove(data)
	elseif view_index == TabIndex.forge_deity_suit then
		return self:GetDeitySuitCanImprove(data)
	elseif view_index == TabIndex.forge_jue_xing then
		return self:GetJueXingCanImprove(data)
	end
end

-----------------------
-------- 红点remind

-- 红点 进阶
function ForgeData:GetForgeAdvanceRemind()
	if not OpenFunData.Instance:CheckIsHide("forge_advance") then
		return 0
	end

	local equip_suit = EquimentSuitData.Instance:GetEquimentSuitRemind()
	local equip_data = EquipData.Instance:GetDataList()
	for _, v in pairs(equip_data) do
		if v.item_id ~= nil and 0 == self:CheckFunIsCanImprove(v, TabIndex.forge_advance) then
			return 1 + equip_suit
		end
	end

	return 0 + equip_suit
end

-- 红点 强化
function ForgeData:SetStrengthStoneNum()
	local cfg = self:GetStrengthCfg(0, 1)
	if not cfg then return 0 end
	local material_num = ItemData.Instance:GetItemNumInBagById(cfg.stuff_id)
	self.strength_stone_num = material_num
end

function ForgeData:GetForgeStrenthenRemind()
	local cfg = self:GetStrengthCfg(0, 1)
	if not cfg then return 0 end
	local material_num = ItemData.Instance:GetItemNumInBagById(cfg.stuff_id)
	if self.strength_stone_num and self.strength_stone_num >= material_num then return 0 end

	if not OpenFunData.Instance:CheckIsHide("forge_strengthen") then
		return 0
	end

	local goal_info =  self:GetStrengthGoalInfo()
	if goal_info ~= nil and goal_info.active_flag ~= nil and goal_info.fetch_flag ~= nil then
		if (goal_info.active_flag[0] == 1 and goal_info.fetch_flag[0] == 0) or (goal_info.fetch_flag[0] == 1 and goal_info.active_flag[1] == 1 and goal_info.fetch_flag[1] == 0) then
			return 1
		end
	end

	local equip_data = EquipData.Instance:GetDataList()
	for _, v in pairs(equip_data) do
		if v.item_id ~= nil and 0 == self:CheckFunIsCanImprove(v, TabIndex.forge_strengthen) then
			return 1
		end
	end

	return 0
end

-- 红点 宝石
function ForgeData:GetForgeGemRemind()
	if not OpenFunData.Instance:CheckIsHide("forge_gem") then
		return 0
	end

	local goal_info =  self:GetGemGoalInfo()
	if goal_info ~= nil and goal_info.active_flag ~= nil and goal_info.fetch_flag ~= nil then
		if (goal_info.active_flag[0] == 1 and goal_info.fetch_flag[0] == 0) or (goal_info.fetch_flag[0] == 1 and goal_info.active_flag[1] == 1 and goal_info.fetch_flag[1] == 0) then
			return 1
		end
	end

	local equip_data = EquipData.Instance:GetDataList()
	for _, v in pairs(equip_data) do
		if v.item_id ~= nil and 0 == self:CheckFunIsCanImprove(v, TabIndex.forge_gem) then
			return 1
		end
	end

	return 0
end

-- 红点 品质
function ForgeData:GetForgeQualityRemind()
	-- if not OpenFunData.Instance:CheckIsHide("forge_quality") then
	-- 	return 0
	-- end

	-- local equip_data = EquipData.Instance:GetDataList()
	-- for _, v in pairs(equip_data) do
	-- 	if v.item_id ~= nil and 0 == self:CheckFunIsCanImprove(v, TabIndex.forge_quality) then
	-- 		return 1
	-- 	end
	-- end

	return 0
end

-- 红点 套装（永恒）
function ForgeData:GetForgeYonghengRemind()
	if not OpenFunData.Instance:CheckIsHide("forge_yongheng") then
		return 0
	end

	local equip_data = EquipData.Instance:GetDataList()
	for _, v in pairs(equip_data) do
		if v.item_id ~= nil and 0 == self:CheckFunIsCanImprove(v, TabIndex.forge_yongheng) then
			return 1
		end
	end

	return 0
end

-- 红点 神铸
function ForgeData:GetForgeCastRemind()
	if not OpenFunData.Instance:CheckIsHide("forge_cast") then
		return 0
	end

	local equip_data = EquipData.Instance:GetDataList()
	for _, v in pairs(equip_data) do
		if v.item_id ~= nil and 0 == self:CheckFunIsCanImprove(v, TabIndex.forge_cast) then
			return 1
		end
	end

	return 0
end

-- 红点 升星
function ForgeData:GetForgeUpStarRemind()
	if not OpenFunData.Instance:CheckIsHide("forge_up_star") then
		return 0
	end

	local equip_data = self.zhuanzhi_equip or {}
	for _, v in pairs(equip_data) do
		if v.item_id > 0 and 0 == self:CheckFunIsCanImprove(v, TabIndex.forge_up_star) then
			return 1
		end
	end

	return 0
end

-- 红点 玉石
function ForgeData:GetForgeJadeRemind()
	if not OpenFunData.Instance:CheckIsHide("forge_jade") then
		return 0
	end

	local equip_data = self.zhuanzhi_equip or {}
	for _, v in pairs(equip_data) do
		if v.item_id > 0 and 0 == self:CheckFunIsCanImprove(v, TabIndex.forge_jade) then
			return 1
		end
	end

	return 0
end

-- 红点 玉石精炼 (功能屏蔽)
function ForgeData:GetForgeJadeRefineRemind()
	return 0

	-- local equip_data = self.zhuanzhi_equip or {}
	-- for _, v in pairs(equip_data) do
	-- 	if v.item_id > 0 and 0 == self:CheckFunIsCanImprove(v, TabIndex.forge_jade_refine) then
	-- 		return 1
	-- 	end
	-- end

	-- return 0
end

-- 红点 附灵（神装强化）
function ForgeData:SetFuLingStoneNum()
	local cfg = self:GetLockNumConsumeCfg(0)
	if not cfg then return 0 end
	local material_num = ItemData.Instance:GetItemNumInBagById(cfg.consume_stuff_id)
	self.fuling_stone_num = material_num
end

function ForgeData:GetForgeDeityIntersifyRemind()
	-- local cfg = self:GetLockNumConsumeCfg(0)
	-- if not cfg then return 0 end
	-- local material_num = ItemData.Instance:GetItemNumInBagById(cfg.consume_stuff_id)
	-- if self.fuling_stone_num and self.fuling_stone_num >= material_num then return 0 end

	-- if not OpenFunData.Instance:CheckIsHide("forge_deity_intersify") then
	-- 	return 0
	-- end

	-- local equip_data = self.zhuanzhi_equip or {}
	-- for _, v in pairs(equip_data) do
	-- 	if v.item_id > 0 and 0 == self:CheckFunIsCanImprove(v, TabIndex.forge_deity_intersify) then
	-- 		return 1
	-- 	end
	-- end

	return 0
end

-- 红点 套装
function ForgeData:GetForgeDeitySuitRemind()
	if not OpenFunData.Instance:CheckIsHide("forge_deity_suit") then
		return 0
	end

	local equip_data = self.zhuanzhi_equip or {}
	for _, v in pairs(equip_data) do
		if v.item_id > 0 and 0 == self:CheckFunIsCanImprove(v, TabIndex.forge_deity_suit) then
			return 1
		end
	end

	return 0
end

function ForgeData:GetForgeJueXingRemind()
	if not OpenFunData.Instance:CheckIsHide("forge_jue_xing") then
		return 0
	end

	local equip_data = self.zhuanzhi_equip or {}
	for _, v in pairs(equip_data) do
		if v.item_id > 0 and 0 == self:CheckFunIsCanImprove(v, TabIndex.forge_jue_xing) then
			return 1
		end
	end

	return 0
end



----------------------------
--------进阶 ForgeAdvance
function ForgeData:GetAdvanceCfg(item_id)
	return self.advance_cfg[item_id]
end

function ForgeData:GetAdvanceIndexMaxLevelId(equip_index)
	local cfg = self.advance_index_cfg[equip_index]
	if equip_index == 6 then
		local base_prof = PlayerData.Instance:GetRoleBaseProf()
		local temp_cfg = cfg or {}
		local temp_new_equip_id = nil
		for k, v in pairs(temp_cfg) do
			if v.prof == base_prof then
				if not temp_new_equip_id or v.new_equip_id > temp_new_equip_id then
					temp_new_equip_id = v.new_equip_id
				end
			end
		end
		return temp_new_equip_id
	else
		return cfg and cfg[#cfg].new_equip_id or nil
	end
end

function ForgeData:CheckAdvanceIsCanImprove(data)
	local cfg = self:GetAdvanceCfg(data.item_id)
	if nil == cfg then return false end

	local role_level = PlayerData.Instance:GetRoleLevel()
	local limit_role_level = cfg.equip_level
	if role_level < limit_role_level then
		return false
	end

	local item_count = cfg.stuff_count_2
	local had_item_num = ItemData.Instance:GetItemNumInBagById(cfg.stuff_id_2)
	return (item_count <= had_item_num) and 0 or false
end


----------------------------
--------强化 ForgeStrengthen
-- 强化大小目标
function ForgeData:SetStrengthGoalInfo(protocol)
	self.strength_goal_info = {}
	self.strength_goal_info.open_system_timestamp = protocol.open_system_timestamp
	self.strength_goal_info.active_flag = protocol.active_flag
	self.strength_goal_info.fetch_flag = protocol.fetch_flag
	self.strength_goal_info.active_special_attr_flag = protocol.active_special_attr_flag
end

function ForgeData:GetStrengthGoalInfo()
	return self.strength_goal_info
end

function ForgeData:GetStrengthCfg(equip_index, level)
	if self.strength_cfg[equip_index] then
		return self.strength_cfg[equip_index][level]
	end
end

--强化 获得装备(某阶数)强化最高等级
function ForgeData:GetMaxStrengthLevelByGrade(equip_index, order)
	if self.strength_grade_cfg[equip_index] then
		local cfg = nil
		if order == nil then
			cfg = self.strength_grade_cfg[equip_index]
			cfg = cfg[#cfg]
		else
			cfg = self.strength_grade_cfg[equip_index][order]
		end
		if nil == cfg then return end

		return cfg[#cfg].strength_level
	end
end

--强化 获得全身强化等级
function ForgeData:GetTotalStrengthLevel()
	local data = EquipData.Instance:GetDataList()
	local total_level = 0
	for k,v in pairs(data) do
		total_level = total_level + v.param.strengthen_level
	end
	return total_level
end

--强化 获取全身强化Cfg
function ForgeData:GetTotalStrengthCfgByLevel(total_level)
	local full_strength_cfg = self.equipforge_auto_cfg.strength_minlevel_reward
	local target_cfg = nil
	local next_cfg = nil
	for k,v in pairs(full_strength_cfg) do
		if v.total_strength_level <= total_level then
			target_cfg = v
		else
			next_cfg = v
			break
		end
	end
	return target_cfg, next_cfg
end

function ForgeData:CheckStrengthIsCanImprove(equip_data)
	local cfg = ItemData.Instance:GetItemConfig(equip_data.item_id)
	if not cfg then return false end

	local max_level = self:GetMaxStrengthLevelByGrade(equip_data.index, cfg.order)
	if max_level and max_level <= equip_data.param.strengthen_level then
		return 1
	end
	--材料
	local next_cfg = self:GetStrengthCfg(equip_data.index, equip_data.param.strengthen_level + 1)
	if nil == next_cfg then return false end
	
	local item_id = next_cfg["stuff_id"]
	local item_count = next_cfg["stuff_count"]
	local had_item_num = ItemData.Instance:GetItemNumInBagById(item_id)
	if had_item_num < item_count then
		return 2, item_id, (item_count - had_item_num)
	end

	return 0
end

-- 获取全身装备强化属性
function ForgeData:GetEquipAllStrengthAttr()
	local equip_list  = EquipData.Instance:GetDataList() or {}
	local attribute = CommonStruct.AttributeNoUnderline()
	for k, v in pairs(equip_list) do
		if v.item_id and v.item_id > 0 and v.param and v.param.strengthen_level > 0 then
			local strength_cfg = self:GetStrengthCfg(v.index, v.param.strengthen_level)
			if strength_cfg then
				local attr_tab = CommonDataManager.GetAttributteNoUnderline(strength_cfg)
				attribute = CommonDataManager.AddAttributeAttrNoUnderLine(attribute, attr_tab)
			end
		end
	end
	return attribute
end

--------------------------------
--------宝石 ForgeGem
-- 宝石大小目标
function ForgeData:SetGemGoalInfo(protocol)
	self.gem_goal_info = {}
	self.gem_goal_info.open_system_timestamp = protocol.open_system_timestamp
	self.gem_goal_info.active_flag = protocol.active_flag
	self.gem_goal_info.fetch_flag = protocol.fetch_flag
	self.gem_goal_info.active_special_attr_flag = protocol.active_special_attr_flag
end

function ForgeData:GetGemGoalInfo()
	return self.gem_goal_info
end

function ForgeData:SetGemInfo(protocol)
	self.gem_total_level = protocol.total_stone_level
	self.stone_limit_list = {}
	for k, v in pairs(protocol.stone_limit_flag) do
		self.stone_limit_list[k] = bit:d2b(v) or {}
	end

	self.gem_info = protocol.stone_infos
	self:SetTotalGemPower()
	RemindManager.Instance:Fire(RemindName.KaiFu)
	RemindManager.Instance:Fire(RemindName.ForgeBaoshi)
end

function ForgeData:GetGemInfo()
	return self.gem_info or {}
end

function ForgeData:GetGemInfoByIndex(equip_index)
	return self.gem_info[equip_index] or {}
end

function ForgeData:GetGemCfg(item_id)
	return self.stone_cfg[item_id]
end

--宝石 获取装备上所有宝石格子的状态: 0、锁定 1、可镶嵌 2、已镶嵌
function ForgeData:GetEquipGemInfo(equip_index)
	local final_data = {}
	local gem_data = self.gem_info[equip_index] or {}

	for k ,v in pairs(gem_data) do
		local temp_data = {}
		if v.stone_id == 0 then
			if self.stone_limit_list[equip_index][32 - k] == 0 then
				temp_data.gem_state = 0
			else
				temp_data.gem_state = 1
			end
		else
			temp_data.gem_state = 2
			temp_data.gem_id = v.stone_id
		end
		final_data[k] = temp_data
	end
	return final_data
end

--根据格子index获取开启条件
function ForgeData:GetGemOpenLimitCfg(equip_index, stone_index)
	local cfg = self.gem_open_limit_cfg[equip_index] or {}
	for k, v in pairs(cfg) do
		if stone_index == v.stone_index then
			return v
		end
	end
end

-- 是否请求宝石信息
function ForgeData:IsSendStoneMsg(level)
	local cfg = self.gem_open_limit_cfg[0]
	for k, v in pairs(cfg) do
		if level == v.param1 then
			return true
		end
	end
	return false
end

--宝石 根据Euqip_Index获取装备宝石战力
function ForgeData:GetGemPowerByIndex(equip_index)
	local gem_data = self.gem_info[equip_index]
	local power = self:GetEquipGemPower(gem_data)
	return power
end

--宝石 获取单个装备的宝石战斗力
function ForgeData:GetEquipGemPower(data)
	if data == nil then
		return 0
	end
	local final_attr = {}
	local additions = {}
	for k, v in pairs(data) do
		if v.stone_id ~= 0 then
			local gem_cfg = self:GetGemCfg(v.stone_id)
			if gem_cfg ~= nil then
				if gem_cfg.stone_type <= 2 then
					if final_attr[gem_cfg.attr_type1] == nil then
						final_attr[gem_cfg.attr_type1] = 0
					end
					final_attr[gem_cfg.attr_type1] =  final_attr[gem_cfg.attr_type1] + gem_cfg.attr_val1
				else
					if additions[gem_cfg.attr_type1] == nil then
						additions[gem_cfg.attr_type1] = 0
					end
					if additions[gem_cfg.attr_type2] == nil then
						additions[gem_cfg.attr_type2] = 0
					end
					additions[gem_cfg.attr_type1] =   additions[gem_cfg.attr_type1] + gem_cfg.attr_val1
					additions[gem_cfg.attr_type2] =   additions[gem_cfg.attr_type2] + gem_cfg.attr_val2
				end
			else
				-- print(ToColorStr("宝石信息为空  "..v.stone_id, TEXT_COLOR.GREEN))
			end
		end
	end

	local total_gem_attr = {}
	for k, v in pairs(self.gem_info) do
		for k2, v2 in pairs(v) do
			if v2.stone_id ~= 0 then
				local gem_cfg = self:GetGemCfg(v2.stone_id)
				if gem_cfg and gem_cfg.stone_type <= 2 then
					if total_gem_attr[gem_cfg.attr_type1] == nil then
						total_gem_attr[gem_cfg.attr_type1] = 0
					end
					total_gem_attr[gem_cfg.attr_type1] =  total_gem_attr[gem_cfg.attr_type1] + gem_cfg.attr_val1
				end
			end
		end
	end

	for k,v in pairs(additions) do
		if final_attr[k] or total_gem_attr[k] then
			final_attr[k] = (final_attr[k] or 0) + math.floor(total_gem_attr[k] * (v / 10000))
		end
	end
	local power = CommonDataManager.GetCapability(final_attr)
	return power
end

function ForgeData:GetGemCfgByTypeAndLevel(type, level)
	local cfg = self.stone_type_level_cfg[type]
	return cfg and cfg[level]
end

function ForgeData:GetMinLevelGemTypeCfg(type)
	local cfg = self.stone_type_level_cfg[type]
	if cfg then
		for k, v in pairs(cfg) do
			return v
		end
	end
end

--宝石 检查装备的宝石是否能镶嵌(1)、替换(2)、升级(3)
function ForgeData:GetEquipGemCanImprove(data)
	local gem_data = self:GetEquipGemInfo(data.index)
	for k,v in pairs(gem_data) do
		local bag_gem = {}
		if v.gem_id ~= nil then
			local gem_type = self:GetGemTypeByid(v.gem_id)
			bag_gem = self:GetGemsInBag(gem_type)
		else
			bag_gem = self:GetBagGemlistByGemInfo(gem_data)
		end
		local count = 0
		for k,v in pairs(bag_gem) do
			count = count + 1
		end
		-- local bag_gem = self:GetGemsInBag(k)
		if v.gem_state == 1 then
			--处理可镶嵌
			if count > 0 then
				return 0, 1
			end
		elseif v.gem_state == 2 then
			--处理可替换
			local max_id = v.gem_id
			for k2,v2 in pairs(bag_gem) do
				if v2.item_id > max_id then
					return 0, 2
				end
			end
			--处理可升级
			local forge_gem_cfg = self:GetGemCfg(v.gem_id)
			if forge_gem_cfg then
				local level = forge_gem_cfg.level
				local next_cfg =self:GetGemCfgByTypeAndLevel(forge_gem_cfg.stone_type, level + 1)
				if next_cfg ~= nil then
					local upgrade_need_energy = math.pow(3, level) - math.pow(3, level - 1)
					local had_energy = 0
					for k,v in pairs(bag_gem) do
						if v.item_id <= forge_gem_cfg.item_id then
							local tmp_forge_gem_cfg = ForgeData.Instance:GetGemCfg(v.item_id)
							if tmp_forge_gem_cfg then
								had_energy = had_energy + (math.pow(3, tmp_forge_gem_cfg.level - 1) * v.num)
							end
						end
					end
					if had_energy >= upgrade_need_energy then
						return 0, 3
					end
				end
			end
		end
	end
	return false
end

function ForgeData:GetCurBagGemList(stone_index)
	local bag_all_list = {}
	local all_type_list = {}
	local equip_gem_data = self:GetEquipGemInfo(stone_index)
	for i = 0, 5 do
		all_type_list[i] = true
	end
	for k,v in pairs(equip_gem_data) do
		if v.gem_state == 2 then
			local cfg = self:GetGemCfg(v.gem_id)
			if nil ~= cfg then
				all_type_list[cfg.stone_type] = false
			end
		end
	end
	for k, v in pairs(all_type_list) do
		if v then
			local bag_gem_tab = self:GetGemsInBag(k)
			if next(bag_gem_tab) then
				for k1, v1 in pairs(bag_gem_tab) do
					local tab = TableCopy(v1)
					local gem_cfg = self:GetGemCfg(tab.item_id)
					tab.stone_type = gem_cfg.stone_type
					tab.stone_sort_level = 11 - gem_cfg.level
					table.insert(bag_all_list, tab)
				end
			end
		end
	end
	if next(bag_all_list) then
		table.sort(bag_all_list, SortTools.KeyLowerSorter("stone_type", "stone_sort_level"))
	end
	return bag_all_list
end

function ForgeData:GetCurBagGemReplaceList(stone_index)
	local bag_all_list = {}
	local all_type_list = {}
	local equip_gem_data = self:GetEquipGemInfo(stone_index)
	for i = 0, 5 do
		all_type_list[i] = true
	end
	for k, v in pairs(all_type_list) do
		if v then
			local bag_gem_tab = self:GetGemsInBag(k)
			if next(bag_gem_tab) then
				for k1, v1 in pairs(bag_gem_tab) do
					local tab = TableCopy(v1)
					local gem_cfg = self:GetGemCfg(tab.item_id)
					tab.stone_type = gem_cfg.stone_type
					tab.stone_sort_level = 11 - gem_cfg.level
					table.insert(bag_all_list, tab)
				end
			end
		end
	end
	if next(bag_all_list) then
		table.sort(bag_all_list, SortTools.KeyLowerSorter("stone_type", "stone_sort_level"))
	end
	return bag_all_list
end

--宝石 得到玩家背包中的宝石 gem_type:0-5,指定宝石的类型
function ForgeData:GetGemsInBag(gem_type)
	local gems_list = ItemData.Instance:GetGemsInBag(gem_type) or {}
	return gems_list
end

function ForgeData:GetHadGemsInBag()
	local had_tab = {}
	for i = 0, 5 do
		table.insert(had_tab, i, ItemData.Instance:GetGemsInBag(i) or {})
		local tab  
	end
	return had_tab
end

--宝石 获得宝石中文属性对
function ForgeData:GetGemAttr(gem_id)
	local forge_gem_cfg = self:GetGemCfg(gem_id)
	local attr_list = {}
	if forge_gem_cfg then
		for i = 1, 2 do
			if forge_gem_cfg["attr_type"..i] == nil or forge_gem_cfg["attr_type"..i] == 0 then
				break
			else
				local data = {}
				if forge_gem_cfg.stone_type >= 3 then
					data.attr_name = Language.Forge.GemAttrName[2][forge_gem_cfg["attr_type"..i]] or "nil"
					data.attr_value = (forge_gem_cfg["attr_val"..i] / 100)..'%'
				else
					data.attr_name = Language.Forge.GemAttrName[1][forge_gem_cfg["attr_type"..i]] or "nil"
					data.attr_value = forge_gem_cfg["attr_val"..i]
				end
				data.attr_real_name = CommonDataManager.GetAttrName(forge_gem_cfg["attr_type"..i])
				table.insert(attr_list, data)
			end
		end
	end
	return attr_list
end

function ForgeData:GetGemTypeByid(id)
	local cfg = self:GetGemCfg(id)
	return cfg and cfg.stone_type or 0
end

function ForgeData:GetMinType(equip_index)
	local has_type_list = {}
	local all_type_list = {}
	for i = 0, 6 do
		table.insert(all_type_list, i)
	end
	local equip_data = self:GetEquipGemInfo(equip_index)
	if next(equip_data) then
		for k,v in pairs(equip_data) do
			if v.gem_state == 2 then
				local cfg = self:GetGemCfg(v.gem_id)
				if nil ~= cfg then
					table.insert(has_type_list, cfg.stone_type)
				end
			end
		end
	end
	if nil ~= next(has_type_list) then
		for i=#all_type_list,1,-1 do
			for k,v in pairs(has_type_list) do
				if all_type_list[i] and all_type_list[i] == v then
					table.remove(all_type_list, i)
				end
			end
		end
	end
	if next(all_type_list) then
		for k,v in pairs(all_type_list) do
			if v ~= 6 then
				return v
			end
		end
	end
	return 0
end

--宝石 全身宝石等级配置
function ForgeData:GetTotalGemCfg()
	local total_gem_cfg = self.equipforge_auto_cfg.stone_ex_add
	local current_cfg = {}
	local next_cfg = {}
	local total_level = self.gem_total_level or 0

	for k,v in pairs(total_gem_cfg) do
		if v.total_level <= total_level then
			current_cfg = v
		else
			next_cfg = v
			break
		end
	end
	return total_level, current_cfg, next_cfg
end

-- 获取全身宝石属性
function ForgeData:GetEquipAllStoneAttr()
	local equip_list  = EquipData.Instance:GetDataList() or {}
	local attr_tab = {}
	local per_attr_tab = {}
	for k, v in pairs(equip_list) do
		if v.item_id and v.item_id > 0 then
			local stone_info = self:GetEquipGemInfo(v.index) or {}
			for k2, v2 in pairs(stone_info) do
				if v2.gem_state == 2 and v2.gem_id then
					local attrs = self:GetGemCfg(v2.gem_id)
					for i = 1, 2 do
						if attrs["attr_val" .. i] and attrs["attr_val" .. i] > 0 then
							if attrs.stone_type <= 3 then
								local name = attrs["attr_type" .. i]
								attr_tab[name] = (attr_tab[name] or 0) + attrs["attr_val" .. i]
							else
								local name = attrs["attr_type" .. i]
								per_attr_tab[name] = (per_attr_tab[name] or 0) + attrs["attr_val" .. i]								
							end
						end
					end
				end
			end
		end
	end
	for k, v in pairs(attr_tab) do
		if per_attr_tab[k] and per_attr_tab[k] > 0 then
			attr_tab[k] = attr_tab[k] + (attr_tab[k] * per_attr_tab[k] * 0.0001)
		end
	end
	local attribute = CommonDataManager.GetAttributteNoUnderline(attr_tab)
	return attribute
end


----------------------------
---- 品质 ForgeQuality
function ForgeData:GetForgeQualityCfg(equip_index, quality)
	local cfg = self.up_quality[equip_index]
	return cfg and cfg[quality] or nil
end

function ForgeData:GetMaxColorQuality(equip_index)
	local cfg = self.up_quality_index[equip_index]
	return cfg and cfg[#cfg].quality or nil
end

-- 品质的颜色(返回配置)
function ForgeData:GetEquipColor(equip_index, quality)
	local cfg = self.up_quality[equip_index]
	if nil ~= cfg then
		return cfg[quality] and cfg[quality] or nil
	end
end

-- 品质的颜色(返回颜色下标)
function ForgeData:GetEquipColorIndex(equip_index, quality)
	local cfg = self.up_quality[equip_index]
	if nil == cfg then return 1 end

	local quality_cfg = cfg[quality]
	return quality_cfg and quality_cfg.c_quality or 1
end

function ForgeData:GetEquipQualityCanImprove(data)
	if not data or not next(data) then return false end

	local cfg = self:GetForgeQualityCfg(data.index, data.param.quality + 1)
	if nil == cfg then return false end

	local item_count = cfg.stuff_count
	local had_item_num = ItemData.Instance:GetItemNumInBagById(cfg.stuff_id)
	return (item_count <= had_item_num) and 0 or false
end

----------------------------
---- 套装（永恒） ForgeQuality
-- 永恒装备配置
function ForgeData:GetEternityEquipCfg(equip_index, level)
	if self.eternity_equip_cfg[equip_index] then
		return self.eternity_equip_cfg[equip_index][level]
	end
end

function ForgeData:GetEternityMaxLevel(equip_index)
	local cfg = self.eternity_equip_index[equip_index]
	return cfg and cfg[#cfg].eternity_level or nil
end

function ForgeData:GetEquipEternityCanImprove(data)
	if not data or not data.item_id or not data.param or not data.param.eternity_level then 
		return false 
	end

	local cur_eternity_cfg = self:GetEternityEquipCfg(data.index, data.param.eternity_level)
	local next_eternity_cfg = self:GetEternityEquipCfg(data.index, data.param.eternity_level + 1)
	if nil ~= next_eternity_cfg then
		local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
		local cur_jingjie_level = JingJieData.Instance:GetjingjieLevel()
		if cur_eternity_cfg and cur_jingjie_level >= next_eternity_cfg.jingjie_level then
		-- if cur_eternity_cfg and item_cfg.order >= next_eternity_cfg.show_level then
			local bag_num = ItemData.Instance:GetItemNumInBagById(cur_eternity_cfg.stuff_id)
			if bag_num >= cur_eternity_cfg.stuff_count then
				return 0
			end
		end
	end
	return false
end

function ForgeData:GetEternitySuitLevel(suit_level)
	return self.eternity_suit_cfg[suit_level]
end

-- 当前达到的套装等级
function ForgeData:GetCurrEternitySuitLevel()
	local equip_data = EquipData.Instance:GetDataList()
	local eternity_level = nil 
	for k, v in pairs(equip_data) do
		if not eternity_level or v.param.eternity_level < eternity_level then
			eternity_level = v.param.eternity_level
		end
	end
	local suit_level = self:GetSelectSuitLevel(eternity_level)
	return self:GetEternitySuitLevel(suit_level)
end

function ForgeData:GetSuitCfgByIndex(index)
	return self.equipforge_auto_cfg.eternity_suit[index]
end

-- 获取当前选择装备能达到的永恒套装等级
function ForgeData:GetSelectSuitLevel(suit_level)
	local level = 0
	local cfg = self.equipforge_auto_cfg.eternity_suit
	if suit_level then
		for k, v in pairs(cfg) do
			if v.suit_level > suit_level then
				break
			else
				level = v.suit_level
			end
		end
	end
	return level
end

-- 永恒功能属性
function ForgeData:GetYonghengAllAttr()
	local equip_data = EquipData.Instance:GetDataList()

	local attr_tab = CommonStruct.Attribute()
	for k, v in pairs(equip_data) do
		if v and v.item_id > 0 then 
			local yongheng_cfg = self:GetEternityEquipCfg(v.index, v.param.eternity_level)
			local add_attr = CommonDataManager.GetAttributteByClass(yongheng_cfg)
			attr_tab = CommonDataManager.AddAttributeAttr(attr_tab, add_attr)
		end
	end

	local yongheng_suit = self:GetCurrEternitySuitLevel()

	return attr_tab, yongheng_suit
end

--------------------------------
--------天锻（神铸） ForgeCast
function ForgeData:GetShenOpSingleCfg(equip_index, shen_level)
	local cfg =  self.shen_op_cfg[equip_index]
	return cfg and cfg[shen_level] or nil
end

function ForgeData:GetMaxShenOpLevel(equip_index)
	local cfg = self.shen_op_cfg[equip_index]
	if nil == cfg then 
		return 0 
	end

	return cfg[#cfg].shen_level
end

--神铸 全身神铸配置
function ForgeData:GetFullCastLevel(is_next)
	local data = EquipData.Instance:GetDataList()
	local cast_count = 0
	for k,v in pairs(data) do
		cast_count = cast_count + v.param.shen_level
	end
	local casst_auto =  self.equipforge_auto_cfg.all_shen_op
	local target_data = {}
	local next_data = {}
	for k,v in pairs(casst_auto) do
		if cast_count >= v.shen_level then
			target_data = v
		else
			next_data = v
			break
		end
	end
	return cast_count, target_data, next_data
end

-- 获得下一次增加属性的等级
function ForgeData:GetNextUpAttrLevel(equip_index, curr_level)
	local max_level = self:GetMaxShenOpLevel(equip_index)
	local curr_cfg = self:GetShenOpSingleCfg(equip_index, curr_level)
	local attr_percent = curr_cfg and curr_cfg.attr_percent or 0
	local level = curr_level + 1
	for i = level, max_level do
		local next_cfg = self:GetShenOpSingleCfg(equip_index, level)
		if next_cfg and next_cfg.attr_percent > attr_percent then
			return next_cfg.shen_level
		end
		level = level + 1
	end
end

function ForgeData:CheckCastIsCanImprove(data)
	local next_cfg = self:GetShenOpSingleCfg(data.index, data.param.shen_level + 1)
	if nil == next_cfg then return false end

	local item_count = next_cfg.stuff_count
	local had_item_num = ItemData.Instance:GetItemNumInBagById(next_cfg.stuff_id)
	return (item_count <= had_item_num) and 0 or false
end

-----------------------------------------

-------------------百战装备
function ForgeData:SetBaiZhanEquipInfo(protocol)
	self.baizhan_equip = protocol.baizhan_equip
	self.baizhan_part_order_list = protocol.baizhan_part_order_list
	self.baizhan_order_count_list = protocol.baizhan_order_count_list
	if nil ~= self.baizhan_notify_data_change_callback_list then 
		for k,v in pairs(self.baizhan_notify_data_change_callback_list) do
			v()
		end
	end
	if self.baizhan_power_flush_enable then
		self:SetBaiZhanEquipAllPower()
	end	
end

-------------------转职装备
function ForgeData:SetZhuanzhiEquipInfo(protocol)
	local old_equip_num = 0
	local new_equip_num = 0
	if self.zhuanzhi_equip and next(self.zhuanzhi_equip) then	
		for k, v in pairs(self.zhuanzhi_equip) do
			if v.item_id > 0 then
				old_equip_num = old_equip_num + 1
			end
		end
		for k, v in pairs(protocol.zhuanzhi_equip_data.equip_tab) do
			if v.item_id > 0 then
				new_equip_num = new_equip_num + 1
			end
		end
	end
		
	self.zhuanzhi_equip = protocol.zhuanzhi_equip_data.equip_tab
	self.up_star_exp_list = protocol.zhuanzhi_equip_data.star_exp_tab
	self.up_star_level_list = protocol.zhuanzhi_equip_data.star_level_tab
	self.fuling_count_list = protocol.zhuanzhi_equip_data.fuling_count_list

	if old_equip_num < new_equip_num then
		PackageCtrl.Instance:ShowQuickEquipVieww()
		for k,v in pairs(self.notify_data_count_change_callback_list) do
			v()
		end
	end
	if nil ~= self.notify_data_change_callback_list then 
		for k,v in pairs(self.notify_data_change_callback_list) do
			v()
		end
	end
	
	if self.power_flush_enable then
		self:SetZhuanzhiEquipAllPower()
	end

	RemindManager.Instance:Fire(RemindName.OrangeSuitCollection)
	RemindManager.Instance:Fire(RemindName.RedSuitCollection)
end

function ForgeData:GetZhuanzhiEquipAll()
	return self.zhuanzhi_equip or {}
end

function ForgeData:GetBaiZhanEquipAll()
	return self.baizhan_equip or {}
end

function ForgeData:GetBaiZhanEquipOrderAll()
	return self.baizhan_part_order_list or {}
end

function ForgeData:GetBaiZhanOrderCountListAll()
	return self.baizhan_order_count_list or {}
end

-- 获的某件转职装备
function ForgeData:GetZhuanzhiEquip(index)
	if not self.zhuanzhi_equip then return end
	return self.zhuanzhi_equip[index]
end

-- 获的某件百战装备
function ForgeData:GetBaiZhanEquip(index)
	if not self.baizhan_equip then return end

	return self.baizhan_equip[index]
end

function ForgeData:SetZhuanzhiEquipAllPower()
	self.zhuanzhi_equip_power = {}
	for k, v in pairs(self.zhuanzhi_equip) do
		if not v or not v.item_id then 
			return 0 
		end

		self.zhuanzhi_equip_power[k] = EquipData:GetEquipCapacityPower(v)
	end
end

function ForgeData:SetBaiZhanEquipAllPower()
	self.baizhan_equip_power = {}
	for k, v in pairs(self.baizhan_equip) do
		if not v or not v.item_id then 
			return 0 
		end

		self.baizhan_equip_power[k] = EquipData:GetEquipCapacityPower(v)
	end
end

function ForgeData:GetZhuanzhiEquipAllPower(equip_index, order)
	if self.zhuanzhi_equip_power then
		return self.zhuanzhi_equip_power[equip_index] or 0
	end
	return 0
end

function ForgeData:GetBaiZhanEquipAllPower(equip_index, order)
	if self.baizhan_equip_power then
		return self.baizhan_equip_power[equip_index] or 0
	end
	return 0
end

function ForgeData:SetIsFlushEquipPower(enable)
	self.power_flush_enable = enable
	if enable then
		self:SetZhuanzhiEquipAllPower()
	end
end

function ForgeData:SetIsFlushBaiZhanEquipPower(enable)
	self.baizhan_power_flush_enable = enable
	if enable then
		self:SetBaiZhanEquipAllPower()
	end
end

-- 获得转职装备的信息
function ForgeData:GetZhuanzhiEquipInfo(equip_index, order)
	local cfg = self.zhuanzhieuqip_info_cfg[equip_index]

	return cfg and cfg[order] or nil
end

-- 转职装备变动回调
function ForgeData:NotifyZhuanzhiDataChangeCallBack(callback, notify_count_change)
	if callback == nil then
		return
	end
	if notify_count_change then
		self.notify_data_count_change_callback_list[#self.notify_data_count_change_callback_list + 1] = callback
	else
		self.notify_data_change_callback_list[#self.notify_data_change_callback_list + 1] = callback
	end

	local count = 0
	for k, v in pairs(self.notify_data_change_callback_list) do
		count = count + 1
	end
	if count >= 30 then
		print_log(string.format("监听飞仙装备数据的地方多达%d条，请检查！", count))
	end

end
function ForgeData:UnNotifyZhuanzhiDataChangeCallBack(callback)
	if callback == nil then
		return
	end
	for k,v in pairs(self.notify_data_change_callback_list) do
		if v == callback then
			self.notify_data_change_callback_list[k] = nil
			return
		end
	end
	for k,v in pairs(self.notify_data_count_change_callback_list) do
		if v == callback then
			self.notify_data_count_change_callback_list[k] = nil
			return
		end
	end
end

-- 百战装备变动回调
function ForgeData:NotifyBaiZhanDataChangeCallBack(callback)
	if callback == nil then
		return
	end
	self.baizhan_notify_data_change_callback_list[#self.baizhan_notify_data_change_callback_list + 1] = callback

	local count = 0
	for k, v in pairs(self.baizhan_notify_data_change_callback_list) do
		count = count + 1
	end
	if count >= 30 then
		print_log(string.format("监听百战装备数据的地方多达%d条，请检查！", count))
	end

end
function ForgeData:UnNotifyBaiZhanDataChangeCallBack(callback)
	if callback == nil then
		return
	end
	for k,v in pairs(self.baizhan_notify_data_change_callback_list) do
		if v == callback then
			self.baizhan_notify_data_change_callback_list[k] = nil
			return
		end
	end
end

--传奇属性 根据类型获取传奇属性Cfg
function ForgeData:GetLegendCfgByType(type)
	return self.xianpin_cfg[type]
end

--根据武器颜色获取传奇属性
function ForgeData:GetLegendCfgByEquipColor(equip_color)
	local cfg = self.equipforge_auto_cfg.xianpin
	local tab = {}
	for k, v in pairs(cfg) do
		if v.equip_color == equip_color then
			tab[#tab + 1] = v.xianpin_type
		end
	end
	return tab
end

-- 获取装备传奇属性战斗力
function ForgeData:GetLegendAttrCapacity(equip_index)
	local equip_data = self.zhuanzhi_equip[equip_index]
	if nil == equip_data or #equip_data.param.xianpin_type_list <= 0 then 
		return 0
	end

	local attr_tab = CommonStruct.Attribute()
	for k, v in pairs(self.zhuanzhi_equip) do
		if v and v.item_id > 0 then
			local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
			local base_attr = CommonDataManager.GetAttributteByClass(item_cfg)
			attr_tab = CommonDataManager.AddAttributeAttr(attr_tab, base_attr)
		end
	end

	local legend_list = {}
	for k, v in pairs(equip_data.param.xianpin_type_list) do
		local xianpin_cfg = self:GetLegendCfgByType(v)
		if xianpin_cfg then
			legend_list[xianpin_cfg.shuxing_type] = xianpin_cfg.add_value
		end
	end

	attr_tab = self:CalcLegendAttrCapacity(attr_tab, legend_list)
	return CommonDataManager.GetCapabilityCalculation(attr_tab)
end

--	[20]  全部转职装备防御属性百分比加成
--	[21]  全部转职装备气血属性百分比加成
--	[22]  全部转职装备攻击属性百分比加成
function ForgeData:CalcLegendAttrCapacity(equip_attr, legend_list)
	return {
		["fangyu"] = math.floor((equip_attr.fang_yu or equip_attr.fangyu or 0) * (legend_list[20] and (legend_list[20] / 10000) or 0)),
		["maxhp"] = math.floor((equip_attr.max_hp or equip_attr.maxhp or 0) * (legend_list[21] and (legend_list[21] / 10000) or 0)),
		["gongji"] = math.floor((equip_attr.gong_ji or equip_attr.gongji or 0) * (legend_list[22] and (legend_list[22] / 10000) or 0)),
		 }
end

-- 背包的转职装备是否高于当前装备
function ForgeData:GetZhuanzhiEquipIsCanUp()
	local bag_list = ItemData.Instance:GetBagItemDataList()
	local equip_tab = {}
	for k, v in pairs(bag_list) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg and item_cfg.sub_type and EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type) then
			local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
			local curr_equip = self:GetZhuanzhiEquip(equip_index)
			if curr_equip then
				if curr_equip.item_id <= 0 then
					equip_tab[equip_index] = true
				else
					local bag_equip_power = EquipData.Instance:GetEquipCapacityPower(v)
					local curr_equip_power = EquipData.Instance:GetEquipCapacityPower(curr_equip)
					if bag_equip_power > curr_equip_power then
						equip_tab[equip_index] = true
					end
				end
			end
		end
	end
	return equip_tab
end

-- 获取最高能穿戴的装备
function ForgeData:GetBestEquipCfg(equip_index, role_level, role_zhuan)
	local equip_cfg = self.zhuanzhieuqip_info_cfg[equip_index]
	if not equip_cfg then return end

	local equip_info = self.zhuanzhi_equip[equip_index]
	if not equip_info or not equip_info.item_id then return end
	local equip_item_cfg = ItemData.Instance:GetItemConfig(equip_info.item_id)
	local is_shoushi = EquipData.Instance:IsZhuanzhiEquipShoushiType(equip_item_cfg.sub_type)
	if is_shoushi then
		return
	end
	
	local best_equip_cfg = {}
	for k, v in pairs(equip_cfg) do
		if not is_shoushi and role_zhuan < v.role_need_min_prof_level or role_level < v.role_need_min_level then
			break
		-- elseif is_shoushi and v.equip_order == (equip_item_cfg.order + 1) then
		-- 	best_equip_cfg = v
		-- 	break
		else
			best_equip_cfg = v
		end
	end
	return best_equip_cfg
end

--------------------------------
--------升星 ForgeUpStarView
-- 升星等级
function ForgeData:GetUpStarLevelByIndex(index)
	if not self.up_star_level_list then return end

	return self.up_star_level_list[index]
end

-- 升星经验
function ForgeData:GetUpStarExpByIndex(index)
	return self.up_star_exp_list[index]
end

function ForgeData:GetUpStarSingleCfg(equip_index, star_level)
	local cfg = self.up_star_cfg[equip_index]
	return cfg and cfg[star_level] or nil
end

function ForgeData:GetMaxUpStarLevel(equip_index)
	local cfg = self.up_star_index[equip_index]
	if nil == cfg then 
		return 0 
	end

	return cfg[#cfg].star_level
end

-- 获取最小可升级装备
function ForgeData:GetMinStarIndex()
	local min_index = -1
	local min_value = 0
	local min_level = 0
	for k, v in pairs(self.zhuanzhi_equip) do
		local temp_max = self:GetMaxUpStarLevel(v.index)
		if temp_max ~=nil then
			if temp_max > min_level then
				min_level = temp_max
			end
		end
	end
	for k, v in pairs(self.zhuanzhi_equip) do
		if nil ~= v and nil ~= v.item_id and v.item_id > 0 then
			local max_level = self:GetMaxUpStarLevel(v.index)
			local star_level = self:GetUpStarLevelByIndex(v.index)

			if star_level and max_level and star_level < max_level then
				local cfg = self:GetUpStarSingleCfg(v.index, star_level + 1)
				if star_level < min_level then
					min_level = star_level
					min_index = v.index
				end
				if cfg and cfg.need_mojing < min_value or min_value == 0 then
					min_value = cfg.need_mojing
				end
			end
		end
	end
	local mojing = ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.MOJING)
	if mojing < min_value or min_value == 0 then
		return -2
	end
	return min_index
end

function ForgeData:CheckUpStarIsCanImprove(data)
	if data and data.item_id > 0 then
		local max_level = self:GetMaxUpStarLevel(data.index)
		local star_level = self:GetUpStarLevelByIndex(data.index)
		if star_level and star_level < max_level then
			local cfg = self:GetUpStarSingleCfg(data.index, star_level + 1)
			local mojing = ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.MOJING)
			if cfg and cfg.need_mojing < mojing then
				return 0
			end
		end
	end
	return false
end

--获取当前总星星数
function ForgeData:GetNowTotalStar()
	local all_star_level = 0
	if self.up_star_level_list then
		for k, v in pairs(self.up_star_level_list) do
			if v and v > 0 then
				all_star_level = all_star_level + v
			end
		end
	end
	return all_star_level
end

--获取升星全身套装属性
function ForgeData:GetTotleStarInfo()
	local total_level = self:GetNowTotalStar()
	local total_up_star_cfg = self.zhuanzhieuqip_auto_cfg.total_upstar
	local current_cfg = {}
	local next_cfg = {}

	for k, v in pairs(total_up_star_cfg) do
		if v.total_star <= total_level then
			current_cfg = v
		else
			next_cfg = v
			break
		end
	end
	return total_level, current_cfg, next_cfg
end

--获取升星全身套装属性
function ForgeData:GetTotleStarInfoBySeq(seq)
	local total_up_star_cfg = self.zhuanzhieuqip_auto_cfg.total_upstar
	return total_up_star_cfg[seq + 1]
end

--------------------------------
--------玉石 
function ForgeData:SetZhuanzhiStoneInfo(protocol)
	self.zhuanzhi_stone_limit_list = {}
	self.jade_info = {}
	for k, v in pairs(protocol.stone_list) do
		self.zhuanzhi_stone_limit_list[k] = bit:d2b(v.slot_open_flag) or {}
		self.jade_info[k] = v
	end

	-- 玉石精髓
	self.jade_score = protocol.stone_score
end

function ForgeData:GetJadeScore()
	return self.jade_score
end

--玉石 获取装备上所有玉石格子的状态: 0、锁定 1、可镶嵌 2、已镶嵌
function ForgeData:GetEquipJadeSlotInfo(equip_index)
	local final_data = {}
	if not self.jade_info then return end
	local jade_data = self.jade_info[equip_index].slot_list or {}

	for k ,v in pairs(jade_data) do
		local temp_data = {}
		if v.stone_id == 0 then
			if self.zhuanzhi_stone_limit_list[equip_index][33 - k] == 0 then
				temp_data.jade_state = 0
			else
				temp_data.jade_state = 1
			end
		else
			temp_data.jade_state = 2
			temp_data.jade_id = v.stone_id
		end
		final_data[k] = temp_data
	end
	return final_data
end

function ForgeData:GetJadeCfg(item_id)
	return self.jade_cfg[item_id]
end

-- 获取部位对应背包能装备的玉石
function ForgeData:GetHadJadesInBag(equip_index)
	if self.jade_open_limit_cfg[equip_index] then
		local cfg = self.jade_open_limit_cfg[equip_index][1]
		return self:GetJadesInBag(cfg.stone_type_limit)
	end
end

-- 获取背包某类型的玉石
function ForgeData:GetJadesInBag(jade_type)
	local jade_tab = {}
	local bag_items = ItemData.Instance:GetBagItemDataList()
	for k, v in pairs(bag_items) do
		local cfg = self:GetJadeCfg(v.item_id)
		if cfg then
			if cfg.stone_type == jade_type then
				table.insert(jade_tab, v)
			end
		end
	end
	return jade_tab
end

-- 获取背包所有玉石
function ForgeData:GetAllJadesInBag(jade_type)
	local jade_tab = {}
	local temp_jade_tab = {}
	local count = 1
	local bag_items = ItemData.Instance:GetBagItemDataList()
	for k, v in pairs(bag_items) do
		local cfg = self:GetJadeCfg(v.item_id)
		if cfg then
			temp_jade_tab[count] = TableCopy(v)
			temp_jade_tab[count].jade_level = cfg.level
			count = count + 1
		end
	end
	table.sort(temp_jade_tab, function(a, b)
		return a.jade_level > b.jade_level
	end)

	for k, v in pairs(temp_jade_tab) do
		jade_tab[k - 1] = v
	end
	return jade_tab
end

-- 获取equip_index能装备的玉石类型
function ForgeData:GetJadeTypeByIndex(equip_index)
	local cfg = self.jade_open_limit_cfg[equip_index]
	return cfg and cfg[1].stone_type_limit
end

-- 玉石类型和等级获取玉石配置
function ForgeData:GetJadeCfgByTypeAndLevel(type, level)
	local cfg = self.jade_stone_type_level_cfg[type]
	return cfg and cfg[level]
end

--根据格子index和玉石槽index获取开启条件
function ForgeData:GetJadeOpenLimitCfg(equip_index, stone_index)
	local cfg = self.jade_open_limit_cfg[equip_index]
	if cfg then
		for k, v in pairs(cfg) do
			if stone_index == v.slot_index then
				return v
			end
		end
	end
end

-- 获取玉石升级Cfg
function ForgeData:GetJadeUpLevelCfg(item_id)
	return self.jade_up_level_cfg[item_id]
end

--玉石 获得玉石中文属性对
function ForgeData:GetJadeAttr(jade_id)
	local jade_cfg = self:GetJadeCfg(jade_id)
	local attr_list = {}
	local attr_sort = {
		["gongji"] = 1,
		["fangyu"] = 2,
		["maxhp"] = 3,
	}
	if jade_cfg then
		for i = 1, 2 do
			if jade_cfg["attr_type"..i] == nil or jade_cfg["attr_type"..i] == 0 then
				break
			else
				local data = {}
				data.attr_name = Language.Forge.GemAttrName[1][jade_cfg["attr_type"..i]] or "nil"
				data.attr_value = jade_cfg["attr_val"..i]
				data.attr_real_name = CommonDataManager.GetAttrName(jade_cfg["attr_type"..i])
				data.sort_value = attr_sort[jade_cfg["attr_type"..i]]
				table.insert(attr_list, data)
			end
		end
	end

	table.sort(attr_list, SortTools.KeyLowerSorter("sort_value"))

	return attr_list
end

function ForgeData:GetJadePowerByIndex(equip_index)
	if nil == equip_index then return end

	local attrs = {}
	local stone_infos = self.jade_info[equip_index].slot_list
	for k, v in pairs(stone_infos) do
		if v.stone_id and v.stone_id > 0 then
			local jade_cfg = self:GetJadeCfg(v.stone_id)
			if jade_cfg then
				for i = 1, 2 do
					if jade_cfg["attr_val" .. i] > 0 then
						local name = jade_cfg["attr_type" .. i]
						attrs[name] = attrs[name] and (attrs[name] + jade_cfg["attr_val" .. i]) or jade_cfg["attr_val" .. i]
					end
				end
			end
		end
	end

	return attrs
end

function ForgeData:GetAllJadePower(jade_info)
	if nil == jade_info then return end

	local attrs = {}
	for k, v in pairs(jade_info) do
		if v.stone_id and v.stone_id > 0 then
			local jade_cfg = self:GetJadeCfg(v.stone_id)
			if jade_cfg then
				for i = 1, 2 do
					if jade_cfg["attr_val" .. i] > 0 then
						local name = jade_cfg["attr_type" .. i]
						attrs[name] = attrs[name] and (attrs[name] + jade_cfg["attr_val" .. i]) or jade_cfg["attr_val" .. i]
					end
				end
			end
		end
	end

	return attrs
end

--玉石 检查装备的玉石是否能镶嵌、升级
function ForgeData:GetJadeCanImprove(data)
	if data.item_id <= 0 then return false end 

	local stone_infos = self:GetEquipJadeSlotInfo(data.index)
	if nil == stone_infos then return end

	for k, v in pairs(stone_infos) do
		local bag_had_jade = {}
		if v.jade_state ~= 0 then 
			bag_had_jade = self:GetHadJadesInBag(data.index)
		end

		if bag_had_jade and next(bag_had_jade) then
			if v.jade_state == 1 then
				return 0
			-- elseif v.jade_state == 2 then  -- 判断可合成（功能屏蔽）
			-- 	local jade_cfg = self:GetJadeCfg(v.jade_id)
			-- 	if jade_cfg then
			-- 		local level = jade_cfg.level
			-- 		local next_cfg = self:GetJadeCfgByTypeAndLevel(jade_cfg.stone_type, level + 1)
			-- 		local up_jade_cfg = self:GetJadeUpLevelCfg(v.jade_id)
			-- 		if nil ~= next_cfg and nil ~= up_jade_cfg then
			-- 			local upgrade_need_energy = math.pow(up_jade_cfg.need_num, level) - math.pow(up_jade_cfg.need_num, level - 1)
			-- 			local had_energy = 0
			-- 			for k2, v2 in pairs(bag_had_jade) do
			-- 				if v2.item_id <= jade_cfg.item_id then
			-- 					local temp_up_jade_cfg = self:GetJadeUpLevelCfg(v2.item_id)
			-- 					local temp_jade_cfg = self:GetJadeCfg(v2.item_id)
			-- 					if temp_up_jade_cfg then
			-- 						had_energy = had_energy + (math.pow(temp_up_jade_cfg.need_num, temp_jade_cfg.level - 1) * v2.num)
			-- 					end
			-- 				end
			-- 			end
			-- 			if had_energy >= upgrade_need_energy then
			-- 				return 0
			-- 			end
			-- 		end
			-- 	end
			-- end
			elseif v.jade_state == 2 then -- 可更换更高级玉石
				for k2, v2 in pairs(bag_had_jade) do
					if v.jade_id < v2.item_id then
						return 0
					end
				end
			end
		end
	end
	return false
end

-- 获得玉石总等级
function ForgeData:GetJadeTotalLevel()
	if not self.jade_info then return end
	
	local total_level = 0
	for k, v in pairs(self.jade_info) do
		for k1, v1 in pairs(v.slot_list) do
			if v1.stone_id and v1.stone_id > 0 then
				local jade_cfg = self:GetJadeCfg(v1.stone_id)
				if jade_cfg then
					total_level = total_level + jade_cfg.level
				end
			end
		end
	end
	return total_level
end

--玉石 全身玉石等级配置
function ForgeData:GetTotalJadeCfg()
	local total_level = self:GetJadeTotalLevel() or 0
	local total_jade_cfg = self.zhuanzhieuqip_auto_cfg.total_stone
	local current_cfg = {}
	local next_cfg = {}

	for k,v in pairs(total_jade_cfg) do
		if v.total_stone_level <= total_level then
			current_cfg = v
		else
			next_cfg = v
			break
		end
	end
	return total_level, current_cfg, next_cfg
end

--玉石 分解
function ForgeData:GetJadeResolveCfg(item_id)
	local cfg = self.zhuanzhieuqip_auto_cfg.stone_resolve
	for k, v in pairs(cfg) do
		if v.stone_id == item_id then
			 return v.resolve_get_score
		end
	end
end

--玉石 兑换
function ForgeData:GetJadeConvertCfg()
	return self.zhuanzhieuqip_auto_cfg.stone_convert
end

--------------------------------
--------玉石精炼
function ForgeData:GetEquipJadeInfo(equip_index)
	if not self.jade_info then return end

	return self.jade_info[equip_index]
end

function ForgeData:GetJadeRefineCfg(refine_level)
	if not self.jade_refine_cfg then return end
	
	return self.jade_refine_cfg[refine_level]
end

function ForgeData:GetJadeRefineMaterialCfg(equip_index)
	return self.jade_refine_material_cfg[equip_index]
end

function ForgeData:GetJadeRefineMaxLevel()
	local cfg = self.zhuanzhieuqip_auto_cfg.stone_refine
	return cfg and cfg[#cfg].refine_level
end

function ForgeData:GetJadeRefineCanImprove(data)
	if not self.jade_info or data.item_id <= 0 then return false end

	local jade_info = self.jade_info[data.index]
	if not jade_info then return false end

	local max_levle = self:GetJadeRefineMaxLevel()
	if max_levle <= jade_info.refine_level then
		return false
	end

	local refine_cfg = self.jade_refine_cfg[jade_info.refine_level]
	local material_cfg = self.jade_refine_material_cfg[data.index]
	local need_refine_val = refine_cfg.consume_refine_val - jade_info.refine_val
	local had_refine_val = 0
	for k, v in pairs(material_cfg) do
		local material_num = ItemData.Instance:GetItemNumInBagById(v.stuff_id)
		had_refine_val = had_refine_val + (v.add_refine * material_num)
		if had_refine_val >= need_refine_val then
			return 0
		end
	end
	return false
end

--------------------------------
--------附灵(转职装强化)
function ForgeData:SetSCEquipBaptizeAllInfo(protocol)
	self.clear_part_info_list = protocol.part_info_list
	self.clear_open_flag_list = {}
	for k, v in pairs(protocol.open_flag) do
		self.clear_open_flag_list[k] = bit:d2b(v)
	end
	self.clear_lock_flag_list = {}
	for k, v in pairs(protocol.lock_flag) do
		self.clear_lock_flag_list[k] = bit:d2b(v)
	end
	self.clear_used_free_times = protocol.used_free_times
end

function ForgeData:GetClearPartInfo(equip_index)
	return self.clear_part_info_list and self.clear_part_info_list[equip_index] or {}
end

function ForgeData:GetOpenSlotFlag(equip_index)
	return self.clear_open_flag_list and self.clear_open_flag_list[equip_index] or {}
end

function ForgeData:GetLockSlotFlag(equip_index)
	return self.clear_lock_flag_list and self.clear_lock_flag_list[equip_index] or {}
end

-- 获取高级洗练Item
function ForgeData:GetHighClearItem()
	local tab = {}
	local cfg = self.equip_baptize_cfg.lock_consume
	if cfg and cfg[1] then
		local purple_count = ItemData.Instance:GetItemNumInBagById(cfg[1].purple_stuff_id)
		local orange_count = ItemData.Instance:GetItemNumInBagById(cfg[1].orange_stuff_id)
		local red_count = ItemData.Instance:GetItemNumInBagById(cfg[1].red_stuff_id)
		if purple_count > 0 then
			table.insert(tab, {item_id = cfg[1].purple_stuff_id, color_seq = EQUIP_BAPTIZE_SPECIAL_TYPE.EQUIP_BAPTIZE_SPECIAL_TYPE_PURPLE, count = purple_count})
		else
			table.insert(tab, {item_id = cfg[1].purple_stuff_id, color_seq = EQUIP_BAPTIZE_SPECIAL_TYPE.EQUIP_BAPTIZE_SPECIAL_TYPE_PURPLE})
		end
		if orange_count > 0 then
			table.insert(tab, {item_id = cfg[1].orange_stuff_id, color_seq = EQUIP_BAPTIZE_SPECIAL_TYPE.EQUIP_BAPTIZE_SPECIAL_TYPE_ORANGE, count = orange_count})
		end
		if red_count > 0 then
			table.insert(tab, {item_id = cfg[1].red_stuff_id, color_seq = EQUIP_BAPTIZE_SPECIAL_TYPE.EQUIP_BAPTIZE_SPECIAL_TYPE_RED, count = red_count})
		end
	end
	return tab
end

-- 锁定数量洗练消耗
function ForgeData:GetLockNumConsumeCfg(lock_num)
	local cfg = self.equip_baptize_cfg.lock_consume
	for k, v in pairs(cfg) do
		if v.lock_num == lock_num then
			return v
		end
	end
	return cfg[1]
end

-- 开启洗炼槽消耗
function ForgeData:OpenLockConsume(index)
	local cfg = self.equip_baptize_cfg.baptize_consume
	for k, v in pairs(cfg) do
		if v.index == index then
			return v.consume_gold
		end
	end
	return 0
end

function ForgeData:GetClearAttrBySeq(seq)
	return self.baptize_attr_cfg[0][seq]
end

function ForgeData:GetClearAttrColorSeq(seq, attr_value)
	local attr_cfg = self.baptize_attr_cfg[0][seq]
	if attr_cfg then
		local attr_limit = {
			[0] = "white_value_low",
			[1] = "blue_value_low",
			[2] = "purple_value_low",
			[3] = "orange_value_low",
			[4] = "red_value_low",
		}

		local color_index = 1
		for k, v in pairs(attr_limit) do
			if attr_value >= attr_cfg[v] then
				color_index = k
			else
				break
			end
		end
		return color_index
	end
	return 1
end

-- 返回第二个参数为 next_cfg/是否满级（true是满级，false是没激活）
function ForgeData:GetClearSuitCfg(equip_index, color_list)
	local part_list = self.baptize_suit_cfg[equip_index]
	if part_list then
		local color = 5
		local attr_num = 0
		for k, v in pairs(color_list) do
			attr_num = attr_num + 1
			if v < color then
				color = v
			end
		end

		local curr_suit = {}
		local suit_seq = 0
		for k, v in pairs(part_list) do
			suit_seq = suit_seq + 1
			if v.baptize_color == color and v.baptize_count == attr_num then
				curr_suit = v
				break
			end
		end

		if not next(curr_suit) then
			curr_suit = part_list[1]
			return curr_suit, false
		else
			local next_suit = part_list[suit_seq + 1]
			if not next_suit then
				return curr_suit, true
			else
				return curr_suit, next_suit
			end
		end
	end

	return {}
end

function ForgeData:GetDeityIntersifyCanImprove(data)
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if not item_cfg then return false end	

	local open_flag_list = ForgeData.Instance:GetOpenSlotFlag(data.index)
	local lock_flag_list = ForgeData.Instance:GetLockSlotFlag(data.index)

	local lock_num = 0
	for i = 1, 3 do
		local open_flag = open_flag_list and open_flag_list[33 - i] or 0
		local lock_flag = lock_flag_list and lock_flag_list[33 - i] or 0
		if open_flag == 1 and lock_flag == 1 then
			lock_num = lock_num + 1
		end
	end

	local lock_cfg = self:GetLockNumConsumeCfg(lock_num)
	if lock_cfg then
		local had_material = ItemData.Instance:GetItemNumInBagById(lock_cfg.consume_stuff_id)
		local need_material = lock_cfg.consume_stuff_num
		if had_material >= need_material then
			return 0
		else
			return false
		end
	else
		return false
	end
end

--[[ 	原附灵-改洗练
-- 获取装备附灵data
function ForgeData:GetFulingData(equip_index)
	return self.fuling_count_list[equip_index]
end

-- 附灵材料
function ForgeData:GetFulingCfg(equip_order)
	local cfg =  self.zhuanzhieuqip_auto_cfg.equip_fuling
	return cfg and cfg[equip_order]
end

-- 附灵材料
function ForgeData:GetFulingMaterial()
	return self.zhuanzhieuqip_auto_cfg.fuling_stuff
end

function ForgeData:GetDeityIntersifyCanImprove(data)
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if not item_cfg then return end

	local fuling_cfg = ForgeData.Instance:GetFulingCfg(item_cfg.order)
	local material_cfg = self:GetFulingMaterial()
	if fuling_cfg and material_cfg then
		for i, v in ipairs(material_cfg) do
			local max_val = v.add_attr_val * fuling_cfg.fuling_max_count
			local had_val = v.add_attr_val * self.fuling_count_list[data.index][i]
			local num = ItemData.Instance:GetItemNumInBagById(v.stuff_id)
			if had_val < max_val and num > 0 then
				return 0
			end
		end
	end
	return false
end
]]


--------------------------------
--------转职套装
function ForgeData:SetZhuanzhiSuitInfo(protocol)
	self.part_suit_type_list = protocol.part_suit_type_list
	self.part_order_list = protocol.part_order_list
	if next(self.forge_deity_suit) then
		self:ChangeInlaySuccess(self.part_suit_type_list, self.forge_deity_suit)
	end
end

function ForgeData:GetZhuanzhiSuitInfo()
	return self.part_suit_type_list, self.part_order_list
end

-- 获取装备的套装类型
function ForgeData:GetZhuanzhiSuitType(equip_index)
	return self.part_suit_type_list[equip_index]
end

-- 获取装备的阶数
function ForgeData:GetZhuanzhiSuitOrder(equip_index)
	return self.part_order_list[equip_index]
end

-- 获取装备的套装攻防属性类型配置
function ForgeData:GetZhuanzhiSuitAttrType(equip_index)
	local cfg = self.zhuanzhieuqip_auto_cfg.suit_group_type
	return cfg[equip_index + 1]
end

-- 获取装备的套装类型配置
function ForgeData:GetZhuanzhiSuitTypeCfg(equip_index, suit_index, equip_order)
	local prof = PlayerData.Instance:GetRoleBaseProf()
	if not self.suit_type_cfg or not self.suit_type_cfg[prof] or not self.suit_type_cfg[prof][equip_index] 
		or not self.suit_type_cfg[prof][equip_index][suit_index] then
		return
	end
	
	local min_order = self:GetSuitMinOrder(suit_index)
	equip_order = equip_order < min_order and min_order or equip_order
	return self.suit_type_cfg[prof][equip_index][suit_index][equip_order]
end

-- 获取装备属性列表
function ForgeData:GetSuitAttrList(equip_index, suit_index, equip_order)
	local cfg = self:GetZhuanzhiSuitAttrType(equip_index)
	if not cfg then return end

	if cfg.group_type == 0 then
		return self:GetSuitFangAttrList(suit_index, equip_order)
	elseif cfg.group_type == 1 then
		return self:GetSuitGongAttrList(suit_index)
	end
end

-- 攻套装属性
function ForgeData:GetSuitGongAttrList(suit_index)
	if not self.suit_attr_gong_cfg or not self.suit_attr_gong_cfg[suit_index] then
		return
	end

	return self.suit_attr_gong_cfg[suit_index]
end

-- 防套装属性
function ForgeData:GetSuitFangAttrList(suit_index, equip_order)
	local prof = PlayerData.Instance:GetRoleBaseProf()
	if not self.suit_attr_fang_cfg or not self.suit_attr_fang_cfg[prof] or not self.suit_attr_fang_cfg[prof][suit_index] then
		return
	end

	local min_order = self:GetSuitMinOrder(suit_index)
	equip_order = equip_order < min_order and min_order or equip_order
	return self.suit_attr_fang_cfg[prof][suit_index][equip_order]
end

-- 通过阶数和数量获取百战套装属性
function ForgeData:GetBaiZhanAttrListByOrderAndNum(equip_order, num)
	local same_order_num = 0
	if num >= 10 then
		same_order_num = 10
	elseif num >= 5 then
		same_order_num = 5
	elseif num >= 2 then
		same_order_num = 2
	else
		same_order_num = num		
	end
	if self.baizhanequip_suit_attr_cfg[equip_order] and self.baizhanequip_suit_attr_cfg[equip_order][same_order_num] then
		return self.baizhanequip_suit_attr_cfg[equip_order][same_order_num]
	end
end

-- 通过阶数获取百战套装属性
function ForgeData:GetBaiZhanAttrListByOrder(equip_order)
	if self.baizhanequip_suit_attr_cfg[equip_order] then
		local final_list = {}
		for i, v in pairs(self.baizhanequip_suit_attr_cfg[equip_order]) do
			table.insert(final_list, v)
		end
		if final_list and next(final_list) then
			table.sort(final_list, SortTools.KeyLowerSorter("same_order_num"))
		end
		return final_list
	end
end

-- 通过阶数获取百战套装名字
function ForgeData:GetBaiZhanNameListByOrder(order)
	if self.baizhanequip_suit_name_cfg[order] and self.baizhanequip_suit_name_cfg[order].name then
		return self.baizhanequip_suit_name_cfg[order].name
	end
end

function ForgeData:GetBaiZhanListMaxOrder()
	if #self.baizhanequip_suit_name_cfg > 0 and self.baizhanequip_suit_name_cfg[#self.baizhanequip_suit_name_cfg] and self.baizhanequip_suit_name_cfg[#self.baizhanequip_suit_name_cfg].order then
		return self.baizhanequip_suit_name_cfg[#self.baizhanequip_suit_name_cfg].order
	end
end

function ForgeData:GetBaiZhanSuitInfoByOrder(order)
	local suit_list = {}
	if self.baizhan_suit_info ~= nil then
		for k, v in pairs(self.baizhan_suit_info) do
			if order == v.equip_order then
				table.insert(suit_list, v)
			end
		end
	end
	return suit_list
end

function ForgeData:GetBaiZhanInfoByOrderPart(order, equip_part)
	if self.baizhan_suit_info ~= nil then
		for k, v in pairs(self.baizhan_suit_info) do
			if order == v.equip_order and equip_part == v.equip_part then
				return v 
			end
		end
	end
	return {}
end

function ForgeData:GetBaiZhanSuit()
	-- print_error(self.baizhan_suit)
	return self.baizhan_suit
end

function ForgeData:GetBaiZhanLevelUpCfgByOldId(new_equip_item_id)
	if self.baizhanequip_level_up_old_cfg and self.baizhanequip_level_up_old_cfg[new_equip_item_id] then
		return self.baizhanequip_level_up_old_cfg[new_equip_item_id]
	end
end

function ForgeData:GetBaiZhanLevelUpCfgByPartAndOldId(part, old_equip_item_id)
	if self.baizhanequip_level_up_part_cfg and self.baizhanequip_level_up_part_cfg[part] and self.baizhanequip_level_up_part_cfg[part][old_equip_item_id] then
		return self.baizhanequip_level_up_part_cfg[part][old_equip_item_id]
	end
end

function ForgeData:GetBaiZhanLevelUpCfgByPartAndOrder(part, order)
	local need_stuff_id = 0
	if order and order <= 4 and order >= 1 then
		need_stuff_id = 27274
	end
	if order and order <= 8 and order >= 6 then
		need_stuff_id = 27275
	end
	if self.baizhanequip_level_up_part_cfg and self.baizhanequip_level_up_part_cfg[part] then
		local final_list = {}
		for i, v in pairs(self.baizhanequip_level_up_part_cfg[part]) do
			if need_stuff_id == v.need_stuff_id then
				table.insert(final_list, v)
			end
		end
		if final_list and next(final_list) then
			table.sort(final_list, SortTools.KeyUpperSorter("stuff_num"))
		end		
		return final_list
	end
	return {}
end

-- 最小可套装阶数
function ForgeData:GetSuitMinOrder(suit_index)
	local cfg = self.zhuanzhieuqip_auto_cfg.suit_forge_limit
	for k, v in pairs(cfg) do
		if v.suit_index == suit_index then
			return v.suit_min_order, v.suit_min_color
		end
	end
	return 6, 6
end

-- 套装合成件数
function ForgeData:GetSuitCount(equip_index, suit_type, equip_order)
	local cfg = self.zhuanzhieuqip_auto_cfg.suit_group_type
	local equip_attr_type = cfg[equip_index + 1]
	local suit_total_count = 0
	local suit_had_count = 0
	for k, v in pairs(cfg) do
		if equip_attr_type.group_type == v.group_type then
			suit_total_count = suit_total_count + 1
			if self:GetZhuanzhiSuitType(v.equip_index) == suit_type and self:GetZhuanzhiSuitOrder(v.equip_index) == equip_order then
				suit_had_count = suit_had_count + 1
			end
		end
	end
	return suit_total_count, suit_had_count
end

-- 套装合成件数(查看角色的信息)
function ForgeData:GetCheckRoleInfoSuitCount(equip_index, suit_type, equip_order, type_list, order_list)
	if not type_list or not order_list then
		return
	end
	local cfg = self.zhuanzhieuqip_auto_cfg.suit_group_type
	local equip_attr_type = cfg[equip_index + 1]
	local suit_total_count = 0
	local suit_had_count = 0
	for k, v in pairs(cfg) do
		if equip_attr_type.group_type == v.group_type then
			suit_total_count = suit_total_count + 1
			if type_list[v.equip_index] == suit_type and order_list[v.equip_index] == equip_order then
				suit_had_count = suit_had_count + 1
			end
		end
	end
	return suit_total_count, suit_had_count
end

function ForgeData:GetDeitySuitCanImprove(data)
	if not self.part_suit_type_list or not data.index or not self.part_suit_type_list[data.index] then return false end

	if self.part_suit_type_list[data.index] >= 1 then return false end 	-- 最高套装（诛神）

	for i = 0, 1 do
		if 1 == i and self.part_suit_type_list[data.index] < 0 then
			return false
		end
		if self.part_suit_type_list[data.index] ~= i then
			local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
			if item_cfg then
				local cfg = self:GetZhuanzhiSuitTypeCfg(data.index, i, item_cfg.order)
				local min_order, min_color = ForgeData.Instance:GetSuitMinOrder(i)
				if cfg and item_cfg.order >= min_order and item_cfg.color >= min_color then
					local need_material = 0
					local had_material = 0
					for i = 1, 3 do
						if cfg["stuff_" .. i .. "_id"] > 0 then
							local material_num = ItemData.Instance:GetItemNumInBagById(cfg["stuff_" .. i .. "_id"])
							need_material = need_material + 1
							if material_num >= cfg["stuff_" .. i .. "_num"] then
								had_material = had_material + 1
							end
						end
					end
					if need_material == had_material then
						return 0
					end
				end
			end
		end
	end
	return false
end

function ForgeData:GetJueXingCanImprove(data)
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if not item_cfg then return false end	

	-- 转职装备觉醒S特效个数
	local s_num = 0
	for i=1, GameEnum.MAX_ZHUANZHI_EQUIP_AWAKENING_COUNT do
		local is_show_s = ForgeData.Instance:LeftJueXingLevelIsMax(data.index, i)

		if is_show_s then
			s_num = s_num + 1
		end
	end
	local equip_order = self:GetZhuanzhiEquipJieShu(data.index)
	local max_equip_order, color = ForgeData.Instance:GetMaxJueXingJieShu()
	local equip_color = ForgeData.Instance:GetZhuanzhiEquipColor(data.index)
	if equip_color < color then
		return false
	end
	local max_equip_order = self:GetMaxJueXingJieShu()
	if equip_order < max_equip_order then
		return false
	end

	if s_num < 3 then
		local lock_num = ForgeData.Instance:JueXingShuXingLockNum(data.index)
		local lock_cfg = self:GetJueXingShuXingLockCfg(lock_num)
		if lock_cfg then
			local had_material = ItemData.Instance:GetItemNumInBagById(lock_cfg.consume_stuff_id)
			local need_material = lock_cfg.consume_stuff_num_1
			if had_material >= need_material then
				return 0
			else
				return false
			end
		else
			return false
		end
	end
	return false
end

function ForgeData:GetDeitySuitAllAttr()
	if not self.zhuanzhi_equip then return end

	local fangyu_suit = {}
	local gongji_suit = {}
	local zhizun_suit = {}
	for k, v in pairs(self.zhuanzhieuqip_auto_cfg.suit_group_type) do
		if v.group_type == 0 then
			fangyu_suit[v.equip_index] = v.equip_index
		elseif v.group_type == 1 then
			gongji_suit[v.equip_index] = v.equip_index
		else
			zhizun_suit[v.equip_index] = v.equip_index
		end
	end

	-- 如果凑齐阶数属性就保存进去
	local had_order_fangyu_suit = {}
	local had_order_gongji_suit = {}
	local had_order_zhizun_suit = {}

	local fangyu_attr = {}
	local gongji_attr = {}
	local zhizun_attr = {}
	for k, v in pairs(self.zhuanzhi_equip) do
		local suit_type = self:GetZhuanzhiSuitType(v.index)
		local equip_order = self:GetZhuanzhiSuitOrder(v.index)
		if v and v.item_id and v.item_id > 0 then
			local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
			local min_order, min_color = self:GetSuitMinOrder(suit_type)
			if suit_type >= 0 and equip_order >= min_order and item_cfg.color >= min_color then
				if fangyu_suit[v.index] then
					if not had_order_fangyu_suit[equip_order] then
						local suit_cfg = self:GetSuitFangAttrList(suit_type, equip_order)
						local suit_total_count, suit_had_count = self:GetSuitCount(v.index, suit_type, equip_order)
						for k2, v2 in pairs(suit_cfg) do
							if suit_had_count >= v2.same_order_num then
								table.insert(fangyu_attr, v2)
								had_order_fangyu_suit[v2.equip_order] = true
							end
						end
					end
				elseif gongji_suit[v.index] then
					if not had_order_gongji_suit[suit_type] then
						local suit_cfg = self:GetSuitGongAttrList(suit_type)
						local suit_total_count, suit_had_count = self:GetSuitCount(v.index, suit_type, equip_order)
						for k2, v2 in pairs(suit_cfg) do
							if suit_had_count >= v2.same_order_num then
								local attr = TableCopy(v2)
								attr.equip_order = equip_order
								table.insert(gongji_attr, attr)
								had_order_gongji_suit[v2.suit_index] = true
							end
						end					
					end
				end
			else
				local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
				if not had_order_zhizun_suit[item_cfg.order] then
					local cfg = self:GetZhiZunAttrCfg(item_cfg.order)
					if cfg then
						local is_active = self:GetIsGetZhiZunAttr(item_cfg.order)
						if is_active then
							table.insert(zhizun_attr, cfg)
							had_order_zhizun_suit[item_cfg.order] = true
						end
					end
				end
			end
		end
	end
	return fangyu_attr, gongji_attr, zhizun_attr
end

--------------------------------
--------转职至尊套装
-- 至尊合成配置
function ForgeData:GetExtremeSuitCfg()
	local prof = PlayerData.Instance:GetRoleBaseProf()
	local wuqi_cfg = self.extreme_suit_cfg[prof]
	local hufu_cfg = self.extreme_suit_cfg[5]
	local tab = {}
	if wuqi_cfg and hufu_cfg then
		for k, v in pairs(wuqi_cfg) do
			tab[k] = {}
			tab[k][1] =	v
			if hufu_cfg[k] then
				tab[k][2] = hufu_cfg[k]
			end
		end
	end
	return tab
end

-- 至尊装备配置
function ForgeData:GetZhiZunEquipCfg(item_id)
	return self.zhizun_equipment_cfg[item_id]
end

-- 至尊套装属性配置
function ForgeData:GetZhiZunAttrCfg(order)
	return self.zhizun_attr_cfg[order]
end

-- 获得阶数是否激活至尊套装
function ForgeData:GetIsGetZhiZunAttr(order)
	local wuqi = self:GetZhuanzhiEquip(0)
	local hufu = self:GetZhuanzhiEquip(9)
	local wuqi_order = 0
	local hufu_order = 0
	if wuqi and wuqi.item_id > 0 and self.zhizun_equipment_cfg[wuqi.item_id] then
		local item_cfg = ItemData.Instance:GetItemConfig(wuqi.item_id)
		wuqi_order = item_cfg.order
	end
	if hufu and hufu.item_id > 0 and self.zhizun_equipment_cfg[hufu.item_id] then
		local item_cfg = ItemData.Instance:GetItemConfig(hufu.item_id)
		hufu_order = item_cfg.order
	end

	return (wuqi_order == order and hufu_order == order)
end

-- 获取特殊转职装备配置
function ForgeData:GetSpecialEquipCfg(item_id)
	return self.special_equip_id_cfg[item_id]
end

function ForgeData:SetForgeDeitySuitCfg()
	self.forge_deity_suit = self.part_suit_type_list
end

function ForgeData:GetForgeDeitySuitCfg()
	return self.forge_deity_suit
end


function ForgeData:ChangeInlaySuccess(list_1, list_2)
	local is_equil = false
	for k,v in pairs(list_1) do
		if v ~= list_2[k] and (v == 0 or v == 1) then
			is_equil = true
		end
	end
	self.is_inlay_success = is_equil
end

function ForgeData:SetChangeInlaySuccess(is_success)
	 self.is_inlay_success = is_success
end

function ForgeData:GetChangeInlaySuccess()
	return self.is_inlay_success
end


--------------觉醒装备(equip_index[0-9], jue_xing_index[1-3])-----------------------
function ForgeData:SetZhuanzhiEquipAwakeningAllInfo(protocol)
	self.zhuanzhi_all_equip_awakening_lock_flag = bit:uc2b(protocol.zhuanzhi_all_equip_awakening_lock_flag) or {}
	self.zhuanzhi_all_equip_awakening_list = protocol.zhuanzhi_all_equip_awakening_list or {}
end

function ForgeData:SetZhuanzhiEquipAwakeningInfo(protocol)
	self.zhuanzhi_equip_index = protocol.zhuanzhi_equip_index or 0
	-- self.zhuanzhi_all_equip_awakening_lock_flag = bit:uc2b(protocol.zhuanzhi_equip_awakening_lock_flag) or {}
	self.zhuanzhi_all_equip_awakening_list[self.zhuanzhi_equip_index] = {}
	self.zhuanzhi_all_equip_awakening_list[self.zhuanzhi_equip_index] = protocol.zhuanzhi_equip_awakening_list
	self.zhuanzhi_all_equip_awakening_lock_flag = bit:uc2b(protocol.zhuanzhi_equip_awakening_lock_flag) or {}
end


function ForgeData:GetZhuanzhiEquipAwakeningAllInfo()
	return self.zhuanzhi_all_equip_awakening_list
end

function ForgeData:JunXingFakeAllInfo(index)
	local fake_equimentatt = {}
	local vo = {}
	local max_level = ForgeData.Instance:GetJueXingMaxLevelByIndex(index)
	local good_attr_list = ForgeData.Instance:GetJueXingGoodAttrByIndex(index)
	local good_attr_list_cfg = ForgeData.Instance:GetJueXingGoodAttrCfg(good_attr_list, max_level)
	local max_level = ForgeData.Instance:GetJueXingMaxLevelByIndex(index)
	for i = 1, GameEnum.MAX_ZHUANZHI_EQUIP_AWAKENING_COUNT do
		vo[i] = {}
		vo[i].type = good_attr_list_cfg[i].type
		vo[i].level = max_level
	end
	fake_equimentatt = vo 
	return fake_equimentatt
end

function ForgeData:GetZhuanzhiEquipAwakeningAllInfoByIndex(equip_index)
	return self.zhuanzhi_all_equip_awakening_list[equip_index]
end

function ForgeData:GetLeftEquipAwakeningAllInfoByIndex(equip_index)
	local info = self.zhuanzhi_all_equip_awakening_list[equip_index]
	return info and info.awakening_in_equip or nil
end

function ForgeData:IsHasEquipAllShuXingInfo(equip_index, jue_xing_index)
	local zhuanzhi_all_equip_awakening_list = self:GetZhuanzhiEquipAwakeningAllInfoByIndex(equip_index)
	if zhuanzhi_all_equip_awakening_list then
		local equip_list_info = zhuanzhi_all_equip_awakening_list.awakening_in_equip
		for k,v in pairs(equip_list_info) do
			if k == jue_xing_index and v.type == 0 and v.level == 0 then
				return true
			end
		end
	end
	return false
end

function ForgeData:IsHasDisplacementAllShuXingInfo(equip_index, jue_xing_index)
	local zhuanzhi_all_equip_awakening_list = self:GetZhuanzhiEquipAwakeningAllInfoByIndex(equip_index)
	
	if zhuanzhi_all_equip_awakening_list then
		local equip_list_info = zhuanzhi_all_equip_awakening_list.awakening_in_displacement
		for k,v in pairs(equip_list_info) do
			if k == jue_xing_index and v.type == 0 and v.level == 0 then
				return true
			end
		end
	end
	return false
end

function ForgeData:IsLockJueXingShuXing(equip_index, jue_xing_index)
	local zhuanzhi_equip_awakening_lock_flag = self.zhuanzhi_all_equip_awakening_lock_flag
	if zhuanzhi_equip_awakening_lock_flag then
		local equip_lock_flag = zhuanzhi_equip_awakening_lock_flag[(jue_xing_index - 1) + equip_index * 3]
		if equip_lock_flag == 1 then
			return true
		end
	end
	return false
end

function ForgeData:JueXingShuXingLockNum(equip_index)
	local lock_num = 0
	for i=1, GameEnum.MAX_ZHUANZHI_EQUIP_AWAKENING_COUNT do
		local is_lock = self:IsLockJueXingShuXing(equip_index, i)
		if is_lock then
			lock_num = lock_num + 1
		end
	end
	return lock_num
end

function ForgeData:JueXingShuXingMaxNum(equip_index)
	local max_num = 0
	for i=1, GameEnum.MAX_ZHUANZHI_EQUIP_AWAKENING_COUNT do
		local is_left_max = self:LeftJueXingLevelIsMax(equip_index, i)
		if is_left_max then
			max_num = max_num + 1
		end
	end
	return max_num
end

function ForgeData:GetJueXingShuXingLockCfg(lock_num)
	local lock_cfg = self.zhuanzhieuqip_auto_cfg.lock_consume
	for k,v in pairs(lock_cfg) do
		if v.lock_num == lock_num then
			return v
		end
	end
	return lock_cfg[1]
end

function ForgeData:GetZhuanzhiEquipJieShu(equip_index)
	local equip_list = self:GetZhuanzhiEquip(equip_index)
	if equip_list then
		local item_cfg = ItemData.Instance:GetItemConfig(equip_list.item_id)
		return item_cfg and item_cfg.order or 0
	end
end

function ForgeData:GetZhuanzhiEquipColor(equip_index)
	local equip_list = self:GetZhuanzhiEquip(equip_index)
	if equip_list then
		local item_cfg = ItemData.Instance:GetItemConfig(equip_list.item_id)
		return item_cfg and item_cfg.color or 0
	end
end

function ForgeData:LeftJueXingLevelIsMax(equip_index, jue_xing_index)
	local equip_order = self:GetZhuanzhiEquipJieShu(equip_index)
	local wake_level_limit_cfg = self.zhuanzhieuqip_auto_cfg.wake_level_limit_cfg or {}

	local zhuanzhi_all_equip_awakening_list = self:GetZhuanzhiEquipAwakeningAllInfoByIndex(equip_index)
	if zhuanzhi_all_equip_awakening_list then
		local left_equip_attr_info = zhuanzhi_all_equip_awakening_list.awakening_in_equip

		for k,v in pairs(wake_level_limit_cfg) do
			if v.equip_grade == equip_order then
				local max_level = v.max_level
				for k,v in pairs(left_equip_attr_info) do
					if k == jue_xing_index and v.level >= max_level then
						return true
					end
				end
			end
		end
	end
		
	return false
end

-- 是否满级并且显示S
function ForgeData:LeftJueXingLevelIsMax2(equip_index, jue_xing_index)
	local equip_order = self:GetZhuanzhiEquipJieShu(equip_index)
	local wake_level_limit_cfg = self.zhuanzhieuqip_auto_cfg.wake_level_limit_cfg or {}
	local good_attr_list = self:GetJueXingGoodAttrByIndex2(equip_index) or {}
	local juexing_type = self:LeftJueXingTypeAndLevelByIndex(equip_index, jue_xing_index)

	local zhuanzhi_all_equip_awakening_list = self:GetZhuanzhiEquipAwakeningAllInfoByIndex(equip_index)
	if zhuanzhi_all_equip_awakening_list then
		local left_equip_attr_info = zhuanzhi_all_equip_awakening_list.awakening_in_equip

		for k,v in pairs(wake_level_limit_cfg) do
			if v.equip_grade == equip_order then
				local max_level = v.max_level
				for k,v in pairs(left_equip_attr_info) do
					if k == jue_xing_index and v.level >= max_level and good_attr_list[juexing_type] then
						return true
					end
				end
			end
		end
	end
		
	return false
end

function ForgeData:GetJueXingLevelIsMax(equip_order, level)
	local wake_level_limit_cfg = self.zhuanzhieuqip_auto_cfg.wake_level_limit_cfg or {}
	
	for k,v in pairs(wake_level_limit_cfg) do
		if v.equip_grade == equip_order and v.max_level == level then
			return true
		end
	end

	return false
end


function ForgeData:RightJueXingLevelIsMax(equip_index, jue_xing_index)
	local equip_order = self:GetZhuanzhiEquipJieShu(equip_index)
	local wake_level_limit_cfg = self.zhuanzhieuqip_auto_cfg.wake_level_limit_cfg or {}

	local zhuanzhi_all_equip_awakening_list = self:GetZhuanzhiEquipAwakeningAllInfoByIndex(equip_index)
	if zhuanzhi_all_equip_awakening_list then
		local right_equip_attr_info = zhuanzhi_all_equip_awakening_list.awakening_in_displacement
		for k,v in pairs(wake_level_limit_cfg) do
			if v.equip_grade == equip_order then
				local max_level = v.max_level
				for k,v in pairs(right_equip_attr_info) do
					if k == jue_xing_index and v.level == max_level then
						return true
					end
				end
			end
		end
	end
	
	return false
end

function ForgeData:LeftJueXingTypeAndLevelByIndex(equip_index, jue_xing_index)
	if next(self.zhuanzhi_all_equip_awakening_list) then
		if self.zhuanzhi_all_equip_awakening_list[equip_index] then
			local curr_equip_info = self.zhuanzhi_all_equip_awakening_list[equip_index].awakening_in_equip or {}
			for k,v in pairs(curr_equip_info) do
				if k == jue_xing_index then
					return v.type, v.level
				end
			end
		end
	end
	return 0, 0
end


function ForgeData:IsZhenXiAttrByIndex(equip_index, jue_xing_index)
	local juexing_type, _ = self:LeftJueXingTypeAndLevelByIndex(equip_index, jue_xing_index)
	local wake_type_weight_cfg = self.zhuanzhieuqip_auto_cfg.wake_type_weight or {}
	for k,v in pairs(wake_type_weight_cfg) do
		if v.type == juexing_type and v.is_zhenxi == 1 then
			return true
		end
	end
	return false
end

function ForgeData:RightJueXingTypeAndLevelByIndex(equip_index, jue_xing_index)
	if next(self.zhuanzhi_all_equip_awakening_list) then
		local curr_equip_info = self.zhuanzhi_all_equip_awakening_list[equip_index].awakening_in_displacement
		for k,v in pairs(curr_equip_info) do
			if k == jue_xing_index then
				return v.type, v.level
			end
		end
	end
	return 0, 0
end

function ForgeData:GetLeftJueXingAttrCfg(equip_index, jue_xing_index)
	local type, level = self:LeftJueXingTypeAndLevelByIndex(equip_index, jue_xing_index)
	local cfg = self.jue_xing_attr_cfg[type]
	return cfg and cfg[level] or nil
end

function ForgeData:GetRightJueXingAttrCfg(equip_index, jue_xing_index)
	local type, level = self:RightJueXingTypeAndLevelByIndex(equip_index, jue_xing_index)
	local cfg = self.jue_xing_attr_cfg[type]
	return cfg and cfg[level] or nil
end

function ForgeData:GetJueXingAttrCfg(type, level)
	local cfg = self.jue_xing_attr_cfg[type]
	return cfg and cfg[level] or nil
end

function ForgeData:GetMaxJueXingJieShu()
	local other_cfg = self.zhuanzhieuqip_auto_cfg.other[1]
	if other_cfg then
		return other_cfg.wake_min_order, other_cfg.wake_min_color
	end
	return 4, 5
end

function ForgeData:GetShowSNumber(equip_index, equip_item_cfg, juexing_list)
	local s_num = 0
	local equip_order = equip_item_cfg.order
	local wake_level_limit_cfg = self.zhuanzhieuqip_auto_cfg.wake_level_limit_cfg or {}
	local good_attr_list = self:GetJueXingGoodAttrByIndex2(equip_index) or {}

	for k,v in pairs(wake_level_limit_cfg) do
		if v.equip_grade == equip_order then
			local max_level = v.max_level
			for k2, v2  in pairs(juexing_list) do
				if v2.level == max_level and good_attr_list[v2.type] then
					s_num = s_num + 1
				end
			end
		end
	end

	return s_num
end

function ForgeData:GetJueXingMaxLevelByIndex(equip_index)
	local equip_order = self:GetZhuanzhiEquipJieShu(equip_index)
	local wake_level_limit_cfg = self.zhuanzhieuqip_auto_cfg.wake_level_limit_cfg or {}

	for k,v in pairs(wake_level_limit_cfg) do
		if v.equip_grade == equip_order then
			return v.max_level
		end
	end

	return 0
end

function ForgeData:GetJueXingGoodAttrByIndex(equip_index)
	local wake_type_weight = self.zhuanzhieuqip_auto_cfg.wake_type_weight or {}
	local good_attr_list = {}
	for k,v in pairs(wake_type_weight) do
		if v.part == equip_index and v.is_zhenxi == 1 then 						-- 1为珍惜 0为普通
			table.insert(good_attr_list, v.type)
		end
	end
	return good_attr_list
end

function ForgeData:GetJueXingGoodAttrByIndex2(equip_index)
	local wake_type_weight = self.zhuanzhieuqip_auto_cfg.wake_type_weight or {}
	local good_attr_list = {}
	for k,v in pairs(wake_type_weight) do
		if v.part == equip_index and v.is_zhenxi == 1 then 						-- 1为珍惜 0为普通
			good_attr_list[v.type] = true
		end
	end
	return good_attr_list
end

function ForgeData:IsZhenXiAttr(equip_index, attr_type)
	local wake_type_weight = self.zhuanzhieuqip_auto_cfg.wake_type_weight or {}
	for k, v in pairs(wake_type_weight) do
		if v.part == equip_index and v.type == attr_type then 	
			return v.is_zhenxi
		end
	end
end

function ForgeData:GetJueXingGoodAttrCfg(good_attr_list, max_level)
	if good_attr_list == nil then
		return
	end
	local good_attr_list_cfg = {}
	for k,v in pairs(good_attr_list) do
		if self.jue_xing_attr_cfg[v] and v then
			table.insert(good_attr_list_cfg, self.jue_xing_attr_cfg[v][max_level])
		end
	end
	return good_attr_list_cfg
end
---------------------------------------------------------------------
function ForgeData:GetCondiTionAttr(equip_index, order)
	if self.zhuanzhieuqip_condition_attr[equip_index] and self.zhuanzhieuqip_condition_attr[equip_index][order] then
		return self.zhuanzhieuqip_condition_attr[equip_index][order].attribute_type_0, self.zhuanzhieuqip_condition_attr[equip_index][order].attribute_value_0
	end
end


--------------------------------
--------转职装备合成

-- 装备合成配置
function ForgeData:GetEquipExchangeCfg()
	local prof = PlayerData.Instance:GetRoleBaseProf()
	local temp_cfg = self.equip_exchange_cfg[prof]
	return temp_cfg
end

-- 装备合成目标配置
function ForgeData:GetTargetEquipExchangeCfg(target_equip, target_attr_num)
	local cfg = self.zhuanzhi_equip_compose_cfg[target_equip]
	return cfg and cfg[target_attr_num]
end

-- 获取符合合成的装备
function ForgeData:GetExchangeMaterialEquipList(need_color, need_attr_num, order)
	local equip_tab = {}
	local bag_items = ItemData.Instance:GetBagItemDataList()
	for k, v in pairs(bag_items) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg and EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type) then
			local xianpin_num = (v.param and v.param.xianpin_type_list) and #(v.param.xianpin_type_list)
			if not EquipData.Instance:IsZhuanzhiEquipShoushiType2(item_cfg.sub_type) and not self:GetExchangeBagEquipIndexList(v.index)
				and (PlayerData.Instance:GetRoleBaseProf() == item_cfg.limit_prof or 5 == item_cfg.limit_prof)
				and item_cfg.color == need_color and xianpin_num and xianpin_num == need_attr_num and item_cfg.order == order then
				table.insert(equip_tab, v)
			end
		end
	end
	return equip_tab
end


function ForgeData:GetExchangeBagEquipIndexList(index)
	return self.exchange_equip_index_list[index]
end

function ForgeData:SetExchangeBagEquipIndexList(index, is_add)
	self.exchange_equip_index_list[index] = is_add
end

function ForgeData:ResetExchangeBagEquipIndexList()
	self.exchange_equip_index_list = {}
end

-- 获取能显示的最大Order
function ForgeData:GetExchangeShowOrder()
	local role_level = PlayerData.Instance:GetRoleLevel()
	local min_order = 1
	local max_order = 1
	for k, v in pairs(self.zhuanzhieuqip_auto_cfg.equip_exchange_order_show) do
		if v.level > role_level then
			break
		else
			min_order = v.min_order
			max_order = v.max_order
		end
	end
	return min_order, max_order
end

function ForgeData:GetJumpIndexBySeq(seq)
	local sort_tab = {
		[1] = 1, [2] = 2, [3] = 3, 
		[4] = 4, [5] = 8, [6] = 5, 
		[7] = 6, [8] = 7,
	}
	local equip_data = self:GetZhuanzhiEquipAll() or {}
	for k, v in ipairs(sort_tab) do
		if equip_data[v] and equip_data[v].item_id > 0 then
			return true
		end
	end
	return false
end

function ForgeData:SetExchangeEquipIsSucc(is_success)
	self.exchange_equip_is_succ = is_success
end

function ForgeData:GetExchangeEquipIsSucc()
	-- return 1
	return self.exchange_equip_is_succ
end
