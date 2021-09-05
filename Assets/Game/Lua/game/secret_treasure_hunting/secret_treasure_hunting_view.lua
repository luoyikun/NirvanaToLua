SecretTreasureHuntingView = SecretTreasureHuntingView or BaseClass(BaseView)

local ALL_TYPE = 3
local SLIDER_SHOW_REWARD_NUM = 6 			--进度条显示的奖励数量
local COLUMN = 4
local GOLD_TYPE = {
	[1] = "mijingxunbao3_once_gold",
	[2] = "mijingxunbao3_tentimes_gold",
	[3] = "mijingxunbao3_thirtytimes_gold",
}

local REQUIRE_SEQ = {
	[1] = RA_MIJINGXUNBAO3_CHOU_TYPE.RA_MIJINGXUNBAO3_CHOU_TYPE_1,
	[2] = RA_MIJINGXUNBAO3_CHOU_TYPE.RA_MIJINGXUNBAO3_CHOU_TYPE_10,
	[3] = RA_MIJINGXUNBAO3_CHOU_TYPE.RA_MIJINGXUNBAO3_CHOU_TYPE_30,
}

function SecretTreasureHuntingView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour"},
		{"uis/views/secrettreasurehunting_prefab", "SecretTreasureHuntingView"},
	}

	self.is_modal = true
	self.play_audio = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function SecretTreasureHuntingView:__delete()

end

function SecretTreasureHuntingView:Open()
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MIJINGXUNBAO3) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
		return
	end
	BaseView.Open(self)
end

