ShengongData = ShengongData or BaseClass()

ShengongDanId = {
		ChengZhangDanId = 22116,
		ZiZhiDanId = 22111,
}

ShengongShuXingDanCfgType = {
		Type = 8
}

ShengongDataEquipId = {
	16300, 16310, 16320, 16330
}

function ShengongData:__init()
	if ShengongData.Instance then
		print_error("[ItemData] Attemp to create a singleton twice !")
	end
	ShengongData.Instance = self

	self.shengong_info = {}
	self.maxshengong_special_level = 0
	self.shengong_cfg = ConfigManager.Instance:GetAutoConfig("shengong_auto")
	self.equip_info_cfg = ListToMap(self.shengong_cfg.shengong_equip_info, "equip_idx", "equip_level")
	self.special_img_cfg = ListToMap(self.shengong_cfg.special_img, "res_id")
	self.huanhua_special_cap_add = ListToMap(self.shengong_cfg.huanhua_special_cap_add, "huanhua_id")			--幻化特殊战力加成
	for i,v in ipairs(self.shengong_cfg.special_image_upgrade) do
		if self.maxshengong_special_level <= v.grade then
			self.maxshengong_special_level = v.grade
		else
			break
		end
	end
	self.clear_bless_grade = 100
	self.clear_bless_grade_name = ""
	for i,v in ipairs(self.shengong_cfg.grade) do
		if v.is_clear_bless == 1 then
			self.clear_bless_grade = v.grade
			self.clear_bless_grade_name = v.gradename
			break
		end
	end

	RemindManager.Instance:Register(RemindName.Goddess_ShengongHuanhua, BindTool.Bind(self.HuanhuaRed, self))
end

function ShengongData:__delete()
	if ShengongData.Instance then
		ShengongData.Instance = nil
	end
	RemindManager.Instance:UnRegister(RemindName.Goddess_ShengongHuanhua)
	self.shengong_info = {}
end

function ShengongData:SetShengongInfo(protocol)
	self.shengong_info.star_level = protocol.star_level
	self.shengong_info.shengong_level = protocol.shengong_level
	self.shengong_info.grade = protocol.grade
	self.shengong_info.grade_bless_val = protocol.grade_bless_val
	self.shengong_info.used_imageid = protocol.used_imageid
	self.shengong_info.shuxingdan_count = protocol.shuxingdan_count
	self.shengong_info.chengzhangdan_count = protocol.chengzhangdan_count
	self.shengong_info.active_image_flag = bit:uc2b(protocol.active_image_flag)
	self.shengong_info.active_special_image_flag = bit:uc2b(protocol.active_special_image_flag)
	self.shengong_info.clear_upgrade_time = protocol.clear_upgrade_time
	self.shengong_info.equip_skill_level = protocol.equip_skill_level
	self.shengong_info.equip_level_list = protocol.equip_level_list
	self.shengong_info.skill_level_list = protocol.skill_level_list
	self.shengong_info.special_img_grade_list = protocol.special_img_grade_list
end

function ShengongData:GetSpecialImageIsActive(img_id)
	if nil == next(self.shengong_info) then
		return false
	end
	return 1 == self.shengong_info.active_special_image_flag[img_id]
end

function ShengongData:GetLevelAttribute()
	local level_cfg = self:GetShengongUpStarCfgByLevel(self.shengong_info.star_level)
	return CommonDataManager.GetAttributteByClass(level_cfg)
end

function ShengongData:GetShengongInfo()
	return self.shengong_info
end

function ShengongData:GetShengongLevelCfg(shengong_level)
	if shengong_level >= self:GetMaxShengongLevelCfg() then
		shengong_level = self:GetMaxShengongLevelCfg()
	end
	return self.shengong_cfg.level[shengong_level]
end

function ShengongData:GetMaxShengongLevelCfg()
	return #self.shengong_cfg.level
end

function ShengongData:GetShengongGradeCfg(shengong_grade)
	shengong_grade = shengong_grade or self.shengong_info.grade or 0
	return self.shengong_cfg.grade[shengong_grade]
end

function ShengongData:GetSpecialImagesCfg()
	return self.shengong_cfg.special_img
end

function ShengongData:GetSpecialImages(res_id)
	return self.special_img_cfg[res_id]
end

function ShengongData:GetSpecialImageCfg(image_id)
	local shengong_config = self:GetSpecialImageList()
	for k, v in pairs(shengong_config) do
		if image_id == v.image_id then
			return v
		end
	end
	return nil
end

function ShengongData:GetSpecialImageCfgByIndex(index)
	local shengong_config = self:GetSpecialImageList()
	return shengong_config[index]
end

function ShengongData:GetMaxGrade()
	return #self.shengong_cfg.grade
end

