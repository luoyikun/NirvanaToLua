CrystalEscortSceneLogic = CrystalEscortSceneLogic or BaseClass(CommonActivityLogic)

function CrystalEscortSceneLogic:__init()
end

function CrystalEscortSceneLogic:__delete()

end

function CrystalEscortSceneLogic:Enter(old_scene_type, new_scene_type)
	CommonActivityLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Open(ViewName.CrystalEscortView)
	-- ViewManager.Instance:Close(ViewName.Guild)
		MainUICtrl.Instance:SetViewState(false)
	GlobalTimerQuest:AddDelayTimer(function()
		GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)
		end, 0.1)
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_SREVER)
end

function CrystalEscortSceneLogic:Out(old_scene_type, new_scene_type)
	CommonActivityLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.CrystalEscortView)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	MainUICtrl.Instance:SetViewState(true)
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_PEACE)
end

function CrystalEscortSceneLogic:CanGetMoveObj()
	return true
end

function CrystalEscortSceneLogic:GetMoveObjAllInfoFrequency()
	return 3
end

-- function CrystalEscortSceneLogic:IsRoleEnemy(target_obj, main_role)
-- 	return false
-- end