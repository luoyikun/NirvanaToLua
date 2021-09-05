MainRole = MainRole or BaseClass(Role)

local MATERIAL_ID_LIST = {
	[GameEnum.ROLE_PROF_1] = "8016_02",
	[GameEnum.ROLE_PROF_2] = "8016_02",
	[GameEnum.ROLE_PROF_3] = "8016_02",
}
function MainRole:__init(vo)
	self.obj_type = SceneObjType.MainRole
	self.draw_obj:SetObjType(self.obj_type)
	self.draw_obj:SetIsDisableAllAttachEffects(false)
	self.draw_obj:SetIsOptimizeMaterial(false)

	self.arrive_func = nil							-- 到达处理
	self.move_oper_cache = nil						-- 移动操作缓存
	self.move_oper_cache2 = nil  					-- 跳跃操作缓存
	self.is_only_client_move = false				-- 在某些玩法副本中, 全是机器人，又需要动态改变主角速度，移动设计成不通知服务器

	self.last_logic_pos_x = 0
	self.last_logic_pos_y = 0

	self.last_skill_id = 0
	self.last_skill_index = 0
	self.atk_is_hit = {}
	self.last_atk_end_time = 0

	self.path_pos_list = {}
	self.path_pos_index = 1

	self.last_in_safe = false					-- 上一刻是否在安全区

	self.is_specialskil = false
	self.is_special_jump = false
	self.is_inter_scene = false
	self.character_ghost = nil 					-- 残影组件
	self.ghost_time = 1 						-- 残影持续时间

	self.last_mount_state = 0

	self.jump_name = nil
	self.jump_normalized_time = nil

	self.jump_call_back = nil
	self.target_point = nil
	self.next_point = nil

	self.target_x = 0
	self.target_y = 0

	self.total_stand_time = 0
	self.npc_id = 220 --抱美人的npcid

	self.next_check_camera_time = 0

	self.is_fly_task_update = false
	self.fly_task_is_hide = false
	self.fly_task_range = 0

	self.qinggong_index = 0
	self.auto_jump_count = 0
	self.cur_qinggong_state = QingGongState.None
	self.check_fly_task_update_time = 0
	self.last_sync_time = 0
	self.jump_time_stamp = 0
	self.qinggong_obj_time = 0
	self.old_qinggong_enabled = nil
	self.ready_to_ground = false
	self.is_scene_action_state = false
	self.is_qinggong_guide = false
	self.is_first_land = true
	self.delay_npc_group_chat = {}

	self.touch_began_event = GlobalEventSystem:Bind(LayerEventType.TOUCH_BEGAN, BindTool.Bind(self.TouchBegin, self))
	self.touch_end_event = GlobalEventSystem:Bind(LayerEventType.TOUCH_ENDED, BindTool.Bind(self.TouchEnd, self))
	self.touch_move_event = GlobalEventSystem:Bind(LayerEventType.TOUCH_MOVED, BindTool.Bind(self.TouchMove, self))

	if nil == self.npc_group_chat_event then
		self.npc_group_chat_event = GlobalEventSystem:Bind(SceneChatEventType.NPC_GROUP_CHAT, BindTool.Bind(self.NpcGroupChatHandler, self))
	end
	self.change_scene_handle = GlobalEventSystem:Bind(SceneEventType.SCENE_ALL_LOAD_COMPLETE, BindTool.Bind1(self.OnSceneChangeComplete, self))
	self.role_enter_scene_effect = GlobalEventSystem:Bind(SceneEventType.CLOSE_LOADING_VIEW, BindTool.Bind1(self.OnCloseSceneLoadingView, self))
end

function MainRole:__delete()
	if self.material then
		ResPoolMgr:Release(self.material)
		self.material = nil
	end
	self:HideJumpTrailRenderer()
	if not IsNil(MainCameraFollow) then
		MainCameraFollow.Target = nil
		if CAMERA_TYPE == CameraType.Free then
			MainCameraFollow.AutoRotation = false
		end
	end

	if self.npc_group_chat_event then
		GlobalEventSystem:UnBind(self.npc_group_chat_event)
		self.npc_group_chat_event = nil
	end

	if self.touch_began_event then
		GlobalEventSystem:UnBind(self.touch_began_event)
		self.touch_began_event = nil
	end

	if self.touch_end_event then
		GlobalEventSystem:UnBind(self.touch_end_event)
		self.touch_end_event = nil
	end

	if self.touch_move_event then
		GlobalEventSystem:UnBind(self.touch_move_event)
		self.touch_move_event = nil
	end

	if self.role_enter_scene_effect then
		GlobalEventSystem:UnBind(self.role_enter_scene_effect)
		self.role_enter_scene_effect = nil
	end
	if self.change_scene_handle then
		GlobalEventSystem:UnBind(self.change_scene_handle)
		self.change_scene_handle = nil
	end

	if self.role_can_move_time then
		GlobalTimerQuest:CancelQuest(self.role_can_move_time)
		self.role_can_move_time = nil
	end

	self.is_scene_action_state = false
	self.is_inter_scene = false
	self.character_ghost = nil
	self.jump_name = nil
	self.jump_normalized_time = nil
	self:CancelJumpQuest()
	self:CancelCameraUpdateTimer()
	self:DestroyTrail()				-- 销毁拖尾特效
	self:ReleaseQingGongMount()		-- 释放轻功坐骑
	self:RemoveNpcGroupChatTimer()
	self:RemoveHighAreaAudio()		-- 释放音频
end

function MainRole:InitInfo()
	Role.InitInfo(self)
	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	for i = 1, COMMON_CONSTS.MAX_QING_GONG_COUNT do
		if main_part then
			main_part:ListenEvent("qinggong_pre" .. i .. "/end", BindTool.Bind(self.QingGongBeginExit, self, i))
		end
	end

	if main_part then
		main_part:ListenEvent("scene_action_1/begin", BindTool.Bind(self.SceneActionBegin, self))
		main_part:ListenEvent("scene_action_1/end", BindTool.Bind(self.SceneActionEnd, self))
	end
end

function MainRole:CreateShadow()
	Role.CreateShadow(self)
end

function MainRole:RegisterShadowUpdate()
	Role.RegisterShadowUpdate(self)
end

function MainRole:Update(now_time, elapse_time)
	Role.Update(self, now_time, elapse_time)
	if self.last_logic_pos_x ~= self.logic_pos.x or self.last_logic_pos_y ~= self.logic_pos.y then
		self.last_logic_pos_x = self.logic_pos.x
		self.last_logic_pos_y = self.logic_pos.y
		GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_POS_CHANGE, self.last_logic_pos_x, self.last_logic_pos_y)

		-- 状态不一样
		local is_in_safe_area = self:IsInSafeArea()
		if self.last_in_safe ~= is_in_safe_area then
			self.last_in_safe = is_in_safe_area
			local convertion = SceneConvertionArea.SAFE_TO_WAY
			if self.last_in_safe then
				convertion = SceneConvertionArea.WAY_TO_SAFE
			end
			GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_CHANGE_AREA_TYPE, convertion)
		end

		-- 用于检测飞行下降的距离是多少
		self:OnFlyTaskUpdate()
	end
	if self.add_level_eff_time and now_time - self.add_level_eff_time > 0.5 then
		self:RemoveBuff(BUFF_TYPE.UP_LEVEL)
		self.add_level_eff_time = nil
	end

	if self:IsStand() then
		if self.total_stand_time == 0 then
			GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_ENTER_IDLE_STATE)
		end
		self.total_stand_time = self.total_stand_time + elapse_time
	else
		if self.total_stand_time ~= 0 then
			GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_STOP_IDLE_STATE)
		end
		self.total_stand_time = 0
	end

	if not self.is_landed and not CgManager.Instance:IsCgIng() then
		if now_time >= self.last_sync_time + 0.1 then
			self.last_sync_time = now_time

			local position = self.draw_obj:GetRoot().gameObject.transform.position
			self:SetRealPos(position.x, position.z)

			local forward = self.draw_obj:GetRoot().gameObject.transform.forward
			local dir = math.atan2(forward.z, forward.x)

			local height = position.y
			height = bit:_lshift(height, 4)

			local percent = 0
			if self.qinggong_obj_time > 0 then
				percent = (Status.NowTime - self.jump_time_stamp) / self.qinggong_obj_time
				percent = percent > 1 and 1 or percent
				percent = math.floor(percent * 15)
			end
			
			Scene.SendMoveReq(dir, self.logic_pos.x, self.logic_pos.y, 0, height + percent)
		end
	end

	if self.is_chongci then
		if self.chongci_end_timer and self.chongci_end_timer <= Status.NowTime then
			self.is_chongci = false
		end
	end

	-- MainCamera在某些情况下会丢失Target，这里加个检查
	if self.next_check_camera_time <= Status.NowTime then
		self.next_check_camera_time = Status.NowTime + 2
		if not IsNil(MainCameraFollow) then
			if nil == MainCameraFollow.Target then
				self:UpdateCameraFollowTarget(true)
			end
		end
	end
end

--检测飞行距离
function MainRole:FlyTaskTesting(end_x, end_y)
	local dis = GameMath.GetDistance(self.logic_pos.x, self.logic_pos.y, end_x, end_y, false)
	return dis <= self.fly_task_range
end

function MainRole:OnEnterScene()
	Role.OnEnterScene(self)
	self.is_inter_scene = true
	self:UpdateCameraFollowTarget(true)
	self:GetFollowUi()
	self.draw_obj:SetMoveCallback(function (flag)
		if flag == 2 then
			self:StopMove()
			-- self:SendMoveReq(0)
		end
	end)
	self:CheckQingGong()
end

function MainRole:OnLoadSceneComplete()
	Role.OnLoadSceneComplete(self)
end

function MainRole:IsMainRole()
	return true
end

function MainRole:GetObjKey()
	return nil
