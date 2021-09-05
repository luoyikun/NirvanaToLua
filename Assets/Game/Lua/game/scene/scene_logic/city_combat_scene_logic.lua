CityCombatFBLogic = CityCombatFBLogic or BaseClass(CommonActivityLogic)

function CityCombatFBLogic:__init()
	self.block_grids = {
		{x = 175, y = 122},
		{x = 175, y = 121},
		{x = 175, y = 120},
		{x = 175, y = 119},
		{x = 175, y = 118},
		{x = 175, y = 117},
		{x = 175, y = 116},
		{x = 175, y = 115},
		{x = 175, y = 114},
		{x = 175, y = 113},
		{x = 175, y = 112},
		{x = 175, y = 111},
		{x = 175, y = 110},
		{x = 175, y = 109},
		{x = 175, y = 108},
		{x = 175, y = 107},
		{x = 175, y = 106},
		{x = 175, y = 105},
		{x = 175, y = 104},
		{x = 175, y = 103},
		{x = 175, y = 102},
		{x = 160, y = 122},
		{x = 160, y = 121},
		{x = 160, y = 120},
		{x = 160, y = 119},
		{x = 160, y = 118},
		{x = 160, y = 117},
		{x = 160, y = 116},
		{x = 160, y = 115},
		{x = 160, y = 114},
		{x = 160, y = 113},
		{x = 160, y = 112},
		{x = 160, y = 111},
		{x = 160, y = 110},
		{x = 160, y = 109},
		{x = 160, y = 108},
		{x = 160, y = 107},
		{x = 160, y = 106},
		{x = 160, y = 105},
		{x = 160, y = 104},
		{x = 160, y = 103},
		{x = 160, y = 102},
		{x = 160, y = 101},
	}

	self.barrier = nil
	self.barrier_state = false
	self.chengmen = nil
	self.chengmen_obj = nil
end

function CityCombatFBLogic:__delete()
	self.chengmen_obj = nil
	self.chengmen = nil
end

function CityCombatFBLogic:OnSceneDetailLoadComplete()
	self.barrier = GameObject.Find("Main/Effects/men_02")
	self.chengmen = GameObject.Find("Main/chengmen")
	self:UpdateBarrierState()
	self:UpdateChengMen(self.barrier_state)
end

function CityCombatFBLogic:Enter(old_scene_type, new_scene_type)
	CommonActivityLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.CityCombatView)
	ViewManager.Instance:Open(ViewName.CityCombatFBView)
	MainUICtrl.Instance:SetViewState(false)

	local main_role = Scene.Instance:GetMainRole()
	local attck_mode = PlayerPrefsUtil.GetInt("attck_mode", -1)
	if attck_mode ~= nil and attck_mode ~= -1 then
		PlayerPrefsUtil.SetInt("attck_mode", attck_mode)
	else
		PlayerPrefsUtil.SetInt("attck_mode", tonumber(main_role.vo.attack_mode))
	end
	if main_role.vo.attack_mode ~= GameEnum.ATTACK_MODE_GUILD then
		MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_GUILD)
	end

	self.cg_layer = GameObject.Find("GameRoot").transform
end

function CityCombatFBLogic:Out(old_scene_type, new_scene_type)
	CommonActivityLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.CityCombatFBView)
	MainUICtrl.Instance:SetViewState(true)
	GuajiType.IsManualState = false
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)

	self:SetBlock(false)
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_PEACE)
	CityCombatCtrl.Instance:ExitSceneShowAward()
	Scene.Instance:ClearCgObj()
end

function CityCombatFBLogic:Update(now_time, elapse_time)
	CommonActivityLogic.Update(self, now_time, elapse_time)

end

function CityCombatFBLogic:IsRoleEnemy(scene_obj, main_role)
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GONGCHENGZHAN) then
		return false
	end
	return not self:IsSameSide(scene_obj, main_role)
end

-- 设置角色头上名字的颜色
function CityCombatFBLogic:GetColorName(scene_obj)
	local name = scene_obj.vo.name

	local main_role = Scene.Instance:GetMainRole()
	if main_role == nil or scene_obj.vo.role_id == main_role.vo.role_id then
		return name
	end

	if not (scene_obj:GetType() == SceneObjType.Role) then
		return name
	end

	return self:IsRoleEnemy(scene_obj, main_role) and ToColorStr(name, TEXT_COLOR.RED) or ToColorStr(name, TEXT_COLOR.WHITE)
