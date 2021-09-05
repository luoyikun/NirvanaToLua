local DISTANCE_TO_MOVE = 30

MainUIViewJoystick = MainUIViewJoystick or BaseClass(BaseRender)

function MainUIViewJoystick:__init()
	self.joystick_angle = 0
	self.joystick_last_target_pos = u3d.vec2(0, 0)

	self.touch_times = 0
	self.show_fight_mount_flag = false

	self.is_touched = false
	self.joystick_finger_index = -1
	self.swipe_finger_index = -1
	self.is_drag = false
	self.can_drag_time = 0

	self.root_node.joystick:AddDragBeginListener(
		BindTool.Bind(self.OnJoystickBegin, self))
	self.root_node.joystick:AddDragUpdateListener(
		BindTool.Bind(self.OnJoystickUpdate, self))
	self.root_node.joystick:AddDragEndListener(
		BindTool.Bind(self.OnJoystickEnd, self))
	self.root_node.joystick:AddIsTouchedListener(
		BindTool.Bind(self.OnJoystickTouched, self))

	self.swipe_start_handle = BindTool.Bind(self.OnFingerSwipeStart, self)
	EasyTouch.On_SwipeStart = EasyTouch.On_SwipeStart + self.swipe_start_handle

	self.swipe_end_handle = BindTool.Bind(self.OnFingerSwipeEnd, self)
	EasyTouch.On_SwipeEnd = EasyTouch.On_SwipeEnd + self.swipe_end_handle

	self.swipe_handle = BindTool.Bind(self.OnFingerSwipe, self)
	EasyTouch.On_Swipe = EasyTouch.On_Swipe + self.swipe_handle

	self.pinch_handle = BindTool.Bind(self.OnFingerPinch, self)
	EasyTouch.On_Pinch = EasyTouch.On_Pinch + self.pinch_handle

	self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER, 
		BindTool.Bind1(self.OnSceneChangeBegin, self))

	-- 编辑器下才增加方向键移动，其他情况不使用
	if UnityEngine.Debug.isDebugBuild then
		Runner.Instance:AddRunObj(self, 6)
	end
end

function MainUIViewJoystick:__delete()
	if self.swipe_start_handle then
		EasyTouch.On_SwipeStart = EasyTouch.On_SwipeStart - self.swipe_start_handle
		EasyTouch.On_SwipeEnd = EasyTouch.On_SwipeEnd - self.swipe_end_handle
		EasyTouch.On_Swipe = EasyTouch.On_Swipe - self.swipe_handle
		EasyTouch.On_Pinch = EasyTouch.On_Pinch - self.pinch_handle
	end
	self:CancelOperationQuest()

	GlobalEventSystem:UnBind(self.scene_load_enter)
	self.scene_load_enter = nil

	if UnityEngine.Debug.isDebugBuild then
		Runner.Instance:RemoveRunObj(self)
	end

	if self.update_timer then
		GlobalTimerQuest:CancelQuest(self.update_timer)
		self.update_timer = nil
	end
end

