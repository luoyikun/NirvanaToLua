ActorTrigger = ActorTrigger or BaseClass()

function ActorTrigger:__init(draw_obj)
	self.draw_obj = draw_obj

	self.is_main_role = false

	self.effects = {}
	self.halts = {}
	self.sounds = {}
	self.camera_shakes = {}
	-- self.camera_fovs = {}
	-- self.scene_fades = {}
	-- self.footsteps = {}

	self.animator = nil
	self.enable_effect = true
	self.enable_halt = true
	self.enable_camera_shake = true
	-- self.enable_camera = true
	-- self.enable_sceneFade = true
	-- self.enable_footsteps = true

end

function ActorTrigger:__delete()
	self:ResetData()
end

function ActorTrigger:ResetData()
	for _, effect in pairs(self.effects) do
		effect:DeleteMe()
	end
	self.effects = {}

	for _, halt in pairs(self.halts) do
		halt:DeleteMe()
	end
	self.halts = {}

	for _, sound in pairs(self.sounds) do
		sound:DeleteMe()
	end
	self.sounds = {}

	for _, camera_shake in pairs(self.camera_shakes) do
		camera_shake:DeleteMe()
	end
	self.camera_shakes = {}
end

function ActorTrigger:SetMainRole(is_main_role)
	self.is_main_role = is_main_role
end

function ActorTrigger:GetMainRole()
	return self.is_main_role
end

function ActorTrigger:GetPrefabData()
	return self.prefab_data
end

function ActorTrigger:SetPrefabData(data, layer)
	self.prefab_data = data
	self:ResetData()

	if self.prefab_data and self.prefab_data.actorTriggers then
		local actor_triggers = self.prefab_data.actorTriggers

		-- effects
		local effects = actor_triggers.effects or {}
		for k, effect in pairs(effects) do
			self.effects[k] = ActorTriggerEffect.New(effect.triggerEventName, layer)
			self.effects[k]:Init(effect)
		end

		-- halts
		local halts = actor_triggers.halts or {}
		for k, halt in pairs(halts) do
			self.halts[k] = ActorTriggerHalts.New(halt.haltEventName)
			self.halts[k]:Init(halt)
		end

		-- sounds
		local sounds = actor_triggers.sounds or {}
		for k, sound in pairs(sounds) do
			self.sounds[k] = ActorTriggerSound.New(sound.soundEventName, self.is_main_role)
			self.sounds[k]:Init(sound)
		end

		-- camera_shake
		local camera_shakes = actor_triggers.cameraShakes or {}
		for k, camera_shake in pairs(camera_shakes) do
			self.camera_shakes[k] = ActorTriggerCameraShake.New(camera_shake.eventName)
			self.camera_shakes[k]:Init(camera_shake)
			self.camera_shakes[k]:Enalbed(self.enable_camera_shake)
		end
	end
end

-- get/set
function ActorTrigger:EnableEffect(value)
	if value == nil then
		return self.enable_effect
	end
	if self.enable_effect ~= value then
		self.enable_effect = value
		for _, effect in pairs(self.effects) do
			effect:Enalbed(value)
		end
	end
end

-- get/set
function ActorTrigger:EnableEHalts(value)
	if value == nil then
		return self.enable_halt
	end
	if self.enable_halt ~= value then
		self.enable_halt = value
		for _, halt in pairs(self.halts) do
			halt:Enalbed(value)
		end
	end
end

-- get/set
function ActorTrigger:EnableCameraShake(value)
	if value == nil then
		return self.enable_camera_shake
	end
	if self.enable_camera_shake ~= value then
		self.enable_camera_shake = value
		for _, camera_shake in pairs(self.camera_shakes) do
			camera_shake:Enalbed(value)
		end
	end
end

function ActorTrigger:StopEffects()
	for _, effect in pairs(self.effects) do
		effect:StopEffects()
	end
end

function ActorTrigger:OnAnimatorEvent(param, state_info, source_obj, target_obj, anim_name)
	for _, effect in pairs(self.effects) do
		if effect.anima_name == anim_name then
			effect:OnAnimatorEvent(param, state_info, source_obj, target_obj, anim_name)
		end
	end

	for _, halt in pairs(self.halts) do
		if halt.anima_name == anim_name then
			halt:OnAnimatorEvent(param, state_info, source_obj, target_obj, anim_name)
		end
	end

	for _, sound in pairs(self.sounds) do
		if sound.anima_name == anim_name then
			sound:OnAnimatorEvent(param, state_info, source_obj, target_obj, anim_name)
		end
	end

	for _, camera_shake in pairs(self.camera_shakes) do
		if camera_shake.anima_name == anim_name then
			camera_shake:OnAnimatorEvent(param, state_info, source_obj, target_obj, anim_name)
		end
	end
end

