ShengXiaoData = ShengXiaoData or BaseClass()
ShengXiaoData.SHENGXIAOCOUNT = 3

function ShengXiaoData:__init()
	if ShengXiaoData.Instance then
		print_error("[ShengXiaoData] Attemp to create a singleton twice !")
	end
	ShengXiaoData.Instance = self
	self.role_goal_cfg = ConfigManager.Instance:GetAutoConfig("role_big_small_goal_auto") or {}
	self.goal_item_cfg = ListToMap(self.role_goal_cfg.item_cfg, "reward_type", "system_type")
	self.goal_attr_cfg = ListToMap(self.role_goal_cfg.attr_cfg, "system_type")

	local chinese_zodiac_cfg = ConfigManager.Instance:GetAutoConfig("chinese_zodiac_cfg_auto") or {}
	-- self.equip_cfg = ListToMap(chinese_zodiac_cfg.equip, "equip_type", "level")

	-- self.equip_type_quality_cfg = ListToMap(chinese_zodiac_cfg.equip, "equip_type", "quality", "level")

	self.equip_suit_cfg = chinese_zodiac_cfg.equip_suit

	self.shengxiao_color_cfg = ListToMap(chinese_zodiac_cfg.shengxiao_color, "index")

	self:SetColorMaxLevelList()

	self.single_info_cfg = ListToMap(chinese_zodiac_cfg.single_info, "seq", "level")

	self.xinghun_cfg = ListToMap(chinese_zodiac_cfg.xinghun, "seq", "level")

	self.funny_trun_cfg =  ListToMap(chinese_zodiac_cfg.funny_trun_combine, "box_index")

	self.funny_trun_combine = chinese_zodiac_cfg.funny_trun_combine

	self.miji_cfg = chinese_zodiac_cfg.miji_cfg

	self.bead_chapter_attr_cfg = chinese_zodiac_cfg.bead_chapter_attr

	self.miji_open_limit_cfg = chinese_zodiac_cfg.miji_open_limit

	self.miji_kong_limit_cfg = chinese_zodiac_cfg.miji_kong_open_limit

	self.point_effect_cfg = chinese_zodiac_cfg.point_effect

	self.starsoul_point_effect_cfg = chinese_zodiac_cfg.xinghun_effect

	self.xingling_point_effect_cfg = chinese_zodiac_cfg.xingling_point_effect

	self.bead_cfg = chinese_zodiac_cfg.bead

	self.xinghun_extra_cfg = chinese_zodiac_cfg.xinghun_extra_info

	self.xingling_cfg = chinese_zodiac_cfg.xingling

	self.suit_info_cfg = chinese_zodiac_cfg.suit_info
	self.other_cfg = chinese_zodiac_cfg.other
	table.sort(self.suit_info_cfg, function(a, b)
		return a.level < b.level
	end)

	self.combine_attr_cfg = chinese_zodiac_cfg.combine_attr

	self.zodiac_level_list = {}
	self.chinesezodiac_equip_list = {}
	self.xinghun_level_list = {}
	self.xinghun_level_max_list = {}
	self.xinghun_baoji_value_list = {}
	for i = 1, GameEnum.CHINESE_ZODIAC_SOUL_MAX_TYPE_LIMIT do
		self.zodiac_level_list[i] = 0
		self.xinghun_level_list[i] = 0
		self.xinghun_level_max_list[i] = 0
		self.xinghun_baoji_value_list[i] = 0
		self.chinesezodiac_equip_list[i]  = {}
		for j = 1, GameEnum.CHINESE_ZODIAC_EQUIP_SLOT_MAX_LIMIT do
			self.chinesezodiac_equip_list[i][j] = 0
		end
	end
	self.select_equip_index = 1
	self.uplevel_index = 1
	self.curr_chapter = 1
	self.is_stop_ernie_animation = false
	self.equip_item_info = {}
	self.active_list = {}
	self.chapter_list = {}
	self.bead_by_combine_list = {}
	self.grid_seq_list = {}
	self.combine_type = {}
	self.ernie_bless_reward_list = {}
	self.cur_show_anim_list = {}
	self.spirit_list = {}
	self.chapter_total_cap = 0
	self.zodiac_progress = 1
	self.xinghun_progress = 1
	self.upgrade_zodiac = -1
	self.today_free_ggl_times = 0
	self.last_free_ggl_time = 0
	self.end_turn_index = 1
	self.miji_shengxiao_index = 1
	self.is_finish_all_chapter = 0
	self.equip_is_auto_buy = false
	self.miji_list = {}
	for i = 1, GameEnum.CHINESE_ZODIAC_SOUL_MAX_TYPE_LIMIT do
		self.miji_list[i]  = {}
		for j = 1, GameEnum.MIJI_KONG_NUM do
			self.miji_list[i][j] = -1
		end
	end

	RemindManager.Instance:Register(RemindName.ShengXiao_Equip, BindTool.Bind(self.CalcEquipRedPoint, self))
	RemindManager.Instance:Register(RemindName.ShengXiao_Uplevel, BindTool.Bind(self.CalcUpLevelRedPoint, self))
	RemindManager.Instance:Register(RemindName.ShengXiao_Spirit, BindTool.Bind(self.CalcSpiritRedPoint, self))
	RemindManager.Instance:Register(RemindName.ShengXiao_Piece, BindTool.Bind(self.CalcPieceRedPoint, self))
	RemindManager.Instance:Register(RemindName.ShengXiao_StarSoul, BindTool.Bind(self.CalcStarSoulRedPoint, self))
end

function ShengXiaoData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ShengXiao_Equip)
	RemindManager.Instance:UnRegister(RemindName.ShengXiao_Uplevel)
	RemindManager.Instance:UnRegister(RemindName.ShengXiao_Spirit)
	RemindManager.Instance:UnRegister(RemindName.ShengXiao_Piece)
	RemindManager.Instance:UnRegister(RemindName.ShengXiao_StarSoul)

	ShengXiaoData.Instance = nil

	PlayerPrefsUtil.DeleteKey("enter_xingzuoyiji")
	self.xinghun_stone_num = nil
end

