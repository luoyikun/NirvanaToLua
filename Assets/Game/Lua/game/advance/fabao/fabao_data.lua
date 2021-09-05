FaBaoData = FaBaoData or BaseClass()

FaBaoDanId = {
		ChengZhangDanId = 22102,
		ZiZhiDanId = 22102,
}

FaBaoShuXingDanCfgType = {
		Type = 7
}

FaBaoDataEquipId = {
	16200, 16210, 16220, 16230
}
local TALENTLEVEL = 8
function FaBaoData:__init()
	if FaBaoData.Instance then
		print_error("[ItemData] Attemp to create a singleton twice !")
	end
	FaBaoData.Instance = self

	self.fabao_info = {}
	self.fabao_cfg = ConfigManager.Instance:GetAutoConfig("fabao_auto")
	self.equip_info_cfg = ListToMap(self.fabao_cfg.fabao_equip_info, "equip_idx", "equip_level")
	self.huanhua_special_cap_add = ListToMap(self.fabao_cfg.huanhua_special_cap_add, "huanhua_id")
	self.clear_bless_grade = 100
	self.clear_bless_grade_name = ""
	for i,v in ipairs(self.fabao_cfg.grade) do
		if v.is_clear_bless == 1 then
			self.clear_bless_grade = v.grade
			self.clear_bless_grade_name = v.gradename
			break
		end
	end
end

function FaBaoData:__delete()
	if FaBaoData.Instance then
		FaBaoData.Instance = nil
	end
	self.fabao_info = {}
end

function FaBaoData:SetFaBaoInfo(protocol)
	if self.fabao_info.grade_bless_val then
		local diff = protocol.grade_bless_val - self.fabao_info.grade_bless_val
		local bless_cfg =  AdvanceData.Instance:GetBlessBaojiCfg(UPGRADE_BAOJI_TYPE.UPGRADE_TYPE_FABAO)
		local baoji_bless = bless_cfg.upgrade_exp * bless_cfg.crit_value
		if diff > 0 and diff == baoji_bless then
			TipsCtrl.Instance:OpenBaojiViewTips("advance_view")
		end
	end

	self.fabao_info.grade = protocol.grade
	self.fabao_info.used_imageid = protocol.used_imageid
	self.fabao_info.used_special_id = protocol.used_special_id
	self.fabao_info.active_image_flag = bit:uc2b(protocol.active_image_flag)
	self.fabao_info.grade_bless_val = protocol.grade_bless_val
	local special_img_grade_list = {}
	for i = 0, GameEnum.MAX_MOUNT_SPECIAL_IMAGE_ID_TWO - 1 do
		special_img_grade_list[i] = protocol.special_img_grade_list[i + 1]
	end
	self.fabao_info.special_img_grade_list = special_img_grade_list
	self.fabao_info.shuxingdan_count = protocol.shuxingdan_count 				-- 使用的属性丹数量
	self.fabao_info.clear_bless_time = protocol.clear_bless_time				-- 进阶祝福值清零时间
	self.fabao_info.last_upgrade_succ_time = protocol.last_upgrade_succ_time	-- 上一次进阶成功的时间
	self.fabao_info.skill_level_list = protocol.skill_level_list 				-- 上一次进阶成功的时间
	self.fabao_info.equip_skill_level = protocol.equip_skill_level				-- 装备技能等级
	self.fabao_info.is_used_special_img = protocol.is_used_special_img			-- 是否使用幻化形象

	local equip_level_list = {}
	for i = 0, GameEnum.MOUNT_EQUIP_COUNT - 1 do
		equip_level_list[i] = protocol.equip_level_list[i + 1]
	end
	self.fabao_info.equip_level_list = equip_level_list
	self.fabao_info.active_special_image_flag =  bit:uc2b(protocol.active_special_image_flag)
end

function FaBaoData:GetSpecialImageIsActive(img_id)
	local act_flag = self.fabao_info.active_special_image_flag
	if act_flag then
		return act_flag[img_id] and 1 == act_flag[img_id] or false
	end
	return false
end

function FaBaoData:GetLevelAttribute()
	local level_cfg = self:GetFaBaoStarLevelCfg(self.fabao_info.star_level)
	return CommonDataManager.GetAttributteByClass(level_cfg)
end

