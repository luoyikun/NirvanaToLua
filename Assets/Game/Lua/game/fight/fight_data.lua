
FightData = FightData or BaseClass()
local EXP_BUY_BUFF_ID_LIST = {
	[1] = 2201,							-- 药水-经验加成1
	[2] = 2202,							-- 药水-经验加成2
	[3] = 2203,							-- 药水-经验加成3
	[4] = 2204,							-- 药水-经验加成4
}
function FightData:__init()
	if FightData.Instance then
		print_error("[FightData]:Attempt to create singleton twice!")
	end
	FightData.Instance = self

	self.main_role_effect_list = {}					-- 主角effect
	self.target_objid = COMMON_CONSTS.INVALID_OBJID	-- 目标objid
	self.target_effect_list = {}					-- 目标effect

	self.equip_level_add = 0						-- 装备越级
	self.equip_level_change_callback_list = {}
	self.exp_buff_list = {}
	self.be_hit_list = {}							-- 受击缓存
	self.ra_is_has_first_recharge_attr_add = 0
end

function FightData:__delete()
	FightData.Instance = nil
end

function FightData.CreateEffectInfo()
	return {
		effect_type = 0,
		product_method = 0,
		product_id = 0,
		unique_key = 0,
		param_list = {},
		client_effect_type = 0,
		merge_layer = 0,
		recv_time = 0,
		cd_time = 0,
	}
end

function FightData:Update(now_time, elapse_time)
	for k, v in pairs(self.be_hit_list) do
		if now_time >= v.max_trigger_time then
			self:DoBeHit(v, false, nil)
			self.be_hit_list[k] = nil
		end
	end
end

function FightData:SetExpBuffInfo(protocol)
	self.exp_buff_list = protocol.exp_buff_list
end

function FightData:GetIsHasOtherExpBuff()
	local num = 0
	local flag = false
	if self.exp_buff_list then
		local now_exp_buff_type = self:GetNowExpBuyBuff()
		for k,v in pairs(self.exp_buff_list) do
			if v and v.exp_buff_left_time_s > 0 then
				if EXP_BUY_BUFF_ID_LIST[k] ~= now_exp_buff_type then
					num = num + 1
				end
			end
		end
	end
	flag = num > 0

	return flag
end

function FightData:GetNowExpBuyBuff()
	local now_exp_buff_type = -1
	if self.main_role_effect_list then
		for k,v in pairs(self.main_role_effect_list) do
			for i = 1,4 do
				if EXP_BUY_BUFF_ID_LIST[i] == v.client_effect_type then
					now_exp_buff_type = v.client_effect_type
				end
			end
		end
	end
	return now_exp_buff_type
end

function FightData:GetOtherExpBuff()
	local exp_buff_list = {}
	if self.exp_buff_list then
		local now_exp_buff_type = self:GetNowExpBuyBuff()
		for k,v in pairs(self.exp_buff_list) do
			if v and v.exp_buff_left_time_s > 0 then
				if EXP_BUY_BUFF_ID_LIST[k] ~= now_exp_buff_type then
					local effect = FightData.CreateEffectInfo()
					effect.client_effect_type = EXP_BUY_BUFF_ID_LIST[k]
					effect.cd_time = v.exp_buff_left_time_s
					table.insert(exp_buff_list, effect)
				end
			end
		end
	end
	return exp_buff_list
end

