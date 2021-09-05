LimitedFeedbackView = LimitedFeedbackView or BaseClass(BaseView)

local CHONGZHI_COUNT = {60,500,1500}

function LimitedFeedbackView:__init()
	self.ui_config = {
		{"uis/views/limitedfeedback_prefab", "LimitedFeedbackPanel_1"},
		{"uis/views/limitedfeedback_prefab", "LimitedFeedbackView"},
		{"uis/views/limitedfeedback_prefab", "LimitedFeedbackPanel_2"},
	}
	self.play_audio = true
	self.list_view_group = {}
	self.is_modal = true
end

function LimitedFeedbackView:__delete()

end

function LimitedFeedbackView:ReleaseCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	for k,v in pairs(self.list_view_group) do
		v:DeleteMe()
	end
	self.list_view_group = {}

end

function LimitedFeedbackView:LoadCallBack()
	LimitedFeedbackData.Instance:GetLimitCfgByChongzhi()
	self.node_list["TxtTitle"].text.text = Language.Title.XianShi
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self:InitListView()
	self.node_list["BtnPlus"].button:AddClickListener(BindTool.Bind(self.ClickAddMoney, self))
end

function LimitedFeedbackView:ClickAddMoney()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function LimitedFeedbackView:OpenCallBack()
	self:Flush()
end

function LimitedFeedbackView:InitListView()
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = function ()
		return LimitedFeedbackData.Instance:GetLimitDataGroupCount()
	end

	list_delegate.CellRefreshDel = function (cellobj,index)
		local cell = self.list_view_group[cellobj]
		if cell == nil then
			cell = FeedbackListGroup.New(cellobj.gameObject)
			self.list_view_group[cellobj] = cell
		end
		cell:SetIndex(index+1)
		cell:SetData(LimitedFeedbackData.Instance:GetLimitDataItemByChongzhi(LimitedFeedbackData.Instance:GetChongZhiCount()[index+1]))
		cell:SetGroupCallBack(BindTool.Bind(self.OnFeedbackDayItemClick,self))
	end

end

function LimitedFeedbackView:OnFlush()
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
	local money = LimitedFeedbackData.Instance:GetCurDayChongZhi()
	self.node_list["ChongZhiInfoText"].text.text =  money
	self.node_list["ListView"].scroller:RefreshActiveCellViews()
end

function LimitedFeedbackView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LIMITTIME_REBATE)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	local time_type = 1
	if time > 3600 * 24 then
		time_type = 6
	elseif time > 3600 then
		time_type = 1
	else
		time_type = 2
	end

	self.node_list["Time"].text.text = TimeUtil.FormatSecond(time, time_type)
end

function LimitedFeedbackView:OnFeedbackDayItemClick(cell)
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LIMITTIME_REBATE,RA_LIMIT_TIME_REBATE_OPERA_TYPE.RA_LIMIT_TIME_REBATE_OPERA_TYPE_FETCH_REWARD,cell.data.seq,0)
	self:Flush()
end

-------------------------滚动Group父类格子-----------------------
FeedbackListGroup = FeedbackListGroup or BaseClass(BaseCell)

function FeedbackListGroup:__init()
	self.list_group_data = {}
	self.item_cell_count = 0
	local list_delegate = self.node_list["CellListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.cell_list = {}

end

function FeedbackListGroup:__delete()
	--清理对象和变量
	self.list_group_data = {}
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function FeedbackListGroup:SetData(data)
	self.list_group_data = data
	self:Flush()
end

function FeedbackListGroup:SetGroupCallBack(callback)
	if callback ~= nil then
		self.callback = callback
	end
end


function FeedbackListGroup:GetNumberOfCells()
	if #self.list_group_data <= self.item_cell_count then
		return
	end
	return #self.list_group_data
end

function FeedbackListGroup:RefreshCell(cell, cell_index)
	cell_index = cell_index + 1
	local feedbackday_cell = self.cell_list[cell]
	if feedbackday_cell == nil then
		feedbackday_cell = FeedbackDayItem.New(cell.gameObject)
		self.cell_list[cell] = feedbackday_cell
	end
	feedbackday_cell:SetIndex((self.index - 1) * #self.list_group_data + cell_index - 1)
	feedbackday_cell:SetData(self.list_group_data[cell_index])
	feedbackday_cell:SetItemCallBack(self.callback)
end

function FeedbackListGroup:OnFlush()
	if self.list_group_data and self.list_group_data[1] then
		self.node_list["TitleText"].text.text =  self.list_group_data[1].chongzhi_count
		for k,v in ipairs(self.cell_list) do
			v:SetIndex((self.index - 1) * #self.list_group_data + k - 1)
			v:SetData(self.list_group_data[k])
			v:SetItemCallBack(self.callback)
		end
	end
	self.node_list["CellListView"].scroller:RefreshActiveCellViews()
end

----------------------限时反馈天数格子-------------------------
FeedbackDayItem = FeedbackDayItem or BaseClass(BaseCell)

function FeedbackDayItem:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.item_cell:ShowHighLight(false)
end

function FeedbackDayItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
	end

end

function FeedbackDayItem:SetItemCallBack(callback)
	if callback ~= nil then
		self.callback = callback
	end
end

function FeedbackDayItem:OnFlush()
	self.node_list["Day_Text"].text.text =  self.data.chongzhi_day
	self.item_cell:SetData(self.data.reward)

	local cur_day_chongzhi = LimitedFeedbackData.Instance:GetCurDayChongzhiByDay(self.data.chongzhi_count,self.data.chongzhi_day)
	local chongzhi_day = LimitedFeedbackData.Instance:GetChongZhiDay(self.data.chongzhi_count)
	local flag = LimitedFeedbackData.Instance:GetRewardFlagByIndex(self.index)

	if cur_day_chongzhi >= self.data.chongzhi_count and chongzhi_day >= self.data.chongzhi_day and flag ~= 1 then
		self.item_cell:ShowGetEffect(true)
		self.node_list["Effect"]:SetActive(true)
		self.item_cell:ListenClick(BindTool.Bind(self.OnClick,self))
	else
		self.item_cell:ShowGetEffect(false)
		self.item_cell:ListenClick(nil)
		self.node_list["Effect"]:SetActive(false)
	end

	self.node_list["Is_Get"]:SetActive(flag == 1)

end

function FeedbackDayItem:OnClick()
	if nil ~= self.callback then
		self.callback(self)
	end
end