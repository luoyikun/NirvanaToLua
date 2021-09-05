KuaFuTuanZhanTaskView = KuaFuTuanZhanTaskView or BaseClass(BaseView)

local MAX_REWARD_NUM = 3

function KuaFuTuanZhanTaskView:__init()
	self.active_close = false
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.ui_config = {{"uis/views/kuafutuanzhan_prefab", "KuaFuTuanZhanTaskView"}}
	self.next_redistribute_time = 0
	self.my_score = 0
	self.my_rank = nil
	self.reward_cfg = nil
	self.next_flush_boss_time = -1
	self.auto_change = 0
	self.is_safe_area_adapter = true						-- IphoneX适配
end

function KuaFuTuanZhanTaskView:ReleaseCallBack()
	for k,v in pairs(self.reward_item_list) do
		v:DeleteMe()
	end
	self.reward_item_list = {}

	for k,v in pairs(self.owner_cell_list) do
		v:DeleteMe()
	end
	self.owner_cell_list = {}

	for k,v in pairs(self.reward_cell_list) do
		v:DeleteMe()
	end
	self.reward_cell_list = {}

	for k,v in pairs(self.boss_cell_list) do
		v:DeleteMe()
	end
	self.boss_cell_list = {}

	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.change_time_quest then
		GlobalTimerQuest:CancelQuest(self.change_time_quest)
		self.change_time_quest = nil
	end

	self.next_redistribute_time = 0
	self.my_score = 0
	self.my_rank = nil
	self.reward_cfg = nil
	self.broadcast_list = {}
	self.is_cross_server = 1
	self.activity_type = 0
	self.auto_change = 0
end

function KuaFuTuanZhanTaskView:LoadCallBack()
	self.node_list["BtnGet"].button:AddClickListener(BindTool.Bind(self.OnGetScoreReward, self))
	self.node_list["BtnCheckReward"].button:AddClickListener(BindTool.Bind(self.OnOpenRankView, self))
	self.node_list["PersonToggle"].toggle.onValueChanged:AddListener(BindTool.Bind(self.OnToggleSideInfo, self))
	self.node_list["SideToggle"].toggle:AddClickListener(BindTool.Bind(self.OnTogglePersonInfo, self))

	self.is_cross_server = KuaFuTuanZhanData.Instance:GetIsCrossServerState()

	self.activity_type = self.is_cross_server == 1 and ACTIVITY_TYPE.KF_TUANZHAN or ACTIVITY_TYPE.NIGHT_FIGHT_FB

	self.reward_item_list = {}
	self.boss_cell_list = {}

	self.broadcast_list = KuaFuTuanZhanData.Instance:GetBroadCastList()

	self.reward_cfg = KuaFuTuanZhanData.Instance:GetNightFightRewardCfg()
	for i = 1, MAX_REWARD_NUM do
		self.reward_item_list[i] = ItemCell.New()
		self.reward_item_list[i]:SetInstanceParent(self.node_list["RewardItem" .. i])
		-- self.reward_item_list[i].root_node.transform:SetLocalScale(0.7, 0.7, 0.7)
	end

	local reward_list_delegate = self.node_list["RankScroller"].list_simple_delegate
	reward_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetRankNumberOfCells, self)
	reward_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshFightRankCell, self)

	local boss_list_delegate = self.node_list["BossRankScroller"].list_simple_delegate
	boss_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetRankBossNumberOfCells, self)
	boss_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshBossRankCell, self)

	self.reward_cell_list = {}

	self.owner_cell_list = {}

	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))

	self:SetCountDownTimer()

end

function KuaFuTuanZhanTaskView:SwitchButtonState(enable)
	self.node_list["PanelTombExplore"]:SetActive(enable)
end

