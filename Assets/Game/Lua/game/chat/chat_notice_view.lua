ChatNoticeView = ChatNoticeView or BaseClass(BaseView)

function ChatNoticeView:__init()
	self.ui_config = {{"uis/views/chatview_prefab", "ChatNoticeView"}}
	self.view_layer = UiLayer.Pop
	self.chat_type = QUICK_CHAT_TYPE.NORMAL
	self.is_modal = true
	self.is_any_click_close = true
end

function ChatNoticeView:__delete()

end

function ChatNoticeView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.cell_list = {}

	self.list_data = {}

	self.list_view_delegate = self.node_list["Scroller"].list_simple_delegate
	self.list_view_delegate.CellSizeDel = BindTool.Bind(self.GetCellSizeDel, self)
	self.list_view_delegate.NumberOfCellsDel = function() return #self.list_data end
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

function ChatNoticeView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.list_view_delegate = nil
	self.scroller = nil
	self.call_back = nil
end

function ChatNoticeView:OpenCallBack()
	self.list_data = {}
	self.list_data = ChatData.Instance:GetHistoryMsgList()
	-- if self.chat_type == QUICK_CHAT_TYPE.NORMAL then
		-- self.list_data = Language.Chat.QuickChatList
	-- elseif self.chat_type == QUICK_CHAT_TYPE.GUILD then
		-- self.list_data = Language.Chat.QuickGuildChatList
	-- end

	self.node_list["Scroller"].scroller:ReloadData(0)
end

function ChatNoticeView:CloseCallBack()

end

function ChatNoticeView:SetQuickType(chat_type)
	self.chat_type = chat_type
end

function ChatNoticeView:SetCallBack(call_back)
	self.call_back = call_back
end

function ChatNoticeView:GetCellSizeDel(data_index)
	local data = {}
	local height = 0
	data.content = self.list_data[data_index + 1] or ""
	height = ChatCtrl.Instance:CalePurchaseHeight(data, data.content)
	return height or 0
end

function ChatNoticeView:RefreshView(cell, data_index)
	local chat_cell = self.cell_list[cell]
	if chat_cell == nil then
		chat_cell = QuickChatCell.New(cell.gameObject)
		chat_cell:SetClickCallBack(BindTool.Bind(self.ClickCell, self))
		self.cell_list[cell] = chat_cell
	end
	local data = self.list_data[data_index + 1] or ""
	chat_cell:SetData(data)
end

function ChatNoticeView:ClickCell(cell)
	if self.chat_type == QUICK_CHAT_TYPE.NORMAL then
		-- if ChatData.Instance:GetChannelCdIsEnd(CHANNEL_TYPE.WORLD) then
			local str = cell.data or ""
			if self.call_back then
				self.call_back(str)
			end
			self:Close()
		-- else
		-- 	SysMsgCtrl.Instance:ErrorRemind(Language.Chat.WorldChatCD)
		-- end
	elseif self.chat_type == QUICK_CHAT_TYPE.GUILD then
		local str = cell.data or ""
		ChatData.Instance:AddToHistoryMsgList(str)
		ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, str, CHAT_CONTENT_TYPE.TEXT)
		self:Close()
	end
end

--------------------------------------QuickChatCell------------------------------------------

QuickChatCell = QuickChatCell or BaseClass(BaseCell)

function QuickChatCell:__init()
	self.node_list["QuickChatCell"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function QuickChatCell:__delete()

end

function QuickChatCell:OnFlush()
	RichTextUtil.ParseRichText(self.node_list["RichText"].rich_text, self.data or "")
	local data = {}
	data.content = self.data or ""
	local height = ChatCtrl.Instance:CalePurchaseHeight(data, data.content)
	self.node_list["Line"].transform.localPosition = Vector3(0, 0 - (height / 2), 0)
end