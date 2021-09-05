ShenYuBossData = ShenYuBossData or BaseClass()

function ShenYuBossData:__init()
	if ShenYuBossData.Instance then
		print_error("[ShenYuBossData] Attempt to create singleton twice!")
		return
	end
	ShenYuBossData.Instance = self

	self.cross_mizang_cfg = ConfigManager.Instance:GetAutoConfig("cross_mizang_boss_auto")
	self.monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
	self.crossboss_list = self.cross_mizang_cfg.boss_cfg
	self.cross_other_cfg = self.cross_mizang_cfg.other[1]
	self.crossmonster_list = self.cross_mizang_cfg.monster_cfg
	self.crosscrytal_lsit = self.cross_mizang_cfg.layer_cfg
	-- 秘藏Boss
	self.cross_boss_all_list = {}
	self.cross_boss_info = {}
	self.cross_boss_list = {}
	self.leftmonsterandtreasure = {}
	self.cross_client_flush_info = {}
	self.left_can_kill_boss_num = 0
	self.crossboss_weary = 0
	self.crossboss_can_relive_time = 0

	--幽冥Boss
	self.cross_youming_cfg = ConfigManager.Instance:GetAutoConfig("cross_youming_boss_auto")
	self.cross_youmingboss_list = self.cross_youming_cfg.boss_cfg
	self.cross_youming_other_cfg = self.cross_youming_cfg.other[1]
	self.cross_youmingmonster_list = self.cross_youming_cfg.monster_cfg
	self.cross_youming_crytal_lsit = self.cross_youming_cfg.layer_cfg

	--神魔Boss
	self.godmagic_boss_cfg = ConfigManager.Instance:GetAutoConfig("godmagicboss_auto")
	self.godmagic_bosslist = self.godmagic_boss_cfg.boss_cfg
	self.godmagic_boss_layer_cfg = self.godmagic_boss_cfg.layer_cfg
	self.godmagic_boss_other_cfg = self.godmagic_boss_cfg.other[1]
	self.godmagic_boss_all_list = {}
	self.godmagic_boss_info = {}
	self.godmagic_boss_list = {}
	self.godmagic_client_flush_info = {}
	self.godmagic_left_can_kill_boss_num = 0


	self.cross_youming_boss_all_list = {}
	self.cross_youming_boss_info = {}
	self.cross_youming_boss_list = {}
	self.youming_leftmonsterandtreasure = {}
	self.godmagic_leftmonsterandtreasure = {}
	self.cross_youming_client_flush_info = {}
	self.youming_left_can_kill_boss_num = 0
	self.cross_youmingboss_weary = 0
	self.cross_youmingboss_can_relive_time = 0

	RemindManager.Instance:Register(RemindName.ShenYuBoss, BindTool.Bind(self.GetShenYuBossRemind, self))
	RemindManager.Instance:Register(RemindName.ShenYu_Secret, BindTool.Bind(self.GetCrossMiZangRedPoint, self))
	-- RemindManager.Instance:Register(RemindName.ShenYu_YouMing, BindTool.Bind(self.GetCrossYouMingRedPoint, self))
	RemindManager.Instance:Register(RemindName.ShenYu_Tujian, BindTool.Bind(self.GetTujianRedPoint, self, 1))
	RemindManager.Instance:Register(RemindName.ShenYu_Godmagic, BindTool.Bind(self.GetGodmagicRedPoint, self))
end

function ShenYuBossData:__delete()
	ShenYuBossData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.ShenYuBoss)
	RemindManager.Instance:UnRegister(RemindName.ShenYu_Tujian)
	-- RemindManager.Instance:UnRegister(RemindName.ShenYu_Secret)
	RemindManager.Instance:UnRegister(RemindName.ShenYu_YouMing)
end

function ShenYuBossData:GetCrossMiZangRedPoint()
	local tire, max_tire = self:GetCrossBossTire()
	local differ = max_tire - tire
	if differ > 0 then
		return 1
	end
	return 0
end

function ShenYuBossData:SetGodMagicBossBossInfo(protocol)
	for i,j in ipairs(protocol.scene_list) do
		self.godmagic_client_flush_info[j.layer + 1] = {}
		self.godmagic_client_flush_info[j.layer + 1].left_treasure_crystal_count = j.left_treasure_crystal_count
		self.godmagic_client_flush_info[j.layer + 1].left_monster_count = j.left_monster_count
		self.godmagic_client_flush_info[j.layer + 1].boss_list = {}
		for k,v in ipairs(j.boss_list) do
			if v.boss_id ~= 0 then
				local vo = {}
				vo.boss_id = v.boss_id
				vo.next_refresh_time = v.next_refresh_time
				self.godmagic_client_flush_info[j.layer + 1].boss_list[v.boss_id] = vo
			end
		end
	end
end

function ShenYuBossData:SetGodmagicBossPalyerInfo(protocol)
	self.godmagic_left_ordinary_crystal_gather_times = protocol.left_ordinary_crystal_gather_times
	self.godmagic_left_can_kill_boss_num = protocol.left_can_kill_boss_num
	self.godmagic_left_treasure_crystal_gather_times = protocol. left_treasure_crystal_gather_times
end

function ShenYuBossData:GetGodmagicLeftNumInScene(layer, data_type)
	if nil == self.godmagic_leftmonsterandtreasure[layer] then
		return
	end
	if data_type == 1 then
		return self.godmagic_leftmonsterandtreasure[layer].left_monster_count
	elseif data_type == 2 then
		return self.godmagic_leftmonsterandtreasure[layer].left_treasure_crystal_num
	end
