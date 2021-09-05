ActorTriggerCameraShake = ActorTriggerCameraShake or BaseClass(ActorTriggerBase)

function ActorTriggerCameraShake:__init(anima_name)
	self.anima_name = anima_name
	self.transform = nil
	self.enabled = true
	self.target = nil

	self.camera_shake_data = nil
end

function ActorTriggerCameraShake:__delete()
	self.camera_shake_data = nil
end

-- 初始化预制体保存的配置数据(单个)
function ActorTriggerCameraShake:Init(camera_shake_data)
	self.camera_shake_data = camera_shake_data
	self.delay = camera_shake_data.delay
end

-- get/set
function ActorTriggerCameraShake:Enalbed(value)
	if value == nil then
		return self.enabled
	end
	self.enabled = value
end

function ActorTriggerCameraShake:OnEventTriggered(source, target, source_obj, target_obj, stateInfo)
	local shake = self.camera_shake_data
	if shake and self.enabled and CameraShake and CameraShake.Shake then
		CameraShake.Shake(shake.numberOfShakes, Vector3.one, Vector3.zero, shake.distance, shake.speed, shake.decay, 1, true)
	end
end
