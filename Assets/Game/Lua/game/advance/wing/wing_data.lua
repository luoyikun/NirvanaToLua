WingData = WingData or BaseClass()

WingDanId = {
		ChengZhangDanId = 22114,
		ZiZhiDanId = 22109,
}

WingShuXingDanCfgType = {
		Type = 6
}

WingDataEquipId = {
	16100, 16110, 16120, 16130
}
local TALENTLEVEL = 8
function WingData:__init()
	if WingData.Instance then
		print_error("[ItemData] Attemp to create a singleton twice !")
	end
	WingData.Instance = self

	self.wing_info = {}
	self.temp_img_id = 0
	self.temp_img_id_has_select = 0
	self.temp_img_time = 0
	self.wing_cfg = ConfigManager.Instance:GetAutoConfig("wing_auto")
	self.special_upgrade_cfg = ListToMap(self.wing_cfg.special_image_upgrade, "special_img_id", "grade")
	self.equip_info_cfg = ListToMap(self.wing_cfg.wing_equip_info, "equip_idx", "equip_level")
	self.huanhua_special_cap_add = ListToMap(self.wing_cfg.huanhua_special_cap_add, "huanhua_id")			--幻化特殊战力加成
	self.clear_bless_grade = 100
	self.clear_bless_grade_name = ""
	for i,v in ipairs(self.wing_cfg.grade) do
		if v.is_clear_bless == 1 then
			self.clear_bless_grade = v.grade
			self.clear_bless_grade_name = v.gradename
			break
		end
	end
end

function WingData:__delete()
	if WingData.Instance then
		WingData.Instance = nil
	end
	self.wing_info = {}
end

function WingData:SetWingInfo(protocol)
	if self.wing_info.grade_bless_val then
		local diff = protocol.grade_bless_val - self.wing_info.grade_bless_val
		local bless_cfg =  AdvanceData.Instance:GetBlessBaojiCfg(UPGRADE_BAOJI_TYPE.UPGRADE_TYPE_WING)
		local baoji_bless = bless_cfg.upgrade_exp * bless_cfg.crit_value
		if diff > 0 and diff == baoji_bless then
			TipsCtrl.Instance:OpenBaojiViewTips("advance_view")
		end
	end
	
	self.wing_info.wing_level = protocol.wing_level
	self.wing_info.grade = protocol.grade
	self.wing_info.grade_bless_val = protocol.grade_bless_val
	self.wing_info.used_imageid = protocol.used_imageid
	self.wing_info.shuxingdan_count = protocol.shuxingdan_count
	self.wing_info.chengzhangdan_count = protocol.chengzhangdan_count
	self.wing_info.active_image_flag = bit:uc2b(protocol.active_image_flag)
	self.wing_info.clear_upgrade_time = protocol.clear_upgrade_time
	self.wing_info.star_level = protocol.star_level
	self.wing_info.equip_skill_level = protocol.equip_skill_level
	self.wing_info.equip_level_list = protocol.equip_level_list
	self.wing_info.skill_level_list = protocol.skill_level_list
	self.wing_info.special_img_grade_list = protocol.special_img_grade_list
	self.temp_img_id = protocol.temp_img_id
	self.temp_img_id_has_select = protocol.temp_img_id_has_select
	self.temp_img_time = protocol.temp_img_time
	self.wing_info.active_special_image_flag = bit:uc2b(protocol.active_special_image)
end

function WingData:GetSpecialImageIsActive(img_id)
	local act_flag = self.wing_info.active_special_image_flag
	return act_flag and 1 == act_flag[img_id] or false
end

function WingData:GetLevelAttribute()
	local level_cfg = self:GetWingStarLevelCfg(self.wing_info.star_level)
	return CommonDataManager.GetAttributteByClass(level_cfg)
end

function WingData:IsShowTempWingIcon()
	if self.temp_img_id_has_select == 0 and self.temp_img_time ~= 0 then
		return false
	end
	return true
end

function WingData:GetTempWingTime()
	return self.temp_img_time
end

function WingData:HasChooseTempWing()
	return self.temp_img_id_has_select ~= 0
end

