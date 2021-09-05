ShangguBossFightView = ShangguBossFightView or BaseClass(BaseView)

local DISABLE_TIME = 30
function ShangguBossFightView:__init()
	self.ui_config = {{"uis/views/bossview_prefab","ShangguBossFightView"}}
	self.active_close = false
	self.fight_info_view = true
	self.cur_monster_id = 0
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.boss_cell_list = {}
	self.elite_cell_list = {}
	self.layer = 0
	self.dabao_info_event = BindTool.Bind(self.Flush, self)
end

function ShangguBossFightView:__delete()

end

function ShangguBossFightView:ReleaseCallBack()
	if self.show_mode_list_event ~= nil then
		GlobalEventSystem:UnBind(self.show_mode_list_event)
		self.show_mode_list_event = nil
	end

	if self.menu_toggle_event then
		GlobalEventSystem:UnBind(self.menu_toggle_event)
	end

	if self.boss_cell_list then
		for _,v in pairs(self.boss_cell_list) do
			if v then
				v:DeleteMe()
			end
		end
		self.boss_cell_list = {}
	end

	if self.elite_cell_list then
		for _,v in pairs(self.elite_cell_list) do
			if v then
				v:DeleteMe()
			end
		end
		self.elite_cell_list = {}
	end

	if self.team_panel then
		self.team_panel:DeleteMe()
		self.team_panel = nil
	end

	self:StopTimeQuest()
	self.is_boss = nil

	if self.tiptime_cut_down then
		GlobalTimerQuest:CancelQuest(self.tiptime_cut_down)
		self.tiptime_cut_down = nil
	end
end

function ShangguBossFightView:LoadCallBack()
	self.node_list["Txt_MaxAnger"].text.text = Language.Boss.MaxAnger
	local fun = function()
		self.node_list["Img_text_frame"]:SetActive(false)
	end
	self.tiptime_cut_down = GlobalTimerQuest:AddDelayTimer(fun, DISABLE_TIME)
	local scene = Scene.Instance:GetSceneId()
	local layer = BossData.Instance:GetCurShanggulayerBysceneid(scene)
	self.layer = layer + 1

	local list_delegate = self.node_list["BossList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumOfBossCell, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshBossCell, self)
	self.team_panel = BossShangguTeamInfo.New(self.node_list["InfoContent"])

	local list_delegate = self.node_list["EliteList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumOfEliteCell, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshEliteCell, self)

	self.menu_toggle_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,BindTool.Bind(self.PortraitToggleChange, self))

	self.node_list["TeamButton"].toggle:AddValueChangedListener(BindTool.Bind(self.OnClickBoss, self))
	self.node_list["Btn_Exchange"].button:AddClickListener(BindTool.Bind(self.OnClickExchange, self))
	self:Flush("team_type")
end

function ShangguBossFightView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if value then
		self:Flush()
	end
end

function ShangguBossFightView:OnClickBoss(is_click)
	if is_click then
		self:Flush()
	end
end

function ShangguBossFightView:OnClickExchange()
	self.is_boss = not self.is_boss
	self.node_list["BossList"]:SetActive(self.is_boss)
	self.node_list["EliteList"]:SetActive(not self.is_boss)
	local task_desc = self.is_boss and Language.Boss.BabyFBBossText or Language.Boss.BabyFBEliteText
	self.node_list["BossText"].text.text = task_desc
	self.node_list["BossText2"].text.text = task_desc
	self:Flush()
end

function ShangguBossFightView:CloseCallBack()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end

end

function ShangguBossFightView:OpenCallBack()
	local scene_id = Scene.Instance:GetSceneId()
	GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)
	BossCtrl.Instance:SendShangGuBossReq(SGBOSS_REQ_TYPE.ALLINFO)   -- 请求上古boss所有信息

	local info = nil
	info = BossData.Instance:GetCurBossInfo(BOSS_ENTER_TYPE.TYPE_BOSS_SHANGGU)
	if info then
		self.cur_monster_id = info.monster_id
	end

	self.is_boss = true
	self.node_list["BossText"].text.text = Language.Boss.BabyFBBossText
	self.node_list["BossText2"].text.text = Language.Boss.BabyFBBossText
end

function ShangguBossFightView:PortraitToggleChange(state)
	if state then
		self:Flush()
	end
	self.node_list["InfoPanel"]:SetActive(state)
end