end

function ShenYuBossData:GetGodmagicOtherNextFlushTimestamp(layer, data_type)
	if nil == self.godmagic_leftmonsterandtreasure[layer] then
		return
	end
	if data_type == 1 then
		return self.godmagic_leftmonsterandtreasure[layer].monster_next_flush_timestamp
	elseif data_type == 2 then
		return self.godmagic_leftmonsterandtreasure[layer].treasure_crystal_next_flush_timestamp
	end
end

function ShenYuBossData:GetGodMagicLeftTreasureGatherTimes()
	return self.godmagic_left_treasure_crystal_gather_times
end

function ShenYuBossData:GetGodMagicBossTire()
	local max_tire_value = self.godmagic_boss_other_cfg.daily_boss_num
	return self.godmagic_left_can_kill_boss_num, max_tire_value
end

function ShenYuBossData:SetGodMagicBossSceneInfo(protocol)
	self.godmagic_leftmonsterandtreasure[protocol.layer] = {
	left_treasure_crystal_num = protocol.left_treasure_crystal_num,
	left_monster_count = protocol.left_monster_count,
	monster_next_flush_timestamp = protocol.monster_next_flush_timestamp,
	treasure_crystal_next_flush_timestamp = protocol.treasure_crystal_next_flush_timestamp
	}

	local treasure_crystal_gather_id = protocol.treasure_crystal_gather_id
	local monster_next_flush_timestamp = protocol.monster_next_flush_timestamp
	local treasure_crystal_next_flush_timestamp = protocol.treasure_crystal_next_flush_timestamp
	for k, v in pairs(protocol.boss_list) do
		local vo = {}
		vo.boss_id = v.boss_id
		vo.is_exist = v.is_exist
		vo.next_refresh_time = v.next_flush_time
		vo.left_num = 0
		self.godmagic_boss_info[v.boss_id] = vo
		if self.godmagic_boss_all_list and self.godmagic_boss_all_list[protocol.layer] then
			for i,j in pairs(self.godmagic_boss_all_list[protocol.layer]) do
				if j.boss_id == v.boss_id then
					j.next_refresh_time = v.next_flush_time
				end
			end
		end
	end

	local treasure_crystal_vo = {}
	treasure_crystal_vo.boss_id = treasure_crystal_gather_id
	treasure_crystal_vo.exist = treasure_crystal_next_flush_timestamp > 0 and 1 or 0
	treasure_crystal_vo.next_refresh_time = treasure_crystal_next_flush_timestamp
	treasure_crystal_vo.left_num = protocol.left_treasure_crystal_num
	self.godmagic_boss_info[treasure_crystal_gather_id] = treasure_crystal_vo
end

function ShenYuBossData:FlushRefreshTimeByAllBossSC(boss_id, next_flush_time)
	if self.godmagic_boss_info then
		for k,v in pairs(self.godmagic_boss_info) do
			if v.boss_id == boss_id then
				v.next_refresh_time = next_flush_time
			end
		end
	end
	return 0
end

function ShenYuBossData:GetGodMagicBossFlushTimesByBossId(boss_id, scene_id)
	if self.godmagic_boss_info then
		for k,v in pairs(self.godmagic_boss_info) do
			if v and v.boss_id == boss_id then
				return v.next_refresh_time
			end
		end
	end
	return 0
end

function ShenYuBossData:GetGodMagicLayerBossBySceneID(scene_id)
	local layer = nil
	for k,v in pairs(self.godmagic_boss_layer_cfg) do
		if v.scene_id == scene_id then
			layer = v.layer_index
		end
	end
	local list = self:GetGodMagicLayerBossBylayer(layer)
	return list
end

function ShenYuBossData:GetGodMagicBossSinleInfo(scene_id, boss_id)
	local list = self:GetGodMagicLayerBossBySceneID(scene_id)
	for k,v in pairs(list) do
		if v.boss_id == boss_id then
			return v
		end
	end
end

function ShenYuBossData:GetGodMagicBossById(boss_id)
	return self.godmagic_boss_info[boss_id]
end

function ShenYuBossData:GetGodMagicAllBoss()
	if next(self.godmagic_boss_all_list) == nil then 
		for i = 1, #self.godmagic_bosslist do
			self.godmagic_boss_all_list[i] = {}
		end
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local prof = PlayerData.Instance:GetRoleBaseProf(main_role_vo.prof)
		local boss_data = {}
		for i = 1, #self.godmagic_bosslist do
			local vo = {}
			vo.layer = self.godmagic_bosslist[i].layer
			vo.boss_index = self.godmagic_bosslist[i].boss_index
			vo.boss_id = self.godmagic_bosslist[i].boss_id
			vo.x_pos = self.godmagic_bosslist[i].flush_pos_x
			vo.y_pos = self.godmagic_bosslist[i].flush_pos_y
			vo.drop_item_list = Split(self.godmagic_bosslist[i]["drop_item_list" .. prof], "|")
			boss_data = self:GetMonsterInfo(self.godmagic_bosslist[i].boss_id)			
			vo.boss_level = boss_data.level
			vo.boss_name = boss_data.name
			vo.boss_hp = boss_data.hp
			vo.boss_atk = boss_data.gongji
			vo.boss_defen = boss_data.fangyu
			vo.damage_type = boss_data.damage_type
			vo.boss_magdef = boss_data.fa_fangyu
			vo.max_delta_level = self.godmagic_bosslist[i].max_delta_level
			vo.scene_id = self.godmagic_bosslist[i].scene_id
			vo.type = BossData.MonsterType.Boss
			vo.scale = self.godmagic_bosslist[i].scale
			vo.scene_show = self.godmagic_bosslist[i].scene_show
			if self.godmagic_client_flush_info[vo.layer] ~= nil and self.godmagic_client_flush_info[vo.layer].boss_list[vo.boss_id] ~= nil then
				vo.next_refresh_time = self.godmagic_client_flush_info[vo.layer].boss_list[vo.boss_id].next_refresh_time
			end
			self.godmagic_boss_list[vo.boss_id] = vo
			if self.godmagic_boss_all_list[vo.layer] then
				table.insert(self.godmagic_boss_all_list[vo.layer], vo)
			end
		end
	end
	return self.godmagic_boss_all_list
