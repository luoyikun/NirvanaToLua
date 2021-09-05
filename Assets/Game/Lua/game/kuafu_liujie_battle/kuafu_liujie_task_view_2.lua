KuafuGuildTaskDailyView = KuafuGuildTaskDailyView or BaseClass(BaseView)
KuafuGuildTaskDailyView.GatherId = 0
function KuafuGuildTaskDailyView:__init()
	self.ui_config = {{"uis/views/kuafuliujie_prefab", "LiuJieSceneView2"}}
	self.active_close = false
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.fight_state_button_handle = nil
	self.is_safe_area_adapter = true						-- IphoneX适配
end

function KuafuGuildTaskDailyView:ReleaseCallBack()
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
	self.cell_list = {}

	for k,v in pairs(self.boss_cell_list) do
		v:DeleteMe()
	end
	self.boss_cell_list = {}
	if self.change_scene then
		GlobalEventSystem:UnBind(self.change_scene)
	end
	self.change_scene  = nil
	self.select_index = nil

	GlobalEventSystem:UnBind(self.fight_state_button_handle)
	self.fight_state_button_handle = nil

	if self.rank_view then
		self.rank_view:DeleteMe()
		self.rank_view = nil
	end
end

function KuafuGuildTaskDailyView:LoadCallBack()
	self:InitScroller()
	self:InitBoss()
	self.node_list["TaskToggle"].toggle.onValueChanged:AddListener(BindTool.Bind(self.TaskToggleChange, self))
	self.node_list["BOSSToggle"].toggle:AddClickListener(BindTool.Bind(self.ClickBossToggle, self))
	self.node_list["TeamButton"].toggle:AddClickListener(BindTool.Bind(self.ClickTeamToggle, self))
	self.rank_view = KuafuGuildRankView.New(self.node_list["ScoreRank"])
	self.auto_task_id = nil
	self.select_index = 0

	self.show_mode_list_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON, BindTool.Bind(self.OnMainUIModeListChange, self))
	self.change_scene = GlobalEventSystem:Bind(SceneEventType.SCENE_ALL_LOAD_COMPLETE, BindTool.Bind1(self.OnSceneChangeComplete, self))
	self.obj_del_event = GlobalEventSystem:Bind(ObjectEventType.OBJ_DELETE,
		BindTool.Bind(self.OnObjDelete, self))
	self.clear_task_toggle = GlobalEventSystem:Bind(
		MainUIEventType.MAINUI_CLEAR_TASK_TOGGLE,
		BindTool.Bind(self.ClearToggle, self))
	self.stop_gather_event = GlobalEventSystem:Bind(ObjectEventType.STOP_GATHER,
		BindTool.Bind(self.OnStopGather, self))
	self.start_gather_event = GlobalEventSystem:Bind(ObjectEventType.START_GATHER,
		BindTool.Bind(self.OnStartGather, self))
	self.node_list["TaskBtn"].button:AddClickListener(BindTool.Bind(self.OnClickTask, self))
	self.fight_state_button_handle = GlobalEventSystem:Bind(MainUIEventType.FIGHT_STATE_BUTTON, BindTool.Bind(self.CheckFightState, self))
end

function KuafuGuildTaskDailyView:CheckFightState(is_on)
	if self.root_node then
		self.root_node:SetActive(not is_on)
	end
end

function KuafuGuildTaskDailyView:OnStopGather()
	self.is_gather = false
	if KuafuGuildTaskDailyView.GatherId > 0 and Scene.Instance:GetMainRole():IsStand() then
		self:AutoDoTask()
	end
end

function KuafuGuildTaskDailyView:SetIsLiuJieBossRange(is_active)
	if nil == self.node_list or self.node_list["TeamButton"] == nil or self.node_list["BOSSToggle"] == nil then
		return
	end
	if self.node_list["TeamButton"].toggle and self.node_list["TeamButton"].toggle.isActiveAndEnabled then
		self.node_list["TeamButton"].toggle.isOn = is_active
	end
	if self.node_list["BOSSToggle"].toggle and self.node_list["BOSSToggle"].toggle.isActiveAndEnabled then
		self.node_list["BOSSToggle"].toggle.isOn = not is_active
	end
	self:Flush()
