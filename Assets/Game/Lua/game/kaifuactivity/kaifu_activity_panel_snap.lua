FullServerSnapView =  FullServerSnapView or BaseClass(BaseRender)

local PAGE_COLUMN = 3	--列数

--开服 全服抢购  FullServiceSnap
function FullServerSnapView:__init()
	self.contain_cell_list = {}
	self.reward_list = {}
	self.time_change_day = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.SendActivityInfo, self))
	self.current_page = 0
	
	

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

	local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FULL_SERVER_SNAP)
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
		rest_time = rest_time - 1
		self:SetTime(rest_time)
	end)

	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
end

function FullServerSnapView:LoadCallBack()
	local list_delegate = self.node_list["ScrollerListView"].list_simple_delegate
	-- list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	-- list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCellGroupNumber, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCellGroup, self)

	self.reward_list = KaifuActivityData.Instance:GetSnapServerItemlistLimit() or {}
	
	for i = 1, 5 do
		self.node_list["PageToggle" .. i] :SetActive(false)
	end
	
	for i = 1, self:GetCellGroupNumber() do
		self.node_list["PageToggle" .. i]:SetActive(true)
	end
end

function FullServerSnapView:__delete()
	if self.time_change_day then
		GlobalEventSystem:UnBind(self.time_change_day)
		self.time_change_day = nil
	end
	if self.contain_cell_list ~= nil then
		for k, v in pairs(self.contain_cell_list) do
			v:DeleteMe()
		end
	end

	self.contain_cell_list = {}
	self.reward_list = {}
	self.time_change_day = nil
end

function FullServerSnapView:OpenCallBack()
	-- KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FULL_SERVER_SNAP, RA_CHARGE_REPAYMENT_OPERA_TYPE.RA_SERVER_PANIC_BUY_OPERA_TYPE_QUERY_INFO)
	self.reward_list = KaifuActivityData.Instance:GetSnapServerItemlistLimit() or {}
end

function FullServerSnapView:CloseCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

function FullServerSnapView:SendActivityInfo()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FULL_SERVER_SNAP, RA_CHARGE_REPAYMENT_OPERA_TYPE.RA_SERVER_PANIC_BUY_OPERA_TYPE_QUERY_INFO)
end

function FullServerSnapView:ClickReChange()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function FullServerSnapView:OnFlush()
	self.reward_list = KaifuActivityData.Instance:GetSnapServerItemlistLimit() or {}
	self.node_list["ScrollerListView"].scroller:RefreshActiveCellViews()
end

function FullServerSnapView:SetTime(rest_time)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local str = ""

	if time_tab.day > 0 then
		str = TimeUtil.FormatSecond2DHMS(rest_time, 4)
	else
		str = TimeUtil.FormatSecond(rest_time)
	end
	self.node_list["TxtLastRestTime"].text.text = str
	self.node_list["TxtLastTimeTips"].text.text = Language.Activity.ActivityTime7
end

local PAGE_COUNT = 3

function FullServerSnapView:GetNumberOfCells()
	self.reward_list = KaifuActivityData.Instance:GetSnapServerItemlistLimit() or {}
	return #self.reward_list
end

function FullServerSnapView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]

	if contain_cell == nil then
		contain_cell = FullServerSnapCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1
	contain_cell:SetRewardData(self.reward_list[cell_index])
	contain_cell.root_node:SetActive(self.reward_list[cell_index] ~= nil)
	contain_cell:Flush()
end

