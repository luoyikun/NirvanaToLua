GuildData = GuildData or BaseClass()

CREATE_GUILD_LIMIT_LEVEL = 80
GUILD_SKILL_COUNT = 7
GUILD_MAX_EXCHANGE_ITEM_COUNT = 30
TWEEN_TIME = 0.5											--切入动画时间
ADD_GUILD_EXP_TYPE = {
	ADD_GUILD_EXP_TYPE_INVALID = 0,
	ADD_GUILD_EXP_TYPE_GOLD = 1,                            -- 元宝捐献
	ADD_GUILD_EXP_TYPE_ITEM = 2,                            -- 物品捐献
	ADD_GUILD_EXP_TYPE_MAX = 3,
}

GUILD_STORGE_OPERATE =
{
	GUILD_STORGE_OPERATE_PUTON_ITEM = 1,            -- 放入
	GUILD_STORGE_OPERATE_TAKE_ITEM = 2,             -- 取出
	GUILD_STORGE_OPERATE_REQ_INFO = 3,              -- 查询
	GUILD_STORGE_OPERATE_DISCARD_ITEM = 4,          -- 销毁
}

GUILD_SKILL_UP_LEVEL_TYPE =
{
	GUILD_SKILL_UP_LEVEL = 0,
	GUILD_SKILL_UP_LEVEL_ALL = 1,
};

GUILD_STORGE_ONE_KEY_OPERATE =
{
	GUILD_STORGE_OPERATE_PUTON_ITEM_ONE_KEY = 1,    -- 批量放入
	GUILD_STORGE_OPERATE_DISCARD_ITEM_ONE_KEY = 2,  -- 批量销毁
}

GHILD_BOSS_OPER_TYPR = {
	GUILD_BOSS_UPLEVEL = 0,
	GUILD_BOSS_CALL = 1,
	GUILD_BOSS_INFO_REQ = 2,
}

GHILD_OPERA_TYPE = {
	OPERA_TYPE_INVALID = 0,
	OPERA_TYPE_APPLY_SET = 1,
	OPERA_TYPE_CALL_IN = 2,
}

Guild_PANEL = {
	information = 1,
	member = 2,
	box = 3,
	altar = 4,
	totem = 5,
	territory = 6,
	list = 7,
	boss = 8,
	maze = 11,
}

GUILD_BOX_OPERATE_TYPE =
{
	GBOT_QUERY_SELF = 0,
	GBOT_UPLEVEL = 1,
	GBOT_OPEN = 2,
	GBOT_FETCH = 3,
	GBOT_QUERY_NEED_ASSIST = 4,
	GBOT_ASSIST = 5,
	GBOT_CLEAN_ASSIST_CD = 6,
	GBOT_INVITE_ASSIST = 7,
	GBOT_THANK_ASSIST = 8,
}

GuildData.TweenPosition = {
	Up = Vector3(440, 480, 0),
	Right = Vector3(729, 0, 0),
	Down = Vector3(-100, -832, 0),
}

GuildData.WarTweenPosition = {
	Up = Vector3(-52, 20, 0),
	Down = Vector3(-52, -432, 0),
}

GuildData.MemberTweenPosition = {
	Up = Vector3(-57, -50, 0),
	Down = Vector3(-52, -432, 0),
}

GuildData.BoxTweenPosition = {
	Up = Vector3(-50, 480, 0),
	Down = Vector3(0, -432, 0),
}

GuildData.AltarTweenPosition = {
	Left = Vector3(-729, -23, 0),
	Down = Vector3(0, -432, 0),
}

GuildData.ActTweenPosition = {
	Left = Vector3(-201.5, 201, 0),
	Right = Vector3(611, 0, 0),
}


GUILD_STORGE_LEVEL =
{
	500, 400, 300, 200, 1000
}

-- 领地站奖励
GUID_TERRITORY_WELF_OPERATE_TYPE =
{
	GTW_FETCH_REWARD = 0,           -- 普通奖励
	GTW_FETCH_EXTRA_REWARD = 1,     -- 会长奖励
}

-- 扩展成员请求
GUILD_EXTEND_OPERATE_TYPE =
{
	EXTEND_MEMBER = 0,              -- 扩展成员
	MEMBER_MAX_COUNT_INFO = 1,      -- 请求最大成员信息
}

GuildData.SinginRewardState = {
	CanNotGetReward = 1,    -- 不能领取
	CanGetReward = 2,       -- 可以领取
	HasGetReward = 3,       -- 已领取
}

 -- 仙盟仓库操作类型
GuildData.GUILD_STORE_OPTYPE =
{
	GUILD_STORE_OPTYPE_TAKEOUT = 0,    --兑换了
	GUILD_STORE_OPTYPE_PUTIN = 1,      --捐献了
}

GuildData.SigninRewardNum = 3

GUILD_MAX_BOX_LEVEL = 4

function GuildData:__init()
	if GuildData.Instance then
		print_error("[GuildData] Attempt to create singleton twice!")
		return
	end
	GuildData.Instance = self
	self.guild_id = -1

	self.guild_skill_config = nil

	self.role_info = {skill_level_list = {}, territorywar_reward_flag = {}, daily_guild_gongxian = 0}

	self.guild_total_gongxian = 0
	self.box_color = ""
	self.box_free_count = ""
	self.box_up_count = ""
	self.box_is_free = false

	self.red_point_list = {}

	self.box_info = {
		uplevel_count = 0,
		assist_count = 0,
		assist_cd_end_time = 0,
		info_list = {},
	}

	self.assist_info = {
		box_count = 0,
		info_list = {},
	}

	self.boss_info = {
		boss_normal_call_count = 0,
		boss_super_call_count = 0,
		boss_level = 0,
		boss_exp = 0,
		boss_super_call_uid = 0,
		boss_super_call_name = "",
		rank_list = {},
	}

	self.gongzi_list = {
		guild_id = 0,
		member_list = {},
	}

	self.guild_post = {
		"PuTong",
		"ZhangLao",
		"FuMengZhu",
		"MengZhu",
		"JingYing",
		"HuFa"
	}
	self.guild_storge_info = {storge_item_list = {}}
	self.fu_li_count = 0
	self.last_leave_guild_time = 0
	self.is_can_assist = false
	self.is_guild_box_start = true
	self.other_guild_info = {}
	self.territory_rank = 0
	self.tree_rank_info = {}
	self.guild_info_statistic_list = {}
	self.guild_info_list = {}
	self.gong_xian_config = {}
	self.territory_welf_config = nil
	local guild_config = self:GetGuildConfig()
	if guild_config then
		self.territory_welf_config = guild_config.territory_welf_config
		if self.territory_welf_config then
			self.gong_xian_config[1] = self.territory_welf_config[1].banggong_one_limit
			self.gong_xian_config[2] = self.territory_welf_config[1].banggong_two_limit
			self.gong_xian_config[3] = self.territory_welf_config[1].banggong_three_limit
			self.gong_xian_config[4] = self.territory_welf_config[1].banggong_four_limit
		end
	end

	self.bon_fire_openstatus = 0
	self.mi_jing_openstatus = 0
	self.moneytreeicon = 0
	self.moneytree_gather_type = 0
	self.moneytree_rank = 0
	self.moneytree_state = false
	self.moneytree_pos = {}
	self.moneytree_info = {}
	self.moneytree_num_info = {}
	self.moneytree_reward = {}
	self.guild_event_list = {}
	self.guild_event_count = 0
	self.guild_warehouse_log_list = {}

	self.boss_activity_info = {
		boss_id = 0,
		boss_level = 0,
		boss_obj_id = 0,
		is_surper_boss = 0,
		totem_exp = 0,
		cur_star_level = 0,
		gather_num = 0,
		next_change_star_time = 0,
	}
	self.last_callin_time = -10

	self.red_pocket_list = {}                                       --红包列表
	self.red_pocket_num = 0                                         --红包个数
	self.red_pocket_distribute = {}                                 --红包详细列表
	self.next_red_index = -1
	self.save_list = {}

	self.max_skill_level = 0
	self.maze_help_cd = 0
	local other_config = self:GetOtherConfig()
	if other_config then
		self.max_skill_level = other_config.max_skill_level or 0
		self.maze_help_cd = other_config.maze_help_cd or 0
	end

	self.daily_use_guild_relive_times = 0
	self.daily_boss_redbag_reward_fetch_flag = 0
	self.guild_shake_state = false

	self.maze_info = {
		reason = 0,
		layer = 0,
		complete_time = 0,
		cd_end_time = 0,
		max_layer = 0,
	}

	self.maze_rank_info = {
		rank_count = 0,
		rank_list = {},
	}

	self.signin_data = {
		is_signin_today = -1,                        -- 今天是否已签到
		signin_count_month = 0,                     -- 月签到次数
		guild_signin_fetch_reward_flag = 0,         -- 工会总签到
		guild_signin_count_today = 0,               -- 工会总签到次
	}
	-- 仙盟答题
	self.player_info = {
		exp = 0,
		guild_gongxian = 0,
	}
	self.question_info = {}
	self.question_rank_info = {}
	self.tuanzhang_info = {}
	self.fall_msg_data = {}
	self.fall_unread_msg = {}

	-- RemindManager.Instance:Register(RemindName.Guild, BindTool.Bind(self.GetGuildRemind, self))
	RemindManager.Instance:Register(RemindName.NoGuild, BindTool.Bind(self.GetNoGuildRemind, self))
	RemindManager.Instance:Register(RemindName.GuildMaze, BindTool.Bind(self.GetMazeRemind, self))
	-- RemindManager.Instance:Register(RemindName.GuildSignin, BindTool.Bind(self.GetSigninRemind, self))
	RemindManager.Instance:Register(RemindName.GuildHead, BindTool.Bind(self.GetGuildHeadRemind, self))
	RemindManager.Instance:Register(RemindName.GuildRedPacket, BindTool.Bind(self.GetRedPacketRemindNum, self))
	RemindManager.Instance:Register(RemindName.GuildOperate, BindTool.Bind(self.GetRedOperate, self))
	RemindManager.Instance:Register(RemindName.GuildDonation, BindTool.Bind(self.GetRedDonate, self))
	RemindManager.Instance:Register(RemindName.GuildBox, BindTool.Bind(self.GetBoxCount, self))
	RemindManager.Instance:Register(RemindName.GuildAltar, BindTool.Bind(self.GetAltarCount, self))
	RemindManager.Instance:Register(RemindName.GuildWar, BindTool.Bind(self.GetGuildWarRewardRedPoint, self))
	RemindManager.Instance:Register(RemindName.GuildWage, BindTool.Bind(self.GetGuildWageRedPoint, self))

	self.hug_state = 0
	self.gather_type = 0
end

