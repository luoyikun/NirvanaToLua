require("game/common/ui_scene")
require("game/common/ui_tween")

local develop_mode = require("editor/develop_mode")
BaseView = BaseView or BaseClass()

local TypeCamera = typeof(UnityEngine.Camera)
local TypeCanvas = typeof(UnityEngine.Canvas)

local _tinsert = table.insert
local _sformat = string.format

CloseMode = {
	CloseVisible = 1,			-- 隐藏
	CloseDestroy = 2,			-- 延时销毁
}

UICameraMode = {
	UICameraLow = 1,
	UICameraMid = 2,
	UICameraHigh = 3,
}

UiLayer = {
	SceneName = 0,				-- 场景名字
	FloatText = 1,				-- 飘字
	MainUILow = 2,				-- 主界面(低)
	MainUI = 3,					-- 主界面
	MainUIHigh = 4,				-- 主界面(高)
	Normal = 5,					-- 普通界面
	Pop = 6,					-- 弹出框
	PopTop = 7,					-- 弹出框(高)
	Guide = 8,					-- 引导层
	SceneLoading = 9,			-- 场景加载层
	SceneLoadingPop = 10,		-- 场景加载层上的弹出层
	Disconnect = 11,			-- 断线面板弹出层
	Standby = 12,				-- 待机遮罩
	MaxLayer = 13
}

ViewCacheTime = {
	LEAST = 5,
	NORMAL = 60,
	MOST = 3000,
}

local UIRoot = GameObject.Find("GameRoot/UILayer").transform

local UICamera1 = GameObject.Find("GameRoot/UICamera"):GetComponent(TypeCamera)
local UICamera2 = GameObject.Find("GameRoot/UICamera2"):GetComponent(TypeCamera)
local UICamera3 = GameObject.Find("GameRoot/UICamera3"):GetComponent(TypeCamera)

local BaseViewObj = GameObject.Find("GameRoot/UILayer/BaseView")
BaseViewObj:SetActive(false)

local CameraModeToCamera = {
	[UICameraMode.UICameraLow] = UICamera1,
	[UICameraMode.UICameraMid] = UICamera2,
	[UICameraMode.UICameraHigh] = UICamera3,
}

function BaseView.SetAllUICameraEnable(enabled)
	for _, v in pairs(CameraModeToCamera) do
		v.enabled = enabled
	end
end

function BaseView:__init(view_name)
	self.close_mode = CloseMode.CloseDestroy				-- 默认关闭后会销毁
	self.view_layer = UiLayer.Normal
	self.camera_mode = UICameraMode.UICameraHigh

	self.ui_config = nil									-- {bundle_name, prefab_name}
	self.full_screen = false								-- 是否是全屏界面
	self.vew_cache_time = ViewCacheTime.LEAST				-- 界面缓存时间
	self.is_async_load = false								-- 是否异步加载
	self.is_check_reduce_mem = false						-- 是否检查减少内存
	self.is_safe_area_adapter = false						-- IphoneX适配
	self.safe_area_adapter_check_time = 2

	self.active_close = true								-- 是否可以主动关闭(用于关闭所有界面操作)
	self.fight_info_view = false

	self.root_node = nil									-- UI根节点

	self.is_loading = false									-- 是否加载中
	self.is_open = false									-- 是否已打开
	self.is_rendering = false								-- 是否渲染
	self.is_real_open = false								-- 是否已打开

	self.flush_param_t = nil								-- 界面刷新参数

	self.def_index = 0										-- 默认显示的标签
	self.last_index = nil									-- 上次显示的标签
	self.show_index = -1									-- 当前显示的标签

	self.is_modal = false									-- 是否模态
	self.background_opacity = 165
	self.is_any_click_close = false							-- 是否点击其它地方要关闭界面
	self.is_bindgold_click = true 							-- 绑定元宝是否添加监听

	self.open_tween = nil
	self.close_tween = nil

	self.audio_config = AudioData.Instance:GetAudioConfig()
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].DefaultOpen)				-- 打开面板音效
		self.close_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].DefaultClose)				-- 关闭面板音效
	end
	self.play_audio = false									-- 播放音效

	if nil ~= view_name and "" ~= view_name then
		self.view_name = view_name							-- 界面名字 在view_def.lua中定义
		ViewManager.Instance:RegisterView(self, view_name)
	end

	self.node_list = {}
