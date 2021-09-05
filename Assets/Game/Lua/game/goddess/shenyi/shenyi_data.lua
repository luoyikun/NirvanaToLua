ShenyiData = ShenyiData or BaseClass()

ShenyiDanId = {
		ChengZhangDanId = 22117,
		ZiZhiDanId = 22112,
}

ShenyiShuXingDanCfgType = {
		Type = 9
}

ShenyiDataEquipId = {
	16400, 16410, 16420, 16430
}

function ShenyiData:__init()
	if ShenyiData.Instance then
		print_error("[ItemData] Attemp to create a singleton twice !")
	end
	ShenyiData.Instance = self

	self.shenyi_info = {
		star_level = 0,
		shenyi_level = 0,
		grade = 0,
		grade_bless_val = 0,
		clear_upgrade_time = 0,
		used_imageid = 0,
		shuxingdan_count = 0,
		chengzhangdan_count = 0,
		active_image_flag = {},
		active_special_image_flag = {},
		equip_skill_level = 0,
	}

	self.shenyi_cfg = ConfigManager.Instance:GetAutoConfig("shenyi_auto")
	self.equip_info_cfg = ListToMap(self.shenyi_cfg.shenyi_equip_info, "equip_idx", "equip_level")
	self.shenyi_special_img_cfg = ListToMap(self.shenyi_cfg.special_img, "image_id")
	self.shenyi_special_image_upgrade_cfg = ListToMap(self.shenyi_cfg.special_image_upgrade, "special_img_id", "grade")
	self.clear_bless_grade = 100
	self.clear_bless_grade_name = ""
	for i,v in ipairs(self.shenyi_cfg.grade) do
		if v.is_clear_bless == 1 then
			self.clear_bless_grade = v.grade
			self.clear_bless_grade_name = v.gradename
			break
		end
	end

	RemindManager.Instance:Register(RemindName.Goddess_ShenyiHuanhua, BindTool.Bind(self.HuanhuaRed, self))
end

function ShenyiData:__delete()
	if ShenyiData.Instance then
		ShenyiData.Instance = nil
	end
	RemindManager.Instance:UnRegister(RemindName.Goddess_ShenyiHuanhua)
	self.shenyi_info = {}
end

function ShenyiData:SetShenyiInfo(protocol)
	self.shenyi_info.star_level = protocol.star_level
	self.shenyi_info.shenyi_level = protocol.shenyi_level
	self.shenyi_info.grade = protocol.grade
	self.shenyi_info.grade_bless_val = protocol.grade_bless_val
	self.shenyi_info.clear_upgrade_time = protocol.clear_upgrade_time
	self.shenyi_info.used_imageid = protocol.used_imageid
	self.shenyi_info.shuxingdan_count = protocol.shuxingdan_count
	self.shenyi_info.chengzhangdan_count = protocol.chengzhangdan_count
	self.shenyi_info.active_image_flag = bit:uc2b(protocol.active_image_flag) 
	self.shenyi_info.active_special_image_flag = bit:uc2b(protocol.active_special_image_flag)
	self.shenyi_info.equip_skill_level = protocol.equip_skill_level
	self.shenyi_info.equip_level_list = protocol.equip_level_list
	self.shenyi_info.skill_level_list = protocol.skill_level_list
	self.shenyi_info.special_img_grade_list = protocol.special_img_grade_list
end

function ShenyiData:GetSpecialImageIsActive(img_id)
	if nil == next(self.shenyi_info) then
		return
	end
	return 1 == self.shenyi_info.active_special_image_flag[img_id]
end

function ShenyiData:GetLevelAttribute()
	local level_cfg = self:GetShenyiUpStarCfgByLevel(self.shenyi_info.star_level)
	return CommonDataManager.GetAttributteByClass(level_cfg)
end

function ShenyiData:GetShenyiInfo()
	return self.shenyi_info
end

function ShenyiData:GetShenyiLevelCfg(shenyi_level)
	if shenyi_level >= self:GetMaxShenyiLevelCfg() then
		shenyi_level = self:GetMaxShenyiLevelCfg()
	end
	return self.shenyi_cfg.level[shenyi_level]
end

function ShenyiData:GetMaxShenyiLevelCfg()
	return #self.shenyi_cfg.level
end

function ShenyiData:GetShenyiGradeCfg(shenyi_grade)
	shenyi_grade = shenyi_grade or self.shenyi_info.grade or 0
	return self.shenyi_cfg.grade[shenyi_grade]
