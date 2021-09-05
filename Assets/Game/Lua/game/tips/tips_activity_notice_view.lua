TipsActivityNoticeView = TipsActivityNoticeView or BaseClass(BaseView)

function TipsActivityNoticeView:__init()
	self.ui_config = {{"uis/views/tips/activitynotice_prefab", "ActivityNoticeTips"}}
	self.view_layer = UiLayer.PopTop

	self.messge = nil
	self.close_timer = nil

	self.is_hide = false
	self.play_audio = true
end

function TipsActivityNoticeView:LoadCallBack()

end

function TipsActivityNoticeView:ReleaseCallBack()
	if nil ~= self.close_timer then
		GlobalTimerQuest:CancelQuest(self.CloseTips)
	end
end

function TipsActivityNoticeView:Show(msg)
	if nil ~= self.close_timer then
		GlobalTimerQuest:CancelQuest(self.CloseTips)
	end
	local color = COLOR.WHITE
	self.messge = RichTextUtil.GetAnalysisText(msg, color)
	self:Open()
	self.is_hide = false
	self:Flush()
end

function TipsActivityNoticeView:CloseTips()
	self:Close()
end

function TipsActivityNoticeView:AnimatorIsHide()
	return self.is_hide
end

function TipsActivityNoticeView:OnFlush(param_list)
	self.node_list["PanelTipAnimator"].animator:SetBool(ANIMATOR_PARAM.SHOW, true)

	self.node_list["TxtRich"].text.text = self.messge
	self.node_list["PanelTipAnimator"].animator:WaitEvent("enter", function(param)
		self.node_list["PanelTipAnimator"].animator:SetBool(ANIMATOR_PARAM.SHOW, false)
		self.is_hide = true
	end)
end
