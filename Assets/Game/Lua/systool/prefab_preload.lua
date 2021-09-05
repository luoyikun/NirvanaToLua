-- 加载器
local Loader = Loader or BaseClass()
function Loader:__init()
	self.callback = nil
	self.load_total_num = 0
	self.loaded_num = 0
	self.is_loading = false
end

function Loader:__delete()

end

function Loader:IsLoading()
	return self.is_loading
end

function Loader:StopLoad()
	self.is_loading = false
end

function Loader:StartLoad(list, callback)
	self.callback = callback
	self.loaded_num = 0
	self.load_total_num = 0
	self.is_loading = true

	for _, v in ipairs(list) do
		local bundle = v[1]
		local asset = v[2]

		if nil ~= bundle and nil ~= asset then
			self.load_total_num = self.load_total_num + 1

			local res_async_loader = AllocResAsyncLoader(self, "res_async_loader_" .. self.load_total_num)
			res_async_loader:Load(bundle, asset, nil, function(prefab)
				self.loaded_num = self.loaded_num + 1
				if self.loaded_num >= self.load_total_num and self.is_loading then
					self.is_loading = false
					self.callback()
				end
			end)
		end
	end

	if self.load_total_num <= 0 then
		self.is_loading = false
		self.callback()
	end
end

-- prefabload
PrefabPreload = PrefabPreload or BaseClass()
function PrefabPreload:__init()
	if PrefabPreload.Instance then
		print_error("[PrefabPreload]:Attempt to create singleton twice!")
	end
	PrefabPreload.Instance = self

	self.inc_id = 0
	self.wait_queue = {}
	self.loader_list = {}

	Runner.Instance:AddRunObj(self, 8)
end

function PrefabPreload:__delete()
	Runner.Instance:RemoveRunObj(self)
	for k,v in pairs(self.loader_list) do
		v:DeleteMe()
	end
	self.loader_list = nil

	PrefabPreload.Instance = nil
end

function PrefabPreload:Update(now_time, elapse_time)
	if #self.wait_queue <= 0 then
		return
	end

	local t = table.remove(self.wait_queue, 1)
	local loader = Loader.New()
	loader:StartLoad(t.list, function()
		if nil ~= t.callback then
			t.callback()
		end
	end)
	self.loader_list[t.id] = loader
end

function PrefabPreload:LoadPrefables(list, callback)
	self.inc_id = self.inc_id + 1
	table.insert(self.wait_queue, {id = self.inc_id, list = list, callback = callback})

	return self.inc_id
end

function PrefabPreload:StopLoad(id)
	if nil == id then
		return
	end

	for k, v in pairs(self.wait_queue) do
		if v.id == id then
			table.remove(self.wait_queue, k)
			break
		end 
	end

	local loader = self.loader_list[id]
	if loader then
		if loader:IsLoading() then
			loader:StopLoad()
		end
		loader:DeleteMe()
	end

	self.loader_list[id] = nil
end
