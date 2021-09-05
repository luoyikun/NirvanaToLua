KuaFu1v1ViewMain = KuaFu1v1ViewMain or BaseClass(BaseRender)

function KuaFu1v1ViewMain:__init()
	self.play_audio = true
	self.hide = false
	self.is_modal = true
	self.is_pipei = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.open_day_list = {}
	self:InitInfo()
	self:Flush()
end

function KuaFu1v1ViewMain:LoadCallBack()
	self.node_list["TxtIsCanClick"].text.text = Language.Common.PiPei
	self.node_list["BtnEnter"].button:AddClickListener(BindTool.Bind(self.OnClickEnter, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["BtnWangZhe"].button:AddClickListener(BindTool.Bind(self.OnClickWangZhe, self))
	self.node_list["BtnAddCiShu"].button:AddClickListener(BindTool.Bind(self.SendBuyJoinTimes, self))
	self.node_list["EnemyInfo"]:SetActive(false)
	self.node_list["ShowEnemyImg"]:SetActive(true)
	for i = 1, 3 do
		self.node_list["Reward" .. i].button:AddClickListener(BindTool.Bind(self.OnClickReward, self, i))
	end

	-- self.my_model = RoleModel.New()
	-- self.my_model:SetDisplay(self.node_list["MyDisPlay"].ui3d_display)
end

function KuaFu1v1ViewMain:ReleaseCallBack()
	if self.pipei_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.pipei_count_down)
		self.pipei_count_down = nil
	end

	-- if self.my_model then
	-- 	self.my_model:DeleteMe()
	-- 	self.my_model = nil
	-- end

	-- if self.enemy_model then
	-- 	self.enemy_model:DeleteMe()
	-- 	self.enemy_model = nil
	-- end
end

function KuaFu1v1ViewMain:__delete()
	if self.pipei_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.pipei_count_down)
		self.pipei_count_down = nil
	end

	-- if self.my_model then
	-- 	self.my_model:DeleteMe()
	-- 	self.my_model = nil
	-- end

	-- if self.enemy_model then
	-- 	self.enemy_model:DeleteMe()
	-- 	self.enemy_model = nil
	-- end

end


function KuaFu1v1ViewMain:OpenCallBack()
	local reward_cfg = KuaFu1v1Data.Instance:GetRewardCfg()
	for i=1,#reward_cfg do
		self.node_list["Reward" .. i].animator:SetBool("shake", false)
	end
	self:Flush()
end


-- 购买
function KuaFu1v1ViewMain:SendBuyJoinTimes()
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.KF_ONEVONE) then
		local max_goumai = KuaFu1v1Data.Instance:GetBuyMaxTimes()
		local gold_cost = KuaFu1v1Data.Instance:GetBuyTimeCost()
		local goumaicishu = KuaFu1v1Data.Instance:GetRoleData().today_buy_times
		if max_goumai - goumaicishu > 0 then
			describe = string.format(Language.Field1v1.AddNumTip, ToColorStr(gold_cost, TEXT_COLOR.GREEN), ToColorStr(goumaicishu + 1, TEXT_COLOR.GREEN))
			yes_func = function() KuaFu1v1Ctrl.Instance:SendCSCross1v1BuyTimeReq() end
		elseif goumaicishu < max_goumai then
			TipsCtrl.Instance:ShowLockVipView(VIPPOWER.KF1V1_TIMES)
			return
		else
			describe = Language.Field1v1.AddNumTip2
			SysMsgCtrl.Instance:ErrorRemind(describe)
			return
		end
		TipsCtrl.Instance:ShowCommonAutoView("kf1v1_pipei", describe, yes_func)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.GUILDJIUHUINOOPEN)
	end
end

