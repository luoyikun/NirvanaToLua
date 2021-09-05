--主角服装武器数据
FashionData = FashionData or BaseClass()

SHIZHUANG_TYPE = {
	WUQI = 0,
	BODY = 1,
	MAX = 2,
}

SHIZHUANG = {
	SHIZHUANG_MAX_LEVEL = 20,
	SHIZHUANG_MAX_INDEX = 63,
	SHIZHUANG_CROSS_RANK_REWARD_INDEX = 30,
	FASHION_SKILL_COUNT = 4,
	FASHION_EQUIP_COUNT = 4,
}

FashionDanId = {
	ZiZhiDanId = 22103, 		 --时装资质丹
	ShenBingZiZhiDanID = 22120    --神兵
}

ShizhuangShuXingDanCfgType = {
	Type = 15
}

WuQiShuXingDanCfgType = {
	Type = 16
}

local TALENTLEVEL = 8
function FashionData:__init()
	if FashionData.Instance then
		print_error("[FashionData] 尝试创建第二个单例模式")
	end
	FashionData.Instance = self
	self.clothing_act_id_list = {}
	self.wuqi_act_id_list = {}
	self.upgrade_list = {}

--武器
	self.wuqi_info = {}
	self.wuqi_cfg = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto")
	self.wuqi_special_upgrade_cfg = ListToMap(self.wuqi_cfg.weapon_special_img_upgrade, "special_img_id", "grade")
	self.wuqi_equip_cfg = ListToMap(self.wuqi_cfg.weapon_equip_info, "equip_idx", "equip_level")
	self.huanhua_special_cap_add = ListToMap(self.wuqi_cfg.huanhua_special_cap_add, "huanhua_id")
	self.fashion_huanhua_special_cap_add = ListToMap(self.wuqi_cfg.fashion_huanhua_special_cap_add, "huanhua_id")
	-- self.shuxingdan_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("shuxingdan_cfg_auto").reward,"type") --type唯一才能调用
	self.clear_bless_grade = 100
	self.clear_bless_grade_name = ""
	for i,v in ipairs(self.wuqi_cfg.weapon_upgrade) do
		if v.is_clear_bless == 1 then
			self.clear_bless_grade = v.grade
			self.clear_bless_grade_name = v.gradename
			break
		end
	end
--时装
	self.jinjie_type = self.wuqi_cfg.jinjie_type
	self.canupgrade_cfg_list = self.wuqi_cfg.can_upgrade
	self.shizhuang_upgrade_cfg = self.wuqi_cfg.shizhuang_upgrade
	self.shizhuang_img_cfg = ListToMap(self.wuqi_cfg.shizhuang_img, "image_id")
	self.shizhuang_skill_cfg = ListToMap(self.wuqi_cfg.shizhuang_skill, "skill_idx", "skill_level")
	self.shizhuang_special_img_cfg = self.wuqi_cfg.shizhuang_special_img
	self.shizhuang_special_img_upgrade_cfg = ListToMap(self.wuqi_cfg.shizhuang_special_img_upgrade, "special_img_id", "grade")
	self.shizhuang_equip_info_cfg = ListToMap(self.wuqi_cfg.shizhuang_equip_info, "equip_idx", "equip_level")
	self.clear_bless_grade2 = 100
	self.clear_bless_grade_name2 = ""
	for i,v in ipairs(self.wuqi_cfg.shizhuang_upgrade) do
		if v.is_clear_bless == 1 then
			self.clear_bless_grade2 = v.grade
			self.clear_bless_grade_name2 = v.gradename
			break
		end
	end

	self.use_clothing_index = 0
	self.use_special_img = 0
end

function FashionData:__delete()
	FashionData.Instance = nil
	self.upgrade_list = {}
	self.wuqi_info = {}
end

--武器Datag
function FashionData:SetWuQiData(protocol)
	if self.wuqi_info.grade_bless_val then
		local diff = protocol.grade_bless - self.wuqi_info.grade_bless_val
		local bless_cfg =  AdvanceData.Instance:GetBlessBaojiCfg(UPGRADE_BAOJI_TYPE.UPGRADE_TYPE_SHENBING)
		local baoji_bless = bless_cfg.upgrade_exp * bless_cfg.crit_value
		if diff > 0 and diff == baoji_bless then
			TipsCtrl.Instance:OpenBaojiViewTips("advance_view")
		end
	end

	self.wuqi_info.use_idx  = protocol.use_idx           --当前形象ID
	self.wuqi_info.use_special_img = protocol.use_special_img   --当前特殊形象id
	self.wuqi_info.grade_bless_val = protocol.grade_bless       --进阶祝福值   
	self.wuqi_info.grade = protocol.grade             --进阶
	self.wuqi_info.shuxingdan_count = protocol.shuxingdan_count  --属性丹数量
	self.wuqi_info.active_flag = bit:uc2b(protocol.active_flag)        --已经激活的武器
	self.wuqi_info.special_img_grade_list = protocol.special_img_grade_list --特殊形象等级列表
	self.wuqi_info.valid_timestamp_list = protocol.valid_timestamp_list --
	self.wuqi_info.skill_level_list = protocol.skill_level_list        --时装技能等级
	self.wuqi_info.equip_level_list = protocol.equip_level_list
	self.wuqi_info.equip_skill_level = protocol.equip_skill_level
	self.wuqi_info.clear_bless_value_time = protocol.clear_bless_value_time
	self.wuqi_info.is_used_special_img = protocol.is_used_special_img
	self.wuqi_info.special_active_flag =  bit:uc2b(protocol.special_img_active_flag)
	self.wuqi_info.grade = protocol.grade == 0 and 1 or protocol.grade
	self.wuqi_info.use_clothing_index = self.wuqi_info.grade == 1 and protocol.use_idx or protocol.use_idx + 1
end

function FashionData:GetShenBingGradeCfg(shenbing_grade)
	local shenbing_grade = shenbing_grade or self.wuqi_info.grade or 0
	if shenbing_grade > self:GetMaxGrade() then
		shenbing_grade = self:GetMaxGrade()
	end
	return self.wuqi_cfg.weapon_upgrade[shenbing_grade]
end

function FashionData:GetWuQiSpecialActiveFlag()
	return self.wuqi_info.special_active_flag 
end

function FashionData:GetWuQiInfo()
	return self.wuqi_info
end

function FashionData:GetImageListInfo(index)
	if (index == 0) or nil then return end
	for k, v in pairs(self:GetWuQiImageID()) do
		if v.image_id == index then
			return v
		end
	end
	return nil
end

function FashionData:GetMaxSpecialImage()
	return #self.wuqi_cfg.weapon_special_img
end

--获取当前武器阶数
function FashionData:GetWuQiGrade()
	return self.wuqi_info.grade 
end

--同步使用中的武器
function FashionData:SetUseWuqiIndex()
	return self.wuqi_info.use_idx 
end

