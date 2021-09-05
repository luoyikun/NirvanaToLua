require("game/login/login_data")
require("game/login/login_view")
require("game/login/login_select_role_view")

-- 登录
LoginCtrl = LoginCtrl or BaseClass(BaseController)

LOGIN_STATE_PLAT_LOGIN = 0
LOGIN_STATE_SERVER_LIST = 1
LOGIN_STATE_CREATE_ROLE = 2
LOGIN_STATE_LOADING = 3
LOGIN_VERIFY_KEY = "566713d23b8810efb313d6934cf77610"

--职业对应性别
ROLE_PROF_SEX = {
	[GameEnum.ROLE_PROF_1] = GameEnum.MALE,									--男近战
	[GameEnum.ROLE_PROF_2] = GameEnum.MALE,									--男远程
	[GameEnum.ROLE_PROF_3] = GameEnum.FEMALE,								--女近战
	[GameEnum.ROLE_PROF_4] = GameEnum.FEMALE,								--女远程
}

function LoginCtrl:__init()
	if LoginCtrl.Instance ~= nil then
		print_error("[LoginCtrl] attempt to create singleton twice!")
		return
	end
	LoginCtrl.Instance = self

	self.data = LoginData.New()
	self.view = LoginView.New(ViewName.Login)

	self:RegisterAllProtocols()
	self:RegisterAllEvents()

	self.is_click_start_game = false
	self.is_load_complete = false

	self.retry_connect_login_times = 0
	
	-- 加载品质控制器
	QualityConfig.ClearInstance()
	local loader = AllocResAsyncLoader(self, "RoleOcclusion")
	loader:Load(
		"misc/quality",
		"QualityConfig",
		typeof(QualityConfig),
		function(config)
			if IsLowMemSystem then -- 低内存系统不开启实时阴影
				QualityConfig.SetOverrideShadowQuality(0, 0)
			end
			
			if config ~= nil then
				print_log("Load the QualityConfig.")
			else
				print_error("Can not load the QualityConfig")
			end
        end)

	-- 创建渠道匹配器.
	AgentAdapter.New()
	-- 加载鼠标点击特效
	LoginCtrl.CreateClickEffectCanvas()
	--直接选角的话跳过
	local select_role_state = UtilU3d.GetCacheData("select_role_state")
	if select_role_state == 1 then
		return
	end

	-- 检查SDK是否存在特殊的登录页，如果存在则使用SDK的登录页,并且服务端show_3dlogin开关为false，则不播放开场CG
	if ResMgr.ExistedInStreaming("AgentAssets/login_bg.png") and not GLOBAL_CONFIG.param_list.switch_list.show_3dlogin then
		local url = ResUtil.GetAgentAssetPath("AgentAssets/login_bg.png")
		self.view:SetLoginURL(url)
		return
	end
end

function LoginCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	LoginCtrl.Instance = nil

	if nil ~= AgentAdapter.Instance then
		AgentAdapter.Instance:DeleteMe()
		AgentAdapter.Instance = nil
	end
	self.depend = nil
end

function LoginCtrl:StartLogin(complete_callback)
	self.view:SetLoadCallBack(complete_callback)
	self.view:Open()
end

function LoginCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCLoginAck, "OnLoginAck")
	self:RegisterProtocol(SCRoleListAck, "OnRoleListAck")
	self:RegisterProtocol(SCMergeRoleListAck, "OnMergeRoleListAck")
	self:RegisterProtocol(SCCreateRoleAck, "OnCreateRoleAck")
	self:RegisterProtocol(SCUserEnterGSAck, "OnUserEnterGSAck")
	self:RegisterProtocol(SCProfNumInfo, "OnProfNumInfo")
	self:RegisterProtocol(SCLHeartBeat, "OnLHeartBeat")
	self:RegisterProtocol(SCDisconnectNotice, "OnDisconnectNotice")
end

