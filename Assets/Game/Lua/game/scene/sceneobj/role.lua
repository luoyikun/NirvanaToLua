DefaultLayer = UnityEngine.LayerMask.NameToLayer("Default")

Role = Role or BaseClass(Character)
local SceneObjLayer = GameObject.Find("GameRoot/SceneObjLayer").transform
function Role:__init(vo)
	self.obj_type = SceneObjType.Role
	self.draw_obj:SetObjType(self.obj_type)

	self.role_res_id = 0
	self.special_res_id = 0
	self.weapon_res_id = 0
	self.weapon2_res_id = 0
	self.wing_res_id = 0
	self.waist_res_id = 0
	self.toushi_res_id = 0
	self.qilinbi_res_id = 0
	self.mask_res_id = 0
	self.foot_res_id = 0
	self.mount_res_id = 0
	self.fight_mount_res_id = 0
	self.halo_res_id = 0
	self.fabao_res_id = 0
	self.cloak_res_id = 0
	self.tail_res_id = 0
	self.flypet_res_id = 0
	self.shouhuan_res_id = 0
	self.fazhen_res_id = ""
	self.is_gather_state = false
	self.attack_index = 1
	self.role_is_visible = true
	self.goddess_obj = nil
	self.is_sit_mount = 0
	self.is_sit_mount2 = 0
	self.is_load_effect = false
	self.is_load_effect2 = false
	self.goddess_visible = true
	self.spirit_visible = true
	self.lingchong_visible = true
	self.flypet_visible = true
	self.attack_index_shadow = 0
	self.is_show_special_image = false
	self.is_parnter = false
	self.is_xunyou = false
	self.is_delivering = false
	self.on_multi_mount = 0
	self.update_marry_time = 0
	self.multi_mount_owner_role = nil
	self.marry_role = nil
	self.follow_and_shadow_shield = false
	self.is_yinshen = 0

	self.role_last_logic_pos_x = 0
	self.role_last_logic_pos_y = 0
	self.next_create_footprint_time = -1 			-- 下一次生成足迹的时间
	self.hug_res_id = 0
	self.shuibo_effect_time = 0
	self.shuibo_effect_is_show = false
	self.is_chongci = false						-- 是否冲刺状态
	self.is_in_multi_mount = false

	self:UpdateAppearance()
	self:UpdateMount()
	self:UpdateFightMount()

	self.shield_spirit_helo = true --暂时屏蔽光环
	self.is_enter_fight = false

	self.is_war_scene_state = false					-- 是否是战场变身状态

	self.weiyan_list = {}

	self.is_qinggong = false
	self.is_landed = true
	self.qinggong_index = 0
	self.is_force_landing = false
	self.has_play_qinggong_land = false
	self.quality_node = QualityConfig.ListenQualityChanged(function()
		self:OnQualityChanged()
	end)
	self.foot_count = 0

	self.destroy_qinggong_mount = true
end

local QINGGONG_MOUNT_DIFF_Y = {-3.20, 0.92, 0.61, -0.19}

Role.FootPrintCount = 0
function Role:CreateFootPrint()
	if not self:IsRoleVisible() or self:IsWaterWay() or self:IsWaterRipple() then return end
	if self.is_jump or self.draw_obj == nil or self.foot_res_id < 1 then return end

	if not self:IsMainRole() and Role.FootPrintCount > 8 then
		return
	end
	local is_hide_foot = SettingData.Instance:GetAdvanceTypeHideFlag(ADVANCE_HIDE_TYPE.FOOT)
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if is_hide_foot == 1 or fb_scene_cfg.pb_foot == 1 then return end
	if self.is_force_landing or (self.is_qinggong and not self.is_landed) then
		return
	end

	local root_transform = self.draw_obj:GetRoot().transform
	if not IsNil(root_transform) then
		Role.FootPrintCount = Role.FootPrintCount + 1
		local pos = self.draw_obj:GetRoot().transform.position
		local position = Vector3(pos.x, pos.y + 0.25, pos.z)
		local bundle, asset = ResPath.GetFootModel(self.foot_res_id)		--足迹
		-- EffectManager.Instance:PlayControlEffect(bundle, asset, position, nil)

		self.foot_count = self.foot_count + 1
		local async_loader = AllocAsyncLoader(self, "hurt_effect" .. self.foot_count % 8)
		async_loader:SetIsUseObjPool(true)
		async_loader:SetObjAliveTime(5) --防止永久存在
		async_loader:Load(bundle, asset, function(obj)
			if IsNil(obj) then
				print_warning("obj not exist", bundle, asset)
				return
			end

			obj.transform.position = position
			obj:SetLayerRecursively(DefaultLayer)

			local control = obj:GetOrAddComponent(typeof(EffectControl))
			if control == nil then
				async_loader:Destroy()
				print_warning("PlayControlEffect not exist EffectControl")
				return
			end

			control:Reset()
			control.enabled = true
			control:Play()
			control:WaitFinsh(function()
				async_loader:Destroy()
			end)
		end)

		GlobalTimerQuest:AddDelayTimer(function ()
			Role.FootPrintCount = Role.FootPrintCount - 1
		end, 1)
	end
end

function Role:OnEnterScene()
	Character.OnEnterScene(self)
	-- SceneData.Instance:AddSceneRoleShield(self)
	
	self:GetFollowUi()
	self:CreateTitle()
	self:ChangeHuSong()
	-- self:ChangeGuildBattle()
	self:ChangeSpirit()
	self:ChangeLingChong()
	-- self:ChangeImpGuard()
	self:ChangeGoddess()
	self:UpdateBoat()
	-- self:UpdateRoleFaZhen()
	-- self:ChangeFaZhen()
	self:ChangeJingHuaHuSong()
	self:OthersChangeJingHuaHuSong()
	self:InitWuDiGather()
	self:InitXiuLuoWuDiGather()
	self:ReloadSpecialImage()
	if self.follow_ui and not self.is_show_special_image then
		self.follow_ui:SetSpecialImage(false)
	end
	
	self:InitWaterState()
	self:OnQualityChanged()
end

function Role:InitWaterState()
	if self.draw_obj then
		self.draw_obj:SetWaterHeight(COMMON_CONSTS.WATER_HEIGHT)
		local scene_logic = Scene.Instance:GetSceneLogic()
		if scene_logic then
			local flag = scene_logic:IsCanCheckWaterArea() and true or false
			self.draw_obj:SetCheckWater(flag)
			if flag then
				self.draw_obj:SetEnterWaterCallBack(BindTool.Bind(self.EnterWater, self))
			end
		end
	end
end

function Role:OnQualityChanged()

end

-- function Role:HideFollowUi()
-- end

function Role:ChangeFollowUiName(name)
	if name then
		self.vo.name = name
	end
	self:ReloadUIName()
end

function Role:__delete()
	local setting_data = SettingData.Instance
	if self.setting_shield_others ~= nil then
		setting_data:UnNotifySettingChangeCallBack(
			SETTING_TYPE.SHIELD_OTHERS,
			self.setting_shield_others)
		self.setting_shield_others = nil
	end

	if self.setting_shield_self_effect ~= nil then
		setting_data:UnNotifySettingChangeCallBack(
			SETTING_TYPE.SELF_SKILL_EFFECT,
			self.setting_shield_self_effect)
		self.setting_shield_self_effect = nil
	end

	if self.setting_shield_other_effect ~= nil then
		setting_data:UnNotifySettingChangeCallBack(
			SETTING_TYPE.SKILL_EFFECT,
			self.setting_shield_other_effect)
		self.setting_shield_other_effect = nil
	end

	if self.setting_close_shake_camera ~= nil then
		setting_data:UnNotifySettingChangeCallBack(
			SETTING_TYPE.CLOSE_SHOCK_SCREEN,
			self.setting_close_shake_camera)
		self.setting_close_shake_camera = nil
	end

	self:DeleteAllFollowObjs()

	if self.load_mount_quest then
		GlobalTimerQuest:CancelQuest(self.load_mount_quest)
		self.load_mount_quest = nil
	end
	if self.load_fightmount_quest then
		GlobalTimerQuest:CancelQuest(self.load_fightmount_quest)
		self.load_fightmount_quest = nil
	end

	if self.delay_stop_baiye then
		GlobalTimerQuest:CancelQuest(self.delay_stop_baiye)
		self.delay_stop_baiye = nil
	end

	if nil ~= self.baoju_effect then
		self.baoju_effect:Destroy()
		self.baoju_effect:DeleteMe()
		self.baoju_effect = nil
	end

	if self.spirit_halo then
		self.spirit_halo:Destroy()
		self.spirit_halo:DeleteMe()
		self.spirit_halo = nil
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.weapon_effect then
		ResPoolMgr:Release(self.weapon_effect)
		self.weapon_effect = nil
	end
	if self.weapon2_effect then
		ResPoolMgr:Release(self.weapon2_effect)
		self.weapon2_effect = nil
	end
	self.is_load_effect = nil
	self.is_load_effect2 = nil
	self.weapon2_effect_name = nil
	self.weapon_effect_name = nil

	GlobalTimerQuest:CancelQuest(self.do_mount_up_delay)
	self:DestroyXiaMaEffect()
	self:RemoveXiamaDelay()

	if self.quality_node ~= nil then
		QualityConfig.UnlistenQualtiy(self.quality_node)
		self.quality_node = nil
	end
	if self.dance_delay_time then
		GlobalTimerQuest:CancelQuest(self.dance_delay_time)
		self.dance_delay_time = nil
	end
	if self.shuibo_effect and not IsNil(self.shuibo_effect) then
		ResPoolMgr:Release(self.shuibo_effect)
		self.shuibo_effect = nil
	end
	self.multi_mount_owner_role = nil
	self.marry_role = nil
	self:ReleaseQingGongMount()
	self.actor_qinggong = nil
	self.follow_and_shadow_shield = false
end

function Role:DeleteAllFollowObjs()
	if self.truck_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.TruckObj, self.truck_obj:GetObjKey())
		self.truck_obj = nil
	end

	if self.imp_guard_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.ImpGuardObj, self.imp_guard_obj:GetObjKey())
		self.imp_guard_obj = nil
	end

	if self.spirit_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.SpriteObj, self.spirit_obj:GetObjKey())
		self.spirit_obj = nil
	end

	if self.goddess_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.GoddessObj, self.goddess_obj:GetObjKey())
		self.goddess_obj = nil
	end

	if self.pet_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.PetObj, self.pet_obj:GetObjKey())
		self.pet_obj = nil
	end

	if self.baby_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.Baby, self.baby_obj:GetObjKey())
		self.baby_obj = nil
	end

	if self.fight_mount_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.FightMount, self.fight_mount_obj:GetObjKey())
		self.fight_mount_obj = nil
	end

	if self.lingchong_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.LingChongObj, self.lingchong_obj:GetObjKey())
		self.lingchong_obj = nil
	end

	if self.flypet_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.FlyPetObj, self.flypet_obj:GetObjKey())
		self.flypet_obj = nil
	end

	if self.fake_truck_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.FakeTruckObj, self.fake_truck_obj:GetObjKey())
		self.fake_truck_obj = nil
	end
	
end

function Role:IsRole()
	return true
end

function Role:InitInfo()
	Character.InitInfo(self)
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.HotSpring then
		local cur_res_id = 2039001
		if sex == 1 then
			if prof == 1 then
				cur_res_id = 2039001
			elseif prof == 2 then
				cur_res_id = 2040001
			end
		else
			if prof == 3 then
				cur_res_id = 2042001
			elseif prof == 4 then
				cur_res_id = 2041001
			end
		end
		self:SetActorConfigPrefabData(ConfigManager.Instance:GetPrefabDataAutoConfig("Monster", cur_res_id))
	else
		local base_prof = PlayerData.Instance:GetRoleBaseProf(self.vo.prof)
		self:SetActorConfigPrefabData(ConfigManager.Instance:GetAutoPrefabConfig(self.vo.sex, base_prof))
	end

	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	main_part:ListenEvent("QingGongLandExit", BindTool.Bind(self.QingGongLandExit, self))
end

function Role:GetObjKey()
	return self.vo.role_id
end

function Role:InitShow()
	Character.InitShow(self)
	if self:IsMainRole() then
		self.load_priority = 5
	end
	if self.special_res_id ~= 0 then
		self:ChangeSpecialModel()
		return
	end
		-- 变身卡
	if self.special_res_id ~= 0 and SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_WORD_EVENT_YURENCARD == self.vo.special_appearance then
		local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.vo.appearance_param]
		if monster_cfg then
			self.special_res_id = monster_cfg.resid
		end

		self:ChangeModel(SceneObjPart.Main, ResPath.GetMonsterModel(self.special_res_id))
		return
	end

	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	main_part:EnableMountUpTrigger(false)

	if self.role_res_id ~= nil and self.role_res_id ~= 0 then
		self:InitModel(ResPath.GetRoleModel(self.role_res_id))
	end

	if self.weapon_res_id ~= nil and self.weapon_res_id ~= 0 then
		self:ChangeModel(SceneObjPart.Weapon, ResPath.GetWeaponModel(self.weapon_res_id))
	end

	if self.weapon2_res_id ~= nil and self.weapon2_res_id ~= 0 then
		self:ChangeModel(SceneObjPart.Weapon2, ResPath.GetWeaponModel(self.weapon2_res_id))
	end

	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local is_hide_wing = SettingData.Instance:GetAdvanceTypeHideFlag(ADVANCE_HIDE_TYPE.WING)
	if self.wing_res_id ~= nil and self.wing_res_id ~= 0 and fb_scene_cfg.pb_wing ~= 1 and self.vo.multi_mount_res_id <= 0 and is_hide_wing ~= 1 then
		self:ChangeModel(SceneObjPart.Wing, ResPath.GetWingModel(self.wing_res_id))
	end

	local is_hide_cloak = SettingData.Instance:GetAdvanceTypeHideFlag(ADVANCE_HIDE_TYPE.CLOAK)
	if self.cloak_res_id ~= nil and self.cloak_res_id ~= 0 and is_hide_cloak ~= 1 then
		self:ChangeModel(SceneObjPart.Cloak, ResPath.GetPifengModel(self.cloak_res_id))
	end

	if self.fight_mount_res_id ~= nil and self.fight_mount_res_id ~= 0 then
		self:ChangeModel(SceneObjPart.FightMount, ResPath.GetFightMountModel(self.fight_mount_res_id))
	elseif self.mount_res_id ~= nil and self.mount_res_id ~= 0 and not self:IsMultiMountPartner() then
		if self.is_sit_mount == 1 and not self:IsMultiMount() then
			self:ChangeModel(SceneObjPart.FightMount, ResPath.GetMountModel(self.mount_res_id))
		else
			self:ChangeModel(SceneObjPart.Mount, ResPath.GetMountModel(self.mount_res_id))
		end
	end

	-- 人物法阵
	-- self:ChangeFaZhen()
	local is_hide_halo = SettingData.Instance:GetAdvanceTypeHideFlag(ADVANCE_HIDE_TYPE.HALO)
	if self.halo_res_id ~= nil and self.halo_res_id ~= 0 and fb_scene_cfg.pb_guanghuan ~= 1 and is_hide_halo ~= 1 then
		self:ChangeModel(SceneObjPart.Halo, ResPath.GetHaloModel(self.halo_res_id))
	end

	local is_hide_fabao = SettingData.Instance:GetAdvanceTypeHideFlag(ADVANCE_HIDE_TYPE.FABAO)
	if self.fabao_res_id ~= nil and self.fabao_res_id ~= 0 and fb_scene_cfg.pb_fabao ~= 1 and is_hide_fabao ~= 1 then
		self:ChangeModel(SceneObjPart.BaoJu, ResPath.GetFaBaoModel(self.fabao_res_id, true))
	end

	if self:CanHug() then
		local part = self.draw_obj:GetPart(SceneObjPart.Main)
		part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Hug)
		self:DoHug()
	end

	self:CheckDanceState()
	self:ChangeYaoShi()
	self:ChangeTouShi()
	self:ChangeQilinBi()
	self:ChangeMask()
	self:ChangeCloak()
	self:ChangeFlyPet()
	self:ChangeTail()
	self:ChangeShouHuan()

	self:UpDateWeiYanResid()
	self:ChangeWeiYan()
end

function Role:InitModel(bundle, asset)
    if ResMgr:IsBundleMode() and not ResMgr:IsVersionCached(bundle) then
		local default_res_id = nil
		local base_prof = PlayerData.Instance:GetRoleBaseProf(self.vo.prof)

		if self.vo.sex == 0 then
			default_res_id = "100" .. base_prof .. "001"
		else
			default_res_id = "110" .. base_prof .. "001"
		end
		self:ChangeModel(SceneObjPart.Main, ResPath.GetRoleModel(default_res_id))

		DownloadHelper.DownloadBundle(bundle, 3, function(ret)
			if ret then
				self:ChangeModel(SceneObjPart.Main, bundle, asset)
			end
		end)
	else
		self:GetFollowUi():SetIsShowGuildIcon(Scene.Instance:GetCurFbSceneCfg().guild_badge == 0)
		self:ChangeModel(SceneObjPart.Main, bundle, asset)
	end
end

function Role:Update(now_time, elapse_time)
	Character.Update(self, now_time, elapse_time)
	if self.role_last_logic_pos_x ~= self.logic_pos.x or self.role_last_logic_pos_y ~= self.logic_pos.y then
		self.role_last_logic_pos_x = self.logic_pos.x
		self.role_last_logic_pos_y = self.logic_pos.y

		if self.next_create_footprint_time == 0 then
			self:CreateFootPrint()
			self.next_create_footprint_time = Status.NowTime + COMMON_CONSTS.FOOTPRINT_CREATE_GAP_TIME
		end

		if self.next_create_footprint_time == -1 then --初生时也是位置改变，不播
			self.next_create_footprint_time = 0
		end

		self:UpdateShuiboEffect()
	end

	if self.next_create_footprint_time > 0 and now_time >= self.next_create_footprint_time then
		self.next_create_footprint_time = 0
	end
	self:UpdateMultiMountParnter(now_time, elapse_time)
	self:UpdateXunyou(now_time, elapse_time)
end

function Role:UpdateShuiboEffect()
	if not self:IsRoleVisible() or self.draw_obj == nil then return end
	if self:IsWaterRipple() and self:IsMainRole() and not self.is_jump and not self:IsQingGong() then
		if self.shuibo_time then
			GlobalTimerQuest:CancelQuest(self.shuibo_time)
			self.shuibo_time = nil
		end
		if not self.shuibo_effect_is_show then
			if nil == self.shuibo_effect then
				local bundle, asset = ResPath.GetMiscEffect("tongyong_shuibo")
				ResPoolMgr:GetDynamicObjAsync(bundle, asset, 
					function(obj)
						if IsNil(obj) then
							return
						end
						if not self.draw_obj then
							ResPoolMgr:Release(obj)
							return
						end
						self.shuibo_effect = obj
						local role_foot_point = self.draw_obj:GetAttachPoint(AttachPoint.HurtRoot)
						if role_foot_point then
							obj.transform:SetParent(role_foot_point.transform)
							obj.transform.localPosition = Vector3(0, 0, 0)
							obj.transform.localRotation = Quaternion.Euler(-90, 0, 0)
						end
					end)
			elseif self.shuibo_effect_time <= Status.NowTime then
				if self.shuibo_effect and not IsNil(self.shuibo_effect) then
					self.shuibo_effect:GetComponent(typeof(UnityEngine.ParticleSystem)):Play()
				end
			end
		end
		self.shuibo_effect_is_show = true
		self.shuibo_effect_time = Status.NowTime + COMMON_CONSTS.SHUIBO_SHOW_DELAY_TIME
	else
		self:ShuiboEffectStop()
	end