--获取武器属性
function FashionData:GetWuQiAttrNum(shenbing_info, next_level)
	local attr = CommonStruct.Attribute()
	local fashion_info = shenbing_info or self:GetWuQiInfo()
	if nil == fashion_info.grade or fashion_info.grade <= 0  then
		return attr
	end

	local shenbing_grade_cfg = {}
	if next_level then
		shenbing_grade_cfg = self.wuqi_cfg.weapon_upgrade[fashion_info.grade + 1]
	else
		shenbing_grade_cfg = self.wuqi_cfg.weapon_upgrade[fashion_info.grade]
	end

	if not shenbing_grade_cfg or not next(shenbing_grade_cfg) then return attr end 
	attr.max_hp = shenbing_grade_cfg.maxhp or 0 or 0
	attr.gong_ji = shenbing_grade_cfg.gongji or 0
	attr.fang_yu = shenbing_grade_cfg.fangyu or 0
	attr.ming_zhong = shenbing_grade_cfg.mingzhong or 0
	attr.shan_bi = shenbing_grade_cfg.shanbi or 0
	attr.bao_ji = shenbing_grade_cfg.baoji or 0
	attr.jian_ren = shenbing_grade_cfg.jianren or 0
	attr.extra_zengshang = shenbing_grade_cfg.extra_zengshang or 0						--额外伤害值
	attr.extra_mianshang = shenbing_grade_cfg.extra_mianshang or 0					--额外减伤值
	attr.per_jingzhun = shenbing_grade_cfg.per_jingzhun or 0							-- 破甲
	attr.per_baoji = shenbing_grade_cfg.per_baoji or 0								-- 暴伤
	attr.per_zengshang = shenbing_grade_cfg.per_zengshang or 0							--伤害加成万分比
	attr.per_jianshang = shenbing_grade_cfg.per_jianshang or 0							--伤害减免万分比
	attr.pvp_jianshang = shenbing_grade_cfg.pvp_jianshang or 0							-- pvp减伤
	attr.pvp_zengshang = shenbing_grade_cfg.pvp_zengshang or 0							-- pvp增伤
	attr.pve_jianshang = shenbing_grade_cfg.pve_jianshang or 0							-- pve减伤
	attr.pve_zengshang = shenbing_grade_cfg.pve_zengshang or 0							-- pve增伤
	return attr
end

function FashionData:GetSpecialAttrActiveType(cur_grade)
	local cur_grade = cur_grade or self.wuqi_info.grade or 0
	return AdvanceData.Instance:GetSpecialAttrActiveType(self.wuqi_cfg.weapon_upgrade, cur_grade)
end

-------武器的激活形象的id
function FashionData:GetWuQiImageID()
	return self.wuqi_cfg.weapon_img
end

function FashionData:GetWuQiImageCfg()
	return self.wuqi_cfg.weapon_special_img
end

function FashionData:GetWuQiSpecialImageCfg(image_id)
	local wuqiconfig = self:GetWuQiImageCfg()
	return wuqiconfig[image_id] or {}
end

---------武器的最大阶数
function FashionData:GetMaxGrade()
	 return #self.wuqi_cfg.weapon_upgrade
end

-------获取武器阶数
function FashionData:GetWuQiGradeCfg(grade)
	local grade = grade or self.wuqi_info.grade or 0
	if grade > self:GetMaxGrade() then
		grade = self:GetMaxGrade()
	end
	return self.wuqi_cfg.weapon_upgrade[grade]
end

--获取进阶丹的ID
function FashionData:GetWuQiUpStarStuffCfg()
	return self.wuqi_cfg.weapon_upgrade[1]
end

---获取技能的信息
function FashionData:GetWuQiSkillCfgById(skill_idx, level, wuqi_info)
	if self.wuqi_info.skill_level_list == nil then return end   
	local wuqi_info = wuqi_info or self.wuqi_info
	local level = level or wuqi_info.skill_level_list[skill_idx]

	for k, v in pairs(self:GetWuQiSkillCfg()) do
		if v.skill_idx == skill_idx and v.skill_level == level then
			return v
		end
	end

	return nil
end

-- 获得已学习的技能总战力
function FashionData:GetWuQiSkillAttrSum(wuqi_info)
	local attr_list = CommonStruct.Attribute()
	for i = 0, 3 do
		local skill_cfg = self:GetWuQiSkillCfgById(i, nil, wuqi_info)
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

--得到武器技能配置
function FashionData:GetWuQiSkillCfg()
	return self.wuqi_cfg.weapon_skill
end

function FashionData:GetSpecialImagesCfg()
	-- local wuqi_list_special_img = TableCopy(self.wuqi_cfg.weapon_special_img)
	local wuqi_list_special_img = self:GetHuanHuaCfgList()
	table.sort(wuqi_list_special_img, function(a, b)
			if a.valid_time_s == b.valid_time_s then
				return a.image_id < b.image_id
			end
			return a.valid_time_s > b.valid_time_s
		end)
	return wuqi_list_special_img
end

function FashionData:CanHuanhuaIndexByImageId(image_id)
	local list = self:GetSpecialImagesCfg()
	local num = 0
	for k, v in ipairs(list) do
		num = num + 1
		if v.item_id == image_id then
			return v.image_id, num
		end
	end
end

-- 获取可显示的幻化列表
function FashionData:GetHuanHuaCfgList()
	local huanhua_list = {}
	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	for _, v in ipairs(self.wuqi_cfg.weapon_special_img) do
		if main_vo.level >= v.lvl and open_server_day >= v.open_day then
			table.insert(huanhua_list, v)
		end
	end
	return huanhua_list
end

function FashionData:IsWuQiCanHuanhuaDayAndLevel(index)
	local huanhua_list = self:GetHuanHuaCfgList()
	for k, v in pairs(huanhua_list) do
		if v.image_id == index then
			return true
		end
	end
	return false
end

function FashionData:GetSpecialImageUpgradeCfg()
	return self.wuqi_cfg.weapon_special_img_upgrade
end

function FashionData:GetWuqiSpecialUpgradeCfg()
	return self.wuqi_special_upgrade_cfg
end

function FashionData:GetSpecialImageCfg(image_id)
	local wuqiconfig = self:GetSpecialImagesCfg()
	return wuqiconfig[image_id] or {}
end

function FashionData:CanWuQiHuanhuaUpgradeList()
	local list = {}
	if self.wuqi_info.grade == nil or self.wuqi_info.grade <= 0 then
		return list
	end
	local special_img_grade_list = self.wuqi_info.special_img_grade_list
	if special_img_grade_list == nil then
		return list
	end

	local image_id = self:GetBigTargetImageId()
	local upgrade_cfg = self:GetWuqiSpecialUpgradeCfg()

	for k,v in pairs(special_img_grade_list) do
		if upgrade_cfg[k] and upgrade_cfg[k][v] then
			local upgrade_info = upgrade_cfg[k][v]
			if ItemData.Instance:GetItemNumInBagById(upgrade_info.stuff_id) >= upgrade_info.stuff_num 
			and v < self:GetSpecialImageMaxUpLevelById(k) 
			and k ~= image_id then
				if self:IsWuQiCanHuanhuaDayAndLevel(k) then
					list[k] = k
				end
			end
		end
	end

	-- for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
	-- 	if ItemData.Instance:GetItemNumInBagById(v.stuff_id) >= v.stuff_num and 
	-- 		special_img_grade_list[v.special_img_id] == v.grade and
	-- 		v.grade < self:GetSpecialImageMaxUpLevelById(v.special_img_id)
	-- 		and v.special_img_id ~= image_id then 								--大目标去除
	-- 		if self:IsWuQiCanHuanhuaDayAndLevel(v.special_img_id) then
	-- 			list[v.special_img_id] = v.special_img_id
	-- 		end
	-- 	end
	-- end
	return list
end

function FashionData:CanWuQiHuanhuaUpgrade()
	local list = self:CanWuQiHuanhuaUpgradeList()
	return next(list) ~= nil
end

-- 获取幻化最大等级
function FashionData:GetSpecialImageMaxUpLevelById(image_id)
	if not image_id then return 0 end
	local max_level = 0

	local upgrade_cfg = self:GetWuqiSpecialUpgradeCfg()
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