function WingData:GetTempImgId()
	return self.temp_img_id_has_select
end


function WingData:GetWingInfo()
	return self.wing_info
end

function WingData:GetWingLevelCfg(wing_level)
	if wing_level >= self:GetMaxWingLevelCfg() then
		wing_level = self:GetMaxWingLevelCfg()
	end
	return self.wing_cfg.level[wing_level]
end

function WingData:GetMaxWingLevelCfg()
	return #self.wing_cfg.level
end

function WingData:GetWingGradeCfg(wing_grade)
	local wing_grade = wing_grade or self.wing_info.grade or 0
	if wing_grade > self:GetMaxGrade() then
		wing_grade = self:GetMaxGrade()
	end
	return self.wing_cfg.grade[wing_grade]
end

function WingData:GetSpecialImageCfg(image_id)
	local wing_config = self.wing_cfg.special_img
	return wing_config[image_id]
end

function WingData:GetSpecialImagesCfg()
	return self.wing_cfg.special_img
end

-- 获取可显示的幻化列表
function WingData:GetHuanHuaCfgList()
	local huanhua_list = {}
	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	for _, v in ipairs(self.wing_cfg.special_img) do
		if main_vo.level >= v.lvl and open_server_day >= v.open_day and (v.is_shenci == nil or v.is_shenci == 0) then
			table.insert(huanhua_list, v)
		end
	end
	return huanhua_list
end

function WingData:GetShenCiHuanHuaCfgList()
	local huanhua_list = {}
	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	for _, v in ipairs(self.wing_cfg.special_img) do
		if main_vo.level >= v.lvl and open_server_day >= v.open_day and v.is_shenci and v.is_shenci == 1 then
			table.insert(huanhua_list, v)
		end
	end
	if huanhua_list[1] and huanhua_list[1].zhuanzhi_prof then
		table.sort(huanhua_list, SortTools.KeyLowerSorter("zhuanzhi_prof", "image_id"))
	end
	return huanhua_list
end

function WingData:CanHuanhuaIndexByImageId(image_id)
	local list = self:GetHuanHuaCfgList()
	local num = 0
	for k, v in ipairs(list) do
		num = num + 1
		if v.item_id == image_id then
			return v.image_id, num
		end
	end
end

function WingData:CanShenCiHuanhuaIndexByImageId(image_id)
	local list = self:GetShenCiHuanHuaCfgList()
	local num = 0
	for k, v in ipairs(list) do
		num = num + 1
		if v.item_id == image_id then
			return v.image_id, num
		end
	end
end

function WingData:IsCanHuanhuaDayAndLevel(index)
	local huanhua_list = self:GetHuanHuaCfgList()
	for k, v in pairs(huanhua_list) do
		if v.image_id == index then
			return true
		end
	end
	return false
end

function WingData:IsCanShenCiHuanhuaDayAndLevel(index)
	local huanhua_list = self:GetShenCiHuanHuaCfgList()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local zhuanzhi_prof = math.floor(vo.prof / 10)
	for k, v in pairs(huanhua_list) do
		if v.image_id == index and zhuanzhi_prof >= v.zhuanzhi_prof then
			return true
		end
	end
	return false
end

function WingData:GetMaxGrade()
	return #self.wing_cfg.grade
end

function WingData:GetGradeCfg()
	return self.wing_cfg.grade
end

function WingData:GetMaxSpecialImage()
	return #self.wing_cfg.special_img
end

function WingData:GetSpecialImageUpgradeCfg()
	-- return self.wing_cfg.special_image_upgrade
	return self.special_upgrade_cfg
end

function WingData:GetWingSkillCfg()
	return self.wing_cfg.wing_skill
end

function WingData:GetWingImageCfg()
	return self.wing_cfg.image_list
end

function WingData:GetWingEquipCfg()
	return self.wing_cfg.wing_equip
end

function WingData:GetWingEquipExpCfg()
	return self.wing_cfg.equip_exp
end

function WingData:GetWingEquipRandAttr()
	return self.wing_cfg.equip_attr_range
end

function WingData:GetWingUpStarStuffCfg()
	return self.wing_cfg.up_start_stuff[1]
