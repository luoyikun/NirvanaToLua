--------------------------------------------------------
--技能数据管理
--------------------------------------------------------
SkillData = SkillData or BaseClass()

SkillData.ANGER_SKILL_ID = 5
SkillData.SKILL_INFO_GET = false
SkillData.PROFESSOIN_SKILL_NUM = 7	-- 主动技能数

local KILL_SKILL_ID = 5			-- 必杀技ID
local PASSVIE_SKILL_ID_STAR = 41	-- 被动技能起始ID
local PASSVIE_SKILL_ID_END = 47		-- 被动技能结束ID
local TIANSHU_SKILL_ID_STAR = 800 	-- 天书技能起始ID
local TIANSHU_SKILL_ID_END = 803	-- 天书技能结束ID

KILL_SKILL = {[1] = 101, [2] = 201, [3] = 301, [4] = 401}			-- 怒气招
ZHUAN_ZHI_SKILL1 = {[1] = 182, [2] = 184, [3] = 186, [4] = 188}			-- 转职技能1
ZHUAN_ZHI_SKILL2 = {[1] = 183, [2] = 185, [3] = 187, [4] = 189}			-- 转职技能2
ZHUAN_ZHI_SKILL_MIN, ZHUAN_ZHI_SKILL_MAX = 180, 189						-- 专职技能取值范围

local use_prof_normal_skill_list = {
		111, 211, 311, 411,
	}
function SkillData:__init()
	if SkillData.Instance then
		print_error("[SkillData] Attemp to create a singleton twice !")
	end
	SkillData.Instance = self

	self.default_skill_index = 0
	self.skill_list = {}
	self.global_cd_end = 0

	self.UP_SKILL_ITEM_ID = 26500
	self.other_skill_info = {}
	self.goddes_skill_id = 0
	self.mieShi_skill_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("rolegoalconfig_auto").skill, "skill_type", "skill_level")
	self.innate_skill_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("role_talent_auto").talent_level_max, "talent_type", "talent_id")
	self.innate_skill_talent_type_cfg = ListToMapList(ConfigManager.Instance:GetAutoConfig("role_talent_auto").talent_level_max, "talent_type")
	self.talent_point_cfg = ConfigManager.Instance:GetAutoConfig("role_talent_auto").level_add_talent_point

	RemindManager.Instance:Register(RemindName.PlayerActiveSkill, BindTool.Bind(self.GetActiveSkillRemind, self))
	RemindManager.Instance:Register(RemindName.PlayerPassiveSkill, BindTool.Bind(self.GetPassiveSkillRemind, self))
	RemindManager.Instance:Register(RemindName.PlayerInnateSkill, BindTool.Bind(self.GetInnateSkillRemind, self))
	RemindManager.Instance:Register(RemindName.PlayerSkill, BindTool.Bind(self.GetAllSkillRemind, self))
end

function SkillData:__delete()
	RemindManager.Instance:UnRegister(RemindName.PlayerActiveSkill)
	RemindManager.Instance:UnRegister(RemindName.PlayerPassiveSkill)
	RemindManager.Instance:UnRegister(RemindName.PlayerInnateSkill)
	RemindManager.Instance:UnRegister(RemindName.PlayerSkill)
	
	SkillData.Instance = nil
	self.skill_list = {}
end

function SkillData:GetDefaultSkillIndex()
	return self.default_skill_index
end

function SkillData:SetDefaultSkillIndex(default_skill_index)
	self.default_skill_index = default_skill_index
end

function SkillData:SetSkillList(skill_list)
	SkillData.SKILL_INFO_GET = true
	self.skill_list = {}
	for k, v in pairs(skill_list) do
		self.skill_list[v.skill_id] = v
		self:CalcSkillCondition(v)
	end
	GlobalEventSystem:Fire(MainUIEventType.ROLE_SKILL_CHANGE, "list")
end

function SkillData:SetSkillInfo(skill_info)
	self.skill_list[skill_info.skill_id] = skill_info
	self:CalcSkillCondition(skill_info)
	GlobalEventSystem:Fire(MainUIEventType.ROLE_SKILL_CHANGE, "skill", skill_info.skill_id)
end

