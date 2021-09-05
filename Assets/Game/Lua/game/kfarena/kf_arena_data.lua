KFArenaData = KFArenaData or BaseClass()
local MAXLISTITEM = 5
function KFArenaData:__init()
	if KFArenaData.Instance then
		print_error("[KFArenaData] Attemp to create a singleton twice !")
	end
	KFArenaData.Instance = self

	self.scene_user_list = {} 								-- 场景对象信息
	self.scene_status = -1									-- 当前状态 0 发起方等待中 1准备 2战斗开始 3战斗完成
	self.scene_next_time = -1								-- 当前状态倒计时

	self.user_info = nil									-- 用户信息
	self.last_rank = 0										-- 上次排名
	self.role_info_list = {}								-- 挑战列表用户信息
	self.rank_info = {}										-- 英雄榜

	self.title_cfg = ConfigManager.Instance:GetAutoConfig("titleconfig_auto")
	self.config = ConfigManager.Instance:GetAutoConfig("challengefield_auto")
	self.title_list = self.config.cross_rank_reward
	self.fight_result = {
		rank_up = 0,
	}

	RemindManager.Instance:Register(RemindName.KFArena, BindTool.Bind(self.GetKFArenaRemindNum, self))
	RemindManager.Instance:Register(RemindName.KFArenaChallange, BindTool.Bind(self.GetKFLunjianRemind, self))
	RemindManager.Instance:Register(RemindName.KFArenaRank, BindTool.Bind(self.GetKFJiFenMayGetReardNum, self))
end

function KFArenaData:__delete()
	KFArenaData.Instance = nil
end

-- 主Ui上的提醒次数
function KFArenaData:GetKFArenaRemindNum()
	if self:GetKFLunjianRemind() > 0 then
		return 1
	end

	if self:GetKFJiFenMayGetReardNum() > 0 then
		return 1
	end

	return 0
end

function KFArenaData:GetKFLunjianRemind()
	return 0
end

function KFArenaData:GetKFJiFenMayGetReardNum()
	local num = 0
	-- local flag = self:GetIsCanFetchRankReward()
	-- if flag then
	-- 	num = num + 1
	-- end
	return num
end

-- 是否获胜
function KFArenaData:IsWin()
	if self.scene_user_list and self.scene_user_list[2] then
		return self.scene_user_list[2].hp <= 0
	end
	return false
end

function KFArenaData:GetEnemyUserInfo()
	return self.scene_user_list[2]
end

function KFArenaData:SetFightResult()
	if self.last_rank ~= self.user_info.rank then
		self.fight_result.rank_up = self.last_rank - self.user_info.rank
	else
		self.fight_result.rank_up = 0
	end
end

function KFArenaData:SetFightResult2(data)
	if data then
		self.fight_result.rank_up = data.old_rank_pos - data.new_rank_pos
	end
end

function KFArenaData:GetFightResult()
	return self.fight_result
end

-- 结算信息
function KFArenaData:GetResultData()
	local add_jifen = 0
	if self.config.other[1] then
		add_jifen = self:IsWin() and self.config.other[1].win_add_jifen or self.config.other[1].lose_add_jifen
	end
	local data = DungeonData.CreatePassVo()
	data.fb_type = Scene.Instance:GetSceneType()
	data.is_passed = self:IsWin() and 1 or 0
	data.tip1 = ""
	if self.user_info then
		if self.last_rank ~= self.user_info.rank then
			data.param = true
			data.tip1 = string.format(Language.Field1v1.ResultTip1, self.last_rank, self.user_info.rank)
		else
			data.tip1 = string.format(Language.Field1v1.ResultTip2)
		end

		if nil == self.user_info.jifen then return end
		local jifenValue = 0
		jifenValue = self.user_info.jifen - add_jifen
		data.tip2 = string.format(Language.Field1v1.ResultTip3, jifenValue, add_jifen)
		data.tip2 = HtmlTool.BlankReplace(HtmlTool.GetHtml(data.tip2, COLOR3B.WHITE, 26))
		if self:IsWin() then
			data.tip3 = string.format(Language.Field1v1.ResultTip4, self.user_info.best_rank_pos)
			if self.user_info_gold.reward_bind_gold ~= 0 and self.user_info_gold.reward_bind_gold ~= nil then
				data.tip4 = string.format(Language.Field1v1.ResultTip5, self.user_info_gold.reward_bind_gold)
				data.tip5 = Language.NationalBoss.ResultTip4
				self.user_info_gold.reward_bind_gold = 0
			end
		end
	end
	return data
end

function KFArenaData:GetTitleID(Rank)
	if self.title_list then
		for k,v in pairs(self.title_list) do
			if v.min_rank_pos <= Rank and v.max_rank_pos >= Rank then
				return v.title_id
			end
		end
	end
end

function KFArenaData:GetArenaRankListMaxPage()
	local role_info = self.rank_info or {}
	local max_page = math.ceil(#role_info / MAXLISTITEM)
	return max_page
end

function KFArenaData:GetCurRankItemNumByIndex(index)
	local role_info = self.rank_info or {}
	local num = math.modf(#role_info / MAXLISTITEM)
	local max_page = self:GetArenaRankListMaxPage()
	if index <= max_page then
		return MAXLISTITEM
	else
		return num
	end
end

function KFArenaData:GetArenaRankInfo()
	if self.rank_info and next(self.rank_info) then
		return self.rank_info
	end
end

function KFArenaData:GetRankRewardData(server_open_day)
	local list = {}
	local data = self.config.cross_rank_other_reward
	if data then
		for k,v in pairs(data) do
			table.insert(list, v)
		end
	end
	return list
end

function KFArenaData:GetUserInfo()
	if self.user_info then
		return self.user_info
	end
end

--排名奖励红点
function KFArenaData:GetIsCanFetchRankReward()
	if self.user_info then
		local flag = self.user_info.reward_guanghui ~= 0
		if flag then
			return true
		else
			return false
		end
	end
	return false
end

function KFArenaData:GetFightTime()
	if self.scene_next_time then
		return self.scene_next_time
	end
end

function KFArenaData:SetRoleInfo(role_info)
	if role_info then
		for k,v in pairs(role_info) do
			self.role_info_list[v.user_id] = v
		end
	end
end

-- 获取玩家信息
function KFArenaData:GetRoleInfoByUid(uid)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if uid == main_role_vo.role_id then
		return main_role_vo
	end
	return self.role_info_list[uid]
end

-- 获取玩家信息
function KFArenaData:GetOtherPlayersInfo()
	return self.role_info_list
end

-- 获取玩家挑战信息
function KFArenaData:GetRoleTiaoZhanInfoByUid(uid)
	local info = nil
	if self.user_info then
		for k,v in pairs(self.user_info.rank_list) do
			if v.user_id == uid then
				info = v
				break
			end
		end
	end
	return info
end