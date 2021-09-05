FuBenAddFriendView = FuBenAddFriendView or BaseClass(BaseView)

function FuBenAddFriendView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/fubenview_prefab", "FinishAddFrient"},
	}
	self.view_layer = UiLayer.Pop
	self.is_modal = true									-- 是否模态
	self.is_any_click_close = true							-- 是否点击其它地方要关闭界面
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function FuBenAddFriendView:__delete()

end

function FuBenAddFriendView:LoadCallBack()
	self.team_member_list = {}
	self.team_member_list[1] = FuBenTeamAddFriend.New(self.node_list["Team1"])
	self.team_member_list[2] = FuBenTeamAddFriend.New(self.node_list["Team2"])

	self.node_list["Bg"].rect.sizeDelta = Vector3(550, 370, 0)
	self.node_list["Txt"].text.text = Language.Title.FinishAddFrient
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose,self))
end

function FuBenAddFriendView:ReleaseCallBack()
	if self.team_member_list then
		for k, v in pairs(self.team_member_list) do
			v:DeleteMe()
		end
	end
	self.team_member_list = nil
end

function FuBenAddFriendView:OnClickClose()
	self:Close()
end

function FuBenAddFriendView:OpenCallBack()
	self:Flush()
end

function FuBenAddFriendView:CloseCallBack()
	MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.AddFriend, false)
	-- local team_info = ScoietyData.Instance:GetTeamInfo()
	-- local team_type = team_info.team_type or 0
	-- if team_type == FuBenTeamType.TEAM_TYPE_TEAM_DAILY_FB then
	-- 	ViewManager.Instance:Open(ViewName.FuBen, TabIndex.fb_exp)
	-- elseif team_type == FuBenTeamType.TEAM_TYPE_TEAM_TOWERDEFEND then
	-- 	FuBenData.Instance:SetDefaultChoose(ScoietyData.InviteOpenType.TeamTowerDefend)
	-- 	ViewManager.Instance:Open(ViewName.FuBen, TabIndex.fb_team_tower)
	-- elseif team_type == FuBenTeamType.TEAM_TYPE_EQUIP_TEAM_FB then
	-- 	FuBenData.Instance:SetDefaultChoose(ScoietyData.InviteOpenType.EquipTeamFbNew)
	-- 	ViewManager.Instance:Open(ViewName.FuBen, TabIndex.fb_team_tower)
	-- end
end

function FuBenAddFriendView:OnFlush()
	self:FlushTeamRoom()
end

function FuBenAddFriendView:FlushTeamRoom()
	local info = ScoietyData.Instance:GetTeamInfo()
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if info == nil or info.team_member_list == nil or info.team_member_list == "" then return end
	
	if info then
		local i = 1
		for k,v in pairs(info.team_member_list) do
			local teammate_info = v
			if teammate_info then
				-- 如果是队员
				if role_id ~= teammate_info.role_id then
					self.team_member_list[i]:FlushMemberInfo(teammate_info, info.team_type)
					self.team_member_list[i]:SetActive(true)
					i = i + 1
				end
			end
		end
	end
end

FuBenTeamAddFriend = FuBenTeamAddFriend or BaseClass(BaseCell)

function FuBenTeamAddFriend:__init()
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtCount"])
end

function FuBenTeamAddFriend:__delete()
	self.fight_text = nil
end

function FuBenTeamAddFriend:FlushMemberInfo(meminfo, team_type)
	self.node_list["TxtName"].text.text = meminfo.name
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = meminfo.capability
	end
	-- local lv, zhuan = PlayerData.GetLevelAndRebirth(meminfo.level)
	-- self.node_list["TxtLevel"].text.text = string.format(Language.Common.ZhuanShneng, lv, zhuan)
	self.node_list["TxtLevel"].text.text = PlayerData.GetLevelString(meminfo.level)
	UI:SetGraphicGrey(self.node_list["IconImage"], not (meminfo.is_online == 1))
	UI:SetGraphicGrey(self.node_list["RawImage"], not (meminfo.is_online == 1))
	-- self.node_list["ImgOffLine"]:SetActive(not meminfo.is_online == 1)

	AvatarManager.Instance:SetAvatar(meminfo.role_id, self.node_list["RawImage"], self.node_list["IconImage"], meminfo.sex, meminfo.prof, false)
	local is_friend = ScoietyData.Instance:IsFriend(meminfo.name)
	local is_guild = nil ~= GuildData.Instance:GetGuildMemberInfo(meminfo.role_id)

	UI:SetButtonEnabled(self.node_list["BtnAddFriend"], not is_friend)
	UI:SetButtonEnabled(self.node_list["BtnGuild"], not is_guild)
	self.node_list["BtnAddFriend"].button:AddClickListener(BindTool.Bind(self.OnClickAddFriend, self, meminfo.role_id))
	self.node_list["BtnGuild"].button:AddClickListener(BindTool.Bind(self.OnClickGuildInvite, self, meminfo.role_id))
end

function FuBenTeamAddFriend:OnClickAddFriend(role_id)
	if role_id then
		ScoietyCtrl.Instance:AddFriendReq(role_id)
	end
end

function FuBenTeamAddFriend:OnClickGuildInvite(role_id)
	if role_id then
		GuildCtrl.Instance:SendInviteGuildReq(role_id)
	end
end