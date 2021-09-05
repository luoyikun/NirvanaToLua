require("core/draw_part_render")
--加载人物透明和影子材质球
ResPreload = require("core.res_preload")
ResPreload.init()

DrawPart = DrawPart or BaseClass()

local NirvanaRenderer = typeof(NirvanaRenderer)
local UnitySkinnedMeshRenderer = typeof(UnityEngine.SkinnedMeshRenderer)
local UnityMeshRenderer = typeof(UnityEngine.MeshRenderer)
local UnityParticleSystem = typeof(UnityEngine.ParticleSystem)
local GeometryRendererQueue = 2000
local AlphaTestQueue = 2450
local UnityEngineLayerMask = UnityEngine.LayerMask
local ShadowCastingMode = UnityEngine.Rendering.ShadowCastingMode

function DrawPart:__init()
	self.obj = nil
	self.asset_bundle = nil
	self.asset_name = nil
	self.loading = false
	self.load_complete = nil
	self.remove_callback = nil

	self.visible = true
	self.parent = nil
	self.layer = 0
	self.click_listener = nil
	self.attach_requests = {}
	self.blink = false
	self.play_attach_effect = false

	self.animator_triggers = {}
	self.animator_bools = {}
	self.animator_ints = {}
	self.animator_floats = {}
	self.animator_listener = {}
	self.animator_layers = {}
	self.animator_plays = {}

	self.animator_handle = {}

	self.is_main_role = false
	self.enable_mount_up = false
	self.budget_vis = true
	self.is_visible = true
	self.part = 0

	self.add_occlusion_material_list = {}

	self.is_use_objpool = false
	self.is_optimize_material = false
	self.is_disable_all_attach_effects = false
	self.draw_part_render = DrawPartRender.New()
end

function DrawPart:__delete()
	self.draw_part_render:DeleteMe()

	for _, v in pairs(self.animator_handle) do
		v:Dispose()
	end
	self.animator_handle = {}

	self:RemoveModel()

	self.load_complete = nil
	self.remove_callback = nil
end

function DrawPart:DestoryObj(obj)
	if not IsNil(obj) then
		if self.is_use_objpool then
			self:RemoveOcclusion()

			ResPoolMgr:Release(obj)
		else
			ResMgr:Destroy(obj)
		end
	end
end

function DrawPart:SetYinShenMaterial(change_material, prof)
	if change_material then
		self:RemoveOcclusion()
		self.draw_part_render:SetRenderMaterial(ResPreload["role_ghost_" .. prof or 1])
	else
		self:RemoveOcclusion()
		self.draw_part_render:SetIsLowMaterial(self.is_optimize_material, true)
		self:AddOcclusion()
	end
end

function DrawPart:SetIsUseObjPool(is_use_objpool)
	self.is_use_objpool = is_use_objpool
end

function DrawPart:SetIsOptimizeMaterial(is_optimize_material)
	self.is_optimize_material = is_optimize_material
end

function DrawPart:SetIsDisableAllAttachEffects(is_disable_all_attach_effects)
	self.is_disable_all_attach_effects = is_disable_all_attach_effects
end

function DrawPart:SetBudgetVis(visible)
	self.budget_vis = visible
	self:SetVisible()
end

function DrawPart:SetVisible(visible, callback)
	if visible ~= nil then
		self.is_visible = visible
	end
	visible = self.is_visible and self.budget_vis
	if visible then
		if self.obj == nil and
			self.asset_bundle ~= nil and
			self.asset_name ~= nil then
			local asset_bundle = self.asset_bundle
			local asset_name = self.asset_name
			self.asset_bundle = nil
			self.asset_name = nil
			self:ChangeModel(asset_bundle, asset_name, callback)
		end
	else
		if self.obj ~= nil then
			if self.remove_callback ~= nil then
				self.remove_callback(self.obj)
			end
			self:Reset()

			self:DestoryObj(self.obj.gameObject)
			self.obj = nil
		end
	end
end

function DrawPart:SetParent(parent)
	self.parent = parent
	if self.obj ~= nil then
		self:_FlushParent(self.obj)
	end
end

function DrawPart:SetGameLayer(layer)
	self.layer = layer

	if self.obj ~= nil then
		self:_FlushGameLayer(self.obj)
	end
end

function DrawPart:ListenClick(listener)
	self.click_listener = listener
	if self.obj ~= nil then
		self:_FlushClickListener(self.obj)
	end
