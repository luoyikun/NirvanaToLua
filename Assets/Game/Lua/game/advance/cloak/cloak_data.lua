CloakData = CloakData or BaseClass()

CloakDanId = {
		ZiZhiDanId = 22104,
		ChengZhangDanId = 22126,
}

CloakShuXingDanCfgType = {
		Type = 13
}

CloakMaxLevel = 1000


function CloakData:__init()
	if CloakData.Instance then
		print_error("[ItemData] Attemp to create a singleton twice !")
	end
	CloakData.Instance = self

	self.cloak_info = {
		cloak_level = -1,
		cur_exp = 0,
		used_imageid = 0,
		shuxingdan_count = 0,
		chengzhangdan_count = 0,
		active_image_flag = 0,
		active_special_image_flag = 0,
		equip_skill_level = 0,
		equip_level_list = {},
		skill_level_list = {},
		special_img_grade_list = {},
	}

	self.temp_img_id = 0
	self.temp_img_id_has_select = 0
	self.temp_img_time = 0

	self.cloak_cfg = ConfigManager.Instance:GetAutoConfig("cloak_auto")
	self.equip_info_cfg = ListToMap(self.cloak_cfg.cloak_equip_info, "equip_idx", "equip_level")
end

function CloakData:__delete()
	if CloakData.Instance then
		CloakData.Instance = nil
	end
	self.cloak_info = {}
end

function CloakData:SetCloakInfo(protocol)
	self.cloak_info.cloak_level = protocol.cloak_level
	self.cloak_info.cur_exp = protocol.cur_exp
	self.cloak_info.used_imageid = protocol.used_imageid
	-- self.cloak_info.shuxingdan_count = protocol.shuxingdan_count
	self.cloak_info.shuxingdan_count = protocol.shuxingdan_list[SHUXINGDAN_SLOT_TYPE.SHUXINGDAN_SLOT_TYPE_ZIZHI]			-- 资质丹
	self.cloak_info.chengzhangdan_count = protocol.shuxingdan_list[SHUXINGDAN_SLOT_TYPE.SHUXINGDAN_SLOT_TYPE_CHENGZHANG]	-- 成长丹
	self.cloak_info.active_image_flag = protocol.active_image_flag
	self.cloak_info.active_special_image_flag = protocol.active_special_image_flag
	self.cloak_info.equip_skill_level = protocol.equip_skill_level

	self.cloak_info.equip_level_list = protocol.equip_level_list
	self.cloak_info.skill_level_list = protocol.skill_level_list
	self.cloak_info.special_img_grade_list = protocol.special_img_grade_list
end

function CloakData:GetCloakInfo()
	return self.cloak_info
end

function CloakData:GetCloakLevelCfg(cloak_level)
	for k,v in pairs(self.cloak_cfg.up_level_cfg) do
		if cloak_level == v.level then
			return v
		end
	end
end

function CloakData:GetCloakNextLevelCfg(cloak_level)
	local list = self:GetCloakLevelCfg(cloak_level)
	if list then
		local shuxingdan_count = list.shuxingdan_limit
		if shuxingdan_count then
			for k,v in pairs(self.cloak_cfg.up_level_cfg) do
				if v.shuxingdan_limit > shuxingdan_count then
					return v.level, v.shuxingdan_limit
				end
			end
		end
	end
	return 0, -1
end

function CloakData:GetCloakChengZhangLevelCfg(cloak_level)
	local cloak_level = cloak_level or self.cloak_info.cloak_level
	local list = self:GetCloakLevelCfg(cloak_level)
	return list and list.chengzhangdan_limit or 0
end

-- 获取当前等级可使用的最大成长丹数量
function CloakData:GetMaxChengZhangDanCount(grade)
	local max_num = 0
	if nil == self.cloak_info then
		return max_num
	end

	local grade = grade or self.cloak_info.cloak_level 
	max_num = self:GetCloakChengZhangLevelCfg(grade)

	return max_num
end

