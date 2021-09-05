BianShenData = BianShenData or BaseClass()
BianShenData.SHOW_ATTR = {
	"maxhp",
	"gongji",
	"fangyu",
	"ice_master",
	"fire_master",
	"thunder_master",
	"poison_master",
	"all_percent",
}

BianShenData.Attr = {
	"max_hp",
	"fang_yu",
	"gong_ji",
}

BianShenData.Potential = {
	"max_gongji_potential",
	"max_fangyu_potential",
	"max_hp_potential",
}

BianShenData.PotentialLimit = {
	"add_wash_upper_limit_gongji",
	"add_wash_upper_limit_fangyu",
	"add_wash_upper_limit_maxhp",
}

BianShenData.TempPotential = {
	"max_gongji_tmp_potential",
	"max_fangyu_tmp_potential",
	"max_hp_tmp_potential",
}

BianShenData.Change = {
	["gongji_tmp"] = "gongji",
	["fangyu_tmp"] = "fangyu",
	["hp_tmp"] = "hp",
}

FAMOUS_HOUSE_ALL_ROW = 60 		--背包总列数
FAMOUS_HOUSE_COLUMN = 3 		--行数
FAMOUS_HOUSE_ROW = 6 			--格子列数
FAMOUS_HOUSE_SHOW_COLUMN = 3 	--行数

function BianShenData:__init()
	if BianShenData.Instance then
		print_error("[BianShenData] Attemp to create a singleton twice !")
	end
	BianShenData.Instance = self
	self.config = nil
	self.general_info_cfg = nil
	self.passive_skill = nil
	self.normal_skill = nil
	self.zuhe_cfg = nil
	self.slot_cfg = nil
	self.other_cfg = nil
	self.draw_cfg = nil
	self.red_skill = nil
	self.solt_name = nil
	self.experience = nil
	self.solt_seq_level = nil
	self.chinese_zodiac_cfg = nil
	self.xinghun_cfg  = nil
	self.xinghun_cfg2  = nil
	self.xinghun_extra_cfg = nil
	self.starsoul_point_effect_cfg = nil

	self.general_info_list = {}
	self.last_wash_point = {}
	self.potential_info = {}
	self.cur_used_seq = -1
	self.bianshen_end_timestamp = 0
	self.slot_info = {}

	self.active_list = {}
	self.data_change = false
	self.bianshen_cd = 0
	self.bianshen_cd_reduce_s = 0
	self.sort_list = {}
	self.bone_sort_list = {}
	self.has_dailyfirst_draw_ten = 0

	self.reward_draw_times = 0
	self.reward_fetch_flag = 0

	self.select_index = 1									-- 策划需求 切换第一第二标签不更换选中名将

	self.role_goal_cfg = ConfigManager.Instance:GetAutoConfig("role_big_small_goal_auto") or {}
	self.goal_item_cfg = ListToMap(self.role_goal_cfg.item_cfg, "reward_type", "system_type")
	self.goal_attr_cfg = ListToMap(self.role_goal_cfg.attr_cfg, "system_type")
	local great_soldier_cfg = ConfigManager.Instance:GetAutoConfig("greate_soldier_config_auto") or {}
	self.soldier_name_cfg = ListToMap(great_soldier_cfg.slot_name,"seq")
	self.soldier_leve_cfg = ListToMap(great_soldier_cfg.level,"seq")
	self.potential_cfg = ListToMap(great_soldier_cfg.potential,"seq","level")
	self.soldier_model_cfg = ListToMap(great_soldier_cfg.level,"image_id")
	self.soldier_draw_cfg = ListToMapList(great_soldier_cfg.draw, "is_show_item")
	self.soldier_zuhe_cfg = ListToMap(great_soldier_cfg.combine,"seq")
	self.soldier_skill_cfg = ListToMap(great_soldier_cfg.skill,"skill_id")
	self.experience_cfg = ListToMap(great_soldier_cfg.experience,"bs_id")
	self.soldier_passive_skill_cfg = ListToMap(great_soldier_cfg.passive_skill,"seq")
	self.equip_cfg = great_soldier_cfg.equip_level	    -- 装备等级配表
	self.level_attr_per = ListToMap(great_soldier_cfg.level_attr_per, "level")	-- 等级属性加成配表
	self.huanhua_cfg = ListToMap(great_soldier_cfg.huanhua, "id")		-- 大目标幻化形象
	self.special_skill_cfg = great_soldier_cfg.specialskill_tips		-- 特殊技能配置

	self.item_list = {}							-- 抽奖获得的物品列表

	-- self.wash_point_limit_cfg = great_soldier_cfg.wash_attr_upper_limit_increase or {}

	-- 星座所有信息
	self.xingzuo_all_info = {
		zodiac_level_list = {},
		xinghun_level_list = {},
		xinghun_level_max_list = {},
		chinesezodiac_equip_list = {},
		miji_list = {},
		zodiac_progress = 0,
		upgrade_zodiac = 0,
		xinghun_progress = 0,
	}

	self.general_goal_list = {}			--名将目标
	self.use_huanhua_id = 0
	self.huanhua_flag = 0
	self.seq_exchange_counts = {}
	self.equipment_list_info = {}	-- 名将信息

	RemindManager.Instance:Register(RemindName.BianShenMsg, BindTool.Bind(self.ShowRemindMsg, self))
	RemindManager.Instance:Register(RemindName.BianShenQianNeng, BindTool.Bind(self.ShowRemindQianNeng, self))
	RemindManager.Instance:Register(RemindName.BianShenQingShen, BindTool.Bind(self.ShowRemindQingShen, self))
	RemindManager.Instance:Register(RemindName.BianShenEquip, BindTool.Bind(self.ShowRemindEquip, self))
	RemindManager.Instance:Register(RemindName.BianShenStrengthen, BindTool.Bind(self.ShowRemindStrengthen, self))
end

function BianShenData:__delete()
	RemindManager.Instance:UnRegister(RemindName.BianShenMsg)
	RemindManager.Instance:UnRegister(RemindName.BianShenQianNeng)
	RemindManager.Instance:UnRegister(RemindName.BianShenQingShen)
	RemindManager.Instance:UnRegister(RemindName.BianShenEquip)
	RemindManager.Instance:UnRegister(RemindName.BianShenStrengthen)
	BianShenData.Instance = nil
	self.last_wash_point = {}
end

function BianShenData:GetGeneralConfig()
	if not self.config then
		self.config = ConfigManager.Instance:GetAutoConfig("greate_soldier_config_auto")
	end
	return self.config
end

function BianShenData:GeneralLimitDrawInfoCfg()
	if not self.general_limit_draw then
		self.general_limit_draw = self:GetGeneralConfig().general_limit_draw
	end
	return self.general_limit_draw or {}
end

function BianShenData:GeneralInfoCfg()
	if not self.general_info_cfg then
		self.general_info_cfg = self:GetGeneralConfig().level
	end
	return self.general_info_cfg or {}