end

function BaseView:__delete()
	self:Release()
end

function BaseView:Release()
	self.is_loading = false
	if nil == self.root_node then
		return
	end

	if self.__gameobj_loaders then
		ReleaseGameobjLoaders(self)
	end

	if self.__res_loaders then
		ReleaseResLoaders(self)
	end

	self:CancelReleaseTimer()
	self:ReleaseCallBack()

	if self.mask_bg then
		if self.mask_bg.gameObject then
			ResMgr:Destroy(self.mask_bg.gameObject)
		end
		self.mask_bg = nil
	end

	ResMgr:Destroy(self.root_node)
	self.root_node = nil
	
	self.safe_adapter = nil
	self.last_index = nil
	self.show_index = -1

	self.is_open = false
	self.is_rendering = false
	self.is_real_open = false
	self.flush_param_t = nil
	self:CancelDelayFlushTimer()
	self:CancelDelayCloseTimer()
	self:RemoveSafeAdapterUpdate()

	self.root_parent = nil
	self.root_childrens = nil

	if develop_mode:IsDeveloper() then
		develop_mode:OnReleaseView(self)
	end

	self.node_list = nil
end

function BaseView:GetCamera(camera_mode)
	return camera_mode and CameraModeToCamera[camera_mode] or UICamera3
end

function BaseView:CancelReleaseTimer()
	if nil ~= self.release_timer then
		GlobalTimerQuest:CancelQuest(self.release_timer)
		self.release_timer = nil
	end
end

function BaseView:LoadSprite(bundle_name, asset_name, callback)
	LoadSprite(self, bundle_name, asset_name, callback)
end

function BaseView:LoadSpriteAsync(bundle_name, asset_name, callback)
	LoadSpriteAsync(self, bundle_name, asset_name, callback)
end

function BaseView:LoadRawImage(arg0, arg1, arg2)
	LoadRawImage(self, arg0, arg1, arg2)
end

