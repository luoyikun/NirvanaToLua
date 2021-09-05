local TypeRawImage = typeof(UnityEngine.UI.RawImage)
local TypeImage = typeof(UnityEngine.UI.Image)
local TypeRichTextGroup = typeof(RichTextGroup)
local TypeActorAttachEffect = typeof(ActorAttachEffect)
local TypePageViewSimpleDelegate = typeof(PageViewSimpleDelegate)
local TypeGameObjectAttach = typeof(Game.GameObjectAttach)
local TypeGameLoadRawImage = typeof(Game.LoadRawImage)
local TypeTexture2D = typeof(UnityEngine.Texture2D)

local UserDataKey = "__userdata__"

local function component_func_wrap(value, key)
	return function(self, ...)
		local component = rawget(self, "__meta__")
		value(component, ...)
	end
end

local function handle_func_wrap(caches, table, key)
	local value = caches[key]
	if value then
		return value
	end

	local component = rawget(table, "__meta__")
	if IsNil(component) then
		return nil
	end

	value = component[key]
	if value and type(value) == "function" then
		value = component_func_wrap(value)
		caches[key] = value
	end

	return value
end

local RawImageFunctionCaches = {}
local ImageFunctionCaches = {}
local ActorAttachEffectCaches = {}
local RichTextFunctionCaches = {}

local component_metatable = {
	[TypeRawImage] = function(table, key)
		if key == "LoadSprite" or key == "LoadURLSprite" or key == "LoadSpriteAsync" then
			local base_view = rawget(table, UserDataKey)
			return base_view["LoadRawImage"]
		elseif key == "__metaself__" then
			return rawget(table, UserDataKey)
		else
			return handle_func_wrap(RawImageFunctionCaches, table, key)
		end
	end,

	[TypeImage] = function(table, key)
		if key == "LoadSprite" or key == "LoadSpriteAsync" then
			local base_view = rawget(table, UserDataKey)
			return base_view[key]
		elseif key == "__metaself__" then
			return rawget(table, UserDataKey)
		else
			return handle_func_wrap(ImageFunctionCaches, table, key)
		end
	end,

	[TypeActorAttachEffect] = function(table, key)
		if key == "PlayEffect" then
			local draw_part = rawget(table, UserDataKey)
			return draw_part[key]
		elseif key == "StopEffect" then
			local draw_part = rawget(table, UserDataKey)
			return draw_part[key]
		elseif key == "__metaself__" then
			return rawget(table, UserDataKey)
		else
			return handle_func_wrap(ActorAttachEffectCaches, table, key)
		end
	end,

	[TypeRichTextGroup] = function(table, key)
		if key == "__metaself__" then
			return rawget(table, UserDataKey)
		else
			return handle_func_wrap(RichTextFunctionCaches, table, key)
		end
	end,
}

local function create_component_metable(component, index, userdata)
	return setmetatable(
		{
			__meta__ = component,
			is_component = true,
			[UserDataKey] = userdata,
		},

		{
			__index = index,
			__newindex = function(t, k, v)
				component[k] = v
			end
		})
end

local component_table = {
	-- 基础组件
	transform = typeof(UnityEngine.Transform),
	camera = typeof(UnityEngine.Camera),
	renderer = typeof(UnityEngine.Renderer),
	animation = typeof(UnityEngine.Animation),
	animator = typeof(UnityEngine.Animator),
	collider = typeof(UnityEngine.Collider),
	audio = typeof(UnityEngine.AudioSource),
	light = typeof(UnityEngine.Light),
	line_renderer = typeof(UnityEngine.LineRenderer),

	-- UI相关组件
	rect = typeof(UnityEngine.RectTransform),
	canvas = typeof(UnityEngine.Canvas),
	canvas_group = typeof(UnityEngine.CanvasGroup),
	image = TypeImage,
	raw_image = TypeRawImage,
	text = typeof(UnityEngine.UI.Text),
	button = typeof(UnityEngine.UI.Button),
	toggle = typeof(UnityEngine.UI.Toggle),
	toggle_group = typeof(UnityEngine.UI.ToggleGroup),
	slider = typeof(UnityEngine.UI.Slider),
	scroll_rect = typeof(UnityEngine.UI.ScrollRect),
	input_field = typeof(UnityEngine.UI.InputField),
	dropdown = typeof(UnityEngine.UI.Dropdown),
	scroller = typeof(EnhancedUI.EnhancedScroller.EnhancedScroller),
	accordion_element = typeof(AccordionElement),
	grayscale = typeof(UIGrayscale),
	rich_text = TypeRichTextGroup,
	grid_layout_group = typeof(UnityEngine.UI.GridLayoutGroup),
	playable_director = typeof(UnityEngine.Playables.PlayableDirector),
	shadow = typeof(UnityEngine.UI.Shadow),
	outline = typeof(UnityEngine.UI.Outline),

	-- 自定义UI组件
	list_cell = typeof(ListViewCell),
	list_delegate = typeof(ListViewDelegate),
	list_simple_delegate = typeof(ListViewSimpleDelegate),
	list_page_scroll = typeof(ListViewPageScroll),
	list_page_scroll2 = typeof(ListViewPageScroll2),
	page_view = typeof(PageView),
	list_view = typeof(Nirvana.ListView),
	page_simple_delegate = typeof(PageViewSimpleDelegate),
	joystick = typeof(UIJoystick),
	ui3d_display = typeof(UI3DDisplay),
	uiprefab_loader = typeof(UIPrefabLoader),
	load_raw_image_url = typeof(Nirvana.LoadRawImageURL),
	graphic = typeof(UnityEngine.UI.Graphic),
	ui_gradient = typeof(UIGradient),
	uiname_table = typeof(UINameTable),

	-- 自定义3D组件
	move_obj = typeof(MoveableObject),
	actor_attachment = typeof(ActorAttachment),
	actor_ctrl = typeof(ActorController),
	actor_fadout = typeof(ActorFadeout),
	actor_attach_effect = TypeActorAttachEffect,
	attach_obj = typeof(AttachObject),
	camera_follow = typeof(CameraFollow),
	click_manager = typeof(ClickManager),
	clickable_obj = typeof(ClickableObject),
	uidrag = typeof(UIDrag),
	event_trigger_listener = typeof(EventTriggerListener),
	attach_skin = typeof(AttachSkin),
	attach_skin_obj = typeof(AttachSkinObject),
	uifollow_target = typeof(UIFollowTarget),
	uifollow_distance = typeof(UIFollowDistance),
	actorRender = typeof(ActorRender),
	
	load_raw_image = TypeGameLoadRawImage,
}

