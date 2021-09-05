TombExploreFBView = TombExploreFBView or BaseClass(BaseView)
TombExploreFBView.GatherId = 0

function TombExploreFBView:__init()
	self.ui_config = {{"uis/views/tombexplore_prefab", "TombExploreFBView"}}
	self.last_task_count = 0
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.active_close = false
	self.fight_info_view = true
end

function TombExploreFBView:ReleaseCallBack()
	GlobalTimerQuest:CancelQuest(self.time_quest)
	if self.show_mode_list_event ~= nil then
		GlobalEventSystem:UnBind(self.show_mode_list_event)
		self.show_mode_list_event = nil
	end
	if self.obj_del_event ~= nil then
		GlobalEventSystem:UnBind(self.obj_del_event)
		self.obj_del_event = nil
	end

	if self.clear_task_toggle ~= nil then
		GlobalEventSystem:UnBind(self.clear_task_toggle)
		self.clear_task_toggle = nil
	end

	if self.stop_gather_event ~= nil then
		GlobalEventSystem:UnBind(self.stop_gather_event)
		self.stop_gather_event = nil
	end

	if self.start_gather_event ~= nil then
		GlobalEventSystem:UnBind(self.start_gather_event)
		self.start_gather_event = nil
	end

	if self.team_view ~= nil then
		self.team_view:DeleteMe()
		self.team_view = nil
	end

	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}

	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function TombExploreFBView:LoadCallBack()
	self.node_list["Btn03"].button:AddClickListener(BindTool.Bind(self.BOSSClick, self))
	self.node_list["BtnFireMine"].button:AddClickListener(BindTool.Bind(self.TeamClick, self))
	self.node_list["ToggleTask"].toggle:AddClickListener(BindTool.Bind(self.TaskToggleChange, self))
	self.node_list["BOSSToggle"].toggle:AddClickListener(BindTool.Bind(self.TeamButtonClick, self))


	self.time_count = -100
	self.boss_time_count = 0
	self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.Timer, self), 1)

	self.auto_task_id = nil
	self.item_cell_list = {}
	local items_cfg = TombExploreData.Instance:GetTombActivityOtherCfg().boss_item_id
	if items_cfg and next(items_cfg) ~= nil then
		for i = 1, 3 do
			self.item_cell_list[i] = ItemCell.New()
			self.item_cell_list[i]:SetInstanceParent(self.node_list["item_".. i])
			local item_data = {}
			item_data.item_id = items_cfg[i-1].item_id
			item_data.num = items_cfg[i-1].num
			item_data.is_bind = items_cfg[i-1].is_bind
			item_data.is_gray = false
			item_data.is_up_arrow = false
			self.item_cell_list[i]:SetData(item_data)
		end
	end

	self:InitScroller()

	self.show_mode_list_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON, BindTool.Bind(self.OnMainUIModeListChange, self))
	self.obj_del_event = GlobalEventSystem:Bind(ObjectEventType.OBJ_DELETE,
		BindTool.Bind(self.OnObjDelete, self))
	self.clear_task_toggle = GlobalEventSystem:Bind(
		MainUIEventType.MAINUI_CLEAR_TASK_TOGGLE,
		BindTool.Bind(self.ClearToggle, self))
	self.stop_gather_event = GlobalEventSystem:Bind(ObjectEventType.STOP_GATHER,
		BindTool.Bind(self.OnStopGather, self))
	self.start_gather_event = GlobalEventSystem:Bind(ObjectEventType.START_GATHER,
		BindTool.Bind(self.OnStartGather, self))

	self.team_view = TeamContentView.New(self.node_list["TeamContent"])
end

function TombExploreFBView:TeamButtonClick()
	self.team_view:ReloadData()
end

function TombExploreFBView:OnStopGather()
	self.is_gather = false
	if TombExploreFBView.GatherId > 0 and Scene.Instance:GetMainRole():IsStand() then
		self:AutoDoTask()
	end
end

function TombExploreFBView:OnStartGather()
	self.is_gather = true
end

function TombExploreFBView:CloseCallBack()
	TombExploreFBView.GatherId = 0