function FaBaoData:GetFaBaoInfo()
	return self.fabao_info
end

function FaBaoData:GetFaBaoLevelCfg(fabao_level)
	if fabao_level >= self:GetMaxFaBaoGradeCfg() then
		fabao_level = self:GetMaxFaBaoGradeCfg()
	end
	return self.fabao_cfg.level[fabao_level]
end

function FaBaoData:GetMaxFaBaoGradeCfg()
	return #self.fabao_cfg.grade
end

function FaBaoData:GetFaBaoGradeCfg(fabao_grade)
	local fabao_grade = fabao_grade or self.fabao_info.grade or 0
	if fabao_grade > self:GetMaxGrade() then
		fabao_grade = self:GetMaxGrade()
	end
	return self.fabao_cfg.grade[fabao_grade]
end

function FaBaoData:GetSpecialImagesCfg()
	return self.fabao_cfg.special_img
end

-- 获取可显示的幻化列表
function FaBaoData:GetHuanHuaCfgList()
	local huanhua_list = {}
	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	for _, v in ipairs(self.fabao_cfg.special_img) do
		if main_vo.level >= v.lvl and open_server_day >= v.open_day then
			table.insert(huanhua_list, v)
		end
	end
	return huanhua_list
end

function FaBaoData:CanHuanhuaIndexByImageId(image_id)
	local list = self:GetHuanHuaCfgList()
	local num = 0
	for k, v in ipairs(list) do
		num = num + 1
		if v.item_id == image_id then
			return v.image_id, num
		end
	end
end

function FaBaoData:IsCanHuanhuaDayAndLevel(index)
	local huanhua_list = self:GetHuanHuaCfgList()
	for k, v in pairs(huanhua_list) do
		if v.image_id == index then
			return true
		end
	end
	return false
end

function FaBaoData:GetSpecialImageCfg(image_id)
	if self.fabao_cfg == nil then
		return
	end
	local fabao_config = self.fabao_cfg.special_img
	return fabao_config[image_id]
end

function FaBaoData:GetResIdByImageId(image_id)
	local image_info = nil
	if image_id > 1000 then
		--特殊形象由1000开始
		image_id = image_id - 1000
		image_info = self:GetSpecialImageCfg(image_id)
	else
		image_info = self:GetSingleFaBaoImageCfg(image_id)
	end

	if image_info then
		return image_info.res_id
	end

	return 0
end

function FaBaoData:GetMaxGrade()

	return #self.fabao_cfg.grade
end

function FaBaoData:GetGradeCfg()
	return self.fabao_cfg.grade
end

function FaBaoData:GetMaxSpecialImage()
	return #self.fabao_cfg.special_img
end

function FaBaoData:GetSpecialImageUpgradeCfg()
	return self.fabao_cfg.special_image_upgrade
end

function FaBaoData:GetFaBaoSkillCfg()
	return self.fabao_cfg.fabao_skill
end

function FaBaoData:GetFaBaoImageCfg()
	return self.fabao_cfg.image_list
end

function FaBaoData:GetSingleFaBaoImageCfg(image_id)
	return self.fabao_cfg.image_list[image_id]
end

function FaBaoData:GetBigTargetImageId()
	return JinJieRewardData.Instance:GetSingleRewardCfgParam0(JINJIE_TYPE.JINJIE_TYPE_FABAO)
end

function FaBaoData:GetFaBaoEquipCfg()
	return self.fabao_cfg.fabao_equip
end

function FaBaoData:GetFaBaoEquipExpCfg()
	return self.fabao_cfg.equip_exp
end

function FaBaoData:GetFaBaoEquipRandAttr()
	return self.fabao_cfg.equip_attr_range
end

function FaBaoData:GetFaBaoUpgradeStuffCfg(index)
	if nil == index then
		index = 1
	end
	return self.fabao_cfg.grade[index].upgrade_stuff_id
end

function FaBaoData:GetFaBaoUpStarExpCfg()
	return self.fabao_cfg.up_star_exp
end

function FaBaoData:GetOhterCfg()
	return self.fabao_cfg.other[1]
end

