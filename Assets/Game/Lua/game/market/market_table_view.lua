MarketTableView = MarketTableView or BaseClass(BaseRender)

local ListViewDelegate = ListViewDelegate
local YaoHeTime = 30 		-- 吆喝时间

function MarketTableView:__init(instance)
	if instance == nil then
		return
	end
	self:InitScroller()
end

function MarketTableView:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	self:CancelQuestionCountDown()
	self.diff_time = nil
end

function MarketTableView:OnFlush()
	if self.node_list["Scroller"].scroller.isActiveAndEnabled then
		self.node_list["Scroller"].scroller:RefreshAndReloadActiveCellViews(true)
	end
	local count = self:GetNumberOfCells()
	if count < 1 then
		self.node_list["TxtNoGoods"]:SetActive(true)
	else
		self.node_list["TxtNoGoods"]:SetActive(false)
	end

	local market_time = MarketData.Instance:GetMarketTime()
	local diff_time = market_time - TimeCtrl.Instance:GetServerTime()
	if diff_time > 0 then
		self.diff_time = diff_time
		self:SetCountDown(diff_time)
	end
end

--初始化滚动条
function MarketTableView:InitScroller()
	self.cell_list = {}

	self.list_view_delegate = ListViewDelegate()

	local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader")
	res_async_loader:Load("uis/views/market_prefab", "Info", nil, function (obj)
		if nil == obj then
			return
		end

		self.enhanced_cell_type = obj:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))
		self.node_list["Scroller"].scroller.Delegate = self.list_view_delegate

		self.list_view_delegate.numberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
		self.list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
		self.list_view_delegate.cellViewDel = BindTool.Bind(self.GetCellView, self)
	end)
end

--滚动条数量
function MarketTableView:GetNumberOfCells()
	return MarketData.Instance:GetSaleCount()
end

--滚动条大小
function MarketTableView:GetCellSize(data_index)
	return 105
end

--滚动条刷新
function MarketTableView:GetCellView(scroller, data_index, cell_index)
	local cell_view = scroller:GetCellView(self.enhanced_cell_type)
	local cell = self.cell_list[cell_view]
	if cell == nil then
		self.cell_list[cell_view] = MarketTableViewScrollCell.New(cell_view)
		cell = self.cell_list[cell_view]
		cell:ListenAllEvent()
		cell:SetParentView(self)
		cell:SetOnClickCallBack(BindTool.Bind(self.OnClick, self))
	end
	local sale_item_list = MarketData.Instance:GetSaleItemList()
	if sale_item_list and sale_item_list[data_index + 1] then
		local data = sale_item_list[data_index + 1]
		data.data_index = data_index
		if self.diff_time then
			cell:CellCountState(self.diff_time)
		end
		cell:SetData(data)
		cell:SetCellIndex(cell_index)
	end
	return cell_view
end

function MarketTableView:OnClick(cell)
	
	local function callback()
		cell.root_node:GetComponent("Toggle").isOn = false
	end
	TipsCtrl.Instance:OpenItem(cell.data, TipsFormDef.FROM_MARKET_JISHOU, {fromIndex = cell.data.sale_index},callback)
end

function MarketTableView:SetCountDown(time)
	local time = time
	self:CancelQuestionCountDown()
	for k,v in pairs(self.cell_list) do
		v:CellCountState(time)
	end
	MarketData.Instance:SetMarketTime(time)
	self.count_down = CountDown.Instance:AddCountDown(time, 1, BindTool.Bind(self.CountDown, self))
end

function MarketTableView:CountDown(elapse_time, total_time)
	for k,v in pairs(self.cell_list) do
		v:CellCountState(total_time - elapse_time)
	end
	if elapse_time >= total_time then
		self:CancelQuestionCountDown()
	end
end

function MarketTableView:CancelQuestionCountDown()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

-------------------------------------- 动态生成Cell ----------------------------------------------
MarketTableViewScrollCell = MarketTableViewScrollCell or BaseClass(BaseCell)

function MarketTableViewScrollCell:__init()
	self.root_node.list_cell.refreshCell = BindTool.Bind(self.Flush, self)
	self.item_cell = ItemCell.New()
	self.item_cell:SetFromView(TipsFormDef.FROM_MARKET_JISHOU)
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.node_list["CountDownText"]:SetActive(false)

	self.onclick_callback = nil
	self.parent_view = nil
	self.cell_index = nil
end

function MarketTableViewScrollCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	self.onclick_callback = nil
	self.parent_view = nil
	self.cell_index = nil
end

function MarketTableViewScrollCell:Flush()
	self.item_cell:SetData(self.data)
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	self.node_list["TxtName"].text.text = ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color])
	self.node_list["TxtTotalPrice"].text.text = self.data.gold_price
	local one_price = math.floor(self.data.gold_price / self.data.num) >= 1 and math.floor(self.data.gold_price / self.data.num) or 1
	self.node_list["TxtUnitPrice"].text.text = one_price
end

function MarketTableViewScrollCell:ListenAllEvent()
	self.node_list["BtnInfo"].button:AddClickListener(BindTool.Bind(self.OnXiaJia, self))
	self.node_list["ButtonSell"].button:AddClickListener(BindTool.Bind(self.OnClickSell, self))
	-- self.node_list["Info"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end


function MarketTableViewScrollCell:OnXiaJia()
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	local des = string.format(Language.Market.XiaJiaThing, ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color]))
	local function ok_callback()
		MarketCtrl.Instance:SendRemovePublicSaleItem(self.data.sale_index) 
	end
	TipsCtrl.Instance:ShowCommonAutoView("xiajia", des, ok_callback)
end

function MarketTableViewScrollCell:SetOnClickCallBack(callback)
	self.onclick_callback = callback
end

function MarketTableViewScrollCell:OnClick()
	if self.onclick_callback then
		self.onclick_callback(self)
	end
end

function MarketTableViewScrollCell:OnClickSell()
	MarketCtrl.Instance:SendPublicSaleSendItemInfoToWorld(self.cell_index)
	self.parent_view:SetCountDown(YaoHeTime)
end

function MarketTableViewScrollCell:CellCountState(time)
	if time > 0 then
		UI:SetButtonEnabled(self.node_list["ButtonSell"], false)
		self.node_list["CountDownText"].text.text = "(" .. math.ceil(time) .. "s)"
		self.node_list["CountDownText"]:SetActive(true)
	else
		UI:SetButtonEnabled(self.node_list["ButtonSell"], true)
		self.node_list["CountDownText"]:SetActive(false)
	end
end

function MarketTableViewScrollCell:SetParentView(parent_view)
	self.parent_view = parent_view
end

function MarketTableViewScrollCell:SetCellIndex(cell_index)
	self.cell_index = cell_index
end