end

function Role:ShuiboEffectStop()
	if not self.shuibo_effect_is_show then return end
	if self.shuibo_effect and not IsNil(self.shuibo_effect) then
		self.shuibo_effect:GetComponent(typeof(UnityEngine.ParticleSystem)):Stop()
		self.shuibo_effect_is_show = false
		self.shuibo_effect_time = 0
		if self.shuibo_time then
			GlobalTimerQuest:CancelQuest(self.shuibo_time)
			self.shuibo_time = nil
		end
		self.shuibo_time = GlobalTimerQuest:AddDelayTimer(function ()
			self:ReleaseShuiboEffect()
		end, 1)
	end
end

function Role:ReleaseShuiboEffect()
	if self.shuibo_effect and not IsNil(self.shuibo_effect) then
		ResPoolMgr:Release(self.shuibo_effect)
		self.shuibo_effect = nil
	end
end

function Role:UpdateXunyou(now_time, elapse_time)
	if self.is_xunyou and self.update_marry_time and self.update_marry_time < now_time then
		local marry_info = MarriageData.Instance:GetXunYouPos()
		self.marry_role = Scene.Instance:GetObjectByObjId(marry_info.obj_id)
		if self.marry_role and marry_info.is_own ~= 0 then
			if not self:IsRoleVisible() then
				self:SetMarryFlag(1)
			end
			self.partner_point2 = self.marry_role.draw_obj:_TryGetPartObj(SceneObjPart.Main)
			if self.partner_point2 then
				if not IsNil(MainCameraFollow) then
					MainCameraFollow.Target = self.partner_point2.transform
				end
				self.draw_obj.root.transform:SetParent(self.partner_point2.transform)
			end
		end
		self.update_marry_time = now_time + 1
	end
end

function Role:EnterStateAttack()
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	if self.vo.task_appearn and self.vo.task_appearn > 0 and self.vo.task_appearn_param_1 > 0 then
		part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Idle)
		self:StopHug()
	end

	local anim_name = SceneObjAnimator.Atk1
	local info_cfg = SkillData.GetSkillinfoConfig(self.attack_skill_id)
	if nil ~= info_cfg then
		anim_name = info_cfg.skill_action
		-- 机器人attack_index要特殊处理
		if self.vo.is_shadow == 1 then
			if info_cfg.hit_count > 1 then
				self.attack_index_shadow = self.attack_index_shadow + 1
				if self.attack_index_shadow > 3 then
					self.attack_index_shadow = 1
				end
				anim_name = anim_name.."_"..self.attack_index_shadow
			end
		else
			if info_cfg.hit_count > 1 then
				anim_name = anim_name.."_"..self.attack_index
			end
		end
		if info_cfg.play_speed ~= nil then
			local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
			main_part:SetFloat(anim_name.."_speed", info_cfg.play_speed)
		end
	else
		-- 跨服农场动作特殊处理
		if Scene.Instance:GetSceneType() == SceneType.FarmHunting and nil ~= FarmHuntingData.FarmSkillAction[self.attack_skill_id] then
			anim_name = FarmHuntingData.FarmSkillAction[self.attack_skill_id].skill_action
			-- if anim_name == "not_action" then
			-- 	GuajiCtrl.SetAtkValid(false)
			-- 	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
			-- 	return
			-- end
			
		end
	end
	Character.EnterStateAttack(self, anim_name)
end

function Role:GetRoleId()
	return self.vo.role_id
end

function Role:GetRoleResId()
	return self.role_res_id
end

function Role:GetRoleHead()
	local base_prof = PlayerData.Instance:GetRoleBaseProf(self.vo.prof)
	return string.format("%3d", base_prof)
end

function Role:GetWeaponResId()
	return self.weapon_res_id
end

function Role:GetWeapon2ResId()
	return self.weapon2_res_id
end

function Role:GetWingResId()
	return self.wing_res_id
end

function Role:GetCloakResId()
	return self.cloak_res_id
end

function Role:GetWaistResId()
	return self.waist_res_id
end

function Role:GetTouShiResId()
	return self.toushi_res_id
end

function Role:GetQilinBiResId()
	return self.qilinbi_res_id
end

function Role:GetMaskResId()
	return self.mask_res_id
end

function Role:GetLingChongObj()
	return self.lingchong_obj
end

function Role:GetTailResId()
	return self.tail_res_id
end

function Role:GetFlyPetResId()
	return self.flypet_res_id
end

function Role:GetShouHuanResId()
	return self.shouhuan_res_id
end

function Role:GetMountResId()
	return self.mount_res_id
end

function Role:GetHaloResId()
	return self.halo_res_id
end

function Role:GetBaoJuResId()
	return self.fabao_res_id
end

function Role:SetAttackMode(attack_mode)
	self.vo.attack_mode = attack_mode
end

function Role:SetIsGatherState(is_gather_state, is_fishing, is_kite)
	self.is_fishing = is_fishing
	self.is_kite = is_kite
	self.is_gather_state = is_gather_state
	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	if is_gather_state then
		self:StopHug()
		local scene_type = Scene.Instance:GetSceneType()
		if scene_type == SceneType.KF_Fish then
			--钓鱼特殊处理
			main_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Gather)
		elseif is_fishing then
			main_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.ShuaiGan)
			MountCtrl.Instance:SendGoonMountReq(0)
		elseif is_kite then
			main_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Kite)
		else
			main_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Gather)
		end
	else
		if self:IsStand() then
			main_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Idle)
		end
		if self:CanHug() then
			main_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Hug)
			self:DoHug()
			local holdbeauty_part = self.draw_obj:GetPart(SceneObjPart.HoldBeauty)
			if holdbeauty_part then
				holdbeauty_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Hug)
			end
		end
	end
	if nil ~= self.mount_res_id and self.mount_res_id ~= "" and self.mount_res_id > 0 and nil == self.do_mount_up_delay then
		self.do_mount_up_delay = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.OnMountUpEnd,self), 0.1)
	end
	self:EquipDataChangeListen()
end

function Role:GetIsGatherState()
	return self.is_gather_state
end

function Role:OnRealive()
	self:InitShow()
	self:ChangeSpirit()
	self:ChangeGoddess()
	-- self:ChangeImpGuard()
	self:OnFightMountUpEnd()
end

function Role:OnDie()
	self:RemoveModel(SceneObjPart.Weapon)
	self:RemoveModel(SceneObjPart.Weapon2)
	self:RemoveModel(SceneObjPart.Wing)
	self:RemoveModel(SceneObjPart.ImpGuard)
	self:RemoveModel(SceneObjPart.Halo)
	self:RemoveModel(SceneObjPart.BaoJu)
	self:RemoveModel(SceneObjPart.FightMount)
	if self.spirit_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.SpiritObj, self.spirit_obj:GetObjKey())
		self.spirit_obj:RemoveModel(SceneObjPart.Main)
		self.spirit_obj:DeleteMe()
		self.spirit_obj = nil
	end

	if self.imp_guard_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.ImpGuardObj, self.imp_guard_obj:GetObjKey())
		self.imp_guard_obj:RemoveModel(SceneObjPart.Main)
		self.imp_guard_obj:DeleteMe()
		self.imp_guard_obj = nil
	end

	if self.goddess_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.GoddessObj, self.goddess_obj:GetObjKey())
		self.goddess_obj = nil
	end
	
	if self.pet_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.PetObj, self.pet_obj:GetObjKey())
		self.pet_obj = nil
	end
end

function Role:UpDateMountLayer(mount_layer, fight_mount_layer, mount_layer2)
	if Scene.Instance:GetSceneType() == SceneType.HotSpring then
		return
	end
	local main_part = self.draw_obj and self.draw_obj:_TryGetPart(SceneObjPart.Main)
	if main_part == nil then
		return
	end

	main_part:SetLayer(ANIMATOR_PARAM.MOUNT_LAYER, mount_layer)
	main_part:SetLayer(ANIMATOR_PARAM.FIGHTMOUNT_LAYER, fight_mount_layer)
	main_part:SetLayer(ANIMATOR_PARAM.MOUNT_LAYER2, mount_layer2)
end

function Role:ChangeSpecialModel()
	if self.special_res_id ~= 0 and Scene.Instance:GetSceneType() == SceneType.KF_Fish then
		self:ChangeModel(SceneObjPart.Main, ResPath.GetMonsterModel(self.special_res_id))
		return
	elseif Scene.Instance:GetSceneType() == SceneType.HotSpring then
		self:ChangeModel(SceneObjPart.Main, ResPath.GetMonsterModel(self.special_res_id))
		return
	elseif Scene.Instance:GetSceneType() == SceneType.ChaosWar then
		self:ChangeModel(SceneObjPart.Main, ResPath.GetMonsterModel(self.special_res_id))
		return
	end

	-- 变身卡
	if self.special_res_id ~= 0 and self.vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_WORD_EVENT_YURENCARD then
		self:ChangeModel(SceneObjPart.Main, ResPath.GetMonsterModel(self.special_res_id))
		return
	end

	if self.vo.task_appearn == CHANGE_MODE_TASK_TYPE.TALK_IMAGE then
		self:ChangeModel(SceneObjPart.Main, TaskData.Instance:ChangeResInfo(self.special_res_id))
		self:ReloadBianShenImage()
	elseif self.vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_GREATE_SOLDIER then
		self:ChangeModel(SceneObjPart.Main,  ResPath.GetMingJiangRes(self.special_res_id))
	elseif self.vo.bianshen_param == BIANSHEN_EFEECT_APPEARANCE.APPEARANCE_MOJIE_GUAIWU then
		self:ChangeModel(SceneObjPart.Main, ResPath.GetMonsterModel(self.special_res_id))
	else
		self:ChangeModel(SceneObjPart.Main, ResPath.GetRoleModel(self.special_res_id))
	end
end

function Role:SetAttr(key, value)
	Character.SetAttr(self, key, value)
	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	local main_role = Scene.Instance:GetMainRole()
	if key == "prof" or key == "appearance" or key == "special_appearance" or key == "bianshen_param" or (key == "task_appearn" and self.vo.task_appearn == CHANGE_MODE_TASK_TYPE.TALK_IMAGE) then
		self:UpdateAppearance()
		self:UpdateFaBao()
		self:UpdateMount()
		self:UpdateFightMount()
		-- self:UpdateRoleFaZhen()
		self:CheckDanceState()
		if self.vo.use_xiannv_id ~= nil and self.vo.use_xiannv_id > -1 then
			self:ChangeGoddess()
		end
		if self:IsMainRole() then
			self:CheckQingGong()
		end
		if self.special_res_id ~= 0 then
			self:ChangeSpecialModel()
			self:RemoveModel(SceneObjPart.Mount)
			self:RemoveModel(SceneObjPart.FightMount)
			self:RemoveModel(SceneObjPart.Weapon)
			self:RemoveModel(SceneObjPart.Weapon2)
			self:RemoveModel(SceneObjPart.Wing)
			self:RemoveModel(SceneObjPart.TouShi)
			self:RemoveModel(SceneObjPart.Waist)
			self:RemoveModel(SceneObjPart.QilinBi)
			self:RemoveModel(SceneObjPart.Mask)
			self:RemoveModel(SceneObjPart.Halo)
			self:RemoveModel(SceneObjPart.BaoJu)
			self:RemoveModel(SceneObjPart.Cloak)
			self:RemoveModel(SceneObjPart.Tail)
			return
		end

		local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
		if self.role_res_id ~= 0 then
			self:ChangeModel(SceneObjPart.Main, ResPath.GetRoleModel(self.role_res_id))
		end

		if self.weapon_res_id ~= 0 then
			self:ChangeModel(SceneObjPart.Weapon, ResPath.GetWeaponModel(self.weapon_res_id))
		end

		if self.weapon2_res_id ~= 0 then
			self:ChangeModel(SceneObjPart.Weapon2, ResPath.GetWeaponModel(self.weapon2_res_id))
		end

		local is_hide_wing = SettingData.Instance:GetAdvanceTypeHideFlag(ADVANCE_HIDE_TYPE.WING)
		if self.wing_res_id ~= nil and self.wing_res_id ~= 0 and fb_scene_cfg.pb_wing ~= 1 and self.vo.multi_mount_res_id <= 0 and is_hide_wing ~= 1 then
			self:ChangeModel(SceneObjPart.Wing, ResPath.GetWingModel(self.wing_res_id))
		else
			self:RemoveModel(SceneObjPart.Wing)
		end

		local is_hide_cloak = SettingData.Instance:GetAdvanceTypeHideFlag(ADVANCE_HIDE_TYPE.CLOAK)
		if self.cloak_res_id ~= nil and self.cloak_res_id ~= 0 and fb_scene_cfg.pb_wing ~= 1 and is_hide_cloak ~= 1 then
			self:ChangeModel(SceneObjPart.Cloak, ResPath.GetPifengModel(self.cloak_res_id))
		else
			self:RemoveModel(SceneObjPart.Cloak)
		end

		local is_hide_halo = SettingData.Instance:GetAdvanceTypeHideFlag(ADVANCE_HIDE_TYPE.HALO)
		if self.halo_res_id ~= nil and self.halo_res_id ~= 0 and fb_scene_cfg.pb_guanghuan ~= 1 and is_hide_halo ~= 1 then
			self:ChangeModel(SceneObjPart.Halo, ResPath.GetHaloModel(self.halo_res_id))
		else
			self:RemoveModel(SceneObjPart.Halo)
		end

		local is_hide_fabao = SettingData.Instance:GetAdvanceTypeHideFlag(ADVANCE_HIDE_TYPE.FABAO)
		if self.fabao_res_id ~= nil and self.fabao_res_id ~= 0 and fb_scene_cfg.pb_fabao ~= 1 and is_hide_fabao ~= 1 then
			self:ChangeModel(SceneObjPart.BaoJu, ResPath.GetFaBaoModel(self.fabao_res_id, true))
		else
			self:RemoveModel(SceneObjPart.BaoJu)
		end

		-- self:ChangeFaZhen()
		self:OnFightMountUpEnd()
		self:OnMountUpEnd()
		
		-- self:ChangeMultiMount()

		self:ChangeYaoShi()
		self:ChangeTouShi()
		self:ChangeQilinBi()
		self:ChangeMask()
		self:ChangeTail()
		self:ChangeShouHuan()
		self:ChangeFlyPet()

		-- local is_hide = SettingData.Instance:GetSettingList()[SETTING_TYPE.SHIELD_SPIRIT]
		-- self:ChangeSpiritHalo()
		-- self:ChangeSpiritFazhen()
	elseif key == "mount_appeid" then
		self:UpdateMount()
		if main_part then
			if nil ~= self.mount_res_id and self.mount_res_id ~= "" and self.mount_res_id > 0 then
				if self.is_sit_mount == 1 then
					self:UpDateMountLayer(0, 1, 0)
				else
					self:UpDateMountLayer(1, 0, 0)
				end
			else
				self:UpDateMountLayer(0, 0, 0)
			end
			main_part:EnableMountUpTrigger(false) --nil ~= main_part:GetObj() and main_role and not main_role:IsFightState()
			self:OnMountUpEnd()
		end
	elseif key == "fight_mount_appeid" then
		self:UpdateFightMount()
		main_part:EnableMountUpTrigger(false)
		if main_part then
			if nil ~= self.fight_mount_res_id and self.fight_mount_res_id ~= "" and self.fight_mount_res_id > 0 then
				self:UpDateMountLayer(0, 1, 0)
			else
				self:UpDateMountLayer(0, 0, 0)
			end

			self:OnFightMountUpEnd()
		end
	elseif key == "used_title_list" then
		self:UpdateTitle()
		if nil ~= self.spirit_obj then
			self.spirit_obj:UpdateSpiritTitle()
		end
	elseif key == "husong_taskid" or key == "husong_color" then
		self:ChangeHuSong()
	elseif	key == "husong_status" or key == "husong_type" then
		self:ChangeJingHuaHuSong()
	elseif key == "hp" or key == "max_hp" then
		if ScoietyData.Instance.have_team then
			ScoietyData.Instance:ChangeTeamList(self.vo)
			GlobalEventSystem:Fire(ObjectEventType.TEAM_HP_CHANGE, self.vo)
		end
		if self:IsMainRole() then
			self:SyncShowHp()
		end
		self:CheckDanceState()
	elseif key == "special_param" then
		-- self:ChangeGuildBattle()
		self:ChangeFollowUiName()
		self:ReloadUIName()
		self:ReloadSpecialImage()
		self:UpdateBoat()
	elseif key == "task_appearn" then
		--暂时只给自己做飞行
		if self.vo.task_appearn == CHANGE_MODE_TASK_TYPE.CHANGE_MODE_TASK_TYPE_FLY and self:IsMainRole() then
			if SceneType.Common == Scene.Instance:GetSceneType() and self.vo.task_appearn_param_1 > 0 then
				if CgManager.Instance:IsCgIng() then
					return
				end
				if self:IsMainRole() and self.vo.appearance_param > 0 then --变身中强制取消变身形象
					self:SetAttr("special_appearance", 0)
				end
				self:RemoveModel(SceneObjPart.FightMount)
				self:ChangeModel(SceneObjPart.Mount, ResPath.GetMountModel(self:GetFlyMount()))	--测试
			else
				self:UpdateMount()
				self:OnMountUpEnd()
			end
		else
			self:ReloadBianShenImage()
			self:UpdateHoldBeauty()
			if self:CanHug() then
				self:UpdateMount()
				self:OnMountUpEnd()
				self:UpdateFightMount()
				self:OnFightMountUpEnd()
				self:DoHug()
				if main_part then
					main_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Hug)
				end
				local holdbeauty_part = self.draw_obj:GetPart(SceneObjPart.HoldBeauty)
				if holdbeauty_part then
					holdbeauty_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Hug)
				end
			else
				self:StopHug()
				if main_part then
					main_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Idle)
				end
			end
		end
	elseif key == "used_sprite_id" or key == "sprite_name" or key == "user_pet_special_img" then
		self:ChangeSpirit()
	elseif key == "imp_guard_id" then
		-- self:ChangeImpGuard()
	elseif key == "use_xiannv_id" or key == "xiannv_huanhua_id" then
		self:ChangeGoddess()
	elseif key == "xiannv_name" then
		local goddess_obj = self:GetGoddessObj()
		if goddess_obj then
			goddess_obj:SetAttr("name", value)
			goddess_obj:GetFollowUi()
		end
	elseif key == "millionare_type" then
		if self.vo.millionare_type and self.vo.millionare_type > 0 then
			self:GetFollowUi():SetDaFuHaoIconState(true)
		else
			self:GetFollowUi():SetDaFuHaoIconState(false)
		end
	elseif key == "guild_name" then
		self:ReloadUIGuildName()
		self:UpdateTitle()
	elseif key == "use_pet_id"then
		self:ChangePet()
	elseif key == "use_baby_id"then
		self:ChangeBaby()
	elseif key == "JingJie" and self.follow_ui then
		self.follow_ui:SetLongXingIcon(self:GetAttr("JingJie"))
	elseif key == "lover_name" then
		self:ReloadUILoverName()
		self:UpdateTitle()
	elseif key == "wuqi_color" then
		self:EquipDataChangeListen()
	elseif key == "name_color" or key == "is_fightback_obj" then
		self:ChangeFollowUiName()
	elseif key == "top_dps_flag" or key == "first_hurt_flag" then
		self:ReloadSpecialImage()
	elseif key == "vip_level" and self.follow_ui then
		self.follow_ui:SetVipIcon(self:GetAttr("vip_level"))
	elseif key == "guild_id" and self.follow_ui then
		self.follow_ui:SetGuildIcon(self)
	elseif key == "halo_lover_uid" then
		local role_id = self.vo.role_id
		if value > 0 then
			local lover_obj = Scene.Instance:GetObjByUId(value)
			local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
			if lover_obj and fb_scene_cfg.pb_couplehalo ~= 1 then
				local lover_role_id = value
				local halo_type = self:GetAttr("halo_type")
				Scene.Instance:CreateCoupleHaloObj(role_id, lover_role_id, halo_type)
			end
		else
			Scene.Instance:DeleteCoupleHaloObj(role_id)
		end
	elseif key == "combine_server_equip_active_special" then
		self:UpdateTitle()
	elseif key == "follow_num" then
		self:ReloadFollowNum()
	elseif key == "lingzhu_used_imageid" then
		if self.spirit_obj then
			self.spirit_obj:SetAttr(key, value)
		end
	elseif key == "lingchong_used_imageid" or key == "linggong_used_imageid" or key == "lingqi_used_imageid" then
		self:ChangeLingChong()

	elseif key == "weiyan_used_imageid" then
		self:UpDateWeiYanResid()
		self:ChangeWeiYan()
	elseif key == "move_speed" then
		if self.spirit_obj then self.spirit_obj:SetAttr(key, value) end
		if self.goddess_obj then self.goddess_obj:SetAttr(key, value) end
		if self.imp_guard_obj then self.imp_guard_obj:SetAttr(key, value) end
		if self.pet_obj then self.pet_obj:SetAttr(key, value) end
	elseif key == "is_yinshen" then
		self.is_yinshen = value or 0
	end