function SkillData:CalcSkillCondition(skill_info)
	skill_info.cd_end_time = 0
	skill_info.cost_mp = 0

	local cfg = SkillData.GetSkillConfigByIdLevel(skill_info.skill_id, skill_info.level)
	if cfg ~= nil then
		local cd = math.min(skill_info.last_perform + cfg.cd_s - TimeCtrl.Instance:GetServerTime(), cfg.cd_s)
		skill_info.cd_end_time = Status.NowTime + cd
		skill_info.cost_mp = cfg.cost_mp or 0
	end
end

function SkillData:GetNextLevelSkillVo(skill_id)
	local skill_info = self:GetSkillInfoById(skill_id)
	local now_level = skill_info ~= nil and skill_info.level or 0
	return self.GetSkillConfigByIdLevel(skill_id,now_level + 1)
end

function SkillData:GetLearnSkillIsEnoughLevel(skill_id)
	local next_skill_vo = self:GetNextLevelSkillVo(skill_id)
	if next_skill_vo ~= nil and next_skill_vo.learn_level_limit > PlayerData.Instance.role_vo.level then
		return false
	end
	return true
end

function SkillData:GetLeanSkillIEnoughNWS(skill_id)
	local next_skill_vo = self:GetNextLevelSkillVo(skill_id)
	if next_skill_vo ~= nil and next_skill_vo.zhenqi_cost > PlayerData.Instance.role_vo.nv_wa_shi then
		return false
	end
	return true
end

function SkillData:GetLeanSkillIEnoughCoin(skill_id)
	local next_skill_vo = self:GetNextLevelSkillVo(skill_id)
	if next_skill_vo ~= nil and not PlayerData.GetIsEnoughAllCoin(next_skill_vo.coin_cost) then
		return false
	end
	return true
end

--根据技能id获得info
function SkillData:GetSkillInfoById(skill_id)
	return self.skill_list[skill_id]
end


--获取当前的仙女技能
function SkillData:GetCurGoddessSkill()
	if self.goddes_skill_id > 0 and nil ~= self.skill_list[self.goddes_skill_id] then
		return self.skill_list[self.goddes_skill_id]
	end

	for k,v in pairs(self.skill_list) do
		if GoddessData.Instance:IsGoddessSkill(k) then
			self.goddes_skill_id = k -- 缓存防止每次战斗进行查询
			return v
		end
	end

	return nil
end

function SkillData:GetSkillIndex(skill_id)
	if nil == self.skill_list[skill_id] then
		return 0
	end
	return self.skill_list[skill_id].index
end

function SkillData:GetRealSkillIndex(skill_id)
	local index = self:GetSkillIndex(skill_id)
	if PlayerData.Instance.role_vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR then
		local special_skills = ClashTerritoryData.Instance:GetSkillList()
		for k,v in pairs(special_skills) do
			if index == 3 then
				if v.skill_index > 3 then
					return v.skill_index
				end
			elseif v.skill_index <= 3 then
				return v.skill_index
			end
		end
	elseif Scene.Instance:GetSceneType() == SceneType.FarmHunting then
		local skill_index = FarmHuntingData.Instance:GetFarmSkillIndex(skill_id)
		if skill_index >= 0 then
			return skill_index
		end
	end
	return index
end

function SkillData:GetSkillCDEndTime(skill_id)
	if nil == self.skill_list[skill_id] then
		return self.global_cd_end
	end

	return math.max(self.global_cd_end, self.skill_list[skill_id].cd_end_time)
end

function SkillData:GetGlobalCDEndTime()
	return self.global_cd_end
end

function SkillData:GetSkillList()
	return self.skill_list
end

function SkillData:IsSkillCD(skill_id)
	if PlayerData.Instance.role_vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR then
		local index = self:GetRealSkillIndex(skill_id)
		local special_skill =  ClashTerritoryData.Instance:GetSkillInfoById(index)
		if nil == special_skill or special_skill.cd_end_time > Status.NowTime then
			return true
		else
			return false
		end
	end
	-- if skill_id == SkillData.ANGER_SKILL_ID then
	-- 	return PlayerData.Instance.role_vo.nuqi < COMMON_CONSTS.NUQI_FULL
	-- end
	local skill_info = self:GetSkillInfoById(skill_id)
	if nil == skill_info or skill_info.cd_end_time > Status.NowTime then
		return true
	end
	return false
end

