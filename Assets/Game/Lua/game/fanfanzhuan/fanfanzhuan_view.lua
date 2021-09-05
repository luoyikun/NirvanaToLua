FanFanZhuanView = FanFanZhuanView or BaseClass(BaseView)

-- 累计充值次数最大档次
local MAX_PROG_GRADE = 3

function FanFanZhuanView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour"},
		{"uis/views/fanfanzhuan_prefab", "FanFanZhuanView"},
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
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	
	self.auto_buy_flag_list = {
		["auto_type_1"] = false,
		["auto_type_10"] = false,
		["auto_type_50"] = false,
	}
end

function FanFanZhuanView:LoadCallBack()
	self.node_list["Name"].text.text = Language.Title.FanLong
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.OnclickReset, self))
	self.node_list["BtnRefreshTen"].button:AddClickListener(BindTool.Bind2(self.RefreshAllItems, self, 10))
	self.node_list["BtnRefreshMany"].button:AddClickListener(BindTool.Bind2(self.RefreshAllItems, self, 50))
	self.node_list["BtnWenHao"].button:AddClickListener(BindTool.Bind(self.OpenTreasureLoftTips, self))
	self.node_list["BtnCangKu"].button:AddClickListener(BindTool.Bind(self.OnClickWarehouse, self))

	--self.node_list["ImgTitle"].image:LoadSprite("uis/views/fanfanzhuan/images_atlas","text_title_fanlong")

	self.node_list["ButtonLeft"].button:AddClickListener(BindTool.Bind(self.ClickLeft, self))
	self.node_list["ButtonRight"].button:AddClickListener(BindTool.Bind(self.ClickRight, self))
	self.node_list["BtnLucky"].button:AddClickListener(BindTool.Bind(self.OnClickLog, self))
	
	self.item_list = {}
	for i = 1, 6 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["Item" .. i])
	end

	self.level_item_list = {}
	self.is_show_select_list = {}
	for i = 0, 2 do
		self.node_list["level_item" .. i].button:AddClickListener(BindTool.Bind2(self.OnClickLevel, self, i))
	end
	
	for i = 0, 8 do
		self.display_item_list[i] = ItemCell.New()
		self.display_item_list[i]:SetInstanceParent(self.node_list["ItemDisplay" .. i])
		self.node_list["card_item" .. i].button:AddClickListener(BindTool.Bind2(self.SendRollCard,self,i))
		self.node_list["ItemDisplay" .. i].button:AddClickListener(BindTool.Bind2(self.SendRollCard,self,i))
		
	end

	self.cell_list = {}
	self.node_list["Scroller"].list_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.node_list["Scroller"].list_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
	self.node_list["Scroller"].scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.FlushPage, self))

	-- 三个等级 0， 1， 2
	self.cur_level = 0
	self.is_rotation = false
	self.req_type = RA_KING_DRAW_OPERA_TYPE.RA_KING_DRAW_OPERA_TYPE_REFRESH_CARD
end

function FanFanZhuanView:ReleaseCallBack()
	for i = 0, 8 do
		self["item_name" .. i] = nil
		if nil ~= self.item_list[i] then
			self.item_list[i]:DeleteMe()
		end
		if self.display_item_list[i] then
			self.display_item_list[i]:DeleteMe()
		end
	end

	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}

	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	self.refresh_gold = nil
	self.remain_time = nil
	self.list_view = nil
	self.buy_all_desc = nil
	self.item_list = {}
	self.display_item_list = {}
	self.item_buffer = {}
	self.card_status = {}
	self.level_item_list = {}
	self.is_show_select_list = {}
	self.text_once = nil
	self.text_two = nil
	self.text_three = nil
	self.text_ten = nil
	self.text_many = nil
	self.key_redpoint = nil
	self.tab_redpoint = nil

	self.scroller = nil
	self.list_view_delegate = nil
	self.text_times = nil
	self.text_left_time = nil
	self.show_key_str = nil
	self.key_str = nil

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

	FanFanZhuanData.Instance:ClearReturnRewardList()
end

function FanFanZhuanView:Open()
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_FANFANZHUAN) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
		return
	end

	BaseView.Open(self)
end

