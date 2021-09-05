local _sformat = string.format
local UnityWWW = UnityEngine.WWW

local TypeUnitySprite = typeof(UnityEngine.Sprite)
local TypeUnityTexture = typeof(UnityEngine.Texture)
local TypeGameLoadRawImage = typeof(Game.LoadRawImage)
local GameObjLoader = require("gameui/common/gameobj_loader")
local ResLoader = require("gameui/common/res_loader")

function LoadSprite(self, bundle_name, asset_name, callback)
	local image = self
	self = self.__metaself__

	local sprite_loader = AllocResSyncLoader(self, "image_" .. image.gameObject:GetInstanceID())
	image.enabled = not IsNil(image.sprite)

	if G_IsDeveloper then
		if not EditorResourceMgr.IsCanLoadAssetInGameObj(image.gameObject, bundle_name, asset_name) then
			-- return
		end
	end

	sprite_loader:Load(
		bundle_name, 
		asset_name, 
		TypeUnitySprite,
		function(sprite)
			if not IsNil(image) then
				image.sprite = sprite
				image.enabled = not IsNil(image.sprite)

				if callback then
					callback()
				end
			end
		end)
end

function LoadSpriteAsync(self, bundle_name, asset_name, callback)
	local image = self
	self = self.__metaself__

	local sprite_loader = AllocResAsyncLoader(self, "image_" .. image.gameObject:GetInstanceID())
	image.enabled = not IsNil(image.sprite)

	if G_IsDeveloper then
		if not EditorResourceMgr.IsCanLoadAssetInGameObj(image.gameObject, bundle_name, asset_name) then
			-- return
		end
	end

	sprite_loader:Load(
		bundle_name, 
		asset_name, 
		TypeUnitySprite,
		function(sprite)
			if not IsNil(image) then
				image.sprite = sprite
				image.enabled = not IsNil(image.sprite)

				if callback then
					callback()
				end
			end
		end)
end

function LoadRawImage(self, arg0, arg1, arg2)
	-- print_log("load rawimage ", arg0, arg1, arg2)
	local raw_image = self
	self = self.__metaself__

	raw_image.enabled = not IsNil(raw_image.texture)

	if arg1 and type(arg1) == "string" then
		local bundle_name = arg0
		local asset_name = arg1
		local callback = arg2

		local load_raw_image = raw_image.gameObject:GetComponent(TypeGameLoadRawImage)
		local texture_loader = load_raw_image and LoadRawImageEventhandle.AllocLoader(load_raw_image) or AllocResSyncLoader(self, "rawimage_" .. raw_image.gameObject:GetInstanceID())
		texture_loader:Load(
			bundle_name,
			asset_name,
			TypeUnityTexture,
			function(texture)
				if not IsNil(raw_image) then
					raw_image.texture = texture
					raw_image.enabled = not IsNil(raw_image.texture)

					if callback then
						callback()
					end
				end
			end)
	else
		local image_path = arg0
		local callback = arg1

		if UNITY_EDITOR_WIN or UNITY_STANDALONE_WIN then
			if not image_path:find("file:///.*") and
				not image_path:find("http://.*") then

				image_path = "file:///" .. image_path
			end
		else
			if not image_path:find("file://.*") and
				not image_path:find("http://.*") then
				image_path = "file://" .. image_path
			end
		end

		coroutine.start(function()
			local www = UnityWWW(image_path)
			coroutine.www(www)

			local err = www.error
			if err and err ~= "" then
				local err_msg = _sformat("LoadSprite %s for RawImage failed: %s", image_path, err)
				print_error(err_msg)
				return
			end

			local tex = www.texture
			if IsNil(tex) then
				local err_msg = _sformat("LoadSprite %s for RawImage is not a texture", image_path)
				print_error(err_msg)
				return
			end

			if not IsNil(raw_image.texture) then
				ResMgr:Destroy(raw_image.texture)
			end

			raw_image.enabled = true
			raw_image.texture = tex

			www:Dispose()

			if callback then
				callback()
			end
		end)
	end
end

