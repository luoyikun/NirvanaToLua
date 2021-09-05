ChatGuildView = ChatGuildView or BaseClass(BaseRender)

function ChatGuildView:__init()
	self.cell_list = {}
	self.guild_list = {}
	local scroller_delegate = self.node_list["CharList"].list_simple_delegate
	scroller_delegate.CellSizeDel = BindTool.Bind(self.GetCellSizeDel, self)
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.is_first_flush = true
	self.fall_cell_list = {}
	self.fall_event_list_data = {}
	local list_delegate = self.node_list["FallList"].list_simple_delegate
	list_delegate.CellSizeDel = BindTool.Bind(self.GetFallCellSizeDel, self)
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetFallNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshFallCell, self)


	self.node_list["TipsPanel"].button:AddClickListener(BindTool.Bind(self.ClickTips, self))
	self.node_list["LiaoTian"].toggle:AddClickListener(BindTool.Bind(self.ClickChat, self))
	self.node_list["System"].toggle:AddClickListener(BindTool.Bind(self.ClickSystem, self))
	self.node_list["FallItem"].toggle:AddClickListener(BindTool.Bind(self.ClickFallItem, self))

	self.node_list["CharList"].scroller.scrollerScrolled = function()
		local disable_height = self.node_list["CharList"].scroller.ScrollSize 				-- 列表不可见总长度
		if disable_height >= 0 then
			local normalized_position = self.node_list["CharList"].scroller.NormalizedScrollPosition
			if normalized_position < 1 then
				ChatData.Instance:SetNewLockState(true)
			else
				ChatData.Instance:SetNewLockState(false)
			end
		else
			ChatData.Instance:SetNewLockState(false)
		end
	end	

	self.node_list["FallList"].scroller.scrollerScrolled = function()
		local disable_height = self.node_list["FallList"].scroller.ScrollSize 				-- 列表不可见总长度
		if disable_height >= 0 then
			local normalized_position = self.node_list["FallList"].scroller.NormalizedScrollPosition
			if normalized_position < 1 then
				GuildData.Instance:SetNewFallLockState(true)
			else
				GuildData.Instance:SetNewFallLockState(false)
			end
		else
			GuildData.Instance:SetNewFallLockState(false)
		end
	end
end

function ChatGuildView:ClickTips()
	if self.node_list["FallItem"].toggle.isOn then
		GuildData.Instance:ClearFallUnreadMsg()
		GuildData.Instance:SetNewFallLockState(false)
		self.node_list["FallList"].scroller:ReloadData(1)
	else
		ChatData.Instance:ClearGuildUnreadMsg()
		ChatData.Instance:SetNewLockState(false)
		self.node_list["CharList"].scroller:ReloadData(1)
	end
end

function ChatGuildView:GetPosIsBottom()
	local disable_height = self.node_list["CharList"].scroller.ScrollSize 				-- 画布不可见长度
	if self.node_list["CharList"].scroller.ScrollPosition >= disable_height then
		self.node_list["CharList"].scroller:ReloadData(1)
		return true
	else
		return false
	end
end

function ChatGuildView:__delete()
	for k, v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	for k, v in pairs(self.fall_cell_list) do
		v:DeleteMe()
	end
	self.fall_cell_list = {}
	self.is_first_flush = true
end

