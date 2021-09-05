LuanDouBattleSceneLogic = LuanDouBattleSceneLogic or BaseClass(CrossServerSceneLogic)

function LuanDouBattleSceneLogic:__init()
	self.last_check_time = 0
end

function LuanDouBattleSceneLogic:__delete()

end

function LuanDouBattleSceneLogic:Enter(old_scene_type, new_scene_type)	
	if LuanDouBattleData.Instance:GetIsCrossServerState() == 1 then 
		CrossServerSceneLogic.Enter(self, old_scene_type, new_scene_type)
	else
		CommonActivityLogic.Enter(self, old_scene_type, new_scene_type)
	end
	MainUICtrl.Instance:SetViewState(false)
	ViewManager.Instance:Open(ViewName.FbIconView)
	ViewManager.Instance:Open(ViewName.LuanDouBattleView)
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

function LuanDouBattleSceneLogic:Out(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Out(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
	ViewManager.Instance:Close(ViewName.FbIconView)
	ViewManager.Instance:Close(ViewName.LuanDouBattleView)
	ViewManager.Instance:Close(ViewName.LuanDouRewardView)
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_PEACE)
	GuajiType.IsManualState = false
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)

	local main_role = Scene.Instance:GetMainRole()
	if main_role then
		main_role:SetRoleScore("")
	end
end

function LuanDouBattleSceneLogic:OnClickHeadHandler(is_show)
	CommonActivityLogic.OnClickHeadHandler(self, is_show)
end

-- 角色是否是敌人
function LuanDouBattleSceneLogic:IsRoleEnemy(target_obj, main_role)
 	return true
end

-- 获取挂机打怪的敌人
function LuanDouBattleSceneLogic:GetGuiJiMonsterEnemy()
	local x, y = Scene.Instance:GetMainRole():GetLogicPos()
	local distance_limit = COMMON_CONSTS.SELECT_OBJ_DISTANCE * COMMON_CONSTS.SELECT_OBJ_DISTANCE
	local obj,dis = Scene.Instance:SelectObjHelper(Scene.Instance:GetRoleList(), x, y, distance_limit, SelectType.Enemy)
	if obj then
		return obj,dis
	else
		return Scene.Instance:SelectObjHelper(Scene.Instance:GetMonsterList(), x, y, distance_limit, SelectType.Enemy)
	end
end

function LuanDouBattleSceneLogic:GetColorName(scene_obj)
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

function LuanDouBattleSceneLogic:GetIsShowSpecialImage(obj)
	local obj_type = obj:GetType()
	if obj_type == SceneObjType.Role or obj_type == SceneObjType.MainRole then
		return true, "uis/views/floatingtext/images_atlas", "luandou_shuijing"
	end
end

-- 将图标移动到特殊位置
function LuanDouBattleSceneLogic:GetSpecialImgPos()
	return -50, 1
end

function LuanDouBattleSceneLogic:GetRoleScorePos()
	return 0
end