GiftHarvest = GiftHarvest or BaseClass(BaseFbLogic)

function GiftHarvest:__init()

end

function GiftHarvest:__delete()

end

function GiftHarvest:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Open(ViewName.ChristmaGiftFuBenView)
	-- ViewManager.Instance:Open(ViewName.SkillGiftFuBenView)
	--local fb_cfg = Scene.Instance:GetCurFbSceneCfg()
	if MainUICtrl.Instance.view then
		MainUICtrl.Instance.view:SetViewState(false)
	end
	-- MainUIView.Instance:SetSkillActive(false)
	if ViewManager.Instance:IsOpen(ViewName.FestivalView) then
		ViewManager.Instance:Close(ViewName.FestivalView)
	end
	
end

function GiftHarvest:IsRoleEnemy()
	return false
end

-- 是否可以屏蔽怪物
function GiftHarvest:CanShieldMonster()
	return false
end
function GiftHarvest:CanAutoGuaJi()
	return false
end
function GiftHarvest:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.FuBenTowerInfoView)
	--if ViewManager.Instance:IsOpen(ViewName.FBVictoryFinishView) then
	--	ViewManager.Instance:Close(ViewName.FBVictoryFinishView)
	--end
	--if ViewManager.Instance:IsOpen(ViewName.FBFailFinishView) then
	--	GlobalEventSystem:Fire(OtherEventType.CLOSE_FUBEN_FAIL_VIEW)
	--	-- ViewManager.Instance:Close(ViewName.FBFailFinishView)
	--end
	ViewManager.Instance:Close(ViewName.ChristmaGiftFuBenView)
	-- ViewManager.Instance:Close(ViewName.SkillGiftFuBenView)
	if ViewManager.Instance:IsOpen(ViewName.CommonTips) then
		ViewManager.Instance:Close(ViewName.CommonTips)
	end
	-- MainUIView.Instance:SetSkillActive(true)
	--FuBenData.Instance:ClearFBSceneLogicInfo()
end

function GiftHarvest:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end