end

function WingData:GetWingUpStarExpCfg()
	return self.wing_cfg.up_start_exp
end

function WingData:GetOhterCfg()
	return self.wing_cfg.other[1]
end

-- 获取当前点击坐骑特殊形象的配置
function WingData:GetSpecialImageUpgradeInfo(index, grade, is_next)
	if (index == 0) or nil then
		return
	end
	local grade = grade or self.wing_info.special_img_grade_list[index] or 0
	if is_next then
		grade = grade + 1
	end

	local upgrade_cfg = self:GetSpecialImageUpgradeCfg()
	if upgrade_cfg and upgrade_cfg[index] and upgrade_cfg[index][grade] then
		return upgrade_cfg[index][grade]
	end
	-- for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
	-- 	if v.special_img_id == index and v.grade == grade then
	-- 		return v
	-- 	end
	-- end

	return nil
end

-- 获取形象列表的配置
function WingData:GetImageListInfo(index, is_spec)
	if (index == 0) or nil then
		return
	end
	if is_spec then
		for k, v in pairs(self:GetSpecialImagesCfg()) do
			if v.image_id == index then
				return v
			end
		end
	else
		for k, v in pairs(self:GetWingImageCfg()) do
			if v.image_id == index then
				return v
			end
		end
	end

	return nil
end

-- 获取幻化最大等级
function WingData:GetSpecialImageMaxUpLevelById(image_id)
	if not image_id then return 0 end
	local max_level = 0

	local upgrade_cfg = self:GetSpecialImageUpgradeCfg()
	if upgrade_cfg and upgrade_cfg[image_id] then
		return #upgrade_cfg[image_id]
	end

	-- for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
	-- 	if v.special_img_id == image_id and v.grade > 0 then
	-- 		max_level = max_level + 1
	-- 	end
	-- end
	return max_level
end

-- 获取当前点击坐骑技能的配置
function WingData:GetWingSkillCfgById(skill_idx, level, wing_info)
	local wing_info = wing_info or self.wing_info
	local level = level or wing_info.skill_level_list[skill_idx]

	for k, v in pairs(self:GetWingSkillCfg()) do
		if v.skill_idx == skill_idx and v.skill_level == level then
			return v
		end
	end

	return nil
end

-- 获取特殊形象总增加的属性
function WingData:GetSpecialImageAttrSum(wing_info)
	local wing_info = wing_info or self.wing_info
	local sum_attr_list = CommonStruct.Attribute()
	local active_flag = wing_info.active_special_image_flag
	if active_flag == nil then
		sum_attr_list.chengzhangdan_count = 0
		sum_attr_list.shuxingdan_count = 0
		sum_attr_list.equip_limit = 0
		return sum_attr_list
	end
	-- local bit_list = bit:d2b(active_flag)
	local special_chengzhangdan_count = 0
	local special_shuxingdan_count = 0
	local special_equip_limit = 0
	local special_img_upgrade_info = nil
	for k, v in pairs(active_flag) do
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
	if self:GetWingGradeCfg(wing_info.grade) then
		sum_attr_list.chengzhangdan_count = special_chengzhangdan_count + self:GetWingGradeCfg(wing_info.grade).chengzhangdan_limit
		sum_attr_list.shuxingdan_count = special_shuxingdan_count + self:GetWingGradeCfg(wing_info.grade).shuxingdan_limit
		sum_attr_list.equip_limit = special_equip_limit + self:GetWingGradeCfg(wing_info.grade).equip_level_limit
	end

	return sum_attr_list
end

-- 获得已学习的技能总战力
function WingData:GetWingSkillAttrSum(wing_info)
	local attr_list = CommonStruct.Attribute()
	for i = 0, 3 do
		local skill_cfg = self:GetWingSkillCfgById(i, nil, wing_info)
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
function WingData:GetWingEquipAttrSum(wing_info)
	local wing_info = wing_info or self.wing_info
	local attr_list = CommonStruct.Attribute()
	if nil == wing_info.equip_level_list then return attr_list end
	for k, v in pairs(wing_info.equip_level_list) do
		attr_list = CommonDataManager.AddAttributeAttr(attr_list, CommonDataManager.GetAttributteByClass(self:GetEquipInfoCfg(k, v)))
	end
	return attr_list
