-- 异步加载器
local GameObjLoader = GameObjLoader or BaseClass()
local LoaderLayer = GameObject.Find("GameRoot/LoaderLayer").transform
function GameObjLoader:__init(parent_transform)
	self.name = "GameObjLoader"
	self.cur_t = nil
	self.wait_t = nil

	self.parent_transform = parent_transform or LoaderLayer
	
	self.is_active = true
	self.local_pos_v3 = nil
	self.local_scale_v3 = nil
	self.local_rotation_euler = nil

	self.is_use_objpool = false
	self.is_in_queue = false
    self.is_async = true
    self.is_loading = false

    self.obj_alive_time = nil
    self.del_obj_timer = nil
end

function GameObjLoader:__delete()
	if not self.__is_had_del_in_cache then
		self.__is_had_del_in_cache = true
		if nil ~= self.__loader_key and nil ~= self.__loader_owner and nil ~= self.__loader_owner.__gameobj_loaders then
			self.__loader_owner.__gameobj_loaders[self.__loader_key] = nil
		end
	end

	self:Destroy()
	self.parent_transform = nil
	self.cur_t = nil
	self.wait_t = nil
end

function GameObjLoader:Destroy()
	self:CancleDieTimer()

	if nil ~= self.cur_t then
		if IsNil(self.cur_t.gameobj) then
			if self.is_use_objpool then
				ResPoolMgr:ReleaseInObjId(self.cur_t.instance_id)
			else
				ResMgr:ReleaseInObjId(self.cur_t.instance_id)
			end
		else
			if self.is_use_objpool then
		        ResPoolMgr:Release(self.cur_t.gameobj)
			else
		        ResMgr:Destroy(self.cur_t.gameobj)
			end
		end

		self.cur_t = nil
	end
end

function GameObjLoader:_DestoryObj(obj)
	if IsNil(obj) then
		return
	end

	if self.is_use_objpool then
        ResPoolMgr:Release(obj)
	else
        ResMgr:Destroy(obj)
	end
end

function GameObjLoader:CancleDieTimer()
	if nil ~= self.del_obj_timer then
		GlobalTimerQuest:CancelQuest(self.del_obj_timer)
		self.del_obj_timer = nil
	end
end

function GameObjLoader:_DelayDelObj()
	if nil ~= self.obj_alive_time then
		self.del_obj_timer = GlobalTimerQuest:AddDelayTimer(function ()
			self.del_obj_timer = nil
			self:Destroy()
		end, self.obj_alive_time)
	end
end

function GameObjLoader:SetObjAliveTime(obj_alive_time)
	self:CancleDieTimer()
	self.obj_alive_time = obj_alive_time
	self:_DelayDelObj()
end

function GameObjLoader:SetIsASyncLoad(is_async)
	self.is_async = is_async
end

function GameObjLoader:SetIsUseObjPool(is_use_objpool)
	self.is_use_objpool = is_use_objpool
end

function GameObjLoader:SetIsInQueueLoad(is_in_queue)
	self.is_in_queue = is_in_queue
end

function GameObjLoader:SetParent(parent_transform)
	self.parent_transform = parent_transform
end

function GameObjLoader:SetLocalPosition(local_pos_v3)
	self.local_pos_v3 = local_pos_v3

	if self.cur_t ~= nil and not IsNil(self.cur_t.gameobj) then
		 self.cur_t.gameobj.transform.localPosition = self.local_pos_v3
	end
end

function GameObjLoader:SetLocalScale(local_scale_v3)
	self.local_scale_v3 = local_scale_v3

	if self.cur_t ~= nil and not IsNil(self.cur_t.gameobj) then
		self.cur_t.gameobj.transform.localScale = local_scale_v3
	end
end

function GameObjLoader:SetLocalRotation(local_rotation_euler)
	self.local_rotation_euler = local_rotation_euler

	if self.cur_t ~= nil and not IsNil(self.cur_t.gameobj) then
		self.cur_t.gameobj.transform.localRotation = local_rotation_euler
	end
end

function GameObjLoader:SetActive(active)
	if self.is_active ~= active then
		self.is_active = active
		if self.cur_t ~= nil and not IsNil(self.cur_t.gameobj) then
			self.cur_t.gameobj:SetActive(active)
		end
	end
