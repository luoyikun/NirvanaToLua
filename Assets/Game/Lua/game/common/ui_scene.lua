UIScene = {
	ui_scene_obj = nil,
	role_model = nil,
	actor_trigger = nil,
	actor_ctrl = nil,
	res_info = nil,
	is_play_action = false,
	is_not_create_role = true,
	rotate_cache = nil,
	scene_target = nil,
	scene_effect_obj = nil,
	bundle_list = {},
	asset_list = {},
	node_list = {},
	__res_loaders = {},
}

local GameRoot = GameObject.Find("GameRoot").transform
local UiSceneLayer = UnityEngine.LayerMask.NameToLayer("UIScene")
local UiSceneBgLayer = UnityEngine.LayerMask.NameToLayer("UISceneBg")
local UILayerMask = bit:_lshift(1, UnityEngine.LayerMask.NameToLayer("UI"))
--清除
function UIScene:DeleteMe()
	self:SetActionEnable(false)
	self:CancelMountMoveTimeQuest()
	self:RemoveActionDelayTimer()
	self:DeleteModels()
	self.bundle_list = {}
	self.asset_list = {}
	self.node_list = {}

	ResMgr:Destroy(self.ui_scene_obj)
	for _, v in pairs(self.__res_loaders) do
		v:DeleteMe()
	end
end

function UIScene:DeleteModels()
	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	if self.actor_trigger then
		self.actor_trigger:DeleteMe()
		self.actor_trigger = nil
	end

	if self.actor_ctrl then
		self.actor_ctrl:DeleteMe()
		self.actor_ctrl = nil
	end

	if self.apperance_change then
		GlobalEventSystem:UnBind(self.apperance_change)
		self.apperance_change = nil
	end

	if self.scene_effect_obj then
		self.scene_effect_obj:DeleteMe()
		self.scene_effect_obj = nil
	end
end

function UIScene:ChangeScene(view, call_back)
	if view and not view:IsRendering() then
		return
	end

	if nil == view then
		self:DeleteMe()
		return
	end

	self.load_call_back = call_back

	if not IsNil(self.ui_scene_obj) then
		self:DeleteModels()
		self:OnLoadSceneComplete()
		return
	end

	self.ui_scene_obj = ResPoolMgr:TryGetGameObject("uis/views/commonwidgets_prefab", "UIScene")
	self.ui_scene_obj.transform:SetParent(GameRoot, false)
	self.camera_list = {}
	local camera_list = self.ui_scene_obj:GetComponentsInChildren(typeof(UnityEngine.Camera))
	for i = 0, camera_list.Length - 1 do
		local camera = camera_list[i]
		if camera.cullingMask ~= UILayerMask then
			table.insert(self.camera_list, camera)
		end
	end
	local name_table = self.ui_scene_obj:GetComponent(typeof(UINameTable))
	self.node_list = U3DNodeList(name_table, self)

	self:OnLoadSceneComplete()
end

function UIScene:SetUISceneLoadCallBack(call_back)
	self.load_success_call_back = call_back
end

function UIScene:SetModelLoadCallBack(call_back)
	self.model_load_call_back = call_back
end

function UIScene:OnLoadSceneComplete()
	self:CreateModel()
	if self.load_call_back then
		self.load_call_back()
		self.load_call_back = nil
	end
	if nil ~= self.load_success_call_back then
		self.load_success_call_back()
		self.load_success_call_back = nil
	end
end

function UIScene:SetCameraTransform(transform, view_port_offset)
	if nil == self.camera_list then
		return
	end

	for i, camera in ipairs(self.camera_list) do
		if camera and not IsNil(camera) then
			camera.enabled = true
			camera.transform.localPosition = transform.position
			camera.transform.localRotation = transform.rotation

			if view_port_offset then
				local offset_x = view_port_offset.x or 0
				local offset_y = view_port_offset.y or 0
				camera.rect = UnityEngine.Rect.New(offset_x, offset_y, 1, 1)
			else
				camera.rect = UnityEngine.Rect.New(0, 0, 1, 1)
			end
		end
	end
end

function UIScene:CreateModel()
	if nil ~= self.role_model then
		self.role_model:DeleteMe()
	end
	self.role_model = RoleModel.New()
	
	self.actor_trigger = ActorTrigger.New()
	self.actor_trigger:SetMainRole(true)
	self.actor_ctrl = ActorCtrl.New(self.actor_trigger)

	self.role_model:SetIsInUiScene(true)
	self:SetModelAsset()
end

