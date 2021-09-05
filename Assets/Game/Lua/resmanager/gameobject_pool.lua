local ResUtil = require "resmanager/res_util"

local localPosition = Vector3(0, 0, 0)
local localRotation = Quaternion.Euler(0, 0, 0)
local localScale = Vector3(1, 1, 1)

local M = ResUtil.create_class()
function M:_init(root, v_act_root, full_path)
    self.v_root = root
    self.v_act_root = v_act_root
    self.full_path = full_path or "none"

    self.v_cache_count = 0
    self.v_cache_gos = {}

    self.v_orginal_transform_info = nil
    self.v_use_times = 0
    self.v_ref_count = 0
    self.v_is_valid_pool = true
end

function M:CacheOrginalTransformInfo(prefab)
    if nil == prefab then
        print_error("[GameObjPool] CacheOrginalTransformInfo big bug, prefab is nil", self.full_path)
        return
    end

    self.v_orginal_transform_info = {prefab.transform.localPosition, prefab.transform.localRotation, prefab.transform.localScale}
end

function M:GetCacheCount()
    return self.v_cache_count
end

function M:Release(gameobj)
    if not self.v_is_valid_pool then
        print_error("[GameObjPool] Release big bug, the pool is invalid")
        ResMgr:Destroy(gameobj)
        return false
    end

    self.v_ref_count = self.v_ref_count - 1
    if self.v_ref_count < 0 then
        print_error("[GameObjPool] Release big bug, v_ref_count less 0")
        return false
    end

    if self.v_cache_count >= 64 then
        ResMgr:Destroy(gameobj)
        return true
    end

    self.v_cache_count = self.v_cache_count + 1
    self.v_cache_gos[gameobj] = GlobalUnityTime + self:GetCacheTime(self.v_use_times)

    gameobj:SetActive(false)
    gameobj.transform:SetParent(self.v_root, false)

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

function M:GetGameObjIsCache(gameobj)
    return nil ~= self.v_cache_gos[gameobj]
end

function M:ReleaseInObjId(cid)
    if not self.v_is_valid_pool then
        print_error("[GameObjPool] ReleaseInObjId big bug, the pool is invalid")
        return false
    end

    self.v_ref_count = self.v_ref_count - 1
    if self.v_ref_count < 0 then
        print_error("[GameObjPool] Release big bug, v_ref_count less 0")
        return false
    end

    return true
end

function M:TryPop()
    if not self.v_is_valid_pool then
        print_error("[GameObjPool] TryPop big bug, the pool is invalid")
        return false
    end

    self.v_ref_count = self.v_ref_count + 1
    if self.v_cache_count <= 0 then
        return nil
    end

    local gameobj = next(self.v_cache_gos)
    gameobj:SetActive(true)
    gameobj.transform:SetParent(self.v_act_root, false)
    if nil ~= self.v_orginal_transform_info then
        gameobj.transform.localPosition = self.v_orginal_transform_info[1]
        gameobj.transform.localRotation = self.v_orginal_transform_info[2]
        gameobj.transform.localScale = self.v_orginal_transform_info[3]
    else
        gameobj.transform.localPosition = localPosition
        gameobj.transform.localRotation = localRotation
        gameobj.transform.localScale = localScale
    end

    self.v_cache_gos[gameobj] = nil
    self.v_cache_count = self.v_cache_count - 1
    self.v_use_times = self.v_use_times + 1

    return gameobj
end

function M:Update(now_time)
    if not self.v_is_valid_pool then
        return false
    end
    
    local flag = false
    for k, v in pairs(self.v_cache_gos) do
        if now_time >= v then
            flag = true
            self.v_cache_count = self.v_cache_count - 1
            self.v_cache_gos[k] = nil
            ResMgr:Destroy(k)
            break
        end
    end

    if flag and self.v_cache_count <= 0 and self.v_ref_count <= 0 then
        self.v_is_valid_pool = false
    end

    return not self.v_is_valid_pool
end

function M:Clear()
    local flag = false
    for k,v in pairs(self.v_cache_gos) do
        flag = true
        ResMgr:Destroy(k)
    end

    self.v_cache_gos = {}
    self.v_cache_count = 0
    self.v_use_times = 0

    if flag and self.v_cache_count <= 0 and self.v_ref_count <= 0 then
        self.v_is_valid_pool = false
    end

    return not self.v_is_valid_pool
end

function M:OnDestroy()
    self:Clear()
end

function M:GetDebugStr()
    local debug_str = string.format("%s   count=%s\n", self.full_path, self.v_cache_count)

    return debug_str
end

return M

