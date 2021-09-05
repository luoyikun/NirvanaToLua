KuaFuBorderlandView = KuaFuBorderlandView or BaseClass(BaseView)
KuaFuBorderlandView.GatherId = 0

function KuaFuBorderlandView:__init()
	self.ui_config = {
		{"uis/views/kuafuborderland_prefab", "KuaFuBorderlandView"},
	}

	self.last_task_count = 0
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.active_close = false
	self.fight_info_view = true
end

function KuaFuBorderlandView:__delete()

end

function KuaFuBorderlandView:ReleaseCallBack()
	for k, v in pairs(self.task_cell_list) do
		v:DeleteMe()
	end
	self.task_cell_list = {}

	for k, v in pairs(self.boss_cell_list) do
		v:DeleteMe()
	end
	self.boss_cell_list = {}

	for k, v in pairs(self.rank_cell_list) do
		v:DeleteMe()
	end
	self.rank_cell_list = {}

	if self.show_mode_list_event ~= nil then
		GlobalEventSystem:UnBind(self.show_mode_list_event)
		self.show_mode_list_event = nil
	end
	-- if self.obj_del_event ~= nil then
	-- 	GlobalEventSystem:UnBind(self.obj_del_event)
	-- 	self.obj_del_event = nil
	-- end

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

	if self.touch_move_event ~= nil then
		GlobalEventSystem:UnBind(self.touch_move_event)
		self.touch_move_event = nil
	end

	-- if self.team_btn then
	-- 	self.team_btn:DeleteMe()
	-- 	self.team_btn = nil
	-- end

	self.flush_to_rank_list = true

	if self.count_down_reset_flag_time then
		CountDown.Instance:RemoveCountDown(self.count_down_reset_flag_time)
		self.count_down_reset_flag_time = nil
	end
	self:CancelFlushToBossListTime()
end

function KuaFuBorderlandView:LoadCallBack()
	self.task_list_data = {}
	self.task_cell_list = {}
	local task_list_view_delegate = self.node_list["TaskList"].list_simple_delegate
	task_list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetTaskNumberOfCells, self)
	task_list_view_delegate.CellSizeDel = BindTool.Bind(self.GetTaskCellSizeDel, self)
	task_list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshTaskListView, self)

	self.boss_list_data = {}
	self.boss_cell_list = {}
	local boss_list_view_delegate = self.node_list["BossList"].list_simple_delegate
	boss_list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetBossNumberOfCells, self)
	boss_list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshBossListView, self)

	self.rank_list_data = {}
	self.rank_cell_list = {}
	local rank_list_view_delegate = self.node_list["RankList"].list_simple_delegate
	rank_list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetRankNumberOfCells, self)
	rank_list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshRankListView, self)


	self.show_mode_list_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON, 
		BindTool.Bind(self.OnMainUIModeListChange, self))
	-- self.obj_del_event = GlobalEventSystem:Bind(ObjectEventType.OBJ_DELETE,
	-- 	BindTool.Bind(self.OnObjDelete, self))
	self.clear_task_toggle = GlobalEventSystem:Bind(
		MainUIEventType.MAINUI_CLEAR_TASK_TOGGLE,
		BindTool.Bind(self.ClearToggle, self))
	self.stop_gather_event = GlobalEventSystem:Bind(ObjectEventType.STOP_GATHER,
		BindTool.Bind(self.OnStopGather, self))
	self.start_gather_event = GlobalEventSystem:Bind(ObjectEventType.START_GATHER,
		BindTool.Bind(self.OnStartGather, self))
	self.touch_move_event = GlobalEventSystem:Bind(LayerEventType.TOUCH_MOVED,
		BindTool.Bind(self.StopAutoTask, self))

	self.time_count = 0

	-- local loader = AllocAsyncLoader(self, "kf_borderland_team_btn")
	-- loader:Load("uis/views/kuafuborderland_prefab", "KFBorderlandTeamBtn", function (obj)
	-- 	if not IsNil(obj) then
	-- 		MainUICtrl.Instance:ShowActivitySkill(obj)
	-- 		if self.team_btn then
	-- 			self.team_btn:DeleteMe()
	-- 			self.team_btn = nil
	-- 		end
	-- 		self.team_btn = KFBorderlandTeamBtn.New(obj)
	-- 	end
	-- end)	
	self.flush_to_rank_list = true