-- 清空模型、场景特效、调用这个调用这个调用这个
function UIScene:DeleteModel()
	if self.role_model then
		self.role_model:ClearFoot()
	end

	if self.role_model then
		for k, v in pairs(SceneObjPart) do
			local part = self.role_model.draw_obj:GetPart(v)
			if part then
				part:RemoveModel()
			end
		end
	end

	if self.scene_effect_obj then
		local part = self.scene_effect_obj:GetPart(SceneObjPart.Main)
		part:RemoveModel()
	end

	self:SetCameraActive(false)
end

function UIScene:SetCameraActive(is_active)
	if self.camera_active == is_active then
		return
	end
	for i, camera in ipairs(self.camera_list) do
		if camera and not IsNil(camera) then
			camera.gameObject:SetActive(is_active)
			camera.enabled = true
		end
	end
	self.camera_active = is_active
end

function UIScene:SetModelAsset()
	if nil == self.role_model then
		return
	end

	if self.res_info then
		self.role_model:SetLoadComplete(BindTool.Bind(self._OnModelLoaded, self))

		if self.res_info.is_goddess then
			self.role_model:SetGoddessModelResInfo(self.res_info)
		else
			local res_info_t = self.res_info_t or {}
			self.role_model:SetModelResInfo(self.res_info, res_info_t.ignore_find, res_info_t.ignore_wing, res_info_t.ignore_halo, res_info_t.ignore_weapon, res_info_t.show_footprint, res_info_t.ignore_cloak)
		end
		self.res_info = nil

	elseif next(self.bundle_list) and next(self.asset_list) then
		for k, v in pairs(SceneObjPart) do
			local part = self.role_model.draw_obj:GetPart(v)
			if part then
				part:RemoveModel()
			end
		end

		self.role_model:SetLoadComplete(BindTool.Bind(self._OnModelLoaded, self))
		self.role_model:SetMainAsset(self.bundle_list[SceneObjPart.Main], self.asset_list[SceneObjPart.Main])

		if self.bundle_list[SceneObjPart.Weapon] then
			self.role_model:SetGoddessAsset(self.bundle_list[SceneObjPart.Weapon], self.asset_list[SceneObjPart.Weapon])
		end
		if self.bundle_list[SceneObjPart.Wing] then
			self.role_model:SetWingAsset(self.bundle_list[SceneObjPart.Wing], self.asset_list[SceneObjPart.Wing])
		end
		if self.bundle_list[SceneObjPart.Halo] then
			local part = self.role_model.draw_obj:GetPart(SceneObjPart.Halo)
			part:ChangeModel(self.bundle_list[SceneObjPart.Halo], self.asset_list[SceneObjPart.Halo])
		end

		self.bundle_list = {}
		self.asset_list = {}
	end
end

function UIScene:LoadSceneEffect(bundle, asset)
	if nil == bundle or nil == asset then
		return
	end
	asset = asset .. "_UIeffect"

	if not self.scene_effect_obj and IsNil(self.ui_scene_obj) then
		return
	end
	self.scene_effect_obj = self.scene_effect_obj or DrawObj.New(self, self.ui_scene_obj.transform)

	local part = self.scene_effect_obj:GetPart(SceneObjPart.Main)
	part:RemoveModel()
	part:ChangeModel(bundle, asset)
	part:SetGameLayer(UiSceneBgLayer)
end

function UIScene:ClearSceneEffect()
	if not self.scene_effect_obj then
		return
	end
	self.scene_effect_obj:GetPart(SceneObjPart.Main):RemoveModel()
end

function UIScene:MainRoleApperanceChange()
	if self.role_model and self.res_info then
		self.role_model:SetModelResInfo(GameVoManager.Instance:GetMainRoleVo())
	else
		if nil ~= self.apperance_change then
			GlobalEventSystem:UnBind(self.apperance_change)
			self.apperance_change = nil
		end
	end
end

function UIScene:_OnModelLoaded(part, obj)
	if nil == self.role_model then
		return
	end
	if self.rotate_cache then
		self.role_model.draw_obj.root.transform.rotation = Quaternion.identity
		self.role_model:Rotate(self.rotate_cache.x, self.rotate_cache.y, self.rotate_cache.z)
		self.rotate_cache = nil
	end

	if self.model_load_call_back then
		self.model_load_call_back(self.role_model, self.role_model.draw_obj.root)
		self.model_load_call_back = nil
	end

	local part_obj = self.role_model.draw_obj:GetPart(part)
	part_obj:SetGameLayer(UiSceneLayer)

	if part == SceneObjPart.Main then
		self.role_model.draw_obj:GetRoot().transform:SetParent(self.ui_scene_obj.transform, false)
		if self.fight_enable then
			part_obj:SetBool(ANIMATOR_PARAM.FIGHT, true)
		end
		self:SetRoleAnimation(part_obj)
	end

	if self.weiyan_tab then
		self.role_model:SetWeiYanResid(self.weiyan_tab.weiyan_res_id, self.weiyan_tab.mount_res_id)
	end

	self:SetCameraActive(true)
