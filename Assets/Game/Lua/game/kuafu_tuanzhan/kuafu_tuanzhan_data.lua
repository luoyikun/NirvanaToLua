KuaFuTuanZhanData = KuaFuTuanZhanData or BaseClass()

CROSS_TUANZHAN_SIDE =
{
	CROSS_TUANZHAN_SIDE_MIN = 0,

	CROSS_TUANZHAN_SIDE_0 = 0,						-- 对战方0
	CROSS_TUANZHAN_SIDE_1 = 1,						-- 对战方1

	CROSS_TUANZHAN_SIDE_MAX = 2,
}

TUANZHAN_BOSS_STATE = {
	BOSS_FLASH = 1,									-- boss刷新
	BOSS_LIVE = 2,									-- boss存活
	BOSS_DIE = 3,									-- boss死亡
} 
-- 策划要求在本活动中复活时间为10s
local REVIVE_TIME = 10

function KuaFuTuanZhanData:__init()
	if KuaFuTuanZhanData.Instance then
		ErrorLog("[KuaFuTuanZhanData] attempt to create singleton twice!")
		return
	end
	KuaFuTuanZhanData.Instance = self

	self.act_data = {
		fight_start_time = 0,					-- 战斗开始时间
		activity_end_time = 0, 					-- 活动结束时间
		rand_side_time = 0,						-- 重置阵营时间
	}
	
	self.personal_info = {
		side = 0,
		score_reward_fetch_seq = 0,
		score = 0,
		kill_num = 0,
		assist_kill_num = 0,
		dur_kill_num = 0,
	}

	self.player_info = {
		turn = 0,							-- 回合
		score = 0,							-- 积分
		is_red_side = 0,					-- 是否是魔界方
		rank = 0,							-- 排行
		kill_role_num = 0,					-- 击杀其他玩家数量
		next_redistribute_time = 0,			-- 下次发奖励 重新分配阵营的时间戳
		next_get_score_time = 0,			-- 下次获取积分时间戳
		next_update_rank_time = 0,			-- 下次更新排行时间戳
		kick_out_time = 0,					-- 延迟踢出时间
	}

	self.camp_info = {
		side0_score = 0,
		side1_score = 0,
	}

	self.redside_list_info = {
		red_side_count = 0,
		red_side_list = {},
	}

	self.rank_list = {}

	self.fight_rank_list = {}
	self.boss_rank_list = {}
	self.reward_list = {}
	self.score_rank_info = {}
	self.pillar_info = {}

	self.boss_state = TUANZHAN_BOSS_STATE.BOSS_FLASH
	self.boss_left_hp_per = 0
	self.next_redistribute_time = 0
	self.next_flush_boss_time = 0

	self.is_cross_server = 1

end

function KuaFuTuanZhanData:__delete()
	KuaFuTuanZhanData.Instance = nil
	self.fight_rank_list = {}
	self.boss_rank_list = {}
end

-- 设置活动数据
function KuaFuTuanZhanData:SetActivityData(data)
	self.act_data = data
end

-- 获取活动数据
function KuaFuTuanZhanData:GetActivityData()
	return self.act_data
end

---------合G21----- 夜战云巅--------------------

-- 设置角色信息
function KuaFuTuanZhanData:SetRoleInfo(protocol)
	self.player_info.turn = protocol.turn or 0
	self.player_info.score = protocol.score or 0
	self.player_info.total_score = protocol.total_score or 0
	self.player_info.is_red_side = protocol.is_red_side or 0
	self.player_info.rank = protocol.rank or 0
	self.player_info.total_rank = protocol.total_rank or 0
	self.player_info.kill_role_num = protocol.kill_role_num or 0
	self.player_info.next_redistribute_time = protocol.next_redistribute_time or 0
	self.player_info.next_get_score_time = protocol.next_get_score_time or 0
	self.player_info.next_update_rank_time = protocol.next_update_rank_time or 0
	self.player_info.kick_out_time = protocol.kick_out_time or 0
	self.player_info.next_flush_boss_time = protocol.next_flush_boss_time or 0
