KaifuActivityPanelEveryDayBuy = KaifuActivityPanelEveryDayBuy or BaseClass(BaseRender)
local PAGE_COUNT = 3
function KaifuActivityPanelEveryDayBuy:__init(instance)
	self.cell_list = {}
	self.contain_cell_list = {}
	-- local exchange_list_delegate = self.node_list["ListView"].list_simple_delegate
	
end

function KaifuActivityPanelEveryDayBuy:LoadCallBack()
	local exchange_list_delegate = self.node_list["Scroller"].list_simple_delegate
	exchange_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetGroupNumber, self)
	exchange_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshGroupCell, self)
end

function KaifuActivityPanelEveryDayBuy:OpenCallBack()
	-- self.node_list["Scroller"].list_view:Reload()
	-- self.node_list["Scroller"].list_view:JumpToIndex(0)
	-- self.node_list["Scroller"].list_page_scroll2:JumpToPageImmidate(0)
end

function KaifuActivityPanelEveryDayBuy:__delete()
	-- if self.node_list["Scroller"] then
	-- 	self.node_list["Scroller"].list_view:Reload()
	-- 	self.node_list["Scroller"].list_page_scroll2:JumpToPageImmidate(0)
	-- end
	self.temp_activity_type = nil
	self.activity_type = nil

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end

	if self.contain_cell_list ~= nil then
		for k, v in pairs(self.contain_cell_list) do
			v:DeleteMe()
		end
	end

	self.cell_list = {}
end
function KaifuActivityPanelEveryDayBuy:CloseCallBack()
	if self.time_count ~= nil then
		CountDown.Instance:RemoveCountDown(self.time_count)
		self.time_count = nil
	end
end

function KaifuActivityPanelEveryDayBuy:GetCellNumber1()
	local everyday_actiivity_sort_cfg = KaifuActivityData.Instance:GetEveryDayBuyActivitySortCfg()
	local count = math.ceil(#everyday_actiivity_sort_cfg / PAGE_COUNT)
	if count then
		for i = 1, count do
			self.node_list["PageToggle" .. i]:SetActive(true)
		end
		-- self.node_list["Scroller"].list_page_scroll2:SetPageCount(count)
	end
	-- return #everyday_actiivity_sort_cfg 
	return count
end

function KaifuActivityPanelEveryDayBuy:RefreshCell1(cell_index, cell)
	local cell_item = self.cell_list[cell]

	if cell_item == nil then
		cell_item = PanelEveryDayBuyListCell.New(cell.gameObject)
		self.cell_list[cell] = cell_item
	end
	local activity_sort_cfg = KaifuActivityData.Instance:GetEveryDayBuyActivitySortCfg()
	local sort_cfg = activity_sort_cfg[cell_index + 1]

	if sort_cfg ~= nil then 
		local cfg = KaifuActivityData.Instance:GetEverydayActivityCfgBySeq(sort_cfg.seq)
		local buy_info = KaifuActivityData.Instance:GetEverydayBuyInfo()

		cell_item:SetIndex(cfg.seq + 1)
		cell_item:SetData(cfg, buy_info[cfg.seq + 1])
	end
	cell_item.root_node:SetActive(sort_cfg ~= nil)

end

function KaifuActivityPanelEveryDayBuy:GetGroupNumber()
	local everyday_actiivity_sort_cfg = KaifuActivityData.Instance:GetEveryDayBuyActivitySortCfg()
	local count = math.ceil(#everyday_actiivity_sort_cfg / PAGE_COUNT)
	if count then
		for i = 1, count do
			self.node_list["PageToggle" .. i]:SetActive(true)
		end
	end
	return count
end

function KaifuActivityPanelEveryDayBuy:RefreshGroupCell(cell, cell_index)
	local contain_cell_group = self.contain_cell_list[cell]
	if contain_cell_group == nil then
		contain_cell_group = EveryDayBuyGroup.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell_group
	end


	local activity_sort_cfg = KaifuActivityData.Instance:GetEveryDayBuyActivitySortCfg()

	for i = 1, PAGE_COUNT do
		local index = cell_index * PAGE_COUNT + i
		local sort_cfg = activity_sort_cfg[index]
		if cell_index == self:GetGroupNumber() - 1 then
			sort_cfg = activity_sort_cfg[#activity_sort_cfg - PAGE_COUNT + i]
		end
		if sort_cfg ~= nil then 
			local cfg = KaifuActivityData.Instance:GetEverydayActivityCfgBySeq(sort_cfg.seq)
			local buy_info = KaifuActivityData.Instance:GetEverydayBuyInfo()

			contain_cell_group:SetIndex(i, cfg.seq + 1)
			contain_cell_group:SetData(i, cfg, buy_info[cfg.seq + 1])
			contain_cell_group:SetActive(i, true)
		end
	end
	contain_cell_group:Flush()
end

function KaifuActivityPanelEveryDayBuy:Flush(activity_type)
	self.activity_type = activity_type or self.activity_type

	-- if activity_type == self.temp_activity_type then
		-- self.node_list["ListView"].scroller:RefreshActiveCellViews()
		-- if self.node_list["Scroller"] then
			self.node_list["Scroller"].scroller:RefreshActiveCellViews()
		-- end
	-- end

	self.temp_activity_type = activity_type
	local active_time_table = os.date('*t',TimeCtrl.Instance:GetServerTime())
	local active_cur_time = active_time_table.hour * 3600 + active_time_table.min * 60 + active_time_table.sec
	local time_limit = 24 * 3600 - active_cur_time
	self:ClickTimer(time_limit)
	if self.time_count == nil then
		self.time_count = CountDown.Instance:AddCountDown(time_limit, 1, 
		function (elapse_time, total_time)
			if total_time > elapse_time then
				local temptime = TimeUtil.FormatSecond(total_time - elapse_time)
				self.node_list["TxtNormalTime"].text.text = tostring(temptime)
			end
		end)
	end
end

function KaifuActivityPanelEveryDayBuy:ClickTimer(offtime)
	offtime = offtime - 1
	local temptime = TimeUtil.FormatSecond(offtime - 1)
	self.node_list["TxtNormalTime"].text.text = tostring(temptime)
end


EveryDayBuyGroup = EveryDayBuyGroup or BaseClass(BaseRender)

function EveryDayBuyGroup:__init()
	self.exchange_list = {}
	for i = 1, PAGE_COUNT do
		local exchange_cell = PanelEveryDayBuyListCell.New(self.node_list["ShowItem" .. i])
		table.insert(self.exchange_list, exchange_cell)
	end
end

function EveryDayBuyGroup:__delete()
	for k, v in ipairs(self.exchange_list) do
		v:DeleteMe()
	end
	self.exchange_list = {}
end

function EveryDayBuyGroup:SetActive(i, enable)
	self.exchange_list[i]:SetActive(enable)
end

function EveryDayBuyGroup:SetIndex(i, index)
	self.exchange_list[i]:SetIndex(index)
end

function EveryDayBuyGroup:SetData(i, data, buy_num)
	self.exchange_list[i]:SetData(data, buy_num)
	self.exchange_list[i]:Flush()
end


PanelEveryDayBuyListCell = PanelEveryDayBuyListCell or BaseClass(BaseRender)

function PanelEveryDayBuyListCell:__init(instance)
	self.index = 1
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["CellItem"])
	self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.OnClickBuy, self))
