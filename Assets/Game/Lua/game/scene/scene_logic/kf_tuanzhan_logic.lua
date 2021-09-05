KfTuanZhanLogic = KfTuanZhanLogic or BaseClass(CrossServerSceneLogic)

function KfTuanZhanLogic:__init()

end

function KfTuanZhanLogic:__delete()

end

function KfTuanZhanLogic:Enter(old_scene_type, new_scene_type)
	if KuaFuTuanZhanData.Instance:GetIsCrossServerState() == 1 then 
		CrossServerSceneLogic.Enter(self, old_scene_type, new_scene_type)
	else
		CommonActivityLogic.Enter(self, old_scene_type, new_scene_type)
	end
	-- CrossServerSceneLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Open(ViewName.KuaFuTuanZhanTaskView)
	MainUICtrl.Instance:SetViewState(false)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	local main_role = Scene.Instance:GetMainRole()
	local attck_mode = PlayerPrefsUtil.GetInt("attck_mode", -1)
	if attck_mode ~= nil and attck_mode ~= -1 then
		PlayerPrefsUtil.SetInt("attck_mode", attck_mode)
	else
		PlayerPrefsUtil.SetInt("attck_mode", tonumber(main_role.vo.attack_mode))
	end
	if main_role.vo.attack_mode ~= GameEnum.ATTACK_MODE_ALL then
		MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_ALL)
	end
end

-- 是否可以拉取移动对象信息
function KfTuanZhanLogic:CanGetMoveObj()
	return true
end

-- 是否可以屏蔽怪物
function KfTuanZhanLogic:CanShieldMonster()
	return false
end

-- 是否自动设置挂机
function KfTuanZhanLogic:IsSetAutoGuaji()
	return true
end

function KfTuanZhanLogic:Out(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Out(self, old_scene_type, new_scene_type)
	-- CrossServerSceneLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.KuaFuTuanZhanTaskView)

	GuajiType.IsManualState = false
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	local main_role = Scene.Instance:GetMainRole()
	if main_role then
		main_role:SetRoleScore("")
	end
end

function KfTuanZhanLogic:DelayOut(old_scene_type, new_scene_type)
	CrossServerSceneLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end

-- 怪物是否是敌人
function KfTuanZhanLogic:IsMonsterEnemy(target_obj, main_role)
	if target_obj and target_obj:GetVo() then
		local monster_id = target_obj:GetVo().monster_id or 0
		if KuaFuTuanZhanData.Instance:IsSelfCampPillarByMonsterId(monster_id) then
			return false
		end
	end
	return true
end

function KfTuanZhanLogic:IsEnemy(target_obj, main_role, ignore_table)
	if self.is_map_block then
		return false
	end
	
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
		return true
	elseif target_obj:GetType() == SceneObjType.Role then
		local x,y = target_obj:GetLogicPos()
		local is_in_safe_area = target_obj:IsInSafeArea()
		if is_in_safe_area then
			return false
		else
			return self:IsRoleEnemy(target_obj, main_role)
		end
	end
end

function KfTuanZhanLogic:IsRoleEnemy(target_obj, main_role)
	return not self:IsSameSide(target_obj, main_role)
end

function KfTuanZhanLogic:IsSameSide(scene_obj, main_role)
	local info_list = KuaFuTuanZhanData.Instance:GetObjIDInfo()
	local scene_obj_vo = scene_obj:GetVo()
	if info_list and scene_obj_vo then
		local scene_obj_id = scene_obj_vo.obj_id or 0
		local first_side = info_list[scene_obj_id] and info_list[scene_obj_id].is_red_side or 0
		local my_side = KuaFuTuanZhanData.Instance:GetRoleInfo().is_red_side or 0
		if first_side == my_side then
			return true
		end
	end
	return false
end


-- function KfTuanZhanLogic:IsRoleEnemy(target_obj, main_role)
-- 	if math.floor(main_role:GetVo().special_param / 10000) == math.floor(target_obj:GetVo().special_param / 10000) then
-- 		return false, Language.Fight.Side
-- 	end
-- 	return true
-- end

function KfTuanZhanLogic:GetIsShowSpecialImage(obj)
	local obj_type = obj:GetType()
	if obj_type == SceneObjType.Role or obj_type == SceneObjType.MainRole then
		local role_side = obj:GetVo().special_param
		if role_side >= 0 and role_side <= 1 then
			return true, "uis/views/floatingtext/images_atlas", "kf_tuanzhan_side_" .. role_side
		end
	end
end

function KfTuanZhanLogic:GetIsShowSpecialScore(obj)
	local obj_type = obj:GetType()
	if obj_type == SceneObjType.Role or obj_type == SceneObjType.MainRole then
		return true
	end
	return false
end

-- 将图标移动到特殊位置
function KfTuanZhanLogic:GetSpecialImgPos()
	return -50, 1
end

function KfTuanZhanLogic:GetRoleScorePos()
	return 10
end

function KfTuanZhanLogic:GetGuajiPos()
	return KuaFuTuanZhanData.Instance:GetMonsterPos()
end

function KfTuanZhanLogic:GetColorName(scene_obj)
	local name = scene_obj.vo.name

	if scene_obj and scene_obj.vo.special_param == 0 then
		return ToColorStr(name, TEXT_COLOR.BLUE_4)
	else
		return ToColorStr(name, TEXT_COLOR.RED)
	end
	-- local main_role = Scene.Instance:GetMainRole()
	-- if main_role == nil or scene_obj.vo.role_id == main_role.vo.role_id then
	-- 	return name
	-- end

	-- if not (scene_obj:GetType() == SceneObjType.Role) then
	-- 	return name
	-- end

	-- return self:IsRoleEnemy(scene_obj, main_role) and ToColorStr(name, TEXT_COLOR.RED) or ToColorStr(name, TEXT_COLOR.BLUE)
end


-- 角色是否是敌人
function KfTuanZhanLogic:IsRoleEnemy(target_obj, main_role)
	if target_obj == nil then return false end
	local main_role = main_role or Scene.Instance:GetMainRole()
 	return KuaFuTuanZhanData.Instance:GetIsRedByObjId(target_obj:GetVo().obj_id) ~= KuaFuTuanZhanData.Instance:GetIsRedByObjId(main_role:GetVo().obj_id) 
end