-- 领取奖励
function KuaFu1v1ViewMain:OnClickReward(index)
	KuaFu1v1Ctrl.Instance:SendGetCross1V1RankRewardReq(CROSS_1V1_FETCH_REWARD_TYPE.CROSS_1V1_FETCH_REWARD_TYPE_JOIN_TIMES, index - 1)
	local first_reward_join_count = 1
	local second_reward_join_count = 5
	local third_reward_join_count = 10
	local join_num = 0
	local info = KuaFu1v1Data.Instance:GetRoleData()
	if info == nil then
		return
	end

	if index == 1 then
		join_num = first_reward_join_count
	elseif index == 2 then
		join_num = second_reward_join_count
	elseif index == 3 then
		join_num = third_reward_join_count
	else
		return
	end
	local config = KuaFu1v1Data.Instance:GetRewardByJoin(join_num)
	if config then
		local reward = {config.reward_item_l}
		if info.cross_day_join_1v1_count >= first_reward_join_count and info.cross_day_join_1v1_count < second_reward_join_count and index <= 1 then 
			TipsCtrl.Instance:ShowRewardTipsView(reward[1])
		elseif info.cross_day_join_1v1_count >= second_reward_join_count and info.cross_day_join_1v1_count < third_reward_join_count and index <= 2 then
			TipsCtrl.Instance:ShowRewardTipsView(reward[1])
		elseif info.cross_day_join_1v1_count >= third_reward_join_count  and index <= 3 then
			TipsCtrl.Instance:ShowRewardTipsView(reward[1])
		else
			local title = Language.Tip.HaveRewardTitle
			TipsCtrl.Instance:ShowRewardTipsView(reward[1], title)
		end
	end
end


function KuaFu1v1ViewMain:OnClickWangZhe()
	KuaFu1v1Ctrl.Instance:SetShowWangZheEffect(false)
	self.node_list["ShowEffect"]:SetActive(false)
	ViewManager.Instance:Open(ViewName.WangZheZhiJieView)
end

function KuaFu1v1ViewMain:InitInfo()
	local act_info = ActivityData.Instance:GetActivityInfoById(ACTIVITY_TYPE.KF_ONEVONE)
	if act_info then
		if not next(act_info) then return end
		local min_level = tonumber(act_info.min_level)
		-- local lv, zhuan = PlayerData.GetLevelAndRebirth(min_level)
		-- local level = string.format(Language.Common.ZhuanShneng, lv, zhuan)
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		self.open_day_list = Split(act_info.open_day, ":")
		self.node_list["TxtLevel"].text.text = PlayerData.GetLevelString(min_level)
		self.node_list["ShowMyImg"].image:LoadSprite(ResPath.Get1v1Head("Prof" .. (main_role_vo.prof % 10)))
		self.node_list["ShowMyImg"].image:SetNativeSize()
		self:SetTitleTime(act_info)
		self:SetExplain(act_info)
	end
end

