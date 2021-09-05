-------------------------------------------
-- 管理主角数据
-------------------------------------------
PlayerData = PlayerData or BaseClass(BaseEvent)

PlayerDataReNameItemId = {
	ItemId = 26918
}

local BAG_MAX_GRID_NUM = 200			-- 最大格子数

PlayerData.TweenPosition = {
	Up = Vector3(-560, 480, 0),
	Left = Vector3(-838, 0, 0),
	Right = Vector3(729, -24, 0),
	Down = Vector3(-250, -432, 0),
	UpDown = Vector3(0, -384, 0),
	DownUp = Vector3(0, -480, 0),
	Up2 = Vector3(-560, 368, 0),
	Down2 = Vector3(-560, -658, 0),
}

ImpGuardData = {
	IMP_GUARD_GRID_INDEX_MAX = 2,
}

SEAL_RESOLVE_REMIND_NUM = 20
PlayerData.ATTR_EVENT = "role_attr_event"	--角色属性变化

function PlayerData:__init()
	if PlayerData.Instance then
		print_error("[PlayerData] Attempt to create singleton twice!")
		return
	end
	PlayerData.Instance = self
	self:AddEvent(PlayerData.ATTR_EVENT)
	self.is_return = false
	self.role_info_is_ok = false
	self.role_vo = GameVoManager.Instance:GetMainRoleVo()
	self.exp_extra_per = 0
	RemindManager.Instance:Register(RemindName.PlayerInfo, BindTool.Bind(self.GetPlayerInfoRemind, self))
	RemindManager.Instance:Register(RemindName.AvatarChange, BindTool.Bind(self.GetAvatarChangeRemind, self))
	RemindManager.Instance:Register(RemindName.BaiZhanEquipUpLevel, BindTool.Bind(self.GetBaiZhanEquipUpLevelRemind, self))
	RemindManager.Instance:Register(RemindName.PlayerShengYin, BindTool.Bind(self.GetShengYinRemind, self))
	RemindManager.Instance:Register(RemindName.XiaoGui, BindTool.Bind(self.GetShowXiaoGui, self))
	self.cur_chapter = 0
	self.old_chapter = 0
	self.goal_data_list = {}
	self.field_goal_can_fetch_flag = 0
	self.field_goal_fetch_flag = 0
	self.skill_level_list = {}
	self.seal_backpack_info_list = nil
	self.seal_backpack_info_list2 = {}
	self.seal_slot_info_list = nil 
	self.seal_base_info_list = nil
	self.first_entry = true
	self.seal_cfg_auto = ConfigManager.Instance:GetAutoConfig("seal_cfg_auto")					-- 圣印属性Cfg
	self.seal_suit_client_show = ListToMap(self.seal_cfg_auto.client_show, "suit_type")
	self.seal_suit_type_list = ListToMap(self.seal_cfg_auto.suit, "suit_type", "same_order_num")
	self.seal_suit_part_list = ListToMap(self.seal_cfg_auto.suit_part_list, "suit_type", "equip_order","equip_part")
	self.seal_initial_score = ListToMap(self.seal_cfg_auto.initial_score, "color")
	self.zhuanzhieuqip_auto_cfg = ConfigManager.Instance:GetAutoConfig("zhuanzhicfg_auto")
	self.zhuanzhi_limit_prof_name = ListToMap(self.zhuanzhieuqip_auto_cfg.prof_name, "prof", "zhuan_num")
end

function PlayerData:__delete()
	RemindManager.Instance:UnRegister(RemindName.PlayerInfo)
	RemindManager.Instance:UnRegister(RemindName.AvatarChange)
	RemindManager.Instance:UnRegister(RemindName.BaiZhanEquipUpLevel)
	RemindManager.Instance:UnRegister(RemindName.PlayerShengYin)
	RemindManager.Instance:UnRegister(RemindName.XiaoGui)
	PlayerData.Instance = nil
	if self.tips_show_delay then
		GlobalTimerQuest:CancelQuest(self.tips_show_delay)
		self.tips_show_delay = nil
	end
end

function PlayerData:GetRoleVo()
	return self.role_vo
end

function PlayerData:GetAttr(key)
	return self.role_vo[key]
end

function PlayerData:SetAttr(key, value)
	local old_value = self.role_vo[key]
	self.role_vo[key] = value
	self:NotifyEventChange(PlayerData.ATTR_EVENT, key, value, old_value)
end

function PlayerData:GetDeubgListenCount(t)
	t.attr_listen_count = self:GetTotalEventNum()
end

-- 监听数据改变
function PlayerData:ListenerAttrChange(callback)
	self:AddListener(PlayerData.ATTR_EVENT, callback)
end

-- 取消监听数据改变
function PlayerData:UnlistenerAttrChange(callback)
	self:RemoveListener(PlayerData.ATTR_EVENT, callback)
end

function PlayerData:GetRoleBaseProf(prof)
	prof = prof or self.role_vo.prof
	return prof % 10, math.floor(prof / 10)
end

function PlayerData.GetLevelAndRebirth(level)
	if nil == level then
		return 0, 0
	end
	return (level - 1) % 100 + 1, math.floor((level - 1) / 100)
end

function PlayerData:GetRoleLevel()
	local sub_level, rebirth = PlayerData.GetLevelAndRebirth(self.role_vo.level)
	return self.role_vo.level, sub_level, rebirth
end

function PlayerData.GetLevelString(level, small)
	return string.format(Language.Common.NoZhuan_level, level or 0)
end

-- 根据经验获取当前经验的等级
function PlayerData:GetRoleLevelByExp(exp)
	local role_exp_cfg = ConfigManager.Instance:GetAutoConfig("roleexp_auto").exp_config or {}
	local temp = exp
	for i = self.role_vo.level, #role_exp_cfg do
		if temp >= role_exp_cfg[i].exp then
			temp = temp - role_exp_cfg[i].exp
		else
			return role_exp_cfg[i].level or 1
		end
	end
	return 1
end

