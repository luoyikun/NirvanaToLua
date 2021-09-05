FlyPetObj = FlyPetObj or BaseClass(SceneObj)

local base_speed = 2 
local base_rota_speed = 5

local STATUS = {
	PARK = 0, 			-- 停靠
	ENCIRCLING = 1, 	-- 环绕
	FOLLOW = 2, 		-- 跟随
	RANDOM_FLY = 3, 	-- 随机飞行
}

local Vec3Up = Vector3.up

local encircling_target_list = {
	[1] = Vector3(0, 0.5 ,2.5),
	[2] = Vector3(2.5, 1 ,0),
	[3] = Vector3(0, 1.5 ,-2.5),
	[4] = Vector3(-2.5, 2 ,0),
	[5] = Vector3(0, 2.5 ,2.5),
	[6] = Vector3(2.5, 3 ,0),
	[7] = Vector3(0, 3.5 ,-2.5),
	[8] = Vector3(-2.5, 4 ,0),
}


-- 飞宠
function FlyPetObj:__init(flypet_vo)
	self.obj_type = SceneObjType.FlyPetObj
	self:SetObjId(flypet_vo.obj_id)
	self.vo = flypet_vo
	self.status = STATUS.PARK
	self.think_time = 0
	self.encircling_index = 1
	self.model_is_load = false
	self.max_think_time = 5
	self.is_visible = true
	self.rota_animator_speed = 0
	self.posi_animator_speed = 0
	self.second_time = 0
	self.cur_position = nil
	self.random_fly_target_position = nil
	self.is_active_follow_ui_root = true
	self.is_main_role_owner = false
end

function FlyPetObj:__delete()
	if self.random_fly_timer then
		GlobalTimerQuest:CancelQuest(self.random_fly_timer)
		self.random_fly_timer = nil
	end
	if self.get_main_part_timer then
		GlobalTimerQuest:CancelQuest(self.get_main_part_timer)
		self.get_main_part_timer = nil
	end
	self.vo.owner_role = nil
end

function FlyPetObj:InitShow()
	SceneObj.InitShow(self)

	if self:GetFollowUi() then
		local name_str = self.vo.name
		self:GetFollowUi():SetName(name_str)
		self:GetFollowUi():SetTextPosY(70)
		self:UpdateFollowUi()
	end
end

function FlyPetObj:OnModelLoaded(part, obj)
	SceneObj.OnModelLoaded(self, part, obj)
	self.obj = obj
	self.animator = self.obj:GetComponent(typeof(UnityEngine.Animator))
	self:GetMainPart()
end

function FlyPetObj:GetMainPart()
	if nil == self.vo.owner_role then
		return
	end	

	self.is_main_role_owner = self.vo.owner_role:IsMainRole()
	self.owner_main_part_obj = self.vo.owner_role.draw_obj:GetPart(SceneObjPart.Main).obj 			-- 角色main_part
	if self.owner_main_part_obj == nil then
		self.get_main_part_timer = GlobalTimerQuest:AddDelayTimer(function()
			self:GetMainPart()
		end, 1)
		return
	end


	self.root_obj = self:GetRoot()							-- 飞宠根节点
	self.owner_obj = self.vo.owner_role.draw_obj.root 												-- 角色
	-- self.owner_r_arm = self:FindInChildren(self.owner_main_part_obj, "Bip001 R UpperArm")   		-- 角色右肩
	-- if self.owner_r_arm == nil then
	-- 	print_warning("Bip001 R UpperArm didn't find")
	-- end
	self.root_obj.transform.position = self.owner_main_part_obj.transform.position + self.owner_main_part_obj.transform.forward * -2.5 + Vec3Up * 4 + self.owner_main_part_obj.transform.right
	self.model_is_load = true
end

-- 角色时装更变的时候调用
function FlyPetObj:UpdateOwnerData()
	-- if self.model_is_load and self.vo.owner_role then
	-- 	self.owner_obj = self.vo.owner_role.draw_obj.root
	-- 	self.owner_main_part_obj = self.vo.owner_role.draw_obj:GetPart(SceneObjPart.Main).obj
	-- 	if self.owner_main_part_obj == nil then
	-- 		return
	-- 	end
	-- 	self.owner_r_arm = self:FindInChildren(self.owner_main_part_obj, "Bip001 R UpperArm")
	-- 	if self.owner_r_arm == nil then
	-- 		print_warning("Bip001 R UpperArm didn't find")
	-- 	end
	-- end
end

function FlyPetObj:ResetTransform(transform)
	transform:SetLocalPosition(0,0,0)
	transform.rotation = Vector3(0,0,0)
	transform:SetLocalScale(1,1,1)
end

function FlyPetObj:IsCharacter()
	return false
end

