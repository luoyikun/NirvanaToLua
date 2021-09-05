-- 仙尊卡 author Lm
require("game/immortal/immortal_view")
require("game/immortal/immortal_data")
require("game/immortal/tips_immortal_view")

ImmortalCtrl = ImmortalCtrl or BaseClass(BaseController)
function ImmortalCtrl:__init()
	if ImmortalCtrl.Instance then
		print_error("[ImmortalCtrl] attempt to create singleton twice!")
		return
	end
	ImmortalCtrl.Instance = self

	self.data = ImmortalData.New()
	self.view = ImmortalView.New(ViewName.ImmortalView)
	self.tips_view = ImmortalTipsView.New(ViewName.ImmortalTipsView)

	self:RegisterAllProtocols()
	--提醒监听
	self.GEventListener = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind1(self.SetActivityStatus, self))

end

function ImmortalCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.tips_view then
		self.tips_view:DeleteMe()
		self.tips_view = nil
	end

	if self.GEventListener then 
		GlobalEventSystem:UnBind(self.GEventListener)
		self.GEventListener = nil
	end

	ImmortalCtrl.Instance = nil
end

function ImmortalCtrl:RegisterAllProtocols()
	-- self:RegisterProtocol(SCFairyBuddhaCardActivateInfo,"BackSCFairyBuddhaCardActivateInfo")
	self:RegisterProtocol(SCXianZunKaAllInfo, "OnXianZunKaAllInfo")
end

function ImmortalCtrl:SetActivityStatus()
	local cur_timestamp = TimeCtrl.Instance:GetCurOpenServerDay()
	if cur_timestamp >= 2 and not (IS_AUDIT_VERSION or IS_FREE_VERSION)  then
		if cur_timestamp <= 4  then
			-- self.data:SetOpenRemindNum(1)
		end
		ActivityData.Instance:SetActivityStatus(ACTIVITY_TYPE.IMMORTAL, ACTIVITY_STATUS.OPEN, cur_timestamp + COMMON_CONSTS.MAX_LOOPS)
	else
		ActivityData.Instance:SetActivityStatus(ACTIVITY_TYPE.IMMORTAL, ACTIVITY_STATUS.CLOSE)
	end
end

function ImmortalCtrl:OnXianZunKaAllInfo(protocol)
	self.data:SetXianZunKaInfo(protocol)
	self.view:Flush()
	GlobalEventSystem:Fire(ObjectEventType.FIGHT_EFFECT_CHANGE, true)
	RemindManager.Instance:Fire(RemindName.ImmortalCard)
	RemindManager.Instance:Fire(RemindName.ImmortalLabel)
	MainUICtrl.Instance:FlushImmortalIcon()
end

function ImmortalCtrl:BackSCFairyBuddhaCardActivateInfo(protocol)
	self.data:SetImmortalInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	GlobalEventSystem:Fire(ObjectEventType.FIGHT_EFFECT_CHANGE, true)
	RemindManager.Instance:Fire(RemindName.ImmortalCard)
end

function ImmortalCtrl:SendCSFairyBuddhaCardActivateReq(card_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSFairyBuddhaCardActivateReq)
	protocol.card_type = card_type or 0
	protocol:EncodeAndSend()
end

function ImmortalCtrl:SendCSFairyBuddhaCardGoldBindReq(card_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSFairyBuddhaCardGoldBindReq)
	protocol.card_type = card_type or 0
	protocol:EncodeAndSend()
end

function ImmortalCtrl:Open()
	self.view:Open()
	self.data:SetOpenRemindNum(0)
	RemindManager.Instance:Fire(RemindName.ImmortalCard)
end

--购买仙尊卡
function ImmortalCtrl.SendXianZunKaOperaBuyReq(card_type)
	ImmortalCtrl.SendXianZunKaOperaReq(XIANZUNKA_OPERA_REQ_TYPE.XIANZUNKA_OPERA_REQ_TYPE_BUY_CARD, card_type)
end

--拿取每日奖励
function ImmortalCtrl.SendXianZunKaOperaRewardReq(card_type)
	ImmortalCtrl.SendXianZunKaOperaReq(XIANZUNKA_OPERA_REQ_TYPE.XIANZUNKA_OPERA_REQ_TYPE_FETCH_DAILY_REWARD, card_type)
end

function ImmortalCtrl.SendXianZunKaOperaReq(opera_req_type, param_1, param_2)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSXianZunKaOperaReq)
	send_protocol.opera_req_type = opera_req_type
	send_protocol.param_1 = param_1 or 0
	send_protocol.param_2 = param_2 or 0
	send_protocol:EncodeAndSend()
end