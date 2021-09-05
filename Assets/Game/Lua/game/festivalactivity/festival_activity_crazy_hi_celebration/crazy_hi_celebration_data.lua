CrazyHiCelebrationData = CrazyHiCelebrationData or BaseClass()
function CrazyHiCelebrationData:__init()
	if nil ~= CrazyHiCelebrationData.Instance then
		return
	end
	CrazyHiCelebrationData.Instance = self

	self.crazy_hi_reward_cfg = ConfigManager.Instance:GetAutoConfig("randactivityconfig_1_auto").kuang_hai_reward or {}
	self.crazy_hi_celebration_cfg = ConfigManager.Instance:GetAutoConfig("randactivityconfig_1_auto").kuang_hai or {}
	self.reward_data_list = {}
end

function CrazyHiCelebrationData:__delete()
	CrazyHiCelebrationData.Instance = nil
end

---------------------------接收协议数据------------------------------
function CrazyHiCelebrationData:SetCrazyCelebrationInfo(protocol)
	self.reward_flag = bit:d2b(protocol.reward_flag) 
	self.current_score = protocol.current_score
	self.task_list = protocol.task_list
end
---------------------------协议数据结束-------------------------------

--获取当前嗨点数
function CrazyHiCelebrationData:GetCurrentScore()
	return self.current_score or 0
end

--将根据服务器结果将兑换状态添加到奖励配置中
function CrazyHiCelebrationData:GetTidyRewardInfoList()
	self.reward_data_list = {}
	if self.reward_flag == nil then 
		return self.reward_data_list
	end
	local tidy_crazy_hi_reward_cfg = TableCopy(self.crazy_hi_reward_cfg)
	for k,v in pairs(tidy_crazy_hi_reward_cfg) do
		-- 能否兑换
		local can_fetch_flag = 0
		if v.need_score and v.need_score <= self.current_score then
			can_fetch_flag = 1
		end
		-- 是否兑换
		had_fetch_flag = self.reward_flag[32 - v.reward_seq]
		v.can_fetch_flag = can_fetch_flag
		v.had_fetch_flag = had_fetch_flag
		table.insert(self.reward_data_list, v)
	end
	table.sort(self.reward_data_list, SortTools.KeyLowerSorter("had_fetch_flag", "need_score"))
	return self.reward_data_list
end

--将服务器任务信息添加到任务信息配置中
function CrazyHiCelebrationData:GetCrazyHiCelebrationInfoList()
	local finish_task_list = {}
	local unfinished_task_list = {}
	if self.task_list == nil then 
		return  unfinished_task_list
	end
	local task_cfg = TableCopy(self.crazy_hi_celebration_cfg)
	for k,v in pairs(self.task_list) do
		for k1,v1 in pairs(task_cfg) do
			if v.item_idx and v.item_idx == v1.index then
				if v1.open_param and string.find(v1.open_param, "fb_phase") then
					local num_list = FuBenData.Instance:GetOpenToggleNum()
					if num_list and #num_list > 0 then
						v1.score = v.get_score
						if v1.max_score ~= v.get_score then
							table.insert(unfinished_task_list, v1)
						else
							table.insert(finish_task_list, v1)
						end
					end
				else
					v1.score = v.get_score
					if v1.max_score ~= v.get_score then
						table.insert(unfinished_task_list, v1)
					else
						table.insert(finish_task_list, v1)
					end
				end
			end
		end
	end
	if finish_task_list and next(finish_task_list) then
		for k,v in pairs(finish_task_list) do
			table.insert(unfinished_task_list, v)
		end
	end
	return unfinished_task_list
end

--红点逻辑
function CrazyHiCelebrationData:CrazyHiCelebrationRedPoint()
	local flag = 0
	if next(self.reward_data_list) == nil then
		return flag
	end
	for k,v in pairs(self.reward_data_list) do
		if v.can_fetch_flag == 1 and v.had_fetch_flag == 0 then
			flag = 1
			return flag
		end
	end
	return flag
end