function BaseView:Load(index, is_jump)
	if nil == self.ui_config or self:IsLoaded() or self.is_loading then
		return
	end

	self.is_loading = true
	if self.is_real_open == false and self.is_open == false then
		self:Close()
		return
	end

	-- 存在一种情况，当界面关闭并且Release后，这个预制件加载回调PrefabLoadCallback接口才执行（比如快速重登面板：TipsDisconnectedView）
	-- 此时加载进内存的预制体引用丢失，造成内存泄漏，所以在这里清除下预制体
	if nil ~= self.root_node and not self:IsOpen() and not self.is_loading then
		ResMgr:Destroy(self.root_node)
	end

	local root_obj = ResMgr:Instantiate(BaseViewObj)
	if nil == root_obj then
		self.is_loading = false
		return
	end

	local canvas = root_obj:GetComponent(TypeCanvas)
	canvas.worldCamera = CameraModeToCamera[self.camera_mode] or UICamera3

	root_obj.name = self.view_name or "View"
	root_obj.transform:SetParent(UIRoot, false)
	root_obj:SetActive(true)
	
	self.root_node = root_obj
	self.root_parent = self.root_node.transform:Find("Root")

	if self.is_modal or self.is_any_click_close then
		self:CreateMaskBg()
	end

	self.ui_tab_config = {}
	self.root_childrens = {}

	for order, v in ipairs(self.ui_config) do
		local index_list = v[3]
		if nil ~= index_list then
			for _, tab_index in ipairs(index_list) do
				self.ui_tab_config[tab_index] = self.ui_tab_config[tab_index] or {}
				table.insert(self.ui_tab_config[tab_index], order)
			end
		else
			self.ui_tab_config[0] = self.ui_tab_config[0] or {}
			table.insert(self.ui_tab_config[0], order)
		end
	end

	local def_tab_cfg = self.ui_tab_config[0]
	if def_tab_cfg then
		local load_times_count = 0
		for _, order in ipairs(def_tab_cfg) do
			local res_cfg = self.ui_config[order]
			local bundle, asset = res_cfg[1], res_cfg[2]
			local def_load_callback = function(obj)
				if nil == obj then
					return
				end

				if develop_mode:IsDeveloper() then
					local image_list = obj:GetComponentsInChildren(typeof(UnityEngine.UI.Image))
					for i = 0, image_list.Length - 1 do
						local img = image_list[i]
						local btn = img.gameObject:GetComponent(typeof(UnityEngine.UI.Button))
						if nil ~= btn and img.color.r == 0 and img.color.g == 0 and img.color.b == 0 and img.color.a ~= 0 then
							print_warning(img.gameObject.name, "不要用这个节点做模态黑色半透明背景，请设置self.is_modal = true")
						end
					end
				end

				if self.is_real_open == false and self.is_open == false then
					self:SetActive(false, true)
					self:Close()
					return
				end

				obj.transform:SetParent(self.root_parent.transform)
				obj.name = string.gsub(obj.name, "%(Clone%)", "")
				self.root_childrens[order] = obj

				self.node_list = self.node_list or {}
				local name_table = obj:GetComponent(typeof(UINameTable))
				local node_list = U3DNodeList(name_table, self)
				for k, v in pairs(node_list) do
					if nil ~= self.node_list[k] then
						print_error("A node name repeat in " .. obj.name .. " self.node_list -->> " .. k)
					end
					self.node_list[k] = v
				end

				load_times_count = load_times_count + 1
				if load_times_count >= #def_tab_cfg then
					self.is_loading = false
					self:UpdateSortOrder()
					self:LoadCallBack()
					self:OpenIndex(index, is_jump)

					-- 添加界面顶部
					self:CreateTopIconClickListener()
				end
			end

			local pre_load_obj = ResPoolMgr:TryGetGameObject(bundle, asset)
			if nil ~= pre_load_obj then
				def_load_callback(pre_load_obj)
			else
				local async_loader = self.is_async_load and AllocAsyncLoader(self, "view_prefab_async_loader_" .. order) or AllocSyncLoader(self, "view_prefab_sync_loader_" .. order)
				async_loader:Load(bundle, asset, def_load_callback)
			end
		end
	end
end

function BaseView:CreateTopIconClickListener()
	if self.node_list["BaseFullPanel_3"] and self.node_list["ImgGold"] then
		self.node_list["ImgGold"].button:AddClickListener(function ()
			TipsCtrl.Instance:OpenItem({item_id = COMMON_CONSTS.VIRTUAL_ITEM_GOLD})
		end)
	end
	if self.is_bindgold_click then
		if self.node_list["BaseFullPanel_3"] and self.node_list["ImgBindGold"] then
			self.node_list["ImgBindGold"].button:AddClickListener(function ()
				TipsCtrl.Instance:OpenItem({item_id = COMMON_CONSTS.VIRTUAL_ITEM_BINDGOL})
			end)
		end
	end
end

function BaseView:CreateMaskBg()
	if nil ~= self.mask_bg then
		ResMgr:Destroy(self.mask_bg)
	end

	self.mask_bg = U3DObject(GameObject.New("Mask"))
	self.mask_bg.gameObject.layer = UnityEngine.LayerMask.NameToLayer("UI")

	local mask_bg_transform = self.mask_bg.transform
	mask_bg_transform:SetParent(self.root_node.transform, false)
	mask_bg_transform:SetAsFirstSibling()

	local image = self.mask_bg.gameObject:AddComponent(typeof(UnityEngine.UI.Image))
	local transparency = self.is_modal and (self.background_opacity / 255) or 0
	image.color = Color(0, 0, 0, transparency)
	image.raycastTarget = true

	if self.is_any_click_close then
		local button = self.mask_bg.gameObject:AddComponent(typeof(UnityEngine.UI.Button))
		button.transition = UnityEngine.UI.Selectable.Transition.None
		button:AddClickListener(function ()
			self:Close()
		end)
	end

	local rect = self.mask_bg.rect
	rect.anchorMin = Vector2(0, 0)
	rect.anchorMax = Vector2(1, 1)
	rect.anchoredPosition3D = Vector3(0, 0, 0)
	rect.sizeDelta = Vector2(0, 0)
