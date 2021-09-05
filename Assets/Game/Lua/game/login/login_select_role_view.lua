-- require("game/login/login_select_role_view")

function LoginView:InitSelectRoleView()
	-- 旋转区域
	local event_trigger = self.node_list["SelectRoleEventTrigger"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))

	self.node_list["BtnOpenAdventure"].button:AddClickListener(BindTool.Bind(self.OnClickOpenAdventure, self))

	----------------------------------------------------
	-- 选择角色列表生成滚动条
	self.select_role_cell_list = {}
	self.select_role_listview_data = {}
	local selectrole_list_delegate = self.node_list["RoleList"].list_simple_delegate
	--生成数量
	selectrole_list_delegate.NumberOfCellsDel = function()
		return #self.select_role_listview_data or 0
	end
	--刷新函数
	selectrole_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshSelectRoleListView, self)
	----------------------------------------------------
	self.select_role_prof = 0
	self.select_role_id = 0

	self.is_enter_select_role = false -- 是否进入选择角色面板

end

function LoginView:DeleteSelectRoleView()
	-- 额,貌似不能清数据,清了会突然不见数据了,给释放了.
	if self.select_role_cell_list then
		for k,v in pairs(self.select_role_cell_list) do
			v:DeleteMe()
		end
		self.select_role_cell_list = {}
	end
end

-- 角色被拖转动事件
function LoginView:OnRoleDrag(data)
	if self.draw_obj then
		self.draw_obj:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function LoginView:RefreshSelectRoleListView(cell, data_index, cell_index)
	data_index = data_index + 1

	local role_cell = self.select_role_cell_list[cell]
	if role_cell == nil then
		role_cell = SelectRoleItem.New(cell.gameObject)
		role_cell:SetClickCallBack(BindTool.Bind1(self.OnClickContractHandler, self))
		if data_index == 1 then
			role_cell.root_node.toggle.isOn = true
		end
		self.select_role_cell_list[cell] = role_cell
	end

	local role_list_ack_info = LoginData.Instance:GetRoleListAck()
	if role_list_ack_info.count < 3 then
		if #self.select_role_listview_data > data_index then
			role_cell.root_node.toggle.group = self.node_list["RoleList"].toggle_group
		else
			role_cell.root_node.toggle.group = nil
		end
	else
		role_cell.root_node.toggle.group = self.node_list["RoleList"].toggle_group
		role_cell.root_node.toggle.enabled = true
	end

	role_cell:SetIndex(data_index)
	role_cell:SetData(self.select_role_listview_data[data_index])

	if not self.is_enter_select_role and data_index == 1 then
		self.is_enter_select_role = true
		self.select_role_id = 0
		self:OnClickContractHandler(role_cell)
		role_cell.root_node.toggle.isOn = true
		cell.gameObject:SetActive(true)
	else
		role_cell.root_node.toggle.isOn = false
	end
end

-- 列表选择回调函数处理
function LoginView:OnClickContractHandler(cell)
	if not cell or not cell.data then return end

	local data = cell.data
	if data.role_id > 0 then
		self:SelectRoleProf(data)

		self.select_role_id = data.role_id

		local user_vo = GameVoManager.Instance:GetUserVo()
		user_vo:SetNowRole(data.role_id)
		local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
		mainrole_vo.name = data.role_name
	else
		-- 合服后不允许创建角色
		local combine_data = LoginData.Instance:GetCombineData()
		if nil ~= combine_data.count then
			TipsCtrl.Instance:ShowSystemMsg(Language.Login.CombineNoCreateRole)
			return
		end
		self.select_prof = 0
		self:OnChangeToCreate()
	end

end

-- 刷新选择角色面板
function LoginView:FlushSelectRoleView()
	local role_list_ack_info = LoginData.Instance:GetRoleListAck()
	local temp_role_list = TableCopy(role_list_ack_info.role_list)
	table.sort(temp_role_list, SortTools.KeyUpperSorter("last_login_time"))
	if role_list_ack_info.count < 3 then
		local plus_sign = {
			role_id = -9999,
			role_name = Language.Login.CreateRole,
			avatar = 0,
			sex = 0,
			prof = 0,
			country = 0,
			level = 0,
			create_time = 0,
			last_login_time = 0,
			wuqi_id = 0,
			shizhuang_wuqi = 0,
			shizhuang_body = 0,
			wing_used_imageid = 0,
			halo_used_imageid = 0,
		}
		table.insert(temp_role_list, plus_sign)
	end
	self.select_role_listview_data = temp_role_list
	if self.node_list["RoleList"].scroller.isActiveAndEnabled then
		-- GlobalTimerQuest:AddDelayTimer(function()
			self.node_list["RoleList"].scroller:ReloadData(0)
		-- end, 0)
	end
	local select_role_state = UtilU3d.GetCacheData("select_role_state")
	if select_role_state == 1 then
		UtilU3d.CacheData("select_role_state", 0)
		InitCtrl:HideLoading()
	end