function ShengongData:GetGradeCfg()
	return self.shengong_cfg.grade
end

function ShengongData:GetMaxSpecialImage()
	local list = self:GetSpecialImageList()
	return #list
end

function ShengongData:GetSpecialImageList()
	if self.special_image_list then
		return self.special_image_list
	end
	self.special_image_list = {}
	self.open_special_image_list = {}
	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	for k,v in ipairs(self.shengong_cfg.special_img) do
		if server_day >= v.open_day and main_vo.level >= v.lvl then
			table.insert(self.special_image_list, v)
			self.open_special_image_list[v.image_id] = true
		end
	end
	return self.special_image_list
end

function ShengongData:CanHuanhuaIndexByImageId(image_id)
	local list = self:GetSpecialImageList()
	local num = 0
	for k, v in ipairs(list) do
		num = num + 1
		if v.item_id == image_id then
			return v.image_id, num
		end
	end
end

function ShengongData:GetOpenSpecialImageList()
	if self.open_special_image_list then
		return self.open_special_image_list
	else
		self:GetSpecialImageList()
	end
end

function ShengongData:GetSpecialImageUpgradeCfg()
	return self.shengong_cfg.special_image_upgrade
end

function ShengongData:GetShengongSkillCfg()
	return self.shengong_cfg.shengong_skill
end

function ShengongData:GetShengongImageCfg()
	return self.shengong_cfg.image_list
end

function ShengongData:GetShengongEquipCfg()
	return self.shengong_cfg.shengong_equip
end

function ShengongData:GetShengongEquipExpCfg()
	return self.shengong_cfg.equip_exp
end

function ShengongData:GetShengongEquipRandAttr()
	return self.shengong_cfg.equip_attr_range
end

function ShengongData:GetShengongUpStarPropCfg()
	return self.shengong_cfg.up_start_stuff
end

function ShengongData:IsShengongStuff(item_id)
	for k,v in pairs(self.shengong_cfg.up_start_stuff) do
		if item_id == v.up_star_item_id then
			return true
		end
	end
	return false
end

function ShengongData:GetShengongUpStarCfg()
	return self.shengong_cfg.up_start_exp
end

function ShengongData:GetShengongMaxUpStarLevel()
	return #self.shengong_cfg.up_start_exp
end

function ShengongData:GetOhterCfg()
	return self.shengong_cfg.other[1]
end

-- 全属性加成所需阶数
function ShengongData:GetActiveNeedGrade()
  	local other_cfg = self:GetOhterCfg()
  	return other_cfg.extra_attrs_per_grade or 1
end

-- 当前阶数
function ShengongData:GetGrade()
  	return self.shengong_info.grade or 0
end
function ShengongData:GetInfoGrade()
  	return self.shengong_info
end

-- 全属性加成百分比
function ShengongData:GetAllAttrPercent()
  	local other_cfg = self:GetOhterCfg()
  	-- local attr_percent = math.floor(other_cfg.extra_attrs_per / 100) 	-- 万分比转为百分比
  	return attr_percent or 0
end

-- 根据当前属性的战力，计算全属性百分比的战力加成
function ShengongData:CalculateAllAttrCap(cap)
	if self:GetGrade() >= self:GetActiveNeedGrade() then
		return math.floor(cap * self:GetAllAttrPercent() * 0.01)
	end
	return 0
end

-- 获取当前点击坐骑特殊形象的配置
function ShengongData:GetSpecialImageUpgradeInfo(index, grade, is_next)
	if (index == 0) or nil then
		return
	end
	local grade = grade or self.shengong_info.special_img_grade_list[index] or 0
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
function ShengongData:GetSpecialImageMaxUpLevelById(image_id)
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
function ShengongData:GetImageListInfo(index)
	if (index == 0) or nil then
		return
	end
	for k, v in pairs(self:GetShengongImageCfg()) do
		if v.image_id == index then
			return v
		end
	end

	return nil
end

-- 获取当前点击坐骑技能的配置
function ShengongData:GetShengongSkillCfgById(skill_idx, level, shengong_info)
	local shengong_info = shengong_info or self.shengong_info
	local level = level or shengong_info.skill_level_list[skill_idx]

	for k, v in pairs(self:GetShengongSkillCfg()) do
		if v.skill_idx == skill_idx and v.skill_level == level then
			return v
		end
	end

	return nil
end

