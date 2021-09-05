TipsUseLuckyItemView = TipsUseLuckyItemView or BaseClass(BaseView)
function TipsUseLuckyItemView:__init()
	self.ui_config = {{"uis/views/tips/useluckyitemtips_prefab", "UseLuckyItemTips"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	--要使用幸运符的个数
	self.use_item_num = 0
	self.last_item_num = 0
	self.lucky_item_data = nil
	self.is_modal = true
end

function TipsUseLuckyItemView:LoadCallBack()
	local item_cell = self.node_list["LuckyItemCell"]
	self.lucky_item_cell = ItemCellReward.New()
	self.lucky_item_cell:SetInstanceParent(item_cell)

	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.OnClickCloseWindows, self))
	self.node_list["Plus"].button:AddClickListener(BindTool.Bind(self.OnClickPlus, self))
	self.node_list["reduce"].button:AddClickListener(BindTool.Bind(self.OnClickDeduce, self))
	self.node_list["UseBtn"].button:AddClickListener(BindTool.Bind(self.OnClickUseBtn,self))

	self.node_list["UseLuckyItemNum"].text.text = 0
end

function TipsUseLuckyItemView:OpenCallBack()
	self.lucky_item_cell:SetData(self.lucky_item_data)
	ForgeData.Instance:SetLevelUpLuckyItemUseNum(0)
	self.use_item_num = 0
	self.node_list["UseLuckyItemNum"].text.text = 0
	
	--获取幸运符的信息
	local item_cfg = ItemData.Instance:GetItemConfig(self.lucky_item_data.item_id)
	local color = ITEM_COLOR[item_cfg.color]
	local name = ToColorStr(item_cfg.name, color)
	self.node_list["ItemName"].text.text = name

	local num = ItemData.Instance:GetItemNumInBagById(self.lucky_item_data.item_id)
	local last_str = string.format(Language.Forge.LuckyItemLastTips, num)
	self.last_item_num = num
	self.node_list["LastNum"].text.text = last_str

	local base_succeed_rate = self.lucky_item_data.add_succeed_rate
	self.succeed_rate_str = string.format(Language.Forge.LuckyItemDes, base_succeed_rate)
	self.node_list["UseTips"].text.text = self.succeed_rate_str
end

function TipsUseLuckyItemView:ReleaseCallBack()
	if self.lucky_item_data then
		self.lucky_item_data = nil
	end

	if self.view ~= nil then
		self.view:DeleteMe()
	end

	if self.lucky_item_cell then
		self.lucky_item_cell:DeleteMe()
		self.lucky_item_cell = nil
	end

end

function TipsUseLuckyItemView:SetData(item)
	self.lucky_item_data = item
end

function TipsUseLuckyItemView:OnClickUseBtn()
	ForgeData.Instance:SetLevelUpLuckyItemUseNum(self.use_item_num)
	--刷新界面
	ForgeCtrl.Instance:OnSCEquipmentItemChange()
	self:Close()
end

function TipsUseLuckyItemView:CloseCallBack()
	self.lucky_item_data = nil
end

function TipsUseLuckyItemView:OnClickCloseWindows()
	self:Close()
end

function TipsUseLuckyItemView:OnClickPlus()
	local is_out_of_max = self:IsOutOfSucceedRate()
	if is_out_of_max then
		self.node_list["UseTips"].text.text = Language.Forge.LuckyItemSucceedMax
	else
		self.node_list["UseTips"].text.text = self.succeed_rate_str
		self:FlushText(true)
	end
end

function TipsUseLuckyItemView:IsOutOfSucceedRate()
	local is_out_max = ForgeData.Instance:IsMaxSucceedRate(self.lucky_item_data.equip_id,self.use_item_num)
	return is_out_max
end

function TipsUseLuckyItemView:OnClickDeduce()
	self:FlushText(false)
	self.node_list["UseTips"].text.text = self.succeed_rate_str
end

function TipsUseLuckyItemView:FlushText(is_add)
	if is_add and self.use_item_num < self.last_item_num then
		self.use_item_num = self.use_item_num + 1 
	elseif not is_add and  self.use_item_num > 0 then
		self.use_item_num = self.use_item_num - 1
	end

	self.node_list["UseLuckyItemNum"].text.text = self.use_item_num
end