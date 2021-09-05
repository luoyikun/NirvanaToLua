
ImageFuLingData = ImageFuLingData or BaseClass()

function ImageFuLingData:__init()
	if ImageFuLingData.Instance then
		print_error("[ItemData] Attemp to create a singleton twice !")
	end
	ImageFuLingData.Instance = self

	local image_fuling_cfg = ConfigManager.Instance:GetAutoConfig("img_fuling_cfg_auto")

	self.image_fuling_level_cfg = ListToMap(image_fuling_cfg.fuling_level, "system_type", "level")
	self.image_fuling_skill_level_cfg = ListToMap(image_fuling_cfg.fuling_skill, "system_type", "skill_level")
	self.image_fuling_stuff_cfg = ListToMap(image_fuling_cfg.fuling_stuff, "system_type", "stuff_id")
	self.jingjie_equip_per_add = image_fuling_cfg.jingjie_equip_per_add

	local talent_cfg = ConfigManager.Instance:GetAutoConfig("talent_auto")

	self.talent_list_cfg = ListToMap(talent_cfg.talent_list, "talent_type")
	self.talent_grid_list_cfg = ListToMap(talent_cfg.grid_list, "grid_id")
	self.talent_skill_cfg = ListToMap(talent_cfg.talent_skill, "skill_id", "skill_star")
	self.talent_skill_item_cfg = ListToMapList(talent_cfg.talent_skill, "book_id")
	self.talent_skill_type_cfg = ListToMapList(talent_cfg.talent_skill, "skill_type")
	self.talent_choujiang_stage_cfg = ListToMap(talent_cfg.choujiang_stage, "stage")
	self.flush_cost_cfg = talent_cfg.flush_cost
	self.talent_other_cfg = talent_cfg.other[1]

	self.fuling_tab_info_list = {
		IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_MOUNT,       --坐骑
		IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_WING,        --羽翼
		IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_HALO,        --光环
		IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_FIGHT_MOUNT, --战骑
		IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_SHENGONG,    --神弓
		IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_SHENYI,      --神翼
		IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_FOOT_PRINT,  --足迹
		IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_FABAO,		 --法宝
	}
	self.talent_tab_info_list = {
		TALENT_TYPE.TALENT_MOUNT,
		TALENT_TYPE.TALENT_WING,
		TALENT_TYPE.TALENT_HALO,
		TALENT_TYPE.TALENT_FIGHTMOUNT,
		TALENT_TYPE.TALENT_SHENGGONG,
		TALENT_TYPE.TALENT_SHENYI,
		TALENT_TYPE.TALENT_FOOTPRINT,
		TALENT_TYPE.TALENT_FABAO,
	}

	self.fuling_info_list = {}
	self.talent_info_list = {}
	self.free_chou_count = self.talent_other_cfg.free_count

	RemindManager.Instance:Register(RemindName.ImgFuLing, BindTool.Bind(self.GetImgFuLingRemind, self))
	RemindManager.Instance:Register(RemindName.ImgTalent, BindTool.Bind(self.GetImgTalentRemind, self))
	RemindManager.Instance:Register(RemindName.ImgTianFu, BindTool.Bind(self.GetTalentRemind, self))
	RemindManager.Instance:Register(RemindName.ImgSuXing, BindTool.Bind(self.GetFreeChouJiangTimes, self))
end

function ImageFuLingData:__delete()
	if ImageFuLingData.Instance then
		ImageFuLingData.Instance = nil
	end
	RemindManager.Instance:UnRegister(RemindName.ImgTalent)
	RemindManager.Instance:UnRegister(RemindName.ImgFuLing)
	RemindManager.Instance:UnRegister(RemindName.ImgTianFu)
	RemindManager.Instance:UnRegister(RemindName.ImgSuXing)
end

function ImageFuLingData:SetImgFuLingData(protocol)
	self.fuling_info_list = protocol.fuling_list
end

function ImageFuLingData:GetImgFuLingData(img_fuling_type)
	return self.fuling_info_list[img_fuling_type]
end

