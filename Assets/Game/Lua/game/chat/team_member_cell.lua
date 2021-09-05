--------------------------------------------------------------------------
-- ChatTeamMemberCell 	队伍成员
--------------------------------------------------------------------------
ChatTeamMemberCell = ChatTeamMemberCell or BaseClass(BaseCell)

function ChatTeamMemberCell:__init()
	self.avatar_key = 0
	self.node_list["TeamMemberCell"].toggle:AddClickListener(BindTool.Bind(self.OnClickItem, self))
end

function ChatTeamMemberCell:__delete()
	self.avatar_key = 0
end

function ChatTeamMemberCell:OnClickItem()
	if self.data.role_id == GameVoManager.Instance:GetMainRoleVo().role_id then
		self.root_node.toggle.isOn = true
		return
	end

	local function colse_call_back()
		if self:IsNil() then
			return
		end
		self.root_node.toggle.isOn = false
	end

	ScoietyCtrl.Instance:ShowOperateList(nil, self.data.name, nil, colse_call_back)
end

function ChatTeamMemberCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function ChatTeamMemberCell:SetIconImage()
	AvatarManager.Instance:SetAvatar(self.data.role_id, self.node_list["RawImage"], self.node_list["ImgIcon"], self.data.sex, self.data.prof, false)
end

function ChatTeamMemberCell:OnFlush()
	if nil == self.data then return end

	self.data = ScoietyData.Instance:GetMemberInfoByRoleId(self.data)

	
	local post_str = self.index == 1 and Language.Society.LeaderDes or Language.Society.MemberDes

	self.node_list["TxtName"].text.text = string.format(Language.Chat.MemberDes, self.data.name, post_str)

	self:SetIconImage()

	if self.data.is_online ~= 0 then
		UI:SetGraphicGrey(self.node_list["ImgIcon"], false)
		UI:SetGraphicGrey(self.node_list["RawImage"], false)
	else
		UI:SetGraphicGrey(self.node_list["ImgIcon"], true)
		UI:SetGraphicGrey(self.node_list["RawImage"], true)
	end
end