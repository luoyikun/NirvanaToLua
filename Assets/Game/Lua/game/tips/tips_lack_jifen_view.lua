TipsLackJiFenView = TipsLackJiFenView or BaseClass(BaseView)

function TipsLackJiFenView:__init()
	self.ui_config = {{"uis/views/tips/lackjifentips_prefab", "LackJiFenTips"}}
	self.view_layer = UiLayer.Pop
	self.sure_call_back = nil
	self.play_audio = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsLackJiFenView:LoadCallBack()
	self.node_list["BtnBG"].button:AddClickListener(BindTool.Bind(self.OnClickCloseButton, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickCloseButton, self))
	self.node_list["BtnChongZhi"].button:AddClickListener(BindTool.Bind(self.OnClickChongZhi, self))
end

function TipsLackJiFenView:ReleaseCallBack()

end

function TipsLackJiFenView:OnClickCloseButton()
	self:Close()
end

function TipsLackJiFenView:CloseCallBack()
	if self.sure_call_back ~= nil then
		self.sure_call_back()
	end
	ViewManager.Instance:Close(ViewName.TipsCommonBuyView)
end

function TipsLackJiFenView:SetSureCallBack(sure_call_back)
	self.sure_call_back = sure_call_back
end

function TipsLackJiFenView:OnClickChongZhi()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
	self:Close()
end