-- 获取特殊形象总增加的属性
function ShengongData:GetSpecialImageAttrSum(shengong_info)
	shengong_info = shengong_info or self.shengong_info
	local sum_attr_list = CommonStruct.Attribute()
	if self.shengong_info.active_special_image_flag == nil then
		sum_attr_list.chengzhangdan_count = 0
		sum_attr_list.shuxingdan_count = 0
		sum_attr_list.equip_limit = 0
		return sum_attr_list
	end

	local special_chengzhangdan_count = 0
	local special_shuxingdan_count = 0
	local special_equip_limit = 0
	local special_img_upgrade_info = nil
	for k, v in pairs(self.shengong_info.active_special_image_flag) do
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
	if self:GetShengongGradeCfg(shengong_info.grade) then
		sum_attr_list.chengzhangdan_count = special_chengzhangdan_count + self:GetShengongGradeCfg(shengong_info.grade).chengzhangdan_limit
		sum_attr_list.shuxingdan_count = special_shuxingdan_count + self:GetShengongGradeCfg(shengong_info.grade).shuxingdan_limit
		sum_attr_list.equip_limit = special_equip_limit + self:GetShengongGradeCfg(shengong_info.grade).equip_level_limit
	end

	return sum_attr_list
end

-- 获得已学习的技能总战力
function ShengongData:GetShengongSkillAttrSum(shengong_info)
	local attr_list = CommonStruct.Attribute()
	for i = 0, 3 do
		local skill_cfg = self:GetShengongSkillCfgById(i, nil, shengong_info)
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
function ShengongData:GetShengongEquipAttrSum(shengong_info)
	shengong_info = shengong_info or self.shengong_info
	local attr_list = CommonStruct.Attribute()
	if nil == shengong_info.equip_level_list then return attr_list end
	for k, v in pairs(shengong_info.equip_level_list) do
		attr_list = CommonDataManager.AddAttributeAttr(attr_list, CommonDataManager.GetAttributteByClass(self:GetEquipInfoCfg(k, v)))
	end
	return attr_list
end

-- 获取已吃成长丹，资质丹属性
function ShengongData:GetDanAttr(shengong_info)
	shengong_info = shengong_info or self.shengong_info
	if shengong_info.shengong_level >= self:GetMaxShengongLevelCfg() then
		shengong_info.shengong_level = self:GetMaxShengongLevelCfg()
	end
	local attr_list = CommonStruct.Attribute()
	local shengong_level_cfg = self:GetShengongLevelCfg(shengong_info.shengong_level)
	local shengong_up_star_cfg = self:GetShengongUpStarCfgByLevel(shengong_info.star_level)
	shengong_up_star_cfg = shengong_up_star_cfg or CommonStruct.AttributeNoUnderline()
	local shenyi_shuxingdan_cfg = AdvanceData.Instance:GetShuXingDanCfg(ShengongShuXingDanCfgType.Type)
	if shenyi_shuxingdan_cfg and next(shenyi_shuxingdan_cfg) then
		attr_list.gong_ji = attr_list.gong_ji + shenyi_shuxingdan_cfg.gongji * shengong_info.shuxingdan_count
		attr_list.fang_yu = attr_list.fang_yu + shenyi_shuxingdan_cfg.fangyu * shengong_info.shuxingdan_count
		attr_list.max_hp = attr_list.max_hp + shenyi_shuxingdan_cfg.maxhp * shengong_info.shuxingdan_count
	end

	return attr_list
end

-- 获得特殊属性更高的
function ShengongData:GetGradeAndSpecialAttr()
	local cfg = self:GetShengongGradeCfg(self.shengong_info.grade)
	for k, v in ipairs (self.shengong_cfg.grade) do
		if v.per_jingzhun > cfg.per_jingzhun then
			return v.grade, v.per_jingzhun - cfg.per_jingzhun
		end
	end
end

