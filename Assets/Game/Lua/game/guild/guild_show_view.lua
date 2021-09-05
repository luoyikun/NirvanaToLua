-- 仙盟展示输出功能
-- GuildShowView

GuildShowView = GuildShowView or BaseClass(BaseView)

function GuildShowView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel"},
		{"uis/views/guildview_prefab", "GuildShowView"}
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp

	self.actity_type = 0
end

function GuildShowView:__delete()
	self.actity_type = nil
end

function GuildShowView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
			v = nil
		end
	end
	self.cell_list = {}

	self.guild_info_statistic_list = {}
end

function GuildShowView:LoadCallBack()
	self.node_list["BtnConfrim"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.guild_info_statistic_list = GuildData.Instance:GetGuildInfoStatistic()

	self.cell_list = {}
	local left_list_delegate = self.node_list["ListView"].list_simple_delegate
	left_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCell, self)
	left_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function GuildShowView:OpenCallBack()
	self.guild_info_statistic_list = GuildData.Instance:GetGuildInfoStatistic()
end

function GuildShowView:GetNumberOfCell()
	return self.guild_info_statistic_list and #self.guild_info_statistic_list or 0
end

function GuildShowView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local cell_item = self.cell_list[cell]
	if cell_item == nil then
		cell_item = GuildShowViewCell.New(cell.gameObject)
		self.cell_list[cell] = cell_item
	end
	cell_item:SetData(self.guild_info_statistic_list[data_index])
	cell_item:SetActivityType(self.actity_type)
	cell_item:SetIndex(data_index)
end

function GuildShowView:SetActityData(actity_type)
	self.actity_type = actity_type
	GuildCtrl.Instance:SendGuildInfoStatisticReq(self.actity_type)
	self:Flush()
end

function GuildShowView:OnFlush(param_list)
	self.guild_info_statistic_list = GuildData.Instance:GetGuildInfoStatistic()
	if self.node_list["ListView"].scroller and self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end
	self.node_list["TitleText"].text.text = Language.GuildShowView.TitleName[self.actity_type]
	for i = 1, 6 do 
		self.node_list["Text_Title_" .. i].text.text = Language.GuildShowView.TitleText[self.actity_type][i]
	end
end

---------------------------------------------------------------------------------
-- GuildShowViewCell

GuildShowViewCell = GuildShowViewCell or BaseClass(BaseCell)

function GuildShowViewCell:__init()
	self.actity_type = 0
end

function GuildShowViewCell:__delete()

end

function GuildShowViewCell:SetActivityType(actity_type)
	self.actity_type = actity_type
end

function GuildShowViewCell:OnFlush()
	if not self.data or self.data == {} then
		return
	end
	local is_open = ActivityData.Instance:GetActivityIsOpen(self.actity_type)
	local is_ready = ActivityData.Instance:GetActivityIsReady(self.actity_type)

	if not is_open and not is_ready then
		local most_kill_role_uid = 0
		local most_shuchu_uid = 0
		local most_hurt_id = 0
		local most_zhanling_id = 0
		most_kill_role_uid, most_shuchu_uid, most_hurt_id, most_zhanling_id = GuildData.Instance:GetGuildMostUid()

		self.node_list["MVP"]:SetActive(self.data.is_mvp == 1)

		self.node_list["Text_1"].text.text = self.data.user_name or ""
		local guild_post = self.data.guild_post or 1
		self.node_list["Text_2"].text.text = GUILD_CHAT_POST[guild_post]

		self.node_list["Iconkill"]:SetActive(most_kill_role_uid == self.data.uid)
		self.node_list["Text_3"].text.text = self.data.kill_role or 0

		self.node_list["IconShuChu"]:SetActive(most_shuchu_uid == self.data.uid)
		self.node_list["Text_4"].text.text = CommonDataManager.ConverMoney2(self.data.hurt_roles) or 0

		self.node_list["IconHurt"]:SetActive(most_hurt_id == self.data.uid)
		self.node_list["Text_5"].text.text = CommonDataManager.ConverMoney2(self.data.hurt_targets) or 0

		self.node_list["IconZhanLing"]:SetActive(most_zhanling_id == self.data.uid)
		self.node_list["Text_6"].text.text = self.data.kill_target or 0
	else
		self.node_list["Text_1"].text.text = self.data.user_name or ""
		local guild_post = self.data.guild_post or 1
		self.node_list["Text_2"].text.text = GUILD_CHAT_POST[guild_post]
		self.node_list["Text_3"].text.text = self.data.kill_role or 0
		self.node_list["Text_4"].text.text = CommonDataManager.ConverMoney2(self.data.hurt_roles) or 0
		self.node_list["Text_5"].text.text = CommonDataManager.ConverMoney2(self.data.hurt_targets) or 0
		self.node_list["Text_6"].text.text = self.data.kill_target or 0
		self.node_list["Iconkill"]:SetActive(false)
		self.node_list["IconShuChu"]:SetActive(false)
		self.node_list["IconHurt"]:SetActive(false)
		self.node_list["IconZhanLing"]:SetActive(false)
		self.node_list["MVP"]:SetActive(false)
	end
end