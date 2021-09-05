-------------------------------------------------公会红包列表------------------------------------------------
GuildChatHongBaoCell = GuildChatHongBaoCell or BaseClass(BaseCell)

function GuildChatHongBaoCell:__init()
	self.node_list["GuildHongBao"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function GuildChatHongBaoCell:__delete()
	self.callback = nil
end

function GuildChatHongBaoCell:OnFlush()
	local has_get = GuildData.Instance:IsGetGuildHongBao(self.index)
	if GuildData.Instance:IsCanGetGuildHongBao(self.index) and not has_get then
		self.node_list["Effect"]:SetActive(true)
	else
		self.node_list["Effect"]:SetActive(false)
	end
	if has_get then
		UI:SetGraphicGrey(self.node_list["GuildHongBao"], false)
	else
		UI:SetGraphicGrey(self.node_list["GuildHongBao"], true)
	end
	local need_count = GuildData.Instance:GetGuildHongBaoKillCount(self.index) or 0
	self.node_list["Text"].text.text = need_count
end

function GuildChatHongBaoCell:ListenClick(callback)
	self.callback = callback
end

function GuildChatHongBaoCell:OnClick()
	if self.callback then
		self.callback(self.index)
	end
end