end

function BianShenData:GetPassiveSkillCfg()
	if not self.passive_skill then
		self.passive_skill = self:GetGeneralConfig().passive_skill
	end
	return self.passive_skill
end

function BianShenData:GetSkillCfg()
	if not self.normal_skill then
		self.normal_skill = self:GetGeneralConfig().skill
	end
	return self.normal_skill
end

function BianShenData:GetSoltCfg()
	if not self.slot_cfg then
		self.slot_cfg = self:GetGeneralConfig().slot
	end
	return self.slot_cfg
end

function BianShenData:GetOtherCfg()
	if not self.other_cfg then
		self.other_cfg = self:GetGeneralConfig().other[1]
	end
	return self.other_cfg
end

function BianShenData:GetRedSkill()
	if not self.red_skill then
		self.red_skill = self:GetGeneralConfig().specialskill_tips
	end
	return self.red_skill
end

function BianShenData:GetSlotName(slot_seq)
	if not slot_seq then
		return "", 0
	end

	local name_str = ""
	local need_level = 0
	if self.soldier_name_cfg[slot_seq] then
		name_str = self.soldier_name_cfg[slot_seq].name
		need_level = self.soldier_name_cfg[slot_seq].need_level
	end

	return name_str, need_level
end

function BianShenData:GetSoldierCfg(slot_seq)
	if self.soldier_name_cfg[slot_seq] then
		return self.soldier_name_cfg[slot_seq]
	end
end

function BianShenData:SetGreateSoldierItemInfo(protocol)
	local index = BianShenCtrl.Instance:GetCurSelectIndex()
	if protocol.seq == index then
		self.last_wash_point = self:GetGeneralSingleInfoBySeq(index)
	end
	local general_info = self:GetSingleDataBySeq(protocol.seq)
	self.general_info_list[protocol.seq] = TableCopy(protocol.item_info)
	self.general_info_list[protocol.seq].seq = protocol.seq
	self.general_info_list[protocol.seq].is_active = self:CheckGeneralIsActive(protocol.seq) and 0 or 2

	if general_info then
		self.general_info_list[protocol.seq].color = general_info.color or 0
		self.general_info_list[protocol.seq].active_skill_type = general_info.active_skill_type or 0
	end
	self.data_change = true

	self.equipment_list_info[protocol.seq] = protocol.item_info.equipment_list
end

-- 获取变身装备信息根据魔将索引
function BianShenData:GetEquipmentListInfo(select_index)
	return self.equipment_list_info[select_index]
end

-- 根据槽位和神魔品质获取可以装备的装备列表, 按照装备品质排序
function BianShenData:GetEquipmentBagBySlotIndex(slot_index, quality)
	local bag_equip_list = ItemData.Instance:GetItemListByBigType(GameEnum.ITEM_BIGTYPE_EQUIPMENT)
	local equip_list = {}

	for k, v in pairs(bag_equip_list) do
		local item_cfg, bag_type = ItemData.Instance:GetItemConfig(v.item_id)
		if nil ~= item_cfg and bag_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT 
			and (slot_index + 1500) == item_cfg.sub_type and quality >= item_cfg.quality then
			v.quality = item_cfg.quality
			table.insert(equip_list, v)
		end
	end

	if next(equip_list) then
	 	table.sort(equip_list, SortTools.KeyUpperSorters("quality", "item_id"))
	end
	
	return equip_list
end

-- 获取可以强化的装备列表
function BianShenData:GetStrengthenEquipList()
	local equip_strengthen_list = {}
	local i = 1
	for k, v in pairs(self.equipment_list_info) do
		for k1, v1 in pairs(v) do
			if v1.item_id ~= 0 then
				equip_strengthen_list[i] = {}
				equip_strengthen_list[i].item_id = v1.item_id
				equip_strengthen_list[i].strength_level = v1.strength_level
				equip_strengthen_list[i].shuliandu = v1.shuliandu
				equip_strengthen_list[i].seq = k   -- 名将索引
				equip_strengthen_list[i].slot = k1 - 1  -- 装备槽位
				i = i + 1
			end 
		end
	end
	return equip_strengthen_list
end

-- 获取装备的最大等级
function BianShenData:GetEquipMaxLv(slot_index, quality)
	local slot_index = slot_index or 0
	local quality = quality or 1
	local max_lv = 0
	for k, v in pairs(self.equip_cfg) do
		if v.slot_index == slot_index and v.quality == quality then
			max_lv = v.strength_level
		end
	end
	return max_lv
end

-- 获取装备背包数据，从背包筛选
function BianShenData:GetEquipBagInfoList()
	local strength_equip_list = {}
	local equip_list = ItemData.Instance:GetItemListByBigType(GameEnum.ITEM_BIGTYPE_EQUIPMENT)
	if not equip_list then return end
	for k, v in pairs(equip_list) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg.sub_type >= 1500 and item_cfg.sub_type <= 1503 then
			local cfg = TableCopy(v)
			cfg.sort_quality = item_cfg.quality
			table.insert(strength_equip_list, cfg)
		end
	end
	table.sort(strength_equip_list, SortTools.KeyUpperSorters("sort_quality"))
	return strength_equip_list
end

-- 获取装备配置信息，根据槽位、品质和等级
function BianShenData:GetEquipCfg(slot_index, quality, strength_level)
	for k, v in pairs(self.equip_cfg) do
		if v.slot_index == slot_index and v.quality == quality and v.strength_level == strength_level then
			return v
		end
	end
	return nil
end

-- 根据当前选中的名将索引、槽位，得到是否显示提示箭头
function BianShenData:IsShowArrow(seq, slot_index)
	local general_info = self:GetSingleDataBySeq(seq)
	if not general_info then
		return
	end
	local equip_list = self:GetEquipmentBagBySlotIndex(slot_index, general_info.color)
	local equipment_list_info = self:GetEquipmentListInfo(seq)
	local item_id = equipment_list_info[slot_index + 1].item_id
	if item_id == 0 then 	-- 没有装备时
		if next(equip_list) then
			return true
		end
	else
		local config = ItemData.Instance:GetItemConfig(item_id)
		if next(equip_list) then
			for k, v in pairs(equip_list) do
				if v.quality > config.color and v.quality <= general_info.color then
					return true
				end
			end
		end
	end

	return false
end

function BianShenData:GetLastWashPointInfoBySeq()
	if next(self.last_wash_point) then
		return self.last_wash_point
	end
end

function BianShenData:SetGreateSoldierOtherInfo(protocol)
	self.cur_used_seq = protocol.cur_used_seq
	self.has_dailyfirst_draw_ten = protocol.has_dailyfirst_draw_ten
	self.bianshen_end_timestamp = protocol.bianshen_end_timestamp
	self.bianshen_cd = protocol.bianshen_cd
	self.bianshen_cd_reduce_s = protocol.bianshen_cd_reduce_s
	self.is_bianshen_cd_end = protocol.is_bianshen_cd_end
	self.use_huanhua_id = protocol.use_huanhua_id
	self.huanhua_flag = protocol.huanhua_flag
	self.seq_exchange_counts = protocol.seq_exchange_counts