end

function MainRole:HideFollowUi()
end

function MainRole:IsEnterScene()
	return self.is_inter_scene
end

function MainRole:ResetIsEnterScene()
	self.is_inter_scene = false
end

function MainRole:DoMoveByClick(...)
	if self.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CanNotMoveInJump)
		return
	end
	local logic = Scene.Instance:GetSceneLogic()
	if logic and not logic:CanCancleAutoGuaji() then
		return false
	end

	Scene.Instance:GetSceneLogic():StopAutoGather()
	GuajiCtrl.Instance:DoMoveByClick(...)
	self:ClearPathInfo()
	self.attack_skill_id = 0
	GlobalEventSystem:Fire(OtherEventType.MOVE_BY_CLICK)
	GuajiCtrl.Instance:SetMoveToPosCallBack(nil)
	return self:DoMoveOperate(...)
end

function MainRole:DoMoveOperate(x, y, range, arrive_func, is_chongci, ignore_high_area)
	local is_chongci = is_chongci and true or false
	ignore_high_area = ignore_high_area and true or false

	local scene_logic = Scene.Instance:GetSceneLogic()
	local can_move = scene_logic:GetIsCanMove(x, y)
	if not can_move then
		return false
	end

	if self:IsJump() then
		return false
	end

	if not self.is_landed then
		return false
	end

	if x == self.logic_pos.x and y == self.logic_pos.y then
		return false
	end

	if not self:CanDoMove() then
		if self:IsAtkPlaying() then
			self.move_oper_cache = {x = x, y = y, range = range, arrive_func = arrive_func}
		end
		return false
	end

	-- 暂时屏蔽飞天的时候寻路逻辑
	-- if not self:GetIsFlying() then
	-- 	x, y = AStarFindWay:GetAroundVaildXY(x, y, 3)
	-- 	x, y = AStarFindWay:GetLineEndXY2(self.logic_pos.x, self.logic_pos.y, x, y)
	-- end


	local move_x, move_y = x, y
	-- 暂时屏蔽飞天的时候寻路逻辑
	-- if not self:GetIsFlying() and not AStarFindWay:IsWayLine(self.logic_pos.x, self.logic_pos.y, x, y) then
	if not AStarFindWay:IsWayLine(self.logic_pos.x, self.logic_pos.y, x, y, ignore_high_area) then
		if is_chongci and not AStarFindWay:IsBlock(x, y) then
			--对方在非障碍区就冲过去
			self.path_pos_index = 1
			self.path_pos_list = {{x = move_x, y = move_y}}
		else
			-- 先判断寻路的起始点是否为Block
			-- 如果是block，则从周围2格之内找一个合法的起始点
			local logic_x, logic_y = self.logic_pos.x, self.logic_pos.y
			if AStarFindWay:IsBlock(logic_x, logic_y, ignore_high_area) then
				logic_x, logic_y = AStarFindWay:FindNearestValidPoint(logic_x, logic_y, 2)
			end

			if not AStarFindWay:FindWay(u3d.vec2(logic_x, logic_y), u3d.vec2(x, y), ignore_high_area) then
				-- 判断如果是在可禁止行走但可寻路的区域里的时候就让玩家移动出去
				-- local cell_type = AStarFindWay:GetCellType(self.logic_pos.x, self.logic_pos.y)
				-- if cell_type ~= GridCellType.ObstacleWay then
					GlobalEventSystem:Fire(ObjectEventType.CAN_NOT_FIND_THE_WAY)
					if AStarFindWay:IsHighArea(self.logic_pos.x, self.logic_pos.y) then
						SysMsgCtrl.Instance:ErrorRemind(Language.QingGong.CanNotFindWay)
					end
					return
				-- end
			end

			self.path_pos_list = AStarFindWay:GenerateInflexPoint(range)
			self.path_pos_index = 1
			if not self.path_pos_list or #self.path_pos_list == 0 then
				GlobalEventSystem:Fire(ObjectEventType.CAN_NOT_FIND_THE_WAY)
				return
			end
			-- 找到通往目标的路径时find_count设置为0
			GuajiCtrl.Instance:SetMaxFindCount(0)
			move_x = self.path_pos_list[1].x
			move_y = self.path_pos_list[1].y

			-- 寻路从坐标格子中心那个世界坐标开始寻，地图坐标格子从0.5改成1单位，有时候会原地踏步或者往回走，所以直接从第二个点开始
			if self.logic_pos.x == move_x and self.logic_pos.y == move_y then
				move_x = self.path_pos_list[2] and self.path_pos_list[2].x or self.path_pos_list[1].x
				move_y = self.path_pos_list[2] and self.path_pos_list[2].y or self.path_pos_list[1].y
				if self.path_pos_list[2] then
					self.path_pos_index = 2
				end
			end
			GuajiCtrl.Instance:SetMaxFindCount(0)
		end

	else
		self.path_pos_index = 1
		self.path_pos_list = {{x = move_x, y = move_y}}
		GuajiCtrl.Instance:SetMaxFindCount(0)
	end

	if arrive_func then
		self.arrive_func = arrive_func
	end
	self:ChangeChongCi(is_chongci)
	self.is_chongci = is_chongci
	Role.DoMove(self, move_x, move_y, is_chongci)
	self:SendMoveReq()
end

function MainRole:GetIsChongci()
	return self.is_chongci
end

local skill_can_move = false
function MainRole:CanDoMove()
	skill_can_move = SkillData.GetSkillCanMove(self.last_skill_id)
	if self:IsRealDead() or self:IsDead() 
		or (self:IsAtk() and not skill_can_move) 
		or self.is_scene_action_state 
		or self.is_special_move or self:IsJump() 
		or self.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 
		or (self:IsAtkPlaying() and not skill_can_move) 
		or CgManager.Instance:IsCgIng() 
		or self:IsMultiMountPartner() then

		return false
	end

	-- Buff 效果判断
	if self:IsDingShen() or self:IsXuanYun() or self:IsBingDong() then
		-- print_log("You can't move now. ")
		return false
	end
	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic then
		return scene_logic:CanMove()
	end
	return true
end

-- 主角在寻路出的路径如果拐点相距很短时，会出现人物“抖向”问题
function MainRole:IsNeedChangeDirOnDoMove(pos_x, pos_y)
	if #self.path_pos_list > 1 then
		-- local now_pos = self.draw_obj:GetRootPosition()
		local dis = GameMath.GetDistance(self.logic_pos.x, self.logic_pos.y, pos_x, pos_y, false)
		if dis < 4 then
			return false
		end
	end
	return true
end

function MainRole:MoveEnd()
	MainUICtrl.Instance:FlushView("guaji_manual_state")
	local pos = self.path_pos_list[self.path_pos_index + 1]
	if nil ~= pos then
		self.path_pos_index = self.path_pos_index + 1
		Role.DoMove(self, pos.x, pos.y)
		self:SendMoveReq()
		return false
	end
	return true
end

function MainRole:EnterStateMove()
	Role.EnterStateMove(self)
	if self.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 and self.vo.move_mode_param > 0 then
		if self.target_x == nil or self.target_y == nil then
			return
		end
		Role.DoMove(self, self.target_x, self.target_y)
		self:SendMoveReq()
	end
	GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_MOVE_START)
end

function MainRole:UpdateStateMove(elapse_time)
	Role.UpdateStateMove(self, elapse_time)
	if MainUIData.IsSetCameraZoom then
		Scene.Instance:UpdateCameraDistance()
	end
end

function MainRole:QuitStateMove()
	if not self.is_special_move and not self:IsSpecialJump() then
		-- 如果停止点在阻挡里，前后一格找一个可以站立的点
		if AStarFindWay:IsBlock(self.logic_pos.x, self.logic_pos.y, true) then
			for _, v in pairs({1, -1}) do
				local mov_dir = u3d.v2Mul(self.move_dir, v)
				local x, y = GameMapHelper.WorldToLogic(self.real_pos.x + mov_dir.x, self.real_pos.y + mov_dir.y)
				if not AStarFindWay:IsBlock(x, y, true) then
					self:SetLogicPosData(x, y)
					break
				end
			end
		end
		self:SendMoveReq(0)
	end
	Role.QuitStateMove(self)
	self:ChangeChongCi(false)
	if self.arrive_func then
		local arrive_func = self.arrive_func
		self.arrive_func = nil
		arrive_func()
	end
	if self.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 and self.vo.move_mode_param > 0 then
		if self.jump_call_back then
			self.jump_call_back()
			self.jump_call_back = nil
		end
	end
	GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_MOVE_END)
end

function MainRole:ClearPathInfo()
	self.path_pos_list = {}
	self.path_pos_index = 0
end

