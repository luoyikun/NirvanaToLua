ActorTriggerBase = ActorTriggerBase or BaseClass()

function ActorTriggerBase:__init()
	self.delay = 0
	self.transform = nil
	self.enabled = true
	self.target = nil
	self.delay_timer_quest = {}
	self.delay_timer_num = 0
end

function ActorTriggerBase:__delete()
	for _, v in pairs(self.delay_timer_quest) do
		GlobalTimerQuest:CancelQuest(v)
	end
	self.delay_timer_quest = {}
	self.delay_timer_num = 0
end

-- get/set
function ActorTriggerBase:Enalbed(value)
	if value == nil then
		return self.enabled
	end
	self.enabled = value
end

function ActorTriggerBase:OnAnimatorEvent(param, stateInfo, source_obj, target_obj, anim_name)
	if self.enabled then
		local source = source_obj:GetRoot()
		local target = nil
		if target_obj then
			target = target_obj.GetRoot and target_obj:GetRoot() or target_obj
		end

		if self.delay <= 0 then
			self:OnEventTriggered(source, target, source_obj, target_obj, stateInfo)
		else
			self:DelayTrigger(source, target, source_obj, target_obj, stateInfo)
		end
	end
end

function ActorTriggerBase:OnEventTriggered(source, target, source_obj, target_obj, stateInfo)
	-- root source, root target, obj source_obj, obj target_obj
	-- override
end

function ActorTriggerBase:DelayTrigger(source, target, source_obj, target_obj, stateInfo)
	if self.delay_timer_quest[self.delay_timer_num] then
		GlobalTimerQuest:CancelQuest(self.delay_timer_quest[self.delay_timer_num])
	end
	self.delay_timer_quest[self.delay_timer_num] = GlobalTimerQuest:AddDelayTimer(
		function() 
			if source == nil or IsNil(source.gameObject) or not source.gameObject.activeInHierarchy then
				return
			end
			self:OnEventTriggered(source, target, source_obj, target_obj, stateInfo)
			self.delay_timer_num = self.delay_timer_num + 1
		end, self.delay)
end