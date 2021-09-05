SecretBossFightView = SecretBossFightView or BaseClass(BaseView)
SecretBossFightView.GatherId = 0

function SecretBossFightView:__init()
	self.ui_config = {{"uis/views/bossview_prefab", "SecretBossFightView"}}
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.active_close = false
	self.fight_info_view = true
end

function SecretBossFightView:ReleaseCallBack()
	self.scroller = nil
	

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

	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end

	for k,v in pairs(self.item_t) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.item_t = {}
	self.show_panel = nil

	self.boss_toggle = nil
	self.list_view.scroller = nil
	self.list_view.list_simple_delegate = nil
	self.list_view = nil
	self.exchange_value = nil
end

function SecretBossFightView:LoadCallBack()
	self.item_t = {}
	self.node_list["BtnFireMine"].button:AddClickListener(BindTool.Bind(self.TeamClick, self))
	self.node_list["BtnTask"].toggle.onValueChanged:AddListener(BindTool.Bind(self.TaskToggleChange, self))
	self.node_list["BtnDuiHuan"].button:AddClickListener(BindTool.Bind(self.ClickExchange, self))
	local list_delegate = self.node_list["TaskList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)

	self.auto_task_id = nil

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
end

function SecretBossFightView:OnStopGather()
	self.is_gather = false
	if SecretBossFightView.GatherId > 0 and Scene.Instance:GetMainRole():IsStand() then
		self:SendInfo(2)
	end
end

function SecretBossFightView:OnStartGather()
	self.is_gather = true
end

function SecretBossFightView:CloseCallBack()
	SecretBossFightView.GatherId = 0
end

function SecretBossFightView:OpenCallBack()
	BossCtrl.Instance:SendPosInfo(1)
end

function SecretBossFightView:TaskToggleChange(isOn)
	if isOn then
		self:Flush()
	end
end

function SecretBossFightView:FlushAllHl()
	for k,v in pairs(self.item_t) do
		v:FlushHl()
	end
end

function SecretBossFightView:SetCurIndex(index)
	self.cur_index = index
end

function SecretBossFightView:GetCurIndex()
	return self.cur_index
end

function SecretBossFightView:BagGetNumberOfCells()
	local data_list = BossData.Instance:GetSecretBossList() or {}
	return #data_list
end

function SecretBossFightView:BagRefreshCell(cell, data_index, cell_index)
	local item = self.item_t[cell]
	if nil == item then
		item = SecretBossRewardItem.New(cell.gameObject, self)
		self.item_t[cell] = item
	end

	local data_list = BossData.Instance:GetSecretBossList() or {}
	if data_list[cell_index + 1] then
		item:SetData(data_list[cell_index + 1])
	end
	item:SetItemIndex(cell_index + 1)
	item:FlushHl()
end

function SecretBossFightView:ClearToggle()
	if self.auto_task_id then
		local data = BossData.Instance:GetTaskDataByID(self.auto_task_id)
		if data.cfg.task_type == 2 or GuajiCache.guaji_type == GuajiType.None then
			self.scroller.toggle_group:SetAllTogglesOff()
			self:StopAutoTask()
		end
	end
end

function SecretBossFightView:OnMainUIModeListChange(is_show)
    if is_show then
        self:Flush()
    end
    self.node_list["PanelInfoView"]:SetActive(is_show)
end

function SecretBossFightView:TaskClick(task_id, is_auto)
	local data = BossData.Instance:GetTaskDataByID(task_id)
	GuajiCtrl.Instance:StopGuaji()
	if data == nil or data.is_finish or (self.auto_task_id == task_id and not is_auto) then
		self:StopAutoTask()
		return
	end

	self.auto_task_id = task_id
	BossData.Instance:NotifyTaskProcessChange(data.cfg.task_type, function ( ... )
		 GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.SendInfo,self), 0.1)
	end)
	self:SendInfo()
	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function SecretBossFightView:SendInfo(param)
	if self.auto_task_id then
		BossCtrl.Instance:SendPosInfo(0,BossData.Instance:GetParamById(self.auto_task_id))
	else
		BossCtrl.Instance:SendPosInfo(0,param)
	end
end

function SecretBossFightView:StopAutoTask()
	BossData.Instance:UnNotifyTaskProcessChange()
	self.auto_task_id = nil
end

function SecretBossFightView:OnObjDelete(obj)
	if not self.is_gather and obj and obj:IsGather() and obj:GetGatherId() == SecretBossFightView.GatherId then
		GlobalTimerQuest:AddDelayTimer(function ()
			if not self.is_gather then
			end
		end, 0.1)
	end
