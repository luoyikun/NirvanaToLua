TowerDefendFbSceneLogic = TowerDefendFbSceneLogic or BaseClass(BaseFbLogic)

function TowerDefendFbSceneLogic:__init()
	self.mainui_open = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpen, self))
end

function TowerDefendFbSceneLogic:__delete()

end

function TowerDefendFbSceneLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(false)
	ViewManager.Instance:CloseAll()
	ViewManager.Instance:Open(ViewName.FuBenGuardInfoView)
	ViewManager.Instance:Close(ViewName.GaoZhanFuBen)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	FuBenData.Instance:SetTowerIsWarning(false)
end

function TowerDefendFbSceneLogic:Update(now_time, elapse_time)
	BaseFbLogic.Update(self, now_time, elapse_time)
end

function TowerDefendFbSceneLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	GuajiCtrl.Instance:StopGuaji()
	ViewManager.Instance:Close(ViewName.FuBenGuardInfoView)
	FuBenData.Instance:ClearFBDropInfo()
	TipsCtrl.Instance:CloseFBDropView()
	MainUICtrl.Instance:SetViewState(true)
	self.open_delay = GlobalTimerQuest:AddDelayTimer(function()
		local role_level = PlayerData.Instance:GetRoleVo().level
		local info = FuBenData.Instance:GetTowerDefendInfo()
		if role_level >= GameEnum.NOVICE_LEVEL then
			ViewManager.Instance:Open(ViewName.GaoZhanFuBen, TabIndex.fb_armor)
			-- if info.is_pass == 1 then
			-- 	local gao_zhan_view = GaoZhanCtrl.Instance:GetGaoZhanView()
			-- 	local index = FuBenData.Instance:GetArmorSelectLevel()
			-- 	gao_zhan_view.armor_view:FlushSelectItem(index + 1)
			-- end
		end
		GlobalTimerQuest:CancelQuest(self.open_delay)
		self.open_delay = nil
	end, 0)
end

function TowerDefendFbSceneLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
end

function TowerDefendFbSceneLogic:GetGuajiPos()
	local pos = FuBenData.Instance:GetArmorDefendChapterCfg(1)
	return pos.birth_pos_x, pos.birth_pos_y
end

-- 不屏蔽怪物的列表
function TowerDefendFbSceneLogic:NotShieldMonsterList()
	local monster_list = {{id = 1100},}
	return monster_list, 1
end

function TowerDefendFbSceneLogic:MainuiOpen()
	MainUICtrl.Instance:SetViewState(false)
end