OPEN_FUN_TRIGGER_TYPE =
{
	ACHIEVE_TASK = 1,			-- 接受任务后
	SUBMIT_TASK = 2,			-- 提交任务后
	UPGRADE = 3,				-- 升级后
	PERSON_CHAPTER = 5,			-- 个人目标章节
	SERVER_DAY = 6,				-- 开服天数
	SERVER_DAY_AND_LEVEL = 7,	-- 开服天数+等级
	ZHUANZHI_FINISH = 8,		-- 转职后
	COMBINE_SERVER = 9, 		-- 合服后
}

OPEN_FLY_DICT_TYPE =
{
	UP = 1,					--上
	BOTTOM = 2,				--下
	OTHER = 3,				--其他
}

-- 审核服中开放的功能
FUN_OPEN_IN_AUDIT_VERSION = {
	[string.lower(ViewName.Player)] = 1,
	[string.lower(ViewName.VipView)] = 1,
	[string.lower(ViewName.Login)] = 1,
	[string.lower(ViewName.MainUIResIconList)] = 1,
	[string.lower(ViewName.Main)] = 1,
	[string.lower(ViewName.MainUIResIconList)] = 1,
	[string.lower(ViewName.Agent)] = 1,
	[string.lower(ViewName.DailyChargeView)] = 1,
	-- [string.lower(ViewName.FirstChargeView)] = 1,
	[string.lower(ViewName.SecondChargeView)] = 1,
	[string.lower(ViewName.OpenFirstcharge)] = 1,
	[string.lower(ViewName.LeiJiDailyView)] = 1,
	[string.lower(ViewName.DailyChargeView)] = 1,
	[string.lower(ViewName.FbIconView)] = 1,
	[string.lower(ViewName.MainUIResIconList)] = 1,
	[string.lower(ViewName.Map)] = 1,
	
	["InfoContent"] = 1,
	["PackageContent"] = 1,
	["FashionContent"] = 1,
	["TitlePanel"] = 1,
	["SkillContent"] = 1,
	["role_rebirth"] = 1,
	["tulong_equip"] = 1,
	["chongzhi"] = 1,
}

OpenFunData = OpenFunData or BaseClass()
function OpenFunData:__init()
	if OpenFunData.Instance then
		print_error("[OpenFunData] Attemp to create a singleton twice !")
	end
	OpenFunData.Instance = self
	self.notice_list = ConfigManager.Instance:GetAutoConfig("notice_auto").notice_list
	self.notice_day_cfg = ConfigManager.Instance:GetAutoConfig("notice_auto").notice_day

	self.cache_name_single_map = {}
	self.trailer_last_reward_id = 0
	self.day_trailer_last_reward_id = 0
	self.quick_use_item_id = -1
	self.notice_day_fectch_flag_list = {}
end

function OpenFunData:__delete()
	OpenFunData.Instance = nil
end

function OpenFunData:OpenFunCfg()
	return ConfigManager.Instance:GetAutoConfig("funopen_auto").funopen_list
end

function OpenFunData:GetCurTrailerCfg()
	local level = GameVoManager.Instance:GetMainRoleVo().level
	for k,v in ipairs(self.notice_list) do
		if OpenFunData.Instance:GetTrailerLastRewardId() < v.id or (level >= v.start_level and level < v.end_level) then
			return v
		end
	end
	return nil
end

function OpenFunData:GetSingleCfg(name)
	local cfg = self.cache_name_single_map[name]
	if nil ~= cfg then
		return cfg
	end

	for k,v in pairs(self:OpenFunCfg()) do
		if v.name == name or TabIndex[v.name] == name then
			self.cache_name_single_map[name] = v

			return v
		end
	end

	return nil
end

