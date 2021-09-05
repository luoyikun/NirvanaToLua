MainCollectgarbageText = MainCollectgarbageText or BaseClass(BaseView)

local m_accum = 0
local m_frames = 0
local m_time_left = 1

function MainCollectgarbageText:__init()
	self.ui_config = {{"uis/views/mainui_prefab", "CollectgarbageText"}}
	self.view_layer = UiLayer.Standby
	self.is_show = true
	self.cg_instance_list = {}
	self.play_prof_cg = 1
	Runner.Instance:AddRunObj(self, 16)
end

function MainCollectgarbageText:__delete()

end

function MainCollectgarbageText:CloseCallBack()
	Runner.Instance:RemoveRunObj(self)
end

function MainCollectgarbageText:ReleaseCallBack()
	self.fps_text = nil
	self.lua_text = nil
	self.is_show_view = nil
	self.move_text = nil
	self.att_text = nil
	self.bundle_text = nil
	self.asset_text = nil

	self.play_prof_cg = 1
	self.cg_camera = nil
	self.cg_chuchang = nil
	-- 清空CG实例
	for k, v in pairs(self.cg_instance_list) do
		ResMgr:Destroy(v)
	end
	self.cg_instance_list = {}
	Runner.Instance:RemoveRunObj(self)
end

function MainCollectgarbageText:LoadCallBack()
	self.bundle_text = self.node_list["CGBundle"]
	self.asset_text = self.node_list["CGAsset"]

	self.fps_text = self.node_list["FpsText"]
	self.lua_text = self.node_list["LuaText"]
	self.is_show_view = self.node_list["View"]
	self.move_text = self.node_list["MoveText"]
	self.att_text = self.node_list["AttText"]


	self.bundle_text.input_field.onValueChanged:AddListener(BindTool.Bind(self.CGBundleChange, self))
	self.asset_text.input_field.onValueChanged:AddListener(BindTool.Bind(self.CGAssetChange, self))

	self.node_list["PlayCG"].button:AddClickListener(BindTool.Bind(self.OnPlayCG, self))
	self.node_list["RemoveCG"].button:AddClickListener(BindTool.Bind(self.RemoveCG, self))

	self.node_list["AddRole"].button:AddClickListener(BindTool.Bind(self.AddRole, self))
	self.move_text.input_field.onValueChanged:AddListener(BindTool.Bind(self.MoveValueChange, self))
	
	self.node_list["AttackerRole"].button:AddClickListener(BindTool.Bind(self.AttackerRole, self))
	self.att_text.input_field.onValueChanged:AddListener(BindTool.Bind(self.AttValueChange, self))

	self.node_list["RemoveRole"].button:AddClickListener(BindTool.Bind(self.RemoveRole, self))
	self.node_list["CloseBtn"].button:AddClickListener(BindTool.Bind(self.CloseBtn, self))

	self.node_list["PlayLoadFrofCg"].button:AddClickListener(BindTool.Bind(self.PlayLoadFrofCg, self))

	for i = 1, 4 do
		self.node_list["ProfCg" .. i].button:AddClickListener(BindTool.Bind(self.ProfCg, self, i))
	end
end

function MainCollectgarbageText:Update()
	self:FpsUpdate()
end

function MainCollectgarbageText:MoveValueChange()
	local num = tonumber(self.move_text.input_field.text)
	if num == nil then
		SysMsgCtrl.Instance:ErrorRemind("请输入数字")
	end
end

function MainCollectgarbageText:AttValueChange()
	local num = tonumber(self.att_text.input_field.text)
	if num == nil then
		SysMsgCtrl.Instance:ErrorRemind("请输入数字")
	end
end

function MainCollectgarbageText:CGBundleChange()
	local num = self.bundle_text.input_field.text
	if num == nil then
		SysMsgCtrl.Instance:ErrorRemind("请输入bundle")
	end
end

function MainCollectgarbageText:CGAssetChange()
	local num = self.asset_text.input_field.text
	if num == nil then
		SysMsgCtrl.Instance:ErrorRemind("请输入asset")
	end
end

function MainCollectgarbageText:FpsUpdate()
	m_time_left = m_time_left - UnityEngine.Time.deltaTime 
	m_accum = m_accum + (UnityEngine.Time.timeScale / UnityEngine.Time.deltaTime) 
	m_frames = m_frames + 1
	if (m_time_left <= 0) then        
		if self.fps_text then
			local fps = m_accum / m_frames 
			self.fps_text.text.text = string.format("FPS:%.2f", fps)
		end 

		local lua_count = collectgarbage("count")
		if self.lua_text then
			self.lua_text.text.text = string.format("Lua:%.2f", lua_count / 1000)
		end

		m_time_left = 1
		m_accum = 0 
		m_frames = 0  
	end 