end

function ShenyiData:GetShenyiEquipUp(equip_index)
	local shenyi_cfg = self:GetShenyiGradeCfg()
	local level_limit = self:GetEquipLevelLimit()
	local max_limit = self:GetMaxGrade()
	if shenyi_cfg == nil or next(shenyi_cfg) == nil or level_limit == nil or max_limit == nil then
		return false
	end

	local equip_level = self.shenyi_info.equip_level_list[equip_index] or 0
	if self.shenyi_info.grade >= level_limit and equip_level and equip_level < shenyi_cfg.equip_level_toplimit and self.shenyi_info.grade < max_limit then
		return true
	end

	return false
end

function ShenyiData:GetSpecialAttrActiveType(cur_grade)
	cur_grade = cur_grade or self.shenyi_info.grade or 0
	return AdvanceData.Instance:GetSpecialAttrActiveType(self.shenyi_cfg.grade, cur_grade)
end

function ShenyiData:GetHuanHuaSpecialAttrActiveType(grade, index)
	local grade = grade or self.shenyi_info.special_img_grade_list[index] or 0
	return AdvanceData.Instance:GetSpecialAttrActiveType(self.shenyi_cfg.special_image_upgrade, grade, index)
end

function ShenyiData:GetSpecialImageCfg(image_id)
	local shenyi_config = self.shenyi_cfg.special_img
	return shenyi_config[image_id]
end

function ShenyiData:GetSpecialImagesCfg()
	return self.shenyi_cfg.special_img
end

function ShenyiData:GetMaxGrade()
	return #self.shenyi_cfg.grade
end

function ShenyiData:GetGradeCfg()
	return self.shenyi_cfg.grade
end

function ShenyiData:GetMaxSpecialImage()
	return #self.shenyi_cfg.special_img
end

function ShenyiData:GetSpecialImageUpgradeCfg()
	return self.shenyi_cfg.special_image_upgrade
end

function ShenyiData:GetShenyiSkillCfg()
	return self.shenyi_cfg.shenyi_skill
end

function ShenyiData:GetShenyiImageCfg()
	return self.shenyi_cfg.image_list
end

function ShenyiData:GetShenyiEquipCfg()
	return self.shenyi_cfg.shenyi_equip
end

function ShenyiData:GetShenyiEquipExpCfg()
	return self.shenyi_cfg.equip_exp
end

function ShenyiData:GetShenyiEquipRandAttr()
	return self.shenyi_cfg.equip_attr_range
end

function ShenyiData:GetShenyiUpStarPropCfg()
	return self.shenyi_cfg.up_start_stuff
end

function ShenyiData:IsShenyiStuff(item_id)
	for k,v in pairs(self.shenyi_cfg.up_start_stuff) do
		if item_id == v.up_star_item_id then
			return true
		end
	end
	return false
end

function ShenyiData:GetShenyiUpStarCfg()
	return self.shenyi_cfg.up_start_exp
end

function ShenyiData:GetShenyiMaxUpStarLevel()
	return #self.shenyi_cfg.up_start_exp
end

function ShenyiData:GetOhterCfg()
	return self.shenyi_cfg.other[1]
end

-- 获取当前点击坐骑特殊形象的配置
function ShenyiData:GetSpecialImageUpgradeInfo(index, grade, is_next)
	if (index == 0) or nil then
		return
	end

	local grade = grade or self.shenyi_info.special_img_grade_list[index] or 0
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

-- 获取幻化最大等级
function ShenyiData:GetSpecialImageMaxUpLevelById(image_id)
	if not image_id then return 0 end
	local max_level = 0

	for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
		if v.special_img_id == image_id and v.grade > 0 then
			max_level = max_level + 1
		end
	end
	return max_level
end

-- 获取形象列表的配置
function ShenyiData:GetImageListInfo(index)
	if (index == 0) or nil then
		return
	end
	for k, v in pairs(self:GetShenyiImageCfg()) do
		if v.image_id == index then
			return v
		end
	end

	return nil
end

-- 获取当前点击坐骑技能的配置
function ShenyiData:GetShenyiSkillCfgById(skill_idx, level, shenyi_info)
	local shenyi_info = shenyi_info or self.shenyi_info
	local level = level or shenyi_info.skill_level_list[skill_idx]

	for k, v in pairs(self:GetShenyiSkillCfg()) do
		if v.skill_idx == skill_idx and v.skill_level == level then
			return v
		end
	end

	return nil
