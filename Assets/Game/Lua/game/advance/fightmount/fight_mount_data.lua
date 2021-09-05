FightMountData = FightMountData or BaseClass()

FightMountDanId = {
		ChengZhangDanId = 22113,
		ZiZhiDanId = 22107,
}

FightMountShuXingDanCfgType = {
		Type = 10
}
local TALENTLEVEL = 8
function FightMountData:__init()
	if FightMountData.Instance then
		print_error("[ItemData] Attemp to create a singleton twice !")
	end
	FightMountData.Instance = self

	self.mount_info = {}
	self.mount_cfg = ConfigManager.Instance:GetAutoConfig("fight_mount_auto")
	self.equip_info_cfg = ListToMap(self.mount_cfg.mount_equip_info, "equip_idx", "equip_level")
	self.huanhua_special_cap_add = ListToMap(self.mount_cfg.huanhua_special_cap_add, "huanhua_id")			--幻化特殊战力加成
	self.clear_bless_grade = 100
	self.clear_bless_grade_name = ""
	for i,v in ipairs(self.mount_cfg.grade) do
		if v.is_clear_bless == 1 then
			self.clear_bless_grade = v.grade
			self.clear_bless_grade_name = v.gradename
			break
		end
	end
end

function FightMountData:__delete()
	FightMountData.Instance = nil
end

function FightMountData:SetFightMountInfo(protocol)
	if self.mount_info.grade_bless_val then
		local diff = protocol.grade_bless_val - self.mount_info.grade_bless_val
		local bless_cfg =  AdvanceData.Instance:GetBlessBaojiCfg(UPGRADE_BAOJI_TYPE.UPGRADE_TYPE_FIGHTMOUNT)
		local baoji_bless = bless_cfg.upgrade_exp * bless_cfg.crit_value
		if diff > 0 and diff == baoji_bless then
			TipsCtrl.Instance:OpenBaojiViewTips("advance_view")
		end
	end
	
	self.mount_info.mount_flag = protocol.mount_flag
	self.mount_info.mount_level = protocol.mount_level
	self.mount_info.grade = protocol.grade
	self.mount_info.grade_bless_val = protocol.grade_bless_val
	self.mount_info.clear_upgrade_time = protocol.clear_upgrade_time
	self.mount_info.used_imageid = protocol.used_imageid
	self.mount_info.shuxingdan_count = protocol.shuxingdan_count
	self.mount_info.chengzhangdan_count = protocol.chengzhangdan_count
	self.mount_info.active_image_flag = bit:uc2b(protocol.active_image_flag) 
	self.mount_info.star_level = protocol.star_level
	self.mount_info.equip_skill_level = protocol.equip_skill_level
	self.mount_info.equip_level_list = protocol.equip_level_list
	self.mount_info.skill_level_list = protocol.skill_level_list
	self.mount_info.special_img_grade_list = protocol.special_img_grade_list
	self.mount_info.active_special_image_flag = bit:uc2b(protocol.active_special_image_flag)
end

function FightMountData:GetSpecialImageIsActive(img_id)
	local act_flag = self.mount_info.active_special_image_flag
	if act_flag then
		return act_flag[img_id] and 1 == act_flag[img_id] or false
	end
	return false
end

function FightMountData:GetLevelAttribute()
	local level_cfg = self:GetMountStarLevelCfg(self.mount_info.star_level)
	return CommonDataManager.GetAttributteByClass(level_cfg)
end

function FightMountData:GetFightMountInfo()
	return self.mount_info
end

function FightMountData:GetMountLevelCfg(mount_level)
	if mount_level >= self:GetMaxMountLevelCfg() then
		mount_level = self:GetMaxMountLevelCfg()
	end
	return self.mount_cfg.level[mount_level]
end

function FightMountData:GetMaxMountLevelCfg()
	return #self.mount_cfg.level
end

function FightMountData:GetMountGradeCfg(mount_grade)
	local mount_grade = mount_grade or self.mount_info.grade or 0
	if mount_grade > self:GetMaxGrade() then
		mount_grade = self:GetMaxGrade()
	end
	return self.mount_cfg.grade[mount_grade]
