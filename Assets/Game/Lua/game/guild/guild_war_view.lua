GuildWarView = GuildWarView or BaseClass(BaseRender)

local CityNum = 5

function GuildWarView:__init(instance)
	if instance == nil then
		return
	end
	-- self.box_anim_list = {}
	-- self.city_Anim_list = {}
	for i = 1, CityNum do
		-- self.box_anim_list[i] = self.node_list["Box_" .. i].animator
		-- self.city_Anim_list[i] = self.node_list["CityIcon_" .. i].animator
		self.node_list["BtnBox" .. i].toggle:AddClickListener(BindTool.Bind(self.OnClickBox, self, i))
	end

	--获取组件
	self.item_list = {}
	for i = 1, 3 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Item_" .. i])
		item:SetShowOrangeEffect(true)
		table.insert(self.item_list, item)
	end

	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["BtnEnter"].button:AddClickListener(BindTool.Bind(self.OnClickEnter, self))
	self.node_list["JiTiReward"].button:AddClickListener(BindTool.Bind(self.OnClickJiTiReward, self))
	self:SetAnimTime()
end

function GuildWarView:__delete()

	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	if self.statr_time_timer then
		CountDown.Instance:RemoveCountDown(self.statr_time_timer)
        self.statr_time_timer = nil
	end
end

function GuildWarView:GetSkillIcon(skill_id)
	return ResPath.GetGuildSkillIcon(skill_id)
end

-- 刷新页面
function GuildWarView:OnFlush()
	self.act_info = ActivityData.Instance:GetActivityInfoById(ACTIVITY_TYPE.GUILDBATTLE)
	if not next(self.act_info) then
		return
	end

	self.open_day_list = Split(self.act_info.open_day, ":")
	self:SetExplain(self.act_info)
	self:SetRewardState(self.act_info)
	self:SetCityPro()
	self:FlushBoxRemind()
end

-- 设置城池信息
function GuildWarView:SetCityPro()
	local rank_list = RankData.Instance:GetGetGuildWarRankListAck()
	local reward_cfg = GuildFightData.Instance:GetConfig().daily_reward
	local guild_war_info = GuildFightData.Instance:GetGuildBattleDailyRewardFlag() 
	if not reward_cfg then
		return
	end
	-- if guild_war_info then
	-- 	show_button = guild_war_info.my_guild_rank == index
	-- 	show_gray = show_button and (guild_war_info.had_fetch == 1)
	-- 	show_redpoint = show_button and (guild_war_info.had_fetch == 0)
	-- end


	local global_info = GuildFightData.Instance:GetGlobalInfo()
	for i = 1, CityNum do
		if reward_cfg[i] then
			self.node_list["TxtGuildName" .. i].text.text = reward_cfg[i].occupy_name
		end

		if rank_list and rank_list[i] then
			self.node_list["TxtLeaderName" .. i].text.text = rank_list[i].tuan_zhang_name
			self.node_list["TxtGuild_Name" .. i].text.text = rank_list[i].guild_name
		else
			self.node_list["TxtLeaderName" .. i].text.text = Language.Competition.NoRank
			self.node_list["TxtGuild_Name" .. i].text.text = Language.Competition.NoRank
		end

		if guild_war_info == nil then
			return
		end
		if guild_war_info.my_guild_rank == i then
			if guild_war_info.had_fetch == 0 then
				self.node_list["red_point" .. i]:SetActive(true)
			elseif guild_war_info.had_fetch == 1 then
				self.node_list["red_point" .. i]:SetActive(false)
			end
		else
			self.node_list["red_point" .. i]:SetActive(false)
		end
	end
end

-- 点击城池
function GuildWarView:OnClickBox(index)
	if nil == index then
		return
	end

	local guild_war_cfg = GuildFightData.Instance:GetConfig()
	if not guild_war_cfg then
		return
	end

	local other_cfg = guild_war_cfg.other[1]
	local reward_cfg = guild_war_cfg.daily_reward
	local guild_war_info = GuildFightData.Instance:GetGuildBattleDailyRewardFlag() 
	local show_gray = nil
	local show_button = nil
	local show_redpoint = nil

	local reward_list = reward_cfg[index].reward_item
	local title_id = other_cfg.title_id
	local top_title_id = reward_cfg[index].occupy_name
	local act_type = ACTIVITY_TYPE.GUILDBATTLE
	local function ok_callback()
		GuildFightCtrl.Instance:SendGuildWarOperate(GUILD_WAR_TYPE.TYPE_FETCH_REQ)
	end
	local function close_callback()
		self.node_list["BtnBox" .. index].toggle.isOn = false
	end 

	if guild_war_info then
		show_button = guild_war_info.my_guild_rank == index
		show_gray = show_button and (guild_war_info.had_fetch == 1)
		show_redpoint = show_button and (guild_war_info.had_fetch == 0)
	end
	if index == 1 then
		TipsCtrl.Instance:OpenRewardTip(reward_list, show_gray, ok_callback, show_button, title_id, top_title_id, act_type, show_redpoint, close_callback)
	else
		TipsCtrl.Instance:TipsGuildWarRewardShow(reward_list, show_gray, ok_callback, show_button, top_title_id, show_redpoint, close_callback)
	end
end

