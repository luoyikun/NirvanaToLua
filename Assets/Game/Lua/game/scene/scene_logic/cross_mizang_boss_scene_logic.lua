CrossMiZangBossSceneLogic = CrossMiZangBossSceneLogic or BaseClass(CrossServerSceneLogic)

function CrossMiZangBossSceneLogic:__init()
	
end

function CrossMiZangBossSceneLogic:__delete()

end

function CrossMiZangBossSceneLogic:Enter(old_scene_type, new_scene_type)
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

	ViewManager.Instance:Open(ViewName.CrossButtonView)
	ViewManager.Instance:Open(ViewName.FbIconView)
	ViewManager.Instance:Open(ViewName.CrossMiZangBossInfoView)
end

function CrossMiZangBossSceneLogic:Out(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Out(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)

	MainUICtrl.Instance:ChangeFightStateEnable(true)
	BossCtrl.Instance:CancelDpsFlag()
	ViewManager.Instance:Close(ViewName.CrossMiZangBossInfoView)
	ViewManager.Instance:CloseAll()
	MainUICtrl.Instance:RecoverMode()
end

function CrossMiZangBossSceneLogic:GetGuajiSelectObjDistance()
	return COMMON_CONSTS.SELECT_OBJ_DISTANCE_IN_BOSS_SCENE
end