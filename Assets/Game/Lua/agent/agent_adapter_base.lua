AgentAdapterBase = AgentAdapterBase or BaseClass()

function AgentAdapterBase:__init()
	-- Create the channel user info data.
	self.user_info = ChannelUserInfo.New()

	-- Bind the channel agent.
	self.event_init = BindTool.Bind(self.OnInit, self)
	ChannelAgent.InitializedEvent = ChannelAgent.InitializedEvent + self.event_init

	self.event_login = BindTool.Bind(self.OnLogin, self)
	ChannelAgent.LoginEvent = ChannelAgent.LoginEvent + self.event_login

	self.event_logout = BindTool.Bind(self.OnLogout, self)
	ChannelAgent.LogoutEvent = ChannelAgent.LogoutEvent + self.event_logout

	self.event_exit = BindTool.Bind(self.OnExit, self)
	ChannelAgent.ExitEvent = ChannelAgent.ExitEvent + self.event_exit

	if IS_AUDIT_VERSION or IS_AUDIT_MINI_GAME then
		self.event_reserve = BindTool.Bind(self.OnReserve, self)
		ChannelAgent.ReserveEvent = ChannelAgent.ReserveEvent + self.event_reserve
	end

	-- Bind the game event for report.
	self.event_handler_list = {}
	table.insert(self.event_handler_list, GlobalEventSystem:Bind(
											LoginEventType.CREATE_ROLE,
											BindTool.Bind(self.ReportCreateRole, self)))

	table.insert(self.event_handler_list, GlobalEventSystem:Bind(
											LoginEventType.GAME_SERVER_CONNECTED,
											BindTool.Bind(self.ReportEnterZone, self)))

	table.insert(self.event_handler_list, GlobalEventSystem:Bind(
												OtherEventType.ROLE_LEVEL_UP,
												BindTool.Bind(self.ReportLevelUp, self)))

	table.insert(self.event_handler_list, GlobalEventSystem:Bind(
												LoginEventType.RECV_MAIN_ROLE_INFO,
												BindTool.Bind(self.ReportLoginRole, self)))

	table.insert(self.event_handler_list, GlobalEventSystem:Bind(
												LoginEventType.LOGOUT,
												BindTool.Bind(self.Logout, self)))

	-- Set data
	self.login_user = {}

	-- Initialize the channel.
	print_log("ChannelAgent.Initialize.")
	ChannelAgent.Initialize()

	self.agent_adapt = ConfigManager.Instance:GetAutoConfig("agent_adapt_auto").agent_adapt
end

function AgentAdapterBase:__delete()
	self.agent_adapt = nil
	
	for _, v in pairs(self.event_handler_list) do
		GlobalEventSystem:UnBind(v)
	end
	self.event_handler_list = {}

	if nil ~= self.event_init then
		ChannelAgent.InitializedEvent = ChannelAgent.InitializedEvent - self.event_init
		self.event_init = nil
	end

	if nil ~= self.event_login then
		ChannelAgent.LoginEvent = ChannelAgent.LoginEvent - self.event_login
		self.event_login = nil
	end

	if nil ~= self.event_logout then
		ChannelAgent.LogoutEvent = ChannelAgent.LogoutEvent - self.event_logout
		self.event_logout = nil
	end

	if nil ~= self.event_exit then
		ChannelAgent.ExitEvent = ChannelAgent.ExitEvent - self.event_exit
		self.event_exit = nil
	end

	if nil ~= self.event_reserve then
		ChannelAgent.ReserveEvent = ChannelAgent.ReserveEvent - self.event_reserve
		self.event_reserve = nil
	end
end

function AgentAdapterBase:ShowLogin(callback)
	self.login_callback = callback
	if nil ~= self.http_login_call_back  then
		HttpClient:CancelRequest(self.http_login_call_back)
		self.http_login_call_back = nil
	end
	local user_info = self:GetUserInfo()
	print_log("ChannelAgent.Login: ", user_info)
	ChannelAgent.Login(user_info)
