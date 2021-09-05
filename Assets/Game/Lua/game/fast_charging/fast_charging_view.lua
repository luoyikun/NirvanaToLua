FastChargingView = FastChargingView or BaseClass(BaseView)

function FastChargingView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_1"},
		{"uis/views/randomact/fastcharging_prefab", "FastChargingContent"},
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_2"},
	}
	-- self.play_audio = true

	self.cell_list = {}
	self.is_modal = true
end

function FastChargingView:__delete()

end

function FastChargingView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	-- self.node_list["ImgTitle"].image:LoadSprite("uis/views/randomact/fastcharging/images_atlas","biaozhanxianfeng_title.png")
	-- self.node_list["ImgTitle"].image:SetNativeSize()
	self.node_list["Name"].text.text = Language.Activity.DanBiDaFangSong
	self:InitScroller()
end

function FastChargingView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	self.scroller = nil
	self.act_time = nil
end

function FastChargingView:InitScroller()
	self.data = FastChargingData.Instance:GetFastChargingCfg() or {}
	self.node_list["ListView"].list_simple_delegate.NumberOfCellsDel = function()
		return #self.data
	end

	self.node_list["ListView"].list_simple_delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.cell_list[cell]
		if nil == target_cell then
			self.cell_list[cell] = FastChargingCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
		end
		target_cell:SetData(self.data[data_index])
	end
end

function FastChargingView:OpenCallBack()
	RemindManager.Instance:SetRemindToday(RemindName.SingleChange)
	self:Flush()
end

function FastChargingView:ShowIndexCallBack(index)

end

function FastChargingView:CloseCallBack()

end

function FastChargingView:OnFlush(param_t)
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
end

function FastChargingView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_2)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	local time_str
	if time > 3600 * 24 then
		self.node_list["TxtTime"].text.text = string.format(Language.Activity.ActivityTime1, TimeUtil.FormatSecond(time, 6))
	elseif time > 3600 then
		self.node_list["TxtTime"].text.text = string.format(Language.Activity.ActivityTime1, TimeUtil.FormatSecond(time, 6))
	else
		self.node_list["TxtTime"].text.text = string.format(Language.Activity.ActivityTime1, TimeUtil.FormatSecond(time, 6))
	end
end

---------------------------------------------------------------
--滚动条格子

FastChargingCell = FastChargingCell or BaseClass(BaseCell)

function FastChargingCell:__init()
	self.reward_list = {}
	for i = 1, 4 do
		self.reward_list[i] = ItemCell.New()
		self.reward_list[i]:SetInstanceParent(self.node_list["ItemList"])
	end
	self.node_list["BtnStart"].button:AddClickListener(BindTool.Bind(self.ClickRechange, self))
	
end

function FastChargingCell:__delete()
	for k,v in pairs(self.reward_list) do
		v:DeleteMe()
	end
	self.reward_list = {}
end

function FastChargingCell:OnFlush()
	if self.data == nil then
		return
	end
	local item_list = ItemData.Instance:GetGiftItemList(self.data.reward_item.item_id)
	for k,v in pairs(self.reward_list) do
		if item_list[k] then
			v:SetData(item_list[k])
		end
		v.root_node:SetActive(item_list[k] ~= nil)
	end
	self.node_list["TxtTopUp"].text.text = self.data.charge_value
end

function FastChargingCell:ClickRechange()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end