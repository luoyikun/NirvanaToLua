
KFMonthBlackWindHighView = KFMonthBlackWindHighView or BaseClass(BaseView)

function KFMonthBlackWindHighView:__init()
	self.ui_config = {{"uis/views/kuafumonthblackwindhigh_prefab","KFMonthBlackWindHigh"}}
	self.camera_mode = UICameraMode.UICameraLow
	-- self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.fight_info_view = true
	self.active_close = false
end

function KFMonthBlackWindHighView:__delete()
	if self.skill_render then
		self.skill_render:DeleteMe()
		self.skill_render = nil
	end
end

function KFMonthBlackWindHighView:LoadCallBack()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	self.node_list["MyName"].text.text = main_role_vo.role_name
	MainUICtrl.Instance:SetViewState(false)
	self.score_info = MonthBlackWindHighScoreInfoView.New(self.node_list["ScorePerson"])
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
	-- FuBenCtrl.Instance:SetMonsterClickCallBack(BindTool.Bind(self.MonsterClickCallBack, self))
	self.node_list["BoxItem"].button:AddClickListener(BindTool.Bind(self.OpenBoxTips, self))
	
	self.monster_cell_list = {}
	self.treasure_box_cell_list = {}
	self:InitTreasureBoxScroller()
	self:Flush()
end

function KFMonthBlackWindHighView:ReleaseCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	if self.score_info then
		self.score_info:DeleteMe()
		self.score_info = nil
	end

	self.monster_scroller = nil
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	for k,v in pairs(self.treasure_box_cell_list) do
		v:DeleteMe()
	end
	self.treasure_box_cell_list = nil

	FuBenCtrl.Instance:ClearMonsterClickCallBack()
end

function KFMonthBlackWindHighView:OpenBoxTips( )
	local box_cfg = KFMonthBlackWindHighData.Instance:GetBoxCfg()
	if box_cfg ~= nil then
		local reward_item = TableCopy(box_cfg.reward_item) 
		TipsCtrl.Instance:OpenItem(reward_item)
	end
end
	

function KFMonthBlackWindHighView:OnFlush()
	if self.score_info then
		self.score_info:Flush()
	end
	self:FlushMonsterIcon()
	self:FlushTreasureScor()

	local rank_info = KFMonthBlackWindHighData.Instance:GetMyRankList()
	if rank_info.rank_val > 0 then
		self.node_list["Mybaoxiang"].text.text = "x\t" .. rank_info.rank_val						--string.format(Language.JinYinTa.MyBaoXiang, rank_info.rank_val or 0)
	else
		self.node_list["Mybaoxiang"].text.text = "x\t" .. 0										--string.format(Language.JinYinTa.MyBaoXiang,  0)
	end
	if rank_info.rank_val >= 0 then
		if tonumber(rank_info.rank) >= 20 then
			self.node_list["MyRank"].text.text = rank_info.rank .. "+"
		else
			self.node_list["MyRank"].text.text = rank_info.rank
		end
		self.node_list["MyBoxNum"].text.text = string.format(Language.JinYinTa.BaoXiangNum, rank_info.rank_val or 0)
		-- self.node_list["MyBoxNum"].text.text = rank_info.rank_val or 0
	else
		self.node_list["MyRank"].text.text = Language.Common.ZanWu
		self.node_list["MyBoxNum"].text.text = string.format(Language.JinYinTa.BaoXiangNum, 0)
	end
	local times = KFMonthBlackWindHighData.Instance:GetRewardCount() + 1
	self.node_list["Times"].text.text = string.format(Language.MonthBlackWindHigh.Times, times)
end

function KFMonthBlackWindHighView:OpenCallBack()
	KFMonthBlackWindHighData.Instance:SetFollowNum(0)
	MainUICtrl.Instance:SetViewState(false)


	local loader = AllocAsyncLoader(self, "skill_button_loader")
	loader:Load("uis/views/kuafumonthblackwindhigh_prefab", "KFMonthBlackWindHighSkill", function (obj)
		if IsNil(obj) then
			return
		end

		MainUICtrl.Instance:ShowActivitySkill(obj)
		if nil == self.skill_render then
			self.skill_render = MonthBlackWindHighSkillRender.New(obj)
			self.skill_render:Flush()
		end
	end)
end

