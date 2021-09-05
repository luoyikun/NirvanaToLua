TreasureBusinessmanView = TreasureBusinessmanView or BaseClass(BaseView)

function TreasureBusinessmanView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_1"},
		{"uis/views/businessmanview_prefab", "BusinessmanView"},
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_2"},
	}

	self.item_list = {}
	self.display_item_list = {}
	self.item_buffer = {}
	self.card_status = {}
	self.rare_list = {}
	self.all_buy_gold = 0
	self.zhenbaoge2_reflush_gold = 0
	self.zhenbaoge2_auto_flush_times = 0
	self.refresh_tags = false

	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp

end

function TreasureBusinessmanView:LoadCallBack()
	-- self.node_list["ImgTitle"].image:LoadSprite("uis/views/businessmanview/images_atlas","shenmi_text.png")
	-- self.node_list["ImgTitle"].image:SetNativeSize()
	self.node_list["Name"].text.text = Language.TreasureBusinessman.Title
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	
	self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.SendBuyAllItemsReq, self))
	self.node_list["BtnRefreshTen"].button:AddClickListener(BindTool.Bind(self.RefreshAllItems, self, 1))
	self.node_list["BtnRefreshOne"].button:AddClickListener(BindTool.Bind(self.RefreshAllItems, self, 0))
	self.node_list["BtnTip"].button:AddClickListener(BindTool.Bind(self.OpenTreasureLoftTips, self))
	self.node_list["BtnLucky"].button:AddClickListener(BindTool.Bind(self.OnClickLog, self))
	for i = 1, 6 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["Item" .. i])
	end
	for i = 1, 9 do
		self.display_item_list[i] = ItemCell.New()
		self.display_item_list[i]:SetInstanceParent(self.node_list["ItemDisplay" .. i])
		self.display_item_list[i]:ListenClick(BindTool.Bind2(self.SendRollCard, self, i))
		self.node_list["ItemDisplay" .. i].button:AddClickListener(BindTool.Bind(self.SendRollCard, self, i))
		self.node_list["card_item" .. i].button:AddClickListener(BindTool.Bind(self.SendRollCard, self, i))
	end

	self.total_reward_item_list = {}
	for i = 1, 6 do
		local total_reward_item = TotalrewardItem.New(self.node_list["reward_item" .. i])
		table.insert(self.total_reward_item_list, total_reward_item)
		self.total_reward_item_list[i]:SetCurIndex(i)
	end

	self:InitRareItemsDisplay()
	self:InitRollView()
end

function TreasureBusinessmanView:__delete()

end

function TreasureBusinessmanView:ReleaseCallBack()
	for i = 1, 6 do
		self.item_list[i]:DeleteMe()
	end
	self.item_list = {}

	for i = 1, 9 do
		self.display_item_list[i]:DeleteMe()
	end
	self.display_item_list = {}

	for k,v in pairs(self.total_reward_item_list) do
		v:DeleteMe()
	end
	self.total_reward_item_list = {}

	self.item_buffer = {}
	self.card_status = {}
	self.rare_list = {}

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.tweener1 then
		self.tweener1:Pause()
		self.tweener1 = nil
	end
	if self.tweener2 then
		self.tweener2:Pause()
		self.tweener2 = nil
	end

	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
	end

	if self.delay_timer2 then
		GlobalTimerQuest:CancelQuest(self.delay_timer2)
	end
end

function TreasureBusinessmanView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_BUSINESSMAN, RA_ZHENBAOGE_OPERA_TYPE.RA_ZHENBAOGE_OPERA_TYPE_QUERY_INFO)
	self:Flush()
	RemindManager.Instance:SetRemindToday(RemindName.ZhenBaoge2)
end

function TreasureBusinessmanView:CloseCallBack()

end

function TreasureBusinessmanView:OpenTreasureLoftTips()
	TipsCtrl.Instance:ShowHelpTipView(226)
end

function TreasureBusinessmanView:OnClickLog()
	ActivityCtrl.Instance:SendActivityLogSeq(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_BUSINESSMAN)
end

function TreasureBusinessmanView:InitRareItemsDisplay()
	for i = 1, 9 do
		self.node_list["ImgCard" .. i]:SetActive(true)
	end
	local rare_item_table = TreasureBusinessmanData.Instance:GetDisplayItemTable()
	if rare_item_table ~= nil then
		for i = 1, 6 do
			if rare_item_table[i - 1] then
				self.item_list[i]:SetData(rare_item_table[i - 1])
			end
		end
	end
end