function LoginCtrl:RegisterAllEvents()
	self:BindGlobalEvent(LoginEventType.LOGIN_SERVER_CONNECTED, BindTool.Bind(self.OnConnectLoginServer, self))
	self:BindGlobalEvent(LoginEventType.LOGIN_SERVER_DISCONNECTED, BindTool.Bind(self.OnDisconnectLoginServer, self))

	self:BindGlobalEvent(LoginEventType.GAME_SERVER_CONNECTED, BindTool.Bind(self.OnConnectGameServer, self))
	self:BindGlobalEvent(LoginEventType.GAME_SERVER_DISCONNECTED, BindTool.Bind(self.OnDisconnectGameServer, self))

	self:BindGlobalEvent(LoginEventType.CROSS_SERVER_CONNECTED, BindTool.Bind(self.OnConnectLoginServer, self))
	self:BindGlobalEvent(LoginEventType.CROSS_SERVER_DISCONNECTED, BindTool.Bind(self.OnDisconnectLoginServer, self))

	self:BindGlobalEvent(SceneEventType.SCENE_LOADING_STATE_QUIT, BindTool.Bind(self.OnSceneLoaded, self))
end

function LoginCtrl.CreateClickEffectCanvas()
	ResPoolMgr:GetEffectAsync("uis/views/clickeffectcanvas_prefab", "ClickEffectCanvas", function(obj)
		if IsNil(obj) then
			return
		end
		local canvas = obj:GetComponent(typeof(UnityEngine.Canvas))
		canvas.overrideSorting = true
		canvas.sortingOrder = 32767

		local UIRoot = GameObject.Find("GameRoot/UILayer").transform
		if nil ~= UIRoot then
			canvas.transform:SetParent(UIRoot, false)
			canvas.transform:SetLocalScale(1, 1, 1)
			local rect = canvas.transform:GetComponent(typeof(UnityEngine.RectTransform))
			rect.anchorMax = Vector2(1, 1)
			rect.anchorMin = Vector2(0, 0)
			rect.anchoredPosition3D = Vector3(0, 0, 0)
			rect.sizeDelta = Vector2(0, 0)
		end
	end)
end

function LoginCtrl:OnConnectLoginServer(is_suc)
	if is_suc then
		ReportManager:Step(Report.STEP_LOGIN_SERVER_CONNECTED)
		if IS_MSG_ENCRYPT then
			GameNet.Instance:GetGameServerNet():ClearEncryptKey()
		end
		local user_vo = GameVoManager.Instance:GetUserVo()
		local protocol = ProtocolPool.Instance:GetProtocol(CSLoginReq)
		protocol.rand_1 = math.floor(math.random(1000000, 10000000))
		protocol.login_time = os.time()
		protocol.key = user_vo.plat_session_key
		protocol.rand_2 = math.floor(math.random(1000000, 10000000))
		protocol.plat_fcm = user_vo.plat_fcm
		protocol.plat_name = user_vo.plat_name
		protocol.plat_server_id = user_vo.plat_server_id
		if IS_ON_CROSSSERVER then
			protocol:EncodeAndSend(GameNet.Instance:GetCrossServerNet())
		else
			protocol:EncodeAndSend(GameNet.Instance:GetLoginNet())
		end

		if nil == self.login_server_heartbeat_timer then
			self.login_server_heartbeat_timer = GlobalTimerQuest:AddRunQuest(function()
				self.SendLoginServerHeartBeat()
			end, 10)
		end
	else
		print_log("LoginCtrl:OnConnectLoginServer fail")
		ReportManager:Step(Report.STEP_LOGIN_SERVER_CONNECTED_FAILED)
		if not ViewManager.Instance:IsOpen(ViewName.LoadingTips) then
			TipsCtrl.Instance:ShowDisconnected()
		else
			-- 自动重试5次之后，提示玩家连接失败
			if self.retry_connect_login_times >= 5 then
				self.retry_connect_login_times = 0
				ViewManager.Instance:Close(ViewName.LoadingTips)
				TipsCtrl.Instance:ShowDisconnected()
			else
				self.retry_connect_login_times = self.retry_connect_login_times + 1
				GameNet.Instance:ResetLoginServer()
				GameNet.Instance:ResetGameServer()
				GameNet.Instance:AsyncConnectLoginServer(5)
			end
		end
		if not IS_AUDIT_VERSION then
			TipsCtrl.Instance:ShowSystemMsg("登录认证服务器失败.")
		end
	end
end