-- 跳跃
function MainRole:OnJumpStart()
	if self:IsDeleted() or self.target_point == nil then
		return
	end
	if self.target_x == nil or self.target_y == nil then
		return
	end

	-- 关闭轻功
	self:QingGongEnable(false)

	local interval = 0.14
	self:ShowGhost(0, self.ghost_time / interval, 7, interval)

	self:RemoveModel(SceneObjPart.Mount)
	self:RemoveModel(SceneObjPart.FightMount)

	local x, y = self:GetLogicPos()
	local jump_speed_factor = 1
	local distance = u3d.v2Length({x = self.target_x - x, y = self.target_y - y}, true)
	local jump_time = math.max(self.jump_time - self.jump_end_time, 0.1)
	if self.jump_tong_bu == 1 then
		local speed = self:GetMoveSpeed()
		if speed == 0 then
			speed = 0.01
		end
		local time = distance / speed * 0.7
		if time == 0 then
			time = 0.01
		end
		jump_speed_factor = 0.8 * 1 / time
	else
		if jump_time == nil or jump_time == 0 then
			jump_time = 1
		end
		self.jump_speed = distance / jump_time

		 -- 人物实际落地帧数在22帧（共30帧）0.7 = 22 / 30
		jump_speed_factor = self.jump_animation_speed
	end

	MoveCache.task_id = 0
	Role.DoMove(self, self.target_x, self.target_y)

	if not self:IsSpecialJump() then
		self:SendMoveReq()
	end

	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	if self.vo.mount_appeid ~= nil and self.vo.mount_appeid > 0 then
		main_part:SetFloat("jump_speed", jump_speed_factor)
		local mount_part = self.draw_obj:GetPart(SceneObjPart.Mount)
		if mount_part then
			mount_part:SetFloat("jump_speed", jump_speed_factor)
		end
	else
		local value = 1
		-- 变身状态
		if self.vo.bianshen_param == BIANSHEN_EFEECT_APPEARANCE.APPEARANCE_DATI_XIAOTU then
			value = 2
		elseif self.vo.bianshen_param == BIANSHEN_EFEECT_APPEARANCE.APPEARANCE_DATI_XIAOZHU then
			value = 2.67
		elseif self.vo.bianshen_param == BIANSHEN_EFEECT_APPEARANCE.APPEARANCE_YIZHANDAODI then		-- 一战到底小树人
			value = 2.67
		end
		main_part:SetFloat("jump_speed", value * jump_speed_factor)
	end

	if not IsNil(MainCamera) then
		local camera_follow = MainCamera:GetComponentInParent(typeof(CameraFollow))
		if self.jump_camera_fov ~= nil and self.jump_camera_fov ~= 0 then
			local sequence = DG.Tweening.DOTween.Sequence()

			sequence:Append(camera_follow:DOFieldOfView(self.jump_camera_fov, (jump_time - 0.5) / 2))
			sequence:Append(camera_follow:DOFieldOfView(0, (jump_time - 0.5) / 2))
		end

		if self.jump_camera_rotation ~= nil and self.jump_camera_rotation ~= 0 then
			local sequence = DG.Tweening.DOTween.Sequence()

			if self.jump_target_vo ~= nil and self.jump_target_vo.target_vo ~= nil then
				sequence:Append(camera_follow:DoRotation(self.jump_camera_rotation, jump_time - 0.5))
			else
				if self.jump_camera_rotation ~= 0 then
					sequence:Append(camera_follow:DoRotation(self.jump_camera_rotation, (jump_time - 0.5) / 2))
					sequence:Append(camera_follow:DoRotation(0, (jump_time - 0.5) / 2))
				else
					sequence:Append(camera_follow:DoRotation(0, jump_time - 0.5))
				end
			end
		end
	end

	self:ShowJumpTrailRenderer()
end

-- 跳跃
function MainRole:SetJump(state)
	Character.SetJump(self, state)
	if state then
		local part = self.draw_obj:GetPart(SceneObjPart.Main)
		part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Idle)
		self:StopHug()
	end
end

-- 跳跃
function MainRole:DoJump(move_mode_param)
	Role.DoJump(self, move_mode_param)
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Idle)
	self:StopHug()

	self:CancelJumpQuest()
	self.jump_delay_time = GlobalTimerQuest:AddDelayTimer(function ()
		self:SetJump(false)
		self.vo.move_mode = MOVE_MODE.MOVE_MODE_NORMAL
	end, 3)
end

function MainRole:DoJump2(move_mode_param)
	Role.DoJump2(self, move_mode_param)
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Idle)
	self:StopHug()
end

function MainRole:CancelJumpQuest()
	if self.jump_delay_time then
		GlobalTimerQuest:CancelQuest(self.jump_delay_time)
		self.jump_delay_time = nil
	end
end

function MainRole:OnJumpEnd()
	self:CancelJumpQuest()
	Role.OnJumpEnd(self)
	if self.jump_call_back then
		self.jump_call_back()
		self.jump_call_back = nil
	end
	self:HideJumpTrailRenderer()
	if self:CanHug() then
		local part = self.draw_obj:GetPart(SceneObjPart.Main)
		part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Hug)
		self:DoHug()
	end

	-- MainCameraFollow:SetIsFlyState(false)
end

function MainRole:JumpTo(point_vo, target_point, next_point, call_back)
	if target_point == nil then
		print_error("target_point == nil")
		return
	end
	if self:GetIsFlying() then
		return
	end

	local value = BianShenData.Instance:GetCurUseSeq()
	if value ~= -1  then
		TipsCtrl.Instance:ShowSystemMsg(Language.BianShen.BianShenStanteTip)
		return
	end

	if self.vo.task_appearn_param_1 > 0 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.StateNoJump)
		return
	end
	self:ToJumpPath()
	self.vo.move_mode = MOVE_MODE.MOVE_MODE_JUMP2
	GlobalEventSystem:Fire(OtherEventType.JUMP_STATE_CHANGE, true)
	-- 播放CG
	if point_vo.play_cg and point_vo.play_cg == 1 and not IsLowMemSystem and not CgManager.Instance:IsCgIng() then
		for k,v in pairs(point_vo.cgs) do
			if (v.prof % 10) == (self.vo.prof % 10) then
				self:RemoveModel(SceneObjPart.Mount)
				self:RemoveModel(SceneObjPart.FightMount)
				CgManager.Instance:Play(BaseCg.New(v.bundle_name, v.asset_name), function()
					local scene_key = PlayerData.Instance:GetAttr("scene_key") or 0
					Scene.SendSyncJump(Scene.Instance:GetSceneId(), v.position.x, v.position.y, scene_key)
					self:SetLogicPos(v.position.x, v.position.y)
					local game_obj = self:GetDrawObj():GetRoot()
					game_obj.transform.localRotation = Quaternion.Euler(0, v.rotation, 0)

					if self.fight_mount_res_id ~= nil and self.fight_mount_res_id > 0 then
						self:ChangeModel(SceneObjPart.FightMount, ResPath.GetFightMountModel(self.fight_mount_res_id))
					elseif self.mount_res_id ~= nil and self.mount_res_id > 0 and not self:IsMultiMountPartner() then
						if self.is_sit_mount == 1 then
							self:ChangeModel(SceneObjPart.FightMount, ResPath.GetMountModel(self.mount_res_id))
						else
							self:ChangeModel(SceneObjPart.Mount, ResPath.GetMountModel(self.mount_res_id))
						end
					end

					self:SetJump(false)
					self.vo.move_mode = MOVE_MODE.MOVE_MODE_NORMAL
					GlobalEventSystem:Fire(OtherEventType.JUMP_STATE_CHANGE, false)
				end, nil, true)
				return
			end
		end
	end
	self.vo.jump_factor = 1
	if point_vo.jump_speed and point_vo.jump_speed > 4 then
		point_vo.jump_speed = 4
	end
	self.vo.jump_factor = point_vo.jump_speed
	self.jump_call_back = call_back
	self.target_point = target_point
	self.next_point = next_point
	self.target_x = target_point.vo.pos_x
	self.target_y = target_point.vo.pos_y
	self.jump_tong_bu = point_vo.jump_tong_bu
	self.jump_time = point_vo.jump_time
	self.vo.move_mode = MOVE_MODE.MOVE_MODE_JUMP2
	self.jump_camera_fov = point_vo.camera_fov
	self.jump_camera_rotation = point_vo.camera_rotation
	self.jump_target_vo = point_vo.target_vo

	self.ghost_time = point_vo.jump_time

	if point_vo.jump_type == 0 then
		if point_vo.jump_tong_bu == 0 then
			self.is_special_jump = true
		else
			Scene.SendMoveMode(MOVE_MODE.MOVE_MODE_JUMP2)
		end
		local jump_act = point_vo.jump_act
		if jump_act == 0 then
			if math.random() > 0.5 then
				jump_act = 1
			else
				jump_act = 2
			end
		end
		
		local total_time = PlayerData.Instance:GetJumpTime(jump_act)
		if jump_act == 1 then
			self.jump_end_time = 0.2
		elseif jump_act == 2 then
			self.jump_end_time = 0.0
		elseif jump_act == 3 then
			self.jump_end_time = 0.0
		end
		self.jump_time = point_vo.jump_time
		self.jump_animation_speed = total_time / point_vo.jump_time
		self.vo.jump_act = jump_act
		self:DoJump()
	elseif point_vo.jump_type == 1 then
		Scene.SendMoveMode(MOVE_MODE.MOVE_MODE_JUMP2, point_vo.air_craft_id)
		self.vo.move_mode_param = point_vo.air_craft_id
		FightMountCtrl.Instance:SendGoonFightMountReq(0)
		MountCtrl.Instance:SendGoonMountReq(0)
		self:DoJump(point_vo.air_craft_id)
	end

	if self.move_oper_cache2 then
		for k,v in pairs(self.move_oper_cache2.jumppoint_obj_list) do
			if v.vo.id == point_vo.id then
				self.move_oper_cache2 = nil
				self:ClearPathInfo()
				break
			end
		end
	end
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	if next_point then
		part:SetBool("jump_end", false)
	else
		part:SetBool("jump_end", true)
	end
end

-- 跳跃时的路线
function MainRole:ToJumpPath()
	local path_count = #self.path_pos_list
	if path_count > 1 then
		local x = self.path_pos_list[path_count].x
		local y = self.path_pos_list[path_count].y
		local jumppoint_obj_list = Scene.Instance:FindJumpPoint(x, y)
		self.move_oper_cache2 = {x = x, y = y, range = 0, arrive_func = self.arrive_func, jumppoint_obj_list = jumppoint_obj_list}
		self.arrive_func = nil
		self:ClearPathInfo()
	end
end

function MainRole:OnAttackPlayEnd()
	Role.OnAttackPlayEnd(self)

	if self.move_oper_cache ~= nil then
		local cache = self.move_oper_cache
		self.move_oper_cache = nil
		self:DoMoveOperate(cache.x, cache.y, cache.range, cache.arrive_func)
	end
end

