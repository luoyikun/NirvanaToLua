CoupleHaloObj = CoupleHaloObj or BaseClass(SceneObj)

function CoupleHaloObj:__init(vo)
	self.vo = vo
	self.obj_type = SceneObjType.CoupleHaloObj
end

function CoupleHaloObj:__delete()
	Scene.Instance:DeleteCoupleHaloObj(self.vo.target_1_role_id)
end

function CoupleHaloObj:Update(now_time, elapse_time)
	SceneObj.Update(self, now_time, elapse_time)
	local role_obj_1 = Scene.Instance:GetObjByUId(self.vo.target_1_role_id)
	local role_obj_2 = Scene.Instance:GetObjByUId(self.vo.target_2_role_id)
	if nil == role_obj_1 or nil == role_obj_2 then
		Scene.Instance:DeleteCoupleHaloObj(self.vo.target_1_role_id)
		return
	end

	local main_part = role_obj_1:GetDrawObj() and role_obj_1:GetDrawObj():GetPart(SceneObjPart.Main)
	local role_1_x, role_1_z = role_obj_1:GetRealPos()
	if main_part then
		local role_position = main_part:GetObj() and main_part:GetObj().transform.position
		if role_position then
			role_1_x = role_position.x
			role_1_z = role_position.z
		end
	end

	main_part = role_obj_2:GetDrawObj() and role_obj_2:GetDrawObj():GetPart(SceneObjPart.Main)
	local role_2_x, role_2_z = role_obj_2:GetRealPos()
	if main_part then
		local role_position = main_part:GetObj() and main_part:GetObj().transform.position
		if role_position then
			role_2_x = role_position.x
			role_2_z = role_position.z
		end
	end

	local center_x = (role_1_x + role_2_x) / 2.0
	local center_z = (role_1_z + role_2_z) / 2.0
	local draw_obj = self:GetDrawObj()
	draw_obj:MoveTo(center_x, center_z, 15)
end

function CoupleHaloObj:InitShow()
	SceneObj.InitShow(self)

	--初始化位置
	local role_obj_1 = Scene.Instance:GetObjByUId(self.vo.target_1_role_id)
	local role_obj_2 = Scene.Instance:GetObjByUId(self.vo.target_2_role_id)
	if nil == role_obj_1 or nil == role_obj_2 then
		return
	end
	local role_1_x, role_1_z = role_obj_1:GetLogicPos()
	local role_2_x, role_2_z = role_obj_2:GetLogicPos()
	local center_x = (role_1_x + role_2_x) / 2.0
	local center_z = (role_1_z + role_2_z) / 2.0
	self:SetLogicPos(center_x, center_z)

	--创建特效
	local halo_info = MarriageData.Instance:GetHaloInfo(self.vo.halo_type, 1)
	if nil ~= halo_info then
		local bundle, asset = ResPath.GetHaloEffect(halo_info.res_id)
		local function load_complete()
			local draw_obj = self:GetDrawObj()
			if draw_obj then
				local part = draw_obj:GetPart(SceneObjPart.Main)
				part:SetBool("Rotate", true)
			end
		end
		self:ChangeModel(SceneObjPart.Main, bundle, asset, load_complete)
	end
end