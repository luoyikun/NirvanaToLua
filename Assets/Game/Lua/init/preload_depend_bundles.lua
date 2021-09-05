PreloadDependBundles = PreloadDependBundles or {
	depend_list = {},
}

local DefaultBundles = {
	"shaders",
	"scenes/map/w3_ts_denglu_main",
}

local SceneBundles = {
	"scenes/map/w3_ts_nanjian_main",
	"scenes/map/w3_ts_nanqin_main",
	"scenes/map/w3_ts_nvshuangjian_main",
	"scenes/map/w3_ts_nvpao_main",
}

local CGBundles = {
	"cg/ts_nanjian_prefab",
	"cg/ts_nanqin_prefab",
	"cg/ts_nvshuangjian_prefab",
	"cg/ts_nvpao_prefab",
}

function PreloadDependBundles:Start(call_back)
	self.call_back = call_back
	self.depend_list = self:GetDependList()
	self.cur_index = 0
	PushCtrl(self)
end

function PreloadDependBundles:GetDependList()
	local temp_depends = {}
	local depends = {}
	local temp_bundles = {}
	for k,v in pairs(DefaultBundles) do
		table.insert(temp_bundles, v)
	end

	-- 老玩家只预加载最后上线角色的场景
	local last_login_prof = PlayerPrefsUtil.GetString("last_login_prof")
	if nil ~= last_login_prof and "" ~= last_login_prof then
		table.insert(temp_bundles, SceneBundles[last_login_prof])
	else
		for k,v in pairs(SceneBundles) do
			table.insert(temp_bundles, v)
		end
		for k,v in pairs(CGBundles) do
			table.insert(temp_bundles, v)
		end
	end

	for k, v in pairs(temp_bundles) do
		local deps = ResMgr:GetBundleDeps(v)
		if deps then
			for _, v2 in pairs(deps) do
				temp_depends[v2] = temp_depends[v2] and temp_depends[v2] + 1 or 1
			end
		end
	end

	for k,v in pairs(temp_depends) do
		table.insert(depends, k)
	end

	return depends
end

function PreloadDependBundles:Update()
	if IS_AUDIT_VERSION then
		if self.call_back then
			self.call_back(1)
		end
		PopCtrl(self)
		return
	end
	local total_count = #self.depend_list
	if total_count <= 0 then
		print("finish load login scene and cg", os.date())
		if self.call_back then
			self.call_back(1)
		end
		PopCtrl(self)
		return
	end
	for i = 1, 40 do
		if self.cur_index < total_count then
			self.cur_index = self.cur_index + 1
			local ab = self.depend_list[self.cur_index]
			-- AssetBundleMgr:LoadBundleLocal(ab)
		end
		if self.call_back then
			self.call_back(self.cur_index / total_count)
		end
		if self.cur_index >= total_count then
			PopCtrl(self)
			break
		end
	end
end

function PreloadDependBundles:Stop()

end

function PreloadDependBundles:Destory()
	for k, v in ipairs(self.depend_list) do
		-- AssetBundleMgr:UnloadBundle(v)
	end
	self.depend_list = {}
end

return PreloadDependBundles