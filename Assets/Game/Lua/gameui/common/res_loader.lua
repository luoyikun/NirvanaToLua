local TypeUnityTexture = typeof(UnityEngine.Texture)
local TypeUnitySprite = typeof(UnityEngine.Sprite)
local TypeUnityMaterial = typeof(UnityEngine.Material)
local TypeUnityPrefab = typeof(UnityEngine.GameObject)
local TypeAudioMixer = typeof(UnityEngine.Audio.AudioMixer)
local TypeActorQingGongObject = typeof(ActorQingGongObject)
local TypeQualityConfig = typeof(QualityConfig)

local POOL_TYPE_TBL = {
    [TypeUnityTexture] = ResPoolMgr.GetTexture,
    [TypeUnitySprite] = ResPoolMgr.GetSprite,
    [TypeUnityMaterial] = ResPoolMgr.GetMaterial,
    [TypeUnityPrefab] = ResPoolMgr.GetPrefab,
    [TypeAudioMixer] = ResPoolMgr.GetAudioMixer,
    [TypeActorQingGongObject] = ResPoolMgr.GetQingGongObj,
    [TypeQualityConfig] = ResPoolMgr.GetQualityConfig,
}

local ResLoader = ResLoader or BaseClass()

function ResLoader:__init()
    self.is_deleted = false
    self.cur_t = nil
    self.wait_t = nil

    self.is_async = true
    self.is_loading = false
end

function ResLoader:__delete()
    if not self.__is_had_del_in_cache then
        self.__is_had_del_in_cache = true
        if nil ~= self.__loader_key and nil ~= self.__loader_owner and nil ~= self.__loader_owner.__res_loaders then
            self.__loader_owner.__res_loaders[self.__loader_key] = nil
        end
    end

    self:Destroy()

    self.is_deleted = true
    self.cur_t = nil
    self.wait_t = nil
end

function ResLoader:Destroy()
    if nil ~= self.cur_t then
        if nil ~= self.cur_t.res then
            ResPoolMgr:Release(self.cur_t.res)
        end
        self.cur_t = nil
    end
end

function ResLoader:SetIsASyncLoad(is_async)
    self.is_async = is_async
end

function ResLoader:Load(bundle_name, asset_name, asset_type, load_callback)
    asset_type = asset_type or TypeUnityPrefab

    if nil == bundle_name or "" == bundle_name 
        or nil == asset_name or "" == asset_name then
        return
    end

    if nil == POOL_TYPE_TBL[asset_type] then
        print_error("[ResLoader] load fail, not support asset_type", bundle_name, asset_name)
        return
    end

    -- 如果是跟上次加载的资源相同则不再进行请求加载，并且若资源已存在则直接回调处理
    if nil == load_callback 
        and nil ~= self.cur_t
        and self.cur_t.bundle_name == bundle_name 
        and self.cur_t.asset_name == asset_name 
        and self.cur_t.asset_type == asset_type then
        return
    end

    -- 如果正在加载则等待
    if self.is_loading then
        self.wait_t = {bundle_name = bundle_name, asset_name = asset_name, asset_type = asset_type, load_callback = load_callback}
    else
        self:Destroy()
        self:DoLoad({bundle_name = bundle_name, asset_name = asset_name, asset_type = asset_type, load_callback = load_callback})
    end
end

function ResLoader:DoLoad(load_t)
    self.is_loading = true
    POOL_TYPE_TBL[load_t.asset_type](
            ResPoolMgr,
            load_t.bundle_name,
            load_t.asset_name,
            BindTool.Bind(self.OnLoadComplete, self, load_t),
            self.is_async)
end

function ResLoader:OnLoadComplete(load_t, res)
    self.is_loading = false

    -- 如果加载器已被释放则释放当前加载完成的
    if self.is_deleted then
        if nil ~= res then
            ResPoolMgr:Release(res)
        end

        return
    end

    -- 如果是有等待加载的资源则释放当前加载的
    if nil ~= self.wait_t then
        if nil ~= res then
            ResPoolMgr:Release(res)
        end

        local t = self.wait_t
        self.wait_t = nil
        self:DoLoad(t)
        return
    end

    if nil ~= self.cur_t then
        print_error("[ResLoader] OnLoadComplete big bug", load_t.bundle_name, load_t.asset_name)
    end

    self.cur_t = load_t
    self.cur_t.res = res
    if nil ~= load_t.load_callback then
        local load_callback = load_t.load_callback
        load_t.load_callback = nil
        load_callback(res)
    end   
end

return ResLoader

