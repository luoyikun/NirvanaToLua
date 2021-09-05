BossData = BossData or BaseClass(BaseEvent)

BOSS_ENTER_TYPE = {
	TYPE_BOSS_WORLD = 0,
	TYPE_BOSS_FAMILY = 1,
	TYPE_BOSS_MIKU = 2,
	TYPE_BOSS_DABAO = 3,
	LEAVE_BOSS_SCENE = 4,
	TYPE_BOSS_ACTIVE = 5,
	TYPE_BOSS_PRECIOUS = 6,
	TYPE_BOSS_SHANGGU = 7,
	TYPE_BOSS_BAOBAO = 8,
	TYPE_BOSS_CROSS = 10,
	TYPE_BOSS_MiZang = 11,
	TYPE_BOSS_YouMing = 12,
	TYPE_BOSS_GODMAGIC = 13,
	TYPE_BOSS_PERSONAL = 31,
}

BossData.BOSS_TUJIAN_TYPE = {
	WORLD_BOSS = 1,
	VIP_BOSS = 2,
	MIKU_BOSS = 3,
	ACTIVE_BOSS = 4,
	DABAO_BOSS = 5,
	SHANGGU_BOSS = 6,
	BABY_BOSS = 7,
}

BOSS_FAMILY_OPERATE_TYPE =
{
	BOSS_FAMILY_BUY_MIKU_WEARY = 0,  -- 购买秘窟BOSS疲劳值
	BOSS_FAMILY_BUY_ACTIVE_WEARY = 1,  --购买活跃BOSS疲劳值
	DA_BAO_BUY_ENTER_COUNT = 2,			--购买打宝BOSS进入次数
}

BOSS_TYPE_INFO =
{
	RARE = 3,
}

BossData.Boss_State = {
	not_start = 0,
	ready = 1,
	death = 2,
	time_over = 3,
}

BossData.BossType = {
	WORLD_BOSS = 0,
	BOSS_HOME = 1,
	ELITE_BOSS = 2,
	DABAO_MAP = 3,
}

BossData.FOLLOW_BOSS_OPE_TYPE = {
	FOLLOW_BOSS = 0,                  --关注boss
	UNFOLLOW_BOSS = 1,                --取消关注
	GET_FOLLOW_LIST = 2,              --获取关注列表
}

--怪物平台位置
BossData.PingTai = {
	Vector3(-264.74, 485.13, 676.71),   --平台1
	Vector3(-267.12, 485.13, 678.94),   --平台2
	Vector3(-269.57, 485.13, 676.71),   --平台3
	Vector3(-267.11, 485.13, 672.96),   --平台4
}

BossData.TweenPosition = {
	Up = Vector3(0, 284, 0),
	Left = Vector3(-140, -26, 0),
	Right = Vector3(123, 20, 0),
	Down = Vector3(22, -49, 0),
	TujianLeft = Vector3(-145, 314, 0),
	TujianUp = Vector3(0, 940, 0),
	TujianDown = Vector3(0, -835, 0)
}

BOSS_TYPE =
{
	FAMILY_BOSS = 0,
	MIKU_BOSS = 1,
}

BossData.MonsterType ={
	Boss = 0,
	Monster = 1,
	Gather = 2,
	HideBoss = 3,
}

BossData.BossRemindPoint ={
	[RemindName.Boss] = true,
	[RemindName.Boss_MiKu] = true,
	[RemindName.Boss_Active] = true,
	[RemindName.Boss_Family] = true,
	[RemindName.Boss_DaBao] = true,
	[RemindName.Boss_Baby] = true,
	[RemindName.Boss_Personal] = true,
	[RemindName.Boss_Kf] = true,
	[RemindName.ShenYu_Secret] = true,
}

BossData.DABAO_BOSS = "dabao_boss"
BossData.FAMILY_BOSS = "family_boss"
BossData.MIKU_BOSS = "miku_boss"
BossData.ACTIVE_BOSS = "active_boss"

BossData.FOCUS_WELFARE_LIMIT_LEVEL = 130
--福利boss刷新后 主界面福利boss图标显示1800秒
BossData.MAIN_SHOW_WELFARE_TIME_DIFF = 1800

FLUSH_ITEM_ID = 24605			--BOSS刷新卡

function BossData:__init()
	if BossData.Instance then
		print_error("[BossData] Attempt to create singleton twice!")
		return
	end
	BossData.Instance = self
	self.boss_family_cfg = ConfigManager.Instance:GetAutoConfig("bossfamily_auto")
	self.monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
	self.worldboss_auto = ConfigManager.Instance:GetAutoConfig("worldboss_auto")
	self.baby_boss_cfg = ConfigManager.Instance:GetAutoConfig("baby_boss_config_auto")
	self.shanggu_boss_cfg = ConfigManager.Instance:GetAutoConfig("shangguboss_auto")
	self.kf_boss_cfg = ConfigManager.Instance:GetAutoConfig("cross_boss_auto")
	local personal_cfg = ConfigManager.Instance:GetAutoConfig("person_boss_auto")
	self.cross_mizang_cfg = ConfigManager.Instance:GetAutoConfig("cross_mizang_boss_auto")
	self.bosscardcfg = ConfigManager.Instance:GetAutoConfig("bosscardcfg_auto")
	self.cross_mizang_cfg = ConfigManager.Instance:GetAutoConfig("cross_mizang_boss_auto")
	self.godmagic_boss_cfg = ConfigManager.Instance:GetAutoConfig("godmagicboss_auto")
	self.godmagic_bosslist = self.godmagic_boss_cfg.boss_cfg
	self.godmagic_boss_layer_cfg = self.godmagic_boss_cfg.layer_cfg
	self.crosscrytal_mizang_lsit = self.cross_mizang_cfg.layer_cfg
	self.personal_boss_scen_cfg = personal_cfg.boss_scene_cfg
	self.personal_boss_other = personal_cfg.other[1]
	self.personal_cost = personal_cfg.person_reset
	local mini_map = ConfigManager.Instance:GetAutoConfig("boss_minimap_auto").boss_multyfloor
	self.mini_map_bosstype_cfg = mini_map
	self.mini_map_cfg = ListToMap(mini_map, "bosstype", "boss_cengshu")
	self.dabao_boss_cfg =  self.boss_family_cfg.dabao_boss
	self.active_boss_cfg = self.boss_family_cfg.active_boss
	self.cost_cfg = self.boss_family_cfg.weary_cost
	self.precious_boss_other_cfg = self.boss_family_cfg.precious_boss_other[1]

	self.miku_monster_list_cfg = ListToMapList(self.boss_family_cfg.miku_monster, "scene_id")
	self.task_cfg = ListToMapList(self.boss_family_cfg.precious_boss_task, "task_id")
	
	self.all_boss_list = self.worldboss_auto.worldboss_list

	--活跃BOSS伤害排行奖励
	self.active_boss_reward_list =ListToMapList(self.boss_family_cfg.active_boss_rank_reward, "bossid")

	self.secret_reward_cfg = ListToMapList(self.boss_family_cfg.precious_boss_reward,"level","reward_param")
		--宝宝boss相关本地表
	self.baby_boss_enter_cost = ListToMap(self.baby_boss_cfg.enter_cost, "enter_times")
	self.baby_boss_angry_value = ListToMap(self.baby_boss_cfg.kill_angry_value, "monster_id")
	self.baby_boss_scene_cfg = ListToMap(self.baby_boss_cfg.scene_cfg, "monster_id")
	self.boss_family_id_cfg =  ListToMap(self.boss_family_cfg.boss_family_client, "scene_id")
	self.boss_family_id_cfg2 =  ListToMap(self.boss_family_cfg.boss_family_client, "kf_scene_id")

		--宝宝boss
	self.baby_boss_role_info = {}
	self.baby_boss_all_info = {}
	self.baby_boss_single_info = {}

		--个人boss
	self.personal_boss_list = {}
	self.personal_boss_enter_list = {}
		--上古boss
	self.sg_boss_all_list = {}
	self.sg_boss_list = {}
	self.sg_angry_list = {}
	self.eliteboss_list = {}
		--跨服BOSS
	self.crossboss_list = self.kf_boss_cfg.boss_cfg
	self.cross_other_cfg = self.kf_boss_cfg.other[1]
	self.crossmonster_list = self.kf_boss_cfg.monster_cfg
	self.crosscrytal_lsit = self.kf_boss_cfg.layer_cfg
	self.cross_boss_all_list = {}
	self.shenyun_boss_fb_list = {}
	self.cross_boss_info = {}
	self.cross_boss_list = {}
	self.cross_drop_list = {}
	self.leftmonsterandtreasure = {}
	self.cross_client_flush_info = {}

	self.all_boss_info = {}
	self.worldboss_list = {}
	self.follow_boss_list = {}
	self.drop_list = {}

	-- 仙宠奇遇BOSS
	self.encounter_boss_info = {}
	-- BOSS刷新不再提示表
	self.boss_flush_notip_list = {}
	self.boss_flush_notip_delay_list = {}

	-- -- 世界boss界面boss显示加等级限制
	-- self.worldboss_view_show_level_limit = {
	-- 	off_min_level = 300,
	-- 	off_max_level = 100,
	-- }

	for k,v in pairs(self.all_boss_list) do
		table.insert(self.worldboss_list, v)
	end

	local scene_id = 0
	self.active_boss_level_list = {}
	for k,v in ipairs(self.active_boss_cfg) do
		if scene_id ~= v.scene_id then
			scene_id = v.scene_id
			table.insert(self.active_boss_level_list, v.scene_id)
		end
	end
	self.worldboss_list[0] = table.remove(self.worldboss_list, 1)

	self.boss_scene_map = {}
	for k, boss_type in pairs(BOSS_ENTER_TYPE) do
		self.boss_scene_map[boss_type] = self:GetBossSceneIdMap(boss_type)
	end

	self.angry_value = 0
	self.next_monster_invade_time = 0
	self.next_refresh_time = 0
	self.auto_string = ""
	self.layer = 1
	self.is_quick = false
	self.boss_personal_hurt_info = {
		my_hurt = 0,
		self_rank = 0,
		rank_count = 0,
		rank_list = {},
	}

	self.active_boss_hurt_info = {
		my_hurt = 0,
		my_rank = 0,
		rank_count = 0,
		rank_list = {},
	}
	
	self.miku_boss_hurt_info = {
		my_hurt = 0,
		my_rank = 0,
		rank_count = 0,
		rank_list = {},
	}

	self.boss_guild_hurt_info = {
		my_guild_hurt = 0,
		my_guild_rank = 0,
		rank_count = 0,
		rank_list = {},
	}

	self.boss_week_rank_info = {
		my_guild_kill_count = 0,
		my_guild_rank = 0,
		rank_count = 0,
		rank_list = {},
	}

	self.worldboss_weary = 0
	self.worldboss_weary_last_die_time = 0
	self.worldboss_weary_last_relive_time = 0
	self.crossboss_weary = 0
	self.crossboss_can_relive_time = 0
	self.dabao_angry_value = 0
	self.dabao_enter_count = 0
	self.dabao_boss_enter_num = 0
	-- self.active_angry_value = 0
	self.active_enter_count = 0
	self.active_boss_weary = 0
	self.buy_miku_werary_count = 0
	self.miku_hurt_show = true
	self.active_hurt_show = true
	self.buy_active_werary_count = 0
	-- self.personal_boss_enter_num = 0
	self.sg_tire_value = 0
	self.sg_enter_times = 0
	self.left_can_kill_boss_num = 0
	self.person_buy_count = 0

	self.family_boss_list = {}
	self.family_boss_list.boss_list = {}
	self.miku_boss_info = {
		miku_boss_weary = 0,
		boss_list = {}
	}
	self.boss_list = {}
	self.dabao_flush_info = {}
	self.active_flush_info = {}
	self:AddEvent(BossData.DABAO_BOSS)
	self:AddEvent(BossData.FAMILY_BOSS)
	self:AddEvent(BossData.MIKU_BOSS)
	self:AddEvent(BossData.ACTIVE_BOSS)
	self.main_ui_is_open = false
	self.mainui_open_complete_handle = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
	self.event_quest = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.OpenFunCallBack, self))

	if self.player_data_change_callback == nil then
		self.player_data_change_callback = BindTool.Bind1(self.CheCkDataChangeFocus, self)
		PlayerData.Instance:ListenerAttrChange(self.player_data_change_callback)
	end

	RemindManager.Instance:Register(RemindName.Main_Boss, BindTool.Bind(self.GetMainBossRemind, self))

	RemindManager.Instance:Register(RemindName.Boss, BindTool.Bind(self.GetBossRemind, self))
	RemindManager.Instance:Register(RemindName.Boss_MiKu, BindTool.Bind(self.GetMiKuRedPoint, self))
	RemindManager.Instance:Register(RemindName.Boss_Active, BindTool.Bind(self.GetActiveRedPoint, self))
	RemindManager.Instance:Register(RemindName.Boss_Family, BindTool.Bind(self.GetFamilyRedPoint, self))
	-- RemindManager.Instance:Register(RemindName.Boss_Secret, BindTool.Bind(self.GetSecretRedPoint, self))
	RemindManager.Instance:Register(RemindName.Boss_DaBao, BindTool.Bind(self.GetDaBaoRedPoint, self))
	RemindManager.Instance:Register(RemindName.Boss_Baby, BindTool.Bind(self.GetBabyRedPoint, self))
	RemindManager.Instance:Register(RemindName.Boss_Personal, BindTool.Bind(self.GetPersonalRedPoint, self))
	-- RemindManager.Instance:Register(RemindName.Boss_Shanggu, BindTool.Bind(self.GetShangguRedPoint, self))
	RemindManager.Instance:Register(RemindName.Boss_Kf, BindTool.Bind(self.GetCrossRedPoint, self))
	RemindManager.Instance:Register(RemindName.Boss_Tujian, BindTool.Bind(self.GetTujianRedPoint, self, 0))
end

function BossData:__delete()
	RemindManager.Instance:UnRegister(RemindName.Boss)
	RemindManager.Instance:UnRegister(RemindName.Boss_MiKu)
	RemindManager.Instance:UnRegister(RemindName.Boss_Active)
	RemindManager.Instance:UnRegister(RemindName.Boss_Family)
	-- RemindManager.Instance:UnRegister(RemindName.Boss_Secret)
	RemindManager.Instance:UnRegister(RemindName.Boss_DaBao)
	RemindManager.Instance:UnRegister(RemindName.Boss_Baby)
	RemindManager.Instance:UnRegister(RemindName.Boss_Personal)
	RemindManager.Instance:UnRegister(RemindName.Boss_Shanggu)
	RemindManager.Instance:UnRegister(RemindName.Boss_Kf)
	RemindManager.Instance:UnRegister(RemindName.Boss_Tujian)
	RemindManager.Instance:UnRegister(RemindName.Main_Boss)

	GlobalEventSystem:UnBind(self.mainui_open_complete_handle)
	GlobalEventSystem:UnBind(self.event_quest)

	if self.player_data_change_callback then
		PlayerData.Instance:UnlistenerAttrChange(self.player_data_change_callback)
		self.player_data_change_callback = nil
	end

	if self.boss_flush_notip_delay_list then
		for k,v in pairs(self.boss_flush_notip_delay_list) do
			if v then
				GlobalTimerQuest:CancelQuest(v)
				v = nil
			end
		end
		self.boss_flush_notip_delay_list = {}
	end

	self.main_ui_is_open = false
	BossData.Instance = nil
end

function BossData:ClearCache()
	self.boss_personal_hurt_info = {
		my_hurt = 0,
		self_rank = 0,
		rank_count = 0,
		rank_list = {},
	}

	self.boss_guild_hurt_info = {
		my_guild_hurt = 0,
		my_guild_rank = 0,
		rank_count = 0,
		rank_list = {},
	}

	self.active_boss_hurt_info = {
		my_hurt = 0,
		my_rank = 0,
		rank_count = 0,
		rank_list = {},
	}

	self.miku_boss_hurt_info = {
		my_hurt = 0,
		my_rank = 0,
		rank_count = 0,
		rank_list = {},
	}
end

function BossData:SetMikuHurtShow(is_show)
	self.miku_hurt_show = is_show
end

function BossData:GetMikuHurtShow()
	return self.miku_hurt_show
end

function BossData:SetActiveHurtShow(is_show)
	self.active_hurt_show = is_show
end

function BossData:GetActiveHurtShow()
	return self.active_hurt_show
end

function BossData:GetBossSceneIdMap(boss_type)
	local scene_map = {}
	if boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY then
		for k, v in pairs(self.boss_family_cfg.boss_family) do
			if self:GetBossFamilyKfScene(v.scene_id) then
				scene_map[v.scene_id] = v.scene_id
			end
		end
	elseif boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_MIKU then
		for k, v in pairs(self.boss_family_cfg.miku_boss) do
			scene_map[v.scene_id] = v.scene_id
		end
	elseif boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_DABAO then
		for k, v in pairs(self.boss_family_cfg.dabao_boss) do
			scene_map[v.scene_id] = v.scene_id
		end
	elseif boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE then
		for k, v in pairs(self.boss_family_cfg.active_boss) do
			scene_map[v.scene_id] = v.scene_id
		end
	elseif boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_WORLD then
		for k, v in pairs(self.worldboss_auto.worldboss_list) do
			scene_map[v.scene_id] = v.scene_id
		end
	elseif boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_BAOBAO then
		for k, v in pairs(self.baby_boss_cfg.scene_cfg) do
			scene_map[v.scene_id] = v.scene_id
		end
	elseif boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_PERSONAL then
		for k, v in pairs(self.personal_boss_scen_cfg) do
			scene_map[v.scene_id] = v.scene_id
		end
	elseif boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_CROSS then
		for k, v in pairs(self.kf_boss_cfg.layer_cfg) do
			scene_map[v.scene_id] = v.scene_id
		end
	elseif boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_SHANGGU then
		for k, v in pairs(self.shanggu_boss_cfg.shanggu_boss_layer) do
			scene_map[v.scene_id] = v.scene_id
		end
	elseif boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_MiZang then
		for k, v in pairs(self.crosscrytal_mizang_lsit) do
			scene_map[v.scene_id] = v.scene_id
		end
	elseif boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_GODMAGIC then
		for k, v in pairs(self.godmagic_boss_layer_cfg) do
			scene_map[v.scene_id] = v.scene_id
		end
	elseif boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_PRECIOUS then
		scene_map[self.precious_boss_other_cfg.precious_boss_scene_id] = self.precious_boss_other_cfg.precious_boss_scene_id
	end
	return scene_map
end

function BossData:SetNextMonsterInvadeTime(time)
	self.next_monster_invade_time = time
end

function BossData:GetNextMonsterInvadeTime()
	return self.next_monster_invade_time
end

function BossData:OpenFunCallBack(name)
	if name == "boss" then
		RemindManager.Instance:Fire(RemindName.Boss)
	end
end

function BossData:GetBossState(boss_id)
	return BossData.Boss_State.ready
end

function BossData:OnSCFollowBossInfo(protocol)
	self.follow_boss_list = protocol.follow_boss_list
end

--获取关注列表
function BossData:GetFollowBossList()
	return self.follow_boss_list
end

function BossData:GetPersonBossSceneCfg()
	if self.personal_boss_scen_cfg then
		return self.personal_boss_scen_cfg
	end
end

function BossData:GetPersonBossTimesCost(index)
	if self.personal_cost then
		for k,v in pairs(self.personal_cost) do
			if v.reset_time == index then
				return v.need_gold
			end
		end
	end
end

--boss是否被关注 true被关注, false 没关注
function BossData:BossIsFollow(boss_id)
   for k,v in pairs(self.follow_boss_list) do
		if v.boss_id == boss_id then
			return true
		end
	end
	return false
end

--boss提醒功能
function BossData:CalToRemind(boss_id, boss_type, notify_reason, scene_id)
	-- local boss_id, timer = self:GetFocusBossFlush()
	local is_follow_boss = self:BossIsFollow(boss_id)
	if boss_id == 0 or boss_id == nil or not is_follow_boss then
		return
	end
	self.forcus_boss = boss_id
	self.focus_boss_type = boss_type
	local data = {}
	data.boss_id = boss_id
	data.scene_id = scene_id
	self.foucs_boss_info = data

	if self.focus_boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY then
		local can_go = self:GetFamilyBossCanGoByVip(scene_id)
		if not can_go then
			return
		end
	elseif self.focus_boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE then
		local max_wearry = self:GetActiveBossMaxWeary()
		local weary = max_wearry - self:GetActiveBossWeary()
		if weary <= 0 then
			return
		end
	elseif self.focus_boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_MIKU then
		local max_wearry = self:GetMikuBossMaxWeary()
		local weary = max_wearry - self:GetMikuBossWeary()
		if weary <= 0 then
			return
		end
	elseif self.focus_boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_DABAO then
		local enter_count = self:GetDabaoBossCount()
		local max_count = self:GetDabaoFreeTimes()
		local left_count = max_count - enter_count
		if left_count <= 0 then
			return
		end
	elseif self.focus_boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_BAOBAO then
		local enter_limit = VipData.Instance:GetBabyBossEnterTimes(VIPPOWER.BABYBOSS_ENTER_TIMES)
		local enter_times = self:GetBabyBossEnterTimes()
		local left_times = enter_limit - enter_times
		if left_times <= 0 then
			return
		end
	end

	local scene_type = BossData.Instance:GetSceneTypeByBossID(boss_id)
	if self.boss_flush_notip_list[scene_type] == 1 then
		return
	end

	local ok_call_back = function()
		if self.focus_boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY then
			self:ToAttackBossFamily()
		elseif self.focus_boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_MIKU then
			self:ToAttackBossMiKu()
		elseif self.focus_boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE then
			self:ToActtackBossActive()
		elseif self.focus_boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_DABAO then
			self:ToAttackBossDaBao()
		elseif self.focus_boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_BAOBAO then
			self:ToAttackBabyBoss()
		elseif self.focus_boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_SHANGGU then
			self:ToAttackShangguBoss()
		elseif self.focus_boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_CROSS then
			self:ToAttackCrossBoss()
		elseif self.focus_boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_MiZang then
			self:ToAttackShenYuBoss()
		elseif self.focus_boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_GODMAGIC then
			self:ToActtackGodMagicBoss()
		end
	end
	if notify_reason == 0 then
		TipsCtrl.Instance:OpenBossFocusTip(boss_id, ok_call_back, true, self.focus_boss_type)
	end