function CloakData:GetChengZhangDanNextLevel(cloak_level)
	local list = self:GetCloakLevelCfg(cloak_level)
	if list then
		local chengzhangdan_count = list.chengzhangdan_limit
		if chengzhangdan_count then
			for k,v in pairs(self.cloak_cfg.up_level_cfg) do
				if v.chengzhangdan_limit > chengzhangdan_count then
					return v.level, v.chengzhangdan_limit
				end
			end
		end
	end
	return 0, -1
end


function CloakData:GetMaxCloakLevel()
	local max_level = 0
	for k, v in pairs(self.cloak_cfg.up_level_cfg) do
		if v.level > max_level then
			max_level = v.level
		end
	end
	return max_level
end

function CloakData:CheckSelectItem(cur_index)
	local cur_item_id = self:GetCloakUpLevelStuffCfg(cur_index).up_level_item_id
	local num = ItemData.Instance:GetItemNumInBagById(cur_item_id)
	if num > 0 then return cur_index end

	for i, v in ipairs(self.cloak_cfg.up_level_stuff) do
		if v.up_level_item_id ~= cur_item_id then
			local num = ItemData.Instance:GetItemNumInBagById(v.up_level_item_id)
			if num > 0 then return v.up_level_item_index + 1 end
		end
	end

	return self.cloak_cfg.up_level_stuff[1].up_level_item_index + 1
end

function CloakData:GetNextActiveImgLevel()
	local level_cfg = self:GetCloakLevelCfg(self.cloak_info.cloak_level)
	if nil == level_cfg then return end
	for i, v in ipairs(self.cloak_cfg.up_level_cfg) do
		if v.level > self.cloak_info.cloak_level and v.active_image > level_cfg.active_image then
			return v.level
		end
	end
end

function CloakData:GetActiveImgLevelByActiveImage(index)
	local active_image = index or 0
	for i, v in ipairs(self.cloak_cfg.up_level_cfg) do
		if v.active_image == active_image then
			return v.level
		end
	end
end

function CloakData:GetSpecialImageCfg(image_id)
	local cloak_config = self.cloak_cfg.special_img
	return cloak_config[image_id]
end

function CloakData:GetSpecialImagesCfg()
	return self.cloak_cfg.special_img
end

function CloakData:GetMaxSpecialImage()
	return #self.cloak_cfg.special_img
end

function CloakData:GetSpecialImageUpgradeCfg()
	return self.cloak_cfg.special_image_upgrade
end

function CloakData:GetCloakSkillCfg()
	return self.cloak_cfg.cloak_skill
end

function CloakData:GetCloakImageCfg()
	return self.cloak_cfg.image_list
end

function CloakData:GetCloakEquipCfg()
	return self.cloak_cfg.cloak_equip
end

function CloakData:GetCloakEquipExpCfg()
	return self.cloak_cfg.equip_exp
end

function CloakData:GetCloakEquipRandAttr()
	return self.cloak_cfg.equip_attr_range
end

function CloakData:GetCloakUpLevelStuffCfg(index)
	return self.cloak_cfg.up_level_stuff[index]
end

function CloakData:GetOhterCfg()
	return self.cloak_cfg.other[1]
end


function CloakData:GetSkillIsActive(skill_index)
	if next(self.cloak_info) then
		for k,v in pairs(self.cloak_cfg.cloak_skill) do
			if v.skill_idx == skill_index and self.cloak_info.cloak_level >= v.level then
				return true
			end
		end
	end
	return false
end

function CloakData:GetCloakSkillCfgBuyIndex(index)
	for k,v in pairs(self.cloak_cfg.cloak_skill) do
		if index == v.skill_idx then
			return v
		end
	end
end

-- 获取当前点击披风特殊形象的配置
function CloakData:GetSpecialImageUpgradeInfo(index, grade, is_next)
	if (index == 0) or nil then
		return
	end
	local grade = grade or self.cloak_info.special_img_grade_list[index] or 0
	if is_next then
		grade = grade + 1
	end
	for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
		if v.special_img_id == index and v.grade == grade then
			return v
		end
	end

	return nil
end

-- 获取形象列表的配置
function CloakData:GetImageListInfo(index)
	if (index == 0) or nil then
		return
	end
	for k, v in pairs(self:GetCloakImageCfg()) do
		if v.image_id == index then
			return v
		end
	end

	return nil
