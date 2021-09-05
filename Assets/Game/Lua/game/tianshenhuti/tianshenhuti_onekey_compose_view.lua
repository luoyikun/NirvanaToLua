TianshenhutiOnekeyComposeView = TianshenhutiOnekeyComposeView or BaseClass(BaseView)

function TianshenhutiOnekeyComposeView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/tianshenhutiview_prefab", "QuickComposeView"},
	}
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TianshenhutiOnekeyComposeView:__delete()

end

function TianshenhutiOnekeyComposeView:CloseCallBack()

end

function TianshenhutiOnekeyComposeView:ReleaseCallBack()

end

function TianshenhutiOnekeyComposeView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(666,350,0)
	self.node_list["Txt"].text.text = Language.Tianshenhuti.OneKeyComposeTitle
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))

	self.node_list["TxtPage"].text.text = 2

	self.node_list["BtnNo"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnYes"].button:AddClickListener(BindTool.Bind(self.OnClickEnter, self))
	self.node_list["BtnUp"].button:AddClickListener(BindTool.Bind(self.OnClickReduce, self))
	self.node_list["BtnDown"].button:AddClickListener(BindTool.Bind(self.OnClickAdd, self))
end

function TianshenhutiOnekeyComposeView:OnClickEnter()
	local grade = self.node_list["TxtPage"].text.text
	TianshenhutiCtrl.SendTianshenhutiQuickCombine(grade)
end

function TianshenhutiOnekeyComposeView:OnClickAdd()
	local grade = tonumber(self.node_list["TxtPage"].text.text) or 2
	if grade >= TianshenhutiData.Instance:GetMaxLevel() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Tianshenhuti.GradeTips[1])
		return
	end
	self.node_list["TxtPage"].text.text = grade + 1
end

function TianshenhutiOnekeyComposeView:OnClickReduce()
	local grade = tonumber(self.node_list["TxtPage"].text.text) or 2
	if grade <= 2 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Tianshenhuti.GradeTips[2])
		return
	end
	self.node_list["TxtPage"].text.text = grade - 1
end

function TianshenhutiOnekeyComposeView:OpenCallBack()
	self:Flush()
end

function TianshenhutiOnekeyComposeView:OnFlush(param_list)

end