end

-- 获取个人信息
function KuaFuTuanZhanData:GetRoleInfo()
	return self.player_info
end

function KuaFuTuanZhanData:GetBossID()
	local cfg = ConfigManager.Instance:GetAutoConfig("nightfightfb_auto").other
	local boss_id = cfg[1].boss_id or 0
	return boss_id
end

function KuaFuTuanZhanData:GetNightFightOtherCfg()
	local cfg = ConfigManager.Instance:GetAutoConfig("nightfightfb_auto").other[1]
	return cfg
end

function KuaFuTuanZhanData:GetBroadCastList()
	local broadcast_cfg = ConfigManager.Instance:GetAutoConfig("nightfightfb_auto").broadcast_cfg
	local interval_list = {}
	for k , v in pairs (broadcast_cfg) do
		interval_list[k] = v.interval
	end
	return interval_list
end


function KuaFuTuanZhanData:GetBroadCastInterval(index)
	local broadcast_cfg = ConfigManager.Instance:GetAutoConfig("nightfightfb_auto").broadcast_cfg
	return broadcast_cfg[index].interval 
end

function KuaFuTuanZhanData:GetBroadCastCfgLength()
	local broadcast_cfg = ConfigManager.Instance:GetAutoConfig("nightfightfb_auto").broadcast_cfg
	return #broadcast_cfg
end


function KuaFuTuanZhanData:CheckMonsterFlushStamp()
	local time_stamp = self.player_info.next_flush_boss_time
	if time_stamp ~= self.next_flush_boss_time then
		self.next_flush_boss_time = time_stamp
	end
end

function KuaFuTuanZhanData:GetMonsterFlushStamp()
	return self.next_flush_boss_time
end

function KuaFuTuanZhanData:GetRewardTimeStamp()
	return self.next_redistribute_time
end

-- 设置排名信息
function KuaFuTuanZhanData:SetFightRankInfo(rank_info_list)
	self.fight_rank_list = rank_info_list
end

-- 获取排名信息
function KuaFuTuanZhanData:GetFightRankInfo()
	-- table.sort(self.fight_rank_list, SortTools.KeyUpperSorter("score"))
	SortTools.SortDesc(self.fight_rank_list, "score", "obj_id")
	return self.fight_rank_list
end

-- 获取敌方排名第一
function KuaFuTuanZhanData:GetEnemyFirstRank()
	for k,v in pairs(self.fight_rank_list) do
		if self.player_info.is_red_side ~= v.is_red_side then
			return k - 1
		end
	end
	return
end

-- 设置总排名信息
function KuaFuTuanZhanData:SetAllScoreRankInfo(protocol)
	self.score_rank_info = protocol.score_info_list
end

function KuaFuTuanZhanData:GetAllScoreRankInfo()
	return self.score_rank_info
end

-- 设置boss伤害排名信息
function KuaFuTuanZhanData:SetBossRankInfo(protocol)
	self.boss_left_hp_per = protocol.boss_left_hp_per
	self.boss_rank_list = protocol.boss_rank_info_list

	if (self.boss_left_hp_per / 10000) == 1 then
		self.boss_state = TUANZHAN_BOSS_STATE.BOSS_FLASH
	elseif self.boss_left_hp_per == 0 then
		self.boss_state = TUANZHAN_BOSS_STATE.BOSS_DIE
	else
		self.boss_state = TUANZHAN_BOSS_STATE.BOSS_LIVE
	end
end

-- 获取boss伤害排名信息
function KuaFuTuanZhanData:GetBossRankInfo()
	return self.boss_rank_list
end

function KuaFuTuanZhanData:GetBossHpPercent()
	return self.boss_left_hp_per
end

function KuaFuTuanZhanData:GetBossIsFlushBoss()
	return self.boss_state
end

function KuaFuTuanZhanData:GetShowPercent(number)
	local percent = number / 100
	return percent
end