function GuildData:__delete()
	self.tuanzhang_info = {}
	-- RemindManager.Instance:UnRegister(RemindName.Guild)
	RemindManager.Instance:UnRegister(RemindName.NoGuild)
	RemindManager.Instance:UnRegister(RemindName.GuildMaze)
	-- RemindManager.Instance:UnRegister(RemindName.GuildSignin)
	RemindManager.Instance:UnRegister(RemindName.GuildHead)
	RemindManager.Instance:UnRegister(RemindName.GuildRedPacket)
	RemindManager.Instance:UnRegister(RemindName.GuildOperate)
	RemindManager.Instance:UnRegister(RemindName.GuildDonation)
	RemindManager.Instance:UnRegister(RemindName.GuildBox)
	RemindManager.Instance:UnRegister(RemindName.GuildAltar)
	RemindManager.Instance:UnRegister(RemindName.GuildWar)
	GuildData.Instance = nil

	if self.count_down then
		GlobalTimerQuest:CancelQuest(self.count_down)
		self.count_down = nil
	end
end

GuildDataConst = {
	GUILDVO = {                                                     -- 公会信息
		guild_id = 0,
		guild_name = "",
		guild_post = 0,
		guild_level = 0,
		guild_exp = 10,
		guild_max_exp = 100,
		guild_totem_level = 0,
		guild_totem_exp = 0,
		cur_member_count = 0,
		max_member_count = 0,
		tuanzhang_uid = 0,
		tuanzhang_name = "",
		create_time = 0,
		camp = 0,
		vip_level = 0,
		applyfor_setup = 0,
		guild_notice = "",
		auto_kickout_setup = 0,
		applyfor_need_capability = 0,
		applyfor_need_level = 0,
		guild_callin_times = 0,
		my_lucky_color = 1,
		active_degree = 0,
		total_capability = 0,
		rank = 0,
		totem_exp_today = 0,
		daily_relive_times = 0,
		daily_kill_boss_times = 0,
		is_auto_clear = 0,
		avater_changed = 0,
		guild_avatar_key_big = 0,
		guild_avatar_key_small = 0,
		guild_total_gongzi = 0,
	},
	GUILD_INFO_LIST = {                                             -- 所有公会信息列表
		free_create_guild_times = 0,                                -- 免费创建次数
		is_first = 0,
		count = 0,
		list = {},
		is_server_backed = false
	},
	GUILD_MEMBER_LIST = {                                          -- 所有公会成员信息
		count = 0,
		list = {},
	},
	GUILD_POST = {
		CHENG_YUAN = 1,                                                 -- 成员
		ZHANG_LAO = 2,                                                  -- 长老
		FU_TUANGZHANG = 3,                                              -- 副团长
		TUANGZHANG = 4,                                                 -- 团长
		JINGYING = 5,                                                   -- 精英成员
		HUFA = 6,                                                       -- 护法
	},
	GUILD_POST_WEIGHT = {
		1, 4, 5, 6, 2, 3,
	},
	GUILD_APPLYFOR_LIST = {                                         -- 申请加入公会列表请求
		count = 0,
		list = {},
	},
	GUILD_SETTING_MODEL = {                                         -- 设置公会方式
		APPROVAL = 0,
		FORBID = 1,
		AUTOPASS = 2,
	},
	GUILD_NOTIFY_TYPE = {                                           -- 消息通知类型
		INVALID = 0,
		APPLYFOR = 1,                                               -- 有人申请加入
		UNION_APPLYFOR = 2,                                         -- 有军团申请结盟
		UNION_JOIN = 3,                                             -- 加入联盟
		UNION_QUIT = 4,                                             -- 退出联盟
		UNION_REJECT = 5,                                           -- 拒绝联盟
		UNION_APPLYFOR_SUCC = 6,                                    -- 申请军团联盟成功
		MEMBER_ADD = 7,                                             -- 成员加入
		MEMBER_REMOVE = 8,                                          -- 成员退出
		MEMBER_SOS = 9,                                             -- 成员求救
		MEMBER_HUNYAN = 10,                                         -- 成员有婚宴
		REP_PAPER = 11,                                             -- 红包相关
		GUILD_PARTY = 12,                                           -- 仙盟酒会
		GUILD_FB = 13,                                              -- 仙盟副本
		GUILD_LUCKY = 14,                                           -- 仙盟运势
		GUILD_ACTIVE_DEGREE = 15,                                   -- 仙盟活跃度
		GUILD_BIAOCHE_START = 19,									-- 仙盟运镖开始
		GUILD_BIAOCHE_END = 20, 									-- 仙盟运镖结束
		GUILD_NOTIFY_TYPE_TIANCI_TONGBI_OPEN = 22,					-- 天赐铜币开始
		GUILD_NOTIFY_TYPE_GUILD_BIAOCHE_CUR_POS = 23,				-- 帮派运镖当前坐标
		GUILD_NOTIFY_TYPE_TIANCI_TONGBI_CLOSE = 24,					-- 天赐铜币结束
		GUILD_NOTIFY_TYPE_GET_GONGZI = 25,							-- 获得仙盟工资 notify_param: 工资
		GUILD_NOTIFY_TYPE_TOTAL_GONGZI_CHNAGE = 26,					-- 仙盟总工资变更 notify_param: 工资 
		MAX = 99,
	},
}

GUILD_CHAT_POST = {
		Language.Guild.PuTong,                                                -- 成员
		Language.Guild.ZhangLao,                                                  -- 长老
		Language.Guild.FuMengZhu,                                             -- 副团长
		Language.Guild.MengZhu,                                                 -- 团长
		Language.Guild.JingYing,                                                   -- 精英成员
		Language.Guild.HuFa,                                                       -- 护法
}

GUILD_POST_NAME = {
		[GuildDataConst.GUILD_POST.CHENG_YUAN] = Language.Guild.PuTong,
		[GuildDataConst.GUILD_POST.ZHANG_LAO] = Language.Guild.ZhangLao,
		[GuildDataConst.GUILD_POST.FU_TUANGZHANG] = Language.Guild.FuMengZhu,
		[GuildDataConst.GUILD_POST.TUANGZHANG] = Language.Guild.MengZhu,
		[GuildDataConst.GUILD_POST.JINGYING] = Language.Guild.JingYing,
		[GuildDataConst.GUILD_POST.HUFA] = Language.Guild.HuFa,
	}
function GuildData:GetGuildConfig()
	if not self.guild_config then
		self.guild_config = ConfigManager.Instance:GetAutoConfig("guildconfig_auto")
	end
	return self.guild_config
end

function GuildData:GetSkillConfig(skill_index, skill_level)
	if not skill_index or not skill_level then return end
	if not self.skill_config then
		self.skill_config = self:GetGuildConfig().skill_config
	end
	if self.skill_config then
		return self.skill_config[(self.max_skill_level + 1) * (skill_index - 1) + skill_level + 1]
	end
end

function GuildData:SetGuildRoleGuildInfo(protocol)
	self.role_info = {}
	for k,v in pairs(protocol) do  -- ??? 还能这么写。 这么写会有DeleteMe
		if k ~= "DeleteMe" then
			self.role_info[k] = v
		end
	end
end

function GuildData:GetGuildBiaoCheRewardByIndex(index)
	local reward_list = {}
	local temp_list = {}
	local data = {}
	local guild_config = self:GetGuildConfig()
	if guild_config and guild_config.guild_biaoche_info then
		local reward_cfg = guild_config.guild_biaoche_info[1]
		if index == UILD_YUNBIAO_RESULT_TYPE.GUILD_YUNBIAO_RESULT_TYPE_SUCC then
			if reward_cfg.succ_reward_item and reward_cfg.succ_gongxian then
				temp_list = TableCopy(reward_cfg.succ_reward_item)
				data = {item_id = ResPath.CurrencyToIconId.guild_gongxian, num = reward_cfg.succ_gongxian, is_bind = 1}
				table.insert(temp_list, data)
			end
		elseif index == UILD_YUNBIAO_RESULT_TYPE.GUILD_YUNBIAO_RESULT_TYPE_FAIL then
			if reward_cfg.fail_reward_item then
				temp_list = TableCopy(reward_cfg.fail_reward_item)
				data = {item_id = ResPath.CurrencyToIconId.guild_gongxian, num = reward_cfg.fail_gongxian, is_bind = 1}
				table.insert(temp_list, data)
			end
		elseif index == UILD_YUNBIAO_RESULT_TYPE.GUILD_YUNBIAO_RESULT_TYPE_ROB_SUCC then
			if reward_cfg.rob_reward_item then
				temp_list = TableCopy(reward_cfg.rob_reward_item)
				data = {item_id = ResPath.CurrencyToIconId.guild_gongxian, num = reward_cfg.rob_gongxian, is_bind = 1}
				table.insert(temp_list, data)
			end
		end
	end
	-- for k,v in pairs(temp_list) do
	-- 	if v.item_id > 0 then
	-- 		table.insert(reward_list, v)
	-- 	end
	-- end
	return temp_list
end

function GuildData:GetAltarCount()
	for i = 1, 4 do
		local is_show_remind = self:IsCanUpgrade(i)
		if is_show_remind then
			return 1
		end
	end

	return 0
end

-- 根据技能id获取是否能升级
function GuildData:IsCanUpgrade(skill_idx)
	if skill_idx == 1 then 					--策划要求第一把剑不要红点提示
		return false
	end
	local level = self:GetSkillLevel(skill_idx) or 0
	local skill_cfg = self:GetSkillConfig(skill_idx, level)
	if not skill_cfg then
		return false
	end

	local is_max_level = level >= self:GetMaxGuildSkillLevel()

	if is_max_level then
		return false
	end

	local is_expend_goods = skill_cfg.uplevel_stuff_id ~= 0 and skill_cfg.uplevel_stuff_count ~= 0

	if is_expend_goods then
		local have_item_num = ItemData.Instance:GetItemNumInBagById(skill_cfg.uplevel_stuff_id)
		local gongxian = self:GetGuildGongxian()
		if have_item_num >= skill_cfg.uplevel_stuff_count and gongxian >= skill_cfg.uplevel_gongxian then
			return true
		end
	end

	if not is_expend_goods then
		local gongxian = self:GetGuildGongxian()
		if gongxian >= skill_cfg.uplevel_gongxian then
			return true
		end
	end

	return false
end

function GuildData:GetGuildRoleGuildInfo()
	return self.role_info
end

function GuildData:GetSkillLevel(index)
	return self.role_info.skill_level_list[index]
end

function GuildData:SetGuildGongxian(gongxian)
	self.role_info.guild_gongxian = gongxian
end

function GuildData:SetGuildTotalGongxian(gongxian)
	self.guild_total_gongxian = gongxian
end

