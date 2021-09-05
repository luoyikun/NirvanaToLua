local TypeTexture2D = typeof(UnityEngine.Texture2D)
local TypeRawImage = typeof(UnityEngine.UI.RawImage)

local M = {}
local RAW_IMAGE_LOADERS = {}

function M.EnableLoadRawImageEvent(enabled_list)
	for i = 0, enabled_list.Count - 1 do
		local load_raw_image = enabled_list[i]
		if not IsNil(load_raw_image) then
			local bundle_name, asset_name = load_raw_image.BundleName, load_raw_image.AssetName

			local raw_image = load_raw_image.gameObject:GetComponent(TypeRawImage)
			if raw_image and bundle_name and bundle_name ~= "" and
				asset_name and asset_name ~= "" then
				
				if nil == raw_image.texture then
					local loader = M.AllocLoader(load_raw_image)
					loader:Load(bundle_name, asset_name, TypeTexture2D, function(texture)
						if texture then
							raw_image.enabled = true
							load_raw_image:SetTexture(texture)
						end
					end)
				else
					raw_image.enabled = true
				end
			end
		end
	end
end

function M.DisableLoadRawImageEvent(disabled_list)
end

function M.DestroyLoadRawImageEvent(destroyed_list)
	for i = 0, destroyed_list.Count - 1 do
		DestroyResLoader(M, "id_" .. destroyed_list[i])
	end
end

function M.AllocLoader(load_raw_image)
	return AllocResAsyncLoader(M, "id_" .. load_raw_image:GetInstanceID())
end

LoadRawImageEventhandle = M

