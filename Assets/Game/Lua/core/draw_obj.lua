require("core/draw_part")

DrawObj = DrawObj or BaseClass()

function DrawObj:__init(parent_obj, parent_transform)
	self.parent_obj = parent_obj

	-- 控制的根节点.
    self.root = U3DObject(ResMgr:CreateEmptyGameObj(nil, true))
	self.root.gameObject:AddComponent(typeof(MoveableObject))
	if parent_transform ~= nil then
		self.root.transform:SetParent(parent_transform)
	end

	self.part_list = {}
	self.shield_part_list = {}
	self.auto_fly = false
	self.load_complete = nil
	self.obj_type = 0
	self.scene_obj = nil
	self.budget_vis = true
	self.is_visible = true
	self.is_use_objpool = true
	self.is_disable_effect = false
	self.is_use_material_optimize = false
	self.look_at_point = nil
end

function DrawObj:__delete()
	for k,v in pairs(self.part_list) do
		v:DeleteMe()
	end
	self.part_list = {}
	self.shield_part_list = {}

	local game_obj = self.root.gameObject
	ResMgr:Destroy(game_obj)

	GlobalTimerQuest:CancelQuest(self.delay_set_attached)

	if nil ~= self.delay_open_raycast_optimize then
		GlobalTimerQuest:CancelQuest(self.delay_open_raycast_optimize)
		self.delay_open_raycast_optimize = nil
	end

	if nil ~= self.root and not IsNil(self.root.move_obj) then
		self.root.move_obj:Clear()
	end
	self.root = nil
	self.parent_obj = nil
	self.scene_obj = nil
	self.look_at_point = nil
end

function DrawObj:OnEnterScene()
	if nil ~= self.delay_open_raycast_optimize then
		GlobalTimerQuest:CancelQuest(self.delay_open_raycast_optimize)
	end
	self.delay_open_raycast_optimize = GlobalTimerQuest:AddDelayTimer(function ()
		if nil ~= self.root and not IsNil(self.root.move_obj) then
			self.root.move_obj:SetIsRaycastOptimize(true)
		end
	end, 1)
end

function DrawObj:GetObjVisible()
	return self.is_visible
end

function DrawObj:IsDeleted()
	return self.root == nil
end

function DrawObj:GetRoot()
	return self.root
end

function DrawObj:SetIsUseObjPool(is_use_objpool)
	self.is_use_objpool = is_use_objpool
end

function DrawObj:SetIsOptimizeMaterial(is_use_material_optimize)
	self.is_use_material_optimize = is_use_material_optimize
end

function DrawObj:SetIsDisableAllAttachEffects(is_disable_effect)
	self.is_disable_effect = is_disable_effect
end

function DrawObj:SetName(name)
	self.root.gameObject.name = name
end

function DrawObj:GetName()
	return self.root.gameObject.name
end

function DrawObj:SetSceneObj(scene_obj)
	self.scene_obj = scene_obj
end

function DrawObj:GetSceneObj()
	return self.scene_obj
end

function DrawObj:SetOffset(vector_3)
	self.root.move_obj:SetOffset(vector_3)
end

function DrawObj:SetPosition(x, y)
	-- 重置坐标时，开启一下轻功，避免人物出现在建筑物底下
	if self.parent_obj.IsRole and self.parent_obj:IsRole() then
		local logic_pos_x, logic_pos_y = self.parent_obj:GetLogicPos()
		if AStarFindWay:IsHighArea(logic_pos_x, logic_pos_y) then
			local old_state = self.root.move_obj.enableQingGong
			self:QingGongEnable(true)
			self.root.move_obj:SetPosition(x, 0, y)
			self:QingGongEnable(old_state)
			return
		end
	end

	self.root.move_obj:SetPosition(x, 0, y)
end

function DrawObj:SetRotation(x, y, z)
	self.root.move_obj:SetRotation(x, y, z)
end

function DrawObj:SetRotationOffset(x, y, z)
	self.root.move_obj:SetRotationOffset(x, y, z)
end

function DrawObj:SetRotationX(x)
	self.root.move_obj:SetRotationX(x)
end

function DrawObj:Rotate(x_angle, y_angle, z_angle)
	self.root.transform:Rotate(x_angle, y_angle, z_angle)
end

function DrawObj:GetRootPosition()
	return self.root.transform.position
end

function DrawObj:LookAt(x, y, z)
	local point = Vector3(x, y, z)
	self.root.transform:LookAt(point)
end

function DrawObj:SetDirectionByXY(x, z)
	self.root.move_obj:RotateTo(x, 0, z, 20)
end

function DrawObj:SetDirectionByXYZ(x, y, z)
	self.root.move_obj:RotateTo(x, y, y, 20)
end

function DrawObj:MoveTo(x, y, speed)
	self.root.move_obj:MoveTo(x, 0, y, speed)
end

function DrawObj:SetMoveCallback(callback)
	if nil ~= callback then
		self.root.move_obj:SetMoveCallback(callback)
	end
end

function DrawObj:StopMove()
	self.root.move_obj:StopMove()
end

