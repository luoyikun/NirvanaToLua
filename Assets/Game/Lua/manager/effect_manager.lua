EffectManager = EffectManager or BaseClass()

function EffectManager:__init()
	if EffectManager.Instance then
		print_error("EffectManager to create singleton twice")
	end
	EffectManager.Instance = self
end

function EffectManager:__delete()
	self.Instance = nil
end

function EffectManager:PlayAtTransform(bundle, asset, transform, duration, position, rotation, scale, call_back)
	ResPoolMgr:GetEffectAsync(bundle, asset, function(obj)
		if IsNil(obj) then
			return
		end
		if transform == nil or IsNil(transform) then
			ResPoolMgr:Release(obj)
			return
		end

		local canvas = transform:GetComponentInParent(typeof(UnityEngine.Canvas))
		if canvas == nil then
			ResPoolMgr:Release(obj)
			print_warning("PlayAtTransform transform is not in a canvas.", bundle, asset)
			return
		end
		
		if position ~= nil then
			obj.transform.position = position
		end

		if rotation ~= nil then
			obj.transform.rotation = rotation
		end

		if scale ~= nil then
			obj.transform.localScale = scale
		end

		obj.transform:SetParent(transform, false)

		local sorting_order = obj:GetOrAddComponent(typeof(SortingOrderOverrider))
		sorting_order.SortingOrder = canvas.sortingOrder + 3

		GlobalTimerQuest:AddDelayTimer(function()
			if call_back then
				call_back()
			end
			ResPoolMgr:Release(obj)
		end, duration)
	end)
end

function EffectManager:PlayAtTransformCenter(bundle, asset, transform, duration)
	self:PlayAtTransform(bundle, asset, transform, duration, transform:GetWorldCenter())
end

function EffectManager:PlayEffect(bundle, asset, transform, call_back, duration)
	ResPoolMgr:GetEffectAsync(bundle, asset, function(obj)
		if IsNil(obj) then
			return
		end
		if transform == nil or IsNil(transform) then
			ResPoolMgr:Release(obj)
			return
		end

		obj.transform:SetParent(transform, false)
		if call_back then
			call_back(obj)
		end
		if duration ~= nil then
			GlobalTimerQuest:AddDelayTimer(function()
				ResPoolMgr:Release(obj)
			end, duration)
		end

	end)
end

-- 播放带有EffectControl的特效
function EffectManager:PlayControlEffect(target, bundle, asset, position, deliverer_position, rotation, scale)
	target = target or self

	target.control_effect_counter = target.control_effect_counter or 0
	target.control_effect_counter = target.control_effect_counter + 1
	target.control_effect_counter = target.control_effect_counter % 50 -- 防止创建loader过多

	local async_loader = AllocAsyncLoader(target, "control_effect_loader_" .. target.control_effect_counter)
	async_loader:SetObjAliveTime(10) --防止永久存在
	async_loader:SetIsUseObjPool(true)
	async_loader:Load(bundle, asset, function(obj)
		if IsNil(obj) then
			return
		end

		obj.transform.position = position

		if deliverer_position then
			local direction = position - deliverer_position
			direction.y = 0
			if not (direction.x == 0 and direction.y == 0 and direction.z == 0) then
				obj.transform:SetPositionAndRotation(position, Quaternion.LookRotation(direction))
			else
				print_warning(obj.name, "LookRotation[0,0,0]")
			end
		end

		if rotation ~= nil and rotation ~= "" then
			obj.transform.rotation = rotation
		end

		if scale then
			obj.transform:SetLocalScale(scale, scale, scale)
		end
		
		local control = obj:GetOrAddComponent(typeof(EffectControl))
		if control == nil then
			async_loader:DeleteMe()
			print_warning("PlayControlEffect not exist EffectControl")
			return
		end

		control:Reset()
		control.enabled = true

		control:WaitFinsh(function()
			async_loader:DeleteMe()
		end)

		control:Play()
	end)
end