end

function Role:GetFlyMount()
	local task_cfg = TaskData.Instance:GetTaskConfig(self.vo.task_appearn_param_1)
	local mount_res_id = 7013001
	if task_cfg and task_cfg.c_param3 then
		local _, mount_id = TaskData.Instance:ChangeResInfo(task_cfg.c_param3)
		if mount_id and "" ~= mount_id and tonumber(mount_id) > 0 then
			mount_res_id = mount_id
		end
	end
	return mount_res_id
end

function Role:OnMountUpEnd()
	if self:GetIsFlying() then
		return
	end
	self.do_mount_up_delay = nil
	if CgManager.Instance:IsCgIng() then
		self:RemoveModel(SceneObjPart.Mount)
		return
	end

	if nil ~= self.mount_res_id and self.mount_res_id ~= "" and self.mount_res_id > 0 and not self:IsMultiMountPartner() then
		self:RemoveModel(SceneObjPart.FightMount)
		self:RemoveModel(SceneObjPart.FaZhen)
		if self.is_sit_mount == 1 then
			self:RemoveModel(SceneObjPart.Mount)
			self:ChangeModel(SceneObjPart.FightMount, ResPath.GetMountModel(self.mount_res_id))
		else
			if self.is_gather_state then
				self:RemoveModel(SceneObjPart.Mount)
			else
				local res_id = self.mount_res_id
				if self:TaskIsFly() then
					res_id = self:GetFlyMount()
				end

				self:ChangeModel(SceneObjPart.Mount, ResPath.GetMountModel(res_id))
				self.show_fade_in = true
			end
		end
		if self.role_res_id ~= 0 then
			self:ChangeModel(SceneObjPart.Main, ResPath.GetRoleModel(self.role_res_id))
		end
	else
		if self.special_res_id ~= 0 then
			self:ChangeSpecialModel()
			self:RemoveModel(SceneObjPart.Weapon)
			self:RemoveModel(SceneObjPart.Weapon2)
			self:RemoveModel(SceneObjPart.Wing)
			self:RemoveModel(SceneObjPart.Halo)
		end
		if self.is_sit_mount == 1 then
			self:RemoveModel(SceneObjPart.FightMount)
			self.is_sit_mount = 0
		else
			self:RemoveMonutWithFade()
		end

		-- self:ChangeFaZhen()
	end
	self:CheckDanceState()
end

function Role:OnBeHit(real_blood, deliverer, skill_id)
	if real_blood >= 0 or self.vo.hp <= 0 then
		return
	end
	if self:IsMainRole() and deliverer and deliverer:GetType() == SceneObjType.Role and deliverer.vo.is_shadow == 0 then
		MainUICtrl.Instance:SetBeAttackedIcon(deliverer.vo)
	end
end

function Role:OnFightMountUpEnd()
	if nil ~= self.fight_mount_res_id and self.fight_mount_res_id ~= "" and self.fight_mount_res_id > 0 then
		self:RemoveModel(SceneObjPart.Mount)
		self:RemoveModel(SceneObjPart.FaZhen)
		self:ChangeModel(SceneObjPart.FightMount, ResPath.GetFightMountModel(self.fight_mount_res_id))
		if self.role_res_id ~= 0 then
			self:ChangeModel(SceneObjPart.Main, ResPath.GetRoleModel(self.role_res_id))
		end
	else
		if self.special_res_id ~= 0 then
			self:ChangeSpecialModel()
			self:RemoveModel(SceneObjPart.Weapon)
			self:RemoveModel(SceneObjPart.Weapon2)
			self:RemoveModel(SceneObjPart.Wing)
			self:RemoveModel(SceneObjPart.Halo)
		end
		self:RemoveModel(SceneObjPart.FightMount)

		-- self:ChangeFaZhen()
	end
	self:CheckDanceState()
end

function Role:UpdateWingResId()
	if self.vo == nil or self.vo.appearance == nil then
		return
	end
	local index = self.vo.appearance.wing_used_imageid or 0
	local wing_config = ConfigManager.Instance:GetAutoConfig("wing_auto")
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local image_cfg = nil
	self.wing_res_id = 0
	if wing_config and fb_scene_cfg.pb_wing ~= 1 then
		if index >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			image_cfg = wing_config.special_img[index - GameEnum.MOUNT_SPECIAL_IMA_ID]
		else
			image_cfg = wing_config.image_list[index]
		end
		if image_cfg then
			self.wing_res_id = image_cfg.res_id
		end
	end
end

function Role:UpdateCloakResId()
	if self.vo == nil or self.vo.appearance == nil then
		return
	end
	local index = self.vo.appearance.cloak_used_imageid or 0
	local cloak_config = ConfigManager.Instance:GetAutoConfig("cloak_auto")
	local image_cfg = nil
	self.cloak_res_id = 0
	if cloak_config then
		if index >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			image_cfg = cloak_config.special_img[index - GameEnum.MOUNT_SPECIAL_IMA_ID]
		else
			image_cfg = cloak_config.image_list[index]
		end
		if image_cfg then
			self.cloak_res_id = image_cfg.res_id
		end
	end
end

function Role:UpdateFootResId()
	local index = self.vo.appearance.footprint_used_imageid or 0
	local foot_config = ConfigManager.Instance:GetAutoConfig("footprint_auto")
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local image_cfg = nil
	self.foot_res_id = 0
	if foot_config and fb_scene_cfg.pb_foot ~= 1 then
		if index >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			image_cfg = foot_config.special_img[index - GameEnum.MOUNT_SPECIAL_IMA_ID]
		else
			image_cfg = foot_config.image_list[index]
		end
		if image_cfg then
			self.foot_res_id = image_cfg.res_id
		end
	end
end

function Role:ReloadFollowNum()
	local scene_logic = Scene.Instance:GetSceneLogic()
	local is_show_follow_num = scene_logic:GetIsShowSpecialImageRightNum(self)
	if is_show_follow_num then
		local box_count = KFMonthBlackWindHighData.Instance:GetCrossDarkNightPlayerInfoBroadcast(self:GetObjId()) or 0
		box_count = box_count > 0 and box_count or ""
		self:SetFollowNum(box_count)
	end
end

function Role:ReloadRoleScore()
	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic.GetIsShowSpecialScore then
		local is_show_follow_num = scene_logic:GetIsShowSpecialScore(self)
		if is_show_follow_num then
			local role_score = KuaFuTuanZhanData.Instance:GetCrossTuanZhanPlayerInfoScore(self:GetObjId())
			self:SetScore(role_score or 0)
		end
	end
end

function Role:SetRoleScore(score)
	if self.follow_ui then
		self.follow_ui:SetRoleScore(score)
	end
end

function Role:SetFollowNum(num)
	if self.follow_ui then
		self.follow_ui:SetNum(num)
	end
end

function Role:UpdateHaloResId()
	if self.vo == nil or self.vo.appearance == nil then
		return
	end
	local index = self.vo.appearance.halo_used_imageid or 0
	local halo_config = ConfigManager.Instance:GetAutoConfig("halo_auto")
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local image_cfg = nil
	self.halo_res_id = 0
	if halo_config and fb_scene_cfg.pb_guanghuan ~= 1 then
		if index >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			image_cfg = halo_config.special_img[index - GameEnum.MOUNT_SPECIAL_IMA_ID]
		else
			image_cfg = halo_config.image_list[index]
		end
		if image_cfg then
			self.halo_res_id = image_cfg.res_id
		end
	end
end

function Role:UpdateFaBaoResId()
	if self.vo == nil or self.vo.appearance == nil then
		return
	end
	local index = self.vo.appearance.fabao_used_imageid or 0
	local fabao_config = ConfigManager.Instance:GetAutoConfig("fabao_auto")
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local image_cfg = nil
	self.fabao_res_id = 0
	if fabao_config and fb_scene_cfg.pb_guanghuan ~= 1 then
		if index >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			image_cfg = fabao_config.special_img[index - GameEnum.MOUNT_SPECIAL_IMA_ID]
		else
			image_cfg = fabao_config.image_list[index]
		end
		if image_cfg then
			self.fabao_res_id = image_cfg.res_id
		end
	end
end


function Role:UpdateAppearance()
	if self.vo == nil or self.vo.appearance == nil then
		return
	end
	local vo = self.vo
	local prof = vo.prof % 10
	local sex = vo.sex
	--清空缓存
	self.role_res_id = 0
	self.weapon_res_id = 0
	self.weapon2_res_id = 0
	self.wing_res_id = 0
	self.foot_res_id = 0
	self.special_res_id = 0
	self.waist_res_id = 0
	self.toushi_res_id = 0
	self.qilinbi_res_id = 0
	self.mask_res_id = 0
	self.tail_res_id = 0
	self.flypet_res_id = 0
	self.shouhuan_res_id = 0
	
	-- 先查找时装的武器和衣服
	if vo.appearance ~= nil then
		-- 这里改成大于1的原因是我们默认的进阶时装类型是1，在默认时装的时候需要显示首充武器的特殊形象
		if vo.appearance.fashion_wuqi and vo.appearance.fashion_wuqi >= 1 then
			local weapon_cfg_list = vo.appearance.fashion_wuqi_is_special == 0 and ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").weapon_img or ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").weapon_special_img
			if weapon_cfg_list then
				local wuqi_cfg = weapon_cfg_list[vo.appearance.fashion_wuqi]
				local cfg = wuqi_cfg["resouce" .. prof .. sex]
				if type(cfg) == "string" then
					local temp_table = Split(cfg, ",")
					if temp_table then
						self.weapon_res_id = temp_table[1]
						self.weapon2_res_id = temp_table[2]
					end
				elseif type(cfg) == "number" then
					self.weapon_res_id = cfg
				end
			end
		end

		if vo.appearance.fashion_body ~= 0 then
			local fashion_cfg_list = vo.appearance.fashion_body_is_special == 0 and ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").shizhuang_img or ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").shizhuang_special_img
			if nil == fashion_cfg_list then return end
			local clothing_cfg = fashion_cfg_list[vo.appearance.fashion_body]
			if clothing_cfg then
				local res_id = clothing_cfg["resouce" .. prof .. sex]
				self.role_res_id = res_id
			end
		end

		--腰饰
		if vo.appearance.yaoshi_used_imageid and vo.appearance.yaoshi_used_imageid > 0 and WaistData.Instance then
			self.waist_res_id = WaistData.Instance:GetResIdByImageId(vo.appearance.yaoshi_used_imageid)
		end

		--头饰
		if vo.appearance.toushi_used_imageid and vo.appearance.toushi_used_imageid > 0 and TouShiData.Instance then
			self.toushi_res_id = TouShiData.Instance:GetResIdByImageId(vo.appearance.toushi_used_imageid)
		end

		--麒麟臂
		if vo.appearance.qilinbi_used_imageid and vo.appearance.qilinbi_used_imageid > 0 and QilinBiData.Instance then
			self.qilinbi_res_id = QilinBiData.Instance:GetResIdByImageId(vo.appearance.qilinbi_used_imageid, sex)
		end

		--面饰
		if vo.appearance.mask_used_imageid and vo.appearance.mask_used_imageid > 0 and MaskData.Instance then
			self.mask_res_id = MaskData.Instance:GetResIdByImageId(vo.appearance.mask_used_imageid)
		end

		--手环
		if vo.appearance.shouhuan_used_imageid and vo.appearance.shouhuan_used_imageid > 0 and ShouHuanData.Instance then
			self.shouhuan_res_id = ShouHuanData.Instance:GetResIdByImageId(vo.appearance.shouhuan_used_imageid)
		end

		--尾巴
		if vo.appearance.tail_used_imageid and vo.appearance.tail_used_imageid > 0 and TailData.Instance then
			self.tail_res_id = TailData.Instance:GetResIdByImageId(vo.appearance.tail_used_imageid)
		end

		--飞宠
		if vo.appearance.flypet_used_imageid and vo.appearance.flypet_used_imageid > 0 and FlyPetData.Instance then
			self.flypet_res_id = FlyPetData.Instance:GetResIdByImageId(vo.appearance.flypet_used_imageid)
		end
		if vo.appearance.shenbing_image_id ~= nil and vo.appearance.shenbing_image_id > 0 and ShenqiData.Instance then
			local cfg = ShenqiData.Instance:GetResCfgByIamgeID(vo.appearance.shenbing_image_id, vo)
			if nil ~= cfg then
				if type(cfg) == "string" then
					local temp_table = Split(cfg, ",")
					if temp_table then
						self.weapon_res_id = temp_table[1]
						self.weapon2_res_id = temp_table[2]
					end
				elseif type(cfg) == "number" then
					self.weapon_res_id = cfg
				end
			end
		end


		if nil ~= vo.appearance.baojia_image_id and vo.appearance.baojia_image_id > 0 and ShenqiData.Instance then
			local res_id = ShenqiData.Instance:GetBaojiaResCfgByIamgeID(vo.appearance.baojia_image_id, vo)
			if nil ~= res_id then
				self.role_res_id = res_id
			end
		end

		self:UpdateWingResId()
		self:UpdateCloakResId()
		self:UpdateHaloResId()
		self:UpdateFootResId()
		self:UpdateFaBaoResId()
		self:UpdateHead()
	end

	-- 最后查找职业表
	local job_cfgs = ConfigManager.Instance:GetAutoConfig("rolezhuansheng_auto").job
	local role_job = job_cfgs[prof]
	if role_job ~= nil then
		if self.role_res_id == 0 then
			self.role_res_id = role_job["model" .. vo.sex]
		end
		if self.weapon_res_id == 0 then
			-- 武器颜色为红色时，使用特殊的模型
			-- if self.vo.wuqi_color >= GameEnum.ITEM_COLOR_RED then
			-- 	self.weapon_res_id = role_job["right_red_weapon" .. vo.sex]
			-- else
			self.weapon_res_id = role_job["right_weapon" .. vo.sex]
			-- end
		end
		if self.weapon2_res_id == 0 then
			-- if self.vo.wuqi_color >= GameEnum.ITEM_COLOR_RED then
			-- 	self.weapon2_res_id = role_job["left_red_weapon" .. vo.sex]
			-- else
			self.weapon2_res_id = role_job["left_weapon" .. vo.sex]
			-- end
		end
	else
		if self.role_res_id == 0 then
			self.role_res_id = 1101001
		end

		if self.weapon_res_id == 0 then
			self.weapon_res_id = 900100101
		end
	end

	if self.is_fishing then
		self.weapon_res_id = 10050101 					--先用上面的先
		self.weapon2_res_id = 0
	end
	if self.is_kite then
		self.weapon_res_id = 10060101 					--放风筝
		self.weapon2_res_id = 0
	end

	if self.vo.bianshen_param ~= "" and self.vo.bianshen_param ~= 0 then
		if self.vo.bianshen_param == BIANSHEN_EFEECT_APPEARANCE.APPEARANCE_MOJIE_GUAIWU then
			self.special_res_id = 2016001
		elseif self.vo.bianshen_param == BIANSHEN_EFEECT_APPEARANCE.APPEARANCE_DATI_XIAOTU then
			self.special_res_id = 3002001
		elseif self.vo.bianshen_param == BIANSHEN_EFEECT_APPEARANCE.APPEARANCE_DATI_XIAOZHU then
			self.special_res_id = 3003001
		elseif self.vo.bianshen_param == BIANSHEN_EFEECT_APPEARANCE.APPEARANCE_YIZHANDAODI then 		-- 一战到底小树人
			self.special_res_id = 2007001
		end
	elseif SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_WORD_EVENT_YURENCARD == self.vo.special_appearance then
		local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.vo.appearance_param]
		if monster_cfg then
			self.special_res_id = monster_cfg.resid
		end
	elseif SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR == self.vo.special_appearance then
		self.special_res_id = ClashTerritoryData.Instance:GetMonsterResId(self.vo.appearance_param, self.vo.guild_id)
	elseif SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_HUASHENG == self.vo.special_appearance then
		local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.vo.appearance_param]
		if monster_cfg then
			self.special_res_id = monster_cfg.resid
		end
	elseif SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_CROSS_HOTSPRING == self.vo.special_appearance then
		if sex == 1 then
			if prof == 1 then
				self.special_res_id = 2039001
			elseif prof == 2 then
				self.special_res_id = 2040001
			end
		else
			if prof == 3 then
				self.special_res_id = 2042001
			elseif prof == 4 then
				self.special_res_id = 2041001
			end
		end
	elseif SPECIAL_APPEARANCE_TYPE.SPECIAL_APPEARANCE_TYPE_CROSS_FISHING == self.vo.special_appearance then
		local fishing_other_cfg = CrossFishingData.Instance:GetFishingOtherCfg()
		if fishing_other_cfg and fishing_other_cfg["resource_id_" .. prof] then
			self.special_res_id = fishing_other_cfg["resource_id_" .. prof]
			self.weapon_res_id = 0
		end
	elseif self.vo.task_appearn == CHANGE_MODE_TASK_TYPE.TALK_IMAGE then
		self.special_res_id = self.vo.task_appearn_param_1
	elseif self.vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_GREATE_SOLDIER then
		self.special_res_id = self.vo.appearance_param
		self.old_special_res_id = self.special_res_id
	elseif MarriageData.Instance and MarriageData.Instance:IsMarryUserCompareId(self.vo.role_id) then
		local scene_type = Scene.Instance:GetSceneType()
		if scene_type == SceneType.HunYanFb then
			self.weapon_res_id = 0
			self.weapon2_res_id = 0
			if sex == 1 then
				if prof == 1 then
					self.role_res_id = 1101051
				elseif prof == 2 then
					self.role_res_id = 1102051
				end
			else
				if prof == 3 then
					self.role_res_id = 1003051
				elseif prof == 4 then
					self.role_res_id = 1004051
				end
			end
		end
	end

	if self.old_special_res_id and self.old_special_res_id ~= self.special_res_id then
		-- 默认使用回人物技能配置
		local base_prof = PlayerData.Instance:GetRoleBaseProf(self.vo.prof)
		self:SetActorConfigPrefabData(ConfigManager.Instance:GetAutoPrefabConfig(self.vo.sex, base_prof))
	end

	if self:IsMainRole() then
		local value = false
		if SPECIAL_APPEARANCE_TYPE.SPECIAL_APPEARANCE_TYPE_NORMAL == self.vo.special_appearance then
			value = false
		elseif SPECIAL_APPEARANCE_TYPE.SPECIAL_APPEARANCE_TYPE_BIANSHEN == self.vo.special_appearance then
			value = true
		end

		self:SetWarSceneState(value)
	end
