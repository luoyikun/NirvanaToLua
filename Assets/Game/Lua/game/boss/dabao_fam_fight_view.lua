require("game/boss/boss_family_fight_view")
DabaoFamFightView = DabaoFamFightView or BaseClass(BaseView)

local DISABLE_TIME = 30
function DabaoFamFightView:__init()
	self.ui_config = {{"uis/views/bossview_prefab", "DabaoFamFightView"}}
	self.active_close = false
	self.fight_info_view = true
	self.is_safe_area_adapter = true
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.item_t = {}
	self.cur_index = 0
	self.dabao_info_event = BindTool.Bind(self.OnFlush, self)
end

function DabaoFamFightView:ReleaseCallBack()
	if BossData.Instance then
		BossData.Instance:RemoveListener(BossData.DABAO_BOSS, self.dabao_info_event)
	end
	if self.show_mode_list_event ~= nil then
		GlobalEventSystem:UnBind(self.show_mode_list_event)
		self.show_mode_list_event = nil
	end
	if self.menu_toggle_event then
		GlobalEventSystem:UnBind(self.menu_toggle_event)
	end

	for k,v in pairs(self.item_t) do
		v:DeleteMe()
	end
	self.item_t = {}

	if self.team_panel then
		self.team_panel:DeleteMe()
		self.team_panel = nil
	end

	if self.tiptime_cut_down then
		GlobalTimerQuest:CancelQuest(self.tiptime_cut_down)
		self.tiptime_cut_down = nil
	end

	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function DabaoFamFightView:LoadCallBack()
	BossData.Instance:AddListener(BossData.DABAO_BOSS, self.dabao_info_event)
	self.node_list["BtnTeam"].toggle.onValueChanged:AddListener(BindTool.Bind(self.BossClick, self))
	self.team_panel = BossDaBaoTeamInfo.New(self.node_list["TeamContent"])

	local list_delegate = self.node_list["TaskList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)

	self.node_list["Text_tip"].text.text = Language.Boss.MaxAnger
	local fun = function()
		self.node_list["Img_text_frame"]:SetActive(false)
	end

	local info = BossData.Instance:GetCurBossInfo(BOSS_ENTER_TYPE.TYPE_BOSS_DABAO)
	if info then
		local callback = function()
			MoveCache.end_type = MoveEndType.Auto
			GuajiCtrl.Instance:MoveToPos(info.scene_id, info.born_x, info.born_y, 10, 10)
		end
		callback()
		GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
	end

	if info then
		local list = self:GetDataList()
		if list then
			for k,v in pairs(list) do
				if info.bossID == v.bossID then
					self.cur_index = k
					self.select_boss_id = v.bossID
				end
			end
		end
	end

	self.tiptime_cut_down = GlobalTimerQuest:AddDelayTimer(fun, DISABLE_TIME)
	self.menu_toggle_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,BindTool.Bind(self.PortraitToggleChange, self))
	self:Flush("team_type")
end

function DabaoFamFightView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if value then
		self:Flush()
	end
end

function DabaoFamFightView:BossClick(is_click)
	if is_click then
		self:Flush()
	end
end

function DabaoFamFightView:CloseCallBack()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end

	for k,v in pairs(self.item_t) do
		v:DeleteMe()
	end
	self.item_t = {}
end

function DabaoFamFightView:OpenCallBack()
	GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)

	if self.node_list["TaskList"] and self.node_list["TaskList"].scroller then
		self.node_list["TaskList"].scroller:ReloadData(0)
	end
end

function DabaoFamFightView:PortraitToggleChange(state)
	if state then
		self:Flush()
	end
	self.node_list["PanelInfo"]:SetActive(state)
	self.node_list["DamagePerson"]:SetActive(state)
end

