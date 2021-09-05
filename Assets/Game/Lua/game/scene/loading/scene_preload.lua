ScenePreload = ScenePreload or BaseClass()

ScenePreload.main_scene_bundle_name = ""
ScenePreload.main_scene_asset_name = ""
ScenePreload.detail_scene_bundle_name = ""
ScenePreload.detail_scene_asset_name = ""
ScenePreload.first_load = true
ScenePreload.cache_cg_t = {}

local LOAD_TYPE =
{
	DOWNLOAD = 1,				 	-- 下载bundle
	LOAD_MAIN_SCENE = 2,			-- 加载主场景
	LOAD_UNFREE_GAMEOBJECT = 3,		-- 加载不释放的gameobject(即长久在对象池中)
	LOAD_CG = 4,					-- 预加载CG
	REDUCE_MEM = 5,					-- 清理内存
	COMBINE_SCENE = 6,				-- 合并场景
}

function ScenePreload:__init(show_loading)
	self.progress_fun = nil
	self.main_complete_fun = nil
	self.complete_fun = nil
	self.load_list = {}
	self.load_num_once = 1		-- 每次加载个数
	self.loading_num = 0		-- 正在加载的数量
	self.update_retry_times = 0
	self.download_scene_id = 0
	self.cache_gameobj_list = {}
	self.is_stop_load = false 	-- 是否停止加载
	self.show_loading = show_loading

	self.bytes_total = 0
	self.bytes_loaded = 0
	self.bytes_vir_loaded = 0 	-- 虚拟加载，为了让加载本地的资源时，进度条更平滑

	Runner.Instance:AddRunObj(self, 8)
end

function ScenePreload:__delete()
	self.is_stop_load = true
	for _, v in ipairs(self.cache_gameobj_list) do
		ResPoolMgr:Release(v)
	end
	self.cache_gameobj_list = {}

	Runner.Instance:RemoveRunObj(self)
end

