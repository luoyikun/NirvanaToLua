DanBiChongZhiThree = DanBiChongZhiThree or BaseClass(BaseRender)
--单笔充值
function DanBiChongZhiThree:__init()
	self.contain_cell_list = {}
	self.reward_list = {}
end

function DanBiChongZhiThree:__delete()
	if self.contain_cell_list then
		for k,v in pairs(self.contain_cell_list) do
			v:DeleteMe()
		end
		self.contain_cell_list = nil
	end
end

function DanBiChongZhiThree:OpenCallBack()
	local list_delegate = self.node_list["ScrollerListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBICHONGZHITHREE)
	-- local opengameday = TimeCtrl.Instance:GetCurOpenServerDay()
	self.reward_list = CrazyHappyData.Instance:GetSingleChargeInfoThree(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBICHONGZHITHREE)

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
			self:SetTime(rest_time)
	end)
end

function DanBiChongZhiThree:CloseCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

function DanBiChongZhiThree:ClickReChange()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function DanBiChongZhiThree:GetNumberOfCells()
	return #self.reward_list
end

function DanBiChongZhiThree:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	
	if contain_cell == nil then
		contain_cell = DanBiChongZhiThreeCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1
	contain_cell:SetData(self.reward_list[cell_index])
	contain_cell:SetChargeValue(self.reward_list[cell_index].charge_value)
	contain_cell:Flush()
end

function DanBiChongZhiThree:SetTime(rest_time)
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

function DanBiChongZhiThree:OnFlush()
	self.reward_list = CrazyHappyData.Instance:GetSingleChargeInfoThree(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBICHONGZHITHREE)
	if self.node_list then
		self.node_list["ScrollerListView"].scroller:ReloadData(0)
	end
end

------------------------------DanBiChongZhiThreeCell-------------------------------------
DanBiChongZhiThreeCell = DanBiChongZhiThreeCell or BaseClass(BaseCell)

local MAX_CELL_NUM = 4

function DanBiChongZhiThreeCell:__init()
	self.charge_value = 0
	self.item_cell_list = {}
	for i = 1, MAX_CELL_NUM do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.node_list["CellItem_" .. i])
	end

	self.node_list["BtnReCharge"].button:AddClickListener(BindTool.Bind(self.OnClickGet, self))
end

function DanBiChongZhiThreeCell:__delete()
	if self.item_cell_list then
		for k,v in pairs(self.item_cell_list) do
			v:DeleteMe()
		end
		self.item_cell_list = nil
	end
end

function DanBiChongZhiThreeCell:SetChargeValue(value)
	self.charge_value = value
end

function DanBiChongZhiThreeCell:OnFlush()
	self.data = self:GetData()

	if next(self.data) then
		local reward_item = self.data.reward_item or {}
		local reward_list = ItemData.Instance:GetItemConfig(reward_item.item_id)

		if nil == reward_list.item_1_id then
			self.item_cell_list[1]:SetData({item_id = reward_list.id , num = 1, is_bind = 1})
			self.node_list["CellItem_" .. 1]:SetActive(true)
			for i = 2, MAX_CELL_NUM do
				self.node_list["CellItem_" .. i]:SetActive(false)
			end
		else
			local reward_item_list = {}
			for i = 1, MAX_CELL_NUM do
				self.node_list["CellItem_" .. i]:SetActive(true)
				reward_item_list[i] = {
				item_id = reward_list["item_"..i.."_id"],
				num = reward_list["item_"..i.."_num"],
				is_bind = reward_list["is_bind_"..i],}
				self.item_cell_list[i]:SetData(reward_item_list[i])
			end
		end
	end
	
	local str = string.format(Language.OutLine.DanBiChongZhiTips, self.charge_value)
	self.node_list["TxtTipsChongZhiNum"].text.text = self.charge_value
	-- RichTextUtil.ParseRichText(self.node_list["TxtTipsChongZhiNum"].rich_text, str, 20)
	-- self.node_list["TxtTipsLoginCenGet"].text.text = Language.Activity.DanBiChongZhiTips2
	if self.data.fetch_reward_flag == 1 then
		self.node_list["BtnText"].text.text = Language.Activity.FlagAlreadyReceive
	else
		self.node_list["BtnText"].text.text = Language.Common.Recharge
	end
	UI:SetButtonEnabled(self.node_list["BtnReCharge"], self.data.fetch_reward_flag == 0)
	local text_num = self.data.fetch_reward_flag == 0 and 1 or 0
	self.node_list["TxtDesc"].text.text = string.format(Language.Activity.TextDesc, text_num)
end

function DanBiChongZhiThreeCell:OnClickGet()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end