function ImageFuLingData:GetImgFuLingCapability(img_fuling_type, level)
	level = level or self.fuling_info_list[img_fuling_type].level
	local level_cfg = self:GetImgFuLingLevelCfg(img_fuling_type, level)
	if nil ~= level_cfg then
		local level_attr = CommonDataManager.GetAttributteByClass(level_cfg)
		return CommonDataManager.GetCapabilityCalculation(level_attr)
	end
	return 0
end

function ImageFuLingData:GetImgFuLingLevelCfg(img_fuling_type, level)
	if self.image_fuling_level_cfg[img_fuling_type] and self.image_fuling_level_cfg[img_fuling_type][level] then
		return self.image_fuling_level_cfg[img_fuling_type][level]
	end
end

function ImageFuLingData:GetTalentTypeFirstConfigBySkillType(skill_type)
	local skill_cfg_list = self.talent_skill_type_cfg[skill_type]
	return skill_cfg_list[1]
end

function ImageFuLingData:GetImgFuLingSkillName(skill_index)
	for k,v in pairs(self.image_fuling_skill_level_cfg) do
		if nil ~= v[1] and v[1].index == skill_index then
			return v[1].skill_name
		end
	end
	return ""
end

function ImageFuLingData:GetTalentFlushCost(count)
	for k,v in pairs(self.flush_cost_cfg) do
		if v.count == count then
			return v. gold
		end
	end
end

function ImageFuLingData:GetImgFuLingSkillLevelCfg(img_fuling_type, level)
	level = level > 0 and level or 1
	if self.image_fuling_skill_level_cfg[img_fuling_type] and self.image_fuling_skill_level_cfg[img_fuling_type][level] then
		return self.image_fuling_skill_level_cfg[img_fuling_type][level]
	end
end

function ImageFuLingData:GetImgFuLingAllUpStuffCfg(img_fuling_type)
	return self.image_fuling_stuff_cfg[img_fuling_type]
end

function ImageFuLingData:GetJinJieEquipAddPer(min_level)
	for k,v in pairs(self.jingjie_equip_per_add) do
		if v.min_level == min_level then
			return v
		end
	end
end

function ImageFuLingData:GetFuLingTabInfoList()
	return self.fuling_tab_info_list
end

function ImageFuLingData:GetFuLingExtraCapabilityByType(img_fuling_type, level)
	local attr = CommonStruct.Attribute()
	if IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_MOUNT == img_fuling_type then
		attr = MountData.Instance:GetLevelAttribute()
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_WING == img_fuling_type then
		attr = WingData.Instance:GetLevelAttribute()
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_HALO == img_fuling_type then
		attr = HaloData.Instance:GetLevelAttribute()
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_FIGHT_MOUNT == img_fuling_type then
		attr = FightMountData.Instance:GetLevelAttribute()
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_SHENGONG == img_fuling_type then
		attr = ShengongData.Instance:GetLevelAttribute()
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_SHENYI == img_fuling_type then
		attr = ShenyiData.Instance:GetLevelAttribute()
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_FOOT_PRINT == img_fuling_type then
		attr = FootData.Instance:GetFootAttrSum()
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_FABAO == img_fuling_type then
		attr = FaBaoData.Instance:GetFaBaoAttrSum()
	end

	local extra_attr = CommonStruct.Attribute()
	local fuling_level_cfg = self:GetImgFuLingLevelCfg(img_fuling_type, level)
	if nil ~= fuling_level_cfg then
		for k, v in pairs(attr) do
			extra_attr[k] = v * (fuling_level_cfg.per_add / 10000)
		end
	end
	return CommonDataManager.GetCapabilityCalculation(extra_attr)
end