end

function Role:UpdateMount()
	local vo = self.vo
	self.mount_res_id = 0
	if self:IsMultiMount() then
		self.mount_res_id = self.vo.multi_mount_res_id
		return
	end
	local image_cfg = nil
	if nil ~= vo.mount_appeid and vo.mount_appeid > 0 and self.special_res_id == 0 then
		if self.vo.mount_appeid > 1000 then
			image_cfg = ConfigManager.Instance:GetAutoConfig("mount_auto").special_img[self.vo.mount_appeid - 1000]
		else
			image_cfg = ConfigManager.Instance:GetAutoConfig("mount_auto").image_list[self.vo.mount_appeid]
		end
	end

	if nil ~= image_cfg and not self:CanHug() then
		self.mount_res_id = image_cfg.res_id
		self.is_sit_mount = image_cfg.is_sit
	end
end

function Role:UpdateFightMount()
	local vo = self.vo
	self.fight_mount_res_id = 0
	local image_cfg = nil
	if nil ~= vo.fight_mount_appeid and vo.fight_mount_appeid > 0 and self.special_res_id == 0 then
		if self.vo.fight_mount_appeid > 1000 then
			image_cfg = ConfigManager.Instance:GetAutoConfig("fight_mount_auto").special_img[self.vo.fight_mount_appeid - 1000]
		else
			image_cfg = ConfigManager.Instance:GetAutoConfig("fight_mount_auto").image_list[self.vo.fight_mount_appeid]
		end
	end
	if nil ~= image_cfg and not self:CanHug() then
		self.fight_mount_res_id = image_cfg.res_id
		-- 恢复下状态 其他地方会设置成站立的
		self.is_sit_mount = 0
	end
end

function Role:UpdateFaBao()
	if self.vo == nil or self.vo.appearance == nil then
		return
	end
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if self.vo.appearance.fabao_used_imageid and self.vo.appearance.fabao_used_imageid > 0 and fb_scene_cfg.pb_fabao ~= 1 then
		if self.vo.appearance.fabao_used_imageid < 1000 and FaBaoData.Instance then  -- 大于1000特殊形象(使用的是普通形象)
			local img_cfg = FaBaoData.Instance:GetImageListInfo(self.vo.appearance.fabao_used_imageid)
			if nil ~= img_cfg then
				self.fabao_res_id = img_cfg.res_id
			end
		else
			if FaBaoData.Instance then
				local spc_img_cfg = FaBaoData.Instance:GetSpecialImageCfg(self.vo.appearance.fabao_used_imageid - 1000)
				if nil ~= spc_img_cfg then
					self.fabao_res_id = spc_img_cfg.res_id
				end
			end
		end
	end
end

function Role:ChangeCloak()
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local is_hide = SettingData.Instance:GetAdvanceTypeHideFlag(ADVANCE_HIDE_TYPE.CLOAK) == 1
	if self.cloak_res_id == nil or self.cloak_res_id <= 0 or fb_scene_cfg.pb_cloak == 1 or nil == self.vo or self.is_enter_fight or is_hide then
		self:RemoveModel(SceneObjPart.Cloak)
		return
	end
	self:ChangeModel(SceneObjPart.Cloak, ResPath.GetPifengModel(self.cloak_res_id))
end

function Role:ChangeYaoShi()
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local is_hide = SettingData.Instance:GetAdvanceTypeHideFlag(ADVANCE_HIDE_TYPE.WAIST) == 1
	if fb_scene_cfg.pb_yaoshi == 1 or self.special_res_id > 0 or self.waist_res_id <= 0 or self.is_enter_fight or is_hide then
		self:RemoveModel(SceneObjPart.Waist)
		return
	end

	self:ChangeModel(SceneObjPart.Waist, ResPath.GetWaistModel(self.waist_res_id))
end

function Role:ChangeTouShi()
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local is_hide = SettingData.Instance:GetAdvanceTypeHideFlag(ADVANCE_HIDE_TYPE.TOUSHI) == 1
	if fb_scene_cfg.pb_toushi == 1 or self.special_res_id > 0 or self.toushi_res_id <= 0 or self.is_enter_fight or is_hide then
		self:RemoveModel(SceneObjPart.TouShi)
		return
	end

	self:ChangeModel(SceneObjPart.TouShi, ResPath.GetTouShiModel(self.toushi_res_id))

end

function Role:ChangeQilinBi()
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local is_hide = SettingData.Instance:GetAdvanceTypeHideFlag(ADVANCE_HIDE_TYPE.QILINBI) == 1
	if fb_scene_cfg.pb_qilinbi == 1 or self.special_res_id > 0 or nil == self.vo or self.qilinbi_res_id <= 0 or is_hide then
		self:RemoveModel(SceneObjPart.QilinBi)
		return
	end

	self:ChangeModel(SceneObjPart.QilinBi, ResPath.GetQilinBiModel(self.qilinbi_res_id, self.vo.sex))
end

function Role:ChangeMask()
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local is_hide = SettingData.Instance:GetAdvanceTypeHideFlag(ADVANCE_HIDE_TYPE.MASK) == 1
	if fb_scene_cfg.pb_mask == 1 or self.special_res_id > 0 or nil == self.vo or self.mask_res_id <= 0 or self.is_enter_fight or is_hide then
		self:RemoveModel(SceneObjPart.Mask)
		return
	end

	self:ChangeModel(SceneObjPart.Mask, ResPath.GetMaskModel(self.mask_res_id))
end

function Role:ChangeTail()
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local is_hide = SettingData.Instance:GetAdvanceTypeHideFlag(ADVANCE_HIDE_TYPE.TAIL) == 1
	if fb_scene_cfg.pb_tail == 1 or self.special_res_id > 0 or nil == self.vo or self.tail_res_id <= 0 or self.is_enter_fight or is_hide then
		self:RemoveModel(SceneObjPart.Tail)
		return
	end

	self:ChangeModel(SceneObjPart.Tail, ResPath.GetTailModel(self.tail_res_id))
end

function Role:ChangeShouHuan()
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local is_hide = SettingData.Instance:GetAdvanceTypeHideFlag(ADVANCE_HIDE_TYPE.SHOUHUAN) == 1
	if fb_scene_cfg.pb_shouhuan == 1 or self.special_res_id > 0 or nil == self.vo or self.shouhuan_res_id == 0 or self.is_enter_fight or is_hide then
		self:RemoveModel(SceneObjPart.ShouHuan)
		return
	end
	self:ChangeModel(SceneObjPart.ShouHuan, ResPath.GetShouHuanModel(self.shouhuan_res_id))
end

function Role:FreeWeiYanList()
	for _, v in pairs(self.weiyan_list) do
		if not IsNil(v) then
			ResPoolMgr:Release(v)
		end
	end

	self.weiyan_list = {}
end

function Role:UpDateWeiYanResid()
	if self.vo == nil or self.vo.appearance == nil then
		return
	end

	self.weiyan_res_id = WeiYanData.Instance:GetResIdByImageId(self.vo.appearance.weiyan_used_imageid or 0)
end

function Role:ChangeWeiYan()
	self:FreeWeiYanList()
	if self.weiyan_res_id == nil or self.weiyan_res_id <= 0 then
		return
	end

	local mount_res_id = self.mount_res_id
	--在战斗坐骑上或者没骑在坐骑上不加载尾焰
	if (not mount_res_id or mount_res_id <= 0) then
		return
	end

	-- local mount_type = WEIYAN_MOUNT_TYPE.MOUNT

	local path_list = WeiYanData.Instance:GetWeiYanGuaDianPathList(mount_res_id)
	if path_list == nil then
		return
	end

	local mount_part = nil
	-- 双人坐骑有些坐骑是战斗坐骑挂点，有些是坐骑挂点
	if self:IsMultiMount() and 1 == MultiMountData.Instance:GetMultiMountSitTypeByResid(self.vo.multi_mount_res_id) then
		mount_part = self.draw_obj:GetPart(SceneObjPart.FightMount)
	else
		mount_part = self.draw_obj:GetPart(SceneObjPart.Mount)
		if not mount_part:GetObj() then
			mount_part = self.draw_obj:GetPart(SceneObjPart.FightMount)
		end
	end
	if mount_part == nil or mount_part:GetObj() == nil then
		return
	end

	local weiyan_res_id = self.weiyan_res_id
	local part_obj = mount_part:GetObj()
	local bundle, asset = ResPath.GetWeiYanModel(weiyan_res_id)

	for _, v in ipairs(path_list) do
		local gua_dian = part_obj.transform:FindByName(v)
		if gua_dian then
			ResPoolMgr:GetDynamicObjAsyncInQueue(bundle, asset, function(obj)
				if nil == obj then
					print_error("error weiyan", bundle, asset)
					return
				end

				if weiyan_res_id ~= self.weiyan_res_id then
					ResPoolMgr:Release(obj)
					return
				end

				--在战斗坐骑上或者没骑在坐骑上不加载尾焰
				if (not self.mount_res_id or self.mount_res_id <= 0) then
					ResPoolMgr:Release(obj)
					return
				end

				--当节点被释放了不添加尾焰
				if gua_dian == nil or IsNil(gua_dian) then
					ResPoolMgr:Release(obj)
					return
				end

				--防止一个坐骑存在多种尾焰
				if self.weiyan_list[gua_dian] then
					ResPoolMgr:Release(obj)
					return
				end

				obj.transform:SetParent(gua_dian, false)
				obj:SetLayerRecursively(DefaultLayer)

				self.weiyan_list[gua_dian] = obj
			end)
		end
	end
end

-- 创建温泉皮艇
function Role:UpdateBoat()
	if Scene.Instance:GetSceneType() == SceneType.HotSpring then --温泉场景
		local special_param = self.vo.special_param
		if self:IsMainRole() then
			special_param = HotStringChatData.Instance:GetpartnerObjId()
		end
		if special_param >= 0 and special_param < 65535 then
			local obj = Scene.Instance:GetObjectByObjId(special_param)
			if obj and obj:IsMainRole() then
				Scene.Instance:CreateBoatByCouple(self:GetObjId(), special_param, obj, HOTSPRING_ACTION_TYPE.SHUANG_XIU)
			else
				Scene.Instance:CreateBoatByCouple(self:GetObjId(), special_param, self, HOTSPRING_ACTION_TYPE.SHUANG_XIU)
			end
		else
			Scene.Instance:DeleteBoatByRole(self:GetObjId())
			if self:IsMainRole() then
				local choose_answer = HotStringChatData.Instance:GetChooseAnswer()
				if choose_answer >= 0 then
					local scene_logic = Scene.Instance:GetSceneLogic()
					if scene_logic then
						if scene_logic:GetSceneType() == SceneType.HotSpring then
							local pos = {}
							if choose_answer == 0 then
								pos = scene_logic:GetPosA()
							else
								pos = scene_logic:GetPosB()
							end
							if pos and next(pos) then
								GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), pos.x, pos.y, 1, 1)
							end
						end
					end
				end
				local is_start_gather = HotStringChatData.Instance:GetIsStartGather()
				if is_start_gather then
					local hot_info_view = HotStringChatCtrl.Instance:GetRankView()
					if hot_info_view then
						hot_info_view:OnGatherThing()
					end
				end
			end
		end
	elseif Scene.Instance:GetSceneType() == SceneType.KF_Fish then
		local special_param = self.vo.special_param
		if special_param >= 0 then
			GlobalTimerQuest:AddDelayTimer(function ()
				local obj = Scene.Instance:GetObjectByObjId(self.vo.obj_id)
				if nil == obj then return end

				local obj_part = obj.draw_obj:GetPart(SceneObjPart.Main)
				if special_param == FISHING_STATUS.FISHING_STATUS_HOOKED then
					obj_part:SetInteger("status", ActionStatus.ShangGou)					--上钩
				end

				if special_param == FISHING_STATUS.FISHING_STATUS_CAST then
					obj_part:SetInteger("status", ActionStatus.ShuaiGan)					--甩杆
				end

				if special_param == FISHING_STATUS.FISHING_STATUS_PULLED  then			--收杆
					obj_part:SetInteger("status", ActionStatus.ShouGan)			
				end

				if special_param == FISHING_STATUS.FISHING_STATUS_IDLE then
					obj_part:SetInteger("status", ActionStatus.Idle)						--等待	
				end

				if special_param == FISHING_STATUS.FISHING_STATUS_WAITING then
					obj_part:SetInteger("status", ActionStatus.Idle)						--等待
					local real_x, real_y = obj:GetRealPos()								--人物世界坐标
					local real_vec = u3d.vec2(real_x, real_y)							--世界坐标转化成表
					local target_x, target_y = 0, 0
					local is_water_way = false												
					local length = 6.5													--半径长度
					local flag = math.random(2)											--取随机方向遍历角度(1为右边，-1为左边)
					if flag == 2 then
						flag = -1
					end
					local pos = obj:GetRoot().transform.position
					local dir = obj:GetRoot().transform.forward					
					local dirvec = u3d.vec2(dir.x, dir.z)								--方向坐标转化成表
					local vec = u3d.v2Add(real_vec, u3d.v2Mul(dirvec, length))			--获得目标位置
					for i = 1, 12 do
						target_x, target_y = GameMapHelper.WorldToLogic(vec.x, vec.y)	--世界坐标转化成逻辑坐标（传参是逻辑坐标）
						is_water_way = AStarFindWay:IsWaterWay(target_x, target_y)			--求目标是否为水区域（参数为逻辑坐标）
						if is_water_way then
							local goal = u3d.vec3(vec.x, pos.y + 0.1, vec.y)
							CrossFishingData.Instance:SetFishingGoal(role_id, goal)
							break
						end
						dirvec = u3d.v2Rotate(dirvec, 30, flag)							--往flag方向转30度角
						vec = u3d.v2Add(real_vec, u3d.v2Mul(dirvec, length))
					end

					if is_water_way then
						obj:SetDirectionByXY(target_x, target_y)
					end
				end
			end, 0)
		end
	end
end

function Role:CreateTitle()
	self:UpdateTitle()
end

function Role:UpdateTitle()
	if nil == self:GetFollowUi() then return end
	self:GetFollowUi():CreateTitleEffect(self.vo)
	-- self.title_layer:SetTitleListOffsetY(self.model:GetHeight())
	self:InspectTitleLayerIsShow()
end

function Role:IsRoleVisible()
	return self.role_is_visible
end

function Role:CreateShadow()
	Character.CreateShadow(self)
end

function Role:RegisterShadowUpdate()
	Character.RegisterShadowUpdate(self)
end

function Role:SetRoleSheildOptimize(is_role_shield_optimize)
	if self.is_role_shield_optimize ~= is_role_shield_optimize then
		self.is_role_shield_optimize = is_role_shield_optimize
		self:SetRoleVisible()
	end
end

-- 不接受传入参数，所有因素在函数内判断
function Role:SetRoleVisible()
	local setting_data = SettingData.Instance
	-- 屏蔽其他玩家
	local shield_others = setting_data:GetSettingData(SETTING_TYPE.SHIELD_OTHERS)
	-- 屏蔽友方玩家
	local shield_same_camp = (setting_data:GetSettingData(SETTING_TYPE.SHIELD_SAME_CAMP) == true) and (not Scene.Instance:IsEnemy(self) == true)
	-- local is_scene_shield = Scene.Instance:GetIsShield()

	local is_shield = shield_others == true or shield_same_camp == true or self.is_role_shield_optimize
	-- local is_in_multi_mount = (self:IsMultiMountPartner() and self.on_multi_mount == 0 and self:GetMountOwnerRole())
	local is_in_multi_mount = self.is_in_multi_mount

	-- 隐身buff
	local is_yinshen = self.buff_type_list[BUFF_TYPE.INVISIBLE] == 1

	local is_visible = (not is_shield and not is_yinshen) or is_in_multi_mount or self:IsMainRole()
	if self.is_xunyou or self.is_delivering then
		is_visible = false
	end

	local is_show_follow_ui = true
	if is_yinshen then
		is_show_follow_ui = false

	-- 只有在隐藏角色的时候并且当前角色因为性能优化而隐藏的，头顶上的总数如果超过一定数量，才不显示
	elseif not is_visible and is_shield and 
		not self:IsMainRole() and self:CanHideFollowUi() 
		and Scene.Instance:IsCanHideRoleFollowUIInLimitCount(45) then
		is_show_follow_ui = false
		self:SetShadowSheild(true)

	else
		is_show_follow_ui = true
		self:SetShadowSheild(false)
	end

	if is_show_follow_ui then
		self:ShowFollowUi()
	else
		self:HideFollowUi()
	end

	if nil ~= self.draw_obj then
		self.draw_obj:SetVisible(is_visible, function() self:InitWaterState() end)
	end
	self.role_is_visible = is_visible

	self:SetTitleVisible(is_visible)
	self:SetGoddessVisible(is_visible)
	self:SetSpriteVisible(is_visible)
	self:SetLingChongVisible(is_visible)
	self:SetFlyPetVisible(is_visible)
	if self.follow_ui then
		self.follow_ui:SetIsShowGuildIcon(is_visible)
	end

	if not is_visible then
		self:GetOrAddSimpleShadow()
	end
	if self.simple_shadow ~= nil then
		if is_visible then
			self.simple_shadow.enabled = false
		else
			self.simple_shadow.enabled = true
		end
	end
	if self.role_is_visible and self:IsMultiMountPartner() then
		if self.is_sit_mount2 then
			if self.is_sit_mount2 == 0 then
				self:UpDateMountLayer(1, 0, 0)
			elseif self.is_sit_mount2 == 1 then
				self:UpDateMountLayer(0, 1, 0)
			else
				self:UpDateMountLayer(0, 0, 1)
			end
		end
	end
end

function Role:SetGoddessVisible(is_visible)
	local is_hide = SettingData.Instance:GetSettingData(SETTING_TYPE.CLOSE_GODDESS) or false
	self.goddess_visible = is_visible and self.role_is_visible and not is_hide
	if self.vo.husong_color ~= 0 and self.vo.husong_taskid ~= 0 then
		self.goddess_visible = false
	end
	if self.goddess_visible then
		self:ChangeGoddess()
	end
	local goddess_obj = self:GetGoddessObj()
	if goddess_obj then
		goddess_obj:SetGoddessVisible(self.goddess_visible)
	end
end

function Role:SetSpriteVisible(is_visible)
	local is_hide = SettingData.Instance:GetSettingData(SETTING_TYPE.SHIELD_SPIRIT) or false
	self.spirit_visible = is_visible and self.role_is_visible and not is_hide
	if self.vo.husong_color ~= 0 and self.vo.husong_taskid ~= 0 then
		self.spirit_visible = false
	end
	if self.spirit_visible then
		self:ChangeSpirit()
	end
	if self.spirit_obj then
		self.spirit_obj:SetSpiritVisible(self.spirit_visible)
	end
