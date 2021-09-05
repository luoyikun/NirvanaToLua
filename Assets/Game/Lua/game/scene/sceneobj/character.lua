Character = Character or BaseClass(SceneObj)

function Character:__init()
	self.show_hp = 0								-- 表现hp
	-- 攻击相关
	self.attack_skill_id = 0
	self.next_skill_id = 0
	self.attack_target_pos_x = 0
	self.attack_target_pos_y = 0
	self.attack_target_obj = nil

	self.attack_is_playing = false					-- 攻击动作是否在播放中
	self.attack_is_playing_invalid_time = 0 		-- 一段时间后attack_is_playing恢复为false

	self.fight_state_end_time = 0					-- 战斗状态结束时间
	self.fight_by_role_end_time = 0					-- 由与人物战斗状态结束时间
	self.floating_data = nil						-- 当前正在播放的飘字
	self.floating_texts = {}						-- 飘字队列

	-- Move状态相关变量
	self.move_end_pos = u3d.vec2(0, 0)
	self.move_dir = u3d.vec2(0, 0)					-- 移动方向(单位向量)
	self.move_total_distance = 0.0					-- 移动总距离
	self.move_pass_distance = 0.0					-- 移动距离
	self.is_special_move = false					-- 是否特殊移动
	self.special_speed = 0							-- 特殊移动附加速度
	self.delay_end_move_time = 0					-- 延迟结束移动状态(防止摇杆贴边行走时快速切换移动、站立)
	self.is_jump = false

	self.fly_max_height = 12						-- 飞行最大高度
	self.flying_up_use_time = 2						-- 飞行上升需要的时间
	self.flying_down_use_time = 2					-- 飞行下降需要的时间
	self.flying_height = 0							-- 当前飞行高度
	self.flying_process = 0							-- 飞行过程（1,上升 2,最高处 3,下降）

	self.rotate_to_angle = nil 						-- 旋转到指定角度
	self.anim_name = ""								-- 当前的动作
	self.attack_index = 1							-- 当前攻击序列
	self.animator_handle_t = {}

	self.select_effect = nil
	self.buff_effect_list = {}
	self.buff_type_list = {}

	self.other_effect_list = {}

	self.last_bink_time = 0
	self.old_show_hp = nil
	self.last_hit_audio_time = 0
	self.last_attacker_pos_x = 0
	self.last_attacker_pos_y = 0

	-- 是否创建飞行器
	self.has_craft = false
	self.is_sit_mount = 0

	self.state_machine = StateMachine.New(self)
	--Stand
	self.state_machine:SetStateFunc(SceneObjState.Stand, self.EnterStateStand, self.UpdateStateStand, self.QuitStateStand)
	--Move
	self.state_machine:SetStateFunc(SceneObjState.Move, self.EnterStateMove, self.UpdateStateMove, self.QuitStateMove)
	--Attack
	self.state_machine:SetStateFunc(SceneObjState.Atk, self.EnterStateAttack, self.UpdateStateAttack, self.QuitStateAttack)
	--Dead
	self.state_machine:SetStateFunc(SceneObjState.Dead, self.EnterStateDead, self.UpdateStateDead, self.QuitStateDead)
end

function Character:__delete()
	self.state_machine:DeleteMe()

	for _, v in pairs(self.animator_handle_t) do
		v:Dispose()
	end
	self.animator_handle_t = {}

	for k,v in pairs(self.buff_effect_list) do
		v:Destroy()
		v:DeleteMe()
	end
	self.buff_effect_list = {}
	self:RemoveDelayTime()
	GlobalTimerQuest:CancelQuest(self.dead_timer)
	GlobalTimerQuest:CancelQuest(self.say_end_timer)
	self:RemoveJumpDelayTime()
	self.uicamera = nil
	self.attack_target_obj = nil
	self.buff_type_list = {}

	if self.effect_obj then
		ResPoolMgr:Release(self.effect_obj)
		self.effect_obj = nil
	end	
end

function Character:InitInfo()
	SceneObj.InitInfo(self)
	self.show_hp = self.vo.hp
	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	local is_main_role = self:IsMainRole()
	main_part:SetMainRole(is_main_role)
	if self.actor_trigger then
		self.actor_trigger:SetMainRole(is_main_role)
		self.actor_trigger:EnableCameraShake(is_main_role)
	end

	main_part:ListenEvent("jump/start", BindTool.Bind(self.OnJumpStart, self))
	main_part:ListenEvent("jump/end", BindTool.Bind(self.OnJumpEnd, self))
end

function Character:RegisterShadowUpdate()
	SceneObj.RegisterShadowUpdate(self)
end

local reset_pos_time = 0
function Character:Update(now_time, elapse_time)
	SceneObj.Update(self, now_time, elapse_time)
	self.state_machine:UpdateState(elapse_time)
	self:UpdateFlying(now_time, elapse_time)

	if self.fight_state_end_time > 0 and now_time >= self.fight_state_end_time then
		self:LeaveFightState()
	end
	reset_pos_time = reset_pos_time + UnityEngine.Time.deltaTime
	if self.reset_x and self.reset_y and reset_pos_time > 0.05 then
		reset_pos_time = 0
		if self.logic_pos.x == self.reset_x and self.logic_pos.y == self.reset_y then
			self.reset_x = nil
			self.reset_y = nil
		else
			local reset_x, reset_y = 0, 0
			if self.logic_pos.x ~= self.reset_x then
				reset_x = self.logic_pos.x > self.reset_x and -1 or 1
			end
			if self.logic_pos.y ~= self.reset_y then
				reset_y = self.logic_pos.y > self.reset_y and -1 or 1
			end
			self:SetLogicPos(self.logic_pos.x + reset_x, self.logic_pos.y + reset_y)
		end
	end

	if self.attack_is_playing_invalid_time > 0 and now_time >= self.attack_is_playing_invalid_time then
		self.attack_is_playing_invalid_time = 0
		self.attack_is_playing = false
	end

	if ClientCmdCtrl.Instance.is_show_pos and self:GetFollowUi() then
		local name_str = string.format(self.vo.name .. "(%d,%d)",self.logic_pos.x, self.logic_pos.y)
		self:GetFollowUi():SetName(name_str)
	end
	for k,v in pairs(self.other_effect_list) do
		if v.time < now_time then
			v.eff:Destroy()
			v.eff:DeleteMe()
			self.other_effect_list[k] = nil
		end
	end
end

function Character:OnEnterScene()
	SceneObj.OnEnterScene(self)
	self:ChangeToCommonState(true)
end

function Character:CreateShadow()
	SceneObj.CreateShadow(self)
end

function Character:IsCharacter()
	return true
end

function Character:CharacterAnimatorEvent(param, state_info, anim_name)
	local actor_trigger = self:GetActorTrigger()
	if actor_trigger ~= nil then
		-- local source = self.draw_obj:GetRoot()
		local source_obj = self.draw_obj
		local target_obj = nil
		if self.attack_target_obj and self.attack_target_obj.draw_obj then
			-- target = self.attack_target_obj.draw_obj:GetRoot()
			target_obj = self.attack_target_obj.draw_obj
		end
		actor_trigger:OnAnimatorEvent(param, state_info, source_obj, target_obj, anim_name)
	end
end