end

function KuafuGuildTaskDailyView:OnStartGather()
	self.is_gather = true
end

function KuafuGuildTaskDailyView:CloseCallBack()
	KuafuGuildTaskDailyView.GatherId = 0
end

function KuafuGuildTaskDailyView:OpenCallBack()
	self.select_index = 0
	KuafuGuildBattleCtrl.Instance:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_REQ_TASK_INFO)
	KuafuGuildBattleCtrl.Instance:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_BOSS_INFO, 1450)
	self:ChangeToggleState()
end

function KuafuGuildTaskDailyView:TaskToggleChange(isOn)
	if isOn then
		self:Flush()
	end
end

function KuafuGuildTaskDailyView:ClickBossToggle()
	self:Flush()
end

function KuafuGuildTaskDailyView:ClickTeamToggle()
	self:Flush()
end

function KuafuGuildTaskDailyView:ClearToggle()
	if self.auto_task_id then
		local data = self:GetTaskDataByID(self.auto_task_id)
		if data and data.cfg.task_type == 1 or GuajiCache.guaji_type == GuajiType.None then
			self:StopAutoTask()
		end
	end
end

function KuafuGuildTaskDailyView:OnMainUIModeListChange(is_show)
	self.node_list["TombExploreInfoPanel"]:SetActive(is_show)
	-- self.node_list["TomImg"]:SetActive(is_show)
	if is_show then
		self:Flush()
	end
end

function KuafuGuildTaskDailyView:OnSceneChangeComplete()
	local scene_id = Scene.Instance:GetSceneId()
	KuafuGuildBattleCtrl.Instance:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_BOSS_INFO, scene_id)
	self:ChangeToggleState()
end

function KuafuGuildTaskDailyView:ChangeToggleState()
	local enter_type = KuafuGuildBattleData.Instance:GetEnterType()
	if enter_type == LIUJIE_ENTER_TYPE.LIUJIE_ENTER then
		-- self.node_list["TaskImg"]:SetActive(false)
		self.node_list["TaskToggle"].toggle.isOn = true
		self.node_list["Scroller"].gameObject:SetActive(true)
	elseif enter_type == LIUJIE_ENTER_TYPE.BOSS_ENTER then
		-- self.node_list["TaskImg"]:SetActive(false)
		self.node_list["BOSSToggle"].toggle.isOn = true
		self.node_list["TaskList"].gameObject:SetActive(true)
	end
end

function KuafuGuildTaskDailyView:TaskClick(task_id, is_auto)
	local data = self:GetTaskDataByID(task_id)
	GuajiCtrl.Instance:StopGuaji()
	if data == nil or data.statu == 1 or (self.auto_task_id == task_id and not is_auto) then
		self:StopAutoTask()
		return
	end

	self.auto_task_id = task_id
	KuafuGuildBattleData.Instance:NotifyTaskProcessChange(task_id, function()
		GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.AutoDoTask,self), 0.1)
	end)
	self:AutoDoTask()
	self.node_list["Scroller"].scroller:ReloadData(0)
end

function KuafuGuildTaskDailyView:StopAutoTask()
	KuafuGuildBattleData.Instance:UnNotifyTaskProcessChange()
	self.auto_task_id = nil
end

function KuafuGuildTaskDailyView:GetTaskDataByID(task_id)
	local index = KuafuLiuJieSceneId[Scene.Instance:GetSceneId()]
	local data = KuafuGuildBattleData.Instance:GetTaskCfgInfo(index) or {}
	local s_data = data.list or {}
	for k,v in pairs(s_data) do
		if v.cfg.task_id == task_id then
			return v
		end
	end
end

