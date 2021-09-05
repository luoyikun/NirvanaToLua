KuafuLiuJieBossInfoView = KuafuLiuJieBossInfoView or BaseClass(BaseRender)

local MAX_CITY_NUM = 6

function KuafuLiuJieBossInfoView:__init()
	self.main_boss_list = {}
	self.secondary_boss_list = {}
	self.item_list = {}
	-- local main_city_cfg = KuafuGuildBattleData.Instance:GetCityShowItemCfg(0)
	-- for i = 1, #main_city_cfg do
	-- 	local item_cell = ItemCell.New()
	-- 	item_cell:SetInstanceParent(self.node_list["MainBoss"])
	-- 	local data ={item_id = main_city_cfg[i]} 
	-- 	item_cell:SetData(data)
	-- 	table.insert(self.main_boss_list,item_cell)
	-- end
	self.act_id = ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_LIUJIE_BOSS
	local act_info = ActivityData.Instance:GetActivityInfoById(self.act_id)
	if act_info then
		local tab_list = Split(act_info.item_label, ":")
		for i = 1, 4 do
			local item_cell = ItemCell.New()
			item_cell:SetShowOrangeEffect(true)
			item_cell:SetInstanceParent(self.node_list["MainBoss"])
			if tab_list[i] then
				tab_list[i] = tonumber(tab_list[i])
			end
			if act_info["reward_item" .. i] and act_info["reward_item" .. i].item_id > 0 then
				item_cell:SetData(act_info["reward_item" .. i])
				item_cell:SetActive(true)
				if tab_list[i]then
					item_cell:SetShowZhuanShu(tab_list[i] == 1)
				end
			else
				item_cell:SetActive(false)
			end
			table.insert(self.main_boss_list,item_cell)
		end
	end

	for i = 1, MAX_CITY_NUM do
		self.item_list[i] = KuafuLiuJieBossInfoRender.New(self.node_list["Item" .. i])
		self.node_list["PlaceName" .. i].text.text = Language.RecordRank.PlaceName[i]
		self.item_list[i]:SetIndex(i)
	end

	local text = ""
	local is_open, list_num, list = ActivityData.Instance:GetOpenWeekDay(self.act_id)
	if is_open and list_num then
		if list_num >= 7 then
			local start_time = KuafuGuildBattleData.Instance:GetStartFlushTime()
			start_time = TimeUtil.FormatSecond(start_time, 5)
			text = string.format(Language.KuafuGuildBattle.OpenTime, start_time)
		else
			local str = ""
			for i = 1,list_num do
				if list[i] then
					local day = tonumber(list[i])
					if i == 1 then
						str = string.format("%s%s", Language.Activity.WeekDay, Language.Common.DayToChs[day])
					else
						str = string.format("%s、%s", str, Language.Common.DayToChs[day])
					end
				end
			end
			local week_day = string.format(Language.KuafuGuildBattle.KFLiuJieBossTime, str, act_info.open_time, act_info.end_time)
			text = string.format(Language.Activity.DetailExplain_3, week_day)
		end
	else
		text = ""
	end

	self.node_list["des_Text"].text.text = text

	self.node_list["EnterCrossBtn"].button:AddClickListener(BindTool.Bind(self.OnEnterCross, self))
	self.node_list["BtnLog"].button:AddClickListener(BindTool.Bind(self.OpenDropLogView, self))
	self.node_list["DescBtn"].button:AddClickListener(BindTool.Bind(self.ClickKfBattleDesc, self))
end

function KuafuLiuJieBossInfoView:InitData()
	
end

function KuafuLiuJieBossInfoView:__delete()
	for k,v in pairs(self.main_boss_list) do
		v:DeleteMe()
	end
	for k,v in pairs(self.secondary_boss_list) do
		v:DeleteMe()
	end
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	self.secondary_boss_list = {}
	self.main_boss_list = {}
end

function KuafuLiuJieBossInfoView:ClickKfBattleDesc()
	local tips_id = 294
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