-- string param, AnimatorStateInfo stateInfo
function Character:OnAnimatorBegin(param, state_info)
	if self:IsAtk() then
		self:SetIsAtkPlaying(true)

		self:CharacterAnimatorEvent(param, state_info, self.anim_name.."/begin")
	end
	-- self:CharacterAnimatorEvent(param, state_info, self.anim_name.."/begin")
end

function Character:OnAnimatorHit(param, state_info)
	if self:IsDeleted() then
		self.attack_skill_id = 0
		return
	end

	if self:IsAtk() then
		local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
		local main_part_obj = main_part:GetObj()
		if nil == main_part_obj or IsNil(main_part_obj.gameObject) or self.attack_target_obj == nil then
			return
		end

		local target_draw_obj = self.attack_target_obj.draw_obj
		if target_draw_obj == nil then
			return
		end
		local root = target_draw_obj:GetRoot()
		local hurt_point = target_draw_obj:GetAttachPoint(AttachPoint.Hurt)

		if not self:IsRole() and (Scene.Instance:GetSceneType() == SceneType.Defensefb or
		Scene.Instance:GetSceneType() == SceneType.QunXianLuanDou)then --防御塔的攻击
			hurt_point = target_draw_obj:GetAttachPoint(AttachPoint.HurtRoot)
		end
		
		local attack_skill_id = self.attack_skill_id
		local attack_target_obj = self.attack_target_obj

		self:CharacterAnimatorEvent(param, state_info, self.anim_name.."/hit")

		local actor_ctrl = self:GetActorCtrl()
		if actor_ctrl ~= nil then
			actor_ctrl:PlayProjectile(main_part_obj, self.anim_name, root, hurt_point, function()
				if not self:IsDeleted() and attack_target_obj ~= nil then
					self:OnAttackHit(attack_skill_id, attack_target_obj)
				end
			end)
		end
	end

	if self.next_skill_id and self.next_skill_id ~= 0 and self.attack_skill_id and self.attack_skill_id > 0 then
		self.attack_skill_id = 0
		self:DoAttack(
			self.next_skill_id,
			self.next_target_x,
			self.next_target_y,
			self.next_target_obj_id,
			self.next_target_type)
		self.next_skill_id = 0
	else
		self.next_skill_id = 0
		self.attack_skill_id = 0
	end
end

function Character:OnAnimatorEnd(param, state_info)
	if self:IsAtk() then
		self:ChangeToCommonState()
	end
	self:SetIsAtkPlaying(false)

	self:CharacterAnimatorEvent(param, state_info, self.anim_name.."/end")
end

function Character:OnAttackHit(attack_skill_id, attack_target_obj)
	FightData.Instance:OnHitTrigger(self, attack_target_obj)
end

function Character:CreateFollowUi()
	self.follow_ui = CharacterFollow.New()
	self.follow_ui:CreateRootObj(self.obj_type)
	if self.draw_obj then
		self.follow_ui:SetFollowTarget(self.draw_obj.root.transform, self.draw_obj:GetName())
	end
	self:SyncShowHp()
end

function Character:GetMoveSpeed()
	local speed = Scene.ServerSpeedToClient(self.vo.move_speed) + self.special_speed
	if self.is_jump or self.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		if self.vo.jump_factor then
			speed = self.vo.jump_factor * speed
		else
			speed = 1.8 * speed
		end
	end
	return speed
end

function Character:IsStand()
	return self.state_machine:IsInState(SceneObjState.Stand)
end

function Character:IsMove()
	return self.state_machine:IsInState(SceneObjState.Move)
end

function Character:IsAtk()
	return self.state_machine:IsInState(SceneObjState.Atk)
end

function Character:SetIsAtkPlaying(attack_is_playing)
	local old_attack_is_playing = self.attack_is_playing
	self.attack_is_playing = attack_is_playing

	if attack_is_playing then
		self.attack_is_playing_invalid_time = Status.NowTime + 4
	else
		self.attack_is_playing_invalid_time = 0
	end

	if true == old_attack_is_playing and false == attack_is_playing then
		self:OnAttackPlayEnd()
	end
end

function Character:IsAtkPlaying()
	return self.attack_is_playing
end

function Character:IsDead()
	return self.state_machine:IsInState(SceneObjState.Dead)
end

function Character:IsRealDead()
	return self.vo.hp <= 0
end

function Character:OnClick()
	SceneObj.OnClick(self)
	if self:IsDeleted() then
		return
	end

	if nil == self.select_effect then
		self.select_effect = AllocAsyncLoader(self, "select_effect_loader")
		self.select_effect:SetIsUseObjPool(true)
		local bundle, asset = ResPath.GetSelectObjEffect(1)
		self.select_effect:SetParent(self.draw_obj:GetRoot().transform)
		self.select_effect:Load(bundle, asset)
	end
	self.select_effect:SetActive(true)
end

function Character:CancelSelect()
	SceneObj.CancelSelect(self)
	if nil ~= self.select_effect then
		self.select_effect:SetActive(false)
	end
end
----------------------------------------------------
-- 状态函数begin
----------------------------------------------------
-- 站立
function Character:DoStand()
	if self:IsDeleted() then
		return
	end

	if self:IsStand() then
		return
	end
	self.state_machine:ChangeState(SceneObjState.Stand)
end

function Character:EnterStateStand()
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	if part then
		part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Idle)
	end
	if self:IsGoddess() then
		local weapon_part = self.draw_obj:GetPart(SceneObjPart.Weapon)
		if weapon_part then
			weapon_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Idle)
		end
	end
	if self:IsMarryObj() then
		local main_part_obj = part:GetObj()
		if main_part_obj then
			local children = main_part_obj.gameObject:GetComponentsInChildren(typeof(UnityEngine.Animator))
			for i = 0, children.Length - 1 do
				children[i]:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Idle)
			end
		end
	end
end

function Character:UpdateStateStand(elapse_time)
end

function Character:QuitStateStand()
end

-- 移动
function Character:DoMove(pos_x, pos_y)
	if self:IsDead() then
		return
	end

	if self:IsNeedChangeDirOnDoMove(pos_x, pos_y) then
		self:SetDirectionByXY(pos_x, pos_y)
	end

	self.move_end_pos.x, self.move_end_pos.y = GameMapHelper.LogicToWorld(pos_x, pos_y)
	local delta_pos = u3d.v2Sub(self.move_end_pos, self.real_pos)
	self.move_total_distance = u3d.v2Length(delta_pos)
	self.move_dir = u3d.v2Normalize(delta_pos)
	self.move_pass_distance = 0.0

	self.delay_end_move_time = 0
	self.draw_obj:MoveTo(self.move_end_pos.x, self.move_end_pos.y, self:GetMoveSpeed())

	--如果当前不在移动状态则切换至移动状态
	if not self:IsMove() then
		self.state_machine:ChangeState(SceneObjState.Move)
	end
end

function Character:IsNeedChangeDirOnDoMove(pos_x, pos_y)
	return true
end