end

function BaseView:SetMaskActive(bool)
	if self.mask_bg and self.mask_bg.gameObject then
		self.mask_bg:SetActive(bool)
	end
end

function BaseView:Open(index, is_jump)
	self.is_real_open = true
	index = index or self.def_index
	self:CancelReleaseTimer()

	if self.full_screen then
		AssetBundleMgr:ReqHighLoad()
	end

	if not self.is_open then
		if not self:IsLoaded() then
			self:Load(index, is_jump)
		else
			self:OpenIndex(index, is_jump)
		end
	else
		self:ShowIndex(index, is_jump)
	end 
end

function BaseView:OpenIndex(index, is_jump)
	self:SetActive(true)

	if self.full_screen and nil == self.delay_close_view_timer then
		self.delay_close_view_timer = GlobalTimerQuest:AddDelayTimer(function ()
			self:CancelDelayCloseTimer()
		end, 0)
	end
	self:OpenCallBack()
	self:ChangeToIndex(index, is_jump)

	if nil ~= self.open_tween then
		local tween, update_func, complete_func = self.open_tween(self)
		if nil ~= tween then
			tween:OnUpdate(function ()
				if nil ~= update_func then
					update_func()
				end
			end)
			tween:OnComplete(function ()
				if nil ~= complete_func then
					complete_func()
				end
			end)
		end
	end

	if self.open_audio_id and self.play_audio then
		AudioManager.PlayAndForget(self.open_audio_id.BundleName, self.open_audio_id.AssetName)
	end

	ViewManager.Instance:AddOpenView(self)
end

function BaseView:CancelDelayCloseTimer()
	if nil ~= self.delay_close_view_timer then
		GlobalTimerQuest:CancelQuest(self.delay_close_view_timer)
		self.delay_close_view_timer = nil
	end
end

function BaseView:ResetTransform(node)
	if nil ~= node then
		-- 重置坐标位置
		local transform = node.transform
		transform:SetLocalScale(1, 1, 1)
		local rect = transform:GetComponent(typeof(UnityEngine.RectTransform))
		rect.anchorMax = Vector2(1, 1)
		rect.anchorMin = Vector2(0, 0)
		rect.anchoredPosition3D = Vector3(0, 0, 0)
		rect.sizeDelta = Vector2(0, 0)
	end
end

function BaseView:UpdateSortOrder()
	if nil ~= self.root_childrens then
		for order = #self.ui_config, 1, -1 do
			local sub_node = self.root_childrens[order]
			if not IsNil(sub_node) then
				sub_node.transform:SetAsFirstSibling()
				self:ResetTransform(sub_node)
			end
		end
		if self.is_safe_area_adapter then
			self:SetSafeAdapter()
		end
	end
end

function BaseView:RemoveSafeAdapterUpdate()
	if self.safe_adapter_update then
		GlobalTimerQuest:CancelQuest(self.safe_adapter_update)
		self.safe_adapter_update = nil
	end
end

function BaseView:SetSafeAdapter()
	if SafeAreaAdpater then
		if not self.safe_adapter and nil ~= self.root_parent then
			self.safe_adapter = SafeAreaAdpater.Bind(self.root_parent.gameObject)
		end
	else
		if UnityEngine.Application.platform == UnityEngine.RuntimePlatform.IPhonePlayer
			and UnityEngine.iOS.Device.generation == UnityEngine.iOS.DeviceGeneration.iPhoneX then

			local rect = self.root_node.transform:GetComponent(typeof(UnityEngine.RectTransform))
			self:RemoveSafeAdapterUpdate()
			local end_time = Status.NowTime + self.safe_area_adapter_check_time
			self.safe_adapter_update = GlobalTimerQuest:AddRunQuest(function ()
				if nil == rect or IsNil(rect.gameObject) then
					self:RemoveSafeAdapterUpdate()
					return
				end
				if rect.offsetMin.x ~= 66 or rect.offsetMax.x ~= -66 then
					rect.offsetMin = Vector2(66, 0)
					rect.offsetMax = Vector2(-66, 0)
				end
				if Status.NowTime > end_time then
					self:RemoveSafeAdapterUpdate()
				end
			end, 0.1)
		end
	end