function FlyPetObj:IsFlyPet()
	return true
end

function FlyPetObj:GetAttr(key)
	return self.vo[key]
end

function FlyPetObj:SetAttr(key, value)
	if key == "flypet_used_imageid" and FlyPetData.Instance then
		local res_id = FlyPetData.Instance:GetResIdByImageId(value)
		self:ChangeModel(SceneObjPart.Main, ResPath.GetFlyPetModel(res_id))
	elseif key == "name" then
		if self.follow_ui then
			local name_str = value
			self.follow_ui:SetName(name_str)
			self:UpdateFollowUi()
		end
	end
	self.vo[key] = value
end

function FlyPetObj:Update(now_time, elapse_time)
	SceneObj.Update(self, now_time, elapse_time)
	if not self.model_is_load then
		return
	end
	if self.obj and self.owner_obj and self.owner_main_part_obj and not IsNil(self.owner_main_part_obj.transform) and
		self.animator and not IsNil(self.animator) then
		self:StatusControl(now_time, elapse_time)

		if self.is_main_role_owner then
			self:ParkUpdate(now_time, elapse_time)
			self:EncirclingUpdate(now_time, elapse_time)
			self:RandomFlyUpdate(now_time, elapse_time)
		end

		self:FollowUpdate(now_time, elapse_time)
		self.animator.speed = self.rota_animator_speed + self.posi_animator_speed + 1
	end
end

-- 状态更变控制
function FlyPetObj:StatusControl(now_time, elapse_time)
	self.think_time = self.think_time + elapse_time
  	local owner_idle = self:GetOwnerMainPartIsIdle()
  	local owner_fight = self:GetOwnerMainPartIsFight()
  	if self.think_time > self.max_think_time then
  		self.think_time = 0
  		if owner_idle == true and owner_fight == false then
	  		local random = math.random(0, 100)
	  		if random > 60 and self.owner_r_arm ~= nil then
	  			self:ChangeStatus(STATUS.PARK)
	  		elseif random > 30 then
	  			self:ChangeStatus(STATUS.RANDOM_FLY)
	  		else
	  			self:ChangeStatus(STATUS.ENCIRCLING)
	  		end
	  	end
  	end

  	if owner_idle == false and owner_fight == false then
  		self:ChangeStatus(STATUS.FOLLOW)
  		self.think_time = 0
  	elseif owner_fight == true then 
	  	self:ChangeStatus(STATUS.RANDOM_FLY)
  		self.think_time = 0
  	end

  	if self.status == STATUS.PARK and not self.owner_r_arm then
  		self:ChangeStatus(STATUS.RANDOM_FLY)
  	end
end

-- 更改状态
function FlyPetObj:ChangeStatus(new_status)
	if self.status ~= new_status then
		self:OutStatus(self.status)
		self:EnterStatus(new_status)
	end
	self.status = new_status
end

-- 离开状态处理
function FlyPetObj:OutStatus(old_status)
	if old_status == STATUS.PARK then
		
	elseif old_status == STATUS.ENCIRCLING then
		self.cur_position = nil
		self.second_time = 0
	elseif old_status == STATUS.FOLLOW then

	elseif old_status == STATUS.RANDOM_FLY then
		self.random_fly_target_position = nil
		if self.random_fly_timer then
			GlobalTimerQuest:CancelQuest(self.random_fly_timer)
			self.random_fly_timer = nil
		end
		self.cur_target_complete = true
	end
end

-- 进入状态处理
function FlyPetObj:EnterStatus(new_status)
	if new_status == STATUS.PARK then
		self.max_think_time = math.random(5, 10)
	elseif new_status == STATUS.ENCIRCLING then
		self.max_think_time = 15
	elseif new_status == STATUS.FOLLOW then
		self.max_think_time = 5
	elseif new_status == STATUS.RANDOM_FLY then
		self.max_think_time = 15
	end
end

-- 停靠状态
function FlyPetObj:ParkUpdate(now_time, elapse_time)
	if self.status == STATUS.PARK then
		if not self.owner_r_arm then
			return
		end
		local target_position = self.owner_r_arm.transform.position + self.owner_main_part_obj.transform.right * 0.06 --向右偏移0.06个单位
		local dir = target_position - self.root_obj.transform.position
		local dis = dir.sqrMagnitude

		-- local arm_position = Vector3(target_position.x, target_position.y, target_position.z)
		-- local par_position = self.root_obj.transform.position
		-- arm_position.y = 0
		-- par_position.y = 0
		-- local hori_dir = arm_position - par_position 		
		-- local hori_dis = hori_dir.magnitude 			--水平距离

		local speed = base_speed
		if dis > 25 then
			speed = base_speed + dis
		elseif  dis < 1 then
			speed = dis * base_speed
		end

		self:RotaTo(now_time, elapse_time, target_position)
		local parent_position = self.root_obj.transform.position
	 	self.root_obj.transform.position = parent_position + self.root_obj.transform.forward * speed * elapse_time

		-- if dis > 0.1 then
			-- if hori_dis > 2 then
			-- 	self:RotaTo(now_time, elapse_time, target_position + Vector3(0, 3 ,0))
			-- else
			-- 	self:RotaTo(now_time, elapse_time, target_position)
			-- end

		-- else
		-- 	self.root_obj.transform.position = target_position
		-- 	self:RotaTo(now_time, elapse_time, self.owner_main_part_obj.transform.position + self.owner_main_part_obj.transform.forward * 99999)
		-- end
	end