end

-- 获取幻化最大等级
function CloakData:GetSpecialImageMaxUpLevelById(image_id)
	if not image_id then return 0 end
	local max_level = 0

	for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
		if v.special_img_id == image_id and v.grade > 0 then
			max_level = max_level + 1
		end
	end
	return max_level
end

-- 获取当前点击披风技能的配置
function CloakData:GetCloakSkillCfgById(skill_idx, level, cloak_info)
	local cloak_info = cloak_info or self.cloak_info
	local level = level or cloak_info.skill_level_list[skill_idx]

	for k, v in pairs(self:GetCloakSkillCfg()) do
		if v.skill_idx == skill_idx and v.skill_level == level then
			return v
		end
	end

	return nil
end

-- 获取特殊形象总增加的属性
function CloakData:GetSpecialImageAttrSum(cloak_info)
	cloak_info = cloak_info or self.cloak_info
	local sum_attr_list = CommonStruct.Attribute()
	local active_flag = cloak_info.active_special_image_flag
	if active_flag == nil then
		sum_attr_list.chengzhangdan_count = 0
		sum_attr_list.shuxingdan_count = 0
		sum_attr_list.equip_limit = 0
		return sum_attr_list
	end
	local bit_list = bit:d2b(active_flag)
	local special_chengzhangdan_count = 0
	local special_shuxingdan_count = 0
	local special_equip_limit = 0
	local special_img_upgrade_info = nil
	for k, v in pairs(bit_list) do
		if v == 1 then
			if self:GetSpecialImageUpgradeInfo(64 - k) ~= nil then
				special_img_upgrade_info = self:GetSpecialImageUpgradeInfo(64 - k)
				special_chengzhangdan_count = special_chengzhangdan_count + special_img_upgrade_info.chengzhangdan_count
				special_shuxingdan_count = special_shuxingdan_count + special_img_upgrade_info.shuxingdan_count
				special_equip_limit = special_equip_limit + special_img_upgrade_info.equip_level

				sum_attr_list.max_hp = sum_attr_list.max_hp + special_img_upgrade_info.maxhp
				sum_attr_list.gong_ji = sum_attr_list.gong_ji + special_img_upgrade_info.gongji
				sum_attr_list.fang_yu = sum_attr_list.fang_yu + special_img_upgrade_info.fangyu
				sum_attr_list.ming_zhong = sum_attr_list.ming_zhong + special_img_upgrade_info.mingzhong
				sum_attr_list.shan_bi = sum_attr_list.shan_bi + special_img_upgrade_info.shanbi
				sum_attr_list.bao_ji = sum_attr_list.bao_ji + special_img_upgrade_info.baoji
				sum_attr_list.jian_ren = sum_attr_list.jian_ren + special_img_upgrade_info.jianren
			end
		end
	end

	return sum_attr_list
end

-- 获得已学习的技能总战力
function CloakData:GetCloakSkillAttrSum(cloak_info)
	local attr_list = CommonStruct.Attribute()
	for i = 0, 3 do
		local skill_cfg = self:GetCloakSkillCfgById(i, nil, cloak_info)
		if skill_cfg ~=nil then
			attr_list.fang_yu = attr_list.fang_yu + skill_cfg.fangyu
			attr_list.gong_ji = attr_list.gong_ji + skill_cfg.gongji
			attr_list.max_hp = attr_list.max_hp + skill_cfg.maxhp
			attr_list.ming_zhong = attr_list.ming_zhong + skill_cfg.mingzhong
			attr_list.shan_bi = attr_list.shan_bi + skill_cfg.shanbi
			attr_list.bao_ji = attr_list.bao_ji + skill_cfg.baoji
			attr_list.jian_ren = attr_list.jian_ren + skill_cfg.jianren
		end
	end
	return attr_list
end

