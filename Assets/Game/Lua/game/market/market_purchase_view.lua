MarketPurchaseView = MarketPurchaseView or BaseClass(BaseRender)

function MarketPurchaseView:__init(instance)
	if instance == nil then
		return
	end

	self.cell_list = {}
	self.list_data = MarketData.Instance:GetPurchaseCfg() or {}
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.node_list["ListView"].scroller:ReloadData(0)
	local purchase_list_delegate = self.node_list["PurchaseList"].list_simple_delegate

	purchase_list_delegate.CellSizeDel = BindTool.Bind(self.GetPurchaseCellSizeDel, self)
	purchase_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetPurchaseNumberOfCells, self)
	purchase_list_delegate.CellRefreshDel = BindTool.Bind(self.PurchaseRefreshCell, self)

	self.node_list["BtnPurchase"].button:AddClickListener(BindTool.Bind(self.OnClickPurchase, self))

	self.purchase_event_list_data = {}
	self.purchase_cell_list = {}
	self.select_id = 0
	self.cur_select_id = 0
	self.is_first_flush = true
end

function MarketPurchaseView:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for k, v in pairs(self.purchase_cell_list) do
		v:DeleteMe()
	end
	self.purchase_cell_list = {}
	self.is_first_flush = true
end

function MarketPurchaseView:GetNumberOfCells()
	return math.ceil(#self.list_data / 2)
end

function MarketPurchaseView:RefreshCell(cell, data_index)
	local item_cell = self.cell_list[cell]
	if nil == item_cell then
		item_cell = PurchaseItem.New(cell.gameObject)
		item_cell:ListenClick(BindTool.Bind(self.OnClickParentCell, self))
		self.cell_list[cell] = item_cell
	end

	local data_list = self.list_data
	local data = {data_list[data_index * 2 + 1], data_list[data_index * 2 + 2]}
	item_cell:SetData(data)
end

function MarketPurchaseView:OnClickParentCell(data)
	self.cur_select_id = data.item_id or 0

	for k, v in pairs(self.cell_list) do
		v:SetHightLight(data.item_id)
	end
end

function MarketPurchaseView:OnClickPurchase()
	if not ChatData.Instance:GetChannelCdIsEnd(CHANNEL_TYPE.WORLD) then
		local time = ChatData.Instance:GetChannelCdEndTime(CHANNEL_TYPE.WORLD) - Status.NowTime
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Chat.CanNotChat, math.ceil(time)))
		return
	end

	if nil == self.cur_select_id or 0 == self.cur_select_id then
		SysMsgCtrl.Instance:ErrorRemind(Language.Market.PleaseSelectItem)
		return
	end

	local rank = math.random(1, 5)
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	local real_role_id = CrossServerData.Instance:GetRoleId()
	real_role_id = real_role_id > 0 and real_role_id or role_vo.role_id
	local dec = string.format(Language.Market.MarketPurchase[rank], self.cur_select_id, real_role_id, self.cur_select_id)

	ChatData.Instance:SetChannelCdEndTime(CHANNEL_TYPE.WORLD)
	ChatCtrl.SendChannelChat(CHANNEL_TYPE.WORLD, dec, CHAT_CONTENT_TYPE.TEXT)
	ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, dec, CHAT_CONTENT_TYPE.TEXT)
	TipsCtrl.Instance:ShowSystemMsg(Language.GetBuyChat.Send)

	MarketCtrl.Instance:SendWorldAcquisitionLogReq(rank, self.cur_select_id)
end

function MarketPurchaseView:GetPurchaseCellSizeDel(data_index)
	local data = {}
	local height = 0
	data = self.purchase_event_list_data[data_index + 1]
	if data then
		data.content = MarketData.Instance:ExplainPurchaseText(data)
		height = ChatCtrl.Instance:CalePurchaseHeight(data, data.content)
	end
	
	return height or 0
end

function MarketPurchaseView:PurchaseRefreshCell(cell, data_index)
	data_index = data_index + 1
	local icon_cell = self.purchase_cell_list[cell]
	if icon_cell == nil then
		icon_cell = PurchaseCell.New(cell.gameObject)
		self.purchase_cell_list[cell] = icon_cell
	end
	local data = {}
	data = self.purchase_event_list_data[data_index]
	if data then
		data.content = MarketData.Instance:ExplainPurchaseText(data)
		icon_cell:SetIndex(data_index)
		icon_cell:SetData(data)
		icon_cell:Flush()
	end
