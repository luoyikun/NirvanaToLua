require("game/chat/chat_friend_view")
ChatPrivateView = ChatPrivateView or BaseClass(BaseRender)

function ChatPrivateView:__init()
	self.select_index = 0
	self.cell_list = {}
	self.role_cell_list = {}

	self.private_list = {}
	self.role_list = {}
	
	local scroller_delegate = self.node_list["CharList"].list_simple_delegate
	scroller_delegate.CellSizeDel = BindTool.Bind(self.GetCellSizeDel, self)
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	local delegate = self.node_list["LeftRoleList"].list_simple_delegate
	delegate.NumberOfCellsDel = BindTool.Bind(self.GetRoleNumberOfCells, self)
	delegate.CellRefreshDel = BindTool.Bind(self.RefreshRoleCell, self)

	self.friend_view = ChatFriendView.New(self.node_list["FindFriendList"])

	self.node_list["TabChat"].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, 1))
	self.node_list["TabFriendList"].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, 2))

	self.node_list["CharList"].scroller.scrollerScrolled = function()
		local position = self.node_list["CharList"].scroller.ScrollPosition
		position = position < 0 and 0 or position
		position = math.floor(position)
		local scroll_size = self.node_list["CharList"].scroller.ScrollSize
		if scroll_size < 10 then
			return
		end
		if position >= scroll_size then
			ChatCtrl.Instance:ChangeLockState(false)
		else
			ChatCtrl.Instance:ChangeLockState(true)
		end
	end
end