function SkillData:CanUseSkill(skill_id, ignore_global_cd)
	if PlayerData.Instance.role_vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR then
		local index = self:GetRealSkillIndex(skill_id)
		local special_skill = ClashTerritoryData.Instance:GetSkillInfoById(index)
		if special_skill then
			if not ignore_global_cd and special_skill.cd_end_time > Status.NowTime then
				return false, 0
			else
				local cfg = ClashTerritoryData.Instance:GetTerritorySkillCfg(index)
				if cfg == nil then
					return false, 0
				end
				return true, cfg.distance or 1
			end
		end
	end

	if Scene.Instance:GetSceneType() == SceneType.FarmHunting then
		local skill_index = FarmHuntingData.Instance:GetFarmSkillIndex(skill_id)
		if skill_index >= 0 then
			local role_skill_cfg = FarmHuntingData.Instance:GetRoleSkillCfgBySkillId(skill_id)
			return true, role_skill_cfg.distance
		end
	end

	local skill_info = self:GetSkillInfoById(skill_id)
	if nil == skill_info or skill_info.cd_end_time > Status.NowTime then
		return false, 0, Language.Common.SkillCD
	end

	if not ignore_global_cd and self.global_cd_end > Status.NowTime then
		return false, 0
	end

	if PlayerData.Instance:GetAttr("mp") < skill_info.cost_mp then
		return false, 0
	end

	local prof = PlayerData.Instance:GetRoleBaseProf()
	if skill_id == ZHUAN_ZHI_SKILL1[prof] then
		local skill_cfg = SkillData.GetNormalSkillinfoConfig(skill_id)
		return true, skill_cfg.distance or 1
	end

	local cfg = SkillData.GetSkillConfigByIdLevel(skill_info.skill_id, skill_info.level)
	if cfg == nil then
		return false, 0
	end

	return true, cfg.distance or 1
end

function SkillData:UseSkill(skill_id)
	self.global_cd_end = Status.NowTime + 0.3

	local skill_info = self:GetSkillInfoById(skill_id)
	if nil ~= skill_info then
		local cfg = SkillData.GetSkillConfigByIdLevel(skill_info.skill_id, skill_info.level)
		local count_cd = ShengXiaoData.Instance:GetMijiToSkillCd()
		local cd_s = cfg.cd_s
		if count_cd ~= 0 then
			cd_s = cd_s - cd_s * count_cd / 10000
		end
		if nil ~= cfg then
			if cfg.cd_s > 0  then
				skill_info.cd_end_time = Status.NowTime + cd_s
			else
				skill_info.cd_end_time = Status.NowTime + cd_s + 0.3
			end
		end
	end
	if PlayerData.Instance.role_vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR then
		local spec_skill = ClashTerritoryData.Instance:GetSkillInfoById(skill_id)
		if spec_skill then
			local cfg = ClashTerritoryData.Instance:GetTerritorySkillCfg(skill_id)
			if nil ~= cfg then
				if cfg.cd_s > 0  then
					spec_skill.cd_end_time = Status.NowTime + cfg.cd_s
				else
					spec_skill.cd_end_time = Status.NowTime + cfg.cd_s + 0.3
				end
			end
		end
	end
	GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_USE_SKILL, skill_id)

	if skill_info then
		local skill_rest_time_data = {}
		skill_rest_time_data.skill_index = MainUIData.Instance:GetSkillIndexBySkillId(skill_id) or 0
		skill_rest_time_data.skill_id = skill_id or 0
		skill_rest_time_data.cd_end_time = skill_info.cd_end_time - Status.NowTime
		MainUIData.Instance:SetSkillRestTimeData(skill_rest_time_data)
	end
	IosAuditSender:UpdateSkillRestTime()
end

function SkillData.IsBuffSkill(skill_id)
	local client_cfg = SkillData.GetSkillinfoConfig(skill_id)
	if client_cfg and client_cfg.is_buff == 1 then
		return true
	end
	return false
end


--根据id和等级获得技能Config
function SkillData.GetSkillConfigByIdLevel(skill_id, level)
	local roleskill_auto = ConfigManager.Instance:GetAutoConfig("roleskill_auto")
	local cfg = roleskill_auto.normal_skill[skill_id]
	if cfg ~= nil then
		return cfg
	end
	cfg = roleskill_auto["s" .. skill_id]
	if cfg ~= nil then
		return cfg[level]
	end

	return nil
end

function SkillData.GetSkillarchConfig(bskill_id)
	return ConfigManager.Instance:GetAutoConfig("roleskill_auto").skillarch[bskill_id]
end

function SkillData.GetSkillinfoConfig(skill_id)
	return ConfigManager.Instance:GetAutoConfig("roleskill_auto").skillinfo[skill_id]
