require("game/kuafu_target/kuafu_target_view")
require("game/kuafu_target/kuafu_target_data")

KuaFuTargetCtrl = KuaFuTargetCtrl or BaseClass(BaseController)
function KuaFuTargetCtrl:__init()
	if KuaFuTargetCtrl.Instance then
		print_error("[KuaFuTargetCtrl] Attemp to create a singleton twice !")
	end
	KuaFuTargetCtrl.Instance = self
	self.data = KuaFuTargetData.New()
	self.view = KuaFuTargetView.New(ViewName.KuaFuTargetView)

	self:RegisterAllProtocols()
	self.mainui_open = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpen, self))
end

function KuaFuTargetCtrl:__delete()
	KuaFuTargetCtrl.Instance = nil
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.mainui_open then
		GlobalEventSystem:UnBind(self.mainui_open)
		self.mainui_open = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
end

function KuaFuTargetCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCCrossGoalInfo, "OnSCRAKuaFuTargetInfo")
	self:RegisterProtocol(SCCrossGoalGuildNotify, "OnSCCrossGoalGuildNotify")
	self:RegisterProtocol(CSCrossGoalOperaReq)
end

function KuaFuTargetCtrl:OnSCCrossGoalGuildNotify(protocol)
	self.data:SetGoalGuildNotify(protocol)
end

function KuaFuTargetCtrl:OnSCRAKuaFuTargetInfo(protocol)
	self.data:SetExtremeChallengeInfo(protocol)									-- 服务器下发协议
	if self.view:IsOpen() then												-- 协议下发后刷新
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.KuaFuTarget)				-- 红点
end

function KuaFuTargetCtrl:MainuiOpen()
	local day = TimeCtrl.Instance:GetCurOpenServerDay()
	local openday, endday = self.data:GetOpenAndEndDay()

	if day > openday and day <= endday + 1 then
		self:SendCrossGolbReq(CROSS_GOLB_OPERA_TYPE.CROSS_GOAL_INFO_REQ)
	end
end

function KuaFuTargetCtrl:SendCrossGolbReq(opera, param)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossGoalOperaReq)
	protocol.opera_type = opera or 0
	protocol.param = param or 0
	protocol:EncodeAndSend()
end