function MainRole:SendMoveReq(distance)
	if self.is_only_client_move then
		return
	end

	local dir = math.atan2(self.move_dir.y, self.move_dir.x)
	distance = distance or self.move_total_distance / Config.SCENE_TILE_WIDTH
	Scene.SendMoveReq(dir, self.logic_pos.x, self.logic_pos.y, distance, 0, self.is_chongci and 1 or 0)
end

function MainRole:SetIsOnlyClintMove(is_only_client_move)
	self.is_only_client_move = is_only_client_move
end

function MainRole:SetAttackParam(is_specialskill)
	self.is_specialskill = is_specialskill
end

function MainRole:DoAttack(skill_id, target_x, target_y, target_obj_id, target_type)
	self.arrive_func = nil
	if not self:CanAttack() then return end

	Scene.Instance:GetSceneLogic():StopAutoGather()
	Role.DoAttack(self, skill_id, target_x, target_y, target_obj_id, target_type)
end

function MainRole:CanAttack()
	if self:IsRealDead() or self:IsJump() 
		or self.is_scene_action_state 
		or self.task_appearn_can_not_attack 
		or self.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 
		or self:IsBianxingFool() or self:IsXuanYun() or self:IsDingShen() 
		or CgManager.Instance:IsCgIng() 
		or self:IsMultiMountPartner()
		or self:IsBingDong() then
		return false
	end

	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic then
		return scene_logic:CanMove()
	end

	return true
end

local skill_obj = nil
function MainRole:OnAnimatorBegin()
	Role.OnAnimatorBegin(self)
	local main_view = MainUICtrl.Instance:GetView()
	local transform = nil
	if main_view then
		local dazhao_effect = main_view:GetDaZhaoEffect()
		if dazhao_effect then
			transform = dazhao_effect.transform
		end
	end

	if transform then
		if self.anim_name == "attack4" then
			local bundle_name, asset_name = ResPath.GetUiXEffect("UI_effect_bishaji")
			EffectManager.Instance:PlayAtTransform(bundle_name, asset_name, transform, 2)
		elseif self.attack_skill_id and self.attack_skill_id ~= 111 and self.attack_skill_id ~= 211 and self.attack_skill_id ~= 311 and self.attack_skill_id ~= 411 
			and not GoddessData.Instance:IsGoddessSkill(self.attack_skill_id) then
			local info = SkillData.GetSkillinfoConfig(self.attack_skill_id)
			local value = BianShenData.Instance:GetCurUseSeq()	--神魔变身状态下不用播放这个特效
			if info and value == -1 then
				self.async_loader = self.async_loader or AllocAsyncLoader(self, "effect_skill_loader")
				local bundle_name, asset_name = ResPath.GetUiXEffect("UI_effect_skill")
				self.async_loader:Load(bundle_name, asset_name, function(obj)
					if IsNil(obj) then
						return
					end
					if IsNil(transform) then
						ResPoolMgr:Release(obj)
						return
					end
					skill_obj = obj
					skill_obj.transform:SetParent(transform, false)
					local panel = skill_obj.transform:Find("GameObject")
					local text1 = panel.transform:Find("Text1"):GetComponent(typeof(UnityEngine.UI.Text))
					local text2 = panel.transform:Find("Text2"):GetComponent(typeof(UnityEngine.UI.Text))
					if text1 and text2 then
						local name_tbl = CommonDataManager.StringToTable(info.skill_name)
						if #name_tbl > 4 then
							text1.text = name_tbl[1] .. name_tbl[2]
							text2.text = name_tbl[3] .. name_tbl[4] .. name_tbl[5]
						end
					end
					local animator = skill_obj.gameObject:GetComponent(typeof(UnityEngine.Animator))
					if animator then
						animator:WaitEvent("exit", function ()
							skill_obj = nil
							ResMgr:Destroy(obj)
						end)
					end
				end)
			end
		end
	end
	

	-- 温泉扔雪球不应该进来这段代码
	if Scene.Instance:GetSceneType() ~= SceneType.HotSpring then
		if self:IsAtk() then
			local scene_obj = self.attack_target_obj
			-- 如果对方有问题，则找个附近的攻击
			if not scene_obj or not scene_obj:IsCharacter() or scene_obj:IsRealDead() then
				-- 直接使用挂机的，会不会选择了太远的目标？
				scene_obj = GuajiCtrl.Instance:SelectAtkTarget(true)
			end

			if nil ~= scene_obj and scene_obj:IsCharacter() and not scene_obj:IsRealDead() then
				self.last_skill_id = self.attack_skill_id
				self.atk_is_hit[self.attack_skill_id] = false

				local target_robert = RobertManager.Instance:GetRobert(scene_obj:GetObjId())
				local main_role = Scene.Instance:GetMainRole()
				if nil ~= target_robert and main_role:GetObjId() ~= scene_obj:GetObjId() then -- 与机器人的战斗不通过服务器
					local attack_robert = RobertManager.Instance:GetRobert(self:GetObjId())
					RobertManager.Instance:ReqFight(attack_robert, target_robert, self.attack_skill_id, self.attack_index)
				else
					self.is_specialskill = self.is_specialskill or PlayerData.Instance.role_vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR
					self.last_skill_index = self.attack_index

					FightCtrl.SendPerformSkillReq(
						SkillData.Instance:GetRealSkillIndex(self.attack_skill_id),
						self.attack_index,
						self.attack_target_pos_x,
						self.attack_target_pos_y,
						scene_obj:GetObjId(),
						self.is_specialskill,
						self.logic_pos.x,
						self.logic_pos.y)
				end
			end
		end
	end
end

function MainRole:OnAnimatorHit()
	if self:IsAtk() then
		self.atk_is_hit[self.attack_skill_id] = true

		if self:CanAttack() then
			local info_cfg = SkillData.GetSkillinfoConfig(self.attack_skill_id)
			if info_cfg ~= nil then
				if info_cfg.hit_count > 1 then
					self.attack_index = self.attack_index + 1
					if self.attack_index > info_cfg.hit_count then
						self.attack_index = 1
					end
				end
			end
		end
	end

	Role.OnAnimatorHit(self)
end

function MainRole:OnAnimatorEnd()
	if self:IsAtk() then
		self.last_atk_end_time = Status.NowTime
	end
	Role.OnAnimatorEnd(self)
end

function MainRole:OnAttackHit(attack_skill_id, attack_target_obj)
	Role.OnAttackHit(self, attack_skill_id, attack_target_obj)

	local scene_obj = attack_target_obj
	if nil ~= scene_obj and scene_obj:IsCharacter() then
		local deliverer = Scene.Instance:GetObj(self.vo.obj_id)
		scene_obj:DoBeHitShow(
			deliverer, attack_skill_id, scene_obj:GetObjId())
	end
end

function MainRole:GetLastSkillId()
	return self.last_skill_id
end

function MainRole:AtkIsHit(skill_id)
	return self.atk_is_hit and self.atk_is_hit[skill_id]
end

function MainRole:GetLastAtkEndTime()
	return self.last_atk_end_time
end

function MainRole:EnterStateDead()
	Role.EnterStateDead(self)
	if self.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		self.vo.move_mode = MOVE_MODE.MOVE_MODE_NORMAL
		GlobalEventSystem:Fire(OtherEventType.JUMP_STATE_CHANGE, false)
		self:ClearJumpCache()
	end
	MountCtrl.Instance:SendGoonMountReq(0)
	GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_DEAD, self)
end

function MainRole:OnRealive()
	Role.OnRealive(self)
	if Scene.Instance then
		Scene.Instance:GetSceneLogic():OnMainRoleRealive()
	end
	GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_REALIVE, self)
end

function MainRole:DoStand()
	Role.DoStand(self)
	ReviveCtrl.Instance:OnReviveClose()
end

