require("game/scene/sceneobj/role")
BaseCg = BaseCg or BaseClass()

local UILayer = GameObject.Find("GameRoot/UILayer")

function BaseCg:__init(bundle_name, asset_name)
	self.bundle_name = bundle_name
	self.asset_name = asset_name
	self.end_callback = nil
	self.start_callback = nil
	self.cg_ctrl = nil
	self.cg_obj = nil
	self.cg_layer = GameObject.Find("GameRoot/SceneObjLayer").transform
	self.timer_quest = nil
	self.is_deleted = false
	self.is_main_role_join = false
	self.is_sheild_all_monster_infb = false
	self.is_sheild_all_npc_infb = false
	self.is_sheild_all_impguard_infb = false

	self.old_position = 0
	self.old_rotation = nil
	self.old_scale = nil

	self.old_lover_position = 0
	self.old_lover_rotation = nil
	self.old_lover_scale = nil

	self.old_shield_others = false
	self.old_shield_monster = false
	self.old_mainui_layer = nil
	self.old_main_role_visible = false

	self.is_disable_main_camera_on_playing = true
	
	-- 是否是跳跃cg
	self.is_jump_cg = false

	-- 设置场景放CG不隐藏对象
	self.is_scene_not_hide_cg = {
		[SceneType.Field1v1] = 1,
		[SceneType.KF_Arena] = 1,
		[SceneType.HunYanFb] = 1,
		[SceneType.Kf_OneVOne] = 1,
	}

	-- 隐藏主角的CG场景名字
	self.is_main_role_hide_cg = {
		["nanjiantiaoyue1"] = 1,
		["nanjiantiaoyue2"] = 1,
		["nanjiantiaoyue3"] = 1,
		["nanjiantiaoyue4"] = 1,
		["nanjiantiaoyue5"] = 1,
		["nanjiantiaoyue6"] = 1,
		["nanqintiaoyue1"] = 1,
		["nanqintiaoyue2"] = 1,
		["nanqintiaoyue3"] = 1,
		["nanqintiaoyue4"] = 1,
		["nanqintiaoyue5"] = 1,
		["nanqintiaoyue6"] = 1,
		["nvpaotiaoyue1"] = 1,
		["nvpaotiaoyue2"] = 1,
		["nvpaotiaoyue3"] = 1,
		["nvpaotiaoyue4"] = 1,
		["nvpaotiaoyue5"] = 1,
		["nvpaotiaoyue6"] = 1,
		["nvshuangjiantiaoyue1"] = 1,
		["nvshuangjiantiaoyue2"] = 1,
		["nvshuangjiantiaoyue3"] = 1,
		["nvshuangjiantiaoyue4"] = 1,
		["nvshuangjiantiaoyue5"] = 1,
		["nvshuangjiantiaoyue6"] = 1,
		["W3_ZC_XianMengZhengBa_cg01"] = 1,
		["W3_HD_Liujie_zhuchangjing_cg01"] = 1,
		["W3_HD_LiuJie_fenchangjing_cg01"] = 1,
	}

	-- 隐藏怪物的CG场景名字
	self.is_monster_hide_cg = {
		["Xzptfb01_Cg1"] = 1,
		["w3_fb_zuoqi_cg01"] = 1,
		["w3_hd_dafuhao_cg01"] = 1,
		["w3_hd_dafuhao_cg02"] = 1,
		["w3_fb_feijian_cg01"] = 1,
		["w3_fb_feichuan_cg01"] = 1,
		["w3_fb_feichuan_cg02"] = 1,
		["w3_fb_feijian_cg02"] = 1,
		["w3_fb_guanghuan_cg01"] = 1,
		["w3_fb_jingyan_cg01"] = 1,
		["w3_fb_shengong_cg01"] = 1,
		["w3_fb_shenyi_cg01"] = 1,
		["w3_fb_shenyi_cg02"] = 1,
		["w3_fb_xingkong_cg01"] = 1,
		["w3_fb_xingkong_cg02"] = 1,
		["w3_fb_yuyi_cg01"] = 1,
		["w3_fb_zuoqi_cg02"] = 1,
	}

	-- 隐藏NPC的CG场景名字
	self.is_npc_hide_cg = {
		["GZ_Xsc01_Cg9"] = 1,
		["Zz_nanjian"] = 1,
		["Zz_nanqin"] = 1,
		["Zz_nvpao"] = 1,
		["Zz_nvshuangjian"] = 1,
	}

	-- 隐藏小鬼的CG场景名字
	-- self.is_impguard_hide_cg = {
	-- 	["Zz_nanjian"] = 1,
	-- 	["Zz_nanqin"] = 1,
	-- 	["Zz_nvpao"] = 1,
	-- 	["Zz_nvshuangjian"] = 1,
	-- }
	self.is_shield_robert = {
		["nanjiantiaoyue3"] = true,
		["nanqintiaoyue3"] = true,
		["nvpaotiaoyue3"] = true,
		["nvshuangjiantiaoyue3"] = true,
	}

	Runner.Instance:AddRunObj(self)
