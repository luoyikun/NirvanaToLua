LuanDouAllRewardView = LuanDouAllRewardView or BaseClass(BaseView)

function LuanDouAllRewardView:__init()
	self.ui_config = {
			{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
			{"uis/views/luandoubattleview_prefab", "LuandouAllRewardView"},
	}
	self.view_layer = UiLayer.Pop
	self.cell_list = {}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function LuanDouAllRewardView:__delete()

end

function LuanDouAllRewardView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(700, 450, 0)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Txt"].text.text = Language.LuanDouBattle.MyReward

	local list_delegate = self.node_list["Scroller"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.node_list["Scroller"].scroller:ReloadData(0)
end

function LuanDouAllRewardView:GetNumberOfCells()
	local data = LuanDouBattleData.Instance:GetAllRankReward()
	if data then
		return #data
	end
	return 0
end

function LuanDouAllRewardView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local the_cell = self.cell_list[cell]
	if the_cell == nil then
		the_cell = LuanDouAllRewardCell.New(cell.gameObject, self)
		self.cell_list[cell] = the_cell
	end
	local data_list = LuanDouBattleData.Instance:GetAllRankReward()
	local data = data_list[data_index]
	the_cell:SetData(data)
end

function LuanDouAllRewardView:OpenCallBack()

end

function LuanDouAllRewardView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function LuanDouAllRewardView:CloseCallBack()

end

function LuanDouAllRewardView:OnFlush()

end

--------------------------------------LuanDouAllRewardCell-----------------------------------------

LuanDouAllRewardCell = LuanDouAllRewardCell or BaseClass(BaseCell)

local MAX_REWARD_NUM = 5

function LuanDouAllRewardCell:__init()
	self.item_cell_list = {}
	for i = 1, MAX_REWARD_NUM do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.node_list["ItemCell" .. i])
	end
end

function LuanDouAllRewardCell:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function LuanDouAllRewardCell:SetData(data)
	if nil == data then
		return
	end
	self.node_list["TxtShowRank"].text.text = string.format(Language.LuanDouBattle.Rank, data.turn)
	self.node_list["TxtRank"].text.text = string.format(Language.LuanDouBattle.RankNum, data.rank + 1)
	local reward_data = data.reward_item
	for i = 1, MAX_REWARD_NUM do
		if reward_data[i - 1] then 
			self.item_cell_list[i]:SetData(reward_data[i-1])
			self.item_cell_list[i]:SetParentActive(true)
		else
			self.item_cell_list[i]:SetParentActive(false)
		end
	end
end