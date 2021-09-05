CrossCrystalSceneLogic = CrossCrystalSceneLogic or BaseClass(CommonActivityLogic)

function CrossCrystalSceneLogic:__init()
end

function CrossCrystalSceneLogic:__delete()

end

function CrossCrystalSceneLogic:Enter(old_scene_type, new_scene_type)
	CommonActivityLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Open(ViewName.CrossCrystalInfoView)
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

function CrossCrystalSceneLogic:Out(old_scene_type, new_scene_type)
	CommonActivityLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.CrossCrystalInfoView)
	GuajiType.IsManualState = false
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
end

function CrossCrystalSceneLogic:IsCanAutoGather()
	return false
end