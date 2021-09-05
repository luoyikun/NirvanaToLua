require("game/advance/huashen/huashen_data")


HuashenCtrl = HuashenCtrl or BaseClass(BaseController)

function HuashenCtrl:__init()
	if HuashenCtrl.Instance then
		return
	end
	HuashenCtrl.Instance = self
	self.data = HuashenData.New()
	self:RegisterAllProtocols()
end

function HuashenCtrl:__delete()
	if nil ~= self.set_mount_attr then
		GlobalEventSystem:UnBind(self.set_mount_attr)
		self.set_mount_attr = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end



	HuashenCtrl.Instance = nil
end

function HuashenCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCHuaShenAllInfo, "HuaShenAllInfoReq");
	self:RegisterProtocol(SCHuaShenSpiritInfo, "HuaShenProtectInfoReq");
	self:RegisterProtocol(CSHuaShenOperaReq)
end

-- 化神信息
function HuashenCtrl:HuaShenAllInfoReq(protocol)
	self.data:SetHuashenInfo(protocol)
	AdvanceCtrl.Instance:FlushHuashen("huashen")
end

-- 化神守护信息
function HuashenCtrl:HuaShenProtectInfoReq(protocol)
	self.data:SetHuashenProtectInfo(protocol)
	AdvanceCtrl.Instance:FlushHuashenProtect("huashenprotect")
end

-- 华神操作请求  HUASHEN_REQ_TYPE
function HuashenCtrl:SendHuaShenOperaReq(req_type, param_1, param_2, param_3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSHuaShenOperaReq)
	send_protocol.req_type = req_type or HUASHEN_REQ_TYPE.HUASHEN_REQ_TYPE_ALL_INFO
	send_protocol.param_1 = param_1 or 0
	send_protocol.param_2 = param_2 or 0
	send_protocol.param_3 = param_3 or 0
	send_protocol:EncodeAndSend()
end

-- 化神进阶结果返回
function HuashenCtrl:OnUpgradeResult(result)
	AdvanceCtrl.Instance:OnHuashenUpgradeResult(result)
end

function HuashenCtrl:OnSpiritUpgradeResult(result)
	AdvanceCtrl.Instance:OnSpiritUpgradeResult(result)
end