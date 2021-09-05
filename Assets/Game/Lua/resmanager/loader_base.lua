local ResUtil = require "resmanager/res_util"
local SceneLoader = require "resmanager/scene_loader"
local FileDownloader = require "resmanager/file_downloader"
local FileInfo = require "resmanager/file_info"

local SysUri = System.Uri

local UnityLoadSceneMode = UnityEngine.SceneManagement.LoadSceneMode
local SceneSingleLoadMode = UnityLoadSceneMode.Single
local SceneAdditiveLoadMode = UnityLoadSceneMode.Additive

local UnityGameObject = UnityEngine.GameObject
local UnityDontDestroyOnLoad = UnityGameObject.DontDestroyOnLoad
local UnityInstantiate = UnityGameObject.Instantiate

local _tinsert = table.insert
local _sformat = string.format

local M = ResUtil.create_class()

function M:_init()
	self.v_lua_manifest_info = {bundleInfos = {}}
	self.v_manifest_info = {bundleInfos = {}}
	self.v_scene_loader_tbl = {}
	self.v_scene_loader = SceneLoader:new()

	self.is_ignore_hash_check = true
end

function M:Update(time, delta_time)
	if self.v_scene_loader then
		self.v_scene_loader:Update()
	end

	for _, scene_loader in ipairs(self.v_scene_loader_tbl) do
		scene_loader:Update()
	end

	if AudioManager then
		AudioManager.Update()
	end
end

function M:CreateEmptyGameObj(name, dont_destroy)
	local gameobj = UnityGameObject()

	if name then
		gameobj.name = name
	end

	if dont_destroy then
		self:DontDestroyOnLoad(gameobj)
	end

	return gameobj
end

function M:DontDestroyOnLoad(gameobj)
	UnityDontDestroyOnLoad(gameobj)
end

function M:Instantiate(res, dont_destroy)
	local go = UnityInstantiate(res)

	if dont_destroy then
		self:DontDestroyOnLoad(go)
	end
	
	return go
end

function M:Destroy(gameobj)
	assert(nil)
end

function M:OnHotUpdateLuaComplete()
end

function M:LoadUnitySceneAsync(bundle_name, asset_name, load_mode, callback)
	assert(nil)
end

function M:LoadUnitySceneSync(bundle_name, asset_name, load_mode, callback)
	assert(nil)
end

function M:LoadLocalLuaManifest(name)
	assert(nil)
end

function M:LoadRemoteLuaManifest(callback)
	assert(nil)
end

function M:LoadLocalManifest(name)
	assert(nil)
end

function M:LoadRemoteManifest(name, callback)
	assert(nil)
end

function M:GetAllLuaManifestBundles()
    return {}
end

function M:GetAllManifestBundles()
    return {}
end

function M:LoadLevelSync(bundle_name, asset_name, load_mode, callback)
	if load_mode == SceneSingleLoadMode then
		self:_DestroyLoadingScenes()

		self.v_scene_loader:LoadLevelSync(bundle_name, asset_name, load_mode, callback)
	else
		local scene_loader = SceneLoader:new()
		_tinsert(self.v_scene_loader_tbl, scene_loader)
		scene_loader:LoadLevelSync(bundle_name, asset_name, load_mode, callback)
	end
end

function M:LoadLevelAsync(bundle_name, asset_name, load_mode, callback)
	if load_mode == SceneSingleLoadMode then
		self:_DestroyLoadingScenes()

		self.v_scene_loader:LoadLevelAsync(bundle_name, asset_name, load_mode, callback)
	else
		local scene_loader = SceneLoader:new()
		_tinsert(self.v_scene_loader_tbl, scene_loader)
		scene_loader:LoadLevelAsync(bundle_name, asset_name, load_mode, callback)
	end
end

function M:_DestroyLoadingScenes()
	self.v_scene_loader:Destroy()
	
	for _, scene_loader in ipairs(self.v_scene_loader_tbl) do
		scene_loader:Destroy()
	end

	self.v_scene_loader_tbl = {}
end

function M:UpdateBundle(bundle_name, update_delegate, complete)
	assert(nil)
end

function M:GetBundlesWithoutCached(bundle_name)
	assert(nil)
end

function M:GetManifestInfo()
	return self.v_manifest_info
end

function M:IsLuaVersionCached(bundle_name)
	local hash = nil
	if nil ~= self.v_lua_manifest_info.bundleInfos[bundle_name] then
		hash = self.v_lua_manifest_info.bundleInfos[bundle_name].hash
	end
	
	return ResUtil.IsFileExist("LuaAssetBundle/".. bundle_name, hash)
end

function M:SetAssetLuaVersion(asset_lua_version)
	self.v_asset_lua_version = asset_lua_version
end

function M:GetAssetLuaVersion()
	return self.v_asset_lua_version
end

function M:IsVersionCached(bundle_name, hash)
	if nil == hash and nil ~= self.v_manifest_info.bundleInfos[bundle_name] then
		hash = self.v_manifest_info.bundleInfos[bundle_name].hash
	end

	return ResUtil.IsFileExist(bundle_name, hash)
end

function M:SetAssetVersion(asset_version)
	self.v_asset_version = asset_version
end

function M:GetAssetVersion()
	return self.v_asset_version
end

function M:SetDownloadingURL(downloading_url)
	if downloading_url == nil then
		print_error("[LoaderBase] set downloading_url is nil")
		return
	end

	print_log("set donwloading url:", downloading_url)
	self.v_downloading_url = downloading_url
	self.is_ignore_hash_check = false
end

function M:GetDownloadingURL()
	return self.v_downloading_url
end

function M:GetRemotePath(bundle_name, version)
	return SysUri.EscapeUriString(_sformat("%s/%s?v=%s", self.v_downloading_url, bundle_name, version))
end

function M:GetIsIgnoreHashCheck()
	return self.is_ignore_hash_check
end

function M:GetLuaHashCode()
	return ""
end

function M:GetHashCode()
	return ""
end

function M:IsBundleMode()
	return false
end

function M.ExistedInStreaming(path)
	return ResUtil.ExistedInStreaming(path)
end

return M