end

function UIScene:ResetLocalPostion()
	if nil == self.role_model then
		return
	end
	local obj = self.role_model.draw_obj.root
	obj.transform.localPosition = Vector3(0, 0, 0)
	obj.transform.localRotation = Quaternion.Euler(0, 0, 0)
	obj.transform.localScale = Vector3(1, 1, 1)
end

function UIScene:SetRoleModelLocalPostion(x, y, z)
	if self.role_model then
		local obj = self.role_model.draw_obj.root
		obj.transform.localPosition = Vector3(x, y, z)
	end
end

function UIScene:SetRoleModelScale(scale)
	if self.role_model then
		local obj = self.role_model.draw_obj.root
		obj.transform.localScale = Vector3(scale, scale, scale)
	end
end

function UIScene:SetRoleAnimation(part_obj)
	if nil == self.role_model then
		return
	end

	part_obj = part_obj or self.role_model.draw_obj:GetPart(SceneObjPart.Main)
	if not part_obj or not self.fight_enable then return end

	local animator = part_obj:GetObj() and part_obj:GetObj().animator
	if self.tiggers then
		for k, v in pairs(self.tiggers) do
			part_obj:SetTrigger(v)
		end
	end

	self.tiggers = {}
	self.attack_hit_handle = self.attack_hit_handle or {}
	self.attack_begin_handle = self.attack_begin_handle or {}

	if animator and self.action_names then
		for k, v in pairs(self.action_names) do
			if self.attack_hit_handle[v] then
				self.attack_hit_handle[v]:Dispose()
				self.attack_hit_handle[v] = nil
			end
			if self.attack_begin_handle[v] then
				self.attack_begin_handle[v]:Dispose()
				self.attack_begin_handle[v] = nil
			end

			self.attack_begin_handle[v] = animator:ListenEvent(
				v .. "/begin", BindTool.Bind(self.OnAnimatorBegin, self, part_obj, v, self.attack_begin_handle))
			self.attack_hit_handle[v] = animator:ListenEvent(
				v .. "/hit", BindTool.Bind(self.OnAnimatorHit, self, part_obj, v, self.attack_hit_handle))
		end
	end
end

function UIScene:SetActorConfigPrefabData(data)
	if self.actor_ctrl then
		self.actor_ctrl:SetPrefabData(data)
	end
	if self.actor_trigger then
		self.actor_trigger:SetPrefabData(data, UiSceneLayer)
	end
end

function UIScene:CharacterAnimatorEvent(part_obj, param, state_info, anim_name)
	local actor_trigger = self.actor_trigger
	if actor_trigger and part_obj and part_obj:GetObj() then
		if not self.scene_target then
			self.scene_target = U3DObject(GameObject.New())
		end
		local target_transform = self.scene_target.transform
		if IsNil(target_transform) then
			self.scene_target = U3DObject(GameObject.New())
			target_transform = self.scene_target.transform
		end

		target_transform:SetParent(part_obj:GetObj().transform, false)
		target_transform.localPosition = part_obj:GetObj().transform.localPosition + Vector3(-0.23, 0, 4.57)

		local source_obj = self.role_model.draw_obj
		local target_obj = self.scene_target
		actor_trigger:OnAnimatorEvent(param, state_info, source_obj, target_obj, anim_name)
	end
end

-- string param, AnimatorStateInfo stateInfo
function UIScene:OnAnimatorBegin(part_obj, skill_action, attack_begin_handle, param, state_info)
	if self.actor_ctrl then
		self:CharacterAnimatorEvent(part_obj, param, state_info, skill_action .. "/begin")
	end

	if attack_begin_handle[skill_action] then
		attack_begin_handle[skill_action]:Dispose()
		attack_begin_handle[skill_action] = nil
	end
end

