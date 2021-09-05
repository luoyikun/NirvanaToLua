Monster = Monster or BaseClass(Character)

function Monster:__init(vo)
	self.obj_type = SceneObjType.Monster
	self.draw_obj:SetObjType(self.obj_type)
	self.draw_obj:SetIsDisableAllAttachEffects(false)
	self.is_boss = false
	self.res_id = 0
	self.head_id = 0
	self.is_skill_reading = false
	self.dps_target_name = ""
	self.effect_obj = nil
	self.time_quest = nil
	self.monster_up_time = 0
	self.is_first = false
	
	local cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.vo.monster_id]
	if nil ~= cfg then
		self.vo.name = cfg.name
		self.res_id = cfg.resid
		self.head_id = cfg.headid
		self.is_boss = (cfg.type == MONSTER_TYPE.BOSS)
		self.obj_scale = cfg.scale
		self.dietype = cfg.dietype
	end
	self.draw_obj.is_boss = self.is_boss

	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.LingyuFb then
		local guild_name = GuildFightData.Instance:GetGuildNameByPos(self.vo.monster_id, self.vo.pos_x, self.vo.pos_y)
		if guild_name ~= "" then
			self.vo.name = guild_name
		end
	end
end

function Monster:__delete()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	self.effect_obj = nil
end

local DecayMounstCount = 0
function Monster:DeleteDrawObj()
	if not self:IsRealDead() or DecayMounstCount > 10 then
		Character.DeleteDrawObj(self)
		return
	end

	if nil ~= self.draw_obj then
		local draw_obj = self.draw_obj
		self.draw_obj = nil
		if self.res_id ~= 3030001 and self.res_id ~= 3031001 and self.res_id ~= 3032001 then
			DecayMounstCount = DecayMounstCount + 1
			draw_obj:PlayDead(self.dietype, function()
				DecayMounstCount = DecayMounstCount - 1
				draw_obj:DeleteMe()
			end)
		else
			draw_obj:DeleteMe()
		end
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	self.monster_up_time = 0

end

function Monster:InitInfo()
	Character.InitInfo(self)
	self.dps_target_name = ""
	-- self.draw_obj:SetVisible(false)
	self:GetFollowUi()
	self.follow_ui:SetFollowTarget(self.draw_obj:GetRoot().transform, self.draw_obj:GetName())
	self.follow_ui:SetIsBoss(self:IsBoss())
	self:ReloadUIName()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.LingyuFb or scene_type == SceneType.Defensefb or self.vo.monster_id == 310 then --特殊处理名字
		self:ActiveFollowUi()
		self:ShowName()
	end
	-- 怪物如果是旗帜的话，根据下面的InitShow()来判断是否是旗帜
	if scene_type == SceneType.GongChengZhan then
		if self.vo.monster_id == ConfigManager.Instance:GetAutoConfig("gongchengzhan_auto").other[1].boss2_id then
			self:SetActorConfigPrefabData(ConfigManager.Instance:GetPrefabDataAutoConfig("QiZhi", self.res_id))
		end
	elseif scene_type == SceneType.CrossGuild then
		if self.vo.monster_id <= 4200 and self.vo.monster_id >= 4000 then
			self:SetActorConfigPrefabData(ConfigManager.Instance:GetPrefabDataAutoConfig("QiZhi", self.res_id))
		else
			self:SetActorConfigPrefabData(ConfigManager.Instance:GetPrefabDataAutoConfig("Monster", self.res_id))
		end
	elseif scene_type == SceneType.GuideFb or
			scene_type == SceneType.MountStoryFb or
			scene_type == SceneType.WingStoryFb or
			scene_type == SceneType.XianNvStoryFb then
		if self.vo.monster_id == 7501 then
			self:SetActorConfigPrefabData(ConfigManager.Instance:GetPrefabDataAutoConfig("QiZhi", self.res_id))
		end
	elseif scene_type == SceneType.LingyuFb then
		-- if self.vo.monster_id == 60052 then
		-- 	self:SetActorConfigPrefabData(ConfigManager.Instance:GetPrefabDataAutoConfig("Monster", self.res_id))
		-- else
			self:SetActorConfigPrefabData(ConfigManager.Instance:GetPrefabDataAutoConfig("QiZhi", self.res_id))
		-- end
	else
		self:SetActorConfigPrefabData(ConfigManager.Instance:GetPrefabDataAutoConfig("Monster", self.res_id))
	end

