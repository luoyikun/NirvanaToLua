--------------------------------------------------------------------------
-- MemberCell   成员格子
--------------------------------------------------------------------------
MemberCell = MemberCell or BaseClass(BaseCell)

function MemberCell:__init(instance)
	self.avatar_key = 0
	self:IconInit()
end

function MemberCell:__delete()
	self.avatar_key = 0
end

function MemberCell:IconInit()
	self.node_list["GuildMemberCell"].toggle:AddClickListener(BindTool.Bind(self.OnClickItem, self))
end

-- 选择成员
function MemberCell:OnSelectMember()
	if self.index and GuildDataConst.GUILD_MEMBER_LIST.list[self.index].uid ~= GameVoManager.Instance:GetMainRoleVo().role_id then
		local info = GuildData.Instance:GetGuildMemberInfo()
		if info then
			local detail_type = ScoietyData.DetailType.Default
			if info.post == GuildDataConst.GUILD_POST.TUANGZHANG then
				detail_type = ScoietyData.DetailType.GuildTuanZhang
			elseif info.post == GuildDataConst.GUILD_POST.FU_TUANGZHANG or info.post == GuildDataConst.GUILD_POST.ZHANG_LAO then
				detail_type = ScoietyData.DetailType.Guild
			end

			local function canel_callback()
				if self.root_node then
					self.root_node.toggle.isOn = false
				end
			end
			ScoietyCtrl.Instance:ShowOperateList(detail_type, GuildDataConst.GUILD_MEMBER_LIST.list[self.index].role_name, nil, canel_callback)
		end
	end
end

function MemberCell:OnClickItem()
	self:OnSelectMember()
end

function MemberCell:OnFlush()
	if self.data and not next(self.data) then return end

	self.node_list["TxtName"].text.text = self.data.role_name
	-- 以前是职位，现在用来显示称号

	-- 公会聊天显示称号
	-- local signin_title_cfg = GuildData.Instance:GetSigninTitleOneCfg(self.data.guild_signin_count or 0)
	-- local post_id = signin_title_cfg.name or ""

	local post_id = GuildData.Instance:GetGuildPost(self.data.uid)
	self.node_list["TxtPost"].text.text = GUILD_CHAT_POST[post_id]
	self:SetIconImage()

	if self.data.is_online ~= 0 then
		UI:SetGraphicGrey(self.node_list["ImgIconImage"], false)
		UI:SetGraphicGrey(self.node_list["RawImageObj"], false)
	else
		UI:SetGraphicGrey(self.node_list["ImgIconImage"], true)
		UI:SetGraphicGrey(self.node_list["RawImageObj"], true)
	end
end

function MemberCell:SetIconImage()
	local role_id = self.data.uid
	self.node_list["HeadFrame"].image.enabled = false
	CommonDataManager.SetAvatarFrame(role_id, self.node_list["HeadFrame"], self.node_list["BgKuang"])

	AvatarManager.Instance:SetAvatar(self.data.uid, self.node_list["RawImageObj"], self.node_list["ImgIconImage"], self.data.sex, self.data.prof, false)
end