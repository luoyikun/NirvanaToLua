GuildApplyView = GuildApplyView or BaseClass(BaseView)

function GuildApplyView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/guildview_prefab", "GuildApplyView"},
	}
	self.is_modal = true
	self.is_any_click_close = true
end

function GuildApplyView:__delete()
	
end

function GuildApplyView:LoadCallBack()
	self.node_list["ButtonAllConsent"].button:AddClickListener(BindTool.Bind(self.OnAllConsent, self))
	self.node_list["ButtonAllrRefuse"].button:AddClickListener(BindTool.Bind(self.OnAllRefuse, self))

	-- self.node_list["ButtonClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))

	self.node_list["Txt"].text.text = Language.Guild.GuildApply
	self.node_list["Bg"].rect.sizeDelta = Vector3(1001, 630, 0)

	self.cell_list = {}
	self:InitScroller()
end

function GuildApplyView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	self.list_view_delegate = nil
	self.enhanced_cell_type = nil
	self.async_loader = nil

end

function GuildApplyView:OpenCallBack()
	GuildCtrl.Instance:SendGuildApplyListReq()
end

function GuildApplyView:OnFlush()
	self:FlushApply()
end

function GuildApplyView:OnClickClose()
	self:Close()
end

-- 同意所有人加入公会
function GuildApplyView:OnAllConsent()
	local uid = {}
	local list = GuildDataConst.GUILD_APPLYFOR_LIST.list
	for i = 1, #list do
		uid[i] = list[i].uid
	end
	if #uid > 0 then
		local describe = Language.Guild.PassAll
		local yes_func = function() GuildCtrl.Instance:SendGuildApplyforJoinReq(GuildDataConst.GUILDVO.guild_id, 0, #uid, uid)
		self:Close() end
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoApply)
	end
end

-- 拒绝所有人加入公会
function GuildApplyView:OnAllRefuse()
	local uid = {}
	local list = GuildDataConst.GUILD_APPLYFOR_LIST.list
	for i = 1, #list do
		uid[i] = list[i].uid
	end
	if #uid > 0 then
		local describe = Language.Guild.RefuseAll
		local yes_func = function() GuildCtrl.Instance:SendGuildApplyforJoinReq(GuildDataConst.GUILDVO.guild_id, 1, #uid, uid)
		self:Close() end
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoApply)
	end
end

-- 同意加入公会
function GuildApplyView:OnConsent(index)
	local uid = GuildDataConst.GUILD_APPLYFOR_LIST.list[index].uid
	if uid then
		GuildCtrl.Instance:SendGuildApplyforJoinReq(GuildDataConst.GUILDVO.guild_id, 0, 1, {uid})
	end
	self.apply_click = true
end

-- 拒绝加入公会
function GuildApplyView:OnRefuse(index)
	local uid = GuildDataConst.GUILD_APPLYFOR_LIST.list[index].uid
	if uid then
		GuildCtrl.Instance:SendGuildApplyforJoinReq(GuildDataConst.GUILDVO.guild_id, 1, 1, {uid})
	end
	self.apply_click = true
end

-- 刷新公会申请列表
function GuildApplyView:FlushApply()
	if self.node_list["Scroller"].scroller.isActiveAndEnabled then
		self.node_list["Scroller"].scroller:RefreshAndReloadActiveCellViews(true)
	end
	if self.apply_click then
		self.apply_click = false
		if GuildDataConst.GUILD_APPLYFOR_LIST.count <= 0 then
			self:Close()
		end
	end
end

-- 初始化申请列表
function GuildApplyView:InitScroller()
	self.list_view_delegate = ListViewDelegate()

	local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader")
	res_async_loader:Load("uis/views/guildview_prefab", "Info", nil, function (obj)
		if nil == obj then
			return
		end
		local enhanced_cell_type = obj:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))
		
		self.enhanced_cell_type = enhanced_cell_type
		self.node_list["Scroller"].scroller.Delegate = self.list_view_delegate

		self.list_view_delegate.numberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
		self.list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
		self.list_view_delegate.cellViewDel = BindTool.Bind(self.GetCellView, self)
	end)
end

--滚动条数量
function GuildApplyView:GetNumberOfCells()
	return GuildDataConst.GUILD_APPLYFOR_LIST.count
end

--滚动条大小 50
function GuildApplyView:GetCellSize(data_index)
	return 50
end

--滚动条刷新
function GuildApplyView:GetCellView(scroller, data_index, cell_index)
	local cell_view = scroller:GetCellView(self.enhanced_cell_type)

	local cell = self.cell_list[cell_view]
	if cell == nil then
		self.cell_list[cell_view] = GuildInfoViewScrollCell.New(cell_view)
		cell = self.cell_list[cell_view]
		cell.info_view = self
		cell:ListenAllEvent()
	end
	cell:SetData(data_index)
	return cell_view
end

---------------------------------------------GuildInfoViewScrollCell-------------------------------------------
GuildInfoViewScrollCell = GuildInfoViewScrollCell or BaseClass(BaseCell)

function GuildInfoViewScrollCell:__init()
	self.root_node.list_cell.refreshCell = BindTool.Bind(self.Flush, self)

end

function GuildInfoViewScrollCell:__delete()
	self.info_view = nil
end

function GuildInfoViewScrollCell:ListenAllEvent()
	self.node_list["ButtonConsent"].button:AddClickListener(function() self.info_view:OnConsent(self.data + 1) end)
	self.node_list["ButtonRefuse"].button:AddClickListener(function() self.info_view:OnRefuse(self.data + 1) end)

end

function GuildInfoViewScrollCell:Flush()
	local info = GuildDataConst.GUILD_APPLYFOR_LIST.list[self.data + 1]
	if info then
		local prof, grade = PlayerData.Instance:GetRoleBaseProf(info.prof)
		self.node_list["Name"].text.text = info.role_name		--ToColorStr(info.role_name, PROF_COLOR[prof])
		self.node_list["Job"].text.text = ZhuanZhiData.Instance:GetProfNameCfg(prof, grade)
		-- local lv, zhuan = PlayerData.GetLevelAndRebirth(info.level)
		-- self.node_list["Level"].text.text = string.format(Language.Common.ZhuanShneng, lv, zhuan)
		self.node_list["Level"].text.text = PlayerData.GetLevelString(info.level)
		self.node_list["FightPower"].text.text = info.capability
		if info.vip_level > 0 then
			self.node_list["VipImage"]:SetActive(false)
		else
			self.node_list["VipImage"]:SetActive(false)
		end
	end
end
