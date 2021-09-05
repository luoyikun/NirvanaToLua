local ResUtil = require "resmanager/res_util"
local ResUtil = require "resmanager/res_util"
local Base = require "resmanager/loader_base"

local UnityGameObject = UnityEngine.GameObject
local UnityDestroy = UnityGameObject.Destroy
local TypeUnityGameObject = typeof(UnityGameObject)

local M = ResUtil.create_child_mt(Base)
local wait_load_obj_queue = {}
local wait_load_gameobj_queue = {}

function M:_init()
	Base._init(self)
	self.v_goid_prefab_map = {}
	self.v_goid_go_monitors = {}
	self.v_goid_go_monit_time = 0
	self.loadscene_t = nil
end

function M:Update(time, delta_time)
	Base.Update(self, time, delta_time)
	EditorResourceMgr.SweepOriginalInstanceIdMap()
	self:UpdateQueueLoad()
	self:MonitorGameObjLive(time)
	self:UpdateSceneLoad()
end

function M:GetPrefab(instance_id)
	return self.v_goid_prefab_map[instance_id]
end

-- 监测obj的是否已被称除，逻辑层往往在因为父节点移除而没有调Destroy的方法
function M:MonitorGameObjLive(time)
	if time < self.v_goid_go_monit_time then
		return
	end

	self.v_goid_go_monit_time = time + 1

	local die_goids = {}
	local monitor_count = 0
	for k, v in pairs(self.v_goid_go_monitors) do
		monitor_count = monitor_count + 1
		if v:Equals(nil) then
			table.insert(die_goids, k)
		end
	end

	for _, v in ipairs(die_goids) do
		self:ReleaseInObjId(v)
	end

	if #die_goids > 0 then
		print(string.format("[BundleLoader] monitor_count=%s, die_gameobj count=%s", monitor_count, #die_goids))
	end
end

function M:Destroy(gameobj)
	if IsNil(gameobj) then
		return
	end
	
	self:ReleaseInObjId(gameobj:GetInstanceID())
	UnityDestroy(gameobj)
end

function M:ReleaseInObjId(instance_id)
	if nil ~= self.v_goid_prefab_map[instance_id] then
		ResPoolMgr:Release(self.v_goid_prefab_map[instance_id])
		self.v_goid_go_monitors[instance_id] = nil
		self.v_goid_prefab_map[instance_id] = nil
	end
end

function M:IsCanSafeUseBundle(bundle_name)
	return true
end

function M:UpdateQueueLoad()
	if #wait_load_obj_queue > 0 then
		local count = 3 + math.ceil(#wait_load_obj_queue / 3)
		count = math.min(#wait_load_obj_queue, count)
		while count > 0 do
			count = count - 1
			local t = table.remove(wait_load_obj_queue, 1)
			self:InternalLoadObject(t.bundle_name, t.asset_name, t.asset_type, t.cb, t.cbdata)
		end
	end

	if #wait_load_gameobj_queue > 0 then
		local count = 3 + math.ceil(#wait_load_gameobj_queue / 3)
		count = math.min(#wait_load_gameobj_queue, count)
		while count > 0 do
			count = count - 1
			local t = table.remove(wait_load_gameobj_queue, 1)
			self:_InternalLoadGameobj(t.bundle_name, t.asset_name, t.cb, t.cbdata, true)
		end
	end
end

function M:LoadLocalLuaManifest()
end

function M:LoadRemoteLuaManifest(callback)
	callback()
end

function M:LoadLocalManifest()
end

function M:LoadRemoteManifest(name, callback)
	callback()
end

-- 异步加载资源(texture, prefab, matierl等)
function M:__LoadObjectAsync(bundle_name, asset_name, asset_type, cb, cbdata)
	table.insert(wait_load_obj_queue, {bundle_name = bundle_name, asset_name = asset_name, asset_type = asset_type, cb = cb, cbdata = cbdata})
end

-- 同步加载资源(texture, prefab, matierl等)
function M:__LoadObjectSync(bundle_name, asset_name, asset_type, cb, cbdata)
	self:InternalLoadObject(bundle_name, asset_name, asset_type, cb, cbdata)
end

function M:InternalLoadObject(bundle_name, asset_name, asset_type, cb, cbdata)
	asset_type = asset_type or TypeUnityGameObject
	local obj = EditorResourceMgr.LoadObject(bundle_name, asset_name, asset_type)
	if IsNil(obj) then
		print_error("[SimulationLoader] load object error", bundle_name, asset_name)
	else
		BundleCache:AddRef(bundle_name)
	end

	cb(obj, cbdata)
end

-- 异步加载Prefab并实例化GameObject
function M:LoadGameobjAsync(bundle_name, asset_name, cb, cbdata)
	table.insert(wait_load_gameobj_queue, {bundle_name = bundle_name, asset_name = asset_name, cb = cb, cbdata = cbdata})
end

function M:LoadGameobjAsyncInQueue(bundle_name, asset_name, cb, cbdata)
	table.insert(wait_load_gameobj_queue, {bundle_name = bundle_name, asset_name = asset_name, cb = cb, cbdata = cbdata})
end

-- 同步加载Prefab并实例化GameObject
function M:LoadGameobjSync(bundle_name, asset_name, cb, cbdata)
	self:_InternalLoadGameobj(bundle_name, asset_name, cb, cbdata, false)
end

function M:_InternalLoadGameobj(bundle_name, asset_name, cb, cbdata, is_async)
	ResPoolMgr:GetPrefab(bundle_name, asset_name, function (prefab)
		if nil == prefab then
			print_error("[SimulationLoader] load gameobject error", bundle_name, asset_name)
			cb(nil, cbdata)
			return
		end

		local gameobj = self:Instantiate(prefab, true)
		local instance_id = gameobj:GetInstanceID()
		self.v_goid_go_monitors[instance_id] = gameobj
		self.v_goid_prefab_map[instance_id] = prefab

		cb(gameobj, cbdata)

	end, is_async)
end


function M:UseBundle(bundle_name)
	BundleCache:AddRef(bundle_name)
end

function M:ReleaseBundle(bundle_name)
	BundleCache:DelRef(bundle_name)
end

function M:UpdateBundle(bundle_name, update_delegate, complete)
	complete()
end

function M:GetBundlesWithoutCached(bundle_name)
	return nil
end

function M:Instantiate(res, dont_destroy)
	local go = Base.Instantiate(self, res, dont_destroy)
	EditorResourceMgr.CacheOrginalInstanceMapping(go, res)
	return go
end

function M:UpdateSceneLoad()
	if nil ~= self.v_load_scene_t 
		and nil ~= self.v_load_scene_t.loadscene_op 
		and self.v_load_scene_t.loadscene_op.isDone then
		self.v_load_scene_t.callback(true)
		self.v_load_scene_t = nil
	end
end

function M:LoadUnitySceneAsync(bundle_name, asset_name, load_mode, callback)
	local loadscene_op =  EditorResourceMgr.LoadLevelAsync(bundle_name, asset_name, load_mode)
	if not loadscene_op then
		print_error("[SimulationLoader] load level async error: ", bundle_name, " ", asset_name)
	end

	callback(loadscene_op)
end

function M:LoadUnitySceneSync(bundle_name, asset_name, load_mode, callback)
	if not EditorResourceMgr.LoadLevelSync(bundle_name, asset_name, load_mode) then
		print_error("[SimulationLoader] load level error: ", bundle_name, " ", asset_name)
	end

	callback()
end

function M:UnloadScene(bundle_name, asset_name)
end

function M:GetBundleDeps(bundle_name)
	return {}
end

function M:GetDebugGameObjCount(t)
	t.gameobj_count = 0
	for _, v in pairs(self.v_goid_prefab_map) do
		t.gameobj_count = t.gameobj_count + 1
	end
end

return M