end

-- 跟随状态
function FlyPetObj:FollowUpdate(now_time, elapse_time)
	if self.status == STATUS.FOLLOW then
		local dir = self.owner_main_part_obj.transform.position - self.root_obj.transform.position
		local dis = dir.magnitude
		local speed = base_speed
		if dis > 4 then
			speed = speed + dis
		end
		local target_position = self.owner_main_part_obj.transform.position + self.owner_main_part_obj.transform.forward * -2.5 + Vec3Up * 4 + self.owner_main_part_obj.transform.right
		local is_complete = self:FlyTo(now_time, elapse_time, target_position, speed)
		if is_complete then
			self:RotaTo(now_time, elapse_time, self.owner_main_part_obj.transform.position + self.owner_main_part_obj.transform.forward * 99999)
		end
	end
end

-- 随机飞行状态
function FlyPetObj:RandomFlyUpdate(now_time, elapse_time)
	if self.status == STATUS.RANDOM_FLY then
		if not self.random_fly_target_position then
			self.random_fly_target_position = self:GetRandomFlyTarget()
		end
		if self.cur_target_complete then
			self.cur_target_complete = false
			self.random_fly_target_position = self:GetRandomFlyTarget()
		end

		local speed = base_speed
		local dis = (self.random_fly_target_position - self.root_obj.transform.position).magnitude
		if dis > 5 then
			speed = speed + dis / 2
		end

		local is_complete = self:FlyTo(now_time, elapse_time, self.random_fly_target_position, speed)

		if is_complete then
			local rota_position = self.root_obj.transform.position + self.root_obj.transform.forward * 1000
			rota_position.y = self.root_obj.transform.position.y
			self:RotaTo(now_time, elapse_time, rota_position, base_rota_speed / 3)
			if not self.random_fly_timer then
				self.random_fly_timer = GlobalTimerQuest:AddDelayTimer(function()
					self.cur_target_complete = true
					self.random_fly_timer = nil
				end, 5)
			end
		end
	end
end

-- 环绕主角状态
function FlyPetObj:EncirclingUpdate(now_time, elapse_time)
	if self.status == STATUS.ENCIRCLING then
		if not self.cur_position then
			self.cur_position = self.root_obj.transform.position
		end
		local target_position = self.owner_main_part_obj.transform.position + encircling_target_list[self.encircling_index]

		local dis = (target_position - self.cur_position).magnitude
		self.second_time = self.second_time + elapse_time / dis * base_speed
		self.root_obj.transform.position = self:CalBezierPosition(self.second_time, self.cur_position, self:CalPosition2(self.cur_position ,target_position), target_position)
		local look_target = self.root_obj.transform.position + (self:CalBezierPosition(self.second_time + 0.1, self.cur_position, self:CalPosition2(self.cur_position ,target_position), target_position) - self.root_obj.transform.position) * 10

		if self.second_time >= 1 then
			self.second_time = 0
			self.cur_position = target_position
			self.encircling_index = self.encircling_index + 1
			if self.encircling_index > #encircling_target_list then
				self.encircling_index = 1
			end
		else
			self:RotaTo(now_time, elapse_time, look_target, base_rota_speed / 3)
		end
	end
end

function FlyPetObj:CalBezierPosition(t, p1, p2 ,p3)
	if t > 1 or t < 0 then
		t = 1
	end
  	local result = p1 * (1 - t) * (1 - t) + p2 * 2 * t * (1 - t) + p3 * t * t
  	return result
end

function FlyPetObj:CalPosition2(p1, p3)
	local mid_position = p1 + (p3 - p1) / 2
	local owner_main_part_position = self.owner_main_part_obj.transform.position + Vec3Up * 2
	local p2 = (mid_position - owner_main_part_position) / 2 + mid_position
	return p2
end