function FashionData:CanSkillUpLevelListOne()
	local list = {}
	if self.wuqi_info.grade == nil or self.wuqi_info.grade <= 0 then return list end
	if self.wuqi_info.skill_level_list == nil then
		return list
	end
	for k, v in pairs(self:GetWuQiSkillCfg()) do
		if v.uplevel_stuff_num <= ItemData.Instance:GetItemNumInBagById(v.uplevel_stuff_id)
			and self.wuqi_info.skill_level_list[v.skill_idx] == (v.skill_level - 1)
			and v.grade <= self.wuqi_info.grade and v.skill_type ~= 0 then
			list[v.skill_idx] = v.skill_idx
		end
	end
	return list
end

--是否可以进阶
function FashionData:CanJinjie()
	if self.wuqi_info.grade == nil or self.wuqi_info.grade <= 0 then return false end

	local grad_cfg = self:GetWuQiGradeCfg(self.wuqi_info.grade)
	if nil == grad_cfg then return false end

	if ItemData.Instance:GetItemNumInBagById(grad_cfg.upgrade_stuff_id) >= grad_cfg.upgrade_stuff_count
		and self.wuqi_info.grade < self:GetMaxGrade() then
		return true
	end
	return false
end

--资质丹
function FashionData:IsShowZizhiRedPoint()
	-- local wuqi_shuxingdan_cfg = self.shuxingdan_cfg[WuQiShuXingDanCfgType.Type]
	local wuqi_shuxingdan_cfg = AdvanceData.Instance:GetShuXingDanCfg(WuQiShuXingDanCfgType.Type)
	if not wuqi_shuxingdan_cfg or not next(wuqi_shuxingdan_cfg) then
		return false
	end

	if next(self.wuqi_info) == nil and self.wuqi_info.grade == nil then
		return false
	end

	if self.wuqi_info.grade < wuqi_shuxingdan_cfg.order_limit then
		return false
	end
	if self.wuqi_info.shuxingdan_count == nil  then
		return false
	end
	local count_limit = self.wuqi_cfg.weapon_upgrade[self.wuqi_info.grade].shuxingdan_limit
	if self.wuqi_info.shuxingdan_count >= count_limit or count_limit == nil then
		return false
	end
	if ItemData.Instance:GetItemNumInBagById(FashionDanId.ShenBingZiZhiDanID) > 0 then
		return true
	end
	return false
end

-- 获取武器特殊特殊形象总增加的属性
function FashionData:GetSpecialImageAttrSum(wuqi_info)
	local wuqi_info = wuqi_info or self.wuqi_info
	local sum_attr_list = CommonStruct.Attribute()
	local active_flag = wuqi_info.special_active_flag
	if active_flag == nil then
		sum_attr_list.shuxingdan_count = 0
		sum_attr_list.shuxingdan_count = 0
		sum_attr_list.equip_limit = 0
		return sum_attr_list
	end
	local special_shuxingdan_count = 0
	local special_shuxingdan_count = 0
	local special_equip_limit = 0
	local special_img_upgrade_info = nil
	for k, v in pairs(active_flag) do
		if v == 1 then
			if self:GetSpecialImageUpgradeInfo(k) ~= nil then
				special_img_upgrade_info = self:GetSpecialImageUpgradeInfo(k)
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
	if self:GetWuQiGradeCfg(wuqi_info.grade) then
		sum_attr_list.chengzhangdan_count = special_shuxingdan_count + self:GetWuQiGradeCfg(wuqi_info.grade).chengzhangdan_limit
		sum_attr_list.shuxingdan_count = special_shuxingdan_count + self:GetWuQiGradeCfg(wuqi_info.grade).shuxingdan_limit
		sum_attr_list.equip_limit = special_equip_limit + self:GetWuQiGradeCfg(wuqi_info.grade).equip_level_limit
	end
	return sum_attr_list
end

-- 获取当前点击坐骑特殊形象的配置
function FashionData:GetSpecialImageUpgradeInfo(index, grade, is_next)
	if (index == 0) or nil then
		return
	end
	local grade = grade or self.wuqi_info.special_img_grade_list[index] or 0
	if is_next then
		grade = grade + 1
	end
	local upgrade_cfg = self:GetWuqiSpecialUpgradeCfg()
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

function FashionData:IsActiviteWuQi()
	local active_flag = self.wuqi_info and self.wuqi_info.active_flag or {}
	for k, v in pairs(active_flag) do
		if v == 1 then
			return true
		end
	end
	return false
end

function FashionData:CalAllEquipRemind()
	if not self:IsOpenEquip() or not self:GetWuQiEquipInfo().equip_level_list then return 0 end

	for k, v in pairs(self:GetWuQiEquipInfo().equip_level_list) do
		if self:CalEquipRemind(k) > 0 then
			return 1
		end
	end
	return 0
end

function FashionData:CalTalentRemind()
	if nil == self.wuqi_info or nil == next(self.wuqi_info) then
		return 0
	end
	if ImageFuLingData.Instance:GetAdvanceTalentRemind(TALENT_TYPE.TALENT_SHENYI) > 0 and self.wuqi_info.grade > TALENTLEVEL then
		return 1
	end
	return 0
end

function FashionData:GetWuQiEquipInfo()
	local info = {}
	info.equip_level_list = self.wuqi_info.equip_level_list
	info.equip_skill_level = self.wuqi_info.equip_skill_level
	return info
end

function FashionData:CalEquipRemind(equip_index)
	if nil == self.wuqi_info or nil == next(self.wuqi_info) then
		return 0
	end
	local equip_level = self.wuqi_info.equip_level_list[equip_index] or 0
	local equip_cfg = self:GetEquipInfoCfg(equip_index, equip_level + 1)
	if nil == equip_cfg then return 0 end

	local grade_info_cfg = self:GetShenBingGradeCfg(self.wuqi_info.grade)
	local equip_level_toplimit = grade_info_cfg.equip_level_toplimit
	if self.wuqi_info.grade < self:GetEquipLevelLimit() or equip_level >= equip_level_toplimit then
		return 0
	end

	local item_data = equip_cfg.item
	local had_prop_num = ItemData.Instance:GetItemNumInBagById(item_data.item_id)
	return had_prop_num >= item_data.num and 1 or 0
end

function FashionData:GetEquipLevelLimit()
	for k, v in ipairs(self.wuqi_cfg.weapon_upgrade) do
		if v.equip_level_toplimit ~= 0 then
			return k - 1
		end
	end
	return 0
end


function FashionData:GetEquipInfoCfg(equip_index, level)
	if nil == self.wuqi_equip_cfg[equip_index] then
		return
	end
	return self.wuqi_equip_cfg[equip_index][level]
 end

-- 获得已升级装备战力
function FashionData:GetWuQiEquipAttrSum(wuqi_info)
	local wuqi_info = wuqi_info or self.wuqi_info
	local attr_list = CommonStruct.Attribute()
	if nil == wuqi_info.equip_level_list then return attr_list end
	for k, v in pairs(wuqi_info.equip_level_list) do
		attr_list = CommonDataManager.AddAttributeAttr(attr_list, CommonDataManager.GetAttributteByClass(self:GetEquipInfoCfg(k, v)))
	end
	return attr_list
end

function FashionData:IsOpenEquip()
	if nil == self.wuqi_info or nil == next(self.wuqi_info) then
		return false, 0
	end
	local otehr_cfg = self:GetOtherCfg()
	if self.wuqi_info.grade > otehr_cfg.active_equip_grade then
		return true, 0
	end
	return false, otehr_cfg.active_equip_grade
end

function FashionData:GetOtherCfg()
	return self.wuqi_cfg.other[1]
end

