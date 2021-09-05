require("game/kuafu_pvp/kf_pvp_view_pipei")
KFPVPViewMain = KFPVPViewMain or BaseClass(BaseRender)

TeamNum = 3
function KFPVPViewMain:__init()
	self.play_audio = true
	self.hide = false
	self.is_modal = true
	self.is_pipei = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.open_day_list = {}
	self.role_model_list = {}
	self:InitInfo()
	self:Flush()
end

function KFPVPViewMain:LoadCallBack()
	self.node_list["TxtIsCanClick"].text.text = Language.Common.PiPei
	self.node_list["BtnEnter"].button:AddClickListener(BindTool.Bind(self.OnClickEnter, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["BtnZhiZun"].button:AddClickListener(BindTool.Bind(self.OnClickZhiZun, self))
	self.node_list["BtnTeam"].button:AddClickListener(BindTool.Bind(self.OnClickTeam, self))

	self.fight_text = {}
	for i = 1, 3 do
		self.node_list["Reward" .. i].button:AddClickListener(BindTool.Bind(self.OnClickReward, self, i))
		self.fight_text[i] = CommonDataManager.FightPower(self, self.node_list["PowerLabel" .. i])
	end
end

function KFPVPViewMain:ReleaseCallBack()
	for k, v in pairs(self.role_model_list) do
		v:DeleteMe()
	end
	self.role_model_list = {}

	for i = 1,3 do
		self.fight_text[i] = nil
	end
	self.fight_text = nil
end

function KFPVPViewMain:__delete()
	for k, v in pairs(self.role_model_list) do
		v:DeleteMe()
	end
	self.role_model_list = {}
	if self.pvp_pipei_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.pvp_pipei_count_down)
		self.pvp_pipei_count_down = nil
	end
end

function KFPVPViewMain:OpenCallBack()
	local reward_cfg = KuafuPVPData.Instance:GetRewardCfg()
	for i=1,#reward_cfg do
		self.node_list["Reward" .. i].animator:SetBool("shake", false)
		self.node_list["Effect" .. i]:SetActive(false)
	end
	self:Flush()
	KuafuPVPCtrl.Instance:SendCrossMultiuserChallengeGetBaseSelfSideInfo()
end



-- 领取奖励
function KFPVPViewMain:OnClickReward(index)
	KuafuPVPCtrl.Instance:SendCrossMultiuserChallengeFetchDaycountReward(index - 1)
	local first_reward_join_count = 1
	local second_reward_join_count = 5
	local third_reward_join_count = 10
	local join_num = 0
	local info = KuafuPVPData.Instance:GetActivityInfo()
	if info == nil then
		return
	end

	if index == 1 then
		jion_times = first_reward_join_count
	elseif index == 2 then
		jion_times = second_reward_join_count
	elseif index == 3 then
		jion_times = third_reward_join_count
	else
		return
	end
	local config = KuafuPVPData.Instance:GetRewardByJoin(jion_times)
	-- if config then
	-- 	local reward = {config.reward_item}
	-- 	TipsCtrl.Instance:ShowRewardTipsView(reward)
	-- end

	if config then
		local reward = {config.reward_item}
		if info.today_match_count >= first_reward_join_count and info.today_match_count < second_reward_join_count and index <= 1 then 
			TipsCtrl.Instance:ShowRewardTipsView(reward[1])
		elseif info.today_match_count >= second_reward_join_count and info.today_match_count < third_reward_join_count and index <= 2 then
			TipsCtrl.Instance:ShowRewardTipsView(reward[1])
		elseif info.today_match_count >= third_reward_join_count  and index <= 3 then
			TipsCtrl.Instance:ShowRewardTipsView(reward[1])
		else
			local title = Language.Tip.HaveRewardTitle
			TipsCtrl.Instance:ShowRewardTipsView(reward[1], title)
		end
	end
end


function KFPVPViewMain:OnClickZhiZun()
	KuafuPVPCtrl.Instance:SetShowZhiZunEffect(false)
	self.node_list["ShowEffect"]:SetActive(false)
	ViewManager.Instance:Open(ViewName.ZhiZunLingPaiView)
end

function KFPVPViewMain:OnClickTeam()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
end


function KFPVPViewMain:InitInfo()
	local act_info = ActivityData.Instance:GetActivityInfoById(ACTIVITY_TYPE.KF_PVP)
	if act_info then
		if not next(act_info) then return end
		local min_level = tonumber(act_info.min_level)
		-- local lv, zhuan = PlayerData.GetLevelAndRebirth(min_level)
		-- local level = string.format(Language.Common.ZhuanShneng, lv, zhuan)
		self.open_day_list = Split(act_info.open_day, ":")
		self.node_list["TxtLevel"].text.text = PlayerData.GetLevelString(min_level)
		self:SetTitleTime(act_info)
		self:SetExplain(act_info)
	end
end

function KFPVPViewMain:OnFlush()
	local activity_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.KF_PVP)
	UI:SetButtonEnabled(self.node_list["BtnEnter"], activity_info and ACTIVITY_STATUS.OPEN == activity_info.status)
	local info = KuafuPVPData.Instance:GetActivityInfo()
	if info == nil then
		return
	end
	
	local max_jiontimes = KuafuPVPData.Instance:GetMaxJionTimes()
	local cross_day_join_1v1_count = info.today_match_count
	self.node_list["TxtTiaoZhan"].text.text = max_jiontimes - cross_day_join_1v1_count


	self:FlushTeamInfoAndModel()

	local is_show = KuafuPVPData.Instance:GetSeasonCardRemind() > 0
	self.node_list["WangZheRedPoint"]:SetActive(is_show)

	local current_config, next_config = KuafuPVPData.Instance:GetRankByScore(info.challenge_score)
	if current_config then
		UI:SetGraphicGrey(self.node_list["HeadImg"], false)
		local rank = current_config.rank_type
		local bundle, asset = ResPath.Get1v1RankIcon(rank)
		self.node_list["HeadImg"].image:LoadSprite(bundle, asset .. ".png")
		self.node_list["TxtRank"].text.text = current_config.name
	elseif next_config then
		local bundle, asset = ResPath.Get1v1RankIcon(next_config.rank_type)
		self.node_list["HeadImg"].image:LoadSprite(bundle, asset .. ".png")
		UI:SetGraphicGrey(self.node_list["HeadImg"], true)
		self.node_list["TxtRank"].text.text = Language.Common.WuDuanWei
	end
	local jifen_num = info.challenge_score
	local rewared_id = KuafuPVPData.Instance:GetRewardBaseCell(jifen_num)
	local prog = KuafuPVPData.Instance:SetProgLevel(rewared_id.grade)
	self.node_list["TxtJiFen"].text.text = string.format(Language.Kuafu3V3.JiFenTxt, jifen_num)
	self.node_list["ValueSlider"].slider.value = (jifen_num - rewared_id.score) / (prog.score - rewared_id.score)

	-- 领取奖励所需要的参加次数
	local first_reward_join_count = 1
	local second_reward_join_count = 5
	local third_reward_join_count = 10
	local num = 0
	local reward_cfg = KuafuPVPData.Instance:GetRewardCfg()
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.KF_PVP) then
		self.node_list["RewardNum"].text.text = string.format(Language.Kuafu3V3.RewardNum, 0 , 3)
		for i =  1 ,#reward_cfg do
			if KuafuPVPData.Instance:GetPvPJionTimesRewardIsGet(i)  == 0 then
				self.node_list["Reward" .. i].animator:SetBool("shake", false)
				self.node_list["Effect" .. i]:SetActive(false)
				if cross_day_join_1v1_count >= first_reward_join_count and cross_day_join_1v1_count < second_reward_join_count and i <= 1 then 
					self.node_list["Reward" .. i].animator:SetBool("shake", true)
					self.node_list["Reward" .. i]:SetActive(true) 
					self.node_list["Effect" .. i]:SetActive(true)
					self.node_list["RewardClose" .. i]:SetActive(false)
				elseif cross_day_join_1v1_count >= second_reward_join_count and cross_day_join_1v1_count < third_reward_join_count and i <= 2 then
					self.node_list["Reward" .. i].animator:SetBool("shake", true)
					self.node_list["Reward" .. i]:SetActive(true)
					self.node_list["Effect" .. i]:SetActive(true)
					self.node_list["RewardClose" .. i]:SetActive(false)
				elseif cross_day_join_1v1_count >= third_reward_join_count  and i <= 3 then
					self.node_list["Reward" .. i].animator:SetBool("shake", true)
					self.node_list["Reward" .. i]:SetActive(true)
					self.node_list["Effect" .. i]:SetActive(true)
					self.node_list["RewardClose" .. i]:SetActive(false)
				else
					self.node_list["Reward" .. i].animator:SetBool("shake", false)
				end
			elseif KuafuPVPData.Instance:GetPvPJionTimesRewardIsGet(i)  == 1 then
				self.node_list["Reward" .. i].animator:SetBool("shake", false)
				self.node_list["Reward" .. i]:SetActive(false)
				self.node_list["Effect" .. i]:SetActive(false)
				self.node_list["RewardClose" .. i]:SetActive(true)
				num = num + 1
			else
				num = 0
			end
			self.node_list["RewardSlider"].slider.value = cross_day_join_1v1_count / 10
		end 
		self.node_list["RewardNum"].text.text = string.format(Language.Kuafu3V3.RewardNum, num , 3)
	end
	
	self.node_list["ShowEffect"]:SetActive(KuafuPVPCtrl.Instance:GetShowZhiZunEffect())

	local match_info = KuafuPVPData.Instance:GetMatchStateInfo()

	if match_info.matching_state < 0 or match_info.matching_state == 3 then
		self.node_list["TxtIsCanClick"].text.text = string.format(Language.KuafuPVP.MatchBtnTxt[1])
		if self.pvp_pipei_count_down ~= nil then
			CountDown.Instance:RemoveCountDown(self.pvp_pipei_count_down)
			self.pvp_pipei_count_down = nil
		end
	else
		--self.node_list["TxtIsCanClick"].text.text = string.format(Language.KuafuPVP.MatchBtnTxt[2])

		self.node_list["TxtIsCanClick"].text.text = string.format(Language.Common.PiPeiZhong, 1)
		if self.pvp_pipei_count_down == nil then
			local time = 60
			self.pvp_pipei_count_down = CountDown.Instance:AddCountDown(time, 1, BindTool.Bind1(self.UpdateCD, self), BindTool.Bind1(self.CompleteCD, self))
		end
	end