--提取出每种装备颜色对应的阶数列表
function ShengXiaoData:SetColorMaxLevelList()
	--只取其中一个部位就好了
	-- local pair_list = self.equip_cfg and self.equip_cfg[0] or {}
	-- for k, v in pairs(pair_list) do
	-- 	if v.level > 0 then
	-- 		if nil == self.color_max_level_list then
	-- 			self.color_max_level_list = {}
	-- 		end
	-- 		if nil == self.color_max_level_list[v.quality] then
	-- 			self.color_max_level_list[v.quality] = 0
	-- 		end
	-- 		self.color_max_level_list[v.quality] = self.color_max_level_list[v.quality] + 1
	-- 	end
	-- end
end

function ShengXiaoData:GetColorMaxLevelByColor(quality)
	if nil == self.color_max_level_list then
		return 0
	end
	return self.color_max_level_list[quality] or 0
end

function ShengXiaoData:SetShengXiaoAllInfo(all_info)
	self.zodiac_level_list = all_info.zodiac_level_list
	self.xinghun_level_list = all_info.xinghun_level_list
	self.xinghun_level_max_list = all_info.xinghun_level_max_list
	self.xinghun_baoji_value_list = all_info.xinghun_baoji_value_list
	self.chinesezodiac_equip_list = all_info.chinesezodiac_equip_list
	self.zodiac_progress = all_info.zodiac_progress
	self.xinghun_progress = all_info.xinghun_progress
	self.upgrade_zodiac = all_info.upgrade_zodiac
	self.miji_list = all_info.miji_list
end

function ShengXiaoData:SetOneMijiInfo(one_info)
	self.miji_list[one_info.zodiac_type + 1][one_info.kong_index + 1] = one_info.miji_index
end

function ShengXiaoData:SetEndTurnIndex(index)
	self.end_turn_index = index + 1
end

function ShengXiaoData:GetEndIndex()
	return self.end_turn_index
end

function ShengXiaoData:SetMijiShengXiaoIndex(index)
	self.miji_shengxiao_index = index
end

function ShengXiaoData:GetMijiShengXiaoIndex()
	return self.miji_shengxiao_index
end

function ShengXiaoData:GetMijiCountByindex(index)
	local count = 0
	for k,v in pairs(self.miji_list[index]) do
		if v > -1 then
			count = count + 1
		end
	end
	return count
end

function ShengXiaoData:GetMijiToSkillCd()
	local total_cd = 0
	for k,v in pairs(self.miji_list) do
		if v then
			for k1,v1 in pairs(v) do
				if v1 >= 0 then
					local cfg = self:GetMijiCfgByIndex(v1)
					if cfg.type == 11 then
						total_cd = total_cd + cfg.value
					end
				end
			end
		end
	end
	return total_cd < 6000 and total_cd or 6000
end

function ShengXiaoData:GetMijiOpenCfgByIndex(index)
	for k,v in pairs(self.miji_open_limit_cfg) do
		if index - 1 == v.index then
			return v
		end
	end
	return nil
end

function ShengXiaoData:GetKongIsOpenByIndex(index)
	for k,v in pairs(self.miji_kong_limit_cfg) do
		if index - 1 == v.index then
			return v.zodiac_level_limit
		end
	end
	return 0
end

function ShengXiaoData:GetBagMijiList()
	local bag_list = {}
	for k,v in pairs(self.miji_cfg) do
		local bag_num = ItemData.Instance:GetItemNumInBagById(v.item_id)
		if bag_num > 0 then
			local have_type = 1
			for k1,v1 in pairs(self.miji_list[self.miji_shengxiao_index]) do
				if v1 >=0 then
					local miji_type = self:GetMijiCfgByIndex(v1).type
					if v.type == miji_type then
						have_type = 0
					end
				end
			end
			local vo = {}
			vo.item_num = bag_num
			vo.item_id = v.item_id
			vo.cfg_index = v.index
			vo.have_type = have_type
			vo.level = v.level
			table.insert(bag_list, vo)
		end
	end
	table.sort(bag_list, SortTools.KeyUpperSorters("have_type", "level"))
	return bag_list
end

function ShengXiaoData:GetMijiCfgByIndex(index)
	for k,v in pairs(self.miji_cfg) do
		if v.index == index then
			return v
		end
	end
	return nil
end

function ShengXiaoData:GetMijiCfgByItemId(item_id)
	for k,v in pairs(self.miji_cfg) do
		if v.item_id == item_id then
			return v
		end
	end
	return nil
end

function ShengXiaoData:GetZodiacMijiList(index)
	return self.miji_list[index]
end

function ShengXiaoData:GetUpgradeZodiac()
	return self.upgrade_zodiac
end

function ShengXiaoData:SetTianXianAllInfo(all_info)
	self.curr_chapter = all_info.curr_chapter + 1
	self.active_list = all_info.active_list
	self.chapter_list = all_info.chapter_list
	self.bead_by_combine_list = all_info.bead_by_combine_list
	self.is_finish_all_chapter = all_info.is_finish_all_chapter
end

function ShengXiaoData:GetIsFinishAll()
	return self.is_finish_all_chapter
end

function ShengXiaoData:SetCurShowList(data)
	if next(data) then
		self.cur_show_anim_list = data
	end
end

function ShengXiaoData:GetCurShowList()
	return self.cur_show_anim_list
end

function ShengXiaoData:SetTianXiangSignBead(all_info)
	if self.chapter_list[all_info.chapter + 1] == nil or self.chapter_list[all_info.chapter + 1][all_info.y + 1] == nil
		or self.chapter_list[all_info.chapter + 1][all_info.y + 1][all_info.x + 1] == nil then
		return
	end
	self.chapter_list[all_info.chapter + 1][all_info.y + 1][all_info.x + 1] = all_info.type
end

function ShengXiaoData:SetTianXiangCombind(all_info)
	self.active_list[all_info.curr_chapter + 1] = all_info.active_list
	self.bead_by_combine_list[all_info.curr_chapter + 1] = self.bead_by_combine_list[all_info.curr_chapter + 1] or {}
	self.bead_by_combine_list[all_info.curr_chapter + 1] = all_info.bead_by_combine_list
