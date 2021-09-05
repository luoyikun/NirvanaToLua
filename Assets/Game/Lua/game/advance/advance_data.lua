AdvanceData = AdvanceData or BaseClass()

AdvanceDataIndex = {
	"mount", "wing", "halo", "shengong", "shenyi","fabao",
}

MountEquipExpItemId = {
	{26370, 26380, 26390}, {26340, 26350, 26360}
}
WingEquipExpItemId = {
	{26371, 26381, 26391}, {26341, 26351, 26361}
}
HaloEquipExpItemId = {
	{26372, 26382, 26392}, {26342, 26352, 26362}
}
ShengongEquipExpItemId = {
	{26373, 26383, 26393}, {26343, 26353, 26363}
}
ShenyiEquipExpItemId = {
	{26374, 26384, 26394}, {26344, 26354, 26364}
}

JINJIE_EQUIP_SKILL_TYPE = {
		SKILL_TYPE_MOUNT = 0,
		SKILL_TYPE_WING = 1,
		SKILL_TYPE_HALO = 2,
		SKILL_TYPE_SHENGONG = 3,
		SKILL_TYPE_SHENYI = 4,
		SKILL_TYPE_FIGHT_MOUNT = 5,
		SKILL_TYPE_FOOT_PRINT = 6,
		SKILL_TYPE_FABAO = 7,
		SKILL_TYPE_SHIZHUANG = 8,
		SKILL_TYPE_MAX = 9,
		
}

local JINJIE_SKILL_ICON_ASSET = {
	[JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_MOUNT] = "mount_skill_icon",
	[JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_WING] = "wing_skill_icon",
	[JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_HALO] = "halo_skill_icon",
	[JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_SHENGONG] = "shengong_skill_icon",
	[JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_SHENYI] = "shenyi_skill_icon",
	[JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_FIGHT_MOUNT] = "fight_mount_skill_icon",
	[JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_FOOT_PRINT] = "foot_skill_icon",
	[JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_FABAO] = "fabao_skill_icon",
	[JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_SHIZHUANG] = "fashion_skill_icon",
}

--是否清空祝福值
ADVANCE_CLEAR_BLESS = {
	NOT_CLEAR = 0,
	CLEAR = 1
}

-- 祝福值暴击类型
UPGRADE_BAOJI_TYPE = {
	UPGRADE_TYPE_MOUNT = 1,				--坐骑
	UPGRADE_TYPE_WING = 2,				--羽翼
	UPGRADE_TYPE_SHIZHUANG = 3,			--时装
	UPGRADE_TYPE_SHENBING = 4,			--神兵
	UPGRADE_TYPE_FABAO = 5,				--法宝
	UPGRADE_TYPE_FOOTPRINT = 6,			--足迹
	UPGRADE_TYPE_HALO = 7,				--光环
	UPGRADE_TYPE_FIGHTMOUNT = 8,		--战骑
	UPGRADE_TYPE_TOUSHI = 9,			--头饰
	UPGRADE_TYPE_MASK = 10,				--面饰
	UPGRADE_TYPE_YAOSHI = 11,			--腰饰
	UPGRADE_TYPE_QILINBI = 12,			--麒麟臂
	UPGRADE_TYPE_LINGTONG = 13,			--灵童
	UPGRADE_TYPE_LINGGONG = 14,			--灵弓
}

UPLEVEL_ITEM_TYPE = {
	SMALL_TYPE = 1,
	BIG_TYPE = 2,
	JUEBAN_TYPE = 3
}

function AdvanceData:__init()
	if AdvanceData.Instance ~= nil then
		return
	end
	AdvanceData.Instance = self
	self.advance_type = nil

	self.advance_transform_cfg = require("game/advance/advance_transform_cfg")

	RemindManager.Instance:Register(RemindName.AdvanceMount, BindTool.Bind(self.CalcMountRemind, self))
	RemindManager.Instance:Register(RemindName.AdvanceWing, BindTool.Bind(self.CalcWingRemind, self))
	RemindManager.Instance:Register(RemindName.AdvanceHalo, BindTool.Bind(self.CalcHaloRemind, self))
	RemindManager.Instance:Register(RemindName.AdvanceFightMount, BindTool.Bind(self.CalcFightMountRemind, self))
	RemindManager.Instance:Register(RemindName.AdvanceFoot, BindTool.Bind(self.CalcFootRemind, self))
	RemindManager.Instance:Register(RemindName.AdvanceCloak, BindTool.Bind(self.CalcCloakRemind, self))
	RemindManager.Instance:Register(RemindName.AdvanceFaBao, BindTool.Bind(self.CalcFaBaoRemind, self))
	RemindManager.Instance:Register(RemindName.AdvanceFashion, BindTool.Bind(self.CalcFashionRemind, self))
	RemindManager.Instance:Register(RemindName.AdvanceShenbing, BindTool.Bind(self.CalcWuQiRemind, self))
	RemindManager.Instance:Register(RemindName.AdvanceImmortals, BindTool.Bind(self.CalcLingRenRemind, self))
	RemindManager.Instance:Register(RemindName.HuanHua, BindTool.Bind(self.GetHuanhuaRemind, self))
	RemindManager.Instance:Register(RemindName.ShenCiWingHuanHua, BindTool.Bind(self.GetShenCiWingHuanhuaRemind, self))
	RemindManager.Instance:Register(RemindName.ShenCiFightMountHuanHua, BindTool.Bind(self.GetShenCiFightMountHuanhuaRemind, self))
	RemindManager.Instance:Register(RemindName.AdvanceEquip, BindTool.Bind(self.CalAdvanceEquipRemind, self))
	local skill_cfg = ConfigManager.Instance:GetAutoConfig("upgradeskill_auto")
	self.equip_skill_cfg = ListToMap(skill_cfg.skill_cfg, "skill_type", "skill_level")
	self.equip_skill_gauge_cfg = ListToMap(skill_cfg.gauge_cfg, "skill_count")
	self.advance_equip_type = 0

	self.bless_baoji_type_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("upgrade_sys_crit_config_auto").upgrade_sys_crit, "type")
	self.shuxingdan_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("shuxingdan_cfg_auto").reward,"type") --type唯一才能调用
	self.view_type = 0   -- 0是进阶界面, 1是幻化界面, 进阶界面只刷新进阶，幻化界面只刷新幻化
