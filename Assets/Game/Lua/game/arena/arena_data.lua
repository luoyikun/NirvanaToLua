ArenaData = ArenaData or BaseClass()

FIELD1V1_STATUS =
{
	AWAIT = 0,					-- 等待
	PREPARE = 1,				-- 准备
	PROCEED = 2,				-- 进行中
	OVER = 3,					-- 结束
}

ArenaData.MaxListItem = 5
function ArenaData:__init()
	if ArenaData.Instance then
		print_error("[ArenaData] Attemp to create a singleton twice !")
	end
	ArenaData.Instance = self

	self.scene_user_list = {} 								-- 场景对象信息
	self.scene_status = -1									-- 当前状态 0 发起方等待中 1准备 2战斗开始 3战斗完成
	self.scene_next_time = -1								-- 当前状态倒计时

	self.user_info = nil									-- 用户信息
	self.last_rank = 0										-- 上次排名
	self.role_info_list = {}								-- 挑战列表用户信息
	self.report_info = {}									-- 战报
	self.rank_info = {}										-- 英雄榜
	self.guanghui_info = {}									-- 光辉

	self.config = ConfigManager.Instance:GetAutoConfig("challengefield_auto")
	self.fight_result = {
		rank_up = 0,
	}
	self.title_cfg = ConfigManager.Instance:GetAutoConfig("titleconfig_auto")
	self.history_rank_reward_cfg = ListToMap(self.config.history_rank_reward, "index")
	self.title_list = ListToMap(self.title_cfg.challenge_field, "min_rank_pos")

	self.cur_best_rank_index = 0
	self.cur_best_rank_pos_index = 0
	self.arena_mainui_show = true

	RemindManager.Instance:Register(RemindName.Arena, BindTool.Bind(self.GetRemindNum, self))
	RemindManager.Instance:Register(RemindName.ArenaChallange, BindTool.Bind(self.GetLunjianRemind, self))
	RemindManager.Instance:Register(RemindName.ArenaRank, BindTool.Bind(self.GetJiFenMayGetReardNum, self))
	RemindManager.Instance:Register(RemindName.ArenaTupo, BindTool.Bind(self.GetArenaTupoRemind, self))
	
	self:CheckArenaOpenOrNotOnMainuiChange()
end

function ArenaData:__delete()
	RemindManager.Instance:UnRegister(RemindName.Arena)
	RemindManager.Instance:UnRegister(RemindName.ArenaChallange)
	RemindManager.Instance:UnRegister(RemindName.ArenaRank)
	RemindManager.Instance:UnRegister(RemindName.ArenaTupo)
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	ArenaData.Instance = nil
end

