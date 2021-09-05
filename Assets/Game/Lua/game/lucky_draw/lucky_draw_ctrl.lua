require("game/lucky_draw/lucky_draw_data")
require("game/lucky_draw/lucky_draw_view")
require("game/lucky_draw/lucky_draw_auto_pop_view")
LuckyDrawCtrl = LuckyDrawCtrl or BaseClass(BaseController)

function LuckyDrawCtrl:__init()
	if LuckyDrawCtrl.Instance then
		print_error("[LuckyDrawCtrl] Attemp to create a singleton twice !")
	end
	LuckyDrawCtrl.Instance = self
	self.view = LuckyDrawView.New(ViewName.LuckyDrawView)
	self.auto_pop_view = LuckyDrawAutoPopView.New(ViewName.LuckyDrawAutoPopView)
	self.data = LuckyDrawData.New()
	self:RegisterAllProtocols()

	self.activity_call_back = BindTool.Bind(self.ActivityChange, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.RemindLuckyDraw)
end

function LuckyDrawCtrl:__delete()
	self:CacleSendDelayTime()
	self:CacleClearDelayTime()
	if self.view then
		self.view:DeleteMe()
	end

	if self.data then
		self.data:DeleteMe()
	end
	
	if self.auto_pop_view then
		self.auto_pop_view:DeleteMe()
	end

	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end	
	LuckyDrawCtrl.Instance = nil
end

function LuckyDrawCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRATianMingDivinationInfo, "OnRATianMingDivinationInfo")
	self:RegisterProtocol(SCTianMingDivinationActivityStartChouResult, "OnTianMingDivinationActivityStartChouResult")
end

function LuckyDrawCtrl:OnRATianMingDivinationInfo(protocol)
	self.data:SetLuckyDrawInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.RemindLuckyDraw)
end

function LuckyDrawCtrl:OnTianMingDivinationActivityStartChouResult(protocol)
	self.data:SetLuckyDrawResultInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end

	if self.data:GetAutoFlag() and self.view:IsOpen() then
		self:AutoDivination()
		return
	end

	if self.data:GetStopFlag() then
		self:ClearData()
		return
	end

	if not self.data:GetAutoFlag() then
		self.view:FlushAnimation()
		return
	end
	RemindManager.Instance:Fire(RemindName.RemindLuckyDraw)
end

function LuckyDrawCtrl:ActivityChange(activity_type, status, next_time, open_type)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_LUCKYDRAW then
		-- 活动开启之后才请求
		if status == ACTIVITY_STATUS.OPEN then
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_LUCKYDRAW, RA_TIANMING_DIVINATION_OPERA_TYPE.RA_TIANMING_DIVINATION_OPERA_TYPE_QUERY_INFO, 0, 0)
		end
	end
end

function LuckyDrawCtrl:AutoDivination()
	self.view:FlushAutoAnimation()
	if not self.data:IsDesired() and self.view:IsOpen() then
		if not self.data:IsEnoughGold() then
			TipsCtrl.Instance:ShowLackDiamondView()
			self:ClearData()
			self.view:Flush()
			return
		end

		self:StartSendDelayTime()
		self:CacleSendDelayTime()
		self.delay_send_time = GlobalTimerQuest:AddDelayTimer(function()
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_LUCKYDRAW, RA_TIANMING_DIVINATION_OPERA_TYPE.RA_TIANMING_DIVINATION_OPERA_TYPE_START_CHOU, 0, 0)
			end, 0.05)
	elseif self.data:IsDesired() then
		self:ClearData()
	end
end

function LuckyDrawCtrl:StartSendDelayTime()
	self:CacleClearDelayTime()
	self.delay_clear_time = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.ClearData, self), 2)
end

function LuckyDrawCtrl:CacleClearDelayTime()
	if self.delay_clear_time then
		GlobalTimerQuest:CancelQuest(self.delay_clear_time)
		self.delay_clear_time = nil
	end
end

function LuckyDrawCtrl:CacleSendDelayTime()
	if self.delay_send_time then
		GlobalTimerQuest:CancelQuest(self.delay_send_time)
		self.delay_send_time = nil
	end
end

function LuckyDrawCtrl:ClearData()
	self.data:SetAutoFlag(false)
	self.data:SetStopFlag(false)
end

function LuckyDrawCtrl:RemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.RemindLuckyDraw then
		ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_LUCKYDRAW, num > 0)
	end
end