function KuaFuTuanZhanTaskView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if "switch_time" == k then
			self:ChangeInfo()
			self:SetBossInfo()
		elseif "flush_rank_list" == k then
			if self.node_list["RankScroller"] and self.node_list["RankScroller"].scroller.isActiveAndEnabled then
				self.node_list["RankScroller"].scroller:RefreshAndReloadActiveCellViews(true)
			end
			if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.KF_TUANZHAN) then
				KuaFuTuanZhanCtrl.Instance:SetAllPlayerInfo()
			end
		elseif "flush_boss_rank_list" == k then
			local boss_state = KuaFuTuanZhanData.Instance:GetBossIsFlushBoss()
			if boss_state == TUANZHAN_BOSS_STATE.BOSS_DIE then
				FuBenCtrl.Instance:SetBossTips(false)
				FuBenCtrl.Instance:SetMonsterIconGray(true, 1)
				if self.auto_change ~= boss_state then
					local act_info = KuaFuTuanZhanData.Instance:GetRoleInfo()
					if act_info then
						local info_reward_stamp = act_info.next_redistribute_time
						local server_time = TimeCtrl.Instance:GetServerTime()
						FuBenCtrl.Instance:SetMonsterDiffTime(info_reward_stamp - server_time)

						FuBenCtrl.Instance:ShowMonsterHadFlush(false, "", 1)
						FuBenCtrl.Instance:SetBossHpPercentValue(false)
					end
				end
				self.auto_change = boss_state
				-- if not self.node_list["PersonToggle"].toggle.isOn then
				-- 	self.node_list["PersonToggle"].toggle.isOn = true
				-- 	self.node_list["RankScroller"].scroller:ReloadData(0)
				-- end
			else
				if boss_state == TUANZHAN_BOSS_STATE.BOSS_FLASH and self.auto_change ~= boss_state then
					FuBenCtrl.Instance:SetBossTips(true)
					FuBenCtrl.Instance:SetMonsterIconGray(false, 1)
					-- self.node_list["SideToggle"].toggle.isOn = true
					self.auto_change = boss_state
				end
				FuBenCtrl.Instance:ShowMonsterHadFlush(true, "", 1)
				local hp_percent = KuaFuTuanZhanData.Instance:GetBossHpPercent()
				local percent_str = KuaFuTuanZhanData.Instance:GetShowPercent(hp_percent)
				local str = percent_str .. "%"
				FuBenCtrl.Instance:SetBossHpPercentValue(true, str)
			end

			if self.node_list["BossRankScroller"] and self.node_list["BossRankScroller"].scroller.isActiveAndEnabled then
				self.node_list["BossRankScroller"].scroller:RefreshAndReloadActiveCellViews(true)
			end
		end
	end

	if self.time_quest == nil then
		self:SetCountDownTimer()
	end
end

function KuaFuTuanZhanTaskView:OpenCallBack()
	self.next_flush_boss_time = -1
	-- KuaFuTuanZhanData.Instance:SetRoleScore(0)
	-- self:FlushPersonView()
	-- self:SetCountDownTimer()

	local loader = AllocAsyncLoader(self, "skill_button_loader")
	loader:Load("uis/views/kuafutuanzhan_prefab", "KuaFuTuanZhanSkill", function (obj)
		if IsNil(obj) then
			return
		end		
		
		MainUICtrl.Instance:ShowActivitySkill(obj)
		if nil == self.skill_render then
			self.skill_render = KuaFuTuanZhanSkillRender.New(obj)
			self.skill_render:Flush()
		end
	end)
end

function KuaFuTuanZhanTaskView:CloseCallBack()
	MainUICtrl.Instance:ShowActivitySkill(false)
	if self.skill_render then
		self.skill_render:DeleteMe()
		self.skill_render = nil
	end
end

function KuaFuTuanZhanTaskView:ChangeInfo()
	local act_info = KuaFuTuanZhanData.Instance:GetRoleInfo()
	if act_info then
		local info_reward_stamp = act_info.next_redistribute_time
		local info_score = act_info.score
		local info_rank = act_info.rank + 1
		if self.node_list["TextMyScore"] and self.node_list["TextMyRank"] then
			self.node_list["TextMyRank"].text.text = string.format(Language.NightFight.MyRank, act_info.total_rank + 1)
			self.node_list["TextMyScore"].text.text = string.format(Language.NightFight.MyScore, act_info.total_score)
			self.node_list["Ranktitle"].text.text = string.format(Language.NightFight.MyRank, act_info.total_rank + 1)
			self.node_list["Rankjifen"].text.text = string.format(Language.NightFight.MyScore, act_info.total_score)
		end
		if self.node_list["TxtRound"] then
			local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.KF_TUANZHAN)
			self.node_list["TxtRound"].text.text = is_open and string.format(Language.Activity.RoundTimes, act_info.turn) or ""
		end
		if info_reward_stamp ~= self.next_redistribute_time then
			self.next_redistribute_time = info_reward_stamp
			self:SetCountDownTimer()
		end
		if info_score ~= self.my_score then
			self.my_score = info_score
			self:FlushMyScore(info_score)
		end
		if info_rank ~= self.my_rank then
			self.my_rank = info_rank
			self:FlushMyRank(info_rank)
		end
	end
