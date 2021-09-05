ExpenseRewardPoolPanel = ExpenseRewardPoolPanel or BaseClass(BaseView)

function ExpenseRewardPoolPanel:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/rewardlog_prefab","ExpenseRewardPoolPanel"}
	}
	self.full_screen = false
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function ExpenseRewardPoolPanel:__delete()

end

function ExpenseRewardPoolPanel:ReleaseCallBack()
	if self.cell_list then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
			v = nil
		end
		self.cell_list = nil
	end	

	self.toggle_list = nil
	self.list_view_delegate = nil
end

function ExpenseRewardPoolPanel:CloseCallBack()

end

function ExpenseRewardPoolPanel:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(400,420,0)
	self.node_list["Txt"].text.text = Language.Common.RewardName
	self.cell_list = {}

	self.toggle_list = {}

	for i = 1, 5 do
		self.toggle_list[i] = self.node_list["Toggle".. i]
	end

	local page_count = self:GetNumberOfCells()
	self.node_list["ListView"].list_page_scroll:SetPageCount(page_count)

	self.list_view_delegate = self.node_list["ListView"].list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseClick, self))
	self:InitToggles()
end

function ExpenseRewardPoolPanel:OpenCallBack()
	-- body
end

function ExpenseRewardPoolPanel:OnFlush()

end

function ExpenseRewardPoolPanel:InitToggles()
	if self.toggle_list then
		local page_count = self:GetNumberOfCells()
		for i = 1, 5 do
			self.toggle_list[i]:SetActive(i <= page_count)
		end
		self.toggle_list[1].toggle.isOn = true
	end
end

function ExpenseRewardPoolPanel:GetNumberOfCells()
	return FestivalActivityData.Instance:GetExpenseNiceGiftPageCount()
end

function ExpenseRewardPoolPanel:RefreshView(cell, data_index)
	data_index = data_index + 1
	local cfg = FestivalActivityData.Instance:GetExpenseNiceGiftPageCfgByIndex(data_index)
	local the_cell = self.cell_list[cell]

	if cfg then
		if the_cell == nil then
			the_cell = ExpenseRewardPage.New(cell.gameObject)
			self.cell_list[cell] = the_cell
		end
		the_cell:SetIndex(data_index)
		the_cell:SetData(cfg)
	end	
end

function ExpenseRewardPoolPanel:CloseClick()
	self:Close()
end


----------------------------------------------------------------------------
-------------------------------奖励池页数-----------------------------------
----------------------------------------------------------------------------
ExpenseRewardPage = ExpenseRewardPage or BaseClass(BaseCell)

function ExpenseRewardPage:__init()
	self.cell_list = {}
	self.item_cell_list = {}

	for i = 1, 9 do
		self.cell_list[i] = self,node_list["Cell" .. i]
	end
end

function ExpenseRewardPage:__delete()
	if self.item_cell_list then
		for k, v in pairs(self.item_cell_list) do
			if v then
				v:DeleteMe()
				v = nil
			end
		end

		self.item_cell_list = nil
	end
end

function ExpenseRewardPage:OnFlush()
	if not self.data then return end

	cell_count = #self.data

	for i = 1, cell_count do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.cell_list[i])

		if self.data[i] and self.data[i].reward_item then
			self.item_cell_list[i]:SetData(self.data[i].reward_item)
		end
	end
end




