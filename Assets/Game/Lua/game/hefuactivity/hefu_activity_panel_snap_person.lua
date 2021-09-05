PersonFullServerSnapView =  PersonFullServerSnapView or BaseClass(BaseRender)
--个人抢购
function PersonFullServerSnapView:__init()
	self.contain_cell_list = {}
	self.reward_list = {}

	self.current_page = 0
	
	local list_delegate = self.node_list["Scroller"].page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

	local rest_time = HefuActivityData.Instance:GetCombineActTimeLeft(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_PERSONAL_PANIC_BUY)
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
		rest_time = rest_time - 1
		self:SetTime(rest_time)
	end)
end

function PersonFullServerSnapView:OpenCallBack()
	self.reward_list = HefuActivityData.Instance:GetPanicBuyItemListData(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_PERSONAL_PANIC_BUY) or {}

	self.node_list["Scroller"].list_view:Reload()
	self.node_list["Scroller"].list_view:JumpToIndex(0)
	self.node_list["Scroller"].list_page_scroll2:JumpToPageImmidate(0)
end

function PersonFullServerSnapView:__delete()
	if self.node_list["Scroller"] then
		self.node_list["Scroller"].list_view:Reload()
		self.node_list["Scroller"].list_page_scroll2:JumpToPageImmidate(0)
	end

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

	if self.time_change_day then
		GlobalEventSystem:UnBind(self.time_change_day)
		self.time_change_day = nil
	end

	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end

	self.contain_cell_list = {}
end

function PersonFullServerSnapView:SendActivityInfo()
	HefuActivityCtrl.Instance:SendCSAQueryActivityInfo()
end

function PersonFullServerSnapView:ClickReChange()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function PersonFullServerSnapView:OnFlush()
	self.reward_list = HefuActivityData.Instance:GetPanicBuyItemListData(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_PERSONAL_PANIC_BUY) or {}
	if self.node_list["Scroller"] then
		self.node_list["Scroller"].list_view:Reload()
	end
end

function PersonFullServerSnapView:SetTime(rest_time)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local str = ""
	if time_tab.day > 0 then
		str = TimeUtil.FormatSecond2DHMS(rest_time, 4)
	else
		str = TimeUtil.FormatSecond(rest_time)
	end
	self.node_list["TxtRestTime"].text.text = str
end

local PAGE_COUNT = 3

function PersonFullServerSnapView:GetNumberOfCells()
	local count = math.ceil(#self.reward_list / PAGE_COUNT)
	if count then
		for i = 1, count do
			self.node_list["PageToggle" .. i]:SetActive(true)
		end
		self.node_list["Scroller"].list_page_scroll2:SetPageCount(count)
	end
	return math.ceil(#self.reward_list / 3) * 3
end

function PersonFullServerSnapView:RefreshCell(cell_index, cell)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = ActHotSellPersonItemRender.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	contain_cell:SetItemData(self.reward_list[cell_index])
	contain_cell.root_node:SetActive(self.reward_list[cell_index] ~= nil)
	contain_cell:Flush()
end

---------------------------ActHotSellPersonItemRender---------------------------------
ActHotSellPersonItemRender = ActHotSellPersonItemRender or BaseClass(BaseCell)

function ActHotSellPersonItemRender:__init()
	self.reward_data = {}
	self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.OnClickGet, self))
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["CellItem"])
	-- end
end

function ActHotSellPersonItemRender:__delete()
	self.item_cell:DeleteMe()
	self.item_cell = nil
end

function ActHotSellPersonItemRender:OnClickGet()
	if self.reward_data.is_no_item == 1 then
		return
	end
	self.reward_data.get_callback()
end

function ActHotSellPersonItemRender:SetItemData(data)
	self.reward_data = data
end

function ActHotSellPersonItemRender:OnFlush()
	if not self.reward_data  then return end 
	local item_cfg = ItemData.Instance:GetItemConfig(self.reward_data.reward_item.item_id) or {}
	self.item_cell:SetData(self.reward_data.reward_item)
	self.node_list["TxtLimitBuyCount"].text.text = Language.Activity.LimitedBuyTxt
	local str = ""
	if self.reward_data.person_limit <= 0 then
		str = string.format(Language.OutLine.RedNumTxt, self.reward_data.person_limit)
	else
		str = string.format(Language.OutLine.GreenNumTxt_1, self.reward_data.person_limit)
	end
	RichTextUtil.ParseRichText(self.node_list["TxtLimitBuyCountValue"].rich_text, str, 22)

	local time_str = string.format(Language.HefuActivityItemNameColor[item_cfg.color], item_cfg.name)
	RichTextUtil.ParseRichText(self.node_list["TxtItemName"].rich_text, time_str, 22)
	
	--self.node_list["TxtItemName"].text.text = "<color=" .. SOUL_NAME_COLOR[item_cfg.color] .. ">" .. item_cfg.name .. "</color>"
	self.node_list["TxtCostGold"].text.text = self.reward_data.gold_price or 0
	UI:SetButtonEnabled(self.node_list["BtnBuy"], self.reward_data.is_no_item == 0)
	self.node_list["TxtInBtn"].text.text = self.reward_data.is_no_item == 0 and Language.Common.CanPurchase or Language.Common.AlreadyPurchase
end
