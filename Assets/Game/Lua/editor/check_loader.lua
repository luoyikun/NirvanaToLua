local CheckLoader = {}

local loaders = {}

function CheckLoader:OnCreateObj(obj, class_type)
	if obj.name == "GameObjLoader" then
		loaders[obj] = debug.traceback()
	end
end

function CheckLoader:OnDeleteObj(obj)
	loaders[obj] = nil
end

function CheckLoader:Update(now_time, elapse_time)
	local del_list = {}
	for loader, v in pairs(loaders) do
		if not loader.is_loading 
			and nil ~= loader.game_obj
			and loader.game_obj:Equals(nil) then
			print_error("释放GameObject未通过loader:DeleteMe()方式，将导致内存泄露", v)
			table.insert(del_list, loader)
		end
	end

	for _, v in ipairs(del_list) do
		loaders[v] = nil
	end
end

return CheckLoader