function UIScene:OnAnimatorHit(part_obj, skill_action, attack_hit_handle)
	-- local actor_ctrl = part_obj:GetObj() and part_obj:GetObj().actor_ctrl
	-- if actor_ctrl then
	-- 	if not self.scene_target then
	-- 		self.scene_target = U3DObject(GameObject.New())
	-- 	end
	-- 	local target_transform = self.scene_target.transform
	-- 	target_transform:SetParent(part_obj:GetObj().transform, false)
	-- 	target_transform.localPosition = part_obj:GetObj().transform.localPosition + Vector3(-0.23, 0, 4.57)
	-- end

	if attack_hit_handle[skill_action] then
		attack_hit_handle[skill_action]:Dispose()
		attack_hit_handle[skill_action] = nil
	end
end

function UIScene:SetFightBool(fight_enable)
	self.fight_enable = fight_enable or false
	if self.role_model then
		local part = self.role_model.draw_obj:GetPart(SceneObjPart.Main)
		if part then
			part:SetBool(ANIMATOR_PARAM.FIGHT, fight_enable)
		end
	end
end

function UIScene:SetAnimation(action_name)
	self.action_names = self.action_names or {}
	self.action_names[action_name] = action_name
	self:SetRoleAnimation(nil)
end

function UIScene:SetTriggerValue(tigger)
	self.tiggers = self.tiggers or {}
	self.tiggers[tigger] = tigger
end

function UIScene:SetRoleModelResInfo(info, ignore_find, ignore_wing, ignore_halo, ignore_weapon, show_footprint, ignore_cloak)
	if self.role_model then
		self.role_model:SetLoadComplete(BindTool.Bind(self._OnModelLoaded, self))
		self.role_model:SetModelResInfo(info, ignore_find, ignore_wing, ignore_halo, ignore_weapon, show_footprint, ignore_cloak)
	else
		self.res_info = info
		self.res_info_t = {ignore_find = ignore_find, ignore_wing = ignore_wing, ignore_halo = ignore_halo, ignore_weapon = ignore_weapon, show_footprint = show_footprint, ignore_cloak = ignore_cloak}
	end
end

function UIScene:SetGoddessModelResInfo(info, is_hide_effect)
	if self.role_model then
		self.role_model:SetLoadComplete(BindTool.Bind(self._OnModelLoaded, self))
		self.role_model:SetGoddessModelResInfo(info, is_hide_effect)
	else
		self.res_info = info
	end
end

function UIScene:ResetRotate()
	if self.role_model then
		self.role_model.draw_obj.root.transform.localRotation = Quaternion.identity
	end
	self.rotate_cache = nil
end

function UIScene:Rotate(x, y, z)
	if self.role_model then
		self.role_model:Rotate(x, y, z)
	else
		self.rotate_cache = {x = x, y = y, z = z}
	end
end

function UIScene:SetWingNeedAction(bool)
	if self.role_model then
		self.role_model:SetWingNeedAction(bool)
	end
end

-- 设置模型的旋转
function UIScene:SetLocalRotation(x, y, z)
	if self.role_model then
		self.role_model.draw_obj.root.localRotation = Quaternion.Euler(x, y, z)
	else
		self.rotation_cache = {x = x, y = y, z = z}
	end
end

function UIScene:IsNotCreateRoleModel(is_not_create_role)
	self.is_not_create_role = is_not_create_role
end

function UIScene:ModelBundle(bundle_list, asset_list)
	self.bundle_list = bundle_list or {}
	self.asset_list = asset_list or {}
	UIScene:SetModelAsset()
end

function UIScene:SetActionEnable(switch)
	if switch then
		if not self.is_play_action then
			self:RemoveActionDelayTimer()
			self.delay_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.PlayAction, self), 2)
		end
	else
		self:RemoveActionDelayTimer()
		self:SetFightBool(false)
		self.is_play_action = false
	end
end

function UIScene:PlayAction()
	if self.role_model and not self.is_play_action then
		local part = self.role_model.draw_obj:GetPart(SceneObjPart.Main)
		self.delay_timer = GlobalTimerQuest:AddDelayTimer(function()
			self.is_play_action = true
			part:EnableEffect(false)
			part:SetTrigger(ANIMATOR_PARAM.REST)
			self.delay_timer2 = GlobalTimerQuest:AddDelayTimer(function()
					part:EnableEffect(true)
					self.is_play_action = false
				 end, 3)
		  end, 0.5)
	end
end

function UIScene:RemoveActionDelayTimer()
	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end

	if self.delay_timer2 then
		GlobalTimerQuest:CancelQuest(self.delay_timer2)
		self.delay_timer2 = nil
	end
end