end

function AdvanceData:SetViewType(type_par)
	self.view_type = type_par or 0
end

function AdvanceData:GetViewType()
	return self.view_type
end

function AdvanceData:__delete()
	RemindManager.Instance:UnRegister(RemindName.AdvanceMount)
	RemindManager.Instance:UnRegister(RemindName.AdvanceWing)
	RemindManager.Instance:UnRegister(RemindName.AdvanceHalo)
	RemindManager.Instance:UnRegister(RemindName.AdvanceFightMount)
	RemindManager.Instance:UnRegister(RemindName.AdvanceShenbing)
	RemindManager.Instance:UnRegister(RemindName.AdvanceFoot)
	RemindManager.Instance:UnRegister(RemindName.AdvanceCloak)
	RemindManager.Instance:UnRegister(RemindName.AdvanceFaBao)
	RemindManager.Instance:UnRegister(RemindName.AdvanceFashion)
	RemindManager.Instance:UnRegister(RemindName.AdvanceImmortals)
	RemindManager.Instance:UnRegister(RemindName.HuanHua)
	RemindManager.Instance:UnRegister(RemindName.AdvanceEquip)
	AdvanceData.Instance = nil
end

function AdvanceData:GetAdvanceTransformCfg(advance_type, res_id)
	local cfg = self.advance_transform_cfg
	if cfg and cfg[advance_type] and cfg[advance_type][res_id] then
		return cfg[advance_type][res_id] 
	end
end

function AdvanceData:GetShengongCanJinjie()
	local shengong_info = ShengongData.Instance:GetShengongInfo()
	local up_star_cfg = ShengongData.Instance:GetShengongUpStarPropCfg()
	local shengong_grade_cfg = ShengongData.Instance:GetShengongGradeCfg(shengong_info.grade)
	if (not shengong_grade_cfg) or (not up_star_cfg) then
		return false
	end

	local max_grade = ShengongData.Instance:GetMaxGrade()
	if shengong_info.grade >= max_grade then
		 return false
	end

	if KaifuActivityData.Instance:IsOpenAdvanceReturnActivity() then
		local open_advance_one = KaifuActivityData.Instance:GetOpenAdvanceType(TYPE_UPGRADE_RETURN.SHENGONG_UPGRADE_RETURN)
		local open_advance_two = KaifuActivityData.Instance:GetOpenAdvanceTypeTwo(TYPE_UPGRADE_RETURN.SHENGONG_UPGRADE_RETURN)
		if (open_advance_one == 1 or open_advance_two == 1) then
			for k, v in ipairs(up_star_cfg) do
				local num = ItemData.Instance:GetItemNumInBagById(v.up_star_item_id)
				if num >= shengong_grade_cfg.upgrade_stuff_count then
					return true
				end
			end
		end
	end
	
	return false
end

function AdvanceData:GetShenyiCanJinjie()
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
	local up_star_cfg = ShenyiData.Instance:GetShenyiUpStarPropCfg()
	local shenyi_grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(shenyi_info.grade)
	if (not up_star_cfg) or (not shenyi_grade_cfg) then
		return false
	end

	local max_grade = ShenyiData.Instance:GetMaxGrade()
	if shenyi_info.grade >= max_grade then
		return false
	end

	if KaifuActivityData.Instance:IsOpenAdvanceReturnActivity() then
		local open_advance_one = KaifuActivityData.Instance:GetOpenAdvanceType(TYPE_UPGRADE_RETURN.SHENYI_UPGRADE_RETURN)
		local open_advance_two = KaifuActivityData.Instance:GetOpenAdvanceTypeTwo(TYPE_UPGRADE_RETURN.SHENYI_UPGRADE_RETURN)
		if (open_advance_one == 1 or open_advance_two == 1) then
			for k, v in ipairs(up_star_cfg) do
				local num = ItemData.Instance:GetItemNumInBagById(v.up_star_item_id)
				if num >= shenyi_grade_cfg.upgrade_stuff_count then
					return true
				end
			end
		end
	end
	
	return false
end

function AdvanceData:CalcMountRemind()
	if OpenFunData.Instance:CheckIsHide("mount_jinjie") == false then return 0 end
	local mount_data = MountData.Instance
	--进阶奖励
	local is_can_active_jinjie_reward = JinJieRewardData.Instance:SystemIsShowRedPoint(JINJIE_TYPE.JINJIE_TYPE_MOUNT)
	if (mount_data:CanHuanhuaUpgrade() == true or mount_data:CanShenCiHuanhuaUpgrade() == true
		or mount_data:CanShowRed()
		or mount_data:IsShowZizhiRedPoint() or next(mount_data:CanSkillUpLevelList()) ~= nil)
		or mount_data:CalAllEquipRemind() > 0 
		or is_can_active_jinjie_reward == true then
		return 1
	end
	return 0
end

function AdvanceData:CalcWingRemind()
	if OpenFunData.Instance:CheckIsHide("wing_jinjie") == false then return 0 end
	local wing_data = WingData.Instance
	local is_can_active_jinjie_reward = JinJieRewardData.Instance:SystemIsShowRedPoint(JINJIE_TYPE.JINJIE_TYPE_WING)
	if (wing_data:CanHuanhuaUpgrade() == true or wing_data:CanShenCiHuanhuaUpgrade() == true
		or wing_data:CanShowRed()
		or wing_data:IsShowZizhiRedPoint() or next(wing_data:CanSkillUpLevelList()) ~= nil )
		or wing_data:CalAllEquipRemind() > 0
		or is_can_active_jinjie_reward == true then
		return 1
	end
	return 0
end

