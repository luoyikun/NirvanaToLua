LoginView = LoginView or BaseClass(BaseView)
LoginView.ProfIcon = {
	[1] = {"icon_102", "icon_099"},
	[2] = {"icon_101", "icon_098"},
	[3] = {"icon_100", "icon_097"},
}
local GROUP_SERVER_COUNT = 8

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

local UnitySceneManagement = UnityEngine.SceneManagement
local UnitySceneManager = UnitySceneManagement.SceneManager

local UnityLoadSceneMode = UnitySceneManagement.LoadSceneMode
local SceneSingleLoadMode = UnityLoadSceneMode.Single
local SceneAdditiveLoadMode = UnityLoadSceneMode.Additive

function LoginView:__init()
	LoginView.Instance = self
	
	self.ui_config = {
		{"uis/views/login_prefab", "LoginView"},
	}
	self.server_list = LoginData.Instance:GetShowServerList()
	self.server_count = #self.server_list

	self.group_count = math.ceil(self.server_count / GROUP_SERVER_COUNT)
	self.server_temp_end_index = self.server_count - 1

	self.select_server_id = 1
	self.scene_cache = {}
	self.scene_loaded_bundle_name_t = {}
	self.has_scene_cached = false

	self.is_open_create = false				-- 是否打开过创建角色界面(用于返回的时候做判断用)
	self.is_click_event = false				-- 监听模型点击事件

	self.select_sex = GameEnum.MALE
	self.select_prof = 0
	self.server_group_cell_list = {}
	self.server_content_cell_list = {}
	self.server_item_num_in_group = GROUP_SERVER_COUNT
	self.cur_group_index = math.max(self.group_count - 1, 0)
	self.last_server = LoginData.Instance:GetLastLoginServer()
	self.cur_select_server = self.last_server

	self.cg_instance_list = {}

	-- AudioService.Instance:PlayBgm("audios/musics/bgmxuanjue", "xuanjuebgm")
end

function LoginView:__delete()
end

function LoginView:ReleaseCallBack()
	self:DeleteSelectRoleView()

	-- 取消监听模型点击事件
	if self.is_click_event then
		self.is_click_event = false
		EasyTouch.On_TouchDown = EasyTouch.On_TouchDown - self.click_handle
	end

	for k, v in pairs(self.server_content_cell_list) do
		v:DeleteMe()
	end
	self.server_content_cell_list = {}

    if self.draw_obj then
        self.draw_obj:DeleteMe()
        self.draw_obj = nil
    end

    self.cg_camera = nil
	self.cg_chuchang = nil
	self.cg_idle = nil

	self.load_callback = nil

	if self.cg_handler_2 ~= nil then
		GlobalTimerQuest:CancelQuest(self.cg_handler_2)
		self.cg_handler_2 = nil
	end

	if self.enter_game_server_succ then
		GlobalEventSystem:UnBind(self.enter_game_server_succ)
		self.enter_game_server_succ = nil
	end
end

function LoginView:OnLoadDengluLevelScene(bundle_name)
	self.scene_loaded_bundle_name_t[bundle_name] = bundle_name
end

function LoginView:SetCurSelectServerId(server_id)
	self.cur_select_server = server_id
end

function LoginView:GetCurSelectServerId()
	return self.cur_select_server
end

function LoginView:SetLoadCallBack(load_callback)
	self.load_callback = load_callback
end

function LoginView:LoadCallBack()
	if self.load_callback then
		self.load_callback()
	end
	-- 选服
	self:InitLastItem()
	self:InitGroupListView()
	self:InitServerListView()
	-- 初始化选择角色面板
	self:InitSelectRoleView()

	local back_btn = self.node_list["SelectBackBtn"]
	back_btn.button:AddClickListener(BindTool.Bind(self.OnClickSelectBack, self))

	if LoginData.Instance:GetServerFlag(self.last_server) == 2 then
		self.node_list["ImgNew"]:SetActive(true)
	else
		self.node_list["ImgNew"]:SetActive(false)
	end

	-- 设置版本号
	if IS_AUDIT_VERSION then
		self.node_list["TxtAppVersion"].text.text = ""
		self.node_list["TxtAssetVersion"].text.text = ""
		self.node_list["CopyRightText"].text.text = ""
	else
		self.node_list["TxtAppVersion"].text.text = string.format("v %s",GLOBAL_CONFIG.package_info.version)
		self.node_list["TxtAssetVersion"].text.text = GLOBAL_CONFIG.assets_info.version
		self.node_list["CopyRightText"].text.text = GLOBAL_CONFIG.param_list.copyrighttext or ""
	end

	local confirm_btn = self.node_list["SelectConfirmBtn"]
	confirm_btn.button:AddClickListener(BindTool.Bind(self.OnClickSelectConfirm, self))

	-- 创建角色

	-- 记录是否可点击创建动画模型进行切换角色
	self.if_can_click_model = {}
	self.cg_played_t = {}
	for i = 1, 4 do
		self.node_list["prof_toggle_" .. i].toggle:AddClickListener(BindTool.Bind2(self.OnToggleChange, self, i))
	end

	self.node_list["BtnReturn"].button:AddClickListener(BindTool.Bind(self.OnCreateRetunClick, self))
	self.node_list["BtnReturn1"].button:AddClickListener(BindTool.Bind(self.OnCreateRetunClick, self))
	self.node_list["BtnReturn2"].button:AddClickListener(BindTool.Bind(self.OnDefaultReturnClick, self))

	self.node_list["BtnStart"].button:AddClickListener(BindTool.Bind(self.OnStartGameClick, self))
	self.node_list["BtnDefaultService"].button:AddClickListener(BindTool.Bind(self.OnSelectServerClick, self))
	self.node_list["BtnSelect"].button:AddClickListener(BindTool.Bind(self.OnSelectServerClick, self))
	self.node_list["Craps"].button:AddClickListener(BindTool.Bind(self.OnCrapsClick, self))
	self.node_list["BtnLogin"].button:AddClickListener(BindTool.Bind(self.OnClickLogin, self))
	self.node_list["BtnGongGao"].button:AddClickListener(BindTool.Bind(self.OnClickGongGao, self))

	self.login_succ = false
	self.enter_game_server_succ = GlobalEventSystem:Bind(LoginEventType.ENTER_GAME_SERVER_SUCC, BindTool.Bind(self.EnterGameServerSucc, self))

	local create_confirm_btn = self.node_list["CreateConfirmBtn"]
	create_confirm_btn.button:AddClickListener(
		BindTool.Bind(self.OnClickCreateConfirm, self))

	local last_item = self.node_list["SelectLastItem"]
	last_item.toggle.isOn = true
	self.select_index = 0

	-- 显示账号登陆界面
	local ip = LoginData.Instance:GetGetServerIP(self.last_server)
	local port = LoginData.Instance:GetGetServerPort(self.last_server)
	GameNet.Instance:SetLoginServerInfo(ip, port)
	GameVoManager.Instance:GetUserVo().plat_server_id = self.last_server
	GameVoManager.Instance:GetUserVo().plat_server_name = LoginData.Instance:GetServerName(self.last_server)

	if self.bg_url ~= nil and self.bg_url ~= "" then
		self.node_list["BackGround"]:SetActive(true)
		self.node_list["BackGround"].raw_image:LoadURLSprite(self.bg_url)
	else
		self.node_list["BackGround"]:SetActive(false)
	end
	self.node_list["LoginView"]:SetActive(true)
	if ResMgr.ExistedInStreaming("AgentAssets/login_bg.png") and not GLOBAL_CONFIG.param_list.switch_list.show_3dlogin then
		self.node_list["PictureBackGround"]:SetActive(false)
	else
		self.node_list["PictureBackGround"]:SetActive(IS_AUDIT_VERSION)
	end
	
	self:ShowLogin()

	-- 显示Logo
	-- 检查SDK是否存在特殊的Logo，如果存在则使用SDK的Logo
	if ResMgr.ExistedInStreaming("AgentAssets/logo.png") then
		self.node_list["ImgDefaultLogo"]:SetActive(false)
		self.node_list["ImgLogoURL"]:SetActive(true)
		local url = ResUtil.GetAgentAssetPath("AgentAssets/logo.png")
		self.node_list["ImgLogoURL"].raw_image:LoadURLSprite(url, function()
			self.node_list["ImgLogoURL"].raw_image:SetNativeSize()
		end)
		-- self.node_list["ImgLogoURL"].load_raw_image_url.URL = url
	else
		self.node_list["ImgDefaultLogo"]:SetActive(true)
	end

	self:PlayLoginMusic()
