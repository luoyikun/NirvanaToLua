InviteView = InviteView or BaseClass(BaseView)
function InviteView:__init()
	self.ui_config = {{"uis/views/scoietyview_prefab", "InviteList"}}
	self.cell_list = {}
	self.is_modal = true
	self.is_any_click_close = true
end

function InviteView:__delete()

end

function InviteView:ReleaseCallBack()
	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	-- 清理变量和对象
	self.title = nil
	self.scroller = nil
end

function InviteView:LoadCallBack()

	self.node_list["BtnBlock"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnInvite"].button:AddClickListener(BindTool.Bind(self.ClickInvite, self))
		-- 生成滚动条
	self.scroller_data = {}
	local scroller_delegate = self.node_list["ListView"].list_simple_delegate

	--生成数量
	scroller_delegate.NumberOfCellsDel = function()
		return #self.scroller_data or 0
	end
	--刷新函数
	scroller_delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1

		local invite_cell = self.cell_list[cell]
		if invite_cell == nil then
			invite_cell = ScrollerInviteCell.New(cell.gameObject)
			invite_cell.root_node.toggle.group = self.node_list["ListView"].toggle_group
			invite_cell.invite_view = self
			self.cell_list[cell] = invite_cell
		end

		invite_cell:SetIndex(data_index)
		invite_cell:SetData(self.scroller_data[data_index])
	end
end

function InviteView:OpenCallBack()
	self:ChangeInviteView()
end

function InviteView:ChangeInviteView()
	self.scroller_data = {}
	local invite_type = ScoietyData.Instance:GetInviteType()
	if invite_type == ScoietyData.InviteType.FriendType then
		local friend_info = ScoietyData.Instance:GetIsOnLineFriendInfo()
		self.scroller_data = friend_info
		self.node_list["TitleText"].text.text = Language.Society.FriendInviety
	elseif invite_type == ScoietyData.InviteType.GuildType then
		self.scroller_data = {}
		self.node_list["TitleText"].text.text = Language.Society.BanPaiInviety
	elseif invite_type == ScoietyData.InviteType.WorldType then
		self.scroller_data = {}
		self.node_list["TitleText"].text.text = Language.Society.WorldInviety
	elseif invite_type == ScoietyData.InviteType.NearType then
		local near_info = Scene.Instance:GetRoleList()
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		for k, v in pairs(near_info) do
			if IS_ON_CROSSSERVER then
				if v.vo and v.vo.merge_server_id == main_vo.merge_server_id then
					table.insert(self.scroller_data, v.vo)
				end
			else
				table.insert(self.scroller_data, v.vo)
			end
		end
		self.node_list["TitleText"].text.text = Language.Society.NearInviety
	end
	self.select_index = nil
	self.node_list["ListView"].scroller:ReloadData(0)
end

function InviteView:CloseWindow()
	self:Close()
end

function InviteView:CloseCallBack()
	self.select_index = nil
end

function InviteView:ClickInvite()
	if self.select_index == nil then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.SelectAddFriendItemTips)
		return
	end
	ScoietyCtrl.Instance:InviteUserReq(self.role_id)
	self:Close()
end

function InviteView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function InviteView:GetSelectIndex()
	return self.select_index or 0
end

function InviteView:SetRoleId(id)
	self.role_id = id
end

----------------------------------------------------------------------------
--ScrollerInviteCell 		邀请列表滚动条格子
----------------------------------------------------------------------------

ScrollerInviteCell = ScrollerInviteCell or BaseClass(BaseCell)

function ScrollerInviteCell:__init()

	self.node_list["InviteListItem"].toggle:AddClickListener(BindTool.Bind(self.ClickItem, self))
end

function ScrollerInviteCell:__delete()
	self.invite_view = nil
	self.data = nil
end

function ScrollerInviteCell:OnFlush()
	if not self.data or not next(self.data) then return end

	self.role_id = self.data.user_id or self.data.role_id
	AvatarManager.Instance:SetAvatar(self.role_id, self.node_list["RawImage"], self.node_list["RoleImage"], self.data.sex, self.data.prof, false)

	-- local lv, zhuan = PlayerData.GetLevelAndRebirth(self.data.level)
	-- local level_des = string.format(Language.Common.LevelFormat, lv, zhuan)
	self.node_list["LevelTxt"].text.text = PlayerData.GetLevelString(self.data.level)
	self.node_list["NameTxt"].text.text = self.data.gamename or self.data.name
	self.node_list["ProfTxt"].text.text = PlayerData.GetProfNameByType(self.data.prof)

	-- 刷新选中特效
	local select_index = self.invite_view:GetSelectIndex()
	if self.root_node.toggle.isOn and select_index ~= self.index then
		self.root_node.toggle.isOn = false
	elseif self.root_node.toggle.isOn == false and select_index == self.index then
		self.root_node.toggle.isOn = true
	end
end

function ScrollerInviteCell:ClickItem()
	self.invite_view:SetSelectIndex(self.index)
	self.invite_view:SetRoleId(self.role_id)
end