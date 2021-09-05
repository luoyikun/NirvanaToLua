-------------------------------------------
--基础副本逻辑,统一处理一些副本活动类通用的逻辑
--@author bzw
--------------------------------------------
local MAP_BLOCK_EFFECT = {
	[1] = {bundle = "effects/prefab/misc/zudang_huo_prefab", asset = "zudang_huo"},
	[2] = {bundle = "effects/prefab/misc/zudang_lan_prefab", asset = "zudang_lan"},
	[3] = {bundle = "effects/prefab/misc/zudang_xue_prefab", asset = "zudang_xue"},
	[4] = {bundle = "effects/prefab/misc/zudang_zi_prefab", asset = "zudang_zi"}
}


BaseFbLogic = BaseFbLogic or BaseClass(BaseSceneLogic)
function BaseFbLogic:__init()
	self.is_enter_scene_action = false
	self.is_enter_scene_rotation = false
	self.is_map_block = false				-- 是否处于地图阻挡区域中
end

function BaseFbLogic:__delete()
	if self.story then
		self.story:DeleteMe()
		self.story = nil
	end
	self.is_enter_scene_action = false
	self.is_enter_scene_rotation = false
	self.is_map_block = false
end

function BaseFbLogic:Enter(old_scene_type, new_scene_type)
	BaseSceneLogic.Enter(self, old_scene_type, new_scene_type)
	-- MainUICtrl.Instance:SetViewHideorShow("RightPanel", false)
	local fb_cfg = Scene.Instance:GetCurFbSceneCfg()
	ViewManager.Instance:Close(ViewName.TaskDialog)
	ViewManager.Instance:Close(ViewName.FuBen)

	local scene_id = Scene.Instance:GetSceneId()
	self.story = XinShouStorys.New(scene_id)

	self:CheckSceneMapBlock(scene_id)

	-- 进入副本写死一个视角
	local camear_cfg = FuBenData.Instance:GetFbCamearCfg(scene_id)
	if camear_cfg then
		Scene.Instance:SetGuideFixedCamera(camear_cfg.rotation_x, camear_cfg.rotation_y)
	end
		-- 进副本播放人物场景动作
	local fb_scene_cfg = SceneData.Instance:GetFbSceneCfg(scene_id)
	if fb_scene_cfg then
		if fb_scene_cfg.role_rotation and fb_scene_cfg.role_rotation ~= "" then
			self.is_enter_scene_rotation = true
		end

		if fb_scene_cfg.is_scene_action and fb_scene_cfg.is_scene_action ~= "" and fb_scene_cfg.is_scene_action == 1 then
			self.is_enter_scene_action = true
			Scene.Instance:SetMainRoleIsMove(false)
		end
	end
end

-- 退出
function BaseFbLogic:Out(old_scene_type, new_scene_type)
	BaseSceneLogic.Out(self, old_scene_type, new_scene_type)
	-- MainUICtrl.Instance:SetViewHideorShow("RightPanel", true)
	-- 退出场景移除禁止走路的区域
	self:RemoveSceneBlock()
	if new_scene_type == 0 then
		self:SetOutFbCamera()
	end
	if old_scene_type ~= SceneType.ZhuanZhiFb and old_scene_type ~= SceneType.CrossGuild then
		GuajiCtrl.Instance:SetMoveToPosCallBack(nil)
	end
end

-- 进度条结束调用
function BaseFbLogic:SceneLoadEnd(scene_id)
	BaseSceneLogic.SceneLoadEnd(self, scene_id)

	if self.is_enter_scene_rotation then
		local fb_scene_cfg = SceneData.Instance:GetFbSceneCfg(scene_id)
		local main_role = Scene.Instance:GetMainRole()
		if fb_scene_cfg and main_role and main_role.GetDrawObj then
			main_role:GetDrawObj():SetRotation(0, fb_scene_cfg.role_rotation, 0)
		end
	end

	if self.is_enter_scene_action then
		self:FbPlayAction()
	end
