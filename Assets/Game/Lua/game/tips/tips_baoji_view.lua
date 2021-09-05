TipsBaoJiView = TipsBaoJiView or BaseClass(BaseView)

function TipsBaoJiView:__init()
	self.ui_config = {{"uis/views/tips/baojitip_prefab", "BaoJiTip"}}
	self.view_layer = UiLayer.Pop

	self.close_mode = CloseMode.CloseVisible
	self.close_timer = nil
end

function TipsBaoJiView:__delete()
	if self.close_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.close_timer)
	end
end

function TipsBaoJiView:LoadCallBack()
	
end

function TipsBaoJiView:ReleaseCallBack()
	
end

function TipsBaoJiView:Show(advance_type)
	self.advance_type = advance_type
	if self.close_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.close_timer)
		self.close_timer = nil
	end
	self.close_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.CloseTips, self), 5)
	self:Open()
	self:Flush()
end

function TipsBaoJiView:CloseTips()
	self.is_close = true
	self:Close()
end

function TipsBaoJiView:CloseCallBack()
	self.is_close = true
	if self.close_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.close_timer)
		self.close_timer = nil
	end
end 

function TipsBaoJiView:OnFlush()
	if "advance_view" == self.advance_type then
		self.node_list["Image"]:SetActive(true)
		UITween.MoveToShowPanel(self.node_list["Image"], Vector3(475, -135, 0), Vector3(475, -35, 0), 1, nil, function()
			UITween.AlpahShowPanel(self.node_list["Image"], false, 0.5, DG.Tweening.Ease.Linear, function()
				self.node_list["Image"]:SetActive(false)
			end)
		end)
	else
		self.node_list["Image"]:SetActive(true)
		UITween.MoveToShowPanel(self.node_list["Image"], Vector3(475, -145, 0), Vector3(475, -45, 0), 1, nil, function()
			UITween.AlpahShowPanel(self.node_list["Image"], false, 0.5, DG.Tweening.Ease.Linear, function()
				self.node_list["Image"]:SetActive(false)
			end)
		end)
	end
end