end

-- 获取已吃成长丹，资质丹属性
function WingData:GetDanAttr(wing_info)
	local wing_info = wing_info or self.wing_info
	local attr_list = CommonStruct.Attribute()
	if wing_info.wing_level >= self:GetMaxWingLevelCfg() then
		wing_info.wing_level = self:GetMaxWingLevelCfg()
	end
	local wing_level_cfg = self:GetWingLevelCfg(wing_info.wing_level)
	local wing_grade_cfg = self:GetWingGradeCfg(wing_info.grade)
	if not wing_grade_cfg then return attr_list end


	local wing_shuxingdan_cfg = AdvanceData.Instance:GetShuXingDanCfg(WingShuXingDanCfgType.Type)
	if wing_shuxingdan_cfg and next(wing_shuxingdan_cfg) then
		attr_list.gong_ji = attr_list.gong_ji + wing_shuxingdan_cfg.gongji * wing_info.shuxingdan_count
		attr_list.fang_yu = attr_list.fang_yu + wing_shuxingdan_cfg.fangyu * wing_info.shuxingdan_count
		attr_list.max_hp = attr_list.max_hp + wing_shuxingdan_cfg.maxhp * wing_info.shuxingdan_count
	end

	return attr_list
end

function WingData:GetWingAttrSum(wing_info, next_level)
	local wing_info = wing_info or self:GetWingInfo()

	local attr = CommonStruct.Attribute()
	if nil == wing_info.grade or wing_info.grade <= 0 or wing_info.wing_level < 1 then
		return attr
	end
	local wing_grade_cfg = {}
	if next_level then
		wing_grade_cfg = self:GetWingGradeCfg(wing_info.grade + 1)
	else
		wing_grade_cfg = self:GetWingGradeCfg(wing_info.grade)
	end
	if not next(wing_grade_cfg) then return attr end
	attr.max_hp = wing_grade_cfg.maxhp or 0
	attr.gong_ji = wing_grade_cfg.gongji or 0
	attr.fang_yu = wing_grade_cfg.fangyu or 0
	attr.ming_zhong = wing_grade_cfg.mingzhong or 0
	attr.shan_bi = wing_grade_cfg.shanbi or 0
	attr.bao_ji = wing_grade_cfg.baoji or 0
	attr.jian_ren = wing_grade_cfg.jianren or 0
	attr.extra_zengshang = wing_grade_cfg.extra_zengshang or 0						--额外伤害值
	attr.extra_mianshang = wing_grade_cfg.extra_mianshang or 0					--额外减伤值
	attr.per_jingzhun = wing_grade_cfg.per_jingzhun or 0							-- 破甲
	attr.per_baoji = wing_grade_cfg.per_baoji or 0								-- 暴伤
	attr.per_zengshang = wing_grade_cfg.per_zengshang or 0							--伤害加成万分比
	attr.per_jianshang = wing_grade_cfg.per_jianshang or 0							--伤害减免万分比
	attr.pvp_jianshang = wing_grade_cfg.pvp_jianshang or 0							-- pvp减伤
	attr.pvp_zengshang = wing_grade_cfg.pvp_zengshang or 0							-- pvp增伤
	attr.pve_jianshang = wing_grade_cfg.pve_jianshang or 0							-- pve减伤
	attr.pve_zengshang = wing_grade_cfg.pve_zengshang or 0							-- pve增伤
	return attr
end

function WingData:GetSpecialAttrActiveType(cur_grade)
	local cur_grade = cur_grade or self.wing_info.grade or 0
	return AdvanceData.Instance:GetSpecialAttrActiveType(self.wing_cfg.grade, cur_grade)
end

function WingData:GetHuanHuaSpecialAttrActiveType(grade, index)
	local grade = grade or self.wing_info.special_img_grade_list[index] or 0
	return AdvanceData.Instance:GetSpecialAttrActiveType(self.wing_cfg.special_image_upgrade, grade, index)
