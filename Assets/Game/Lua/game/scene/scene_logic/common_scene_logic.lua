
CommonSceneLogic = CommonSceneLogic or BaseClass(BaseSceneLogic)

function CommonSceneLogic:__init()
	self.mainui_open = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpen, self))
	self.story = nil
end

function CommonSceneLogic:__delete()
	if self.mainui_open then
		GlobalEventSystem:UnBind(self.mainui_open)
		self.mainui_open = nil
	end

	if self.loaded_scene then
		GlobalEventSystem:UnBind(self.loaded_scene)
		self.loaded_scene = nil
	end

	if nil ~= self.story then
		self.story:DeleteMe()
		self.story = nil
	end
end

function CommonSceneLogic:Enter(old_scene_type, new_scene_type)
	BaseSceneLogic.Enter(self, old_scene_type, new_scene_type)
	BossCtrl.Instance:CancelDpsFlag()

	if SceneType.PhaseFb == old_scene_type then
		TaskCtrl.Instance:SetAutoTalkState(true)
	end

	local scene_id = Scene.Instance:GetSceneId()

	self:CheckEnterFieldScene(scene_id)
	self:CheckEnterBossScene(scene_id)
	self:CheckEnterDahuhaoScene(scene_id)
	self:CheckEnterPartyActivityScene(scene_id)
	if YewaiGuajiData.Instance:IsGuajiScene(scene_id) then
		ViewManager.Instance:Open(ViewName.GuajiMapTips)
	end

	self.story = XinShouStorys.New(scene_id)
	if self.story:GetStoryNum() > 0 then
		RobertManager.Instance:Start()
	end
	TipsCtrl.Instance:CloseZhanChangTip()

	if (scene_id >= 9040 and scene_id <= 9047) or (scene_id >= 9020 and scene_id <= 9022) then
		MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_PEACE)
	end

	-- if AncientRelicsData.IsAncientRelics(scene_id) then
	-- 	self.has_open_info_view = true
	-- 	MainUICtrl.Instance:SetViewState(false)
	-- 	ViewManager.Instance:Open(ViewName.AncientRelics)
	-- 	HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_GATHER_INFO_REQ)
	-- end
	
	self:CheckShowEnterSceneTip()
end

function CommonSceneLogic:CheckShowEnterSceneTip()
	if Scene.Instance:GetEnterSceneCount() < 2 then
		return
	end

	local scene_id = Scene.Instance:GetSceneId()
	TipsCtrl.Instance:ShowEneterCommonSceneView(scene_id)
end

function CommonSceneLogic:CheckEnterFieldScene(scene_id)
	if scene_id == 103 then
		local attack_mode = PlayerPrefsUtil.GetInt("attck_mode", -1)
		if attack_mode ~= nil and attack_mode ~= -1 then
			MainUICtrl.Instance:SendSetAttackMode(attack_mode)
			-- PlayerPrefsUtil.DeleteKey("attck_mode")
		end
	elseif scene_id >= 101 and scene_id <= 109 then
		MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_PEACE)
	end
 end

 function CommonSceneLogic:CheckOutFieldScene(scene_id)
	if scene_id == 103 then
		local main_role = Scene.Instance:GetMainRole()
		PlayerPrefsUtil.SetInt("attck_mode", tonumber(main_role.vo.attack_mode))
	end
 end

function CommonSceneLogic:CheckEnterBossScene(scene_id)
	if BossData.Instance:IsWorldBossScene(scene_id)
		or BossData.Instance:IsDabaoBossScene(scene_id)
		or BossData.Instance:IsFamilyBossScene(scene_id)
		or BossData.Instance:IsMikuBossScene(scene_id)
		or BossData.Instance:IsActiveBossScene(scene_id) then
		-- or BossData.Instance:IsSecretBossScene(scene_id) then
		ViewManager.Instance:Close(ViewName.KaifuActivityView)
		self.has_open_info_view = true
		if BossData.Instance:IsWorldBossScene(scene_id) then
			BossCtrl.Instance:OpenBossInfoView()
		elseif BossData.Instance:IsDabaoBossScene(scene_id) then
			ViewManager.Instance:Open(ViewName.DabaoBossInfoView)
		elseif BossData.Instance:IsFamilyBossScene(scene_id) or
			BossData.Instance:IsMikuBossScene(scene_id) then
			-- local cfg = BossData.Instance:GetBossMiniMapCfg(1, 1)
			-- if cfg and cfg.scene_id == scene_id then
			-- 	ViewManager.Instance:Open(ViewName.BossFamilyFightViewTwo)
			-- 	ViewManager.Instance:FlushView(ViewName.BossFamilyFightViewTwo, "boss_type", {boss_type = BossData.Instance:IsFamilyBossScene(scene_id) and 0 or 1})
			-- else
				ViewManager.Instance:Open(ViewName.BossFamilyInfoView)
				ViewManager.Instance:FlushView(ViewName.BossFamilyInfoView, "boss_type", {boss_type = BossData.Instance:IsFamilyBossScene(scene_id) and 0 or 1})
			-- end

		elseif BossData.Instance:IsActiveBossScene(scene_id) then
			ViewManager.Instance:Open(ViewName.ActiveBossInfoView)
		-- elseif BossData.Instance:IsSecretBossScene(scene_id) then
		-- 	ViewManager.Instance:Open(ViewName.SecretBossFightView)
		end
		MainUICtrl.Instance:SetViewState(false)
		ViewManager.Instance:Close(ViewName.Boss)
		self:ChangeAttackMode(scene_id)

		self.is_in_boss_scene = true
	end
