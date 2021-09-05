ChatWorldView = ChatWorldView or BaseClass(BaseRender)

function ChatWorldView:__init()
	self.cell_list = {}
	self.world_list = {}
	self.is_show = true

	local transform = self.root_node.transform:FindHard("ChatList")
	if transform ~= nil then
		self.chat_list_view = U3DObject(transform.gameObject, transform, self)
	end

	local scroller_delegate = self.chat_list_view.list_simple_delegate
	scroller_delegate.CellSizeDel = BindTool.Bind(self.GetCellSizeDel, self)
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.chat_list_view.scroller.scrollerScrolled = function()
		local position = self.chat_list_view.scroller.ScrollPosition
		position = position < 0 and 0 or position
		position = math.floor(position)
		local scroll_size = self.chat_list_view.scroller.ScrollSize
		if scroll_size < 10 then
			return
		end
		if position >= scroll_size then
			ChatCtrl.Instance:ChangeLockState(false)
		else
			ChatCtrl.Instance:ChangeLockState(true)
		end

		if self.is_show then
			self.chat_list_view.scroller:ReloadData(1)
			self.is_show = false
		end
		
	end
end

function ChatWorldView:__delete()
	print("ChatWorldView.Release")
	for k, v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}
end

function ChatWorldView:FlushWorldView()
	local chat_world_list = ChatData.Instance:GetChannel(CHANNEL_TYPE.WORLD) or {}

	local old_world_list_count = self.world_list and #self.world_list or 0
	local msg_list = chat_world_list.msg_list or {}
	self.world_list = msg_list
	local is_lock = ChatData.Instance:GetIsLockState()
	if is_lock and self.world_list and #self.world_list > 0 and old_world_list_count > 0 then
		self.chat_list_view.scroller:RefreshAndReloadActiveCellViews(true)
	else
		self.chat_list_view.scroller:ReloadData(1)
	end
end

function ChatWorldView:FlushUnreadState()
	if self.chat_list_view then
		self.chat_list_view.scroller:ReloadData(1)
	end
end

function ChatWorldView:GetCellSizeDel(data_index)
	data_index = data_index + 1
	local world_list = self.world_list[data_index]
	local height = ChatData.Instance:GetChannelItemHeight(CHANNEL_TYPE.WORLD, world_list.msg_id)
	if height <= 0 then
		height = ChatCtrl.Instance:CaleChatHeight(CHANNEL_TYPE.WORLD, world_list)
	end
	return height
end

function ChatWorldView:GetNumberOfCells()
	return #self.world_list or 0
end

function ChatWorldView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local chat_cell = self.cell_list[cell]
	if chat_cell == nil then
		chat_cell = ChatCell.New(cell.gameObject)
		self.cell_list[cell] = chat_cell
	end

	chat_cell:SetIndex(data_index)
	chat_cell:SetData(self.world_list[data_index])
	chat_cell:SetMainChatFlag()
	ChatData.Instance:RemoveChatChannelUnreadMsgByMsgId(self.world_list[data_index].msg_id, CHANNEL_TYPE.WORLD)
	if self.call_back then
		self.call_back()
	end
end

function ChatWorldView:SetListenerCallBack(call_back)
	self.call_back = call_back
end

