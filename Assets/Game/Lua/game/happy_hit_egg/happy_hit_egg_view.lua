HappyHitEggView = HappyHitEggView or BaseClass(BaseView)

local MAX_PROG_GRADE = 3
local MAX_BUTTON_NUM = 3

local HAPPYEGG_OPERATE_PARAM = {
	[1] = RA_HUANLEZADAN_CHOU_TYPE.RA_HUANLEZADAN_CHOU_TYPE_1,
	[2] = RA_HUANLEZADAN_CHOU_TYPE.RA_HUANLEZADAN_CHOU_TYPE_10,
	[3] = RA_HUANLEZADAN_CHOU_TYPE.RA_HUANLEZADAN_CHOU_TYPE_30,
}

local HAPPYEGG_CHESTSHOP_MODE = {
	[1] = CHEST_SHOP_MODE.CHEST_HAPPYHITEGG_MODE_1,
	[2] = CHEST_SHOP_MODE.CHEST_HAPPYHITEGG_MODE_10,
	[3] = CHEST_SHOP_MODE.CHEST_HAPPYHITEGG_MODE_30,
}

function HappyHitEggView:__init()

	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_1"},
		{"uis/views/happyhitegg_prefab", "HappyHitEgg"},
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_2"},
		{"uis/views/happyhitegg_prefab", "HappyHitEggLeftDisplay"},
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp

end

function HappyHitEggView:__delete()

end

function HappyHitEggView:Open()
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_ZADAN) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
		return
	end
	BaseView.Open(self)
end

--加载回调
function HappyHitEggView:LoadCallBack()
	self.diamond_num_list = {}
	self.total_list = {}
	self.draw_lot_ani = {}
	for i=1,3 do
		self.diamond_num_list[i] = self.node_list["diamond_num_"..i]
		self.draw_lot_ani[i] = self.node_list["draw_lot_"..i]
		self.total_list[i] = self.node_list["total_"..i]
		self.total_list[i+3] = self.node_list["total_"..i + 3]
	end

	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	self.cell_list = {}
	self.list_view_delegate = self.node_list["Scroller"].list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
	self.node_list["Scroller"].scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.FlushPage, self))

	self.node_list["BtnWareHoseClick"].button:AddClickListener(BindTool.Bind(self.OnWareHoseClick, self))

	for i=1,MAX_BUTTON_NUM do
		self.node_list["BtnClick"..i].button:AddClickListener(BindTool.Bind(self.OnClickDraw, self, i))
	end

	self.node_list["BtnClickTurnPageLeft"].button:AddClickListener(BindTool.Bind(self.OnClickTurnPage, self, "left"))
	self.node_list["BtnClickTurnPageRight"].button:AddClickListener(BindTool.Bind(self.OnClickTurnPage, self, "right"))
	self.node_list["BtnClcikLog"].button:AddClickListener(BindTool.Bind(self.OnClcikLog, self))

	self.total_reward_list = {}
	for i=1, self:GetRewardCount() do
		self.total_reward_list[i] = ItemCell.New()
		self.total_reward_list[i]:SetInstanceParent(self.node_list["total_reward_"..i])
		self.total_reward_list[i]:SetIndex(i)
	end
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Name"].text.text = Language.Title.HuanLeZaDan

	self:InitModle()
end

--打开界面的回调
function HappyHitEggView:OpenCallBack()
	HappyHitEggData.Instance:SetIsOpen()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_ZADAN,RA_HUANLEZADAN_OPERA_TYPE.RA_HUANLEZADAN_OPERA_TYPE_QUERY_INFO)
	HappyHitEggData.Instance:FlushHallRedPoindRemind()
	self:Flush()
end


--关闭界面的回调
function HappyHitEggView:CloseCallBack()
	-- override
end

