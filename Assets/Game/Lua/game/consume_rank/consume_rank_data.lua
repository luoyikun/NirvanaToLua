ConsumeRankData = ConsumeRankData or BaseClass()

function ConsumeRankData:__init()
	if ConsumeRankData.Instance then
		ErrorLog("[ConsumeRankData] attempt to create singleton twice!")
		return
	end
	ConsumeRankData.Instance =self
	self.rand_act_consume = 0
end

function ConsumeRankData:__delete()
	ConsumeRankData.Instance = nil
end

function ConsumeRankData:SetRandActConsume(num)
	self.rand_act_consume = num
end

function ConsumeRankData:GetRandActConsume()
	return self.rand_act_consume
end

function ConsumeRankData:GetConsumeRankCfg()
	local rand_act_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	return ActivityData.Instance:GetRandActivityConfig(rand_act_cfg.consume_gold_rank, ACTIVITY_TYPE.RAND_CONSUME_GOLD_RANK)
end