function TreasureBusinessmanView:InitRollView()
	local zhenbaoge2_cfg = KaifuActivityData.Instance:GetZhenBaoGe2Cfg()
	if zhenbaoge2_cfg == nil then return end
	local other_cfg = PlayerData.Instance:GetCurrentRandActivityConfig()
	local str = ""
	if other_cfg ~= nil and other_cfg.other[1] ~= nil and other_cfg.other[1].zhenbaoge2_all_buy_reward ~= nil then
		str = ItemData.Instance:GetItemName(other_cfg.other[1].zhenbaoge2_all_buy_reward.item_id)
	end
	local tips = string.format(Language.TreasureLoft.BuyAllDesc, str)

	self.zhenbaoge2_reflush_gold = other_cfg.other[1].zhenbaoge2_reflush_gold
	self.zhenbaoge2_auto_flush_times = other_cfg.other[1].zhenbaoge2_auto_flush_times
	self.node_list["TxtGold"].text.text = self.zhenbaoge2_reflush_gold
	for i = 1, GameEnum.RAND_ACTIVITY_ZHENBAOGE_ITEM_COUNT do
		if nil ~= self.display_item_list[i] then
			self.card_status[i] = NEQ_CARD_STATUS.OPEN
			self.display_item_list[i]:SetData(zhenbaoge2_cfg[1].reward_item)
			self.node_list["TxtPrice" .. i].text.text = zhenbaoge2_cfg[1].buy_consume_gold
		end
	end
	self.node_list["TextDesc"].text.text = tips
end

function TreasureBusinessmanView:RefreshAllItems(num)
	if self.refresh_tags then
		return 
	end
	local flag = TreasureBusinessmanData.Instance:HasRareItemNotBuy()
	local gold = (num == 0) and (self.zhenbaoge2_reflush_gold) or (self.zhenbaoge2_reflush_gold*self.zhenbaoge2_auto_flush_times)
	local player_data = PlayerData.Instance:GetRoleVo()

	if player_data and player_data.gold and player_data.gold < gold then
		TipsCtrl.Instance:ShowLackDiamondView()
		return
	end
	if flag then
		local yes_func = function()
			if 0 == num then
				self:SendReq(0)
			elseif 1 == num then
				self:SendReq(1)
			end
		end
		local tips = Language.TreasureBusinessman.HasRare
		local ok_des = Language.TreasureBusinessman.KeepRefreh
		TipsCtrl.Instance:ShowCommonAutoView("", tips, yes_func, nil, nil, ok_des, nil, nil, nil, true)
	else
		if 0 == num then
			local tips = string.format(Language.TreasureLoft.ResetTips, self.zhenbaoge2_reflush_gold)
			local yes_func = function() self:SendReq(0) end
			TipsCtrl.Instance:ShowCommonAutoView("refresh2_one", tips, yes_func, nil, nil, nil, nil, nil, nil, true, false)
		elseif 1 == num then
			local tips = string.format(Language.TreasureLoft.OneKeyResetRare, self.zhenbaoge2_reflush_gold*self.zhenbaoge2_auto_flush_times, self.zhenbaoge2_auto_flush_times)
			local yes_func = function() self:SendReq(1) end
			TipsCtrl.Instance:ShowCommonAutoView("refresh2_ten", tips, yes_func, nil, nil, nil, nil, nil, nil, true, false)
		end
	end
end

function TreasureBusinessmanView:SendReq(num)
	if num == 0 then
		self.refresh_tags = true
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_BUSINESSMAN, RA_ZHENBAOGE_OPERA_TYPE.RA_ZHENBAOGE_OPEAR_TYPE_FLUSH)
	elseif num == 1 then
		self.refresh_tags = true
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_BUSINESSMAN, RA_ZHENBAOGE_OPERA_TYPE.RA_ZHENBAOGE_OPEAR_TYPE_RARE_FLUSH)
	elseif num == 2 then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_BUSINESSMAN, RA_ZHENBAOGE_OPERA_TYPE.RA_ZHENBAOGE_OPEAR_TYPE_BUY_ALL)
	end
end

function TreasureBusinessmanView:SendRollCard(index)
	if NEQ_CARD_STATUS.DEFAULT == self.card_status[index] then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_BUSINESSMAN, RA_ZHENBAOGE_OPERA_TYPE.RA_ZHENBAOGE_OPERA_TYPE_BUY, index -1)
		return
	end
	self.display_item_list[index]:SetHighLight(false)
	if not next(self.item_buffer) then return end
	local item_name = ItemData.Instance:GetItemName(self.item_buffer[index].item.item_id)

	local tips = string.format(Language.TreasureLoft.DrawTips, self.item_buffer[index].price , item_name, self.item_buffer[index].item.num)
	local yes_func = function()
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_BUSINESSMAN, RA_ZHENBAOGE_OPERA_TYPE.RA_ZHENBAOGE_OPERA_TYPE_BUY, index -1)
	end
	TipsCtrl.Instance:ShowCommonAutoView("buy_one", tips, yes_func, nil, nil, nil, nil, nil, nil, true, false)
end