end

function BaseCg:__delete()
	Runner.Instance:RemoveRunObj(self)
	self.end_callback = nil
	self.start_callback = nil
	self.cg_ctrl = nil
	self.is_deleted = true
	self:StopTimerQuest()
	self:DestoryCg()

	CgManager.Instance:DelCacheCg(self.bundle_name, self.asset_name)
	SettingData.Instance:ResetAllAutoShield()
end

function BaseCg:DestoryCg()
	AssetBundleMgr:ReqLowLoad()
	
	if nil ~= self.cg_obj then
		ResMgr:Destroy(self.cg_obj)
		self.cg_obj = nil
		Scene.SendCancelMonsterStaticState()
	end
end

function BaseCg:StopTimerQuest()
	if nil ~= self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function BaseCg:Play(end_callback, start_callback, is_jump_cg)
	AssetBundleMgr:ReqHighLoad()
	-- AudioManager.PlayAndForget("audios/sfxs/npctalk/shared", "mute_voice") 	-- 播放npc对话静音
	-- AudioManager.PlayAndForget("audios/sfxs/npcvoice/shared", "mute_voice") 	-- 播放npc对话静音
	TaskCtrl.Instance:StopTaskDialogAudio()				-- 停止播放任务NPC对话声音

	self.end_callback = end_callback
	self.start_callback = start_callback
	self.is_jump_cg = is_jump_cg or false
	
	local sync_loader = AllocAsyncLoader(self, "cg_play_loader")
	sync_loader:Load(self.bundle_name, self.asset_name, function(obj)
		if self.is_deleted then
			if nil ~= obj then
				ResMgr:Destroy(obj)
			end
			return
		end

		if IsNil(obj) then
			print_error("CgManager Play obj is nil", self.bundle_name, self.asset_name)
			self:OnPlayEnd()

			return
		end

		self.cg_obj = obj
		self.cg_obj.transform:SetParent(self.cg_layer)

		self.cg_ctrl = obj:GetComponent(typeof(CGController))
		if self.cg_ctrl == nil then
			print_error("CgManager Play not exist CGController")
			self:DestoryCg()
			self:OnPlayEnd()

			return
		end

		self:StopTimerQuest()
		self.timer_quest = GlobalTimerQuest:AddRunQuest(function()
			self:CheckPlay()
		end, 0)
	end)
end

function BaseCg:Stop()
	if nil ~= self.cg_ctrl then
		self.cg_ctrl:Stop()
		self:DestoryCg()
		self.cg_ctrl = nil
	end

	MountCtrl.Instance:CheckMountUpOrDownInCg()
	FightMountCtrl.Instance:CheckFightMountUpOrDownInCg()

	-- 摄象机直接同步到角色，不缓动
	if not IsNil(MainCameraFollow) then
		MainCamera:GetComponentInParent(typeof(CameraFollow)):SyncImmediate()
	end

	self:ResumeVisible()
end

