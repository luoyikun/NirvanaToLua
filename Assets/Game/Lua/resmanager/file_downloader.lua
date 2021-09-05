local ResUtil = require "resmanager/res_util"
local UnityWebRequest = UnityEngine.Networking.UnityWebRequest
local UnityYield = UnityEngine.Yield
local UnityTime = UnityEngine.Time
local SysFile = System.IO.File

local _sformat = string.format

local SPEED_SAMPLE_INTERVAL = 0.5

local M = ResUtil.create_class()

local zeroInt64 = int64.new(0, 0)
local zeroUInt64 = uint64.zero
local fhInt64 = int64.new(0, 400)

function M:_init(url, update_callback, complete_callback, cache_path)
	self:ResetSample()

	self.v_progress = 0
	self.v_downloaded_bytes = 0
	self.v_update_callback = update_callback
	self.v_complete_callback = complete_callback

	coroutine.start(function()
		print_log("[FileDownloader] start download file:", url)
		self.v_request = UnityWebRequest.Get(url)
		local www = self.v_request:SendWebRequest()
		coroutine.www(www)

		if IsGameStop then
			self.v_request:Dispose()
			return
		end

		local err
		if  self.v_request.isNetworkError then
			err = _sformat("[FileDownloader]download load fail, network error: %s %s", url,  self.v_request.error)
		elseif  self.v_request.isHttpError then
			err = _sformat("[FileDownloader]download load fail, http error: %s", url)
		elseif self.v_request.responseCode < zeroInt64 or  self.v_request.responseCode >= fhInt64 then
			err = _sformat("[FileDownloader]download load fail, code error: %s %s", url,  self.v_request.responseCode)
		elseif self.v_request.downloadedBytes <= zeroUInt64 then
			err = _sformat("[FileDownloader]download load fail, bytes error: %s %s", url,  self.v_request.downloadedBytes)
		end

		if nil ~= err then
			print_error("[FileDownloader] " .. err)
		else
			if nil ~= rawget(getmetatable(RuntimeAssetHelper), "TryWriteWebRequestData") then
				if not RuntimeAssetHelper.TryWriteWebRequestData(cache_path, self.v_request) then
					if SysFile.Exists(cache_path) then
						os.remove(cache_path)
					end

					err = _sformat("[FileDownloader]download load fail, write file error %s", cache_path)
				end
			else
				RuntimeAssetHelper.WriteWebRequestData(cache_path, self.v_request)
			end
		end

		print_log("[FileDownloader] download file complete:", url)
		complete_callback(err, self.v_request)

		self.v_request:Dispose()
		self:Destroy()
	end)
end

function M:Update()
	if self.v_destroy then
		return false
	end

	if self.v_request then
		local download_bytes = self.v_request:GetByteDownloads()
		self.v_sample_bytes = self.v_sample_bytes + download_bytes - self.v_downloaded_bytes
		self.v_downloaded_bytes = download_bytes
		self.v_progress = self.v_request.downloadProgress

		local interval = UnityTime.unscaledTime - self.v_sample_time
		self.v_sample_speed = self.v_downloaded_bytes / interval

		if self.v_update_callback then
			self.v_update_callback(
				self.v_progress,
				self.v_sample_speed,
				self.v_downloaded_bytes,
				0)
		end

		if interval >= SPEED_SAMPLE_INTERVAL then
			self:ResetSample()
		end
	end

	return true
end

function M:ResetSample()
	self.v_sample_bytes = 0
	self.v_sample_speed = 0
	self.v_sample_time = UnityTime.unscaledTime
end

function M:Destroy()
	self.v_destroy = true
	self.v_request = nil
	self.v_update_callback = nil
	self.v_complete_callback = nil
end

return M