function AdvanceData:CalcHaloRemind()
	if OpenFunData.Instance:CheckIsHide("halo_jinjie") == false then return 0 end
	local halo_data = HaloData.Instance
	local is_can_active_jinjie_reward = JinJieRewardData.Instance:SystemIsShowRedPoint(JINJIE_TYPE.JINJIE_TYPE_HALO)
	if (halo_data:CanHuanhuaUpgrade() == true
		or halo_data:CanShowRed()
		or halo_data:IsShowZizhiRedPoint() or next(halo_data:CanSkillUpLevelList()) ~= nil )
		or halo_data:CalAllEquipRemind() > 0
		or is_can_active_jinjie_reward == true then
		return 1
	end
	return 0
end

function AdvanceData:CalcFaBaoRemind()
	if OpenFunData.Instance:CheckIsHide("fabao_jinjie") == false then return 0 end
	local fabao_data = FaBaoData.Instance
	local is_can_active_jinjie_reward = JinJieRewardData.Instance:SystemIsShowRedPoint(JINJIE_TYPE.JINJIE_TYPE_FABAO)
	if (fabao_data:CanHuanhuaUpgrade() == true
		or fabao_data:CanShowRed()
		or fabao_data:IsShowZizhiRedPoint() or next(fabao_data:CanSkillUpLevelList()) ~= nil )
		or fabao_data:CalAllEquipRemind() > 0
		or is_can_active_jinjie_reward == true then
		return 1
	end
	return 0
end

function AdvanceData:CalcFootRemind()
	if OpenFunData.Instance:CheckIsHide("foot_jinjie") == false then return 0 end
	local foot_data = FootData.Instance
	local is_can_active_jinjie_reward = JinJieRewardData.Instance:SystemIsShowRedPoint(JINJIE_TYPE.JINJIE_TYPE_FOOTPRINT)
	if (foot_data:CanHuanhuaUpgrade() == true
		or foot_data:CanShowRed()
		or foot_data:IsShowZizhiRedPoint() or next(foot_data:CanSkillUpLevelList()) ~= nil )
		or foot_data:CalAllEquipRemind() > 0
		or is_can_active_jinjie_reward == true then
		return 1
	end
	return 0
end

function AdvanceData:CalcWuQiRemind()
	if OpenFunData.Instance:CheckIsHide("player_role_shenbing") == false then return 0 end
	local wuqi_data = FashionData.Instance
	local is_can_active_jinjie_reward = JinJieRewardData.Instance:SystemIsShowRedPoint(JINJIE_TYPE.JINJIE_TYPE_SHENBING)
	if wuqi_data:CanWuQiHuanhuaUpgrade() == true
		or wuqi_data:CanShowRed2() 
		or wuqi_data:IsShowZizhiRedPoint() 
		or next(wuqi_data:CanSkillUpLevelListOne()) ~= nil 
		or wuqi_data:CalAllEquipRemind() > 0
		or is_can_active_jinjie_reward == true then
		return 1
	end
	return 0
end

function AdvanceData:CalcLingRenRemind()
	return LingRenData.Instance:GetRemind()
end

function AdvanceData:CalAdvanceEquipRemind()
	local index = self:GetEquipType()
	if index == TabIndex.mount_jinjie then
		return MountData.Instance:CalAllEquipRemind() > 0 and 1 or 0
	elseif index == TabIndex.wing_jinjie then
		return WingData.Instance:CalAllEquipRemind() > 0 and 1 or 0
	elseif index == TabIndex.halo_jinjie then
		return HaloData.Instance:CalAllEquipRemind() > 0 and 1 or 0
	elseif index == TabIndex.fabao_jinjie then
		return FaBaoData.Instance:CalAllEquipRemind() > 0 and 1 or 0
	elseif index == TabIndex.fight_mount then
		return FightMountData.Instance:CalAllEquipRemind() > 0 and 1 or 0
	elseif index == TabIndex.goddess_shengong then
		return ShengongData.Instance:CalAllEquipRemind() > 0 and 1 or 0
	elseif index == TabIndex.goddess_shenyi then
		return ShenyiData.Instance:CalAllEquipRemind() > 0 and 1 or 0
	elseif index == TabIndex.foot_jinjie then
		return FootData.Instance:CalAllEquipRemind() > 0 and 1 or 0
	elseif index == TabIndex.fashion_jinjie then
		return FashionData.Instance:CalAllFashionEquipRemind() > 0 and 1 or 0
	elseif index == TabIndex.role_shenbing then
		return FashionData.Instance:CalAllEquipRemind() > 0 and 1 or 0
	end
end

function AdvanceData:GetHuanhuaRemind()
	local index = self:GetHuanHuaType()
	if index == TabIndex.mount_huan_hua then
		return MountData.Instance:CanHuanhuaUpgrade() == true and 1 or 0
	elseif index == TabIndex.wing_huan_hua then
		return WingData.Instance:CanHuanhuaUpgrade() == true and 1 or 0
	elseif index == TabIndex.halo_huan_hua then
		return HaloData.Instance:CanHuanhuaUpgrade() == true and 1 or 0
	elseif index == TabIndex.foot_huan_hua then
		return FootData.Instance:CanHuanhuaUpgrade() == true and 1 or 0
	elseif index == TabIndex.fight_mount_huan_hua then
		return FightMountData.Instance:CanHuanhuaUpgrade() == true and 1 or 0
	elseif index == TabIndex.fabao_huan_hua then
		return FaBaoData.Instance:CanHuanhuaUpgrade() == true and 1 or 0
	elseif index == TabIndex.fashion_huan_hua then
		return FashionData.Instance:CanFashionHuanhuaUpgrade() == true and 1 or 0
	elseif index == TabIndex.wuqi_huan_hua then
		return FashionData.Instance:CanWuQiHuanhuaUpgrade() == true and 1 or 0
	end
end

function AdvanceData:GetShenCiWingHuanhuaRemind()
	return WingData.Instance:CanShenCiHuanhuaUpgrade() == true and 1 or 0
end

function AdvanceData:GetShenCiFightMountHuanhuaRemind()
	return FightMountData.Instance:CanShenCiHuanhuaUpgrade() == true and 1 or 0
end