end

function ShenYuBossData:GetGodMagicLayerBossBylayer(index)
	local all_list = self:GetGodMagicAllBoss()
	if all_list[index] then
		function sortfun(a, b)
			a.next_refresh_time = self:GetGodMagicBossFlushTimesByBossId(a.boss_id, a.scene_id)
			b.next_refresh_time = self:GetGodMagicBossFlushTimesByBossId(b.boss_id, b.scene_id)
			if a.next_refresh_time and b.next_refresh_time then
				local state_a = a.next_refresh_time > 0 and 1 or 0
				local state_b = b.next_refresh_time > 0 and 1 or 0
				if state_a and state_b and state_a ~= state_b then
					return state_a < state_b
				else
					local level_a = a.boss_level or 0
					local level_b = b.boss_level or 0
					return level_a < level_b
				end
			end
		end
		table.sort(all_list[index], sortfun)
	end
	return all_list[index] or {}
end

function ShenYuBossData:GetGodMagicBossInfoByBossId(boss_id)
	if next(self.godmagic_boss_list) == nil then
		self:GetGodMagicAllBoss()
	end
	return self.godmagic_boss_list[boss_id]
end

function ShenYuBossData:GetGodMagicBossCanGoLevel()
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	local index = 0
	for k,v in pairs(self.godmagic_boss_layer_cfg) do
		if my_level >= v.level_limit then
			index = index + 1
		end
	end
	return index
end

function ShenYuBossData:GetGodMagicSceneIDByLayer(layer)
	local cfg = self:GetGodMagicCfgByLayer(layer)
	if cfg then
		return cfg.scene_id
	end
end

function ShenYuBossData:GetGodMagicCfgByLayer(layer)
	for k,v in pairs(self.godmagic_boss_layer_cfg) do
		if v.layer_index == layer then
			return v
		end
	end
end

function ShenYuBossData:GetGodMagicBossFallList(boss_id)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo then
		local prof = PlayerData.Instance:GetRoleBaseProf(main_role_vo.prof) or 0
		if self.godmagic_bosslist then
			for k,v in pairs(self.godmagic_bosslist) do
				if v and v.boss_id == boss_id then
					local list = {}
					list = Split(v["drop_item_list" .. prof], "|")
					return list
				end
			end
		end
	end
end

function ShenYuBossData:GetCrossYouMingRedPoint()
	if RemindManager.Instance:RemindToday(RemindName.ShenYu_YouMing) then
		return 0
	end
	local tire, max_tire = self:GetYouMingCrossBossTire()
	local differ = max_tire - tire
	if differ > 0 or self.youming_left_treasure_crystal_gather_times > 0 then
		return 1
	end
	return 0
end

function ShenYuBossData:GetShenYuBossRemind()
	local num = BossData.Instance:GetCrossRedPoint()
	local num1 = self:GetTujianRedPoint(1)
	-- local num2 = self:GetCrossMiZangRedPoint()
	-- local num3 = self:GetCrossYouMingRedPoint()
	if num + num1 > 0 then
		return 1
	end
	return 0 
end

function ShenYuBossData:GetGodmagicRedPoint()
	if self.godmagic_left_can_kill_boss_num > 0 then
		return 1
	else
		return 0
	end
end

function ShenYuBossData:GetTujianRedPoint(index)
	local list = BossData.Instance:FormatMenu(index)
	for k,v in pairs(list) do
		if v.can_activef == 1 then
			return 1
		end
	end

	-- for i = 1 , #list do
	-- 	for k,v in ipairs(list[i].child) do
	-- 		if v.progress == 100 and v.reward_flag == 0 then
	-- 			return 1
	-- 		end
	-- 	end
	-- end
	return 0
end

function ShenYuBossData:SetCurInfo(scene_id, boss_id)
	self.boss_scene_id = scene_id
	self.boss_id = boss_id
end

function ShenYuBossData:GetCurBossInfo(enter_type)
	if enter_type == BOSS_ENTER_TYPE.TYPE_BOSS_MiZang then
		return self:GetCrossBossSinleInfo(self.boss_scene_id, self.boss_id)
	elseif enter_type == BOSS_ENTER_TYPE.TYPE_BOSS_YouMing then
		return self:GetCrossYouMingBossSinleInfo(self.boss_scene_id, self.boss_id)
	end
end

function ShenYuBossData:GetCrossBossSinleInfo(scene_id, boss_id)
	local list = self:GetCrossLayerBossBySceneID(scene_id)
	for k,v in pairs(list) do
		if v.boss_id == boss_id then
			return v
		end
	end