function GuildData:GetGuildGongxian()
	return self.role_info.guild_gongxian or 0
end

function GuildData:GetGuildTotalGongxian()
	return self.guild_total_gongxian
end

function GuildData:GetGongXianMaxGold()
	return self.role_info.day_juanxian_gold or 0
end

function GuildData:GetTotemConfig(level)
	if not self.totem_config then
		self.totem_config = self:GetGuildConfig().totem_config
	end
	local totem_level = level or GuildDataConst.GUILDVO.guild_totem_level
	return self.totem_config[totem_level + 1]
end

-- 得到成员在自己公会中的信息
function GuildData:GetGuildMemberInfo(role_id)
	if self.guild_id < 1 then return end
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local id = role_id or main_role_vo.role_id
	if GuildDataConst.GUILD_MEMBER_LIST.count > 0 then
		for _, v in pairs(GuildDataConst.GUILD_MEMBER_LIST.list) do
			if v.uid == id then
				return v
			end
		end
	end
	return nil
end

function GuildData:SetInviteGuild(data)
	self.guild_invent_data = data
end

function GuildData:GetInviteGuild()
	return self.guild_invent_data
end

-- 得到成员在自己公会中的职位
function GuildData:GetGuildPost(role_id)
	local info = self:GetGuildMemberInfo(role_id)
	if info then
		return info.post
	end
	return -1
end

-- 获得弹劾令牌id
function GuildData:GetGuildDeleteId()
	local config = self:GetOtherConfig()
	if config then
		return config.delate_item_id
	end
end

-- 获得建设物资id
function GuildData:GetGuildJianSheId()
	local config = self:GetOtherConfig()
	if config then
		return config.jianshe_item_id
	end
end

-- 获得建盟令id
function GuildData:GetGuildCreatId()
	local config = self:GetOtherConfig()
	if config then
		return config.create_item_id
	end
end

-- 需要的绑钻数量
function GuildData:GetGuildCreatBindGoldCount()
	local num = 0
	local config = self:GetOtherConfig()
	if config then
		num = config.create_coin_bind
	end
	return num
end

-- 获得扩展公会成员物品ID
function GuildData:GetGuildExtendId()
	local config = self:GetOtherConfig()
	if config then
		return config.extend_member_item
	end
end

-- 获得扩展公会成员物品所需要的数量
function GuildData:GetGuildExtendCountByNum(cur_max_member_count)
	if nil == cur_max_member_count then
		cur_max_member_count = GuildDataConst.GUILDVO.max_member_count or 0
	end
	local need_item_count = 0
	local config = self:GetGuildConfig()
	if config then
		local extend_member_cfg = config.extend_member_cfg
		if extend_member_cfg then
			for i = #extend_member_cfg, 1, -1 do
				local cfg = extend_member_cfg[i]
				if cfg.member_count <= cur_max_member_count then
					need_item_count = cfg.need_item_count
					break
				end
			end
		end
	end
	return need_item_count
end

---------------------------------------------------------------红点提示------------------------------------------------------

-- 是否需要红点标记
function GuildData:GetReminder(index)
	self:CalculateRedPoint()
	if index then
		if self.red_point_list[index] == nil then
			return false
		end
		return self.red_point_list[index]
	end
	return self.red_point_list
end

function GuildData:CalculateRedPoint()
	if self.guild_id < 1 then
		self.red_point_list = {}
		RemindManager.Instance:Fire(RemindName.Guild)
		return
	end
	local guild_level = GuildDataConst.GUILDVO.guild_level or 0
	local post = self:GetGuildPost()
	 -- 图腾界面
	if not OpenFunData.Instance:CheckIsHide("guild_totem") then
		self.red_point_list[Guild_PANEL.totem] = false
	else
		local totem_config = self:GetTotemConfig()
		if totem_config then
			local exp = totem_config.max_exp
			if GuildDataConst.GUILDVO.guild_totem_exp >= exp and self:GetTotemConfig(GuildDataConst.GUILDVO.guild_totem_level + 1) then
				if post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
					self.red_point_list[Guild_PANEL.totem] = true
				else
					self.red_point_list[Guild_PANEL.totem] = false
				end
			else
				self.red_point_list[Guild_PANEL.totem] = false
			end
		else
			self.red_point_list[Guild_PANEL.totem] = false
		end
	end

	-- 信息界面
	self.red_point_list[Guild_PANEL.information] = false
	if OpenFunData.Instance:CheckIsHide("guild_info") then
		local card = 0
		local card_id = GuildData.Instance:GetGuildJianSheId()
		if card_id then
			card = ItemData.Instance:GetItemNumInBagById(card_id)
		end
		if (GuildDataConst.GUILD_APPLYFOR_LIST.count > 0 and (post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG))
			or self:GetSigninRemind() > 0 or self:GetGuildHeadRemind() > 0 then
			self.red_point_list[Guild_PANEL.information] = true
		elseif card > 0 then
			self.red_point_list[Guild_PANEL.information] = true
		elseif self:GetRedPacketRemindNum() == 1 then
			self.red_point_list[Guild_PANEL.information] = true
		end
	end

	-- 技能界面
	local temp = false
	if OpenFunData.Instance:CheckIsHide("guild_altar") then
		local gongxian = GuildData.Instance:GetGuildGongxian()
		for i = 1, GUILD_SKILL_COUNT do
			local skill_level = GuildData.Instance:GetSkillLevel(i) or 0
			local config = GuildData.Instance:GetSkillConfig(i, skill_level)
			if not config then return end
			local uplevel_gongxian = config.uplevel_gongxian
			local guild_level_limit = config.guild_level_limit or 0
			if skill_level < self.max_skill_level and gongxian >= uplevel_gongxian and guild_level >= guild_level_limit then
				temp = true
				break
			end
		end
	end
	self.red_point_list[Guild_PANEL.altar] = temp

	-- 宝箱界面
	self.red_point_list[Guild_PANEL.box] = false
	if OpenFunData.Instance:CheckIsHide("guild_box") then
		
		-- if self.assist_info.box_count > 0 and rest_assist_count > 0 and self.is_can_assist then
		-- 	self.red_point_list[Guild_PANEL.box] = true
		-- else
		if self:GetRestOpenBoxCount() > 0 and not self:IsGuildCD() and self:IsGuildBoxStart() and self:IsCanWaQuBox() then
			self.red_point_list[Guild_PANEL.box] = true
		elseif self.box_info.info_list then
			self.red_point_list[Guild_PANEL.box] = false
			for k,v in pairs(self.box_info.info_list) do
				if v.is_reward == 0 and v.open_time ~= 0 and v.open_time <= TimeCtrl.Instance:GetServerTime() then
					self.red_point_list[Guild_PANEL.box] = true
					break
				end
			end
		else
			self.red_point_list[Guild_PANEL.box] = false
		end
	end

	-- Boss界面
	self.red_point_list[Guild_PANEL.boss] = false
	if OpenFunData.Instance:CheckIsHide("guild_boss") then
		local feed_id = self:GetBossFeedItemId()
		local number = 0
		if feed_id then
			number = ItemData.Instance:GetItemNumInBagById(feed_id)
		end
		local boss_config = self:GetGuildActiveConfig().guild_boss
		local boss_info = GuildData.Instance:GetBossInfo()
		if boss_config and boss_info then
			local next_config = boss_config[boss_info.boss_level + 2]
			if next_config then
				if number > 0 and boss_info.boss_normal_call_count <= 0 then
					self.red_point_list[Guild_PANEL.boss] = true
				end
			end
		end
	end

	-- 领地界面
	-- self.red_point_list[Guild_PANEL.territory] = false
	-- if OpenFunData.Instance:CheckIsHide("guild_territory") then
	--     if post == GuildDataConst.GUILD_POST.TUANGZHANG and self.territory_rank > 0 then
	--         if not self.role_info.territorywar_reward_flag[5] and self.has_territory then
	--             self.red_point_list[Guild_PANEL.territory] = true
	--         end
	--     end
	--     if not self.red_point_list[Guild_PANEL.territory] then
	--         for i = 1, 4 do
	--             if not self.role_info.territorywar_reward_flag[i] then
	--                 if self.role_info.daily_guild_gongxian >= self.gong_xian_config[i] then
	--                     if i == 1 or self.has_territory then
	--                         self.red_point_list[Guild_PANEL.territory] = true
	--                         break
	--                     end
	--                 end
	--             end
	--         end
	--     end
	-- end

	-- 迷宫界面
	self.red_point_list[Guild_PANEL.maze] = RemindManager.Instance:GetRemind(RemindName.GuildMaze) > 0

   RemindManager.Instance:Fire(RemindName.Guild)
end

function GuildData:GetRestAssistCount()
	local other_config = self:GetOtherConfig()
	local info = self:GetBoxInfo()
	local rest_assist_count = 0
	if info and other_config then
		rest_assist_count = other_config.box_assist_max_count - info.assist_count
	end
	return rest_assist_count
 end 

-- 通知主界面
function GuildData:GetMazeRemind()
	if OpenFunData.Instance:CheckIsHide("guild_maze") then
		if self.maze_info.complete_time <= 0 then
			if self:GetMazeAnswerCD() <= 0 then
				return 1
			end
		end
	end
	return 0
end

-- 通知主界面
function GuildData:GetGuildRemind()
	local num = 0
	for _,v in pairs(self.red_point_list) do
		if v then
		   num = num + 1
		end
	end
	if self.guild_id <= 0 and OpenFunData.Instance:CheckIsHide("guild") then
		num = num + 1
	end
	return num
end

-- 操作红点
function GuildData:GetRedOperate()
	local post = self:GetGuildPost()
	if OpenFunData.Instance:CheckIsHide("guild_info") and GuildDataConst.GUILD_APPLYFOR_LIST.count > 0 and 
		(post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG) then
		return 1
	end
	return 0
end

--捐赠红点
function GuildData:GetRedDonate()
	local card_id = self:GetGuildJianSheId()
	if card_id then
		local card_count = ItemData.Instance:GetItemNumInBagById(card_id)
		return card_count > 0 and 1 or 0
	end
	return 0
end

-- 通知主界面
function GuildData:GetNoGuildRemind()
	local guild_id = PlayerData.Instance.role_vo.guild_id
	if not OpenFunData.Instance:CheckIsHide("guild") then
		return 0
	end
	if guild_id and guild_id > 0 then
		return 0
	end
	return 1
end

-- 得到成员在公会中的红点信息
function GuildData:GetRedPointInfo()
	for _,v in pairs(self.red_point_list) do
		if v then
			return true
		end
	end
	return false
end

function GuildData:SetIsCanAssistBox(switch)
	self.is_can_assist = switch
	self:CalculateRedPoint()
end