function SecretTreasureHuntingView:LoadCallBack()
	self.data_list = {}
	self.total_reward_list = {}
	self.secret_treasure_hunting_show_list = {}

	self.node_list["OnWareHoseClick"].button:AddClickListener(BindTool.Bind(self.OnWareHoseClick, self))
	self.node_list["Luck"].button:AddClickListener(BindTool.Bind(self.OnClickOpenLuck, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Name"].text.text = Language.Title.MIJingXunBao

	local list_delegate = self.node_list["ShowListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetLengthsOfCell, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	for i=1, ALL_TYPE do
		self.node_list["OnClick".. i].button:AddClickListener(BindTool.Bind(self.OnClickChouJiang, self, i))
	end

	for i=1, SLIDER_SHOW_REWARD_NUM do


		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["total_reward_" .. i])
		item:SetData(nil)
		table.insert(self.total_reward_list, item)
	end
end

function SecretTreasureHuntingView:ReleaseCallBack()
	self.data_list = {}
	self.btn_text_list = {}
	
	for k,v in pairs(self.secret_treasure_hunting_show_list) do
		v:DeleteMe()
	end
	self.secret_treasure_hunting_show_list = {}

	for k,v in pairs(self.total_reward_list) do
		v:DeleteMe()
	end
	self.total_reward_list = {}

	self:CancelTimeQuest()
	self:CancelCountDown()
end


function SecretTreasureHuntingView:OpenCallBack()
	SecretTreasureHuntingData.Instance:SetIsOpen()
	SecretTreasureHuntingCtrl.Instance:SendGetKaifuActivityInfo(RA_MIJINGXUNBAO3_OPERA_TYPE.RA_MIJINGXUNBAO3_OPERA_TYPE_QUERY_INFO)
	SecretTreasureHuntingData.Instance:FlushHallRedPoindRemind()

	self:GetDataList()
	self.node_list["ShowListView"].scroller:ReloadData(0)
end

function SecretTreasureHuntingView:CloseCallBack()
	self:CancelTimeQuest()
	self:CancelCountDown()
end

function SecretTreasureHuntingView:GetDataList()
	self.data_list = SecretTreasureHuntingData.Instance:GetMiJingXunBaoCfgByList()
end

function SecretTreasureHuntingView:GetLengthsOfCell()
	local num = #SecretTreasureHuntingData.Instance:GetMiJingXunBaoCfgByList()
	return math.ceil(num / COLUMN) or 0
end

function SecretTreasureHuntingView:RefreshCell(cell, cell_index)
	local the_cell = self.secret_treasure_hunting_show_list[cell]
	if nil == the_cell then
		the_cell = SecretTreasureHuntingViewShow.New(cell.gameObject)
		self.secret_treasure_hunting_show_list[cell] = the_cell
	end

	the_cell:SetIndex(cell_index)
	the_cell:SetData(self.data_list)
end

function SecretTreasureHuntingView:ShowNeedGoldText()
	local cfg = SecretTreasureHuntingData.Instance:GetOtherCfgByOpenDay()
	local reward_cfg = SecretTreasureHuntingData.Instance:GetMiJingXunBaoRewardConfig()

	if nil == cfg or nil == reward_cfg then return end

	for i=1, ALL_TYPE do
		if self.node_list["diamond_num_".. i] then
			local gold_type = GOLD_TYPE[i]
			local value = cfg[gold_type] or 0
			self.node_list["diamond_num_".. i].text.text = value
		end
	end

	for i = 1, SLIDER_SHOW_REWARD_NUM do
		if reward_cfg[i] and reward_cfg[i].choujiang_times then
			self.node_list["total_" .. i].text.text = string.format(Language.Activity.CiShu, reward_cfg[i].choujiang_times)
			self.total_reward_list[i]:SetData(reward_cfg[i].reward_item)
		end
	end
end

function SecretTreasureHuntingView:OnFlush()
	self:ShowNeedGoldText()
	self:FlushFreeCountDown()
	self:FlushDataPresentation()
	self:FlushActivityTimeCountDown()
	self:RewardShow()
end

function SecretTreasureHuntingView:FlushDataPresentation()
	local flush_times = SecretTreasureHuntingData.Instance:GetChouTimesByInfo()
	local silder_num = SecretTreasureHuntingData.Instance:GetProValueByTimes(flush_times)
	local key_num, key_color, key_name = SecretTreasureHuntingData.Instance:IsHaveThirtyKey()

	self.node_list["total_count"].text.text = string.format(Language.Activity.CiShu, flush_times)
	self.node_list["silder_num"].slider.value = silder_num
	-- self.node_list["is_have_key1"]:SetActive(key_num > 0)
	self.node_list["is_have_key2"]:SetActive(key_num <= 0)
	self.node_list["key_num"]:SetActive(key_num > 0)
	self.node_list["is_have_key3"]:SetActive(key_num > 0)

	local text = key_num > 0 and Language.Common.X..key_num or ""
	-- local str = ToColorStr(text, key_color)
	self.node_list["key_num"].text.text = text
end

function SecretTreasureHuntingView:FlushActivityTimeCountDown()
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
end

function SecretTreasureHuntingView:FlushFreeCountDown()
	local next_free_tao_timestamp = SecretTreasureHuntingData.Instance:GetNextFreeTaoTimestampByInfo()
	if next_free_tao_timestamp == 0 then
		-- self:ShowFreeTimes()
		self:CancelCountDown()
		self.node_list["reddot_activate1"]:SetActive(true)
		self.node_list["reddot_activate2"]:SetActive(false)
		self.node_list["reddot_activate3"]:SetActive(false)
		self.node_list["free_timer"]:SetActive(false)
		return
	end

	local server_time = TimeCtrl.Instance:GetServerTime()
	local time_diff = next_free_tao_timestamp - server_time
	self:CancelCountDown()
	if time_diff > 0 then
		self.count_down = CountDown.Instance:AddCountDown(time_diff, 1, BindTool.Bind(self.FlushCountDown, self))
	else
		self:ShowFreeTimes()
	end
end

function SecretTreasureHuntingView:FlushCountDown(elapse_time, total_time)
	if elapse_time >= total_time then
		self:ShowFreeTimes()
	end

	self.node_list["reddot_activate1"]:SetActive(true)
	self.node_list["reddot_activate2"]:SetActive(false)
	self.node_list["reddot_activate3"]:SetActive(false)
	self.node_list["free_timer"].text.text = TimeUtil.FormatSecond(total_time - elapse_time) .. Language.SecretTreasureHunting.FreeTime
end

function SecretTreasureHuntingView:ShowFreeTimes()
	local is_free = SecretTreasureHuntingData.Instance:IsFree()
	self:CancelCountDown()
	self.node_list["reddot_activate1"]:SetActive(not is_free)
	self.node_list["reddot_activate2"]:SetActive(is_free)
	self.node_list["reddot_activate3"]:SetActive(is_free)
	self.node_list["free_timer"].text.text = ""
end

function SecretTreasureHuntingView:RewardShow()
	local total_config = SecretTreasureHuntingData.Instance:GetMiJingXunBaoRewardConfig()

	for i = 1, SLIDER_SHOW_REWARD_NUM do
		if total_config[i] and total_config[i].choujiang_times then
			local info_choujiang_times = SecretTreasureHuntingData.Instance:GetChouTimesByInfo()
			local is_get = SecretTreasureHuntingData.Instance:GetCanFetchFlag(i - 1)
			local is_can_get = info_choujiang_times >= total_config[i].choujiang_times and not is_get

			self.node_list["OnClickReward" .. i]:SetActive(is_can_get)
			self.node_list["bg_" .. i]:SetActive(is_get)
			self.node_list["Have_Got_" .. i]:SetActive(is_get)
			self.total_reward_list[i]:SetActive(true)
			if is_can_get then
				self.total_reward_list[i]:ListenClick(BindTool.Bind(self.OnClickReward, self, i))
			end
		end
	end
end

function SecretTreasureHuntingView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MIJINGXUNBAO3)
	local timer = ""
	if time <= 0 then
		self:CancelTimeQuest()
	end

	-- if time > 3600 * 24 then
	-- 	timer = TimeUtil.FormatSecond(time, 6)
	-- elseif time > 3600 then
	-- 	timer = TimeUtil.FormatSecond(time, 1)
	-- else
	-- 	timer = TimeUtil.FormatSecond(time, 2)
	-- end
	timer = TimeUtil.FormatSecond(time, 10)
	self.node_list["timer"].text.text = string.format(Language.Activity.ActivityTime1, timer)
end

function SecretTreasureHuntingView:CancelTimeQuest()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function SecretTreasureHuntingView:CancelCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

-- function SecretTreasureHuntingView:OnCloseClick()
-- 	self:Close()
-- end

function SecretTreasureHuntingView:OnWareHoseClick()
	ViewManager.Instance:Open(ViewName.TipsTreasureWarehouseView)
end

function SecretTreasureHuntingView:OnClickOpenLuck()
	ActivityCtrl.Instance:SendActivityLogSeq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MIJINGXUNBAO3)
