local ResUtil = require "resmanager/res_util"
local FileDownloader = require "resmanager/file_downloader"

local M = ResUtil.create_class()

function M:_init()
	self.v_file_downloaders = {}
end

function M:CreateFileDownloader(url, update_callback, complete_callback, cache_path)
	local file_downloader = FileDownloader:new(url, update_callback, complete_callback, cache_path)
	self.v_file_downloaders[file_downloader] = true
end

function M:Update()
	local list = {}
	for v, _ in pairs(self.v_file_downloaders) do
		if not v:Update() then
			table.insert(list, v)
		end
	end

	for _, v in ipairs(list) do
		self.v_file_downloaders[v] = nil
	end
end

return M