function BaseCg:CheckPlay()
	local main_role = Scene.Instance:GetMainRole()

	if nil == main_role
		or nil == main_role:GetDrawObj()
		or nil == main_role:GetRoot()
		or nil == main_role:GetDrawObj():GetPart(SceneObjPart.Main)
		or nil == main_role:GetDrawObj():GetPart(SceneObjPart.Main):GetObj() then
		
		return
	end

	self:StopTimerQuest()
	self.cg_ctrl:SetPlayEndCallback(BindTool.Bind(self.OnPlayEnd, self))
	self:OnPlayStart()
	self.cg_ctrl:Play()
end

function BaseCg:Update(now_time, elapse_time)
	if self.is_sheild_all_monster_infb then
		local monster_list = Scene.Instance:GetMonsterList()
		for _, v in pairs(monster_list) do
			v:GetDrawObj():SetVisible(false)
		end
	end
	if self.is_sheild_all_npc_infb then
		local npc_list = Scene.Instance:GetNpcList()
		for _, v in pairs(npc_list) do
			v:GetDrawObj():SetVisible(false)
			v:CancelSelect(false)
		end
	end
	if self.is_sheild_all_impguard_infb then
		local npc_list = Scene.Instance:GetImpGuardList()
		for _, v in pairs(npc_list) do
			v:GetDrawObj():SetVisible(false)
		end
	end
end

function BaseCg:OnPlayStart()
	local scene_type = Scene.Instance:GetSceneType()
	self:ModifyTrack(scene_type)

	-- 有主角参与的cg将下马参与
	if self.is_main_role_join and not self.is_jump_cg then
		MountCtrl.Instance:CheckMountUpOrDownInCg()
		FightMountCtrl.Instance:CheckFightMountUpOrDownInCg()
	end
	Scene.Instance:OnShieldRolePet(false)

	local main_role = Scene.Instance:GetMainRole()
	if nil == main_role then
		return
	end
	if main_role.vo.appearance_param > 0 then		--变身中强制取消变身形象
		main_role:SetAttr("special_appearance", 0)
	end
	main_role:RemoveModel(SceneObjPart.Mount)

	if self.start_callback then
		self.start_callback(self.cg_obj)
	end

	main_role:StopMove()
	self.old_position = main_role:GetRoot().gameObject.transform.localPosition
	self.old_rotation = main_role:GetRoot().gameObject.transform.localRotation
	self.old_scale = main_role:GetRoot().gameObject.transform.localScale

	-- 不是设置的场景类型就屏蔽对象
	if not self.is_scene_not_hide_cg[scene_type] then
		SettingData.Instance:SystemAutoSetting(10)
	end

	-- self.old_shield_others = SettingData.Instance:GetSettingData(SETTING_TYPE.SHIELD_OTHERS)
	-- SettingData.Instance:SetSettingData(SETTING_TYPE.SHIELD_OTHERS, true, true)

	-- self.old_shield_monster = SettingData.Instance:GetSettingData(SETTING_TYPE.SHIELD_ENEMY)
	-- SettingData.Instance:SetSettingData(SETTING_TYPE.SHIELD_ENEMY, true, true)

	if self.is_disable_main_camera_on_playing then
		if not IsNil(MainCamera) then
			MainCamera.gameObject:SetActive(false)
		end
	end

	-- 屏弊Ui摄象机
	ViewManager.Instance:CloseAllViewExceptViewName(ViewName.ReviveView)
	BaseView.SetAllUICameraEnable(false)

	Scene.Instance:ShieldNpc(COMMON_CONSTS.CG_NVSHEN_NPC_ID)

	--屏蔽所有跑任务机器人
	RobertMgr.Instance:ShieldAllRobert()

	local main_view = MainUICtrl.Instance:GetView()
	if main_view then
		self.mainui_root_node = main_view:GetRootNode()
		if self.mainui_root_node then
			self.old_mainui_layer = self.mainui_root_node.layer
		end
	end

	self:HandleSpecialCgOnPlay()
end

