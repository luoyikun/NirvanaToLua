FreeDownload = FreeDownload or BaseClass(BaseView)

function FreeDownload:__init()
	self.download_list = self:GetDownloadList()
	self.is_downloading = false

	self.max_stand_time = 60					-- 站在原地不动超过N秒
	self.stand_time = 0

	self.max_in_guaji_scene_time = 60			-- 在挂机地图超过N秒
	self.in_guaji_scene_time = 0

	self.max_lock_screen_time = 10				-- 锁屏N秒
	self.lock_screen_time = 0
end

function FreeDownload:__delete()
	Runner.Instance:RemoveRunObj(self)
end

function FreeDownload:Start()
	Runner.Instance:AddRunObj(self, 8)
end

function FreeDownload:Stop()
	Runner.Instance:RemoveRunObj(self)
end

function FreeDownload:Update(now_time, elapse_time)
	if self.is_downloading or #self.download_list <= 0 then
		return
	end

	if self:CheckCondition(now_time, elapse_time) then
		self:DownloadBundle(table.remove(self.download_list, 1))
	end
end

function FreeDownload:CheckCondition(now_time, elapse_time)
	local main_role = Scene.Instance:GetMainRole()
	if main_role and main_role:IsStand() then
		self.stand_time = self.stand_time + elapse_time
	else
		self.stand_time = 0
	end

	if Scene.Instance:GetSceneType() == SceneType.RuneTower then
		self.in_guaji_scene_time = self.in_guaji_scene_time + elapse_time
	else
		self.in_guaji_scene_time = 0
	end

	if ViewManager.Instance:IsOpen(ViewName.Unlock) then
		self.lock_screen_time = self.lock_screen_time + elapse_time
	else
		self.lock_screen_time = 0
	end

	return self.stand_time >= self.max_stand_time or
					self.in_guaji_scene_time >= self.max_in_guaji_scene_time or
					self.lock_screen_time >= self.max_lock_screen_time
end

function FreeDownload:DownloadBundle(bundle)
	self.is_downloading = true
	ResMgr:UpdateBundle(bundle,
		function(progress, download_speed, bytes_downloaded, content_length)

		end,

		function(error_msg)
			self.is_downloading = false
		end)
end

function FreeDownload:GetDownloadList()
	local list = {
		 -- "scenes/map/fcfb01_main",			--飞船地图
   --       "scenes/map/Wenquan01_Main",		--温泉
   --       "scenes/map/Sgfb01_Main",			--山谷副本
   --       "scenes/map/3dhddt01_Main",		--元素战场
   --       "scenes/map/Tfdt01_Main",			--爬塔
   --       "scenes/map/Gczdt01_Main",			--攻城战
   --       "scenes/map/Dczhddt01_Main",		--领土战
   --       "scenes/map/Jhfb01_Main",			--结婚婚宴
   --       "scenes/map/Pkhddt01_Main",		--修罗塔
   --       "scenes/map/Tfdt01_Main",			--爬塔
   --       "scenes/map/Sldt01_Main",			--森林
   --       "scenes/map/Smdt01_Main",			--沙漠
   --       "scenes/map/Xkcdt01_Main",			--悬空城
   --       "scenes/map/Fxgzcdt01_Main",		--废墟古战场
	}

	-- 处理成相关联的文件
	local download_list = {}
	local dic = {}
	for _, v in ipairs(list) do
		local uncached_bundles = ResMgr:GetBundlesWithoutCached(v)
		if uncached_bundles ~= nil then
			for v2 in pairs(uncached_bundles) do
				if not dic[v2] then
					dic[v2] = true
					table.insert(download_list, v2)
				end
			end
		end
	end

	return download_list
end
