HappyRecordListView = HappyRecordListView or BaseClass(BaseView)
function HappyRecordListView:__init()
	self.ui_config = {{"uis/views/happyrecharge_prefab", "RecordTipsView"}}
	self.is_modal = true
end

function HappyRecordListView:__delete()
	-- body
end

function HappyRecordListView:LoadCallBack()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().charge_niu_egg
	self.rand_cfg = ActivityData.Instance:GetRandActivityConfig(cfg, ACTIVITY_TYPE.RAND_HAPPY_RECHARGE)

	self.record_cell_list = {}
	self.record_info_list = HappyRechargeData.Instance:GetHistoryList()

	self.node_list["ButtonClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	local list_delegate_right = self.node_list["list_view"].list_simple_delegate
	list_delegate_right.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate_right.CellRefreshDel = BindTool.Bind(self.RefreshCellRight, self)

end

function HappyRecordListView:ReleaseCallBack()
	self.record_cell_list = nil
end

function HappyRecordListView:GetNumberOfCells()
	return HappyRechargeData.Instance:GetHistoryCount()
end

function HappyRecordListView:RefreshCellRight(cell, cell_index)
	local contain_cell = self.record_cell_list[cell]
	if contain_cell == nil then
		contain_cell = HappyRecordCell.New(cell.gameObject)
		self.record_cell_list[cell] = contain_cell
	end
	contain_cell:SetConfig(self.rand_cfg)
	contain_cell:SetData(self.record_info_list[cell_index + 1])
end

function HappyRecordListView:OpenCallBack()

end

function HappyRecordListView:CloseCallBack()

end

function HappyRecordListView:OnFlush(param_list)

end

function HappyRecordListView:CloseView()
	self:Close()
end

------------------------------HappyRecordCell------------------------------------
HappyRecordCell = HappyRecordCell or BaseClass(BaseCell)
function HappyRecordCell:__init()

end

function HappyRecordCell:__delete()
	-- body
end

function HappyRecordCell:SetConfig(cfg)
	self.cfg = cfg
end

function HappyRecordCell:OnFlush()
	self.data = self:GetData()
	if next(self.data) then
		self.node_list["Name"].text.text = self.data.user_name
		self.node_list["ItemName"].text.text = ItemData.Instance:GetItemConfig(self.cfg[self.data.reward_req + 1].reward_item.item_id).name
	end
end