function BaseCg:HandleSpecialCgOnPlay()
	local main_role = Scene.Instance:GetMainRole()
	if nil == main_role then
		return
	end
	self.old_main_role_visible = main_role:GetDrawObj():GetObjVisible()
	-- 隐藏主角
	local asset_name = string.gsub(self.asset_name, ".prefab", "")
	if self.is_main_role_hide_cg[asset_name] then
		-- main_role:GetDrawObj():SetVisible(false)
		-- 骚操作，不屏蔽了改成把人位置下移到地面去以便达到隐藏目的
		main_role:GetDrawObj():GetRoot().transform.position = Vector3(0, -99999, 0)
	end


	-- 隐藏怪物
	if self.is_monster_hide_cg[asset_name] then
		self.is_sheild_all_monster_infb = true
	end

	-- 隐藏NPC
	if self.is_npc_hide_cg[asset_name] then
		self.is_sheild_all_npc_infb = true
		-- Scene.Instance:SetIsCgHideNpc(true)
	else
		-- Scene.Instance:SetIsCgHideNpc(false)
	end
	
	GlobalEventSystem:Fire(SettingEventType.CLOSE_GODDESS, nil, true)
	-- 隐藏小鬼
	-- if self.is_impguard_hide_cg[asset_name] then
	-- 	self.is_sheild_all_impguard_infb = true
	-- end
end

function BaseCg:OnPlayEnd()
	self:DestoryCg()
	self.cg_ctrl = nil

	-- 有主角参与的cg将下马参与
	if self.is_main_role_join then
		MountCtrl.Instance:CheckMountUpOrDownInCg()
		FightMountCtrl.Instance:CheckFightMountUpOrDownInCg()
	end
	Scene.Instance:OnShieldRolePet(true)

	if self.is_disable_main_camera_on_playing then
		if not IsNil(MainCamera) then
			MainCamera.gameObject:SetActive(true)
		end
	end
	
	-- 恢复之前的Ui摄象机
	BaseView.SetAllUICameraEnable(true)

	local main_role = Scene.Instance:GetMainRole()
	if nil == main_role then
		return
	end

	main_role:StopMove()
	main_role:ChangeToCommonState()

	if nil ~= self.old_rotation then
		main_role:GetRoot().gameObject.transform.localPosition = self.old_position
		main_role:GetRoot().gameObject.transform.localRotation = self.old_rotation
		main_role:GetRoot().gameObject.transform.localScale = self.old_scale

		-- 摄象机直接同步到角色，不缓动
		if not IsNil(MainCamera) then
			MainCamera:GetComponentInParent(typeof(CameraFollow)):SyncImmediate()
		end

		-- 恢复之前的其他玩家屏蔽状态
		self:ResumeVisible()
	end
	if nil ~= self.old_lover_rotation then
		local vo = main_role:GetVo()
		local lover_role = Scene.Instance:GetObjByUId(vo.lover_uid)
		if lover_role then
			lover_role:GetRoot().gameObject.transform.localPosition = self.old_lover_position
			lover_role:GetRoot().gameObject.transform.localRotation = self.old_lover_rotation
			lover_role:GetRoot().gameObject.transform.localScale = self.old_lover_scale
		end
	end

	if main_role.vo.task_appearn == CHANGE_MODE_TASK_TYPE.CHANGE_MODE_TASK_TYPE_FLY then
		if main_role.vo.task_appearn_param_1 > 0 then
			main_role.mount_res_id = 7013001
			local task_cfg = TaskData.Instance:GetTaskConfig(main_role.vo.task_appearn_param_1)
			if task_cfg and task_cfg.c_param3 then
				local _, mount_id = TaskData.Instance:ChangeResInfo(task_cfg.c_param3)
				if mount_id and "" ~= mount_id and tonumber(mount_id) > 0 then
					main_role.mount_res_id = mount_id
				end
			end
			main_role:ChangeModel(SceneObjPart.Mount, ResPath.GetMountModel(main_role.mount_res_id))
		end
	end
	TipsCtrl.Instance:CgEndFlshOpenNewSkillView()
	if nil ~= self.end_callback then
		self.end_callback()
	end
end

