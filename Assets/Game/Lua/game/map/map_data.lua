MapData = MapData or BaseClass()

MapData.WORLDCFG = {
	[1] = 101,							-- 苍梧山
	[2] = 107,							-- 幻溟界
	[3] = 103,							-- 祖龙神都
	[4] = 104,							-- 极北冰原
	[5] = 105,							-- 天晴之海
	[6] = 108,							-- 璇梦归尘
	[7] = 106,							-- 火之狱
	[8] = 109,							-- 天枢神域
	[9] = 102,							-- 太一仙径
	[10] = 8002,							-- 太一仙径
}

MapData.SCENEID = {
	gongchengzhan = 1002,							-- 攻城战
}

function MapData:__init()
	if MapData.Instance then
		print_error("[MapData] Attempt to create singleton twice!")
		return
	end
	MapData.Instance = self

	self.map_config = {}

	self.info_table = {}
	self.icon_table = {}
	self.boss_info_list = {}
	self.wander_boss_all = {}
end

function MapData:__delete()
	MapData.Instance = nil
end

function MapData:GetMapConfig(map_id)
	if not self.map_config[map_id] then
		self.map_config[map_id] = ConfigManager.Instance:GetSceneConfig(map_id)
		if not self.map_config[map_id] then
			print_error("Can't find scene_" .. map_id .. "config")
			return
		end
	end
	return self.map_config[map_id]
end

function MapData:GetInfoByType(info_type)
	if not info_type then
		return self.info_table
	else
		local temp_table = {}
		local count = 0
		for _, v in pairs(self.info_table) do
			if (v.obj_type == info_type) then
				count = count + 1
				temp_table[count] = v
			end
		end
		return temp_table, count
	end
end

function MapData:GetInfoByIndex(index)
	if not index then
		return self.info_table
	else
		return self.info_table[index]
	end
end

function MapData:SetInfo(list)
	self:ClearInfo()
	self.info_table = list
	local count = 0
	for _, v in pairs(self.info_table) do
		count = count + 1
	end
end

function MapData:ClearInfo()
	if self.info_table then
		for _, v in pairs(self.info_table) do
			ResMgr:Destroy(v.obj)
		end
		self.info_table = {}
	end
end

function MapData:SetIcon(list)
	self:ClearIcon()
	self.icon_table = list
end

function MapData:ClearIcon()
	if self.icon_table then
		for _, v in pairs(self.icon_table) do
			ResMgr:Destroy(v.obj)
		end
		self.icon_table = {}
	end
end

function MapData:GetNpcIcon()
	local temp_table = {}
	local count = 0
	for _, v in pairs(self.icon_table) do
		if v.npc_id then
			count = count + 1
			temp_table[count] = v
		end
	end
	return temp_table, count
end

function MapData:GetMonster(monster_id)
	local monster_info = ConfigManager.Instance:GetAutoConfig("guaji_pos_auto").map_info
	for k,v in pairs(monster_info) do
		if monster_id == v.monster_id then
			return v
		end
	end
	return nil
end

-- 小飞鞋道具ID
function MapData:GetFlyShoeId()
	return 27583
end

function MapData:GetBossMiniMapCfg()
	if self.boss_map_cfg == nil then
		self.boss_map_cfg = ConfigManager.Instance:GetAutoConfig("boss_minimap_auto").boss_info
	end
	return self.boss_map_cfg
end

function MapData:GetBossMapCfg(scene_id)
	local boss_cfg = self:GetBossMiniMapCfg()
	local boss_map_cfg = {}

	for k,v in pairs(boss_cfg) do
		if scene_id == v.scene_id then
			table.insert(boss_map_cfg, v)
		end
	end
	return boss_map_cfg
end

function MapData:SetYunYouBossInfo(protocol)
	self.nex_refresh_time = protocol.nex_refresh_time
	self.scene_id = protocol.scene_id
	self.boss_count = protocol.boss_count
	self.boss_info_list = protocol.boss_info_list
end

function MapData:SetAllYunYouBossNum(protocol)
	self.wander_boss_all = protocol.scene_info_list
end

function MapData:GetBossPosCounInfo()
	return self.boss_info_list, self.boss_count or 0
end

function MapData:IsYunYouShowTime()
	local scene_id = Scene.Instance:GetSceneId()
	local data_list = ConfigManager.Instance:GetAutoConfig("bossfamily_auto").yunyou_boss
	for k,v in pairs(data_list) do
		if scene_id == v.scene_id then
			return true
		end
	end
	return false
end


function MapData:GetYunYonFlushInfo()
	return self.nex_refresh_time or 0
end

function MapData:GetMapWanderAllInfocfg(scene_id)
	local data_list = self.wander_boss_all
	for k,v in pairs(data_list) do
		if v.scene_id == scene_id then
			return v.boss_count
		end
	end
	return 0
end