-- 获取世界等级经验加成
function PlayerData:GetWorldLevelExpAdd(role_level, world_level)
	local exp_add_percent = 0
	local world_level_cfg = ConfigManager.Instance:GetAutoConfig("world_level_difference_exp_add_config_auto").world_level_difference_exp_add_percent
	local level = world_level - role_level
	if level <= 0 then level = 0 end

	if role_level < world_level and role_level >= COMMON_CONSTS.WORLD_LEVEL_OPEN then
		for k, v in pairs(world_level_cfg) do
			if level >= v.min_level and level <= v.max_level then
				exp_add_percent = v.exp_add_per * 0.01		-- 万分比 客户端显示百分比
				break
			end
		end
	end
	return exp_add_percent
end

--获得职业名字
function PlayerData.GetProfNameByType(prof_type, is_gray)
	local prof_name = ""
	local prof, grade = PlayerData.Instance:GetRoleBaseProf(prof_type)
	if is_gray then
		prof_name = ToColorStr(ZhuanZhiData.Instance:GetProfNameCfg(prof, grade) or "", COLOR.GREY)
	else
		prof_name = ToColorStr(ZhuanZhiData.Instance:GetProfNameCfg(prof, grade) or "", PROF_COLOR[prof])
	end
	return prof_name
end

function PlayerData:RoleInfoIsOk()
	return self.role_info_is_ok
end

function PlayerData:RoleInfoOk()
	self.role_info_is_ok = true
end

function PlayerData:SetExpExtraPer(value)
	self.exp_extra_per = value
end

function PlayerData:GetExpExtraPer()
	return self.exp_extra_per
end

-- 根据属性类型获得属性名字。名字参照game_vo.lua中的RoleVo
local attr_name_list = nil
function PlayerData.GetRoleAttrNameByType(type)
	if attr_name_list == nil then
		attr_name_list = {
			[GameEnum.FIGHT_CHARINTATTR_TYPE_HP] = "hp",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_MP] = "mp",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_MAXHP] = "max_hp",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_MAXMP] = "max_mp",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_GONGJI] = "gong_ji",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_FANGYU] = "fang_yu",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_MINGZHONG] = "ming_zhong",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_SHANBI] = "shan_bi",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_BAOJI] = "bao_ji",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_JIANREN] = "jian_ren",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_MOVE_SPEED] = "move_speed",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_FUJIA_SHANGHAI] = "fujia_shanghai",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_DIKANG_SHANGHAI] = "dikang_shanghai",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_PER_JINGZHUN] = "per_jingzhun",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_PER_BAOJI] = "per_baoji",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_PER_KANGBAO] = "per_kangbao",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_PER_POFANG] = "per_pofang",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_PER_MIANSHANG] = "per_mianshang",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_CONSTANT_ZENGSHANG] = "constant_zengshang",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_CONSTANT_MIANSHANG] = "constant_mianshang",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_HUIXINYIJI] = "huixinyiji",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_HUIXINYIJI_HURT_PER] = "huixinyiji_hurt_per",

			[GameEnum.BASE_CHARINTATTR_TYPE_MAXHP] = "base_max_hp",
			[GameEnum.BASE_CHARINTATTR_TYPE_GONGJI] = "base_gongji",
			[GameEnum.BASE_CHARINTATTR_TYPE_FANGYU] = "base_fangyu",
			[GameEnum.BASE_CHARINTATTR_TYPE_MINGZHONG] = "base_mingzhong",
			[GameEnum.BASE_CHARINTATTR_TYPE_SHANBI] = "base_shanbi",
			[GameEnum.BASE_CHARINTATTR_TYPE_BAOJI] = "base_baoji",
			[GameEnum.BASE_CHARINTATTR_TYPE_JIANREN] = "base_jianren",
			[GameEnum.BASE_CHARINTATTR_TYPE_MOVE_SPEED] = "base_move_speed",
			[GameEnum.BASE_CHARINTATTR_TYPE_FUJIA_SHANGHAI] = "base_fujia_shanghai",
			[GameEnum.BASE_CHARINTATTR_TYPE_DIKANG_SHANGHAI] = "base_dikang_shanghai",
			[GameEnum.BASE_CHARINTATTR_TYPE_PER_JINGZHUN] = "base_per_jingzhun",
			[GameEnum.BASE_CHARINTATTR_TYPE_PER_BAOJI] = "base_per_baoji",
			[GameEnum.BASE_CHARINTATTR_TYPE_PER_KANGBAO] = "base_per_kangbao",
			[GameEnum.BASE_CHARINTATTR_TYPE_PER_POFANG] = "base_per_pofang",
			[GameEnum.BASE_CHARINTATTR_TYPE_PER_MIANSHANG] = "base_per_mianshang",
			[GameEnum.BASE_CHARINTATTR_TYPE_CONSTANT_ZENGSHANG] = "base_constant_zengshang",
			[GameEnum.BASE_CHARINTATTR_TYPE_CONSTANT_MIANSHANG] = "base_constant_mianshang",
			[GameEnum.BASE_CHARINTATTR_TYPE_HUIXINYIJI] = "base_huixinyiji",
			[GameEnum.BASE_CHARINTATTR_TYPE_HUIXINYIJI_HURT_PER] = "base_huixinyiji_hurt_per",
			[GameEnum.SPEICAL_CHARINTATTR_TYPE_PVP_JIANSHANG_PER] = "pvp_jianshang",
			[GameEnum.SPEICAL_CHARINTATTR_TYPE_PVP_ZENGSHANG_PER] = "pvp_zengshang",
			[GameEnum.SPEICAL_CHARINTATTR_TYPE_PVE_JIANSHANG_PER] = "pve_jianshang",
			[GameEnum.SPEICAL_CHARINTATTR_TYPE_PVE_ZENGSHANG_PER] = "pve_zengshang",
			[GameEnum.BASE_CHARINTATTR_TYPE_ZHUFUYIJI_PER] = "base_zhufuyiji_per",
			[GameEnum.BASE_CHARINTATTR_TYPE_SKILL_ZENGSHANG] = "base_skill_zengshang",
			[GameEnum.BASE_CHARINTATTR_TYPE_SKILL_JIANSHANG] = "base_skill_jianshang",
			[GameEnum.BASE_CHARINTATTR_TYPE_MINGZHONG_PER] = "base_mingzhong_per",
			[GameEnum.BASE_CHARINTATTR_TYPE_SHANBI_PER] = "base_shanbi_per",
			[GameEnum.BASE_CHARINTATTR_TYPE_PER_BAOJI_HURT] = "base_per_baoji_hurt",
			[GameEnum.BASE_CHARINTATTR_TYPE_PER_KANGBAO_HURT] = "base_per_kangbao_hurt",
			[GameEnum.BASE_CHARINTATTR_TYPE_GEDANG_PER] = "base_gedang_per",
			[GameEnum.BASE_CHARINTATTR_TYPE_GEDANG_JIANSHANG_PER] = "base_gedang_jianshang",
		}
	end
	return attr_name_list[type] or ""