function ScenePreload:Update(now_time, elapse_time)
	if self.is_stop_load then
		return
	end

	if self.bytes_vir_loaded > 0 then
		local inc_bytes = math.min(self.bytes_vir_loaded, 4)
		self.bytes_vir_loaded = self.bytes_vir_loaded - inc_bytes
		self.bytes_loaded = self.bytes_loaded + inc_bytes
		self:CheckLoadComplete()
		return
	end

	if #self.load_list <= 0 then
		return
	end

	if self.loading_num > 0 then
		return
	end

	local num = math.min(self.load_num_once, #self.load_list)
	for i = 1, num do
		local t = table.remove(self.load_list, 1)

		if LOAD_TYPE.DOWNLOAD == t.load_type then
			self:DownloadBundle(t.bundle, t.bytes_total)

		elseif LOAD_TYPE.LOAD_MAIN_SCENE == t.load_type then
			self:LoadUnityMainScene(t.bundle_name, t.asset_name, t.bytes_total)
		
		elseif LOAD_TYPE.LOAD_UNFREE_GAMEOBJECT == t.load_type then
			self:LoadUnFreeGameObject(t.bundle_name, t.asset_name, t.bytes_total)
		
		elseif LOAD_TYPE.LOAD_CG == t.load_type then
			self:LoadCG(t.bundle_name, t.asset_name, t.bytes_total)
		
		elseif LOAD_TYPE.REDUCE_MEM == t.load_type then
			self:ReduceMem(t.bytes_total)
		
		elseif LOAD_TYPE.COMBINE_SCENE == t.load_type then
			self:CombineScene(t.bytes_total)
		end
	end
end

function ScenePreload:StartLoad(scene_id, load_list, download_scene_id, progress_fun, main_complete_fun, complete_fun)
	self.progress_fun = progress_fun
	self.main_complete_fun = main_complete_fun
	self.complete_fun = complete_fun
	self.update_retry_times = 0
	self.is_stop_load = false

	self.load_list = load_list or {}
	self.download_scene_id = download_scene_id
	self.loading_num = 0
	self.bytes_loaded = 0
	self.bytes_vir_loaded = 0
	self.bytes_total = self:GetBytesTotal()

	if self.download_scene_id > 0 then
		ReportManager:Step(Report.STEP_UPDATE_SCENE_BEGIN, self.download_scene_id)
	end

	CgManager.Instance:DelCacheCgs()
	self:CheckLoadComplete()
end

function ScenePreload:GetBytesTotal()
	local bytes_total = 0
	for _, v in ipairs(self.load_list) do
		bytes_total = bytes_total + v.bytes_total
	end

	return bytes_total
end

-- 预加载技能进对象池
function ScenePreload:LoadUnFreeGameObject(bundle_name, asset_name, bytes)
	self.loading_num = self.loading_num + 1
	self.bytes_vir_loaded = self.bytes_vir_loaded + bytes

	ResPoolMgr:GetEffectAsync(bundle_name, asset_name, function(obj)
		if nil ~= obj then
			table.insert(self.cache_gameobj_list, obj)
		end

		self.loading_num = self.loading_num - 1
		self:CheckLoadComplete()
	end)
end

-- 预加载CG到内存（在用完之前不释放）
function ScenePreload:LoadCG(bundle_name, asset_name, bytes)
	self.loading_num = self.loading_num + 1
	self.bytes_vir_loaded = self.bytes_vir_loaded + bytes

	CgManager.Instance:PreloadCacheCg(bundle_name, asset_name, function ()
		self.loading_num = self.loading_num - 1
		self:CheckLoadComplete()
	end)
end

-- 减少内存
function ScenePreload:ReduceMem(bytes)
	self.loading_num = self.loading_num + 1
	self.bytes_vir_loaded = self.bytes_vir_loaded + bytes
	AssetBundleMgr:UnloadUnusedAssets(function ()
		self.loading_num = self.loading_num - 1
		self:CheckLoadComplete()
	end)
end

function ScenePreload:CombineScene(bytes)
	self.loading_num = self.loading_num + 1
	self.bytes_vir_loaded = self.bytes_vir_loaded + bytes
	SceneOptimizeMgr.StaticBatch()
	self.loading_num = self.loading_num - 1
end

-- 下载bundle
function ScenePreload:DownloadBundle(bundle, bytes)
	self.loading_num = self.loading_num + 1
	local old_progress = self.bytes_loaded

	ResMgr:UpdateBundle(bundle,
		function(progress, download_speed, bytes_downloaded, content_length)
			
		end,

		function(error_msg)
			if self.is_stop_load then
				return
			end
			if error_msg ~= nil and error_msg ~= "" then
				self.loading_num = self.loading_num - 1
				print_log("下载: ", bundle, " 失败: ", error_msg, os.time())

				self.bytes_loaded = old_progress
				self:OnDownloadBundleFail(bundle, bytes)
			else
				if self.update_retry_times > 0 then
					self.update_retry_times = 0
					ResMgr:SetDownloadingURL(GLOBAL_CONFIG.param_list.update_url)
				end

				self.bytes_loaded = old_progress + bytes
				self.loading_num = self.loading_num - 1
				self:CheckLoadComplete()
			end
		end)
end

-- 下载bundle失败后再尝试
function ScenePreload:OnDownloadBundleFail(bundle, bytes)
	if self.update_retry_times < 8 then
		self.update_retry_times = self.update_retry_times + 1
		if GLOBAL_CONFIG.param_list.update_url2 ~= nil then -- 切换下载地址
			if self.update_retry_times % 2 == 1
				and nil ~= GLOBAL_CONFIG.param_list.update_url2
				and "" ~= GLOBAL_CONFIG.param_list.update_url2 then
				ResMgr:SetDownloadingURL(GLOBAL_CONFIG.param_list.update_url2)
			else
				ResMgr:SetDownloadingURL(GLOBAL_CONFIG.param_list.update_url)
			end
		end

		print_log("retry download ", bundle, ", retry times=", self.update_retry_times, ", url=", ResMgr.downloading_url)
		self:DownloadBundle(bundle, bytes)
	else
		self.is_stop_load = true
		TipsCtrl.Instance:OpenMessageBox(Language.MapLoading.LoadFail, function()
			GameRoot.Instance:Restart()
		end)
	end
end

-- 加载unity主场景
function ScenePreload:LoadUnityMainScene(bundle_name, asset_name, bytes)
	self.loading_num = self.loading_num + 1
	self.bytes_vir_loaded = self.bytes_vir_loaded + bytes
	self.main_has_compelet = false


	local function loadMainSceneComplete()
		self.loading_num = self.loading_num - 1
		self.main_has_compelet = true
		if self.show_loading then
			self:CheckLoadComplete()
		else
			if self.main_complete_fun ~= nil then
				self.main_complete_fun()
				self.main_complete_fun = nil
			end
		end
	end

	if ScenePreload.main_scene_bundle_name == bundle_name
		and ScenePreload.main_scene_asset_name == asset_name then
		loadMainSceneComplete()
		return
	end

	local load_mode = UnityEngine.SceneManagement.LoadSceneMode.Single
	ResMgr:LoadLevelSync("scenes/empytscene", "empytscene", load_mode,
		function()
			ResMgr:LoadLevelAsync(bundle_name, asset_name, load_mode,
				function ()
					ScenePreload.main_scene_bundle_name = bundle_name
					ScenePreload.main_scene_asset_name = asset_name
					loadMainSceneComplete()
				end)
		end)
end

function ScenePreload:CheckLoadComplete(tip)
	if nil ~= self.progress_fun and self.bytes_total > 0 then
		local precent = math.ceil(self.bytes_loaded / self.bytes_total * 100)

		self.progress_fun(math.min(precent, 100), tip or Language.Common.MapReading)
	end

	if (self.bytes_loaded >= self.bytes_total) and 0 == self.loading_num then
		self:OnLoadComplete()
	end
end

function ScenePreload:OnLoadComplete()
	if self.download_scene_id > 0 then
		ReportManager:Step(Report.STEP_UPDATE_SCENE_COMPLETE, self.download_scene_id)
	end

	for _, v in ipairs(self.cache_gameobj_list) do
		ResPoolMgr:Release(v)  -- 进入对象池，下次取出会很快
	end
	self.cache_gameobj_list = {}

	if self.show_loading and self.main_has_compelet and self.main_complete_fun ~= nil then
		self.main_complete_fun()
		self.main_complete_fun = nil
	end

	if nil ~= self.complete_fun then
		self.complete_fun()
		self.complete_fun = nil
	end
end

-- 获得场景预加载列表，
function ScenePreload.GetLoadList(scene_id)
	local list = {}
	local download_scene_id = 0

	-- 首先释放内存
	if GAME_ASSETBUNDLE then
		table.insert(list, {load_type = LOAD_TYPE.REDUCE_MEM, bytes_total = 20})
	end

	local scene_cfg = ConfigManager.Instance:GetSceneConfig(scene_id)
	if nil ~= scene_cfg then
		-- 加载网络上的场景
		local name_list = {scene_cfg.bundle_name}
		for _, v in ipairs(name_list) do
			local uncached_bundles = ResMgr:GetBundlesWithoutCached(v)
			if uncached_bundles ~= nil then
				for v in pairs(uncached_bundles) do
					table.insert(list, {load_type = LOAD_TYPE.DOWNLOAD, bundle = v, bytes_total = 30})
					download_scene_id = scene_id
				end
			end
		end

		-- 加载本地场景
		local scene_bytes_total = UNITY_EDITOR and 100 or 100
		table.insert(list, {load_type = LOAD_TYPE.LOAD_MAIN_SCENE, bundle_name = scene_cfg.bundle_name, asset_name = scene_cfg.asset_name, bytes_total = scene_bytes_total})
	end

	-- 如果不是低内存机才进行合批（重要）
	if not IsLowMemSystem then
		table.insert(list, {load_type = LOAD_TYPE.COMBINE_SCENE, bytes_total = 30})

		-- 首次进入指定要加载的prefab
		if GAME_ASSETBUNDLE then
			local scene_type = scene_cfg and scene_cfg.scene_type or 0
			ScenePreload.GetLoadCgList(list, scene_id, scene_type) 	-- 预加载CG
		end

	end

	return list, download_scene_id
end

-- 预加载技能列表(这些配置必须在包里有)
function ScenePreload.GetLoadSkillList(list)
	local sex = GameVoManager.Instance:GetMainRoleVo().sex
	local base_prof = PlayerData.Instance:GetRoleBaseProf()

	local cfg = ConfigManager.Instance:GetAutoPrefabConfig(sex, base_prof) or {}
	if cfg.actorController then
		if cfg.actorController.projectiles and nil ~= next(cfg.actorController.projectiles) then
			for key, value in pairs(cfg.actorController.projectiles) do
				if value.Projectile and nil ~= next(value.Projectile) then
					local bundle_name = value.Projectile.BundleName
					local asset_name = value.Projectile.AssetName

					table.insert(list, {load_type = LOAD_TYPE.LOAD_UNFREE_GAMEOBJECT, 
						bundle_name = bundle_name, asset_name = asset_name, bytes_total = 20})
				end
			end
		end
	end

	if cfg.actorTriggers then
		if cfg.actorTriggers.effects and nil ~= next(cfg.actorTriggers.effects) then
			for key, value in pairs(cfg.actorTriggers.effects) do
				if value.effectAsset and nil ~= next(value.effectAsset) then
					local bundle_name = value.effectAsset.BundleName
					local asset_name = value.effectAsset.AssetName

					table.insert(list, {load_type = LOAD_TYPE.LOAD_UNFREE_GAMEOBJECT, 
						bundle_name = bundle_name, asset_name = asset_name, bytes_total = 20})
				end
			end
		end
	end
end

-- 预加载CG列表
function ScenePreload.GetLoadCgList(list, scene_id, scene_type)
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local cfg_list = ConfigManager.Instance:GetAutoConfig("story_auto")["normal_scene_story"] or {}
	for k, v in pairs(cfg_list) do
		if scene_id == v.scene_id and v.operate_param and v.operate_param ~= "" and v.preload and v.preload == 1 then
			local tab = Split(v.operate_param, "##")
			if #tab == 2 then
				table.insert(list, {load_type = LOAD_TYPE.LOAD_CG, bundle_name = tab[1], asset_name = tab[2], bytes_total = 20})
			end
		end
	end

	-- 预加拜谒CG
	if scene_type == 22 then	-- 跨服六界
		local cg_bundle = "cg/w3_hd_liujie_zhuchangjing_prefab"
		local cg_asset = "W3_HD_Liujie_zhuchangjing_cg01"
		table.insert(list, {load_type = LOAD_TYPE.LOAD_CG, bundle_name = cg_bundle, asset_name = cg_asset, bytes_total = 20})
	end

	if scene_type == 41 then	-- 仙盟争霸
		local cg_bundle = "cg/w3_zc_xianmengzhengba_prefab"
		local cg_asset = "W3_ZC_XianMengZhengBa_cg01"
		table.insert(list, {load_type = LOAD_TYPE.LOAD_CG, bundle_name = cg_bundle, asset_name = cg_asset, bytes_total = 20})
	end

	if scene_type == 8 then		-- 攻城战
		local cg_bundle = "cg/w3_hd_liujie_fenchangjing_prefab"
		local cg_asset = "W3_HD_LiuJie_fenchangjing_cg01"
		table.insert(list, {load_type = LOAD_TYPE.LOAD_CG, bundle_name = cg_bundle, asset_name = cg_asset, bytes_total = 20})
	end

	-- 预加载跳跃CG
	-- local prof = PlayerData.Instance:GetRoleBaseProf()
	-- if scene_id == 101 then
	-- 	if prof == GameEnum.ROLE_PROF_1 then		-- 太渊
	-- 		local bundle_name = "cg/cg_tiaoyue/nanjian_prefab"
	-- 		for i = 1, 6 do
	-- 			table.insert(list, {load_type = LOAD_TYPE.LOAD_CG, bundle_name = bundle_name, asset_name = "nanjiantiaoyue"..i, bytes_total = 20})
	-- 		end
	-- 	end

	-- 	if prof == GameEnum.ROLE_PROF_2 then		-- 孤影
	-- 		local bundle_name = "cg/cg_tiaoyue/nvshuangjian_prefab"
	-- 		for i = 1, 6 do
	-- 			table.insert(list, {load_type = LOAD_TYPE.LOAD_CG, bundle_name = bundle_name, asset_name = "nvshuangjiantiaoyue"..i, bytes_total = 20})
	-- 		end
	-- 	end

	-- 	if prof == GameEnum.ROLE_PROF_3 then		-- 绝弦
	-- 		local bundle_name = "cg/cg_tiaoyue/nanqin_prefab"
	-- 		for i = 1, 6 do
	-- 			table.insert(list, {load_type = LOAD_TYPE.LOAD_CG, bundle_name = bundle_name, asset_name = "nanqintiaoyue"..i, bytes_total = 20})
	-- 		end
	-- 	end

	-- 	if prof == GameEnum.ROLE_PROF_4 then		-- 无极
	-- 		local bundle_name = "cg/cg_tiaoyue/nvpao_prefab"
	-- 		for i = 1, 6 do
	-- 			table.insert(list, {load_type = LOAD_TYPE.LOAD_CG, bundle_name = bundle_name, asset_name = "nvpaotiaoyue"..i, bytes_total = 20})
	-- 		end
	-- 	end
	-- end
end