-- 获取当前点击法宝特殊形象的配置
function FaBaoData:GetSpecialImageUpgradeInfo(index, grade, is_next)
	if (index == 0) or nil then
		return
	end

	local grade = grade or self.fabao_info.special_img_grade_list[index] or 0
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
function FaBaoData:GetSpecialImageMaxUpLevelById(image_id)
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
function FaBaoData:GetImageListInfo(index)
	if (index == 0) or nil then
		return
	end
	for k, v in pairs(self:GetFaBaoImageCfg()) do
		if v.image_id == index then
			return v
		end
	end

	return nil
end

function FaBaoData:GetImageIdByRes(res_id)
	for k,v in pairs(self:GetFaBaoImageCfg()) do
		if v.res_id == res_id then
			return v.image_id
		end
	end
	return 0
end

-- 获取当前点击法宝技能的配置
function FaBaoData:GetFaBaoSkillCfgById(skill_idx, level, fabao_info)
	if self.fabao_info.skill_level_list == nil then
		 return
	end

	local fabao_info = fabao_info or self.fabao_info
	local level = level or fabao_info.skill_level_list[skill_idx + 1]

	for k, v in pairs(self:GetFaBaoSkillCfg()) do
		if v.skill_idx == skill_idx and v.skill_level == level then
			return v
		end
	end

	return nil
end

-- 获得特殊属性更高的 
function FaBaoData:GetGradeAndSpecialAttr()
	local cfg = self:GetFaBaoGradeCfg(self.fabao_info.grade)
	for k, v in ipairs (self.fabao_cfg.grade) do
		if v.jianshang_per > cfg.jianshang_per then
			return v.grade, v.jianshang_per - cfg.jianshang_per
		end
	end
end


-- 获取特殊形象总增加的属性
function FaBaoData:GetSpecialImageAttrSum(fabao_info)
	local fabao_info = fabao_info or self.fabao_info
	local sum_attr_list = CommonStruct.Attribute()
	local active_flag = fabao_info.active_special_image_flag
	if active_flag == nil then
		sum_attr_list.chengzhangdan_count = 0
		sum_attr_list.shuxingdan_count = 0
		sum_attr_list.equip_limit = 0
		return sum_attr_list
	end
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
	if self:GetFaBaoGradeCfg(fabao_info.grade) then
		sum_attr_list.chengzhangdan_count = special_chengzhangdan_count + self:GetFaBaoGradeCfg(fabao_info.grade).chengzhangdan_limit
		sum_attr_list.shuxingdan_count = special_shuxingdan_count + self:GetFaBaoGradeCfg(fabao_info.grade).shuxingdan_limit
		sum_attr_list.equip_limit = special_equip_limit + self:GetFaBaoGradeCfg(fabao_info.grade).equip_level_limit
	end

	return sum_attr_list
end

-- 获得已学习的技能总战力
function FaBaoData:GetFaBaoSkillAttrSum(fabao_info)
	local attr_list = CommonStruct.Attribute()
	for i = 0, 3 do
		local skill_cfg = self:GetFaBaoSkillCfgById(i, nil, fabao_info)
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
function FaBaoData:GetFaBaoEquipAttrSum(fabao_info)
	local fabao_info = fabao_info or self.fabao_info
	local attr_list = CommonStruct.Attribute()
	if nil == fabao_info.equip_level_list then return attr_list end
	for k, v in pairs(fabao_info.equip_level_list) do
		attr_list = CommonDataManager.AddAttributeAttr(attr_list, CommonDataManager.GetAttributteByClass(self:GetEquipInfoCfg(k, v)))
	end
	return attr_list
end

-- 获取已吃成长丹，资质丹属性
function FaBaoData:GetDanAttr(fabao_info)
	local fabao_info = fabao_info or self.fabao_info
	--如果法宝等级
	if fabao_info.fabao_level >= self:GetMaxFaBaoGradeCfg() then
		fabao_info.fabao_level = self:GetMaxFaBaoGradeCfg()
	end

	local attr_list = CommonStruct.Attribute()
	local fabao_grade_cfg = self:GetFaBaoGradeCfg(fabao_info.grade)
	if not fabao_grade_cfg then print_error("法宝配置表为空", fabao_info.grade) return attr_list end

	local fabao_shuxingdan_cfg = AdvanceData.Instance:GetShuXingDanCfg(FaBaoShuXingDanCfgType.Type)
	if fabao_shuxingdan_cfg and next(fabao_shuxingdan_cfg) then
		attr_list.gong_ji = attr_list.gong_ji + fabao_shuxingdan_cfg.gongji * fabao_info.shuxingdan_count
		attr_list.fang_yu = attr_list.fang_yu + fabao_shuxingdan_cfg.fangyu * fabao_info.shuxingdan_count
		attr_list.max_hp = attr_list.max_hp + fabao_shuxingdan_cfg.maxhp * fabao_info.shuxingdan_count
	end

	return attr_list
