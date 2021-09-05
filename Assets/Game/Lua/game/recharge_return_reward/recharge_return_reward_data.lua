
RechargeReturnRewardData = RechargeReturnRewardData or BaseClass()
function RechargeReturnRewardData:__init()
	if RechargeReturnRewardData.Instance ~= nil then
		print("[RechargeReturnRewardData]error:create a singleton twice")
	end
	RechargeReturnRewardData.Instance = self
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHONGZHI_CRAZY_REBATE)
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHONGZHI_CRAZY_REBATE, is_open)

	self.chongzhi_count = 0
end

function RechargeReturnRewardData:__delete()
end

function RechargeReturnRewardData:GetActConfig()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().crazy_rebate
end

function RechargeReturnRewardData:SetRechargeNum(num)
	self.chongzhi_count = num
end

function RechargeReturnRewardData:GetRechargeNum()
	return self.chongzhi_count
end