-- 设置宝箱信息
function GuildData:SetBoxInfo(info)
	self.box_info.uplevel_count = info.uplevel_count
	self.box_info.assist_count = info.assist_count
	self.box_info.be_assist_count = info.be_assist_count
	self.box_info.assist_cd_end_time = info.assist_cd_end_time
	self.box_info.info_list = info.info_list
	local now_time = TimeCtrl.Instance:GetServerTime()
	for k,v in pairs(self.box_info.info_list) do
		v.index = k - 1
		if v.open_time and v.open_time > now_time then
			self:SetDelayReqProt(v.open_time, now_time)
			break
		end
	end
end

function GuildData:SetDelayReqProt(open_time, now_time)
	if self.count_down then
		GlobalTimerQuest:CancelQuest(self.count_down)
		self.count_down = nil
	end

	if self.count_down == nil then
		local time = open_time - now_time + 1
		self.count_down = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.CountDownRequest, self), time)
	end
end 

function GuildData:CountDownRequest()
	GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_QUERY_SELF)
	if self.count_down then
		GlobalTimerQuest:CancelQuest(self.count_down)
		self.count_down = nil
	end
end

function GuildData:GetBoxInfo()
	return self.box_info
end

-- 设置宝箱协助信息
function GuildData:SetAssistInfo(info)
	self.assist_info.box_count = info.box_count
	self.assist_info.info_list = info.info_list
end

function GuildData:GetAssistInfo()
	return self.assist_info
end

function GuildData:GetOtherConfig()
	if not self.other_config then
		self.other_config = self:GetGuildConfig().other_config[1]
	end
	return self.other_config
end

function GuildData:GetBoxConfig()
	if not self.box_config then
		self.box_config = self:GetGuildConfig().box_config
	end
	return self.box_config
end

function GuildData:GetGuildYunBiaoConfig()
	if not self.guild_yunbiao_config then
		self.guild_yunbiao_config = self:GetGuildConfig().guild_yunbiao_other_config[1]
	end
	return self.guild_yunbiao_config
end

function GuildData:GetBoxConfigByLevel(level)
	local cfg = self:GetBoxConfig()
	if cfg then
		for k,v in pairs(cfg) do
			if v.level == level then
				return v
			end
		end
	end
end

function GuildData:GetOpenBoxCountByVip(vip_level)
	local vip_config = VipData.Instance:GetVipLevelCfg()
	if vip_config then
		local vip_box_info = vip_config[VIPPOWER.GUILD_BOX_COUNT]
		if vip_box_info then
			return vip_box_info["param_" .. vip_level]
		end
	end
end

--得到盒子标签红点
function GuildData:GetBoxCount()
	local count = 0
	if self:GetRestOpenBoxCount() > 0 and not self:IsGuildCD() and self:IsGuildBoxStart() and self:IsCanWaQuBox() then
		return 1
	elseif self.box_info.info_list then
		for k,v in pairs(self.box_info.info_list) do
			if v.is_reward == 0 and v.open_time ~= 0 and v.open_time <= TimeCtrl.Instance:GetServerTime() then
				-- count = count + 1
				return 1
			end
		end
	end
	-- local assist_info = self:GetAssistInfo()
	-- local rest_assist_count = self:GetOtherConfig().box_assist_max_count - self:GetBoxInfo().assist_count
	-- if assist_info and assist_info.box_count > 0 and rest_assist_count > 0 then
	-- 	count = count + 1
	-- end
	return count
end

function GuildData:GetRestOpenBoxCount()
	local count = 0
	for i = 1, GameEnum.MAX_GUILD_BOX_COUNT do
		if self.box_info.info_list[i] then
			if self.box_info.info_list[i].open_time ~= 0 then
				count = count + 1
			end
		end
	end
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local open_count = self:GetOpenBoxCountByVip(main_role_vo.vip_level)
	if open_count then
		return math.max(open_count - count, 0)
	end
end

function GuildData:SetBossInfo(protocol)
	for k,v in pairs(protocol) do
		self.boss_info[k] = v
	end
end

function GuildData:GetBossInfo()
	return self.boss_info
end

function GuildData:GetGuildActiveConfig()
	if not self.boss_config then
		self.boss_config = ConfigManager.Instance:GetAutoConfig("guild_active_auto")
	end
	return self.boss_config
end

function GuildData:GetGuildActivityIDList()
	self:GetGuildActiveConfig()
	if self.boss_config ~= nil then
		return self.boss_config.guild_act_id
	end
end

function GuildData:GetActivityConfig()
	local config = self:GetGuildActiveConfig().guild_activity
	if config then
		local guild_activity_config = TableCopy(config)
		table.sort(guild_activity_config, function(a, b)
			local a_id = a.activity_id
			local b_id = b.activity_id
			local a_is_open = ActivityData.Instance:GetActivityIsOpen(a_id) and 1 or 0
			local b_is_open = ActivityData.Instance:GetActivityIsOpen(b_id) and 1 or 0
			if a_is_open == b_is_open then
				local a_today_is_open = ActivityData.Instance:GetActivityIsInToday(a_id) and 1 or 0
				local b_today_is_open = ActivityData.Instance:GetActivityIsInToday(b_id) and 1 or 0
				if a_today_is_open == b_today_is_open then
					local a_is_over = ActivityData.Instance:GetActivityIsOver(a_id) and 1 or 0
					local b_is_over = ActivityData.Instance:GetActivityIsOver(b_id) and 1 or 0
					if a_is_over == b_is_over then
						local a_next_time = ActivityData.Instance:GetNextOpenTime(a_id)
						local b_next_time = ActivityData.Instance:GetNextOpenTime(b_id)
						return a_next_time < b_next_time
					else
						return a_is_over < b_is_over
					end
				else
					return a_today_is_open > b_today_is_open
				end
			else
				return a_is_open > b_is_open
			end
			return true
		 end)
		return guild_activity_config
	end
end

function GuildData:GetBossFeedItemId()
	return ConfigManager.Instance:GetAutoConfig("guild_active_auto").other[1].boss_uplevel_item_id
end

function GuildData:GetGuildInfoById(guild_id)
	if not guild_id or guild_id == 0 then return end
	for k,v in pairs(GuildDataConst.GUILD_INFO_LIST.list) do
		if v.guild_id == guild_id then
			return v
		end
	end
end

-- 通过Post得到职位名称
function GuildData:GetGuildPostNameByPostId(post)
	return Language.Guild[self.guild_post[post]]
end

function GuildData:SetGuildFuLiCount(count)
	self.fu_li_count = count
	self:CalculateRedPoint()
end

function GuildData:GetGuildFuLiCount()
	return self.fu_li_count
end

function GuildData:SetLastLeaveGuildTime(last_leave_guild_time)
	self.last_leave_guild_time = last_leave_guild_time
	self:CalculateRedPoint()
end

function GuildData:GetLastLeaveGuildTime()
	return self.last_leave_guild_time
end

function GuildData:GetBoxLimitTime()
	local config = self:GetOtherConfig()
	if config then
		return config.box_limit_time
	end
end

function GuildData:SetGuildStorgeInfo(info)
	self.guild_storge_info = {}
	self.guild_storge_info.open_grid_count = info.open_grid_count
	self.guild_storge_info.count = info.count
	self.guild_storge_info.storage_score = info.storage_score
	self.guild_storge_info.storge_item_list = {}
	for k,v in pairs(info.item_list) do
		self.guild_storge_info.storge_item_list[k] = v
	end
end

function GuildData:SetGuildStorgeChange(info)
	self.guild_storge_info.storge_item_list[info.index] = info.item_datawrapper
end

function GuildData:GetGuildStorgeInfo()
	return self.guild_storge_info
end

function GuildData:GetGuildStorgeSize()
	if self.guild_storge_info then
		return self.guild_storge_info.open_grid_count
	end
end

-- 是否在离开公会的限制时间中
function GuildData:IsGuildCD()
	local limit_time = TimeCtrl.Instance:GetServerTime() - self.last_leave_guild_time
	-- local box_limit_time = self:GetBoxLimitTime() or 0
	local box_limit_time = 0
	return limit_time < box_limit_time
end

function GuildData:SetGuildBoxStart(switch)
	self.is_guild_box_start = switch
end

-- 宝箱活动是否开始
function GuildData:IsGuildBoxStart()
	-- local now_time = TimeCtrl.Instance:GetServerTime()
	-- if now_time then
	--  now_time = now_time % 86400
	--  local other_config = GuildData.Instance:GetOtherConfig()
	--  if other_config then
	--      local box_start_time = other_config.box_start_time
	--      if box_start_time then
	--          if now_time >= box_start_time then
	--              return true
	--          end
	--      end
	--  end
	-- end
	-- return false

	return self.is_guild_box_start
end

-- 宝箱是否可以挖下一个
function GuildData:IsCanWaQuBox()
	local flag = true
	for k,v in pairs(self.box_info.info_list) do
		if v.open_time > 0 and v.is_reward == 0 then
			flag = false
			break
		end
	end
	return flag
end

function GuildData:IsCanInviteBox()
	local flag = false
	local now_time = TimeCtrl.Instance:GetServerTime()
	for k,v in pairs(self.box_info.info_list) do
		if v.open_time > now_time then
			flag = true
			break
		end
	end
	return flag
end

function GuildData:GetOtherGuildInfo()
	return self.other_guild_info
end

function GuildData:GetGuildTerritoryGongXian()
	return self.gong_xian_config
end

function GuildData:SetTerritoryRank(rank, has_territory)
	if rank == nil then
		rank = 0
		has_territory = false
	end
	self.territory_rank = rank
	self.has_territory = has_territory
	self:CalculateRedPoint()
end

function GuildData:GetTerritoryRank()
	return self.territory_rank, self.has_territory
end

function GuildData:GetTerritoryConfig(index)
	if self.territory_welf_config then
	   for k,v in pairs(self.territory_welf_config) do
			if v.territory_index == index then
				return v
			end
	   end
	end
end

function GuildData:SetBonFireState(openstatus)
	self.bon_fire_openstatus = openstatus
end

function GuildData:SetMiJingState(openstatus)
	self.mi_jing_openstatus = openstatus
end

function GuildData:GetBonFireState()
	return self.bon_fire_openstatus
end

function GuildData:GetMiJingState()
	return self.mi_jing_openstatus
end

