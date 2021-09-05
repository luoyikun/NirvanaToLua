CrossBossSceneLogic = CrossBossSceneLogic or BaseClass(CrossServerSceneLogic)

function CrossBossSceneLogic:__init()
	
end

function CrossBossSceneLogic:__delete()

end

function CrossBossSceneLogic:Enter(old_scene_type, new_scene_type)
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
	ViewManager.Instance:Close(ViewName.Activity)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	MainUICtrl.Instance:SetViewState(false)

	ViewManager.Instance:Open(ViewName.CrossButtonView)

	local scene_id = Scene.Instance:GetSceneId()
	if BossData.Instance:IsCrossBossScene(scene_id) then
		ViewManager.Instance:Open(ViewName.CrossBossFightView)
	end
end

function CrossBossSceneLogic:Out(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.CrossButtonView)
	MainUICtrl.Instance:SetViewState(true)
	GuajiType.IsManualState = false
	BossCtrl.Instance:CancelDpsFlag()
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	BossCtrl.Instance:CloseCrossFamFightView()
	MainUICtrl.Instance:RecoverMode()
end

function CrossBossSceneLogic:GetGuajiSelectObjDistance()
	return COMMON_CONSTS.SELECT_OBJ_DISTANCE_IN_BOSS_SCENE
end