end

function BaseView:Close(...)
	if nil ~= self.delay_close_view_timer then
		return
	end

	self.is_real_open = false
	if not self.is_open then
		self:CloseDestroy()
		return
	end

	if self.full_screen then
		AssetBundleMgr:ReqLowLoad()
	end

	if self.close_audio_id and self.play_audio then
		AudioManager.PlayAndForget(self.close_audio_id.BundleName, self.close_audio_id.AssetName)
	end

	self:CloseCallBack(...)

	if nil ~= self.close_tween then
		local tween, update_func, complete_func = self.close_tween(self)
		if nil ~= tween then
			tween:OnUpdate(function ()
				if nil ~= update_func then
					update_func()
				end
			end)
			tween:OnComplete(function ()
				if self.is_real_open then
					self.is_open = false
					self:Open()
				else
					if nil ~= complete_func then
						complete_func()
					end
					self:OnViewClose()
				end
			end)
		end
	else
		self:OnViewClose()
	end
end

function BaseView:OnViewClose()
	if self.close_mode == CloseMode.CloseVisible then
		self:CloseVisible()
	elseif self.close_mode == CloseMode.CloseDestroy then
		self:CloseDestroy()
	end
end

function BaseView:CloseVisible()
	self.is_real_open = false

	self:HideIndex(self.show_index)

	self.show_index = -1
	if self:IsOpen() then
		ViewManager.Instance:RemoveOpenView(self)
	end
	self:SetActive(false)
	self:CancelDelayFlushTimer()
end

function BaseView:CloseDestroy()
	self:CloseVisible()
	if nil == self.release_timer then
		self.release_timer = GlobalTimerQuest:AddDelayTimer(function()
			self.release_timer = nil
			self:Release()
		end, self.vew_cache_time)
	end
end

function BaseView:ChangeToIndex(index, is_jump)
	if not self:IsOpen() then
		return
	end

	self:ShowIndex(index, is_jump)
	self:FlushHelper()
end

function BaseView:ShowIndex(index, is_jump)
	if not self:IsLoaded() then
		return
	end

	if self.show_index == index then
		return
	end
	if nil == index then
		print_log("BaseView:ShowIndex index == nil")
		return
	end

	self:HideIndex(self.show_index)

	self.last_index = self.show_index
	self.show_index = index

	local cur_tab_cfg = self.ui_tab_config[index]
	if cur_tab_cfg then
		local load_count = 0
		local index_nodes = {}
		for _, order in ipairs(cur_tab_cfg) do
			local sub_node = self.root_childrens[order]
			if nil == sub_node then
				local res_cfg = self.ui_config[order]
				local bundle, asset = res_cfg[1], res_cfg[2]
				local callback = function(obj)
					if nil == obj then
						return
					end

					obj.transform:SetParent(self.root_parent.transform)
					obj.name = string.gsub(obj.name, "%(Clone%)", "")
					self.root_childrens[order] = obj

					load_count = load_count + 1
					index_nodes[asset] = obj
					if load_count >= #cur_tab_cfg then
						self:UpdateSortOrder()
						self:ShowIndexCallBack(index, index_nodes, is_jump)
					end
					obj:SetActive(self.show_index == index)
				end
				local async_loader = self.is_async_load and AllocAsyncLoader(self, "view_prefab_async_loader_" .. order) or AllocSyncLoader(self, "view_prefab_sync_loader_" .. order)
				async_loader:Load(bundle, asset, callback)
			else
				sub_node:SetActive(true)

				load_count = load_count + 1
				if load_count >= #cur_tab_cfg then
					self:ShowIndexCallBack(index, nil, is_jump)
				end
			end
		end
	else
		self:ShowIndexCallBack(index, nil, is_jump)
	end