function GuildData:SetBossActivityInfo(protocol)
	if NOTIFY_INFO_TYPE.NOTIFY_INFO_TYPE_SCENE  == protocol.notify_type then
		self.boss_activity_info.boss_level = protocol.boss_level
		self.boss_activity_info.boss_id = protocol.boss_id
		self.boss_activity_info.boss_obj_id = protocol.boss_obj_id
		self.boss_activity_info.is_surper_boss = protocol.is_surper_boss
	elseif NOTIFY_INFO_TYPE.NOTIFY_INFO_TYPE_RANK == protocol.notify_type then
		self.boss_activity_info.rank_list = protocol.rank_list
	elseif NOTIFY_INFO_TYPE.NOTIFY_INFO_TYPE_ROLE_INFO_CHANGE == protocol.notify_type then
		self.boss_activity_info.totem_exp = protocol.totem_exp
		self.boss_activity_info.gather_num = protocol.gather_num
	elseif NOTIFY_INFO_TYPE.NOTIFY_INFO_TYPE_STAR_LEVEL_CHANGE == protocol.notify_type then
		self.boss_activity_info.cur_star_level = protocol.cur_star_level
		self.boss_activity_info.next_change_star_time = protocol.next_change_star_time
	end
	self.boss_activity_info = protocol
end

function GuildData:GetBossStarConfig()
	if not self.boss_star_config then
		self.boss_star_config = ConfigManager.Instance:GetAutoConfig("guild_active_auto").star_level_cfg
	end
	return self.boss_star_config
end

function GuildData:GetBossActivityInfo()
	return self.boss_activity_info
end

function GuildData:GetRankInfo(index)
	return self.boss_activity_info.rank_list[index]
end

-- 是否有公会邀请权力
function GuildData:GetInvitePower()
	local flag = false
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	if guild_id > 0 then
		local post = self:GetGuildPost()
		if post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
			flag = true
		end
	end
	return flag
end

-- 得到旗帜的模型ID
function GuildData:GetQiZhiResId(level)
	local res_id = 15001
	local totem_level = level or GuildDataConst.GUILDVO.guild_totem_level
	local cfg = self:GetTotemConfig(totem_level)
	if cfg then
		res_id = res_id + cfg.image
	end
	return res_id
end

function GuildData:GetQiZhiHeadId(level)
	local head_id = 0
	local totem_level = level or GuildDataConst.GUILDVO.guild_totem_level
	local cfg = self:GetTotemConfig(totem_level)
	if cfg then
		head_id = cfg.headid or 0
	end
	return head_id
end

-- 是否拥有免费招募次数
function GuildData:GetCanCallinFree()
	local guild_call_in_free_time = 0
	local config = self:GetOtherConfig()
	if config then
		guild_call_in_free_time = config.guild_call_in_free_time or 0
	end
	if guild_call_in_free_time > GuildDataConst.GUILDVO.guild_callin_times then
		return true
	else
		return false
	end
end

-- 公会招募花费
function GuildData:GetCallinPrice()
	local guild_call_in_cost_gold = 0
	local config = self:GetOtherConfig()
	if config then
		guild_call_in_cost_gold = config.guild_call_in_cost_gold or 0
	end
	return guild_call_in_cost_gold
end

function GuildData:SetLastCallinTime(time)
	self.last_callin_time = time
end

function GuildData:GetLastCallinTime()
	return self.last_callin_time
end

-- 是否可以免费创建公会
function GuildData:IsCreateFree()
	local free_create_guild_times = self:CreateFreeNum()
	return GuildDataConst.GUILD_INFO_LIST.free_create_guild_times < free_create_guild_times
end

-- 免费创建公会数量
function GuildData:CreateFreeNum()
	local other_config = self:GetOtherConfig() or {}
	return other_config.free_create_guild_times or 0
end

function GuildData:ClearCache()
	self.box_info = {
		uplevel_count = 0,
		assist_count = 0,
		assist_cd_end_time = 0,
		info_list = {},
	}

	self.assist_info = {
		box_count = 0,
		info_list = {},
	}
end

-- 得到公会技能等级上限
function GuildData:GetMaxGuildSkillLevel()
	return self.max_skill_level or 0
end

-- 得到公会人数上限
function GuildData:GetMaxGuildMemberCount()
	-- 服务端写死的60
	return 60
end

-- 得到公会红包配置
function GuildData:GetGuildRedBagCfg()
	local config = self:GetGuildConfig()
	if config then
		return config.boss_guild_redbag_cfg
	end
end

-- 根据职位得到对应的复活次数
function GuildData:GetGuildReviveCountByPost(post)
	local count = 0
	if nil == post then
		post = self:GetGuildPost()
	end
	local config = self:GetGuildConfig()
	if config then
		local post_relive_times = config.post_relive_times
		if post_relive_times then
			for k,v in pairs(post_relive_times) do
				if v.guild_post == post then
					count = v.daily_relive_times or 0
					break
				end
			end
		end
	end
	return count
end

-- 得到剩余的个人公会复活次数
function GuildData:GetRestPersonalGuildReviveCount()
	local max_revive_count = self:GetGuildReviveCountByPost()
	return math.max(0, max_revive_count - self.daily_use_guild_relive_times)
end

-- 得到剩余的公会总复活次数
function GuildData:GetRestGuildTotalReviveCount()
	return GuildDataConst.GUILDVO.daily_relive_times
end

-- 得到公会Boss红包最大击杀数量
function GuildData:GetMaxGuildBossCount()
	local count = 0
	local boss_guild_redbag_cfg = self:GetGuildRedBagCfg()
	if boss_guild_redbag_cfg then
		for k,v in pairs(boss_guild_redbag_cfg) do
			if v.kill_boss_times > count then
				count = v.kill_boss_times
			end
		end
	end
	return count
end

-- 得到公会Boss红包是否已经领取
function GuildData:IsGetGuildHongBao(index)
	local bit_list = bit:d2b(self.daily_boss_redbag_reward_fetch_flag)
	for k, v in pairs(bit_list) do
		if v == 1 and (32 - k) == index then
			return true
		end
	end
	return false
end

-- 得到公会Boss红包是否达到领取条件
function GuildData:IsCanGetGuildHongBao(index)
	local need_num = self:GetGuildHongBaoKillCount(index)
	return need_num <= GuildDataConst.GUILDVO.daily_kill_boss_times
end

-- 得到当天已经使用了多少次公会复活次数
function GuildData:GetDailyUseGuildReliveTimes()
	return self.daily_use_guild_relive_times
end

function GuildData:SetDailyUseGuildReliveTimes(daily_use_guild_relive_times)
	self.daily_use_guild_relive_times = daily_use_guild_relive_times
end

function GuildData:SetDailyBossRedbagFlag(daily_boss_redbag_reward_fetch_flag)
	self.daily_boss_redbag_reward_fetch_flag = daily_boss_redbag_reward_fetch_flag
end

function GuildData:GetMaxHongBaoCount()
	local count = 0
	local cfg = self:GetGuildRedBagCfg()
	if cfg then
		count = #cfg
	end
	return count
end

-- 得到公会Boss红包需要击杀数量
function GuildData:GetGuildHongBaoKillCount(index)
	local need_num = 0
	local boss_guild_redbag_cfg = self:GetGuildRedBagCfg()
	if boss_guild_redbag_cfg then
		for k,v in pairs(boss_guild_redbag_cfg) do
			if v.index == index then
				need_num = v.kill_boss_times or 0
				break
			end
		end
	end
	return need_num
end

-- 得到公会红包是否可领
function GuildData:IsCanGetGuildRedPacket()
	return false
end
----------------红包----------------
function GuildData:SetRedPocketListInfo(protocol)
	local old_red_list = self:GetRedPocketListInfoIsOut()
	self.red_pocket_list = protocol.red_pocket_list
	local new_red_list = self:GetRedPocketListInfoIsOut()
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	for k,v in ipairs(self:GetRedPocketListInfoPrune()) do
		if (v.status == GUILD_RED_POCKET_STATUS.DISTRIBUTED and v.is_fetch ~= 1) or
			(v.status == GUILD_RED_POCKET_STATUS.UN_DISTRIBUTED and role_id == v.owner_role_id)
			and (GuildData.Instance.guild_id ~= 0)then
			--MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.GuildHongBao, true)
			--屏蔽仙盟红包
			MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.GuildHongBao, false)
			break
		else
			MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.GuildHongBao, false)
		end
	end

	if next(old_red_list) then
		for i = 1, #new_red_list do
			if old_red_list[i] and old_red_list[i].status == 1 and new_red_list[i].status == 2 and new_red_list[i].owner_role_id == role_id then
				local str_format = Language.Guild.GuildRedPacket
				local content = str_format
				ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, content, CHAT_CONTENT_TYPE.TEXT)
			end
		end
	end
end

-- 红包排序
function GuildData:GetRedPocketListInfoPrune()
	local red_pocket_list = TableCopy(self.red_pocket_list)
	local min_time = TimeCtrl.Instance:GetServerTime() - 2 * 24 * 60 * 60

	if next(red_pocket_list) then
		table.insert(red_pocket_list, 1, red_pocket_list[0])
		red_pocket_list[0] = nil
		for i = #red_pocket_list ,1 , -1 do
			if min_time >= red_pocket_list[i].create_timestamp then
				table.remove(red_pocket_list, i)
			end
		end
	end

	local red_pocket_list_prune = {}
	local index = 1
	self.next_red_index = -1
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	for k,v in ipairs(red_pocket_list) do
		if v.owner_role_id == role_id and v.is_fetch == 0 and v.status == 1 then     -- state 1 为未发放 2 为 已发放 3 为已领取  is_fetch 是否领完
			v.flag = 3
		elseif v.owner_role_id == role_id and v.is_fetch == 0 and v.status == 2 then
			v.flag = 1
		elseif v.owner_role_id ~= role_id and v.is_fetch == 0 and v.status == 2 then
			v.flag = 2
		elseif v.owner_role_id ~= role_id and v.is_fetch == 0 and v.status == 1 then
			v.flag = 4
		elseif v.is_fetch == 1 and v.status == 2 then
			v.flag = 5
		elseif v.status == 3 then
			v.flag = 7
		else
			v.flag = 6
		end
		if self.next_red_index == -1 and v.is_fetch == 0 and v.status == 2 then
			self.next_red_index = v.id
		end
		red_pocket_list_prune[index] = v
		index = index + 1
	end
	table.sort(red_pocket_list_prune, GuildData.CommonSorters("flag","create_timestamp", "red_paper_seq"))
	return red_pocket_list_prune
end

function GuildData:GetNextRedId()
	return self.next_red_index
end

--获得没有过期的红包
function GuildData:GetRedPocketListInfoIsOut()
	local red_pocket_list = TableCopy(self.red_pocket_list)
	local min_time = TimeCtrl.Instance:GetServerTime() - 2 * 24 * 60 * 60

	if next(red_pocket_list) then
		table.insert(red_pocket_list, 1, red_pocket_list[0])
		red_pocket_list[0] = nil
		for i = #red_pocket_list ,1 , -1 do
			if min_time >= red_pocket_list[i].create_timestamp then
				table.remove(red_pocket_list, i)
			end
		end
	end
	return red_pocket_list
