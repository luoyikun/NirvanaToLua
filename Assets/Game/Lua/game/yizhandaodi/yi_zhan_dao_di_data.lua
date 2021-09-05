YiZhanDaoDiData = YiZhanDaoDiData or BaseClass()

-- 踢出理由
KICKOUT_BATTLE_FIELD_REASON =
{
	KICKOUT_BATTLE_FIELD_REASON_INVALID = 0,
	KICKOUT_BATTLE_FIELD_REASON_DEAD_ISOUT = 1,										-- 复活次数没了
	KICKOUT_BATTLE_FIELD_REASON_TIMEOUT = 2,										-- 战场时间到了
}

-- 鼓舞类型
YIZHANDAODI_GUWU_TYPE =
{
	YIZHANDAODI_GUWU_TYPE_INVALID = 0,
	YIZHANDAODI_GUWU_TYPE_GONGJI = 1,
	YIZHANDAODI_GUWU_TYPE_MAXHP = 2,
}

YIZHANDAODI_RANK_NUM = 20

function YiZhanDaoDiData:__init()
	if YiZhanDaoDiData.Instance then
		print_error("[YiZhanDaoDiData] Attempt to create singleton twice!")
		return
	end
	YiZhanDaoDiData.Instance = self

	self.yi_zhan_dao_di_rank_info = {}
	self.yi_zhan_dao_di_title_change_info = {}
	self.yi_zhan_dao_di_lucky_info = {}
	self.yi_zhan_dao_di_kickout_info = {}
	self.yi_zhan_dao_di_user_info = {kill_num_reward_flag = 0}
	self.last_first_info = {}
	self.my_score = 0
	self.my_rank = 0

	self.yizhandaodi_cfg = ConfigManager.Instance:GetAutoConfig("yizhandaodiconfig_auto")
end

function YiZhanDaoDiData:__delete()
	YiZhanDaoDiData.Instance = nil
end

-- 排行榜信息
function YiZhanDaoDiData:SetYiZhanDaoDiRankInfo(protocol)
	self.my_score = protocol.self_score
	self.my_rank = protocol.self_rand_pos
	self.yi_zhan_dao_di_rank_info = protocol.rank_list
end

function YiZhanDaoDiData:GetMyRankPos()
	return self.my_rank or 0
end

function YiZhanDaoDiData:GetYiZhanDaoDiRankInfo()
	return self.yi_zhan_dao_di_rank_info
end

function YiZhanDaoDiData:IsUserInRank()
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	local role_id = game_vo.role_id
	for k, v in pairs(self.yi_zhan_dao_di_rank_info) do
		if role_id == v.uid then
			return true, k
		end
	end
	return false, -1
end

-- 称号改变
function YiZhanDaoDiData:SetYiZhanDaoDiTitleChangeInfo(protocol)
	self.yi_zhan_dao_di_title_change_info = protocol
end

function YiZhanDaoDiData:GetYiZhanDaoDiTitleChangeInfo()
	return self.yi_zhan_dao_di_title_change_info
end

-- 幸运玩家信息
function YiZhanDaoDiData:SetYiZhanDaoDiLuckyInfo(protocol)
	self.yi_zhan_dao_di_lucky_info = protocol
end

function YiZhanDaoDiData:GetLuckyRewardNameList()
	return self.yi_zhan_dao_di_lucky_info.luck_user_namelist or {}
end

function YiZhanDaoDiData:GetLuckyRewardNextFlushTime()
	return self.yi_zhan_dao_di_lucky_info.next_lucky_timestamp or 0
end

-- 踢出信息
function YiZhanDaoDiData:SetYiZhanDaoDiKickoutInfo(protocol)
	self.yi_zhan_dao_di_kickout_info = protocol
end

function YiZhanDaoDiData:GetYiZhanDaoDiKickoutInfo()
	return self.yi_zhan_dao_di_kickout_info
end

-- function YiZhanDaoDiData:SetYiZhanDaoDiRankTopInfo(protocol)
-- 	self.rank_top_list = protocol
-- end

-- function YiZhanDaoDiData:GetYiZhanDaoDiTopInfo()
-- 	return self.rank_top_list
-- end

-- 主角信息
function YiZhanDaoDiData:SetYiZhanDaoDiUserInfo(protocol)
	self.yi_zhan_dao_di_user_info = protocol
end

function YiZhanDaoDiData:GetYiZhanDaoDiUserInfo()
	return self.yi_zhan_dao_di_user_info
end

function YiZhanDaoDiData:GetGuWuValue()
	if Scene.Instance:GetSceneType() ~= SceneType.ChaosWar then
		return 0
	end
	return self.yi_zhan_dao_di_user_info.gongji_guwu_per or 0
end

-- 上一次第一名玩家信息
function YiZhanDaoDiData:SetYiZhanDaoDiLastFirstInfo(protocol)
	self.last_first_info = protocol
end

function YiZhanDaoDiData:GetYiZhanDaoDiLastFirstInfo()
	return self.last_first_info
end

-- function YiZhanDaoDiData:GetRankTopThree()
-- 	local rank_list = self:GetYiZhanDaoDiTopInfo()
-- 	local top_three_list = {}
-- 	if rank_list then
-- 		for k,v in pairs(rank_list.name_list) do
-- 			if v then
-- 				table.insert(top_three_list, v)
-- 			end
-- 		end
-- 	end
-- 	return top_three_list
-- end

----------- 配置表 ----------

--排行榜奖励
function YiZhanDaoDiData:GetKillRankRewardCfg()
	if nil == self.rank_reward_cfg then
		self.rank_reward_cfg = self.yizhandaodi_cfg.kill_rank_reward
		table.sort(self.rank_reward_cfg, function(a, b)
			return a.rank < b.rank
		end)
	end

	return self.rank_reward_cfg
end

function YiZhanDaoDiData:GetOtherCfg()
	return self.yizhandaodi_cfg.other[1]
end

function YiZhanDaoDiData:GetTitleCfg()
	local title_cfg = {}
	if self.yizhandaodi_cfg then
		title_cfg = self.yizhandaodi_cfg.rank_title
	end
	return title_cfg
end

function YiZhanDaoDiData:GetYiZhanDaoDiKillReward()
	local flag_info = bit:d2b(self.yi_zhan_dao_di_user_info.kill_num_reward_flag) or {}
	return flag_info
end

function YiZhanDaoDiData:GetKillNumReward()
	local reward_cfg = {}
	if self.yizhandaodi_cfg then
		reward_cfg = self.yizhandaodi_cfg.kill_num_reward
	end
	return reward_cfg
end

function YiZhanDaoDiData:GetShowRewardListNum()
	local flag_info = self:GetYiZhanDaoDiKillReward()
	local reward_cfg = self:GetKillNumReward()
	local num = 1
	for k,v in pairs(flag_info) do
		if v == 1 then
			num = num + 1
		end
	end
	return num
end

function YiZhanDaoDiData:GetShowRewardList()
	local seq = self:GetShowRewardListNum()
	local reward_cfg = self:GetKillNumReward()
	if seq and reward_cfg and reward_cfg[seq] then
		return reward_cfg[seq].reward_item
	else
		if reward_cfg and reward_cfg[#reward_cfg] then
			return reward_cfg[#reward_cfg].reward_item
		end
	end
	return nil
end
function YiZhanDaoDiData:GetLuckRewardItem()
	local data_list = self.yizhandaodi_cfg.other[1]
	return data_list.lucky_item
end