function Character:EnterStateMove()
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	if part then
		part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Run)
	end
	if self:IsGoddess() then
		local weapon_part = self.draw_obj:GetPart(SceneObjPart.Weapon)
		if weapon_part then
			weapon_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Run)
		end
	end
	if self:IsMarryObj() then
		local main_part_obj = part:GetObj()
		if main_part_obj then
			local children = main_part_obj.gameObject:GetComponentsInChildren(typeof(UnityEngine.Animator))
			for i = 0, children.Length - 1 do
				children[i]:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Run)
			end
		end
	end
end

function Character:UpdateStateMove(elapse_time)
	if self.delay_end_move_time > 0 then
		if Status.NowTime >= self.delay_end_move_time then
			self.delay_end_move_time = 0
			self:ChangeToCommonState()
		end
		return
	end

	if self.draw_obj then
		local part = self.draw_obj:GetPart(SceneObjPart.Main)
		part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Run)
		--移动状态更新
		local distance = elapse_time * self:GetMoveSpeed()
		self.move_pass_distance = self.move_pass_distance + distance

		if self.move_pass_distance >= self.move_total_distance then
			self.is_special_move = false
			self:SetRealPos(self.move_end_pos.x, self.move_end_pos.y)

			if self:MoveEnd() then
				self.move_pass_distance = 0
				self.move_total_distance = 0
				if self:IsMainRole() then
					self.delay_end_move_time = Status.NowTime + 0.05
				elseif self:IsSpirit() then
					self.delay_end_move_time = Status.NowTime + 0.02
				else
					self.delay_end_move_time = Status.NowTime + 0.2
				end
			end
		else
			local mov_dir = u3d.v2Mul(self.move_dir, distance)
			self:SetRealPos(self.real_pos.x + mov_dir.x, self.real_pos.y + mov_dir.y)
		end
	end
end

function Character:QuitStateMove()
	self.draw_obj:StopMove()
	if self.has_craft then
		self.timer_quest = GlobalTimerQuest:AddDelayTimer(function() self:RemoveModel(SceneObjPart.FightMount)
		self:RemoveModel(SceneObjPart.Mount) self.has_craft = false end, 0.2)
	end
	self.is_jump = false

end

function Character:RemoveDelayTime()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function Character:MoveEnd()
	return true
end

-- 移动剩余距离
function Character:GetMoveRemainDistance()
	if not self:IsMove() then
		return 0
	end

	return self.move_total_distance - self.move_pass_distance
end

-- 攻击
function Character:DoAttack(skill_id, target_x, target_y, target_obj_id, target_type)
	if self.attack_skill_id ~= 0 and skill_id ~= self.attack_skill_id then
		self.next_skill_id = skill_id
		self.next_target_x = target_x
		self.next_target_y = target_y
		self.next_target_obj_id = target_obj_id
		self.next_target_type = target_type
		self:DoAttack(self.attack_skill_id, target_x, target_y, target_obj_id, target_type)
		return
	end

	-- bug现象，战士旋风斩过程中，释放必杀击会失效
	if skill_id == 5 and not self:IsStand() or self:IsAtkPlaying() then
		return
	end

	self.attack_skill_id = skill_id
	self.attack_target_pos_x = target_x
	self.attack_target_pos_y = target_y
	self.attack_target_obj = Scene.Instance:GetObj(target_obj_id)
	if self.attack_target_obj ~= nil and nil ~= self.draw_obj then
		local target = self.attack_target_obj:GetRoot().transform
		if self.attack_skill_id == 80 or self.attack_skill_id == 81 or self.attack_skill_id == 82 then
			target = self.attack_target_obj.draw_obj:GetAttachPoint(AttachPoint.UI)
		end
	end
	if not SkillData.IsBuffSkill(skill_id) and (self.vo.special_appearance ~= SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR
		or SkillData.Instance:GetRealSkillIndex(skill_id) ~= 5) then
		self:SetDirectionByXY(target_x, target_y)
	end
	self:EnterFight(target_type)
	self.state_machine:ChangeState(SceneObjState.Atk)

	if self:IsRole() then
		local goddess_obj = self:GetGoddessObj()
		if goddess_obj then
			goddess_obj:DoAttack(skill_id, target_x, target_y, target_obj_id, target_type)
		end

		local lingchong_obj = self:GetLingChongObj()
		if lingchong_obj then
			lingchong_obj:DoAttack(target_x, target_y, target_obj_id)
		end

	end
end

function Character:EnterStateAttack(anim_name)
	if self.vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR then
		if SkillData.Instance:GetRealSkillIndex(self.attack_skill_id) > 3 then
			anim_name = "attack2"
		else
			anim_name = "attack1"
		end
	end

	if Scene.Instance:GetSceneType() == SceneType.HotSpring then
		if self.skill_id == VIRTUAL_SKILL_TYPE.THROW_SNOW_BALL then
			anim_name = "attack1"
		end
	elseif not self:IsMainRole() and (Scene.Instance:GetSceneType() == SceneType.Defensefb or
	Scene.Instance:GetSceneType() == SceneType.QunXianLuanDou) then --防御塔的攻击
		anim_name = "attack2"
	end

	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	local part_obj = part:GetObj()
	if part_obj == nil or IsNil(part_obj.gameObject) then
		return
	end

	local animator = part_obj.animator
	animator:SetTrigger(anim_name)
	self.anim_name = anim_name

	if nil == self.animator_handle_t[anim_name.."/begin"] then
		self.animator_handle_t[anim_name.."/begin"] = animator:ListenEvent(anim_name.."/begin", BindTool.Bind(self.OnAnimatorBegin, self))
	end

	if nil == self.animator_handle_t[anim_name.."/hit"] then
		self.animator_handle_t[anim_name.."/hit"] = animator:ListenEvent(anim_name.."/hit", BindTool.Bind(self.OnAnimatorHit, self))
	end

	if nil == self.animator_handle_t[anim_name.."/end"] then
		self.animator_handle_t[anim_name.."/end"] = animator:ListenEvent(anim_name.."/end", BindTool.Bind(self.OnAnimatorEnd, self))
	end
end

function Character:UpdateStateAttack(elapse_time)
end

function Character:QuitStateAttack(attack_skill_id)
	attack_skill_id = attack_skill_id or self.attack_skill_id
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	local part_obj = part:GetObj()
	local skill_cfg = SkillData.GetSkillinfoConfig(attack_skill_id)
	local anim_name = nil
	if nil ~= skill_cfg then
		anim_name = skill_cfg.skill_action
		if skill_cfg.hit_count > 1 then
			anim_name = anim_name.."_"..self.attack_index
		end
	end
	if self.vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR then
		if SkillData.Instance:GetRealSkillIndex(attack_skill_id) > 3 then
			anim_name = "attack2"
		else
			anim_name = "attack1"
		end
	end
	if part_obj then
		local animator = part_obj.animator
		if anim_name then
			animator:ResetTrigger(anim_name)
		end
	end
end

-- 攻击表现完成后做的事(退出攻击动作QuitStateAttack不可靠)
function Character:OnAttackPlayEnd()
	-- body
end

function Character:RemoveJumpDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

