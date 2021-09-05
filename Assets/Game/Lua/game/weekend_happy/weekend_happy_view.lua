WeekendHappyView = WeekendHappyView or BaseClass(BaseView)

local MAX_RARE_SHOW_NUM = 10				
local MAX_BUTTON_NUM = 2
local MAX_RIGHT_SHOW_NUM = 3

local HAPPY_OPERATE_PARAM = {
	1, 
	2,
}
local HAPPY_CHESTSHOP_MODE = {
	[1] = CHEST_SHOP_MODE.CHEST_Weekend_HAPPY_MODE_1,
	[2] = CHEST_SHOP_MODE.CHEST_Weekend_HAPPY_MODE_10,
}

function WeekendHappyView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "Base_Activity_Panel4_1"},
		{"uis/views/weekendhappy_prefab", "Weekend_Happy"}
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.play_audio = true
	self.close_tween = UITween.HideFadeUp
	self.camera = self:GetCamera(self.camera_mode)
end

function WeekendHappyView:__delete()

end

-- function WeekendHappyView:Open()
-- 	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WEEKENDHAPPY) then
-- 		SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
-- 		return
-- 	end
-- 	-- BaseView.Open(self)
-- end

--加载回调
function WeekendHappyView:LoadCallBack()
	self.is_free = false
	self.is_have_ten_key = false
	self.is_have_one_key = false
	self.is_show_anim = true
	self.toggle_index = nil
	self.data_list = {}
	self.weekend_happy_reward_item_list = {}
	local day = TimeCtrl.Instance:GetCurOpenServerDay()
	local icon_id = day <= 4 and 2 or 1								--智扬说开服第四天开一次 名字叫首饰狂欢 以后开启的都加周末狂欢
	local bundle, asset = ResPath.GetWeekendTitle(icon_id)
	self.node_list["Title"].image:LoadSprite(bundle, asset, function()
		self.node_list["Title"].image:SetNativeSize()
	end)
	
	self.node_list["MianFeiTime"].gameObject:SetActive(false)
	self.node_list["Free"].gameObject:SetActive(false)
	-- 保底奖励
	self.animator = self.node_list["EffectAnm"].animator
	self.data_list = WeekendHappyData.Instance:GetWeekendHappyRewardItemConfig()
	self.node_list["Toggle"].toggle:AddClickListener(BindTool.Bind(self.SetAnimSwitch, self))
	self.reward_list = self.node_list["ListView"]
	local list_delegate = self.reward_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetLengthsOfCell, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	-- 珍稀展示
	self.rare_reward_list = {}
	for i = 1, MAX_RARE_SHOW_NUM do
		self.rare_reward_list[i] = ItemCell.New()
		if i == MAX_RARE_SHOW_NUM then
			self.rare_reward_list[i].root_node.rect.sizeDelta = Vector2(140, 140)
		else
			self.rare_reward_list[i].root_node.rect.sizeDelta = Vector2(108, 108)
		end
		self.rare_reward_list[i]:SetInstanceParent(self.node_list["Point" .. i].gameObject, false)
		self.rare_reward_list[i]:SetIndex(i)
	end

	for i = 1, MAX_RIGHT_SHOW_NUM do
		local index = i + MAX_RARE_SHOW_NUM
		self.rare_reward_list[index] = ItemCell.New()
		self.rare_reward_list[index]:SetInstanceParent(self.node_list["Point" .. index].gameObject, false)
		self.rare_reward_list[index]:SetIndex(index)
	end

	for i = 1, MAX_BUTTON_NUM do
		self.node_list["Btn" .. i].button:AddClickListener(BindTool.Bind(self.OnClickDraw, self, i))
	end
	self.node_list["Close"].button:AddClickListener(BindTool.Bind(self.OnCloseClick, self))
	self.node_list["Btn_Ware"].button:AddClickListener(BindTool.Bind(self.OnWareHoseClick, self))
	self.node_list["Lucky"].button:AddClickListener(BindTool.Bind(self.OnClickLucker, self))

	if not self.item_change_callback then
		self.item_change_callback = BindTool.Bind(self.FlushDownShow, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_change_callback)
	end
	TreasureCtrl.Instance:SendChestShopItemListReq(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP)
	Runner.Instance:AddRunObj(self, 3)