function DrawObj:StopRotate()
	self.root.move_obj:StopRotate()
end

function DrawObj:SetYinShenMaterial(change_material, prof)
	for k, part in pairs(SceneObjPart) do
		if self.part_list[part] then
			self.part_list[part]:SetYinShenMaterial(change_material, prof)
		end
	end
end

function DrawObj:SetBudgetVis(visible)
	self.budget_vis = visible
	for k, part in pairs(SceneObjPart) do
		if self.part_list[part] then
			self.part_list[part]:SetVisible(self.is_visible and self.budget_vis)
		end
	end
end

function DrawObj:SetVisible(visible, main_loadcallback)
	self.is_visible = visible
	visible = self.is_visible and self.budget_vis

	local part = self.part_list[SceneObjPart.Main]
	if part then
		part:SetVisible(visible, main_loadcallback)
	end

	part = self.part_list[SceneObjPart.Weapon]
	if part then
		part:SetVisible(visible)
	end

	part = self.part_list[SceneObjPart.Weapon2]
	if part then
		part:SetVisible(visible)
	end

	part = self.part_list[SceneObjPart.Mount]
	if part then
		part:SetVisible(visible)
	end

	part = self.part_list[SceneObjPart.FightMount]
	if part then
		part:SetVisible(visible)
	end

	part = self.part_list[SceneObjPart.Wing]
	if part then
		part:SetVisible(visible)
	end

	part = self.part_list[SceneObjPart.Halo]
	if part then
		part:SetVisible(visible)
	end

	part = self.part_list[SceneObjPart.BaoJu]
	if part then
		part:SetVisible(visible)
	end

	part = self.part_list[SceneObjPart.Particle]
	if part then
		part:SetVisible(visible)
	end

	part = self.part_list[SceneObjPart.Cloak]
	if part then
		part:SetVisible(visible)
	end

	part = self.part_list[SceneObjPart.FaBao]
	if part then
		part:SetVisible(visible)
	end

	part = self.part_list[SceneObjPart.TouShi]
	if part then
		part:SetVisible(visible)
	end

	part = self.part_list[SceneObjPart.Waist]
	if part then
		part:SetVisible(visible)
	end

	part = self.part_list[SceneObjPart.QilinBi]
	if part then
		part:SetVisible(visible)
	end

	part = self.part_list[SceneObjPart.FaBao]
	if part then
		part:SetVisible(visible)
	end

	part = self.part_list[SceneObjPart.Tail]
	if part then
		part:SetVisible(visible)
	end

	part = self.part_list[SceneObjPart.Mask]
	if part then
		part:SetVisible(visible)
	end

	part = self.part_list[SceneObjPart.ShouHuan]
	if part then
		part:SetVisible(visible)
	end

	part = self.part_list[SceneObjPart.FaZhen]
	if part then
		part:SetVisible(visible)
	end
end

function DrawObj:GetPart(part)
	local part_obj = self.part_list[part]
	if part_obj == nil then
		part_obj = self:_CreatePart(part)
		self.part_list[part] = part_obj
	end

	return part_obj
end

function DrawObj:_TryGetPart(part)
	return self.part_list[part]
end

function DrawObj:RemoveModel(part)
	local part_obj = self.part_list[part]
	if part_obj then
		part_obj:RemoveModel()
	end
end

function DrawObj:GetAttachPoint(point)
	local part = self:GetPart(SceneObjPart.Main)
	local point_node = part:GetAttachPoint(point)
	if point_node ~= nil then
		return point_node
	else
		return self.root.transform
	end
end

function DrawObj:GetTransfrom()
	return self.root.transform
end

function DrawObj:GetObjType()
	return self.obj_type
end

function DrawObj:SetObjType(obj_type)
	self.obj_type = obj_type
end

function DrawObj:SetLoadComplete(complete)
	self.load_complete = complete
end

function DrawObj:SetRemoveCallback(callback)
	self.remove_callback = callback
end

