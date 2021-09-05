RechargeCapacityView = RechargeCapacityView or BaseClass(BaseView)

function RechargeCapacityView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_1"},
		{"uis/views/randomact/speedupcapacity_prefab", "RechargeCapacity"},
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_2"},
	}
	self.play_audio = true
	self.cell_list = {}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function RechargeCapacityView:__delete()

end

function RechargeCapacityView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Name"].text.text = Language.RechargeCapacity.ActName
	self:InitScroller()
end

function RechargeCapacityView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

end

function RechargeCapacityView:InitScroller()
	local delegate = self.node_list["ListView"].list_simple_delegate
	-- 生成数量
	self.data = RechargeCapacityData.Instance:GetRechargeCapacityCfg()
	delegate.NumberOfCellsDel = function()
		return #self.data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] =  RechargeCapacityCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
		end
		target_cell:SetData(self.data[data_index])
	end
end

function RechargeCapacityView:OpenCallBack()
	RemindManager.Instance:SetRemindToday(RemindName.RechargeCapacity)
	self:Flush()
end

function RechargeCapacityView:ShowIndexCallBack(index)

end

function RechargeCapacityView:CloseCallBack()

end

function RechargeCapacityView:OnFlush(param_t)
	if self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
end

function RechargeCapacityView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RECHARGE_CAPACITY)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	local time_tab = TimeUtil.Format2TableDHMS(time)
	if time_tab.day > 0 then
		local str = string.format(Language.IncreaseCapablity.ResTime, time_tab.day, time_tab.hour)--, time_tab.min, time_tab.s)
		self.node_list["TxtTime"].text.text = string.format(Language.RechargeCapacity.ActTime, str) --ToColorStr(str, TEXT_COLOR.GREEN_4)
	else
		local str = TimeUtil.FormatSecond2HMS(time)
		self.node_list["TxtTime"].text.text = string.format(Language.RechargeCapacity.ActTime, str)
	end
end

---------------------------------------------------------------
--滚动条格子

RechargeCapacityCell = RechargeCapacityCell or BaseClass(BaseCell)

function RechargeCapacityCell:__init()
	self.node_list["BtnStart"].button:AddClickListener(BindTool.Bind(self.ClickRechange, self))

	self.reward_list = {}
	for i = 1, 5 do
		self.reward_list[i] = ItemCell.New()
		self.reward_list[i]:SetInstanceParent(self.node_list["ItemList"])
		self.reward_list[i]:IgnoreArrow(true)
	end

end

function RechargeCapacityCell:__delete()
	for k,v in pairs(self.reward_list) do
		v:DeleteMe()
	end
	self.reward_list = {}
end

function RechargeCapacityCell:OnFlush()
	if nil == self.data then return end

	local item_list = ItemData.Instance:GetGiftItemList(self.data.reward_item.item_id)
	for k,v in pairs(self.reward_list) do
		if item_list[k] then
			v:SetData(item_list[k])
		end
		v.root_node:SetActive(item_list[k] ~= nil)
	end
	--self.node_list["TxtTopUp"].text.text = string.format(Language.RechargeCapacity.NeedGold, self.data.charge_value)
	self.node_list["TxtTopUp"].text.text = ToColorStr(self.data.charge_value,"#00ff30")
end

function RechargeCapacityCell:ClickRechange()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end