function DabaoFamFightView:OnFlush(param_t)
	local boss_data = BossData.Instance
	local max_val = boss_data:GetDabaoMaxValue()
	local angry_val = boss_data:GetDabaoBossInfo()
	angry_val = angry_val >= max_val and max_val or angry_val
	self.node_list["TxtAngry"].text.text = string.format(Language.Boss.ActiveFamAnger, angry_val .. "/".. max_val)
	self.node_list["SliderProgressBG"].slider.value = angry_val/max_val
	if self.node_list["TaskList"].scroller.isActiveAndEnabled then
		if self.cur_index > 1 and not self.has_flush then
			self.has_flush = true
			self.node_list["TaskList"].scroller:ReloadData(self.cur_index / (#self:GetDataList() or 0))
		else
			self.node_list["TaskList"].scroller:RefreshAndReloadActiveCellViews(true)
		end
	end

	if nil ~= param_t then
		for k,v in pairs(param_t) do
			if k == "team_type" then
				self.team_panel:Flush()
			end
		end
	end

	local kick_time = BossData.Instance:GetDaBaoKickTime()
	local time = kick_time - TimeCtrl.Instance:GetServerTime()

	if self.time_coundown ~= nil then
		if self.time_coundown then
			GlobalTimerQuest:CancelQuest(self.time_coundown)
			self.time_coundown = nil
		end
	end

	if time > 0 and self.time_coundown == nil then
		self.time_coundown = GlobalTimerQuest:AddTimesTimer(
			BindTool.Bind(self.OnBossUpdate, self), 1, time)
		self:OnBossUpdate()
	end
end

function DabaoFamFightView:OnBossUpdate()
	local kick_time = BossData.Instance:GetDaBaoKickTime()
	local time = math.max(0, kick_time - TimeCtrl.Instance:GetServerTime())
	if time > 0 then
		time = math.floor(time)
		if self.node_list and self.node_list["TxtTime"] then
			self.node_list["TxtTime"].text.text = string.format(Language.Boss.BabyBossFightViewCountDown, time)
		end
	else
		GlobalTimerQuest:CancelQuest(self.time_coundown)
	end
end

function DabaoFamFightView:BagGetNumberOfCells()
	local data_list = self:GetDataList() or {}
	return #data_list
end

function DabaoFamFightView:BagRefreshCell(cell, data_index, cell_index)
	local item = self.item_t[cell]
	if nil == item then
		item = DaBaoBossItem.New(cell.gameObject, self)
		self.item_t[cell] = item
	end

	local data_list = self:GetDataList() or {}
	if data_list[cell_index + 1] then
		item:SetData(data_list[cell_index + 1])
	end
	item:SetItemIndex(cell_index + 1)
	item:FlushHl()
end

function DabaoFamFightView:GetDataList()
	local scene_id = Scene.Instance:GetSceneId()
	return BossData.Instance:GetDaBaoBossList(scene_id)
end

function DabaoFamFightView:GetCurIndex()
	return self.cur_index
end

function DabaoFamFightView:GetCurBossId()
	return self.select_boss_id
end

function DabaoFamFightView:SetCurIndex(index)
	self.cur_index = index
end

function DabaoFamFightView:SetCurBossId(boss_id)
	self.select_boss_id = boss_id
end

function DabaoFamFightView:FlushAllHl()
	for k,v in pairs(self.item_t) do
		v:FlushHl()
	end
end
----------------------------打宝bossItem
DaBaoBossItem = DaBaoBossItem or BaseClass(BaseRender)

function DaBaoBossItem:__init(instance, parent)
	self.parent = parent
	self.time = ""
	self.time_color = "#32d45eff"
	self.index = 0
	self.next_refresh_time = 0
	self.node_list["BossFamilyItem"].button:AddClickListener(BindTool.Bind(self.ClickKill, self))
end

function DaBaoBossItem:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
	self.parent = nil
end

function DaBaoBossItem:ClickKill(is_click)
	if self.data == nil then return end
	self.parent:SetCurIndex(self.index)
	self.parent:SetCurBossId(self.data.bossID)
	MoveCache.end_type = MoveEndType.Auto
	GuajiCtrl.Instance:MoveToPos(self.data.scene_id, self.data.born_x, self.data.born_y, 0, 0)
	self.parent:FlushAllHl()
	return
end

function DaBaoBossItem:SetData(data)
	self.data = data
	self:Flush()
end

function DaBaoBossItem:GetBossData(boss_id)
	local scene_id = Scene.Instance:GetSceneId()
	local boss_info = BossData.Instance:GetDaBaoBossList(scene_id)
	for k,v in pairs(boss_info) do
		if v.bossID == boss_id then
			return v
		end
	end
end

function DaBaoBossItem:SetItemIndex(index)
	self.index = index
end

function DaBaoBossItem:Flush()
	if nil == self.data then
		self.root_node:SetActive(false)
		return
	else
		self.root_node:SetActive(true)
	end
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.bossID]
	if monster_cfg then
		self.node_list["TxtName"].text.text = monster_cfg.name
		self.node_list["TextLevel"].text.text = string.format("Lv.%s", monster_cfg.level)
	end

	local boss_data = self:GetBossData(self.data.bossID)
	if boss_data then
		self.flush_time = BossData.Instance:GetDaBaoStatusByBossId(self.data.bossID, self.data.scene_id)
		self.time_color = self.flush_time <= 0 and TEXT_COLOR.GREEN or TEXT_COLOR.RED
		self.node_list["TxtTime"].text.text = ToColorStr(self.time, self.time_color)
		if self.flush_time <= 0 then
			self.time = Language.Boss.CanKill
			self.node_list["TxtTime"].text.text = ToColorStr(self.time, self.time_color)
		else
			self.time_coundown = GlobalTimerQuest:AddTimesTimer(
				BindTool.Bind(self.OnBossUpdate, self), 1, self.flush_time - TimeCtrl.Instance:GetServerTime())
			self:OnBossUpdate()
		end
	end

	local angry_des = string.format(Language.Boss.BabyMonsterAngryValue, self.data.kill_boss_value)
	self.node_list["Desc"].text.text = angry_des
	self:FlushHl()
end

function DaBaoBossItem:FlushHl()
	if self.node_list["ImgHL"] then
		self.node_list["ImgHL"]:SetActive(self.parent:GetCurBossId() == self.data.bossID)
	end
end

function DaBaoBossItem:OnBossUpdate()
	if nil == self.time_coundown then return end
	local time = math.max(0, self.flush_time - TimeCtrl.Instance:GetServerTime())
	if time > 0 then
		self.time = TimeUtil.FormatSecond(time)
		self.node_list["TxtTime"].text.text = ToColorStr(self.time, self.time_color)
	end
end

BossDaBaoTeamInfo = BossDaBaoTeamInfo or BaseClass(BaseRender)
function BossDaBaoTeamInfo:__init()
	self.team_cells = {}
	self.team_list = {}

	self.node_list["BtnExitButton"].button:AddClickListener(BindTool.Bind(self.ExitClick, self))
	self.node_list["BtnOpenTeam"].button:AddClickListener(BindTool.Bind(self.OpenTeam, self))
	self.node_list["ButtonCreateTeam"].button:AddClickListener(BindTool.Bind(self.CreateTeam, self))

	self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER,
		BindTool.Bind(self.OnChangeScene, self))

	self.contain_cell_list = {}
	local list_delegate = self.node_list["list_view"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function BossDaBaoTeamInfo:__delete()
	self.add_exp_text = nil
	self.show_add_exp = nil
	self.show_exit_btn = nil
	self.show_create_team = nil

	self.team_cells = {}
	self.star_gray_list = {}

	if self.scene_load_enter then
		GlobalEventSystem:UnBind(self.scene_load_enter)
		self.scene_load_enter = nil
	end

	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}