function DrawObj:_CreatePart(part)
	local part_obj = DrawPart.New(part)
	part_obj:SetParent(self.root)
	part_obj:SetIsUseObjPool(self.is_use_objpool)
	part_obj:SetIsOptimizeMaterial(self.is_use_material_optimize)
	part_obj:SetIsDisableAllAttachEffects(self.is_disable_effect)
	part_obj:SetMainRole(self.parent_obj.IsMainRole and self.parent_obj:IsMainRole())
	if part == SceneObjPart.Main then
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
			obj_class:SetVisible(self.is_visible)
			local attachment = obj.actor_attachment
			local attach_skin = obj.attach_skin
			if attachment == nil then
				if self.load_complete ~= nil then
					self.load_complete(part, obj)
				end
				return
			end

			local attach, point = nil, nil
			GlobalTimerQuest:CancelQuest(self.delay_set_attached)
			self.delay_set_attached = GlobalTimerQuest:AddDelayTimer(function ()
				for k, v in pairs(PartAttachPoint) do
					local attach_skin_obj = self:_TryGetPartAttachSkinObj(k)
					if nil ~= attach_skin_obj and nil ~= attach_skin then
						attach_skin_obj.gameObject:SetActive(true)
						attach_skin:AttachMesh(attach_skin_obj.gameObject)
					else
						attach = self:_TryGetPartAttachObj(k)
						if attach ~= nil then
							attach.gameObject:SetActive(true)
							point = attachment:GetAttachPoint(v)
							if nil ~= point and not IsNil(point.gameObject) then
								attach:SetAttached(point)
								attach:SetTransform(attachment.Prof)
							end
						end
					end
				end
			end, 0)

			local wing_obj = self:_TryGetPartAttachObj(SceneObjPart.Wing)
			if wing_obj ~= nil then
				wing_obj.gameObject:SetActive(true)
				point = attachment:GetAttachPoint(AttachPoint.Wing)
				if nil ~= point and not IsNil(point.gameObject) then
					wing_obj:SetAttached(point)
					wing_obj:SetTransform(attachment.Prof)
				end
				if self.auto_fly then
					local main_part = self:GetPart(SceneObjPart.Main)
					main_part:SetLayer(1, 1)
				end
			end

			local cloak_obj = self:_TryGetPartAttachObj(SceneObjPart.Cloak)
			if cloak_obj ~= nil then
				cloak_obj.gameObject:SetActive(true)
				point = attachment:GetAttachPoint(AttachPoint.Wing)
				if nil ~= point and not IsNil(point.gameObject) then
					cloak_obj:SetAttached(point)
					cloak_obj:SetTransform(attachment.Prof)
				end

				if self.auto_fly then
					local main_part = self:GetPart(SceneObjPart.Main)
					main_part:SetLayer(1, 1)
				end
			end

			local mount_obj = self:_TryGetPartObj(SceneObjPart.Mount)
			if mount_obj ~= nil then
				mount_obj.gameObject:SetActive(true)
				attachment:AddMount(mount_obj.gameObject)
				if self.parent_obj.IsRole and self.parent_obj:IsRole() then
					self.parent_obj:ChangeWeiYan()

					--双人坐骑跟随者上坐骑
					local parnter_obj_id = self.parent_obj.mount_other_objid or -1
					local parnter_obj = Scene.Instance:GetRoleByObjId(parnter_obj_id)
					if parnter_obj then
						parnter_obj:MultiMountParentUp()
					end

					local main_part = self:GetPart(SceneObjPart.Main)
					if self.parent_obj.IsMountLayer2 and self.parent_obj:IsMountLayer2() then
						main_part:SetLayer(ANIMATOR_PARAM.MOUNT_LAYER2, 1)
					else
						main_part:SetLayer(ANIMATOR_PARAM.MOUNT_LAYER2, 0)
					end


					-- 双骑初始化坐姿
					local game_vo = self.parent_obj:GetVo()
					if game_vo.multi_mount_res_id and game_vo.multi_mount_res_id > 0 then
						local sit_mount = 0
						if game_vo.multi_mount_res_id > 0 then
							sit_mount = MultiMountData.Instance:GetMultiMountSitTypeByResid(game_vo.multi_mount_res_id)
						end
						if sit_mount == 0 then
							main_part:SetLayer(ANIMATOR_PARAM.MOUNT_LAYER, 1)
						elseif sit_mount == 1 then
							main_part:SetLayer(ANIMATOR_PARAM.FIGHTMOUNT_LAYER, 1)
						else
							main_part:SetLayer(ANIMATOR_PARAM.MOUNT_LAYER2, 1)
						end
					end
				end

				if mount_obj.attach_obj ~= nil then
					mount_obj.attach_obj:SetTransform(attachment.Prof)
				end
			else
				local fight_mount_obj = self:_TryGetPartObj(SceneObjPart.FightMount)
				if fight_mount_obj ~= nil then
					fight_mount_obj.gameObject:SetActive(true)
					attachment:AddFightMount(fight_mount_obj.gameObject)

					if self.parent_obj.IsRole and self.parent_obj:IsRole() then
						--双人坐骑跟随者上坐骑
						local parnter_obj_id = self.parent_obj.mount_other_objid or -1
						local parnter_obj = Scene.Instance:GetRoleByObjId(parnter_obj_id)
						if parnter_obj then
							parnter_obj:MultiMountParentUp()
						end

						local main_part = self:GetPart(SceneObjPart.Main)
						if self.parent_obj.IsMountLayer2 and self.parent_obj:IsMountLayer2() then
							main_part:SetLayer(ANIMATOR_PARAM.MOUNT_LAYER2, 1)
						else
							main_part:SetLayer(ANIMATOR_PARAM.MOUNT_LAYER2, 0)
						end

						-- 双骑初始化坐姿
						local game_vo = self.parent_obj:GetVo()
						if game_vo.multi_mount_res_id and game_vo.multi_mount_res_id > 0 then
							local sit_mount = 0
							if game_vo.multi_mount_res_id > 0 then
								sit_mount = MultiMountData.Instance:GetMultiMountSitTypeByResid(game_vo.multi_mount_res_id)
							end
							if sit_mount == 0 then
								main_part:SetLayer(ANIMATOR_PARAM.MOUNT_LAYER, 1)
							elseif sit_mount == 1 then
								main_part:SetLayer(ANIMATOR_PARAM.FIGHTMOUNT_LAYER, 1)
							else
								main_part:SetLayer(ANIMATOR_PARAM.MOUNT_LAYER2, 1)
							end
						end
					end

					if fight_mount_obj.attach_obj ~= nil then
						fight_mount_obj.attach_obj:SetTransform(attachment.Prof)
						local vo = self.parent_obj.vo
						if vo and vo.fight_mount_appeid then
							local is_rotation = FightMountData.Instance:GetFightMountIsRotationByImageId(vo.fight_mount_appeid)
							fight_mount_obj.attach_obj.IsRotationZero = is_rotation
						end
					end
				end
			end

			if self.load_complete ~= nil then
				self.load_complete(part, obj)
			end
			self:AddPayload(obj_class, obj_part)
		end, part)
		part_obj:SetRemoveCallback(function(obj)
			local attachment = self:_TryGetPartAttachment(SceneObjPart.Main)
			if attachment ~= nil then
				attachment:RemoveMount()
			end

			local weapon = self.part_list[SceneObjPart.Weapon]
			if nil ~= weapon then
				if self.weapon_effect then
					ResMgr:Destroy(self.weapon_effect)
					self.weapon_effect = nil
				end
				weapon:Reset()
			end
			local weapon2 = self.part_list[SceneObjPart.Weapon2]
			if nil ~= weapon2 then
				if self.weapon2_effect then
					ResMgr:Destroy(self.weapon2_effect)
					self.weapon2_effect = nil
				end
				weapon2:Reset()
			end
			local wing = self.part_list[SceneObjPart.Wing]
			if nil ~= wing then
				wing:Reset()
			end
			local cloak = self.part_list[SceneObjPart.Cloak]
			if nil ~= cloak then
				cloak:Reset()
			end
			local halo = self.part_list[SceneObjPart.Halo]
			if nil ~= halo then
				halo:Reset()
			end
			local fabao = self.part_list[SceneObjPart.FaBao]
			if nil ~= fabao then
				fabao:Reset()
			end
			local fazhen = self.part_list[SceneObjPart.FaZhen]
			if nil ~= fazhen then
				fazhen:Reset()
			end
			
			if self.remove_callback ~= nil then
				self.remove_callback(part, obj)
			end
		end)
	elseif PartAttachPoint[part] ~= nil then
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
			obj_class:SetVisible(self.is_visible)
			local attachment = self:_TryGetPartAttachment(SceneObjPart.Main)
			local attach_skin = self:_TryGetPartAttachSkin(SceneObjPart.Main)
			if nil ~= attach_skin and nil ~= obj.attach_skin_obj then
				obj.gameObject:SetActive(true)
				attach_skin:AttachMesh(obj.gameObject)
			else
				if attachment ~= nil then
					obj.gameObject:SetActive(true)
					local point = attachment:GetAttachPoint(PartAttachPoint[part])
					if not IsNil(point) and obj.attach_obj then
						obj.attach_obj:SetAttached(point)
						obj.attach_obj:SetTransform(attachment.Prof)
					end
				else
					obj.gameObject:SetActive(false)
				end
			end

			if self.load_complete ~= nil then
				self.load_complete(part, obj)
			end
			self:AddPayload(obj_class, obj_part)
		end, part)
		part_obj:SetRemoveCallback(function(obj)
			if self.remove_callback ~= nil then
				self.remove_callback(part, obj)
			end
		end)
	elseif part == SceneObjPart.Wing then
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
			obj_class:SetVisible(self.is_visible)
			local attachment = self:_TryGetPartAttachment(SceneObjPart.Main)
			if attachment ~= nil then
				obj.gameObject:SetActive(true)

				local point = attachment:GetAttachPoint(AttachPoint.Wing)
				if not IsNil(point) and obj.attach_obj then
					obj.attach_obj:SetAttached(point)
					obj.attach_obj:SetTransform(attachment.Prof)
				end
			else
				obj.gameObject:SetActive(false)
			end

			if self.auto_fly then
				local main_part = self:GetPart(SceneObjPart.Main)
				main_part:SetLayer(1, 1)
			end

			if self.load_complete ~= nil then
				self.load_complete(part, obj)
			end
			self:AddPayload(obj_class, obj_part)
		end, part)
		part_obj:SetRemoveCallback(function(obj)
			if self.remove_callback ~= nil then
				self.remove_callback(part, obj)
			end
		end)
	elseif part == SceneObjPart.Cloak then
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
			obj_class:SetVisible(self.is_visible)
			local attachment = self:_TryGetPartAttachment(SceneObjPart.Main)
			if attachment ~= nil then
				obj.gameObject:SetActive(true)
				
				local point = attachment:GetAttachPoint(AttachPoint.Wing)
				if not IsNil(point) and obj.attach_obj then
					obj.attach_obj:SetAttached(point)
					obj.attach_obj:SetTransform(attachment.Prof)
				end
			else
				obj.gameObject:SetActive(false)
			end

			if self.auto_fly then
				local main_part = self:GetPart(SceneObjPart.Main)
				main_part:SetLayer(1, 1)
			end

			if self.load_complete ~= nil then
				self.load_complete(part, obj)
			end
			self:AddPayload(obj_class, obj_part)
		end, part)
		part_obj:SetRemoveCallback(function()
			if self.remove_callback ~= nil then
				self.remove_callback(part, obj)
			end
		end)
	elseif part == SceneObjPart.Mount or part == SceneObjPart.FightMount then
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
			obj_class:SetVisible(self.is_visible)
			self:AddPayload(obj_class, obj_part)
			local scale = obj.transform.localScale
			local attachment = self:_TryGetPartAttachment(SceneObjPart.Main)
			if attachment ~= nil then
				obj.gameObject:SetActive(true)
				if part == SceneObjPart.Mount then
					attachment:AddMount(obj.gameObject)

					if self.parent_obj.IsRole and self.parent_obj:IsRole() then
						--双人坐骑跟随者上坐骑
						local parnter_obj_id = self.parent_obj.mount_other_objid or -1
						local parnter_obj = Scene.Instance:GetRoleByObjId(parnter_obj_id)
						if parnter_obj then
							parnter_obj:MultiMountParentUp()
						end

						local main_part = self:GetPart(SceneObjPart.Main)
						if self.parent_obj.IsMountLayer2 and self.parent_obj:IsMountLayer2() then
							main_part:SetLayer(ANIMATOR_PARAM.MOUNT_LAYER2, 1)
						else
							main_part:SetLayer(ANIMATOR_PARAM.MOUNT_LAYER2, 0)
						end

						-- 双骑初始化坐姿
						local game_vo = self.parent_obj:GetVo()
						if game_vo.multi_mount_res_id and game_vo.multi_mount_res_id > 0 then
							local sit_mount = 0
							if game_vo.multi_mount_res_id > 0 then
								sit_mount = MultiMountData.Instance:GetMultiMountSitTypeByResid(game_vo.multi_mount_res_id)
							end
							if sit_mount == 0 then
								main_part:SetLayer(ANIMATOR_PARAM.MOUNT_LAYER, 1)
							elseif sit_mount == 1 then
								main_part:SetLayer(ANIMATOR_PARAM.FIGHTMOUNT_LAYER, 1)
							else
								main_part:SetLayer(ANIMATOR_PARAM.MOUNT_LAYER2, 1)
							end
						end

					elseif self.parent_obj.IsLingChong and self.parent_obj:IsLingChong() then
						local main_part = self:GetPart(SceneObjPart.Main)
						main_part:SetLayer(LINGCHONG_ANIMATOR_PARAM.MOUNT_LAYER, 1)

						obj.transform.localPosition = Vector3(0, 0, 0)
						obj.transform.localEulerAngles = Vector3(0, 0, 0)

						local vo = self.parent_obj:GetVo()
						local image_info = LingQiData.Instance:GetLingQiImageCfgInfoByImageId(vo.lingqi_used_imageid or 0)
						if image_info then
							local scale = image_info.scale
							if scale then
								obj.transform.localScale = Vector3(scale, scale, scale)
							end
						end
					end
				else
					attachment:AddFightMount(obj.gameObject)

					if self.parent_obj.IsRole and self.parent_obj:IsRole() then
						--双人坐骑跟随者上坐骑
						local parnter_obj_id = self.parent_obj.mount_other_objid or -1
						local parnter_obj = Scene.Instance:GetRoleByObjId(parnter_obj_id)
						if parnter_obj then
							parnter_obj:MultiMountParentUp()
						end

						local main_part = self:GetPart(SceneObjPart.Main)
						if self.parent_obj.IsMountLayer2 and self.parent_obj:IsMountLayer2() then
							main_part:SetLayer(ANIMATOR_PARAM.MOUNT_LAYER2, 1)
						else
							main_part:SetLayer(ANIMATOR_PARAM.MOUNT_LAYER2, 0)
						end

						-- 双骑初始化坐姿
						local game_vo = self.parent_obj:GetVo()
						if game_vo.multi_mount_res_id and game_vo.multi_mount_res_id > 0 then
							local sit_mount = 0
							if game_vo.multi_mount_res_id > 0 then
								sit_mount = MultiMountData.Instance:GetMultiMountSitTypeByResid(game_vo.multi_mount_res_id)
							end
							if sit_mount == 0 then
								main_part:SetLayer(ANIMATOR_PARAM.MOUNT_LAYER, 1)
							elseif sit_mount == 1 then
								main_part:SetLayer(ANIMATOR_PARAM.FIGHTMOUNT_LAYER, 1)
							else
								main_part:SetLayer(ANIMATOR_PARAM.MOUNT_LAYER2, 1)
							end
						end
					end
				end
				if obj.attach_obj ~= nil then
					obj.attach_obj:SetTransform(attachment.Prof)
					if part == SceneObjPart.FightMount then
						local vo = self.parent_obj.vo
						if vo and vo.fight_mount_appeid then
							local is_rotation = FightMountData.Instance:GetFightMountIsRotationByImageId(vo.fight_mount_appeid)
							obj.attach_obj.IsRotationZero = is_rotation
						end
					end
				end
				local baoju_part = self:GetPart(SceneObjPart.BaoJu)
				if baoju_part and baoju_part:GetObj() then
					local mount_point = obj.transform:Find("mount_point")
					if mount_point then
						local position = baoju_part:GetObj().transform.localPosition
						local temp_y = mount_point.transform.localPosition.y - 1.2
						if part == SceneObjPart.FightMount then
							temp_y = mount_point.transform.localPosition.y
						end
						baoju_part:GetObj().transform.localPosition = Vector3(position.x, temp_y * scale.y, mount_point.transform.localPosition.z)
					end
				end
			else
				obj.gameObject:SetActive(false)
			end

			if self.load_complete ~= nil then
				self.load_complete(part, obj)
			end
		end, part)
		part_obj:SetRemoveCallback(function(obj)
			if part == SceneObjPart.Mount or part == SceneObjPart.FightMount then
				if self.parent_obj.IsRole and self.parent_obj:IsRole() then
					--双人坐骑跟随者下坐骑
					local parnter_obj_id = self.parent_obj.mount_other_objid or -1
					local parnter_obj = Scene.Instance:GetRoleByObjId(parnter_obj_id)
					if parnter_obj then
						parnter_obj:MultiMountPartnerDown()
					end
				end
			end

			local attachment = self:_TryGetPartAttachment(SceneObjPart.Main)
			if attachment ~= nil then
				attachment:RemoveMount()
				local part = self:GetPart(SceneObjPart.BaoJu)
				if part and part:GetObj() then
					part:GetObj().transform.localPosition = Vector3(0, -0.34, 0)
				end
			end
			if self.remove_callback ~= nil then
				self.remove_callback(part, obj)
			end
		end)
	elseif part == SceneObjPart.Halo then
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
			obj_class:SetVisible(self.is_visible)
			self:AddPayload(obj_class, obj_part)
			local attachment = self:_TryGetPartAttachment(SceneObjPart.Main)
			if attachment ~= nil then
				obj.gameObject:SetActive(true)
				local point = attachment:GetAttachPoint(AttachPoint.Hurt)
				if not IsNil(point) and obj.attach_obj then
					obj.attach_obj:SetAttached(point)
					obj.attach_obj:SetTransform(attachment.Prof)
				end
			else
				obj.gameObject:SetActive(false)
			end

			if self.load_complete ~= nil then
				self.load_complete(part, obj)
			end
		end, part)
		part_obj:SetRemoveCallback(function(obj)
			if self.remove_callback ~= nil then
				self.remove_callback(part, obj)
			end
		end)
	elseif part == SceneObjPart.BaoJu then
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
			obj_class:SetVisible(self.is_visible)
			self:AddPayload(obj_class, obj_part)
			local mount_part = self:GetPart(SceneObjPart.Mount)
			local fight_mount_part = self:GetPart(SceneObjPart.FightMount)
			if mount_part and mount_part:GetObj() then
				local scale = mount_part:GetObj().transform.localScale
				local position = obj.transform.localPosition
				local mount_point = mount_part:GetObj().transform:Find("mount_point")
				if mount_point then
					obj.transform.localPosition = Vector3(position.x, (mount_point.transform.localPosition.y - 1.2) * scale.y, mount_point.transform.localPosition.z)
				end
			elseif fight_mount_part and fight_mount_part:GetObj() then
				local scale = fight_mount_part:GetObj().transform.localScale
				local position = obj.transform.localPosition
				local mount_point = fight_mount_part:GetObj().transform:Find("mount_point")
				if mount_point then
					obj.transform.localPosition = Vector3(position.x, mount_point.transform.localPosition.y * scale.y, mount_point.transform.localPosition.z)
				end
			elseif not mount_part and not fight_mount_part then
				obj.transform.localPosition = Vector3(0, -0.34, 0)
			end
			if self.load_complete ~= nil then
				self.load_complete(part, obj)
				part_obj:SetInteger(ANIMATOR_PARAM.STATUS, 1)
			end
		end, part)
		part_obj:SetRemoveCallback(function(obj)
			if self.remove_callback ~= nil then
				self.remove_callback(part, obj)
			end
		end)
	elseif part == SceneObjPart.Particle then
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
			obj_class:SetVisible(self.is_visible)
			self:AddPayload(obj_class, obj_part)
			local attachment = self:_TryGetPartAttachment(SceneObjPart.Main)
			if attachment ~= nil then
				obj.gameObject:SetActive(true)
				local point = attachment:GetAttachPoint(AttachPoint.Hurt)
				if not IsNil(point) and obj.attach_obj then
					obj.attach_obj:SetAttached(point)
					obj.attach_obj:SetTransform(attachment.Prof)
				end
			else
				obj.gameObject:SetActive(false)
			end

			if self.load_complete ~= nil then
				self.load_complete(part, obj)
			end
		end, part)
		part_obj:SetRemoveCallback(function(obj)
			if self.remove_callback ~= nil then
				self.remove_callback(part, obj)
			end
		end)
	elseif part == SceneObjPart.FaZhen then
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
			obj_class:SetVisible(self.is_visible)
			self:AddPayload(obj_class, obj_part)
			local attachment = self:_TryGetPartAttachment(SceneObjPart.Main)
			if attachment ~= nil then
				obj.gameObject:SetActive(true)
				local point = attachment:GetAttachPoint(AttachPoint.HurtRoot)
				if not IsNil(point) and obj.attach_obj then
					obj.attach_obj:SetAttached(point)
					obj.attach_obj:SetTransform(attachment.Prof)
				end
			else
				obj.gameObject:SetActive(false)
			end

			if self.load_complete ~= nil then
				self.load_complete(part, obj)
			end
		end, part)
		part_obj:SetRemoveCallback(function(obj)
			if self.remove_callback ~= nil then
				self.remove_callback(part, obj)
			end
		end)
	elseif part == SceneObjPart.HoldBeauty then
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
			obj_class:SetVisible(self:GetPartVisible(part))
			self:AddPayload(obj_class, obj_part)
			local attachment = self:_TryGetPartAttachment(SceneObjPart.Main)
			if attachment ~= nil then
				obj.gameObject:SetActive(true)
				local point = attachment:GetAttachPoint(AttachPoint.Hug)
				if not IsNil(point) and obj.attach_obj then
					obj.attach_obj:SetAttached(point)
					obj.attach_obj:SetTransform(attachment.Prof)
				end
			else
				obj.gameObject:SetActive(false)
			end

			if self.load_complete ~= nil then
				self.load_complete(part, obj)
			end
			self:AddPayload(obj_class, obj_part)
		end, part)
		part_obj:SetRemoveCallback(function(obj)
			if self.remove_callback ~= nil then
				self.remove_callback(part, obj)
			end
		end)
	elseif part == SceneObjPart.FaBao then
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
			obj_class:SetVisible(self.is_visible)
			self:AddPayload(obj_class, obj_part)
			local attachment = self:_TryGetPartAttachment(SceneObjPart.Main)
			if attachment ~= nil then
				obj.gameObject:SetActive(true)
				local point = attachment:GetAttachPoint(AttachPoint.HurtRoot)
				if not IsNil(point) and obj.attach_obj then
					obj.attach_obj:SetAttached(point)
					obj.attach_obj:SetTransform(attachment.Prof)
				end
			else
				obj.gameObject:SetActive(false)
			end

			if self.load_complete ~= nil then
				self.load_complete(part, obj)
			end
		end, part)
		part_obj:SetRemoveCallback(function(obj)
			if self.remove_callback ~= nil then
				self.remove_callback(part, obj)
			end
		end)
	elseif part == SceneObjPart.Head then
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
			local attachment = self:_TryGetPartAttachment(SceneObjPart.Main)
			if attachment ~= nil then
				obj.gameObject:SetActive(true)
				local point = attachment:GetAttachPoint(AttachPoint.Head)
				if not IsNil(point) and obj.attach_obj then
					obj.attach_obj:SetAttached(point)
					obj.attach_obj:SetTransform(attachment.Prof)
				end
			else
				obj.gameObject:SetActive(false)
			end

			if self.load_complete ~= nil then
				self.load_complete(part, obj)
			end
			self:AddPayload(obj_class, obj_part)
		end, part)
		part_obj:SetRemoveCallback(function(obj)
			if self.remove_callback ~= nil then
				self.remove_callback(part, obj)
			end
		end)
	else
		print_error("_CreatePart failed: ", part)
	end

	return part_obj