function FanFanZhuanView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_FANFANZHUAN, RA_KING_DRAW_OPERA_TYPE.RA_KING_DRAW_OPERA_TYPE_QUERY_INFO)
	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
	self.is_auto_buy = false
	self:Flush()
	self:FlsuhCardShow()
end

function FanFanZhuanView:OnClickLog()
	ActivityCtrl.Instance:SendActivityLogSeq(ACTIVITY_TYPE.RAND_ACTIVITY_FANFANZHUAN)
end

function FanFanZhuanView:ClickLeft()
	local page = self.node_list["Scroller"].list_page_scroll:GetNowPage()
	page = page - 1
	if page < 0 then return end
	self:JumpPage(page)
	self.node_list["Scroller"].list_page_scroll:JumpToPage(page)
	-- local jump_index = 0
	-- local scrollerOffset = 0
	-- local cellOffset = 0
	-- local useSpacing = false
	-- local scrollerTweenType = self.node_list["Scroller"].scroller.snapTweenType
	-- local scrollerTweenTime = 0.2
	-- local scroll_complete = nil
	-- self.node_list["Scroller"].scroller:JumpToDataIndexForce(
	-- jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
end

function FanFanZhuanView:ClickRight()
	local page = self.node_list["Scroller"].list_page_scroll:GetNowPage()
	page = page + 1
	self:JumpPage(page)
	self.node_list["Scroller"].list_page_scroll:JumpToPage(page)

	-- local jump_index = 1
	-- local scrollerOffset = 0
	-- local cellOffset = 0
	-- local useSpacing = false
	-- local scrollerTweenType = self.node_list["Scroller"].scroller.snapTweenType
	-- local scrollerTweenTime = 0.2
	-- local scroll_complete = nil
	-- self.node_list["Scroller"].scroller:JumpToDataIndexForce(
	-- jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
end

function FanFanZhuanView:FlushPage()
	local page = self.node_list["Scroller"].list_page_scroll:GetNowPage()
	self:JumpPage(page)
end

function FanFanZhuanView:JumpPage(page)
	if page == 0 then
		self.node_list["ButtonLeft"]:SetActive(false)
		self.node_list["ButtonRight"]:SetActive(true)
	elseif page == 1 then
		self.node_list["ButtonLeft"]:SetActive(true)
		self.node_list["ButtonRight"]:SetActive(false)
	else
		self.node_list["ButtonLeft"]:SetActive(true)
		self.node_list["ButtonRight"]:SetActive(true)
	end
end


function FanFanZhuanView:ActivityCallBack(activity_type, status)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_FANFANZHUAN and status == ACTIVITY_STATUS.CLOSE then
		self:Close()
	end 
end

function FanFanZhuanView:SendRollCard(index)
	local reward_index = FanFanZhuanData.Instance:GetinfoByLevelAndIndex(self.cur_level, index)
	if reward_index >= 0 then
		return
	end

		-- 翻牌费用显示
	local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local gold = 0
	if self.cur_level == 0 then
		gold = randact_cfg.other[1].king_draw_chuji_once_gold
	elseif self.cur_level == 1 then
		gold = randact_cfg.other[1].king_draw_zhongji_once_gold
	elseif self.cur_level == 2 then
		gold = randact_cfg.other[1].king_draw_gaoji_once_gold
	end

	if PlayerData.Instance:GetRoleVo().gold < gold then
		TipsCtrl.Instance:ShowLackDiamondView()
		return
	end

	local func = function(is_auto)
		self.auto_buy_flag_list["auto_type_1"] = is_auto
		self.is_rotation = true
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_FANFANZHUAN, 
													RA_KING_DRAW_OPERA_TYPE.RA_KING_DRAW_OPERA_TYPE_PLAY_ONCE, self.cur_level, index)

		self.node_list["card_item" .. index].rect:SetLocalScale(1, 1, 1)
		local target_scale = Vector3(0, 1, 1)
		local target_scale2 = Vector3(1, 1, 1)
		self.tweener1 = self.node_list["card_item" .. index].rect:DOScale(target_scale, 0.5)

		local func2 = function()
			self.node_list["Imgcover" .. index]:SetActive(false)
			self.tweener2 = self.node_list["card_item" .. index].rect:DOScale(target_scale2, 0.5)
			self.is_rotation = false
		end
		self.tweener1:OnComplete(func2)
		self.delay_timer2 = GlobalTimerQuest:AddDelayTimer(func2, 0.5)
	end

	if self.auto_buy_flag_list["auto_type_1"] then
		func(true)
	else
		local str = string.format(Language.Fanfanzhuan.CostTip, gold, CommonDataManager.GetDaXie(1))
		TipsCtrl.Instance:ShowCommonAutoView("fanfanzhuan_auto1", str, func)
	end
end

--滚动条数量
function FanFanZhuanView:GetNumberOfCells()
	local show_reward_list = FanFanZhuanData.Instance:GetShowRewardCfgByOpenDay()
	return math.ceil(#show_reward_list/3)
end

--滚动条刷新
function FanFanZhuanView:RefreshView(cell, data_index)
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = FanFanZhuanGridItem.New(cell.gameObject)
		self.cell_list[cell] = group_cell
	end
	group_cell:SetPageIndex(data_index)
	group_cell:Flush()
end

function FanFanZhuanView:ResetItemGrid(i)

end

function FanFanZhuanView:RefreshCastRedPoint()
	for i = 0, 2 do
		local is_red = FanFanZhuanData.Instance:GetCastRemind(i)
		local red_index = i + 1
		if is_red then
			self.node_list["TabRedPoint" .. red_index]:SetActive(is_red)
			--if i == 3 then
		else 
			if red_index ~= 3 then
			self.node_list["TabRedPoint" .. red_index]:SetActive(is_red)
			end
		end
	end
end

function FanFanZhuanView:CloseCallBack()
	self.is_auto_buy = false
	self.is_rotation = false

	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end
end

function FanFanZhuanView:OpenTreasureLoftTips()
	TipsCtrl.Instance:ShowHelpTipView(207)
end

function FanFanZhuanView:OnClickWarehouse()
	ViewManager.Instance:Open(ViewName.TipsTreasureWarehouseView)
end

function FanFanZhuanView:OnclickReset()
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_FANFANZHUAN, 
											RA_KING_DRAW_OPERA_TYPE.RA_KING_DRAW_OPERA_TYPE_REFRESH_CARD, self.cur_level)

		self.req_type = RA_KING_DRAW_OPERA_TYPE.RA_KING_DRAW_OPERA_TYPE_REFRESH_CARD
end

function FanFanZhuanView:RefreshAllItems(req_type)
	local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local gold = 0
	if self.cur_level == 0 then
		gold = randact_cfg.other[1].king_draw_chuji_once_gold
	elseif self.cur_level == 1 then
		gold = randact_cfg.other[1].king_draw_zhongji_once_gold
	elseif self.cur_level == 2 then
		gold = randact_cfg.other[1].king_draw_gaoji_once_gold
	end

	local func = function(is_auto)
		self.auto_buy_flag_list["auto_type_" .. req_type] = is_auto
		self:OnOperate(req_type)
	end

	local item_num = ItemData.Instance:GetItemNumInBagById(randact_cfg.other[1].king_draw_gaoji_consume_item)
	local is_auto_use_item = self.cur_level == 2 and req_type == 50 and item_num > 0

	if not is_auto_use_item and PlayerData.Instance:GetRoleVo().gold < gold * req_type then
		TreasureData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_RANK_FANFANZHUANG_50)
		TipsCtrl.Instance:ShowLackDiamondView()
		return
	end

	if self.auto_buy_flag_list["auto_type_" .. req_type] or is_auto_use_item then
		self:OnOperate(req_type)
	else
		local str = string.format(Language.Fanfanzhuan.CostTip, gold * req_type, CommonDataManager.GetDaXie(req_type))
		TipsCtrl.Instance:ShowCommonAutoView("fanfanzhuan_auto" .. req_type, str, func)
	end