end

function Monster:ReloadSpecialImage()
	local scene_logic = Scene.Instance:GetSceneLogic()

	local is_show_special_image, asset, bundle = scene_logic:GetIsShowSpecialImage(self)
	self.follow_ui:SetSpecialImage(is_show_special_image, asset, bundle)
end

function Monster:ReloadSpecialName(guild_id)
	local guild_yunbiao_cfg = GuildData.Instance:GetGuildYunBiaoConfig()
	local scene_id = guild_yunbiao_cfg.biaoche_scene_id
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GUILD_BONFIRE) and Scene.Instance:GetSceneId() == scene_id then
		GuildCtrl.Instance:SendAllGuildInfoReq()
		local guild_name = GuildData.Instance:GetGuildNameByGuild(guild_id)
		local text = string.format(Language.Guild.BiaoChe, guild_name)
		self:SetDpsTargetName(guild_name)
		self.follow_ui:SetName(text)
	end
end

function Monster:ReloadMonsterInfo()
	-- if Scene.Instance:GetSceneType() == SceneType.MonthBlackWindHigh then						--珍宝秘境屏蔽Boss头上的宝箱
	-- 	local boss_cfg = KFMonthBlackWindHighData.Instance:GetCrossDarkNightBossCfg()
	-- 	for k,v in pairs(boss_cfg) do
	-- 		if v and self.vo.monster_id == v.monster_id then
	-- 			self:ShowName()
	-- 			self.follow_ui:SetMonsterNum(v.drop_num)
	-- 			local bundle, asset = "uis/views/kuafumonthblackwindhigh/images_atlas", "ZhenBaoMiJingBox"
	-- 			self.follow_ui:SetIsShowMonsterImage(true, bundle, asset)
	-- 		end
	-- 	end
	-- else
	-- 	self.follow_ui:SetMonsterNum("")
	-- 	self.follow_ui:SetIsShowMonsterImage(false)
	-- end
	if Scene.Instance:GetSceneType() == SceneType.GongChengZhan then
		local other_cfg = ConfigManager.Instance:GetAutoConfig("gongchengzhan_auto").other[1]
		if other_cfg and self.vo.monster_id == other_cfg.boss1_id then
			self:HideName()
		elseif other_cfg and self.vo.monster_id == other_cfg.boss2_id then
			self:ShowName()
			local city_bobal_info = CityCombatData.Instance:GetGlobalInfo()
			if city_bobal_info then
				local name = string.format(Language.CityCombat.Status, city_bobal_info.shou_guild_name)
				self.follow_ui:SetName(name)
			end
		end
	end
end

function Monster:ReloadScoreNum()
	local scene_logic = Scene.Instance:GetSceneLogic()
	if nil == scene_logic.GetIsShowScoreNum then return end

	self.follow_ui:SetScoreNum(scene_logic:GetIsShowScoreNum(self))
end

function Monster:AddBuff(buff_type)
	Character.AddBuff(self, buff_type)
	local scene_id = Scene.Instance:GetSceneId()
	if buff_type == 41 and self.buff_effect_list[buff_type] then
		if BossData.Instance:IsWorldBossScene(scene_id) then
			local scale = BossData.Instance:GetBossHuDunScale(self.vo.monster_id)
			self.buff_effect_list[buff_type]:SetLocalScale(Vector3(scale, scale, scale))
		elseif Scene.Instance:GetSceneType() == SceneType.TowerDefend then
			local other_cfg = ConfigManager.Instance:GetAutoConfig("towerdefendteam_auto").other[1]
			local life_tower_monster_id = other_cfg.life_tower_monster_id
			if self.vo.monster_id == life_tower_monster_id then
				self.buff_effect_list[buff_type]:SetLocalScale(Vector3(1.3, 1.3, 1.3))
			end
		end
	end
end