--关闭界面释放回调
function HappyHitEggView:ReleaseCallBack()
	self.diamond_num_list = {}
	self.total_list = {}
	self.list_view_delegate  = nil
	self.left_button = nil
	self.display = nil
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	--释放计时器
	if CountDown.Instance:HasCountDown(self.count_down) then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.next_timer then
		GlobalTimerQuest:CancelQuest(self.next_timer)
		self.next_timer = nil
	end

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	self:ClearClickDelay()

	for k,v in pairs(self.total_reward_list) do
		if v then
			v:DeleteMe()
			v = nil
		end
	end
	self.total_reward_list = nil

	for k,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
			v = nil
		end
	end
	self.cell_list = nil	
end

-- --刷新
function HappyHitEggView:OnFlush(param_list)
	--刷新时间
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushActNextTime, self), 1)
		self:FlushActNextTime()
	end
-- 	--读取消费的钻石数量
	local configs = HappyHitEggData.Instance:GetHappyHitEggConfigs()
	self.diamond_num_list[1].text.text = configs.other[1].huanlezadan_once_gold
	self.diamond_num_list[2].text.text = configs.other[2].huanlezadan_tentimes_gold
	self.diamond_num_list[3].text.text = configs.other[3].huanlezadan_thirtytimes_gold
	--读取累计抽奖配置
	for i = 1,self:GetRewardCount() do
		self.total_list[i].text.text = configs.huanlezadan_reward[i].choujiang_times
		self.total_reward_list[i]:SetData(configs.huanlezadan_reward[i].reward_item )
	end

	--判断寻宝次数是否满足
	self:WhetherItMeets()
-- 	--抽奖次数进度
	local flush_times = HappyHitEggData.Instance:GetChouTimes() or 0
	self.node_list["txt_total_count"].text.text = flush_times
	local key_num = ItemData.Instance:GetItemNumInBagById(configs.other[1].huanlezadan_thirtytimes_item_id) or 0
	self.node_list["key_num"].text.text = string.format(Language.HappyHitEgg.KeyText..key_num)
	self.node_list["KeyLable"]:SetActive(key_num > 0)
	self.node_list["LayoutGold"]:SetActive(key_num <= 0)
	self.node_list["show_redpoint"]:SetActive(key_num > 0)

	self.node_list["Scroller"].scroller:RefreshAndReloadActiveCellViews(true)
end

--判断寻宝次数是否满足
function HappyHitEggView:WhetherItMeets()
	local total_config = HappyHitEggData.Instance:GetHappyHitEggConfigs()
	local draw_times = HappyHitEggData.Instance:GetChouTimes() or 0
	for i = 1,self:GetRewardCount() do
		if nil == total_config.huanlezadan_reward[i].choujiang_times then return end
		if draw_times >= total_config.huanlezadan_reward[i].choujiang_times and 
			not HappyHitEggData.Instance:GetCanFetchFlag(self.total_reward_list[i]:GetIndex()) then
			self.total_reward_list[i]:ShowGetEffect(true)
			self.total_reward_list[i]:ListenClick(BindTool.Bind(self.OnClick, self, i))

		else
			self.total_reward_list[i]:ShowGetEffect(false)
			self.total_reward_list[i]:ListenClick()
		end

		if HappyHitEggData.Instance:GetCanFetchFlag(self.total_reward_list[i]:GetIndex()) then
			-- self.total_reward_list[i]:ShowHaseGet(true)-----需解决
		else
			-- self.total_reward_list[i]:ShowHaseGet(false)-----需解决
		end
	end
end

--点击奖励物品事件
function HappyHitEggView:OnClick(i)
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_ZADAN,RA_HUANLEZADAN_OPERA_TYPE.RA_HUANLEZADAN_OPERA_TYPE_FETCH_REWARD, self.total_reward_list[i]:GetIndex() - 1)
end

function HappyHitEggView:SetIndex(index)
	self.index = index
end

function HappyHitEggView:GetRewardCount()
	return #HappyHitEggData.Instance:GetHappyHitEggRewardConfig()
end

function HappyHitEggView:FlushActNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_ZADAN)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	self.node_list["txt_timer"].text.text = TimeUtil.FormatSecond(time, 10)
end

function HappyHitEggView:OnWareHoseClick()
	ViewManager.Instance:Open(ViewName.TipsTreasureWarehouseView)
end