end

function Role:SetLingChongVisible(is_visible)
	local is_hide = SettingData.Instance:GetSettingData(SETTING_TYPE.SHIELD_LINGCHONG) or false
	self.lingchong_visible = is_visible and self.role_is_visible and not is_hide
	if self.vo.husong_color ~= 0 and self.vo.husong_taskid ~= 0 then
		self.lingchong_visible = false
	end
	if self.lingchong_visible then
		self:ChangeLingChong()
	end
	if self.lingchong_obj then
		self.lingchong_obj:ChangeVisible(self.lingchong_visible)
	end
end

function Role:SetFlyPetVisible(is_visible)
	local is_hide = SettingData.Instance:GetSettingData(SETTING_TYPE.SHIELD_FLYPET) or false
	self.fly_visible = is_visible and self.role_is_visible and not is_hide
	if self.vo.husong_color ~= 0 and self.vo.husong_taskid ~= 0 then
		self.fly_visible = false
	end
	if self.fly_visible then
		self:ChangeFlyPet()
	end
	if self.flypet_obj then
		self.flypet_obj:ChangeVisible(self.fly_visible)
	end
end

function Role:SetPetVisible(is_visible)
	self.pet_visible = is_visible and self.role_is_visible
	if self.pet_obj then
		self.pet_obj:SetPetVisible(is_visible)
	end
end

function Role:SetBabyVisible(is_visible)
	self.pet_visible = is_visible and self.role_is_visible
	if self.baby_obj then
		self.baby_obj:SetBabyVisible(is_visible)
	end
end

function Role:SetTitleVisible(is_visible)
	-- if nil == self.title_layer then return end
	self:InspectTitleLayerIsShow(is_visible)
end

function Role:InspectTitleLayerIsShow(is_visible)
	local flag = true
	if nil ~= is_visible then flag = is_visible end

	if SettingData.Instance then
		flag = not SettingData.Instance:GetSettingData(SETTING_TYPE.CLOSE_TITLE)
	end

	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if fb_scene_cfg.pb_chenhao and fb_scene_cfg.pb_chenhao == 1 or BossData.IsBossScene() then
		flag = false
	end

	-- if SceneType.XianMengzhan == Scene.Instance:GetSceneType()
	-- or SceneType.HunYanFb == Scene.Instance:GetSceneType()
	-- or SceneType.Field1v1 == Scene.Instance:GetSceneType() then
	-- 	flag = false
	-- elseif self.vo.husong_taskid > 0 or self.vo.jilian_type > 0 or self.special_res_id ~= 0 then
	-- 	flag = false
	-- elseif self.vo.jinghua_husong_status > 0 then
	-- 	flag = false
	-- end

	if not self.role_is_visible then
		flag = false
	end
	self:GetFollowUi():SetTitleVisible(flag)
end

function Role:ChangeFakeTruck()
	if SceneType.Common == Scene.Instance:GetSceneType() and TaskData.Instance:GetTaskIsCanCommint(FAkE_TRUCK) then
		if self:IsMainRole() and not self.fake_truck_obj then
			self.fake_truck_obj = Scene.Instance:CreateFakeTruckObjByRole(self)
		end
	else
		if self.fake_truck_obj then
			Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.FakeTruckObj, self.fake_truck_obj:GetObjKey())
			self.fake_truck_obj = nil
		end
	end
end

function Role:ChangeHuSong()
	if Scene.Instance:GetSceneType() == SceneType.Common then 					-- 普通场景才调用护送相关操作
		if self.vo.husong_taskid ~= 0 and self.vo.husong_color ~= 0 then
			if self:IsMainRole() then
				YunbiaoCtrl.Instance:ShowHuSongButton(true)
				MountCtrl.Instance:SendGoonMountReq(0)
				FightMountCtrl.Instance:SendGoonFightMountReq(0)
			end
			if not self.truck_obj then
				self.truck_obj = Scene.Instance:CreateTruckObjByRole(self)
			end
			local str = "hu_" .. self.vo.husong_color
			self:GetFollowUi():ChangeSpecailTitle(str)
			-- 屏蔽女神和精灵
			self:SetGoddessVisible(false)
			self:SetSpriteVisible(false)
			self:SetLingChongVisible(false)
			self:SetFlyPetVisible(false)
		else
			if self:IsMainRole() then
				YunbiaoCtrl.Instance:ShowHuSongButton(false)
			end
			if self.truck_obj then
				Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.TruckObj, self.truck_obj:GetObjKey())
				self.truck_obj = nil
			end
			self:GetFollowUi():ChangeSpecailTitle(nil)
			-- 还原女神和精灵
			self:SetGoddessVisible(true)
			self:SetSpriteVisible(true)
			self:SetLingChongVisible(true)
			self:SetFlyPetVisible(true)
		end

		if self:IsMainRole() then
			self:CheckQingGong()
		end
	end
end

--初始化无敌采集称号
function Role:InitWuDiGather()
	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic then
		if scene_logic:GetSceneType() == SceneType.ShuiJing then
			if not self:CheckShuijingBuff() then
				self:GetFollowUi():ChangeSpecailTitle(nil)
				return
			end
			local str = "wudi_gather"
			self:GetFollowUi():ChangeSpecailTitle(str)
		elseif scene_logic:GetSceneType() == SceneType.TombExplore then
			if not self:CheckTombExploreBuff() then
				self:GetFollowUi():ChangeSpecailTitle(nil)
				return
			end
			local str = "wudi_gather"
			self:GetFollowUi():ChangeSpecailTitle(str)
		elseif scene_logic:GetSceneType() == SceneType.KF_Borderland then
			if not self:CheckKFBorderlandBuff() then
				self:GetFollowUi():ChangeSpecailTitle(nil)
				return
			end
			local str = "wudi_gather"
			self:GetFollowUi():ChangeSpecailTitle(str)
		end
	end
end

--改变无敌采集称号
function Role:ChangeWuDiGather(shuijing_buff, scene_type)
	if scene_type == SceneType.TombExplore then
		if not self:CheckTombExploreBuff(shuijing_buff) then
			self:GetFollowUi():ChangeSpecailTitle(nil)
			return
		end
		local str = "wudi_gather"
		self:GetFollowUi():ChangeSpecailTitle(str)
	elseif scene_type == SceneType.KF_Borderland then
		if not self:CheckKFBorderlandBuff(shuijing_buff) then
			self:GetFollowUi():ChangeSpecailTitle(nil)
			return
		end
		local str = "wudi_gather"
		self:GetFollowUi():ChangeSpecailTitle(str)
	else
		if not self:CheckShuijingBuff(shuijing_buff) then
			self:GetFollowUi():ChangeSpecailTitle(nil)
			return
		end
		local str = "wudi_gather"
		self:GetFollowUi():ChangeSpecailTitle(str)
	end
end

function Role:CheckTombExploreBuff(tomb_buff)
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type and scene_type ~= SceneType.TombExplore then
	 	return false
	end

	if tomb_buff ~= nil then
		return tomb_buff == 1
	end

	if self:IsMainRole() then
		local gather_time = TombExploreData.Instance:GetTombFbBuffTime()
		return gather_time > TimeCtrl.Instance:GetServerTime()
	else
		return self.vo.special_param == 1
	end
	return true
end

function Role:CheckKFBorderlandBuff(tomb_buff)
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type and scene_type ~= SceneType.KF_Borderland then
	 	return false
	end

	if tomb_buff ~= nil then
		return tomb_buff == 1
	end

	if self:IsMainRole() then
		local gather_time = KuaFuBorderlandData.Instance:GetKFBorderlandBuffTime()
		return gather_time > TimeCtrl.Instance:GetServerTime()
	else
		return self.vo.special_param == 1
	end
	return true
end

--检测是否有水晶buff
function Role:CheckShuijingBuff(shuijing_buff)
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id ~= FUBEN_SCENE_ID.SHUIJING then
	 	return false
	end

	if shuijing_buff ~= nil then
		return shuijing_buff == 1
	end

	if self:IsMainRole() then
		local crystal_info = CrossCrystalData.Instance:GetCrystalInfo()
		return crystal_info.gather_buff_time > TimeCtrl.Instance:GetServerTime()
	else
		return self.vo.special_param == 1
	end
	return true
end

function Role:ChangeSpirit()
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local call_back = function()
		-- self:ChangeSpiritHalo()
		-- self:ChangeSpiritFazhen()
	end
	if self.vo.used_sprite_id and self.vo.used_sprite_id > 0 and fb_scene_cfg.pb_jingling ~= 1 and self.spirit_visible then
		if not self.spirit_obj then
			self.spirit_obj = Scene.Instance:CreateSpiritObjByRole(self)
			self.spirit_obj:SetLoadCallBack(call_back)
		else
			local spirit_cfg = nil
			if self.vo.user_pet_special_img >= 0 then
				spirit_cfg = SpiritData.Instance:GetSpecialSpiritImageCfg(self.vo.user_pet_special_img)
			else
				spirit_cfg = SpiritData.Instance:GetSpiritResIdByItemId(self.vo.used_sprite_id)
			end
			if spirit_cfg and spirit_cfg.res_id and spirit_cfg.res_id > 0 then
				self.spirit_obj:SetObjId(self.vo.used_sprite_id)
				self.spirit_obj:UpdateSpritId(self.vo.used_sprite_id)
				self.spirit_obj:UpdateSpecialSpritId(self.vo.user_pet_special_img)
				self.spirit_obj:ChangeModel(SceneObjPart.Main, ResPath.GetSpiritModel(spirit_cfg.res_id))
				self.spirit_obj:SetSpiritName(self.vo.sprite_name)
			end
			call_back()
		end
	else
		if self.spirit_obj then
			Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.SpiritObj, self.spirit_obj:GetObjKey())
			self.spirit_obj:RemoveModel(SceneObjPart.Main)
			self.spirit_obj:DeleteMe()
			self.spirit_obj = nil
		end
		call_back()
	end
end

function Role:ChangeImpGuard()
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local call_back = function()
		-- self:ChangeSpiritHalo()
		-- self:ChangeSpiritFazhen()
	end
	if self.vo.imp_guard_id and self.vo.imp_guard_id > 0 then
		if not self.imp_guard_obj then
			self.imp_guard_obj = Scene.Instance:CreateImpGuardObjByRole(self)
			self.imp_guard_obj:SetLoadCallBack(call_back)
		else
			local imp_guard_cfg = nil

				imp_guard_cfg = EquipData.GetXiaoGuiCfgType(self.vo.imp_guard_id)

			if imp_guard_cfg and imp_guard_cfg.res_id and imp_guard_cfg.res_id > 0 then
				self.imp_guard_obj:SetObjId(self.vo.imp_guard_id)
				self.imp_guard_obj:UpdateImpGuardInfo(self.vo.imp_guard_id)
				-- self.imp_guard_obj:UpdateSpecialSpritId(self.vo.user_pet_special_img)
				-- self.imp_guard_obj:ChangeModel(SceneObjPart.Main, ResPath.GetImpGuardModel(imp_guard_cfg.res_id))
				-- self.imp_guard_obj:SetImpGuardName(self.vo.imp_guard_id)
			end
			-- call_back()
		end
	else
		if self.imp_guard_obj then
			Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.ImpGuardObj, self.imp_guard_obj:GetObjKey())
			self.imp_guard_obj:RemoveModel(SceneObjPart.Main)
			self.imp_guard_obj:DeleteMe()
			self.imp_guard_obj = nil
		end
		-- call_back()
	end
end

function Role:ChangeSpiritHalo()
	if self.vo == nil or self.vo.appearance == nil then
		return
	end
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if self.vo.used_sprite_id and self.vo.used_sprite_id > 0 and fb_scene_cfg.pb_jingling ~= 1 and not self.shield_spirit_helo then
		if self.vo.appearance.jingling_guanghuan_imageid and self.vo.appearance.jingling_guanghuan_imageid > 0 then
			if self.spirit_obj then
				local image_cfg = SpiritData.Instance:GetSpiritHaloImageCfg()[self.vo.appearance.jingling_guanghuan_imageid]
				if self.vo.appearance.jingling_guanghuan_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
					image_cfg = SpiritData.Instance:GetSpiritHaloSpecialImageCfg()[self.vo.appearance.jingling_guanghuan_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID]
				end
				local is_hide = SettingData.Instance:GetSettingList()[SETTING_TYPE.SHIELD_SPIRIT]
				if not is_hide then
					GlobalTimerQuest:AddDelayTimer(function()
						if self.spirit_obj then
							if not self.spirit_halo then
								self.spirit_halo = self.spirit_halo or AllocAsyncLoader(self, "spirit_halo_loader")
								self.spirit_halo:SetParent(self.spirit_obj.draw_obj:GetAttachPoint(AttachPoint.Hurt))
							end
							if image_cfg then
								local load_call_back = function(obj)
									if IsNil(obj) then
										return
									end

									local go = U3DObject(obj)
									local main_obj = self.spirit_obj.draw_obj:GetPart(SceneObjPart.Main):GetObj()
									local attachment = main_obj and main_obj.actor_attachment
									if go.attach_obj then
										go.attach_obj:SetAttached(self.spirit_obj.draw_obj:GetAttachPoint(AttachPoint.Hurt))
										if attachment then
											go.attach_obj:SetTransform(attachment.Prof)
										end
									end
								end
								local bundle, asset = ResPath.GetHaloModel(image_cfg.res_id)
								self.spirit_halo:Load(bundle, asset, load_call_back)
							end
						end
					end, 0.8)
				end
			end
		end
	else
		if self.spirit_halo then
			self.spirit_halo:Destroy()
			self.spirit_halo:DeleteMe()
			self.spirit_halo = nil
		end
	end
end

-- 屏蔽仙宠法阵
-- function Role:ChangeSpiritFazhen()
-- 	if self.spirit_obj then
-- 		local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
-- 		if self.vo.used_sprite_id and self.vo.used_sprite_id > 0 and fb_scene_cfg.pb_jingling ~= 1 then
-- 			if self.vo.appearance and self.vo.appearance.jingling_fazhen_imageid > 0 then
-- 				local image_cfg = SpiritData.Instance:GetSpiritFazhenImageCfg()[self.vo.appearance.jingling_fazhen_imageid] or {}
-- 				if self.vo.appearance.jingling_fazhen_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
-- 					image_cfg = SpiritData.Instance:GetSpiritFazhenSpecialImageCfg()[self.vo.appearance.jingling_fazhen_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID] or {}
-- 				end
-- 				self.spirit_obj:ChangeSpiritFazhen(image_cfg.res_id)
-- 			else
-- 				self.spirit_obj:ChangeSpiritFazhen()
-- 			end
-- 		else
-- 			self.spirit_obj:ChangeSpiritFazhen()
-- 		end
-- 	end
-- end

-- function Role:ChangeFightMount()
-- 	if self.vo.fight_mount_appeid and self.vo.fight_mount_appeid > 0 then
-- 		if not self.fight_mount_obj then
-- 			self.fight_mount_obj = Scene.Instance:CreateFightMountObjByRole(self)
-- 		else
-- 			self.fight_mount_obj:ChangeModel(SceneObjPart.Main, ResPath.GetFightMountModle())
-- 		end
-- 	else
-- 		if self.fight_mount_obj then
-- 			self.fight_mount_obj:RemoveModel(SceneObjPart.Main)
-- 			Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.FightMount, self.fight_mount_obj:GetObjKey())
-- 			-- self.fight_mount_obj:GetFollowUi():DeleteMe()
-- 			-- ResMgr:Destroy(self.spirit_obj.draw_obj:GetRoot().gameObject)
-- 			self.fight_mount_obj:DeleteMe()
-- 			self.fight_mount_obj = nil
-- 		end
-- 	end
-- end

-- function Role:ChangeGuildBattle()
-- 	local scene_logic = Scene.Instance:GetSceneLogic()
-- 	if scene_logic then
-- 		if scene_logic:GetSceneType() ~= SceneType.LingyuFb then
-- 			return
-- 		end
-- 	end
-- 	if self.vo.special_param ~= 0 then
-- 		local str = "guild_battle_" .. self.vo.special_param
-- 		self:GetFollowUi():ChangeSpecailTitle(str)
-- 	else
-- 		self:GetFollowUi():ChangeSpecailTitle(nil)
-- 	end
-- end

function Role:ChangePet()
	if self.vo.pet_id and self.vo.pet_id > 0 then
		if not self.pet_obj then
			self.pet_obj = Scene.Instance:CreatePetObjByRole(self)
		else
			local pet_cfg = LittlePetData.Instance:GetSinglePetCfgByPetId(self.vo.pet_id)
			if pet_cfg and pet_cfg.using_img_id and pet_cfg.using_img_id > 0 then
				self.pet_obj:SetObjId(self.vo.pet_id)
				self.pet_obj:UpdatePetId(self.vo.pet_id)
				self.pet_obj:ChangeModel(SceneObjPart.Main, ResPath.GetLittlePetModel(pet_cfg.using_img_id))
				self.pet_obj:SetPetName(pet_cfg.name)
			end
		end
	else
		if self.pet_obj then
			local delete_call_back = function()
				self:RemovePetModel()
			end
			self.pet_obj:RemovePetWithFade(delete_call_back)
		end
	end
end

function Role:RemovePetModel()
	if self.pet_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.PetObj, self.pet_obj:GetObjKey())
		self.pet_obj:RemoveModel(SceneObjPart.Main)
		self.pet_obj:DeleteMe()
		self.pet_obj = nil
	end
end

function Role:ChangeBaby()
	if self.vo.baby_id and self.vo.baby_id > 0 then
		if not self.baby_obj then
			self.baby_obj = Scene.Instance:CreateBabyObjByRole(self)
		else
			self.baby_obj:SetObjId(self.vo.baby_id)
			self.baby_obj:UpdateBabyId(self.vo.baby_id)
			-- self.baby_obj:ChangeModel(SceneObjPart.Main, ResPath.GetSpiritModel(BaobaoData.BabyModel[baby_id]))
			self.baby_obj:ChangeModel(SceneObjPart.Main, ResPath.GetSpiritModel(baby_id))
			self.baby_obj:SetBabyName(self.vo.baby_name)
		end
	else
		if self.baby_obj then
			local delete_call_back = function()
				self:RemoveBabyModel()
			end
			self.baby_obj:RemoveBabyWithFade(delete_call_back)
		end
	end
end

function Role:RemoveBabyModel()
	if self.baby_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.PetObj, self.baby_obj:GetObjKey())
		self.baby_obj:RemoveModel(SceneObjPart.Main)
		self.baby_obj:DeleteMe()
		self.baby_obj = nil
	end
end

function Role:ChangeGoddess()
	if self.vo == nil or self.vo.appearance == nil then
		return
	end
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if self.vo.use_xiannv_id and self.vo.use_xiannv_id >= 0 and fb_scene_cfg.pb_god ~= 1 and self.goddess_visible then
		if not self.goddess_obj then
			self.goddess_obj = Scene.Instance:CreateGoddessObjByRole(self)
		else
			self.goddess_obj:SetAttr("use_xiannv_id", self.vo.use_xiannv_id)
			self.goddess_obj:SetAttr("goddess_wing_id", self.vo.appearance.shenyi_used_imageid)
			self.goddess_obj:SetAttr("goddess_shen_gong_id", self.vo.appearance.shengong_used_imageid)
			self.goddess_obj:SetAttr("xiannv_huanhua_id", self.vo.xiannv_huanhua_id)
		end
	else
		if self.goddess_obj then
			Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.GoddessObj, self.goddess_obj:GetObjKey())
			self.goddess_obj = nil
		end
	end