local old_value = nil
function MainRole:SetAttr(key, value)
	old_value = self.vo[key]
	PlayerData.Instance:SetAttr(key, value)
	Role.SetAttr(self, key, value)
	if key == "level" then
		if old_value == nil or value > old_value then
			self:AddBuff(BUFF_TYPE.UP_LEVEL)
			local audio_config = AudioData.Instance:GetAudioConfig()
			if audio_config then
				AudioManager.PlayAndForget("audios/sfxs/other", audio_config.other[1].Level_up)
			end
			self.add_level_eff_time = Status.NowTime
		end
		GlobalEventSystem:Fire(ObjectEventType.LEVEL_CHANGE, self, value)
		RemindManager.Instance:Fire(RemindName.Rank)
		-- self:CheckQingGong()
	end
	if key == "move_speed" then
		if self:IsMove() then
			if self.path_pos_list and #self.path_pos_list > 0 then
				local pos = self.path_pos_list[self.path_pos_index]
				if nil ~= pos then
					Role.DoMove(self, pos.x, pos.y)
					self:SendMoveReq()
				end
			end
		end
	end
	if key == "bianshen_param" then
		if value > 0 then
			if self.vo.mount_appeid and self.vo.mount_appeid > 0 then
				MountCtrl.Instance:SendGoonMountReq(0)
			end
			if self.vo.fight_mount_appeid and self.vo.fight_mount_appeid > 0 then
				FightMountCtrl.Instance:SendGoonFightMountReq(0)
			end
		end
	elseif key == "task_appearn" then
		if self.vo.task_appearn > 0 and self.vo.task_appearn_param_1 > 0 then
			self.task_appearn_can_not_attack = true
			self.is_landed = true
			if self.vo.task_appearn ~= CHANGE_MODE_TASK_TYPE.CHANGE_MODE_TASK_TYPE_FLY then
				MountCtrl.Instance:SendGoonMountReq(0)
			end
			FightMountCtrl.Instance:SendGoonFightMountReq(0)
		else
			self.task_appearn_can_not_attack = false
		end

		if self.vo.task_appearn == CHANGE_MODE_TASK_TYPE.CHANGE_MODE_TASK_TYPE_FLY then
			if self.vo.task_appearn_param_1 > 0 then
				TaskCtrl.Instance:DoTask(self.vo.task_appearn_param_1)
				-- 因为服务端下发的数据有限，只能让服务端发个任务ID过来客户端自己取数据
				local task_cfg = TaskData.Instance:GetTaskConfig(self.vo.task_appearn_param_1)
				if task_cfg then
					if task_cfg.accept_op == TASK_ACCEPT_OP.TASK_ACCEPT_OP_CLIENT_PARAM then
						if "" ~= task_cfg.a_param1 and "" ~= task_cfg.a_param2 then
							self:SetFlyMaxHeight(task_cfg.a_param2)
							self.fly_task_range = task_cfg.a_param1
							self.is_fly_task_update = true
						end
						local npc_info = task_cfg.commit_npc
						local end_x = 0
						local end_y = 0
						if Scene.Instance:GetSceneId() == npc_info.scene then
							end_x = npc_info.x
							end_y = npc_info.y
						end
						if (end_x == 0 and end_y == 0) or not self:FlyTaskTesting(end_x, end_y) then
							self:StartFlyingUp()
							Scene.Instance:OnShieldRolePet(false)
							self:SetLingChongVisible(false)
							self:SetGoddessVisible(false)
							self.fly_task_is_hide = true
							MainUICtrl.Instance:FlushView("fly_task_is_hide", {self.fly_task_is_hide})
							RobertMgr.Instance:ShieldAllRobert()
							-- if self.vo.task_appearn_param_1 == 510 then 	--第一次飞行出引导特效先写死测试	
								local main_view = MainUICtrl.Instance:GetView()
								local transform = nil
								if main_view then
									local dazhao_effect = main_view:GetDaZhaoEffect()
									if dazhao_effect then
										transform = dazhao_effect.transform
									end
								end
								local bundle_name, asset_name = ResPath.GetUiXEffect("UI_gesture_slide")
								EffectManager.Instance:PlayAtTransform(bundle_name, asset_name, transform, 4)
							-- end
						end
					end
				end
			else
				self.is_fly_task_update = false
				Scene.Instance:OnShieldRolePet(true)
				self:SetLingChongVisible(true)
				self:SetGoddessVisible(not SettingData.Instance:GetSettingData(SETTING_TYPE.CLOSE_GODDESS) or false)
			end
		end

		if self.vo.task_appearn > 0 and self.vo.task_appearn < CHANGE_MODE_TASK_TYPE.TALK_IMAGE and self.vo.task_appearn_param_1 > 0 then
			GlobalEventSystem:Fire(SettingEventType.MAIN_CAMERA_MODE_CHANGE, 2, self.vo.task_appearn)
			if self.vo.task_appearn == CHANGE_MODE_TASK_TYPE.TALK_TO_NPC then
				self:SetHugNpcActive(false)
			end
		else
			GlobalEventSystem:Fire(SettingEventType.MAIN_CAMERA_MODE_CHANGE)
			self:SetHugNpcActive(true)
		end
	end
end

-- 用于检测飞行下降的距离是多少
function MainRole:OnFlyTaskUpdate()
	if self.is_fly_task_update then
		local end_x, end_y = self:GetMoveEndPos()
		if self:FlyTaskTesting(end_x, end_y) then
			self.is_fly_task_update = false
			self:StartFlyingDown()
		-- else
		-- 	if self.check_fly_task_update_time <= Status.NowTime then
		-- 		self.check_fly_task_update_time = Status.NowTime + 3
		-- 		if self.vo.task_appearn == CHANGE_MODE_TASK_TYPE.CHANGE_MODE_TASK_TYPE_FLY then
		-- 			if self.vo.task_appearn_param_1 > 0 then
		-- 				TaskCtrl.Instance:DoTask(self.vo.task_appearn_param_1)
		-- 			end
		-- 		end
		-- 	end
		end
	end
end

--将场景上所抱隐藏或显示
function MainRole:SetHugNpcActive(value)
	if not CgManager.Instance:IsCgIng() then
		if self.vo.task_appearn == CHANGE_MODE_TASK_TYPE.TALK_TO_NPC and not value then
			Scene.Instance:ShieldNpc(self.npc_id)
		else
			Scene.Instance:UnShieldNpc(self.npc_id)
		end
	end
end

function MainRole:GetPathPosList()
	return self.path_pos_list
end

function MainRole:GetPathPosIndex()
	return self.path_pos_index
end

function MainRole:GetMoveEndPos()
	local path_count = #self.path_pos_list
	if path_count >= 1 then
		local x = self.path_pos_list[path_count].x
		local y = self.path_pos_list[path_count].y
		return x, y
	end
	return 0, 0
end

function MainRole:StopMove()
	self.arrive_func = nil
	self.move_oper_cache = nil
	self:ClearPathInfo()
	if self:IsMove() then
		self:ChangeToCommonState()
	end
end

function MainRole:ContinuePath()
	self.is_special_jump = false
	if MoveCache.task_id and MoveCache.task_id > 0 then
		GuajiCache.monster_id = 0
		TaskCtrl.Instance:DoTask(MoveCache.task_id)
		self:ClearJumpCache()
		return
	end
	if self.move_oper_cache2 then
		local cache = self.move_oper_cache2
		self.move_oper_cache2 = nil
		self.jump_call_back = nil
		GlobalTimerQuest:AddDelayTimer(function() self:DoMoveOperate(cache.x, cache.y, cache.range, cache.arrive_func) end, 0.1)
	end
end

function MainRole:ClearJumpCache()
	self.jump_call_back = nil
	self.move_oper_cache2 = nil
end

function MainRole:IsSpecialJump()
	return self.is_special_jump
end

function MainRole:GetMoveSpeed()
	if self.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 and self.jump_tong_bu == 0 and self.jump_speed and self.jump_speed > 0 then
		return self.jump_speed
	else
		local speed = Scene.ServerSpeedToClient(self.vo.move_speed) + self.special_speed
		if self.is_jump or self.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
			if self.vo.jump_factor then
				speed = self.vo.jump_factor * speed
			else
				speed = 1.8 * speed
			end
		end
		local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
		local obj = main_part:GetObj()
		if obj and not IsNil(obj.gameObject) and obj.animator then
			if obj.animator:GetBool("fight") then
				speed = speed * 1.055
			end
			-- 冲刺状态
			if obj.animator:GetLayerWeight(ANIMATOR_PARAM.CHONGCI_LAYER) > 0 then
				speed = COMMON_CONSTS.CHONGCI_SPEED
			end
		end
		return speed
	end
end

function MainRole:GetLastSkillIndex()
	return self.last_skill_index
end

function MainRole:GetTotalStandTime()
	return self.total_stand_time
end

function MainRole:ShowJumpTrailRenderer()
	local renderer1, renderer2 = self:FindTrailRenderer()
	if nil == renderer1 or nil == renderer2 then
		return
	end

	local function StartShow()
		self.trail_renderer1 = renderer1.gameObject:AddComponent(typeof(UnityEngine.TrailRenderer))
		if self.trail_renderer1 then
			self.trail_renderer1.material = self.material
			self.trail_renderer1.time = 0.32
			self.trail_renderer1.startWidth = 1
			self.trail_renderer1.endWidth = 1
		end
		self.trail_renderer2 = renderer2.gameObject:AddComponent(typeof(UnityEngine.TrailRenderer))
		if self.trail_renderer2 then
			self.trail_renderer2.material = self.material
			self.trail_renderer2.time = 0.32
			self.trail_renderer2.startWidth = 1
			self.trail_renderer2.endWidth = 1
		end
	end

	if nil == self.material then
		ResPoolMgr:GetMaterial("effects/materials", MATERIAL_ID_LIST[self.vo.prof % 10], function(material)
			if nil == material then
				return
			end

			self.material = material
			StartShow()
		end)
	else
		StartShow()
	end
end

function MainRole:HideJumpTrailRenderer()
	if self.trail_renderer1 then
		ResMgr:Destroy(self.trail_renderer1)
		self.trail_renderer1 = nil
	end
	if self.trail_renderer2 then
		ResMgr:Destroy(self.trail_renderer2)
		self.trail_renderer2 = nil
	end
end

function MainRole:FindTrailRenderer()
	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	local obj = main_part:GetAttachPoint(AttachPoint.BuffMiddle)
	if nil ~= obj and not IsNil(obj.gameObject) then
		local renderer1 = obj.transform:Find("JumpTrailRenderer1")
		local renderer2 = obj.transform:Find("JumpTrailRenderer2")
		return renderer1, renderer2
	end
end

function MainRole:SetMountOtherObjId(mount_other_objid)
	Role.SetMountOtherObjId(self, mount_other_objid)
	self:UpdateCameraFollowTarget(true)
end

function MainRole:CancelCameraUpdateTimer()
	if self.delay_update_camera_target_timer then
		GlobalTimerQuest:CancelQuest(self.delay_update_camera_target_timer)
		self.delay_update_camera_target_timer = nil
	end
end

function MainRole:UpdateCameraFollowTarget(immediate)
	if IsNil(MainCameraFollow) then
		print_log("The main camera does not have CameraFollow component.")
		return
	end
	
	self:CancelCameraUpdateTimer()
	self.delay_delay_update_camera_target_timer = GlobalTimerQuest:AddDelayTimer(function () 
		if not IsNil(MainCameraFollow) and not self:IsDeleted() then
			local target_point = self:GetRoot() and self:GetRoot().transform or nil
			local owner_role = self:GetMountOwnerRole()
			local point
			if owner_role then
				local height = owner_role:GetLookAtPointHeight()
				point = owner_role:GetDrawObj():GetLookAtPoint(height)
			elseif 0 <= BianShenData.Instance:GetCurUseSeq() then		-- 神魔获取高度
				local height = self:GetLookAtPointHeight(AttachPoint.BuffMiddle)
				point = self.draw_obj:GetLookAtPoint(height)
			else
				local height = self:GetLookAtPointHeight()
				point = self.draw_obj:GetLookAtPoint(height)
			end
			target_point = point or target_point
			
			MainCameraFollow.TargetOffset = Vector3.zero
			MainCameraFollow.Target = target_point
			if immediate then
				MainCameraFollow:SyncImmediate()
			end
		end
	end, 0.1)
