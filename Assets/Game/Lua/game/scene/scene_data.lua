SceneData = SceneData or BaseClass()
local M = SceneData

local SHIELD_NUM = 10		-- 玩家数量达到设置的数量后隐藏其他玩家名字

function M:__init()
	if M.Instance then
		print_error("[SceneData]:Attempt to create singleton twice!")
	end
	M.Instance = self

	self.show_role_list = {}		-- 显示玩家列表
	self.scene_role_num = 0
	self.is_shield_role_followandshadow = false
	self.check_role_num_time = 0	-- 检测玩家时间
end

function M:__delete()
	M.Instance = nil

	self.show_role_list = {}
	self.scene_role_num = 0
	self.is_shield_role_followandshadow = false
end

function M:TargetSelectIsTask(value)
	return value == SceneTargetSelectType.TASK
end

function M:TargetSelectIsScene(value)
	return value == SceneTargetSelectType.SCENE
end

function M:TargetSelectIsSelect(value)
	return value == SceneTargetSelectType.SELECT
end

function M:IsSceneRolelistShow()
	return #self.show_role_list >= SHIELD_NUM
end

function M:IsSceneRoleShield()
	return self.scene_role_num > SHIELD_NUM
end

function M:GetSceneRoleNum()
	return self.scene_role_num
end

function M:AddSceneRoleNum()
	self.scene_role_num = self.scene_role_num + 1
end

function M:RemoveSceneRoleNum()
	self.scene_role_num = self.scene_role_num - 1
end