end

function PanelEveryDayBuyListCell:__delete()
	if self.item ~= nil then
		self.item:DeleteMe()
		self.item = nil
	end
	self.need_data = nil
end

function PanelEveryDayBuyListCell:SetActive(enable)
	self.node_list["Cell"]:SetActive(enable)
end

function PanelEveryDayBuyListCell:OnClickBuy()
	if not self.need_data then
		return
	end
	local buy_info = KaifuActivityData.Instance:GetEverydayBuyInfo()
	if buy_info then
		local buy_num = buy_info[self.index]
		if buy_num >= self.need_data.limit_buy_count then
			TipsCtrl.Instance:ShowSystemMsg(Language.Activity.BuyLimitTip)
			return
		end
	end

	local func = function()
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.need_data.activity_type, RA_LIMIT_BUY_OPERA_TYPE.RA_LIMIT_BUY_OPERA_TYPE_BUY, self.need_data.seq)
	end

	local str = string.format(Language.Activity.BuyGiftTip, self.need_data.gold_price)
	TipsCtrl.Instance:ShowCommonAutoView("everyday_auto_buy", str, func)
end

function PanelEveryDayBuyListCell:SetIndex(index)
	self.index = index
end

function PanelEveryDayBuyListCell:SetData(data, buy_num)
	self.need_data = data
	self.need_buy_num = buy_num >= 0 and buy_num or 0
	self:Flush()
end

function PanelEveryDayBuyListCell:OnFlush()
	local data = self.need_data
	local buy_num = self.need_buy_num
	if not data then return end
	
	local buy_num = buy_num or 0
	self.node_list["TxtPrice"].text.text = string.format(Language.Activity.SpecialPrice_1, data.gold_price) 
	self.node_list["TxtOldPrice"].text.text =  string.format(Language.Activity.OldPrice_1, data.show_price)   
	self.node_list["TxtDiscount"].text.text = string.format(Language.Activity.DisCount, data.discount)

	-- KaifuActivityData.Instance:OutLineRichText(data.limit_buy_count - buy_num, data.limit_buy_count, self.node_list["TxtCount"])
	local str = ""
	if data.limit_buy_count - buy_num == 0 then
		str = string.format(Language.OutLine.RedNumTxt, data.limit_buy_count - buy_num)
	else
		str = string.format(Language.OutLine.GreenNumTxt_1, data.limit_buy_count - buy_num)
	end
	RichTextUtil.ParseRichText(self.node_list["TxtCount"].rich_text, str, 22)

	self.item:SetData(data.reward_item)
	local item_cfg = ItemData.Instance:GetItemConfig(data.reward_item.item_id)

	if item_cfg then
		local time_str = string.format(Language.HefuActivityItemNameColor[item_cfg.color], item_cfg.name)
		RichTextUtil.ParseRichText(self.node_list["TxtGiftName"].rich_text, time_str, 22)		
		--local name_str = "<color=" .. SOUL_NAME_COLOR[item_cfg.color] .. ">" .. item_cfg.name .. "</color>"
		--self.node_list["TxtGiftName"].text.text = name_str
	end

	UI:SetButtonEnabled(self.node_list["BtnBuy"], buy_num < data.limit_buy_count)
	self.node_list["TxtBtnName"].text.text = buy_num < data.limit_buy_count and Language.OpenServer.LiJiGouMai or Language.OpenServer.YiGouMai
end