end

function BossDaBaoTeamInfo:GetNumberOfCells()
	return #self.team_list
end

function BossDaBaoTeamInfo:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = BossDaBaoTeamCell.New(cell.gameObject, self)
		contain_cell.parent = self
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	contain_cell:SetIndex(cell_index)
	contain_cell:SetData(self.team_list[cell_index])
end

function BossDaBaoTeamInfo:OnChangeScene()
	self:Flush()
end

function BossDaBaoTeamInfo:ExitClick()
	ScoietyCtrl.Instance:ExitTeamReq()
end

function BossDaBaoTeamInfo:OpenTeam()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
end

function BossDaBaoTeamInfo:CreateTeam()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
	local param_t = {}
	param_t.must_check = 0
	param_t.assign_mode = 1
	ScoietyCtrl.Instance:CreateTeamReq(param_t, true)
end

function BossDaBaoTeamInfo:OnFlush()
	self.team_list = ScoietyData.Instance:GetMemberList()
	self.node_list["PanelShowCreat"]:SetActive(not next(self.team_list))
	for i = 1, 3 do
		UI:SetGraphicGrey(self.node_list["ImgGrayPerson" .. i], not (i <= #self.team_list and self.team_list[i].is_online == 1))
	end

	self.node_list["PanelShowPerson"]:SetActive(#self.team_list > 0)
	self.node_list["TxtAddExp"].text.text = string.format("EXP+%s", ScoietyData.Instance:GetTeamExp(self.team_list)) .. "%"

	self.node_list["BtnExitButton"]:SetActive(#self.team_list > 0)
	if self.node_list["list_view"].scroller.isActiveAndEnabled then
		self.node_list["list_view"].scroller:ReloadData(0)
	end
end

function BossDaBaoTeamInfo:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function BossDaBaoTeamInfo:GetSelectIndex()
	return self.select_index or 0
end

function BossDaBaoTeamInfo:FlushAllHl()
	for k,v in pairs(self.contain_cell_list) do
		v:FlushHl(self.select_index)
	end
end

BossDaBaoTeamCell = BossDaBaoTeamCell or BaseClass(BaseCell)
function BossDaBaoTeamCell:__init()

	self.node_list["BossMenberItem"].toggle:AddClickListener(BindTool.Bind(self.ClickItem, self))

end

function BossDaBaoTeamCell:__delete()
	self.role_name = nil
	self.level_text = nil
	self.menber_state = nil
	self.parent = nil
end

function BossDaBaoTeamCell:OnFlush()
	self.root_node.gameObject:SetActive(self.data ~= nil and next(self.data) ~= nil)
	if not self.data or not next(self.data) then return end

	-- local lv1, zhuan1 = PlayerData.GetLevelAndRebirth(self.data.level)
	local member_state = ScoietyData.Instance:GetMemberPosState(self.data.role_id, self.data.scene_id, self.data.is_online)
	self.node_list["TxtName"].text.text = self.data.name
	self.node_list["TxtLevel"].text.text = string.format(Language.Common.ShenGongHuanHuaLevel, PlayerData.GetLevelString(self.data.level))
	self.node_list["TxtState"].text.text = member_state

end

function BossDaBaoTeamCell:ClickItem()
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if main_role_id == self.data.role_id then
		self.node_list["ImgHL"]:SetActive(false)
		return
	end

	self.parent:SetSelectIndex(self.index)
	self.parent:FlushAllHl()

	local function canel_callback()
		if self.root_node then
			self.node_list["ImgHL"]:SetActive(false)
		end
	end

	ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, self.data.name, nil, canel_callback)
end

function BossDaBaoTeamCell:FlushHl(cur_index)
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	self.node_list["ImgHL"]:SetActive(self.data and cur_index == self.index and main_role_id ~= self.data.role_id)
end