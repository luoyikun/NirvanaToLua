WeekendHappyData = WeekendHappyData or BaseClass()
--初始化
function WeekendHappyData:__init()
	if WeekendHappyData.Instance ~= nil then
		ErrorLog("[WeekendHappyData] attempt to create singleton twice!")
		return
	end
	WeekendHappyData.Instance = self
	self.count = -1
	self.chest_shop_mode = -1
	self.chou_times = 0
	self.is_open = false
	self.select = nil
	RemindManager.Instance:Register(RemindName.WeekendHappyRemind, BindTool.Bind(self.GetWeekendHappyRemind, self))
end

--释放
function WeekendHappyData:__delete()
	WeekendHappyData.Instance = nil
	self.count = nil 
	self.chest_shop_mode = nil
	RemindManager.Instance:UnRegister(RemindName.WeekendHappyRemind)

end

-- 其他配置
function WeekendHappyData:GetOtherCfgByOpenDay()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfigOtherCfg()
	return cfg
end

--根据开服时间获取欢乐摇奖配置  
function WeekendHappyData:GetOpenTakeTimeCfg()
	local weekend_happy_cfg = {}
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	if nil == cfg then
		return weekend_happy_cfg
	end
	weekend_happy_cfg = ActivityData.Instance:GetRandActivityConfig(cfg.lottery_1, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WEEKENDHAPPY) or {}
	return weekend_happy_cfg
end

--获取累计奖励配置表
function WeekendHappyData:GetWeekendHappyRewardConfig()
	local reward_cfg = {}
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	if nil == cfg then
		return reward_cfg
	end
	
	reward_cfg = ActivityData.Instance:GetRandActivityConfig(cfg.lottery_1_person_reward, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WEEKENDHAPPY) or {}
	return reward_cfg
end

-- 获取展示珍稀物品列表
function WeekendHappyData:GetWeekendHappyCfgByList()
	local cfg = self:GetOpenTakeTimeCfg()
	local list = {}
	if nil == next(cfg) then
		return list
	end
	for k, v in pairs(cfg) do
		local show_num = v.show_num
		if show_num ~= nil and show_num > 0 and show_num < 14 then
			list[show_num] = v
		end
	end
	return list
end

--获取抽取消耗金额
function WeekendHappyData:GetWeekendHappyDrawCost()
	local weekend_happy_other_configs = self:GetOtherCfgByOpenDay()
	if nil == weekend_happy_other_configs then
		return nil
	end
	local draw_gold_list = {}
	draw_gold_list.once_gold = weekend_happy_other_configs.lottery1_consume_gold or 0			
	draw_gold_list.tenth_gold = weekend_happy_other_configs.lottery1_ten_consume_gold or 0

	return draw_gold_list
end

-- 获取一抽钥匙道具
function WeekendHappyData:GetWeekendHappyOneKeyNum()
	local weekend_happy_other_configs = self:GetOtherCfgByOpenDay()
	if nil == weekend_happy_other_configs then
		return 0
	end

	local key_id = weekend_happy_other_configs.lottery1_one_consume_item or 0	
	local key_num = ItemData.Instance:GetItemNumInBagById(key_id) or 0
	local key_cfg = ItemData.Instance:GetItemConfig(key_id)
	return key_num, key_cfg
end

-- 获取十抽钥匙道具
function WeekendHappyData:GetWeekendHappyTenKeyNum()
	local weekend_happy_other_configs = self:GetOtherCfgByOpenDay()
	if nil == weekend_happy_other_configs then
		return 0
	end

	local key_id = weekend_happy_other_configs.lottery1_ten_consume_item or 0	
	local key_num = ItemData.Instance:GetItemNumInBagById(key_id) or 0
	local key_cfg = ItemData.Instance:GetItemConfig(key_id)
	return key_num, key_cfg
end

--获取累计奖励配置表
function WeekendHappyData:GetWeekendHappyRewardItemConfig()
	local weekend_happy_activity_reward_cfg = self:GetWeekendHappyRewardConfig()
	if nil == weekend_happy_activity_reward_cfg or nil == self.reward_flag then
		return {}
	end
	local has_got_data_list = {}
	local not_got_data_list = {}
	for k, v in ipairs(weekend_happy_activity_reward_cfg) do
		if self:GetIsFetchFlag(v.seq) then		--self.reward_flag[self.reward_list_length - k + 1] == 1
			table.insert(has_got_data_list, v)
		else
			table.insert(not_got_data_list, v)
		end
	end
	for k1, v1 in ipairs(has_got_data_list) do
		table.insert(not_got_data_list, v1)
	end
	return not_got_data_list
end

-- 获取欢乐摇奖珍稀展示配置
-- function WeekendHappyData:GetHappyErnieRareRewardCfg()
-- 	local happy_ernie_rare_reward = self:GetHappyErnieRareReward()
-- 	return happy_ernie_rare_reward or {}
-- end