end

function TombExploreFBView:OpenCallBack()
	local tomb_data = TombExploreData.Instance
	local boss_name = tomb_data:GetBossName(tomb_data:GetBossCfg().boss_id)
	self.node_list["TxtBossName"].text.text = string.format( Language.TombExplore.BossName,boss_name)
end

function TombExploreFBView:TaskToggleChange(isOn)
	if isOn then
		self:Flush()
	end
end

--寻路至BOSS
function TombExploreFBView:BOSSClick()
	local boss_x, boss_y, boss_id = TombExploreData.Instance:GetBOSSInfo()
	local boss_info = TombExploreData.Instance:GetWangLingExploreBossInfo()
	local scene_id = Scene.Instance:GetSceneId()
	if boss_info and boss_info.monster_id then
		local callback = function()
			MoveCache.task_id = 0
			MoveCache.param1 = boss_info.monster_id
			GuajiCache.monster_id = boss_info.monster_id
			MoveCache.end_type = MoveEndType.FightByMonsterId
			GuajiCtrl.Instance:MoveToPos(scene_id, boss_x, boss_y, 4, 2)
		end
		callback()
		GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
	end
end

function TombExploreFBView:ClearToggle()
	if self.auto_task_id then
		local data = self:GetTaskDataByID(self.auto_task_id)
		if data.cfg.task_type == 1 or GuajiCache.guaji_type == GuajiType.None then
			self.node_list["Scroller"].toggle_group:SetAllTogglesOff()
			self:StopAutoTask()
		end
	end
end

function TombExploreFBView:OnMainUIModeListChange(is_show)
	self.node_list["NodeTombExploreInfoView"]:SetActive(is_show)
	if is_show then
		self:Flush()
	end
end