end

function Role:ChangeLingChong()
	if self.vo == nil or self.vo.appearance == nil then
		return
	end
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local image_id = self.vo.appearance.lingchong_used_imageid or 0

	if image_id <= 0 or fb_scene_cfg.pb_lingtong == 1 or not self.lingchong_visible then
		if self.lingchong_obj then
			Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.LingChongObj, self.lingchong_obj:GetObjKey())
			self.lingchong_obj = nil
		end
		return
	end

	if nil == self.lingchong_obj then
		self.lingchong_obj = Scene.Instance:CreateLingChongObjByRole(self)
	end
	if self.lingchong_obj then
		self.lingchong_obj:SetAttr("lingchong_used_imageid", self.vo.appearance.lingchong_used_imageid)
		self.lingchong_obj:SetAttr("linggong_used_imageid", self.vo.appearance.linggong_used_imageid)
		self.lingchong_obj:SetAttr("lingqi_used_imageid", self.vo.appearance.lingqi_used_imageid)
	end

	local is_hide = SettingData.Instance:GetSettingList()[SETTING_TYPE.SHIELD_LINGCHONG]
	if is_hide then
		self.lingchong_obj:ChangeVisible(not is_hide)
	end
end

function Role:ChangeFlyPet()
	if self.vo == nil or self.vo.appearance == nil then
		return
	end
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local image_id = self.vo.appearance.flypet_used_imageid or 0
	if image_id <= 0 or fb_scene_cfg.pb_flypet == 1 or not self.flypet_visible then
		if self.flypet_obj then
			Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.FlyPetObj, self.flypet_obj:GetObjKey())
			self.flypet_obj = nil
		end

		return
	end

	if nil == self.flypet_obj then
		self.flypet_obj = Scene.Instance:CreateFlyPetObjByRole(self)
	end
	self.flypet_obj:SetAttr("flypet_used_imageid", self.vo.appearance.flypet_used_imageid)
	local image_cfg_info = FlyPetData.Instance:GetImageCfgInfoByImageId(self.vo.appearance.flypet_used_imageid)
	if image_cfg_info then
		self.flypet_obj:SetAttr("name", image_cfg_info.image_name)
	end

	local is_hide = SettingData.Instance:GetSettingList()[SETTING_TYPE.SHIELD_FLYPET]
	if is_hide then
		self.flypet_obj:ChangeVisible(not is_hide)
	end
end

function Role:CreateFollowUi()
	self.follow_ui = RoleFollow.New()
	if self:IsMainRole() then
		self.follow_ui:IsMainRole(true)
	end
	self.follow_ui:CreateRootObj(self.obj_type)

	if self.draw_obj then
		self.follow_ui:SetFollowTarget(self.draw_obj.root.transform, self.draw_obj:GetName())
	end
	self:SyncShowHp()
end

function Role:GetGoddessObj()
	return self.goddess_obj
end

function Role:ReloadUIName()
	if self.follow_ui ~= nil then
		local scene_logic = Scene.Instance:GetSceneLogic()
		local color_name = ""
		if scene_logic then
			color_name = scene_logic:GetColorName(self)
		end
		-- if self:IsMainRole() then
		if Scene.Instance:GetSceneType() == SceneType.CrossTuanZhan and color_name then
			color_name = color_name
		else
			color_name = ToColorStr(color_name, TEXT_COLOR.YELLOW)
		end
		self.follow_ui:SetName(color_name, self)
		self:ReloadUIGuildName()
		self:ReloadUILoverName()
		self:ReloadSpecialImage()
		self.follow_ui:SetVipIcon(self:GetAttr("vip_level"))
		self.follow_ui:SetGuildIcon(self)
		self.follow_ui:SetLongXingIcon(self:GetAttr("JingJie"))
		self:GetFollowUi():SetIsShowGuildIcon(Scene.Instance:GetCurFbSceneCfg().guild_badge == 0) --0显示公会头像
		self:FlshHpVisiable()
	end
end

function Role:ReloadGuildIcon()
	if self.follow_ui ~= nil then
		self.follow_ui:SetGuildIcon(self)
		self:GetFollowUi():SetIsShowGuildIcon(Scene.Instance:GetCurFbSceneCfg().guild_badge == 0) --0显示公会头像
	end
end

function Role:ReloadUIGuildName()
	if self.follow_ui ~= nil then
		local guild_id = self:GetVo().guild_id
		if guild_id > 0 then
			local guild_name = self:GetVo().guild_name
			guild_name = ToColorStr(guild_name, TEXT_COLOR.GREEN)
			guild_name = "[" .. guild_name .. "]"
			local post = GuildData.Instance:GetGuildPostNameByPostId(self:GetVo().guild_post)
			if post then
				guild_name = guild_name .. post
			end
			self.follow_ui:SetGuildName(guild_name)
		else
			self.follow_ui:SetGuildName("")
		end
	end
end


function Role:ReloadUILoverName()
	if self.follow_ui ~= nil then
		local lover_name = self:GetVo().lover_name
		if lover_name and lover_name ~= "" then
			lover_name = "[" .. lover_name .. "]" .. (Language.Marriage.LoverNameFormat[self:GetVo().sex])
			lover_name = ToColorStr(lover_name, TEXT_COLOR.PINK)
			self.follow_ui:SetLoverName(lover_name)
		else
			self.follow_ui:SetLoverName()
		end
	end
end


function Role:ReloadBianShenImage()
	if self.vo == nil or self.vo.appearance == nil or not self:IsMainRole() or nil == self.follow_ui then
		return
	end
	
	if self.vo.task_appearn == CHANGE_MODE_TASK_TYPE.TALK_IMAGE then
		local height = self:GetLookAtPointHeight(AttachPoint.UI, 90)
		self.follow_ui:SetTemporaryEffectObj("uis/views/taskview/animations_prefab", "Title_tf_chicken", 0, height)
	else
		if self.vo.task_appearn and not(self.vo.task_appearn_param_1 > 0) then
			self.follow_ui:RemoveTemporaryEffectObj()
		end
	end
end

function Role:ReloadSpecialImage()
	local scene_logic = Scene.Instance:GetSceneLogic()
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()

	local is_show_special_image, asset, bundle, scale
	if scene_logic then
		is_show_special_image, asset, bundle, scale = scene_logic:GetIsShowSpecialImage(self)
	end

	local scene_type = Scene.Instance:GetSceneType()
	if (self.vo.top_dps_flag and self.vo.top_dps_flag > 0) or (self.vo.first_hurt_flag and self.vo.first_hurt_flag > 0) then
		is_show_special_image, asset, bundle = true, ResPath.GetDpsIcon()
	end
	self.is_show_special_image = is_show_special_image
	if self.follow_ui and fb_scene_cfg.pb_bossAttribution and fb_scene_cfg.pb_bossAttribution ~= 1 then
		if scene_type == SceneType.KF_NightFight then
			if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.KF_TUANZHAN) then
				self.follow_ui:SetSpecialImage(is_show_special_image, asset, bundle)
			end
		elseif scene_type == SceneType.LuandouBattle then
			if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.KF_LUANDOUBATTLE) or ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.LUANDOUBATTLE) then
				self.follow_ui:SetSpecialImage(is_show_special_image, asset, bundle)
			end
		else
			self.follow_ui:SetSpecialImage(is_show_special_image, asset, bundle)
		end
		if scale then
			self.follow_ui:SetSpecialScale(scale)
		end
	end


	-- 乱斗战场 和神魔之境图标需要特殊处理
	if (scene_type == SceneType.LuandouBattle and ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.KF_LUANDOUBATTLE) or ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.LUANDOUBATTLE)) or 
		(scene_type == SceneType.KF_NightFight and ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.KF_TUANZHAN)) then
		if scene_logic.GetSpecialImgPos then
			local pos_x, pos_y = scene_logic:GetSpecialImgPos()
			if self.follow_ui and pos_x and pos_y then
				self.follow_ui:SetSpecialPosition(pos_x, pos_y)
				self.follow_ui:SetSpecialImage(is_show_special_image, asset, bundle)
				if scale then
					self.follow_ui:SetSpecialScale(scale)
				end
			end
		end
	end
	-- 神魔之境 积分位置特殊处理
	if scene_type == SceneType.KF_NightFight or scene_type == SceneType.LuandouBattle then
		local pos_x = scene_logic:GetRoleScorePos()
		if pos_x and self.follow_ui then
			self.follow_ui:SetRoleScorePosition(pos_x)
		end
	end 
end

function Role:AddBaoJuEffect(asset_bundle, name, time)
	if not asset_bundle or not name then
		return
	end

	local is_shield_self = SettingData.Instance:GetSettingData(SETTING_TYPE.SELF_SKILL_EFFECT)
	if is_shield_self then
		if self:IsMainRole() then
			return
		end
	end
	local is_shield_other = SettingData.Instance:GetSettingData(SETTING_TYPE.SKILL_EFFECT)
	if is_shield_other then
		if not self:IsMainRole() then
			return
		end
	end

	local baoju_part = self.draw_obj:GetPart(SceneObjPart.BaoJu)
	if baoju_part then
		if self.baoju_effect == nil then
			local bj_obj = baoju_part:GetObj()
			if bj_obj then
				self.baoju_effect = self.baoju_effect or AllocAsyncLoader(self, "baoju_effect_loader")
				self.baoju_effect:SetParent(bj_obj.transform)
				self.baoju_effect:Load(asset_bundle, name)
				self.time_quest = GlobalTimerQuest:AddDelayTimer(function()
					self.baoju_effect:Destroy()
					self.baoju_effect:DeleteMe()
					self.baoju_effect = nil end, time or 1)
			end
		end
	end
end


--初始化跨服修罗塔无敌采集称号
function Role:InitXiuLuoWuDiGather()
	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic then
		if scene_logic:GetSceneType() == SceneType.Kf_XiuLuoTower then
			if not self:CheckXiuLuoBuff() then
				self:GetFollowUi():ChangeSpecailTitle(nil)
			 	return
			end
			local str = "wudi_gather"
			self:GetFollowUi():ChangeSpecailTitle(str)
		end
	end
end

--改变跨服修罗塔无敌采集称号
function Role:ChangeXiuLuoWuDiGather(shuijing_buff)
	if not self:CheckXiuLuoBuff(shuijing_buff) then
		self:GetFollowUi():ChangeSpecailTitle(nil)
		return
	end
	local str = "wudi_gather"
	self:GetFollowUi():ChangeSpecailTitle(str)
end

--检测是否有跨服修罗塔buff
function Role:CheckXiuLuoBuff(shuijing_buff)
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type ~= SceneType.Kf_XiuLuoTower then
	 	return false
	end

	if shuijing_buff ~= nil then
		return shuijing_buff == 1
	end

	if self:IsMainRole() then
		local gather_buff_time =  KuaFuXiuLuoTowerData.Instance:GetBossGatherEndTime() or 0
		return gather_buff_time > TimeCtrl.Instance:GetServerTime()
	else
		return self.vo.special_param == 1
	end
	return true
end

-- 武器为红色时，更换武器模型
function Role:EquipDataChangeListen()
	local value = BianShenData.Instance:GetCurUseSeq()
	if value ~= -1 then 		-- 变身状态时，采集动作不要刷武器
		return
	end
	self:UpdateAppearance()
	if self.weapon_res_id ~= 0 then
		self:ChangeModel(SceneObjPart.Weapon, ResPath.GetWeaponModel(self.weapon_res_id))
	end

	if self.weapon2_res_id ~= 0 then
		self:ChangeModel(SceneObjPart.Weapon2, ResPath.GetWeaponModel(self.weapon2_res_id))
	end
end

function Role:SetWeaponEffect(part, obj)
	if not obj or (part ~= SceneObjPart.Weapon and part ~= SceneObjPart.Weapon2) then return end
	if self.vo == nil or self.vo.appearance == nil then
		return
	end
	if self.vo.appearance and self.vo.appearance.fashion_wuqi and self.vo.appearance.fashion_wuqi == 0 and self.vo.wuqi_color >= GameEnum.ITEM_COLOR_RED then
		local bundle, asset = ResPath.GetWeaponEffect(self.weapon_res_id)
		if self.weapon_effect_name and self.weapon_effect_name ~= asset then
			if self.weapon_effect then
				ResPoolMgr:Release(self.weapon_effect)
				self.weapon_effect = nil
			end
		end
		if bundle and asset and not self.weapon_effect and not self.is_load_effect then
			self.is_load_effect = true

			ResPoolMgr:GetDynamicObjAsyncInQueue(bundle, asset, function (effct_obj)
				if nil == effct_obj then return end
				self.weapon_effect = effct_obj.gameObject
				effct_obj.transform:SetParent(obj.transform, false)
				if self.draw_obj then
					obj.gameObject:SetLayerRecursively(self.draw_obj.root.gameObject.layer)
				end
				self.weapon_effect_name = asset
				self.is_load_effect = false
			end)
		end
		if part == SceneObjPart.Weapon2 then
			local bundle, asset = ResPath.GetWeaponEffect(self.weapon2_res_id)
			if self.weapon2_effect_name and self.weapon2_effect_name ~= asset then
				if self.weapon2_effect then
					ResMgr:Destroy(self.weapon2_effect)
					self.weapon2_effect = nil
				end
			end
			if bundle and asset and not self.weapon2_effect and not self.is_load_effect2 then
				self.is_load_effect2 = true
				ResPoolMgr:GetDynamicObjAsyncInQueue(bundle, asset, function (effct_obj)
					if nil == effct_obj then return end
					self.weapon2_effect = effct_obj.gameObject
					effct_obj.transform:SetParent(obj.transform, false)
					if self.draw_obj then
						obj.gameObject:SetLayerRecursively(self.draw_obj.root.gameObject.layer)
					end
					self.is_load_effect2 = false
					self.weapon2_effect_name = asset
				end)
			end
		end
	else
		if self.weapon_effect then
			ResPoolMgr:Release(self.weapon_effect)
			self.weapon_effect = nil
		end
		if self.weapon2_effect then
			ResPoolMgr:Release(self.weapon2_effect)
			self.weapon2_effect = nil
		end
	end
end

function Role:OnModelLoaded(part, obj)
	Character.OnModelLoaded(self, part, obj)
	if self:IsMainRole() then
		if part == SceneObjPart.Mount then
			if self.mount_res_id == nil or self.mount_res_id <= 0 then
				if not self:TaskIsFly() and not self:GetIsFlying() then
					self:RemoveModel(SceneObjPart.Mount)
				end
			elseif self.show_fade_in then
				self.show_fade_in = false
				local mount_part = self.draw_obj:GetPart(SceneObjPart.Mount)
				mount_part:RemoveOcclusion()
				local call_back = function()
					if mount_part then
						GlobalTimerQuest:AddDelayTimer(function()
							mount_part:AddOcclusion()
						end, 0)
					end
				end
				self:PlayMountFade(1, 1, call_back)
			end
			self:FixMeshRendererBug()
		end
		if part == SceneObjPart.Main then
			local logic = Scene.Instance:GetSceneLogic()
			if self:IsAtk() or (logic and not logic:CanCancleAutoGuaji()) then
				self:OnAnimatorEnd()
			end
			for _, v in pairs(self.animator_handle_t) do
				v:Dispose()
			end
			self.animator_handle_t = {}
		end
	end
	if part == SceneObjPart.Main then
		local boat_obj = Scene.Instance:GetBoatByRole(self:GetObjId())
		if boat_obj then
			self.draw_obj:GetPart(SceneObjPart.Main):SetInteger(ANIMATOR_PARAM.STATUS, 2)
			local point = boat_obj:GetBoatAttachPoint(self:GetObjId())
			if point then
				obj.gameObject.transform:SetParent(point, false)
				obj.gameObject.transform:SetLocalPosition(0,0,0)
				obj.gameObject.transform.rotation = Vector3(0,0,0)
				obj.gameObject.transform:SetLocalScale(1,1,1)
			end
		end

		self:UpdateFaZhenAttach()
		self:CheckDanceState()
		self.is_landed = true
	elseif part == SceneObjPart.Mount or part == SceneObjPart.FightMount then
		self:UpDateWeiYanResid()
		self:ChangeWeiYan()
	end
end

-- 角色更换时装，重新设置法阵挂点（法阵屏蔽）
function Role:UpdateFaZhenAttach()
	if nil == self.fazhen_res_id or "" == self.fazhen_res_id then
		return
	end
	local attachment = self.draw_obj:_TryGetPartAttachment(SceneObjPart.Main)
	if attachment ~= nil then
		local fazhen_part = self.draw_obj:GetPart(SceneObjPart.FaZhen)
		local fazhen_obj = fazhen_part and fazhen_part:GetObj()
		if nil ~= fazhen_obj then
			fazhen_obj.gameObject:SetActive(true)
			local point = attachment:GetAttachPoint(AttachPoint.HurtRoot)
			if not IsNil(point) then
				fazhen_obj.attach_obj:SetAttached(point)
				fazhen_obj.attach_obj:SetTransform(attachment.Prof)
			end
		end
	end
end

function Role:OnModelRemove(part, obj)
	Character.OnModelRemove(self, part, obj)
	if part == SceneObjPart.Main then
		if SimpleShadow ~= nil then
			local simple_shadow = obj.gameObject:GetComponent(typeof(SimpleShadow))
			if simple_shadow then
				self:GetOrAddSimpleShadow()
				if self.simple_shadow then
					self.simple_shadow.enabled = not self.role_is_visible
					self.simple_shadow.ShadowMaterial = simple_shadow.ShadowMaterial
					self.simple_shadow.GroundMask = simple_shadow.GroundMask
					self.simple_shadow.Offset = simple_shadow.Offset
					self.simple_shadow.ScaleDistance = simple_shadow.ScaleDistance
					self.simple_shadow.ShadowSize = simple_shadow.ShadowSize
				end
			end
		end
	end
end

-- 带渐变效果移除坐骑
function Role:RemoveMonutWithFade()
	if not self:IsMainRole() then
		self:RemoveModel(SceneObjPart.Mount)
		return
	end
	-- 坐骑渐变
	local mount_part = self.draw_obj:GetPart(SceneObjPart.Mount)
	if nil ~= mount_part and mount_part:GetObj() then
		mount_part:Reset()
		local obj = mount_part:GetObj()
		if mount_part.remove_callback ~= nil then
			mount_part.remove_callback(obj)
			mount_part.remove_callback = nil
		end
		local call_back = function() mount_part:RemoveModel() mount_part:DeleteMe() end
		local fade_time = 1
		self.show_fade_out = false
		self:PlayMountFade(0, fade_time, call_back)
		if obj and obj.gameObject then
			self:DoMountRun(obj.gameObject, fade_time, 10)
			-- 下马特效
			self:DestroyXiaMaEffect()
			self:RemoveXiamaDelay()
			self.xiama_effect = AllocAsyncLoader(self, "xiamatexiao")
			self.xiama_effect:SetParent(self:GetRoot().transform)
			self.xiama_effect:SetIsUseObjPool(true)
			local bundle_name, asset_name = ResPath.GetMiscEffect("xiamatexiao")
			self.xiama_effect:Load(bundle_name, asset_name)
			self.xiama_delay_time = GlobalTimerQuest:AddDelayTimer(function() self:DestroyXiaMaEffect() end, 5)
		end
		self.draw_obj.part_list[SceneObjPart.Mount] = nil
	end
end

