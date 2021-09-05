KuaFuBorderlandData = KuaFuBorderlandData or BaseClass()

function KuaFuBorderlandData:__init()
	if KuaFuBorderlandData.Instance ~= nil then
		ErrorLog("[KuaFuBorderlandData] Attemp to create a singleton twice !")
	end

	KuaFuBorderlandData.Instance = self



	self.cross_bianjingzhidi_cfg = ConfigManager.Instance:GetAutoConfig("cross_bianjingzhidi_auto")
	self.flush_point_list = ListToMap(self.cross_bianjingzhidi_cfg.flush_point, "id")
	self.cross_bianjingzhidi_boss_cfg = ListToMapList(self.cross_bianjingzhidi_cfg.boss_id, "boss_type")

	self.task_scroller_data = {}
	self.zhaoji_data = {}
	self.act_map_tip = true
end

function KuaFuBorderlandData:__delete()
	KuaFuBorderlandData.Instance = nil

	if self.world_level_change_handle then
		GlobalEventSystem:UnBind(self.world_level_change_handle)
		self.world_level_change_handle = nil
	end
	self.zhaoji_data = {}
	self.act_map_tip = true
end

-- 任务信息
function KuaFuBorderlandData:SetSCCrossBianJingZhiDiUserInfo(protocol)
	self.fb_data = protocol
	self:FlushKFBorderlandTaskInfo()
	self:TaskMonitor()
	self.task_list = protocol.taskinfo_list
	-- print_error(self.fb_data.sos_times, self.fb_data)

end

-- Boss信息
function KuaFuBorderlandData:SetSCCrossBianJingZhiDiBossInfo(protocol)
	self.boss_list = protocol.boss_list
	self:FlushBossList()
end

-- 伤害排行
function KuaFuBorderlandData:SetSCCrossBianJingZhiDiBossHurtInfo(protocol)
	self.rank_info = protocol
	self.rank_list = protocol.rank_list
end

------------------任务
--获得活动副本信息
function KuaFuBorderlandData:GetKFBorderlandInfo()
	return self.fb_data
end

function KuaFuBorderlandData:GetKFBorderlandBuffTime()
	if self.fb_data then
		return self.fb_data.gather_buff_time
	end
	return 0
end

function KuaFuBorderlandData:GetKFBorderlandSosTimes()
	if self.fb_data then
		return self.fb_data.sos_times
	end
	return 0
end

function KuaFuBorderlandData:TaskMonitor()
	if self.task_list ~= nil and self.task_change_callback ~= nil then
		for k,v in pairs(self.fb_data.taskinfo_list) do
			if v.task_id == self.monitor_task_id then
				if v.cur_param_value > self.task_list[k].cur_param_value then
					self.task_change_callback()
				end
				break
			end
		end
	end
end

function KuaFuBorderlandData:FlushKFBorderlandTaskInfo()
	self.task_scroller_data = {}
	local finish_task_list = {}
	local un_finish_task_list = {}
	for k,v in pairs(self.fb_data.taskinfo_list) do
		local task_cfg = self:GetTaskCfgByID(v.task_id)
		local text = ""
		-- if task_cfg.task_type == 1 then
		-- 	--采集
		-- 	local gather_cfg = ConfigManager.Instance:GetAutoConfig("gather_auto").gather_list[task_cfg.param_id]
		-- 	text = text..gather_cfg.name
		-- elseif task_cfg.task_type == 2 then
		-- 	--打怪
		-- 	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[task_cfg.param_id]
		-- 	text = text..monster_cfg.name
		-- else
		-- 	text = text .. task_cfg.task_desc
		-- end
		text = text .. task_cfg.task_desc

		if v.is_finish == 1 then
			--完成
			text = text..Language.TombExplore.HaveReached
		else
			if v.cur_param_value < v.param_count then
				local Num_txt = string.format(Language.TombExplore.KillMonsterText,ToColorStr(v.cur_param_value, TEXT_COLOR.RED_4),v.param_count) 
				text = text..Num_txt
			else
				local Num_txt = string.format(Language.TombExplore.KillMonsterText,v.cur_param_value,v.param_count) 
				text = text..Num_txt
			end
		end

		local data = {}
		data.cfg = task_cfg
		data.target_text = text
		data.is_double_reward = (v.is_double_reward == 1)
		data.is_finish = (v.is_finish == 1)

		if data.is_finish then
			table.insert(finish_task_list, data)
		elseif data.is_double_reward then
			table.insert(self.task_scroller_data, data)
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

function KuaFuBorderlandData:GetKFBorderlandTaskInfo()
	return self.task_scroller_data
end

--获得副本任务配置
function KuaFuBorderlandData:GetTaskCfgByID(task_id)
	for k,v in pairs(self.cross_bianjingzhidi_cfg.task_list) do
		if v.task_id == task_id then
			return v
		end
	end
end

function KuaFuBorderlandData:NotifyTaskProcessChange(task_id, func)
	self.task_change_callback = func
	self.monitor_task_id = task_id