end

function FightMountData:GetSpecialImagesCfg()
	return self.mount_cfg.special_img
end

-- 获取可显示的幻化列表
function FightMountData:GetHuanHuaCfgList()
	local huanhua_list = {}
	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	for _, v in ipairs(self.mount_cfg.special_img) do
		if main_vo.level >= v.lvl and open_server_day >= v.open_day and (v.is_shenci == nil or v.is_shenci == 0) then
			table.insert(huanhua_list, v)
		end
	end
	return huanhua_list
end

function FightMountData:GetShenCiHuanHuaCfgList()
	local huanhua_list = {}
	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	for _, v in ipairs(self.mount_cfg.special_img) do
		if main_vo.level >= v.lvl and open_server_day >= v.open_day and v.is_shenci and v.is_shenci == 1 then
			table.insert(huanhua_list, v)
		end
	end
	return huanhua_list
end

function FightMountData:CanHuanhuaIndexByImageId(image_id)
	local list = self:GetHuanHuaCfgList()
	local num = 0
	for k, v in ipairs(list) do
		num = num + 1
		if v.item_id == image_id then
			return v.image_id, num
		end
	end
end

function FightMountData:CanShenCiHuanhuaIndexByImageId(image_id)
	local list = self:GetShenCiHuanHuaCfgList()
	local num = 0
	for k, v in ipairs(list) do
		num = num + 1
		if v.item_id == image_id then
			return v.image_id, num
		end
	end
end

function FightMountData:IsCanHuanhuaDayAndLevel(index)
	local huanhua_list = self:GetHuanHuaCfgList()
	for k, v in pairs(huanhua_list) do
		if v.image_id == index then
			return true
		end
	end
	return false
end

function FightMountData:IsCanShenCiHuanhuaDayAndLevel(index)
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

function FightMountData:GetSpecialImageCfg(image_id)
	return self.mount_cfg.special_img[image_id]
end

function FightMountData:GetMaxGrade()
	return #self.mount_cfg.grade
end

function FightMountData:GetMaxSpecialImage()
	return #self.mount_cfg.special_img
end

function FightMountData:GetSpecialImageUpgradeCfg()
	return self.mount_cfg.special_image_upgrade
end

function FightMountData:GetMountSkillCfg()
	return self.mount_cfg.mount_skill
end

function FightMountData:GetGradeCfg()
	return self.mount_cfg.grade
end

function FightMountData:GetMountImageCfg()
	return self.mount_cfg.image_list
end

function FightMountData:GetMountUpStarStuffCfg()
	return self.mount_cfg.up_star_stuff[1]
end

function FightMountData:GetMountUpStarExpCfg()
	return self.mount_cfg.up_star_exp
end

function FightMountData:GetOhterCfg()
	return self.mount_cfg.other[1]
end

-- 获取形象列表的配置
function FightMountData:GetImageListInfo(index)
	if (index == 0) or nil then
		return
	end
	for k, v in pairs(self:GetMountImageCfg()) do
		if v.image_id == index then
			return v
		end
	end

	return nil
end

-- 获取当前点击坐骑特殊形象的配置
function FightMountData:GetSpecialImageUpgradeInfo(index, grade, is_next)
	if (index == 0) or nil then
		return
	end

	local grade = grade or self.mount_info.special_img_grade_list[index]
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
function FightMountData:GetSpecialImageMaxUpLevelById(image_id)
	if not image_id then return 0 end
	local max_level = 0

	for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
		if v.special_img_id == image_id and v.grade > 0 then
			max_level = max_level + 1
		end
	end
	return max_level
end