function KuaFuTuanZhanData:GetObjIDInfo()
	local obj_id_list = ListToMap(self.fight_rank_list, "obj_id")
	return obj_id_list
end

function KuaFuTuanZhanData:SetFightReward(protocol)
	self.reward_list = protocol.reward_list
end

-- 获取排行奖励
function KuaFuTuanZhanData:GetAllRankReward()
	local cfg = ConfigManager.Instance:GetAutoConfig("nightfightfb_auto").reward
	if nil == cfg then return end

	local rewardcfg = {}

	for i,v in ipairs(self.reward_list) do
		if v >= 0 then
			for m,n in ipairs(cfg) do
				if v >= n.min_rank and v <= n.max_rank then
					local temp = TableCopy(n)
					temp.turn = i
					temp.rank = v
					local data1 = {item_id = ResPath.CurrencyToIconId.gongxun, num = n.cross_honor, is_bind = 1,}  -- 荣誉
					table.insert(temp.reward_item, data1)
					local data2 = {item_id = ResPath.CurrencyToIconId.honor, num = n.shengwang, is_bind = 1}	 -- 声望
					table.insert(temp.reward_item, data2)
					for k1,v1 in pairs(temp.reward_item) do
						local quality = ItemData.Instance:GetItemQuailty(v1.item_id)
						v1.quality = quality
					end
					table.sort(temp.reward_item, SortTools.KeyUpperSorter("quality"))
					table.insert(rewardcfg, temp)
				end
			end
		end
	end
	return rewardcfg
end

function KuaFuTuanZhanData:SetNightFightRedSideListInfo(protocol)
	self.redside_list_info.red_side_count = protocol.red_side_count
	self.redside_list_info.red_side_list = protocol.red_side_list
end

function KuaFuTuanZhanData:GetNightFightRewardCfg()
	local temp_reward_cfg = ConfigManager.Instance:GetAutoConfig("nightfightfb_auto").reward
	local rank_reward_cfg = {}
	for k , v in pairs(temp_reward_cfg) do
		if nil ~= v.reward_item then
			rank_reward_cfg[k] = v.reward_item
		end
	end
	return rank_reward_cfg
end

function KuaFuTuanZhanData:GetNightFightCfg()
	local temp_reward_cfg = ConfigManager.Instance:GetAutoConfig("nightfightfb_auto")
	return temp_reward_cfg
end

function KuaFuTuanZhanData:GetIsRedByObjId(obj_id)
	--local info_list = self:GetObjIDInfo()
	if self.redside_list_info.red_side_list[obj_id] == 1 then
		return true
	else
		return false
	end
end

function KuaFuTuanZhanData:SetIsCrossServerState(index)
	self.is_cross_server = index
end

function KuaFuTuanZhanData:GetIsCrossServerState()
	return self.is_cross_server
end


---------合G21----- 夜战云巅-------END-----------

------------------ 跨服团战----------------------

-- 设置个人信息
function KuaFuTuanZhanData:SetPlayerInfo(info)
	self.personal_info.side = info.side or 0
	self.personal_info.score = info.score or 0
	self.personal_info.kill_num = info.kill_num or 0
	self.personal_info.assist_kill_num = info.assist_kill_num or 0
	self.personal_info.dur_kill_num = info.dur_kill_num or 0
	self.personal_info.score_reward_fetch_seq = info.score_reward_fetch_seq or 0
end

-- 获取个人信息
function KuaFuTuanZhanData:GetPlayerInfo()
	return self.personal_info
end

-- 获取自己的阵营
function KuaFuTuanZhanData:GetPlayerCampId()
	return self.personal_info.side
end

-- 设置排名信息
function KuaFuTuanZhanData:SetRankListInfo(rank_list)
	self.rank_list = rank_list
end

-- 获取排名信息
function KuaFuTuanZhanData:GetRankListInfo()
	table.sort(self.rank_list, SortTools.KeyUpperSorter("score"))
	return self.rank_list
end