function LoginCtrl:OnDisconnectLoginServer()
	if nil ~= self.login_server_heartbeat_timer then
		GlobalTimerQuest:CancelQuest(self.login_server_heartbeat_timer)
		self.login_server_heartbeat_timer = nil
	end
	if CrossServerData.Instance then
		-- 是否手动断线
		if not CrossServerData.Instance:GetIsManualDisconnect() then
			ReportManager:Step(Report.STEP_DISCONNECT_LOGIN_SERVER)
			-- if nil == self.show_disconnect_tips_timer then
				-- local func = function ()
					if TipsCtrl.Instance ~= nil then
						TipsCtrl.Instance:ShowDisconnected(reason ~= GameNet.DISCONNECT_REASON_MULTI_LOGIN)
					end
					-- self.show_disconnect_tips_timer = nil
				-- end
				-- self.show_disconnect_tips_timer = GlobalTimerQuest:AddDelayTimer(func, 10)
			-- end
		end
	end
end

function LoginCtrl:OnConnectGameServer(is_suc)
	if is_suc then
		ReportManager:Step(Report.STEP_CONNECT_GAME_SERVER)
		if IS_MSG_ENCRYPT then
			GameNet.Instance:GetGameServerNet():TrySendEncryptKeyToServer()
		end
		self.SendUserEnterGSReq()
	else
		print_log("LoginCtrl:OnConnectGameServer fail")
		ReportManager:Step(Report.STEP_CONNECT_GAME_SERVER_FAILED)
		TipsCtrl.Instance:ShowSystemMsg("登录游戏服务器失败.")
	end
end

function LoginCtrl:OnDisconnectGameServer(reason, disconnect_notice_type)
	print_warning("#########OnDisconnectGameServer", reason, disconnect_notice_type)

	if ActivityData.Instance then
		ActivityData.Instance:ClearAllActivity()
	end

	-- 是否手动断线
	if CrossServerData.Instance then
		if CrossServerData.Instance:GetIsManualDisconnect() then return end
	end

	ReportManager:Step(Report.STEP_DISCONNECT_GAME_SERVER)
	-- if nil == self.show_disconnect_tips_timer then
		-- local func = function ()
			if TipsCtrl.Instance ~= nil then
				TipsCtrl.Instance:ShowDisconnected(reason ~= GameNet.DISCONNECT_REASON_MULTI_LOGIN, disconnect_notice_type == DISCONNECT_NOTICE_TYPE.LOGIN_OTHER_PLACE)
			end
		-- 	self.show_disconnect_tips_timer = nil
		-- end
		-- self.show_disconnect_tips_timer = GlobalTimerQuest:AddDelayTimer(func, 10)
	-- end
end

function LoginCtrl:OnConnectCrossServer(is_suc)

end

function LoginCtrl:OnDisconnectCrossServer()

end

function LoginCtrl:OnSceneLoaded()

end

function LoginCtrl:OnLoginAck(protocol)
	TimeCtrl.Instance:SetServerTime(protocol.server_time)
	if 0 == protocol.result then
		ReportManager:Step(Report.STEP_ON_LOGIN_ACK)
		GameNet.Instance:SetGameServerInfo(protocol.gs_hostname, protocol.gs_port)
		print_log("LoginCtrl:OnLoginAck hostname:" .. protocol.gs_hostname .. "  prot:" .. protocol.gs_port)
		local user_vo = GameVoManager.Instance:GetUserVo()
		user_vo:SetNowRole(protocol.role_id)
		user_vo.login_time = protocol.time
		user_vo.session_key = protocol.key
		user_vo.anti_wallow = protocol.anti_wallow
		user_vo.scene_id = protocol.scene_id
		user_vo.last_scene_id = protocol.last_scene_id

		-- 设置为手动断线
		CrossServerData.Instance:SetDisconnectGameServer()

		if IS_ON_CROSSSERVER then
			GameNet.Instance:DisconnectCrossServer()
		else
			GameNet.Instance:DisconnectLoginServer()
		end
		GameNet.Instance:AsyncConnectGameServer(5)

		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		ReportManager:ReportUrlToSQ(main_role_vo.server_id, main_role_vo.role_name, main_role_vo.role_id, main_role_vo.level, "", "login")
		if ReportManager.ReportLoginEvent then
			ReportManager:ReportLoginEvent()
		end
	elseif -4 == protocol.result then
		TipsCtrl.Instance:OpenMessageBox(Language.Common.GameWorldNotExist, function()
			GameRoot.Instance:Restart()
		end)
	else
		print_log("LoginCtrl:OnLoginAck", protocol.result)
		ReportManager:Step(Report.STEP_ON_LOGIN_ACK_FAILED)
		TipsCtrl.Instance:ShowSystemMsg(string.format("登录认证失败: %d.", protocol.result))
	end