end

function FaBaoData:GetFaBaoAttrSum(fabao_info, next_level)
	local fabao_info = fabao_info or self:GetFaBaoInfo()
	local attr = CommonStruct.Attribute()

	if nil == fabao_info.grade or fabao_info.grade <= 0  then
		return attr
	end

	local fabao_grade_cfg = {}
	if next_level then
		fabao_grade_cfg = self:GetFaBaoGradeCfg(fabao_info.grade + 1)
	else
		fabao_grade_cfg = self:GetFaBaoGradeCfg(fabao_info.grade)
	end
	
	if not next(fabao_grade_cfg) then return attr end
	attr.max_hp = fabao_grade_cfg.maxhp or 0
	attr.gong_ji = fabao_grade_cfg.gongji or 0
	attr.fang_yu = fabao_grade_cfg.fangyu or 0
	attr.ming_zhong = fabao_grade_cfg.mingzhong or 0
	attr.shan_bi = fabao_grade_cfg.shanbi or 0
	attr.bao_ji = fabao_grade_cfg.baoji or 0
	attr.jian_ren = fabao_grade_cfg.jianren or 0
	attr.extra_zengshang = fabao_grade_cfg.extra_zengshang or 0						--额外伤害值
	attr.extra_mianshang = fabao_grade_cfg.extra_mianshang or 0					--额外减伤值
	attr.per_jingzhun = fabao_grade_cfg.per_jingzhun or 0							-- 破甲
	attr.per_baoji = fabao_grade_cfg.per_baoji or 0								-- 暴伤
	attr.per_zengshang = fabao_grade_cfg.per_zengshang or 0							--伤害加成万分比
	attr.per_jianshang = fabao_grade_cfg.per_jianshang or 0							--伤害减免万分比
	attr.pvp_jianshang = fabao_grade_cfg.pvp_jianshang or 0							-- pvp减伤
	attr.pvp_zengshang = fabao_grade_cfg.pvp_zengshang or 0							-- pvp增伤
	attr.pve_jianshang = fabao_grade_cfg.pve_jianshang or 0							-- pve减伤
	attr.pve_zengshang = fabao_grade_cfg.pve_zengshang or 0							-- pve增伤
	return attr
end

function FaBaoData:GetSpecialAttrActiveType(cur_grade)
	local cur_grade = cur_grade or self.fabao_info.grade or 0
	return AdvanceData.Instance:GetSpecialAttrActiveType(self.fabao_cfg.grade, cur_grade)
end

function FaBaoData:GetHuanHuaSpecialAttrActiveType(grade, index)
	local grade = grade or self.fabao_info.special_img_grade_list[index] or 0
	return AdvanceData.Instance:GetSpecialAttrActiveType(self.fabao_cfg.special_image_upgrade, grade, index)
end

function FaBaoData:GetFaBaoUpgradeStuffCountCfg()
	return self.fabao_cfg.grade[self.fabao_info.grade].upgrade_stuff_count
end

function FaBaoData:GetFaBaoStarLevelCfg(star_level)
	local star_level = star_level or self.fabao_info.star_level
	for k, v in pairs(self:GetFaBaoUpStarExpCfg()) do
		if v.star_level == star_level then
			return v
		end
	end

	return nil
end

function FaBaoData:IsShowZizhiRedPoint()
	local fabao_shuxingdan_cfg = AdvanceData.Instance:GetShuXingDanCfg(FaBaoShuXingDanCfgType.Type)
	if not fabao_shuxingdan_cfg or not next(fabao_shuxingdan_cfg) then
		return false
	end
	if next(self.fabao_info) == nil and self.fabao_info.grade == nil then
		return false
	end

	if self.fabao_info.grade < fabao_shuxingdan_cfg.order_limit then
		return false
	end
	
	local count_limit = self:GetSpecialImageAttrSum().shuxingdan_count
	if self.fabao_info.shuxingdan_count == nil or count_limit == nil then
		return false
	end
	if self.fabao_info.shuxingdan_count >= count_limit then
		return false
	end

	if ItemData.Instance:GetItemNumInBagById(FaBaoDanId.ZiZhiDanId) > 0 then
		return true
	end

	return false
