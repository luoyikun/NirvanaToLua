TipsHelpView = TipsHelpView or BaseClass(BaseView)

function TipsHelpView:__init()
	self.ui_config = {{"uis/views/tips/helptips_prefab", "HelpTipView"}}
	self.des = ""
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_any_click_close = true
	self.is_modal = true

	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsHelpView:__delete()

end

function TipsHelpView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
end

function TipsHelpView:ReleaseCallBack()
	-- 清理变量和对象
end

function TipsHelpView:CloseWindow()
	self:Close()
end

function TipsHelpView:OpenCallBack()
	self:Flush()
end

function TipsHelpView:SetDes(tips_id)
	if tonumber(tips_id) ~= nil then
		self.tips_id = tips_id or 1
		self.des = TipsOtherHelpData.Instance:GetTipsTextById(tips_id) or ""
		return
	end
	self.des = tips_id or ""
end

function TipsHelpView:OnFlush()
	if type(self.des) ~= "string" then
		self.des = ""
	end
	self.node_list["TxtHelp"].text.text = self.des
end