end

function KFPVPViewMain:UpdateCD(elapse_time, total_time)
	if nil == elapse_time or nil == total_time then
		return
	end
	local last_time = math.ceil(elapse_time)
	self.node_list["TxtIsCanClick"].text.text = string.format(Language.Common.PiPeiZhong, last_time)
end

function KFPVPViewMain:CompleteCD()
	self.node_list["TxtIsCanClick"].text.text = Language.Common.OnMatchTxt_2
	if self.pvp_pipei_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.pvp_pipei_count_down)
		self.pvp_pipei_count_down = nil
	end
end

function KFPVPViewMain:OnClickEnter()
	local match_info = KuafuPVPData.Instance:GetMatchStateInfo()
	if match_info.matching_state >= 0 and match_info.matching_state ~= 3 then
		KuafuPVPCtrl.Instance:SendCrossMultiuerChallengeCancelMatching()
		return
	end
	KuafuPVPCtrl.Instance:OpenPiPeiView()
end

function KFPVPViewMain:FlushTeamInfoAndModel()
	self:ClearPage() 
	local mate_list_data = KuafuPVPData.Instance:GetMatesInfo()

	self.node_list["DZ_1"]:SetActive(false)
	self.node_list["DZ_2"]:SetActive(false)
	self.node_list["DZ_3"]:SetActive(false)

	self.node_list["DWState1"]:SetActive(false)
	self.node_list["DWState2"]:SetActive(false)
	self.node_list["DWState3"]:SetActive(false)

	local list_data = TableCopy(mate_list_data)
	if ScoietyData.Instance:GetTeamState() and #list_data >= 2 then
		for i = 2, #list_data do
			local is_leader = ScoietyData.Instance:IsLeaderById(list_data[i].uid)
			if is_leader and i ~= 1 then
				local data = table.remove(list_data, i)
				table.insert(list_data, 1, data)
				break
			end
		end
	end

	for i = 1, #list_data do
		self.node_list["Name" .. i].text.text = list_data[i].user_name
		if self.fight_text[i] and self.fight_text[i].text then
			self.fight_text[i].text.text = list_data[i].capability
		end
		local config = KuafuPVPData.Instance:GetRankByScore(list_data[i].challenge_score)
		if config then
			self.node_list["DuanWei" .. i].text.text = config.name
		else
			self.node_list["DuanWei" .. i].text.text = Language.Common.WuDuanWei
		end
		self.node_list["ShowImg" .. i]:SetActive(false)
		if self.role_model_list[i] == nil then
			self.role_model_list[i] = RoleModel.New()
			self.role_model_list[i]:SetDisplay(self.node_list["DisPlay" .. i].ui3d_display, MODEL_CAMERA_TYPE.BASE)
		end
		self.role_model_list[i]:SetModelResInfo(list_data[i], false, true, true)
		if ScoietyData.Instance:GetTeamState() then
			local is_leader = ScoietyData.Instance:IsLeaderById(list_data[i].uid)
			self.node_list["DZ_" .. i]:SetActive(is_leader)

			local have_team_text = ScoietyData.Instance:GetIsInTeam(list_data[i].uid)
			if have_team_text ~= nil and have_team_text then
				self.node_list["DWState" .. i].text.text = have_team_text
				self.node_list["DWState" .. i]:SetActive(true)
			end 
		end
		self.node_list["PowerLabel" .. i]:SetActive(true)
		self.node_list["TitleBg" .. i]:SetActive(true)
	end
