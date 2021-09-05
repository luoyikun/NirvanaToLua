JuHuaSuanView = JuHuaSuanView or BaseClass(BaseView)

function JuHuaSuanView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour"},
		{"uis/views/randomact/juhuasuan_prefab", "JuHuaSuanView"},
	}
	self.play_audio = true
	self.cell_list = {}
	self.end_time = 0
	self.data = {}
	self.reward_id = 0
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function JuHuaSuanView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))

	-- self.node_list["ImgTitle"].image:LoadSprite("uis/views/randomact/juhuasuan/images_atlas","title_text.png", function()
	-- 	self.node_list["ImgTitle"].image:SetNativeSize() end)
	self.node_list["Name"].text.text = Language.RandAct.JuTeHuiTitle

	self.node_list["BtnBuyAll"].button:AddClickListener(BindTool.Bind(self.ClickBuyAll, self))
	self:InitScroller()
	self.reward_item = ItemCell.New()
	self.reward_item:SetInstanceParent(self.node_list["Item"])
end

function JuHuaSuanView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.reward_item then
		self.reward_item:DeleteMe()
		self.reward_item = nil
	end
end

function JuHuaSuanView:InitScroller()
	local delegate = self.node_list["ListView"].list_simple_delegate
	-- 生成数量
	self.data = JuHuaSuanData.Instance:GetJuHuaSuanData()
	delegate.NumberOfCellsDel = function()
		return #self.data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] = JuHuaSuanCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
		end
		target_cell:SetData(self.data[data_index])
	end
end

function JuHuaSuanView:OpenCallBack()
	self:Flush()
	RemindManager.Instance:Fire(RemindName.JuHuaSuan)
	RemindManager.Instance:SetRemindToday(RemindName.JuHuaSuan)
end

function JuHuaSuanView:ShowIndexCallBack(index)

end

function JuHuaSuanView:ClickBuyAll()
	local item_cfg = ItemData.Instance:GetItemConfig(self.reward_id)
	local reward_name = ""
	if item_cfg then
		reward_name = item_cfg.name
	end
	TipsCtrl.Instance:ShowCommonAutoView("", string.format(Language.RandAct.BuyAllGiftTips, JuHuaSuanData.Instance:BuyAllNeed(), reward_name), BindTool.Bind(self.SendBuyAllGift, self))
end

function JuHuaSuanView:SendBuyAllGift()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIANYUAN_TREAS, XIANYUAN_TREAS_OPERA_TYPE.BUY_ALL)
end

function JuHuaSuanView:OnFlush(param_t)
	self.data = JuHuaSuanData.Instance:GetJuHuaSuanData()
	if self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
	local buy_all_need = JuHuaSuanData.Instance:BuyAllNeed()
	self.node_list["TxtGold"].text.text = buy_all_need
	UI:SetButtonEnabled(self.node_list["BtnBuyAll"], buy_all_need > 0)
	if self.data and self.data[1] then
		self.node_list["TxtNum"].text.text = self.data[1].max_reward_day
	end
	local act_other_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfigOtherCfg() or {}
	
	local all_buy_reward = act_other_cfg.xianyuan_treas_all_buy_reward
	self.reward_id = all_buy_reward and all_buy_reward.item_id or 0
	self.reward_item:SetData(all_buy_reward)
end

function JuHuaSuanView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIANYUAN_TREAS)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	if time > 3600 * 24 then
		self.node_list["TxtTime"].text.text = string.format(Language.Activity.ActivityTime1, TimeUtil.FormatSecond(time, 6))
	else
		self.node_list["TxtTime"].text.text = string.format(Language.Activity.ActivityTime1, TimeUtil.FormatSecond(time, 0))
	end
end

---------------------------------------------------------------
--滚动条格子
JuHuaSuanCell = JuHuaSuanCell or BaseClass(BaseCell)
function JuHuaSuanCell:__init()
	self.reward_list = {}
	for i = 1, 3 do
		self.reward_list[i] = ItemCell.New()
		self.reward_list[i]:SetInstanceParent(self.node_list["ItemList"])
	end
	self.node_list["BtnStart"].button:AddClickListener(BindTool.Bind(self.ClickBuy, self))
end

function JuHuaSuanCell:__delete()
	for k,v in pairs(self.reward_list) do
		v:DeleteMe()
	end
	self.reward_list = {}

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function JuHuaSuanCell:OnFlush()
	if nil == self.data then return end
	local item_list = ItemData.Instance:GetGiftItemList(self.data.reward_item.item_id)
	for k,v in pairs(self.reward_list) do
		if item_list[k] then
			v:SetData(item_list[k])
		end
		v.root_node:SetActive(item_list[k] ~= nil)
	end
	self.node_list["TxtName"].text.text = self.data.theme_name
	self.node_list["TxtGold"].text.text = string.format("（       <size=22><color='#00ff30'>%s</color></size>）", self.data.consume_gold)
	local has_buy = JuHuaSuanData.Instance:HasBuyGift(self.data.seq)
	local can_receive = JuHuaSuanData.Instance:GetCanReceiveGift(self.data.seq)
	local buy_num = JuHuaSuanData.Instance:GetReceiceGiftNum(self.data.seq) or 0
	if not has_buy or can_receive then
		self.node_list["TxtBuy"].text.text = has_buy and Language.Common.BuyOrGet[2] or Language.Common.BuyOrGet[1]
	else
		self.node_list["TxtBuy"].text.text = string.format(Language.RandAct.BtnTxt, buy_num)
	end
	self.node_list["left_time"]:SetActive(not (not has_buy or can_receive))
	if buy_num >= 3 then
		self.node_list["left_time"]:SetActive(false)
	end
	UI:SetButtonEnabled(self.node_list["BtnStart"], not has_buy or can_receive)
	self.node_list["ImgRedPoint"]:SetActive(has_buy and can_receive)

	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushTime, self), 1)
		self:FlushTime()
	end
end

function JuHuaSuanCell:ClickBuy()
	if self.data == nil then return end
	if JuHuaSuanData.Instance:HasBuyGift(self.data.seq) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIANYUAN_TREAS, XIANYUAN_TREAS_OPERA_TYPE.FETCH_REWARD, self.data.seq)
	else
		TipsCtrl.Instance:ShowCommonAutoView("", string.format(Language.RandAct.BuyGiftTips, self.data.consume_gold), BindTool.Bind(self.SendBuyGift, self))
	end
end

function JuHuaSuanCell:SendBuyGift()
	if self.data == nil then return end
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIANYUAN_TREAS, XIANYUAN_TREAS_OPERA_TYPE.BUY, self.data.seq)
end

function JuHuaSuanCell:FlushTime()
	local now_time = TimeCtrl.Instance:GetServerTime() --当前时间戳
	local day_end_time = TimeUtil.NowDayTimeEnd(now_time) - now_time --当天结束与当前差值
	if day_end_time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	self.node_list["left_time"].text.text = string.format(Language.JuBaoPen.GainAgain, TimeUtil.FormatSecond2HMS(day_end_time))
end