end

function ShenYuBossData:GetCrossYouMingBossSinleInfo(scene_id, boss_id)
	local list = self:GetCrossYouMingLayerBossBySceneID(scene_id)
	for k,v in pairs(list) do
		if v.boss_id == boss_id then
			return v
		end
	end
end

-------------- 跨服秘藏BOSS -------------
function ShenYuBossData:SetCrossBossPalyerInfo(protocol)
	self.left_ordinary_crystal_gather_times = protocol.left_ordinary_crystal_gather_times
	self.left_can_kill_boss_num = protocol.left_can_kill_boss_num
	self.left_treasure_crystal_gather_times = protocol.left_treasure_crystal_gather_times
	self.concern_flag = {}
	for i = 1, 5 do
		local flag = bit:d2b(protocol.concern_flag[i])
		self.concern_flag[i] = flag
	end
end

function ShenYuBossData:GetCrossBossIsConcern(layer, boss_index)
	if nil == self.concern_flag then
		return
	end
	local flag_list = self.concern_flag[layer]
	if flag_list and flag_list[33 - boss_index] == 1 then
		return true
	else
		return false
	end
end

function ShenYuBossData:GetLeftTreasureGatherTimes()
	return self.left_treasure_crystal_gather_times
end

function ShenYuBossData:SetCrossBossSceneInfo(protocol)
	self.leftmonsterandtreasure[protocol.layer] = {
	left_treasure_crystal_num = protocol.left_treasure_crystal_num,
	left_monster_count = protocol.left_monster_count,
	monster_next_flush_timestamp = protocol.monster_next_flush_timestamp,
	treasure_crystal_next_flush_timestamp = protocol.treasure_crystal_next_flush_timestamp
	}

	local treasure_crystal_gather_id = protocol.treasure_crystal_gather_id
	local monster_next_flush_timestamp = protocol.monster_next_flush_timestamp
	local treasure_crystal_next_flush_timestamp = protocol.treasure_crystal_next_flush_timestamp
	for k, v in pairs(protocol.boss_list) do
		local vo = {}
		vo.boss_id = v.boss_id
		vo.is_exist = v.is_exist
		vo.next_refresh_time = v.next_flush_time
		vo.left_num = 0
		self.cross_boss_info[v.boss_id] = vo
		if self.cross_boss_all_list[protocol.layer] then
			for i,j in pairs(self.cross_boss_all_list[protocol.layer]) do
				if j.boss_id == v.boss_id then
					j.next_refresh_time = v.next_flush_time
				end
			end
		end
	end
	local treasure_crystal_vo = {}
	treasure_crystal_vo.boss_id = treasure_crystal_gather_id
	treasure_crystal_vo.exist = treasure_crystal_next_flush_timestamp > 0 and 1 or 0
	treasure_crystal_vo.next_refresh_time = treasure_crystal_next_flush_timestamp
	treasure_crystal_vo.left_num = protocol.left_treasure_crystal_num
	self.cross_boss_info[treasure_crystal_gather_id] = treasure_crystal_vo

	local monster_info = self:GetOneMonsterByLayer(protocol.layer)
	local monster_vo = {}
	monster_vo.boss_id = monster_info.boss_id
	monster_vo.exist = monster_next_flush_timestamp > 0 and 1 or 0
	monster_vo.next_refresh_time = monster_next_flush_timestamp
	monster_vo.left_num = protocol.left_monster_count
	self.cross_boss_info[monster_info.boss_id] = monster_vo
end

function ShenYuBossData:SetCrossBossBossInfo(protocol)
	for i,j in ipairs(protocol.scene_list) do
		self.cross_client_flush_info[j.layer + 1] = {}
		self.cross_client_flush_info[j.layer + 1].left_treasure_crystal_count = j.left_treasure_crystal_count
		self.cross_client_flush_info[j.layer + 1].left_monster_count = j.left_monster_count
		self.cross_client_flush_info[j.layer + 1].boss_list = {}
		for k,v in ipairs(j.boss_list) do
			if v.boss_id ~= 0 then
				local vo = {}
				vo.boss_id = v.boss_id
				vo.next_refresh_time = v.next_flush_time
				self.cross_client_flush_info[j.layer + 1].boss_list[v.boss_id] = vo
			end
		end
	end
end