-- 获得已升级装备战力
function CloakData:GetCloakEquipAttrSum(cloak_info)
	cloak_info = cloak_info or self.cloak_info
	local attr_list = CommonStruct.Attribute()
	if nil == cloak_info.equip_level_list then return attr_list end
	for k, v in pairs(cloak_info.equip_level_list) do
		attr_list = CommonDataManager.AddAttributeAttr(attr_list, CommonDataManager.GetAttributteByClass(self:GetEquipInfoCfg(k, v)))
	end
	return attr_list
end

-- 获取已吃成长丹，资质丹属性
function CloakData:GetDanAttr(cloak_info)
	cloak_info = cloak_info or self.cloak_info
	local attr_list = CommonStruct.Attribute()

	local shuxingdan_cfg = ConfigManager.Instance:GetAutoConfig("shuxingdan_cfg_auto").reward
	for k, v in pairs(shuxingdan_cfg) do
		if v.type == CloakShuXingDanCfgType.Type then
			attr_list.gong_ji = attr_list.gong_ji + v.gongji * cloak_info.shuxingdan_count
			attr_list.fang_yu = attr_list.fang_yu + v.fangyu * cloak_info.shuxingdan_count
			attr_list.max_hp = attr_list.max_hp + v.maxhp * cloak_info.shuxingdan_count
			break
		end
	end

	-- for k, v in pairs(attr_list) do
	-- 	attr[k] = math.ceil((self.cloak_info.chengzhangdan_count * shuxingdan_cfg.attr_per / 10000 + 1) * v)
	-- end

	return attr_list
end

function CloakData:GetCloakAttrSum(cloak_info, is_next)
	cloak_info = cloak_info or self:GetCloakInfo()

	local attr = CommonStruct.Attribute()
	local cloak_level = cloak_info.cloak_level or -1
	if cloak_level < 0 then
		return attr
	end

	if cloak_info.cloak_level >= self:GetMaxCloakLevel() then
		cloak_info.cloak_level = self:GetMaxCloakLevel()
	end

	local cloak_level_cfg = self:GetCloakLevelCfg(is_next and cloak_info.cloak_level + 1 or cloak_info.cloak_level)
	if not cloak_level_cfg then return attr end

	local shuxingdan_cfg = ConfigManager.Instance:GetAutoConfig("shuxingdan_cfg_auto").reward
	local chengzhang_cfg ={}
	for k, v in pairs(shuxingdan_cfg) do
		if v.type == CloakShuXingDanCfgType.Type and v.slot_idx == SHUXINGDAN_SLOT_TYPE.SHUXINGDAN_SLOT_TYPE_CHENGZHANG then
			chengzhang_cfg = v
			break
		end
	end
	local cloak_cfg = TableCopy(cloak_level_cfg)
	if chengzhang_cfg and next(chengzhang_cfg) then
		for k, v in pairs(cloak_level_cfg) do
			cloak_cfg[k] = math.ceil((self.cloak_info.chengzhangdan_count * chengzhang_cfg.attr_per / 10000 + 1) * v)
		end
	end

	local skill_attr = self:GetCloakSkillAttrSum(cloak_info)
	local dan_attr = self:GetDanAttr(cloak_info)

	attr.max_hp = (cloak_cfg.maxhp
				+ skill_attr.max_hp
				+ dan_attr.max_hp)

	attr.gong_ji = (cloak_cfg.gongji
				+ skill_attr.gong_ji
				
				+ dan_attr.gong_ji)
				
	attr.fang_yu = (cloak_cfg.fangyu
				+ skill_attr.fang_yu
				+ dan_attr.fang_yu)

	attr.ming_zhong = (cloak_cfg.mingzhong
					+ skill_attr.ming_zhong
					+ dan_attr.ming_zhong)

	attr.shan_bi = (cloak_cfg.shanbi
				+ skill_attr.shan_bi
				+ dan_attr.shan_bi)

	attr.bao_ji = (cloak_cfg.baoji
				+ skill_attr.bao_ji
				+ dan_attr.bao_ji)

	attr.jian_ren = (cloak_cfg.jianren
				+ skill_attr.jian_ren
				+ dan_attr.jian_ren)
	attr.extra_zengshang = cloak_cfg.extra_zengshang or 0						--额外伤害值
	attr.extra_mianshang = cloak_cfg.extra_mianshang or 0					--额外减伤值
	attr.per_jingzhun = cloak_cfg.per_jingzhun or 0							-- 破甲
	attr.per_baoji = cloak_cfg.per_baoji or 0								-- 暴伤
	attr.per_zengshang = cloak_cfg.per_zengshang or 0							--伤害加成万分比
	attr.per_jianshang = cloak_cfg.per_jianshang or 0							--伤害减免万分比
	attr.pvp_jianshang = cloak_cfg.pvp_jianshang or 0							-- pvp减伤
	attr.pvp_zengshang = cloak_cfg.pvp_zengshang or 0							-- pvp增伤
	attr.pve_jianshang = cloak_cfg.pve_jianshang or 0							-- pve减伤
	attr.pve_zengshang = cloak_cfg.pve_zengshang or 0							-- pve增伤
	return attr