end

function SecretBossFightView:AutoDoTask()
	local data = BossData.Instance:GetTaskDataByID(self.auto_task_id)
	local pos_x, pos_y, param = BossData.Instance:GetCurTargetPos()
	if data == nil or data.is_finish then
		GuajiCtrl.Instance:StopGuaji()
		self.auto_task_id = nil
		local task_info = BossData.Instance:GetTaskInfo()
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
			SecretBossFightView.GatherId = 0
			GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
			BossData.Instance:UnNotifyTaskProcessChange()
			self:ClearToggle()
		end
		return
	end
	local scene_id = Scene.Instance:GetSceneId()
	local list = nil
	local end_type = nil
	local target = nil

	if data.cfg.task_type == 2 then
		--²É¼¯
		GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
		end_type = MoveEndType.GatherById
		target = Scene.Instance:SelectMinDisGather(param)
		SecretBossFightView.GatherId = param
	else
		--´ò¹Ö
		end_type = MoveEndType.Auto
		target = Scene.Instance:SelectMinDisMonster(param)
		SecretBossFightView.GatherId = 0
	end

	local x, y, id = 0, 0, 0
	if target then
		id = param
		x, y = target:GetLogicPos()
	else
		
		local target_distance = 1000000
		local p_x, p_y = Scene.Instance:GetMainRole():GetLogicPos()
		if not AStarFindWay:IsBlock(pos_x, pos_y) then
			local distance = GameMath.GetDistance(p_x, p_y, pos_x, pos_y, false)
			if distance < target_distance then
		 		target_distance = distance
		 		x = pos_x
		 		y =	pos_y
				id = param
		 	end
		end
	end
	MoveCache.end_type = end_type
	MoveCache.param1 = id
	MoveCache.task_id = 0
	GuajiCache.target_obj_id = id
	GuajiCtrl.Instance:MoveToPos(scene_id, x, y, 4, 2)
end

local is_first_set = true
function SecretBossFightView:OnFlush()
	if not self:IsLoaded() then
		return
	end
	if self.scroller and self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end

	if self.node_list["TaskList"] and self.node_list["TaskList"].scroller.isActiveAndEnabled then
		self.node_list["TaskList"].scroller:RefreshAndReloadActiveCellViews(true)
	end

	if BossData.Instance:IsTaskAllDone() and self.node_list["BOSSToggle"].toggle.isActiveAndEnabled then
		if is_first_set then
			is_first_set = false
			self.node_list["BOSSToggle"].toggle.isOn = true
		end
	else
		is_first_set = true
	end
	local count = CommonDataManager.ConverMoney(BossData.Instance:GetSecretValue())
	self.node_list["TxtExchangeValue"].text.text = count
end


function SecretBossFightView:InitScroller()
	self.scroller = self.node_list["Scroller"]
	self.cell_list = {}

	local delegate = self.scroller.list_simple_delegate
	delegate.NumberOfCellsDel = function()
		return #(BossData.Instance:GetTaskInfo())
	end
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		local s_data = BossData.Instance:GetTaskInfo()
		data_index = data_index + 1
		if self.cell_list[cell] == nil then
			self.cell_list[cell] = SecretBossFightItem.New(cell.gameObject)
			self.cell_list[cell].mother_view =self
			self.cell_list[cell].toggle.group = self.scroller.toggle_group
		end
		local data = s_data[data_index]
		data.data_index = data_index
		self.cell_list[cell]:SetData(data)
	end
end

function SecretBossFightView:TeamClick()
	
	ScoietyCtrl.Instance:AutoHaveTeamReq()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
end

function SecretBossFightView:SetMonitorBoss(item)
	if item then
		self.monitor_boss = item
	end
end


function SecretBossFightView:KillBoss(x,y)
	self.monitor_boss:ClickKillCallBack(x,y)
end

function SecretBossFightView:ClickExchange()
	ViewManager.Instance:Open(ViewName.Exchange, TabIndex.exchange_xianjing)
end


---------------------滚动条格子------------------------------------------------------
SecretBossFightItem = SecretBossFightItem or BaseClass(BaseCell)