end

function WingData:GetWingStarLevelCfg(star_level)
	local star_level = star_level or self.wing_info.star_level

	for k, v in pairs(self:GetWingUpStarExpCfg()) do
		if v.star_level == star_level then
			return v
		end
	end

	return nil
end

function WingData:IsShowZizhiRedPoint()
	-- local shuxingdan_cfg = ConfigManager.Instance:GetAutoConfig("shuxingdan_cfg_auto").reward
	-- local shuxingdan = {}
	-- for k, v in pairs(shuxingdan_cfg) do
	-- 	if v.type == WingShuXingDanCfgType.Type then
	-- 		shuxingdan = v
	-- 	end
	-- end
	local wing_shuxingdan_cfg = AdvanceData.Instance:GetShuXingDanCfg(WingShuXingDanCfgType.Type)
	if not wing_shuxingdan_cfg or not next(wing_shuxingdan_cfg) then
		return false
	end
	if self.wing_info.grade == nil  then
		return false
	end
	if self.wing_info.grade < wing_shuxingdan_cfg.order_limit then
		return false
	end
	local count_limit = self:GetSpecialImageAttrSum().shuxingdan_count
	if self.wing_info.shuxingdan_count == nil or count_limit == nil then
		return false
	end
	if self.wing_info.shuxingdan_count >= count_limit then
		return false
	end

	if ItemData.Instance:GetItemNumInBagById(WingDanId.ZiZhiDanId) > 0 then
		return true
	end

	return false
end

function WingData:IsShowChengzhangRedPoint()
	local count_limit = self:GetSpecialImageAttrSum().chengzhangdan_count
	if self.wing_info.chengzhangdan_count == nil or count_limit == nil then
		return false
	end
	if self.wing_info.chengzhangdan_count >= count_limit then
		return false
	end
	for k, v in pairs(ItemData.Instance:GetBagItemDataList()) do
		if v.item_id == WingDanId.ChengZhangDanId then
			return true
		end
	end
	return false
end

function WingData:CanHuanhuaUpgradeList()
	local list = {}
	if self.wing_info.grade == nil or self.wing_info.grade <= 0 then
		return list
	end

	local special_img_grade_list = self.wing_info.special_img_grade_list
	if special_img_grade_list == nil then
		return list
	end
	local image_id = self:GetBigTargetImageId()
	local upgrade_cfg = self:GetSpecialImageUpgradeCfg()
	for k,v in pairs(special_img_grade_list) do
		if upgrade_cfg[k] and upgrade_cfg[k][v] then
			local upgrade_info = upgrade_cfg[k][v]
			if ItemData.Instance:GetItemNumInBagById(upgrade_info.stuff_id) >= upgrade_info.stuff_num 
			and v < self:GetSpecialImageMaxUpLevelById(k) 
			and k ~= image_id then
				if self:IsCanHuanhuaDayAndLevel(k) then
					list[k] = k
				end
			end
		end
	end
	return list
end

function WingData:CanHuanhuaUpgrade()
	local list = self:CanHuanhuaUpgradeList()
	return next(list) ~= nil
end

function WingData:CanShenCiHuanhuaUpgradeList()
	local list = {}
	if self.wing_info.grade == nil or self.wing_info.grade <= 0 then
		return list
	end

	local special_img_grade_list = self.wing_info.special_img_grade_list
	if special_img_grade_list == nil then
		return list
	end
	local image_id = self:GetBigTargetImageId()
	local upgrade_cfg = self:GetSpecialImageUpgradeCfg()

	for k,v in pairs(special_img_grade_list) do
		if upgrade_cfg[k] and upgrade_cfg[k][v] then
			local upgrade_info = upgrade_cfg[k][v]
			if ItemData.Instance:GetItemNumInBagById(upgrade_info.stuff_id) >= upgrade_info.stuff_num 
			and v < self:GetSpecialImageMaxUpLevelById(k)
			and k ~= image_id then
				if self:IsCanShenCiHuanhuaDayAndLevel(k) then
					list[k] = k
				end
			end
		end
	end
	return list
end

