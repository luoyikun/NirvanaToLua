WeaponMaterialsFbLogic = WeaponMaterialsFbLogic or BaseClass(BaseFbLogic)

function WeaponMaterialsFbLogic:__init()
	self.mainui_open = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpen, self))
end

function WeaponMaterialsFbLogic:__delete()
	if self.mainui_open then
		GlobalEventSystem:UnBind(self.mainui_open)
		self.mainui_open = nil
	end
end

function WeaponMaterialsFbLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Open(ViewName.FuBenWeaponInfoView)
	MainUICtrl.Instance:SetViewState(false)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)

	if ViewManager.Instance:IsOpen(ViewName.GaoZhanFuBen) then
		ViewManager.Instance:Close(ViewName.GaoZhanFuBen)
	end
end

-- 是否可以拉取移动对象信息
function WeaponMaterialsFbLogic:CanGetMoveObj()
	return true
end

-- 是否可以屏蔽怪物
function WeaponMaterialsFbLogic:CanShieldMonster()
	return false
end

-- 是否自动设置挂机
function WeaponMaterialsFbLogic:IsSetAutoGuaji()
	return true
end

function WeaponMaterialsFbLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.FuBenWeaponInfoView)
	MainUICtrl.Instance:SetViewState(true)
	if ViewManager.Instance:IsOpen(ViewName.GaoZhanFuBen) then
		ViewManager.Instance:Close(ViewName.GaoZhanFuBen)
	end
	if ViewManager.Instance:IsOpen(ViewName.FBFinishView) then
		ViewManager.Instance:Close(ViewName.FBFinishView)
	end
	GuajiCtrl.Instance:StopGuaji()

	FuBenData.Instance:ClearFBSceneLogicInfo()
	self.open_delay = GlobalTimerQuest:AddDelayTimer(function()
		local is_open_fail = ViewManager.Instance:IsOpen(ViewName.FBFailFinishView)
		ViewManager.Instance:CloseAll()
		if UIScene.role_model then
			UIScene:DeleteModels()
		end
		ViewManager.Instance:Open(ViewName.GaoZhanFuBen, TabIndex.fb_weapon)
		if is_open_fail then
			ViewManager.Instance:Open(ViewName.FBFailFinishView)
		end
		GlobalTimerQuest:CancelQuest(self.open_delay)
		self.open_delay = nil
	end, 0.5)
end

function WeaponMaterialsFbLogic:MainuiOpen()
	MainUICtrl.Instance:SetViewState(false)
end
