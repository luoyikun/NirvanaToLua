local BundleCache = require "resmanager/bundle_cache"
local ResUtil = require "resmanager/res_util"

local UnityAssetBundle = UnityEngine.AssetBundle
local UnityWebRequest = UnityEngine.Networking.UnityWebRequest

local BASE_MAX_DOWNLOADING_BUNDLE_COUNT = 4
local MAX_DOWNLOAD_RETRY_COUNT = 10
local BASE_MAX_WRITING_BUNDLE_COUNT = 10
local BASE_MAX_LOADING_BUNDLE_COUNT = 15
local BASE_MAX_LOADING_ASSET_COUNT = 8

local zeroInt64 = int64.new(0, 0)
local zeroUInt64 = uint64.zero
local fhInt64 = int64.new(0, 400)
local SysFile = System.IO.File
local _sformat = string.format
local _tinsert = table.insert

local M = ResUtil.create_class()

function M:_init()
	self.v_game_is_stop = false
	self.v_loading_session = 0

	self.v_downloading_bundle_count = 0
	self.v_writing_bundle_count = 0
	self.v_loading_bundle_count = 0
	self.v_loading_asset_count = 0

	self.v_need_load_bundles = {}
	self.v_need_load_bundle_infos = {}
	self.v_need_check_bundle_loads = {}
	self.v_download_bundle_records = {}

	-- 重试加载的数量，不恢复
	self.v_download_retry_counts = {}
	self.v_need_write_bundles = {}

	self.v_need_load_assets = {}
	self.v_need_load_asset_infos = {}
	self.v_need_check_asset_loads = {}
	self.v_load_bundle_records = {}

	self.v_need_download_bundles = {}
	self.v_need_download_bundle_infos = {}
	self.v_need_check_download_bundles = {}
	self.v_load_asset_recoreds = {}

	self.v_load_scene_t = nil
	self.v_unloading = false
	self.v_unload_timer_count = 0
	self.v_unload_invalid_time = 0
end

function M:Update()
	if self.v_unloading then
		self:_UpdateUnloadState()
		return
	end

	self:_UpdateCheckDownloadingStatus()
	self:_UpdateDownloadBundles()
	self:_UpdateWriteBundles()

	self:_UpdateCheckBundleLoadStatus()
	self:_UpdateBundleLoads()

	self:_UpdateCheckAssetLoadStatus()
	self:_UpdateAssetLoads()

	self:_UpdateSceneLoadStatus()
end

function M:ReqHighLoad()
	UnityEngine.Application.backgroundLoadingPriority = UnityEngine.ThreadPriority.High
end

function M:ReqLowLoad()
	UnityEngine.Application.backgroundLoadingPriority = UnityEngine.ThreadPriority.Low
end

-- 每帧检查正在下载的AB状态
-- 下载指定的AB时,如果有同样的AB正在下载中，则把此次请求加入检查列表。这里对检查列表进行检查
function M:_UpdateCheckDownloadingStatus()
	local succ_list = {}
	local fail_list = {}
	for i = #self.v_need_check_download_bundles, 1, -1 do
		local t = self.v_need_check_download_bundles[i]
		local record = self.v_download_bundle_records[t.cache_path]
		if record == true then
			table.remove(self.v_need_check_download_bundles, i)
			table.insert(succ_list, t.session)
		
		elseif record == false then
			table.remove(self.v_need_check_download_bundles, i)
			table.insert(fail_list, t.session)
		end
	end

	local del_list = {}
	for k,v in pairs(self.v_download_bundle_records) do
		if true == v or false == v then
			table.insert(del_list, k)
		end
	end

	for _, v in ipairs(del_list) do
		self.v_download_bundle_records[v] = nil
	end

	for _, v in ipairs(succ_list) do
		self:_OnDownloadBundleSucc(v)
	end

	for _, v in ipairs(fail_list) do
		self:_OnDownloadBundleFail(v)
	end
end