end

function AgentAdapterBase:Logout()
	local user_info = self:GetUserInfo()
	print_log("ChannelAgent.Logout: ", user_info)
	ChannelAgent.Logout(user_info)
end

function AgentAdapterBase:Pay(product_id, amount, callback)
	local user_info = self:GetUserInfo()
	local order_id = self:MakeOrderID(user_info)
	
	user_info.ProductName = "元宝"					--商品名称
	user_info.ProductDesc = amount * 10 .. "元宝"	--商品描述
	user_info.Ratio = "10"  						--兑换比例

	if GLOBAL_CONFIG.param_list.switch_list.gamewp then
		local user_vo = GameVoManager.Instance:GetUserVo()
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()

		local data = string.format(
			"{\"amount\":\"%s\",\"uid\":\"%s\",\"roleid\":\"%s\",\"serverid\":\"%s\",\"cpoid\":\"%s\",\"rolename\":\"%s\",\"userdata\":\"%s\",\"ProductDesc\":\"%s\"}",
			amount,
			user_info.UserID,
			main_role_vo.role_id or 0,
			user_vo.plat_server_id or 0,
			order_id,
			user_info.RoleName,
			self.login_user.account or "",
			user_info.ProductDesc or "")
		local channelID = ChannelAgent.GetChannelID()
		local agentID = ChannelAgent.GetAgentID()
		local url = string.format(
			"%s/%s/wp_type.php?channelId=%s&agentId=%s&pkg=%s&data=%s&device=%s",
			GlobalUrl,
			channelID,
			channelID,
			agentID,
			GLOBAL_CONFIG.package_info.version,
			mime.b64(data),
			DeviceTool.GetDeviceID())

		print_log("[WebPay]url = ", url)
		HttpClient:Request(url, function(url, is_succ, data)
			if not is_succ then
				print_error("Webpay request failed: ", url)
				return
			end

			local info = cjson.decode(data)
			if info == nil then
				print_error("Webpay request format error: ", url)
				return
			end

			if info.ret ~= 0 then
				print_error("Webpay request error: ", info.msg)
				return
			end

			if info.wptype == 0 then
				print_log("[SDKPay]orderID = ", order_id,
					",product_id=", product_id,
					",amount=", amount,
					",userInfo=", user_info)
				ChannelAgent.Pay(user_info, order_id, product_id, amount)
			else
				print_log("[WebPay]: open url: ", info.data)
				WebView.Open(info.data)
			end
		end)
	else
		--ylsp 充值
		local account_name = GameVoManager.Instance:GetUserVo().plat_name
		local user_vo = GameVoManager.Instance:GetUserVo()
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local pay_role_id = main_role_vo.role_id
		local pay_server_id = user_vo.plat_server_id
		local pay_daili_id = string.sub(account_name, 1, 5)
		local pay_role_name = user_info.RoleName
		local pay_game_id = "game3d003"
		print_log("[SDKPay]orderID1 = ", order_id,
			",product_id=", product_id,
			",pay_role_id=", pay_role_id,
			",pay_server_id=", pay_server_id,
			",amount=", amount,
			",accountname=", account_name,
			",userInfo=", user_info)
		--ChannelAgent.Pay(user_info, order_id, product_id, amount)
		local channelID = ChannelAgent.GetChannelID()
		local agentID = ChannelAgent.GetAgentID()
		local url = string.format(
			"http://117.120.62.67:9981/api/pay/?account=%s&playername=%s&roleid=%s&pay_game_id=%s&daili=%s&serverid=%s&pdcid=%s&amount=%s",
			account_name,
			account_name,
			pay_role_id,
			pay_game_id,
			pay_daili_id,
			pay_server_id,
			'gold',
			amount)
		print_log("[WebPay]: open url: ", url)
		WebView.Open(url)
	end
end