--服装是否激活
function FashionData:GetClothingActFlag(index)
	if self.special_active_flag_t == nil or not next(self.special_active_flag_t) then return 0 end
	return self.special_active_flag_t[index]
end
 
--武器是否激活
function FashionData:GetWuqiActFlag(index)
	if self.wuqi_info == nil then
		return 0
	end
	if self.wuqi_info.special_active_flag == nil or not next(self.wuqi_info.special_active_flag) then return 0 end
	return self.wuqi_info.special_active_flag[index]
end

-- 时装是否激活
function FashionData:GetFashionActFlag(part_type, index)
	if part_type == SHIZHUANG_TYPE.WUQI then
		return self.wuqi_act_id_list[index]
	elseif part_type == SHIZHUANG_TYPE.BODY then
		return self.clothing_act_id_list[index]
	end
end

function FashionData:GetFashionActFlagById(id)
	local cfg = self:GetShizhuangImgCfg()
	local index = 0
	for k,v in pairs(cfg) do
		if v.item_id == id then
			index = v.image_id
			break
		end
	end
	if index then
		local flag = self:GetClothingActFlag(index)
		return flag == 1
	end
	return false
end

--获取使用中的武器
function FashionData:GetUsedWuqiIndex()
	return self.use_wuqi_index
end

-- 根据时装类型获取当前index
function FashionData:GetUsedFashionIndexByType(part_type)
	if part_type == SHIZHUANG_TYPE.WUQI then
		return self.use_wuqi_index
	elseif  part_type == SHIZHUANG_TYPE.BODY then
		return self.use_clothing_index
	end
end

--根据index获取服装的配置
function FashionData:GetClothingConfig(clothing_index)
	self:GetShizhuangUpgrade(clothing_index)
end

--根据type, index获取服装的配置
function FashionData:GetFashionConfig(fashion_cfg_list, part_type, index)
	for k, v in pairs(fashion_cfg_list) do
		if v.part_type == part_type and index == v.index then
			return v
		end
	end
	return nil
end

function FashionData:CheckIsDressed(fz_type, index)
	if fz_type == SHIZHUANG_TYPE.WUQI then
		return (self.use_wuqi_index == index)
	elseif fz_type == SHIZHUANG_TYPE.BODY then
		return (self.use_clothing_index == index)
	end
end
function FashionData:CheckIsActive(fz_type, index)
	if fz_type == SHIZHUANG_TYPE.WUQI then
		return (self:GetWuqiActFlag(index) == 1)
	elseif fz_type == SHIZHUANG_TYPE.BODY then
		return (self:GetClothingActFlag(index) == 1)
	end
end

--获取服装激活数
function FashionData:GetFashionActNum()
	local num = 0

	for k,v in pairs(self.clothing_act_id_list) do
		if v == 1 then
			num = num + 1
		end
	end
	for k,v in pairs(self.wuqi_act_id_list) do
		if v == 1 then
			num = num + 1
		end
	end

	return num
end

--是否有激活的时装
function FashionData:GetHasActFashion()
	for k,v in pairs(self.clothing_act_id_list) do
		if v == 1 then
			return true
		end
	end
	for k,v in pairs(self.wuqi_act_id_list) do
		if v == 1 then
			return true
		end
	end
	return false
end

-- 根据时装物品id获取资源id
function FashionData.GetFashionResByItemId(item_id, sex, prof)
	if nil == item_id then return nil end
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").shizhuang_special_img) do
		if v.item_id == item_id then
			return v["resouce"..prof..sex], v
		end
	end
	return nil
end

function FashionData.GetWeaponResByItemId(item_id, sex, prof)
	if nil == item_id then return nil end
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").weapon_special_img) do
		if v.item_id == item_id then
			return v["resouce"..prof..sex]
		end
	end
	return nil
end


function FashionData:IsActiveEquipSkill()
	if nil == self.wuqi_info or nil == next(self.wuqi_info) then
		return false
	end
	return self.wuqi_info.equip_skill_level > 0
end

function FashionData:SetFashionUpgradeInfo(upgrade_list)
	self.upgrade_list = upgrade_list
end

function FashionData:SetFashionLeastTimeInfo(least_time_list)
	self.least_time_list = least_time_list
end

function FashionData:GetTimeCfg(index, part_type)
	local cfg = self:GetFashionTimeInfo()
	if next(cfg) == nil then
		return
	end
	local time = TimeCtrl.Instance:GetServerTime()
	local least_time = cfg[part_type].time_list[index] - time
	least_time = TimeUtil.FormatSecond(least_time,6)
	return least_time 
end

function FashionData:GetShuXinLevel()
	for k, v in ipairs(self.wuqi_cfg.weapon_upgrade) do
		if v.zengshang_per ~= 0 then
			return v.grade 
		end
	end 
	return 0
end

-- 当前阶数
function FashionData:GetGrade()
	return self.wuqi_info.grade or 0
end

--当前使用形象
function FashionData:GetUsedImageId()
	return self.wuqi_info.use_clothing_index
end

-- 全属性加成所需阶数
function FashionData:GetActiveNeedGrade()
	local other_cfg = self:GetOtherCfg()
	return other_cfg.extra_attrs_per_grade or 1
end

-- 全属性加成百分比
function FashionData:GetAllAttrPercent()
  	local other_cfg = self:GetOtherCfg()
  	local attr_percent = math.floor(other_cfg.extra_attrs_per / 100) 	-- 万分比转为百分比
  	return attr_percent or 0
end

--当前等级基础战力 power  额外属性加成 huanhua_add_per
function FashionData:GetCurGradeBaseFightPowerAndAddPer(type)
	local power = 0
	local huanhua_add_per = 0
	local grade = 0
	if type == SHIZHUANG_TYPE.WUQI then
		grade = self:GetGrade()
		local cur_grade = grade == 0 and 1 or grade
		local attr_cfg = self:GetShenBingGradeCfg(cur_grade)
		local attr = CommonDataManager.GetAttributteByClass(attr_cfg)
		power = CommonDataManager.GetCapabilityCalculation(attr)
	else
		grade = self:GetNowGrade()
		local cur_grade = grade == 0 and 1 or grade
		local attr_cfg = self:GetShiZhuangGradeCfg(cur_grade)
		local attr = CommonDataManager.GetAttributteByClass(attr_cfg)
		power = CommonDataManager.GetCapabilityCalculation(attr)
	end
	local active_add_per_need_level = self:GetActiveNeedGrade()
	if grade >= active_add_per_need_level then
		huanhua_add_per = self:GetAllAttrPercent()
	end
	return power, huanhua_add_per
end

--得到幻化形象当前等级
function FashionData:GetSingleSpecialImageGrade(image_id, type)
	local grade = 0
	if type == SHIZHUANG_TYPE.WUQI then
		if nil == self.wuqi_info or nil == self.wuqi_info.special_img_grade_list or nil == self.wuqi_info.special_img_grade_list[image_id] then
			return grade
		end
		grade = self.wuqi_info.special_img_grade_list[image_id]
	else
		if nil == self.special_img_grade_list or nil == self.special_img_grade_list[image_id] then
			return grade
		end
		grade = self.special_img_grade_list[image_id]
	end
	return grade
end

--当前进阶等级对应的image_id
function FashionData:GetCurGradeImageId()
	local image_id = 0
	local cfg = self:GetShenBingGradeCfg(self.wuqi_info.grade)
	if cfg then
		image_id = cfg.image_id or 0
	end

	return image_id
end

function FashionData:GetGradeAndSpecialAttr()
	local cfg = self:GetShenBingGradeCfg(self.wuqi_info.grade)
	for k, v in ipairs(self.wuqi_cfg.weapon_upgrade) do
		if v.zengshang_per > cfg.zengshang_per then
			return v.grade, v.zengshang_per - cfg.zengshang_per
		end
	end
