
require("game/fight/fight_def")
require("game/fight/fight_data")
require("game/fight/fight_text")
-- 战斗
FightCtrl = FightCtrl or BaseClass(BaseController)

--pvp技能进行特殊处理
local XIANNV_SKILL1 = 80
local XIANNV_SKILL2 = 86
local MOJIE_SKILL = 70

function FightCtrl:__init()
	if FightCtrl.Instance ~= nil then
		print_error("[FightCtrl] attempt to create singleton twice!")
		return
	end
	FightCtrl.Instance = self

	self.data = FightData.New()
	FightText.New()

	self.last_skill_id = 0
	self.last_atk_time = 0

	self:RegisterAllProtocols()

	Runner.Instance:AddRunObj(self, 5)
	self.monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
end

function FightCtrl:__delete()
	FightCtrl.Instance = nil

	FightText.Instance:DeleteMe()

	self.data:DeleteMe()
	self.data = nil

	Runner.Instance:RemoveRunObj(self)
	self.monster_cfg = nil
end

function FightCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCObjChangeBlood, "OnObjChangeBlood")
	self:RegisterProtocol(SCPerformSkill, "OnPerformSkill")
	self:RegisterProtocol(SCPerformAOESkill, "OnPerformAOESkill")
	self:RegisterProtocol(SCRoleReAlive, "OnRoleReAlive")
	self:RegisterProtocol(SCFixPos, "OnFixPos")
	self:RegisterProtocol(SCSkillTargetPos, "OnSkillTargetPos")
	self:RegisterProtocol(SCBuffMark, "OnBuffMark")
	self:RegisterProtocol(SCBuffAdd, "OnBuffAdd")
	self:RegisterProtocol(SCBuffRemove, "OnBuffRemove")
	self:RegisterProtocol(SCEffectList, "OnEffectList")
	self:RegisterProtocol(SCEffectInfo, "OnEffectInfo")
	self:RegisterProtocol(SCEffectRemove, "OnEffectRemove")
	self:RegisterProtocol(SCFightSpecialFloat, "OnFightSpecialFloat")
	self:RegisterProtocol(SCSpecialShieldChangeBlood, "OnSpecialShieldChangeBlood")
	self:RegisterProtocol(SCSkillPhase, "OnSkillPhase")
	self:RegisterProtocol(SCZhiBaoAttack, "OnZhiBaoAttack")
	self:RegisterProtocol(SCBianShenView, "BianShenView")
	self:RegisterProtocol(SCFightBackRoleList, "OnFightBackRoleList")
	self:RegisterProtocol(SCFirstRechargeBuffFlag, "OnSCFirstRechargeBuffFlag")

	-- 经验buff信息
	self:RegisterProtocol(SCExpBuffInfo, "OnSCExpBuffInfo")
end

function FightCtrl:Update(now_time, elapse_time)
	self.data:Update(now_time, elapse_time)
end

function FightCtrl:OnSCExpBuffInfo(protocol)
	self.data:SetExpBuffInfo(protocol)
	TipsCtrl.Instance:FlushTipsBuffPandectView()
end