function AdvanceData:CalcFashionRemind()
	local fashion_data = FashionData.Instance
	local is_can_active_jinjie_reward = JinJieRewardData.Instance:SystemIsShowRedPoint(JINJIE_TYPE.JINJIE_TYPE_FASHION)
	if is_can_active_jinjie_reward == true
		or fashion_data:CanShowRed()
		or fashion_data:IsShowFashionZizhiRedPoint() 
		or next(fashion_data:CanFashionSkillUpLevelList()) ~= nil 
		or fashion_data:CalAllFashionEquipRemind() > 0 
		or fashion_data:CanFashionHuanhuaUpgrade() == true then
		return 1
	end
	return 0
end

function AdvanceData:IsShowShengongRedPoint()
	local shengong_data = ShengongData.Instance
	local is_can_active_jinjie_reward = JinJieRewardData.Instance:SystemIsShowRedPoint(JINJIE_TYPE.JINJIE_TYPE_SHENGONG)
	if shengong_data:CanHuanhuaUpgrade() > 0 or shengong_data:IsShowZizhiRedPoint()
		or next(shengong_data:CanSkillUpLevelList()) ~= nil or self:GetShengongCanJinjie()
		or shengong_data:CalAllEquipRemind() > 0
		or is_can_active_jinjie_reward == true then
		return true
	end
	return false
end

function AdvanceData:IsShowShenyiRedPoint()
	local shenyi_data = ShenyiData.Instance
	local is_can_active_jinjie_reward = JinJieRewardData.Instance:SystemIsShowRedPoint(JINJIE_TYPE.JINJIE_TYPE_SHENYI)
	if shenyi_data:CanHuanhuaUpgrade() > 0 or shenyi_data:IsShowZizhiRedPoint()
		or next(shenyi_data:CanSkillUpLevelList()) ~= nil or self:GetShenyiCanJinjie()
		or shenyi_data:CalAllEquipRemind() > 0
		or is_can_active_jinjie_reward == true then
		return true
	end
	return false
end

function AdvanceData:CalcCloakRemind()
	return CloakData.Instance:GetRemind()
end

function AdvanceData:IsShowHuaShenRedPoint()
	if self:IsShowTopHuashenRedPoint() or self:IsShowHuashenHuanhuaRedPoint() or self:IsShowHuaShenProtectRedPoint() then
		return true
	end
	return false
end

function AdvanceData:CalcFightMountRemind()
	if OpenFunData.Instance:CheckIsHide("fight_mount") == false then return 0 end
	local fight_mount_data = FightMountData.Instance
	local is_can_active_jinjie_reward = JinJieRewardData.Instance:SystemIsShowRedPoint(JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT)
	if (fight_mount_data:CanHuanhuaUpgrade() == true or fight_mount_data:CanShenCiHuanhuaUpgrade()
		or fight_mount_data:CanShowRed() or next(fight_mount_data:CanSkillUpLevelList()) ~= nil
		or fight_mount_data:IsShowZizhiRedPoint())
		or fight_mount_data:CalAllEquipRemind() > 0
		or is_can_active_jinjie_reward == true then
		return 1
	end
	return 0
end

function AdvanceData:IsShowTopHuashenRedPoint()
	for i = 0, GameEnum.HUASHEN_MAX_ID - 1 do
		local level_info_list = HuashenData.Instance:GetHuashenInfo().level_info_list
		if not level_info_list then return end

		local level = level_info_list[i] and level_info_list[i].level or 0
		level = (level ~= 0) and level or 1
		local level_cfg = HuashenData.Instance:GetHuashenLevelCfg(i, level)
		if level_cfg and level_cfg.stuff_id then
			if ItemData.Instance:GetItemNumInBagById(level_cfg.stuff_id) > 0 then
				return true
			end
		end
	end
	return false
end

function AdvanceData:IsShowHuashenHuanhuaRedPoint()
	for i = 0, GameEnum.HUASHEN_MAX_ID - 1 do
		local huashen_info = HuashenData.Instance:GetHuashenInfo()
		local grade_list = huashen_info.grade_list
		local activie_flag = huashen_info.activie_flag
		if not grade_list or not activie_flag then return end

		local level = grade_list[i] and grade_list[i] or 0
		level = (level ~= 0) and level or 1
		local image_cfg = HuashenData.Instance:GetHuashenImageCfg(i, level)
		if image_cfg and image_cfg.stuff_id then
			local image_info = HuashenData.Instance:GetHuashenInfoCfg()[i]
			local data = (1 == activie_flag[i]) and image_cfg or image_info
			local item_id = (1 == activie_flag[i]) and image_cfg.stuff_id or image_info.item_id
			local need_num = (1 == activie_flag[i]) and image_cfg.stuff_num or 1
			if ItemData.Instance:GetItemNumInBagById(item_id) >= need_num then
				return true
			end
		end
	end
	return false
end

function AdvanceData:IsShowHuaShenProtectRedPoint()
	for i = 0, GameEnum.HUASHEN_MAX_ID - 1 do
		for j = 0, GameEnum.HUASHEN_SPIRIT_MAX_ID_LIMIT - 1 do
			local protect_cfg = HuashenData.Instance:GetHuashenProtectLevelCfg(i, j)
			if protect_cfg and protect_cfg.consume_item_id then
				if ItemData.Instance:GetItemNumInBagById(protect_cfg.consume_item_id) > 0 then
					return true
				end
			end
		end
	end
	return false
end

function AdvanceData:GetDefaultOpenView()
	local default_open = ""
	local open_data = OpenFunData.Instance
	local list = {
		"mount_jinjie",
		"wing_jinjie",
		"fashion_jinjie", 
		"immortals_jinjie", 
		"fabao_jinjie",  
		"halo_jinjie", 
		"foot_jinjie", 
		"fight_mount", 
		"role_shenbing"
	}
	for k,v in pairs(list) do
		if open_data:CheckIsHide(v) then
			default_open = v
			return default_open
		end
	end
	return default_open
end

function AdvanceData:GetEquipSkill(skill_type, skill_level)
	if nil == self.equip_skill_cfg[skill_type] then
		return
	end
	return self.equip_skill_cfg[skill_type][skill_level]
end

