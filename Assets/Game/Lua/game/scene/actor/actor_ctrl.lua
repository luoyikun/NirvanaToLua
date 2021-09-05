ActorCtrl = ActorCtrl or BaseClass()

local TypeProjectile = typeof(Projectile)
local TypeEffectControl = typeof(EffectControl)

local HurtPositionEnum = {
	Root = 0,
	HurtPoint = 1,
}

local HurtRotationEnum = {
	Target = 0,
	HitDirection = 1,
}

function ActorCtrl:__init(actor_triggers)
	self.actor_triggers = actor_triggers
end

function ActorCtrl:__delete()
	self.actor_triggers = nil
	self.is_deleted = true
end

function ActorCtrl:StopEffects()
	if self.actor_triggers then
		self.actor_triggers:StopEffects()
		self.actor_triggers = nil
	end
end

function ActorCtrl:SetPrefabData(data)
	self.prefab_data = data
end

function ActorCtrl:GetPrefabData()
	return self.prefab_data
end

function ActorCtrl:PlayProjectile(main_part_obj, action, root, hurt_point, hited)
	local prefab_data = self:GetPrefabData()
	local find = false
	if prefab_data ~= nil and prefab_data.actorController ~= nil then
		local projectiles = prefab_data.actorController.projectiles
		for k, projectile in pairs(projectiles) do
			if projectile.Action == action and next(projectile.Projectile) ~= nil then
				self:PlayProjectileImpl(main_part_obj, projectile, root, hurt_point, hited, k)
				find = true
				break
			end
		end
	end

	if not find then
		if hited then
			hited()
		end
	end
end

function ActorCtrl:PlayProjectileImpl(main_part_obj, projectile, root, hurt_point, hited, key)
	if self.actor_triggers and self.actor_triggers:EnableEffect() and main_part_obj then
		local from_transform = nil
		local from_position = nil
		-- if projectile.HurtPosition == HurtPositionEnum.HurtPoint then
			if projectile.FromPosHierarchyPath ~= nil and projectile.FromPosHierarchyPath ~= "" then
				from_transform = main_part_obj.transform:Find(projectile.FromPosHierarchyPath)
			end
			from_transform = from_transform or main_part_obj.transform
			from_position = from_transform.position

			-- from_position = hurt_point.transform.position
		-- end
		if projectile.DelayProjectileEff <= 0 then
			self:PlayProjectileWithEffect(main_part_obj, projectile, hurt_point, from_position, hited, key)
		else
			local start_time = UnityEngine.Time.unscaledTime
			GlobalTimerQuest:AddDelayTimer(
				function()
					if self.is_deleted then
						return
					end
					self:PlayProjectileWithEffect(main_part_obj, projectile, hurt_point, from_position, hited, key)
				end, 
				projectile.DelayProjectileEff)
		end
	else
		self:PlayProjectileWithoutEffect(hited, key)
	end
end

function ActorCtrl:PlayProjectileWithEffect(main_part_obj, projectile, hurt_point, fromPosition, hited, key)
	local asset_name = projectile.Projectile.AssetName
	local bundle_name = projectile.Projectile.BundleName
	if not asset_name or not bundle_name or asset_name == "" or bundle_name == "" then
		return
	end

	local async_loader = AllocAsyncLoader(self, "projectile" .. key)
	async_loader:SetIsUseObjPool(true)
	async_loader:SetObjAliveTime(5) --防止永久存在
	async_loader:Load(bundle_name, asset_name, function(obj)
		if IsNil(obj) then
			return
		end

		if nil == main_part_obj or IsNil(main_part_obj.transform) then
			async_loader:Destroy()
			return
		end

		local instance = obj:GetComponent(TypeProjectile)
		if instance == nil then
			async_loader:Destroy()
			print_warning("lua:PlayProjectileWithEffect not exist Projectile")
			if hited then
				hited()
			end
			return
		end

		if not IsNil(hurt_point) and hurt_point.transform then
			local direction = fromPosition - hurt_point.transform.position
			direction.y = 0
			if direction ~= Vector3.zero then
				instance.transform:SetPositionAndRotation(fromPosition, Quaternion.LookRotation(direction))
			end
		else
			instance.transform.position = fromPosition
		end

		if IsNil(hurt_point) or IsNil(hurt_point.transform) then
			async_loader:Destroy()
			return
		end

		instance.transform.localScale = main_part_obj.transform.lossyScale
		instance.gameObject:SetLayerRecursively(main_part_obj.gameObject.layer)
		
		instance:Play(
			main_part_obj.transform.lossyScale,
			hurt_point.transform,
			main_part_obj.gameObject.layer,
			function ()
				if hited then
					hited()
				end
			end,
			function ()
				async_loader:SetObjAliveTime(projectile.DeleProjectileDelay)
			end)
	end)

