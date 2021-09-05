KfOneVOneSceneLogic = KfOneVOneSceneLogic or BaseClass(CrossServerSceneLogic)

function KfOneVOneSceneLogic:__init()
	self.fight_start_timestmap = -1
end

function KfOneVOneSceneLogic:__delete()

end

function KfOneVOneSceneLogic:Update(now_time, elapse_time)
	CrossServerSceneLogic.Update(self, now_time, elapse_time)
	local main_role = Scene.Instance:GetMainRole()
	if not main_role:IsFightState() and main_role:IsMove() then
		MoveCache.is_move_scan = true
	end
end

-- 进入场景
function KfOneVOneSceneLogic:Enter(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Enter(self, old_scene_type, new_scene_type)
	local main_role = Scene.Instance:GetMainRole()
	local attck_mode = PlayerPrefsUtil.GetInt("attck_mode", -1)
	if attck_mode ~= nil and attck_mode ~= -1 then
		PlayerPrefsUtil.SetInt("attck_mode", attck_mode)
	else
		PlayerPrefsUtil.SetInt("attck_mode", tonumber(main_role.vo.attack_mode))
	end
	if main_role.vo.attack_mode ~= GameEnum.ATTACK_MODE_ALL then
		MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_ALL)
	end
	local side = KuaFu1v1Data.Instance:GetMatchResult().side
	local oppo_plat_type = KuaFu1v1Data.Instance:GetMatchResult().oppo_plat_type
	local obj_list = Scene.Instance:GetObjList()
	local enemy_obj = nil
	if obj_list then
		for k,v in pairs(obj_list) do
			if v:IsRole() and not v:IsMainRole() then
				enemy_obj = v
			else
				enemy_obj = nil
			end
		end
	end
	
	if oppo_plat_type == 0 and enemy_obj == nil then
		main_role:RotateTo(180)
	else
		if enemy_obj ~= nil then  
			if side == 1 then
				main_role:RotateTo(180)
				enemy_obj:RotateTo(60)
			else
				main_role:RotateTo(60)
				enemy_obj:RotateTo(180)
			end
		else
			if side == 1 then
				main_role:RotateTo(180)
			else
				main_role:RotateTo(60)
			end 
		end
	end
	GuajiType.IsManualState = false
	GuajiCtrl.Instance:StopGuaji()
	local fight_start = KuaFu1v1Data.Instance:GetCross1v1FightStart()
	self.fight_start_timestmap = fight_start.fight_start_timestmap

	MainUICtrl.Instance:SetViewState(false)
	GlobalEventSystem:Fire(MainUIEventType.CHNAGE_FIGHT_STATE_BTN, true)
	MainUICtrl.Instance:ChangeFightStateEnable(false)

	local main_view = MainUICtrl.Instance:GetView()
	if main_view then
		main_view:SetPlayerInfoState(false)
		main_view:HideMap(true)
	end
	GlobalTimerQuest:AddDelayTimer(function()
		GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)
		end, 0.1)
	ViewManager.Instance:CloseAll()

	MainCameraFollow.AllowRotation = false
	MainCameraFollow.AutoRotation = false
	MainCameraFollow.Distance = 10
	MainCameraFollow.ZoomSmoothing = 10
	MainCameraFollow:ChangeAngle(Vector2(26, 135))

	local cg_name = side == 1 and "CG_JingJiChang" or "CG_JingJiChang_0"
	CgManager.Instance:Play(BaseCg.New("cg/cg_jingjichang_prefab", cg_name), 
		function()
			KuaFu1v1Ctrl.Instance:CreartKuaFu1v1ViewFight()
			MainCameraFollow.AllowRotation = true
		end)
end

function KfOneVOneSceneLogic:Out(old_scene_type, new_scene_type)
	KuaFu1v1Ctrl.Instance:OpenView()
	MainUICtrl.Instance:ChangeFightStateEnable(true)
	GlobalEventSystem:Fire(MainUIEventType.CHNAGE_FIGHT_STATE_BTN, false)
	CrossServerSceneLogic.Out(self, old_scene_type, new_scene_type)
	self.fight_start_timestmap = 0

	local main_view = MainUICtrl.Instance:GetView()
	if main_view then
		main_view:SetAllViewState(true)
		main_view:SetPlayerInfoState(true)
		main_view:HideMap(false)
	end
	
	KuaFu1v1Ctrl.Instance:CloseFightView()
	KuaFu1v1Ctrl.Instance:CloseHpTouXiang()
	GlobalTimerQuest:AddDelayTimer(function()
	 	local state = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.KF_ONEVONE)
		if state then
			ViewManager.Instance:Open(ViewName.KuaFu1v1)
		end
	end, 1)
	GuajiType.IsManualState = false
	GuajiCtrl.Instance:StopGuaji()
end

-- 是否可以移动
function KfOneVOneSceneLogic:CanMove()
	return KuaFu1v1Ctrl.Instance:GetCanMove()
end

-- 角色是否是敌人
function KfOneVOneSceneLogic:IsRoleEnemy(target_obj, main_role)
	return KuaFu1v1Ctrl.Instance:GetCanMove()
end

-- 是否是挂机打怪的敌人
function KfOneVOneSceneLogic:IsGuiJiMonsterEnemy(target_obj)
	if nil == target_obj or target_obj:GetType() ~= SceneObjType.Role
		or target_obj:IsRealDead() or not Scene.Instance:IsEnemy(target_obj) then
		return false
	end
	return true
end

-- 获取挂机打怪的敌人
function KfOneVOneSceneLogic:GetGuiJiMonsterEnemy()
	local server_time = TimeCtrl.Instance:GetServerTime()
	if self.fight_start_timestmap >= server_time then
		return false
	end
	local x, y = Scene.Instance:GetMainRole():GetLogicPos()
	local distance_limit = COMMON_CONSTS.SELECT_OBJ_DISTANCE * COMMON_CONSTS.SELECT_OBJ_DISTANCE
	return Scene.Instance:SelectObjHelper(Scene.Instance:GetRoleList(), x, y, distance_limit, SelectType.Enemy)
end
