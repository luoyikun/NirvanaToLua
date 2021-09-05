local ResUtil = require "resmanager/res_util"
local Base = require "resmanager/loader_base"
local libbit = require "bit"
local BundleCache = require "resmanager/bundle_cache"

local UnityApplication = UnityEngine.Application
local UnityGameObject = UnityEngine.GameObject
local UnityDestroy = UnityGameObject.Destroy
local UnityDownloadHandlerAssetBundle = UnityEngine.Networking.DownloadHandlerAssetBundle
local TypeUnityGameObject = typeof(UnityEngine.GameObject)
local UnityLoadSceneSync = UnityEngine.SceneManagement.SceneManager.LoadScene
local UnityLoadSceneAsync = UnityEngine.SceneManagement.SceneManager.LoadSceneAsync
local SysFile = System.IO.File

local _sformat = string.format
local _tinsert = table.insert

local M = ResUtil.create_child_mt(Base)

-- 判断bundle_name是否lua的bundle
local function IsLuaAssetBundle(bundle_name)
	local lua_asset_bundles = {"^lua/.*", "^luajit/.*"}
	for i,v in ipairs(lua_asset_bundles) do
		if string.match(bundle_name, v) then
			return true
		end
	end

	return false
end

function M:_init()
	Base._init(self)

	self.v_lua_manifest_info = {bundleInfos = {}}
	self.v_manifest_info = {bundleInfos = {}}
	self.v_goid_prefab_map = {}
	self.v_goid_go_monitors = {}
	self.v_goid_go_monit_time = 0
	self.v_instantiate_queue = {}
end

function M:Update(time, delta_time)
	Base.Update(self, time, delta_time)

	self:_InstantiateInQueue()
	AssetBundleMgr:Update()
	DownloaderMgr:Update()
	self:MonitorGameObjLive(time)
end

function M:IsBundleMode()
	return true
end

function M:GetPrefab(instance_id)
	return self.v_goid_prefab_map[instance_id]
end

function M:OnHotUpdateLuaComplete()
	local src = ResUtil.GetCachePath("LuaAssetBundle/Temp/LuaAssetBundle.lua", nil)
	local dest = ResUtil.GetCachePath("LuaAssetBundle/LuaAssetBundle.lua", nil)
	if SysFile.Exists(src) then
		SysFile.Copy(src, dest, true)
		SysFile.Delete(src)
	end
end

function M:LoadRemoteLuaManifest(callback)
	local remote_path = self:GetRemotePath("LuaAssetBundle/LuaAssetBundle.zip", self.v_asset_lua_version)
	local cache_path = ResUtil.GetCachePath("LuaAssetBundle/Temp/LuaAssetBundle.zip")
	print_log("[BundleLoader] remote lua manifest path:", remote_path)
	DownloaderMgr:CreateFileDownloader(remote_path, nil, 
		function(err, request)
			if nil == err then
				ReportManager:Step(Report.STEP_LUA_MANIFEST_UNZIP)
				local temp_dir = ResUtil.GetCachePath("LuaAssetBundle/Temp", nil)
				ZipUtils.UnZip(cache_path, temp_dir, 
					function ()
						if ResUtil.is_ios_encrypt_asset then
							-- 因为Unzip接口的原因，zipName是加密过的，而里面的name是没加密的，这里做个拷贝
							local src = temp_dir .. "/LuaAssetBundle.lua"
							local dest = ResUtil.GetCachePath("LuaAssetBundle/Temp/LuaAssetBundle.lua")
							SysFile.Copy(src, dest, true)
						end
						self:LoadLocalLuaManifest("LuaAssetBundle/Temp/LuaAssetBundle.lua")
					end)
			end
			callback(err)
		end, cache_path)
end

