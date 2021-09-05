TianShuData = TianShuData or BaseClass()

function TianShuData:__init()
	if TianShuData.Instance ~= nil then
		print("[TianShuData] attempt to create singleton twice!")
		return		
	end
	TianShuData.Instance = self

	local config = ConfigManager.Instance:GetAutoConfig("tianshuxunzhu_cfg_auto")
	self.tianshu_config = config.runetime_use
	self.pass_skill_cfg = config.pass_skill
	self.tianshu_goal_cfg = ListToMap(config.goal_cfg, "seq", "type")
	self.goal_fetch_flag_list_t = {}
	self.goal_can_fetch_flag_list_t = {}
	self.zhuanzhi_equip_fangyu = 0
	self.equip_level_50 = 0
	self.equip_level_100 = 0
	self.baizhan_equip_num = 0
	RemindManager.Instance:Register(RemindName.TianShu, BindTool.Bind(self.GetTianshuRemind, self))
end

function TianShuData:__delete()
	TianShuData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.TianShu)
end

function TianShuData:SetTianshuXunzhuInfo(protocol)
	self.equip_level_50 = protocol.equip_level_50
	self.equip_level_100 = protocol.equip_level_100
	self.zhuanzhi_equip_fangyu = protocol.zhuanzhi_equip_fangyu
	self.baizhan_equip_num = protocol.baizhan_equip_num
	self.tianshu_xunzhu_goal_fetch_flag_list = protocol.fetch_flag_list
	self.tianshu_xunzhu_goal_can_fetch_flag_list = protocol.act_flag_list
	for i = 1, GameEnum.TIANSHU_MAX_TYPE do
		self.goal_fetch_flag_list_t[i] = bit:d2b(self.tianshu_xunzhu_goal_fetch_flag_list[i])
		self.goal_can_fetch_flag_list_t[i] = bit:d2b(self.tianshu_xunzhu_goal_can_fetch_flag_list[i])
	end
end

function TianShuData:GetZhuanZhiFangyuValue()
	return self.zhuanzhi_equip_fangyu
end

function TianShuData:GetEquipCount()
	return self.equip_level_50, self.equip_level_100
end

function TianShuData:GetFetchFlagList()
	return self.goal_fetch_flag_list_t, self.goal_can_fetch_flag_list_t
end

function TianShuData:GetBaiZhanEquipCount()
	return self.baizhan_equip_num
end

function TianShuData:GetTisnShuDataListByIndex(index)
	if nil == next(self.goal_fetch_flag_list_t) or nil == next(self.goal_can_fetch_flag_list_t) or nil == index
		or index < 1 or index > GameEnum.TIANSHU_MAX_TYPE then return nil end
	local prof = PlayerData.Instance:GetRoleBaseProf()
	local config = self.tianshu_config[index]
	local data_list = {}
	if not config or not next(config) then
		return data_list
	end
	local goal_count = config.goal_count or 0
	local param1_list = Split(config.param1_list, "|")
	local param2_list = Split(config.param2_list, "|")
	local reward_param_list = Split(config.reward_param_list, "|")
	local recommend = Split(config["recommend" .. prof], "|")
	local seq_list = Split(config.seq, "|")
	local recommend_list = {}
	for i = 1, goal_count do
		if recommend[i] then
			recommend_list[i] = Split(recommend[i], ",")
		end
	end

	local is_past = false
	local cur_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local openday, endday = TianShuData.Instance:GetTianShuTypeOpenDayByIndex(index)
	if endday ~= 0 and cur_open_day >= endday then
		is_past = true
	end

	for i = 1, goal_count do
		local data = {}
		data.index = index
		data.param1 = param1_list[i]
		data.param2 = tonumber(param2_list[i])
		data.reward = tonumber(reward_param_list[i])
		data.seq = tonumber(seq_list[i])
		data.desc = config.describe
		data.is_past = is_past
		data.fetch_flag = self.goal_fetch_flag_list_t[index][33 - i]
		data.final_fetch_flag = self.goal_fetch_flag_list_t[index][1]
		data.can_fetch_flag = self.goal_can_fetch_flag_list_t[index][33 - i]
		data.recommend_t = {}
		if next(recommend_list) and recommend_list[i] then
			for j = 1, #recommend_list[i] do
				data.recommend_t[j] = tonumber(recommend_list[i][j])
			end
		end
		data_list[i] = data
	end

	table.sort(data_list, function(a, b)
		if a.fetch_flag ~= b.fetch_flag then
			return a.fetch_flag < b.fetch_flag
		else
			return a.seq < b.seq
		end
	end )

	return data_list
end

function TianShuData:GetFinalRewardByIndex(index)
	if nil == index or index < 1 or index > GameEnum.TIANSHU_MAX_TYPE then
		return nil
	end
	local config = self.tianshu_config[index]
	local goal_count = config.goal_count or 0
	local final_reward_item = config.final_reward_item
	return final_reward_item
