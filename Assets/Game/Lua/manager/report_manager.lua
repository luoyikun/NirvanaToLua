-- 上报管理器
ReportManager = {
	agent_id = GLOBAL_CONFIG.package_info.config.agent_id,
	device_id = DeviceTool.GetDeviceID(),
	pkg_ver = GLOBAL_CONFIG.package_info.version,
	assets_ver = GLOBAL_CONFIG.assets_info.version,
}

-- 上报枚举
Report = {
	STEP_GAME_BEGIN								= 10000, -- 游戏开始，获取第一条PHP
	STEP_UPGRADE								= 10010, -- 游戏需要更新包
	STEP_REQUEST_REMOTE_LUA_MANIFEST 			= 10020, -- 开始请求lua RemoteManifest
	STEP_REQUEST_REMOTE_LUA_MANIFEST_FAILED		= 10021, -- 请求lua RemoteManifest失败
	STEP_LUA_MANIFEST_UNZIP						= 10022, -- 解压Lua Manifest
	STEP_REQUEST_REMOTE_MANIFEST				= 10025, -- 开始请求RemoteManifest
	STEP_REQUEST_REMOTE_MANIFEST_FAILED			= 10026, -- 请求RemoteManifest失败
	STEP_MANIFEST_UNZIP							= 10027, -- 解压Manifest
	STEP_REQUEST_LOAD_STRONG_CFG				= 10030, -- 请求强更列表
	STEP_REQUEST_LOAD_STRONG_CFG_FAIL			= 10031, -- 请求强更列表失败
	STEP_REQUEST_LOAD_FILE_INFO					= 10032, -- 开始请求file_info
	STEP_REQUEST_LOAD_FILE_INFO_FAILED			= 10033, -- 下载file_info失败
	STEP_UPDATE_ASSET_BUNDLE					= 10040, -- 开始更新AssetBundle
	STEP_UPDATE_ASSET_BUNDLE_COMPLETE			= 10050, -- 更新AssetBundle完成
	STEP_REQUIRE_START							= 10060, -- 开始require列表
	STEP_REQUIRE_END							= 10070, -- require完成
	STEP_SHOW_LOGIN								= 10080, -- 显示登陆界面
	STEP_LOGIN_COMPLETE							= 10090, -- 登陆完成
	STEP_CLICK_START_GAME						= 10100, -- 点击开始游戏
	STEP_CONNECT_LOGIN_SERVER					= 10110, -- 开始连接登陆服务器
	STEP_LOGIN_SERVER_CONNECTED					= 10120, -- 登陆服连接上了
	STEP_LOGIN_SERVER_CONNECTED_FAILED			= 10130, -- 登陆服连接失败
	STEP_ROLE_LIST_MERGE_ACK					= 10140, -- 合并角色列表(合服之后)
	STEP_SEND_CREATE_ROLE						= 10150, -- 发送创建角色请求
	STEP_CREATE_ROLE_ACK						= 10160, -- 创建角色成功
	STEP_CREATE_ROLE_ACK_FAILED					= 10170, -- 创建角色失败
	STEP_ROLE_LIST_ACK							= 10180, -- 获得角色列表
	STEP_SEND_ROLE_REQUEST						= 10190, -- 请求登陆角色
	STEP_SEND_ROLE_REQUEST_CROSS				= 10200, -- 请求跨服登陆角色
	STEP_ON_LOGIN_ACK							= 10210, -- 收到登陆回复
	STEP_ON_LOGIN_ACK_FAILED					= 10220, -- 登陆回复失败
	STEP_CONNECT_GAME_SERVER					= 10230, -- 游戏服连接上了
	STEP_CONNECT_GAME_SERVER_FAILED				= 10240, -- 游戏服连接失败
	STEP_SEND_ENTER_GS							= 10250, -- 请求进入游戏服
	STEP_ENTER_GS_ACK							= 10260, -- 进入场景
	STEP_ENTER_GS_ACK_FAILED					= 10270, -- 进入场景失败
	STEP_CHANGE_SCENE_BEGIN						= 10280, -- 开始切换场景
	STEP_UPDATE_SCENE_BEGIN						= 10290, -- 更新场景开始
	STEP_UPDATE_SCENE_COMPLETE					= 10300, -- 更新场景完成
	STEP_CHANGE_SCENE_COMPLETE					= 10310, -- 切换场景完成
	STEP_CONNECT_PHP_SERVER_FAILED				= 10320, -- php请求失败
	STEP_JSON_DECODE_FAILED						= 10330, -- cjson解析失败

	STEP_DISCONNECT_LOGIN_SERVER				= 11010, -- 登陆服断线
	STEP_DISCONNECT_GAME_SERVER					= 11020, -- 游戏服断线
	STEP_DISCONNECT_SHOW						= 11030, -- 显示断线提示
	STEP_DISCONNECT_RETRY						= 11040, -- 提示后重试连接
	STEP_DISCONNECT_BACK						= 11050, -- 断线后返回登陆

	CHAT_PRIVATE                        		= 20100, -- 私聊记录
}

