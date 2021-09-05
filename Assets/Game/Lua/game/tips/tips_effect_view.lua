TipsEffectView = TipsEffectView or BaseClass(BaseView)

function TipsEffectView:__init()
	self.ui_config = {{"uis/views/tips/effecttips_prefab", "EffectView"}}
	self.view_layer = UiLayer.Pop
end

function TipsEffectView:LoadCallBack()
	self.effect_obj = nil
	self.is_load_effect = false
end

function TipsEffectView:ReleaseCallBack()
	if self.effect_obj then
		ResMgr:Destroy(self.effect_obj)
		self.effect_obj = nil
	end
	self:RemoveDelayTime()
end

function TipsEffectView:OpenCallBack()
	self:LoadEffect()
end

function TipsEffectView:CloseCallBack()
	self:RemoveDelayTime()
	if self.effect_obj then
		ResMgr:Destroy(self.effect_obj)
		self.effect_obj = nil
	end
end

function TipsEffectView:SetData(bundle_name, asset_name, close_time)
	if self.effect_obj then
		return
	end
	close_time = close_time or 3
	self.bundle_name = bundle_name
	self.asset_name = asset_name
	self:LoadEffect()
	self:RemoveDelayTime()
	self.timer_quest = GlobalTimerQuest:AddDelayTimer(function() self:Close() end, close_time)
end

function TipsEffectView:LoadEffect()
	if self.effect_obj then
		return
	end
	if not self.is_load_effect then
		if self:IsLoaded() then
			self.is_load_effect = true
			local root_node = self.node_list["Center"].gameObject

			local async_loader = AllocAsyncLoader(self, "effect_loader")
			async_loader:Load(self.bundle_name, self.asset_name, function(obj)
				self.is_load_effect = false
				if not IsNil(obj) then
					if nil ~= root_node and not IsNil(root_node) then
						obj.transform:SetParent(root_node.transform, false)
						self.effect_obj = obj.gameObject
					end
				end
			end)
		end
	end
end

function TipsEffectView:RemoveDelayTime()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end