end

function KuaFuBorderlandView:OpenCallBack()
	self:Flush("first_flush_rank")
end

function KuaFuBorderlandView:CloseCallBack()
	KuaFuBorderlandView.GatherId = 0
	-- MainUICtrl.Instance:ShowActivitySkill(false)
	-- if self.team_btn then
	-- 	self.team_btn:DeleteMe()
	-- 	self.team_btn = nil
	-- end
	if self.count_down_reset_flag_time then
		CountDown.Instance:RemoveCountDown(self.count_down_reset_flag_time)
		self.count_down_reset_flag_time = nil
	end
	self:CancelFlushToBossListTime()
end

function KuaFuBorderlandView:CancelFlushToBossListTime()
	if self.flush_to_boss_toggle_timer then
		CountDown.Instance:RemoveCountDown(self.flush_to_boss_toggle_timer)
		self.flush_to_boss_toggle_timer = nil
	end
end

function KuaFuBorderlandView:OnMainUIModeListChange(is_show)
	self.node_list["KuaFuBorderlandView"]:SetActive(is_show)
	if is_show then
		self:Flush()
	end
end

function KuaFuBorderlandView:OnObjDelete(obj)
	if not self.is_gather and obj and obj:IsGather() and obj:GetGatherId() == KuaFuBorderlandView.GatherId then
		GlobalTimerQuest:AddDelayTimer(function ()
			if not self.is_gather then
				self:AutoDoTask()
			end
		end, 0.1)
	end
end

function KuaFuBorderlandView:ClearToggle()
	if self.auto_task_id then
		local data = self:GetTaskDataByID(self.auto_task_id)
		if data.cfg.task_type == 1 or GuajiCache.guaji_type == GuajiType.None then
			-- self.node_list["TaskList"].toggle_group:SetAllTogglesOff()
			self:StopAutoTask()
		end
	end
end

function KuaFuBorderlandView:OnStopGather()
	self.is_gather = false
	if KuaFuBorderlandView.GatherId > 0 and Scene.Instance:GetMainRole():IsStand() then
		self:AutoDoTask()
	end
end

function KuaFuBorderlandView:OnStartGather()
	self.is_gather = true
end


------任务列表
function KuaFuBorderlandView:GetTaskNumberOfCells()
	return #self.task_list_data
end

function KuaFuBorderlandView:GetTaskCellSizeDel(cell_index)
	cell_index = cell_index + 1
	local s_data = self.task_list_data
	if s_data[cell_index].is_double_reward and
		not s_data[cell_index].is_finish and
		self.time_count > 0 then
		return 115
	else
		return 80
	end
end

function KuaFuBorderlandView:RefreshTaskListView(cell, cell_index)
	local item_cell = self.task_cell_list[cell]
	if nil == item_cell then
		item_cell = TaskListItemRenderer.New(cell.gameObject)
		item_cell:SetClickCallBack(BindTool.Bind(self.OnClickTaskItemCell, self))
		self.task_cell_list[cell] = item_cell
	end

	local data = self.task_list_data[cell_index + 1] or {}
	item_cell:SetIndex(cell_index)
	item_cell:SetData(data)
	item_cell:SetHighLight(self.auto_task_id == data.cfg.task_id)
end

function KuaFuBorderlandView:OnClickTaskItemCell(cell)
	local data = cell:GetData()
	local index = cell:GetIndex()

	-- self.task_select_index = index


	if nil == data then return end
	self:TaskClick(data.cfg.task_id)