end

function ShenyiData:GetBitFlag()
	return self.shenyi_info.active_special_image_flag
end

-- 获取特殊形象总增加的属性丹和成长丹数量
function ShenyiData:GetSpecialImageAttrSum(shenyi_info)
	shenyi_info = shenyi_info or self.shenyi_info
	local sum_attr_list = CommonStruct.Attribute()
	if shenyi_info.active_special_image_flag == nil then
		sum_attr_list.chengzhangdan_count = 0
		sum_attr_list.shuxingdan_count = 0
		sum_attr_list.equip_limit = 0
		return sum_attr_list
	end
	local special_chengzhangdan_count = 0
	local special_shuxingdan_count = 0
	local special_equip_limit = 0
	local special_img_upgrade_info = nil
	for k, v in pairs(shenyi_info.active_special_image_flag) do
		if v == 1 then
			if self:GetSpecialImageUpgradeInfo(k) ~= nil then
				special_img_upgrade_info = self:GetSpecialImageUpgradeInfo(k)
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

	local grade_cfg = self:GetShenyiGradeCfg(shenyi_info.grade)
	if grade_cfg then
		sum_attr_list.chengzhangdan_count = special_chengzhangdan_count + grade_cfg.chengzhangdan_limit
		sum_attr_list.shuxingdan_count = special_shuxingdan_count + grade_cfg.shuxingdan_limit
		sum_attr_list.equip_limit = special_equip_limit + grade_cfg.equip_level_limit
	end

	return sum_attr_list
end

-- 获得已学习的技能总战力
function ShenyiData:GetShenyiSkillAttrSum(shenyi_info)
	local attr_list = CommonStruct.Attribute()
	for i = 0, 3 do
		local skill_cfg = self:GetShenyiSkillCfgById(i, nil, shenyi_info)
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
function ShenyiData:GetShenyiEquipAttrSum(shenyi_info)
	shenyi_info = shenyi_info or self.shenyi_info
	local attr_list = CommonStruct.Attribute()
	if nil == shenyi_info.equip_level_list then return attr_list end
	for k, v in pairs(shenyi_info.equip_level_list) do
		attr_list = CommonDataManager.AddAttributeAttr(attr_list, CommonDataManager.GetAttributteByClass(self:GetEquipInfoCfg(k, v)))
	end
	return attr_list
end

-- 获得特殊属性更高的
function ShenyiData:GetGradeAndSpecialAttr()
	local cfg = self:GetShenyiGradeCfg(self.shenyi_info.grade)
	if cfg then
		for k, v in ipairs (self.shenyi_cfg.grade) do
			if v.per_baoji > cfg.per_baoji then
				return v.grade, v.per_baoji - cfg.per_baoji
			end
		end
	end
end

-- 获取已吃成长丹，资质丹属性
function ShenyiData:GetDanAttr(shenyi_info)
	shenyi_info = shenyi_info or self.shenyi_info
	local attr_list = CommonStruct.Attribute()
	if shenyi_info.shenyi_level >= self:GetMaxShenyiLevelCfg() then
		shenyi_info.shenyi_level = self:GetMaxShenyiLevelCfg()
	end
	local shenyi_level_cfg = self:GetShenyiLevelCfg(shenyi_info.shenyi_level)
	local shenyi_up_star_cfg = self:GetShenyiUpStarCfgByLevel(shenyi_info.star_level)
	shenyi_up_star_cfg = shenyi_up_star_cfg or CommonStruct.AttributeNoUnderline()
	local shenyi_shuxingdan_cfg = AdvanceData.Instance:GetShuXingDanCfg(ShenyiShuXingDanCfgType.Type)
	if shenyi_shuxingdan_cfg and next(shenyi_shuxingdan_cfg) then
		attr_list.gong_ji = attr_list.gong_ji + shenyi_shuxingdan_cfg.gongji * shenyi_info.shuxingdan_count
		attr_list.fang_yu = attr_list.fang_yu + shenyi_shuxingdan_cfg.fangyu * shenyi_info.shuxingdan_count
		attr_list.max_hp = attr_list.max_hp + shenyi_shuxingdan_cfg.maxhp * shenyi_info.shuxingdan_count
	end

	return attr_list
end

