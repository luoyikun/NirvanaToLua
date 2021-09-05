ApplyView = ApplyView or BaseClass(BaseView)

function ApplyView:__init()
	self.ui_config = {{"uis/views/scoietyview_prefab", "ApplyList"}}
	self.cell_list = {}
	self.open_type = 0
end

function ApplyView:__delete()

end

function ApplyView:ReleaseCallBack()
	for _,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	--清除变量
	-- self,node_list["TitleText"].text.text = nil
	-- self.node_list['LeaderNameTxt'].text.text = nil
	-- self.node_list["BtnAgree"]:SetActive(false)
	-- self.node_list["BtnRefuse"]:SetActive(false)
	-- self.node_list["BtnGoPet"]:SetActive(false)
	-- self.node_list["OperateTxt"].text.text= nil
	self.title = nil
	self.name = nil
	self.show_btn_team = nil
	self.show_btn_pet = nil
	self.tab_text = nil
end

function ApplyView:LoadCallBack()
	self.select_index = 1

	self.node_list["Block"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnRefuse"].button:AddClickListener(BindTool.Bind(self.ClickOpera, self , 1))
	self.node_list["BtnAgree"].button:AddClickListener(BindTool.Bind(self.ClickOpera, self, 0))
	self.node_list["BtnGoPet"].button:AddClickListener(BindTool.Bind(self.GoPetClick, self))
	-- 生成滚动条
	self.scroller_data = {}
	local scroller_delegate = self.node_list["ApplyList"].list_simple_delegate		

	--生成数量
	scroller_delegate.NumberOfCellsDel = function()
		return #self.scroller_data or 0
	end
	--刷新函数
	scroller_delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1

		local apply_cell = self.cell_list[cell]
		if apply_cell == nil then
			apply_cell = ApplyCell.New(cell.gameObject)
			apply_cell.root_node.toggle.group = self.node_list["ApplyList"].toggle_group
			apply_cell.apply_view = self
			self.cell_list[cell] = apply_cell
		end

		apply_cell:SetIndex(data_index)
		apply_cell:SetData(self.scroller_data[data_index])
	end
end

function ApplyView:CloseCallBack()
	self.open_type = 0
end

function ApplyView:SetOpenType(open_type)
	self.open_type = open_type
end

function ApplyView:CloseWindow()
	self:Close()
end

function ApplyView:ClickOpera(value)
	if self.select_index == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.SelectAddFriendItemTips)
		return
	end
	local role_info = {}

	if self.open_type == APPLY_OPEN_TYPE.JOIN then
		role_info = ScoietyData.Instance:GetJoinRoleInfoByIndex(self.select_index)
	elseif self.open_type == APPLY_OPEN_TYPE.FRIEND then
		role_info = ScoietyData.Instance:GetFriendApplyInfoByIndex(self.select_index)
	elseif self.open_type == APPLY_OPEN_TYPE.TEAM then
		role_info = ScoietyData.Instance:GetInviteInfoByIndex(self.select_index)
	end

	if next(role_info) then
		self.select_index = 1

		if self.open_type == APPLY_OPEN_TYPE.JOIN then
			ScoietyCtrl.Instance:ReqJoinTeamRet(role_info.req_role_id, value)
			ScoietyData.Instance:RemoveJoinTeamInfoByRoleId(role_info.req_role_id)
			local join_team_info = ScoietyData.Instance:GetReqJoinTeamInfo()
			if next(join_team_info) then
				self:Flush()
			else
				MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.JOIN_REQ, false)
				self:Close()
			end

		elseif self.open_type == APPLY_OPEN_TYPE.FRIEND then
			local param_t = {}
			param_t.req_user_id = role_info.req_user_id
			param_t.req_gamename = role_info.req_gamename
			param_t.is_accept = value == 1 and 0 or 1
			param_t.req_sex = role_info.req_sex
			param_t.req_prof = role_info.req_prof
			ScoietyCtrl.Instance:AddFriendRet(param_t)

			ScoietyData.Instance:RemoveFriendApplyInfoByRoleId(role_info.req_user_id)

			local friend_apply_list = ScoietyData.Instance:GetFriendApplyList()
			if next(friend_apply_list) then
				self:Flush()
			else
				MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.FRIEND_REC, false)
				self:Close()
			end

		elseif self.open_type == APPLY_OPEN_TYPE.TEAM then
			ScoietyCtrl.Instance:InviteUserTransmitRet(role_info.inviter, value)

			if value == 1 then
				ScoietyData.Instance:RemoveInviteInfoById(role_info.inviter)
				local invite_info = ScoietyData.Instance:GetInviteInfo()
				if next(invite_info) then
					self:Flush()
				else
					MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.TEAM_REQ, false)
					self:Close()
				end
			else
				ScoietyData.Instance:ClearInviteInfo()
				MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.TEAM_REQ, false)
				self:Close()
			end
		end
	end