end

function BossData:SetDelayTimeNoBossTip(scene_type, isOn)
	if self.boss_flush_notip_delay_list[scene_type] then
		GlobalTimerQuest:CancelQuest(self.boss_flush_notip_delay_list[scene_type])
		self.boss_flush_notip_delay_list[scene_type] = nil
	end
	if isOn then
		self.boss_flush_notip_list[scene_type] = 1
		self.boss_flush_notip_delay_list[scene_type] = GlobalTimerQuest:AddDelayTimer(function() self.boss_flush_notip_list[scene_type] = nil end, 7200)
	end
end

function BossData:CheCkDataChangeFocus(attr, value)
	if attr == "level" then
		if self.level_record == nil then
			self.level_record = GameVoManager.Instance:GetMainRoleVo().level
		end

		if value > self.level_record then
			self:CheCkAutoFocus(value)
			self.level_record = value
		end

		--自动取消关注
		if self.follow_boss_list then
			for k,v in pairs(self.follow_boss_list) do
				local real_type = 0
				if v.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY then
					real_type = 0
				elseif v.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_MIKU then
					real_type = 1
				elseif v.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_DABAO then
					real_type = 2
				elseif v.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE then
					real_type = 3
				elseif v.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_BAOBAO then
					real_type = 4
				elseif v.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_CROSS then
					real_type = 5
				elseif v.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_MiZang then
					real_type = 6
				elseif v.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_GODMAGIC then
					real_type = 7
				end
				local total_ceng = self:GetBossTypeCengshu(real_type) or 0
				local max_ceng = self:GetMostCeng(total_ceng, real_type)
				local least_ceng = self:GetLeastCeng(total_ceng, real_type)
				local scene_list = self:GetCengSceneidListByType(least_ceng, max_ceng, real_type)
				local is_inshow_ceng = false
				for k1,v1 in pairs(scene_list) do
					if v1 == v.scene_id then
						is_inshow_ceng = true
					end
				end
				if not is_inshow_ceng then
					if BossData.Instance:BossIsFollow(v.boss_id) then
						BossCtrl.Instance:SendFollowBossReq(BossData.FOLLOW_BOSS_OPE_TYPE.UNFOLLOW_BOSS, v.boss_type, v.boss_id, v.scene_id)
					end
				end
			end
		end
	end
end

function BossData:CheCkAutoFocus(level)
	local list = {}
	if self.boss_family_cfg and self.boss_family_cfg.boss_auto_focus then
		for i,v in ipairs(self.boss_family_cfg.boss_auto_focus) do
			if self.level_record < v.role_level and level >= v.role_level then
				local boss_list = {}
				if v.monster_list then
					boss_list = Split(v.monster_list, "|")
				end
				for i1,v1 in ipairs(boss_list) do
					table.insert(list, tonumber(v1))
				end
			end
		end
	end

	if next(list) ~= nil then
		for i,v in ipairs(list) do
			local scene_id, boss_type = self:GetBossSceneAndBossTypeByBossId(v)
			BossCtrl.Instance:SendFollowBossReq(BossData.FOLLOW_BOSS_OPE_TYPE.FOLLOW_BOSS, boss_type, v, scene_id)
		end
	end
end

function BossData:GetBossSceneAndBossTypeByBossId(boss_id)
	if self.boss_family_cfg and self.boss_family_cfg.active_boss then
		for i,v in ipairs(self.boss_family_cfg.active_boss) do
			if v.bossID == boss_id then
				return v.scene_id, BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE
			end
		end
	end

	if self.boss_family_cfg and self.boss_family_cfg.miku_boss then
		for i,v in ipairs(self.boss_family_cfg.miku_boss) do
			if v.bossID == boss_id then
				return v.scene_id, BOSS_ENTER_TYPE.TYPE_BOSS_MIKU
			end
		end
	end

	if self.boss_family_cfg and self.boss_family_cfg.boss_family then
		for i,v in ipairs(self.boss_family_cfg.boss_family) do
			if v.bossID == boss_id then
				return v.scene_id, BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY
			end
		end
	end

	if self.boss_family_cfg and self.boss_family_cfg.dabao_boss then
		for i,v in ipairs(self.boss_family_cfg.dabao_boss) do
			if v.bossID == boss_id then
				return v.scene_id, BOSS_ENTER_TYPE.TYPE_BOSS_DABAO
			end
		end
	end

	if self.baby_boss_cfg and self.baby_boss_cfg.scene_cfg then
		for i,v in ipairs(self.baby_boss_cfg.scene_cfg) do
			if v.monster_id == boss_id then
				return v.scene_id, BOSS_ENTER_TYPE.TYPE_BOSS_BAOBAO
			end
		end
	end

	if self.kf_boss_cfg and self.kf_boss_cfg.boss_cfg then
		for i,v in ipairs(self.kf_boss_cfg.boss_cfg) do
			if v.boss_id == boss_id then
				return v.scene_id, BOSS_ENTER_TYPE.TYPE_BOSS_CROSS
			end
		end
	end

	if self.cross_mizang_cfg and self.cross_mizang_cfg.boss_cfg then
		for i,v in ipairs(self.cross_mizang_cfg.boss_cfg) do
			if v.boss_id == boss_id then
				return v.scene_id, BOSS_ENTER_TYPE.TYPE_BOSS_MiZang
			end
		end
	end

	if self.godmagic_bosslist then
		for i,v in ipairs(self.godmagic_bosslist) do
			if v.boss_id == boss_id then
				return v.scene_id, BOSS_ENTER_TYPE.TYPE_BOSS_GODMAGIC
			end
		end
	end

	return 0, 0
end

function BossData:GetMostCeng(max_ceng, boss_type)
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	for i = 1, max_ceng do
		local cfg = self:GetBossMiniMapCfg(boss_type, i)
		if cfg then
			if my_level < cfg.show_min_lv then
				return cfg.boss_cengshu
			end
		end
	end
	return max_ceng
end

function BossData:GetLeastCeng(max_ceng, boss_type)
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	for i = 1, max_ceng do
		local cfg = self:GetBossMiniMapCfg(boss_type, i)
		if my_level >= cfg.show_min_lv and my_level <= cfg.show_max_lv then
			return cfg.boss_cengshu
		end
	end
	return 0
end

function BossData:GetCengSceneidListByType(least_ceng, max_ceng, boss_type)
	local scene_list = {}
	if self.mini_map_bosstype_cfg then
		for k,v in pairs(self.mini_map_bosstype_cfg) do
			if v.bosstype == boss_type and v.boss_cengshu >= least_ceng and v.boss_cengshu <= max_ceng then
				local scene_id = v.scene_id
				if scene_id then
					table.insert(scene_list, scene_id)
				end
			end
		end
	end
	return scene_list
end

function BossData:SetWorldBossWearyInfo(protocol)
	self.worldboss_weary = protocol.worldboss_weary
	self.worldboss_weary_last_die_time = protocol.worldboss_weary_last_die_time
	self.worldboss_weary_last_relive_time = protocol.worldboss_weary_last_relive_time
	GlobalEventSystem:Fire(ObjectEventType.FIGHT_EFFECT_CHANGE, true)
end

function BossData:GetWroldBossWeary()
	return self.worldboss_weary
end

function BossData:GetWroldBossWearyLastDie()
	return self.worldboss_weary_last_die_time
end

function BossData:GetWroldBossWearyLastRelive()
	return self.worldboss_weary_last_relive_time
end

--boss之家 密窟
function BossData:SetBossType(boss_type)
	self.boss_type = boss_type
end

--boss之家 密窟
function BossData:GetBossType()
	local scene_id = Scene.Instance:GetSceneId()
	if BossData.Instance:IsFamilyBossScene(scene_id) or 
		BossData.Instance:IsBossFamilyKfScene(scene_id) then
		return BOSS_TYPE.FAMILY_BOSS
	end
	if BossData.Instance:IsMikuBossScene(scene_id) then
		return BOSS_TYPE.MIKU_BOSS
	end
end

function BossData:SetAutoComeFlag(auto_come_flag)
	self.auto_come_flag = auto_come_flag
end

function BossData:GetAutoComeFlag()
	return self.auto_come_flag
end

function BossData:ToAttackBossFamily()
	if IS_ON_CROSSSERVER then
		TipsCtrl.Instance:ShowSystemMsg(Language.Boss.CanNotMoveToSceneNow)
		return
	end
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id == self.foucs_boss_info.scene_id then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.OnArrive)
		return
	end
	if not self:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end

	local _, cost_gold = self:GetBossVipLismit(self.foucs_boss_info.scene_id)
	local ok_fun = function ()
		local vo = GameVoManager.Instance:GetMainRoleVo()
		if vo.gold >= cost_gold then
			self:SetCurInfo(self.foucs_boss_info.scene_id, self.foucs_boss_info.boss_id)
			ViewManager.Instance:CloseAll()
			if self:IsBossFamilyKfScene(self.foucs_boss_info.scene_id) then
				CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.KF_COMMON_BOSS, BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY, self.foucs_boss_info.scene_id, self.foucs_boss_info.boss_id)
			else
				BossCtrl.Instance:SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY, self.foucs_boss_info.scene_id)
			end
			--BossCtrl.Instance:SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY, self.foucs_boss_info.scene_id)
		else
			TipsCtrl.Instance:ShowLackDiamondView()
		end
	end

	self:SetCurInfo(self.foucs_boss_info.scene_id, self.foucs_boss_info.boss_id)
	if self:GetFamilyBossCanGoByVip(self.foucs_boss_info.scene_id) then
		if self:IsBossFamilyKfScene(self.foucs_boss_info.scene_id) then
			CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.KF_COMMON_BOSS, BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY, self.foucs_boss_info.scene_id, self.foucs_boss_info.boss_id)
		else
			BossCtrl.Instance:SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY, self.foucs_boss_info.scene_id)
		end
		--BossCtrl.Instance:SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY, self.foucs_boss_info.scene_id)
	else
		TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, string.format(Language.Boss.BossFamilyLimit, cost_gold))
	end
end

function BossData:ToAttackBossMiKu()
	if IS_ON_CROSSSERVER then
		TipsCtrl.Instance:ShowSystemMsg(Language.Boss.CanNotMoveToSceneNow)
		return
	end
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id == self.foucs_boss_info.scene_id then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.OnArrive)
		return
	end
	if not BossData.Instance:IsMikuBossScene(scene_id) and not self:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end
	if self.foucs_boss_info.scene_id == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Boss.SelectBoss)
		return
	end

	ViewManager.Instance:CloseAll()
	self:SetBossType(1)
	self.auto_come_flag = true
	self:SetCurInfo(self.foucs_boss_info.scene_id, self.foucs_boss_info.boss_id)
	BossCtrl.Instance:SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_MIKU, self.foucs_boss_info.scene_id)
end

function BossData:ToActtackBossActive()
	if IS_ON_CROSSSERVER then
		TipsCtrl.Instance:ShowSystemMsg(Language.Boss.CanNotMoveToSceneNow)
		return
	end
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id == self.foucs_boss_info.scene_id then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.OnArrive)
		return
	end
	if not BossData.Instance:IsActiveBossScene(scene_id) and not self:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end

	self:SetCurInfo(self.foucs_boss_info.scene_id, self.foucs_boss_info.boss_id)
	BossCtrl.Instance:SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE, self.foucs_boss_info.scene_id, 1)
end

function BossData:ToAttackBossDaBao()
	if IS_ON_CROSSSERVER then
		TipsCtrl.Instance:ShowSystemMsg(Language.Boss.CanNotMoveToSceneNow)
		return
	end
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id == self.foucs_boss_info.scene_id then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.OnArrive)
		return
	end
	-- local _, _, need_item_id, need_item_num = self:GetBossVipLismit(self.foucs_boss_info.scene_id)
	local enter_count = self:GetDabaoBossCount()
	local max_count = self:GetDabaoFreeTimes()
	self:SetCurInfo(self.foucs_boss_info.scene_id, self.foucs_boss_info.boss_id)
	local need_item_id, need_item_num = BossData.Instance:GetDabaoBossEnterCostIdAndNumByTimes(enter_count)
	local free_enter_times = self:GetDabaoFreeEnterTimes()
	if free_enter_times > 0 then
		BossCtrl.Instance:SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_DABAO, self.foucs_boss_info.scene_id, 1)
		return
	end
	if enter_count < max_count then
		-- BossCtrl.Instance:SetEnterBossComsunData(need_item_id, need_item_num, Language.Boss.EnterDabao, Language.Boss.EnterBossConsum, function()
		-- 	BossCtrl.Instance:SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_DABAO, self.foucs_boss_info.scene_id, 1)
		-- end)
		local num = ItemData.Instance:GetItemNumInBagById(need_item_id)
		if num >= need_item_num then
			BossCtrl.Instance:SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_DABAO, self.foucs_boss_info.scene_id, 1)
		elseif num > 0 and num < need_item_num then
			local rest_num = need_item_num - num
			BossCtrl.Instance:SetEnterBossComsunData(need_item_id, rest_num, Language.Boss.EnterDabao, Language.Boss.EnterBossConsum, 
				function(need_item_id, rest_num, is_bind, is_use, is_buy_quick)
				 MarketCtrl.Instance:SendShopBuy(need_item_id, rest_num, is_bind, is_use)
			end)
			self:JumpToFocusDaBaoBossView()
		elseif num <= 0 then
			BossCtrl.Instance:SetEnterBossComsunData(need_item_id, need_item_num, Language.Boss.EnterDabao, Language.Boss.EnterBossConsum, 
				function(need_item_id, need_item_num, is_bind, is_use, is_buy_quick)
				 MarketCtrl.Instance:SendShopBuy(need_item_id, need_item_num, is_bind, is_use)
			end)
			self:JumpToFocusDaBaoBossView()
		end
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Boss.BabyBossEnterTimesLimit)
	end
end

function BossData:JumpToFocusDaBaoBossView()
	ViewManager.Instance:Open(ViewName.Boss, TabIndex.dabao_boss)
	local cfg = self:GetDabaoBossClientCfg()
	local layer = 1
	if cfg then
		for k,v in pairs(cfg) do
			if v.scene_id == self.foucs_boss_info.scene_id then
				layer = k
			end
		end
	end
	BossCtrl.Instance:JumpToDaBaoLayer(layer)
end

function BossData:JumpToFocusBabyBossView()
	ViewManager.Instance:Open(ViewName.Boss, TabIndex.baby_boss)
	local cfg = self:GetBabyBossListClient()
	local layer = 1
	if cfg then
		for k,v in pairs(cfg) do
			if v.scene_id == self.foucs_boss_info.scene_id then
				layer = k
			end
		end
	end
	BossCtrl.Instance:JumpToBabyLayer(layer)
end

function BossData:SetPersonalBossBuyTimes(count)
	if count then
		self.person_buy_count = count
	end
end

function BossData:GetPersonalBossBuyTimes()
	return self.person_buy_count
end

function BossData:ToAttackBabyBoss()
	if IS_ON_CROSSSERVER then
		TipsCtrl.Instance:ShowSystemMsg(Language.Boss.CanNotMoveToSceneNow)
		return
	end
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id == self.foucs_boss_info.scene_id then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.OnArrive)
		return
	end
	if not self:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end

	local gold_cost, is_bind = self:GetBabyBossEnterCost()
	local enter_limit = VipData.Instance:GetBabyBossEnterTimes(VIPPOWER.BABYBOSS_ENTER_TIMES)
	local enter_times = self:GetBabyBossEnterTimes()
	local enter_times_max_vip = VipData.Instance:GetBabyBossEnterTimes(VIPPOWER.BABYBOSS_ENTER_TIMES, VipData.Instance:GetVipMaxLevel())
	-- 进入次数已达上限
	if enter_times >= enter_limit then
		if enter_limit < enter_times_max_vip then
			TipsCtrl.Instance:ShowLockVipView(VIPPOWER.BABYBOSS_ENTER_TIMES)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Boss.BabyBossEnterTimesLimit)
		end
		return
	end

	local need_item_id, need_item_num = self:GetBabyEnterCondition()
	-- BossCtrl.Instance:SetEnterBossComsunData(need_item_id, need_item_num, Language.Boss.EnterBaby, Language.Boss.EnterBossConsum, function()
	-- 	BossCtrl.Instance:SendBabyBossRequest(BABY_BOSS_OPERATE_TYPE.BABY_BOSS_SCENE_ENTER_REQ, self.foucs_boss_info.scene_id, self.foucs_boss_info.boss_id)
	-- end)
	local num = ItemData.Instance:GetItemNumInBagById(need_item_id)
	if num >= need_item_num then
		BossCtrl.Instance:SendBabyBossRequest(BABY_BOSS_OPERATE_TYPE.BABY_BOSS_SCENE_ENTER_REQ, self.foucs_boss_info.scene_id, self.foucs_boss_info.boss_id)
	elseif num > 0 and num < need_item_num then
		local rest_num = need_item_num - num
		BossCtrl.Instance:SetEnterBossComsunData(need_item_id, rest_num, Language.Boss.EnterDabao, Language.Boss.EnterBossConsum, 
			function(need_item_id, rest_num, is_bind, is_use, is_buy_quick)
			 MarketCtrl.Instance:SendShopBuy(need_item_id, rest_num, is_bind, is_use)
		end)
		self:JumpToFocusBabyBossView()
	elseif num <= 0 then
		BossCtrl.Instance:SetEnterBossComsunData(need_item_id, need_item_num, Language.Boss.EnterDabao, Language.Boss.EnterBossConsum, 
			function(need_item_id, need_item_num, is_bind, is_use, is_buy_quick)
			 MarketCtrl.Instance:SendShopBuy(need_item_id, need_item_num, is_bind, is_use)
		end)
		self:JumpToFocusBabyBossView()
	end
end

function BossData:ToAttackShangguBoss()
	if IS_ON_CROSSSERVER then
		TipsCtrl.Instance:ShowSystemMsg(Language.Boss.CanNotMoveToSceneNow)
		return
	end
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id == self.foucs_boss_info.scene_id then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.OnArrive)
		return
	end
	if not self:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end

	if Scene.Instance:GetSceneType() == SceneType.SG_BOSS then
		SysMsgCtrl.Instance:ErrorRemind(Language.Boss.OutFubenTip)
		return 
	end

	local enter_comsun = self:GetSGBossEnterComsun()
	local tiky_id = self:GetSGBossTikyId()
	local layer_cfg = self.shanggu_boss_cfg.shanggu_boss_layer
	local layer = nil
	for k,v in pairs(layer_cfg) do
		if v.scene_id == self.foucs_boss_info.scene_id then
			layer = v.layer
		end
	end

	-- BossCtrl.Instance:SetEnterBossComsunData(tiky_id, enter_comsun, Language.Boss.EnterSGBoss, Language.Boss.EnterBossConsum, function()
	-- 	BossCtrl.Instance:SendShangGuBossReq(SGBOSS_REQ_TYPE.ENTER, layer, self.foucs_boss_info.boss_id)
	-- end)
	local num = ItemData.Instance:GetItemNumInBagById(tiky_id)
	if self.is_quick and num > 0 and num < enter_comsun then
		local rest_num = enter_comsun - num
		MarketCtrl.Instance:SendShopBuy(tiky_id, rest_num, 0, 0)
		BossCtrl.Instance:SendShangGuBossReq(SGBOSS_REQ_TYPE.ENTER, layer, self.foucs_boss_info.boss_id)
	elseif self.is_quick and num <= 0 then
		MarketCtrl.Instance:SendShopBuy(tiky_id, enter_comsun, 0, 0)
		BossCtrl.Instance:SendShangGuBossReq(SGBOSS_REQ_TYPE.ENTER, layer, self.foucs_boss_info.boss_id)
	elseif self.is_quick and num >= enter_comsun then
		BossCtrl.Instance:SendShangGuBossReq(SGBOSS_REQ_TYPE.ENTER, layer, self.foucs_boss_info.boss_id)
	elseif num >= enter_comsun then
		BossCtrl.Instance:SendShangGuBossReq(SGBOSS_REQ_TYPE.ENTER, layer, self.foucs_boss_info.boss_id)
	elseif num > 0 and num < enter_comsun then
		local rest_num = enter_comsun - num
		BossCtrl.Instance:SetEnterBossComsunData(tiky_id, rest_num, Language.Boss.EnterSGBoss, Language.Boss.EnterBossConsum, 
			function(tiky_id, rest_num, is_bind, is_use, is_buy_quick)
			 MarketCtrl.Instance:SendShopBuy(tiky_id, rest_num, is_bind, is_use)
			 if is_buy_quick then
				self.is_quick = true
			end
		end)
	elseif num <= 0 then
		BossCtrl.Instance:SetEnterBossComsunData(tiky_id, enter_comsun, Language.Boss.EnterSGBoss, Language.Boss.EnterBossConsum, 
			function(tiky_id, enter_comsun, is_bind, is_use, is_buy_quick)
			 MarketCtrl.Instance:SendShopBuy(tiky_id, enter_comsun, is_bind, is_use)
			if is_buy_quick then
				self.is_quick = true
			end
		end)
	end