end

-- 退出副本角度
function BaseFbLogic:SetOutFbCamera()
	if nil ~= MainCameraFollow and MainCameraFollow.OriginAngle then
		Scene.Instance:SetGuideFixedCamera(20, MainCameraFollow.OriginAngle.y or 0)
	end
end

function BaseFbLogic:GetMoveObjAllInfoFrequency()
	return 3
end

--获得场景显标的副本图标列表
function BaseSceneLogic:GetFbSceneShowFbIconCfgList()

end

function BaseFbLogic:OnClickHeadHandler(is_show)
	-- override
end

function BaseFbLogic:IsShowVictoryView()
	return false
end

function BaseFbLogic:IsEnemy(target_obj, main_role, ignore_table)
	if not Scene.Instance:GetMainRoleIsMove() then
		return false
	end

	if self.is_map_block then
		return false
	end

	return BaseSceneLogic.IsEnemy(self, target_obj, main_role, ignore_table)
end

-- 是否可以移动
function BaseFbLogic:CanMove()
	return Scene.Instance:GetMainRoleIsMove()
	-- return true
end

-- 进副本播放动画效果
function BaseFbLogic:FbPlayAction()
	Scene.Instance:OnShieldFlyPet(true)
	local setting_spirit = SettingData.Instance:GetSettingList()[SETTING_TYPE.SHIELD_SPIRIT]
	local setting_lingtong = SettingData.Instance:GetSettingList()[SETTING_TYPE.SHIELD_LINGCHONG]
	SettingData.Instance:SetSettingData(SETTING_TYPE.SHIELD_SPIRIT, true)
	SettingData.Instance:SetSettingData(SETTING_TYPE.SHIELD_LINGCHONG, true)

	local main_role = Scene.Instance:GetMainRole()
	if not main_role then
		return
	end
	main_role:GetRoot().transform.localScale = Vector3.zero
	main_role:SetGoddessVisible(false)
	main_role:SetRoleCannotMove()
	local follow_ui = main_role:GetFollowUi()
	follow_ui:Hide()

	local rand_num = math.random(1000, 1001)
	local bundle_name, asset_name = ResPath.GetOtherModel(rand_num)		-- 1000 是葫芦
	ResPoolMgr:GetDynamicObjAsync(bundle_name, asset_name, function (obj)
		if IsNil(obj) then
			Scene.Instance:SetMainRoleIsMove(true)
			return
		end
		
		if not main_role or not main_role:GetRoot() then
			Scene.Instance:SetMainRoleIsMove(true)
			return
		end	
		local huluzui_eff = obj.transform:FindByName("huluzui_effect")
		if huluzui_eff then
			huluzui_eff.gameObject:SetActive(false)
		end

		local role_transform = main_role:GetRoot().transform

		local camera_point = role_transform:FindByName("CamerafocalPoint")
		local camera_pos = Vector3.zero
		if camera_point then
			camera_pos = camera_point.transform.localPosition
		end

		local role_position = role_transform.localPosition
		local role_rotation = role_transform.localRotation
		obj.transform.localPosition = role_position
		obj.transform.localRotation = role_rotation
		role_transform.localScale = Vector3.zero
		-- 摄像机
		if camera_point then
			camera_point.transform:SetParent(obj.transform)
			camera_point.transform.localPosition = camera_pos
		end

		local huluzui_obj = obj.transform:FindByName("huluzui")
		if huluzui_obj then
			role_transform:SetParent(huluzui_obj.transform)
			role_transform.localPosition = Vector3.zero
			role_transform.localRotation = Vector3.zero
		end
		local main_part = main_role.draw_obj:GetPart(SceneObjPart.Main)

		local animator = obj.gameObject:GetComponent(typeof(UnityEngine.Animator))
		if animator then
			-- 监听人从葫芦嘴里出来
			animator:WaitEvent("chuchang", function ()
				if huluzui_eff then
					huluzui_eff.gameObject:SetActive(true)
				end
				local sceneobj_layer = main_role:GetSceneObjLayer()
				if sceneobj_layer then
					if not IsNil(role_transform) then
						role_transform:SetParent(sceneobj_layer)
					end
				end
				role_transform:DOScale(Vector3.one, 1)
				local tween = role_transform:DOLocalMove(role_position, 1)
				tween:OnComplete(function ()
					-- 摄像机
					if camera_point then
						camera_point.transform:SetParent(role_transform)
					end
					
					local bundle, asset = ResPath.GetHuLuEff(2)
					EffectManager.Instance:PlayEffect(bundle, asset, role_transform, nil, 1)
					Scene.Instance:SetMainRoleIsMove(true)
				end)

				if main_part then
					main_part:SetTrigger("QingGongLand2")

				end
			end)
			animator:WaitEvent("tuichu", function ()
					if huluzui_eff then
						huluzui_eff.gameObject:SetActive(false)
					end
				end)

			-- 监听动作结束 释放资源
			animator:WaitEvent("chuchang_exit", function ()
				Scene.Instance:SetMainRoleIsMove(true)
				Scene.Instance:OnShieldFlyPet(false)
				SettingData.Instance:SetSettingData(SETTING_TYPE.SHIELD_SPIRIT, setting_spirit)
				SettingData.Instance:SetSettingData(SETTING_TYPE.SHIELD_LINGCHONG, setting_lingtong)

				local shield_goddess = SettingData.Instance:GetSettingData(SETTING_TYPE.CLOSE_GODDESS)
				main_role:SetGoddessVisible(not shield_goddess)
				follow_ui:Show()

				ResPoolMgr:Release(obj)
			end)
		end
	end)