function MainUIViewJoystick:Update(now_time, elapse_time)
	self.dir_key_list = self.dir_key_list or {}
	if UnityEngine.Input.GetKey(UnityEngine.KeyCode.W) then
		self.dir_key_list[UnityEngine.KeyCode.W] = {x = 0, y = 1}
	else
		self.dir_key_list[UnityEngine.KeyCode.W] = nil
	end
	if UnityEngine.Input.GetKey(UnityEngine.KeyCode.A) then
		self.dir_key_list[UnityEngine.KeyCode.A] = {x = -1, y = 0}
	else
		self.dir_key_list[UnityEngine.KeyCode.A] = nil
	end
	if UnityEngine.Input.GetKey(UnityEngine.KeyCode.S) then
		self.dir_key_list[UnityEngine.KeyCode.S] = {x = 0, y = -1}
	else
		self.dir_key_list[UnityEngine.KeyCode.S] = nil
	end
	if UnityEngine.Input.GetKey(UnityEngine.KeyCode.D) then
		self.dir_key_list[UnityEngine.KeyCode.D] = {x = 1, y = 0}
	else
		self.dir_key_list[UnityEngine.KeyCode.D] = nil
	end
	if nil ~= next(self.dir_key_list) then
		self:OnJoystickBegin()
		local dir = {x = 0, y = 0}
		for k, v in pairs(self.dir_key_list) do
			dir = { x = dir.x + v.x, y = dir.y + v.y}
		end
		local CIRCLE_ROUND = 40
		self:OnJoystickUpdate(dir.x * CIRCLE_ROUND, dir.y * CIRCLE_ROUND)
	else
		if self.touch_times > 0 then
			self:OnJoystickEnd(0, 0, true)
		end
	end

	self.camera_turn_left, self.camera_turn_right = 0, 0
	if UnityEngine.Input.GetKey(UnityEngine.KeyCode.Q) then
		self.camera_turn_left = -1
	else
		self.camera_turn_left = 0
	end
	if UnityEngine.Input.GetKey(UnityEngine.KeyCode.E) then
		self.camera_turn_right = 1
	else
		self.camera_turn_right = 0
	end
	self:MainCameraFollowSwipe((self.camera_turn_left + self.camera_turn_right) * 2, 0)
end

function MainUIViewJoystick:OnSceneChangeBegin()
	self.dir_key_list = {}
	self.camera_turn_left = nil
	self.camera_turn_right = nil
end

function MainUIViewJoystick:OnJoystickBegin()
	if Scene.Instance:GetMainRole():GetIsFlying() or MarriageData.Instance:GetOwnIsXunyou() then
		return
	end
	self.touch_times = Status.NowTime
	
	if ViewManager.Instance and ViewManager.Instance:IsOpen(ViewName.TaskDialog) then
		ViewManager.Instance:Close(ViewName.TaskDialog)
	end
end

function MainUIViewJoystick:UpdateAuditJoyStick(fx, fy, is_touch_move)
	if is_touch_move then
		self:OnJoystickUpdate(fx, fy)
		if self.update_timer then
			GlobalTimerQuest:CancelQuest(self.update_timer)
			self.update_timer = nil
		end
		if nil == self.update_timer then
			self.update_timer = GlobalTimerQuest:AddRunQuest(function()
				self:OnJoystickUpdate(fx, fy)
			end, 0.2)
		end
	else
		self:OnJoystickEnd(0, 0, is_force)
		if self.update_timer then
			GlobalTimerQuest:CancelQuest(self.update_timer)
			self.update_timer = nil
		end
	end
end