end

function FaBaoData:IsShowChengzhangRedPoint()
	local count_limit = self:GetSpecialImageAttrSum().chengzhangdan_count
	if self.fabao_info.chengzhangdan_count == nil or count_limit == nil then
		return false
	end
	if self.fabao_info.chengzhangdan_count >= count_limit then
		return false
	end
	for k, v in pairs(ItemData.Instance:GetBagItemDataList()) do
		if v.item_id == FaBaoDanId.ChengZhangDanId then
			return true
		end
	end
	return false
end

function FaBaoData:CanHuanhuaUpgradeList()
	local list = {}
	if self.fabao_info.grade == nil or self.fabao_info.grade <= 0 then
		return list
	end

	local special_img_grade_list = self.fabao_info.special_img_grade_list
	if special_img_grade_list == nil then
		return list
	end
	
	local image_id = self:GetBigTargetImageId()
	for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
		if ItemData.Instance:GetItemNumInBagById(v.stuff_id) >= v.stuff_num 
			and special_img_grade_list[v.special_img_id] == v.grade 
			and v.grade < self:GetSpecialImageMaxUpLevelById(v.special_img_id)
			and v.special_img_id ~= image_id then 								--大目标去除
			if self:IsCanHuanhuaDayAndLevel(v.special_img_id) then
				list[v.special_img_id] = v.special_img_id
			end
		end
	end
	return list
end

function FaBaoData:CanHuanhuaUpgrade()
	local list = self:CanHuanhuaUpgradeList()
	return next(list) ~= nil
end

function FaBaoData:CanSkillUpLevelList()
	local list = {}
	if self.fabao_info.grade == nil or self.fabao_info.grade <= 0 then return list end
	if self.fabao_info.skill_level_list == nil then
		return list
	end
	for k, v in pairs(self:GetFaBaoSkillCfg()) do
		if ItemData.Instance:GetItemNumInBagById(v.uplevel_stuff_id) >= v.uplevel_stuff_num
			and self.fabao_info.skill_level_list[v.skill_idx + 1] == (v.skill_level - 1)
			and v.grade <= self.fabao_info.grade and v.skill_type ~= 0 then
			list[v.skill_idx] = v.skill_idx
		end
	end
	
	return list
end
--判断是否能够进阶
function FaBaoData:CanJinjie()
	if self.fabao_info.grade == nil or self.fabao_info.grade <= 0 then return false end

	local upgrade_stuff_id = FaBaoData.Instance:GetFaBaoUpgradeStuffCfg(self.fabao_info.grade)
	local upgrade_stuff_limit = self:GetFaBaoUpgradeStuffCountCfg()
	--在背包里根据ID检查升级的物品是否足够
	local item_num = ItemData.Instance:GetItemNumInBagById(upgrade_stuff_id)

	if upgrade_stuff_id then
		if 0 < ItemData.Instance:GetItemNumInBagById(upgrade_stuff_id)
			and self.fabao_info.grade < self:GetMaxGrade()
			and item_num >=  upgrade_stuff_limit then
			return true
		end
	end
	return false
end

function FaBaoData:GetChengzhangDanLimit()
	for i = 1, self:GetMaxGrade() do
		if self:GetGradeCfg()[i] and self:GetGradeCfg()[i].chengzhangdan_limit > 0 then
			return self:GetGradeCfg()[i]
		end
	end
	return nil
end

function FaBaoData:GetFaBaoGradeByUseImageId(used_imageid)
	if not used_imageid then return 0 end
	local image_list = self:GetFaBaoImageCfg()
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

function FaBaoData:IsActiviteFaBao()
	local active_flag = self.fabao_info and self.fabao_info.active_image_flag or {}
	for k, v in pairs(active_flag) do
		if v == 1 then
			return true
		end
	end
	return false
end