function ShenyiData:GetShenyiAttrSum(shenyi_info, is_advancesucce)
	shenyi_info = shenyi_info or self:GetShenyiInfo()
	if nil == shenyi_info.grade or shenyi_info.grade <= 0 then
		return 0
	end
	if shenyi_info.shenyi_level >= self:GetMaxShenyiLevelCfg() then
		shenyi_info.shenyi_level = self:GetMaxShenyiLevelCfg()
	end
	local shenyi_level_cfg = self:GetShenyiLevelCfg(shenyi_info.shenyi_level)
	local level = is_advancesucce and math.floor(shenyi_info.star_level / 10) * 10 or shenyi_info.star_level
	local shenyi_up_star_cfg = self:GetShenyiUpStarCfgByLevel(level) or CommonStruct.AttributeNoUnderline()
	local skill_attr = self:GetShenyiSkillAttrSum(shenyi_info)
	local dan_attr = self:GetDanAttr(shenyi_info)
	local special_img_attr = self:GetSpecialImageAttrSum(shenyi_info)
	local medal_percent = MedalData.Instance:GetMedalSuitActiveCfg() and MedalData.Instance:GetMedalSuitActiveCfg().magic_wing_attr_add / 10000 or 0
	local attr = CommonStruct.Attribute()
	attr.max_hp = (shenyi_level_cfg.maxhp
				+ shenyi_up_star_cfg.maxhp --+ differ_value.max_hp * temp_attr_per * shenyi_grade_cfg.bless_addition /10000
				+ skill_attr.max_hp
				+ dan_attr.max_hp
				+ special_img_attr.max_hp)
				+ (medal_percent) * (shenyi_level_cfg.maxhp + shenyi_up_star_cfg.maxhp)

	attr.gong_ji = (shenyi_level_cfg.gongji
				+ shenyi_up_star_cfg.gongji --+ differ_value.gong_ji * temp_attr_per * shenyi_grade_cfg.bless_addition /10000
				+ skill_attr.gong_ji
				+ dan_attr.gong_ji
				+ special_img_attr.gong_ji)
				+ (medal_percent) * (shenyi_level_cfg.gongji + shenyi_up_star_cfg.gongji)

	attr.fang_yu = (shenyi_level_cfg.fangyu
				+ shenyi_up_star_cfg.fangyu --+ differ_value.fang_yu * temp_attr_per
				+ skill_attr.fang_yu
				+ dan_attr.fang_yu
				+ special_img_attr.fang_yu)
				+ (medal_percent) * (shenyi_level_cfg.fangyu + shenyi_up_star_cfg.fangyu)

	attr.ming_zhong = (shenyi_level_cfg.mingzhong
					+ shenyi_up_star_cfg.mingzhong --+ differ_value.ming_zhong * temp_attr_per
					+ skill_attr.ming_zhong
					+ dan_attr.ming_zhong
					+ special_img_attr.ming_zhong)
					+ (medal_percent) * (shenyi_level_cfg.mingzhong + shenyi_up_star_cfg.mingzhong)

	attr.shan_bi = (shenyi_level_cfg.shanbi
				+ shenyi_up_star_cfg.shanbi --+ differ_value.shan_bi * temp_attr_per
				+ skill_attr.shan_bi
				+ dan_attr.shan_bi
				+ special_img_attr.shan_bi)
				+ (medal_percent) * (shenyi_level_cfg.shanbi + shenyi_up_star_cfg.shanbi)

	attr.bao_ji = (shenyi_level_cfg.baoji
				+ shenyi_up_star_cfg.baoji --+ differ_value.bao_ji * temp_attr_per
				+ skill_attr.bao_ji
				+ dan_attr.bao_ji
				+ special_img_attr.bao_ji)
				+ (medal_percent) * (shenyi_level_cfg.baoji + shenyi_up_star_cfg.baoji)

	attr.jian_ren = (shenyi_level_cfg.jianren
				+ shenyi_up_star_cfg.jianren --+ differ_value.jian_ren * temp_attr_per
				+ skill_attr.jian_ren
				+ dan_attr.jian_ren
				+ special_img_attr.jian_ren)
				+ (medal_percent) * (shenyi_level_cfg.jianren + shenyi_up_star_cfg.jianren)

	return attr
end