end

function BianShenData:GetExchangeCounts(index)
	return self.seq_exchange_counts[index]
end

function BianShenData:GetBianShenCdEnd()
	return (self.is_bianshen_cd_end == 1)
end

function BianShenData:SetGreateSoldierSlotInfo(protocol)
	self.crrent_use_mingjiang = protocol.slot_param[0]
	local index = 1
	for k,v in pairs(protocol.slot_param) do
		self.slot_info[index] = v
		self.slot_info[index].place = k
		index = index + 1
	end
end

function BianShenData:GetGeneralInfoList()
	return self.general_info_list
end

function BianShenData:GetCurrentMingJiangInfo()
	return self.crrent_use_mingjiang
end

function BianShenData:GetSingleDataBySeq(seq)
	return self.soldier_leve_cfg[seq] or nil
end

function BianShenData:GetExchangeSoldier()
	if not self.soldier_exchange_cfg then
		self.soldier_exchange_cfg = {}
		for k,v in pairs(self.soldier_leve_cfg) do
			if v.exchange == 1 then
				table.insert(self.soldier_exchange_cfg, v)
			end
		end
	end
	return self.soldier_exchange_cfg
end

function BianShenData:GetGeneralSingleInfoBySeq(seq)
	return self.general_info_list[seq] or nil
end

function BianShenData:GetActiveGeneral()
	if self.data_change then
		self.active_list = {}
		for k,v in pairs(self.general_info_list) do
			local info = self:GetSingleDataBySeq(v.seq)
			if v.level > 0 and info then
				table.insert(self.active_list, info)
			end
		end
		self.data_change = false
	end
	return self.active_list
end

function BianShenData:CheckPassiveSkillIsActive(skill_seq)
	local active_list = self:GetActiveGeneral()
	for k,v in pairs(self.active_list) do
		if skill_seq == v.active_passive_skill_seq then
			return true
		end
	end
	return false
end

function BianShenData:GetZuheCfg()
	if not self.zuhe_cfg then
		self.zuhe_cfg = self:GetGeneralConfig().combine
	end
	return self.zuhe_cfg
end

function BianShenData:GetSortZuHeCfg()
	local zuhe_cfg = self:GetZuheCfg()
	if zuhe_cfg then
		local new_zuhe_cfg = TableCopy(zuhe_cfg)
		SortTools.SortDesc(new_zuhe_cfg, "grade")
		return new_zuhe_cfg
	end
	return {}
end

function BianShenData:GetComboDisplayList(seq)
	if nil == seq then return {} end

	local total_cfg = self.soldier_zuhe_cfg[seq]
	return total_cfg and Split(total_cfg.greate_soldier_seq_list, "|") or {}
end

function BianShenData:GetZuheSingleCfg(seq)
	if seq == nil then return end
	local zuhe_cfg = self.soldier_zuhe_cfg
	if zuhe_cfg[seq] then
		return zuhe_cfg[seq]
	end
end

function BianShenData:GetZuheAttrCfg(seq)
	if self.soldier_zuhe_attr_cfg == nil then
		self.soldier_zuhe_attr_cfg = ListToMapList(ConfigManager.Instance:GetAutoConfig("greate_soldier_config_auto").combine_attr, "seq")
	end
	local zuhe_attr_cfg = self.soldier_zuhe_attr_cfg
	if zuhe_attr_cfg[seq] then
		return zuhe_attr_cfg[seq]
	end
	return nil
end

function BianShenData:GetZuHeAttrCurLevel(seq)
	local soldier_seq_list = self:GetComboDisplayList(seq)
	local cur_level = 0
	for k, v in pairs(soldier_seq_list) do
		local single_cfg = self:GetGeneralSingleInfoBySeq(tonumber(v))
		if k == 1 then
			cur_level = single_cfg.level
		else
			if cur_level > single_cfg.level then
				cur_level = single_cfg.level
			end
		end
	end
	return cur_level
end

function BianShenData:GetCurZuHeAttrAndNext(seq)
	local cur_zuhe_attr = nil
	local next_zuhe_attr = nil
	local zuhe_attr_cfg = self:GetZuheAttrCfg(seq)
	local cur_zuhe_level = self:GetZuHeAttrCurLevel(seq)
	if zuhe_attr_cfg and cur_zuhe_level then
		local index = 0
		for k, v in pairs(zuhe_attr_cfg) do
			if cur_zuhe_level >= v.need_min_strength_level then
				index = k
			end
		end
		cur_zuhe_attr = zuhe_attr_cfg[index]
		next_zuhe_attr = zuhe_attr_cfg[index + 1]
	end
	return cur_zuhe_attr, next_zuhe_attr
end

function BianShenData:CheckGeneralIsActive(seq)
	for k,v in pairs(self.general_info_list) do
		if seq == v.seq and v.level > 0 then
			return true
		end
	end
	return false
end

--检查名将池是否有已激活，出战的武将
function BianShenData:CheckGeneralPoolHasActive()
	local fight_num = 0
	local totle_num = 0
	for k,v in pairs(self.slot_info) do
		if v.item_seq ~= -1 then
			fight_num = fight_num + 1
		end
	end

	if fight_num >= COMMON_CONSTS.GREATE_SOLDIER_SLOT_MAX_COUNT then
		return false
	end

	for k,v in pairs(self.general_info_list) do
		if v.level > 0 then
			totle_num = totle_num + 1
		end
		if totle_num > COMMON_CONSTS.GREATE_SOLDIER_SLOT_MAX_COUNT then
			break
		end
	end

	if totle_num > fight_num then
		return true
	end

	return false
end

function BianShenData:GetslotInfo()
	return self.slot_info
end

function BianShenData:GetSingleSlotInfo(slot_seq)--
	if nil == slot_seq then return end
	for k,v in pairs(self.slot_info) do
		if slot_seq == v.place then
			return v
		end
	end
	return {}
end

function BianShenData:GetSlotLevelCfg(level, seq)
	local solt_seq_level = self:GetSlotSeqLevelCfg()
	if nil == level or nil == seq or nil == solt_seq_level then return end
	local solt_cfg = solt_seq_level[seq]
	if solt_cfg and solt_cfg[level] then
		return solt_cfg[level]
	end
end

function BianShenData:GetSlotSeqLevelCfg()
	if nil == self.solt_seq_level then
		self.solt_seq_level = ListToMap(self:GetSoltCfg(), "seq","level")
	end
	return self.solt_seq_level
end

function BianShenData:GetResIdBySeq(seq)
	local data = self.soldier_leve_cfg[seq]
	return data and data.image_id or 0
end

function BianShenData:GetSeqByImageId(image_id)
	if self.soldier_model_cfg[image_id] then
		return self.soldier_model_cfg[image_id].seq
	end
	return nil