function ChatGuildView:FlushGuildView(role_id)
	self.node_list["TipsPanel"]:SetActive(false)
	if role_id == SPECIAL_CHAT_ID.GUILD then
		self.guild_list = ChatData.Instance:GetChannel(CHANNEL_TYPE.GUILD).msg_list
		local lock_state = ChatData.Instance:GetNewLockState()
		if lock_state then
			self.node_list["CharList"].scroller:RefreshAndReloadActiveCellViews(true)
		else
			self.node_list["CharList"].scroller:ReloadData(1)
			self.node_list["CharList"].scroller:RefreshAndReloadActiveCellViews(true)
		end
		self:RefreshTips()
	elseif role_id == SPECIAL_CHAT_ID.TEAM then
		self.guild_list = ChatData.Instance:GetChannel(CHANNEL_TYPE.TEAM).msg_list
		self.node_list["CharList"].scroller:ReloadData(1)
		ChatData.Instance:ClearTeamUnreadMsg()
		-- self.node_list["TipsPanel"]:SetActive(false)
	elseif role_id == SPECIAL_CHAT_ID.SYSTEM then
		self.guild_list = ChatData.Instance:GetChannel(CHANNEL_TYPE.GUILD_SYSTEM).msg_list
		self.node_list["CharList"].scroller:ReloadData(1)
		-- self.node_list["TipsPanel"]:SetActive(false)
	elseif role_id == SPECIAL_CHAT_ID.FALLITEM then
		self.fall_event_list_data = GuildData.Instance:GetGuildRareLogRet()
		if next(self.fall_event_list_data) ~= nil then
			local lock_state = GuildData.Instance:GetNewFallLockState()
			if lock_state then
				self.node_list["FallList"].scroller:RefreshAndReloadActiveCellViews(true)
			else
				self.node_list["FallList"].scroller:ReloadData(1)
			end
		end
		self:RefreshFallTips()
	else
		local privite_obj = ChatData.Instance:GetPrivateObjByRoleId(role_id) or {}
		self.guild_list = privite_obj.msg_list or {}
		self.node_list["CharList"].scroller:ReloadData(1)

		local private_list = ChatData.Instance:GetDynamicChatList()
		for k,v in pairs(private_list) do
			ChatData.Instance:RemPrivateUnreadMsg(v.role_id)
		end
		self.channel_type = CHANNEL_TYPE.GUILD
		-- self.node_list["TipsPanel"]:SetActive(false)
	end
	self:FlushHighLight()
end

function ChatGuildView:GoToChatButtom()
	self.node_list["CharList"].scroller:ReloadData(1)
end

function ChatGuildView:GetCellSizeDel(data_index)
	data_index = data_index + 1
	local guild_list = self.guild_list[data_index]
	local channel_type = 0
	local current_id = ChatData.Instance:GetCurrentId()
	if current_id == SPECIAL_CHAT_ID.GUILD then
		channel_type = CHANNEL_TYPE.GUILD
	elseif current_id == SPECIAL_CHAT_ID.TEAM then
		channel_type = CHANNEL_TYPE.TEAM
	else
		channel_type = CHANNEL_TYPE.PRIVATE
	end
	local height = ChatData.Instance:GetChannelItemHeight(channel_type, guild_list.msg_id)
	if height <= 0 then
		height = ChatCtrl.Instance:CaleChatHeight(channel_type, guild_list)
	end

	if guild_list.is_special then
		height = 30
	end
	return height
end

function ChatGuildView:RefreshTips()
	local guild_unread_msg = ChatData.Instance:GetGuildUnreadMsg() or {}

	local count = #guild_unread_msg
	if count <= 0 then
		self.node_list["TipsPanel"]:SetActive(false)
		ChatData.Instance:ClearGuildUnreadMsg()
	else
		self.node_list["TipsPanel"]:SetActive(true)
		self.node_list["TipsText"].text.text = string.format(Language.Chat.WeiDu, count)
	end
end

function ChatGuildView:RefreshFallTips()
	local guild_unread_msg = GuildData.Instance:GetFallUnreadMsg() or {}

	local count = #guild_unread_msg or 0
	if count <= 0 then
		self.node_list["TipsPanel"]:SetActive(false)
		GuildData.Instance:ClearFallUnreadMsg()
	else
		self.node_list["TipsPanel"]:SetActive(true)
		self.node_list["TipsText"].text.text = string.format(Language.Chat.WeiDu, count)
	end
end

function ChatGuildView:GetNumberOfCells()
	return #self.guild_list or 0
end

function ChatGuildView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local chat_cell = self.cell_list[cell]
	if chat_cell == nil then
		chat_cell = ChatCell.New(cell.gameObject)
		self.cell_list[cell] = chat_cell
	end

	chat_cell:SetIndex(data_index)
	local data = self.guild_list[data_index]
	if data.channel_type == CHANNEL_TYPE.GUILD then
		ChatData.Instance:RemoveGuildUnreadMsgByMsgId(data.msg_id)
		ChatData.Instance:RemindGuildUnreadNumChangeCallBack()
		self:RefreshTips()
	end
	chat_cell:SetData(data)
end

function ChatGuildView:GetFallCellSizeDel(data_index)
	local data = {}
	local height = 0
	data = self.fall_event_list_data[data_index + 1]
	if data then
		data.content = GuildData.Instance:GetGuildRareLogText(data)
		height = ChatCtrl.Instance:CaleFallItemHeight(data, data.content)
	end
	return height or 0
