ExtremeChallengeData = ExtremeChallengeData or BaseClass()
function ExtremeChallengeData:__init()
	if nil ~= ExtremeChallengeData.Instance then
		return
	end
	ExtremeChallengeData.Instance = self

	self.task_list = {}
	self.reward_task_cfg = {}
	self.extreme_challenge_cfg = ConfigManager.Instance:GetAutoConfig("randactivityconfig_1_auto").extreme_challenge
end

function ExtremeChallengeData:__delete()
	ExtremeChallengeData.Instance = nil
end

function ExtremeChallengeData:SetExtremeChallengeInfo(protocol)
	self.task_list = protocol.task_list or {}
	self.is_have_fetch_ultimate_reward = protocol.is_have_fetch_ultimate_reward
end

function ExtremeChallengeData:GetExtremeChallengeConfig()
	return self.extreme_challenge_cfg
end

function ExtremeChallengeData:GetFetchUltimateRewardFlag()
	return self.is_have_fetch_ultimate_reward
end

function ExtremeChallengeData:GetTaskCount()
	local count = 0
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfigOtherCfg()
	if nil == cfg then
		return count
	end
	local count = cfg.extreme_challenge_rand_task_num
	return count
end

function ExtremeChallengeData:GetFlushNeedGold()
	local need_gold = 0
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfigOtherCfg()
	if nil == cfg then
		return need_gold
	end
	local need_gold = cfg.extreme_challenge_refresh_task_need_gold
	return need_gold
end

function ExtremeChallengeData:GetTaskInfoList()
	return self.task_list
end

function ExtremeChallengeData:GetRewardCfgByTaskId(index)
	local reward_cfg = {}
	if self.extreme_challenge_cfg ~= nil then
		for k,v in pairs(self.extreme_challenge_cfg) do
			if index == v.task_id then
				reward_cfg = v
			end
		end
	end
	return reward_cfg
end

function ExtremeChallengeData:GetRedPointStateByTaskId(task_id)
	local flag = 0
	for k,v in pairs(self.task_list) do
		if v.task_id == task_id and v.is_finish == 1 and v.is_already_fetch == 0 then
			flag = 1
			return flag
		end
	end
	return flag
end

function ExtremeChallengeData:GetCompleteTaskNum()
	local count = 0
	for k,v in pairs(self.task_list) do
		if v.is_finish == 1 then
			count = count + 1
		end
	end
	return count
end