function FightCtrl:OnObjChangeBlood(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if nil == obj or not obj:IsCharacter() then
		return
	end

	if protocol.real_blood ~= 0 then
		obj:SetAttr("hp", obj:GetAttr("hp") + protocol.real_blood)
	end

	if protocol.real_blood >= 0 and protocol.fighttype == FIGHT_TYPE.NORMAL then
		return
	end

	local deliverer = Scene.Instance:GetObj(protocol.deliverer)
	-- 单体攻击使用这条协议来播动作
	-- if 0 ~= protocol.skill and nil ~= deliverer and not deliverer:IsMainRole() and not SkillData.IsAoeSkill(protocol.skill) then
	-- 	local target_x, target_y = obj:GetLogicPos()
	-- 	deliverer:DoAttack(protocol.skill, target_x, target_y, protocol.obj_id)
	-- end

	-- 没有攻击者或者技能id为0直接处理受击效果
	if nil == deliverer or 0 == protocol.skill then
		obj:DoBeHit(deliverer, protocol.skill, protocol.real_blood, protocol.blood, protocol.fighttype)
	else
		-- 主角攻击特殊处理
		local role_hurt, nvshen_hurt, lingchong_hurt = self:CalculateHurt(protocol.blood, protocol.fighttype)
		local is_trigger = false
		if deliverer:IsMainRole() then
			-- 不是本次攻击的，或者已经击中直接表现
			if (protocol.skill ~= deliverer:GetLastSkillId() or deliverer:AtkIsHit(protocol.skill))
			and deliverer.vo.special_appearance ~= SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR then
				is_trigger = true
				obj:DoBeHit(deliverer, protocol.skill, protocol.real_blood, role_hurt, protocol.fighttype)
				if nvshen_hurt < 0 then
					obj:DoBeHit(deliverer, 0, 0, nvshen_hurt, protocol.fighttype, FIGHT_TEXT_TYPE.NVSHEN)
				end
				if lingchong_hurt < 0 then
					obj:DoBeHit(deliverer, 0, 0, nvshen_hurt, protocol.fighttype, FIGHT_TYPE.LINGCHONG)
				end
			end
			GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_DO_HIT, obj, protocol.blood)
		else
			role_hurt = protocol.blood
			nvshen_hurt = 0
			lingchong_hurt = 0
		end
		if not is_trigger then
			-- 尚未击中先缓存
			self.data:SaveBeHitInfo(protocol.obj_id, protocol.deliverer, protocol.skill,
				protocol.real_blood, role_hurt, protocol.fighttype, nvshen_hurt, lingchong_hurt)
		end
	end

	if obj:IsMainRole() and nil ~= deliverer then
		GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_BE_HIT, deliverer)
		GuildCtrl.Instance:SetIsStopYunBiaoFollow(true)
		if not deliverer:IsMainRole() then
			if deliverer:GetType() == SceneObjType.Trigger then
				ReviveData.Instance:SetKillerName(deliverer.vo.trigger_name or "")
				obj:DoBeHit(deliverer, protocol.skill, protocol.real_blood, protocol.blood, protocol.fighttype)
			else
				ReviveData.Instance:SetKillerName(deliverer:GetName() or "")
			end
		end
	end

	local skill_list = bit:d2b(protocol.passive_flag)
	for i,v in ipairs(skill_list) do
		if v == 1 then
			local pos = nil
			local target = obj
			if i == PASSIVE_FLAG.PASSIVE_FLAG_JING_LING_LEI_TING + 1 then
				pos = obj.draw_obj:GetPart(SceneObjPart.Main):GetAttachPoint(2)
			elseif i == PASSIVE_FLAG.PASSIVE_FLAG_JING_LING_XI_XUE + 1 then
				if nil ~= deliverer then
					target = deliverer
					pos = deliverer.draw_obj:GetPart(SceneObjPart.Main):GetAttachPoint(2)
				end
			end

			if nil ~= pos then
				local bundle_name, prefab_name = ResPath.GetEffect(PASSIVE_FLAG_RES[i - 1] or "tongyong_lei")
				EffectManager.Instance:PlayControlEffect(target, bundle_name, prefab_name, pos.transform.position)
			end
		end
	end

	if obj:IsRole() and tonumber(protocol.product_method) == PRODUCT_METHOD.GCZCZ_SKILL then
		if obj then
			obj:AddBuff(BUFF_TYPE.GCZCZ_SKILL)

			if nil ~= self.gcz_buff_timer then
				GlobalTimerQuest:CancelQuest(self.gcz_buff_timer)
				self.gcz_buff_timer = nil
			end
			self.gcz_buff_timer = GlobalTimerQuest:AddDelayTimer(function ()
				obj:RemoveBuff(BUFF_TYPE.GCZCZ_SKILL)
			end, 3)
		end
	elseif obj:IsMainRole() and tonumber(protocol.product_method) == PRODUCT_METHOD.GCZCZ_SKILL_CHENGZHU then
		local main_view = MainUICtrl.Instance:GetView()
		local transform = nil
		if main_view then
			local chengzhu_skill = main_view:GetChengZhuSkill()
			if chengzhu_skill then
				transform = chengzhu_skill.transform
			end
			UITween.MoveShowPanel(chengzhu_skill, Vector3(400, 230, 0), 0.5)
		end
		if transform then
			--直接放在主界面上
			local bundle_name, asset_name = ResPath.GetUiXEffect("UI_dafandoushulei")
			EffectManager.Instance:PlayAtTransform(bundle_name, asset_name, transform, 3)
		end
	end

	self:KillRoleInBossScene(obj, deliverer)
