local ResUtil = require "resmanager/res_util"
local GameObjectPool = require "resmanager/gameobject_pool"
local ResPool = require "resmanager/res_pool"

local TypeUnityTexture = typeof(UnityEngine.Texture)
local TypeUnitySprite = typeof(UnityEngine.Sprite)
local TypeUnityMaterial = typeof(UnityEngine.Material)
local TypeUnityPrefab = typeof(UnityEngine.GameObject)
local TypeAudioItem = typeof(AudioItem)
local TypeAudioMixer = typeof(UnityEngine.Audio.AudioMixer)
local TypeActorQingGongObject = typeof(ActorQingGongObject)
local TypeQualityConfig = typeof(QualityConfig)

local M = ResUtil.create_class()
function M:_init()
    self.v_used_pools = {}

    self.v_root = ResMgr:CreateEmptyGameObj("GameObjectPool", true)
    self.v_root_transform = self.v_root.transform
    self.v_root:SetActive(false)

    self.v_root_act = ResMgr:CreateEmptyGameObj("GameObjectPoolAct", true)
    self.v_root_act_transform = self.v_root_act.transform

    self.v_res_pools = {}
    self.v_gameobj_pools = {}
    self.v_get_gameobj_queue = {}

    self.next_check_pool_release_time = 0
end

function M:OnGameStop()
    if nil ~= self.v_root then
        ResMgr:Destroy(self.v_root)
        self.v_root = nil
    end
    
    if nil ~= self.v_root_act then
        ResMgr:Destroy(self.v_root_act)
        self.v_root_act = nil
    end
end

function M:GetRoot()
    return self.v_root
end

function M:Startup()
    Runner.Instance:AddRunObj(self)
end

function M:Update(now_time, elapse_time)
    self:QueueGetGameObject()
    self:UpdateAllPool(now_time)
    self:ResumeInvalidTransform(self.v_root_transform)
    self:ResumeInvalidTransform(self.v_root_act_transform)
end

function M:GetSprite(bundle_name, asset_name, callback, is_async)
    if nil == string.find(asset_name, ".png") then
        asset_name = asset_name .. ".png"
    end
    self:_GetRes(bundle_name, asset_name, TypeUnitySprite, callback, is_async, false)
end

function M:GetTexture(bundle_name, asset_name, callback, is_async)
    if nil == string.find(asset_name, ".png") and nil == string.find(asset_name, ".jpg") then
        print_error("[ResPoolMgr] if you want to load texture, you must specified .jpg or .png!!", bundle_name, asset_name)
        callback(nil)
        return
    end

    self:_GetRes(bundle_name, asset_name, TypeUnityTexture, callback, is_async, false)
end

function M:GetQualityConfig(bundle_name, asset_name, callback, is_async)
    self:_GetRes(bundle_name, asset_name, TypeQualityConfig, callback, is_async, false)
end

function M:GetQingGongObj(bundle_name, asset_name, callback, is_async)
    self:_GetRes(bundle_name, asset_name, TypeActorQingGongObject, callback, is_async, false)
end

function M:GetAudioMixer(bundle_name, asset_name, callback, is_async)
    self:_GetRes(bundle_name, asset_name, TypeAudioMixer, callback, is_async, false)
end

function M:GetAudio(bundle_name, asset_name, callback, is_async)
    self:_GetRes(bundle_name, asset_name, TypeAudioItem, callback, is_async, false)
end

function M:GetMaterial(bundle_name, asset_name, callback, is_async)
    if nil == string.find(asset_name, ".mat") then
        asset_name = asset_name .. ".mat"
    end

    self:_GetRes(bundle_name, asset_name, TypeUnityMaterial, callback, is_async, false)
end

function M:TryGetMaterial(bundle_name, asset_name)
    if nil == string.find(asset_name, ".mat") then
        asset_name = asset_name .. ".mat"
    end

    local pool = self.v_res_pools[bundle_name]
    return pool ~= nil and pool:GetRes(asset_name) or nil
end