end

function LoginView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "flush_select_role_view" then
			self:FlushSelectRoleView()
		elseif k == "flush_gonggao" and self.node_list["BtnGongGao"] then
			self.node_list["BtnGongGao"]:SetActive(v[1])
		end
	end
end

-- 设置登录背景
function LoginView:SetLoginURL(url)
	if url ~= nil and url ~= "" then
		self.bg_url = url
		if self.node_list["BackGround"] and self.node_list["BackGround"].raw_image then
			self.node_list["BackGround"]:SetActive(true)
			self.node_list["BackGround"].raw_image:LoadURLSprite(url)
		end
	end
end

----------最近登录、新服--------------
function LoginView:InitLastItem()
	local last_item = self.node_list["SelectLastItem"]
	local name = LoginData.Instance:GetShowServerNameById(self.last_server)
	self.SetServerItemName(last_item, name)
	last_item.toggle:AddValueChangedListener(
		BindTool.Bind(self.OnClickLastItem, self))

	local flag = LoginData.Instance:GetServerFlag(self.last_server)
	-- self.last_sever_state:SetAsset(self:GetServerState(flag))
	self.node_list["ImgServerState"].image:LoadSprite(self:GetServerState(flag))
	self.node_list["ImgPoint"].image:LoadSprite(self:GetServerState(flag))
end

function LoginView:OnClickLastItem(is_click)
	if is_click then
		local name = LoginData.Instance:GetShowServerNameById(self.last_server)
		local ip = LoginData.Instance:GetGetServerIP(self.last_server)
		local port = LoginData.Instance:GetGetServerPort(self.last_server)

		GameNet.Instance:SetLoginServerInfo(ip, port)
		GameVoManager.Instance:GetUserVo().plat_server_id = self.last_server
		GameVoManager.Instance:GetUserVo().plat_server_name = LoginData.Instance:GetServerName(self.last_server)
		self.node_list["TxtServer"].text.text = name
		self:SetCurSelectServerId(self.last_server)
	end
end
----------最近登录、新服--------------