end

function DrawPart:SetTrigger(key)
	if self.obj ~= nil and not IsNil(self.obj.animator) then
		if self.obj.animator and self.obj.animator.isActiveAndEnabled then
			self.obj.animator:SetTrigger(key)
		end
	elseif self.visible then
		self.animator_triggers[key] = true
	end
end

function DrawPart:SetBool(key, value)
	self.animator_bools[key] = value
	if self.obj ~= nil and not IsNil(self.obj.animator) then
		if self.obj.animator and self.obj.animator.isActiveAndEnabled then
			self.obj.animator:SetBool(key, value)
		end
	end
end

function DrawPart:GetBool(key)
	if self.obj ~= nil and not IsNil(self.obj.animator) then
		if self.obj.animator and self.obj.animator.isActiveAndEnabled then
			return self.obj.animator:GetBool(key)
		end
	end
end

function DrawPart:SetInteger(key, value)
	self.animator_ints[key] = value
	if self.obj ~= nil and not IsNil(self.obj.animator) then
		if self.obj.animator and self.obj.animator.isActiveAndEnabled then
			self.obj.animator:SetInteger(key, value)
		end
	end
end

function DrawPart:GetInteger(key)
	if self.obj ~= nil and not IsNil(self.obj.animator) then
		if self.obj.animator and self.obj.animator.isActiveAndEnabled then
			return self.obj.animator:GetInteger(key)
		end
	end
end

function DrawPart:SetFloat(key, value)
	self.animator_floats[key] = value
	if self.obj ~= nil and not IsNil(self.obj.animator) then
		if self.obj.animator and self.obj.animator.isActiveAndEnabled then
			self.obj.animator:SetFloat(key, value)
		end
	end
end

function DrawPart:SetLayer(layer, value)
	if self.obj ~= nil and not IsNil(self.obj.animator) then
		self.obj.animator:SetLayerWeight(layer, value)
	else
		self.animator_layers[layer] = value
	end
end

function DrawPart:Play(key, layer, value)
	self.animator_plays[key] = {layer = layer, value = value}
	if self.obj ~= nil and not IsNil(self.obj.animator) then
		self.obj.animator:Play(key, layer, value)
	end
end

function DrawPart:GetAnimationInfo(layer)
	layer = layer or ANIMATOR_PARAM.BASE_LAYER
	local animation_info = nil
	if self.obj ~= nil and not IsNil(self.obj.animator) then
		if self.obj.animator.isActiveAndEnabled then
			animation_info = self.obj.animator:GetCurrentAnimatorStateInfo(layer)
		end
	end
	return animation_info
end

function DrawPart:SetMainRole(is_main_role)
	self.is_main_role = is_main_role
end

function DrawPart:IsMainRole()
	return self.is_main_role
end

function DrawPart:EnableEffect(enabled)
end

function DrawPart:EnableHalt(enabled)

end

function DrawPart:EnableMountUpTrigger(enabled)
	self.enable_mount_up = enabled
	if self.obj ~= nil then
		local attachment = self.obj.actor_attachment
		if attachment ~= nil then
			attachment:SetMountUpTriggerEnable(enabled)
		end
	end
end

function DrawPart:GetEnabelMountUp()
	return self.enable_mount_up
end

function DrawPart:EnableSceneFade(enabled)
end

function DrawPart:EnableFootsteps(enabled)
end

function DrawPart:ListenEvent(event_name, callback)
	self:UnListenEvent(event_name)

	self.animator_listener[event_name] = callback
	if self.obj ~= nil and not IsNil(self.obj.animator) then
		self.animator_handle[event_name] = self.obj.animator:ListenEvent(event_name, callback)
	end
end

function DrawPart:UnListenEvent(event_name)
	self.animator_listener[event_name] = nil

	if nil ~= self.animator_handle[event_name] then
		self.animator_handle[event_name]:Dispose()
		self.animator_handle[event_name] = nil
	end
end

function DrawPart:Blink()

end

function DrawPart:PlayAttachEffect()
	if self.obj ~= nil then
		if nil ~= self.obj.actor_attach_effect then
			self.obj.actor_attach_effect:PlayEffect()
		end
	else
		self.play_attach_effect = true
	end
end