end

function BianShenData:CheckShowSkill()
	for k,v in pairs(self.slot_info) do
		if v.place == 0 and v.item_seq ~= -1 then
			return true
		end
	end
	return false
end

function BianShenData:GetEndTimestamp()
	return self.bianshen_end_timestamp
end

function BianShenData:GetCurUseSeq()
	return self.cur_used_seq
end

function BianShenData:CheckIsGeneralSkill(skill_id)
	if skill_id == nil then return false end

	local skill_cfg = self.soldier_skill_cfg[skill_id]
	return skill_cfg and true or false
end

function BianShenData:GetExperience(seq)
	if seq == nil then return nil end
	local cfg = self.experience_cfg
	return cfg[seq] or nil
end

function BianShenData:GetsinglePassive(seq)
	if seq == nil then return nil end
	local cfg = self.soldier_passive_skill_cfg
	return cfg[seq] or nil
end

function BianShenData:GetSpePassive(seq)
	if not self.red_skill then
		self.red_skill = self:GetGeneralConfig().specialskill_tips
	end
	local active_skill_type = self.general_info_list[seq].active_skill_type
	for k,v in pairs(self.red_skill) do
		if v.active_skill_type == active_skill_type then
			return v
		end
	end
	return {}
end

function BianShenData:CheckComboIsActive(combo_seq)
	local temp = self:GetComboDisplayList(combo_seq)
	for k,v in pairs(temp) do
		if not self:CheckGeneralIsActive(tonumber(v)) then
			return false
		end
	end
	return true
end

function BianShenData:GetTextColor(percent)
	local color =  GameEnum.ITEM_COLOR_GREEN
	if percent >= 90 then
		color = GameEnum.ITEM_COLOR_ORANGE
	elseif percent >= 80 then
		color = GameEnum.ITEM_COLOR_PURPLE
	elseif percent >= 70 then
		color = GameEnum.ITEM_COLOR_BLUE
	elseif percent >= 60 then
		color = GameEnum.ITEM_COLOR_GREEN
	end
	return color
end

function BianShenData:GetShowReward()
	return self.soldier_draw_cfg[1] or {}
end

function BianShenData:GetBianShenCds()
	local real_cd = self.bianshen_cd / 1000 - self.bianshen_cd_reduce_s
	if real_cd < 0 then
		real_cd = 0
	end

	return real_cd
end

function BianShenData:CheckSpecialSkillIsActive(id)
	if not id then return false end
	local level_cfg = self.soldier_leve_cfg
	for k,v in pairs(level_cfg) do
		if id == v.active_skill_type then
			return self:CheckGeneralIsActive(v.seq)
		end
	end
	return false
end

function BianShenData:AfterSortList()
	local other_cfg = self:GetOtherCfg()
	local curr_opend_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local level_cfg = TableCopy(self.soldier_leve_cfg)
	local data_list = {}
	for i = 0, #level_cfg do
		if curr_opend_day >= level_cfg[i].open_day then
			local temp = level_cfg[i]
			local cur_cfg = self:GetGeneralSingleInfoBySeq(level_cfg[i].seq)
			if cur_cfg then
				temp.is_active = cur_cfg.is_active
				temp.can_active = (ItemData.Instance:GetItemNumIsEnough(level_cfg[i].item_id, 1) and cur_cfg.level < other_cfg.max_level) and 1 or 2
				temp.level = cur_cfg.level
				temp.potential_level = cur_cfg.potential_level
			end
			table.insert(data_list, temp)
		end
	end
	return data_list
end

function BianShenData:GetSeqBySelectIndex(index)
	local list = self:AfterSortList()
	if list[index] and list[index].seq then
		return list[index].seq + 1
	end
	return 1
end

function BianShenData:GetIndexByImageId(image_id)
	local list = self:AfterSortList()
	for k, v in pairs(list) do
		if v.item_id == image_id then
			return v.seq, v.color
		end
	end
end

function BianShenData:GetListByColorType(color_type)
	local sort_list = self:AfterSortList()
	local data_list = {}
	for k, v in ipairs(sort_list) do
		if v.color == color_type then
			table.insert(data_list, v)
		end
	end
	return data_list
end

function BianShenData:GetDatalistBySeq(seq)
	local sort_list = self:AfterSortList()
	for k, v in ipairs(sort_list) do
		if v.seq == seq then
			return v
		end
	end
	return nil
end

function BianShenData:GetBianShenTime()
	local now_time = TimeCtrl.Instance:GetServerTime()
	local cd_s = (self.bianshen_end_timestamp - now_time)
	return cd_s
end

function BianShenData:SetSelectIndex(select_index)
	self.select_index = select_index
end

function BianShenData:GetSelectIndex()
	return self.select_index
end

function BianShenData:GetIndexBySeq(cur_seq)
	local data_list = self:AfterSortList()
	for k,v in pairs(data_list) do
		if cur_seq == v.seq then
			return k
		end
	end
	return 1
end

function BianShenData:SetItemList(item_list)
	self.item_list = item_list
end

function BianShenData:GetItemList()
	return self.item_list or {}
end

function BianShenData:GetCurSlotBySeq(seq)
	for k,v in pairs(self.slot_info) do
		if seq == v.item_seq then
			return v.place
		end
	end
	return nil
end

function BianShenData:IsAllOrangeo(select_seq)
	if not select_seq then return false end

	local select_cfg = self:GetSingleDataBySeq(select_seq)
	if not select_cfg then return false end
	local select_info = self:GetGeneralSingleInfoBySeq(select_cfg.seq)
	if not select_info then return false end

	for k,v in pairs(select_info) do
		if select_cfg["max_" .. k .. "_potential"] then
			local percent = v * 100 / select_cfg["max_" .. k .. "_potential"]
			if percent < 90 then
				return false
			end
		end
	end

	return true
end

function BianShenData:IsTempAllOrangeo(select_seq)
	if not select_seq then return false end

	local select_cfg = self:GetSingleDataBySeq(select_seq)
	if not select_cfg then return false end
	local select_info = self:GetGeneralSingleInfoBySeq(select_cfg.seq)
	if not select_info then return false end

	for k,v in pairs(select_info) do
		local cfg_name = BianShenData.Change[k] or ""
		if select_cfg["max_" .. cfg_name .. "_potential"] then
			local percent = v * 100 / select_cfg["max_" .. cfg_name .. "_potential"]
			if percent < 90 then
				return false
			end
		end
	end

	return true
end

function BianShenData:ClearSortList()
	self.sort_list = {}
end

function BianShenData:IsFirstTenChou()
	return self.has_dailyfirst_draw_ten == 0
end