local u3d_shortcut = {}
function u3d_shortcut:SetActive(active)
	self.gameObject:SetActive(active)
end

function u3d_shortcut:GetActive()
	return self.gameObject.activeInHierarchy
end

function u3d_shortcut:GetActiveSelf()
	return self.gameObject.activeSelf
end

function u3d_shortcut:FindObj(name_path)
	local transform = self.transform:FindHard(name_path)
	if transform == nil then
		return nil
	end

	return U3DObject(transform.gameObject, transform)
end

function u3d_shortcut:GetComponent(type)
	return self.gameObject:GetComponent(type)
end

function u3d_shortcut:GetOrAddComponent(type)
	return self.gameObject:GetOrAddComponent(type)
end

function u3d_shortcut:GetComponentsInChildren(type)
	return self.gameObject:GetComponentsInChildren(type)
end

function u3d_shortcut:SetLocalPosition(x, y, z)
	self.transform:SetLocalPosition(x or 0, y or 0, z or 0)
end

function u3d_shortcut:ChangeAsset(bundle_name, asset_name, silent)
	local game_obj_attach = rawget(self, "game_obj_attach")
	if game_obj_attach == nil then
		game_obj_attach = self.gameObject:GetComponent(TypeGameObjectAttach)
		self.game_obj_attach = game_obj_attach
	end

	if not silent then
		assert(game_obj_attach, "Need GameObjectAttach Component")
	elseif not game_obj_attach then
		return
	end

	local old_bundle_name = game_obj_attach.BundleName
	local old_asset_name = game_obj_attach.AssetName

	if not bundle_name or not asset_name then
		bundle_name = game_obj_attach.BundleName
		asset_name = game_obj_attach.AssetName
	else
		game_obj_attach.BundleName = bundle_name
		game_obj_attach.AssetName = asset_name
	end

	if bundle_name and bundle_name ~= "" and asset_name and asset_name ~= "" and not self.game_obj_attach:IsSceneOptimize() then
		self.__attach_gameobj_loader = self.__attach_gameobj_loader or GameObjAttachEventHandle.AllocLoader(self.game_obj_attach)
		self.__attach_gameobj_loader:SetIsUseObjPool(true)
		self.__attach_gameobj_loader:SetIsInQueueLoad(true)
		self.__attach_gameobj_loader:Load(bundle_name, asset_name, function (obj)
		end)
		if old_bundle_name ~= bundle_name and old_asset_name ~= asset_name then
			self.game_obj_attach.enabled = false
			self.game_obj_attach.enabled = true
		end
		
	elseif nil ~= self.__attach_gameobj_loader then
		self.__attach_gameobj_loader:DeleteMe()
		self.__attach_gameobj_loader = nil
	end
end

function u3d_shortcut:ChangeRawImageAsset(bundle_name, asset_name)
	local load_raw_image = self.load_raw_image

	if not bundle_name or not asset_name then
		bundle_name = load_raw_image.BundleName
		asset_name = load_raw_image.AssetName
	else
		load_raw_image.BundleName = bundle_name
		load_raw_image.AssetName = asset_name
	end

	if bundle_name and bundle_name ~= "" and asset_name and asset_name ~= "" then
		self.__raw_image_loader = self.__raw_image_loader or LoadRawImageEventhandle.AllocLoader(self.transform)
		self.__raw_image_loader:Load(bundle_name, asset_name, TypeTexture2D, function(texture)
			if texture then
				load_raw_image:SetTexture(texture)
			end
		end)
	elseif nil ~= self.__raw_image_loader then
		self.__raw_image_loader:DeleteMe()
		self.__raw_image_loader = nil
	end
end

local u3d_metatable = {
	__index = function(table, key)
		if IsNil(table.gameObject) then
			return nil
		end

		local key_type = component_table[key]
		if key_type ~= nil then
			local component = table.gameObject:GetComponent(key_type)
			if component ~= nil then
				local metatable = component_metatable[key_type]
				local data

				if metatable then
					data = create_component_metable(component, metatable, table[UserDataKey])
				else
					data = component
				end

				table[key] = data
				return data
			end
		end

		return u3d_shortcut[key]
	end
}

function U3DObject(go, transform, userdata)
	if go == nil then
		return nil
	end

	local obj = {gameObject = go, transform = transform, [UserDataKey] = userdata}
	setmetatable(obj, u3d_metatable)
	return obj
end

function U3DNodeList(name_table, userdata)
	local node_list = {}
	if nil ~= name_table then
		local map = name_table.Lookup
		local iter = map:GetEnumerator() 
		while iter:MoveNext() do
			node_list[iter.Current.Key] = U3DObject(iter.Current.Value, nil, userdata)
		end
	end
	return node_list
end