function DrawPart:GetAttachPoint(point)
	if self.obj == nil or IsNil(self.obj.gameObject) then
		return nil
	end

	local attachment = self.obj.actor_attachment
	if attachment == nil then
		return nil
	end

	return attachment:GetAttachPoint(point)
end

function DrawPart:RequestAttachment(complete)
	if self.obj ~= nil then
		local attachment = self.obj.actor_attachment
		if attachment ~= nil then
			complete(attachment)
		else
			complete(nil)
		end
	else
		table.insert(self.attach_requests, complete)
	end
end

function DrawPart:SetLoadComplete(complete, part)
	self.load_complete = complete
	self.part = part
end

function DrawPart:SetRemoveCallback(callback)
	self.remove_callback = callback
end


function DrawPart:GetObj()
	return self.obj
end

function DrawPart:ChangeModel(asset_bundle, asset_name, callback)
	if not self.visible then
		self.asset_bundle = asset_bundle
		self.asset_name = asset_name
		return
	end

	if self.asset_bundle == asset_bundle and
		self.asset_name == asset_name then
		return
	end

	self.asset_bundle = asset_bundle
	self.asset_name = asset_name
	if self.loading then
		return
	end

	self.load_callback = callback
	if self.asset_bundle ~= nil and self.asset_name ~= nil then
		self.loading = true
		self:LoadModel(self.asset_bundle, self.asset_name, false)
	elseif self.obj ~= nil then
		if self.remove_callback ~= nil then
			self.remove_callback(self.obj)
		end
		self:Reset()
		self:DestoryObj(self.obj.gameObject)
		self.obj = nil
	end
end

function DrawPart:RemoveModel()
	self.asset_bundle = nil
	self.asset_name = nil
	if self.obj ~= nil and not IsNil(self.obj.gameObject) then
		if self.remove_callback ~= nil then
			self.remove_callback(self.obj)
		end
		self:Reset()

		local attachment = self.obj.actor_attachment
		if attachment ~= nil then
			for i,v in ipairs(self.attach_requests) do
				v(nil)
			end
		end

		local actor_attach_effect = self.obj.actor_attach_effect
		if nil ~= actor_attach_effect then
			actor_attach_effect:StopEffect()
		end

		self:DestoryObj(self.obj.gameObject)
		self.obj = nil
	end
end

function DrawPart:Reset(obj)
	local object = nil
	if obj == nil then
		object = self.obj
	else
		if type(obj) == "userdata" then
			object = U3DObject(obj, obj.transform, self)
		else
			object = obj
		end
	end
	if object ~= nil then
		if object.attach_obj ~= nil then
			object.attach_obj:CleanAttached()
		end
		if object.attach_skin_obj ~= nil then
			object.attach_skin_obj:ResetBone()
		end
	end
end

function DrawPart:LoadModel(asset_bundle, asset_name, is_reload)
	if self.is_use_objpool then
		if self.is_main_role then
			if SceneObjPart.Main == self.part then
				ResPoolMgr:GetDynamicObjSync(asset_bundle, asset_name, BindTool.Bind(self._OnLoadComplete, self, asset_bundle, asset_name, is_reload))
			else
				ResPoolMgr:GetDynamicObjAsync(asset_bundle, asset_name, BindTool.Bind(self._OnLoadComplete, self, asset_bundle, asset_name, is_reload))
			end
		else
			ResPoolMgr:GetDynamicObjAsyncInQueue(asset_bundle, asset_name, BindTool.Bind(self._OnLoadComplete, self, asset_bundle, asset_name, is_reload))
		end
	else
		ResMgr:LoadGameobjAsync(
			asset_bundle,
			asset_name,
			BindTool.Bind(self._OnLoadComplete, self, asset_bundle, asset_name, is_reload))
	end
end

