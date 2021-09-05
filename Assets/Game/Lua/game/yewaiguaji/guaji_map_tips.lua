GuajiMapTips = GuajiMapTips or BaseClass(BaseView)

function GuajiMapTips:__init()
	self.ui_config = {{"uis/views/yewaiguaji_prefab", "GuajiMapTips"}}
	self.view_layer = UiLayer.Pop
end

function GuajiMapTips:__delete()

end

function GuajiMapTips:ReleaseCallBack()
	if self.close_timer then
		GlobalTimerQuest:CancelQuest(self.close_timer)
		self.close_timer = nil
	end
end

function GuajiMapTips:LoadCallBack()

end

function GuajiMapTips:CloseWindow()

end

function GuajiMapTips:CloseCallBack()
	if self.close_timer then
		GlobalTimerQuest:CancelQuest(self.close_timer)
		self.close_timer = nil
	end
end

function GuajiMapTips:OpenCallBack()
	self.close_timer = GlobalTimerQuest:AddDelayTimer(function ()
		self.close_timer = nil
		self:Close()
	end, 3)
end