function WingData:CanShenCiHuanhuaUpgrade()
	local list = self:CanShenCiHuanhuaUpgradeList()
	return next(list) ~= nil
end

function WingData:CanSkillUpLevelList()
	local list = {}
	if self.wing_info.grade == nil or self.wing_info.grade <= 0 then return list end
	if self.wing_info.skill_level_list == nil then
		return list
	end

	for k, v in pairs(self:GetWingSkillCfg()) do
		if ItemData.Instance:GetItemNumInBagById(v.uplevel_stuff_id) >= v.uplevel_stuff_num
			and self.wing_info.skill_level_list[v.skill_idx] == (v.skill_level - 1)
			and v.grade <= self.wing_info.grade and v.skill_type ~= 0 then
			list[v.skill_idx] = v.skill_idx
		end
	end
	return list
end

function WingData:CanJinjie()
	if self.wing_info.grade == nil or self.wing_info.grade <= 0 then return false end
	local stuff_item_id = WingData.Instance:GetWingUpStarStuffCfg().up_star_item_id

	-- local star_cfg = self:GetWingStarLevelCfg(self.wing_info.star_level)
	local item_num = ItemData.Instance:GetItemNumInBagById(stuff_item_id) * self.wing_cfg.up_start_stuff[1].star_exp
	 + self.wing_info.grade_bless_val

	if stuff_item_id then
		if 0 < ItemData.Instance:GetItemNumInBagById(stuff_item_id)
			and self.wing_info.grade < self:GetMaxGrade() then
			-- and item_num >= star_cfg.up_star_level_exp then
			return true
		end
	end
	return false
end

function WingData:GetChengzhangDanLimit()
	for i = 1, self:GetMaxGrade() do
		if self:GetGradeCfg()[i] and self:GetGradeCfg()[i].chengzhangdan_limit > 0 then
			return self:GetGradeCfg()[i]
		end
	end
	return nil
end

function WingData:GetWingGradeByUseImageId(used_imageid)
	if not used_imageid then return 0 end
	local image_list = self:GetWingImageCfg()
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

function WingData:GetBigTargetImageId()
	return JinJieRewardData.Instance:GetSingleRewardCfgParam0(JINJIE_TYPE.JINJIE_TYPE_WING)
end

function WingData:IsActiviteWing()
	local active_flag = self.wing_info and self.wing_info.active_image_flag or {}
	for k, v in pairs(active_flag) do
		if v == 1 then
			return true
		end
	end
	return false
end

function WingData:GetWingModelResCfg(sex, prof)
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

function WingData:GetEquipInfoCfg(equip_index, level)
	if nil == self.equip_info_cfg[equip_index] then
		return
	end
	return self.equip_info_cfg[equip_index][level]
end

function WingData:CalAllEquipRemind()
	if not self:IsOpenEquip() then return 0 end

	for k, v in pairs(self.wing_info.equip_level_list) do
		if self:CalEquipRemind(k) > 0 then
			return 1
		end
	end
	return 0
end

function WingData:CalEquipRemind(equip_index)
	if nil == self.wing_info or nil == next(self.wing_info) then
		return 0
	end

	local equip_level = self.wing_info.equip_level_list[equip_index] or 0
	local equip_cfg = self:GetEquipInfoCfg(equip_index, equip_level + 1)
	if nil == equip_cfg then return 0 end

	local grade_info_cfg = self:GetWingGradeCfg(self.wing_info.grade)
	local equip_level_toplimit = grade_info_cfg.equip_level_toplimit
	if self.wing_info.grade < self:GetEquipLevelLimit() or equip_level >= equip_level_toplimit then
		return 0
	end

	local item_data = equip_cfg.item
	local had_prop_num = ItemData.Instance:GetItemNumInBagById(item_data.item_id)

	return had_prop_num >= item_data.num and 1 or 0
end

function WingData:GetEquipLevelLimit()
	for k, v in ipairs(self.wing_cfg.grade) do
		if v.equip_level_toplimit ~= 0 then
			return k - 1
		end
	end
	return 0
end