function ArenaData:GetArenaRankListMaxPage()
	local role_info = self.rank_info or {}
	local max_page = math.ceil(#role_info / ArenaData.MaxListItem)
	return max_page
end

function ArenaData:GetCurRankItemNumByIndex(index)
	local role_info = self.rank_info or {}
	local num = math.modf(#role_info / ArenaData.MaxListItem)
	local max_page = self:GetArenaRankListMaxPage()
	if index <= max_page then
		return ArenaData.MaxListItem
	else
		return num
	end
end

function ArenaData:GetArenaRankInfo()
	if self.rank_info and next(self.rank_info) then
		return self.rank_info
	end
end

-- 获取当前积分
function ArenaData:GetCurJifen()
	if self.user_info then
		return self.user_info.jifen
	else
		return nil
	end
end

-- 获取排名
function ArenaData:GetRankByUid(uid)
	local rank = 0
	if self.user_info then
		if uid == GameVoManager.Instance:GetMainRoleVo().role_id then
			rank = self.user_info.rank
		else
			for k,v in pairs(self.user_info.rank_list) do
				if v.user_id == uid then
					rank = v.rank
					break
				end
			end
			if rank == 0 then
				for k,v in pairs(self.rank_info) do
					if v.user_id == uid then
						rank = v.rank
						break
					end
				end
			end
		end
	end
	return rank
end

function ArenaData:GetRankRewardData(server_open_day)
	local list = {}
	local data = self.config.rank_reward
	if data then
		for k,v in pairs(data) do
			if v.open_game_day == server_open_day then
				table.insert(list, v)
			end
		end
	end
	return list

end

function ArenaData:SetRoleInfo(role_info)
	if role_info then
		--self.role_info_list[role_info.role_id] = role_info
		for k,v in pairs(role_info) do
			self.role_info_list[v.user_id] = v
		end
	end
end

-- 获取玩家信息
function ArenaData:GetRoleInfoByUid(uid)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if uid == main_role_vo.role_id then
		return main_role_vo
	end
	return self.role_info_list[uid]
end

function ArenaData:SetGuangHuiData(data)
	self.guanghui_info.guanghui = data.guanghui
	self.guanghui_info.delta_guanghui = data.delta_guanghui
	PlayerData.Instance:SetAttr("guanghui", data.guanghui)
end

function ArenaData:GetRoleGuangHuiData()
	if self.guanghui_info then
		return self.guanghui_info
	end
end

-- 获取玩家信息
function ArenaData:GetOtherPlayersInfo()
	return self.role_info_list
end

-- 获取玩家挑战信息
function ArenaData:GetRoleTiaoZhanInfoByUid(uid)
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

-- 奖励是否可领取
function ArenaData:GetCurSeqJiFenRewardIsGet(seq)
	if self.user_info then
		return self.user_info.jifen_reward_flag[seq]
	end
end

-- 获取积分奖励配置
function ArenaData:GetJIfenConfig()
	return self.config.jifen_reward
end

function ArenaData:GetJiFenRewardByIndex(seq)
	local role_lev = GameVoManager.Instance:GetMainRoleVo().level
	local cfg
	for i,v in ipairs(self.config.jifen_reward_detail) do
		if v.seq == seq and role_lev >= v.role_level then
			cfg = v
		end
	end
	return cfg
end

-- 获取可领取积分奖励数量
function ArenaData:GetJiFenMayGetReardNum()
	local num = 0
	local flag = self:GetIsCanFetchRankReward()
	if flag then
		num = num + 1
	end
	return num
end

-- 总挑战次数
function ArenaData:GetSumTiaoZhanNum()
	local sum_num = 0
	if self.user_info then
		sum_num = self.user_info.free_day_times
	end
	if self.user_info then
		sum_num = sum_num + self.user_info.buy_join_times
	end
	return sum_num
end

-- 剩余次数
function ArenaData:GetResidueTiaoZhanNum()
	local num = 0
	if self.user_info then
		num = self:GetSumTiaoZhanNum() - self.user_info.join_times
	end
	return num
end

-- 是否获胜
function ArenaData:IsWin()
	if self.scene_user_list and self.scene_user_list[2] then
		return self.scene_user_list[2].hp <= 0
	end
	return false
end

function ArenaData:GetEnemyUserInfo()
	return self.scene_user_list[2]
end

-- 结算信息
function ArenaData:GetResultData()
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

function ArenaData:GetFightTime()
	if self.scene_next_time then
		return self.scene_next_time
	end
end

function ArenaData:SetFightResult()
	if self.last_rank ~= self.user_info.rank then
		self.fight_result.rank_up = self.last_rank - self.user_info.rank
	else
		self.fight_result.rank_up = 0
	end
end

function ArenaData:SetFightResult2(data)
	if data then
		self.fight_result.rank_up = data.old_rank_pos - data.new_rank_pos
	end
end

function ArenaData:GetFightResult()
	return self.fight_result
end

-- 获取配置排名声望奖励
function ArenaData:GetRankRewardByRank(rank)
	local reward_config = self.config.rank_reward
	local reward = 0
	for i,v in ipairs(reward_config) do
		if rank >= v.min_rank_pos and rank <= v.max_rank_pos then
			reward = v.reward_guanghui
			break
		end
	end
	return reward
end

-- 获取下次结算声望
function ArenaData:GetNextJieShuanShengWangByRank(rank)
	local min_sw, max_sw = self:GetCurRanJieShuanShengWangByRank(rank)
	return self:GetIsMaxJieShuan() and max_sw or min_sw
end

-- 下次是否大结算
function ArenaData:GetIsMaxJieShuan()
	local is_max = false
	local time_tab = TimeCtrl.Instance:GetServerTimeFormat()
	local config = self.config.rank_reward_time_cfg
	if config then
		if time_tab.hour + 1 == config[#config].honor then
			is_max = true
		end
	end
	return is_max
end

-- 获取排名结算声望  返回 普通结算 最终结算
function ArenaData:GetCurRanJieShuanShengWangByRank(rank)
	local min_sw, max_sw = 0, 0
	local config = self.config.rank_reward_time_cfg
	if config then
		local rnak_sw = self:GetRankRewardByRank(rank)
		min_sw = rnak_sw * (config[1].percent / 100)
		max_sw = rnak_sw * (config[#config].percent / 100)
	end
	return min_sw, max_sw
end

-- 根据突破等级排名获取历史排名奖励配置
function ArenaData:GetHistoryRankRewardCfg(rank)
	local rank_reward_cfg = ConfigManager.Instance:GetAutoConfig("challengefield_auto").history_rank_reward
	if rank_reward_cfg then
		for k, v in pairs(rank_reward_cfg) do
			if rank >= v.best_rank_pos then
				return v
			end
		end
	end

	return nil
end

-- 是否1v1准备状态
function ArenaData.Is1v1Prepare()
	local boolean = false
	if ArenaData.Instance.scene_status == FIELD1V1_STATUS.PREPARE then
		boolean = true
	end
	return boolean
end

-- 获取本角色最好的排名
function ArenaData:GetBestRank()
	if self.user_info then
		return self.user_info.best_rank_pos
	end
end

-- 获取buff购买次数
function ArenaData:GetBuffBuyTimes()
	if self.user_info then
		return self.user_info.buy_buff_times
	end
end

-- 获取挑战次数购买次数
function ArenaData:GetBuyJoinTimesTimes()
	if self.user_info then
		return self.user_info.buy_join_times
	end
end

function ArenaData:GetUserInfo()
	if self.user_info then
		return self.user_info
	end
end

function ArenaData:GetUserInfoHasItem()
	if self.user_info then
		return #self.user_info.item_list > 0
	end
end

--挑战次数红点
function ArenaData:GetIsFreeDareTimes()
	local times = self:GetResidueTiaoZhanNum()
	if times > 0 then
		return true
	else
		return false
	end
end

--排名奖励红点
function ArenaData:GetIsCanFetchRankReward()
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


-- 主Ui上的提醒次数
function ArenaData:GetRemindNum()
	-- local tiaozhan_remind_num = self:GetResidueTiaoZhanNum()
	-- if tiaozhan_remind_num > 0 and ArenaCtrl.Instance:GetIsRemind() == 0 then
	-- 	return 1
	-- end
	if self.arena_mainui_show then--主界面有标签时不显示红点
		return 0
	end
	if self:GetLunjianRemind() >= 1 then
		return 1
	end
	local flag = self:GetIsCanFetchRankReward()
	if flag then
		return 1
	end
	local curr_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
 	local open_day = ArenaData.Instance:GetArenaTupoOpenDay()
	if curr_server_day < open_day then
		if self.cur_best_rank_pos_index > self.cur_best_rank_index then
			return 1
		end
	end
	return 0
end

function ArenaData:GetLunjianRemind()
	if RemindManager.Instance:RemindToday(RemindName.ArenaChallange) then
		return 0
	end
	local tiaozhan_remind_num = self:GetResidueTiaoZhanNum()
	if tiaozhan_remind_num > 0 then--and ArenaCtrl.Instance:GetIsRemind() == 0 then
		return 1
	end
	return 0
end

function ArenaData:GetTitleID(Rank)
	if self.title_list then
		for k,v in pairs(self.title_list) do
			if v.min_rank_pos <= Rank and v.max_rank_pos >= Rank then
				return v.title_id
			end
		end
	end
end


----突破
-------------------------

function ArenaData:SetBestRank(info)
	self.cur_best_rank_index = info.best_rank_break_level
	local best_rank_pos = info.best_rank_pos + 1
	self:SetBestRankPosIndex(best_rank_pos)
end

function ArenaData:SetBestRankPosIndex(best_rank_pos)
	self.cur_best_rank_pos_index = 0
	if best_rank_pos > 0 then
		for k,v in ipairs(self.config.history_rank_reward) do
			if best_rank_pos <= v.best_rank_pos + 1 then
			 	self.cur_best_rank_pos_index = v.index
			else
			 	break
			end
		end
	end
end

function ArenaData:GetArenaTupoOpenDay()
	if self.config.other[1] then
		return self.config.other[1].open_day or 0
	end
end

function ArenaData:GetArenaViewOpenSeverDay()
	if self.config.other[1] then
		return self.config.other[1].open_dur_day or 0
	end
end

function ArenaData:GetHistoryRankCfg(index)
	index = index or self.cur_best_rank_index
	return self.history_rank_reward_cfg[index]
end

function ArenaData:GetBestRankPosIndex()
	return self.cur_best_rank_pos_index
end

function ArenaData:GetBestRankIndex()
	return self.cur_best_rank_index
end

function ArenaData:GetArenaTupoRemind()
	local open_fun_data = OpenFunData.Instance
	local is_open = open_fun_data:CheckIsHide("arena_view")
	if is_open then
		return self.cur_best_rank_pos_index > self.cur_best_rank_index and 1 or 0
	end
	return 0
end

function ArenaData:RankPosChange(user_id, rank_pos)
	local info = self:GetUserInfo()
	if info then
		for k,v in pairs(info.rank_list) do
			if v.user_id == user_id then
				v.rank_pos = rank_pos
				v.rank = rank_pos + 1
			end
		end
	end
end

function ArenaData:SetArenaMainuiShow(is_show)
	self.arena_mainui_show = is_show
end

function ArenaData:GetArenaMainuiShow()
	return self.arena_mainui_show
end

function ArenaData:GetArenaOpenOrNot()
	local cur_time = TimeCtrl.Instance:GetServerTime()
	local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local sever_day = self:GetArenaViewOpenSeverDay()
	local differ_day = sever_day - server_open_day
	local str = os.date("%X", cur_time)
	local time_tab = Split(str, ":")
	local time = tonumber(time_tab[1]) * 3600 + tonumber(time_tab[2]) * 60 + tonumber(time_tab[3])
	local diff_time = 86400 * differ_day + 22 * 3600 - time
	return diff_time > 0
end


function ArenaData:CheckArenaOpenOrNotOnMainuiChange()
	local func = function ()
		local is_show = self:GetArenaOpenOrNot()
		if not is_show  then
			if ViewManager.Instance:IsOpen(ViewName.ArenaActivityView) then
				ViewManager.Instance:Close(ViewName.ArenaActivityView)
			end
			MainUICtrl.Instance:FlushView("icon_group_1")
			if self.time_quest then
				GlobalTimerQuest:CancelQuest(self.time_quest)
				self.time_quest = nil
			end
		end
	end
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(func, 2)
	end
end