function ChatPrivateView:__delete()
	print("ChatPrivateView.Release")
	if self.friend_view then
		self.friend_view:DeleteMe()
		self.friend_view = nil
	end

	for k, v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	for k, v in pairs(self.role_cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.role_cell_list = {}
	self.select_index = 0
end

function ChatPrivateView:OnToggleChange(index, ison)
	if ison then
		if index == 1 then
			self.node_list["TopTitle"].transform.localPosition = self.node_list["TopTitle"].transform.localPosition
			ChatData.Instance:SetHavePriviteChat(false)
			self:SetPriviteRedPoint(false)
			ChatCtrl.Instance.view:SetPriviteRedVisible()
			self:FlushPrivateView()
		else
			self.node_list["TopTitle"].transform.localPosition = Vector3(0, self.node_list["TopTitle"].transform.localPosition.y, self.node_list["TopTitle"].transform.localPosition.z)
			self:FlushFriendView()
		end
	end
end

function ChatPrivateView:SetPriviteRedPoint(state)
	if state then
		if self.node_list["TabFriendList"].toggle.isOn then
			self.node_list["ImgPriviteRed"]:SetActive(true)
		else
			self.node_list["ImgPriviteRed"]:SetActive(false)
		end
	else
		self.node_list["ImgPriviteRed"]:SetActive(false)
	end
end

function ChatPrivateView:SetSelectIndex(index)
	self.select_index = index
end

function ChatPrivateView:ChangePriviteTab(tab_index)
	if tab_index == 1 then
		if self.node_list["TabChat"].toggle.isOn then
			ChatData.Instance:SetHavePriviteChat(false)
			self:SetPriviteRedPoint(false)
			ChatCtrl.Instance.view:SetPriviteRedVisible()
			self:FlushPrivateView()
		else
			self.node_list["TabChat"].toggle.isOn = true
		end
	else
		if self.node_list["TabFriendList"].toggle.isOn then
			self:FlushFriendView()
		else
			self.node_list["TabFriendList"].toggle.isOn = true
		end
	end
end

function ChatPrivateView:FlushView(index)
	if index == 1 then
		if self.node_list["TabChat"].toggle.isOn then
			ChatData.Instance:SetHavePriviteChat(false)
			self:FlushPrivateView()
		end
	else
		if self.node_list["TabFriendList"].toggle.isOn then
			self:FlushFriendView()
		end
	end
end

function ChatPrivateView:FlushPrivateView()

end

function ChatPrivateView:FlushMsgList(data)
	self.private_list = data
	if self.node_list["CharList"].scroller.isActiveAndEnabled then
		local is_lock = ChatData.Instance:GetIsLockState()
		if is_lock then
			self.node_list["CharList"].scroller:RefreshAndReloadActiveCellViews(true)
		else
			self.node_list["CharList"].scroller:ReloadData(1)
		end
	end

end

function ChatPrivateView:FlushFriendView()
	if not IsNil(self.friend_view.root_node.gameObject) then
		self.friend_view:FlushFriendView()
	end
end

function ChatPrivateView:GetCellSizeDel(data_index)
	data_index = data_index + 1
	local private_list = self.private_list[data_index]
	local height = ChatData.Instance:GetChannelItemHeight(CHANNEL_TYPE.PRIVATE, private_list.msg_id)
	if height <= 0 then
		height = ChatCtrl.Instance:CaleChatHeight(CHANNEL_TYPE.PRIVATE, private_list)
	end
	return height
end

function ChatPrivateView:GetNumberOfCells()
	return #self.private_list or 0
end

function ChatPrivateView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local chat_cell = self.cell_list[cell]
	if chat_cell == nil then
		chat_cell = ChatCell.New(cell.gameObject)
		self.cell_list[cell] = chat_cell
	end

	chat_cell:SetIndex(data_index)
	chat_cell:SetData(self.private_list[data_index])
end


function ChatPrivateView:GetRoleNumberOfCells()
	return #self.role_list or 0
end

function ChatPrivateView:RefreshRoleCell(cell, data_index)
	data_index = data_index + 1
	local role_cell = self.role_cell_list[cell]
	if role_cell == nil then
		role_cell = LeftRoleCell.New(cell.gameObject)
		role_cell.root_node.toggle.group = self.node_list["LeftRoleList"].toggle_group
		role_cell.private_view = self
		self.role_cell_list[cell] = role_cell
	end

	role_cell:SetIndex(data_index)
	role_cell:SetData(self.role_list[data_index])
end

function ChatPrivateView:RefreshSelect(role_id)
	if not role_id then
		return
	end
	for k, v in pairs(self.role_cell_list) do
		if v then
			local data = v:GetData()
			if data and next(data) then
				if data.role_id == role_id then
					v:ClickItem()
				end
			end
		end
	end
end

function ChatPrivateView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function ChatPrivateView:GetSelectIndex()
	return self.select_index or 0
end

--人物列表格子
LeftRoleCell = LeftRoleCell or BaseClass(BaseCell)

function LeftRoleCell:__init()
	self.avatar_key = 0

	self.node_list["RoleSelectItem"].button:AddClickListener(BindTool.Bind(self.ClickItem, self))
	self.node_list["No"].button:AddClickListener(BindTool.Bind(self.ClickDelete, self))
end

function LeftRoleCell:__delete()
	self.avatar_key = 0
end

function LeftRoleCell:OnFlush()
	if not self.data or not next(self.data) then return end

	self.node_list["TxtName"].text.text = self.data.username
	self.node_list["TxtLev"].text.text = self.data.level

	AvatarManager.Instance:SetAvatar(self.data.role_id, self.node_list["RawImage"], self.node_list["IconImage"], self.data.sex, self.data.prof, false)
	
	-- 有未读消息显示红点
	if self.data.unread_num > 0 then
		self.node_list["RedPoint"]:SetActive(true)
	else
		self.node_list["RedPoint"]:SetActive(false)
	end

	-- 刷新选中特效
	local select_index = self.private_view:GetSelectIndex()
	if self.root_node.toggle.isOn and select_index ~= self.index then
		self.root_node.toggle.isOn = false
	elseif self.root_node.toggle.isOn == false and select_index == self.index then
		self.root_node.toggle.isOn = true
	end
end

function LeftRoleCell:ClickItem()

end

function LeftRoleCell:ClickDelete()
	local cur_role_id = ChatData.Instance:GetCurrentRoleId()
	if cur_role_id == self.data.role_id then
		--清除选中
		self.private_view:SetSelectIndex(0)
		ChatData.Instance:SetCurrentRoleId(0)
	end

	--清除私聊对象
	local index = ChatData.Instance:GetPrivateIndex(self.data.role_id)
	ChatData.Instance:RemovePrivateObjByIndex(index)
	self.private_view:FlushPrivateView()
	self.private_view:FlushMsgList({})
end