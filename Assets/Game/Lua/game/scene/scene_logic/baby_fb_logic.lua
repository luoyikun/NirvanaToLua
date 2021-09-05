BabyFBLogic = BabyFBLogic or BaseClass(BaseFbLogic)

function BabyFBLogic:__init()
	self.mainui_open = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpen, self))
end

function BabyFBLogic:__delete()
	if self.mainui_open then
		GlobalEventSystem:UnBind(self.mainui_open)
		self.mainui_open = nil
	end
end

-- 进入场景
function BabyFBLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(false)

	ViewManager.Instance:Close(ViewName.Boss)
	local scene_id = Scene.Instance:GetSceneId()
	if BossData.Instance:IsBabyBossScene(scene_id) then
		ViewManager.Instance:Open(ViewName.BabyBossFightView)
	end

	local main_role = Scene.Instance:GetMainRole()
	PlayerPrefsUtil.SetInt("attck_mode", tonumber(main_role.vo.attack_mode))
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_PEACE)

	FuBenCtrl.Instance:GetFuBenIconView():Open()
	FuBenCtrl.Instance:GetFuBenIconView():Flush()
end

function BabyFBLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)

	BossCtrl.Instance:CloseBabyBossInfoView()
	BossCtrl.Instance:CancelDpsFlag()
	MainUICtrl.Instance:SetViewState(true)
end

function BabyFBLogic:DelayOut(old_scene_type, new_scene_type)
	-- BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end

-- 是否自动设置挂机
function BabyFBLogic:IsSetAutoGuaji()
	return false
end

function BabyFBLogic:MainuiOpen()
	MainUICtrl.Instance:SetViewState(false)
end