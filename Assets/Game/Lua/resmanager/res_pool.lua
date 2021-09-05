local ResUtil = require "resmanager/res_util"
local M = ResUtil.create_class()

function M:_init(bundle_name)
	self.v_bundle_name = bundle_name
	self.v_asset_count = 0
	self.v_asset_dic = {}
	self.v_instanceid_name_map = {}
	self.v_wait_unload_t = {}

	self.v_is_valid_pool = true
	ResMgr:UseBundle(bundle_name)
end

function M:GetAssetCount()
	return self.v_asset_count
end

function M:CacheRes(asset_name, asset)
	if not self.v_is_valid_pool then
        print_error("[ResPool] CacheRes big bug, the pool is invalid")
        return
    end

	if nil == asset then
		print_error("[ResPool] CacheRes big bug, asset is nil!!!!", asset_name)
		return
	end

	if nil ~= self.v_asset_dic[asset_name] then
		print_error("[ResPool] CacheRes big bug, asset is repeat cache!!!!", asset_name)
		return
	end

	if not ResMgr:IsCanSafeUseBundle(self.v_bundle_name) then
		print_error("[ResPool] CacheRes big bug, bundle is invalid!!!!", self.v_bundle_name, asset_name)
		return
	end
	
	self.v_asset_count = self.v_asset_count + 1
	self.v_asset_dic[asset_name] = {asset = asset, ref_count = 0, use_times = 0, asset_name = asset_name}
	self.v_instanceid_name_map[asset:GetInstanceID()] = asset_name
	self.v_wait_unload_t[asset_name] = GlobalUnityTime + 15
end

function M:ScanRes(asset_name)
	if nil ~= self.v_asset_dic[asset_name] then
		return self.v_asset_dic[asset_name].asset
	end

	return nil
end

function M:GetRes(asset_name)
	if not self.v_is_valid_pool then
        print_error("[ResPool] CacheRes big bug, the pool is invalid")
        return nil
    end

	local t = self.v_asset_dic[asset_name]
	if nil == t then
		return nil
	end

	if not ResMgr:IsCanSafeUseBundle(self.v_bundle_name) then
		print_error("[ResPool] GetRes big bug, bundle is invalid!!!!", self.v_bundle_name, asset_name)
		return nil
	end

	t.ref_count = t.ref_count + 1
	t.use_times = t.use_times + 1
	
	self.v_wait_unload_t[asset_name] = nil
	return t.asset
end

function M:Release(asset)
	if not self.v_is_valid_pool then
        print_error("[ResPool] Release big bug, the pool is invalid")
        return false
    end

	if nil == asset then
		print_error("[ResPool] Release big bug, asset is nil", self.v_bundle_name)
		return false
	end

	return self:ReleaseInObjId(asset:GetInstanceID())
end

function M:ReleaseInObjId(instance_id)
	if not self.v_is_valid_pool then
        print_error("[ResPool] ReleaseInObjId big bug, the pool is invalid")
        return false
    end

	local asset_name = self.v_instanceid_name_map[instance_id]
	if nil == asset_name then
		print_error("[ResPool] Release big bug, asset is not exist", asset.name)
		return false
	end

	local t = self.v_asset_dic[asset_name]
	t.ref_count = t.ref_count - 1
	if t.ref_count > 0 then
		return false
	end

	if t.ref_count < 0 then
		print_error("[ResPool] Release big bug, ref_count is less 0", asset_name, t.ref_count)
		return true
	end

    self.v_wait_unload_t[asset_name] = GlobalUnityTime + self:GetCacheTime(t.use_times)
    return true
end

 -- 根据使用次数来控制释放时间，有些使用次数少的可以快些释放
function M:GetCacheTime(use_times)
	local cache_time = 0
	if IsLowMemSystem then
		cache_time = 10
	else
		cache_time = 30 + (use_times / 50) * 180
	    if cache_time > 180 then
	        cache_time = 180
	    end
	end

	return cache_time
end

function M:Update(now_time)
	if not self.v_is_valid_pool then
        return false
    end

	local unload_list = {}
	for k, v in pairs(self.v_wait_unload_t) do
		if now_time >= v then
			local t = self.v_asset_dic[k]
			self.v_asset_dic[k] = nil
			if nil ~= t and nil ~= t.asset then
				self.v_instanceid_name_map[t.asset:GetInstanceID()] = nil
			else
				print_error("[ResPool] Update big bug, not found asset !!!", k)
			end

			self.v_asset_count = self.v_asset_count - 1
			table.insert(unload_list, k)
		end
	end

	for _, v in ipairs(unload_list) do
		self.v_wait_unload_t[v] = nil
	end

	-- 池里的所有资源引用为0时，将释放该AB的引用
	if #unload_list > 0 and self.v_asset_count <= 0 then
		if self.v_asset_count < 0 then
			print_error("[ResPool] Update big bug, v_asset_count less 0 !!!", k)
		end

		self.v_is_valid_pool = false
		ResMgr:ReleaseBundle(self.v_bundle_name)
	end

	return not self.v_is_valid_pool
end

-- 清除所有在等待移除列表中的，不考虑时间进行移除
function M:Clear()
	for k, v in pairs(self.v_wait_unload_t) do
		local t = self.v_asset_dic[k]
		self.v_asset_dic[k] = nil
		if nil ~= t and nil ~= t.asset then
			self.v_instanceid_name_map[t.asset:GetInstanceID()] = nil
		else
			print_error("[ResPool] Clear big bug, not found asset !!!", k)
		end

		self.v_asset_count = self.v_asset_count - 1

		if self.v_asset_count <= 0 then
			if self.v_asset_count < 0 then
				print_error("[ResPool] Update big bug, v_asset_count less 0 !!!", k)
			end

			ResMgr:ReleaseBundle(self.v_bundle_name)
			self.v_is_valid_pool = false
			break
		end
	end

	self.v_wait_unload_t = {}

	return not self.v_is_valid_pool
end

function M:GetDebugStr()
	local debug_str = string.format("[%s]\n", self.v_bundle_name)
	for k,v in pairs(self.v_asset_dic) do
		debug_str = debug_str .. string.format("asset_name=%s ref=%s \n", v.asset_name, v.ref_count)
	end

	debug_str = debug_str .. "\n"

	return debug_str
end

return M