function ShengongData:GetShengongAttrSum(shengong_info, is_advancesucce)
	shengong_info = shengong_info or self:GetShengongInfo()
	if nil == shengong_info.grade or shengong_info.grade <= 0 then
		return 0
	end
	if shengong_info.shengong_level >= self:GetMaxShengongLevelCfg() then
		shengong_info.shengong_level = self:GetMaxShengongLevelCfg()
	end
	-- local shengong_level_cfg = self:GetShengongLevelCfg(shengong_info.shengong_level)
	local shengong_grade_cfg = self:GetShengongGradeCfg(shengong_info.grade)
	local level = is_advancesucce and math.floor(shengong_info.star_level / 10) * 10 or shengong_info.star_level
	local shengong_up_star_cfg = self:GetShengongUpStarCfgByLevel(level) or CommonStruct.AttributeNoUnderline()
	local skill_attr = self:GetShengongSkillAttrSum(shengong_info)
	local dan_attr = self:GetDanAttr(shengong_info)
	local special_img_attr = self:GetSpecialImageAttrSum(shengong_info)
	local medal_percent = MedalData.Instance:GetMedalSuitActiveCfg() and MedalData.Instance:GetMedalSuitActiveCfg().magic_bow_attr_add / 10000 or 0

	local attr = CommonStruct.Attribute()
	attr.max_hp = (shengong_grade_cfg.maxhp
				+ shengong_up_star_cfg.maxhp
				+ skill_attr.max_hp
				+ dan_attr.max_hp
				+ special_img_attr.max_hp)
				+ (medal_percent) * (shengong_grade_cfg.maxhp + shengong_up_star_cfg.maxhp)

	attr.gong_ji = (shengong_grade_cfg.gongji
				+ shengong_up_star_cfg.gongji
				+ skill_attr.gong_ji
				+ dan_attr.gong_ji
				+ special_img_attr.gong_ji)
				+ (medal_percent) * (shengong_grade_cfg.gongji + shengong_up_star_cfg.gongji)

	attr.fang_yu = (shengong_grade_cfg.fangyu
				+ shengong_up_star_cfg.fangyu
				+ skill_attr.fang_yu
				+ dan_attr.fang_yu
				+ special_img_attr.fang_yu)
				+ (medal_percent) * (shengong_grade_cfg.fangyu + shengong_up_star_cfg.fangyu)

	attr.ming_zhong = (shengong_grade_cfg.mingzhong
					+ shengong_up_star_cfg.mingzhong
					+ skill_attr.ming_zhong
					+ dan_attr.ming_zhong
					+ special_img_attr.ming_zhong)
					+ (medal_percent) * (shengong_grade_cfg.mingzhong + shengong_up_star_cfg.mingzhong)

	attr.shan_bi = (shengong_grade_cfg.shanbi
				+ shengong_up_star_cfg.shanbi
				+ skill_attr.shan_bi
				+ dan_attr.shan_bi
				+ special_img_attr.shan_bi)
				+ (medal_percent) * (shengong_grade_cfg.shanbi + shengong_up_star_cfg.shanbi)

	attr.bao_ji = (shengong_grade_cfg.baoji
				+ shengong_up_star_cfg.baoji
				+ skill_attr.bao_ji
				+ dan_attr.bao_ji
				+ special_img_attr.bao_ji)
				+ (medal_percent) * (shengong_grade_cfg.baoji + shengong_up_star_cfg.baoji)

	attr.jian_ren = (shengong_grade_cfg.jianren
				+ shengong_up_star_cfg.jianren
				+ skill_attr.jian_ren
				+ dan_attr.jian_ren
				+ special_img_attr.jian_ren)
				+ (medal_percent) * (shengong_grade_cfg.jianren + shengong_up_star_cfg.jianren)
	attr.extra_zengshang = shengong_grade_cfg.extra_zengshang						--额外伤害值
	attr.extra_mianshang = shengong_grade_cfg.extra_mianshang					--额外减伤值
	attr.per_jingzhun = shengong_grade_cfg.per_jingzhun							-- 破甲
	attr.per_baoji = shengong_grade_cfg.per_baoji								-- 暴伤
	attr.per_zengshang = shengong_grade_cfg.per_zengshang							--伤害加成万分比
	attr.per_jianshang = shengong_grade_cfg.per_jianshang							--伤害减免万分比
	attr.pvp_jianshang = shengong_grade_cfg.pvp_jianshang							-- pvp减伤
	attr.pvp_zengshang = shengong_grade_cfg.pvp_zengshang							-- pvp增伤
	attr.pve_jianshang = shengong_grade_cfg.pve_jianshang							-- pve减伤
	attr.pve_zengshang = shengong_grade_cfg.pve_zengshang							-- pve增伤
	return attr
end

function ShengongData:GetSpecialAttrActiveType(cur_grade)
	cur_grade = cur_grade or self.shengong_info.grade or 0
	return AdvanceData.Instance:GetSpecialAttrActiveType(self.shengong_cfg.grade, cur_grade)
end

function ShengongData:GetHuanHuaSpecialAttrActiveType(grade, index)
	local grade = grade or self.shengong_info.special_img_grade_list[index] or 0
	return AdvanceData.Instance:GetSpecialAttrActiveType(self.shengong_cfg.special_image_upgrade, grade, index)
end