-- 坐骑渐变
function Role:PlayMountFade(fade_type, fade_time, call_back)
	local mount_part = self.draw_obj:GetPart(SceneObjPart.Mount)
	if nil ~= mount_part then
		local mount_obj = mount_part:GetObj()
		if mount_obj == nil then
			call_back()
			return
		end
		local fadeout = mount_obj.actor_fadout
		if fadeout ~= nil then
			if fade_type == 0 then
				fadeout:Fadeout(fade_time, call_back)
			elseif fade_type == 1 then
				fadeout:Fadein(fade_time, call_back)
			end
		else
			call_back()
		end
	end
end

-- 坐骑位移
function Role:DoMountRun(obj, time, distance)
	if obj and obj.transform then
		local anim = obj:GetComponent(typeof(UnityEngine.Animator))
		if anim == nil then
			return
		end
		local target_pos = obj.transform.position + obj.transform.forward * distance
		if not self.game_root then
			self.game_root = GameObject.Find("GameRoot/SceneObjLayer")
		end
		if self.game_root then
			obj.transform:SetParent(self.game_root.transform, true)
		end
		anim:SetInteger(ANIMATOR_PARAM.STATUS, 1)
		local tween = obj.transform:DOMove(target_pos, time)
		tween:SetEase(DG.Tweening.Ease.Linear)
	end
end

-- 移除下马特效
function Role:DestroyXiaMaEffect()
	if self.xiama_effect ~= nil then
		self.xiama_effect:DeleteMe()
		self.xiama_effect = nil
	end
end

-- 清除下马特效延迟
function Role:RemoveXiamaDelay()
	if self.xiama_delay_time ~= nil then
		GlobalTimerQuest:CancelQuest(self.xiama_delay_time)
		self.xiama_delay_time = nil
	end
end

function Role:GetOrAddSimpleShadow()
	if SimpleShadow ~= nil and self.draw_obj then
		self.simple_shadow = self.draw_obj:GetRoot().gameObject:GetOrAddComponent(typeof(SimpleShadow))
	end
end

function Role:UpdateRoleFaZhen()
	if self.vo == nil or self.vo.appearance == nil then
		return
	end
	local eternity_level = self.vo.appearance and self.vo.appearance.use_eternity_level or 0
	local suit_cfg = nil
	-- if nil == ForgeData.Instance then
	-- 	suit_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("equipforge_auto").eternity_suit, "suit_level")
	-- else
		suit_cfg= ForgeData.Instance:GetEternitySuitCfg(eternity_level)
	-- end

	if nil == suit_cfg then return end

	self.fazhen_res_id = suit_cfg.fazhen
end

-- 法阵屏蔽
function Role:ChangeFaZhen()
	-- 人物法阵
	-- if nil ~= self.fazhen_res_id and self.fazhen_res_id ~= "" and self.fight_mount_res_id == 0 and self.mount_res_id == 0 then
	-- 	self:ChangeModel(SceneObjPart.FaZhen, ResPath.GetZhenfaEffect(self.fazhen_res_id))
	-- end
end

-- 修复MeshRenderer被隐藏的bug
function Role:FixMeshRendererBug()
	if self.draw_obj then
		-- 取到身上所有部件
		for k,v in pairs(SceneObjPart) do
			local part_obj = self.draw_obj:_TryGetPartObj(v)
			if part_obj then
				local mesh_renderer_list = part_obj.gameObject:GetComponentsInChildren(typeof(UnityEngine.SkinnedMeshRenderer))
				-- 把每个meshRenderer的Enabled强制设为true
				for i = 0, mesh_renderer_list.Length - 1 do
					local mesh_renderer = mesh_renderer_list[i]
					if mesh_renderer then
						mesh_renderer.enabled = true
					end
				end
			end
		end
	end
end

------------------------双人坐骑-------------------------------------

--双人坐骑搭档位置刷新
function Role:UpdateMultiMountParnter(now_time, elapse_time)
	if self.is_in_multi_mount and self:IsMultiMount() and self:IsMultiMountPartner() and self.draw_obj then
		local main_part = self.draw_obj:_TryGetPart(SceneObjPart.Main)
		if main_part then
			if self.is_sit_mount2 == 0 then
				self:UpDateMountLayer(1, 0, 0)
			elseif self.is_sit_mount2 == 1 then
				self:UpDateMountLayer(0, 1, 0)
			else
				self:UpDateMountLayer(0, 0, 1)
			end
		end

		local root_transform = self.draw_obj.root.transform
		if not IsNil(root_transform) then
			if self.is_sit_mount2 == 0 or self.is_sit_mount2 == 2 then
				self.draw_obj.root.transform.localPosition = Vector3(0, -1.7, 0)
			else
				self.draw_obj.root.transform.localPosition = Vector3(0, 0, 0)
			end
			self.draw_obj.root.transform.localRotation = Quaternion.Euler(0, 0, 0)
			-- self.draw_obj.root.transform.localScale = Vector3(1, 1, 1)
			if self.is_parnter then
				self.draw_obj.root.transform.localScale = self.record_scale or Vector3(1, 1, 1)
			end
		end
	end
end

function Role:SetMultiMountIdAndOnwerFlag(multi_mount_res_id, multi_mount_is_owner, multi_mount_other_uid)
	local old_is_parnter = self:IsMultiMountPartner()
	local old_multi_mount_res_id = self.vo.multi_mount_res_id

	self:SetAttr("multi_mount_res_id", multi_mount_res_id)
	self:SetAttr("multi_mount_is_owner", multi_mount_is_owner)
	self:SetAttr("multi_mount_other_uid", multi_mount_other_uid)
	-- 有双人坐骑不显示羽翼
	if self:IsMultiMount() then
		self:RemoveModel(SceneObjPart.Wing)
		self.is_sit_mount, self.is_sit_mount2 = MultiMountData.Instance:GetMultiMountSitTypeByResid(multi_mount_res_id)
	-- 下双人坐骑时恢复
	elseif old_multi_mount_res_id > 0 then
		local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
		if self.wing_res_id ~= nil and self.wing_res_id ~= 0 and fb_scene_cfg.pb_wing ~= 1 and self.vo.multi_mount_res_id <= 0 then
			self:ChangeModel(SceneObjPart.Wing, ResPath.GetWingModel(self.wing_res_id))
		end
	end
	self.is_parnter = self.vo.multi_mount_other_uid > 0 and self.vo.multi_mount_is_owner == 0
	if old_is_parnter and not self.is_parnter then
		--不是跟随者了，下坐骑
		self:MultiMountPartnerDown()
	elseif not old_is_parnter and self.is_parnter then
		-- 是跟随者，上坐骑
		self:MultiMountParentUp()
	else
		self:UpdateMountAnimation()
	end
	self.partner_point = nil
	self.multi_mount_owner_role = nil

	MountCtrl.Instance:MultiMountFlushMountState()

	if self:IsMainRole() then
		self:CheckQingGong()
	end
end

-- 是否跟随者
function Role:IsMultiMountPartner()
	return self.is_parnter
end

function Role:SetMountOtherObjId(mount_other_objid)
	self.mount_other_objid = mount_other_objid
	-- self:SetRoleVisible()
end

-- 跟随者下坐骑
function Role:MultiMountPartnerDown()
	if not self.is_in_multi_mount or not self.draw_obj then
		return
	end

	self.is_in_multi_mount = false
	local sceneobj_layer = self:GetSceneObjLayer()
	self.draw_obj.root.transform:SetParent(sceneobj_layer)
	self.draw_obj.root.transform.localScale = Vector3(1, 1, 1)
	self.draw_obj.root.transform.localRotation = Quaternion.Euler(0, 0, 0)

	--这个重置位置由服务器做
	-- local logic_x, logic_y = self:GetLogicPos()
	-- self:SetLogicPos(logic_x, logic_y)

	self:UpdateMountAnimation()
	if self.mount_res_id <= 0 then
		self:UpDateMountLayer(0, 0, 0)
	end
end

-- 双人坐骑跟随者上坐骑
function Role:MultiMountParentUp()
	if self.is_in_multi_mount then
		return
	end

	if self:IsMultiMountPartner() then
		self.multi_mount_owner_role = self:GetMountOwnerRole()
		if self.multi_mount_owner_role then
			if not self:IsRoleVisible()then
				self:SetRoleVisible()
			end
			local draw_obj = self.multi_mount_owner_role.draw_obj

			-- 双人坐骑有些坐骑是战斗坐骑挂点，有些是坐骑挂点
			local mount_part = nil

			-- if 1 == MultiMountData.Instance:GetMultiMountSitTypeByResid(self.vo.multi_mount_res_id) then
			-- 	mount_part = draw_obj:GetPart(SceneObjPart.FightMount)
			-- else
			-- 	mount_part = draw_obj:GetPart(SceneObjPart.Mount)
			-- end
			-- if mount_part == nil or mount_part:GetObj() == nil then
			-- 	return
			-- end

			local mount_part_obj = draw_obj:_TryGetPartObj(SceneObjPart.Mount) or draw_obj:_TryGetPartObj(SceneObjPart.FightMount)
			-- local mount_part_obj = mount_part:GetObj()
			if mount_part_obj then
				self.is_in_multi_mount = true
				self:RemoveModel(SceneObjPart.Mount)
				self.partner_point = mount_part_obj.transform:FindByName("mount_point001")
				self.draw_obj:StopMove()
				self.draw_obj:StopRotate()
				if self.partner_point then
					self.draw_obj.root.transform:SetParent(self.partner_point.transform)
					self.record_scale = self.draw_obj.root.transform.localScale
				end
			end
		end
	end
end

-- 是否使用第二个坐骑动作
function Role:IsMountLayer2()
	return self.is_sit_mount == 2
end

-- 是否双人坐骑
function Role:IsMultiMount()
	return self.vo.multi_mount_res_id and self.vo.multi_mount_res_id > 0
end

------------------------------------------------------------
-- 参数可以传过来挂点 和 默认高度
function Role:GetLookAtPointHeight(attach_point, height)
	attach_point = attach_point or AttachPoint.BuffTop
	height = height or 2
	local point = self.draw_obj:GetAttachPoint(attach_point)
	if point and not IsNil(point.gameObject) then
		local root = self.draw_obj:GetRoot()
		if root and not IsNil(root.gameObject) then
			height = point.transform.position.y - root.transform.position.y
		end
	end
	return height
end

function Role:SetLogicPos(pos_x, pos_y)
	if not self.is_parnter then
		Character.SetLogicPos(self, pos_x, pos_y)
	else
		self:SetLogicPosData(pos_x, pos_y)
	end
end

function Role:GetMoveSpeed()
	local speed = Scene.ServerSpeedToClient(self.vo.move_speed) + self.special_speed
	if self.is_jump or self.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		if self.vo.jump_factor then
			speed = self.vo.jump_factor * speed
		else
			speed = 1.8 * speed
		end
	end

	if self.is_chongci then
		speed = COMMON_CONSTS.CHONGCI_SPEED
	end
	return speed
end

function Role:OnClick()
	Character.OnClick(self)
	self:FlshHpVisiable()
end

function Role:DoMove(pos_x, pos_y, is_chongci)
	self.is_chongci = is_chongci
	self:ChangeChongCi(is_chongci)
	if not self.is_parnter then
		Character.DoMove(self, pos_x, pos_y)
	else
		-- self:SetRealPos(pos_x, pos_y)
	end
end

function Role:SetDirectionByXY(x, y)
	if not self.is_parnter then
		Character.SetDirectionByXY(self, x, y)
	end
end

function Role:GetMountOwnerRole()
	if nil == self.vo.multi_mount_is_owner or nil == self.mount_other_objid then
		return nil
	end
	if self.vo.multi_mount_is_owner == 0 and self.mount_other_objid >= 0 then
		local owner_role = self.parent_scene:GetRoleByObjId(self.mount_other_objid)
		if nil ~= owner_role and owner_role:GetRoleId() == self.vo.multi_mount_other_uid then
			return owner_role
		end
	end
	return nil
end

function Role:GetMountParnterRole()
	if nil == self.vo.multi_mount_is_owner or nil == self.mount_other_objid then
		return nil
	end
	
	if self.vo.multi_mount_is_owner ~= 0 and self.mount_other_objid >= 0 then
		local partner_role = self.parent_scene:GetRoleByObjId(self.mount_other_objid)
		if nil ~= partner_role and partner_role:GetRoleId() == self.vo.multi_mount_other_uid then
			return partner_role
		end
	end
	return nil
end

function Role:UpdateMountAnimation()
	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	self:UpdateMount()
	self:UpdateFightMount()
	if main_part then
		if nil ~= self.mount_res_id and self.mount_res_id ~= "" and self.mount_res_id > 0 then
			if self.is_sit_mount then
				if self.is_sit_mount == 0 then
					self:UpDateMountLayer(1, 0, 0)
				elseif self.is_sit_mount == 1 then
					self:UpDateMountLayer(0, 1, 0)
				else
					self:UpDateMountLayer(0, 0, 1)
				end
			end
		elseif nil ~= self.fight_mount_res_id and self.fight_mount_res_id ~= "" and self.fight_mount_res_id > 0 then

		else
			self:UpDateMountLayer(0, 0, 0)
		end
		main_part:EnableMountUpTrigger(false)
		self:OnMountUpEnd()
	end
end

-- 是否巡游者
function Role:SetMarryFlag(state)
	self.is_xunyou = state ~= 0
	if not self.xun_you_state then
		self.xun_you_state = self.is_xunyou
	end
	self.draw_obj:SetVisible(not self.is_xunyou, function() self:InitWaterState() end)
	self.role_is_visible = not self.is_xunyou
	self:SetTitleVisible(not self.is_xunyou)
	self:SetGoddessVisible(not self.is_xunyou)
	self:SetSpriteVisible(not self.is_xunyou)
	self:SetLingChongVisible(not self.is_xunyou)
	self:SetFlyPetVisible(not self.is_xunyou)
	self:SetPetVisible(not self.is_xunyou)
	self:SetBabyVisible(not self.is_xunyou)
	local follow_ui = self:GetFollowUi()
	if follow_ui then
		if self.is_xunyou then
			follow_ui:Hide()
		else
			follow_ui:Show()
		end
	end

	if not self.is_xunyou then
		self:GetOrAddSimpleShadow()
	end
	if self.simple_shadow ~= nil then
		if not self.is_xunyou then
			self.simple_shadow.enabled = false
		else
			self.simple_shadow.enabled = true
		end
	end
	if not self.is_xunyou and not self:IsMultiMount() then
		self.draw_obj.root.transform:SetParent(SceneObjLayer)
		self.draw_obj.root.transform.localScale = Vector3(1, 1, 1)
		self.partner_point2 = nil
		self.update_marry_time = 0

		if self.xun_you_state then
			if self.vo and self.vo.sex == 0 then
				self.draw_obj.root.transform.localPosition = Vector3(-34.5, 52.746, -1.5)
			else
				self.draw_obj.root.transform.localPosition = Vector3(-34.5, 52.746, 7.5)
			end
		end
	end
	self.xun_you_state = self.is_xunyou
end

function Role:SetFollowLocalPosition(high)
	local follow_ui = self:GetFollowUi()
	local setting_data = SettingData.Instance
	local shield_others = setting_data:GetSettingData(SETTING_TYPE.SHIELD_OTHERS)
	local shield_friend = setting_data:GetSettingData(SETTING_TYPE.SHIELD_SAME_CAMP)

	local temp_high = ((self.is_role_shield_optimize or shield_others or (shield_friend and not Scene.Instance:IsEnemy(self))) and not self:IsMainRole()) and 100 or 0
	local high = temp_high

	local attach_point = self.draw_obj:GetAttachPoint(AttachPoint.UI)
	if follow_ui and attach_point then
		follow_ui:SetFollowTarget(attach_point, self.draw_obj:GetName())
		follow_ui:SetLocalUI(0, high, 0)
		follow_ui:SetHpBarLocalPosition(0, 10, 0)
		follow_ui:SetNameTextPosition()
	end
end

function Role:StopHug()
	self:RemoveModel(SceneObjPart.HoldBeauty)
	local holdbeauty_part = self.draw_obj:GetPart(SceneObjPart.HoldBeauty)
	if holdbeauty_part then
		holdbeauty_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Idle)
	end
end

--怀抱中的资源id
function Role:UpdateHoldBeauty()
	self.hug_res_id = 0
	local obj_cfg = nil
	if self.vo.task_appearn == CHANGE_MODE_TASK_TYPE.GATHER then
		obj_cfg = ConfigManager.Instance:GetAutoConfig("gather_auto").gather_list[self.vo.task_appearn_param_1]
	elseif self.vo.task_appearn == CHANGE_MODE_TASK_TYPE.TALK_TO_NPC then
		obj_cfg = ConfigManager.Instance:GetAutoConfig("npc_auto").npc_list[self.vo.task_appearn_param_1]
	end
	if obj_cfg and obj_cfg.resid and obj_cfg.resid ~= "" and obj_cfg.resid > 0 then
		self.hug_res_id = obj_cfg.resid
	end
end

-- 是否可以抱东西
function Role:CanHug()
	return Scene.Instance:GetSceneType() == 0 and self.vo.task_appearn > 0 and self.vo.task_appearn < CHANGE_MODE_TASK_TYPE.TALK_IMAGE
	and self.vo.task_appearn_param_1 > 0 and self.is_jump == false and not self:IsDead() and not self.is_gather_state
	or (GuildData.Instance and GuildData.Instance:GetHugState() == 1
		and Scene.Instance:GetSceneType() == SceneType.GuildStation
		and self.is_jump == false and not self:IsDead() and not self.is_gather_state)
end

function Role:DoHug()
	if GuildData.Instance and GuildData.Instance:GetGatherID() ~= 0 then
		local obj_cfg = ConfigManager.Instance:GetAutoConfig("gather_auto").gather_list[GuildData.Instance:GetGatherID()]
		if obj_cfg and obj_cfg.resid and obj_cfg.resid ~= "" and obj_cfg.resid > 0 then
			self.hug_res_id = obj_cfg.resid
		end
		self:ChangeModel(SceneObjPart.HoldBeauty, ResPath.GetGatherModel(self.hug_res_id))
	elseif self.vo.task_appearn == CHANGE_MODE_TASK_TYPE.GATHER then
		self:ChangeModel(SceneObjPart.HoldBeauty, ResPath.GetGatherModel(self.hug_res_id))
	elseif self.vo.task_appearn == CHANGE_MODE_TASK_TYPE.TALK_TO_NPC then
		self:ChangeModel(SceneObjPart.HoldBeauty, ResPath.GetNpcModel(self.hug_res_id))	
	end
end

function Role:TaskIsFly()
	return self.vo.task_appearn == CHANGE_MODE_TASK_TYPE.CHANGE_MODE_TASK_TYPE_FLY 
	and self.vo.task_appearn_param_1 > 0 
	and SceneType.Common == Scene.Instance:GetSceneType()
	and self:IsMainRole()
end

function Role:EnterWater(is_in_water)
	Character.EnterWater(self, is_in_water)
	if self.draw_obj then
		local root = self.draw_obj:GetRoot()
		if root then
			local part = self.draw_obj:GetPart(SceneObjPart.Main)
			if is_in_water then
				if Scene.Instance:GetSceneType() == SceneType.HotSpring then
					part:SetLayer(ANIMATOR_PARAM.SWIMMING_LAYER, 1)
					part:SetLayer(ANIMATOR_PARAM.SWIMMINGACTION_LAYER, 1)
				end
			else
				if Scene.Instance:GetSceneType() == SceneType.HotSpring then
					part:SetLayer(ANIMATOR_PARAM.SWIMMING_LAYER, 0)
					part:SetLayer(ANIMATOR_PARAM.SWIMMINGACTION_LAYER, 0)
				end
			end
		end
	end
