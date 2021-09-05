SendGiftSelectView = SendGiftSelectView or BaseClass(BaseView)
function SendGiftSelectView:__init()
    self.ui_config = {
		{"uis/views/sendgiftview_prefab", "SelectTipView"},
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
    self.play_audio = true
    self.is_async_load = false
    self.is_any_click_close = true 
end

function SendGiftSelectView:__delete()

end

function SendGiftSelectView:ReleaseCallBack()
	if self.cell_select then
		self.cell_select:DeleteMe()
		self.cell_select = nil
	end
end

function SendGiftSelectView:LoadCallBack()
 	self.cell_select = ItemCell.New()
	self.cell_select:SetInstanceParent(self.node_list["CellSelect"])  
	self.node_list["BtnCloseButton"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["InputNum"].button:AddClickListener(BindTool.Bind(self.OnClickInputNum, self))
	self.node_list["Max"].button:AddClickListener(BindTool.Bind(self.OnMax, self))
	self.node_list["Confirm"].button:AddClickListener(BindTool.Bind(self.OnConfirm, self))
end

function SendGiftSelectView:ShowIndexCallBack()
end

function SendGiftSelectView:CloseCallBack()
	
end

function SendGiftSelectView:OpenCallBack()
	self:Flush()
end

function SendGiftSelectView:OnFlush(param_t)
	if self.item_data and self.item_data.item_id then
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.item_data.item_id)
		if not item_cfg then return end
		self.cell_select:SetData(self.item_data) 		
		self.node_list["ItemName"].text.text = ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color])
		self.select_item_count = self.item_data.num
		self.count = self.select_item_count
		self.node_list["ItemNum"].text.text = self.count
	end
end

function SendGiftSelectView:SetSelectViewData(data)
	self.item_data = {}
	self.item_data = data
end

-- 点击数量输入框
function SendGiftSelectView:OnClickInputNum()
	if self.select_item_count == nil then
		return
	end
	if self.select_item_count and self.select_item_count < 1 then
		return
	end	
	TipsCtrl.Instance:OpenCommonInputView(nil, BindTool.Bind(self.CountInputEnd, self))
end

function SendGiftSelectView:CountInputEnd(str)
	local count = tonumber(str)
	if count < 1 then
		count = 1
	elseif count > self.select_item_count then
		count = self.select_item_count
	end
	self.count = count
	self.node_list["ItemNum"].text.text = self.count
end

function SendGiftSelectView:OnMax()
	if self.select_item_count ~= nil then
		self.count = self.select_item_count
		self.node_list["ItemNum"].text.text = self.count
	end
end

function SendGiftSelectView:OnConfirm()
	self.item_data.num = self.count
	SendGiftCtrl.Instance:InsertSendCellData(self.item_data)
	self:Close()
end