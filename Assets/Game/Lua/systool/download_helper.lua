DownloadHelper = {}

function DownloadHelper.DownloadBundle(bundle, retry_times, callback)
	DownloadHelper.DownloadBundleHelper(bundle, retry_times, 0, callback)
end

function DownloadHelper.DownloadBundleHelper(bundle, retry_times, cur_times, callback)
	-- print_log("[Download] start download ", bundle)
	ResMgr:UpdateBundle(bundle,
		function(progress, download_speed, bytes_downloaded, content_length)
		end,
		function(error_msg)
			if error_msg ~= nil and error_msg ~= "" then
				print_error("[Download] download fail ", bundle, cur_times, retry_times, error_msg)

				if cur_times < retry_times then
					DownloadHelper.DownloadBundleHelper(bundle, retry_times, cur_times + 1, callback)
				else
					if callback then
						callback(false)
					end
				end
			else
				-- print_log("[Download] download succ ", bundle)
				if callback then
					callback(true)
				end
			end
		end)
end
