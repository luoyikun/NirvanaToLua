Npc = Npc or BaseClass(SceneObj)

function Npc:__init(vo)
	self.obj_type = SceneObjType.Npc
	self.draw_obj:SetObjType(self.obj_type)
	self.draw_obj:SetIsDisableAllAttachEffects(false)

	self.last_task_index = -1
	self.select_effect = nil

	self.task_change = GlobalEventSystem:Bind(OtherEventType.TASK_CHANGE,
		BindTool.Bind(self.OnTaskChange, self))
	self.is_active_follow_ui_root = true

	-- self.is_group_npc = false			-- 是否群聊npc
	self.is_speak = false				-- 是否说话
	self.group_chat_id = -1				-- 群聊组ID
	self.npc_to_role_distance = -1		-- NPC到人距离
end

function Npc:__delete()
	-- self.is_group_npc = false
	self.is_speak = false
	self.group_chat_id = -1
	self.npc_to_role_distance = -1

	if self.role_pos_change then
		GlobalEventSystem:UnBind(self.role_pos_change)
		self.role_pos_change = nil
	end

	if nil ~= self.select_effect then
		self.select_effect:DeleteMe()
		self.select_effect = nil
	end
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	if self.bobble_timer_quest then
		GlobalTimerQuest:CancelQuest(self.bobble_timer_quest)
		self.bobble_timer_quest = nil
	end
	if self.task_change then
		GlobalEventSystem:UnBind(self.task_change)
		self.task_change = nil
	end
	if self.task_effect then
		ResPoolMgr:Release(self.task_effect)
		self.task_effect = nil
	end
end

function Npc:CreateShadow()
	SceneObj.CreateShadow(self)
end

function Npc:RegisterShadowUpdate()
	SceneObj.RegisterShadowUpdate(self)
end

function Npc:InitInfo()
	SceneObj.InitInfo(self)
	local npc_config = ConfigManager.Instance:GetAutoConfig("npc_auto").npc_list[self.vo.npc_id]
	if nil == npc_config then
		print_log("npc_config not find npc_id:" .. self.vo.npc_id)
		return
	end

	self.npc_id = self.vo.npc_id
	self.vo.name = npc_config.show_name
	self.res_id = npc_config.resid
	self.head_id = npc_config.headid
	self.obj_scale = npc_config.scale
	self.role_res = npc_config.role_res or 0
	self.weapen_res = npc_config.weapen_res or 0
	self.mount_res = npc_config.mount_res or 0
	self.wing_res = npc_config.wing_res or 0
	self.halo_res = npc_config.halo_res or 0
	self.monster_id = npc_config.monster_res
	if not self.monster_id or self.monster_id == "" then
		self.monster_id = 0
	end

	-- 随机取出权重数据
	self.group_chat_id = self:RadomBubbleTxt()
	if self.group_chat_id <= 0 then
		return
	end
	local chat_content_cfg = SceneData.Instance:GetBubbleChatContentCfgByGroup(self.group_chat_id)
	if chat_content_cfg then
		local scene_id = Scene.Instance:GetSceneId()
		for k, v in pairs(chat_content_cfg) do
			if scene_id == v.scene_id and self.npc_id == v.npc_id then
				if v.distance ~= "" and v.distance > 0 then
					self.npc_to_role_distance = v.distance
					-- 监听玩家移动
					if nil == self.role_pos_change then
						self.role_pos_change = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_POS_CHANGE, 
							BindTool.Bind1(self.OnMainRolePosChangeHandler, self))
					end
				end
				break
			end
		end
	end
end

function Npc:RadomBubbleTxt()
	local chat_limit = SceneData.Instance:GetBubbleChatLimitCfgByNpcId(self.npc_id)
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

