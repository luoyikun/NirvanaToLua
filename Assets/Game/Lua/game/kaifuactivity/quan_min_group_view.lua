QuanMinGroupView = QuanMinGroupView or BaseClass(BaseRender)
-- 全民总动员

-- 最大
local MAX_NUM = 3


function QuanMinGroupView:__init()
	self.contain_cell_list = {}
	self.reward_list = {}
end

function QuanMinGroupView:__delete()
	if self.contain_cell_list then
		for k , v in pairs(self.contain_cell_list) do
			v:DeleteMe()
		end
	end
end

function QuanMinGroupView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(2201, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	local list_delegate = self.node_list["ScrollerListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QUAN_MIN_UPGRADE_GROUPE)

	self.reward_list = KaifuActivityData.Instance:GetKaifuActivityCfgByType(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QUAN_MIN_UPGRADE_GROUPE)

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
	self:Flush()
end

function QuanMinGroupView:CloseCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

function QuanMinGroupView:GetNumberOfCells()
	return #self.reward_list
end

function QuanMinGroupView:RefreshCell(cell, cell_index)
	
	local contain_cell = self.contain_cell_list[cell]
	
	if contain_cell == nil then
		contain_cell = QuanMinGroupCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1

	local type_list = KaifuActivityData.Instance:SortList(2201)
	local is_get_reward = KaifuActivityData.Instance:IsGetReward(type_list[cell_index].seq, 2201)
	local is_complete = KaifuActivityData.Instance:IsComplete(type_list[cell_index].seq, 2201)

	contain_cell:SetIndex(cell_index)
	contain_cell:SetData(type_list[cell_index], is_get_reward, is_complete)
	contain_cell:Flush()
end

function QuanMinGroupView:SetTime(rest_time)
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

function QuanMinGroupView:OnFlush()
	self.node_list["ScrollerListView"].scroller:RefreshActiveCellViews()
end

------------------------------QuanMinGroupCell-------------------------------------
QuanMinGroupCell = QuanMinGroupCell or BaseClass(BaseCell)

local MAX_CELL_NUM = 2

function QuanMinGroupCell:__init()

	self.charge_value = 0
	self.is_get_reward = false
	self.is_complete = false
	self.item_cell_list = {}
	for i = 1, MAX_CELL_NUM do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.node_list["CellItem_" .. i])
	end

	self.node_list["BtnGet"].button:AddClickListener(BindTool.Bind(self.OnClickGet, self))

end

function QuanMinGroupCell:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_obj_list = nil
end

function QuanMinGroupCell:SetChargeValue(value)
	self.charge_value = value
end

function QuanMinGroupCell:OnFlush()
	self.data = self:GetData()
	local type_num = self.data.cond1
	local grade_num = self.data.cond2
	local target_man_num = self.data.cond3

	local str = string.format(Language.Activity.QuanMinGroup[type_num], grade_num, target_man_num)
	RichTextUtil.ParseRichText(self.node_list["TxtTips"].rich_text, str, 22)
	local item_id = self.data.reward_item[0].item_id
	local reward_list = ItemData.Instance:GetGiftItemList(item_id)

	if next(reward_list) then
		for i = 1, MAX_CELL_NUM do
			self.item_cell_list[i]:SetData(reward_list)
		end
	else
		for i = 1, MAX_CELL_NUM do
			if self.data.reward_item[i - 1] then
				self.item_cell_list[i]:SetActive(true)
				self.item_cell_list[i]:SetData(self.data.reward_item[i - 1])
			else
				self.item_cell_list[i]:SetActive(false)
			end
		end
	end

	local count = KaifuActivityData.Instance:GetQuanMinGroupInfo().count_list[self.data.cond2 + 2] or 0
	local str1 = string.format(Language.Activity.ReachNumber,count)

	RichTextUtil.ParseRichText(self.node_list["TxtManNum"].rich_text, str1)
	self.node_list["TxtBtn"].text.text = Language.Activity.QuanMinLingQu

	if self.is_complete and self.is_get_reward then
		self.node_list["TxtBtn"].text.text = Language.Activity.QuanMinYiLingQu
	end

	self.node_list["NodeEffect"]:SetActive(self.is_complete and not self.is_get_reward)
	UI:SetButtonEnabled(self.node_list["BtnGet"], self.is_complete and not self.is_get_reward)

end

function QuanMinGroupCell:OnClickGet()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QUAN_MIN_UPGRADE_GROUPE, 1, self.data.seq)
end

function QuanMinGroupCell:SetData(data, is_get_reward, is_complete)
	self.data = data
	self.is_get_reward = is_get_reward
	self.is_complete = is_complete
end