function TombExploreFBView:TaskClick(task_id, is_auto)
	local data = self:GetTaskDataByID(task_id)
	-- GuajiCtrl.Instance:StopGuaji()
	if data == nil or data.is_finish or (self.auto_task_id == task_id and not is_auto) then
		self:StopAutoTask()
		self.auto_task_id = task_id
			if self.node_list["Scroller"].scroller.isActiveAndEnabled then
				self.node_list["Scroller"].scroller:RefreshAndReloadActiveCellViews(true)
			end
		return
	end
	self.auto_task_id = task_id
	TombExploreData.Instance:NotifyTaskProcessChange(task_id, function ( ... )
		 GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.AutoDoTask,self), 0.1)
	end)
	self:AutoDoTask()
	if self.node_list["Scroller"].scroller.isActiveAndEnabled then
		self.node_list["Scroller"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function TombExploreFBView:StopAutoTask()
	TombExploreData.Instance:UnNotifyTaskProcessChange()
	self.auto_task_id = nil
end

function TombExploreFBView:GetTaskDataByID(task_id)
	local data = nil
	local s_data = TombExploreData.Instance:GetTombFBTaskInfo()
	for k,v in pairs(s_data) do
		if v.cfg.task_id == task_id then
			return v
		end
	end
end

function TombExploreFBView:OnObjDelete(obj)
	if not self.is_gather and obj and obj:IsGather() and obj:GetGatherId() == TombExploreFBView.GatherId then
		GlobalTimerQuest:AddDelayTimer(function ()
			if not self.is_gather then
				self:AutoDoTask()
			end
		end, 0.1)
	end
end

function TombExploreFBView:AutoDoTask()
	local data = self:GetTaskDataByID(self.auto_task_id)

	if data == nil or data.is_finish then
		GuajiCtrl.Instance:StopGuaji()
		self.auto_task_id = nil
		local task_info = TombExploreData.Instance:GetTombFBTaskInfo()
		if task_info then
			local info = task_info[1]
			if info then
				if not info.is_finish then
					self.auto_task_id = info.cfg.task_id
				end
			end
		end
		if self.auto_task_id then
			self:TaskClick(self.auto_task_id, true)
		else
			TombExploreFBView.GatherId = 0
			GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
			TombExploreData.Instance:UnNotifyTaskProcessChange()
			self:ClearToggle()
		end
		return
	end
	local scene_id = Scene.Instance:GetSceneId()
	local list = nil
	local end_type = nil
	local target = nil
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	GuajiType.IsManualState = false
	if data.cfg.task_type == 1 then
		--采集
		GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
		end_type = MoveEndType.GatherById
		list = ConfigManager.Instance:GetSceneConfig(scene_id).gathers
		target = Scene.Instance:SelectMinDisGather(data.cfg.param_id)
		TombExploreFBView.GatherId = data.cfg.param_id
	else
		--打怪
		list = ConfigManager.Instance:GetSceneConfig(scene_id).monsters
		end_type = MoveEndType.Auto
		target = Scene.Instance:SelectMinDisMonster(data.cfg.param_id)
		TombExploreFBView.GatherId = 0
	end

	local x, y, id = 0, 0, 0
	if target then
		id = data.cfg.param_id
		x, y = target:GetLogicPos()
	else
		local target_distance = 1000000
		local p_x, p_y = Scene.Instance:GetMainRole():GetLogicPos()
		for k, v in pairs(list) do
			if v.id == data.cfg.param_id  then
				if not AStarFindWay:IsBlock(v.x, v.y) then
					local distance = GameMath.GetDistance(p_x, p_y, v.x, v.y, false)
					if distance < target_distance then
						target_distance = distance
						x = v.x
						y = v.y
						id = v.id
					end
				end
			end
		end
	end
	MoveCache.end_type = end_type
	MoveCache.param1 = id
	MoveCache.task_id = 0
	GuajiCache.target_obj_id = id
	local callback = function()
		if end_type == MoveEndType.GatherById then
			GuajiCtrl.Instance:MoveToPos(scene_id, x, y, 1, 1)
		else
			GuajiCtrl.Instance:MoveToPos(scene_id, x, y, 2, 0)
		end
	end
	callback()
	GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
end

local is_first_set = true
function TombExploreFBView:OnFlush(param_t)
	if not self:IsLoaded() then
		return
	end
	local fb_info = TombExploreData.Instance:GetTombFBInfo()
	--限时奖励时间
	local tmp_time = math.floor(fb_info.limit_task_time - TimeCtrl.Instance:GetServerTime())
	if tmp_time > 0 then
		self.time_count = tmp_time
	end

	local is_having_boss = fb_info.boss_num > 0
	self.node_list["NodeTimer"]:SetActive(not is_having_boss)
	self.node_list["NodeHavingBOSS"]:SetActive(is_having_boss)

	self:FlushBossIcon()

	--任务滚动条
	if self.node_list["Scroller"] and self.node_list["Scroller"].scroller.isActiveAndEnabled then
		self.node_list["Scroller"].scroller:RefreshAndReloadActiveCellViews(true)
	end
	--结算面板
	local show_victory = false
	for k,v in pairs(fb_info.item_list) do
		if v.item_id ~= 0 then
			show_victory = true
			break
		end
	end
	if show_victory then
		GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	end
	--奇遇完成时跳到BOSS
	if TombExploreData.Instance:IsTaskAllDone() and self.node_list["BOSSToggle"].toggle.isActiveAndEnabled then
		if is_first_set then
			is_first_set = false
			-- self.node_list["BOSSToggle"].toggle.isOn = true
		end
	else
		is_first_set = true
	end

	for k, v in pairs(param_t) do
		if k == "flush_team" and self.team_view then
			self.team_view:ReloadData()
		end
	end
end

function TombExploreFBView:FlushBossIcon()
	--BOSS刷新时间
	local fb_info = TombExploreData.Instance:GetTombFBInfo()
	if fb_info then
		FuBenCtrl.Instance:SetMonsterInfo(TombExploreData.Instance:GetBossCfg().boss_id)
		local call_back = function()
			self:BOSSClick()
		end
		FuBenCtrl.Instance:SetMonsterClickCallBack(call_back)
		local tmp_time2 = math.floor(fb_info.boss_reflush_time - TimeCtrl.Instance:GetServerTime())
		if tmp_time2 > 0 then
			self.boss_time_count = tmp_time2
			self:SetTime()
			FuBenCtrl.Instance:SetMonsterDiffTime(self.boss_time_count)
			FuBenCtrl.Instance:ShowMonsterHadFlush(false)
		else
			local monster_info = TombExploreData.Instance:GetWangLingExploreBossInfo()
			local text = nil
			if monster_info and monster_info.max_hp > 0 then
				text = (math.floor(monster_info.cur_hp / monster_info.max_hp * 100 * 100) / 100) .."%"
			end
			FuBenCtrl.Instance:ShowMonsterHadFlush(true, text)
		end
	end
end

--BOSS刷新计时
function TombExploreFBView:Timer()
	if not self:IsLoaded() or nil == self.node_list then
		return
	end

	if self.time_count ~= -100 then
		if self.time_count > 0 then
			self.time_count = self.time_count - 1
		else
			self.time_count = -100
			self.node_list["Scroller"].scroller:RefreshAndReloadActiveCellViews(true)
		end
	end

	self.boss_time_count = self.boss_time_count - 1
	self:SetTime()
end

--滚动条
function TombExploreFBView:InitScroller()
	self.cell_list = {}

	local delegate = self.node_list["Scroller"].list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #(TombExploreData.Instance:GetTombFBTaskInfo())
	end
	--大小
	delegate.CellSizeDel = function(dataIndex)
		dataIndex = dataIndex + 1
		local s_data = TombExploreData.Instance:GetTombFBTaskInfo()
		if s_data[dataIndex].is_double_reward and
			not s_data[dataIndex].is_finish and
			self.time_count > 0 then
			return 115
		else
			return 80
		end
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		local s_data = TombExploreData.Instance:GetTombFBTaskInfo()
		data_index = data_index + 1
		if self.cell_list[cell] == nil then
			self.cell_list[cell] = TombExploreScrollerCell.New(cell.gameObject)
			self.cell_list[cell].mother_view = self
			self.cell_list[cell].toggle_group = self.node_list["Scroller"].toggle_group
		end
		local data = s_data[data_index]
		data.data_index = data_index
		self.cell_list[cell]:SetData(data)
	end
end

--BOSS时间赋值
function TombExploreFBView:SetTime()
	local boss_time_count_text = ""
	local h2, m2, s2 = WelfareData.Instance:TimeFormat(self.boss_time_count)
	boss_time_count_text = self:TimeWithZero(h2)..":"..self:TimeWithZero(m2)..":"..self:TimeWithZero(s2)

	if self.boss_time_count > 0 then
		if self.node_list["TxtTimer"] then
			self.node_list["TxtTimer"].text.text = boss_time_count_text
		end
	else
		if self.node_list["TxtTimer"] then
			self.node_list["TxtTimer"].text.text = ""
		end
	end
end

--把时间换成"01"格式
function TombExploreFBView:TimeWithZero(num)
	if num < 0 then
		return "00"
	end

	if num >= 10 then
		return num
	else
		return "0"..num
	end
end

function TombExploreFBView:TeamClick()
	ScoietyCtrl.Instance:AutoHaveTeamReq()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
end

--滚动条格子------------------------------------------------------
TombExploreScrollerCell = TombExploreScrollerCell or BaseClass(BaseCell)

function TombExploreScrollerCell:__init()
	--self.node_list["Toggle"].toggle.onValueChanged:AddListener(BindTool.Bind(self.OnClick, self))
	self.node_list["Toggle"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.flush_time = 0
end

function TombExploreScrollerCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
	end
	self.item_cell = nil

	self.mother_view = nil
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
	self.flush_time = nil
end

-- function TombExploreScrollerCell:SetDoubleRewardTime(time)
	-- if self.data.is_double_reward then
	-- 	if time > 0 then
	-- 		if nil == self.count_down then
	-- 			local func = function(elapse_time, total_time)
	-- 				if elapse_time > total_time then
	-- 					if self.count_down then
	-- 						CountDown.Instance:RemoveCountDown(self.count_down)
	-- 						self.count_down = nil
	-- 					end
	-- 					return
	-- 				end
	-- 				local last_time = math.floor(total_time - elapse_time + 0.5)
	-- 				self.node_list["TxtDoubleReward"].text.text = string.format(Language.TombExplore.TimeDouble, TimeUtil.FormatSecond(last_time,2))
	-- 			end
	-- 			self.count_down = CountDown.Instance:AddCountDown(time, 1, func)
	-- 		end
	-- 		self.node_list["TxtDoubleReward"].text.text = string.format(Language.TombExplore.TimeDouble, TimeUtil.FormatSecond(time - TimeCtrl.Instance:GetServerTime(),2))
	-- 	end
	-- end

-- 	self.flush_time = time
-- end

function TombExploreScrollerCell:OnClick()
	self.mother_view:TaskClick(self.data.cfg.task_id)
end

function TombExploreScrollerCell:OnFlush()
	self.node_list["TxtTitle"].text.text = self.data.cfg.task_name

	self.item_cell:SetData(self.data.cfg.reward_item[0])

	local str = self.data.cfg.task_type == 1 and Language.TombExplore.CHAIJI or Language.TombExplore.Kill
	self.is_finish = self.data.is_finish
	if not self.is_finish then
		self.node_list["TxtTaskTarget"].text.text = "<color=#ffffff>" .. str .. "</color>" .. self.data.target_text
	else
		self.node_list["TxtTaskTarget"].text.text = str..self.data.cfg.task_name
	end

	if self.mother_view.time_count > 0 then
		self.is_double_reward = self.data.is_double_reward
	else
		self.is_double_reward = false
	end

	self.node_list["ImgFinish"]:SetActive(self.is_finish)
	self.node_list["TxtDoubleReward"]:SetActive(not self.is_finish and self.is_double_reward)

	self.node_list["Toggle"].toggle.isOn = (self.mother_view.auto_task_id == self.data.cfg.task_id)

	local fb_info = TombExploreData.Instance:GetTombFBInfo()
	if fb_info and fb_info.limit_task_time then
		local tmp_time = fb_info.limit_task_time
		if tmp_time > 0 then
			self.flush_time = tmp_time
		end
	end
	if self.flush_time <= 0 then
		self.node_list["TxtDoubleReward"]:SetActive(not self.is_finish and self.is_double_reward)
	else
		if nil == self.time_coundown then
			self.time_coundown = GlobalTimerQuest:AddTimesTimer(
					BindTool.Bind(self.OnTimeUpdate, self), 1, self.flush_time - TimeCtrl.Instance:GetServerTime())
		end
		self:OnTimeUpdate()
		self.node_list["TxtDoubleReward"]:SetActive(not self.is_finish and self.is_double_reward)
	end
end

function TombExploreScrollerCell:OnTimeUpdate()
	if nil == self.time_coundown then return end
	local time = math.max(0, self.flush_time - TimeCtrl.Instance:GetServerTime())
	if time <= 0 then
		time = ""
		self.node_list["TxtDoubleReward"].text.text = time
	else
		self.node_list["TxtDoubleReward"]:SetActive(not self.is_finish and self.is_double_reward)
		time = string.format(Language.TombExplore.TimeDouble,TimeUtil.FormatSecond(time, 2))
		self.node_list["TxtDoubleReward"].text.text = time
	end
end




-----------------------------------
---------队伍界面
TeamContentView = TeamContentView or BaseClass(BaseRender)

function TeamContentView:__init()
	self.node_list["BtnExit"].button:AddClickListener(BindTool.Bind(self.ExitClick, self))
	self.node_list["ButtonOpenTeam"].button:AddClickListener(BindTool.Bind(self.OpenTeam, self))
	self.node_list["ButtonCreateTeam"].button:AddClickListener(BindTool.Bind(self.CreateTeam, self))

	-- 生成滚动条
	self.cell_list = {}
	self.team_list = {}
	self.list_view = self.root_node
	local scroller_delegate = self.list_view.list_simple_delegate
	--生成数量
	scroller_delegate.NumberOfCellsDel = function()
		return #self.team_list or 0
	end
	--刷新函数
	scroller_delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1

		local menber_cell = self.cell_list[cell]
		if menber_cell == nil then
			menber_cell = TeamMenberCell.New(cell.gameObject)
			menber_cell.root_node.toggle.group = self.list_view.toggle_group
			menber_cell.team_view = self
			self.cell_list[cell] = menber_cell
		end

		menber_cell:SetIndex(data_index)
		menber_cell:SetData(self.team_list[data_index])
	end

	self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER, BindTool.Bind(self.OnChangeScene, self))
end

function TeamContentView:__delete()
	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}
	if self.scene_load_enter then
		GlobalEventSystem:UnBind(self.scene_load_enter)
		self.scene_load_enter = nil
	end