function M:LoadRemoteManifest(name, callback)
	local name_zip = name .. ".zip"
	local name_lua = name .. ".lua"

	local remote_path = self:GetRemotePath(name_zip, self.v_asset_version)
	local cache_path = ResUtil.GetCachePath(name_zip)

	print_log("[BundleLoader] load remote manifest:", remote_path)
	DownloaderMgr:CreateFileDownloader(remote_path, nil, 
		function(err, request)
			if not err then
				ReportManager:Step(Report.STEP_MANIFEST_UNZIP)
				print_log("[BundleLoader] load remote manifest complete:", remote_path)
				ZipUtils.UnZip(cache_path, ResUtil.GetBaseCachePath("", nil), 
					function ()
						self:LoadLocalManifest(name_lua)
					end)
			end
			callback(err)
		end, cache_path)
end

function M:LoadLocalLuaManifest(name)
	print_log("[BundleLoader] load local lua manifest:", name)
	local text = ResUtil.LoadFileHelper(name)
	local data = loadstring(text)
	local manifest = data()
	self.v_lua_manifest_info = manifest
end

function M:LoadLocalManifest(name)
	print_log("[BundleLoader] load local manifest:", name)
	local text = ResUtil.LoadFileHelper(name)
	local data = loadstring(text)
	local manifest = data()
	self.v_manifest_info = manifest
end

function M:GetAllLuaManifestBundles()
	return self.v_lua_manifest_info.bundleInfos
end

function M:GetLuaBundleHash(bundle_name)
	if self.v_lua_manifest_info.bundleInfos[bundle_name] then
		return self.v_lua_manifest_info.bundleInfos[bundle_name].hash
	end
end

function M:GetLuaBundleSize(bundle_name)
	if self.v_lua_manifest_info.bundleInfos[bundle_name] then
		return self.v_lua_manifest_info.bundleInfos[bundle_name].size
	end
	return 0
end

function M:GetLuaHashCode()
	return self.v_lua_manifest_info.manifestHashCode
end

function M:GetAllManifestBundles()
	return self.v_manifest_info.bundleInfos
end

function M:GetBundleDeps(bundle_name)
	if self.v_manifest_info.bundleInfos[bundle_name] then
		return self.v_manifest_info.bundleInfos[bundle_name].deps
	end
end

function M:GetBundleHash(bundle_name)
	if self.v_manifest_info.bundleInfos[bundle_name] then
		return self.v_manifest_info.bundleInfos[bundle_name].hash
	end
end

function M:GetBundleSize(bundle_name)
	if self.v_manifest_info.bundleInfos[bundle_name] then
		return self.v_manifest_info.bundleInfos[bundle_name].size
	end
end

function M:GetHashCode()
	return self.v_manifest_info.manifestHashCode
end

-- 异步加载unity场景
function M:LoadUnitySceneAsync(bundle_name, asset_name, load_mode, cb)
	local need_downloads, need_loads = self:ClacLoadBundleDepends(bundle_name)
	if nil == need_downloads or nil == need_loads then
		cb(nil, cbdata, bundle_name)
		return
	end

	if ResUtil.memory_debug then
		BundleCache:CacheBundleRefDetail(bundle_name, "[Asset]" .. asset_name)
		for _, v in pairs(need_loads) do
			BundleCache:CacheBundleRefDetail(v, bundle_name)
		end
	end

	-- 下载AB
	AssetBundleMgr:DownLoadBundles(need_downloads, true, function (is_succ)
		if not is_succ then
			cb(nil)
			return
		end

		BundleCache:LockBundles(need_loads)

		-- 同步加载AB
		AssetBundleMgr:LoadMultiBundlesAsync(need_loads, function(is_succ)
			if not is_succ then
				BundleCache:UnLockBundles(need_loads)
				cb(nil)
				return
			end

			-- 加载场景
			local loadscene_op = UnityLoadSceneAsync(asset_name, load_mode)
			if nil == loadscene_op then
				print_error("[BundleLoader] unity scene is not exists", bundle_name, asset_name)
				BundleCache:UnLockBundles(need_loads)
				cb(nil)
				return
			end

			BundleCache:UnLockBundles(need_loads)
			self:UseBundle(bundle_name)
			cb(loadscene_op)
		end, false)
	end, false)