function Monster:InitShow()
	Character.InitShow(self)
	local scene_type = Scene.Instance:GetSceneType()
	self.load_priority = 3
	if self.obj_scale ~= nil then
		local transform = self.draw_obj:GetRoot().transform
		transform.localScale = Vector3(self.obj_scale, self.obj_scale, self.obj_scale)
	end
	if scene_type == SceneType.DailyTaskFb and self.res_id == 3030001 then
		self.draw_obj:Rotate(0, 52, 0)
		self:InitModel(ResPath.GetMonsterModel(self.res_id))
	elseif math.floor(self.res_id / 1000) == 2038 then --领土战防御塔
		if scene_type == SceneType.QunXianLuanDou then
			local qxld_cfg = ConfigManager.Instance:GetAutoConfig("qunxianlundouconfig_auto").other[1]
			self.draw_obj:Rotate(0, math.deg(math.atan2(qxld_cfg.town_direction_x - self.logic_pos.x, qxld_cfg.town_direction_y - self.logic_pos.y)) - 90, 0)
		elseif scene_type == SceneType.ClashTerritory then
			local size = ClashTerritoryData.Instance:GetTerritoryMonsterSide(self.vo.monster_id)
			if size then
				self.draw_obj:Rotate(0, size == 0 and 180 or 0, 0)
			end
			self.draw_obj:SetOffset(Vector3(0, -2, 0))
		end
		self:InitModel(ResPath.GetMonsterModel(self.res_id))
	elseif scene_type == SceneType.GongChengZhan then
		local gongcheng_cfg = ConfigManager.Instance:GetAutoConfig("gongchengzhan_auto").other[1]
		if gongcheng_cfg and self.vo.monster_id == gongcheng_cfg.boss2_id then
			local monster_id = self.vo.monster_id
			local city_bobal_info = CityCombatData.Instance:GetGlobalInfo()
			if self.vo.monster_id == gongcheng_cfg.boss2_id then
				-- local city_info = CityCombatData.Instance:GetCityOwnerInfo()
				if city_bobal_info then
					local base_prof, zhuan = PlayerData.Instance:GetRoleBaseProf(city_bobal_info.cheng_zhu_prof or 1)
					monster_id = gongcheng_cfg[StatueProfShow[base_prof] or StatueProfShow[1]]
				end
			end
			local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[monster_id]
			if monster_cfg and city_bobal_info then
				self.head_id = monster_cfg.headid
				self.vo.name = string.format(Language.CityCombat.Status, city_bobal_info.shou_guild_name)
				self:InitModel(ResPath.GetMonsterModel(monster_cfg.resid))
			end
			self.draw_obj:Rotate(0, 80, 0)
		elseif self.vo.monster_id == ConfigManager.Instance:GetAutoConfig("gongchengzhan_auto").other[1].boss1_id then
			self.draw_obj:Rotate(0, 180, 0)
			self:InitModel(ResPath.GetMonsterModel(self.res_id))
		else
			self.draw_obj:Rotate(0, math.random(0, 360), 0)
			self:InitModel(ResPath.GetMonsterModel(self.res_id))
		end

	elseif scene_type == SceneType.GuideFb or
			scene_type == SceneType.MountStoryFb or
			scene_type == SceneType.WingStoryFb or
			scene_type == SceneType.XianNvStoryFb then

		if self.vo.monster_id == 7501 then
			local qizhi_res_id = GuildData.Instance:GetQiZhiResId(14)
			self:InitModel(ResPath.GetQiZhiModel(qizhi_res_id))
		else
			self:InitModel(ResPath.GetMonsterModel(self.res_id))
		end
	elseif scene_type == SceneType.LingyuFb then
		self.draw_obj:Rotate(0, -320, 0)
		-- if self.vo.monster_id == 60052 then
		-- 	self:InitModel(ResPath.GetMonsterModel(self.res_id))
		-- else
			self:InitModel(ResPath.GetQiZhiModel(self.res_id))
		-- end
	elseif scene_type == SceneType.TowerDefend then
		local other_cfg = ConfigManager.Instance:GetAutoConfig("towerdefendteam_auto").other[1]
		local life_tower_monster_id = other_cfg.life_tower_monster_id
		if self.vo.monster_id == life_tower_monster_id then
			self.draw_obj:Rotate(0, 220, 0)
		end
		self:InitModel(ResPath.GetMonsterModel(self.res_id))
	elseif scene_type == SceneType.CrossGuild then
		local scene_id = Scene.Instance:GetSceneId()
		if KuafuGuildBattleData.Instance:GetSceneFlagCfg(scene_id, self.vo.monster_id) then
			local rotation = KuafuGuildBattleData.Instance:GetAngelBySceneId(scene_id)
			self.draw_obj:Rotate(0, rotation, 0)
			-- 根据配置表的龙珠、凤珠id，每隔15秒播放一次动画
			if self.vo.monster_id == 4104 or self.vo.monster_id == 4101 or self.vo.monster_id == 4130 then
				if self.time_quest == nil then
					self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushAnimatorState, self, self.draw_obj, 1, ANIMATOR_PARAM.REST1), 15)
				end
			end
		else
			if LIUJIE_CHUMO_BOSS_ROTATION[self.vo.monster_id] then
				self.draw_obj:Rotate(0, LIUJIE_CHUMO_BOSS_ROTATION[self.vo.monster_id], 0)
			else
				self.draw_obj:Rotate(0, self.rotate_to_angle and self.rotate_to_angle or math.random(0, 360), 0)
			end
		end
		if self.vo.monster_id <= 4200 and self.vo.monster_id >= 4000 then
			self:InitModel(ResPath.GetMonsterModel(self.res_id))
		else
			self:InitModel(ResPath.GetMonsterModel(self.res_id))
		end
	elseif scene_type == SceneType.ZhuanZhiFb then
		self.draw_obj:Rotate(0, 220, 0)
		self:InitModel(ResPath.GetMonsterModel(self.res_id))
	elseif scene_type == SceneType.CrossLieKun_FB then
		if self.vo.monster_id == 52006 or self.vo.monster_id == 52010 then
			self.draw_obj:Rotate(0, -306, 0)
		elseif self.vo.monster_id == 52007 or self.vo.monster_id == 52011 then
			self.draw_obj:Rotate(0, -160, 0)
		elseif self.vo.monster_id == 52008 or self.vo.monster_id == 52012 then
			self.draw_obj:Rotate(0, 218, 0)
		elseif self.vo.monster_id == 52009 or self.vo.monster_id == 52013 then
			self.draw_obj:Rotate(0, 11, 0)
		end
		
		self:InitModel(ResPath.GetMonsterModel(self.res_id))
	elseif scene_type == SceneType.MonthBlackWindHigh then
		-- local boss_cfg = KFMonthBlackWindHighData.Instance:GetCrossDarkNightBossCfg()
		-- if self.vo.monster_id == boss_cfg[1].monster_id then
		-- 	self.draw_obj:Rotate(0, -30, 0)
		-- elseif self.vo.monster_id == boss_cfg[2].monster_id then
		-- 	self.draw_obj:Rotate(0, 100, 0)
		-- elseif self.vo.monster_id == boss_cfg[3].monster_id then
		-- 	self.draw_obj:Rotate(0, 55, 0)
		-- elseif self.vo.monster_id == boss_cfg[4].monster_id then
		-- 	self.draw_obj:Rotate(0, -120, 0)
		-- elseif self.vo.monster_id == boss_cfg[5].monster_id then
		-- 	self.draw_obj:Rotate(0, 260, 0)
		-- end
		self:InitModel(ResPath.GetMonsterModel(self.res_id))
	elseif scene_type == SceneType.PhaseFb then
		if self.vo.monster_id == 500 or  self.vo.monster_id == 510 or self.vo.monster_id == 511 
		or self.vo.monster_id == 501 or self.vo.monster_id == 505 or self.vo.monster_id == 515 then
			self.draw_obj:Rotate(0, 180, 0)
		elseif self.vo.monster_id == 503 or self.vo.monster_id == 513 or  self.vo.monster_id == 504 or self.vo.monster_id == 514 then
			self.draw_obj:Rotate(0, 150, 0)
		end
		self:InitModel(ResPath.GetMonsterModel(self.res_id))
	elseif scene_type == SceneType.TeamSpecialFB then
		if self:IsBoss() then
			self.draw_obj:Rotate(0, -130, 0)
		else
			local rotate_to_angle = CommonSceneTypeDirection[self.res_id]
			self.rotate_to_angle = rotate_to_angle or self.rotate_to_angle
			self.draw_obj:Rotate(0, self.rotate_to_angle or math.random(0, 360), 0)
		end
		self:InitModel(ResPath.GetMonsterModel(self.res_id))
	else
		if VIP_BOSS_ROTATION[self.vo.monster_id] then
			self.draw_obj:Rotate(0, VIP_BOSS_ROTATION[self.vo.monster_id], 0)
		elseif QUALITY_BOSS_ROTATION[self.vo.monster_id] then
			self.draw_obj:Rotate(0, QUALITY_BOSS_ROTATION[self.vo.monster_id], 0)
		elseif self.vo.monster_id == 1103 then 				--组队守护
			self.draw_obj:Rotate(0, 90, 0)
		elseif WEAPON_BOSS_ROTATION[self.vo.monster_id] then
			self.draw_obj:Rotate(0, WEAPON_BOSS_ROTATION[self.vo.monster_id], 0)
		elseif HeFu_BOSS_ROTATION[self.vo.monster_id] then
			self.draw_obj:Rotate(0, HeFu_BOSS_ROTATION[self.vo.monster_id], 0)
		else
			local rotate_to_angle = CommonSceneTypeDirection[self.res_id]
			self.rotate_to_angle = rotate_to_angle or self.rotate_to_angle
			self.draw_obj:Rotate(0, self.rotate_to_angle or math.random(0, 360), 0)
		end
		self:InitModel(ResPath.GetMonsterModel(self.res_id))
	end
