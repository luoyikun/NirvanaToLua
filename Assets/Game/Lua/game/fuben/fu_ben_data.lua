FuBenData = FuBenData or BaseClass()

FuBenDataExpItemId = {
	ItemId = 90050
}


local PHASE_FB_MAX_LEVEL = 10
local FLUSH_REDPOINT_CD = 600
local PHASE_CLOSE_CHALLENGE_OPEN_DAY = 5

TeamFuBenOperateType = {
	REQ_ROOM_LIST = 1,				-- 请求房间列表
	CREATE_ROOM = 2,				-- 创建房间
	JOIN_ROOM = 3,					-- 加入指定房间
	START_ROOM = 4,					-- 开始房间
	EXIT_ROOM = 5,					-- 退出房间
	CHANGE_MODE = 6,				-- 选择模式
	KICK_OUT = 7,					-- T人
	ENTER_AFFIRM = 8,				-- 准备
}

FuBenTeamType = {
	TEAM_TYPE_DEFAULT = 0,					-- 默认组队
	TEAM_TYPE_YAOSHOUJITANG = 1,			-- 妖兽祭坛副本
	TEAM_TYPE_TEAM_TOWERDEFEND = 2,			-- 组队塔防副本
	TEAM_TYPE_TEAM_MIGONGXIANFU = 3,		-- 迷宫仙府副本
	TEAM_TYPE_TEAM_EQUIP_FB = 4,			-- 组队装备副本
	TEAM_TYPE_TEAM_DAILY_FB = 5,			-- 日常经验副本
	TEAM_TYPE_EQUIP_TEAM_FB = 6,			-- 精英组队装备副本
	TEAM_TYPE_MARRY_FB = 7,					-- 情缘副本
}	

TOWER_DEFEND_NOTIFY_REASON = {
	DEFAULT = 0,
	INIT = 1,
	NEW_WAVE_START = 2,
}

--通过1152协议,param_1 发章节数,param_2 发关卡等级
PUSH_FB_TYPE = {
	PUSH_FB_TYPE_NORMAL = 0,                -- 普通推图副本
	PUSH_FB_TYPE_HARD = 1,			        -- 精英推图副本
}

ShowRedPoint = {
	NOT_SHOW_RED_POINT = 0,		-- 不显示红点
	SHOW_RED_POINT = 1,			-- 显示
}

--进阶副本各种类型的顺序(对应配置中的fb_type)
PhaseFuBenTypeSort = {
	1, 2, 3, 4, 5, 6, 7,
}

FuBenTweenData = {
	Right = Vector3(250, -23, 0),
	Down = Vector3(-45, -465, 0),
	PhaseDown = Vector3(-54, -480, 0),
	PhaseUp = Vector3(613, 35, 0),
}

BuildTowerTipsView = {
	BuildPanel = 1,							-- 建防御塔界面
	DescPanel = 2,							-- 防御塔介绍界面
	UpdataPanel = 3, 						-- 防御塔升级界面
	RwardPanel = 4, 						-- 掉落统计界面
}

function FuBenData:__init()
	if FuBenData.Instance ~= nil then
		print_error("[FuBenData] Attemp to create a singleton twice !")
		return
	end
	FuBenData.Instance = self
	self.phase_info_list = {}
	self.story_info_list = {}
	self.tower_info_list = {}
	self.exp_info_list = {}
	self.vip_info_list = {}
	self.vip_pass_flag = 0
	self.pick_item_info = {}
	self.exp_fb_info = {}
	self.rand_weather = {}
	self.team_list = {}
	self.exp_red_point_cd = 0
	self.tower_red_point_cd = 0
	self.now_scene_id = 0
	self.quality_enter_count = 0
	self.quality_buy_count = 0
	self.fuben_team_shouhu_wave = 0
	self.many_fb_user_count = 0
	self.many_fb_user_info = {}
	self.team_equip_fb_pass_flag = 0
	self.team_equip_fb_day_count = 0
	self.team_equip_fb_day_buy_count = 0
	self.fb_scene_logic_info = {}
	self.team_tower_result = {}
	self.fb_team_tower_reward_list = {}
	self.select_many_fuben_layer = 0
	self.cur_select_layer = 0
	self.count = 0

	self.challenge_all_info = {}
	self.challenge_fb_info = {}
	self.pass_layer_info = {}
	self.phase_fb_redpoint_num_record = {}
	self.have_enter_challenge = false
	self.push_show_index = 0

	self.exp_fb_exit_flag = false

	self.auto_gu_wu = false

	-- 推图副本内容
	self.tuitu_fb_result_info = {}
	self.push_fb_info_list = {}

	self.fb_list = {
		team_type = 0,
		room_list = {},
		count = 0,
	}

	self.shuijingbuff_open_list = {
		[SceneType.ShuiJing] = true,
		[SceneType.Kf_XiuLuoTower] = true,
		[SceneType.TombExplore] = true,
	}

	self.enter_affirm_info = {
		team_type = 0,
		mode = 0,
		layer = 0,
	}

	self.map_list = {}
	self.view_data = {}
	
	-- 副本iconview 右边BOSS数据缓存
	self.cache_diff_time_list = {}
	self.cache_monster_id_list = {}
	self.cache_monster_flush_info_list = {}
	self.cache_monster_icon_enable_list = {}
	self.cache_monster_icon_gray_list = {}

	self.tower_defend_role_info = {}
	self.tower_defend_auto_reward_info = {}
	self.tower_defend_fb_info = {}
	self.drop_info = {}
	self.tower_defend_result ={}
	self.weapon_materials_info = {}
	self.neq_level_config = {}
	self.weapon_max_chapter = 0
	self.neq_roll_pool = {}
	self.roll_vo = {}
	self.pass_vo = {}
	self.cur_chapter = 0
	self.cur_level = 1

	self.armor_select_level = 0

	self.select_level = 0

	self.armor_info = {}
	self.armor_skill_cd = {}
	self.armor_scene_info = {}

	self.desc_index = 1
	self.defense_times = 0
	self.defense_buy_times = 0
	self.defense_enter_times = 0
	self.defense_data = {}

	self.layer = 1
	self.cur_page = 1
	self.player_id = 0
	self.show_flag = false
	self.is_not_click = true
	-- self.is_new_power = false
	self.team_info = {}
	self.team_member_t = {}
	self.team_fb_info = {}
	self.fuben_cell_info = {
		[1] = {remain_times = 0},
		[2] = {remain_times = 0},
	}
	self.reward_item_list = {}
	self.join_times_list = {}
	self.open_list = {}
	self.guard_info = {}
	self.set_power = 0
	self.max_pata_pass_level = 0
	self.is_new_level = false
	-- self.is_first_open = true
	self.fb_team_red_point = true
	self.is_not_newpower = false
	self.is_can_open_jiesuo = true
	self.team_flag = true
	self.expteam_flag = true
	self.is_click_saodang = false

	local tuitu_fb_cfg = ConfigManager.Instance:GetAutoConfig("tuitu_fb_auto")
	self.tuitu_fb_info_cfg = ListToMap(tuitu_fb_cfg.fb_info, "fb_type", "chapter", "level")

	local challengefb_cfg = ConfigManager.Instance:GetAutoConfig("challengefbcfg_auto") or {}
	self.challenge_other_cfg = challengefb_cfg.other[1]
	self.challenge_buycost_cfg = challengefb_cfg.buy_cost

	local list = ConfigManager.Instance:GetAutoConfig("newequipfb_auto").levelcfg
	local reward_list = ConfigManager.Instance:GetAutoConfig("newequipfb_auto").starcfg
	local reward_list1 = ConfigManager.Instance:GetAutoConfig("newequipfb_auto").starcfg1
	self.weapon_info_list = ListToMap(list, "chapter", "level")
	self.weapon_need_list = ListToMap(list, "chapter", "level","role_level")
	self.weapon_reward_list = ListToMapList(reward_list, "chapter")
	self.weapon_reward_list1 = ListToMapList(reward_list1, "chapter")

	local patafbconfig_auto = ConfigManager.Instance:GetAutoConfig("patafbconfig_auto")
	self.patafb_level_cfg = ListToMap(patafbconfig_auto.levelcfg, "level")

	RemindManager.Instance:Register(RemindName.FuBenSingle, BindTool.Bind(self.IsShowFubenRedPoint, self)) -- 主界面图标红点
	RemindManager.Instance:Register(RemindName.BeStrength, BindTool.Bind(self.GetBeStrengthRedmind, self)) -- 变强 
	RemindManager.Instance:Register(RemindName.GaoZhanFuBen, BindTool.Bind(self.GetGaoZhanFuBenPoint, self))	-- 闯关主界面红点

	-- RemindManager.Instance:Register(RemindName.FuBen_XueZhan, BindTool.Bind(self.IsShowXueZhanRedPoint, self))
	RemindManager.Instance:Register(RemindName.FuBen_JinJie, BindTool.Bind(self.IsShowPhaseFBRedPoint, self))	-- 已注册
	RemindManager.Instance:Register(RemindName.FuBen_Exp, BindTool.Bind(self.IsShowExpFBRedPoint, self))	-- 已注册
	RemindManager.Instance:Register(RemindName.FuBen_ShiLian, BindTool.Bind(self.IsShowTowerFBRedPoint, self))	-- 已注册
	RemindManager.Instance:Register(RemindName.FuBen_HuanJing, BindTool.Bind(self.IsShowQualityFBRedPoint, self))	-- 已注册
	RemindManager.Instance:Register(RemindName.FuBen_Armor, BindTool.Bind(self.IsShowArmorFBRedPoint, self))	-- 已注册
	RemindManager.Instance:Register(RemindName.FuBen_Weapon, BindTool.Bind(self.IsShowWeaponFBRedPoint, self))	-- 已注册
	RemindManager.Instance:Register(RemindName.FuBen_ShouHu, BindTool.Bind(self.IsShowGuardFBRedPoint, self))	-- 已注册
	RemindManager.Instance:Register(RemindName.FuBen_Defense, BindTool.Bind(self.IsShowDefenseFBRedPoint, self))	-- 已注册
	RemindManager.Instance:Register(RemindName.FuBen_Team, BindTool.Bind(self.IsShowTeamFBRedPoint, self))	-- 已注册

	self:InitDataList()
	self:InitEnterTimes()
	self:InitOpenLevel()
	self:InitReward()
	self:GetWeaponCfgOther()
	self.quality_index_select = self:GetCanChallengeMaxLevel()

	self.is_show_phase_toggle_red_point = {}
	for i = 1,7 do
		self.is_show_phase_toggle_red_point[i] = 1
	end
	self.level_change_event = GlobalEventSystem:Bind(ObjectEventType.LEVEL_CHANGE,
		BindTool.Bind(self.OnLevelChange, self))

	if self.player_data_change_callback2 == nil then
		self.player_data_change_callback2 = BindTool.Bind1(self.CheCkPaTaDataChangeRedPoint, self)
		PlayerData.Instance:ListenerAttrChange(self.player_data_change_callback2)
	end
end

function FuBenData:__delete()
	RemindManager.Instance:UnRegister(RemindName.FuBenSingle)
	RemindManager.Instance:UnRegister(RemindName.BeStrength)
	RemindManager.Instance:UnRegister(RemindName.GaoZhanFuBen)

	-- RemindManager.Instance:UnRegister(RemindName.FuBen_XueZhan)
	RemindManager.Instance:UnRegister(RemindName.FuBen_JinJie)
	RemindManager.Instance:UnRegister(RemindName.FuBen_Exp)
	RemindManager.Instance:UnRegister(RemindName.FuBen_ShiLian)
	RemindManager.Instance:UnRegister(RemindName.FuBen_HuanJing)
	RemindManager.Instance:UnRegister(RemindName.FuBen_ShouHu)
	RemindManager.Instance:UnRegister(RemindName.FuBen_Weapon)
	RemindManager.Instance:UnRegister(RemindName.FuBen_Armor)
	RemindManager.Instance:UnRegister(RemindName.FuBen_Defense)
	RemindManager.Instance:UnRegister(RemindName.FuBen_Team)

	FuBenData.Instance = nil
	self.phase_info_list = {}
	self.story_info_list = {}
	self.tower_info_list = {}
	self.exp_info_list = {}
	self.vip_info_list = {}
	self.fb_scene_logic_info = {}
	self.tuitu_fb_result_info = {}
	self.push_fb_info_list = {}
	self.defense_cfg = {}
	self.armor_info = {}
	self.armor_skill_cd = {}
	self.armor_scene_info = {}
	self.weapon_materials_info = {}
	self.neq_level_config = {}
	self.neq_roll_pool = {}
	
	self.armor_buytimes = false
	self.exp_red_point_cd = 0
	self.tower_red_point_cd = 0
	self.is_show_phase_toggle_red_point = nil

	if self.exp_tiem_quest then
		GlobalTimerQuest:CancelQuest(self.exp_tiem_quest)
	end
	self.exp_tiem_quest = nil
	
	if self.player_data_change_callback then
		PlayerData.Instance:UnlistenerAttrChange(self.player_data_change_callback)
		self.player_data_change_callback = nil
	end

	if self.player_data_change_callback2 then
		PlayerData.Instance:UnlistenerAttrChange(self.player_data_change_callback2)
		self.player_data_change_callback2 = nil
	end
end

-- 进入副本返回的信息
function FuBenData:SetFBSceneLogicInfo(info_list)
	self.fb_scene_logic_info = info_list
end

function FuBenData:GetFBSceneLogicInfo()
	return self.fb_scene_logic_info
end

function FuBenData:SetFBSceneLogicTime(time)
	self.fb_scene_logic_info.time_out_stamp = time
end

function FuBenData:ClearFBSceneLogicInfo()
	self.fb_scene_logic_info = {}
end

function FuBenData:SetFbPickItemInfo(item_list)
	self.pick_item_info = item_list
end

function FuBenData:SetExpFbFlag(value)
	self.exp_fb_exit_flag = value
end

function FuBenData:GetExpFbFlag()
	return self.exp_fb_exit_flag
end

function FuBenData:SetIsAutoGuWu(value)
	self.auto_gu_wu = value
end

function FuBenData:GetIsAutoGuWu()
	return self.auto_gu_wu
end

function FuBenData:GetFbPickItemInfo()
	local list = self.pick_item_info
	self.pick_item_info = {}
	return list
end

function FuBenData:GetFbInspirePrice()
	return self.daily_fb_cfg
end

function FuBenData:SetAromrBuyTimes(enable)
	self.armor_buytimes = enable
end

function FuBenData:GetAromrBuyTimes(enable)
	return self.armor_buytimes
end

function FuBenData:OnLevelChange()
	local fuben_view = FuBenCtrl.Instance:GetFuBenView()
	if fuben_view then
		RemindManager.Instance:Fire(RemindName.FuBen_JinJie)
		RemindManager.Instance:Fire(RemindName.FuBenSingle)
	end

	-- local capability = GameVoManager.Instance:GetMainRoleVo().capability
	-- PlayerPrefsUtil.SetInt("fubenquality_remind", capability)
	-- self.set_power = PlayerPrefsUtil.GetInt("fubenquality_remind")
	-- self.is_new_power = true
end

function FuBenData:SetIsNotNewPower(enable)
	self.is_not_newpower = enable
end

function FuBenData:GetIsNotNewPower()
	return self.is_not_newpower
end

-- 剧情副本
function FuBenData:GetStoryFBLevelCfg()
	return ConfigManager.Instance:GetAutoConfig("storyfbconfig_auto").fb_list
end

function FuBenData:GetStoryFBPageCfg()
	return ConfigManager.Instance:GetAutoConfig("storyfbconfig_auto").section_list
end

function FuBenData:MaxStoryFB()
	return #ConfigManager.Instance:GetAutoConfig("storyfbconfig_auto").fb_list
end

function FuBenData:GetExpFBCfg()
	return ConfigManager.Instance:GetAutoConfig("dailyfbconfig_auto")
end

function FuBenData:SetStoryFBInfo(info_list)
	self.story_info_list = info_list
end

function FuBenData:GetStoryFBInfo()
	return self.story_info_list
end

function FuBenData:ClearStoryFBInfo()
	self.story_info_list = {}
end

-- 勇者之塔
function FuBenData:GetTowerFBLevelCfg()
	if self.patafb_level_cfg then
		return self.patafb_level_cfg
	end
end

function FuBenData:MaxTowerFB()
	return #ConfigManager.Instance:GetAutoConfig("patafbconfig_auto").levelcfg
end