function KuafuGuildTaskDailyView:OnObjDelete(obj)
	if not self.is_gather and obj and obj:IsGather() and obj:GetGatherId() == KuafuGuildTaskDailyView.GatherId then
		GlobalTimerQuest:AddDelayTimer(function ()
			if not self.is_gather then
				self:AutoDoTask()
			end
		end, 0.1)
	end
end

function KuafuGuildTaskDailyView:AutoDoTask()
	local data = self:GetTaskDataByID(self.auto_task_id)

	if data == nil or data.statu == 1 then
		GuajiCtrl.Instance:StopGuaji()
		self.auto_task_id = nil
		local scene_index = KuafuLiuJieSceneId[Scene.Instance:GetSceneId()]
		local task_info = KuafuGuildBattleData.Instance:GetTaskCfgInfo(scene_index).list

		if task_info then
			local info = task_info[1]
			if info then
				if not info.statu == 1 then
					self.auto_task_id = info.cfg.task_id
				end
			end
		end
		if self.auto_task_id then
			self:TaskClick(self.auto_task_id, true)
		else
			KuafuGuildTaskDailyView.GatherId = 0
			GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
			KuafuGuildBattleData.Instance:UnNotifyTaskProcessChange()
			self:ClearToggle()
		end
		return
	end
	local scene_id = Scene.Instance:GetSceneId()
	local list = nil
	local end_type = nil
	local target = nil



	if data.cfg.task_type == 0 then
		--采集
		GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
		end_type = MoveEndType.GatherById
		list = ConfigManager.Instance:GetSceneConfig(scene_id).gathers
		target = Scene.Instance:SelectMinDisGather(data.cfg.task_param)
		KuafuGuildTaskDailyView.GatherId = data.cfg.task_param
	else
		--打怪
		list = ConfigManager.Instance:GetSceneConfig(scene_id).monsters
		end_type = MoveEndType.Auto
		target = Scene.Instance:SelectMinDisMonster(data.cfg.task_param)
		KuafuGuildTaskDailyView.GatherId = 0
	end

	local x, y, id = 0, 0, 0
	if target then
		id = data.cfg.task_param
		x, y = target:GetLogicPos()
	else
		local target_distance = 1000000
		local p_x, p_y = Scene.Instance:GetMainRole():GetLogicPos()
		for k, v in pairs(list) do
			if v.id == data.cfg.task_param  then
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
	GuajiCtrl.Instance:MoveToPos(scene_id, x, y, 2, 1)
end