end

------------------------------------------------幻化超级战力-------------------------------------------------
--获取配置判断超级战力是否开启 0/1 不开启/开启
function FashionData:SuperPowerIsOpenByCfg()
	local other_cfg = self:GetOtherCfg()
	local open_flag = other_cfg and other_cfg.is_open_special_cap_add
	local is_open = false
	if open_flag then
		is_open = open_flag == 1
	end

	return is_open
end

--特殊星星是否显示
function FashionData:GetStarIsShowSuperPower(huanhua_id, type)
	local is_show = false
	local is_open = self:SuperPowerIsOpenByCfg()
	if not is_open then
		return is_show
	end
	if nil == huanhua_id then
		return is_show
	end

	local need_level = 0
	local cur_level = -1
	if type == SHIZHUANG_TYPE.WUQI then
		if nil == self.huanhua_special_cap_add or nil == self.huanhua_special_cap_add[huanhua_id] then
			return is_show
		end
		local list = self.huanhua_special_cap_add[huanhua_id]
		need_level = list.huanhua_level
		cur_level = self:GetSingleSpecialImageGrade(huanhua_id, type)
	else
		if nil == self.fashion_huanhua_special_cap_add or nil == self.fashion_huanhua_special_cap_add[huanhua_id] then
			return is_show
		end
		local list = self.fashion_huanhua_special_cap_add[huanhua_id]
		need_level = list.huanhua_level
		cur_level = self:GetSingleSpecialImageGrade(huanhua_id, type)
	end
	
	if need_level and cur_level and cur_level >= need_level then
		is_show = true
	end
	return is_show
end

--超级战力是否显示
function FashionData:IsShowSuperPower(huanhua_id, type)
	local is_show = false
	local is_open = self:SuperPowerIsOpenByCfg()
	if not is_open then
		return is_show
	end
	if nil == huanhua_id then
		return is_show
	end
	if type == SHIZHUANG_TYPE.WUQI then
		if nil == self.huanhua_special_cap_add or nil == self.huanhua_special_cap_add[huanhua_id] then
			return is_show
		end
		list = self.huanhua_special_cap_add[huanhua_id]
	else
		if nil == self.fashion_huanhua_special_cap_add or nil == self.fashion_huanhua_special_cap_add[huanhua_id] then
			return is_show
		end
	end

	local level = self:GetSingleSpecialImageGrade(huanhua_id, type)
	is_show = level > 0
	return is_show
end

--获取单个幻化形象特殊战力配置
function FashionData:GetSingleHuanHuaSpecialCapAddList(huanhua_id, type)
	local list = {}
	if nil == huanhua_id then
		return list
	end
	if type == SHIZHUANG_TYPE.WUQI then
		if nil == self.huanhua_special_cap_add or nil == self.huanhua_special_cap_add[huanhua_id] then
			return list
		end
		list = self.huanhua_special_cap_add[huanhua_id]
	else
		if nil == self.fashion_huanhua_special_cap_add or nil == self.fashion_huanhua_special_cap_add[huanhua_id] then
			return list
		end
		list = self.fashion_huanhua_special_cap_add[huanhua_id]
	end
	return list
end

--获取激活超级形象的要求等级
function FashionData:GetActiveSuperPowerNeedLevel(huanhua_id, type)
	local level = 0
	local list = self:GetSingleHuanHuaSpecialCapAddList(huanhua_id, type)
	if list and list.huanhua_level then
		level = list.huanhua_level
	end

	return level
end

--特殊战力面板显示数据
function FashionData:GetSpecialHuanHuaShowData(huanhua_id, type)
 	local data_list = CommonStruct.SpecialHuanHuaTipInfo()
	if nil == huanhua_id then
		return data_list
	end

	local cfg = self:GetSingleHuanHuaSpecialCapAddList(huanhua_id, type)
	-- local huanhua_cfg = self:GetSpecialImageCfg(huanhua_id)
	local huanhua_cfg = nil
	if type == SHIZHUANG_TYPE.WUQI then
		huanhua_cfg = self.wuqi_cfg.weapon_special_img[huanhua_id]
	else
		huanhua_cfg = self.wuqi_cfg.shizhuang_special_img[huanhua_id]
	end
	if huanhua_cfg then
		local image_name = huanhua_cfg and huanhua_cfg.image_name or ""
		local name = image_name or "" 

		local need_level = cfg.huanhua_level or 0
		local cur_level = self:GetSingleSpecialImageGrade(huanhua_id, type) or 0
		local color = cur_level >= need_level and TEXT_COLOR.GREEN_4 or TEXT_COLOR.RED
		local cur_level_str = ToColorStr(cur_level, color)
		local desc_str = string.format(Language.Advance.SpecialHuanHuaTips, name, cur_level_str, ToColorStr(need_level, TEXT_COLOR.GREEN_4))

	 	data_list.max_hp = cfg.maxhp or 0								-- 生命
		data_list.gong_ji = cfg.gongji or 0 							-- 攻击
		data_list.fang_yu = cfg.fangyu or 0								-- 防御
		data_list.desc = desc_str										-- 描述
	end
	return data_list
end
---------------------------进阶时装协议star-----------
--接收服务端时装进阶数据
function FashionData:SetFashionData(protocol)
	if self.grade_bless_val then
		local diff = protocol.grade_bless - self.grade_bless_val
		local bless_cfg =  AdvanceData.Instance:GetBlessBaojiCfg(UPGRADE_BAOJI_TYPE.UPGRADE_TYPE_SHIZHUANG)
		local baoji_bless = bless_cfg.upgrade_exp * bless_cfg.crit_value
		if diff > 0 and diff == baoji_bless then
			TipsCtrl.Instance:OpenBaojiViewTips("advance_view")
		end
	end
	
	self.use_special_img = protocol.use_special_img          	  --当前特殊形象id
	self.grade_bless_val  = protocol.grade_bless         	      --进阶祝福值   
	self.shuxingdan_count = protocol.shuxingdan_count   	      --属性丹数量
	self.active_flag = bit:uc2b(protocol.active_flag) --是否开启时装系统
	self.special_img_grade_list = protocol.special_img_grade_list --特殊形象等级列表
	self.valid_timestamp_list = protocol.valid_timestamp_list
	self.skill_level_list = protocol.skill_level_list             --时装技能等级
	self.equip_level_list = protocol.equip_level_list
	self.equip_skill_level = protocol.equip_skill_level
	self.clear_bless_value_time = protocol.clear_bless_value_time
	self.is_used_special_img = protocol.is_used_special_img
	self.special_active_flag_t = bit:uc2b(protocol.special_img_active_flag)
	self.grade = protocol.grade == 0 and 1 or protocol.grade
	self.use_clothing_index = self.grade == 1 and protocol.use_idx or protocol.use_idx + 1
end

function FashionData:GetActiveFlag()
	return self.active_flag
end

function FashionData:GetFashionInfo()
	local info = {}
	info.use_special_img = self.use_special_img
	info.grade_bless_val = self.grade_bless_val
	info.shuxingdan_count = self.shuxingdan_count
	info.active_flag = self.active_flag
	info.special_img_grade_list = self.special_img_grade_list
	info.valid_timestamp_list = self.valid_timestamp_list
	info.skill_level_list = self.skill_level_list
	info.equip_level_list = self.equip_level_list
	info.equip_skill_level = self.equip_skill_level
	info.clear_bless_value_time = self.clear_bless_value_time
	info.special_active_flag_t = self.special_active_flag_t
	info.grade = self.grade
	info.use_clothing_index = self.use_clothing_index == 0 and self.use_clothing_index or self.use_clothing_index - 1
	info.is_used_special_img = self.is_used_special_img 
	return info