-- 飞行到目标位置
function FlyPetObj:FlyTo(now_time, elapse_time, target_position, speed, rota_speed)
	speed = speed or base_speed
	rota_speed = rota_speed or base_rota_speed
	local dir = target_position - self.root_obj.transform.position
	local dis = dir.magnitude
	if dis < 1 then
		rota_speed = 5
		speed = dis * base_speed + 0.2
	end

	self.posi_animator_speed = speed / 4
	if dis > 0.05 then
		local parent_position = self.root_obj.transform.position
	    self:RotaTo(now_time, elapse_time, target_position + target_position - self.root_obj.transform.position, rota_speed)
	   	self.root_obj.transform.position = parent_position + self.root_obj.transform.forward * speed * elapse_time
	   	return false
	else
		self.root_obj.transform.position = target_position
		return true
	end
end

-- 旋转到目标
function FlyPetObj:RotaTo(now_time, elapse_time, look_position, rota_speed)
	rota_speed = rota_speed or base_rota_speed
	local dir = look_position - self.root_obj.transform.position
	local angle = Vector3.Angle(dir, self.root_obj.transform.forward)
	self.rota_animator_speed = angle / 40
	if dir.x ~= 0 or dir.y ~= 0 or dir.z ~= 0 then
		local target_rotation = Quaternion.LookRotation(dir, Vec3Up);

		if self.is_main_role_owner then
			self.root_obj.transform.rotation = Quaternion.Slerp(self.root_obj.transform.rotation, target_rotation, elapse_time * rota_speed);
		else
			self.root_obj.transform.rotation = target_rotation
		end
	end
end

-- 查找子物体
function FlyPetObj:FindInChildren(target, name)
    local result_transform = target.transform:Find(name);
    if not result_transform then
    	local children = target.gameObject:GetComponentsInChildren(typeof(UnityEngine.Transform))
     	for i = 0, children.Length - 1 do
    		result_transform = children[i].transform:Find(name);
    		if result_transform then
    			return result_transform
    		end
    	end
    end
    return result_transform
end

-- 计算并获得随机飞行的目标
function FlyPetObj:GetRandomFlyTarget()
	local random_symbol = math.random(-1, 1)
	local random_x = random_symbol < 0 and math.random(-2, -0.5) or math.random(0.5, 2)
	local random_y = math.random(1, 6)
	random_symbol = math.random(-1, 1)
	local random_z = random_symbol < 0 and math.random(-2, -0.5) or math.random(0.5, 2)
	local forward_offset = self.owner_main_part_obj.transform.forward * random_z
	local up_offset = self.owner_main_part_obj.transform.up * random_y
	local right_offset = self.owner_main_part_obj.transform.right * random_x
	return self.owner_main_part_obj.transform.position + forward_offset + up_offset + right_offset
end

-- 获得角色动画是否处于idle状态
function FlyPetObj:GetOwnerMainPartIsIdle()
	if nil == self.vo.owner_role then
		return
	end		
  	local owner_idle = false
  	local owner_main_part = self.vo.owner_role.draw_obj:GetPart(SceneObjPart.Main)
  	if owner_main_part then
	  	local owner_animator_status = owner_main_part:GetInteger(ANIMATOR_PARAM.STATUS)
	  	if owner_animator_status == ActionStatus.Idle then
	  		owner_idle = true
	  	end
	 end
	 return owner_idle
end

-- 获得角色动画是否处于战斗状态
function FlyPetObj:GetOwnerMainPartIsFight()
	if nil == self.vo.owner_role then
		return
	end	
  	local owner_fight = false
  	local owner_main_part = self.vo.owner_role.draw_obj:GetPart(SceneObjPart.Main)
  	if owner_main_part then
	  	local owner_animator_fight = owner_main_part:GetBool(ANIMATOR_PARAM.FIGHT)
	  	if owner_animator_fight == true then
	  		owner_fight = true
	  	end
	 end
	 return owner_fight
end

function FlyPetObj:ChangeVisible(is_visible)
	self.is_visible = is_visible

	local draw_obj = self:GetDrawObj()
	if draw_obj then
		draw_obj:SetVisible(is_visible)

		if is_visible then
			self:ChangeFlyPetModel()
		end
	end
	self:UpdateFollowUi()
end

function FlyPetObj:ChangeFlyPetModel()
	if not self.vo.flypet_used_imageid or self.vo.flypet_used_imageid <= 0 or not self.is_visible then
		self:RemoveModel(SceneObjPart.Main)
		return
	end

	local res_id = FlyPetData.Instance:GetResIdByImageId(self.vo.flypet_used_imageid)
	self:ChangeModel(SceneObjPart.Main, ResPath.GetFlyPetModel(res_id))
end

function FlyPetObj:UpdateFollowUi()
	if self.follow_ui then
		if self.is_visible then
			self.follow_ui:Show()
		else
			self.follow_ui:Hide()
		end
	end
end