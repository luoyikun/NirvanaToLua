KFArenaSceneLogic = KFArenaSceneLogic or BaseClass(CommonActivityLogic)

function KFArenaSceneLogic:__init()

end

function KFArenaSceneLogic:__delete()
	-- GlobalTimerQuest:CancelQuest(self.open_delay)
end

-- 进入场景
function KFArenaSceneLogic:Enter(old_scene_type, new_scene_type)
	CommonActivityLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:CloseAll()

	local main_view = MainUICtrl.Instance:GetView()
	if main_view then
		main_view:SetPlayerInfoState(false)
		main_view:HideMap(true)
		MainUICtrl.Instance:SetViewState(false)
	end
	GlobalTimerQuest:AddDelayTimer(function()
		GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)
		end, 0.1)

	KFArenaCtrl.Instance:CloseFightView()
	KFArenaCtrl.Instance:InitFight()

	MainCameraFollow.AllowRotation = false
	MainCameraFollow.AutoRotation = false
	MainCameraFollow.Distance = 10
	MainCameraFollow.ZoomSmoothing = 10
	MainCameraFollow:ChangeAngle(Vector2(26, 135))

	CgManager.Instance:Play(BaseCg.New("cg/cg_jingjichang_prefab", "CG_JingJiChang"), 
		function()
			KFArenaCtrl.Instance:SendKfArenaReq(CROSS_CHALLENGEFIELD_OPERA_REQ.CROSS_CHALLENGEFIELD_OPERA_REQ_READY)
			MainCameraFollow.AllowRotation = true
		end)
end

function KFArenaSceneLogic:Out(old_scene_type, new_scene_type)
	CommonActivityLogic.Out(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	if ViewManager.Instance:IsOpen(ViewName.CommonTips) then
		ViewManager.Instance:Close(ViewName.CommonTips)
	end

	KFArenaCtrl.Instance:CloseFightView()
	KFArenaCtrl.Instance:SendKfArenaReq(CROSS_CHALLENGEFIELD_OPERA_REQ.CROSS_CHALLENGEFIELD_OPERA_REQ_SELFT_INFO)
	KFArenaCtrl.Instance:SendKfArenaReq(CROSS_CHALLENGEFIELD_OPERA_REQ.CROSS_CHALLENGEFIELD_OPERA_REQ_OPPONENT_INFO, 0)
	ViewManager.Instance:Open(ViewName.KFArenaActivityView, TabIndex.kf_arena_view)
end

function KFArenaSceneLogic:DelayOut(old_scene_type, new_scene_type)
	BaseSceneLogic.DelayOut(self, old_scene_type, new_scene_type)
	local main_view = MainUICtrl.Instance:GetView()
	if main_view then
		main_view:SetAllViewState(true)
		main_view:SetPlayerInfoState(true)
		main_view:HideMap(false)
	end
end

-- 是否可以移动
function KFArenaSceneLogic:CanMove()
	return KFArenaCtrl.Instance:GetCanMove()
end

-- 角色是否是敌人
function KFArenaSceneLogic:IsEnemy(target_obj, main_role)
	return KFArenaCtrl.Instance:GetCanMove()
end
