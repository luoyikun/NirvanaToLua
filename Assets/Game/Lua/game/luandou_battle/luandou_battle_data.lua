LuanDouBattleData = LuanDouBattleData or BaseClass()

LuanDouBattleData.RANK_LINE_COUNT = 6
function LuanDouBattleData:__init()
	if LuanDouBattleData.Instance then
		ErrorLog("[LuanDouBattleData] attempt to create singleton twice!")
		return
	end
	LuanDouBattleData.Instance = self

	self.role_info = {
		turn =1,
		score = 0,
		rank = 0,
		boss_hp_per = 0,
		next_redistribute_time = 0,
		next_get_score_time = 0,
		next_update_rank_time = 0,
		kick_out_time = 0,
	}

	self.jifen_rank = {}
	self.all_jifen_rank = {}
	self.hurt_rank = {}
	self.score_rank = {}
	self.item_id_list = {}
	self.score = 0
	self.is_cross_req = 1
	self.luandou_cfg = ConfigManager.Instance:GetAutoConfig("messbattlefb_auto")
end

function LuanDouBattleData:__delete()
	LuanDouBattleData.Instance = nil
end

function LuanDouBattleData:GetConfig()
	return self.luandou_cfg
end

-- 设置个人信息
function LuanDouBattleData:SetRoleInfo(protocol)
	self.role_info.turn = protocol.turn
	self.role_info.score = protocol.score
	self.role_info.rank = protocol.rank
	self.role_info.total_score = protocol.total_score
	self.role_info.total_rank = protocol.total_rank
	self.role_info.boss_hp_per = protocol.boss_hp_per
	-- self.role_info.total_kill_count = protocol.total_kill_count
	self.role_info.next_redistribute_time = protocol.next_redistribute_time
	self.role_info.next_get_score_time = protocol.next_get_score_time
	self.role_info.next_update_rank_time = protocol.next_update_rank_time
	self.role_info.kick_out_time =  protocol.kick_out_time
	self.role_info.boss_max_hp = protocol.boss_max_hp
	self.role_info.boss_cur_hp = protocol.boss_cur_hp
end

-- 获取个人信息
function LuanDouBattleData:GetRoleInfo()
	return self.role_info
end

function LuanDouBattleData:SetJiFenRankInfo(protocol)
	self.jifen_rank = protocol.rank_info_list
end

function LuanDouBattleData:SetAllJiFenRankInfo(protocol)
	self.all_jifen_rank = protocol.role_info_list
end

function LuanDouBattleData:GetJiFenRankInfo()
	return self.jifen_rank
end

function LuanDouBattleData:GetAllJiFenRankInfo()
	return self.all_jifen_rank
end

function LuanDouBattleData:SetHurtRankInfo(protocol)
	self.hurt_rank = protocol.rank_info_list
end

function LuanDouBattleData:GetHurtRankInfo()
	return self.hurt_rank
end

function LuanDouBattleData:SetBattleReward(protocol)
	self.item_id_list = protocol.item_id_list
end

-- 获取排行奖励
function LuanDouBattleData:GetAllRankReward()
	local cfg = self.luandou_cfg.reward
	if nil == cfg then return end

	local reward_cfg = {}
	for k,v in pairs(self.item_id_list) do
		if v >= 0 then
			for m,n in ipairs(cfg) do
				if v % 100 >= n.min_rank and v % 100 <= n.max_rank then
					local temp = TableCopy(n)
					temp.turn = k + 1
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
					table.insert(reward_cfg, temp)
				end
			end
		end
	end
	return reward_cfg
end


function LuanDouBattleData:SetRoleInfoJiFen(score)
	self.score = score
end

function LuanDouBattleData:GetRoleInfoJiFen()
	return self.score
end

function LuanDouBattleData:GetOtherConfig()
	if self.luandou_cfg then
		return self.luandou_cfg.other[1]
	end
end
function LuanDouBattleData:GetBossPos()
	if self.luandou_cfg then
		local other_cfg = self:GetOtherConfig()
		if other_cfg then
			local x, y = other_cfg.boss_position_x, other_cfg.boss_position_y
			return x, y
		end
	end
	return 0, 0
end

function LuanDouBattleData:SetIsCrossServerState(index)
	self.is_cross_req = index
end

function LuanDouBattleData:GetIsCrossServerState()
	return self.is_cross_req
end

function LuanDouBattleData:GetLuanDouTitle()
	if self.luandou_cfg then
		return self.luandou_cfg.other[1].title
	end
end

function LuanDouBattleData:GetTitleCfg()
	local title_cfg = {}
	if self.luandou_cfg then
		title_cfg = self.luandou_cfg.rank_title
	end
	return title_cfg
end

function LuanDouBattleData:GetNightFightRewardCfg()
	local rank_reward_cfg = {}
	if self.luandou_cfg then
		local temp_reward_cfg = self.luandou_cfg.reward
		for k , v in pairs(temp_reward_cfg) do
			if nil ~= v.reward_item then
				rank_reward_cfg[k] = v.reward_item
			end
		end
	end
	return rank_reward_cfg
end