end

function FanFanZhuanView:OnOperate(req_type)
	if req_type == 10 then
		TreasureData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_RANK_FANFANZHUANG_10)
	else
		
		TreasureData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_RANK_FANFANZHUANG_50)
	end
	
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_FANFANZHUAN, 
									RA_KING_DRAW_OPERA_TYPE.RA_KING_DRAW_OPERA_TYPE_PLAY_TIMES, self.cur_level, req_type)
end

function FanFanZhuanView:OnFlush()
	for i = 0, GameEnum.RA_KING_DRAW_MAX_SHOWED_COUNT - 1 do
		local seq = FanFanZhuanData.Instance:GetinfoByLevelAndIndex(self.cur_level, i)
		if seq >= 0 then
			local reward_cfg = FanFanZhuanData.Instance:GetRewardByLevelAndIndex(self.cur_level, seq)
			if nil ~= next(reward_cfg) then
				self.display_item_list[i]:SetData(reward_cfg.reward_item)
				local item_cfg = ItemData.Instance:GetItemConfig(reward_cfg.reward_item.item_id)
				--local str_name_item = ItemData.Instance:GetItemName(reward_cfg.reward_item.item_id)
				self.node_list["TxtItemName" .. i].text.text = ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color])
			end
		end 
	end

	local show_reward_list = FanFanZhuanData.Instance:GetRareRewardCfgByOpenDay(self.cur_level)
	for i = 1, 6 do
		if nil ~= show_reward_list[i] then
			self.item_list[i]:SetData(show_reward_list[i])
			self.node_list["Item" .. i]:SetActive(true)
		else
			self.node_list["Item" .. i]:SetActive(false)
		end
	end

	for i = 0, 2 do
		if i == self.cur_level then
			self.node_list["ImgSelect" .. i]:SetActive(true)
			-- self.node_list["ImgGold1"].text.text = gold
		else
			self.node_list["ImgSelect" .. i]:SetActive(false)
		end
	end

	local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	-- 翻牌费用显示
	local gold = 0
	if self.cur_level == 0 then
		gold = randact_cfg.other[1].king_draw_chuji_once_gold
	elseif self.cur_level == 1 then
		gold = randact_cfg.other[1].king_draw_zhongji_once_gold
	elseif self.cur_level == 2 then
		gold = randact_cfg.other[1].king_draw_gaoji_once_gold
	end

	-- self.node_list["ImgGold1"].text.text = randact_cfg.other[1].king_draw_chuji_once_gold
	-- self.node_list["ImgLayoutGold1"].text.text = randact_cfg.other[1].king_draw_zhongji_once_gold
	-- self.node_list["ImgLayoutGold2"].text.text = randact_cfg.other[1].king_draw_gaoji_once_gold
	self.node_list["ImgGold2"].text.text = gold * 10
	self.node_list["ImgGold3"].text.text = gold * 50

	--钥匙显示
	local item_num = ItemData.Instance:GetItemNumInBagById(randact_cfg.other[1].king_draw_gaoji_consume_item)
	self.node_list["ImgLayoutGold"]:SetActive(not (self.cur_level == 2 and item_num > 0))
	self.node_list["TxtKeyLable"]:SetActive(self.cur_level == 2 and item_num > 0)
	self.node_list["TabRedPoint3"]:SetActive(self.cur_level == 2 and item_num > 0)

	local item_cfg = ItemData.Instance:GetItemConfig(randact_cfg.other[1].king_draw_gaoji_consume_item)
	local key_str = ToColorStr("X" .. item_num, TEXT_COLOR.GREEN)--"<color="..SOUL_NAME_COLOR[item_cfg.color] .. ">" .. item_cfg.name .. "</color>X" .. item_num
	self.node_list["TxtKey"].text.text = self.cur_level == 2 and key_str or ""
	self.node_list["KeyRedPoint"]:SetActive(self.cur_level == 2 and item_num > 0)
	self.node_list["TabRedPoint3"]:SetActive(item_num > 0)

	if self.req_type == RA_KING_DRAW_OPERA_TYPE.RA_KING_DRAW_OPERA_TYPE_REFRESH_CARD then
		self:FlsuhCardShow()
		self.req_type = RA_KING_DRAW_OPERA_TYPE.RA_KING_DRAW_OPERA_TYPE_QUERY_INFO
	end
	local times = FanFanZhuanData.Instance:GetDrawTimesByLevel(self.cur_level)
	self.node_list["TxtTimes"].text.text = string.format(Language.ZhuanZhuanLe.Leiji, times)

	-- 活动剩余时间
	local nexttime = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_FANFANZHUAN)
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if nexttime ~= nil then
		local time_t = TimeUtil.Format2TableDHMS(nexttime)
		if time_t.day > 0 then
			local str = string.format(Language.IncreaseCapablity.ResTime, time_t.day, time_t.hour)--, time_tab.min, time_tab.s)
			self.node_list["TxtTime"].text.text = string.format(Language.RechargeCapacity.ActTime, str)
		else
			 self:UpdataRollerTime(0, nexttime)
			 self.count_down = CountDown.Instance:AddCountDown(nexttime,1,BindTool.Bind1(self.UpdataRollerTime, self))	
		end
	end

	FanFanZhuanData.Instance:SetCurLevel(self.cur_level)
	--self.node_list["Scroller"].scroller:RefreshAndReloadActiveCellViews(true)
	for k,v in pairs(self.cell_list) do
		v:SetCurLevel(self.cur_level)
		v:Flush()
	end
	self:RefreshCastRedPoint()
