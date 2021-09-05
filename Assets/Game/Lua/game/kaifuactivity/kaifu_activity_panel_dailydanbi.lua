OpenActDailyDanBi =  OpenActDailyDanBi or BaseClass(BaseRender)

function OpenActDailyDanBi:__init()
	self.contain_cell_list = {}
end

function OpenActDailyDanBi:__delete()
	self.contain_cell_list = nil
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

function OpenActDailyDanBi:OpenCallBack()
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)


	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
	local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DANBI_CHONGZHI)
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
			self:SetTime(rest_time)
	end)
	self.node_list["Button"].button:AddClickListener(BindTool.Bind(self.ClickQianWangChongZhi, self))
	self.reward_list = KaifuActivityData.Instance:GetOpenActDailyDanBiReward()
end

function OpenActDailyDanBi:CloseCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

function OpenActDailyDanBi:ClickQianWangChongZhi()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function OpenActDailyDanBi:OnFlush()
	self.reward_list = KaifuActivityData.Instance:GetOpenActDailyDanBiReward()
	if self.node_list["ListView"] then
		self.node_list["ListView"].scroller:ReloadData(0)
	end
	local info = KaifuActivityData.Instance:GetDailyDanBiInfo()
end

function OpenActDailyDanBi:FlushTotalConsume()
	self:Flush()
end

function OpenActDailyDanBi:SetTime(rest_time)
	-- local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	-- local temp = {}
	-- for k,v in pairs(time_tab) do
	-- 	if k ~= "day" and k ~= "hour" then
	-- 		if v < 10 then
	-- 			v = tostring('0'..v)
	-- 		end
	-- 	end
	-- 	temp[k] = v
	-- end
	-- local str
	-- if temp.day > 0 then
	-- 	str = string.format(Language.OutLine.ActivityTime1, temp.day, temp.hour)
	-- else
	-- 	str = string.format(Language.OutLine.ActivityTime2, temp.hour, temp.min,temp.s)
	-- end
	-- 	RichTextUtil.ParseRichText(self.node_list["TimeText"].rich_text, str)
	-- self.node_list["TimeText"].text.text = str
	local time_tab = TimeUtil.FormatSecond(rest_time, 10)
	self.node_list["TimeText"].text.text = time_tab
end

function OpenActDailyDanBi:GetNumberOfCells()
	return #self.reward_list
end

function OpenActDailyDanBi:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = OpenActDailyDanBiCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1
	contain_cell:SetData(self.reward_list[cell_index])
	contain_cell:Flush()
end

----------------------------OpenActDailyTotalConsumeCell---------------------------------
OpenActDailyDanBiCell = OpenActDailyDanBiCell or BaseClass(BaseCell)

function OpenActDailyDanBiCell:__init()
	self.data = {}
	self.item_cell_obj_list = {}
	self.item_cell_list = {}
	self.node_list["Button01"].button:AddClickListener(BindTool.Bind(self.OnClickGet, self))
	for i = 1, 4 do
		self.item_cell_obj_list[i] = self.node_list["item_"..i]
		local item_cell = ItemCell.New()
		self.item_cell_list[i] = item_cell
		item_cell:SetInstanceParent(self.item_cell_obj_list[i])
	end
end

function OpenActDailyDanBiCell:__delete()
	self.item_cell_obj_list = {}
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function OpenActDailyDanBiCell:SetData(data)
	self.data = data
end

function OpenActDailyDanBiCell:OnFlush()
	local info = KaifuActivityData.Instance:GetDailyDanBiInfo()
	local str = string.format(Language.Activity.DanBiChongZhiTips, self.data.need_chongzhi_num)
	RichTextUtil.ParseRichText(self.node_list["Text"].rich_text, str)
	-- self.node_list["Text"].text.text = string.format(Language.Activity.DanBiChongZhiTips, self.data.need_chongzhi_num)
	local reward_list = ServerActivityData.Instance:GetCurrentRandActivityRewardCfg(self.data.reward_item, true)

	for i = 1, 4 do
		if reward_list ~= nil and reward_list[i] ~= nil then
			self.item_cell_list[i]:SetData(reward_list[i])
			self.item_cell_obj_list[i]:SetActive(true)
		else
			self.item_cell_obj_list[i]:SetActive(false)
		end
	end

	local fetch_reward_flag = self.data.fetch_reward_flag == 1
	local str = 1 == self.data.can_fetch_reward_flag and Language.Common.LingQu or Language.Common.WEIDACHENG
	self.node_list["Text2"].text.text = str
	UI:SetButtonEnabled(self.node_list["Button01"], not fetch_reward_flag and 1 == self.data.can_fetch_reward_flag)
	self.node_list["effect"]:SetActive(not fetch_reward_flag and 1 == self.data.can_fetch_reward_flag)
	self.node_list["HasGet"]:SetActive(fetch_reward_flag)
	self.node_list["Button01"]:SetActive(not fetch_reward_flag)
end

function OpenActDailyDanBiCell:OnClickGet()
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_DAY_DANBI_CHONGZHI, RA_SINGLE_CHONGZHI_OPERA_TYPE.RA_SINGLE_CHONGZHI_OPERA_TYPE_FETCH_REWARD, self.data.seq)
end