end

function ActorCtrl:PlayProjectileWithoutEffect(hited)
	local callback = function ()
	 	if self.is_deleted then
	 		return
	 	end

		if hited then
			hited()
		end
	end

	GlobalTimerQuest:AddDelayTimer(callback, 0.5)
end

function ActorCtrl:PlayHurtShow(skillAction, root, hurtPoint, perHit)
	local found = false
	local prefab_data = self:GetPrefabData()
	if prefab_data ~= nil and prefab_data.actorController ~= nil then
		local hurts = prefab_data.actorController.hurts
		for _, hurt in pairs(hurts) do
			if hurt.Action == skillAction then
				if next(hurt.HurtEffect) ~= nil then
					self:PlayHurtEffect(hurt, root, hurtPoint)
				end

				if hurt.HitCount > 0 then
					self:PlayHitEffect(hurt, root, hurtPoint, perHit)
				else
					if perHit then
						perHit()
					end
				end
				found = true
				break
			end
		end
	end

	if not found then
		if perHit then
			perHit()
		end
	end
end

function ActorCtrl:PlayHurtEffect(data, root, hurtPoint)
	local asset_name = data.HurtEffect.AssetName
	local bundle_name = data.HurtEffect.BundleName

	local async_loader = AllocAsyncLoader(self, "hurt_effect")
	async_loader:SetIsUseObjPool(true)
	async_loader:SetObjAliveTime(5)
	async_loader:Load(bundle_name, asset_name, function(obj)
		if nil == obj then
			return
		end

		local instance = obj:GetOrAddComponent(TypeEffectControl)
		if instance == nil then
			async_loader:Destroy()
			return
		end
		instance:Reset()
		instance.enabled = true

		local targetPos = root
		if data.HurtPosition == HurtPositionEnum.HurtPoint then
			targetPos = hurtPoint
		end

		if data.HurtRotation == HurtRotationEnum.Target then
			instance.transform:SetPositionAndRotation(targetPos.position, targetPos.rotation)
		else
			local direction = targetPos.position - obj.transform.position
			direction.y = 0
			if direction ~= Vector3.zero then
				instance.transform:SetPositionAndRotation(targetPos.position, Quaternion.LookRotation(direction))
			end
		end

		instance:WaitFinsh(function()
			async_loader:Destroy()
		end)

		instance:Play()
	end)
end