function HappyHitEggView:OnClickDraw(index)
	local activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_ZADAN
	local operate_type = RA_HUANLEZADAN_OPERA_TYPE.RA_HUANLEZADAN_OPERA_TYPE_TAO
	local param1 = HAPPYEGG_OPERATE_PARAM[index]
	HappyHitEggData.Instance:SetChestShopMode(HAPPYEGG_CHESTSHOP_MODE[index])
	self.draw_lot_ani[index].animator:SetTrigger("draw")

	self:ClearClickDelay()
	self.send_delay = GlobalTimerQuest:AddDelayTimer(function ()
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(activity_type, operate_type, param1)
	end, 0.4)
end

function HappyHitEggView:ClearClickDelay()
	if self.send_delay then
		GlobalTimerQuest.CancelQuest(self.send_delay)
		self.send_delay = nil
	end
end

--滚动条数量
function HappyHitEggView:GetNumberOfCells()
	return 2
end

--滚动条刷新
function HappyHitEggView:RefreshView(cell, data_index)
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = HappyHitEggRewardItem.New(cell.gameObject)
		self.cell_list[cell] = group_cell
	end
	group_cell:SetPageIndex(data_index)
	group_cell:Flush()
end

function HappyHitEggView:FlushPage()
	local page = self.node_list["Scroller"].list_page_scroll:GetNowPage()
	if page == 0 then
		self.node_list["left_button"]:SetActive(false)
		self.node_list["BtnClickTurnPageRight"]:SetActive(true)
	elseif page == 1 then
		self.node_list["left_button"]:SetActive(true)
		self.node_list["BtnClickTurnPageRight"]:SetActive(false)
	else
		self.node_list["left_button"]:SetActive(true)
		self.node_list["BtnClickTurnPageRight"]:SetActive(false)
	end
end

function HappyHitEggView:OnClickTurnPage(dir)
	local page = self.node_list["Scroller"].list_page_scroll:GetNowPage()
	if dir == "left" then
		page = page - 1
		if page < 0 then
			return
		end
	else
		page = page + 1
	end

	if page == 0 then
		self.node_list["left_button"]:SetActive(false)
		self.node_list["BtnClickTurnPageRight"]:SetActive(true)
	elseif page == 1 then
		self.node_list["left_button"]:SetActive(true)
		self.node_list["BtnClickTurnPageRight"]:SetActive(false)
	else
		self.node_list["left_button"]:SetActive(true)
		self.node_list["BtnClickTurnPageRight"]:SetActive(false)
	end
	self.node_list["Scroller"].list_page_scroll:JumpToPage(page)
end

function HappyHitEggView:InitModle()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().other
	for i, v in pairs(cfg) do
		if open_day <= v.opengame_day then
			local res_id = v.happyegg_showmodel
			self.model:ClearModel()
			self.model:ChangeModelByItemId(res_id)
			break
		end
	end
end

function HappyHitEggView:OnClcikLog()
	ActivityCtrl.Instance:SendActivityLogSeq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_ZADAN)
end

function HappyHitEggView:FlushNextTime()
	if self.next_timer then
		GlobalTimerQuest:CancelQuest(self.next_timer)
		self.next_timer = nil
	end
	self.node_list["diamond"]:SetActive(true)
	self.node_list["img_reddot_activate"]:SetActive(false)
	self.node_list["show_free"]:SetActive(false)
	self.node_list["mianFeiTime"]:SetActive(false)
	self.node_list["txt_free_timer"]:SetActive(true)
	-- 免费倒计时
	local next_free_tao_timestamp = HappyHitEggData.Instance:GetNextFreeTaoTimestamp()
	local choujiang_times = HappyHitEggData.Instance:GetChouTimes()
	if next_free_tao_timestamp == 0 then
		self.node_list["txt_free_timer"]:SetActive(false)
	end
	if next_free_tao_timestamp ~= 0 or choujiang_times == 0 then
		self:FlushCanNextTime()
		self.next_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushCanNextTime, self), 1)
	end
end

