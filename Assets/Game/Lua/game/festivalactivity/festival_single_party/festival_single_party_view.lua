FestivalSinglePartyView =  FestivalSinglePartyView or BaseClass(BaseRender)

function FestivalSinglePartyView:__init()
	self.rank_list = {}
	self.can_enter = false

	self.rank_item_list = {}
	local rank_list_delegate = self.node_list["RankList"].list_simple_delegate
	rank_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfRankCells, self)
	rank_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshRankCell, self)

	self.part_reward = ItemCell.New()
	self.part_reward:SetInstanceParent(self.node_list["RewardItem"].gameObject)

	self.node_list["EnterBtn"].button:AddClickListener(BindTool.Bind(self.OnClickEnter, self))
	self.node_list["TitleBtn1"].button:AddClickListener(BindTool.Bind(self.OnClickTitle, self))
	self.node_list["TitleBtn2"].button:AddClickListener(BindTool.Bind(self.OnOtherClickTitle, self))
	self.node_list["Help"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
end

function FestivalSinglePartyView:__delete()
	for k,v in pairs(self.rank_item_list) do
		v:DeleteMe()
	end
	self.rank_item_list = {}
	-- self.rank_list_view = {}

	if self.part_reward then
		self.part_reward:DeleteMe()
		self.part_reward = nil
	end

	if self.count_down then
        CountDown.Instance:RemoveCountDown(self.count_down)
        self.count_down = nil
    end
	TitleData.Instance:ReleaseTitleEff(self.node_list["Title1"])
	TitleData.Instance:ReleaseTitleEff(self.node_list["Title2"])
end

function FestivalSinglePartyView:OpenCallBack()
	FestivalSinglePartyCtrl.Instance:SendHolidayGuardRankInfo()
	self:Flush()
end

function FestivalSinglePartyView:CloseCallBack()
end


function FestivalSinglePartyView:OnFlush()
	self.reward_list = FestivalSinglePartyData.Instance:GetSinglePartyRewardConfig()		--奖励配置
 	self.rank_list = FestivalSinglePartyData.Instance:GetSpecialAppearanceRankList()  		--排行数据
	self:FlushTitle()
	self:FlushBottom()
	self.node_list["RankList"].scroller:ReloadData(0)
	local join_times = FestivalSinglePartyData.Instance:GetEnterSinglePartyTimes()
	self.can_enter = join_times < 1
end

function FestivalSinglePartyView:GetNumberOfRankCells()
	local rank_count = FestivalSinglePartyData.Instance:GetSpecialAppearanceRankCount()
	-- local rank_count = 5
	return rank_count
end

function FestivalSinglePartyView:RefreshRankCell(cell, cell_index)
	cell_index = cell_index + 1
	local rank_cell = self.rank_item_list[cell]
	if rank_cell == nil then
		rank_cell = SinglePartyCell.New(cell.gameObject, self)
		self.rank_item_list[cell] = rank_cell
	end
	rank_cell:SetIndex(cell_index)
	if nil == next(self.rank_list) then
		return
	end
	rank_cell:SetData(self.rank_list[cell_index], self.reward_list[cell_index])
end

function FestivalSinglePartyView:FlushTitle()
	if nil == next(self.reward_list) and nil == self.reward_list[1]  and self.reward_list[1].reward_item == nil  then
		return
	end
 
	-- 称号默认为第一名的第一个奖励,排名是从0开始的
	local title_item_id = self.reward_list[1].reward_item[0].item_id
	local title_cfg = ItemData.Instance:GetItemConfig(title_item_id)
	if title_cfg == nil then
		return
	end
	local title_id = title_cfg.param1
	self.node_list["Title1"].image:LoadSprite(ResPath.GetTitleIcon(title_id))
	self.node_list["Title1"].image:SetNativeSize()
	TitleData.Instance:LoadTitleEff(self.node_list["Title1"], title_id, true)

	if nil == next(self.reward_list) and nil == self.reward_list[2]  and self.reward_list[2].reward_item == nil  then
		return
	end
	--右边显示第二名的称号
	local other_title_id = self.reward_list[2].reward_item[0].item_id
	local other_title_cfg = ItemData.Instance:GetItemConfig(other_title_id)
	if other_title_cfg == nil then
		return
	end
	local other_title_id = other_title_cfg.param1
	self.node_list["Title2"].image:LoadSprite(ResPath.GetTitleIcon(other_title_id))
	self.node_list["Title2"].image:SetNativeSize()
	TitleData.Instance:LoadTitleEff(self.node_list["Title2"], other_title_id, true)
	-- 活动时间
	local other_cfg = FestivalSinglePartyData.Instance:GetSinglePartyOtherCfg()
	if next(other_cfg) ~= nil then
		local begin_time = other_cfg.begin_time or 0
		local end_time = other_cfg.end_time or 0
		local format_begin_time = self:FormatActivityTime(begin_time)
		local format_end_time = self:FormatActivityTime(end_time)
		self.node_list["OpenTime"].text.text = format_begin_time.."-"..format_end_time
	end

	-- 刷新倒计时
	local activity_end_time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HOLIDAY_GUARD) or 0
    if self.count_down then
        CountDown.Instance:RemoveCountDown(self.count_down)
        self.count_down = nil
    end
    self.count_down = CountDown.Instance:AddCountDown(activity_end_time, 1, function ()
        activity_end_time = activity_end_time - 1
        -- local down_time = 0
  --       if activity_end_time > 3600 * 24 then
		-- 	down_time = TimeUtil.FormatSecond(activity_end_time, 7)
		-- elseif activity_end_time > 3600 then
		-- 	down_time = TimeUtil.FormatSecond(activity_end_time, 1)
		-- else
		-- 	down_time = TimeUtil.FormatSecond(activity_end_time, 4)
		-- end
		self.node_list["CountDown"].text.text = TimeUtil.FormatSecond(activity_end_time, 10)
    end)