function ShangguBossFightView:StopTimeQuest()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function ShangguBossFightView:OnFlush(param_t)
	self:StopTimeQuest()

	local max_val = 100			--愤怒值最大值
	local angry_val = BossData.Instance:GetDabaoBossAngryValue()
	angry_val = angry_val >= max_val and max_val or angry_val
	self.node_list["Txt_Anger"].text.text = string.format(Language.Boss.ActiveFamAnger, angry_val .. "/".. max_val)
	self.node_list["Slider_Anger"].slider.value = angry_val / max_val

	if param_t ~= nil then
		for k,v in pairs(param_t) do
			if k == "team_type" then
				self.team_panel:Flush()
			end
		end
	end

	if self.node_list["BossList"].scroller.isActiveAndEnabled then
		self.node_list["BossList"].scroller:RefreshAndReloadActiveCellViews(true)
	end

	if self.node_list["EliteList"].scroller.isActiveAndEnabled then
		self.node_list["EliteList"].scroller:RefreshAndReloadActiveCellViews(true)
	end

	local _, kick_time = BossData.Instance:GetDabaoBossAngryValue()
	if kick_time then
		local time = kick_time - TimeCtrl.Instance:GetServerTime()
		if time > 0 then
			self.time_coundown = GlobalTimerQuest:AddTimesTimer(
				BindTool.Bind(self.OnBossUpdate, self), 1, time)
			self:OnBossUpdate()
		end
	end
end

function ShangguBossFightView:OnBossUpdate()
	local _, kick_time = BossData.Instance:GetDabaoBossAngryValue()
	local time = math.max(0, kick_time - TimeCtrl.Instance:GetServerTime())
	if time > 0 then
		time = math.floor(time)
		self.node_list["Time"].text.text = string.format(Language.Boss.BabyBossFightViewCountDown, time)
	else
		GlobalTimerQuest:CancelQuest(self.time_coundown)
	end
end

function ShangguBossFightView:GetNumOfBossCell()
	-- local data_list = BossData.Instance:GetSGBossListBySceneId(Scene.Instance:GetSceneId())
	local data_list = BossData.Instance:GetShangGuBossList(Scene.Instance:GetSceneId())
	local num = GetListNum(data_list)
	return num
end

function ShangguBossFightView:RefreshBossCell(cell, data_index)
	-- data_index = data_index + 1
	local item = self.boss_cell_list[cell]
	if nil == item then
		item = ShangguBossItem.New(cell.gameObject)
		item.boss_view = self
		self.boss_cell_list[cell] = item
		item:SetClickCallBack(BindTool.Bind(self.OnClickMonsterItem, self))
	end

	-- local data_list = BossData.Instance:GetSGBossListBySceneId(Scene.Instance:GetSceneId())
	local data_list = BossData.Instance:GetShangGuBossList(Scene.Instance:GetSceneId())
	if data_list[data_index] then
		item:SetData(data_list[data_index])
	end
	item:SetIndex(data_index)
	item:FlushHl(self.cur_monster_id)
end

function ShangguBossFightView:GetNumOfEliteCell()
	local data_list = BossData.Instance:GetSGBossJingYingInfoByLayer(self.layer - 1)
	return #data_list
end

function ShangguBossFightView:RefreshEliteCell(cell, data_index)
	data_index = data_index + 1
	local item = self.elite_cell_list[cell]
	if nil == item then
		item = ShangguBossItem.New(cell.gameObject)
		item.boss_view = self
		self.elite_cell_list[cell] = item
		item:SetClickCallBack(BindTool.Bind(self.OnClickMonsterItem, self))
	end

	local data_list = BossData.Instance:GetSGBossJingYingInfoByLayer(self.layer - 1)
	if data_list[data_index] then
		item:SetData(data_list[data_index])
	end
	item:SetIndex(data_index)
	item:FlushHl(self.cur_monster_id)
end

function ShangguBossFightView:OnClickMonsterItem(item)
	if item.data == nil then return end
	if item.data_index == 0 then
		return
	end
	local boss_id = item.data.boss_id or 0
	local scene_id = item.data.scene_id or 0
	self:SetCurMonsterID(boss_id)

	-- 寻怪
	-- GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	-- MoveCache.end_type = MoveEndType.Auto
	MoveCache.param1 = boss_id
	GuajiCache.monster_id = boss_id
	MoveCache.end_type = MoveEndType.FightByMonsterId
	local boss_data = {}
	if self.is_boss then
		for k,v in pairs(self.boss_cell_list) do
			if self.cur_monster_id == v.data.boss_id then
				boss_data = v.data
			end
		end
	else
		for k,v in pairs(self.elite_cell_list) do
			if self.cur_monster_id == v.data.boss_id then
				boss_data = v.data
			end
		end
	end
	GuajiCtrl.Instance:MoveToPos(item.data.scene_id, boss_data.x_pos, boss_data.y_pos, 0, 0)

	self:FlushAllHl()
	return
end

function ShangguBossFightView:GetCurMonsterID()
	return self.cur_monster_id
end

function ShangguBossFightView:SetCurMonsterID(id)
	self.cur_monster_id = id
end

function ShangguBossFightView:FlushAllHl()
	list = self.is_boss and self.boss_cell_list or self.elite_cell_list
	for k,v in pairs(list) do
		v:FlushHl(self.cur_monster_id)
	end
end

--------------------- 上古bossItem ---------------------
ShangguBossItem = ShangguBossItem or BaseClass(BaseCell)