end

function BossData:ToAttackCrossBoss()
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id ~= self.foucs_boss_info.scene_id then
		if IS_ON_CROSSSERVER then
			TipsCtrl.Instance:ShowSystemMsg(Language.Boss.CanNotMoveToSceneNow)
			return
		end
	end
	if scene_id == self.foucs_boss_info.scene_id then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.OnArrive)
		return
	end
	if not self:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end
	BossData.Instance:SetCurInfo(self.foucs_boss_info.scene_id, self.foucs_boss_info.boss_id)
	local layer = self:GetCrossLayerBySceneID(self.foucs_boss_info.scene_id)
	CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.KF_BOSS, layer)
end

function BossData:ToAttackShenYuBoss()
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id ~= self.foucs_boss_info.scene_id then
		if IS_ON_CROSSSERVER then
			TipsCtrl.Instance:ShowSystemMsg(Language.Boss.CanNotMoveToSceneNow)
			return
		end
	end
	if not BossData.Instance:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end
	ShenYuBossData.Instance:SetCurInfo(self.foucs_boss_info.scene_id, self.foucs_boss_info.boss_id)
	local layer = ShenYuBossData.Instance:GetShenyuLayerBySceneID(self.foucs_boss_info.scene_id)
	CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_CROSS_MIZANG_BOSS, layer)
end

function BossData:ToActtackGodMagicBoss()
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id == self.foucs_boss_info.scene_id then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.OnArrive)
	end
	if not BossData.Instance:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end
	BossData.Instance:SetCurInfo(self.foucs_boss_info.scene_id, self.foucs_boss_info.boss_id)
	ShenYuBossCtrl.Instance:SendGodMagicBossBossInfoReq(GODMAGIC_BOSS_OPERA_TYPE.GODMAGIC_BOSS_OPERA_TYPE_ENTER, self.foucs_boss_info.scene_id)
end

--获得最快刷新的一个boss
function BossData:GetFocusBossFlush()
	if #self.follow_boss_list == 0 then
		return 0, 0
	end
	local list = {}
	for k,v in pairs(self.follow_boss_list) do
		local temp_list = {}
		if v.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY then
			local status = self:GetBossFamilyStatusByBossId(v.boss_id, v.scene_id)
			if status == 0 then
				temp_list.boss_id = v.boss_id
				temp_list.flush_time = self:GetFamilyBossRefreshTime(v.boss_id, v.scene_id)
				temp_list.boss_type = v.boss_type
				temp_list.scene_id = v.scene_id
			end
		elseif v.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_MIKU then
			local next_refresh_time = self:GetBossMikuStatusByBossId(v.boss_id, v.scene_id)
			if next_refresh_time ~= 0 then
				temp_list.boss_id = v.boss_id
				temp_list.flush_time = self:GetMikuBossRefreshTime(v.boss_id, v.scene_id)
				temp_list.boss_type = v.boss_type
				temp_list.scene_id = v.scene_id
			end
		elseif v.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE then
			local next_refresh_time = self:GetActiveStatusByBossId(v.boss_id, v.scene_id)
			if next_refresh_time ~= 0 then
				temp_list.boss_id = v.boss_id
				temp_list.flush_time = self:GetActiveBossRefreshTime(v.boss_id, v.scene_id)
				temp_list.boss_type = v.boss_type
				temp_list.scene_id = v.scene_id
			end
		elseif v.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_DABAO then
			local next_refresh_time = self:GetDaBaoStatusByBossId(v.boss_id, v.scene_id)
			if next_refresh_time ~= 0 then
				temp_list.boss_id = v.boss_id
				temp_list.flush_time = self:GetDaBaoBossRefreshTime(v.boss_id, v.scene_id)
				temp_list.boss_type = v.boss_type
				temp_list.scene_id = v.scene_id
			end
		elseif v.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_BAOBAO then
			local next_refresh_time = self:GetBabyBossStatusByBossId(v.boss_id, v.scene_id)
			if next_refresh_time ~= 0 then
				temp_list.boss_id = v.boss_id
				temp_list.flush_time = self:GetBabyBossStatusByBossId(v.boss_id, v.scene_id)
				temp_list.boss_type = v.boss_type
				temp_list.scene_id = v.scene_id
			end
		elseif v.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_SHANGGU then
			local next_refresh_time = self:GetShangguBossStatusByBossId(v.boss_id, v.scene_id)
			if next_refresh_time ~= 0 then
				temp_list.boss_id = v.boss_id
				temp_list.flush_time = self:GetShangguBossStatusByBossId(v.boss_id, v.scene_id)
				temp_list.boss_type = v.boss_type
				temp_list.scene_id = v.scene_id
			end
		elseif v.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_CROSS then
			local next_refresh_time = self:GetCrossBossFlushTimesByBossId(v.boss_id, v.scene_id)
			if next_refresh_time ~= 0 then
				temp_list.boss_id = v.boss_id
				temp_list.flush_time = self:GetCrossBossFlushTimesByBossId(v.boss_id, v.scene_id)
				temp_list.boss_type = v.boss_type
				temp_list.scene_id = v.scene_id
			end
		end
		if temp_list.flush_time and temp_list.flush_time > 0 then
			table.insert(list, temp_list)
		end
	end

	local boss_id = 0
	local min_value = 0
	local server_time = TimeCtrl.Instance:GetServerTime()
	if #list ~= 0 then
		min_value = list[1].flush_time
		for k,v in pairs(list) do
			if v.flush_time ~= 0 and v.flush_time <= min_value and v.flush_time - server_time > 60 then
				min_value = v.flush_time
				boss_id = v.boss_id
				self.focus_boss_type = v.boss_type
				self.foucs_boss_info = v
			end
		end
	end
	return boss_id, min_value
end

-----------------------------------世界Boss---------------------------------------------