end

function KuaFuBorderlandData:UnNotifyTaskProcessChange()
	self.task_change_callback = nil
end


--------------Boss
-- 获取Boss刷新时间
function KuaFuBorderlandData:GetBossReflushTime()
	if self.fb_data then
		return self.fb_data.boss_reflush_time
	end
	return 0
end

-- 获取BOSS列表
function KuaFuBorderlandData:FlushBossList()
	table.sort(self.boss_list, function (a, b)
		return a.boss_live_flag > b.boss_live_flag
	end)
end

function KuaFuBorderlandData:GetIsFlushBossFirst()
	return self.boss_list and next(self.boss_list) == nil
end

-- 获取BOSS列表
function KuaFuBorderlandData:GetActBossList()
	if self.boss_list and next(self.boss_list) == nil then
		return self:GetTempActBossList()
	end
	return self.boss_list or self:GetTempActBossList()
end

-- 获取无BOSS存活时的信息列表
function KuaFuBorderlandData:GetTempActBossList()
	local num = GetListNum(self.cross_bianjingzhidi_cfg.boss)
	local list = {}
	local world_level = RankData.Instance:GetWordLevel()
	local temp_level = nil
	local index = 1
	for i,v in ipairs(self.cross_bianjingzhidi_boss_cfg[0]) do
		if world_level >= v.world_level then
			index = i
			temp_level = v.world_level
		end
	end
	for i = 1, num do
		local boss_data = {}
		if self.cross_bianjingzhidi_boss_cfg[i - 1] and self.cross_bianjingzhidi_boss_cfg[i - 1][index] and self.flush_point_list[i] then
			boss_data.boss_id = self.cross_bianjingzhidi_boss_cfg[i - 1][index].boss_id
			boss_data.boss_live_flag = 0
			boss_data.born_pos_x = self.flush_point_list[i].pos_x
			boss_data.born_pos_y = self.flush_point_list[i].pos_y
			boss_data.level = temp_level or 0 
			boss_data.boss_obj = nil
			boss_data.guild_uuid = nil
			boss_data.guild_name = nil
			boss_data.is_false = true
			table.insert(list, boss_data)
		end
	end
	return list
end

-- 活动BOSS存活信息
function KuaFuBorderlandData:SetSCCrossServerBianJingZhiDiBossInfo(protocol)
	self.boss_info = protocol
end

function KuaFuBorderlandData:GetSCCrossServerBianJingZhiDiBossInfo()
	return self.boss_info or {}
end

---------------排行
-- 伤害排行
function KuaFuBorderlandData:GetRankInfo()
	return self.rank_info or {}
end

function KuaFuBorderlandData:GetKFBorderlandRankList()
	local rank_list = {}
	for i = 1, 5 do
		if self.rank_list and self.rank_list[i] then
			rank_list[i] = self.rank_list[i]
		else
			local tamp_data = {}
			tamp_data.id = ""
			tamp_data.guild_name = "--"
			tamp_data.hurt = 0
			rank_list[i] = tamp_data
		end
	end
	return rank_list
end


---------------------召集
function KuaFuBorderlandData:SetKFBorderlandZhaojiData(protocol)
	-- print_error(protocol)
	table.insert(self.zhaoji_data, protocol)
end

function KuaFuBorderlandData:GetKFBorderlandZhaojiData()
	local temp_tab = table.remove(self.zhaoji_data, 1)
	return temp_tab
end



--------------------Other
function KuaFuBorderlandData:GetKFBorderlandActivityOtherCfg()
	return self.cross_bianjingzhidi_cfg.other[1]
end

function KuaFuBorderlandData:GetOpenActTimeCfg()
	local cfg = self.cross_bianjingzhidi_cfg.activity_open_time
	local week_day = tonumber(os.date("%w", os.time()))
	for k, v in pairs(cfg) do
		if week_day == v.activity_week_day then
			return v
		end
	end
end

function KuaFuBorderlandData:GetZhaoJiCost()
	local sos_times = self:GetKFBorderlandSosTimes()
	local sos_cfg = self.cross_bianjingzhidi_cfg.sos_cfg or {}
	for i,v in ipairs(sos_cfg) do
		if v and v.times == sos_times then
			return v.cost
		end
	end
	return 0
end

function KuaFuBorderlandData:GetZhaoJiMaxCost()
	local sos_cfg = self.cross_bianjingzhidi_cfg.sos_cfg or {}
	return sos_cfg and sos_cfg[#sos_cfg].times or 0
end

function KuaFuBorderlandData:SetActMapTipFrame()
	self.act_map_tip = false
end

function KuaFuBorderlandData:GetActMapTipFrame()
	return self.act_map_tip
end

function KuaFuBorderlandData:GetActStates()
	return self.kf_borderland_act_state
end

function KuaFuBorderlandData:SetActStates(act_state)
	self.kf_borderland_act_state = act_state
end

