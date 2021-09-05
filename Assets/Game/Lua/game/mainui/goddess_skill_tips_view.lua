GoddessSkillTipsView = GoddessSkillTipsView or BaseClass(BaseView)

function GoddessSkillTipsView:__init()
	self.ui_config = {{"uis/views/goddess_prefab", "GoddessSkillTips"}}
	self.view_layer = UiLayer.Pop
	self.is_modal = true
end

function GoddessSkillTipsView:__delete()

end

function GoddessSkillTipsView:ReleaseCallBack()
	if nil ~= self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function GoddessSkillTipsView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["Close"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
end

function GoddessSkillTipsView:OpenCallBack()
	TaskCtrl.Instance:SetIsOpenView(true)
	if nil ~= self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	self.timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.CloseWindow, self), 6)
end

function GoddessSkillTipsView:CloseWindow()
	TaskCtrl.Instance:SetIsOpenView(false)
	self:Close()
end

function GoddessSkillTipsView:CloseCallBack()
	if self.call_back then
		self.call_back()
	end
end

function GoddessSkillTipsView:SetCloseCallBack(call_back)
	self.call_back = call_back
end