function AdvanceData:IsOpenEquip(tab_index)
	if tab_index == TabIndex.mount_jinjie then
		return MountData.Instance:IsOpenEquip()
	end

	if tab_index == TabIndex.wing_jinjie then
		return WingData.Instance:IsOpenEquip()
	end

	if tab_index == TabIndex.halo_jinjie then
		return HaloData.Instance:IsOpenEquip()
	end

	if tab_index == TabIndex.fabao_jinjie then
		return FaBaoData.Instance:IsOpenEquip()
	end

	if tab_index == TabIndex.foot_jinjie then
		return FootData.Instance:IsOpenEquip()
	end

	if tab_index == TabIndex.fight_mount then
		return FightMountData.Instance:IsOpenEquip()
	end

	if tab_index == TabIndex.fashion_jinjie then
		return FashionData.Instance:IsOpenFashionEquip()
	end

	if tab_index == TabIndex.role_shenbing then
		return FashionData.Instance:IsOpenEquip()
	end

	if tab_index == TabIndex.goddess_shengong then
		return ShengongData.Instance:IsOpenEquip()
	end

	if tab_index == TabIndex.goddess_shenyi then
		return ShenyiData.Instance:IsOpenEquip()
	end

	return false, 0
end

function AdvanceData:GetJinjieSkillTotalCount()
	local oount = 0
	if MountData.Instance:IsActiveEquipSkill() then
		oount = oount + 1
	end

	if WingData.Instance:IsActiveEquipSkill() then
		oount = oount + 1
	end

	if HaloData.Instance:IsActiveEquipSkill() then
		oount = oount + 1
	end

	if FightMountData.Instance:IsActiveEquipSkill() then
		oount = oount + 1
	end

	if ShengongData.Instance:IsActiveEquipSkill() then
		oount = oount + 1
	end

	if ShenyiData.Instance:IsActiveEquipSkill() then
		oount = oount + 1
	end

	if FootData.Instance:IsActiveEquipSkill() then
		oount = oount + 1
	end
	return oount
end

function AdvanceData:GetJinjieGaugeCount(skill_count)
	skill_count = skill_count or self:GetJinjieSkillTotalCount()

	if nil == self.equip_skill_gauge_cfg[skill_count] then
		return -1
	end
	return self.equip_skill_gauge_cfg[skill_count].gauge
end

function AdvanceData:GetEquipSkillResPath(skill_type)
	local asset = JINJIE_SKILL_ICON_ASSET[skill_type]
	return ResPath.GetSkillIcon(asset)
end
function AdvanceData:SetImageFulingType(advance_type)
	self.image_fuling_type = advance_type
end

function AdvanceData:GetImageFulingType()
	return self.image_fuling_type
end

function AdvanceData:SetEquipType(advance_type)
	self.advance_equip_type = advance_type or 0
end

function AdvanceData:GetEquipType()
	return self.advance_equip_type
end

function AdvanceData:SetHuanHuaType(advance_type)
	self.advance_type = advance_type
end

function AdvanceData:GetHuanHuaType()
	return self.advance_type
end

function AdvanceData:AdvanceInfo()
	self.advance_type = self.advance_type or TabIndex.mount_huan_hua
	local info_list = {}
	if self.advance_type == TabIndex.mount_huan_hua then
		info_list = MountData.Instance:GetMountInfo()
	elseif self.advance_type == TabIndex.wing_huan_hua then
		info_list = WingData.Instance:GetWingInfo()
	elseif self.advance_type == TabIndex.halo_huan_hua then
		info_list = HaloData.Instance:GetHaloInfo()
	elseif self.advance_type == TabIndex.foot_huan_hua then
		info_list = FootData.Instance:GetFootInfo()
	elseif self.advance_type == TabIndex.fight_mount_huan_hua then
		info_list = FightMountData.Instance:GetFightMountInfo()
	elseif self.advance_type == TabIndex.fabao_huan_hua then
		info_list = FaBaoData.Instance:GetFaBaoInfo()
	elseif self.advance_type == TabIndex.fashion_huan_hua then
		info_list =FashionData.Instance:GetFashionInfo()
	elseif self.advance_type == TabIndex.wuqi_huan_hua then
		info_list = FashionData.Instance:GetWuQiInfo()
	end
	return info_list
end

-- 根据不同的幻化面板返回不同Icon
function AdvanceData:GetTabIcon()
	local bundle, asset = "uis/images_atlas", "tab_icon_mount"

	if self.advance_type == TabIndex.wing_huan_hua then
		asset = "tab_icon_wing"
	elseif self.advance_type == TabIndex.halo_huan_hua then
		asset = "tab_icon_halo"
	elseif self.advance_type == TabIndex.foot_huan_hua then
		asset = "tab_icon_foot"
	elseif self.advance_type == TabIndex.fight_mount_huan_hua then
		asset = "tab_icon_fightmount"
	elseif self.advance_type == TabIndex.fabao_huan_hua then
		asset = "tab_icon_fabao"
	elseif self.advance_type == TabIndex.fashion_huan_hua then
		asset = "tab_icon_fashion"
	elseif self.advance_type == TabIndex.wuqi_huan_hua then
		asset = "tab_icon_wuqi"
	end

	return bundle, asset

end

function AdvanceData:GetSpecialAttrActiveType(config, cur_grade, index)
	local active_grade, attr_type, attr_value
	for i, v in ipairs(config) do
		if nil == index or (index and v.special_img_id == index) then
			for key, value in pairs(v) do
				if nil ~= Language.Advance.SpecialAttr[key] then
					if value > 0 then
						active_grade = v.grade or v.level
						attr_type = key
						attr_value = value
						break
					end
				end
			end
			if active_grade then
				break
			end
		end
	end
	if nil == active_grade or nil == attr_type or nil == attr_value then return end
	if nil ~= index then
		if cur_grade >= active_grade then
			for i, v in ipairs(config) do
				if v.special_img_id == index then
					if v.grade == cur_grade then
						attr_value = v[attr_type]
						break
					else
						attr_value = nil
					end
				end
			end
			return cur_grade, attr_type, attr_value
		else
			return active_grade, attr_type, attr_value
		end
	else
		if cur_grade >= active_grade then
			if config[cur_grade] then
				attr_value = config[cur_grade][attr_type]
			else
				attr_value = nil
			end
			return cur_grade, attr_type, attr_value
		else
			return active_grade, attr_type, attr_value
		end
	end