end

function LoginCtrl:OnRoleListAck(protocol)
	-- 下发正常角色列表表示未合服
	IS_MERGE_SERVER = false
	self.data:SetRoleListAck(protocol)
	ReportManager:Step(Report.STEP_ROLE_LIST_ACK)
	local user_vo = GameVoManager.Instance:GetUserVo()

	local show_createrole = LoginData.Instance:GetShowCreateRole()
	if 0 == protocol.result and protocol.count > 0 then
		if IS_ON_CROSSSERVER or (IS_AUDIT_VERSION and not show_createrole) then
			user_vo:SetNowRole(protocol.role_list[1].role_id)
			local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
			mainrole_vo.name = protocol.role_list[1].role_name
			self.SendRoleReq()
		else
			local curr_select_role_id = LoginData.Instance:GetCurrSelectRoleId()
			for k,v in pairs(protocol.role_list) do
				if v.role_id == curr_select_role_id then
					user_vo:SetNowRole(protocol.role_list[k].role_id)
					local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
					mainrole_vo.name = protocol.role_list[k].role_name
					self.SendRoleReq()
					return
				end
			end
			self.view:OnRoleListAck(protocol)
			--self.view:OpenSelectRole()
		end

	elseif -6 == protocol.result then
		print_log("LoginCtrl:OnRoleListAck", protocol.result)
		-- 审核服自动创建角色
		if IS_AUDIT_VERSION and not show_createrole then
			LoginCtrl.SendCreateRole(self:RandomName(), math.random(1, 4), math.random(0, 1))
		else
			-- 如果角色列表为空，则核对一次服务器时间，防止部分玩家通过修改本地时间提前进新服
			-- local server_id = self.view:GetCurSelectServerId()
			-- local is_can_login, tip = LoginData.Instance:IsCanLoginServer(server_id, protocol.server_time + 10)
			-- if not is_can_login then
			-- 	TipsCtrl.Instance:OpenMessageBox(tip, function()
			-- 		GameRoot.Instance:Restart()
			-- 	end)
			-- 	return
			-- end

			self.view:OnRoleListAck(protocol)
		end
	else
		local call_back = function ()
			ViewManager.Instance:Close(ViewName.LoadingTips)
			self.view:OnDefaultReturnClick()
		end
		TipsCtrl.Instance:ShowReminding(Language.Common.Band, call_back)
		print_log("LoginCtrl:OnRoleListAck", protocol.result)
	end

	--self.data:ClearCombineData()
end