-- 获取已吃成长丹，资质丹属性
function FightMountData:GetDanAttr(mount_info)
	local mount_info = mount_info or self.mount_info
	if mount_info.mount_level >= self:GetMaxMountLevelCfg() then
		mount_info.mount_level = self:GetMaxMountLevelCfg()
	end

	local attr_list = CommonStruct.Attribute()
	local mount_level_cfg = self:GetMountLevelCfg(mount_info.mount_level)
	local mount_grade_cfg = self:GetMountGradeCfg(mount_info.grade)
	if not mount_grade_cfg then return attr_list end

	local fightmount_shuxingdan_cfg = AdvanceData.Instance:GetShuXingDanCfg(FightMountShuXingDanCfgType.Type)
	if fightmount_shuxingdan_cfg and next(fightmount_shuxingdan_cfg) then
		attr_list.gong_ji = attr_list.gong_ji + fightmount_shuxingdan_cfg.gongji * mount_info.shuxingdan_count
		attr_list.fang_yu = attr_list.fang_yu + fightmount_shuxingdan_cfg.fangyu * mount_info.shuxingdan_count
		attr_list.max_hp = attr_list.max_hp + fightmount_shuxingdan_cfg.maxhp * mount_info.shuxingdan_count
			-- break
		-- end
	end

	return attr_list
end

-- 获取特殊形象总增加的属性丹和成长丹数量
function FightMountData:GetSpecialImageAttrSum(mount_info)
	local mount_info = mount_info or self.mount_info
	local active_flag = mount_info.active_special_image_flag
	local sum_attr_list = CommonStruct.Attribute()
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
	if self:GetMountGradeCfg(mount_info.grade) then
		sum_attr_list.chengzhangdan_count = special_chengzhangdan_count + self:GetMountGradeCfg(mount_info.grade).chengzhangdan_limit
		sum_attr_list.shuxingdan_count = special_shuxingdan_count + self:GetMountGradeCfg(mount_info.grade).shuxingdan_limit
		sum_attr_list.equip_limit = special_equip_limit + self:GetMountGradeCfg(mount_info.grade).equip_level_limit
	end

	return sum_attr_list
end

-- 获得已升级装备属性
function FightMountData:GetMountEquipAttrSum(mount_info)
	local mount_info = mount_info or self.mount_info
	local attr_list = CommonStruct.Attribute()
	if nil == mount_info.equip_level_list then return attr_list end
	for k, v in pairs(mount_info.equip_level_list) do
		attr_list = CommonDataManager.AddAttributeAttr(attr_list, CommonDataManager.GetAttributteByClass(self:GetEquipInfoCfg(k, v)))
	end
	return attr_list
end

-- 获得特殊属性更高的
function FightMountData:GetGradeAndSpecialAttr()
	local cfg = self:GetMountGradeCfg(self.mount_info.grade)
	for k, v in ipairs (self.mount_cfg.grade) do
		if v.zengshang_per > cfg.zengshang_per then
			return v.grade, v.zengshang_per - cfg.zengshang_per
		end
	end
end

-- 获取已吃成长丹，资质丹属性
function FightMountData:GetDanAttr(mount_info)
	local mount_info = mount_info or self.mount_info
	if mount_info.mount_level >= self:GetMaxMountLevelCfg() then
		mount_info.mount_level = self:GetMaxMountLevelCfg()
	end

	local attr_list = CommonStruct.Attribute()
	local mount_level_cfg = self:GetMountLevelCfg(mount_info.mount_level)
	local mount_grade_cfg = self:GetMountGradeCfg(mount_info.grade)
	if not mount_grade_cfg then return attr_list end

	local shuxingdan_cfg = ConfigManager.Instance:GetAutoConfig("shuxingdan_cfg_auto").reward
	for k, v in pairs(shuxingdan_cfg) do
		if v.type == FightMountShuXingDanCfgType.Type then
			attr_list.gong_ji = attr_list.gong_ji + v.gongji * mount_info.shuxingdan_count
			attr_list.fang_yu = attr_list.fang_yu + v.fangyu * mount_info.shuxingdan_count
			attr_list.max_hp = attr_list.max_hp + v.maxhp * mount_info.shuxingdan_count
			break
		end
	end

	return attr_list
end