end

function ShengXiaoData:GetShowAnimListByChatper(chapter)
	return self.bead_by_combine_list[chapter]
end

function ShengXiaoData:GetMaxChapter()
	return self.curr_chapter
end

function ShengXiaoData:GetTianXianInfoByChapter(y, x)
	local cur_chapter_list = self.chapter_list[self.curr_chapter]
	if cur_chapter_list == nil then
		return 0
	end
	if cur_chapter_list[y] == nil or cur_chapter_list[y][x] == nil then
		return 0
	end
	return cur_chapter_list[y][x]
end

function ShengXiaoData:GetTianxianInfoByPosAndChapter(chapter, y, x)
	if self.chapter_list[chapter] == nil or self.chapter_list[chapter][y] == nil or self.chapter_list[chapter][y][x] == nil then
		return 0
	end
	return self.chapter_list[chapter][y][x]
end

function ShengXiaoData:GetActiveList()
	return self.active_list
end

function ShengXiaoData:GetActiveListByChatper(chapter)
	return self.active_list[chapter] or {}
end

function ShengXiaoData:GetOneChapterActive(chapter)
	local active_list = ShengXiaoData.Instance:GetActiveListByChatper(chapter)
	for k,v in pairs(active_list) do
		if v <= 0 then
			return false
		end
	end
	return true
end

function ShengXiaoData:GetChapterActiveNum(chapter)
	local active_list = ShengXiaoData.Instance:GetActiveListByChatper(chapter)
	local num = 0
	for k,v in pairs(active_list) do
		if v > 0 then
			num = num + 1
		end
	end
	return num
end

function ShengXiaoData:GetZodiacLevelList()
	return self.zodiac_level_list
end

function ShengXiaoData:GetZodiacLevelByIndex(index)
	return self.zodiac_level_list[index] or 0
end

function ShengXiaoData:GetMijiIsOpenByIndex(index)
	local miji_open_cfg = self:GetMijiOpenCfgByIndex(index)
	if index > 1 then
		local miji_count = self:GetMijiCountByindex(index - 1)
		if miji_open_cfg then
			return miji_count >= miji_open_cfg.last_miji_num_limit
		end
	else
		return true
	end
	return false
end

function ShengXiaoData:GetMijiLimitCount(index)
	local miji_open_cfg = self:GetMijiOpenCfgByIndex(index)
	return miji_open_cfg.last_miji_num_limit
end

function ShengXiaoData:SetOneEquipInfo(zodiac_type, equip_type, equip_level)
	self.chinesezodiac_equip_list[zodiac_type + 1][equip_type + 1] = equip_level
end

function ShengXiaoData:GetZodiacInfoByIndex(index, level)
	local cfg = self.single_info_cfg[index - 1]
	return cfg and cfg[level] or nil
end

function ShengXiaoData:GetShengXiaoLevelAllCap()
	local cfg = self.single_info_cfg
	local cap = 0
	for k,v in pairs(self.single_info_cfg) do
		local level = self:GetZodiacLevelByIndex(k + 1) or 0
		cap = cap + CommonDataManager.GetCapability(v[level] or {})
	end
	return cap
end

function ShengXiaoData:GetMaxZodiacLevel()
	local max_level = 0
	return max_level
end

function ShengXiaoData:SetEquipListByindex(index)
	self.select_equip_index = index
end

function ShengXiaoData:GetEquipListByindex()
	return self.select_equip_index
end

function ShengXiaoData:GetCurEquipindex(index)
	local equip_list = self:GetEquipLevelListByindex(self.select_equip_index)
	return equip_list[index + 1]
end

function ShengXiaoData:GetEquipActiveNum(index)
	local active_list = self:GetEquipLevelListByindex(index)
	local num = 0
	for k,v in pairs(active_list) do
		if v > 0 then
			num = num + 1
		end
	end
	return num
end

function ShengXiaoData:GetActiveSuitPower(index)
	local equip_list = self:GetEquipLevelListByindex(index)
	local current_all_suit = ShengXiaoData.Instance:GetShengXiaoSuitCfgByIndex(index)
	if equip_list == nil or next(equip_list) == nil or current_all_suit == nil then return end
	self.new_color_list = {}
	for k, v in pairs(equip_list) do
		if v > 0 then
			local item_cfg, big_type = ItemData.Instance:GetItemConfig(v)
			local color_index = item_cfg.color >= GameEnum.ITEM_COLOR_RED and GameEnum.ITEM_COLOR_RED or item_cfg.color
			self.new_color_list[color_index] = self.new_color_list[color_index] or 0
			self.new_color_list[color_index] = self.new_color_list[color_index] + 1
		end
	end

	local total_value = 0
	local total_attr = CommonStruct.Attribute()
	for k, v in pairs(current_all_suit) do
		if self.new_color_list[v.suit_color] and self.new_color_list[v.suit_color] >= v.need_count then
			local base_attr = CommonDataManager.GetAttributteByClass(v)
			total_attr = CommonDataManager.AddAttributeAttr(total_attr, base_attr)
		end
	end

	local all_value = CommonDataManager.GetCapability(total_attr) or 0

	local arrt_list_no_parcent = CommonDataManager.GetAttributteNoParcent(total_attr)
	total_value = CommonDataManager.GetCapability(arrt_list_no_parcent)

 	return total_value, all_value
end

function ShengXiaoData:GetEquipLevelListByindex(index)
	return self.chinesezodiac_equip_list[index]
end

function ShengXiaoData:GetOneEquipLevel(equip_type, equip_index)
	return self.chinesezodiac_equip_list[equip_type][equip_index]
end

function ShengXiaoData:GetEquipCfgByIndexAndLevel(index, level, quality)
	-- local cfg = self.equip_type_quality_cfg[index]
	-- if cfg and cfg[quality] and cfg[quality][level] then
	-- 	return cfg[quality][level]
	-- end
	return nil
end

function ShengXiaoData:GetEquipAllCapByListIndex(list_index)
	local cap = 0
	-- for k,v in pairs(self.equip_cfg) do
	-- 	local cur_equip_level = self:GetOneEquipLevel(list_index, k) or 0
	-- 	cap = cap + CommonDataManager.GetCapability(v[cur_equip_level] or {})
	-- end
	return cap