end

function TianShuData:GetFetchFlagdByIndex(index)
	if nil == next(self.goal_fetch_flag_list_t) or nil == next(self.goal_can_fetch_flag_list_t) or nil == index then
		return false, false
	end
	local fetch_flag = 1 == self.goal_fetch_flag_list_t[index][1]
	local can_fetch_flag = 1 == self.goal_can_fetch_flag_list_t[index][1]
	return fetch_flag, can_fetch_flag
end

function TianShuData:GetAllFetchFlag()
	if nil == next(self.goal_fetch_flag_list_t) then return nil end

	local all_fetch_flag_t = {}
	for i = 1, GameEnum.TIANSHU_MAX_TYPE do
		all_fetch_flag_t[i] = (1 == self.goal_fetch_flag_list_t[i][1])
	end

	return all_fetch_flag_t
end

function TianShuData:GetRemindByIndex(index)
	if nil == next(self.goal_fetch_flag_list_t) or nil == next(self.goal_can_fetch_flag_list_t) or nil == index
		or index < 1 or index > GameEnum.TIANSHU_MAX_TYPE then return 0 end

	local config = self.tianshu_config[index]
	local goal_count = config.goal_count or 0
	local remind_num = 0

	for i = 1, goal_count do
		remind_num = remind_num + (self.goal_fetch_flag_list_t[index][33 - i] < self.goal_can_fetch_flag_list_t[index][33 - i] and 1 or 0)
	end
	remind_num = remind_num + (self.goal_fetch_flag_list_t[index][1] < self.goal_can_fetch_flag_list_t[index][1] and 1 or 0)

	return remind_num
end

function TianShuData:GetAllRemind()
	local remind_num = 0
	for index = 1, GameEnum.TIANSHU_MAX_TYPE do
		local cur_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
		local openday, endday = TianShuData.Instance:GetTianShuTypeOpenDayByIndex(index)
		if cur_open_day >= openday then
			remind_num = remind_num + self:GetRemindByIndex(index)
		end
	end
	return remind_num
end

function TianShuData:GetTianshuRemind()
	if not RemindManager.Instance:RemindToday(RemindName.TianShu) then
		return 1
	end
	return self:GetAllRemind()
end

function TianShuData:GetCurIndex()
	if nil == self.goal_fetch_flag_list_t or nil == next(self.goal_fetch_flag_list_t) then return 1 end

	for i = 1, GameEnum.TIANSHU_MAX_TYPE do
		if 0 == self.goal_fetch_flag_list_t[i][1] then
			return i
		end
	end
	return 1
end

function TianShuData:GetTabIndexAndIndexByBossId(boss_id)
	local boss_list = BossData.Instance:GetWorldBossList()
	for k, v in pairs(boss_list) do
		if boss_id == v.boss_id then
			return {tab_index = 1, page_index = math.ceil((k + 1) / 8), select_index = k}
		end
	end

	return nil
end

function TianShuData:GetTianShuIsFetch(value)
	if self.goal_fetch_flag_list_t[value + 1] == nil then return false end
	return self.goal_fetch_flag_list_t[value + 1][1] == 1
end


function TianShuData:FlySkillIconID(select_index)
	local data_list =  ConfigManager.Instance:GetAutoConfig("tianshuxunzhu_cfg_auto").runetime_use
	local other_cfg = ConfigManager.Instance:GetAutoConfig("tianshuxunzhu_cfg_auto").other[1]
	if select_index < 4 then
		for k,v in ipairs(data_list) do 
			if select_index == v.type then
				return v.skill_id
			end
		end
	else
		return other_cfg.shouhu_skill_id
	end
end

function TianShuData:TianShuSkillName(res_id)
	local skill_auto = ConfigManager.Instance:GetAutoConfig("roleskill_auto").passive_skill
	for k,v in ipairs(skill_auto) do
		if res_id == v.icon then
			return v.name 
		end
	end
	return ""
end


function TianShuData:GetTianShuTypeNameByIndex(index)
	if self.tianshu_config and self.tianshu_config[index] then
		return self.tianshu_config[index].type_name
	end
	return ""
end

function TianShuData:GetTianShuDescNameByIndex(index)
	if self.pass_skill_cfg and self.pass_skill_cfg[index] then
		return self.pass_skill_cfg[index].skill_desc
	end
	return ""
end

function TianShuData:GetTianShuGoalCountByIndex(index)
	if self.tianshu_config and self.tianshu_config[index] then
		return self.tianshu_config[index].goal_count
	end
	return 0
end

function TianShuData:GetCfgTypeAndSeq(type, seq)
	if self.tianshu_goal_cfg and self.tianshu_goal_cfg[seq] and self.tianshu_goal_cfg[seq][type] then
		return self.tianshu_goal_cfg[seq][type]
	end
	return nil