end
function PlayerData:SetSelectAttrView(index)
	self.type_tip = index 
end
function PlayerData:GetSelectAttrView()
	return self.type_tip 
end
--是否足够绑定和非绑定铜币，优先使用绑定的情况
function PlayerData.GetIsEnoughAllCoin(cost_coin)
	if nil == cost_coin then
		return false
	end
	local coin = PlayerData.Instance.role_vo.coin or 0
	local bind_coin = PlayerData.Instance.role_vo.bind_coin or 0
	local all_coin = coin + bind_coin
	return all_coin >= cost_coin
end

--是否足够绑定和非绑定钻石，优先使用绑定的情况
function PlayerData.GetIsEnoughAllGold(cost_gold)
	if nil == cost_gold then
		return false
	end
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local bind_gold = main_vo.bind_gold
	local gold = main_vo.gold
	local all_gold = bind_gold + gold
	return all_gold >= cost_gold
end

--根据属性类型获得服务端属性名字
function PlayerData:GetServerRoleAttrNameByType(type)
	if self.sever_attr_name == nil then
		self.sever_attr_name = {}
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_HP] = "hp"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_MP] = "mp"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_MAXHP] = "maxhp"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_MAXMP] = "maxmp"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_GONGJI] = "gongji"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_FANGYU] = "fangyu"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_MINGZHONG] = "mingzhong"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_SHANBI] = "shanbi"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_BAOJI] = "baoji"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_JIANREN] = "jianren"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_MOVE_SPEED] = "movespeed"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_FUJIA_SHANGHAI] = "fujia_shanghai"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_DIKANG_SHANGHAI] = "dikang_shanghai"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_PER_JINGZHUN] = "per_jingzhun"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_PER_BAOJI] = "per_baoji"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_PER_KANGBAO] = "per_kangbao"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_PER_POFANG] = "per_pofang"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_PER_MIANSHANG] = "per_mianshang"

		self.sever_attr_name[GameEnum.BASE_CHARINTATTR_TYPE_MAXHP] = "maxhp"
		self.sever_attr_name[GameEnum.BASE_CHARINTATTR_TYPE_GONGJI] = "gongji"
		self.sever_attr_name[GameEnum.BASE_CHARINTATTR_TYPE_FANGYU] = "fangyu"
		self.sever_attr_name[GameEnum.BASE_CHARINTATTR_TYPE_MINGZHONG] = "mingzhong"
		self.sever_attr_name[GameEnum.BASE_CHARINTATTR_TYPE_SHANBI] = "shanbi"
		self.sever_attr_name[GameEnum.BASE_CHARINTATTR_TYPE_BAOJI] = "baoji"
		self.sever_attr_name[GameEnum.BASE_CHARINTATTR_TYPE_JIANREN] = "jianren"
		self.sever_attr_name[GameEnum.BASE_CHARINTATTR_TYPE_MOVE_SPEED] = "move_speed"
		self.sever_attr_name[GameEnum.BASE_CHARINTATTR_TYPE_FUJIA_SHANGHAI] = "fujia_shanghai"
		self.sever_attr_name[GameEnum.BASE_CHARINTATTR_TYPE_DIKANG_SHANGHAI] = "dikang_shanghai"
		self.sever_attr_name[GameEnum.BASE_CHARINTATTR_TYPE_PER_JINGZHUN] = "per_jingzhun"
		self.sever_attr_name[GameEnum.BASE_CHARINTATTR_TYPE_PER_BAOJI] = "per_baoji"
		self.sever_attr_name[GameEnum.BASE_CHARINTATTR_TYPE_PER_KANGBAO] = "per_kangbao"
		self.sever_attr_name[GameEnum.BASE_CHARINTATTR_TYPE_PER_POFANG] = "per_pofang"
		self.sever_attr_name[GameEnum.BASE_CHARINTATTR_TYPE_PER_MIANSHANG] = "per_mianshang"
	end
	return type and self.sever_attr_name[type] or self.sever_attr_name
end

-- 获取角色等级属性经验配置
function PlayerData.GetRoleExpCfgByLv(lv)
	lv = lv or PlayerData.Instance.role_vo.level
	return ConfigManager.Instance:GetAutoConfig("roleexp_auto").exp_config[lv]
end

-- 获取某已转生配置
function PlayerData:GetZsCfgByZsLevel(zhuansheng_level)
	local zhuansheng_cfg = ConfigManager.Instance:GetAutoConfig("zhuansheng_cfg_auto").zhuansheng_attr_cfg
	for k,v in pairs(zhuansheng_cfg) do
		if zhuansheng_level == v.zhuansheng_level then
			return v
		end
	end
	return nil
end

function PlayerData:GetCurLevelzhuan()
	local _, _, cur_zhuan = PlayerData.Instance:GetRoleLevel()
	return cur_zhuan
end

function PlayerData:GetCurLevel()
	local _, cur_level, _ = PlayerData.Instance:GetRoleLevel()
	return cur_level
end

--获取是否可以转生的状态
function PlayerData:GetZhuanShengStatus(cur_zhuan)
	local flag = 0
	local cur_zhuan_cfg = self:GetZsCfgByZsLevel(cur_zhuan)
	local now_level = self:GetCurLevel()
	local next_zhuan_cfg = self:GetZsCfgByZsLevel(cur_zhuan+ 1)

	if next_zhuan_cfg == nil then
		flag = 10000 			--满级
	elseif now_level % 100 ~= 0 then
		flag = 10000 + 1	   --等级不足
	elseif next_zhuan_cfg.nv_wa_shi > PlayerData.Instance.role_vo.nv_wa_shi then
		flag = 10000 + 1 * 10 	--女娲石不足
	elseif not PlayerData.GetIsEnoughAllCoin(next_zhuan_cfg.coin) then
		flag = 10000 + 1 * 100 	--金币不足
	end

	if flag ~= 0 then	--若不能转生直接返回
		return flag
	end

	return flag