function M:GetPrefab(bundle_name, asset_name, callback, is_async, is_in_queue)
    if nil == string.find(asset_name, ".prefab") then
        asset_name = asset_name .. ".prefab"
    end

    self:_GetRes(bundle_name, asset_name, TypeUnityPrefab, callback, is_async, is_in_queue)
end

function M:TryGetPrefab(bundle_name, asset_name)
    if nil == string.find(asset_name, ".prefab") then
        asset_name = asset_name .. ".prefab"
    end

    local pool = self.v_res_pools[bundle_name]
    return pool ~= nil and pool:GetRes(asset_name) or nil
end

function M:ScanRes(bundle_name, asset_name)
    if nil ~= self.v_res_pools[bundle_name] then
        return self.v_res_pools[bundle_name]:ScanRes(asset_name)
    end

    return nil
end

function M:GetResPoolAssetCount(bundle_name)
    if nil ~= self.v_res_pools[bundle_name] then
        return self.v_res_pools[bundle_name].v_asset_count
    else
        return 0
    end
end

function M:GetOrCreateResPool(bundle_name)
    local pool = self.v_res_pools[bundle_name]
    if nil == pool then
        pool = ResPool:new(bundle_name)
        self.v_res_pools[bundle_name] = pool
    end

    return pool
end

function M:_GetRes(bundle_name, asset_name, asset_type, callback, is_async, is_in_queue)
    local asset = self:_TryGetRes(bundle_name, asset_name)
    if nil ~= asset then
        callback(asset)
        return
    end

    self:_LoadRes(bundle_name, asset_name, asset_type, callback, is_async, is_in_queue)
end

function M:_TryGetRes(bundle_name, asset_name)
    --得到bundle的缓冲池
    local pool = self:GetOrCreateResPool(bundle_name)
    local asset = pool:GetRes(asset_name)
    if nil == asset then
        return nil
    end

    local instance_id = asset:GetInstanceID()
    if nil ~= self.v_used_pools[instance_id] and self.v_used_pools[instance_id] ~= pool then
        print_error("[ResPoolMgr] _TryGetRes big bug!!!", bundle_name, asset_name)
    end
    self.v_used_pools[instance_id] = pool

    return asset
end

function M:_LoadRes(bundle_name, asset_name, asset_type, callback, is_async, is_in_queue)
    local load_fun = nil 
    if is_async then
        load_fun = ResMgr.__LoadObjectAsync
    else
        load_fun = ResMgr.__LoadObjectSync
    end
    
    load_fun(ResMgr, bundle_name, asset_name, asset_type, 
        function(asset)
            if nil == asset then
                callback(nil)
                return
            end

            local old_asset = self:_TryGetRes(bundle_name, asset_name)
            if nil ~= old_asset then
                if old_asset ~= asset then
                    print_error("[ResPoolMgr] _LoadRes big bug, old_asset is not same!!!", bundle_name, asset_name)
                end

                callback(old_asset)
                return
            end

            local pool = self:GetOrCreateResPool(bundle_name)
            pool:CacheRes(asset_name, asset)
            callback(self:_TryGetRes(bundle_name, asset_name))

        end, nil, is_in_queue)
end

function M:QueueGetGameObject()
    if #self.v_get_gameobj_queue > 0 then
        local t = table.remove(self.v_get_gameobj_queue, 1)
        self:_GetGameObject(t.bundle_name, t.asset_name, t.callback, t.is_async, true)
    end
end

function M:GetOrCreateGameObjPool(bundle_name, asset_name)
	local full_path = ResUtil.GetAssetFullPath(bundle_name, asset_name)
    local pool = self.v_gameobj_pools[full_path]
    if nil == pool then
        pool = GameObjectPool:new(self.v_root_transform, self.v_root_act_transform, full_path)
        self.v_gameobj_pools[full_path] = pool
    end

    return pool
end

function M:_GetGameObject(bundle_name, asset_name, callback, is_async, is_in_queue)
    if nil == string.find(asset_name, ".prefab") then
        asset_name = asset_name .. ".prefab"
    end

    local gameobj = self:_TryGetGameObject(bundle_name, asset_name)
    if nil ~= gameobj then
        callback(gameobj)
        return
    end

    self:_LoadGameObject(bundle_name, asset_name, callback, is_async, is_in_queue)