function ShenyiData:IsShowZizhiRedPoint()
	if nil == next(self.shenyi_info) then
		return false
	end

	local shenyi_shuxingdan_cfg = AdvanceData.Instance:GetShuXingDanCfg(ShenyiShuXingDanCfgType.Type)
	if not shenyi_shuxingdan_cfg or not next(shenyi_shuxingdan_cfg) then
		return false
	end

	if self.shenyi_info.grade < shenyi_shuxingdan_cfg.order_limit then
		return false
	end

	local count_limit = self:GetSpecialImageAttrSum().shuxingdan_count
	if self.shenyi_info.shuxingdan_count == nil or count_limit == nil then
		return false
	end
	if self.shenyi_info.shuxingdan_count >= count_limit then
		return false
	end

	if ItemData.Instance:GetItemNumInBagById(ShenyiDanId.ZiZhiDanId) > 0 then
		return true
	end

	return false
end

function ShenyiData:IsShowChengzhangRedPoint()
	local count_limit = self:GetSpecialImageAttrSum().chengzhangdan_count
	if self.shenyi_info.chengzhangdan_count == nil or count_limit == nil then
		return false
	end
	if self.shenyi_info.chengzhangdan_count >= count_limit then
		return false
	end
	for k, v in pairs(ItemData.Instance:GetBagItemDataList()) do
		if v.item_id == ShenyiDanId.ChengZhangDanId then
			return true
		end
	end
	return false
end

function ShenyiData:CanHuanhuaUpgrade()
	if self.shenyi_info.grade == nil or self.shenyi_info.grade <= 0 then
		return 0
	end

	local special_img_grade_list = self.shenyi_info.special_img_grade_list
	if special_img_grade_list == nil then
		return 0
	end

	local image_id = JinJieRewardData.Instance:GetSingleRewardCfgParam0(JINJIE_TYPE.JINJIE_TYPE_SHENYI)
	for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
		if v.stuff_num <= ItemData.Instance:GetItemNumInBagById(v.stuff_id) and 
			special_img_grade_list[v.special_img_id] == v.grade and
			v.grade < self:GetMaxSpecialImageCfgById(v.special_img_id) 
			and v.special_img_id ~= image_id then
			return v.special_img_id	

		end
	end

	return 0
end

function ShenyiData:HuanhuaRed()
	return self:CanHuanhuaUpgrade() == 0 and 0 or 1
end

function ShenyiData:CanSkillUpLevelList()
	local list = {}
	if self.shenyi_info.grade == nil or self.shenyi_info.grade <= 0 then return list end
	if self.shenyi_info.skill_level_list == nil then
		return list
	end

	for k, v in pairs(self:GetShenyiSkillCfg()) do
		if v.uplevel_stuff_num <= ItemData.Instance:GetItemNumInBagById(v.uplevel_stuff_id)
			and self.shenyi_info.skill_level_list[v.skill_idx] == (v.skill_level - 1)
			and v.grade <= self.shenyi_info.grade and v.skill_type ~= 0 then
			list[v.skill_idx] = v.skill_idx
		end
	end

	return list
end

function ShenyiData:GetMaxSpecialImageCfgById(id)
	if id == nil then return 0 end
	local special_image_upgrade_cfg = ConfigManager.Instance:GetAutoConfig("shenyi_auto").special_image_upgrade
	local count = 0
	for k, v in pairs(special_image_upgrade_cfg) do
		if id == v.special_img_id and v.grade > 0 then
			count = count + 1
		end
	end
	
	return count
end

--获取对应幻化等级
function ShenyiData:GetHuanHuaGrade(image_id)
	if nil == self.shenyi_info.special_img_grade_list then
		return 0
	end
	return self.shenyi_info.special_img_grade_list[image_id] or 0
end

--获取对应幻化信息
function ShenyiData:GetHuanHuaCfgInfo(image_id, grade)
	grade = grade or self:GetHuanHuaGrade(image_id)
	if self.shenyi_special_image_upgrade_cfg[image_id] then
		return self.shenyi_special_image_upgrade_cfg[image_id][grade]
	end

	return nil
end

-- 获取可显示的幻化列表
function ShenyiData:GetHuanHuaCfgList()
	local huanhua_list = {}

	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	for _, v in pairs(self.shenyi_special_img_cfg) do
		if main_vo.level >= v.lvl and open_server_day >= v.open_day then
			table.insert(huanhua_list, v)
		end
	end

	return huanhua_list
end

function ShenyiData:CanHuanhuaIndexByImageId(image_id)
	local list = self:GetHuanHuaCfgList()
	if list then
		local num = 0
		for k, v in ipairs(list) do
			num = num + 1
			if v.item_id == image_id then
				return v.image_id, num
			end
		end
	end
end

