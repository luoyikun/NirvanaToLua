KFMonthBlackWindHighData = KFMonthBlackWindHighData or BaseClass()

function KFMonthBlackWindHighData:__init()
	if KFMonthBlackWindHighData.Instance then
		ErrorLog("[KFMonthBlackWindHighData] attempt to create singleton twice!")
		return
	end
	KFMonthBlackWindHighData.Instance = self
	self.score = 0
	self.box_count = 0
	self.next_check_reward_timestamp = 0
	self.rank_list = {}
	self.boss_info = {}
	self.reward_list = {}
	self.player_info_broadcast = {}
	self.main_role_rank_info = {
		rank_val = -1,
		rank = "-",
	}
end

function KFMonthBlackWindHighData:__delete()
	KFMonthBlackWindHighData.Instance = nil
end

function KFMonthBlackWindHighData:SetCrossDarkNightUserInfo(protocol)
	self.score = protocol.score 			--击杀怪物积分
	self.box_count = protocol.box_count		--所持宝箱数量
	self.total_reward_box_count = protocol.total_reward_box_count		--累计结算的宝箱数量
	self.reward_count = protocol.reward_count 							--奖励次数
	self.reward_list = protocol.reward_list								--活动结束奖励
end

function KFMonthBlackWindHighData:GetActivityEndRewardList()
	if self.reward_list then
		local fisish_rewards_id_list = {}
		local fisish_rewards_isbind_list = {}
		local temp_reward_list = {}
		temp_reward_list = self.reward_list
		local score_reward = self:GetScoreCfgByScore()
		for k,v in pairs(score_reward) do
			if v then
				table.insert(temp_reward_list, v)
			end
		end
		for k,v in pairs(temp_reward_list) do
			if v then
				for m,n in pairs(v) do
					if n.item_id and n.item_id > 0 then
						fisish_rewards_id_list[n.item_id] = fisish_rewards_id_list[n.item_id] or 0
						fisish_rewards_id_list[n.item_id] = fisish_rewards_id_list[n.item_id] + n.num
						fisish_rewards_isbind_list[n.item_id] = n.is_bind or 1
					end
				end
			end
		end

		local item_list = {}
		for m, n in pairs(fisish_rewards_id_list) do
			if m and n and fisish_rewards_isbind_list[m] then
				table.insert(item_list, {is_bind = fisish_rewards_isbind_list[m], item_id = m, num = n})
			end
		end
		return item_list
	end
end

function KFMonthBlackWindHighData:SetCrossDarkNightRankInfo(protocol)
	self.rank_list = {}
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	self.main_role_rank_info = {rank_val = -1,
		rank = "-",}
	for i,v in ipairs(protocol.rank_list) do
		self.rank_list[i] = {}
		self.rank_list[i].name = v.name
		self.rank_list[i].rank_val = v.rank_val			--宝箱数(已按宝箱数排名)
		self.rank_list[i].rank = tostring(i)
		if v.name == main_role_vo.role_name then
			self.main_role_rank_info = self.rank_list[i]
		end
	end
end

function KFMonthBlackWindHighData:SetCrossDarkNightBossInfo(protocol)

	for i = 1, GameEnum.CROSS_DARK_NIGHT_BOSS_POS_INDEX_MAX do
		self.boss_info[i] = {}
		self.boss_info[i].monster_id = protocol.boss_info[i].monster_id
		self.boss_info[i].pos_x = protocol.boss_info[i].pos_x
		self.boss_info[i].pos_y = protocol.boss_info[i].pos_y
		self.boss_info[i].max_hp = protocol.boss_info[i].max_hp
		self.boss_info[i].cur_hp = protocol.boss_info[i].cur_hp
		self.boss_info[i].boss_status = protocol.boss_info[i].boss_status
	end
	-- KFMonthBlackWindHighCtrl.Instance:SetTargetBossInfo(self.boss_info[1])
end

function KFMonthBlackWindHighData:SetFollowNum(num)
	local main_role = Scene.Instance:GetMainRole()
	if main_role then
		if num == 0 then
			num = ""
		end
		main_role:SetFollowNum(num)
	end
end

function KFMonthBlackWindHighData:GetRewardCount()
	return self.reward_count
end

function KFMonthBlackWindHighData:SetCrossDarkNightPlayerInfoBroadcast(protocol)
	self.player_info_broadcast[protocol.obj_id] = protocol.box_count
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if obj then
		if obj:GetType() == SceneObjType.Role or obj:GetType() == SceneObjType.MainRole then
			if protocol.box_count == 0 then
				num = ""
			else
				num = protocol.box_count
			end
			obj:SetFollowNum(num)
			obj:ReloadSpecialImage()
		end
	end
