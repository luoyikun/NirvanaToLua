local develop_mode = require("editor/develop_mode")

ActivityData = ActivityData or BaseClass()

ActivityData.Act_Type = {
	normal = 1,
	boss = 2,
	boss_remindind = 3,
	battle_field = 4,
	kuafu_battle_field = 5,
	shushan = 6,
	custom_preview = 7,
}

ActivityData.Boss_State = {
	not_start = 0,
	ready = 1,
	death = 2,
	time_over = 3,
}

ActivityData.BossType = {
	WORLD_BOSS = 0,
	BOSS_HOME = 1,
	ELITE_BOSS = 2,
	DABAO_MAP = 3,
}

ActivityData.ActState = {
	OPEN = 0,										-- 活动进行中
	WAIT = 1,										-- 活动未开启
	CLOSE = 2,										-- 活动已结束
}

OPEN_DAY_SERVER_ACTIVITY_OPEN_LIST = {
	[5] = 1,
	[21] = 2,
	[6] = 3,
}

GUILD_ACTIVITY_LIST = {
	[6] = ACTIVITY_TYPE.GONGCHENGZHAN,
	[21] = ACTIVITY_TYPE.GUILDBATTLE,
	-- [27] = ACTIVITY_TYPE.GUILD_BONFIRE,
	-- [30] = ACTIVITY_TYPE.GUILD_ANSWER,
	-- [34] = ACTIVITY_TYPE.GUILD_SHILIAN,
	[3082] = ACTIVITY_TYPE.KF_GUILDBATTLE,
	[3087] = ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_LIEKUN_FB,
	[3091] = ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_LIUJIE_BOSS,
	[3092] = ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_BIANJING_ZHIDI
}

-- 这部分是玩法活动，用来显示传闻用的
ACTIVITY_PLAYING_TYPE = {
	[-1] = true,										-- 无效类型
	[1] = true,											-- 攻城准备战
	[2] = true,											-- 答题活动（旧版）
	[3] = true,											-- 护送活动
	[4] = true,											-- 怪物入侵
	[5] = true,											-- 三界战场
	[6] = true,											-- 攻城战
	[7] = true,											-- 仙盟战
	[8] = true,											-- 神兽禁地(全民boss)
	[9] = true,									 		-- 一战到底
	[10] = true,								 		-- 魔神降临
	[11] = true,								 		-- 阵营刺杀
	[12] = true,									 	-- 幸运挂机
	[13] = true,									 	-- 五行挂机
	[14] = true,										-- 水晶幻境
	[15] = true,										-- 皇城会战
	[16] = true,										-- 守卫雕像1
	[17] = true,										-- 守卫雕像2
	[18] = true,										-- 守卫雕像3
	[19] = true,										-- 领土战
	[20] = true,										-- 天降财宝
	[21] = true,										-- 公会争霸
	[22] = true,										-- 欢乐果树成长值兑换
	[23] = true,										-- 非跨服夜战王城
	[24] = true,										-- 公会Boss
	[25] = true,										-- 大富豪
	[26] = true,										-- 皇陵探险
	[27] = true,										-- 仙盟运镖
	[28] = true,										-- 星座遗迹
	[29] = true,										-- 婚宴
	[30] = true,										-- 仙盟答题
	[31] = true,										-- 乱斗战场
	[32] = true, 										-- 膜拜城主
	[33] = true,										-- 仙盟摇钱树
	[34] = true,										-- 仙盟试炼

	-- 客户端定义的活动类型
	[101] = true,										-- 排名竞技场(1V1)
	[100] = true,										-- 情缘副本
	[102] = true,										-- 仙盟任务
	[103] = true,										-- 仙盟神兽
	[104] = true,										-- 迷宫寻宝
	[105] = true,										-- 多人副本
	[106] = true,										-- 挖宝(仙女掠夺)
	[108] = true, 										-- 炼丹
	[109] = true,										-- 挂机
	[110] = true,										-- 多人塔防
	[112] = true,
	[113] = true,										-- 秘境降魔

	[3073] = true, 										-- 跨服修罗塔
	[3074] = true, 										-- 跨服1V1
	[3075] = true, 										-- 跨服3V3
	[3088] = true,										-- 跨服VIPBoss
	-- KF_TUANZHAN = [3076] = true,									-- 跨服神魔战
	[3077] = true,										-- 牧场
	[3078] = true,										-- 跨服boss
	[3079] = true,										-- 跨服副本
	[3080] = true,										-- 跨服温泉
	-- CROSS_SHUIJING = [3080] = true,									-- 跨服水晶
	[3082] = true,										-- 跨服六界
	[3083] = true,										-- 跨服月黑风高
	[3084] = true, 										-- 跨服钓鱼
	[3085] = true,										-- 夜战王城 CROSS_ACTIVITY_TYPE_NIGHT_FIGHT_FB
	[3086] = true,										-- 跨服乱斗战场
	[3087] = true,										-- 跨服灵鲲之战
	[3089] = true,										-- 跨服秘藏Boss
	[3090] = true,										-- 跨服幽冥Boss
	[3091] = true,										-- 六界BOSS
	[3092] = true,										-- 跨服边境

	--手动添加活动
	[10001] = true, 									-- 婚宴
	[10002] = true,										-- 锁妖塔
	[10003] = true,										-- 妖兽广场
	[10006] = true,
	[10012] = true,										-- 仙尊卡

	[100001] = true,									-- 活动卷轴中的功能 龙行天下
	[100002] = true,									-- 活动卷轴 天天返利
}

-- 跨服仙盟活动
ACTIVITY_ENTER_LIMIT_LIST = {
	[3] = true,											-- 护送
	[6] = true,											-- 攻城战
	[21] = true,										-- 公会争霸
	[30] = true,										-- 仙盟答题
	[27] = true,										-- 仙盟运镖
	[32] = true,										-- 膜拜城主
	[34] = false,										-- 仙盟试炼
	[3073] = true,										-- 跨服修罗塔
	[3081] = true,										-- 跨服水晶（没开）
	[14] = true,										-- 灵石秘境
	[3083] = true,										-- 珍宝秘境
	[5] = true,											-- 仙魔战场
	[23] = true,										-- 怒战九霄
	[26] = true,										-- 王陵探险
	[31] = true,										-- 乱斗战场
	[3074] = true,										-- 巅峰对决
	[3075] = true,										-- 战队争霸
	[3077] = true,										-- 万灵神殿
	[3080] = true,										-- 温泉答题
	[3082] = true,										-- 六界争霸
	[3084] = true,										-- 跨服钓鱼
	[3085] = true,										-- 怒战九霄
	[3086] = true,										-- 乱斗战场
	[3087] = true,										-- 灵鲲之战
	[3091] = true,										-- 连服诛魔
	[3094] = true,										-- 灵石护送
}

local WORSHIP_SCENE_TYPE = {
	[8] = 6,
	[41] = 21,
	[5] = 5,
	[22] = 3082,
}

-- 活动卷轴里面的功能(sort_index用来对卷轴里面的活动进行降序排序，这个列表是假活动)
FunInActHallView = {
	{fun_name = ViewName.ClothespressView, icon = "Icon_System_Clothespress", icon_name = "clothespress", open_name = ViewName.ClothespressView, type = 100003, sort_index = 5000},
	{fun_name = ViewName.LongXingView, icon = "Icon_Longxing", icon_name = "LongXing", open_name = ViewName.LongXingView, type = 100001, sort_index = 10000},
	{fun_name = ViewName.DailyRebateView, icon = "DailyRebate", icon_name = "DailyRebateName", open_name = ViewName.DailyRebateView, type = 100002, sort_index = 11000},
	-- {fun_name = ViewName.DuihuanView, icon = "DuihuanView", icon_name = "DuihuanView", open_name = ViewName.DuihuanView, is_teshu = true, name = 11111,},
}

local ACTIVITY_PREVIEW_OPEN_LEVEL = 120
local LIANFUDUOCHEGNOPENDAY = 5

function ActivityData:__init()
	if ActivityData.Instance then
		print_error("[ActivityData] Attempt to create singleton twice!")
		return
	end
	ActivityData.Instance = self

	self.activity_list = {}									-- 活动信息
	self.room_info_list = {}								-- 房间信息
	self.lucky_log = {}										-- 幸运儿
	self.act_change_callback = {}

	self.cross_activity_list = {}							-- 跨服随机活动
	self.cross_activity_info_list = {}						-- 存储全部下发的活动信息,用于玩家升级之后重新给活动信息表赋值

	-- 卷轴红点
	self.red_point_states = {}
	self.next_monster_invade_time = 0
	self.activity_type = 0
	local rand_act_open_list_cfg = ConfigManager.Instance:GetAutoConfig("randactivityopencfg_auto")
	self.rand_act_open_cfg = ListToMap(rand_act_open_list_cfg.open_cfg, "activity_type")


	self.activity_cfg = ConfigManager.Instance:GetAutoConfig("daily_act_cfg_auto")
	self.show_cfg = ListToMap(self.activity_cfg.show_cfg, "act_id")
	self.show_type_list_cfg = ListToMapList(self.activity_cfg.show_cfg, "act_type")

	local act_list_cfg =  ConfigManager.Instance:GetAutoConfig("daily_activity_auto")
	self.daily_activity_cfg = ListToMap(act_list_cfg.daily, "act_type")

	self.join_limit_config = ConfigManager.Instance:GetAutoConfig("joinlimitconfig_auto")

	self.cross_info = {
		cross_activity_type = 0,
		login_server_ip = "",
		login_server_port = 0,
		pname = "",
		login_time = 0,
		login_str = "",
		anti_wallow = 0,
		server = 0,
	}

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

	self.boss_week_rank_info = {
		my_guild_kill_count = 0,
		my_guild_rank = 0,
		rank_count = 0,
		rank_list = {},
	}
	self.last_check_open_server_day = 0
	self.check_realopen_day_week_day_t = {}
	self.next_refresh_time = 0
	self.first_rank = {}
	self.first_rank_uid = {}
	self.first_rank_role_info = {}
	self.activity_id = 0
	self.activity_reward_info = {}
	self.activity_reward_list = {}
	self.activity_reward_id_list ={}
	self.activity_status_cache_data = {}

	self.is_send_zhuagui_invite = false 			--是否等待发出秘境降魔邀请
	self.pass_day_handle = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.OnDayChangeCallBack, self))
	RemindManager.Instance:Register(RemindName.ACTIVITY_JUAN_ZHOU, BindTool.Bind(self.IsShowRedPointJuan, self))
end

function ActivityData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ActivityHall)
	RemindManager.Instance:UnRegister(RemindName.ACTIVITY_JUAN_ZHOU)
	GlobalEventSystem:UnBind(self.pass_day_handle)
	ActivityData.Instance = nil
	self.activity_status_cache_data = {}