function ShenYuBossData:GetCrossAllBoss()
		for i = 1, #self.crosscrytal_lsit do
			self.cross_boss_all_list[i] = {}
		end
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local prof = PlayerData.Instance:GetRoleBaseProf(main_role_vo.prof)
		-- 水晶

		-- for i = 1, #self.crosscrytal_lsit do 
		-- 	local vo = {}
		-- 	vo.layer = self.crosscrytal_lsit[i].layer_index
		-- 	vo.boss_index = 0
		-- 	vo.boss_id = self.crosscrytal_lsit[i].treasure_crystal_gather_id
		-- 	vo.x_pos = self.crosscrytal_lsit[i].entry_x
		-- 	vo.y_pos = self.crosscrytal_lsit[i].entry_y
		-- 	vo.drop_item_list = {}
		-- 	vo.boss_level = 1
		-- 	vo.boss_name = self.crosscrytal_lsit[i].treasure_crystal_name
		-- 	vo.boss_hp = 0
		-- 	vo.boss_atk = 0
		-- 	vo.boss_defen = 0
		-- 	vo.damage_type = 0
		-- 	vo.boss_magdef = 0
		-- 	vo.type = BossData.MonsterType.Gather
		-- 	vo.max_delta_level = 1000
		-- 	vo.scale = 1
		-- 	vo.scene_id = self.crosscrytal_lsit[i].scene_id
		-- 	table.insert(self.cross_boss_all_list[vo.layer], vo)
		-- end
		local boss_data = {}
		for i = 1, #self.crossboss_list do
			local vo = {}
			vo.layer = self.crossboss_list[i].layer
			vo.boss_index = self.crossboss_list[i].boss_index
			vo.boss_id = self.crossboss_list[i].boss_id
			vo.x_pos = self.crossboss_list[i].flush_pos_x
			vo.y_pos = self.crossboss_list[i].flush_pos_y
			vo.drop_item_list = Split(self.crossboss_list[i]["drop_item_list" .. prof], "|")
			boss_data = self:GetMonsterInfo(self.crossboss_list[i].boss_id)			
			vo.boss_level = boss_data.level
			vo.boss_name = boss_data.name
			vo.boss_hp = boss_data.hp
			vo.boss_atk = boss_data.gongji
			vo.boss_defen = boss_data.fangyu
			vo.damage_type = boss_data.damage_type
			vo.boss_magdef = boss_data.fa_fangyu
			vo.max_delta_level = self.crossboss_list[i].max_delta_level
			vo.scene_id = self.crossboss_list[i].scene_id
			vo.type = BossData.MonsterType.Boss
			vo.scale = self.crossboss_list[i].scale
			vo.scene_show = self.crossboss_list[i].scene_show
			if self.cross_client_flush_info[vo.layer] ~= nil and self.cross_client_flush_info[vo.layer].boss_list[vo.boss_id] ~= nil then
				vo.next_refresh_time = self.cross_client_flush_info[vo.layer].boss_list[vo.boss_id].next_refresh_time
			end
			self.cross_boss_list[vo.boss_id] = vo
			if self.cross_boss_all_list[vo.layer] then
				table.insert(self.cross_boss_all_list[vo.layer], vo)
			end
		end
	return self.cross_boss_all_list
end

function ShenYuBossData:GetOneMonsterByLayer(index)
	local vo = {}
	local other = self.cross_other_cfg
	for i = 1, #self.crossmonster_list do
		if self.crossmonster_list[i].layer == index then
			vo.layer = self.crossmonster_list[i].layer
			vo.boss_index = 0
			vo.boss_id = self.crossmonster_list[i].monster_id
			vo.x_pos = self.crossmonster_list[i].pos_x
			vo.y_pos = self.crossmonster_list[i].pos_y
			vo.drop_item_list = {}
			vo.boss_level = 1
			vo.boss_name = other.monster_name
			vo.boss_hp = 0
			vo.boss_atk = 0
			vo.boss_defen = 0
			vo.damage_type = 0
			vo.boss_magdef = 0
			vo.type = BossData.MonsterType.Monster
			vo.max_delta_level = 1000
			vo.scene_id = 0
			vo.scale = 1
			return vo
		end
	end
end

function ShenYuBossData:GetCrossLayerBossBylayer(index)
	local all_list = TableCopy(self:GetCrossAllBoss())

	if self.cross_boss_info and all_list[index] then
		for k,v in pairs(self.cross_boss_info) do
			for k1,v1 in pairs(all_list[index]) do
				if v.boss_id == v1.boss_id then
					v1.next_refresh_time = v.next_refresh_time
				end
			end
		end
	end
	if all_list[index] then
		function sortfun(a, b)
			if a.next_refresh_time and b.next_refresh_time then
				local state_a = a.next_refresh_time > 0 and 1 or 0
				local state_b = b.next_refresh_time > 0 and 1 or 0
				if state_a and state_b and state_a ~= state_b then
					return state_a < state_b
				else
					local level_a = a.boss_level or 0
					local level_b = b.boss_level or 0
					return level_a < level_b
				end
			else
				local level_a = a.boss_level or 0
				local level_b = b.boss_level or 0
				return level_a < level_b
			end
		end
		table.sort(all_list[index], sortfun)
	end

	return all_list[index] or {}
end

function ShenYuBossData:GetCrossLayerBossBySceneID(scene_id)
	local layer = nil
	for k,v in pairs(self.crosscrytal_lsit) do
		if v.scene_id == scene_id then
			layer = v.layer_index
		end
	end
	local list = self:GetCrossLayerBossBylayer(layer)
	return list
end

function ShenYuBossData:GetShenyuLayerBySceneID(scene_id)
	local layer = 1
	for k,v in pairs(self.crosscrytal_lsit) do
		if v.scene_id == scene_id then
			layer = v.layer_index
		end
	end
	return layer
end

function ShenYuBossData:GetCrossSceneIDByLayer(layer)
	local cfg = self:GetCrossCfgByLayer(layer)
	if cfg then
		return cfg.scene_id
	end
end

function ShenYuBossData:GetCrossCfgByLayer(layer)
	for k,v in pairs(self.crosscrytal_lsit) do
		if v.layer_index == layer then
			return v
		end
	end
end

function ShenYuBossData:GetCrossLayerBySceneID(scene_id)
	for k,v in pairs(self.crosscrytal_lsit) do
		if v.scene_id == scene_id then
			return v.layer_index
		end
	end
end

function ShenYuBossData:GetCrossBossInfoByBossId(boss_id)
	if next(self.cross_boss_list) == nil then
		self:GetCrossAllBoss()
	end
	return self.cross_boss_list[boss_id]