end

function AdvanceData:GetBlessBaojiCfg(upgrade_type)
	return self.bless_baoji_type_cfg[upgrade_type]
end

function AdvanceData:GetShuXingDanCfg(upgrade_type)
	return self.shuxingdan_cfg[upgrade_type]
end

function AdvanceData:GetAdvanceInfo(use_type, param1)
	local active_flag = nil
	if use_type == JUMP_MODLE_TYPE.WING_HUAN_HUA then
		local info_list = WingData.Instance:GetWingInfo()
		active_flag = info_list.active_special_image_flag
	elseif use_type == JUMP_MODLE_TYPE.MOUNT_HUAN_HUA then
		local info_list = MountData.Instance:GetMountInfo()
		active_flag = info_list.active_special_image_flag
	elseif use_type == JUMP_MODLE_TYPE.FASHION_HUAN_HUA then
		active_flag = FashionData.Instance:GetSpecialActiveFlag()
		if param1 and param1 == 0 then
			active_flag = FashionData.Instance:GetWuQiSpecialActiveFlag()
		end
	elseif use_type == JUMP_MODLE_TYPE.HALO_HUAN_HUA then
		local info_list = HaloData.Instance:GetHaloInfo()
		active_flag = info_list.active_special_image_flag
	elseif use_type == JUMP_MODLE_TYPE.FIGHT_MOUNT_HUAN_HUA then
		local info_list = FightMountData.Instance:GetFightMountInfo()
		active_flag = info_list.active_special_image_flag
	elseif use_type == JUMP_MODLE_TYPE.FOOT_HUAN_HUA then
		local info_list = FootData.Instance:GetFootInfo()
		active_flag = info_list.active_special_image_flag
	elseif use_type == JUMP_MODLE_TYPE.FABAO_HUANHUA then
		local info_list = FaBaoData.Instance:GetFaBaoInfo()
		active_flag = info_list.active_special_image_flag
	end
	return active_flag
end


function AdvanceData:GetJumpInfo(jump_type, param1)
	local jump_info = {}

	local tabIndex = nil
	local fulingType = nil
	local flush_view = ""
	local open_model = nil
	local talent_type = nil

	if jump_type == JUMP_MODLE_TYPE.MOUNT_HUAN_HUA then
		tabIndex = TabIndex.mount_huan_hua
		fulingType = IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_MOUNT
		flush_view = "mounthuanhua"
		talent_type = TALENT_TYPE.TALENT_MOUNT
	elseif jump_type == JUMP_MODLE_TYPE.WING_HUAN_HUA then
		tabIndex = TabIndex.wing_huan_hua
		fulingType = IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_WING
		flush_view = "winghuanhua"
		talent_type = TALENT_TYPE.TALENT_WING
	elseif jump_type == JUMP_MODLE_TYPE.FASHION_HUAN_HUA then
		tabIndex = TabIndex.fashion_huan_hua
		fulingType = IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_SHENGONG
		flush_view = "fashionhuanhua"
		talent_type = TALENT_TYPE.TALENT_SHENGGONG
		if param1 and param1 == 0 then
			tabIndex = TabIndex.wuqi_huan_hua
			fulingType = IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_SHENYI
			flush_view = "wuqihuanhuaview"
			talent_type = TALENT_TYPE.TALENT_SHENYI
		end
	elseif jump_type == JUMP_MODLE_TYPE.HALO_HUAN_HUA then
		tabIndex = TabIndex.halo_huan_hua
		fulingType = IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_HALO
		flush_view = "halohuanhua"
		talent_type = TALENT_TYPE.TALENT_HALO
	elseif jump_type == JUMP_MODLE_TYPE.FIGHT_MOUNT_HUAN_HUA then
		tabIndex = TabIndex.fight_mount_huan_hua
		fulingType = IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_FIGHT_MOUNT
		flush_view = "fightmounthuanhua"
		talent_type = TALENT_TYPE.TALENT_FIGHTMOUNT
	elseif jump_type == JUMP_MODLE_TYPE.FOOT_HUAN_HUA then
		tabIndex = TabIndex.foot_huan_hua
		fulingType = IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_FOOT_PRINT
		flush_view = "foothuanhua"
		talent_type = TALENT_TYPE.TALENT_FOOTPRINT
	elseif jump_type == JUMP_MODLE_TYPE.FABAO_HUANHUA then
		tabIndex = TabIndex.fabao_huan_hua
		fulingType = IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_FABAO
		flush_view = "fabaohuanhua"
		talent_type = TALENT_TYPE.TALENT_FABAO
	end
	jump_info.tabIndex = tabIndex
	jump_info.fulingType = fulingType
	jump_info.flush_view = flush_view
	jump_info.talent_type = talent_type
	return jump_info
end