-- 设置UIScene的背景，使用默认背景时，bundle=nil asset=nil
function UIScene:SetBackground(bundle, asset, callback)
	if not self.node_list["Bg"] then
		return
	end

	if self.node_list["Bg"].gameObject.activeSelf then
		self.node_list["Bg"]:SetActive(false)
	end

	if nil ~= bundle and nil ~= asset then
		self.node_list["Bg"].raw_image:LoadSprite(bundle, asset, function ()
			self.node_list["Bg"]:SetActive(true)
			if callback then
				callback()
			end
		end)
	else
		self.node_list["Bg"]:SetActive(true)
	end
end

-- 设置台子是否显示
function UIScene:SetTerraceBgActive(state)
	if not self.node_list["TerraceBg"] then
		return
	end

	self.node_list["TerraceBg"]:SetActive(state)
end

-- 设置台子,bundle=nil,asset=nil 使用默认台子
function UIScene:SetTerraceBg(bundle, asset, transform, callback)
	if not self.node_list["TerraceBg"] then
		return
	end
	
	if self.node_list["TerraceBg"].gameObject.activeSelf then
		self.node_list["TerraceBg"]:SetActive(false)
	end

	local setpos = function()
		if nil ~= transform then
			self.node_list["TerraceBg"].transform.localPosition = transform.position
		end
		self.node_list["TerraceBg"]:SetActive(true)
	end

	if nil ~= bundle and nil ~= asset then
		self.node_list["TerraceBg"].raw_image:LoadSprite(bundle, asset, function ()
			self.node_list["TerraceBg"]:SetActive(true)
			self.node_list["TerraceBg"].raw_image:SetNativeSize()
			setpos()
			if callback then
				callback()
			end
		end)
	else
		setpos()
	end
end

function UIScene:SetWeiYanResid(weiyan_res_id, mount_res_id)
	self.weiyan_tab = {weiyan_res_id = weiyan_res_id, mount_res_id = mount_res_id}
	if not self.mount_move_time_quest then
		self.mount_move_time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateMountPosition, self), 0.02)
	end
end

function UIScene:ClearWeiYanData()
	self:CancelMountMoveTimeQuest()
	self.weiyan_tab = {}

	if nil == self.role_model or nil == self.role_model.draw_obj then return end

	self.role_model.draw_obj:GetRoot().transform.position = Vector3(0, 0, 0)
end

--移动坐骑，达到尾焰拖尾效果
function UIScene:UpdateMountPosition()
	if nil == self.role_model or nil == self.role_model.draw_obj then
		self:CancelMountMoveTimeQuest()
		return
	end

	if not self.camera_obj then
		self.camera_obj = self.ui_scene_obj.transform:FindByName("CameraModel")
	end

	if self.camera_obj then
		local transform = self.camera_obj.transform
		local init_position = transform.position

		if GameMath.GetDistance(transform.position.x, transform.position.y, init_position.x, init_position.y) > 10000000 then
			self.camera_obj.transform.position = init_position
		end

		local draw_root_obj = self.role_model.draw_obj:GetRoot()
		local step_target_pos = self.camera_obj.transform.position + (draw_root_obj.transform.forward * 0.08)
		local mount_pos = draw_root_obj.transform.position + (draw_root_obj.transform.forward * 0.08)

		self.camera_obj.transform.position = step_target_pos
		draw_root_obj.transform.position = mount_pos
	end
end

function UIScene:CancelMountMoveTimeQuest()
	if self.mount_move_time_quest then
		GlobalTimerQuest:CancelQuest(self.mount_move_time_quest)
		self.mount_move_time_quest = nil
	end
	self.camera_obj = nil
end

function UIScene:MoveObjResetPos(pos_cfg)
	self:CancelMountMoveTimeQuest()

	local mulit_mount_res_id = MultiMountData.Instance:GetCurMulitMountResId()
	local type_key = mulit_mount_res_id > 0 and "multimount" or "mount"
	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, type_key)
	transform.position = Vector3(transform.position.x, transform.position.y, transform.position.z + 2)
	transform.rotation = Quaternion.Euler(0, -161, 0)
	self:SetCameraTransform(transform)

	local draw_root_obj = self.role_model.draw_obj:GetRoot()
	draw_root_obj.gameObject.transform.localPosition = pos_cfg.position
	draw_root_obj.gameObject.transform.localRotation = pos_cfg.rotation
	self.mount_move_time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateMountPosition, self), 0.02)
end

function UIScene:LoadSprite(bundle_name, asset_name, callback)
	LoadSprite(self, bundle_name, asset_name, callback)
end

function UIScene:LoadRawImage(arg0, arg1, arg2)
	LoadRawImage(self, arg0, arg1, arg2)
end