function FuBenData:SetTowerFBInfo(protocol)
	self.tower_info_list.today_level = protocol.pass_level
	self.tower_info_list.pass_level = protocol.pass_level

	if protocol.pass_level > self.max_pata_pass_level then
		self.max_pata_pass_level = protocol.pass_level
		self.is_new_level = true
		ClickOnceRemindList[RemindName.FuBen_ShiLian] = 1
		RemindManager.Instance:Fire(RemindName.FuBen_ShiLian)
	else
		self.is_new_level = false
	end
end

function FuBenData:GetTowerFBInfo()
	return self.tower_info_list or nil
end

function FuBenData:ClearTowerFBInfo()
	self.tower_info_list = {}
end

function FuBenData:SetIsCanOpenJieSuo(enable)
	self.is_can_open_jiesuo = enable
end

function FuBenData:GetIsCanOpenJieSuo()
	return self.is_can_open_jiesuo
end

function FuBenData:GetSpecialRewardLevel(level)
	local level = level or self.tower_info_list.pass_level
	if not level then return end
	for k, v in pairs(self.patafb_level_cfg) do
		if v.title_id > 0 and level < v.level then
			return v
		end
	end
	return nil
end

-- 爬塔副本通关最高层，扫荡全部层数奖励
function FuBenData:GetTowerFbSaoDangAllReward()
	local reward_cfg = {}
	local temp_list = {}
	local temp_cfg = nil
	for k, v in pairs(ConfigManager.Instance:GetAutoConfig("patafbconfig_auto").levelcfg) do
		temp_cfg = v.normal_reward[0]
		if temp_cfg then
			if not temp_list[temp_cfg.item_id] then
				temp_list[temp_cfg.item_id] = {item_id = temp_cfg.item_id, num = temp_cfg.num, is_bind = temp_cfg.is_bind}
			elseif temp_list[temp_cfg.item_id].is_bind == temp_cfg.is_bind then	-- 绑定类型一样
				temp_list[temp_cfg.item_id].num = temp_list[temp_cfg.item_id].num + temp_cfg.num
			elseif temp_list[temp_cfg.item_id].is_bind ~= temp_cfg.is_bind and temp_list[temp_cfg.item_id] then	-- 绑定类型不一样
				temp_list[temp_cfg.item_id.."_0"] = {item_id = temp_cfg.item_id, num = temp_cfg.num, is_bind = temp_cfg.is_bind}
			end
		end
	end
	for k, v in pairs(temp_list) do
		table.insert(reward_cfg, v)
	end

	return reward_cfg
end

function FuBenData:SetExpFbInfo(protocol)
	if self.exp_fb_info == nil then
		self.exp_fb_info = {}
	end
	self.exp_fb_info.time_out_stamp = protocol.time_out_stamp
	self.exp_fb_info.scene_type = protocol.scene_type
	self.exp_fb_info.is_finish = protocol.is_finish
	self.exp_fb_info.guwu_times = protocol.guwu_times
	self.exp_fb_info.team_member_num = protocol.team_member_num
	self.exp_fb_info.exp = protocol.exp
	self.exp_fb_info.record_max_exp = protocol.record_max_exp
	self.exp_fb_info.exp_percent = protocol.exp_percent
	self.exp_fb_info.wave = protocol.wave
	self.exp_fb_info.kill_allmonster_num = protocol.kill_allmonster_num
	self.exp_fb_info.start_time = protocol.start_time
end

function FuBenData:OnSCDailyFBRoleInfo(protocol)
	if self.exp_fb_info == nil then
		self.exp_fb_info = {}
	end
	self.exp_fb_info.expfb_today_pay_times = protocol.expfb_today_pay_times --今天购买次数
	self.exp_fb_info.expfb_today_enter_times = protocol.expfb_today_enter_times --今天进入次数
	self.exp_fb_info.last_enter_fb_time = protocol.last_enter_fb_time --最后一次进入时间
	self.exp_fb_info.max_exp = protocol.max_exp --最大经验
	self.exp_fb_info.max_wave = protocol.max_wave --最大波数
	self.exp_fb_info.expfb_history_enter_times = protocol.expfb_history_enter_times or 1 --历史进入次数
end

function FuBenData:GetExpFBInfo()
	return self.exp_fb_info or {}
end

function FuBenData:ClearExpFBInfo()
	-- self.exp_info_list = {}
end

function FuBenData:GetExpPotionCfg()
	return ConfigManager.Instance:GetAutoConfig("dailyfbconfig_auto").dailyfb[0] or {}
end

function FuBenData:GetExpFBOtherCfg()
	return ConfigManager.Instance:GetAutoConfig("dailyfbconfig_auto").exp_other_cfg[1]
end

function FuBenData:GetExpPayTimeByVipLevel(vip_level)
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("dailyfbconfig_auto").expfb_vip_pay_time) do
		if vip_level == v.vip_level then
			return v.pay_time
		end
	end
	return 0
end

function FuBenData:GetExpVipLevelByPayTime(pay_time)
	for k,v in ipairs(ConfigManager.Instance:GetAutoConfig("dailyfbconfig_auto").expfb_vip_pay_time) do
		if pay_time == v.pay_time then
			return v.vip_level
		end
	end
	return 0
end

function FuBenData:GetExpNextPayMoney(has_buy_times)
	local cfg = self:GetExpFBCfg().expfb_reset
	local next_buy_times = has_buy_times + 1
	for k,v in pairs(cfg) do
		if next_buy_times == v.reset_time then
			return v.need_gold
		end
	end
	return 0
end

function FuBenData:GetExpMaxPayTime()
	local cfg = self:GetExpFBCfg().expfb_vip_pay_time
	local max_pay_time = 0
	for k,v in pairs(cfg) do
		if v.pay_time > max_pay_time then
			max_pay_time = v.pay_time
		end
	end
	return max_pay_time
end

function FuBenData:GetExpMaxVipLevel()
	local cfg = self:GetExpFBCfg().expfb_vip_pay_time
	local max_vip_level = 0
	for k,v in pairs(cfg) do
		if v.vip_level > max_vip_level then
			max_vip_level = v.vip_level
		end
	end
	return max_vip_level
end

function FuBenData:GetExpFBLevelCfg()
	return ConfigManager.Instance:GetAutoConfig("dailyfbconfig_auto").expfb_wave
end

function FuBenData:MaxExpFB()
	return #ConfigManager.Instance:GetAutoConfig("dailyfbconfig_auto").expfb_wave
end

function FuBenData:GetRewardWave()
	local list = {}
	for k, v in pairs(self:GetExpFBLevelCfg()) do
		if v.has_first_reward == 1 then
			table.insert(list, v.wave)
		end
	end
	return list
end

function FuBenData:GetExpCurReward(wave)
	local wave = wave or self.exp_info_list.expfb_fetch_reward_wave or 0
	for k, v in pairs(self:GetExpFBLevelCfg()) do
		if v.has_first_reward == 1 and v.wave > wave then
			return v
		end
	end
	return nil
end

function FuBenData:GetExpRewardByWave(wave)
	if not wave then return end
	for k, v in pairs(self:GetExpFBLevelCfg()) do
		if v.wave == wave then
			return v
		end
	end
	return nil
end

function FuBenData:GetExpFbResetGold(reset_times)
	if not reset_times then return 0 end

	local cfg = ConfigManager.Instance:GetAutoConfig("dailyfbconfig_auto").expfb_reset or {}
	for k, v in pairs(cfg) do
		if reset_times == v.reset_time then
			return v.need_gold
		end
	end
	return 0
end

function FuBenData:GetExpPayTimes()
	if self.exp_fb_info ~= nil then
		return self.exp_fb_info.expfb_today_pay_times or 0
	end
	return 0
end

function FuBenData:GetExpEnterTimes()
	if self.exp_fb_info ~= nil then
		return self.exp_fb_info.expfb_today_enter_times or 0
	end
	return 0
end

function FuBenData:GetExpLastTimes()
	if self.exp_fb_info ~= nil then
		return self.exp_fb_info.last_enter_fb_time or 0
	end
	return 0
end

function FuBenData:GetSCDailyFBRoleInfo()
	return self.num_buy_list or 0
end

function FuBenData:GetBagRewardNum()
	local cfg = ConfigManager.Instance:GetAutoConfig("dailyfbconfig_auto").exp_other_cfg[1].item_stuff or {}
	return ItemData.Instance:GetItemNumInBagById(cfg.item_id)
end

-- 阶段副本
function FuBenData:GetPhaseFBLevelCfg()
	return ConfigManager.Instance:GetAutoConfig("phasefb_auto").fb_list
end

function FuBenData:MaxPhaseFB()
	return #ConfigManager.Instance:GetAutoConfig("phasefb_auto").fb_list
end

function FuBenData:GetPhaseChallengeDay()
	local other_cfg = ConfigManager.Instance:GetAutoConfig("phasefb_auto").other_settings
	if other_cfg then
		return other_cfg.timelimit_challenge or 5
	end
	return 5
end

function FuBenData:SetPhaseFBInfo(info_list)
	self.phase_info_list = info_list
end

function FuBenData:GetPhaseFBInfo()
	return self.phase_info_list
end

function FuBenData:ClearPhaseFBInfo()
	self.phase_info_list = {}
end

function FuBenData:GetCurFbCfgByIndex(index, level)
	local phase_select_list = self:GetPhaseFBCfgByIndex(index)
	if phase_select_list then
		for k, v in pairs(phase_select_list) do
			if level == v.fb_level then
				return v
			end
		end
	end
	return nil
end

function FuBenData:SetIsShowPhaseToggleRedPoint(index, value)
	if self.is_show_phase_toggle_red_point[index] then
		RemindManager.Instance:Fire(RemindName.FuBen_JinJie)
		self.is_show_phase_toggle_red_point[index] = value
	end
end

function FuBenData:GetIsShowPhaseToggleRedPoint(index)
	return self.is_show_phase_toggle_red_point[index] or 0
end

function FuBenData:GetPhaseFBCfgByIndex(index)
	local phase_info_cfg = self:GetPhaseFBLevelCfg()
	local phase_select_list = {}
	local left_time = FuBenData.Instance:GetLastTime()
	if phase_info_cfg then
		for k,v in pairs(phase_info_cfg) do
			if v.fb_index == index then
				if self.phase_info_list and self.phase_info_list[index] then
					if left_time > 0 then
						if self.phase_info_list[index].is_pass + 2 >= v.fb_level then
							table.insert(phase_select_list, v)
						end
					else
						if self.phase_info_list[index].is_pass >= v.fb_level then
							table.insert(phase_select_list, v)
						end
					end
				end
			end
		end
	end
	return phase_select_list
end

function FuBenData:BindPlayerDataChange()
	if self.player_data_change_callback == nil then
		self.player_data_change_callback = BindTool.Bind1(self.CheCkDataChangeRedPoint, self)
		PlayerData.Instance:ListenerAttrChange(self.player_data_change_callback)
	end
end

function FuBenData:CheCkDataChangeRedPoint(attr, value)
	if attr == "capability" then
		local left_time = FuBenData.Instance:GetLastTime()
		if left_time <= 0 then
			return
		end
		local toggle_num = self:GetToggleNum()
		if #toggle_num >= 1 then
			for i=1, #toggle_num do
				local list = self:GetPhaseFBCfgByIndex(i - 1)
				local num = #list or 0
				local real_num = 0
				local cfg_list = self:GetPhaseFBCfgByIndex(i - 1)
				for i=1, num do
					if cfg_list[i] then
						local task_id = cfg_list[i].open_task_id or 0
						local role_level = cfg_list[i].role_level or 0
						if role_level <= PlayerData.Instance:GetRoleLevel() and TaskData.Instance:GetTaskIsCompleted(task_id) then
							real_num = real_num + 1
						end
					end
				end
				if self.phase_fb_redpoint_num_record[i] == nil then
					self.phase_fb_redpoint_num_record[i] = real_num
				end
				if (real_num - self.phase_fb_redpoint_num_record[i]) >= 1 then
					self.phase_fb_redpoint_num_record[i] = real_num
					self:SetIsShowPhaseToggleRedPoint(i, 1)
				end
			end
		end
		FuBenCtrl.Instance:FlushFbViewByParam("phase")
	end
end

function FuBenData:CheCkPaTaDataChangeRedPoint(attr_name, value, old_value)
	if "capability" == attr_name then
		local arrive_capability = self:IsPowerTowerRedPoint()
		if arrive_capability then
			if not self.can_do then
				ClickOnceRemindList[RemindName.FuBen_ShiLian] = 1
				RemindManager.Instance:Fire(RemindName.FuBen_ShiLian)
				self.can_do = true
			end
		else
			self.can_do = false
		end
	end

	-- if self.is_new_power then
	-- 	local power = GameVoManager.Instance:GetMainRoleVo().capability
	-- 	if power > self.set_power then
	-- 		PlayerPrefsUtil.SetInt("fubenquality_remind", power)
	-- 		self.is_new_power = false
	-- 	end
	-- end
end

function FuBenData:GetToggleNum()
	local phase_cfg_list = self:GetPhaseFBLevelCfg()
	local num = 0
	local fuben_phase_index = nil
	local phase_toggle_list = {}
	if phase_cfg_list then
		local role_level = PlayerData.Instance:GetRoleLevel()
		for k,v in ipairs(phase_cfg_list) do
			if fuben_phase_index ~= v.fb_index then
				if role_level >= v.role_level and TaskData.Instance:GetTaskIsCompleted(v.open_task_id) and TimeCtrl.Instance:GetCurOpenServerDay() >= v.open_day then
					num = num + 1
					phase_toggle_list[num] = v
				end
				fuben_phase_index = v.fb_index
			end
		end
	end
	return phase_toggle_list
end

function FuBenData:GetOpenToggleNum()
	local phase_toggle_list = self:GetToggleNum()
	local last_toggle_list = {}
	if phase_toggle_list then
		for k,v in pairs(phase_toggle_list) do
			if v and v.fb_index then
				local is_not_pass_layer = self:GetIsNotPassAnyLayer(v.fb_index)
				if not is_not_pass_layer then
					table.insert(last_toggle_list, v)
				end
			end
		end
	end
	return last_toggle_list
end

function FuBenData:GetIsNotPassAnyLayer(index)
	if index and self.phase_info_list then
		local left_time = FuBenData.Instance:GetLastTime()
		if left_time <= 0 and self.phase_info_list[index] and self.phase_info_list[index].is_pass <= 0 then
			return true
		end
	end
	return false
end

function FuBenData:GetSaoDangToggleNum()
	local list = self:GetSaoDangData()
	return #list or 0
end

function FuBenData:GetSaoDangData()
	local saodang_list = {}
	local i = 0
	local max_buy_num = VipPower:GetParam(VipPowerId.fuben_phase_buy_times) or 0
	if self.phase_info_list then
		for k,v in pairs(self.phase_info_list) do
			if v and v.is_pass > 0 then
				local phase_cfg = self:GetCurFbCfgByIndex(k, v.is_pass)
				if phase_cfg and v.today_times < max_buy_num + phase_cfg.free_times then
					i = i + 1
					saodang_list[i] = {}
					saodang_list[i].index = k
					saodang_list[i].is_pass = v.is_pass
					saodang_list[i].list = v
				end
			end
		end
	end
	table.sort(saodang_list, SortTools.KeyUpperSorter("is_pass"))
	return saodang_list
end

function FuBenData:SetSelectLayer(layer)
	self.layer = layer
end

function FuBenData:GetSelectLayer()
	return self.layer
end

function FuBenData:SetSelectCurPage(page)
	self.cur_page = page
end

function FuBenData:GetSelectCurPage()
	return self.cur_page
end

function FuBenData:GetOpenCurPage(layer)
	local info_list = self:GetPhaseFBInfo()
	local max_cur_page = self:GetPhaseFBCfgByIndex(layer - 1)
	if layer and info_list and info_list[layer - 1] and max_cur_page then
		if info_list[layer - 1].is_pass >= self.cur_page and info_list[layer - 1].is_pass > 0 then
			local temp_cur_page = info_list[layer - 1].is_pass + 1
			if temp_cur_page > #max_cur_page then
				temp_cur_page = #max_cur_page
			end
			return temp_cur_page
		end
	end
	return self.cur_page
end

function FuBenData:GetPhaseFbResetGold(fb_index)
	if not fb_index then return 0 end

	local cfg = ConfigManager.Instance:GetAutoConfig("phasefb_auto").fb_buy_cfg or {}
	if next(cfg) then
		for k, v in pairs(cfg) do
			if v.fb_index == fb_index then
				return v.need_gold
			end
		end
	end
	return 0
end