end

-- 在BOSS场景中杀人，弹出UI
function FightCtrl:KillRoleInBossScene(obj, deliverer)
	if nil == obj or nil == deliverer then
		return
	end

	local scene_logic = Scene.Instance:GetSceneLogic()
	if not scene_logic:GetIsInBossScene() then
		return
	end
	if obj:IsMainRole()
		or not obj:IsRole()
		or not obj:IsRealDead()
		or not deliverer:IsMainRole() then
		return
	end

	KillRoleCtrl.Instance:ShowKillView(obj:GetVo())
end

function FightCtrl:OnPerformSkill(protocol)
	local deliverer = Scene.Instance:GetObj(protocol.deliverer)
	if nil == deliverer or not deliverer:IsCharacter() then
		return
	end

	local attack_index = protocol.skill_data
	-- if deliverer:IsMainRole() then
	-- 	return
	-- end

	local target_obj = Scene.Instance:GetObj(protocol.target)
	if nil == target_obj then
		return
	end
	-- 跨服农场的几个技能protocol.skill_data返回0会出bug，强制改掉
	if Scene.Instance:GetSceneType() == SceneType.FarmHunting then
		local skill_index = FarmHuntingData.Instance:GetFarmSkillIndex(protocol.skill)
		if skill_index >= 0 then
			if protocol.skill_data == 0 then
				attack_index = 1
			end
			-- 疾跑技能加个特效（本来应该走OnFightSpecialFloat或者OnObjChangeBlood流程，但其实像这种播放一次的特效感觉不需要通过服务器来播放）
			local farm_skill_config = FarmHuntingData.FarmSkillAction
			if farm_skill_config[protocol.skill] and farm_skill_config[protocol.skill].effect then
				target_obj:AddEffect(farm_skill_config[protocol.skill].effect, 3)
			end
		end
	end

	if deliverer:IsMainRole() then -- and (protocol.skill == 221 or protocol.skill == 321)
		SkillData.Instance:UseSkill(protocol.skill)
		SkillData.Instance:RecordSkillProficiency(protocol.skill)
		PlayerCtrl.Instance:FlushPlayerSkillView()
	else
		-- 一些技能不需要播放动作
		if NotActionSkill[protocol.skill] == nil then
			local target_x, target_y = target_obj:GetLogicPos()
			deliverer:DoAttack(protocol.skill, target_x, target_y, protocol.target)
			deliverer.attack_index = attack_index
		end
	end
end

function FightCtrl:OnPerformAOESkill(protocol)
	local deliverer = Scene.Instance:GetObj(protocol.obj_id)
	if nil == deliverer or not deliverer:IsCharacter() then
		return
	end

	-- 怪物在施法阵过程中，会一直收到AOE，法阵原因不处理
	if AOE_REASON.AOE_REASON_FAZHEN == protocol.aoe_reason then
		return
	end

	if not deliverer:IsMainRole() then
		deliverer.attack_index = protocol.skill_data
		deliverer:DoAttack(protocol.skill, protocol.pos_x, protocol.pos_y, protocol.target)
	elseif protocol.skill == 4401 then -- 防具材料本群攻技能
		FuBenCtrl.Instance:ArmorPlaySkillAnim(protocol.target)
	else--if protocol.skill == 221 or protocol.skill == 321 then
		SkillData.Instance:UseSkill(protocol.skill)
		SkillData.Instance:RecordSkillProficiency(protocol.skill)
		PlayerCtrl.Instance:FlushPlayerSkillView()
	end
end

