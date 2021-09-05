TipsTulongEffectView = TipsTulongEffectView or BaseClass(BaseView)

function TipsTulongEffectView:__init()
	self.ui_config = {{"uis/views/player_prefab", "TipsTulongEffectView"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true

	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsTulongEffectView:__delete()

end

function TipsTulongEffectView:LoadCallBack()
	self.node_list["ButtonClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
end

function TipsTulongEffectView:ReleaseCallBack()
	-- 清理变量和对象
end

function TipsTulongEffectView:CloseWindow()
	self:Close()
end

function TipsTulongEffectView:OpenCallBack()

end

function TipsTulongEffectView:SetData(worldOpenLevel, worldLevel, expPercent)

end

function TipsTulongEffectView:OnFlush()
end