function FightMountData:GetMountAttrSum(mount_info, next_level)
	local mount_info = mount_info or self.mount_info

	local attr = CommonStruct.Attribute()
	if not mount_info or not mount_info.grade or mount_info.grade <= 0 or mount_info.mount_level == 0 then
		return attr
	end
	local mount_grade_cfg = {}
	if next_level then
		mount_grade_cfg = self:GetMountGradeCfg(mount_info.grade + 1)
	else
		mount_grade_cfg = self:GetMountGradeCfg(mount_info.grade)
	end

	if not next(mount_grade_cfg) then return attr end
	attr.max_hp = mount_grade_cfg.maxhp or 0 or 0
	attr.gong_ji = mount_grade_cfg.gongji or 0
	attr.fang_yu = mount_grade_cfg.fangyu or 0
	attr.ming_zhong = mount_grade_cfg.mingzhong or 0
	attr.shan_bi = mount_grade_cfg.shanbi or 0
	attr.bao_ji = mount_grade_cfg.baoji or 0
	attr.jian_ren = mount_grade_cfg.jianren or 0
	attr.extra_zengshang = mount_grade_cfg.extra_zengshang or 0						--额外伤害值
	attr.extra_mianshang = mount_grade_cfg.extra_mianshang or 0					--额外减伤值
	attr.move_speed = mount_grade_cfg.movespeed or 0 --+ differ_value.move_speed * temp_attr_per
	attr.per_jingzhun = mount_grade_cfg.per_jingzhun or 0							-- 破甲
	attr.per_baoji = mount_grade_cfg.per_baoji or 0								-- 暴伤
	attr.per_zengshang = mount_grade_cfg.per_zengshang or 0							--伤害加成万分比
	attr.per_jianshang = mount_grade_cfg.per_jianshang or 0							--伤害减免万分比
	attr.pvp_jianshang = mount_grade_cfg.pvp_jianshang or 0							-- pvp减伤
	attr.pvp_zengshang = mount_grade_cfg.pvp_zengshang or 0							-- pvp增伤
	attr.pve_jianshang = mount_grade_cfg.pve_jianshang or 0							-- pve减伤
	attr.pve_zengshang = mount_grade_cfg.pve_zengshang or 0							-- pve增伤
	return attr
end

function FightMountData:GetSpecialAttrActiveType(cur_grade)
	local cur_grade = cur_grade or self.mount_info.grade or 0
	return AdvanceData.Instance:GetSpecialAttrActiveType(self.mount_cfg.grade, cur_grade)
end

function FightMountData:GetHuanHuaSpecialAttrActiveType(grade, index)
	local grade = grade or self.mount_info.special_img_grade_list[index] or 0
	return AdvanceData.Instance:GetSpecialAttrActiveType(self.mount_cfg.special_image_upgrade, grade, index)
end

function FightMountData:GetMountStarLevelCfg(star_level)
	local star_level = star_level or self.mount_info.star_level

	for k, v in pairs(self:GetMountUpStarExpCfg()) do
		if v.star_level == star_level then
			return v
		end
	end

	return nil
end

-- 获取当前点击战骑技能的配置
function FightMountData:GetMountSkillCfgById(skill_idx, level, mount_info)
	local mount_info = mount_info or self.mount_info
	local level = level or mount_info.skill_level_list[skill_idx]

	for k, v in pairs(self:GetMountSkillCfg()) do
		if v.skill_idx == skill_idx and v.skill_level == level then
			return v
		end
	end

	return nil
end

function FightMountData:GetMountGradeByUseImageId(used_imageid)
	if not used_imageid then return 0 end
	local image_list = self:GetMountImageCfg()
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

function FightMountData:GetBigTargetImageId()
	return JinJieRewardData.Instance:GetSingleRewardCfgParam0(JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT)
end

function FightMountData:CanHuanhuaUpgradeList()
	local list = {}
	if self.mount_info.grade == nil or self.mount_info.grade <= 0 then
		return list
	end

	local special_img_grade_list = self.mount_info.special_img_grade_list
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

function FightMountData:CanShenCiHuanhuaUpgradeList()
	local list = {}
	if self.mount_info.grade == nil or self.mount_info.grade <= 0 then
		return list
	end

	local special_img_grade_list = self.mount_info.special_img_grade_list
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