end

function ChatGuildView:RefreshFallCell(cell, data_index)
	data_index = data_index + 1
	local icon_cell = self.fall_cell_list[cell]
	if icon_cell == nil then
		icon_cell = FallMessageCell.New(cell.gameObject)
		self.fall_cell_list[cell] = icon_cell
	end
	local data = {}
	data = self.fall_event_list_data[data_index]

	GuildData.Instance:SetFallUnreadMsg(data.timestamp)
	self:RefreshFallTips()

	if data then
		data.content = GuildData.Instance:GetGuildRareLogText(data)
		icon_cell:SetIndex(data_index)
		icon_cell:SetData(data)
		icon_cell:Flush()
	end
end

function ChatGuildView:GetFallNumberOfCells()
	local count = #self.fall_event_list_data
	return count or 0
end

function ChatGuildView:ClickChat()
	if self.channel_type == CHANNEL_TYPE.GUILD then
		return
	end
	self.channel_type = CHANNEL_TYPE.GUILD
	ChatData.Instance:ClearGuildUnreadMsg()
	ChatData.Instance:SetNewLockState(false)
	GuildData.Instance:SetNewFallLockState(false)

	local current_id = ChatData.Instance:GetCurrentId() or 1
	self:FlushGuildView(current_id)
end

function ChatGuildView:ClickSystem()
	if self.channel_type == CHANNEL_TYPE.GUILD_SYSTEM then
		return
	end
	self.channel_type = CHANNEL_TYPE.GUILD_SYSTEM
	ChatData.Instance:SetNewLockState(false)
	GuildData.Instance:SetNewFallLockState(false)

	self:FlushGuildView(3)
end

function ChatGuildView:ClickFallItem()
	if self.channel_type == SPECIAL_CHAT_ID.FALLITEM then
		return
	end
	self.channel_type = SPECIAL_CHAT_ID.FALLITEM
	GuildData.Instance:ClearFallUnreadMsg()
	ChatData.Instance:SetNewLockState(false)
	GuildData.Instance:SetNewFallLockState(false)

	self:FlushGuildView(SPECIAL_CHAT_ID.FALLITEM)
end

function ChatGuildView:ChangeChannelType()
	self.channel_type = CHANNEL_TYPE.GUILD
	self:FlushHighLight()
end

function ChatGuildView:ChangeChannelGuildSystem()
	self.channel_type = CHANNEL_TYPE.GUILD_SYSTEM
	self:FlushHighLight()
end


function ChatGuildView:FlushHighLight()
	if self.channel_type == CHANNEL_TYPE.GUILD then
		self.node_list["LiaoTian"].toggle.isOn = true
		ChatData.Instance:SetCurIsLiaoOrSystem(CHANNEL_TYPE.GUILD)
		GuildData.Instance:SetNewFallLockState(false)
	elseif self.channel_type == CHANNEL_TYPE.GUILD_SYSTEM then
		self.node_list["System"].toggle.isOn = true
		ChatData.Instance:SetCurIsLiaoOrSystem(CHANNEL_TYPE.GUILD_SYSTEM)
		GuildData.Instance:SetNewFallLockState(false)
		ChatData.Instance:SetNewLockState(false)
	elseif self.channel_type == SPECIAL_CHAT_ID.FALLITEM then
		self.node_list["FallItem"].toggle.isOn = true
		ChatData.Instance:SetCurIsLiaoOrSystem(SPECIAL_CHAT_ID.FALLITEM)
		ChatData.Instance:SetNewLockState(false)
	end
end

--收购记录
FallMessageCell = FallMessageCell or BaseClass(BaseCell)

function FallMessageCell:__init()
	
end

function FallMessageCell:__delete()
	
end

function FallMessageCell:OnFlush()
	if self.data == nil then
		return
	end
	if self.node_list["FallItem"] then
		RichTextUtil.ParseRichText(self.node_list["FallItem"].rich_text, self.data.content)
		-- ScoietyCtrl.Instance:SetWaitOperaName(self.data.role_name, self.data.item_id)
	end
end

function FallMessageCell:GetContentHeight()
	if self.node_list["FallItem"] then
		local rect = self.node_list["FallItem"]:GetComponent(typeof(UnityEngine.RectTransform))
		--强制刷新
		UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(rect)
		local des_height = rect.rect.height

		local height = des_height / 8 + des_height
		return height
	end
	return 0
end