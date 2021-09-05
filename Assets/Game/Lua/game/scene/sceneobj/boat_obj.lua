BoatObj = BoatObj or BaseClass(SceneObj)

-- 温泉皮艇
function BoatObj:__init(boat_vo)
	self.obj_type = SceneObjType.BoatObj
	self:SetObjId(boat_vo.obj_id)
	self.vo = boat_vo

	self.res_id = 2097001

	self.boy_boy_res_id = 2095001
	self.boy_girl_res_id = 2094001
	self.girl_girl_res_id = 2096001

	self.mount_point_r = nil
	self.mount_point_l = nil

	self.timer = 0

	self.modle_is_loading = false
	self.modle_is_loaded = false
	self.last_select_obj_id = -1
	self.boy_origin_logic_pos = nil
	self.girl_origin_logic_pos = nil
end

function BoatObj:__delete()
	local boy_obj = Scene.Instance:GetObjectByObjId(self.vo.boy_obj_id)
	local girl_obj = Scene.Instance:GetObjectByObjId(self.vo.girl_obj_id)

	if nil ~= boy_obj and nil ~= boy_obj:GetRoot() and not IsNil(boy_obj:GetRoot().gameObject) then
		if nil ~= self.boy_origin_logic_pos then
			boy_obj:SetLogicPos(self.boy_origin_logic_pos.x, self.boy_origin_logic_pos.y)
		end

		local boy_main_part_obj = boy_obj.draw_obj:_TryGetPartObj(SceneObjPart.Main)
		if nil ~= boy_main_part_obj then
			boy_main_part_obj.transform:SetParent(boy_obj.draw_obj.root.transform)
			self:ResetTransform(boy_main_part_obj.transform)
		end

		local boy_main_part = boy_obj.draw_obj:GetPart(SceneObjPart.Main)
		boy_main_part:SetInteger(ANIMATOR_PARAM.STATUS, 0)
		boy_obj:CheckWaterArea()
	end

	if nil ~= girl_obj and nil ~= girl_obj:GetRoot() and not IsNil(girl_obj:GetRoot().gameObject) then
		if nil ~= self.girl_origin_logic_pos then
			girl_obj:SetLogicPos(self.girl_origin_logic_pos.x, self.girl_origin_logic_pos.y)
		end

		local girl_main_part_obj = girl_obj.draw_obj:_TryGetPartObj(SceneObjPart.Main)
		if nil ~= girl_main_part_obj then
			girl_main_part_obj.transform:SetParent(girl_obj.draw_obj.root.transform)
			self:ResetTransform(girl_main_part_obj.transform)
		end

		local girl_main_part = girl_obj.draw_obj:GetPart(SceneObjPart.Main)
		girl_main_part:SetInteger(ANIMATOR_PARAM.STATUS, 0)
		girl_obj:CheckWaterArea()

		if self.vo.action_type == HOTSPRING_ACTION_TYPE.MASSAGE then
			local name = ""
			if boy_obj then
				name = boy_obj.vo.name
			end
			FollowBubble.BUBBLE_VIS = false
			girl_obj:GetFollowUi():ShowBubble()
			girl_obj:GetFollowUi():ChangeBubble(string.format(Language.HotString.MassageText, name), 3)
		end
	end
	self.mount_point_r = nil
	self.mount_point_l = nil
end

function BoatObj:InitShow()
	Character.InitShow(self)

	self.name = self.vo.name

	self:CheckModelLoaded()

	if self.draw_obj then
		self.draw_obj:SetWaterHeight(0)
		local scene_logic = Scene.Instance:GetSceneLogic()
		if scene_logic then
			local flag = scene_logic:IsCanCheckWaterArea() and true or false
			self.draw_obj:SetCheckWater(flag)
		end
	end
end

