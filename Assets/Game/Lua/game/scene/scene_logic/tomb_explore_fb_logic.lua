TombExploreFBLogic = TombExploreFBLogic or BaseClass(BaseFbLogic)

function TombExploreFBLogic:__init()

end

function TombExploreFBLogic:__delete()

end

function TombExploreFBLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Open(ViewName.TombExploreFBView)
	MainUICtrl.Instance:SetViewState(false)
	local main_role = Scene.Instance:GetMainRole()
	local attck_mode = PlayerPrefsUtil.GetInt("attck_mode", -1)
	if attck_mode ~= nil and attck_mode ~= -1 then
		PlayerPrefsUtil.SetInt("attck_mode", attck_mode)
	else
		PlayerPrefsUtil.SetInt("attck_mode", tonumber(main_role.vo.attack_mode))
	end
	if main_role.vo.attack_mode ~= GameEnum.ATTACK_MODE_TEAM then
		MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_TEAM)
	end
end

function TombExploreFBLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.TombExploreFBView)
	GuajiType.IsManualState = false
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	MainUICtrl.Instance:SetvisibleGath()
end

function TombExploreFBLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end