end

function Role:EnterStateStand()
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	if nil == part then
		return
	end
	if self.is_gather_state then
		if scene_type == SceneType.KF_Fish then
			--钓鱼特殊处理
			part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Gather)
		elseif self.is_fishing then
			part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.ShuaiGan)
			-- self.draw_obj:SetDirectionByXY(-282.25, -153.75) --捕鱼写死位置
		elseif self.is_kite then
			part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Kite)
		else
			part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Gather)
		end
		self:StopHug()
	else
		if self:CanHug() then
			part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Hug)
			self:DoHug()
			local holdbeauty_part = self.draw_obj:GetPart(SceneObjPart.HoldBeauty)
			if holdbeauty_part then
				holdbeauty_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.BeHug)
			end
		else
			part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Idle)
		end
	end
	local mount_part = self.draw_obj:GetPart(SceneObjPart.Mount)
	mount_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Idle)
	local fight_mount_part = self.draw_obj:GetPart(SceneObjPart.FightMount)
	fight_mount_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Idle)
end

function Role:UpdateStateStand(elapse_time)
	if self.shuibo_effect_time <= Status.NowTime then
		self:ShuiboEffectStop()
	end
end

function Role:EnterStateMove()
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	for i = 1, 3 do
		local layer = ANIMATOR_PARAM.DANCE1_LAYER - 1 + i
		if self.draw_obj then
			self.draw_obj:GetPart(SceneObjPart.Main):SetLayer(layer, 0)
		end
	end
	-- 抱美人
	if self:CanHug() then
		part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.HugRun)
		self:DoHug()
		local holdbeauty_part = self.draw_obj:GetPart(SceneObjPart.HoldBeauty)
		if holdbeauty_part then
			holdbeauty_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.BeHug)
		end
	else
		part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Run)
	end
	if Scene.Instance:GetSceneType() == SceneType.HotSpring then
		Scene.Instance:DeleteBoatByRole(self:GetObjId())
	end
	local mount_part = self.draw_obj:GetPart(SceneObjPart.Mount)
	mount_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Run)
	local fight_mount_part = self.draw_obj:GetPart(SceneObjPart.FightMount)
	if self.vo and self.vo.fight_mount_appeid then
		local is_rotation = FightMountData.Instance:GetFightMountIsRotationByImageId(self.vo.fight_mount_appeid)
		if not is_rotation then
			fight_mount_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Run)
		end
	end
end

function Role:UpdateStateMove(elapse_time)
	if self.delay_end_move_time > 0 then
		if Status.NowTime >= self.delay_end_move_time then
			self.delay_end_move_time = 0
			self:ChangeToCommonState()
		end
		return
	end
	if self.draw_obj then
		local part = self.draw_obj:GetPart(SceneObjPart.Main)
		if self:CanHug() then
			part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.HugRun)
			local holdbeauty_part = self.draw_obj:GetPart(SceneObjPart.HoldBeauty)
			if holdbeauty_part then
				holdbeauty_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.BeHug)
			end
		else
			part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Run)
		end

		--移动状态更新
		local distance = elapse_time * self:GetMoveSpeed()
		self.move_pass_distance = self.move_pass_distance + distance

		if self.move_pass_distance >= self.move_total_distance then
			self.is_special_move = false
			self:SetRealPos(self.move_end_pos.x, self.move_end_pos.y)

			if self:MoveEnd() then
				self.move_pass_distance = 0
				self.move_total_distance = 0
				if self:IsMainRole() then
					self.delay_end_move_time = Status.NowTime + 0.05
				elseif self:IsSpirit() then
					self.delay_end_move_time = Status.NowTime + 0.02
				else
					self.delay_end_move_time = Status.NowTime + 0.2
				end
			end
		else
			local mov_dir = u3d.v2Mul(self.move_dir, distance)
			self:SetRealPos(self.real_pos.x + mov_dir.x, self.real_pos.y + mov_dir.y)
		end
	end
end

function Role:ChangeChongCi(state)
	if self.draw_obj then
		local part = self.draw_obj:GetPart(SceneObjPart.Main)
		if nil ~= part then
			part:SetLayer(ANIMATOR_PARAM.CHONGCI_LAYER, state and 1 or 0)
		end
	end
end

function Role:EnterFightState(...)
	Character.EnterFightState(self, ...)
	self:ChangeFightState(true)
end

function Role:LeaveFightState(...)
	Character.LeaveFightState(self, ...)
	self:ChangeFightState(false)
end

function Role:ChangeFightState(state)
	self.is_enter_fight = state
	self:ChangeYaoShi()
	self:ChangeTouShi()
	self:ChangeMask()
	self:ChangeCloak()
	self:ChangeTail()
	self:ChangeFlyPet()
	self:ChangeShouHuan()
	self:FlshHpVisiable()
end

function Role:FlshHpVisiable()
	if nil ~= self:GetFollowUi() and not self:IsMainRole() then
		self:GetFollowUi():SetHpVisiable(self.is_select or self.is_enter_fight)
	end
end

-- 是否是主角的双骑伙伴
function Role:IsMainRoleParnter()
	local flag = false
	local role = self:GetMountParnterRole() or self:GetMountOwnerRole()
	if role and role:IsMainRole() then
		flag = true
	end
	return flag
end

function Role:CheckDanceState()
	if self.vo == nil or self.vo.appearance == nil or not self.draw_obj then
		return
	end
	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	local is_active = false
	local is_dead = self:IsDead()
	if self.vo.hp <= 0 then
		if main_part then
			if self.dance_delay_time then
				GlobalTimerQuest:CancelQuest(self.dance_delay_time)
				self.dance_delay_time = nil
			end
			for i = 1, 3 do
				if self.draw_obj then
					local layer = ANIMATOR_PARAM.DANCE1_LAYER - 1 + i
					self.draw_obj:GetPart(SceneObjPart.Main):SetLayer(layer, 0)
				end
			end
			if main_part then
				main_part:SetLayer(ANIMATOR_PARAM.DEATH_LAYER, 1)
			end
			 return
		end
	end
	for i = 1, 3 do
		local value = self.vo.appearance.baojia_texiao_id == i and 1 or 0
		local layer = ANIMATOR_PARAM.DANCE1_LAYER - 1 + i
		if (self.vo.mount_appeid and self.vo.mount_appeid > 0)
			or (self.vo.fight_mount_appeid and self.vo.fight_mount_appeid > 0)
			or self:IsMultiMount()
			or self.special_res_id ~= 0 then
			value = 0
		end
		if self.draw_obj then
			if main_part then
				main_part:SetLayer(layer, value)
			end
		end
		if value == 1 then
			is_active = true
		end
	end
	
	local info = ShenqiData.Instance:GetShenqiAllInfo()
	if is_active and info.texiao_open_flag == 0 then
		self:RandomDance()
	end
end

function Role:IsWarSceneState()
	return self.is_war_scene_state
end

function Role:SetWarSceneState(value)
	self.is_war_scene_state = value
end

function Role:RandomDance()
	if not self.dance_delay_time then
		self.dance_delay_time = GlobalTimerQuest:AddDelayTimer(function ()
			for i = 1, 3 do
				if self.draw_obj then
					local layer = ANIMATOR_PARAM.DANCE1_LAYER - 1 + i
					self.draw_obj:GetPart(SceneObjPart.Main):SetLayer(layer, 0)
				end
			end
			self.dance_delay_time = GlobalTimerQuest:AddDelayTimer(function ()
				self.dance_delay_time = nil
				self:CheckDanceState()
			end, math.random(5, 10))
		end, math.random(10, 20))
	end
	

end
function Role:UpdateHead()
	if SPECIAL_APPEARANCE_TYPE.SPECIAL_APPEARANCE_TYPE_SHNEQI == self.vo.special_appearance then
		if self.vo.appearance_param ~= nil and self.vo.appearance_param > 0 then
			local head_id = ShenqiData.Instance:GetHeadResId(self.vo.appearance_param)
			if head_id ~= nil then
				self:ChangeModel(SceneObjPart.Head, ResPath.GetHeadModel(head_id))
			end
		end
	else
		self:RemoveModel(SceneObjPart.Head)
	end
end

function Role:UpdateModel()
	self:SetAttr("appearance", self.vo.appearance)
end

function Role:GetFBExpByLevel(level)
	if level == nil then
		return exp_0
	end
	local role_exp_level_cfg = ConfigManager.Instance:GetAutoConfig("role_level_reward_auto").level_reward_list
	local exp_cfg = ListToMap(role_exp_level_cfg, "level")
	if exp_cfg[level] then
		return exp_cfg[level].exp_0
	end
end

function Role:DoJump(move_mode_param)
	Character.DoJump(self, move_mode_param)
end

function Role:DoJump2(move_mode_param)
	Character.DoJump2(self, move_mode_param)
end

function Role:OnJumpEnd()
	Character.OnJumpEnd(self)
end

---------------------------------------------------------------轻功相关--------------------------------------------------

function Role:JumpQingGongMount(prof)
	self.destroy_qinggong_mount = false

	-- local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	-- main_part:SetTrigger("QingGongDown")
	if CgManager.Instance:IsCgIng() then
		return
	end
	local bundle_mount, asset_mount = ResPath.GetFourJumpMount(prof)
	
	ResPoolMgr:GetDynamicObjAsync(bundle_mount, asset_mount, 
		function(obj)
			if IsNil(obj) then
				return
			end
			if not self.draw_obj then
				ResPoolMgr:Release(obj)
				return
			end

			if self.destroy_qinggong_mount then
				ResPoolMgr:Release(obj)
				return
			end

			if self.jump_qinggong_mount and not IsNil(self.jump_qinggong_mount) then
				ResPoolMgr:Release(self.jump_qinggong_mount)
				self.jump_qinggong_mount = nil
			end
			self.jump_qinggong_mount = obj

			local mount_point = obj.transform:FindByName("mount_point")
			local mount_y = mount_point.transform.localPosition.y
			local role_foot_point = self.draw_obj:GetAttachPoint(AttachPoint.HurtRoot)
			if role_foot_point then
				obj.transform:SetParent(role_foot_point.transform)
				obj.transform.localPosition = Vector3(0, QINGGONG_MOUNT_DIFF_Y[prof] - mount_y, 0)
				obj.transform.localRotation = Vector3(0, 0, 0)
			else
				self:ReleaseQingGongMount()
			end
		end)
end

function Role:Jump(qinggong_index)
	self:QingGongEnable(true)
	self.qinggong_index = qinggong_index
	self.is_landed = false
	self.is_force_landing = false
	self.has_play_qinggong_land = false

	local forward = self.draw_obj:GetRoot().gameObject.transform.forward
	local dir = Vector3(forward.x, 0, forward.z)
	local prof = PlayerData.Instance:GetRoleBaseProf(self.vo.prof)
	local qinggong_obj = ResPreload[string.format("QingGongObject%s_%s", prof, qinggong_index)]
	self.draw_obj:SimpleJump(qinggong_obj, u3d.v3Add(self:GetLuaPosition(), u3d.v3Mul(dir, 1000)))

	if qinggong_index == 1 then
		self.draw_obj:SetDrag(0.1)
	elseif qinggong_index == 2 then
		self.draw_obj:SetDrag(2)
	elseif qinggong_index == 3 then
		self.draw_obj:SetDrag(0.1)
	elseif qinggong_index == 4 then
		self.draw_obj:SetDrag(3)
	end

	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	main_part:SetTrigger("QingGong" .. qinggong_index)
	if self.qinggong_index == 4 then
		self:JumpQingGongMount(prof)
		-- main_part:SetTrigger("QingGongDown")
	end
	local jump_pos = self.draw_obj:GetRoot().gameObject.transform.position
	self:PlayJumpEffect(prof, jump_pos)
end

function Role:PlayJumpEffect(prof, pos)
	local jump_bundle, jump_asset = ResPath.GetRoleJumpEff(prof)
	if jump_bundle and jump_asset then
		EffectManager.Instance:PlayControlEffect(self, jump_bundle, jump_asset, pos)
	end
end

-- 从一半开始播放
function Role:Jump2(qinggong_index, dir, height, percent)
	self:QingGongEnable(true)
	self.qinggong_index = qinggong_index
	self.is_landed = false
	self.is_force_landing = false
	self.has_play_qinggong_land = false

	local target = u3d.v3Add(self:GetLuaPosition(), u3d.v3Mul(dir, 1000))

	local prof = PlayerData.Instance:GetRoleBaseProf(self.vo.prof)
	local qinggong_obj = ResPreload[string.format("QingGongObject%s_%s", prof, qinggong_index)]
	if nil ~= qinggong_obj then
		self.draw_obj:JumpFormAir(height, target, qinggong_obj, percent)
	else
		print_error("qinggong_obj is nil", qinggong_index, self.vo.prof, prof)
	end

	if qinggong_index == 1 then
		self.draw_obj:SetDrag(0.1)
	elseif qinggong_index == 2 then
		self.draw_obj:SetDrag(2)
	elseif qinggong_index == 3 then
		self.draw_obj:SetDrag(0.1)
	elseif qinggong_index == 4 then
		self.draw_obj:SetDrag(3)
	end

	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	main_part:Play("QingGongAir" .. qinggong_index, 0, 0)
end

function Role:Landing()
	if not self.is_landed then
		self.draw_obj:SetDrag(0.1)
		self.is_force_landing = true
		self.draw_obj:ForceLanding()
	end
end

function Role:QingGongStateChange(state)
	self.cur_qinggong_state = state
	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	if state == QingGongState.OnGround then
		if not self.is_landed then
			if self.qinggong_index < COMMON_CONSTS.MAX_QING_GONG_COUNT and not self.has_play_qinggong_land then
				main_part:SetTrigger("QingGongLand")
			end
		end
		self.qinggong_index = 0
	else
		self.is_landed = false
		if state == QingGongState.Down and self.qinggong_index < COMMON_CONSTS.MAX_QING_GONG_COUNT or self.is_force_landing then
			main_part:SetTrigger("QingGongDown")
		end

		if state == QingGongState.ReadyToGround then
			if self.is_force_landing then
				main_part:SetTrigger("QingGongLand")
				self.has_play_qinggong_land = true
			elseif self.qinggong_index == COMMON_CONSTS.MAX_QING_GONG_COUNT then
				main_part:SetTrigger("QingGongLand2")
			end
		end
	end
end

function Role:QingGongLandExit()
	self.is_landed = true
	local root = self.draw_obj.root
	self:SetRealPos(root.transform.position.x, root.transform.position.z)
	if self.move_target then
		if u3d.v2Length(u3d.v2Sub(self.move_target, self.logic_pos), false) > 1 then
			self:DoMove(self.move_target.x, self.move_target.y)
		end
		self.move_target = nil
	end
	self:ReleaseQingGongMount()
	self:QingGongEnable(false)
end

function Role:ReleaseQingGongMount()
	self.destroy_qinggong_mount = true
	if self.jump_qinggong_mount and not IsNil(self.jump_qinggong_mount) then
		ResPoolMgr:Release(self.jump_qinggong_mount)
		self.jump_qinggong_mount = nil
	end
end

function Role:QingGongEnable(enabled)
	self.draw_obj:QingGongEnable(enabled)
	if enabled and self.is_qinggong ~= enabled then
		self.draw_obj:SetStateChangeCallBack(BindTool.Bind(self.QingGongStateChange, self))
		self.draw_obj:SetGravityMultiplier(2)
		self.draw_obj:SetJumpHorizonSpeed(12)
		self.draw_obj:SetDrag(0.1)
	end

	self.is_qinggong = enabled
end

function Role:IsQingGong()
	return not self.is_landed
end

function Role:SaveMoveTarget(target)
	self.move_target = target
end

-- 播放角色身上变身特效展示
function Role:SetRoleBianShenEffect()
	if nil == self.draw_obj then
		return
	end

	local bundle, asset = ResPath.GetEffect("Effect_bianshen")
	local async_loader = AllocAsyncLoader(self, "effect_bianshen")
	async_loader:SetIsUseObjPool(true)
	async_loader:Load(bundle, asset, function(obj)
		if IsNil(obj) then
			async_loader:Destroy()
			return
		end

		local transform = self.draw_obj:GetTransfrom()
		if transform then
			local obj_transform = obj.transform
			obj_transform:SetParent(transform, false)
		else
			async_loader:Destroy()
		end
	end)
end

-- 设置模型拜谒时的动作和气泡框
function Role:SetRoleModeBaiYeAction()
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	if nil ~= part then
		for k,v in pairs(Scene.Instance:GetCgObjList()) do
			if v:GetRoot() then
				self:RotaToTarget(v:GetRoot().transform.position, 0.1)
				break
			end
		end

		part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Gather)
		local scene_type = Scene.Instance:GetSceneType()
		local is_click = ActivityData.Instance:GetIsInListByID(scene_type)
		if is_click then
			local content_cfg = ActivityData.Instance:GetBubbleContentById(scene_type)
			if content_cfg and next(content_cfg) then
				self:Say(content_cfg.bubble_text, content_cfg.disappear_time)
			end
		end
	end
	if self.delay_stop_baiye then
		GlobalTimerQuest:CancelQuest(self.delay_stop_baiye)
		self.delay_stop_baiye = nil
	end
	self.delay_stop_baiye = GlobalTimerQuest:AddDelayTimer(function ()
		part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Idle)
	end, 2)
end

local Vec3Zero = Vector3.zero
-- 旋转到目标
function Role:RotaToTarget(target_position, timer)
	local root_obj = self:GetRoot()
	if nil == root_obj then
		return
	end

	timer = timer or 0.5
	local position = root_obj.transform.position
	local direction = target_position - position
	direction.y = 0
	if direction ~= Vec3Zero then
		local rotation = Quaternion.LookRotation(direction).eulerAngles
		root_obj.transform:DORotate(rotation, timer)
	end
end

--更改精华护送时候的护送图标
function Role:ChangeJingHuaHuSong()
	-- 判断是否处于护送状态
	local husong_status = JingHuaHuSongData.Instance:GetHuSongStatus()
	local husong_type = JingHuaHuSongData.Instance:GetCurJingHuaType()
	local scene_type = Scene.Instance:GetSceneType()
	local is_show = false
	local str = ""
	if scene_type == SceneType.CrystalEscort then
		if self:IsMainRole() then
			if husong_status ~= JH_HUSONG_STATUS.NONE then
				local crystal_type = husong_type * 10
				if husong_type == 1 then
					str = "jinghua_husong_" .. husong_type .. husong_status
				else
					str = "jinghua_husong_" .. crystal_type .. husong_status
				end
				self:GetFollowUi():ChangeSpecailTitle(str)
				is_show = true
			end
		end
		if not is_show then
			self:GetFollowUi():ChangeSpecailTitle(nil)
		end
	end
end

function Role:OthersChangeJingHuaHuSong(shuijing_buff)
	local crystal_buff = shuijing_buff or self.vo.special_param
	local scene_type = Scene.Instance:GetSceneType()  
	if scene_type == SceneType.CrystalEscort then
		if not self:IsMainRole() then
			if crystal_buff ~= JH_HUSONG_STATUS.NONE then
				local str = ""
				if tonumber(crystal_buff) < 10 then
					str = "jinghua_husong_0" .. crystal_buff
				else
					str = "jinghua_husong_" .. crystal_buff
				end
				self:GetFollowUi():ChangeSpecailTitle(str)
			else
				self:GetFollowUi():ChangeSpecailTitle(nil)
			end
		end
	end
end
