TipsCommonExplainView = TipsCommonExplainView or BaseClass(BaseView)

function TipsCommonExplainView:__init()
	self.ui_config = {{"uis/views/tips/commontips_prefab", "CommonExplainTips"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.content_str = ""
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsCommonExplainView:ReleaseCallBack()

end

function TipsCommonExplainView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["BtnGo"].button:AddClickListener(BindTool.Bind(self.OnClickGoTo, self))
	self.node_list["BtnComplete"].button:AddClickListener(BindTool.Bind(self.OnClickComplete, self))
end

function TipsCommonExplainView:OpenCallBack()
	self.node_list["NoTipToggle"].toggle.isOn = true
	self:Flush()
end

function TipsCommonExplainView:CloseCallBack()

end

function TipsCommonExplainView:SetContent(content)
	self.content_str = content or ""
end

function TipsCommonExplainView:SetOkCallBack(go_callback)
	self.go_callback = go_callback
end

function TipsCommonExplainView:SetCompleteCallBack(complete_callback)
	self.complete_callback = complete_callback
end

function TipsCommonExplainView:SetPrefabKey(prefab_key)
	self.prefab_key = prefab_key
end

function TipsCommonExplainView:OnClickClose()
	self:Close()
end

function TipsCommonExplainView:OnClickGoTo()
	if nil ~= self.go_callback then
		self.go_callback()
		self.go_callback = nil
	end
	-- if self.node_list["NoTipToggle"].toggle.isOn and nil ~= self.prefab_key then
	-- 	PlayerPrefsUtil.SetInt(self.prefab_key, 1)
	-- end
	self:Close()
end

function TipsCommonExplainView:OnClickComplete()
	if nil ~= self.complete_callback then
		self.complete_callback()
		self.complete_callback = nil
	end
	self:Close()
end

function TipsCommonExplainView:OnFlush(param_list)
	self.node_list["TxtTips"].text.text = self.content_str
end