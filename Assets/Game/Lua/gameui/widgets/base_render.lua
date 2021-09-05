BaseRender = BaseRender or BaseClass()

local TypeUnitySprite = typeof(UnityEngine.Sprite)
local _tinsert = table.insert

function BaseRender:__init(instance)
	self.root_node = nil
	if instance ~= nil then
		self:SetInstance(instance)
	end

	self.global_event_map = {}
	self.flush_param_t = nil								-- 界面刷新参数

	self.control_render_list = {}
end

function BaseRender:__delete()
	for k, _ in pairs(self.global_event_map) do
		GlobalEventSystem:UnBind(k)
	end
	self.global_event_map = {}
	self.node_list = nil
	self.control_render_list = nil

	self.root_node = nil
	self:CancelDelayFlushTimer()
end

function BaseRender:SetInstance(instance)
	-- UI根节点, 支持instance是GameObject或者U3DObject
	if type(instance) == "userdata" then
		self.root_node = U3DObject(instance)
	else
		self.root_node = instance
	end

	local name_table = instance:GetComponent(typeof(UINameTable))			-- 名字绑定
	self.node_list = U3DNodeList(name_table, self)
	self:LoadCallBack(instance)

	self:FlushHelper()
end

function BaseRender:LoadAsset(bundle_name, asset_name, parent, callback)
	local async_loader = AllocAsyncLoader(self, "base_asset_loader")
	async_loader:SetParent(parent)
	async_loader:Load(bundle_name, asset_name, function(obj)
		if IsNil(obj) then
			return
		end
		-- 这里不用处理BaseRender被delete了的情况
		-- 因为被delete后，不会调用这个回调函数了
		self:SetInstance(obj)
		if nil ~= callback then
			callback(obj)
		end
	end)
end

function BaseRender:SetInstanceParent(instance_parent)
	self.root_node.transform:SetParent(instance_parent.transform, false)
end

function BaseRender:AddControlRender(name, render)
	self.control_render_list[name] = render
end

-- 外部通知刷新，调用此接口
function BaseRender:Flush(key, value_t)
	key = key or "all"
	value_t = value_t or {"all"}

	self.flush_param_t = self.flush_param_t or {}
	for k, v in pairs(value_t) do
		self.flush_param_t[key] = self.flush_param_t[key] or {}
		self.flush_param_t[key][k] = v
	end
	if nil == self.delay_flush_timer and self.root_node ~= nil then
		self.delay_flush_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.FlushHelper, self), 0)
	end
end

function BaseRender:FlushHelper()
	self:CancelDelayFlushTimer()

	if self.root_node == nil then
		return
	end

	if nil ~= self.flush_param_t then
		local param_list = self.flush_param_t
		self.flush_param_t = nil
		self:OnFlush(param_list)
	end
end

function BaseRender:CancelDelayFlushTimer()
	if self.delay_flush_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.delay_flush_timer)
		self.delay_flush_timer = nil
	end
end

function BaseRender:SetActive(active)
	self.root_node:SetActive(active)
end

function BaseRender:SetParentActive(active)
	self.root_node.transform.parent.gameObject:SetActive(active)
end

function BaseRender:IsNil()
	return IsNil(self.root_node and self.root_node.gameObject)
end

-- 是否打开过
function BaseRender:IsOpen()
	return self.root_node and true or false
end

function BaseRender:GetRootNode()
	return self.root_node
end

function BaseRender:BindGlobalEvent(event_id, event_func)
	local handle = GlobalEventSystem:Bind(event_id, event_func)
	self.global_event_map[handle] = event_id
	return handle
end

function BaseRender:UnBindGlobalEvent(handle)
	GlobalEventSystem:UnBind(handle)
	self.global_event_map[handle] = nil
end

----------------------------------------------------
-- 可重写继承的接口 begin
----------------------------------------------------
function BaseRender:LoadCallBack(instance)
	-- override
end

-- 刷新(用Flush刷新OnFlush的方法必须是有用LoadCallBack加载完成的时候使用,否则有可能引起报错)
function BaseRender:OnFlush(param_list)
end


----------------------------------------------------
-- 可重写继承的接口 end
----------------------------------------------------

function BaseRender:LoadSprite(bundle_name, asset_name, callback)
	LoadSprite(self, bundle_name, asset_name, callback)
end

function BaseRender:LoadSpriteAsync(bundle_name, asset_name, callback)
	LoadSpriteAsync(self, bundle_name, asset_name, callback)
end

function BaseRender:LoadRawImage(arg0, arg1, arg2)
	LoadRawImage(self, arg0, arg1, arg2)
end