local is_first_set = true
function KuafuGuildTaskDailyView:OnFlush(param_t)
	-- self.node_list["Scroller"].scroller:ReloadData(0)
	-- self.node_list["TaskList"].scroller:ReloadData(0)

	if self.node_list["Scroller"] and self.node_list["Scroller"].scroller and self.node_list["Scroller"].scroller.isActiveAndEnabled then
		self.node_list["Scroller"].scroller:RefreshAndReloadActiveCellViews(true)
	end

	if self.node_list["TaskList"] and self.node_list["TaskList"].scroller and self.node_list["TaskList"].scroller.isActiveAndEnabled then
		self.node_list["TaskList"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function KuafuGuildTaskDailyView:FlushRankView()
	if self.rank_view then
		self.rank_view:Flush()
	end
end

--滚动条
function KuafuGuildTaskDailyView:InitScroller()
	self.cell_list = {}

	-- 生成数量
	self.node_list["Scroller"].list_simple_delegate.NumberOfCellsDel = function()
		local index =KuafuLiuJieSceneId[Scene.Instance:GetSceneId()]
		if index == nil then 
			return
		end
		return #KuafuGuildBattleData.Instance:GetTaskCfgInfo(index).list
	end
	-- 格子刷新
	self.node_list["Scroller"].list_simple_delegate.CellRefreshDel = function(cell, data_index, cell_index)
		local scene_index = KuafuLiuJieSceneId[Scene.Instance:GetSceneId()]
		if scene_index == nil then 
			return
		end
		local s_data = KuafuGuildBattleData.Instance:GetTaskCfgInfo(scene_index).list
		data_index = data_index + 1
		if self.cell_list[cell] == nil then
			self.cell_list[cell] = KuafuGuidTaskItem.New(cell.gameObject)
			self.cell_list[cell].mother_view =self
			self.cell_list[cell].toggle.group = self.node_list["Scroller"].toggle_group
		end
		local data = s_data[data_index]
		self.cell_list[cell]:SetData(data)
	end
end

function KuafuGuildTaskDailyView:InitBoss()
	self.boss_cell_list = {}

	self.node_list["TaskList"].list_simple_delegate.NumberOfCellsDel = function()
		return #KuafuGuildBattleData.Instance:GetBossList()
	end
	-- 格子刷新
	self.node_list["TaskList"].list_simple_delegate.CellRefreshDel = function(cell, data_index, cell_index)
		local s_data = KuafuGuildBattleData.Instance:GetBossList()
		data_index = data_index + 1
		if self.boss_cell_list[cell] == nil then
			self.boss_cell_list[cell] = BossLiujieItem.New(cell.gameObject,self)
			self.boss_cell_list[cell].mother_view = self
		end
		self.boss_cell_list[cell]:SetItemIndex(self.boss_cell_list[cell])
		local data = s_data[data_index]
		self.boss_cell_list[cell]:SetData(data)
	end
end

function KuafuGuildTaskDailyView:SetSelectIndex(index)
	self.select_index = index
end

function KuafuGuildTaskDailyView:GetSelectIndex(index)
	return self.select_index
end

function KuafuGuildTaskDailyView:FlushCellHl()
	for k,v in pairs(self.boss_cell_list) do
		v:FlushHl()
	end
end

function KuafuGuildTaskDailyView:OnClickTask()
	ViewManager.Instance:Open(ViewName.KuafuTaskRecordView)
end


--滚动条格子------------------------------------------------------
KuafuGuidTaskItem = KuafuGuidTaskItem or BaseClass(BaseRender)
function KuafuGuidTaskItem:__init()
	self.toggle = self.root_node.toggle
	self.node_list["TaskItem"].toggle:AddValueChangedListener(BindTool.Bind(self.OnClick, self))
	self.node_list["IconTirple"]:SetActive(false)
	self.item_cell = nil
end

function KuafuGuidTaskItem:__delete()
	self.mother_view = nil
	if self.item_cell then
		self.item_cell:DeleteMe()
	end
	self.item_cell = nil
end


function KuafuGuidTaskItem:OnClick()
	self.mother_view:TaskClick(self.data.cfg.task_id)
end

function KuafuGuidTaskItem:OnFlush()
	self.node_list["TaskNameTxt"].text.text = self.data.cfg.name
	local str = self.data.cfg.task_content
	local target_text = string.format("(%s/%s)", self.data.record, self.data.cfg.task_count)
	self.node_list["TaskTargetTxt"].text.text = "<color=#ffffff>" .. str .. "</color>" .. target_text

	local reward_item = self.data.cfg.reward_item[0]

	if nil == self.item_cell then
		self.item_cell = ItemCell.New()
		self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	end
	self.item_cell:SetData(reward_item)
	-- self.node_list["IsFinishImg"]:SetActive(self.data.statu == 1)
	if self.data.statu == 1 then
		self.toggle.isOn = false
		self.toggle.interactable = false
		self.node_list["IsFinishImg"]:SetActive(true)
	else
		self.toggle.interactable = true
		self.node_list["IsFinishImg"]:SetActive(false)
	end
	self.node_list["RewardTxt"].text.text = self.data.cfg.reward_credit
	self.toggle.isOn = (self.mother_view.auto_task_id == self.data.cfg.task_id)
		local triple_flag = KuafuGuildBattleData.Instance:GetTripleStatus()
	self.node_list["IconTirple"]:SetActive(triple_flag)
end

function KuafuGuidTaskItem:SetData(data)
	self.data = data
	self:Flush()
end

-----------------------bossliujieitem------------------------
BossLiujieItem = BossLiujieItem or BaseClass(BaseRender)
function BossLiujieItem:__init(instance, parent)
	self.parent = parent
	self.index = 0
	self.next_refresh_time = 0
	self.node_list["BosstItem"].button:AddClickListener(BindTool.Bind(self.ClickKill, self))
end

function BossLiujieItem:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
	self.parent = nil
	self.mother_view = nil
end

function BossLiujieItem:ClickKill(is_click)
	self:ClickKillCallBack(self.pos_x, self.pos_y)
end

function BossLiujieItem:ClickKillCallBack(born_x,born_y)
	if self.data == nil then return end
	self.mother_view:SetSelectIndex(self.index)
	MoveCache.param1 = self.data.replace_boss_id or 0
	GuajiCache.monster_id = self.data.replace_boss_id or 0
	MoveCache.end_type = MoveEndType.FightByMonsterId
	GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), born_x, born_y, 5, 5)

	self.mother_view:FlushCellHl()