function HappyHitEggView:FlushCanNextTime()
	local next_free_tao_timestamp = HappyHitEggData.Instance:GetNextFreeTaoTimestamp()
	local server_time = TimeCtrl.Instance:GetServerTime()
	local time_str = next_free_tao_timestamp - server_time or 0
	self.node_list["txt_free_timer"].text.text = string.format(Language.HappyHitEgg.FreeTime, TimeUtil.FormatSecond(time_str))
	if time_str <= 0 then
		-- 移除计时器
		if self.next_timer then
			GlobalTimerQuest:CancelQuest(self.next_timer)
			self.next_timer = nil
		end
		self.node_list["diamond"]:SetActive(false)
		self.node_list["img_reddot_activate"]:SetActive(true)
		self.node_list["show_free"]:SetActive(true)
		self.node_list["mianFeiTime"]:SetActive(true)
		self.node_list["txt_free_timer"]:SetActive(false)
		HappyHitEggData.Instance:FlushHallRedPoindRemind()
	end
end

-- -------------------------------------------显示奖励物品-------------------------------------------------------

------------------------------------------------------------------------
HappyHitEggRewardItem = HappyHitEggRewardItem  or BaseClass(BaseRender)

-- local NOW_PAGE = -1
function HappyHitEggRewardItem:__init()
	self.page_index = 0
	-- 累计翻牌达到的档次
	self.cur_grade = 0

	self.item_list = {}
	for i=0,2 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["Item" .. i])
		self.item_list[i]:ListenClick(BindTool.Bind(self.ItemClick, self, i))
	end

	self.show_effect_flag_list = {}
end

function HappyHitEggRewardItem:__delete()
	self.page_index = 0
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end

	self.item_list = {}
end

function HappyHitEggRewardItem:ItemClick(i)
	if self.cur_grade >= i + 1 then
		-- local configs = HappyHitEggData.Instance:GetHappyHitEggConfigs()
		local index = (self.page_index * MAX_PROG_GRADE) + (i + 1)
		-- local return_reward_list = configs.huanlezadan_reward
		-- local data = return_reward_list[index] or {}

		local return_reward_list = HappyHitEggData.Instance:GetReturnReward()
		local seq = return_reward_list[index].cfg.index
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_ZADAN,
																							RA_HUANLEZADAN_OPERA_TYPE.RA_HUANLEZADAN_OPERA_TYPE_FETCH_REWARD, seq)
	else
		self.item_list[i]:OnClickItemCell()
	end
end

function HappyHitEggRewardItem:SetPageIndex(page_index)
	self.page_index = page_index
end

function HappyHitEggRewardItem:OnFlush()
	-- local return_reward_list = HappyHitEggData.Instance:GetHappyHitEggRewardConfig()
	local return_reward_list = HappyHitEggData.Instance:GetReturnReward()
	local draw_times = HappyHitEggData.Instance:GetChouTimes() or 0
	self.cur_grade = 0
	for i = 0,2 do
		local index = (self.page_index * MAX_PROG_GRADE) + (i + 1)
		local data = return_reward_list[index].cfg or {}
		local cell = self.item_list[i]
		cell:SetData(data.reward_item)
		self.node_list["text_desc_" .. i].text.text = string.format(Language.HappyHitEgg.Count, string.format("<color=#FDE45CFF>%s</color>", data.choujiang_times)) 

		-- 获取当前达到第几个档次
		local is_show_effect = false
		local is_show_has_get = false
		local reward_flag =  return_reward_list[index].fetch_flag
		if draw_times >= data.choujiang_times then
			-- local reward_flag = HappyHitEggData.Instance:GetCanFetchFlag(index)
			-- local reward_flag =  return_reward_list[index].fetch_flag
			if reward_flag == 1 then
				is_show_has_get = true
			else
				is_show_effect = true
			end
			self.cur_grade = self.cur_grade + 1
		end
		self.node_list["Have_Got_" .. i]:SetActive(is_show_has_get)
		self.node_list["Mask_" .. i]:SetActive(is_show_has_get)
		self.node_list["ShowEff" .. i]:SetActive(is_show_effect)
		cell:SetHighLight(false)
	end
end