end

--打开界面的回调
function WeekendHappyView:OpenCallBack()
	self.camera = self:GetCamera(self.camera_mode)
	WeekendHappyData.Instance:SetIsOpen()
	self.data_list = WeekendHappyData.Instance:GetWeekendHappyRewardItemConfig()
	self:Flush()
	self.reward_list.scroller:ReloadData(0)
end

--关闭界面的回调
function WeekendHappyView:CloseCallBack()
	-- override
	RemindManager.Instance:Fire(RemindName.WeekendHappyRemind)
end

--关闭界面释放回调
function WeekendHappyView:ReleaseCallBack()
	for k, v in pairs(self.rare_reward_list) do
		v:DeleteMe()
	end
	self.rare_reward_list = {}
	self.animator = nil
	for k, v in pairs(self.weekend_happy_reward_item_list) do
		v:DeleteMe()
	end
	self.weekend_happy_reward_item_list = {}
	self.reward_list = nil

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	--释放计时器
	if CountDown.Instance:HasCountDown(self.count_down) then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.item_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_callback)
		self.item_change_callback = nil
	end

	Runner.Instance:RemoveRunObj(self)
	self.camera = nil
	self:ClearClickDelay()
end

function WeekendHappyView:Update(now_time, elapse_time)
	if self.camera ~= nil then
		local camera_rotation = self.camera.transform.rotation
		for i = 1, MAX_RARE_SHOW_NUM - 1 do
			if self.node_list["Point0" .. i] then
				self.node_list["Point0" .. i].gameObject.transform.rotation = camera_rotation
			end
		end
	end
end

function WeekendHappyView:GetLengthsOfCell()
	return #self.data_list
end

function WeekendHappyView:SetAnimSwitch()
	self.is_show_anim = not self.node_list["Toggle"].toggle.isOn
end

--刷新奖励格子
function WeekendHappyView:RefreshCell(cell, cell_index)
	local item_cell = self.weekend_happy_reward_item_list[cell]
	if nil == item_cell then
		item_cell = WeekendHappyRewardItem.New(cell.gameObject, self)
		self.weekend_happy_reward_item_list[cell] = item_cell
	end
	item_cell:SetToggleGroup(self.reward_list.toggle_group)
	item_cell:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))
	item_cell:SetIndex(cell_index)
	item_cell:SetToggleSel(self.toggle_index == cell_index)
	item_cell:SetData(self.data_list[cell_index + 1])
end

function WeekendHappyView:ChangeToIndex(index)
	self.toggle_index = index
end

--刷新
function WeekendHappyView:OnFlush()
	--刷新时间
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end

	--读取珍稀展示配置
	local happy_rare_show = WeekendHappyData.Instance:GetWeekendHappyCfgByList()
	for i = 1, MAX_RARE_SHOW_NUM do
		if nil == happy_rare_show[i] then
			self.node_list["Point" .. i]:SetActive(false)
		else
			self.rare_reward_list[i]:SetData(happy_rare_show[i].reward_item)
		end
	end

	for j = 1, MAX_RIGHT_SHOW_NUM do
		local index = j + MAX_RARE_SHOW_NUM
		if nil == happy_rare_show[index] then
			self.node_list["Point" .. index]:SetActive(false)
		elseif happy_rare_show[index].reward_item then
			happy_rare_show[index].reward_item.is_from_extreme = 3	 					-- 唐圣说右上角展示3星首饰写死 不会变
			self.rare_reward_list[index]:SetData(happy_rare_show[index].reward_item)
		end
		
	end

	self.data_list = WeekendHappyData.Instance:GetWeekendHappyRewardItemConfig()
	self.reward_list.scroller:RefreshActiveCellViews()

	--释放计时器
	if CountDown.Instance:HasCountDown(self.count_down) then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	--抽奖次数进度
	self.node_list["HasTimes"].text.text = WeekendHappyData.Instance:GetChouTimes() or 0

	--下次免费时间
	local next_free_tao_timestamp = WeekendHappyData.Instance:GetNextFreeTaoTimestamp()
	if next_free_tao_timestamp == nil then
		-- self.next_free_time = false
		self.node_list["MianFeiTime"].gameObject:SetActive(false)
		self.is_free = false
	else
		-- self.next_free_time = true
		local server_time = TimeCtrl.Instance:GetServerTime()
		if server_time - next_free_tao_timestamp >= 0 then
			self.is_free = true
			self:FlushFreeTime(true)
		else
			self.is_free = false
			self.count_down = CountDown.Instance:AddCountDown(next_free_tao_timestamp - server_time, 1, BindTool.Bind(self.FlushCountDown, self))
		end
	end
	
	self:FlushWareRed()
	self:FlushDownShow()
