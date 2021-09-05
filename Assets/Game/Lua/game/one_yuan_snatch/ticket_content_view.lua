SnatchTicketView = SnatchTicketView or BaseClass(BaseRender)

function SnatchTicketView:__init()
	self.cell_list = {}

	self.toggle_list = {}
	for i = 1, 10 do 
		self.toggle_list[i] = self.node_list["Toggle" .. i]
	end 

	local page_count = OneYuanSnatchData.Instance:GetTicketPageNum() or 1

	local scroller_delegate = self.node_list["ListView"].list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.node_list["BtnTitle"].button:AddClickListener(BindTool.Bind(self.HintClick, self))
end

function SnatchTicketView:__delete()
	if self.cell_list then
		for k, v in pairs(self.cell_list) do
			if v then
				v:DeleteMe()
				v = nil
			end
		end
		self.cell_list = nil
	end
end

function SnatchTicketView:CloseCallBack()

end

function SnatchTicketView:OpenCallBack()
	self:Flush()
end

function SnatchTicketView:OnFlush()
	self:FlushToggleList()

	if self.node_list["ListView"] and self.node_list["ListView"].scroller then
		self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end

	local user_info = OneYuanSnatchData.Instance:GetCloudPurchaseUserInfo()
	if user_info then
		self.node_list["TxtTicketNum"].text.text = user_info.ticket_num or 0
	end
end

function SnatchTicketView:FlushToggleList()
	local toggle_count = OneYuanSnatchData.Instance:GetTicketPageNum() or 1
	if self.toggle_list then
		for i = 1, 10 do
			if self.toggle_list[i] then
				self.toggle_list[i]:SetActive(i <= toggle_count)
			end
		end
	end
end

function SnatchTicketView:GetNumberOfCells() 
 	return OneYuanSnatchData.Instance:GetTicketPageNum() or 0
end

function SnatchTicketView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local cfg = OneYuanSnatchData.Instance:GetTicketPagIndexCfg(data_index)
	local the_cell = self.cell_list[cell]

	if cfg then
		if the_cell == nil then
			the_cell = SnatchCellGroup.New(cell.gameObject)
			self.cell_list[cell] = the_cell
		end
		the_cell:SetIndex(data_index)
		the_cell.view_type = "ticket"
		the_cell:SetData(cfg)
	end
end

function SnatchTicketView:HintClick()
	TipsCtrl.Instance:ShowHelpTipView(TipsOtherHelpData.Instance:GetTipsTextById(320))
end