end

function Monster:InitModel(bundle, asset)
    if ResMgr:IsBundleMode() and not ResMgr:IsVersionCached(bundle) then
		self:ChangeModel(SceneObjPart.Main, ResPath.GetMonsterModel(2007001))

		DownloadHelper.DownloadBundle(bundle, 3, function(ret)
			if ret then
				self:ChangeModel(SceneObjPart.Main, bundle, asset)
			end
		end)
	else
		self:ChangeModel(SceneObjPart.Main, bundle, asset)
	end
end

function Monster:InitEnd()
	Character.InitEnd(self)

	if MAGIC_SPECIAL_STATUS_TYPE.READING == self.vo.status_type then
		self:StartSkillReading(0)
	end

	self:CheckShowEffect()
end

function Monster:CheckShowEffect()
	local is_golden_pig_monster = KaifuActivityData.Instance:GetIsGoldenPigMonsterById(self.vo.monster_id)
	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	if nil ~= main_part and not is_golden_pig_monster then
		main_part:PlayAttachEffect()
	end
end

function Monster:SetDirectionByXY(x, y)
	if self.vo and math.floor(self.res_id / 1000) == 2038 then--and ClashTerritoryData.Instance:GetTerritoryMonsterSide(self.vo.monster_id) then
		return
	end
	Character.SetDirectionByXY(self, x, y)
