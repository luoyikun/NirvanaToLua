ActorTriggerHalts = ActorTriggerHalts or BaseClass(ActorTriggerBase)

function ActorTriggerHalts:__init(anima_name, is_main_role)
	self.anima_name = anima_name
	self.is_main_role = is_main_role
	self.enabled = true

	self.halts_data = nil
end

function ActorTriggerHalts:__delete()
	self.halts_data = nil
end

-- 初始化预制体保存的配置数据(单个)
function ActorTriggerHalts:Init(halts_data)
	self.halts_data = halts_data
	self.delay = halts_data.haltDelay
end

-- get/set
function ActorTriggerHalts:Enalbed(value)
	if value == nil then
		return self.enabled
	end
	self.enabled = value
end

function ActorTriggerHalts:OnEventTriggered(source, target, source_obj, target_obj, stateInfo)
	local halts_data = self.halts_data
	if not halts_data or not self.enabled then
		return
	end

	if target_obj then
		local scene_obj = target_obj:GetSceneObj()
		if scene_obj and scene_obj:IsRole() then
			return
		end
	end

	local children = target.gameObject:GetComponentsInChildren(typeof(UnityEngine.Animator))
	for i = 0, children.Length - 1 do
		local animator = children[i]
		if animator then
			animator.enabled = false
			GlobalTimerQuest:AddDelayTimer(
				function() 
					animator.enabled = true
				end, halts_data.haltContinueTime)
		end
	end
end