end

function ShenYuBossData:GetCrossBossCanGoLevel()
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	local index = 0
	for k,v in pairs(self.crosscrytal_lsit) do
		if my_level >= v.level_limit then
			index = index + 1
		end
	end
	return index
end

function ShenYuBossData:GetCrossBossTire()
	local max_tire_value = self.cross_other_cfg.daily_boss_num
	return self.left_can_kill_boss_num, max_tire_value
end

function ShenYuBossData:GetCrossBossById(boss_id)
	return self.cross_boss_info[boss_id]
end

function ShenYuBossData:GetCrossLeftNum(layer, data_type)
	if nil == self.cross_client_flush_info[layer] then
		return
	end
	if data_type == 1 then
		return self.cross_client_flush_info[layer].left_monster_count
	elseif data_type == 2 then
		return self.cross_client_flush_info[layer].left_treasure_crystal_count
	end
end

function ShenYuBossData:GetCrossLeftNumInScene(layer, data_type)
	if nil == self.leftmonsterandtreasure[layer] then
		return
	end
	if data_type == 1 then
		return self.leftmonsterandtreasure[layer].left_monster_count
	elseif data_type == 2 then
		return self.leftmonsterandtreasure[layer].left_treasure_crystal_num
	end
end

function ShenYuBossData:GetCrossOtherNextFlushTimestamp(layer, data_type)
	if nil == self.leftmonsterandtreasure[layer] then
		return
	end
	if data_type == 1 then
		return self.leftmonsterandtreasure[layer].monster_next_flush_timestamp
	elseif data_type == 2 then
		return self.leftmonsterandtreasure[layer].treasure_crystal_next_flush_timestamp
	end
end

function ShenYuBossData:SetCrossBossWeary(protocol)
	self.crossboss_weary = protocol.relive_tire_value
	self.crossboss_can_relive_time = protocol.tire_can_relive_time
end

function ShenYuBossData:GetCrossBossCanReliveTime()
	return self.crossboss_can_relive_time
end

function ShenYuBossData:GetCrossBossWeary()
	return self.crossboss_weary
end

function ShenYuBossData:GetCrossBossFlushTimesByBossId(boss_id, scene_id)
	-- local list = self:GetCrossLayerBossBySceneID(scene_id)
	if self.cross_boss_info then
	-- if nil ~= list then
		for k,v in pairs(self.cross_boss_info) do
			if v and v.boss_id == boss_id then
				return v.next_refresh_time
			end
		end
	end
	return 0
end

function ShenYuBossData:GetShenYuBossFallList(boss_id)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo then
		local prof = PlayerData.Instance:GetRoleBaseProf(main_role_vo.prof) or 0
		if self.crossboss_list then
			for k,v in pairs(self.crossboss_list) do
				if v and v.boss_id == boss_id then
					local list = {}
					list = Split(v["drop_item_list" .. prof], "|")
					return list
				end
			end
		end
	end
end

-------------- 跨服幽冥BOSS -------------
function ShenYuBossData:SetCrossYouMingBossPalyerInfo(protocol)
	self.youming_left_ordinary_crystal_gather_times = protocol.left_ordinary_crystal_gather_times
	self.youming_left_can_kill_boss_num = protocol.left_can_kill_boss_num
	self.youming_left_treasure_crystal_gather_times = protocol.left_treasure_crystal_gather_times
	self.youming_concern_flag = {}
	for i = 1, 5 do
		local flag = bit:d2b(protocol.concern_flag[i])
		self.youming_concern_flag[i] = flag
	end
end

function ShenYuBossData:GetCrossYouMingBossIsConcern(layer, boss_index)
	if nil == self.youming_concern_flag then
		return
	end
	local flag_list = self.youming_concern_flag[layer]
	if flag_list and flag_list[33 - boss_index] == 1 then
		return true
	else
		return false
	end
end

function ShenYuBossData:GetYouMingLeftTreasureGatherTimes()
	return self.youming_left_treasure_crystal_gather_times
end

function ShenYuBossData:SetCrossYouMingBossSceneInfo(protocol)
	self.youming_leftmonsterandtreasure[protocol.layer] = {
	left_treasure_crystal_num = protocol.left_treasure_crystal_num,
	left_monster_count = protocol.left_monster_count,
	monster_next_flush_timestamp = protocol.monster_next_flush_timestamp,
	treasure_crystal_next_flush_timestamp = protocol.treasure_crystal_next_flush_timestamp
	}

	local treasure_crystal_gather_id = protocol.treasure_crystal_gather_id
	local monster_next_flush_timestamp = protocol.monster_next_flush_timestamp
	local treasure_crystal_next_flush_timestamp = protocol.treasure_crystal_next_flush_timestamp
	for k, v in pairs(protocol.boss_list) do
		local vo = {}
		vo.boss_id = v.boss_id
		vo.is_exist = v.is_exist
		vo.next_refresh_time = v.next_flush_time
		vo.left_num = 0
		self.cross_youming_boss_info[v.boss_id] = vo
		for i,j in pairs(self.cross_youming_boss_all_list[protocol.layer]) do
			if j.boss_id == v.boss_id then
				j.next_refresh_time = v.next_flush_time
			end
		end
	end

	local treasure_crystal_vo = {}
	treasure_crystal_vo.boss_id = treasure_crystal_gather_id
	treasure_crystal_vo.exist = treasure_crystal_next_flush_timestamp > 0 and 1 or 0
	treasure_crystal_vo.next_refresh_time = treasure_crystal_next_flush_timestamp
	treasure_crystal_vo.left_num = protocol.left_treasure_crystal_num
	self.cross_youming_boss_info[treasure_crystal_gather_id] = treasure_crystal_vo

	local monster_info = self:GetOneMonsterByLayer(protocol.layer)
	local monster_vo = {}
	monster_vo.boss_id = monster_info.boss_id
	monster_vo.exist = monster_next_flush_timestamp > 0 and 1 or 0
	monster_vo.next_refresh_time = monster_next_flush_timestamp
	monster_vo.left_num = protocol.left_monster_count
	self.cross_youming_boss_info[monster_info.boss_id] = monster_vo