end

function SkillData.GetNormalSkillinfoConfig(skill_id)
	return ConfigManager.Instance:GetAutoConfig("roleskill_auto").normal_skill[skill_id]
end

function SkillData.GetSkillCanMove(skill_id)
	if ConfigManager.Instance:GetAutoConfig("roleskill_auto").skillinfo[skill_id] then
		return ConfigManager.Instance:GetAutoConfig("roleskill_auto").skillinfo[skill_id].can_move == 1
	end
	return false
end

local skill_info_cfg = nil
function SkillData.GetSkillBloodDelay(skill_id)
	skill_info_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto").skillinfo[skill_id]
	return skill_info_cfg and skill_info_cfg.blood_delay or 0.1
end

function SkillData.IsAoeSkill(skill_id)
	local skill_config = SkillData.GetSkillConfigByIdLevel(skill_id, 1)
	if nil ~= skill_config then
		return skill_config.enemy_num > 1
	end

	skill_config = ConfigManager.Instance:GetAutoConfig("monsterskill_auto").skill_list[skill_id]
	if nil ~= skill_config then
		return skill_config.is_aoe == 1
	end

	return false
end

-- 非普通攻击
--[[local normal_skill_list = {
	{111, 112, 113},
	{211, 212, 213},
	{311, 312, 313},
	{411, 412, 413},
}]]

function SkillData.IsNotNormalSkill(skill_id)
	--[[for _, v in ipairs(normal_skill_list) do
		for _, sid in ipairs(v) do
			if sid == skill_id then
				return false
			end
		end
	end

	return true]]
	local prof = PlayerData.Instance:GetRoleBaseProf()

	return not ((skill_id >= 111 and skill_id <= 113) or
		(skill_id >= 211 and skill_id <= 213) or
		(skill_id >= 311 and skill_id <= 313) or
		(skill_id >= 411 and skill_id <= 413) or
		ZHUAN_ZHI_SKILL1[prof])
end

function SkillData.GetMonsterSkillConfig(skill_id)
	return ConfigManager.Instance:GetAutoConfig("monsterskill_auto").skill_list[skill_id]
end

function SkillData.RepleCfgContent(source, skill_vo)
	if not source or not skill_vo then
		return ""
	end
	local len = string.len(source)
	local rule = '%[([^%]]-)%]%%'
	local key = ""
	local rep = ""

	local var = 1
	while var <= len do
		var = var + 1
		local i, j = string.find(source, rule)
		if i and i < var then
			var = j
			key = string.sub(source, i + 1, j - 2)
			rep = skill_vo[key] / 100
			source = string.gsub(source, '%[' .. key .. '%]%%', rep .. "%%")
		end
	end

	len = string.len(source)
	rule = '%[(.-)%]'
	var = 1
	while var <= len do
		var = var + 1
		local i, j = string.find(source, rule)
		if i and i < var then
			var = j
			key = string.sub(source, i + 1, j -1)
			rep = skill_vo[key]
			source = string.gsub(source, '%[' .. key .. '%]', rep)
		end
	end
	return source
end

--获得某个技能的可学习状态
--应付多种状态，使用时用取模方法
-- function SkillData:GetLearnSkillStatus(skill_id)
-- 	local flag = 0
-- 	local skill_info = self:GetSkillInfoById(skill_id)
-- 	local now_level = skill_info ~= nil and skill_info.level or 0

-- 	local next_skill_vo = self.GetSkillConfigByIdLevel(skill_id,now_level + 1)
-- 	if next_skill_vo == nil then
-- 		flag = 10000 			--满级
-- 		return flag
-- 	end
-- 	if next_skill_vo.learn_level_limit > PlayerData.Instance.role_vo.level then
-- 		flag = 10000 + 1		--人物等级不足
-- 	elseif next_skill_vo.zhenqi_cost ~= 0 and next_skill_vo.zhenqi_cost > PlayerData.Instance.role_vo.nv_wa_shi then
-- 		flag = 10000 + 1 * 10 	--女娲石
-- 	elseif not self:GetLeanSkillIEnoughCoin(skill_id) then
-- 		flag = 10000 + 1 * 100 	--铜币不足
-- 	elseif "" ~= next_skill_vo.item_cost and 0 ~= next_skill_vo.item_cost
-- 		and ItemData.Instance:GetItemNumInBagById(self.UP_SKILL_ITEM_ID) < next_skill_vo.item_cost then
-- 		flag = 10000 + 1 * 1000 	--物品不足
-- 	end
-- 	if flag ~= 0 then	--若不能升级学习直接返回
-- 		return flag
-- 	end
-- 	flag = 20000
-- 	if now_level == 0 then
-- 		flag = 20000			--可学
-- 	else
-- 		flag = 20000 + 1 * 10	--可升级
-- 	end
-- 	return flag
-- end