end

function FanFanZhuanView:UpdataRollerTime(elapse_time, next_time)
	local time = next_time - elapse_time
	
		if time > 0 then
			local str = TimeUtil.FormatSecond2HMS(time)
			self.node_list["TxtTime"].text.text = string.format(Language.RechargeCapacity.ActTime, str)
		else
			self.node_list["TxtTime"].text.text = "00:00:00"
		end
end

function FanFanZhuanView:FlsuhCardShow()
	for i = 0, GameEnum.RA_KING_DRAW_MAX_SHOWED_COUNT - 1 do
		local reward_index = FanFanZhuanData.Instance:GetinfoByLevelAndIndex(self.cur_level, i)
		if reward_index >= 0 then
			self.node_list["Imgcover" .. i]:SetActive(false)
		else
			self.node_list["Imgcover" .. i]:SetActive(true)
		end 
	end
end

function FanFanZhuanView:OnClickLevel(level)
	if self.cur_level == level then
		return
	end
	if self.is_rotation then
		SysMsgCtrl.Instance:ErrorRemind(Language.Fanfanzhuan.IsRotation)
		return
	end
	local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local gold = 0
	if level == 0 then
		gold = randact_cfg.other[1].king_draw_chuji_once_gold
	elseif level == 1 then
		gold = randact_cfg.other[1].king_draw_zhongji_once_gold
	elseif level == 2 then
		gold = randact_cfg.other[1].king_draw_gaoji_once_gold
	end
	self.node_list["ImgGold1"].text.text = gold

	if self.cur_level ~= level then
		self.node_list["Scroller"].list_page_scroll:JumpToPage(0)
	end

	self.cur_level = level
	self:Flush()
	self:FlsuhCardShow()