--这里的is_hide的意思是反义(就是是否显示的意思)
function OpenFunData:CheckIsHide(name)
	-- 审核服>>>>以前G16的逻辑 但不适合之后的，之后的项目审核服都不屏蔽
	-- if IS_AUDIT_VERSION and FUN_OPEN_IN_AUDIT_VERSION[name] ~= 1 and type(name) ~= "number" then
	-- 	return false, ""
	-- end
	local single_cfg = self:GetSingleCfg(name)
	if single_cfg == nil then
		return true
	end

	-- 是否IOS屏蔽
	if single_cfg.ios_shield == 1 and IS_AUDIT_VERSION then
		return false
	end

	local is_special_limit = self:IsSpecialLimit(name, single_cfg)

	if nil ~= is_special_limit then
		return is_special_limit
	end

	-- 是否关闭功能（用于达到某些条件就关闭功能）
	local is_close = self:IsCloseFun(single_cfg)
	if is_close then
		return false
	end

	local is_open, tips = self:IsOpenFun(single_cfg)
	-- 这里必须判断是否等于nil
	if nil ~= is_open then
		return is_open, tips
	end

	return true
end

function OpenFunData:IsOpenFun(single_cfg)
	if single_cfg.trigger_type == OPEN_FUN_TRIGGER_TYPE.ACHIEVE_TASK then
		return self:InitByAcceptedTask(single_cfg.trigger_param)
	elseif single_cfg.trigger_type == OPEN_FUN_TRIGGER_TYPE.SUBMIT_TASK then
		return self:InitBySubmitTask(single_cfg.trigger_param, single_cfg.task_level)
	elseif single_cfg.trigger_type == OPEN_FUN_TRIGGER_TYPE.UPGRADE then
		return self:InitByUpgrade(single_cfg.trigger_param)
	elseif single_cfg.trigger_type == OPEN_FUN_TRIGGER_TYPE.PERSON_CHAPTER then
		return self:InitByPersonChapter(single_cfg.trigger_param, single_cfg.name)
	elseif single_cfg.trigger_type == OPEN_FUN_TRIGGER_TYPE.SERVER_DAY then
		return self:InitByServerDay(single_cfg.trigger_param, single_cfg.name)
	elseif single_cfg.trigger_type == OPEN_FUN_TRIGGER_TYPE.SERVER_DAY_AND_LEVEL then
		return (self:InitByServerDay(single_cfg.trigger_param, single_cfg.name) and self:InitByUpgrade(single_cfg.task_level))
	elseif single_cfg.trigger_type == OPEN_FUN_TRIGGER_TYPE.ZHUANZHI_FINISH then
		return (self:InitByZhuanZhiNum(single_cfg.trigger_param, single_cfg.name) and self:InitByUpgrade(single_cfg.task_level))
	elseif single_cfg.trigger_type == OPEN_FUN_TRIGGER_TYPE.COMBINE_SERVER then
		return (self:InitByCombineServer(single_cfg.trigger_param, single_cfg.name))
	end
end

function OpenFunData:IsCloseFun(single_cfg)
	if nil == single_cfg or single_cfg.close_trigger_type == "" or single_cfg.close_trigger_param == "" then
		return false
	end
	if single_cfg.close_trigger_type == OPEN_FUN_TRIGGER_TYPE.ACHIEVE_TASK then
		return self:InitByAcceptedTask(single_cfg.close_trigger_param)
	elseif single_cfg.close_trigger_type == OPEN_FUN_TRIGGER_TYPE.SUBMIT_TASK then
		return self:InitBySubmitTask(single_cfg.close_trigger_param, single_cfg.task_level)
	elseif single_cfg.close_trigger_type == OPEN_FUN_TRIGGER_TYPE.UPGRADE then
		return self:InitByUpgrade(single_cfg.close_trigger_param)
	elseif single_cfg.close_trigger_type == OPEN_FUN_TRIGGER_TYPE.PERSON_CHAPTER then
		return self:InitByPersonChapter(single_cfg.close_trigger_param, single_cfg.name)
	elseif single_cfg.close_trigger_type == OPEN_FUN_TRIGGER_TYPE.SERVER_DAY then
		return self:InitByServerDay(single_cfg.close_trigger_param, single_cfg.name)
	elseif single_cfg.trigger_type == OPEN_FUN_TRIGGER_TYPE.SERVER_DAY_AND_LEVEL then
		return (self:InitByServerDay(single_cfg.trigger_param, single_cfg.name) or self:InitByUpgrade(single_cfg.task_level))
	elseif single_cfg.trigger_type == OPEN_FUN_TRIGGER_TYPE.ZHUANZHI_FINISH then
		return (self:InitByZhuanZhiNum(single_cfg.trigger_param, single_cfg.name) or self:InitByUpgrade(single_cfg.task_level))
	elseif single_cfg.trigger_type == OPEN_FUN_TRIGGER_TYPE.COMBINE_SERVER then
		return (self:InitByCombineServer(single_cfg.trigger_param, single_cfg.name))
	end

	return false