end

------Boss列表
function KuaFuBorderlandView:GetBossNumberOfCells()
	return #self.boss_list_data
end

function KuaFuBorderlandView:RefreshBossListView(cell, cell_index)
	local item_cell = self.boss_cell_list[cell]
	if nil == item_cell then
		item_cell = BossListItemRenderer.New(cell.gameObject)
		item_cell:SetClickCallBack(BindTool.Bind(self.OnClickBossItemCell, self))
		self.boss_cell_list[cell] = item_cell
	end

	local data = self.boss_list_data[cell_index + 1] or {}
	item_cell:SetIndex(cell_index)
	item_cell:SetData(data)
	item_cell:SetHighLight(self.boss_select_index == cell_index)
end

function KuaFuBorderlandView:OnClickBossItemCell(cell)
	local data = cell:GetData()
	local index = cell:GetIndex()

	self.boss_select_index = index
	for k, v in pairs(self.boss_cell_list) do
		v:SetHighLight(v:GetIndex() == self.boss_select_index)
	end

	KuaFuBorderlandView.GatherId = 0
	self:StopAutoTask()
	if nil == data then return end
	-- if nil == data or 0 == data.boss_live_flag then return end

	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	MoveCache.end_type = MoveEndType.Auto
	GuajiCtrl.Instance:MoveToPos(CROSS_BINGJINGZHIDI_DEF.MAP_ID, data.born_pos_x, data.born_pos_y, 0, 0)
end

------排行列表
function KuaFuBorderlandView:GetRankNumberOfCells()
	return #self.rank_list_data
end

function KuaFuBorderlandView:RefreshRankListView(cell, cell_index)
	local item_cell = self.rank_cell_list[cell]
	if nil == item_cell then
		item_cell = RankListItemRenderer.New(cell.gameObject)
		-- item_cell:SetClickCallBack(BindTool.Bind(self.OnClickRankItemCell, self))
		self.rank_cell_list[cell] = item_cell
	end

	local data = self.rank_list_data[cell_index + 1] or {}
	item_cell:SetIndex(cell_index)
	item_cell:SetData(data)
end


