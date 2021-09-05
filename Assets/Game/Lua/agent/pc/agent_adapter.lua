require("agent/agent_adapter_base")
require("agent/pc/agent_view")

AgentAdapter = AgentAdapter or BaseClass(AgentAdapter)

function AgentAdapter:__init()
	if AgentAdapter.Instance ~= nil then
		print_error("[AgentAdapter] attempt to create singleton twice!")
		return
	end
	AgentAdapter.Instance = self

	self.view = AgentView.New(ViewName.Agent)

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
end

function AgentAdapter:__delete()
	AgentAdapter.Instance = nil

	if self.view ~= nil then
		self.view:DeleteMe()
	end

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
end

function AgentAdapter:ShowLogin(callback)
	self.login_callback = callback

	self.view:SetClickLoginCallback(function(account_name, password)
		local data = string.format("{\"user\":\"%s\",\"pass\":\"%s\"}", account_name, password)
		local channel_id = GLOBAL_CONFIG.package_info.config.agent_id
		local agent_id = channel_id
		local url = string.format("%s/%s/login.php?channelId=%s&agentId=%s&data=%s",
			GlobalUrl,
			channel_id,
			channel_id,
			agent_id,
			mime.b64(data))

		print_log("[AgentAdapter.VerifyLogin]Request ", url)
		if nil ~= self.http_login_call_back  then
			HttpClient:CancelRequest(self.http_login_call_back)
			self.http_login_call_back = nil
		end
		
		self.http_login_call_back = BindTool.Bind(AgentAdapter.OnVerifyLogin, self)
		HttpClient:Request(url, self.http_login_call_back)
	end)

	ViewManager.Instance:Open(ViewName.Agent)
end

function AgentAdapter:Logout()
	local user_info = self:GetUserInfo()
	print_log("ChannelAgent.Logout: ", user_info)
	ChannelAgent.Logout(user_info)
end

function AgentAdapter:Pay(product_id, amount, callback)
	local user_info = self:GetUserInfo()
	user_info.ProductName = "元宝"					--商品名称
	user_info.ProductDesc = amount * 10 .. "元宝"	--商品描述
	user_info.Ratio = "10"  						--兑换比例

	local user_vo = GameVoManager.Instance:GetUserVo()

	local data = string.format(
		"{\"ZoneID\":\"%s\",\"RoleID\":\"%s\",\"UserID\":\"%s\",\"ProductDesc\":\"%s\",\"amount\":\"%s\",\"ext\":\"%s\"}",
		user_info.ZoneID,
		user_info.RoleID,
		user_info.UserID,
		user_info.ProductDesc,
		amount,
		user_vo.ext)

	local channelID = GLOBAL_CONFIG.package_info.config.agent_id
	local url = string.format(
		"%s/%s/pay.php?data=%s",
		GlobalUrl,
		channelID,
		mime.b64(data))

	print_log("[WebPay]url = ", url)
	HttpClient:Request(url, function(url, is_succ, data)
		if not is_succ then
			print_error("Webpay request failed: ", url)
			return
		end

		if nil == data or  "" == data then
			print_error("[WebPay]: data: ", data)
			return
		end

		print_log("[WebPay]: open pay_url: ", data)
		WebView.Open(data)
	end)
end

function AgentAdapter:OnInit(result)
end

function AgentAdapter:OnLogin(data)
end

function AgentAdapter:OnVerifyLogin(url, is_succ, data)
	print_log("[AgentAdapter.VerifyLogin]OnRequeset ", url, is_succ, data)

	local callback = self.login_callback
	if not is_succ then
		print_error("[AgentAdapter.VerifyLogin]failed: ")
		callback(false)
		return
	end

	local login_info = cjson.decode(data)
	if login_info == nil then
		print_error("[AgentAdapter.VerifyLogin]json format failed")
		callback(false)
		return
	end

	if login_info.ret ~= nil and login_info.ret ~= 0 then
		print_error("[AgentAdapter.VerifyLogin]failed with code: ", login_info.ret)
		callback(false)

		if 100 == login_info.ret then
			TipsCtrl.Instance:OpenMessageBox(login_info.msg)
		end

		return
	end

	self.login_user = login_info.user
	local uservo = GameVoManager.Instance:GetUserVo()
	uservo.plat_name = self.login_user.account
	uservo.plat_fcm = self.login_user.fcm_flag
	uservo.login_time = self.login_user.login_time
	uservo.plat_account_type = self.login_user.account_type
	uservo.ext = self.login_user.ext

	GameRoot.Instance:SetBuglyUserID(uservo.plat_name)

	self.login_callback = nil
	callback(true)
end

function AgentAdapter:OnLogout()
	LoginCtrl.Instance:OnLoginOut()
	
	if Scene.Instance:IsEnterScene() then
		GameRoot.Instance:Restart()
	end
end

function AgentAdapter:OnExit()
	if TipsCtrl and TipsCtrl.Instance and Language then
		local yes_func = function() DeviceTool.Quit() end
		local describe = Language.Common.QuitGame
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	end
end

function AgentAdapter:GetUserInfo()
	local user_info = self.user_info

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
	user_info.UserID = tostring(self.login_user.uid)
	user_info.ProductName = "元宝"
	user_info.ProductDesc = "描述"
	user_info.Ratio = "10"

	return user_info
end

function AgentAdapter:ReportEnterZone(is_succ)
	if is_succ then
		print_log("[AgentAdapter.ReportEnterZone]is_succ, user_info ", is_succ, user_info)
		self:ReportUserInfo()
	end
end

function AgentAdapter:ReportCreateRole()
	print_log("[AgentAdapter.ReportCreateRole]user_info = ", user_info)
	self:ReportUserInfo()
end

function AgentAdapter:ReportLevelUp()
	print_log("[AgentAdapter.ReportLevelUp]user_info = ", user_info)
	self:ReportUserInfo()
end

function AgentAdapter:ReportLoginRole()
	print_log("[AgentAdapter.ReportLoginRole]user_info = ", user_info)
	self:ReportUserInfo()
end

function AgentAdapter:ReportLogoutRole()
	print_log("[AgentAdapter.ReportLogoutRole]user_info = ", user_info)
	self:ReportUserInfo()
end

function AgentAdapter:ReportUserInfo()
	local user_info = self:GetUserInfo()
	local user_vo = GameVoManager.Instance:GetUserVo()

	local data = string.format(
		"{\"ZoneID\":\"%s\",\"ZoneName\":\"%s\",\"RoleID\":\"%s\",\"RoleName\":\"%s\",\"RoleLevel\":\"%s\",\"UserID\":\"%s\",\"ext\":\"%s\"}",
		user_info.ZoneID,
		user_info.ZoneName,
		user_info.RoleID,
		user_info.RoleName,
		user_info.RoleLevel,
		user_info.UserID,
		user_vo.ext)

	local channelID = GLOBAL_CONFIG.package_info.config.agent_id
	local url = string.format("%s/%s/report.php?data=%s", GlobalUrl, channelID, mime.b64(data))

	HttpClient:Request(url, function(url, is_succ, data)
		print_log(string.format("[ReportUserInfo] url:%s is_succ:%s data:%s", url, is_succ, data))
	end)
end
