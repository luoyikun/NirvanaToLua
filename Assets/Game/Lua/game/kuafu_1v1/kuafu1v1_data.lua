KuaFu1v1Data = KuaFu1v1Data or BaseClass()

KUAFUONEVONE_STATUS = 
{
	AWAIT = 0,					-- 等待
	PREPARE = 1,				-- 进行中
}
function KuaFu1v1Data:__init()
	if KuaFu1v1Data.Instance then
		print_error("[KuaFu1v1Data] Attempt to create singleton twice!")
		return
	end
	KuaFu1v1Data.Instance = self

	self.role_data = {
		cross_score_1v1 = 0,
		cross_day_join_1v1_count = 0,
		cross_1v1_curr_activity_add_score = 0,
		today_buy_times = 0,
		cross_lvl_total_join_times = 0,
		cross_1v1_total_win_times = 0,
		cross_1v1_dur_win_times = 0,
		cross_1v1_gongxun = 0,
		cur_season  = 0,
		cross_1v1_have_ring = nil,
		cross_1v1_use_ring = nil,

	}
	self.enemy = {}
	self.oppo_info = {}
	self.macth_info = {
		result = 0,
		match_end_left_time = 0,
	}

	self.fight_start = {
		timestamp_type = 0,
		pk_start_timestamp = 0,
		fight_start_timestmap = 0,
	}
	self.scene_user_list = {}
	self.come_from_kf_scene = false
	self.join_time_reward_flag = {}
	self.result = 0
	self.match_end_left_time = 0

	self.record = {
		win_this_week = 0,
		lose_this_week = 0,
		kf_1v1_news = {},
	}

	self.rank_list = {}
	self.fight_info = {
		result = 0,
		award_score = 0,
	}
	self.match_result = {
		result = 0,
		side = 0,
		oppo_plat_type =  0,
		oppo_sever_id =  0,
		role_id = 0,
		oppo_name = "",
		fight_start_time = 0,
		prof = 0,
		sex = 0,
		camp = 0,
		level = 0,
		fight_end_time = 0,
		capability = 0,
	}

	self.fight_result = {
		result = 0,
		week_win_times = 0,
		week_lose_times =  0,
		week_score = 0,
		this_honor = 0,
		this_score = 0,
		dur_win_count = 0,
		max_dur_win_count = 0,
		oppo_dur_win_count = 0,
		self_hp_per = 0,
		oppo_hp_per = 0,
	}
	self.is_matching = false
	RemindManager.Instance:Register(RemindName.GongXunRed, BindTool.Bind(self.RemindKFOnevOne, self))
end

function KuaFu1v1Data:__delete()
	KuaFu1v1Data.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.GongXunRed)
end

function KuaFu1v1Data:SetRoleData(info)
	if info then
		self.role_data.cross_score_1v1 = info.cross_score_1v1
		self.role_data.cross_day_join_1v1_count = info.cross_day_join_1v1_count
		self.role_data.cross_1v1_curr_activity_add_score = info.cross_1v1_curr_activity_add_score
		self.role_data.today_buy_times = info.today_buy_times
		self.role_data.cross_lvl_total_join_times = info.cross_lvl_total_join_times
		self.role_data.cross_1v1_total_win_times = info.cross_1v1_total_win_times
		self.role_data.cross_1v1_dur_win_times = info.cross_1v1_dur_win_times
		self.role_data.cross_1v1_gongxun = info.cross_1v1_gongxun
		self.role_data.cur_season = info.cur_season
		if self.role_data.cur_season >= 5 then 			--策划说第5赛季之后的都是用5赛季的展示
			self.role_data.cur_season = 5
		end
		self.join_time_reward_flag = bit:d2b(info.cross_1v1_join_time_reward_flag) or 0
		self.cross_1v1_fetch_score_reward_flag = bit:d2b(info.cross_1v1_fetch_score_reward_flag) or 0
		self.role_data.cross_1v1_have_ring = info.cross_1v1_have_ring
		self.role_data.cross_1v1_use_ring = info.cross_1v1_use_ring
	end
end

function KuaFu1v1Data:GetRoleData()
	return self.role_data