end

function BossLiujieItem:SetData(data)
	self.data = data
	if self.data then
		local scene_id = Scene.Instance:GetSceneId()
		local list = KuafuGuildBattleData.Instance:GetBossCfg()
		for k,v in pairs(list) do
			if v.boss_id == self.data.boss_id then
				self:SetPos(v.born_x, v.born_y)
			end
			-- if k == self.data.index then
			-- 	self:SetPos(v.born_x, v.born_y)
			-- end
		end
	end
	self:Flush()
end

function BossLiujieItem:FlushHl()
	self.node_list["ImgHL"]:SetActive(self.index == self.mother_view:GetSelectIndex())
end

function BossLiujieItem:SetItemIndex(index)
	self.index = index
end

function BossLiujieItem:OnFlush()
	if nil == self.data then
		self.root_node:SetActive(false)
		return
	else
		self.root_node:SetActive(true)
	end

	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.replace_boss_id]
	if monster_cfg then
		self.node_list["NameTxt"].text.text = monster_cfg.name
		self.node_list["LevelTxt"].text.text = string.format("Lv.%s", monster_cfg.level)
	end

	local boss_data = self.data
	if boss_data then
		self.flush_time = self.data.next_refresh_time
		self.statu = self.data.status
		if self.flush_time <= 0 or self.statu == 1 then
			self.node_list["TimeTxt"].text.text = ToColorStr(Language.Boss.CanKill, TEXT_COLOR.GREEN)
		else
			if self.time_coundown then
				GlobalTimerQuest:CancelQuest(self.time_coundown)
				self.time_coundown = nil
			end
			self.time_coundown = GlobalTimerQuest:AddTimesTimer(
				BindTool.Bind(self.OnBossUpdate, self), 1, self.flush_time - TimeCtrl.Instance:GetServerTime())
			self:OnBossUpdate()
		end

		local scene_id = Scene.Instance:GetSceneId()
		local config = ConfigManager.Instance:GetSceneConfig(scene_id)
		local pos = string.format("%s(%s,%s)", config.name, self.pos_x, self.pos_y)
		self.node_list["DescTxt"].text.text = pos
	end
	self.node_list["ImgHL"]:SetActive(self.index == self.mother_view:GetSelectIndex())

end


function BossLiujieItem:OnBossUpdate()
	local time = math.max(0, self.flush_time - TimeCtrl.Instance:GetServerTime())
	self.statu = self.data.status
	if time <= 0 or self.statu == 1 then
		self.node_list["TimeTxt"].text.text = ToColorStr(Language.Boss.CanKill, TEXT_COLOR.GREEN)
	else
		if nil == self.node_list then return end
		self.node_list["TimeTxt"].text.text = ToColorStr(TimeUtil.FormatSecond(time), TEXT_COLOR.RED)
	end
end

function BossLiujieItem:SetPos(x, y)
	self.pos_x = x
	self.pos_y = y
end


