MainUIViewTeam = MainUIViewTeam or BaseClass(BaseRender)

function MainUIViewTeam:__init()
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
			menber_cell = MainUiMenberCell.New(cell.gameObject)
			menber_cell.root_node.toggle.group = self.list_view.toggle_group
			menber_cell.team_view = self
			self.cell_list[cell] = menber_cell
		end

		menber_cell:SetIndex(data_index)
		menber_cell:SetData(self.team_list[data_index])
	end

	self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER, BindTool.Bind(self.OnChangeScene, self))
end

function MainUIViewTeam:__delete()
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

function MainUIViewTeam:ExitClick()
	ScoietyCtrl.Instance:ExitTeamReq()
end

function MainUIViewTeam:OnChangeScene()
	self:ReloadData()
end

function MainUIViewTeam:ReloadData()
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

function MainUIViewTeam:OpenTeam()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
end

function MainUIViewTeam:CreateTeam()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
	local param_t = {}
	param_t.must_check = 0
	param_t.assign_mode = 1
	ScoietyCtrl.Instance:CreateTeamReq(param_t, true)
end

function MainUIViewTeam:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function MainUIViewTeam:GetSelectIndex()
	return self.select_index or 0
end
----------------------------------------------------------------------------
--MainUiMenberCell 		队伍滚动条格子
----------------------------------------------------------------------------

MainUiMenberCell = MainUiMenberCell or BaseClass(BaseCell)

function MainUiMenberCell:__init()
	self.node_list["MenberItem"].toggle:AddClickListener(BindTool.Bind(self.ClickItem, self))
end

function MainUiMenberCell:__delete()
	if self.team_member_handle then
		GlobalEventSystem:UnBind(self.team_member_handle)
		self.team_member_handle = nil
	end
end

function MainUiMenberCell:OnFlush()
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

function MainUiMenberCell:ClickItem()
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