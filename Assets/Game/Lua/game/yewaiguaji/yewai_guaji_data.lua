YewaiGuajiData =YewaiGuajiData or BaseClass()

function YewaiGuajiData:__init()
	if YewaiGuajiData.Instance then
		print_error("YewaiGuajiData] Attemp to create a singleton twice !")
	end
	YewaiGuajiData.Instance = self

	self.guaji_info_cfg = ConfigManager.Instance:GetAutoConfig("guaji_pos_auto").pos_list_new
	self.fb_scene_config = ConfigManager.Instance:GetAutoConfig("guaji_pos_auto").show_scene
	self.guaji_list = {}
	self:GetGuaJiPosList()
end

function YewaiGuajiData:__delete()
	self.guaji_info_cfg = nil
	self.fb_scene_config = nil
	if YewaiGuajiData.Instance ~= nil then
		YewaiGuajiData.Instance = nil
	end
end

-- 获取显示的挂机地图列表
function YewaiGuajiData:GetGuaJiPosList()
	local guaji_list_temp = {}
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	for k, v in ipairs(self.guaji_info_cfg) do
		table.insert(guaji_list_temp,v)
		if(my_level < v.level_limit and #guaji_list_temp > 2) then
			break
		end
	end
	self.guaji_list = {}
	local temp_length = #guaji_list_temp
	table.insert(self.guaji_list, guaji_list_temp[temp_length - 2])
	table.insert(self.guaji_list, guaji_list_temp[temp_length - 1])
	table.insert(self.guaji_list, guaji_list_temp[temp_length])
	return self.guaji_list
end

-- 获取地图等级限制
function YewaiGuajiData:GetMapLevelLimit(index)
	return self.guaji_list[index].level_limit
end

--获取怪物配置索引
function YewaiGuajiData:GetGuaiwuIndex()
	local guaiwu_temp = 0
	local guaji_item = self:GetCurGuajiList()
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	for i = 1, 8 do
		if(guaji_item["level_" .. i] == "") then
			guaiwu_temp = i - 1
			break
		end

		if my_level >= guaji_item["level_" .. i] then
			guaiwu_temp = i
		else
			guaiwu_temp = i - 1
			break
		end
	end

	if guaiwu_temp == 0 then
		guaiwu_temp = 1
	end
	return guaiwu_temp
end

-- 获取场景名字
function YewaiGuajiData:GetGuaJiSceneName(index, guaiwu_temp)
	local guaji_item = self.guaji_list[index]
	local scene_id = guaji_item["scene_id_" .. guaiwu_temp]
	return ConfigManager.Instance:GetSceneConfig(scene_id).name
end

--获取挂机地图位置
function YewaiGuajiData:GetGuajiPos(guaiwu_temp)
	local guaji_pos = {}
	local guaji_item = self:GetCurGuajiList()
	table.insert(guaji_pos,guaji_item["scene_id_" .. guaiwu_temp])
	table.insert(guaji_pos,guaji_item["x_" .. guaiwu_temp])
	table.insert(guaji_pos,guaji_item["y_" .. guaiwu_temp])

	return guaji_pos
end

-- 获取当前挂机列表
function YewaiGuajiData:GetCurGuajiList()
	local guaji_temp = self.guaji_info_cfg[1]
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	for k, v in ipairs(self.guaji_info_cfg) do
		if my_level >= v.min_level and my_level <= v.max_level then
			guaji_temp = v
			break
		end
	end
	return guaji_temp
end

--获取挂机标准经验
function YewaiGuajiData:GetStanderdExp(index, guaiwu_temp)
	local guaji_item = self.guaji_list[index]
	return guaji_item["standard_exp_" .. guaiwu_temp]
end

--获取挂机装备数量
function YewaiGuajiData:GetEquipNum(index, guaiwu_temp)
	local guaji_item = self.guaji_list[index]
	return guaji_item["blue_num_"..guaiwu_temp] , guaji_item["purple_num_" .. guaiwu_temp]
end

--获取挂机装备阶数
function YewaiGuajiData:GetEquipmentLevel(index, guaiwu_temp)
	local guaji_item = self.guaji_list[index]
	return guaji_item["equip_level_" .. guaiwu_temp]
end

function YewaiGuajiData:GetMap(index)
	return self.guaji_list[index].map_res
end

function YewaiGuajiData:GetFlagShowIcon()
	local current_scene = GameVoManager.Instance:GetMainRoleVo().scene_id
	local flag = false
	for i, v in ipairs(self.fb_scene_config) do
		if v.scene_id == current_scene then
			flag = true
		end
	end
	return flag
end

function YewaiGuajiData:IsGuajiScene(scene_id)
	scene_id = scene_id or Scene.Instance:GetSceneId()
	for k, v in pairs(self.guaji_info_cfg) do
		if v.scene_id_1 == scene_id then
			return true
		end
	end
	return false
end