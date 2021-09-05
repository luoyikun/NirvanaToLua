LeiJiRewardView =  LeiJiRewardView or BaseClass(BaseRender)
--累充回馈 LiejiReward
function LeiJiRewardView:__init()
	self.contain_cell_list = {}
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHARGE_REPALMENT, RA_CHARGE_REPAYMENT_OPERA_TYPE.RA_CHARGE_REPAYMENT_OPERA_TYPE_QUERY_INFO)
end

function LeiJiRewardView:__delete()
	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end

	self.contain_cell_list = {}
end

function LeiJiRewardView:OpenCallBack()
	KaifuActivityData.Instance:IsShowLeiChongSign()
	local list_delegate = self.node_list["ScrollerListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

	local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHARGE_REPALMENT)
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
			self:SetTime(rest_time)
	end)

	self.node_list["BtnPlus"].button:AddClickListener(BindTool.Bind(self.ClickReChange, self))
	-- self.node_list["TxtChongZhiCount"].text.text = CommonDataManager.ConverMoney(KaifuActivityData.Instance:GetLeiJiChargeValue())

	local opengameday = TimeCtrl.Instance:GetCurOpenServerDay()
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	self.reward_list = KaifuActivityData.Instance:GetLeiJiChargeRewardCfg()
end

function LeiJiRewardView:CloseCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end


end

function LeiJiRewardView:ClickReChange()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function LeiJiRewardView:OnFlush()
	self.reward_list = KaifuActivityData.Instance:GetLeiJiChargeRewardCfg()

	if self.node_list["ScrollerListView"] then
		self.node_list["ScrollerListView"].scroller:ReloadData(0)
	end

	self.node_list["TxtChongZhiCount"].text.text = CommonDataManager.ConverMoney(KaifuActivityData.Instance:GetLeiJiChargeValue() or 0)
end

function LeiJiRewardView:SetTime(rest_time)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local str = ""

	if time_tab.day > 0 then
		str = string.format(Language.Activity.ActivityTime8, time_tab.day, time_tab.hour)
	else
		str = string.format(Language.Activity.ActivityTime9, time_tab.hour, time_tab.min, time_tab.s)
	end

	self.node_list["TxtLastTimeTips"].text.text = str
end

function LeiJiRewardView:GetNumberOfCells()
	return #self.reward_list
end

function LeiJiRewardView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]

	if contain_cell == nil then
		contain_cell = LeiJiChargeLevelCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1
	contain_cell:SetItemData(self.reward_list[cell_index])
	contain_cell:SetCostData()
	contain_cell:Flush()
end

----------------------------LeiJiChargeLevelCell---------------------------------
LeiJiChargeLevelCell = LeiJiChargeLevelCell or BaseClass(BaseCell)

function LeiJiChargeLevelCell:__init()
	self.reward_data = {}
	self.node_list["BtnGetReward"].button:AddClickListener(BindTool.Bind(self.OnClickGet, self))
 	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["CellItemIcon"])
end

function LeiJiChargeLevelCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function LeiJiChargeLevelCell:OnClickGet()
	local is_active = KaifuActivityData.Instance:GetLeiJiChargeRewardIsActive(self.reward_data.seq)
	local is_fench = KaifuActivityData.Instance:GetLeiJiChargeRewardIsFetch(self.reward_data.seq)
	if is_active == 0 then
		VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
		ViewManager.Instance:Open(ViewName.VipView)
		return
	end
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHARGE_REPALMENT, RA_CHARGE_REPAYMENT_OPERA_TYPE.RA_CHARGE_REPAYMENT_OPERA_TYPE_FETCH_REWARD, self.reward_data.seq)
end

function LeiJiChargeLevelCell:SetItemData(data)
	self.reward_data = data
end

function LeiJiChargeLevelCell:SetCostData()
	self.node_list["TxtChongZhiTips"].text.text = self.reward_data.charge_value or 0 	--string.format(Language.Activity.TotalRecharge, self.reward_data.charge_value or 0) 
	self.node_list["TxtLoginReward"].text.text = self.reward_data.bind_gold_repayment or 0	--string.format(Language.Activity.DayLoginReward, self.reward_data.bind_gold_repayment or 0) 
end

function LeiJiChargeLevelCell:OnFlush()
	self.item_cell:SetData(self.reward_data.reward_item)
	local is_active = KaifuActivityData.Instance:GetLeiJiChargeRewardIsActive(self.reward_data.seq)
	local is_fench = KaifuActivityData.Instance:GetLeiJiChargeRewardIsFetch(self.reward_data.seq)

	local str = ""

	if is_active == 0 and is_fench == 0 then
		str = Language.Recharge.GoReCharge
	elseif is_active == 1 and is_fench == 0 then
		str = Language.Common.LingQu
	elseif is_active == 1 and is_fench == 1 then
		str = Language.Common.YiLingQu
	end
	
	self.node_list["TxtInBtn"].text.text = str
	self.node_list["BtnGetReward"]:SetActive(is_fench == 0)
	self.node_list["ImgHadGotIcon"]:SetActive(is_fench == 1)
	UI:SetButtonEnabled(self.node_list["BtnGetReward"], is_fench == 0)
	self.node_list["EffectInBtn"]:SetActive(is_active == 1 and is_fench == 0)
end