end

function MarketPurchaseView:GetPurchaseNumberOfCells()
	local count = #self.purchase_event_list_data
	return count or 0
end

function MarketPurchaseView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "select_purchase" then
			self:OnFlushSelectPurchase()
		elseif k == "purchase" then
			self:OnFlushRecordList()
		elseif k == "all" then
			self:OnFlushRecordList()
			self:OnFlushSelectPurchase()
		end
	end
end

function MarketPurchaseView:OnFlushRecordList()
	self.purchase_event_list_data = MarketData.Instance:GetWorldAcquisitionLog()
	if next(self.purchase_event_list_data) ~= nil then
		if self.is_first_flush or self.node_list["PurchaseList"].scroll_rect.verticalNormalizedPosition <= 0.01 then
			self.is_first_flush = false
			self.node_list["PurchaseList"].scroller:ReloadData(1)
		else
			self.node_list["PurchaseList"].scroller:RefreshAndReloadActiveCellViews(true)
		end
	end
end

function MarketPurchaseView:OnFlushSelectPurchase()
	local select_id, item_id = MarketData.Instance:GetPurchaseItemId()
	self.cur_select_id = item_id or 0
	local active_index = 1 - (select_id / #self.list_data)
	if self.node_list["ListView"].gameObject.activeInHierarchy and item_id > 0 then
		if select_id == 1 then
			self.node_list["ListView"].scroll_rect.verticalNormalizedPosition = 1
		else
			self.node_list["ListView"].scroll_rect.verticalNormalizedPosition = active_index
		end
		for k, v in pairs(self.cell_list) do
			v:SetHightLight(item_id)
		end
	end
end


---------------------------------------------------------------------------------------------------
PurchaseItem = PurchaseItem or BaseClass(BaseCell)
function PurchaseItem:__init()
	self.item_id = 0
	self.node_list["BtnItem1"].button:AddClickListener(BindTool.Bind(self.OnClickCell, self, 1))
	self.node_list["BtnItem2"].button:AddClickListener(BindTool.Bind(self.OnClickCell, self, 2))

	self.item_cell_list = {}
	for i = 1, 2 do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.node_list["ItemCell" .. i])
	end
end

function PurchaseItem:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function PurchaseItem:ListenClick(handler)
	self.handler = handler
end

function PurchaseItem:OnClickCell(index)
	if self.data and self.handler then
		self.handler(self.data[index])
	end
end

function PurchaseItem:OnFlush()
	for i = 1, 2 do
		if self.data[i] then
			self.item_cell_list[i]:SetData(self.data[i])
			local item_cfg = ItemData.Instance:GetItemConfig(self.data[i].item_id)
			if item_cfg then
				self.node_list["TxtItem" ..  i].text.text = item_cfg.name
			end
		end
		self.node_list["BtnItem" .. i]:SetActive(self.data[i] ~= nil)
		self.node_list["Image" .. i]:SetActive(self.data[i] and self.item_id == self.data[i].item_id)
	end
end

function PurchaseItem:SetHightLight(item_id)
	self.item_id = item_id
	for i = 1, 2 do
		self.node_list["Image" .. i]:SetActive(self.data[i] and self.data[i].item_id == item_id)
	end
end


--收购记录
PurchaseCell = PurchaseCell or BaseClass(BaseCell)

function PurchaseCell:__init()
	
end

function PurchaseCell:__delete()
	
end

function PurchaseCell:OnFlush()
	if self.data == nil then
		return
	end
	if self.node_list["PurchaseItem"] then
		RichTextUtil.ParseRichText(self.node_list["PurchaseItem"].rich_text, self.data.content)
		-- ScoietyCtrl.Instance:SetWaitOperaName(self.data.role_name, self.data.item_id)
	end
end

function PurchaseCell:GetContentHeight()
	if self.node_list["PurchaseItem"] then
		local rect = self.node_list["PurchaseItem"]:GetComponent(typeof(UnityEngine.RectTransform))
		--强制刷新
		UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(rect)
		local des_height = rect.rect.height

		local height = des_height / 8 + des_height
		return height
	end
	return 0
end