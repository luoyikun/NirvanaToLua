require("game/daily_rebate/daily_rebate_view")
require("game/daily_rebate/daily_rebate_data")

DailyRebateCtrl = DailyRebateCtrl or  BaseClass(BaseController)

function DailyRebateCtrl:__init()
	if DailyRebateCtrl.Instance ~= nil then
		print_error("[DailyRebateCtrl] attempt to create singleton twice!")
		return
	end
	DailyRebateCtrl.Instance = self

	self:RegisterAllProtocols()

	self.data = DailyRebateData.New()
	self.view = DailyRebateView.New(ViewName.DailyRebateView)
end

function DailyRebateCtrl:__delete()
	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	DailyRebateCtrl.Instance = nil
end

-- 协议注册
function DailyRebateCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSDayChongzhiRewardReq)
	self:RegisterProtocol(SCDayChongzhiRewardInfo, "OnDayChongzhiRewardInfo")
end

function DailyRebateCtrl:ReqDayChongzhiRewardReq(opera_type, param)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSDayChongzhiRewardReq)
	send_protocol.opera_type = opera_type or 0
	send_protocol.param = param or 0
	send_protocol:EncodeAndSend()
end

function DailyRebateCtrl:OnDayChongzhiRewardInfo(protocol)
	self.data:SetChongZhiDay(protocol.day_count)
	self.data:SetDayRewardFlagList(protocol.reward_flag_list)
	self.data:SetRareRewardFlagList(protocol.rare_reward_flag_list)

	if self.view:IsOpen() then
		self.view:Flush()
	end

	RemindManager.Instance:Fire(RemindName.DailyRebateRemind)
end