-- 设置阵营信息
function KuaFuTuanZhanData:SetCampInfo(camp_info)
	self.camp_info.side0_score = camp_info[1] or 0				-- 对战方0积分
	self.camp_info.side1_score = camp_info[2] or 0				-- 对战方1积分
end

-- 获取阵营信息
function KuaFuTuanZhanData:GetCampInfo()
	local camp_info = {
		{side = 0, score = self.camp_info.side0_score, name = Language.KuafuTeambattle.side0}, 
		{side = 1, score = self.camp_info.side1_score, name = Language.KuafuTeambattle.side1}}

	table.sort(camp_info, SortTools.KeyUpperSorter("score"))

	for i,v in ipairs(camp_info) do
		v.rank = i
	end
	return camp_info
end

-- 设置柱子信息
function KuaFuTuanZhanData:SetPillarInfo(pillar_info)
	if 1 == #pillar_info then
		for k,v in pairs(self.pillar_info) do
			if pillar_info[1].index == v.index then
				self.pillar_info[k] = pillar_info[1]
				return
			end
		end
		return
	end

	self.pillar_info = pillar_info
end

-- 获取柱子信息
function KuaFuTuanZhanData:GetPillarInfo()
	return self.pillar_info
end

function KuaFuTuanZhanData:GetShowRewardCfg()
	return 0
	-- if nil == self.other_cfg[1].boss_diao then return end
	-- return self.other_cfg[1].boss_diao
end

function KuaFuTuanZhanData.IsNightFightScene(scene_type)
	return scene_type == SceneType.KF_NightFight
end


function KuaFuTuanZhanData:GetReviveTime()
	return REVIVE_TIME
end

function KuaFuTuanZhanData:GetMonsterPos()
	-- local main_role = Scene.Instance:GetMainRole()
	-- local main_role_x, main_role_y = main_role:GetLogicPos()
	-- local min_pos_x, min_pos_y, min_distance = main_role_x, main_role_y, 99999

	-- local pilla_info_cfg = ConfigManager.Instance:GetAutoConfig("cross_tuanzhan_auto").pilla_info
	-- for k,v in pairs(pilla_info_cfg) do
	-- 	if self.pillar_info[v.index + 1].owner_side ~= self.personal_info.side then
	-- 		local distance = GameMath.GetDistance(main_role_x, main_role_y, v.x_pos, v.y_pos, false)
	-- 		if distance < min_distance then
	-- 			min_pos_x = v.x_pos
	-- 			min_pos_y = v.y_pos
	-- 			min_distance = distance
	-- 		end
	-- 	end
	-- end

	return min_pos_x, min_pos_y
end

function KuaFuTuanZhanData:GetPillarCfg(index)
	local pilla_info_cfg = ConfigManager.Instance:GetAutoConfig("cross_tuanzhan_auto").pilla_info
	for k,v in pairs(pilla_info_cfg) do
		if v.index == index then
			return v
		end
	end
end

function KuaFuTuanZhanData:GetMonsterName(monster_vo)
	for k,v in pairs(self.pillar_info) do
		if monster_vo.monster_id == v.monster_id and "" ~= v.owner_name then
			return monster_vo.name .. " <color='#ffff00'>(" .. v.owner_name .. ")</color>"
		end
	end

	return monster_vo.name
end

-- 根据柱子monster_id判断是否是本阵营
function KuaFuTuanZhanData:IsSelfCampPillarByMonsterId(monster_id)
	for k,v in pairs(self.pillar_info) do
		if monster_id == v.monster_id then
			if v.owner_side == self.personal_info.side then
				return true
			end
			break
		end
	end
	return false
end

-- 根据柱子怪物对象monster_id获取名字
function KuaFuTuanZhanData:GetNameByMonsterId(monster_id)
	for k,v in pairs(self.pillar_info) do
		if monster_id == v.monster_id then
			return v.owner_name
		end
	end
	return ""
end

-- 设置玩家连杀信息
function KuaFuTuanZhanData:SetDurKillInfo(dur_kill_info)
	self.dur_kill_info = dur_kill_info
