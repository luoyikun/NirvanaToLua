VipContentView = VipContentView or BaseClass(BaseRender)

function VipContentView:__init(instance)
	self.max_vip_level = VipData.Instance:GetVipMaxLevel()
	self.vip_list = {}
	self.vip_desc_list = {}
	self:InitListView()

	self.node_list["reward_btn"].button:AddClickListener(BindTool.Bind(self.RewardClick, self))
	self.node_list["week_gift_btn"].button:AddClickListener(BindTool.Bind(self.WeekRewardClick, self))

	self.item_list = {}
	for i = 1, 8 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["item_" .. i])
	end

	self.item_week_gift = ItemCell.New()
	self.item_week_gift:SetInstanceParent(self.node_list["item_9"])

	self.current_vip_id = VipData.Instance:GetVipInfo().vip_level

	self.cur_index = self.current_vip_id
	self.last_select_cell = nil

	self.is_create_done = false
end

function VipContentView:OnPreClick()
	VipView.Instance:OpenTeToggle()
end

function VipContentView:SetCurIndex(index)
	self.cur_index = index
end

function VipContentView:GetCurIndex()
	return self.cur_index
end

function VipContentView:__delete()
	if self.dis_modle ~= nil then
		self.dis_modle:DeleteMe()
		self.dis_modle = nil
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.time_quest1 then
		GlobalTimerQuest:CancelQuest(self.time_quest1)
		self.time_quest1 = nil
	end

	if self.vip_list then
		for k,v in pairs(self.vip_list) do
			v:DeleteMe()
		end
	end
	self.vip_list = {}

	if self.item_week_gift then
		self.item_week_gift:DeleteMe()
		self.item_week_gift = nil
	end

	for _,v in pairs(self.item_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.item_list = {}
	self.max_vip_level = 0
	self.is_create_done = false
end

function VipContentView:SetVipRewardItemData(reward_vip_id)
	self.node_list["TxtBgTitle"].text.text = reward_vip_id
	self:SetRewardDes(reward_vip_id)

	local vip_reward_cfg = VipData.Instance:GetVipRewardCfg()
	local reward_list = VipData.Instance:GetRewardList(self.current_vip_id)
	local effect_cfg = Split(VipData.Instance:GetGiftEffectCfgById(reward_vip_id), ",")

	for i = 1, 6 do
		--礼物特效配置
		for k, v in pairs(effect_cfg) do	
			if k == i and v == "1" then
				local item_cfg = ItemData.Instance:GetItemConfig(reward_list[i].item_id)
				if item_cfg and item_cfg.color == 4 then
					self.item_list[i]:SetShowOrangeEffect(true)
				else
					self.item_list[i]:SetShowOrangeEffect(false)
				end
			end
		end
		self.item_list[i]:SetData({item_id = reward_list[i].item_id, num = reward_list[i].item_num})
	end
end

function VipContentView:SetVipWeekRewarditem(reward_vip_id)
	local vip_reward_cfg = VipData.Instance:GetVipRewardCfg()
	local week_gift_cfg = VipData.Instance:GetVipWeekGiftCfg()
	local week_gift_item_id = week_gift_cfg.week_reward_id
	local week_gift_num = vip_reward_cfg[reward_vip_id-1].week_reward_num
	local vip_week_gift_fetch_flag = VipData.Instance:GetVipInfo().vip_week_gift_resdiue_times
	local get_gift_num = week_gift_num - vip_week_gift_fetch_flag

	if self.current_vip_id == 0 then
		get_gift_num = 0
		self.node_list["Txt"].text.text = get_gift_num
	else
		local reward_num = VipData.Instance:GetVipWeekRewardNum()
		local vip_level = VipData.Instance:GetVipInfo().vip_level
		if reward_num == 0 then
			self.node_list["Txt"].text.text = string.format("<color=#ff0000>%s</color>/%s", reward_num, vip_level)
		else
			self.node_list["Txt"].text.text = string.format("%s/%s", reward_num, vip_level)
		end
	end

	self.item_week_gift:SetData({item_id = week_gift_item_id, num = get_gift_num})

	if VipData.Instance:GetVipWeekRewardFetchFlag() then
		UI:SetButtonEnabled(self.node_list["week_gift_btn"], true)
	else
		UI:SetButtonEnabled(self.node_list["week_gift_btn"], false)
	end
end

function VipContentView:OpenCallBack()
	local reward_vip_id = self.current_vip_id
	if reward_vip_id == 0 then
		reward_vip_id = 1
	end
	self:SetVipWeekRewarditem(reward_vip_id)

	self.node_list["TxtButton03"].text.text = Language.Common.LingQuJiangLi

	if self.node_list["list_view"].scroller and self.node_list["list_view"].scroller.isActiveAndEnabled then
		self.node_list["list_view"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function VipContentView:JumpToCurrentVip()
	self.current_vip_id = VipData.Instance:GetFirstCanFetchGiftVip() or VipData.Instance:GetVipInfo().vip_level
	if self.current_vip_id ~= 0 then
		self:BagJumpPage(self.current_vip_id - 1)
	else
		self:BagJumpPage(0)
	end

	self:OnFlushAllVipItem()
end

--跳转到下一个可以领取奖励的vip等级
function VipContentView:JumpToCanGetGiftVip(vip_level)
	local vip_page = VipData.Instance:GetFirstCanFetchGiftVip(vip_level)
	if nil == vip_page then
		return
	end
	self:OnFlushAllVipItem()
	self:BagJumpPage(vip_page - 1)

	if self.time_quest1 then
		GlobalTimerQuest:CancelQuest(self.time_quest1)
		self.time_quest1 = nil
	end
	
	self.time_quest1 = GlobalTimerQuest:AddRunQuest(function()
		self:OnFlushVipItem(vip_page)
		GlobalTimerQuest:CancelQuest(self.time_quest1)
		self.time_quest1 = nil
	end, 0.1)
end

function VipContentView:FlushRewardState()
	local reward_vip_id = self.current_vip_id
	if reward_vip_id == nil or reward_vip_id == 0 then
		reward_vip_id = 1
	end
	self:SetVipRewardItemData(reward_vip_id)

	local is_reward = VipData.Instance:GetVipRewardFlag(reward_vip_id)
	if is_reward then
		UI:SetButtonEnabled(self.node_list["reward_btn"], false)
		UI:SetGraphicGrey(self.node_list["TxtRewardBtn"], true)
		self.node_list["TxtRewardBtn"].text.text = Language.Common.YiLingQu
	else
		UI:SetButtonEnabled(self.node_list["reward_btn"], true)
		UI:SetGraphicGrey(self.node_list["TxtRewardBtn"], false)
		self.node_list["TxtRewardBtn"].text.text = Language.Common.LingQuJiangLi
	end

	-- self.node_list["ImgRedPointToggle4"]:SetActive(not is_reward)
	RemindManager.Instance:Fire(RemindName.ChargeGroup)
	local reward_vip_id = self.current_vip_id
	if reward_vip_id == 0 then
		reward_vip_id = 1
	end
	self:SetVipWeekRewarditem(reward_vip_id)
	self:OnFlushAllVipItem()
end

function VipContentView:InitListView()
	local list_delegate = self.node_list["list_view"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function VipContentView:GetNumberOfCells()
	local num = VipData.Instance:GetShowVipData()
	return num
end

function VipContentView:GetListView()
	return self.node_list["list_view"]
end

function VipContentView:RefreshCell(cell, cell_index)
	local vip_cell = self.vip_list[cell]
	if vip_cell == nil then
		vip_cell = VipItem.New(cell.gameObject, self)
		self.vip_list[cell] = vip_cell
		vip_cell:SetToggleGroup(self.node_list["list_view"].toggle_group)
	end
	vip_cell:SetToggleActive(false)
	cell_index = cell_index + 1
	vip_cell:SetVipLevel(cell_index)
	vip_cell:SetIndex(cell_index)

	self.is_create_done = true
end

function VipContentView:RechargeClick()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
	VipCtrl.Instance:GetView():OnCloseBtnClick()
end

function VipContentView:BagJumpPage(page)
	local jump_index = page
	local scrollerOffset = 0
	local cellOffset = 0
	local useSpacing = false
	local scrollerTweenType = self.node_list["list_view"].scroller.snapTweenType
	local scrollerTweenTime = 0.1
	local scroll_complete = nil

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		if self.is_create_done and self.node_list["list_view"].scroller.isActiveAndEnabled then
			self.node_list["list_view"].scroller:JumpToDataIndex(jump_index)
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end, 0.2)
end

function VipContentView:RewardClick()
	if self.current_vip_id > 0 then
		VipCtrl.Instance:SendFetchVipLevelRewardReq(self.current_vip_id)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.VipLimitTips)
	end
	if VipData.Instance:GetVipInfo().vip_level >= self.current_vip_id then
		self:JumpToCanGetGiftVip(self.current_vip_id)
	end
end

function VipContentView:WeekRewardClick()
	local vip_week_gift_fetch_flag = VipData.Instance:GetVipInfo().vip_week_gift_resdiue_times
	VipCtrl.Instance:SendFetchVipWeekRewardReq()

	UI:SetButtonEnabled(self.node_list["week_gift_btn"], false)

	self.node_list["TxtButton03"].text.text = Language.Common.YiLingQu
	self.item_week_gift:SetNum(0)
end

function VipContentView:GetCurrentVipId()
	return self.current_vip_id
end

function VipContentView:SetCurrentVipId(current_vip_id)
	self.current_vip_id = current_vip_id
end

function VipContentView:OnFlushAllVipItem()
	for k,v in pairs(self.vip_list) do
		v:Flush()
	end
end

--刷新指定vip格子
function VipContentView:OnFlushVipItem(vip)
	self:SetCurrentVipId(vip)
	for k, v in pairs(self.vip_list) do
		v:OnFlushFistGiftVipCell(vip)
	end
end

function VipContentView:SetRewardText()
	self.node_list["TxtBgTitle"].text.text = self.current_vip_id
end

function VipContentView:SetRewardDes(index)
	local vip_des = VipData.Instance:GetVipCurDescList(index)
	if vip_des then
		for i = 1, self.max_vip_level do
			self.node_list["TxtVipDes" .. i].text.text = vip_des["desc" .. i]
			if nil == vip_des["desc" ..i] or vip_des["desc" ..i] == "" then
				self.node_list["ImgVipDes" .. i]:SetActive(false)
				self.node_list["TxtVipDes" .. i]:SetActive(false)
			else
				self.node_list["ImgVipDes" .. i]:SetActive(true)
				self.node_list["TxtVipDes" .. i]:SetActive(true)
			end
		end
	end

	self.node_list["TxtVIPText"].text.text = index
end

function VipContentView:SetVipActive(is_active)
	self.root_node:SetActive(is_active)
end

function VipContentView:FlushSelectEffect(cell)
	if self.last_select_cell and self.last_select_cell ~= cell then
		self.last_select_cell:SetHighLight(false)
	end
	self.last_select_cell = cell
	if cell then
		cell:SetHighLight(true)
	end
end

----------------------------------------------------------------------------
VipItem = VipItem or BaseClass(BaseCell)

function VipItem:__init(instance, parent_view)
	self.parent_view = parent_view
	self.vip_level = 0
	self.root_node.toggle:AddValueChangedListener(BindTool.Bind(self.OnValueChange,self))
	self.node_list["ToggleNode"].toggle:AddClickListener(BindTool.Bind(self.OnVipClick, self))
end

function VipItem:SetVipLevel(vip_level)
	self.vip_level = vip_level
	self:OnFlush()
end

function VipItem:OnVipClick()
	if self.index == self.parent_view:GetCurIndex() then
		return
	end

	self.parent_view:SetCurIndex(self.index)
	self.parent_view:SetCurrentVipId(self.vip_level)
	self.parent_view:SetRewardText()
	self.parent_view:FlushRewardState()
	self.parent_view:FlushSelectEffect(self)
	self.root_node.toggle.isOn = true
end

function VipItem:SetRedPoint(is_show)
	self.node_list["ImgRedPoint"]:SetActive(is_show)
end

function VipItem:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function VipItem:OnFlush()
	self:SetVipItemData()
	local current_vip_id = self.parent_view:GetCurrentVipId()
	if current_vip_id == 0 then
		current_vip_id = 1
	end

	if current_vip_id == self.vip_level  then
		self.root_node.toggle.isOn = true
	else
		self.root_node.toggle.isOn = false
	end
	local reward_flag = VipData.Instance:GetVipRewardFlag(self.vip_level)
	if VipData.Instance:GetVipInfo().vip_level >= self.vip_level then
		self:SetRedPoint(not reward_flag)
	else
		self:SetRedPoint(false)
	end
end

function VipItem:OnFlushFistGiftVipCell(vip)
	self:SetVipItemData()
	if vip == 0 then
		vip = 1
	end

	if vip == self.vip_level  then
		self.root_node.toggle.isOn = true
	else
		self.root_node.toggle.isOn = false
	end
	local reward_flag = VipData.Instance:GetVipRewardFlag(self.vip_level)
	if VipData.Instance:GetVipInfo().vip_level >= self.vip_level then
		self:SetRedPoint(not reward_flag)
	else
		self:SetRedPoint(false)
	end

	self.parent_view:SetRewardText()
	self.parent_view:FlushRewardState()
end

function VipItem:SetVipItemData()
	local bundle, asset = ResPath.GetVipIcon("tips_vipbg")
	self.node_list["bg"].image:LoadSprite(bundle, asset .. ".png")

	self.node_list["TxtVip"].text.text = self.vip_level

	local vip_item = VipData.Instance:GetVipInfoList(self.vip_level)
	local vip_cfg = ItemData.Instance:GetItemConfig(vip_item.reward_item.item_id)
	if vip_item and vip_cfg then
		self.node_list["TxtLiBaoName"].text.text = vip_cfg.name
	end

	-- vip_item.icon_id
	local bundle2, asset2
	if nil == vip_item.icon_id then
		bundle2, asset2 = ResPath.GetVipIcon("vip_reward_" .. self.vip_level)
	else
		bundle2, asset2 = ResPath.GetVipItemIcon("big_item_" .. vip_item.icon_id)
	end

	self.node_list["ImgLiBaoIcon"].image:LoadSprite(bundle2, asset2 .. ".png")

	if self.parent_view:GetCurrentVipId() == self.vip_level then
		self.parent_view:FlushSelectEffect(self)
	else
		self:SetHighLight(false)
	end
end

function VipItem:OnValueChange(is_click)
	if is_click then
		if self.root_node.toggle.isOn == true then
			VipItem.Instance = self
		end
	end
end

function VipItem:SetToggleActive(is_on)
	self.root_node.toggle.isOn = is_on
end

function VipItem:SetHighLight(enabled)
	self.node_list["hl"]:SetActive(enabled)
end