end

function Monster:OnEnterScene()
	Character.OnEnterScene(self)
	self:GetFollowUi()
	if self:IsBoss() then
		self:GetFollowUi()
		if self:CanHideFollowUi() then
			self:HideFollowUi()
		end
	end
	self:SetMonsterNameIsShow()
	self:ReloadSpecialImage()
	self:ReloadScoreNum()
	self:ReloadMonsterInfo()
end

function Monster:OnClick()
	Character.OnClick(self)

	if not self:IsBoss() then
		self:ShowName()
		local need_load_select = self.select_effect == nil
		if need_load_select and self.select_effect then
			self.select_effect:Load(ResPath.GetSelectObjEffect2("red"))
			self.select_effect:SetLocalScale(Vector3(1.5, 1.5, 1.5))
		end
	end

	if self.vo.monster_id == 310 or self.vo.monster_id == 60051 then 				--仙盟镖车和攻城战雕像特殊处理
		self:ShowName()
	end
end

function Monster:CancelSelect()
	Character.CancelSelect(self)
	local scene_logic = Scene.Instance:GetSceneLogic()
	local scene_type = Scene.Instance:GetSceneType()
	if not self:IsBoss() and not scene_logic:AlwaysShowMonsterName() and scene_type ~= SceneType.Defensefb then
		self:HideName()
	end
end

function Monster:EnterStateDead()
	Character.EnterStateDead(self)
	if self.vo.monster_id == 10000 then
		if self.audio_config == nil then
			self.audio_config = AudioData.Instance:GetAudioConfig()
		end
		AudioManager.PlayAndForget("audios/sfxs/uis", self.audio_config.other[1].MonsterKill)
	end
	if self.res_id == 3030001 and nil ~= self.draw_obj then
		self.draw_obj:PlayDead(self.dietype, function()
			if nil ~= self.draw_obj then
				self.draw_obj:SetVisible(false)
			end
		end, 1)
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