function BianShenData:GetFamousCapAndAttr()
	local capability = 0
	local all_attr = CommonStruct.Attribute()

	if self.general_info_list ~= nil then
		local slot_list = {}
		if self.slot_info ~= nil then
			for k,v in pairs(self.slot_info) do
				slot_list[v.item_seq] = v
			end
		end

		for k,v in pairs(self.general_info_list) do
			if v ~= nil and v.level > 0 then
				local attr = CommonStruct.Attribute()
				local level_cfg = self:GetSingleDataBySeq(v.seq)
				if level_cfg ~= nil and next(level_cfg) ~= nil then
					local level_attr = CommonDataManager.GetAttributteByClass(level_cfg)
					attr = CommonDataManager.AddAttributeAttr(attr, CommonDataManager.MulAttribute(level_attr, v.level))
				end
				if slot_list[v.seq] ~= nil then
					local solt_data = slot_list[v.seq]
					local slot_cfg = self:GetSlotLevelCfg(solt_data.level, solt_data.place)
					if slot_cfg ~= nil and next(slot_cfg) ~= nil then
						if v.gongji ~= nil and slot_cfg.gongji_conv_rate ~= nil then
							attr["gong_ji"] = attr["gong_ji"] + math.floor(v.gongji * 0.01 * slot_cfg.gongji_conv_rate)
						end
						if v.fangyu ~= nil and slot_cfg.fangyu_conv_rate ~= nil then
							attr["fang_yu"] = attr["fang_yu"] + math.floor(v.fangyu * 0.01 * slot_cfg.fangyu_conv_rate)
						end
						if v.hp ~= nil and slot_cfg.hp_conv_rate ~= nil then
							attr["max_hp"] = attr["max_hp"] + math.floor(v.hp * 0.2 * slot_cfg.hp_conv_rate)
						end
					end
				end

				all_attr = CommonDataManager.AddAttributeAttr(all_attr, attr)
			end
		end
	end

	local zuhe_attr = CommonStruct.Attribute()
	if self.soldier_zuhe_cfg ~= nil then
		for k,v in pairs(self.soldier_zuhe_cfg) do
			if self:CheckComboIsActive(v.seq) then
				local attr = CommonDataManager.GetAttributteByClass(v)
				zuhe_attr = CommonDataManager.AddAttributeAttr(zuhe_attr, CommonDataManager.GetAttributteByClass(attr))
			end
		end
	end

	all_attr = CommonDataManager.AddAttributeAttr(all_attr, zuhe_attr)
	capability = CommonDataManager.GetCapability(all_attr)
	return all_attr, capability
end

----------------------根骨--------------
function BianShenData:SetShengXiaoAllInfo(protocol)
	self.xingzuo_all_info.zodiac_level_list = protocol.zodiac_level_list
	self.xingzuo_all_info.xinghun_level_list = protocol.xinghun_level_list
	self.xingzuo_all_info.xinghun_level_max_list = protocol.xinghun_level_max_list
	self.xingzuo_all_info.chinesezodiac_equip_list = protocol.chinesezodiac_equip_list
	self.xingzuo_all_info.miji_list = protocol.miji_list
	self.xingzuo_all_info.zodiac_progress = protocol.zodiac_progress
	self.xingzuo_all_info.upgrade_zodiac = protocol.upgrade_zodiac
	self.xingzuo_all_info.xinghun_progress = protocol.xinghun_progress
end

function BianShenData:GetChineseZodiacCfg()
	if not self.chinese_zodiac_cfg then
		self.chinese_zodiac_cfg = ConfigManager.Instance:GetAutoConfig("chinese_zodiac_cfg_auto") or {}
	end
	return self.chinese_zodiac_cfg
end

function BianShenData:GetXingHunCfg()
	local chinese_zodiac_cfg = self:GetChineseZodiacCfg()
	if not self.xinghun_cfg then
		self.xinghun_cfg = ListToMap(chinese_zodiac_cfg.xinghun, "seq", "level")
	end
	return self.xinghun_cfg
end

function BianShenData:GetXingHunCfg2()
	local chinese_zodiac_cfg = self:GetChineseZodiacCfg()
	if not self.xinghun_cfg2 then
		self.xinghun_cfg2 = ListToMap(chinese_zodiac_cfg.xinghun, "seq")
	end
	return self.xinghun_cfg2
end

function BianShenData:GetXingHunExtraCfg()
	local chinese_zodiac_cfg = self:GetChineseZodiacCfg()
	if not self.xinghun_extra_cfg then
		self.xinghun_extra_cfg = chinese_zodiac_cfg.xinghun_extra_info
	end
	return self.xinghun_extra_cfg
end

function BianShenData:GetXingHunExtraCfg()
	local chinese_zodiac_cfg = self:GetChineseZodiacCfg()
	if not self.xinghun_extra_cfg then
		self.xinghun_extra_cfg = chinese_zodiac_cfg.xinghun_extra_info
	end
	return self.xinghun_extra_cfg
end

function BianShenData:GetStarSoulPointEffectCfg()
	local chinese_zodiac_cfg = self:GetChineseZodiacCfg()
	if not self.starsoul_point_effect_cfg then
		self.starsoul_point_effect_cfg = chinese_zodiac_cfg.xinghun_effect
	end
	return self.starsoul_point_effect_cfg
end

function BianShenData:GetStarSoulPointCfg(index)
	local point_effect_list = {}
	local starsoul_point_effect_cfg = self:GetStarSoulPointEffectCfg()
	local cfg = {}
	for k,v in pairs(starsoul_point_effect_cfg) do
		if v.seq  == index then
			cfg = v
			break
		end
	end
	for i = 1, 10 do
		if cfg["point" .. i .. "_x"] and cfg["point" .. i .. "_y"]
			and cfg["point" .. i .. "_y"] ~= "" and cfg["point" .. i .. "_x"] ~= "" then
			point_effect_list[i] = {}
			point_effect_list[i].x = cfg["point" .. i .. "_x"]
			point_effect_list[i].y = cfg["point" .. i .. "_y"]
		end
	end
	return point_effect_list
end

function BianShenData:GetStarSoulLevelList()
	return self.xingzuo_all_info.xinghun_level_list
end

function BianShenData:GetStarSoulLevelByIndex(index)
	return self.xingzuo_all_info.xinghun_level_list[index] or 0
end

function BianShenData:GetStarSoulMaxLevelList()
	return self.xingzuo_all_info.xinghun_level_max_list
end

function BianShenData:GetStarSoulMaxLevelByIndex(index)
	return self.xingzuo_all_info.xinghun_level_max_list[index] or 0
end

-- 得到星魂开锁进程
function BianShenData:GetStarSoulProgress()
	return self.xingzuo_all_info.xinghun_progress
end

function BianShenData:GetStarSoulInfoByIndexAndLevel(index, level)
	local xinghuncfg = self:GetXingHunCfg()
	local cfg = xinghuncfg[index - 1]
	return cfg and cfg[level] or nil
end

function BianShenData:GetLowestOpenLevelGeneralSeq()
	local xinghuncfg2 = self:GetXingHunCfg2()
	local cfg = xinghuncfg2
	local level = 999
	local seq = -1
	for k,v in pairs(xinghuncfg2) do
		local is_active = self:CheckGeneralIsActive(k)
		if level > v.open_level and not is_active then
			level = v.open_level
			seq = k
		end
	end
	return seq