function AdvanceData:GetjumpModel(item_cfg)
	local is_advance = false
	local is_jump = false
	local model_name = nil
	local is_advane_type = false
	if item_cfg.use_type then
		if item_cfg.use_type == JUMP_MODLE_TYPE.WAIST_HUANHUA then
			local is_active = WaistData.Instance:GetHuanHuaIsActiveByImageId(item_cfg.param1)
			if is_active then
				is_jump = true
			end
			model_name = ViewName.WaistHuanHua
			is_advane_type = true
		elseif item_cfg.use_type == JUMP_MODLE_TYPE.TOUSHI_HUANHUA then
			local is_active = TouShiData.Instance:GetHuanHuaIsActiveByImageId(item_cfg.param1)
			if is_active then
				is_jump = true
			end
			model_name = ViewName.TouShiHuanHua
			is_advane_type = true
		elseif item_cfg.use_type == JUMP_MODLE_TYPE.MASK_HUANHUA then
			local is_active = MaskData.Instance:GetHuanHuaIsActiveByImageId(item_cfg.param1)
			if is_active then
				is_jump = true
			end
			model_name = ViewName.MaskHuanHua
			is_advane_type = true
		elseif item_cfg.use_type == JUMP_MODLE_TYPE.QILINBI_HUANHUA then
			local is_active = QilinBiData.Instance:GetHuanHuaIsActiveByImageId(item_cfg.param1)
			if is_active then
				is_jump = true
			end
			model_name = ViewName.QilinBiHuanHua
			is_advane_type = true
		elseif item_cfg.use_type == JUMP_MODLE_TYPE.GODDESS_HALO then
			local bit_list = ShengongData.Instance:GetBitFlag()
			if bit_list[item_cfg.param1] == 1 then
				is_jump = true
			end
			model_name = ViewName.ShengongHuanHua
			is_advane_type = true
		elseif item_cfg.use_type == JUMP_MODLE_TYPE.GODDESS_FRONT then
			local bit_list = ShenyiData.Instance:GetBitFlag()
			if bit_list[item_cfg.param1] == 1 then
				is_jump = true
			end		
			model_name = ViewName.ShenyiHuanHua
			is_advane_type = true
		elseif item_cfg.use_type == JUMP_MODLE_TYPE.GODDESS_HUANHUA then
			local huanhua_flag_list = GoddessData.Instance:GetXianNvHuanHuaFlag()
			if huanhua_flag_list[item_cfg.param1] == 1 then
				is_jump = true
			end
			model_name = ViewName.GoddessHuanHua
			is_advane_type = true
		elseif item_cfg.use_type == JUMP_MODLE_TYPE.SPIRIT_HUANHUA then
			local spirit_info = SpiritData.Instance:GetSpiritInfo()
			local bit_list = spirit_info.special_img_active_flag
			if  bit_list[item_cfg.param1] and bit_list[item_cfg.param1] == 1 then
				is_jump = true
			end
			model_name = ViewName.SpiritHuanHuaView
			is_advane_type = true
		elseif item_cfg.use_type == JUMP_MODLE_TYPE.LING_HUANHUA then
			if item_cfg.param1 == JUMP_PARAM1_TYPE.LINGZHU then
				is_active = LingZhuData.Instance:GetHuanHuaIsActiveByImageId(item_cfg.param2)
				model_name = ViewName.LingZhuHuanHua
				is_advane_type = true
			elseif item_cfg.param1 == JUMP_PARAM1_TYPE.XIANBAO then
				is_active = XianBaoData.Instance:GetHuanHuaIsActiveByImageId(item_cfg.param2)
				model_name = ViewName.XianBaoHuanHua
				is_advane_type = true
			elseif item_cfg.param1 == JUMP_PARAM1_TYPE.LINGCHONG then
				is_active = LingChongData.Instance:GetHuanHuaIsActiveByImageId(item_cfg.param2)
				model_name = ViewName.LingChongHuanHua
				is_advane_type = true
			elseif item_cfg.param1 == JUMP_PARAM1_TYPE.LINGGONG then
				is_active = LingGongData.Instance:GetHuanHuaIsActiveByImageId(item_cfg.param2)
				model_name = ViewName.LingGongHuanHua
				is_advane_type = true
			elseif item_cfg.param1 == JUMP_PARAM1_TYPE.LINGQQ then
				is_active = LingQiData.Instance:GetHuanHuaIsActiveByImageId(item_cfg.param2)
				model_name = ViewName.LingQiHuanHua
				is_advane_type = true
			elseif item_cfg.param1 == JUMP_PARAM1_TYPE.WEIYAN then
				is_active = WeiYanData.Instance:GetHuanHuaIsActiveByImageId(item_cfg.param2)
				model_name = ViewName.WeiYanHuanHua
				is_advane_type = true
			elseif item_cfg.param1 == JUMP_PARAM1_TYPE.SHOUHUAN then
				is_active = ShouHuanData.Instance:GetHuanHuaIsActiveByImageId(item_cfg.param2)
				model_name = ViewName.ShouHuanHuanHua
				is_advane_type = true
			elseif item_cfg.param1 == JUMP_PARAM1_TYPE.TAIl then
				is_active = TailData.Instance:GetHuanHuaIsActiveByImageId(item_cfg.param2)
				model_name = ViewName.TailHuanHua
				is_advane_type = true
			elseif item_cfg.param1 == JUMP_PARAM1_TYPE.FLYPEt then
				is_active = FlyPetData.Instance:GetHuanHuaIsActiveByImageId(item_cfg.param2)
				model_name = ViewName.FlyPetHuanHua
				is_advane_type = true
			end
			if is_active then
				is_jump = true
			end
		else
			local active_flag = self:GetAdvanceInfo(item_cfg.use_type, item_cfg.param1)
			if active_flag then
				if item_cfg.use_type == JUMP_MODLE_TYPE.FASHION_HUAN_HUA then
					if 1 == active_flag[item_cfg.param2] then
						is_advance = true
					end
				elseif item_cfg.use_type == JUMP_MODLE_TYPE.FABAO_HUANHUA then
					if 1 == active_flag[math.fmod(item_cfg.param1, 1000)] then
						is_advance = true
					end
				else
					if 1 == active_flag[item_cfg.param1] then
						is_advance = true
					end
				end
				is_advane_type = true
			end
		end
	end
	return is_advance, is_jump, model_name, is_advane_type
end