function Npc:InitShow()
	SceneObj.InitShow(self)

	self.load_priority = 10
	if self.obj_scale ~= nil then
		local transform = self.draw_obj:GetRoot().transform
		transform.localScale = Vector3(self.obj_scale, self.obj_scale, self.obj_scale)
	end

	if self.role_res <= 0 then
		if self.monster_id <= 0 then
			self:InitModel(ResPath.GetNpcModel(self.res_id))
		else
			self:InitModel(ResPath.GetMonsterModel(self.monster_id))
		end
	else
		self:ChangeModel(SceneObjPart.Main, ResPath.GetRoleModel(self.role_res))
		if self.weapen_res > 0 then
			self:ChangeModel(SceneObjPart.Weapon, ResPath.GetWeaponModel(self.weapen_res))
			-- 如果是枪手模型
			if math.floor(self.role_res / 1000) % 1000 == 3 then
				self:ChangeModel(SceneObjPart.Weapon2, ResPath.GetWeaponModel(self.weapen_res + 1))
			end
		end
		if self.wing_res > 0 then
			self:ChangeModel(SceneObjPart.Wing, ResPath.GetWingModel(self.wing_res))
		end
		if self.halo_res > 0 then
			self:ChangeModel(SceneObjPart.Halo, ResPath.GetHaloModel(self.halo_res))
		end
		if self.mount_res > 0 then
			self:ChangeModel(SceneObjPart.Mount, ResPath.GetMountModel(self.mount_res))
		end
	end
	self.draw_obj:Rotate(0, self.vo.rotation_y or 0, 0)
end

function Npc:InitModel(bundle, asset)
    if ResMgr:IsBundleMode() and not ResMgr:IsVersionCached(bundle) then
		self:ChangeModel(SceneObjPart.Main, ResPath.GetNpcModel(4026001))

		DownloadHelper.DownloadBundle(bundle, 3, function(ret)
			if ret then
				self:ChangeModel(SceneObjPart.Main, bundle, asset)
			end
		end)
	else
		self:ChangeModel(SceneObjPart.Main, bundle, asset)
	end
end

function Npc:OnEnterScene()
	SceneObj.OnEnterScene(self)
	self:GetFollowUi()
	self:PlayAction()
	self:UpdateTitle()
	-- self:UpdateTaskEffect()

	self:UpdataBubble()

	-- self:NpcGroupChat()
end

function Npc:HideFollowUi()
end

function Npc:IsNpc()
	return true
end

function Npc:GetObjKey()
	return self.vo.npc_id
end

function Npc:GetNpcId()
	return self.vo.npc_id
end

function Npc:GetNpcHead()
	return self.head_id
end

function Npc:OnClick()
	SceneObj.OnClick(self)
	if nil == self.select_effect then
		self.select_effect = self.select_effect or AllocAsyncLoader(self, "select_effect_loader")
		self.select_effect:SetParent(self.draw_obj:GetRoot().transform)
		self.select_effect:SetIsUseObjPool(true)
		local bundle, asset = ResPath.GetSelectObjEffect2("lvse")
		self.select_effect:Load(bundle, asset)
		self.select_effect:SetLocalScale(Vector3(1.5, 1.5, 1.5))
	end
	self.select_effect:SetActive(true)
end

function Npc:CancelSelect()
	-- SceneObj.CancelSelect(self)
	self.is_select = false
	if nil ~= self.select_effect then
		self.select_effect:SetActive(false)
	end
end

function Npc:PlayAction()
	local draw_obj = self:GetDrawObj()
	if draw_obj then
		local part = draw_obj:GetPart(SceneObjPart.Main)
		if part then
			part:SetTrigger("Action")
			self.time_quest = GlobalTimerQuest:AddDelayTimer(function() self:PlayAction() end, 10)
		end
	end
end

function Npc:FlushTaskEffect(enable, bundle, asset)
	if self.task_effect then
		ResPoolMgr:Release(self.task_effect)
		self.task_effect = nil
	end
	if enable then
		ResPoolMgr:GetEffectAsync(bundle, asset, function(obj)
			if not obj then return end
			local draw_obj = self:GetDrawObj()
			if not draw_obj then
				ResPoolMgr:Release(obj)
				return
			end
			local parent_transform = draw_obj:GetAttachPoint(AttachPoint.UI)
			if not parent_transform then
				ResPoolMgr:Release(obj)
				return
			end

			obj.transform:SetParent(parent_transform, false)
			self.task_effect = obj
		end)
	end
end

function Npc:ChangeTaskEffect(index)
	if self.last_task_index ~= index then
		self.last_task_index = index
		if index >= 0 then
			local bubble, asset = ResPath.GetTaskNpcEffect(index)
			self:FlushTaskEffect(true, bubble, asset)
		else
			self:FlushTaskEffect(false)
		end
	end
