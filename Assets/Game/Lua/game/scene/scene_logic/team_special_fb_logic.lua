TeamSpecialFbLogic = TeamSpecialFbLogic or BaseClass(BaseFbLogic)

function TeamSpecialFbLogic:__init()
	self.event_handle = BindTool.Bind(self.OnDoorCreate, self)
	self.is_insert_nostop_guaji_scene_id = false
	self.first_nostop_scene_id = 2100 --须弥幻境第一个场景id
	self.last_nostop_scene_id = 2149 --须弥幻境最后一个场景id
	self.old_scene_type = -1
	self.new_scene_type = -1
	self.mainui_open = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpen, self))
	self.scene_all_load_complete_event = GlobalEventSystem:Bind(SceneEventType.SCENE_ALL_LOAD_COMPLETE, BindTool.Bind1(self.OnSceneDetailLoadComplete, self))
end

function TeamSpecialFbLogic:__delete()
	self.is_insert_nostop_guaji_scene_id = false
	GlobalEventSystem:UnBind(self.scene_all_load_complete_event)

	if self.mainui_open then
		GlobalEventSystem:UnBind(self.mainui_open)
		self.mainui_open = nil
	end
end

function TeamSpecialFbLogic:Enter(old_scene_type, new_scene_type)
	self.obj_create_event = GlobalEventSystem:Bind(ObjectEventType.OBJ_CREATE, self.event_handle)

	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:CloseAll()
	ViewManager.Instance:Open(ViewName.FuBenSpecialInfoView)
	MainUICtrl.Instance:SetViewState(false)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	FuBenCtrl.Instance:CloseView()

	if ViewManager.Instance:IsOpen(ViewName.FBVictoryFinishView) then
		ViewManager.Instance:Close(ViewName.FBVictoryFinishView)
	end
end

function TeamSpecialFbLogic:OnSceneDetailLoadComplete()
	if self.old_scene_type ~= self.new_scene_type then
		local info = FuBenData.Instance:GetTeamSpecialResultInfo()
		self.old_scene_type = -1
		self.new_scene_type = -1
		if (info.is_finish == 1 and info.is_all_over == 1) or info.is_finish == 1 then
			FuBenData.Instance:ClearFBDropInfo()
			ViewManager.Instance:Close(ViewName.FBDropView)
			local time = TimeUtil.FormatSecond(info.use_time, 7) or 0
			if info.is_passed == 1 then
				if info.have_pass_reward == 1 then
					GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
					ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "team_result", {data = info.item_list, time = time})
				else
					ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "no_result", {time = time})
				end
			else
				ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "team_result", {data = info.item_list, time = time})
			end
			if info.is_leave == 1 then
				FuBenData.Instance:SetDefaultChoose(ScoietyData.InviteOpenType.EquipTeamFbNew)
				local role_level = PlayerData.Instance:GetRoleVo().level
				if role_level >= GameEnum.NOVICE_LEVEL then
					ViewManager.Instance:Open(ViewName.FuBen, TabIndex.fb_team_tower)
				end
			end
		end
	end
end

function TeamSpecialFbLogic:Out(old_scene_type, new_scene_type)
	GlobalTimerQuest:CancelQuest(self.delay_move)
	 if self.obj_create_event ~= nil then
		GlobalEventSystem:UnBind(self.obj_create_event)
		self.obj_create_event = nil
	end
	self.old_scene_type = old_scene_type
	self.new_scene_type = new_scene_type

	if old_scene_type ~= new_scene_type then
		BaseFbLogic.Out(self, old_scene_type, new_scene_type)
		ViewManager.Instance:Close(ViewName.FuBenSpecialInfoView)
		TipsCtrl.Instance:CloseFBDropView()
		MainUICtrl.Instance:SetViewState(true)
		GuajiCtrl.Instance:StopGuaji()
		FuBenData.Instance:ClearFBSceneLogicInfo()

		Scene.Instance:DeleteObjsByType(SceneObjType.Door)
	end
end


-- 是否可以拉取移动对象信息
function TeamSpecialFbLogic:CanGetMoveObj()
	return true
end

-- 拉取移动对象信息间隔
function TeamSpecialFbLogic:GetMoveObjAllInfoFrequency()
	return 3
end

-- 角色是否是敌人
function TeamSpecialFbLogic:IsRoleEnemy(target_obj, main_role)
	return false
end

-- 是否可以屏蔽怪物
function TeamSpecialFbLogic:CanShieldMonster()
	return false
end

-- 是否自动设置挂机
function TeamSpecialFbLogic:IsSetAutoGuaji()
	return true
end

-- function TeamSpecialFbLogic:DelayOut(old_scene_type, new_scene_type)
-- 	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
-- 	MainUICtrl.Instance:SetViewState(true)
-- end

function TeamSpecialFbLogic:GetPickItemMaxDic(item_id)
	return 2
end

function TeamSpecialFbLogic:GetGuajiPos()
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id == self.last_nostop_scene_id then
		scene_id = self.last_nostop_scene_id - 1
	end
	local scene_config = ConfigManager.Instance:GetSceneConfig(scene_id) or {}
	local scene_doors = {}
	for k,v in pairs(scene_config.doors) do
		if v.id == scene_id + 1 then
			scene_doors = v
			break
		end
		scene_doors = v
	end
	local door_x = scene_doors.x
	local door_y = scene_doors.y
	--这里返回的应该是一个坐标点, 这里代码不知道用来干嘛的
	-- local main_role = Scene.Instance:GetMainRole()
	-- local logic_x, logic_y = main_role:GetLogicPos()
	-- local normal = u3d.v2Normalize(Vector2(door_x - logic_x, door_y - logic_y))
	-- local distance = u3d.v2Length(Vector2(door_x - logic_x, door_y - logic_y), true)
	return door_x, door_y
end

function TeamSpecialFbLogic:IsRoleEnemy()
	return false
end

function TeamSpecialFbLogic:OnDoorCreate(obj)
	local scene_door = FuBenData.Instance:GetNextSceneDoor()
	if nil == scene_door or SceneObjType.Door ~= obj:GetType() then
		return
	end

	GlobalTimerQuest:CancelQuest(self.delay_move)
	self.delay_move = GlobalTimerQuest:AddDelayTimer(function () 
		local scene_id = Scene.Instance:GetSceneId()
		local callback = function()
			GuajiCtrl.Instance:MoveToPos(scene_id, scene_door.x, scene_door.y)
		end
		callback()
		GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
	end, 6)
end

function TeamSpecialFbLogic:MainuiOpen()
	MainUICtrl.Instance:SetViewState(false)
end