TipsCompleteChapterView = TipsCompleteChapterView or BaseClass(BaseView)

function TipsCompleteChapterView:__init()
	self.is_modal = true
	self.is_any_click_close = true
	self.ui_config = {{"uis/views/tips/completechapterview_prefab", "CompleteChapterView"}}
	self.play_audio = true
	local config = ConfigManager.Instance:GetAutoConfig("fb_scene_config_auto").zhangjie_view
	self.chapter_cfg = ListToMap(config, "start_taskid")
	self.view_layer = UiLayer.PopTop
	self.task_change_handle = GlobalEventSystem:Bind(OtherEventType.TASK_CHANGE, BindTool.Bind(self.OnTaskChange, self))
	self.now_task_id = 0
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.is_async_load = true
end

function TipsCompleteChapterView:__delete()
	if nil ~= self.task_change_handle then
		GlobalEventSystem:UnBind(self.task_change_handle)
		self.task_change_handle = nil
	end
end

function TipsCompleteChapterView:ReleaseCallBack()
	self.async_loader = nil
	self.content_animator = nil
end

function TipsCompleteChapterView:LoadCallBack()
	self.node_list["Frame"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.content_animator = self.node_list["Content"].animator
end

function TipsCompleteChapterView:OpenCallBack()
	TaskCtrl.Instance:SetIsOpenView(true)
	self:ShowOpenEffect()
	self:Flush()
end

function TipsCompleteChapterView:CloseView()
	self:RemoveDelay()
	self:Close()
end

function TipsCompleteChapterView:RemoveDelay()
	if nil ~= self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function TipsCompleteChapterView:CloseCallBack()
	self:RemoveDelay()
	TaskCtrl.Instance:SetIsOpenView(false)
end

function TipsCompleteChapterView:OnTaskChange(task_event_type, task_id)
	if task_event_type ~= "completed_add" then
		return
	end

	if nil == self.chapter_cfg[task_id] then
		return
	end
	self.now_task_id = task_id
	if self:IsOpen() then
		self:Flush()
	else
		self:Open()
	end
end

function TipsCompleteChapterView:OnFlush()
	local cfg = self.chapter_cfg[self.now_task_id]
	if nil == cfg then
		return
	end
	self:RemoveDelay()
	self.node_list["TxtTitleNum"].text.text = Language.Common.NumToChs[cfg.zhangjie_id]
	if self.node_list["Title"] and self.node_list["Txt_des"] then
		local bundle, asset = ResPath.Getcompletechapterview("title" .. cfg.zhangjie_id)
		self.node_list["Title"].image:LoadSprite(bundle, asset, function()
			self.node_list["Title"].image:SetNativeSize()
		end)
		local text_bundle, text_asset = ResPath.Getcompletechapterview("text" .. cfg.zhangjie_id)
		self.node_list["Txt_des"].image:LoadSprite(text_bundle, text_asset, function()
			self.node_list["Txt_des"].image:SetNativeSize()
		end)
	end
end

function TipsCompleteChapterView:ShowOpenEffect()
	local loader = AllocAsyncLoader(self, "show_open_effect")
	local bundle_name, asset_name = ResPath.GetUiEffect("UI_zhangjie")
	loader:Load(bundle_name, asset_name, function(obj)
		if not IsNil(obj) then
			local transform = obj.transform
			transform:SetParent(self.node_list["Bg"].transform, false)
			transform.localScale = Vector3(1, 1, 1)
			if self.content_animator then
				self.content_animator:SetBool("show", true)
				if nil == self.timer_quest then
					self.timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.CloseView, self), 4)
				end
			end
		end
	end)
end