--在原来的基础上加上进阶到满级的属性
function ShengongData:GetShengongMaxAttrSum(shengong_info, is_advancesucce)
	shengong_info = shengong_info or self:GetShengongInfo()
	if nil == shengong_info.grade or shengong_info.grade <= 0 then
		return 0
	end
	if shengong_info.shengong_level >= self:GetMaxShengongLevelCfg() then
		shengong_info.shengong_level = self:GetMaxShengongLevelCfg()
	end
	local shengong_level_cfg = self:GetShengongLevelCfg(shengong_info.shengong_level)
	local level = is_advancesucce and math.floor(shengong_info.star_level / 10) * 10 or shengong_info.star_level
	local shengong_up_star_cfg = self:GetShengongUpStarCfgByLevel(100) or CommonStruct.AttributeNoUnderline()
	local skill_attr = self:GetShengongSkillAttrSum(shengong_info)
	local dan_attr = self:GetDanAttr(shengong_info)
	local special_img_attr = self:GetSpecialImageAttrSum(shengong_info)
	local medal_percent = MedalData.Instance:GetMedalSuitActiveCfg() and MedalData.Instance:GetMedalSuitActiveCfg().magic_bow_attr_add / 10000 or 0

	local attr = CommonStruct.Attribute()
	attr.max_hp = (shengong_level_cfg.maxhp
				+ shengong_up_star_cfg.maxhp
				+ skill_attr.max_hp
				+ dan_attr.max_hp
				+ special_img_attr.max_hp)
				+ (medal_percent) * (shengong_level_cfg.maxhp + shengong_up_star_cfg.maxhp)

	attr.gong_ji = (shengong_level_cfg.gongji
				+ shengong_up_star_cfg.gongji
				+ skill_attr.gong_ji
				+ dan_attr.gong_ji
				+ special_img_attr.gong_ji)
				+ (medal_percent) * (shengong_level_cfg.gongji + shengong_up_star_cfg.gongji)

	attr.fang_yu = (shengong_level_cfg.fangyu
				+ shengong_up_star_cfg.fangyu
				+ skill_attr.fang_yu
				+ dan_attr.fang_yu
				+ special_img_attr.fang_yu)
				+ (medal_percent) * (shengong_level_cfg.fangyu + shengong_up_star_cfg.fangyu)

	attr.ming_zhong = (shengong_level_cfg.mingzhong
					+ shengong_up_star_cfg.mingzhong
					+ skill_attr.ming_zhong
					+ dan_attr.ming_zhong
					+ special_img_attr.ming_zhong)
					+ (medal_percent) * (shengong_level_cfg.mingzhong + shengong_up_star_cfg.mingzhong)

	attr.shan_bi = (shengong_level_cfg.shanbi
				+ shengong_up_star_cfg.shanbi
				+ skill_attr.shan_bi
				+ dan_attr.shan_bi
				+ special_img_attr.shan_bi)
				+ (medal_percent) * (shengong_level_cfg.shanbi + shengong_up_star_cfg.shanbi)

	attr.bao_ji = (shengong_level_cfg.baoji
				+ shengong_up_star_cfg.baoji
				+ skill_attr.bao_ji
				+ dan_attr.bao_ji
				+ special_img_attr.bao_ji)
				+ (medal_percent) * (shengong_level_cfg.baoji + shengong_up_star_cfg.baoji)

	attr.jian_ren = (shengong_level_cfg.jianren
				+ shengong_up_star_cfg.jianren
				+ skill_attr.jian_ren
				+ dan_attr.jian_ren
				+ special_img_attr.jian_ren)
				+ (medal_percent) * (shengong_level_cfg.jianren + shengong_up_star_cfg.jianren)

	return attr
end
function ShengongData:IsShowZizhiRedPoint()
	if nil == next(self.shengong_info) then
		return
	end
	
	local shengong_shuxingdan_cfg = AdvanceData.Instance:GetShuXingDanCfg(ShengongShuXingDanCfgType.Type)
	if not shengong_shuxingdan_cfg or not next(shengong_shuxingdan_cfg) then
		return false
	end

	if self.shengong_info.grade < shengong_shuxingdan_cfg.order_limit then
		return false
	end

	local count_limit = self:GetSpecialImageAttrSum().shuxingdan_count
	if self.shengong_info.shuxingdan_count == nil or count_limit == nil then
		return false
	end
	if self.shengong_info.shuxingdan_count >= count_limit then
		return false
	end

	if ItemData.Instance:GetItemNumInBagById(ShengongDanId.ZiZhiDanId) > 0 then
		return true
	end

	return false
end

function ShengongData:IsShowChengzhangRedPoint()
	local count_limit = self:GetSpecialImageAttrSum().chengzhangdan_count
	if self.shengong_info.chengzhangdan_count == nil or count_limit == nil then
		return false
	end
	if self.shengong_info.chengzhangdan_count >= count_limit then
		return false
	end
	for k, v in pairs(ItemData.Instance:GetBagItemDataList()) do
		if v.item_id == ShengongDanId.ChengZhangDanId then
			return true
		end
	end
	return false
end