end

function ActivityData:ClearCache()
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
end

--对活动进行排序
local function Sort_Activity(act_a, act_b)
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_vo.level >= act_a.min_level and main_vo.level >= act_b.min_level then
		local act_a_is_open = ActivityData.Instance:GetActivityIsOpen(act_a.act_id)
		local act_b_is_open = ActivityData.Instance:GetActivityIsOpen(act_b.act_id)
		if act_a_is_open ~= act_b_is_open then
			return act_a_is_open
		else
			local server_time = TimeCtrl.Instance:GetServerTime()
			local now_weekday = os.date("%w", server_time)
			local server_time_str = os.date("%H:%M", server_time)

			local a_open_day_list = Split(act_a.open_day, ":")
			local a_open_time_list = Split(act_a.open_time, "|")
			local a_open_time_str = a_open_time_list[1]
			local a_end_time_list = Split(act_a.end_time, "|")
			-- local a_end_time_str = a_end_time_list[1]

			local b_open_day_list = Split(act_b.open_day, ":")
			local b_open_time_list = Split(act_b.open_time, "|")
			local b_open_time_str = b_open_time_list[1]
			local b_end_time_list = Split(act_b.end_time, "|")
			-- local b_end_time_str = b_end_time_list[1]

			local a_today_open = false
			for k, v in ipairs(a_open_day_list) do
				if v == now_weekday then
					local though_time = true
					for k1, v1 in ipairs(a_end_time_list) do
						if v1 > server_time_str then
							though_time = false
							a_open_time_str = a_open_time_list[k1]
							break
						end
					end
					if not though_time then
						a_today_open = true
					end
					break
				end
			end
			local b_today_open = false
			for k, v in ipairs(b_open_day_list) do
				if v == now_weekday then
					local though_time = true
					for k1, v1 in ipairs(b_end_time_list) do
						if v1 > server_time_str then
							though_time = false
							b_open_time_str = b_open_time_list[k1]
							break
						end
					end
					if not though_time then
						b_today_open = true
					end
					break
				end
			end
			if (a_today_open and b_today_open) or (not a_today_open and not b_today_open) then
				return a_open_time_str < b_open_time_str
			else
				return a_today_open
			end
		end
	else
		return act_a.min_level < act_b.min_level
	end
end

function ActivityData:GetClockActivityByType(act_type)
	local temp_list = TableCopy(self.show_type_list_cfg[act_type])
	if temp_list == nil then
		return
	end
	for k,v in pairs(temp_list) do
		if v.act_id == ACTIVITY_TYPE.SHUIJING or v.act_id == ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_LIUJIE_BOSS then		--对特定活动进行日期区间限制
			local real_open_day = self:GetActivityRealOpenDay(v.act_id)
			v.open_day = real_open_day
		end
	end
	table.sort(temp_list, Sort_Activity)

	if act_type == ActivityData.Act_Type.normal then
		local index = 0
		for i = 1, #temp_list do
			if temp_list[i].act_id == ACTIVITY_TYPE.GONGCHENG_WORSHIP then
				index = i
				break
			end
		end
		if index > 0 then
			table.remove(temp_list, index)
		end
	end
	if act_type == ActivityData.Act_Type.battle_field then
		local index = 0
		for i = 1, #temp_list do
			if temp_list[i].act_id == ACTIVITY_TYPE.CHAOSWAR then
				index = i
				break
			end
		end
		if index > 0 then
			table.remove(temp_list, index)
		end
	end

	local cur_server_day = TimeCtrl.Instance:GetCurOpenServerDay()

		if act_type ~= nil then
			local index = 0
			for i = #temp_list,1,-1 do
				if (temp_list[i].opensever_day > TimeCtrl.Instance:GetCurOpenServerDay()) or (temp_list[i].closesever_day ~= 0 
				and temp_list[i].closesever_day <= TimeCtrl.Instance:GetCurOpenServerDay()) then
					index = i
				end

				if index > 0 then
					table.remove(temp_list, index)
					index = 0
				end
			end
		end

--对今天活动进行排序
function Sort_Day_Activity(act_a, act_b)

	local act_a_is_open = ActivityData.Instance:GetActivityIsOpen(act_a.act_id)
	local act_b_is_open = ActivityData.Instance:GetActivityIsOpen(act_b.act_id)
	local a_is_reach_level = self:GetIsOpenLevel(act_a.act_id)
	local b_is_reach_level = self:GetIsOpenLevel(act_b.act_id)

	if act_a_is_open ~= act_b_is_open then
		return act_a_is_open
	else
		local server_time = TimeCtrl.Instance:GetServerTime()
		local now_weekday = tonumber(os.date("%w", server_time)) or 0
		local server_time_str = os.date("%H:%M", server_time)
		if now_weekday <= 0 then
			now_weekday = 7
		end

		local a_open_day_list = Split(act_a.open_day, ":")
		local a_open_time_list = Split(act_a.open_time, "|")
		local a_open_time_str = a_open_time_list[1]
		local a_end_time_list = Split(act_a.end_time, "|")
		-- local a_end_time_str = a_end_time_list[1]

		local b_open_day_list = Split(act_b.open_day, ":")
		local b_open_time_list = Split(act_b.open_time, "|")
		local b_open_time_str = b_open_time_list[1]
		local b_end_time_list = Split(act_b.end_time, "|")
		-- local b_end_time_str = b_end_time_list[1]

		local a_today_open = false
		for k, v in ipairs(a_open_day_list) do
			if tonumber(v) == now_weekday then
				local though_time = true
				for k1, v1 in ipairs(a_open_time_list) do
					if v1 > server_time_str then
						though_time = false
						a_open_time_str = a_open_time_list[k1]
						break
					end
				end
				if not though_time then
					a_today_open = true
				end
				break
			end
		end
		local b_today_open = false
		for k, v in ipairs(b_open_day_list) do
			if tonumber(v) == now_weekday then
				local though_time = true
				for k1, v1 in ipairs(b_open_time_list) do
					if v1 > server_time_str then
						though_time = false
						b_open_time_str = b_open_time_list[k1]
						break
					end
				end
				if not though_time then
					b_today_open = true
				end
				break
			end
		end

		act_a_is_ready = self:GetActivityIsReady(act_a.act_id)
		act_b_is_ready = self:GetActivityIsReady(act_b.act_id)
		if (a_today_open and b_today_open) or (not a_today_open and not b_today_open) and a_is_reach_level and b_is_reach_level then
			if (act_a_is_ready and act_b_is_ready) or (not act_a_is_ready and not act_b_is_ready) then
				return a_open_time_str < b_open_time_str
			else
				return act_a_is_ready
			end
			
		else
			return a_today_open
		end
	end
end

	table.sort(temp_list, Sort_Day_Activity)
	local list = {}
	for i = #temp_list, 1, -1 do
		local is_reach_level = self:GetIsOpenLevel(temp_list[i].act_id)
		if not is_reach_level then
			local temp = temp_list[i]
			table.insert(list, temp)
			table.remove(temp_list, i)
		end
	end
	for i,v in ipairs(list) do
		table.insert(temp_list, v)
	end
	return temp_list
end

function ActivityData:GetClockActivityCountByType(act_type)
	local temp_list = self:GetClockActivityByType(act_type)
	for i = #temp_list, 1, -1 do
		local is_reach_level = self:GetIsOpenLevel(temp_list[i].act_id)
		if not is_reach_level then
			table.remove(temp_list, i)
		end
	end
	return temp_list and #temp_list or 0
end

function ActivityData:GetClockActivityByID(id)
	return self.show_cfg[id] or {}
end

function ActivityData:GetActivityInfoById(id)
	return self.show_cfg[id] or {}
end