end

function FestivalSinglePartyView:FormatActivityTime(time)
	if time == nil then return end
	time_tab = TimeUtil.Format2TableDHM(time)
	local hour = time_tab.hour
	local day = time_tab.day
	if day == 1 then
		hour = hour + 24
	end
	local min = time_tab.min
	local s = string.format("%02d:%02d", hour,min)
	return s
end  

function FestivalSinglePartyView:FlushBottom()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfigOtherCfg()
	if nil == cfg then
		return
	end
	local part_reward_data = cfg.holiday_guard_participation_reward
	self.part_reward:SetData(part_reward_data)

	local my_rank = FestivalSinglePartyData.Instance:GetMySpecialAppearanceRank()
	local kill_count = FestivalSinglePartyData.Instance:GetSinglePartyMyKillCount() or 0
	-- local my_rank = 1
	-- local kill_count = 1
	if my_rank == nil or my_rank == -1 or kill_count == 0 then
		self.node_list["MyRank"].text.text = string.format(Language.SingleParty.MyRank, Language.Rank.NoInRank) 
	else
		self.node_list["MyRank"].text.text = string.format(Language.SingleParty.MyRank, my_rank)
	end
	self.node_list["MyKill"].text.text = string.format(Language.SingleParty.MyKill, kill_count) 
end

