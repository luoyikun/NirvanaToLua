require("game/weekend_happy/weekend_happy_view")
require("game/weekend_happy/weekend_happy_data")

WeekendHappyCtrl = WeekendHappyCtrl or BaseClass(BaseController)
function WeekendHappyCtrl:__init()
	if WeekendHappyCtrl.Instance then
		print_error("[WeekendHappyCtrl] Attemp to create a singleton twice !")
	end
	WeekendHappyCtrl.Instance = self
	self.data = WeekendHappyData.New()
	self.view = WeekendHappyView.New(ViewName.Weekend_HappyView)

	self:RegisterAllProtocols()
	
	ActivityData.Instance:NotifyActChangeCallback(BindTool.Bind(self.ActivityChange, self))
	--绑定红点回调
	self.reddot_activate = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.reddot_activate, RemindName.WeekendHappyRemind)
end

function WeekendHappyCtrl:__delete()
	WeekendHappyCtrl.Instance = nil
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.reddot_activate then
		RemindManager.Instance:UnBind(self.reddot_activate)
		self.reddot_activate = nil
	end
end

function WeekendHappyCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAWeekendHappyInfo, "OnSCRAWeekendHappyInfo")
end

function WeekendHappyCtrl:OnSCRAWeekendHappyInfo(protocol)
	self.data:SetRAWeekendHappyInfo(protocol)									-- 服务器下发协议
	if self.view:IsOpen() then												-- 协议下发后刷新
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.WeekendHappyRemind)				-- 红点
end

-- function WeekendHappyCtrl:OnSCRAHappyErnieTaoResultInfo(protocol)
-- 	self.data:SetRAWeekendHappyTaoResultInfo(protocol)												-- 服务器下发协议
-- 	TipsCtrl.Instance:ShowTreasureView(self.data:GetChestShopMode())								-- 显示寻宝奖励界面
-- 	if self.view:IsOpen() then
-- 		self.view:Flush()																			-- 协议下发后刷新
-- 	end
-- 	RemindManager.Instance:Fire(RemindName.WeekendHappyRemind)										-- 红点			
-- end

-- 申请开服活动信息
-- function WeekendHappyCtrl:SendGetKaifuActivityInfo(rand_activity_type, opera_type, param_1, param_2)
-- 	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(rand_activity_type, opera_type, param_1, param_2)
-- end

function WeekendHappyCtrl:ActivityChange(activity_type, status, next_time, open_type)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WEEKENDHAPPY then
		-- 活动开启之后才请求
		if status == ACTIVITY_STATUS.OPEN then
			KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WEEKENDHAPPY, RA_LOTTERY_1_OPERA_TYPE.RA_LOTTERY_1_OPERA_TYPE_INFO, 0, 0)
		end
	end
end

function WeekendHappyCtrl:RemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.WeekendHappyRemind and ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WEEKENDHAPPY)  then
		self.data:FlushHallRedPoindRemind()				--确定是否刷新卷轴红点
	end
end

function WeekendHappyCtrl:FlushWareRed()
	if self.view:IsOpen() then
		self.view:FlushWareRed()
	end
end

