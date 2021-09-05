TreasureLoftView = TreasureLoftView or BaseClass(BaseView)

function TreasureLoftView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour"},
		{"uis/views/treasureloft_prefab", "TreasureLoftView"},
	}

	self.item_list = {}
	self.display_item_list = {}
	self.item_buffer = {}
	self.card_status = {}
	self.rare_list = {}
	self.contain_cell_list = {}

	self.all_buy_gold = 0
	self.zhenbaoge_reflush_gold = 0
	self.zhenbaoge_auto_flush_times = 0
	self.refresh_tags = false

	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TreasureLoftView:LoadCallBack()
	-- local bundle, asset = "uis/views/treasureloft/images_atlas", "icon_title"
	-- self.node_list["ImgTitle"].image:LoadSprite(bundle, asset)
	
	self.node_list["Name"].text.text = Language.Title.LunHui
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.SendBuyAllItemsReq, self))
	self.node_list["BtnRefreshTen"].button:AddClickListener(BindTool.Bind(self.RefreshAllItems, self, 1))
	self.node_list["BtnRefreshOne"].button:AddClickListener(BindTool.Bind(self.RefreshAllItems, self, 0))
	self.node_list["Btn"].button:AddClickListener(BindTool.Bind(self.OpenTreasureLoftTips, self))
	self.node_list["BtnLucky"].button:AddClickListener(BindTool.Bind(self.OnClickLog, self))

	self.item_obj_list = {}
	for i = 1, 9 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["Item" .. i])

		self.display_item_list[i] = ItemCell.New()
		self.display_item_list[i]:SetInstanceParent(self.node_list["ItemDisplay" .. i])
		self.display_item_list[i]:ListenClick(BindTool.Bind2(self.SendRollCard, self, i))

		self.item_obj_list[i] = {}
		self.item_obj_list[i].card_item = self.node_list["card_item" .. i]
		self.item_obj_list[i].price = self.node_list["TxtPrice" .. i]
		self.item_obj_list[i].is_show = self.node_list["ImgCover" .. i]
		self.item_obj_list[i].item_name = self.node_list["TxtItemName" .. i]

		self.node_list["card_item" .. i].button:AddClickListener(BindTool.Bind(self.SendRollCard, self, i))
	end

	local list_delegate = self.node_list["list_view"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	if not self.item_change_callback then
		self.item_change_callback = BindTool.Bind(self.FlushKeyGold, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_change_callback)
	end

	self:InitRareItemsDisplay()
	self:InitRollView()
end

function TreasureLoftView:__delete()
	self:CancelCountDown()
end

function TreasureLoftView:Open()
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
		return
	end
	BaseView.Open(self)
end

function TreasureLoftView:ReleaseCallBack()
	for i = 1, 9 do
		self.item_list[i]:DeleteMe()
		self.display_item_list[i]:DeleteMe()
	end
	self.item_obj_list = {}

	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}

	self.item_list = {}
	self.display_item_list = {}
	self.item_buffer = {}
	self.card_status = {}

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

	if self.item_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_callback)
		self.item_change_callback = nil
	end
	self:CancelCountDown()

	if self.delay_timer2 then
		GlobalTimerQuest:CancelQuest(self.delay_timer2)
	end
end

function TreasureLoftView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT, RA_ZHENBAOGE_OPERA_TYPE.RA_ZHENBAOGE_OPERA_TYPE_QUERY_INFO)
	self:Flush()
end

function TreasureLoftView:CloseCallBack()

end

function TreasureLoftView:OpenTreasureLoftTips()
	TipsCtrl.Instance:ShowHelpTipView(191)
end