end

function CityCombatFBLogic:IsSameSide(target_obj, main_role)

	local def_gulid_id = CityCombatData.Instance:GetDefenceGulidID()
	local guild_id = target_obj:GetVo().guild_id
	if main_role:GetVo().guild_id == def_gulid_id then
		if main_role:GetVo().guild_id == target_obj:GetVo().guild_id then			-- 同一边
			return true
		else
			return false
		end
	else
		if target_obj:GetVo().guild_id == def_gulid_id then
			return false
		else
			return true
		end
	end
end

function CityCombatFBLogic:IsEnemy(target_obj, main_role, ignore_table)
	if nil == target_obj or nil == main_role or not target_obj:IsCharacter() then
		return false
	end
	
	if target_obj:IsDead() then
		return false
	end

	if main_role:IsInSafeArea() then											-- 自己在安全区
		return false
	end
	if target_obj:GetType() == SceneObjType.Monster then
		local id = target_obj:GetMonsterId()
		if not CityCombatData.Instance:GetIsAtkSide() then
			local flag_info = CityCombatData.Instance:GetFlagInfo()
			local wall_info = CityCombatData.Instance:GetWallInfo()
			if id == flag_info.id or id == wall_info.id then
				return false
			end
		end
	elseif target_obj:GetType() == SceneObjType.Role then
		local x,y = target_obj:GetLogicPos()
		local is_in_safe_area = target_obj:IsInSafeArea()
		if is_in_safe_area then
			return false
		else
			return self:IsRoleEnemy(target_obj, main_role)
		end
	end

	return BaseSceneLogic.IsEnemy(self, target_obj, main_role, ignore_table)
end

function CityCombatFBLogic:SetBlock(state)
	for k,v in pairs(self.block_grids) do
		if state then
			AStarFindWay:SetBlockInfo(v.x, v.y)
		else
			AStarFindWay:RevertBlockInfo(v.x, v.y)
		end
	end
	self.barrier_state = state
	self:UpdateBarrierState()
	self:UpdateChengMen(state)
end

function CityCombatFBLogic:UpdateBarrierState()
	if nil ~= self.barrier then
		self.barrier:SetActive(self.barrier_state)
	end
end

function CityCombatFBLogic:UpdateChengMen(barrier_state)
	if nil ~= self.chengmen then
		if barrier_state then
			if nil == self.chengmen_obj then
				local root_node = self.chengmen
				local bundle, asset = ResPath.GetMonsterModel(3088002)
				ResPoolMgr:GetDynamicObjAsyncInQueue(bundle, asset, function(obj)
					if nil == obj or nil == root_node or IsNil(root_node.transform) then
						ResPoolMgr:Release(obj)
						return
					end
					obj.transform:SetParent(root_node.transform)
					obj.transform.localScale = Vector3(1, 1, 1)
					obj.transform.localPosition = Vector3(61.3, -2.5, -0.66)
					self.chengmen_obj = obj
				end)
			end
		else
			if self.chengmen_obj then
				local chengmen_obj = U3DObject(self.chengmen_obj, self.chengmen_obj.transform, self)
				chengmen_obj.animator:SetInteger("status", 2)
				chengmen_obj.animator:WaitEvent("door_die", function(param)
					self.chengmen:SetActive(false)
					ResMgr:Destroy(self.chengmen_obj)
					self.chengmen_obj = nil
				end)
			end
		end
	end
end

function CityCombatFBLogic:GetGuajiPos()
	return CityCombatData.Instance:GetFlagPosXY()
end

function CityCombatFBLogic:GetIsShowSpecialImage(obj)
	local def_gulid_id = CityCombatData.Instance:GetDefenceGulidID()
	if obj:IsRole() then
		if obj.vo.is_immobile_role and obj.vo.is_immobile_role == 1 then
			return false
		end
		if obj.vo.guild_id == def_gulid_id then
			return true, "uis/views/floatingtext/images_atlas", "city_combine_1"
		else
			return true, "uis/views/floatingtext/images_atlas", "city_combine_0"
		end
	end
	return false
end