end

function ShenYuBossData:SetCrossYouMingBossBossInfo(protocol)
	for i,j in ipairs(protocol.scene_list) do
		self.cross_youming_client_flush_info[j.layer + 1] = {}
		self.cross_youming_client_flush_info[j.layer + 1].left_treasure_crystal_count = j.left_treasure_crystal_count
		self.cross_youming_client_flush_info[j.layer + 1].left_monster_count = j.left_monster_count
		self.cross_youming_client_flush_info[j.layer + 1].boss_list = {}
		for k,v in ipairs(j.boss_list) do
			if v.boss_id ~= 0 then
				local vo = {}
				vo.boss_id = v.boss_id
				vo.next_refresh_time = v.next_flush_time
				self.cross_youming_client_flush_info[j.layer + 1].boss_list[v.boss_id] = vo
			end
		end
	end
end

function ShenYuBossData:GetYouMingCrossAllBoss()
		for i = 1, #self.crosscrytal_lsit do
			self.cross_youming_boss_all_list[i] = {}
		end
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local prof = PlayerData.Instance:GetRoleBaseProf(main_role_vo.prof)
		-- 水晶
		-- for i = 1, #self.cross_youming_crytal_lsit do 
		-- 	local vo = {}
		-- 	vo.layer = self.cross_youming_crytal_lsit[i].layer_index
		-- 	vo.boss_index = 0
		-- 	vo.boss_id = self.cross_youming_crytal_lsit[i].treasure_crystal_gather_id
		-- 	vo.x_pos = self.cross_youming_crytal_lsit[i].entry_x
		-- 	vo.y_pos = self.cross_youming_crytal_lsit[i].entry_y
		-- 	vo.drop_item_list = {}
		-- 	vo.boss_level = 1
		-- 	vo.boss_name = self.cross_youming_crytal_lsit[i].treasure_crystal_name
		-- 	vo.boss_hp = 0
		-- 	vo.boss_atk = 0
		-- 	vo.boss_defen = 0
		-- 	vo.damage_type = 0
		-- 	vo.boss_magdef = 0
		-- 	vo.type = BossData.MonsterType.Gather
		-- 	vo.max_delta_level = 1000
		-- 	vo.scale = 1
		-- 	vo.scene_id = self.cross_youming_crytal_lsit[i].scene_id
		-- 	table.insert(self.cross_youming_boss_all_list[vo.layer], vo)
		-- end
		local boss_data = {}
		for i = 1, #self.cross_youmingboss_list do
			local vo = {}
			vo.layer = self.cross_youmingboss_list[i].layer
			vo.boss_index = self.cross_youmingboss_list[i].boss_index
			vo.boss_id = self.cross_youmingboss_list[i].boss_id
			vo.x_pos = self.cross_youmingboss_list[i].flush_pos_x
			vo.y_pos = self.cross_youmingboss_list[i].flush_pos_y
			vo.drop_item_list = Split(self.cross_youmingboss_list[i]["drop_item_list" .. prof], "|")
			boss_data = self:GetMonsterInfo(self.cross_youmingboss_list[i].boss_id)			
			vo.boss_level = boss_data.level
			vo.boss_name = boss_data.name
			vo.boss_hp = boss_data.hp
			vo.boss_atk = boss_data.gongji
			vo.boss_defen = boss_data.fangyu
			vo.damage_type = boss_data.damage_type
			vo.boss_magdef = boss_data.fa_fangyu
			vo.max_delta_level = self.cross_youmingboss_list[i].max_delta_level
			vo.scene_id = self.cross_youmingboss_list[i].scene_id
			vo.type = BossData.MonsterType.Boss
			vo.scale = self.cross_youmingboss_list[i].scale
			vo.scene_show = self.cross_youmingboss_list[i].scene_show
			if self.cross_youming_client_flush_info[vo.layer] ~= nil and self.cross_youming_client_flush_info[vo.layer].boss_list[vo.boss_id] ~= nil then
				vo.next_refresh_time = self.cross_youming_client_flush_info[vo.layer].boss_list[vo.boss_id].next_refresh_time
			end
			self.cross_youming_boss_list[vo.boss_id] = vo
			table.insert(self.cross_youming_boss_all_list[vo.layer], vo)
		end
	return self.cross_youming_boss_all_list
end