function KuaFu1v1ViewMain:OnFlush()
	local info = KuaFu1v1Data.Instance:GetRoleData()
	if info == nil then
		return
	end
	
	local max_jiontimes = KuaFu1v1Data.Instance:GetMaxJionTimes()
	local goumaicishu = info.today_buy_times
	local cross_day_join_1v1_count = info.cross_day_join_1v1_count
	self.node_list["TxtTiaoZhan"].text.text = max_jiontimes + goumaicishu -cross_day_join_1v1_count

	local win_num = KuaFu1v1Data.Instance:GetWinRate()
	self.node_list["TxtRewardCount"].text.text = string.format(Language.Kuafu1V1.Win, win_num)

	local cishu = info.cross_lvl_total_join_times
	self.node_list["TxtWeiWang"].text.text = cishu

	local lian_sheng_count = info.cross_1v1_dur_win_times
	self.node_list["TxWinCount"].text.text = lian_sheng_count

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	self.node_list["MyName"].text.text = string.format(Language.Kuafu1V1.Name, main_role_vo.server_id, main_role_vo.name)
	-- local lv1, zhuan1 = PlayerData.GetLevelAndRebirth(main_role_vo.level)
	-- local level = string.format(Language.Common.ZhuanShneng, lv1, zhuan1)
	self.node_list["MyLevel"].text.text = string.format(Language.Kuafu1V1.Level, PlayerData.GetLevelString(main_role_vo.level))
	-- self.my_model:SetModelResInfo(main_role_vo, false, true, true)

	local index = KuaFu1v1Data.Instance:GetIndexByScore(info.cross_score_1v1)


	if KuaFu1v1Data.Instance:GetSeasonRingRemind() > 0 then
		self.node_list["WangZheRedPoint"]:SetActive(true)
	else
		self.node_list["WangZheRedPoint"]:SetActive(false)
	end

	local current_config, next_config = KuaFu1v1Data.Instance:GetRankByScore(info.cross_score_1v1)
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
	local jifen_num = info.cross_score_1v1
	local rewared_id = KuaFu1v1Data.Instance:GetRewardBaseCell(jifen_num)
	local prog = KuaFu1v1Data.Instance:SetProgLevel(rewared_id.grade)
	self.node_list["TxtJiFen"].text.text = string.format(Language.Kuafu1V1.JiFenTxt, jifen_num)
	self.node_list["ValueSlider"].slider.value = (jifen_num - rewared_id.score) / (prog.score - rewared_id.score)

	-- 领取奖励所需要的参加次数
	local first_reward_join_count = 1
	local second_reward_join_count = 5
	local third_reward_join_count = 10
	local num = 0
	local reward_cfg = KuaFu1v1Data.Instance:GetRewardCfg()
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.KF_ONEVONE) then
		self.node_list["RewardNum"].text.text = string.format(Language.Kuafu1V1.RewardNum, 0 , 3)
		for i =  1 ,#reward_cfg do
			if KuaFu1v1Data.Instance:GetJionTimesRewardIsGet(i)  == 0 then
				self.node_list["Reward" .. i].animator:SetBool("shake", false)
				if info.cross_day_join_1v1_count >= first_reward_join_count and info.cross_day_join_1v1_count < second_reward_join_count and i <= 1 then 
					self.node_list["Reward" .. i].animator:SetBool("shake", true)
					self.node_list["effect" .. i]:SetActive(true)
					self.node_list["Reward" .. i]:SetActive(true) 
					self.node_list["RewardClose" .. i]:SetActive(false)
				elseif info.cross_day_join_1v1_count >= second_reward_join_count and info.cross_day_join_1v1_count < third_reward_join_count and i <= 2 then
					self.node_list["Reward" .. i].animator:SetBool("shake", true)
					self.node_list["Reward" .. i]:SetActive(true)
					self.node_list["effect" .. i]:SetActive(true)
					self.node_list["RewardClose" .. i]:SetActive(false)

				elseif info.cross_day_join_1v1_count >= third_reward_join_count  and i <= 3 then
					self.node_list["Reward" .. i].animator:SetBool("shake", true)
					self.node_list["Reward" .. i]:SetActive(true)
					self.node_list["effect" .. i]:SetActive(true)
					self.node_list["RewardClose" .. i]:SetActive(false)
				else
					self.node_list["Reward" .. i].animator:SetBool("shake", false)
					self.node_list["effect" .. i]:SetActive(false)
				end
			elseif KuaFu1v1Data.Instance:GetJionTimesRewardIsGet(i)  == 1 then
				self.node_list["Reward" .. i].animator:SetBool("shake", false)
				self.node_list["effect" .. i]:SetActive(false)
				self.node_list["Reward" .. i]:SetActive(false)
				self.node_list["RewardClose" .. i]:SetActive(true)
				num = num + 1
			else
				num = 0
			end
			self.node_list["RewardSlider"].slider.value = info.cross_day_join_1v1_count / 10
		end 
		self.node_list["RewardNum"].text.text = string.format(Language.Kuafu1V1.RewardNum, num , 3)
	end
	
	self.node_list["ShowEffect"]:SetActive(KuaFu1v1Ctrl.Instance:GetShowWangZheEffect())


	local macth_info = KuaFu1v1Data.Instance:Get1V1MacthInfo()
	if macth_info.result == 0 then
		self.is_wait_match = false
		self.node_list["ShowEnemyImg"]:SetActive(true)
		self.node_list["RoleBg"]:SetActive(false)
		-- self.node_list["MyDisPlay"]:SetActive(true)
		self.node_list["ShowMyImg"]:SetActive(true)
		self.node_list["MyBg"]:SetActive(false)
		self.node_list["TxtIsCanClick"].text.text = Language.Common.PiPei
		if self.pipei_count_down ~= nil then
			CountDown.Instance:RemoveCountDown(self.pipei_count_down)
			self.pipei_count_down = nil
			self.node_list["RoleBg"].animator:SetBool("pking", false)
		end
	elseif macth_info.match_end_left_time > TimeCtrl.Instance:GetServerTime() then
		self.is_wait_match = true
		self.node_list["ShowEnemyImg"]:SetActive(false)
		-- self.node_list["MyDisPlay"]:SetActive(false)
		self.node_list["ShowMyImg"]:SetActive(false)
		self.node_list["RoleBg"]:SetActive(true)
		self.node_list["MyBg"]:SetActive(true)
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		self.node_list["MyBg"].image:LoadSprite(ResPath.Get1v1Head("Prof" .. (main_role_vo.prof % 10)))
		self.node_list["MyBg"].image:SetNativeSize()
		local time = 35
		self.node_list["TxtIsCanClick"].text.text = string.format(Language.Common.PiPeiZhong, 1)
		if self.pipei_count_down == nil then
			self.pipei_count_down = CountDown.Instance:AddCountDown(time, 1, BindTool.Bind1(self.UpdateCD, self))
			self.node_list["RoleBg"].animator:SetBool("pking", true)
			self.node_list["RoleBg"].animator:ListenEvent("ChangeImage", BindTool.Bind(self.ChangeImage, self))
		end
	end