end

function CloakData:GetSpecialAttrActiveType(cur_grade)
	cur_grade = cur_grade or self.cloak_info.cloak_level or -1
	return AdvanceData.Instance:GetSpecialAttrActiveType(self.cloak_cfg.up_level_cfg, cur_grade)
end

function CloakData:IsShowZizhiRedPoint()
	local level_cfg = self:GetCloakLevelCfg(self.cloak_info.cloak_level)
	if nil == level_cfg then
		return false
	end
	local count_limit = level_cfg.shuxingdan_limit
	if self.cloak_info.shuxingdan_count == nil or count_limit == nil then
		return false
	end
	if self.cloak_info.shuxingdan_count >= count_limit then
		return false
	end

	if ItemData.Instance:GetItemNumInBagById(CloakDanId.ZiZhiDanId) > 0 then
		return true
	end

	return false
end


function CloakData:IsShowChengzhangRedPoint()
	local level_cfg = self:GetCloakLevelCfg(self.cloak_info.cloak_level)
	if nil == level_cfg then
		return false
	end
	local count_limit = level_cfg.chengzhangdan_limit
	if self.cloak_info.chengzhangdan_count == nil or count_limit == nil then
		return false
	end
	if self.cloak_info.chengzhangdan_count >= count_limit then
		return false
	end

	if ItemData.Instance:GetItemNumInBagById(CloakDanId.ChengZhangDanId) > 0 then
		return true
	end

	return false
end

function CloakData:CanHuanhuaUpgrade()
	if self.cloak_info.grade == nil or self.cloak_info.grade <= 0 then
		return nil
	end

	local special_img_grade_list = self.cloak_info.special_img_grade_list
	if special_img_grade_list == nil then
		return nil
	end

	for i, j in pairs(self:GetSpecialImageUpgradeCfg()) do
		if j.stuff_num <= ItemData.Instance:GetItemNumInBagById(j.stuff_id) and 
			special_img_grade_list[j.special_img_id] == j.grade and
			j.grade < self:GetMaxSpecialImageCfgById(j.special_img_id) then
			return j.special_img_id
		end
	end

	return nil
end

function CloakData:CanSkillUpLevelList()
	local list = {}
	if self.cloak_info.grade == nil or self.cloak_info.grade <= 0 then return list end
	if self.cloak_info.skill_level_list == nil then
		return list
	end

	for i, j in pairs(self:GetCloakSkillCfg()) do
		if j.uplevel_stuff_num <= ItemData.Instance:GetItemNumInBagById(j.uplevel_stuff_id)
			and self.cloak_info.skill_level_list[j.skill_idx] == (j.skill_level - 1)
			and j.grade <= self.cloak_info.grade and j.skill_type ~= 0 then
			list[j.skill_idx] = j.skill_idx
		end
	end
	return list
end

function CloakData:GetMaxSpecialImageCfgById(id)
	if id == nil then return 0 end

	local count = 0
	for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
		if id == v.special_img_id then
			count = count + 1
		end
	end

	return count
end


function CloakData:GetCloakGradeByUseImageId(used_imageid)
	if not used_imageid then return 0 end
	local image_list = self:GetCloakImageCfg()
	if not image_list then return 0 end
	if not image_list[used_imageid] then return 0 end

	local show_grade = image_list[used_imageid].show_grade
	for k, v in pairs(self:GetGradeCfg()) do
		if v.show_grade == show_grade then
			return v.grade
		end
	end
	return 0