end

function KuaFu1v1Data:Get1V1InfoJiFen()
	return self.role_data.cross_score_1v1
end


function KuaFu1v1Data:GetJionTimesRewardIsGet(index)
	return self.join_time_reward_flag[33- index]
end

function KuaFu1v1Data:SetMatchAck(info)
	if info then
		self.result = info.result
		self.match_end_left_time = info.match_end_left_time
	end
end

function KuaFu1v1Data:SetRecord(info)
	if info then
		for k,v in pairs(info) do
			self.record[k] = v
		end
	end
end

function KuaFu1v1Data:SetRankList(info)
	if info then
		self.rank_list = info
	end
end

function KuaFu1v1Data:SetMatchResult(info)
	if info then
		for k,v in pairs(info) do
			self.match_result[k] = v
		end
	end
end


function KuaFu1v1Data:GetMatchAck()
	return self.result, self.match_end_left_time
end

function KuaFu1v1Data:GetRecord()
	return self.self.record
end

function KuaFu1v1Data:GetRankListInfo()
	return self.rank_list
end

function KuaFu1v1Data:GetRankList()
	local kf1v1_other_cfg = ConfigManager.Instance:GetAutoConfig("cross_1v1_auto").other[1]
	local rank_list = self:GetRankListInfo()
	self.onevsone_rank_list = {}
	for k,v in pairs(rank_list) do
		if v.rank_value >= kf1v1_other_cfg.rank_score_limit then
			table.insert(self.onevsone_rank_list, v)
		end
	end
	return self.onevsone_rank_list
end

function KuaFu1v1Data:GetMatchResult()
	return self.match_result
end


function KuaFu1v1Data:GetFightTime()
	if self.match_result then
		return self.match_result.fight_end_time - self.match_result.fight_start_time
	end
	return 60
end

function KuaFu1v1Data:GetRankByScore(score)
	if not score then return end
	local rank_config = self:GetRankConfig()
	if rank_config then
		local current_config = nil
		local next_config = nil
		for k,v in pairs(rank_config) do
			current_config = v
			if score < v.score then
				next_config = v
				current_config = rank_config[k - 1]
				break
			end
		end
		return current_config, next_config
	end
end

function KuaFu1v1Data:GetRankByIndex(rank_type, rank_index)
	local rank_config = self:GetRankConfig()
	if rank_config then
		for k,v in pairs(rank_config) do
			if rank_index == v.rank_index and rank_type == v.rank_type then
				return v
			end
		end
	end
end

function KuaFu1v1Data:GetRankCountByType(rank_type)
	local count = 0
	local rank_config = self:GetRankConfig()
	if rank_config then
		for k,v in pairs(rank_config) do
			if rank_type == v.rank_type then
				count = count + 1
			end
		end
	end
	return count
end


function KuaFu1v1Data:GetRankConfig()
	if not self.rank_config then
		self.rank_config = ConfigManager.Instance:GetAutoConfig("cross_1v1_auto").grade_score
	end
	return self.rank_config
end

function KuaFu1v1Data:GetHistoryConfig()
	if not self.history_config then
		self.history_config = ConfigManager.Instance:GetAutoConfig("kuafu_onevone_auto").history_cfg
	end
	return self.history_config
end

function KuaFu1v1Data:GetIndexByScore(score)
	score = score or 0
	local index = -1
	local history_cfg = self:GetHistoryConfig()
	if history_cfg then
		for k,v in ipairs(history_cfg) do
			if v.score <= score then
				index = v.index - 1
			else
				break
			end
		end
	end
	return index
end

-- function KuaFu1v1Data:GetRewardFlagByIndex(index)
-- 	if index < 0 then
-- 		return false
-- 	end
-- 	local flag = self.role_data.cross_1v1_score_reward_flag
-- 	local list = bit:d2b(flag) or {}
-- 	return list[32 - index] == 0
-- end

function KuaFu1v1Data:GetShiZhuangId()
	local cfg = ConfigManager.Instance:GetAutoConfig("cross_1v1_auto")
	if cfg then
		return cfg.show_cfg[1].index
	end
end