end

function ApplyView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function ApplyView:GoPetClick()

	if 0 == #self.scroller_data then
		TipsCtrl.Instance:ShowSystemMsg(Language.Pet.NotPetFriend)
		self:Close()
		return
	end

	self:Close()
end

function ApplyView:GetSelectIndex()
	return self.select_index or 1
end

function ApplyView:OnFlush()
	local data = {}
	local title_name = ""
	local name_str = ""
	self.node_list["BtnAgree"]:SetActive(true)
	self.node_list["BtnRefuse"]:SetActive(true)
	self.node_list["BtnGoPet"]:SetActive(false)

	if self.open_type == APPLY_OPEN_TYPE.JOIN then
		title_name = Language.Society.JoinApply
		name_str = Language.Society.NameDes
		self.node_list["OperateTxt"].text.text = Language.Society.PowerDes
		data = ScoietyData.Instance:GetReqJoinTeamInfo()
	elseif self.open_type == APPLY_OPEN_TYPE.FRIEND then
		title_name = Language.Society.FriendApply
		name_str = Language.Society.NameDes
		self.node_list["OperateTxt"].text.text = Language.Society.PowerDes
		data = ScoietyData.Instance:GetFriendApplyList()
	elseif self.open_type == APPLY_OPEN_TYPE.TEAM then
		title_name = Language.Society.TeamApply
		name_str = Language.Society.LeaderNameDes
		self.node_list["OperateTxt"].text.text = Language.Society.TeamNumDes
		data = ScoietyData.Instance:GetInviteInfo()
	elseif self.open_type == APPLY_OPEN_TYPE.PET then
		title_name = Language.Society.SelectPetFriend
		name_str = Language.Society.NameDes
		self.node_list["BtnAgree"]:SetActive(false)
		self.node_list["BtnRefuse"]:SetActive(false)
		self.node_list["BtnGoPet"]:SetActive(true)
		self.node_list["OperateTxt"].text.text = Language.Society.PetNumDes 
	end
	self.node_list["TitleText"].text.text = title_name
	self.node_list["LeaderNameTxt"].text.text = name_str

	self.scroller_data = data
	self.node_list["ApplyList"].scroller:ReloadData(0)
end

----------------------------------------------------------------------------
--ApplyCell 		队伍申请滚动条格子
----------------------------------------------------------------------------

ApplyCell = ApplyCell or BaseClass(BaseCell)

function ApplyCell:__init()
	self.apply_view = nil
	self.node_list["ApplyItem"].toggle:AddClickListener(BindTool.Bind(self.ClickItem, self))

end

function ApplyCell:__delete()
	self.apply_view = nil
	self.data = nil
end

function ApplyCell:OnFlush()
	if not self.data or not next(self.data) then return end

	self.user_id = self.data.req_role_id or self.data.req_user_id or self.data.user_id or self.data.inviter
	local prof = self.data.req_role_prof or self.data.req_prof or self.data.prof or self.data.inviter_prof
	local sex = self.data.req_role_sex or self.data.req_sex or self.data.sex or self.data.inviter_sex
	AvatarManager.Instance:SetAvatar(self.user_id, self.node_list["RawImage"], self.node_list["RoleImage"], sex, prof, true)

	local level = self.data.req_role_level or self.data.req_level or self.data.level or self.data.inviter_level or 0
	-- local lv, zhuan = PlayerData.GetLevelAndRebirth(level)
	-- local level_des = string.format(Language.Common.LevelFormat, lv, zhuan)
	self.node_list["LevelTxt"].text.text = PlayerData.GetLevelString(level)
	local name = self.data.req_role_name or self.data.req_gamename or self.data.gamename or self.data.inviter_name or ""
	self.node_list["NameTxt"].text.text = name

	local cap_value = ""
	if self.apply_view.open_type == APPLY_OPEN_TYPE.TEAM then
		cap_value = string.format("%s/%d", self.data.member_num, GameEnum.TEAM_MAX_COUNT)
	else
		cap_value = self.data.req_role_capability or self.data.capability
		cap_value = CommonDataManager.ConverMoney(cap_value)
	end
	self.node_list["CapabilityTxt"].text.text = cap_value

	-- 刷新选中特效
	local select_index = self.apply_view:GetSelectIndex()
	if self.root_node.toggle.isOn and select_index ~= self.index then
		self.root_node.toggle.isOn = false
	elseif self.root_node.toggle.isOn == false and select_index == self.index then
		self.root_node.toggle.isOn = true
	end
end

function ApplyCell:ClickItem()
	self.root_node.toggle.isOn = true
	self.apply_view:SetSelectIndex(self.index)
end