-- 上报日志.
function ReportManager:Step(step, ...)
    if not OPEN_REPORT then
        return
    end
	if GameVoManager ~= nil and GameVoManager.Instance ~= nil then
		local user_id = nil
		local server_id = nil
		local role_id = nil
		local role_name = nil

		local user_vo = GameVoManager.Instance:GetUserVo()
		if user_vo ~= nil then
			if user_vo.plat_name ~= nil and user_vo.plat_name ~= "" then
				user_id = user_vo.plat_name
			end

			if user_vo.plat_server_id ~= nil and user_vo.plat_server_id ~= "" then
				server_id = user_vo.plat_server_id
			end
		end

		local main_role_vo =  GameVoManager.Instance:GetMainRoleVo()
		if main_role_vo ~= nil then
			if main_role_vo.role_id ~= nil and main_role_vo.role_id ~= "" then
				role_id = main_role_vo.role_id
			end

			if main_role_vo.role_id ~= nil and main_role_vo.role_id ~= "" then
				role_name = main_role_vo.name
			end
		end

		if user_id ~= nil and server_id ~= nil and role_id ~= nil then
			ReportManager:Report(
				step,
				self.agent_id,
				self.device_id,
				self.pkg_ver,
				self.assets_ver,
				UnityEngine.Application.internetReachability,
				os.time(),
				user_id,
				server_id,
				role_id,
				role_name,
				...)
		elseif user_id ~= nil and server_id ~= nil then
			ReportManager:Report(
				step,
				self.agent_id,
				self.device_id,
				self.pkg_ver,
				self.assets_ver,
				UnityEngine.Application.internetReachability,
				os.time(),
				user_id,
				server_id,
				...)
		elseif user_id ~= nil then
			ReportManager:Report(
				step,
				self.agent_id,
				self.device_id,
				self.pkg_ver,
				self.assets_ver,
				UnityEngine.Application.internetReachability,
				os.time(),
				user_id,
				...)
		else
			ReportManager:Report(
				step,
				self.agent_id,
				self.device_id,
				self.pkg_ver,
				self.assets_ver,
				UnityEngine.Application.internetReachability,
				os.time(),
				...)
		end
	else
		ReportManager:Report(
			step,
			self.agent_id,
			self.device_id,
			self.pkg_ver,
			self.assets_ver,
			UnityEngine.Application.internetReachability,
			os.time(),
			...)
	end
end

function ReportManager:Report(...)
    if not OPEN_REPORT then
        return
    end
	-- 审核状态不上报
	if IS_AUDIT_VERSION then
		return
	end
	local url = GLOBAL_CONFIG.param_list.report_url
	if url == nil or url == "" then
		url = "http://117.120.62.67:9981/report.php"
	end
	
	local args = nil
	for i = 1, select("#", ...) do
		if args == nil then
			args = tostring(select(i, ...))
		else
			args = args .. "\t" .. tostring(select(i, ...))
		end
	end

	print_log("args: ", args)
	local request = string.format(
		"%s?data=%s", url, tostring(mime.b64(args)))
	UtilU3d.RequestGet(request)
	--print_log("request: ", request)