function LoginCtrl:OnMergeRoleListAck(protocol)
	-- 下发合服角色列表表示已经合服
	IS_MERGE_SERVER = true
	print_log("Login::LoginCtrl:OnMergeRoleListAck")

	self.data:SetRoleListAck(protocol)
	ReportManager:Step(Report.STEP_ROLE_LIST_MERGE_ACK)
	local user_vo = GameVoManager.Instance:GetUserVo()
	local show_createrole = LoginData.Instance:GetShowCreateRole()
	if protocol.count == 0 then
		print_log("OnMergeRoleListAck has no count")
		if IS_AUDIT_VERSION and not show_createrole then
			LoginCtrl.SendCreateRole(self:RandomName(), math.random(1, 4), math.random(0, 1))
		else
			self.view:OnRoleListAck(protocol, true)
		end
	else
		user_vo:ClearRoleList()
		for i = 1, protocol.count do
			user_vo:AddRole(
				protocol.combine_role_list[i].role_id,
				protocol.combine_role_list[i].role_name,
				protocol.combine_role_list[i].avatar,
				protocol.combine_role_list[i].sex,
				protocol.combine_role_list[i].prof,
				protocol.combine_role_list[i].country,
				protocol.combine_role_list[i].level,
				protocol.combine_role_list[i].result,
				protocol.combine_role_list[i].create_time,
				protocol.combine_role_list[i].last_login_time,
				protocol.combine_role_list[i].wuqi_id,
				protocol.combine_role_list[i].shizhuang_wuqi,
				protocol.combine_role_list[i].shizhuang_wuqi_is_special,
				protocol.combine_role_list[i].shizhuang_body,
				protocol.combine_role_list[i].shizhuang_body_is_special,
				protocol.combine_role_list[i].wing_used_imageid,
				protocol.combine_role_list[i].halo_used_imageid,
				protocol.combine_role_list[i].yaoshi_used_imageid,
				protocol.combine_role_list[i].toushi_used_imageid,
				protocol.combine_role_list[i].qilinbi_used_imageid,
				protocol.combine_role_list[i].mask_used_imageid,
				protocol.combine_role_list[i].lingzhu_used_imageid,
				protocol.combine_role_list[i].xianbao_used_imageid,
				protocol.combine_role_list[i].lingtong_used_imageid,
				protocol.combine_role_list[i].linggong_used_imageid,
				protocol.combine_role_list[i].lingqi_used_imageid,
				protocol.combine_role_list[i].weiyan_used_imageid,
				protocol.combine_role_list[i].shouhuan_used_imageid,
				protocol.combine_role_list[i].tail_used_imageid,
				protocol.combine_role_list[i].flypet_used_imageid)
		end
		if protocol.count == 1 then
			user_vo:SetNowRole(protocol.combine_role_list[1].role_id)

			local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
			mainrole_vo.name = protocol.combine_role_list[1].role_name

			self.SendRoleReq()
		else
			if IS_ON_CROSSSERVER or (IS_AUDIT_VERSION and not show_createrole) then
				user_vo:SetNowRole(protocol.combine_role_list[1].role_id)
				local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
				mainrole_vo.name = protocol.combine_role_list[1].role_name
				self.SendRoleReq()
			else
				local curr_select_role_id = LoginData.Instance:GetCurrSelectRoleId()
				for k,v in pairs(protocol.combine_role_list) do
					if v.role_id == curr_select_role_id then
						user_vo:SetNowRole(protocol.combine_role_list[k].role_id)
						local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
						mainrole_vo.name = protocol.combine_role_list[k].role_name
						self.SendRoleReq()
						return
					end
				end
				--self.view:OpenSelectRole()
				self.view:OnRoleListAck(protocol, true)
			end
		end
	end

	self.data:SetCombineData(protocol)
end

function LoginCtrl:OnProfNumInfo(protocol)
	local prof, prof_num = 1, protocol.prof1_num
	if prof_num > protocol.prof2_num then
		prof, prof_num = 2, protocol.prof2_num
	end
	if prof_num > protocol.prof3_num then
		prof, prof_num = 3, protocol.prof3_num
	end
	if prof_num > protocol.prof4_num then
		prof, prof_num = 4, protocol.prof4_num
	end

	self.view:SetLowProf(prof)
end

function LoginCtrl.SendRoleReq()
	print_log("Login::LoginCtrl.SendRoleReq")

	local user_vo = GameVoManager.Instance:GetUserVo()
	local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()

	local protocol = ProtocolPool.Instance:GetProtocol(CSRoleReq)
	protocol.rand_1 = math.floor(math.random(1000000, 10000000))
	protocol.login_time = os.time()
	protocol.key = user_vo.plat_session_key
	protocol.plat_fcm = user_vo.plat_fcm
	protocol.rand_2 = math.floor(math.random(1000000, 10000000))
	protocol.role_id = mainrole_vo.role_id
	protocol.plat_name = user_vo.plat_name
	protocol.plat_server_id = user_vo.plat_server_id

	if IS_ON_CROSSSERVER then
		ReportManager:Step(Report.STEP_SEND_ROLE_REQUEST_CROSS)
		protocol:EncodeAndSend(GameNet.Instance:GetCrossServerNet())
	else
		PlayerPrefsUtil.SetString("last_login_prof", mainrole_vo.prof)
		ReportManager:Step(Report.STEP_SEND_ROLE_REQUEST)
		protocol:EncodeAndSend(GameNet.Instance:GetLoginNet())
	end
end