function ShenyiData:GetShenyiUpStarCfgByLevel(level)
	if nil == level then return end

	for k, v in pairs(self:GetShenyiUpStarCfg()) do
		if v.star_level == level then
			return v
		end
	end

	return nil
end

function ShenyiData:GetChengzhangDanLimit()
	for i = 1, self:GetMaxGrade() do
		if self:GetGradeCfg()[i] and self:GetGradeCfg()[i].chengzhangdan_limit > 0 then
			return self:GetGradeCfg()[i]
		end
	end
	return nil
end

function ShenyiData:GetShenyiGradeByUseImageId(used_imageid)
	if not used_imageid then return 0 end
	local image_list = self:GetShenyiImageCfg()
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

function ShenyiData:GetIsRichMoneyUpLevel(item_id)
	local is_rich = true
	local exp_cfg = 1
	local need_exp = self:GetShenyiUpStarCfgByLevel(self.shenyi_info.star_level).up_star_level_exp
	local num = 0
	for k,v in pairs(self:GetShenyiUpStarPropCfg()) do
		if v.up_star_item_id == item_id then
			exp_cfg = v.star_exp
		end
	end
	num = math.ceil(need_exp / exp_cfg)
	local all_gold = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id].gold * num
	if GameVoManager.Instance:GetMainRoleVo().gold > all_gold then
		return true
	else
		return false
	end
end

function ShenyiData:IsActiviteShenyi()
	local active_flag = self.shenyi_info and self.shenyi_info.active_image_flag or {}
	for k, v in pairs(active_flag) do
		if v == 1 then
			return true
		end
	end
	return false
end

function ShenyiData:IsShowCancelHuanhuaBtn(grade)
	if grade == self.shenyi_info.grade then
		if self.shenyi_info.used_imageid > 1000 then
			return true
		end
	end
	return false
end

function ShenyiData:GetShowShenyiRes(grade)
	local shenyi_grade_cfg = self:GetShenyiGradeCfg(grade)
	local image_cfg = nil
	if shenyi_grade_cfg then
		image_cfg = self:GetShenyiImageCfg()
	end
	if self.shenyi_info.used_imageid < 1000 then
		if image_cfg and shenyi_grade_cfg then
			return image_cfg[shenyi_grade_cfg.image_id].res_id
		end
		return -1
	end
	if grade == self.shenyi_info.grade then
		return self:GetSpecialImageCfg(self.shenyi_info.used_imageid - 1000).res_id
	else
		if image_cfg and shenyi_grade_cfg then
			return image_cfg[shenyi_grade_cfg.image_id].res_id
		end
		return -1
	end
end

function ShenyiData:GetCurShenyiRes()
	local grade = 0
	if self.shenyi_info.used_imageid and self.shenyi_info.used_imageid > 1000  then
		local cfg = self:GetSpecialImageCfg(self.shenyi_info.used_imageid - 1000)
		if cfg then
			return cfg.res_id
		end
	else
		if self.shenyi_info.used_imageid then
			grade = self:GetShenyiGradeByUseImageId(self.shenyi_info.used_imageid)
			return self:GetShowShenyiRes(grade)
		end
	end
	return -1
end

function ShenyiData:GetColorName(grade)
	local image_id = 0
	local image_name = ""
	local grade_cfg = self:GetShenyiGradeCfg(grade)
	if grade_cfg then
		image_id = grade_cfg.image_id or 0
	end
	local iamge_cfg = self:GetShenyiImageCfg()[image_id].image_name
	if iamge_cfg and iamge_cfg[image_id] then
		image_name = iamge_cfg[image_id].image_name or ""
	end
	local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)
	local name_str = "<color="..SOUL_NAME_COLOR[color]..">" .. image_name .. "</color>"
	return name_str
end

function ShenyiData:GetEquipInfoCfg(equip_index, level)
	if nil == self.equip_info_cfg[equip_index] then
		return
	end
	return self.equip_info_cfg[equip_index][level]
end

function ShenyiData:CalAllEquipRemind()
	if not self:IsOpenEquip() then return 0 end

	for k, v in pairs(self.shenyi_info.equip_level_list) do
		if self:CalEquipRemind(k) > 0 then
			return 1
		end
	end
	return 0
end

