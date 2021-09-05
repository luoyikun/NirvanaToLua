local InitDownload = {
	ctrl_state = CTRL_STATE.START,
}

local RestartAssetBundles = {
	"^lua/.*",
	"^luajit/.*",
}

local UpdateAssetBundles = {}

local function CalcUpdateAssetBundlesList()
	UpdateAssetBundles = require("config/config_strong_update")

	-- if UnityEngine.Application.platform ~= UnityEngine.RuntimePlatform.WindowsEditor then
		if UnityEngine.Application.platform == UnityEngine.RuntimePlatform.IPhonePlayer or
			UnityEngine.Application.platform == UnityEngine.RuntimePlatform.WindowsPlayer then
			table.insert(UpdateAssetBundles, "^lua/.*")
		else
			table.insert(UpdateAssetBundles, "^luajit/.*")
		end
	-- end
end

local function NeedUpdate(bundle_name)
	for i,v in ipairs(UpdateAssetBundles) do
		if string.match(bundle_name, v) then
			return true
		end
	end

	return false
end

function IsLuaAssetBundle(bundle_name)
	for i,v in ipairs(RestartAssetBundles) do
		if string.match(bundle_name, v) then
			return true
		end
	end

	return false
end

function InitDownload:Update(now_time, elapse_time)
	if self.ctrl_state == CTRL_STATE.START then
		self.ctrl_state = CTRL_STATE.UPDATE
		self:Start()
	elseif self.ctrl_state == CTRL_STATE.STOP then
		self.ctrl_state = CTRL_STATE.NONE
		self:Stop()
		PopCtrl(self)
	end
end

function InitDownload:RefreshDownloadUrl(is_switch)
	if is_switch and GLOBAL_CONFIG.param_list.update_url2 and "" ~= GLOBAL_CONFIG.param_list.update_url2 then
		ResMgr:SetDownloadingURL(GLOBAL_CONFIG.param_list.update_url2)
	else
		ResMgr:SetDownloadingURL(GLOBAL_CONFIG.param_list.update_url)
	end
end

function InitDownload:Start()
	print_log("update_url = ", GLOBAL_CONFIG.param_list.update_url)
	ResMgr:SetDownloadingURL(GLOBAL_CONFIG.param_list.update_url)
	
	if not ResMgr:IsBundleMode() then
		self:OnUpdateComplete()
	else
		if IS_AUDIT_VERSION and not GLOBAL_CONFIG.param_list.switch_list.update_assets then
			ResMgr:LoadLocalLuaManifest("LuaAssetBundle/LuaAssetBundle.lua")
			ResMgr:LoadLocalManifest("AssetBundle.lua")
			self:OnUpdateComplete()
		else
			self.download_retry_times = 0
			InitCtrl:SetText("正在下载游戏资源，请稍等")
			print_log("[InitDownload] start download remote luamanifest", self.download_retry_times)
			ReportManager:Step(Report.STEP_REQUEST_REMOTE_LUA_MANIFEST)
			self:DownloadRemoteLuaManifest()
		end	
	end
end

function InitDownload:Stop()
end

function InitDownload:DownloadRemoteLuaManifest()
	ResMgr:LoadRemoteLuaManifest(function(error_msg)
			if error_msg ~= nil then
				if self.download_retry_times < 8 then -- 重试
					self.download_retry_times = self.download_retry_times + 1
					self:RefreshDownloadUrl(self.download_retry_times % 2 == 1)
					print_log("[InitDownload] retry download remote luamanifest", ResMgr:GetDownloadingURL(), self.download_retry_times)
					self:DownloadRemoteLuaManifest()
				else
					print_error("[InitDownload] download remote luamanifest fail", ResMgr:GetDownloadingURL(), self.download_retry_times)
					ReportManager:Step(Report.STEP_REQUEST_REMOTE_LUA_MANIFEST_FAILED)
					GameRoot.Instance:Restart()
				end
			else
				self:OnLoadRemoteLuaManifestComplete()
			end
		end)
end

function InitDownload:OnLoadRemoteLuaManifestComplete()
	self.download_retry_times = 0
	print_log("[InitDownload] start download remote manifest")
	ReportManager:Step(Report.STEP_REQUEST_REMOTE_MANIFEST)
	self:DownloadRemoteManifest()
end

