KuafuPVPData = KuafuPVPData or BaseClass()

KuafuPVPData.KF3V3_SIDE =
{
	SIDE_0 = 0,										--对战方0
	SIDE_1 = 1,										--对战方1
	SIDE_MAX = 2
}

function KuafuPVPData:__init()
	if KuafuPVPData.Instance then
		ErrorLog("[KuafuPVPData] attempt to create singleton twice!")
		return
	end
	KuafuPVPData.Instance =self
	self.stronghold_info = {
		side_score_list = {},
		strong_hold_rate_info = 0,
	}

	self.matesList = {}

	self.role_info = {
		self_side = 0,	
		kills = 0,	
		assist = 0,	
		dead = 0,
	}

	self.prepare_info = {
		match_state = 0,
		win_side = 0,
		next_state_time = 0,
		user_info_list = {},
	}

	self.acticity_info = {
		challenge_mvp_count = 0,
		challenge_score = 0,
		challenge_total_match_count = 0,
		challenge_win_match_count = 0,
		win_percent = 0,
		today_match_count = 0,
		matching_state = 0,
	}

	self.match_state_info = {
		matching_state = -1,
		user_list = {},
	}

	self.challenge_score = 0
	self.join_time_reward_flag = {}
	self.gongxun_reward_fetch_list = {}
	self.rank_list = {}
	self.is_matching = false
	self.gongxun_value = 0

	self.cross_3v3_season_reward_use = {}

	RemindManager.Instance:Register(RemindName.Cross3v3GongXunRed, BindTool.Bind(self.RemindKFPvP, self))

end

function KuafuPVPData:__delete()
	KuafuPVPData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.Cross3v3GongXunRed)
end

function KuafuPVPData:SetMatesInfo(list)
	self.matesList = list
end


