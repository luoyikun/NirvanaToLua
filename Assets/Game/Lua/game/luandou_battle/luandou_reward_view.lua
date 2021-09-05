LuanDouBattleRewardView = LuanDouBattleRewardView or BaseClass(BaseView)

function LuanDouBattleRewardView:__init()
	self.ui_config = {
			{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
			{"uis/views/luandoubattleview_prefab", "LuanDouRewardView"},
	}
	self.view_layer = UiLayer.Pop
	self.cell_list = {}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function LuanDouBattleRewardView:__delete()

end

function LuanDouBattleRewardView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(700, 450, 0)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Txt"].text.text = Language.LuanDouBattle.AllReward

	local list_delegate = self.node_list["Scroller"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.node_list["Scroller"].scroller:ReloadData(0)
end

function LuanDouBattleRewardView:GetNumberOfCells()
	return #LuanDouBattleData.Instance:GetNightFightRewardCfg()
end

function LuanDouBattleRewardView:RefreshCell(cell, cell_index)
	local the_cell = self.cell_list[cell]
	if the_cell == nil then
		the_cell = LuanDouRewardCell.New(cell.gameObject, self)
		self.cell_list[cell] = the_cell
		the_cell:SetToggleGroup(self.node_list["Scroller"].toggle_group)
	end
	cell_index = cell_index + 1
	the_cell:SetRank(cell_index)
	the_cell:Flush()
end

function LuanDouBattleRewardView:OpenCallBack()

end

function LuanDouBattleRewardView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function LuanDouBattleRewardView:CloseCallBack()

end

function LuanDouBattleRewardView:OnFlush()

end

--------------------------------------LuanDouRewardCell-----------------------------------------

LuanDouRewardCell = LuanDouRewardCell or BaseClass(BaseCell)

local MAX_REWARD_NUM = 4

function LuanDouRewardCell:__init()
	self.item_cell_list = {}
	for i = 1, MAX_REWARD_NUM do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.node_list["ItemCell" .. i])
	end
end

function LuanDouRewardCell:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function LuanDouRewardCell:SetRank(rank)
	self.rank = rank
end

function LuanDouRewardCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function LuanDouRewardCell:OnFlush()
	local cfg = LuanDouBattleData.Instance:GetConfig()
	if nil == cfg and cfg.reward then return end
	local data = cfg.reward[self.rank] and cfg.reward[self.rank] or {}

	if data then
		local reward_data = TableCopy(data.reward_item)
		local data1 = {item_id = ResPath.CurrencyToIconId.gongxun, num = data.cross_honor, is_bind = 1,}  -- 荣誉
		table.insert(reward_data, data1)
		local data2 = {item_id = ResPath.CurrencyToIconId.honor, num = data.shengwang, is_bind = 1}	 -- 声望
		table.insert(reward_data, data2)
		for i = 1, MAX_REWARD_NUM do
			if reward_data[i - 1] then
				self.item_cell_list[i]:SetParentActive(true)
				self.item_cell_list[i]:SetData(reward_data[i - 1])
			else
				self.item_cell_list[i]:SetParentActive(false)
			end
		end

		local min_rank = data.min_rank + 1 or 0
		local max_rank = data.max_rank + 1 or 0
		if min_rank == max_rank then
			self.node_list["TxtRank"].text.text = string.format(Language.NightFight.RankDesc, min_rank)
		else
			self.node_list["TxtRank"].text.text = string.format(Language.NightFight.RankRewardDesc, min_rank, max_rank)
		end
	end
end