end

function M:_TryGetGameObject(bundle_name, asset_name)
    local pool = self:GetOrCreateGameObjPool(bundle_name, asset_name)
    local gameobj = pool:TryPop()
    if nil == gameobj then
        return nil
    end

    local instance_id = gameobj:GetInstanceID()
    if nil ~= self.v_used_pools[instance_id] and self.v_used_pools[instance_id] ~= pool then
        print_error("[ResPoolMgr] _TryGetGameObject big bug!!!", bundle_name, asset_name)
    end

    self.v_used_pools[instance_id] = pool

    return gameobj
end

function M:_LoadGameObject(bundle_name, asset_name, callback, is_async, is_in_queue)
    local load_fun = nil 
    if is_async then
        if is_in_queue then
            load_fun = ResMgr.LoadGameobjAsyncInQueue
        else
            load_fun = ResMgr.LoadGameobjAsync
        end
    else
        load_fun = ResMgr.LoadGameobjSync
    end

    load_fun(ResMgr, bundle_name, asset_name, 
        function (gameobj)
            if nil == gameobj then
                callback(nil)
                return
            end

            local pool = self:GetOrCreateGameObjPool(bundle_name, asset_name)
            local instance_id = gameobj:GetInstanceID()
            if nil ~= self.v_used_pools[instance_id] and self.v_used_pools[instance_id] ~= pool then
                print_error("[ResPoolMgr] _LoadGameObject big bug!!!", bundle_name, asset_name)
            end

            self.v_used_pools[instance_id] = pool
            pool:CacheOrginalTransformInfo(ResMgr:GetPrefab(instance_id))
            callback(gameobj)
        end)
end

function M:_GetGameObjectInPrefab(prefab)
    if nil == prefab then
        return nil
    end
    
    local pool = self.v_gameobj_pools[prefab]
    if nil == pool then
        pool = GameObjectPool:new(self.v_root_transform, self.v_root_act_transform)
        self.v_gameobj_pools[prefab] = pool
    end

    local gameobj = pool:TryPop()
    if nil ~= gameobj then
        local instance_id = gameobj:GetInstanceID()
        if nil ~= self.v_used_pools[instance_id] and self.v_used_pools[instance_id] ~= pool then
            print_error("[ResPoolMgr] _GetGameObjectInPrefab big bug!!!", prefab.name)
        end
        self.v_used_pools[instance_id] = pool

        return gameobj
    end

    local gameobj = ResMgr:Instantiate(prefab)
    local instance_id = gameobj:GetInstanceID()
    self.v_used_pools[instance_id] = pool
    pool:CacheOrginalTransformInfo(prefab)

    return gameobj
end

function M:GetEffectAsync(bundle_name, asset_name, callback)
    self:_GetGameObject(bundle_name, asset_name, callback, true, false)
end

function M:GetDynamicObjAsync(bundle_name, asset_name, callback)
    self:_GetGameObject(bundle_name, asset_name, callback, true, false)
end

function M:GetDynamicObjSync(bundle_name, asset_name, callback)
    self:_GetGameObject(bundle_name, asset_name, callback, false, false)
end

function M:GetDynamicObjAsyncInQueue(bundle_name, asset_name, callback)
    table.insert(self.v_get_gameobj_queue, {bundle_name = bundle_name, asset_name = asset_name, callback = callback, is_async = true})
end

function M:TryGetGameObject(bundle_name, asset_name)
    local prefab = self:TryGetPrefab(bundle_name, asset_name)
    return self:_GetGameObjectInPrefab(prefab)
end

function M:TryGetGameObjectInPrefab(prefab)
     return self:_GetGameObjectInPrefab(prefab)
end

function M:IsPoolObj(obj)
    if IsNil(obj) then return false end

    local cid = obj:GetInstanceID()
    return nil ~= self.v_used_pools[cid]