function InitDownload:DownloadRemoteManifest()
	ResMgr:LoadRemoteManifest("AssetBundle",
		function(error_msg)
			if error_msg ~= nil then
				if self.download_retry_times < 8 then -- 重试
					self.download_retry_times = self.download_retry_times + 1
					self:RefreshDownloadUrl(self.download_retry_times % 2 == 1)
					print_log("[InitDownload] retry download remote manifest", ResMgr:GetDownloadingURL(), self.download_retry_times)
					self:DownloadRemoteManifest()
				else
					print_error("[InitDownload] download remote manifest fail", ResMgr:GetDownloadingURL(), self.download_retry_times)
					ReportManager:Step(Report.STEP_REQUEST_REMOTE_MANIFEST_FAILED)
					GameRoot.Instance:Restart()
				end
			else
				self:OnDownloadRemoteManifestComplete()
			end
		end)
end

function InitDownload:OnDownloadRemoteManifestComplete()
	self.download_retry_times = 0
	print_log("[InitDownload] start download strong update config")
	ReportManager:Step(Report.STEP_REQUEST_LOAD_STRONG_CFG)
	self:DownloadStrongUpdateCfg() -- 强更列表
end

function InitDownload:DownloadStrongUpdateCfg()
	local bundle_path = ""
	if UnityEngine.Application.platform == UnityEngine.RuntimePlatform.IPhonePlayer or
		UnityEngine.Application.platform == UnityEngine.RuntimePlatform.WindowsPlayer then
		bundle_path = "lua/config/config_strong_update"
	else
		bundle_path = "luajit/config/config_strong_update"
	end
	
	if ResMgr:IsLuaVersionCached(bundle_path) then
		self:OnDownloadStrongUpdateCfgComplete()
		return
	end
	
	ResMgr:UpdateBundle(bundle_path, 
		nil,
		-- 完成时回调
		function(error_msg)
			-- 下载失败重试
			if error_msg ~= nil and error_msg ~= "" then
				if self.download_retry_times < 8 then
					self.download_retry_times = self.download_retry_times + 1
					self:RefreshDownloadUrl(self.download_retry_times % 2 == 1)

					print_log("[InitDownload] retry download strong update config", ResMgr:GetDownloadingURL(), bundle_path, self.download_retry_times)
					self:DownloadStrongUpdateCfg(complete_callback)
				else
					ReportManager:Step(Report.STEP_REQUEST_LOAD_STRONG_CFG_FAIL)
					print_error("[InitDownload] download strong update config fail", ResMgr:GetDownloadingURL(), self.download_retry_times)
					GameRoot.Instance:Restart()
				end
			else
				self:OnDownloadStrongUpdateCfgComplete()
			end
		end)
end

function InitDownload:OnDownloadStrongUpdateCfgComplete()
	self.download_retry_times = 0
	ReportManager:Step(Report.STEP_UPDATE_ASSET_BUNDLE)
	CalcUpdateAssetBundlesList()
	self:DownloadStrongUpdateBundles()
end

function InitDownload:DownloadStrongUpdateBundles()
	self.need_restart = false
	local update_bundles = {}

	local lua_bundles = ResMgr:GetAllLuaManifestBundles()
	for k, _ in pairs(lua_bundles) do
		if NeedUpdate(k) then
			if not ResMgr:IsLuaVersionCached(k) then
				self.need_restart = true 				-- 因为是热更lua所以有更新的话需要重新加载
				table.insert(update_bundles, k)
			end
		end
	end

	-- 资源
	local bundles = ResMgr:GetAllManifestBundles()
	for k, _ in pairs(bundles) do
		if NeedUpdate(k) then
			if not ResMgr:IsVersionCached(k) then
				table.insert(update_bundles, k)
			end
		end
	end

	-- show loading
	ReportManager:Step(Report.STEP_UPDATE_ASSET_BUNDLE)
	print_log("[InitDownload] start hotupdate assetbundle", #update_bundles)
	InitCtrl:ShowUpdateBundles(update_bundles, self.need_restart, function()
		self:OnUpdateComplete()
	end)
end

function InitDownload:OnUpdateComplete()
	print_log("[InitDownload] all assetbundle hotupdate complete")
	ReportManager:Step(Report.STEP_UPDATE_ASSET_BUNDLE_COMPLETE)

	PushCtrl(require("init/init_require"))
	self.ctrl_state = CTRL_STATE.STOP
end

return InitDownload