end

function CommonSceneLogic:ChangeAttackMode(scene_id)
	local fix_attack_mode = GameEnum.ATTACK_MODE_GUILD
	local main_role = Scene.Instance:GetMainRole()
	if BossData.Instance:IsWorldBossScene(scene_id) then
		if main_role.vo.attack_mode ~= GameEnum.ATTACK_MODE_PEACE then
			PlayerPrefsUtil.SetInt("attck_mode", tonumber(main_role.vo.attack_mode))
			MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_PEACE)
		end
	elseif BossData.Instance:IsDabaoBossScene(scene_id) then
		if main_role.vo.attack_mode ~= GameEnum.ATTACK_MODE_PEACE then
			PlayerPrefsUtil.SetInt("attck_mode", tonumber(main_role.vo.attack_mode))
			MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_PEACE)
		end
	-- elseif BossData.Instance:IsMikuPeaceBossScene(scene_id) then
	-- 		PlayerPrefsUtil.SetInt("attck_mode", tonumber(main_role.vo.attack_mode))
	-- 		MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_PEACE)
	-- 		BossData.Instance:SetMikuHurtShow(true)
	elseif BossData.Instance:IsMikuBossScene(scene_id) then
		if main_role.vo.attack_mode ~= fix_attack_mode then
			PlayerPrefsUtil.SetInt("attck_mode", tonumber(main_role.vo.attack_mode))
			MainUICtrl.Instance:SendSetAttackMode(fix_attack_mode)
		end
	elseif BossData.Instance:IsActiveBossScene(scene_id) then
		if main_role.vo.attack_mode ~= GameEnum.ATTACK_MODE_PEACE then
			PlayerPrefsUtil.SetInt("attck_mode", tonumber(main_role.vo.attack_mode))
			MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_PEACE)
		end
		BossData.Instance:SetActiveHurtShow(true)
	-- elseif BossData.Instance:IsSecretBossScene(scene_id) then
	-- 	if main_role.vo.attack_mode ~=fix_attack_mode then
	-- 		PlayerPrefsUtil.SetInt("attack_mode", tonumber(main_role.vo.attack_mode))
	-- 		MainUICtrl.Instance:SendSetAttackMode(fix_attack_mode)
	-- 	end
	end
end

function CommonSceneLogic:CheckEnterDahuhaoScene(scene_id)
	if not DaFuHaoData.Instance:IsShowDaFuHao() then
		return
	end

	self.dafuhao_view = true
	MainUICtrl.Instance:SetViewState(false)
	ViewManager.Instance:Open(ViewName.DaFuHao)
	MainUICtrl.Instance:FlushView("dafuhao")
end

function CommonSceneLogic:CanGetMoveObj()
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id then
		-- 世界Boss场景
		if BossData.Instance:IsWorldBossScene(scene_id) then
			-- or BossData.Instance:IsDabaoBossScene(scene_id)
			-- or BossData.Instance:IsFamilyBossScene(scene_id)
			-- or BossData.Instance:IsMikuBossScene(scene_id) then
			return true
		end
	end
	return false
end

function CommonSceneLogic:GetGuajiSelectObjDistance()
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id then
		if BossData.Instance:IsDabaoBossScene(scene_id) or
			BossData.Instance:IsFamilyBossScene(scene_id) or
			BossData.Instance:IsMikuBossScene(scene_id) or
			BossData.Instance:IsActiveBossScene(scene_id) then
			-- BossData.Instance:IsSecretBossScene(scene_id) then
			return COMMON_CONSTS.SELECT_OBJ_DISTANCE_IN_BOSS_SCENE
		end
	end

	return COMMON_CONSTS.SELECT_OBJ_DISTANCE
end