end

function TeamContentView:ExitClick()
	ScoietyCtrl.Instance:ExitTeamReq()
end

function TeamContentView:OnChangeScene()
	self:ReloadData()
end

function TeamContentView:ReloadData()
	if self.list_view and self.list_view.scroller.isActiveAndEnabled then
		self.team_list = ScoietyData.Instance:GetMemberList()
		if not next(self.team_list) then
			self.node_list["ButtonContent"]:SetActive(true)
		else
			self.node_list["ButtonContent"]:SetActive(false)
		end
		self.list_view.scroller:ReloadData(0)
		for i = 1, 3 do
			UI:SetGraphicGrey(self.node_list["ImgPerson" .. i], not (i <= #self.team_list and self.team_list[i].is_online == 1))
		end
	end
	self.node_list["NodeAddEXP"]:SetActive(self.list_view.scroller.isActiveAndEnabled and #self.team_list > 0)
	self.node_list["TxtAddEXP"].text.text = string.format("EXP+%s%%", ScoietyData.Instance:GetTeamExp(self.team_list))
	self.node_list["BtnExit"]:SetActive(#self.team_list > 0)
end

function TeamContentView:OpenTeam()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
end

function TeamContentView:CreateTeam()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
	local param_t = {}
	param_t.must_check = 0
	param_t.assign_mode = 1
	ScoietyCtrl.Instance:CreateTeamReq(param_t, true)
end

function TeamContentView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function TeamContentView:GetSelectIndex()
	return self.select_index or 0
end
----------------------------------------------------------------------------
--TeamMenberCell 		队伍滚动条格子
----------------------------------------------------------------------------

TeamMenberCell = TeamMenberCell or BaseClass(BaseCell)

function TeamMenberCell:__init()
	self.node_list["MenberItem"].toggle:AddClickListener(BindTool.Bind(self.ClickItem, self))
end

function TeamMenberCell:__delete()
	if self.team_member_handle then
		GlobalEventSystem:UnBind(self.team_member_handle)
		self.team_member_handle = nil
	end
end

function TeamMenberCell:OnFlush()
	if not self.data or not next(self.data) then return end

	-- local lv1, zhuan1 = PlayerData.GetLevelAndRebirth(self.data.level)
	local member_state = ScoietyData.Instance:GetMemberPosState(self.data.role_id, self.data.scene_id, self.data.is_online)
	self.node_list["TxtName"].text.text = self.data.name
	self.node_list["TxtLevel"].text.text = PlayerData.GetLevelString(self.data.level)
	self.node_list["TxtMenberName"].text.text = member_state

	-- 刷新选中特效
	local select_index = self.team_view:GetSelectIndex()
	if self.root_node.toggle.isOn and select_index ~= self.index then
		self.root_node.toggle.isOn = false
	elseif self.root_node.toggle.isOn == false and select_index == self.index then
		self.root_node.toggle.isOn = true
	end
end

function TeamMenberCell:ClickItem()
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if main_role_id == self.data.role_id then
		self.root_node.toggle.isOn = false
		return
	end
	self.root_node.toggle.isOn = true

	local function canel_callback()
		if self.root_node then
			self.root_node.toggle.isOn = false
		end
	end

	ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, self.data.name, nil, canel_callback)
end