function FullServerSnapView:GetCellGroupNumber()
	return math.ceil(#self.reward_list / PAGE_COLUMN)
end

function FullServerSnapView:RefreshCellGroup(cell, cell_index)
	if self.reward_list[1] == nil then
		return
	end
	local contain_cell_group = self.contain_cell_list[cell]

	if contain_cell_group == nil then
		contain_cell_group = FullServerSnapGroup.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell_group
	end
	-- if cell_index == math.ceil(#self.reward_list / PAGE_COLUMN) then
	-- 	for i = PAGE_COLUMN, 1, -1 do
	-- 		local index = cell_index * PAGE_COLUMN + i
	-- 		local data = self.reward_list[#self.reward_list - i + 1]
	-- 		contain_cell_group:SetActive(i, true)
	-- 		contain_cell_group:SetIndex(i, index)
	-- 		contain_cell_group:SetData(i, data)
	-- 	end
	-- else
		for i = 1, PAGE_COLUMN do
			local index = cell_index * PAGE_COLUMN + i
			local data = self.reward_list[index]
			if cell_index == self:GetCellGroupNumber() - 1 then
				data = self.reward_list[#self.reward_list - PAGE_COLUMN + i]
			end
			-- if data then
				self.contain_cell_list[cell]:SetActive(i, true)
				self.contain_cell_list[cell]:SetIndex(i, index)
				self.contain_cell_list[cell]:SetData(i, data)
			-- else
			-- 	contain_cell_group:SetActive(i, false)
			-- end
		end
	-- end
	contain_cell_group:Flush()
end


FullServerSnapGroup = FullServerSnapGroup or BaseClass(BaseRender)

function FullServerSnapGroup:__init()
	self.exchange_list = {}
	for i = 1, PAGE_COLUMN do
		local exchange_cell = FullServerSnapCell.New(self.node_list["ShowItem" .. i])
		table.insert(self.exchange_list, exchange_cell)
	end
end

function FullServerSnapGroup:__delete()
	for k, v in ipairs(self.exchange_list) do
		v:DeleteMe()
	end
	self.exchange_list = {}
end

function FullServerSnapGroup:SetActive(i, enable)
	self.exchange_list[i]:SetActive(enable)
end

function FullServerSnapGroup:SetIndex(i, index)
	self.exchange_list[i]:SetIndex(index)
end

function FullServerSnapGroup:SetData(i, data)
	self.exchange_list[i]:SetRewardData(data)
	self.exchange_list[i]:Flush()
end

----------------------------FullServerSnapCell---------------------------------
FullServerSnapCell = FullServerSnapCell or BaseClass(BaseCell)

function FullServerSnapCell:__init()
	self.reward_data = {}
	self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.OnClickGet, self))
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["CellGoodsItem"])
end

function FullServerSnapCell:__delete()
	-- for k,v in pairs(self.item_cell) do
	-- 	v:DeleteMe()
	-- end
	self.item_cell:DeleteMe()
	self.item_cell = nil
end

function FullServerSnapCell:OnClickGet()
	if self.reward_data.is_no_item == 1 then
		return
	end
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FULL_SERVER_SNAP, RA_SERVER_PANIC_BUY_OPERA_TYPE.RA_SERVER_PANIC_BUY_OPERA_TYPE_BUY_ITEM, self.reward_data.seq)
end

function FullServerSnapCell:SetRewardData(data)
	self.reward_data = data
end

function FullServerSnapCell:OnFlush()
	if self.reward_data == nil then return end

	local item_cfg = ItemData.Instance:GetItemConfig(self.reward_data.reward_item.item_id) or {}
	self.item_cell:SetData(self.reward_data.reward_item)
	if self.reward_data.is_no_item == 0 then
		UI:SetButtonEnabled(self.node_list["BtnBuy"], true)
	else
		UI:SetButtonEnabled(self.node_list["BtnBuy"], false)
	end

	self.node_list["TxtInBtn"].text.text = self.reward_data.is_no_item == 0 and Language.OpenServer.Buy or Language.OpenServer.YiGouMai

	if item_cfg then
		local time_str = string.format(Language.HefuActivityItemNameColor[item_cfg.color], item_cfg.name)
		RichTextUtil.ParseRichText(self.node_list["TxtItemName"].rich_text, time_str, 22)		
		--local name_str = "<color=" .. SOUL_NAME_COLOR[item_cfg.color] .. ">" .. item_cfg.name .. "</color>"
		--self.node_list["TxtItemName"].text.text = name_str
	end

	local str = ""
	if self.reward_data.personal_limit_buy_count > 0 then
		str = string.format(Language.OutLine.GreenNumTxt_1, self.reward_data.personal_limit_buy_count)
	else
		str = string.format(Language.OutLine.RedNumTxt, self.reward_data.personal_limit_buy_count)
	end

	local str2 = ""
	if self.reward_data.server_limit_buy_count > 0 then
		str2 = string.format(Language.OutLine.GreenNumTxt_1, self.reward_data.server_limit_buy_count)
	else
		str2 = string.format(Language.OutLine.RedNumTxt, self.reward_data.server_limit_buy_count)
		str = str2
		self.node_list["TxtInBtn"].text.text = Language.Common.YiShouWan
	end
	RichTextUtil.ParseRichText(self.node_list["TxtLastNum"].rich_text, str2, 22)
	RichTextUtil.ParseRichText(self.node_list["TxtLimitedBuyCount"].rich_text, str, 22)

	self.node_list["TxtPriceForItem"].text.text = self.reward_data.gold_price or 0
end