end

function FashionData:IsOpenFashionEquip()
	local otehr_cfg = self:GetOtherCfg()
	if self.grade > otehr_cfg.active_equip_grade then
		return true, 0
	end
	return false, otehr_cfg.active_equip_grade
end

function FashionData:GetFashionShuXinLevel()
	for k, v in ipairs(self.wuqi_cfg.shizhuang_upgrade) do
		if v.per_jingzhun ~= 0 then
			return v.grade 
		end
	end 
	return 0
end

---------------------------时装协议end-----------
function FashionData:GetUpgradeCfg()

	return self.shizhuang_upgrade_cfg
end

function FashionData:GetShizhuangUpgradeMaxGrade()
	return #self.shizhuang_upgrade_cfg
end


function FashionData:GetShiZhuangGradeCfg(shizhuang_grade)
	local shizhuang_grade = shizhuang_grade or self.grade or 0
	if shizhuang_grade > self:GetShizhuangUpgradeMaxGrade() then
		shizhuang_grade = self:GetShizhuangUpgradeMaxGrade()
	end
	return self.wuqi_cfg.shizhuang_upgrade[shizhuang_grade]
end

--根据index(1-13)获取进阶配置表
function FashionData:GetShizhuangUpgrade(index)
	if not index then return self.shizhuang_upgrade_cfg[self.grade] end

	if self.shizhuang_upgrade_cfg and index > 0 and index <= #self.shizhuang_upgrade_cfg then
		return self.shizhuang_upgrade_cfg[index]
	end
end

function FashionData:GetShizhuangImgCfg()
	local info  =  {} 
	for k, v in pairs(self.wuqi_cfg.shizhuang_special_img) do
		table.insert(info, v)
	end
	for k, v in pairs(self.wuqi_cfg.weapon_special_img) do
		table.insert(info, v)
	end
	return info
end

function FashionData:GetShizhuangImgMaxGrade()
	return #self.shizhuang_img_cfg
end

--当前进阶等级对应的image_id
function FashionData:GetFashionCurGradeImageId()
	local image_id = 0
	local cfg = self:GetShiZhuangGradeCfg(self.grade)
	if cfg then
		image_id = cfg.image_id or 0
	end

	return image_id
end

--根据image_id(1-12)获取资源配置表
function FashionData:GetShizhuangImg(image_id)
	if not image_id then return self.shizhuang_img_cfg[self.use_clothing_index] end

	if image_id > 0 and image_id <= #self.shizhuang_img_cfg then
		return self.shizhuang_img_cfg[image_id]
	end
end

function FashionData:GetShizhuangSpecialImg(index)
	local shizhuang_list = self:GetShizhuangSpecialImage()
	if shizhuang_list and next(shizhuang_list) then
		return shizhuang_list[index]
	end
end

function FashionData:GetShizhuangImage()
	return self.shizhuang_img_cfg
end

--形象编号
function FashionData:GetShizhuangSpecialImgByIndex(index)
	return self.shizhuang_special_img_cfg[index]
end

--获取时装属性
function FashionData:GetFashionAttrNum(fashion_info, next_level)
	local attr = CommonStruct.Attribute()
	local grade = fashion_info and fashion_info.grade or self.grade
	if nil == grade or grade <= 0  then
		return attr
	end
	local fashion_info_cfg = {}
	if next_level then
		fashion_info_cfg = self.shizhuang_upgrade_cfg[grade + 1]
	else
		fashion_info_cfg = self.shizhuang_upgrade_cfg[grade]
	end
	if not fashion_info_cfg or not next(fashion_info_cfg) then return attr end

	attr.max_hp = fashion_info_cfg.maxhp or 0
	attr.gong_ji = fashion_info_cfg.gongji or 0
	attr.fang_yu = fashion_info_cfg.fangyu or 0
	attr.ming_zhong = fashion_info_cfg.mingzhong or 0
	attr.shan_bi = fashion_info_cfg.shanbi or 0
	attr.bao_ji = fashion_info_cfg.baoji or 0
	attr.jian_ren = fashion_info_cfg.jianren or 0
	attr.extra_zengshang = fashion_info_cfg.extra_zengshang or 0						--额外伤害值
	attr.extra_mianshang = fashion_info_cfg.extra_mianshang or 0					--额外减伤值
	attr.per_jingzhun = fashion_info_cfg.per_jingzhun or 0							-- 破甲
	attr.per_baoji = fashion_info_cfg.per_baoji or 0								-- 暴伤
	attr.per_zengshang = fashion_info_cfg.per_zengshang or 0							--伤害加成万分比
	attr.per_jianshang = fashion_info_cfg.per_jianshang or 0							--伤害减免万分比
	attr.pvp_jianshang = fashion_info_cfg.pvp_jianshang or 0							-- pvp减伤
	attr.pvp_zengshang = fashion_info_cfg.pvp_zengshang or 0							-- pvp增伤
	attr.pve_jianshang = fashion_info_cfg.pve_jianshang or 0							-- pve减伤
	attr.pve_zengshang = fashion_info_cfg.pve_zengshang or 0							-- pve增伤
	return attr
end

function FashionData:GetFashionSpecialAttrActiveType(cur_grade)
	local cur_grade = cur_grade or self.grade or 0
	return AdvanceData.Instance:GetSpecialAttrActiveType(self.shizhuang_upgrade_cfg, cur_grade)
end

function FashionData:GetHuanHuaSpecialAttrActiveType(grade, index, part_type)
	if part_type == SHIZHUANG_TYPE.WUQI then
		local grade = grade or self.wuqi_info.special_img_grade_list[index] or 0
		return AdvanceData.Instance:GetSpecialAttrActiveType(self.wuqi_cfg.weapon_special_img_upgrade, grade, index)
	else
		local grade = grade or self.special_img_grade_list[index] or 0
		return AdvanceData.Instance:GetSpecialAttrActiveType(self.wuqi_cfg.shizhuang_special_img_upgrade, grade, index)
	end
end

function FashionData:GetSpecialImgGradeList()
	return self.clear_bless_value_time
end

--获取当前阶数祝福值上限
function FashionData:GetBlessValLimit()
	return self.shizhuang_upgrade_cfg[self.grade].bless_val_limit
end

function FashionData:GetClearBlessValueTime()
	return self.clear_bless_value_time
end

--获取当前阶数进阶丹所需数量
function FashionData:GetRemainderNeedNum()
	if nil == self.grade then
		return 9999
	end
	return self.shizhuang_upgrade_cfg[self.grade].upgrade_stuff_count
end

--获取使用中的服装
function FashionData:GetUsedClothingIndex()
	return self.use_clothing_index
end

--获取当前阶数
function FashionData:GetNowGrade()
	return self.grade
end

--获取当前祝福值
function FashionData:GetNowGradeBless()
	return self.grade_bless_val
end
---------------------------进阶end--------------------
---------------------------幻化star-------------------
--当前使用的特殊时装
function FashionData:GetShizhuangUseSpecialImg()
	return self.use_special_img 
end

--获取特殊时装是否激活的表
function FashionData:GetSpecialActiveFlag()
	return self.special_active_flag_t
end

--获取特殊时装等级
function FashionData:GetShizhuangSpecialInfo()
	return self.special_img_grade_list
end

function FashionData:GetShizhuangSpecialImgUpgradeCfg()
	return self.shizhuang_special_img_upgrade_cfg
end

