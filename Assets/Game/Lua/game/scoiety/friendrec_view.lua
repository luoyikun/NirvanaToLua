FriendRandomView = FriendRandomView or BaseClass(BaseView)

function FriendRandomView:__init()
	self.ui_config = {{"uis/views/scoietyview_prefab", "FriendRecList"}}
	self.cell_list = {}
	self.is_modal = true
	self.is_any_click_close = true
end

function FriendRandomView:__delete()

end

function FriendRandomView:ReleaseCallBack()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.FriendRec)
	end

	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	--清除变量
	self.friend_rec_auto_add = nil
	self.scroller = nil
end

function FriendRandomView:LoadCallBack()

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["AutoAdd"].button:AddClickListener(BindTool.Bind(self.AutoAdd, self))
	self.node_list["BtnRefresh"].button:AddClickListener(BindTool.Bind(self.Refresh, self))
	--引导用按钮
	self.friend_rec_auto_add = self.node_list["AutoAdd"]
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
			friend_cell = FriendRecCell.New(cell.gameObject)
			self.cell_list[cell] = friend_cell
		end

		friend_cell:SetIndex(data_index)
		friend_cell:SetData(self.scroller_data[data_index])
	end

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.FriendRec, BindTool.Bind(self.GetUiCallBack, self))
end

function FriendRandomView:CloseWindow()
	self:Close()
end

function FriendRandomView:OpenCallBack()
	self:Flush()
end

function FriendRandomView:AutoAdd()
	local random_list = ScoietyData.Instance:GetRandomRoleList()
	for k,v in ipairs(random_list) do
		if v.is_select then
			ScoietyCtrl.Instance:AddFriendReq(v.user_id, 1)
		end
	end
	self:CloseWindow()
	SysMsgCtrl.Instance:ErrorRemind(Language.Society.AddFriendRec)
end

function FriendRandomView:Refresh()
	ScoietyCtrl.Instance:RandomRoleListReq()
end

function FriendRandomView:OnFlush()
	self.scroller_data = ScoietyData.Instance:GetRandomRoleList()
	self.node_list["FriendList"].scroller:ReloadData(0)
end

function FriendRandomView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end

----------------------------------------------------------------------------
--FriendRecCell 		好友推荐滚动条格子
----------------------------------------------------------------------------

FriendRecCell = FriendRecCell or BaseClass(BaseCell)

function FriendRecCell:__init()
	self.node_list["CheckSelect"].toggle:AddValueChangedListener(BindTool.Bind(self.ClickSelect, self))
end

function FriendRecCell:__delete()
	
end

function FriendRecCell:OnFlush()
	if not self.data or not next(self.data) then return end
	-- self.data.is_select = self.node_list["CheckSelect"].toggle.isOn
	self.node_list["CheckSelect"].toggle.isOn = self.data.is_select
	AvatarManager.Instance:SetAvatar(self.data.user_id, self.node_list["RawImage"], self.node_list["RoleImage"], self.data.sex, self.data.prof, false)

	-- local lv, zhuan = PlayerData.GetLevelAndRebirth(self.data.level)
	-- local level_des = string.format(Language.Common.LevelFormat, lv, zhuan)
	self.node_list["LevelTxt"].text.text = PlayerData.GetLevelString(self.data.level)
	self.node_list["NameTxt"].text.text = self.data.gamename
	self.node_list["ProfTxt"].text.text = PlayerData.GetProfNameByType(self.data.prof)

end

function FriendRecCell:ClickSelect(ison)
	if ison then
		self.data.is_select = true
	else
		self.data.is_select = false
	end
end