end

function MainCollectgarbageText:AddRole()
	local num = tonumber(self.move_text.input_field.text) or 10
	for k = 1, num do
		self:CreateTestRole()
	end
end

function MainCollectgarbageText:RemoveRole()
	Scene.Instance:DeleteObjsByType(SceneObjType.TestRole)
	obj_id_inc = 200000
	att_obj_id_inc = 210000
end

local obj_id_inc = 200000

function MainCollectgarbageText:CreateTestRole()
	obj_id_inc = obj_id_inc + 1
	local vo = TableCopy(GameVoManager.Instance:GetMainRoleVo())
	
	vo.role_id = obj_id_inc + 1
	vo.obj_id = obj_id_inc + 1
	vo.prof = math.floor(math.random(1, 4))
	vo.sex = ROLE_PROF_SEX[vo.prof]
	vo.wuqi_id = 1
	vo.appearance.wuqi_id = math.floor(math.random(1, 10))
	vo.mount_appeid = math.floor(math.random(1000, 1020))
	vo.appearance.wing_used_imageid = math.floor(math.random(1, 10))
	vo.appearance.fazhen_image_id = math.floor(math.random(1, 10))
	vo.move_speed = vo.move_speed + math.floor(math.random(-50, 50))

	local test_role = Scene.Instance:CreateTestRole(vo, SceneObjType.TestRole)
	test_role:SetTestMove()
end

local att_obj_id_inc = 210000

function MainCollectgarbageText:AttackerRole()
	local num = tonumber(self.att_text.input_field.text) or 1

	for k = 1, 2 * num do
		self:CreateAttTestRole()
	end
	self:StartAttcker()
end

function MainCollectgarbageText:CreateAttTestRole()
	att_obj_id_inc = att_obj_id_inc + 1
	local vo = TableCopy(GameVoManager.Instance:GetMainRoleVo())

	vo.role_id = att_obj_id_inc
	vo.obj_id = att_obj_id_inc
	
	local main_role = Scene.Instance:GetMainRole()
	if main_role then
		local role_pos_x, role_pos_y = main_role:GetLogicPos()
		vo.pos_x = math.floor(math.random(-10, 10)) + role_pos_x
		vo.pos_y = math.floor(math.random(-10, 10)) + role_pos_y
	end

	vo.prof = math.floor(math.random(1, 4))
	vo.sex = ROLE_PROF_SEX[vo.prof]
	vo.wuqi_id = 1
	vo.appearance.wuqi_id = math.floor(math.random(1, 10))
	vo.mount_appeid = 0
	vo.appearance.wing_used_imageid = math.floor(math.random(1, 10))
	vo.appearance.fazhen_image_id = math.floor(math.random(1, 10))
	vo.move_speed = vo.move_speed + math.floor(math.random(-50, 50))

	local test_role = Scene.Instance:CreateTestRole(vo, SceneObjType.TestRole)
	test_role:SetAttckerRole()
end

function MainCollectgarbageText:StartAttcker()
	local is_has_attr = 0
	for i = 210000, att_obj_id_inc do
		local one_target = Scene.Instance:GetObjByTypeAndKey(SceneObjType.TestRole, i)
		if one_target ~= nil then
			local two_target = nil
			if is_has_attr == 0 then
				two_target = Scene.Instance:GetObjByTypeAndKey(SceneObjType.TestRole, i + 1)
				if two_target ~= nil then
					one_target:SetAtkTarget(two_target)
					is_has_attr = 1
				end
			else
				two_target = Scene.Instance:GetObjByTypeAndKey(SceneObjType.TestRole, i - 1)
				if two_target ~= nil then
					one_target:SetAtkTarget(two_target)
					is_has_attr = 0
				end
			end
		end
	end
end

function MainCollectgarbageText:OnPlayCG()
	local cg_bundle = self.bundle_text.input_field.text ~= "" and self.bundle_text.input_field.text or "cg/ts_nanjian_prefab"
	local cg_asset  = self.asset_text.input_field.text ~= "" and self.asset_text.input_field.text or "CG_nanjian"
	
	if not CgManager.Instance:IsCgIng() then
		CgManager.Instance:Play(BaseCg.New(cg_bundle, cg_asset), function() end)
	end
end

function MainCollectgarbageText:RemoveCG()
	if nil ~= CgManager.Instance then
		CgManager.Instance:Stop()
	end
end

function MainCollectgarbageText:CloseBtn()
	self.is_show = not self.is_show
	self.is_show_view:SetActive(self.is_show)
end