-- 是否可以幻化
function ShengongData:CanHuanhuaUpgrade()
	if self.shengong_info.grade == nil or self.shengong_info.grade <= 0 then return 0 end
	
	if self.shengong_info.special_img_grade_list == nil then
		return 0
	end
	local image_id = self:GetBigTargetImageId()
	for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
		if v.stuff_num <= ItemData.Instance:GetItemNumInBagById(v.stuff_id)
			and self.shengong_info.special_img_grade_list[v.special_img_id] == v.grade and
			self.shengong_info.special_img_grade_list[v.special_img_id] < self.maxshengong_special_level 
			and v.special_img_id ~= image_id then 								--大目标去除
			return v.special_img_id
		end
	end
	return 0
end

function ShengongData:HuanhuaRed()
	return self:CanHuanhuaUpgrade() == 0 and 0 or 1
end
--
function ShengongData:IsCanHuanhuaUpgrade()
	if self.shengong_info.grade == nil or self.shengong_info.grade <= 0 then return false end
	if self.shengong_info.special_img_grade_list == nil then
		return false
	end

	for i, j in pairs(self:GetSpecialImageUpgradeCfg()) do
		if j.stuff_num <= ItemData.Instance:GetItemNumInBagById(j.stuff_id)
			and self.shengong_info.special_img_grade_list[j.special_img_id] == j.grade and
			self.shengong_info.special_img_grade_list[j.special_img_id] < self.maxshengong_special_level then
			return true
		end
	end

	return false
end

function ShengongData:CanSkillUpLevelList()
	local list = {}
	if self.shengong_info.grade == nil or self.shengong_info.grade <= 0 then return list end
	if self.shengong_info.skill_level_list == nil then
		return list
	end

	for i, j in pairs(self:GetShengongSkillCfg()) do
		if j.uplevel_stuff_num <= ItemData.Instance:GetItemNumInBagById(j.uplevel_stuff_id)
			and self.shengong_info.skill_level_list[j.skill_idx] == (j.skill_level - 1)
			and j.grade <= self.shengong_info.grade and j.skill_type ~= 0 then
			list[j.skill_idx] = j.skill_idx
		end
	end

	return list
end

function ShengongData:GetMaxSpecialImageCfgById(id)
	local list = {}
	if id == nil then return list end
	for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
		if id == v.special_img_id then
			list[v.grade] = v
		end
	end
	return #list
end

function ShengongData:GetBigTargetImageId()
	return JinJieRewardData.Instance:GetSingleRewardCfgParam0(JINJIE_TYPE.JINJIE_TYPE_SHENGONG)
end

function ShengongData:GetShengongUpStarCfgByLevel(level)
	if nil == level then return end

	for k, v in pairs(self:GetShengongUpStarCfg()) do
		if v.star_level == level then
			return v
		end
	end

	return nil
end

function ShengongData:GetChengzhangDanLimit()
	for i = 1, self:GetMaxGrade() do
		if self:GetGradeCfg()[i] and self:GetGradeCfg()[i].chengzhangdan_limit > 0 then
			return self:GetGradeCfg()[i]
		end
	end
	return nil
end

function ShengongData:GetShengongGradeByUseImageId(used_imageid)
	if not used_imageid then return 0 end
	local image_list = self:GetShengongImageCfg()
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

function ShengongData:GetIsRichMoneyUpLevel(item_id)
	local is_rich = true
	local exp_cfg = 1
	local need_exp = self:GetShengongUpStarCfgByLevel(self.shengong_info.star_level).up_star_level_exp
	local num = 0
	for k,v in pairs(self:GetShengongUpStarPropCfg()) do
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

function ShengongData:IsActiviteShengong()
	local active_flag = self.shengong_info and self.shengong_info.active_image_flag or {}
	for k, v in pairs(active_flag) do
		if v == 1 then
			return true
		end
	end
	return false
end

function ShengongData:GetShowShengongRes(grade)
	local grade = grade
	local shengong_grade_cfg = self:GetShengongGradeCfg(grade)
	if not shengong_grade_cfg then return -1 end
	local image_cfg = nil
	if shengong_grade_cfg then
		image_cfg = self:GetShengongImageCfg()
	end
	if self.shengong_info.used_imageid < 1000 then
		if image_cfg then
			return image_cfg[shengong_grade_cfg.image_id].res_id
		end
		return -1
	end

	if grade == self.shengong_info.grade then
		return self:GetSpecialImageCfg(self.shengong_info.used_imageid - 1000).res_id
	else
		if image_cfg then
			return image_cfg[shengong_grade_cfg.image_id].res_id
		end
		return -1
	end
end

-- 为了不改到上面的逻辑，复制多一个函数
function ShengongData:GetShowShengongResID(grade)
	local grade = grade
	local shengong_grade_cfg = self:GetShengongGradeCfg(grade)
	local image_cfg = nil
	if shengong_grade_cfg then
		image_cfg = self:GetShengongImageCfg()
	end
	if image_cfg then
		return image_cfg[shengong_grade_cfg.image_id].res_id
	end
	return -1
