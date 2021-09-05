ZhiZunRechargeRankData = ZhiZunRechargeRankData or BaseClass()

function ZhiZunRechargeRankData:__init()
	if ZhiZunRechargeRankData.Instance then
		ErrorLog("[ZhiZunRechargeRankData] attempt to create singleton twice!")
		return
	end
	ZhiZunRechargeRankData.Instance =self
	self.rand_act_rechange = 0
end

function ZhiZunRechargeRankData:__delete()
	ZhiZunRechargeRankData.Instance = nil
end

function ZhiZunRechargeRankData:SetRandActRecharge(num)
	self.rand_act_rechange = num
end

function ZhiZunRechargeRankData:GetRandActRecharge()
	return self.rand_act_rechange
end

function ZhiZunRechargeRankData:GetRechargeRankCfg()
	local rand_act_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	return ActivityData.Instance:GetRandActivityConfig(rand_act_cfg.extreme_recharge, ACTIVITY_TYPE.RAND_ZHIZUN_CHONGZHI_RANK)
end