end

function ShengXiaoData:GetShengXiaoSuitCfgByIndex(index)
	local data = {}
	local index = index - 1
	if nil ~= self.equip_suit_cfg then
		for k,v in pairs(self.equip_suit_cfg) do
			if v.seq == index then
			 table.insert(data, v)  
			end
		end
	end
	return data
end

function ShengXiaoData:GetHasBetterEquip(item_id, enable, select_index)
	local cur_level = self:GetZodiacLevelByIndex(select_index)
	if cur_level <= 0 then return false end

	local equip_list = self:GetBagEquipDataList()
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(item_id)
	if next(equip_list) == nil or item_cfg == nil then return false end

	for k,v in pairs(equip_list) do
		if v.sub_type == item_cfg.sub_type and (v.quality > item_cfg.quality or enable) then
			return true
		end
	end

	return false
end

function ShengXiaoData:GetBagEquipDataList()
	local bag_equip_list = ItemData.Instance:GetItemListByBigType(GameEnum.ITEM_BIGTYPE_EQUIPMENT)
	local equip_list = {}

	for _, v in pairs(bag_equip_list) do
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
		if nil ~= item_cfg
			and GameEnum.ITEM_BIGTYPE_EQUIPMENT == big_type
			and EquipData.IsShengXiaoEqType(item_cfg.sub_type) then
			v.quality = item_cfg.quality
			v.recyclget = item_cfg.recyclget
			v.sub_type = item_cfg.sub_type
			table.insert(equip_list, v)
		end
	end
 	table.sort(equip_list, SortTools.KeyUpperSorters("quality", "item_id"))
	self.equip_item_info = equip_list
	return equip_list
end

function ShengXiaoData:GetShengXiaoItemData(index)
	local equip_info = self:GetBagEquipDataList()
	return equip_info[index] or {}
end

function ShengXiaoData:GetShengXiaoCount()
	return #self.equip_item_info
end

function ShengXiaoData:GetSameQualityItem(quality)
	local item_list = {}

	for k,v in pairs(self.equip_item_info) do
		-- local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if v.quality == quality then
			item_list[k] = v
		end
	end

	return item_list
end

function ShengXiaoData:GetBagBestSpirit(data_list, is_no_bag)
	data_list = data_list or self:GetBagSpiritDataList()

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

		-- if a.param and b.param and #a.param.xianpin_type_list ~= #b.param.xianpin_type_list then
		-- 	return #a.param.xianpin_type_list > #b.param.xianpin_type_list
		-- end

		if item_cfg_a.bag_type ~= item_cfg_b.bag_type then
			return item_cfg_a.bag_type < item_cfg_b.bag_type
		end

		return a.item_id > b.item_id
	end)

	return temp_list
end

function ShengXiaoData:GetCurCanUpByIndex(index)
	local level = self:GetZodiacLevelByIndex(index)
	local cfg = self:GetZodiacInfoByIndex(index, level)
	local befor_level = self:GetZodiacLevelByIndex(index - 1)
	if cfg and cfg.level_limit > befor_level then
		return false
	end
	return true
end

function ShengXiaoData:GetShowRate()
	for i = 1, 12 do
		if not self:GetCurCanUpByIndex(i) then
			return i
		end
	end
	return 1
end

function ShengXiaoData:GetCanUpLevelRemindByIndex(index)
	local level = self:GetZodiacLevelByIndex(index)
	if level >= GameEnum.CHINESE_ZODIAC_LEVEL_MAX_LIMIT then
		return false
	end
	local cfg = self:GetZodiacInfoByIndex(index, level + 1)
	local befor_level = self:GetZodiacLevelByIndex(index - 1)
	-- local zodiac_progress = self:GetZodiacProgress()
	-- if index <= ShengXiaoData.SHENGXIAOCOUNT then 
	-- 	if index > zodiac_progress then
	-- 		return false
	-- 	end
	-- end
	if cfg then
		if cfg.level_limit > 0 and nil ~= befor_level then
			if cfg.level_limit > befor_level then
				return false
			end
			return ItemData.Instance:GetItemNumInBagById(cfg.item_id) >= cfg.expend
		end
		return ItemData.Instance:GetItemNumInBagById(cfg.item_id) >= cfg.expend
	end
	return false
end

function ShengXiaoData:GetSpiritRemindByStarIndex(index)
	local info = self:GetXingLingInfo(index)
	if nil == info or nil == info.level then
		return false
	end

	if info.level >= 39 then
		return false
	end
	
	local cfg = self:GetXingLingCfg(index - 1, info.level)
	return next(cfg) and (ItemData.Instance:GetItemNumInBagById(cfg.uplevel_stuff_id) >= cfg.uplevel_stuff_num) or false
end

function ShengXiaoData:GetEquipRemindByEquipTypeAndIndex(equip_type, equip_index, quality)
	local level = self:GetOneEquipLevel(equip_type, equip_index)
	if level >= GameEnum.CHINESE_ZODIAC_MAX_EQUIP_LEVEL then
		return false
	end
	local cfg = self:GetEquipCfgByIndexAndLevel(equip_index - 1, level + 1, quality)
	if nil == cfg then
		return false
	end

	local star_level = self:GetZodiacLevelByIndex(equip_type)
	local zodiac_level = cfg.zodiac_level or 0
	if star_level < zodiac_level then
		return false
	end
	return ItemData.Instance:GetItemNumInBagById(cfg.consume_stuff_id) >= cfg.consume_stuff_num
end

function ShengXiaoData:GetEquipRemindByStarIndex(star_index)
	local equip_level_list = ShengXiaoData.Instance:GetEquipLevelListByindex(star_index)
	if equip_level_list == nil then
		return false
	end

	for i = 1, 5 do 
		if equip_level_list[i] > 0 then
			local flag = self:GetHasBetterEquip(equip_level_list[i], false, star_index)
			if flag then
				return true
			end
		else
			local flag = self:GetHasBetterEquip(65000 + i - 1, true, star_index)
			if flag then
				return true
			end
		end
	end

	return false