--获取协议下的数据
function WeekendHappyData:SetRAWeekendHappyInfo(protocol)
	self.next_free_tao_timestamp = protocol.nex_free_time
    self.chou_times = protocol.person_total_chou_times
    self.reward_flag = bit:d2b(protocol.fetch_person_reward_flag)
    self.reward_list_length = #self.reward_flag
    self.weekend_happy_tao_seq = protocol.chou_item_list
    self.count = protocol.item_count
    if self.count and self.count > 0 then
    	TipsCtrl.Instance:ShowTreasureView(self:GetChestShopMode())
    end
end
-- 协议还没定
--获取协议下的数据
-- function WeekendHappyData:SetRAWeekendHappyTaoResultInfo(protocol)
-- 	self.count = protocol.count
--     self.weekend_happy_tao_seq = protocol.huanleyaojiang_tao_seq
-- end

--获取服务器上的抽奖次数
function WeekendHappyData:GetChouTimes()
	return self.chou_times
end

--获取服务器上的下次免费的时间戳
function WeekendHappyData:GetNextFreeTaoTimestamp()
	return self.next_free_tao_timestamp or 0
end

--是否已领取
function WeekendHappyData:GetIsFetchFlag(index)
	if index ~= nil then
		return (1 == self.reward_flag[self.reward_list_length - index]) and true or false
	end
	return false
end

--获取可获取奖励的抽奖次数
function WeekendHappyData:GetCanFetchFlagByIndex(index)
	local weekend_happy_activity_reward_cfg = self:GetWeekendHappyRewardConfig()
	if nil == weekend_happy_activity_reward_cfg then
		return 0
	end
	for k, v in pairs(weekend_happy_activity_reward_cfg) do
		if index == v.seq then
			return v.person_chou_times or 0		--配置还没定
		end
	end
	return 0
end

--设置奖励展示框模式
function WeekendHappyData:SetChestShopMode(mode)
	self.chest_shop_mode = mode
end

--获取奖励展示框模式
function WeekendHappyData:GetChestShopMode()
	return self.chest_shop_mode
end

--获取奖励展示框的格子数量
function WeekendHappyData:GetChestCount()
	return self.count
end

--获取奖励展示框的信息
function WeekendHappyData:GetChestShopItemInfo()
	local data = {}
	for i = 1, self.count do
		if self.weekend_happy_tao_seq and self.weekend_happy_tao_seq[i] then
			local tao_seq = self.weekend_happy_tao_seq[i]
			local color = 0
			local item_cfg = ItemData.Instance:GetItemConfig(tao_seq.item_id)
			if item_cfg and item_cfg.color then
				color = item_cfg.color
			end
			tao_seq.noindex_show_xianpin = true
			tao_seq.color = color
			if tao_seq.xianpin_type_list then
				for k, v in pairs(tao_seq.xianpin_type_list) do
					if v == 0 then
						tao_seq.xianpin_type_list[k] = nil
					end
				end
				tao_seq.param = {}
				tao_seq.param.xianpin_type_list = tao_seq.xianpin_type_list
			end
			table.insert(data, tao_seq)
		end
	end
	table.sort(data, SortTools.KeyUpperSorter("color"))
	return data
end

--红点提示
function WeekendHappyData:GetWeekendHappyRemind()
	local weekend_happy_activity_reward_cfg = self:GetWeekendHappyRewardConfig()
	if nil == weekend_happy_activity_reward_cfg or nil == self.reward_flag then
		return 0
	end
	-- 是否有免费次数
	local next_free_tao_timestamp = self:GetNextFreeTaoTimestamp()
	local server_time = TimeCtrl.Instance:GetServerTime()

	if next_free_tao_timestamp < server_time then
		return 1
	end

	-- 是否有摇奖钥匙
	local ten_key_num = self:GetWeekendHappyTenKeyNum()
	if ten_key_num > 0 then
		return 1
	end

	local one_key_num = self:GetWeekendHappyOneKeyNum()
	if one_key_num > 0 then
		return 1
	end

	-- 是否有可领取奖励
	local get_reward_times = 0
	for k, v in pairs(self.reward_flag) do
		if v == 1 then
			get_reward_times = get_reward_times + 1
		end
	end
	local can_reward_times = 0
	for k, v in pairs(weekend_happy_activity_reward_cfg) do
		if self.chou_times >= v.person_chou_times then

			if v.seq ~= nil then
				can_reward_times = v.seq + 1
			end
		end
	end
	return can_reward_times > get_reward_times and 1 or 0
end

--主界面红点刷新
function WeekendHappyData:FlushHallRedPoindRemind()
	-- local remind_num = self:GetWeekendHappyRemind()
	-- if remind_num > 0 then
	-- 	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WEEKENDHAPPY, true)
	-- else
	-- 	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WEEKENDHAPPY, not self.is_open)
	-- end
end

function WeekendHappyData:SetIsOpen()
	self.is_open = true
end
