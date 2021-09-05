-- startup 
-- 确定要接着要load哪些lua文件
local UnityApplication = UnityEngine.Application
local SysFile = System.IO.File

local _smatch = string.match
local _sformat = string.format

local function Setup()
	ResUtil = require "resmanager/res_util"
	require("utils/util")

	ResUtil.SetBaseCachePath(_sformat("%s/%s", UnityApplication.persistentDataPath, "BundleCache"))
	local develop_mode = require("editor/develop_mode")

	ResUtil.memory_debug = develop_mode:IsDeveloper()

	if GAME_ASSETBUNDLE then
		ResUtil.InitEncryptKey()
		if ResUtil.is_ios_encrypt_asset then
			ResUtil.SetBaseCachePath(_sformat("%s/%s", UnityApplication.persistentDataPath, EncryptMgr.GetEncryptPath("BundleCache")))
		end
		
		ResUtil:InitStreamingFilesInfo()
		ResMgr = require("resmanager/bundle_loader"):new()
	else
		ResMgr = require("resmanager/simulation_loader"):new()
	end

	AssetBundleMgr = require("resmanager/assetbundle_mgr"):new()

	BundleCache = require("resmanager/bundle_cache")
	DownloaderMgr = require("resmanager.download_mgr"):new()
	AudioManager = require "resmanager/audio_mgr"
	AudioManager.init()

	require("resmanager/gameobjattach_event_handle")
	require("resmanager/loadrawimage_event_handle")
	require("resmanager/effect_event_handl")

	BundleCache:Init()

	ResPoolMgr = require("resmanager/resource_pool_mgr"):new()
	ResMgr:LoadLocalLuaManifest("LuaAssetBundle/LuaAssetBundle.lua")
	ResMgr:LoadLocalManifest("AssetBundle.lua")
end

Setup()

require "main"
