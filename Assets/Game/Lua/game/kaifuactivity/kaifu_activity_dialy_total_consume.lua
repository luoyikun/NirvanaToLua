DailyTotalConsume =  DailyTotalConsume or BaseClass(BaseRender)
--开服累计消费 TotalComsume
function DailyTotalConsume:__init()
	self.contain_cell_list = {}
end

function DailyTotalConsume:__delete()
	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}
end

function DailyTotalConsume:OpenCallBack()
	local list_delegate = self.node_list["ScrollerListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

	local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CONSUME_GOLD)
	self:SetTime(0, rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, BindTool.Bind(self.SetTime, self))
	self.node_list["BtnPlus"].button:AddClickListener(BindTool.Bind(self.ClickReChange, self))
	self.reward_list = KaifuActivityData.Instance:GetOpenActDailyTotalConsumeReward()
end

function DailyTotalConsume:CloseCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

function DailyTotalConsume:ClickReChange()
	ViewManager.Instance:Open(ViewName.Shop, TabIndex.shop_youhui)
end

function DailyTotalConsume:OnFlush()
	self.reward_list = KaifuActivityData.Instance:GetOpenActDailyTotalConsumeReward()

	if self.node_list["ScrollerListView"] then
		self.node_list["ScrollerListView"].scroller:ReloadData(0)
	end

	local info = KaifuActivityData.Instance:GetDailyTotalConsumeInfo()
	self.node_list["TxtHasConsume"].text.text = info ~= nil and CommonDataManager.ConverMoney(info.consume_gold or 0)
end

function DailyTotalConsume:FlushTotalConsume()
	self:Flush()
end

function DailyTotalConsume:SetTime(elapse_time, total_time)
	local rest_time = math.floor(total_time - elapse_time)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)

	local time_str = nil
	if time_tab.day >= 1 then
		time_str = string.format(Language.Activity.ActivityTime8, time_tab.day, time_tab.hour)
	else
		time_str = string.format(Language.Activity.ActivityTime9, time_tab.hour, time_tab.min, time_tab.s)
	end
	self.node_list["TxtRestTime"].text.text = time_str

end

function DailyTotalConsume:GetNumberOfCells()
	return #self.reward_list
end

function DailyTotalConsume:RefreshCell(cell, cell_index)
	if self.contain_cell_list == nil then return end
	local contain_cell = self.contain_cell_list[cell]

	if contain_cell == nil then
		contain_cell = DailyTotalConsumeCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1
	contain_cell:SetData(self.reward_list[cell_index])
	contain_cell:Flush()
end

----------------------------DailyTotalConsumeCell---------------------------------
DailyTotalConsumeCell = DailyTotalConsumeCell or BaseClass(BaseCell)

local MAX_REWARD_CELL_NUM = 4

function DailyTotalConsumeCell:__init()
	self.data = {}
	self.item_cell_list = {}
	self.node_list["BtnGetReward"].button:AddClickListener(BindTool.Bind(self.OnClickGet, self))

	for i = 1, MAX_REWARD_CELL_NUM do
		local item_cell = ItemCell.New()
		self.item_cell_list[i] = item_cell
		item_cell:SetInstanceParent(self.node_list["CellRewardItem" .. i])
	end

end

function DailyTotalConsumeCell:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function DailyTotalConsumeCell:SetData(data)
	self.data = data
end

function DailyTotalConsumeCell:OnFlush()
	local info = KaifuActivityData.Instance:GetDailyTotalConsumeInfo()
	local cur_value = info ~= nil and info.consume_gold or 0

	local color = cur_value >= self.data.need_consume_gold and "67FF5F" or "FF3939FF"
	local outline = cur_value >= self.data.need_consume_gold and "00210280" or "4D161680"
	-- local str = string.format(Language.Activity.ReChargeRewardTips, self.data.need_consume_gold, cur_value, color, outline, self.data.need_consume_gold)
	-- RichTextUtil.ParseRichText(self.node_list["TxtComsumeTips"].rich_text, str, 22)
	self.node_list["TxtNeed"].text.text = self.data.need_consume_gold
	KaifuActivityData.Instance:OutLineRichText(cur_value, self.data.need_consume_gold, self.node_list["TextValue"], 1)
	local reward_list = ServerActivityData.Instance:GetCurrentRandActivityRewardCfg(self.data.reward_item, true)
	for i = 1, MAX_REWARD_CELL_NUM do
		if reward_list ~= nil and reward_list[i] then
			self.item_cell_list[i]:SetData(reward_list[i])
			self.node_list["CellRewardItem" .. i]:SetActive(true)
		else
			self.node_list["CellRewardItem" .. i]:SetActive(false)
		end
	end

	local fetch_reward_flag = self.data.fetch_reward_flag == 1
	local str = fetch_reward_flag and Language.Common.YiLingQu or (cur_value >= self.data.need_consume_gold and Language.Common.LingQu or Language.Common.WEIDACHENG)

	self.node_list["TxtInBtn"].text.text = str
	UI:SetButtonEnabled(self.node_list["BtnGetReward"], (not fetch_reward_flag and cur_value >= self.data.need_consume_gold))
	self.node_list["EffectInBtn"]:SetActive(not fetch_reward_flag and cur_value >= self.data.need_consume_gold)
	self.node_list["ImgHasGet"]:SetActive(fetch_reward_flag and cur_value >= self.data.need_consume_gold)
	self.node_list["BtnGetReward"]:SetActive(not fetch_reward_flag)
end

function DailyTotalConsumeCell:OnClickGet()
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CONSUME_GOLD, RA_SINGLE_CHONGZHI_OPERA_TYPE.RA_SINGLE_CHONGZHI_OPERA_TYPE_FETCH_REWARD, self.data.seq)
end