end

function BianShenData:GetWashPointLimitByIndexAndLevel(index, level)
	local data = {}
	data.add_wash_upper_limit_gongji = 0
	data.add_wash_upper_limit_fangyu = 0
	data.add_wash_upper_limit_maxhp = 0
	for k,v in pairs(self.wash_point_limit_cfg) do
		if v.seq == index - 1 and v.level <= level then
			data.add_wash_upper_limit_gongji = data.add_wash_upper_limit_gongji + v.add_wash_upper_limit_gongji
			data.add_wash_upper_limit_fangyu = data.add_wash_upper_limit_fangyu + v.add_wash_upper_limit_fangyu
			data.add_wash_upper_limit_maxhp = data.add_wash_upper_limit_maxhp + v.add_wash_upper_limit_maxhp
		end
	end
	return data
end

function BianShenData:GetNextStarSoulInfoByIndexAndLevel(index, level, attr_type)
	local cur_cfg = self:GetStarSoulInfoByIndexAndLevel(index, level)
	local xinghuncfg = self:GetXingHunCfg()
	local cfg = xinghuncfg[index - 1]
	for i,v in ipairs(cfg) do
		if v[attr_type] > cur_cfg[attr_type] then
			return v
			-- return v[attr_type] - cur_cfg[attr_type]
		end
	end
	return {}
end

function BianShenData:GetStarSoulMaxLevel(index)
	local xinghuncfg = self:GetXingHunCfg()
	local cfg = xinghuncfg[index - 1]
	return cfg and #cfg or 0
end

function BianShenData:GetStarSoulCanUp(index)
	if self:CheckGeneralIsActive(index - 1) then
		local befor_level = self:GetStarSoulMaxLevelByIndex(index - 1)
		local cfg = self:GetStarSoulInfoByIndexAndLevel(index, 0)
		if befor_level and cfg then
			if befor_level >= cfg.backwards_highest_level then
				return true
			end
		end
	end
	return false
end

