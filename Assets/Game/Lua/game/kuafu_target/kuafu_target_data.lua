KuaFuTargetData = KuaFuTargetData or BaseClass()

local SORTWEIGHT = {[0] = 2, [1] = 1, [2] = 3}
local SORTNUM = 8

local CONDTYPELIST = {
	CROSS_GOAL_COND_KILL_CROSS_BOSS = 1,					--个人击杀神域boss数
	CROSS_GOAL_COND_CROSS_BOSS_ROLE_KILL = 2,				--个人击杀神域场景内玩家数
	CROSS_GOAL_COND_FINISH_BAIZHAN_TASK = 3,				--个人完成百战任务数
	CROSS_GOAL_COND_KILL_BAIZHAN_BOSS = 4,					--个人击杀百战boss数
	CROSS_GOAL_COND_GUILD_KILL_CROSS_BOSS = 5,				--公会击杀神域boss数
	CROSS_GOAL_COND_GUILD_KILL_BAIZHAN_BOSS = 6,			--公会击杀百战boss数
	CROSS_GOAL_COND_FINISH_ALL_BEFORE = 100,					--完成所有目标
}

function KuaFuTargetData:__init()
	if nil ~= KuaFuTargetData.Instance then
		return
	end
	KuaFuTargetData.Instance = self

	self.task_list = {}
	self.crossgolb_cfg = ConfigManager.Instance:GetAutoConfig("cross_goal_auto") or {}
	self.other_cfg = self.crossgolb_cfg.other
	self.is_remind = true
	self.select_index = 1
	self.fetch_reward_flag = {}
	self.item_cfg = {}
	self.item_cfg[1] = self.crossgolb_cfg.cross_goal_item
	self.item_cfg[2] = self.crossgolb_cfg.guild_goal_item
	RemindManager.Instance:Register(RemindName.KuaFuTarget, BindTool.Bind(self.GetKuaFuTargetRed, self))
end

function KuaFuTargetData:__delete()
	KuaFuTargetData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.KuaFuTarget)
end

function KuaFuTargetData:SetExtremeChallengeInfo(protocol)
	self.kill_cross_boss_num = protocol.kill_cross_boss_num
	self.cross_boss_role_killer = protocol.cross_boss_role_killer
	self.kill_baizhan_boss_num = protocol.kill_baizhan_boss_num
	self.finish_baizhan_task_num = protocol.finish_baizhan_task_num
	self.guild_kill_cross_boss = protocol.guild_kill_cross_boss
	self.guild_kill_baizhan_boss = protocol.guild_kill_baizhan_boss
	self.fetch_reward_flag[1] = protocol.fetch_reward_flag
	self.fetch_reward_flag[2] = protocol.fetch_reward_flag2
	-- local guild_notify_cur_finish = protocol.guild_notify_cur_finish
	-- if guild_notify_cur_finish == 1 then
		-- self:NoFinishChat(protocol.guild_kill_cross_boss, protocol.guild_kill_baizhan_boss)
	-- end
end

function KuaFuTargetData:SetGoalGuildNotify(protocol)
	local flag = protocol.flag
	local guild_kill_cross_boss = protocol.guild_kill_cross_boss or 0
	local guild_kill_baizhan_boss = protocol.guild_kill_baizhan_boss or 0
	self:NoFinishChat(guild_kill_cross_boss, guild_kill_baizhan_boss)
end

function KuaFuTargetData:NoFinishChat(guild_kill_cross_boss, guild_kill_baizhan_boss)
	if self.fetch_reward_flag[2] ~= nil and self.item_cfg[2] ~= nil then
		for k, v in pairs(self.fetch_reward_flag[2]) do
			if v == 0 then
				if self.item_cfg[2][k] ~= nil and self.item_cfg[2][k].cond_type and self.item_cfg[2][k].cond_type <= CONDTYPELIST.CROSS_GOAL_COND_GUILD_KILL_BAIZHAN_BOSS then
					local kill_num = 0
					local cond_type = self.item_cfg[2][k].cond_type or 5
					kill_num = cond_type == 5 and guild_kill_cross_boss or guild_kill_baizhan_boss
					local cond_param = self.item_cfg[2][k].cond_param or 0
					cond_param = tonumber(cond_param)
					local is_finish = kill_num >= cond_param
					local color = is_finish and TEXT_COLOR.GREEN or TEXT_COLOR.RED
					local str1 = string.format(Language.CrossGolb["NoFinishTask" .. cond_type], cond_param)
					local str2 = string.format(Language.CrossGolb.NoFinishNum, color, kill_num, cond_param)
					local des = str1 .. str2

					local str = ""
					-- local cond_type = self.item_cfg[2][k].cond_type or 5
					-- local cond_param = self.item_cfg[2][k].cond_param or 0
					-- local des = string.format(Language.CrossGolb["NoFinishTask" .. cond_type], tonumber(cond_param))
					str = Language.CrossGolb.NoFinishChat .. des .. Language.CrossGolb.NoFinishChat2
					ChatCtrl.Instance:LocalNotifyGuild(str)
				end
			end
		end
	end
