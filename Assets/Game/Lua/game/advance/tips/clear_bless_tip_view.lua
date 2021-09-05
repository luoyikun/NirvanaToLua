ClearBlessTipView = ClearBlessTipView or BaseClass(BaseView)

function ClearBlessTipView:__init()
	self.ui_config = {{"uis/views/advanceview_prefab", "ClearBlessTip"}}
	self.play_audio = true
	self.data = nil
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function ClearBlessTipView:__delete()

end

function ClearBlessTipView:LoadCallBack()
	self.node_list["Button02"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
end

function ClearBlessTipView:ReleaseCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

end

function ClearBlessTipView:OpenCallBack()
	self:Flush()
end

function ClearBlessTipView:CloseWindow()
	self:Close()
end

function ClearBlessTipView:SetData(data)
	self.data = data
	self:Open()
end

function ClearBlessTipView:ShowIndexCallBack(index)

end

function ClearBlessTipView:CloseCallBack()
	if self.data then
		if self.data.call_back then
			if ViewManager.Instance:IsOpen(self.data.view_name) then
				self.data.call_back(self.data.to_index)
			end
		else
			ViewManager.Instance:Close(self.data.view_name)
		end
	end
	self.data = nil
end

function ClearBlessTipView:OnFlush(param_t)
	if nil == self.data then return end
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
	self.node_list["LuckPerStr"].text.text = self.data.cur_val .. "/" .. self.data.max_val
	self.node_list["ProgressBG"].slider.value = self.data.cur_val/self.data.max_val
	self.node_list["GradeTxt"].text.text = string.format(Language.Advance.ClearStr, self.data.grade_name)
	self.node_list["IndexName"].text.text = string.format(Language.Advance.ClearJinJie, Language.Advance.PercentAttrNameList[self.data.view_index] or "")
end

function ClearBlessTipView:FlushNextTime()
	local cur_time = TimeCtrl.Instance:GetServerTime()
	local over_time = TimeUtil.NowDayTimeStart(cur_time) + 3600 * 5
	local time = over_time - cur_time
	if time < 0 then
		time = time + 3600 * 24
	end
	if time > 3600 then
		self.node_list["ClearTime"].text.text = string.format(Language.Advance.ClearBlessStr, TimeUtil.FormatSecond(time,3))
	else
		self.node_list["ClearTime"].text.text = string.format(Language.Advance.ClearBlessStr, TimeUtil.FormatSecond(time,2))
	end
end
