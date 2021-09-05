require("game/consume_discount/consume_discount_view")
require("game/consume_discount/consume_discount_data")

ConsumeDiscountCtrl = ConsumeDiscountCtrl or BaseClass(BaseController)

function ConsumeDiscountCtrl:__init()
	if ConsumeDiscountCtrl.Instance ~= nil then
		print_error("[ConsumeDiscountCtrl]error:create a singleton twice")
	end
	ConsumeDiscountCtrl.Instance = self

	self.view = ConsumeDiscountView.New(ViewName.ConsumeDiscountView)
	self.data = ConsumeDiscountData.New()

	self:RegisterAllProtocols()
	--self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenComplete, self))
	self.activity_call_back = BindTool.Bind(self.ActivityChangeCallback, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.ConsumeDiscount)
end

function ConsumeDiscountCtrl:__delete()
	if nil ~= self.view then
		self.view:DeleteMe()
	end
	if nil ~= self.data then
		self.data:DeleteMe()
	end

	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end		

	ConsumeDiscountCtrl.Instance = nil
end

function ConsumeDiscountCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAContinueConsumeInfo, "OnRAContinueConsumeInfo")
end


function ConsumeDiscountCtrl:MainuiOpenComplete()
	local param_t = {
		rand_activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CONSUME,
		opera_type = RA_CONTINUE_CONSUME_OPERA_TYPE.RA_CONTINUME_CONSUME_OPERA_TYPE_QUERY_INFO,
	}
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CONSUME)
	if is_open then
		KaifuActivityCtrl.Instance:SendRandActivityOperaReq(param_t.rand_activity_type, param_t.opera_type)
	end
end

function ConsumeDiscountCtrl:ActivityChangeCallback(activity_type, status, next_time, open_type)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CONSUME then
		-- 活动开启之后才请求
		if status == ACTIVITY_STATUS.OPEN then
			local param_t = {
				rand_activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CONSUME,
				opera_type = RA_CONTINUE_CONSUME_OPERA_TYPE.RA_CONTINUME_CONSUME_OPERA_TYPE_QUERY_INFO,
			}
			local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CONSUME)
			if is_open then
				KaifuActivityCtrl.Instance:SendRandActivityOperaReq(param_t.rand_activity_type, param_t.opera_type)
			end
		end
	end
end

function ConsumeDiscountCtrl:OnRAContinueConsumeInfo(protocol)
	self.data:SetRAContinueConsumeInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.ConsumeDiscount)
end

function ConsumeDiscountCtrl:RemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.ConsumeDiscount then
		ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CONSUME, num > 0)
	end
end