function ImageFuLingData:GetSpecialImageActiveItemId(img_fuling_type, img_id)
	local cfg = {}
	if IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_MOUNT == img_fuling_type then
		cfg = ConfigManager.Instance:GetAutoConfig("mount_auto").special_img
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_WING == img_fuling_type then
		cfg = ConfigManager.Instance:GetAutoConfig("wing_auto").special_img
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_HALO == img_fuling_type then
		cfg = ConfigManager.Instance:GetAutoConfig("halo_auto").special_img
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_FIGHT_MOUNT == img_fuling_type then
		cfg = ConfigManager.Instance:GetAutoConfig("fight_mount_auto").special_img
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_SHENGONG == img_fuling_type then
		cfg = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").shizhuang_special_img
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_SHENYI == img_fuling_type then
		cfg = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").weapon_special_img
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_FOOT_PRINT == img_fuling_type then
		cfg = ConfigManager.Instance:GetAutoConfig("footprint_auto").special_img
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_FABAO == img_fuling_type then
		cfg = ConfigManager.Instance:GetAutoConfig("fabao_auto").special_img
	end

	for k,v in pairs(cfg) do
		if v.image_id == img_id then
			return v.item_id
		end
	end
end

function ImageFuLingData:GetFuLingStuffItemConfig(img_fuling_type, item_id)
	if self.image_fuling_stuff_cfg[img_fuling_type] and self.image_fuling_stuff_cfg[img_fuling_type][item_id] then
		return self.image_fuling_stuff_cfg[img_fuling_type][item_id]
	end
end