-- 进入跨服帮派战
function KuafuLiuJieBossInfoView:OnEnterCross()
	-- 背包满了不让进
	-- local empty_num = ItemData.Instance:GetEmptyNum()
	-- if empty_num == 0 then
	-- 	TipsCtrl.Instance:ShowSystemMsg(Language.GuildBattle.BagRemind)
	-- 	return
	-- end
	-- local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_LIUJIE_BOSS)
	-- local is_limit_flag = ActivityData.Instance:IsAchieveLevelInLimintConfigById(ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_LIUJIE_BOSS)
	-- if not is_open and is_limit_flag then
		KuafuGuildBattleData.Instance:SetEnterType(LIUJIE_ENTER_TYPE.BOSS_ENTER)
		CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.KF_GUILDBATTLE, KuafuGuildBattleData.Instance:GetSceneIdByIndex())
	-- else
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.KuafuGuildBattle.NotOpen)
	-- end
end

function KuafuLiuJieBossInfoView:OpenDropLogView()
	KuafuGuildBattleCtrl.Instance:SendKuaFuLiuJieLogInfoReq()
	-- ViewManager.Instance:Open(ViewName.TipsLiuJieLogView)
end

function KuafuLiuJieBossInfoView:OnFlush()
	-- local boss_num = KuafuGuildBattleData.Instance:GetBossNum()
	local monster_info = KuafuGuildBattleData.Instance:GetCrossGuildBattleMonsterInfo()
	-- if boss_num == nil or monster_info == nil then
	-- 	return
	-- end
	-- local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_LIUJIE_BOSS)
	if monster_info == nil then
		return
	end
	local is_any_alive = KuafuGuildBattleData.Instance:IsAnyBossAlive()
	local is_limit_flag = ActivityData.Instance:IsAchieveLevelInLimintConfigById(ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_LIUJIE_BOSS)
	self.node_list["BossNode"]:SetActive(is_any_alive and is_limit_flag)
	self.node_list["NodeEffect"]:SetActive(is_any_alive and is_limit_flag)
	self.node_list["NodeBtnEffect"]:SetActive(is_any_alive and is_limit_flag)
	-- self.item_list[1]:SetData(boss_num)
	for i = 1, MAX_CITY_NUM do
		if monster_info[i] then
			local monster_num = monster_info[i]
			self.item_list[i]:SetData(monster_num)
		end
	end
	self.node_list["EnterCrossBtn"]:SetActive(true)
	-- local act_info = ActivityData.Instance:GetActivityInfoById(self.act_id)
	-- local server_time = TimeCtrl.Instance:GetServerTime()
	-- if act_info and act_info.open_time then
	-- 	local open_time_stamp = ActivityData.Instance:ChangeToStamp(act_info.open_time) or 0
	-- 	if open_time_stamp > server_time then
	-- 		self.node_list["EnterCrossBtn"]:SetActive(false)
	-- 	end
	-- end
	-- local time = tonumber(os.date("%w",os.time())) or 0

	-- if time == 0 then
	-- 	time = 7
	-- end
	-- local level = GameVoManager.Instance:GetMainRoleVo().level or 0
	-- local is_show = ActivityData.Instance:GetIsShowLimint(self.act_id, time, level)
	-- self.node_list["des_Text"]:SetActive(is_show)
end

KuafuLiuJieBossInfoRender = KuafuLiuJieBossInfoRender or BaseClass(BaseRender)
function KuafuLiuJieBossInfoRender:__init()
end

function KuafuLiuJieBossInfoRender:__delete()
end

function KuafuLiuJieBossInfoRender:SetIndex(index)
	self.index = index
end

function KuafuLiuJieBossInfoRender:SetData(data)
	if nil == data then return end
	local is_limit_flag = ActivityData.Instance:IsAchieveLevelInLimintConfigById(ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_LIUJIE_BOSS)
	local num = is_limit_flag and data or 0
	self.node_list["BossTxt"].text.text = string.format(Language.KuafuGuildBattle.kfGuildBossRemind, num)
end