end

-- 上报事件
function ReportManager:ReportLoginEvent()
    if not OPEN_REPORT then
        return
    end
	local event_url = GLOBAL_CONFIG.param_list.event_url
	if event_url == nil or event_url == "" then
		event_url = GlobalUrl .. "/api/qzw/report_event.php"
	end

	local user_vo = GameVoManager.Instance:GetUserVo()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()

	-- event_url = event_url .. "?type=%s&spid=%s&user_id=%s&role_id=%s&server_id=%s&time=%s"
	-- event_url = string.format(event_url,
	-- 	1,
	-- 	GLOBAL_CONFIG.package_info.config.agent_id,
	-- 	user_vo.plat_name,
	-- 	main_role_vo.role_id,
	-- 	user_vo.plat_server_id,
	-- 	os.time())

	local type_s = 1
	local agent_id = GLOBAL_CONFIG.package_info.config.agent_id
	local plat_name = user_vo.plat_name
	local role_id = main_role_vo.role_id
	local plat_server_id = user_vo.plat_server_id
	local time = os.time()

	local url = ""
	if string.find(event_url, "?") then
		url = event_url
		url = string.gsub(url, "{{type}}", type_s)
		url = string.gsub(url, "{{spid}}", agent_id)
		url = string.gsub(url, "{{user_id}}", plat_name)
		url = string.gsub(url, "{{role_id}}", role_id)
		url = string.gsub(url, "{{server_id}}", plat_server_id)
		url = string.gsub(url, "{{time}}", time)
	else
		url = string.format("%s?type=%s&spid=%s&user_id=%s&role_id=%s&server_id=%s&time=%s",
			event_url,
			type_s,
			agent_id,
			plat_name,
			role_id,
			plat_server_id,
			time)
	end

	UtilU3d.RequestGet(url)
end

function ReportManager:ReportPay(money)
    if not OPEN_REPORT then
        return
    end
	local url = GLOBAL_CONFIG.param_list.pay_event_url
	if url == nil or url == "" then
		--url = "http://117.120.62.67:9981/api/qzw/report_event.php"
		url = "http://117.120.62.67:9981/api/pay/"
	end
	--?account=%s&playername=%s&roleid=%s&pay_game_id=%s&daili=%s&serverid=%s&pdcid=%s&amount=%s
	--url = url .. "?type=%s&spid=%s&user_id=%s&role_id=%s&server_id=%s&data=%s&time=%s"
	url = url .. "?account=%s&playername=%s&roleid=%s&pay_game_id=%s&daili=%s&serverid=%s&pdcid=%s&amount=%s&time=%s"
	local user_vo = GameVoManager.Instance:GetUserVo()
	local main_role_vo =  GameVoManager.Instance:GetMainRoleVo()
	local pay_game_id = "game3d003"
	local account_name = user_vo.plat_name
	local pay_daili_id = string.sub(account_name, 5, 9)
	url = string.format(url,
		user_vo.plat_name,
		user_vo.plat_name,
		main_role_vo.role_id,
		pay_game_id,
		pay_daili_id,
		user_vo.plat_server_id,
		'gold',
		money,
		os.time())
	UtilU3d.RequestGet(url)
	--print_log("request pay: ", url)
end