end

--初始化判断受特殊情况限制
function OpenFunData:IsSpecialLimit(name, single_cfg)
	return nil
end

--初始化判断是否达到接受任务条件
function OpenFunData:InitByAcceptedTask(trigger_param)
	local task_data = TaskData.Instance
	if task_data:GetTaskCompletedList()[trigger_param] == 1 then
		return true
	end

	if nil == task_data:GetTaskAcceptedInfoList()[trigger_param] then
		local task_info = task_data:GetTaskConfig(trigger_param)
		local tips = ""
		if task_info then
			tips = string.format(Language.Common.FunOpenTaskLevelLimit, task_info.task_name)
		end
		return false, tips
	end
	return true
end

--初始化判断是否达到提交任务条件
function OpenFunData:InitBySubmitTask(trigger_param, task_level)
	local list = TaskData.Instance:GetTaskCompletedList()
	if list[trigger_param] ~= 1 then
		local task_info = TaskData.Instance:GetTaskConfig(trigger_param)
		local tips = ""
		if task_info then
			tips = string.format(Language.Common.FunOpenTaskLevelLimit, PlayerData.GetLevelString(task_level))
		end
		return false, tips
	end
	return true
end

--初始化判断是否达到等级条件
function OpenFunData:InitByUpgrade(trigger_param)
	if GameVoManager.Instance:GetMainRoleVo().level < trigger_param then
		-- local lv, zhuan = PlayerData.GetLevelAndRebirth(trigger_param)
		-- local level_des = string.format(Language.Common.LevelFormat, lv, zhuan)
		local tips = string.format(Language.Common.FunOpenRoleLevelLimit, PlayerData.GetLevelString(trigger_param))
		return false, tips
	end
	return true
end

-- 初始化判断是否完成章节
function OpenFunData:InitByPersonChapter(trigger_param, name)
	local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local cur_chapter = PersonalGoalsData.Instance:GetOldChapter()
	if cur_chapter < trigger_param and (name ~= "CollectGoals" or server_open_day <= 4) then
		local tips = string.format(Language.Common.FunopenPersonChapterLimit, trigger_param)
		return false , tips
	end
	return true
end

-- --初始化判断是否达到开服天数条件
function OpenFunData:InitByServerDay(trigger_param, name)
	local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if server_open_day < trigger_param then
		local tips = string.format(Language.Common.FunOpenRoleServerDayLimit, trigger_param)
		return false , tips
	end
	return true
end

-- --初始化判断是否达到转职次数条件
function OpenFunData:InitByZhuanZhiNum(trigger_param, name)
	local prof, zhuan = PlayerData.Instance:GetRoleBaseProf()
	if zhuan < trigger_param then
		local tips = string.format(Language.Common.FunopenZhuanZhiNum, trigger_param)
		return false , tips
	end
	return true
end

-- --初始化判断是否达到合服后条件
function OpenFunData:InitByCombineServer(trigger_param, name)
	local combine_server_flag = TulongEquipData.Instance:GetCombineServerFlag()
	if combine_server_flag < trigger_param then
		local tips = string.format(Language.Common.FunOpenTip, trigger_param)
		return false , tips
	end
	return true
end