end

function DrawObj:_TryGetPartObj(part)
	local part_obj = self.part_list[part]
	if part_obj == nil then
		return nil
	end

	local obj = part_obj:GetObj()
	if obj == nil or IsNil(obj.gameObject) then
		return nil
	end

	return obj
end

function DrawObj:_TryGetPartAttachObj(part)
	local part_obj = self.part_list[part]
	if part_obj == nil then
		return nil
	end

	local obj = part_obj:GetObj()
	if obj == nil or IsNil(obj.gameObject) then
		return nil
	end

	return obj.attach_obj
end

function DrawObj:_TryGetPartAttachment(part)
	local part_obj = self.part_list[part]
	if part_obj == nil then
		return nil
	end

	local obj = part_obj:GetObj()
	if obj == nil or IsNil(obj.gameObject) then
		return nil
	end

	return obj.actor_attachment
end

function DrawObj:_TryGetPartAttachSkinObj(part)
	local part_obj = self.part_list[part]
	if part_obj == nil then
		return nil
	end

	local obj = part_obj:GetObj()
	if obj == nil or IsNil(obj.gameObject) then
		return nil
	end

	return obj.attach_skin_obj
end

function DrawObj:_TryGetPartAttachSkin(part)
	local part_obj = self.part_list[part]
	if part_obj == nil then
		return nil
	end

	local obj = part_obj:GetObj()
	if obj == nil or IsNil(obj.gameObject) then
		return nil
	end

	return obj.attach_skin