end

-- 切换选择角色面板
function LoginView:OnChangeToSelectRole()
	if self:IsOpen() then
		self.is_open_create = false
		self.is_enter_select_role = false
		self.node_list["SelectRole"]:SetActive(true)
		self.node_list["PictureBackGround"]:SetActive(false)
		self:Flush("flush_select_role_view")
	end
end

-- 开启冒险
function LoginView:OnClickOpenAdventure()
	-- 提前打开加载页（为了进游戏时的体验）
	Scene.Instance:OpenSceneLoading()
	if self.select_role_id > 0 then
		LoginData.Instance:SetCurrSelectRoleId(self.select_role_id)
		LoginCtrl.SendRoleReq()
	else
		self:OnChangeToCreate()
	end
end

function LoginView:SelectRoleProf(data)
	local base_prof = PlayerData.Instance:GetRoleBaseProf(data.prof)
	local prof = base_prof
	local sex = data.sex

	local role_id = data.role_id

	local role_res_id = 0
	local weapon_res_id = 0
	local weapon2_res_id = 0

	local wing_res_id = 0
	local halo_res_id = 0

	if self.select_role_id == role_id then
		return
	end

	-- 卸载登录界面
	local SceneManager = UnityEngine.SceneManagement.SceneManager
	local scene = SceneManager.GetSceneByName("W3_TS_DengLu_Main")
	if scene:IsValid() then
		local roots = scene:GetRootGameObjects()
		for i = 0, roots.Length - 1 do
			local obj = roots[i]
			obj:SetActive(false)
		end
		SceneManager.UnloadSceneAsync(scene)
	end
	--TipsCtrl.Instance:ShowLoadingTips()

	self.select_role_id = role_id

	if self.draw_obj ~= nil then
		self.draw_obj:DeleteMe()
		self.draw_obj = nil
	end

	local bundle, asset
	if prof == 1 then
		bundle = "scenes/map/w3_ts_nanjian_main"
		asset = "W3_TS_NanJian_Main"
	elseif prof == 2 then
		bundle = "scenes/map/w3_ts_nanqin_main"
		asset = "W3_TS_NanQin_Main"
	elseif prof == 3 then
		bundle = "scenes/map/w3_ts_nvshuangjian_main"
		asset = "W3_TS_NvShuangJian_Main"
	elseif prof == 4 then
		bundle = "scenes/map/w3_ts_nvpao_main"
		asset = "W3_TS_NvPao_Main"
	end

	if self.cg_handler ~= nil then
		GlobalTimerQuest:CancelQuest(self.cg_handler)
		self.cg_handler = nil
	end

	self:ChangeScene(bundle, asset, function()
		self.node_list["SelectServer"]:SetActive(false)
		self.node_list["CreateRole"]:SetActive(false)
		self.node_list["LoginRoot"]:SetActive(false)

		-- self.node_list["SelectRole"]:SetActive(true)
		local center = nil
		local key = bundle..asset
		for k,v in pairs(self.scene_cache) do
			local objs = v.roots
			if k ~= key then
				for i = 0, objs.Length-1 do
					local obj = objs[i]
					obj:SetActive(false)
				end
			else
				for i = 0, objs.Length-1 do
					local obj = objs[i]
					obj:SetActive(true)

					if objs[i].gameObject.name == "Main" then
						center = objs[i].gameObject.transform:Find("HeroPos")
						local scene_camera = objs[i].gameObject.transform:Find("Camera")
						if nil ~= scene_camera then
							scene_camera.gameObject:SetActive(true)
						end
					end
				end
			end
		end

		self.draw_obj = DrawObj.New(self, center.transform)
		self.draw_obj.root.transform.localPosition = Vector3.zero
		self.draw_obj.root.transform.localRotation = Quaternion.identity

		local shizhuang_wuqi_is_special_flag = data.shizhuang_wuqi_is_special > 0 and true or false
		local shizhuang_body_is_special_flag = data.shizhuang_body_is_special > 0 and true or false

		-- 先查找时装的武器和衣服
		if data.shizhuang_wuqi ~= 0 and data.shizhuang_wuqi ~= nil then
			local wuqi_cfg = LoginData.Instance:GetWeaponFashionConfig(shizhuang_wuqi_is_special_flag, data.shizhuang_wuqi)
			if wuqi_cfg then
				local cfg = wuqi_cfg["resouce" .. prof .. sex]
				if type(cfg) == "string" then
					local temp_table = Split(cfg, ",")
					if temp_table then
						weapon_res_id = tonumber(temp_table[1]) or 0
						weapon2_res_id = tonumber(temp_table[2]) or 0
					end
				elseif type(cfg) == "number" then
					weapon_res_id = cfg
				end
			end
		end

		if data.shizhuang_body ~= 0 and data.shizhuang_body ~= nil then
			local clothing_cfg = LoginData.Instance:GetClothFashionConfig(shizhuang_body_is_special_flag, data.shizhuang_body)
			if clothing_cfg then
				local index = string.format("resouce%s%s", prof, sex)
				local res_id = clothing_cfg[index]
				role_res_id = res_id
			end
		end

		wing_res_id = self:UpdateWingResId(data.wing_used_imageid)
		halo_res_id = self:UpdateHaloResId(data.halo_used_imageid)

		-- 最后查找职业表
		local job_cfgs = ConfigManager.Instance:GetAutoConfig("rolezhuansheng_auto").job
		local role_job = job_cfgs[prof]
		if role_job ~= nil then
			if role_res_id == 0 then
				role_res_id = role_job["model" .. sex]
			end
			if weapon_res_id == 0 then
				weapon_res_id = role_job["right_weapon" .. sex]
			end
			if weapon2_res_id == 0 then
				weapon2_res_id = role_job["left_weapon" .. sex]
			end
		else
			if role_res_id == 0 then
				role_res_id = 1001001
			end
			if weapon_res_id == 0 then
				weapon_res_id = 900100101
			end
		end

		-- 主角
		local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
		main_part:ChangeModel(ResPath.GetRoleModel(role_res_id))

		-- 武器1
		local wepapon_part = self.draw_obj:GetPart(SceneObjPart.Weapon)
		wepapon_part:ChangeModel(ResPath.GetWeaponModel(weapon_res_id))

		-- 武器2
		if weapon2_res_id > 0 then
			local wepapon_part2 = self.draw_obj:GetPart(SceneObjPart.Weapon2)
			wepapon_part2:ChangeModel(ResPath.GetWeaponModel(weapon2_res_id))
		end

		-- 羽翼
		if wing_res_id > 0 then
			local wing_part = self.draw_obj:GetPart(SceneObjPart.Wing)
			wing_part:ChangeModel(ResPath.GetWingModel(wing_res_id))
		end

		-- 光环
		if halo_res_id > 0 then
			local halo_part = self.draw_obj:GetPart(SceneObjPart.Halo)
			halo_part:ChangeModel(ResPath.GetHaloModel(halo_res_id))
		end
		TipsCtrl.Instance:CloseLoadingTips()
	end)