--描述
function GuildWarView:SetExplain(act_info)
	local min_level = tonumber(act_info.min_level)
	local level_str = PlayerData.GetLevelString(min_level)
	local time_des = ""

	time_des = self:GetChineseWeek(act_info)

	local detailexplain = string.format(Language.Activity.DetailExplain_2, level_str)
	local detailexplain_2 = string.format(Language.Activity.DetailExplain_3, time_des)

	self.node_list["TxtExplain"].text.text = detailexplain
	self.node_list["TxtExplain2"].text.text = detailexplain_2
end

function GuildWarView:GetChineseWeek(act_info)
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

--设置是否显示奖励
function GuildWarView:SetRewardState(act_info)
	if act_info and next(act_info.reward_item1) then
		local tab_list = Split(act_info.item_label, ":")
		self.node_list["NodeItemList"]:SetActive(true)
		for k, v in ipairs(self.item_list) do
			if tab_list[k] then
				tab_list[k] = tonumber(tab_list[k])
			end
			if act_info["reward_item" .. k] and next(act_info["reward_item" .. k]) and act_info["reward_item" .. k].item_id ~= 0 then
				v:SetActive(true)
				act_info["reward_item" .. k].is_bind = 0
				v:SetShowVitualOrangeEffect(true)
				v:SetData(act_info["reward_item" .. k])
				if tab_list[k]then
					v:SetShowZhuanShu(tab_list[k] == 1)
				end
			else
				v:SetInteractable(false)
				v:SetActive(false)
			end
		end
	else
		self.node_list["NodeItemList"]:SetActive(false)
	end
end

function GuildWarView:OpenCallBack()
	self:DoPanelTweenPlay()
	self:Flush()
end

function GuildWarView:DoPanelTweenPlay()
	UITween.MoveAlpahShowPanel(self.node_list["TopContent"], GuildData.WarTweenPosition.Up , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Bottom"], GuildData.WarTweenPosition.Down , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

function GuildWarView:OnClickHelp()
	local act_info = ActivityData.Instance:GetClockActivityByID(ACTIVITY_TYPE.GUILDBATTLE)
	if not next(act_info) then return end
	TipsCtrl.Instance:ShowHelpTipView(act_info.play_introduction)
end

function GuildWarView:OnClickJiTiReward()
	local activity_cfg = ActivityData.Instance:GetActivityConfig(ACTIVITY_TYPE.GUILDBATTLE)
	if activity_cfg and activity_cfg.team_reward_item then
		local team_main_reward_list = {}
		for i = 1, activity_cfg.team_reward_item[0].num do
			team_main_reward_list[i] = {item_id = activity_cfg.team_reward_item[0].item_id, num = 1, is_bind = activity_cfg.team_reward_item[0].is_bind}
		end
		local team_other_reward_list = {{item_id = activity_cfg.team_reward_item[0].item_id, num = 1, is_bind = activity_cfg.team_reward_item[0].is_bind}}
		TipsCtrl.Instance:OpenJiTiRewardTip(team_main_reward_list, team_other_reward_list, ACTIVITY_TYPE.GUILDBATTLE)
	end
end

function GuildWarView:OnClickEnter()
	local act_info = ActivityData.Instance:GetClockActivityByID(ACTIVITY_TYPE.GUILDBATTLE)
	if not next(act_info) then return end

	if GameVoManager.Instance:GetMainRoleVo().level < act_info.min_level then
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Common.JoinEventActLevelLimit, act_info.min_level))
		return
	end

	local act_is_ready = ActivityData.Instance:GetActivityIsReady(ACTIVITY_TYPE.GUILDBATTLE)
	local act_is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GUILDBATTLE)
	if not act_is_ready and not act_is_open then
		SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
		return
	end

	ActivityCtrl.Instance:SendActivityEnterReq(ACTIVITY_TYPE.GUILDBATTLE, 0)
	ViewManager.Instance:CloseAll()
end

function GuildWarView:SetAnimTime()
	if self.statr_time_timer then
		CountDown.Instance:RemoveCountDown(self.statr_time_timer)
		self.statr_time_timer = nil
	end

	local one_time = math.random(0.1)
	-- local one_time_num = 1
	-- self.statr_time_timer = CountDown.Instance:AddCountDown(5, 0.1, function (elapse_time, total_time)
	-- 		-- if one_time_num <= CityNum then
	-- 		-- 	self.city_Anim_list[one_time_num]:SetBool("Shake", true)
	-- 		-- end
	-- 		one_time_num = one_time_num + 1

	-- 		-- if elapse_time >= total_time then
	-- 		-- 	for k,v in pairs(self.city_Anim_list) do
	-- 		-- 		v:SetBool("Shake", true)
	-- 		-- 	end
	-- 		-- end
	-- end)
end

function GuildWarView:FlushBoxRemind()
	local guild_war_info = GuildFightData.Instance:GetGuildBattleDailyRewardFlag()
	if nil == guild_war_info then
		return
	end

	local show_button = nil
	local shake_button = nil
	-- for k,v in pairs(self.box_anim_list) do
	-- 	show_button = guild_war_info.my_guild_rank == k
	-- 	shake_button = show_button and (guild_war_info.had_fetch == 0)
	-- 	-- self.box_anim_list[k]:SetBool("Shake", shake_button)
	-- end
end