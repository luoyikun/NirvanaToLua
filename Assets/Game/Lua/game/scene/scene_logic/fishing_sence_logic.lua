FishingSceneLogic = FishingSceneLogic or BaseClass(CrossServerSceneLogic)

function FishingSceneLogic:__init()

end

function FishingSceneLogic:__delete()

end

function FishingSceneLogic:Enter(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Enter(self, old_scene_type, new_scene_type)
	local main_role = Scene.Instance:GetMainRole()
	local attck_mode = PlayerPrefsUtil.GetInt("attck_mode", -1)
	if attck_mode ~= nil and attck_mode ~= -1 then
		PlayerPrefsUtil.SetInt("attck_mode", attck_mode)
	else
		PlayerPrefsUtil.SetInt("attck_mode", tonumber(main_role.vo.attack_mode))
	end
	if main_role.vo.attack_mode ~= GameEnum.ATTACK_MODE_PEACE then
		MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_PEACE)
	end

	MainUICtrl.Instance:SetViewState(false)
	local mian_view = MainUICtrl.Instance:GetView()
	if mian_view then
		mian_view.node_list["FishToggle"]:SetActive(true)
		mian_view.node_list["FishToggle"].toggle.isOn = true
	end
	-- 是否自动钓鱼 0不自动 1自动
	CrossFishingData.Instance:SetAutoFishing(0)
	ViewManager.Instance:Open(ViewName.FbIconView)
	ViewManager.Instance:Open(ViewName.FishingView)
end

function FishingSceneLogic:Out(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Out(self, old_scene_type, new_scene_type)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)

	MainUICtrl.Instance:SetViewState(true)
	local mian_view = MainUICtrl.Instance:GetView()
	if mian_view then
		mian_view.node_list["FishToggle"].toggle.isOn = false
		mian_view.node_list["FishToggle"]:SetActive(false)
	end
	ViewManager.Instance:Close(ViewName.FishingView)
	ViewManager.Instance:Close(ViewName.FbIconView)

	if ViewManager.Instance:IsOpen(ViewName.CreelPanel) then
		ViewManager.Instance:Close(ViewName.CreelPanel)
	end
	GuajiType.IsManualState = false
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	MainUICtrl.Instance:SetvisibleGath()
end

function FishingSceneLogic:DelayOut(old_scene_type, new_scene_type)
	CrossServerSceneLogic.DelayOut(self, old_scene_type, new_scene_type)

	-- 是否自动钓鱼 0不自动 1自动
	CrossFishingData.Instance:SetAutoFishing(0)
	ViewManager.Instance:Close(ViewName.FishingView)
end