end

------------------------------------------------------------------------
FanFanZhuanGridItem = FanFanZhuanGridItem  or BaseClass(BaseRender)

function FanFanZhuanGridItem:__init()
	self.page_index = 0
	self.cur_level = 0
	-- 累计翻牌达到的档次
	self.cur_grade = 0
	-- self.is_red_point = false

	self.item_list = {}
	for i = 0, 2 do
		local index = i + 1
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["Item" .. index])
		self.item_list[i]:ListenClick(BindTool.Bind(self.ItemClick, self, i))
		self.node_list["ItemGrout" .. index].toggle:AddClickListener(BindTool.Bind(self.ItemHightClick, self, index))
	end

	self.text_desc_list = {}

	self.show_rewardtext_list = {}

	self.show_hasReward_list = {}

	self.show_effect_flag_list = {}

end

function FanFanZhuanGridItem:__delete()
	self.page_index = 0

	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end

	self.item_list = {}
	self.text_desc_list = {}
	self.show_hasReward_list = {}
	self.show_rewardtext_list = {}
end

function FanFanZhuanGridItem:ItemClick(i)
	if self.cur_grade >= i +1 then
		local return_reward_list = FanFanZhuanData.Instance:GetReturnRewardByLevelSort(self.cur_level)
		-- local index = i + 1
		-- local return_reward_list = FanFanZhuanData.Instance:GetReturnRewardByLevel(self.cur_level)
		-- local data = return_reward_list[index] or {}
		-- local reward_seq =  (self.page_index * MAX_PROG_GRADE) + data.seq
		local reward_seq = return_reward_list[i + 1].index_cfg
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_FANFANZHUAN, 
													RA_KING_DRAW_OPERA_TYPE.RA_KING_DRAW_OPERA_TYPE_FETCH_REWARD, self.cur_level, reward_seq - 1)
	else
		self.item_list[i]:OnClickItemCell()
	end