function SecretBossFightItem:__init()
	self.is_double_reward = false
	self.is_gather = true
	self.is_finish = false
	self.toggle = self.root_node.toggle

	self.node_list["TaskItem"].toggle.onValueChanged:AddListener(BindTool.Bind(self.ToggleChange, self))
	self.node_list["TaskItem"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function SecretBossFightItem:__delete()
	if self.mother_view then
		self.mother_view = nil
	end
end


function SecretBossFightItem:ToggleChange(is_On)

end

function SecretBossFightItem:OnClick()
	self.mother_view:TaskClick(self.data.cfg.task_id)
end

function SecretBossFightItem:OnFlush()
	self.node_list["TxtTitle"].text.text = string.format(Language.Boss.BossFightViewTaskName, self.data.cfg.task_name)

	local str = ""
	self.node_list["TxtTaskTarget"].text.text = string.format("%s", "<color=#ffffff>" .. str .. "</color>" .. self.data.target_text)
	self.node_list["ImgTaskTarget"].text.text = string.format("%s", self.data.reward_target)
	self.is_finish = self.data.is_finish
	self.node_list["TxtDoubleReward"]:SetActive(self.is_double_reward and (not self.is_finish))

	self.toggle.isOn = (self.mother_view.auto_task_id == self.data.cfg.task_id)
end


----------------------------打宝bossItem
SecretBossRewardItem = SecretBossRewardItem or BaseClass(BaseRender)

function SecretBossRewardItem:__init(instance, parent)
	self.parent = parent
	self.time = ""
	self.time_color = "#32d45eff"
	self.index = 0
	self.next_refresh_time = 0

	self.node_list["BossSecretItem"].button:AddClickListener(BindTool.Bind(self.ClickKill, self))
end

function SecretBossRewardItem:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
	self.parent = nil
end

function SecretBossRewardItem:ClickKill(is_click)
	BossCtrl.Instance:KillBoss(true)
	self.parent:SetMonitorBoss(self)
	BossCtrl.Instance:SendPosInfo(0, 0, self.data.monster_id)
end

function SecretBossRewardItem:ClickKillCallBack(born_x,born_y)
	BossCtrl.Instance:KillBoss(false)
	if self.data == nil then return end
	self.parent:SetCurIndex(self.index)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	MoveCache.end_type = MoveEndType.Auto
	GuajiCtrl.Instance:MoveToPos(1250, born_x, born_y, 0, 0)
	self.parent:FlushAllHl()
	return
end

function SecretBossRewardItem:SetData(data)
	self.data = data
	self:Flush()
end


function SecretBossRewardItem:SetItemIndex(index)
	self.index = index
end

function SecretBossRewardItem:Flush()
	if nil == self.data then
		self.root_node:SetActive(false)
		return
	else
		self.root_node:SetActive(true)
	end
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.monster_id]
	if monster_cfg then
		self.node_list["TxtName"].text.text = monster_cfg.name
		self.node_list["TxtLevel"].text.text = string.format("Lv.%s", monster_cfg.level)
	end

	local boss_data = self.data
	if boss_data then
		self.flush_time = BossData.Instance:GetItemStatusById(self.data.monster_id)
		self.time_color = self.flush_time <= 0 and TEXT_COLOR.GREEN_4 or TEXT_COLOR.RED_4
		self.node_list["TxtTime"].text.text = string.format("<color=%s>%s</color>", self.time_color, self.time)
		if self.flush_time <= 0 then
			self.time = Language.Boss.CanKill
			self.node_list["TxtTime"].text.text = string.format("<color=%s>%s</color>", self.time_color, self.time)
		else
			self.time_coundown = GlobalTimerQuest:AddTimesTimer(
				BindTool.Bind(self.OnBossUpdate, self), 1, self.flush_time - TimeCtrl.Instance:GetServerTime())
			self:OnBossUpdate()
		end
		local reward = BossData.Instance:GetRewardById(self.data.monster_id)
		reward = ToColorStr(reward,TEXT_COLOR.GREEN_4)
		self.node_list["TxtDesc"].text.text = string.format(Language.SecretBoss.Reward,reward)
	end
	self:FlushHl()
end

function SecretBossRewardItem:FlushHl()
	if self.node_list["ImgHighLight"] then
		self.node_list["ImgHighLight"]:SetActive(self.parent:GetCurIndex() == self.index)
	end
end

function SecretBossRewardItem:OnBossUpdate()
	local time = math.max(0, self.flush_time - TimeCtrl.Instance:GetServerTime())
	if time <= 0 then
		self.time = ToColorStr(Language.Boss.CanKill, TEXT_COLOR.GREEN_4)
		self.node_list["TxtTime"].text.text = string.format("<color=%s>%s</color>", self.time_color, self.time)
	else
		self.time = ToColorStr(TimeUtil.FormatSecond(time), TEXT_COLOR.RED)
		self.node_list["TxtTime"].text.text = string.format("<color=%s>%s</color>", self.time_color, self.time)
	end
end