end

function PlayerData:CanRebirth()
	local cur_zhuan = self:GetCurLevelzhuan()
	local flag = self:GetZhuanShengStatus(cur_zhuan)
	--满级
	if flag == 10000 then
		return false
	end
	--等级不足
	if flag == 10001 then
		return false
	end
	return true
end

function PlayerData:GetRoleZhanli()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local power = vo.max_hp * 0.1 + vo.gong_ji * 2 + vo.fang_yu * 2 + vo.ming_zhong + vo.shan_bi + vo.bao_ji + vo.jian_ren + GoddessData.Instance:GetXiannvGongji()
	return power
end

function PlayerData:GetPlayerInfoRemind()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	for i = 1, 4 do
		if MojieData.Instance:IsShowMojieRedPoint(i - 1) and vo.level >= 140 then
			return 1
		end
	end
	local num = 0
	num = num + self:GetBaiZhanEquipUpLevelRemind()
	return num
end

function PlayerData:GetAvatarChangeRemind()
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if not OtherData.Instance:CanChangePortrait() then
		--不能更换头像
		return 0
	end
	return (level >= GameEnum.AVTAR_REMINDER_LEVEL and not TipsPortraitView.HasOpen and 0 == GameVoManager.Instance:GetMainRoleVo().is_change_avatar) and 1 or 0
end

function PlayerData:GetBaiZhanEquipUpLevelRemind()
	local num = 0
	local baizhan_equiplist = ForgeData.Instance:GetBaiZhanEquipAll()
	local baizhan_order_equiplist = ForgeData.Instance:GetBaiZhanEquipOrderAll()

	local can_equip = {
		[0] = false,
		[1] = false,
		[2] = false,
		[3] = false,
		[4] = false,
		[5] = false,
		[6] = false,
		[7] = false,
		[8] = false,
		[9] = false,
	}
	for i = 0, COMMON_CONSTS.BAIZHAN_E_INDEX_MAX do
		if baizhan_equiplist[i] then
			local star_id = 0
			local for_star_id = 0
			if baizhan_equiplist[i].item_id > 0 then
				star_id = baizhan_equiplist[i].item_id
				for_star_id = star_id + 1
			else
				star_id = 17000 + i * 100
				for_star_id = star_id
			end 
			local end_id = star_id + (COMMON_CONSTS.BAIZHAN_E_INDEX_MAX - star_id % 10)
			if end_id >= for_star_id then
				for k = end_id, for_star_id, -1 do
					if ItemData.Instance:GetItemNumInBagById(k) > 0 then
						local is_open = OpenFunData.Instance:CheckIsHide("baizhanequip")
						if is_open then
							num = num + 1
							can_equip[i] = true
							break
						end
					else
						can_equip[i] = false
					end					
				end
			else
				can_equip[i] = false
			end
		end
	end

	for i = 0, COMMON_CONSTS.BAIZHAN_E_INDEX_MAX do
		if can_equip[i] == false then
			if baizhan_equiplist[i] and baizhan_equiplist[i].item_id > 0 then
				local is_jump = false 
				if baizhan_order_equiplist[i] >= 1 and baizhan_order_equiplist[i] <= 5 then
					local up_level_cfg = {}
					if ItemData.Instance:GetItemNumInBagById(27275) >= 5 then
						up_level_cfg = ForgeData.Instance:GetBaiZhanLevelUpCfgByPartAndOldId(i, 27275)
					end
					if up_level_cfg and up_level_cfg.need_num then
						local is_open = OpenFunData.Instance:CheckIsHide("baizhanequip")
						if is_open then
							num = num + 1
							is_jump = true
						end		
					else
						is_jump = false
					end						
				end						
				if is_jump == false then
					local up_level_cfg = {}
					local all_up_level_cfg = {}
					up_level_cfg = ForgeData.Instance:GetBaiZhanLevelUpCfgByPartAndOldId(i, baizhan_equiplist[i].item_id)
					all_up_level_cfg = ForgeData.Instance:GetBaiZhanLevelUpCfgByPartAndOrder(i, baizhan_order_equiplist[i])
					if up_level_cfg and up_level_cfg.need_num and all_up_level_cfg and #all_up_level_cfg > 0 then
						local need_stuff_num = up_level_cfg.need_stuff_num
						for k, v in ipairs(all_up_level_cfg) do
							-- 只能拿同阶或者以下的去合成（升级）
							if v.stuff_num <= up_level_cfg.stuff_num and need_stuff_num > 0 then
								local need_num = 999999999
								-- 防止策划把除数v.stuff_num配成0
								if v.stuff_num > 0 then
									need_num = math.ceil(need_stuff_num / v.stuff_num)
								end
								local old_item_cfg = ItemData.Instance:GetItemConfig(v.old_equip_item_id)
								local new_item_cfg = ItemData.Instance:GetItemConfig(up_level_cfg.new_equip_item_id)
								if ItemData.Instance:GetItemNumInBagById(v.old_equip_item_id) >= need_num then
									need_stuff_num = need_stuff_num - (ItemData.Instance:GetItemNumInBagById(v.old_equip_item_id) * v.stuff_num)
									if need_stuff_num <= 0 then
										break
									end
								elseif ItemData.Instance:GetItemNumInBagById(v.old_equip_item_id) < need_num then
									if ItemData.Instance:GetItemNumInBagById(v.old_equip_item_id) > 0 then
										need_stuff_num = need_stuff_num - (ItemData.Instance:GetItemNumInBagById(v.old_equip_item_id) * v.stuff_num)
									end
								end
							end
						end
						if need_stuff_num <= 0 then
							local is_open = OpenFunData.Instance:CheckIsHide("baizhanequip")
							if is_open then
								num = num + 1
							end
						end
					end
				end
			else
				local up_level_cfg = {}
				if ItemData.Instance:GetItemNumInBagById(27275) >= 5 then
					up_level_cfg = ForgeData.Instance:GetBaiZhanLevelUpCfgByPartAndOldId(i, 27275)
				elseif ItemData.Instance:GetItemNumInBagById(27274) >= 10 then
					up_level_cfg = ForgeData.Instance:GetBaiZhanLevelUpCfgByPartAndOldId(i, 27274)
				end
				if up_level_cfg and up_level_cfg.need_num then
					local is_open = OpenFunData.Instance:CheckIsHide("baizhanequip")
					if is_open then
						num = num + 1
					end
				end	
			end
		end
	end	
	return num