----------创建ListView------------
function LoginView:InitGroupListView()
	local list_delegate = self.node_list["SelectServerGroup"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function LoginView:GetNumberOfCells()
	return self.group_count
end

function LoginView:RefreshCell(cell, cell_index)
	local server_group_cell = self.server_group_cell_list[cell]
	if server_group_cell == nil then
		server_group_cell = ServerGroupItem.New(cell.gameObject, self)
		self.server_group_cell_list[cell] = server_group_cell
		server_group_cell:SetToggleGroup(self.node_list["SelectServerGroup"].toggle_group)
	end

	local data = {}
	-- 反序，用总按钮数量减
	-- (cell_index + 1)是因为cell_index从0开始
	local index = self.group_count - (cell_index + 1)
	data.begin_index = GROUP_SERVER_COUNT * index
	data.end_index = data.begin_index + math.min(GROUP_SERVER_COUNT, self.server_count - data.begin_index) - 1
	data.cell_index = index
	server_group_cell:SetData(data)
end

function LoginView:GetCurGroupIndex()
	return self.cur_group_index
end

function LoginView:SetCurGroupIndex(group_index)
	self.cur_group_index = group_index

	if group_index < math.floor(self.server_count / GROUP_SERVER_COUNT) then
		self.server_item_num_in_group = GROUP_SERVER_COUNT
	else
		self.server_item_num_in_group = self.server_count % GROUP_SERVER_COUNT
	end

	self.node_list["SelectServerList"].scroller:ReloadData(0)
end

function LoginView:InitServerListView()
	local list_delegate = self.node_list["SelectServerList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells2, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell2, self)
end

function LoginView:GetNumberOfCells2()
	return math.ceil(self.server_item_num_in_group / 2)
end

function LoginView:RefreshCell2(cell, cell_index)
	local server_content_cell = self.server_content_cell_list[cell]
	if server_content_cell == nil then
		server_content_cell = ServerItemContent.New(cell.gameObject, self)
		self.server_content_cell_list[cell] = server_content_cell
		self.server_content_cell_list[cell].index = cell_index
	end

	local begin_index = self.server_temp_end_index - self.server_temp_end_index % GROUP_SERVER_COUNT
	local index = self.server_temp_end_index - cell_index * 2

	local data = {}
	data[1] = self.server_list[index + 1]
	if index > begin_index then
		data[2] = self.server_list[index - 1 + 1]
	end

	server_content_cell:SetData(data)
end

----------创建ListView------------

function LoginView.SetServerItemName(server_item, name)


	
	if transform ~= nil then
		node = U3DObject(transform.gameObject, transform, self)
		return node
	end

	local transform1 = server_item.transform:FindHard("ServerName")
	local left_text = U3DObject(transform1.gameObject, transform1, self)

	local transform2 = server_item.transform:FindHard("ServerNameHL")
	local left_text_hl = U3DObject(transform2.gameObject, transform2, self)
	left_text.text.text = name
	left_text_hl.text.text = name
end

function LoginView:SetTempServerEndIndex(index)
	self.server_temp_end_index = index
end

function LoginView:SetLowProf(low_prof)
	self.low_prof = low_prof
end

function LoginView:ShowLogin()
	--直接选角的话跳过
	local select_role_state = UtilU3d.GetCacheData("select_role_state")
	if select_role_state == 1 then
		--重置参数
		UtilU3d.CacheData("select_role_state", 0)

		--自动登陆平台账号
		local uservo = GameVoManager.Instance:GetUserVo()
		uservo.plat_name = UtilU3d.GetCacheData("select_role_plat_name")
		self.node_list["LoginView"]:SetActive(false)

		local ip = LoginData.Instance:GetGetServerIP(self.last_server)
		local port = LoginData.Instance:GetGetServerPort(self.last_server)
		GameNet.Instance:SetLoginServerInfo(ip, port)
		GameVoManager.Instance:GetUserVo().plat_server_id = self.last_server
		GameVoManager.Instance:GetUserVo().plat_server_name = LoginData.Instance:GetServerName(self.last_server)

		--上报登陆完成
		-- ReportManager:Step(Report.STEP_LOGIN_COMPLETE)

		local last_is_merge_server = UtilU3d.GetCacheData("last_is_merge_server")
		local last_role_list_count = UtilU3d.GetCacheData("last_role_list_count")
		if last_is_merge_server and last_role_list_count == 1 then
			--返回登陆前的服务器已经合服过并且只有一个账号的直接回到选服界面
			local name = LoginData.Instance:GetShowServerNameById(self.last_server)
			self.node_list["TxtServer"].text.text = name
			self.default_login:SetActive(true)
			self.node_list["SelectRole"]:SetActive(false)
			self.node_list["SelectServer"]:SetActive(false)
			return
		end

		LoadingPriorityManager.Instance:CancelRequest(self.request_priority_id)
		self.request_priority_id = LoadingPriorityManager.Instance:RequestPriority(LoadingPriority.High)

		-- 预加载场景
		self:PreloadScene(SCENE_BUNDLE[1].bundle, SCENE_BUNDLE[1].asset, CG_BUNDLE[1].bundle, CG_BUNDLE[1].asset, function()
			InitCtrl:SetPercent(0.93)
			self:PreloadScene(SCENE_BUNDLE[2].bundle, SCENE_BUNDLE[2].asset, CG_BUNDLE[2].bundle, CG_BUNDLE[2].asset, function()
				InitCtrl:SetPercent(0.96)
				self:PreloadScene(SCENE_BUNDLE[3].bundle, SCENE_BUNDLE[3].asset, CG_BUNDLE[3].bundle, CG_BUNDLE[3].asset, function()
					InitCtrl:SetPercent(0.99)
					self:PreloadScene(SCENE_BUNDLE[4].bundle, SCENE_BUNDLE[4].asset, CG_BUNDLE[4].bundle, CG_BUNDLE[4].asset, function()
						LoadingPriorityManager.Instance:CancelRequest(self.request_priority_id)
						ReportManager:Step(Report.STEP_CONNECT_LOGIN_SERVER)
						GameNet.Instance:AsyncConnectLoginServer(5)
						
						self.node_list["SelectServer"]:SetActive(false)
						self.node_list["Default_login"]:SetActive(false)
						self.node_list["SelectRole"]:SetActive(false)
						self.node_list["LoginView"]:SetActive(false)
					end)
				end)
			end)
		end)
		return
	end
	self.node_list["LoginView"]:SetActive(true)
	-- SDK登录
	-- 这里延迟一帧，因为调用SDK登录接口可能会暂停游戏进程，导致某些逻辑没有执行
	Scheduler.Delay(function ()
		ReportManager:Step(Report.STEP_SHOW_LOGIN)
		AgentAdapter.Instance:ShowLogin(function(is_succ)
			if is_succ then
				-- 审核服直接进入游戏
				local auto_login = LoginData.Instance:GetIsAutoLogin()
				if not auto_login then
					self.node_list["Default_login"]:SetActive(true)
					self.node_list["LoginView"]:SetActive(false)
				end

				if SettingCtrl ~= nil and SettingCtrl.Instance ~= nil then
					SettingCtrl.Instance:SendNoticeRequest()
				end

				local ip = LoginData.Instance:GetGetServerIP(self.last_server)
				local port = LoginData.Instance:GetGetServerPort(self.last_server)
				local name = LoginData.Instance:GetShowServerNameById(self.last_server)
				self.node_list["TxtServer"].text.text = name

				GameNet.Instance:SetLoginServerInfo(ip, port)
				GameVoManager.Instance:GetUserVo().plat_server_id = self.last_server
				GameVoManager.Instance:GetUserVo().plat_server_name = LoginData.Instance:GetServerName(self.last_server)

				ReportManager:Step(Report.STEP_LOGIN_COMPLETE)

				-- 审核服直接进入游戏
				if auto_login then
					self:OnStartGameClick()
					return
				end

				-- 入场CG
				if not self.is_played_loginCG then
					local stage_enter = GameObject.Find("CG/stage_enter")
					if not IsNil(stage_enter) then
						local cg_enter = stage_enter:GetComponent(typeof(UnityEngine.Playables.PlayableDirector))
						if not IsNil(cg_enter) then
							cg_enter.gameObject:SetActive(true)
							cg_enter:Play()
							self.is_played_loginCG = true
						end
					end
				end
			else
				self.node_list["Default_login"]:SetActive(false)
				self.node_list["LoginView"]:SetActive(true)
			end
		end)
	end)
end

-- 骰子随机名字
function LoginView:OnCrapsClick()
	-- self:PlaySelectFrofCg()
	self:RandomName()
end

-- 播放当前角色的CG(测试的时候用)
function LoginView:PlaySelectFrofCg()
	local prof = self.select_prof
	local bundle = SCENE_BUNDLE[prof].bundle
	local asset = SCENE_BUNDLE[prof].asset
	local cg_bundle = CG_BUNDLE[prof].bundle
	local cg_asset = CG_BUNDLE[prof].asset

	local cg_key = cg_bundle .. cg_asset
	local cg_obj = self.cg_instance_list[cg_key]
	if cg_obj then
		local center = nil
		local key = bundle..asset
		if self.scene_cache[key] then
			local objs = self.scene_cache[key].roots
			for i = 0, objs.Length - 1 do
				if objs[i].gameObject.name == "Main" then
					center = objs[i].gameObject.transform:Find("HeroPos")
					local scene_camera = objs[i].gameObject.transform:Find("Camera")
					if nil ~= scene_camera then
						scene_camera.gameObject:SetActive(false)
					end
				end
			end
		end

		cg_obj.gameObject:SetActive(true)
		cg_obj.transform:SetParent(center.transform)
		cg_obj.transform.localPosition = Vector3.zero

		local chuchang = cg_obj.transform:Find("stage_chuchang")
		self.cg_chuchang = chuchang:GetComponent(typeof(UnityEngine.Playables.PlayableDirector))
		self.cg_chuchang.gameObject:SetActive(true)
		self.cg_chuchang:Play()

		if self.cg_camera then
			EasyTouch.RemoveCamera(self.cg_camera)
		end

		self.cg_camera = cg_obj:GetComponentInChildren(typeof(UnityEngine.Camera))
		if self.cg_camera then
			EasyTouch.AddCamera(self.cg_camera)
		end
	end

end

function LoginView:OnClickSelectConfirm()
	self:OnStartGameClick()
end

function LoginView:OnClickSelectBack()
	-- 清空缓存的场景
	local SceneManager = UnitySceneManager
	for k,v in pairs(self.scene_cache) do
		if v.scene:IsValid() then
			SceneManager.UnloadSceneAsync(v.scene)
		end
	end
	self.scene_cache = {}
	self.has_scene_cached = false

	if self.draw_obj ~= nil then
		self.draw_obj:DeleteMe()
		self.draw_obj = nil
	end

	self.node_list["SelectServer"]:SetActive(false)
	self.node_list["SelectRole"]:SetActive(false)
	self.node_list["Default_login"]:SetActive(true)
	self.node_list["LoginView"]:SetActive(false)
	local name = LoginData.Instance:GetShowServerNameById(self.cur_select_server)
	self.node_list["TxtServer"].text.text = name
end

function LoginView:ClearScenes()
	-- 清空缓存的场景
	local SceneManager = UnitySceneManager
	for k,v in pairs(self.scene_cache) do
		if v.scene:IsValid() then
			SceneManager.UnloadSceneAsync(v.scene)
		end
	end
	self.scene_cache = {}
	self.has_scene_cached = false

	-- 清空CG实例
	for k, v in pairs(self.cg_instance_list) do
		ResMgr:Destroy(v)
	end
	self.cg_instance_list = {}

	-- 清理绘制物体
	if self.draw_obj ~= nil then
		self.draw_obj:DeleteMe()
		self.draw_obj = nil
	end
end

function LoginView:LoginScene(callback)
	local bunle_name = "scenes/map/w3_ts_denglu_main"
	local asset_name = "W3_TS_DengLu_Main"
	local load_mode = SceneSingleLoadMode

	ResMgr:LoadLevelAsync(
		bunle_name,
		asset_name,
		load_mode,
		function()
			self.scene_loaded_bundle_name_t[bunle_name] = bunle_name
			if callback then
				callback()
			end
			Scheduler.Delay(function()
				local scene = UnitySceneManager.GetSceneByName(asset_name)
				print_log("Login scene: ", scene)
				-- -- 入场CG
				-- local stage_idle = GameObject.Find("CG/stage_idle")
				-- if not IsNil(stage_idle) then
				-- 	local cg_idle = stage_idle:GetComponent(typeof(UnityEngine.Playables.PlayableDirector))
				-- 	if not IsNil(cg_idle) then
				-- 		cg_idle:Play()
				-- 	end
				-- end
			end)
		end)
end

-- 打开选角面板
-- 这里是为了解决在创建角色面板停留时，掉线导致返回选角面板，而没有施放内存
function LoginView:OpenSelectRole()
	if self.is_open_create then
		self:OnCreateRetunClick()
	else
		self:OnChangeToSelectRole()
	end
end

function LoginView:SetOpenCallback(callback)
	self.open_callback = callback
end

-- 打开后调用
function LoginView:OpenCallBack()
	-- 打开登录角色面板的时候加载最高优先级
	AssetBundleMgr:ReqHighLoad()

	if nil ~= self.open_callback then
		self.open_callback()
		self.open_callback = nil
	end
end

function LoginView:CloseCallBack()
	-- 进入场景时候降低先级
	AssetBundleMgr:ReqLowLoad()
end

function LoginView:OnCreateRetunClick()
	local role_list_ack_info = LoginData.Instance:GetRoleListAck()
	GlobalTimerQuest:CancelQuest(self.cg_handler)
	self.cg_handler = nil
	if self.cg_handler_2 ~= nil then
		GlobalTimerQuest:CancelQuest(self.cg_handler_2)
		self.cg_handler_2 = nil
	end
	self.select_role_id = 0
	self.is_enter_select_role = false
	if self.is_open_create and role_list_ack_info.count > 0 then
		-- 清空CG实例
		for k, v in pairs(self.cg_instance_list) do
			ResMgr:Destroy(v)
		end
		self.cg_instance_list = {}

		self:OnChangeToSelectRole()
		-- self:PlayLoginMusic()
	else
		if self.bg_url == nil or self.bg_url == "" then
			self:LoginScene(BindTool.Bind(self.ClearScenes, self))
		end
		LoginData.Instance:SetCurrSelectRoleId(-1)
		GameNet.Instance:ResetLoginServer()
		self.node_list["Default_login"]:SetActive(true)
		self.node_list["LoginView"]:SetActive(false)
		self.node_list["CreateRole"]:SetActive(false)
		self.node_list["SelectRole"]:SetActive(false)
		self.node_list["LoginRoot"]:SetActive(true)
		local name = LoginData.Instance:GetShowServerNameById(self.cur_select_server)
		self.node_list["TxtServer"].text.text = name
		if self.is_open_create then
			-- self:PlayLoginMusic()
		end
	end
end

function LoginView:OnDefaultReturnClick()
	GlobalEventSystem:Fire(LoginEventType.LOGOUT)
end

function LoginView:BackLoginView()
	self:OnCreateRetunClick()
	
	LoginData.Instance:SetCurrSelectRoleId(-1)
	GameNet.Instance:ResetLoginServer()
	self.node_list["Default_login"]:SetActive(false)
	self.node_list["LoginView"]:SetActive(true)
	self.node_list["SelectServer"]:SetActive(false)
end

function LoginView:OnClickLogin()
	self.node_list["LoginView"]:SetActive(false)
	self:ShowLogin()
end

function LoginView:OnClickGongGao()
	SettingCtrl.Instance:SetLoginState(true)
	SettingCtrl.Instance:SendNoticeRequest()
end

function LoginView:SetLoginButtonActive(enable)
	if self.node_list then
		self.node_list["BtnLogin"]:SetActive(enable)
	end
end

function LoginView:OnStartGameClick()
	local can_login, tip = LoginData.Instance:IsCanLoginServer(self.cur_select_server)
	if not can_login then
		SysMsgCtrl.Instance:ErrorRemind(tip)
		return
	end

	if self.login_succ then
		return
	end

	local client_time = GLOBAL_CONFIG.client_time and tonumber(GLOBAL_CONFIG.client_time) or 0
	local now_server_time = GLOBAL_CONFIG.server_info.server_time + (Status.NowTime - client_time)
	ReportManager:Step(Report.STEP_CLICK_START_GAME, nil, nil, nil, nil,
		GLOBAL_CONFIG.server_info.server_time,
		now_server_time,
		GameVoManager.Instance:GetUserVo().plat_account_type)

	if TipsCtrl.Instance then
		TipsCtrl.Instance:ShowLoadingTips()
	end

	if IS_AUDIT_VERSION then
		LoginCtrl.Instance:StartGame()
	else
		GameNet.Instance:AsyncConnectLoginServer(5)
	end

	if not IS_ON_CROSSSERVER then
		PlayerPrefsUtil.SetString("PRVE_SRVER_ID", self.cur_select_server)
		self.last_server = self.cur_select_server
	end
end

function LoginView:OnRoleListAck(role_list, is_hefu)
	local scene_load_complete_callback = function ()
		ReportManager:Step(Report.STEP_CONNECT_LOGIN_SERVER)
		GlobalTimerQuest:AddDelayTimer(function ()
			if self:IsOpen() and self.node_list then
				self.node_list["SelectServer"]:SetActive(false)
				self.node_list["Default_login"]:SetActive(false)
				self.node_list["SelectRole"]:SetActive(false)
				self.node_list["LoginView"]:SetActive(false)
			end
			
			if (0 == role_list.result or is_hefu) and role_list.count > 0 then
				self:OpenSelectRole()
			elseif -6 == role_list.result or is_hefu then
				self:OnChangeToCreate()
			end
		end, 0)
	end

	local show_createrole = LoginData.Instance:GetShowCreateRole()
	-- 已经有角色了
	if (0 == role_list.result or is_hefu) and role_list.count > 0 then
		local temp_role_list = TableCopy(role_list.role_list or role_list.combine_role_list)
		table.sort(temp_role_list, SortTools.KeyUpperSorter("last_login_time"))
		local prof = PlayerData.Instance:GetRoleBaseProf(temp_role_list[1].prof)
		if IS_AUDIT_VERSION and not show_createrole then
			scene_load_complete_callback()
			return
		end
		-- 只加载玩家最后一次登录的职业的场景
		self:PreloadScene(SCENE_BUNDLE[prof].bundle, SCENE_BUNDLE[prof].asset, nil, nil, function()
			scene_load_complete_callback()
		end)
	else
		if IS_AUDIT_VERSION and not show_createrole then
			scene_load_complete_callback()
			return
		end
		-- 没有角色则预加载所有场景
		self:PreloadScene(SCENE_BUNDLE[1].bundle, SCENE_BUNDLE[1].asset, CG_BUNDLE[1].bundle, CG_BUNDLE[1].asset, function()
			self:PreloadScene(SCENE_BUNDLE[2].bundle, SCENE_BUNDLE[2].asset, CG_BUNDLE[2].bundle, CG_BUNDLE[2].asset, function()
				self:PreloadScene(SCENE_BUNDLE[3].bundle, SCENE_BUNDLE[3].asset, CG_BUNDLE[3].bundle, CG_BUNDLE[3].asset, function()
					self:PreloadScene(SCENE_BUNDLE[4].bundle, SCENE_BUNDLE[4].asset, CG_BUNDLE[4].bundle, CG_BUNDLE[4].asset, function()
						scene_load_complete_callback()
					end)
				end)
			end)
		end)
	end
end

function LoginView:OnSelectServerClick()
	self.node_list["Default_login"]:SetActive(false)
	self.node_list["SelectRole"]:SetActive(false)
	self.node_list["LoginView"]:SetActive(false)
	self.node_list["SelectServer"]:SetActive(true)
end

function LoginView:OnChangeToCreate()
	if self:IsOpen() then
		self.is_open_create = true
		self.select_prof = 0

		local index = math.random(1, 4)
		self:OnToggleChange(index, true)
		-- AudioService.Instance:PlayBgm("audios/musics/bgmxuanjue", "xuanjuebgm")
	end
end

function LoginView:OnToggleChange(prof, is_click)
	if is_click then
		if prof == self.select_prof then
			return
		end
		if self.draw_obj ~= nil then
			self.draw_obj:DeleteMe()
			self.draw_obj = nil
		end

		self.select_prof = prof
		local prof_numb = 62 + prof

		self.node_list["ImgAbility"].image:LoadSprite(ResPath.GetLoginRes("icon_0" .. prof_numb))
		self.node_list["ImgIcon"].image:LoadSprite(ResPath.GetLoginRes("prof_icon_" .. prof))
		self.node_list["ImgIcon"].image:SetNativeSize()
		local text_list = Language.Login.TextDesc[prof]
		if text_list then
			for i = 1, 2 do
				self.node_list["TextDesc" .. i].text.text = text_list[i]
			end
		end

		self.cg_chuchang = nil

		local bundle, asset, cg_bundle, cg_asset, position, rotation
		self.select_sex = ROLE_PROF_SEX[prof]
		self.is_male = ROLE_PROF_SEX[prof] == GameEnum.MALE

		bundle = SCENE_BUNDLE[prof].bundle
		asset = SCENE_BUNDLE[prof].asset
		cg_bundle = CG_BUNDLE[prof].bundle
		cg_asset = CG_BUNDLE[prof].asset

		self:RandomName()

		if self.cg_handler ~= nil then
			GlobalTimerQuest:CancelQuest(self.cg_handler)
			self.cg_handler = nil
		end

		-- 取消监听模型点击事件
		if self.click_handle and self.is_click_event then
			self.is_click_event = false
			EasyTouch.RemoveCamera(self.cg_camera)
			EasyTouch.On_TouchDown = EasyTouch.On_TouchDown - self.click_handle
		end

		-- CG 切换
		local cg_key = cg_bundle .. cg_asset
		local change_scene_func = function()
			self:ChangeScene(bundle, asset, function()
				local cg_obj = self.cg_instance_list[cg_key]

				self.node_list["SelectServer"]:SetActive(false)
				self.node_list["LoginRoot"]:SetActive(false)
				self.node_list["SelectRole"]:SetActive(false)
				TipsCtrl.Instance:CloseLoadingTips()

				if nil == cg_obj then
					self.node_list["CreateRole"]:SetActive(true)
					return
				end

				local center = nil
				local key = bundle..asset
				if self.scene_cache[key] then
					local objs = self.scene_cache[key].roots
					for i = 0, objs.Length - 1 do
						if objs[i].gameObject.name == "Main" then
							center = objs[i].gameObject.transform:Find("HeroPos")
							local scene_camera = objs[i].gameObject.transform:Find("Camera")
							if nil ~= scene_camera then
								scene_camera.gameObject:SetActive(false)
							end
						end
					end
				end

				cg_obj.gameObject:SetActive(true)
				cg_obj.transform:SetParent(center.transform)
				-- cg_obj.transform.localPosition = position
				cg_obj.transform.localPosition = Vector3.zero

				local chuchang = cg_obj.transform:Find("stage_chuchang")
				self.cg_chuchang = chuchang:GetComponent(typeof(UnityEngine.Playables.PlayableDirector))
				self.cg_chuchang.gameObject:SetActive(true)
				self.cg_chuchang:Play()

				local idle = cg_obj.transform:Find("stage_idle")
				self.cg_idle = idle:GetComponent(typeof(UnityEngine.Playables.PlayableDirector))
				-- local attack = cg_obj.transform:Find("stage_attack")
				-- self.cg_attack = attack:GetComponent(typeof(UnityEngine.Playables.PlayableDirector))

				self.cg_camera = cg_obj:GetComponentInChildren(typeof(UnityEngine.Camera))
				if self.cg_camera then
					EasyTouch.AddCamera(self.cg_camera)
				end

				-- 关闭其他的场景.
				for k,v in pairs(self.scene_cache) do
					if k ~= key then
						local objs = v.roots
						for i = 0,objs.Length-1 do
							local obj = objs[i]
							obj:SetActive(false)
						end
					end
				end

				-- 卸载登录界面
				local SceneManager = UnitySceneManager
				local scene = SceneManager.GetSceneByName("W3_TS_DengLu_Main")
				if scene and scene:IsValid() then
					local roots = scene:GetRootGameObjects()
					for i = 0, roots.Length-1 do
						local obj = roots[i]
						obj:SetActive(false)
					end
					SceneManager.UnloadSceneAsync(scene)
				end

				self.click_handle = function(gesture)
					-- 只有跳过动画了才能点击模型切换角色
					if self.if_can_click_model[prof] then
						if gesture.pickedObject ~= nil then
							self.modelparent = gesture.pickedObject.transform.parent
							if self.modelparent.name == "1003001" or
								self.modelparent.name == "1004001" or
								self.modelparent.name == "1101001" or
								self.modelparent.name == "1102001" then
								local rotation = Vector3(0, -gesture.deltaPosition.x, 0)
								self.modelparent.transform:Rotate(rotation,UnityEngine.Space.World)
							end
						end
					end
				end

				-- 监听模型拖拽事件
				if not self.is_click_event then
					self.is_click_event = true
					EasyTouch.On_TouchDown = EasyTouch.On_TouchDown + self.click_handle
				end

				for k,v in pairs(self.if_can_click_model) do
					if k ~= prof then
						self.if_can_click_model[k] = false
					end
				end


				if self.cg_played_t[prof] and not IsNil(self.cg_chuchang) then
					if not IsNil(self.cg_idle) then
						self.cg_chuchang:Stop()
						self.cg_chuchang.gameObject:SetActive(false)
						self.cg_idle.gameObject:SetActive(true)
					end

					self.node_list["CreateRole"]:SetActive(true)
					if not self.node_list["prof_toggle_" .. prof].toggle.isOn then
						self.node_list["prof_toggle_" .. prof].toggle.isOn = true
					end

					-- if self.cg_handler_2 ~= nil then
					-- 	GlobalTimerQuest:CancelQuest(self.cg_handler_2)
					-- 	self.cg_handler_2 = nil
					-- end
					-- self.cg_handler_2 = GlobalTimerQuest:AddRunQuest(
					-- 	function()
					-- 		if not IsNil(self.cg_attack) then
					-- 			if self.cg_attack.duration - self.cg_attack.time <= 2 then
					-- 				GlobalTimerQuest:CancelQuest(self.cg_handler)
					-- 				self.cg_handler = nil
					-- 				self.if_can_click_model[prof] = true
					-- 			end
					-- 		end
					-- 	end, 0)


					self:ChangeProf()
					return
				end


				self.node_list["CreateRole"]:SetActive(false)

				self.cg_played_t[prof] = true
				if self.cg_handler ~= nil then
					GlobalTimerQuest:CancelQuest(self.cg_handler)
					self.cg_handler = nil
				end
				self.cg_handler = GlobalTimerQuest:AddRunQuest(
					function()
						if not IsNil(self.cg_chuchang) then
							if self.cg_chuchang.duration - self.cg_chuchang.time <= 0.1 then
								GlobalTimerQuest:CancelQuest(self.cg_handler)
								self.node_list["CreateRole"]:SetActive(true)
								self.cg_handler = nil
								self.if_can_click_model[prof] = true
							elseif self.cg_chuchang.duration - self.cg_chuchang.time <= 2 then
								self.node_list["CreateRole"]:SetActive(true)
								self.if_can_click_model[prof] = true
								if not self.node_list["prof_toggle_" .. prof].toggle.isOn then
									self.node_list["prof_toggle_" .. prof].toggle.isOn = true
								end
							end
						end
					end, 0)
			end)
		end

		-- 加载场景
		self:PreloadScene(bundle, asset, cg_bundle, cg_asset, change_scene_func, true)
	 end
end

function LoginView:OnClickCreateConfirm()
	local role_name = self.node_list["CreateNameInput"].input_field.text
	if role_name == "" then
		return
	end
	if ChatFilter.Instance:IsIllegal(role_name, true) or ChatFilter.Instance:IsEmoji(role_name) then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.IllegalContent)
		return
	end
	
	if string.utf8len(role_name) > COMMON_CONSTS.GUILD_NAME_MAX then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NameLenLimit)
		return
	end

	LoginCtrl.SendCreateRole(role_name, self.select_prof, self.select_sex)