function KFMonthBlackWindHighView:CloseCallBack()
	self.is_auto = false
	MainUICtrl.Instance:SetViewState(true)

	MainUICtrl.Instance:ShowActivitySkill(false)
	if self.skill_render then
		self.skill_render:DeleteMe()
		self.skill_render = nil
	end
end

function KFMonthBlackWindHighView:MonsterClickCallBack()
	GuajiCtrl.Instance:CancelSelect()
	local boss_is_flush = KFMonthBlackWindHighData.Instance:GetBossIsFlush()
	-- if not boss_is_flush then return end
	local boss_info = KFMonthBlackWindHighData.Instance:GetTargetBossInfo()
	-- local boss_info = KFMonthBlackWindHighData.Instance:GetBossInfo()
	if boss_info then
		local callback = function()
			MoveCache.param1 = boss_info.monster_id
			GuajiCache.monster_id = boss_info.monster_id
			MoveCache.end_type = MoveEndType.FightByMonsterId
			GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), boss_info.pos_x, boss_info.pos_y, 10, 10)
		end
		callback()
		GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
	end
end

function KFMonthBlackWindHighView:MianUIOpenComlete()
	MainUICtrl.Instance:SetViewState(false)
	self:Flush()
end

function KFMonthBlackWindHighView:SwitchButtonState(enable)
	if self.node_list["TaskParent"] then
		self.node_list["TaskParent"]:SetActive(enable)
	end
end

function KFMonthBlackWindHighView:InitTreasureBoxScroller()
	local list_delegate = self.node_list["InfoScroller"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshTreasureBoxCell, self)
end

function KFMonthBlackWindHighView:GetNumberOfCells()
	--排行信息
	local rank_list = KFMonthBlackWindHighData.Instance:GetRankListInfo()
	return #rank_list
end

function KFMonthBlackWindHighView:RefreshTreasureBoxCell(cell, cell_index)
	local box_cell = self.treasure_box_cell_list[cell]
	if box_cell == nil then
		box_cell = TreasureBoxScrollerCell.New(cell.gameObject, self)
		self.treasure_box_cell_list[cell] = box_cell
	end
	cell_index = cell_index + 1
	box_cell:SetIndex(cell_index)
	box_cell:Flush()
end

function KFMonthBlackWindHighView:SetCurGatherId(cur_gather_id)
	self.cur_gather_id = cur_gather_id
end

function KFMonthBlackWindHighView:SetCurIndex(index)
	self.cur_index = index
end

function KFMonthBlackWindHighView:GetCurIndex()
	return self.cur_index
end