end

function Monster:IsMonster()
	return true
end

function Monster:IsBoss()
	return self.is_boss
end

function Monster:GetMonsterId()
	return self.vo.monster_id
end

function Monster:GetMonsterHead()
	return self.head_id
end

function Monster:IsSkillReading()
	return self.is_skill_reading
end

function Monster:GetDpsTargetName()
	return self.dps_target_name
end

function Monster:SetDpsTargetName(name)
	self.dps_target_name = name
end

function Monster:StartSkillReading(skill_id)
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	local part_obj = part:GetObj()
	if part_obj == nil or IsNil(part_obj.gameObject) then
		return false
	end

	local anim_name = "magic1_1"

	local skill_cfg = SkillData.GetMonsterSkillConfig(skill_id)
	if nil ~= skill_cfg then
		anim_name = skill_cfg.skill_action .. "_1"
	end

	self.is_skill_reading = true
	part_obj.animator:SetTrigger(anim_name)

	return true
end

function Monster:EnterStateAttack()
	local anim_name = SceneObjAnimator.Atk1
	local skill_cfg = SkillData.GetMonsterSkillConfig(self.attack_skill_id)
	if nil ~= skill_cfg then
		local is_magic = ("magic1" == skill_cfg.skill_action or "magic2" == skill_cfg.skill_action)

		if self.is_skill_reading and is_magic then -- 正在读条中且是魔法技能，则是一个完整的（读条-聚气-释放）
			self.is_skill_reading = false
			anim_name = skill_cfg.skill_action .. "_3"

			-- 播放聚气特效
			if "" ~= skill_cfg.effect_prefab_name and "none" ~= skill_cfg.effect_prefab_name then

				local position = self.attack_target_obj and self.attack_target_obj:GetRoot().transform.position or self.draw_obj:GetRoot().transform.position
				if skill_cfg.is_aoe == 1 and self.attack_target_pos_x and self.attack_target_pos_y then
					local position_1 = position
					local x, z =  GameMapHelper.LogicToWorld(self.attack_target_pos_x, self.attack_target_pos_y)
					position = {x = x, y = position_1.y, z = z}
				end
				local bundle_name, prefab_name = ResPath.GetEffect(skill_cfg.effect_prefab_name)

				EffectManager.Instance:PlayControlEffect(self, bundle_name, prefab_name, position)
			end

		elseif not self.is_skill_reading and is_magic then -- 没在读条但收到魔法技能id，则处理成普攻
			anim_name = SceneObjAnimator.Atk1

		else
			anim_name = skill_cfg.skill_action
		end
	end

	Character.EnterStateAttack(self, anim_name)
end

function Monster:CreateFollowUi()
	self.follow_ui = MonsterFollow.New()

	self.follow_ui:SetIsBoss(self:IsBoss())
	if self.draw_obj then
		self.follow_ui:SetFollowTarget(self.draw_obj.root.transform, self.draw_obj:GetName())
	end
	if self.vo.max_hp ~= nil and self.vo.max_hp > 0 then
		self.follow_ui:SetHpPercent(self.vo.hp / self.vo.max_hp)
	end
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.LingyuFb or scene_type == SceneType.Defensefb then
		self.follow_ui:Show()
		if FuBenData.Instance:GetIsDefenseTower(self.vo.monster_id) then
			self.follow_ui:ShowFollowUIUpImage(self.vo.obj_id)
			FuBenCtrl.Instance:SetBuildTargetObjData(self)
		end
	elseif scene_type == SceneType.QunXianLuanDou then
		local monster_id = ElementBattleData.Instance:GetCampName(1).defender_monster_id
		if self.effect_obj == nil and monster_id and self.vo.monster_id == monster_id then
			self:PlayerTowerEffectAddtion(true)
		end
	end
end

function Monster:ShowName()
	self:GetFollowUi():ShowName()
end

function Monster:HideName()
	self:GetFollowUi():HideName()
end

