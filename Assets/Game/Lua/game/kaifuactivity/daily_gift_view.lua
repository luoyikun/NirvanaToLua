DailyGiftView = DailyGiftView or BaseClass(BaseRender)

local REWARD_DAY = 7

function DailyGiftView:__init()

	self.cell_list = {}
	self.list = self.node_list["ListView"]
	local list_delegate = self.list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.node_list["BtnChongZhi"].button:AddClickListener(BindTool.Bind(self.OnClickChongZhi, self))
	self:Flush()
end


function DailyGiftView:__delete()
	self.cell_list = nil
	if self.count_down then
        CountDown.Instance:RemoveCountDown(self.count_down)
        self.count_down = nil
    end

    if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

function DailyGiftView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EVERYDAY_NICE_GIFT, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)

	local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EVERYDAY_NICE_GIFT)
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
			self:SetTime(rest_time)
	end)
	self:Flush()
end

function DailyGiftView:CloseCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

end

function DailyGiftView:GetNumberOfCells()
	self.data_list = KaifuActivityData.Instance:GetDailyGitfRewardConfig()
	return #self.data_list
end

function DailyGiftView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local cell_item = self.cell_list[cell]
	if cell_item == nil then
		cell_item = DailyGiftItem.New(cell.gameObject)
		self.cell_list[cell] = cell_item
	end
	local data_list = KaifuActivityData.Instance:GetDailyGitfRewardConfig()
	cell_item:SetIndex(data_index)
	local data = data_list[data_index]
	cell_item:SetData(data, data_index)
end

function DailyGiftView:OnClickClose()
	self:Close()
end

function DailyGiftView:InitView()
	local active_flag = KaifuActivityData.Instance:GetActiveFlag()
	UI:SetButtonEnabled(self.node_list["BtnChongZhi"], not active_flag)
end

function DailyGiftView:OnFlush()
	local other_cfg = KaifuActivityData.Instance:GetDailyGiftConfig()
	if next(other_cfg) ~= nil then
		local recharge_gold = other_cfg.recharge_gold
		self.node_list["RechargeGold"].text.text = recharge_gold
	end
	self:InitView()
	self.list.scroller:RefreshAndReloadActiveCellViews(false)


	-- 刷新倒计时
	
	-- local activity_end_time = FestivalActivityData.Instance:GetActivityActTimeLeftById(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EVERYDAY_NICE_GIFT)
 --    if self.count_down then
 --        CountDown.Instance:RemoveCountDown(self.count_down)
 --        self.count_down = nil
 --    end

 --    self.count_down = CountDown.Instance:AddCountDown(activity_end_time, 1, function ()
 --        activity_end_time = activity_end_time - 1
 --        self.count_down_time.text.text = string.format(Language.Common.TimesDay, TimeUtil.FormatBySituation(activity_end_time))
 --    end)
end

function DailyGiftView:OnClickChongZhi()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function DailyGiftView:SetTime(rest_time)
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
	local str = ""
	if temp.day > 0 then
		str = string.format(Language.OutLine.ActivityTime3, temp.day, temp.hour)
	else
		str = string.format(Language.OutLine.ActivityTime4, temp.hour, temp.min,temp.s)
	end
	RichTextUtil.ParseRichText(self.node_list["Time"].rich_text, str, 22)
end

--------------------DailyGiftItem--------------------------------------
DailyGiftItem = DailyGiftItem or BaseClass(BaseCell)

function DailyGiftItem:__init(instance)
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["Item"], false)
	self.node_list["BtnGet"].button:AddClickListener(BindTool.Bind(self.OnClickFetch, self))
end

function DailyGiftItem:__delete()
	self.item_cell:DeleteMe()
end

function DailyGiftItem:SetData(data,index)
	if data == nil then return end
	self.node_list["Text"].text.text = string.format(Language.Common.TimesDay, CommonDataManager.DAXIE[index+1])
	-- self.node_list["Text"].text.text = CommonDataManager.DAXIE[index+1]

	local active = KaifuActivityData.Instance:GetActiveFlag() 
	local flag = KaifuActivityData.Instance:GetCanFetchRewardFlag(index) or false
	local has_fetch = KaifuActivityData.Instance:GetHaveFetchRewardFlag(index) or false
	self.node_list["Red"]:SetActive(flag and has_fetch == false)
	-- self.node_list["BtnGet"]:SetActive(flag and has_fetch == false)
	self.node_list["HasGot"]:SetActive(has_fetch)
	UI:SetButtonEnabled(self.node_list["BtnGet"], flag)
	-- UI:SetButtonEnabled(self.node_list["BtnGet"], flag and has_fetch == false)
	self.node_list["BtnGet"]:SetActive(not has_fetch)
	
	self.item_cell:SetData(data)
end

function DailyGiftItem:OnFlush()

end

function DailyGiftItem:OnClickFetch()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EVERYDAY_NICE_GIFT, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH,self.index - 1)
end