-- 摇杆回调
function MainUIViewJoystick:OnJoystickUpdate(fx, fy)
	if IsNil(MainCamera) then
		return
	end
	local main_role = Scene.Instance:GetMainRole()
	if (main_role and (main_role:GetIsQingGongGuide() or main_role:GetIsFlying() or main_role:GetIsChongci())) or MarriageData.Instance:GetOwnIsXunyou() then
		return
	end
	local main_role = Scene.Instance:GetMainRole()
	if main_role == nil or main_role.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		main_role.move_oper_cache2 = nil
		return
	end
	-- GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false, true)
	-- GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_SHRINK_BUTTON, false)
	if fx^2 + fy^2 <= DISTANCE_TO_MOVE^2 then
		GlobalEventSystem:Fire(LayerEventType.TOUCH_MOVED, 0, 0)
		return
	end

	fx, fy = self:ActuallyMoveDir(fx, fy)
	local angle = math.atan2(fy, fx)

	local ignore_high_area = main_role:IsCanUseQingGong()

	if main_role:GetMoveRemainDistance() <= 2 or math.abs(angle - self.joystick_angle) >= 0.26 then
		self.joystick_angle = angle
		local dir = u3d.v2Normalize(u3d.vec2(fx, fy))
		local x, y =  main_role:GetLogicPos()
		local target_x, target_y = AStarFindWay:GetLineEndXY(x, y, x + dir.x * 8, y + dir.y * 8, ignore_high_area)

		if target_x == x and target_y == y then
			local x_offset = fx >= 0 and 3 or -3
			local y_offset = fy >= 0 and 3 or -3

			if math.abs(fx) > math.abs(fy) then
				target_x, target_y = AStarFindWay:GetLineEndXY(x, y, x + x_offset, y, ignore_high_area)
				if target_x == x and target_y == y then
					target_x, target_y = AStarFindWay:GetLineEndXY(x, y, x + x_offset, y + y_offset, ignore_high_area)
				end
				if target_x == x and target_y == y then
					target_x, target_y = AStarFindWay:GetLineEndXY(x, y, x, y + y_offset, ignore_high_area)
				end
			else
				target_x, target_y = AStarFindWay:GetLineEndXY(x, y, x, y + y_offset, ignore_high_area)
				if target_x == x and target_y == y then
					target_x, target_y = AStarFindWay:GetLineEndXY(x, y, x + x_offset, y + y_offset, ignore_high_area)
				end
				if target_x == x and target_y == y then
					target_x, target_y = AStarFindWay:GetLineEndXY(x, y, x + x_offset, y, ignore_high_area)
				end
			end
		end

		if self.joystick_last_target_pos.x ~= target_x or self.joystick_last_target_pos.y ~= target_y then
			if not main_role:IsJump() then
				if main_role:DoMoveByClick(target_x, target_y, 0, nil, false, ignore_high_area) ~= false then
					self.joystick_last_target_pos = u3d.vec2(target_x, target_y)
				end
			end
		end
	end

	GlobalEventSystem:Fire(LayerEventType.TOUCH_MOVED, fx, fy)
end

function MainUIViewJoystick:OnJoystickEnd(fx, fy, is_force)
	if Scene.Instance:GetMainRole():GetIsFlying() or MarriageData.Instance:GetOwnIsXunyou() then
		return
	end
	local is_role_moved = self.joystick_last_target_pos.x > 0 or self.joystick_last_target_pos.y > 0
	local up_in_center = fx^2 + fy^2 <= DISTANCE_TO_MOVE^2
	if not is_force and not is_role_moved and up_in_center then
		MainUICtrl.Instance:GetView():OnClickBtnMount()
	end

	MainUICtrl.Instance:FlushView("guaji_manual_state")
	if IsNil(MainCamera) then
		return
	end

	self.joystick_angle = 0
	self.joystick_last_target_pos = u3d.vec2(0, 0)

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		return
	end
	local main_role = Scene.Instance:GetMainRole()
	if not main_role:IsAtk() and not main_role:IsAtkPlaying() and not main_role:IsJump() then
		main_role:ChangeToCommonState()
	end
	self.touch_times = 0
end

function MainUIViewJoystick:OnJoystickTouched(is_touched, finger_index)
	if Scene.Instance:GetMainRole():GetIsFlying() or MarriageData.Instance:GetOwnIsXunyou() then
		return
	end
	self.joystick_finger_index = finger_index or -1
	self.is_touched = is_touched
	if is_touched then
		GlobalEventSystem:Fire(LayerEventType.TOUCH_BEGAN)
	else
		GlobalEventSystem:Fire(LayerEventType.TOUCH_ENDED)
	end
end

function MainUIViewJoystick:ActuallyMoveDir(fx, fy)
	if IsNil(MainCamera) then
		return 0, 0
	end

	if nil == self.quat then
		self.quat = Quaternion()
		self.screen_forward = Vector3(0, 0, 0)
		self.screen_input = Vector3(0, 0, 0)
		self.euler_angles = Vector3(0, 0, 0)
	end

	self.screen_forward.z = 1

	self.screen_input.x = fx
	self.screen_input.z = fy

	self.quat:SetFromToRotation(self.screen_forward, self.screen_input)

	self.euler_angles.x = self.quat.eulerAngles.x
	self.euler_angles.y = self.quat.eulerAngles.y
	self.quat.eulerAngles = self.euler_angles
	local camera_forward = MainCamera.transform.forward
	camera_forward.y = 0

	local move_dir = self.quat * camera_forward
	return move_dir.x, move_dir.z