function AgentAdapterBase:MakeOrderID(user_info)
	-- order_id = 服id|渠道id|agent_id|uid|roleID|时间戳
	return string.format("%s|%s|%s|%s|%s|%s",
		user_info.ZoneID,
		ChannelAgent.GetChannelID(),
		ChannelAgent.GetAgentID(),
		user_info.UserID or "0",
		user_info.RoleID,
		os.time())
end

function AgentAdapterBase:OnInit(result)
end

function AgentAdapterBase:OnLogin(data)
	-- Verify Login.
	local login_verify = GLOBAL_CONFIG.param_list.verify_url
	local channel_id = ChannelAgent.GetChannelID()
	local agent_id = ChannelAgent.GetAgentID()

	local url = ""
	if string.find(login_verify, "?") then
		local b64_data = mime.b64(data)
		local device = DeviceTool.GetDeviceID()
		url = login_verify
		url = string.gsub(url, "{{channelId}}", channel_id)
		url = string.gsub(url, "{{agentId}}", agent_id)
		url = string.gsub(url, "{{data}}", b64_data)
		url = string.gsub(url, "{{device}}", device)
	else
		url = string.format("%s?channelId=%s&agentId=%s&data=%s&device=%s",
			login_verify,
			channel_id,
			agent_id,
			mime.b64(data),
			DeviceTool.GetDeviceID())
	end

	-- local url = string.format("%s?channelId=%s&agentId=%s&data=%s&device=%s",
	-- 	login_verify,
	-- 	channel_id,
	-- 	agent_id,
	-- 	mime.b64(data),
	-- 	DeviceTool.GetDeviceID())

	print_log("[AgentAdapter.VerifyLogin]Request ", url)
	if nil ~= self.http_login_call_back  then
		HttpClient:CancelRequest(self.http_login_call_back)
		self.http_login_call_back = nil
	end
	self.http_login_call_back = BindTool.Bind(AgentAdapter.OnVerifyLogin, self)
	HttpClient:Request(url, self.http_login_call_back)
end

function AgentAdapterBase:OnVerifyLogin(url, is_succ, data)
	print_log("[AgentAdapter.VerifyLogin]OnRequeset ", url, is_succ, data)

	local callback = self.login_callback
	if not is_succ then
		print_error("[AgentAdapter.VerifyLogin]failed: ")
		if callback then
			callback(false)
		end
		return
	end

	local login_info = cjson.decode(data)
	if login_info == nil then
		print_error("[AgentAdapter.VerifyLogin]json format failed")
		if callback then
			callback(false)
		end
		return
	end

	-- 获取加密方式
	if login_info.t then
		local encryption = Split(login_info.t, ",")
		local langth = #encryption
		if langth == 2 then
			if encryption[1] == "1" then
				local data_length = encryption[2]
				local login_info_data = Base64Decode(login_info.data, data_length)
				login_info = cjson.decode(login_info_data)
			end
		end
	end

	if login_info.ret ~= nil and login_info.ret ~= 0 then
		print_error("[AgentAdapter.VerifyLogin]failed with code: ", login_info.ret)
		if callback then
			callback(false)
		end
		return
	end

	self.login_user = login_info.user
	PlayerPrefsUtil.SetString("login_user", self.login_user.uid)
	local uservo = GameVoManager.Instance:GetUserVo()
	uservo.plat_name = self.login_user.account
	uservo.plat_fcm = self.login_user.fcm_flag
	uservo.login_time = self.login_user.login_time
	uservo.plat_account_type = self.login_user.account_type
	LoginData.Instance:SetIsAutoLogin(self.login_user.auto_login)
	LoginData.Instance:SetShowCreateRole(self.login_user.show_createrole)
	if self.login_user.channelId and self.login_user.channelId ~= "" then
		GLOBAL_CONFIG.package_info.config.agent_id = self.login_user.channelId
	end

	GameRoot.Instance:SetBuglyUserID(uservo.plat_name)

	-- self.login_callback = nil
	if callback then
		callback(true)
	end