function LoginCtrl.SendCreateRole(role_name, prof, sex)
	-- 根据条件限制整个渠道ID不允许注册用户
	local create_role = GLOBAL_CONFIG.param_list.switch_list.create_role
	if create_role ~= nil and create_role == false then
		SysMsgCtrl.Instance:ErrorRemind(Language.Login.LimitRegister)
		return
	end
	print_log("Login::LoginCtrl:SendCreateRole")
	ReportManager:Step(Report.STEP_SEND_CREATE_ROLE)

	local user_vo = GameVoManager.Instance:GetUserVo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCreateRoleReq)
	protocol.plat_name = user_vo.plat_name
	protocol.role_name = role_name
	protocol.login_time = os.time()
	protocol.key = user_vo.plat_session_key
	protocol.plat_server_id = user_vo.plat_server_id
	protocol.plat_fcm = user_vo.plat_fcm
	protocol.avatar = 1
	protocol.sex = ROLE_PROF_SEX[prof]
	protocol.prof = prof
	protocol.plat_spid = tostring(GLOBAL_CONFIG.package_info.config.agent_id)
	protocol:EncodeAndSend(GameNet.Instance:GetLoginNet())
end

function LoginCtrl:OnCreateRoleAck(protocol)
	if 0 == protocol.result then
		-- 提前打开加载页（为了进游戏时的体验）
		Scene.Instance:OpenSceneLoading()

		print_log("LoginCtrl:OnCreateRoleAck", protocol.result)
		ReportManager:Step(Report.STEP_CREATE_ROLE_ACK)
		local user_vo = GameVoManager.Instance:GetUserVo()
		user_vo:ClearRoleList()
		user_vo:AddRole(
			protocol.role_id,
			protocol.role_name,
			protocol.avatar,
			protocol.sex,
			protocol.prof,
			0,
			protocol.level,
			protocol.create_time)

		user_vo:SetNowRole(protocol.role_id)
		LoginData.Instance:SetCurrSelectRoleId(protocol.role_id)

		local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
		mainrole_vo.name = protocol.role_name

		self.SendRoleReq()

		GlobalEventSystem:Fire(LoginEventType.CREATE_ROLE)

		-- 神起上报
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		ReportManager:ReportUrlToSQ(main_role_vo.server_id, protocol.role_name, protocol.role_id, protocol.level, protocol.create_time, "createRole")
	else
		print_log("LoginCtrl:OnCreateRoleAck2", protocol.result)
		ReportManager:Step(Report.STEP_CREATE_ROLE_ACK_FAILED)
		if protocol.result == -1 then
			TipsCtrl.Instance:ShowSystemMsg("拥有角色已满")
		elseif protocol.result == -2 then
			if IS_AUDIT_VERSION and not show_createrole then
				LoginCtrl.SendCreateRole(self:RandomName(), math.random(1, 4), math.random(0, 1))
			else
				TipsCtrl.Instance:ShowSystemMsg("该昵称已存在, 请修改昵称")
			end
		elseif protocol.result == -3 then
			TipsCtrl.Instance:ShowSystemMsg("名字含有非法字符")
		else
			TipsCtrl.Instance:ShowSystemMsg("本区人数已满，请更换其他区服")
		end
	end
end

function LoginCtrl.SendLoginServerHeartBeat()
	local protocol = ProtocolPool.Instance:GetProtocol(CSLHeartBeat)
	if IS_ON_CROSSSERVER then
		protocol:EncodeAndSend(GameNet.Instance:GetCrossServerNet())
	else
		protocol:EncodeAndSend(GameNet.Instance:GetLoginNet())
	end

end

function LoginCtrl:RandomName()
	local name_cfg = ConfigManager.Instance:GetAutoConfig("randname_auto").random_name[1]
	local first_list = {}
	local last_list = {}
	local the_list_1 = {}
	local the_list_2 = {}
	if math.random(0, 1) == GameEnum.FEMALE then
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
	return name
end

-- 登录服心跳返回
function LoginCtrl:OnLHeartBeat()
end