end

function KuaFuTargetData:GetOpenAndEndDay()
	if self.other_cfg ~= nil and self.other_cfg[1] then
		return self.other_cfg[1].open_day_beg, self.other_cfg[1].open_day_end
	end
	return 0, 0
end

function KuaFuTargetData:GetOpenLevel()
	if self.other_cfg ~= nil and self.other_cfg[1] then 
		return self.other_cfg[1].open_level
	end
	return 0
end

function KuaFuTargetData:GetItemData(index)
	if self.item_cfg ~= nil then
		local item_cfg_sort = self:SortItemData()
		if index ~= nil then
			return item_cfg_sort[index] 
		end
		return item_cfg_sort
	end
end

function KuaFuTargetData:SortItemData()
	local item_cfg_sort = {}
	if self.item_cfg ~= nil and self.fetch_reward_flag ~= nil and self.item_cfg[self.select_index] ~= nil and self.fetch_reward_flag[self.select_index] ~= nil then
		for i = 1, 3 do
			for j = 1, SORTNUM do
				local flag = self.fetch_reward_flag[self.select_index][j] or 0
				if SORTWEIGHT[flag] == i then
					table.insert(item_cfg_sort, self.item_cfg[self.select_index][j])
				end
			end
		end
	end
	return item_cfg_sort
end

function KuaFuTargetData:GetFinishAllBeforeItemData()
	local reward_item = {}
	if self.item_cfg ~= nil and self.item_cfg[self.select_index] ~= nil then
		for k, v in pairs(self.item_cfg[self.select_index]) do
			if v.cond_type == CONDTYPELIST.CROSS_GOAL_COND_FINISH_ALL_BEFORE then
				return v.reward_item
			end
		end
	end
	return reward_item
end

function KuaFuTargetData:GetParamByCondType(cond_type)
	if cond_type == CONDTYPELIST.CROSS_GOAL_COND_KILL_CROSS_BOSS then
		return self.kill_cross_boss_num or 0
	elseif cond_type == CONDTYPELIST.CROSS_GOAL_COND_CROSS_BOSS_ROLE_KILL then
		return self.cross_boss_role_killer or 0
	elseif cond_type == CONDTYPELIST.CROSS_GOAL_COND_FINISH_BAIZHAN_TASK then
		return self.finish_baizhan_task_num or 0
	elseif cond_type == CONDTYPELIST.CROSS_GOAL_COND_KILL_BAIZHAN_BOSS then
		return self.kill_baizhan_boss_num or 0
	elseif cond_type == CONDTYPELIST.CROSS_GOAL_COND_GUILD_KILL_CROSS_BOSS then
		return self.guild_kill_cross_boss or 0
	elseif cond_type == CONDTYPELIST.CROSS_GOAL_COND_GUILD_KILL_BAIZHAN_BOSS then
		return self.guild_kill_baizhan_boss or 0
	end
	return 0
end

-- function KuaFuTargetData:GetFinishBaiZhanTaskNum()
-- 	return self.finish_baizhan_task_num or 0
-- end

-- function KuaFuTargetData:GetBaiZhanBossKillNum()
-- 	return self.kill_baizhan_boss_num or 0
-- end

-- function KuaFuTargetData:GetBossKillNum()
-- 	return self.kill_cross_boss_num or 0
-- end

-- function KuaFuTargetData:GetRoleKillNum()
-- 	return self.cross_boss_role_killer or 0
-- end

function KuaFuTargetData:SetToggleIndex(index)
	self.select_index = index
end

function KuaFuTargetData:GetToggleIndex()
	return self.select_index
end

function KuaFuTargetData:GetFetchUltimateRewardFlag(index)
	if self.fetch_reward_flag ~= nil and self.fetch_reward_flag[self.select_index] ~= nil then
		if index ~= nil then
			return self.fetch_reward_flag[self.select_index][index] or 0
		end
		return self.fetch_reward_flag[self.select_index]
	end
end

function KuaFuTargetData:GetTaskCount()
	return self.item_cfg[self.select_index] and #self.item_cfg[self.select_index] - 1 or 0
end

function KuaFuTargetData:GetKuaFuTargetRed()
	if self.is_remind then
		self.is_remind = false
		return 1
	end
	for i = 1, 2 do
		if self:GetTabRemind(i) > 0 then
			return 1
		end
	end
	return 0
end

function KuaFuTargetData:GetTabRemind(index)
	if self.fetch_reward_flag ~= nil and self.fetch_reward_flag[index] ~= nil then
		for k, v in pairs(self.fetch_reward_flag[index]) do
			if v == 1 then
				return 1
			end
		end
	end
	return 0
end