end

function KuaFuTuanZhanTaskView:SetCountDownTimer()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	if self.change_time_quest then
		GlobalTimerQuest:CancelQuest(self.change_time_quest)
		self.change_time_quest = nil
	end
	self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 0.5)
	self.change_time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushChangeTime, self), 1)
end


-- 刷新获得奖励的时间(阵营转换)
function KuaFuTuanZhanTaskView:FlushNextTime()
	local _,  end_time = ActivityData.Instance:GetActivityResidueTime(self.activity_type)

	local server_time = TimeCtrl.Instance:GetServerTime()
	if self.node_list["TxtGetRewardTime"] then
		self.node_list["TxtGetRewardTime"].text.text = string.format(Language.NightFight.RewardCountTime, TimeUtil.FormatSecond2MS(self.next_redistribute_time  - server_time))
	end

	-- if self.node_list["TxtTime"] then
	-- 	if (end_time - server_time) <= 0 then 
	-- 		self.node_list["TxtTime"]:SetActive(false)
	-- 	else
	-- 		self.node_list["TxtTime"].text.text = TimeUtil.FormatSecond2MS(end_time - server_time)
	-- 	end
	-- end
end

function KuaFuTuanZhanTaskView:FlushChangeTime()
	local server_time = TimeCtrl.Instance:GetServerTime()
	local change_time = TimeUtil.Format2TableDHMS(self.next_redistribute_time  - server_time)

	local flag_1 = change_time.min == 0 and change_time.s == self.broadcast_list[1]
	local flag_2 = change_time.min == 0 and change_time.s == self.broadcast_list[2]
	local flag_3 = change_time.min == 0 and change_time.s == self.broadcast_list[3]
	if flag_1 or flag_2 or flag_3 then
		local RemindDes = string.format(Language.NightFight.RemindDes, change_time.s)
		TipsCtrl.Instance:ShowActivityNoticeMsg(RemindDes)
	end
end



-- 刷新个人积分
function KuaFuTuanZhanTaskView:FlushMyScore(score)
	if self.node_list["TxtPersonScore"] then
		self.node_list["TxtPersonScore"].text.text = string.format(Language.NightFight.MyScore, score)
	end
	if self.node_list["TxtScore"] then
		self.node_list["TxtScore"].text.text = score
	end
end

-- 刷新排行积分
function KuaFuTuanZhanTaskView:FlushMyRank(rank)
	if self.node_list["TxtKillAssist"] then
		self.node_list["TxtKillAssist"].text.text = string.format(Language.NightFight.MyRank, rank)
	end

	if self.node_list["TxtRank"] then
		self.node_list["TxtRank"].text.text = rank
	end

	local range = self:GetRankRewardRange(rank)
	local cfg = self.reward_cfg[range]
	for i, v in ipairs(self.reward_item_list) do
		v:SetData(cfg[i - 1])
		v:SetParentActive(nil ~= cfg[i - 1])
	end
end

-- 排名奖励范围(根据排名返回档位)
function KuaFuTuanZhanTaskView:GetRankRewardRange(rank)
	if rank <= 3 then
		return 1
	elseif rank > 3 and rank <= 10 then
		return 2
	elseif rank > 10 and rank <= 20 then
		return 3
	else
		return 4
	end
end

function KuaFuTuanZhanTaskView:GetRankNumberOfCells()
	return #KuaFuTuanZhanData.Instance:GetRankListInfo()
end