end

function ShengXiaoData:GetChapterAttrByChapter(chapter)
	for k,v in pairs(self.bead_chapter_attr_cfg) do
		if v.chapter == chapter - 1 then
			return v
		end
	end
	return nil
end

function ShengXiaoData:GetTotalLevel()
	local total_level = 0
	for i = 1, GameEnum.CHINESE_ZODIAC_SOUL_MAX_TYPE_LIMIT do
		total_level = total_level + self:GetZodiacLevelByIndex(i)
	end
	return total_level
end

function ShengXiaoData:GetTotalAttrListAndAttrState(is_next)
	local total_level = self:GetTotalLevel()
	local is_show_cur = true
	local is_show_next = true


	local suit_cfg = {}
	for k, v in pairs(self.suit_info_cfg) do
		if total_level == 0 and v.level == total_level then
			suit_cfg = self.suit_info_cfg[k + 1]
			is_show_cur = false
			break
		end

		if v.level > total_level then
			if k == 2 then
				suit_cfg = v
				is_show_cur = false
				break
			end

			if is_next then
				suit_cfg = v
				break
			end

			suit_cfg = self.suit_info_cfg[k - 1]
			break
		end

		if v.level == total_level and k < #self.suit_info_cfg then
			if is_next then
				suit_cfg = self.suit_info_cfg[k + 1]
				break
			end

			suit_cfg = v
			break
		end

		if k == #self.suit_info_cfg then
			is_show_next = false
			suit_cfg = v
			break
		end
	end

	return suit_cfg, is_show_cur, is_show_next
end

function ShengXiaoData:GetSuitCfgByLevel(level)
	for k,v in pairs(self.suit_info_cfg) do
		if v.level == level then
			return v
		end
	end
	return nil
end

function ShengXiaoData:GetShengXiaoIndexByCostItem(item_id)
	for k,v in pairs(self.single_info_cfg) do
		if v.item_id == item_id then
			return v.seq + 1
		end
	end
	return 0
end

function ShengXiaoData:SetUplevelIndex(index)
	self.uplevel_index = index
end

function ShengXiaoData:GetUplevelIndex()
	return self.uplevel_index
end

function ShengXiaoData:GetCombineCfgByIndex(index)
	for k,v in pairs(self.combine_attr_cfg) do
		if index == v.seq then
			local cfg = TableCopy(v)
			return cfg
		end
	end
	return nil
end

function ShengXiaoData:GetCombineCapByChapter(chapter_id)
	local cap = 0
	local actve_data_list = self:GetActiveListByChatper(chapter_id) or {}
	local skill_cfg = self:GetChapterAttrByChapter(chapter_id) or {}
	local add_attr = self:GetOneChapterActive(chapter_id) and skill_cfg.per_attr or 0
	for k,v in pairs(self.combine_attr_cfg) do
		for i = 1, 3 do
			if actve_data_list[i] == 1 and (chapter_id - 1) * 3 + i - 1 == v.seq then
				cap = cap + CommonDataManager.GetCapability(v) * (100 + add_attr) / 100
			end
		end
	end
	if self.chapter_list[chapter_id] then
		for k,v in pairs(self.chapter_list[chapter_id]) do
			for k1,v1 in pairs(v) do
				if v1 > 0 then
					local detail_cfg = ShengXiaoData.Instance:GetBeadCfg(v1) or {}
					cap = cap + CommonDataManager.GetCapability(detail_cfg)
				end
			end
		end
	end
	return cap
end

function ShengXiaoData:GetOtherCfg()
	return self.other_cfg[1]
end

function ShengXiaoData:GetCostByMijiLevel(level)
	return self.other_cfg[1]["miji_compound_consume_gold" .. level + 1] or 0
end

-- 得到星座开锁进程
function ShengXiaoData:GetZodiacProgress()
	return self.zodiac_progress
end

---------------------------------------------摇奖机-----------------------------------------------

function ShengXiaoData:GetFunnyTrunCombine()
	return self.funny_trun_combine
end