function FaBaoData:GetEquipInfoCfg(equip_index, level)
	if nil == self.equip_info_cfg[equip_index] then
		return
	end
	return self.equip_info_cfg[equip_index][level]
end

function FaBaoData:CalAllEquipRemind()
	if not self:IsOpenEquip() then return 0 end

	for k, v in pairs(self.fabao_info.equip_level_list) do
		if self:CalEquipRemind(k) > 0 then
			return 1
		end
	end
	return 0
end

function FaBaoData:CalEquipRemind(equip_index)
	if nil == self.fabao_info or nil == next(self.fabao_info) then
		return 0
	end

	local equip_level = self.fabao_info.equip_level_list[equip_index] or 0
	local equip_cfg = self:GetEquipInfoCfg(equip_index, equip_level + 1)
	if nil == equip_cfg then return 0 end

	local grade_info_cfg = self:GetFaBaoGradeCfg(self.fabao_info.grade)
	local equip_level_toplimit = grade_info_cfg.equip_level_toplimit
	if self.fabao_info.grade < self:GetEquipLevelLimit() or equip_level >= equip_level_toplimit then
		return 0
	end

	local item_data = equip_cfg.item
	local had_prop_num = ItemData.Instance:GetItemNumInBagById(item_data.item_id)

	return had_prop_num >= item_data.num and 1 or 0
end

function FaBaoData:GetEquipLevelLimit()
	for k, v in ipairs(self.fabao_cfg.grade) do
		if v.equip_level_toplimit ~= 0 then
			return k - 1
		end
	end
	return 0
end

function FaBaoData:IsOpenEquip()
	if nil == self.fabao_info or nil == next(self.fabao_info) then
		return false, 0
	end

	local other_cfg = self:GetOhterCfg()
	if self.fabao_info.grade > other_cfg.active_equip_grade then
		return true, 0
	end

	return false, other_cfg.active_equip_grade
end

function FaBaoData:CalTalentRemind()
	if nil == self.fabao_info or nil == next(self.fabao_info) then
		return 0
	end
	if ImageFuLingData.Instance:GetAdvanceTalentRemind(TALENT_TYPE.TALENT_FABAO) > 0 and self.fabao_info.grade > TALENTLEVEL then
		return 1
	end
	return 0
end

function FaBaoData:IsActiveEquipSkill()
	if nil == self.fabao_info or nil == next(self.fabao_info) then
		return false
	end
	return self.fabao_info.equip_skill_level > 0
end


function FaBaoData:GetClearBlessGrade()
	return self.clear_bless_grade, self.clear_bless_grade_name
end

function FaBaoData:CanShowRed()
	local fabao_info = FaBaoData.Instance:GetFaBaoInfo()
	local grade_cfg = FaBaoData.Instance:GetFaBaoGradeCfg(fabao_info.grade)
	if nil == grade_cfg then
		return false
	end

	if fabao_info.grade >= self:GetMaxGrade() then
		return false
	end

	if KaifuActivityData.Instance:IsOpenAdvanceReturnActivity() then
		local open_advance_one = KaifuActivityData.Instance:GetOpenAdvanceType(TYPE_UPGRADE_RETURN.FABAO_UPGRADE_RETURN)
		local open_advance_two = KaifuActivityData.Instance:GetOpenAdvanceTypeTwo(TYPE_UPGRADE_RETURN.FABAO_UPGRADE_RETURN)
		local bag_num = ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff_id) + ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff2_id)
		if (open_advance_one == 1 or open_advance_two == 1) and bag_num >= grade_cfg.upgrade_stuff_count then
			return true
		end
	end
	
	return false
end

function FaBaoData:GetShuXinLevel()
	for k, v in ipairs(self.fabao_cfg.grade) do
		if v.jianshang_per ~= 0 then
			return v.grade 
		end
	end 
	return 0
end

-- 当前阶数
function FaBaoData:GetGrade()
	return self.fabao_info.grade or 0
end

--当前使用形象
function FaBaoData:GetUsedImageId()
	return self.fabao_info.used_imageid 
end

-- 全属性加成所需阶数
function FaBaoData:GetActiveNeedGrade()
	local other_cfg = self:GetOhterCfg()
	return other_cfg.extra_attrs_per_grade or 1
end