function ShenyiData:CalEquipRemind(equip_index)
	if nil == self.shenyi_info or nil == next(self.shenyi_info) then
		return 0
	end

	local equip_level = self.shenyi_info.equip_level_list[equip_index] or 0
	local equip_cfg = self:GetEquipInfoCfg(equip_index, equip_level + 1)
	if nil == equip_cfg then return 0 end

	local equip_level_toplimit = 0
	local grade_info_cfg = self:GetShenyiGradeCfg(self.shenyi_info.grade)
	if grade_info_cfg then
		equip_level_toplimit = grade_info_cfg.equip_level_toplimit
	end
	-- if self.shenyi_info.grade < self:GetEquipLevelLimit() or equip_level >= equip_level_toplimit then
	-- 	return 0
	-- end

	local item_data = equip_cfg.item
	local had_prop_num = ItemData.Instance:GetItemNumInBagById(item_data.item_id)
	if self:GetShenyiEquipUp(equip_index) and had_prop_num >= item_data.num then
		return 1
	end
	return 0
end

function ShenyiData:GetEquipLevelLimit()
	for k, v in ipairs(self.shenyi_cfg.grade) do
		if v.equip_level_toplimit ~= 0 then
			return k
		end
	end
	return 0
end

function ShenyiData:IsOpenEquip()
	if nil == self.shenyi_info or nil == next(self.shenyi_info) then
		return false, 0
	end

	local otehr_cfg = self:GetOhterCfg()
	if self.shenyi_info.grade >= otehr_cfg.active_equip_grade then
		return true, 0
	end

	return false, otehr_cfg.active_equip_grade
end

function ShenyiData:GetEquipMinLevel()
	if nil == self.shenyi_info or nil == next(self.shenyi_info) then
		return 0
	end
	local min_level = 999
	for k, v in pairs(self.shenyi_info.equip_level_list) do
		if min_level > v then
			min_level = v
		end
	end
	return min_level
end

function ShenyiData:IsActiveEquipSkill()
	if nil == self.shenyi_info or nil == next(self.shenyi_info) then
		return false
	end
	return self.shenyi_info.equip_skill_level > 0
end

function ShenyiData:GetClearBlessGrade()
	return self.clear_bless_grade, self.clear_bless_grade_name
end

function ShenyiData:GetShuXinLevel()
	for k, v in ipairs(self.shenyi_cfg.grade) do
		if v.per_baoji ~= 0 then
			return v.grade
		end
	end 
	return 0
end

--当前等级基础战力
function ShenyiData:GetCurGradeBaseFightPowerAndAddPer()
	local power = 0
	local huanhua_add_per = 0

	local grade = self:GetGrade()
	local cur_grade = grade == 0 and 1 or grade
	local attr_cfg = self:GetShenyiGradeCfg(cur_grade)
	local attr = CommonDataManager.GetAttributteByClass(attr_cfg)
	power = CommonDataManager.GetCapabilityCalculation(attr)

	return power, huanhua_add_per
end

--得到幻化形象当前等级
function ShenyiData:GetSingleSpecialImageGrade(image_id)
	local grade = 0
	if nil == self.shenyi_info or nil == self.shenyi_info.special_img_grade_list or nil == self.shenyi_info.special_img_grade_list[image_id] then
		return grade
	end

	grade = self.shenyi_info.special_img_grade_list[image_id]
	return grade
end

--当前使用形象
function ShenyiData:GetUsedImageId()
	return self.shenyi_info.used_imageid
end

--当前进阶等级对应的image_id
function ShenyiData:GetCurGradeImageId()
	local image_id = 0
	local cfg = self:GetShenyiGradeCfg(self.shenyi_info.grade)
	if cfg then
		image_id = cfg.image_id or 0
	end

	return image_id
end

------------------------------------------------幻化超级战力-------------------------------------------------
--获取配置判断超级战力是否开启 0/1 不开启/开启
function ShenyiData:SuperPowerIsOpenByCfg()
	local other_cfg = self:GetOhterCfg()
	local open_flag = other_cfg and other_cfg.is_open_special_cap_add
	local is_open = false
	if open_flag then
		is_open = open_flag == 1
	end

	return is_open
end

--特殊星星是否显示
function ShenyiData:GetStarIsShowSuperPower(huanhua_id)
	local is_show = false
	local is_open = self:SuperPowerIsOpenByCfg()
	if not is_open then
		return is_show
	end

	if nil == huanhua_id or nil == self.huanhua_special_cap_add or nil == self.huanhua_special_cap_add[huanhua_id] then
		return is_show
	end

	local list = self.huanhua_special_cap_add[huanhua_id]
	local need_level = list.huanhua_level
	local cur_level = self:GetSingleSpecialImageGrade(huanhua_id)
	if need_level and cur_level and cur_level >= need_level then
		is_show = true
	end

	return is_show
