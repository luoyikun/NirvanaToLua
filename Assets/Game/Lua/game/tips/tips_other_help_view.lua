TipsOtherHelpView = TipsOtherHelpView or BaseClass(BaseView)

function TipsOtherHelpView:__init()
	self.ui_config = {{"uis/views/tips/helptips_prefab", "OtherHelpTipView"}}

	self.des = ""
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsOtherHelpView:__delete()
end

function TipsOtherHelpView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
end

function TipsOtherHelpView:ReleaseCallBack()
end

function TipsOtherHelpView:CloseWindow()
	self:Close()
end

function TipsOtherHelpView:OpenCallBack()
	self:Flush()
end

function TipsOtherHelpView:SetDes(id)
	self.id = id or 1
	self.des = TipsOtherHelpData.Instance:GetTipsTextById(id)
end

function TipsOtherHelpView:OnFlush()
	if type(self.des) ~= "string" then
		self.des = ""
	end
	self.node_list["TxtHelp"].text.text = self.des
end