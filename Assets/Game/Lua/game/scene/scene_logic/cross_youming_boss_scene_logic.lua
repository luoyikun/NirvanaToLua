CrossYouMingBossSceneLogic = CrossYouMingBossSceneLogic or BaseClass(CrossServerSceneLogic)

function CrossYouMingBossSceneLogic:__init()
	
end

function CrossYouMingBossSceneLogic:__delete()

end

function CrossYouMingBossSceneLogic:Enter(old_scene_type, new_scene_type)
	local main_role = Scene.Instance:GetMainRole()
	local attck_mode = PlayerPrefsUtil.GetInt("attck_mode", -1)
	if attck_mode ~= nil and attck_mode ~= -1 then
		PlayerPrefsUtil.SetInt("attck_mode", attck_mode)
	else
		PlayerPrefsUtil.SetInt("attck_mode", tonumber(main_role.vo.attack_mode))
	end
	if main_role.vo.attack_mode ~= GameEnum.ATTACK_MODE_SREVER then
		MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_SREVER)
		MainUICtrl.Instance:LimitAttackMode({GameEnum.ATTACK_MODE_ALL, GameEnum.ATTACK_MODE_TEAM, GameEnum.ATTACK_MODE_GUILD, GameEnum.ATTACK_MODE_PEACE, GameEnum.ATTACK_MODE_SREVER})
	end
	CrossServerSceneLogic.Enter(self, old_scene_type, new_scene_type)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)

	MainUICtrl.Instance:SetViewState(false)
	MainUICtrl.Instance:ChangeFightStateEnable(false)
	
	ViewManager.Instance:Open(ViewName.FbIconView)
	ViewManager.Instance:Open(ViewName.CrossYouMingBossInfoView)
end

function CrossYouMingBossSceneLogic:Out(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Out(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
	MainUICtrl.Instance:ChangeFightStateEnable(true)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)

	ViewManager.Instance:Close(ViewName.CrossYouMingBossInfoView)
	ViewManager.Instance:CloseAll()
	MainUICtrl.Instance:RecoverMode()
end

function CrossYouMingBossSceneLogic:GetGuajiSelectObjDistance()
	return COMMON_CONSTS.SELECT_OBJ_DISTANCE_IN_BOSS_SCENE
end