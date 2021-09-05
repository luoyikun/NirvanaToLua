RuneTowerFbLogic = RuneTowerFbLogic or BaseClass(BaseFbLogic)

function RuneTowerFbLogic:__init()
	if MainCameraFollow then
		MainCameraFollow.StopCameraUpdate = true
	end
end

function RuneTowerFbLogic:__delete()
end

function RuneTowerFbLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	if MainCameraFollow then
		MainCameraFollow.StopCameraUpdate = false
	end
	ViewManager.Instance:CloseAll()
	MainUICtrl.Instance:SetViewState(false)
	ViewManager.Instance:Open(ViewName.RuneTowerFbInfoView)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	GuaJiTaCtrl.Instance:SendRuneTowerAuto(RUNE_TOWER_FB_OPER_TYPE.RUNE_TOWER_FB_OPER_REFRESH_MONSTER)
end

-- 是否可以拉取移动对象信息
function RuneTowerFbLogic:CanGetMoveObj()
	return true
end

function RuneTowerFbLogic:CanMove()
	return GuaJiTaCtrl.Instance:GetCanMove()
end

-- 是否可以屏蔽怪物
function RuneTowerFbLogic:CanShieldMonster()
	return false
end

-- 是否自动设置挂机
function RuneTowerFbLogic:IsSetAutoGuaji()
	return true
end

function RuneTowerFbLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.RuneTowerFbInfoView)
	if ViewManager.Instance:IsOpen(ViewName.FBVictoryFinishView) then
		ViewManager.Instance:Close(ViewName.FBVictoryFinishView)
	end
	if ViewManager.Instance:IsOpen(ViewName.FBFailFinishView) then
		GlobalEventSystem:Fire(OtherEventType.CLOSE_FUBEN_FAIL_VIEW)
	end
	if ViewManager.Instance:IsOpen(ViewName.CommonTips) then
		ViewManager.Instance:Close(ViewName.CommonTips)
	end
	if ViewManager.Instance:IsOpen(ViewName.Rune) then
		ViewManager.Instance:Close(ViewName.Rune)
	end
	GuajiCtrl.Instance:StopGuaji()
	FuBenData.Instance:ClearFBSceneLogicInfo()
	if new_scene_type ~= SceneType.RuneTower then
		local role_level = PlayerData.Instance:GetRoleVo().level
		if role_level >= GameEnum.NOVICE_LEVEL then
			ViewManager.Instance:Open(ViewName.Rune, TabIndex.rune_tower)
		end
		MainUICtrl.Instance:SetViewState(true)
	end
end

-- function RuneTowerFbLogic:DelayOut(old_scene_type, new_scene_type)
-- 	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
-- 	MainUICtrl.Instance:SetViewState(true)
-- end