end

function MainRole:OnModelLoaded(part, obj)
	Role.OnModelLoaded(self, part, obj)
	if part == SceneObjPart.Main then
		if nil ~= CharacterGhost then
			if self.character_ghost then
				self.character_ghost:CloseCurGhostList()
			end
			local scene_obj_layer = GameObject.Find("GameRoot/SceneObjLayer").transform
			self.character_ghost = CharacterGhost.Bind(obj.gameObject)
			if self.character_ghost then
				self.character_ghost.Root = scene_obj_layer
				local mesh_renderers = obj:GetComponentsInChildren(typeof(UnityEngine.SkinnedMeshRenderer))
				local material = ResPreload["role_ghost_" .. (self.vo.prof % 10)]
				self.character_ghost.Material = material
				self.character_ghost:SetSpeedFactor(3)
			end
		end

		self:UpdateCameraFollowTarget()
		if self.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
			local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
			if self.jump_name and self.jump_normalized_time then
				main_part:Play(self.jump_name, ANIMATOR_PARAM.BASE_LAYER, self.jump_normalized_time)
				self.jump_name = nil
				self.jump_normalized_time = nil
			end
		end
	end

	if part == SceneObjPart.Mount or part == SceneObjPart.FightMount then
		self:UpdateCameraFollowTarget()
	end
end

function MainRole:OnModelRemove(part, obj)
	Role.OnModelRemove(part, obj)
	if part == SceneObjPart.Mount or part == SceneObjPart.FightMount then
		self:UpdateCameraFollowTarget()
	end

	if part == SceneObjPart.Main then
		-- 如果在跳跃中换角色模型，会使Animator的状态丢失，导致卡在跳跃点
		-- 所以在切换模型时记录Animator的状态，等模型加载完成时还原回去
		if self.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
			local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
			local animation_info = main_part:GetAnimationInfo(ANIMATOR_PARAM.BASE_LAYER)
			if animation_info then
				self.jump_name = animation_info.shortNameHash
				self.jump_normalized_time = animation_info.normalizedTime
			end
		end
	end
end

function MainRole:ShowGhost(_type, maxGhostNum, maxConcurrentGhostNum, timeInterval)
	_type = _type or 0
	maxGhostNum = maxGhostNum or 10
	maxConcurrentGhostNum = maxConcurrentGhostNum or 8
	timeInterval = timeInterval or 0.1
	if self.character_ghost then
		self.character_ghost:ShowGhost(_type, maxGhostNum, maxConcurrentGhostNum, timeInterval)
	end
end

function MainRole:StopGhost(time)
	self.chongci_end_timer = Status.NowTime + 0.5
	time = time or 0
	if self.character_ghost then
		self.character_ghost:Stop(time)
	end
end

function MainRole:IsMarriage()
	if self.vo.lover_uid ~= 0 then
		return true
	else
		return false
	end
end

function MainRole:EnterFightState()
	-- 记录进入战斗状态前的坐骑状态
	-- 1：普通坐骑 2：战斗坐骑
	if self.vo.mount_appeid and self.vo.mount_appeid > 0 then
		self.last_mount_state = 1
	elseif self.vo.fight_mount_appeid and self.vo.fight_mount_appeid > 0 then
		self.last_mount_state = 2
	else
		self.last_mount_state = 0
	end
	MountCtrl.Instance:SendGoonMountReq(0)
	if nil ~= self.vo.mount_appeid and self.vo.mount_appeid > 0 then
		FightMountCtrl.Instance:SendGoonFightMountReq(1)
	end
	Role.EnterFightState(self)

	if FIGHTSTATE_CAMERA and CAMERA_TYPE == CameraType.Free then
		if Scene.Instance:GetSceneType() == SceneType.HotSpring then
			return
		end

		if MainCameraFollow and not self.is_enter_fight_camera then
			self.is_enter_fight_camera = true
			self.fightstate_camera_param = MainCameraFollow.transform.localEulerAngles.x
			if not CgManager.Instance:IsCgIng() then
				Scene.Instance:FlushFightCamera()
			end
		end
	end
end

function MainRole:LeaveFightState()
	-- 脱战后恢复战斗前的坐骑状态
	if self.last_mount_state == 1 then
		FightMountCtrl.Instance:SendGoonFightMountReq(0)
		MountCtrl.Instance:SendGoonMountReq(1)
	elseif self.last_mount_state == 2 then
		MountCtrl.Instance:SendGoonMountReq(0)
		FightMountCtrl.Instance:SendGoonFightMountReq(1)
	end
	Role.LeaveFightState(self)

	if FIGHTSTATE_CAMERA and CAMERA_TYPE == CameraType.Free then
		if self.fightstate_camera_param and self.is_enter_fight_camera then
			self.is_enter_fight_camera = false
			if not CgManager.Instance:IsCgIng() then
				Scene.Instance:FlushFightCamera(self.fightstate_camera_param)
			end
		end
	end
end

function MainRole:ChangeChongCi(state)
	self.chongci_end_timer = nil
	Role.ChangeChongCi(self, state)
	if state then
		self:ShowGhost(1, 50, 5, 0.02)
	elseif self.is_chongci then
		self:StopGhost()
	end
end

----------------------------------------------------
-- 主角飞行逻辑
----------------------------------------------------
function MainRole:StartFlyingUp()
	if self.flying_process == FLYING_PROCESS_TYPE.FLYING_UP then return end
	Role.StartFlyingUp(self)
	-- MainCameraFollow:SetIsFlyState(true)
	self:CheckQingGong()
	-- 屏蔽飞行不请求了。
	-- Scene.SendMoveMode(MOVE_MODE.MOVE_MODE_FLY)
end

function MainRole:StartFlyingDown()
	if self.flying_process == FLYING_PROCESS_TYPE.FLYING_DOWN then return end
	Role.StartFlyingDown(self)
	self:CheckQingGong()
	-- 屏蔽降落不请求了。
	-- Scene.SendMoveMode(MOVE_MODE.MOVE_MODE_NORMAL)
end

function MainRole:OnFlyingUpEnd()
	if self.flying_process == FLYING_PROCESS_TYPE.FLYING_IN_MAX_HEIGHT then return end
	Role.OnFlyingUpEnd(self)
	self:CheckQingGong()
end

function MainRole:OnFlyingDownEnd()
	if self.flying_process == FLYING_PROCESS_TYPE.NONE_FLYING then return end
	Role.OnFlyingDownEnd(self)
	-- MainCameraFollow:SetIsFlyState(false)
	self:CheckQingGong()
	if self.fly_task_is_hide then
		self.fly_task_is_hide = false
		MainUICtrl.Instance:FlushView("fly_task_is_hide", {self.fly_task_is_hide})
		RobertMgr.Instance:UnShieldAllRobert()
		MountCtrl.Instance:SendGoonMountReq(0)
	end
end

function MainRole:OnFlyingUpProcess()
	Role.OnFlyingUpProcess(self)
end

function MainRole:OnFlyingDownProcess()
	Role.OnFlyingDownProcess(self)
end

---------------------------------------------------------------轻功相关--------------------------------------------------

function MainRole:TouchBegin()
	self.is_joystick_touched = true
	local enabled = self:IsCanUseQingGong() and self:IsUsableQingGong()
	self:QingGongEnable(enabled)
end

function MainRole:TouchEnd()
	self.is_joystick_touched = false
	if not self.is_landed then
		self.draw_obj:AdjustMoveMent(0, 0)
	end

	if not self:IsQingGong() then
		self:QingGongEnable(false)
	end
end

function MainRole:TouchMove(fx, fy)
	if not self.is_landed then
		self.draw_obj:AdjustMoveMent(fx, fy)
	end
end