function PlayEffect(self)
	local asset = self
	self = self.__metaself__
	local loader = AllocAsyncLoader(self, "effect_id_" .. asset.gameObject:GetInstanceID())
	loader:SetParent(asset.transform)
	loader:Load(
		asset.EffectAsset.BundleName,
		asset.EffectAsset.AssetName,
		nil)
end

function StopEffect(self)
	local asset = self
	self = self.__metaself__
	DelGameObjLoader(self, "effect_id_" .. asset.gameObject:GetInstanceID())
end

local _AllocLoader = function(self, is_async, loader_key)
	if nil == loader_key or "" == loader_key or "string" ~= type(loader_key) then
		print_error("Your async_loader has no loader_key !! loader_key ==", loader_key)
	end

	if nil == self.__gameobj_loaders then
		self.__gameobj_loaders = {}
	end

	if self.__gameobj_loaders[loader_key] then
		self.__gameobj_loaders[loader_key]:SetIsASyncLoad(is_async)
		return self.__gameobj_loaders[loader_key]
	end

	local gameobj_loader = GameObjLoader.New()
	gameobj_loader.__loader_key = loader_key
	gameobj_loader.__loader_owner = self
	gameobj_loader:SetIsASyncLoad(is_async)
	self.__gameobj_loaders[loader_key] = gameobj_loader

	return gameobj_loader
end

-- 异步读成GameObject
-- 用法：
-- 唯一、带key:					AllocAsyncLoader(self, "scroller_window_gameobj_loader")

function AllocAsyncLoader(self, arg0)
	return _AllocLoader(self, true, arg0)
end

-- 同步读成GameObject
function AllocSyncLoader(self, arg0)
	return _AllocLoader(self, false, arg0)
end

function DelGameObjLoader(self, loader_key)
	if self.__gameobj_loaders and self.__gameobj_loaders[loader_key] then
		local t = self.__gameobj_loaders[loader_key]
		self.__gameobj_loaders[loader_key] = nil
		t.__is_had_del_in_cache = true
		t:DeleteMe()
	end
end

function ReleaseGameobjLoaders(self)
	for _, gameobj_loader in pairs(self.__gameobj_loaders) do
		gameobj_loader.__is_had_del_in_cache = true
		gameobj_loader:DeleteMe()
	end
	
	self.__gameobj_loaders = nil
end

local _AllocResLoader = function(self, is_async, loader_key)
	if nil == loader_key or "" == loader_key or "string" ~= type(loader_key) then
		print_error("Your res_async_loader has no loader_key !! loader_key ==", loader_key)
		return
	end
	
	if nil == self.__res_loaders then
		self.__res_loaders = {}
	end

	local res_loader = self.__res_loaders[loader_key]
	if not res_loader then
		res_loader = ResLoader.New()
		res_loader.__loader_key = loader_key
		res_loader.__loader_owner = self
		self.__res_loaders[loader_key] = res_loader
	end

	res_loader:SetIsASyncLoad(is_async)

	return res_loader
end

-- 异步读资源的(未实例化)
-- 唯一、带key:					AllocResAsyncLoader(self, "scroller_window_gameobj_loader")
function AllocResAsyncLoader(self, loader_key)
	return _AllocResLoader(self, true, loader_key)
end

-- 异步读资源的(未实例化)
-- 唯一、带key:					AllocResSyncLoader(self, "scroller_window_gameobj_loader")
function AllocResSyncLoader(self, loader_key)
	return _AllocResLoader(self, false, loader_key)
end

function DestroyResLoader(self, loader_key)
	if self.__res_loaders and self.__res_loaders[loader_key] then
		local t = self.__res_loaders[loader_key]
		self.__res_loaders[loader_key] = nil
		t.__is_had_del_in_cache = true
		t:DeleteMe()
	end
end

function ReleaseResLoaders(self)
	local loader_count = 0
	for _, res_loader in pairs(self.__res_loaders) do
		res_loader.__is_had_del_in_cache = true
		res_loader:DeleteMe()
		loader_count = loader_count + 1
	end
	if loader_count > 200 then
		print_warning("[Load Util] your code is very bad! too many resloaders " .. loader_count, self.view_name)
	end
	self.__res_loaders = nil
end