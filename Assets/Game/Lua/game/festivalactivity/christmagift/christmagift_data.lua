ChristmaGiftData = ChristmaGiftData or BaseClass(BaseEvent)
function ChristmaGiftData:__init()
	if nil ~= ChristmaGiftData.Instance then
		return
	end
	ChristmaGiftData.Instance =  self
	self.medata = {}
	self.rank_data = {}
	self.skill_data = {}
end
function ChristmaGiftData:__delete()
	ChristmaGiftData.Instance = nil
	self.rank_data = nil
	self.medata = nil
	self.skill_data = nil
	self:RemoveCountDown()
end
function ChristmaGiftData:GetAward()
	return ConfigManager.Instance:GetAutoConfig("gift_harvest_auto").other[1].reward_item
end
function ChristmaGiftData:GetGiftAward()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1].gift_harvest_reward
end
function ChristmaGiftData:SetMeData(data)
	self.medata.round = data.round
	self.medata.get_score = data.get_score
	self.medata.kill_num = data.kill_num
end
function ChristmaGiftData:GetMeData()
	return self.medata
end
function ChristmaGiftData:SetRankData(data)
	self.rank_data.count = data.rank_num
	self.rank_data.rank_lsit = data.rank_lsit
	for k,v in pairs(self.rank_data.rank_lsit) do
		if v.role_id == GameVoManager.Instance:GetMainRoleVo().role_id then
			self.medata.rank = k
		end
	end
end
function ChristmaGiftData:GetRankData()
	self.rank_data.rank_lsit = self.rank_data.rank_lsit or {} 
	return self.rank_data
end
function ChristmaGiftData:GetRankItemAwk(rank)
	local cfg =  ServerActivityData.Instance:GetCurrentRandActivityConfig().gift_harvest_rank_reward
	return cfg[rank]
end
function ChristmaGiftData:GetRankItemCount()
	return #ServerActivityData.Instance:GetCurrentRandActivityConfig().gift_harvest_rank_reward
end
function ChristmaGiftData:GetRoundTime(round)
	return ConfigManager.Instance:GetAutoConfig("gift_harvest_auto").round_open_time[round]
end
function ChristmaGiftData:SetSkillData(data)
	self.skill_data.id = data.skill_index
	self.skill_data.next_perform_timestamp = data.next_perform_timestamp
end
function ChristmaGiftData:GetSkillData()
	return self.skill_data
end
function ChristmaGiftData:GetSkillCD(id)
	local cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto").normal_skill
	for k,v in pairs(cfg) do
		if v.skill_id == id then
			return v.cd_s
		end
	end
	return 20
end

function ChristmaGiftData:SetActiviTime(state, next_perform_timestamp, round)
	-- self:RemoveCountDown()
	-- if state == 1 then
	-- 	self.count_down_two = CountDown.Instance:AddCountDown(9999, 1, function ()
	-- 		MainUIView.Instance:SetLiwuState(state, TimeUtil.FormatSecond(next_perform_timestamp - TimeCtrl.Instance:GetServerTime(), 4))
	-- 	end)
	-- else
	-- 	MainUIView.Instance:SetLiwuState(state)
	-- end
	self.scene_round =  round
end

function ChristmaGiftData:RemoveCountDown()
	if self.count_down_two then
        CountDown.Instance:RemoveCountDown(self.count_down_two)
        self.count_down_two = nil
    end
end

function ChristmaGiftData:GetSceneRound()
	return self.scene_round or 10
end