function TreasureLoftView:GetNumberOfCells()
	-- local data = TreasureLoftData.Instance:GetRewardListData()
	local data = TreasureLoftData.Instance:GetReturnReward()
	if #data % 2 ~= 0 then
		return math.ceil(#data / 2)
	else
		return #data / 2
	end
end

function TreasureLoftView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = TreasureLoftItems.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
		contain_cell:SetToggleGroup(self.node_list["list_view"].toggle_group)
	end

	-- local data = TreasureLoftData.Instance:GetRewardListData()
	local data = TreasureLoftData.Instance:GetReturnReward()
	cell_index = cell_index + 1
	contain_cell:InitItems(data)
	contain_cell:SetRowNum(cell_index)
	contain_cell:Flush()
end

function TreasureLoftView:InitRareItemsDisplay()
	local rare_item_table = TreasureLoftData.Instance:GetDisplayItemTable()
	if rare_item_table ~= nil then
		for i = 1, 9 do
			if rare_item_table[i - 1] then
				self.item_list[i]:SetData(rare_item_table[i - 1])
				self.item_obj_list[i].is_show:SetActive(true)
			end
		end
	end
end

function TreasureLoftView:OnClickLog()
	ActivityCtrl.Instance:SendActivityLogSeq(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT)
end

function TreasureLoftView:InitRollView()
	local zhenbaoge_cfg = KaifuActivityData.Instance:GetZhenBaoGeCfg()
	if zhenbaoge_cfg == nil then return end
	local other_cfg = PlayerData.Instance:GetCurrentRandActivityConfig()

	local str = ""
	if other_cfg ~= nil and other_cfg.other[1] ~= nil and other_cfg.other[1].zhenbaoge_all_buy_reward ~= nil then
		str = ItemData.Instance:GetItemName(other_cfg.other[1].zhenbaoge_all_buy_reward.item_id)
	end
	self.node_list["TxtShenyutime2"].text.text = string.format(Language.TreasureLoft.BuyAllDesc, str)

	self.zhenbaoge_reflush_gold = other_cfg.other[1].zhenbaoge_reflush_gold
	self.zhenbaoge_auto_flush_times = other_cfg.other[1].zhenbaoge_auto_flush_times
	self.node_list["TxtGold"].text.text = self.zhenbaoge_reflush_gold
	self.node_list["TxtTenGold"].text.text = self.zhenbaoge_reflush_gold * 10
end

function TreasureLoftView:RefreshAllItems(num)
	local flag = TreasureLoftData.Instance:HasRareItemNotBuy()
	local gold = (num == 0) and (self.zhenbaoge_reflush_gold) or (self.zhenbaoge_reflush_gold*self.zhenbaoge_auto_flush_times)
	local key_num = TreasureLoftData.Instance:GetKeyNum()
	if PlayerData.Instance:GetRoleVo().gold < gold and key_num <= 0 then
		TipsCtrl.Instance:ShowLackDiamondView()
		return
	end
	if flag then
		local tips = Language.TreasureLoft.RareItemNotBuyTip2
		local yes_func = function()
			if 0 == num then
				self:SendReq(0) 
			elseif 1 == num then
				self:SendReq(1)
			end
		end
		TipsCtrl.Instance:ShowCommonAutoView("", tips, yes_func, nil, nil, nil, nil, nil, nil, true)
	else
		if 0 == num then
			if key_num > 0 then
				self:SendReq(num)
			else
				local tips = string.format(Language.TreasureLoft.ResetTips, self.zhenbaoge_reflush_gold)
				local yes_func = function() self:SendReq(0) end
				TipsCtrl.Instance:ShowCommonAutoView("refresh_one", tips, yes_func, nil, nil, nil, nil, nil, true, true)
			end
		elseif 1 == num then
			local tips = string.format(Language.TreasureLoft.OneKeyResetRare, self.zhenbaoge_reflush_gold*self.zhenbaoge_auto_flush_times, self.zhenbaoge_auto_flush_times)
			local yes_func = function() self:SendReq(1) end
			TipsCtrl.Instance:ShowCommonAutoView("refresh_ten", tips, yes_func, nil, nil, nil, nil, nil, true, true)
		end
	end
end

function TreasureLoftView:SendReq(num)
	if num == 0 then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT, RA_ZHENBAOGE_OPERA_TYPE.RA_ZHENBAOGE_OPEAR_TYPE_FLUSH)
		self.refresh_tags = true
	elseif num == 1 then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT, RA_ZHENBAOGE_OPERA_TYPE.RA_ZHENBAOGE_OPEAR_TYPE_RARE_FLUSH)
		self.refresh_tags = true
	elseif num == 2 then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT, RA_ZHENBAOGE_OPERA_TYPE.RA_ZHENBAOGE_OPEAR_TYPE_BUY_ALL)
	end