end

function AgentAdapterBase:OnLogout()
	LoginCtrl.Instance:OnLoginOut()
	
	if Scene.Instance:IsEnterScene() then
		GameRoot.Instance:Restart()
	end
end

function AgentAdapterBase:OnExit()
	if TipsCtrl and TipsCtrl.Instance and Language then
		local yes_func = function() DeviceTool.Quit() end
		local describe = Language.Common.QuitGame
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	end
end

function AgentAdapterBase:OnReserve(data)
	print_warning(">>>>>>>>>>>>>>>>>>>OnReserve", data)
	local reserve_info = cjson.decode(data)
	if reserve_info == nil then
		return
	end

	if reserve_info.types == "pay_callback" then
		GlobalEventSystem:Fire(AuditEvent.RECHARGE_CHANGE, reserve_info)
	end
end

function AgentAdapterBase:GetUserInfo()
	local user_info = self.user_info

	local user_id = ""
	if nil == self.login_user or nil == self.login_user.uid or "" == tostring(self.login_user.uid) then
		user_id = PlayerPrefsUtil.GetString("login_user")
	else
		user_id = tostring(self.login_user.uid)
	end

	local user_vo = GameVoManager.Instance:GetUserVo()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()

	user_info.ZoneID = user_vo.plat_server_id or 0
	user_info.ZoneName = user_vo.plat_server_name or ""
	user_info.RoleID = main_role_vo.role_id or 0
	user_info.RoleName = main_role_vo.role_name or ""
	user_info.RoleLevel = main_role_vo.level or 0
	user_info.Currency = main_role_vo.coin or 0
	user_info.Diamond = main_role_vo.gold or 0
	user_info.VIP = main_role_vo.vip_level or 0
	user_info.GuildName = main_role_vo.guild_name or ""
	user_info.CreateTime = main_role_vo.create_time or 0
	user_info.UserID = user_id
	user_info.ProductName = "元宝"
	user_info.ProductDesc = "描述"
	user_info.Ratio = "10"

	return user_info
end

function AgentAdapterBase:ReportEnterZone(is_succ)
	if is_succ and not IS_ON_CROSSSERVER then
		local user_info = self:GetUserInfo()
		print_log("[AgentAdapter.ReportEnterZone]is_succ, user_info ", is_succ, user_info)
		ChannelAgent.ReportEnterZone(user_info)
	end
end

function AgentAdapterBase:ReportCreateRole()
	local user_info = self:GetUserInfo()
	print_log("[AgentAdapter.ReportCreateRole]user_info = ", user_info)
	ChannelAgent.ReportCreateRole(user_info)
end

function AgentAdapterBase:ReportLevelUp()
	if not IS_ON_CROSSSERVER then
		local user_info = self:GetUserInfo()
		print_log("[AgentAdapter.ReportLevelUp]user_info = ", user_info)
		ChannelAgent.ReportLevelUp(user_info)
	end
end

function AgentAdapterBase:ReportLoginRole()
	if not IS_ON_CROSSSERVER then
		local user_info = self:GetUserInfo()
		print_log("[AgentAdapter.ReportLoginRole]user_info = ", user_info)
		ChannelAgent.ReportLoginRole(user_info)
	end
end

function AgentAdapterBase:ReportLogoutRole()
	local user_info = self:GetUserInfo()
	print_log("[AgentAdapter.ReportLogoutRole]user_info = ", user_info)
	ChannelAgent.ReportLogoutRole(user_info)
end

function AgentAdapterBase:Reserve(reserve_content)
	if ChannelAgent.Reserve then
		ChannelAgent.Reserve(reserve_content)
	end
end

function AgentAdapterBase:GetAgentAdaptCfg()
	local agent_id = ChannelAgent.GetChannelID()
	if self.agent_adapt and self.agent_adapt[agent_id] then
		return self.agent_adapt[agent_id]
	end
end
