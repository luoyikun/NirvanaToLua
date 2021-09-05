local ResUtil = require "resmanager/res_util"
local UnitySceneManager = UnityEngine.SceneManagement.SceneManager
local UnityLoadSceneMode = UnityEngine.SceneManagement.LoadSceneMode
local SceneSingleLoadMode = UnityLoadSceneMode.Single
local SceneAdditiveLoadMode = UnityLoadSceneMode.Additive

local M = ResUtil.create_class()

function M:_init()
	self.v_is_loading = false
	self.v_bundle_name = nil
	self.v_asset_name = nil
end

function M:Update()
	if not self.v_is_loading then
		if self.not_need_load then
			if self.v_callback then
				local callback = self.v_callback
				self.v_callback = nil

				callback()
			end

			self.not_need_load = nil
		end
		
		return
	end

	if self.v_loadsceneop and self.v_loadsceneop.isDone then
		self.v_loadsceneop = nil
		self:OnLoadLevelComplete()
	end
end

function M:OnLoadLevelComplete()
	self.v_is_loading = false
	if self.v_callback then
		local callback = self.v_callback
		self.v_callback = nil

		callback()
	end

	if not self.v_bundle_name then
		return
	elseif self.v_need_reload then
		self.v_need_reload = false

		if v_sync then
			self:LoadLevelSync(self.v_bundle_name, self.v_asset_name, self.v_load_mode, self.v_next_callback, true)
		else
			self:LoadLevelAsync(self.v_bundle_name, self.v_asset_name, self.v_load_mode, self.v_next_callback, true)
		end
	end
end

function M:LoadLevelAsync(bundle_name, asset_name, load_mode, callback, force)
	if not force and not self:_CheckNeedLoad(bundle_name, asset_name) then
		self.not_need_load = true
		self.v_callback = callback
		return
	end

	self.v_bundle_name = bundle_name
	self.v_asset_name = asset_name
	self.v_load_mode = load_mode
	self.v_next_callback = nil
	self.v_need_reload = false
	self.v_sync = false

	if self.v_is_loading then
		self.v_next_callback = callback
		self.v_need_reload = true
		return
	end

	self.v_callback = callback
	self.v_is_loading = true
	self.v_loadsceneop = nil

	ResMgr:LoadUnitySceneAsync(bundle_name, asset_name, load_mode, function(loadscene_op)
		if not self:IsSameScene(bundle_name, asset_name) then
			ResMgr:UnloadScene(bundle_name)
			return
		end

		self.v_loadsceneop = loadscene_op

	end)
end

function M:LoadLevelSync(bundle_name, asset_name, load_mode, callback, force)
	if not force and not self:_CheckNeedLoad(bundle_name, asset_name) then
		self.not_need_load = true
		self.v_callback = callback
		return
	end

	self.v_bundle_name = bundle_name
	self.v_asset_name = asset_name
	self.v_load_mode = load_mode
	self.v_next_callback = nil
	self.v_need_reload = false
	self.v_sync = true

	if self.v_is_loading then
		self.v_next_callback = callback
		self.v_need_reload = true
		return
	end

	self.v_callback = callback
	self.v_is_loading = true
	self.v_loadsceneop = nil

	ResMgr:LoadUnitySceneSync(bundle_name, asset_name, load_mode, function(loadscene_op)
		if not self:IsSameScene(bundle_name, asset_name) then
			ResMgr:UnloadScene(bundle_name)
			return
		end
		self:OnLoadLevelComplete()
	end)
end

function M:Destroy()
	if self.v_bundle_name then
		ResMgr:UnloadScene(self.v_bundle_name)
		self.v_bundle_name = nil
	end

	self.v_bundle_name = nil
	self.v_asset_name = nil
	self.v_need_reload = nil
end

function M:IsSameScene(bundle_name, asset_name)
	return self.v_bundle_name == bundle_name and self.v_asset_name == asset_name
end

function M:_CheckNeedLoad(bundle_name, asset_name)
	if self.v_bundle_name == bundle_name and self.v_asset_name == asset_name then
		return false
	end

	return true
end

return M