function DrawPart:_OnLoadComplete(asset_bundle, asset_name, is_reload, obj)
	if IsNil(obj) then
		self.loading = false
		print_warning("Load model failed: ", asset_bundle, asset_name)
		if is_reload then
			return
		end
	end

	if self.obj ~= nil then
		if self.remove_callback ~= nil then
			self.remove_callback(self.obj)
		end
		self:Reset()
		self:DestoryObj(self.obj.gameObject)
		self.obj = nil
	end

	if obj == nil or IsNil(obj) or self.asset_bundle ~= asset_bundle or
		self.asset_name ~= asset_name then
		if obj and not IsNil(obj) then
			self:Reset(obj)
			self:DestoryObj(obj)
		end
		if self.asset_bundle ~= nil and self.asset_name ~= nil then
			self:LoadModel(self.asset_bundle, self.asset_name, true)
		else
			self.loading = false
		end

		return
	end

	self.loading = false
	self.obj = U3DObject(obj, obj.transform, self)

	self.draw_part_render:SetActorRender(obj:GetOrAddComponent(typeof(ActorRender)))
	self.draw_part_render:SetIsLowMaterial(self.is_optimize_material)
	self.draw_part_render:SetIsDisableAllAttachEffects(self.is_disable_all_attach_effects)
	self.draw_part_render:SetIsCastShadow(self.is_main_role)
	
	self:AddOcclusion()
	self:_FlushParent(self.obj)
	self:_FlushClickListener(self.obj)
	self:_FlushGameLayer(self.obj)

	if self.play_attach_effect and self.obj.actor_attach_effect then
		self.obj.actor_attach_effect:PlayEffect()
		self.play_attach_effect = false
	end

	local attachment = self.obj.actor_attachment
	if attachment ~= nil then
		attachment:SetMountUpTriggerEnable(self.enable_mount_up)
		for i,v in ipairs(self.attach_requests) do
			v(attachment)
		end
	else
		for i,v in ipairs(self.attach_requests) do
			v(nil)
		end
	end
	self.attach_requests = {}

	local animator = self.obj.animator
	if animator ~= nil and animator.isActiveAndEnabled then
		for k,v in pairs(self.animator_triggers) do
			animator:SetTrigger(k)
		end
		self.animator_triggers = {}

		for k,v in pairs(self.animator_bools) do
			animator:SetBool(k, v)
		end

		for k,v in pairs(self.animator_ints) do
			animator:SetInteger(k, v)
		end

		for k,v in pairs(self.animator_floats) do
			animator:SetFloat(k, v)
		end

		for k,v in pairs(self.animator_layers) do
			animator:SetLayerWeight(k, v)
		end

		for k,v in pairs(self.animator_plays) do
			animator:Play(k, v.layer, v.value)
		end
		self.animator_layers = {}

		for k,v in pairs(self.animator_listener) do
			if nil ~= self.animator_handle[k] then
				self.animator_handle[k]:Dispose()
				self.animator_handle[k] = nil
			end

			self.animator_handle[k] = self.obj.animator:ListenEvent(k, v)
		end
	end

	local visible = self.is_visible and self.budget_vis
	self:SetVisible(visible)
	if not visible then
		return
	end

	if self.load_complete then
		self.load_complete(self.obj, self.part, self)
	end

	if self.load_callback then
		self.load_callback(obj)
		self.load_callback = nil
	end
end

function DrawPart:_FlushParent(obj)
	if self.parent ~= nil then
		obj.transform:SetParent(self.parent.transform, false)
	else
		obj.transform:SetParent(nil)
	end
end

function DrawPart:_FlushGameLayer(obj)
	local children = self.obj.gameObject:GetComponentsInChildren(typeof(UnityEngine.Transform))
	local layer = nil
	if self.layer ~= nil then
		layer = self.layer
	else
		layer = UnityEngineLayerMask.NameToLayer("Default")
	end
	for i = 0, children.Length - 1 do
		local child = children[i].gameObject
		if child then
			if child.layer ~= UnityEngineLayerMask.NameToLayer("Clickable") then
				child.layer = layer
			end
		end
	end
end

function DrawPart:OnClickListener()
	if self.click_listener ~= nil then
		self.click_listener()
	end
end

function DrawPart:_FlushClickListener(obj)
	local clickable = obj.clickable_obj
	if clickable == nil then
		return
	end

	if self.click_listener ~= nil then
		clickable:SetClickListener(self.click_listener)
		clickable:SetClickable(true)
	else
		clickable:SetClickListener(nil)
		clickable:SetClickable(false)
	end
end

function DrawPart:AddOcclusion()
	if self.is_main_role and self.obj then
		local occlusion_obj = self.obj:GetComponent(typeof(OcclusionObject))
		if occlusion_obj then
			local itmes = occlusion_obj.Items
			local length = itmes.Length
			for i = 0, length - 1 do
				local item = itmes[i]
				local skinned_mesh = item.renderer:GetComponent(UnitySkinnedMeshRenderer)
				if skinned_mesh then
					self:AddMaterial(skinned_mesh, item.occlusionMaterial)
				end
			end
		else
			self:AddOcclusionMaterial(self.obj:GetComponentsInChildren(UnitySkinnedMeshRenderer), false)
			self:AddOcclusionMaterial(self.obj:GetComponentsInChildren(UnityMeshRenderer), true)
		end
	end
