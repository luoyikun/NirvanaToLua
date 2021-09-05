require("game/boss/world_boss_info_view")

WorldBossFightView = WorldBossFightView or BaseClass(BaseView)

function WorldBossFightView:__init()
	self.ui_config = {{"uis/views/bossview_prefab", "WorldBossFightView"}}
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.is_open_info_view = false
end

function WorldBossFightView:__delete()

end

function WorldBossFightView:ReleaseCallBack()
	if self.show_mode_list_event ~= nil then
		GlobalEventSystem:UnBind(self.show_mode_list_event)
		self.show_mode_list_event = nil
	end
	if self.menu_toggle_event then
		GlobalEventSystem:UnBind(self.menu_toggle_event)
	end
	self:RemoveDelayTime()

	if self.info_view then
		self.info_view:DeleteMe()
		self.info_view = nil
	end
	self.show_panel = nil

	if self.rank_view then
		self.rank_view:DeleteMe()
		self.rank_view = nil
	end

	if self.team_panel then
		self.team_panel:DeleteMe()
		self.team_panel = nil
	end
end

function WorldBossFightView:LoadCallBack()
	self.is_show_person = true
	self.rank_view = WorldBossRankView.New(self.node_list["ScoreRank"])
	self.node_list["BtnTab"].toggle.onValueChanged:AddListener(BindTool.Bind(self.OnClickPerson, self))

	self.team_panel = BossWorldTeamInfo.New(self.node_list["TeamContent"])
	self.menu_toggle_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,BindTool.Bind(self.PortraitToggleChange, self))
	self:Flush("team_type")

	self.info_view = WorldBossInfoView.New()
	self.info_view:Open()
end

function WorldBossFightView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if value then
		self:Flush()
	end
end

function WorldBossFightView:OpenCallBack()
	GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)
	self.main_role_revive = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_REALIVE, BindTool.Bind(self.MainRoleRevive, self))
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
end

function WorldBossFightView:CloseCallBack()
	if self.main_role_revive then
		GlobalEventSystem:UnBind(self.main_role_revive)
		self.main_role_revive = nil
	end
	self:RemoveDelayTime()

	if self.info_view then
		self.info_view:Close()
	end
end

function WorldBossFightView:MainRoleRevive()
	self:RemoveDelayTime()
	--钻石复活才自动挂机
	if ReviveData.Instance:GetLastReviveType() == REALIVE_TYPE.REALIVE_TYPE_HERE_GOLD then
		-- 延迟是因为主角复活后有可能坐标还没有reset
		self.delay_time = GlobalTimerQuest:AddDelayTimer(function() GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto) end, 0.5)
	end
end

function WorldBossFightView:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function WorldBossFightView:PortraitToggleChange(state)
	self.node_list["PanelTrackInfo"]:SetActive(state)
end

function WorldBossFightView:OnFlush(param_t)
	self.rank_view:Flush()
	for k,v in pairs(param_t) do
		if k == "team_type" then
			self.team_panel:Flush()
		end
	end
end

function WorldBossFightView:OnClickPerson(switch)
	self.is_show_person = switch
	self.rank_view:Flush()
end

function WorldBossFightView:SetCanRoll(index)
	if self.info_view and self.info_view:IsOpen() then
		self.info_view:SetCanRoll(index)
	end
end

function WorldBossFightView:SetRollResult(point, index)
	if self.info_view and self.info_view:IsOpen() then
		self.info_view:SetRollResult(point, index)
	end
end

function WorldBossFightView:SetRollTopPointInfo(boss_id, hudun_index, top_roll_point, top_roll_name)
	if self.info_view and self.info_view:IsOpen() then
		self.info_view:SetRollTopPointInfo(boss_id, hudun_index, top_roll_point, top_roll_name)
	end
end

BossWorldTeamInfo = BossWorldTeamInfo or BaseClass(BaseRender)
function BossWorldTeamInfo:__init()
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

function BossWorldTeamInfo:__delete()
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

function BossWorldTeamInfo:GetNumberOfCells()
	return #self.team_list
end

function BossWorldTeamInfo:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = BossWorldTeamCell.New(cell.gameObject, self)
		contain_cell.parent = self
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	contain_cell:SetIndex(cell_index)
	contain_cell:SetData(self.team_list[cell_index])
end

function BossWorldTeamInfo:OnChangeScene()
	self:Flush()
end

function BossWorldTeamInfo:ExitClick()
	ScoietyCtrl.Instance:ExitTeamReq()
end

function BossWorldTeamInfo:OpenTeam()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
end

function BossWorldTeamInfo:CreateTeam()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
	local param_t = {}
	param_t.must_check = 0
	param_t.assign_mode = 1
	ScoietyCtrl.Instance:CreateTeamReq(param_t, true)