function FashionData:GetShizhuangSpecialImgCfg()
	-- self.shizhuang_list = TableCopy(self.shizhuang_special_img_cfg)
	self.shizhuang_list = self:GetShiZhuangHuanHuaCfgList() or {}
	table.sort(self.shizhuang_list, function(a, b)
			if a.valid_time_s == b.valid_time_s then
				return a.image_id < b.image_id
			end
			return a.valid_time_s > b.valid_time_s
		end)
	return self.shizhuang_list
end

function FashionData:CanShizhuangHuanhuaIndexByImageId(image_id)
	local list = self:GetShizhuangSpecialImgCfg()
	local num = 0
	for k, v in ipairs(list) do
		num = num + 1
		if v.item_id == image_id then
			return v.image_id, num
		end
	end
end

-- 获取可显示的幻化列表
function FashionData:GetShiZhuangHuanHuaCfgList()
	local huanhua_list = {}
	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	for _, v in ipairs(self.shizhuang_special_img_cfg) do
		if main_vo.level >= v.lvl and open_server_day >= v.open_day then
			table.insert(huanhua_list, v)
		end
	end
	return huanhua_list
end

function FashionData:IsShiZhuangCanHuanhuaDayAndLevel(index)
	local huanhua_list = self:GetHuanHuaCfgList()
	for k, v in pairs(huanhua_list) do
		if v.image_id == index then
			return true
		end
	end
	return false
end

--特殊形象id，等级
function FashionData:GetShizhuangSpecialImgUpgradeById(special_img_id, grade)
	if not grade then 
		grade = self.special_img_grade_list[special_img_id]
	end
	if self.shizhuang_special_img_upgrade_cfg[special_img_id] then
		return self.shizhuang_special_img_upgrade_cfg[special_img_id][grade]
	end
end

function FashionData:GetFashionBigTargetImageId()
	local image_id = JinJieRewardData.Instance:GetSingleRewardCfgParam0(JINJIE_TYPE.JINJIE_TYPE_FASHION)
	local fshion_list = self:GetShizhuangSpecialImgCfg()
	for k, v in pairs(fshion_list) do
		if v.image_id == image_id then 
			return k
		end
	end
	return 0
end

function FashionData:GetBigTargetImageId()
	local image_id = JinJieRewardData.Instance:GetSingleRewardCfgParam0(JINJIE_TYPE.JINJIE_TYPE_SHENBING)
	local shenbing_list = self:GetSpecialImagesCfg()
	for k, v in pairs(shenbing_list) do
		if v.image_id == image_id then 
			return k
		end
	end
	return 0
end

function FashionData:GetMaxShizhuangSpecialImage()
	return #self.shizhuang_special_img_cfg
end

function FashionData:GetShizhuangSpecialImage()
	return self.shizhuang_special_img_cfg
end

function FashionData:GetFashionSpecialImageMaxUpLevelById(special_img_id)
	if not special_img_id then return 0 end
	return #self.shizhuang_special_img_upgrade_cfg[special_img_id]
end
----------------------------幻化end--------------------
----------------------------技能star-------------------
function FashionData:GetShizhuangSkillCfg()
	return self.shizhuang_skill_cfg
end

--获取服务端数据
function FashionData:GetShizhuangSkillInfo()
	local info = {}
	info.grade = self.grade
	info.skill_level_list = self.skill_level_list
	return info
end

--根据技能id和等级获取技能配置表
function FashionData:GetShizhuangSkillCfgById(skill_idx, skill_level)
	skill_idx = skill_idx ~= nil and skill_idx or 1
	skill_level = skill_level ~= nil and skill_level or self.skill_level_list[skill_idx]
	return self.shizhuang_skill_cfg[skill_idx][skill_level]
end

function FashionData:CanSkillUpLevelList()
	local list = {}
	if self.grade == nil or self.grade <= 0 or self.skill_level_list == nil then return list end

	for i = 1, SHIZHUANG.FASHION_SKILL_COUNT - 1 do
		local level = self.skill_level_list[i]
		local cfg = self.shizhuang_skill_cfg[i][level + 1]
		if cfg and cfg.grade <= self.grade and
			cfg.uplevel_stuff_num <= ItemData.Instance:GetItemNumInBagById(cfg.uplevel_stuff_id) then
			list[i] = true
		else
			list[i] = false
		end
	end

	return list
end

function FashionData:CanFashionSkillUpLevelList()
	local list = {}
	if self.grade == nil or self.grade <= 0 or self.skill_level_list == nil then return list end

	for i = 1, SHIZHUANG.FASHION_SKILL_COUNT - 1 do
		local level = self.skill_level_list[i]
		local cfg = self.shizhuang_skill_cfg[i][level + 1]
		if cfg and cfg.grade <= self.grade and
			cfg.uplevel_stuff_num <= ItemData.Instance:GetItemNumInBagById(cfg.uplevel_stuff_id) then
			list[i] = cfg.skill_idx
		end
	end
	return list
end
----------------------------技能end--------------------
----------------------------装备star-------------------
function FashionData:GetShizhuangEquipInfo()
	local info = {}
	info.equip_level_list = self.equip_level_list
	info.equip_skill_level = self.equip_skill_level
	return info
end

function FashionData:GetEquipSkillLevel()
	return self.equip_skill_level
end

function FashionData:GetShizhuangEquipCfg()
	return self.shizhuang_equip_info_cfg
end

function FashionData:GetShizhuangEquipById(equip_idx, equip_level)
	if not self.shizhuang_equip_info_cfg[equip_idx] then return end

	if not equip_level then
		equip_level = self.equip_level_list[equip_idx + 1]
	end
	return self.shizhuang_equip_info_cfg[equip_idx][equip_level]
end

function FashionData:CalShizhuangEquipRemind(equip_idx)
	if not self.equip_level_list then return 0 end
	local equip_level = self.equip_level_list[equip_idx] or 0
	local equip_cfg = self.shizhuang_equip_info_cfg[equip_idx][equip_level + 1]
	if not equip_cfg then return 0 end

	local grade_info_cfg = self:GetShiZhuangGradeCfg(self.grade)
	local equip_level_toplimit = grade_info_cfg.equip_level_toplimit
	if self.grade < self:GetShiZhuangLevelLimit() or equip_level >= equip_level_toplimit then
		return 0
	end

	local item_data = equip_cfg.item
	local had_prop_num = ItemData.Instance:GetItemNumInBagById(item_data.item_id)
	return had_prop_num >= item_data.num and 1 or 0
end

function FashionData:GetShiZhuangLevelLimit()
	for k, v in ipairs(self.wuqi_cfg.shizhuang_upgrade) do
		if v.equip_level_toplimit ~= 0 then
			return k - 1
		end
	end
	return 0
end

--需要读取othercfg(无)
function FashionData:IsOpenShizhuangEquip()
	if nil == self.grade then
		return false, 0
	end

	local other_cfg = self:GetOtherCfg()
	if self.grade > other_cfg.active_equip_grade then
		return true, 0
	end

	return false, other_cfg.active_equip_grade
end

function FashionData:IsOpenShenBingEquip()
	if nil == self.wuqi_info or nil == next(self.wuqi_info) then
		return false, 0
	end

	local other_cfg = self:GetOtherCfg()
	if self.wuqi_info.grade > other_cfg.active_equip_grade then
		return true, 0
	end

	return false, other_cfg.active_equip_grade
end

--需要读取othercfg(无)
function FashionData:GetShizhuangOhterCfg()

end

