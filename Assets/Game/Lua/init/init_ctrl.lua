InitCtrl = {
	ctrl_state = CTRL_STATE.START,
	loading_view = nil,
	last_flush_time = -1,
	str_list = {},
	loading_data = nil,
	scene_state = false,
}


require("init/global_config")
require("init/init_device")
-- 上报服务器第一条协议：游戏启动
require("manager/report_manager")

local FlushTime = 3

function InitCtrl:Start()
	assert(not InitCtrl.Instance, "multi instance InitCtrl")
	if not InitCtrl.Instance then
		InitCtrl.Instance = self
	end

	self.init_request_times = 1
	self.init_url_index = 1
	self.cjson_request_time = 1
	self.client_time = 0
	self.is_delay_time = false

	self.is_first_request = true		-- 是否第一次请求链接

	-- 
	local init_urls = GLOBAL_CONFIG.package_info.config.init_urls
	self.audit_version_urls = init_urls[#init_urls]
	self.init_urls_table = {}
	self.init_urls_table[1] = init_urls[1]
	for i = 1, #init_urls - 1 do
		self.init_urls_table[i] = init_urls[i]
	end
	self.init_max_request_times = math.max(8, #self.init_urls_table)

	self.cjson_max_request_times = 8
	self.is_retry = false

	self.update_total_size = 0
	self.downloaded_size = 0

	self.is_receive_json = false

	print_log("init ctrl start")
	self.loading_data = require("init/init_loading_data")
	self.loading_view = require("init/init_loading_view")
	self.loading_view:Start()

	self:GetRandomStr()
	self:GetRandomAsset()

	self:SendRequest()
	self:CheckDefaultSetting()
end

function InitCtrl:Update(now_time, elapse_time)
	self.client_time = now_time
	if self.last_flush_time == -1 then
		self.last_flush_time = now_time
	elseif self.last_flush_time + FlushTime < now_time then
		self.last_flush_time = now_time
		self:GetRandomStr()
	end
	if self.ctrl_state == CTRL_STATE.START then
		self.ctrl_state = CTRL_STATE.UPDATE
		self:Start()
	elseif self.ctrl_state == CTRL_STATE.STOP then
		self.ctrl_state = CTRL_STATE.NONE
		self:Stop()
		PopCtrl(self)
	end
	if self.is_require_complete and self.is_receive_json then
		self:StartPreLoad()
		self.is_require_complete = false
		self.is_receive_json = false
	end
	if self.is_complete then
		if self.splash_complete then
			self:OnComplete()
			self.is_complete = false
		end
	end
	if self.is_delay_time then
		self:UpdateDelayTime(now_time, elapse_time)
	end
end

function InitCtrl:GetRandomStr()
	if #self.str_list < 1 then
		local temp_list = {}
		for k,v in pairs(self.loading_data.Reminding) do
			table.insert(temp_list, v)
		end
		self.str_list = temp_list
	end
	local index = math.random(1, #self.str_list)
	local str = self.str_list[index]
	self.loading_view:SetNotice(str)
	table.remove(self.str_list, index)
end

function InitCtrl:GetRandomAsset()
	-- 检查SDK是否存在闪屏页
	local url_tbl = {}
	-- 是否是第一次进游戏
	local is_first_start = UtilU3d.GetCacheData("is_first_start")
	if is_first_start == nil then
		if ResMgr.ExistedInStreaming("AgentAssets/splash_1.png") then
			local url = ResUtil.GetAgentAssetPath("AgentAssets/splash_1.png")
			table.insert(url_tbl, url)
		end
		if ResMgr.ExistedInStreaming("AgentAssets/splash_2.png") then
			local url = ResUtil.GetAgentAssetPath("AgentAssets/splash_2.png")
			table.insert(url_tbl, url)
		end
	end
	self.loading_view:SetSplashUrl(url_tbl, function() self.splash_complete = true end)
	UtilU3d.CacheData("is_first_start", 1)

	-- 检查SDK是否存在特殊的背景页，如果存在则使用SDK的背景页.
	if ResMgr.ExistedInStreaming("AgentAssets/loading_bg.png") then
		local url = ResUtil.GetAgentAssetPath("AgentAssets/loading_bg.png")
		self.loading_view:SetBgURL(url)
		return
	end

	local bunle_name = UtilU3d.GetCacheData("loading_bg_bundle_name")
	local asset_name = UtilU3d.GetCacheData("loading_bg_asset_name")

	if nil ~= bunle_name and nil ~= asset_name then
		self.loading_view:SetBgAsset(bunle_name, asset_name)
		return
	end

	local temp_list = self.loading_data.SceneImages
	local index = math.random(1, #temp_list)
	local asset = temp_list[index]
	if asset then
		bunle_name = asset[1]
		asset_name = asset[2]
		UtilU3d.CacheData("loading_bg_bundle_name", bunle_name)
		UtilU3d.CacheData("loading_bg_asset_name", asset_name)
		self.loading_view:SetBgAsset(bunle_name, asset_name)
	end
end

function InitCtrl:Stop()
end

function InitCtrl:SendRequest()
	local os = "unknown"
	local platform = UnityEngine.Application.platform
	if platform == UnityEngine.RuntimePlatform.Android then
		os = "android"
	elseif platform == UnityEngine.RuntimePlatform.IPhonePlayer then
		os = "ios"
	elseif platform == UnityEngine.RuntimePlatform.WindowsPlayer then
		os = "windows"
	elseif platform == UnityEngine.RuntimePlatform.WindowsEditor or
		platform == UnityEngine.RuntimePlatform.OSXEditor then
		os = "android"
	end

	local init_url = ""
	if self.is_first_request then
		init_url = self.audit_version_urls
	else
		init_url = self.init_urls_table[self.init_url_index]
	end

	local url = ""
	if string.find(init_url, "?") then
		local plat = GLOBAL_CONFIG.package_info.config.agent_id
		local pkg = GLOBAL_CONFIG.package_info.version
		local asset = GLOBAL_CONFIG.assets_info.version
		local device = DeviceTool.GetDeviceID()
		url = init_url
		url = string.gsub(url, "{{plat}}", plat)
		url = string.gsub(url, "{{pkg}}", pkg)
		url = string.gsub(url, "{{asset}}", asset)
		url = string.gsub(url, "{{device}}", device)
		url = string.gsub(url, "{{os}}", os)
	else
		url = string.format("%s?plat=%s&pkg=%s&asset=%s&device=%s&os=%s",
			init_url,
			GLOBAL_CONFIG.package_info.config.agent_id,
			GLOBAL_CONFIG.package_info.version,
			GLOBAL_CONFIG.assets_info.version,
			DeviceTool.GetDeviceID(),
			os)
	end
	print_log("SendRequest", url)
	HttpClient:Request(url, function(url, is_succ, data)
		InitCtrl:OnRequestCallback(url, is_succ, data)
	end)
end

function InitCtrl:OnRequestCallback(url, is_succ, data)
	print_log("Request", url, is_succ)
	if not is_succ then
		if self.is_first_request then
			self.is_first_request = false
			local is_continue_load = true
			if nil ~= rawget(getmetatable(DeviceTool), "GetNetworkAccessibility") then
				is_continue_load = DeviceTool.GetNetworkAccessibility()
			end
			
			if is_continue_load then
				self:SendRequest()
			else
				self.init_request_times = 1
				self.loading_view:ShowMessageBox("网络错误", "连接服务器失败", "重试", function()
					print_log("重试连接服务器")
					self.is_retry = true
					self:SendRequest()
				end)
				self:ReportConnectFaild(Report.STEP_CONNECT_PHP_SERVER_FAILED, url, data, self.init_max_request_times)
			end
			return
		end
		self.is_first_request = false

		if self.init_request_times < self.init_max_request_times then
			self.init_request_times = self.init_request_times + 1
			self.init_url_index = self.init_url_index + 1
			if self.init_url_index > #self.init_urls_table then
				self.init_url_index = 1
			end

			self:SendRequest()
		else
			self.init_request_times = 1
			self.loading_view:ShowMessageBox("网络错误", "连接服务器失败", "重试", function()
				print_log("重试连接服务器")
				self.is_retry = true
				self:SendRequest()
			end)
			self:ReportConnectFaild(Report.STEP_CONNECT_PHP_SERVER_FAILED, url, data, self.init_max_request_times)
		end
		return
	end

	for i = 1, 1 do
		if data == "login block" then
			self.loading_view:ShowMessageBox("封禁", "您的设备已被封禁,请联系客服", "重试", function()
				print_log("重试连接服务器")
				self:SendRequest()
			end)
			return
		end

		local init_info = cjson.decode(data)
		if init_info == nil then
			if self.cjson_request_time < self.cjson_max_request_times then
				self.cjson_request_time = self.cjson_request_time + 1
				self.init_url_index = self.init_url_index + 1
				if self.init_url_index > #self.init_urls_table then
					self.init_url_index = 1
				end
				self:SendRequest()
			else
				self.cjson_request_time = 1
				self.loading_view:ShowMessageBox("网络错误", "连接服务器失败", "重试", function()
					print_log("重试连接服务器")
					self.is_retry = true
					self:SendRequest()
				end)
				self:ReportConnectFaild(Report.STEP_JSON_DECODE_FAILED, url, data, self.cjson_max_request_times)
			end
			return
		end

		-- 保留这段代码
		if init_info.ret == "login block" then
			local error_remind = ""
			if "string" == type(init_info.msg) then
				error_remind = "您的设备已被封禁：封禁id为" .. init_info.msg
			else
				if init_info.msg and init_info.msg.ip then
					error_remind = "您的IP已被封禁：封禁ip为" .. init_info.msg.ip
				elseif init_info.msg and init_info.msg.device then
					error_remind = "您的设备已被封禁：封禁设备为" .. init_info.msg.device
				end
			end

			-- local error_remind = "您的设备已被封禁：封禁id为" .. init_info.msg
			self.loading_view:ShowMessageBox("封禁", error_remind, "重试", function()
				print_log("重试连接服务器")
				self:SendRequest()
			end)
			return
		end

		-- 获取加密方式
		if init_info.t then
			local encryption = Split(init_info.t, ",")
			local langth = #encryption
			if langth == 2 then
				if encryption[1] == "1" then
					local data_length = encryption[2]
					local init_info_data = Base64Decode(init_info.data, data_length)
					init_info = cjson.decode(init_info_data)
				end
			end
		end
		
		if cjson.null == init_info.param_list then break end

		GLOBAL_CONFIG.param_list = init_info.param_list

		if GLOBAL_CONFIG.param_list.switch_list.audit_version then
			IS_AUDIT_VERSION = true
		end

		if IS_AUDIT_VERSION then
			IS_MSG_ENCRYPT = true
		end

		self.loading_view:IsVersionHide()
		
		if GLOBAL_CONFIG.param_list.switch_list.open_gvoice then
			IS_FEES_VOICE = true
		end

		self.is_receive_json = true

		if cjson.null == init_info.server_info then break end
		GLOBAL_CONFIG.server_info = init_info.server_info
		GLOBAL_CONFIG.client_time = self.client_time
		
		if cjson.null == init_info.version_info then break end
		local version_info = init_info.version_info
		GLOBAL_CONFIG.version_info = {}

		if cjson.null == version_info.package_info then break end
		GLOBAL_CONFIG.version_info.package_info = version_info.package_info

		if cjson.null ~= version_info.assets_info then
			GLOBAL_CONFIG.version_info.assets_info = version_info.assets_info
			ResMgr:SetAssetVersion(version_info.assets_info.version)
			ResMgr:SetAssetLuaVersion(version_info.assets_info.lua_version)
		end

		ReportManager:Step(Report.STEP_GAME_BEGIN, 
				UnityEngine.SystemInfo.deviceName,
				UnityEngine.SystemInfo.deviceModel,
				UnityEngine.SystemInfo.deviceUniqueIdentifier)

		if cjson.null == version_info.update_data then break end
		local update_data = mime.unb64(version_info.update_data)

		-- 加载繁体字
		if ResMgr.ExistedInStreaming("AgentAssets/language_tw.txt") and GLOBAL_CONFIG.param_list.switch_list.language_tw then
			ResPoolMgr:GetDynamicObjSync("uis/changefont_prefab", "ChangeFont", 
				function(obj)
					print_log("load changefont...")
				end)
		end

		if cjson.null == update_data then break end
		local update_func = loadstring(update_data)
		if cjson.null ~= update_func and "function" == type(update_func) then
			-- PushCtrl(update_func())
			PushCtrl(require("update"))
			return
		end

		self:SetPercent(1)
	end
end

-- view
function InitCtrl:ShowLoading()
	if not self.loading_view then
		return
	end
	self.loading_view:Show()
end

function InitCtrl:HideLoading()
	if not self.loading_view then
		return
	end
	self.loading_view:Hide()
end

function InitCtrl:SetSceneState(scene_state)
	self.scene_state = scene_state
end

function InitCtrl:SetText(text)
	self.loading_view:SetText(text)
end

function InitCtrl:SetPercent(percent, callback)
	self.loading_view:SetPercent(percent, callback)
end

function InitCtrl:ShowMessageBox(title, content, button_name, complete)
	self.loading_view:ShowMessageBox(title, content, button_name, complete)
end
--

-- level:0,1,2
local function SetQuality(level)
	QualityConfig.QualityLevel = level
	PlayerPrefsUtil.SetInt("quality_level", level)
	if level == 2 or level == 3 then
		LimitScreenResolution(720)
	else
		LimitScreenResolution(1080)
	end

	if GlobalEventSystem then
		GlobalEventSystem:Fire(ObjectEventType.QUALITY_CHANGE)
	end
end

function InitCtrl:CheckDefaultSetting()
	-- 如果玩家设置了，就不再进入默认设置
	if PlayerPrefsUtil.HasKey("quality_level") then
		local quality_level = PlayerPrefsUtil.GetInt("quality_level")
		QualityConfig.QualityLevel = quality_level
		if quality_level == 2 or quality_level == 3 then
			LimitScreenResolution(720)
		else
			LimitScreenResolution(1080)
		end
		return
	end

	-- gpu, cpu, ram
	local sysInfo = UnityEngine.SystemInfo
	print_log("sysInfo ",
		"\nsupportsImageEffects=",sysInfo.supportsImageEffects,
		"\ndeviceName=", sysInfo.deviceName,
		"\ndeviceModel=", sysInfo.deviceModel,
		"\ndeviceUniqueIdentifier=",sysInfo.deviceUniqueIdentifier,
		"\nsupportsRenderToCubemap=",sysInfo.supportsRenderToCubemap,
		"\nsystemMemorySize=",sysInfo.systemMemorySize,
		"\ngraphicsMemorySize=",sysInfo.graphicsMemorySize,
		"\ngraphicsDeviceID=",sysInfo.graphicsDeviceID,
		"\ngraphicsDeviceName=",sysInfo.graphicsDeviceName,
		"\ngraphicsDeviceVendorID=",sysInfo.graphicsDeviceVendorID,
		"\ngraphicsDeviceType=",sysInfo.graphicsDeviceType,
		"\ngraphicsDeviceVersion=",sysInfo.graphicsDeviceVersion,
		"\ngraphicsShaderLevel=",sysInfo.graphicsShaderLevel,
		"\ngraphicsMultiThreaded=",sysInfo.graphicsMultiThreaded,
		"\nsupportsShadows=",sysInfo.supportsShadows,
		"\ngraphicsDeviceVendor=",sysInfo.graphicsDeviceVendor,
		"\nmaxCubemapSize=",sysInfo.maxCubemapSize
		)

	-- 模拟器 最高配
	if rawget(getmetatable(DeviceTool), "IsEmulator") and DeviceTool.IsEmulator() then 
		SetQuality(0)
		return
	end

	-- 特殊型号, 直接low品质
	for _, device_name in ipairs(LOW_QUALITY_DEVICE) do
		if device_name == sysInfo.deviceName then
			print_log("[InitCtrl]special device name, set quality to low")
			SetQuality(3)
			return
		end
	end

	for _, graphics_id in ipairs(LOW_QUALITY_GRAPHICS) do
		if graphics_id == sysInfo.graphicsDeviceID then
			print_log("[InitCtrl]special graphics id, set quality to low")
			SetQuality(3)
			return
		end
	end

	-- 不支持特定功能，直接low品质
	if not sysInfo.supportsImageEffects or
		not sysInfo.supportsRenderToCubemap or
		not sysInfo.supportsShadows or 
		not sysInfo.graphicsMultiThreaded then
		SetQuality(3)
		return
	end

	if UnityEngine.Application.platform == UnityEngine.RuntimePlatform.IPhonePlayer then
		if UnityEngine.SystemInfo.systemMemorySize <= 1500 then -- 超低配
			SetQuality(3)
		else
			SetQuality(0)
		end
	else
		-- 高配
		if sysInfo.supportedRenderTargetCount >= 4 and
			sysInfo.systemMemorySize >= 3072 and
			sysInfo.graphicsMemorySize >= 500 and
			sysInfo.processorCount >= 4 and
			sysInfo.processorFrequency > 2200 then
			SetQuality(0)
			return
		end

		-- 中配
		if sysInfo.supportedRenderTargetCount >= 2 and
			sysInfo.systemMemorySize >= 2000 and
			sysInfo.graphicsMemorySize >= 400 and
			sysInfo.processorCount >= 2 and
			sysInfo.processorFrequency > 2000 then
			SetQuality(1)
			return
		end

		-- 低配
		if sysInfo.supportedRenderTargetCount >= 2 and
			sysInfo.systemMemorySize >= 1500 and
			sysInfo.graphicsMemorySize >= 256 and
			sysInfo.processorCount >= 2 and
			sysInfo.processorFrequency > 1500 then
			SetQuality(2)
			return
		end

		-- 超低配
		SetQuality(3)
	end
end

function InitCtrl:OnCompleteRequire()
	self.is_require_complete = true
end

function InitCtrl:StartPreLoad()
	local play = nil
	if IS_AUDIT_VERSION then
		play = require("audit_play")
	else
		play = require("play")
	end
	play:SetComplete(function ()
		-- 预加载场景依赖的AB包
		print_log("[loading] start load login scene or cg", os.date())
		LoginCtrl.Instance:PreLoadDependBundles(function (percent)
			self:SetPercent(0.1 * percent + 0.6)
			if percent >= 1 then
				print_log("[loading] finish load login scene or cg", os.date())
				-- 开始预加载
				print_log("[loading] start load preload prefab", os.date())
				PreloadManager.Instance:Start()

				local temp_normal_pec = 0.29
				local select_role_state = UtilU3d.GetCacheData("select_role_state")
				local last_is_merge_server = UtilU3d.GetCacheData("last_is_merge_server")
				local last_role_list_count = UtilU3d.GetCacheData("last_role_list_count")
				local is_select_role = select_role_state == 1 and (not last_is_merge_server or last_role_list_count ~= 1)
				if is_select_role then
					temp_normal_pec = 0.2
				end
				PreloadManager.Instance:WaitComplete(function (percent)
					self:SetPercent(temp_normal_pec * percent + 0.7)
					if percent < 1 then
						return
					end
					print_log("[loading] finish load preload prefab", os.date())
					print_log("[loading] start sync load login scene", os.date())
					local login_view_complete_callback = function ()
						self:SetPercent(1, function ()
							print_log("finish login view", os.date())
							self:HideLoading()
							self:DestroyLoadingView()
							self:OnComplete()
						end)
					end

					if IS_AUDIT_VERSION then
						-- 打开登录界面
						play:SetTrulyCompleteCallBack(function ()
							LoginCtrl.Instance:ModulesComplete()
						end)
						LoginCtrl.Instance:StartLogin(login_view_complete_callback)
						return
					end

					-- 加载登录场景
					local asset_name = "scenes/map/w3_ts_denglu_main"
					local bundle_name = "W3_TS_DengLu_Main"
					ResMgr:LoadLevelSync(
						asset_name,
						bundle_name,
						UnityEngine.SceneManagement.LoadSceneMode.Single,
						function()
							if nil ~= LoginView.Instance then
								LoginView.Instance:OnLoadDengluLevelScene(asset_name)
							end

							print_log("[loading] finish sync load login scene", os.date())
							print_log("start open login view", os.date())
							-- 打开登录界面
							LoginCtrl.Instance:StartLogin(login_view_complete_callback)
						end)
				end)
			end
		end)
	end)

	PushCtrl(play)
end

function InitCtrl:OnComplete()
	-- 闪屏完成后
	if self.splash_complete then
		print_log("InitCtrl:OnComplete")
		self:Delete()
	else
		self.is_complete = true
	end
end

function InitCtrl:Delete()
	self.ctrl_state = CTRL_STATE.STOP
end

function InitCtrl:DestroyLoadingView()
	self.loading_view:Destroy()
end

-- 上报连接失败
function InitCtrl:ReportConnectFaild(reason, url, data, retry_times)
	ReportManager:Step(reason, nil, nil, nil, nil,
		UnityEngine.SystemInfo.deviceName,
		UnityEngine.SystemInfo.deviceModel,
		UnityEngine.SystemInfo.deviceUniqueIdentifier, url, data, retry_times)
end

local function CalculateUpdateSize(update_bundles)
	local size = 0
	for i, v in ipairs(update_bundles) do
		local bundle_size = 0
		if IsLuaAssetBundle(v) then
			bundle_size = ResMgr:GetLuaBundleSize(v) or 0
		else
			bundle_size = ResMgr:GetBundleSize(v) or 0
		end
		size = size + bundle_size
	end

	return size
end

function InitCtrl:ShowUpdateBundles(update_bundles, need_restart, complete_callback)
	if #update_bundles <= 0 then
		ResMgr:OnHotUpdateLuaComplete()
		complete_callback()
		return
	end

	self.complete_callback = complete_callback
	self.need_restart = need_restart
	self.update_total_size = 0
	self.downloaded_size = 0

	local update_size = CalculateUpdateSize(update_bundles)
	print_log("update_size=", update_size)
	self.update_total_size = update_size
	self:UpdateBundles(update_bundles, 1)
end

function InitCtrl:UpdateDelayTime(now_time, elapse_time)
	local initctrl_delay_time = UtilU3d.GetCacheData("initctrl_delay_time")
	if nil == initctrl_delay_time then
		UtilU3d.CacheData("initctrl_delay_time", now_time + 2)
	end
	if initctrl_delay_time and now_time > initctrl_delay_time then
		self.is_delay_time = false
		UtilU3d.CacheData("initctrl_delay_time", nil)
		GameRoot.Instance:Restart()
	end
end

function InitCtrl:UpdateBundles(update_bundles, index, file_info)
	if index > #update_bundles then
		-- 继续或者重启
		if self.need_restart then
			ResMgr:OnHotUpdateLuaComplete()
			GameRoot.Instance:Restart()

			self.complete_callback = nil
			self.need_restart = nil
		else
			ResMgr:OnHotUpdateLuaComplete()
			self.complete_callback()
			self.complete_callback = nil
			self.need_restart = nil
		end
		return
	end

	local bundle = update_bundles[index]
	local file_size = 0
	if IsLuaAssetBundle(bundle) then
		file_size = ResMgr:GetLuaBundleSize(bundle) or 0
	else
		file_size = ResMgr:GetBundleSize(bundle) or 0
	end
	ResMgr:UpdateBundle(bundle,
		function(progress, download_speed, bytes_downloaded, content_length)
			local p = 1 * (index + progress) / #update_bundles
			local speed_in_kb = download_speed / 1024
			local downloaded_mb = (self.downloaded_size + file_size * progress) / 1024 / 1024
			local total_mb = self.update_total_size / 1024 / 1024

			self:SetPercent(p)
			self:SetText(self.scene_state and self.loading_data.UpdateText[2] or self.loading_data.UpdateText[1])
			-- local tip = string.format("新版本更新: %0.1fMB/%0.1fMB, 速度: %0.1fKB/s", downloaded_mb, total_mb, speed_in_kb)
			-- if speed_in_kb / 1024 >= 1 then
			-- 	tip = string.format("新版本更新: %0.1fMB/%0.1fMB, 速度: %0.1fMB/s", downloaded_mb, total_mb, speed_in_kb / 1024)
			-- end
			local tip = string.format("新版本更新: %0.1fMB/%0.1fMB, 速度: %0.1fMB/s", downloaded_mb, total_mb, speed_in_kb / 1024)
			self:SetText(tip)
		end,
		function(error_msg)
			if error_msg ~= nil and error_msg ~= "" then
				print_log("下载: ", bundle, " 失败: ", error_msg)

				-- 最多重试8次
				if not self.update_retry_times or self.update_retry_times < 8 then
					self.update_retry_times = (self.update_retry_times or 0) + 1
					-- 切换下载地址
					if GLOBAL_CONFIG.param_list.update_url2 ~= nil and "" ~= GLOBAL_CONFIG.param_list.update_url2 then
						if self.update_retry_times%2 == 1 then
							ResMgr:SetDownloadingURL(GLOBAL_CONFIG.param_list.update_url2)
						else
							ResMgr:SetDownloadingURL(GLOBAL_CONFIG.param_list.update_url)
						end
					end

					self:UpdateBundles(update_bundles, index)
				else
					self:SetText("网络异常，正在为您尝试重新连接。。。")
					self.is_delay_time = true
				end
			else
				self.downloaded_size = self.downloaded_size + file_size
				-- 下载成功, 还原网络下载地址
				if self.update_retry_times then
					self.update_retry_times = nil
					ResMgr:SetDownloadingURL(GLOBAL_CONFIG.param_list.update_url)
				end

				-- 继续下载
				self:UpdateBundles(update_bundles, index + 1)
			end
		end)
end

return InitCtrl