-- VIP副本
function FuBenData:GetVipFBLevelCfg()
	local cfg = {}
	for k, v in pairs(ConfigManager.Instance:GetAutoConfig("vipfbconfig_auto").levelcfg) do
		cfg[v.level] = v
	end
	return cfg
end

function FuBenData:MaxVipFB()
	return #ConfigManager.Instance:GetAutoConfig("vipfbconfig_auto").levelcfg
end

function FuBenData:SetVipFBInfo(protocol)
	self.vip_info_list = protocol.info_list
	self.vip_pass_flag = protocol.is_pass_flag
end

function FuBenData:GetVipFBInfo()
	return self.vip_info_list
end

function FuBenData:ClearVipFBInfo()
	self.vip_info_list = {}
end

function FuBenData:GetVipFBIsPass(index)
	if not index then return false end

	local bit_list = bit:d2b(self.vip_pass_flag)
	for k, v in pairs(bit_list) do
		if v == 1 and (32 - k) == index then
			return true
		end
	end

	return false
end

-- -- 血战红点显示
-- function FuBenData:IsShowXueZhanRedPoint()
-- 	local special_info = self:GetTuituSpecialFbInfo()
-- 	local special_other_cfg = self:GetPushFBOtherCfg()
-- 	if nil == special_info or nil == special_other_cfg then
-- 		return
-- 	end
-- 	local left_num = special_info.buy_join_times - special_info.today_join_times + special_other_cfg.hard_free_join_times
-- 	if left_num > 0 then
-- 		return 1
-- 	else
-- 		return 0
-- 	end
-- end

function FuBenData:GetGaoZhanFuBenPoint()
	local num = 0
	if self:IsShowWeaponFBRedPoint() >= 1 then
		return 1
		-- num = num + 1
	end
	if self:IsShowArmorFBRedPoint() >= 1 then
		return 1
		-- num = num + 1
	end
	if self:IsShowQualityFBRedPoint() >= 1 then
		return 1
		-- num = num + 1
	end
	if self:IsShowTowerFBRedPoint() >= 1 then
		return 1
		-- num = num + 1
	end
	if self:IsShowGuardFBRedPoint() >= 1 then
		return 1
		-- num = num + 1
	end
	return num
end

function FuBenData:IsShowPhaseFBRedPoint()
	if not OpenFunData.Instance:CheckIsHide("fb_phase") then
		return 0
	end

	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local num_list = self:GetOpenToggleNum() or {}
	local left_time = FuBenData.Instance:GetLastTime()
	for k, v in pairs(self.phase_info_list) do
		for k2, v2 in pairs(self:GetOpenToggleNum()) do
			if left_time > 0 then
				if v and v.is_pass <= 0 and v2 and v2.fb_index == k and v.today_times <= 0 and v2.role_level <= role_level and TaskData.Instance:GetTaskIsCompleted(v2.open_task_id) and (k + 1) <= #num_list then
					local flag = self:GetIsShowPhaseToggleRedPoint(k + 1)
					if flag > 0 then
						return 1
					end
				end
			else
				if v and v.is_pass <= 0 and v2 and v2.fb_index == k and v.today_times <= 0 and v2.role_level <= role_level and TaskData.Instance:GetTaskIsCompleted(v2.open_task_id) then
					local flag = self:GetIsShowPhaseToggleRedPoint(v2.fb_index + 1)
					if flag > 0 then
						return 1
					end
				end
			end
		end
	end

	local saodang_redpoint_num = self:GetSaoDangRedPointNum()
	if saodang_redpoint_num == 1 then
		return 1
	end

	return 0
end

function FuBenData:GetSaoDangRedPointNum()
	if self.is_click_saodang == false then
		local data_list = self:GetSaoDangData()
		if data_list then
			for k, v in pairs(data_list) do
				if v.index and v.is_pass then
					local fuben_cfg = self:GetCurFbCfgByIndex(v.index, v.is_pass)
					local fuben_info = self:GetPhaseFBInfo()
					if fuben_cfg and fuben_info and fuben_info[v.index] then
						local has_buy_times = fuben_info[v.index].today_buy_times or 0		
						local enter_count = fuben_cfg.free_times + has_buy_times - fuben_info[v.index].today_times or 0
						if enter_count > 0 then
							return 1
						end
					end
				end
			end
		end
	end
	return 0
end

function FuBenData:SetClickSaoDang()
	self.is_click_saodang = true
	RemindManager.Instance:Fire(RemindName.FuBen_JinJie)
end

function FuBenData:GetExpFBTime()
	return self:GetExpFBOtherCfg().time_limit or 0
end

function FuBenData:IsShowExpFBRedPoint()
	if not OpenFunData.Instance:CheckIsHide("fb_exp") then
		return 0
	end
	local now_time = TimeCtrl.Instance:GetServerTime()
	local time = self:GetExpLastTimes() + self:GetExpFBOtherCfg().interval_time - now_time
	if time > 0 then
		local function delay_callback()
			if self.exp_tiem_quest then
				GlobalTimerQuest:CancelQuest(self.exp_tiem_quest)
			end
			self.exp_tiem_quest = nil
			RemindManager.Instance:Fire(RemindName.FuBen_Exp)
		end
		if self.exp_tiem_quest then
			GlobalTimerQuest:CancelQuest(self.exp_tiem_quest)
		end
		self.exp_tiem_quest = GlobalTimerQuest:AddDelayTimer(delay_callback, time)
		
		return 0
	end
	if self:GetExpPayTimes() + self:GetExpFBOtherCfg().day_times - self:GetExpEnterTimes() > 0 and FuBenCtrl.Instance:GetExpRemind() then
		return 1
	end
	return 0
end

function FuBenData:IsShowStoryFBRedPoint()
	if not OpenFunData.Instance:CheckIsHide("fb_story") then
		return false
	end

	local role_level = PlayerData.Instance:GetRoleLevel()
	for k, v in pairs(self.story_info_list) do
		if v.today_times <= 0 and self:GetStoryFBLevelCfg()[k + 1] and
		self:GetStoryFBLevelCfg()[k + 1].role_level <= role_level and k < self:MaxStoryFB() then
			return true
		end
	end
	return false
end

function FuBenData:IsShowVipFBRedPoint()
	if not OpenFunData.Instance:CheckIsHide("fb_vip") then
		return false
	end

	local vo = GameVoManager.Instance:GetMainRoleVo()
	for k, v in pairs(self.vip_info_list) do
		if v.today_times <= 0 and self:GetVipFBLevelCfg()[k] and self:GetVipFBLevelCfg()[k].enter_level <= vo.vip_level then
			return true
		end
	end
	return false
end

function FuBenData:IsShowTowerFBRedPoint()
	if ClickOnceRemindList[RemindName.FuBen_ShiLian] == 0 then
		return 0
	end

	local fb_info = FuBenData.Instance:GetTowerFBInfo()
	if next(fb_info) then
		local is_max_level = fb_info.pass_level >= FuBenData.Instance:MaxTowerFB()
		if is_max_level then
			return 0
		end
	end
	if not OpenFunData.Instance:CheckIsHide("fb_tower") then
		return 0
	end

	if nil == next(self.tower_info_list) then 
		return 0
	end

	if self.tower_info_list.today_level < self.tower_info_list.pass_level then
		return 1
	end

	if self:IsPowerTowerRedPoint() then
		return 1
	end
	return 0
end

function FuBenData:IsPowerTowerRedPoint()
	if nil ==  next(self.tower_info_list) then return end
	local capability = GameVoManager.Instance:GetMainRoleVo().capability
	if self.patafb_level_cfg[self.tower_info_list.today_level + 1] then
		if capability >= self.patafb_level_cfg[self.tower_info_list.today_level + 1].capability then
			return true
		end
	end
	return false
end

function FuBenData:PowerTowerCanChallange()
	if not OpenFunData.Instance:CheckIsHide("fb_tower") or nil == next(self.tower_info_list) then
		return false
	end
	local capability = GameVoManager.Instance:GetMainRoleVo().capability
	if self.patafb_level_cfg[self.tower_info_list.today_level + 1] then
		if capability >= self.patafb_level_cfg[self.tower_info_list.today_level + 1].capability then
			return true
		end
	end
	return false
end

function FuBenData:GetBeStrengthRedmind()
	local num = self:StrenthenRemindNum()
	MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.Strength, num > 0)
	return num
end

function FuBenData:StrenthenRemindNum()
	local num = 0
	if self:PowerTowerCanChallange() then
		-- num = num + 1
		return 1
	end
	if GuaJiTaData.Instance:RuneTowerCanChallange() then
		-- num = num + 1
		return 1
	end
	if FuBenData.Instance:CheckIsOpenFubenQuality() then
		-- num = num + 1
		return 1
	end
	if PackageData.Instance:CheckBagBatterEquip() ~= 0 then
		-- num = num + 1
		return 1
	end
	-- if RuneData.Instance:GetBagHaveRuneGift() then
	-- 	num = num + 1
	-- end
	-- if FuBenData.Instance:GetIsCanPushCommonFb(PUSH_FB_TYPE.PUSH_FB_TYPE_HARD) then
	-- 	num = num + 1
	-- end
	return num
end

function FuBenData:IsShowKuafuFbRedPoint()
	if not OpenFunData.Instance:CheckIsHide("fb_many_people") then
		return false
	end

	local total_count = self:GetManyFbTotalCount() or 0
	return self.team_equip_fb_day_count < total_count
end

-- 主界面红点提示
function FuBenData:IsShowFubenRedPoint()

	-- if ShowRedPoint.SHOW_RED_POINT == self:IsShowXueZhanRedPoint() then
	-- 	return 1
	-- end

	if ShowRedPoint.SHOW_RED_POINT == self:IsShowPhaseFBRedPoint() then
		return 1
	end

	if ShowRedPoint.SHOW_RED_POINT == self:IsShowExpFBRedPoint() then
		return 1
	end

	-- if ShowRedPoint.SHOW_RED_POINT == self:IsShowTowerFBRedPoint() then
	-- 	return 1
	-- end
	if ShowRedPoint.SHOW_RED_POINT == self:IsShowDefenseFBRedPoint() then
		return 1
	end
	-- if ShowRedPoint.SHOW_RED_POINT == self:IsShowQualityFBRedPoint() then
	-- 	return 1
	-- end

	-- if ShowRedPoint.SHOW_RED_POINT == self:IsShowGuardFBRedPoint() then
	-- 	return 1
	-- end

	if ShowRedPoint.SHOW_RED_POINT == self:IsShowTeamFBRedPoint() then
		return 1
	end

	return 0
end

function FuBenData:SetRedPointCd(str_param)
	if str_param == "exp" then
		self.exp_red_point_cd = Status.NowTime + FLUSH_REDPOINT_CD
	elseif str_param == "tower" then
		self.tower_red_point_cd = Status.NowTime + FLUSH_REDPOINT_CD
	end
end

function FuBenData:GetInSpireDamage()
	if self.exp_fb_info and self.exp_fb_info.guwu_times then
		return self.exp_fb_info.guwu_times * (self:GetExpFBCfg().exp_other_cfg[1].buff_add_gongji_per/100)
	end
	return 0
end

function FuBenData:GetExpFuBenGuWuCount()
	if self.exp_fb_info and self.exp_fb_info.guwu_times then
		return self.exp_fb_info.guwu_times
	end
	return 0
end

function FuBenData:GetExpOpenLevel()
	local exp_cfg = self:GetExpFBCfg()
	if exp_cfg and exp_cfg.exp_other_cfg then
		return exp_cfg.exp_other_cfg[1].open_level
	end
	return 0
end

-- 组队装备副本
-- 组队装备副本配置表
function FuBenData:GetManyConfig()
	if not self.many_config then
		self.many_config = ConfigManager.Instance:GetAutoConfig("team_equip_fb_auto")
	end
	return self.many_config
end

function FuBenData:GetRoomInfo()
	local layer = 0
	local scene_id = Scene.Instance:GetSceneId() or 0
	local config = self:GetManyConfig()
	if config then
		local fb_config = config.fb_config
		if fb_config then
			for k,v in pairs(fb_config) do
				if v.scene_id == scene_id then
					layer = v.layer
					break
				end
			end
		end
	end
	return layer
end

function FuBenData:GetConfigByLayer(layer)
	local config = self:GetManyConfig()
	if config then
		local fb_config = config.fb_config
		if fb_config then
			for k,v in pairs(fb_config) do
				if v.layer == layer then
					return v
				end
			end
		end
	end
end

function FuBenData:GetShowConfigByLayer(layer)
	local config = self:GetManyConfig()
	if config then
		local show_message = config.show_message
		if show_message then
			return show_message[layer]
		end
	end
end

function FuBenData:GetCrossFBCount()
	local config = self:GetManyConfig()
	local count = 0
	local level = GameVoManager.Instance:GetMainRoleVo().level
	local no_active_count = 0
	if config then
		local list = config.fb_config
		table.sort(list, function(a, b)
			return a.layer < b.layer
		end)

		for k,v in pairs(list) do
			if no_active_count >= 1 then
				break
			end
			if v.level_limit <= level then
				count = count + 1
			else
				no_active_count = no_active_count + 1
			end
		end
	end
	return count + no_active_count
end

function FuBenData:GetManyFBCount()
	return self.team_equip_fb_day_count
end

function FuBenData:GetManyFBMaxCount()
	local count = 0
	local config = self:GetManyConfig()
	if config then
		count = config.other[1].max_count or 0
	end
	return count
end

function FuBenData:GetMoJingByLayer(layer)
	local mojing = 0
	local config = self:GetConfigByLayer(layer)
	if config then
		mojing = config.mojing or 0
	end
	return mojing
end

function FuBenData:SetManyFbInfo(protocol)
	self.many_fb_user_count = protocol.user_count
	self.many_fb_user_info = protocol.user_info
end

function FuBenData:GetManyFbInfo()
	return {user_count = self.many_fb_user_count, user_info = self.many_fb_user_info}
end

function FuBenData:SetTeamEquipFbDropCountInfo(protocol)
	self.team_equip_fb_pass_flag = protocol.team_equip_fb_pass_flag
	self.team_equip_fb_day_count = protocol.team_equip_fb_day_count
	self.team_equip_fb_day_buy_count = protocol.team_equip_fb_day_buy_count
end

function FuBenData:GetManyFbTotalCount()
	local max_count = self:GetManyFBMaxCount() or 0
	return max_count + self.team_equip_fb_day_buy_count
end

function FuBenData:GetManyFbPrice()
	local price = 0
	local config = self:GetManyConfig()
	if config then
		local buy_times_cost = config.buy_times_cost or {}
		for i = #buy_times_cost, 1, -1 do
			price = buy_times_cost[i].gold_cost
			if buy_times_cost[i].buytimes <= self.team_equip_fb_day_buy_count then
				break
			end
		end
	end
	return price
end

-- 得到组队装备副本加成
function FuBenData:GetManyFbValueByNum(num)
	local value = 0
	local config = self:GetManyConfig()
	if config then
		for k,v in pairs(config.team_drop) do
			if v.team_num == num then
				value = v.drop
				break
			end
		end
	end
	return value
end

-- 得到组队装备副本购买次数
function FuBenData:GetManyFbBuyCountByVip(vip_level)
	local count = 0
	local vip_config = VipData.Instance:GetVipLevelCfg()
	if vip_config then
		local vip_box_info = vip_config[VIPPOWER.TEAM_EQUIP_COUNT]
		if vip_box_info then
			count = vip_box_info["param_" .. vip_level]
		end
	end
	return count
end

function FuBenData:GetManyFbBuyCount()
	return self.team_equip_fb_day_buy_count
end

--记录选择的组队装备副本层级
function FuBenData:SetSelectFuBenLayer(layer)
	self.select_many_fuben_layer = layer
end

function FuBenData:GetSelectFuBenLayer()
	return self.select_many_fuben_layer
end

function FuBenData:SetTeamFbRoomList(protocol)
	self.fb_list.count = protocol.count
	self.fb_list.team_type = protocol.team_type
	self.fb_list.room_list = protocol.room_list
end

function FuBenData:ClearTeamFbRoomList()
	self.fb_list.count = 0
	self.fb_list.room_list = {}
end

function FuBenData:GetTeamFbRoomList()
	if self.fb_list and self.fb_list.room_list then
		function sortfun(a, b)
			if a.flag > b.flag then
				return false
			elseif a.flag == b.flag then
				return a.menber_num > b.menber_num
			else
				return true
			end
		end
		table.sort(self.fb_list.room_list, sortfun)
	end
	return self.fb_list
end

function FuBenData:GetTeamFbTeamCount(team_type)
	if team_type == self.fb_list.team_type then
		return self.fb_list.count
	end
	return 0
end