function FightMountData:CanShenCiHuanhuaUpgrade()
	local list = self:CanShenCiHuanhuaUpgradeList()
	return next(list) ~= nil
end

function FightMountData:CanSkillUpLevelList()
	local list = {}
	if self.mount_info.grade == nil or self.mount_info.grade <= 0 then return list end
	if self.mount_info.skill_level_list == nil then
		return list
	end

	for k, v in pairs(self:GetMountSkillCfg()) do
		if v.uplevel_stuff_num <= ItemData.Instance:GetItemNumInBagById(v.uplevel_stuff_id)
			and self.mount_info.skill_level_list[v.skill_idx] == (v.skill_level - 1)
			and v.grade <= self.mount_info.grade and v.skill_type ~= 0 then
			list[v.skill_idx] = v.skill_idx
		end
	end
	return list
end


function FightMountData:CalTalentRemind()
	if nil == self.mount_info or nil == next(self.mount_info) then
		return 0
	end
	if ImageFuLingData.Instance:GetAdvanceTalentRemind(TALENT_TYPE.TALENT_FIGHTMOUNT) > 0 and self.mount_info.grade > TALENTLEVEL then
		return 1
	end
	return 0
end

function FightMountData:CanHuanhuaUpgrade()
	local list = self:CanHuanhuaUpgradeList()
	return next(list) ~= nil
end

function FightMountData:IsShowZizhiRedPoint()
	local fightmount_shuxingdan_cfg = AdvanceData.Instance:GetShuXingDanCfg(FightMountShuXingDanCfgType.Type)
	if not fightmount_shuxingdan_cfg or not next(fightmount_shuxingdan_cfg) then
		return false
	end

	if next(self.mount_info) == nil and self.mount_info.grade == nil then
		return false
	end
	if self.mount_info.grade < fightmount_shuxingdan_cfg.order_limit then
		return false
	end
	
	local count_limit = self:GetSpecialImageAttrSum().shuxingdan_count
	if self.mount_info.shuxingdan_count == nil or count_limit == nil then
		return false
	end
	if self.mount_info.shuxingdan_count >= count_limit then
		return false
	end

	if ItemData.Instance:GetItemNumInBagById(FightMountDanId.ZiZhiDanId) > 0 then
		return true
	end

	return false
end

function FightMountData:CanJinjie()
	if self.mount_info.grade == nil or self.mount_info.grade <= 0 then return false end
	local stuff_item_id = FightMountData.Instance:GetMountUpStarStuffCfg().up_star_item_id

	-- local star_cfg = self:GetMountStarLevelCfg(self.mount_info.star_level)
	local item_num = ItemData.Instance:GetItemNumInBagById(stuff_item_id) * self.mount_cfg.up_star_stuff[1].star_exp
	 + self.mount_info.grade_bless_val
	 
	if stuff_item_id then
		if 0 < ItemData.Instance:GetItemNumInBagById(stuff_item_id)
			and self.mount_info.grade < self:GetMaxGrade() then
			-- and item_num >= star_cfg.up_star_level_exp then
			return true
		end
	end
	return false
end

function FightMountData:IsActiviteMount()
	local active_flag = self.mount_info and self.mount_info.active_image_flag or {}
	for k, v in pairs(active_flag) do
		if v == 1 then
			return true
		end
	end
	return false
end

function FightMountData:GetEquipInfoCfg(equip_index, level)
	if nil == self.equip_info_cfg[equip_index] then
		return
	end
	return self.equip_info_cfg[equip_index][level]
end

function FightMountData:CalAllEquipRemind()
	if not self:IsOpenEquip() then return 0 end

	for k, v in pairs(self.mount_info.equip_level_list) do
		if self:CalEquipRemind(k) > 0 then
			return 1
		end
	end
	return 0
end