end

--超级战力是否显示
function ShenyiData:IsShowSuperPower(huanhua_id)
	local is_show = false
	local is_open = self:SuperPowerIsOpenByCfg()
	if not is_open then
		return is_show
	end
	
	if nil == huanhua_id or nil == self.huanhua_special_cap_add or nil == self.huanhua_special_cap_add[huanhua_id] then
		return is_show
	end

	local level = self:GetSingleSpecialImageGrade(huanhua_id)
	is_show = level > 0
	return is_show
end

--获取单个幻化形象特殊战力配置
function ShenyiData:GetSingleHuanHuaSpecialCapAddList(huanhua_id)
	local list = {}
	if nil == huanhua_id or nil == self.huanhua_special_cap_add or nil == self.huanhua_special_cap_add[huanhua_id] then
		return list
	end

	list = self.huanhua_special_cap_add[huanhua_id]
	return list
end

--获取激活超级形象的要求等级
function ShenyiData:GetActiveSuperPowerNeedLevel(huanhua_id)
	local level = 0
	local list = self:GetSingleHuanHuaSpecialCapAddList(huanhua_id)
	if list and list.huanhua_level then
		level = list.huanhua_level
	end

	return level
end

--特殊战力面板显示数据
function ShenyiData:GetSpecialHuanHuaShowData(huanhua_id)
	local data_list = CommonStruct.SpecialHuanHuaTipInfo()
	if nil == huanhua_id then
		return data_list
	end

	local cfg = self:GetSingleHuanHuaSpecialCapAddList(huanhua_id)
	local huanhua_cfg = self:GetSpecialImageCfg(huanhua_id)
	local image_name = huanhua_cfg and huanhua_cfg.image_name or ""
	local name = image_name or "" 

	local need_level = cfg.huanhua_level or 0
	local cur_level = self:GetSingleSpecialImageGrade(huanhua_id) or 0
	local color = cur_level >= need_level and TEXT_COLOR.GREEN_4 or TEXT_COLOR.RED
	local cur_level_str = ToColorStr(cur_level, color)
	local desc_str = string.format(Language.Advance.SpecialHuanHuaTips, name, cur_level_str, ToColorStr(need_level, TEXT_COLOR.GREEN_4))

 	data_list.max_hp = cfg.maxhp or 0								-- 生命
	data_list.gong_ji = cfg.gongji or 0 							-- 攻击
	data_list.fang_yu = cfg.fangyu or 0								-- 防御
	data_list.desc = desc_str										-- 描述
	return data_list
end
-----------------------------------------------幻化超级战力结束----------------------------------------------
function ShenyiData:GetSpecialImagesCfgByImageId(image_id)
	local cfg = {}
	if nil == image_id then
		return cfg
	end
	
	local list = self:GetSpecialImagesCfg()
	cfg = list and list[image_id]
	return cfg or {}
end

--得到当前使用image_id配置
function ShenyiData:GetCurUseImageCfgByImageId(image_id)
	local image_info = {}
	if nil == image_id then
		return image_info
	end
	
	if image_id >= GameEnum.MOUNT_SPECIAL_IMA_ID then
		--特殊形象由1000开始
		image_id = image_id - GameEnum.MOUNT_SPECIAL_IMA_ID
		image_info = self:GetSpecialImagesCfgByImageId(image_id)
	else
		image_info = self:GetImageListInfo(image_id)
	end

	return image_info
end

--获取对应的资源id
function ShenyiData:GetResIdByImageId(image_id)
	local res_id = 0
	local image_info = self:GetCurUseImageCfgByImageId(image_id)
	if image_info and image_info.res_id then
		res_id = image_info.res_id
	end

	return res_id
end

-- 当前阶数
function ShenyiData:GetGrade()
  	return self.shenyi_info.grade or 0
end

function ShenyiData:IsHaveZhiShengDanInGrade()
	if self.shenyi_info and next(self.shenyi_info) then
		local zhishengdan_list = ItemData.Instance:GetItemListByBigType(GameEnum.ITEM_BIGTYPE_EXPENSE)
		for k, v in pairs(zhishengdan_list) do
			local item_cfg, bag_type = ItemData.Instance:GetItemConfig(v.item_id)
			if item_cfg.use_type == 72 and item_cfg.param2 == self.shenyi_info.grade then
				return true, item_cfg.id
			end
		end
	end
	return false, nil
end