end

function ShengongData:GetBitFlag()
	return self.shengong_info.active_special_image_flag
end
function ShengongData:GetGoddessShengongRes()
	if self.shengong_info.used_imageid == 0 then
		return -1
	end
	if self.shengong_info.used_imageid > 1000 then
		return self:GetSpecialImageCfg(self.shengong_info.used_imageid - 1000).res_id
	end
	local image_cfg = self:GetShengongImageCfg()
	if image_cfg then
		return image_cfg[self.shengong_info.used_imageid].res_id
	end
	return -1
end

function ShengongData:IsShowCancelHuanhuaBtn(grade)
	if grade == self.shengong_info.grade then
		if self.shengong_info.used_imageid > 1000 then
			return true
		end
	end
	return false
end

function ShengongData:GetColorName(grade)
	local image_id = self:GetShengongGradeCfg(grade).image_id
	local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)
	local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..self:GetShengongImageCfg()[image_id].image_name.."</color>"
	return name_str
end

function ShengongData:GetName(grade)
	local image_id = self:GetShengongGradeCfg(grade).image_id
	return self:GetShengongImageCfg()[image_id].image_name
end

function ShengongData:GetEquipInfoCfg(equip_index, level)
	if nil == self.equip_info_cfg[equip_index] then
		return
	end
	return self.equip_info_cfg[equip_index][level]
end

function ShengongData:CalAllEquipRemind()
	if not self:IsOpenEquip() then return 0 end
	for k, v in pairs(self.shengong_info.equip_level_list) do
		if self:CalEquipRemind(k) > 0 then
			return 1
		end
	end
	return 0
end

function ShengongData:CalEquipRemind(equip_index)
	if nil == self.shengong_info or nil == next(self.shengong_info) then
		return 0
	end

	local equip_level = self.shengong_info.equip_level_list[equip_index] or 0
	local equip_cfg = self:GetEquipInfoCfg(equip_index, equip_level + 1)
	if nil == equip_cfg then return 0 end

	local grade_info_cfg = self:GetShengongGradeCfg(self.shengong_info.grade)
	local equip_level_toplimit = grade_info_cfg.equip_level_toplimit
	if self.shengong_info.grade < self:GetEquipLevelLimit() or equip_level >= equip_level_toplimit then
		return 0
	end
	
	local item_data = equip_cfg.item
	local had_prop_num = ItemData.Instance:GetItemNumInBagById(item_data.item_id)
	if equip_level == 100 then
		return 0
	end
	return had_prop_num >= item_data.num and 1 or 0
end

function ShengongData:GetEquipLevelLimit()
	for k, v in ipairs(self.shengong_cfg.grade) do
		if v.equip_level_toplimit ~= 0 then
			return k
		end
	end
	return 0
end

function ShengongData:IsOpenEquip()
	if nil == self.shengong_info or nil == next(self.shengong_info) then
		return false, 0
	end

	local otehr_cfg = self:GetOhterCfg()
	if self.shengong_info.grade >= otehr_cfg.active_equip_grade then
		return true, 0
	end

	return false, otehr_cfg.active_equip_grade
end

function ShengongData:GetEquipMinLevel()
	if nil == self.shengong_info or nil == next(self.shengong_info) then
		return 0
	end
	local min_level = 999
	for k, v in pairs(self.shengong_info.equip_level_list) do
		if min_level > v then
			min_level = v
		end
	end
	return min_level
end

function ShengongData:IsActiveEquipSkill()
	if nil == self.shengong_info or nil == next(self.shengong_info) then
		return false
	end
	return self.shengong_info.equip_skill_level > 0
end

function ShengongData:GetClearBlessGrade()
	return self.clear_bless_grade, self.clear_bless_grade_name
end

function ShengongData:GetShuXinLevel()
	for k, v in ipairs(self.shengong_cfg.grade) do
		if v.per_jingzhun ~= 0 then
			return v.grade 
		end
	end 
	return 0
end

--当前等级基础战力 power  额外属性加成 huanhua_add_per
function ShengongData:GetCurGradeBaseFightPowerAndAddPer()
	local power = 0
	local huanhua_add_per = 0

	local grade = self:GetGrade()
	local cur_grade = grade == 0 and 1 or grade
	local attr_cfg = self:GetShengongGradeCfg(cur_grade)
	local attr = CommonDataManager.GetAttributteByClass(attr_cfg)
	power = CommonDataManager.GetCapabilityCalculation(attr)

	local active_add_per_need_level = self:GetActiveNeedGrade() 
	if grade >= active_add_per_need_level then
		huanhua_add_per = self:GetAllAttrPercent()
	end

	return power, huanhua_add_per
end