-- -- 刷新活动结束时间
-- function KuaFuTuanZhanTaskView:FlushEndTime()
-- 	if self.node_list["TxtTime"] then
-- 		self.node_list["TxtTime"].text.text = TimeUtil.FormatSecond2MS(act_data.activity_end_time - server_time)
-- 	end
-- end


function KuaFuTuanZhanTaskView:FlushPersonView()
	local person_info = KuaFuTuanZhanData.Instance:GetPlayerInfo()
	self.node_list["TxtKillAssist"].text.text = string.format(Language.XiuLuo.KillAssit, person_info.kill_num, person_info.assist_kill_num)
	self.node_list["TxtPersonScore"].text.text = string.format(Language.XiuLuo.PersonScore, person_info.score)

	local reward_cfg = KuaFuTuanZhanData.Instance:GetUnFetchScoreRewardCfg()
	if nil == reward_cfg then
		return
	end
	self.node_list["TxtChouScore"].text.text = string.format(Language.XiuLuo.ReachScore, reward_cfg.need_score)

	for i, v in ipairs(self.reward_item_list) do
		v:SetData(reward_cfg.client_reward_item[i - 1])
		v:SetParentActive(nil ~= reward_cfg.client_reward_item[i - 1])
	end

	self.node_list["BtnGet"]:SetActive(person_info.score >= reward_cfg.need_score and person_info.score_reward_fetch_seq <= reward_cfg.seq)
end

function KuaFuTuanZhanTaskView:GetRankNumberOfCells()
	return #KuaFuTuanZhanData.Instance:GetFightRankInfo()
end

function KuaFuTuanZhanTaskView:RefreshFightRankCell(cell, cell_index)
	local the_cell = self.reward_cell_list[cell]
	local data_list = KuaFuTuanZhanData.Instance:GetFightRankInfo()
	cell_index = cell_index + 1
	if nil == the_cell then
		the_cell = KfTuanZhanRankItem.New(cell.gameObject,self)
		self.reward_cell_list[cell] = the_cell
	end
	the_cell:SetIndex(cell_index)
	the_cell:SetData(data_list[cell_index])
end

function KuaFuTuanZhanTaskView:GetRankBossNumberOfCells()
	return #KuaFuTuanZhanData.Instance:GetAllScoreRankInfo()
end

function KuaFuTuanZhanTaskView:RefreshBossRankCell(cell, cell_index)
	local the_cell = self.boss_cell_list[cell]
	local data_list = KuaFuTuanZhanData.Instance:GetAllScoreRankInfo()
	cell_index = cell_index + 1
	if nil == the_cell then
		the_cell = KfTuanZhanRankBossItem.New(cell.gameObject,self)
		self.boss_cell_list[cell] = the_cell
	end
	the_cell:SetIndex(cell_index)
	the_cell:SetData(data_list[cell_index])
end
-- function KuaFuTuanZhanTaskView:ShowRewardItem(index)
-- 	local item_cfg = self:GetRewardCfg(index)
-- 	for i = 1 , 3 do 
-- 		local reward_item = ItemCell.New()
-- 		reward_item:SetInstanceParent(self.node_list["RewardItem" .. i])
-- 		reward_item:SetData(item_cfg[i - 1])
-- 		self.reward_item_list[i] = reward_item
-- 	end
-- end

function KuaFuTuanZhanTaskView:GetRewardCfg(index)
	local reward_info = KuaFuTuanZhanData.Instance:GetShowRewardCfg(index)
	return reward_info
end


function KuaFuTuanZhanTaskView:RefreshRankCell(cell, cell_index)
	local the_cell = self.reward_cell_list[cell]
	if the_cell == nil then
		the_cell = KfTuanZhanRankItem.New(cell.gameObject, self)
		self.reward_cell_list[cell] = the_cell
	end
	cell_index = cell_index + 1

	local data_list = KuaFuTuanZhanData.Instance:GetRankListInfo()
	the_cell:SetData(data_list[cell_index])
end

function KuaFuTuanZhanTaskView:GetOwnerNumberOfCells()
	return #KuaFuTuanZhanData.Instance:GetPillarInfo()
end

