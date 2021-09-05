ArenaSceneLogic = ArenaSceneLogic or BaseClass(CommonActivityLogic)

function ArenaSceneLogic:__init()

end

function ArenaSceneLogic:__delete()
	-- GlobalTimerQuest:CancelQuest(self.open_delay)
end

-- 进入场景
function ArenaSceneLogic:Enter(old_scene_type, new_scene_type)
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

	ArenaCtrl.Instance:CloseFightView()
	ArenaCtrl.Instance:InitFight()

	MainCameraFollow.AllowRotation = false
	MainCameraFollow.AutoRotation = false
	MainCameraFollow.Distance = 10
	MainCameraFollow.ZoomSmoothing = 10
	MainCameraFollow:ChangeAngle(Vector2(26, 135))

	CgManager.Instance:Play(BaseCg.New("cg/cg_jingjichang_prefab", "CG_JingJiChang"), 
		function()
			ArenaCtrl.Instance:SendChallengeFieldReadyStartFightReq()
			MainCameraFollow.AllowRotation = true
		end)
end

function ArenaSceneLogic:Out(old_scene_type, new_scene_type)
	CommonActivityLogic.Out(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)

	ArenaCtrl.Instance:CloseFightView()
	ViewManager.Instance:Open(ViewName.ArenaActivityView, TabIndex.arena_view)
end

function ArenaSceneLogic:DelayOut(old_scene_type, new_scene_type)
	BaseSceneLogic.DelayOut(self, old_scene_type, new_scene_type)
	local main_view = MainUICtrl.Instance:GetView()
	if main_view then
		main_view:SetAllViewState(true)
		main_view:SetPlayerInfoState(true)
		main_view:HideMap(false)
	end
end

-- 是否可以移动
function ArenaSceneLogic:CanMove()
	return ArenaCtrl.Instance:GetCanMove()
end

-- 角色是否是敌人
function ArenaSceneLogic:IsEnemy(target_obj, main_role)
	return ArenaCtrl.Instance:GetCanMove()
end
