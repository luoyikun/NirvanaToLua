ChatFriendView = ChatFriendView or BaseClass(BaseRender)

function ChatFriendView:__init()
	self.cell_list = {}

	self.friend_list = {}

	local delegate = self.node_list["RoleList"].list_simple_delegate
	delegate.NumberOfCellsDel = BindTool.Bind(self.GetFriendNumberOfCells, self)
	delegate.CellRefreshDel = BindTool.Bind(self.RefreshFriendCell, self)

	self.node_list["BtnChat"].button:AddClickListener(BindTool.Bind(self.ClickFind, self))
end

function ChatFriendView:__delete()
	print("ChatFriendView.Release")
	for k, v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}
end

function ChatFriendView:FlushFriendView()
	self.friend_list = ScoietyData.Instance:GetIsOnLineFriendInfo()
	if self.node_list["RoleList"].scroller.isActiveAndEnabled then
		self.node_list["RoleList"].scroller:ReloadData(0)
	end
end

function ChatFriendView:ClickFind()
	local name = self.node_list["InPutField"].input_field.text

	if #self.friend_list <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.NotOnlineFriend)
		return
	end

	if name == "" then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.NotChooseUser)
		return
	end

	for _, v in ipairs(self.friend_list) do
		if name == v.gamename then
			self.friend_list = {}
			table.insert(self.friend_list, v)
			if self.node_list["RoleList"].scroller.isActiveAndEnabled then
				self.node_list["RoleList"].scroller:ReloadData(0)
			end
			return
		end
	end
	SysMsgCtrl.Instance:ErrorRemind(Language.Society.UserNotExist)
end

function ChatFriendView:GetFriendNumberOfCells()
	return #self.friend_list or 0
end

function ChatFriendView:RefreshFriendCell(cell, data_index)
	data_index = data_index + 1
	local role_cell = self.cell_list[cell]
	if role_cell == nil then
		role_cell = ChatFriendCell.New(cell.gameObject)
		role_cell.friend_view = self
		self.cell_list[cell] = role_cell
	end

	role_cell:SetIndex(data_index)
	role_cell:SetData(self.friend_list[data_index])
end

function ChatFriendView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function ChatFriendView:GetSelectIndex()
	return self.select_index or 0
end

--好友列表格子
ChatFriendCell = ChatFriendCell or BaseClass(BaseCell)

function ChatFriendCell:__init()
	self.avatar_key = 0
	self.node_list["BtnSendMsg"].button:AddClickListener(BindTool.Bind(self.SendMsg, self))
end

function ChatFriendCell:__delete()
	self.avatar_key = 0
end

function ChatFriendCell:LoadUserCallBack(user_id, raw_image_obj, path)
	if self:IsNil() then
		return
	end

	if user_id ~= self.data.user_id then
		self.node_list["ImgIcon"]:SetActive(true)
		self.node_list["RawImage"]:SetActive(false)
		return
	end

	if path == nil then
		path = AvatarManager.GetFilePath(self.data.user_id, false)
	end
	raw_image_obj.raw_image:LoadURLSprite(path, function ()
		if user_id ~= self.data.user_id then
			self.node_list["ImgIcon"]:SetActive(true)
			self.node_list["RawImage"]:SetActive(false)
			return
		end
		self.node_list["ImgIcon"]:SetActive(false)
		self.node_list["RawImage"]:SetActive(true)
	end)
end

function ChatFriendCell:OnFlush()
	if not self.data or not next(self.data) then return end

	AvatarManager.Instance:SetAvatar(self.data.user_id, self.node_list["RawImage"], self.node_list["ImgIcon"], self.data.sex, self.data.prof, false)

	self.node_list["TxtName"].text.text = self.data.gamename
	self.node_list["TxtCapability"].text.text = self.data.capability
	local online_txt = ""
	if self.data.is_online == 0 then
		online_txt = Language.Common.OutLine
	else
		online_txt = Language.Common.OnLine
	end
	self.node_list["TxtOnline"].text.text = online_txt
end

function ChatFriendCell:SendMsg()
	if not self.data or not next(self.data) then return end
	-- 判断等级是否足够
	if not ChatData.Instance:IsCanChat(CHAT_OPENLEVEL_LIMIT_TYPE.SINGLE) then
		return
	end
	local private_obj = {}
	if nil == ChatData.Instance:GetPrivateObjByRoleId(self.data.user_id) then
		private_obj = ChatData.CreatePrivateObj()
		private_obj.role_id = self.data.user_id
		private_obj.username = self.data.gamename
		private_obj.sex = self.data.sex
		private_obj.camp = self.data.camp
		private_obj.prof = self.data.prof
		private_obj.avatar_key_small = self.data.avatar_key_small
		private_obj.level = self.data.level
		private_obj.create_time = TimeCtrl.Instance:GetServerTime()
		ChatData.Instance:AddPrivateObj(private_obj.role_id, private_obj)
	end
	ChatData.Instance:SetCurrentId(self.data.user_id)
end