function BaseCg:ResumeVisible()
	SettingData.Instance:ResetAllAutoShield()
	-- SettingData.Instance:SetSettingData(SETTING_TYPE.SHIELD_OTHERS, self.old_shield_others, true)
	-- SettingData.Instance:SetSettingData(SETTING_TYPE.SHIELD_ENEMY, self.old_shield_monster, true)
	Scene.Instance:UnShieldNpc(COMMON_CONSTS.CG_NVSHEN_NPC_ID)

	-- 恢复mainui层
	if self.mainui_root_node then
		self.mainui_root_node:SetLayerRecursively(self.old_mainui_layer or self.mainui_root_node.layer)
	end


	-- 骚操作，不屏蔽了改成把人位置下移到地面去以便达到隐藏目的
	-- 恢复显示主角
	-- local main_role = Scene.Instance:GetMainRole()
	-- if nil == main_role then
	-- 	return
	-- end
	-- main_role:GetDrawObj():SetVisible(self.old_main_role_visible)
	GlobalEventSystem:Fire(SettingEventType.CLOSE_GODDESS, nil, false)

	-- 恢复显示怪物
	if self.is_sheild_all_monster_infb then
		self.is_sheild_all_monster_infb = false
		local monster_list = Scene.Instance:GetMonsterList()
		for _, v in pairs(monster_list) do
			v:GetDrawObj():SetVisible(true)
		end
	end

	-- 恢复显示NPC
	if self.is_sheild_all_npc_infb then
		self.is_sheild_all_npc_infb = false
		local npc_list = Scene.Instance:GetNpcList()
		for _, v in pairs(npc_list) do
			v:GetDrawObj():SetVisible(true)
		end
	end

	-- 恢复显示小鬼守护
	-- if self.is_sheild_all_impguard_infb then
	-- 	self.is_sheild_all_impguard_infb = false
	-- 	local npc_list = Scene.Instance:GetImpGuardList()
	-- 	for _, v in pairs(npc_list) do
	-- 		v:GetDrawObj():SetVisible(true)
	-- 	end
	-- end
	
	--这个任务是cg拉上去机器人走不了，跳下去时再恢复
	local asset_name = string.gsub(self.asset_name, ".prefab", "")
	if not self.is_shield_robert[asset_name] then
		--恢复所有跑任务机器人
		RobertMgr.Instance:UnShieldAllRobert()
	end
end

function BaseCg:ModifyTrack(scene_type)
	if scene_type == SceneType.HunYanFb then
		self:HunyanTrack()
		return
	end
	if EndPlayCgSceneId[Scene.Instance:GetSceneId()] then
		local obj_list = Scene.Instance:GetCgObjList()
		if obj_list then
			for k,v in pairs(obj_list) do
				self:ModifyTrackList(v, k)
			end
			return
		end
	end
	
	local main_role = Scene.Instance:GetMainRole()
	if nil == main_role then
		return
	end
	
	local vo = main_role:GetVo()
	-- 把主角obj替换到cg里
	local succ1 = self.cg_ctrl:AddActor(main_role:GetDrawObj():GetPart(SceneObjPart.Main):GetObj().gameObject, "MainRoleActTrack")
	local succ2 = self.cg_ctrl:AddActor(main_role:GetRoot().gameObject, "MainRoleTrack")
	self.is_main_role_join = succ1 or succ2
	local act_track_name = string.format("1%d0%d", main_role:GetVo().sex, main_role:GetVo().prof % 10)
	-- 开启主角的动作(默认全部静默中)
	for i = GameEnum.FEMALE, GameEnum.MALE  do
		for j = GameEnum.ROLE_PROF_1, GameEnum.ROLE_PROF_4 do
			local track_name = string.format("1%d0%d", i, j)
			self.cg_ctrl:SetTrackMute(track_name, act_track_name ~= track_name)
		end
	end
	-- 隐藏不是当前职业音轨
	for i=1,4 do
		if i == main_role:GetVo().prof % 10 then
			self.cg_ctrl:SetTrackMute("AudioTrackProf" .. i, false)
		else
			self.cg_ctrl:SetTrackMute("AudioTrackProf" .. i, true)
		end
	end
