DaLeGouData = DaLeGouData or BaseClass()
function DaLeGouData:__init()
	if DaLeGouData.Instance then
		print_error("[DaLeGouData] Attempt to create singleton twice!")
		return
	end

	DaLeGouData.Instance = self

	self.chongzhi = 0
	self.level = 0
	self.person_limit = 0
	self.all_limit = 0
	RemindManager.Instance:Register(RemindName.DaLeGou, BindTool.Bind(self.GetDaLeGouRedCount, self))
end

function DaLeGouData:__delete()
	RemindManager.Instance:UnRegister(RemindName.DaLeGou)
	DaLeGouData.Instance = nil
end

function DaLeGouData:GetActivityCfg()
	local rand_act_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local happy_shopping_cfg = ActivityData.Instance:GetRandActivityConfig(rand_act_cfg.happy_shopping, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DALEGOU)

	return happy_shopping_cfg
end

function DaLeGouData:SetBuyInfo(protocol)
	self.chongzhi = protocol.chongzhi
	self.level = protocol.level
end

function DaLeGouData:GetChongZhi()
	return self.chongzhi
end

function DaLeGouData:GetLevel()
	return self.level
end

function DaLeGouData:SetBuyLimitList(limit_list)
	self.limit_list = limit_list
end

function DaLeGouData:GetBuyLimitInfoBySeq(seq)
	if self.limit_list == nil then
		return nil
	end
	
	seq = seq or -1
	return self.limit_list[seq + 1]
end

--获取下一档位充值额度
function DaLeGouData:GetNextLevelRecharge()
	local happy_shopping_cfg = self:GetActivityCfg()
	for _, v in ipairs(happy_shopping_cfg) do
		if v.level > self.level then
			return v.gold_level
		end
	end

	return 0
end

function DaLeGouData:GetDaLeGouRedCount()
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DALEGOU) then
		return 0
	end

end

function DaLeGouData:DaLeGouPoindRemind()
	local remind_num = self:GetDaLeGouRedCount()
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DALEGOU, remind_num > 0)
end
