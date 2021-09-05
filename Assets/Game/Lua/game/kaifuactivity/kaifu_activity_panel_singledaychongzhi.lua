KaifuActivityPanelSingleDayChongZhi = KaifuActivityPanelSingleDayChongZhi or BaseClass(BaseRender)
--单日累充
function KaifuActivityPanelSingleDayChongZhi:__init()
	self.contain_cell_list = {}
	self.reward_list = {}
end

function KaifuActivityPanelSingleDayChongZhi:__delete()
	if self.contain_cell_list then
		for k , v in pairs(self.contain_cell_list) do
			v:DeleteMe()
		end
	end
end

function KaifuActivityPanelSingleDayChongZhi:OpenCallBack()
	local list_delegate = self.node_list["ScrollerListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_SINGLE_DAY_CHARGE)
	self.reward_list = KaifuActivityData.Instance:GetKaifuActivityCfgByType(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_SINGLE_DAY_CHARGE)

	if self.reward_list == nil or next(self.reward_list) == nil then return end

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
			self:SetTime(rest_time)
	end)

	self.node_list["TxtChongZhiCount"].text.text = CommonDataManager.ConverMoney(KaifuActivityData.Instance:GetDayChongZhiCount())
	self.node_list["BtnPlus"].button:AddClickListener(BindTool.Bind(self.ClickReChange, self))
end

function KaifuActivityPanelSingleDayChongZhi:CloseCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

function KaifuActivityPanelSingleDayChongZhi:ClickReChange()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function KaifuActivityPanelSingleDayChongZhi:GetNumberOfCells()
	return #self.reward_list
end

function KaifuActivityPanelSingleDayChongZhi:RefreshCell(cell, cell_index)
	
	local contain_cell = self.contain_cell_list[cell]
	
	if contain_cell == nil then
		contain_cell = SingleDayChongZhiCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1
	local type_list = KaifuActivityData.Instance:SortList(2137)
	local is_get_reward = KaifuActivityData.Instance:IsGetReward(type_list[cell_index].seq, 2137)
	local is_complete = KaifuActivityData.Instance:IsComplete(type_list[cell_index].seq, 2137)

	contain_cell:SetChargeValue(type_list[cell_index].cond1)
	contain_cell:SetData(type_list[cell_index], is_get_reward, is_complete)
	contain_cell:Flush()
end

function KaifuActivityPanelSingleDayChongZhi:SetTime(rest_time)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local temp = {}
	for k,v in pairs(time_tab) do
		if k ~= "day" and k ~= "hour" then
			if v < 10 then
				v = tostring('0'..v)
			end
		end
		temp[k] = v
	end
	local str
	if temp.day > 0 then
		str = string.format(Language.Activity.ActivityTime8, temp.day, temp.hour)
	else
		str = string.format(Language.Activity.ActivityTime9, temp.hour, temp.min,temp.s)
	end

	self.node_list["TxtRestTime"].text.text = str
end

function KaifuActivityPanelSingleDayChongZhi:OnFlush()
	self.node_list["TxtChongZhiCount"].text.text = CommonDataManager.ConverMoney(DailyChargeData.Instance:GetChongZhiInfo().today_recharge) 
	self.node_list["ScrollerListView"].scroller:RefreshActiveCellViews()
end

------------------------------SingleDayChongZhiCell-------------------------------------
SingleDayChongZhiCell = SingleDayChongZhiCell or BaseClass(BaseCell)

local MAX_CELL_NUM = 4

function SingleDayChongZhiCell:__init()
	self.is_get_reward = false
	self.is_complete = false
	self.charge_value = 0
	self.item_cell_list = {}
	for i = 1, MAX_CELL_NUM do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.node_list["CellItem_" .. i])
	end

	self.node_list["BtnReCharge"].button:AddClickListener(BindTool.Bind(self.OnClickGet, self))

end

function SingleDayChongZhiCell:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_obj_list = nil
end

function SingleDayChongZhiCell:SetChargeValue(value)
	self.charge_value = value
end

function SingleDayChongZhiCell:OnFlush()
	self.data = self:GetData()
	local item_id = self.data.reward_item[0].item_id
	local reward_list = ItemData.Instance:GetGiftItemList(item_id)

	local recharge_count = DailyChargeData.Instance:GetChongZhiInfo().today_recharge
	local flag = recharge_count >= self.charge_value


	if next(reward_list) then
		for i = 1, MAX_CELL_NUM do
			self.item_cell_list[i]:SetData(reward_list[i])
		end
	end

	self.node_list["TxtTipsChongZhiNum"].text.text = self.charge_value

	self.node_list["TxtBtn"].text.text = flag and Language.Recharge.GetReward or Language.Recharge.ChargeWord


	self.node_list["NodeEffect"]:SetActive(flag and not self.is_get_reward)
	UI:SetButtonEnabled(self.node_list["BtnReCharge"], true)
	if self.is_get_reward then
		self.node_list["NodeEffect"]:SetActive(false)
		self.node_list["BtnReCharge"]:SetActive(false)
		self.node_list["Image"]:SetActive(true)
		--UI:SetButtonEnabled(self.node_list["BtnReCharge"], false)
	else
		self.node_list["BtnReCharge"]:SetActive(true)
		self.node_list["Image"]:SetActive(false)
	end
end

	

function SingleDayChongZhiCell:OnClickGet()
	local recharge_count = DailyChargeData.Instance:GetChongZhiInfo().today_recharge

	local flag = recharge_count >= self.charge_value
	if flag then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_SINGLE_DAY_CHARGE, 1, self.data.seq)
	else
		VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
		ViewManager.Instance:Open(ViewName.VipView)
	end
end

function SingleDayChongZhiCell:SetData(data, is_get_reward, is_complete)
	self.data = data
	self.is_get_reward = is_get_reward
	self.is_complete = is_complete
end