function FuBenData:SetTeamFbRoomEnterAffirm(protocol)
	self.enter_affirm_info.team_type = protocol.team_type
	self.enter_affirm_info.mode = protocol.mode
	self.enter_affirm_info.layer = protocol.layer
end

function FuBenData:GetTeamFbRoomEnterAffirm()
	return self.enter_affirm_info
end

--------------- FBIconView  --------------
function FuBenData:SaveMonsterDiffTime(diff_time, index)
	index = index or 1
	self.cache_diff_time_list[index] = diff_time
end

function FuBenData:SaveMonsterInfo(monster_id, index)
	index = index or 1
	self.cache_monster_id_list[index] = monster_id
end

function FuBenData:SaveShowMonsterHadFlush(enable, flush_text, index)
	index = index or 1
	self.cache_monster_flush_info_list[index] = {}
	self.cache_monster_flush_info_list[index].enable = enable
	self.cache_monster_flush_info_list[index].flush_text = flush_text
end

function FuBenData:SaveMonsterIconState(enable, index)
	index = index or 1
	self.cache_monster_icon_enable_list[index] = enable
end

function FuBenData:SaveMonsterIconGray(enable, index)
	index = index or 1
	self.cache_monster_icon_gray_list[index] = enable
end

function FuBenData:GetMonsterDiffTimeCache()
	return self.cache_diff_time_list
end

function FuBenData:GetMonsterInfoCache()
	return self.cache_monster_id_list
end

function FuBenData:GetShowMonsterHadFlushCache()
	return self.cache_monster_flush_info_list
end

function FuBenData:GetMonsterIconStateCache()
	return self.cache_monster_icon_enable_list
end

function FuBenData:GetMonsterIconGrayCache()
	return self.cache_monster_icon_gray_list
end

function FuBenData:ClearFBIconCache()
	self.cache_diff_time_list = {}
	self.cache_monster_id_list = {}
	self.cache_monster_flush_info_list = {}
	self.cache_monster_icon_enable_list = {}
	self.cache_monster_icon_gray_list = {}
end

function FuBenData:GetChallengCfgByLevel(level)
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("challengefbcfg_auto").chaptercfg) do
		if level == v.level then
			local list = TableCopy(v)
			local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
			local prof = PlayerData.Instance:GetRoleBaseProf(main_role_vo.prof)
			local item_list = {}
			item_list = Split(list["item_list" .. prof], "|")
			list.item_list = item_list
			list.icon = v.icon
			return list
		end
	end
	return nil
end

function FuBenData:GetChallengStarInfo(level)
	local cfg = {}
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("challengefbcfg_auto").chaptercfg) do
		if level == v.level then
			cfg = v
			break
		end
	end
	local star_info = {}
	if next(cfg) then
		for i = 1 , 3 do
			if cfg["star_max_time_" .. i] then
				star_info[i] = cfg["star_max_time_" .. i]
			end
		end

	end
	return star_info
end

function FuBenData:GetChallengLayerCfgByLevelAndLayer(level, layer)
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("challengefbcfg_auto").levelcfg) do
		if level == v.level and layer == v.layer then
			return v
		end
	end
	return nil
end

function FuBenData:GetChallengLayerCfgBySceneId(scene_id)
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("challengefbcfg_auto").levelcfg) do
		if scene_id == v.scene_id then
			return v
		end
	end
	return nil
end

function FuBenData:GetTotalLayerByLevel(level)
	local total_layer = 0
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("challengefbcfg_auto").levelcfg) do
		if level == v.level then
			total_layer = total_layer + 1
		end
	end
	return total_layer
end

function FuBenData:GetChallengCfgLength()
	local lenghth = 0
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("challengefbcfg_auto").chaptercfg) do
		lenghth = lenghth + 1
	end

	local show_index = FuBenData.Instance:GetCanChallengeMaxLevel() + 2
	if show_index and 0 < show_index and show_index <= lenghth then
		lenghth = show_index
	end
	return lenghth
end

function FuBenData:GetChallengOtherCfg()
	return self.challenge_other_cfg
end

function FuBenData:GetCostGoldByTimes(buy_times)
	local cost = 0
	if nil == self.challenge_buycost_cfg then
		return cost
	end
	for k, v in ipairs(self.challenge_buycost_cfg) do
		if buy_times >= v.buy_times then
			cost = v.gold_cost
			break
		end
	end
	return cost
end

function FuBenData:SetChallengeFbInfo(protocol)
	self.quality_enter_count = protocol.enter_count
	self.quality_buy_count = protocol.buy_count
	self.challenge_all_info = protocol.level_list
end

function FuBenData:GetQualityEnterCount()
	return self.quality_enter_count
end

function FuBenData:GetQualityBuyCount()
	return self.quality_buy_count
end

function FuBenData:GetOneLevelChallengeInfoByLevel(level)
	return self.challenge_all_info[level]
end

function FuBenData:SetHasEnterChallengeFb()
	self.have_enter_challenge = true
end

function FuBenData:GetCanChallengeMaxLevel()
	for k,v in pairs(self.challenge_all_info) do
		if v.is_pass <= 0 then
			if k > 0 then
				if self.challenge_all_info[k - 1].history_max_reward >= 3 then
					return k 
				else
					return k - 1
				end
			else
				return k
			end
		end
	end

	return #self.challenge_all_info
end

-- 守护红点提示
function FuBenData:IsShowGuardFBRedPoint()
	if not OpenFunData.Instance:CheckIsHide("fb_guard") then
		return 0
	end
	local info = self.armor_info
	if nil == next(info) then return 0 end
	local other_cfg = ConfigManager.Instance:GetAutoConfig("towerdefendteam_auto").other[1]
	if other_cfg.free_join_times + info.buy_join_times - info.join_times > 0 and FuBenCtrl.Instance:GetGuardRemind() then
		return 1
	end
	return 0
end

function FuBenData:GetTowerDefendOtherCfg()
	local other_cfg = ConfigManager.Instance:GetAutoConfig("towerdefendteam_auto").other[1]
	return other_cfg
end

-- 武器材料红点提示
function FuBenData:IsShowWeaponFBRedPoint()
	if not OpenFunData.Instance:CheckIsHide("fb_weapon") then
		return 0
	end
	local info = self.weapon_materials_info
	local other_cfg = self:GetWeaponCfgOther()
	if info == nil or other_cfg == nil then return 0 end
	if info.today_buy_times and info.today_fight_all_times and other_cfg.day_total_count + info.today_buy_times - info.today_fight_all_times > 0 and FuBenCtrl.Instance:GetWeaponRemind() then
		return 1
	end
	if info.chapter_list then
		for i,v in ipairs(info.chapter_list) do
			if v.red then
				return 1
			end
		end
	end

	local data_list = KaifuActivityData.Instance:GetFBTouZiDataList()
	for i, v in ipairs(data_list) do
		if not InvestData.Instance:CheckIsFetchedFbByID(v.index + 1) and InvestData.Instance:CheckIsActiveFbByID(v.index + 1) then
			return 1
		end
	end

	return 0
end

-- 防具材料红点提示
function FuBenData:IsShowArmorFBRedPoint()
	if not OpenFunData.Instance:CheckIsHide("fb_armor") then
		return 0
	end

	local info = self.tower_defend_role_info 
	local other_cfg = self:GetArmorDefendCfgOther()

	if next(info) == nil or next(other_cfg) == nil then return 0 end
	if other_cfg.free_join_times + info.buy_join_times - info.join_times > 0 and FuBenCtrl.Instance:GetArmorRemind() then
		return 1
	end
	return 0
end

-- 塔防（建塔）红点提示
function FuBenData:IsShowDefenseFBRedPoint()
	if not OpenFunData.Instance:CheckIsHide("fb_defense") then
		return 0
	end

	local tf_fb_buy_num = self.defense_buy_times > 0 and self.defense_buy_times or self.defense_times
	local tf_cfg_other = self:GetDefenseTowerOtherCfg()
	if tf_fb_buy_num == nil or tf_cfg_other == "" then return 0 end
	if tf_cfg_other.enter_free_times + tf_fb_buy_num - self.defense_enter_times > 0 and FuBenCtrl.Instance:GetDefenseRemind() then
		return 1
	end
	return 0
end

function FuBenData:IsShowTeamFBRedPoint()
	if not OpenFunData.Instance:CheckIsHide("fb_team_tower") then
		return 0
	end

	local fb_team_tower_reward_list = self:GetFBTowerRewardInfo()
	local open_list = self:GetOpenList()
	local level = GameVoManager.Instance:GetMainRoleVo().level or 0
	if self.fuben_cell_info == nil or self.fuben_cell_info == "" then return 0 end
	for i = 1, 2 do
		local level_limit = open_list[i] and open_list[i] or 0
		-- if TeamFBType[i] and fb_team_tower_reward_list and fb_team_tower_reward_list[TeamFBType[i]] and fb_team_tower_reward_list[TeamFBType[i]].fb_type == TeamFBType[i] then
		-- 	if fb_team_tower_reward_list[TeamFBType[i]].today_buy_times then
		-- 		if self.fuben_cell_info[i] and self.fuben_cell_info[i].remain_times <= 0 
		-- 			and fb_team_tower_reward_list[TeamFBType[i]].today_buy_times < 2 then
		-- 			return 1
		-- 		end
		-- 	end
		-- end
		-- local is_show = RemindManager.Instance:RemindToday(RemindName.FuBen_Team)
		-- if is_show then
		-- 	return 0
		-- end
		if self.fuben_cell_info[i] and self.fuben_cell_info[i].remain_times > 0 and level >= level_limit and FuBenCtrl.Instance:GetTeamRemind() then
			return 1
		end
	end
	return 0
end

function FuBenData:IsShowQualityFBRedPoint()
	if ClickOnceRemindList[RemindName.FuBen_HuanJing] == 0 then
		return 0
	end
	if not OpenFunData.Instance:CheckIsHide("fb_quality") then
		return 0
	end
	local show_red_point = false
	-- local other_cfg = self:GetChallengOtherCfg()
	-- if nil == other_cfg then
	-- 	return show_red_point and 1 or 0
	-- end

	-- --判断是否有挑战次数
	-- local day_free_times = other_cfg.day_free_times
	-- local buy_times = self:GetQualityBuyCount()
	-- local total_times = day_free_times + buy_times
	-- local enter_times = self:GetQualityEnterCount()
	-- local left_times = total_times - enter_times
	-- if left_times > 0 then
	-- 	show_red_point = true
	-- end
	if self:CheckIsOpenFubenQuality() then
		return 1
	end
	return show_red_point and 1 or 0
end

function FuBenData:SetPassLayerInfo(protocol)
	self.pass_layer_info = protocol.info
end

function FuBenData:GetPassLayerInfo()
	return self.pass_layer_info
end

function FuBenData:SetChallengeInfoList(protocol)
	self.challenge_fb_info = protocol.info
end

function FuBenData:GetChallengeInfoList()
	return self.challenge_fb_info
end

function FuBenData:GetCanEnterByLevel(level)
	if level < 1 then return true end
	local cfg = self:GetChallengCfgByLevel(level)
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	if cfg and role_level < cfg.role_level then
		return false
	end
	local last_data = self:GetOneLevelChallengeInfoByLevel(level - 1)
	if last_data and (last_data.is_pass ~= 1 or last_data.history_max_reward < 3) then
		return false
	end
	return true
end

function FuBenData:IsCanShowQualityEnterByLevel(level)
	local fb_info = self:GetOneLevelChallengeInfoByLevel(level)
	local capability = GameVoManager.Instance:GetMainRoleVo().capability
	local cur_layer = fb_info.fight_layer < 0 and 0 or fb_info.fight_layer
	local layer_cfg = self:GetChallengLayerCfgByLevelAndLayer(level, cur_layer)
	if capability < layer_cfg.zhanli then
		return false
	end
	return true
end

function FuBenData:GetQualityDefindIndex()
	if not OpenFunData.Instance:CheckIsHide("fb_quality") then
		return 0
	end
	local cur_flag = false
	local length = self:GetChallengCfgLength()
	for i = 0, length - 1 do
		local info = self:GetOneLevelChallengeInfoByLevel(i)
		cur_flag = self:GetCanEnterByLevel(i) and (info.state == 0 or info.state == 2) and self:IsCanShowQualityEnterByLevel(i)
		if not cur_flag then
			cur_flag = self:GetCanEnterByLevel(i) and (info.state == 0 or info.state == 2) and info.history_max_reward >= 3
		end
		if cur_flag then
			return i
		end
	end
	return 0
end

function FuBenData:SetQualitySelectIndex(index)
	self.quality_index_select = index
end

function FuBenData:GetQualitySelectIndex()
	return self.quality_index_select
end

function FuBenData:SetTowerDefendRoleInfo(info)
	self.tower_defend_role_info.join_times = info.join_times
	self.tower_defend_role_info.buy_join_times = info.buy_join_times
	self.tower_defend_role_info.max_pass_level = info.max_pass_level
	self.tower_defend_role_info.auto_fb_free_times = info.auto_fb_free_times
	self.tower_defend_role_info.item_buy_join_times = info.item_buy_join_times
	self.tower_defend_role_info.personal_last_level_star = info.personal_last_level_star
end

function FuBenData:GetTowerDefendRoleInfo()
	return self.tower_defend_role_info
end

function FuBenData:SetSelectLevel(level)
	self.select_level = level
end

function FuBenData:GetSelectLevel()
	return self.select_level
end

function FuBenData:GetCurTowerDefendLevel()
	return self.tower_defend_role_info.max_pass_level == - 1 and 0  or (self.tower_defend_role_info.max_pass_level + 1)
end

function FuBenData:SetAutoFBRewardDetail2(info)
	self.tower_defend_auto_reward_info.fb_type = info.fb_type
	self.tower_defend_auto_reward_info.reward_coin = info.reward_coin
	self.tower_defend_auto_reward_info.reward_exp = info.reward_exp
	self.tower_defend_auto_reward_info.reward_xianhun = info.reward_xianhun
	self.tower_defend_auto_reward_info.reward_yuanli = info.reward_yuanli
	self.tower_defend_auto_reward_info.item_list = info.item_list
end

function FuBenData:SetTowerDefendInfo(info)
	self.tower_defend_fb_info.reason = info.reason
	self.tower_defend_fb_info.time_out_stamp = info.time_out_stamp
	self.tower_defend_fb_info.is_finish = info.is_finish
	self.tower_defend_fb_info.is_pass = info.is_pass
	self.tower_defend_fb_info.pass_time_s = info.pass_time_s
	self.tower_defend_fb_info.life_tower_left_hp = info.life_tower_left_hp
	self.tower_defend_fb_info.life_tower_left_maxhp = info.life_tower_left_maxhp
	self.tower_defend_fb_info.curr_wave = info.curr_wave
	self.tower_defend_fb_info.curr_level = info.curr_level
	self.tower_defend_fb_info.next_wave_refresh_time = info.next_wave_refresh_time
	self.tower_defend_fb_info.clear_wave_count = info.clear_wave_count
	self.tower_defend_fb_info.death_count = info.death_count
	self.tower_defend_fb_info.get_coin = info.get_coin
	self.tower_defend_fb_info.pick_drop_list = info.pick_drop_list

end

function FuBenData:GetTowerDefendInfo()
	return self.tower_defend_fb_info
end

function FuBenData:GetPhaseSaoDangReward()
	local reward_list = {}
	if self.phase_saodang_list then
		for k,v in pairs(self.phase_saodang_list) do
			if v.is_pass > 0 then
				local fuben_cfg = FuBenData.Instance:GetPhaseFBCfgByIndex(k - 1)
				if v and v.enter_count and fuben_cfg and fuben_cfg[v.is_pass] then
					for i = 1,v.enter_count do
						self.count = self.count + 1
						reward_list[self.count] = {}
						reward_list[self.count] = fuben_cfg[v.is_pass].reset_reward[0]
					end
				end
			end
		end
	end
	return reward_list
end

function FuBenData:SetPhaseSaoDangList(data)
	self.phase_saodang_list = data
end

function FuBenData:GetSaoDangInfoData()
	local saodang_data_list = {}
	local saodang_bind_list = {}
	local reward_item_list = self:GetPhaseSaoDangReward()
	if reward_item_list then
		for k,v in pairs(reward_item_list) do
			saodang_data_list[v.item_id] = saodang_data_list[v.item_id] or 0
			saodang_data_list[v.item_id] = saodang_data_list[v.item_id] + v.num
			saodang_bind_list[v.item_id] = v.is_bind
		end
	end
	local reward_list = {}
	for m,n in pairs(saodang_data_list) do
		if m and n and saodang_bind_list[m] then
			table.insert(reward_list, {is_bind = saodang_bind_list[m], item_id = m, num = n})
		end
	end

	return reward_list