end

function SecretTreasureHuntingView:OnClickReward(index)
	local idx = index
	local cfg = SecretTreasureHuntingData.Instance:GetMiJingXunBaoRewardConfig()
	local param_1 = cfg[idx] and cfg[idx].index or 0
	SecretTreasureHuntingCtrl.Instance:SendGetKaifuActivityInfo(RA_MIJINGXUNBAO3_OPERA_TYPE.RA_MIJINGXUNBAO3_OPERA_TYPE_FETCH_REWARD, param_1)
end

function SecretTreasureHuntingView:OnClickChouJiang(index)
	local opera_type = RA_MIJINGXUNBAO3_OPERA_TYPE.RA_MIJINGXUNBAO3_OPERA_TYPE_TAO
	local param_1 = REQUIRE_SEQ[index]
	SecretTreasureHuntingCtrl.Instance:SendGetKaifuActivityInfo(opera_type, param_1)
	SecretTreasureHuntingData.Instance:SetChestShopMode(index)
end

-------------------------------------------显示奖励物品-------------------------------------------------------
SecretTreasureHuntingViewShow = SecretTreasureHuntingViewShow or BaseClass(BaseCell)
function SecretTreasureHuntingViewShow:__init()
	self.item_cell_list = {}
	for i = 1, COLUMN do		
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["image_0" .. i])
		item:SetData(nil)
		table.insert(self.item_cell_list, item)
	end
end

function SecretTreasureHuntingViewShow:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = nil 
end

function SecretTreasureHuntingViewShow:OnFlush()
	if self.data == nil then return end

	for i = 1, COLUMN do
		index = self.index * COLUMN + i
		if self.data[index] and self.data[index].is_show == 1 then
			self.item_cell_list[i]:SetData(self.data[index].reward_item)
			self.item_cell_list[i]:SetItemActive(true)
		else
			self.item_cell_list[i]:SetItemActive(false)
		end
	end
end