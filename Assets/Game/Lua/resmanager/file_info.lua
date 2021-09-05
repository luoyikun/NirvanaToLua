local ResUtil = require "resmanager/res_util"

local M = ResUtil.create_class()

function M:_init(data)
    self.v_file_infos = {}

    string.gsub(data, "[^\n]+", function(line)
        local file_name, size = string.match(line, "(.+)%s+(.+)")
        if file_name and size then
            self.v_file_info[file_name] = tonumber(size)
        end
    end)
end

function M:GetSize(file_name)
    local size = self.v_file_info[file_name] or 0
    return size
end

return M

