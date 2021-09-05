KFBorderlandSceneLogin = KFBorderlandSceneLogin or BaseClass(CrossServerSceneLogic)

function KFBorderlandSceneLogin:__init()

end

function KFBorderlandSceneLogin:__delete()

end

function KFBorderlandSceneLogin:Enter(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.Map)
	SysMsgCtrl.Instance:ErrorRemind(Language.Activity.CannotChangeMode2)
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

	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	MainUICtrl.Instance:SetViewState(false)
	ViewManager.Instance:Open(ViewName.FbIconView)
	ViewManager.Instance:Open(ViewName.KuaFuBorderland)
	ViewManager.Instance:Open(ViewName.CrossButtonView)
end

function KFBorderlandSceneLogin:Out(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.FbIconView)
	ViewManager.Instance:Close(ViewName.KuaFuBorderland)
	ViewManager.Instance:Close(ViewName.CrossButtonView)
	GuajiType.IsManualState = false
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
end

function KFBorderlandSceneLogin:DelayOut(old_scene_type, new_scene_type)
	CrossServerSceneLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end

-- 角色是否是敌人
function KFBorderlandSceneLogin:IsRoleEnemy(target_obj, main_role)
	local attack_mode = main_role:GetVo().attack_mode
	if (FightData.Instance:GetIsFightbackObj(target_obj:GetVo().is_fightback_obj or 0) or target_obj:GetVo().name_color ~= GameEnum.NAME_COLOR_WHITE) 
		and attack_mode ~= GameEnum.ATTACK_MODE_SREVER then
		return true
	end

	return not (ScoietyData.Instance:IsTeamMember(target_obj:GetRoleId()) or (main_role:GetVo().guild_id ~= 0 and main_role:GetVo().guild_id == target_obj:GetVo().guild_id))
end