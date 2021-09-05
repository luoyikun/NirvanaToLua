require("game/happy_recharge/happy_recharge_data")
require("game/happy_recharge/happy_recharge_view")
require("game/happy_recharge/happy_record_list_view")
HappyRechargeCtrl = HappyRechargeCtrl or BaseClass(BaseController)

function HappyRechargeCtrl:__init()
	if HappyRechargeCtrl.Instance then
		print_error("[HappyRechargeCtrl] Attemp to create a singleton twice !")
	end
	HappyRechargeCtrl.Instance = self
	self.data = HappyRechargeData.New()
	self.view = HappyRechargeView.New(ViewName.HappyRechargeView)
	self.record_list_view = HappyRecordListView.New(ViewName.HappyRecordListView)
	self:RegisterAllProtocols()

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.CHONGZHIDALETOU)

	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)

end

function HappyRechargeCtrl:__delete()

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end	

	self.view:DeleteMe()

	self.data:DeleteMe()

	HappyRechargeCtrl.Instance = nil
end

function HappyRechargeCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRANiuEggInfo, "OnSCRANiuEggInfo")
	self:RegisterProtocol(SCRANiuEggChouResultInfo, "OnSCRANiuEggChouResultInfo")
end

function HappyRechargeCtrl:SendGetKaifuActivityInfo(rand_activity_type, opera_type, param_1, param_2)
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(rand_activity_type, opera_type, param_1, param_2)
end

function HappyRechargeCtrl:OnSCRANiuEggInfo(protocol)
	self.data:SetNiuEggInfo(protocol)
	self.view:Flush()

	RemindManager.Instance:Fire(RemindName.CHONGZHIDALETOU)
end

function HappyRechargeCtrl:OnSCRANiuEggChouResultInfo(protocol)
	self.data:SetRewardListInfo(protocol.reward_req_list)
	if protocol.reward_req_list_count > 1 then
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.HAPPY_RECHARGE_10)
	elseif protocol.reward_req_list_count == 1 then
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.HAPPY_RECHARGE_1)
	end
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.CHONGZHIDALETOU)
end

function HappyRechargeCtrl:RemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.CHONGZHIDALETOU then
		self.data:FlushHallRedPoindRemind()
	end
end

function HappyRechargeCtrl:ActivityCallBack(activity_type, status)
	if activity_type == ACTIVITY_TYPE.RAND_HAPPY_RECHARGE and status == ACTIVITY_STATUS.OPEN then
		HappyRechargeCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_HAPPY_RECHARGE, 
			RA_CHONGZHI_NIU_EGG_OPERA_TYPE.RA_CHONGZHI_NIU_EGG_OPERA_TYPE_QUERY_INFO)
	end 
end