end

function GameObjLoader:Load(bundle_name, prefab_name, load_callback)
	if nil == bundle_name or "" == bundle_name 
        or nil == prefab_name or "" == prefab_name then
        return
    end

    -- 如果是跟上次加载的资源相同则不再进行请求加载，并且若资源已存在则直接回调处理
	if nil == load_callback 
		and nil ~= self.cur_t
		and self.cur_t.bundle_name == bundle_name 
		and self.cur_t.prefab_name == prefab_name then
		return
	end

    -- 如果正在加载则等待
    if self.is_loading then
        self.wait_t = {bundle_name = bundle_name, prefab_name = prefab_name, load_callback = load_callback}
    else
        self:Destroy()
        self:DoLoad({bundle_name = bundle_name, prefab_name = prefab_name, load_callback = load_callback})
    end
end

function GameObjLoader:DoLoad(load_t)
	self.is_loading = true

    if self.is_use_objpool then
    	if self.is_async then
    		if self.is_in_queue then
				ResPoolMgr:GetDynamicObjAsyncInQueue(
			            load_t.bundle_name,
			            load_t.prefab_name,
			            BindTool.Bind(self.LoadComplete, self, load_t))
    		else
				ResPoolMgr:GetDynamicObjAsync(
			            load_t.bundle_name,
			            load_t.prefab_name,
			            BindTool.Bind(self.LoadComplete, self, load_t))
    		end
    	else
    		ResPoolMgr:GetDynamicObjSync(
	            load_t.bundle_name,
	            load_t.prefab_name,
	            BindTool.Bind(self.LoadComplete, self, load_t))
    	end
    else
    	if self.is_async then
    		ResMgr:LoadGameobjAsync(
	            load_t.bundle_name,
	            load_t.prefab_name,
	            BindTool.Bind(self.LoadComplete, self, load_t))
    	else
			ResMgr:LoadGameobjSync(
	            load_t.bundle_name,
	            load_t.prefab_name,
	            BindTool.Bind(self.LoadComplete, self, load_t))
    	end
    end
end

 -- 当加载完后检查此次加载返回上请求的是不是同一个。
 -- 如果不是（即外部已发起新的请求或者加载器已删除），则释放掉当前加载的，再进行新的加载
function GameObjLoader:LoadComplete(load_t, gameobj)
	self.is_loading = false

	 -- 如果是有等待加载的资源则释放当前加载的,并执行新的加载
	if nil ~= self.wait_t then
		self:_DestoryObj(gameobj)
		local t = self.wait_t
		self.wait_t = nil
        self:DoLoad(t)
        return
	end

	-- 如果是空对象则，这里不敢再调callback了？？
	if IsNil(gameobj) then
		return
	end

	-- 如果父节点已释放，则直接删除obj
	if IsNil(self.parent_transform) then
		self:_DestoryObj(gameobj)
		return
	end

	if nil ~= self.cur_t then
        print_error("[GameObjLoader] OnLoadComplete big bug", load_t.bundle_name, load_t.asset_name)
    end

	self.cur_t = load_t
	self.cur_t.gameobj = gameobj
	self.cur_t.instance_id = gameobj:GetInstanceID()

	gameobj.transform:SetParent(self.parent_transform, false)

	if self.local_pos_v3 then
		gameobj.transform.localPosition = self.local_pos_v3
	end

	if nil ~= self.local_scale_v3 then
		gameobj.transform.localScale = self.local_scale_v3
	end

	if nil ~= self.local_rotation_euler then
		gameobj.transform.localRotation = self.local_rotation_euler
	end

	gameobj:SetActive(self.is_active)

	local lock_rotation = gameobj:GetComponent(typeof(LockRotation))
	if lock_rotation then
		local off_y = DownAngleOfCamera or 0
		lock_rotation:SetOffY(off_y - 180)
		lock_rotation:SetParentTransform(self.parent_transform)
	end

	self:CancleDieTimer()
	self:_DelayDelObj()

	if nil ~= load_t.load_callback then
		local load_callback = load_t.load_callback
        load_t.load_callback = nil
		load_callback(gameobj)
	end
end

return GameObjLoader