end

function FuBenData:SetFBDropInfo(info)
	self.drop_info.get_coin = info.get_coin
	self.drop_info.get_item_count = info.get_item_count
	self.drop_info.item_list = info.item_list
end

function FuBenData:GetFBDropInfo()
	return self.drop_info
end

function FuBenData:GetFBDropItemInfo()
	if self.drop_info and self.drop_info.item_list then
		local last_reward_info = {}
		for k,v in pairs(self.drop_info.item_list) do
			if v and v.item_id > 0 and v.num > 0 then
				local quality = ItemData.Instance:GetItemQuailty(v.item_id)
				v.quality = quality
				table.insert(last_reward_info, v)
			end
		end
		table.sort(last_reward_info, SortTools.KeyUpperSorter("quality"))
		return last_reward_info
	end
end

function FuBenData:GetFBDropInfoItemNum()
	local reward_info = self:GetFBDropItemInfo()
	if reward_info then
		return #reward_info
	end
	return 0
end

function FuBenData:ClearFBDropInfo()
	self.drop_info.item_list = {}
	self.drop_info.get_item_count = 0
end

function FuBenData:GetTowerDefendChapterCfg(chapter)
	-- local level_scene_cfg = ConfigManager.Instance:GetAutoConfig("towerdefendteam_auto").level_scene_cfg
	-- return level_scene_cfg[chapter]

	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("fb_armor_defend_auto").level_scene_cfg) do
		if chapter - 1  == v.level then
			local list = TableCopy(v)
			local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
			local prof = PlayerData.Instance:GetRoleBaseProf(main_role_vo.prof)
			local item_list = {}
			item_list = Split(list["item_list" .. prof], "|")
			list.item_list = item_list
			list.icon = v.icon
			return list
		end
	end
	return nil
end

function FuBenData:GetTowerDefendChapterCfg2(chapter)
	local level_scene_cfg = ConfigManager.Instance:GetAutoConfig("fb_armor_defend_auto").level_scene_cfg
	return level_scene_cfg[chapter]
end

function FuBenData:GetTowerDefendChapterNum()
	local level_scene_cfg = ConfigManager.Instance:GetAutoConfig("towerdefendteam_auto").level_scene_cfg
	if self.tower_defend_role_info == nil and next(self.tower_defend_role_info) == nil then
		return
	end
	local num = #level_scene_cfg
	-- if level_scene_cfg[chapter] then
	-- 	for k,v in pairs(level_scene_cfg[chapter]) do
	-- 		num = num + 1
	-- 	end
	-- end
 	
 	if num - self.tower_defend_role_info.max_pass_level <= 3 then
 		return num
	else
		num = self.tower_defend_role_info.max_pass_level + 3
	end
	return num
end

function FuBenData:GetTowerWaveCfg(level)
	local wave_list = ConfigManager.Instance:GetAutoConfig("towerdefendteam_auto").wave_list
	local cfg = {}
	for i,v in ipairs(wave_list) do
		if v.level == level then
			table.insert(cfg, v)
		end
	end
	return cfg
end