-- 跳跃
function Character:DoJump(move_mode_param)
	if move_mode_param == nil or move_mode_param == 0 then
		local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
		-- 如果跳跃之前是战斗状态，则强制切换到普通状态（战斗状态跳跃动作很奇怪），延迟0.5秒再进行跳跃
		local obj = main_part:GetObj()
		if obj and not IsNil(obj.gameObject) and obj.animator and obj.animator:GetBool("fight") then
			main_part:SetBool(ANIMATOR_PARAM.FIGHT, false)
			self:RemoveJumpDelayTime()
			self.delay_time = GlobalTimerQuest:AddDelayTimer(function() self:DoJump(move_mode_param) end, 0.5)
			return
		end

		if self.vo.jump_act and self.vo.jump_act == 3 then
			main_part:SetTrigger("jump3")
		elseif self.vo.jump_act and self.vo.jump_act == 2 then
			main_part:SetTrigger("jump2")
		else
			main_part:SetTrigger("jump")
		end
	else
		self:DoAirCraftMove(move_mode_param)
	end

	self.is_jump = true
end

-- 从一半开始播放
function Character:DoJump2(move_mode_param)
	if move_mode_param == nil or move_mode_param == 0 then
		local mount_part = nil
		local fight_mount_part = nil
		if self.vo.mount_appeid ~= nil and self.vo.mount_appeid > 0 then
			mount_part = self.draw_obj:GetPart(SceneObjPart.Mount)
		elseif self.vo.fight_mount_appeid ~= nil and self.vo.fight_mount_appeid > 0 then
			fight_mount_part = self.draw_obj:GetPart(SceneObjPart.FightMount)
		end
		if mount_part then
			mount_part:Play("jump", 0, 0.5)
		else
			local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
			main_part:Play("jump", 0, 0.5)
		end
		if fight_mount_part then
			fight_mount_part:Play("jump", 0, 0.5)
		end
	else
		self:DoAirCraftMove(move_mode_param)
	end
	self.is_jump = true
end

-- 飞行器移动
function Character:DoAirCraftMove(craft_id)
	local craft_cfg = MountData.Instance:GetCraftCfgById(craft_id)
	if craft_cfg then
		local asset_bundle = tostring(craft_cfg.asset_bundle)
		local asset_name = tostring(craft_cfg.asset_name)
		if asset_bundle ~= "" and asset_name ~= "" then
			if craft_cfg.type == 1 then
				self:RemoveModel(SceneObjPart.FightMount)
				self:ChangeModel(SceneObjPart.Mount, asset_bundle, asset_name)
			else
				self:RemoveModel(SceneObjPart.Mount)
				self:ChangeModel(SceneObjPart.FightMount, asset_bundle, asset_name)
			end
			self.has_craft = true
			self:RemoveDelayTime()
		end
	end
	self:EnterStateMove()
end

function Character:OnJumpStart()
	self.is_jump = true
end

function Character:OnJumpEnd()
	self.is_jump = false
end

function Character:IsJump()
	return self.is_jump or false
end

function Character:SetJump(state)
	self.is_jump = state or false
end

-- 死亡
function Character:DoDead(is_init)
	if is_init then
		self.is_init_dead = true
	end
	Scene.Instance:DelMoveObj(self.vo.obj_id)
	self.state_machine:ChangeState(SceneObjState.Dead)

	self:OnDie()
end

function Character:EnterStateDead()
	self:RemoveModel(SceneObjPart.Mount)

	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	main_part:SetInteger(ANIMATOR_PARAM.STATUS, 2)
	if self.is_init_dead then
		self.is_init_dead = nil
		main_part:SetTrigger("dead_imm")
	else
		if self:IsMonster() and self.dietype == 1 then
			if math.random() > 0.5 then
				local delta_x = self.real_pos.x - self.last_attacker_pos_x
				local delta_y = self.real_pos.y - self.last_attacker_pos_y
				local delta_l = math.sqrt(delta_x * delta_x + delta_y * delta_y)
				if delta_l > 0 then
					delta_x = delta_x / delta_l
					delta_y = delta_y / delta_l
				end

				local move_len = 5.0
				local target_x = self.real_pos.x + move_len * delta_x
				local target_y = self.real_pos.y + move_len * delta_y

				self.draw_obj:MoveTo(
					target_x,
					target_y,
					2 * self:GetMoveSpeed())
			end
		end
	end

	self:SetIsAtkPlaying(false)
	GlobalEventSystem:Fire(ObjectEventType.OBJ_DEAD, self)
	self:HideFollowUi()
end

function Character:UpdateStateDead(elapse_time)
end

function Character:QuitStateDead()
end

function Character:ChangeToCommonState(is_init)
	if (self.show_hp and self.show_hp > 0) or (self.vo and self.vo.hp > 0) then
		if not self:IsStand() then
			self:DoStand()
		end
	else
		if not self:IsDead() then
			if self:IsMainRole() then
				if self.dead_timer == nil then
					self.dead_timer = GlobalTimerQuest:AddDelayTimer(function ()
						if self.show_hp <= 0 and not self:IsDead() then
							self:DoDead()
						end
						self.dead_timer = nil
					end, 0.1)
				end
			else
				self:DoDead()
			end
		end
	end
end
----------------------------------------------------
-- 状态函数end
----------------------------------------------------

----------------------------------------------------
-- 战斗 begin
----------------------------------------------------
function Character:GetAttackSkillId()
	return self.attack_skill_id
end

-- 进入战斗
function Character:EnterFight(target_type)
	if 0 == self.fight_state_end_time then
		self:EnterFightState()
	end
	self.fight_state_end_time = Status.NowTime + COMMON_CONSTS.FIGHT_STATE_TIME

	if target_type == SceneObjType.Role then
		self.fight_by_role_end_time = Status.NowTime + COMMON_CONSTS.FIGHT_STATE_TIME
	end
end

-- 进入战斗状态
function Character:EnterFightState()
	if self.draw_obj == nil then
		return
	end
	self:ActiveFollowUi()
	-- self:SyncShowHp()

	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	part:SetBool(ANIMATOR_PARAM.FIGHT, true)

	if self:IsMainRole() then
		GlobalEventSystem:Fire(ObjectEventType.ENTER_FIGHT)
	end
end

-- 离开战斗状态
function Character:LeaveFightState()
	self.fight_state_end_time = 0
	self.fight_by_role_end_time = 0

	if self.draw_obj == nil then
		return
	end
	
	if self:CanHideFollowUi() then
		self:HideFollowUi()
	end

	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	part:SetBool(ANIMATOR_PARAM.FIGHT, false)

	if self:IsMainRole() then
		GlobalEventSystem:Fire(ObjectEventType.EXIT_FIGHT)
	end
end

-- 是否在战斗状态
function Character:IsFightState()
	return self.fight_state_end_time > Status.NowTime
end

-- 是否在由人物引起的战斗
function Character:IsFightStateByRole()
	return self.fight_by_role_end_time > Status.NowTime
end

function Character:CanHideFollowUi()
	return not self:IsFightState() and not self.is_select
end

function Character:ShowFollowUi()
	local follow_ui = self:GetFollowUi()
	if follow_ui then
		follow_ui:Show()
	end
end

function Character:HideFollowUi()
	local follow_ui = self:GetFollowUi()
	if follow_ui then
		follow_ui:Hide()
	end
end

function Character:Say(content, say_time)
	if nil == self.follow_ui then
		return
	end

	self.follow_ui:HideBubble()
	GlobalTimerQuest:CancelQuest(self.say_end_timer)

	self.follow_ui:ChangeBubble(content)
	self.follow_ui:ShowBubble()
	self.say_end_timer = GlobalTimerQuest:AddDelayTimer(function ()
		self.say_end_timer = nil
		self.follow_ui:HideBubble()
	end, say_time)
