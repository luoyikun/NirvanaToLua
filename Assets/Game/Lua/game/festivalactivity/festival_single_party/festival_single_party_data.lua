FestivalSinglePartyData = FestivalSinglePartyData or BaseClass()

function FestivalSinglePartyData:__init()
	if nil ~= FestivalSinglePartyData.Instance then
		print_error("[FestivalSinglePartyData] Attemp to create a singleton twice !")
		return
	end

	FestivalSinglePartyData.Instance = self
	self.single_party_role_info = {}
	self.single_party_fb_info = {}
	self.single_party_drop_info = {}
	self.wave_cfg = {}
	self.single_party_cfg = ConfigManager.Instance:GetAutoConfig("holidayguardconfig_auto")
end

function FestivalSinglePartyData:__delete()
	FestivalSinglePartyData.Instance = nil
end

--单身派对个人信息
function FestivalSinglePartyData:SetEnterSinglePartyTimes(protocol)
	self.join_times = protocol.personal_join_times or 0
	self.personal_kill_monster_count = protocol.personal_kill_monster_count
	self.reserve_ch = protocol.reserve_ch
end

function FestivalSinglePartyData:GetEnterSinglePartyTimes()
	return self.join_times
end

--派对塔防信息
function FestivalSinglePartyData:SetSinglePartyInfo(protocol)
	self.single_party_fb_info.reason = protocol.reason
	self.single_party_fb_info.reserve = protocol.reserve
	self.single_party_fb_info.time_out_stamp = protocol.time_out_stamp
	self.single_party_fb_info.is_finish = protocol.is_finish
	self.single_party_fb_info.is_pass = protocol.is_pass
	self.single_party_fb_info.pass_time_s = protocol.pass_time_s
	self.single_party_fb_info.life_tower_left_hp = protocol.life_tower_left_hp
	self.single_party_fb_info.life_tower_left_maxhp = protocol.life_tower_left_maxhp
	self.single_party_fb_info.curr_wave = protocol.curr_wave
	self.single_party_fb_info.reserve_1 = protocol.reserve_1
	self.single_party_fb_info.next_wave_refresh_time = protocol.next_wave_refresh_time
	self.single_party_fb_info.clear_wave_count = protocol.clear_wave_count
	self.single_party_fb_info.total_kill_monster_count = protocol.total_kill_monster_count
	self.single_party_fb_info.get_coin = protocol.get_coin
	self.single_party_fb_info.get_item_count = protocol.get_item_count
	self.single_party_fb_info.pick_drop_list = protocol.pick_drop_list
end

--个人塔防掉落
function FestivalSinglePartyData:SetSinglePartyDropInfo(protocol)
	self.single_party_drop_info.get_coin = protocol.get_coin
	self.single_party_drop_info.get_item_count = protocol.get_item_count
	self.single_party_drop_info.item_list = protocol.item_list
end

function FestivalSinglePartyData:GetSinglePartyDropInfo()
	return self.single_party_drop_info
end

--塔防结果
function FestivalSinglePartyData:SetSinglePartyResultInfo(protocol)
	self.is_passed = protocol.is_passed
	self.clear_wave_count = protocol.clear_wave_count
	self.resertotal_kill_monster_countve_sh = protocol.resertotal_kill_monster_countve_sh
end

function FestivalSinglePartyData:GetIsPassed()
	return self.is_passed
end

function FestivalSinglePartyData:GetSinglePartyMyKillCount()
	return self.personal_kill_monster_count
end

function FestivalSinglePartyData:GetSingleParyRoleInfo()
	return self.tower_defend_role_info
end

function FestivalSinglePartyData:GetSinglePartyDefendInfo()
	return self.single_party_fb_info
end


function FestivalSinglePartyData:SetSinglePartyWaveCfg()
	self.wave_cfg = ListToMapList(self.single_party_cfg.wave_list, "wave")
end

--波次配置信息
function FestivalSinglePartyData:GetSinglePartyWaveCfg()
	local wave_cfg = self.single_party_cfg.wave_list
	return wave_cfg
end

--当前关卡
function FestivalSinglePartyData:GetCurrentLevel()
	local level_scene_cfg = self.single_party_cfg.level_scene_cfg
	local level = 0
	if level_scene_cfg ~= nil or next(leve_scene_cfg) ~= nil then
		level = level_scene_cfg[1].level
	end
	return level
end

function FestivalSinglePartyData:GetSinglePartyGuajiPos(chapter)
	local pos = {}
	pos.x = self.single_party_cfg.level_scene_cfg[chapter].guaji_pos_x
	pos.y = self.single_party_cfg.level_scene_cfg[chapter].guaji_pos_y
	return pos
end

function FestivalSinglePartyData:SetTowerIsWarning(state)
	self.tower_is_warning = state
end

function FestivalSinglePartyData:GetTowerIsWarning()
	return self.tower_is_warning
end

-- ------------------------------ 排行榜 ------------------------------
function FestivalSinglePartyData:SetSpecialAppearanceInfo(protocol)
	self.special_appearance_rank_count = GameEnum.HOLIDAYGUARD_PERSON_RANK_MAX
	self.special_appearance_rank_list = protocol.kill_rank
	if self.special_appearance_rank_count > 10 then
		self.special_appearance_rank_count = 10
	end

	table.sort(self.special_appearance_rank_list, self:SortKillRankList("kill_monster_count", "pass_time"))
end


function FestivalSinglePartyData:GetSpecialAppearanceRankJoinRewardCfg()
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().other
	return config[1].holiday_guard_kill_rank_reward
end