function BoatObj:CheckModelLoaded()
	if self.modle_is_loading or self.modle_is_loaded then
		return
	end

	local boy_obj = Scene.Instance:GetObjectByObjId(self.vo.boy_obj_id)
	local girl_obj = Scene.Instance:GetObjectByObjId(self.vo.girl_obj_id)
	if boy_obj and girl_obj then
		self.boy_origin_logic_pos = {}
		self.boy_origin_logic_pos.x, self.boy_origin_logic_pos.y = boy_obj:GetLogicPos()
		self.girl_origin_logic_pos = {}
		self.girl_origin_logic_pos.x, self.girl_origin_logic_pos.y = girl_obj:GetLogicPos()

		local pos_x, pos_y = self:GetLogicPos()
		boy_obj:SetLogicPos(pos_x, pos_y)
		girl_obj:SetLogicPos(pos_x, pos_y)

		if self.vo.action_type ~= HOTSPRING_ACTION_TYPE.MASSAGE then
			local boy_vo_sex = boy_obj:GetVo().sex
			local girl_vo_sex = girl_obj:GetVo().sex

			if boy_vo_sex == girl_vo_sex and boy_obj:GetVo().sex == 1 then
				self:ChangeModel(SceneObjPart.Main, ResPath.GetMonsterModel(self.boy_boy_res_id))
			elseif boy_vo_sex == girl_vo_sex and boy_obj:GetVo().sex ~= 1 then
				self:ChangeModel(SceneObjPart.Main, ResPath.GetMonsterModel(self.girl_girl_res_id))
			elseif boy_vo_sex ~= girl_vo_sex then
				self:ChangeModel(SceneObjPart.Main, ResPath.GetMonsterModel(self.boy_girl_res_id))
			end
		else
			if self.res_id ~= nil and self.res_id ~= 0 then
				self:ChangeModel(SceneObjPart.Main, ResPath.GetMonsterModel(self.res_id))
			end
		end

		self.modle_is_loading = true
	end
end

function BoatObj:OnModelLoaded(part, obj)
	SceneObj.OnModelLoaded(self, part, obj)
	if part == SceneObjPart.Main then
		self.mount_point_l = obj.transform:FindByName("mount_point")
		self.mount_point_r = obj.transform:FindByName("mount_point01")

		local boy_obj = Scene.Instance:GetObjectByObjId(self.vo.boy_obj_id)
		local girl_obj = Scene.Instance:GetObjectByObjId(self.vo.girl_obj_id)

		if nil ~= boy_obj and nil ~= boy_obj:GetRoot() and not IsNil(boy_obj:GetRoot().gameObject) then
			local obj = boy_obj.draw_obj:_TryGetPartObj(SceneObjPart.Main)
			if nil ~= obj then
				obj.gameObject.transform:SetParent(self.mount_point_l)
				local boy_main_part = boy_obj.draw_obj:GetPart(SceneObjPart.Main)
				if boy_main_part then
					if self.vo.action_type == HOTSPRING_ACTION_TYPE.SHUANG_XIU then
						boy_main_part:SetInteger(ANIMATOR_PARAM.STATUS, 2)
					elseif self.vo.action_type == HOTSPRING_ACTION_TYPE.MASSAGE then
						boy_main_part:SetInteger(ANIMATOR_PARAM.STATUS, 3)
					end
				end
				self:ResetTransform(obj.gameObject.transform)
			end
		end

		if nil ~= girl_obj and nil ~= girl_obj:GetRoot() and not IsNil(girl_obj:GetRoot().gameObject) then
			local obj = girl_obj.draw_obj:_TryGetPartObj(SceneObjPart.Main)
			if nil ~= obj then
				obj.gameObject.transform:SetParent(self.mount_point_r)
				local girl_main_part = girl_obj.draw_obj:GetPart(SceneObjPart.Main)
				if nil ~= girl_main_part then
					if self.vo.action_type == HOTSPRING_ACTION_TYPE.SHUANG_XIU then
						girl_main_part:SetInteger(ANIMATOR_PARAM.STATUS, 2)
					elseif self.vo.action_type == HOTSPRING_ACTION_TYPE.MASSAGE then
						-- 按摩时挂点在同一边
						girl_obj:DoStand()
						girl_main_part:SetInteger(ANIMATOR_PARAM.STATUS, 4)
						obj.gameObject.transform:SetParent(self.mount_point_l)
					end
				end
				self:ResetTransform(obj.gameObject.transform)
			end
		end

		self:CheckWaterArea()

		self.modle_is_loading = false
		self.modle_is_loaded = true
	end
