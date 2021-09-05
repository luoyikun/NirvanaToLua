HunYanFbLogic = HunYanFbLogic or BaseClass(BaseFbLogic)

function HunYanFbLogic:__init()

end

function HunYanFbLogic:__delete()

end

function HunYanFbLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_PEACE)

	MarriageCtrl.Instance:CloseAllView()
	ViewManager.Instance:Close(ViewName.WeddingDeMandView)
	ViewManager.Instance:Open(ViewName.FuBenHunYanInfoView)
	MainUICtrl.Instance:SetViewState(false)
	MainUICtrl.Instance:SetViewHideorShow("RightBttomPanel", false)
end

function HunYanFbLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:CloseAll()
	ViewManager.Instance:Close(ViewName.FuBenHunYanInfoView)
	MainUICtrl.Instance:SetViewState(true)
	MainUICtrl.Instance:SetViewHideorShow("RightBttomPanel", true)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
end

function HunYanFbLogic:IsEnemy(target_obj, main_role, ignore_table)
	-- 婚宴副本不给攻击
	return false
end