function SkillData:SetSkillOtherSkillInfo(protocol)
	if protocol.skill124_effect_baoji == 1  and nil ~= self.other_skill_info.skill124_effect_star then
		self.other_skill_info.skill124_effect_star = self.other_skill_info.skill124_effect_star + 1
	else
		self.other_skill_info.skill124_effect_star = protocol.skill124_effect_star
	end
	self.other_skill_info.skill124_effect_baoji = protocol.skill124_effect_baoji
end

function SkillData:CheckIsNew(skill_list, is_init)
	if is_init == 1 then
		return
	end

	for k, v in pairs(skill_list) do
		if self.skill_list[v.skill_id] == nil then
			TipsCtrl.Instance:ShowGetNewSkillView(v.skill_id)
			break
		end
	end
end

function SkillData:GetActiveSkillRemind()
	local mojing_num = ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.MOJING)
	local profession_skill_data = self:GetActiveSkillListCfg()
	local roleskill_auto = ConfigManager.Instance:GetAutoConfig("roleskill_auto")

	for k,v in pairs(profession_skill_data) do
		if self:CanSkillUpLevel(v.skill_id) and not (v.skill_id >= ZHUAN_ZHI_SKILL_MIN and v.skill_id <= ZHUAN_ZHI_SKILL_MAX) then
			local skill_info = self:GetSkillInfoById(v.skill_id)
			if skill_info then
				local skill_level = skill_info.level or 1
				local skill_cfg = roleskill_auto["s" .. v.skill_id]
				if skill_cfg and skill_cfg[skill_level + 1] and mojing_num > skill_cfg[skill_level + 1].mojing_cost then
					return 1
				end
			end
		end
	end
	return 0
end

function SkillData:GetInnateSkillRemind()
	--判断功能开启
	if not OpenFunData.Instance:CheckIsHide("role_innate_skill") then
		return 0
	end
	local _, zhuan = PlayerData.Instance:GetRoleBaseProf()
	local skill_num = self:GetRoleTalentPoint()
	local other_cfg = self:GetRoleTalentSkillResetItem()
	-- local is_complet = TaskData.Instance:GetTaskIsCompleted(task_id)

	local need_find_max_type = 3

	local function is_remind_by_type(num_type)
		local cont_num = self:GetRoleTalentSkillTypeLevel(num_type)
		local max_num = self:GetTalentCfgSkillCount(num_type)
		if cont_num < max_num then
			return 1
		end
		return 0
	end

	if skill_num > 0 then
		for i = 1, need_find_max_type do
			if i <= 2 and self:GetInnateSkillOpen("zhuan_gongfang") <= zhuan then
				if is_remind_by_type(i) == 1 then
					return 1
				end
			elseif i == 3 and self:GetInnateSkillOpen("zhuan_tongyong") <= zhuan then
				if is_remind_by_type(i) == 1 then
					return 1
				end
			elseif i == 4 and self:GetInnateSkillOpen("zhuan_jingtong") <= zhuan then
				if is_remind_by_type(i) == 1 then
					return 1
				end
			end
		end
	end

	return 0
end

function SkillData:GetAllSkillRemind()
	if self:GetPassiveSkillRemind() == 1 
		or self:GetActiveSkillRemind() == 1 
		or self:GetInnateSkillRemind() == 1 then
		return 1
	end
	return 0
end

function SkillData:GetPassiveSkillRemind()
	return self:IsShowSkillRedPoint() and 1 or 0
end

function SkillData:IsShowSkillRedPoint()
	for i = 41, 47 do
		if self:CanSkillUpLevel(i) then
			return true
		end
	end
	return self:CanMieShiSkillUpLevel()
end

