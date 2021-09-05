local ResUtil = require "resmanager/res_util"
local UnityTime = UnityEngine.Time

local M = ResUtil.create_class()

function M:_init(obj, root, max_free_count, max_cache_time)
	self.v_pool = {}
	self.v_root = root
	self.v_count = 0
	self.v_obj = obj

	self.v_max_free_count = max_free_count
    self.v_max_cache_time = max_cache_time
	self.v_last_touch_time = UnityTime.time
end

function M:GetObject()
    return self.v_obj
end

function M:TryPop()
	self.v_last_touch_time = GlobalUnityTime
	if self.v_count > 0 then
		local obj = self.v_pool[self.v_count]

        obj:SetActive(true)
		obj.transform:SetPosition(0, 0, 0)
		self.v_count = self.v_count - 1
		return obj
	end

	local obj = ResMgr:Instantiate(self.v_obj)
	return obj
end

function M:ReleaseObj(obj)
	if self.v_count >= self.v_max_free_count then
		ResMgr:Destroy(obj)
		return
	end

	self.v_count = self.v_count + 1
	self.v_pool[self.v_count] = obj

	local obj_transform = obj.transform
	obj:SetActive(false)
	obj_transform:SetParent(self.v_root, false)

	self.v_last_touch_time = GlobalUnityTime
end

function M:CheckTimer()
	if self.v_count > 0 and GlobalUnityTime - self.v_last_touch_time > self.v_max_cache_time then
		self:Clear()
		return true
	end

	return false
end

function M:IsSimplePool()
	return true
end

function M:Clear()
	if self.v_count <= 0 then
		return
	end

	for i = 1, self.v_count do
		ResMgr:Destroy(self.v_pool[i])
	end

	self.v_pool = {}
	self.v_count = 0
end

return M

