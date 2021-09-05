require("game/cross_server/cross_server_data")

IS_ON_CROSSSERVER = false     				-- 是否在跨服中

CrossServerCtrl = CrossServerCtrl or BaseClass(BaseController)
function CrossServerCtrl:__init()
	if CrossServerCtrl.Instance then
		error("[CrossServerCtrl]:Attempt to create singleton twice!")
	end
	CrossServerCtrl.Instance = self

	self.data = CrossServerData.New()
	self:RegisterAllProtocals()
end

function CrossServerCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil

	CrossServerCtrl.Instance = nil
end

function CrossServerCtrl:RegisterAllProtocals()
	self:RegisterProtocol(SCCrossEnterServer, "OnCrossEnterServer")
	self:RegisterProtocol(SCReturnOriginalServer, "OnReturnOriginalServer")
end

-- 通知客户端进入隐藏服
function CrossServerCtrl:OnCrossEnterServer(protocol)
	--记录进入跨服的唯一id
	CrossServerData.Instance:SetRoleId(GameVoManager.Instance:GetMainRoleVo().role_id or 0)
	CrossServerData.Instance:SetServerId(GameVoManager.Instance:GetMainRoleVo().server_id or 0)

	print("OnCrossEnterServer",protocol.login_server_ip, protocol.login_server_port)
	self.data:SetCrossInfo(protocol)
	self.data:SetDisconnectGameServer()
	self.data:SetIsReqDisconnecting(true)

	UserVo.Instance.old_plat_id = UserVo.Instance.plat_server_id
	UserVo.Instance.old_plat_name = UserVo.Instance.plat_name
	UserVo.Instance.plat_server_id = protocol.server
	UserVo.Instance.plat_name = protocol.pname
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	main_role_vo.main_role_id_t[role_id] = true
	
	GameNet.Instance:ResetCrossServer()
	GameNet.Instance:DisconnectGameServer()
	GameNet.Instance:SetCrossServerInfo(protocol.login_server_ip, protocol.login_server_port)
	GameNet.Instance:AsyncConnectCrossServer(5)

	self.data:SetIsReqDisconnecting(false)

	ViewManager.Instance:CloseAll()
end

-- 通知返回原服
function CrossServerCtrl:OnReturnOriginalServer(protocol)
	print_log("通知返回原服")
	self:GoBack()

	-- 下面干嘛延迟10秒？不懂。
	-- GlobalTimerQuest:AddDelayTimer(function() self:GoBack() end, 10)
end

-- 请求开始跨服
function CrossServerCtrl:SendCrossStartReq(cross_activity_type, param, param_1, param_2, sos_pos_x, sos_pos_y)
	if IS_ON_CROSSSERVER then 
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.NotOperate)
		return 
	end

	local main_role = Scene.Instance:GetMainRole()
	GlobalEventSystem:Fire(ObjectEventType.STOP_GATHER, main_role:GetObjId())
	CrossServerData.LAST_CROSS_TYPE = cross_activity_type
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCrossStartReq)
	send_protocol.cross_activity_type = cross_activity_type
	send_protocol.param = param or 0
	send_protocol.param_1 = param_1 or 0
	send_protocol.param_2 = param_2 or 0
	send_protocol.sos_pos_x = sos_pos_x or 0
	send_protocol.sos_pos_y = sos_pos_y or 0
	send_protocol:EncodeAndSend()
end

-- 返回原服
function CrossServerCtrl:GoBack()
	if not IS_ON_CROSSSERVER then return end
	print_log("CrossServerCtrl:GoBack")
	UserVo.Instance.plat_server_id = UserVo.Instance.old_plat_id
	UserVo.Instance.plat_name = UserVo.Instance.old_plat_name

	JUST_BACK_FROM_CROSS_SERVER = true
	GlobalTimerQuest:AddDelayTimer(function() JUST_BACK_FROM_CROSS_SERVER = false end, 10)

	LoginCtrl.SendUserLogout()
	self.data:SetDisconnectGameServer()
	GameNet.Instance:DisconnectGameServer()
	GameNet.Instance:AsyncConnectLoginServer(5)
end