function SkillData:CanMieShiSkillUpLevel()
	self.mieshi_skill_level_list = PlayerData.Instance:GetSkillLevelList()
	local role_prof = PlayerData.Instance:GetRoleBaseProf()

	for i = 1, 3 do
		local skill_cfg = self.mieShi_skill_cfg[i]
		if skill_cfg then
			local current_level = self.mieshi_skill_level_list[i]
			local level_cfg = skill_cfg[current_level]
			if nil ~= level_cfg and current_level < #skill_cfg then
				local material_info = level_cfg["uplevel_stuff_prof" .. role_prof]
				if nil ~= material_info and ItemData.Instance:GetItemNumInBagById(material_info.item_id) >= material_info.num then
					return true
				end
			end
		end
	end

	return false
end

function SkillData:CanSkillUpLevel(skill_id)
	local skill_info = self:GetSkillInfoById(skill_id)
	local skill_level = skill_info and skill_info.level or 0
	local skill_cfg = SkillData.GetSkillConfigByIdLevel(skill_id, skill_level + 1)

	return nil ~= skill_cfg
		and PlayerData.Instance:GetAttr("level") >= skill_cfg.learn_level_limit
		and skill_cfg.item_cost <= ItemData.Instance:GetItemNumInBagById(skill_cfg.item_cost_id)
end

function SkillData.RepleCfgContent(skill_id, level)
	local cfg = SkillData.GetSkillinfoConfig(skill_id)
	local source = cfg and cfg.skill_desc or nil
	local skill_vo = SkillData.GetSkillConfigByIdLevel(skill_id, level)
	if not source or not skill_vo then
		return ""
	end
	local len = string.len(source)
	local rule = '%[([^%]]-)%]%%'
	local key = ""
	local rep = ""

	local var = 1
	while var <= len do
		var = var + 1
		local i, j = string.find(source, rule)
		if i and i < var then
			var = j
			key = string.sub(source, i + 1, j - 2)
			rep = skill_vo[key] / 100
			source = string.gsub(source, '%[' .. key .. '%]%%', rep .. "%%")
		end
	end
	len = string.len(source)
	rule = '%[(.-)%]'
	var = 1
	while var <= len do
		var = var + 1
		local i, j = string.find(source, rule)
		if i and i < var then
		  var = j
		  key = string.sub(source, i + 1, j -1)
		  rep = skill_vo[key]
		  source = string.gsub(source, '%[' .. key .. '%]', rep)
		end
	end
	len = string.len(source)
	rule = '%((.-)%)%%'
	var = 1
	while var <= len do
		var = var + 1
		local i, j = string.find(source, rule)
		if i and i < var then
		  var = j
		  key = string.sub(source, i + 1, j - 2)
		  rep = skill_vo[key] / 1000
		  source = string.gsub(source, '%(' .. key .. '%)%%', rep)
		end
	end
	return source
end

function SkillData:GetPassvieSkillCanUpLevelIndexList(skill_list)
	local list = {}

	for k, v in pairs(skill_list) do
		if self:CanSkillUpLevel(v.skill_id) then
			table.insert(list, k)
		end
	end

	return list
end

-- 客户端记录角色技能增加的熟练度
function SkillData:RecordSkillProficiency(skill_id)
	if nil ~= self.skill_list[skill_id] then
		self.skill_list[skill_id].exp = self.skill_list[skill_id].exp + 1
	end
end

function SkillData:GetSkillProficiency(skill_id)
	if nil ~= self.skill_list[skill_id] then
		return self.skill_list[skill_id].exp
	end
	return 0
end

function SkillData:GetActiveSkillListCfg()
	local profession_skill_data = {}
	local roleskill_auto = ConfigManager.Instance:GetAutoConfig("roleskill_auto")
	local skillinfo = roleskill_auto.skillinfo
	local prof = PlayerData.Instance:GetRoleBaseProf()
	for skill_id, v in pairs(skillinfo) do

		if skill_id == ZHUAN_ZHI_SKILL1[prof] then
			profession_skill_data[SkillData.PROFESSOIN_SKILL_NUM - 1] = v
		elseif skill_id == ZHUAN_ZHI_SKILL2[prof] then
			profession_skill_data[SkillData.PROFESSOIN_SKILL_NUM] = v
		elseif prof == math.modf(skill_id / 100) then	--or skill_id == KILL_SKILL_ID then
			profession_skill_data[v.skill_index] = v
		end
	end
	return profession_skill_data
end

function SkillData:GetPassiveSkillListCfg()
	local passive_skill_data = {}
	local roleskill_auto = ConfigManager.Instance:GetAutoConfig("roleskill_auto")
	local skillinfo = roleskill_auto.skillinfo

	for skill_id, v in pairs(skillinfo) do
		for i = PASSVIE_SKILL_ID_STAR, PASSVIE_SKILL_ID_END do
			if i == skill_id then
				passive_skill_data[v.skill_index] = v
			end
		end
	end
	return passive_skill_data