function LoginCtrl:OnUserEnterGSAck(protocol)
	local result_str = tostring(protocol.result)
	if 0 == protocol.result then
		result_str = result_str .. " 成功"
	elseif -1 == protocol.result then
		result_str = result_str .. " 角色已存在"
	elseif -2 == protocol.result then
		result_str = result_str .. " 没找到场景"
	end
	print_log("Login::LoginCtrl:OnUserEnterGSAck result:" .. tostring(protocol.result) .. ",result_str:" .. result_str)

	if 0 == protocol.result then
		ReportManager:Step(Report.STEP_ENTER_GS_ACK)
		-- -- 清空资源
		-- self.view:ClearScenes()
		-- 关闭网络提示
		-- GlobalTimerQuest:CancelQuest(self.show_disconnect_tips_timer)
		TipsCtrl.Instance:CloseDisconnected()
		ViewManager.Instance:Close(ViewName.LoadingTips)
		-- 发送进度游戏成功事件
		GlobalEventSystem:Fire(LoginEventType.ENTER_GAME_SERVER_SUCC)
	elseif -1 == protocol.result then
		ReportManager:Step(Report.STEP_ENTER_GS_ACK_FAILED)
		self.enter_gs_count = self.enter_gs_count or 0 + 1
		if self.enter_gs_count >= 5 then
			self.enter_gs_count = 0
		else
			self.enter_gs_timer = GlobalTimerQuest:AddDelayTimer(
				function() self.SendUserEnterGSReq() end, 0.1)
		end
	else
		ReportManager:Step(Report.STEP_ENTER_GS_ACK_FAILED)
		self.enter_gs_count = 0
		print_log("LoginCtrl:OnUserEnterGSAck", protocol.result)
	end
end

function LoginCtrl.SendUserEnterGSReq()
	ReportManager:Step(Report.STEP_SEND_ENTER_GS)
	local user_vo = GameVoManager.Instance:GetUserVo()
	local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()

	local protocol = ProtocolPool.Instance:GetProtocol(CSUserEnterGSReq)
	protocol.scene_id = user_vo.scene_id
	protocol.scene_key = 0
	protocol.last_scene_id = user_vo.last_scene_id
	protocol.role_id = mainrole_vo.role_id
	protocol.role_name = mainrole_vo.role_name
	protocol.time = user_vo.login_time
	protocol.is_login = 1
	protocol.server_id = mainrole_vo.server_id
	protocol.key = user_vo.session_key
	protocol.plat_name = user_vo.plat_name
	protocol.is_micro_pc = 0
	protocol.plat_spid = tostring(GLOBAL_CONFIG.package_info.config.agent_id)
	protocol:EncodeAndSend(GameNet.Instance:GetGameServerNet())

	print_log("Login::LoginCtrl.SendUserEnterGSReq name=" .. mainrole_vo.role_name.."server_id="..mainrole_vo.server_id)
end

function LoginCtrl:ExitReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSDisconnectReq)
	protocol:EncodeAndSend(GameNet.Instance:GetGameServerNet())
end

-- 断开当前服务器
function LoginCtrl.SendUserLogout()
	local protocol = ProtocolPool.Instance:GetProtocol(CSUserLogout)
	protocol:EncodeAndSend()
end

-- 断开当前服务器
function LoginCtrl:OnDisconnectNotice(protocol)
	-- 玩家在别处登录
	if protocol.reason == DISCONNECT_NOTICE_TYPE.LOGIN_OTHER_PLACE then
		GlobalEventSystem:Fire(LoginEventType.GAME_SERVER_DISCONNECTED, GameNet.DISCONNECT_REASON_MULTI_LOGIN, DISCONNECT_NOTICE_TYPE.LOGIN_OTHER_PLACE)
	else
		GlobalEventSystem:Fire(LoginEventType.GAME_SERVER_DISCONNECTED, GameNet.DISCONNECT_REASON_NORMAL)
	end
end

-- 在加载页面出来后,再清空资源
function LoginCtrl:ClearScenes()
	if self.view then
		self.view:ClearScenes()
	end
end

function LoginCtrl:OnLoginOut()
	if self.view:IsOpen() then
		self.view:BackLoginView()
	end
end

function LoginCtrl:PreLoadDependBundles(call_back)
	if IS_AUDIT_VERSION then
		if call_back then
			call_back(1)
		end
		return
	end
	self.depend = require("init/preload_depend_bundles")
	self.depend:Start(call_back)
end

function LoginCtrl:DestoryDependBundles()
	if self.depend then
		self.depend:Destory()
	end
end

function LoginCtrl:ModulesComplete()
	self.is_load_complete = true
	self:CheckTrulyComplete()
end

function LoginCtrl:StartGame()
	self.is_click_start_game = true
	self:CheckTrulyComplete()
end

function LoginCtrl:CheckTrulyComplete()
	if self.is_load_complete and self.is_click_start_game then
		GameNet.Instance:AsyncConnectLoginServer(5)
	end
end

function LoginCtrl:SetLoginButtonIsActive(enable)
	if self.view then
		self.view:SetLoginButtonActive(enable)
	end
end