end

-- 同步表现血量
function Character:SyncShowHp()
	self:ActiveFollowUi()
	if self.vo.role_id and self.vo.role_id <= 0 then
		return
	end
	
	--回血绿字
	if self.show_hp < self.vo.hp and self.show_hp ~= 0 then
		if self:IsMainRole() then
			local floating_point = self.draw_obj:GetAttachPoint(AttachPoint.UI)
			FightText.Instance:ShowRecover(self.vo.hp - self.show_hp, floating_point)
		end
	end

	self.show_hp = self.vo.hp

	if self.show_hp > 0 then
		if self:IsMainRole() then
			if self:IsDead() then
				self:DoStand()
			end
			if self.old_show_hp and self.old_show_hp <= 0 then
				GlobalTimerQuest:CancelQuest(self.dead_timer)
				self.dead_timer = nil
				self:OnRealive()
			end
		else
			-- self:DoStand()
			-- self:OnRealive() big bug!!!!
		end
	elseif self.dead_timer == nil and self.show_hp <= 0 and not self:IsDead() then
		if self:IsMainRole() then
			self.dead_timer = GlobalTimerQuest:AddDelayTimer(function ()
				if self.show_hp <= 0 and not self:IsDead() then
					self:DoDead()
				end
				self.dead_timer = nil
			end, 0.1)
		else
			self:DoDead()
		end
	end

	if self.vo.max_hp and 0 ~= self.vo.max_hp then
		self:GetFollowUi():SetHpPercent(self.show_hp / self.vo.max_hp)
	end

	if self == GuajiCache.target_obj then
		GlobalEventSystem:Fire(ObjectEventType.TARGET_HP_CHANGE, self)
	end
	self.old_show_hp = self.show_hp
end

function Character:OnRealive()
end

function Character:OnDie()
	-- body
end

-- 被打(有数据)
function Character:DoBeHit(deliverer, skill_id, real_blood, blood, fighttype, text_type)
	if nil ~= deliverer then
		self.last_attacker_pos_x, self.last_attacker_pos_y = deliverer:GetRealPos()
	else
		self.last_attacker_pos_x = 0
		self.last_attacker_pos_y = 0
	end

	-- 获取技能配置
	local skill_action = nil
	local skill_hit_interval = 0
	if nil ~= deliverer then
		if deliverer:IsRole() then
			local skill_cfg = SkillData.GetSkillinfoConfig(skill_id)
			if nil ~= skill_cfg then
				skill_action = skill_cfg.skill_action
				if skill_cfg.hit_count > 1 then
					skill_action = skill_action.."_"..self.attack_index
				end
			end
		end
	end

	-- 同步血量
	self:SyncShowHp()

	if skill_action == nil or deliverer == nil  then
		local real_blood_p = math.floor(real_blood)
		local blood_p = math.floor(blood)
		self:DoBeHitAction(deliverer, real_blood_p, blood_p, fighttype, text_type)
		return
	end

	if deliverer and deliverer.draw_obj then
		local deliverer_main = deliverer.draw_obj:GetPart(SceneObjPart.Main)
		local deliverer_obj = deliverer_main:GetObj()
		if deliverer_obj == nil then
			if nil ~= deliverer then
				local real_blood_p = math.floor(real_blood * 1)
				local blood_p = math.floor(blood * 1)
				self:DoBeHitAction(deliverer, real_blood_p, blood_p, fighttype, text_type)
				self:OnBeHit(real_blood, deliverer, skill_id)
			end
			return
		end
		-- local attacker_obj = deliverer_obj.actor_ctrl
		local attacker_actor_ctrl = deliverer:GetActorCtrl()
		if attacker_actor_ctrl then
			attacker_actor_ctrl:PlayHurt(skill_action, function(p)
				local real_blood_p = math.floor(real_blood * p)
				local blood_p = math.floor(blood * p)
				self:DoBeHitAction(deliverer, real_blood_p, blood_p, fighttype, text_type)
			end)
		end
	end

	if nil ~= deliverer then
		self:OnBeHit(real_blood, deliverer, skill_id)
		if self.vo.hp <= 0 and self:IsMonster() and deliverer.IsMainRole() then
			TipsCtrl.Instance:UpdateDoubleHitNum()
		end
	end
end

-- 受击
function Character:OnBeHit(real_blood, deliverer, skill_id)
	-- override
end

function Character:DoBeHitAction(deliverer, real_blood, blood, fighttype, text_type)
	if self:IsDeleted() then
		return
	end

	-- 飘字
	local is_main_role = false
	local is_left = false
	local is_top = false
	if nil ~= deliverer then
		is_main_role = deliverer:IsMainRole()
		if Scene.Instance:GetSceneType() == SceneType.Defensefb then 			-- 塔防本策划说塔的攻击就相当于人物攻击一样，所以特殊处理一哈
			is_main_role = true
		end
		local root = deliverer:GetRoot()
		if root ~= nil and not IsNil(root.gameObject) and not IsNil(MainCamera) then
			local attacker = root.transform
			local screen_pos_1 = UnityEngine.RectTransformUtility.WorldToScreenPoint(MainCamera, self:GetRoot().transform.position)
			local screen_pos_2 = UnityEngine.RectTransformUtility.WorldToScreenPoint(MainCamera, attacker.position)
			is_left = screen_pos_1.x > screen_pos_2.x
			is_top = screen_pos_1.y < screen_pos_2.y
		end
	end

	local floating_data = {
		is_main_role = is_main_role,
		blood = blood,
		fighttype = fighttype,
		pos = {is_left = is_left, is_top = is_top},
		text_type = text_type,
	}
	if self.floating_data ~= nil then
		if #self.floating_texts < 10 then
			table.insert(self.floating_texts, floating_data)
		end
	else
		self:PlayFloatingText(floating_data)
	end
end