function MainRole:Jump()
	if self.is_auto_jump then
		return
	end

	if self.qinggong_index >= COMMON_CONSTS.MAX_QING_GONG_COUNT then
		return
	end

	-- 落地之前不允许触发第一段跳跃
	-- 快要落地之后不能再触发连跳
	if not self.is_landed and (self.qinggong_index == 0 or self.ready_to_ground) then
		return
	end

	-- 快速降落之后不能再使用轻功
	if self.is_force_landing then
		return
	end

	if self.jump_time_stamp + 1 > Status.NowTime then
		return
	end
	
	if not self:IsUsableQingGong() then
		SysMsgCtrl.Instance:ErrorRemind(Language.QingGong.StateNoQingGong)
		return
	end

	if self:IsFightState() then
		SysMsgCtrl.Instance:ErrorRemind(Language.QingGong.CanNotJumpInFight)
		return
	end

	if not self:IsCanUseQingGong() then
		return
	end

	self:QingGongEnable(true)
	self.has_play_qinggong_land = false
	self.ready_to_ground = false

	local post_effects = nil
	if not IsNil(MainCameraFollow) then
		post_effects = MainCameraFollow.gameObject:GetComponentInChildren(typeof(PostEffects))
		-- 轻功时关闭自动调整摄像机
		-- MainCameraFollow:SetIsFlyState(true)
	end

	local prof = PlayerData.Instance:GetRoleBaseProf(self.vo.prof)
	local qinggong_obj = ResPreload[string.format("QingGongObject%s_%s", prof, self.qinggong_index + 1)]
	self.draw_obj:Jump(qinggong_obj)
	self.qinggong_obj_time = qinggong_obj.Time

	--音效
	self:PlayQingGongJumpAudio("jump")

	if self.qinggong_index == 0 then
		self.draw_obj:SetDrag(0.1)
	elseif self.qinggong_index == 1 then
		self.draw_obj:SetDrag(0.1)
		if post_effects then
			post_effects.MotionBlurDist = 0.3
			post_effects.MotionBlurStrength = 0
			post_effects:DoMotionBlurStrength(1.5, 0.5)
			post_effects.EnableMotionBlur = true
		end
	elseif self.qinggong_index == 2 then
		self.draw_obj:SetDrag(0.1)
		if post_effects then
			post_effects.MotionBlurDist = 0.3
			post_effects:DoMotionBlurStrength(2.5, 0.5)
			post_effects.EnableMotionBlur = true
		end
	elseif self.qinggong_index == 3 then
		self.draw_obj:SetDrag(3)
		if post_effects then
			post_effects.MotionBlurDist = 0.3
			post_effects:DoMotionBlurStrength(3.5, 0.5)
			post_effects.EnableMotionBlur = true
		end
	end

	self.qinggong_index = self.qinggong_index + 1
	self.jump_time_stamp = Status.NowTime

	if self.qinggong_index >= 3 then
		self:PlayQingGongJumpAudio("fly", true)
	end

	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	main_part:SetTrigger("QingGong" .. self.qinggong_index)

	-- 这里发一条移动协议，用来同步方向
	local forward = self.draw_obj:GetRoot().gameObject.transform.forward
	local dir = math.atan2(forward.z, forward.x)
	Scene.SendMoveReq(dir, self.logic_pos.x, self.logic_pos.y, 0, 0)
	Scene.SendMoveMode(MOVE_MODE.MOVE_MODE_JUMP, self.qinggong_index)
	MainUICtrl.Instance:FlushView("jump_state", {self.qinggong_index})
	local jump_eff_pos = self.draw_obj:GetRoot().gameObject.transform.position	
	self:PlayJumpEffect(prof, jump_eff_pos)
end

function MainRole:QingGongStateChange(state)
	self.cur_qinggong_state = state
	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	
	if state == QingGongState.OnGround then
		-- 关闭动态模糊
		if not IsNil(MainCameraFollow) then
			local post_effects = MainCameraFollow.gameObject:GetComponentInChildren(typeof(PostEffects))
			if post_effects then
				post_effects.EnableMotionBlur = false
			end
			-- MainCameraFollow:SetIsFlyState(false)
		end

		--音效
		self:PlayQingGongJumpAudio("down")

		self.draw_obj:SetDrag(0.1)
		local root = self.draw_obj.root
		self:SetRealPos(root.transform.position.x, root.transform.position.z)

		-- 播放落地特效
		local bundle_name, asset_name = ResPath.GetMiscEffect("tongyong_luodiyanwu")
		EffectManager.Instance:PlayControlEffect(self, bundle_name, asset_name, root.transform.position)

		-- 清除拖尾特效
		self:DestroyTrail()
		-- 清除第四段坐骑
		self:ReleaseQingGongMount()
		self:RemoveHighAreaAudio()

		-- 检查是否落在非法区
		local logic_x, logic_y = self.logic_pos.x, self.logic_pos.y
		local is_block = AStarFindWay:IsBlock(logic_x, logic_y, true)
		local is_force_reset = false
		local position = Vector3(0, 0, 0)
		if is_block then
			self.auto_jump_count = self.auto_jump_count + 1
			logic_x, logic_y = AStarFindWay:FindNearestValidPoint(logic_x, logic_y, 500)
			-- 如果没有找到有效的点，则回到出生点
			if self.logic_pos.x == logic_x and self.logic_pos.y == logic_y then
				logic_x, logic_y = Scene.Instance:GetSceneTownPos()
			end

			local x, y = GameMapHelper.LogicToWorld(logic_x, logic_y)
			position.x = x
			position.z = y

			local height = self.draw_obj:GetHeight(MASK_LAYER.WALKABLE, position)
			position.y = height

			if u3d.v3Length(u3d.v3Sub(self:GetLuaPosition(), position), false) > 30 * 30 then
				is_force_reset = true
			end
		end

		-- 如果落在非法区，则尝试跳到合法区
		if is_block and self.auto_jump_count <= 3 and not is_force_reset then
			self:QingGongEnable(true)
			local dir = u3d.v3Normalize(u3d.v3Sub(position, self:GetLuaPosition()))
			self.draw_obj:SimpleJump(ResPreload.QingGongObject_back, u3d.v3Add(self:GetLuaPosition(), u3d.v3Mul(dir, 1000)), true)
			main_part:SetTrigger("QingGong1")
			self.is_auto_jump = true
			self.qinggong_index = 0
			self.has_play_qinggong_land = false
		-- 超过3次，或者距离太远，则直接重置坐标
		else
			if self.auto_jump_count > 3 or is_force_reset then
				self:SetLogicPos(logic_x, logic_y)
			end
			self.auto_jump_count = 0

			-- 这里发一条移动协议，用来同步方向
			local forward = self.draw_obj:GetRoot().gameObject.transform.forward
			local dir = math.atan2(forward.z, forward.x)
			Scene.SendMoveReq(dir, logic_x, logic_y, 0, 0)

			-- 同步位置
			local scene_key = PlayerData.Instance:GetAttr("scene_key") or 0
			Scene.SendSyncJump(Scene.Instance:GetSceneId(), logic_x, logic_y, scene_key)

			if not self.is_landed then
				if self.qinggong_index < COMMON_CONSTS.MAX_QING_GONG_COUNT and not self.has_play_qinggong_land then
					main_part:SetTrigger("QingGongLand")
				end
				Scene.SendMoveMode(MOVE_MODE.MOVE_MODE_NORMAL)
			end
			self.qinggong_index = 0

			GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_EXIT_JUMP_STATE)
		end
	else
		FightMountCtrl.Instance:SendGoonFightMountReq(0)
		MountCtrl.Instance:SendGoonMountReq(0)

		if self.is_landed then
			self.is_landed = false
			GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_ENTER_JUMP_STATE)
		end
		
		if state == QingGongState.Down then
			if self.qinggong_index < COMMON_CONSTS.MAX_QING_GONG_COUNT or self.is_force_landing then
				main_part:SetTrigger("QingGongDown")
				if self.qinggong_index == 3 then
					self:RemoveHighAreaAudio()
				end
			end
		end

		-- 如果是第四段跳跃，或者是快速下落，则提前播放落地动作
		if state == QingGongState.ReadyToGround then
			if self.is_force_landing then
				main_part:SetTrigger("QingGongLand")
				self.has_play_qinggong_land = true
			elseif self.qinggong_index == COMMON_CONSTS.MAX_QING_GONG_COUNT then
				main_part:SetTrigger("QingGongLand2")
			end

			self.ready_to_ground = true
		end

		-- 增加拖尾特效
		self.destroy_trail = false
		local bundle_name2, asset_name2 = ResPath.GetMiscEffect("tongyong_tuowei")
		local left_hand = self.draw_obj:GetAttachPoint(AttachPoint.QilinBi)
		local right_hand = self.draw_obj:GetAttachPoint(AttachPoint.RightHand)
		if nil == self.left_hand_effect and left_hand then
			EffectManager.Instance:PlayEffect(bundle_name2, asset_name2, left_hand, function (effect)
				if self.left_hand_effect then
					ResPoolMgr:Release(self.left_hand_effect)
					self.left_hand_effect = nil
				end

				if self.destroy_trail then
					ResPoolMgr:Release(effect)
					return
				end

				self.left_hand_effect = effect
			end)
		end
		if nil == self.right_hand_effect and right_hand then
			EffectManager.Instance:PlayEffect(bundle_name2, asset_name2, right_hand, function (effect)
				if self.right_hand_effect then
					ResPoolMgr:Release(self.right_hand_effect)
					self.right_hand_effect = nil
				end

				if self.destroy_trail then
					ResPoolMgr:Release(effect)
					return
				end
				
				self.right_hand_effect = effect
			end)
		end

		if state == QingGongState.Down then
			if not IsNil(MainCameraFollow) then
				local post_effects = MainCameraFollow.gameObject:GetComponentInChildren(typeof(PostEffects))
				if post_effects then
					post_effects:DoMotionBlurStrength(0, 0.5)
				end
			end
		end
	end
end

function MainRole:QingGongLandExit()
	if self.cur_qinggong_state ~= QingGongState.Up then
		self.is_landed = true
		self.is_auto_jump = false
		if self.is_qinggong_guide then
			self.is_qinggong_guide = false
			TaskCtrl.Instance:DoTask()
		end
	end

	self.is_force_landing = false
	self.has_play_qinggong_land = false

	if not self.is_joystick_touched then
		self:QingGongEnable(false)
	end
end

function MainRole:SetIsQingGongGuide(is_qinggong_guide)
	self.is_qinggong_guide = is_qinggong_guide
end

function MainRole:GetIsQingGongGuide()
	return self.is_qinggong_guide
end

function MainRole:Landing()
	self:ReleaseQingGongMount()
	if not self.is_landed and not self.is_auto_jump then
		Scene.Instance:SendRoleLandingReq()
		self.draw_obj:SetDrag(0.1)
		self.is_force_landing = true
		self.draw_obj:ForceLanding()
	end
	self:RemoveHighAreaAudio()
end

function MainRole:CheckQingGong()
	local enabled = self:IsCanUseQingGong()
	if self.old_qinggong_enabled ~= enabled then
		GlobalEventSystem:Fire(OtherEventType.ENABLE_QING_GONG_CHANGE, enabled)
		self.old_qinggong_enabled = enabled
	end
end

function MainRole:IsCanUseQingGong()
	return Scene.Instance:IsQingGongScene()
		and OpenFunData.Instance:CheckIsHide("JumpOpen")
		and self.vo.husong_taskid == 0
		and not self:GetIsFlying()
		and self.special_res_id == 0
	-- return true