end

function TreasureLoftView:SendRollCard(index)
	if NEQ_CARD_STATUS.DEFAULT == self.card_status[index] then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT, RA_ZHENBAOGE_OPERA_TYPE.RA_ZHENBAOGE_OPERA_TYPE_BUY, index -1)
		return
	end
	self.display_item_list[index]:SetHighLight(false)
	if not next(self.item_buffer) then return end
	local item_name = ItemData.Instance:GetItemName(self.item_buffer[index].item.item_id)

	local tips = string.format(Language.TreasureLoft.DrawTips, self.item_buffer[index].price , item_name, self.item_buffer[index].item.num)
	local yes_func = function()
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT, RA_ZHENBAOGE_OPERA_TYPE.RA_ZHENBAOGE_OPERA_TYPE_BUY, index -1)
	end

	TipsCtrl.Instance:ShowCommonAutoView("buy_one", tips, yes_func, nil, nil, nil, nil, nil, nil, true, false)
end

function TreasureLoftView:SendBuyAllItemsReq()
	local str = ""
	local randact_cfg = PlayerData.Instance:GetCurrentRandActivityConfig()
	if randact_cfg ~= nil and randact_cfg.other[1] ~= nil and randact_cfg.other[1].zhenbaoge_all_buy_reward ~= nil then
		str = ItemData.Instance:GetItemName(randact_cfg.other[1].zhenbaoge_all_buy_reward.item_id)
	end

	if self.all_buy_gold > 0 then
		local tips = string.format(Language.TreasureLoft.AllBuyTips,self.all_buy_gold, str)
		local yes_func = function() self:SendReq(2) end
		TipsCtrl.Instance:ShowCommonAutoView("buy_ten", tips, yes_func, nil, nil, nil, nil, nil, nil, true, false)
	else
		self:SendReq(2)
	end
end

function TreasureLoftView:DoCardFlipAction()
	for i = 1, 9 do
		self.item_obj_list[i].is_show:SetActive(true)
		self.item_obj_list[i].card_item.rect:SetLocalScale(1, 1, 1)

		local target_scale = Vector3(0, 1, 1)
		local target_scale2 = Vector3(1, 1, 1)
		self.tweener1 = self.item_obj_list[i].card_item.rect:DOScale(target_scale, 0.5)

		local func2 = function()
			self.tweener2 = self.item_obj_list[i].card_item.rect:DOScale(target_scale2, 0.5)
		end
		self.delay_timer2 = GlobalTimerQuest:AddDelayTimer(func2, 0.5)
	end

	local func = function()
		self:ResetItemGrid()
	end
	self.delay_timer = GlobalTimerQuest:AddDelayTimer(func, 0.5)
end

function TreasureLoftView:ResetItemGrid()
	for i = 1, 9 do
		self.item_obj_list[i].is_show:SetActive(false)
	end
	self.refresh_tags = false
end

function TreasureLoftView:FlushNextFlushTimer()
	local nexttime = TreasureLoftData.Instance:GetNextFlushTimeStamp() - TimeCtrl.Instance:GetServerTime()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if nexttime ~= nil then	
		 self:UpdataRollerTime(0, nexttime)
		 self.count_down = CountDown.Instance:AddCountDown(nexttime, 1, BindTool.Bind1(self.UpdataRollerTime, self))	
	end

	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT)
	if time > 0 then
		self:CancelCountDown()
		self:ChangeActTime(0, time)
		self.node_list["ActTime"]:SetActive(true)
		self.countdown_timer = CountDown.Instance:AddCountDown(time, 1, BindTool.Bind1(self.ChangeActTime, self))
	else
		self.node_list["ActTime"]:SetActive(false)
	end
end