end

function WeekendHappyView:FlushWareRed()			-- 唐胜说给仓库按钮加红点 不用提示主界面图标
	self.node_list["treasureRed"]:SetActive(TreasureData.Instance:GetChestCount() > 0) 
end

function WeekendHappyView:FlushDownShow()
	local ten_key_num = WeekendHappyData.Instance:GetWeekendHappyTenKeyNum()
	if ten_key_num ~= nil then
		self.is_have_ten_key = ten_key_num > 0
		self.node_list["TenKeys"].text.text = ten_key_num
	end

	local one_key_num = WeekendHappyData.Instance:GetWeekendHappyOneKeyNum()
	if one_key_num ~= nil then
		self.is_have_one_key = one_key_num > 0
		self.node_list["OneKey"].text.text = one_key_num
	end

	--读取消费价格
	local draw_gold_list = WeekendHappyData.Instance:GetWeekendHappyDrawCost()
	if nil ~= draw_gold_list then
		self.node_list["CostTxt1"].text.text = draw_gold_list.once_gold
		self.node_list["Cost1"].gameObject:SetActive(not self.is_free and not self.is_have_one_key)
		self.node_list["Free"].gameObject:SetActive(self.is_free)
		self.node_list["redpoint1"].gameObject:SetActive(self.is_free or self.is_have_one_key)
		self.node_list["Key1"]:SetActive(self.is_have_one_key and not self.is_free)

		self.node_list["CostTxt2"].text.text = draw_gold_list.tenth_gold
		self.node_list["Cost2"]:SetActive(not self.is_have_ten_key)
		self.node_list["Key2"].gameObject:SetActive(self.is_have_ten_key)
		self.node_list["redpoint2"].gameObject:SetActive(self.is_have_ten_key)
	end
end

--计时器
function WeekendHappyView:FlushCountDown(elapse_time, total_time)
	local time_interval = total_time - elapse_time
	if time_interval > 0 then
		self:FlushFreeTime(false)
		self.node_list["MianFeiTime"].text.text = TimeUtil.FormatSecond2HMS(time_interval) .. Language.Common.FreeTime
	else
		self:FlushFreeTime(true)
	end
end

function WeekendHappyView:FlushFreeTime(isfree)
	self.is_free = isfree
	self.node_list["MianFeiTime"].gameObject:SetActive(not isfree)
	self.node_list["Free"].gameObject:SetActive(isfree)
	self.node_list["redpoint1"].gameObject:SetActive(isfree or self.is_have_one_key)
	self.node_list["Cost1"].gameObject:SetActive(not isfree and not self.is_have_one_key)
end

function WeekendHappyView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WEEKENDHAPPY)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end

	local time_str = ""
	local timer = TimeUtil.Format2TableDHMS(time)
	if timer.day > 0 then
		time_str = string.format(Language.Activity.ActivityTime8, timer.day, timer.hour)
	else
		time_str = string.format(Language.Activity.ActivityTime9, timer.hour, timer.min, timer.s)
	end
	self.node_list["Time"].text.text = time_str
end

function WeekendHappyView:OnCloseClick()
	self:Close()
end

function WeekendHappyView:OnWareHoseClick()
	ViewManager.Instance:Open(ViewName.TipsTreasureWarehouseView)
end

function WeekendHappyView:ClearClickDelay()
	if self.send_delay then
		GlobalTimerQuest.CancelQuest(self.send_delay)
		self.send_delay = nil
	end