function Character:PlayFloatingText(data)
	if self:IsDeleted() then
		return
	end

	self.floating_data = data
	if data.is_main_role then
		local floating_point = self.draw_obj:GetAttachPoint(AttachPoint.UI)
		local bottom_point = self.draw_obj:GetAttachPoint(AttachPoint.BuffBottom)
		if FIGHT_TYPE.NORMAL == data.fighttype then
			FightText.Instance:ShowHurt(
				data.blood, data.pos, bottom_point, data.text_type)
		elseif FIGHT_TYPE.BAOJI == data.fighttype then
			FightText.Instance:ShowCritical(
				data.blood, data.pos, bottom_point, data.text_type)
		elseif FIGHT_TYPE.SHANBI == data.fighttype then
			FightText.Instance:ShowDodge(
				data.pos, floating_point)
		elseif FIGHT_TYPE.LINGCHONG == data.fighttype then
			FightText.Instance:ShowLingChongGongji(
				data.blood, data.pos, bottom_point, data.text_type)
		elseif FIGHT_TYPE.GEDANG == data.fighttype then
			FightText.Instance:ShowGeDang(
				data.blood, data.pos, bottom_point, data.text_type)
		elseif FIGHT_TYPE.HUIXINYIJI == data.fighttype then
			FightText.Instance:ShowHuiXinYiJi(
				data.blood, data.pos, bottom_point, data.text_type)
		else
			FightText.Instance:ShowBeHurt(
				data.blood, data.pos, bottom_point, data.text_type)
		end
	elseif self:IsMainRole() then
		local floating_point = self.draw_obj:GetAttachPoint(AttachPoint.UI)
		local bottom_point = self.draw_obj:GetAttachPoint(AttachPoint.BuffBottom)
		if FIGHT_TYPE.NORMAL == data.fighttype then
			FightText.Instance:ShowBeHurt(
				data.blood, data.pos, bottom_point)
		elseif FIGHT_TYPE.BAOJI == data.fighttype then
			FightText.Instance:ShowBeCritical(
				data.blood, data.pos, bottom_point)
		elseif FIGHT_TYPE.SHANBI == data.fighttype then
			FightText.Instance:ShowDodge(
				data.pos, floating_point)
		elseif FIGHT_TYPE.LINGCHONG == data.fighttype then
			FightText.Instance:ShowBeLingChongGongji(
				data.blood, data.pos, bottom_point)
		elseif FIGHT_TYPE.GEDANG == data.fighttype then
			FightText.Instance:ShowGeDang(
				data.blood, data.pos, bottom_point, data.text_type)			
		elseif FIGHT_TYPE.HUIXINYIJI == data.fighttype then
			FightText.Instance:ShowBeHuiXinYiJi(
				data.blood, data.pos, bottom_point, data.text_type)
		else
			FightText.Instance:ShowBeHurt(
				data.blood, data.pos, bottom_point)
		end
	end

	GlobalTimerQuest:AddDelayTimer(function()
		if #self.floating_texts > 0 then
			local text = self.floating_texts[1]
			table.remove(self.floating_texts, 1)
			self:PlayFloatingText(text)
		else
			self.floating_data = nil
		end
	end, 0.1)
end

-- 被打(客户端纯表现)
function Character:DoBeHitShow(deliverer, skill_id, target_obj_id)
	-- print_log("++++++++DoBeHitShow+++++++")
	if nil == deliverer then return end
	if not self:IsRealDead() then
		self:EnterFight(deliverer:GetType())
	end

	-- 获取技能配置
	local skill_action = ""
	if deliverer:IsRole() then
		local skill_cfg = SkillData.GetSkillinfoConfig(skill_id)
		if nil ~= skill_cfg then
			skill_action = skill_cfg.skill_action
			if skill_cfg.hit_count > 1 then
				skill_action = skill_action.."_"..deliverer.attack_index
			end
		end
	elseif deliverer:IsMonster() then
		local skill_cfg = SkillData.GetMonsterSkillConfig(skill_id)
		if nil ~= skill_cfg then
			skill_action = skill_cfg.skill_action
		end
	end

	-- 主目标和其他目标之间的受击增加以下随机间隔
	if self.vo.obj_id == target_obj_id then
		self:DoBeHitShowImpl(skill_action, deliverer, skill_id)
	else
		local delay_time = 0.5 * math.random()
		GlobalTimerQuest:AddDelayTimer(function()
			self:DoBeHitShowImpl(skill_action, deliverer, skill_id)
		end, delay_time)
	end
end

function Character:DoBeHitShowImpl(skill_action, deliverer, skill_id)
	if self:IsDeleted() or nil == deliverer or deliverer:IsDeleted() or skill_action == "" then
		return
	end

	local deliverer_main = deliverer.draw_obj:GetPart(SceneObjPart.Main)
	local deliverer_obj = deliverer_main:GetObj()
	if deliverer_obj == nil then
		return
	end

	local attacker_actor_ctrl = deliverer:GetActorCtrl()
	local root = self.draw_obj:GetRoot()
	local hurt_point = self.draw_obj:GetAttachPoint(AttachPoint.Hurt)

	if nil ~= attacker_actor_ctrl and nil ~= hurt_point then
		attacker_actor_ctrl:PlayHurtShow(skill_action, root.transform, hurt_point, function()
			self:DoBeHitShowAction(deliverer, skill_action)
		end)
	end

	local actor_ctrl = self:GetActorCtrl()
	if actor_ctrl then
		actor_ctrl:PlayBeHurt(root)
	end
end

function Character:DoBeHitShowAction(deliverer, skill_action)
	if self:IsDeleted() then
		return
	end
	
	-- 获取角色对象
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	if nil ~= part then
		-- W2这些项目都屏蔽 这里也屏蔽吧
		-- 播放受击音效
		-- AudioManager.PlayAndForget("audios/sfxs/foley", "SFX Impact Iron", part.transform)
		-- 播放受击叫声
		-- if deliverer and not deliverer:IsMainRole() then
		-- 	AudioManager.PlayAndForget(
		-- 		"audios/sfxs/voice/sfxvoicemonstergolemhit", 
		-- 		"SFX_Voice_Monster_Golem_Hit", nil, part.transform)
		-- end

		-- 闪光
		if self.last_bink_time + 0.5 <= Status.NowTime then
			-- if self.prefab_data == nil then
			-- 	print_error("读取prefab数据有误")
			-- 	return
			-- end
			-- local data = self.prefab_data.data
			-- self.actor_ctrl:Blink(part:GetObj(), 
			-- 	data.blinkFadeIn, data.blinkFadeHold, data.blinkFadeOut)
			self.last_bink_time = Status.NowTime
		end
	end
end

function Character:SetBuffList(buff_type_list)
	self.buff_type_list = buff_type_list or {}
	self:AddBuffList()
end

-- buff_type_list是倒过来解析的
function Character:AddBuffList()
	local count = 0
	for k, v in pairs(self.buff_type_list) do
		if v == 0 then
			self:RemoveBuff(k)
		else
			self:AddBuff(k)
			count = count + 1
		end
	end
end

