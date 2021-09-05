IosAuditSender = IosAuditSender or {}
IosAuditSender.is_audit = false
local self = IosAuditSender

function IosAuditSender:SendMsg(data)
	IosAuditAdapter:SendMsg(data)
end

function IosAuditSender:OpenMainView()
	if not self.is_audit then return end
	self:SendMsg({msg_type = "OpenView", view_name = "mainui"})
end

function IosAuditSender:UpdatePlayerData()
	if not self.is_audit then return end
	self:SendMsg({msg_type = "UpdateData", data = IosAuditData:GetPlayerData()})
end

function IosAuditSender:UpdateTaskData()
	if not self.is_audit then return end
	self:SendMsg({msg_type = "UpdateData", data = IosAuditData:GetTaskData()})
end

function IosAuditSender:UpdateSkillData()
	if not self.is_audit then return end
	self:SendMsg({msg_type = "UpdateData", data = IosAuditData:GetSkillData()})
end

function IosAuditSender:UpdatePackageData()
	if not self.is_audit then return end
	self:SendMsg({msg_type = "UpdateData", data = IosAuditData:GetPackageData()})
end

function IosAuditSender:UpdateShopData()
	if not self.is_audit then return end
	self:SendMsg({msg_type = "UpdateData", data = IosAuditData:GetShopData()})
end

function IosAuditSender:UpdateSkillRestTime()
	if not self.is_audit then return end
	self:SendMsg({msg_type = "UpdateData", data = IosAuditData:GetAuditSkillRestTimeData()})
end

function IosAuditSender:UpdatePlayerAttrInfoData()
	if not self.is_audit then return end
	self:SendMsg({msg_type = "UpdateData", data = IosAuditData:GetPlayerAttrInfoData()})
end

function IosAuditSender:UpdateChongZhiData()
	if not self.is_audit then return end
	self:SendMsg({msg_type = "UpdateData", data = IosAuditData:GetChongZhiData()})
end