end

function FanFanZhuanGridItem:ItemHightClick(i)
	if self.cur_grade >= i then
		local return_reward_list = FanFanZhuanData.Instance:GetReturnRewardByLevelSort(self.cur_level)
		-- local index = i
		-- local return_reward_list = FanFanZhuanData.Instance:GetReturnRewardByLevel(self.cur_level)
		-- local data = return_reward_list[i] or {}
		-- local reward_seq =  (self.page_index * MAX_PROG_GRADE) + data.seq
		local reward_seq = return_reward_list[i + 1].index_cfg
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_FANFANZHUAN, 
													RA_KING_DRAW_OPERA_TYPE.RA_KING_DRAW_OPERA_TYPE_FETCH_REWARD, self.cur_level, reward_seq - 1)
	end
end

function FanFanZhuanGridItem:SetPageIndex(page_index)
	self.page_index = page_index
end

function FanFanZhuanGridItem:SetCurLevel(level)
	self.cur_level = level
end

-- function FanFanZhuanGridItem:GetRedPoint()
-- 	return self.is_red_point
-- end

function FanFanZhuanGridItem:OnFlush()
	self.is_show_has_get = false
	local return_reward_list = FanFanZhuanData.Instance:GetReturnRewardByLevelSort(self.cur_level)
	local draw_times = FanFanZhuanData.Instance:GetDrawTimesByLevel(self.cur_level)
	self.cur_grade = 0
	for i = 0, 2 do
		local index = i + 1
		local index_cfg = (self.page_index * MAX_PROG_GRADE) + (i + 1)
		local data = return_reward_list[index + 3 * self.page_index] or {}
		local cell = self.item_list[i]
		cell:SetData(data.reward_item or {})
		local times_text = FanFanZhuanData.Instance:GetDrawTimesByLevel(self.cur_level)
		times_text = string.format(Language.ZhuanZhuanLe.MiaoShu2, data.draw_times)
		self.node_list["TxtNomal_" .. index].text.text = times_text

		-- 获取当前达到第几个档次
		local is_show_effect = false
		local is_show_has_get = false
		if draw_times >= data.draw_times then
			local reward_flag = FanFanZhuanData.Instance:GetIsGetReward(self.cur_level, data.index_cfg)
			self.node_list["ImgHight_" .. index]:SetActive(true)
			self.node_list["BgEffect_" .. index]:SetActive(true)
			self.node_list["TxtNomal_" .. index]:SetActive(true)
			self.node_list["TxtNomal_" .. index].text.text = ToColorStr(Language.ZhuanZhuanLe.KeLingQu,TEXT_COLOR.GREEN_4)
			-- self.is_red_point = true
			if reward_flag == 1 then
				is_show_has_get = true
			else
				is_show_effect = true
			end
			self.cur_grade = self.cur_grade + 1
		else
			self.node_list["ImgHight_" .. index]:SetActive(false)
			self.node_list["BgEffect_" .. index]:SetActive(false)
			self.node_list["TxtNomal_" .. index]:SetActive(true)
			self.node_list["TxtNomal_" .. index].text.text = times_text
			
		end
		if is_show_has_get then
			-- UI:SetGraphicGrey(self.node_list["Item" .. index], true)
			self.node_list["ImgBgGray_" .. index]:SetActive(true)
			self.node_list["TxtNomalText_" .. index]:SetActive(true)
			self.node_list["ImgHight_" .. index]:SetActive(false)
			self.node_list["BgEffect_" .. index]:SetActive(false)
			-- self.node_list["TxtNomal_" .. index]:SetActive(false)
			self.node_list["TxtNomal_" .. index].text.text = times_text
		else
			-- UI:SetGraphicGrey(self.node_list["Item" .. index], false)
			self.node_list["ImgBgGray_" .. index]:SetActive(false)
			self.node_list["TxtNomalText_" .. index]:SetActive(true)
		end
		cell:SetHighLight(false)
	end

end