function ImageFuLingData:GetItemIsActiveImage(img_fuling_type, item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	local img_id = item_cfg.param1

	local is_active = false
	if IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_MOUNT == img_fuling_type then
		is_active = MountData.Instance:GetSpecialImageIsActive(img_id)
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_WING == img_fuling_type then
		is_active = WingData.Instance:GetSpecialImageIsActive(img_id)
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_HALO == img_fuling_type then
		is_active = HaloData.Instance:GetSpecialImageIsActive(img_id)
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_FIGHT_MOUNT == img_fuling_type then
		is_active = FightMountData.Instance:GetSpecialImageIsActive(img_id)
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_SHENGONG == img_fuling_type then
		-- is_active = ShengongData.Instance:GetSpecialImageIsActive(img_id)
		is_active = FashionData.Instance:CheckIsActive(SHIZHUANG_TYPE.BODY, img_id)
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_SHENYI == img_fuling_type then
		-- is_active = ShenyiData.Instance:GetSpecialImageIsActive(img_id)
		is_active = FashionData.Instance:CheckIsActive(SHIZHUANG_TYPE.WUQI, img_id)
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_FOOT_PRINT == img_fuling_type then
		is_active = FootData.Instance:GetSpecialImageIsActive(img_id)
	elseif IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_FABAO == img_fuling_type then
		is_active = FaBaoData.Instance:GetSpecialImageIsActive(img_id)
	end
	return is_active
end

function ImageFuLingData:GetCanConsumeStuff(img_fuling_type)
	local stuff_cfg = self:GetImgFuLingAllUpStuffCfg(img_fuling_type)
	local item_list = ItemData.Instance:GetBagItemDataList()
	local temp_list = {}
	if stuff_cfg then
		for k,v in pairs(item_list) do
			local next_fuling_level_cfg = nil
			if self.fuling_info_list[img_fuling_type] then
				next_fuling_level_cfg = self:GetImgFuLingLevelCfg(img_fuling_type, self.fuling_info_list[img_fuling_type].level + 1)
			end
			if stuff_cfg[v.item_id] and self:GetItemIsActiveImage(img_fuling_type, v.item_id) and nil ~= next_fuling_level_cfg then
				table.insert(temp_list, v)
			end
		end
	end
	return temp_list
end

function ImageFuLingData:GetImgFuLingTypeByDisplayType(display_type)
	if display_type == DISPLAY_TYPE.MOUNT then
		return IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_MOUNT
	elseif display_type == DISPLAY_TYPE.FIGHT_MOUNT then
		return IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_FIGHT_MOUNT
	elseif display_type == DISPLAY_TYPE.WING then
		return IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_WING
	elseif display_type == DISPLAY_TYPE.HALO then
		return IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_HALO
	elseif display_type == DISPLAY_TYPE.FOOTPRINT then
		return IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_FOOT_PRINT
	elseif display_type == DISPLAY_TYPE.SHENGONG then
		return IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_SHENGONG
	elseif display_type == DISPLAY_TYPE.SHENYI then
		return IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_SHENYI
	elseif display_type == DISPLAY_TYPE.FABAO then
		return IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_FABAO
	end
end

function ImageFuLingData:GetImgFuLingRemind()
	for img_fuling_type = 0, GameEnum.IMG_FULING_JINGJIE_TYPE_MAX - 1 do
		local item_list = self:GetCanConsumeStuff(img_fuling_type)
		local next_fuling_level_cfg = nil
		if self.fuling_info_list[img_fuling_type] then
			next_fuling_level_cfg = self:GetImgFuLingLevelCfg(img_fuling_type, self.fuling_info_list[img_fuling_type].level + 1)
		end
		if nil ~= next_fuling_level_cfg and #item_list > 0 then
			return 1
		end
	end
	return 0
end

function ImageFuLingData:SetTalentAllInfo(talent_info_list)
	self.talent_info_list = talent_info_list
end

function ImageFuLingData:GetTalentAllInfo()
	return self.talent_info_list
end

function ImageFuLingData:SetTalentOneGridInfo(protocol)
	self.talent_info_list[protocol.talent_type] = self.talent_info_list[protocol.talent_type] or {}
	self.talent_info_list[protocol.talent_type][protocol.talent_index] = protocol.grid_info
end

function ImageFuLingData:SetTalentChoujiangPageInfo(protocol)
	self.free_chou_count = protocol.free_chou_count
	self.choujiang_times = protocol.cur_count
	self.choujiang_grid_skill = protocol.choujiang_grid_skill
end

function ImageFuLingData:GetTalentChoujiangPageInfo()
	if nil == self.choujiang_grid_skill then
		return
	end

	local choujiang_info_list = {}
	for i,v in ipairs(self.choujiang_grid_skill) do
		local info = {}
		info.seq = i - 1
		info.skill_id = v
		table.insert(choujiang_info_list, info)
	end

	return choujiang_info_list
end

function ImageFuLingData:GetTalentTabInfoList()
	return self.talent_tab_info_list
end

function ImageFuLingData:GetBagTalentBookItems(select_info, only_need_has)
	local stuff_cfg = self:GetTalentBookItems()
	local bag_item_list = ItemData.Instance:GetBagItemDataList()
	local temp_list = {}
	for k,v in pairs(bag_item_list) do
		if stuff_cfg[v.item_id] then
			if nil == select_info then
				table.insert(temp_list, v)
			else
				local talent_skill_quality, talent_skill_type = self:GetTalentQualityTypeByItemId(v.item_id)
				if 0 == talent_skill_quality then
					local talent_cfg = self:GetTalentConfig(select_info.talent_type)
					--顶级技能槽只能装特定顶级技能
					if talent_cfg and (GameEnum.TALENT_SKILL_GRID_MAX_NUM - 1) == select_info.grid_index then
						if talent_cfg.skill_type == talent_skill_type then
							table.insert(temp_list, v)
							if only_need_has then
								return temp_list
							end
						end
					else
						local has_same_type = false
						--过滤相同类型技能
						for k,v in pairs(self.talent_info_list[select_info.talent_type]) do
							local skill_cfg = self:GetTalentSkillConfig(v.skill_id, 0)
							if nil ~= skill_cfg and talent_skill_type == skill_cfg.skill_type then
								has_same_type = true
								break
							end
							--过滤顶级技能
							for k,v in pairs(self.talent_list_cfg) do
								if v.skill_type == talent_skill_type then
									has_same_type = true
									break
								end
							end
						end

						if not has_same_type then
							table.insert(temp_list, v)
							if only_need_has then
								return temp_list
							end
						end
					end
				end
			end
		end
	end
	return temp_list
end

function ImageFuLingData:GetTalentBagList(select_info, only_need_has)
	local bag_list = self:GetBagTalentBookItems(select_info, only_need_has)
	for k, v in pairs(bag_list) do
		v.quality = self:GetTalentQualityTypeByItemId(v.item_id)
	end
	table.sort(bag_list, SortTools.KeyUpperSorter("quality"))
	return bag_list
end

function ImageFuLingData:GetIsShowTalentRedPoint(talent_type)
	local talent_list = self.talent_info_list[talent_type]
	if nil == talent_list then
		return false
	end

	for k,v in pairs(talent_list) do
		if 1 == v.is_open then
			if 0 == v.skill_id then
				local select_info = {talent_type = talent_type, grid_index = k}
				local item_list = self:GetBagTalentBookItems(select_info, true)
				if #item_list > 0 then
					return true
				end
			else
				local skill_cfg = self:GetTalentSkillConfig(v.skill_id, v.skill_star)
				if nil ~= skill_cfg then
					local item_num = ItemData.Instance:GetItemNumInBagById(skill_cfg.need_item_id)
					if item_num >= skill_cfg.need_item_count then
						return true
					end
				end
			end
		end
	end

	return false
end

function ImageFuLingData:GetTalentSkillConfig(skill_id, skill_star)
	if nil == self.talent_skill_cfg[skill_id] then
		return
	end
	return self.talent_skill_cfg[skill_id][skill_star]
end

function ImageFuLingData:GetTalentBookItems()
	local item_list = {}
	for k, v in pairs(self.talent_skill_cfg) do
		if v[0] and v[0].book_id then
			local key = v[0].book_id
			item_list[key] = key
		end
	end
	return item_list
end

function ImageFuLingData:GetTalentQualityTypeByItemId(item_id)
	local skill_cfg_list = self.talent_skill_item_cfg[item_id]
	if skill_cfg_list then
		return skill_cfg_list[1].skill_quality, skill_cfg_list[1].skill_type
	else
		return 0, 0
	end
end

function ImageFuLingData:GetTalentConfig(talent_type)
	return self.talent_list_cfg[talent_type]
end

function ImageFuLingData:GetFreeChouJiangTimes()
	return self.talent_other_cfg.free_count - self.free_chou_count
end

function ImageFuLingData:GetTalentCapability(talent_type)
	local attribute = self:GetTalentAttr(talent_type)
	local capability = CommonDataManager.GetCapabilityCalculation(attribute)
	if nil == self.talent_info_list[talent_type] then
		return capability
	end

	for k,v in pairs(self.talent_info_list[talent_type]) do
		if v.is_open and v.skill_id > 0 then
			local skill_cfg = self:GetTalentSkillConfig(v.skill_id, v.skill_star)
			if skill_cfg.capability > 0 then
				capability = capability + skill_cfg.capability
			end
		end
	end
	return capability
end

function ImageFuLingData:GetTalentAttr(talent_type)
	local attribute = CommonStruct.Attribute()
	if nil == self.talent_info_list[talent_type] then
		return attribute
	end

	for k,v in pairs(self.talent_info_list[talent_type]) do
		if v.is_open and v.skill_id > 0 then
			local skill_cfg = self:GetTalentSkillConfig(v.skill_id, v.skill_star)
			-- 固定值
			if TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_0 == skill_cfg.skill_type then
				attribute.max_hp = attribute.max_hp + skill_cfg.value
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_1 == skill_cfg.skill_type then
				attribute.gong_ji = attribute.gong_ji + skill_cfg.value
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_2 == skill_cfg.skill_type then
				attribute.fang_yu = attribute.fang_yu + skill_cfg.value
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_3 == skill_cfg.skill_type then
				attribute.ming_zhong = attribute.ming_zhong + skill_cfg.value
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_4 == skill_cfg.skill_type then
				attribute.shan_bi = attribute.shan_bi + skill_cfg.value
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_5 == skill_cfg.skill_type then
				attribute.bao_ji = attribute.bao_ji + skill_cfg.value
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_6 == skill_cfg.skill_type then
				attribute.jian_ren = attribute.jian_ren + skill_cfg.value
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_7 == skill_cfg.skill_type then
				attribute.constant_zengshang = attribute.constant_zengshang + skill_cfg.value
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_8 == skill_cfg.skill_type then
				attribute.constant_mianshang = attribute.constant_mianshang + skill_cfg.value

			-- 百分比+固定值 固定值部分
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_10 == skill_cfg.skill_type then
				attribute.max_hp = attribute.max_hp + skill_cfg.value
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_11 == skill_cfg.skill_type then
				attribute.gong_ji = attribute.gong_ji + skill_cfg.value
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_12 == skill_cfg.skill_type then
				attribute.fang_yu = attribute.fang_yu + skill_cfg.value
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_13 == skill_cfg.skill_type then
				attribute.ming_zhong = attribute.ming_zhong + skill_cfg.value
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_14 == skill_cfg.skill_type then
				attribute.shan_bi = attribute.shan_bi + skill_cfg.value
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_15 == skill_cfg.skill_type then
				attribute.bao_ji = attribute.bao_ji + skill_cfg.value
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_16 == skill_cfg.skill_type then
				attribute.jian_ren = attribute.jian_ren + skill_cfg.value
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_17 == skill_cfg.skill_type then
				attribute.constant_zengshang = attribute.constant_zengshang + skill_cfg.value
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_18 == skill_cfg.skill_type then
				attribute.constant_mianshang = attribute.constant_mianshang + skill_cfg.value
			end
		end 
	end

	--本页天赋百分比
	for k,v in pairs(self.talent_info_list[talent_type]) do
		if v.is_open and v.skill_id > 0 then
			local skill_cfg = self:GetTalentSkillConfig(v.skill_id, v.skill_star)
			if TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_10 == skill_cfg.skill_type then
				attribute.max_hp = math.floor(attribute.max_hp * (1 + skill_cfg.per / 10000))
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_11 == skill_cfg.skill_type then
				attribute.gong_ji = math.floor(attribute.gong_ji * (1 + skill_cfg.per / 10000))
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_12 == skill_cfg.skill_type then
				attribute.fang_yu = math.floor(attribute.fang_yu * (1 + skill_cfg.per / 10000))
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_13 == skill_cfg.skill_type then
				attribute.ming_zhong = math.floor(attribute.ming_zhong * (1 + skill_cfg.per / 10000))
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_14 == skill_cfg.skill_type then
				attribute.shan_bi = math.floor(attribute.shan_bi * (1 + skill_cfg.per / 10000))
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_15 == skill_cfg.skill_type then
				attribute.bao_ji = math.floor(attribute.bao_ji * (1 + skill_cfg.per / 10000))
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_16 == skill_cfg.skill_type then
				attribute.jian_ren = math.floor(attribute.jian_ren * (1 + skill_cfg.per / 10000))
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_17 == skill_cfg.skill_type then
				attribute.constant_zengshang = math.floor(attribute.constant_zengshang * (1 + skill_cfg.per / 10000))
			elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_18 == skill_cfg.skill_type then
				attribute.constant_mianshang = math.floor(attribute.constant_mianshang * (1 + skill_cfg.per / 10000))
			end
		end
	end

	--对应系统进阶属性百分比
	for k,v in pairs(self.talent_info_list[talent_type]) do
		if v.is_open and v.skill_id > 0 then
			local skill_cfg = self:GetTalentSkillConfig(v.skill_id, v.skill_star)
			if TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_9 == skill_cfg.skill_type then
				local attr = CommonStruct.Attribute()
				if TALENT_TYPE.TALENT_MOUNT == talent_type then
					attr = MountData.Instance:GetLevelAttribute()
				elseif TALENT_TYPE.TALENT_WING == talent_type then
					attr = WingData.Instance:GetLevelAttribute()
				elseif TALENT_TYPE.TALENT_HALO == talent_type then
					attr = HaloData.Instance:GetLevelAttribute()
				elseif TALENT_TYPE.TALENT_FIGHTMOUNT == talent_type then
					attr = FightMountData.Instance:GetLevelAttribute()
				elseif TALENT_TYPE.TALENT_SHENGGONG == talent_type then
					attr = ShengongData.Instance:GetLevelAttribute()
				elseif TALENT_TYPE.TALENT_SHENYI == talent_type then
					attr = ShenyiData.Instance:GetLevelAttribute()
				elseif TALENT_TYPE.TALENT_FOOTPRINT == talent_type then
					attr = FootData.Instance:GetLevelAttribute()
				end

				local extra_attr = CommonStruct.Attribute()
				if nil ~= skill_cfg then
					for k, v in pairs(attr) do
						extra_attr[k] = math.floor(v * (skill_cfg.per / 10000))
					end
				end

				attribute = CommonDataManager.AddAttributeAttr(attribute, extra_attr)
			end
		end
	end
	return attribute
end

function ImageFuLingData:GetTalentStageConfigByTimes(choujiang_times)
	for k,v in pairs(self.talent_choujiang_stage_cfg) do
		if choujiang_times >= v.min_count and choujiang_times <= v.max_count then
			return v
		end
	end
end

function ImageFuLingData:GetCurChouJiangTimes()
	return self.choujiang_times
end

function ImageFuLingData:GetTalentChouJiangMaxtStageConfig()
	return self.talent_choujiang_stage_cfg[#self.talent_choujiang_stage_cfg]
end

function ImageFuLingData:GetImgTalentRemind()
	if self:GetFreeChouJiangTimes() > 0 then
		return 1
	end
	if self:GetTalentRemind() > 0 then
		return 1
	end
	return 0
end

function ImageFuLingData:GetAdvanceTalentRemind(index)
	if self:GetFreeChouJiangTimes() > 0 then
		return 1
	end
	for k,v in pairs(self.talent_tab_info_list) do
		if k == index + 1 then
			if self:GetIsShowTalentRedPoint(v) then
				return 1
			end
		end
	end
	return 0
end

function ImageFuLingData:GetTalentRemind()
	for k,v in pairs(self.talent_tab_info_list) do
		if self:GetIsShowTalentRedPoint(v) then
			return 1
		end
	end
	return 0
end

function ImageFuLingData:IsBagTalentBookItems(item_id)
	local stuff_cfg = self:GetTalentBookItems()
	return nil ~= stuff_cfg[item_id]
end

function ImageFuLingData:GetTalentAttrDataList(skill_cfg, talent_type)
	if nil == skill_cfg then
		return
	end

	local config = TableCopy(Language.Advance.TalentAttrName[skill_cfg.skill_type])
	if nil == config then
		return {desc = skill_cfg.description}
	end
	for k,v in pairs(config) do
		if nil ~= v.icon then
			v.str = string.format(v.str, skill_cfg.value)
		elseif TALENT_SKILL_TYPE.TALENT_SKILL_TYPE_9 == skill_cfg.skill_type then
			v.str = string.format(v.str, Language.Advance.TalentTabName[talent_type] or "", skill_cfg.per / 100 .. "%")
		else
			v.str = string.format(v.str, skill_cfg.per / 100 .. "%")
		end
	end

	return config
end

function ImageFuLingData:GetTalentSkillNextConfig(skill_id, skill_star)
	if nil == self.talent_skill_cfg[skill_id] or nil == self.talent_skill_cfg[skill_id][skill_star] then
		return
	end

	local cur_cfg = self.talent_skill_cfg[skill_id][skill_star]
	local next_cfg = self.talent_skill_cfg[skill_id][skill_star + 1]
	if nil == next_cfg then
		local temp_cfg = nil ~= self.talent_skill_cfg[skill_id + 1] and self.talent_skill_cfg[skill_id + 1][0] or {}
		if temp_cfg.skill_type == cur_cfg.skill_type then
			next_cfg = temp_cfg
		end
	end
	return next_cfg
end

function ImageFuLingData:GetTalentGridActiveCondition(talent_type, grid_id)
	local grid_cfg = self.talent_grid_list_cfg[grid_id]
	if nil == grid_cfg then
		return
	end

	local system_type = Language.Advance.FuLingTabName[talent_type]
	if nil == system_type then
		return
	end

	local str = ""
	if grid_cfg.need_grade > 1 then
		str = string.format(Language.Advance.GradeCondition, system_type, CommonDataManager.GetDaXie(grid_cfg.need_grade - 1))
	else
		str = string.format(Language.Advance.PreCondition, Language.Advance.TalentQuality[grid_cfg.pre_quality])
	end

	return str
end