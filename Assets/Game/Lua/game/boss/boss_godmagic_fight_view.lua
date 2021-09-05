BossGodMagicFightView = BossGodMagicFightView or BaseClass(BaseView)

function BossGodMagicFightView:__init()
	self.ui_config = {{"uis/views/bossview_prefab", "BossGodMagicFightView"}}
	self.active_close = false
	self.click_flag = false
	self.is_safe_area_adapter = true
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.last_remind_time = 0
end

function BossGodMagicFightView:ReleaseCallBack()
	if self.boss_panel then
		self.boss_panel:DeleteMe()
		self.boss_panel = nil
	end

	if self.team_panel then
		self.team_panel:DeleteMe()
		self.team_panel = nil
	end

	-- 清理变量和对象
	self.show_panel = nil
	self.show_refresh_text = nil
	self.ismax_level = nil
	self.have_left_count = nil
end

function BossGodMagicFightView:LoadCallBack()
	self.boss_panel = BossGodMagicbossView.New(self.node_list["BossPanel"])
	self.team_panel = BossGodMagicTeamInfo.New(self.node_list["TeamPanel"])
	self.show_refresh_text = true
	self.ismax_level = false
	self.have_left_count = false
	self.show_panel = true
	self.node_list["BtnInfo"].toggle:AddClickListener(BindTool.Bind(self.ClickInfo, self))
	self.node_list["boss_btn"].toggle:AddClickListener(BindTool.Bind(self.ClickBoss, self))
	self.node_list["TextWeary"]:SetActive(true)
	ShenYuBossCtrl.Instance:SendGodMagicBossBossInfoReq(GODMAGIC_BOSS_OPERA_TYPE.GODMAGIC_BOSS_OPERA_TYPE_GET_FLUSH_INFO, 0)
	ShenYuBossCtrl.Instance:SendGodMagicBossBossInfoReq(GODMAGIC_BOSS_OPERA_TYPE.GODMAGIC_BOSS_OPERA_TYPE_PLAYER_INFO)
	self:Flush()
end

function BossGodMagicFightView:ClickInfo()
	if self.click_flag == false then
		self.click_flag = true
		self:Flush("team_type")
		self:FlushTabHl(false)
	else
		ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
	end
end

function BossGodMagicFightView:ClickBoss()
	self.click_flag = false
	self.boss_panel:Flush()
	self:FlushTabHl(true)
end

function BossGodMagicFightView:FlushTabHl(show_boss)
	self.node_list["ImgShowBossHL"]:SetActive(show_boss)
	self.node_list["ImgShowTeamHL"]:SetActive(not show_boss)

end

function BossGodMagicFightView:OpenCallBack()
	local boss_data = BossData.Instance
	local info = nil
	info = BossData.Instance:GetCurBossInfo(BOSS_ENTER_TYPE.TYPE_BOSS_GODMAGIC)
	if info then
		local callback = function()
			MoveCache.end_type = MoveEndType.Auto
			GuajiCtrl.Instance:MoveToPos(info.scene_id, info.x_pos, info.y_pos, 10, 10)
		end
		callback()
		GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
	end

	if self.boss_panel and info then
		local list = self.boss_panel:GetDataList()
		if list then
			for k,v in pairs(list) do
				if info.boss_id == v.boss_id then
					self.boss_panel.cur_index = k
					self.boss_panel.select_boss_id = v.boss_id
				end
			end
		end
		self.boss_panel:Flush()
	end

	self:Flush("open_flush")
	self:Flush("team_type")

	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.PortraitToggleChange, self))
	GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)

	-- GlobalTimerQuest:AddDelayTimer(function()
		-- self.boss_panel:JumpToBossList(self.boss_panel.cur_index)
		-- end, 1)
end

function BossGodMagicFightView:CloseCallBack()
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	if self.root_node.gameObject.activeSelf and self.node_list["track_info"].gameObject.activeSelf then
		self.node_list["boss_btn"].toggle.isOn = true
		self:FlushTabHl(true)
	end
	self.click_flag = false
end

function BossGodMagicFightView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if value then
		self:Flush()
	end
end