end

function SkillData:GetTianShuSkillListCfg()
	local tianshu_skill_data = {}
	local roleskill_auto = ConfigManager.Instance:GetAutoConfig("roleskill_auto")
	local skillinfo = roleskill_auto.skillinfo

	for skill_id, v in pairs(skillinfo) do
		for i = TIANSHU_SKILL_ID_STAR, TIANSHU_SKILL_ID_END do
			if i == skill_id then
				tianshu_skill_data[v.skill_index] = v
			end
		end
	end
	return tianshu_skill_data
end


------------------------------角色天赋-----------------------------------
function SkillData:InitTalentSkillCtg()
	self.talent_skill_cfg = {}
	local role_talent_auto = ConfigManager.Instance:GetAutoConfig("role_talent_auto")
	for k, v in ipairs(role_talent_auto.talent_level_max)do
		if self.talent_skill_cfg[v.talent_type] == nil then
			self.talent_skill_cfg[v.talent_type] = {}
		end
		table.insert(self.talent_skill_cfg[v.talent_type], v)
	end
end

function SkillData:GetRoleTalentSkillCfg(talent_id, talent_level)
	local role_talent_auto = ConfigManager.Instance:GetAutoConfig("role_talent_auto")
	for k,v in ipairs(role_talent_auto.talent_level_cfg)do
		if v.talent_id == talent_id and v.talent_level == talent_level then
			return v
		end
	end
end

function SkillData:SetRoleTelentInfo(protocol)
	self.talent_level_list = protocol.talent_level_list
	self.talent_point = protocol.talent_point
end

function SkillData:GetRoleTalentPoint()
	return self.talent_point or 0
end

function SkillData:SetRoleTalentLevelList(type_id)
	self:InitTalentSkillCtg()
	local skill_cfg = TableCopy(self.talent_skill_cfg[type_id]) or {}
	for k, v in ipairs(skill_cfg)do
		local index_id = v.talent_id % 100 + 1
		if self.talent_level_list and self.talent_level_list[type_id][index_id] then
			v.level = self.talent_level_list[type_id][index_id]
		else
			v.level = 0
		end
	end
	return skill_cfg
end

--获取属性激活数量
function SkillData:GetRoleTalentSkillTypeLevel(type_id)
	if self.talent_level_list[type_id] == nil then return 0 end
	local all_level = 0
	for k,v in ipairs(self.talent_level_list[type_id])do
		all_level = all_level + v
	end
	return all_level
end

--获取全部属性激活的总数量
function SkillData:GetRoleTalentAllSkillType()
	local all_level = 0
	for i = 1, 4 do
		local level = self:GetRoleTalentSkillTypeLevel(i)
		all_level = all_level + level
	end
	return all_level
end

function SkillData:GetRoleTalentSkillLevel(talent_id)
	for talent_type, skill_list in ipairs(self.talent_skill_cfg)do
		for k,v in ipairs(skill_list)do
			if v.talent_id == talent_id then
				local index_id = v.talent_id % 100 + 1			--服务端根据id大小排序下发协议
				return self.talent_level_list[talent_type][index_id]
			end
		end
	end
end

function SkillData:GetRoleTalentSkillName(talent_id)
	local role_talent_auto = ConfigManager.Instance:GetAutoConfig("role_talent_auto")
	for k, v in ipairs(role_talent_auto.talent_level_max)do
		if v.talent_id == talent_id then
			return v.name
		end
	end
end

function SkillData:GetRoleTalentSkillResetItem()
	return ConfigManager.Instance:GetAutoConfig("role_talent_auto").other[1]
end

function SkillData:GetTalentCfgSkillCount(type_id)
	if self.innate_skill_cfg[type_id] == nil then return 0 end

	local count = 0 
	for k, v in pairs(self.innate_skill_cfg[type_id])do
		count = count + v.max_level
	end
	return count
end

function SkillData:GetAllTalentCfgSkillCount()
	local all_level = 0
	for i = 1, 4 do
		local level = self:GetTalentCfgSkillCount(i)
		all_level = all_level + level
	end
	return all_level
end

