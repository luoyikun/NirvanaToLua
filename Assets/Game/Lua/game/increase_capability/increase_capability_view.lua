IncreaseCapabilityView = IncreaseCapabilityView or BaseClass(BaseView)

function IncreaseCapabilityView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_1"},
		{"uis/views/increasecapability_prefab", "IncreaseCapability"},
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_2"},
	}
	self.contain_cell_list = {}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function IncreaseCapabilityView:__delete()
	-- body
end

function IncreaseCapabilityView:LoadCallBack()
	self.node_list["Name"].text.text = Language.IncreaseCapablity.PanelName
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.node_list["ListView"].list_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.node_list["ListView"].list_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.reward_list = IncreaseCapabilityData.Instance:GetRewardListDataByDay()
	self.coset_list =  IncreaseCapabilityData.Instance:GetCostListByDay()
end

-- 销毁前调用
function IncreaseCapabilityView:ReleaseCallBack()
	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}
end

function IncreaseCapabilityView:OpenCallBack()
	RemindManager.Instance:SetRemindToday(RemindName.IncreaseCapability)
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_GIFT)

	self:SetTime(time)
	self.least_time_timer = CountDown.Instance:AddCountDown(time, 1, function ()
			time = time - 1
			self:SetTime(time)
		end)
end

-- 关闭前调用
function IncreaseCapabilityView:CloseCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

function IncreaseCapabilityView:SetTime(time)
	local str = ""
	if time > 3600 * 24 then 
		str = string.format(Language.Activity.ActivityTime1, TimeUtil.FormatSecond(time, 6))
	elseif time > 3600 then 
		str = string.format(Language.Activity.ActivityTime1, TimeUtil.FormatSecond(time, 0))
	else
		str = string.format(Language.Activity.ActivityTime1, TimeUtil.FormatSecond(time, 0))
	end 
	self.node_list["Txt"].text.text = str
end

-- 刷新
function IncreaseCapabilityView:OnFlush(param_list)
	-- override
end

function IncreaseCapabilityView:GetNumberOfCells()
	return #self.reward_list
end

function IncreaseCapabilityView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = IncreaseCapabilityCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	contain_cell:SetItemData(self.reward_list[cell_index])
	contain_cell:SetCost(self.coset_list[cell_index])
	contain_cell:Flush()
end

function IncreaseCapabilityView:CloseView()
	self:Close()
end

----------------------------IncreaseCapabilityCell---------------------------------
IncreaseCapabilityCell = IncreaseCapabilityCell or BaseClass(BaseCell)

function IncreaseCapabilityCell:__init()
	self.reward_data = {}
	self.item_cell_obj = {}
	self.item_cell_list = {}
	for i = 1, 4 do
		self.item_cell_obj[i] = self.node_list["item_" .. i]
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.item_cell_obj[i])
	end
	
	self.node_list["Btn_2"].button:AddClickListener(BindTool.Bind(self.OnClickChongZhi, self))
end

function IncreaseCapabilityCell:__delete()
	self.item_cell_obj = nil

	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
end

function IncreaseCapabilityCell:SetItemData(data)
	if data then
		self.reward_data = data
	end
end

function IncreaseCapabilityCell:SetCost(num)
	self.cost_count = num
end

function IncreaseCapabilityCell:OnFlush()
	local str = string.format(Language.IncreaseCapablity.Tips, self.cost_count)
	self.node_list["Txt"].text.text = str
	local reward_list = ItemData.Instance:GetItemConfig(self.reward_data.item_id)
	local reward_item_list = {}
	for i = 1, 4 do
		reward_item_list[i] = {
		item_id = reward_list["item_"..i.."_id"],
		num = reward_list["item_"..i.."_num"],
		is_bind = reward_list["is_bind_"..i],}
		self.item_cell_list[i]:SetData(reward_item_list[i])
	end
end

function IncreaseCapabilityCell:OnClickChongZhi()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end
