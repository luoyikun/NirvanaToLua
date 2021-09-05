FarmHuntingData = FarmHuntingData or BaseClass()

FarmHuntingData.FarmSkillAction = {
	[250]={skill_id = 250, skill_action = "combo1_1", effect = nil},
	[251]={skill_id = 251, skill_action = "combo1_1", effect = nil},
	[252]={skill_id = 252, skill_action = "combo1_1", effect = "BUFF_feng"},
	[253]={skill_id = 253, skill_action = "combo1_1", effect = nil},
}

function FarmHuntingData:__init()
	if FarmHuntingData.Instance ~= nil then
		ErrorLog("[FarmHuntingData] Attemp to create a singleton twice !")
	end
	FarmHuntingData.Instance = self

	self.cross_pasture_cfg = ConfigManager.Instance:GetAutoConfig("cross_pasture_auto")

	self.skill_cfg_list = self.cross_pasture_cfg.skill
	self.monster_info = self.cross_pasture_cfg.monster_info
	self.fence_cfg = self.cross_pasture_cfg.fence
	self.other_cfg = self.cross_pasture_cfg.other

	self.normal_skill = ConfigManager.Instance:GetAutoConfig("roleskill_auto").normal_skill

	self.monster_cfg = ListToMap(self.monster_info, "monster_id")

	self.farm_info = {
		score = 0,
		left_get_score_times = 0,
	}

	local main_role_name = GameVoManager.Instance:GetMainRoleVo().name

	self.rank_list = {}
	self.main_role_rank_info = {
		rank = 0,
		name = main_role_name,
		score = 0,			-- 积分
}
end

function FarmHuntingData:__delete()
	FarmHuntingData.Instance = nil
end


function FarmHuntingData:GetShowRewardCfg()
	if nil == self.other_cfg[1].boss_diao then return end
	return self.other_cfg[1].boss_diao
end

--获得人物技能配置
function FarmHuntingData:GetRoleSkillCfgBySkillId(skill_id)
	return self.normal_skill[skill_id]
end
--获得牧场技能配置
function FarmHuntingData:GetCrossPastureSkillCfg()
	return self.skill_cfg_list
end

function FarmHuntingData:GetFarmSkillIndex(skill_id)
	for k,v in pairs(self.skill_cfg_list) do
		if v.skill_id == skill_id then
			return v.index
		end
	end

	return -1
end

function FarmHuntingData:GetMonsterList()
	return self.monster_info
end

function FarmHuntingData:GetMonsterScore(monster_id)
	return self.monster_cfg[monster_id].score
end


-- 跨服牧场
function FarmHuntingData:OnFarmHountingInfo(protocol)
	self.farm_info.score = protocol.score
	self.farm_info.left_get_score_times = protocol.left_get_score_times
	self.farm_info.special_monster_refresh_time = protocol.special_monster_refresh_time
	self.farm_info.x = protocol.x
	self.farm_info.y = protocol.y
end

function FarmHuntingData:GetMonsterID(index)
	local cfg = self.cross_pasture_cfg.monster_info
	local num = index or #cfg
	local monster_id = cfg[num].monster_id or 0
	return monster_id
end


function FarmHuntingData:GetFarmHountingInfo()
	return self.farm_info
end

function FarmHuntingData:SetBtnStatus(status)
	self.is_show_btn = status
end

function FarmHuntingData:GetBtnStatus()
	return self.is_show_btn
end

function FarmHuntingData:GetFarmHountingInfo()
	return self.farm_info
end

function FarmHuntingData:GetMonsterPos()
	local info = self:GetFarmHountingInfo()
	if info then
		pos_x = info.x
		pos_y = info.y
	end
	return pos_x , pos_y
end

--获取附近的熔炉点
function FarmHuntingData:GetNearRongluPoint()
	local x, y = 0, 0
	local self_x, self_y = Scene.Instance:GetMainRole():GetLogicPos()
	local dis = nil
	for k,v in pairs(self.fence_cfg) do
		if dis == nil or dis > GameMath.GetDistance(v.ronghe_pos_x, v.ronghe_pos_y, self_x, self_y, false) then
			dis = GameMath.GetDistance(v.ronghe_pos_x, v.ronghe_pos_y,self_x, self_y, false)
			x = v.ronghe_pos_x
			y = v.ronghe_pos_y
		end
	end
	return x, y
end

function FarmHuntingData:GetRankListInfo()
	return self.rank_list
end

function FarmHuntingData:GetRankInfoByIndex(index)
	return self.rank_list[index]
end

function FarmHuntingData:GetMainRoleRankInfo()
	return self.main_role_rank_info
end

function FarmHuntingData:SetCrossRankInfo(protocol)
	self.rank_list = {}
	local main_role_name = GameVoManager.Instance:GetMainRoleVo().name
	for i,v in ipairs(protocol.rank_list) do
		self.rank_list[i] = {}
		self.rank_list[i].rank = i
		self.rank_list[i].name = v.name
		self.rank_list[i].score = v.score			-- 积分

		if main_role_name == self.rank_list[i].name then
			self.main_role_rank_info = self.rank_list[i]
		end
	end
end

function FarmHuntingData:GetFarmHuntingTitleId()
	return self.other_cfg[1].rank_title_id or 3001
end