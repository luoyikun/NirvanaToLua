local UnityGameObject = UnityEngine.GameObject
local UnityDestroy = UnityGameObject.Destroy

local M = {}

local MAX_UNLOAD_TIME = 3

function M:Init()
	self.last_sweep_time = 0
	self.v_caches = {}
	self.v_refs = {}
	self.v_last_del_times = {}
	self.v_last_use_times = {}
	self.v_ref_bundle_detail_dic = {}
	self.bundle_lock_num = {}
end

function M:Update(time, delta_time)
	if time - self.last_sweep_time < 0.2 then
		return
	end

	local now_time = time
	self.last_sweep_time = now_time

	for k, v in pairs(self.v_caches) do
		if nil == self.bundle_lock_num[k]
			and (nil == self.v_refs[k] or self.v_refs[k] <= 0)
			and (nil == self.v_last_del_times[k] or time - self.v_last_del_times[k] >= MAX_UNLOAD_TIME) then

			local bundle = self.v_caches[k]
			self.v_caches[k] = nil
			self.v_refs[k] = nil
			self.v_last_del_times[k] = nil
			self.v_last_use_times[k] = nil

			bundle:Unload(true)
			break
		end
	end
end

function M:IsBundlRefing(bundle_name)
	if self.v_caches[bundle_name] 
		and nil ~= self.v_refs[bundle_name]
		and self.v_refs[bundle_name] > 0 then
		return true
	end

	return false
end

function M:GetCacheRes(bundle_name)
	if nil == self.bundle_lock_num[bundle_name] then
		print_error("[BundleCache] GetCacheRes big bug, the bundle is not lock", bundle_name)
	end
	return self.v_caches[bundle_name]
end

function M:CacheRes(bundle_name, bundle)
	if nil == bundle then
		print_error("[BundleCache] cache bundle fail!", bundle_name)
		return
	end

	if nil ~= self.v_caches[bundle_name] then
		print_error("[BundleCache] cache bundle repeat!", bundle_name)
		return
	end

	self.v_caches[bundle_name] = bundle
end

function M:AddRef(bundle_name)
    if self.v_refs[bundle_name] == nil then
        self.v_refs[bundle_name] = 0
    end

	self.v_refs[bundle_name] = self.v_refs[bundle_name] + 1
	self.v_last_del_times[bundle_name] = nil
	self.v_last_use_times[bundle_name] = GlobalUnityTime
end

function M:DelRef(bundle_name)
    local ref = self.v_refs[bundle_name]
    if nil == ref then
    	print_error("[BundleCache] DelRef big bug!!!!, ref is nil", bundle_name, ref)
        return
    end

    if ref <= 0 then
        print_error("[BundleCache] DelRef big bug!!!!, ref < 0", bundle_name, ref)
    end

	self.v_refs[bundle_name] =  self.v_refs[bundle_name] - 1
	self.v_last_del_times[bundle_name] = GlobalUnityTime
end

function M:LockBundles(bundle_list)
    for _, v in ipairs(bundle_list) do
    	self.bundle_lock_num[v] = (self.bundle_lock_num[v] or 0) + 1
    end
end

function M:UnLockBundles(bundle_list)
    for _, v in ipairs(bundle_list) do
        self.bundle_lock_num[v] = (self.bundle_lock_num[v] or 0) - 1
        if self.bundle_lock_num[v] == 0 then
        	self.bundle_lock_num[v] = nil
        
        elseif self.bundle_lock_num[v] < 0 then
			print_error("[BundleCache] UnLockBundles big bug!!!!, lock num < 0", v, self.bundle_lock_num[v])
        end
    end
end

-- debug
function M:CheckAsetBundleLeak()
	local content = {}
	for k, v in pairs(self.v_last_use_times) do
		if self.v_refs[k] > 0 then
			local ref = self.v_refs[k]
			local timer = math.floor(GlobalUnityTime - v)
			table.insert(content, {text=string.format("ref=%s	last_use=%s	%s %s\n", ref, timer, k, self.v_caches[k] ~= nil), timer=timer, ref=ref})
		end
	end

	SortTools.SortDesc(content, "timer", "ref")
	local out_content = ""
	for k,v in pairs(content) do
		out_content = out_content .. v.text
	end

	local file_path = UnityEngine.Application.dataPath .. "/../temp/assetbundle_leak.txt"
	print_log("已输出日志到", file_path)
	local f = assert(io.open(file_path,'w'))
	f:write(out_content)
	f:close()
end

-- debug
function M:CheckAsetBundleDetailLeak()
	local content = ""
	for k, v in pairs(self.v_last_use_times) do
		if self.v_refs[k] > 0 then
			local s_builder = {}
			local lookup = {}
			self:GetAssetBundleRefInfo(k, s_builder, 0, lookup)

			if #s_builder > 0 then
				for _, s in ipairs(s_builder) do
					content = content .. s .. "\n"
				end
				content = content .. "\n"
			end
		end
	end

	local file_path = UnityEngine.Application.dataPath .. "/../temp/assetbundle_leak_detail.txt"
	print_log("已输出日志到", file_path)
	local f = assert(io.open(file_path,'w'))
	f:write(content)
	f:close()
end

-- deubg
function M:CacheBundleRefDetail(bundle_name, refer)
	if bundle_name == refer then
		return
	end

	local refers = self.v_ref_bundle_detail_dic[bundle_name]
	if nil == refers then
		refers = {}
		self.v_ref_bundle_detail_dic[bundle_name] = refers
	end

	refers[refer] = true
end

-- deubg
function M:GetAssetBundleRefInfo(bundle_name, s_builder, depth, lookup)
	local indent = ""
	for i = 0, depth do
		indent = indent .. "	"
	end

	local begin, _ = string.find(bundle_name, "Asset")
	if nil ~= begin then
		table.insert(s_builder, indent .. bundle_name)
		return
	end

	local refers = self.v_ref_bundle_detail_dic[bundle_name]
	if nil == refers then
		return
	end

	local ref_count = self.v_refs[bundle_name] or 0
	lookup[bundle_name] = true
	local elapse_time = math.floor(GlobalUnityTime - (self.v_last_use_times[bundle_name] or GlobalUnityTime))
	local show_bundle_name = bundle_name
	if 0 == depth then 
		show_bundle_name = "[AB]" .. bundle_name
	end

	table.insert(s_builder, string.format("%s%s, ref=%s, last_use_time=%ss", indent, show_bundle_name, ref_count, elapse_time))

	for k,v in pairs(refers) do
		if nil ~= lookup[k] then
			print_error(string.format("出现了包之间的互引用 %s => %s", bundle_name, k))
		else
			self:GetAssetBundleRefInfo(k, s_builder, depth + 1, lookup)
		end
	end

	lookup[bundle_name] = nil
end

function M:GetBundleCount(t)
	t.bundle_count = 0
	for k,v in pairs(self.v_caches) do
		t.bundle_count = t.bundle_count + 1
	end
end

function M:OnGameStop()
	for k, v in pairs(self.v_caches) do
		v:Unload(true)
	end
	self.v_caches = {}
end

return M