end
-- 同步加载unity场景
function M:LoadUnitySceneSync(bundle_name, asset_name, load_mode, cb)
	local need_downloads, need_loads = self:ClacLoadBundleDepends(bundle_name)
	if nil == need_downloads or nil == need_loads then
		cb(nil, cbdata, bundle_name)
		return
	end

	if ResUtil.memory_debug then
		BundleCache:CacheBundleRefDetail(bundle_name, "[Asset]" .. asset_name)
		for _, v in pairs(need_loads) do
			BundleCache:CacheBundleRefDetail(v, bundle_name)
		end
	end

	-- 下载AB
	AssetBundleMgr:DownLoadBundles(need_downloads, true, function (is_succ)
		if not is_succ then
			cb()
			return
		end

		BundleCache:LockBundles(need_loads)

		-- 同步加载AB
		AssetBundleMgr:LoadMultiBundlesSync(need_loads, function(is_succ)
			if not is_succ then
				BundleCache:UnLockBundles(need_loads)
				cb()
				return
			end

			-- 加载场景
			UnityLoadSceneSync(asset_name, load_mode)

			BundleCache:UnLockBundles(need_loads)
			self:UseBundle(bundle_name)
			cb()
		end)
	end, false)
end

-- 异步加载资源(请不要直接调用该方法,通过资源池来调)
function M:__LoadObjectAsync(bundle_name, asset_name, asset_type, cb, cbdata, is_in_queue)
	local need_downloads, need_loads = self:ClacLoadBundleDepends(bundle_name)
	if nil == need_downloads or nil == need_loads then
		cb(nil, cbdata, bundle_name)
		return
	end

	if ResUtil.memory_debug then
		BundleCache:CacheBundleRefDetail(bundle_name, "[Asset]" .. asset_name)
		for _, v in pairs(need_loads) do
			BundleCache:CacheBundleRefDetail(v, bundle_name)
		end
	end

	-- 下载AB
	AssetBundleMgr:DownLoadBundles(need_downloads, false, function(is_succ)
		if not is_succ then
			cb(nil, cbdata, bundle_name)
			return
		end

		BundleCache:LockBundles(need_loads)

		-- 加载AB
		AssetBundleMgr:LoadMultiBundlesAsync(need_loads, function(is_succ)
			if not is_succ then
				BundleCache:UnLockBundles(need_loads)
				cb(nil, cbdata, bundle_name)
				return
			end

			-- 加载Asset
			AssetBundleMgr:LoadAssetAsync(bundle_name, asset_name, function(res)
				BundleCache:UnLockBundles(need_loads)
				cb(res, cbdata, bundle_name)

			end, asset_type, is_in_queue)
		end, is_in_queue)
	end, is_in_queue)
end

-- 同步加载资源(请不要直接调用该方法,通过资源池来调)
function M:__LoadObjectSync(bundle_name, asset_name, asset_type, cb, cbdata)
	local need_downloads, need_loads = self:ClacLoadBundleDepends(bundle_name)
	if nil == need_downloads or nil == need_loads then
		cb(nil, cbdata, bundle_name)
		return
	end

	if ResUtil.memory_debug then
		BundleCache:CacheBundleRefDetail(bundle_name, "[Asset]" .. asset_name)
		for _, v in pairs(need_loads) do
			BundleCache:CacheBundleRefDetail(v, bundle_name)
		end
	end

	-- 下载AB
	AssetBundleMgr:DownLoadBundles(need_downloads, true, function(is_succ)
		if not is_succ then
			cb(nil, cbdata, bundle_name)
			return
		end

		BundleCache:LockBundles(need_loads)

		-- 同步加载AB
		AssetBundleMgr:LoadMultiBundlesSync(need_loads, function(is_succ)
			if not is_succ then
				BundleCache:UnLockBundles(need_loads)
				cb(nil, cbdata, bundle_name)
				return
			end

			-- 同步加载Asset
			AssetBundleMgr:LoadAssetSync(bundle_name, asset_name, function(res)
				BundleCache:UnLockBundles(need_loads)
				cb(res, cbdata, bundle_name)

			end, asset_type)
		end)
	end, false)