function FestivalSinglePartyData:GetSpecialAppearanceRankCfg()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().special_appearance_rank
end

function FestivalSinglePartyData:GetSpecialAppearanceRankList()
	return self.special_appearance_rank_list or {}
end

function FestivalSinglePartyData:GetSpecialAppearanceRankCount()
	local rank_count = 0
	if self.special_appearance_rank_list == nil then
		return rank_count 
	end
	for k,v in pairs(self.special_appearance_rank_list) do
		if v.kill_monster_count ~= 0 then
			rank_count = rank_count + 1
		end
	end
	return rank_count
end

function FestivalSinglePartyData:GetMySpecialAppearanceRank()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if nil == self.special_appearance_rank_list then
		return 0
	end
	for i, v in ipairs(self.special_appearance_rank_list) do
		if main_role_vo.role_id == v.uid then
			return i
		end
	end
	return -1
end

--奖励配置表 
function FestivalSinglePartyData:GetSinglePartyRewardConfig()
	local reward_cfg = {}
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	if config == nil then
		return reward_cfg
	end
	local reward_cfg = ActivityData.Instance:GetRandActivityConfig(config.holiday_guard_kill_rank_reward, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HOLIDAY_GUARD)
	return reward_cfg
end

function FestivalSinglePartyData:SetTowerIsWarning(state)
	self.tower_is_warning = state
end

function FestivalSinglePartyData:GetTowerIsWarning()
	return self.tower_is_warning
end

function FestivalSinglePartyData:GetSinglePartyOtherCfg()
	return self.single_party_cfg.other[1]
end

----------------------------------------- 活动入口npc -----------------------------------------

function FestivalSinglePartyData:SetNpcEnterCfg()
	self.enter_cfg = self.single_party_cfg.enter_config
end

function FestivalSinglePartyData:SetEnterSceneCfg()
	self.npc_refresh_limit = self.single_party_cfg.npc_refresh_limit
end

function FestivalSinglePartyData:GetEnterSceneCfg()
	if self.npc_refresh_limit == nil then
		self:SetEnterSceneCfg()
	end
	return self.npc_refresh_limit
end

function FestivalSinglePartyData:GetNPCRefreshSceneCount()
	local count = 0
	if self.npc_refresh_limit == nil then
		self:GetEnterSceneCfg()
	end
	for k,v in pairs(self.npc_refresh_limit) do
		if v.scene_id ~= nil and v.scene_id ~= 0 then
			count = count + 1
		end
	end
	return count
end

function FestivalSinglePartyData:GetNpcEnterCfg()
	if self.enter_cfg == nil then
		self:SetNpcEnterCfg()
	end

	return self.enter_cfg
end

-- 判断是否为活动入口NPC
function FestivalSinglePartyData:IsSinglePartyNpc(npc_id)
	local enter_cfg = self:GetNpcEnterCfg()
	if enter_cfg == nil then
		return false
	end

	for k,v in pairs(enter_cfg) do
		if npc_id == v.npc_id then
			return true
		end
	end

	return false
end

function FestivalSinglePartyData:FiltrateEnterNpc(protocol)
	if protocol == nil or protocol.npc_list == nil then
		return {}
	end
	self.npc_list = {}
	self.npc_count = 0
	for k,v in pairs(protocol.npc_list) do
		if v.npc_id ~= 0 then
			table.insert(self.npc_list, v)
			self.npc_count = self.npc_count + 1
		end
	end
	return self.npc_list, self.npc_count
end

function FestivalSinglePartyData:GetTotalNpcCountInScene()
	return self.npc_count or 0
end

function FestivalSinglePartyData:GetSceneNpcBySceneID(scene_id)
  local npc_vo_list = {}
  if self.npc_list == nil then
 	return
  end
  for k,v in pairs(self.npc_list) do
    if scene_id ~= nil and scene_id == v.scene_id then
      local npc_vo = GameVoManager.Instance:CreateVo(NpcVo)
      npc_vo.npc_index = v.npc_index
      npc_vo.pos_x = v.npc_x
      npc_vo.pos_y = v.npc_y
      npc_vo.npc_id = v.npc_id
      npc_vo.scene_id = v.scene_id
      npc_vo.is_walking = 0
      table.insert(npc_vo_list, npc_vo)
    end
  end
  return npc_vo_list
end

function FestivalSinglePartyData:GetSceneNpcCountBySceneID(scene_id)
	local npc_count = 0
	if self.npc_list == nil then
		return npc_count
	end
	for k,v in pairs(self.npc_list) do
		if v.npc_id ~= 0 and scene_id == v.scene_id then
			npc_count = npc_count + 1
		end
	end
	return npc_count
end

function FestivalSinglePartyData:GetNpcIndexByPosition(x, y)
	local index = 0
	if self.npc_list ~= nil then
		for k,v in pairs(self.npc_list) do
			if v.npc_id ~= 0 and v.npc_x == x and v.npc_y == y then
				index = v.npc_index
			end
		end
	end
	return index
end

function FestivalSinglePartyData:SortKillRankList(sort_key_name1, sort_key_name2)
	return function(a, b)
		local order_a = 100000
		local order_b = 100000
		if a[sort_key_name1] > b[sort_key_name1] then
			order_a = order_a + 10000
		elseif a[sort_key_name1] < b[sort_key_name1] then
			order_b = order_b + 10000
		end

		if nil == sort_key_name2 then  return order_a > order_b end

		if a[sort_key_name2] < b[sort_key_name2] then
			order_a = order_a + 1000
		elseif a[sort_key_name2] > b[sort_key_name2] then
			order_b = order_b + 1000
		end
		
		return order_a > order_b
	end
end