function WingData:CalTalentRemind()
	if nil == self.wing_info or nil == next(self.wing_info) then
		return 0
	end
	if ImageFuLingData.Instance:GetAdvanceTalentRemind(TALENT_TYPE.TALENT_WING) > 0 and self.wing_info.grade > TALENTLEVEL then
		return 1
	end
	return 0
end

function WingData:IsOpenEquip()
	if nil == self.wing_info or nil == next(self.wing_info) then
		return false, 0
	end

	local otehr_cfg = self:GetOhterCfg()
	if self.wing_info.grade > otehr_cfg.active_equip_grade then
		return true, 0
	end

	return false, otehr_cfg.active_equip_grade
end

function WingData:IsActiveEquipSkill()
	if nil == self.wing_info or nil == next(self.wing_info) then
		return false
	end
	return self.wing_info.equip_skill_level > 0
end

function WingData:GetClearBlessGrade()
	return self.clear_bless_grade, self.clear_bless_grade_name
end

-- 获得特殊属性更高的
function WingData:GetGradeAndSpecialAttr()
	local cfg = self:GetWingGradeCfg(self.wing_info.grade)
	for k, v in ipairs (self.wing_cfg.grade) do
		if v.shanbi > cfg.shanbi then
			return v.grade, v.shanbi - cfg.shanbi
		end
	end
end

function WingData:CanShowRed()
	local wing_info = WingData.Instance:GetWingInfo()
	local grade_cfg = WingData.Instance:GetWingGradeCfg(wing_info.grade)
	if nil == grade_cfg then
		return false
	end

	if wing_info.grade >= self:GetMaxGrade() then
		return false
	end

	if KaifuActivityData.Instance:IsOpenAdvanceReturnActivity() then
		local open_advance_one = KaifuActivityData.Instance:GetOpenAdvanceType(TYPE_UPGRADE_RETURN.WING_UPGRADE_RETURN)
		local open_advance_two = KaifuActivityData.Instance:GetOpenAdvanceTypeTwo(TYPE_UPGRADE_RETURN.WING_UPGRADE_RETURN)
		local bag_num = ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff_id) + ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff2_id)
		if (open_advance_one == 1 or open_advance_two == 1) and bag_num >= grade_cfg.upgrade_stuff_count then
			return true
		end
	end
	
	return false
end

function WingData:GetShuXinLevel()
	for k, v in ipairs(self.wing_cfg.grade) do
		if v.shanbi ~= 0 then
			return v.grade 
		end
	end 
	return 0
end

-- 当前阶数
function WingData:GetGrade()
	return self.wing_info.grade or 0
end

--当前使用形象
function WingData:GetUsedImageId()
	return self.wing_info.used_imageid
end

-- 全属性加成所需阶数
function WingData:GetActiveNeedGrade()
	local other_cfg = self:GetOhterCfg()
	return other_cfg.extra_attrs_per_grade or 1
end

-- 全属性加成百分比
function WingData:GetAllAttrPercent()
  	local other_cfg = self:GetOhterCfg()
  	local attr_percent = math.floor(other_cfg.extra_attrs_per / 100) 	-- 万分比转为百分比
  	return attr_percent or 0
end

--当前等级基础战力 power  额外属性加成 huanhua_add_per
function WingData:GetCurGradeBaseFightPowerAndAddPer()
	local power = 0
	local huanhua_add_per = 0

	local grade = self:GetGrade()
	local cur_grade = grade == 0 and 1 or grade
	local attr_cfg = self:GetWingGradeCfg(cur_grade)
	local attr = CommonDataManager.GetAttributteByClass(attr_cfg)
	power = CommonDataManager.GetCapabilityCalculation(attr)

	local active_add_per_need_level = self:GetActiveNeedGrade()
	if grade >= active_add_per_need_level then
		huanhua_add_per = self:GetAllAttrPercent()
	end
	return power, huanhua_add_per
end

--当前等级基础战力 power  额外勋章属性加成 base_attr_add_per
function WingData:GetCurGradeBaseFightPower()
	local power = 0
	local grade = self:GetGrade()
	local cur_grade = grade == 0 and 1 or grade
	local attr_cfg = self:GetWingGradeCfg(cur_grade)
	local attr = CommonDataManager.GetAttributteByClass(attr_cfg)
	power = CommonDataManager.GetCapabilityCalculation(attr)
	return power