end

function DrawObj:PlayDead(dietype, callback, time)
	time = time or 2.0
	local main_part = self:GetPart(SceneObjPart.Main)
	local main_obj = main_part:GetObj()
	if main_obj == nil then
		callback()
		return
	end

	local fadeout = main_obj.actor_fadout
	if fadeout ~= nil then
		fadeout:Fadeout(time, callback)
		return
	end

	local tween = main_obj.transform:DOLocalMoveY(-1.0, 1.0)
	tween:SetEase(DG.Tweening.Ease.Linear)
	tween:OnComplete(callback)
end

function DrawObj:AddPayload(part_obj, part)
	if nil == RenderBudget.Instance then return end
	if self.obj_type == SceneObjType.Monster and self.is_boss then return end
	part_obj.budget_handle = RenderBudget.Instance:AddPayload(self.obj_type, part, BindTool.Bind(self.BudgetEnable, self, part), BindTool.Bind(self.BudgetDisable, self, part))

end

function DrawObj:BudgetEnable(part)
	if part > 0 then
		if self.part_list[part] then
			self.part_list[part]:SetBudgetVis(true)
		end
	else
		self:SetBudgetVis(true)
	end
end

function DrawObj:BudgetDisable(part)
	if part > 0 then
		if self.part_list[part] then
			self.part_list[part]:SetBudgetVis(false)
		end
	else
		self:SetBudgetVis(false)
	end