function FightCtrl:OnRoleReAlive(protocol)
	local target_obj = Scene.Instance:GetObj(protocol.obj_id)
	if nil == target_obj then
		return
	end
	target_obj:SetLogicPos(protocol.pos_x, protocol.pos_y)
	target_obj:DoStand()
	if target_obj:IsRole() and not target_obj:IsMainRole() then
		target_obj:OnRealive()
	end

	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.CrossGuild then
		GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	else
		if target_obj:IsRole() and target_obj:IsMainRole() then
			if (BossData.IsBossScene() or Scene.Instance:GetSceneType() == SceneType.Common) then
				if not target_obj:IsInSafeArea() then
					GuajiCtrl.Instance:SetReviveGuajiState()
				end
			else
				GuajiCtrl.Instance:SetReviveGuajiState(GuajiType.Auto)
			end
		end
	end
	ReviveData.Instance:SetRoleReviveInfo(protocol)

	-- 3V3 复活旋转角度
	if Scene.Instance:GetSceneType() == SceneType.Kf_PVP then
		local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
		if role_id == target_obj:GetRoleId() then
			local my_side = KuafuPVPData.Instance:GetRoleInfo().self_side
			if my_side == 0 then
				Scene.Instance:SetGuideFixedCamera(16, 0)
			else
				Scene.Instance:SetGuideFixedCamera(16, 180)
			end
		end
	end
	MainUICtrl.Instance:FlushView("fulush_near_role")
	--复活修改视角先屏蔽
	-- if target_obj:IsRole() and target_obj:IsMainRole() then
	-- 	Scene.Instance:SetCurFixedCamera(Scene.Instance:GetSceneId())
	-- end
end

function FightCtrl:OnFixPos(protocol)
	Scene.Instance:GetMainRole():SetLogicPos(protocol.x, protocol.y)
end

-- 技能目标位置
function FightCtrl:OnSkillTargetPos(protocol)
	local obj = Scene.Instance:GetObj(protocol.target_obj_id)
	if obj then
		obj:SetLogicPos(protocol.pos_x, protocol.pos_y)
	end
end