function KuaFuTuanZhanTaskView:RefreshOwnerCell(cell, cell_index)
	local the_cell = self.owner_cell_list[cell]
	if the_cell == nil then
		the_cell = KfTuanZhanPillarOwnerItem.New(cell.gameObject,self)
		self.owner_cell_list[cell] = the_cell
	end
	cell_index = cell_index + 1

	local data_list = KuaFuTuanZhanData.Instance:GetPillarInfo()
	the_cell:SetData(data_list[cell_index])
end

function KuaFuTuanZhanTaskView:OnGetScoreReward()
	KuaFuTuanZhanCtrl.Instance:SendGetCrossTuanzhanReward()
end

function KuaFuTuanZhanTaskView:OnOpenRankView()
	ViewManager.Instance:Open(ViewName.KuaFuTuanZhanRewardView)
end

function KuaFuTuanZhanTaskView:OnTogglePersonInfo()
	-- self:FlushPersonView()
end

function KuaFuTuanZhanTaskView:OnToggleSideInfo()
	-- self.node_list["ScrollerRankList"].scroller:RefreshAndReloadActiveCellViews(true)
end

function KuaFuTuanZhanTaskView:SetSelectPillar(index)
	self.select_index = index

	for k,v in pairs(self.owner_cell_list) do
		v:FlushHL()
	end
end

function KuaFuTuanZhanTaskView:GetSelectPillar()
	return self.select_index
end

function KuaFuTuanZhanTaskView:SetBossInfo()
	local info = KuaFuTuanZhanData.Instance:GetRoleInfo()
	local boss_id = KuaFuTuanZhanData.Instance:GetBossID()
	if nil == next(info) or self.next_flush_boss_time == info.next_flush_boss_time then
		return
	end
	-- self.next_flush_boss_time = info.next_flush_boss_time

	-- local boss_flush_time = math.floor(info.next_flush_boss_time - TimeCtrl.Instance:GetServerTime())
	-- FuBenCtrl.Instance:SetMonsterDiffTime(boss_flush_time)
	if nil ~= boss_id then
		FuBenCtrl.Instance:SetMonsterInfo(boss_id)
	end
	FuBenCtrl.Instance:SetMonsterIconState(true)

	-- if KuaFuTuanZhanData.Instance:GetBossIsFlushBoss() then
	-- 	FuBenCtrl.Instance:ShowMonsterHadFlush(true, string.format(Language.Activity.GoFindBoss), 1)
	-- else
	-- 	FuBenCtrl.Instance:ShowMonsterHadFlush(false, string.format(Language.Activity.BossDie), 1)
	-- end
end


----------------------KuaFuTuanZhanSkillRender------------------------------------
KuaFuTuanZhanSkillRender = KuaFuTuanZhanSkillRender  or BaseClass(BaseRender)

function KuaFuTuanZhanSkillRender:__init()

end

function KuaFuTuanZhanSkillRender:__delete()
	
end

function KuaFuTuanZhanSkillRender:LoadCallBack()
	self.node_list["BtnFollow"].button:AddClickListener(BindTool.Bind(self.OnTrackFirstOne, self))
end

function KuaFuTuanZhanSkillRender:OnFlush()

end

function KuaFuTuanZhanSkillRender:OnTrackFirstOne()
	local enemy_first = KuaFuTuanZhanData.Instance:GetEnemyFirstRank()
	if enemy_first == nil then
		return SysMsgCtrl.Instance:ErrorRemind(Language.NightFight.NoSideRank)
	end
	KuaFuTuanZhanCtrl.Instance:SendFirstPos(NIGHT_FIGHT_OPERA_TYPE.NIGHT_FIGHT_OPERA_TYPE_POSI_INFO, enemy_first)
end


----------------------KfTuanZhanPillarOwnerItem------------------------------------
KfTuanZhanPillarOwnerItem = KfTuanZhanPillarOwnerItem  or BaseClass(BaseCell)

