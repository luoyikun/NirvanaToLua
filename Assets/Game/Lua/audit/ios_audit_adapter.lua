IosAuditAdapter = IosAuditAdapter or {}
local self = IosAuditAdapter
local is_audit = false

require("audit/ios_audit_receiver")
require("audit/ios_audit_sender")
require("audit/ios_audit_data")

function IosAuditAdapter:Startup()
	is_audit = true
	IosAuditSender.is_audit = is_audit
	IosAuditReceiver.is_audit = is_audit
	IosAuditData.is_audit = is_audit

	IosAuditMgr.Startup()
	IosAuditMgr.SwitchToIosAuditUI()

	IosAuditMgr.BindMsgCallback(function (json_msg)
		self:OnReceiveMsg(json_msg)
	end)

end

function IosAuditAdapter:SendMsg(msg_data)
	if not is_audit then return end

	IosAuditMgr.SendMsgToAuditUI(cjson.encode(msg_data))
end

function IosAuditAdapter:OnReceiveMsg(json_msg)
	if not is_audit then return end

	local data = cjson.decode(json_msg)
	IosAuditReceiver:ReceiveMsg(data)
end