function ShangguBossItem:__init()
	self.index = 0
	self.next_refresh_time = 0
	self.node_list["BtnClick"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function ShangguBossItem:__delete()
	self:StopTimeQuest()
	self.boss_view = nil
end

function ShangguBossItem:SetIndex(index)
	self.index = index
end

function ShangguBossItem:StopTimeQuest()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function ShangguBossItem:FlushHl(select_id)
	if self.data ~= nil then
		self.node_list["HighLight"]:SetActive(select_id == self.data.boss_id)
	end
end

function ShangguBossItem:OnBossUpdate()
	local time = math.max(0, self.flush_time - TimeCtrl.Instance:GetServerTime())
	if time <= 0 then
		self.node_list["Time"].text.text = ToColorStr(Language.Boss.CanKill, TEXT_COLOR.GREEN) 
	else
		self.node_list["Time"].text.text = ToColorStr(TimeUtil.FormatSecond(time), TEXT_COLOR.RED)
	end
end

function ShangguBossItem:Flush()
	self:StopTimeQuest()

	local boss_data = self.data
	if nil == self.data then
		return
	end

	self.node_list["Name"].text.text = boss_data.boss_name
	self.node_list["Level"].text.text = string.format(Language.Boss.Level, boss_data.boss_level)
	self.node_list["Time"].text.text = ""
	local data = {}
	if self.boss_view.is_boss then
		if boss_data.boss_id then 
			data = BossData.Instance:GetBossRefreshInfoByBossId(boss_data.boss_id)
			if data ~= nil then
				self.flush_time = data.next_refresh_time
				if nil == self.flush_time or self.flush_time == 0 then
					self.node_list["Time"].text.text = ToColorStr(Language.Boss.CanKill, TEXT_COLOR.GREEN)
				else
					self.time_coundown = GlobalTimerQuest:AddTimesTimer(
						BindTool.Bind(self.OnBossUpdate, self), 1, self.flush_time - TimeCtrl.Instance:GetServerTime())
					self:OnBossUpdate()
				end
			end
		end
	end

	local hide_boss_num = string.format(Language.Boss.NowHideBossNume, boss_data.num)
	local angry_des = string.format(Language.Boss.BabyMonsterAngryValue, boss_data.kill_add_angry)
	self.node_list["Desc"].text.text = boss_data.kill_add_angry < 0 and hide_boss_num or angry_des
end

BossShangguTeamInfo = BossShangguTeamInfo or BaseClass(BaseRender)
function BossShangguTeamInfo:__init()
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

function BossShangguTeamInfo:__delete()
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

function BossShangguTeamInfo:GetNumberOfCells()
	return #self.team_list
end

function BossShangguTeamInfo:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = ShangguTeamCell.New(cell.gameObject, self)
		contain_cell.parent = self
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	contain_cell:SetIndex(cell_index)
	contain_cell:SetData(self.team_list[cell_index])
end

function BossShangguTeamInfo:OnChangeScene()
	self:Flush()
end

function BossShangguTeamInfo:ExitClick()
	ScoietyCtrl.Instance:ExitTeamReq()
end

function BossShangguTeamInfo:OpenTeam()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
end

function BossShangguTeamInfo:CreateTeam()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
	local param_t = {}
	param_t.must_check = 0
	param_t.assign_mode = 1
	ScoietyCtrl.Instance:CreateTeamReq(param_t, true)
end

function BossShangguTeamInfo:OnFlush()
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

function BossShangguTeamInfo:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function BossShangguTeamInfo:GetSelectIndex()
	return self.select_index or 0
end

function BossShangguTeamInfo:FlushAllHl()
	for k,v in pairs(self.contain_cell_list) do
		v:FlushHl(self.select_index)
	end
end

ShangguTeamCell = ShangguTeamCell or BaseClass(BaseCell)
function ShangguTeamCell:__init()

	self.node_list["BossMenberItem"].toggle:AddClickListener(BindTool.Bind(self.ClickItem, self))

end

function ShangguTeamCell:__delete()
	self.role_name = nil
	self.level_text = nil
	self.menber_state = nil
	self.parent = nil
end

function ShangguTeamCell:OnFlush()
	self.root_node.gameObject:SetActive(self.data ~= nil and next(self.data) ~= nil)
	if not self.data or not next(self.data) then return end

	-- local lv1, zhuan1 = PlayerData.GetLevelAndRebirth(self.data.level)
	local member_state = ScoietyData.Instance:GetMemberPosState(self.data.role_id, self.data.scene_id, self.data.is_online)
	self.node_list["TxtName"].text.text = self.data.name
	self.node_list["TxtLevel"].text.text = string.format(Language.Common.ShenGongHuanHuaLevel, PlayerData.GetLevelString(self.data.level)) 
	self.node_list["TxtState"].text.text = member_state

end

function ShangguTeamCell:ClickItem()
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

function ShangguTeamCell:FlushHl(cur_index)
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	self.node_list["ImgHL"]:SetActive(self.data and cur_index == self.index and main_role_id ~= self.data.role_id)
end