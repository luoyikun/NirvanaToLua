
local M = {}

local AppStreamingAssetsPath = UnityEngine.Application.streamingAssetsPath
local SysFile = System.IO.File
local SysPath = System.IO.Path
local SysDirectory = System.IO.Directory
local SysSearchOption = System.IO.SearchOption
local UnityResourceFind = UnityEngine.Resources.FindObjectsOfTypeAll
local GameRootGetAliasResPath = nil
if nil ~= rawget(getmetatable(GameRoot), "GetAliasResPath") then
	GameRootGetAliasResPath = GameRoot.Instance.GetAliasResPath
end

local _sformat = string.format
local _slower = string.lower

local FileExistTbl = {}

M.memory_debug = false
M.memory_tag = "memory_tag"
M.cache_path = ""
M.streaming_files = {}
M.log_debug = false
M.log_list = {}
M.is_ios_encrypt_asset = false

function M.create_child_mt(base)
	local child = setmetatable({}, base)
	child.__index = child
	return child
end

local function _create_class_new(self, ...)
	local ret = setmetatable({}, self)
	ret:_init(...)
	return ret
end

local function _create_class_on_destroy(self)
end

function M.create_class()
	local class = {}
	class.__index = class

	class.new = _create_class_new
	class.on_destroy = _create_class_on_destroy 

	return class
end

function M.GetAssetFullPath(bundle_name, asset_name)
	return _sformat("%s/%s", bundle_name, _slower(asset_name))
end

function M.SetBaseCachePath(path)
	if not path or path == "" then
		return
	end

	if not SysDirectory.Exists(path) then
		SysDirectory.CreateDirectory(path)
	end

	M.base_cache_path = path
end

function M.GetBaseCachePath()
	return M.base_cache_path
end

function M.GetCachePath(bundle_name, hash)
	if M.is_ios_encrypt_asset then
		local relative_path = ""
		if hash then
			relative_path = _sformat("%s-%s", bundle_name, hash)
		else
			relative_path = bundle_name
		end

		relative_path = EncryptMgr.GetEncryptPath(relative_path)
		return _sformat("%s/%s", M.base_cache_path, relative_path)
	else
		if hash then
			return _sformat("%s/%s-%s", M.base_cache_path, bundle_name, hash)
		else
			return _sformat("%s/%s", M.base_cache_path, bundle_name)
		end
	end
end

function M.GetBundleFilePath(bundle_name, hash)
	local record_path = FileExistTbl[bundle_name]
	if nil ~= record_path then
		return record_path
	end

	-- 是否在Cache目录存在
	local bundle_file_path = M.GetCachePath(bundle_name, hash)
	if SysFile.Exists(bundle_file_path) then
		FileExistTbl[bundle_name] = bundle_file_path
		return bundle_file_path
	end

	-- 是否在包体内
	if nil == hash then
		local bundle_path = _sformat("AssetBundle/%s", bundle_name)
		if M.ExistedInStreaming(bundle_path) then
			bundle_file_path = M.GetSteamingAssetPath(bundle_path)
			FileExistTbl[bundle_name] = bundle_file_path
			return bundle_file_path
		end
	else
		local bundle_path = _sformat("AssetBundle/%s-%s", bundle_name, hash)
		if M.ExistedInStreaming(bundle_path) then
			bundle_file_path = M.GetSteamingAssetPath(bundle_path)
			FileExistTbl[bundle_name] = bundle_file_path
			return bundle_file_path
		end
	end

	-- 当没有指定Download时，将无视hash值寻找
	if ResMgr:GetIsIgnoreHashCheck() then
		local file_name = SysPath.GetFileName(bundle_name)
		-- 从Canche目录中找
		local bundle_dir = SysPath.GetDirectoryName(M.GetCachePath(bundle_name, hash))
		if SysDirectory.Exists(bundle_dir) then
			local file_list = SysDirectory.GetFiles(bundle_dir, _sformat("%s-*", file_name), SysSearchOption.TopDirectoryOnly)
			if nil ~= file_list and file_list.Length > 0 then
				return file_list:GetValue(0)
			end
		end

		-- 在包体中找
		local find_start
		for k, _ in pairs(M.streaming_files) do
			find_start, _ = string.find(k, _sformat("AssetBundle/%s%s", bundle_name, "%-")) 
			if 1 == find_start then
				bundle_file_path = M.GetSteamingAssetPath(k)
				return bundle_file_path
			end
		end
	end

	return nil
end

function M.LoadFileHelper(path)
	local full_path = M.GetCachePath(path)
	if SysFile.Exists(full_path) then
		return SysFile.ReadAllText(full_path)
	else
		if M.is_ios_encrypt_asset then
			local alias_path = M.GetSteamingAssetPath("AssetBundle/" .. path)
			return EncryptMgr.ReadEncryptFile(alias_path)
		else
			local alias_path = M.GetAliasResPath("AssetBundle/" .. path)
			return StreamingAssets.ReadAllText(alias_path)
		end
	end
end

function M.IsFileExist(bundle_name, hash)
	return nil ~= M.GetBundleFilePath(bundle_name, hash)
end

function M.ExistedInCache(bundle_name, hash)
	local path = M.GetCachePath(bundle_name, hash)
	if SysFile.Exists(path) then
		return true
	end

	return false
end

function M.ExistedInStreaming(path)
	return M.streaming_files[path]
end

function M.InitStreamingFilesInfo()
	M.streaming_files = {}
	local data = nil
	if M.is_ios_encrypt_asset then
		local path = M.GetSteamingAssetPath("file_list.txt")
		data = EncryptMgr.ReadEncryptFile(path)
	else
		local path = M.GetAliasResPath("file_list.txt")
		data = StreamingAssets.ReadAllText(path)
	end

	local lines = Split(data, '\n')
	for _, line in ipairs(lines) do
		M.streaming_files[line] = true
	end
end

function M.InitEncryptKey()
	if nil ~= EncryptMgr then
		M.is_ios_encrypt_asset = EncryptMgr.IsEncryptAsset()
	end
end

function M.GetSteamingAssetPath(path)
	path = M.GetAliasResPath(path)
	return _sformat("%s/%s", AppStreamingAssetsPath, path)
end

function M.GetAgentAssetPath(path)
	path = M.GetSteamingAssetPath(path)

	if M.is_ios_encrypt_asset then
		local target_path = EncryptMgr.DecryptAgentAssets(path)
		if nil ~= target_path and "" ~= target_path then
			path = target_path
		end
	end
	
	return path
end

function M.GetAliasResPath(path)
	if nil == GameRootGetAliasResPath then
		return path
	end
	return GameRootGetAliasResPath(path)
end

function M.Log(...)
	if not UNITY_EDITOR then
		return
	end

	print_log(...)

	local param = {...}
	local log_str = string.format("%s", socket.gettime())
	for _, v in ipairs(param) do
		log_str = log_str .. "		" .. tostring(v)
	end

	table.insert(M.log_list, log_str)
end

function M.OutputLog()
	local content = ""
	for _, v in ipairs(M.log_list) do
		content = content .. v .. "\n"
	end
	local file_path = UnityEngine.Application.dataPath .. "/../temp/log.txt"
	local f = assert(io.open(file_path,'w'))
	f:write(content)
	f:close()
end

return M