function KFMonthBlackWindHighView:FlushMonsterIcon()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	local boss_info = KFMonthBlackWindHighData.Instance:GetTargetBossInfo()
	-- local boss_info = KFMonthBlackWindHighData.Instance:GetBossInfo()
	local boss_list_cfg = KFMonthBlackWindHighData.Instance:GetCrossDarkNightBossCfg()
	local boss_is_flush = KFMonthBlackWindHighData.Instance:GetBossIsFlush()
	local next_reward_times = KFMonthBlackWindHighData.Instance:GetNextCheckRewardTimestamp()
	local index, boss_cfg = KFMonthBlackWindHighData.Instance:GetBossCfgById(boss_info.monster_id)
	if not boss_info or not boss_list_cfg then return end

	if self.time_quest == nil then
		local function diff_time_func(elapse_time, total_time2)
			if elapse_time >= total_time2 then
				FuBenCtrl.Instance:SetMonsterIconGray(false, 1)
				-- FuBenCtrl.Instance:ShowMonsterHadFlush(true, index .. " / ".. #boss_list_cfg , 1)
				-- FuBenCtrl.Instance:ShowMonsterHadFlush(true, string.format(Language.MonthBlackWindHigh.BoxNum, boss_cfg.drop_num) , 1)
				FuBenCtrl.Instance:ShowMonsterHadFlush(true, Language.Boss.HasRefresh , 1)
				if self.time_quest then
					CountDown.Instance:RemoveCountDown(self.time_quest)
					self.time_quest = nil
				end
				return
			end
			FuBenCtrl.Instance:ShowMonsterHadFlush(false, "", 1)
		end
		self.time_quest = CountDown.Instance:AddCountDown(next_reward_times - TimeCtrl.Instance:GetServerTime(), 
			1, diff_time_func)
	end

	FuBenCtrl.Instance:SetMonsterInfo(boss_cfg.monster_id, 1)
	FuBenCtrl.Instance:SetMonsterIconGray(not boss_is_flush, 1)

	if boss_info.pos_x ~= 0 and boss_info.pos_y ~= 0 then
		-- FuBenCtrl.Instance:ShowMonsterHadFlush(true, index .. " / ".. #boss_list_cfg , 1)
		FuBenCtrl.Instance:ShowMonsterHadFlush(true, string.format(Language.MonthBlackWindHigh.BoxNum, boss_cfg.drop_num) , 1)
	end
end

function KFMonthBlackWindHighView:FlushTreasureScor()
	if self.node_list["InfoScroller"] and self.node_list["InfoScroller"].scroller and self.node_list["InfoScroller"].scroller.isActiveAndEnabled then
		self.node_list["InfoScroller"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end


----------------------技能render----------------------
MonthBlackWindHighSkillRender = MonthBlackWindHighSkillRender or BaseClass(BaseRender)
function MonthBlackWindHighSkillRender:__init()
	
end

function MonthBlackWindHighSkillRender:__delete()
	
end

function MonthBlackWindHighSkillRender:LoadCallBack()
	self.node_list["FollowBtn"].button:AddClickListener(BindTool.Bind(self.OnClickFollow, self))
end

-- 点击追杀榜首
function MonthBlackWindHighSkillRender:OnClickFollow()
	GuajiCtrl.Instance:CancelSelect()
	GuajiCtrl.Instance:StopGuaji()

	local rank_list_info = KFMonthBlackWindHighData.Instance:GetRankListInfo()
	if not next(rank_list_info) then
		SysMsgCtrl.Instance:ErrorRemind(Language.MonthBlackWindHigh.NoFirst)
		return
	end
	local main_role_info = KFMonthBlackWindHighData.Instance:GetMyRankList()
	if main_role_info and main_role_info.rank == "1" then
		SysMsgCtrl.Instance:ErrorRemind(Language.MonthBlackWindHigh.YouAreFirst)
		return
	end
	KFMonthBlackWindHighCtrl.Instance:SendFirstPos()
end

function MonthBlackWindHighSkillRender:OnFlush()

end


----------------------View----------------------
MonthBlackWindHighScoreInfoView = MonthBlackWindHighScoreInfoView or BaseClass(BaseRender)
local RewardNum = 3
function MonthBlackWindHighScoreInfoView:__init()
	self.reward_list = {}
	for i = 1, RewardNum do
		self.reward_list[i] = ItemCell.New()
		self.reward_list[i]:SetInstanceParent(self.node_list["Cell" .. i])
	end
	self:Flush()
end

function MonthBlackWindHighScoreInfoView:__delete()
	for k,v in pairs(self.reward_list) do
		v:DeleteMe()
	end
	self.reward_list = {}
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self:RemoveUniversalCountDown()
end

function MonthBlackWindHighScoreInfoView:OnFlush()
	local score_info = KFMonthBlackWindHighData.Instance:GetScoreInfo()
	local score_cfg = KFMonthBlackWindHighData.Instance:GetCrossDarkNightScoreCfg()
	local box_total_info = KFMonthBlackWindHighData.Instance:GetTotalRewardBoxCount()
	local info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.KF_MONTH_BLACK_WIND_HIGHT)
	local max_score = KFMonthBlackWindHighData.Instance:GetMaxScore()
	if score_info > max_score then
		self.node_list["IsLingQu"]:SetActive(true)
	else
		self.node_list["IsLingQu"]:SetActive(false)
	end
	if next(score_cfg) then
		local score_color = score_info >= score_cfg.score and TEXT_COLOR.GREEN or TEXT_COLOR.RED
		self.node_list["Score"].text.text = string.format(Language.MonthBlackWindHigh.ScoreReward, score_color, score_info, score_cfg.score)
	end
	for i,v in ipairs(self.reward_list) do
		-- if i == RewardNum then
		-- 	v.root_node:SetActive(score_cfg.cross_honor ~= nil)
		-- 	v:SetData({item_id=COMMON_CONSTS.VIRTUAL_KF_ITEM_HORNOR, num=score_cfg.cross_honor, is_bind=1})
		-- else
			v.root_node:SetActive(score_cfg.reward_item[i - 1] ~= nil)
			v:SetData(score_cfg.reward_item[i - 1])
		-- end
	end
	if info then
		local end_time = info.next_time or 0
		local total_time = end_time - TimeCtrl.Instance:GetServerTime()
		self:SetCountDownByTotalTime(total_time)
	end
	self.node_list["BoxTotal"].text.text = string.format(Language.MonthBlackWindHigh.BoxTotal, box_total_info)

	-- local next_check_reward_timestamp = KFMonthBlackWindHighData.Instance:GetNextCheckRewardTimestamp()
	-- local next_time = next_check_reward_timestamp - TimeCtrl.Instance:GetServerTime()
	-- if next_time > 0 then
	-- 	self.node_list["NextTime"]:SetActive(true)
	-- 	self:SetUniversalTime(next_time)
	-- else
	-- 	self.node_list["NextTime"]:SetActive(false)
	-- end
end

function MonthBlackWindHighScoreInfoView:RemoveUniversalCountDown()
	if self.universal_count_down then
		CountDown.Instance:RemoveCountDown(self.universal_count_down)
		self.universal_count_down = nil
	end
end

function MonthBlackWindHighScoreInfoView:SetUniversalTime(total_time)
	if self.universal_count_down == nil then
		local function diff_time_func(elapse_time, total_time2)
			if elapse_time >= total_time2 then
				local time = "00:00"
				self.node_list["TxtTime"].text.text = time
				self:RemoveUniversalCountDown()
				return
			end
			local left_time = math.floor(total_time2 - elapse_time + 0.5)
			local the_time_text = TimeUtil.FormatSecond(left_time, 7)
			self.node_list["TxtTime"].text.text = the_time_text
		end
		diff_time_func(0, total_time)
		self.universal_count_down = CountDown.Instance:AddCountDown(
			total_time, 1, diff_time_func)
	end
end

function MonthBlackWindHighScoreInfoView:SetCountDownByTotalTime(total_time)
	if total_time <= 0 then
		self.node_list["ActivityTime"].text.text = string.format(Language.JinYinTa.ActEndTime3, 0, 0)
		if self.count_down then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		return
	end

	if self.count_down == nil then
		local function diff_time_func(elapse_time, total_time2)
			if elapse_time >= total_time2 then
				self.node_list["ActivityTime"].text.text = string.format(Language.JinYinTa.ActEndTime3, 0, 0)
				if self.count_down then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
			local left_time = math.floor(total_time2 - elapse_time + 0.5)
			local time_text = TimeUtil.FormatSecond(left_time, 2)
			self.node_list["ActivityTime"].text.text = string.format(Language.LuckyDraw.LastTime, time_text)
		end
		diff_time_func(0, total_time)
		self.count_down = CountDown.Instance:AddCountDown(total_time, 1, diff_time_func)
	end
end


--宝箱排名滚动条格子------------------------------------------------------
TreasureBoxScrollerCell = TreasureBoxScrollerCell or BaseClass(BaseCell)

function TreasureBoxScrollerCell:__init(instance, view)
	self.parent = view
end

function TreasureBoxScrollerCell:__delete()
	self.parent = nil
end

function TreasureBoxScrollerCell:OnFlush()
	local rank_info = KFMonthBlackWindHighData.Instance:GetRankInfoByIndex(self.index)
	self:SetActive(rank_info and rank_info.name ~= "")
	if not rank_info then return end

	self.node_list["Name"].text.text = rank_info.name
	self.node_list["Rank"].text.text = rank_info.rank
	self.node_list["BoxNum"].text.text = rank_info.rank_val
 	if rank_info then
		if tonumber(rank_info.rank) <= 3 then
			self.node_list["Rank"]:SetActive(false)
			self.node_list["IconRank"]:SetActive(true)
			local bundle, asset = ResPath.GetRankIcon(rank_info.rank)
			self.node_list["IconRank"].image:LoadSprite(bundle, asset .. ".png")
		else
			self.node_list["Rank"]:SetActive(true)
			self.node_list["IconRank"]:SetActive(false)
		end
	end

	-- local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	-- self.node_list["Bg"]:SetActive(rank_info.name == main_role_vo.role_name)
end