end

function LoginView:RandomName()
	local name_cfg = ConfigManager.Instance:GetAutoConfig("randname_auto").random_name[1]
	local first_list = {}
	local last_list = {}
	local the_list_1 = {}
	local the_list_2 = {}
	if self.select_sex == GameEnum.FEMALE then
		the_list_1 = name_cfg.female_first
		the_list_2 = name_cfg.female_last
	else
		the_list_1 = name_cfg.male_first
		the_list_2 = name_cfg.male_last
	end

	for k,v in pairs(the_list_1) do
		table.insert(first_list,v)
	end

	for k,v in pairs(the_list_2) do
		table.insert(last_list,v)
	end
	local name = first_list[math.random(1, #first_list)] .. last_list[math.random(1, #last_list)]

	self.node_list["CreateNameInput"].input_field.text = name
end

function LoginView:GetProfDesc(prof)
	local cfg = ConfigManager.Instance:GetAutoConfig("rolezhuansheng_auto").job
	local prof_info = {}
	for k,v in pairs(cfg) do
		if v.id == prof then
			prof_info.describe = v.describe
			prof_info.character = v.character
			return prof_info
		end
	end
end

-- 服务器标记 (1: 火爆 2: 新服 3: 即将开服 4: 测试 5: 维护)
function LoginView:GetServerState(flag)
	local asset = ""
	if flag == 1 then
		asset = "ball_red"
	elseif flag == 2 then
		asset = "ball_green"
	elseif flag == 3 then
		asset = "ball_blue"
	elseif flag == 4 then
		asset = "ball_yellow"
	elseif flag == 5 then
		asset = "ball_gray"
	end
	return "uis/views/login/images_atlas", asset
end

function LoginView:ChangeProf()
	if self.cg_handler ~= nil then
		GlobalTimerQuest:CancelQuest(self.cg_handler)
		self.cg_handler = nil
	end

	if not IsNil(self.cg_idle) then
		self.cg_idle:Play()
	end

	-- if not IsNil(self.cg_idle) then
	-- 	self.cg_idle:Stop()
	-- end

	-- if not IsNil(self.cg_attack) then
	-- 	self.cg_attack:Play()
	-- end

	-- if self.select_sex == GameEnum.MALE then
	-- 	self:ClickRoleAttackMale()
	-- else
	-- 	self:ClickRoleAttackFemale()
	-- end
end

-- 选择男的时候攻击
function LoginView:ClickRoleAttackMale()
	if self.cg_handler ~= nil then
		GlobalTimerQuest:CancelQuest(self.cg_handler)
		self.cg_handler = nil
	end
end

-- 选择女的时候攻击
function LoginView:ClickRoleAttackFemale()
	if self.cg_handler ~= nil then
		GlobalTimerQuest:CancelQuest(self.cg_handler)
		self.cg_handler = nil
	end
end

function LoginView:ChangeScene(bundle, asset, callback)
	if not bundle or not asset then
		print_warning("bundle or asset is nill")
		return
	end
	local key = bundle..asset
	local SceneManager = UnitySceneManager


	-- 激活/加载当前场景
	local scene = self.scene_cache[key]
	if scene ~= nil then
		SceneManager.SetActiveScene(scene.scene)
		local objs = scene.roots
		for i = 0,objs.Length-1 do
			local obj = objs[i]
			obj:SetActive(true)
		end
		callback()
	else
		local load_mode = SceneAdditiveLoadMode
		if not self.has_scene_cached then
			self.scene_cache = {}
		end
		ResMgr:LoadLevelAsync(
			bundle,
			asset,
			load_mode,
			function()
				self.scene_loaded_bundle_name_t[bundle] = bundle
				Scheduler.Delay(function()
					local scene = SceneManager.GetSceneByName(asset)
					SceneManager.SetActiveScene(scene)
					self.scene_cache[key] = {
						scene = scene,
						roots = scene:GetRootGameObjects()
					}

					self.has_scene_cached = true
					callback()
				end)
			end)
	end
end

function LoginView:PreloadScene(bundle, asset, cg_bundle, cg_asset, callback, not_hide)
	local key = bundle .. asset
	local SceneManager = UnitySceneManager

	local load_mode = SceneAdditiveLoadMode
	if not self.has_scene_cached then
		self.scene_cache = {}
		self.cg_instance_list = {}
	end

	local scene_load_callback = function ()
		print_log("[loading] finish load create scene", bundle, asset, os.date())
		local scene = SceneManager.GetSceneByName(asset)
		local objs = scene:GetRootGameObjects()

		if not not_hide then
			for i = 0, objs.Length-1 do
				local obj = objs[i]
				obj:SetActive(false)
			end
		end

		self.scene_cache[key] = {
			scene = scene,
			roots = objs
		}
		self.has_scene_cached = true
		self:PreLoadCG(cg_bundle, cg_asset, objs, function ()
			callback()
		end)
	end

	if self.scene_cache[key] then
		scene_load_callback()
	else
		print_log("[loading] start load create scene", bundle, asset, os.date())
		ResMgr:LoadLevelAsync(
			bundle,
			asset,
			load_mode,
			function()
				self.scene_loaded_bundle_name_t[bundle] = bundle
				Scheduler.Delay(function()
					scene_load_callback()
				end)
			end)
	end
end

function LoginView:PreLoadCG(bundle, asset, objs, callback)
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
		end)
	else
		callback()
	end
end

function LoginView:PlayLoginMusic()
	if not IS_AUDIT_VERSION then
		AudioService.Instance:PlayBgm("audios/musics/bgmlogin", "loginmusic")
	end
end

---------------------------------------------------------------
ServerItemContent = ServerItemContent  or BaseClass(BaseCell)

function ServerItemContent:__init()
	self.server_item_contain_list = {}
	for i = 1, 2 do
		self.server_item_contain_list[i] = {}
		self.server_item_contain_list[i].server_item_item = ServerItem.New(self.node_list["ServerItem" .. i])

		self.server_item_contain_list[i].server_item_item:SetToggleGroup(LoginView.Instance.node_list["SelectCommon"].toggle_group)
	end
end

function ServerItemContent:__delete()
	for i = 1, 2 do
		if self.server_item_contain_list[i] then
			self.server_item_contain_list[i].server_item_item:DeleteMe()
			self.server_item_contain_list[i].server_item_item = nil
		end
	end
end

function ServerItemContent:SetData(data)
	for i = 1, 2 do
		self.server_item_contain_list[i].server_item_item:SetData(data[i])
	end
end

----------------------------------------------------------------------------
ServerItem = ServerItem or BaseClass(BaseCell)

function ServerItem:__init()

	self.server_id = 0
	self.node_list["CellServerItem"].toggle:AddValueChangedListener(BindTool.Bind(self.OnClickItem, self))
	self.root_node.toggle:AddValueChangedListener(BindTool.Bind(self.OnValueChange,self))
end

function ServerItem:SetData(data)
	self.data = data
	self:OnFlush()
end

function ServerItem:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function ServerItem:OnFlush()
	self.root_node:SetActive(true)
	if self.data == nil then
		self.root_node:SetActive(false)
		return
	end

	if self.data.id == LoginView.Instance:GetCurSelectServerId() then
		self.root_node.toggle.isOn = true
	else
		self.root_node.toggle.isOn = false
	end


	local hand_bundle, hand_asset = "uis/images_atlas", "Torch_2"
	if self.data.flag == 2 then
		self.node_list["ImgNew"]:SetActive(true)
	else
		self.node_list["ImgNew"]:SetActive(false)
	end

	local bundle_bundle, bundle_asset = self:GetServerState(self.data.flag)
	self.node_list["ImgServeState"].image:LoadSprite(bundle_bundle, bundle_asset)
	self.node_list["TxtLevel"].text.text = self.data.role_level

	local name = LoginData.Instance:GetShowServerName(self.data)
	self.node_list["TxtServerName"].text.text = name
	self.node_list["TxtServerNameHL"].text.text = name
end

--点击
function ServerItem:OnClickItem()
	LoginView.Instance:SetCurSelectServerId(self.data.id)
	GameNet.Instance:SetLoginServerInfo(self.data.ip, self.data.port)
	GameVoManager.Instance:GetUserVo().plat_server_id = self.data.id
	GameVoManager.Instance:GetUserVo().plat_server_name = LoginData.Instance:GetServerName(self.data.id)
end

function ServerItem:OnValueChange()
--点击
end

-- 服务器标记 (1: 火爆 2: 新服 3: 即将开服 4: 测试 5: 维护)
function ServerItem:GetServerState(flag)
	local asset = "ball_red"
	if flag == 1 then
		asset = "ball_red"
	elseif flag == 2 then
		asset = "ball_green"
	elseif flag == 3 then
		asset = "ball_blue"
	elseif flag == 4 then
		asset = "ball_yellow"
	elseif flag == 5 then
		asset = "ball_gray"
	end
	return "uis/views/login/images_atlas", asset
end

---------------------------------
ServerGroupItem = ServerGroupItem or BaseClass(BaseCell)

function ServerGroupItem:__init()
	self.cur_group_index = 0
	self.node_list["ServerGroupItem"].toggle:AddValueChangedListener(BindTool.Bind(self.OnClickItem, self))
	self.root_node.toggle:AddValueChangedListener(BindTool.Bind(self.OnValueChange,self))
end

function ServerGroupItem:SetData(data)
	self.data = data
	self.cur_group_index = data.cell_index
	self:OnFlush()
end

function ServerGroupItem:OnFlush()
	if self.cur_group_index == LoginView.Instance:GetCurGroupIndex() then
		self.root_node.toggle.isOn = true
		self:OnClickItem()
	else
		self.root_node.toggle.isOn = false
	end

	local server_list = LoginData.Instance:GetShowServerList()
	-- local server_name = server_list[self.data.begin_index + 1].id .. "-" .. server_list[self.data.end_index + 1].id .. Language.Login.Qu

	local server_name = (self.data.begin_index + 1) .. "-" .. (self.data.end_index + 1) .. Language.Login.Qu
	if self.data.begin_index == self.data.end_index then
		server_name = (self.data.begin_index + 1) .. Language.Login.Qu
	end

	self.node_list["TxtNormal"].text.text = server_name
	self.node_list["TxtHighLight"].text.text = server_name
end

function ServerGroupItem:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function ServerGroupItem:OnClickItem()
	LoginView.Instance:SetTempServerEndIndex(self.data.end_index)
	LoginView.Instance:SetCurGroupIndex(self.cur_group_index)
end

function ServerGroupItem:OnValueChange(is_click)
	--点击
	--if is_click then
	--end
end

function LoginView:EnterGameServerSucc()
	self.login_succ = true
	-- 提前打开加载页（为了进游戏时的体验）
	Scene.Instance:OpenSceneLoading()
end