end

function BossWorldTeamInfo:OnFlush()
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

function BossWorldTeamInfo:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function BossWorldTeamInfo:GetSelectIndex()
	return self.select_index or 0
end

function BossWorldTeamInfo:FlushAllHl()
	for k,v in pairs(self.contain_cell_list) do
		v:FlushHl(self.select_index)
	end
end

BossWorldTeamCell = BossWorldTeamCell or BaseClass(BaseCell)
function BossWorldTeamCell:__init()

	self.node_list["BossMenberItem"].toggle:AddClickListener(BindTool.Bind(self.ClickItem, self))

end

function BossWorldTeamCell:__delete()
	self.role_name = nil
	self.level_text = nil
	self.menber_state = nil
	self.parent = nil
end

function BossWorldTeamCell:OnFlush()
	self.root_node.gameObject:SetActive(self.data ~= nil and next(self.data) ~= nil)
	if not self.data or not next(self.data) then return end

	-- local lv1, zhuan1 = PlayerData.GetLevelAndRebirth(self.data.level)
	local member_state = ScoietyData.Instance:GetMemberPosState(self.data.role_id, self.data.scene_id, self.data.is_online)
	self.node_list["TxtName"].text.text = self.data.name
	self.node_list["TxtLevel"].text.text = string.format(Language.Common.ShenGongHuanHuaLevel, PlayerData.GetLevelString(self.data.level))
	self.node_list["TxtState"].text.text = member_state

end

function BossWorldTeamCell:ClickItem()
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

function BossWorldTeamCell:FlushHl(cur_index)
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	self.node_list["ImgHL"]:SetActive(self.data and cur_index == self.index and main_role_id ~= self.data.role_id)
end



----------------------排行View----------------------
WorldBossRankView = WorldBossRankView or BaseClass(BaseRender)
function WorldBossRankView:__init()
	-- 获取控件
	self.rank_data_list = {}
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	self.item_t = {}
	self:Flush()
end

function WorldBossRankView:__delete()
	for k,v in pairs(self.item_t) do
		v:DeleteMe()
	end
	self.item_t = {}
end

-----------------------------------
-- ListView逻辑
-----------------------------------
function WorldBossRankView:BagGetNumberOfCells()
	return math.max(#self.rank_data_list, 5)
end

function WorldBossRankView:BagRefreshCell(cell, data_index, cell_index)
	local item = self.item_t[cell]
	if nil == item then
		item = WorldBossRankItem.New(cell.gameObject)
		self.item_t[cell] = item
	end
	item:SetIndex(cell_index + 1)
	if self.rank_data_list[cell_index + 1] then
		item:SetData(self.rank_data_list[cell_index + 1])
	else
		item:SetData({name = "--", hurt = 0})
	end
end

function WorldBossRankView:OnFlush()
	local info = BossData.Instance:GetBossPersonalHurtInfo()
	if info.self_rank > 0 and info.self_rank <= 3 then
		local bundle, asset = ResPath.GetRankIcon(info.self_rank)
		self.node_list["Img_rank"]:SetActive(true)
		self.node_list["rank"]:SetActive(false)
		self.node_list["Img_rank"].image:LoadSprite(bundle, asset)
	else
		self.node_list["rank"].text.text = (info.self_rank > 5 or info.self_rank == 0) and Language.Boss.NotOnRank or info.self_rank
		self.node_list["rank"]:SetActive(true)
		self.node_list["Img_rank"]:SetActive(false)
	end
	
	self.node_list["name"].text.text = PlayerData.Instance.role_vo.name
	self.node_list["hurt"].text.text = ToColorStr(CommonDataManager.ConverMoney2(info.my_hurt), TEXT_COLOR.GREEN)

	self.rank_data_list = info.rank_list
	if self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:RefreshActiveCellViews()
	end
end

WorldBossRankItem = WorldBossRankItem or BaseClass(BaseRender)

function WorldBossRankItem:__init()
end

function WorldBossRankItem:SetIndex(index)
	if index <= 3 then
		local bundle, asset = ResPath.GetRankIcon(index)
		self.node_list["rank"]:SetActive(false)
		self.node_list["Img_rank"]:SetActive(true)
		self.node_list["Img_rank"].image:LoadSprite(bundle, asset)
	else
		self.node_list["Img_rank"]:SetActive(false)
		self.node_list["rank"]:SetActive(true)
		self.node_list["rank"].text.text = index
	end
end

function WorldBossRankItem:SetData(data)
	self.data = data
	self:Flush()
end

function WorldBossRankItem:OnFlush()
	if nil == self.data then
		return
	end
	self.node_list["name"].text.text = self.data.name
	self.node_list["score"].text.text = CommonDataManager.ConverMoney2(self.data.hurt)
end