end

function DrawObj:SetCheckWater(state)
	self.root.move_obj.CheckWater = state
end

function DrawObj:SetWaterHeight(height)
	self.root.move_obj.WaterHeight = height
end

function DrawObj:SetEnterWaterCallBack(callback)
	self.root.move_obj:SetEnterWaterCallBack(callback)
end

function DrawObj:GetIsInWater()
	local in_water = false
	if self.root.move_obj then
		in_water = self.root.move_obj.IsInWater
	end
	return in_water
end

function DrawObj:GetLookAtPoint(y)
	y = y or 0
	if nil == self.look_at_point then
		self.look_at_point = GameObject.New("CamerafocalPoint")
		self.look_at_point.transform:SetParent(self.root.transform)
		self.look_at_point.transform.localEulerAngles = Vector3(0, 0, 0)
		self.look_at_point.transform.localPosition = Vector3(0, y, 0)
	else
		local tween = self.look_at_point.transform:DOLocalMoveY(y, 0.6)
		tween:SetEase(DG.Tweening.Ease.OutQuad)
	end
	return self.look_at_point.transform
end

-- function DrawObj:AddOcclusion()
-- 	for k, part in pairs(SceneObjPart) do
-- 		if self.part_list[part] then
-- 			self.part_list[part]:AddOcclusion()
-- 		end
-- 	end
-- end

