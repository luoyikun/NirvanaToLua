TowerArmorFbSceneLogic = TowerArmorFbSceneLogic or BaseClass(BaseFbLogic)

function TowerArmorFbSceneLogic:__init()
	self.mainui_open = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpen, self))
end

function TowerArmorFbSceneLogic:__delete()
	if self.mainui_open then
		GlobalEventSystem:UnBind(self.mainui_open)
		self.mainui_open = nil
	end
end

function TowerArmorFbSceneLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(false)
	ViewManager.Instance:Open(ViewName.FuBenArmorInfoView)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	FuBenData.Instance:SetTowerIsWarning(false)

	if ViewManager.Instance:IsOpen(ViewName.GaoZhanFuBen) then
		ViewManager.Instance:Close(ViewName.GaoZhanFuBen)
	end
end

function TowerArmorFbSceneLogic:Update(now_time, elapse_time)
	BaseFbLogic.Update(self, now_time, elapse_time)
end

function TowerArmorFbSceneLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	GuajiCtrl.Instance:StopGuaji()
	ViewManager.Instance:Close(ViewName.FuBenArmorInfoView)
	TipsCtrl.Instance:CloseFBDropView()
	FuBenData.Instance:ClearFBDropInfo()
	MainUICtrl.Instance:SetViewState(true)
	self.open_delay = GlobalTimerQuest:AddDelayTimer(function()
		local role_level = PlayerData.Instance:GetRoleVo().level
		local info = FuBenData.Instance:GetGuardPass()
		if role_level >= GameEnum.NOVICE_LEVEL then
			ViewManager.Instance:Open(ViewName.GaoZhanFuBen, TabIndex.fb_guard)
			if info.is_passed == 1 then
				local gao_zhan_view = GaoZhanCtrl.Instance:GetGaoZhanView()
				local index = FuBenData.Instance:GetSelectLevel()
				gao_zhan_view.guard_view:FlushScollView(index)
			end
		end
		GlobalTimerQuest:CancelQuest(self.open_delay)
		self.open_delay = nil
	end, 0)
end

function TowerArmorFbSceneLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
end

function TowerArmorFbSceneLogic:MainuiOpen()
	MainUICtrl.Instance:SetViewState(false)
end
