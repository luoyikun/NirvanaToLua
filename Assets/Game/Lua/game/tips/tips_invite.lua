TipsInviteView = TipsInviteView or BaseClass(BaseView)

function TipsInviteView:__init()
	self.ui_config = {{"uis/views/tips/invitetip_prefab", "InviteTip"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.world_notice = ""
	self.guild_notice = ""
	self.open_type = ""
	self.is_modal = true
	self.is_any_click_close = true
end

function TipsInviteView:__delete()
end

function TipsInviteView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnFriend"].button:AddClickListener(BindTool.Bind(self.OnClick, self, ScoietyData.InviteType.FriendType))
	self.node_list["BtnGuild"].button:AddClickListener(BindTool.Bind(self.OnClick, self, ScoietyData.InviteType.GuildType))
	self.node_list["BtnWorld"].button:AddClickListener(BindTool.Bind(self.OnClick, self, ScoietyData.InviteType.WorldType))
	self.node_list["BtnNear"].button:AddClickListener(BindTool.Bind(self.OnClick, self, ScoietyData.InviteType.NearType))
end

function TipsInviteView:OpenCallBack()
	local is_visible = not IS_ON_CROSSSERVER
	self.node_list["BtnFriend"]:SetActive(is_visible)
	self.node_list["BtnWorld"]:SetActive(is_visible)
end

function TipsInviteView:CloseWindow()
	self:Close()
end

function TipsInviteView:OnClick(value)
	if value == ScoietyData.InviteType.GuildType then
		if GuildData.Instance.guild_id <= 0 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NotEnterGuild)
			return
		else
			local team_index = ScoietyData.Instance:GetTeamIndex()
			if team_index then
				SysMsgCtrl.Instance:ErrorRemind(Language.Society.GuildInvite)
				local content = ""
				if self.open_type == "" or self.open_type == ScoietyData.InviteOpenType.Normal then
					content = string.format(Language.Society.SomeOneTeamInvite, team_index, 0, self.open_type)
				elseif self.open_type == ScoietyData.InviteOpenType.ExpFuBen then
					local cfg = FuBenData.Instance:GetExpFBOtherCfg() or {}
					local min_level = cfg.open_level or 0
					content = string.format(Language.Society.TeamExpInvite, team_index, min_level, self.open_type)
				elseif self.open_type == ScoietyData.InviteOpenType.EquipTeamFbNew then
					local cfg = FuBenData.Instance:GetOpenList()
					local min_level = cfg[1] or 0
					content = string.format(Language.Society.TeamEquipInvite, team_index, min_level, self.open_type)
				elseif self.open_type == ScoietyData.InviteOpenType.TeamTowerDefend then
					local cfg = FuBenData.Instance:GetOpenList()
					local min_level = cfg[2] or 0
					content = string.format(Language.Society.TeamTowerDefendInvite, team_index, min_level, self.open_type)
				elseif self.open_type == ScoietyData.InviteOpenType.ManyFuBen then
					local fuben_layer = FuBenData.Instance:GetSelectFuBenLayer()
					local show_config = FuBenData.Instance:GetShowConfigByLayer(fuben_layer) or {}
					if show_config then
						local min_level = show_config.level or 0
						local name = show_config.name or ""
						content = string.format(Language.FuBen.GuildNotice, name, team_index, min_level, self.open_type)
					end
				end
				ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, content, CHAT_CONTENT_TYPE.TEXT)
			end
		end
	elseif value == ScoietyData.InviteType.FriendType or value == ScoietyData.InviteType.NearType then
		ScoietyCtrl.Instance:ShowInviteView(value)
	else
		--等级限制
		if not ChatData.Instance:IsCanChat(CHAT_OPENLEVEL_LIMIT_TYPE.WORLD) then
			return
		end


		local team_index = ScoietyData.Instance:GetTeamIndex()
		if team_index then
			SysMsgCtrl.Instance:ErrorRemind(Language.Society.WorldInvite)
			local content = ""
			if self.open_type == "" or self.open_type == ScoietyData.InviteOpenType.Normal then
				content = string.format(Language.Society.SomeOneTeamInvite, team_index, 0, self.open_type)
			elseif self.open_type == ScoietyData.InviteOpenType.ExpFuBen then
				local cfg = FuBenData.Instance:GetExpFBOtherCfg() or {}
				local min_level = cfg.open_level or 0
				content = string.format(Language.Society.TeamExpInvite, team_index, min_level, self.open_type)
			elseif self.open_type == ScoietyData.InviteOpenType.EquipTeamFbNew then
				local cfg = FuBenData.Instance:GetOpenList()
				local min_level = cfg[1] or 0
				content = string.format(Language.Society.TeamEquipInvite, team_index, min_level, self.open_type)
			elseif self.open_type == ScoietyData.InviteOpenType.TeamTowerDefend then
				local cfg = FuBenData.Instance:GetOpenList()
				local min_level = cfg[2] or 0
				content = string.format(Language.Society.TeamTowerDefendInvite, team_index, min_level, self.open_type)
			elseif self.open_type == ScoietyData.InviteOpenType.ManyFuBen then
				local fuben_layer = FuBenData.Instance:GetSelectFuBenLayer()
				local show_config = FuBenData.Instance:GetShowConfigByLayer(fuben_layer) or {}
				if show_config then
					local min_level = show_config.level or 0
					local name = show_config.name or ""
					content = string.format(Language.FuBen.WorldNotice, name, team_index, min_level, self.open_type)
				end
			end
			ChatCtrl.SendChannelChat(CHANNEL_TYPE.WORLD, content, CHAT_CONTENT_TYPE.TEXT)
		end
	end
	self:Close()
end

function TipsInviteView:CloseCallBack()
	self.open_type = ""
end

function TipsInviteView:SetOpenType(open_type)
	self.open_type = open_type
end

function TipsInviteView:SetWorldNotice(notice)
	self.world_notice = notice or ""
end

function TipsInviteView:SetGuildNotice(notice)
	self.guild_notice = notice or ""
end