end

function PlayerData:GetInfoRedPoint()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if vo.is_change_avatar == 0 then
		return true
	end
	return false
end

--服务器在不同阶段有不同的奖励配置表，用这个方法来读相应的配置表
function PlayerData:GetCurrentRandActivityConfig()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig()
end

function PlayerData:GetCheckCfg()
	-- local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local role_level = 999
	local prof = PlayerData.Instance:GetRoleBaseProf()
	local check_cfg = ConfigManager.Instance:GetAutoConfig("equipment_strategy_auto").equipment
	for i,v in ipairs(check_cfg) do
		if role_level < v.role_level then
			return v["purple_equip_".. prof], v["orange_equip_".. prof], v["red_equip_".. prof]
		end
	end
	return 0, 0, 0
end

function PlayerData:SetAllCapList(protocol)
	self.play_cap_list = protocol.capability_list
end

function PlayerData:GetCapByType(cap_type)
	local cap = 0
	if self.play_cap_list == nil or cap_type == nil then
		return
	end

	return self.play_cap_list[cap_type] or 0
end

function PlayerData:SetRoleGoalInfo(protocol)
	local falg = false
	if self.cur_chapter > self.old_chapter and protocol.cur_chapter == protocol.old_chapter then
		falg = true
	end
	self.cur_chapter = protocol.cur_chapter
	self.old_chapter = protocol.old_chapter
	self.goal_data_list = protocol.goal_data_list
	self.field_goal_can_fetch_flag = protocol.field_goal_can_fetch_flag
	self.field_goal_fetch_flag = protocol.field_goal_fetch_flag
	self.skill_level_list = protocol.skill_level_list
	GlobalEventSystem:Fire(OtherEventType.VIRTUAL_TASK_CHANGE, self.old_chapter, falg)
end

function PlayerData:GetSkillLevelList()
	local data_table = {}
	for i = 2, 4 do
		local level = self.skill_level_list[i] or 0
		table.insert(data_table, level)
	end
	return data_table
end

function PlayerData:SetTianShiFlag(flag)
	self.tianshi_flag = flag
end

function PlayerData:GetTianShiFlag()
	return self.tianshi_flag
end

--获取圣印背包物品
function PlayerData:GetSealBagItemList()
	local seal_backpack_info_list2 = {}
	local bag_item_list = ItemData.Instance:GetBagItemDataList()
	if bag_item_list == nil then
		return
	end

	local real_id_list = ListToMap(self.seal_cfg_auto.real_id_list, "seal_id")
	local equip_seal_list = self:GetSealSlotItemList()
	local index = 1
	for k, v in pairs(bag_item_list) do
		if nil ~= v and v.item_id >= 24206 and v.item_id <= 24288 then
			local real_data = real_id_list[v.item_id]
			seal_backpack_info_list2[index] = {}
			seal_backpack_info_list2[index].order = real_data.order
			seal_backpack_info_list2[index].color = real_data.color
			seal_backpack_info_list2[index].slot_index = real_data.slot_index
			seal_backpack_info_list2[index].item_id = real_data.seal_id
			seal_backpack_info_list2[index].index = index
			seal_backpack_info_list2[index].bag_index = k
			seal_backpack_info_list2[index].level = 0
			seal_backpack_info_list2[index].num = v.num
			seal_backpack_info_list2[index].is_bind = v.is_bind
			seal_backpack_info_list2[index].show_arrow = 0
			if equip_seal_list[real_data.slot_index - 1] ~= nil and equip_seal_list[real_data.slot_index - 1].order < real_data.order then
				seal_backpack_info_list2[index].show_arrow = 1
			end
			index = index + 1
		end
	end
	table.sort(seal_backpack_info_list2, SortTools.KeyUpperSorters("show_arrow", "order"))
	return seal_backpack_info_list2 or {}
end

--获取圣印背包的圣印数量
function PlayerData:GetSealItemNum(seal_id)
	local num = 0
	if self.seal_backpack_info_list == nil or self.seal_backpack_info_list.grid_list == nil then
		return num
	end
	for k, v in pairs(self.seal_backpack_info_list.grid_list) do 
		if v.item_id == seal_id then 
			num = num + 1
		end
	end
	return num 
end

function PlayerData:SetSealBackpackInfo(protocol)
	self.seal_backpack_info_list = protocol
end

function PlayerData:GetSealBackpackInfo()
	return self.seal_backpack_info_list or {}
end

--获取装备的圣印
function PlayerData:GetSealSlotItemList()
	if self.seal_slot_info_list == nil or self.seal_slot_info_list.grid_list == nil then
		return {}
	end
	local item_list = DeepCopy(self.seal_slot_info_list.grid_list)
	for k, v in pairs(item_list) do 
		if v.item_id ~= 0 then 
			local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
			if item_cfg ~= nil then 
				v.color = item_cfg.color
			end
		end
	end
	return item_list
end

function PlayerData:SetSealSlotInfo(protocol)
	self.seal_slot_info_list = protocol
end

function PlayerData:GetSealSlotInfo()
	return self.seal_slot_info_list or {}
end

--获取圣印属性信息
function PlayerData:GetSealAttrData(slot_index ,order)
	for k, v in pairs(self.seal_cfg_auto.initial_attr) do
		if v.slot_index == slot_index and v.order == order then 
			return v
		end
	end
	return {}
end

--获取圣魂配置
function PlayerData:GetSoulCfg()
	return self.seal_cfg_auto.soul or {}