end

function GuildData:GetRedPocketListInfo()
	local red_pocket_list = {}
	local index = 1
	for k,v in pairs(self.red_pocket_list) do
		red_pocket_list[index] = v
		index = index + 1
	end
	return red_pocket_list
end

function GuildData:GetJiluList()
	local red_pocket_list = self:GetRedPocketListInfo()
	local new_list = {}
	for k,v in pairs(red_pocket_list) do
		new_list[#red_pocket_list + 1 - k] = v
	end
	return new_list
end

function GuildData:GetRedPocketListDesc(seq)
	local red_pocket_cfg = ConfigManager.Instance:GetAutoConfig("guildconfig_auto").red_pocket
	for k,v in pairs(red_pocket_cfg) do
		if v.seq == seq then
			return v
		end
	end
	return nil
end

function GuildData:SetSaveRedPocketInfo(data)
	self.save_list = data
end

function GuildData:GetSaveRedPocketInfo()
	return self.save_list or {}
end

function GuildData:GetRedPocketInfo(id)
	local red_pocket_info = self:GetRedPocketListInfo()
	for k,v in pairs(red_pocket_info) do
		if id == v.id then
			return v
		end
	end
end

function GuildData:GetRedPocketZuiJia()
	local max_num = 0
	local max_uid = 0
		local fetch_info_list = self:GetRedPocketDistributeInfo()
		for k,v in pairs(fetch_info_list) do
			if v.gold_num >= max_num then
				max_num = v.gold_num
				max_uid = v.uid
			end
		end
	return max_uid
end

-- 红包领取详细列表
function GuildData:SetRedPocketDistributeInfo(protocol)
	self.red_pocket_distribute = protocol.log_list
end

function GuildData:GetRedPocketDistributeInfo()
	local fetch_info_list = {}
	local index = 1
	for k,v in pairs(self.red_pocket_distribute) do
		fetch_info_list[index] = v
		index = index + 1
	end
	return fetch_info_list
end

function GuildData:GetOwnRedPocket()
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local fetch_info_list = self:GetRedPocketDistributeInfo()
	for k,v in pairs(fetch_info_list) do
		if role_id == v.uid then
			return v
		end
	end
	return nil
end

-- 红包排序
function GuildData.CommonSorters(sort_key_name1, sort_key_name4, sort_key_name5)
	return function(a, b)
		local order_a = 10000
		local order_b = 10000
		if a[sort_key_name1] > b[sort_key_name1] then
			order_a = order_a + 10000
		elseif a[sort_key_name1] < b[sort_key_name1] then
			order_b = order_b + 10000
		end

		if nil == sort_key_name4 then return order_a < order_b end

		if a[sort_key_name4] > b[sort_key_name4] then
			order_a = order_a + 100
		elseif a[sort_key_name4] < b[sort_key_name4] then
			order_b = order_b + 100
		end

		if nil == sort_key_name5 then return order_a < order_b end

		if a[sort_key_name5] > b[sort_key_name5] then
			order_a = order_a + 10
		elseif a[sort_key_name5] < b[sort_key_name5] then
			order_b = order_b + 10
		end
		return order_a < order_b
	end
end

function GuildData:GetRedPacketRemindNum()
	-- if next(self:GetRedPocketListInfoPrune()) then
	-- 	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	-- 	for k,v in ipairs(self:GetRedPocketListInfoPrune()) do
	-- 		if (v.status == GUILD_RED_POCKET_STATUS.DISTRIBUTED and v.is_fetch == 0) or
	-- 			(v.status == GUILD_RED_POCKET_STATUS.UN_DISTRIBUTED and role_id == v.owner_role_id) then
	-- 			return 1
	-- 		end
	-- 	end
	-- end

	-- 策划叫屏蔽仙盟红包，如果策划要加回来这个功能，把上面这段代码还原
	return 0
end

function GuildData:SetGuildChatShakeState(guild_shake_state)
	self.guild_shake_state = guild_shake_state
end

--获取主界面摇晃状态
function GuildData:GetGuildChatShakeState()
	return self.guild_shake_state
end

function GuildData:GetGuildAutoKickOutLevel()
	local level = 0
	local other_config = self:GetOtherConfig()
	if other_config then
		level = other_config.auto_kickout or 0
	end
	return level
end

-- 获取仙盟仓库的装备数据
function GuildData:GetGuildWarehouseDataList()
	if self.guild_storge_info and self.guild_storge_info.storge_item_list and #self.guild_storge_info.storge_item_list > 0 then
		return self.guild_storge_info.storge_item_list
	end
	return {}
end

function GuildData:SetGuildWarehouseLogData(protocol)
	self.guild_warehouse_log_list = protocol.log_list
end

-- 获取仙盟仓库日志数据
function GuildData:GetGuildWarehouseLogDataList()
	table.sort(self.guild_warehouse_log_list, SortTools.KeyUpperSorters("log_time"))
	return self.guild_warehouse_log_list or {}
end

-- 获取仙盟捐献装备数据
function GuildData:GetGuildContributeEquipDataList()
	local bag_no_bind_list = ItemData.Instance:GetBagNoBindItemList()
	local contribute_equip_list = {}
	for k, v in pairs(bag_no_bind_list) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg and EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type) and item_cfg.guild_storage_score and item_cfg.guild_storage_score > 0 then
			table.insert(contribute_equip_list, v)
		end
	end
	return contribute_equip_list
end

-- 根据角色等级, 获取显示的品阶筛选列表
function GuildData:GetMaxStepAndListDataByRoleLv(role_lv, list_name_data)
	local guild_storge_dressing_cfg = ConfigManager.Instance:GetAutoConfig("guildconfig_auto").storge_dressing
	local max_step = 0
	for k, v in pairs(guild_storge_dressing_cfg) do
		if role_lv >= v.open_level then
			max_step = v.order
		end
	end

	local new_list_name = {}
	table.insert(new_list_name, list_name_data[1])
	for i = #list_name_data, 2, -1  do
		if i - 1 <= max_step then
			table.insert(new_list_name, list_name_data[i])
		end
	end
	return max_step, new_list_name
end

function GuildData:SetMazeInfo(info)
	self.maze_info.reason = info.reason
	self.maze_info.layer = info.layer
	self.maze_info.complete_time = info.complete_time
	self.maze_info.cd_end_time = info.cd_end_time
	self.maze_info.max_layer = info.max_layer
end

function GuildData:GetMazeInfo()
	return self.maze_info
end

function GuildData:SetMazeRankInfo(info)
	self.maze_rank_info.rank_count = info.rank_count
	self.maze_rank_info.rank_list = info.rank_list
end

function GuildData:GetMazeRankInfo()
	return self.maze_rank_info
end

function GuildData:GetMazeCfgByLayer(layer)
	local cfg = self:GetGuildConfig()
	if cfg then
		local maze_cfg = cfg.maze
		if maze_cfg then
			for k,v in pairs(maze_cfg) do
				if v.layer == layer then
					return v
				end
			end
		end
	end
end

function GuildData:GetMazeAnswerCD()
	local now_time = TimeCtrl.Instance:GetServerTime()
	local cd = self.maze_info.cd_end_time - now_time
	return cd
end

function GuildData:GetMazeHelpCD()
	return self.maze_help_cd
end

function GuildData:GetMazeRankCfgByRank(rank)
	local cfg = self:GetGuildConfig()
	if cfg then
		local maze_cfg = cfg.maze_rank_reward
		if maze_cfg then
			for k,v in pairs(maze_cfg) do
				if v.rank == rank then
					return v
				end
			end
		end
	end
end

function GuildData:GetSigninCfg()
   local signin_cfg = ConfigManager.Instance:GetAutoConfig("guild_active_auto").signin_cfg
   return signin_cfg
end

function GuildData:SetSigninData(protocol)
	self.signin_data.is_signin_today = protocol.is_signin_today                                 -- 今天是否已签到
	self.signin_data.signin_count_month = protocol.signin_count_month                           -- 月签到次数
	self.signin_data.guild_signin_fetch_reward_flag = protocol.guild_signin_fetch_reward_flag   -- 工会总签到
	self.signin_data.guild_signin_count_today = protocol.guild_signin_count_today               -- 工会总签到次
end

function GuildData:GetSigninData()
	return self.signin_data
end

function GuildData:GetSigninTitleOneCfg(signin_count)
	local signin_title = ConfigManager.Instance:GetAutoConfig("guild_active_auto").signin_title
	for k,v in pairs(signin_title) do
		if signin_count >= v.min and signin_count <= v.max then
			return v
		end
	end

	return {}
end