end

function Npc:UpdateTaskEffect()
	local task_cfg = TaskData.Instance:GetNpcOneExitsTask(self:GetNpcId())
	if task_cfg then
		local status = TaskData.Instance:GetTaskStatus(task_cfg.task_id)
		if status == TASK_STATUS.CAN_ACCEPT then
			local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
			if main_role_vo then
				local level = main_role_vo.level
				if task_cfg.min_level > level then
					status = 0
				end
			end
		end
		self:ChangeTaskEffect(status)
	else
		self:ChangeTaskEffect(-1)
	end
end

function Npc:ChangeSpecailTitle(index)
	if self.last_task_index ~= index then
		self.last_task_index = index
		if index >= 0 then
			local str = "task_" .. index
			local bundle, asset = ResPath.GetTitleModel(str)
			self:GetFollowUi():ChangeTitle(bundle, asset, 0, 60)
		else
			self:GetFollowUi():ChangeTitle(nil)
		end
	end
end

function Npc:UpdateTitle()
	local task_cfg = TaskData.Instance:GetNpcOneExitsTask(self:GetNpcId())
	if task_cfg then
		local status = TaskData.Instance:GetTaskStatus(task_cfg.task_id)
		if status == TASK_STATUS.CAN_ACCEPT then
			local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
			if main_role_vo then
				local level = main_role_vo.level
				if task_cfg.min_level > level then
					status = 0
				end
			end
		end
		self:ChangeSpecailTitle(status)
	else
		self:ChangeSpecailTitle(-1)
	end
end

function Npc:OnTaskChange()
	self:UpdateTitle()
	-- self:UpdateTaskEffect()
end

function Npc:GetBubbletext()
	local bubble_cfg = SceneData.Instance:GetBubbleListCfg().bubble_npc_list
	for k,v in pairs(bubble_cfg) do
		if v.npc_id == self:GetNpcId() then
			return v.bubble_npc_text
		end
	end
end

function Npc:UpdataBubble()
	if TaskData.Instance:GetNpcOneExitsTask(self:GetNpcId()) then return end
	local rand_num = math.random(1, 10)
	local npc_odds = SceneData.Instance:GetBubbleListCfg().other[1].npc_odds
	if rand_num * 0.1 <= npc_odds then
		local text = self:GetBubbletext()
		if nil ~= text then
			self:GetFollowUi():ChangeBubble(text, 5)
		end
	end
end

function Npc:IsWalkNpc()
	return false
end

-- 玩家角色移动处理函数
function Npc:OnMainRolePosChangeHandler(x, y)
	local dis = self:RoleDistance(x, y)
	local is_dis = dis <= self.npc_to_role_distance
	if is_dis then
		self:NpcGroupChat()
	end
end

function Npc:RoleDistance(end_x, end_y)
	-- 这里不开平方，避免一些运算
	local dis = GameMath.GetDistance(self.logic_pos.x, self.logic_pos.y, end_x, end_y, false)
	return dis
end

function Npc:NpcGroupChat()
	-- 进来后移除监听玩家移动的
	if self.role_pos_change then
		GlobalEventSystem:UnBind(self.role_pos_change)
		self.role_pos_change = nil
	end

	local group_chat_list = {}
	local chat_content_cfg = SceneData.Instance:GetBubbleChatContentCfgByGroup(self.group_chat_id)
	if chat_content_cfg then
		local scene_id = Scene.Instance:GetSceneId()
		for k, v in pairs(chat_content_cfg) do
			if scene_id == v.scene_id then
				table.insert(group_chat_list, v)
			end
		end
	end
	SortTools.SortAsc(group_chat_list, "start_time")

	GlobalEventSystem:Fire(SceneChatEventType.NPC_GROUP_CHAT, self.group_chat_id, group_chat_list)
end

function Npc:NpcSpeakChatContent(text, time)
	if nil == text or "" == text then
		return
	end
	time = time or 5
	-- print_error("npc>>>>>", self.vo.name, text, time)
	self:GetFollowUi():ChangeBubble(text, time)
end