end

function MainRole:IsUsableQingGong()
	return self.special_res_id == 0
		and not self:GetIsFlying()
		and not self:IsJump()
		and not CgManager.Instance:IsCgIng()
		and not self:IsMultiMount()
		and not self:IsMultiMountPartner()
		and self.vo.husong_taskid == 0 
		and self.vo.task_appearn_param_1 == 0
		and not self:IsDead() 
		and not self.is_gather_state
		and not MarriageData.Instance:GetOwnIsXunyou()
		and not TaskData.Instance:GetTaskIsCanCommint(FAkE_TRUCK)
end

function MainRole:QingGongBeginExit(index)
	if index == COMMON_CONSTS.MAX_QING_GONG_COUNT then
		-- local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
		-- main_part:SetTrigger("QingGongDown")
		self:JumpQingGongMount(self.vo.prof % 10)
	end
end

function MainRole:DestroyTrail()
	if self.left_hand_effect then
		ResPoolMgr:Release(self.left_hand_effect)
		self.left_hand_effect = nil
	end

	if self.right_hand_effect then
		ResPoolMgr:Release(self.right_hand_effect)
		self.right_hand_effect = nil
	end

	self.destroy_trail = true
end

function MainRole:SceneActionBegin()
	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	if main_part then
		self.is_scene_action_state = true
	end
end

function MainRole:SceneActionEnd()
	self.is_scene_action_state = false
end

------------------------------------
-- NPC自言自语
function MainRole:NpcGroupChatHandler(group_chat_id, group_chat_list)
	if group_chat_id <= 0 or #group_chat_list <= 0 then
		return
	end
	self:RemoveNpcGroupChatTimer()
	
	local npc_tab = {} 
	local npc_list = Scene.Instance:GetNpcList()
	for k, v in pairs(npc_list) do
		table.insert(npc_tab, {npc_id = v.npc_id, obj = v})
	end

	local scene_id = Scene.Instance:GetSceneId()
	for i = 1, #group_chat_list do
		local group_chat = group_chat_list[i]
		if scene_id ~= group_chat.scene_id then
			return
		end
		for k, v in pairs(npc_tab) do
			if v.npc_id == group_chat.npc_id and v.obj then
				local timer_key = group_chat_id .. v.npc_id .. group_chat.start_time
				if self.delay_npc_group_chat[timer_key] then
					GlobalTimerQuest:CancelQuest(self.delay_npc_group_chat[timer_key])
				end
				self.delay_npc_group_chat[timer_key] = GlobalTimerQuest:AddDelayTimer(function ()
					v.obj:NpcSpeakChatContent(group_chat.bubble_text, group_chat.end_time)
					self.delay_npc_group_chat[timer_key] = nil
				end, group_chat.start_time)

			end
		end
	end
end

function MainRole:RemoveNpcGroupChatTimer()
	for k,v in pairs(self.delay_npc_group_chat) do
		GlobalTimerQuest:CancelQuest(self.delay_npc_group_chat[timer_key])
	end
end

--播放高空音效
function MainRole:PlayQingGongJumpAudio(asset, is_high_fly)
	is_high_fly = is_high_fly or false

	local bundle = "audios/sfxs/other"
	local asset = asset

	if is_high_fly ~= true then
		AudioManager.PlayAndForget(bundle, asset)
		return
	end
	
	if self.high_area_audio_player then
		AudioManager.StopAudio(self.high_area_audio_player)
		self.high_area_audio_player = nil
	end

	if not self.high_area_audio_player then
		AudioManager.Play(bundle, asset, nil, nil, function(audio_item)
			if nil == audio_item then
				return
			end
			self.high_area_audio_player = audio_item
		end)
	end
end

function MainRole:RemoveHighAreaAudio()
	if self.delete_high_area_voice_timer then
		if self.high_area_audio_player then
			AudioManager.StopAudio(self.high_area_audio_player)
			self.high_area_audio_player = nil
		end
		GlobalTimerQuest:CancelQuest(self.delete_high_area_voice_timer)
		self.delete_high_area_voice_timer = nil
	end
end

function MainRole:SetDelivering(is_delivering)
	if not self.is_inter_scene then
		return
	end
	
	self.is_delivering = is_delivering
	self:SetRoleVisible()
end

function MainRole:IsDelivering()
	return self.is_delivering
end

function MainRole:OnSceneChangeComplete()
	if not self.is_inter_scene then
		return
	end
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if CgManager.Instance:IsCgIng() or fb_scene_cfg.effect_enter ~= 1 then
		return
	end

	if self.is_first_land then
		self.is_first_land = false
		return
	end
	Scene.Instance:GetMainRole():StopMove()
	self:SetRoleCannotMove()
	if not IsNil(MainCameraFollow) then
		MainCameraFollow.AutoRotation = false
	end
end

function MainRole:OnCloseSceneLoadingView()
	if not self.is_inter_scene then
		return
	end

	--特殊处理：竞技场和1V1需要两个角色同时播放特效
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if PlayerData.Instance:GetIsFirstEntry() or CgManager.Instance:IsCgIng() or fb_scene_cfg.effect_enter ~= 1  then
		PlayerData.Instance:SetIsFirstEntry(false)
		return
	end

	local call_back = GuajiCtrl.Instance:GetMoveToPosCallBack()
	self:PlayFlyDownEffect(call_back)
end

function MainRole:PlayFlyDownEffect(callback)
	if self.play_chuansongmen_02_effect then
		return
	end
	self:SetDelivering(true)
	if nil == self:GetRoot() then
		return
	end
	Scene.Instance:GetMainRole():StopMove()
	self:SetRoleCannotMove()
	if not IsNil(MainCameraFollow) then
		MainCameraFollow.AutoRotation = false
	end
	local bundle_name, asset_name = ResPath.GetTongyongEffect("chuansongmen_02")
	local async_loader = AllocAsyncLoader(self, "player_fly_down_effect")
	async_loader:SetParent(self:GetRoot().transform)
	async_loader:SetObjAliveTime(10) --防止永久存在
	async_loader:SetIsUseObjPool(true)
	async_loader:Load(bundle_name, asset_name, function(obj)
		if IsNil(obj) then
			return
		end
		
		local control = obj:GetOrAddComponent(typeof(EffectControl))
		if control == nil then
			async_loader:DeleteMe()
			return
		end

		control:Reset()
		control.enabled = true
		control:WaitFinsh(function()
			async_loader:DeleteMe()
		end)
		control:Play()
	end)

	self.play_chuansongmen_02_effect = true
	if self.fall_effect_timer then
		GlobalTimerQuest:CancelQuest(self.fall_effect_timer)
	end
	self.fall_effect_timer = GlobalTimerQuest:AddDelayTimer(function()
			self.play_chuansongmen_02_effect = false
			self:SetDelivering(false)
			Scene.Instance:SetMainRoleIsMove(true)
			if callback then
				callback()
				GuajiCtrl.Instance:SetMoveToPosCallBack(nil)
			end
	end, 1.5)
end

function MainRole:PlayFlyUpEffect(callback)
	if self.play_chuansongmen_01_effect then
		return
	end
	self.play_chuansongmen_01_effect = true
	if not IsNil(MainCameraFollow) then
		MainCameraFollow.AutoRotation = false
	end
	self:SetDelivering(false)
	PlayerData.Instance:SetIsFirstEntry(false)
	MountCtrl.Instance:SendGoonMountReq(0)
	FightMountCtrl.Instance:SendGoonFightMountReq(0)
	Scene.Instance:GetMainRole():StopMove()
	self:SetRoleCannotMove()
	local bundle_name, asset_name = ResPath.GetTongyongEffect("chuansongmen_01")
	local async_loader = AllocAsyncLoader(self, "player_fly_up_effect")
	async_loader:SetParent(self:GetRoot().transform)
	async_loader:SetObjAliveTime(10) --防止永久存在
	async_loader:SetIsUseObjPool(true)
	async_loader:Load(bundle_name, asset_name, function(obj)
		if IsNil(obj) then
			return
		end

		local control = obj:GetOrAddComponent(typeof(EffectControl))
		if control == nil then
			async_loader:DeleteMe()
			return
		end

		control:Reset()
		control.enabled = true
		control:WaitFinsh(function()
			async_loader:DeleteMe()
		end)
		control:Play()
	end)
	if self.fly_effect_timer then
		GlobalTimerQuest:CancelQuest(self.fly_effect_timer)
	end
	self.fly_effect_timer = GlobalTimerQuest:AddDelayTimer(function()
		self.play_chuansongmen_01_effect = false
		self:SetDelivering(true)
		Scene.Instance:SetMainRoleIsMove(true)
		if callback then
			callback()
		end
	end, 1.5)
end

function MainRole:SetRoleCannotMove()
	Scene.Instance:SetMainRoleIsMove(false)
	if self.role_can_move_time then
		GlobalTimerQuest:CancelQuest(self.role_can_move_time)
		self.role_can_move_time = nil
	end
	--做个计时防卡死正常是不需要的
	self.role_can_move_time =  GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.RoleCanMoveTimeEnd, self), 5)
end

function MainRole:RoleCanMoveTimeEnd()
	Scene.Instance:SetMainRoleIsMove(true)
end

function MainRole:IsBaiYe()
	if GuildFightCtrl.Instance and GuildFightCtrl.Instance:GetIsBaiYe() then
		return true
	elseif CityCombatCtrl.Instance and CityCombatCtrl.Instance:GetIsBaiYe() then
		return true
	elseif ElementBattleCtrl.Instance and ElementBattleCtrl.Instance:GetIsBaiYe() then
		return true
	elseif KuafuGuildBattleCtrl.Instance and KuafuGuildBattleCtrl.Instance:GetIsBaiYe() then
		return true
	end
	return false
end