end

function LoginView:UpdateWingResId(index)
	local wing_config = ConfigManager.Instance:GetAutoConfig("wing_auto")
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local image_cfg = nil
	local wing_res_id = 0
	if wing_config then
		if index >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			image_cfg = wing_config.special_img[index - GameEnum.MOUNT_SPECIAL_IMA_ID]
		else
			image_cfg = wing_config.image_list[index]
		end
		if image_cfg then
			wing_res_id = image_cfg.res_id
		end
	end
	return wing_res_id
end

function LoginView:UpdateHaloResId(index)
	local halo_config = ConfigManager.Instance:GetAutoConfig("halo_auto")
	local image_cfg = nil
	local halo_res_id = 0
	if halo_config then
		if index >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			image_cfg = halo_config.special_img[index - GameEnum.MOUNT_SPECIAL_IMA_ID]
		else
			image_cfg = halo_config.image_list[index]
		end
		if image_cfg then
			halo_res_id = image_cfg.res_id
		end
	end
	return halo_res_id
end


---------------------------------
-- 选择多人角色Item
---------------------------------
SelectRoleItem = SelectRoleItem or BaseClass(BaseCell)

function SelectRoleItem:__init()
	self.node_list["RoleItem"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function SelectRoleItem:OnFlush()
	self:JudgeState(true)
	if nil == self.data then return end
	self.node_list["ImgRoleItem"]:SetActive(true)

	local level_str = PlayerData.GetLevelString(self.data.level)
	if self.data.role_id <= 0 then
		self.node_list["ImgRoleItem"]:SetActive(false)
		level_str = ""
	else
		self:JudgeState(false)
		local base_prof = PlayerData.Instance:GetRoleBaseProf(self.data.prof)
		local bundle, asset = ResPath.GetRoleHeadSmall(base_prof, self.data.sex)
		self.node_list["ImgIcon"].image:LoadSprite(bundle, asset)
		self.node_list["ImgIconBig"].image:LoadSprite(bundle, asset)
	end
	self.node_list["TxtName"].text.text = self.data.role_name
	self.node_list["TxtLevel"].text.text = level_str
end

function SelectRoleItem:JudgeState(flag)
	self.node_list["ImgPlus"]:SetActive(flag)
	self.node_list["ImgMask"]:SetActive(not flag)
	self.node_list["ImgMaskBig"]:SetActive(not flag)
end