--------------------------------------
-- 获取系统对应的直升丹ID
function AdvanceData:GetSystemTypeJinJieItem(system_type, item_type)
	local type_to_id = {
		[JINJIE_TYPE.JINJIE_TYPE_MOUNT] = {[1] = 24835, [2] = 24900, [3] = 24011},
		[JINJIE_TYPE.JINJIE_TYPE_WING] = {[1] = 24836, [2] = 24901, [3] = 24105},
		[JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT] = {[1] = 24842, [2] = 24907, [3] = 25092},
		[JINJIE_TYPE.JINJIE_TYPE_LINGCHONG] = {[1] = 24847, [2] = 24912, [3] = 22573},
		[JINJIE_TYPE.JINJIE_TYPE_FABAO] = {[1] = 24839, [2] = 24904, [3] = 22555},
		[JINJIE_TYPE.JINJIE_TYPE_FLYPET] = {[1] = 24856, [2] = 24920, [3] = 25056},
		[JINJIE_TYPE.JINJIE_TYPE_HALO] = {[1] = 24841, [2] = 24906, [3] = 22546},
		[JINJIE_TYPE.JINJIE_TYPE_LINGQI] = {[1] = 24852, [2] = 24916, [3] = 22591},
		[JINJIE_TYPE.JINJIE_TYPE_WEIYAN] = {[1] = 24853, [2] = 24917, [3] = 22590},
		[JINJIE_TYPE.JINJIE_TYPE_QILINBI] = {[1] = 24846, [2] = 24911, [3] = 22692},
		[JINJIE_TYPE.JINJIE_TYPE_SHENGONG] = {[1] = 24857, [2] = 24921, [3] = 22560},
		[JINJIE_TYPE.JINJIE_TYPE_FOOTPRINT] = {[1] = 24840, [2] = 24905, [3] = 24992},
		[JINJIE_TYPE.JINJIE_TYPE_LINGGONG] = {[1] = 24848, [2] = 24913, [3] = 22574},
		[JINJIE_TYPE.JINJIE_TYPE_SHENYI] = {[1] = 24858, [2] = 24922, [3] = 22565},
		[JINJIE_TYPE.JINJIE_TYPE_FASHION] = {[1] = 24837, [2] = 24902, [3] = 22635},
		[JINJIE_TYPE.JINJIE_TYPE_SHENBING] = {[1] = 24838, [2] = 24903, [3] = 22635},
		[JINJIE_TYPE.JINJIE_TYPE_MASK] = {[1] = 24844, [2] = 24909, [3] = 22635},
		[JINJIE_TYPE.JINJIE_TYPE_TOUSHI] = {[1] = 24843, [2] = 24908, [3] = 22635},
		[JINJIE_TYPE.JINJIE_TYPE_YAOSHI] = {[1] = 24845, [2] = 24910, [3] = 22635},
		[JINJIE_TYPE.JINJIE_TYPE_LINGZHU] = {[1] = 24850, [2] = 24914, [3] = 22635},
		[JINJIE_TYPE.JINJIE_TYPE_XIANBAO] = {[1] = 24851, [2] = 24915, [3] = 22635},
	} 
	return type_to_id[system_type] and type_to_id[system_type][item_type] or nil
end

-- 是否当天比拼类型
function AdvanceData:GetIsBiPinSystemType(system_type)
	local PaiHangBang_Index = {
		-- 开服比拼活动(目前只开14个，注释后面两个)
		RANK_TAB_TYPE.MOUNT,			-- 坐骑进阶榜(开服活动)
		RANK_TAB_TYPE.WING,				-- 羽翼进阶榜(开服活动)
		RANK_TAB_TYPE.FIGHT_MOUNT,		-- 战骑战力榜(开服活动)
		RANK_TAB_TYPE.LINGTONG,			-- 灵童进阶榜(开服活动)
		RANK_TAB_TYPE.FABAO,			-- 法宝进阶榜(开服活动)
		RANK_TAB_TYPE.FLYPET,			-- 飞宠进阶榜(开服活动)
		RANK_TAB_TYPE.HALO,				-- 光环进阶榜(开服活动)
		RANK_TAB_TYPE.LINGQI,			-- 灵骑进阶榜(开服活动)
		RANK_TAB_TYPE.WEIYAN,			-- 尾焰进阶榜(开服活动)
		RANK_TAB_TYPE.QILINBI,			-- 麒麟臂进阶榜(开服活动)
		RANK_TAB_TYPE.SHENGONG,			-- 神弓仙环进阶榜(开服活动)
		RANK_TAB_TYPE.FOOT,				-- 足迹进阶榜(开服活动)
		RANK_TAB_TYPE.LINGGONG,			-- 灵弓进阶榜(开服活动)
		RANK_TAB_TYPE.SHENYI,			-- 神翼仙阵进阶榜(开服活动)
	}
	local BiPinType_To_JinJieType = {
		[RANK_TAB_TYPE.MOUNT] = JINJIE_TYPE.JINJIE_TYPE_MOUNT,	
		[RANK_TAB_TYPE.WING] = JINJIE_TYPE.JINJIE_TYPE_WING,		
		[RANK_TAB_TYPE.FIGHT_MOUNT] = JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT,
		[RANK_TAB_TYPE.LINGTONG] = JINJIE_TYPE.JINJIE_TYPE_LINGCHONG,	
		[RANK_TAB_TYPE.FABAO] = JINJIE_TYPE.JINJIE_TYPE_FABAO,	
		[RANK_TAB_TYPE.FLYPET] = JINJIE_TYPE.JINJIE_TYPE_FLYPET,	
		[RANK_TAB_TYPE.HALO] = JINJIE_TYPE.JINJIE_TYPE_HALO,		
		[RANK_TAB_TYPE.LINGQI] = JINJIE_TYPE.JINJIE_TYPE_LINGQI,	
		[RANK_TAB_TYPE.WEIYAN] = JINJIE_TYPE.JINJIE_TYPE_WEIYAN,	
		[RANK_TAB_TYPE.QILINBI] = JINJIE_TYPE.JINJIE_TYPE_QILINBI,	
		[RANK_TAB_TYPE.SHENGONG] = JINJIE_TYPE.JINJIE_TYPE_SHENGONG,	
		[RANK_TAB_TYPE.FOOT] = JINJIE_TYPE.JINJIE_TYPE_FOOTPRINT,		
		[RANK_TAB_TYPE.LINGGONG] = JINJIE_TYPE.JINJIE_TYPE_LINGGONG,	
		[RANK_TAB_TYPE.SHENYI] = JINJIE_TYPE.JINJIE_TYPE_SHENYI,	
	}

	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local cur_bipin_type  = PaiHangBang_Index[cur_day] or (-1)
	local cur_jinjie_type = BiPinType_To_JinJieType[cur_bipin_type] or (-1)

	return system_type == cur_jinjie_type
end