function TreasureLoftView:ChangeActTime(elapse_time, total_time)
	local str_tmp = total_time - elapse_time
	local time_tab = TimeUtil.Format2TableDHMS(str_tmp)

	if time_tab.day >= 1 then
		time_str = string.format(Language.Activity.ActivityTime8, time_tab.day, time_tab.hour)
	else
		time_str = string.format(Language.Activity.ActivityTime9, time_tab.hour, time_tab.min, time_tab.s)
	end
	self.node_list["TimeTxt"].text.text = time_str
	if elapse_time >= total_time then
		self.node_list["ActTime"]:SetActive(false)
		self:CancelCountDown()
	end
end

function TreasureLoftView:CancelCountDown()
	if self.countdown_timer then
		CountDown.Instance:RemoveCountDown(self.countdown_timer)
		self.countdown_timer = nil
	end
end

function TreasureLoftView:UpdataRollerTime(elapse_time, next_time)
	local time = next_time - elapse_time
	if self.node_list["TxtShenyutime"] ~= nil then
		if time > 0 then
			self.node_list["TxtShenyutime"].text.text = TimeUtil.FormatSecond2HMS(time)
		else
			self.node_list["TxtShenyutime"].text.text = "00:00:00"
		end
	end
end

function TreasureLoftView:OnFlush()
	self:FlushItemGrid()
	self:FlushKeyGold()
	self:FlushServerFetchReward()
	self:FlushNextFlushTimer()
end

function TreasureLoftView:FlushItemGrid()
	local zhenbaoge_item_list = TreasureLoftData.Instance:GetTreasureLoftGridData()
	local zhenbaoge_cfg = KaifuActivityData.Instance:GetZhenBaoGeCfg()
	if zhenbaoge_cfg == nil or zhenbaoge_item_list == nil then return end

	self.all_buy_gold = 0
	for i = 0, #zhenbaoge_item_list do
		local index = i + 1
		local key = zhenbaoge_item_list[i]
		if key ~= 0 and zhenbaoge_cfg[key] then
			self.card_status[index] = NEQ_CARD_STATUS.OPEN
			self.item_obj_list[index].is_show:SetActive(false)
			self.item_obj_list[index].price.text.text = zhenbaoge_cfg[key].buy_consume_gold

			self.display_item_list[index]:SetData(zhenbaoge_cfg[key].reward_item)
			self.rare_list[index] = zhenbaoge_cfg[key].is_rare
			if 1 == self.rare_list[index] then
				self.display_item_list[index]:ShowGetEffect(true)
			else
				self.display_item_list[index]:ShowGetEffect(false)
			end

			local data = {}
			data.item = zhenbaoge_cfg[key].reward_item
			data.price = zhenbaoge_cfg[key].buy_consume_gold
			data.is_rare = zhenbaoge_cfg[key].is_rare

			self.item_buffer[index] = data

			local item_name = ItemData.Instance:GetItemName(self.item_buffer[index].item.item_id)
			local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.item_buffer[index].item.item_id)
			self.item_obj_list[index].item_name.text.text = ToColorStr(item_name, ITEM_COLOR[item_cfg.color or 0])
			self.all_buy_gold = self.all_buy_gold + zhenbaoge_cfg[key].buy_consume_gold
		else
			self.item_obj_list[index].is_show:SetActive(true)
			self.card_status[index] = NEQ_CARD_STATUS.DEFAULT
		end
	end

	if next(zhenbaoge_item_list) and self.refresh_tags then
		self:DoCardFlipAction()
	end
end

function TreasureLoftView:FlushKeyGold()
	local key_num = TreasureLoftData.Instance:GetKeyNum()
	local is_have_key = key_num > 0
	self.node_list["TextKey"].text.text = "X" .. key_num
	self.node_list["TextKey"]:SetActive(is_have_key)
	self.node_list["TxtGold"]:SetActive(not is_have_key)
end

function TreasureLoftView:FlushServerFetchReward()
	self.node_list["list_view"].scroller:ReloadData(0)
end

------------------------------------------------------------------------
TreasureLoftItems = TreasureLoftItems  or BaseClass(BaseCell)

function TreasureLoftItems:__init()
	self.contain_list = {}
	self.row_num = 1
	for i = 1, 2 do
		self.contain_list[i] = {}
		self.contain_list[i] = TreasureVipItems.New(self.node_list["item_" .. i])
	end
end

