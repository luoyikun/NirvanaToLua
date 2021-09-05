TipsLackDiamondView = TipsLackDiamondView or BaseClass(BaseView)

function TipsLackDiamondView:__init()
	self.ui_config = {{"uis/views/tips/lackdiamondtips_prefab", "LackDiamondTips"}}
	self.view_layer = UiLayer.Pop
	self.sure_call_back = nil
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsLackDiamondView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickCloseButton, self))
	self.node_list["BtnChongZhi"].button:AddClickListener(BindTool.Bind(self.OnClickChongZhi, self))
end

function TipsLackDiamondView:OpenCallBack()
	self.node_list["DescText"].text.text = self.desc_text or Language.Recharge.LeckOfGold
end

function TipsLackDiamondView:SetDescText(desc_text)
	self.desc_text = desc_text
end

function TipsLackDiamondView:OnClickCloseButton()
	self:Close()
end

function TipsLackDiamondView:CloseCallBack()
	if self.sure_call_back ~= nil then
		self.sure_call_back()
	end

	self.desc_text = nil
	ViewManager.Instance:Close(ViewName.TipsCommonBuyView)
end

function TipsLackDiamondView:SetSureCallBack(sure_call_back)
	self.sure_call_back = sure_call_back
end

function TipsLackDiamondView:OnClickChongZhi()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
	self:Close()
end
