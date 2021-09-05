GuildAnswerTask = GuildAnswerTask or BaseClass(BaseView)

local ListNum = 6
function GuildAnswerTask:__init()
	self.ui_config = {{"uis/views/guildanswer_prefab", "GuildAnswer"}}
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
end

function GuildAnswerTask:__delete()

end

function GuildAnswerTask:ReleaseCallBack()
	for k,v in pairs(self.rank_cell_list) do
		v:DeleteMe()
	end
	self.rank_cell_list = nil

	if self.menu_toggle_event then
		GlobalEventSystem:UnBind(self.menu_toggle_event)
	end
end

function GuildAnswerTask:LoadCallBack()
	self.rank_cell_list = {}
	local list_delegate = self.node_list["DaTIList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshTreasureBoxCell, self)
	self.menu_toggle_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,BindTool.Bind(self.PortraitToggleChange, self))
end

function GuildAnswerTask:PortraitToggleChange(state)
	if state then
		self:Flush()
	end
	self.node_list["TaskParent"]:SetActive(state)
end


function GuildAnswerTask:GetNumberOfCells()
	--排行信息
	local rank_list = GuildData.Instance:GetGuildRankInfoList()
	return #rank_list
end

function GuildAnswerTask:RefreshTreasureBoxCell(cell, cell_index)
	local rank_cell = self.rank_cell_list[cell]
	if rank_cell == nil then
		rank_cell = DaTiListRankItem.New(cell.gameObject, self)
		self.rank_cell_list[cell] = rank_cell
	end
	cell_index = cell_index + 1
	rank_cell:SetIndex(cell_index)
	rank_cell:Flush()
end

function GuildAnswerTask:FlushRoleInfo()
	local guild_player_info = GuildData.Instance:GetQuestionPlayerInfo()
	local answer_cfg = GuildData.Instance:GetGuildQuestionOtherCfg()
	local gather_num = GuildData.Instance:GetQuestionPlayerInfo()
	if guild_player_info == nil then return end
	self.node_list["exp"].text.text = CommonDataManager.ConverExp(guild_player_info.exp)
	self.node_list["gongxian"].text.text = guild_player_info.guild_gongxian

	self.node_list["caiji"].text.text = guild_player_info.is_gather .. "/" .. answer_cfg.gather_count_limit
end

function GuildAnswerTask:OnFlush()
	if self.node_list["DaTIList"] and self.node_list["DaTIList"].scroller and self.node_list["DaTIList"].scroller.isActiveAndEnabled then
		self.node_list["DaTIList"].scroller:RefreshAndReloadActiveCellViews(true)
	end
	self:FlushRoleInfo()
end


-----------------------------------------------------------------------------
------------------------排行ItemRender---------------------------------------
-----------------------------------------------------------------------------
-- 个人积分排行单元

--答题排名滚动条格子------------------------------------------------------
DaTiListRankItem = DaTiListRankItem or BaseClass(BaseCell)

function DaTiListRankItem:__init(instance, view)
	self.parent = view
end

function DaTiListRankItem:__delete()
	self.parent = nil
end

function DaTiListRankItem:OnFlush()
	local rank_info = GuildData.Instance:GetGuildRankInfo(self.index)
	self:SetActive(rank_info and rank_info.guild_name ~= "")
	if not rank_info then return end
	self.node_list["TxtName"].text.text = rank_info.guild_name
	self.node_list["TxtRank"].text.text =  self.index
	self.node_list["Txtjifen"].text.text = string.format(Language.GuildDaTi.Score, rank_info.guild_score)
	if self.index <= 3 then
		self.node_list["TxtRank"]:SetActive(false)
		self.node_list["RankImage"]:SetActive(true)
		local bundle, asset = ResPath.GetRankIcon(self.index)
		self.node_list["RankImage"].image:LoadSprite(bundle, asset .. ".png")
		self.node_list["RankImage"].image:SetNativeSize()
	else
		self.node_list["TxtRank"]:SetActive(true)
		self.node_list["RankImage"]:SetActive(false)
	end

end