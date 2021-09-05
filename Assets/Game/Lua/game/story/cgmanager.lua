local TypeUnityGameObject = typeof(UnityEngine.GameObject)

CgManager = CgManager or BaseClass()
function CgManager:__init()
	if CgManager.Instance ~= nil then
		ErrorLog("[CgManager] attempt to create singleton twice!")
		return
	end
	CgManager.Instance = self

	self.cg = nil
	self.cache_prefab_list = {}
end

function CgManager:__delete()
	if nil ~= self.cg then
		self.cg:DeleteMe()
		self.cg = nil
	end

	CgManager.Instance = nil
end

function CgManager:Play(cg, end_callback, start_callback, is_jump_cg)
	if nil == cg or cg == self.cg then
		return
	end

	if nil ~= self.cg then
		self.cg:Stop()
		self.cg:DeleteMe()
	end

	self.cg = cg
	local main_role = Scene.Instance:GetMainRole()
	if main_role then
		main_role:StopMove()	-- 玩家停止移动
		main_role:QingGongEnable(false)
	end
	GuajiCtrl.Instance:ClearAllOperate()	-- 停止所有操作

	self.cg:Play(function ()
			self.cg:DeleteMe()
			self.cg = nil
			end_callback()
		end, start_callback, is_jump_cg)
end

function CgManager:Stop()
	if nil ~= self.cg then
		self.cg:Stop()
		self.cg:DeleteMe()
		self.cg = nil
	end
end

function CgManager:IsCgIng()
	return nil ~= self.cg
end

-- 预加载cg prefab到缓存，引用计数会+1，用完后记得DelCacheCg
function CgManager:PreloadCacheCg(bundle_name, asset_name, callback)
	ResPoolMgr:GetPrefab(bundle_name, asset_name, function(prefab)
		table.insert(self.cache_prefab_list, {prefab = prefab, bundle_name = bundle_name, asset_name = asset_name})
		if nil ~= callback then
			callback()
		end
	end, true)
end

function CgManager:DelCacheCgs()
	for k,v in pairs(self.cache_prefab_list) do
		ResPoolMgr:Release(v.prefab)
	end
	self.cache_prefab_list = {}
end

function CgManager:DelCacheCg(bundle_name, asset_name)
	for i=#self.cache_prefab_list, 1, -1 do
		local t = self.cache_prefab_list[i]
		if t.bundle_name == bundle_name and t.asset_name == asset_name then
			table.remove(self.cache_prefab_list, i)
			ResPoolMgr:Release(t.prefab)
		end
	end
end