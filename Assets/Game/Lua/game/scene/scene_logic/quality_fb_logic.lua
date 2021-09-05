QualityFbLogic = QualityFbLogic or BaseClass(BaseFbLogic)

function QualityFbLogic:__init()

end

function QualityFbLogic:__delete()

end

function QualityFbLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.GaoZhanFuBen)
	ViewManager.Instance:Open(ViewName.FuBenQualityInfoView)
	MainUICtrl.Instance:SetViewState(false)
	FuBenCtrl.Instance:FulshEndTime()
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	if ViewManager.Instance:IsOpen(ViewName.GaoZhanFuBen) then
		ViewManager.Instance:Close(ViewName.GaoZhanFuBen)
	end
end

-- 是否可以拉取移动对象信息
function QualityFbLogic:CanGetMoveObj()
	return true
end

-- 是否可以屏蔽怪物
function QualityFbLogic:CanShieldMonster()
	return false
end

-- 是否自动设置挂机
function QualityFbLogic:IsSetAutoGuaji()
	return true
end

function QualityFbLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.FuBenQualityInfoView)
	TipsCtrl.Instance:CloseFBDropView()
	MainUICtrl.Instance:SetViewState(true)
	if ViewManager.Instance:IsOpen(ViewName.FBFinishStarView) then
		-- ViewManager.Instance:Close(ViewName.FBFinishStarView)
	end

	if ViewManager.Instance:IsOpen(ViewName.FBFailFinishView) then
		GlobalEventSystem:Fire(OtherEventType.CLOSE_FUBEN_FAIL_VIEW)
	end
	GuajiCtrl.Instance:StopGuaji()

	if new_scene_type == SceneType.Common and FuBenData.Instance:GetOneLevelChallengeInfoByLevel(1) then
		self.open_delay = GlobalTimerQuest:AddDelayTimer(function()
			ViewManager.Instance:Open(ViewName.GaoZhanFuBen, TabIndex.fb_quality)
			GlobalTimerQuest:CancelQuest(self.open_delay)
			self.open_delay = nil
		end, 0.5)
	end
end