end

function BaseView:HideIndex(show_index)
	if nil == self.ui_tab_config then
		return
	end

	local last_tab_cfg = self.ui_tab_config[show_index]
	if show_index > 0 and last_tab_cfg then
		for _, order in ipairs(last_tab_cfg) do
			if self.root_childrens[order] then
				self.root_childrens[order]:SetActive(false)
			end
		end
	end
end

function BaseView:SetActive(active, force)
	if self.is_open ~= active or force then
		self.is_open = active
		self.is_rendering = active
		self:SetRootNodeActive(active)
	end

	if IS_AUDIT_VERSION then
		local color = GLOBAL_CONFIG.param_list.ui_skin_color
		if "" ~= color and nil ~= color then
			self:ChangeColorInIosAudit(active, color)
		end
	end
end

function BaseView:ChangeColorInIosAudit(active, color)
	if active then
		self.ios_audit_change_color = GlobalTimerQuest:AddRunQuest(function ()
			if self.root_node then
				IosAudit.ChangeUISkinColor(self.root_node, color)
			end
		end, 0)
	else
		if nil ~= self.ios_audit_change_color then
			GlobalTimerQuest:CancelQuest(self.ios_audit_change_color)
			self.ios_audit_change_color = false
		end
	end
end

function BaseView:SetRendering(value)
	if self.is_rendering ~= value then
		self.is_rendering = value
		self:SetRootNodeActive(value)
	end
end

function BaseView:SetRootNodeActive(value)
	if nil ~= self.root_node then
		self.root_node:SetActive(value)
		if value and self.is_safe_area_adapter then
			self:SetSafeAdapter()
		end
	end
	if value then
		self:UpdateSortOrder()
	end
end

function BaseView:CanActiveClose()
	return self.active_close
end

function BaseView:GetLayer()
	return self.view_layer
end

function BaseView:IsOpen()
	return self.is_open
end

function BaseView:IsRealOpen()
	return self.is_real_open
end

function BaseView:IsRendering()
	return self.is_rendering
end

function BaseView:IsLoaded()
	return nil ~= self.root_node and not self.is_loading
end

function BaseView:GetRootNode()
	return self.root_node
end

function BaseView:Flush(key, value_t)
	key = key or "all"
	value_t = value_t or {"all"}

	self.flush_param_t = self.flush_param_t or {}
	for k, v in pairs(value_t) do
		self.flush_param_t[key] = self.flush_param_t[key] or {}
		self.flush_param_t[key][k] = v
	end
	if nil == self.delay_flush_timer and self:IsLoaded() and self:IsOpen() then
		self.delay_flush_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.FlushHelper, self), 0)
	end
end

function BaseView:FlushHelper()
	self:CancelDelayFlushTimer()

	if not self:IsOpen() or not self:IsLoaded() then
		return
	end

	if nil ~= self.flush_param_t then
		local param_list = self.flush_param_t
		self.flush_param_t = nil
		self:OnFlush(param_list)
	end
end

function BaseView:CancelDelayFlushTimer()
	if self.delay_flush_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.delay_flush_timer)
		self.delay_flush_timer = nil
	end
end

function BaseView:GetViewName()
	return self.view_name or ""
end

function BaseView:GetShowIndex()
	return self.show_index
end

function BaseView:GetLastIndex()
	return self.last_index
end
----------------------------------------------------
-- 继承 begin
----------------------------------------------------

-- 创建完调用
function BaseView:LoadCallBack()
	-- override
end

-- 打开后调用
function BaseView:OpenCallBack()
	-- override
end

-- 切换标签调用
function BaseView:ShowIndexCallBack(index, obj, is_jump)
	-- override
end

-- 关闭前调用
function BaseView:CloseCallBack()
	-- override
end

-- 销毁前调用
function BaseView:ReleaseCallBack()
	-- override
end

-- 刷新
function BaseView:OnFlush(param_list)
	-- override
end

-- 从自己面板打开其他面板
function BaseView:OtherOpenView()
	-- override
end

----------------------------------------------------
-- 继承 end
----------------------------------------------------
