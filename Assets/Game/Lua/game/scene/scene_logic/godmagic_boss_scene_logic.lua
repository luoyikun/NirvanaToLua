GodMagicBossSceneLogic = GodMagicBossSceneLogic or BaseClass(BaseFbLogic)

function GodMagicBossSceneLogic:__init()
	self.mainui_open = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpen, self))
end

function GodMagicBossSceneLogic:__delete()
	if self.mainui_open then
		GlobalEventSystem:UnBind(self.mainui_open)
		self.mainui_open = nil
	end
end

function GodMagicBossSceneLogic:Enter(old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.ShenYuBossView)
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
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)

	MainUICtrl.Instance:SetViewState(false)
	MainUICtrl.Instance:ChangeFightStateEnable(false)
	
	ViewManager.Instance:Open(ViewName.FbIconView)
	ViewManager.Instance:Open(ViewName.BossGodMagicFightView)
end

function GodMagicBossSceneLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
	MainUICtrl.Instance:ChangeFightStateEnable(true)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	BossCtrl.Instance:CancelDpsFlag()
	ViewManager.Instance:Close(ViewName.BossGodMagicFightView)
	ViewManager.Instance:CloseAll()
	MainUICtrl.Instance:RecoverMode()
end

function GodMagicBossSceneLogic:GetGuajiSelectObjDistance()
	return COMMON_CONSTS.SELECT_OBJ_DISTANCE_IN_BOSS_SCENE
end

function GodMagicBossSceneLogic:MainuiOpen()
	MainUICtrl.Instance:SetViewState(false)
end