end

--得到幻化形象当前等级
function WingData:GetSingleSpecialImageGrade(image_id)
	local grade = 0
	if nil == self.wing_info or nil == self.wing_info.special_img_grade_list or nil == self.wing_info.special_img_grade_list[image_id] then
		return grade
	end

	grade = self.wing_info.special_img_grade_list[image_id]
	return grade
end

--当前进阶等级对应的image_id
function WingData:GetCurGradeImageId()
	local image_id = 0
	local cfg = self:GetWingGradeCfg(self.wing_info.grade)
	if cfg then
		image_id = cfg.image_id or 0
	end

	return image_id
end

------------------------------------------------幻化超级战力-------------------------------------------------
--获取配置判断超级战力是否开启 0/1 不开启/开启
function WingData:SuperPowerIsOpenByCfg()
	local other_cfg = self:GetOhterCfg()
	local open_flag = other_cfg and other_cfg.is_open_special_cap_add
	local is_open = false
	if open_flag then
		is_open = open_flag == 1
	end

	return is_open
end

--特殊星星是否显示
function WingData:GetStarIsShowSuperPower(huanhua_id)
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
function WingData:IsShowSuperPower(huanhua_id)
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
function WingData:GetSingleHuanHuaSpecialCapAddList(huanhua_id)
	local list = {}
	if nil == huanhua_id or nil == self.huanhua_special_cap_add or nil == self.huanhua_special_cap_add[huanhua_id] then
		return list
	end

	list = self.huanhua_special_cap_add[huanhua_id]
	return list
end

--获取激活超级形象的要求等级
function WingData:GetActiveSuperPowerNeedLevel(huanhua_id)
	local level = 0
	local list = self:GetSingleHuanHuaSpecialCapAddList(huanhua_id)
	if list and list.huanhua_level then
		level = list.huanhua_level
	end

	return level
end

--特殊战力面板显示数据
function WingData:GetSpecialHuanHuaShowData(huanhua_id)
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

function WingData:IsHidden()
	local flag = SettingData.Instance:GetAdvanceTypeHideFlag(ADVANCE_HIDE_TYPE.WING)		--0为不隐藏，1为隐藏
	return flag == 1
end

function WingData:IsHaveZhiShengDanInGrade()
	if self.wing_info and next(self.wing_info) then
		local zhishengdan_list = ItemData.Instance:GetItemListByBigType(GameEnum.ITEM_BIGTYPE_EXPENSE)
		for k, v in pairs(zhishengdan_list) do
			local item_cfg, bag_type = ItemData.Instance:GetItemConfig(v.item_id)
			if item_cfg.use_type == 69 and item_cfg.param2 == self.wing_info.grade then
				return true, item_cfg.id
			end
		end
	end
	return false, nil
end

function WingData:GetWingResIdByImageId(image_id)
	image_id = image_id or 0
	local image_cfg = nil
	if image_id > 1000 then
		image_id = image_id - 1000
		image_cfg = ConfigManager.Instance:GetAutoConfig("wing_auto").special_img[image_id]
	else
		image_cfg = ConfigManager.Instance:GetAutoConfig("wing_auto").image_list[image_id]
	end

	if image_cfg then
		return image_cfg.res_id
	end

	return 0
end

function WingData:IsShenCiHuanhuaIdByItemId(item_id)
	local cfg = self:GetSpecialImagesCfg()
	for k, v in pairs(cfg) do
		if v.item_id == item_id and v.is_shenci and v.is_shenci == 1 then
			return true
		end
	end
	return false
end

function WingData:IsShenCiHuanhuaIdAndCanJumpByItemId(item_id)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local zhuanzhi_prof = math.floor(vo.prof / 10)
	local cfg = self:GetSpecialImagesCfg()
	for k, v in pairs(cfg) do
		if v.item_id == item_id and v.is_shenci and v.is_shenci == 1 and zhuanzhi_prof < v.zhuanzhi_prof then
			return true
		end
	end
	return false
end