function KuaFu1v1Data:GetTitleId()
	local cfg = ConfigManager.Instance:GetAutoConfig("cross_1v1_auto")
	if cfg then
		return cfg.show_cfg[1].title_id
	end
end

-- -- 红点
-- function KuaFu1v1Data:GetReminder()
-- 	local num = 0
-- 	local history_cfg = self:GetHistoryConfig() or {}
-- 	for i = 0, #history_cfg - 1 do
-- 		if self:GetRewardFlagByIndex(i) then
-- 			local cfg = KuaFu1v1Data.Instance:GetHistoryCfgByIndex(i + 1) or {}
-- 			local need_score = cfg.score or 0
-- 			if self.role_data.cross_score_1v1 >= need_score then
-- 				--print_error(self.role_data.cross_score_1v1, need_score)
-- 				num = 1
-- 				break
-- 			end
-- 		end
-- 	end
-- 	return num
-- end

function KuaFu1v1Data:GetHistoryCfgByIndex(index)
	local history_cfg = self:GetHistoryConfig() or {}
	for k,v in pairs(history_cfg) do
		if v.index == index then
			return v
		end
	end
end

function KuaFu1v1Data:GetIsMatching()
	return self.is_matching
end

function KuaFu1v1Data:SetIsMatching(is_matching)
	self.is_matching = is_matching
end

--王者之戒红点提示
function KuaFu1v1Data:GetSeasonRingRemind()
	if self.role_data.cross_1v1_use_ring == nil and self.role_data.cross_1v1_have_ring == nil then
		return 0
	end

	local count = 0
	for k,v in pairs(self.role_data.cross_1v1_use_ring) do
		if v > 0 then
			count = count + 1
		end
	end
	if count >=2 then
		return 0
	end

	local have_ring = 0
	for k,v in pairs(self.role_data.cross_1v1_have_ring) do
		if v > 0 then
			have_ring = have_ring + 1
		end
	end
	if have_ring > count then
		return 1
	else
		return 0
	end
end

function KuaFu1v1Data:GetUseRingData()
	return self.role_data.cross_1v1_use_ring
end

function KuaFu1v1Data:GetCurSeason()
	return self.role_data.cur_season
end

function KuaFu1v1Data:GetHaveRingData()
	return self.role_data.cross_1v1_have_ring
end

function KuaFu1v1Data:GetSeasonJoinCount()
	return self.role_data.cross_lvl_total_join_times
end

--参加次数
function KuaFu1v1Data:GetMaxJionTimes()
	local cfg =  ConfigManager.Instance:GetAutoConfig("cross_1v1_auto").show_cfg
	return cfg[1].max_time
end

--获取购买花费
function KuaFu1v1Data:GetBuyTimeCost()
	local cfg =  ConfigManager.Instance:GetAutoConfig("cross_1v1_auto").other[1]
	return cfg.buy_time_cost
end

--最大购买次数
function KuaFu1v1Data:GetBuyMaxTimes()
	local cfg =  ConfigManager.Instance:GetAutoConfig("cross_1v1_auto").other[1]
	return cfg.max_buy_times
end

--获取胜率
function KuaFu1v1Data:GetWinRate()
	local kf_info = self:GetRoleData()
	if kf_info.cross_1v1_total_win_times > 0 then
	 	return math.ceil((kf_info.cross_1v1_total_win_times / kf_info.cross_lvl_total_join_times)*100) 
	else
		return 0
	end
end

--获取参与次数奖励
function KuaFu1v1Data:GetJoinTimesReward(join_times)
	if join_times == nil then return end
	local cfg = ConfigManager.Instance:GetAutoConfig("cross_1v1_auto").join_times_reward
	local num = #cfg
	for i = 1, #cfg do
		if join_times >= cfg[i].jion_times and self:GetJionTimesRewardIsGet(cfg[i].seq) == 0 then
			num = i
			break
		end
		if join_times < cfg[i].jion_times then
			num = i
			break
		end
	end
	return cfg[num]
end

function KuaFu1v1Data:GetRewardCfg()
	local reward_cfg = ConfigManager.Instance:GetAutoConfig("cross_1v1_auto").join_times_reward
	return reward_cfg
