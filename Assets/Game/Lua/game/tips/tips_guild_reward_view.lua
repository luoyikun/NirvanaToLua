TipGuildRewardView = TipGuildRewardView or BaseClass(BaseView)

function TipGuildRewardView:__init()
	self.ui_config = {{"uis/views/tips/rewardtips_prefab", "GuildRewardTip"}}
	self.view_layer = UiLayer.Pop
	self.is_show_default_title = true
	self.callback = nil
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipGuildRewardView:ReleaseCallBack()
	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end
end

function TipGuildRewardView:LoadCallBack()
	self.node_list["BtnOk"].button:AddClickListener(BindTool.Bind(self.CloseOnClick, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseOnClick, self))
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["EquipItem"])
end

function TipGuildRewardView:OpenCallBack()
	self:Flush()
end

function TipGuildRewardView:ShowIndexCallBack(index)
end

function TipGuildRewardView:CloseCallBack()
end

function TipGuildRewardView:SetData(data)
	self.data = data
	self:Open()
end

function TipGuildRewardView:CloseOnClick()
	self:Close()
end

function TipGuildRewardView:CloseCallBack()
	if self.callback then
		self.callback(self.param)
	end
	self.callback = nil
end

function TipGuildRewardView:SetParam(param)
	self.param = param
end

function TipGuildRewardView:SetTitleState(value)
	self.is_show_default_title = value
	if nil == self.is_show_default_title then
		self.is_show_default_title = true
	end
end

function TipGuildRewardView:SetCallBack(callback)
	self.callback = callback
end

function TipGuildRewardView:OnFlush(param_list)
	if nil == self.data or nil == next(self.data) then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg then
		return
	end

	local name_str = ToColorStr(item_cfg.name, SOUL_NAME_COLOR[item_cfg.color])
	self.node_list["TxtItemName"].text.text = name_str
	self.item:SetData(self.data)
	self.node_list["TxtOktext"].text.text = self.callback and Language.Common.LingQu or Language.Common.Confirm
	self.node_list["ImgTitle"]:SetActive(self.is_show_default_title)
	self.node_list["ImgFalse"]:SetActive(not self.is_show_default_title)
	self.node_list["EffectSuccess"]:SetActive(self.is_show_default_title)
end