function BossGodMagicFightView:PortraitToggleChange(state)
	if state == true then
		self:Flush()
	end
	self.show_panel = state
	self.node_list["track_info"]:SetActive(self.show_panel)
end

function BossGodMagicFightView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "boss_type" then
			self.boss_panel:Flush()
		elseif k == "team_type" then
			self.team_panel:Flush()
		elseif k == "open_flush" then
			self.node_list["boss_btn"].toggle.isOn = true
			self:FlushTabHl(true)
		else
			self.boss_panel:Flush()
		end
	end

	local tire_value, max_tire_value = ShenYuBossData.Instance:GetGodMagicBossTire()
	if tire_value <= 0 then
		-- self.node_list["Text_tip"].text.text = Language.Boss.NoWearyTip 
	end
	self.node_list["Text_tip"]:SetActive(tire_value <= 0)
	self.node_list["TextWeary"].text.text = string.format(Language.ShenYuBoss.GodMagicTire, tire_value .. "/" .. max_tire_value)
end

function BossGodMagicFightView:SwitchButtonState(enable)
	if self.shrink_button_toggle and self:IsOpen() then
		self.shrink_button_toggle.isOn = not enable
	end
end

------------------------领主boss----------------------------------
------------------------------------------------------------------
------------------------------------------------------------------
BossGodMagicbossView = BossGodMagicbossView or BaseClass(BaseRender)
function BossGodMagicbossView:__init()
	-- 获取控件
	local list_delegate = self.node_list["TaskList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	self.item_t= {}
	self.cur_index = 0
	self:Flush()
end

function BossGodMagicbossView:__delete()
	for _, v in pairs(self.item_t) do
		v:DeleteMe()
	end

	self.item_t= {}
end

function BossGodMagicbossView:BagGetNumberOfCells()
	local data_list = self:GetDataList() or {}
	return #data_list
end

function BossGodMagicbossView:BagRefreshCell(cell, data_index, cell_index)
	local item = self.item_t[cell]
	if nil == item then
		item = BossGodMagicBossItem.New(cell.gameObject, self)
		self.item_t[cell] = item
	end

	local data_list = self:GetDataList() or {}
	if data_list[cell_index + 1] then
		item:SetData(data_list[cell_index + 1])
	end
	item:SetItemIndex(cell_index + 1)
	item:FlushHl()
end

function BossGodMagicbossView:GetDataList()
	local scene_id = Scene.Instance:GetSceneId()
	return ShenYuBossData.Instance:GetGodMagicLayerBossBySceneID(scene_id)
end

function BossGodMagicbossView:SetCurIndex(index)
	self.cur_index = index
end

function BossGodMagicbossView:GetCurBossId()
	return self.select_boss_id
end

function BossGodMagicbossView:SetCurBossId(boss_id)
	self.select_boss_id = boss_id
end

function BossGodMagicbossView:GetCurIndex()
	return self.cur_index
end

function BossGodMagicbossView:OnFlush()
	if self.node_list["TaskList"].scroller.isActiveAndEnabled then
		if self.cur_index > 1 and not self.has_flush then
				self.node_list["TaskList"].scroller:ReloadData(self.cur_index / (#self:GetDataList() or 0))
				self.has_flush = true
		else
			self.node_list["TaskList"].scroller:RefreshAndReloadActiveCellViews(true)
		end
	end
end

-- function BossGodMagicbossView:JumpToBossList()

-- end

function BossGodMagicbossView:FlushAllHl()
	for k,v in pairs(self.item_t) do
		v:FlushHl()
	end
end

------------------------------------------------------------------------
------------------BossGodMagicBossItem-------------------------------------
------------------------------------------------------------------------
BossGodMagicBossItem = BossGodMagicBossItem or BaseClass(BaseRender)

function BossGodMagicBossItem:__init(instance, parent)
	self.parent = parent

	self.time = ""
	self.time_color = "#32d45eff"
	self.index = 0
	self.next_refresh_time = 0
	self.node_list["BossFamilyItem"].button:AddClickListener(BindTool.Bind(self.ClickKill, self))
end

function BossGodMagicBossItem:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function BossGodMagicBossItem:ClickKill(is_click)
	if self.data == nil then return end
	self.parent:SetCurIndex(self.index)
	self.parent:SetCurBossId(self.data.boss_id)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	MoveCache.end_type = MoveEndType.Auto
	GuajiCtrl.Instance:MoveToPos(self.data.scene_id, self.data.x_pos, self.data.y_pos, 10, 10)
	self.parent:FlushAllHl()
	return
end

function BossGodMagicBossItem:SetData(data)
	self.data = data
	self:Flush()
end

function BossGodMagicBossItem:GetBossData(boss_id)
	local scene_id = Scene.Instance:GetSceneId()
	local boss_info = ShenYuBossData.Instance:GetGodMagicLayerBossBySceneID(scene_id)
	for k,v in pairs(boss_info) do
		if v.boss_id == boss_id then
			return v
		end
	end
end

function BossGodMagicBossItem:SetItemIndex(index)
	self.index = index
end

function BossGodMagicBossItem:Flush()
	if nil == self.data then
		self.root_node:SetActive(false)
		return
	else
		self.root_node:SetActive(true)
	end
	-- self.node_list["Desc"]:SetActive(false)
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.boss_id]
	if monster_cfg then
		self.node_list["TxtName"].text.text = monster_cfg.name
		self.node_list["TextLevel"].text.text = string.format("Lv.%s", monster_cfg.level)
		self.node_list["TextLevel"]:SetActive(true)
		self.node_list["TxtTime"]:SetActive(true)
	end
	self.node_list["special_txt"]:SetActive(false)
	if self.data.type == 2 or self.data.type == 1 then
		local left_num = ShenYuBossData.Instance:GetGodmagicLeftNumInScene(self.data.layer, self.data.type)
		self.flush_time = ShenYuBossData.Instance:GetGodmagicOtherNextFlushTimestamp(self.data.layer, self.data.type)
		-- self.node_list["TxtName"].text.text = self.data.boss_name .. "(" .. tostring(left_num) .. ")"
		self.node_list["TxtName"].text.text = string.format(Language.Boss.KFbossSJName, self.data.boss_name) 
		self.node_list["special_txt"]:SetActive(true)
		self.node_list["TextLevel"]:SetActive(false)
		self.node_list["TxtTime"]:SetActive(false)
		if left_num > 0 then
			self.node_list["special_txt"].text.text = string.format(Language.Boss.KFBOSSSYSJ, left_num)
		else
			self.node_list["special_txt"].text.text = string.format(Language.Boss.KFBOSSSYSJT, left_num)
		end
		
		self.node_list["TextLevel"].text.text = ""
		self.time_color = self.flush_time <= 0 and TEXT_COLOR.GREEN or TEXT_COLOR.RED
		self.node_list["Desc"]:SetActive(self.flush_time > 0)
		self.node_list["Desc"].text.text = string.format(Language.Boss.KFbossFulsh, ToColorStr(self.time, self.time_color))
		if self.flush_time <= 0 or self.data.type == 1 then
			self.node_list["Desc"].text.text = ""
		else
			if nil == self.time_coundown then
				self.time_coundown = GlobalTimerQuest:AddTimesTimer(
					BindTool.Bind(self.OnOtherUpdate, self), 1, self.flush_time - TimeCtrl.Instance:GetServerTime())
			end
			self:OnOtherUpdate()
		end
	end
	
	if self.data.type == 0 then
		local boss_data = self:GetBossData(self.data.boss_id)
		self.node_list["Desc"].text.text = self.data.scene_show
		if boss_data then
			self.flush_time = ShenYuBossData.Instance:GetGodMagicBossFlushTimesByBossId(self.data.boss_id, self.data.scene_id) or 0
			self.time_color = self.flush_time <= 0 and TEXT_COLOR.GREEN or TEXT_COLOR.RED
			self.node_list["TxtTime"].text.text = ToColorStr(self.time, self.time_color)
			if self.flush_time <= 0 then
				self.time = Language.Boss.CanKill
				self.node_list["TxtTime"].text.text = ToColorStr(self.time, self.time_color)
			else
				if nil == self.time_coundown then
					self.time_coundown = GlobalTimerQuest:AddTimesTimer(
						BindTool.Bind(self.OnBossUpdate, self), 1, self.flush_time - TimeCtrl.Instance:GetServerTime())
				end
				self:OnBossUpdate()
			end
		end
	end
	self:FlushHl()
end

function BossGodMagicBossItem:FlushHl()
	if self.node_list["ImgHL"] then
		self.node_list["ImgHL"]:SetActive(self.parent:GetCurBossId() == self.data.boss_id)
	end
end

function BossGodMagicBossItem:OnBossUpdate()
	local time = math.max(0, self.flush_time - TimeCtrl.Instance:GetServerTime())
	if time <= 0 then
		self.time = ToColorStr(Language.Dungeon.CanKill, TEXT_COLOR.GREEN)
		self.node_list["TxtTime"].text.text = string.format("<color=%s>%s</color>", self.time_color, self.time)
	else
		self.time = ToColorStr(TimeUtil.FormatSecond(time), TEXT_COLOR.RED)
		self.node_list["TxtTime"].text.text = string.format("<color=%s>%s</color>", self.time_color, self.time)
	end
end

--组队------------------------------------
------------------------------------------
------------------------------------------
BossGodMagicTeamInfo = BossGodMagicTeamInfo or BaseClass(BaseRender)
function BossGodMagicTeamInfo:__init()
	self.team_cells = {}

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

function BossGodMagicTeamInfo:__delete()
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

function BossGodMagicTeamInfo:GetNumberOfCells()
	return #self.team_list
end

function BossGodMagicTeamInfo:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = BossGodMagicTeamCell.New(cell.gameObject, self)
		contain_cell.parent = self
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	contain_cell:SetIndex(cell_index)
	contain_cell:SetData(self.team_list[cell_index])
end

function BossGodMagicTeamInfo:OnChangeScene()
	self:Flush()
end

function BossGodMagicTeamInfo:ExitClick()
	ScoietyCtrl.Instance:ExitTeamReq()
end

function BossGodMagicTeamInfo:OpenTeam()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
end

function BossGodMagicTeamInfo:CreateTeam()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
	local param_t = {}
	param_t.must_check = 0
	param_t.assign_mode = 1
	ScoietyCtrl.Instance:CreateTeamReq(param_t, true)
end

function BossGodMagicTeamInfo:OnFlush()
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

function BossGodMagicTeamInfo:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function BossGodMagicTeamInfo:GetSelectIndex()
	return self.select_index or 0
end

function BossGodMagicTeamInfo:FlushAllHl()
	for k,v in pairs(self.contain_cell_list) do
		v:FlushHl(self.select_index)
	end
end
---------------------------------------------------------------
BossGodMagicTeamCell = BossGodMagicTeamCell or BaseClass(BaseCell)
function BossGodMagicTeamCell:__init()

	self.node_list["BossMenberItem"].toggle:AddClickListener(BindTool.Bind(self.ClickItem, self))

end

function BossGodMagicTeamCell:__delete()
	self.role_name = nil
	self.level_text = nil
	self.menber_state = nil
	self.parent = nil
end

function BossGodMagicTeamCell:OnFlush()
	self.root_node.gameObject:SetActive(self.data ~= nil and next(self.data) ~= nil)
	if not self.data or not next(self.data) then return end

	-- local lv1, zhuan1 = PlayerData.GetLevelAndRebirth(self.data.level)
	local member_state = ScoietyData.Instance:GetMemberPosState(self.data.role_id, self.data.scene_id, self.data.is_online)
	self.node_list["TxtName"].text.text = self.data.name
	self.node_list["TxtLevel"].text.text = string.format(Language.Common.ShenGongHuanHuaLevel, PlayerData.GetLevelString(self.data.level))
	self.node_list["TxtState"].text.text = member_state

end

function BossGodMagicTeamCell:ClickItem()
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

function BossGodMagicTeamCell:FlushHl(cur_index)
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	self.node_list["ImgHL"]:SetActive(self.data and cur_index == self.index and main_role_id ~= self.data.role_id)
end