-- function DrawObj:RemoveOcclusion()
-- 	for k, part in pairs(SceneObjPart) do
-- 		if self.part_list[part] then
-- 			self.part_list[part]:RemoveOcclusion()
-- 		end
-- 	end
-- end

function DrawObj:ShieldPart(part, is_shield)
	self.shield_part_list[part] = is_shield
	local part_obj = self.part_list[part]
	if part_obj then
		part_obj:SetVisible(self:GetPartVisible(part))
	end
end

function DrawObj:GetPartVisible(part)
	return (self.is_visible and self.budget_vis and not self.shield_part_list[part]) or false
end

function DrawObj:QingGongEnable(state)
	self.root.move_obj.enableQingGong = state
end

function DrawObj:Jump(qinggongObject)
	self.root.move_obj:Jump(qinggongObject)
end

function DrawObj:SimpleJump(qinggongObject, target, autoJump)
	self.root.move_obj:SimpleJump(qinggongObject, target, autoJump or false)
end

function DrawObj:AdjustMoveMent(fx, fy)
	self.root.move_obj:AdjustMoveMent(fx, fy)
end

function DrawObj:SetStateChangeCallBack(callback)
	self.root.move_obj:SetStateChangeCallBack(callback)
end

function DrawObj:SetGravityMultiplier(multiplier)
	self.root.move_obj:SetGravityMultiplier(multiplier)
end

function DrawObj:SetJumpHorizonSpeed(speed)
	self.root.move_obj.JumpHorizonSpeed = speed or 0
end

function DrawObj:ForceLanding(speed)
	self.root.move_obj:ForceLanding()
end

function DrawObj:SetDrag(drag)
	self.root.move_obj:SetDrag(drag)
end

function DrawObj:SetQingGongTarget(target)
	self.root.move_obj:SetQingGongTarget(target)
end

function DrawObj:JumpFormAir(height, target, qinggongObject, percent)
	self.root.move_obj:JumpFormAir(height, target, qinggongObject, percent)
end

function DrawObj:GetHeight(layer, position)
	return self.root.move_obj:Height(layer, position)
end

function DrawObj:CheckBuilding(state)
	self.root.move_obj.checkBuilding = state
end