function GuildData:GetSigninRewardState(reward_index)
	local reward_flag = self.signin_data.guild_signin_fetch_reward_flag
	local flag_t = bit:d2b(reward_flag)
	local has_get_reward = flag_t[#flag_t - reward_index] == 1
	-- 已领取
	if has_get_reward then
		return GuildData.SinginRewardState.HasGetReward
	else
		local signin_cfg = self:GetSigninCfg()[reward_index] or {}
		local need_count = signin_cfg.need_count or 0
		local guild_signin_count_today = self.signin_data.guild_signin_count_today

		-- 可领取
		if guild_signin_count_today >= need_count then
			return GuildData.SinginRewardState.CanGetReward
		end

		-- 不可领
		return GuildData.SinginRewardState.CanNotGetReward
	end
end

-- 当前和上一个签到阶段配置
function GuildData:GetCurAndLastSigninGrade()
	local signin_cfg = self:GetSigninCfg()
	local guild_signin_count_today = self.signin_data.guild_signin_count_today
	for i = 0, #signin_cfg do
		local grade_cfg = signin_cfg[i]
		if grade_cfg then
			if guild_signin_count_today < grade_cfg.need_count then
				return grade_cfg, signin_cfg[i - 1] or {}
			end
		end
	end

	return {}, {}
end

function GuildData:GetPersonalSigninReward()
	return ConfigManager.Instance:GetAutoConfig("guild_active_auto").other[1].signin_item[0]
end

function GuildData:GetSigninRemind()
	if IS_ON_CROSSSERVER then
		return 0
	end
	-- 先判断有没有仙盟
	if GameVoManager.Instance:GetMainRoleVo().guild_id <= 0 then
		return 0
	end
	-- 可签到
	if self.signin_data.is_signin_today <= 0 then
		return 1
	end

	-- 公会总签到有可领取奖励
	-- 减1是因为现在可领取奖励客户端少了一个
	for i = 1, GuildData.SigninRewardNum - 1 do
		local data_index = i - 1
		local state = self:GetSigninRewardState(data_index)
		if state == GuildData.SinginRewardState.CanGetReward then
			return 1
		end
	end

	return 0
end

-- 公会头像小红点：会长副会长 且 还是使用默认头像
function GuildData:GetGuildHeadRemind()
	-- 先判断有没有仙盟
	if GameVoManager.Instance:GetMainRoleVo().guild_id <= 0 then
		return 0
	end

	if ClickOnceRemindList[RemindName.GuildHead] == 0 then
		return 0
	end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	-- 判断公会地位
	if vo.guild_post == GuildDataConst.GUILD_POST.TUANGZHANG or vo.guild_post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		if AvatarManager.Instance:isDefaultImg(vo.guild_id, true) == 0 then
			return 1
		end
	end

	return 0
end

--根据平台创建公会是否消耗钻石 plat_name_cfg
function GuildData:GetPlantNameGold(plat_name)
	local cfg = self:GetGuildConfig().plat_name_cfg or {}
	if cfg[plat_name] then
		return cfg[plat_name].gold
	elseif cfg["default"] then
		return cfg["default"].gold
	end
	return 0
end

--仙盟答题
function GuildData:SetQuestionPlayerInfo(protocol)
	self.player_info.exp = protocol.exp or 0
	self.player_info.guild_gongxian = protocol.guild_gongxian or 0
	self.player_info.guild_score = protocol.guild_score or 0
	self.player_info.is_gather = protocol.is_gather or 0
	self.player_info.true_uid = protocol.true_uid or 0
	self.player_info.true_name = protocol.true_name or ""
end

function GuildData:GetQuestionPlayerInfo()
	return self.player_info
end

function GuildData:SetQuestionInfo(protocol)
	self.question_info.question_state = protocol.question_state
	self.question_info.question_state_change_timestamp = protocol.question_state_change_timestamp
	self.question_info.question_index = protocol.question_index
	self.question_info.question_id = protocol.question_id
	self.question_info.question_str = protocol.question_str
	self.question_info.question_end_timestamp = protocol.question_end_timestamp
	self:CheckIsNeedShowNotice(self.question_info.question_index)
end

function GuildData:CheckIsShowGuildQuestion()
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GUILD_ANSWER) then
		local other_cfg = self:GetGuildQuestionOtherCfg()
		if other_cfg and self.question_info.question_end_timestamp then
			local total_num = other_cfg.question_total_num or 0
			local left_time = self.question_info.question_end_timestamp - TimeCtrl.Instance:GetServerTime()
			if self.question_info.question_index == total_num and left_time < 0 then
				return true
			end
		end
		return false
	end
end

function GuildData:CheckIsNeedShowNotice(question_index)
	local list = {1, 5, 10, 15, 20} --如果不在仙盟驻地则发出提示
	if question_index then
		for k,v in pairs(list) do
			if v == question_index then
				local scene_id = Scene.Instance:GetSceneId()
				if scene_id ~= 151 then
					ChatCtrl.Instance:AddSystemMsg(Language.GuildDaTi.Notice, nil, SYS_MSG_TYPE.SYS_MSG_ONLY_CHAT_WORLD)
				end
			end
		end
	end
end

function GuildData:GetQuestionInfo()
	return self.question_info
end

function GuildData:SetGuildRankInfo(protocol)
	self.question_rank_info = protocol.guild_rank_list
end

function GuildData:GetGuildRankInfo(index)
	return self.question_rank_info[index]
end

function GuildData:GetGuildRankInfoList()
	return self.question_rank_info
end

function GuildData:GetGuildQuestionOtherCfg()
	local other_cfg = ConfigManager.Instance:GetAutoConfig("guild_question_auto").other[1]
	return other_cfg
end

function GuildData:GetGuildNameByGuild(guild_id)
	local info_list = GuildDataConst.GUILD_INFO_LIST
	for k,v in pairs(info_list.list) do
		if guild_id == v.guild_id then
			return v.guild_name
		end
	end
	return ""
end

function GuildData:SendRankInfo(protocol)
	self.tree_rank_info = protocol
end

function GuildData:GetRankListNum()
	return self.tree_rank_info.rank_count
end

function GuildData:GetRankInfoList()
	return self.tree_rank_info.rank_item_list
end

function GuildData:GetMoneyTreeTimeInfo()
	return self.tree_rank_info
end

function GuildData:SendMoneyTreeState(state)
	self.moneytree_state = state or false
end

function GuildData:GetMoneyTreeState()
	return self.moneytree_state
end

function GuildData:SendMoneyTreePosInfo(protocol)
	self.moneytree_pos = protocol
end

function GuildData:GetMoneyTreePosInfo()
	return self.moneytree_pos
end

function GuildData:SendMoneyTreeInfo(protocol)
	self.moneytree_info = protocol
end

function GuildData:GetMoneyTreeInfo()
	return self.moneytree_info
end

function GuildData:SendMoneyTreeReward(protocol)
	local mojing_list = {}
	local bangyuan_list = {}
	local exp_list = {}
	self.moneytree_rank = protocol.rank_pos or 0
	self.moneytree_reward = {}

	mojing_list.item_id = protocol.reward_item_id
	mojing_list.num = protocol.reward_item_num or 0
	bangyuan_list.item_id = protocol.reward_id_bigcoin
	bangyuan_list.num = protocol.reward_num_bigcoin or 0
	exp_list.item_id = protocol.reward_id_exp
	exp_list.num = protocol.total_exp_low + (protocol.total_exp_high * (2 ^ 32)) or 0

	if protocol.reward_item_num > 0 then
		table.insert(self.moneytree_reward, mojing_list)
	end

	if protocol.reward_num_bigcoin > 0 then
		table.insert(self.moneytree_reward, bangyuan_list)
	end

	if (protocol.total_exp_low + (protocol.total_exp_high * (2 ^ 32))) > 0 then
		table.insert(self.moneytree_reward, exp_list)
	end
end

function GuildData:GetMoneyTreeReward()
	return self.moneytree_reward
end

function GuildData:GetMoneyTreeRank()
	return self.moneytree_rank
end

function GuildData:MoveToMoneyTree()
	local npc_id = self:GetMoneyTreeID()
	local scene_type = Scene.Instance:GetSceneType()
	if nil == npc_id or scene_type ~= SceneType.GuildStation then
		return
	end

	local npc = Scene.Instance:GetNpcByNpcId(npc_id)
	if nil == npc then
		return
	end

	-- MoveCache.end_type = MoveEndType.GatherById
	-- MoveCache.param1 = npc:GetGatherId()
	MoveCache.end_type = MoveEndType.ClickNpc
	MoveCache.param1 = npc_id
	GuajiCtrl.Instance:MoveToObj(npc)
end

function GuildData:ClsoeMoneyTreeModel()
	local npc_id = self:GetMoneyTreeID()
	local scene_type = Scene.Instance:GetSceneType()
	if nil == npc_id or scene_type ~= SceneType.GuildStation then
		return
	end

	local npc = Scene.Instance:GetNpcByNpcId(npc_id)
	if nil == npc then
		return
	end

	Scene.Instance:DeleteObj(npc:GetObjId())
end

function GuildData:SendMoneyTreeGatherState(gater_type)
	self.moneytree_gather_type = gater_type or 0
end

function GuildData:GetMoneyTreeGatherState()
	return self.moneytree_gather_type
end

function GuildData:SendMoneyTreeIcon(state)
	self.moneytreeicon = state or 0
end

function GuildData:GetMoneyTreeIcon()
	return self.moneytreeicon
end

function GuildData:SendMoneyTreeGather()
	GuildCtrl.Instance:MoveToTreeState(false)
	GuildCtrl.Instance:OpenGuildMoneyTree(GUILD_TIANCITONGBI_REQ_TYPE.GUILD_TIANCITONGBI_REQ_TYPE_USE_GATHER)
end

function GuildData:GetMoneyTreeID()
	local npc_info = ConfigManager.Instance:GetAutoConfig("npc_auto").npc_list[303]
	local id = npc_info.id or 0

	return id
end

-------------仙盟剑阵/技能-------------
-- 返回仙盟技能描述列表
function GuildData:GetSkillDecCfg()
	local guild_cfg = self:GetGuildConfig()
	local skill_dec_cfg = ListToMap(guild_cfg.skill_config_describe, "skill_idx")
	return skill_dec_cfg
end

---------------------------------

function GuildData:GetGuildWarRewardRedPoint()
	local guild_war_reward_info = GuildFightData.Instance:GetGuildBattleDailyRewardFlag()
	if guild_war_reward_info == nil then
		return 0
	end
	if guild_war_reward_info.my_guild_rank ~= 0 and guild_war_reward_info.had_fetch == 0 then
		return 1
	end
	return 0
end

function GuildData:GetGuildWageRedPoint()
	local is_show = self:IsCanShowGongZiRedPoint()
	if is_show then
		return 1 
	end
	return 0
end

function GuildData:SetHugState(hug_state)
	self.hug_state = hug_state
end

function GuildData:GetHugState()
	return self.hug_state
end

function GuildData:GetGatherIdByType(gather_type)
	local cfg = ConfigManager.Instance:GetAutoConfig("guild_active_auto").guild_tianci_tongbi_gather
	local gather_id = 0
	if cfg then
		for i, v in pairs(cfg) do
			if v.type == gather_type then
				return v.gather_id
			end
		end
	end
	return gather_id
end

function GuildData:SetGatherID(gather_type)
	self.gather_type = gather_type
end

function GuildData:GetGatherID()
	return self.gather_type
end

function GuildData:SetGuildEventListData(protocol)
	self.guild_event_list = protocol.event_list
	self.guild_event_count = protocol.count
	function sortfun(a, b)
		if a.event_time and b.event_time and a.event_time ~= b.event_time then
			return a.event_time > b.event_time
		end
	end
	table.sort(self.guild_event_list, sortfun)
end

function GuildData:GetGuildEventCount()
	local list = self:GetGuildEventList()
	local count = #list or 0
	return count
end

function GuildData:GetGuildEventCfg(index)
	local cfg = self:GetGuildConfig()
	if cfg then
		local guild_event_cfg = cfg.jianghu_rumors
		if guild_event_cfg then
			for k,v in pairs(guild_event_cfg) do
				if v.rumors_type == index then
					return v.rumors_desc or ""
				end
			end
		end
	end
	return ""
end

function GuildData:CheckIsGuildChuanWen(index)
	local cfg = self:GetGuildConfig()
	if cfg then
		local guild_event_cfg = cfg.jianghu_rumors
		if guild_event_cfg then
			for k,v in pairs(guild_event_cfg) do
				if v.rumors_type == index then
					return true
				end
			end
		end
	end
	return false
end

function GuildData:GetGuildEventList()
	local list = {}
	for i,v in ipairs(self.guild_event_list) do
		if self:CheckIsGuildChuanWen(v.event_type) then
			table.insert(list, v)
		end
	end
	return list