end

function KuaFu1v1Data:ClearKf1V1News()
	self.kf1v1_news = {}
end

function KuaFu1v1Data:AddKf1V1News(name, result, score)
	local vo = {}
	local cfg = ConfigManager.Instance:GetAutoConfig("kuafu_onevone_auto").show_cfg[1].match_fail_score
	vo.name = name
	vo.result = result
	vo.jifen = score or cfg
	table.insert(self.kf1v1_news, vo)
	if #self.kf1v1_news > 5 then
		table.remove(self.kf1v1_news, 1)
	end
end

function KuaFu1v1Data:SetMatchingEnemySex(info)
	if info == nil then
		return
	end
	self.enemy.name = info.oppo_name
	self.enemy.level = info.level
	self.enemy.sever = info.oppo_sever_id
	self.enemy.sex = info.sex
	self.enemy.prof = info.prof
end

function KuaFu1v1Data:GetMatchingEnemySex()
	return self.enemy 
end

function KuaFu1v1Data:GetRewardBaseCell(jifen)
	local item_cfg = ConfigManager.Instance:GetAutoConfig("cross_1v1_auto").grade_score

	for k = #item_cfg,1, -1 do
		if item_cfg[k].score <= jifen then
			return item_cfg[k]
		end
	end
	return item_cfg[1]
end

