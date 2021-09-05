ZhuanZhiFbLogic = ZhuanZhiFbLogic or BaseClass(BaseFbLogic)

function ZhuanZhiFbLogic:__init()

end

function ZhuanZhiFbLogic:__delete()
end

function ZhuanZhiFbLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(false)
	ViewManager.Instance:CloseAll()
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
end

-- 是否可以拉取移动对象信息
function ZhuanZhiFbLogic:CanGetMoveObj()
	return true
end

-- 是否可以屏蔽怪物
function ZhuanZhiFbLogic:CanShieldMonster()
	return false
end

-- 是否自动设置挂机
function ZhuanZhiFbLogic:IsSetAutoGuaji()
	return true
end

function ZhuanZhiFbLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.FuBenPushInfoView)
	if ViewManager.Instance:IsOpen(ViewName.FuBenFinishStarNextView) then
		ViewManager.Instance:Close(ViewName.FuBenFinishStarNextView)
	end
	
	if ViewManager.Instance:IsOpen(ViewName.FBFinishStarView) then
		ViewManager.Instance:Close(ViewName.FBFinishStarView)
	end

	if ViewManager.Instance:IsOpen(ViewName.FBFailFinishView) then
		GlobalEventSystem:Fire(OtherEventType.CLOSE_FUBEN_FAIL_VIEW)
	end
	GuajiCtrl.Instance:StopGuaji()

	FuBenData.Instance:ClearFBSceneLogicInfo()
end

function ZhuanZhiFbLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end
