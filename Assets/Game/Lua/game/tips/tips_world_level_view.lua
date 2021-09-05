TipsWorldLevelView = TipsWorldLevelView or BaseClass(BaseView)

function TipsWorldLevelView:__init()
	self.ui_config = {{"uis/views/player_prefab", "TipsWorldLevelView"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true

	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsWorldLevelView:__delete()

end

function TipsWorldLevelView:LoadCallBack()
	self.node_list["ButtonClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
end

function TipsWorldLevelView:ReleaseCallBack()
	-- 清理变量和对象
end

function TipsWorldLevelView:OpenCallBack()
	
end

function TipsWorldLevelView:SetData(worldOpenLevel, worldLevel, expPercent)
	self.worldOpenLevel = worldOpenLevel
	self.worldLevel = worldLevel
	self.expPercent = expPercent
	self:Flush()
end

function TipsWorldLevelView:OnFlush()
	self.node_list["Text1"].text.text = ToColorStr(self.worldOpenLevel or 0, CHAT_COLOR.GREEN)
	self.node_list["Text2"].text.text = ToColorStr(self.worldLevel or 0, CHAT_COLOR.GREEN)
	self.node_list["Content"].text.text = self.expPercent or 0
end