function KuaFu1v1Data:SetProgLevel(grade)
	local item_cfg = ConfigManager.Instance:GetAutoConfig("cross_1v1_auto").grade_score
	if grade < #item_cfg - 1 then
		for k = #item_cfg,1, -1 do
			if item_cfg[k].grade == grade + 1 then
				return item_cfg[k]
			end
		end
	end
	return item_cfg[#item_cfg]

end

-- 设置跨服1V1匹配信息
function KuaFu1v1Data:Set1V1MacthInfo(info)
	self.macth_info.result = info.result
	self.macth_info.match_end_left_time = TimeCtrl.Instance:GetServerTime() + info.match_end_left_time
end

-- 获取跨服1V1匹配信息
function KuaFu1v1Data:Get1V1MacthInfo()
	return self.macth_info
end

-- 设置跨服1V1对手信息
function KuaFu1v1Data:SetOppoInfo(info)
	self.oppo_info = info
end

-- 获取跨服1V1对手信息
function KuaFu1v1Data:GetOppoInfo()
	return self.oppo_info
end

-- 获取跨服1V1对手信息
function KuaFu1v1Data:GetSceneUser()
	self.scene_user_list = {}
	self.scene_user_list[1] = RoleData.Instance.role_vo
	self.scene_user_list[2] = self.oppo_info
	return self.scene_user_list
end

function KuaFu1v1Data:SetComeFromScene(bool_value)
	self.come_from_kf_scene = bool_value
end

function KuaFu1v1Data:GetComeFromScene()
	return self.come_from_kf_scene
end

-- 战斗结果
function KuaFu1v1Data:SetFightResult(info)
	self.fight_info.result = info.result
	self.fight_info.award_score = info.award_score
end

function KuaFu1v1Data:GetFightResult()
	return self.fight_info
end


-- 结束后的功勋奖励
function KuaFu1v1Data:GetGongXunReward(index)
	local cfg  = ConfigManager.Instance:GetAutoConfig("cross_1v1_auto").other[1]
	return index > 0 and cfg.winner_score or cfg.loser_score
end

function KuaFu1v1Data:SetCross1v1FightStart(info)
	-- print_error(info)
	self.fight_start.timestamp_type = info.timestamp_type
	self.fight_start.pk_start_timestmap = info.pk_start_timestamp
	self.fight_start.fight_start_timestmap = info.fight_start_timestmap
end

function KuaFu1v1Data:GetCross1v1FightStart()
	return self.fight_start
end

function KuaFu1v1Data:GetSeasonRewardCount()
	local season = KuaFu1v1Data.Instance:GetCurSeason()
	local cfg = ConfigManager.Instance:GetAutoConfig("cross_1v1_auto")
	local count = 0
	for k,v in pairs(cfg.gxshow_cfg) do
		if v.season == season then
			count = count + 1
		end
	end
	return count
end

function KuaFu1v1Data:GetSeasonRewardBySeq(grade)
	local cfg = ConfigManager.Instance:GetAutoConfig("cross_1v1_auto")
	local season = KuaFu1v1Data.Instance:GetCurSeason()
	for k,v in pairs(cfg.gxshow_cfg) do
		if v.grade == grade + 1 and v.season == season then
			return v
		end
	end
end

-- 获取跨服1V1总积分
function KuaFu1v1Data:GetInfoGongXun()
		return self.role_data.cross_1v1_gongxun
end


function KuaFu1v1Data:GetGongXunRewardCount()
	local cfg = ConfigManager.Instance:GetAutoConfig("cross_1v1_auto")
	return #cfg.score_reward
end

function KuaFu1v1Data:GetGongXunRewardIsGet()
	return self.cross_1v1_fetch_score_reward_flag
end

function KuaFu1v1Data:GetGongXunRewardIsGetFlag(index)
	return self.cross_1v1_fetch_score_reward_flag[32 - index]
end

--获取积分达标奖励
function KuaFu1v1Data:GetJiFenReward()
	local cfg =  ConfigManager.Instance:GetAutoConfig("cross_1v1_auto").score_reward
	local reward_tab = {}
	for k, v in pairs(cfg) do
		reward_tab[k] = {}
		reward_tab[k].seq = v.seq
		reward_tab[k].need_score = v.need_score
		reward_tab[k].reward_item = v.reward_item
		reward_tab[k].curr_score = self.role_data.cross_1v1_gongxun
	end

	local function scortfun (a, b)
		if KuaFu1v1Data.Instance:GetGongXunRewardIsGetFlag(a.seq) == KuaFu1v1Data.Instance:GetGongXunRewardIsGetFlag(b.seq) then
			return a.seq < b.seq
		else
			return KuaFu1v1Data.Instance:GetGongXunRewardIsGetFlag(a.seq) < KuaFu1v1Data.Instance:GetGongXunRewardIsGetFlag(b.seq)
		end
	end
	table.sort(reward_tab, scortfun)
	return reward_tab
end

function KuaFu1v1Data:RemindKFOnevOne()
	local cfg = KuaFu1v1Data.Instance:GetJiFenReward()
	for k,v in pairs(cfg) do
		local remind = self:GetGongXunRewardIsGetFlag(v.seq)
		if v.curr_score> v.need_score and remind == 0  then
			return 1
		end
	end
	return 0
end

function KuaFu1v1Data:GetRewardByJoin(jion_times)
	local cfg =  ConfigManager.Instance:GetAutoConfig("cross_1v1_auto").join_times_reward
	if cfg then
		for k,v in pairs(cfg) do
			if v.jion_times == jion_times then
				return v
			end
		end
	end
end

function KuaFu1v1Data:CheckIsCanWear()
	if self.role_data.cross_1v1_use_ring then
		for i,v in ipairs(self.role_data.cross_1v1_use_ring) do
			if v and v == 0 then
				return true
			end
		end
	end
	return false
end

function KuaFu1v1Data:CheckJieZhiID(item_id)
	local cfg = ConfigManager.Instance:GetAutoConfig("cross_1v1_auto")
	local kf_info = self:GetRoleData()
	local season = kf_info.cur_season or 0
	local list = ListToMap(cfg.season_ring, "season", "grade")
	for i = 1, season do
		if list[i] then
			for j = 0, #list[i] do
				if list[i][j].reward_item.item_id == item_id then
					return true
				end
			end
		end
	end
	return false
end

function KuaFu1v1Data:GetJieZhiCfgByID(item_id)
	local cfg = ConfigManager.Instance:GetAutoConfig("cross_1v1_auto")
	local kf_info = self:GetRoleData()
	local season = kf_info.cur_season or 0
	local list = ListToMap(cfg.season_ring, "season", "grade")
	for i = 1, season do
		if list[i] then
			for j = 0, #list[i] do
				if list[i][j].reward_item.item_id == item_id then
					return list[i][j]
				end
			end
		end
	end
end