function FightMountData:CalEquipRemind(equip_index)
	if nil == self.mount_info or nil == next(self.mount_info) then
		return 0
	end

	local equip_level = self.mount_info.equip_level_list[equip_index] or 0
	local equip_cfg = self:GetEquipInfoCfg(equip_index, equip_level + 1)
	if nil == equip_cfg then return 0 end

	local grade_info_cfg = self:GetMountGradeCfg(self.mount_info.grade)
	local equip_level_toplimit = grade_info_cfg.equip_level_toplimit
	if self.mount_info.grade < self:GetEquipLevelLimit() or equip_level >= equip_level_toplimit then
		return 0
	end

	local item_data = equip_cfg.item
	local had_prop_num = ItemData.Instance:GetItemNumInBagById(item_data.item_id)

	return had_prop_num >= item_data.num and 1 or 0
end

function FightMountData:GetEquipLevelLimit()
	for k, v in ipairs(self.mount_cfg.grade) do
		if v.equip_level_toplimit ~= 0 then
			return k -1
		end
	end
	return 0
end


function FightMountData:IsOpenEquip()
	if nil == self.mount_info or nil == next(self.mount_info) then
		return false, 0
	end

	local otehr_cfg = self:GetOhterCfg()
	if self.mount_info.grade > otehr_cfg.active_equip_grade then
		return true, 0
	end

	return false, otehr_cfg.active_equip_grade
end

function FightMountData:IsActiveEquipSkill()
	if nil == self.mount_info or nil == next(self.mount_info) then
		return false
	end
	return self.mount_info.equip_skill_level > 0
end

function FightMountData:GetClearBlessGrade()
	return self.clear_bless_grade, self.clear_bless_grade_name
end

function FightMountData:CanShowRed()
	local mount_info = FightMountData.Instance:GetFightMountInfo()
	local grade_cfg = FightMountData.Instance:GetMountGradeCfg(mount_info.grade)
	if nil == grade_cfg then
		return false
	end

	if mount_info.grade >= self:GetMaxGrade() then
		return false
	end
	if KaifuActivityData.Instance:IsOpenAdvanceReturnActivity() then
		local open_advance_one = KaifuActivityData.Instance:GetOpenAdvanceType(TYPE_UPGRADE_RETURN.FIGHTMOUNT_UPGRADE_RETURN)
		local open_advance_two = KaifuActivityData.Instance:GetOpenAdvanceTypeTwo(TYPE_UPGRADE_RETURN.FIGHTMOUNT_UPGRADE_RETURN)
		local bag_num = ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff_id) + ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff2_id)
		if (open_advance_one == 1 or open_advance_two == 1) and bag_num >= grade_cfg.upgrade_stuff_count then
			return true
		end
	end
	return false
end

function FightMountData:GetShuXinLevel()
	for k, v in ipairs(self.mount_cfg.grade) do
		if v.zengshang_per ~= 0 then
			return v.grade 
		end
	end 
	return 0
end

-- 当前阶数
function FightMountData:GetGrade()
	return self.mount_info.grade or 0
end

--当前使用形象
function FightMountData:GetUsedImageId()
	return self.mount_info.used_imageid 
end

-- 全属性加成所需阶数
function FightMountData:GetActiveNeedGrade()
	local other_cfg = self:GetOhterCfg()
	return other_cfg.extra_attrs_per_grade or 1
end

-- 全属性加成百分比
function FightMountData:GetAllAttrPercent()
  	local other_cfg = self:GetOhterCfg()
  	local attr_percent = math.floor(other_cfg.extra_attrs_per / 100) 	-- 万分比转为百分比
  	return attr_percent or 0
end

--当前等级基础战力 power  额外属性加成 huanhua_add_per
function FightMountData:GetCurGradeBaseFightPowerAndAddPer()
	local power = 0
	local huanhua_add_per = 0

	local grade = self:GetGrade()
	local cur_grade = grade == 0 and 1 or grade
	local attr_cfg = self:GetMountGradeCfg(cur_grade)
	local attr = CommonDataManager.GetAttributteByClass(attr_cfg)
	power = CommonDataManager.GetCapabilityCalculation(attr)

	local active_add_per_need_level = self:GetActiveNeedGrade()
	if grade >= active_add_per_need_level then
		huanhua_add_per = self:GetAllAttrPercent()
	end
	return power, huanhua_add_per