end

function WeekendHappyView:OnClickDraw(index)
	local activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WEEKENDHAPPY
	local operate_type = RA_LOTTERY_1_OPERA_TYPE.RA_LOTTERY_1_OPERA_TYPE_DO_LOTTERY
	local param_1 = HAPPY_OPERATE_PARAM[index]
	WeekendHappyData.Instance:SetChestShopMode(HAPPY_CHESTSHOP_MODE[index])
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local draw_gold_list = WeekendHappyData.Instance:GetWeekendHappyDrawCost()
	local cost_gold = index == 1 and draw_gold_list.once_gold or draw_gold_list.tenth_gold
	if self.is_show_anim and vo.gold > cost_gold then
		self:ClearClickDelay()
		
		self.animator:SetTrigger("huiju")
		self.animator:SetFloat("Blend", 12)
		
		self.send_delay = GlobalTimerQuest:AddDelayTimer(function ()
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(activity_type, operate_type, param_1)
			self.animator:SetFloat("Blend", 1)
			end, 1.8)
	else
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(activity_type, operate_type, param_1)
	end
end

function WeekendHappyView:OnClickLucker()
	ActivityCtrl.Instance:SendActivityLogSeq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WEEKENDHAPPY)
end

-------------------------------------------保底奖励-------------------------------------------------------
WeekendHappyRewardItem = WeekendHappyRewardItem or BaseClass(BaseCell)
function WeekendHappyRewardItem:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.node_list["Toggle"].toggle:AddClickListener(BindTool.Bind(self.OnClickReward, self))
	self.item_cell:ShowHighLight(false)
	self.vip_limit = 0
	self.vip_can = false
	self.is_got = false
	self.can_get = false
	self.index = 0
end

function WeekendHappyRewardItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function WeekendHappyRewardItem:SetToggleGroup(toggle_group)
	self.node_list["Toggle"].toggle.group = toggle_group
end

function WeekendHappyRewardItem:SetSelectCallback(call_back)
	self.select_callback = call_back
end

function WeekendHappyRewardItem:SetToggleSel(is_on)
	self.node_list["Toggle"].toggle.isOn = is_on
end

function WeekendHappyRewardItem:SetIndex(index)
	self.index = index
end

function WeekendHappyRewardItem:SetData(data)
	if nil == data then return end
	self.seq = data.seq
	self.vip_limit = data.vip_limit
	local role_info = GameVoManager.Instance:GetMainRoleVo()
	if role_info.vip_level ~= nil and self.vip_limit ~= nil then
		self.vip_can = role_info.vip_level >= self.vip_limit
	end
	if data.reward_item ~= nil and data.reward_item[0] ~= nil then
		self.item_cell:SetData(data.reward_item[0])
	end
	
	local is_got = WeekendHappyData.Instance:GetIsFetchFlag(self.seq)
	local can_get_times = WeekendHappyData.Instance:GetCanFetchFlagByIndex(self.seq)
	local draw_times = WeekendHappyData.Instance:GetChouTimes()
	self.is_got = is_got
	self.can_get = draw_times >= can_get_times and not is_got
	self.node_list["VipText"].text.text = Language.Common.VIP .. self.vip_limit
	self.node_list["Effect"].gameObject:SetActive(self.can_get and self.vip_can)
	self.node_list["Gou"].gameObject:SetActive(self.is_got)
	self.node_list["TimesTxt"].text.text = string.format(Language.Activity.TimesGet, can_get_times)
end

function WeekendHappyRewardItem:OnClickReward()
	self.node_list["Toggle"].toggle.isOn = true
	if self.select_callback then
		self.select_callback(self.index)
	end
	if (self.can_get and self.vip_can) or self.is_got then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WEEKENDHAPPY, RA_LOTTERY_1_OPERA_TYPE.RA_LOTTERY_1_OPERA_TYPE_FETCH_PERSON_REWARD, self.seq)
	elseif (self.can_get and not self.vip_can) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.VipLimitTips)
	else
		self.item_cell:OnClickItemCell()
	end
end
