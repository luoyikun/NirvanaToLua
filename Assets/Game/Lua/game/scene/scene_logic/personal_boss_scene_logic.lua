PersonalBossSceneLogic = PersonalBossSceneLogic or BaseClass(BaseFbLogic)

function PersonalBossSceneLogic:__init()

end

function PersonalBossSceneLogic:__delete()

end

function PersonalBossSceneLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(false)
	ViewManager.Instance:Close(ViewName.Boss)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
end

function PersonalBossSceneLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end

function PersonalBossSceneLogic:OpenFbSceneCd()

end

function PersonalBossSceneLogic:GetMoveObjAllInfoFrequency()
	return 3
end