-- 获得已升级装备属性
function FashionData:GetShizhuangEquipAttrSum()
	local attr_list = CommonStruct.Attribute()
	if not self.equip_level_list then return attr_list end

	for k,v in pairs(self.equip_level_list) do
		attr_list = CommonDataManager.AddAttributeAttr(attr_list, CommonDataManager.GetAttributteByClass(self:GetShizhuangEquipById(k, v)))
	end
	return attr_list
end

----------------------------装备end---------------------
----------------------------资质star--------------------
--获取当前使用属性丹(资质丹)数量
function FashionData:GetShuXingDanCount()
	return self.shuxingdan_count
end

--获取资质丹战力
function FashionData:GetZizhidanPower()
	local item_cfg = ItemData.Instance:GetItemConfig(FashionData.ZiZhiDanId)
	if not item_cfg then return 0 end

	return item_cfg.power
end

function FashionData:GetFashionZizhiInfo()
	local info = {}
	info.grade = self.grade
	info.shuxingdan_count = self.shuxingdan_count
	return info
end
----------------------------资质end---------------------
----------------------------红点star--------------------
function FashionData:CanHuanhuaUpgradeList()
	local list = {}
	if self.grade == nil or self.grade <= 0 then
		return list
	end
	local special_img_grade_list = self.special_img_grade_list
	if special_img_grade_list == nil then
		return list
	end

	local image_id = self:GetFashionBigTargetImageId()
	for k, v in pairs(self.wuqi_cfg.shizhuang_special_img_upgrade) do
		if ItemData.Instance:GetItemNumInBagById(v.stuff_id) >= v.stuff_num and 
			special_img_grade_list[v.special_img_id] == v.grade and
			v.grade < self:GetFashionSpecialImageMaxUpLevelById(v.special_img_id)
			and v.special_img_id ~= image_id then 								--大目标去除
			list[v.special_img_id] = v.special_img_id
		end
	end
	
	return list
end

function FashionData:CanFashionHuanhuaUpgrade()
	local list = self:CanHuanhuaUpgradeList()
	return next(list) ~= nil
end

function FashionData:CalFashionTalentRemind()
	if self.grade == nil or self.grade <= 0 then
		return 0
	end
	
	if ImageFuLingData.Instance:GetAdvanceTalentRemind(TALENT_TYPE.TALENT_SHENGGONG) > 0 and self.grade > TALENTLEVEL then
		return 1
	end
	return 0
end

function FashionData:IsShowFashionZizhiRedPoint()
	-- local fashion_shuxingdan_cfg = self.shuxingdan_cfg[ShizhuangShuXingDanCfgType.Type]
	local fashion_shuxingdan_cfg = AdvanceData.Instance:GetShuXingDanCfg(ShizhuangShuXingDanCfgType.Type)
	if not fashion_shuxingdan_cfg or not next(fashion_shuxingdan_cfg) then
		return false
	end

	if self.grade == nil then
		return false
	end
	if self.grade < fashion_shuxingdan_cfg.order_limit then
		return false
	end
	if self.shuxingdan_count == nil then
		return false
	end
	local count_limit = self.shizhuang_upgrade_cfg[self.grade].shuxingdan_limit
	if count_limit == nil or self.shuxingdan_count >= count_limit then
		return false
	end
	if ItemData.Instance:GetItemNumInBagById(FashionDanId.ZiZhiDanId) > 0 then
		return true
	end
	return false
end

function FashionData:CanFashionJinjie()
	if self.shizhuang_upgrade_cfg and self.grade and self.shizhuang_upgrade_cfg[self.grade] then
		local need_count = self.shizhuang_upgrade_cfg[self.grade].upgrade_stuff_count
		local item_id = self.shizhuang_upgrade_cfg[self.grade].upgrade_stuff_id
		local now_cound = ItemData.Instance:GetItemNumInBagById(item_id)
		return need_count <= now_cound
	end

	return false
end

function FashionData:CalAllFashionEquipRemind()
	if not self:IsOpenShizhuangEquip() or not self.equip_level_list then return 0 end
	for i,v in pairs(self.equip_level_list) do
		if self:CalShizhuangEquipRemind(i) > 0 then
			return 1
		end
	end
	return 0
end
----------------------------红点end--------------------
-------------------------------------------------衣服end-----------------------------------------
function FashionData:GetClearBlessGrade()
	return self.clear_bless_grade, self.clear_bless_grade_name
end

function FashionData:GetClearBlessGrade2()
	return self.clear_bless_grade2, self.clear_bless_grade_name2
end


function FashionData:CanShowRed()
	if nil == self.grade then
		return
	end
	
	local cfg = self:GetShizhuangUpgrade()
	local show_cfg = self:GetShizhuangUpgrade(self.grade)
	if nil == show_cfg then
		return false
	end
	if nil == cfg then
		return false
	end
	local num2 = self:GetRemainderNeedNum()
	local bag_num = ItemData.Instance:GetItemNumInBagById(show_cfg.upgrade_stuff_id) + ItemData.Instance:GetItemNumInBagById(show_cfg.upgrade_stuff2_id)
	if bag_num >= num2 and cfg.is_clear_bless == 0 then
		return true
	else
		return false
	end
end


function FashionData:GetFashionSpecialImageUpgradeCfg()
	return self.wuqi_cfg.shizhuang_special_img_upgrade
end


function FashionData:CanShowRed2()
	local wuqi_info = FashionData.Instance:GetWuQiInfo()
	local grade_cfg = FashionData.Instance:GetWuQiGradeCfg(wuqi_info.grade)
	if nil == grade_cfg then
		return false
	end
	local bag_num = ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff_id) + ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff2_id)
	if bag_num >= grade_cfg.upgrade_stuff_count and ADVANCE_CLEAR_BLESS.NOT_CLEAR == grade_cfg.is_clear_bless then
		return true
	else
		return false
	end
end

-- 根据套装id获取相应配置
function FashionData:GetFashionCfg(fashion_id)
	local cfg = {}
	for k,v in pairs(self.shizhuang_special_img_cfg) do
		if v.item_id == fashion_id then
			cfg = v
			break
		end
	end

	return cfg
end

function FashionData:GetWeaponCfg(weapon_id)
	local cfg = {}
	local weapon_cfg = self:GetWuQiImageCfg()
	for k,v in pairs(weapon_cfg) do
		if v.item_id == weapon_id then
			cfg = v
			break
		end
	end

	return cfg
end

function FashionData:GetFashionGradeAndSpecialAttr()
	local cfg = self:GetShiZhuangGradeCfg(self.grade)
	for k, v in ipairs(self.shizhuang_upgrade_cfg) do
		if v.per_jingzhun > cfg.per_jingzhun then
			return v.grade, v.per_jingzhun - cfg.per_jingzhun
		end
	end
end

function FashionData:IsHaveZhiShengDanInGrade()
	if self.wuqi_info and next(self.wuqi_info) then
		local zhishengdan_list = ItemData.Instance:GetItemListByBigType(GameEnum.ITEM_BIGTYPE_EXPENSE)
		for k, v in pairs(zhishengdan_list) do
			local item_cfg, bag_type = ItemData.Instance:GetItemConfig(v.item_id)
			if item_cfg.use_type == 93 and item_cfg.param2 == self.wuqi_info.grade then
				return true, item_cfg.id
			end
		end
	end
	return false, nil
end

function FashionData:IsFashionHaveZhiShengDanInGrade()
	local zhishengdan_list = ItemData.Instance:GetItemListByBigType(GameEnum.ITEM_BIGTYPE_EXPENSE)
	for k, v in pairs(zhishengdan_list) do
		local item_cfg, bag_type = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg.use_type == 92 and item_cfg.param2 == self.grade then
			return true, item_cfg.id
		end
	end
	return false, nil
end