end

-- 替换多个角色
function BaseCg:ModifyTrackList(obj, index)
	self.is_disable_main_camera_on_playing = false --无奈啊
	local is_mute = 0 == obj:GetVo().role_id
	self.cg_ctrl:SetTrackMute("RoleTrackActive" .. index, is_mute)
	if is_mute then
		return
	end

	-- 把主角obj替换到cg里
	local succ1 = self.cg_ctrl:AddActor(obj:GetDrawObj():GetPart(SceneObjPart.Main):GetObj().gameObject,"RoleActTrack" .. index)
	local succ2 = self.cg_ctrl:AddActor(obj:GetRoot().gameObject, "RoleTrack" .. index or "RoleTrack")
	local act_track_name = string.format("100%d", obj:GetVo().prof % 10) .. "_".. index
	for i = GameEnum.ROLE_PROF_1, GameEnum.ROLE_PROF_4 do
		local track_name = string.format("100%d", i) .. "_" .. index
		self.cg_ctrl:SetTrackMute(track_name, act_track_name ~= track_name)
	end
	
	local info_obj = self.cg_obj.transform:Find("ui/Text" .. index)
	if info_obj then
		local bg_obj = info_obj.transform:Find("Images")
		if bg_obj then
			bg_obj.gameObject:SetActive(true)
		end
	end

	local name_obj = self.cg_obj.transform:Find("ui/Text" .. index .. "/name")
	if name_obj then
		local text_obj = name_obj.gameObject:GetComponent(typeof(UnityEngine.UI.Text))
		text_obj.text = obj:GetVo().role_name
		text_obj.gameObject:SetActive(true)
	end
end

function BaseCg:HunyanTrack()
	local main_role = Scene.Instance:GetMainRole()
	if nil == main_role then
		return
	end
	local vo = main_role:GetVo()
	local lover_role = Scene.Instance:GetObjByUId(vo.lover_uid)

	if not lover_role then return end

	-- 保存情侣的位置
	self.old_lover_position = lover_role:GetRoot().gameObject.transform.localPosition
	self.old_lover_rotation = lover_role:GetRoot().gameObject.transform.localRotation
	self.old_lover_scale = lover_role:GetRoot().gameObject.transform.localScale

	local nan = "HunYanNan"
	local nv = "HunYanNv"
	local main_track
	local love_track
	if vo.sex == 0 then
		main_track = nv
		love_track = nan
	else
		main_track = nan
		love_track = nv
	end

	-- 把主角obj替换到cg里
	local succ1 = self.cg_ctrl:AddActor(main_role:GetDrawObj():GetPart(SceneObjPart.Main):GetObj().gameObject, main_track .."ActTrack")
	local succ2 = self.cg_ctrl:AddActor(main_role:GetRoot().gameObject, main_track .. "Track")
	self.is_main_role_join = succ1 or succ2
	local act_track_name = string.format("1%d0%d", main_role:GetVo().sex, main_role:GetVo().prof % 10)
	-- 开启主角的动作(默认全部静默中,把其他主角动画关闭)
	for i = GameEnum.FEMALE, GameEnum.MALE do
		for j = GameEnum.ROLE_PROF_1, GameEnum.ROLE_PROF_4 do
			local track_name = string.format("1%d0%d", i, j)
			self.cg_ctrl:SetTrackMute(track_name, act_track_name ~= track_name)
		end
	end

	-- 把情侣obj替换到cg里
	local lover_succ1 = self.cg_ctrl:AddActor(lover_role:GetDrawObj():GetPart(SceneObjPart.Main):GetObj().gameObject, love_track .. "ActTrack")
	local lover_succ2 = self.cg_ctrl:AddActor(lover_role:GetRoot().gameObject, love_track .. "Track")
	local act_track_name2 = string.format("1%d0%d", lover_role:GetVo().sex, lover_role:GetVo().prof % 10)
	-- 开启情侣的动作()
	self.cg_ctrl:SetTrackMute(act_track_name2, false)
end