local CG_BUNDLE = {
	[1] = {bundle = "cg/ts_nanjian_prefab", asset = "CG_nanjian"},
	[2] = {bundle = "cg/ts_nanqin_prefab", asset = "CG_nanqin"},
	[3] = {bundle = "cg/ts_nvshuangjian_prefab", asset = "CG_nvshuangjian"},
	[4] = {bundle = "cg/ts_nvpao_prefab", asset = "CG_nvpao"},
}

local SCENE_BUNDLE = {
	[1] = {bundle = "scenes/map/w3_ts_nanjian_main", asset = "W3_TS_NanJian_Main"},
	[2] = {bundle = "scenes/map/w3_ts_nanqin_main", asset = "W3_TS_NanQin_Main"},
	[3] = {bundle = "scenes/map/w3_ts_nvshuangjian_main", asset = "W3_TS_NvShuangJian_Main"},
	[4] = {bundle = "scenes/map/w3_ts_nvpao_main", asset = "W3_TS_NvPao_Main"},
}

function MainCollectgarbageText:PlayLoadFrofCg()
	local prof = self.play_prof_cg

	if self.cg_camera then
		EasyTouch.RemoveCamera(self.cg_camera)
		self.cg_camera = nil
	end

	local scene = UnityEngine.SceneManagement.SceneManager.GetSceneByName(SCENE_BUNDLE[prof].asset)
	if scene then
		local cg_key = CG_BUNDLE[prof].bundle .. CG_BUNDLE[prof].asset
		local objs = scene:GetRootGameObjects()
		if self.cg_instance_list[cg_key] then
			local center = nil
			for i = 0, objs.Length - 1 do
				if objs[i].gameObject.name == "Main" then
					center = objs[i].gameObject.transform:Find("HeroPos")

					local scene_camera = objs[i].gameObject.transform:Find("Camera")
					if nil ~= scene_camera then
						scene_camera.gameObject:SetActive(false)
					end

					break
				end
			end


			if center then
				self.cg_instance_list[cg_key].gameObject:SetActive(true)
				self.cg_instance_list[cg_key].transform:SetParent(center.transform)
				self.cg_instance_list[cg_key].transform.localPosition = Vector3.zero

				local chuchang = self.cg_instance_list[cg_key].transform:Find("stage_chuchang")
				self.cg_chuchang = chuchang:GetComponent(typeof(UnityEngine.Playables.PlayableDirector))
				self.cg_chuchang:Play()

				self.cg_camera = self.cg_instance_list[cg_key]:GetComponentInChildren(typeof(UnityEngine.Camera))
				if self.cg_camera then
					EasyTouch.AddCamera(self.cg_camera)
				end
			end
		end
	end
end

function MainCollectgarbageText:ProfCg(prof)
	self.play_prof_cg = prof
	local scene = UnityEngine.SceneManagement.SceneManager.GetSceneByName(SCENE_BUNDLE[prof].asset)
	if scene then
		local cg_key = CG_BUNDLE[prof].bundle .. CG_BUNDLE[prof].asset
		local objs = scene:GetRootGameObjects()
		if not self.cg_instance_list[cg_key] then
			self:LoadProfCG(CG_BUNDLE[prof].bundle, CG_BUNDLE[prof].asset, objs, function () end)
		end
	end

	-- local cg_cfg = {
	-- 	{"cg/ts_nanjian_prefab", "CG_nanjian"},
	-- 	{"cg/ts_nanqin_prefab", "CG_nanqin"},
	-- 	{"cg/ts_nvshuangjian_prefab", "CG_nvshuangjian"},
	-- 	{"cg/ts_nvpao_prefab", "CG_nvpao"},
	-- }
	-- print_error("?????", prof, CgManager.Instance:IsCgIng())
	-- if not CgManager.Instance:IsCgIng() then
	-- 	CgManager.Instance:Play(BaseCg.New(cg_cfg[prof][1], cg_cfg[prof][2]), function() end)
	-- end
end

function MainCollectgarbageText:LoadProfCG(bundle, asset, objs, callback)
	if nil == bundle or nil == asset then
		callback()
		return
	end

	local cg_key = bundle .. asset
	if not self.cg_instance_list[cg_key] then
		print_log("[loading] start load create cg", bundle, asset, os.date())

		ResMgr:LoadGameobjSync(bundle, asset, function(cg_obj)
			print_log("[loading] finish load create cg", bundle, asset, os.date())
			if cg_obj then
				cg_obj.gameObject:SetActive(false)
				local center = nil
				for i = 0, objs.Length - 1 do
					if objs[i].gameObject.name == "Main" then
						center = objs[i].gameObject.transform:Find("HeroPos")
						break
					end
				end

				if center then
					self.cg_instance_list[cg_key] = cg_obj
					cg_obj.transform:SetParent(center.transform)
				end
			end
			callback()
		end, true)
	else
		callback()
	end
end