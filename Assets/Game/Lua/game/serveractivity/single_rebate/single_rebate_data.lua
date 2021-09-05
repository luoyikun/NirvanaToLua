SingleRebateData = SingleRebateData or BaseClass()

function SingleRebateData:__init()
	if SingleRebateData.Instance then
		print_error("[SingleRebateData] Attemp to create a singleton twice !")
	end
	SingleRebateData.Instance = self

	self.is_charge_flag = 0
end

function SingleRebateData:__delete()
	SingleRebateData.Instance = nil
end

function SingleRebateData:GetCfg()
	if self.rand_act_other_cfg then
		return self.rand_act_other_cfg
	end

	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local act_cfg = cfg and cfg.daily_love2			--daily_love2 单笔返利表名
	-- self.rand_act_other_cfg = act_cfg and ActivityData.Instance:GetRandActivityConfig(act_cfg, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_REBATE)
	-- return self.rand_act_other_cfg
	self.rand_act_other_cfg = act_cfg
	return self.rand_act_other_cfg
end

function SingleRebateData:GetRewardPrecent()
	local cfg = self:GetCfg()
	-- if cfg and cfg[1] then
	-- 	return cfg[1].single_rebate_reward_precent
	-- end
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if cfg and #cfg > 0 then
		for i = 1, #cfg do
			if cfg[i] then
				if cur_day <= cfg[i].opengame_day then
					return cfg[i].single_rebate_reward_precent
				end
			end
		end
	end
	return 0
end

function SingleRebateData:GetLimitLevel()
	local show_cfg = ActivityData.Instance:GetActivityConfig(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_REBATE)
	if show_cfg then
		return show_cfg.min_level
	end
	return 0
end

function SingleRebateData:IsFunOpen()
	local limit_level = self:GetLimitLevel()
	if limit_level <= GameVoManager.Instance:GetMainRoleVo().level then
		return true
	else
		return false
	end
end

function SingleRebateData:SetSingleRebateChargeFlag(protocol)
	self.is_charge_flag = protocol.flag
end

function SingleRebateData:GetSingleRebateChargeFlag()
	return self.is_charge_flag
end