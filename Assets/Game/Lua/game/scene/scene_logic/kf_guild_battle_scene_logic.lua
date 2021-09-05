KfGuildBattleSceneLogic = KfGuildBattleSceneLogic or BaseClass(CrossServerSceneLogic)

function KfGuildBattleSceneLogic:__init()
	self.open_view = false
end

function KfGuildBattleSceneLogic:__delete()

end

function KfGuildBattleSceneLogic:Enter(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Enter(self, old_scene_type, new_scene_type)
	-- ViewManager.Instance:CloseAllView()
	KuafuGuildBattleCtrl.Instance:OpenScenePanle()
	KuafuGuildBattleCtrl.Instance:OpenRankPanle()
	local main_role = Scene.Instance:GetMainRole()
	local attck_mode = PlayerPrefsUtil.GetInt("attck_mode", -1)
	if attck_mode ~= nil and attck_mode ~= -1 then
		PlayerPrefsUtil.SetInt("attck_mode", attck_mode)
	else
		PlayerPrefsUtil.SetInt("attck_mode", tonumber(main_role.vo.attack_mode))
	end
	if main_role.vo.attack_mode ~= GameEnum.ATTACK_MODE_GUILD then
		MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_GUILD)
	end
	MainUICtrl.Instance:SetViewState(false)

	local scene_id = KuafuGuildBattleData.Instance:GetSceneIdByIndex()
	if Scene.Instance:GetSceneId() == scene_id then
		if KuafuGuildBattleCtrl.Instance:GetIsBaiYe() then
			KuafuGuildBattleCtrl.Instance:FlushCgObjList()
		end
	end
end

function KfGuildBattleSceneLogic:Update(now_time, elapse_time)
	BaseFbLogic.Update(self, now_time, elapse_time)
	
end

function KfGuildBattleSceneLogic:Out(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Out(self, old_scene_type, new_scene_type)
	Scene.Instance:ClearCgObj()
	-- 不是在同样场景里就清空数据
	if old_scene_type ~= new_scene_type then
		KuafuGuildBattleData.Instance:ClearCgRoleListData()
	end

	KuafuGuildBattleCtrl.Instance:CloseScenePanle()
	KuafuGuildBattleCtrl.Instance:CloseRankPanle()
	MainUICtrl.Instance:SetViewState(true)
	GlobalEventSystem:Fire(ObjectEventType.STOP_GATHER, Scene.Instance:GetMainRole():GetObjId())
	BossCtrl.Instance:CancelDpsFlag()
	GuajiType.IsManualState = false
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
end


-- 怪物是否是敌人
function KfGuildBattleSceneLogic:IsMonsterEnemy(target_obj, main_role)
	if target_obj and target_obj:GetVo() then
		local monster_id = target_obj:GetVo().monster_id or 0
		local my_guild_name = main_role:GetVo().guild_name or " "
		local flag_list = KuafuGuildBattleData.Instance:GetRankInfo().flag_list or {}
		for k,v in pairs(flag_list) do
			if monster_id == v.monster_id and my_guild_name == v.guild_name then
				return false
			end
		end
	end
	return true
end

function KfGuildBattleSceneLogic:IsRoleEnemy(target_obj, main_role)
	if main_role:GetVo().guild_id == target_obj:GetVo().guild_id then			-- 同一边
		return false, Language.Fight.Side
	end
	return true
end