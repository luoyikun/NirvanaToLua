require("game/kuafu_consumerank/kuafu_consumerank_view")
require("game/kuafu_consumerank/kuafu_consumerank_data")

KuaFuConsumeRankCtrl = KuaFuConsumeRankCtrl or BaseClass(BaseController)

function KuaFuConsumeRankCtrl:__init()
	if KuaFuConsumeRankCtrl.Instance ~= nil then
		print_error("[KuaFuConsumeRankCtrl] attempt to create singleton twice!")
		return
	end
	KuaFuConsumeRankCtrl.Instance = self
	self.data = KuaFuConsumeRankData.New()
	self.view = KuaFuConsumeRankView.New(ViewName.KuaFuConsumeRank)
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MianUIOpenComlete, self))
	self:RegisterAllProtocols()
end


function KuaFuConsumeRankCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.main_view_complete then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end

	KuaFuConsumeRankCtrl.Instance = nil
end
-- 协议注册
function KuaFuConsumeRankCtrl:RegisterAllProtocols()
	-- self:RegisterProtocol(CSCrossRandActivityRequest)
	self:RegisterProtocol(CSCrossRAConsumeRankGetRank)

	self:RegisterProtocol(SCCrossRAConsumeRankConsumeInfo, "OnSCCrossRAConsumeRankConsumeInfo")
	self:RegisterProtocol(SCCrossRAConsumeRankGetRankACK, "OnCrossRAConsumeRankGetRankACK")
end

function KuaFuConsumeRankCtrl:OnCrossRAConsumeRankGetRankACK(protocol)
	self.data:SetCrossRAConsumeRankGetRankACK(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

function KuaFuConsumeRankCtrl:OnSCCrossRAConsumeRankConsumeInfo(protocol)
	self.data:SetConsumeInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

function KuaFuConsumeRankCtrl.SendTianXiangOperate2(id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCrossRAConsumeRankGetRank)
	send_protocol.modify_id = id
	send_protocol:EncodeAndSend()
end

function KuaFuConsumeRankCtrl:MianUIOpenComlete()
	if ActivityData.Instance:GetCrossRandActivityIsOpenByType(ACTIVITY_TYPE.KF_KUAFUCONSUME) then
		KuaFuConsumeRankCtrl.SendTianXiangOperate(ACTIVITY_TYPE.KF_KUAFUCONSUME, GameEnum.CS_CROSS_RA_CONSUME_RANK_REQ_TYPE_INFO)
		local modify_id = KuaFuConsumeRankData.Instance:GetModifyId()
		KuaFuConsumeRankCtrl.SendTianXiangOperate2(modify_id)
	end
end

function KuaFuConsumeRankCtrl.SendTianXiangOperate(activity_type,operate_type, param_1, param_2, param_3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCrossRandActivityRequest)
	send_protocol.activity_type = activity_type or 0
	send_protocol.opera_type = operate_type or 0
	send_protocol.param_1 = param_1 or 0
	send_protocol.param_2 = param_2 or 0
	send_protocol.param_3 = param_3 or 0
	send_protocol:EncodeAndSend()
end



