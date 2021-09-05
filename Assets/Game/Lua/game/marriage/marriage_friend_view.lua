MarryFriendListView = MarryFriendListView or BaseClass(BaseView)

function MarryFriendListView:__init()
	self.ui_config = {{"uis/views/marriageview_prefab", "FriendListView"}}
	self.cell_list = {}
	self.is_modal = true
end

function MarryFriendListView:__delete()

end

function MarryFriendListView:ReleaseCallBack()
	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	-- 清理变量和对象
end

function MarryFriendListView:LoadCallBack()

	self.node_list["BgImg"].event_trigger_listener:AddPointerClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["SureBtn"].button:AddClickListener(BindTool.Bind(self.SureOnClick, self))
	-- 生成滚动条
	self.scroller_data = {}
	local scroller_delegate = self.node_list["FriendList"].list_simple_delegate

	--生成数量
	scroller_delegate.NumberOfCellsDel = function()
		return #self.scroller_data or 0
	end
	--刷新函数
	scroller_delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1

		local friend_cell = self.cell_list[cell]
		if friend_cell == nil then
			friend_cell = MarryFriendListCell.New(cell.gameObject)
			friend_cell.root_node.toggle.group = self.node_list["FriendList"].toggle_group
			friend_cell.friend_list_view = self
			self.cell_list[cell] = friend_cell
		end

		friend_cell:SetIndex(data_index)
		friend_cell:SetData(self.scroller_data[data_index])

	end
end

function MarryFriendListView:OpenCallBack()
	self:Flush()
end

function MarryFriendListView:CloseWindow()
	self:Close()
end

function MarryFriendListView:CloseCallBack()
	self.select_index = nil
end

function MarryFriendListView:SetCallBack(callback)
	self.callback = callback
end

function MarryFriendListView:SetSex(sex)
	self.sex = sex
end

function MarryFriendListView:SureOnClick()
	if not self.select_index then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.SelectAddFriendItemTips)
		return
	end
	self.callback(self.select_friend_info)
	self:Close()
end

function MarryFriendListView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function MarryFriendListView:GetSelectIndex()
	return self.select_index or 0
end

function MarryFriendListView:SetSelectFriend(info)
	self.select_friend_info = info
end

function MarryFriendListView:OnFlush()
	self.scroller_data = {}
	if self.sex then
		self.scroller_data = ScoietyData.Instance:GetFriendInfoBySex(self.sex)
	else
		self.scroller_data = ScoietyData.Instance:GetFriendInfo()
	end
	self.node_list["FriendList"].scroller:ReloadData(0)
end

----------------------------------------------------------------------------
--MarryFriendListCell 		好友滚动条格子
----------------------------------------------------------------------------

MarryFriendListCell = MarryFriendListCell or BaseClass(BaseCell)

function MarryFriendListCell:__init()

	self.avatar_key = 0
	self.friend_list_view = nil
	self.node_list["FriendListItem"].toggle:AddClickListener(BindTool.Bind(self.ClickItem, self))
end

function MarryFriendListCell:__delete()
	self.friend_list_view = nil
	self.avatar_key = 0
end

function MarryFriendListCell:LoadUserCallBack(user_id, path)
	if self:IsNil() then
		return
	end

	if user_id ~= self.data.user_id then
		self.node_list["IconImage"]:SetActive(true)
		self.node_list["RawImage"]:SetActive(false)
		return
	end

	if path == nil then
		path = AvatarManager.GetFilePath(user_id, false)
	end
	self.node_list["IconImage"]:SetActive(false)
	self.node_list["RawImage"]:SetActive(true)
	GlobalTimerQuest:AddDelayTimer(function()
		self.node_list["RawImage"].raw_image:LoadSprite(path, function ()
			end)
		end, 0)
end

function MarryFriendListCell:OnFlush()
	if not self.data or not next(self.data) then return end
	AvatarManager.Instance:SetAvatar(self.data.user_id, self.node_list["RawImage"], self.node_list["IconImage"], self.data.sex, self.data.prof, false)

	local prof, grade =	PlayerData.Instance:GetRoleBaseProf(self.data.prof)
	local proftxt = ZhuanZhiData.Instance:GetProfNameCfg(prof, grade) or ""
	self.node_list["LevelTxt"].text.text= PlayerData.GetLevelString(self.data.level)
	self.node_list["NameTxt"].text.text = self.data.gamename
	self.node_list["ProfTxt"].text.text = proftxt

	local intimacy_list = ScoietyData.Instance:GetIntimacyCfg()
	local intimacy_lev = 0
	for k, v in ipairs(intimacy_list) do
		if self.data.intimacy >= v.need_intimacy then
			intimacy_lev = v.level
		end
	end
	self.node_list["ImyLevTxt"].text.text = string.format("Lv.%s", intimacy_lev)
	self.node_list["IntimacyTxt"].text.text = self.data.intimacy
	if self.data.is_online == 1 then
		UI:SetGraphicGrey(self.node_list["IconImage"], false)
		UI:SetGraphicGrey(self.node_list["RawImage"], false)
		UI:SetGraphicGrey(self.node_list["NameTxt"], false)
		UI:SetGraphicGrey(self.node_list["ProfTxt"], false)
		UI:SetGraphicGrey(self.node_list["LevelTxt"], false)
		local is_on = false
		local color = is_on and Color(0.3764706, 0.5960785, 0.7960784, 1) or Color(0.5, 0.5, 0.5, 1)
		self.node_list["ImyLevTxt"].graphic.color = color
		UI:SetGraphicGrey(self.node_list["IntimacyTxt"], false)
	else
		UI:SetGraphicGrey(self.node_list["IconImage"], true)
		UI:SetGraphicGrey(self.node_list["RawImage"], true)
		UI:SetGraphicGrey(self.node_list["NameTxt"], true)
		UI:SetGraphicGrey(self.node_list["ProfTxt"], true)
		UI:SetGraphicGrey(self.node_list["LevelTxt"], true)
		local is_on = true
		local color = is_on and Color(0.3764706, 0.5960785, 0.7960784, 1) or Color(0.5, 0.5, 0.5, 1)
		self.node_list["ImyLevTxt"].graphic.color = color
		UI:SetGraphicGrey(self.node_list["IntimacyTxt"], true)
	end

	-- 刷新选中特效
	local select_index = self.friend_list_view:GetSelectIndex()
	if self.root_node.toggle.isOn and select_index ~= self.index then
		self.root_node.toggle.isOn = false
	elseif self.root_node.toggle.isOn == false and select_index == self.index then
		self.root_node.toggle.isOn = true
	end
end

function MarryFriendListCell:ClickItem()
	if self.data.is_online ~= 1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.OnlineLimitDes)
		self.node_list["FriendListItem"].toggle.isOn = false
		return
	end
	self.root_node.toggle.isOn = true
	self.friend_list_view:SetSelectIndex(self.index)
	self.friend_list_view:SetSelectFriend(self.data)
end