function OpenFunData:OnTheTrigger(trigger_type, trigger_param)
	local cfg = self:OpenFunCfg()
	local list = {}
	for k,v in pairs(cfg) do
		if v.trigger_type == trigger_type and v.trigger_param == trigger_param then
			list[#list + 1] = v
		end
	end
	return list
end

function OpenFunData:GetFlyDic(parent_name, name)
	if parent_name == "ButtonGroup1" or parent_name == "ButtonGroup2" or parent_name == "ButtonGroup3" then
		if name ~= "ButtonDeposit" and name ~= "ButtonInvest" and name ~= "ButtonRebate" and name ~= "ButtonFirstCharge" then
			return OPEN_FLY_DICT_TYPE.UP
		else
			return OPEN_FLY_DICT_TYPE.OTHER
		end
	elseif parent_name == "ButtonGroup" or parent_name == "ButtonGroupLeft" then
		return OPEN_FLY_DICT_TYPE.BOTTOM
	else
		return OPEN_FLY_DICT_TYPE.OTHER
	end
end

function OpenFunData:GetName(open_param)
	local list = Split(open_param, "#")
	if #list == 2 then
		return list[1]
	else
		return open_param
	end
end

function OpenFunData:GetTrailerLastRewardId()
	return self.trailer_last_reward_id
end

function OpenFunData:SetTrailerLastRewardId(id)
	self.trailer_last_reward_id = id
end

function OpenFunData:SetDayTrailerLastRewardId(list)
	self.notice_day_fectch_flag_list = {}
	local count = 0
	for k, v in pairs(list) do
		local bit_tab = bit:d2b(v)
		for i = 0, 7 do
			self.notice_day_fectch_flag_list[count] = bit_tab[33 - 8 + i]
			count = count + 1
		end
	end
end

function OpenFunData:GetDayTrailerLastRewardId(id)
	return self.notice_day_fectch_flag_list[id] or 0
end

--获得跨服六界功能开启等级
function OpenFunData:GetKuaFuBattleOpenLevel()
	if self:OpenFunCfg() and self:OpenFunCfg().kf_battle then
		return self:OpenFunCfg().kf_battle.trigger_param or 1
	end
	return 1
end

-- 返回1代表没有设置功能开启等级
function OpenFunData:GetOpenLevel(name)
	local single_cfg = self:GetSingleCfg(name)

	if single_cfg == nil then
		return 1
	end

	if single_cfg.trigger_type ~= OPEN_FUN_TRIGGER_TYPE.UPGRADE then
		return 1
	end

	if single_cfg.trigger_param then
		return single_cfg.trigger_param
	end
	return 1
end

function OpenFunData:GetNowDayOpenTrailerInfo()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local today_info, tomorrow_info = self:GetDayOpenTrailerCfg()
	local trailer_info = {}
	trailer_info.info_list = {}
	local i = 0
	for k,v in pairs(today_info) do
		if main_role_vo.level >= v.level_limit and self:GetDayTrailerLastRewardId(v.id) == 0 then
			i = i + 1
			trailer_info.is_tomorrow = false
			trailer_info.num = i
			table.insert(trailer_info.info_list, v)
		end
	end

	if i == 0 then
		for k,v in pairs(tomorrow_info) do
			i = i + 1
			trailer_info.is_tomorrow = true
			trailer_info.num = i
			table.insert(trailer_info.info_list, v)
		end
	end
	return trailer_info
end

-- 获取今日明日开启列表
function OpenFunData:GetDayOpenTrailerCfg()
	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if self.cur_day == open_server_day then
		return self.today_info, self.tomorrow_info
	end
	local today_info = {}
	local tomorrow_info = {}
	for k, v in ipairs(self.notice_day_cfg) do
		if v.open_day == open_server_day then
			table.insert(today_info, v)
		elseif v.open_day == open_server_day + 1 then
			table.insert(tomorrow_info, v)
		end
	end
	self.today_info = today_info
	self.tomorrow_info = tomorrow_info
	self.cur_day = open_server_day
	return self.today_info, self.tomorrow_info
end

function OpenFunData:GetNoticeItemIdById(id)
	if self.notice_list and self.notice_list[id] then
		if self.notice_list[id].reward_item and self.notice_list[id].reward_item[0] then
			return self.notice_list[id].reward_item[0].item_id
		end
	end
	return 0
end

function OpenFunData:GetNoticeList()
	return self.notice_list
end