--得到幻化形象当前等级
function ShengongData:GetSingleSpecialImageGrade(image_id)
	local grade = 0
	if nil == self.shengong_info or nil == self.shengong_info.special_img_grade_list or nil == self.shengong_info.special_img_grade_list[image_id] then
		return grade
	end

	grade = self.shengong_info.special_img_grade_list[image_id]
	return grade
end

--当前使用形象
function ShengongData:GetUsedImageId()
	return self.shengong_info.used_imageid
end

--当前进阶等级对应的image_id
function ShengongData:GetCurGradeImageId()
	local image_id = 0
	local cfg = self:GetShengongGradeCfg(self.shengong_info.grade)
	if cfg then
		image_id = cfg.image_id or 0
	end

	return image_id
end

------------------------------------------------幻化超级战力-------------------------------------------------
--获取配置判断超级战力是否开启 0/1 不开启/开启
function ShengongData:SuperPowerIsOpenByCfg()
	local other_cfg = self:GetOhterCfg()
	local open_flag = other_cfg and other_cfg.is_open_special_cap_add
	local is_open = false
	if open_flag then
		is_open = open_flag == 1
	end

	return is_open
end

--特殊星星是否显示
function ShengongData:GetStarIsShowSuperPower(huanhua_id)
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
function ShengongData:IsShowSuperPower(huanhua_id)
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
function ShengongData:GetSingleHuanHuaSpecialCapAddList(huanhua_id)
	local list = {}
	if nil == huanhua_id or nil == self.huanhua_special_cap_add or nil == self.huanhua_special_cap_add[huanhua_id] then
		return list
	end

	list = self.huanhua_special_cap_add[huanhua_id]
	return list
end

--获取激活超级形象的要求等级
function ShengongData:GetActiveSuperPowerNeedLevel(huanhua_id)
	local level = 0
	local list = self:GetSingleHuanHuaSpecialCapAddList(huanhua_id)
	if list and list.huanhua_level then
		level = list.huanhua_level
	end

	return level
end

--特殊战力面板显示数据
function ShengongData:GetSpecialHuanHuaShowData(huanhua_id)
	local data_list = CommonStruct.SpecialHuanHuaTipInfo()
	if nil == huanhua_id then
		return data_list
	end

	local cfg = self:GetSingleHuanHuaSpecialCapAddList(huanhua_id)
	local huanhua_cfg = self:GetSpecialImageCfg(huanhua_id)
	local image_name = huanhua_cfg and huanhua_cfg.image_name or ""
	-- local name = image_name or "" 
	local color_name_str = ""
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(huanhua_cfg.item_id or 0)
	if item_cfg and (item_cfg.limit_prof == prof or item_cfg.limit_prof == 5) then
		color_name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
	end

	local need_level = cfg.huanhua_level or 0
	local cur_level = self:GetSingleSpecialImageGrade(huanhua_id) or 0
	local color = cur_level >= need_level and TEXT_COLOR.GREEN_4 or TEXT_COLOR.RED
	local cur_level_str = ToColorStr(cur_level, color)
	local desc_str = string.format(Language.Advance.ShengongHuanHuaTips, color_name_str, cur_level_str, ToColorStr(need_level, TEXT_COLOR.GREEN_4))

 	data_list.max_hp = cfg.maxhp or 0								-- 生命
	data_list.gong_ji = cfg.gongji or 0 							-- 攻击
	data_list.fang_yu = cfg.fangyu or 0								-- 防御
	data_list.desc = desc_str										-- 描述
	return data_list
end
-----------------------------------------------幻化超级战力结束----------------------------------------------
function ShengongData:GetSpecialImagesCfgByImageId(image_id)
	local cfg = {}
	if nil == image_id then
		return cfg
	end
	
	local list = self:GetSpecialImagesCfg()
	cfg = list and list[image_id]
	return cfg or {}
end

--得到当前使用image_id配置
function ShengongData:GetCurUseImageCfgByImageId(image_id)
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
function ShengongData:GetResIdByImageId(image_id)
	local res_id = 0
	local image_info = self:GetCurUseImageCfgByImageId(image_id)
	if image_info and image_info.res_id then
		res_id = image_info.res_id
	end

	return res_id
end

function ShengongData:IsHaveZhiShengDanInGrade()
	if self.shengong_info and next(self.shengong_info) then
		local zhishengdan_list = ItemData.Instance:GetItemListByBigType(GameEnum.ITEM_BIGTYPE_EXPENSE)
		for k, v in pairs(zhishengdan_list) do
			local item_cfg, bag_type = ItemData.Instance:GetItemConfig(v.item_id)
			if item_cfg.use_type == 71 and item_cfg.param2 == self.shengong_info.grade then
				return true, item_cfg.id
			end
		end
	end
	return false, nil
end