function KuafuPVPData:AddTeamMate(info)
	if #self.matesList >= 3 then return end
	for k,v in pairs(self.matesList) do
		if v.uid == info.role_id then
			return
		end
	end
	local vo = {}
	vo.plat_type = info.plat_type
	vo.server_id = info.server_id
	vo.uid = info.role_id
	vo.user_name = info.role_name
	vo.sex = info.sex
	vo.prof = info.prof
	vo.camp = info.camp
	vo.level = info.level
	vo.challenge_score = info.challenge_score
	vo.win_percent = info.win_percent
	vo.mvp_count = info.mvp_count
	vo.capability = info.capability
	self.matesList[#self.matesList +1] = vo
end

function KuafuPVPData:GetMatesInfo()
	return self.matesList
end

function KuafuPVPData:SetRoleInfo(info)
	self.role_info.self_side = info.self_side
	self.role_info.kills = info.kills
	self.role_info.assist = info.assist
	self.role_info.dead = info.dead
end

function KuafuPVPData:GetRoleInfo()
	return self.role_info
end

function KuafuPVPData:SetStrongHoldInfo(info)
	self.stronghold_info.side_score_list = info.side_score_list
	self.stronghold_info.strong_hold_rate_info = info.strong_hold_rate_info
end

function KuafuPVPData:GetStrongHoldInfo()
	return self.stronghold_info
end

function KuafuPVPData:GetSideScoreList()
	return self.stronghold_info.side_score_list
end

function KuafuPVPData:GetSliderNum()
	return self.stronghold_info.strong_hold_rate_info
end

function KuafuPVPData:SetKF3v3DayCount(info)
	 self.reward_daycount = info
end

function KuafuPVPData:GetKF3v3DayCount()
		return self.reward_daycount
end

function KuafuPVPData:SetMatchStateInfo(info)
	self.match_state_info.matching_state = info.matching_state
	self.match_state_info.user_list = info.user_list
end

function KuafuPVPData:GetMatchStateInfo()
	return self.match_state_info
end

function KuafuPVPData:SetActivityInfo(info)
	self.acticity_info = info
	self.acticity_info.cur_season = info.season_count
	if self.acticity_info.cur_season >= 5 then 					--策划说第5赛季之后的都是用5赛季的展示
		self.acticity_info.cur_season = 5
	end
	self.join_time_reward_flag = bit:d2b(info.join_reward_fetch_flag)
	self.cross_3v3_season_reward_use = info.cross_3v3_season_reward_use
end

function KuafuPVPData:GetActivityInfo()
	return self.acticity_info
end

function KuafuPVPData:GetUseCardData()
	return self.acticity_info.cross_3v3_season_reward_use
end

function KuafuPVPData:GetCurSeason()
	return self.acticity_info.cur_season
end

function KuafuPVPData:GetHaveCardData()
	return self.acticity_info.cross_3v3_season_reward
end

function KuafuPVPData:GetIsMatching()
	return self.is_matching
end

function KuafuPVPData:SetIsMatching(is_matching)
	self.is_matching = is_matching
end

function KuafuPVPData:GetIsWear(index)
	for k,v in pairs(self.cross_3v3_season_reward_use) do
		if v == index then
			return true
		end
	end
	return false
end

function KuafuPVPData:CheckIsCanWear()
	for i,v in ipairs(self.cross_3v3_season_reward_use) do
		if v == 0 then
			return true
		end
	end
end


function KuafuPVPData:GetWZCardSelectCfg(index)
	for k,v in ipairs(self.cross_3v3_season_reward_use) do
		if v == index then
			return true
		end
	end
	return false
end

function KuafuPVPData:GetPvPJionTimesRewardIsGet(index)
	return self.join_time_reward_flag[33- index]
end

function KuafuPVPData:SetPrepareInfo(info)
	self.prepare_info.match_state = info.match_state
	self.prepare_info.win_side = info.win_side
	self.prepare_info.next_state_time = info.next_state_time
	self.prepare_info.user_info_list = info.user_info_list
end

function KuafuPVPData:GetPrepareInfo()
	return self.prepare_info
end

function KuafuPVPData:GetUserInfoList(index)
	return self.prepare_info.user_info_list[index]
end

function KuafuPVPData:GetAllUserInfoList()
	return self.prepare_info.user_info_list
end

function KuafuPVPData:GetPrepareAndFightTime()
	return self.prepare_info.next_state_time
end

function KuafuPVPData:GetRoleTeamIndex()
	local main_role_id = GameVoManager.Instance:GetMainRoleVo()
	for k,v in pairs(KuafuPVPData.Instance:GetAllUserInfoList()) do
		if main_role_id.obj_id == v.obj_id then
			return v.team
		end
	end
end

function KuafuPVPData:GetGatherNameByObjid(objid)
	local name,color = "", COLOR3B.WHITE
	local col_t = {[0] = COLOR3B.WHITE, COLOR3B.RED, COLOR3B.BLUE}
	for k,v in pairs(self.stronghold_info.stronghold_list) do
		if objid == v.obj_id then
			name = Language.KuafuPVP.GatherName[v.owner_side + 1] or ""
			color = col_t[v.owner_side + 1] or COLOR3B.WHITE
		end
	end
	return name,color
end

function KuafuPVPData:GetGatherResByObjid(objid)
	local res = 21
	local res_t = {[0] = 21, 22, 15}
	for k,v in pairs(self.stronghold_info.stronghold_list) do
		if objid == v.obj_id then
			res = res_t[v.owner_side + 1] or 21
		end
	end
	return res
end


function KuafuPVPData:GetJoinTimesReward(join_times)
	local cfg =  ConfigManager.Instance:GetAutoConfig("kuafu_tvt_auto").join_times_reward
	local num = #cfg
	for i = 1, #cfg do
		if join_times >= cfg[i].jion_times and cfg[i].seq + 1 == self.reward_daycount then
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
function KuafuPVPData:GetRewardIntegralCfg(protocol)
	self.challenge_score = protocol.info.challenge_score
	self.gongxun_value = protocol.info.gongxun_value
	self.gongxun_reward_fetch_list = bit:d2b(protocol.info.gongxun_reward_fetch_flag)
end

function KuafuPVPData:GetRewardIntegral()
	return self.challenge_score
end
function KuafuPVPData:GetRewardGongxun()
	return self.gongxun_value
end

function KuafuPVPData:GetPvPGongXunRewardIsGet(index)
	return self.gongxun_reward_fetch_list[32- index]
end

function KuafuPVPData:GetPvPGongXunRewardIsGetFlag()
	return self.gongxun_reward_fetch_list
end

function KuafuPVPData:GetRewardCfg()
	local reward_cfg = ConfigManager.Instance:GetAutoConfig("kuafu_tvt_auto").join_times_reward
	return reward_cfg
end

function KuafuPVPData:GetRewardDanCfg()
	local reward_cfg = ConfigManager.Instance:GetAutoConfig("kuafu_tvt_auto").grade_score
	return reward_cfg
end

function KuafuPVPData:GetMaxScoreCfg()
	local score_max = ConfigManager.Instance:GetAutoConfig("kuafu_tvt_auto").other[1].finish_match_score
	return score_max
end

function KuafuPVPData:GetJiFenRewardCfg()
	local reward_cfg = ConfigManager.Instance:GetAutoConfig("kuafu_tvt_auto").score_reward
	-------------------已领取的奖励放到最后面----------------------------------
	local data_list = {}
	local list = {}
	for i,v in pairs(reward_cfg) do 
		local is_lingqu = KuafuPVPData.Instance:GetPvPGongXunRewardIsGet(v.seq)
		if is_lingqu ~= 1 then --未领取的奖励
			table.insert(data_list,v)
		else --已领取的奖励
			table.insert(list,v)
		end
	end
	--遍历已领取的奖励并且放到最后面
	for i,v in pairs(list) do 
		table.insert(data_list,v)
	end

	return data_list
end

function KuafuPVPData:GetGongXunRewardCount()
	local cfg = ConfigManager.Instance:GetAutoConfig("kuafu_tvt_auto")
	return #cfg.score_reward
end



function KuafuPVPData:GetdwRankReward(season)
	local cfg = ConfigManager.Instance:GetAutoConfig("kuafu_tvt_auto").gxshow_cfg
	 local data = {}
	for k,v in pairs(cfg) do
		if v.season == season then
			data[v.grade] = {}
			data[v.grade].seq = v.seq
			data[v.grade].grade = v.grade
			data[v.grade].score = v.score
			data[v.grade].name = v.name
			data[v.grade].reward_item = v.reward_item
		end
	end
	return data
end

function KuafuPVPData:GetSeasonRewardCount()
	local kf_info = self:GetActivityInfo()
	local season = kf_info.cur_season
	local cfg = ConfigManager.Instance:GetAutoConfig("kuafu_tvt_auto")
	local count = 0
	for k,v in pairs(cfg.gxshow_cfg) do
		if v.season == season then
			count = count + 1
		end
	end
	return count
end

function KuafuPVPData:GetSeasonRewardBySeq(grade)
	local cfg = ConfigManager.Instance:GetAutoConfig("kuafu_tvt_auto")
	local kf_info = self:GetActivityInfo()
	local season = kf_info.cur_season
	for k,v in pairs(cfg.gxshow_cfg) do
		if v.grade == grade + 1 and v.season == season then
			return v
		end
	end
end

function KuafuPVPData:CheckLingPaiID(item_id)
	local cfg = ConfigManager.Instance:GetAutoConfig("kuafu_tvt_auto")
	local kf_info = self:GetActivityInfo()
	local season = kf_info.cur_season
	local list = ListToMap(cfg.season_card, "season", "grade")
	for i=1, season do
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

function KuafuPVPData:GetLingPaiCfgByID(item_id)
	local cfg = ConfigManager.Instance:GetAutoConfig("kuafu_tvt_auto")
	local kf_info = self:GetActivityInfo()
	local season = kf_info.cur_season
	local list = ListToMap(cfg.season_card, "season", "grade")
	for i=1, season do
		if list[i] then
			for j = 0, #list[i] do
				if list[i][j].reward_item.item_id == item_id then
					return list[i][j]
				end
			end
		end
	end
end

function KuafuPVPData:GetStrongHoldCfg()
	local cfg = ConfigManager.Instance:GetAutoConfig("kuafu_tvt_auto").show_cfg[1]
	if cfg == nil or next(cfg) == nil then return end
	local hold_cfg = {}
	for i = 1, 3 do
		local data = {}
		if i == 1 then
			data.hold = cfg.hold_blue
		elseif i == 2 then
			data.hold = cfg.hold_red
		else
			data.hold = cfg.hold_none
		end
		data.pos_x = cfg.stronghold_x
		data.pos_y = cfg.stronghold_y
		hold_cfg[i] = data
	end
	return hold_cfg
end

function KuafuPVPData:GetRewardBaseCell(jifen)
	local item_cfg = ConfigManager.Instance:GetAutoConfig("kuafu_tvt_auto").grade_score

	for k = #item_cfg,1, -1 do
		if item_cfg[k].score <= jifen then
			return item_cfg[k]
		end
	end
	return item_cfg[1]
end

function KuafuPVPData:GetGridNum()
	return #ConfigManager.Instance:GetAutoConfig("kuafu_tvt_auto").grade_score
end

function KuafuPVPData:SetProgLevel(grade)
	local item_cfg = ConfigManager.Instance:GetAutoConfig("kuafu_tvt_auto").grade_score
	if grade < #item_cfg - 1 then
		for k = #item_cfg,1, -1 do
			if item_cfg[k].grade == grade + 1 then
				return item_cfg[k]
			end
		end
	end
	return item_cfg[#item_cfg]
end

function KuafuPVPData:GetWZLingPaiCfg()
	self.cfg_list = ConfigManager.Instance:GetAutoConfig("kuafu_tvt_auto").xndex
	local data_lits = self:GetActivityInfo()
	self.data_cfg = {}
	for k,v in ipairs(self.cfg_list) do
		local data = {}
		data_flag = data_lits.cross_3v3_season_reward[k]
		self.data_cfg[k] = {}
		self.data_cfg[k].index = v.seq
		self.data_cfg[k].flag = data_flag
		self.data_cfg[k].cur_season = data_lits.season_count
		self.data_cfg[k].pic = v.img_pic
	end
	return self.data_cfg
end

function KuafuPVPData:GetWZCardAttributeCfg(index,grade)
	local ring_att = ConfigManager.Instance:GetAutoConfig("kuafu_tvt_auto").season_card
	for k,v in ipairs(ring_att) do
		if v.season == index and v.grade == grade then
			return v
		end
	end
	return nil
end

function KuafuPVPData:GetPvPRankData()
	local ranking_data = RankData.Instance:GetRankData(RankKind.Cross, CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_3V3_SCORE)
	local kfpvp_other_cfg = ConfigManager.Instance:GetAutoConfig("kuafu_tvt_auto").other[1]
	self.pvp_rank_list = {}
	for k,v in pairs(ranking_data) do
		if v.rank_value >= kfpvp_other_cfg.rank_score_limit then
			table.insert(self.pvp_rank_list, v)
		end
	end
	return self.pvp_rank_list
end


function KuafuPVPData:RemindKFPvP()
	local cfg = self:GetJiFenRewardCfg()
	local gongxun_value = self:GetRewardGongxun()
	local flag = 0
	for k,v in ipairs(cfg) do
		local remind = self:GetPvPGongXunRewardIsGet(v.seq)
		if gongxun_value >= v.need_score and remind == 0 then
			flag = flag + 1
		end 
	end
	return  flag
end

function KuafuPVPData:SetRankList(info)
	if info then
		self.rank_list = info
	end
end

function KuafuPVPData:GetRankListInfo()
	return self.rank_list
end

function KuafuPVPData:GetRankList()
	local kfpvp_other_cfg = ConfigManager.Instance:GetAutoConfig("kuafu_tvt_auto").other[1]
	local rank_list = self:GetRankListInfo()
	self.pvp_rank_list = {}
	for k,v in pairs(rank_list) do
		if v.rank_value >= kfpvp_other_cfg.rank_score_limit then
			table.insert(self.pvp_rank_list, v)
		end
	end
	return self.pvp_rank_list
end


function KuafuPVPData:GetShiZhuangId()
	local cfg = ConfigManager.Instance:GetAutoConfig("kuafu_tvt_auto")
	if cfg then
		return cfg.show_cfg[1].index
	end
end

function KuafuPVPData:GetTitleId()
	local cfg = ConfigManager.Instance:GetAutoConfig("kuafu_tvt_auto")
	if cfg then
		return cfg.show_cfg[1].title_id
	end
end


function KuafuPVPData:GetRankByScore(score)
	if not score then return end
	local rank_config = self:GetRewardDanCfg()
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

function KuafuPVPData:GetRewardByJoin(jion_times)
	local cfg =  ConfigManager.Instance:GetAutoConfig("kuafu_tvt_auto").join_times_reward
	if cfg then
		for k,v in pairs(cfg) do
			if v.jion_times == jion_times then
				return v
			end
		end
	end
end

--参加次数
function KuafuPVPData:GetMaxJionTimes()
	local cfg =  ConfigManager.Instance:GetAutoConfig("kuafu_tvt_auto").other[1]
	return cfg.join_limit_daycount
end

function KuafuPVPData:GetRewardBaseCell(jifen)
	local item_cfg = ConfigManager.Instance:GetAutoConfig("kuafu_tvt_auto").grade_score

	for k = #item_cfg,1, -1 do
		if item_cfg[k].score <= jifen then
			return item_cfg[k]
		end
	end
	return item_cfg[1]
end

function KuafuPVPData:SetProgLevel(grade)
	local item_cfg = ConfigManager.Instance:GetAutoConfig("kuafu_tvt_auto").grade_score
	if grade < #item_cfg - 1 then
		for k = #item_cfg,1, -1 do
			if item_cfg[k].grade == grade + 1 then
				return item_cfg[k]
			end
		end
	end
	return item_cfg[#item_cfg]

end

--王者之戒红点提示
function KuafuPVPData:GetSeasonCardRemind()
	if self.acticity_info.cross_3v3_season_reward_use == nil and self.acticity_info.cross_3v3_season_reward == nil then
		return 0
	end

	local count = 0
	for k,v in pairs(self.acticity_info.cross_3v3_season_reward_use) do
		if v > 0 then
			count = count + 1
		end
	end
	if count >=2 then
		return 0
	end

	local have_card = 0
	for k,v in pairs(self.acticity_info.cross_3v3_season_reward) do
		if v > 0 then
			have_card = have_card + 1
		end
	end
	if have_card > count then
		return 1
	else
		return 0
	end
end