end

function CloakData:IsActiviteCloak()
	return self.cloak_info.cloak_level >= 0
end

function CloakData:GetCloakModelResCfg(sex, prof)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local base_prof = PlayerData.Instance:GetRoleBaseProf()
	local sex = sex or vo.sex
	local prof = (prof % 10) or base_prof
	if sex == 0 then
		return tonumber("100"..prof)
	else
		return tonumber("110"..prof)
	end
end

function CloakData:GetEquipInfoCfg(equip_index, level)
	if nil == self.equip_info_cfg[equip_index] then
		return
	end
	return self.equip_info_cfg[equip_index][level]
end

function CloakData:CalAllEquipRemind()
	if not self:IsOpenEquip() then return 0 end

	for k, v in pairs(self.cloak_info.equip_level_list) do
		if self:CalEquipRemind(k) > 0 then
			return 1
		end
	end
	return 0
end

function CloakData:CalEquipRemind(equip_index)
	if nil == self.cloak_info or nil == next(self.cloak_info) then
		return 0
	end

	local equip_level = self.cloak_info.equip_level_list[equip_index] or 0
	local equip_cfg = self:GetEquipInfoCfg(equip_index, equip_level + 1)
	if nil == equip_cfg then return 0 end

	local item_data = equip_cfg.item
	local had_prop_num = ItemData.Instance:GetItemNumInBagById(item_data.item_id)

	return had_prop_num >= item_data.num and 1 or 0
end

function CloakData:GetRemind()
	if not OpenFunData.Instance:CheckIsHide("cloak_jinjie") then
		return 0
	end
	if self:IsShowZizhiRedPoint() then
		return 1
	end

	if self:IsShowChengzhangRedPoint() then
		return 1
	end

	if self.cloak_info.cloak_level >= self:GetMaxCloakLevel() then
		return 0
	end

	local level_exp = 0

	for k,v in pairs(self.cloak_cfg.up_level_stuff) do
		local num = ItemData.Instance:GetItemNumInBagById(v.up_level_item_id)
		if num > 0 then
			local temp_level_exp = num * v.add_exp
			level_exp = level_exp + temp_level_exp
		end
	end
	level_exp = level_exp + self.cloak_info.cur_exp
	local level_cfg = self:GetCloakLevelCfg(self.cloak_info.cloak_level)
	if level_cfg and level_exp >= level_cfg.up_level_exp then
		return 1 
	end

	return 0
end

function CloakData:GetClockLevelRemind()
	if next(self.cloak_info) then
		if self.cloak_info.cloak_level >= CloakMaxLevel then return false end
		local level_exp = 0
		for k,v in pairs(self.cloak_cfg.up_level_stuff) do
			local num = ItemData.Instance:GetItemNumInBagById(v.up_level_item_id)
			if num > 0 then
				local temp_level_exp = num * v.add_exp
				level_exp = level_exp + temp_level_exp
			end
		end
		level_exp = level_exp + self.cloak_info.cur_exp
		local level_cfg = self:GetCloakLevelCfg(self.cloak_info.cloak_level)
		if level_cfg and level_exp >= level_cfg.up_level_exp then
			return true
		end
	end
	return false
end


function CloakData:IsOpenEquip()
	if nil == self.cloak_info or nil == next(self.cloak_info) then
		return false, 0
	end

	local otehr_cfg = self:GetOhterCfg()
	if self.cloak_info.grade >= otehr_cfg.active_equip_grade then
		return true, 0
	end

	return false, otehr_cfg.active_equip_grade - 1
end

function CloakData:IsActiveEquipSkill()
	if nil == self.cloak_info or nil == next(self.cloak_info) then
		return false
	end
	return self.cloak_info.equip_skill_level > 0
end

function CloakData:IsHidden()
	local flag = SettingData.Instance:GetAdvanceTypeHideFlag(ADVANCE_HIDE_TYPE.CLOAK)		--0为不隐藏，1为隐藏
	return flag == 1
end