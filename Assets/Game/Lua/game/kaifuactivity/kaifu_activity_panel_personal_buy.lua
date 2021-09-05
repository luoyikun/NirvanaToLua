KaifuActivityPanelPersonBuy = KaifuActivityPanelPersonBuy or BaseClass(BaseRender)
local PAGE_COUNT = 3
--开服活动 个人抢购 panel11
function KaifuActivityPanelPersonBuy:__init(instance)
	self.list_delegate = self.node_list["ScrollerListView"].list_simple_delegate
	self.list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	for i = 1, 5 do
		self.node_list["PageToggle" .. i] :SetActive(false)
	end
	
	
	self.cell_list = {}
end
function KaifuActivityPanelPersonBuy:LoadCallBack()
	
end
function KaifuActivityPanelPersonBuy:__delete()
	self.temp_activity_type = nil
	self.activity_type = nil

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end

	self.cell_list = {}
end
function KaifuActivityPanelPersonBuy:OpenCallBack()
end

function KaifuActivityPanelPersonBuy:GetNumberOfCells()
	local personal_actiivity_sort_cfg = KaifuActivityData.Instance:GetPersonalActivitySortCfg()
	local count = math.ceil(#personal_actiivity_sort_cfg / PAGE_COUNT)

	if count >= 2 then
		for i = 1, count do
			self.node_list["PageToggle" .. i]:SetActive(true)
		end
		self.node_list["ScrollerListView"].list_page_scroll:SetPageCount(count)
	end
	return math.ceil(#personal_actiivity_sort_cfg / PAGE_COUNT) * PAGE_COUNT
end

function KaifuActivityPanelPersonBuy:RefreshCell(cell, cell_index)
	local cell_item = self.cell_list[cell]

	if cell_item == nil then
		cell_item = PanelPersonBuyListCell.New(cell.gameObject)
		self.cell_list[cell] = cell_item
	end
	local activity_sort_cfg = KaifuActivityData.Instance:GetPersonalActivitySortCfg()
	local sort_cfg = activity_sort_cfg[cell_index + 1]

	if sort_cfg ~= nil then 
		local cfg = KaifuActivityData.Instance:GetPersonalActivityCfgBySeq(sort_cfg.seq)
		local buy_info = KaifuActivityData.Instance:GetPersonalBuyInfo()

		cell_item:SetData(cfg, buy_info[cfg.seq + 1])
	end
	cell_item.root_node:SetActive(sort_cfg ~= nil)
end

function KaifuActivityPanelPersonBuy:Flush(activity_type)
	self.activity_type = activity_type or self.activity_type
	if activity_type == self.temp_activity_type then
		self.node_list["ScrollerListView"].scroller:ReloadData(0)
		-- self.node_list["ScrollerListView"].list_page_scroll:JumpToPageImmidate(0)
	end

	self.temp_activity_type = activity_type
end


PanelPersonBuyListCell = PanelPersonBuyListCell or BaseClass(BaseRender)

function PanelPersonBuyListCell:__init(instance)
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["CellItem"])
	self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.OnClickBuy, self))

end

function PanelPersonBuyListCell:__delete()
	if self.item ~= nil then
		self.item:DeleteMe()
		self.item = nil
	end
end
function PanelPersonBuyListCell:SetData(data, buy_num)
	self.need_data = data
	self.need_buy_num = buy_num
	self:ItemFlush()
end
function PanelPersonBuyListCell:ItemFlush()
	local data = self.need_data
	local buy_num = self.need_buy_num
	if not data then return end
	
	local buy_num = buy_num or 0
	self.node_list["TxtPrice"].text.text = string.format(Language.Activity.SpecialPrice_1, data.gold_price) 
	self.node_list["TxtOldPrice"].text.text =  string.format(Language.Activity.OldPrice_1, data.show_price)   
	self.node_list["TxtDiscount"].text.text = string.format(Language.Activity.DisCount, data.discount)

	local str = ""
	if data.limit_buy_count - buy_num > 0 then
		str = string.format(Language.OutLine.GreenNumTxt_1, data.limit_buy_count - buy_num)
	else
		str = string.format(Language.OutLine.RedNumTxt, data.limit_buy_count - buy_num)
	end
	RichTextUtil.ParseRichText(self.node_list["TxtCount"].rich_text, str, 22)

	self.item:SetData(data.reward_item)
	local item_cfg = ItemData.Instance:GetItemConfig(data.reward_item.item_id)

	if item_cfg then
		local time_str = string.format(Language.HefuActivityItemNameColor[item_cfg.color], item_cfg.name)
		RichTextUtil.ParseRichText(self.node_list["TxtGiftName"].rich_text, time_str, 22)		
		-- local name_str = "<color=" .. SOUL_NAME_COLOR[item_cfg.color] .. ">" .. item_cfg.name .. "</color>"
		-- self.node_list["TxtGiftName"].text.text = name_str
	end

	UI:SetButtonEnabled(self.node_list["BtnBuy"], buy_num < data.limit_buy_count)
	self.node_list["TxtBtnName"].text.text = buy_num < data.limit_buy_count and Language.OpenServer.LiJiGouMai or Language.OpenServer.YiGouMai
end

function PanelPersonBuyListCell:OnClickBuy()
	local cfg = self.need_data
	if not cfg then
		return
	end

	if self.need_buy_num >= cfg.limit_buy_count then
		TipsCtrl.Instance:ShowSystemMsg(Language.Activity.BuyLimitTip)
		return
	end

	local func = function()
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(cfg.activity_type, RA_PERSONAL_PANIC_BUY_OPERA_TYPE.RA_PERSONAL_PANIC_BUY_OPERA_TYPE_BUY_ITEM, cfg.seq)
	end

	local str = string.format(Language.Activity.BuyGiftTip, cfg.gold_price)
	TipsCtrl.Instance:ShowCommonAutoView("personal_auto_buy", str, func)
end