function FightData:OnEffectList(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if nil == obj then
		return
	end

	local effect_list = {}
	for k, v in pairs(protocol.effect_list) do
		local effect = FightData.CreateEffectInfo()
		effect.effect_type = v.effect_type
		effect.product_method = v.product_method
		effect.product_id = v.product_id
		effect.param_list = v.param_list
		effect.unique_key = v.unique_key
		effect.client_effect_type = v.client_effect_type
		effect.merge_layer = v.merge_layer
		effect.recv_time = Status.NowTime
		table.insert(effect_list, effect)
	end

	if obj:IsMainRole() then
		self.main_role_effect_list = effect_list
		GlobalEventSystem:Fire(ObjectEventType.FIGHT_EFFECT_CHANGE, true)
	else
		self.target_objid = obj:GetObjId()
		self.target_effect_list = effect_list
		GlobalEventSystem:Fire(ObjectEventType.FIGHT_EFFECT_CHANGE, false)
	end
end

function FightData:OnEffectInfo(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if nil == obj then
		return
	end

	local effect = FightData.CreateEffectInfo()
	effect.effect_type = protocol.effect_type
	effect.product_method = protocol.product_method
	effect.product_id = protocol.product_id
	effect.param_list = protocol.param_list
	effect.unique_key = protocol.unique_key
	effect.client_effect_type = protocol.client_effect_type
	effect.merge_layer = protocol.merge_layer
	effect.recv_time = Status.NowTime

	if obj:IsMainRole() then
		self:UpdateEffect(self.main_role_effect_list, effect)
		GlobalEventSystem:Fire(ObjectEventType.FIGHT_EFFECT_CHANGE, true)
		if effect.effect_type == FIGHT_EFFECT_TYPE.BIANSHEN then
			obj:SetAttr("bianshen_param", protocol.param_list[2])
		end
	else
		if self.target_objid ~= obj:GetObjId() then
			self.target_objid = obj:GetObjId()
			self.target_effect_list = {}
		end

		self:UpdateEffect(self.target_effect_list, effect)
		GlobalEventSystem:Fire(ObjectEventType.FIGHT_EFFECT_CHANGE, false)
	end
end

function FightData:GetMainRoleEffectList()
	return self.main_role_effect_list or {}
end

function FightData:UpdateEffect(effect_list, effect)
	for i, v in ipairs(effect_list) do
		if v.unique_key == effect.unique_key then
			effect_list[i] = effect
			return
		end
	end
	table.insert(effect_list, effect)
end

-- 移除Effect
function FightData:OnEffectRemove(effect_key)
	for i, v in ipairs(self.main_role_effect_list) do
		if v.unique_key == effect_key then
			table.remove(self.main_role_effect_list, i)
			GlobalEventSystem:Fire(ObjectEventType.FIGHT_EFFECT_CHANGE, true)
			break
		end
	end
end

function FightData:HasEffectByClientType(client_type)
	for k, v in pairs(self.main_role_effect_list) do
		if v.client_effect_type == client_type then
			return true
		end
	end

	return false
end

-- vip加成
function FightData:GetMainRoleVipEffect()
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	if vip_level > 0 then
		local vip_cfg = VipData.Instance:GetVipBuffCfg(vip_level)
		if nil ~= vip_cfg then
			local effect = FightData.CreateEffectInfo()
			effect.unique_key = -1
			effect.client_effect_type = EFFECT_CLIENT_TYPE.ECT_OTHER_VIP
			effect.cd_time = 0
			for i = 1, 10 do
				effect.param_list[i] = 0
			end
			effect.param_list[3] = vip_cfg.gongji
			effect.param_list[6] = vip_cfg.fangyu
			effect.param_list[9] = vip_cfg.maxhp

			return effect
		end
	end

	return nil
end

-- 仙尊卡加成
function FightData:GetXianZunCardEffect(index)
	local immort_cfg = ImmortalData.Instance:GetCardDescCfg(index)
	if nil ~= immort_cfg then
		local effect = FightData.CreateEffectInfo()
		effect.unique_key = -3
		-- 仙尊卡buff3个对应的假的buffid，9006、9007、9008
		effect.client_effect_type = 9006 + index
		effect.cd_time = 0
		for i = 1, 10 do
			effect.param_list[i] = 0
		end
		-- effect.param_list[3] = immort_cfg.add_gongji
		-- effect.param_list[7] = immort_cfg.add_mojing_per / 100
		effect.param_list[10] = immort_cfg.add_exp_per / 100
		return effect
	end

	return nil
end


function FightData:GetBronzeXianZunCardActive()
	local is_active_card = ImmortalData.Instance:IsActive(0)
	return is_active_card
end

function FightData:GetSilverXianZunCardActive()
	local is_active_card = ImmortalData.Instance:IsActive(1)
	return is_active_card
end

function FightData:GetJewelXianZunCardActive()
	local is_active_card = ImmortalData.Instance:IsActive(2)
	return is_active_card
end


-- 世界加成
function FightData:GetWorldLevelEffect()
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local world_level = RankData.Instance:GetWordLevel()
	if role_level < COMMON_CONSTS.WORLD_LEVEL_OPEN or role_level >= world_level then
		return nil
	end

	local add_percent = PlayerData.Instance:GetWorldLevelExpAdd(role_level, world_level)
	local effect = FightData.CreateEffectInfo()
	effect.unique_key = -2
	effect.client_effect_type = EFFECT_CLIENT_TYPE.ECT_OTHER_SJJC
	effect.cd_time = 0
	for i = 1, 10 do
		effect.param_list[i] = 0
	end
	effect.param_list[2] = add_percent

	return effect
end

-- 世界boss死亡buff
function FightData:GetWorldBossDieEffect()
	local boss_weary = BossData.Instance:GetWroldBossWeary() or 0
	local last_die_time_value = BossData.Instance:GetWroldBossWearyLastRelive() or 0
	local last_die_time = last_die_time_value + 300 - TimeCtrl.Instance:GetServerTime()
	if boss_weary <= 0 or last_die_time_value <= 0 then
		return nil
	end

	local effect = FightData.CreateEffectInfo()
	effect.unique_key = -2
	effect.client_effect_type = EFFECT_CLIENT_TYPE.ECT_BOSS_PILAO
	effect.cd_time = last_die_time
	for i = 1, 10 do
		effect.param_list[i] = 0
	end
	effect.param_list[2] = boss_weary < 5 and boss_weary or 5

	return effect
end

-- 一战到底攻击鼓舞buff
function FightData:GetYiZhanDaoDiGuWuEffect()
	local buff_value = YiZhanDaoDiData.Instance:GetGuWuValue()
	if buff_value <= 0 then return nil end

	local effect = FightData.CreateEffectInfo()
	effect.unique_key = -2
	effect.client_effect_type = EFFECT_CLIENT_TYPE.BCT_YZDD_GJ_BUFF
	effect.cd_time = 0
	for i = 1, 10 do
		effect.param_list[i] = 0
	end
	effect.param_list[4] = buff_value

	return effect
end

-- 获取主角Effect列表
function FightData:GetMainRoleShowEffect()
	local BuffType = {
		SpecialBuff = 0,
		CommonBuff = 1,
		ExpBuff = 2,
		VipBuff = 3,
		XianZunBuff = 4,
		ImpExpBuff = 5,
		XianZunLegendBuff = 6,
		SpecidlExpBuffStop = 99,
	}

	local effect_list = {}
	local buff_num = 0

	local vip_effect = self:GetMainRoleVipEffect()
	local has_vip_buff = false

	local VipBuffType = {
		[EFFECT_CLIENT_TYPE.ECT_OTHER_VIP] = 1,
	}
	if nil ~= vip_effect then
		table.insert(effect_list, {type = BuffType.SpecialBuff, info = vip_effect})
		if nil ~= VipBuffType[vip_effect.client_effect_type] then
			has_vip_buff = true
		end
	end

	local world_effect = self:GetWorldLevelEffect()
	if nil ~= world_effect and world_effect.param_list and world_effect.param_list[2] and world_effect.param_list[2] > 0 then
		table.insert(effect_list, {type = BuffType.SpecialBuff, info = world_effect})
	end

	-- local boss_die_effect = self:GetWorldBossDieEffect()
	-- if nil ~= boss_die_effect then
	-- 	table.insert(effect_list, {type = BuffType.SpecialBuff, info = boss_die_effect})
	-- end

	local yizhandaodi_guwu_effect = self:GetYiZhanDaoDiGuWuEffect()
	if nil ~= yizhandaodi_guwu_effect then
		table.insert(effect_list, {type = BuffType.SpecialBuff, info = yizhandaodi_guwu_effect})
	end

	local cd_time = 0
	local ExeBuffType = {
		[EFFECT_CLIENT_TYPE.ECT_ITEM_EXP1] = 1,
		[EFFECT_CLIENT_TYPE.ECT_ITEM_EXP2] = 1,
		[EFFECT_CLIENT_TYPE.ECT_ITEM_EXP3] = 1,
		[EFFECT_CLIENT_TYPE.ECT_ITEM_EXP4] = 1,
		[EFFECT_CLIENT_TYPE.ECT_ITEM_IMP1] = 2,
		[EFFECT_CLIENT_TYPE.ECT_ITEM_IMP2] = 2,
	}

	local has_exp_buff = false
	local has_imp_exp_buff = false
	for k, v in pairs(self.main_role_effect_list) do
		if v.client_effect_type > 0 then
			if v.effect_type == FIGHT_EFFECT_TYPE.MOVESPEED then
				cd_time = v.param_list[3]
			else
				cd_time = v.param_list[1]
			end
			v.cd_time = math.max(cd_time / 1000 - (Status.NowTime - v.recv_time), 0)
			if 1 == ExeBuffType[v.client_effect_type] then
				has_exp_buff = true
			elseif 2 == ExeBuffType[v.client_effect_type] then
				has_imp_exp_buff = true
			end
			table.insert(effect_list, {type = BuffType.CommonBuff, info = v})
		end
	end

	local has_bronze_xianzun_buff = self:GetBronzeXianZunCardActive()
	-- local has_silver_xianzun_buff = self:GetSilverXianZunCardActive()
	-- local has_jewel_xianzun_buff = self:GetJewelXianZunCardActive()

	local has_xianzun_buff = has_bronze_xianzun_buff or has_silver_xianzun_buff or has_jewel_xianzun_buff

	if has_bronze_xianzun_buff then
		local xianzun_buff_effect = self:GetXianZunCardEffect(0)
		table.insert(effect_list, {type = BuffType.SpecialBuff, info = xianzun_buff_effect})
	end

	if self:GetIsHasOtherExpBuff() then
		local buff_list = self:GetOtherExpBuff()
		if buff_list then
			for k,v in pairs(buff_list) do
				table.insert(effect_list, {type = BuffType.SpecidlExpBuffStop, info = v})
			end
		end
	end

	local xianzun_active_list = ImmortalData.Instance:GetActiveList()
	local is_show_xianzun_buff = false
	if xianzun_active_list ~= nil then
		is_show_xianzun_buff = true
		for k, v in pairs(xianzun_active_list) do
			if not v then
				is_show_xianzun_buff = false
				break
			end
		end
	end
	if is_show_xianzun_buff then
		table.insert(effect_list, {type = BuffType.XianZunLegendBuff, info = {client_effect_type = 9009, cd_time = 0}})
	end
	-- if self.ra_is_has_first_recharge_attr_add == 1 then
	-- 	table.insert(effect_list, {type = BuffType.CommonBuff, info = {client_effect_type = 9010, cd_time = 0}})
	-- end	
	-- if has_silver_xianzun_buff then
	-- 	local xianzun_buff_effect = self:GetXianZunCardEffect(2)
	-- 	table.insert(effect_list, {type = BuffType.SpecialBuff, info = xianzun_buff_effect})
	-- end

	-- if has_jewel_xianzun_buff then
	-- 	local xianzun_buff_effect = self:GetXianZunCardEffect(3)
	-- 	table.insert(effect_list, {type = BuffType.SpecialBuff, info = xianzun_buff_effect})
	-- end

	buff_num = #effect_list

	-- 下面这块是未激活

	-- 没VIP加成的情况下
	-- type = 3 为VIP加成
	if not has_vip_buff then
		table.insert(effect_list, {type = BuffType.VipBuff})
	end

	-- 没经验加成的情况下显示经验药水快捷购买
	-- type = 2 为经验药水快捷购买
	if not has_exp_buff then
		table.insert(effect_list, {type = BuffType.ExpBuff})
	end

	-- 没激活任何一个仙尊卡的情况下跳转到仙尊卡界面
	-- type = 4 为仙尊卡未激活的时候跳转到仙尊卡界面
	if not has_xianzun_buff then
		table.insert(effect_list, {type = BuffType.XianZunBuff})
	end

	-- 没激活任何一个经验小鬼的情况下跳转到商城购买界面
	-- type = 5 
	if not has_imp_exp_buff then
		table.insert(effect_list, {type = BuffType.ImpExpBuff})
	end

	return effect_list, buff_num
end

function FightData:SetFirstRechargeBuff(ra_is_has_first_recharge_attr_add)
	self.ra_is_has_first_recharge_attr_add = ra_is_has_first_recharge_attr_add
end

-- 获取Effect描述
function FightData:GetEffectDesc(effect_info)
	local data = effect_info.info
	local cfg = ConfigManager.Instance:GetAutoConfig("buff_desc_auto").desc[data.client_effect_type]
	local desc = ""
	local name = ""
	if nil ~= cfg then
		name = cfg.name
		local i, j = 0, 0
		local last_pos = 1

		for loop_count = 1, 20 do
			i, j = string.find(cfg.desc, "(%[p_.-%])", j + 1)
			if nil == i or nil == j then
				desc = desc .. string.sub(cfg.desc, last_pos, -1)
				break
			else
				if last_pos ~= i then
					desc = desc .. string.sub(cfg.desc, last_pos, i - 1)
				end

				local str_arr = Split(string.sub(cfg.desc, i + 1, j - 1), "_")
				if #str_arr >= 2 then
					local index = tonumber(str_arr[2]) or 1
					local temp = data.param_list[index]
					if effect_info.type == 1 and (index == 1 or index == 3) and temp ~= nil and data.effect_type ~= FIGHT_EFFECT_TYPE.ATTR_PER then
						temp = temp / 1000
					end

					if "w" == str_arr[3] then
						desc = desc .. (temp or 0) / 100 .. "%"
					else
						desc = desc .. (math.ceil(temp or 0))
					end
				else
					desc = desc .. "nil"
				end
				last_pos = j + 1
			end
		end
	end
	return desc, name
end

function FightData:GetBeHitInfo(deliverer)
	return self.be_hit_list[deliverer]
end

function FightData:OnHitTrigger(deliverer, target_obj)
	local info = self.be_hit_list[deliverer]
	if nil ~= info and nil ~= target_obj then
		self:DoBeHit(info, deliverer:IsMainRole(), target_obj:GetObjId())
		self.be_hit_list[deliverer] = nil
	end
end

function FightData.CreateBeHitInfo(deliverer, skill_id)
	return {
		deliverer = deliverer,
		skill_id = skill_id,
		max_trigger_time = Status.NowTime + SkillData.GetSkillBloodDelay(skill_id),
		hit_info_list = {}
	}
end

function FightData:SaveBeHitInfo(obj_id, deliverer_id, skill_id, real_blood, blood, fighttype, nvshen_hurt, lingchong_hurt)
	local deliverer = Scene.Instance:GetObj(deliverer_id)
	if deliverer == nil then
		return
	end

	if nil ~= self.be_hit_list[deliverer] then
		local info = self.be_hit_list[deliverer]
		if skill_id ~= info.skill_id or Status.NowTime - info.max_trigger_time > 0.1 then
			self:DoBeHit(info, false, nil)
			self.be_hit_list[deliverer] = FightData.CreateBeHitInfo(deliverer, skill_id)
		end
	else
		self.be_hit_list[deliverer] = FightData.CreateBeHitInfo(deliverer, skill_id)
	end

	table.insert(self.be_hit_list[deliverer].hit_info_list, {
		obj = Scene.Instance:GetObj(obj_id),
		real_blood = real_blood,
		blood = blood,
		fighttype = fighttype,
		nvshen_hurt = nvshen_hurt,
		lingchong_hurt = lingchong_hurt,
	})
end

function FightData:DoBeHit(info, is_main_role, target_obj_id)
	for k, v in pairs(info.hit_info_list) do
		if v.obj ~= nil and not v.obj:IsDeleted() and v.obj:IsCharacter() then
			v.obj:DoBeHit(info.deliverer, info.skill_id, v.real_blood, v.blood, v.fighttype)
			if v.nvshen_hurt and v.nvshen_hurt < 0 then
				v.obj:DoBeHit(info.deliverer, 0, 0, v.nvshen_hurt, v.fighttype, FIGHT_TEXT_TYPE.NVSHEN)
			end
			if v.lingchong_hurt and v.lingchong_hurt < 0 then
				v.obj:DoBeHit(info.deliverer, 0, 0, v.lingchong_hurt, v.fighttype, FIGHT_TYPE.LINGCHONG)
			end
			if not is_main_role or v.obj_id ~= target_obj_id then
				v.obj:DoBeHitShow(info.deliverer, info.skill_id, target_obj_id)
			end
		end
	end
end

function FightData:GetBuffDescCfgByType(effect_type)
	return ConfigManager.Instance:GetAutoConfig("buff_desc_auto").desc[effect_type]
end

function FightData:GetMainRoleDrugAddExp()
	if #self.main_role_effect_list == 0 then return 0 end
	local effect_type = 0
	for k,v in pairs(self.main_role_effect_list) do
		if v.client_effect_type == 2201 or v.client_effect_type == 2202 or v.client_effect_type == 2203 or v.client_effect_type == 2204 then
			return v.param_list[3]
		end
	end
	return 0
end

function FightData:GetIsFightbackObj(fightback)
	return Scene.Instance:GetSceneId() == 103 and fightback ~= GameEnum.NAME_COLOR_WHITE
end