end

----------------------------------------自由视觉/star-------------------------------------
function MainUIViewJoystick:OnFingerSwipeStart(gesture)
	if gesture.fingerIndex ~= self.joystick_finger_index and not self.is_drag then
		self.is_drag = true
		self.swipe_finger_index = gesture.fingerIndex
		self.can_drag_time = Status.NowTime + 0.05
	end
end

function MainUIViewJoystick:OnFingerSwipeEnd(gesture)
	if gesture.fingerIndex == self.swipe_finger_index then
		self.is_drag = false
		self.swipe_finger_index = -1
	end
	if not IsNil(MainCameraFollow) then
		MainUIData.UserOperation = true
		MainCameraFollow.AutoRotation = false
		self:CancelOperationQuest()
		self.user_operation_time = GlobalTimerQuest:AddDelayTimer(function ()
			MainUIData.UserOperation = false
			MainUICtrl.Instance:FlushView("auto_rotation")
		end, 10)
	end
end

function MainUIViewJoystick:OnFingerSwipe(gesture)
	if not self.is_drag or (self.is_touched and gesture.fingerIndex == self.joystick_finger_index) then
		return
	end
	if Status.NowTime >= self.can_drag_time and not IsNil(MainCameraFollow) then
		local x = gesture.swipeVector.x
		if x > 0 then
			x = math.min(20, x)
		else
			x = math.max(-20, x)
		end
		self:MainCameraFollowSwipe(x, gesture.swipeVector.y)
	end
end

function MainUIViewJoystick:MainCameraFollowSwipe(x, y)
	if IsNil(MainCameraFollow) or (x == 0 and y == 0) then
		return
	end
	MainCameraFollow:Swipe(x, y)
	self:CancelQuest()
	self.delay_time = GlobalTimerQuest:AddDelayTimer(function ()
		self:UpdateCameraSetting()
	end, 0.5)
end

function MainUIViewJoystick:OnFingerPinch(gesture)
	if PlayerData.Instance:IsHoldAngle() then
		return
	end
	if not self.is_touched and not IsNil(MainCameraFollow) then
		self.can_drag_time = Status.NowTime + 0.05
		MainCameraFollow:Pinch(gesture.deltaPinch)
		self:CancelQuest()
		self.delay_time = GlobalTimerQuest:AddDelayTimer(function ()
			self:UpdateCameraSetting()
		end, 0.5)
	end
end

function MainUIViewJoystick:CancelQuest()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function MainUIViewJoystick:CancelOperationQuest()
	if self.user_operation_time then
		GlobalTimerQuest:CancelQuest(self.user_operation_time)
		self.user_operation_time = nil
	end
end

-- 服务器保存参数
function MainUIViewJoystick:UpdateCameraSetting()
	if CAMERA_TYPE == CameraType.Free then
		if not IsNil(MainCameraFollow) and not IsNil(MainCamera) then
			local angle = MainCamera.transform.parent.transform.localEulerAngles
			SettingCtrl.Instance:SendChangeHotkeyReq(HOT_KEY.CAMERA_ROTATION_X, angle.x)
			SettingData.Instance:SetSettingDataListByKey(HOT_KEY.CAMERA_ROTATION_X, angle.x)
			SettingCtrl.Instance:SendChangeHotkeyReq(HOT_KEY.CAMERA_ROTATION_Y, angle.y)
			SettingData.Instance:SetSettingDataListByKey(HOT_KEY.CAMERA_ROTATION_Y, angle.y)

			local distance = MainCameraFollow.Distance
			SettingCtrl.Instance:SendChangeHotkeyReq(HOT_KEY.CAMERA_DISTANCE, distance)
			SettingData.Instance:SetSettingDataListByKey(HOT_KEY.CAMERA_DISTANCE, distance)
		end
	end
end