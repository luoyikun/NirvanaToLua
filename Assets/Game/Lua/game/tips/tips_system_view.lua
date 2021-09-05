TipsSystemView = TipsSystemView or BaseClass(BaseView)

function TipsSystemView:__init()
	self.ui_config = {{"uis/views/tips/systemtips_prefab", "SystemTips"}}
	self.view_layer = UiLayer.Pop

	self.close_mode = CloseMode.CloseVisible
	self.messge = nil
	self.close_timer = nil
	self.anim_speed = 1
	self.is_close = false
end

function TipsSystemView:__delete()
	if self.close_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.close_timer)
	end
end

function TipsSystemView:LoadCallBack()
	self.anim = self.node_list["SystemTips"]:GetComponent(typeof(UnityEngine.Animator))
	self.anim:SetFloat("Speed", self.anim_speed)
end

function TipsSystemView:ReleaseCallBack()
	-- 清理变量和对象
	self.anim = nil
end

function TipsSystemView:Show(msg, speed)
	speed = speed or 1
	self.anim_speed = speed
	if self.anim and self.anim.isActiveAndEnabled then
		self.anim:SetFloat("Speed", speed)
	end
	if self.close_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.close_timer)
		self.close_timer = nil
	end
	self.close_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.CloseTips, self), 5)
	self:Open()
	self:Flush("new_msg", {msg = msg})
end

function TipsSystemView:ChangeSpeed(speed)
	if self.anim and self.anim.isActiveAndEnabled then
		self.anim:SetFloat("Speed", speed)
	end
end

function TipsSystemView:CloseTips()
	self.is_close = true
	self:Close()
end

function TipsSystemView:CloseCallBack()
	self.is_close = true
	if self.close_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.close_timer)
		self.close_timer = nil
	end
end

function TipsSystemView:GetCloseFlag()
	return self.is_close
end

function TipsSystemView:OnFlush(param_list)
	for k,v in pairs(param_list) do
		if "new_msg" == k then
			RichTextUtil.ParseRichText(self.node_list["RichText"].rich_text, v.msg)
		end
	end
end

function TipsSystemView:GetAnimSpeed()
	return self.anim_speed
end