end
--设置圣魂的基本信息
function PlayerData:SetSealBaseInfo(protocol)
	self.seal_base_info_list = protocol
end
--获取圣魂基本信息
function PlayerData:GetSealBaseInfo()
	return self.seal_base_info_list or {}
end

--获取当前使用圣魂的限制数量
function PlayerData:GetUseMaxCount()
	--local role_level = RoleData.Instance.role_vo.level  		-- 获取角色等级
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local soul_use_limit = self.seal_cfg_auto.soul_use_limit
	for i = #soul_use_limit, 1, -1  do 
		if role_level >= soul_use_limit[i].role_level  then 
			return soul_use_limit[i].use_limit_num
		end
	end
	return 0
end

--获取当前使用圣魂的限制数量
function PlayerData:GetUseLevel()
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	for k, v in ipairs(self.seal_cfg_auto.soul_use_limit) do
		if v.role_level and role_level < v.role_level then 
			return v.role_level
		end
	end
	return 0
end

--根据圣印等级获取升级积分
function PlayerData:GetSealSocrdBySealItemData(item_data)
	local score_cfg_list = self.seal_cfg_auto.score
	local hun_score = 0
	if item_data ~= nil then 
		for i, v in pairs(score_cfg_list) do 
			if item_data.level == v.level then 
				hun_score = v.hun_score 
				break
			end
		end
		return hun_score, #score_cfg_list - 1 
	else
		return 0, #score_cfg_list - 1 
	end
end
--获取圣印套装配置
function PlayerData:GetShengYinSuitCfg()
	return self.seal_suit_client_show
