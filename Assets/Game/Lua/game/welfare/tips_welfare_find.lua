TipsWelareFindView = TipsWelareFindView or BaseClass(BaseView)
function TipsWelareFindView:__init()
	self.ui_config = {{"uis/views/welfare_prefab", "ZhaoHuiTip"}}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsWelareFindView:__delete()

end

function TipsWelareFindView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.node_list["BtnFree"].button:AddClickListener(BindTool.Bind(self.ClickFree, self))
	self.node_list["BtnCost"].button:AddClickListener(BindTool.Bind(self.ClickCost, self))

	self.free_item_list = {}
	local list_simple_delegate_free = self.node_list["FreeItemList"].list_simple_delegate
	list_simple_delegate_free.NumberOfCellsDel = BindTool.Bind(self.GetCellNumberFree, self)
	list_simple_delegate_free.CellRefreshDel = BindTool.Bind(self.CellRefreshFree, self)

	self.cost_item_list = {}
	local list_simple_delegate_cost = self.node_list["CostItemList"].list_simple_delegate
	list_simple_delegate_cost.NumberOfCellsDel = BindTool.Bind(self.GetCellNumberCost, self)
	list_simple_delegate_cost.CellRefreshDel = BindTool.Bind(self.CellRefreshCost, self)
end

function TipsWelareFindView:ReleaseCallBack()
	self.free_callback = nil
	self.cost_callback = nil
end

function TipsWelareFindView:CloseView()
	self:Close()
end

function TipsWelareFindView:GetCellNumberFree()
	if #self.free_data_list % 6 ~= 0 then
		return math.ceil(#self.free_data_list / 6)
	else
		return #self.free_data_list / 6
	end
end

function TipsWelareFindView:CellRefreshFree(cell, data_index)
	local reward_cell = self.free_item_list[cell]
	if nil == reward_cell then
		reward_cell = FreeRewardGroup.New(cell.gameObject)
		self.free_item_list[cell] = reward_cell
	end
	for i = 1 ,6 do
		local index = data_index * 6 + i
		local data = self.free_data_list[index] or {}
		reward_cell:SetIndex(index)
		reward_cell:SetData(i, data)
	end
end

function TipsWelareFindView:GetCellNumberCost()
	if #self.cost_data_list % 6 ~= 0 then
		return math.ceil(#self.cost_data_list / 6)
	else
		return #self.cost_data_list / 6
	end
end

function TipsWelareFindView:CellRefreshCost(cell, data_index)
	local reward_cell = self.cost_item_list[cell]
	if nil == reward_cell then
		reward_cell = CostRewardGroup.New(cell.gameObject)
		self.cost_item_list[cell] = reward_cell
	end

	for i = 1 ,6 do
		local index = data_index * 6 + i
		local data = self.cost_data_list[index] or {}
		reward_cell:SetIndex(index)
		reward_cell:SetData(i, data)
	end
end

function TipsWelareFindView:ClickFree()
	if self.free_callback then
		self.free_callback()
	end
	self:Close()
end

function TipsWelareFindView:ClickCost()
	if self.cost_callback then
		self.cost_callback()
	end
	self:Close()
end


function TipsWelareFindView:CloseCallBack()

end

function TipsWelareFindView:OpenCallBack()
	self:OnFlush()
end

function TipsWelareFindView:OnFlush()
	self.node_list["TxtCost"].text.text = self.cost
	self.node_list["FreeItemList"].scroller:ReloadData(0)
	self.node_list["CostItemList"].scroller:ReloadData(0)
	if self.free_data_list then
		local flag = #self.free_data_list > 0 
		self.node_list["FreeContent"]:SetActive(flag)
		self.node_list["Line"]:SetActive(flag)
		self.node_list["BtnFree"]:SetActive(flag)
		self.node_list["Frame"].rect.sizeDelta = flag and Vector3(800, 475,0) or Vector3(800, 350 , 0)
		local txt = flag and Language.Welfare.WelfareFindTxt[1] or Language.Welfare.WelfareFindTxt[2]
		self.node_list["TxtYuanBaoZhaoHui"].text.text = txt
	end
end

function TipsWelareFindView:SetData(cost, free_items, cost_items)
	self.cost = cost
	self.free_data_list = free_items
	self.cost_data_list = cost_items
end

function TipsWelareFindView:SetFreeCallBack(callback)
	self.free_callback = callback
end

function TipsWelareFindView:SetCostCallBack(callback)
	self.cost_callback = callback
end

------------------------------------------------------------------------
FreeRewardGroup = FreeRewardGroup  or BaseClass(BaseCell)

function FreeRewardGroup:__init()
	self.free_list = {}
	for i = 1, 6 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Item" .. i])
		table.insert(self.free_list, item)
	end
end

function FreeRewardGroup:__delete()
	for i = 1, 6 do
		self.free_list[i]:DeleteMe()
		self.free_list[i] = nil
	end
end

function FreeRewardGroup:SetData(i, data)
	self.free_list[i]:SetData(data)
end


------------------------------------------------------------------------
CostRewardGroup = CostRewardGroup  or BaseClass(BaseCell)

function CostRewardGroup:__init()
	self.cost_list = {}
	for i = 1, 6 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Item" .. i])
		table.insert(self.cost_list, item)
	end
end

function CostRewardGroup:__delete()
	for i = 1, 6 do
		self.cost_list[i]:DeleteMe()
		self.cost_list[i] = nil
	end
end

function CostRewardGroup:SetData(i, data)
	self.cost_list[i]:SetData(data)
end