end

local BUY_HOUSE = 23 							 --买房特殊处理
local BAOBAO = 22 								 --宝宝特殊处理
local LIANFU_DUOCHENG = 51						 --连服夺城特殊处理
local XIANPIN_ZHUANGBEI = 28 					 --装备特殊处理

function GuildData:ExplainChuanWenText(data)
	if data == nil then
		return ""
	end
	local cfg_dec =""
	cfg_dec = self:GetGuildEventCfg(data.event_type)
	
	local gsub_text = cfg_dec
	

	if string.find(gsub_text, "[N0]") then
		if data.event_owner then
			gsub_text = string.gsub(gsub_text,"%[N0]", data.event_owner)
		end
	end

	if string.find(gsub_text, "[N1]") then
		if data.sparam0 then
			gsub_text = string.gsub(gsub_text,"%[N1]", data.sparam0)
		end
	end


	for i = 0, 4 do
		if string.find(gsub_text, "[P" .. i .. "]") then
			if data["param" .. i] then
				if data.event_type == BUY_HOUSE then
					gsub_text = string.gsub(gsub_text,"%[P" .. i .. "]", Language.CoupleHome.ThemeType[data["param" .. i]])
				elseif data.event_type == BAOBAO then
					gsub_text = string.gsub(gsub_text,"%[P" .. i .. "]", Language.BaoBaoChuanWen[data["param" .. i]])
				elseif data.event_type == LIANFU_DUOCHENG then
					if data["param" .. i] > 0 then
						local scene_name = ConfigManager.Instance:GetSceneConfig(data["param" .. i]).name or ""
						gsub_text = string.gsub(gsub_text,"%[P" .. i .. "]", scene_name)
					end
				elseif data.event_type == XIANPIN_ZHUANGBEI then
					if data["param" .. i] > 0 then
						local xian_pin_item_list = {}
						xian_pin_item_list = {data["param1"], data["param2"], data["param3"]}
						local xian_pin_item_list_num = xian_pin_item_list and #xian_pin_item_list or 0
						local param = ""
						local param_interval = ":"
						local num = 6 + xian_pin_item_list_num
						for i=1, num do
							if i <= 6 then
								param = param .. param_interval
							else
								if xian_pin_item_list and xian_pin_item_list[i - 6] then
									param = param .. param_interval .. xian_pin_item_list[i - 6]
								end
							end
						end

						local gsub_text2 = string.gsub(gsub_text,"%[P0]", data["param0"])
						gsub_text = string.gsub(gsub_text2,"%[P1]", param)
					end
				else
					gsub_text = string.gsub(gsub_text,"%[P" .. i .. "]", data["param" .. i])
				end
			end
			
		end
	end

	local str = "{wordcolor;#89F201;%s} " .. gsub_text
	local time_str = ""
	local cur_day = os.date("%d", TimeCtrl.Instance:GetServerTime())
	local event_day = os.date("%d", data.event_time)

	if cur_day == event_day then
		time_str = os.date("%H:%M", data.event_time)
	else
		time_str = os.date("%m/%d", data.event_time)
	end
	str = string.format(str, time_str)
	return str
end

function GuildData:SetGuildGongZiRankList(protocol)
	self.gongzi_list.guild_id = protocol.guild_id
	self.gongzi_list.member_list = protocol.member_list
end

function GuildData:GetGuildGongZiRankList()
	local list = self.gongzi_list.member_list
	if list then
		table.sort(list, SortTools.KeyUpperSorters("gongzi", "sort_post", "uid"))
	end
	return list
end

-- 仙盟输出展示
function GuildData:SetGuildInfoStatistic(protocol)
	self.guild_info_statistic_list = protocol.info_list
	if not ActivityData.Instance:GetActivityIsOpen(protocol.activity_type) and not ActivityData.Instance:GetActivityIsReady(protocol.activity_type) then
		table.sort(self.guild_info_statistic_list, SortTools.KeyUpperSorters("is_mvp", "kill_role", "hurt_roles", "hurt_targets", "kill_target", "uid"))
	end
end

function GuildData:GetGuildInfoStatistic()
	return self.guild_info_statistic_list
end

function GuildData:GetGuildMostUid()
	local kill_role_id = 0
	local shuchu_id = 0
	local hurt_id = 0
	local zhanling_id = 0

	local kill_role_num = 0
	local shuchu_num = 0
	local hurt_num = 0
	local kill_target_num = 0
	if self.guild_info_statistic_list then
		for k,v in ipairs(self.guild_info_statistic_list) do
			if v and v.kill_role > kill_role_num then
				kill_role_num = v.kill_role
				kill_role_id = v.uid
			end
			if v and v.hurt_roles > shuchu_num then
				shuchu_num = v.hurt_roles
				shuchu_id = v.uid
			end

			if v and v.hurt_targets > hurt_num then
				hurt_num = v.hurt_targets
				hurt_id = v.uid
			end
			if v and v.kill_target > kill_target_num then
				kill_target_num = v.kill_target
				zhanling_id = v.uid
			end
		end
	end
	return kill_role_id, shuchu_id, hurt_id, zhanling_id
end

function GuildData:GetIsGuildInfoListData(uid, plat_type)
	for k,v in pairs(self.guild_info_statistic_list) do
		if v.uid == uid then
			return true
		end
	end
	return false
end

function GuildData:SetGuildMvpInfo(protocol)
	self.guild_info_list.uid = protocol.uid
	self.guild_info_list.user_name = protocol.user_name
end

function GuildData:GetGuildMvpInfo()
	if self.guild_info_list.uid == 0 or self.guild_info_list.user_name == 0 then
		return
	end
	return self.guild_info_list.user_name
end

function GuildData:GetGuildTotalWage()
	return GuildDataConst.GUILDVO.guild_total_gongzi
end

function GuildData:IsCanShowGongZiRedPoint()
	local need_num = self:GetGuildNeedWage()
	local is_reach = GuildDataConst.GUILDVO.guild_total_gongzi >= need_num
	local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
	local is_tuanzhan = mainrole_vo.guild_post == GuildDataConst.GUILD_POST.TUANGZHANG
	return is_reach and is_tuanzhan and OpenFunData.Instance:CheckIsHide("guild_gongzi")
end

function GuildData:GetGuildNeedWage()
	local guild_cfg = self:GetOtherConfig()
	local need_num = 0
	if guild_cfg then
		need_num = guild_cfg.need_gongzi
	end
	return need_num
end

function GuildData:SaveTuanzhangInfo(role_id, info)
	local tuanzhang_uid = GuildDataConst.GUILDVO.tuanzhang_uid

	if self.tuanzhang_info and self.tuanzhang_info.role_id == tuanzhang_uid and 
		self.tuanzhang_info.shizhuang_part_list[2] == info.shizhuang_part_list[2] and
		self.tuanzhang_info.shizhuang_part_list[1] == info.shizhuang_part_list[1]  then
		-- 同武器 同时装不刷新
		return
	end

	if tuanzhang_uid and tuanzhang_uid == role_id then
		self.tuanzhang_info = TableCopy(info)
	end
end

function GuildData:GetTuanzhanginfo()
	return self.tuanzhang_info.role_id, self.tuanzhang_info
end

function GuildData:GetBoxTipsColor()
	return self.box_color
end

function GuildData:SetBoxTipsColor(color)
	self.box_color = color
end

function GuildData:SetBoxTipsData(is_free, free_count, up_count)
	if is_free ~= nil then
		self.box_is_free = is_free
	end
	if free_count ~= nil then
		self.box_free_count = free_count
	end
	if up_count ~= nil then
		self.box_up_count = up_count	
	end
end

function GuildData:GetBoxTipsData()
	return self.box_is_free, self.box_free_count, self.box_up_count
end

function GuildData:SetGuildRareLogRet(data)
	table.insert(self.fall_msg_data, data)
	table.insert(self.fall_unread_msg, data)
end

function GuildData:ClearFallAllMsg()
	self.fall_msg_data = {}
	self.fall_unread_msg = {}
end

function GuildData:GetGuildRareLogRet()
	return self.fall_msg_data
end

function GuildData:SetFallUnreadMsg(timestamp)
	if nil == self.fall_unread_msg then
		return
	end

	for k, v in ipairs(self.fall_unread_msg) do
		if timestamp == v.timestamp then
			table.remove(self.fall_unread_msg, k)
			break
		end
	end
end

function GuildData:GetFallUnreadMsg()
	return self.fall_unread_msg
end

function GuildData:ClearFallUnreadMsg()
	self.fall_unread_msg = {}
end

function GuildData:SetNewFallLockState(state)
	self.new_fall_lock_state = state
end

function GuildData:GetNewFallLockState()
	return self.new_fall_lock_state
end

function GuildData:GetGuildRareLogText(data)
	if data == nil or next(data) == nil then
		return ""
	end
	local dec =""
	local str = "{wordcolor;#89F201;%s} "
	local time_str = ""
	local cur_day = os.date("%d", TimeCtrl.Instance:GetServerTime())
	local event_day = os.date("%d", data.timestamp)

	if cur_day == event_day then
		time_str = os.date("%H:%M", data.timestamp)
	else
		time_str = os.date("%m/%d", data.timestamp)
	end

	local param_interval = ":"
	local xianpin_type_list_num = data.xianpin_type_list and #data.xianpin_type_list or 0
	local param = ""
	local num = 6 + xianpin_type_list_num
	for i=1, num do
		if i <= 6 then
			param = param .. param_interval
		else
			if data.xianpin_type_list and data.xianpin_type_list[i - 6] then
				param = param .. param_interval .. data.xianpin_type_list[i - 6]
			end
		end
	end

	str = string.format(str, time_str)
	-- local rank = data.log_str_id <= 0 and 1 or data.log_str_id
	if data.is_from_gift > 0 then
		local gift_cfg = ItemData.Instance:GetItemConfig(data.gift_item_id)
		if gift_cfg then
			dec = string.format(Language.Market.GuildRareLogText[2], str, data.role_name, gift_cfg.name or "", 
				data.item_id, param, data.role_id, data.item_id, "fall_msg")
		end
	else
		local monster = BossData.Instance:GetMonsterInfo(tonumber(data.monster_id)) or {}
		local scene_cfg = data.scene_id > 0 and MapData.Instance:GetMapConfig(data.scene_id) or {}
		dec = string.format(Language.Market.GuildRareLogText[1], str, data.role_name, scene_cfg.name or "", monster.name or "", 
			data.item_id, param, data.role_id, data.item_id, "fall_msg")
	end
	return dec
end

function GuildData:IsGuildEnemyFunOpen()
	local cfg = self:GetOtherConfig()
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local open_level = cfg.guild_enemy or 0
	return role_level >= open_level
end
