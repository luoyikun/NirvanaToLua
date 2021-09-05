NearTeamView = NearTeamView or BaseClass(BaseView)

function NearTeamView:__init()
	self.ui_config = {{"uis/views/scoietyview_prefab", "NearTeamList"}}
	self.cell_list = {}
	self.is_modal = true
	self.is_any_click_close = true
end

function NearTeamView:__delete()

end

function NearTeamView:ReleaseCallBack()

	self.cell_list = {}
	self.have_team = nil
	self.scroller = nil
end

function NearTeamView:LoadCallBack()

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnFastTeam"].button:AddClickListener(BindTool.Bind(self.FastTeam, self))
	self.node_list["BtnCreateTeam"].button:AddClickListener(BindTool.Bind(self.CreateTeam, self))

		-- 生成滚动条
	self.scroller_data = {}
	local scroller_delegate = self.node_list["TeamList"].list_simple_delegate

	--生成数量
	scroller_delegate.NumberOfCellsDel = function()
		return #self.scroller_data or 0
	end
	--刷新函数
	scroller_delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1

		local team_cell = self.cell_list[cell]
		if team_cell == nil then
			team_cell = ScrollerTeamCell.New(cell.gameObject)
			team_cell.mail_view = self
			self.cell_list[cell] = team_cell
		end

		team_cell:SetIndex(data_index)
		team_cell:SetData(self.scroller_data[data_index])
	end
end

function NearTeamView:OnFlush()
	local team_state = ScoietyData.Instance:GetTeamState()

	UI:SetButtonEnabled(self.node_list["BtnCreateTeam"], not team_state)
	UI:SetGraphicGrey(self.node_list["CreateTeamTxt"], not team_state)
	UI:SetButtonEnabled(self.node_list["BtnFastTeam"], not team_state)
	UI:SetGraphicGrey(self.node_list["FastTeamTxt"], not team_state)

	self.scroller_data = ScoietyData.Instance:GetTeamListAck()
	self.node_list["TeamList"].scroller:ReloadData(0)
end

function NearTeamView:CloseWindow()
	self:Close()
end

function NearTeamView:CreateTeam()
	local team_state = ScoietyData.Instance:GetTeamState()
	if team_state then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.AlreadyInTeam)
		return
	end
	local param_t = {}
	param_t.must_check = 0
	param_t.assign_mode = 1
	ScoietyCtrl.Instance:CreateTeamReq(param_t, true)
	self:Close()
end

function NearTeamView:FastTeam()
	local team_state = ScoietyData.Instance:GetTeamState()
	if team_state then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.AlreadyInTeam)
		return
	end
	ScoietyCtrl.Instance:AutoHaveTeamReq()
	self:Close()
end

----------------------------------------------------------------------------
--ScrollerTeamCell 		附近队伍滚动条格子
----------------------------------------------------------------------------

ScrollerTeamCell = ScrollerTeamCell or BaseClass(BaseCell)

function ScrollerTeamCell:__init()

	self.node_list["BtnAdd"].button:AddClickListener(BindTool.Bind(self.ClickEnter, self))
end

function ScrollerTeamCell:__delete()

end

function ScrollerTeamCell:OnFlush()
	if not self.data or not next(self.data) then return end
	local user_id = self.data.member_uid_list[1]
	local uuid = self.data.member_uuid_list[1]
	if uuid and uuid.plat_role_id then
		AvatarManager.Instance:SetAvatar(uuid.plat_role_id, self.node_list["RawImage"], self.node_list["RoleImage"], self.data.leader_sex, self.data.leader_prof, false)
	else
		AvatarManager.Instance:SetAvatar(user_id, self.node_list["RawImage"], self.node_list["RoleImage"], self.data.leader_sex, self.data.leader_prof, false)
	end

	local team_state = ScoietyData.Instance:GetTeamState()
	self.node_list["NameTxt"].text.text = self.data.leader_name
	self.node_list["NymTxt"].text.text =  string.format("%d/%d", self.data.cur_member_num, GameEnum.TEAM_MAX_COUNT)
end

function ScrollerTeamCell:ClickEnter()
	local team_index = self.data.team_index
	ScoietyCtrl.Instance:JoinTeamReq(team_index)
	local is_kf_pvp_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.KF_PVP)
	if is_kf_pvp_open then
		KuafuPVPCtrl.Instance:SendCrossMultiuserChallengeGetBaseSelfSideInfo()
	end
end