-- 上报神起 创建角色数据
function ReportManager:ReportUrlToSQ(server_id, role_name, role_id, role_level, create_time, rep_type)
    if not OPEN_REPORT then
        return
    end
	local user_vo = GameVoManager.Instance:GetUserVo()
	local main_role_vo =  GameVoManager.Instance:GetMainRoleVo()

	local url_ip = "http://117.120.62.67:9981/UserCharacter/SaveUserCharacter"
	local CPSeriesId = "ug03"
	local key = "c5a88ed5a06ce1ea55cd4e04f333207f1"
	local CPId = 1
	local agent_id = GLOBAL_CONFIG.package_info.config.agent_id
	local user_id = user_vo.plat_name
	local is_shenqi = GLOBAL_CONFIG.param_list.switch_list.is_shenqi

	if is_shenqi then
		-- print_error(">>>>>玩家数据上报测试", server_id, role_name, role_id, role_level, create_time, rep_type)
		local Sign = ""
		local signData = user_id .. server_id .. role_id .. role_level .. rep_type .. CPId .. key
		if MD52 ~= nil then
			Sign = string.upper(MD52.GetMD5(signData))
		else
			Sign = string.upper(MD5.GetMD5FromString(signData)) 
		end

		local url = string.format("%s?user_id=%s&server_id=%s&role_name=%s&role_id=%s&role_level=%s&create_time=%s&type=%s&CPId=%s&CPSeriesId=%s&Sign=%s",
			url_ip, user_id, server_id, HttpClient:UrlEncode(role_name), role_id, role_level, create_time, rep_type, CPId, CPSeriesId, Sign)
		HttpClient:Request(url, nil)
	end
end

function ReportManager:ReportChatMsgToSQ(server_id, role_name, role_id, role_level, role_glod, chat_type, chat_msg, chat_role)
    if not OPEN_REPORT then
        return
    end
	local user_vo = GameVoManager.Instance:GetUserVo()

	local url_ip = "http://117.120.62.67:9981/Chat/CreateChatInfo"
	local key = "c5a88ed5a06ce1ea55cd4e04f333207f1"
	local CPSeriesId = "ug03"
	local CPId = 1
	local agent_id = GLOBAL_CONFIG.package_info.config.agent_id
	local is_shenqi = GLOBAL_CONFIG.param_list.switch_list.is_shenqi
	local user_id = user_vo.plat_name
	local chat_time = os.time()
	local ip_addr = ReportManager:GetIpAddress()
	local device_id = DeviceTool.GetDeviceID()

	if is_shenqi then
		-- print_error(">>>>>聊天上报测试", server_id, role_name, role_id, role_level, role_glod, chat_type, chat_msg, chat_role)
		local mySign = ""
		local signData = server_id .. user_id .. role_level .. chat_type .. key
		if MD52 ~= nil then
			mySign = string.upper(MD52.GetMD5(signData))
		else
			mySign = string.upper(MD5.GetMD5FromString(signData)) 
		end

		local url = string.format("%s?ip_addr=%s&device_id=%s&user_id=%s&server_id=%s&role_name=%s&role_id=%s&role_level=%s&role_glod=%s&chat_type=%s&chat_msg=%s&chat_role=%s&chat_time=%s&CPId=%s&CPSeriesId=%s&Sign=%s",
			url_ip, ip_addr, device_id, user_id, server_id, HttpClient:UrlEncode(role_name), role_id, role_level, role_glod, chat_type, HttpClient:UrlEncode(chat_msg), chat_role, chat_time, CPId, CPSeriesId, mySign)
		-- print("requrl ", url)
		HttpClient:Request(url, nil)
	end
end

--获得当前ip地址
function ReportManager.GetIpAddress()
	-- return PlatformBinder:JsonCall("call_get_ip_address") 
	if nil ~= GLOBAL_CONFIG.param_list and nil ~= GLOBAL_CONFIG.param_list.client_ip then
		return GLOBAL_CONFIG.param_list.client_ip
	end

	return "0.0.0.0"
end