-- 每帧检查开启下载
function M:_UpdateDownloadBundles()
	if #self.v_need_download_bundles <= 0 then
		return
	end

	local max_downloading_count = BASE_MAX_DOWNLOADING_BUNDLE_COUNT + math.floor(#self.v_need_download_bundles / 5)
	local loop_count = 0
	while self.v_downloading_bundle_count < max_downloading_count do
		loop_count = loop_count + 1
		if loop_count >= 1000 then
			break
		end

		local download_t = table.remove(self.v_need_download_bundles, 1)
		if nil == download_t then
			break
		end

		self:_InternalDownloadBundle(download_t)
	end
end

-- 每帧检查正在加载的AB包的状态
-- 加载指定的AB时,如果有同样的AB正在加载中，则把此次请求加入检查列表。这里对检查列表进行检查
function M:_UpdateCheckBundleLoadStatus()
	local succ_list = {}
	local fail_list = {}
	for i = #self.v_need_check_bundle_loads, 1, -1 do
		local t = self.v_need_check_bundle_loads[i]
		local record = self.v_load_bundle_records[t.bundle_name]
		if true == record then
			table.remove(self.v_need_check_bundle_loads, i)
			if nil ~= BundleCache:GetCacheRes(t.bundle_name) then
				table.insert(succ_list, t.session)
			else
				table.insert(fail_list, t.session)
				print_error("[AssetBundleManager] _UpdateCheckBundleLoadStatus big bug", t.bundle_name)
			end

		elseif false == record then
			table.insert(fail_list, t.session)
			table.remove(self.v_need_check_bundle_loads, i)
		end
	end

	local del_list = {}
	for k,v in pairs(self.v_load_bundle_records) do
		if true == v or false == v then
			table.insert(del_list, k)
		end
	end

	for _, v in ipairs(del_list) do
		self.v_load_bundle_records[v] = nil
	end

	for _, v in ipairs(succ_list) do
		self:_OnBundleLoadSucc(v)
	end

	for _, v in ipairs(fail_list) do
		self:_OnBundleLoadFail(v)
	end
end

function M:_UpdateWriteBundles()
	if #self.v_need_write_bundles <= 0 then
		self.v_writing_bundle_count = 0
		return
	end

	local index = 0
	local write_in_queue_count = 0
	local max_write_count = BASE_MAX_WRITING_BUNDLE_COUNT + math.floor(#self.v_need_write_bundles / 5)
	local had_write_indexs = {}
	local loop_count = 0

	while self.v_writing_bundle_count < max_write_count do
		loop_count = loop_count + 1
		if loop_count >= 1000 then
			break
		end

		index = index + 1
		local t = self.v_need_write_bundles[index]
		if nil == t then
			break
		end

		if t.is_in_queue then
			write_in_queue_count = write_in_queue_count + 1
			if write_in_queue_count <= 1 then
				self:_InternalWriteBundle(t)
				
				_tinsert(had_write_indexs, index)
			end
		else
			self:_InternalWriteBundle(t)
			_tinsert(had_write_indexs, index)
		end
	end

	for i = #had_write_indexs, 1, -1 do
		table.remove(self.v_need_write_bundles, had_write_indexs[i])
	end

	self.v_writing_bundle_count = 0
end

-- 每帧检查开启加载
function M:_UpdateBundleLoads()
	if #self.v_need_load_bundles <= 0 then
		return
	end

	local index = 0
	local load_in_queue_count = 0
	local max_loading_count = BASE_MAX_LOADING_BUNDLE_COUNT + math.floor(#self.v_need_load_bundles / 5)
	local had_load_indexs = {}

	while self.v_loading_bundle_count < max_loading_count do
		index = index + 1
		local t = self.v_need_load_bundles[index]
		if nil == t then
			break
		end
		
		if t.is_in_queue then
			load_in_queue_count = load_in_queue_count + 1

			if load_in_queue_count <= 3 then
				_tinsert(had_load_indexs, index)
				self:_InternalLoadBundleAsync(t.bundle_file_path, t.bundle_name, t.bundle_hash, t.session)
			end
		else
			_tinsert(had_load_indexs, index)
			self:_InternalLoadBundleAsync(t.bundle_file_path, t.bundle_name, t.bundle_hash, t.session)
		end
	end

	for i = #had_load_indexs, 1, -1 do
		table.remove(self.v_need_load_bundles, had_load_indexs[i])
	end
end

-- 每帧检查正在加载的Asset状态
-- 加载指定的Asset时,如果有同样的Asset正在加载中，则把此次请求加入检查列表。这里对检查列表进行检查
function M:_UpdateCheckAssetLoadStatus()
	local succ_list = {}
	local fail_list = {}

	for i = #self.v_need_check_asset_loads, 1, -1 do
		local t = self.v_need_check_asset_loads[i]
		local record = self.v_load_asset_recoreds[t.asset_full_path]
		if true == record then
			local asset = ResPoolMgr:ScanRes(t.bundle_name, t.asset_name)
			table.remove(self.v_need_check_asset_loads, i)
			if nil ~= asset then
				table.insert(succ_list, {t.session, asset})
			else
				print_error("[AssetBundleManager] _UpdateCheckAssetLoadStatus big bug", t.bundle_name, t.asset_name)
				table.insert(fail_list, t.session)
			end
		elseif false == record then
			table.insert(fail_list, t.session)
			table.remove(self.v_need_check_asset_loads, i)
		end
	end

	local del_list = {}
	for k,v in pairs(self.v_load_asset_recoreds) do
		if true == v or false == v then
			table.insert(del_list, k)
		end
	end

	for _, v in ipairs(del_list) do
		self.v_load_asset_recoreds[v] = nil
	end

	for _, v in ipairs(succ_list) do
		self:_OnAssetLoaded(v[1], v[2])
	end

	for _, v in ipairs(fail_list) do
		self:_OnAssetLoaded(v, nil)
	end
end

-- 每帧检查开启从AB包加载Asset，控制加载总量和允许慢点加载的数量
function M:_UpdateAssetLoads()
	if #self.v_need_load_assets <= 0 then
		return
	end

	local index = 0
	local load_in_queue_count = 0
	local max_loading_count = BASE_MAX_LOADING_ASSET_COUNT + math.floor(#self.v_need_load_assets / 5)
	local had_load_indexs = {}

	while self.v_loading_asset_count < max_loading_count do
		index = index + 1
		local t = self.v_need_load_assets[index]
		if nil == t then
			break
		end

		if t.is_in_queue then
			load_in_queue_count = load_in_queue_count + 1

			if load_in_queue_count <= 1 then
				_tinsert(had_load_indexs, index)
				self:_InternalLoadAssetAsync(t.bundle_name, t.asset_name, t.session, t.asset_type)
			end
		else
			_tinsert(had_load_indexs, index)
			self:_InternalLoadAssetAsync(t.bundle_name, t.asset_name, t.session, t.asset_type)
		end
	end

	for i = #had_load_indexs, 1, -1 do
		table.remove(self.v_need_load_assets, had_load_indexs[i])
	end
end

function M:_UpdateSceneLoadStatus()
	if nil ~= self.v_load_scene_t 
		and nil ~= self.v_load_scene_t.loadscene_op
		and self.v_load_scene_t.loadscene_op.isDone then

		if self.v_game_is_stop then
			return
		end
		self:_OnSceneLoaded()
	end
end

-- 下载指定的AB,如果有同样的AB正在下载中，则把此次请求加入检查列表。每帧检查该AB的下载状态。
function M:_InternalDownloadBundle(download_t)
	local cache_path = download_t.cache_path
	local bundle_name = download_t.bundle_name
	local session = download_t.session

	if SysFile.Exists(cache_path) then
		self:_OnDownloadBundleSucc(session)
		return
	end

	if nil ~= self.v_download_bundle_records[cache_path] then
		local t = {cache_path = cache_path, session = session}
		_tinsert(self.v_need_check_download_bundles, t)
		return
	end

	self.v_download_bundle_records[cache_path] = 1

	local bundle_hash = ResMgr:GetBundleHash(bundle_name)
	local remote_path = ResMgr:GetRemotePath(bundle_name, bundle_hash)
	local downloading_www = UnityWebRequest.Get(remote_path)
	self.v_downloading_bundle_count = self.v_downloading_bundle_count + 1

	coroutine.start(function()
		if ResUtil.log_debug then
			ResUtil.Log("[AssetBundleManager] start download ", remote_path)
		end

		local www = downloading_www:SendWebRequest()
		coroutine.www(www)

		if self.v_game_is_stop then
			downloading_www:Dispose()
			return
		end

		self.v_downloading_bundle_count = self.v_downloading_bundle_count - 1

		if ResUtil.log_debug then
			ResUtil.Log("[AssetBundleManager] download complete ", remote_path)
		end

		local error_msg
		if downloading_www.isNetworkError then
			error_msg = _sformat("[AssetBundleManager]download load fail, network error: %s %s", remote_path, downloading_www.error)
		elseif downloading_www.isHttpError then
			error_msg = _sformat("[AssetBundleManager]download load fail, http error: %s", remote_path)
		elseif downloading_www.responseCode < zeroInt64 or downloading_www.responseCode >= fhInt64 then
			error_msg = _sformat("[AssetBundleManager]download load fail, code error: %s %s", remote_path, downloading_www.responseCode)
		elseif downloading_www.downloadedBytes <= zeroUInt64 then
			error_msg = _sformat("[AssetBundleManager]download load fail, bytes error: %s %s", remote_path, downloading_www.downloadedBytes)
		end

		local download_t = {cache_path = cache_path, downloading_www = downloading_www, bundle_name = bundle_name, session = session, is_priority = is_priority, is_in_queue = is_in_queue}
		if error_msg then
			download_t.downloading_www:Dispose()
			download_t.downloading_www = nil
			print_error("[AssetBundleManager] download fail ", remote_path, self.v_download_bundle_records[cache_path], error_msg)
			self:_OnDownloadError(download_t)
		else
			if download_t.is_priority then
				self:_InternalWriteBundle(download_t)
			else
				_tinsert(self.v_need_write_bundles, download_t)
			end
		end
	end)
end

function M:_OnDownloadError(download_t)
	local cache_path = download_t.cache_path

	self.v_download_retry_counts[cache_path] = self.v_download_retry_counts[cache_path] or 0
	if self.v_download_retry_counts[cache_path] <= MAX_DOWNLOAD_RETRY_COUNT or ResMgr:GetIsIgnoreHashCheck() then
		self.v_download_bundle_records[cache_path] = nil
		self.v_download_retry_counts[cache_path] = self.v_download_retry_counts[cache_path] + 1
		_tinsert(self.v_need_download_bundles, download_t)
	else
		self.v_download_retry_counts[cache_path] = nil
		self.v_download_bundle_records[cache_path] = false
		self:_OnDownloadBundleFail(download_t.session)
	end
end

-- 把下载好的AssetBundle写文件到本地
function M:_InternalWriteBundle(download_t)
	local cache_path = download_t.cache_path
	local session = download_t.session
	self.v_writing_bundle_count = self.v_writing_bundle_count + 1
	
	if nil ~= rawget(getmetatable(RuntimeAssetHelper), "TryWriteWebRequestData") then
		local is_succ = RuntimeAssetHelper.TryWriteWebRequestData(cache_path, download_t.downloading_www)
		download_t.downloading_www:Dispose()
		download_t.downloading_www = nil
		self.v_download_retry_counts[cache_path] = nil
		self.v_download_bundle_records[cache_path] = true

		if is_succ then
			self:_OnDownloadBundleSucc(session)
		else -- 如果写文件异常则忽略本地错当作下载失败处理
			if SysFile.Exists(cache_path) then
				os.remove(cache_path)
			end
			
			self:_OnDownloadError(download_t)
		end
	else
		RuntimeAssetHelper.WriteWebRequestData(cache_path, download_t.downloading_www)
		download_t.downloading_www:Dispose()
		download_t.downloading_www = nil
		self.v_download_retry_counts[cache_path] = nil
		self.v_download_bundle_records[cache_path] = true
		self:_OnDownloadBundleSucc(session)
	end
end

-- 加载指定的AB,如果有同样的AB正在加载中，则把此次请求加入检查列表。每帧检查该AB的加载状态。
function M:_InternalLoadBundleAsync(bundle_file_path, bundle_name, bundle_hash, session)
	if nil ~= BundleCache:GetCacheRes(bundle_name) then
		self:_OnBundleLoadSucc(session)
		return
	end

	if nil ~= self.v_load_bundle_records[bundle_name] then
		_tinsert(self.v_need_check_bundle_loads, {bundle_name = bundle_name, session = session})
		return
	end

	self.v_load_bundle_records[bundle_name] = 1

	-- 加密资源预处理(针对审核)
	if ResUtil.is_ios_encrypt_asset then
		local cache_file_path = ResUtil.GetCachePath(bundle_name, bundle_hash)
		if EncryptMgr.DecryptAssetBundle(bundle_file_path, cache_file_path) then
			bundle_file_path = cache_file_path
		end
	end

	local loading_bundle = UnityAssetBundle.LoadFromFileAsync(bundle_file_path)
	if nil == loading_bundle then
		print_error("[AssetBundleManager] async load bundle fail, not exist bundle", bundle_file_path, bundle_name)
		self.v_load_bundle_records[bundle_name] = false
		self:_OnBundleLoadFail(session)
		return
	end

	self.v_loading_bundle_count = self.v_loading_bundle_count + 1

	coroutine.start(function()
		coroutine.www(loading_bundle)

		if self.v_game_is_stop then
			if nil ~= loading_bundle.assetBundle then
				loading_bundle.assetBundle:Unload(true)
			end
			return
		end

		self.v_loading_bundle_count = self.v_loading_bundle_count - 1

		if nil == loading_bundle.assetBundle then
			-- 来到这里说明bundle本地文件已损坏，重新启动下载
			if SysFile.Exists(bundle_file_path) then
				os.remove(bundle_file_path)
			end

			self:DownLoadBundles({bundle_name}, false, function (is_succ)
				print_error("[AssetBundleManager] bigbug! load assetbundle fail, restart download callback", bundle_name, is_succ)
			end, false)

			print_error("[AssetBundleManager] async load bundle fail, bundle is nil ", bundle_file_path, bundle_name)
			self.v_load_bundle_records[bundle_name] = false
			self:_OnBundleLoadFail(session)
			return
		end

		self.v_load_bundle_records[bundle_name] = true
		BundleCache:CacheRes(bundle_name, loading_bundle.assetBundle)
		self:_OnBundleLoadSucc(session)
	end)
end

-- 从AB包中加载指定的Asset,如果有同样的Asset正在加载，则把此次请求加入检查列表。每帧检查该Asset的加载状态。
function M:_InternalLoadAssetAsync(bundle_name, asset_name, session, asset_type)
	local asset = ResPoolMgr:ScanRes(bundle_name, asset_name)
	if nil ~= asset then
		self:_OnAssetLoaded(session, asset)
		return
	end

	local bundle = BundleCache:GetCacheRes(bundle_name)
	if nil == bundle then
		print_error("[AssetBundleManager] not exist bundle in asset cache", bundle_name)
		self:_OnAssetLoaded(session, nil)
		return
	end

	if M.log_debug then
		M.Log("[AssetBundleManager] start aysnc load asset from bundle complete", bundle_name, asset_name)
	end

	local asset_full_path = ResUtil.GetAssetFullPath(bundle_name, asset_name)
	if nil ~= self.v_load_asset_recoreds[asset_full_path] then
		local t = {bundle_name = bundle_name, asset_name = asset_name, asset_full_path = asset_full_path, session = session}
		_tinsert(self.v_need_check_asset_loads, t)
		return
	end

	self.v_load_asset_recoreds[asset_full_path] = 1

	local request = nil
	if nil ~= asset_type then
		request = bundle:LoadAssetAsync(asset_name, asset_type)
	else
		request = bundle:LoadAssetAsync(asset_name)
	end

	if nil == request then
		print_error("[AssetBundleManager] asset not exist from bundle", bundle_name, asset_name)
		self.v_load_asset_recoreds[asset_full_path] = false
		self:_OnAssetLoaded(session, nil)
	else
		self.v_loading_asset_count = self.v_loading_asset_count + 1

		coroutine.start(function()
			coroutine.www(request)

			if self.v_game_is_stop then
				if nil ~= request.asset then
					UnityEngine.Resources.UnloadAsset(request.asset)
				end
				return
			end

			self.v_loading_asset_count = self.v_loading_asset_count - 1

			if M.log_debug then
				M.Log("[AssetBundleManager] aysnc load asset from bundle complete", bundle_name, asset_name)
			end

			local asset = request.asset
			if nil == asset then
				print_error("[AssetBundleManager] async load asset from bundle fail", bundle_name, asset_name)
				self.v_load_asset_recoreds[asset_full_path] = false
				self:_OnAssetLoaded(session, nil)
				return
			end

			self.v_load_asset_recoreds[asset_full_path] = true
			self:_OnAssetLoaded(session, asset)
		end)
	end
end

-- 下载多个assetbundle
function M:DownLoadBundles(bundle_infos, is_priority, finish_callback, is_in_queue)
	if #bundle_infos <= 0 then
		finish_callback(true)
		return
	end

	local session = self:_NewLoadingSession()
	for _, bundle_name in ipairs(bundle_infos) do
		local bundle_hash = ResMgr:GetBundleHash(bundle_name)
		local cache_path = ResUtil.GetCachePath(bundle_name, bundle_hash)
		if is_priority then
			_tinsert(self.v_need_download_bundles, 1, {cache_path = cache_path, bundle_name = bundle_name, session = session, is_priority = is_priority, is_in_queue = is_in_queue})
		else
			_tinsert(self.v_need_download_bundles, {cache_path = cache_path, bundle_name = bundle_name, session = session, is_priority = is_priority, is_in_queue = is_in_queue})
		end
	end

	self.v_need_download_bundle_infos[session] = {
		finish_callback = finish_callback,
		need_download_count = #bundle_infos,
		is_failed = false,
	}
end

-- 加载多个AB，先考虑缓存里是否有，无则加入加载队列
function M:LoadMultiBundlesAsync(bundle_infos, finish_callback, is_in_queue)
	local session = self:_NewLoadingSession()
	local is_failed = false
	local need_load_bundles = {}

	for _, bundle_name in ipairs(bundle_infos) do
		if nil == BundleCache:GetCacheRes(bundle_name) then
			local bundle_hash = ResMgr:GetBundleHash(bundle_name)
			local bundle_file_path = ResUtil.GetBundleFilePath(bundle_name, bundle_hash)
			if nil == bundle_file_path then
				is_failed = true
				print_error("[AssetBundleManager] async load bundle fail, not exit bundle", bundle_name, bundle_hash)
			else
				_tinsert(need_load_bundles, {bundle_file_path = bundle_file_path, bundle_name = bundle_name, bundle_hash = bundle_hash, is_in_queue = is_in_queue, session = session})
			end
		end
	end

	if is_failed then
		finish_callback(false)
		return
	end

	if #need_load_bundles <= 0 then
		finish_callback(true)
		return
	end

	for _, v in ipairs(need_load_bundles) do
		_tinsert(self.v_need_load_bundles, v)
	end

	self.v_need_load_bundle_infos[session] = {
		finish_callback = finish_callback,
		need_load_count = #need_load_bundles,
		is_failed = false,
	}
end

-- 同步加载多个AB包，先考虑缓存里是否有，无则同步加载
-- 注:如果有资源已经正在异步加载中，则不再进行同步加载，否则会触发unity重复加载AssetBundle的接口
-- 注:为了方便处理这种情况。这种情况很少发生，且这种同步改为异步的方式不会对逻辑层有任何影响，只是减慢了些加载速度
function M:LoadMultiBundlesSync(bundle_infos, finish_callback)
	local is_in_async_loading = false
	for _, bundle_name in ipairs(bundle_infos) do
		if 1 == self.v_load_bundle_records[bundle_name] then
			is_in_async_loading = true
			break
		end
	end

	if is_in_async_loading or self.v_unloading then
		self:LoadMultiBundlesAsync(bundle_infos, finish_callback, false)
		return
	end

	local is_succ = true
	for _, bundle_name in ipairs(bundle_infos) do
		if nil == BundleCache:GetCacheRes(bundle_name) then
			local bundle_hash = ResMgr:GetBundleHash(bundle_name)
			local bundle_file_path = ResUtil.GetBundleFilePath(bundle_name, bundle_hash)
			if nil == bundle_file_path then
				print_error("[AssetBundleManager] not exit assetbundle file", bundle_name, bundle_hash)
				is_succ = false
				break
			else
				-- 加密资源预处理(针对审核)
				if ResUtil.is_ios_encrypt_asset then
					local cache_file_path = ResUtil.GetCachePath(bundle_name, bundle_hash)
					if  EncryptMgr.DecryptAssetBundle(bundle_file_path, cache_file_path) then
						bundle_file_path = cache_file_path
					end
				end

				local bundle = UnityAssetBundle.LoadFromFile(bundle_file_path)
				if nil ~= bundle then
					BundleCache:CacheRes(bundle_name, bundle)
				else
					-- 来到这里说明bundle本地文件已损坏，重新启动下载
					print_error("[AssetBundleManager] sync load bundle fail!", bundle_file_path)
					if SysFile.Exists(bundle_file_path) then
						os.remove(bundle_file_path)
					end
					
					self:DownLoadBundles({bundle_name}, false, function (is_succ)
						print_error("[AssetBundleManager] bigbug! load assetbundle fail, restart download callback", bundle_name, is_succ)
					end, false)
					is_succ = false
					break
				end
			end
		end
	end

	finish_callback(is_succ)
end

-- 从指定的AB包里异步加载资源，调用此方法前确保BundleCache里存在此AB
function M:LoadAssetAsync(bundle_name, asset_name, finish_callback, asset_type, is_in_queue)
	local asset = ResPoolMgr:ScanRes(bundle_name, asset_name)
	if nil ~= asset then
		finish_callback(asset)
		return
	end

	local bundle = BundleCache:GetCacheRes(bundle_name)
	if nil == bundle then
		print_error("[AssetBundleManager] async load asset fail, because not exist bundle", bundle_name, asset_name)
		finish_callback(nil)
		return
	end

	local session = self:_NewLoadingSession()
	local t = {bundle_name = bundle_name, asset_name = asset_name, session = session, asset_type = asset_type, is_in_queue = is_in_queue}
	_tinsert(self.v_need_load_assets, t)
	self.v_need_load_asset_infos[session] = {
		finish_callback = finish_callback,
	}
end

-- 从指定的AB包里同步加载资源，调用此方法前确保BundleCache里存在此AB
-- 注:如果该资源已经正在异步加载中，则不再进行同步加载，否则可能会触发未知问题（加载资源一个在同步，一个在异步）
-- 注:为了方便处理这种情况。这种情况很少发生，且这种同步改为异步的方式不会对逻辑层有任何影响，只是减慢了些加载速度
function M:LoadAssetSync(bundle_name, asset_name, finish_callback, asset_type)
	local asset = ResPoolMgr:ScanRes(bundle_name, asset_name)
	if nil ~= asset then
		finish_callback(asset)
		return
	end

	local asset_full_path = ResUtil.GetAssetFullPath(bundle_name, asset_name)
	if 1 == self.v_load_asset_recoreds[asset_full_path] or self.v_unloading then
		self:LoadAssetAsync(bundle_name, asset_name, finish_callback, asset_type, false)
		return
	end

	local bundle = BundleCache:GetCacheRes(bundle_name)
	if nil == bundle then
		print_error("[AssetBundleManager] sync load asset fail, because not exist bundle", bundle_name, asset_name)
		finish_callback(nil)
		return
	end

	if nil ~= asset_type then
		asset = bundle:LoadAsset(asset_name, asset_type)
	else
		asset = bundle:LoadAsset(asset_name)
	end

	if nil == asset then
		print_error("[AssetBundleManager] sync load asset from bundle fail", bundle_name, asset_name)
		finish_callback(nil)
		return
	end

	finish_callback(asset)
end

-- 从指定的AB包里异步加载资源，调用此方法前确保BundleCache里存在此AB
function M:LoadSceneAsync(bundle_name, scene_name, load_mode, finish_callback)
	if nil ~= self.v_load_scene_t then
		print_error("[AssetBundleManager] async load scene big bug, not support load multi scene", 
					bundle_name, scene_name,  self.v_load_scene_t.bundle_name,  self.v_load_scene_t.scene_name)
		finish_callback(false)
		return
	end

	local bundle = BundleCache:GetCacheRes(bundle_name)
	if nil == bundle then
		print_error("[AssetBundleManager] async load scene fail, because not exist bundle", bundle_name, scene_name)
		finish_callback(false)
		return
	end

	local loadscene_op = UnityEngine.SceneManagement.SceneManager.LoadSceneAsync(scene_name, load_mode)
	if nil == loadscene_op then
		print_error("[AssetBundleManager] async load scene fail, because not exist scene", bundle_name, scene_name)
		finish_callback(false)
		return
	end

	self.v_load_scene_t = {bundle_name = bundle_name, scene_name = scene_name, loadscene_op = loadscene_op, finish_callback = finish_callback}
end

function M:_OnDownloadBundleSucc(session)
	local info = self.v_need_download_bundle_infos[session]
	info.need_download_count = info.need_download_count - 1

	if info.need_download_count == 0 then
		self.v_need_download_bundle_infos[session] = nil
		info.finish_callback(not info.is_failed)
	elseif info.need_download_count < 0 then
		print_error("[AssetBundleManager] _OnDownloadBundleSucc big bug, download count less 0")
	end
end

function M:_OnDownloadBundleFail(session)
	local info = self.v_need_download_bundle_infos[session]
	info.is_failed = true
	info.need_download_count = info.need_download_count - 1

	if info.need_download_count == 0 then
		self.v_need_download_bundle_infos[session] = nil
		info.finish_callback(false)
	elseif info.need_download_count < 0 then
		print_error("[AssetBundleManager] _OnDownloadBundleFail big bug, download count less 0")
	end
end

function M:_OnBundleLoadSucc(session)
	local info = self.v_need_load_bundle_infos[session]
	info.need_load_count = info.need_load_count - 1

	if info.need_load_count == 0 then
		self.v_need_load_bundle_infos[session] = nil
		info.finish_callback(not info.is_failed)
	elseif info.need_load_count < 0 then
		print_error("[AssetBundleManager] _OnBundleLoadSucc big bug, load count less 0")
	end
end

function M:_OnBundleLoadFail(session)
	local info = self.v_need_load_bundle_infos[session]
	info.need_load_count = info.need_load_count - 1
	info.is_failed = true

	if info.need_load_count == 0 then
		self.v_need_load_bundle_infos[session] = nil
		info.finish_callback(info.is_failed)
	elseif info.need_load_count < 0 then
		print_error("[AssetBundleManager] _OnBundleLoadFail big bug, load count less 0")
	end
end

function M:_OnAssetLoaded(session, asset)
	local info = self.v_need_load_asset_infos[session]
	if nil == info then
		print_error("[AssetBundleManager] _OnAssetLoaded big bug, load count less 0")
		return
	end

	self.v_need_load_asset_infos[session] = nil
	info.finish_callback(asset)
end

function M:_OnSceneLoaded()
	local t = self.v_load_scene_t
	self.v_load_scene_t = nil
	t.finish_callback(true)
end

function M:_NewLoadingSession()
	self.v_loading_session = self.v_loading_session + 1
	return self.v_loading_session
end

function M:OnGameStop()
	self.v_game_is_stop = true

	for k,v in pairs(self.v_need_write_bundles) do
		v.downloading_www:Dispose()
	end
	self.v_need_write_bundles = {}
end

function M:_UpdateUnloadState()
	-- 防止失效。超过一定时间，直接返回，不处理
	if self.v_unload_invalid_time > 0 and GlobalUnityTime >= self.v_unload_invalid_time then
		self.v_unload_invalid_time = 0
		if nil ~= self.v_unloading_finish_callback then
			local callback = self.v_unloading_finish_callback
			self.v_unloading_finish_callback = nil
			callback()
		end
		return
	end

	local can_unload = true
	for i,v in ipairs(self.v_load_bundle_records) do
		if v == 1 then
			can_unload = false
		end
	end

	for i,v in ipairs(self.v_load_asset_recoreds) do
		if v == 1 then
			can_unload = false
		end
	end

	if can_unload then
		self.v_unload_timer_count = self.v_unload_timer_count + 1
		if self.v_unload_timer_count == 2 then
			UnityEngine.Resources.UnloadUnusedAssets()
		elseif self.v_unload_timer_count == 4 then
			self.v_unload_invalid_time = 0
			self.v_unload_timer_count = 0
			self.v_unloading = false
			if nil ~= self.v_unloading_finish_callback then
				local callback = self.v_unloading_finish_callback
				self.v_unloading_finish_callback = nil
				callback()
			end
		end
	end
end

function M:UnloadUnusedAssets(finish_callback)
	self.v_unload_invalid_time = GlobalUnityTime + 2
	self.v_unloading = true
	self.v_unload_timer_count = 0
	self.v_unloading_finish_callback = finish_callback
end

return M