-- 全属性加成百分比
function FaBaoData:GetAllAttrPercent()
  	local other_cfg = self:GetOhterCfg()
  	local attr_percent = math.floor(other_cfg.extra_attrs_per / 100) 	-- 万分比转为百分比
  	return attr_percent or 0
end

--当前等级基础战力 power  额外属性加成 huanhua_add_per
function FaBaoData:GetCurGradeBaseFightPowerAndAddPer()
	local power = 0
	local huanhua_add_per = 0

	local grade = self:GetGrade()
	local cur_grade = grade == 0 and 1 or grade
	local attr_cfg = self:GetFaBaoGradeCfg(cur_grade)
	local attr = CommonDataManager.GetAttributteByClass(attr_cfg)
	power = CommonDataManager.GetCapabilityCalculation(attr)

	local active_add_per_need_level = self:GetActiveNeedGrade()
	if grade >= active_add_per_need_level then
		huanhua_add_per = self:GetAllAttrPercent()
	end
	return power, huanhua_add_per
end

--当前等级基础战力 power  额外勋章属性加成 base_attr_add_per
function FaBaoData:GetCurGradeBaseFightPower()
	local power = 0
	local grade = self:GetGrade()
	local cur_grade = grade == 0 and 1 or grade
	local attr_cfg = self:GetFaBaoGradeCfg(cur_grade)
	local attr = CommonDataManager.GetAttributteByClass(attr_cfg)
	power = CommonDataManager.GetCapabilityCalculation(attr)
	return power
end

--得到幻化形象当前等级
function FaBaoData:GetSingleSpecialImageGrade(image_id)
	local grade = 0
	if nil == self.fabao_info or nil == self.fabao_info.special_img_grade_list or nil == self.fabao_info.special_img_grade_list[image_id] then
		return grade
	end

	grade = self.fabao_info.special_img_grade_list[image_id]
	return grade
end

--当前进阶等级对应的image_id
function FaBaoData:GetCurGradeImageId()
	local image_id = 0
	local cfg = self:GetFaBaoGradeCfg(self.fabao_info.grade)
	if cfg then
		image_id = cfg.image_id or 0
	end

	return image_id
end

------------------------------------------------幻化超级战力-------------------------------------------------
--获取配置判断超级战力是否开启 0/1 不开启/开启
function FaBaoData:SuperPowerIsOpenByCfg()
	local other_cfg = self:GetOhterCfg()
	local open_flag = other_cfg and other_cfg.is_open_special_cap_add
	local is_open = false
	if open_flag then
		is_open = open_flag == 1
	end

	return is_open
end

--特殊星星是否显示
function FaBaoData:GetStarIsShowSuperPower(huanhua_id)
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
function FaBaoData:IsShowSuperPower(huanhua_id)
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
function FaBaoData:GetSingleHuanHuaSpecialCapAddList(huanhua_id)
	local list = {}
	if nil == huanhua_id or nil == self.huanhua_special_cap_add or nil == self.huanhua_special_cap_add[huanhua_id] then
		return list
	end

	list = self.huanhua_special_cap_add[huanhua_id]
	return list
end

--获取激活超级形象的要求等级
function FaBaoData:GetActiveSuperPowerNeedLevel(huanhua_id)
	local level = 0
	local list = self:GetSingleHuanHuaSpecialCapAddList(huanhua_id)
	if list and list.huanhua_level then
		level = list.huanhua_level
	end

	return level
end

--特殊战力面板显示数据
function FaBaoData:GetSpecialHuanHuaShowData(huanhua_id)
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

function FaBaoData:IsHidden()
	local flag = SettingData.Instance:GetAdvanceTypeHideFlag(ADVANCE_HIDE_TYPE.FOOT)		--0为不隐藏，1为隐藏
	return flag == 1
end

function FaBaoData:IsHaveZhiShengDanInGrade()
	if self.fabao_info and next(self.fabao_info) then
		local zhishengdan_list = ItemData.Instance:GetItemListByBigType(GameEnum.ITEM_BIGTYPE_EXPENSE)
		for k, v in pairs(zhishengdan_list) do
			local item_cfg, bag_type = ItemData.Instance:GetItemConfig(v.item_id)
			if item_cfg.use_type == 94 and item_cfg.param2 == self.fabao_info.grade then
				return true, item_cfg.id
			end
		end
	end
	return false, nil
end