end

function BoatObj:ResetTransform(transform)
	transform:SetLocalPosition(0,0,0)
	transform.rotation = Vector3(0,0,0)
	transform:SetLocalScale(1,1,1)
end

function BoatObj:GetBoatAttachPoint(obj_id)
	if obj_id == self.vo.boy_obj_id then
		return self.mount_point_l
	else
		return self.mount_point_r
	end
end

function BoatObj:Update(now_time, elapse_time)
	SceneObj.Update(self, now_time, elapse_time)
	self.timer = elapse_time + self.timer
	-- if self.timer > 5 then
		self:CheckStatus(self.timer)
	-- end
	self:CheckModelLoaded()
end

function BoatObj:CheckStatus(time)
	local boy_obj = Scene.Instance:GetObjectByObjId(self.vo.boy_obj_id)
	if nil ~= boy_obj and nil ~= boy_obj:GetRoot() and not IsNil(boy_obj:GetRoot().gameObject) then
		local boy_main_part = boy_obj.draw_obj:GetPart(SceneObjPart.Main)
		if boy_main_part then
			if self.vo.action_type == HOTSPRING_ACTION_TYPE.SHUANG_XIU then
				boy_main_part:SetInteger(ANIMATOR_PARAM.STATUS, 2)
			elseif self.vo.action_type == HOTSPRING_ACTION_TYPE.MASSAGE then
				boy_main_part:SetInteger(ANIMATOR_PARAM.STATUS, 3)
				-- 按摩时间5秒然后删除模型
				if time >= 5 then
					self.timer = 0
					boy_main_part:SetInteger(ANIMATOR_PARAM.STATUS, 0)
					Scene.Instance:DeleteBoatByRole(self.vo.boy_obj_id)
				end
			end
		end
	end

	local girl_obj = Scene.Instance:GetObjectByObjId(self.vo.girl_obj_id)
	if nil ~= girl_obj and nil ~= girl_obj:GetRoot() and not IsNil(girl_obj:GetRoot().gameObject) then
		local girl_main_part = girl_obj.draw_obj:GetPart(SceneObjPart.Main)
		if nil ~= girl_main_part then
			if self.vo.action_type == HOTSPRING_ACTION_TYPE.SHUANG_XIU then
				girl_main_part:SetInteger(ANIMATOR_PARAM.STATUS, 2)
			elseif self.vo.action_type == HOTSPRING_ACTION_TYPE.MASSAGE then
				girl_main_part:SetInteger(ANIMATOR_PARAM.STATUS, 4)
			end
		end
	end
end

function BoatObj:IsCharacter()
	return false
end

function BoatObj:IsBoat()
	return true
end

function BoatObj:CheckWaterArea()
	if self.draw_obj then
		local root = self.draw_obj:GetRoot()
		if root then
			local part = self.draw_obj:GetPart(SceneObjPart.Main)
			if root.move_obj.IsInWater then
				part:SetInteger(ANIMATOR_PARAM.STATUS, 1)
			else
				part:SetInteger(ANIMATOR_PARAM.STATUS, 0)
			end
		end
	end
end

function BoatObj:OnClick()
	SceneObj.OnClick(self)

	local temp_obj_id = self.vo.boy_obj_id
	if self.last_select_obj_id == self.vo.boy_obj_id then
		temp_obj_id = self.vo.girl_obj_id
	elseif self.last_select_obj_id == self.vo.girl_obj_id then
		temp_obj_id = self.vo.boy_obj_id
	end

	local obj = Scene.Instance:GetObjectByObjId(temp_obj_id)
	if nil ~= obj then
		obj:OnClicked(obj.vo)
		self.last_select_obj_id = temp_obj_id
	end
end