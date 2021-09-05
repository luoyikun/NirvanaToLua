ExpFbLogic = ExpFbLogic or BaseClass(BaseFbLogic)

function ExpFbLogic:__init()
	self.mainui_open = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpen, self))
end

function ExpFbLogic:__delete()
	if self.mainui_open then
		GlobalEventSystem:UnBind(self.mainui_open)
		self.mainui_open = nil
	end
end

function ExpFbLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:CloseAll()
	ViewManager.Instance:Open(ViewName.FuBenExpInfoView)
	ViewManager.Instance:Close(ViewName.TipsEnterFbView)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)

	if ViewManager.Instance:IsOpen(ViewName.FBVictoryFinishView) then
		ViewManager.Instance:Close(ViewName.FBVictoryFinishView)
	end
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_PEACE)
	MainUICtrl.Instance:SetViewState(false)
	ViewManager.Instance:Close(ViewName.Player)
	FuBenCtrl.Instance:CloseView()
	-- 进入经验本，自动鼓舞
	if FuBenData.Instance:GetIsAutoGuWu() then
		-- 发送自动鼓舞请求
		FuBenCtrl.Instance:SendExpFbPayGuwu(1)
	end
end

-- 是否可以拉取移动对象信息
function ExpFbLogic:CanGetMoveObj()
	return true
end

-- 是否自动设置挂机
function ExpFbLogic:IsSetAutoGuaji()
	return true
end

function ExpFbLogic:CanShieldMonster()
	return true
end

-- 拉取移动对象信息间隔
function ExpFbLogic:GetMoveObjAllInfoFrequency()
	return 3
end

function ExpFbLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.FuBenExpInfoView)
	MainUICtrl.Instance:SetViewState(true)

	if ViewManager.Instance:IsOpen(ViewName.TipsExpInSprieFuBenView) then
		ViewManager.Instance:Close(ViewName.TipsExpInSprieFuBenView)
	end

	if ViewManager.Instance:IsOpen(ViewName.TipsExpFuBenView) then
		ViewManager.Instance:Close(ViewName.TipsExpFuBenView)
	end

	GlobalTimerQuest:AddDelayTimer(function()
		local role_level = PlayerData.Instance:GetRoleVo().level
		if role_level >= GameEnum.NOVICE_LEVEL then
			ViewManager.Instance:Open(ViewName.FuBen, TabIndex.fb_exp)
		end
	end, 2)

	GuajiCtrl.Instance:StopGuaji()
	FuBenData.Instance:ClearFBSceneLogicInfo()
end

-- function ExpFbLogic:DelayOut(old_scene_type, new_scene_type)
-- 	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
-- 	MainUICtrl.Instance:SetViewState(true)
-- end

-- 角色是否是敌人
function ExpFbLogic:IsRoleEnemy(target_obj, main_role)
	return false
end

function ExpFbLogic:MainuiOpen()
	MainUICtrl.Instance:SetViewState(false)
end