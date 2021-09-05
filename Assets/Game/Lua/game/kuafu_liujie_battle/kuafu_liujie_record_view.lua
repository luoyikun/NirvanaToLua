KuafuGuildRecordView = KuafuGuildRecordView or BaseClass(BaseView)

local Max_Type_Count = 6

function KuafuGuildRecordView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/kuafuliujie_prefab", "GuildRecord"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.cur_index = 1
	self.type_list_view = nil
	self.item_listview_list = nil
	self.def_index = 1
end

function KuafuGuildRecordView:__delete()
end

function KuafuGuildRecordView:ReleaseCallBack()
	for k,v in pairs(self.item_cell) do
		v:DeleteMe()
	end
	self.item_cell = {}
end

function KuafuGuildRecordView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(1020, 600, 0)
	self.node_list["Txt"].text.text = Language.GuildBattle.ZhanChangLog

	self.item_cell = {}
	self:CreateTypeList()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnXianMengShuChu"]:SetActive(SceneType.CrossGuild == Scene.Instance:GetSceneType())
	self.node_list["BtnXianMengShuChu"].button:AddClickListener(BindTool.Bind(self.OnClickGuildShowView, self))
end

-- 打开仙盟输出展示面板
function KuafuGuildRecordView:OnClickGuildShowView()
	self:Close()
	GuildCtrl.Instance:OpenGuildShowView(ACTIVITY_TYPE.KF_GUILDBATTLE)
end

function KuafuGuildRecordView:OpenCallBack()
	self.cur_index = 1
	self.node_list["TypeToggle" .. self.cur_index].toggle.isOn = true
	self.node_list["LeftList"].scroll_rect.normalizedPosition = Vector2(0, 1)
	self:Flush()
end

function KuafuGuildRecordView:CreateTypeList()
	for i = 1, Max_Type_Count do
		self.node_list["TypeToggle" .. i].toggle:AddClickListener(BindTool.Bind(self.OnClickRankType, self, i))
	end
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function KuafuGuildRecordView:GetNumberOfCells()
	local data_list = KuafuGuildBattleData.Instance:GetGuildBattleRankInfoResp()
	if data_list and next(data_list) then
		local rank_list = {}
		for k,v in ipairs(data_list[self.cur_index]) do
			if v.get_score > 0 then
				table.insert(rank_list, v)
			end
		end
		return #rank_list --#data_list[self.cur_index]
	else
		return 0
	end
end

function KuafuGuildRecordView:RefreshCell(cell, data_index, cell_index)
	local data_list = KuafuGuildBattleData.Instance:GetGuildBattleRankInfoResp()
	local item = self.item_cell[cell]
	if nil == item then
		item  = KuafuRankRoleItem.New(cell)
		self.item_cell[cell] = item
	end
	self.item_cell[cell]:SetIndex(cell_index)
	if data_list and next(data_list) then
		if data_list[self.cur_index][cell_index + 1].get_score > 0 then
			self.item_cell[cell]:SetData(data_list[self.cur_index][cell_index + 1])
		end
	end
end

--点击排行榜回调
function KuafuGuildRecordView:OnClickRankType(index)

	if nil == index then
		return
	end
	
	self.cur_index = index   -- list回调
	self:Flush()
end

function KuafuGuildRecordView:OnFlush()
	self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	self:MyGuildRank()
	self:FlushLeft()
end

function KuafuGuildRecordView:FlushLeft()
	local data_list = {}
	local info = KuafuGuildBattleData.Instance:GetGuildBattleInfo()

	if info and info.kf_battle_list then
		data_list = TableCopy(info.kf_battle_list)
	end

	for i = 1, Max_Type_Count do
		local index = 1
		if data_list and data_list[i] and data_list[i].index then
			index = data_list[i].index
		end
		if data_list[i].guild_id > 0 then
			self.node_list["TextNor" .. index].text.text = string.format(Language.KuafuGuildBattle.KfGuildMengzhu, data_list[i].guild_tuanzhang_name)
			self.node_list["TextGuild" .. index].text.text = string.format(Language.KuafuGuildBattle.KfGuildServe, data_list[i].guild_name, data_list[i].server_id)
		else
			self.node_list["TextNor" .. index].text.text = Language.KuafuGuildBattle.KfNoOccupy
			self.node_list["TextGuild" .. index].text.text = Language.KuafuGuildBattle.KfNoOccupy
		end
	end
end

function KuafuGuildRecordView:MyGuildRank()
	local cur_index = self.cur_index

	local myguild_name = GameVoManager.Instance:GetMainRoleVo().guild_name or ""
	local server_id = CrossServerData.Instance:GetServerId() or 0
	-- local server_id = GameVoManager.Instance:GetMainRoleVo().server_id or 0
	self.node_list["MyRankTxt"].text.text = Language.Rank.NoInRank
	self.node_list["SeverIdTxt"].text.text = server_id
	self.node_list["ScoreTxt"].text.text = 0
	local camp_color = CAMP_COLOR[0]
	self.node_list["MyGUildTxt"].text.text = ToColorStr(myguild_name,camp_color)

	local data_list = KuafuGuildBattleData.Instance:GetGuildBattleRankInfoResp()
	self.node_list["ImgRank"]:SetActive(false)
	for i,v in ipairs(data_list) do
		if i == cur_index then
			for x,z in ipairs(v) do
				if myguild_name == z.guild_name and z.get_score > 0 then
					self.node_list["MyRankTxt"].text.text = z.rank
					self.node_list["ImgRank"]:SetActive(z.rank <= 3)
					if z.rank <= 3 then
						self.node_list["ImgRank"].image:LoadSprite(ResPath.GetRankIcon(z.rank))
					end
					self.node_list["SeverIdTxt"].text.text = z.server_id
					self.node_list["MyGUildTxt"].text.text = myguild_name
					self.node_list["ScoreTxt"].text.text = z.get_score
				end
			end
		end
	end
end

----------------------------------------------------
-- 日志排行榜帮派item
----------------------------------------------------
KuafuRankRoleItem = KuafuRankRoleItem or BaseClass(BaseRender)
function KuafuRankRoleItem:__init()

end

function KuafuRankRoleItem:__delete()

end

function KuafuRankRoleItem:OnFlush()
	if nil == self.data then return end
	self.node_list["RankTxt"].text.text = self.data.rank
	self.node_list["ServerIdTxt"].text.text = self.data.server_id
	self.node_list["ScoreTxt"].text.text = self.data.get_score
	self.node_list["GuildNameTxt"].text.text = self.data.guild_name
	if self.data.rank <= 3 then
		self.node_list["ImgRank"].image:LoadSprite(ResPath.GetRankIcon(self.data.rank))
	end
	self.node_list["ImgRank"]:SetActive(self.data.rank <= 3)
end

function KuafuRankRoleItem:FlushMmedal(rank)
end

function KuafuRankRoleItem:SetIndex(index)
	self.index = index
end

function KuafuRankRoleItem:SetData(data)
	self.data = data
	self:Flush()
end