end

function DrawPart:RemoveOcclusion()
	if self.is_main_role and self.obj then
		local occlusion_obj = self.obj:GetComponent(typeof(OcclusionObject))
		if occlusion_obj then
			local itmes = occlusion_obj.Items
			local length = itmes.Length
			for i = 0, length - 1 do
				local item = itmes[i]
				local skinned_mesh = item.renderer:GetComponent(UnitySkinnedMeshRenderer)
				if skinned_mesh then
					self:RemoveMaterial(skinned_mesh, item.occlusionMaterial)
				end
			end
		else
			self:RemoveOcclusionMaterial(self.obj:GetComponentsInChildren(UnitySkinnedMeshRenderer), false)
			self:RemoveOcclusionMaterial(self.obj:GetComponentsInChildren(UnityMeshRenderer), true)
		end
	end
end

function DrawPart:AddMaterial(renderer, occlusion_material, skip_particle_system)
	if not self.add_occlusion_material_list[renderer] and nil ~= renderer and nil ~= renderer.gameObject and not IsNil(renderer.gameObject) then
		if not skip_particle_system or renderer:GetComponent(UnityParticleSystem) == nil then
			-- 神魔变身不知道为什么结束后也会进来添加给人物脚下影子
			local obj_name = renderer.gameObject.name
			if obj_name == "ObjShadow(Clone)" or obj_name == "ObjShadow" then
				return
			end

			local nirvana_renderer = renderer.gameObject:GetComponent(NirvanaRenderer)
			local materials

			if nirvana_renderer then
				materials = nirvana_renderer.Materials
			else
				materials = renderer.materials
			end

			if nil == materials then return end

			local new_materials = {}
			local len = materials.Length
			if len > 0 then
				for j = 0, len - 1 do
					local material = materials[j]
					if material then
 						table.insert(new_materials, material)
						if material.renderQueue < AlphaTestQueue then
							material.renderQueue = GeometryRendererQueue + 2    --2000+2
						end
					end
				end
				table.insert(new_materials, occlusion_material)
				if nirvana_renderer then
					nirvana_renderer.Materials = new_materials
				else
					renderer.materials = new_materials
				end
				self.add_occlusion_material_list[renderer] = true
			end
		end
	end
end

function DrawPart:AddOcclusionMaterial(renderers, skip_particle_system)
	if renderers ~= nil then
		for i = 0, renderers.Length - 1 do
			local renderer = renderers[i]
			self:AddMaterial(renderer, ResPreload.role_occlusion, skip_particle_system)
		end
	end
end

function DrawPart:RemoveMaterial(renderer, occlusion_material, skip_particle_system)
	if self.add_occlusion_material_list[renderer] and nil ~= renderer and nil ~= renderer.gameObject and not IsNil(renderer.gameObject) then
		if not skip_particle_system or renderer:GetComponent(UnityParticleSystem) == nil then
			local nirvana_renderer = renderer.gameObject:GetComponent(NirvanaRenderer)
			local materials

			if nirvana_renderer then
				materials = nirvana_renderer.Materials
			else
				materials = renderer.materials
			end

			if nil == materials then return end

			local new_materials = {}
			local len = materials.Length

			if len > 1 then
				for j = 0, len - 2 do
					local material = materials[j]
					if material then
						table.insert(new_materials, material)
					end
				end
				if nirvana_renderer then
					nirvana_renderer.Materials = new_materials
				else
					renderer.materials = new_materials
				end
				self.add_occlusion_material_list[renderer] = nil
			end
		end
	end
end

function DrawPart:RemoveOcclusionMaterial(renderers, skip_particle_system)
	if renderers ~= nil then
		for i = 0, renderers.Length - 1 do
			local renderer = renderers[i]
			self:RemoveMaterial(renderer, ResPreload.role_occlusion, skip_particle_system)
		end
	end
end

function DrawPart:PlayEffect()
	PlayEffect(self)
end

function DrawPart:StopEffect()
	StopEffect(self)
end