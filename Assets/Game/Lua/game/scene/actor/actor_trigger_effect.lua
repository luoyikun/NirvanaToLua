ActorTriggerEffect = ActorTriggerEffect or BaseClass(ActorTriggerBase)

function ActorTriggerEffect:__init(anima_name, layer)
	self.anima_name = anima_name
	self.layer = layer
	self.transform = nil
	self.enabled = true
	self.target = nil

	self.effect_data = nil
end

function ActorTriggerEffect:__delete()
	self.effect_data = nil
end

-- 初始化预制体保存的配置数据(单个)
function ActorTriggerEffect:Init(effect_data)
	self.effect_data = effect_data
	self.delay = effect_data.triggerDelay
end

-- get/set
function ActorTriggerEffect:Enalbed(value)
	if value == nil then
		return self.enabled
	end
	self.enabled = value
end

function ActorTriggerEffect:OnEventTriggered(source, target, source_obj, target_obj, stateInfo)
	if self.enabled then
		self:OnEventTriggeredImpl(source, target, source_obj, target_obj, stateInfo)
	end
end

function ActorTriggerEffect:OnEventTriggeredImpl(source, target, source_obj, target_obj, stateInfo)
	local effect_data = self.effect_data
	if not effect_data then
		return
	end
	if effect_data.effectAsset and nil == next(effect_data.effectAsset) then
		return
	end
	-- Find the reference node.
	local reference = nil
	local deliverer = nil

	local reference_node = nil
	if effect_data.referenceNodeHierarchyPath ~= nil and effect_data.referenceNodeHierarchyPath ~= "" then
		reference_node = target.transform:Find(effect_data.referenceNodeHierarchyPath)
	end
	reference_node = reference_node or source.transform

	if effect_data.playerAtTarget then
		reference = target.transform
		deliverer = reference_node
	else
		reference = reference_node
		deliverer = reference_node
	end
	if reference == nil or deliverer == nil then
		return
	end

	local bundle_name = effect_data.effectAsset.BundleName
	local asset_name = effect_data.effectAsset.AssetName
	
	local async_loader = AllocAsyncLoader(self, "actor_trigger_effect")
	async_loader:SetIsUseObjPool(true)
	async_loader:SetObjAliveTime(5) --防止永久存在
	async_loader:Load(bundle_name, asset_name, function(obj)
		if IsNil(obj) then
			return
		end

		if self.layer then
			obj:SetLayerRecursively(self.layer)
		end
		
		local effect = obj:GetComponent(typeof(EffectControl))
		if effect == nil then
			async_loader:Destroy()
			return
		end

		if not IsNil(reference) and not IsNil(deliverer) then
			if effect_data.isAttach then
				effect.transform:SetParent(reference)
				if effect_data.isRotation then
					local direction = reference.position - deliverer.position
					direction.y = 0
					local temp_rotation = Vector3.zero
					if direction ~= Vector3.zero then
						temp_rotation = Quaternion.LookRotation(direction)
					end
					effect.transform:SetPositionAndRotation(reference.position, temp_rotation)
				else
					effect.transform.localPosition = Vector3.zero
					effect.transform.localRotation = Quaternion.identity
				end
				effect.transform.localScale = reference.localScale
			else
				effect.transform:SetPositionAndRotation(reference.position, reference.rotation)
				if effect.IsNoScalable then
					effect.transform.localScale = source.transform.lossyScale
				else
					effect.transform.localScale = reference.lossyScale
				end
			end
		end

		effect:Reset()
		effect:WaitFinsh(function()
			async_loader:Destroy()
		end)

		effect.enabled = true
		effect:Play()
	end)
end