end


--------------------------------------------------
-- 进入副本 处于准备期间的表现
--------------------------------------------------
-- 检测该场景是否需要准备状态中禁止走出去区域
function BaseFbLogic:CheckSceneMapBlock(scene_id)
	local act_scene = SceneData.Instance:GetMapBlockOtherCfg(scene_id)
	if nil == act_scene then
		return
	end
	self.act_id = act_scene.act_id

	local activity_info = ActivityData.Instance:GetActivityStatuByType(self.act_id)
	if activity_info.status == ACTIVITY_STATUS.STANDY then
		self.is_map_block = true
		self:SetSceneBlock()
		if nil == self.activity_status then
			self.activity_status = GlobalEventSystem:Bind(OtherEventType.ACTIVITY_STATUS, BindTool.Bind1(self.OnActivityStatus, self))
		end

		local map_block_bubble_cfg = SceneData.Instance:GetMapBlockBubbleCfg()
		if nil == self.role_bubble_timer and map_block_bubble_cfg then
			self.role_bubble_timer = GlobalTimerQuest:AddRunQuest(
				function()
					self:SetRoleBubble(scene_id)
				end, map_block_bubble_cfg.show_time)
		end
	else
		self:RemoveSceneBlock()
	end
end

function BaseFbLogic:OnActivityStatus(protocol)
	if nil == self.act_id or self.act_id ~= protocol.activity_type then
		return
	end

	if protocol.status ~= ACTIVITY_STATUS.STANDY then
		self:RemoveSceneBlock()
	end
end

-- 设置场景禁止走路的区域(根据场景ID获取配置)
function BaseFbLogic:SetSceneBlock()
	local map_block = SceneData.Instance:GetMapBlockCfg(self.act_id)
	if nil == map_block then
		return
	end

	self.map_block_effect_list = {}
	self.block_info = {}
	for _, v in pairs(map_block) do
		if v.effect_type and v.effect_type ~= "" then
			local effect_y = v.effect_y ~= "" and v.effect_y or 0
			local rotation_y = v.rotation_y ~= "" and v.rotation_y or 0
			local scale_x = v.scale_x ~= "" and v.scale_x or 1
			local scale_y = v.scale_y ~= "" and v.scale_y or 1
			self:SetMapBlockEffect(v.effect_type, v.point_x, v.point_y, effect_y, rotation_y, scale_x, scale_y)
		end
		table.insert(self.block_info, {x = v.point_x, y = v.point_y})
	end
	for _, v in pairs(self.block_info) do
		AStarFindWay:SetBlockInfo(v.x, v.y)
	end
