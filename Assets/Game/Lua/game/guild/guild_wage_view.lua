GuildWageView = GuildWageView or BaseClass(BaseView)
local ROW = 5 				--暂定5行
function GuildWageView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel"},
		{"uis/views/guildview_prefab", "GuildWageView"}
	}

	self.play_audio = true
	-- self.view_layer = UiLayer.Pop
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function GuildWageView:LoadCallBack()
	self.node_list["TitleText"].text.text = Language.Guild.GuildWage
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["BtnSend"].button:AddClickListener(BindTool.Bind(self.OnClickSend, self))
	self.select_index = -1
	self.cell_list = {}
	self.guild_wage_info = {}
	local list_view_delegate = self.node_list["List"].list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

function GuildWageView:ReleaseCallBack()
	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			if v then
				v:DeleteMe()
			end
		end
	end
	self.cell_list = nil
end

function GuildWageView:CloseCallBack()
	self.select_index = -1
end

function GuildWageView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(328)
end

function GuildWageView:OnClickSend()
	local func = function()
		GuildCtrl.Instance:SendGuildFetchRewardReq(GUILD_COMMON_REQ_TYPE.GUILD_COMMON_REQ_TYPE_GIVE_GONGZI)
	end
	local des = ""
	if GuildDataConst.GUILDVO.cur_member_count < 20 then
		des = Language.Guild.IsSendGuildWage2
	else
		des = Language.Guild.IsSendGuildWage
	end
	TipsCtrl.Instance:ShowCommonAutoView("", des, func)
end

function GuildWageView:OpenCallBack()
	GuildCtrl.Instance:SendGuildInfoReq()
	GuildCtrl.Instance:SendGuildWageInfoReq()
	self:Flush()
end

function GuildWageView:GetNumberOfCells()
	if self.guild_wage_info and #self.guild_wage_info > 0 then
		return #self.guild_wage_info
	end
	return 0
end

function GuildWageView:RefreshView(cell, data_index)
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = GuildWageMenberCell.New(cell.gameObject) --实例化item
		self.cell_list[cell] = group_cell
		self.cell_list[cell]:SetParentView(self)
		self.cell_list[cell].root_node.toggle.group = self.node_list["List"].toggle_group
	end

	local data = self.guild_wage_info[data_index + 1]
	if data then
		group_cell:SetIndex(data_index)
		group_cell:SetData(data)
	end
end

function GuildWageView:OnFlush()
	self.guild_wage_info = GuildData.Instance:GetGuildGongZiRankList()
	local total_wage = GuildData.Instance:GetGuildTotalWage()
	self.node_list["TxtTotalWage"].text.text = string.format(Language.Guild.TotalGuildWage, total_wage)

	local need_wage = GuildData.Instance:GetGuildNeedWage()
	self.node_list["TxtNeedWage"].text.text = string.format(Language.Guild.ReachGuildWage, need_wage)

	UI:SetButtonEnabled(self.node_list["BtnSend"], total_wage >= need_wage)
	local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
	local is_tuanzhan = mainrole_vo.guild_post == GuildDataConst.GUILD_POST.TUANGZHANG
	self.node_list["BtnSend"]:SetActive(is_tuanzhan)
	self.node_list["RedPoint"]:SetActive(is_tuanzhan and total_wage >= need_wage)

	if self.node_list["List"] and self.node_list["List"].scroller and self.node_list["List"].scroller.isActiveAndEnabled then
		self.node_list["List"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function GuildWageView:SetSelectIndex(index)
	self.select_index = index
	self:FlushLeftList()
end

function GuildWageView:FlushLeftList()
	for k,v in pairs(self.cell_list) do
		v:FlushIsSelected(self.select_index)
	end
end


function GuildWageView:OnClickClose()
	self:Close()
end

GuildWageMenberCell = GuildWageMenberCell or BaseClass(BaseCell)
function GuildWageMenberCell:__init()
	self.parent_view = nil
	self.node_list["MemberInfo"].toggle:AddClickListener(BindTool.Bind(self.OnClickCell, self))
end

function GuildWageMenberCell:__delete()
	self.parent_view = nil
end

function GuildWageMenberCell:OnClickCell()
	if nil == self.data then
		return
	end
	if self.parent_view then
		self.parent_view:SetSelectIndex(self.index)
	end
	if self.data.uid ~= GameVoManager.Instance:GetMainRoleVo().role_id then
		local info = GuildData.Instance:GetGuildMemberInfo()
		if info then
			local detail_type = ScoietyData.DetailType.Default
			if info.post == GuildDataConst.GUILD_POST.TUANGZHANG then
				detail_type = ScoietyData.DetailType.GuildTuanZhang
			elseif info.post == GuildDataConst.GUILD_POST.FU_TUANGZHANG or info.post == GuildDataConst.GUILD_POST.ZHANG_LAO then
				detail_type = ScoietyData.DetailType.Guild
			end
			ScoietyCtrl.Instance:ShowOperateList(detail_type, self.data.role_name)
		end
	end
end

function GuildWageMenberCell:SetParentView(parent)
	self.parent_view = parent
end

function GuildWageMenberCell:OnFlush( )
	if nil == self.data then
		return
	end
	self.node_list["Name"].text.text = self.data.role_name
	self.node_list["Job"].text.text = GuildData.Instance:GetGuildPostNameByPostId(self.data.post)
	self.node_list["TxtContribution"].text.text = self.data.gongzi
	self.node_list["TxtPercent"].text.text = math.floor(self.data.gongzi_rate) .. "%"
	self.node_list["TxtBindGold"].text.text = self.data.gold_bind
	local info = GuildData.Instance:GetGuildMemberInfo(self.data.uid)
	if info then
		self.node_list["SexMale"]:SetActive(info.sex == 1)
		self.node_list["SexFmale"]:SetActive(info.sex == 0)
	end
	if self.parent_view then
		self:FlushIsSelected(self.parent_view.select_index)
	end
end

function GuildWageMenberCell:FlushIsSelected(select_index)
	if select_index then
		self.node_list["HighLight"]:SetActive(select_index == self.index)
	end
end