end

local count = 0
function KuaFu1v1ViewMain:ChangeImage()
	count = count + 1
	self.node_list["RoleBg"].image:LoadSprite(ResPath.Get1v1Head("Prof" .. ((count % 4) + 1)))
end

function KuaFu1v1ViewMain:UpdateCD(elapse_time, total_time)
	if nil == elapse_time or nil == total_time then
		return
	end
	local last_time = math.ceil(elapse_time)
	self.node_list["TxtIsCanClick"].text.text = string.format(Language.Common.PiPeiZhong, last_time)
end

function KuaFu1v1ViewMain:CompleteCD()
	self.node_list["TxtIsCanClick"].text.text = Language.Common.OnMatchTxt
end

function KuaFu1v1ViewMain:OnClickEnter()
	if self.is_wait_match then
		KuaFu1v1Ctrl.Instance:SendCross1v1MatchQueryReq(CROSS_1V1_MATCH_REQ_TYPE.CROSS_1V1_MATCH_REQ_CANCEL)
		return
	end
	KuaFu1v1Ctrl.Instance:SendCrossMatch1V1Req()
end



function KuaFu1v1ViewMain:ShowEnemyInfo()
	self:ClearPage()
	self.node_list["EnemyInfo"]:SetActive(true)
	self.node_list["ShowEnemyImg"]:SetActive(false)
	self.node_list["ShowMyImg"]:SetActive(false)
	local enemy_info = KuaFu1v1Data.Instance:GetMatchingEnemySex()
	self.node_list["EnemyName"].text.text = string.format(Language.Kuafu1V1.Name, enemy_info.sever, enemy_info.name)
	-- local lv1, zhuan1 = PlayerData.GetLevelAndRebirth(enemy_info.level)
	-- local level = string.format(Language.Common.ZhuanShneng, lv1, zhuan1)
	self.node_list["EnemyLevel"].text.text = string.format(Language.Kuafu1V1.Level, PlayerData.GetLevelString(enemy_info.level))
	-- self.enemy_model = RoleModel.New()
	-- self.enemy_model:SetDisplay(self.node_list["EnemyDisPlay"].ui3d_display)
	-- self.enemy_model:SetModelResInfo(enemy_info, false, true, true)
end

function KuaFu1v1ViewMain:ClearPage()
	-- if self.enemy_model then
	-- 	self.enemy_model:DeleteMe()
	-- 	self.enemy_model = nil
	-- end
end


function KuaFu1v1ViewMain:SetTitleTime(act_info)
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
	self.node_list["TxtJoinCount"].text.text = time_str
end

function KuaFu1v1ViewMain:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(93)
end

function KuaFu1v1ViewMain:OnClickHead()

end


function KuaFu1v1ViewMain:SetExplain(act_info)
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

function KuaFu1v1ViewMain:GetChineseWeek(act_info)
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