function KuaFuBorderlandView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if "flush_rank" == k then
			if self.flush_to_rank_list then
				self.node_list["TaskButton"].toggle.isOn = false
				self.node_list["BossButton"].toggle.isOn = false
				self.node_list["RankButton"].toggle.isOn = true
				self.flush_to_rank_list = false
			end

			if self.count_down_reset_flag_time then
				CountDown.Instance:RemoveCountDown(self.count_down_reset_flag_time)
				self.count_down_reset_flag_time = nil
			end
			self.count_down_reset_flag_time = CountDown.Instance:AddCountDown(
				5, 5, function ()
					if self.count_down_reset_flag_time then
						CountDown.Instance:RemoveCountDown(self.count_down_reset_flag_time)
						self.count_down_reset_flag_time = nil
					end
					self.flush_to_rank_list = true
				end)

			self.rank_list_data = KuaFuBorderlandData.Instance:GetKFBorderlandRankList()
			if self.node_list["RankList"] and self.node_list["RankList"].scroller.isActiveAndEnabled then
				self.node_list["RankList"].scroller:RefreshAndReloadActiveCellViews(true)
			end
		elseif "first_flush_rank" == k then
			self.rank_list_data = KuaFuBorderlandData.Instance:GetKFBorderlandRankList()
			if self.node_list["RankList"] and self.node_list["RankList"].scroller.isActiveAndEnabled then
				self.node_list["RankList"].scroller:RefreshAndReloadActiveCellViews(true)
			end			
		end
	end


	local fb_info = KuaFuBorderlandData.Instance:GetKFBorderlandInfo()
	if nil == fb_info or nil == next(fb_info) then
		return
	end

	--限时奖励时间
	local tmp_time = math.floor(fb_info.limit_task_time - TimeCtrl.Instance:GetServerTime())
	self.time_count = tmp_time

	self.task_list_data = KuaFuBorderlandData.Instance:GetKFBorderlandTaskInfo()
	if self.node_list["TaskList"] and self.node_list["TaskList"].scroller.isActiveAndEnabled then
		self.node_list["TaskList"].scroller:RefreshAndReloadActiveCellViews(true)
	end

	self.boss_list_data = KuaFuBorderlandData.Instance:GetActBossList()
	if self.node_list["BossList"] and self.node_list["BossList"].scroller.isActiveAndEnabled then
		self.node_list["BossList"].scroller:RefreshAndReloadActiveCellViews(true)
	end

	local rank_info = KuaFuBorderlandData.Instance:GetRankInfo()
	if rank_info and next(rank_info) then
		local my_rank_index = rank_info.own_guild_rank + 1
		if my_rank_index > 0 then
			if my_rank_index <= 3 then
				local bundle, asset = ResPath.GetKFBorderland("rank_" .. my_rank_index)
				self.node_list["MyImg_rank"].image:LoadSprite(bundle, asset)
				self.node_list["MyImg_rank"]:SetActive(true)
				self.node_list["MyRank"].text.text = ""
			else
				self.node_list["MyImg_rank"]:SetActive(false)
				self.node_list["MyRank"].text.text = my_rank_index
			end
		else
			self.node_list["MyImg_rank"]:SetActive(false)
			self.node_list["MyRank"].text.text = Language.KFBorderland.NoRank
		end
		self.node_list["MyGuildName"].text.text = GameVoManager.Instance:GetMainRoleVo().guild_name or ""
		self.node_list["MyDamage"].text.text = CommonDataManager.ConverMoney(rank_info.own_guild_hurt)
	else
		self.node_list["MyRank"].text.text = Language.KFBorderland.NoRank
		self.node_list["MyGuildName"].text.text = GameVoManager.Instance:GetMainRoleVo().guild_name or ""
		self.node_list["MyDamage"].text.text = 0
	end

	local reflush_boss_time = KuaFuBorderlandData.Instance:GetBossReflushTime()
	local left_time = math.floor(reflush_boss_time - TimeCtrl.Instance:GetServerTime())
	if left_time > 0 and nil == self.flush_to_boss_toggle_timer then
		self.flush_to_boss_toggle_timer = CountDown.Instance:AddCountDown(
			left_time, 1, function (elapse_time, total_time)
				if elapse_time >= total_time then
					self:CancelFlushToBossListTime()
					self.node_list["RankButton"].toggle.isOn = false
					self.node_list["TaskButton"].toggle.isOn = false
					self.node_list["BossButton"].toggle.isOn = true
				end
			end)
	end
end