function FightCtrl:OnBuffMark(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if nil == obj or not obj:IsCharacter() then
		return
	end

	obj:SetBuffList(bit:uc2b(protocol.buff_mark))
end

function FightCtrl:OnBuffAdd(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if nil == obj or not obj:IsCharacter() then
		return
	end

	obj:AddBuff(protocol.buff_type)
end

function FightCtrl:OnBuffRemove(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if nil == obj or not obj:IsCharacter() then
		return
	end
	obj:RemoveBuff(protocol.buff_type)
end

function FightCtrl:OnEffectList(protocol)
	self.data:OnEffectList(protocol)
end

function FightCtrl:OnEffectInfo(protocol)
	self.data:OnEffectInfo(protocol)
end

function FightCtrl:OnEffectRemove(protocol)
	self.data:OnEffectRemove(protocol.effect_key)
end

function FightCtrl:OnFightSpecialFloat(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if nil == obj or not obj:IsCharacter() then
		return
	end

	local deliverer = Scene.Instance:GetObj(protocol.deliver_obj_id)
	if protocol.float_type == FLOAT_VALUE_TYPE.EFFECT_UP_GRADE_SKILL then
		obj:DoBeHit(deliverer, 0, 0, protocol.float_value, FIGHT_TYPE.NORMAL, FIGHT_TEXT_TYPE.SHENSHENG)
		local bundle_name, prefab_name = ResPath.GetEffect(ATTATCH_SKILL_SPECIAL_EFFECT_RES[protocol.skill_special_effect] or "Boss_chongjibo")
		local deliverer_pos = nil
		if deliverer then
			deliverer_pos = deliverer:GetRoot().transform.position
		end
		EffectManager.Instance:PlayControlEffect(obj, bundle_name, prefab_name, obj:GetRoot().transform.position, deliverer_pos)

	elseif protocol.float_type == FLOAT_VALUE_TYPE.EFFECT_REBOUNDHURT then
		-- 精灵的反弹技能特殊处理
		if protocol.skill_special_effect == ATTATCH_SKILL_SPECIAL_EFFECT.SPECIAL_EFFECT_JINGLING_REBOUNDHURT and nil ~= deliverer then
			deliverer:AddEffect(ATTATCH_SKILL_SPECIAL_EFFECT_RES[protocol.skill_special_effect], 2)
		else
			local pos = obj.draw_obj:GetPart(SceneObjPart.Main):GetAttachPoint(2)
			local bundle_name, prefab_name = ResPath.GetEffect(ATTATCH_SKILL_SPECIAL_EFFECT_RES[protocol.skill_special_effect] or "Boss_chongjibo")
			if pos == nil then return end
			EffectManager.Instance:PlayControlEffect(obj, bundle_name, prefab_name, pos.transform.position)
		end
		obj:DoBeHit(deliverer, 0, 0, protocol.float_value, FIGHT_TYPE.NORMAL, FIGHT_TEXT_TYPE.NVSHEN_FAN)
	elseif protocol.float_type == FLOAT_VALUE_TYPE.EFFECT_RESTORE_HP then
		-- 精灵回血技能服务端会发个0过来 因为只需要到飘字，但特效的播放会通过另外的一条协议（我也很无奈 --||）
		if protocol.skill_special_effect > 0 then
			local pos = obj.draw_obj:GetPart(SceneObjPart.Main):GetAttachPoint(2)
			if pos then
				local bundle_name, prefab_name = ResPath.GetEffect(ATTATCH_SKILL_SPECIAL_EFFECT_RES[protocol.skill_special_effect] or "Boss_chongjibo")
				EffectManager.Instance:PlayControlEffect(obj, bundle_name, prefab_name, pos.transform.position)
			end
		end
	elseif protocol.float_type == FLOAT_VALUE_TYPE.EFFECT_NORMAL_HURT then
		local pos = obj.draw_obj:GetPart(SceneObjPart.Main):GetAttachPoint(2)
		if nil == pos then
			return
		end
		local bundle_name, prefab_name = ResPath.GetEffect(ATTATCH_SKILL_SPECIAL_EFFECT_RES[protocol.skill_special_effect] or "Boss_chongjibo")
		EffectManager.Instance:PlayControlEffect(obj, bundle_name, prefab_name, pos.transform.position)
		obj:DoBeHit(deliverer, 0, 0, protocol.float_value, FIGHT_TYPE.NORMAL, FIGHT_TEXT_TYPE.NVSHEN_SHA)
	-- else
		-- obj:OnFightSpecialFloat(protocol.float_value)
	end
end

function FightCtrl:OnSpecialShieldChangeBlood(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if nil == obj or not obj:IsCharacter() then
		return
	end
	local info = {
		obj_id = protocol.obj_id,
		real_hurt = protocol.real_hurt,
		left_times = protocol.left_times,
		max_times = protocol.max_times,
	}
	GlobalEventSystem:Fire(ObjectEventType.SPECIAL_SHIELD_CHANGE, info)
end

function FightCtrl:OnSkillPhase(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if nil == obj or not obj:IsMonster() then
		return
	end

	if MAGIC_SKILL_PHASE.READING == protocol.phase then
		if Scene.Instance:GetSceneType() ~= SceneType.Common then
			ViewManager.Instance:Open(ViewName.BossSkillWarning)
		end
		obj:StartSkillReading(protocol.skill_id)
	end
end

function FightCtrl:OnZhiBaoAttack(protocol)
	local obj = Scene.Instance:GetObj(protocol.target_id)
	if nil == obj or not obj:IsCharacter() then
		return
	end
	local deliverer = Scene.Instance:GetObj(protocol.attacker_id)
	local is_shield_self = SettingData.Instance:GetSettingData(SETTING_TYPE.SELF_SKILL_EFFECT)
	if is_shield_self then
		if deliverer and deliverer:IsMainRole() then
			return
		end
	end
	local is_shield_other = SettingData.Instance:GetSettingData(SETTING_TYPE.SKILL_EFFECT)
	if is_shield_other then
		if deliverer and not deliverer:IsMainRole() then
			return
		end
	end

	local asset_bundle, name = ResPath.GetMiscEffect("tongyong_lei")
	-- if protocol.skill_index == 1 then
	-- 	asset_bundle, name = ResPath.GetMiscEffect("tongyong_lei")
	-- end
	if not self.game_root then
		self.game_root = GameObject.Find("GameRoot/SceneObjLayer")
	end
	if self.game_root then
		local effect_loader = AllocAsyncLoader(self, "zibao_effect_loader")
		effect_loader:SetParent(self.game_root.transform)
		local call_back = function(effect_obj)
			if not IsNil(effect_obj) then
				local root = obj:GetRoot()
				if root and not IsNil(root.gameObject) then
					effect_obj.transform.localPosition = root.transform.localPosition
				end
			end
		end
		effect_loader:Load(asset_bundle, name, call_back)
		GlobalTimerQuest:AddDelayTimer(function() effect_loader:DeleteMe() end, 5)
	end

	local fighttype = FIGHT_TYPE.NORMAL
	if protocol.is_baoji == 1 then
		fighttype = FIGHT_TYPE.BAOJI
	end
	if nil == deliverer then
		obj:DoBeHit(nil, 0, 0, protocol.hurt, fighttype, FIGHT_TEXT_TYPE.BAOJU)
	else
		-- 主角攻击特殊处理
		if deliverer:IsMainRole() then
			obj:DoBeHit(deliverer, 0, 0, protocol.hurt, fighttype, FIGHT_TEXT_TYPE.BAOJU)
		end
	end
end

function FightCtrl.SendPerformSkillReq(skill_index, attack_index, pos_x, pos_y, target_id, is_specialskill, client_pos_x, client_pos_y)
	local protocol = ProtocolPool.Instance:GetProtocol(CSPerformSkillReq)
	protocol.skill_index = skill_index
	protocol.pos_x = pos_x 
	protocol.pos_y = pos_y
	protocol.target_id = target_id
	protocol.is_specialskill = is_specialskill and 1 or 0
	protocol.client_pos_x = client_pos_x
	protocol.client_pos_y = client_pos_y
	protocol.skill_data = attack_index
	protocol:EncodeAndSend()
end

function FightCtrl.SendRoleReAliveReq(realive_type, is_timeout_req, item_index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRoleReAliveReq)
	protocol.realive_type = realive_type or 0
	protocol.is_timeout_req = is_timeout_req or 0
	protocol.item_index = item_index or 0
	protocol:EncodeAndSend()
end

function FightCtrl.SendGetEffectListReq(obj_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetEffectListReq)
	protocol.target_obj_id = obj_id
	protocol:EncodeAndSend()
end

function FightCtrl:NextCanAtkTime()
	-- if not self.last_skill_id or self.last_skill_id <= 0 then
	-- 	return self.last_atk_time + 0.3
	-- else
	-- 	local is_not_normal_skill = SkillData.IsNotNormalSkill(self.last_skill_id)
	-- 	return is_not_normal_skill and (self.last_atk_time + 0.3) or self.last_atk_time
	-- end

	return self.last_atk_time
end

local Manual_Use_Cache = {}
-- 尝试使用角色技能
function FightCtrl:TryUseRoleSkill(skill_id, target_obj, is_specialskill, is_manual_use)
	if nil == target_obj then
		return false
	end

	if is_manual_use then
		Manual_Use_Cache[skill_id] = true
	end


	local main_role = Scene.Instance:GetMainRole()
	if main_role:IsChenMo() and SkillData.IsNotNormalSkill(skill_id) then
		return false
	end

	if main_role:IsAtkPlaying() then
		return false
	end

	local prof = PlayerData.Instance:GetRoleBaseProf()
	if not is_manual_use and not Manual_Use_Cache[skill_id] then
		local skillinfo = ConfigManager.Instance:GetAutoConfig("roleskill_auto").skillinfo
		if GuajiCache.guaji_type ~= GuajiType.None
			and skillinfo[skill_id] and skillinfo[skill_id].skill_index > 1 
			and (skill_id ~= MOJIE_SKILL and SettingData.Instance:GetAutoUseSkillFlag(skillinfo[skill_id].skill_index - 1) == 0
				or ((skill_id == ZHUAN_ZHI_SKILL1[prof] or skill_id == XIANNV_SKILL1 or skill_id == XIANNV_SKILL2 or skill_id == MOJIE_SKILL) and target_obj:GetType() == SceneObjType.Monster)) 
			then
			return false
		end
	end
	
	if (skill_id == ZHUAN_ZHI_SKILL1[prof] or skill_id == XIANNV_SKILL1 or skill_id == XIANNV_SKILL2 or skill_id == MOJIE_SKILL) and target_obj:GetType() == SceneObjType.Monster then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.SkillTipsError)
		Manual_Use_Cache[skill_id] = nil
		return false
	end

	local can_use, range = SkillData.Instance:CanUseSkill(skill_id)
	if not can_use then
		return false
	end

	local x, y = target_obj:GetLogicPos()
	is_specialskill = is_specialskill or false
	self:DoAtkOperate(skill_id, x, y, target_obj, is_specialskill, range)
	
	Manual_Use_Cache[skill_id] = nil

	return true
end

-- 攻击操作
function FightCtrl:DoAtkOperate(skill_id, x, y, target_obj, is_specialskill, range)
	-- 停止采集
	if Scene.Instance:GetMainRole():GetIsGatherState() then
		Scene.SendStopGatherReq()
	end

	self.last_skill_id = skill_id
	self.last_atk_time = Status.NowTime

	GuajiCtrl.SetAtkValid(true)
	AtkCache.skill_id = skill_id
	AtkCache.x = x
	AtkCache.y = y
	AtkCache.is_specialskill = is_specialskill
	AtkCache.target_obj = target_obj
	AtkCache.target_obj_id = (nil ~= target_obj) and target_obj:GetObjId() or COMMON_CONSTS.INVALID_OBJID
	AtkCache.range = range or 1
	AtkCache.offset_range = 0
	AtkCache.monster_range = 0
	if target_obj and target_obj:IsMonster() and self.monster_cfg[target_obj:GetMonsterId()] then
		AtkCache.monster_range = self.monster_cfg[target_obj:GetMonsterId()].hurt_range
		if AtkCache.monster_range > 3 then
			AtkCache.monster_range = AtkCache.monster_range - 1
			AtkCache.offset_range = 1
		end
	end

	if AtkCache.range > 3 then
		AtkCache.range = AtkCache.range - 1
		AtkCache.offset_range = 1
	end
	-- if skill_id == 121 then
	-- 	AtkCache.range = 5
	-- end
	if Scene.Instance:GetMainRole():IsFightState() then
		MountCtrl.Instance:SendGoonMountReq(0)
	end
	GuajiCtrl.SetMoveValid(false)
	MoveCache.task_id = 0

	GuajiCache.target_obj = target_obj
	GuajiCache.target_obj_id = AtkCache.target_obj_id
	return true
end

-- 跳跃操作
function FightCtrl:DoJump()
	Scene.SendMoveMode(MOVE_MODE.MOVE_MODE_JUMP)
end

function FightCtrl:BianShenView(protocol)
	local scene_obj = Scene.Instance:GetObj(protocol.obj_id)
	if nil ~= scene_obj and scene_obj:IsRole() then
		scene_obj:SetAttr("bianshen_param", protocol.show_image)
	end
end

function FightCtrl:CalculateHurt(total_hurt, fighttype)
	if total_hurt > -10  or fighttype ~= FIGHT_TYPE.NORMAL then
		return total_hurt, 0, 0
	end
	local role_hurt = total_hurt
	local nvshen_hurt = 0
	local lingchong_hurt = 0

	local vo = GameVoManager.Instance:GetMainRoleVo()
	if vo.use_xiannv_id and vo.use_xiannv_id >= 0 then
		nvshen_hurt = math.floor(total_hurt * 0.3)
	end
	if vo.appearance and vo.appearance.lingchong_used_imageid and vo.appearance.lingchong_used_imageid > 0 and math.floor(total_hurt * 0.05) <= -20 then
		lingchong_hurt = math.floor(total_hurt * 0.05)
	end

	role_hurt = total_hurt - nvshen_hurt - lingchong_hurt
	return role_hurt, nvshen_hurt, lingchong_hurt
end

function FightCtrl:OnFightBackRoleList(protocol)
	local is_add = 0
	if protocol.notify == FIGHTBACK_TYPE.NOTIFY_LIST_ADD then
		is_add = 1
	end
	for k,v in pairs(protocol.role_uid_list) do
		local obj = Scene.Instance:GetRoleObjByUId(v)
		if obj then
			obj:SetAttr("is_fightback_obj", is_add)
		end
	end
end

function FightCtrl:OnSCFirstRechargeBuffFlag(protocol)
	self.data:SetFirstRechargeBuff(protocol.ra_is_has_first_recharge_attr_add)
	GlobalEventSystem:Fire(ObjectEventType.FIGHT_EFFECT_CHANGE, true)
end