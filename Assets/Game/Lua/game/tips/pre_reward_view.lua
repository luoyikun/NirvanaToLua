-- 魂器宝藏-奖励预览提示框
PreRewardView = PreRewardView or BaseClass(BaseView)

local BAG_PAGE_COUNT = 15				-- 每页个数

function PreRewardView:__init()
	self.ui_config = {{"uis/views/tips/prerewardview_prefab", "PreRewardView"}}
	self.view_layer = UiLayer.Pop
	self.cell_list = {}
	self.real_reward_list = {}
	self.reward_list = {}
	self.is_modal = true
	self.is_any_click_close = true
end

function PreRewardView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function PreRewardView:LoadCallBack()
	self.cell_list = {}
	local page_simple_delegate = self.node_list["ListView"].page_simple_delegate
	page_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.NumberOfCellsDel, self)
	page_simple_delegate.CellRefreshDel = BindTool.Bind(self.CellRefreshDel, self)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
end

function PreRewardView:CloseWindow()
	self:Close()
end

function PreRewardView:NumberOfCellsDel()
	return #self.reward_list
end

function PreRewardView:CellRefreshDel(data_index, cell)
	data_index = data_index + 1
	local item_cell = self.cell_list[cell]
	if not item_cell then
		item_cell = ItemCell.New()
		item_cell:SetInstanceParent(cell.gameObject)
		self.cell_list[cell] = item_cell
	end
	item_cell:SetData(self.reward_list[data_index])
end

function PreRewardView:SetRewardList(reward_list)
	self.reward_list = reward_list
end

function PreRewardView:OpenCallBack()
	self.node_list["ListView"].list_view:Reload()
	self.node_list["ListView"].list_view:JumpToIndex(0)
end

function PreRewardView:CloseCallBack()

end