end

-- 异步加载Prefab并实例化GameObject
function M:LoadGameobjAsync(bundle_name, asset_name, cb, cbdata)
	self:_LoadGameobj(bundle_name, asset_name, cb, cbdata, true, false)
end

-- 异步加载Prefab并实例化GameObject。但是实例化时将会用队列形式(即可以慢点显示)
function M:LoadGameobjAsyncInQueue(bundle_name, asset_name, cb, cbdata)
	self:_LoadGameobj(bundle_name, asset_name, cb, cbdata, true, true)
end

-- 同步加载Prefab并实例化GameObject
function M:LoadGameobjSync(bundle_name, asset_name, cb, cbdata)
	self:_LoadGameobj(bundle_name, asset_name, cb, cbdata, false, false)
end

function M:_LoadGameobj(bundle_name, asset_name, cb, cbdata, is_async, is_in_queue)
	if ResUtil.log_debug then
		ResUtil.Log("[BundleLoader] start async load gameobject", bundle_name, asset_name)
	end

	ResPoolMgr:GetPrefab(bundle_name, asset_name, function (prefab)
		if ResUtil.log_debug then
			ResUtil.Log("[BundleLoader] async load gameobject complete", bundle_name, asset_name, prefab)
		end

		if nil == prefab then
			cb(nil, cbdata)
			return
		end

		if is_in_queue then
			table.insert(self.v_instantiate_queue, {cb = cb, cbdata = cbdata, prefab = prefab, bundle_name = bundle_name})
			return
		end

		local gameobj = ResMgr:Instantiate(prefab, true)
		local instance_id = gameobj:GetInstanceID()
		self.v_goid_go_monitors[instance_id] = gameobj
		self.v_goid_prefab_map[instance_id] = prefab

		cb(gameobj, cbdata)

	end, is_async, is_in_queue)
end

function M:_InstantiateInQueue()
	if #self.v_instantiate_queue > 0 then
		local t = table.remove(self.v_instantiate_queue, 1)
		if nil ~= t.prefab then
			local gameobj = ResMgr:Instantiate(t.prefab, true)
			local instance_id = gameobj:GetInstanceID()
			self.v_goid_go_monitors[instance_id] = gameobj
			self.v_goid_prefab_map[instance_id] = t.prefab

			t.cb(gameobj, t.cbdata)
		else
			t.cb(nil, t.cbdata)
		end
	end
end

-- 计算加载AB需要依赖加载的文件
function M:ClacLoadBundleDepends(bundle_name)
	local deps = self:GetBundleDeps(bundle_name)
	if not deps then
		print_error("[BundleLoader] not found dependency：", bundle_name)
		return nil, nil
	end

	local bundle_hash = self:GetBundleHash(bundle_name)
	if nil == bundle_hash then
		print_error("[BundleLoader] not exists in manifest: ", bundle_name)
		return nil, nil
	end

	local need_downloads = {}
	local need_loads = {bundle_name}
	if not ResUtil.IsFileExist(bundle_name, bundle_hash) then
		need_downloads = {bundle_name}
	end

	for _, dep in ipairs(deps) do
		local hash = self.v_manifest_info.bundleInfos[dep].hash
		if not ResUtil.IsFileExist(dep, hash) then
			_tinsert(need_loads, dep)
			_tinsert(need_downloads, dep)
		else
			_tinsert(need_loads, dep)
		end
	end

	return need_downloads, need_loads
end