end

-- 获取玩家连杀信息
function KuaFuTuanZhanData:GetDurKillInfo()
	return self.dur_kill_info
end

-- 根据标记获取角色阵营与连杀数
function KuaFuTuanZhanData.GetCampAndDurKillByNum(number)
	local camp_id = 0
	if number >= 10000 then
		camp_id = 1
		number = number - 10000
	end
	return camp_id, number
end

-- function KuaFuTuanZhanData:GetAllRankReward()
-- 	local rank_reward_cfg = ConfigManager.Instance:GetAutoConfig("cross_tuanzhan_auto").rank_reward
-- 	local level_index = 0
-- 	local last_level = 0
-- 	local new_cfg_list = {}
-- 	for i, v in ipairs(rank_reward_cfg) do
-- 		if v.level ~= last_level then
-- 			level_index = level_index + 1
-- 		end
-- 		last_level = v.level

-- 		new_cfg_list[level_index] = new_cfg_list[level_index] or {}
-- 		table.insert(new_cfg_list[level_index], v)
-- 	end

-- 	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
-- 	local reward_level_index = 1
-- 	for index = #new_cfg_list, 1, -1 do
-- 		if main_role_vo.level >= new_cfg_list[index][1].level then
-- 			reward_level_index = index
-- 			break
-- 		end
-- 	end

-- 	return new_cfg_list[reward_level_index]
-- end

function KuaFuTuanZhanData:GetAllScoreReward()
	local score_reward_cfg = ConfigManager.Instance:GetAutoConfig("cross_tuanzhan_auto").score_reward
	local level_index = 0
	local last_level = 0
	local new_cfg_list = {}
	for i, v in ipairs(score_reward_cfg) do
		if v.level ~= last_level then
			level_index = level_index + 1
		end
		last_level = v.level

		new_cfg_list[level_index] = new_cfg_list[level_index] or {}
		table.insert(new_cfg_list[level_index], v)
	end

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local reward_level_index = 1
	for index = #new_cfg_list, 1, -1 do
		if main_role_vo.level >= new_cfg_list[index][1].level then
			reward_level_index = index
			break
		end
	end

	return new_cfg_list[reward_level_index]
end

function KuaFuTuanZhanData:GetScoreRewardValue(role_level, score)
	local reward_currency = 0
	local cross_tuanzhan_cfg = ConfigManager.Instance:GetAutoConfig("cross_tuanzhan_auto")
	for i,v in ipairs(cross_tuanzhan_cfg.score_reward) do
		if score >= v.need_score then
			reward_currency = v.reward_currency
		end
	end
	return reward_currency
end

function KuaFuTuanZhanData:GetUnFetchScoreRewardCfg()
	local all_rank_cfg = self:GetAllScoreReward()
	if nil == all_rank_cfg then
		return
	end
	for i, v in ipairs(all_rank_cfg) do
		if v.seq >= self.personal_info.score_reward_fetch_seq then
			return v
		end
	end

	return all_rank_cfg[#all_rank_cfg]
end

function KuaFuTuanZhanData:GetCrossTuanZhanPlayerInfoScore(obj_id)
	return self.player_info_score[obj_id]
end

function KuaFuTuanZhanData:SetRoleScore(num)
	local main_role = Scene.Instance:GetMainRole()
	if main_role then
		main_role:SetRoleScore(num)
	end
end

function KuaFuTuanZhanData:SetCrossTuanZhanPlayerInfoScore(protocol)
	-- print_error("ttttttttttttt",protocol)
	-- local obj = Scene.Instance:GetObj(protocol.obj_id)
	-- if obj then
	-- 	if obj:GetType() == SceneObjType.Role or obj:GetType() == SceneObjType.MainRole then
	-- 		obj:SetRoleScore(protocol.box_count)
	-- 	end
	-- end
	-- self.player_info_score[protocol.obj_id] = protocol.score
end

------------------ 跨服团战-------END---------------