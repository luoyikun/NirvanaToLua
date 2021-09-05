GoldMemberShop = GoldMemberShop or BaseClass(BaseView)

local PAGE_ROW = 1					--行
local PAGE_COLUMN = 3				--列

function GoldMemberShop:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelOne"},
		{"uis/views/goldmember_prefab", "GoldMemberShopView"},
	}
	self.full_screen = false
	self.play_audio = true
	self.def_index = 0
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function GoldMemberShop:ReleaseCallBack()
	if self.exchange_cell_list ~= nil then
		for k, v in pairs(self.exchange_cell_list) do
			v:DeleteMe()
		end
	end
	self.exchange_cell_list = nil

	-- 清理变量和对象
	self.exchange_list = nil

end

--关闭黄金会员商店
function GoldMemberShop:BackOnClick()
	ViewManager.Instance:Close(ViewName.GoldMemberShop)
end

function GoldMemberShop:OpenVipOnClick()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function GoldMemberShop:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.BackOnClick, self))
	self.node_list["Button"].button:AddClickListener(BindTool.Bind(self.OpenVipOnClick, self))
	self.node_list["Name"].text.text = Language.GoldMember.Title1

	self.exchange_listview_data = {}
	self.exchange_cell_list = {}
	self.exchange_listview_data = GoldMemberData.Instance:GetShopInfo()
	local page = math.ceil(#self.exchange_listview_data / PAGE_COLUMN)

	for i = 1, 20 do
		self.node_list["Toggle" .. i]:SetActive(i <= page)
	end

	local convert_rate = GoldMemberData.Instance:GetGoldCfg()[1].convert_rate
	local active_convert_gold = GoldMemberData.Instance:GetGoldCfg()[1].active_convert_gold
	self.node_list["Desc"].text.text = string.format(Language.GoldMember.Member_shop_Description, convert_rate, active_convert_gold)
	self.node_list["ListView"].list_page_scroll:SetPageCount(page)
	self.node_list["Toggle1"].toggle.isOn = true

	local exchange_list_delegate = self.node_list["ListView"].list_simple_delegate
	exchange_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCellNumber, self)
	exchange_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshDel, self)

	self:Flush()
end

function GoldMemberShop:GetCellNumber()
	return math.ceil(#self.exchange_listview_data/PAGE_COLUMN)
end

function GoldMemberShop:RefreshDel(cell, data_index)
	local exchange_group_cell = self.exchange_cell_list[cell]
	if not exchange_group_cell then
		exchange_group_cell = GoldMemberGroupCell.New(cell.gameObject)
		self.exchange_cell_list[cell] = exchange_group_cell
	end

	for i = 1, PAGE_COLUMN do
		local index = data_index * PAGE_COLUMN + i
		local data = self.exchange_listview_data[index]
		if data then
			exchange_group_cell:SetActive(i, true)
			exchange_group_cell:SetIndex(i, index)
			exchange_group_cell:SetData(i, data)
		else
			discount_group_cell:SetActive(i, false)
		end
	end
end

function GoldMemberShop:OpenCallBack()
end

-- 刷新
function GoldMemberShop:OnFlush(param_t, index)
	-- 设置数据
	self.exchange_listview_data = GoldMemberData.Instance:GetShopInfo()
	self.node_list["ListView"].scroller:RefreshActiveCellViews()
	self.node_list["Gold"].text.text = GoldMemberData.Instance:GetDayScore()

end


--------------------------------------------------------------------------------------------------

GoldMemberGroupCell = GoldMemberGroupCell or BaseClass(BaseRender)

function GoldMemberGroupCell:__init()
	self.exchange_list = {}
	for i = 1, PAGE_COLUMN do
		local exchange_cell = GoldMemberItem.New(self.node_list["GoldMemberItem" .. i])
		table.insert(self.exchange_list, exchange_cell)
	end
end

function GoldMemberGroupCell:__delete()
	for k, v in ipairs(self.exchange_list) do
		v:DeleteMe()
	end
	self.exchange_list = {}
end

function GoldMemberGroupCell:SetActive(i, enable)
	self.exchange_list[i]:SetActive(enable)
end

function GoldMemberGroupCell:SetIndex(i, index)
	self.exchange_list[i]:SetIndex(index)
end

function GoldMemberGroupCell:SetData(i, data)
	self.exchange_list[i]:SetData(data)
end

function GoldMemberGroupCell:StopCountDown()
	for k, v in ipairs(self.exchange_list) do
		v:ClearCountDown()
	end
end


---------------------------------------------------------------------------
GoldMemberItem = GoldMemberItem or BaseClass(BaseCell)

function GoldMemberItem:__init(instance, left_view)
	self.left_view = left_view
	
	self:IconInit()
end

function GoldMemberItem:__delete()
	self.item_cell:DeleteMe()
end

function GoldMemberItem:IconInit()
	self.node_list["Button"].button:AddClickListener(BindTool.Bind(self.ExchangeOnClick, self))

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["Item"])

end

function GoldMemberItem:OnFlush()
	local config = ItemData.Instance:GetItemConfig(self.data.reward_item.item_id)
	local por_name = "<color="..SOUL_NAME_COLOR[config and config.color or 1]..">"..config.name.."</color>"
		self.node_list["Name"].text.text = por_name

	if not self.data or not next(self.data) then return end
	
	local count = 0
	if self.data.limit_times == 0 then
		self.bottom_text:SetActive(false)
	elseif GoldMemberData.Instance:GetShopIndexCount(self.index) ~= nil then
		if self.data.limit_times - GoldMemberData.Instance:GetShopIndexCount(self.index) > 0 then
			count = self.data.limit_times - GoldMemberData.Instance:GetShopIndexCount(self.index)
		else
			count = 0
		end
		if count == 0 then
			UI:SetButtonEnabled(self.node_list["Button"], false)
		end
	end
	self.item_cell:SetData(self.data.reward_item)

	local exchange_count = GoldMemberData.Instance:GetShopIndexCount(self.index)
	local cur_score, next_score = GoldMemberData.Instance:GetExchangeScoreBySeq(self.data.seq, exchange_count)
	if not cur_score then
		-- 找不到配置，用回减一次数的配置
		cur_score, next_score = GoldMemberData.Instance:GetExchangeScoreBySeq(self.data.seq, exchange_count - 1)
		self.node_list["Integrel"].text.text = cur_score.price_multile * self.data.consume_val
		self.node_list["BottomText"].text.text = Language.GoldMember.Member_shop_LimitExchage3
		return
	end 
	self.node_list["Integrel"].text.text = cur_score.price_multile * self.data.consume_val
	if next_score then
		self.node_list["BottomText"].text.text = string.format(Language.GoldMember.Member_shop_LimitExchage2, cur_score.times_max - exchange_count)
	else
		self.node_list["BottomText"].text.text = string.format(Language.GoldMember.Member_shop_LimitExchage, self.data.limit_times - exchange_count)
	end

	if GoldMemberData.Instance:CheckIFOpenSeal(self.index - 1) == false then
		UI:SetButtonEnabled(self.node_list["Button"], false)
		self.node_list["BottomText"].text.text = Language.GoldMember.Member_shop_open
	else
		UI:SetButtonEnabled(self.node_list["Button"], true)
	end
end

function GoldMemberItem:ExchangeOnClick()
	if not self.data or not next(self.data) then return end

	GoldMemberCtrl.Instance:SendGoldVipOperaReq(GOLD_VIP_OPERA_TYPE.OPERA_TYPE_CONVERT_SHOP, self.data.seq)
end