function ActivityData:GetAllActivityOpenInfo()
	local temp_list = {}
	for k, v in pairs(self.show_type_list_cfg[ActivityData.Act_Type.normal]) do
		local is_reach_level = self:GetIsOpenLevel(v.act_id)
		if is_reach_level then
			table.insert(temp_list, v)
		end
	end

	for k, v in pairs(self.show_type_list_cfg[ActivityData.Act_Type.battle_field]) do
		local is_reach_level = self:GetIsOpenLevel(v.act_id)
		if is_reach_level then
			table.insert(temp_list, v)
		end
	end

	for k, v in pairs(self.show_type_list_cfg[ActivityData.Act_Type.kuafu_battle_field]) do
		local is_reach_level = self:GetIsOpenLevel(v.act_id)
		if is_reach_level then
			table.insert(temp_list, v)
		end
	end

	local act_info = ActivityData.Instance:GetActivityInfoById(ACTIVITY_TYPE.MOSHEN)
	local is_reach_level = self:GetIsOpenLevel(act_info.act_id)
	if is_reach_level then
		table.insert(temp_list, act_info)
	end

	local cfg_list = {}
	for _,v in pairs(temp_list) do
		local act_t = TableCopy(v)
		act_t.sort_key = 0

		if ActivityData.Instance:GetActivityIsOpen(act_t.act_id) then
			act_t.sort_key = act_t.sort_key + 100000
		end

		local server_time = TimeCtrl.Instance:GetServerTime()
		local now_weekday = tonumber(os.date("%w", server_time))
		if now_weekday == 0 then
			now_weekday = 7
		end

		local server_time_str = os.date("%H:%M", server_time)
		local open_day_list = Split(act_t.open_day, ":")
		local open_time_list = Split(act_t.open_time, "|")
		local open_time_str = open_time_list[1]
		local end_time_list = Split(act_t.end_time, "|")

		local today_open = false
		local though_time = true
		for k, v in ipairs(open_day_list) do
			if tonumber(v) == now_weekday then
				today_open = true
				for k1, v1 in ipairs(#end_time_list > 0 and end_time_list or open_time_list) do
					if v1 > server_time_str then
						though_time = false
						open_time_str = open_time_list[k1]
						break
					end
				end
				break
			end
		end

		if today_open then
			if though_time then
				act_t.sort_key = act_t.sort_key - 1000000
			else
				act_t.sort_key = act_t.sort_key + 10000
			end

			local open_time_t = Split(open_time_str, ":")
			local open_time_value = tonumber(open_time_t[1]) * 100 + tonumber(open_time_t[2])
			act_t.sort_key = act_t.sort_key + (2400 - open_time_value)

			table.insert(cfg_list, act_t)
		end
	end

	table.sort(cfg_list, SortTools.KeyUpperSorter("sort_key"))

	return cfg_list
end

function ActivityData:GetNextActivityOpenInfo()
	if PlayerData.Instance.role_vo.level < ACTIVITY_PREVIEW_OPEN_LEVEL then
		return
	end

	local cfg = nil
	local act_cfg = self:GetAllActivityOpenInfo()
	for i, v in ipairs(act_cfg) do
		local server_time = TimeCtrl.Instance:GetServerTime()
		local server_time_str = os.date("%H:%M", server_time)
		local open_time_tbl = Split(v.open_time, "|")
		local open_time_str = open_time_tbl[1]

		local though_time = true
		for k2, v2 in ipairs(open_time_tbl) do
			if server_time_str < v2 then
				though_time = false
				open_time_str = open_time_tbl[k2]
				break
			end
		end

		local is_openning = self:GetActivityIsOpen(v.act_id) or v.is_allday == 1
		if not is_openning and not though_time then
			cfg = v
			break
		end
	end
	return cfg
end

function ActivityData:GetNextActivityCountDownStr()
	local cfg = self:GetNextActivityOpenInfo()
	if nil == cfg then
		return
	end

	local server_time = TimeCtrl.Instance:GetServerTime()
	local server_time_str = os.date("%H:%M", server_time)

	local open_time_tbl = Split(cfg.open_time, "|")
	local open_time_str = open_time_tbl[1]

	for k2, v2 in ipairs(open_time_tbl) do
		if server_time_str < v2 then
			open_time_str = open_time_tbl[k2]
			break
		end
	end

	local time_t = Split(open_time_str, ":")
	local act_start_time = TimeUtil.NowDayTimeStart(server_time) + time_t[1] * 60 * 60 + time_t[2] * 60
	local countdown_time = math.floor(act_start_time - server_time)

	if countdown_time < 0 then
		return nil
	end

	if countdown_time > 30 * 60 then
		return ""
	end

	return TimeUtil.FormatSecond2Str(countdown_time)
end

function ActivityData:SetActivityStatus(activity_type, status, next_time, start_time, end_time, open_type)
	self.activity_list[activity_type] = {
		["type"] = activity_type,
		["status"] = status,
		["next_time"] = next_time,
		["start_time"] = start_time,
		["end_time"] = end_time,
		["open_type"] = open_type,
		["sort_index"] = 0,
	}
	for k, v in pairs(self.act_change_callback) do
		v(activity_type, status, next_time, open_type)
	end
	if status == ACTIVITY_STATUS.CLOSE then
		self:SetNewServerAct()
		self:SetLianFuDuoChengAct()
	end
	if GUILD_ACTIVITY_LIST[activity_type] then
		ChatCtrl.Instance:FlushViewActivityIcon()
	end
end

function ActivityData:GetActivityStatus()
	return self.activity_list
end

function ActivityData:GetActivityStatuByType(activity_type)
	return self.activity_list[activity_type]
end

function ActivityData:ClearAllActivity()
	for k,v in pairs(self.activity_list) do
		if v.status ~= ACTIVITY_STATUS.CLOSE then
			v.status = ACTIVITY_STATUS.CLOSE
			for k1, v1 in pairs(self.act_change_callback) do
				v1(k, ACTIVITY_STATUS.CLOSE, 0, open_type)
			end
		end
	end
end

--获得某个活动是否开启
function ActivityData:GetActivityIsOpen(act_type)
	local activity_info = self:GetActivityStatuByType(act_type)

	if nil ~= activity_info and ACTIVITY_STATUS.OPEN == activity_info.status then
		return true
	end
	return false
end

--添加获取某个活动是否是准备状态
function ActivityData:GetActivityIsReady(act_type)
	local activity_info = self:GetActivityStatuByType(act_type)

	if nil ~= activity_info and ACTIVITY_STATUS.STANDY == activity_info.status then
		return true
	end
	return false
end

function ActivityData:SetNextMonsterInvadeTime(time)
	self.next_monster_invade_time = time
end

function ActivityData:GetNextMonsterInvadeTime()
	return self.next_monster_invade_time
end

--根据类型获得活动配置
function ActivityData:GetActivityNameByType(act_type)
	local act_cfg = self:GetActivityConfig(act_type)
	if nil ~= act_cfg then
		if act_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WEEKENDHAPPY and self.last_check_open_server_day <= 4 then
			return Language.Activity.WeekendHappy
		else
			return act_cfg.act_name
		end
	end

	local act_cfg = self.rand_act_open_cfg[act_type]
	if nil ~= act_cfg then
		return act_cfg.name
	end
	--判断版本活动
	
	local act_cfg = FestivalActivityData.Instance:GetActivityOpenCfgById(act_type)
	if nil ~= act_cfg then
		return act_cfg.name
	end

	return ""
end

function ActivityData:GetBossState(boss_id)
	return ActivityData.Boss_State.ready
end

--获得某个活动是否当天开启
function ActivityData:GetActivityIsInToday(act_type)
	local act_cfg = self:GetClockActivityByID(act_type)
	if act_cfg == nil or next(act_cfg) == nil then return false end
	local server_time = TimeCtrl.Instance:GetServerTime()
	local updata_time = math.max(server_time - 6 * 3600, 0) 	-- 6点刷新时间
	local w_day = tonumber(os.date("%w", updata_time))
	if 0 == w_day then w_day = 7 end

	local open_day_list = Split(act_cfg.open_day, ":")
	local is_open_day = false
	for k, v in pairs(open_day_list) do
		if tonumber(v) == w_day then
			is_open_day = true
			break
		end
	end
	return is_open_day
end

--获得某个活动是否当天凌晨开启
function ActivityData:GetActivityIsInEarlyMorning(act_type)
	local act_cfg = self:GetClockActivityByID(act_type)
	if act_cfg == nil or next(act_cfg) == nil then return false end
	local server_time = TimeCtrl.Instance:GetServerTime()
	local updata_time = math.max(server_time - 0 * 3600, 0) 	-- 0点刷新时间
	local w_day = tonumber(os.date("%w", updata_time))
	if 0 == w_day then w_day = 7 end

	local open_day_list = Split(act_cfg.open_day, ":")
	local is_open_day = false
	for k, v in pairs(open_day_list) do
		if tonumber(v) == w_day then
			is_open_day = true
			break
		end
	end
	return is_open_day
end

--获得某个活动是否已经进行完
function ActivityData:GetActivityIsOver(act_type)
	local act_cfg = self:GetClockActivityByID(act_type)
	if act_cfg == nil then
		return false
	end
	if self:GetActivityIsInToday(act_type) then
		if self:GetActivityIsOpen(act_type) then
			return false
		else
			local server_time = TimeCtrl.Instance:GetServerTime()
			local time_zone = TimeUtil.GetTimeZone()
			server_time = server_time + time_zone
			local time_tab = TimeUtil.Format2TableDHM(server_time)
			local now_time = time_tab.hour * 60 + time_tab.min
			local open_time_list = Split(act_cfg.open_time, "|")
			local open_time_table = Split(open_time_list[#open_time_list], ":")
			if open_time_table and open_time_table[1] and open_time_table[2] then
				local open_time = tonumber(open_time_table[1]) * 60 + tonumber(open_time_table[2])
				return now_time > open_time
			else
				return false
			end
		end
	else
		return false
	end
end

-- 通过配置表获得某个活动下次的开启时间
function ActivityData:GetNextOpenTime(act_type)
	local act_cfg = self:GetClockActivityByID(act_type)
	local next_time1 = 0
	local next_time2 = "00:00"
	if act_cfg then
		local server_time = TimeCtrl.Instance:GetServerTime()
		local time_zone = TimeUtil.GetTimeZone()
		server_time = server_time + time_zone
		local time_tab = TimeUtil.Format2TableDHM(server_time)
		local now_time = time_tab.hour * 60 + time_tab.min
		local open_time_list = Split(act_cfg.open_time, "|")
		for i = 1, #open_time_list do
			local open_time_table = Split(open_time_list[i], ":")
			if open_time_table and open_time_table[1] and open_time_table[2] then
				local open_time = tonumber(open_time_table[1]) * 60 + tonumber(open_time_table[2])
				if i == 1 then
					next_time1 = open_time
					next_time2 = open_time_list[1]
				end
				if open_time > now_time then
					next_time1 = open_time
					next_time2 = open_time_list[i]
					break
				end
			end
		end
	end
	return next_time1, next_time2
end

-- 通过配置表获得某个活动下次的开启时间(周X xx:xx)
function ActivityData:GetNextOpenWeekTime(act_type)
	if develop_mode:IsDeveloper() then

	end
	local act_info = self:GetClockActivityByID(act_type)
	local time_str = Language.Activity.YiJieShu
	if not act_info or not next(act_info) then
		return time_str
	end
	local open_day_list = Split(act_info.open_day, ":")
	local server_time = TimeCtrl.Instance:GetServerTime()
	local now_weekday = tonumber(os.date("%w", server_time))
	local server_time_str = os.date("%H:%M", server_time)
	if now_weekday == 0 then now_weekday = 7 end
	if ActivityData.Instance:GetActivityIsOpen(act_info.act_id) then
		time_str = Language.Activity.KaiQiZhong
	elseif act_info.is_allday == 1 then
		time_str = Language.Activity.AllDay
	else
		local flag = false
		local open_time_tbl = Split(act_info.open_time, "|")
		local open_time_str = open_time_tbl[1]
		local end_time_tbl = Split(act_info.end_time, "|")
		for _, v in ipairs(open_day_list) do
			if tonumber(v) == now_weekday then
				local though_time = true
				for k2, v2 in ipairs(end_time_tbl) do
					if v2 > server_time_str then
						though_time = false
						open_time_str = open_time_tbl[k2]
						break
					end
				end
				if though_time then
					time_str = Language.Activity.YiJieShuDes
				else
					flag = true
					time_str = string.format("%s", open_time_str)
				end
				break
			end
		end
		if not flag then
			local open_day = open_day_list[1] or 1
			for _, v in ipairs(open_day_list) do
				if tonumber(v) > now_weekday then
					open_day = tonumber(v)
					break
				end
			end
			time_str = string.format("%s %s", Language.Common.Week .. Language.Common.DayToChs[tonumber(open_day)], open_time_str)
		end
	end
	return time_str
end

-- 注册监听活动状态改变
function ActivityData:NotifyActChangeCallback(callback)
	self.act_change_callback[#self.act_change_callback + 1] = callback
end

-- 取消注册
function ActivityData:UnNotifyActChangeCallback(callback)
	for k,v in pairs(self.act_change_callback) do
		if v == callback then
			self.act_change_callback[k] = nil
		end
	end
end

function ActivityData:SetRoomStatusList(activity_type, room_user_max, room_status_list)
	self.room_info_list[activity_type] = {['activity_type'] = activity_type, ['room_user_max'] = room_user_max, ['room_status_list'] = room_status_list}
end

function ActivityData:GetRoomIndex(activity_type)
	local room_data = self.room_info_list[activity_type]
	local room_index = 0
	if room_data then
		local room_user_max = room_data.room_user_max
		local room_list = room_data.room_status_list
		local n = room_user_max
		for k,v in pairs(room_list) do
			if v.is_open == 1 and v.role_num < n then
				n = v.role_num
				room_index = v.index
			end
		end
	end
	return room_index
end

function ActivityData:GetRoomStatuList()
	return self.room_info_list
end

function ActivityData:GetRoomStatuesByActivityType(activity_type)
	return self.room_info_list[activity_type]
end

function ActivityData.GetActivityName(act_type)
	return self.daily_activity_cfg[act_type] and self.daily_activity_cfg[act_type].name or tostring(act_type)
end

function ActivityData.GetActivityStatusName(status)
	if status == ACTIVITY_STATUS.CLOSE then 				--活动关闭状态
		return Language.Activity.ActivetyStatusClose
	elseif status == ACTIVITY_STATUS.STANDY then			--活动准备状态
		return Language.Activity.ActivetyStatusStandy
	elseif status == ACTIVITY_STATUS.OPEN then				--活动进行中
		return Language.Activity.ActivetyStatusOpen
	end
	return tostring(status)
end

-- 获取活动剩余时间,结束时间
function ActivityData:GetActivityResidueTime(act_type)
	local time = 0
	local next_time = 0
	local activity = self:GetActivityStatuByType(act_type)
	if activity then
		next_time = activity.next_time
		time = activity.next_time - TimeCtrl.Instance:GetServerTime()
	end
	return time, next_time
end

-- 获取活动开启第几天
function ActivityData.GetActivityDays(act_type)
	local activity = ActivityData.Instance:GetActivityStatuByType(act_type)
	if activity then
		local time_off = TimeCtrl.Instance:GetServerTime() - TimeUtil.NowDayTimeStart(activity.start_time)
		return math.ceil(time_off / 86400)
	end
	return 0
end

--请求进入活动的房间
function ActivityData:OnEnterRoom(activity_type)
	local room_info_list = self:GetRoomStatuesByActivityType(activity_type)
	if nil ~= room_info_list and nil ~= room_info_list.room_status_list then
		-- 选择房间人数最少的进入
		local min_role_num = 9999
		local enter_room_index = 0
		local activity_room_list = room_info_list.room_status_list
		for _, room_status in pairs(activity_room_list) do
			if ACTIVITY_ROOM_STATUS.OPEN == room_status.is_open then
				if room_status.role_num < min_role_num then
					min_role_num = room_status.role_num
					enter_room_index = room_status.index
				end
			end
		end
		Log("请求进入" .. ActivityData.GetActivityName(activity_type), "活动房间号：", enter_room_index)
		Log("当前房间人数：", min_role_num)
		local activity_cfg = DailyData.Instance:GetActivityConfig(activity_type)

		if nil ~= activity_cfg then
			ActivityCtrl.Instance:SendActivityEnterReq(activity_type, enter_room_index)
		end
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Activity.MeiYouKaiQiDeFangJian)
	end
end

function ActivityData:GetActivityConfig(act_type)
	return self.show_cfg[act_type]
end

function ActivityData:GetIsShowLimint(act_type, time, level)
	local activity_cfg = self:GetActivityConfig(act_type)
	if activity_cfg and activity_cfg.open_day_2 then
		-- local time_list_1 = Split(activity_cfg.open_day_1, ":")
		local time_list_2 = Split(activity_cfg.open_day_2, ":")
		-- if level >= activity_cfg.min_level_1 and level <= activity_cfg.max_level_1 then
		-- 	for k,v in pairs(time_list_1) do
		-- 		if v then
		-- 			if tonumber(v) == time then
		-- 				return true
		-- 			end
		-- 		end
		-- 	end
		-- end
		if level >= activity_cfg.min_level_2 and level <= activity_cfg.max_level_2 then
			for k,v in pairs(time_list_2) do
				if v then
					if tonumber(v) == time then
						return true
					end
				end
			end
		end
	end
	return false
end

function ActivityData:ClearCrossInfo(info)
	if self.cross_info then
		self.cross_info.cross_activity_type = 0
		self.cross_info.login_server_ip = ""
		self.cross_info.login_server_port = 0
		self.cross_info.pname = ""
		self.cross_info.login_time = 0
		self.cross_info.login_str = ""
		self.cross_info.anti_wallow = 0
		self.cross_info.server = 0
	end
	GlobalEventSystem:Fire(CrossType.ExitCross)
end

-----------------------------------世界Boss---------------------------------------------

function ActivityData:BossBorn()

end

function ActivityData.KeyDownSort(sort_key_name1, sort_key_name2)
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

function ActivityData:SetBossPersonalHurtInfo(protocol)
	self.boss_personal_hurt_info = {}
	for k,v in pairs(protocol) do
		self.boss_personal_hurt_info[k] = v
	end
end

function ActivityData:SetBossGuildHurtInfo(protocol)
	self.boss_guild_hurt_info = {}
	for k,v in pairs(protocol) do
		self.boss_guild_hurt_info[k] = v
	end
end

function ActivityData:SetBossWeekRankInfo(protocol)
	for k,v in pairs(protocol) do
		self.boss_week_rank_info[k] = v
	end
end

function ActivityData:GetBossPersonalHurtInfo()
	return self.boss_personal_hurt_info
end

function ActivityData:GetBossGuildHurtInfo()
	return self.boss_guild_hurt_info
end

function ActivityData:GetBossWeekRankInfo()
	return self.boss_week_rank_info
end

function ActivityData:IsSendZhuaGuiInvite()
	return self.is_send_zhuagui_invite
end


function ActivityData:SetSendZhuaGuiInvite(state)
	self.is_send_zhuagui_invite = state
end

function ActivityData:OnDayChangeCallBack(cur_day, is_new_day)
	self:SetNewServerAct(cur_day)
	self:SetLianFuDuoChengAct(cur_day)
	self:SetHeFuNewServerAct(cur_day)
	FuBenData.Instance:ResetOpenBuffType()
end

-- 开服固定开启的活动，提前预告，准备中状态倒计时
local OPEN_SERVER_ACTIVITY_OPEN_LIST = {
	ACTIVITY_TYPE.QUNXIANLUANDOU,
	ACTIVITY_TYPE.GUILDBATTLE,
	ACTIVITY_TYPE.GONGCHENGZHAN,
}


-- 合服盟战和攻城战提前预告，准备中状态倒计时
local HEFU_SERVER_ACTIVITY_OPEN_LIST = {
	[1] = ACTIVITY_TYPE.GUILDBATTLE,
	[2] = ACTIVITY_TYPE.GONGCHENGZHAN,
}

function ActivityData:SetNewServerAct(day, is_next_day)
	day = day or TimeCtrl.Instance:GetCurOpenServerDay()
	if day > #OPEN_SERVER_ACTIVITY_OPEN_LIST then return end

	local act_type = OPEN_SERVER_ACTIVITY_OPEN_LIST[day]
	if self:GetActivityIsOpen(act_type) then
		return
	end
	local act_cfg = self:GetClockActivityByID(act_type)
	if act_cfg == nil or next(act_cfg) == nil then return end

	local open_time_str = Split(act_cfg.open_time, "|")
	local open_time_t = Split(open_time_str[1], ":")
	local open_hour, open_min = open_time_t[1], open_time_t[2]
	local day_open_second = open_hour * 3600 + open_min * 60
	local time_table = os.date("*t",TimeCtrl.Instance:GetServerTime())
	local cur_day_second = time_table.hour * 3600 + time_table.min*60 + time_table.sec
	if cur_day_second < day_open_second or is_next_day then
		time_table.hour = open_hour
		time_table.min = open_min
		time_table.sec = 0
		if is_next_day then
			time_table.day = time_table.day + 1
		end
		ActivityData.Instance:SetActivityStatus(act_type, ACTIVITY_STATUS.STANDY, os.time(time_table))
	elseif day < #OPEN_SERVER_ACTIVITY_OPEN_LIST then
		self:SetNewServerAct(day + 1, true)
	end
end

function ActivityData:SetLianFuDuoChengAct(day, is_next_day)
	day = day or TimeCtrl.Instance:GetCurOpenServerDay()
	local act_type = ACTIVITY_TYPE.KF_GUILDBATTLE 
	if day < 3 then return end 
	local residue_time = self:GetResidueTime(act_type)
	if day > LIANFUDUOCHEGNOPENDAY + residue_time then return end
	if day == 3 then
		act_type = ACTIVITY_TYPE.GONGCHENGZHAN
	end
	if self:GetActivityIsOpen(act_type) then
		return
	end

	local act_cfg = self:GetClockActivityByID(act_type)
	if act_cfg == nil or next(act_cfg) == nil then return end
	local open_time_str = Split(act_cfg.open_time, "|")
	local open_time_t = Split(open_time_str[1], ":")
	local open_hour, open_min = open_time_t[1], open_time_t[2]
	local day_open_second = open_hour * 3600 + open_min * 60
	local time_table = os.date("*t",TimeCtrl.Instance:GetServerTime())
	local cur_day_second = time_table.hour * 3600 + time_table.min*60 + time_table.sec
	if act_type == ACTIVITY_TYPE.GONGCHENGZHAN and cur_day_second < day_open_second then
		return
	end
	if cur_day_second < day_open_second or is_next_day then
		time_table.hour = open_hour
		time_table.min = open_min
		time_table.sec = 0
		if is_next_day then
			time_table.day = time_table.day + 1
		end
		local residue_day = residue_time + LIANFUDUOCHEGNOPENDAY - day
		ActivityData.Instance:SetActivityStatus(ACTIVITY_TYPE.KF_GUILDBATTLE_READYACTIVITY, ACTIVITY_STATUS.STANDY, os.time(time_table) + residue_day*3600*24)
	elseif day < LIANFUDUOCHEGNOPENDAY + residue_time then
		self:SetLianFuDuoChengAct(day + 1, true)
	end
end

function ActivityData:GetResidueTime(act_type)
	local wek_day = 0
	local limint_config = self:GetActivityLimintConfig()
	if not limint_config then
		return wek_day
	end
	-- local act_info = self:GetClockActivityByID(act_type)
	local act_info = nil
	for k,v in pairs(limint_config) do
		if v and v.type == 1 and v.sub_type == act_type then
			act_info = v
		end
	end
	if not act_info or not next(act_info) then
		return wek_day
	end
	local open_day_list = Split(act_info.open_day_vec_vec, ",")
	local time_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local server_time = TimeCtrl.Instance:GetServerTime() or 0
	local time = tonumber(os.date("%w",server_time)) or 0
	if time == 0 then time = 7 end
	local now_weekday = time - (time_day % 7 - LIANFUDUOCHEGNOPENDAY)
	if now_weekday <= 0 then
		now_weekday = now_weekday + 7
	elseif now_weekday > 7 then
		now_weekday = now_weekday - 7
	end
	local open_day = open_day_list[1] or 1
	for _, v in ipairs(open_day_list) do
		if tonumber(v) >= now_weekday then
			wek_day = tonumber(v) - now_weekday
			break
		else
			wek_day = open_day
		end
	end
	return wek_day
end

function ActivityData:SetHeFuNewServerAct(day, is_next_day)
	if (not HefuActivityData.Instance:IsHeFuFirstCombine()) and (not HefuActivityData.Instance:IsHeFuFirstGuildWar()) then
		return
	end

	local act_type = 0
	-- 攻城战星期三星期日开
	if HefuActivityData.Instance:IsHeFuFirstCombine() then
		act_type = HEFU_SERVER_ACTIVITY_OPEN_LIST[2]
		if not self:GetActivityIsInEarlyMorning(act_type) then
			act_type = 0
		end
	-- 盟战星期二开
	elseif HefuActivityData.Instance:IsHeFuFirstGuildWar() then
		act_type = HEFU_SERVER_ACTIVITY_OPEN_LIST[1]
		if not self:GetActivityIsInEarlyMorning(act_type) then
			act_type = 0
		end		
	end
	local act_cfg = self:GetClockActivityByID(act_type)
	if act_cfg == nil or next(act_cfg) == nil then return end

	local open_time_str = Split(act_cfg.open_time, "|")
	local open_time_t = Split(open_time_str[1], ":")
	local open_hour, open_min = open_time_t[1], open_time_t[2]
	local day_open_second = open_hour * 3600 + open_min * 60

	local time_table = os.date("*t",TimeCtrl.Instance:GetServerTime())
	local cur_day_second = time_table.hour * 3600 + time_table.min*60 + time_table.sec
	if cur_day_second < day_open_second or is_next_day then
		time_table.hour = open_hour
		time_table.min = open_min
		time_table.sec = 0
		if is_next_day then
			time_table.day = time_table.day + 1
		end
		ActivityData.Instance:SetActivityStatus(act_type, ACTIVITY_STATUS.STANDY, os.time(time_table))
	end
end

function ActivityData.IsOpenServerSpecAct(act_type)
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	return nil ~= act_type and act_type == OPEN_SERVER_ACTIVITY_OPEN_LIST[cur_day]
end

function ActivityData:GetActivityHallDatalist()
	local data_list = {}
	local first_data_list = {}
	local scroll_sort_t = {}
	-- local second_list = {}
	-- local third_list = {}
	local num = 0
	local level = PlayerData.Instance.role_vo.level
	if CrazyMoneyTreeData and CrazyMoneyTreeData.Instance ~= nil and DailyRebateData and DailyRebateData.Instance ~= nil then
		for _,v in ipairs(FunInActHallView) do
			-- if OpenFunData.Instance:CheckIsHide(v.fun_name) and self:CanOpenSpecialAct(v.fun_name) then
			if v.type == ACTIVITY_TYPE.FUNC_TYPE_CLOTHE then
				local open_level = ClothespressData.Instance:GetOpenLevel()
				if level >= open_level then
					table.insert(first_data_list, v)
					num = num + 1
				end
			elseif v.type == ACTIVITY_TYPE.EVERYDAY_BACK_GOLD then	--天天返利
				local flag = (DailyRebateData.Instance:IsFetchAllDayReward() == true) and (DailyRebateData.Instance:IsFetchAllRareReward() == true)
				if flag == false then
					table.insert(first_data_list, v)
					num = num + 1
				end
			elseif v.type == ACTIVITY_TYPE.FUNC_TYPE_LONGXING and LongXingData and LongXingData.Instance and not LongXingData.Instance:IsFinishLongXing() then
				table.insert(first_data_list, v)
				num = num + 1
			end
			-- end
		end

		--疯狂摇钱树
		local gold = CrazyMoneyTreeData.Instance:GetMoney()
		local max_chongzhi_num = CrazyMoneyTreeData.Instance:GetMaxChongZhiNum()
		for k,v in pairs(self.activity_list) do
			local act_cfg = ActivityData.Instance:GetActivityConfig(v.type)
			if v.status == ACTIVITY_STATUS.OPEN and act_cfg and act_cfg.min_level <= level and act_cfg.is_inscroll == 1 then
				if v.type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHAKE_MONEY then
					v.sort_index = act_cfg.sort_index
					if gold ~= max_chongzhi_num then
						table.insert(data_list, v)
					end
				-- elseif v.type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LUCKY_WISH then
				-- 	table.insert(first_data_list, v)
				-- elseif v.type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BiPin_ACTIVITY then
				-- 	table.insert(second_list, v)
				-- elseif v.type == ACTIVITY_TYPE.RAND_DAILY_CHONGZHI_RANK or v.type == ACTIVITY_TYPE.RAND_DAILY_CONSUME_RANK then
				-- 	table.insert(third_list, v)
				elseif v.type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_REBATE then
					local flag = SingleRebateData.Instance:GetSingleRebateChargeFlag()
					v.sort_index = act_cfg.sort_index
					if flag <= 0 then
						table.insert(data_list, v)
					end
				elseif v.type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHONGZHI then
					local is_all_lingqu = SingleRechargeData.Instance:IsHaveAllChongzhiAndLingQu()
					v.sort_index = act_cfg.sort_index
					if not is_all_lingqu then
						table.insert(data_list, v)
					end
				elseif v.type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DOUBLE_GOLD then
					local is_have_weilingqu = DoubleGoldData.Instance:ListIsHaveWeiLingQu()
					if is_have_weilingqu then
						table.insert(data_list, v)
					end
				else
					v.sort_index = act_cfg.sort_index
					table.insert(data_list, v)
				end
			end
		end
	end

	for k,v in pairs(self.cross_activity_list) do
		local act_cfg = self:GetActivityConfig(v.type)
		if v.status == ACTIVITY_STATUS.OPEN and act_cfg and act_cfg.min_level <= level and act_cfg.is_inscroll == 1 then
			v.sort_index = act_cfg.sort_index
			table.insert(data_list, v)
			-- scroll_sort_t[v.type] = act_cfg.scroll_sort
			-- if not MainuiActivityHallData.Instance.SCROLL_CLICK_EFF[v.type] then
			-- 	MainuiActivityHallData.Instance.SCROLL_CLICK_EFF[v.type] = true
			-- end
		end
	end


	-- -- -- 根据活动号进行排序
	-- function sortfun(a, b)
	-- 	return a.type < b.type
	-- end
	-- table.sort(data_list, sortfun)
	-- for i,v in ipairs(second_list) do
	-- 	table.insert(first_data_list, v)
	-- end
	-- table.sort(third_list, SortTools.KeyLowerSorter("type"))
	-- for i,v in ipairs(third_list) do
	-- 	table.insert(first_data_list, v)
	-- end

 --    -- 特殊要求的放最前面
	for i,v in ipairs(data_list) do
		table.insert(first_data_list, v)
	end

	table.sort(first_data_list, SortTools.KeyUpperSorters("sort_index"))
	return first_data_list
end

-- 活动卷轴里面活动的红点特效
function ActivityData:SetActivityRedPointState(act_type,act_flag)
	local level = PlayerData.Instance.role_vo.level
	local act_cfg = ActivityData.Instance:GetActivityConfig(act_type)
	if act_flag and act_cfg and act_cfg.min_level > level then
		return
	end

	self.red_point_states[act_type] = act_flag
	MainUICtrl.Instance:FlushActivityRed()
	RemindManager.Instance:Fire(RemindName.ACTIVITY_JUAN_ZHOU)
end

-- 是否显示活动卷轴里面的活动红点
function ActivityData:GetActivityRedPointState(act_type)
	local remind_name = MainuiActivityHallData.DelayRemindList[act_type]
	if remind_name and ClickOnceRemindList[remind_name] == 0 and 
	 self.red_point_states and not self.red_point_states[act_type] then
		return false
	end
	
	if remind_name and RemindManager.Instance:GetOnceADayRemindList(remind_name) then
		return false
	end

	if self.red_point_states then
		return self.red_point_states[act_type] or false
	end
	return false
end

-- 获取活动卷轴里面的活动数量
function ActivityData:GetActivityRedPointNum()
	local act_num = 0
	for k,v in pairs(self.red_point_states) do
		act_num = act_num + 1
	end
	return act_num
end

-- 主界面是否显示活动卷轴红点
function ActivityData:IsShowRedPointJuan()
	if self.red_point_states and next(self.red_point_states) then
		for k,v in pairs(self.red_point_states) do
			if v then
				return 1
			end
		end
	end
	return 0
end

function ActivityData:GetActDayPassFromStart(activity_type)
	if nil == activity_type then
		return 0
	end
	local activity_status = self:GetActivityStatuByType(activity_type)
	local activity_day = -1
	if nil ~= activity_status and activity_status.start_time then
		local format_time_start = os.date("*t", activity_status.start_time)
		local end_zero_time_start = os.time{year=format_time_start.year, month=format_time_start.month, day=format_time_start.day, hour=0, min = 0, sec=0} or 0

		local format_time_now = os.date("*t", TimeCtrl.Instance:GetServerTime())
		local end_zero_time_now = os.time{year=format_time_now.year, month=format_time_now.month, day=format_time_now.day, hour=0, min = 0, sec=0} or 0
		local format_start_day = math.floor(end_zero_time_start / (60 * 60 * 24))
		local format_now_day =  math.floor(end_zero_time_now / (60 * 60 * 24))
		activity_day = format_now_day - format_start_day
	end
	return activity_day
end

function ActivityData:GetRandActivityConfig(cfg, type)
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local pass_day = self:GetActDayPassFromStart(type)
	local rand_t = {}
	local day = nil
	
	if cfg[0] and (nil == day or cfg[0].opengame_day == day) and (open_day - pass_day) <= cfg[0].opengame_day then
		day = cfg[0].opengame_day
		table.insert(rand_t, cfg[0])
	end

	for k,v in ipairs(cfg) do
		if v and (nil == day or v.opengame_day == day) and (open_day - pass_day) <= v.opengame_day then
			day = v.opengame_day
			table.insert(rand_t, v)
		end
	end
	return rand_t
end

-- 活动时间显示
function ActivityData:GetActTimeShow(time)
	if time > (24 * 3600) then
		return TimeUtil.FormatSecond2DHMS(time,5)
	elseif time > 3600 then
		return TimeUtil.FormatSecond(time, 14)
	else
		return TimeUtil.FormatSecond(time, 2)
	end
end

function ActivityData:SendActivityLogType(activity_type)
	self.activity_type = activity_type or 0
end

function ActivityData:SetActivityLogInfo(protocol)
	self.lucky_log[protocol.activity_type] = protocol
end

function ActivityData:GetActivityLogInfo()
	return self.lucky_log[self.activity_type] or {}
end

function ActivityData:GetXianMoItemCfg()
	local config = ConfigManager.Instance:GetAutoConfig("qunxianlundouconfig_auto").relive_pos
	return config or {}
end

function ActivityData:SetQunxianLuandouFirstRankInfo(protocol)
	self.first_rank = protocol.first_rank_num
	self.first_rank_uid = protocol.first_rank_uid
end

function ActivityData:GetQunxianLuandouFirstRankUid()
	return self.first_rank_uid or {}
end

function ActivityData:GetElementFirstRank()
	local rank_list = {}
	local count = 0
	for k,v in pairs(self.first_rank_uid) do
		if v > 0 then
			rank_list[k] = v
			count = count + 1
		end
	end
	return rank_list, count
end

function ActivityData:GetQunxianLuandouFirstRankInfo(protocol)
	return self.first_rank or {}
end

function ActivityData:SaveFirstRankRoleInfo(role_id, protocol)
	local info = {}
	info.appearance = {}
	info.prof = protocol.prof
	info.sex = protocol.sex
	info.appearance.mask_used_imageid = protocol.mask_info.used_imageid
	info.appearance.toushi_used_imageid = protocol.head_info.used_imageid
	info.appearance.yaoshi_used_imageid = protocol.waist_info.used_imageid
	info.appearance.qilinbi_used_imageid = protocol.arm_info.used_imageid
	info.appearance.shouhuan_used_imageid = protocol.upgrade_sys_info[UPGRADE_TYPE.SHOU_HUAN].used_imageid
	info.appearance.tail_used_imageid = protocol.upgrade_sys_info[UPGRADE_TYPE.TAIL].used_imageid

	local fashion_info = protocol.shizhuang_part_list[2]
	local wuqi_info = protocol.shizhuang_part_list[1]
	info.is_normal_fashion = fashion_info.use_special_img == 0
	info.is_normal_wuqi = wuqi_info.use_special_img == 0
	local fashion_id = fashion_info.use_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
	local wuqi_id = wuqi_info.use_special_img == 0 and wuqi_info.use_id or wuqi_info.use_special_img
	info.appearance.fashion_wuqi = wuqi_id
	info.appearance.fashion_body = fashion_id

	self.first_rank_role_info[role_id] = info
end

function ActivityData:GetFirstRankRoleInfo(role_id)
	return self.first_rank_role_info[role_id]
end

function ActivityData:GetCurActOpenInfo()
	if PlayerData.Instance.role_vo.level < ACTIVITY_PREVIEW_OPEN_LEVEL then
		return
	end
	local act_cfg = self:GetTodayActInfo()
	local openning_cfg = nil
	local server_time = TimeCtrl.Instance:GetServerTime()
	if act_cfg then
		for i, v in ipairs(act_cfg) do
			if v.open_time_stamp <= server_time and v.end_time_stamp >= server_time then
				openning_cfg = v
			end
		end
	end

	return openning_cfg
end

function ActivityData:GetNextActOpenInfo()
	if PlayerData.Instance.role_vo.level < ACTIVITY_PREVIEW_OPEN_LEVEL then
		return
	end
	local act_cfg = self:GetTodayActInfo()
	local server_time = TimeCtrl.Instance:GetServerTime()
	if act_cfg then
		for i, v in ipairs(act_cfg) do
			if v.open_time_stamp > server_time then
				return v
			end
		end
	end
	return
end

function ActivityData:GetRealOpenDay(activity_type)
	local server_time = TimeCtrl.Instance:GetServerTime()
	local now_weekday = tonumber(os.date("%w", server_time))
	if now_weekday == 0 then
		now_weekday = 7
	end

	local role_level = GameVoManager.Instance:GetMainRoleVo().level

	-- 做个缓存，防止一直调。这个方法调得非常恐怖，下面代码没法改
	local cache_t = self.check_realopen_day_week_day_t[activity_type]
	if nil == cache_t then
		cache_t = {}
		self.check_realopen_day_week_day_t[activity_type] = cache_t
	end
	if cache_t.now_weekday == now_weekday
		and cache_t.role_level == role_level
		and nil ~= cache_t.is_open_day then
		return cache_t.is_open_day
	end

	cache_t.now_weekday = now_weekday
	cache_t.role_level = role_level

	local list = {}
	if self.activity_cfg.other[1] == nil then
		cache_t.is_open_day = false
		return false
	end
	local part_num = self.activity_cfg.other[1].part_num


	if self.show_cfg and self.show_cfg[activity_type] then
		list = TableCopy(self.show_cfg[activity_type])
	end
	if part_num >= 1 then
		for i=1, part_num do
			if i == 1 then
				if list["min_level"] and list["max_level"] and tonumber(list["min_level"]) and tonumber(list["max_level"]) 
					and role_level >= tonumber(list["min_level"]) and role_level <= tonumber(list["max_level"]) then
					list.min_level = list["min_level"]
					list.max_level = list["max_level"]
					if list["open_day"] then
						list.open_day = list["open_day"]
					end
				end
			else
				if list["min_level_" .. i] and list["max_level_" .. i] and tonumber(list["min_level_" .. i]) and tonumber(list["max_level_" .. i]) 
					and role_level >= tonumber(list["min_level_" .. i]) and role_level <= tonumber(list["max_level_" .. i]) then
					list.min_level = list["min_level_" .. i]
					list.max_level = list["max_level_" .. i]
					if list["open_day_" .. i] then
						list.open_day = list["open_day_" .. i]
					end
				end
			end
		end
	end
	if next(list) ~= nil and tonumber(list.min_level) ~= nil and tonumber(list.max_level) ~= nil then
		if role_level < list.min_level or role_level > list.max_level then
			cache_t.is_open_day = false
			return false
		end
	end

	if activity_type == ACTIVITY_TYPE.SHUIJING or activity_type == ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_LIUJIE_BOSS then	--对特定活动进行开启日期显示限制
		if list.open_day then
			local open_day_list = Split(list.open_day, ":")
			for k,v in pairs(open_day_list) do
				if tonumber(v) == now_weekday then
					cache_t.is_open_day = true
					return true
				end
			end
		end
		cache_t.is_open_day = false
		return false
	end

	cache_t.is_open_day = true
	return true
end

function ActivityData:GetIsOtherDailyOpenExceptType(act_id)
	if self.show_cfg then
		for k,v in pairs(self.show_cfg) do
			if v.act_type ~= 999 and v.act_id ~= act_id then
				local activity_info = ActivityData.Instance:GetActivityStatuByType(v.act_id)
				local real_open = self:GetRealOpenDay(v.act_id)
				if ActivityData.Instance:GetIsOpenLevel(v.act_id) and activity_info and activity_info.status ~= ACTIVITY_STATUS.CLOSE and real_open then
					return true
				end
			end
		end
		return false
	end
end


function ActivityData:GetTodayActInfo()
	if self.last_check_level == GameVoManager.Instance:GetMainRoleVo().level
		and self.last_check_open_server_day == TimeCtrl.Instance:GetCurOpenServerDay() then
		return self.today_act_info_result_list
	end

	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local temp_list = {}
	local result_list = {}
	for k, v in pairs(self.show_type_list_cfg[ActivityData.Act_Type.normal]) do
		table.insert(temp_list, v)
	end

	for k, v in pairs(self.show_type_list_cfg[ActivityData.Act_Type.battle_field]) do
		table.insert(temp_list, v)
	end

	for k, v in pairs(self.show_type_list_cfg[ActivityData.Act_Type.kuafu_battle_field]) do
		table.insert(temp_list, v)
	end

	-- for k, v in pairs(self.show_type_list_cfg[ActivityData.Act_Type.custom_preview]) do
	-- 	table.insert(temp_list, v)
	-- end

	local act_info = ActivityData.Instance:GetActivityInfoById(ACTIVITY_TYPE.MOSHEN)
	table.insert(temp_list, act_info)

	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local server_time = TimeCtrl.Instance:GetServerTime()
	local now_weekday = tonumber(os.date("%w", server_time))
	if now_weekday == 0 then
		now_weekday = 7
	end

	for _,v in pairs(temp_list) do
		local act_t = v
		local open_day_list = Split(act_t.open_day, ":")
		local open_time_list = Split(act_t.open_time, "|")
		local end_time_list = Split(act_t.end_time, "|")

		local today_open = false
		for k, v in ipairs(open_day_list) do
			if tonumber(v) == now_weekday then
				today_open = true
			end
		end

		if tonumber(v.opensever_day) == tonumber(open_server_day) then 		--强制开启活动
			today_open = true
		elseif tonumber(v.opensever_day) > tonumber(open_server_day) then	--未到该活动的开启天数，禁止开启
			today_open = false
		end

		local level_enough = false
		if role_level >= v.min_level then
			level_enough = true
		end
		local is_real_openday = self:GetRealOpenDay(act_t.act_id)
		if today_open and level_enough and is_real_openday then
			for k,v in pairs(open_time_list) do
				if end_time_list[k] then
					local info = {}
					info.act_type = act_t.act_type
					info.act_id = act_t.act_id
					info.act_name = act_t.act_name
					info.open_time = v
					info.end_time = end_time_list[k]
					info.open_time_stamp = self:ChangeToStamp(v)
					info.end_time_stamp = self:ChangeToStamp(end_time_list[k])
					if self:IsAchieveLevelInLimintConfigById(act_t.act_id) then
						table.insert(result_list, info)
					elseif act_t.act_id == 10 then 						-- 世界Boss
						table.insert(result_list, info)
					elseif act_t.act_id == 3092 then 					--跨服边境
						table.insert(result_list, info)
					end
				end
			end
		end
	end
	table.sort(result_list, SortTools.KeyLowerSorter("open_time_stamp"))

	self.today_act_info_result_list = result_list
	self.last_check_level = role_level
	self.last_check_open_server_day = open_server_day

	return result_list
end

function ActivityData:ChangeToStamp(time_str)
	local server_time = TimeCtrl.Instance:GetServerTime()
	local time_tb = Split(time_str, ":")
	local tab = os.date("*t", server_time)
	tab.hour = tonumber(time_tb[1])
	tab.min = tonumber(time_tb[2])
	tab.sec = 0
	local stamp = os.time(tab) or 0
	return stamp
end

function ActivityData:GetCurActivityCountDownStr()
	local cfg = self:GetCurActOpenInfo()
	if nil == cfg then
		return ""
	end
	local server_time = TimeCtrl.Instance:GetServerTime()
	local act_end_time = cfg.end_time_stamp
	local countdown_time = math.floor(act_end_time - server_time)
	if countdown_time < 0 then
		return ""
	end

	local str = ""
	local hour = math.floor(countdown_time / 3600)
	if hour >= 1 then
		str = string.format(Language.Common.AfterHourOpen, hour)
	else
		str = TimeUtil.FormatSecond2MS(countdown_time)
	end

	return str
end

function ActivityData:GetRealLevelLimit(act_id)
	local act_info = self:GetClockActivityByID(act_id)
	if act_info == nil then
		return
	end
	local act_info_list = TableCopy(act_info)
	if self.activity_cfg.other[1] == nil then
		return
	end
	local part_num = self.activity_cfg.other[1].part_num
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	if part_num >= 1 then
		for i=1, part_num do
			if i == 1 then
				if act_info_list["min_level"] and act_info_list["max_level"] and tonumber(act_info_list["min_level"]) and tonumber(act_info_list["max_level"]) 
					and role_level >= tonumber(act_info_list["min_level"]) and role_level <= tonumber(act_info_list["max_level"]) then
					act_info_list.min_level = act_info_list["min_level"]
					act_info_list.max_level = act_info_list["max_level"]
				end
			else
				if act_info_list["min_level_" .. i] and act_info_list["max_level_" .. i] and tonumber(act_info_list["min_level_" .. i]) and tonumber(act_info_list["max_level_" .. i]) 
					and role_level >= tonumber(act_info_list["min_level_" .. i]) and role_level <= tonumber(act_info_list["max_level_" .. i]) then
					act_info_list.min_level = act_info_list["min_level_" .. i]
					act_info_list.max_level = act_info_list["max_level_" .. i]
				end
			end
		end
	end
	return act_info_list.min_level, act_info_list.max_level
end

function ActivityData:GetActivityRealOpenDay(act_id)
	local act_info = self:GetClockActivityByID(act_id)
	if act_info == nil then
		return
	end

	local act_info_list = TableCopy(act_info)
	if self.activity_cfg.other[1] == nil then
		return
	end
	local part_num = self.activity_cfg.other[1].part_num
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	if part_num >= 1 then
		for i=1, part_num do
			if i == 1 then
				if act_info_list["min_level"] and act_info_list["max_level"] and tonumber(act_info_list["min_level"]) and tonumber(act_info_list["max_level"]) 
					and role_level >= tonumber(act_info_list["min_level"]) and role_level <= tonumber(act_info_list["max_level"]) then
					if act_info_list["open_day_" .. i] then
						act_info_list.open_day = act_info_list["open_day_" .. i]
					end
				end
			else
				if act_info_list["min_level_" .. i] and act_info_list["max_level_" .. i] and tonumber(act_info_list["min_level_" .. i]) and tonumber(act_info_list["max_level_" .. i]) 
					and role_level >= tonumber(act_info_list["min_level_" .. i]) and role_level <= tonumber(act_info_list["max_level_" .. i]) then
					if act_info_list["open_day_" .. i] then
						act_info_list.open_day = act_info_list["open_day_" .. i]
					end
				end
			end
		end
	end
	return act_info_list.open_day
end

function ActivityData:GetMinestLevelLimit(act_id)
	local act_info = self:GetClockActivityByID(act_id)
	if act_info == nil then
		return
	end
	local act_info_list = TableCopy(act_info)
	if self.activity_cfg.other[1] == nil then
		return
	end
	local part_num = self.activity_cfg.other[1].part_num
	local minest_level = nil
	if part_num >= 1 then
		for i=1, part_num do
			if i == 1 then
				if act_info_list["min_level"] and tonumber(act_info_list["min_level"]) then
					if minest_level == nil or minest_level > act_info_list["min_level"] then
						minest_level = act_info_list["min_level"]
					end
				end
			else
				if act_info_list["min_level_" .. i] and tonumber(act_info_list["min_level_" .. i]) then
					if minest_level == nil or minest_level > act_info_list["min_level_" .. i] then
						minest_level = act_info_list["min_level_" .. i]
					end
				end
			end
		end
	end
	return minest_level
end

--获得今日开启的活动，并且开启中放前面，已结束放后面
function ActivityData:GetTodayActInfoSort()
	local server_time = TimeCtrl.Instance:GetServerTime()
	local today_act_list = self:GetTodayActInfo()
	if today_act_list then
		for i,v in ipairs(today_act_list) do
			if server_time >= v.open_time_stamp and server_time <= v.end_time_stamp then --开启中
				today_act_list[i].state = ActivityData.ActState.OPEN
			elseif server_time > v.end_time_stamp then 	--已结束
				today_act_list[i].state = ActivityData.ActState.CLOSE
			else 										--未开启
				today_act_list[i].state = ActivityData.ActState.WAIT
			end
			if v and (v.act_type ~= ActivityData.Act_Type.boss or v.act_id ~= 3092) then
				if not self:IsAchieveLevelInLimintConfigById(v.act_id) then
					if server_time >= v.open_time_stamp then
						today_act_list[i].state = ActivityData.ActState.CLOSE
					else
						today_act_list[i].state = ActivityData.ActState.WAIT
					end
				end
			end
		end
	end
	table.sort(today_act_list, SortTools.KeyLowerSorter("state", "open_time_stamp", "act_id"))
	return today_act_list
end

function ActivityData:GetIsOpenLevel(id)
	local is_reach_level = true
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local min_level, max_level = self:GetRealLevelLimit(id)
	local is_rearch_limit = true
	if min_level and type(min_level) == 'number' then
		is_reach_level = role_level >= min_level and role_level <= max_level
	end
	if ACTIVITY_ENTER_LIMIT_LIST[id] then
		if OPEN_DAY_SERVER_ACTIVITY_OPEN_LIST[id] then
			local cur_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
			if cur_open_day <= 1 then
				if id == ACTIVITY_TYPE.QUNXIANLUANDOU or id == ACTIVITY_TYPE.GUILDBATTLE then
					is_rearch_limit = true
				else
					is_rearch_limit = false
				end
			elseif cur_open_day <= 2 then
				if id == ACTIVITY_TYPE.GUILDBATTLE or id == ACTIVITY_TYPE.GONGCHENGZHAN then
					is_rearch_limit = true
				else
					is_rearch_limit = false
				end
			elseif cur_open_day <= 3 then
				if id == ACTIVITY_TYPE.GONGCHENGZHAN then
					is_rearch_limit = true
				else
					is_rearch_limit = false
				end
			else
				is_rearch_limit = self:IsAchieveLevelInLimintConfigById(id)
			end
		else
			is_rearch_limit = self:IsAchieveLevelInLimintConfigById(id)
		end
	end
	local flag = is_rearch_limit and is_reach_level
	return flag
end

--跨服随机活动
function ActivityData:SetCrossRandActivityStatus(activity_type, status, start_time, end_time)
	self.cross_activity_list[activity_type] = {
		["type"] = activity_type,
		["status"] = status,
		["start_time"] = start_time,
		["end_time"] = end_time,
		["next_time"] = end_time,
		["sort_index"] = 0,
		}

	for k, v in pairs(self.act_change_callback) do
		v(activity_type, status, end_time)
	end
end

function ActivityData:GetCrossRandActivityStatusByType(activity_type)
	return self.cross_activity_list[activity_type]
end

function ActivityData:GetCrossRandActivityIsOpenByType(activity_type)
	local activity_info = self:GetCrossRandActivityStatusByType(act_type)

	if nil ~= activity_info and ACTIVITY_STATUS.OPEN == activity_info.status then
		return true
	end
	return false
end

-- 根据等级判断活动能否显示(只判断等级下限)
function ActivityData:CanShowActivityByLevelFloor(act_id, level)
	local cfg = self:GetActivityInfoById(act_id)
	if nil == cfg or nil == cfg.min_level then
		return true
	end

	if not level then
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		level = main_vo.level
	end
	if level >= cfg.min_level then
		return true
	end

	return false
end

--增加一个活动信息到随机活动列表中
function ActivityData:AddCrossActivityInfo(protocol)
	local tab = {
		activity_type = protocol.activity_type,
		status = protocol.status,
		begin_time = protocol.begin_time,
		end_time = protocol.end_time,
	}
	if tab.status == ACTIVITY_STATUS.CLOSE then
		self.cross_activity_info_list[tab.activity_type] = nil
	else
		self.cross_activity_info_list[tab.activity_type] = tab
	end
end

function ActivityData:GetCrossActivityInfoList()
	return self.cross_activity_info_list
end

-- 根据活动类型获取拜谒配置数据
function ActivityData:GetBaiJieCfgByActivityType(activity_type)
	local worship_cfg = ConfigManager.Instance:GetAutoConfig("worship_auto").other
	for k,v in pairs(worship_cfg) do
		if v.activityde_type == activity_type then
			return v
		end
	end
end

function ActivityData:GetIsInListByID(scene_type)
	local activity_type = WORSHIP_SCENE_TYPE[scene_type]
	local worship_cfg = self:GetBaiJieCfgByActivityType(activity_type)
	local is_click = false
	if worship_cfg then
		local num = math.random(1, 100)
		is_click = num <= worship_cfg.probability
	end
	return is_click
end

function ActivityData:GetBubbleContentListById(activity_type)
	local worship_bubble_cfg = ConfigManager.Instance:GetAutoConfig("worship_auto").bubble_content
	local list = {}
	if worship_bubble_cfg then
		for k,v in pairs(worship_bubble_cfg) do
			if v.activityde_type == activity_type then
				table.insert(list, v)
			end
		end
	end
	return list
end

function ActivityData:GetBubbleContentById(scene_type)
	local activity_type = WORSHIP_SCENE_TYPE[scene_type]
	local bubble_list = self:GetBubbleContentListById(activity_type)
	local content = {}
	if bubble_list and #bubble_list > 0 then
		local num = math.random(1, #bubble_list) or 1
		content = bubble_list[num]
	end
	return content
end

-- 获取活动剩余时间,结束时间
function ActivityData:GetCrossRandActivityResidueTime(act_type)
	local time = 0
	local next_time = 0
	local activity = self:GetCrossRandActivityStatusByType(act_type)
	if activity then
		next_time = activity.next_time
		time = activity.next_time - TimeCtrl.Instance:GetServerTime()
	end
	return time, next_time
end

function ActivityData:GetActivityLimintConfig()
	if self.join_limit_config then
		return self.join_limit_config.join_limit
	end
end

function ActivityData:IsAchieveLevelInLimintConfigById(id)
	local limint_config = self:GetActivityLimintConfig()
	if limint_config then
		local cur_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
		local level = GameVoManager.Instance:GetMainRoleVo().level or 0
		local server_time = TimeCtrl.Instance:GetServerTime()
		local week_day = tonumber(os.date("%w",server_time)) or 0
		if week_day == 0 then
			week_day = 7
		end
		for k,v in pairs(limint_config) do
			if v and v.type == 1 and v.sub_type == id then
				if type(v.level_range_vec)=='number' and v.level_range_vec <= 0 then 
					return true
				end
				if not string.find(v.level_range_vec, ",") then
					return true
				end
				local level_range = Split(v.level_range_vec, "|")
				local open_day_vec = Split(v.open_day_vec_vec, "|")
				local open_server_day_range = Split(v.open_server_day_range_vec, "|")
				if level_range and open_day_vec and open_server_day_range then
					for i = 1, #level_range do
						local level_range_list = level_range[i] and Split(level_range[i], ",") or {}
						local level_min = level_range_list[1] or 0
						local level_max = level_range_list[2] or 0
						local flag1 = level >= tonumber(level_min) and level <= tonumber(level_max)

						local open_server_day_range_list = open_server_day_range[i] and Split(open_server_day_range[i], ",") or {}
						local open_day_min = open_server_day_range_list[1] or 0
						local open_day_max = open_server_day_range_list[2] or 0
						local flag2 = cur_open_day >= tonumber(open_day_min) and cur_open_day <= tonumber(open_day_max)

						local open_week_day_list = open_day_vec[i] and Split(open_day_vec[i], ",") or {}
						local flag3 = self:GetNumIsINList(week_day, open_week_day_list)
						local flag = flag1 and flag2 and flag3
						if flag then
							return true
						end
					end
				end
			end
		end
	end
	return false
end

function ActivityData:GetNumIsINList(num, list)
	if num and list then
		for k,v in pairs(list) do
			if v and tonumber(v) == num then
				return true
			end
		end
	end
	return false
end

function ActivityData:GetOpenWeekDay(id)
	local limint_config = self:GetActivityLimintConfig()
	if limint_config then
		local cur_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
		local level = GameVoManager.Instance:GetMainRoleVo().level or 0
		for k,v in pairs(limint_config) do
			if v and v.type == 1 and v.sub_type == id then
				local level_range = Split(v.level_range_vec, "|")
				local open_day_vec = Split(v.open_day_vec_vec, "|")
				local open_server_day_range = Split(v.open_server_day_range_vec, "|")
				if type(v.level_range_vec)=='number' and v.level_range_vec <= 0 then 
					return false, 0, {}
				end
				if level_range and open_server_day_range and open_day_vec  then
					for i = 1, #level_range do
						local level_range_list = level_range[i] and Split(level_range[i], ",") or {}
						local level_min = level_range_list[1] or 0
						local level_max = level_range_list[2] or 0
						local flag1 = level >= tonumber(level_min) and level <= tonumber(level_max)

						local open_server_day_range_list = open_server_day_range[i] and Split(open_server_day_range[i], ",") or {}
						local open_day_min = open_server_day_range_list[1] or 0
						local open_day_max = open_server_day_range_list[2] or 0
						local flag2 = cur_open_day >= tonumber(open_day_min) and cur_open_day <= tonumber(open_day_max)
						if flag1 and flag2 then
							local open_week_day_list = open_day_vec[i] and Split(open_day_vec[i], ",") or {}
							return true, #open_week_day_list, open_week_day_list
						end
					end
				end
			end
		end
	end
	return false, -1, {}
end


function ActivityData:GetChineseWeek(act_info)
	local open_time_tbl = Split(act_info.open_time, "|")
	local end_time_tbl = Split(act_info.end_time, "|")
	local open_day_list = Split(act_info.open_day, ":")
	local time_des = ""

	if #open_day_list >= 7 then
		if #open_time_tbl > 1 then
			local time_str = ""
			for i = 1, #open_time_tbl do
				if i == 1 then
					time_str = string.format("%s-%s", open_time_tbl[1], end_time_tbl[1])
				else
					time_str = string.format("%s,%s-%s", time_str, open_time_tbl[i], end_time_tbl[i])
				end
			end
			time_des = string.format("%s %s", Language.Activity.EveryDay, time_str)
		else
			time_des = string.format("%s %s-%s", Language.Activity.EveryDay, act_info.open_time, act_info.end_time)
		end
	else
		local week_str = ""
		for k, v in ipairs(open_day_list) do
			local day = tonumber(v)
			if k == 1 then
				week_str = string.format("%s%s", Language.Activity.WeekDay, Language.Common.DayToChs[day])
			else
				week_str = string.format("%s、%s", week_str, Language.Common.DayToChs[day])
			end
		end
		if #open_time_tbl > 1 then
			local time_str = ""
			for i = 1, #open_time_tbl do
				if i == 1 then
					time_str = string.format("%s-%s", open_time_tbl[1], end_time_tbl[1])
				else
					time_str = string.format("%s,%s-%s", time_str, open_time_tbl[i], end_time_tbl[i])
				end
			end
			time_des = string.format("%s %s", week_str, time_str)
		else
			time_des = string.format("%s %s-%s", week_str, act_info.open_time, act_info.end_time)
		end
	end
	return time_des
end

function ActivityData:GetLimintOpenDayTextByActId(id, act_info, time_des)
	local text = ""
	if id and act_info then
		local is_open, list_num, list = self:GetOpenWeekDay(id)
		if is_open and list_num then
			if list_num >= 7 then
				text = string.format("%s %s-%s", Language.Activity.EveryDay, act_info.open_time, act_info.end_time)
			else
				local str = ""
				for i = 1,list_num do
					if list[i] then
						local day = tonumber(list[i])
						if i == 1 then
							str = string.format("%s%s", Language.Activity.WeekDay, Language.Common.DayToChs[day])
						else
							str = string.format("%s、%s", str, Language.Common.DayToChs[day])
						end
					end
				end
				text = string.format("%s %s-%s", str, act_info.open_time, act_info.end_time)
			end
		else
			if list_num >= 0 then
				text = time_des
			else
				text = ""
			end
		end
	end
	return text
end

function ActivityData:GetCurServerOpenDayText(activity_type, act_info) 			--4个活动预告的时间展示
	local time_des = ""
	if activity_type and act_info then
		local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(activity_type)
		local server_time = TimeCtrl.Instance:GetServerTime()
		local now_day_open_time = TimeUtil.NowDayTimeEnd(server_time)
		local time = next_time - now_day_open_time
		if time > 0 then
			if time > 24 * 3600 then
				local num = tonumber(os.date("%w",next_time))
				local weekday = num <= 0 and 7 or num
				local str = Language.Common.DayToChs[weekday]
				time_des = string.format(Language.Activity.LongDayOpen, str, act_info.open_time)
			else
				time_des = string.format(Language.Activity.NextDayOpen, act_info.open_time)
			end
		else
			time_des = string.format(Language.Activity.NowDayOpen, act_info.open_time)
		end
	end
	return time_des
end

function ActivityData:GetNearGuildActivity()
	local today_open_activity = self:GetTodayActInfo()
	local server_time = TimeCtrl.Instance:GetServerTime()
	if today_open_activity then
		for k,v in ipairs(today_open_activity) do
			if v and GUILD_ACTIVITY_LIST[v.act_id] then
				local time_stamp = v.open_time_stamp - server_time
				if time_stamp > 0 then--and time_stamp <= 2 * 3600 then
					return v
				end
				if v.open_time_stamp <= server_time and v.end_time_stamp >= server_time then
					return v
				end
			end
		end
	end
	return {}
end

function ActivityData:AddToRewardList(protocol)
	if self.activity_reward_list[protocol.activity_id] == nil then
		self.activity_reward_list[protocol.activity_id] = {}
		table.insert(self.activity_reward_id_list, protocol.activity_id)
	end

	local data_copy = TableCopy(protocol)
	-- self.activity_reward_list[protocol.activity_id][protocol.reward_type] = {}
	self.activity_reward_list[protocol.activity_id][protocol.reward_type] = data_copy
end

function ActivityData:UpdateActivityRewardInfo()
	local temp_activity_id = nil
	if self.activity_reward_list and self.activity_reward_id_list[1] and self.activity_reward_list[self.activity_reward_id_list[1]] then
		for k,v in pairs(self.activity_reward_list[self.activity_reward_id_list[1]]) do
			if temp_activity_id == nil then
				temp_activity_id = v.activity_id
			end
			self:SetSetActivityRewardInfo(v)
		end

		table.remove(self.activity_reward_list, self.activity_reward_id_list[1])
		self.activity_reward_list[temp_activity_id] = nil
		table.remove(self.activity_reward_id_list, 1)
	end

	local num = self:CheckActivityRewardListNum()
	if num <= 0 then
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.ActivityReward, false)
	else
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.ActivityReward, true)
	end
end

function ActivityData:CheckActivityRewardListNum()
	return #self.activity_reward_id_list
end

function ActivityData:SetSetActivityRewardInfo(protocol)
	local activity_id = protocol.activity_id
	local reward_type = protocol.reward_type

	if self.activity_id ~= activity_id or self.activity_id == 0 then
		self.activity_reward_info = {}
	end

	self.activity_id = activity_id
	self.activity_reward_info.activity_id = activity_id
	self.activity_reward_info.param = protocol.param

	self.activity_reward_info[reward_type] = {}
	if activity_id == ACTIVITY_TYPE.GONGCHENGZHAN then --攻城战特殊处理夫君夫人 如果顺序改变再提
		if reward_type == ACTIVITY_REWARD_TYPE.REWARD_TYPE_TITLE then
			if self.activity_reward_info[reward_type].reward_id and self.activity_reward_info[reward_type].reward_id > protocol.reward_id then
				self.activity_reward_info[reward_type].reward_id = self.activity_reward_info[reward_type].reward_id
			else
				self.activity_reward_info[reward_type].reward_id = protocol.reward_id
			end
		else
			self.activity_reward_info[reward_type].reward_id = protocol.reward_id
		end
	else
		self.activity_reward_info[reward_type].reward_id = protocol.reward_id
	end
end

function ActivityData:ClearActivityReward()
	self.activity_reward_info = {}
end

function ActivityData:GetSetActivityRewardInfo()
	return self.activity_reward_info
end

function ActivityData:SetActivityStatusCacheData(activity_type, activity_status)
	self.activity_status_cache_data[activity_type] = activity_status
end

function ActivityData:GetActivityStatusCacheData(activity_type)
	return self.activity_status_cache_data[activity_type]
end