function BianShenData:GetStarSoulTotal()
	local extra_cfg = self:GetXingHunExtraCfg()
	local total_level = 0
	for k,v in pairs(self.xingzuo_all_info.xinghun_level_list) do
		total_level = total_level + v
	end
	local cur_cfg, next_cfg = nil, nil
	if total_level < extra_cfg[1].level then
		next_cfg = extra_cfg[1]
	elseif total_level >= extra_cfg[#extra_cfg].level then
		cur_cfg = extra_cfg[#extra_cfg]
	else
		for k,v in pairs(extra_cfg) do
			if v.level > total_level then
				cur_cfg = extra_cfg[k - 1]
				next_cfg = v
				break
			end
		end
	end
	return cur_cfg, next_cfg, total_level
end

function BianShenData:CheckGeneralBoneUprise()
	local cur_select_index = self:GetSelectIndex()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	for k,v in pairs(self.general_info_list) do
		local cur_level = self:GetStarSoulLevelByIndex(v.seq + 1)
		if v.level > 0 and cur_level < 50 then -- 根骨最高等级
			local cur_cfg = self:GetStarSoulInfoByIndexAndLevel(v.seq + 1, cur_level)
			local item_num = ItemData.Instance:GetItemNumInBagById(cur_cfg.consume_stuff_id)
			if item_num > 0 and main_role_vo.level >= cur_cfg.open_level then
				return true
			end
		end
	end
	return false
end

function BianShenData:GetExperienceCfg(bs_type, param)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local great_soldier_cfg = ConfigManager.Instance:GetAutoConfig("greate_soldier_config_auto") or {}
	for k, v in pairs(great_soldier_cfg.experience) do
		if bs_type == v.bs_type and param == v["param" .. vo.camp] then
			return v
		end
	end

	return {}
end

function BianShenData:GetImageInfoByImgId(image_id)
	local great_soldier_cfg = ConfigManager.Instance:GetAutoConfig("greate_soldier_config_auto").level
	for k,v in pairs(great_soldier_cfg) do
		if v.image_id == image_id then
			return v
		end
	end
	return nil
end

function BianShenData:GetHasGeneralSkill()
	local skill_list = SkillData.Instance:GetSkillList()
	for k, v in pairs(skill_list) do
		if v.skill_id == 600 or v.skill_id == 601 or v.skill_id == 602 then
			return true
		end
	end

	return false
end

----------------------------潜能--------------------------------
function BianShenData:GetSinglePotentialCfg(seq,level)
	if not self.potential_cfg or not seq or not level then return end
	if not self.potential_cfg[seq] then return end
	return self.potential_cfg[seq][level]
end

function BianShenData:GetPotentialUpgradeItem(seq, level) -- 升到level所需物品
	if not self.potential_cfg or not seq or not level then return end
	level = level > self:GetMaxPotentialLevel(seq) and self:GetMaxPotentialLevel(seq) or level
	return self.potential_cfg[seq][level].upgrade_item.item_id, self.potential_cfg[seq][level].upgrade_item.num
end

function BianShenData:GetPotentialSuccessRate(seq,level) -- 升到level的概率
	local cfg = self:GetSinglePotentialCfg(seq,level)
	if not cfg then return 0 end
	return cfg.succ_percent
end

function BianShenData:GetPotentialAttr(seq,level)
	local attr = {["gongji"] = 0, ["fangyu"] = 0, ["maxhp"] = 0}
	if not self.potential_cfg or not seq or not level then return attr end
	if not self.potential_cfg[seq] or not self.potential_cfg[seq][level]then return attr end
	for i = 1,level do
		attr.gongji = attr.gongji + self.potential_cfg[seq][i].gongji
		attr.fangyu = attr.fangyu + self.potential_cfg[seq][i].fangyu
		attr.maxhp = attr.maxhp + self.potential_cfg[seq][i].maxhp
	end
	return attr
end

function BianShenData:GetMaxPotentialLevel(seq)
	if not self.potential_cfg then return end
	if not seq then seq = 0 end
	return #self.potential_cfg[seq]
end

function BianShenData:SetPotentialLevelInfo()
	self.potential_level_list = {}
	local info = self:GetGeneralInfoList() or {}
	if not next(info) then
		return
	end
	
	for i = 0, #info -1 do
		self.potential_level_list[i] = info[i].potential_level
	end
end

function BianShenData:GetPotentialLevelInfo()
	return self.potential_level_list
end

function BianShenData:GetFamousGeneralLevelChange()
	local is_change = false
	local info = self:GetGeneralInfoList()
	local level_list = self:GetPotentialLevelInfo()
	if level_list == nil then
		self:SetPotentialLevelInfo()
		level_list = self:GetPotentialLevelInfo()
	end
	for i = 0, #info - 1 do
		-- print_error(info[i].potential_level, level_list[i])
		if info[i].potential_level > level_list[i] then
			is_change = true
			self:SetPotentialLevelInfo()
			break
		end
	end

	return is_change
end

function BianShenData:SetGreateSoldierFetchReward(protocol)
	self.reward_draw_times = protocol.draw_times
	self.reward_fetch_flag = protocol.fetch_flag
end

function BianShenData:GetDrawCount()
	return self.reward_draw_times
end

function BianShenData:IsGetRewardByIndex(index)
	local bit_list = bit:d2blh(self.reward_fetch_flag)
	for k, v in pairs(bit_list) do
		if v == 1 and k == index + 1 then
			return true
		end
	end
	return false
end

function BianShenData:SortGeneralRewardList()
	local new_list = {}
	local reward_list = TableCopy(self:GeneralLimitDrawInfoCfg())
	for k, v in pairs(reward_list) do
		if v.seq then
			v.flag = self:IsGetRewardByIndex(v.seq) and 1 or 0
			v.target = v.draw_number <= self.reward_draw_times
			table.insert(new_list, v)
		end
	end
	if next(new_list) then
		SortTools.SortAsc(new_list, "flag", "seq")
	end
	return new_list
end

function BianShenData:SetGeneralGoalInfo(protocol)
	self.general_goal_list = protocol.data_list
end

function BianShenData:GetGeneralGoalInfo()
	return	self.general_goal_list
end

function BianShenData:GetCurGoalCfg(goal_type)
	if self.cur_goal_cfg == nil then
		self.cur_goal_cfg = ListToMap(self:GetGeneralConfig().goal, "goal_type")
	end
	if self.cur_goal_cfg[goal_type] then
		return self.cur_goal_cfg[goal_type]
	end
	return nil
end

function BianShenData:GetHuanHuaIsActive(id)
	local table = bit:d2b(self.huanhua_flag)
	if table[32 - id] == 1 then
		return true
	end
	return false
end

function BianShenData:GetCurHuanHuaCfg(id)
	if self.general_huanhua_cfg == nil then
		self.general_huanhua_cfg = ListToMap(self:GetGeneralConfig().huanhua, "id")
	end
	if self.general_huanhua_cfg[id] then
		return self.general_huanhua_cfg[id]
	end
	return nil
end

function BianShenData:GetCurHuanHuaCfgID(res_id)
	if self.general_huanhua_seq_cfg == nil then
		self.general_huanhua_seq_cfg = ListToMap(self:GetGeneralConfig().huanhua, "res_id")
	end
	if self.general_huanhua_seq_cfg[res_id] then
		return self.general_huanhua_seq_cfg[res_id].id
	end
	return nil
end

function BianShenData:GetBagBianShenDataList()
	local equip_list = ItemData.Instance:GetItemListByBigType(GameEnum.ITEM_BIGTYPE_EQUIPMENT)
	local qingshen_list = {}

	for _, v in pairs(equip_list) do
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
		if nil ~= item_cfg
			and GameEnum.ITEM_BIGTYPE_EQUIPMENT == big_type
			and item_cfg.sub_type == GameEnum.EQUIP_TYPE_JINGLING then
			table.insert(qingshen_list, v)
		end
	end

	return qingshen_list
end

function BianShenData:SetHuntQingShenWarehouseList(item_list)
	self.warehouse_item_list = self:GetBagBestQingShen(item_list, true)
	BianShenCtrl.Instance:FlushWarehouseView()
end

-- 获取仓库数据
function BianShenData:GetHuntQingShenWarehouseList()
	return self.warehouse_item_list or {}
end

function BianShenData:GetBagBestQingShen(data_list, is_no_bag)
	data_list = data_list or self:GetBagBianShenDataList()

	local list = {}
	local temp_list = {}
	local color = -1
	local temp_color = -1
	local list_lengh = 0
	local last_sort_list = {}
	for k, v in pairs(data_list) do
		table.insert(temp_list, v)
	end
	table.sort(temp_list, function (a, b)
		if not a then
			a = {item_id = 0}
			return a.item_id > b.item_id
		end
		if not b then
			b = {item_id = 0}
			return a.item_id > b.item_id
		end
		local item_cfg_a = ItemData.Instance:GetItemConfig(a.item_id)
		local item_cfg_b = ItemData.Instance:GetItemConfig(b.item_id)
		if item_cfg_a.click_use ~= item_cfg_b.click_use then
			return item_cfg_a.click_use > item_cfg_b.click_use
		end
		if item_cfg_a.color ~= item_cfg_b.color then
			return item_cfg_a.color > item_cfg_b.color
		end
		if a.item_id == b.item_id and a.param and b.param and a.param.strengthen_level ~= b.param.strengthen_level then
			return a.param.strengthen_level > b.param.strengthen_level
		end
		if a.item_id == b.item_id and a.param and b.param and a.param.param1 ~= b.param.param1 then
			return a.param.param1 > b.param.param1
		end

		if item_cfg_a.bag_type ~= item_cfg_b.bag_type then
			return item_cfg_a.bag_type < item_cfg_b.bag_type
		end

		return a.item_id > b.item_id
	end)

	return temp_list
end

-- 变身信息侧边栏红点提示
function BianShenData:ShowRemindMsg()
	local is_open = OpenFunData.Instance:CheckIsHide("bian_shen_msg")
	if not is_open then
		return 0
	end

	local goal_info = self:GetGoalInfo()
	if goal_info ~= nil and goal_info.active_flag ~= nil and goal_info.fetch_flag ~= nil then
		if (goal_info.active_flag[0] == 1 and goal_info.fetch_flag[0] == 0) or (goal_info.fetch_flag[0] == 1 and goal_info.active_flag[1] == 1 and goal_info.fetch_flag[1] == 0) then
			return 1
		end
	end

	local flag = 0
	local general_cfg = self:GeneralInfoCfg()
	local other_cfg = self:GetOtherCfg()
	for k,v in pairs(general_cfg) do
		local cur_info = self:GetGeneralSingleInfoBySeq(v.seq)
		if self:IsShowGeneral(v.item_id) then
			if ItemData.Instance:GetItemNumIsEnough(v.item_id, 1) and cur_info and cur_info.level < other_cfg.max_level then
				flag = 1
				break
			end
		end
	end
	return flag
end

-- 判断当前神魔是否开启显示
function BianShenData:IsShowGeneral(item_id)
	local show_general_list = self:AfterSortList()	-- 左侧展示的神魔列表
	for k, v in pairs(show_general_list) do
		if item_id == v.item_id then
			return true
		end
	end
	return false
end

-- 变身信息左侧边红点提示
function BianShenData:ShowRemindMsgByColor(color_type)
	local is_open = OpenFunData.Instance:CheckIsHide("bian_shen_msg")
	if not is_open then
		return false
	end

	local flag = false
	local general_cfg = self:GeneralInfoCfg()
	local other_cfg = self:GetOtherCfg()
	for k,v in pairs(general_cfg) do
		if v.color == color_type then
			local cur_info = self:GetGeneralSingleInfoBySeq(v.seq)
			if ItemData.Instance:GetItemNumIsEnough(v.item_id, 1) and cur_info and cur_info.level < other_cfg.max_level then
				flag = true
			end
		end
	end
	return flag
end

-- 潜能侧边栏红点提示
function BianShenData:ShowRemindQianNeng()
	local is_open = OpenFunData.Instance:CheckIsHide("bian_shen_qian_neng")
	if not is_open then
		return 0
	end

	local flag = 0
	local general_cfg = self:GeneralInfoCfg()
	for k,v in pairs(general_cfg) do				
		local cur_info = self:GetGeneralSingleInfoBySeq(v.seq)
		if cur_info and cur_info.level > 0 and cur_info.potential_level < self:GetMaxPotentialLevel(v.seq) then
			local potential_id, need_num = self:GetPotentialUpgradeItem(v.seq, cur_info.potential_level + 1)
			local potential_num = ItemData.Instance:GetItemNumInBagById(potential_id)
			if potential_num >= need_num then
				flag = 1
				break
			end
		end
	end
	return flag
end

-- 潜能左侧红点提示
function BianShenData:ShowRemindQianNengByColor(color_type)
	local is_open = OpenFunData.Instance:CheckIsHide("bian_shen_qian_neng")
	if not is_open then
		return false
	end

	local flag = false
	local general_cfg = self:GeneralInfoCfg()
	for k,v in pairs(general_cfg) do
		if v.color == color_type then
			local cur_info = self:GetGeneralSingleInfoBySeq(v.seq)
			if cur_info and cur_info.level > 0 and cur_info.potential_level < self:GetMaxPotentialLevel(v.seq) then
				local potential_id, need_num = self:GetPotentialUpgradeItem(v.seq, cur_info.potential_level + 1)
				local potential_num = ItemData.Instance:GetItemNumInBagById(potential_id)
				if potential_num >= need_num then
					flag = true
				end
			end
		end
	end
	return flag
end

-- 请神侧边栏红点
function BianShenData:ShowRemindQingShen()
	local is_open = OpenFunData.Instance:CheckIsHide("bian_shen_qing_shen")
	if not is_open then
		return 0
	end

	local flag = 0
	local other_cfg = self:GetOtherCfg()
	if ItemData.Instance:GetItemNumIsEnough(other_cfg.draw_1_item_id, 1) then
		flag = 1
	end
	return flag
end

-- 装备侧边红点
function BianShenData:ShowRemindEquip()
	local is_open = OpenFunData.Instance:CheckIsHide("bian_shen_equip")
	if not is_open then
		return 0
	end

	for k, v in pairs(self.general_info_list) do
		if v.level > 0 then
			for i = 0, 3 do
				if self:IsShowArrow(v.seq, i) then
					return 1
				end
			end
		end
	end
	return 0
end

-- 装备左侧边红点
function BianShenData:ShowRemindEquipByColor(color_type)
	local is_open = OpenFunData.Instance:CheckIsHide("bian_shen_equip")
	if not is_open then
		return false
	end
	for k, v in pairs(self.general_info_list) do
		if v.color == color_type and v.level > 0 then
			for i = 0, 3 do 	-- 四个槽位
				if self:IsShowArrow(v.seq, i) then
					return true
				end
			end
		end
	end
	return false
end

-- 强化侧边红点
function BianShenData:ShowRemindStrengthen()
	local is_open = OpenFunData.Instance:CheckIsHide("bian_shen_strengthen")
	if not is_open then
		return 0
	end
	
end

-- 根据神魔等级获取属性万分比
function BianShenData:GetPerAttrByLevel(level)
	local  per_attr = level <= 0 and 0 or (self.level_attr_per[level].per_attr / 10000)
	return per_attr
end

-- 潜能界面，根据当前潜能等级和神魔索引计算进阶技能的下一个等级数
function BianShenData:GetUpGradeByLevel(seq, potential_level, skill_level)
	for k, v in pairs(self.potential_cfg[seq]) do
	 	if v.seq == seq and v.special_skill_level > skill_level and v.level > potential_level then
	 		return v.level
	 	end
	 end 
	
	return 0
end

-- 获取全身属性
function BianShenData:GetAllBaseAttr()
	local attribute = CommonStruct.AttributeNoUnderline()
	local sort_list = self:AfterSortList()
	for k,v in pairs(sort_list) do
		local general_info = BianShenData.Instance:GetGeneralSingleInfoBySeq(v.seq)
		local read_data = {}
		local attr = CommonDataManager.GetAttributteNoUnderline(v)
		local attr_per = BianShenData.Instance:GetPerAttrByLevel(general_info.level)
		for k,v in pairs(attr) do
			if v > 0 then
				table.insert(read_data, {key = k, value = v*attr_per})
			end
		end
			
		local attr_tab = CommonStruct.AttributeNoUnderline()
		if read_data then
			for k,v in pairs(read_data) do
				if v ~= nil and attr_tab[v.key] ~= nil then
					attr_tab[v.key] = attr_tab[v.key] + v.value
				end
			end
		end

		attribute = CommonDataManager.AddAttributeAttrNoUnderLine(attribute, attr_tab)
	end

	return attribute
end

-- 获取特殊技能信息，根据神魔特殊技能类型和特殊技能等级
function BianShenData:GetSpecialSkillInfoByTypeLevel(skill_type, skill_level)
	for k, v in pairs(self.special_skill_cfg) do
		if v.active_skill_type == skill_type and v.skill_level == skill_level then
			return v
		end
	end

	return nil
end


---------------------大小目标-------------------
function BianShenData:SetGoalInfo(protocol)
	self.goal_info = {}
	self.goal_info.open_system_timestamp = protocol.open_system_timestamp
	self.goal_info.active_flag = protocol.active_flag
	self.goal_info.fetch_flag = protocol.fetch_flag
	self.goal_info.active_special_attr_flag = protocol.active_special_attr_flag
end

function BianShenData:GetGoalInfo()
	return self.goal_info
end

function BianShenData:GetItemGoalInfo(goal_type, sys_type)
	if self.goal_item_cfg and self.goal_item_cfg[goal_type] and self.goal_item_cfg[goal_type][sys_type] then
		return self.goal_item_cfg[goal_type][sys_type]
	end
end

function BianShenData:GetGoalAttr(goal_type)
	if self.goal_attr_cfg and self.goal_attr_cfg[goal_type] then
		return self.goal_attr_cfg[goal_type].add_per
	end
end

function BianShenData:GetGoalCfg(goal_type)
	if self.goal_attr_cfg then
		return self.goal_attr_cfg[goal_type]
	end
end

-- 获取大目标幻化形象
function BianShenData:GetBigGoalCfg()
	return self.huanhua_cfg[1]
end

-- 获取当前使用的幻化id
function BianShenData:GetCurrentUseHuanHuaId()
	return self.use_huanhua_id
end