end

function KFMonthBlackWindHighData:SetCrossDarkNightRewardTimestampInfo(protocol)
	self.next_check_reward_timestamp = protocol.next_check_reward_timestamp
end

function KFMonthBlackWindHighData:GetCrossDarkNightPlayerInfoBroadcast(obj_id)
	return self.player_info_broadcast[obj_id]
end

function KFMonthBlackWindHighData:RemovePlayerInfoBroadcast()
	self.player_info_broadcast = {}
end

function KFMonthBlackWindHighData:GetRankListInfo()
	return self.rank_list
end

function KFMonthBlackWindHighData:GetScoreInfo()
	return self.score
end

function KFMonthBlackWindHighData:GetBoxCountInfo()
	return self.box_count
end

function KFMonthBlackWindHighData:GetBossInfo()
	local num = 0
	for k, v in pairs(self.boss_info) do
		if v ~= nil and v.monster_id ~= 0 then
			num = num + 1
		end
	end
	return self.boss_info, num
end

function KFMonthBlackWindHighData:SetTargetBossInfo(info)
	self.target_boss_info = info
end

function KFMonthBlackWindHighData:GetTargetBossInfo()
	return self.target_boss_info or self.boss_info[1]
end

function KFMonthBlackWindHighData:GetTotalRewardBoxCount()
	return self.total_reward_box_count or 0
end

function KFMonthBlackWindHighData:GetCrossDarkNightCfg()
	return ConfigManager.Instance:GetAutoConfig("cross_dark_night_auto")
end

function KFMonthBlackWindHighData:GetBoxCfg()
	local auto = ConfigManager.Instance:GetAutoConfig("cross_dark_night_auto")
	if auto and auto.box_cfg then
		return auto.box_cfg[1]
	end
end

function KFMonthBlackWindHighData:GetCrossDarkNightBossCfg()
	local cfg = self:GetCrossDarkNightCfg()
	return cfg.boss_cfg
end

function KFMonthBlackWindHighData:GetCrossDarkNightScoreCfg()
	local cfg = self:GetCrossDarkNightCfg()
	local max_cfg = {}
	for i,v in ipairs(cfg.score_cfg) do
		max_cfg = v
		if self.score < v.score then
			return v
		end
	end
	if max_cfg.score and self.score >= max_cfg.score then
		return max_cfg
	end
	return {}
end

function KFMonthBlackWindHighData:GetScoreCfgByScore()
	if self.score then
		local cfg = self:GetCrossDarkNightCfg()
		local score_reward_list = {}
		if cfg and cfg.score_cfg then
			for k,v in pairs(cfg.score_cfg) do
				if self.score >= v.score then
					table.insert(score_reward_list, v.reward_item)
					-- local data = {{item_id = COMMON_CONSTS.VIRTUAL_KF_ITEM_HORNOR, num = v.cross_honor, is_bind = 1}}
					-- table.insert(score_reward_list, data)
				end
			end
		end
		return score_reward_list
	end
end

function KFMonthBlackWindHighData:GetRankInfoByIndex(index)
	return self.rank_list[index]
end

function KFMonthBlackWindHighData:GetBossCfgById(boss_id)
	local boss_cfg = self:GetCrossDarkNightBossCfg()
	for i,v in ipairs(boss_cfg) do
		if v.monster_id == boss_id then
			return v.seq_index + 1, v
		end
	end
	return #boss_cfg, boss_cfg[#boss_cfg]
end

function KFMonthBlackWindHighData:GetNextCheckRewardTimestamp()
	return self.next_check_reward_timestamp
end

function KFMonthBlackWindHighData:GetBossIsFlush()
	local server_time = TimeCtrl.Instance:GetServerTime()
	return self.next_check_reward_timestamp == 0 or self.next_check_reward_timestamp < server_time
end

function KFMonthBlackWindHighData:GetMyRankList()
	return self.main_role_rank_info
end

function KFMonthBlackWindHighData:GetOthercfg()
	local cfg = ConfigManager.Instance:GetAutoConfig("cross_dark_night_auto").other_cfg
	return cfg[1]
end

function KFMonthBlackWindHighData:GetMaxScore()
	local cfg = self:GetCrossDarkNightCfg()
	if cfg and cfg.score_cfg then
		local max_num = GetListNum(cfg.score_cfg)
		return cfg.score_cfg[max_num].score
	end
	return 0
end