function Character:AddBuff(buff_type)
	if (self.vo.task_appearn and self.vo.task_appearn > 0 and self.vo.task_appearn_param_1 > 0) or (self:IsMainRole() and TaskData.Instance:GetTaskAcceptedIsBeauty()) then
		return
	end
	local buff_effect_loader = self.buff_effect_list[buff_type]
	self.buff_type_list[buff_type] = 1
	if nil == buff_effect_loader then
		local buff_config = BUFF_CONFIG[buff_type]
		if buff_config then
			local draw_obj = self.draw_obj
			-- 女神buff则显示在女神身上
			if buff_config.buff_character == BUFF_CHARACTER.GODDESS then
				if self:IsRole() then
					local goddess_obj = self:GetGoddessObj()
					if goddess_obj then
						draw_obj = goddess_obj:GetDrawObj()
					end
				end
			end
			local attach_obj = draw_obj:GetPart(SceneObjPart.Main):GetAttachPoint(buff_config.attach_index)
			if attach_obj then
				buff_effect_loader = AllocAsyncLoader(self, "buff_effect_loader" .. buff_type)
				buff_effect_loader:SetParent(attach_obj)
				buff_effect_loader:SetIsUseObjPool(true)
				buff_effect_loader:SetIsInQueueLoad(true)
				self.buff_effect_list[buff_type] = buff_effect_loader

				local bundle, asset = nil, nil
				if buff_config.is_noraml_effect == 1 then
					-- 隐私buff特效只对主角有效
					if buff_type == BUFF_TYPE.INVISIBLE then
						if self:IsMainRole() then
							bundle, asset = ResPath.GetBuffEffect(buff_config.effect_id)
						end
					elseif buff_type == BUFF_TYPE.SUPER_MIANYI then
						if self:IsRole() then
							bundle, asset = ResPath.GetBuffEffect(buff_config.effect_id)
						end
					elseif buff_type == BUFF_TYPE.EBT_BIND_DONG then
						if self:IsRole() then
							bundle, asset = ResPath.GetZhenfaEffect(buff_config.effect_id)
						end
					elseif buff_type == BUFF_TYPE.GCZCZ_SKILL then
						if self:IsRole() then
							bundle, asset = ResPath.GetZhenfaEffect(buff_config.effect_id)
						end
					elseif buff_type == BUFF_TYPE.EBT_ZHUANZHI_ADD_FANGYU then		-- 专职技能特殊处理每个职业的特效
						if self:IsRole() then
							local base_prof = PlayerData.Instance:GetRoleBaseProf(self.vo.prof)
							bundle, asset = ResPath.GetRoleEffects(GameEnum.ROLE_PROF_MODEL[base_prof])
						end
					else
						bundle, asset = ResPath.GetBuffEffect(buff_config.effect_id)
					end
				else
					bundle, asset = ResPath.GetEffectBoss(buff_config.effect_id)
				end

				if nil ~= bundle and nil ~= asset then
					buff_effect_loader:Load(bundle, asset)
				end
			else
				self.buff_type_list[buff_type] = 1
			end
		else
			self.buff_effect_list[buff_type] = AllocAsyncLoader(self, "buff_effect_loader_" .. buff_type)
		end
	end
	if self:IsXuanYun() or self:IsDingShen() or self:IsBingDong() then
		self:ChangeToCommonState()
	end
	if Scene.Instance:GetSceneType() == SceneType.HotSpring then
		if buff_type == BUFF_TYPE.XUANYUN then
			-- 如果没有在皮艇上
			if nil == Scene.Instance:GetBoatByRole(self:GetObjId()) then
				local part = self.draw_obj:GetPart(SceneObjPart.Main)
				part:SetBool(ANIMATOR_PARAM.HURT, true)
			end
		end
	end

	if self:IsRole() then
		if buff_type == BUFF_TYPE.EBT_MOHUA then
			self.draw_obj:GetRoot().transform:DOScale(Vector3(1.3, 1.3, 1.3), 0.3)
		elseif buff_type == BUFF_TYPE.INVISIBLE then
			self:SetAttr("is_yinshen", 1)
			if self:IsMainRole() then
				local main_role = Scene.Instance:GetMainRole()
				if main_role then
					local draw_obj = main_role:GetDrawObj()
					if draw_obj then
					local prof = PlayerData.Instance:GetRoleBaseProf()
						draw_obj:SetYinShenMaterial(true, prof)
					end
				end
			end
			self:SetRoleVisible()
		elseif buff_type == BUFF_TYPE.EBT_TALENT_WING_SKILL then
			self:SetHunLuanState(true)
		end
	end

	if buff_type == BUFF_TYPE.EBT_PINK_EQUIP_NARROW then
		local scale = self.obj_scale or 1.0
		self.draw_obj:GetRoot().transform:DOScale(Vector3(scale - 0.3, scale - 0.3, scale - 0.3), 0.3)
	end

	if buff_type == BUFF_TYPE.EBT_TALENT_MOUNT_SKILL then
		if not self.substitutes_obj then
			self.substitutes_obj = Scene.Instance:CreateSubstitutesObjByCharacter(self)
		end
	end
end

function Character:RemoveBuff(buff_type)
	self.buff_type_list[buff_type] = 0
	if self:IsXuanYun() or self:IsDingShen() or self:IsBianxingFool() or self:IsBingDong() then
		if self:IsAtk() then
			self:DoStand()
		end
	end

	local buff_effect = self.buff_effect_list[buff_type]
	if nil ~= buff_effect then
		buff_effect:Destroy()
		buff_effect:DeleteMe()
		self.buff_effect_list[buff_type] = nil
	end
	if Scene.Instance:GetSceneType() == SceneType.HotSpring then
		if buff_type == BUFF_TYPE.XUANYUN then
			local part = self.draw_obj:GetPart(SceneObjPart.Main)
			part:SetBool(ANIMATOR_PARAM.HURT, false)
		end
	end

	if self:IsRole() then
		if buff_type == BUFF_TYPE.EBT_MOHUA then
			local scale = self.obj_scale or 1.0
			self.draw_obj:GetRoot().transform:DOScale(Vector3(scale, scale, scale), 0.3)
		elseif buff_type == BUFF_TYPE.INVISIBLE then
			self:SetAttr("is_yinshen", 0)
			if self:IsMainRole() then
				local main_role = Scene.Instance:GetMainRole()
				if main_role then
					local draw_obj = main_role:GetDrawObj()
					if draw_obj then
					local prof = PlayerData.Instance:GetRoleBaseProf()
						draw_obj:SetYinShenMaterial(false, prof)
					end
				end
			end
			self:SetRoleVisible()
		elseif buff_type == BUFF_TYPE.EBT_TALENT_WING_SKILL then
			self:SetHunLuanState(false)
		end
	end

	if buff_type == BUFF_TYPE.EBT_PINK_EQUIP_NARROW then
		local scale = self.obj_scale or 1.0
		self.draw_obj:GetRoot().transform:DOScale(Vector3(scale, scale, scale), 0.3)
	end

	if buff_type == BUFF_TYPE.EBT_TALENT_MOUNT_SKILL then
		if self.substitutes_obj then
			Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.Substitutes, self.substitutes_obj:GetObjKey())
			self.substitutes_obj = nil
		end
	end

end

function Character:AddEffect(res, attach_index)
	if self.other_effect_list[res] then return end
	attach_index = attach_index or 0
	local attach_obj = self.draw_obj:GetPart(SceneObjPart.Main):GetAttachPoint(attach_index)
	if attach_obj then
		self.other_effect_list[res] = {
			eff = AllocAsyncLoader(self, "res_loader" .. res), 
			time = Status.NowTime + 2
		}
		local bundle, asset = ResPath.GetEffect(res)
		self.other_effect_list[res].eff:SetParent(attach_obj)
		self.other_effect_list[res].eff:Load(bundle, asset)
	end
end

function Character:SetHunLuanState(is_hunluan)
	if nil ~= self.fear_time_quest then
		GlobalTimerQuest:CancelQuest(self.fear_time_quest)
		self.fear_time_quest = nil
	end

	if is_hunluan then
		local operate_fun = function()
			local team_run_pos_list = {{x = -3, y = 3}, {x = 3, y = 3}, {x = -3, y = -3}, {x = 3, y = -3}}
			self.cur_pos_index = self.cur_pos_index + 1
			if self.cur_pos_index > 4 then
				self.cur_pos_index = 1
			end
			local to_pos = team_run_pos_list[self.cur_pos_index]
			self:DoMove(self.temp_real_logic_pos_x + to_pos.x, self.temp_real_logic_pos_y + to_pos.y)
		end

		self.cur_pos_index = 1
		self.temp_real_logic_pos_x, self.temp_real_logic_pos_y = self:GetLogicPos()
		self.fear_time_quest = GlobalTimerQuest:AddRunQuest(operate_fun, 0.5)
	else
		if nil ~= self.temp_real_logic_pos_x and nil ~= self.temp_real_logic_pos_y then
			self:DoMove(self.temp_real_logic_pos_x, self.temp_real_logic_pos_y)
			self.temp_real_logic_pos_x = nil
			self.temp_real_logic_pos_y = nil
		end
	end