-- 获取可击杀列表信息
function BossData:GetCanKillList()
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local can_kill_list = {}
	for k,v in pairs(self.all_boss_info) do
		if 1 == v.status then
			local boss_cfg = self:GetBossCfgById(v.boss_id)
			if nil ~= boss_cfg and boss_cfg.boss_level <= role_level then
				local boss_info = {}
				boss_info.boss_type = boss_cfg.boss_tag
				boss_info.name = boss_cfg.boss_name
				boss_info.scene_id = boss_cfg.scene_id
				boss_info.x = boss_cfg.born_x
				boss_info.y = boss_cfg.born_y
				boss_info.boss_level = boss_cfg.boss_level

				boss_info.status = v.status
				boss_info.boss_id = v.boss_id
				can_kill_list[#can_kill_list + 1] = boss_info
			end
		end
	end

	table.sort(can_kill_list, BossData.CanKillKeySort("boss_type", "boss_level"))

	return can_kill_list
end

-- 可击杀排序
function BossData.CanKillKeySort(sort_key_name1, sort_key_name2)
	return function(a, b)
		local order_a = 100000
		local order_b = 100000
		if a[sort_key_name1] < b[sort_key_name1] then
			order_a = order_a + 10000
		elseif a[sort_key_name1] > b[sort_key_name1] then
			order_b = order_b + 10000
		end

		if nil == sort_key_name2 then  return order_a < order_b end

		if a[sort_key_name2] > b[sort_key_name2] then
			order_a = order_a + 1000
		elseif a[sort_key_name2] < b[sort_key_name2] then
			order_b = order_b + 1000
		end

		return order_a > order_b
	end
end

function BossData:GetWorldBossNum()
	if 0 == #self.worldboss_list then
		return nil
	end
	return #self.worldboss_list
end

function BossData:GetBossCfg()
	return self.worldboss_list
end

-- 根据boss_id获取世界boss信息
function BossData:GetBossCfgById(boss_id)
	for k,v in pairs(self.all_boss_list) do
		if boss_id == v.bossID then
			return v
		end
	end
	return nil
end

-- 根据boss_id获取boss状态   1.可击杀   0.未刷新
function BossData:GetBossStatusByBossId(boss_id)
	if nil ~= self.all_boss_info[boss_id] then
		return self.all_boss_info[boss_id].status
	end
	return 0
end

-- 根据boss_id获取boss之家状态   1.可击杀   0.未刷新
function BossData:GetBossFamilyStatusByBossId(boss_id, scene_id)
	if nil ~= self.family_boss_list.boss_list[scene_id] then
		for k,v in pairs(self.family_boss_list.boss_list[scene_id]) do
			if v.boss_id == boss_id then
				return v.status
			end
		end
	end
	return 0
end

function BossData:GetDaBaoStatusByBossId(boss_id, scene_id)
	if nil ~= self.dabao_flush_info[scene_id] then
		for k,v in pairs(self.dabao_flush_info[scene_id]) do
			if v.boss_id == boss_id then
				return v.next_refresh_time
			end
		end
	end
	return 0
end

function BossData:GetActiveStatusByBossId(boss_id, scene_id)
	if nil ~= self.active_flush_info[scene_id] then
		for k,v in pairs(self.active_flush_info[scene_id]) do
			if v.boss_id == boss_id then
				return v.next_refresh_time
			end
		end
	end
	return 0
end

function BossData:GetBossMikuStatusByBossId(boss_id, scene_id)
	if nil ~= self.miku_boss_info.boss_list[scene_id] then
		for k,v in pairs(self.miku_boss_info.boss_list[scene_id]) do
			if v.boss_id == boss_id then
				return v.next_refresh_time
			end
		end
	end
	return 0
end

function BossData:GetBabyBossStatusByBossId(boss_id, scene_id)
	if nil ~= self.baby_boss_all_info then
		for k,v in pairs(self.baby_boss_all_info) do
			if v.boss_id == boss_id and v.scene_id == scene_id then
				return v.next_refresh_time
			end
		end
	end
	return 0
end

function BossData:GetShangguBossStatusByBossId(boss_id)
	if nil ~= self.all_boss_info then
		for k,v in pairs(self.all_boss_info) do
			if v.boss_id == boss_id then
				return v.next_refresh_time
			end
		end
	end
	return 0
end

function BossData:GetCrossBossFlushTimesByBossId(boss_id, scene_id)
	if self.cross_boss_info then
		for k,v in pairs(self.cross_boss_info) do
			if v and v.boss_id == boss_id then
				return v.next_refresh_time
			end
		end
	end
	return 0
end

function BossData:SetBossInfo(protocol)
	self.next_refresh_time = protocol.next_refresh_time
	local boss_list = protocol.boss_list
	self.all_boss_info = {}
	for k,v in pairs(boss_list) do
		self.all_boss_info[v.boss_id] = v
	end
end

function BossData:FlushWorldBossInfo(protocol)
	for k,v in pairs(self.all_boss_info) do
		if k == protocol.boss_id then
			v.status = protocol.status
		end
	end
end

-- 获取世界boss列表
function BossData:GetWorldBossList()
	local boss_list = {}
	-- local off_level_limit = self.worldboss_view_show_level_limit
	local role_level = GameVoManager.Instance:GetMainRoleVo().level

	-- local min_level = role_level - off_level_limit.off_min_level
	-- local max_level = role_level + off_level_limit.off_max_level
	local index = 1
	for i = 0, #self.worldboss_list + 1 do
		local boss_cfg = self.worldboss_list[i]
		if nil ~= boss_cfg then
			boss_list[index] = {}
			boss_list[index].bossID = boss_cfg.bossID
			boss_list[index].boss_type = boss_cfg.boss_tag
			boss_list[index].status = self:GetBossStatusByBossId(boss_cfg.bossID)
			boss_list[index].min_lv = boss_cfg.min_lv
			boss_list[index].max_lv = boss_cfg.max_lv

			index = index + 1
		end
	end
	function sortfun(a, b)
		if a.status > b.status then
			return true
		elseif a.status == b.status then
			local level_1 = self:GetWorldBossInfoById(a.bossID).boss_level
			local level_2 = self:GetWorldBossInfoById(b.bossID).boss_level
			return level_1 < level_2
		else
			return false
		end
	end
	table.sort(boss_list, sortfun)

	for i = #boss_list, 1, -1 do
		if role_level > boss_list[i].max_lv or role_level < boss_list[i].min_lv then
			table.remove(boss_list, i)
		end
	end
	return boss_list
end

-- 根据索引获取boss信息
function BossData:GetWorldBossInfoById(boss_id)
	local cur_info = nil
	for k,v in pairs(self.worldboss_list) do
		if boss_id == v.bossID then
			cur_info = v
			break
		end
	end
	if nil == cur_info then return end

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local prof = PlayerData.Instance:GetRoleBaseProf(main_role_vo.prof)
	local monster_info = self:GetMonsterInfo(boss_id) or {}
	local boss_info = {}
	boss_info.boss_name = cur_info.boss_name
	boss_info.boss_level = cur_info.boss_level
	boss_info.boss_id = cur_info.bossID
	boss_info.scene_id = cur_info.scene_id
	boss_info.born_x = cur_info.born_x
	boss_info.born_y = cur_info.born_y
	local scene_config = ConfigManager.Instance:GetSceneConfig(boss_info.scene_id)
	boss_info.map_name = scene_config.name
	boss_info.refresh_time = cur_info.refresh_time
	boss_info.recommended_power = cur_info.recommended_power

	local item_list = {}
	item_list = Split(cur_info["drop_item_list" .. prof], "|")

	boss_info.item_list = item_list
	boss_info.boss_capability = cur_info.boss_capability

	boss_info.resid = monster_info.resid
	boss_info.ui_scale = monster_info.ui_scale
	boss_info.ui_position_y = monster_info.ui_position_y

	if nil ~= self.all_boss_info[cur_info.bossID] then
		boss_info.status = self.all_boss_info[cur_info.bossID].status or 0
		boss_info.last_kill_name = self.all_boss_info[cur_info.bossID].last_killer_name or ""
		boss_info.next_refresh_time = self.all_boss_info[cur_info.bossID].next_refresh_time
	end

	return boss_info
end

function BossData:GetBossRefreshInfoByBossId(boss_id)
	return self.all_boss_info[boss_id]
end

function BossData:GetMonsterInfo(boss_id)
	return self.monster_cfg[boss_id]
end

function BossData:GetBossNextReFreshTime()
	return self.next_refresh_time
end

function BossData.KeyDownSort(sort_key_name1, sort_key_name2)
	return function(a, b)
		local order_a = 100000
		local order_b = 100000
		if a[sort_key_name1] > b[sort_key_name1] then
			order_a = order_a + 10000
		elseif a[sort_key_name1] < b[sort_key_name1] then
			order_b = order_b + 10000
		end

		if nil == sort_key_name2 then  return order_a < order_b end

		if a[sort_key_name2] > b[sort_key_name2] then
			order_a = order_a + 1000
		elseif a[sort_key_name2] < b[sort_key_name2] then
			order_b = order_b + 1000
		end

		return order_a < order_b
	end
end

function BossData:SetBossPersonalHurtInfo(protocol)
	self.boss_personal_hurt_info = {}
	for k,v in pairs(protocol) do
		self.boss_personal_hurt_info[k] = v
	end
end

function BossData:SetBossGuildHurtInfo(protocol)
	self.boss_guild_hurt_info = {}
	for k,v in pairs(protocol) do
		self.boss_guild_hurt_info[k] = v
	end
end

function BossData:SetBossWeekRankInfo(protocol)
	for k,v in pairs(protocol) do
		self.boss_week_rank_info[k] = v
	end
end

function BossData:OnSCDabaoBossNextFlushInfo(protocol)
	self.dabao_flush_info[protocol.scene_id] = protocol.boss_list
end

function BossData:OnSCActiveBossNextFlushInfo(protocol)
	self.active_flush_info[protocol.scene_id] = protocol.boss_list
end

function BossData:OnMiKuWearyChange(buy_miku_werary_count)
	self.buy_miku_werary_count = buy_miku_werary_count
end

function BossData:OnActiveWearyChange(buy_active_werary_count)
	self.buy_active_werary_count = buy_active_werary_count
end

function BossData:GetBuyMiKuWearyCount()
	return self.buy_miku_werary_count
end

function BossData:GetBuyActiveWearyCount()
	return self.buy_active_werary_count
end

function BossData:FlushDaBaoFlushInfo(protocol)
	local have_scene = false
	for k,v in pairs(self.dabao_flush_info) do
		if protocol.scene_id == k then
			have_scene = true
			for k,v in pairs(v) do
				if v.boss_id == protocol.boss_id then
					v.next_refresh_time = protocol.next_refresh_time
					return
				end
			end
		end
	end
	if have_scene then
		local list = {}
		list.boss_id = protocol.boss_id
		list.next_refresh_time = protocol.next_refresh_time
		table.insert(self.dabao_flush_info[protocol.scene_id], list)
	else
		self.dabao_flush_info[protocol.scene_id] = {}
		self.dabao_flush_info[protocol.scene_id][1] = {}
		self.dabao_flush_info[protocol.scene_id][1].boss_id = protocol.boss_id
		self.dabao_flush_info[protocol.scene_id][1].next_refresh_time = protocol.next_refresh_time
	end
end

function BossData:FlushActiveFlushInfo(protocol)
	local have_scene = false
	for k,v in pairs(self.active_flush_info) do
		if protocol.scene_id == k then
			have_scene = true
			for k,v in pairs(v) do
				if v.boss_id == protocol.boss_id then
					v.next_refresh_time = protocol.next_refresh_time
					return
				end
			end
		end
	end
	if have_scene then
		local list = {}
		list.boss_id = protocol.boss_id
		list.next_refresh_time = protocol.next_refresh_time
		table.insert(self.active_flush_info[protocol.scene_id], list)
	else
		self.active_flush_info[protocol.scene_id] = {}
		self.active_flush_info[protocol.scene_id][1] = {}
		self.active_flush_info[protocol.scene_id][1].boss_id = protocol.boss_id
		self.active_flush_info[protocol.scene_id][1].next_refresh_time = protocol.next_refresh_time
	end
end

function BossData:GetBossPersonalHurtInfo()
	return self.boss_personal_hurt_info
end

function BossData:GetBossGuildHurtInfo()
	return self.boss_guild_hurt_info
end

function BossData:GetBossWeekRankInfo()
	return self.boss_week_rank_info
end

function BossData:GetBossWeekRewardConfig()
	return self.worldboss_auto.week_rank_reward
end

function BossData:GetBossOtherConfig()
	return self.worldboss_auto.other[1]
end

function BossData:GetWorldBossIdBySceneId(scene_id)
	if not scene_id then return end
	local config = self:GetBossCfg()
	if config then
		for k,v in pairs(config) do
			if v.scene_id == scene_id then
				return v.bossID
			end
		end
	end
end

function BossData:SetDabaoBossInfo(protocol)
	self.dabao_angry_value  = protocol.dabao_angry_value
	self.dabao_enter_count  = protocol.dabao_enter_count
	self.dabao_kick_time = protocol.kick_time
	self:NotifyEventChange(BossData.DABAO_BOSS)
end

function BossData:SetActiveBossInfo(protocol)
	self.active_enter_count  = protocol.enter_count
	self.active_boss_weary = protocol.active_boss_weary
	self:NotifyEventChange(BossData.ACTIVE_BOSS)
end

function BossData:GetDabaoBossInfo()
	return self.dabao_angry_value
end

function BossData:GetDabaoBossCount()
	return self.dabao_enter_count
end

function BossData:GetActiveBossCount()
	return self.active_enter_count
end

function BossData:GetDabaoFreeTimes()
	-- return self.boss_family_cfg.other[1].dabao_free_times + self.dabao_boss_enter_num
	return VipPower:GetParam(VIPPOWER.DABAO_TIMES)
end

function BossData:GetDabaoFreeEnterTimes()
	if self.boss_family_cfg and self.boss_family_cfg.other and self.boss_family_cfg.other[1] and self.boss_family_cfg.other[1].dabao_free_times then
		return self.boss_family_cfg.other[1].dabao_free_times - self.dabao_enter_count
	end
	return 0
end

function BossData:GetDabaoBossEnterCostIdAndNumByTimes(times)
	local id = 0
	local num = 0
	if times and self.boss_family_cfg.dabao_cost then
		for k,v in ipairs(self.boss_family_cfg.dabao_cost) do
			if times >= v.times then
				id = v.consume_item_id
				num = v.consume_item_num
			end
		end
	end
	return id , num
end

function BossData:GetDabaoButCount()
	return self.dabao_boss_enter_num
end

function BossData:GetCanBuyDaBaoEnter()
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	local power_list = VipData.Instance:GetVipPowerList(vip_level)
	if power_list then
		local vip_time = power_list[VIPPOWER.DABAO_TIMES]
		return vip_time <= self.dabao_boss_enter_num
	end
end

function BossData:GetCanBuyFamilyEnter()
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	local power_list = VipData.Instance:GetVipPowerList(vip_level)
	if power_list then
		local vip_time = power_list[VIPPOWER.VIP_TIMES]
		return vip_time <= self.dabao_boss_enter_num
	end
end

function BossData:GetBossOtherCfg()
	if self.boss_family_cfg then
		return self.boss_family_cfg.other[1]
	end
end

function BossData:GetDaBaoKickTime()
	return self.dabao_kick_time
end

function BossData:GetDabaoMaxValue()
	if self.boss_family_cfg and self.boss_family_cfg.other and self.boss_family_cfg.other[1] then
		return self.boss_family_cfg.other[1].max_value
	end
end

function BossData:GetBuyWearyGold()
	local weary_count = self:GetBuyMiKuWearyCount()
	for k,v in pairs(self.cost_cfg) do
		if v.buy_times == weary_count then
			return v.cost
		end
	end
	return 100
end

function BossData:GetActiveBuyWearyGold()
	local weary_count = self:GetBuyActiveWearyCount()
	for k,v in pairs(self.cost_cfg) do
		if v.buy_times == weary_count then
			return v.cost
		end
	end
	return 100
end

function BossData:GetDabaoEnterGold(count)
   for k,v in pairs(self.boss_family_cfg.dabao_cost) do
		if v.times == count then
			return v.cost_gold
		end
   end
   return self.boss_family_cfg.dabao_cost[#self.boss_family_cfg.dabao_cost].cost_gold
end

function BossData:CanGoActiveBoss()
	local max_wearry = self:GetActiveBossMaxWeary()
	local weary = max_wearry - self:GetActiveBossWeary()
	return weary < max_wearry
end


function BossData:SetFamilyBossInfo(protocol)
	self.family_boss_list.boss_list[protocol.scene_id] = protocol.boss_list
	self:NotifyEventChange(BossData.FAMILY_BOSS)
end

function BossData:GetFamilyBossInfo(scene_id)
	return self.family_boss_list.boss_list[scene_id]
end

function BossData:OnSCBossInfoToAll(protocol)
	if protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY then
	   for k,v in pairs(self.family_boss_list.boss_list) do
			if k == protocol.scene_id then
				for k1,v1 in pairs(v) do
					if v1.boss_id == protocol.boss_id then
						v1.status = protocol.status
						v1.next_refresh_time = protocol.next_refresh_time
					end
				end
			end
		 end
	elseif protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_MIKU then
		 for k,v in pairs(self.miku_boss_info.boss_list) do
			if k == protocol.scene_id then
				for k1,v1 in pairs(v) do
					if v1.boss_id == protocol.boss_id then
						v1.status = protocol.status
						v1.next_refresh_time = protocol.next_refresh_time
					end
				end
			end
		 end
	elseif protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_DABAO then
		if self.dabao_flush_info then
			local data = {}
			data.boss_id = protocol.boss_id
			data.next_refresh_time = protocol.next_refresh_time
			table.insert(self.dabao_flush_info, data)
		end
	elseif protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE then
		if self.active_flush_info then
			local data = {}
			data.boss_id = protocol.boss_id
			data.next_refresh_time = protocol.next_refresh_time
			table.insert(self.active_flush_info, data)
		end
	elseif protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_BAOBAO then
		if self.baby_boss_all_info then
			local data = {}
			data.boss_id = protocol.boss_id
			data.next_refresh_time = protocol.next_refresh_time
			for k,v in pairs(self.baby_boss_all_info) do
				if v.boss_id == protocol.boss_id then
					v.next_refresh_time = protocol.next_refresh_time
				end
			end
		end
	elseif protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_SHANGGU then
		if self.all_boss_info then
			for k,v in pairs(self.all_boss_info) do
				if k == protocol.boss_id then
					v.next_refresh_time = protocol.next_refresh_time
				end
			end
		end
	end
end

function BossData:GetMikuEliteCountBySeceneId(scene_id)
	local count = 0
	if nil == self.miku_elite_count_list then
		return count
	end
	count = self.miku_elite_count_list[scene_id] or 0
	return count
end

function BossData:ChangeMikuEliteCount(scene_id, elite_count)
	if nil == self.miku_elite_count_list then
		self.miku_elite_count_list = {}
	end
	self.miku_elite_count_list[scene_id] = elite_count
end

function BossData:SetMikuBossInfo(protocol)
	self.miku_boss_info.miku_boss_weary = protocol.miku_boss_weary
	self.miku_boss_info.boss_list[protocol.scene_id] = protocol.boss_list
	self:NotifyEventChange(BossData.MIKU_BOSS)
end

function BossData:SetMikuPiLaoInfo(protocol)
	self.miku_boss_info.miku_boss_weary = protocol.miku_boss_weary
	self:NotifyEventChange(BossData.MIKU_BOSS)
end

function BossData:GetMikuBossInfo()
	return self.miku_boss_info
end

function BossData:GetMikuBossInfoList(scene_id)
	return self.miku_boss_info.boss_list[scene_id]
end

function BossData:GetMikuBossRefreshTime(boss_id, scene_id)
	if self.miku_boss_info.boss_list[scene_id] and #self.miku_boss_info.boss_list[scene_id] ~= 0 then
		for k,v in pairs(self.miku_boss_info.boss_list[scene_id]) do
			if v.boss_id == boss_id then
				return v.next_refresh_time, v.status
			end
		end
	end
	return 0, 0
end

function BossData:GetActiveBossRefreshTime(boss_id, scene_id)
	if self.active_flush_info[scene_id] and #self.active_flush_info[scene_id] ~= 0 then
		for k,v in pairs(self.active_flush_info[scene_id]) do
			if v.boss_id == boss_id then
				return v.next_refresh_time, v.status
			end
		end
	end
	return 0, 0
end

function BossData:GetFamilyBossRefreshTime(boss_id, scene_id)
	if self.family_boss_list.boss_list[scene_id] and #self.family_boss_list.boss_list[scene_id] ~= 0 then
		for k,v in pairs(self.family_boss_list.boss_list[scene_id]) do
			if v.boss_id == boss_id then
				return v.next_refresh_time, v.status
			end
		end
	end
	return 0, 0
end

function BossData:GetDaBaoBossRefreshTime(boss_id, scene_id)
	if self.dabao_flush_info[scene_id] and #self.dabao_flush_info[scene_id] ~= 0 then
		for k,v in pairs(self.dabao_flush_info[scene_id]) do
			if v.boss_id == boss_id then
				return v.next_refresh_time, v.status
			end
		end
	end
	return 0, 0
end

function BossData:GetMikuBossWeary()
	return self.miku_boss_info.miku_boss_weary
end

function BossData:GetActiveBossWeary()
	return self.active_boss_weary
end

function BossData:GetBossFamilyList(scene_id, add_cross)
	local list = {}
	local kf_scene_id = self:GetBossFamilyKfScene(scene_id) or 0
	for k,v in pairs(self.boss_family_cfg.boss_family) do
		if v.scene_id == scene_id or (add_cross and v.scene_id == kf_scene_id) then
			table.insert(list, v)
		end
	end

	function sortfun(a, b)
		local state_a = self:GetBossFamilyStatusByBossId(a.bossID, a.scene_id)
		local state_b = self:GetBossFamilyStatusByBossId(b.bossID, b.scene_id)
		if state_a ~= state_b then
			return state_a > state_b
		else
			local level_a = self.monster_cfg[a.bossID] and self.monster_cfg[a.bossID].level or 0
			local level_b = self.monster_cfg[b.bossID] and self.monster_cfg[b.bossID].level or 0
			if level_a ~= level_b then
				return level_a < level_b
			else
				return a.is_cross < b.is_cross
			end
		end
	end
	table.sort(list, sortfun)
	return list
end

--获取boss之家跨服场景
function BossData:GetBossFamilyKfScene(scene_id)
	if self.boss_family_id_cfg[scene_id] then
		return self.boss_family_id_cfg[scene_id].kf_scene_id
	end
	return nil
end

--获取boss之家跨服场景等级
function BossData:GetBossFamilyKfSceneLevel(scene_id)
	if self.boss_family_id_cfg2[scene_id] then
		return self.boss_family_id_cfg2[scene_id].level
	end
	return 1
end

--获取boss之家跨服场景
function BossData:IsBossFamilyKfScene(scene_id)
	local scene_id = scene_id or Scene.Instance:GetSceneId()
	for k,v in pairs(self.boss_family_id_cfg) do
		if scene_id == v.kf_scene_id then
			return true
		end
	end
	return false
end


function BossData:GetDaBaoBossList(scene_id)
	local list = {}
	for k,v in pairs(self.boss_family_cfg.dabao_boss) do
		if v.scene_id == scene_id then
			local vo = TableCopy(v)
			vo.kill_boss_value = v.kill_boss_value
			table.insert(list, vo)
		end
	end

	function sortfun(a, b)
		local state_a = self:GetDaBaoStatusByBossId(a.bossID, scene_id)
		local state_b = self:GetDaBaoStatusByBossId(b.bossID, scene_id)
		if state_a ~= state_b then
			return state_a < state_b
		else
			local level_a = self.monster_cfg[a.bossID] and self.monster_cfg[a.bossID].level or 0
			local level_b = self.monster_cfg[b.bossID] and self.monster_cfg[b.bossID].level or 0
			return level_a < level_b
		end
	end
	table.sort(list, sortfun)
	return list
end

function BossData:GetActiveBossList(scene_id)
	local list = {}
	for k,v in pairs(self.active_boss_cfg) do
		if v.scene_id == scene_id then
			table.insert(list, v)
		end
	end
	function sortfun(a, b)
		local state_a = self:GetActiveStatusByBossId(a.bossID, scene_id)
		local state_b = self:GetActiveStatusByBossId(b.bossID, scene_id)
		if state_a ~= state_b then
			return state_a < state_b
		else
			local level_a = self.monster_cfg[a.bossID] and self.monster_cfg[a.bossID].level or 0
			local level_b = self.monster_cfg[b.bossID] and self.monster_cfg[b.bossID].level or 0
			return level_a < level_b
		end
	end
	table.sort(list, sortfun)
	return list
end

function BossData:GetMikuBossList(scene_id)
	local list = {}
	for k,v in pairs(self.boss_family_cfg.miku_boss) do
		if v.scene_id == scene_id then
			table.insert(list, v)
		end
	end
	function sortfun(a, b)
		local state_a = self:GetBossMikuStatusByBossId(a.bossID, scene_id)
		local state_b = self:GetBossMikuStatusByBossId(b.bossID, scene_id)
		if state_a ~= state_b then
			return state_a < state_b
		else
			local level_a = self.monster_cfg[a.bossID] and self.monster_cfg[a.bossID].level or 0
			local level_b = self.monster_cfg[b.bossID] and self.monster_cfg[b.bossID].level or 0
			return level_a < level_b
		end
	end
	table.sort(list, sortfun)
	return list
end

function BossData:GetBossFamilyFallList(boss_id)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local prof = PlayerData.Instance:GetRoleBaseProf(main_role_vo.prof)
	for k,v in pairs(self.boss_family_cfg.boss_family) do
		if v.bossID == boss_id then
			local list = {}
			list = Split(v["drop_item_list" .. prof], "|")
			return list
		end
	end
end

function BossData:GetMikuBossFallList(boss_id)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local prof = PlayerData.Instance:GetRoleBaseProf(main_role_vo.prof)
	for k,v in pairs(self.boss_family_cfg.miku_boss) do
		if v.bossID == boss_id then
			local list = {}
			list = Split(v["drop_item_list" .. prof], "|")
			return list
		end
	end
end

function BossData:GetBossFamilyListClient()
	return self.boss_family_cfg.boss_family_client
end

--获取下一boss之家场景
function BossData:GetNextBossFamilyScene(scene_id)
	for i,v in ipairs(self.boss_family_cfg.boss_family_client) do
		if v.scene_id == scene_id then
			if self.boss_family_cfg.boss_family_client[i + 1] then
				return self.boss_family_cfg.boss_family_client[i + 1].scene_id
			end
			break
		end
	end
	return nil
end

function BossData:GetBossSingleInfo(list ,scene_id, boss_id)
	for k,v in pairs(list) do
		if v.scene_id == scene_id and v.bossID == boss_id then
			return v
		end
	end
end

function BossData:GetBossSingleInfo2(list ,scene_id, boss_id)
	for k,v in pairs(list) do
		if v.scene_id == scene_id and v.monster_id == boss_id then
			return v
		end
	end
end
function BossData:SetCurInfo(scene_id, boss_id)
	self.boss_scene_id = scene_id
	self.boss_id = boss_id
end

function BossData:GetCurBossInfo(enter_type)
	if enter_type == BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY then
		return self:GetBossSingleInfo(self.boss_family_cfg.boss_family, self.boss_scene_id, self.boss_id)
	elseif enter_type == BOSS_ENTER_TYPE.TYPE_BOSS_MIKU then
		return self:GetBossSingleInfo(self.boss_family_cfg.miku_boss, self.boss_scene_id, self.boss_id)
	elseif enter_type == BOSS_ENTER_TYPE.TYPE_BOSS_DABAO then
		return self:GetBossSingleInfo(self.boss_family_cfg.dabao_boss, self.boss_scene_id, self.boss_id)
	elseif enter_type == BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE then
		return self:GetBossSingleInfo(self.active_boss_cfg, self.boss_scene_id, self.boss_id)
	elseif enter_type == BOSS_ENTER_TYPE.TYPE_BOSS_CROSS then
		return self:GetCrossBossSinleInfo(self.boss_scene_id, self.boss_id)
	elseif enter_type == BOSS_ENTER_TYPE.TYPE_BOSS_BAOBAO then
		if self.baby_boss_cfg then
			return self:GetBossSingleInfo2(self.baby_boss_cfg.scene_cfg, self.boss_scene_id, self.boss_id)
		end
	elseif enter_type == BOSS_ENTER_TYPE.TYPE_BOSS_GODMAGIC then
		if ShenYuBossData and ShenYuBossData.Instance then
			return ShenYuBossData.Instance:GetGodMagicBossSinleInfo(self.boss_scene_id, self.boss_id)
		end
	end
end

function BossData:GetCrossBossSinleInfo(scene_id, boss_id)
	local list = self:GetCrossLayerBossBySceneID(scene_id)
	for k,v in pairs(list) do
		if v.boss_id == boss_id then
			return v
		end
	end
end

--获取上一boss之家场景
function BossData:GetUpperBossFamilyScene(scene_id)
	for i,v in ipairs(self.boss_family_cfg.boss_family_client) do
		if v.scene_id == scene_id then
			if self.boss_family_cfg.boss_family_client[i - 1] then
				return self.boss_family_cfg.boss_family_client[i - 1].scene_id
			end
			break
		end
	end
	return nil
end

function BossData:GetMikuBossListClient()
	if self.boss_family_cfg then
		return self.boss_family_cfg.miku_boss_client
	end
end

--获取下一秘窟场景
function BossData:GetNextMikuBossScene(scene_id)
	for i,v in ipairs(self.boss_family_cfg.miku_boss_client) do
		if v.scene_id == scene_id then
			if self.boss_family_cfg.miku_boss_client[i + 1] then
				return self.boss_family_cfg.miku_boss_client[i + 1].scene_id
			end
			break
		end
	end
	return nil
end

--获取上一秘窟场景
function BossData:GetUpperMikuBossScene(scene_id)
	for i,v in ipairs(self.boss_family_cfg.miku_boss_client) do
		if v.scene_id == scene_id then
			if self.boss_family_cfg.miku_boss_client[i - 1] then
				return self.boss_family_cfg.miku_boss_client[i - 1].scene_id
			end
			break
		end
	end
	return nil
end

function BossData:GetMikuBossMaxWeary()
	if self.boss_family_cfg and self.boss_family_cfg.weary and self.boss_family_cfg.weary[1] then
		return self.boss_family_cfg.weary[1].weary_limit
	end
end

function BossData:GetActiveBossMaxWeary()
	if self.boss_family_cfg and self.boss_family_cfg.weary and self.boss_family_cfg.weary[2] then
		return self.boss_family_cfg.weary[2].weary_limit
	end
end

function BossData:GetBossVipLismit(scene_id)
	for k,v in pairs(self.boss_family_cfg.enter_condition) do
		if v.scene_id == scene_id then
			return v.free_vip_level, v.cost_gold, v.need_item_id, v.need_item_num
		end
	end
	return 0, 0, 0, 0
end

function BossData:GetIsEnoughVipLevelInVipBossNum()
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	local my_vip = GameVoManager.Instance:GetMainRoleVo().vip_level
	local max_layer = BossData.Instance:GetBossTypeCengshu(0)
	local most_layer = max_layer
	for i=1,max_layer do
		local cfg = BossData.Instance:GetBossMiniMapCfg(0, i)
		if cfg then
			if my_level < cfg.show_min_lv then
				most_layer = cfg.boss_cengshu
			end
		end
	end

	local num = 0
	for i = 1, most_layer do
		local cfg = BossData.Instance:GetBossMiniMapCfg(0, i)
		if cfg then
			local vip_level = BossData.Instance:GetBossVipLismit(cfg.scene_id)
			if my_vip >= vip_level then
				num = num + 1
			end
		end
	end
	if num < max_layer then
		num = num + 1
	end
	return num
end

function BossData:GetDabaoBossRewards(boss_id)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local prof = PlayerData.Instance:GetRoleBaseProf(main_role_vo.prof)
	for k,v in pairs(self.boss_family_cfg.dabao_boss) do
		if v.bossID == boss_id then
			local list = {}
			list = Split(v["drop_item_list" .. prof], "|")
			return list
		end
	end
end

function BossData:GetActiveBossRewards(boss_id)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local prof = PlayerData.Instance:GetRoleBaseProf(main_role_vo.prof)
	for k,v in pairs(self.active_boss_cfg) do
		if v.bossID == boss_id then
			local list = {}
			list = Split(v["drop_item_list" .. prof], "|")
			return list
		end
	end
end

function BossData:GetActiveSceneList()
	return self.active_boss_level_list
end

function BossData:GetDabaoBossClientCfg()
	return self.boss_family_cfg.dabao_boss_client
end

function BossData:IsWorldBossScene(scene_id)
	local scene_map = self.boss_scene_map[BOSS_ENTER_TYPE.TYPE_BOSS_WORLD] or {}
	return nil ~= scene_map[scene_id]
end

function BossData:IsDabaoBossScene(scene_id)
	local scene_map = self.boss_scene_map[BOSS_ENTER_TYPE.TYPE_BOSS_DABAO] or {}
	return nil ~= scene_map[scene_id]
end

function BossData:IsFamilyBossScene(scene_id)
	local scene_map = self.boss_scene_map[BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY] or {}
	return nil ~= scene_map[scene_id]
end

function BossData:IsMikuBossScene(scene_id)
	local scene_map = self.boss_scene_map[BOSS_ENTER_TYPE.TYPE_BOSS_MIKU] or {}
	return nil ~= scene_map[scene_id]
end

function BossData:IsActiveBossScene(scene_id)
	local scene_map = self.boss_scene_map[BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE] or {}
	return nil ~= scene_map[scene_id]
end

function BossData:IsSgBossScene(scene_id)
	local scene_map = self.boss_scene_map[BOSS_ENTER_TYPE.TYPE_BOSS_SHANGGU] or {}
	return nil ~= scene_map[scene_id]
end

function BossData:IsMikuPeaceBossScene(scene_id)
	local cfg = BossData.Instance:GetBossMiniMapCfg(1, 1)
	if cfg and scene_id == cfg.scene_id then
		return true
	end
	return false
end

function BossData:IsPersonalBossScene(scene_id)
	local scene_map = self.boss_scene_map[BOSS_ENTER_TYPE.TYPE_BOSS_PERSONAL] or {}
	return nil ~= scene_map[scene_id]
end

function BossData:IsBabyBossScene(scene_id)
	local scene_map = self.boss_scene_map[BOSS_ENTER_TYPE.TYPE_BOSS_BAOBAO] or {}
	return nil ~= scene_map[scene_id]
end

function BossData:IsCrossBossScene(scene_id)
	local scene_map = self.boss_scene_map[BOSS_ENTER_TYPE.TYPE_BOSS_CROSS] or {}
	return nil ~= scene_map[scene_id]
end

function BossData:IsSecretBossScene(scene_id)
	local scene_map = self.boss_scene_map[BOSS_ENTER_TYPE.TYPE_BOSS_PRECIOUS] or {}
	return nil ~= scene_map[scene_id]
end

function BossData:IsShenYuBossScene(scene_id)
	local scene_map = self.boss_scene_map[BOSS_ENTER_TYPE.TYPE_BOSS_MiZang] or {}
	return nil ~= scene_map[scene_id]
end

function BossData:IsShenYuYouMingScene(scene_id)
	local scene_map = self.boss_scene_map[BOSS_ENTER_TYPE.TYPE_BOSS_YouMing] or {}
	return nil ~= scene_map[scene_id]
end

function BossData:IsGodMagicBossScene(scene_id)
	local scene_map = self.boss_scene_map[BOSS_ENTER_TYPE.TYPE_BOSS_GODMAGIC] or {}
	return nil ~= scene_map[scene_id]
end

function BossData:GetBossFamilyRemainEnemyCount(boss_list, scene_id)
	local count = 0
	if boss_list then
		for k,v in pairs(boss_list) do
			local next_refresh_time = self:GetFamilyBossRefreshTime(v, scene_id)
			if next_refresh_time <= TimeCtrl.Instance:GetServerTime() then
				count = count + 1
			end
		end
	end
	return count
end

function BossData:GetBossFamilyIdList()
	local cfg = self:GetBossFamilyListClient()
	local id_list = {}
	if cfg then
		for k,v in pairs(cfg) do
		   id_list[k] = {}
		   for m,n in pairs(self:GetBossFamilyList(v.scene_id)) do
			  id_list[k][#id_list[k] + 1] = n.bossID
		   end
		end
	end
	return id_list
end

function BossData:GetBossMikuRemainEnemyCount(boss_list, scene_id)
	local count = 0
	for k,v in pairs(boss_list) do
		local next_refresh_time = self:GetMikuBossRefreshTime(v, scene_id)
		if next_refresh_time <= TimeCtrl.Instance:GetServerTime() then
			count = count + 1
		end
	end
	return count
end

function BossData:GetBossMikuIdList()
	local cfg = self:GetMikuBossListClient()
	local id_list = {}
	if cfg then
		for k,v in pairs(cfg) do
		   id_list[k] = {}
		   for m,n in pairs(self:GetMikuBossList(v.scene_id)) do
			  id_list[k][#id_list[k] + 1] = n.bossID
		   end
		end
	end
	return id_list
end

function BossData:GetDaBaoBossCfg()
	return self.dabao_boss_cfg
end

function BossData:GetActiveBossCfg()
	return self.active_boss_cfg
end


function BossData.IsBossScene()
	local scene_id = Scene.Instance:GetSceneId()
	if BossData.Instance then
		if BossData.Instance:IsDabaoBossScene(scene_id)
		or BossData.Instance:IsFamilyBossScene(scene_id)
		or BossData.Instance:IsMikuBossScene(scene_id)
		or BossData.Instance:IsWorldBossScene(scene_id)
		or BossData.Instance:IsActiveBossScene(scene_id)
		or BossData.Instance:IsSecretBossScene(scene_id)
		or BossData.Instance:IsSgBossScene(scene_id)
		or BossData.Instance:IsPersonalBossScene(scene_id)
		or BossData.Instance:IsCrossBossScene(scene_id)
		or BossData.Instance:IsBabyBossScene(scene_id)
		or BossData.Instance:IsShenYuBossScene(scene_id)
		or BossData.Instance:IsShenYuYouMingScene(scene_id)
		or BossData.Instance:IsGodMagicBossScene(scene_id) then
			return true
		end
	end
	return false
end


function BossData:GetCanGoAttack()
	local scene_id = Scene.Instance:GetSceneId()
	if BossData.Instance:IsDabaoBossScene(scene_id)
	or BossData.Instance:IsFamilyBossScene(scene_id)
	or BossData.Instance:IsMikuBossScene(scene_id)
	or BossData.Instance:IsWorldBossScene(scene_id)
	or BossData.Instance:IsActiveBossScene(scene_id)
	or BossData.Instance:IsSecretBossScene(scene_id)
	or BossData.Instance:IsSgBossScene(scene_id)
	or BossData.Instance:IsPersonalBossScene(scene_id)
	or BossData.Instance:IsCrossBossScene(scene_id)
	or BossData.Instance:IsBabyBossScene(scene_id) 
	or BossData.Instance:IsShenYuBossScene(scene_id)
	or BossData.Instance:IsShenYuYouMingScene(scene_id)
	or BossData.Instance:IsGodMagicBossScene(scene_id) then
		return false
	end
	return true
end


function BossData:GetCanToSceneLevel(scene)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	for k,v in pairs(self.boss_family_cfg.enter_condition) do
		if v.scene_id == scene then
			return v.min_lv <= level, v.min_lv
		end
	end
	return true
end

function BossData:GetConditionLevelByScene(scene)
	for k,v in pairs(self.boss_family_cfg.enter_condition) do
		if v.scene_id == scene then
			return v.min_lv
		end
	end
end

function BossData:GetFamilyBossCanGoByVip(scene_id)
	local limit_vip = self:GetBossVipLismit(scene_id)
	local my_vip = GameVoManager.Instance:GetMainRoleVo().vip_level
	return limit_vip <= my_vip
end

function BossData:GetBossHuDunScale(boss_id)
	for k,v in pairs(self.worldboss_auto.worldboss_list) do
		if boss_id == v.bossID then
			return v.scale
		end
	end
end

function BossData:GetMiKuRedPoint()
	if not OpenFunData.Instance:CheckIsHide("miku_boss") then return 0 end
	-- if not BossData.BossRemindPoint[RemindName.Boss_MiKu] then
	-- 	return 0
	-- end

	local data_list = KaifuActivityData.Instance:GetBossTouZiDataList()
	for i, v in ipairs(data_list) do
		if not InvestData.Instance:CheckIsFetchedBossByID(v.index + 1) and InvestData.Instance:CheckIsActiveBossByID(v.index + 1) then
			return 1
		end
	end

	if self.boss_family_cfg and self.boss_family_cfg.other and self.boss_family_cfg.other[1] and self.boss_family_cfg.other[1].weary_upper_limit 
		and self.miku_boss_info and self.miku_boss_info.miku_boss_weary then

		local pi_lao = self.boss_family_cfg.other[1].weary_upper_limit - self.miku_boss_info.miku_boss_weary
		if pi_lao <= 0 then
			return 0
		elseif pi_lao > 0 then
			return 1
		end
	end

	-- local list = self:GetMikuBossListClient()
	-- if list then
	-- 	for k,v in pairs(list) do
	-- 		local can_go = self:GetCanToSceneLevel(v.scene_id)
	-- 		if can_go then
	-- 			if self.miku_boss_info.boss_list[v.scene_id] then
	-- 				for m,n in pairs(self.miku_boss_info.boss_list[v.scene_id]) do
	-- 					if n.status > 0 then
	-- 						return 1
	-- 					end
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end

	return 0
end

function BossData:GetDaBaoRedPoint()
	if not OpenFunData.Instance:CheckIsHide("dabao_boss") then return 0 end
	local is_show = RemindManager.Instance:RemindToday(RemindName.Boss_DaBao)
	if is_show then
		return 0
	end
	-- if self.dabao_enter_count then
	-- 	return 1
	-- else
	-- 	return 0
	-- end
	return 1
end

function BossData:GetFamilyRedPoint()
	-- if not OpenFunData.Instance:CheckIsHide("vip_boss") then return 0 end
	-- if not BossData.BossRemindPoint[RemindName.Boss_Family] then
	-- 	return 0
	-- end
	-- local my_vip = GameVoManager.Instance:GetMainRoleVo().vip_level
	-- for k,v in pairs(self.boss_family_cfg.boss_family) do
	-- 	local next_refresh_time = self:GetFamilyBossRefreshTime(v.boss_id, v.scene_id)
	-- 	local vip_level = BossData.Instance:GetBossVipLismit(v.scene_id)
	-- 	-- local is_show = RemindManager.Instance:RemindToday(RemindName.Boss_Family)
	-- 	if  my_vip > vip_level then
	-- 		return 1
	-- 	end
	-- end
	return 0
end

function BossData:GetBabyRedPoint()
	if not OpenFunData.Instance:CheckIsHide("baby_boss") then return 0 end
	local is_show = RemindManager.Instance:RemindToday(RemindName.Boss_Baby)
	if is_show then
		return 0
	end
	-- local enter_limit = VipData.Instance:GetBabyBossEnterTimes(VIPPOWER.BABYBOSS_ENTER_TIMES)
	-- local enter_times = BossData.Instance:GetBabyBossEnterTimes()
	-- if enter_limit and enter_times then
	-- 	local left_times = enter_limit - enter_times
	-- 	if left_times == 0 then
	-- 		return 0
	-- 	end
	-- end

	-- for k,v in pairs(self.baby_boss_all_info) do
	-- 	if v.next_refresh_time == 0 then
	-- 		return 1
	-- 	end
	-- end
	return 1
end

function BossData:GetPersonalRedPoint()
	if not OpenFunData.Instance:CheckIsHide("personal_boss") then return 0 end
	-- if not BossData.BossRemindPoint[RemindName.Boss_Personal] then
	-- 	return 0
	-- end

	local boss_list = BossData.Instance:GetPersonalBossList()
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	if next(self.personal_boss_enter_list) ~= nil then
		for k,v in pairs(self.personal_boss_enter_list) do
			if v.layer and boss_list[v.layer] and boss_list[v.layer].need_level and my_level >= boss_list[v.layer].need_level then
				local max_enter_num = BossData.Instance:GetPersonalBossMaxEnterTimeBylayer(k)
				local num = ItemData.Instance:GetItemNumInBagById(boss_list[v.layer].need_item_id)
				if v.times < max_enter_num and num >= boss_list[v.layer].need_item_num  then
					return 1
				end
			end
		end
	end
	return 0
end

-- function BossData:GetShangguRedPoint()
-- 	if RemindManager.Instance:RemindToday(RemindName.Boss_Shanggu) then
-- 		return 0
-- 	end
-- 	local enter_times, max_enter_times = self:GetSgBossEnterTimes()
-- 	local left_times = max_enter_times - enter_times
-- 	local is_show = RemindManager.Instance:RemindToday(RemindName.Boss_Shanggu)
-- 	if left_times > 0 and not is_show then
-- 		return 1
-- 	else
-- 		return 0
-- 	end
-- end

function BossData:SetIsAutoBuy(string)
	self.auto_string = string
end

function BossData:GetIsAutoBuy(string)
	return string == self.auto_string
end

function BossData:GetTujianRedPoint(index)
	if not OpenFunData.Instance:CheckIsHide("tujian_boss") then return 0 end
	local list = self:FormatMenu(index)
	for k,v in pairs(list) do
		if v.can_activef == 1 then
			return 1
		end
	end

	-- for i = 1 , #list do
	-- 	for k,v in ipairs(list[i].child) do
	-- 		if v.progress == 100 and v.reward_flag == 0 then
	-- 			return 1
	-- 		end
	-- 	end
	-- end

	return 0
end

function BossData:GetCrossRedPoint()
	-- local tire, max_tire = BossData.Instance:GetCrossBossTire()
	-- local differ = max_tire - tire
	-- if differ > 0 then
	-- 	return 1
	-- end

	local data_list = KaifuActivityData.Instance:GetShenYuBossTouZiDataList()
	for i, v in ipairs(data_list) do
		if not InvestData.Instance:CheckIsFetchedShenYuBossByID(v.index + 1) and InvestData.Instance:CheckIsActiveShenYuBossByID(v.index + 1) then
			return 1
		end
	end

	return 0
end

function BossData:GetActiveRedPoint()
	if not OpenFunData.Instance:CheckIsHide("active_boss") then return 0 end
	-- if not BossData.BossRemindPoint[RemindName.Boss_Active] then
	-- 	return 0
	-- end
	local max_wearry = self:GetActiveBossMaxWeary()
	local active_weary = self:GetActiveBossWeary()
	if max_wearry and active_weary then
		local weary = max_wearry - active_weary
		if weary <= 0 then
			return 0
		elseif weary > 0 then
			return 1
		end
	end
	return 0
end
function BossData:GetSecretRedPoint()
	local data = self.boss_family_cfg.precious_boss_task
	for k,v in pairs(data) do
		-- 服务端没数据过来说明还未开始做任务。。。不知道谁一开始搞的鬼逻辑
		if self.task_map and nil == self.task_map[v.task_id] then
			return 1
		elseif self.task_map and self.task_map[v.task_id] and self.task_map[v.task_id].is_finish == 0 then
			return 1
		end
	end
	if self.show_boss_red_point then
		return 1
	end
	return 0
end

function BossData:SecretBossRedPointTimer(is_need)
	self.show_boss_red_point = is_need
end

function BossData:GetBossRemind()
	return self:CheckRedPoint() == 1 and 1 or 0
end

function BossData:GetMainBossRemind()
	if self:GetBossRemind() >= 1 then
		return 1
	end
	if self:GetFamilyRedPoint() >= 1 then
		return 1
	end
	if self:GetDaBaoRedPoint() >= 1 then
		return 1
	end
	if self:GetBabyRedPoint() >= 1 then
		return 1
	end
	if self:GetPersonalRedPoint() >= 1 then
		return 1
	end
	if self:GetTujianRedPoint(0) >= 1 then
		return 1
	end

	local data_list = KaifuActivityData.Instance:GetBossTouZiDataList()
	for i, v in ipairs(data_list) do
		if not InvestData.Instance:CheckIsFetchedBossByID(v.index + 1) and InvestData.Instance:CheckIsActiveBossByID(v.index + 1) then
			return 1
		end
	end

	-- if self:GetMiKuRedPoint() >= 1 then
	-- 	return 1
	-- end
	-- if self:GetActiveRedPoint() >= 1 then
	-- 	return 1
	-- end
	return 0
end

function BossData:CheckRedPoint()
	if not OpenFunData.Instance:CheckIsHide("world_boss") then
	 return 0
	end

	local list = self:GetWorldBossList()
	if list then
		for k,v in pairs(list) do
			if v.status == 1 then
				return 1
			end
		end
	end
	return 0
end

function BossData:MainuiOpenCreate()
	self.main_ui_is_open = true
end

function BossData:GetCanGoLevel(boss_type)
	local scene_list = self.boss_scene_map[boss_type] or {}
	local min_lv_list = {}
	for k,v in pairs(self.boss_family_cfg.enter_condition) do
		for k1, v1 in pairs(scene_list) do
			if v.scene_id == v1 then
				table.insert(min_lv_list, v.min_lv)
			end
		end
	end

	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	local index = 0
	for k,v in pairs(min_lv_list) do
		if my_level < v then
			if k ~= 1 then
				index = k - 1
			else
				index = 1
			end
			break
		end
	end
	if index == 0 then
		if my_level <= min_lv_list[1] then
			index = 1
		elseif my_level >= min_lv_list[#min_lv_list] then
			index = #min_lv_list
		end
	end
	if boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY then
		local vip_level_list = {}
		local vip_index = 0
		for k,v in pairs(scene_list) do
			local vip_limit = self:GetBossVipLismit(v)
			table.insert(vip_level_list, vip_limit)
		end
		local my_vip = GameVoManager.Instance:GetMainRoleVo().vip_level
		for k,v in pairs(vip_level_list) do
			if my_vip < v then
				if k == 1 then
					vip_index = 1
				else
					vip_index = k - 1
				end
				break
			end
		end
		if vip_index == 0 then
			if my_vip <= vip_level_list[1] then
				vip_index = 1
			elseif my_level >= vip_level_list[#vip_level_list] then
				vip_index = #vip_level_list
			end
		end
		if index >= vip_index then
			index = vip_index
		end
	end
	return index
end

function BossData:GetWorldBossRewardItems(scene_id)
	local data_list = {}
	local item_list = {}
	for k,v in pairs(self.all_boss_list) do
		if v.scene_id == scene_id then
			for i = 1, 3 do
				local data = {}
				data.item_id = v["scene_item_id"..i]
				data.num = 1
				data.is_bind = 0
				item_list[i] = data
			end
			break
		end
	end
	return item_list
end

function BossData:GetWelfareBossFlushTimeCfg()
	local other_cfg = self:GetBossOtherConfig()
	local time_list = {}
	time_list[1] = other_cfg.refresh_time_one / 100
	time_list[2] = other_cfg.refresh_time_two / 100
	return time_list
end

function BossData:SetBossHpInfo(protocol)
	self.boss_hp = protocol
end

function BossData:GetBossHpInfo()
	return self.boss_hp
end

function BossData:GetRefreshEliteLeftTimes(ignore_scene)
	local left_times = 0
	if nil == self.boss_family_cfg then
		return left_times
	end

	local cfg_list = {}
	if ignore_scene then
		cfg_list = self.boss_family_cfg.miku_monster
	else
		cfg_list = self.miku_monster_list_cfg[Scene.Instance:GetSceneId()] or {}
	end

	local server_time = TimeCtrl.Instance:GetServerTime()
	server_time = math.floor(server_time)
	local h = tonumber(os.date("%H", server_time))
	local m = tonumber(os.date("%M", server_time))
	local s = tonumber(os.date("%S", server_time))
	local now_second = h * 3600 + m * 60 + s

	for k, v in ipairs(cfg_list) do
		if now_second >= v.start_refresh_time and now_second <= v.end_refresh_time then
			local pass_times = math.ceil((now_second - v.start_refresh_time) % v.refresh_interval)
			left_times = v.refresh_interval - pass_times
			break
		else
			left_times = v.start_refresh_time - now_second
			break
		end
	end

	return left_times
end

function BossData:GetMiKuEliteDropMaxLevel(scene_id)
	local cfg = self.miku_monster_list_cfg[scene_id]
	return cfg and cfg[1] and cfg[1].drop_limit or 0
end

--获取刷新时间区间
function BossData:GetMiKuEliteReFreshSection()
	local start_refresh_time = 0
	local end_refresh_time = 0
	local refresh_interval = 0

	if nil == self.boss_family_cfg then
		return start_refresh_time, end_refresh_time, refresh_interval
	end

	local miku_monster = self.boss_family_cfg.miku_monster or {}
	for k, v in ipairs(miku_monster) do
	   start_refresh_time = v.start_refresh_time
	   end_refresh_time = v.end_refresh_time
	   refresh_interval = v.refresh_interval
	   break
	end

	return start_refresh_time, end_refresh_time, refresh_interval
end

-------------秘藏Boss数据------------

function BossData:GetSecretBossList()
	local list = {}
	local dead_boss = {}
	local world_level = RankData.Instance:GetWordLevel() or 0
	local data = self.boss_family_cfg.precious_boss_monster
	local range = GetDataRange(data, "world_level")
	local rank = GetRangeRank(range, world_level)
	for k,v in ipairs(data) do
		if v.world_level == rank and v.monster_type == 0 then
			if self.boss_list[v.monster_id] == 0 then
				table.insert(list, v)
			else
				table.insert(dead_boss,v)
			end
		end
	end
	for k,v in pairs(dead_boss) do
		table.insert(list,v)
	end
	return list,dead_boss
end

function BossData:GetBossDataByID(data,id)
	for k,v in pairs(data) do
		if v.monster_id == id then
			return v
		end
	end
end

function BossData:GetSecretBossRefreshTime(boss_id, scene_id)
	if self.miku_boss_info.boss_list[scene_id] and #self.miku_boss_info.boss_list[scene_id] ~= 0 then
		for k,v in pairs(self.miku_boss_info.boss_list[scene_id]) do
			if v.boss_id == boss_id then
				return v.next_refresh_time, v.status
			end
		end
	end
	return 0, 0
end

function BossData:GetTaskInfo()
	if not self.task_scroller_data then
		self:FlushTombFBTaskInfo()
	end
	return self.task_scroller_data
end

function BossData:IsTaskAllDone()
	return false
end

function BossData:FlushTombFBTaskInfo()
	self.task_scroller_data = {}
	local finish_task_list = {}
	local un_finish_task_list = {}

	for k,v in pairs(self.boss_family_cfg.precious_boss_task) do
			local text = ""
			if v.task_type == 2 then
			--采集
				local gather_cfg = v.target_name
				text = text..ToColorStr(gather_cfg, TEXT_COLOR.GREEN_4)
			else
			--打怪
				local monster_cfg = v.target_name
				text = text..ToColorStr(monster_cfg, TEXT_COLOR.GREEN_4)
			end
			local is_finish = 0
			if self.task_map and self.task_map[v.task_type] then
				is_finish = self.task_map[v.task_type].is_finish
			end
			if is_finish == 1 then
				--完成
				text = text..
				ToColorStr("(", TEXT_COLOR.GRAY_WHITE)..
				ToColorStr( v.task_condition, TEXT_COLOR.GRAY_WHITE)..
				ToColorStr(" / "..v.task_condition, TEXT_COLOR.GRAY_WHITE)..ToColorStr(")", TEXT_COLOR.GRAY_WHITE)
			else
			--未完成
				local task_condition = 0
				if self.task_map and self.task_map[v.task_type] then
					task_condition = self.task_map[v.task_type].task_condition
				end
				text = text..
				ToColorStr("(", TEXT_COLOR.GRAY_WHITE)..
				ToColorStr( task_condition, TEXT_COLOR.GRAY_WHITE)..
				ToColorStr(" / "..v.task_condition, TEXT_COLOR.GRAY_WHITE)..ToColorStr(")", TEXT_COLOR.GRAY_WHITE)
			end

			local data = {}
			data.cfg = v
			data.target_text = text
			data.is_finish = (is_finish == 1)
			data.reward_target = self:GetRewardById(v.task_type)
			if data.is_finish then
				table.insert(finish_task_list, data)
			else
				table.insert(un_finish_task_list, data)
			end
		end
	for k,v in pairs(un_finish_task_list) do
		table.insert(self.task_scroller_data, v)
	end
	for k,v in pairs(finish_task_list) do
		table.insert(self.task_scroller_data, v)
	end
end

function BossData:GetTaskFinshInfo(id)
	for k,v in pairs(self.fb_data.task_list) do
		if v.task_id == id then
			return v.is_finish
		end
	end
	return 0
end

function BossData:GetCurParam(id)
	return 0
end

function BossData:GetTaskDataByID(id)
	local data = nil
	local s_data = self:GetTaskInfo()
	for k,v in pairs(s_data) do
		if v.cfg.task_id == id then
			return v
		end
	end
end

function BossData:GetParamById(id)
	return self.task_cfg[id][1].task_type
end

function BossData:NotifyTaskProcessChange(task_id, func)
	self.task_change_callback = func
	self.monitor_task_id = task_type
end

function BossData:UnNotifyTaskProcessChange()
	self.task_change_callback = nil
end

function BossData:TaskMonitor()
	if self.task_list and self.task_change_callback ~= nil then
		for k,v in pairs(self.fb_data.task_list) do
			if v.task_type == self.monitor_task_id then
				if v.task_condition > self.task_list[k].task_condition then
					self.task_change_callback()
				end
				break
			end
		end
	end
end

function BossData:SetSecretTaskData(protocol)
	self.task_map = {}
	self.fb_data = {}
	self.fb_data.task_list = protocol.task_list
	for k,v in pairs(self.fb_data.task_list) do
		self.task_map[v.task_type] = {}
		self.task_map[v.task_type].task_condition = v.task_condition
		self.task_map[v.task_type].is_finish = v.is_finish
	end
	self:FlushTombFBTaskInfo()
	self:TaskMonitor()
	self.task_list = self.fb_data.task_list
end

function BossData:SetSecretBossInfo(protocol)
	self.boss_list = {}
	for k,v in pairs(protocol.boss_list) do
		self.boss_list[v.boss_id] = v.next_refresh_time
	end
end


function BossData:GetGatherPosition()
	local list = {}
	local data = self.boss_family_cfg.precious_boss_pos
	list.gathers = {}
	list.monsters = {}
	for k,v in pairs(data) do
		if v.pos_type == 2 then
			table.insert(list.gathers,v)
		else
			table.insert(list.monsters,v)
		end
	end
	return list
end

function BossData:GetItemStatusById(id)
	return self.boss_list[id] and self.boss_list[id] or 0
end

function BossData:GetCurTargetPos()
	return self.target.x, self.target.y, self.target.id
end

function BossData:GetRewardById(id)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	
	for i,v in ipairs(self.boss_family_cfg.boss_reward_level) do
		if level <= v.level then
			if self.secret_reward_cfg and self.secret_reward_cfg[v.level] and self.secret_reward_cfg[v.level][id] then
				return self.secret_reward_cfg[v.level][id][1].reward_score
			 end
		end 
	end
	return 0
end

function BossData:SetTargetPos(protocol)
	self.target = {}
	self.target.x = protocol.pos_x
	self.target.y = protocol.pos_y
	self.target.id = protocol.param
end

--获取秘藏boss不可打架的范围半径
function BossData:GetSecretNotPkRadius()
	return self.precious_boss_other_cfg.forbid_pk_radius or 0
end

--获取秘藏boss不可攻击的范围中心点
function BossData:GetSecretNotPkCenterXY()
	local center_x = self.precious_boss_other_cfg.forbid_pk_pos_x or 0
	local center_y = self.precious_boss_other_cfg.forbid_pk_pos_y or 0

	return center_x, center_y
end

function BossData:SetSecretExchangeValue(value)
	self.secret_value = value
end

function BossData:GetSecretValue()
	return self.secret_value or 0
end

function BossData:GetSecretOtherCfg()
	return self.precious_boss_other_cfg
end

function  BossData:GetTaskNum()
	local num = 0
	for i,v in pairs(self:GetTaskInfo()) do
		if v.is_finish == false then
			num = num + 1
		end
	end

	return num
end

-- 红色装备转换下属性(强行写死)
function BossData:GetShowEquipItemList(item_id)
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(item_id)
	local data = {item_id = item_id}
	data.index = -1
	data.param = {}
	data.param.xianpin_type_list = {3, 2, 1}
	if item_cfg then
		if EquipData.IsShengXiaoEqType(item_cfg.sub_type) or EquipData.IsLongQiEqType(item_cfg.sub_type) or EquipData.IsBianShenEquipType(item_cfg.sub_type) or DouQiData.Instance:IsDouqiEqupi(item_id) then
			data.param.xianpin_type_list = {}
		end
	end

	return data
end

function BossData:GetShowEquipItemList2(item_id)
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(item_id)
	local data = {item_id = item_id}
	data.index = -1
	data.param = {}
	data.param.xianpin_type_list = {1}
	if item_cfg then
		if EquipData.IsShengXiaoEqType(item_cfg.sub_type) or EquipData.IsLongQiEqType(item_cfg.sub_type) or EquipData.IsBianShenEquipType(item_cfg.sub_type) then
			data.param.xianpin_type_list = {}
		end
	end

	return data
end

function BossData:GetActiveBossNum(scene_id)
	local boss_num = 0
	for k,v in pairs(self.active_boss_cfg) do
		if v.scene_id == scene_id then
			local reflash_time = self:GetActiveStatusByBossId(v.bossID, scene_id)
			if reflash_time <= 0 then
				boss_num = boss_num + 1
			end
		end
	end
	return boss_num
end

function BossData:GetFamilyBossNum(scene_id)
	local boss_num = 0
	for k,v in pairs(self.boss_family_cfg.boss_family) do
		if v.scene_id == scene_id then
			local reflash_time = self:GetFamilyBossRefreshTime(v.bossID, scene_id)
			local diff_time = reflash_time - TimeCtrl.Instance:GetServerTime()
			if diff_time <= 0 then
				boss_num = boss_num + 1
			end
		end
	end
	return boss_num
end

function BossData:GetDaBaoBossNum(scene_id)
	local boss_num = 0
	for k,v in pairs(self.boss_family_cfg.dabao_boss) do
		if v.scene_id == scene_id then
			local reflash_time = self:GetDaBaoStatusByBossId(v.bossID, scene_id)
			if reflash_time <= 0 then
				boss_num = boss_num + 1
			end
		end
	end
	return boss_num
end

function BossData:GetMikuBossNum(scene_id)
	local boss_num = 0
	for k,v in pairs(self.boss_family_cfg.miku_boss) do
		if v.scene_id == scene_id then
			local reflash_time = self:GetMikuBossRefreshTime(v.bossID, scene_id)
			local diff_time = reflash_time - TimeCtrl.Instance:GetServerTime()
			if diff_time <= 0 then
				boss_num = boss_num + 1
			end
		end
	end
	return boss_num
end

function BossData:GetSecretBossNum()
	local boss_list = self:GetSecretBossList()
	local boss_num = 0
	for i,v in ipairs(boss_list) do
		local next_refresh_time = self:GetItemStatusById(v.monster_id)
		local diff_time = next_refresh_time - TimeCtrl.Instance:GetServerTime()
		if diff_time <= 0 then
			boss_num = boss_num + 1
		end
	end
	return boss_num
end

function BossData:SetDropLog(protocol)
	self.drop_list = protocol.log_list
end

function BossData:SetCrossDropLog(protocol)
	self.cross_drop_list = protocol.dorp_record_list
end

function BossData:GetShenYuBossDropLog()
	function sortfun(a, b)
		if a.timestamp > b.timestamp then
			return true
		else
			return false
		end
	end
	table.sort(self.cross_drop_list, sortfun)
	return self.cross_drop_list
end

function BossData:GetDropLog(is_defence)
	if is_defence then
		table.sort(self.drop_list, SortTools.KeyUpperSorters("color", "timestamp", "item_id", "monster_id"))
	else
		table.sort(self.drop_list, SortTools.KeyUpperSorter("timestamp"))
	end
	return self.drop_list
end

-------------- 宝宝boss --------------
function BossData:SetBabyBossRoleInfo(protocol)
	self.baby_boss_role_info = protocol or {}
end

function BossData:SetBabyBossAllInfo(protocol)
	self.baby_boss_count = protocol.boss_count or 0
	self.baby_boss_all_info = protocol.boss_info_list or {}
end

function BossData:SetBabyBossSingleInfo(protocol)
	local baby_boss_single_info = protocol.boss_info or {}
	local boss_id = baby_boss_single_info.boss_id or 0
	if nil == next(self.baby_boss_all_info) then
		return
	end
	for k,v in ipairs(self.baby_boss_all_info) do
		if v.boss_id == boss_id then
			self.baby_boss_all_info[k] = baby_boss_single_info
			return
		end
	end
end

function BossData:GetBabyBossAngryValue()
	return self.baby_boss_role_info.angry_value or 0
end

function BossData:GetBabyBossEnterTimes()
	return self.baby_boss_role_info.enter_times or 0
end

function BossData:GetBabyBossKickTime()
	return self.baby_boss_role_info.kick_time or 0
end

function BossData:GetBabyBossMaxAngryValue()
	if nil == self.baby_boss_cfg then
		return 0
	end
	return self.baby_boss_cfg.other[1].angry_value_limit or 0
end

function BossData:GetBabyBosskillerInfo(boss_id)
	if nil == next(self.baby_boss_all_info) then
		return nil
	end
	for i,v in ipairs(self.baby_boss_all_info) do
		if v.boss_id == boss_id then
			return v.killer_info
		end
	end
	return nil
end

function BossData:GetBabyBossEnterCost()
	if nil == next(self.baby_boss_role_info) or nil == next(self.baby_boss_enter_cost) then
		return -1, true
	end

	local enter_times = self.baby_boss_role_info.enter_times or 0
	local max_enter_times = self:GetBabyBossEnterLimitTimes()
	if enter_times >= max_enter_times then
		return -1, true
	end
	if nil == self.baby_boss_enter_cost[enter_times] then
		return -1, true
	end

	local enter_cost = self.baby_boss_enter_cost[enter_times].cost or -1
	local is_bind = self.baby_boss_enter_cost[enter_times].is_bind == 1 and true or false
	return enter_cost, is_bind
end

function BossData:GetBabyEnterCondition()
	if nil == next(self.baby_boss_enter_cost) or nil == self.baby_boss_cfg then
		return
	end
	local enter_times = self.baby_boss_role_info.enter_times or 0
	return self.baby_boss_cfg.other[1].need_item_id, self.baby_boss_enter_cost[enter_times].need_item_num
end

function BossData:GetBabyNeedByTimes(enter_times)
	if nil == next(self.baby_boss_enter_cost) or nil == self.baby_boss_cfg then
		return 0
	end
	return self.baby_boss_enter_cost[enter_times].need_item_num
end

function BossData:GetBabyBossEnterLimitTimes()
	if nil == self.baby_boss_enter_cost then
		return 0
	end
	return #self.baby_boss_enter_cost + 1
end

function BossData:GetBabyBossDataListByLayer(layer)
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
	if nil == next(self.baby_boss_all_info)
		or nil == self.baby_boss_cfg
		or nil == monster_cfg
		or nil == next(self.baby_boss_angry_value) then
		return {}
	end
	local layer_scene_auto = self.baby_boss_cfg.layer_scene[layer]
	if nil == layer_scene_auto then
		return {}
	end
	local scene_id = layer_scene_auto.scene_id or 0
	local boss_list = {}
	for i,v in ipairs(self.baby_boss_all_info) do
		if scene_id == v.scene_id then
			local temp_boss_item = {}
			temp_boss_item.boss_id = v.boss_id
			temp_boss_item.scene_id = v.scene_id
			temp_boss_item.next_refresh_time = v.next_refresh_time
			if monster_cfg[v.boss_id] then
				local temp_boss_info = {}
				temp_boss_info.level = monster_cfg[v.boss_id].level
				temp_boss_info.name = monster_cfg[v.boss_id].name
				temp_boss_info.headid = monster_cfg[v.boss_id].headid
				temp_boss_info.boss_type = monster_cfg[v.boss_id].boss_type
				if self.baby_boss_angry_value[v.boss_id] then
					temp_boss_info.angry_value = self.baby_boss_angry_value[v.boss_id].angry_value or 0
				else
					temp_boss_info.angry_value = 0
				end
				temp_boss_item.boss_info = temp_boss_info
			end
			table.insert(boss_list, temp_boss_item)
		end
	end

	function sortfun(a, b)
		local state_a = a.next_refresh_time > 0 and 1 or 0
		local state_b = b.next_refresh_time > 0 and 1 or 0
		if state_a ~= state_b then
			return state_a < state_b
		else
			local level_a = a.boss_info.level or 0
			local level_b = b.boss_info.level or 0
			return level_a < level_b
		end
	end
	table.sort(boss_list, sortfun)
	return boss_list
end

function BossData:GetBabyEliteList(layer)
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
	if nil == self.baby_boss_cfg
		or nil == self.baby_boss_cfg.layer_scene
		or nil == self.baby_boss_cfg.scene_cfg
		or nil == monster_cfg
		or nil == next(self.baby_boss_angry_value) then
		return {}
	end

	if nil == self.baby_boss_cfg.layer_scene[layer] then
		return {}
	end
	local scene_id = self.baby_boss_cfg.layer_scene[layer].scene_id or 0
	local elite_list = {}
	for i,v in ipairs(self.baby_boss_cfg.scene_cfg) do
		if scene_id == v.scene_id and v.is_boss == 0 then
			local temp_elite_list = {}
			temp_elite_list.boss_id = v.monster_id
			temp_elite_list.scene_id = v.scene_id
			temp_elite_list.is_boss = v.is_boss
			temp_elite_list.next_refresh_time = 0       -- 宝宝boss精英怪的下一次刷新时间默认为0，即不显示刷新时间
			local monster_info = monster_cfg[v.monster_id]
			if monster_info then
				local temp_elite_info = {}
				temp_elite_info.level = monster_info.level
				temp_elite_info.name = monster_info.name
				if self.baby_boss_angry_value[v.monster_id] then
					temp_elite_info.angry_value = self.baby_boss_angry_value[v.monster_id].angry_value or 0
				else
					temp_elite_info.angry_value = 0
				end
				temp_elite_list.boss_info = temp_elite_info
			end
			table.insert(elite_list, temp_elite_list)
		end
	end
	return elite_list
end

function BossData:GetBabyBossMaxAngryValue()
	if nil == self.baby_boss_cfg then
		return 0
	end
	return self.baby_boss_cfg.other[1].angry_value_limit or 0
end

function BossData:GetBabyBossAliveNumByLayer(layer)
	if nil == self.baby_boss_all_info
		or nil == self.baby_boss_cfg
		or nil == self.baby_boss_cfg.layer_scene
		or nil == self.baby_boss_cfg.layer_scene[layer] then
		return 0
	end

	local num = 0
	local scene_id = self.baby_boss_cfg.layer_scene[layer].scene_id or 0
	for i,v in ipairs(self.baby_boss_all_info) do
		if v.scene_id == scene_id and v.next_refresh_time == 0 then
			num = num + 1
		end
	end
	return num
end

function BossData:GetBabyBossFallList(boss_id)
	if nil == self.baby_boss_cfg or nil == self.baby_boss_cfg.scene_cfg then
		return {}
	end
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local prof = PlayerData.Instance:GetRoleBaseProf(main_role_vo.prof)
	for i,v in ipairs(self.baby_boss_cfg.scene_cfg) do
		if v.monster_id == boss_id then
			local item_list = {}
			item_list = Split(v["drop_item_list" .. prof], "|")
			return item_list or {}
		end
	end
	return {}
end

function BossData:GetBabyBossListClient()
	if nil == self.baby_boss_cfg then
		return nil
	end
	return self.baby_boss_cfg.layer_scene or nil
end

function BossData:GetBabyBossCanToSceneLevel(scene_id)
	if nil == self.baby_boss_cfg or nil == self.baby_boss_cfg.scene_cfg then
		return false, 0
	end

	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	for i,v in ipairs(self.baby_boss_cfg.scene_cfg) do
		local scene_cfg = ConfigManager.Instance:GetSceneConfig(v.scene_id)
		if nil == scene_cfg then
			return false, 0
		end
		if scene_id == v.scene_id and my_level < scene_cfg.levellimit then
			return false, scene_cfg.levellimit
		end
	end
	return true, 0
end

function BossData:GetBabyBossCanGoLevel()
	if nil == self.baby_boss_cfg then
		return 0
	end

	local min_level_list = self.baby_boss_cfg.scene_cfg
	if nil == min_level_list then
		return 0
	end

	local max_layer = #self:GetBabyBossFloorList()
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	local scene_id = 0
	for i,v in ipairs(min_level_list) do
		local scene_cfg = ConfigManager.Instance:GetSceneConfig(v.scene_id)
		if my_level >= scene_cfg.levellimit then
			scene_id = v.scene_id
			break
		end
	end
	if scene_id == 0 then
		local first_scene_cfg = ConfigManager.Instance:GetSceneConfig(min_level_list[1].scene_id)
		local last_scene_cfg = ConfigManager.Instance:GetSceneConfig(min_level_list[#min_level_list].scene_id)
		if nil == first_scene_cfg or nil == last_scene_cfg then
			return 0
		end
		local first_level_limit = first_scene_cfg.levellimit
		local last_level_limit = last_scene_cfg.levellimit
		if my_level <= first_level_limit then
			return 1
		elseif my_level >= last_level_limit then
			return max_layer
		end
	end

	local layer = self:GetBabyBossLayerBySceneID(scene_id)
	return layer
end

function BossData:GetBabyBossSceneIDByBossID(boss_id)
	if nil == self.baby_boss_cfg or nil == self.baby_boss_cfg.scene_cfg then
		return 0
	end

	for i,v in ipairs(self.baby_boss_cfg.scene_cfg) do
		if boss_id == v.monster_id then
			return v.scene_id or 0
		end
	end
	return 0
end

function BossData:GetBabyBossLayerBySceneID(scene_id)
	if nil == self.baby_boss_cfg or nil == self.baby_boss_cfg.layer_scene then
		return 0
	end

	for i,v in ipairs(self.baby_boss_cfg.layer_scene) do
		if scene_id == v.scene_id then
			return v.layer
		end
	end
	return 0
end

function BossData:GetBabyBossFloorList()
	if nil == self.baby_boss_cfg or nil == self.baby_boss_cfg.layer_scene then
		return {}
	end

	local layer_list = {}
	for i,v in ipairs(self.baby_boss_cfg.layer_scene) do
		layer_list[i] = v.layer
	end
	return layer_list
end

function BossData:GetBabyBossLocationByBossID(scene_id, boss_id)
	if nil == self.baby_boss_scene_cfg then
		return 0, 0
	end

	local scene_cfg = self.baby_boss_scene_cfg[boss_id]
	if scene_cfg ~= nil then
		return scene_cfg.born_pos_x, scene_cfg.born_pos_y
	else
		return 0, 0
	end
end

------------   个人BOSS   ------------
function BossData:GetPersonalBossList()
	self.personal_boss_list = TableCopy(self.personal_boss_scen_cfg)
	local boss_data = {}
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local prof = PlayerData.Instance:GetRoleBaseProf(main_role_vo.prof)
	for i = 1, #self.personal_boss_list do
		if self.personal_boss_list[i] then
			self.personal_boss_list[i].index = i
			local boss_id = nil
			if prof ~= 1 then
				self.personal_boss_list[i].boss_id = self.personal_boss_list[i]["boss_id" .. prof]
			end
			boss_data = self:GetMonsterInfo(self.personal_boss_list[i].boss_id)
			if boss_data then
				self.personal_boss_list[i].boss_level = boss_data.level
				self.personal_boss_list[i].boss_name = boss_data.name
				self.personal_boss_list[i].boss_hp = boss_data.hp
				self.personal_boss_list[i].boss_atk = boss_data.gongji
				self.personal_boss_list[i].boss_defen = boss_data.fangyu
				self.personal_boss_list[i].damage_type = boss_data.damage_type
				self.personal_boss_list[i].boss_magdef = boss_data.fa_fangyu
			end
		end
	end

	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	for i= #self.personal_boss_list, 1, -1 do
		if self.personal_boss_list[i].min_lv > my_level or self.personal_boss_list[i].max_lv < my_level then
			table.remove(self.personal_boss_list, i)
		end
	end
	-- local temp_list = {}
	-- for i= #self.personal_boss_list, 1, -1 do
		-- local left_enter_num = BossData.Instance:GetPersonalBossEnterTimeBylayer(i)
		-- local max_enter_num = BossData.Instance:GetPersonalBossMaxEnterTimeBylayer(i)
		-- if left_enter_num then
			-- left_enter_num = max_enter_num - left_enter_num
			-- if left_enter_num <= 0 then
				-- table.insert(temp_list, self.personal_boss_list[i])
				-- table.remove(self.personal_boss_list, i)
			-- end
		-- end
	-- end
	-- for k,v in pairs(temp_list) do
	-- 	table.insert(self.personal_boss_list, v)
	-- end
	return self.personal_boss_list
end

function BossData:GetPersonalCanGoMaxLevelBossInfo()
	local list = self:GetPersonalBossList()
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local max_level_info = nil
	if list then
		for i,v in ipairs(list) do
			if role_level >= v.need_level then
				max_level_info = v
			end
		end
	end
	return max_level_info
end

function BossData:GetPersonalBossInfoByBossID(boss_id)
	if nil == self.personal_boss_list then return end
	local boss_info_list = {}
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local prof = PlayerData.Instance:GetRoleBaseProf(main_role_vo.prof)
	for k,v in pairs(self.personal_boss_list) do
		if v.boss_id == boss_id then
			boss_info_list = Split(v["drop_item_list" .. prof], "|")
			return boss_info_list
		end
	end
end

function BossData:SetPersonalBossEnterInfo(num)
	self.personal_boss_enter_num = num
	RemindManager.Instance:Fire(RemindName.Boss_Personal)
	RemindManager.Instance:Fire(RemindName.Main_Boss)
end

function BossData:SetPersoanlBossEnterTimes(info_list)
	self.personal_boss_enter_list = info_list
	RemindManager.Instance:Fire(RemindName.Boss_Personal)
	RemindManager.Instance:Fire(RemindName.Main_Boss)
end

function BossData:GetPersonalBossEnterTimeBylayer(layer)
	if next(self.personal_boss_enter_list) ~= nil then
		for k,v in pairs(self.personal_boss_enter_list) do
			if v.layer == layer then
				return v.times
			end
		end
	end
end

function BossData:GetPersonalBossMaxEnterTimeBylayer(layer)
	if self.personal_boss_scen_cfg and next(self.personal_boss_scen_cfg) ~= nil then
		for k,v in pairs(self.personal_boss_scen_cfg) do
			if v.layer == layer then
				return v.day_enter_times
			end
		end
	end
end


function BossData:SetDaBaoBossEnterInfo(num)
	self.dabao_boss_enter_num = num
end

function BossData:GetDaBaoEnterTimesCost()
	if nil ~= self.boss_family_cfg and nil ~= self.boss_family_cfg.dabao_cost then
		local dabao_cost = self.boss_family_cfg.dabao_cost
		for k,v in pairs(dabao_cost) do
			if v.times == self.dabao_boss_enter_num then
				return v.cost_gold
			end
		end
	end
end


-- function BossData:GetCanEnterPersonalBoss()
-- 	local _, num = self:GetPersonalBossEnterInfo()
-- 	if num then
-- 		local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
-- 		if self.person_buy_count > VipData.Instance:GetVipPowerList(vip_level)[VIPPOWER.PERSON_BOSS_TIMES] then
-- 			SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.AddChallengeMaxDes)
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end

function BossData:SetKillBossSucc(is_succ)
	self.is_succ = is_succ
end

function BossData:GetKillBossSucc()
	return self.is_succ
end

------------   上古遗迹   ------------

function BossData:GetSGHideMonsterByLayer(index)
	local layer_cfg = self.shanggu_boss_cfg.shanggu_boss_hide
	return layer_cfg[1]
end

function BossData:GetSgLayerCfg(layer)
	local layer_cfg = self.shanggu_boss_cfg.shanggu_boss_layer
	for k, v in pairs(layer_cfg) do
		if v.layer == layer then
			return v
		end
	end
end

function BossData:GetSgCanGoLayer()
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	local layer_cfg = self.shanggu_boss_cfg.shanggu_boss_layer
	local index = 0
	for k,v in pairs(layer_cfg) do
		if my_level >= v.need_role_level then
			index = index + 1
		end
	end
	return index
end

function BossData:GetSgNeedLevel(layer)
	local layer_cfg = self.shanggu_boss_cfg.shanggu_boss_layer
	for k,v in pairs(layer_cfg) do
		if v.layer == layer then
			return v.need_role_level
		end
	end
end

function BossData:GetSGMonsterByLayer(index)
	local vo = {}
	local shanggu_boss_info = self.shanggu_boss_cfg.shanggu_boss_info
	local other = self:GetOtherCfg()
	for i = 1, #shanggu_boss_info do
		if shanggu_boss_info[i].layer == index and shanggu_boss_info[i].type == 1 then
			vo = TableCopy(shanggu_boss_info[i])
			vo.boss_index = 0
			vo.drop_item_list = {}
			vo.boss_level = 1
			local boss_data = self:GetMonsterInfo(shanggu_boss_info[i].boss_id)
			vo.boss_level = boss_data.level
			vo.boss_name = other.monster_name
			vo.boss_hp = boss_data.hp
			vo.boss_atk = boss_data.gongji
			vo.boss_defen = boss_data.fangyu
			vo.damage_type = boss_data.damage_type
			vo.boss_magdef = boss_data.fa_fangyu
			self.sg_boss_list[vo.boss_id] = vo			
			return vo
		end
	end
end

function BossData:GetSGAllBoss()
	if next(self.sg_boss_all_list) == nil then 
		-- 宝箱
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local prof = PlayerData.Instance:GetRoleBaseProf(main_role_vo.prof)
		local other = self:GetOtherCfg()
		for i = 1, 2 do
			self.sg_boss_all_list[i] = {}
			local cfg = self:GetSgLayerCfg(i - 1)
			local vo = {}
			vo.layer = i - 1
			vo.boss_index = 0
			vo.boss_id = other.shanggu_max_box_id
			vo.x_pos = cfg.pos_x
			vo.y_pos = cfg.pos_y
			vo.drop_item_list = {}
			vo.boss_level = 1
			vo.boss_name = other.boxs_name
			vo.boss_hp = 0
			vo.boss_atk = 0
			vo.boss_defen = 0
			vo.damage_type = 0
			vo.boss_magdef = 0
			vo.scale = cfg.scale
			vo.scene_id = cfg.scene_id
			vo.max_delta_level = 999
			vo.type = BossData.MonsterType.Gather
			table.insert(self.sg_boss_all_list[i], vo)
			self.sg_boss_list[vo.boss_id] = vo
		end
		-- -- 黄金怪
		-- for i = 1, 2 do
		-- 	local vo = self:GetSGMonsterByLayer(i - 1)
		-- 	table.insert(self.sg_boss_all_list[i], vo)
		-- end
		-- 隐藏Boss
		for i = 1, 2 do
			local vo = TableCopy(self:GetSGHideMonsterByLayer(i))
			vo.boss_id = vo.monster_id
			-- local boss_data = self:GetMonsterInfo(vo.monster_id)
			local boss_data = self:GetMonsterInfo(3096)
			vo.layer = i - 1
			vo.drop_item_list = Split(vo["drop_item_list" .. prof], "|")		
			vo.boss_level = boss_data.level
			vo.boss_name = other.boss_name
			vo.boss_hp = boss_data.hp
			vo.boss_atk = boss_data.gongji
			vo.boss_defen = boss_data.fangyu
			vo.damage_type = boss_data.damage_type
			vo.boss_magdef = boss_data.fa_fangyu
			vo.x_pos = vo.pos_x0
			vo.y_pos = vo.pos_y0
			vo.max_delta_level = 999
			vo.type = BossData.MonsterType.HideBoss
			table.insert(self.sg_boss_all_list[i], vo)
			self.sg_boss_list[vo.boss_id] = vo
		end
		-- boss
		local shanggu_boss_info = self.shanggu_boss_cfg.shanggu_boss_info
		for i = 1, #shanggu_boss_info do
			if shanggu_boss_info[i].type == 0 then
				local vo = TableCopy(shanggu_boss_info[i])
				vo.drop_item_list = Split( shanggu_boss_info[i]["drop_item_list" .. prof], "|")
				local boss_data = self:GetMonsterInfo(shanggu_boss_info[i].boss_id)
				vo.boss_level = boss_data.level
				vo.boss_name = boss_data.name
				vo.boss_hp = boss_data.hp
				vo.boss_atk = boss_data.gongji
				vo.boss_defen = boss_data.fangyu
				vo.damage_type = boss_data.damage_type
				vo.boss_magdef = boss_data.fa_fangyu
				table.insert(self.sg_boss_all_list[vo.layer + 1], vo)
				self.sg_boss_list[vo.boss_id] = vo
			end
		end
	end
	return self.sg_boss_all_list
end

function BossData:GetSGBossJingYingInfoByLayer(index)
	local vo = {}
	local list = {}
	local shanggu_boss_info = self.shanggu_boss_cfg.shanggu_boss_info
	local other = self:GetOtherCfg()
	local temp_index = 1
	for i = 1, #shanggu_boss_info do
		if shanggu_boss_info[i].layer == index and shanggu_boss_info[i].type == 1 then
			vo = TableCopy(shanggu_boss_info[i])
			vo.boss_index = 0
			vo.drop_item_list = {}
			vo.boss_level = 1
			local boss_data = self:GetMonsterInfo(shanggu_boss_info[i].boss_id)
			vo.boss_level = boss_data.level
			vo.boss_name = other.monster_name
			vo.x_pos = shanggu_boss_info[i].x_pos
			vo.y_pos = shanggu_boss_info[i].y_pos
			vo.kill_add_angry = shanggu_boss_info[i].kill_add_angry
			list.boss_id = shanggu_boss_info[i].boss_id
			vo.boss_hp = boss_data.hp
			vo.boss_atk = boss_data.gongji
			vo.boss_defen = boss_data.fangyu
			vo.damage_type = boss_data.damage_type
			vo.boss_magdef = boss_data.fa_fangyu
			list[temp_index] = vo
			temp_index = temp_index + 1
		end
	end
	return list
end

function BossData:GetCurShanggulayerBysceneid(scene_id)
	local layer_cfg = self.shanggu_boss_cfg.shanggu_boss_layer
	for k,v in pairs(layer_cfg) do
		if v.scene_id == scene_id then
			return v.layer
		end
	end
end

function BossData:GetSGBossJingYingInfoByID(index, boss_id)
	local list = self:GetSGBossJingYingInfoByLayer(index)
	for k,v in pairs(list) do
		if v.boss_id == boss_id then
			return v
		end
	end
end

function BossData:GetSGAllBossByLayer(layer)
	local sg_boss_list = self:GetSGAllBoss()
	return sg_boss_list[layer]
end

function BossData:GetSGAllBossByBossId(boss_id)
	if next(self.sg_boss_list) == nil then
		self:GetSGAllBoss()
	end
	return self.sg_boss_list[boss_id]
end

function BossData:GetOtherCfg()
	local other_cfg = self.shanggu_boss_cfg.other
	return other_cfg[1]
end

-- 服务端数据
function BossData:SetSgBossAllInfo(protocol)
	self.sg_tire_value = protocol.tire_value
	self.sg_enter_times = protocol.enter_times
	local all_boss_list = protocol.layer_list
	local layer_count = all_boss_list.layer_count
	for i = 1, layer_count do
		for k,v in pairs(all_boss_list[i].boss_info_list) do
			self.all_boss_info[v.boss_id] = v
		end
	end
end

function BossData:SetSgBossLayer(boss_list)
	for k,v in pairs(boss_list) do
		self.all_boss_info[v.boss_id] = v
	end
end

function BossData:GetSgBossTire()
	local shanggu_cfg = self:GetOtherCfg()
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	local vip_time = VipData.Instance:GetVipPowerList(vip_level)[VIPPOWER.SG_TIRE_TIMES]
	return self.sg_tire_value, shanggu_cfg.shanggu_day_max_tire + vip_time
end

function BossData:GetSgBossEnterTimes()
	local shanggu_cfg = self:GetOtherCfg()
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	local vip_time = VipData.Instance:GetVipPowerList(vip_level)[VIPPOWER.SG_ENTER_TIMES]
	return self.sg_enter_times, shanggu_cfg.shanggu_day_free_times + vip_time
end

function BossData:GetSGBossEnterComsun()
	local enter_cfg = self.shanggu_boss_cfg.shanggu_boss_tiky_consume
	local enter_times, _ = self:GetSgBossEnterTimes()
	for k, v in pairs(enter_cfg) do
		if enter_times + 1 == v.enter_times then
			return v.need_consume_item_num
		end
	end
end

function BossData:GetSGBossTikyId()
	local other = self:GetOtherCfg()
	return other.shanggu_tiky_item_id
end

function BossData:SetShangGuBossSceneOtherInfo(protocol)
	self.sg_other_scene_info = protocol.layer_info_list
end

function BossData:GetShangGuBossSceneOtherInfo(layer, type)
	if self.sg_other_scene_info == nil then
		return
	end
	local sg_other_cfg = self.sg_other_scene_info[layer]
	if BossData.MonsterType.Boss == type then
		return 1
	elseif BossData.MonsterType.Monster == type then
		return sg_other_cfg.gold_monster_num
	elseif BossData.MonsterType.Gather == type then
		return sg_other_cfg.max_boss_num + sg_other_cfg.min_boss_num
	elseif BossData.MonsterType.HideBoss == type then
		return sg_other_cfg.hide_boss_num 
	end	
end

function BossData:GetSGBossFlushTimeStr()
	local time_cfg = self.shanggu_boss_cfg.shanggu_boss_flush
	local time_t = {}
	for k, v in ipairs(time_cfg) do
		local time = v.time / 100
		table.insert(time_t, time)
	end
	return time_t
end

function BossData:GetSGBossAngryById(boss_id)
	if next(self.sg_angry_list) == nil then
		local shanggu_boss_info = self.shanggu_boss_cfg.shanggu_boss_info
		for i, v in ipairs(shanggu_boss_info) do
			self.sg_angry_list[v.boss_id] = v
		end
		local hide_boss_info = self.shanggu_boss_cfg.shanggu_boss_hide
		for i, v in ipairs(hide_boss_info) do
			self.sg_angry_list[v.monster_id] = v
		end
	end
	return self.sg_angry_list[boss_id]
end

function BossData:GetDabaoBossMaxAngry(boss_id)
	local boss = self:GetSGBossAngryById(boss_id)
	if boss == nil then return 0 end
	return boss.kill_add_angry
end

function BossData:SetDabaoBossAngryValue(protocol)
	self.angry_value = protocol.angry_value
	self.kick_out_time = protocol.kick_out_time
end

function BossData:GetDabaoBossAngryValue()
	return self.angry_value, self.kick_out_time
end

function BossData:GetSGBossListBySceneId(scene_id)
	if next(self.sg_boss_list) == nil then
		self:GetSGAllBoss()
	end
	local t_list = {}
	for k, v in pairs(self.sg_boss_list) do
		if v.scene_id == scene_id and v.type == BossData.MonsterType.Boss then
			local data = BossData.Instance:GetBossRefreshInfoByBossId(v.boss_id)
			if data ~= nil then
				v.next_refresh_time = data.next_refresh_time
				table.insert(t_list, v)
			end
		end
	end
	
	table.sort(t_list, function (a, b)
		if a.next_refresh_time < b.next_refresh_time then
			return true
		elseif a.next_refresh_time == b.next_refresh_time then
			return a.boss_level < b.boss_level
		else
			return false
		end
	end)

	return t_list
end

function BossData:SetSeclectlayer(layer)
	self.layer = layer
end

function BossData:GetSeclectlayer()
	return self.layer
end

function BossData:GetShangGuBossList(scene_id)
	local boss_info_list = self:GetSGBossListBySceneId(scene_id)
	if boss_info_list then
		local hide_boss_id = self:GetSGHideMonsterByLayer(1).monster_id
		local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
		if hide_boss_id and monster_cfg then
			local data = {}
			local name = monster_cfg[hide_boss_id].name
			local num = self:GetShangGuBossSceneOtherInfo(self.layer, BossData.MonsterType.HideBoss)
			local level = monster_cfg[hide_boss_id].level
			data.boss_name = name or ""
			data.num = num or 0
			data.boss_level = level or 0
			data.next_refresh_time = -1
			data.kill_add_angry = -1
			boss_info_list[0] = data
		end
	end
	return boss_info_list
end

function BossData:GetEliteListBySceneType(scene_type)
	local elite_list = {}
	local list_flag = {}
	local cfg
	if scene_type == SceneType.SG_BOSS then
		cfg = self.shanggu_boss_cfg.shanggu_boss_info
	end
	local cur_bossLayer = 0
	if Scene.Instance:GetSceneId() == 2201 then
		cur_bossLayer = 1
	end
	if cfg then
		for k,v in pairs(cfg) do
			if scene_type == SceneType.SG_BOSS then
				if v.layer == cur_bossLayer and v.type == 1 and list_flag[v.boss_id] == nil then
					list_flag[v.boss_id] = 1
					table.insert(elite_list, v)
				end
			end
		end
	end
	return elite_list
end

------------   精英怪   ------------
-- 获取精英怪列表
function BossData:GetEliteBossList()
	return self.eliteboss_list
end

-- 获取精英怪信息
function BossData:GetEliteBossInfo()
	local boss_info = {}
	if #self.eliteboss_list < 2 then return end

	for i = 1, 2 do
		local boss_id = self.eliteboss_list[i].boss_id
		if nil == self.all_boss_info[boss_id] then return end

		local info = {}
		info.status = self.all_boss_info[boss_id].status
		info.next_refresh_time = self.all_boss_info[boss_id].next_refresh_time - TimeCtrl.Instance:GetServerTime()
		boss_info[i] = info
	end
	return boss_info
end

-- BOSS图鉴
function BossData:SetAllBossInfo(protocol)
	self.tab = {}
	self.card_reward_flag = {}
	self.card_reward_flag = bit:ll2bn(protocol.card_group_reward_fetch_flag)
	local data_index = 0
	for i = 0, 63 do
		local card_can_active_flag = bit:d2b(protocol.card_can_active_flag[i])
		local card_has_active_flag = bit:d2b(protocol.card_has_active_flag[i])
		for k = 1, 8 do
			self.tab[data_index] = {
				can_active = card_can_active_flag[24 + k],
				has_active = card_has_active_flag[24 + k],
			}
			data_index = data_index + 1
		end
	end
end

function BossData:SetBossAllInfo(scene_type,map_type, index)
	if scene_type == nil or map_type == nil then
		return {}
	end
	local list = self:FormatMenu(index)
	local cfg = list[scene_type]
	if cfg and cfg.child then
		for i, v in ipairs(cfg.child) do
			if v.map_id == map_type then
				return v.bossid_id
			end
		end
	end
end

function BossData:GetNotShenYuBossNum()
	local num = 0
	if self.bosscardcfg and self.bosscardcfg.bosstype_cfg then
		for k,v in pairs(self.bosscardcfg.bosstype_cfg) do
			if v.distinguish == 0 then
				if self.is_shenyu_boss ~= v.scene_type then
					num = num + 1
				end
				self.is_shenyu_boss = v.scene_type
			end
		end
	end
	return num
end

function BossData:SetAllBossActiveFlagInfo(monster_seq)
	if monster_seq ~= nil and self.tab ~= nil then
		return self.tab[monster_seq]
	else
		return  {
				can_active = 0,
				has_active = 0,
			}
	end
end

function BossData:FormatMenu(index)
	local list = self:FormatMenuCfg(index)
	local cfg = TableCopy(list)
	local flag_info = nil
	local active_num = 0
	for i = 1 , #cfg do
		cfg[i].can_activef = 0
		for k,v in ipairs(cfg[i].child) do
			v.can_active = 0
			active_num = 0
			for _, boss_data in ipairs(v.bossid_id)do
				flag_info = self:SetAllBossActiveFlagInfo(boss_data.list.monster_seq)
				boss_data.can_active  = flag_info.can_active
				boss_data.has_active = flag_info.has_active
				if boss_data.has_active == 1 then
					active_num = active_num + 1
				end
				if boss_data.can_active == 1 and boss_data.has_active == 0  then
					v.can_active = 1
					cfg[i].can_activef = 1
				end
			end
			v.progress = math.ceil((active_num / #v.bossid_id)*100)
		end
	end
	return cfg 
end

-- 格式化菜单数据
function BossData:FormatMenuCfg(index)
	if index == 1 and self.shenyu_menu_list and next(self.shenyu_menu_list) ~= nil then			-- 神域Boss
		return self.shenyu_menu_list
	end
	if index == 0 and self.menu_list and next(self.menu_list) ~= nil then
		return self.menu_list
	end
	local reward_cfg = ListToMap(self.bosscardcfg.bosscard_reward_cfg, "card_type")
	local bosscard_cfg = {}
	for k,v in ipairs(self.bosscardcfg.bosscard_cfg)do
		bosscard_cfg[v.monster_id] = v
	end
	local boss_cfg  =  self.bosscardcfg.bosscard_cfg
	self.bosstujian_len = boss_cfg[#boss_cfg].monster_seq
	self.menu_list = {}
	self.shenyu_menu_list = {}

	for i = 1, #self.bosscardcfg.bosstype_cfg do
		local item = self.bosscardcfg.bosstype_cfg[i]
		local menu = self.menu_list[item.scene_type]
		local shenyhu_menu = self.shenyu_menu_list[item.scene_type]
		local boss_id_list = Split(item.boss_id, "|")
		local scene_id_list = Split(item.scene_id, "|")
		if nil == menu then
			if item.distinguish == 0 then
				self.menu_list[item.scene_type] = {}
				self.menu_list[item.scene_type].scene_type = item.scene_type
				self.menu_list[item.scene_type].map_type = item.map_type
				self.menu_list[item.scene_type].child = {}
			end
		end
		if nil == shenyhu_menu then
			if item.distinguish == 1 then
				self.shenyu_menu_list[item.scene_type] = {}
				self.shenyu_menu_list[item.scene_type].scene_type = item.scene_type
				self.shenyu_menu_list[item.scene_type].map_type = item.map_type
				self.shenyu_menu_list[item.scene_type].child = {}
			end
		end
		
		local boss_list = {}
		for k,v in ipairs(boss_id_list)do
			if bosscard_cfg[tonumber(v)] ~= nil then
				local data = {}
				data.list = bosscard_cfg[tonumber(v)]
				data.map  = item.map_name
				data.open_level = item.open_level
				data.map_type  = item.map_type
				data.scene_type  = item.scene_type

				if #scene_id_list == 1 then
					data.scene_id = item.scene_id
				elseif #scene_id_list >1 then
					data.scene_id = scene_id_list[k]
				end
				table.insert(boss_list, data)
			end
		end

		if item.distinguish == 0 then
			if reward_cfg[item.card_type] then
				local temp_table = {bossid_id = boss_list, name=item.map_name,
				map_id = item.map_type,map_icon = item.icon_id,open_level = item.open_level, layer_level = item.layer_level, card_type = item.card_type,
				box_color = reward_cfg[item.card_type].rewardbox_color}
				table.insert(self.menu_list[item.scene_type].child, temp_table)
			end
		elseif item.distinguish == 1 then
			if reward_cfg[item.card_type] then
				local temp_table = {bossid_id = boss_list, name=item.map_name,
				map_id = item.map_type,map_icon = item.icon_id,open_level = item.open_level, layer_level = item.layer_level, card_type = item.card_type,
				box_color = reward_cfg[item.card_type].rewardbox_color}
				table.insert(self.shenyu_menu_list[item.scene_type].child, temp_table)
			end
		end
	end

	local temp_list = {}
	for k,v in pairs(self.shenyu_menu_list) do
		table.insert(temp_list, v)
	end
	self.shenyu_menu_list = temp_list
	return self.menu_list
end

function BossData:GetSceneTypeByBossID(boss_id)
	if nil == self.bosscardcfg and nil == self.bosscardcfg.bosstype_cfg then
		return
	end

	local boss_type_cfg =  self.bosscardcfg.bosstype_cfg
	for k,v in pairs(boss_type_cfg) do
		local list = {}
		list = Split(v.boss_id, "|")
		for i,j in pairs(list) do
			if tonumber(j) == boss_id then
				return v.scene_type
			end
		end
	end
end

------------   跨服BOSS   ------------
function BossData:SetCrossBossPalyerInfo(protocol)
	self.left_ordinary_crystal_gather_times = protocol.left_ordinary_crystal_gather_times
	self.left_can_kill_boss_num = protocol.left_can_kill_boss_num
	self.left_treasure_crystal_gather_times = protocol. left_treasure_crystal_gather_times
	self.concern_flag = {}
	for i = 1, 5 do
		local flag = bit:d2b(protocol.concern_flag[i])
		self.concern_flag[i] = flag
	end
end

function BossData:GetCrossBossIsConcern(layer, boss_index)
	if nil == self.concern_flag then
		return
	end
	local flag_list = self.concern_flag[layer]
	if flag_list[33 - boss_index] == 1 then
		return true
	else
		return false
	end
end

function BossData:GetLeftTreasureGatherTimes()
	return self.left_treasure_crystal_gather_times
end

function BossData:SetCrossBossSceneInfo(protocol)
	self.leftmonsterandtreasure[protocol.layer] = {
	left_treasure_crystal_num = protocol.left_treasure_crystal_num,
	left_monster_count = protocol.left_monster_count,
	monster_next_flush_timestamp = protocol.monster_next_flush_timestamp,
	treasure_crystal_next_flush_timestamp = protocol.treasure_crystal_next_flush_timestamp
	}

	local treasure_crystal_gather_id = protocol.treasure_crystal_gather_id
	local monster_next_flush_timestamp = protocol.monster_next_flush_timestamp
	local treasure_crystal_next_flush_timestamp = protocol.treasure_crystal_next_flush_timestamp
	for k, v in pairs(protocol.boss_list) do
		local vo = {}
		vo.boss_id = v.boss_id
		vo.is_exist = v.is_exist
		vo.next_refresh_time = v.next_flush_time
		vo.left_num = 0
		self.cross_boss_info[v.boss_id] = vo
		if self.cross_boss_all_list and self.cross_boss_all_list[protocol.layer] then
			for i,j in pairs(self.cross_boss_all_list[protocol.layer]) do
				if j.boss_id == v.boss_id then
					j.next_refresh_time = v.next_flush_time
				end
			end
		end
	end

	local treasure_crystal_vo = {}
	treasure_crystal_vo.boss_id = treasure_crystal_gather_id
	treasure_crystal_vo.exist = treasure_crystal_next_flush_timestamp > 0 and 1 or 0
	treasure_crystal_vo.next_refresh_time = treasure_crystal_next_flush_timestamp
	treasure_crystal_vo.left_num = protocol.left_treasure_crystal_num
	self.cross_boss_info[treasure_crystal_gather_id] = treasure_crystal_vo

	local monster_info = self:GetOneMonsterByLayer(protocol.layer)
	if monster_info then
		local monster_vo = {}
		monster_vo.boss_id = monster_info.boss_id
		monster_vo.exist = monster_next_flush_timestamp > 0 and 1 or 0
		monster_vo.next_refresh_time = monster_next_flush_timestamp
		monster_vo.left_num = protocol.left_monster_count
		self.cross_boss_info[monster_info.boss_id] = monster_vo
	end
end

function BossData:SetCrossBossBossInfo(protocol)
	for i,j in ipairs(protocol.scene_list) do
		self.cross_client_flush_info[j.layer + 1] = {}
		self.cross_client_flush_info[j.layer + 1].left_treasure_crystal_count = j.left_treasure_crystal_count
		self.cross_client_flush_info[j.layer + 1].left_monster_count = j.left_monster_count
		self.cross_client_flush_info[j.layer + 1].boss_list = {}
		for k,v in ipairs(j.boss_list) do
			if v.boss_id ~= 0 then
				local vo = {}
				vo.boss_id = v.boss_id
				vo.next_refresh_time = v.next_refresh_time
				self.cross_client_flush_info[j.layer + 1].boss_list[v.boss_id] = vo
			end
		end
	end
end

function BossData:GetOneMonsterByLayer(index)
	local vo = {}
	local other = self.cross_other_cfg
	for i = 1, #self.crossmonster_list do
		if self.crossmonster_list[i].layer == index then
			vo.layer = self.crossmonster_list[i].layer
			vo.boss_index = 0
			vo.boss_id = self.crossmonster_list[i].monster_id
			vo.x_pos = self.crossmonster_list[i].pos_x
			vo.y_pos = self.crossmonster_list[i].pos_y
			vo.drop_item_list = {}
			vo.boss_level = 1
			vo.boss_name = other.monster_name
			vo.boss_hp = 0
			vo.boss_atk = 0
			vo.boss_defen = 0
			vo.damage_type = 0
			vo.boss_magdef = 0
			vo.type = BossData.MonsterType.Monster
			vo.max_delta_level = 1000
			vo.scene_id = 0
			vo.scale = 1
			return vo
		end
	end
end
function BossData:GetCrossAllBoss()
	if next(self.cross_boss_all_list) == nil then 
		for i = 1, #self.crossboss_list do
			self.cross_boss_all_list[i] = {}
		end
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local prof = PlayerData.Instance:GetRoleBaseProf(main_role_vo.prof)
		-- 水晶
		-- for i = 1, #self.crosscrytal_lsit do 
		-- 	local vo = {}
		-- 	vo.layer = self.crosscrytal_lsit[i].layer_index
		-- 	vo.boss_index = 0
		-- 	vo.boss_id = self.crosscrytal_lsit[i].treasure_crystal_gather_id
		-- 	vo.x_pos = self.crosscrytal_lsit[i].entry_x
		-- 	vo.y_pos = self.crosscrytal_lsit[i].entry_y
		-- 	vo.drop_item_list = {}
		-- 	vo.boss_level = 1
		-- 	vo.boss_name = self.crosscrytal_lsit[i].treasure_crystal_name
		-- 	vo.boss_hp = 0
		-- 	vo.boss_atk = 0
		-- 	vo.boss_defen = 0
		-- 	vo.damage_type = 0
		-- 	vo.boss_magdef = 0
		-- 	vo.type = BossData.MonsterType.Gather
		-- 	vo.max_delta_level = 1000
		-- 	vo.scale = 1
		-- 	vo.scene_id = self.crosscrytal_lsit[i].scene_id
		-- 	table.insert(self.cross_boss_all_list[vo.layer], vo)
		-- end
		-- 精英怪   --策划需求 删掉精英怪物显示
		-- for i = 1, 2 do
		-- 	local vo = self:GetOneMonsterByLayer(i)
		-- 	table.insert(self.cross_boss_all_list[i], vo)
		-- end
		-- boss
		local boss_data = {}
		for i = 1, #self.crossboss_list do
			local vo = {}
			vo.layer = self.crossboss_list[i].layer
			vo.boss_index = self.crossboss_list[i].boss_index
			vo.boss_id = self.crossboss_list[i].boss_id
			vo.x_pos = self.crossboss_list[i].flush_pos_x
			vo.y_pos = self.crossboss_list[i].flush_pos_y
			vo.drop_item_list = Split(self.crossboss_list[i]["drop_item_list" .. prof], "|")
			boss_data = self:GetMonsterInfo(self.crossboss_list[i].boss_id)			
			vo.boss_level = boss_data.level
			vo.boss_name = boss_data.name
			vo.boss_hp = boss_data.hp
			vo.boss_atk = boss_data.gongji
			vo.boss_defen = boss_data.fangyu
			vo.damage_type = boss_data.damage_type
			vo.boss_magdef = boss_data.fa_fangyu
			vo.max_delta_level = self.crossboss_list[i].max_delta_level
			vo.scene_id = self.crossboss_list[i].scene_id
			vo.type = BossData.MonsterType.Boss
			vo.scale = self.crossboss_list[i].scale
			vo.scene_show = self.crossboss_list[i].scene_show
			if self.cross_client_flush_info[vo.layer] ~= nil and self.cross_client_flush_info[vo.layer].boss_list[vo.boss_id] ~= nil then
				vo.next_refresh_time = self.cross_client_flush_info[vo.layer].boss_list[vo.boss_id].next_refresh_time
			end
			self.cross_boss_list[vo.boss_id] = vo
			if self.cross_boss_all_list[vo.layer] then
				table.insert(self.cross_boss_all_list[vo.layer], vo)
			end
		end
	end
	return self.cross_boss_all_list
end

function BossData:GetCrossLayerBossBylayer(index)
	local all_list = self:GetCrossAllBoss()
	if all_list[index] then
		function sortfun(a, b)
			if a.next_refresh_time == nil and self.cross_client_flush_info[a.layer] ~= nil and self.cross_client_flush_info[a.layer].boss_list[a.boss_id] ~= nil then
				a.next_refresh_time = self.cross_client_flush_info[a.layer].boss_list[a.boss_id].next_refresh_time
			end
			if b.next_refresh_time == nil and self.cross_client_flush_info[b.layer] ~= nil and self.cross_client_flush_info[b.layer].boss_list[b.boss_id] ~= nil then
				b.next_refresh_time = self.cross_client_flush_info[b.layer].boss_list[b.boss_id].next_refresh_time
			end
			if a.next_refresh_time and b.next_refresh_time then
				local state_a = a.next_refresh_time > 0 and 1 or 0
				local state_b = b.next_refresh_time > 0 and 1 or 0
				if state_a and state_b and state_a ~= state_b then
					return state_a < state_b
				else
					local level_a = a.boss_level or 0
					local level_b = b.boss_level or 0
					return level_a < level_b
				end
			else
				local level_a = a.boss_level or 0
				local level_b = b.boss_level or 0
				return level_a < level_b
			end
		end
		table.sort(all_list[index], sortfun)
	end
	return all_list[index] or {}
end

function BossData:GetCrossLayerBossBySceneID(scene_id)
	local layer = nil
	for k,v in pairs(self.crosscrytal_lsit) do
		if v.scene_id == scene_id then
			layer = v.layer_index
		end
	end
	local list = self:GetCrossLayerBossBylayer(layer)
	return list
end

function BossData:GetCrossSceneIDByLayer(layer)
	local cfg = self:GetCrossCfgByLayer(layer)
	if cfg then
		return cfg.scene_id
	end
end

function BossData:GetCrossCfgByLayer(layer)
	for k,v in pairs(self.crosscrytal_lsit) do
		if v.layer_index == layer then
			return v
		end
	end
end

function BossData:GetCrossLayerBySceneID(scene_id)
	for k,v in pairs(self.crosscrytal_lsit) do
		if v.scene_id == scene_id then
			return v.layer_index
		end
	end
end

function BossData:GetMiZangCrossLayerBySceneID(scene_id)
	for k,v in pairs(self.crosscrytal_mizang_lsit) do
		if v.scene_id == scene_id then
			return v.layer_index
		end
	end
end

function BossData:GetCrossBossInfoByBossId(boss_id)
	if next(self.cross_boss_list) == nil then
		self:GetCrossAllBoss()
	end
	return self.cross_boss_list[boss_id]
end

function BossData:GetCrossBossCanGoLevel()
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	local index = 0
	for k,v in pairs(self.crosscrytal_lsit) do
		if my_level >= v.level_limit then
			index = index + 1
		end
	end
	return index
end

function BossData:GetCrossBossTire()
	local max_tire_value = self.cross_other_cfg.daily_boss_num
	return self.left_can_kill_boss_num, max_tire_value
end

function BossData:GetCrossBossById(boss_id)
	return self.cross_boss_info[boss_id]
end

function BossData:GetCrossBossCfgOther()
	return self.cross_other_cfg
end

function BossData:GetCrossYuanGuBossCfgOther()
	return self.cross_mizang_cfg.other[1]
end

function BossData:GetCrossLeftNum(layer, data_type)
	if nil == self.cross_client_flush_info[layer] then
		return
	end
	if data_type == 1 then
		return self.cross_client_flush_info[layer].left_monster_count
	elseif data_type == 2 then
		return self.cross_client_flush_info[layer].left_treasure_crystal_count
	end
end

function BossData:GetCrossLeftNumInScene(layer, data_type)
	if nil == self.leftmonsterandtreasure[layer] then
		return
	end
	if data_type == 1 then
		return self.leftmonsterandtreasure[layer].left_monster_count
	elseif data_type == 2 then
		return self.leftmonsterandtreasure[layer].left_treasure_crystal_num
	end
end

function BossData:GetCrossOtherNextFlushTimestamp(layer, data_type)
	if nil == self.leftmonsterandtreasure[layer] then
		return
	end
	if data_type == 1 then
		return self.leftmonsterandtreasure[layer].monster_next_flush_timestamp
	elseif data_type == 2 then
		return self.leftmonsterandtreasure[layer].treasure_crystal_next_flush_timestamp
	end
end

function BossData:SetCrossBossWeary(protocol)
	self.crossboss_weary = protocol.relive_tire_value
	self.crossboss_can_relive_time = protocol.tire_can_relive_time
end

function BossData:GetCrossBossCanReliveTime()
	return self.crossboss_can_relive_time
end

function BossData:GetCrossBossWeary()
	return self.crossboss_weary
end

function BossData:GetKFBossFallList(boss_id)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo then
		local prof = PlayerData.Instance:GetRoleBaseProf(main_role_vo.prof) or 0
		if self.crossboss_list then
			for k,v in pairs(self.crossboss_list) do
				if v and v.boss_id == boss_id then
					local list = {}
					list = Split(v["drop_item_list" .. prof], "|")
					return list
				end
			end
		end
	end
end

-------------- 仙宠奇遇boss --------------
function BossData:SetEncounterBossData(protocol, ok_callback)
	self.encounter_boss_info.boss_id = protocol.boss_id or 0
	self.encounter_boss_info.role_name = protocol.role_name
	self.encounter_boss_info.scene_id = protocol.scene_id
	self.encounter_boss_info.boss_type = BOSS_ENTER_TYPE.TYPE_BOSS_ENCOUNTER
	self.encounter_boss_info.close_count_down = 12         -- 倒数时间写死为12秒
	self.encounter_boss_info.ok_callback = ok_callback
end

function BossData:GetEncounterBossData()
	return self.encounter_boss_info
end

function BossData:SetEncounterBossEnterTimes(time)
	self.encounter_boss_enter_times = time or 0
end

function BossData:GetEncounterBossEnterTimes()
	local encounter_boss_cfg = ConfigManager.Instance:GetAutoConfig("jingling_advantage_cfg_auto")
	local enter_times = encounter_boss_cfg and encounter_boss_cfg.other[1].boss_max_drop_times or 0
	if self.encounter_boss_enter_times then
		return enter_times - self.encounter_boss_enter_times
	end
	return 0
end
-------------- 仙宠奇遇boss --------------


function BossData:GetBossMiniMapCfg(boss_type, boss_ceng)
	if self.mini_map_cfg and self.mini_map_cfg[boss_type] then
		return self.mini_map_cfg[boss_type][boss_ceng]
	end
end

function BossData:GetBossTypeCengshu(boss_type)
	if self.mini_map_cfg and self.mini_map_cfg[boss_type] then
		return #self.mini_map_cfg[boss_type]
	end
end

--活跃BOSS伤害排行
function BossData:SetActiveBossPersonalHurtInfo(protocol)
	self.active_boss_hurt_info = {}
	for k,v in pairs(protocol) do
		self.active_boss_hurt_info[k] = v
	end
end

--困难BOSS伤害排行
function BossData:SetMikuBossPersonalHurtInfo(protocol)
	self.miku_boss_hurt_info = {}
	for k,v in pairs(protocol) do
		self.miku_boss_hurt_info[k] = v
	end
end

function BossData:GetActiveBossPersonalHurtInfo()
	return self.active_boss_hurt_info
end

function BossData:GetMikuBossPersonalHurtInfo()
	return self.miku_boss_hurt_info
end

function BossData:GetActiveBossHurtRewardList(boss_id)
	local list = {}
	local cfg_list = self.active_boss_reward_list[boss_id] or {}
	for k,v in pairs(cfg_list) do
		table.insert(list, v)
	end
	return list
end

function BossData:SetActiveBossRankMonsterID(monster_id)
	self.active_boss_rand_monster_id = monster_id
end

function BossData:GetActiveBossRankMonsterID()
	return self.active_boss_rand_monster_id
end
function BossData:TipKFBossFulsh(protocol)
	local ok_call_back = function()
			ViewManager.Instance:Open(ViewName.Boss, TabIndex.kf_boss)
	end
end

function BossData:SetBabyBossSelectInfo(select_scene_id, select_boss_id)
	self.select_scene_id = select_scene_id
	self.select_boss_id = select_boss_id
end

function BossData:GetBabyBossSelectInfo()
	return self.select_scene_id, self.select_boss_id
end

function BossData:CheckIsShowBossFlushTipBySceneType(scene_type)
	local fb_config = ConfigManager.Instance:GetAutoConfig("fb_scene_config_auto")
	if fb_config then
		local list = fb_config.fb_scene_cfg_list
		if list then
			for i,v in ipairs(list) do
				if v.scene_type == scene_type then
					return v.pb_tanchuang == 0
				end
			end
		end
	end
	return true
end

function BossData:UseFlushCard(scene_id)
	local data = ItemData.Instance:GetItem(FLUSH_ITEM_ID)
	local item_cfg = ItemData.Instance:GetItemConfig(FLUSH_ITEM_ID)
	local des = ""
	local name = ""
	if data and item_cfg then
		name = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">" ..item_cfg.name.."</color>"
	end
	if BossData.Instance:IsActiveBossScene(scene_id) or BossData.Instance:IsMikuBossScene(scene_id) then
		local boss_list = BossData.Instance:GetActiveBossList(scene_id)
		local other_cfg = BossData.Instance:GetBossOtherCfg()
		if BossData.Instance:IsMikuBossScene(scene_id) then
			boss_list = BossData.Instance:GetMikuBossList(scene_id)
		end
		local self_x, self_y = Scene.Instance:GetMainRole():GetLogicPos()
		local target_distance = nil
		local target_obj = nil
		for k, v in pairs(boss_list) do
			local distance = GameMath.GetDistance(self_x, self_y, v.born_x, v.born_y, false)
			if target_distance == nil then
				target_distance = distance
				target_obj = v
			else
				if distance < target_distance then
					target_distance = distance
					target_obj = v
				end
			end
		end
		if target_obj then
			local monster_cfg = BossData.Instance:GetMonsterInfo(target_obj.bossID)
			if monster_cfg then
				des = string.format(Language.Boss.FlushBossCard, name, monster_cfg.name)
			end

			local flush_time = BossData.Instance:GetActiveStatusByBossId(target_obj.bossID, scene_id)
			if BossData.Instance:IsMikuBossScene(scene_id) then
				flush_time = BossData.Instance:GetBossMikuStatusByBossId(target_obj.bossID, scene_id)
			end

			if other_cfg then
				if GameMath.GetDistance(target_obj.born_x, target_obj.born_y, self_x, self_y, false) <= other_cfg.boss_flush_distance and flush_time > 0 then
					local func = function()
						PackageCtrl.Instance:SendUseItem(data.index, 1, target_obj.bossID)
					end
					TipsCtrl.Instance:ShowCommonAutoView("", des, func)
				else
					SysMsgCtrl.Instance:ErrorRemind(Language.Boss.FlushBossError)
				end
			end
		end
	elseif BossData.Instance:IsShenYuBossScene(scene_id) or BossData.Instance:IsCrossBossScene(scene_id) then
		local boss_list = BossData.Instance:GetCrossLayerBossBySceneID(scene_id)
		local other_cfg = BossData.Instance:GetCrossBossCfgOther()
		if BossData.Instance:IsShenYuBossScene(scene_id) then
			boss_list = ShenYuBossData.Instance:GetCrossLayerBossBySceneID(scene_id)
			other_cfg = BossData.Instance:GetCrossYuanGuBossCfgOther()
		end
		local self_x, self_y = Scene.Instance:GetMainRole():GetLogicPos()
		local target_distance = nil
		local target_obj = nil
		
		for k, v in pairs(boss_list) do
			local distance = GameMath.GetDistance(self_x, self_y, v.x_pos, v.y_pos, false)
			if target_distance == nil then
				target_distance = distance
				target_obj = v
			else
				if distance < target_distance then
					target_distance = distance
					target_obj = v
				end
			end
		end
		if target_obj then
			local monster_cfg = BossData.Instance:GetMonsterInfo(target_obj.boss_id)
			if monster_cfg then
				des = string.format(Language.Boss.FlushBossCard, name, monster_cfg.name)
			end

			-- local _, status = BossData.Instance:GetActiveBossRefreshTime(target_obj.boss_id, scene_id)
			-- if BossData.Instance:IsMikuBossScene(scene_id) then
			-- 	_, status = BossData.Instance:GetMikuBossRefreshTime(target_obj.boss_id, scene_id)
			-- end
			local flush_time = BossData.Instance:GetCrossBossFlushTimesByBossId(target_obj.boss_id, scene_id)
			if BossData.Instance:IsShenYuBossScene(scene_id) then
				flush_time = ShenYuBossData.Instance:GetCrossBossFlushTimesByBossId(target_obj.boss_id, scene_id)
			end
			if other_cfg then
				if GameMath.GetDistance(target_obj.x_pos, target_obj.y_pos, self_x, self_y, false) <= other_cfg.boss_flush_distance and flush_time > 0 then
					local func = function()
						PackageCtrl.Instance:SendUseItem(data.index, 1, target_obj.boss_id)
					end
					TipsCtrl.Instance:ShowCommonAutoView("", des, func)
				else
					SysMsgCtrl.Instance:ErrorRemind(Language.Boss.FlushBossError)
				end
			end
		end

	end
end