-- 监测obj的是否已被称除，逻辑层往往在因为父节点移除而没有调Destroy的方法
-- 此时应该从缓存列表中移除记录
function M:MonitorGameObjLive(time)
	if time < self.v_goid_go_monit_time then
		return
	end

	self.v_goid_go_monit_time = time + 1

	local die_goids = {}
	local monitor_count = 0
	for k, v in pairs(self.v_goid_go_monitors) do
		monitor_count = monitor_count + 1
		if v:Equals(nil) then
			table.insert(die_goids, k)
		end
	end

	for _, v in ipairs(die_goids) do
		self:ReleaseInObjId(v)
		ResPoolMgr:OnGameObjIllegalDestroy(v)
	end

	if #die_goids > 0 then
		print(string.format("[BundleLoader] monitor_count=%s, die_gameobj_count=%s", monitor_count, #die_goids))
	end
end

function M:Destroy(gameobj)
	if IsNil(gameobj) then
		return
	end
		
	if nil ~= ResPoolMgr and ResPoolMgr:IsInGameObjPool(gameobj:GetInstanceID(), gameobj) then
		print_error("[BundleLoader] big bug, destroy pool gameobject")
		return
	end

	self:ReleaseInObjId(gameobj:GetInstanceID())
	UnityDestroy(gameobj)
end

function M:ReleaseInObjId(instance_id)
	if nil ~= self.v_goid_prefab_map[instance_id] then
		self.v_goid_go_monitors[instance_id] = nil
		self.v_goid_prefab_map[instance_id] = nil
	end
end

function M:UseBundle(bundle_name)
	BundleCache:AddRef(bundle_name)

	local deps = self:GetBundleDeps(bundle_name)
	if nil == deps then
		return
	end

	for _, dep in ipairs(deps) do
		BundleCache:AddRef(dep)
	end
end

function M:ReleaseBundle(bundle_name)
	BundleCache:DelRef(bundle_name)

	local deps = self:GetBundleDeps(bundle_name)
	if nil == deps then
		return
	end

	for _, dep in ipairs(deps) do
		BundleCache:DelRef(dep)
	end
end

function M:IsCanSafeUseBundle(bundle_name)
	if not BundleCache:IsBundlRefing(bundle_name) then
		return false
	end

	local deps = self:GetBundleDeps(bundle_name)
	if nil ~= deps then
		for _, dep in ipairs(deps) do
			if not BundleCache:IsBundlRefing(dep) then
				return false
			end
		end
	end

	return true
end

function M:UpdateBundle(bundle_name, update_callback, complete_callback)
	local bundle_path = ""
	local bundle_hash = ""
	if IsLuaAssetBundle(bundle_name) then
		bundle_path = "LuaAssetBundle/" .. bundle_name
		bundle_hash = self:GetLuaBundleHash(bundle_name)
	else
		bundle_path = bundle_name
		bundle_hash = self:GetBundleHash(bundle_name)
	end
	local remote_path = self:GetRemotePath(bundle_path, bundle_hash)
	local cache_path = ResUtil.GetCachePath(bundle_path, bundle_hash)

	DownloaderMgr:CreateFileDownloader(remote_path, update_callback, complete_callback, cache_path)
end

function M:UnloadScene(bundle_name)
	self:ReleaseBundle(bundle_name)
end

function M:GetBundlesWithoutCached(bundle_name)
	local ret = {}

	if not ResUtil.IsFileExist(bundle_name, self:GetBundleHash(bundle_name)) then
		ret[bundle_name] = true
	end

	local deps = self:GetBundleDeps(bundle_name)
	if deps then
		for _, dep in ipairs(deps) do
			if not ResUtil.IsFileExist(dep, self:GetBundleHash(dep)) then
				ret[dep] = true
			end
		end
	end

	return ret
end

function M:GetDebugGameObjCount(t)
	t.gameobj_count = 0
	for _, v in pairs(self.v_goid_prefab_map) do
		t.gameobj_count = t.gameobj_count + 1
	end
end

return M