end

function TianShuData:GetOpenPanelByTypeAndSeq(type, seq)
	if self.tianshu_goal_cfg and self.tianshu_goal_cfg[seq] and self.tianshu_goal_cfg[seq][type] then
		return self.tianshu_goal_cfg[seq][type].open_view_parm
	end
	return nil
end

function TianShuData:GetShowIconByTypeAndSeq(type, seq)
	if self.tianshu_goal_cfg and self.tianshu_goal_cfg[seq] and self.tianshu_goal_cfg[seq][type] then
		return self.tianshu_goal_cfg[seq][type].icon_show
	end
	return nil
end

function TianShuData:IsOpenTianShu()
	if nil == self.goal_fetch_flag_list_t or nil == next(self.goal_fetch_flag_list_t) then return false end
	local open_list = self:GetTianShuOpenType()
	if not open_list or not next(open_list) then
		return false
	end
	for k, v in ipairs (open_list) do
		if 0 == self.goal_fetch_flag_list_t[v][1] then
			local cur_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
			local role_level = PlayerData.Instance:GetRoleLevel()
			local openday, endday = TianShuData.Instance:GetTianShuTypeOpenDayByIndex(v)
			local type_cfg = self:GetTianShuTypeCfgByIndex(v)
			if type_cfg and type_cfg.open_level and type_cfg.end_level and role_level >= type_cfg.open_level and
				role_level <= type_cfg.end_level and  endday ~= 0 and cur_open_day >= endday then
				local config = self.tianshu_config[v]
				if config and next(config) then
					local goal_count = config.goal_count or 0
					for index = 1, goal_count do
						if self.goal_fetch_flag_list_t[v][33 - index] == 0 and self.goal_can_fetch_flag_list_t[v][33 - index] == 1 then
							return true
						end
					end
				end
			else
				return true
			end
		end
	end
	return false
end

function TianShuData:IsOpenTianshuType(index)
	if nil == self.goal_fetch_flag_list_t or nil == next(self.goal_fetch_flag_list_t) then return false end
	local type_cfg = self:GetTianShuTypeCfgByIndex(index)
	local cur_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local openday, endday = TianShuData.Instance:GetTianShuTypeOpenDayByIndex(index)
	local role_level = PlayerData.Instance:GetRoleLevel()
	if cur_open_day < openday then
		return false
	end
	if not type_cfg then
		return false
	end

	if role_level < type_cfg.open_level or role_level > type_cfg.end_level then
		return false
	end
	if endday ~= 0 and cur_open_day >= endday then
		local config = self.tianshu_config[index]
		if config and next(config) then
			local goal_count = config.goal_count or 0
			for i = 1, goal_count do
				if self.goal_fetch_flag_list_t[index][33 - i] == 0 and self.goal_can_fetch_flag_list_t[index][33 - i] == 1 then
					return true
				end
			end
		end
	else
		return true
	end
	return false
end

function TianShuData:GetTianShuTypeOpenDayByIndex(index)
	if self.tianshu_config and self.tianshu_config[index] then
		return self.tianshu_config[index].open_day, self.tianshu_config[index].end_day
	end
	return 0, 0
end

function TianShuData:GetTianShuTypeCfgByIndex(index)
	if self.tianshu_config and self.tianshu_config[index] then
		return self.tianshu_config[index]
	end
	return nil
end

function TianShuData:GetTianShuSelectType()
	local select_index = 1
	local open_list = self:GetTianShuOpenType()
	if nil == self.goal_fetch_flag_list_t or nil == next(self.goal_fetch_flag_list_t) or nil == next(open_list) then return select_index end
	select_index = open_list[1]
	for k, v in ipairs(open_list) do
		local type_cfg = self:GetTianShuTypeCfgByIndex(v)
		local role_level = PlayerData.Instance:GetRoleLevel()
		local config = self.tianshu_config[v]
		local goal_count = config.goal_count or 0
		if self.goal_fetch_flag_list_t[v][1] == 1 then
			if v <= select_index then
				select_index = k >= #open_list and v or open_list[k + 1]
			end
		else
			for index = 1, goal_count do
				if self.goal_fetch_flag_list_t[v][33 - index] == 0 and self.goal_can_fetch_flag_list_t[v][33 - index] == 1
					or (self.goal_fetch_flag_list_t[v][1] == 0 and self.goal_can_fetch_flag_list_t[v][1] == 1) then
					return v
				end
			end
		end
	end
	return select_index
end

function TianShuData:GetTianShuOpenType()
	local open_list = {}
	for i = 1, GameEnum.TIANSHU_MAX_TYPE do
		if self:IsOpenTianshuType(i) then
			table.insert(open_list, i)
		end
	end
	return open_list
end
