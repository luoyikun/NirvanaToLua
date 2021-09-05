ActivityBattleView = ActivityBattleView or BaseClass(BaseRender)

function ActivityBattleView:UIsMove()
	UITween.MoveShowPanel(self.node_list["BattlePanel"] , Vector3(-282.25 , -775 , 0 ) , MOVE_TIME )
	UITween.AlpahShowPanel(self.node_list["BattlePanel"] , true , MOVE_TIME , DG.Tweening.Ease.Linear )
end

function ActivityBattleView:__init(instance)
	if instance == nil then
		return
	end

	self.cell_list = {}
	self.act_info = ActivityData.Instance:GetClockActivityByType(ActivityData.Act_Type.battle_field)
	self.act_count = ActivityData.Instance:GetClockActivityCountByType(ActivityData.Act_Type.battle_field)

	self:InitScroller()
	self.select_index = 0
end

function ActivityBattleView:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

--初始化滚动条
function ActivityBattleView:InitScroller()
	
	self.list_view_delegate = self.node_list["Scroller"].list_simple_delegate
	self.node_list["Scroller"].scroller.spacing = 8 --item间距

	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

--滚动条数量
function ActivityBattleView:GetNumberOfCells()
	return self.act_count
end

--滚动条刷新
function ActivityBattleView:RefreshView(cell, data_index)
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


function ActivityBattleView:FlushBattle()
	self.node_list["Scroller"].scroller:ReloadData(0)
end

function ActivityBattleView:OpenCallBack()
	self.select_index = 0
	self:FlushBattle()
end

function ActivityBattleView:GetSelectIndex()
	return self.select_index
end

function ActivityBattleView:SetSelectIndex(select_index)
	self.select_index = select_index
end
