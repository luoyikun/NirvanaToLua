TipsSpiritConfirmView = TipsSpiritConfirmView or BaseClass(BaseView)

function TipsSpiritConfirmView:__init()
	self.ui_config = {{"uis/views/tips/spirithometip_prefab", "SpiritHarvertConfirmTip"}}
	self.view_layer = UiLayer.Pop
	self.str = ""
	self.early_close_state = false
	self.hook_state = false
	self.is_modal = true
	self.is_any_click_close = true
end

function TipsSpiritConfirmView:ReleaseCallBack()
	self.hook_state = false
end

function TipsSpiritConfirmView:SetData(select_index)
	self.select_index = select_index
	if not self:IsOpen() then
		self:Open()
	end
end

function TipsSpiritConfirmView:OpenCallBack()
	self.hook_state = false
	if self.node_list["ImgHook"] ~= nil then
		self.node_list["ImgHook"]:SetActive(self.hook_state)
	end
	self:Flush()
end

function TipsSpiritConfirmView:LoadCallBack()
	self.node_list["ImgHook"].button:AddClickListener(BindTool.Bind(self.OnClickHook, self))
	self.node_list["BtnYesButton"].button:AddClickListener(BindTool.Bind(self.OnClickConfirm, self))
	self.node_list["BtnCloseButton"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["BtnCancelButton"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
end

function TipsSpiritConfirmView:OnClickHook()
	self.hook_state = not self.hook_state
	 if self.node_list["ImgHook"] ~= nil then
		self.node_list["ImgHook"]:SetActive(self.hook_state)
	end
end

function TipsSpiritConfirmView:OnClickConfirm()
	self:Close()
	if self.select_index == nil then
		return
	end

	local cfg = SpiritData.Instance:GetSpiritHomeInfoByIndex()
	if cfg == nil or next(cfg) == nil then
		return
	end

	local my_cfg =  SpiritData.Instance:GetEnterOtherSpirit()
	if my_cfg.res_id == 0 or my_cfg.read_index == nil then
		return
	end

	SpiritData.Instance:SetHarvertSpirit(self.select_index)
	SpiritCtrl.Instance:SendJingLingHomeOperReq(JING_LING_HOME_OPER_TYPE.JING_LING_HOME_OPER_TYPE_ROB, cfg.role_id, my_cfg.read_index, self.select_index - 1)
end

function TipsSpiritConfirmView:OnClickClose()
	self:Close()
end

function TipsSpiritConfirmView:OnFlush()
	if self.select_index == nil then
		return
	end

	local cfg = SpiritData.Instance:GetSpiritHomeInfoByIndex()
	if cfg == nil or next(cfg) == nil then
		return
	end

	local item_id = cfg.item_list[self.select_index].item_id
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)

	if self.node_list["TxtContent"] ~= nil and item_cfg ~= nil then
		self.node_list["TxtContent"].text.text = string.format(Language.JingLing.SpiritHomeHarvestTip, cfg.name, item_cfg.name)
	end
end