function ActorCtrl:PlayHitEffect(data, root, hurtPoint, perHit)
	if root == nil or hurtPoint == nil then
		return
	end

	local asset_name = data.HitEffect.AssetName
	local bundle_name = data.HitEffect.BundleName

	function LoadEffectRes(index)
		local async_loader = AllocAsyncLoader(self, "hit_effect" .. index)
		async_loader:SetIsUseObjPool(true)
		async_loader:SetObjAliveTime(5)
		async_loader:Load(bundle_name, asset_name, function(obj)
			if nil == obj then
				return
			end

			local instance = obj:GetOrAddComponent(TypeEffectControl)
			if instance == nil then
				async_loader:Destroy()
				return
			end

			instance:Reset()
			instance.enabled = true

			local targetPos = root
			if data.HurtPosition == HurtPositionEnum.HurtPoint then
				targetPos = hurtPoint
			end

			if data.HurtRotation == HurtRotationEnum.Target then
				instance.transform:SetPositionAndRotation(targetPos.position, targetPos.rotation)
			else
				local direction = targetPos.position - this.transform.position
				direction.y = 0
				if direction ~= Vector3.zero then
					instance.transform:SetPositionAndRotation(targetPos.position, Quaternion.LookRotation(direction))
				end
			end

			instance:WaitFinsh(function()
				async_loader:Destroy()
			end)
			instance:Play()
		end)
	end

	for i = 0, data.HitCount - 1 do
		if next(data.HitEffect) ~= nil then
			if i <= 0 then
				LoadEffectRes(i)
			else
				GlobalTimerQuest:AddDelayTimer(function()
					if self.is_deleted then
						return
					end
					LoadEffectRes()
				end, data.HitInterval)
			end
		end

		if perHit then
			perHit()
		end
	end
end

function ActorCtrl:PlayHurt(skillAction, perHit)
	local found = false
	local prefab_data = self:GetPrefabData()
	if prefab_data ~= nil and prefab_data.actorController ~= nil then
		local hurts = prefab_data.actorController.hurts
		for _, hurt in pairs(hurts) do
			if hurt.Action == skillAction then
				if hurt.HitCount > 0 then
					self:PlayHit(hurt, perHit)
				else
					perHit(1)
				end
				found = true
				break
			end
		end
	end

	if not found then
		perHit(1)
	end
end

function ActorCtrl:PlayHit(data, perHit)
	local random = {}
	local total = 0
	local hit_count = data.HitCount
	local hit_interval = data.HitInterval

	for i = 0, hit_count - 1 do
		random[i] = math.random(10, 99)
		total = total + random[i]
	end

	if total <= 0 then
		return
	end

	function SubHit(i)
		if total > 0 then
			local percent = random[i] / total
			perHit(percent)
		end
	end

	for i = 0, hit_count - 1 do
		GlobalTimerQuest:AddDelayTimer(function() 
			if self.is_deleted then
				return
			end
			SubHit(i) 
		end, hit_interval)
	end
end

function ActorCtrl:PlayBeHurt(root)
	local prefab_data = self:GetPrefabData()
	if prefab_data ~= nil and prefab_data.actorController ~= nil then
		local be_hurt_effecct = prefab_data.actorController.beHurtEffecct
		if be_hurt_effecct and nil ~= next(be_hurt_effecct) then
			local asset_name = be_hurt_effecct.AssetName
			local bundle_name = be_hurt_effecct.BundleName
			if asset_name and bundle_name and asset_name ~= "" and bundle_name ~= "" then
				self:PlayBeHitEffect(asset_name, bundle_name, root, be_hurt_effecct.beHurtPosition, be_hurt_effecct.beHurtAttach)
			end
		end
	end
end

function ActorCtrl:PlayBeHitEffect(asset_name, bundle_name, root, position, attached)
	local async_loader = AllocAsyncLoader(self, "behit_effect" .. index)
	async_loader:SetIsUseObjPool(true)
	async_loader:SetObjAliveTime(5)
	async_loader:Load(bundle_name, asset_name, function(obj)
		if nil == obj then
			return
		end

		local instance = obj:GetComponent(typeof(EffectControl))
		if instance == nil then
			async_loader:Destroy()
			return
		end

		instance:Reset()
		instance.enabled = true

		if position == nil then
			position = root.transform
		end

		if attached then
			instance.transform:SetParent(position, false)
		else
			instance.transform:SetPositionAndRotation(position.position, position.rotation)
		end

		instance:WaitFinsh(function()
			async_loader:Destroy()
		end)
		instance:Play()
	end)
end

function ActorCtrl:Blink(obj, fadeIn, fadeHold, fadeOut)
	-- local blink = obj.transform:GetOrAddComponent(typeof(ActorBlinker))
	-- blink:Blink(fadeIn, fadeHold, fadeOut)
end