function Monster:OnDie()
	Character.OnDie(self)

	local part_obj = self.draw_obj:GetPart(SceneObjPart.Main):GetObj()
	if nil ~= part_obj and nil ~= part_obj.actor_attach_effect then
		part_obj.actor_attach_effect:StopEffect()
	end

	if self.is_skill_reading then
		self.is_skill_reading = false
		if nil ~= part_obj and nil ~= part_obj.actor_ctrl then
			part_obj.actor_ctrl:StopEffects()
		end
	end
end

function Monster:SetBubble(text)
	self:ActiveFollowUi()
	if nil ~= self.follow_ui and text then
		self.follow_ui:ChangeBubble(text)
	end
	if text then
		self.follow_ui:ShowBubble()
	else
		self.follow_ui:HideBubble()
	end
end

function Monster:SetShowUpImage(enable)
	if self.follow_ui then
		self.follow_ui:IsShowFollowUIUpImage(enable)
	end
end

function Monster:ShowTowerAttackRangeRadius()
	if self.draw_obj then
		if self.effect_obj == nil then
			self:PlayerTowerEffectAddtion()
		else
			if self.draw_obj and self.effect_obj and self.effect_obj.gameObject then
				self.effect_obj.gameObject:SetActive(true)
			end
		end
	end
end

function Monster:HideTowerAttackRangeRadius()
	if self.draw_obj and self.effect_obj and self.effect_obj.gameObject then
		self.effect_obj.gameObject:SetActive(false)
	end
end

function Monster:PlayerTowerEffectAddtion(normanl)
	self.async_loader = AllocAsyncLoader(self, "defense_loader")
	local bundle_name, asset_name = ResPath.GetMiscEffect("yuanxinggongjifanwei")
	self.async_loader:Load(bundle_name, asset_name, function (obj)
		if not IsNil(obj) and self.draw_obj then
			self.effect_obj = obj.transform
			self.effect_obj:SetParent(self.draw_obj:GetRoot().transform, false)
			self.effect_obj.localPosition = Vector3(0, 0.25, 0)
			local obj = self.effect_obj:Find("yuanxinggongjifanwei")
			if obj then
				obj.transform.localScale = normanl and Vector3(1.4, 1.4, 1.4) or Vector3(1, 1, 1)
			end
		end
	end)
end

function Monster:SetMonsterNameIsShow()
	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic:AlwaysShowMonsterName() then
		self:ShowName()
	end
end

-- 手动刷新怪物的状态 
-- draw_obj
-- ani_type需要设置触发方法是1、setTrigger 2、SetBool 3、SetInteger
-- 若需拓展自己改
function Monster:FlushAnimatorState(draw_obj, ani_type, key, value)
	if draw_obj == nil then return end
	local main_part_obj = draw_obj:GetPart(SceneObjPart.Main)
	if value == nil then
		if ani_type == 1 then
			main_part_obj:SetTrigger(key)
		end
	else
		if ani_type == 2 then
			main_part_obj:SetBool(key, value)
		else
			main_part_obj:SetInteger(key, value)
		end
	end
end

-- 仙盟镖车特殊处理(人物飞过去镖车不会移动问题)
function Monster:Update(now_time, elapse_time)
	Character.Update(self, now_time, elapse_time)
	if self:GetIsChangeDoMove() then
		if self.monster_up_time <= 0 then
			self.monster_up_time = Status.NowTime + 2
		end
		if self.monster_up_time > 0 then
			if not self:IsMove() and not self.is_first and self.vo.distance > 0.1 then
				self.is_first = true
				self:DoMove(math.floor(self.vo.pos_x + math.cos(self.vo.dir) * self.vo.distance), math.floor(self.vo.pos_y + math.sin(self.vo.dir) * self.vo.distance))
			end
			self.monster_up_time = 0
		end
	end
end

function Monster:GetIsChangeDoMove()
	-- 主城(镖车)
	if Scene.Instance:GetSceneId() == 103 then
		local guild_yunbiao_cfg = GuildData.Instance:GetGuildYunBiaoConfig()
		if guild_yunbiao_cfg then
			local monster_id = guild_yunbiao_cfg.biaoche_monster_id
			if self.vo.monster_id == monster_id  then
				return true
			end
		end
	end
	if self.vo.monster_id == 1200 then
		return true
	end
	return false
end