----------------------排行View----------------------
KuafuGuildRankView = KuafuGuildRankView or BaseClass(BaseRender)
function KuafuGuildRankView:__init()
	-- 获取控件
	self.rank_data_list = {}
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	self.item_t = {}
	self:Flush()
end

function KuafuGuildRankView:__delete()
	for k,v in pairs(self.item_t) do
		v:DeleteMe()
	end
	self.item_t = {}
end

-----------------------------------
-- ListView逻辑
-----------------------------------
function KuafuGuildRankView:BagGetNumberOfCells()
	return math.max(#self.rank_data_list, 5)
end

function KuafuGuildRankView:BagRefreshCell(cell, data_index, cell_index)
	local item = self.item_t[cell]
	if nil == item then
		item = KuafuGuilRankItem.New(cell.gameObject)
		self.item_t[cell] = item
	end
	item:SetIndex(cell_index + 1)
	if self.rank_data_list[cell_index + 1] then
		item:SetData(self.rank_data_list[cell_index + 1])
	else
		item:SetData({name = "--", hurt = 0})
	end
end

function KuafuGuildRankView:OnFlush()
	local info = KuafuGuildBattleData.Instance:GetGuildHurtRankInfo()
	self.node_list["name"].text.text = PlayerData.Instance.role_vo.guild_name
	self.node_list["rank"].text.text = Language.Boss.NotOnRank
	if PlayerData.Instance.role_vo.guild_name == nil then
		self.node_list["rank"]:SetActive(false)
		self.node_list["Img_rank"]:SetActive(false)
		self.node_list["hurt"]:SetActive(false)
	end
	if info == nil or next(info) == nil then
		return
	end

	if info.own_guild_rank > 0 and info.own_guild_rank <= 3 then
		local bundle, asset = ResPath.GetRankIcon(info.own_guild_rank)
		self.node_list["Img_rank"]:SetActive(true)
		self.node_list["rank"]:SetActive(false)
		self.node_list["Img_rank"].image:LoadSprite(bundle, asset)
	else
		self.node_list["rank"].text.text = (info.own_guild_rank > 5 or info.own_guild_rank == 0) and Language.Boss.NotOnRank or info.own_guild_rank
		self.node_list["rank"]:SetActive(true)
		self.node_list["Img_rank"]:SetActive(false)
	end
	self.node_list["hurt"]:SetActive(true)
	self.node_list["hurt"].text.text = CommonDataManager.ConverMoney2(info.own_guild_hurt)
	self.rank_data_list = info.guildhurt_rank_list
	if self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:RefreshActiveCellViews()
	end
end

KuafuGuilRankItem = KuafuGuilRankItem or BaseClass(BaseRender)
function KuafuGuilRankItem:__init()

end

function KuafuGuilRankItem:SetIndex(index)
	self.index = index
end

function KuafuGuilRankItem:SetData(data)
	self.data = data
	self:Flush()
end

function KuafuGuilRankItem:OnFlush()
	if nil == self.data then
		return
	end

	if self.data.guild_name == nil then
		self.node_list["name"]:SetActive(false)
		self.node_list["score"]:SetActive(false)
		self.node_list["Img_rank"]:SetActive(false)
		self.node_list["rank"]:SetActive(false)
	else
		if self.index <= 3 then
			local bundle, asset = ResPath.GetRankIcon(self.index)
			self.node_list["rank"]:SetActive(false)
			self.node_list["Img_rank"]:SetActive(true)
			self.node_list["Img_rank"].image:LoadSprite(bundle, asset)
		else
			self.node_list["Img_rank"]:SetActive(false)
			self.node_list["rank"]:SetActive(true)
			self.node_list["rank"].text.text = self.index
		end
		self.node_list["name"]:SetActive(true)
		self.node_list["score"]:SetActive(true)
	end

	self.node_list["name"].text.text = self.data.guild_name
	self.node_list["score"].text.text = CommonDataManager.ConverMoney2(self.data.hurt)
end