end

--当前等级基础战力 power  额外勋章属性加成 base_attr_add_per
function FightMountData:GetCurGradeBaseFightPower()
	local power = 0
	local grade = self:GetGrade()
	local cur_grade = grade == 0 and 1 or grade
	local attr_cfg = self:GetMountGradeCfg(cur_grade)
	local attr = CommonDataManager.GetAttributteByClass(attr_cfg)
	power = CommonDataManager.GetCapabilityCalculation(attr)
	return power
end

--得到幻化形象当前等级
function FightMountData:GetSingleSpecialImageGrade(image_id)
	local grade = 0
	if nil == self.mount_info or nil == self.mount_info.special_img_grade_list or nil == self.mount_info.special_img_grade_list[image_id] then
		return grade
	end

	grade = self.mount_info.special_img_grade_list[image_id]
	return grade
end

--当前进阶等级对应的image_id
function FightMountData:GetCurGradeImageId()
	local image_id = 0
	local cfg = self:GetMountGradeCfg(self.mount_info.grade)
	if cfg then
		image_id = cfg.image_id or 0
	end

	return image_id
end

------------------------------------------------幻化超级战力-------------------------------------------------
--获取配置判断超级战力是否开启 0/1 不开启/开启
function FightMountData:SuperPowerIsOpenByCfg()
	local other_cfg = self:GetOhterCfg()
	local open_flag = other_cfg and other_cfg.is_open_special_cap_add
	local is_open = false
	if open_flag then
		is_open = open_flag == 1
	end

	return is_open
end

--特殊星星是否显示
function FightMountData:GetStarIsShowSuperPower(huanhua_id)
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
function FightMountData:IsShowSuperPower(huanhua_id)
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
function FightMountData:GetSingleHuanHuaSpecialCapAddList(huanhua_id)
	local list = {}
	if nil == huanhua_id or nil == self.huanhua_special_cap_add or nil == self.huanhua_special_cap_add[huanhua_id] then
		return list
	end

	list = self.huanhua_special_cap_add[huanhua_id]
	return list
end

--获取激活超级形象的要求等级
function FightMountData:GetActiveSuperPowerNeedLevel(huanhua_id)
	local level = 0
	local list = self:GetSingleHuanHuaSpecialCapAddList(huanhua_id)
	if list and list.huanhua_level then
		level = list.huanhua_level
	end

	return level
end

--特殊战力面板显示数据
function FightMountData:GetSpecialHuanHuaShowData(huanhua_id)
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

function FightMountData:GetFightMountIsRotationByImageId(image_id)
	if image_id then
		if image_id > 1000 then
			local cfg = self:GetSpecialImageCfg(image_id - 1000)
			if cfg and cfg.is_rotation then
				return cfg.is_rotation == 1
			end
		else
			local cfg = self:GetImageListInfo(image_id)
			if cfg and cfg.is_rotation then
				return cfg.is_rotation == 1
			end
		end
	end
	return false
end

function FightMountData:IsHaveZhiShengDanInGrade()
	if self.mount_info and next(self.mount_info) then
		local zhishengdan_list = ItemData.Instance:GetItemListByBigType(GameEnum.ITEM_BIGTYPE_EXPENSE)
		for k, v in pairs(zhishengdan_list) do
			local item_cfg, bag_type = ItemData.Instance:GetItemConfig(v.item_id)
			if item_cfg.use_type == 68 and item_cfg.param2 == self.mount_info.grade then
				return true, item_cfg.id
			end
		end
	end
	return false, nil
end

function FightMountData:IsShenCiHuanhuaIdByItemId(item_id)
	local cfg = self:GetSpecialImagesCfg()
	for k, v in pairs(cfg) do
		if v.item_id == item_id and v.is_shenci and v.is_shenci == 1 then
			return true
		end
	end
	return false
end

function FightMountData:IsShenCiHuanhuaIdAndCanJumpByItemId(item_id)
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