function FuBenData:GetTowerBuyCost(count)
	local buy_cost = ConfigManager.Instance:GetAutoConfig("towerdefendteam_auto").buy_cost
	local cfg = {}
	for i,v in ipairs(buy_cost) do
		if v.buy_times == count then
			return v.gold_cost
		end
	end
	return buy_cost[#buy_cost].gold_cost
end

function FuBenData:GetPushFBInfo(fb_type, chapter, level)
	if nil == self.tuitu_fb_info_cfg then return nil end
	if nil == self.tuitu_fb_info_cfg[fb_type] or
		nil == self.tuitu_fb_info_cfg[fb_type][chapter] then
		return nil
	end
	if level then
		return self.tuitu_fb_info_cfg[fb_type][chapter][level]
	end
	return self.tuitu_fb_info_cfg[fb_type][chapter]
end

function FuBenData:StarCfgInfo(fb_type, chapter, level)
	local star_info_cfg = {}
	local cur_level_cfg = self:GetPushFBInfo(fb_type, chapter, level)
	if nil == cur_level_cfg then
		return star_info_cfg
	end
	for i = 1 , 3 do
		if cur_level_cfg["time_limit_" .. i .."_star"] then
			table.insert(star_info_cfg, cur_level_cfg["time_limit_" .. i .."_star"])
		end
	end
	return star_info_cfg
end

function FuBenData:GetPushFbMaxChapter(fb_type)
	local list_cfg = self.tuitu_fb_info_cfg[fb_type]
	if nil == list_cfg then
		return 0
	end

	local max_chapter = 0
	for k, v in pairs(list_cfg) do
		if k > max_chapter then
			max_chapter = k
		end
	end

	return max_chapter
end

function FuBenData:GetMaxLevelByTypeAndChapter(fb_type, fb_chapter)
	local max_level = 0
	if fb_type == 0 then
		local cfg = self.tuitu_fb_info_cfg[fb_type][fb_chapter]
		for k,v in pairs(cfg) do
			if v.level > max_level then
				max_level = v.level
			end
		end
	else
		local boss_cfg = self.tuitu_fb_info_cfg[fb_type]
		local max_chapter = 0
		for k,v in pairs(self.tuitu_fb_info_cfg[fb_type]) do
			if k > max_chapter then
				max_chapter = k
			end
		end
		if fb_chapter == max_chapter then
			return #self.tuitu_fb_info_cfg[fb_type][fb_chapter]
		else
			return 9999
		end
	end
	return max_level
end

function FuBenData:GetCanEnterPushFB(fb_type)
	local all_push_info = self.tuitu_all_info_list and self.tuitu_all_info_list.fb_info_list[fb_type + 1] or {}
	local buy_join_times = all_push_info.buy_join_times or 0
	local today_join_times = all_push_info.today_join_times or 0
	local free_join_times = 0
	if fb_type == 0 then
		free_join_times = self:GetPushFBOtherCfg().normal_free_join_times
	else
		free_join_times = self:GetPushFBOtherCfg().hard_free_join_times
	end
	local laft_join_times = buy_join_times - today_join_times + free_join_times
	return laft_join_times > 0
end

function FuBenData:GetOneLevelIsPass(fb_type, fb_chapter, level)
	if self.tuitu_all_info_list and
	 self.tuitu_all_info_list.fb_info_list[fb_type + 1].chapter_info_list[fb_chapter + 1].level_info_list[level + 1].pass_star > 0 then
		return true
	end
	return false
end

function FuBenData:GetOneLevelIsPassAndThreeStar(fb_type, fb_chapter, level)
	if self.tuitu_all_info_list and
	 self.tuitu_all_info_list.fb_info_list[fb_type + 1].chapter_info_list[fb_chapter + 1].level_info_list[level + 1].pass_star == 3 then
		return true
	end
	return false
end

function FuBenData:GetPushFBChapterInfo(fb_type)
	if nil == self.tuitu_fb_info_cfg[fb_type] then
		return nil
	end
	return self.tuitu_fb_info_cfg[fb_type]
end

function FuBenData:GetPushFBLeveLInfo(fb_type, chapter, level)
	if nil == self.tuitu_all_info_list or self.tuitu_all_info_list.fb_info_list[fb_type + 1] == nil or
		self.tuitu_all_info_list.fb_info_list[fb_type + 1].chapter_info_list[chapter + 1] == nil then
		return nil
	end
	return self.tuitu_all_info_list.fb_info_list[fb_type + 1].chapter_info_list[chapter + 1].level_info_list[level + 1]
end

function FuBenData:GetPushFBStarReward()
	return ConfigManager.Instance:GetAutoConfig("tuitu_fb_auto").star_reward
end


function FuBenData:GetStarRewardList(chapter, seq)
	local cfg = self:GetPushFBStarReward()
	for k,v in pairs(cfg) do
		if v.chapter == chapter and seq == v.seq then
			return v.reward
		end
	end
	return nil
end

function FuBenData:GetPushFBOtherCfg()
	return ConfigManager.Instance:GetAutoConfig("tuitu_fb_auto").other[1]
end

function FuBenData:GetPushFBChapterCfg(chapter)
	return ConfigManager.Instance:GetAutoConfig("tuitu_fb_auto").chapter[chapter]
end

function FuBenData:CanGetStarReward(chapter, seq)
	local data = self:GetTuituCommonFbInfo()
	if nil == data then
		return false
	end
	local chapter_info_list = data.chapter_info_list
	local total_star = chapter_info_list[chapter].total_star
	local star_reward_flag = chapter_info_list[chapter].star_reward_flag
	local bit_list = bit:d2b(star_reward_flag)
	local reward_cfg = self:GetPushFBAllReward(chapter - 1, seq)
	if next(reward_cfg) and total_star >= reward_cfg.star_num and 0 == bit_list[32 - seq] then
		return true
	end
	return false
end

function FuBenData:OnPushFbFetchShowStarRewardSucc(protocol)
	self.push_fb_fecth_star_reward_info = protocol
end

function FuBenData:GetPushFbFetchShowStarReward()
	local chapter = self.push_fb_fecth_star_reward_info.chapter
	local seq = self.push_fb_fecth_star_reward_info.seq

	local fecth_reward_list = {}
	local reward_cfg_list = ConfigManager.Instance:GetAutoConfig("tuitu_fb_auto").star_reward
	for i = #reward_cfg_list, 1, -1 do
		local reward_cfg = reward_cfg_list[i]
		if reward_cfg.chapter == chapter
			and reward_cfg.seq == seq then
			for k,v in pairs(reward_cfg.reward) do
				table.insert(fecth_reward_list, v)
			end

			break
		end
	end

	return fecth_reward_list
end

function FuBenData:GetPushFBAllReward(chapter, seq)
	for k,v in pairs(self:GetPushFBStarReward()) do
		if v.chapter == chapter and v.seq == seq then
			return v
		end
	end
	return {}
end

function FuBenData:NextCanGetStarReward(chapter)
	local data = self:GetTuituCommonFbInfo()
	if nil == data then
		return {}
	end
	local chapter_info_list = data.chapter_info_list
	local total_star = chapter_info_list[chapter].total_star
	local reward_chapter_list = {}
	local next_reward_list = {}
	for k,v in pairs(self:GetPushFBStarReward()) do
		if v.chapter == chapter - 1 then
			table.insert(reward_chapter_list, v)
		end
	end
	for k,v in pairs(reward_chapter_list) do
		if v.star_num > total_star then
			next_reward_list = v
			break
		end
	end
	if not next(next_reward_list) then
		next_reward_list = reward_chapter_list[4]
	end
	return next_reward_list
end

function FuBenData:SetTuituFbInfo(protocol)
	self.tuitu_all_info_list = protocol
end

function FuBenData:GetTuituCommonFbInfo()
	return self.tuitu_all_info_list and self.tuitu_all_info_list.fb_info_list[1] or nil
end

function FuBenData:GetTuituSpecialFbInfo()
	return self.tuitu_all_info_list and self.tuitu_all_info_list.fb_info_list[2] or nil
end

function FuBenData:SetTuituFbResultInfo(protocol)
	self.tuitu_fb_result_info = protocol
end

function FuBenData:GetTuituFbResultInfo()
	return self.tuitu_fb_result_info
end

function FuBenData:SetTuituFbSingleInfo(protocol)
	self.tuitu_fb_single_info = protocol
	if self.tuitu_all_info_list then
		self.tuitu_all_info_list.fb_info_list[protocol.fb_type + 1].today_join_times = protocol.today_join_times
		self.tuitu_all_info_list.fb_info_list[protocol.fb_type + 1].buy_join_times = protocol.buy_join_times
		self.tuitu_all_info_list.fb_info_list[protocol.fb_type + 1].chapter_info_list[protocol.chatper + 1].total_star = protocol.total_star
		self.tuitu_all_info_list.fb_info_list[protocol.fb_type + 1].chapter_info_list[protocol.chatper + 1].star_reward_flag = protocol.star_reward_flag
	end
end

function FuBenData:GetPushFbData()
	return self.push_fb_info_list
end

function FuBenData:SetPushFbData(fb_type, chapter, level)
	self.push_fb_info_list = {}
	self.push_fb_info_list.fb_type = fb_type
	self.push_fb_info_list.chapter = chapter
	self.push_fb_info_list.level = level
end

function FuBenData:GetPushRed(fb_type)
	local special_open = OpenFunData.Instance:CheckIsHide("fb_push")
	if not special_open then
		return false
	end
	if fb_type == PUSH_FB_TYPE.PUSH_FB_TYPE_HARD and not OpenFunData.Instance:CheckIsHide("fb_push_special") then
		return false
	end
	local all_push_info = self.tuitu_all_info_list and self.tuitu_all_info_list.fb_info_list[fb_type + 1] or {}
	local buy_join_times = all_push_info.buy_join_times or 0
	local today_join_times = all_push_info.today_join_times or 0
	local FirstLevelIsPass = self:GetOneLevelIsPassBySpecial(1, 0, 0)
	local free_join_times = 0

	if fb_type == 0 then
		free_join_times = self:GetPushFBOtherCfg().normal_free_join_times
	elseif fb_type == 1 then
		if special_open == false or not FirstLevelIsPass then
			return false
		end
		free_join_times = self:GetPushFBOtherCfg().hard_free_join_times
	end
	local laft_join_times = buy_join_times - today_join_times + free_join_times
	if laft_join_times > 0 then
		return true
	end
	return false
end

function FuBenData:GetOneLevelIsPassBySpecial(fb_type, fb_chapter, level)
	if 0 == fb_chapter and 0 == level then
		return true
	end

	local cur_level_cfg = self:GetPushFBInfo(fb_type, fb_chapter, level)
	if self.tuitu_all_info_list and cur_level_cfg and
	 self.tuitu_all_info_list.fb_info_list[cur_level_cfg.need_pass_fb_type + 1].chapter_info_list[cur_level_cfg.need_pass_chapter + 1].level_info_list[cur_level_cfg.need_pass_level + 1].pass_star > 0 then
		return true
	end
	return false
end

function FuBenData:SetShowPushIndex(index)
	self.push_show_index = index
end

function FuBenData:GetShowPushIndex()
	return self.push_show_index
end

function FuBenData:GetIsCanPushCommonFb(fb_type)
	if nil == self.tuitu_all_info_list or nil == next(self.tuitu_all_info_list) then
		return false
	end

	if fb_type == PUSH_FB_TYPE.PUSH_FB_TYPE_NORMAL then
		if not OpenFunData.Instance:CheckIsHide("fb_push") then
			return false
		end
	else
		if not OpenFunData.Instance:CheckIsHide("fb_push_special") then
			return false
		end
	end

	local capability = GameVoManager.Instance:GetMainRoleVo().capability
	local push_cfg = self:GetPushFBInfo(fb_type, self.tuitu_all_info_list.fb_info_list[fb_type + 1].pass_chapter, self.tuitu_all_info_list.fb_info_list[fb_type + 1].pass_level)
	if push_cfg then
		if capability >= push_cfg.capability then
			if fb_type == PUSH_FB_TYPE.PUSH_FB_TYPE_HARD and
				not (self:GetOneLevelIsPass(push_cfg.need_pass_fb_type, push_cfg.need_pass_chapter, push_cfg.need_pass_level)) then
				return false
			end
			return true
		end
	end
	return false
end

function FuBenData:SetTowerIsWarning(state)
	self.tower_is_warning = state
end

function FuBenData:GetTowerIsWarning()
	return self.tower_is_warning
end

------------------------武器材料副本------------------
-- 获取配置最大关卡
function FuBenData:GetWeaponCfgMaxLev()
	local lev = 0
	local cfg = FuBenData.Instance:GetWeaponCfgLevel()
	if cfg then
		for i,v in ipairs(cfg) do
			if v.chapter == 0 then
				lev = lev + 1
			else
				break
			end
		end
	end
	return lev
end

-- 获取配置当前关卡信息
function FuBenData:GetWeaponCurCfg(chapter)
	local cfg = FuBenData.Instance:GetWeaponCfgLevel()
	if cfg then
		for i,v in ipairs(cfg) do
			if v.chapter == chapter then
				return v.weapon_bg
			end
		end
	end
	return nil
end

-- 获取配置关卡星级时间
function FuBenData:GetWeaponCfgStarTime()
	local cfg = FuBenData.Instance:GetWeaponCfgLevel()
	local star_time_list = {}
	if cfg then
		for i,v in ipairs(cfg) do
			if v.chapter == 0  and v.level == 0 then
				star_time_list.star_1_time = v.sec_1_star
				star_time_list.star_2_time = v.sec_2_star
				star_time_list.star_3_time = v.sec_3_star
			end
		end
	end
	return star_time_list
end

-- 获取配置最大章节
function FuBenData:GetWeaponCfgMaxChapter()
	local chapter = 0
	local cfg = FuBenData.Instance:GetWeaponCfgLevel()
	if cfg then
		chapter = cfg[#cfg].chapter + 1
	end
	return chapter
end

function FuBenData:GetWeaponCfgOther()
	if self.weapon_other_cfg == nil then
		self.weapon_other_cfg = ConfigManager.Instance:GetAutoConfig("newequipfb_auto").other[1]
	end
	return self.weapon_other_cfg
end

function FuBenData:GetWeaponCfgRollCost()
	return ConfigManager.Instance:GetAutoConfig("newequipfb_auto").roll_cost or {}
end

function FuBenData:GetWeaponCfgLevel()
	return ConfigManager.Instance:GetAutoConfig("newequipfb_auto").levelcfg
end

function FuBenData:GetWeaponcfgisshow(chapter,index)
		local data_list = self:GetWeaponCfgLevel()
		for k,v in pairs(data_list) do
			if v.chapter == chapter and v.level == index then
				return v.role_level
			end
		end
end



function FuBenData:GetWeaponMaxBuyTimes()
	return #self:GetWeaponCfgRollCost() or 0
end

function FuBenData:GetWeaponRollCost()
	local cost = self:GetWeaponCfgRollCost()
	local roll_buy_times = self.roll_vo.gold_roll_times
	if cost == nil or cost == "" or roll_buy_times == nil or roll_buy_times >= 3 then
		return 0
	end
	return cost[roll_buy_times + 1].gold
end

function FuBenData:InitDataList()
	self.weapon_max_chapter = 0
	for k, v in pairs(self.weapon_info_list) do
		self.map_list[k] = {}
		if k + 1 > self.weapon_max_chapter then
			self.weapon_max_chapter = k
		end
		for k1, v1 in pairs(v) do
			local data = self:InitData(v1)
			self.map_list[k][k1] = data
			self.neq_level_config[v1.chapter] = self.neq_level_config[v1.chapter] or {}
			self.neq_level_config[v1.chapter][v1.level] = v1
		end
	end
end

function FuBenData:InitData(value)
	local data = {}
	data = TableCopy(value)

	data.star = 0
	data.is_open = false

	return data
end

function FuBenData:GetMapList()
	return self.map_list
end

function FuBenData:GetData(index)
	return self.map_list[index]
end

function FuBenData:GetRewardListNum(index)
	return #self.weapon_reward_list[index] + 1
end

function FuBenData:GetRewardList(index)
	return self.weapon_reward_list[index]
end

function FuBenData:GetRewardList1(index)
	return self.weapon_reward_list1[index]
end

function FuBenData:GetMaxChapter()
	return self.weapon_max_chapter
end

function FuBenData:SetNeqRollPool(protocol)
	self.neq_roll_pool = protocol.roll_item_list
end

function FuBenData:GetNeqRollPool()
	return self.neq_roll_pool
end

function FuBenData:SetNeqPassInfo(protocol)
	self.pass_vo.pass_result = protocol.pass_result  --1：通关，0：失败
	self.pass_vo.pass_sec = protocol.pass_sec
	self.pass_vo.pass_star = protocol.pass_star
	self.pass_vo.reward_score = protocol.reward_score
end

function FuBenData:GetNeqPassInfo()
	return self.pass_vo
end

function FuBenData:SetNeqRollInfo(protocol)
	self.roll_vo.reason = protocol.reason
	self.roll_vo.hit_seq = protocol.hit_seq
	self.roll_vo.free_roll_times = protocol.free_roll_times
	self.roll_vo.gold_roll_times = protocol.gold_roll_times
	self.roll_vo.max_free_roll_times = protocol.max_free_roll_times
end

function FuBenData:GetNeqRollInfo()
	return self.roll_vo
end

function FuBenData:SetNeqFBInfo(protocol)
	self.weapon_materials_info.neqfb_score = protocol.neqfb_score
	self.weapon_materials_info.today_buy_times = protocol.today_buy_times
	self.weapon_materials_info.today_fight_all_times = protocol.today_fight_all_times
	self.weapon_materials_info.today_vip_buy_times = protocol.today_vip_buy_times or 0
	self.weapon_materials_info.today_item_buy_times = protocol.today_item_buy_times
	self.weapon_materials_info.chapter_list = {}
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local prof = PlayerData.Instance:GetRoleBaseProf(main_role_vo.prof)
	for k,v in pairs(self.map_list) do
		for k1,v1 in pairs(v) do
			local item_list = {}
			item_list = Split(v1["item_list" .. prof], "|")
			v1.item_list = item_list
		end
	end
	for k,v in pairs(protocol.chapter_list) do
		local data = {}
		local total_star = 0
		local is_last_pass = false
		for k1, v1 in pairs(v.level_list) do
			if self.map_list[k-1] and self.map_list[k-1][k1-1] then
				self.map_list[k-1][k1-1].star = v1.max_star
				self.map_list[k-1][k1-1].is_open = v1.max_star > 0
			end
			
			if self:IsWeaponRoleLevelOpen(k-1, k1-1) then
				if k1 >= 8 and v1.max_star > 0 then
					self.cur_chapter = k
				end
				if (is_last_pass) or (v1.max_star <= 0 and k1 == 1) then
					self.cur_level = k1-1
					self.map_list[k-1][k1-1].is_cur_level = true
					if k1 > 1 then
						self.map_list[k-1][k1-2].is_cur_level = false
					end
				else
					self.map_list[k-1][k1-1].is_cur_level = false
				end
			end
			is_last_pass = v1.max_star > 0
			total_star = total_star + v1.max_star
		end

		data.is_pass_chapter = is_last_pass
		data.cur_star = total_star
		data.reward_flag = bit:d2b(v.reward_flag)
		data.red = false
		if self:GetRewardList(k-1) then
			for k2, v2 in pairs(self:GetRewardList(k-1)) do
				if data.cur_star >= v2.start and data.reward_flag[32 - k2 + 1] == 0 then
					data.red = true
				end
			end
		end

		table.insert(self.weapon_materials_info.chapter_list, data)
	end
end

function FuBenData:GetNeqFBInfo()
	return self.weapon_materials_info
end

function FuBenData:GetMapListNum()
	if self.cur_chapter >= self.weapon_max_chapter then
		return self.weapon_max_chapter
	end
	return self.cur_chapter
end

function FuBenData:IsWeaponRoleLevelOpen(chapter, level)
	if self.neq_level_config[chapter] == nil then 
		return false
	end

	local level_item = self.neq_level_config[chapter][level]
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	if nil ~= level_item then 
		return true --role_level >= level_item.role_level
	end
	return false
end

function FuBenData:GetSceneCurSelectLayer(scene_id)
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("newequipfb_auto").levelcfg) do
		if scene_id == v.scene_id then
			return v.level + 1
		end
	end
	return nil
end

function FuBenData:GetMonsterSpecialCfg(scene_id)
	local layer_list = ConfigManager.Instance:GetAutoConfig("newequipfb_auto").levelcfg
	for k,v in pairs(layer_list) do
		if scene_id == v.scene_id then
			return v
		end
	end
	return nil
end

function FuBenData:GetMonsterInfoCfg()
	local layer_list = ConfigManager.Instance:GetAutoConfig("newequipfb_auto").other[1]
	return layer_list
end

function FuBenData:GetChapterMaxStart()
	local other_cfg = self:GetMonsterInfoCfg()
	return other_cfg.max_level * 3
end
----------------------防具材料副本------------------
function FuBenData:GetArmorDefendCfgOther()
	return ConfigManager.Instance:GetAutoConfig("fb_armor_defend_auto").other[1]
end

function FuBenData:GetArmorDefendBuyCostCfg()
	return ConfigManager.Instance:GetAutoConfig("fb_armor_defend_auto").buy_cost
end

function FuBenData:GetArmorDefendSkillCfg(index)
	local skill_cfg = ConfigManager.Instance:GetAutoConfig("fb_armor_defend_auto").skill_cfg
	if index == nil then 
		return skill_cfg
	end
	return skill_cfg[index + 1]
end

function FuBenData:GetArmorMaxLevel()
	local wave_list = ConfigManager.Instance:GetAutoConfig("fb_armor_defend_auto").wave_list
	local level = 0
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local info = FuBenData.Instance:GetArmorDefendRoleInfo()
	if info.max_pass_level then
		for i,v in ipairs(wave_list) do
			if v.wave == 1 then
				local chapter_cfg = FuBenData.Instance:GetTowerDefendChapterCfg(v.level + 1)
				local is_open = v.level <= info.max_pass_level + 1 and chapter_cfg.need_level <= role_level
				if is_open then
					level = info.max_pass_level + 1 + 2
					if level >= wave_list[#wave_list].level then
						return wave_list[#wave_list].level + 1
					end
					local chapter_cfg_2 = FuBenData.Instance:GetTowerDefendChapterCfg(level)
					if chapter_cfg_2 then
						if v.level ~= info.max_pass_level + 1 and chapter_cfg_2.need_level > role_level then
							level = level - 1
						end
					end
				end
			end
		end
	end
	return level
end

function FuBenData:GetArmorWaveCfg(level)
	local wave_list = ConfigManager.Instance:GetAutoConfig("fb_armor_defend_auto").wave_list
	local cfg = {}
	for i,v in ipairs(wave_list) do
		if v.level == level then
			table.insert(cfg, v)
		end
	end
	return cfg
end

-- function FuBenData:GetNewPlayerWaveCfg()
-- 	local new_player = ConfigManager.Instance:GetAutoConfig("fb_armor_defend_auto").new_player_wave_list
-- 	local cfg = {}
-- 	if new_player then
-- 		for k,v in pairs(new_player) do
-- 			table.insert(cfg, v)
-- 		end
-- 	end
-- 	return cfg
-- end

function FuBenData:GetArmorDefendChapterCfg(chapter)
	local level_scene_cfg = ConfigManager.Instance:GetAutoConfig("towerdefendteam_auto").level_scene_cfg
	if level_scene_cfg[chapter] then
		local list = TableCopy(level_scene_cfg[chapter])
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local prof = PlayerData.Instance:GetRoleBaseProf(main_role_vo.prof)
		local item_list = {}
		item_list = Split(list["item_list" .. prof], "|")
		list.item_list = item_list
		return list
	end
end

function FuBenData:GetArmorDefendBuyCost(count)
	local buy_cost = self:GetArmorDefendBuyCostCfg()
	local cfg = {}
	for i,v in ipairs(buy_cost) do
		if v.buy_times == count then
			return v.gold_cost
		end
	end
	return buy_cost[#buy_cost].gold_cost
end

function FuBenData:SetArmorDefendRoleInfo(protocol)
	self.armor_info.join_times = protocol.personal_join_times
	self.armor_info.buy_join_times = protocol.personal_buy_join_times
	self.armor_info.max_pass_level = protocol.personal_max_pass_level
	self.armor_info.auto_fb_free_times = protocol.personal_auto_fb_free_times
	self.armor_info.item_buy_join_times = protocol.personal_item_buy_join_times
end

function FuBenData:GetArmorDefendRoleInfo()
	return self.armor_info
end

function FuBenData:SetGuardPass(protocol)
	self.guard_info.is_passed = protocol.is_passed
end
function FuBenData:GetGuardPass()
	return self.guard_info
end


function FuBenData:SetArmorDefendInfo(protocol)
	self.armor_scene_info.reason = protocol.reason or 0
	self.armor_scene_info.escape_monster_count = protocol.escape_monster_count or 0
	self.armor_scene_info.curr_wave = protocol.curr_wave or 0
	self.armor_scene_info.energy = protocol.energy or 0
	self.armor_scene_info.next_wave_refresh_time = protocol.next_wave_refresh_time or 0
	self.armor_scene_info.clear_wave_count = protocol.clear_wave_count or 0
	self.armor_scene_info.refresh_when_clear = protocol.refresh_when_clear or 0
end

function FuBenData:GetArmorDefendInfo()
	return self.armor_scene_info
end

function FuBenData:SetArmorSelectLevel(index)
	self.armor_select_level = index
end

function FuBenData:GetArmorSelectLevel()
	return self.armor_select_level
end

function FuBenData:SetArmorDefendPerformSkill(protocol)
	self.skill_index = protocol.skill_index
	self.next_time_list = protocol.next_time_list
end

function FuBenData:GetArmorPerformTimeList()
	return self.next_time_list
end

------------------------------- 塔防副本 -----------------------------------
function FuBenData:GetDefenseTowerCfg()
	if not self.defense_cfg then
		self.defense_cfg = ConfigManager.Instance:GetAutoConfig("build_tower_fb_auto").tower_config
	end
	return self.defense_cfg
end

function FuBenData:GetDefenseTowerOtherCfg()
	return ConfigManager.Instance:GetAutoConfig("build_tower_fb_auto").other[1]
end

function FuBenData:GetDefensePosList()
	return ConfigManager.Instance:GetAutoConfig("build_tower_fb_auto").tower_pos
end

function FuBenData:GetDefenseTowerOneLevelCfg()
	local one_level_tower_cfg = {}
	local index = 1
	for k, v in ipairs(self:GetDefenseTowerCfg())do
		if v.tower_level == 1 and v.tower_type ~= 1 then
			one_level_tower_cfg[index] = v
			index = index + 1
		end
	end
	return one_level_tower_cfg
end

function FuBenData:GetIsDefenseTower(monster_id)
	for k,v in pairs(self:GetDefenseTowerCfg()) do
		if monster_id == v.monster_id then
			return true
		end
	end
	return false
end

function FuBenData:GetDefenseTowerNextCfg(tower_type, tower_level)
	local build_tower_fb_auto = self:GetDefenseTowerCfg()
	local now_defense, next_defense
	for k,v in ipairs(build_tower_fb_auto)do
		if tower_type == v.tower_type and tower_level + 1 == v.tower_level then
			next_defense = v
		elseif tower_type == v.tower_type and tower_level == v.tower_level then
			now_defense = v
		end
		if next_defense and now_defense then
			break
		end
	end
	return now_defense, next_defense
end

function FuBenData:SetDescIndex(index)
	self.desc_index = index
end

function FuBenData:GetDescIndex()
	return self.desc_index
end

function FuBenData:SetBuildTowerFBInfo(protocol)
	self.defense_data = protocol.data
end

function FuBenData:GetBuildTowerFBInfo()
	return self.defense_data
end

function FuBenData:GetBuildTowerRewardList()
	local reward_list = {}
	for i = 1, 6 do
		reward_list[i] = 0
	end

	if not self.item_cfg then
		self.item_cfg = ConfigManager.Instance:GetAutoConfig("build_tower_fb_auto").drop_record
	end
	
	if self.defense_data.item_list == nil or self.defense_data.item_list == "" or self.item_cfg == "" then 
		return nil 
	end

	for k, v in pairs(self.defense_data.item_list) do
		for k1, v1 in pairs(self.item_cfg) do
			if v.item_id == v1.item_id then
				reward_list[v1.record_type] = reward_list[v1.record_type] + v.num
			end
		end
	end
	return reward_list
end

function FuBenData:GetBuildTowerRewardNum()
	local reward_list = self:GetBuildTowerRewardByNum()
	local num = 0
	if reward_list then
		num = #reward_list
	end
	return num
end

function FuBenData:GetBuildTowerRewardByNum()
	local last_reward_list = {}
	if self.defense_data.item_list then
		local reward_list = self.defense_data.item_list
		for k,v in pairs(reward_list) do
			if v and v.item_id > 0 and v.num > 0 then
				local quality = ItemData.Instance:GetItemQuailty(v.item_id)
				v.quality = quality
				table.insert(last_reward_list, v)
			end
		end
	end
	table.sort(last_reward_list, SortTools.KeyUpperSorter("quality"))
	return last_reward_list
end

function FuBenData:GetBuildTowerItemName(item_type)
	if self.item_cfg == nil then return nil end

	for k, v in pairs(self.item_cfg) do
		if item_type == v.record_type then
			return v
		end
	end
	return nil
end

function FuBenData:GetBuildTowerShowReward()
	if self.defense_data == nil and self.defense_data.item_list == nil then return end
	local show_reward = {}
	local count = 0
	for i = #self.defense_data.item_list, 1, -1 do
		count = count + 1
		if count <= 5 then
			show_reward[count] = self.defense_data.item_list[i]
		end
	end

	return show_reward
end

function FuBenData:GetUpDefenseTower(tower_type, tower_level)
	local now_defense, next_defense = self:GetDefenseTowerNextCfg(tower_type, tower_level)
	if self.defense_data ~= "" and next_defense and next_defense.need_douhun <= self.defense_data.douhun then
		return true
	end
	return false
end

function FuBenData:SetBuildTowerBuyTimes(num)
	self.defense_buy_times = num
end

function FuBenData:SetBuildTowerTimes(num)
	self.defense_times = num
end

function FuBenData:GetBuildTowerBuyTimes()
	return self.defense_buy_times > 0 and self.defense_buy_times or self.defense_times
end

function FuBenData:SetBuildTowerEnterTimes(num)
	RemindManager.Instance:Fire(RemindName.FuBen_Defense)
	self.defense_enter_times = num
end

function FuBenData:GetBuildTowerEnterTimes()
	return self.defense_enter_times
end

-------------------组队副本部分--
--数据层构造按照 1.获取数据方法 2.处理数据方法 3.判断数据方法
local TeamCountType = {[DAY_COUNT.DAYCOUNT_ID_TEAM_TOWERDEFEND_JOIN_TIMES] = 2, [DAY_COUNT.DAYCOUNT_ID_TEAM_EQUIP_FB_JOIN_TIMES] = 1}

-- 初始化奖励
function FuBenData:InitReward()
	local cfg = ConfigManager.Instance:GetAutoConfig("fbequip_auto").other
	self.reward_item_list[1] = cfg[1].show_item_id
	cfg = ConfigManager.Instance:GetAutoConfig("teamdefend_auto").other
	self.reward_item_list[2] = cfg[1].show_item_id
end

function FuBenData:InitEnterTimes()
	local cfg = ConfigManager.Instance:GetAutoConfig("fbequip_auto").other
	self.join_times_list[1] = cfg[1].join_times
	local cfg = ConfigManager.Instance:GetAutoConfig("teamdefend_auto").other
	self.join_times_list[2] = cfg[1].free_join_times
end

function FuBenData:InitOpenLevel()
	local cfg = ConfigManager.Instance:GetAutoConfig("fbequip_auto").other
	self.open_list[1] = cfg[1].open_level
	local cfg = ConfigManager.Instance:GetAutoConfig("teamdefend_auto").other
	self.open_list[2] = cfg[1].open_level
end

function FuBenData:GetDesc()
	local desc_list = {}
	local cfg = ConfigManager.Instance:GetAutoConfig("fbequip_auto").other
	desc_list[1] = cfg[1].fb_des
	local cfg = ConfigManager.Instance:GetAutoConfig("teamdefend_auto").other
	desc_list[2] = cfg[1].fb_des
	return desc_list
end

function FuBenData:Getxiannvshengwu()
	local cfg = ConfigManager.Instance:GetAutoConfig("teamdefend_auto").other
	if cfg and cfg[1] then
		return cfg[1].item_id
	end
end

function FuBenData:GetOpenList()
	return self.open_list
end

-- 设置对应副本类型的剩余进入次数
function FuBenData:SetTeamFBInfo(type_value,protocol_value)
	if type_value ~= DAY_COUNT.DAYCOUNT_ID_TEAM_FB_ASSIST_TIMES then
		self.team_fb_info[type_value] = protocol_value
		self:UpdateTeamFBInfo()
	else
		self.remain_help_times = protocol_value
	end
	self.get_team_fb_info = true
end

function FuBenData:GetTeamFbCanEnterCount(type_value)
	if TeamCountType[type_value] then
		local join_times = self.join_times_list[TeamCountType[type_value]] or 0
		local enter_count = self.team_fb_info[type_value] or 0
		return join_times - enter_count
	end
	return 0
end

function FuBenData:UpdateTeamFBInfo()
	for k,v in pairs(self.team_fb_info) do
		local cell_info = {}
		cell_info.remain_times = self.join_times_list[TeamCountType[k]] - v
		self.fuben_cell_info[TeamCountType[k]] = cell_info
	end
	RemindManager.Instance:Fire(RemindName.FuBen_Team)
	RemindManager.Instance:Fire(RemindName.FuBenSingle)
end

-- 获取副本格子信息
function FuBenData:GetFubenCellInfo()
	return self.fuben_cell_info
end

-- 获取副本剩余次数协议是否到达
function FuBenData:IsGetTeamFbInfo()
	return self.get_team_fb_info
end

-- 获取对应副本的奖励物品信息
function FuBenData:GetReward(choose)
	if self.reward_item_list[choose] then
		return self.reward_item_list[choose]
	else
		return {}
	end
end

function FuBenData:GetHelpReward()
	return self.remain_help_times
end

function FuBenData:SetDefaultChoose(req_team_type)
	self.show_flag = true
	if req_team_type == ScoietyData.InviteOpenType.EquipTeamFbNew then
		self.default_choose = TeamCountType[DAY_COUNT.DAYCOUNT_ID_TEAM_EQUIP_FB_JOIN_TIMES]
	elseif req_team_type == ScoietyData.InviteOpenType.TeamTowerDefend then
		self.default_choose = TeamCountType[DAY_COUNT.DAYCOUNT_ID_TEAM_TOWERDEFEND_JOIN_TIMES]
	end
end

function FuBenData:GetDefaultChoose()
	local flag = self.show_flag
	if flag then
		self.show_flag = false
		return self.default_choose or TeamCountType[DAY_COUNT.DAYCOUNT_ID_TEAM_EQUIP_FB_JOIN_TIMES], true
	else
		return self.default_choose or TeamCountType[DAY_COUNT.DAYCOUNT_ID_TEAM_EQUIP_FB_JOIN_TIMES], false
	end
end

function FuBenData:GetMaxHelpValue()
	local cfg = ConfigManager.Instance:GetAutoConfig("other_config_auto").other
	return cfg[1].team_fb_assist_times
end

function FuBenData:CheckRedPoint()
	if not self.get_team_fb_info then
		return false
	end

	local open_level_list = FuBenData.Instance:GetOpenList()
	local vo = GameVoManager.Instance:GetMainRoleVo()

	for k,v in pairs(self.fuben_cell_info) do
		if v.remain_times > 0 and k ~= TeamCountType[DAY_COUNT.DAYCOUNT_ID_YAOSHOUJITAN_JOIN_TIMES] and vo.level >= open_level_list[k] then
			return true
		end
	end
	return false
end

function FuBenData:IsFirstEnter(protocol)
	self.team_tower_defend_fb_is_first = protocol.team_tower_defend_fb_is_first    -- 是否第一次组队塔防
	self.team_yaoshoujitan_fb_is_first = protocol.team_yaoshoujitan_fb_is_first    -- 是否第一次组队妖兽祭坛
	self.team_equip_fb_is_first = protocol.team_equip_fb_is_first
	self:InitEnterTimes()
	-- 如果是第一次的话，则对应的副本进入次数增加1
	if self.team_tower_defend_fb_is_first == 1 then
		self.join_times_list[2] = self.join_times_list[2] + 1
	end
	if self.team_equip_fb_is_first == 1 then
		self.join_times_list[1] = self.join_times_list[1] + 1
	end

	self:UpdateTeamFBInfo()
end

----------------------------------------组队守护
function FuBenData:TeamTowerInfo(protocol)
	self.team_info = protocol
end

function FuBenData:GetTeamTowerInfo()
	return self.team_info
end

function FuBenData:SetTeamTowerDefendSkill(protocol)
	if self.team_info then
		for k,v in pairs(self.team_info.skill_list) do
			if protocol.skill_index == v.skill_id then
				v.last_perform_time = protocol.perform_time
				break
			end
		end
	end
end

function FuBenData:SetTeamTowerDefendAllRole(protocol)
	self.team_list = protocol.team_list
end

function FuBenData:GetTeamTowerDefendAllRole()
	return self.team_list
end

function FuBenData:SetTeamTowerDefendResult(protocol)
	self.team_tower_result.is_passed = protocol.is_passed
	self.team_tower_result.clear_wave_count = protocol.clear_wave_count
	self.team_tower_result.use_time = protocol.use_time
	self.team_tower_result.item_count = protocol.item_count
	self.team_tower_result.item_list = protocol.item_list
	self.team_tower_result.xiannv_shengwu = protocol.xiannv_shengwu
	if protocol.xiannv_shengwu > 0 then
		local data = {}
		data.item_id = self:Getxiannvshengwu()
		data.num = protocol.xiannv_shengwu
		table.insert(self.team_tower_result.item_list, data)
	end
	-- self:ShowFBResult()
end

function FuBenData:ShowFBResult()
	local tower_defend_result = self:GetTeamTowerDefendResult()
	if tower_defend_result and tower_defend_result.use_time then
		local time = TimeUtil.FormatSecond(tower_defend_result.use_time or 0, 7) or 0
		if 1 == tower_defend_result.is_passed then
			if tower_defend_result.item_count > 0 then
				local data_list = tower_defend_result.item_list
				ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "team_result", {data = data_list, time = time})
				FuBenData.Instance:SetDefaultChoose(ScoietyData.InviteOpenType.TeamTowerDefend)
			else
				ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "no_result", {time = time})
				FuBenData.Instance:SetDefaultChoose(ScoietyData.InviteOpenType.TeamTowerDefend)
			end
		elseif 0 == tower_defend_result.is_passed then
			-- local wave = FuBenData.Instance:GetFuBenTeamWave()
			-- if wave > 0 then
				if tower_defend_result.item_count > 0 then
					local data_list = tower_defend_result.item_list
					ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "team_result", {data = data_list, time = time})
				else
					GlobalTimerQuest:AddDelayTimer(function()
						ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "no_result", {time = time})
					end, 1)
				end
			-- else
				-- GlobalTimerQuest:AddDelayTimer(function()
				-- 	ViewManager.Instance:Open(ViewName.FBFailFinishView)
				-- 	end, 1)
			-- end
			FuBenData.Instance:SetDefaultChoose(ScoietyData.InviteOpenType.TeamTowerDefend)
		end
	end
