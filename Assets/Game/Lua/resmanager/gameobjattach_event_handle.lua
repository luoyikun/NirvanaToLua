local M = {}
local GAME_OBJ_LOADERS = {}

function M.EnableGameObjAttachEvent(enabled_list)
	for i = 0, enabled_list.Count - 1 do
		local game_obj_attach = enabled_list[i]
		if not IsNil(game_obj_attach) then
			local bundle_name, asset_name = game_obj_attach.BundleName, game_obj_attach.AssetName

			if bundle_name and bundle_name ~= "" and
				asset_name and asset_name ~= "" then

				local loader = M.AllocLoader(game_obj_attach)
				loader:SetIsInQueueLoad(true)
				loader:SetIsUseObjPool(true)
				local loaded = false
				local is_uieffect_layer = false

				if game_obj_attach.IsSyncLayer then
					local layer = game_obj_attach.gameObject.layer
					if layer ~= 0 then
						loader:Load(bundle_name, asset_name, function(obj)
							if obj and obj:GetComponentInChildren(typeof(UnityEngine.TrailRenderer)) then
								obj:GetOrAddComponent(typeof(TrailRendererController))
							end

							if obj:GetComponentInChildren(typeof(UIEffect)) then
								is_uieffect_layer = true
							end

							if not is_uieffect_layer then
								obj:SetLayerRecursively(layer)
								EffectOrderGroup.RefreshRenderOrder(obj)
							end
						end)

						loaded = true
					end
				end

				if not loaded then
					loader:Load(bundle_name, asset_name, function(obj)
						if obj and obj:GetComponentInChildren(typeof(UnityEngine.TrailRenderer)) then
							obj:GetOrAddComponent(typeof(TrailRendererController))
						end

						if nil == obj:GetComponentInChildren(typeof(UIEffect)) then
							EffectOrderGroup.RefreshRenderOrder(obj)
						end
					end)
				end
			end
		end
	end
end

-- 这里传的是gameobjattach
function M.DisableGameObjAttachEvent(disabled_list)
	for i = 0, disabled_list.Count - 1 do
		local game_obj_attach = disabled_list[i]
		if nil ~= game_obj_attach then
			DelGameObjLoader(M, "id_" .. game_obj_attach:GetInstanceID())
		end
	end
end

-- 这里传的是instance_id
function M.DestroyGameObjAttachEvent(destroyed_list)
	for i = 0, destroyed_list.Count - 1 do
		DelGameObjLoader(M, "id_" .. destroyed_list[i])
	end
end

function M.AllocLoader(game_obj_attach)
	local loader = AllocAsyncLoader(M, "id_" .. game_obj_attach:GetInstanceID())
	loader:SetParent(game_obj_attach.transform)
	return loader
end

GameObjAttachEventHandle = M

return M