end


function KFPVPViewMain:ClearPage()
	for i = 1, TeamNum do
		self.node_list["Name" .. i].text.text = ""
		if self.fight_text[i] and self.fight_text[i].text then
			self.fight_text[i].text.text = ""
		end
		self.node_list["DuanWei" .. i].text.text = ""
		self.node_list["ShowImg" .. i]:SetActive(true)
		self.node_list["PowerLabel" .. i]:SetActive(false)
		self.node_list["TitleBg" .. i]:SetActive(false)
	end

	for k, v in pairs(self.role_model_list) do
		v:DeleteMe()
	end
	self.role_model_list = {}
end



function KFPVPViewMain:SetTitleTime(act_info)
	local server_time = TimeCtrl.Instance:GetServerTime()
	local now_weekday = tonumber(os.date("%w", server_time))
	if now_weekday == 0 then now_weekday = 7 end
	local time_str = Language.Activity.YiJieShu

	if act_info.is_allday == 1 or ActivityData.Instance:GetActivityIsOpen(act_info.act_id) then
		time_str = Language.Activity.KaiQiZhong
	else
		local open_day_list = Split(act_info.open_day, ":")
		for _, v in ipairs(open_day_list) do
			if tonumber(v) == now_weekday then
				local open_time_tbl = Split(act_info.open_time, "|")
				local open_time_str = open_time_tbl[1]
				local end_time_tbl = Split(act_info.end_time, "|")

				if #end_time_tbl > 1 then
					local server_time_str = os.date("%H:%M", server_time)
					for k2, v2 in ipairs(end_time_tbl) do
						open_time_str = open_time_tbl[k2]
						if v2 > server_time_str then
							break
						end
					end
				end
				time_str = string.format("%s  %s", open_time_str, Language.Common.Open)
				break
			end
		end
	end
	self.node_list["TxtTime"].text.text = time_str
	--self.node_list["TxtJoinCount"].text.text = time_str