function TreasureBusinessmanView:SendBuyAllItemsReq()
	local str = ""
	local randact_cfg = PlayerData.Instance:GetCurrentRandActivityConfig()
	if randact_cfg ~= nil and randact_cfg.other[1] ~= nil and randact_cfg.other[1].zhenbaoge2_all_buy_reward ~= nil then
		str = ItemData.Instance:GetItemName(randact_cfg.other[1].zhenbaoge2_all_buy_reward.item_id)
	end
	if self.all_buy_gold > 0 then
		local tips = string.format(Language.TreasureLoft.AllBuyTips,self.all_buy_gold, str)
		local yes_func = function() self:SendReq(2) end
		TipsCtrl.Instance:ShowCommonAutoView("buy_ten", tips, yes_func, nil, nil, nil, nil, nil, nil, true, false)
	else
		self:SendReq(2)
	end
end

function TreasureBusinessmanView:DoCardFlipAction()
	for i = 1, 9 do
		self.node_list["ImgCard" .. i]:SetActive(true)
		self.node_list["card_item" .. i].rect:SetLocalScale(1, 1, 1)
		local target_scale = Vector3(0, 1, 1)
		local target_scale2 = Vector3(1, 1, 1)
		self.tweener1 = self.node_list["card_item" .. i].rect:DOScale(target_scale, 0.5)

		local func2 = function()
			self.tweener2 = self.node_list["card_item" .. i].rect:DOScale(target_scale2, 0.5)
			self.refresh_tags = false
		end
		self.delay_timer2 = GlobalTimerQuest:AddDelayTimer(func2, 0.5)

	end
	local func = function()
		self:ResetItemGrid()
	end
	self.delay_timer = GlobalTimerQuest:AddDelayTimer(func, 0.5)
end

function TreasureBusinessmanView:ResetItemGrid( ... )
	for i = 1,9 do
		self.node_list["ImgCard" .. i]:SetActive(false)
	end
end

function TreasureBusinessmanView:FlushNextFlushTimer()
	local nexttime = TreasureBusinessmanData.Instance:GetNextFlushTimeStamp() - TimeCtrl.Instance:GetServerTime()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if nexttime ~= nil then	
		 self:UpdataRollerTime(0, nexttime)
		 self.count_down = CountDown.Instance:AddCountDown(nexttime,1,BindTool.Bind1(self.UpdataRollerTime, self))	
	end
end

function TreasureBusinessmanView:UpdataRollerTime(elapse_time, next_time)
	local time = next_time - elapse_time
	self.node_list["TxtTime"].text.text = time > 0 and TimeUtil.FormatSecond2HMS(time) or "00:00:00"
end

function TreasureBusinessmanView:OnFlush()
	self:FlushItemGrid()
	self:FlushServerFetchReward()
	self:FlushNextFlushTimer()
end

function TreasureBusinessmanView:FlushItemGrid()
	self.all_buy_gold = 0
	local zhenbaoge_item_list = TreasureBusinessmanData.Instance:GetTreasureLoftGridData()
	local zhenbaoge2_cfg = KaifuActivityData.Instance:GetZhenBaoGe2Cfg()
	if zhenbaoge2_cfg == nil or zhenbaoge_item_list == nil then return end
	for i = 0, #zhenbaoge_item_list do
		if zhenbaoge_item_list[i] and zhenbaoge_item_list[i] ~= 0 then
			local data = {}
			self.card_status[i + 1] = NEQ_CARD_STATUS.OPEN

			self.display_item_list[i + 1]:SetData(zhenbaoge2_cfg[zhenbaoge_item_list[i]].reward_item)
			self.rare_list[i + 1] = zhenbaoge2_cfg[zhenbaoge_item_list[i]].is_rare
			self.node_list["ImgCard" .. (i + 1)]:SetActive(false)
			self.node_list["TxtPrice" .. (i + 1)].text.text = zhenbaoge2_cfg[zhenbaoge_item_list[i]].buy_consume_gold

			if 1 == self.rare_list[i + 1] then
				self.display_item_list[i + 1]:ShowGetEffect(true)
			else
				self.display_item_list[i + 1]:ShowGetEffect(false)
			end

			data.item = zhenbaoge2_cfg[zhenbaoge_item_list[i]].reward_item
			data.price = zhenbaoge2_cfg[zhenbaoge_item_list[i]].buy_consume_gold
			data.is_rare = zhenbaoge2_cfg[zhenbaoge_item_list[i]].is_rare

			self.item_buffer[i + 1] = data

			local item_name = ItemData.Instance:GetItemName(self.item_buffer[i + 1].item.item_id)
			local item_num = zhenbaoge2_cfg[zhenbaoge_item_list[i]].reward_item.num
			local item_cfg = ItemData.Instance:GetItemConfig(self.item_buffer[i + 1].item.item_id)
			if item_name == nil or item_cfg == nil then return end

			self.all_buy_gold = self.all_buy_gold + zhenbaoge2_cfg[zhenbaoge_item_list[i]].buy_consume_gold
			if item_num > 1 then
				item_name = item_name
				self.node_list["TxtName" .. (i + 1)].text.text = ToColorStr(item_name, ITEM_COLOR[item_cfg.color or 0]) 
			else
				self.node_list["TxtName" .. (i + 1)].text.text = ToColorStr(item_name, ITEM_COLOR[item_cfg.color or 0])
			end
			

		else
			self.card_status[i + 1] = NEQ_CARD_STATUS.DEFAULT
			self.node_list["ImgCard" .. (i + 1)]:SetActive(true)
		end
	end

	if next(zhenbaoge_item_list) and self.refresh_tags then
		self:DoCardFlipAction()
	end

	local is_allbuy = TreasureBusinessmanData.Instance:GetIsAllBuy()
	UI:SetButtonEnabled(self.node_list["BtnBuy"], is_allbuy)
	self.node_list["TxtAllBuy"].text.text = self.all_buy_gold
