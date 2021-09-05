ActivityKuaFuBattleView = ActivityKuaFuBattleView or BaseClass(BaseRender)

function ActivityKuaFuBattleView:UIsMove()
	UITween.MoveShowPanel(self.node_list["KuaFuPanel"] , Vector3(-282.25 , -775 , 0 ) , MOVE_TIME )
	UITween.AlpahShowPanel(self.node_list["KuaFuPanel"] , true , MOVE_TIME , DG.Tweening.Ease.Linear )
end

function ActivityKuaFuBattleView:__init(instance)
	if instance == nil then
		return
	end

	self.cell_list = {}
	self.act_info = ActivityData.Instance:GetClockActivityByType(ActivityData.Act_Type.kuafu_battle_field)
	self.act_count = ActivityData.Instance:GetClockActivityCountByType(ActivityData.Act_Type.kuafu_battle_field)

	self:InitScroller()

end

function ActivityKuaFuBattleView:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.select_index = 0
end

--初始化滚动条
function ActivityKuaFuBattleView:InitScroller()
	self.list_view_delegate = self.node_list["Scroller"].list_simple_delegate

	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

--滚动条数量
function ActivityKuaFuBattleView:GetNumberOfCells()
	return self.act_count
end

--滚动条刷新
function ActivityKuaFuBattleView:RefreshView(cell, data_index)
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = ActivityViewScrollCell.New(cell.gameObject) --实例化item
		self.cell_list[cell] = group_cell
		self.cell_list[cell]:SetParentView(self)
		self.cell_list[cell].root_node.toggle.group = self.node_list["Scroller"].toggle_group
	end

	if data_index + 1 == self.index then
		self.cell_list[cell].root_node.toggle.isOn = true
	end

	local data = self.act_info[data_index+1]
	if data then
		group_cell:SetIndex(data_index)
		group_cell:SetData(data)
	end
	
end


function ActivityKuaFuBattleView:FlushKuaFuBattle()
	self.node_list["Scroller"].scroller:ReloadData(0)
end

function ActivityKuaFuBattleView:OpenCallBack()
	self.select_index = 0
	self:FlushKuaFuBattle()
end

function ActivityKuaFuBattleView:GetSelectIndex()
	return self.select_index
end

function ActivityKuaFuBattleView:SetSelectIndex(select_index)
	self.select_index = select_index
end