function ShenYuBossData:GetYouMingOneMonsterByLayer(index)
	local vo = {}
	local other = self.cross_youming_other_cfg
	for i = 1, #self.cross_youmingmonster_list do
		if self.cross_youmingmonster_list[i].layer == index then
			vo.layer = self.cross_youmingmonster_list[i].layer
			vo.boss_index = 0
			vo.boss_id = self.cross_youmingmonster_list[i].monster_id
			vo.x_pos = self.cross_youmingmonster_list[i].pos_x
			vo.y_pos = self.cross_youmingmonster_list[i].pos_y
			vo.drop_item_list = {}
			vo.boss_level = 1
			vo.boss_name = other.monster_name
			vo.boss_hp = 0
			vo.boss_atk = 0
			vo.boss_defen = 0
			vo.damage_type = 0
			vo.boss_magdef = 0
			vo.type = BossData.MonsterType.Monster
			vo.max_delta_level = 1000
			vo.scene_id = 0
			vo.scale = 1
			return vo
		end
	end
end

function ShenYuBossData:GetYouMingCrossBossTire()
	local max_tire_value = self.cross_youming_other_cfg.daily_boss_num
	return self.youming_left_can_kill_boss_num, max_tire_value
end

function ShenYuBossData:GetCrossYouMingLayerBossBylayer(index)
	local all_list = self:GetYouMingCrossAllBoss()
	return all_list[index] or {}
end

function ShenYuBossData:GetCrossYouMingLayerBossBySceneID(scene_id)
	local layer = nil
	for k,v in pairs(self.cross_youming_crytal_lsit) do
		if v.scene_id == scene_id then
			layer = v.layer_index
		end
	end
	local list = self:GetCrossYouMingLayerBossBylayer(layer)
	return list
end

function ShenYuBossData:GetCrossYouMingSceneIDByLayer(layer)
	for k,v in pairs(self.cross_youming_crytal_lsit) do
		if v.layer_index == layer then
			return v.scene_id
		end
	end
end

function ShenYuBossData:GetCrossYouMingLayerBySceneID(scene_id)
	for k,v in pairs(self.cross_youming_crytal_lsit) do
		if v.scene_id == scene_id then
			return v.layer_index
		end
	end
end

function ShenYuBossData:GetCrossYouMingBossInfoByBossId(boss_id)
	if next(self.cross_youming_boss_list) == nil then
		self:GetYouMingCrossAllBoss()
	end
	return self.cross_youming_boss_list[boss_id]
end

function ShenYuBossData:GetCrossYouMingBossCanGoLevel()
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	local index = 0
	for k,v in pairs(self.cross_youming_crytal_lsit) do
		if my_level >= v.level_limit then
			index = index + 1
		end
	end
	return index
end

function ShenYuBossData:GetCrossYouMingBossById(boss_id)
	return self.cross_youming_boss_info[boss_id]
end

function ShenYuBossData:GetCrossYouMingLeftNum(layer, data_type)
	if nil == self.cross_youming_client_flush_info[layer] then
		return
	end
	if data_type == 1 then
		return self.cross_youming_client_flush_info[layer].left_monster_count
	elseif data_type == 2 then
		return self.cross_youming_client_flush_info[layer].left_treasure_crystal_count
	end
end

function ShenYuBossData:GetCrossYouMingLeftNumInScene(layer, data_type)
	if nil == self.youming_leftmonsterandtreasure[layer] then
		return
	end
	if data_type == 1 then
		return self.youming_leftmonsterandtreasure[layer].left_monster_count
	elseif data_type == 2 then
		return self.youming_leftmonsterandtreasure[layer].left_treasure_crystal_num
	end
end

function ShenYuBossData:GetCrossYouMingOtherNextFlushTimestamp(layer, data_type)
	if nil == self.youming_leftmonsterandtreasure[layer] then
		return
	end
	if data_type == 1 then
		return self.youming_leftmonsterandtreasure[layer].monster_next_flush_timestamp
	elseif data_type == 2 then
		return self.youming_leftmonsterandtreasure[layer].treasure_crystal_next_flush_timestamp
	end
end

function ShenYuBossData:SetCrossYouMingBossWeary(protocol)
	self.cross_youmingboss_weary = protocol.relive_tire_value
	self.cross_youmingboss_can_relive_time = protocol.tire_can_relive_time
end

function ShenYuBossData:GetCrossYouMingBossCanReliveTime()
	return self.cross_youmingboss_can_relive_time
end

function ShenYuBossData:GetCrossYouMingBossWeary()
	return self.cross_youmingboss_weary
end

function ShenYuBossData:GetMonsterInfo(boss_id)
	return self.monster_cfg[boss_id]
end

function ShenYuBossData:GetCrossYouMingBossFlushTimesByBossId(boss_id, scene_id)
	-- local list = self:GetCrossYouMingLayerBossBySceneID(scene_id)
	-- if nil ~= list then
	if self.cross_youming_boss_info then
		for k,v in pairs(self.self.cross_youming_boss_info) do
			if v.boss_id == boss_id then
				return v.next_refresh_time
			end
		end
	end
	return 0
end

function ShenYuBossData:GetYouMingBossFallList(boss_id)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo then
		local prof = PlayerData.Instance:GetRoleBaseProf(main_role_vo.prof) or 0
		if self.cross_youmingboss_list then
			for k,v in pairs(self.cross_youmingboss_list) do
				if v and v.boss_id == boss_id then
					local list = {}
					list = Split(v["drop_item_list" .. prof], "|")
					return list
				end
			end
		end
	end
end

-- 保存进入时选择的boss
function ShenYuBossData:SetSelectBoss(select_scene_id, select_boss_id)
	self.select_scene_id = select_scene_id
	self.select_boss_id = select_boss_id
end

function ShenYuBossData:GetSelectBoss()
	return self.select_boss_id
end