-- 拉取移动对象信息间隔
function CommonSceneLogic:GetMoveObjAllInfoFrequency()
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id then
		-- 世界Boss场景
		if BossData.Instance:IsWorldBossScene(scene_id)
			or BossData.Instance:IsDabaoBossScene(scene_id)
			or BossData.Instance:IsFamilyBossScene(scene_id)
			or BossData.Instance:IsMikuBossScene(scene_id)
			or BossData.Instance:IsActiveBossScene(scene_id) then
			-- or BossData.Instance:IsSecretBossScene(scene_id) then
			return 5
		end
	end
	return 100000
end

--退出
function CommonSceneLogic:Out(old_scene_type, new_scene_type)
	BaseSceneLogic.Out(self, old_scene_type, new_scene_type)
	local scene_id = Scene.Instance:GetSceneId()
	if self.has_open_info_view then
		self.has_open_info_view = false
		if BossData.Instance:IsWorldBossScene(scene_id) then
			BossCtrl.Instance:CloseBossInfoView()
			BossData.Instance:ClearCache()
			MainUICtrl.Instance:RecoverMode()
		elseif BossData.Instance:IsDabaoBossScene(scene_id) then
			ViewManager.Instance:Close(ViewName.DabaoBossInfoView)
			BossData.Instance:ClearCache()
			MainUICtrl.Instance:RecoverMode()
		elseif BossData.Instance:IsFamilyBossScene(scene_id) or
			BossData.Instance:IsMikuBossScene(scene_id) then
			ViewManager.Instance:Close(ViewName.BossFamilyInfoView)
			-- ViewManager.Instance:Close(ViewName.BossFamilyFightViewTwo)
			BossData.Instance:ClearCache()
			MainUICtrl.Instance:RecoverMode()
		elseif BossData.Instance:IsActiveBossScene(scene_id) then
			ViewManager.Instance:Close(ViewName.ActiveBossInfoView)
			BossData.Instance:ClearCache()
		-- elseif BossData.Instance:IsSecretBossScene(scene_id) then
		-- 	ViewManager.Instance:Close(ViewName.SecretBossFightView)
		-- elseif AncientRelicsData.IsAncientRelics(scene_id) then
		-- 	ViewManager.Instance:Close(ViewName.AncientRelics)
		-- elseif RelicData.Instance:IsRelicScene(scene_id) then
		-- 	RelicCtrl.Instance:CloseInfoView()
		end
		MainUICtrl.Instance:SetViewState(true)
	end
	if self.dafuhao_view or ViewManager.Instance:IsOpen(ViewName.DaFuHao) then
		self.dafuhao_view = false
		MainUICtrl.Instance:SetViewState(true)
		MainUICtrl.Instance:FlushView("dafuhao")
		ViewManager.Instance:Close(ViewName.DaFuHao)
	end
	self:CheckOutFieldScene(scene_id)

	RobertManager.Instance:Stop()

	TipsCtrl.Instance:CloseEneterCommonSceneView()
	BossCtrl.Instance:CancelDpsFlag()
end

function CommonSceneLogic:MainuiOpen()
	if self.has_open_info_view then
		MainUICtrl.Instance:SetViewState(false)
	end
end

function CommonSceneLogic:IsMonsterEnemy(target_obj, main_role)
	local vo = target_obj:GetVo()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if vo and ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GUILD_BONFIRE) then
		if main_role_vo.guild_id > 0 and vo.special_param == main_role_vo.guild_id then
			return false
		elseif main_role_vo.guild_id <= 0 and vo.special_param ~= 0 then
			return false
		end
	end
	return true
end

function CommonSceneLogic:AlwaysShowMonsterName()
	local guild_yunbiao_cfg = GuildData.Instance:GetGuildYunBiaoConfig()
	local scene_id = guild_yunbiao_cfg.biaoche_scene_id 
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GUILD_BONFIRE) and Scene.Instance:GetSceneId() == scene_id then
		return true
	else
		return false
	end
end

function CommonSceneLogic:CheckEnterPartyActivityScene(scene_id)
	local enter_scene_cfg = FestivalSinglePartyData.Instance:GetEnterSceneCfg()
	if enter_scene_cfg == nil then
		return
	end
	for k,v in pairs(enter_scene_cfg) do
		local npc_vo_list = {}
		if scene_id == v.scene_id then
			npc_vo_list = FestivalSinglePartyData.Instance:GetSceneNpcBySceneID(scene_id)
			Scene.Instance:CreateEnterPartyNpc(npc_vo_list)
		end
	end
end

-- 是否可以移动
function CommonSceneLogic:CanMove()
	return Scene.Instance:GetMainRoleIsMove()
	-- return true
end