function FestivalSinglePartyView:OnClickEnter()
	local server_time = TimeCtrl.Instance:GetServerTime()
	local time_table = os.date("*t",server_time)
	local day_time = time_table.hour * 3600 + time_table.min * 60 + time_table.sec
	local other_cfg = FestivalSinglePartyData.Instance:GetSinglePartyOtherCfg()
	local total_npc = FestivalSinglePartyData.Instance:GetTotalNpcCountInScene()
	if next(other_cfg) ~= nil then
		local begin_time = other_cfg.begin_time or 0
		local end_time = other_cfg.end_time or 0
		if day_time < begin_time or day_time > end_time then
			SysMsgCtrl.Instance:ErrorRemind(Language.SingleParty.ActivateClose)
			return 
		elseif day_time >= begin_time and day_time <= end_time and total_npc == 0 then
			SysMsgCtrl.Instance:ErrorRemind(Language.SingleParty.ActivateTip)
			return
		end
	end
	local refresh_npc_scene_cfg = FestivalSinglePartyData.Instance:GetEnterSceneCfg()
	if refresh_npc_scene_cfg == nil then return end
	local have_turkey_scene = {}
	for k, v in pairs(refresh_npc_scene_cfg) do
		local scene_id = v.scene_id
		local turkey_count = FestivalSinglePartyData.Instance:GetSceneNpcCountBySceneID(scene_id)
		if turkey_count > 0 then
			table.insert(have_turkey_scene, v.scene_id)
		end
	end
	local index = math.random(#have_turkey_scene)
	local target_scene = have_turkey_scene[index]
	local current_scene_id = Scene.Instance:GetSceneId()
	for k,v in pairs(refresh_npc_scene_cfg) do
		if current_scene_id == v.scene_id then
			local current_count = FestivalSinglePartyData.Instance:GetSceneNpcCountBySceneID(current_scene_id)
			if current_count > 0 then
				SysMsgCtrl.Instance:ErrorRemind(Language.SingleParty.TurkeyRemind)
				return
			end
		end
	end
	if Scene.Instance:GetMainRole():IsFightState() then
		GuajiCtrl.Instance:MoveToScene(target_scene)
	else
		GuajiCtrl.Instance:FlyToScene(target_scene)
	end
end

-- 因配置表修改,无法获得item_id
function FestivalSinglePartyView:OnClickTitle()
	if nil == next(self.reward_list) and nil == self.reward_list[1] and self.reward_list[1].reward_item == nil then
		return
	end

	TipsCtrl.Instance:OpenItem(self.reward_list[1].reward_item[0])
end

function FestivalSinglePartyView:OnOtherClickTitle()
	if nil == next(self.reward_list) and nil == self.reward_list[2] and self.reward_list[2].reward_item == nil then
		return
	end

	TipsCtrl.Instance:OpenItem(self.reward_list[2].reward_item[0])
end

function FestivalSinglePartyView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(284)
end

--------------------------SinglePartyCell---------------------------------
SinglePartyCell = SinglePartyCell or BaseClass(BaseCell)

function SinglePartyCell:__init()
	self.is_show_rank_image = false

	self.reward_item_list = {}
	for i = 1, 3 do
		self.reward_item_list[i] = ItemCell.New()
		self.reward_item_list[i]:SetInstanceParent(self.node_list["Item"..i])
	end
end

function SinglePartyCell:__delete()
	for k, v in pairs(self.reward_item_list) do
		v:DeleteMe()
	end
end

function SinglePartyCell:SetIndex(cell_index)
	self.index = cell_index
end

function SinglePartyCell:SetData(data, reward_list)
	self.data = data
	if nil == data and reward_list == nil then
		return
	end
	self.node_list["Name"].text.text = data.user_name or ""
	self.node_list["KillCount"].text.text = data.kill_monster_count or 0

	if self.index > 3 then
		self.is_show_rank_image = false
		self.node_list["Rank"].text.text = self.index
	else
		self.is_show_rank_image = true
		self.node_list["RankImg"].image:LoadSprite(ResPath.GetRankIcon(self.index))
	end

	if nil == reward_list.reward_item then
		return
	end
	self.node_list["RankImg"].gameObject:SetActive(self.is_show_rank_image)
	self.node_list["Rank"].gameObject:SetActive(not self.is_show_rank_image)
	for i = 1, 3 do
		if reward_list.reward_item[i - 1] ~= nil then
			self.reward_item_list[i]:SetParentActive(true)
			self.reward_item_list[i]:SetData(reward_list.reward_item[i - 1])
		else
			self.reward_item_list[i]:SetParentActive(false)
		end
	end

	AvatarManager.Instance:SetAvatar(self.data.uid, self.node_list["HeadRaw"], self.node_list["HeadIcon"], self.data.sex, self.data.prof, false)
end