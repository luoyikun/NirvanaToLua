BlackMarketView = BlackMarketView or BaseClass(BaseView)

function BlackMarketView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_1"},
		{"uis/views/randomact/blackmarket_prefab", "BlackMarketView"},
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_2"},
	}
	self.play_audio = true
	self.cell_list = {}
end

function BlackMarketView:__delete()

end

function BlackMarketView:LoadCallBack()
	self.node_list["Name"].text.text = Language.Activity.BlackMarket
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["TipsBtn"].button:AddClickListener(BindTool.Bind(self.OnClickTipButton, self))
	self:InitScroller()
end

function BlackMarketView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	-- 清理变量和对象
	self.scroller = nil
	self.act_time = nil
	self.bid_time = nil
end

function BlackMarketView:InitScroller()
	self.data = BlackMarketData.Instance:GetItemInfoList()
	local delegate = self.node_list["ListView"].list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	-- 格子刷新
	delegate.CellRefreshDel = BindTool.Bind(self.GetCellRefreshDel, self)
end

function BlackMarketView:GetNumberOfCells()
	local data_list = BlackMarketData.Instance:GetItemInfoList()
	return data_list and #data_list or 0
end

function BlackMarketView:GetCellRefreshDel(cell, data_index, cell_index)
	data_index = data_index + 1
	local target_cell = self.cell_list[cell]

	if nil == target_cell then
		self.cell_list[cell] = BlackMarketCell.New(cell.gameObject)
		target_cell = self.cell_list[cell]
	end

	local data_list = BlackMarketData.Instance:GetItemInfoList()
	target_cell:SetData(data_list[data_index])
end

function BlackMarketView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BLACKMARKET_AUCTION, RA_BLACK_MARKET_OPERA_TYPE.RA_BLACK_MARKET_OPERA_TYPE_ALL_INFO)
end

function BlackMarketView:OnClickTipButton()
	local tips_id = 250 -- 黑市拍卖
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end



function BlackMarketView:ShowIndexCallBack(index)

end

function BlackMarketView:CloseCallBack()

end

function BlackMarketView:OnFlush(param_t)
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end

	if self.node_list["ListView"] then
		self.node_list["ListView"].scroller:ReloadData(0)
	end
end

function BlackMarketView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BLACKMARKET_AUCTION)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end

	if time > 3600 * 24 then
		self.node_list["TxtTime"].text.text = string.format(Language.Market.BlackMarketViewLastTime, "<color='#00ff00'>" .. TimeUtil.FormatSecond(time, 6) .. "</color>")
	elseif time > 3600 then
		self.node_list["TxtTime"].text.text = string.format(Language.Market.BlackMarketViewLastTime, "<color='#00ff00'>" .. TimeUtil.FormatSecond(time, 7) .. "</color>")
	else
		self.node_list["TxtTime"].text.text = string.format(Language.Market.BlackMarketViewLastTime, "<color='#00ff00'>" .. TimeUtil.FormatSecond(time, 7) .. "</color>")
	end

	local now_time = TimeCtrl.Instance:GetServerTime()
	local day_end_time = TimeUtil.NowDayTimeEnd(now_time) - now_time
	if day_end_time > 3600 * 24 then
		self.node_list["TxtCountdown"].text.text = string.format(Language.Market.BlackMarketBidTime, "<color='#00ff00'>" .. TimeUtil.FormatSecond(day_end_time, 6) .. "</color>")
	elseif day_end_time > 3600 then
		self.node_list["TxtCountdown"].text.text = string.format(Language.Market.BlackMarketBidTime, "<color='#00ff00'>" .. TimeUtil.FormatSecond(day_end_time, 7) .. "</color>")
	else
		self.node_list["TxtCountdown"].text.text = string.format(Language.Market.BlackMarketBidTime, "<color='#00ff00'>" .. TimeUtil.FormatSecond(day_end_time, 7) .. "</color>")
	end
end

---------------------------------------------------------------
--滚动条格子

BlackMarketCell = BlackMarketCell or BaseClass(BaseCell)

function BlackMarketCell:__init()
	self.reward_item = ItemCell.New()
	self.reward_item:SetInstanceParent(self.node_list["Item"])
	self.node_list["BtnStart"].button:AddClickListener(BindTool.Bind(self.ClickBuy, self))
end

function BlackMarketCell:__delete()
	self.reward_item:DeleteMe()
	self.reward_item = nil

	self.item_name = nil
	self.low_price = nil
	self.cur_price = nil
	self.role_name = nil
	self.desc = nil
end

function BlackMarketCell:OnFlush()
	if nil == self.data then
		return
	end

	local cfg = BlackMarketData.Instance:GetItemConfigBuySeq(self.data.seq)
	if nil == cfg then
		self.root_node:SetActive(false)
		return
	end

	self.root_node:SetActive(true)
	self.reward_item:SetData(cfg.item)
	self.node_list["TxtDesc"].text.text = cfg.description

	local item_cfg = ItemData.Instance:GetItemConfig(cfg.item.item_id)
	local name_str = string.format(Language.Common.ToColor, SOUL_NAME_COLOR[item_cfg.color], item_cfg.name)
	self.node_list["TxtTitle"].text.text = name_str
	self.node_list["TxtDangqianGold"].text.text = ToColorStr(self.data.cur_price, TEXT_COLOR.GREEN)
	self.node_list["TxtQipaiGold"].text.text = cfg.init_gold
	local jingjia_str = ToColorStr(Language.Activity.Jingjia, TEXT_COLOR.WHITE)
	self.node_list["TxtRoleName"].text.text =  jingjia_str .. ToColorStr(self.data.buyer_uid > 0 and self.data.buyer_name or Language.Activity.NoOneBuy, TEXT_COLOR.GREEN)
end

function BlackMarketCell:ClickBuy()
	BlackMarketCtrl.Instance:OpenBlackMarketBidView(self.data)
end