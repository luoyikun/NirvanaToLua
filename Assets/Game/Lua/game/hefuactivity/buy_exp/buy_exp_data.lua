BuyExpData = BuyExpData or BaseClass()

function BuyExpData:__init()
	if BuyExpData.Instance ~= nil then
		print_error("[BuyExpData] Attemp to create a singleton twice !")
	end
	BuyExpData.Instance = self

	-- 经验炼制信息
	self.buy_exp_info = {}
	-- RemindManager.Instance:Register(RemindName.BuyExp, BindTool.Bind(self.GetBuyExpRemind, self))
	local config = HefuActivityData.GetCurrentCombineActivityConfig() or {}
	self.exp_refine_cfg = config.exp_refine or {}
	self.other_cfg = config.other[1] or {}
end

function BuyExpData:__delete()	
	BuyExpData.Instance = nil
end

function BuyExpData:SetRAExpRefineInfo(protocol)
	self.buy_exp_info.had_buy = protocol.had_buy
end

function BuyExpData:GetRAExpRefineInfo()
	return self.buy_exp_info
end

function BuyExpData:GetBuyExpCfg()
	return self.exp_refine_cfg
end

function BuyExpData:GetOtherCongig()
	return self.other_cfg
end


function BuyExpData:CalculationOfConsumption(default_level)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	local to_level = level + default_level
	local gold_num = 0
	for i,v in ipairs(self.exp_refine_cfg) do
		if level < v.level then
			if to_level <= v.level then
				gold_num = gold_num + (default_level * v.value)
				break
			else
				gold_num = gold_num + ((v.level - level) * v.value)
				level = v.level
				default_level = to_level - level
			end
		end
	end
	return gold_num
end

function BuyExpData:GetCanBuyLevelAndGold()
	local MAX_UPGRADE_LEVEL = self.other_cfg.buy_exp_max_level
	local world_level = RankData.Instance:GetWordLevel() - self.other_cfg.buy_exp_level_limit
	local level = GameVoManager.Instance:GetMainRoleVo().level
	local level_1 = 0
	local level_2 = 0
	local level_3 = 0
	local gold_1 = 0
	local gold_2 = 0
	local gold_3 = 0
	if level < world_level then
		if world_level - level >= MAX_UPGRADE_LEVEL then
			level_1 = math.floor(MAX_UPGRADE_LEVEL / 3) 
			level_2 = level_1 * 2 == 0 and 1 or level_1 *2
			level_3 =  MAX_UPGRADE_LEVEL 
		else
			level_1 = math.floor((world_level - level) / 3)
			level_2 = level_1 * 2 == 0 and 1 or level_1 *2
			level_3 = world_level - level 
		end
		gold_1 = self:CalculationOfConsumption(level_1)
		gold_2 = self:CalculationOfConsumption(level_2)
		gold_3 = self:CalculationOfConsumption(level_3)
	end
	local list = {}
	list["level_1"] = level_1
	list["level_2"] = level_2
	list["level_3"] = level_3
	list["gold_num_1"] = gold_1
	list["gold_num_2"] = gold_2
	list["gold_num_3"] = gold_3
	return list
end


-- 获取活动图标显示条件
function BuyExpData:GetExpRefineIsOpen()
	local world_level = RankData.Instance:GetWordLevel() - self.other_cfg.buy_exp_level_limit
	local level = GameVoManager.Instance:GetMainRoleVo().level
	local activity_state = 0
	local activity_state_list = HefuActivityData.Instance:GetCombineSubActivityList()
	for k,v in pairs(activity_state_list) do
		if v.sub_type ==  COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BUYEXP then
			activity_state = CSActState.OPEN
			break
		end
	end
	if level < world_level and activity_state == CSActState.OPEN and self.buy_exp_info.had_buy == 0 then 
		return true
	else
		return false
	end
end




