YiZhanDaoDiSceneLogic = YiZhanDaoDiSceneLogic or BaseClass(BaseFbLogic)

function YiZhanDaoDiSceneLogic:__init()

end

function YiZhanDaoDiSceneLogic:__delete()
	
end

function YiZhanDaoDiSceneLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_ALL)
	MainUICtrl.Instance:SetViewState(false)
	ViewManager.Instance:Open(ViewName.YiZhanDaoDiView)
end

function YiZhanDaoDiSceneLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_PEACE)
	ViewManager.Instance:Close(ViewName.YiZhanDaoDiView)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
end

function YiZhanDaoDiSceneLogic:DelayOut(old_scene_type, new_scene_type)
	CrossServerSceneLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
	GlobalEventSystem:Fire(ObjectEventType.FIGHT_EFFECT_CHANGE)
end
