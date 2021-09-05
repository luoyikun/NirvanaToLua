TipsLoadingView = TipsLoadingView or BaseClass(BaseView)

function TipsLoadingView:__init()
	self.ui_config = {{"uis/views/tips/loadingtips_prefab", "LoadingTip"}}
	self.view_layer = UiLayer.Pop
	self.is_modal = true
end

function TipsLoadingView:ReleaseCallBack()
	if nil ~= self.connect_time then
		GlobalTimerQuest:CancelQuest(self.connect_time)
		self.connect_time = nil
	end

	if nil ~= self.close_timer then
		GlobalTimerQuest:CancelQuest(self.close_timer)
		self.close_timer = nil
	end
end

function TipsLoadingView:LoadCallBack()

end

function TipsLoadingView:OpenCallBack()
	local str = (self.flag == 1) and Language.LoadingTipsText.ReconnectionText or Language.LoadingTipsText.LoadingText
	self.node_list["TxtCharacter"].text.text = str
end

function TipsLoadingView:SetCharacter(flag)
	self.flag = flag
end

function TipsLoadingView:CloseCallBack()
	self.duration = nil
	self.callback = nil
	self.flag = nil
	if nil ~= self.connect_time then
		GlobalTimerQuest:CancelQuest(self.connect_time)
		self.connect_time = nil
	end

	if nil ~= self.close_timer then
		GlobalTimerQuest:CancelQuest(self.close_timer)
		self.close_timer = nil
	end

end

function TipsLoadingView:ReleaseCallBack()

end


function TipsLoadingView:SetDuration(duration)
	self.duration = duration
	if self.duration then
		GlobalTimerQuest:CancelQuest(self.close_timer)
		self.close_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.OnTimeOutClose,self), self.duration)
	end
end

function TipsLoadingView:SetCallBack(callback)
	self.callback = callback
end

function TipsLoadingView:OnTimeOutClose()
	if self.callback then
		self.callback()
	end
	self:Close()
end