end

function Character:RotateTo(rotate_to_angle)
	self.rotate_to_angle = rotate_to_angle
	self:GetDrawObj():Rotate(0, rotate_to_angle, 0)
end

-- 击退、冲锋、拉人等技能产生的效果
function Character:OnSkillResetPos(skill_id, reset_pos_type, pos_x, pos_y)
	if self.logic_pos.x == pos_x and self.logic_pos.y == pos_y then
		return
	end
	self.reset_x = pos_x
	self.reset_y = pos_y
end

-- 是否眩晕
function Character:IsXuanYun()
	return nil ~= self.buff_effect_list[BUFF_TYPE.XUANYUN]
end

-- 是否定身
function Character:IsDingShen()
	return nil ~= self.buff_effect_list[BUFF_TYPE.DINGSHEN]
end

-- 是否沉默
function Character:IsChenMo()
	return nil ~= self.buff_effect_list[BUFF_TYPE.CHENMO]
end

-- 是否变形不可攻击
function Character:IsBianxingFool()
	return nil ~= self.buff_effect_list[BUFF_TYPE.BIANXING_FOOL]
end

-- 是否迟缓
function Character:IsChiHuan()
	return nil ~= self.buff_effect_list[BUFF_TYPE.CHIHUAN]
end

-- 是否有护盾
function Character:IsHudun()
	return nil ~= self.buff_effect_list[BUFF_TYPE.HPSTORE]
end

-- 是否有冰冻
function Character:IsBingDong()
	return nil ~= self.buff_effect_list[BUFF_TYPE.EBT_BIND_DONG]
end

-- 是否飞行任务(不能操作走路)
function Character:IsFlyTask()
	return self.fly_task
end

-- 是否飞行任务(不能操作走路)
function Character:SetFlyTask(fly_task)
	self.fly_task = fly_task
end

----------------------------------------------------
-- 飞行逻辑(任务表现的)
----------------------------------------------------
function Character:SetFlyMaxHeight(fly_max_height)
	self.fly_max_height = fly_max_height
end

function Character:GetFlyMaxHeight()
	return self.fly_max_height
end

function Character:SetFlyUpUseTime(flying_up_use_time)
	self.flying_up_use_time = flying_up_use_time
end

function Character:GetFlyUpUseTime()
	return self.flying_up_use_time
end

function Character:SetFlyDownUseTime(flying_down_use_time)
	self.flying_down_use_time = flying_down_use_time
end

function Character:GetFlyDownUseTime()
	return self.flying_down_use_time
end

function Character:GetFlyingProcess()
	return self.flying_process
end

function Character:GetIsFlying()
	return self.flying_process ~= FLYING_PROCESS_TYPE.NONE_FLYING
end

-- 开始上升
function Character:StartFlyingUp()
	if self.flying_process == FLYING_PROCESS_TYPE.FLYING_UP then return end
	self.flying_process = FLYING_PROCESS_TYPE.FLYING_UP
end

-- 开始下降
function Character:StartFlyingDown()
	if self.flying_process == FLYING_PROCESS_TYPE.FLYING_DOWN then return end
	self.flying_process = FLYING_PROCESS_TYPE.FLYING_DOWN
end

-- 上升过程处理函数
function Character:OnFlyingUpProcess()
	-- body
end

-- 下降过程处理函数
function Character:OnFlyingDownProcess()
	-- body
end

-- 上升结束
function Character:OnFlyingUpEnd()
	if self.flying_process == FLYING_PROCESS_TYPE.FLYING_IN_MAX_HEIGHT then return end
	self.flying_process = FLYING_PROCESS_TYPE.FLYING_IN_MAX_HEIGHT
end

-- 下降结束
function Character:OnFlyingDownEnd()
	if self.flying_process == FLYING_PROCESS_TYPE.NONE_FLYING then return end
	self.flying_process = FLYING_PROCESS_TYPE.NONE_FLYING
end

function Character:UpdateFlying(now_time, elapse_time)
	if self.flying_process == FLYING_PROCESS_TYPE.NONE_FLYING then return end
	local is_flying_up_end = false
	local is_flying_down_end = false

	if self.flying_process == FLYING_PROCESS_TYPE.FLYING_UP then		--起飞中
		if self.flying_height >= self.fly_max_height then
			self.flying_height = self.fly_max_height
			is_flying_up_end = true
		else
			if self.flying_up_use_time > 0 then
				local up_speed = self.fly_max_height / self.flying_up_use_time
				self.flying_height = self.flying_height + up_speed * elapse_time
			end
		end
		self:OnFlyingUpProcess()
	end

	if self.flying_process == FLYING_PROCESS_TYPE.FLYING_DOWN then		--降落中
		if self.flying_height <= 0 then
			self.flying_height = 0
			is_flying_down_end = true
		else
			if self.flying_down_use_time > 0 then
				local down_speed = self.fly_max_height / self.flying_down_use_time
				self.flying_height = self.flying_height - down_speed * elapse_time
			end
		end
		self:OnFlyingDownProcess()
	end

	if self.flying_process == FLYING_PROCESS_TYPE.FLYING_IN_MAX_HEIGHT then	--最高处平稳飞行中
		self.flying_height = self.fly_max_height
	end

	self.draw_obj:SetOffset(Vector3(0, self.flying_height, 0))
	if is_flying_up_end then self:OnFlyingUpEnd() end
	if is_flying_down_end then self:OnFlyingDownEnd() end
end
----------------------------------------------------
-- 飞行逻辑结束
----------------------------------------------------

function Character:OnModelLoaded(part, obj)
	SceneObj.OnModelLoaded(self, part, obj)
	if part == SceneObjPart.Main then
		self:AddBuffList()
	end
end

function Character:OnModelRemove(part, obj)
	SceneObj.OnModelRemove(self, part, obj)
	if part == SceneObjPart.Main then
		for k,v in pairs(self.buff_effect_list) do
			v:DeleteMe()
		end
		self.buff_effect_list = {}
	end
end

-- 播放角色身上变身特效展示
function Character:SetRoleEffect(bundle, asset, duration)
	if self.draw_obj then
		local transform = self.draw_obj:GetTransfrom()
		ResPoolMgr:GetEffectAsync(bundle, asset, function(prefab)
			if nil == prefab then
				return
			end
			if transform then
				local obj_transform = prefab.transform
				obj_transform:SetParent(transform, false)
				self.effect_obj = prefab
				GlobalTimerQuest:AddDelayTimer(function()
					if self.effect_obj then
						ResPoolMgr:Release(prefab)
						self.effect_obj = nil
					end
				end, duration)
			else
				ResPoolMgr:Release(prefab)
				self.effect_obj = nil
			end
		end)
	end
end
