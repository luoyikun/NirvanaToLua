VipFbLogic = VipFbLogic or BaseClass(BaseFbLogic)

function VipFbLogic:__init()
	self.mainui_open = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpen, self))
end

function VipFbLogic:__delete()
	if self.mainui_open then
		GlobalEventSystem:UnBind(self.mainui_open)
		self.mainui_open = nil
	end
end

function VipFbLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	local main_role = Scene.Instance:GetMainRole()
	local attck_mode = PlayerPrefsUtil.GetInt("attck_mode", -1)
	if attck_mode ~= nil and attck_mode ~= -1 then
		PlayerPrefsUtil.SetInt("attck_mode", attck_mode)
	else
		PlayerPrefsUtil.SetInt("attck_mode", tonumber(main_role.vo.attack_mode))
	end
	local attack_mode = GameEnum.ATTACK_MODE_GUILD
	if IS_ON_CROSSSERVER then
		attack_mode = GameEnum.ATTACK_MODE_SREVER
	end
	if main_role.vo.attack_mode ~= attack_mode then
		MainUICtrl.Instance:SendSetAttackMode(attack_mode)
	end
	ViewManager.Instance:Close(ViewName.Boss)
	ViewManager.Instance:Open(ViewName.BossFamilyInfoView)
	local scene_id = Scene.Instance:GetSceneId()
	ViewManager.Instance:FlushView(ViewName.BossFamilyInfoView, "boss_type", {boss_type = BossData.Instance:IsFamilyBossScene(scene_id) and 0 or 1})
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	MainUICtrl.Instance:SetViewState(false)
end

-- 是否可以屏蔽怪物
function VipFbLogic:CanShieldMonster()
	return false
end

-- 是否自动设置挂机
function VipFbLogic:IsSetAutoGuaji()
	return true
end

function VipFbLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)

	ViewManager.Instance:Close(ViewName.BossFamilyInfoView)
	BossData.Instance:ClearCache()
	GuajiCtrl.Instance:StopGuaji()
	MainUICtrl.Instance:SetViewState(true)
	BossCtrl.Instance:CancelDpsFlag()
end


function VipFbLogic:MainuiOpen()
	MainUICtrl.Instance:SetViewState(false)
end