-- 检查场景角色隐藏follow和影子
function M:CheckRoleNumShield()
	if self.check_role_num_time > Status.NowTime then
		return
	end
	self.check_role_num_time = Status.NowTime + 1

	local role_list = Scene.Instance:GetRoleList()
	for k, v in pairs(role_list) do
		local old_shield = v.follow_and_shadow_shield
		if not self:IsSceneRolelistShow() then
			if v.follow_and_shadow_shield then
				for k2, v2 in pairs(self.show_role_list) do
					if v2 == v.vo.role_id then
						self.show_role_list[#self.show_role_list + 1] = v.vo.role_id
						v.follow_and_shadow_shield = false
						break
					end
				end
			end
		else
			v.follow_and_shadow_shield = true
			for k2, v2 in pairs(self.show_role_list) do
				if v2 == v.vo.role_id then
					v.follow_and_shadow_shield = false
					break
				end
			end
		end
		if old_shield ~= v.follow_and_shadow_shield then
			local is_shield = v.follow_and_shadow_shield
			v.is_shield_role_shadow = is_shield
			v:UpdateShadowByQuality()
			local follow_ui = v:GetFollowUi()
			if follow_ui then
				follow_ui:IsRoleFollowHide(is_shield)
				if is_shield then
					follow_ui:Hide()
				else
					follow_ui:Show()
				end
			end
		end
	end
end

function M:ShowAllSceneRoleShield()
	local role_list = Scene.Instance:GetRoleList()
	self.show_role_list = {}
	for k ,v in pairs(role_list) do
		if not self:IsSceneRolelistShow() then
			self.show_role_list[#self.show_role_list + 1] = v.vo.role_id
		end
		v.follow_and_shadow_shield = false

		v.is_shield_role_shadow = false
		v:UpdateShadowByQuality()
		local follow_ui = v:GetFollowUi()
		if follow_ui then
			follow_ui:IsRoleFollowHide(false)
			follow_ui:Show()
		end
	end
end

function M:AddSceneRoleShield(role_obj)
	if role_obj.vo.role_id and role_obj.vo.role_id <= 0 then
		return
	end
	self:AddSceneRoleNum()
	if not self:IsSceneRolelistShow() then
		self.show_role_list[#self.show_role_list + 1] = role_obj.vo.role_id
		role_obj.follow_and_shadow_shield = false

		role_obj.is_shield_role_shadow = false
		role_obj:UpdateShadowByQuality()
		local follow_ui = role_obj:GetFollowUi()
		if follow_ui then
			follow_ui:IsRoleFollowHide(false)
			follow_ui:Show()
		end
	else
		role_obj.follow_and_shadow_shield = true
		self:CheckRoleNumShield()
	end
end

function M:RecoverSceneRoleShield(role_obj)
	if role_obj.vo.role_id and role_obj.vo.role_id <= 0 then
		return
	end
	local old_is_scene_role_shield = self:IsSceneRoleShield()
	self:RemoveSceneRoleNum()
	local new_is_scene_role_shield = self:IsSceneRoleShield()

	if self:IsSceneRolelistShow() then
		local key = 0
		for k, v in pairs(self.show_role_list) do
			if role_obj.vo.role_id == v then
				key = k
				break
			end
		end
		if key > 0 then
			table.remove(self.show_role_list, key)
			self:CheckRoleNumShield()
		end
	end

	if old_is_scene_role_shield and false == new_is_scene_role_shield then
		self:ShowAllSceneRoleShield()
	end
end

function M:IsShieldRoleFollowAndShadow(is_shield)
	if nil == is_shield then
		return self.is_shield_role_followandshadow
	end
	self.is_shield_role_followandshadow = is_shield
end

-- 获取副本进入的第一个视角
function M:GetFbSceneCfg(scene_id)
	if nil == self.fb_scene_moveview_cfg then
		local fb_config = ConfigManager.Instance:GetAutoConfig("fb_scene_config_auto")
		self.fb_scene_moveview_cfg = ListToMap(fb_config.move_view, "scene_id")
	end

	if self.fb_scene_moveview_cfg[scene_id] then
		return self.fb_scene_moveview_cfg[scene_id]
	end
end

function M:GetBubbleListCfg()
	if nil == self.bubble_list_cfg then
		self.bubble_list_cfg = ConfigManager.Instance:GetAutoConfig("bubble_list_auto")
	end
	return self.bubble_list_cfg
end

-- 获取NPC群聊配置
function M:GetBubbleChatContentCfgByGroup(group_id)
	if nil == self.bubble_chat_content then
		self.bubble_chat_content = ListToMapList(self:GetBubbleListCfg().chat_content, "group_id")
	end
	if self.bubble_chat_content[group_id] then
		return self.bubble_chat_content[group_id]
	end
end

-- 获取NPC群聊限制配置
function M:GetBubbleChatLimitCfgByNpcId(npc_id)
	if nil == self.bubble_chat_limit then
		self.bubble_chat_limit = ListToMapList(self:GetBubbleListCfg().chat_limit, "npc_id")
	end
	if self.bubble_chat_limit[npc_id] then
		return self.bubble_chat_limit[npc_id]
	end
end

-----------------------------------------------------------
function M:GetMapBlockAutoCfg()
	if not self.map_block_cfg_auto then
		self.map_block_cfg_auto = ConfigManager.Instance:GetAutoConfig("map_block_cfg_auto")
	end
	return self.map_block_cfg_auto
end

function M:GetMapBlockOtherCfg(scene_id)
	if not self.map_block_other_cfg then
		self.map_block_other_cfg = self:GetMapBlockAutoCfg().other
	end
	if self.map_block_other_cfg[scene_id] then
		return self.map_block_other_cfg[scene_id]
	end
end

function M:GetMapBlockBubbleCfg()
	if not self.map_block_bubble_cfg then
		self.map_block_bubble_cfg = self:GetMapBlockAutoCfg().bubble
	end
	if self.map_block_bubble_cfg[1] then
		return self.map_block_bubble_cfg[1]
	end
end

-- 获取地图阻挡配置
function M:GetMapBlockCfg(id)
	if nil == id or "" == id then
		return
	end
	local map_block_cfg = self:GetMapBlockAutoCfg()
	return map_block_cfg["actid_" .. id]
end

-- 获取地图阻挡区域内玩家群聊限制配置
function M:GetMapBlockBubbleChatLimit(scene_id)
	if nil == self.map_block_bubble_chat_limit then
		self.map_block_bubble_chat_limit = ListToMapList(self:GetMapBlockAutoCfg().bubble_probability, "scene_id")
	end
	if self.map_block_bubble_chat_limit[scene_id] then
		return self.map_block_bubble_chat_limit[scene_id]
	end
end

-- 获取地图阻挡区域内玩家群聊限制配置
function M:GetMapBlockBubbleChatLimitGroupId(scene_id)
	local chat_limit = self:GetMapBlockBubbleChatLimit(scene_id)
	if nil == chat_limit then
		return -1
	end
	math.randomseed(os.time())
	local rand_num = math.random(1, 10000)
	local range = 0
	for k, v in pairs(chat_limit) do
		range = range + v.probability
		if rand_num <= range then
			return v.group_id
		end
	end
	return -1 
end

-- 获取NPC群聊配置
function M:GetMapBlockBubbleChatContent(group_id)
	if nil == self.map_block_bubble_chat_content then
		self.map_block_bubble_chat_content = ListToMapList(self:GetMapBlockAutoCfg().bubble_content, "group_id")
	end
	if self.map_block_bubble_chat_content[group_id] then
		return self.map_block_bubble_chat_content[group_id]
	end
end