function ReportManager:ReportChatMsgToAgent(server_id, role_name, role_id, role_level, role_glod, chat_type, chat_msg, chat_role)
	if not OPEN_REPORT then
        return
    end
    local agent_id = GLOBAL_CONFIG.package_info.config.agent_id or ""
	-- local agent_id = "asy"
	local need_report_agent = {
		["asy"] = 1,
		["lsy"] = 1,
		["wsy"] = 1,
		["acs"] = 1,
		["lcs"] = 1,
	}

	if nil ~= need_report_agent[agent_id] then
		local platform = UnityEngine.Application.platform
		local url_ip = "http://117.120.62.67:9981/mobilechat.php"
		local key = "8bd21cd84ea7eecfd40db6a2b3a59b411"
		local genre = 1
		local game = 123

		-- if platform == UnityEngine.RuntimePlatform.Android or platform == UnityEngine.RuntimePlatform.WindowsPlayer then
		-- 	self.platform = PHONE_TYPE.ANDROID
		-- else
		if platform == UnityEngine.RuntimePlatform.IPhonePlayer then
			game = 124
			key = "6667f4a19a3c8e10aa3b94af9e53ac01"
		end

		if agent_id == "acs" then
			game = 136
			key = "25e14172f0a66e26857b66a1b4c0120f"
		end

		if agent_id == "lcs" then
			game = 137
			key = "52d9cfa48105e85c85ec0131efd09501"
		end

		local uid = AgentAdapter ~= nil and tostring(AgentAdapter.Instance:GetUserInfo().UserID) or 0
		local mid = chat_role
		if nil == chat_role or chat_role == "" then
			mid = 0
		end
		local time = os.time()
		local chat = os.time()
		local uame = HttpClient:UrlEncode(role_name)

		local private_obj = ChatData.Instance:GetPrivateObjByRoleId(mid)
		local mame = ""
		if private_obj and private_obj.username then
			mame = HttpClient:UrlEncode(private_obj.username)
		end

		local server = server_id
		local type = Language.Channel[chat_type] or "世界"
		local body = HttpClient:UrlEncode(chat_msg)
		local sign = MD52.GetMD5(game .. uid .. time .. key)
		local url = string.format("%s?genre=%s&game=%s&uid=%s&mid=%s&time=%s&chat=%s&uame=%s&mame=%s&server=%s&type=%s&body=%s&sign=%s",
			url_ip, genre, game, uid, mid, time, chat, uame, mame, server, HttpClient:UrlEncode(type), body, sign)
		local function test_callback (url, is_succ, data)
		end
		HttpClient:Request(url, test_callback)
	end
end

-- msg聊天信息参数(按顺序字段值以\t分割):
-- plat_id          渠道id
-- device_id        设备id
-- user_id          用户uid(平台帐号)
-- server_id        区服id
-- role_id          角色id
-- role_name        角色名
-- role_level       角色等级
-- role_gold        角色元宝
-- chat_type        聊天类型
-- chat_msg         聊天信息
-- chat_role        私聊对象（角色id）
-- role_vip         角色VIP
-- chat_role_name   私聊对象（角色名）
-- chat_role_level  私聊对象（角色等级）
-- 渠道聊天推送
function ReportManager:ReportChatPush(server_id, role_id, role_name, role_level, role_gold, chat_type, chat_msg, chat_role, chat_role_name, chat_role_level)
	if not OPEN_REPORT then
        return
    end
    local chat_url = GLOBAL_CONFIG.param_list.chat_report_url
	if nil == chat_url or chat_url == "" then
		return
	end
	local plat_id = ChannelAgent.GetChannelID()
	local device_id = self.device_id
	local user_id = ""
	local user_vo = GameVoManager.Instance:GetUserVo()
	if user_vo then
		user_id = user_vo.plat_name or ""
	end
	chat_role = chat_role or 0

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local role_vip = main_role_vo.vip_level or 0
	chat_role_name = chat_role_name or ""
	chat_role_level = chat_role_level or 0

	local data = string.format("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s",
		plat_id, device_id, user_id, server_id, role_id, role_name, role_level, role_gold, 
		chat_type, chat_msg, chat_role, role_vip, chat_role_name, chat_role_level)

	local base64_data = mime.b64(data)

	local url = string.format("%s?game=ug03&data=%s", chat_url, base64_data)

	local call_back = function (url, is_succ, data)
	end
	HttpClient:Request(url, call_back)
end