function KfTuanZhanPillarOwnerItem:__init(instance, parent)
	self.parent = parent
	self.node_list["KuaFuTuanZhanTaskOwenerItem"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function KfTuanZhanPillarOwnerItem:__delete()
	self.parent = nil
end

function KfTuanZhanPillarOwnerItem:OnFlush()
	self.node_list["TxtItemName"].text.text = string.format(Language.KuafuTeambattle.OccupyDesc, self.data.index + 1)

	if nil ~= Language.KuafuTeambattle["side" .. self.data.owner_side] then
		local color_str = (0 == self.data.owner_side) and "<color=#FE1515>" or "<color=#00ffff>"
		self.node_list["TxtOwnerName"].text.text = color_str .. self.data.owner_name .. "(" .. Language.KuafuTeambattle["side" .. self.data.owner_side] .. ")</color>"
	else
		self.node_list["TxtOwnerName"].text.text = Language.KuafuTeambattle.NotOccupy
	end
end

function KfTuanZhanPillarOwnerItem:FlushHL()
	local is_hl = self.parent:GetSelectPillar() == self.data.index
	self.node_list["ImgLight"]:SetActive(is_hl)
end

function KfTuanZhanPillarOwnerItem:OnClick()
	self.node_list["ImgLight"]:SetActive(true)
	self.parent:SetSelectPillar(self.data.index)

	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	MoveCache.end_type = MoveEndType.Auto
	local pillar_cfg = KuaFuTuanZhanData.Instance:GetPillarCfg(self.data.index)
	local callback = function()
		MoveCache.end_type = MoveEndType.Auto
		GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), pillar_cfg.x_pos, pillar_cfg.y_pos, 10, 10)
	end
	callback()
	GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
end
--------------------KfTuanZhanRankItem--------------------------------------
KfTuanZhanRankItem = KfTuanZhanRankItem or BaseClass(BaseCell)

function KfTuanZhanRankItem:__init()

end

function KfTuanZhanRankItem:__delete()

end

function KfTuanZhanRankItem:GetData()

end

function KfTuanZhanRankItem:OnFlush()
	local str = ""
	str = ToColorStr(self.data.user_name, TEXT_COLOR.BLUE_4)
	if nil ~= self.data.is_red_side and self.data.is_red_side == 1 then
		str = ToColorStr(self.data.user_name, TEXT_COLOR.RED_4)
	end
	
	self.node_list["Name"].text.text = str
	self.node_list["Rank"].text.text = self.index
	self.node_list["ScoreNum"].text.text = self.data.score

	if self.index <= 3 then
		self.node_list["Rank"]:SetActive(false)
		self.node_list["RankImage"]:SetActive(true)
		local bundle, asset = ResPath.GetRankIcon(self.index)
		self.node_list["RankImage"].image:LoadSprite(bundle, asset .. ".png")
		self.node_list["RankImage"].image:SetNativeSize()
	else
		self.node_list["Rank"]:SetActive(true)
		self.node_list["RankImage"]:SetActive(false)
	end

end

--------------------KfTuanZhanRankBossItem--------------------------------------
KfTuanZhanRankBossItem = KfTuanZhanRankBossItem or BaseClass(BaseCell)

function KfTuanZhanRankBossItem:__init()

end

function KfTuanZhanRankBossItem:__delete()

end

function KfTuanZhanRankBossItem:OnFlush()
	-- local str = ""
	-- str = ToColorStr(self.data.user_name, TEXT_COLOR.BLUE_4)
	-- if nil ~= self.data.is_red_side and self.data.is_red_side == 1 then
	-- 	str = ToColorStr(self.data.user_name, TEXT_COLOR.RED_4)
	-- end
	
	local boss_id = KuaFuTuanZhanData.Instance:GetBossID()
	local boss_hp = BossData.Instance:GetMonsterInfo(boss_id)
	-- local hurt_per = KuaFuTuanZhanData.Instance:GetShowPercent(self.data.hurt_per)
	self.node_list["Name"].text.text = self.data.user_name
	self.node_list["Rank"].text.text = self.index
	self.node_list["ScoreNum"].text.text = self.data.total_score
	if self.index <= 3 then
		self.node_list["Rank"]:SetActive(false)
		self.node_list["RankImage"]:SetActive(true)
		local bundle, asset = ResPath.GetRankIcon(self.index)
		self.node_list["RankImage"].image:LoadSprite(bundle, asset .. ".png")
		self.node_list["RankImage"].image:SetNativeSize()
	else
		self.node_list["Rank"]:SetActive(true)
		self.node_list["RankImage"]:SetActive(false)
	end
end
