KaifuActivityPanelTwo = KaifuActivityPanelTwo or BaseClass(BaseRender)
--集字活动 panel9
function KaifuActivityPanelTwo:__init(instance)
	self.list_delegate = self.node_list["ScrollerListView"].list_simple_delegate
	self.list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	
	self.cell_list = {}
	self:IntShowTime()
	-- ClickOnceRemindList[RemindName.JiZi] = 0
	-- RemindManager.Instance:CreateIntervalRemindTimer(RemindName.JiZi)
	self:Flush()
end

function KaifuActivityPanelTwo:__delete()
	self.temp_activity_type = nil
	self.activity_type = nil

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self:RealseTimer()
end

function KaifuActivityPanelTwo:GetNumberOfCells()
	return #PlayerData.Instance:GetCurrentRandActivityConfig().item_collection
end

function KaifuActivityPanelTwo:RefreshCell(cell, data_index)
	local cell_item = self.cell_list[cell]
	local cfg = PlayerData.Instance:GetCurrentRandActivityConfig().item_collection
	if cell_item == nil then
		cell_item = PanelListCellTwo.New(cell.gameObject, self)
		self.cell_list[cell] = cell_item
		cell_item:SetIndex(data_index)
	end

	cell_item:SetData(cfg[data_index + 1])
end

function KaifuActivityPanelTwo:Flush(activity_type)
	self.activity_type = activity_type or self.activity_type

	if activity_type == self.temp_activity_type then
		self.node_list["ScrollerListView"].scroller:RefreshActiveCellViews()
	else
		if self.node_list["ScrollerListView"].scroller.isActiveAndEnabled then
			self.node_list["ScrollerListView"].scroller:ReloadData(0)
		end
	end
	self.temp_activity_type = activity_type
end

function KaifuActivityPanelTwo:IntShowTime()
	local open_start, open_end = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION)
	local open_time = open_end - TimeCtrl.Instance:GetServerTime()
	if nil ~= open_time then
		self:SetRestTimeChu(open_time)
	end
end

function KaifuActivityPanelTwo:SetRestTimeChu(diff_time)
	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
			local time_tab = TimeUtil.Format2TableDHMS(left_time)
			local time_str = nil
			if time_tab.day >= 1 then
				time_str = string.format(Language.Activity.ActivityGatherText, time_tab.day, time_tab.hour)
			else
				time_str = string.format(Language.Activity.ActivityGatherText1, time_tab.hour, time_tab.min, time_tab.s)
			end
			self.node_list["TimeText"].text.text = time_str
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end

end

function KaifuActivityPanelTwo:RealseTimer()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end


PanelListCellTwo = PanelListCellTwo or BaseClass(BaseCell)

local MAX_CELL_NUM = 4


function PanelListCellTwo:__init(instance, parent)
	self.item_list = {}
	self.parent_view = parent

	for i = 1, MAX_CELL_NUM  do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["CellItem" .. i])
	end

	self.reward_item = ItemCell.New()
	self.reward_item:SetInstanceParent(self.node_list["CellRewardItem"])
	self.node_list["BtnExchange"].button:AddClickListener(BindTool.Bind(self.OnClickGet, self))
end

function PanelListCellTwo:__delete()
	if self.reward_item ~= nil then
		self.reward_item:DeleteMe()
		self.reward_item = nil
	end
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function PanelListCellTwo:OnClickGet()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH, self.data.seq or 0)
end

function PanelListCellTwo:OnFlush()
	if self.data == nil then return end
	local times_t = KaifuActivityData.Instance:GetCollectExchangeInfo()
	local times = times_t[self.data.seq + 1] or 0
	local count = math.max(self.data.exchange_times_limit  - times, 0)
	local color = count > 0 and "89f201" or "ff0000"
	local can_exchang_num_str = "<color=#" .. color .. ">" .. count .. "</color>"
	self.node_list["TxtExchangeCount"].text.text = can_exchang_num_str

	for i = 1, MAX_CELL_NUM - 1 do
		self.node_list["ImgPlus" .. i+1]:SetActive(true)
		self.node_list["NodeItemCell" .. i+1]:SetActive(true)
	end

	local is_destory_effect = true

	for k, v in pairs(self.data.item_special or {}) do
		if v.item_id == self.data.reward_item.item_id then
			self.reward_item:IsDestoryActivityEffect(false)
			self.reward_item:SetActivityEffect()
			is_destory_effect = false
			break
		end
	end

	if is_destory_effect then
		self.reward_item:IsDestoryActivityEffect(is_destory_effect)
		self.reward_item:SetActivityEffect()
	end

	self.reward_item:SetData(self.data.reward_item)

	local can_reward = count > 0
	local index = 1
	local text_str = ""

	for i = 1, MAX_CELL_NUM do
		if self.data["stuff_id" .. i] and self.data["stuff_id" .. i].item_id > 0 and self.item_list[index] then
			local num = ItemData.Instance:GetItemNumInBagById(self.data["stuff_id" .. i].item_id)
			if num < self.data["stuff_id" .. i].num then
				can_reward = false
			end
			self.item_list[index]:SetData({item_id = self.data["stuff_id" .. i].item_id})
			KaifuActivityData.Instance:OutLineRichText(num, self.data["stuff_id" .. i].num, self.node_list["TxtNum"..index])
			index = index + 1
		end
	end

	if index <= MAX_CELL_NUM then
		for i = index, MAX_CELL_NUM do
			if self.node_list["ImgPlus" .. i] and self.node_list["NodeItemCell" .. i] then
				self.node_list["ImgPlus" .. i]:SetActive(false)
				self.node_list["NodeItemCell" .. i]:SetActive(false)
			end
		end
	end

	UI:SetButtonEnabled(self.node_list["BtnExchange"], can_reward)
	self.node_list["EffectInButton"]:SetActive(can_reward)
end