end

function FuBenData:GetTeamTowerDefendResult()
	return self.team_tower_result
end

function FuBenData:GetFuBenHp(uid)
	if self.team_list then
		for k,v in pairs(self.team_list) do
			if v.uid == uid then
				return v
			end
		end
	end
end

function FuBenData:GetFuBenBuffList(uid)
	if self.team_list then
		for k,v in pairs(self.team_list) do
			if v.uid == uid then
				return v.buff
			end
		end
	end
end

function FuBenData:TeamTowerDefendAttrType(protocol)
	self.team_member_t = protocol.team_attr_list
end

function FuBenData:ClearTeamTowerDefendAttrType()
	self.team_member_t = {}
end

function FuBenData:GetTeamTowerDefendInfo()
	return self.team_member_t or {}
end

function FuBenData:GetTeamTowerDefendInfoAttrById(role_id)
	if role_id and self.team_member_t then
		for k,v in pairs(self.team_member_t) do
			if v.uid == role_id then
				return v.attr_type
			end
		end
	end
	return 0
end

function FuBenData:IsAttrTypeExist(attr_type)
	if self.team_member_t then
		local player_info = {}
		for k, v in pairs(self.team_member_t) do
			if v.uid == self.player_id then
				player_info = v
			end
			if attr_type == v.attr_type and player_info and player_info.attr_type ~= attr_type then
				return true
			end
		end
	end
	return false
end

function FuBenData:SendID(id)
	self.player_id = id or 0
end

function FuBenData:GetID()
	return self.player_id
end

function FuBenData:SendPos(pos)
	self.player_pos = pos or 0
end

function FuBenData:GetPos()
	return self.player_pos
end

function FuBenData:GetSkillCfg()
	local cfg = ConfigManager.Instance:GetAutoConfig("teamdefend_auto").skill_cfg
	return cfg
end

function FuBenData:GetSkillDistance(skill_id)
	for k, v in pairs(self:GetSkillCfg()) do
		if skill_id == v.skill_id then
			return v.distance
		end
	end
	return 1
end

function FuBenData:GetGuaJiPos()
	return ConfigManager.Instance:GetAutoConfig("teamdefend_auto").other[1]
end