end


function TreasureBusinessmanView:FlushServerFetchReward()
	-- local data = TreasureBusinessmanData.Instance:GetRewardListData()
	local data = TreasureBusinessmanData.Instance:GetReturnReward()
	for i = 1, 6 do
		self.total_reward_item_list[i]:SetData(data[i])
	end
	local flush_times = TreasureBusinessmanData.Instance:GetServerFlushTimes() or 0
	for i = 1, 6 do
		self.node_list["TxttotalTime" .. i].text.text = flush_times
	end
end
----------------------------------TotalrewardItem-------------------------------------
TotalrewardItem = TotalrewardItem or BaseClass(BaseRender)

function TotalrewardItem:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["Item"])
	self.node_list["PanelAwardItem"].button:AddClickListener(BindTool.Bind(self.OnClick, self))

end

function TotalrewardItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
	end
end

function TotalrewardItem:SetCurIndex(index)
	self.cur_index = index
end

function TotalrewardItem:SetData(data)
	if data == nil then
		return
	end
	self.data = data
	self.node_list["Effectitem"]:SetActive(false)
	self.node_list["TxtTimes"].text.text = "/" .. data.cfg.can_fetch_times
	-- local fetch_flag = TreasureBusinessmanData.Instance:GetZhenBaoGeFetchFlagByIndex(self.cur_index)
	local fetch_flag = data.fetch_flag
	local cur_num = TreasureBusinessmanData.Instance:GetServerFlushTimes() or 0
	if data.cfg == nil then
		return
	end
	local can_get = cur_num >= data.cfg.can_fetch_times
	local click_func = nil
	if cur_num >= data.cfg.can_fetch_times then
		if 1 == fetch_flag then
			self.node_list["Imghighlight"]:SetActive(false)
			self.node_list["TxtCangain"]:SetActive(false)
			self.node_list["Panelhave_got_bg"]:SetActive(true)
			self.node_list["Panelcontainer"]:SetActive(false)
		else
			self.node_list["Imghighlight"]:SetActive(true)
			self.node_list["TxtCangain"]:SetActive(true)
			self.node_list["Panelhave_got_bg"]:SetActive(false)
			self.node_list["Panelcontainer"]:SetActive(true)
		end
	else
		self.node_list["Imghighlight"]:SetActive(false)
		self.node_list["TxtCangain"]:SetActive(false)
		self.node_list["Panelhave_got_bg"]:SetActive(false)
		self.node_list["Panelcontainer"]:SetActive(true)
	end
	self:ShowData(can_get and fetch_flag ~= 1)
	self.item_cell:SetData(data.cfg.reward_item)
end

function TotalrewardItem:OnClick()
	self.item_cell:SetHighLight(false)

	-- local fetch_flag = TreasureBusinessmanData.Instance:GetZhenBaoGeFetchFlagByIndex(self.cur_index)
	local fetch_flag = self.data.fetch_flag
	local cur_num = TreasureBusinessmanData.Instance:GetServerFlushTimes() or 0
	if cur_num >= self.data.cfg.can_fetch_times and 1 ~= fetch_flag then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_BUSINESSMAN, RA_ZHENBAOGE_OPERA_TYPE.RA_ZHENBAOGE_OPERA_TYPE_FETCH_SERVER_GIFT, self.data.cfg.seq)
		AudioService.Instance:PlayRewardAudio()
	end
end

function TotalrewardItem:ShowData(is_show)
	if self.item_cell and is_show then
		self.item_cell:IsDestroyEffect(true)
		self.node_list["Effectitem"]:SetActive(true)
		self.node_list["Imghighlight"]:SetActive(true)
		self.node_list["TxtCangain"]:SetActive(true)
		self.node_list["Panelcontainer"]:SetActive(false)
	end
end