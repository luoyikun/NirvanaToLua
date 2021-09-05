local M = {}

local UnityRuntime = UnityEngine.RuntimePlatform
local UnityApplication = UnityEngine.Application

if UNITY_IOS then
	if not UNITY_EDITOR then
		-- M.update_dir = UnityApplication.persistentDataPath .. "/Library/update/"
		-- M.download_dir = UnityApplication.persistentDataPath .. "/Library/download/"
		M.package_dir = UnityApplication.streamingAssetsPath .. '/assetbundles/'
	else
		-- M.update_dir = UnityApplication.persistentDataPath .. "/update/"
		-- M.download_dir = UnityApplication.persistentDataPath .. "/download/"
		M.package_dir = UnityApplication.streamingAssetsPath .. '/assetbundles/'
	end
elseif UNITY_ANDROID and not UNITY_EDITOR then
	-- M.update_dir = UnityApplication.persistentDataPath .. "/update/"
	-- M.download_dir = UnityApplication.persistentDataPath .. "/download/"
	M.package_dir = UnityApplication.dataPath .. "!assets/assetbundles/"
else
	-- M.update_dir = UnityApplication.persistentDataPath .. "/update/"
	-- M.download_dir = UnityApplication.persistentDataPath .. "/download/"
	M.package_dir = UnityApplication.streamingAssetsPath .. '/assetbundles/'
end

return M