function TreasureLoftItems:__delete()
	for i = 1, 2 do
		self.contain_list[i]:DeleteMe()
		self.contain_list[i] = nil
	end
end

function TreasureLoftItems:GetFirstCell()
	return self.contain_list[1]
end

function TreasureLoftItems:SetRowNum(num)
	self.row_num = num
end

function TreasureLoftItems:InitItems(data)
	local index = self:GetIndex()
	for i = 1, 2 do
		local true_index = 2 * (self.row_num - 1) + i
		self.contain_list[i]:SetTrueIndex(true_index)
		self.contain_list[i]:SetItemData(data)
		self.contain_list[i]:Flush()
	end
end

function TreasureLoftItems:OnFlush()

end

function TreasureLoftItems:SetToggleGroup(toggle_group)
	for i = 1, 2 do
		self.contain_list[i]:SetToggleGroup(toggle_group)
	end
end

function TreasureLoftItems:FlushAllFrame()
	for i = 1, 2 do
		self.contain_list[i]:Flush()
	end
end

----------------------------------------------------------------------------
TreasureVipItems = TreasureVipItems or BaseClass(BaseCell)

function TreasureVipItems:__init()
	self.true_index = 1
	self.reward_data = {}
	self.root_node.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleClick,self))
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["item"])
end

function TreasureVipItems:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	self.reward_data = {}
end

function TreasureVipItems:SetItemData(data)
	self.reward_data = data
end

function TreasureVipItems:SetTrueIndex(num)
	self.true_index = num
end

function TreasureVipItems:OnFlush()
	if not self.reward_data or next(self.reward_data) == nil then
		return
	end

	local item_data = self.reward_data[self.true_index].cfg
	local cur_num = TreasureLoftData.Instance:GetServerFlushTimes() or 0
	-- local fetch_flag = TreasureLoftData.Instance:GetZhenBaoGeFetchFlagByIndex(self.true_index)
	local fetch_flag = self.reward_data[self.true_index].fetch_flag
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	if next(item_data) then
		self.node_list["Txt"].text.text = string.format(Language.TreasureLoft.VIP, item_data.vip_limit)
		self.node_list["Txt2"].text.text = string.format("%s/%s", cur_num, item_data.can_fetch_times)

		self.item_cell:SetData(item_data.reward_item)

		self.node_list["Txt3"]:SetActive(false)
		self.node_list["ImgBgGray"]:SetActive(true)
		self.node_list["ImgHighLight"]:SetActive(false)
		self.node_list["EffectHighLight"]:SetActive(false)
		if cur_num >= item_data.can_fetch_times then
			if 1 == fetch_flag then

				self.node_list["Txt"].text.text = ""
				
				
			else
				self.node_list["Txt1"].text.text = ""
				self.node_list["ImgBgGray"]:SetActive(false)
				if vip_level >= item_data.vip_limit then
					self.node_list["ImgHighLight"]:SetActive(true)
					self.node_list["EffectHighLight"]:SetActive(true)
					self.node_list["Txt3"]:SetActive(true)
					self.node_list["Txt2"]:SetActive(false)
				else
					self.node_list["Txt1"].text.text = Language.Common.VipLimitTips
					self.node_list["Txt2"].text.text = Language.Activity.FlagNoCanReceive
					self.node_list["Txt2"]:SetActive(true)
				end
			end
			
		else
			self.node_list["Txt1"].text.text = Language.TreasureLoft.RefreshTarget
			self.node_list["ImgBgGray"]:SetActive(false)
			self.node_list["Txt2"]:SetActive(true)

		end
	end
	if self.click_self then
		self:OnToggleClick(true)
		self.click_self = false
	end
end

function TreasureVipItems:SelectToggle()
	--self.root_node.toggle.isOn = true
end

function TreasureVipItems:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
	self.root_node.toggle.isOn = false
end

function TreasureVipItems:OnToggleClick(is_click)
	if is_click then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT, RA_ZHENBAOGE_OPERA_TYPE.RA_ZHENBAOGE_OPERA_TYPE_FETCH_SERVER_GIFT, self.reward_data[self.true_index].cfg.seq)
	end
end