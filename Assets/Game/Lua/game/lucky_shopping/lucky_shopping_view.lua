LuckyShoppingView = LuckyShoppingView or BaseClass(BaseView)

function LuckyShoppingView:__init()
	self.ui_config = {{"uis/views/randomact/luckyshopping_prefab", "LuckyShoppingView"}}
	self.is_modal = true
end

function LuckyShoppingView:__delete()
end

--加载回调
function LuckyShoppingView:LoadCallBack()

	self.record_list = {}
	self.list_view = self.node_list["ListView"]
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.list_view.scroll_rect.vertical = false

	self.reward_item_list = {}
	for i = 0, 5 do
		self.reward_item_list[i] = ItemCell.New()
		self.reward_item_list[i]:SetInstanceParent(self.node_list["RewardItem"..i])
	end

	self.grand_prix_item = ItemCell.New()
	self.grand_prix_item:SetShowOrangeEffect(true)
	self.grand_prix_item:SetInstanceParent(self.node_list["GrandPrixItem"])

	self.node_list["ClickClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["ClickLucker"].button:AddClickListener(BindTool.Bind(self.OnClickLucker, self))
	self.node_list["ClickBuy"].button:AddClickListener(BindTool.Bind(self.OnClickBuy, self))
	self.node_list["ClickHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
end

--打开界面的回调
function LuckyShoppingView:OpenCallBack()
	local sever_time = TimeCtrl.Instance:GetServerTime()
	LuckyShoppingData.Instance:SetViewIsOpen(true)
	RemindManager.Instance:Fire(RemindName.LuckyShoppingRemind)

	-- 发送请求协议
	local activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LUCKY_SHOPPING
	local time_stamp = LuckyShoppingData.Instance:GetRetTimesTamp()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(activity_type, RA_LUCKY_CLOUD_BUY_OPERA_TYPE.RA_LUCKY_CLOUD_BUY_TYPE_INFO)
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(activity_type, RA_LUCKY_CLOUD_BUY_OPERA_TYPE.RA_LUCKY_CLOUD_BUY_TYPE_OPEN, time_stamp)

	self.name_list = LuckyShoppingData.Instance:GetNameList() or {}
	self.reward_list_cfg = LuckyShoppingData.Instance:GetRewardShow()
	self.activity_is_open = LuckyShoppingData.Instance:GetLuckyShoppingIsOpen()
end

--关闭界面的回调
function LuckyShoppingView:CloseCallBack()
	local activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LUCKY_SHOPPING
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(activity_type, RA_LUCKY_CLOUD_BUY_OPERA_TYPE.RA_LUCKY_CLOUD_BUY_TYPE_CLOSE)
end

--关闭界面释放回调
function LuckyShoppingView:ReleaseCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.record_list then
		for k,v in pairs(self.record_list) do
			v:DeleteMe()
		end
		self.record_list = {}
	end
	self.list_view = nil

	for k,v in pairs(self.reward_item_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.reward_item_list = {}

	if self.grand_prix_item then
		self.grand_prix_item:DeleteMe()
		self.grand_prix_item = nil
	end
end

--刷新
function LuckyShoppingView:OnFlush(param)
	self.activity_is_open = LuckyShoppingData.Instance:GetLuckyShoppingIsOpen()

	--刷新时间
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end

	for k,v in pairs(param) do
		if k == "flush_record" then
			self:FlushRecord()
		else
			self:FlushReward()
			self:FlushRecord()
		end
	end
end

function LuckyShoppingView:FlushReward()
	-- 奖励显示
	self.reward_list_cfg = LuckyShoppingData.Instance:GetRewardShow()
	if self.reward_list_cfg == nil or next(self.reward_list_cfg) == nil then
		return
	end
	local round_index = self.reward_list_cfg.round_index or 0
	self.node_list["TxtRound"].text.text = string.format(Language.LuckyShopping.LuckyRount, CommonDataManager.GetDaXie(round_index + 1) or 0)
	self.node_list["TxtValue"].text.text = string.format(Language.LuckyShopping.ItemValue, self.reward_list_cfg.big_reward_value or 0)

	self.grand_prix_item:SetData(self.reward_list_cfg.grand_prix_item or {})
	local reward_list = self.reward_list_cfg.min_reward_item

	if reward_list then
		for i = 0, 5 do
			if reward_list[i] then
				self.reward_item_list[i]:SetParentActive(true)
				self.reward_item_list[i]:SetData(reward_list[i])
			else
				self.reward_item_list[i]:SetParentActive(false)
			end
		end
	end
end

function LuckyShoppingView:FlushRecord()
	self.name_list = LuckyShoppingData.Instance:GetNameList() or {}
	if self.list_view then
		self.list_view.scroller:ReloadData(0)
	end

	-- 数据刷新
	local buy_count = LuckyShoppingData.Instance:GetTotalBuy()
	local need_gold, total_count = LuckyShoppingData.Instance:GetNeedGold()
	local remind_count = total_count - buy_count
	if remind_count <= 0 then
		remind_count = ToColorStr(remind_count, TEXT_COLOR.RED)
	end

	self.node_list["TxtBuyNums"].text.text = string.format(Language.LuckyShopping.LuckyBuyNums, LuckyShoppingData.Instance:GetSelfBuy() or 0) 
	self.node_list["TxtStoreNums"].text.text = string.format(Language.LuckyShopping.LuckyStoreNums, remind_count or 0)
	self.node_list["GoldCost"].text.text = need_gold
end

function LuckyShoppingView:FlushNextTime()
	local time = 0
	if LuckyShoppingData.Instance:GetLuckyShoppingIsOpen() then
		time = LuckyShoppingData.Instance:LuckyShoppingRoundLeastTime()
	else
		time = LuckyShoppingData.Instance:LuckyShoppingRoundNextOpenTime()
	end
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
		self.node_list["TxtActTime"].text.text = Language.LuckyShopping.TimeText3
		return
	end

	local time_str = ""
	if time > 3600 then
		time_str = TimeUtil.FormatSecond(time, 1)
	else
		time_str = TimeUtil.FormatSecond(time, 2)
	end
	local time_text = string.format(Language.LuckyShopping.TimeText1, time_str)
	if self.activity_is_open == false then
		time_text = string.format(Language.LuckyShopping.TimeText2, time_str)
	end
	self.node_list["TxtActTime"].text.text = time_text
end

function LuckyShoppingView:GetNumberOfCells()
	return self.name_list and #self.name_list or 0
end

function LuckyShoppingView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local list_cell = self.record_list[cell]
	if not list_cell then
		list_cell = NameListCell.New(cell.gameObject)
		self.record_list[cell] = list_cell
	end
	list_cell:SetIndex(data_index)
	local cross_rank_type_list = CrossRankData.Instance:GetCrossRankTypeList()
	local data = self.name_list[data_index]
	list_cell:SetData(data)
end

function LuckyShoppingView:OnClickClose()
	self:Close()
end

function LuckyShoppingView:OnClickLucker()
	local activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LUCKY_SHOPPING
	ActivityCtrl.Instance:SendActivityLogSeq(activity_type)
	-- ActivityData.Instance:SendActivityLogType(activity_type)
	-- KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(activity_type, RA_LUCKY_CLOUD_BUY_OPERA_TYPE.RA_LUCKY_CLOUD_BUY_TYPE_LUCKY)
end

function LuckyShoppingView:OnClickBuy()
	local need_gold, sale_count = LuckyShoppingData.Instance:GetNeedGold()
	local count = LuckyShoppingData.Instance:GetTotalBuy()

	-- 本轮未开启
	if self.activity_is_open == false then
		TipsCtrl.Instance:ShowSystemMsg(Language.LuckyShopping.ActivityCloseText)
		return
	end

	-- 已售完
	if sale_count <= count then
		TipsCtrl.Instance:ShowSystemMsg(Language.LuckyShopping.SoldOutText)
		return
	end

	-- 金币不足
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if vo.gold < need_gold then
		TipsCtrl.Instance:ShowLackDiamondView()
		return
	end

	local gold_max = math.floor(vo.gold / need_gold)
	local remind_count = sale_count - count
	remind_count = math.min(remind_count, 999)
	local max = math.min(gold_max, remind_count)

	TipsCtrl.Instance:OpenCommonInputView(1, BindTool.Bind(self.CountInputCallBack, self), nil, max)
end

function LuckyShoppingView:CountInputCallBack(str)
	local count = tonumber(str)
	if count < 1 then
		return
	end

	local need_gold, sale_count = LuckyShoppingData.Instance:GetNeedGold()
	need_gold = need_gold * count
	local des = string.format(Language.LuckyShopping.BuyText, need_gold)
	local ok_callback = function ()
		local activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LUCKY_SHOPPING
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(activity_type, RA_LUCKY_CLOUD_BUY_OPERA_TYPE.RA_LUCKY_CLOUD_BUY_TYPE_BUY, count)
	end
	TipsCtrl.Instance:ShowCommonAutoView("LuckyShopping", des, ok_callback)	
end

function LuckyShoppingView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(331)
end

----------------------------------- 记录Item -----------------------------------
NameListCell = NameListCell  or BaseClass(BaseCell)

function NameListCell:__init()
	
end

function NameListCell:__delete()
end

function NameListCell:SetIndex(index)
	self.index = index
end

function NameListCell:SetData(data)
	self.node_list["Text"].text.text = string.format(Language.LuckyShopping.LuckyBuyName, data or "")
end