end

-- 移除场景禁止走路的区域
function BaseFbLogic:RemoveSceneBlock()
	self.is_map_block = false
	self.act_id = nil
	if self.role_bubble_timer then
		GlobalTimerQuest:CancelQuest(self.role_bubble_timer)
		self.role_bubble_timer = nil
	end

	if self.activity_status then
		GlobalEventSystem:UnBind(self.activity_status)
		self.activity_status = nil
	end

	if self.map_block_effect_list then
		for _, obj in pairs(self.map_block_effect_list) do
			ResPoolMgr:Release(obj)
		end
		self.map_block_effect_list = nil
	end

	if self.block_info and #self.block_info > 0 then
		for _, v in pairs(self.block_info) do
			AStarFindWay:RevertBlockInfo(v.x, v.y)
		end
		self.block_info = {}
	end
end

-- 设置玩家气泡框
function BaseFbLogic:SetRoleBubble(scene_id)
	local group_id = SceneData.Instance:GetMapBlockBubbleChatLimitGroupId(scene_id)
	if group_id <= 0 then
		return
	end
	local is_chat_content_random = false
	local map_block_bubble_cfg = SceneData.Instance:GetMapBlockBubbleCfg()
	if map_block_bubble_cfg and map_block_bubble_cfg.chat_content_random and  map_block_bubble_cfg.chat_content_random ~= "" then
		is_chat_content_random = map_block_bubble_cfg.chat_content_random == 1 and true or false
	end

	local chat_content_list = SceneData.Instance:GetMapBlockBubbleChatContent(group_id)
	if chat_content_list then
		local map_block_bubble_cfg = SceneData.Instance:GetMapBlockBubbleCfg()
		local role_chat_max_num = map_block_bubble_cfg.scene_limit
		local role_chat_num = 0

		local chat_max_num = #chat_content_list
		local i = 1

		local role_list = Scene.Instance:GetRoleList()
		for _ , v in pairs(role_list) do
			if role_chat_max_num >= role_chat_num then
				if is_chat_content_random then
					local content = chat_content_list[math.random(1, chat_max_num)]
					v:GetFollowUi():ChangeBubble(content.bubble_text, content.disappear_time)
				else
					local content = chat_content_list[i]
					v:GetFollowUi():ChangeBubble(content.bubble_text, content.disappear_time)
					if chat_max_num > i then
						i = i + 1
					else
						i = 1
					end
				end
				role_chat_num = role_chat_num + 1
			else
				break
			end
		end
	end
end

-- 设置地图阻挡区域特效
function BaseFbLogic:SetMapBlockEffect(effect_type, x, y, z, rotation_y, scale_x, scale_y)
	effect_type = effect_type or 1
	local map_block_effect = MAP_BLOCK_EFFECT[effect_type]
	if not map_block_effect then
		return
	end

	local w_pos_x, w_pos_z = GameMapHelper.LogicToWorld(x, z)
	local position = Vector3(w_pos_x, y, w_pos_z)
	local rotation = Quaternion.Euler(0, rotation_y, 0)
	local scale = Vector3(scale_x, scale_y, 1)
	ResPoolMgr:GetEffectAsync(map_block_effect.bundle, map_block_effect.asset, function(obj)
		if IsNil(obj) then
			return
		end
		self.map_block_effect_list[#self.map_block_effect_list + 1] = obj

		obj.transform.position = position
		obj.transform.rotation = rotation
		obj.transform.localScale = scale
	end)
end
--------------------------------------------------
