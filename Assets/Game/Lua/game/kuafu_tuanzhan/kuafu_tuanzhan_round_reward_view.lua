KuaFuTuanZhanRoundRewardView = KuaFuTuanZhanRoundRewardView or BaseClass(BaseView)

function KuaFuTuanZhanRoundRewardView:__init()
	self.ui_config = {
			{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
			{"uis/views/kuafutuanzhan_prefab", "KuaFuTuanZhanRoundRewardView"},
	}
	self.view_layer = UiLayer.Pop
	self.cell_list = {}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function KuaFuTuanZhanRoundRewardView:__delete()

end

function KuaFuTuanZhanRoundRewardView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(700, 450, 0)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Txt"].text.text = Language.LuanDouBattle.MyReward

	local list_delegate = self.node_list["Scroller"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.node_list["Scroller"].scroller:ReloadData(0)
end

function KuaFuTuanZhanRoundRewardView:GetNumberOfCells()
	local data = KuaFuTuanZhanData.Instance:GetAllRankReward()
	if data then
		return #data
	end
	return 0
end

function KuaFuTuanZhanRoundRewardView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local the_cell = self.cell_list[cell]
	if the_cell == nil then
		the_cell = KuaFuTuanZhanRoundRewardCell.New(cell.gameObject, self)
		self.cell_list[cell] = the_cell
	end
	local data_list = KuaFuTuanZhanData.Instance:GetAllRankReward()
	local data = data_list[data_index]
	the_cell:SetData(data)
end

function KuaFuTuanZhanRoundRewardView:OpenCallBack()

end

function KuaFuTuanZhanRoundRewardView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function KuaFuTuanZhanRoundRewardView:CloseCallBack()

end

function KuaFuTuanZhanRoundRewardView:OnFlush()

end

--------------------------------------KuaFuTuanZhanRoundRewardCell-----------------------------------------

KuaFuTuanZhanRoundRewardCell = KuaFuTuanZhanRoundRewardCell or BaseClass(BaseCell)

local MAX_REWARD_NUM = 5

function KuaFuTuanZhanRoundRewardCell:__init()
	self.item_cell_list = {}

	for i = 1, MAX_REWARD_NUM do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.node_list["ItemCell" .. i])
	end
end

function KuaFuTuanZhanRoundRewardCell:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function KuaFuTuanZhanRoundRewardCell:SetData(data)
	if nil == data then
		return
	end
	self.node_list["TxtShowRank"].text.text = string.format(Language.LuanDouBattle.Rank, data.turn)
	self.node_list["TxtRank"].text.text = string.format(Language.LuanDouBattle.RankNum, data.rank + 1)
	local reward_data = data.reward_item
	for i = 1, MAX_REWARD_NUM do
		if reward_data[i-1] then 
			self.item_cell_list[i]:SetData(reward_data[i-1])
			self.node_list["ItemCell" .. i]:SetActive(true)
		else
			self.node_list["ItemCell" .. i]:SetActive(false)
		end
	end
end