end

function KFPVPViewMain:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(291)
end

function KFPVPViewMain:OnClickHead()

end


function KFPVPViewMain:SetExplain(act_info)
	local min_level = tonumber(act_info.min_level)
	-- local lv, zhuan = PlayerData.GetLevelAndRebirth(min_level)
	-- local level_str = string.format(Language.Common.ZhuanShneng, lv, zhuan)
	local time_des = ""
	local level_str = PlayerData.GetLevelString(min_level)
	if act_info.is_allday == 1 then
		time_des = Language.Activity.AllDay
	else
		time_des = self:GetChineseWeek(act_info)
	end

	local detailexplain = string.format(Language.Activity.DetailExplain, level_str, time_des, act_info.dec)
	if self.act_id == ACTIVITY_TYPE.CLASH_TERRITORY then
		local guild_id = PlayerData.Instance.role_vo.guild_id or 0
		local match_name = ClashTerritoryData.Instance:GetTerritoryWarMatch(guild_id)
		detailexplain = string.format(Language.Activity.TerritoryWarExplain, level_str, time_des, match_name)
	end
	self.node_list["TxtExPlain"].text.text = detailexplain
end

function KFPVPViewMain:GetChineseWeek(act_info)
	local open_time_tbl = Split(act_info.open_time, "|")
	local end_time_tbl = Split(act_info.end_time, "|")
	local time_des = ""

	if #self.open_day_list >= 7 then
		if #open_time_tbl > 1 then
			local time_str = ""
			for i = 1, #open_time_tbl do
				if i == 1 then
					time_str = string.format("%s-%s", open_time_tbl[1], end_time_tbl[1])
				else
					time_str = string.format("%s,%s-%s", time_str, open_time_tbl[i], end_time_tbl[i])
				end
			end
			time_des = string.format("%s %s", Language.Activity.EveryDay, time_str)
		else
			time_des = string.format("%s %s-%s", Language.Activity.EveryDay, act_info.open_time, act_info.end_time)
		end
	else
		local week_str = ""
		for k, v in ipairs(self.open_day_list) do
			local day = tonumber(v)
			if k == 1 then
				week_str = string.format("%s%s", Language.Activity.WeekDay, Language.Common.DayToChs[day])
			else
				week_str = string.format("%s、%s", week_str, Language.Common.DayToChs[day])
			end
		end
		if #open_time_tbl > 1 then
			local time_str = ""
			for i = 1, #open_time_tbl do
				if i == 1 then
					time_str = string.format("%s-%s", open_time_tbl[1], end_time_tbl[1])
				else
					time_str = string.format("%s,%s-%s", time_str, open_time_tbl[i], end_time_tbl[i])
				end
			end
			time_des = string.format("%s %s", week_str, time_str)
		else
			time_des = string.format("%s %s-%s", week_str, act_info.open_time, act_info.end_time)
		end
	end
	return time_des
end