end
--根据圣印套装部位配置
function PlayerData:GetSealSuitCfg(suit_type)
	local data_list = {}
	local list = self.seal_suit_part_list[suit_type]
	if list ~= nil then 
		for i, v in pairs(list) do 
			data_list[#data_list + 1] = v
		end
	end
	return data_list
end

--根据阶数和部位获取套装ID(套装配置)
function PlayerData:GetItemByOrderAndPart(item_order,item_part)
	for i, v in pairs(self.seal_cfg_auto.real_id_list) do 
		if v.order == item_order and v.slot_index == item_part then 	
			return v
		end
	end
	return nil
end

--根据类型获取套装属性
function PlayerData:GetSuitDataByItemSuitType(suit_type)
	local data_list = {}
	local list = self.seal_suit_type_list[suit_type]
	if list ~= nil then 
		for i, v in pairs(list) do 
			data_list[#data_list + 1] = v
		end
	end
	return data_list
end

--根据套装类型获取套装完成数量
function PlayerData:GetFinshSuitCountBySuitType(suit_type)
	local item_count = 0
	local seal_part_list = self:GetSealSuitCfg(suit_type)
	local seal_slot_grid_list = self:GetSealSlotItemList()
	for w, s in pairs (seal_slot_grid_list) do 
		for w1, s1 in pairs (seal_part_list) do
			for w2, s2 in pairs(s1) do 
				if s.order == s2.equip_order and s.slot_index == s2.equip_part then 
					item_count = item_count + 1 
				end
			end
		end
	end
	return item_count, suit_type
end
--获取圣魂红点提醒
function PlayerData:GetSealSoulRemind()
	local use_seal_count_list = self:GetSealBaseInfo().soul_list or {}
	local use_max_num = self:GetUseMaxCount()
	local soul_list = self:GetSoulCfg()
	for i, v in pairs(soul_list) do
		local  item_count = ItemData.Instance:GetItemNumInBagById(v.soul_id)
		if use_seal_count_list then 
			local use_num = use_seal_count_list[i - 1] or 0		
			if item_count > 0 and use_num < use_max_num then
				return 1
			end
		end
	end
	return 0
end

--获取圣印镶嵌栏红点提醒
function  PlayerData:GetSealEquipRemind()
	local grid_list = self:GetSealBagItemList()
	if grid_list == nil then return end
	local seal_remind_list = {}
	local enable_points = self:GetShenYinEnablePoints()
	for k, v in pairs(grid_list) do
		if v.slot_index ~= nil and v.slot_index ~= 0 and v.slot_index <= enable_points then
			local sealslot_grid_list = self:GetSealSlotItemList()
			if sealslot_grid_list[v.slot_index - 1] then
				local order = sealslot_grid_list[v.slot_index - 1].order
				if seal_remind_list[v.slot_index - 1] or order <= 0 or order < v.order then
					seal_remind_list[v.slot_index - 1] = true
				else
					seal_remind_list[v.slot_index - 1] = false
				end
			end
		end
	end
	return seal_remind_list
end

--获取圣印分解红点提醒
function PlayerData:GetSealFenJieRemind()
	local grid_list = self:GetSealBagItemList()
	if grid_list == nil then return end
	local num = #grid_list
	if num >= SEAL_RESOLVE_REMIND_NUM then
		return 1
	else
		return 0
	end
end

--获取圣印强化红点提醒
function PlayerData:GetSealStrengthRemind()
	local base_info = self:GetSealBaseInfo()
	local hun_score = base_info.hun_score or 0
	local seal_list = self:GetSoulStrengthlist()
	for k, v in pairs(seal_list) do
		local need_score, max_level = self:GetSealSocrdBySealItemData(v) 
		if hun_score > need_score and max_level > v.level then 

			return 1 
		end
	end
	return 0
end

function PlayerData:GetShengYinRemind()
	if self:GetSealSoulRemind() == 1 or self:GetSealStrengthRemind() == 1 or self:GetSealFenJieRemind() == 1 then
		return 1
	end
	if self:GetSealEquipRemind() == nil then
		return 0
	end
	for k, v in pairs(self:GetSealEquipRemind()) do
		if v == true then
			return 1
		end
	end
	return 0
end

function PlayerData:GetShowXiaoGui()
	-- 每天提醒一次的假红点 
	if self.tips_show_delay == nil then
		self.tips_show_delay = GlobalTimerQuest:AddDelayTimer(function () RemindManager.Instance:SetRemindToday(RemindName.XiaoGui) end, 5)
	end
	local is_remind = RemindManager.Instance:RemindToday(RemindName.XiaoGui)
	if not is_remind then
		return 1
	end
	return 0
end

--获取所有属性键
function PlayerData:GetTotalAttrKey()
local SuitAttrinfoList = {
	"gongji",
	"fangyu",
	"maxhp",
	"mingzhong",
	"shanbi",
	"baoji",
	"jianren",
	"pojia",
	"per_gongji",
	"per_fangyu",
	"per_maxhp",
	"per_baoji",
	"per_pojia",
	"per_baoji_jiacheng",
	"per_shanghaijiacheng" ,
	"per_shanghaijianshao",
	"skill_zengshang_per",
	-- "per_base_attr_jiacheng",
	"per_strength_attr_jiacheng",
	}
	
	return SuitAttrinfoList
end
--获取圣印总属性
function PlayerData:GetSealTotalAttr()
	local seal_solt_list = self:GetSealSlotItemList()
	local suit_attr_info_list = self:GetTotalAttrKey()
	local list = {}
	local list2 = {}
	for i, v in pairs(seal_solt_list) do 
		if v.item_id ~= 0 then
			local item_attr = self:GetSealAttrData(v.slot_index, v.order)
			for i1, v1 in pairs(suit_attr_info_list) do 
				if item_attr[v1] ~= nil and item_attr[v1] ~= 0 then 
					if list[v1] == nil then 
						list[v1] = 0
					end
					list[v1] = item_attr[v1] + list[v1] 
				end
			end
		end
	end
	for i1, v1 in pairs(suit_attr_info_list) do
		if list[v1] ~= nil and list[v1] ~= 0 then 
			table.insert(list2, {v1, list[v1]})
		end
	end
	--------------------------------加算套装属性-------------------------------------------
	for i = 1, #self.seal_suit_type_list do 
		local item_count,suit_type = self:GetFinshSuitCountBySuitType(i)
		local suit_type_list = self.seal_suit_type_list[suit_type]
		for k, v in pairs(suit_type_list) do 
			if item_count >= v.same_order_num then 
				list2 = self:TotalAttrAddSuitAttr(list2, v)
			end
		end
	end
 	-------------------------------------------------------------------
	return list2
end

--总属性加算套装属性
function PlayerData:TotalAttrAddSuitAttr(total_attr_list, suit_type_data)
	local suit_attr_info_list = self:GetTotalAttrKey()
 	for i1, v1 in pairs(suit_attr_info_list) do 
 		if suit_type_data[v1] ~= nil and suit_type_data[v1] ~= 0 then 
 			for i2, v2 in pairs(total_attr_list) do 
 				if v2[1] == v1 then  
 					v2[2] = v2[2] + suit_type_data[v1]
 				end
 			end
 		end
 	end
 	return total_attr_list
end
--获取初始强化配置
function PlayerData:GetCurTotalLevelCfg()
	local seal_solt_list = self:GetSealSlotItemList()
	local total_level = 0 
	local cur_level_cfg = 0
	for i, v in pairs(seal_solt_list)do 
		if v.item_id ~= 0 then 
			total_level = v.level + total_level
		end
	end
	local strength_cfg_list = self.seal_cfg_auto.strength
	for i = #strength_cfg_list, 1, -1 do
		if total_level >= strength_cfg_list[i].level then 
			cur_level_cfg = strength_cfg_list[i]
			break
		end
	end
	if cur_level_cfg == 0 then 
		cur_level_cfg = strength_cfg_list[1]
	end
	return total_level, cur_level_cfg
end

--获取下级强化配置
function PlayerData:GetNextTotalLevelCfg()
	local _, cur_level_cfg = self:GetCurTotalLevelCfg()
	local strength_cfg_list = self.seal_cfg_auto.strength
	if cur_level_cfg.index == #strength_cfg_list then 
		return strength_cfg_list[#strength_cfg_list].level, 0
	end
	return strength_cfg_list[#strength_cfg_list].level, strength_cfg_list[cur_level_cfg.index + 1] or {}
end

--获取分解选择的圣印
-- 合G21的代码
function PlayerData:GetShengYinResoleSelect(seal_item_list, order)
	local select_index_list = {}
	if seal_item_list == nil or order == -1 then return select_index_list end
	for i = 1, #seal_item_list do
		if seal_item_list[i] ~= nil and seal_item_list[i].item_id ~= nil and seal_item_list[i].item_id ~= 0 then
			local item_cfg = ItemData.Instance:GetItemConfig(seal_item_list[i].item_id)
			if seal_item_list[i].order <= order then
				select_index_list[i] = seal_item_list[i].bag_index
			end
		end
	end
	return select_index_list
end
--获取圣印强化表
function PlayerData:GetSoulStrengthlist()
	local list = {} 
	local seal_solt_list = self:GetSealSlotItemList()
	if next(seal_solt_list) then 
		for i = 0, #seal_solt_list do 
			if seal_solt_list[i].item_id ~= 0 then 
				table.insert(list, seal_solt_list[i])
			end
		end
	end
	return list
end

--获取圣印强化最小强化部位
function PlayerData:GetMinSealItem()
	local seal_solt_list = self:GetSoulStrengthlist()
	if seal_solt_list == nil then
		return -1
	end
	local item_data = seal_solt_list[1]
	local index = 1
	local need_score, max_level = self:GetSealSocrdBySealItemData(item_data)
	for i = 2, #seal_solt_list do	
		-- if seal_solt_list[i] ~= nil and (item_data.level >= max_level or self:GetSealSocrdBySealItemData(seal_solt_list[i]) < need_score) then
		-- 	item_data = seal_solt_list[i]
		-- 	index = i
		-- end
		if seal_solt_list[i] ~= nil and (item_data.level >= max_level or seal_solt_list[i].level < item_data.level) then
			item_data = seal_solt_list[i]
			index = i
		end
	end
	need_score, max_level = self:GetSealSocrdBySealItemData(item_data)
	if item_data == nil or item_data.level >= max_level then
		return
	else
		return item_data, need_score, index
	end
end
--根据物品Id判断物品是否圣印
function PlayerData:GetItemIsSealByItemId(seal_id)
	for i, v in pairs(self.seal_cfg_auto.real_id_list ) do 
		if v.seal_id == seal_id then 
			return true, v
		end
	end
	return false, {}
end
--获取圣印基础属性键
function PlayerData:GetBaseAttrKey()
	local SuitAttrinfoList = {
	"gongji",
	"fangyu",
	"maxhp",
	"mingzhong",
	"shanbi",
	"baoji",
	"jianren",
	"pojia",
	"per_gongji",
	"per_fangyu",
	"per_maxhp",
	"per_baoji",
	"per_pojia",
	"per_baoji_jiacheng",
	"per_shanghaijiacheng" ,
	"per_shanghaijianshao",
	"skill_zengshang_per",
	-- "per_base_attr_jiacheng",
	"per_strength_attr_jiacheng",
	}
	
	return SuitAttrinfoList
end

--获取圣印特殊属性键
function PlayerData:GetSpecialAttrKey()
local SuitAttrinfoList = {}
	-- {
	-- "yaolichuantou",
	-- "yaolidikang",
	-- "molichuantou",
	-- "molidikang",
	-- "shenlichuantou",
	-- "shenlidikang",
	-- }
	
	return SuitAttrinfoList
end

--根据部位获取强化属性值
function PlayerData:GetSoulAttrValueBySlotIndex(slot_index)
	return self.seal_cfg_auto.seal[slot_index]
end

--设置圣印背包Index
function PlayerData:SetShengYinBagIndex(index)
	self.shengyin_bag_index = index
end
--获取圣印背包Index
function PlayerData:GetShengYinBagIndex()
	return self.shengyin_bag_index
end

--根据圣印Id获取圣印孔
function PlayerData:GetSealSlotBySealId(seal_id)
	for i, v in pairs(self.seal_cfg_auto.real_id_list ) do 
		if v.seal_id == seal_id then 
			return v.slot_index
		end
	end
	return 0 
end

function PlayerData:IsHoldAngle()
	return self.role_vo.task_appearn > CHANGE_MODE_TASK_TYPE.INVALID 
	and self.role_vo.task_appearn < CHANGE_MODE_TASK_TYPE.TALK_IMAGE 
	and self.role_vo.task_appearn_param_1 > CHANGE_MODE_TASK_TYPE.INVALID
end

-- 获得转职装备的职业要求
function PlayerData:GetZhuanzhiLimitProfName(limit_prof, order)
	local cfg = self.zhuanzhi_limit_prof_name[limit_prof]
	return (cfg and cfg[order]) and cfg[order].prof_name or Language.Common.AllProf
end

-- 获得转职装备的职业要求
function PlayerData:GetZhuanzhiLimitProfNameTwo(limit_prof, order)
	local cfg = self.zhuanzhi_limit_prof_name[limit_prof]
	return (cfg and cfg[order]) and cfg[order].prof_name or Language.Common.AllProf2
end

function PlayerData:GetShenYinEnablePoints()
	local player_level = self.role_vo.level
	local solt_open_tab = self.seal_cfg_auto.slot_open
	if solt_open_tab ~= nil then
		for i = #self.seal_cfg_auto.slot_open, 1, -1 do
			if nil ~= solt_open_tab[i] and player_level >= solt_open_tab[i].role_level then
				return solt_open_tab[i].slot_index
			end
		end
	end
	return 0
end

function PlayerData:GetShengYinJingHuaCfg(color)
	return self.seal_initial_score[color] or {}
end

function PlayerData:IsShengYinJingHua(seal_id)
	local real_id_list = self.seal_cfg_auto.real_id_list
	for k, v in pairs(real_id_list) do
		if v.seal_id == seal_id and v.slot_index == 0 and v.order == 0 then
			return true
		end
	end
	return false
end

function PlayerData:SetIsReturnTalkSystem(enable)
	self.is_return = enable 
end

function PlayerData:GetIsReturnTalkSystem()
	return self.is_return
end

function PlayerData:GetUITweenCfg(panel_tab_index)
	local tween_cfg = {
		[TabIndex.role_innate_skill] = {["LeftPanel"] = Vector3(-838, 0, 0), ["RightPanel"] = Vector3(729, -24, 0), ["DownPanel"] = Vector3(0, -334, 0), ["MoveTime"] = 0.5},
		[TabIndex.role_passive_skill] = {["LeftPanel"] = Vector3(-838, 400, 0), ["RightPanel"] = Vector3(729, -24, 0), ["DownPanel"] = Vector3(0, -350, 0), ["MoveTime"] = 0.5},
		[TabIndex.role_tianshu_skill] = {["LeftPanel"] = Vector3(-838, 400, 0), ["RightPanel"] = Vector3(729, -24, 0), ["DownPanel"] = Vector3(0, -350, 0), ["MoveTime"] = 0.5},
	}
	return tween_cfg[panel_tab_index]
end

function PlayerData:GetFBExpByLevel(level)
	if level == nil then
		return 0
	end
	local role_exp_level_cfg = ConfigManager.Instance:GetAutoConfig("role_level_reward_auto").level_reward_list
	local exp_cfg = ListToMap(role_exp_level_cfg, "level")
	if exp_cfg[level] then
		return exp_cfg[level].exp_0
	end
end

--获取角色绑元加元宝
function PlayerData:GetRoleAllGold()
	return self.role_vo.gold + self.role_vo.bind_gold
end

-- 根据职业获取跳跃时间
function PlayerData:GetJumpTime(jump_act)
	local prof = self:GetRoleBaseProf()
	local jumo_time_cfg = {
		[1] = {[1] = 1, [2] = 1.2, [3] = 1.2},--男剑
		[2] = {[1] = 1, [2] = 1.4, [3] = 1.2},--男琴
		[3] = {[1] = 1, [2] = 1.3, [3] = 1.5},--女剑
		[4] = {[1] = 1, [2] = 1, [3] = 1},--女炮
	}
	if jumo_time_cfg[prof] and jumo_time_cfg[prof][jump_act] then
		return jumo_time_cfg[prof][jump_act]
	end
	return 1
end

--第一次进
function PlayerData:SetIsFirstEntry(bool)
	self.first_entry = bool
end

function PlayerData:GetIsFirstEntry()
	return self.first_entry
end