function ShengXiaoData:SetGunGunLeInfo(protocol)
	local combine_type = {}
	local random_list = {}
	local result_index_list = protocol.combine_type 																												--傻逼策划非要加一个排列组合表在客户端这边让客户端自己取随机排列,就因为服务器懒得看之前逻辑
	
	if self.funny_trun_combine then
		for k, v in pairs(self.funny_trun_combine) do
			if v.zuhe_shunxu then
				random_list[k] = Split(v.zuhe_shunxu, "|")
			end
		end
	end
	if result_index_list then
		for k, v in pairs(result_index_list) do
			if random_list[v] then
				local result_index = math.floor(math.random(1, #random_list[v]))
				local temp_radom = random_list[v]
				combine_type[k] = temp_radom[result_index]
			end
		end
	end
	self.today_free_ggl_times = protocol.today_free_ggl_times
	self.last_free_ggl_time = protocol.last_free_ggl_time
	self.ernie_bless_reward_list = {}
	for i = 1, protocol.count do
		local cfg = self:GetRollInfoByType(combine_type[i])
		if cfg then
			for k,v in pairs(cfg.reward_item) do
				local data = {}
				data.item_id = v.item_id
				data.num = v.num
				data.is_bind = v.is_bind
				table.insert(self.ernie_bless_reward_list, data)
			end
		end
	end
end

-- 得到摇奖机配置
function ShengXiaoData:GetRollInfoByType(combine_type_str)
	if combine_type_str == nil then
		return
	end
	local combine_type = tonumber(combine_type_str)
	local index = 0
	local index1 = combine_type % 10
	combine_type = math.floor(combine_type / 10)
	local index2 = combine_type % 10
	combine_type = math.floor(combine_type / 10)
	local index3 = combine_type

	local same_count = 0
	-- 有3个相同数字
	if index1 == index2 and index1 == index3 then
		same_count = 3
		index = index1
	-- 有2个相同数字
	elseif index1 == index2 then
		same_count = 2
		index = index1
	elseif index1 == index3 then
		same_count = 2
		index = index1
	elseif index2 == index3 then
		same_count = 2
		index = index2
	end
	return self:FindFunnyTrunCfg(same_count, index)
end

function ShengXiaoData:FindFunnyTrunCfg(same_count, index)
	if same_count >= 2 then
		local find = false
		local cfg = nil
		for k1,v1 in pairs(self.funny_trun_combine) do
			if v1.combine_same_num == same_count then
				local combine_type_list = {}
				if type(v1.combine_type) == "number" then
					combine_type_list[1] = v1.combine_type
				elseif type(v1.combine_type) == "string" then
					combine_type_list = Split(v1.combine_type, ",")
				end
				for k2,v2 in pairs(combine_type_list) do
					if tonumber(v2) == index then
						find = true
						cfg = v1
						break
					end
				end
			end
		end
		if not find then
			return self:FindFunnyTrunCfg(same_count - 1, index)
		else
			return cfg
		end
	else
		return self:GetDefaultFunnyTrunCfg()
	end
end

-- 得到摇奖机安慰奖
function ShengXiaoData:GetDefaultFunnyTrunCfg()
	for k,v in pairs(self.funny_trun_combine) do
		if v.combine_same_num == 0 then
			return v
		end
	end
end

function ShengXiaoData:SetErnieIsStopPlayAni(switch)
	self.is_stop_ernie_animation = switch
end

function ShengXiaoData:GetErnieIsStopPlayAni()
	return self.is_stop_ernie_animation
end

-- 得到摇奖机奖励列表
function ShengXiaoData:GetErnieBlessRewardDataList()
	return self.ernie_bless_reward_list
end

function ShengXiaoData:CalcEquipRedPoint()
	for i = 1, 12 do
		if self:GetEquipRemindByStarIndex(i) then
			return 1
		end
	end
	return 0
end

function ShengXiaoData:CalcUpLevelRedPoint()
	local goal_info = self:GetGoalInfo()
	if goal_info ~= nil and goal_info.active_flag ~= nil and goal_info.fetch_flag ~= nil then
		if (goal_info.active_flag[0] == 1 and goal_info.fetch_flag[0] == 0) or (goal_info.fetch_flag[0] == 1 and goal_info.active_flag[1] == 1 and goal_info.fetch_flag[1] == 0) then
			return 1
		end
	end

	for i = 1, 12 do
		if self:GetCanUpLevelRemindByIndex(i) then
			return 1
		end
	end

	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.ACTIVITY_TYPE_XINGZUOYIJI) then
		local gahter_count = RelicData.Instance:GetNowGatherNormalBoxNum()
	    local cfg = RelicData.Instance:GetRelicCfg().other[1]
		local count = cfg.common_box_gather_limit - gahter_count 
		return count > 0 and 1 or 0
	end
	return 0
end

-- 星灵红点
function ShengXiaoData:CalcSpiritRedPoint()
	local flag = 0
	local max_chatpter = ShengXiaoData.Instance:GetMaxChapter()
	if max_chatpter > 1 then
		max_chatpter = max_chatpter - 1
	end
	if max_chatpter == 5 and ShengXiaoData.Instance:GetIsFinishAll() == 1 then
		max_chatpter = 5
	end
	for i = 1, max_chatpter do
		if self:GetSpiritRemindByStarIndex(i) then
			flag =  1
			break
		end
	end
	return flag
end

-- 星魂红点
function ShengXiaoData:SetXingHunMaterialNum()
	local cfg = self:GetStarSoulInfoByIndexAndLevel(1, 0)
	if not cfg then return 0 end
	local material_num = ItemData.Instance:GetItemNumInBagById(cfg.consume_stuff_id)
	self.xinghun_stone_num = material_num
end

function ShengXiaoData:CalcStarSoulRedPoint()
	local cfg = self:GetStarSoulInfoByIndexAndLevel(1, 0)
	if not cfg then return 0 end
	local material_num = ItemData.Instance:GetItemNumInBagById(cfg.consume_stuff_id)
	if self.xinghun_stone_num and self.xinghun_stone_num >= material_num then return 0 end

	local flag = 0

	if OpenFunData.Instance:CheckIsHide("shen_ge_godbody") ~= false then

		local zodiac_progress = self:GetStarSoulProgress()
		local index = 0
		local level = 100000
		local temp_data = {}
		for i = 1, zodiac_progress do	
			local temp_level = ShengXiaoData.Instance:GetStarSoulMaxLevelByIndex(i)
			if level > temp_level then
				level = temp_level
				index = i
			end
			temp_data[i]= ShengXiaoData.Instance:GetStarSoulMaxLevelByIndex(i)
		end

		local cur_cfg = self:GetStarSoulInfoByIndexAndLevel(index, level)
		if nil == cur_cfg then 
			return flag
		end
		local item_num = ItemData.Instance:GetItemNumInBagById(cur_cfg.consume_stuff_id)
		
		if item_num >= cur_cfg.consume_stuff_num then
			flag = 1
		else
			flag = 0
		end
	end

	local zodiac_progress = self:GetStarSoulProgress()
	for i = 1, 12 do
		if self:GetStarSoulCanUp(i) and i > zodiac_progress then
			flag = 1
			break
		end
	end
	
	return flag
end

-- 龙珠界面摇奖机红点
function ShengXiaoData:CalcErnieRedPoint()
	local flag = 0
	if self:IsErnieCanFree() then
		flag = 1
	end
	local replacement_id = self:GetReplaceOneID()
	local open_box_30_use_itemid = self:GetReplaceTenID()
	local item_count_one = ItemData.Instance:GetItemNumInBagById(replacement_id)
	local item_count_Ten = ItemData.Instance:GetItemNumInBagById(open_box_30_use_itemid)
	if item_count_one > 0 or item_count_Ten > 0 then
		return 1
	end
	return flag
end

--摇奖按钮一次红点
function ShengXiaoData:ErnieRedPointOne()
	local flag = false
	if self:IsErnieCanFree() then
		flag = true
	end
	local replacement_id = self:GetReplaceOneID()
	local item_count_one = ItemData.Instance:GetItemNumInBagById(replacement_id)
	if item_count_one > 0 then
		flag = true
	end
	return flag
end

--摇奖按钮十次红点
function ShengXiaoData:ErnieRedPointTen()
	local flag = false
	local open_box_30_use_itemid = self:GetReplaceTenID()
	local item_count_Ten = ItemData.Instance:GetItemNumInBagById(open_box_30_use_itemid)
	if item_count_Ten > 0 then
		flag = true
	end
	return flag
end

--主界面龙珠界面红点
function ShengXiaoData:CalcPieceRedPoint()
	if not self.has_open_piece then
		local bag_list = self:GetBeadInBagList()
		for k,v in pairs(bag_list) do
			if v.num > 0 then
				return 1
			end
		end
	end

	if self:IsErnieCanFree() then
		return 1
	end

	local replacement_id = self:GetReplaceOneID()
	local open_box_30_use_itemid = self:GetReplaceTenID()
	local item_count_one = ItemData.Instance:GetItemNumInBagById(replacement_id)
	local item_count_Ten = ItemData.Instance:GetItemNumInBagById(open_box_30_use_itemid)
	if item_count_one > 0 or item_count_Ten > 0 then
		return 1
	end
	return 0
end

function ShengXiaoData:SetPieceOpenState(state)
	self.has_open_piece = state
end

function ShengXiaoData:GetNextFreeErnieTime()
	local cd = self:GetFreeCD()
	return self.last_free_ggl_time + cd
end

-- 得到摇奖机剩下的免费次数
function ShengXiaoData:GetRestFreeCount()
	local count = 0
	local other_cfg = self:GetOtherCfg()
	count = math.max(0, other_cfg.ggl_free_times - self.today_free_ggl_times)
	return count
end

-- 得到摇奖机免费次数CD
function ShengXiaoData:GetFreeCD()
	local cd = 0
	local other_cfg = self:GetOtherCfg()
	cd = other_cfg.ggl_free_times_cd or 0
	return cd
end

-- 摇奖机是否可以免费
function ShengXiaoData:IsErnieCanFree()
	local rest_free_count = self:GetRestFreeCount()
	if rest_free_count > 0 then
		local rest_time = self:GetNextFreeErnieTime() - TimeCtrl.Instance:GetServerTime()
		if rest_time <= 0 then
			return true
		end
	end
	return false
end

function ShengXiaoData:GetReplaceOneID()
	local replacement_id = 0
	local other_cfg = self:GetOtherCfg()
	if nil == other_cfg or nil == next(other_cfg) then
		return replacement_id
	end
	return other_cfg.replacement_id
end

function ShengXiaoData:GetReplaceTenID()
	local open_box_30_use_itemid = 0
	local other_cfg = self:GetOtherCfg()
	if nil == other_cfg or nil == next(other_cfg) then
		return open_box_30_use_itemid
	end
	return other_cfg.open_box_30_use_itemid
end

function ShengXiaoData:SetChapterTotalCap(cap)
	self.chapter_total_cap = cap
end

function ShengXiaoData:GetChapterTotalCap()
	return self.chapter_total_cap
end

function ShengXiaoData:GetBeadCfg(bead_type)
	for k,v in pairs(self.bead_cfg) do
		if bead_type == v.type then
			return v
		end
	 end
	 return nil
end

function ShengXiaoData:GetBeadInBagList()
	local bag_list = {}
	for k,v in pairs(self.bead_cfg) do
		local data = {}
		local item_num = ItemData.Instance:GetItemNumInBagById(v.item_id)
		data.item_id = v.item_id
		data.num = item_num
		data.is_from_shengxiao = true
		bag_list[v.type] = data
	end
	 return bag_list
end

function ShengXiaoData:GetPointEffectCfg(index)
	local point_effect_list = {}
	local cfg = {}
	for k,v in pairs(self.point_effect_cfg) do
		if v.seq + 1 == index then
			cfg = v
		end
	end
	for i = 1, 16 do
		if cfg["point" .. i .. "_x"] and cfg["point" .. i .. "_y"]
			and cfg["point" .. i .. "_y"] ~= "" and cfg["point" .. i .. "_x"] ~= "" then
			point_effect_list[i] = {}
			point_effect_list[i].x = cfg["point" .. i .. "_x"]
			point_effect_list[i].y = cfg["point" .. i .. "_y"]
		end
	end
	return point_effect_list
end

function ShengXiaoData:SetXinglingInfo(all_info)
	self.spirit_list = all_info
end

function ShengXiaoData:GetXingLingInfo(index)
	return self.spirit_list.xingling_list and self.spirit_list.xingling_list[index] or {}
end

function ShengXiaoData:GetXingLingAllInfo()
	return self.spirit_list
end

function ShengXiaoData:SaveEquipIsAutoBuy(is_auto_buy)
	self.equip_is_auto_buy = is_auto_buy
end

function ShengXiaoData:GetEquipIsAutoBuy()
	return self.equip_is_auto_buy
end

function ShengXiaoData:GetXingLingCfg(id, level)
	if not level or level > 39 then return {} end
	local cur_level = level >= 0 and level or 0
	local cfg = {}
	for k,v in pairs(self.xingling_cfg) do
		if v.id == id and v.level == cur_level then
			cfg = v
		end
	end
	return cfg
end

function ShengXiaoData:GetShowItems(id, level)
	local other_cfg = self:GetXingLingCfg(id, level)
	local data = {}
	data.item_id = other_cfg.uplevel_stuff_id
	return data
end

function ShengXiaoData:GetXinglingPointEffectCfg(index)
	local point_effect_list = {}
	local cfg = {}
	for k,v in pairs(self.xingling_point_effect_cfg) do
		if v.seq + 1 == index then
			cfg = v
		end
	end
	for i = 1, 16 do
		if cfg["point" .. i .. "_x"] and cfg["point" .. i .. "_y"]
			and cfg["point" .. i .. "_y"] ~= "" and cfg["point" .. i .. "_x"] ~= "" then
			point_effect_list[i] = {}
			point_effect_list[i].x = cfg["point" .. i .. "_x"]
			point_effect_list[i].y = cfg["point" .. i .. "_y"]
		end
	end
	return point_effect_list
end

--------------------------------星魂--------------------

function ShengXiaoData:GetStarSoulPointCfg(index)
	local point_effect_list = {}
	local cfg = {}
	for k,v in pairs(self.starsoul_point_effect_cfg) do
		if v.seq + 1 == index then
			cfg = v
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

function ShengXiaoData:GetStarSoulLevelList()
	return self.xinghun_level_list
end

function ShengXiaoData:GetStarSoulLevelByIndex(index)
	return self.xinghun_level_list[index] or 0
end

function ShengXiaoData:GetStarSoulMaxLevelList()
	return self.xinghun_level_max_list
end

function ShengXiaoData:GetStarSoulMaxLevelByIndex(index)
	return self.xinghun_level_max_list[index] or 0
end


function ShengXiaoData:GetStarSoulBaojiList()
	return self.xinghun_baoji_value_list
end

function ShengXiaoData:GetStarSoulBaojiByIndex(index)
	return self.xinghun_baoji_value_list[index] or 0
end

-- 得到星魂开锁进程
function ShengXiaoData:GetStarSoulProgress()
	return self.xinghun_progress
end

function ShengXiaoData:GetStarSoulInfoByIndexAndLevel(index, level)
	local cfg = self.xinghun_cfg[index - 1]
	return cfg and cfg[level] or nil
end

function ShengXiaoData:GetNextStarSoulInfoByIndexAndLevel(index, level, attr_type)
	local cur_cfg = self:GetStarSoulInfoByIndexAndLevel(index, level)
	local cfg = self.xinghun_cfg[index - 1]
	for i,v in ipairs(cfg) do
		if v[attr_type] > cur_cfg[attr_type] then
			return v
			-- return v[attr_type] - cur_cfg[attr_type]
		end
	end
	return {}
end

function ShengXiaoData:GetStarSoulMaxLevel(index)
	local cfg = self.xinghun_cfg[index - 1]
	return cfg and #cfg or 0
end

function ShengXiaoData:GetStarSoulCanUp(index)
	-- local level = self:GetStarSoulLevelByIndex(index)
	local befor_level = self:GetStarSoulMaxLevelByIndex(index - 1)
	local cfg = self:GetStarSoulInfoByIndexAndLevel(index, 0)
	if cfg and cfg.backwards_highest_level > befor_level then
		return false
	end
	return true
end

function ShengXiaoData:GetStarSoulTotal()
	local total_level = 0
	for k,v in pairs(self.xinghun_level_list) do
		total_level = total_level + v
	end
	local cur_cfg, next_cfg = nil, nil
	if total_level < self.xinghun_extra_cfg[1].level then
		next_cfg = self.xinghun_extra_cfg[1]
	elseif total_level >= self.xinghun_extra_cfg[#self.xinghun_extra_cfg].level then
		cur_cfg = self.xinghun_extra_cfg[#self.xinghun_extra_cfg]
	else
		for k,v in pairs(self.xinghun_extra_cfg) do
			if v.level > total_level then
				cur_cfg = self.xinghun_extra_cfg[k - 1]
				next_cfg = v
				break
			end
		end
	end
	return cur_cfg, next_cfg, total_level
end

function ShengXiaoData:GetCfgByBoxIndex(box_index)
	return self.funny_trun_cfg[box_index] 
end

function ShengXiaoData:GetShengXiaoColorByIndex(index)
	if self.shengxiao_color_cfg then
		return self.shengxiao_color_cfg[index]
	end
end

function ShengXiaoData:GetUpgradeNeedItemID(equip_type, quality)
	-- local cfg = self.equip_type_quality_cfg[equip_type]
	-- if cfg and cfg[quality] and cfg[quality][1] then
	-- 	return cfg[quality][1].consume_stuff_id or 0
	-- end
	return 0
end

function ShengXiaoData:GetEquipAttrNumByIndex(list_index, equip_index)
	local num = 0
	if list_index and equip_index then
		local shengxiaoIteminfo = ShengXiaoData.Instance:GetShengXiaoColorByIndex(list_index)
		if shengxiaoIteminfo and shengxiaoIteminfo.shengxiao_color then
			local shengxiao_color = shengxiaoIteminfo.shengxiao_color
			local cur_equip_level = ShengXiaoData.Instance:GetOneEquipLevel(list_index, equip_index) or 0
			local level = cur_equip_level == 0 and 1 or cur_equip_level
			local cur_cfg = ShengXiaoData.Instance:GetEquipCfgByIndexAndLevel(equip_index - 1, level, shengxiao_color)
			if cur_cfg then
				local one_level_attr = CommonDataManager.GetAttributteNoUnderline(cur_cfg)
				local show_attr = CommonDataManager.GetAttrNameAndValueByClass(one_level_attr)
				num = #show_attr
			end
		end
	end
	return num
end

-- 获取全身属性
function ShengXiaoData:GetAllBaseAttr()
	local attribute = CommonStruct.AttributeNoUnderline()
	for k,v in pairs(self.single_info_cfg) do
		local level = self:GetZodiacLevelByIndex(k + 1) or 0
		local attr_tab = CommonDataManager.GetAttributteNoUnderline(v[level] or {})
		attribute = CommonDataManager.AddAttributeAttrNoUnderLine(attribute, attr_tab)
	end
	return attribute
end

---------------------大小目标-------------------

function ShengXiaoData:SetGoalInfo(protocol)
	self.goal_info = {}
	self.goal_info.open_system_timestamp = protocol.open_system_timestamp
	self.goal_info.active_flag = protocol.active_flag
	self.goal_info.fetch_flag = protocol.fetch_flag
	self.goal_info.active_special_attr_flag = protocol.active_special_attr_flag
end

function ShengXiaoData:GetGoalInfo()
	return self.goal_info
end

function ShengXiaoData:GetItemGoalInfo(goal_type, sys_type)
	if self.goal_item_cfg and self.goal_item_cfg[goal_type] and self.goal_item_cfg[goal_type][sys_type] then
		return self.goal_item_cfg[goal_type][sys_type]
	end
end

function ShengXiaoData:GetGoalAttr(goal_type)
	if self.goal_attr_cfg and self.goal_attr_cfg[goal_type] then
		return self.goal_attr_cfg[goal_type].add_per
	end
end