function KuaFuBorderlandView:TaskClick(task_id, is_auto)
	local data = self:GetTaskDataByID(task_id)
	-- GuajiCtrl.Instance:StopGuaji()
	if data == nil or data.is_finish or (self.auto_task_id == task_id and not is_auto) then
		self:StopAutoTask()
		self.auto_task_id = task_id
			if self.node_list["TaskList"].scroller.isActiveAndEnabled then
				self.node_list["TaskList"].scroller:RefreshAndReloadActiveCellViews(true)
			end
		return
	end
	self.auto_task_id = task_id
	for k, v in pairs(self.task_cell_list) do
		v:SetHighLight(v:GetData().cfg.task_id == self.auto_task_id)
	end
	KuaFuBorderlandData.Instance:NotifyTaskProcessChange(task_id, function ( ... )
		 GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.AutoDoTask,self), 0.1)
	end)
	self:AutoDoTask()
	if self.node_list["TaskList"].scroller.isActiveAndEnabled then
		self.node_list["TaskList"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function KuaFuBorderlandView:AutoDoTask()
	local data = self:GetTaskDataByID(self.auto_task_id)

	if data == nil or data.is_finish then
		GuajiCtrl.Instance:StopGuaji()
		self.auto_task_id = nil
		local task_info = KuaFuBorderlandData.Instance:GetKFBorderlandTaskInfo()
		if task_info then
			for k, v in pairs(task_info) do
				if not v.is_finish and v.cfg.task_type <= 2 then
					self.auto_task_id = v.cfg.task_id
					break
				end
			end
		end
		if self.auto_task_id then
			self:TaskClick(self.auto_task_id, true)
		else
			KuaFuBorderlandView.GatherId = 0
			GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
			KuaFuBorderlandData.Instance:UnNotifyTaskProcessChange()
			self:ClearToggle()
		end
		return
	end
	local scene_id = Scene.Instance:GetSceneId()
	local list = nil
	local end_type = nil
	local target = nil

	if data.cfg.task_type == 1 then
		--采集
		GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
		end_type = MoveEndType.GatherById
		list = ConfigManager.Instance:GetSceneConfig(scene_id).gathers
		target = Scene.Instance:SelectMinDisGather(data.cfg.param_id)
		KuaFuBorderlandView.GatherId = data.cfg.param_id
	elseif data.cfg.task_type == 2 then
		--打怪
		list = ConfigManager.Instance:GetSceneConfig(scene_id).monsters
		end_type = MoveEndType.Auto
		target = Scene.Instance:SelectMinDisMonster(data.cfg.param_id)
		KuaFuBorderlandView.GatherId = 0
	elseif data.cfg.task_type == 4 then
		-- 打BOSS
		KuaFuBorderlandView.GatherId = 0
		local is_have_boss = false
		for k, v in pairs(self.boss_list_data) do
			if 1 == v.boss_live_flag then
				is_have_boss = true
				GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
				MoveCache.end_type = MoveEndType.Auto
				GuajiCtrl.Instance:MoveToPos(CROSS_BINGJINGZHIDI_DEF.MAP_ID, v.born_pos_x, v.born_pos_y, 0, 0)
			end
		end
		if not is_have_boss then
			TipsCtrl.Instance:ShowSystemMsg(Language.KFBorderland.NoBoss)
		end
		return
	else
		return
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

function KuaFuBorderlandView:GetTaskDataByID(task_id)
	local data = nil
	local s_data = KuaFuBorderlandData.Instance:GetKFBorderlandTaskInfo()
	for k,v in pairs(s_data) do
		if v.cfg.task_id == task_id then
			return v
		end
	end
end

function KuaFuBorderlandView:StopAutoTask()
	KuaFuBorderlandData.Instance:UnNotifyTaskProcessChange()
	self.auto_task_id = nil
end


--寻路至BOSS
function KuaFuBorderlandView:BOSSClick(pos_x, pos_y, boss_id)
	local boss_x, boss_y, boss_id = KuaFuBorderlandData.Instance:GetBOSSInfo()
	local boss_info = KuaFuBorderlandData.Instance:GetWangLingExploreBossInfo()
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











----------------------
-------任务Item
TaskListItemRenderer = TaskListItemRenderer or BaseClass(BaseCell)
function TaskListItemRenderer:__init()
	self.reward_cell = ItemCell.New()
	self.reward_cell:SetInstanceParent(self.node_list["RewardItem"])

	self.root_node.button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function TaskListItemRenderer:__delete()
	if self.reward_cell then
		self.reward_cell:DeleteMe()
		self.reward_cell = nil
	end
	self:CancleCountDownTimer()
end

function TaskListItemRenderer:OnFlush()
	if nil == self.data or nil == next(self.data) then return end

	self.reward_cell:SetData(self.data.cfg.reward_item[0])
	self.reward_cell:SetNumScale(2)

	-- local str = self.data.cfg.task_type == 1 and Language.TombExplore.CHAIJI or Language.TombExplore.Kill
	local str = ""
	local is_finish = self.data.is_finish
	if not is_finish then
		self.node_list["TaskDesc"].text.text = "<color=#ffffff>" .. str .. "</color>" .. self.data.target_text
	else
		-- self.node_list["TaskDesc"].text.text = str..self.data.cfg.task_name
		self.node_list["TaskDesc"].text.text = self.data.cfg.task_desc
	end

	self.node_list["TaskName"].text.text = self.data.cfg.task_name
	self.node_list["ImgFinish"]:SetActive(is_finish)

	if self.data.is_double_reward then
		local fb_info = KuaFuBorderlandData.Instance:GetKFBorderlandInfo()
		--限时奖励时间
		self.flush_time = fb_info.limit_task_time
		local tmp_time = math.floor(fb_info.limit_task_time - TimeCtrl.Instance:GetServerTime())
		if tmp_time > 0 then
			self:OnTimeUpdate()
			if nil == self.time_coundown then
				self.time_coundown = GlobalTimerQuest:AddTimesTimer(
						BindTool.Bind(self.OnTimeUpdate, self), 1, tmp_time)
			end
		else
			self.node_list["DoubleRewardText"]:SetActive(false)
		end
	else
		self:CancleCountDownTimer()
		self.node_list["DoubleRewardText"]:SetActive(false)
	end
end

function TaskListItemRenderer:SetHighLight(is_hl)
	if self.node_list["HLight"] then
		self.node_list["HLight"]:SetActive(is_hl)
	end
end

function TaskListItemRenderer:OnTimeUpdate()
	if nil == self.time_coundown then return end
	local time = math.max(0, self.flush_time - TimeCtrl.Instance:GetServerTime())
	if time <= 0 then
		time = ""
		self.node_list["DoubleRewardText"].text.text = time
		self:CancleCountDownTimer()
	elseif self.data.is_double_reward then
		self.node_list["DoubleRewardText"]:SetActive(not self.data.is_finish)
		time = string.format(Language.TombExplore.TimeDouble,TimeUtil.FormatSecond(time, 2))
		self.node_list["DoubleRewardText"].text.text = time
	end
end

function TaskListItemRenderer:CancleCountDownTimer()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end






----------------------
-------BossItem
BossListItemRenderer = BossListItemRenderer or BaseClass(BaseCell)
function BossListItemRenderer:__init()

	self.root_node.button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function BossListItemRenderer:__delete()
	self:CancleCountDownTimer()
end

function BossListItemRenderer:OnFlush()
	if nil == self.data or nil == next(self.data) then return end
	local boss_info = BossData.Instance:GetMonsterInfo(self.data.boss_id)
	self.node_list["Name"].text.text = boss_info.name
	self.node_list["Level"].text.text = string.format(Language.Mainui.Level, boss_info.level)
	self.node_list["Desc"].text.text = string.format(Language.KFBorderland.PosDesc, self.data.born_pos_x, self.data.born_pos_y)

	if 1 == self.data.boss_live_flag then
		self.node_list["CanKill"]:SetActive(true)
		self.node_list["Time"]:SetActive(false)
		self:CancleCountDownTimer()
	else
		self.node_list["CanKill"]:SetActive(false)
		self.node_list["Time"]:SetActive(true)
		local reflush_boss_time = KuaFuBorderlandData.Instance:GetBossReflushTime()
		self.flush_time = reflush_boss_time
		local tmp_time = reflush_boss_time - TimeCtrl.Instance:GetServerTime()

		if tmp_time > 0 then
			if nil == self.time_coundown then
				self.time_coundown = GlobalTimerQuest:AddTimesTimer(
						BindTool.Bind(self.BossReflushUpdate, self), 1, tmp_time)
			end
			self:BossReflushUpdate()
		else
			self:CancleCountDownTimer()
			self.node_list["CanKill"]:SetActive(false)
			self.node_list["Time"]:SetActive(false)
		end
	end

	if self.data.is_false then
		self.data.level = self.data.level or ""
		self.node_list["Level"].text.text = string.format(Language.Mainui.Level, self.data.level)
	end
end

function BossListItemRenderer:BossReflushUpdate()
	if nil == self.time_coundown then return end
	local time = math.max(0, self.flush_time - TimeCtrl.Instance:GetServerTime())
	if time <= 0 then
		self:CancleCountDownTimer()
		self.node_list["CanKill"]:SetActive(true)
		self.node_list["Time"]:SetActive(false)
	else
		self.node_list["Time"].text.text = TimeUtil.FormatSecond(time, 2)
	end
end

function BossListItemRenderer:CancleCountDownTimer()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function BossListItemRenderer:SetHighLight(is_hl)
	if self.node_list["HighLight"] then
		self.node_list["HighLight"]:SetActive(is_hl)
	end
end










----------------------
-------排行Item
RankListItemRenderer = RankListItemRenderer or BaseClass(BaseCell)
function RankListItemRenderer:__init()

end

function RankListItemRenderer:__delete()

end

function RankListItemRenderer:OnFlush()
	if nil == self.data or nil == next(self.data) then return end

	self.node_list["name"].text.text = self.data.guild_name
	self.node_list["score"].text.text = CommonDataManager.ConverMoney(self.data.hurt)

	local rank_index = self.index + 1
	if rank_index <= 3 then
		local bundle, asset = ResPath.GetKFBorderland("rank_" .. rank_index)
		self.node_list["Img_rank"].image:LoadSprite(bundle, asset, function()

			end)
		self.node_list["Img_rank"]:SetActive(true)
		self.node_list["rank"].text.text = ""
	else
		self.node_list["Img_rank"]:SetActive(false)
		self.node_list["rank"].text.text = rank_index
	end
end



------------------------------
-----------队伍TeamBtn
KFBorderlandTeamBtn = KFBorderlandTeamBtn or BaseClass(BaseRender)

local ZhaoJiSkillTime = 5
function KFBorderlandTeamBtn:__init()
	self.node_list["BtnTeam"].button:AddClickListener(BindTool.Bind(self.OpenTeamView, self))
	self.node_list["BtnZhaoji"].button:AddClickListener(BindTool.Bind(self.OpenZhaojiView, self))

	self.node_list["TeamCDMask"].image.fillAmount = 0
	self.is_can_zhanji = true
end

function KFBorderlandTeamBtn:__delete()
	self.is_can_zhanji = true

	if self.zhaoji_skill_timer then
		CountDown.Instance:RemoveCountDown(self.zhaoji_skill_timer)
		self.zhaoji_skill_timer = nil
	end
end

function KFBorderlandTeamBtn:OpenTeamView()
	self.node_list["TisFrame"]:SetActive(false)
	self.node_list["TeamEff"]:SetActive(false)
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
end

function KFBorderlandTeamBtn:OpenZhaojiView()
	self.zhaoji_skill_timer = CountDown.Instance:AddCountDown(
		ZhaoJiSkillTime, 0.1, function (elapse_time, total_time)
			if elapse_time >= total_time then
				if self.zhaoji_skill_timer then
					CountDown.Instance:RemoveCountDown(self.zhaoji_skill_timer)
					self.zhaoji_skill_timer = nil
					self.is_can_zhanji = true
				end
			end
			self.node_list["TeamCDMask"].image.fillAmount = ((total_time - elapse_time) / total_time)
		end)

	if self.is_can_zhanji then
		-- KuaFuBorderlandCtrl.Instance:OpenKFBorderlandZhaojiView()
		GuildCtrl.Instance:SendSendGuildSosReq(GUILD_SOS_TYPE.GUILD_SOS_TYPE_CROSS_BIANJINGZHIDI)
		self.is_can_zhanji = false
	end
end