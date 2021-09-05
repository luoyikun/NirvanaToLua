GuildInviteView = GuildInviteView or BaseClass(BaseView)

function GuildInviteView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel_1"},
		{"uis/views/guildview_prefab", "InviteView"},
		{"uis/views/commonwidgets_prefab", "BaseThreePanel_2"},
	}
	self.is_modal = true
	self.is_any_click_close = true
end

-- 打开操作面板
function GuildInviteView:LoadCallBack()
	self.invite_cell_list = {}
	self:GetInfoList()
	self.node_list["Txt"].text.text = Language.Guild.InviteCDTime
	self.node_list["Bg"].rect.sizeDelta = Vector3(791,540,0)
	self.node_list["Bg1"].rect.sizeDelta = Vector3(791,540,0)

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))

	self.list_view_delegate = self.node_list["Scroller"].list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetListCellNum, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function GuildInviteView:__delate()

end

function GuildInviteView:ReleaseCallBack()
	for k,v in pairs(self.invite_cell_list) do
		v:DeleteMe()
	end
	self.invite_cell_list = {}
	self.list_view_delegate = nil
	self.info_list = {}
end

function GuildInviteView:GetListCellNum()
	return #self.info_list
end

function GuildInviteView:RefreshCell(cell, data_index)
	local index = data_index + 1
	local invite_cell = self.invite_cell_list[cell]
	if invite_cell == nil then
		invite_cell = GuildInviteViewScrollCell.New(cell.gameObject)
		self.invite_cell_list[cell] = invite_cell
	end
	invite_cell:SetData(self.info_list[index])
	invite_cell:SetCallBack(self.callback)
	invite_cell:SetInviteCallBack(BindTool.Bind(self.Close, self))
end

function GuildInviteView:SetCallBack(callback)
	self.callback = callback
end

function GuildInviteView:OpenCallBack()
	self:GetInfoList()
	self:Flush()
end

function GuildInviteView:OnFlush()
	
	if self.node_list["Scroller"].scroller.isActiveAndEnabled then
		self.node_list["Scroller"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function GuildInviteView:GetInfoList()
	self.info_list = {}
	for k, v in pairs(GuildDataConst.GUILD_MEMBER_LIST.list or {}) do
		if v.is_online == 1 then
			if v.uid ~= GameVoManager.Instance:GetMainRoleVo().role_id then
				table.insert(self.info_list, v)
			end
		end
	end
end

--------------------------------------------------------------AssistCell---------------------------------------------------------
GuildInviteViewScrollCell = GuildInviteViewScrollCell or BaseClass(BaseCell)

function GuildInviteViewScrollCell:__init()
	self.callback = nil
	self.data = nil
	self.close_callback = nil
end

function GuildInviteViewScrollCell:__delete()
	self.callback = nil
	self.close_callback = nil
end

function GuildInviteViewScrollCell:Flush()
	if self.data == nil then return end
	self.node_list["Name"].text.text = self.data.role_name
	self.node_list["Post"].text.text = GuildData.Instance:GetGuildPostNameByPostId(self.data.post)
	self.node_list["ButtonHelp"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function GuildInviteViewScrollCell:OnClick()
	if self.data == nil then return end
	if self.callback then
		self.callback(self.data.uid)
	end
	if self.close_callback() then
		self.close_callback()
	end
end

function GuildInviteViewScrollCell:SetCallBack(callback)
	self.callback = callback
end

function GuildInviteViewScrollCell:SetInviteCallBack(callback)
	self.close_callback = callback
end