function FuBenData:GetTeamTowerWaveNum()
	local wave_list = ConfigManager.Instance:GetAutoConfig("teamdefend_auto").team_wave_list or {}
	local cfg = wave_list[#wave_list]
	if nil ~= cfg then
		return cfg.wave + 1
	end
	return 0
end

function FuBenData:GetNextSceneDoor()
	local scene_id = Scene.Instance:GetSceneId()
	local scene_config = ConfigManager.Instance:GetSceneConfig(scene_id) or {}
	local scene_doors = nil
	for k, v in pairs(scene_config.doors) do
		if v.id == scene_id + 1 then
			scene_doors = v
			break
		end
		scene_doors = v
	end
	return scene_doors
end

function FuBenData:SetTeamTowerDefendSkillCD(id)
	local cfg = self:GetSkillCfg()
	for k,v in pairs(cfg) do
		if v.skill_id == id then
			return v.cd_s
		end
	end
	return 1
end

function FuBenData:GetTeamSpecialCfg(flag, scene_id)
	local personal_layer_list = ConfigManager.Instance:GetAutoConfig("fbequip_auto").personal_layer_list
	local team_layer_list = ConfigManager.Instance:GetAutoConfig("fbequip_auto").team_layer_list
	local layer_list = personal_layer_list
	if flag == 0 then
		layer_list = personal_layer_list
	else
		layer_list = team_layer_list
	end
	for k,v in pairs(layer_list) do
		if scene_id == v.scene_id then
			return v
		end
	end
	return nil
end

function FuBenData:GetTeamShouHuCfg(wave)
	local team_shouhu_list = ConfigManager.Instance:GetAutoConfig("teamdefend_auto").team_wave_list
	if team_shouhu_list then
		for k,v in pairs(team_shouhu_list) do
			if wave == v.wave then
				return v
			end
		end
	end
end

function FuBenData:SetFuBenTeamWave(wave)
	self.fuben_team_shouhu_wave = wave
end

function FuBenData:GetFuBenTeamWave()
	return self.fuben_team_shouhu_wave
end

function FuBenData:GetTeamSpecialCfglen()
	local team_layer_list = ConfigManager.Instance:GetAutoConfig("fbequip_auto").team_layer_list
	return #team_layer_list or 0
end

function FuBenData:SetTeamSpecialResult(protocol)
	self.team_special_info = protocol
	self.team_special_is_passed = protocol.is_passed
end

function FuBenData:ClearTeamSpecialResult()
	self.team_special_is_passed = nil
end

function FuBenData:GetTeamSpecialIsPass()
	return self.team_special_is_passed
end

function FuBenData:GetTeamSpecialResultInfo()
	return self.team_special_info
end

function FuBenData:IsTeamSpecialNeedDelayCreateDoor()
	return 0 == self.team_special_is_passed
end

function FuBenData:SetTowerDefendResult(protocol)
	self.tower_defend_result.is_passed = protocol.is_passed
	self.tower_defend_result.use_time = protocol.use_time
	self.tower_defend_result.clear_wave_count = protocol.clear_wave_count
	self.tower_defend_result.have_pass_reward = protocol.have_pass_reward
end

function FuBenData:GetTowerDefendResult()
	return self.tower_defend_result
end

---------------------爬塔-传世佩剑-----------------------------

--获得爬塔魔戒/传世名剑配置
function FuBenData:GetTowerMojieCfg()
	if not self.tower_mojie_cfg then
		self.tower_mojie_cfg = ConfigManager.Instance:GetAutoConfig("mojie_skill_config_auto")
	end
	return self.tower_mojie_cfg
end

--获取魔戒/传世名剑数目
function FuBenData:GetMoJieCount()
	return #(self:GetTowerMojieCfg().active_cfg)
end

--获取所有爬塔魔戒/传世名剑的信息
function FuBenData:GetMoJieAllInfo()
	local active_cfg = self:GetTowerMojieCfg().active_cfg
	local skill_cfg  = self:GetTowerMojieCfg().skill_cfg
	local all_info = {}
	for k,v in pairs(active_cfg) do
		local info = {skill_id = v.skill_id, pata_layer = v.pata_layer, upgrade = v.upgrade}
		info.skill_param = self:GetSkillParamById(v.skill_id)
		info.capability = self:GetSkillFightCapability(v.skill_id)
		table.insert(all_info, info)
	end
	return all_info
end

function FuBenData:GetMoJieTipscfg(data_index)
	local data_list  = self:GetMoJieAllInfo()
	for k,v in pairs(data_list) do 
		if data_index == k then
			return v
		end
	end
	return nil 
end

--判断所给Id的魔戒/佩剑是否激活，返回true表示该爬塔魔戒已经激活
function FuBenData:GetIsActiveById(id)
	if id == nil then
		return false 
	end
	
	if id > 9 then
		return true
	end

	local active_table = self:GetCurActiveTowerMojieId()
	if active_table and next(active_table) then
		for k,v in pairs(active_table) do
			if id == v then
				return true
			end
		end
	end
	return false
end

--根据技能ID获得技能参数
function FuBenData:GetSkillParamById(skill_id)
	local cfg  = self:GetTowerMojieCfg().skill_cfg
	if cfg then
		for k, v in pairs(cfg) do 
			if v.skill_id == skill_id then
				return {v.param_0, v.param_1, v.param_2, v.param_3}
			end
		end
	end
	return {0, 0, 0, 0}
end

-- 根据技能id获取战力
function FuBenData:GetSkillFightCapability(skill_id)
	local cfg  = self:GetTowerMojieCfg().skill_cfg
	if cfg then
		for k,v in pairs(cfg) do
			if v.skill_id == skill_id then
				return v.capability
			end 
		end
	end
	return 0
end

--获取已激活的所有魔戒ID
function FuBenData:GetCurActiveTowerMojieId()
	if not self.tower_info_list then return nil end
	local level = self.tower_info_list.pass_level  --当前爬塔层数
	local cfg = self:GetTowerMojieCfg().active_cfg --爬塔魔戒激活配置
	local result = {}
	for k, v in pairs(cfg) do 
		if v.pata_layer > level then
			return result
		end
		table.insert(result, v.skill_id)
	end
	return result
end

-- 爬塔魔戒，判断当前是否是可以获得魔戒的层数
function FuBenData:GetIsMojieLayer()
	if CheckInvalid(self.tower_info_list) then
		return false 
	end
	local level = self.tower_info_list.pass_level  --当前爬塔层数
	local cfg = self:GetTowerMojieCfg().active_cfg --爬塔魔戒激活配置
	for k, v in pairs(cfg) do 
		if v.pata_layer == level and self.is_new_level then
			return true
		end
	end
	return false
end

-- 获取当前的魔戒
function FuBenData:GetCurMojie()
	if CheckInvalid(self.tower_info_list) then return nil end
	local level = self.tower_info_list.pass_level  --当前爬塔层数
	local cfg = self:GetTowerMojieCfg().active_cfg --爬塔魔戒激活配置
	for k, v in pairs(cfg) do 
		if v.pata_layer == level then
			return v
		end
	end
	return nil
end

function FuBenData:GetSkillDesc(skill_id,skill_index)
	local skill_cfg = self:GetSkillParamById(skill_index)
	local desc = string.format(Language.FubenTower.TowerMoJieSkillDes[skill_id + 1], skill_cfg[1], skill_cfg[2], skill_cfg[3], skill_cfg[4])
	return desc
end

-- 根据id获取佩剑名字
function FuBenData:GetName(skill_id)
	local active_cfg = self:GetTowerMojieCfg().active_cfg
	for k, v in pairs(active_cfg) do
		if v.skill_id == skill_id then
			return v.mojie_name
		end
	end
	return ""
end

-- 根据id获取佩剑配置
function FuBenData:GetTowerMojieCfgBySkillId(skill_id)
	local active_cfg = self:GetTowerMojieCfg().active_cfg
	for k, v in pairs(active_cfg) do
		if v.skill_id == skill_id then
			return v
		end
	end
	return ""
end

function FuBenData:GetMaxPataLayer()
	local cfg = self:GetTowerMojieCfg().active_cfg
	return cfg[#cfg].pata_layer
end

function FuBenData:GetPassLayer()
	return self.tower_info_list.pass_level or 0
end
--爬塔魔戒，获取下一个能获得的魔戒cfg，返回nil表示已获得所有魔戒
function FuBenData:GetNextRewardTowerMojieCfg()
	if not self.tower_info_list then return nil end
	local max_layer = self:GetMaxPataLayer()
	local level = self.tower_info_list.pass_level >= max_layer and max_layer - 1 or self.tower_info_list.pass_level  --当前爬塔层数
	local cfg = self:GetTowerMojieCfg().active_cfg --爬塔魔戒激活配置
	for k, v in pairs(cfg) do 
		if v.pata_layer > level then
			return v
		end
	end
end

function FuBenData:GetMaxTowerMojieCfg()
	local cfg = self:GetTowerMojieCfg().active_cfg --爬塔魔戒激活配置
	local max_skill_id = #cfg - 1
	for k, v in pairs(cfg) do 
		if v.skill_id == max_skill_id then
			return v
		end
	end
	return nil 
end

-- 根据层数当前阶数
function FuBenData:GetUpgradeCount()
	local active_cfg = self:GetTowerMojieCfg().active_cfg
	local length = math.floor((#active_cfg) / 10)
	-- local real_index = index % 10
	for i = 0, length - 1 do
		local num = i > 0 and tonumber(i * 10 + 10) or 10
		if active_cfg[num] ~= nil and active_cfg[num] ~= {} then 
			if self.tower_info_list.pass_level <= active_cfg[num].pata_layer then
				return active_cfg[num].upgrade
			end
		end
	end

	return 0
end

-- 获取下一阶通关的层数
function FuBenData:GetLayerCount(skill_id, upgrade_count)
	local active_cfg = self:GetTowerMojieCfg().active_cfg
	if active_cfg == nil then
		return 0
	end
	local next_skill_id = skill_id
	if active_cfg[next_skill_id] == nil then return 0 end
	return active_cfg[next_skill_id].pata_layer
end

-- 获取副本进入的第一个视角
function FuBenData:GetFbCamearCfg(scene_id)
	if nil == self.camear_cfg then
		local fb_config = ConfigManager.Instance:GetAutoConfig("fb_scene_config_auto")
		if fb_config then
			self.camear_cfg = fb_config.camera_view
		end
	end
	if self.camear_cfg then
		for k,v in pairs(self.camear_cfg) do
			if v.scene_id == scene_id then
				return v
			end
		end
	end
end

function FuBenData:GetOrdCamearCfg(scene_id, x, y)
	if nil == self.ord_camear_cfg then
		local fb_config = ConfigManager.Instance:GetAutoConfig("fb_scene_config_auto")
		if fb_config then
			self.ord_camear_cfg = fb_config.ord_camera_view
		end
	end
	if self.ord_camear_cfg then
		for k,v in pairs(self.ord_camear_cfg) do
			if v.scene_id == scene_id and GameMath.IsInRect(x, y, v.point_x - 4, v.point_y - 4, 8, 8) then
				return v
			end
		end
	end
end

function FuBenData:GetMoveViewCamearCfg(scene_id, x, y)
	if nil == self.move_camear_cfg then
		local fb_config = ConfigManager.Instance:GetAutoConfig("fb_scene_config_auto")
		if fb_config then
			self.move_camear_cfg = fb_config.move_view
		end
	end
	if self.move_camear_cfg then
		for k,v in pairs(self.move_camear_cfg) do
			if v.scene_id == scene_id and GameMath.IsInRect(x, y, v.point_x - 4, v.point_y - 4, 8, 8) then
				return v
			end
		end
	end
end

-- 根据场景获取随机天气特效
function FuBenData:RandWeather(scene_id)
	if nil == self.rand_weather[scene_id] then
		self.rand_weather[scene_id] = {}
		local fb_config = ConfigManager.Instance:GetAutoConfig("fb_scene_config_auto")
		if fb_config and fb_config.rand_weather then
			for k,v in pairs(fb_config.rand_weather) do
				if v.scene_id == scene_id then
					local i = 1
					for k1,v1 in pairs(v) do
						if k1 ~= "scene_id" and type(v1) == "number" and v1 > 0 then
							self.rand_weather[scene_id][i] = tonumber(v1)
							i = i + 1
						end
					end
				end
			end
		end
	end
	return self.rand_weather[scene_id]
end

-- 场景是否显示boss按钮
function FuBenData:GetFbIsShowBossBtn()
	if nil == self.show_boss_btn_list then
		local list = ConfigManager.Instance:GetAutoConfig("fb_scene_config_auto").scene_show
		self.show_boss_btn_list = ListToMap(list, "scene_id")
	end
	if self.show_boss_btn_list then
		if self.show_boss_btn_list[Scene.Instance:GetSceneId()] then
			return true
		end
	end
	return false
end
---------------------爬塔-传世名剑-----------------------------

-- 爬塔排行榜数据
function FuBenData:TowerRankInfo(rank_list)
	self.tower_rank_list = rank_list
end

-- 获取爬塔排行榜数据信息
function FuBenData:GetTowerRankInfo()
	return self.tower_rank_list
end

-- 根据层数排序
function FuBenData:SortTowerRankInfo()
	local tower_rank_info = TableCopy(self.tower_rank_list)
	table.sort(tower_rank_info, SortTools.KeyUpperSorter("rank_value"))
	return tower_rank_info
end

function FuBenData:EquimentNeedLevel(chapter,level)
	local list = ConfigManager.Instance:GetAutoConfig("newequipfb_auto").levelcfg
	for k,v in pairs(list) do 
		if v.chapter == chapter and v.level == level then
			return v.role_level
		end
	end
end

function FuBenData:GetPaTaBossAngle(boss_id)
	local boss_list = ConfigManager.Instance:GetAutoConfig("patafbconfig_auto").levelcfg
	for k,v in pairs(boss_list) do  
		if boss_id == v.boss_id then
			return v.boss_angle
		end
	end
end

function FuBenData:SetLastLayerId(scene_id)
	self.now_scene_id = scene_id
end

function FuBenData:GetLastLayerId()
	return self.now_scene_id
end


-------------------------------------------- 组队副本购买多倍奖励-------------------------------------------------------------------------
function FuBenData:SetFBTowerRewardInfo(protocol)
	self.fb_team_tower_reward_list[protocol.fb_type] = {}
	self.fb_team_tower_reward_list[protocol.fb_type].fb_type = protocol.fb_type or 0
	self.fb_team_tower_reward_list[protocol.fb_type].today_buy_times = protocol.today_buy_times or 0
	self.fb_team_tower_reward_list[protocol.fb_type].item_list = protocol.item_list or {}
	self.fb_team_tower_reward_list[protocol.fb_type].item_count = protocol.item_count or 0
	self.fb_team_tower_reward_list[protocol.fb_type].xiannv_shengwu = protocol.xiannv_shengwu
	if protocol.xiannv_shengwu > 0 then
		local data = {}
		data.item_id = self:Getxiannvshengwu()
		data.num = protocol.xiannv_shengwu
		table.insert(self.fb_team_tower_reward_list[protocol.fb_type].item_list, data)
	end
	RemindManager.Instance:Fire(RemindName.FuBen_Team)
	RemindManager.Instance:Fire(RemindName.FuBenSingle)
	self:ShowFBRewardResult(protocol.fb_type)
end


function FuBenData:GetFBTowerRewardInfo()
	return self.fb_team_tower_reward_list
end

function FuBenData:ShowFBRewardResult(fb_type)
	local fb_team_tower_reward_list = self:GetFBTowerRewardInfo()
	if fb_type and fb_team_tower_reward_list[fb_type] and fb_team_tower_reward_list[fb_type].item_count <= 0 then
		return
	end
	if fb_team_tower_reward_list and fb_team_tower_reward_list[fb_type] then
		local data_list = fb_team_tower_reward_list[fb_type].item_list
		TipsCtrl.Instance:ShowGiftsRewardView(data_list)
		--ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "team_reward_result", {data = data_list})
	end
end

function FuBenData:GetFBTowerEquipRewardCfg(fb_type)
	local cfg = {}
	if fb_type == FuBenTeamType.TEAM_TYPE_EQUIP_TEAM_FB then
		cfg = ConfigManager.Instance:GetAutoConfig("fbequip_auto").other[1] 
	else
		cfg = ConfigManager.Instance:GetAutoConfig("teamdefend_auto").other[1]
	end
	return cfg
end


function FuBenData:FBTeamRedPointSign()
	self.fb_team_red_point = false
end

-----------------------------------------------------------------------------

function FuBenData:GetIsInFuBenScene()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.TeamSpecialFB or 		-- 组队爬塔
		scene_type == SceneType.TeamTowerFB or 			-- 组队守护
		scene_type == SceneType.Defensefb or 			-- 塔防(建塔)
		scene_type == SceneType.ArmorDefensefb or 		-- 防具
		scene_type == SceneType.WeaponMaterialsFb or 	-- 武器材料 
		scene_type == SceneType.RuneTower or 			-- 战魂塔
		scene_type == SceneType.QingYuanFB or 			-- 情缘
		scene_type == SceneType.ChallengeFB or 			-- 品质
		scene_type == SceneType.PhaseFb or 				-- 进阶
		scene_type == SceneType.TowerDefend or 			-- 守护仙女
		scene_type == SceneType.ExpFb 					-- 经验
		then
		return true
	end
	return false
end

function FuBenData:GetIsInCommonScene()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.Common then 		-- 普通场景
		return true
	end
	return false
end

function FuBenData:SetFuBenSceneLeftTime(left_time)
	self.fuebn_scene_left_time = left_time
end

function FuBenData:GetFuBenSceneLeftTime()
	return self.fuebn_scene_left_time
end

function FuBenData:GetQualityLevelLimintByLevel(level)
	local quality_config = ConfigManager.Instance:GetAutoConfig("challengefbcfg_auto")
	if quality_config and quality_config.strongreminder then
		for k,v in pairs(quality_config.strongreminder) do
			if v and v.level == level then
				return v.promotemight
			end
		end
	end
	return 0
end

function FuBenData:GetIsNotPassAllLevel()
	if self.challenge_all_info then
		for i = 0, COMMON_CONSTS.LEVEL_MAX_COUNT - 1 do
			local info = self.challenge_all_info[i]
			if info and info.is_pass == 0 then
				return true
			end
		end
	end
	return false
end

function FuBenData:GetIsHasQualityChangeTime()
	local other_cfg = FuBenData.Instance:GetChallengOtherCfg()
	if other_cfg then
		local day_free_times = other_cfg.day_free_times or 0
		local buy_times = FuBenData.Instance:GetQualityBuyCount() or 0
		local total_times = day_free_times + buy_times
		local enter_times = FuBenData.Instance:GetQualityEnterCount() or 0			--已经进入的次数
		local num = total_times - enter_times
		return num > 0
	end
	return false
end

function FuBenData:CheckIsOpenFubenQuality()
	if not OpenFunData.Instance:CheckIsHide("fb_quality") then
		return false
	end
	if self:GetIsNotPassAllLevel() and self:GetIsHasQualityChangeTime() then
		local last_capability = PlayerPrefsUtil.GetInt("fubenquality_remind")
		local level = GameVoManager.Instance:GetMainRoleVo().level or 0
		local now_capability = GameVoManager.Instance:GetMainRoleVo().capability
		local power_limint = FuBenData.Instance:GetQualityLevelLimintByLevel(level)
		if power_limint > 0 and now_capability - last_capability >= power_limint then
			return true
		end
	end

	return false
end

function FuBenData:GetLastTime(day)
	local show_day = day or self:GetPhaseChallengeDay() 				-- 其他要用的再写，不用的默认给进阶用
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local cur_time = TimeCtrl.Instance:GetServerTime() or 0
	local start_time = main_role_vo.create_role_time or 0

	local server_open_time = cur_time - start_time or 0
	local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay() or 0
	local value = TimeUtil.NowDayTimeStart(start_time) or 0
	local value2 = start_time - value or 0
	local left_time = (86400 * show_day) - server_open_time - value2
	return left_time or 0
end

function FuBenData:SetIsNotClickFuBen(enable)
	self.is_not_click = enable
end

function FuBenData:GetIsNotClickFuBen()
	return self.is_not_click
end

function FuBenData:SetIsOpenBuffType(scene_type, enable)
	self.shuijingbuff_open_list[scene_type] = enable
end

function FuBenData:ResetOpenBuffType()
	if self.shuijingbuff_open_list then
		for k,v in pairs(self.shuijingbuff_open_list) do
			v = true
		end
	end
end

function FuBenData:GetIsOpenBuffType(scene_type)
	return self.shuijingbuff_open_list[scene_type]
end

function FuBenData:SetTeamJoinFlag(is_flag)
	self.team_flag = is_flag
end

function FuBenData:GetTeamJoinFlag()
	 return self.team_flag 
end

function FuBenData:SetExpTeamJoinFlag(is_flag)
	self.expteam_flag = is_flag
end

function FuBenData:GetExpTeamJoinFlag()
	 return self.expteam_flag 
end