function SkillData:GetProfSkillRange()
	local role_prof = GameVoManager.Instance:GetMainRoleVo() and GameVoManager.Instance:GetMainRoleVo().prof or 1
	local prof = PlayerData.Instance:GetRoleBaseProf(role_prof)
	local can_use, skill_range = self:CanUseSkill(use_prof_normal_skill_list[prof])
	return skill_range or 6
end

-- 转职之后技能目标数加一(没配置)
function SkillData:GetSkillIsAddTarget(skill_id)
	local prof, zhuan = PlayerData.Instance:GetRoleBaseProf()
	if zhuan < 1 then 
		return 0
	end
	local tab = {
		[111] = 2, [121] = 0, [131] = 0, [141] = 0,
		[211] = 2, [221] = 0, [231] = 0, [241] = 0,
		[311] = 2, [321] = 0, [331] = 0, [341] = 0,
		[411] = 2, [421] = 0, [431] = 0, [441] = 0,
	}
	return tab[skill_id] or 0
end

function SkillData:GetInnateSkillOpen(skill_type)
	local cfg = ConfigManager.Instance:GetAutoConfig("role_talent_auto").other[1]
	if skill_type == "zhuan_gongfang" then
		return cfg.zhuan_gongfang
	elseif skill_type == "zhuan_tongyong" then
		return cfg.zhuan_tongyong
	elseif skill_type == "zhuan_jingtong" then
		return cfg.zhuan_jingtong
	end
end


----------------战场变身------------------------------------
function SkillData:SetBianShenInfo(protocol)
	self.cur_die_times = protocol.cur_die_times
	self.end_bianshen_stamp = protocol.end_bianshen_stamp
end

function SkillData:GetBianShenTime()
	return self.cur_die_times or 0
end

function SkillData:GetBianshenReduceTime()
	local now_time = TimeCtrl.Instance:GetServerTime()
	local re_time = (self.end_bianshen_stamp - now_time)
	return re_time
end

function SkillData:GetWarSceneCfg()
	if self.war_scene_skill_cfg == nil then
		self.war_scene_skill_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("bianshen_config_auto").skill_list_cfg, "skill_id")
	end

	return self.war_scene_skill_cfg or {}
end

function SkillData:GetShowWarSceneList()
	if self.war_scene_show_cfg == nil then
		self.war_scene_show_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("bianshen_config_auto").valid_scene_cfg, "scene_type")
	end	

	return self.war_scene_show_cfg or {}
end

function SkillData:GetWarSceneOtherCfg()
	if self.war_scene_other_cfg == nil then
		self.war_scene_other_cfg = ConfigManager.Instance:GetAutoConfig("bianshen_config_auto").other or {}
	end

	return self.war_scene_other_cfg[1] or {}
end

function SkillData:CheckIsWarSceneSkill(skill)
	if skill == nil then
		return false, {}
	end

	local cfg = self:GetWarSceneCfg()
	return cfg[skill] ~= nil, cfg[skill]
end

function SkillData:GetWarSceneAngerSkill()
	local skill_id = nil
	local cfg = self:GetWarSceneCfg()
	for k,v in pairs(cfg) do
		if v.index == 4 then
			if self:GetSkillInfoById(v.skill_id) then
				skill_id = v.skill_id
				break
			end
		end
	end

	return skill_id
end

function SkillData:GetUseWarSceneSkill()
	local skill_list = nil

	local cfg = self:GetWarSceneCfg()
	for k,v in pairs(cfg) do
		if v ~= nil and self:GetSkillInfoById(v.skill_id) then
			if skill_list == nil then
				skill_list = {}
			end

			table.insert(skill_list, v.skill_id)
		end
	end

	return skill_list
end

function SkillData:GetUseWarSceneSkill(talent_type, talent_index)
	local cfg = self.innate_skill_talent_type_cfg[talent_type]
	return cfg and cfg[talent_index]
end

function SkillData:GetNextTalentPointLevel()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo then
		local level = main_role_vo.level
		if self.talent_point_cfg then
			for i,v in ipairs(self.talent_point_cfg) do
				if v.level and level and v.level > level and v.add_talent_point >= 1 then
					return v.level - level
				end
			end
		end
	end
end

--是否播cg的技能
function SkillData:GetIsZhuanzhiSkill(skill_id)
	if skill_id >= ZHUAN_ZHI_SKILL_MIN and skill_id <= ZHUAN_ZHI_SKILL_MAX then
		return true
	end
	for k,v in pairs(KILL_SKILL) do
		if skill_id == v then
			return true
		end
	end
	return false
end