end

function M:Release(obj)
    if IsNil(obj) then return end

    local cid = obj:GetInstanceID()
    local pool = self.v_used_pools[cid]
    if nil == pool then
        print_error("[ResMgr] Release 释放一个没有pooled的 ", obj.name, cid)
        return
    end

    if pool:Release(obj) then
        self.v_used_pools[cid] = nil
    end
end

function M:ReleaseInObjId(cid)
    local pool = self.v_used_pools[cid]
    if nil == pool then
        print_error("[ResMgr] ReleaseInObjId 释放一个没有pooled的 ", cid)
        return
    end

    if pool:ReleaseInObjId(cid) then
        self.v_used_pools[cid] = nil
    end
end

function M:OnGameObjIllegalDestroy(cid)
    self.v_used_pools[cid] = nil
end

function M:IsInGameObjPool(cid, gameobj)
    local pool = self.v_used_pools[cid]
    return nil ~= pool and pool:GetGameObjIsCache(gameobj)
end

function M:Clear()
    self:ClearPools(self.v_gameobj_pools)
    self:ClearPools(self.v_res_pools)
end

function M:ClearPools(pools)
    local del_pool_list = {}
    for k, pool in pairs(pools) do
        if pool:Clear() then
            table.insert(del_pool_list, k)
        end
    end

    for _, v in ipairs(del_pool_list) do
        pools[v] = nil
    end
end

function M:UpdateAllPool(now_time)
    if now_time < self.next_check_pool_release_time then
        return
    end

    self.next_check_pool_release_time = now_time + 0.1

    self:UpdatePool(self.v_gameobj_pools, now_time)
    self:UpdatePool(self.v_res_pools, now_time)
end

function M:UpdatePool(pools, now_time)
    for k, pool in pairs(pools) do
        if pool:Update(now_time) then
            pools[k] = nil
            break
        end
    end
end

-- 检查对象池节transform属性是否为0，被修改将非常严重
function M:ResumeInvalidTransform(transform)
    if 0 ~= transform.localPosition.x or 0 ~= transform.localPosition.y or 0 ~= transform.localPosition.z then
        transform:SetLocalPosition(0, 0, 0)
        print_error("[ResourcePool] big bug!!!!, object pool be modified!!!!")
    end

    if 0 ~= transform.rotation.x or 0 ~= transform.rotation.y or 0 ~= transform.rotation.z then
        transform.localRotation = Quaternion.Euler(0, 0, 0)
        print_error("[ResourcePool] big bug!!!!, object pool be modified!!!!")
    end

    if 1 ~= transform.localScale.x or 1 ~= transform.localScale.y or 1 ~= transform.localScale.z then
        transform:SetLocalScale(1, 1, 1)
        print_error("[ResourcePool] big bug!!!!, object pool be modified!!!!")
    end
end

function M:GetPoolDebugInfo(t)
    t.res_count = 0
    t.res_pool_count = 0

    for k,v in pairs(self.v_res_pools) do
        t.res_pool_count = t.res_pool_count + 1
        t.res_count =  t.res_count + v:GetAssetCount()
    end

    t.gameobj_cache_count = 0
    t.gameobj_pool_count = 0
    for k,v in pairs( self.v_gameobj_pools) do
        t.gameobj_pool_count = t.gameobj_pool_count + 1
        t.gameobj_cache_count = t.gameobj_cache_count + v:GetCacheCount()
    end
end

-- debug
function M:CheckLeak()
    local res_pools = {
        self.v_res_pools,
        self.v_gameobj_pools,
    }

    local debug_str = ""
    for k,pools in ipairs(res_pools) do
        debug_str = debug_str .. "=================" .. k .. "=================\n"
        for _, v in pairs(pools) do
            debug_str = debug_str .. v:GetDebugStr()
        end
    end

    local file_path = UnityEngine.Application.dataPath .. "/../temp/res_pool.txt"
    print_log("已输出日志到", file_path)
    local f = assert(io.open(file_path,'w'))
    f:write(debug_str)
    f:close()
end

return M

