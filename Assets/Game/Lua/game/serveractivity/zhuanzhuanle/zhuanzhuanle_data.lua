ZhuangZhuangLeData = ZhuangZhuangLeData or BaseClass()

function ZhuangZhuangLeData:__init()
	if ZhuangZhuangLeData.Instance ~= nil then
		ErrorLog("[ZhuangZhuangLeData] Attemp to create a singleton twice !")
	end
	ZhuangZhuangLeData.Instance = self
	self.is_can_play_ani = true
	self.money_tree_free_timestamp = 0
	RemindManager.Instance:Register(RemindName.ZHUANZHUANLE, BindTool.Bind(self.GetZhuanCount, self))
end

function ZhuangZhuangLeData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ZHUANZHUANLE)
	ZhuangZhuangLeData.Instance = nil
end

function ZhuangZhuangLeData:CanGetRewardBySeq(index)
   local seq_list = self:GetGridLotteryTreeAllRewardData()
   if self.server_total_money_tree_times >= seq_list[index].server_rock_times then 
	  return true
   else return false  
   end
end

function ZhuangZhuangLeData:GetRewardBySeq(seq)
	-- local seq_list = self:GetGridLotteryTreeAllRewardData()
	local seq_list = self:GetGridLotteryTreeAllRewardSortData()
	for k,v in pairs(seq_list) do
		if v.seq == seq then
			local data = {}
			local wdata = {}
			data.item_id = v.item_id
			data.is_bind = v.is_bind
			data.num = v.num
			wdata[1] = data
			return wdata
		end
	end
	return {}
end

function ZhuangZhuangLeData:GetOtherCfg()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().yaoqianshu 
end 

function ZhuangZhuangLeData:GetCurDayConfig()
	local zhuanzhuanle_cfg = {}
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	if nil == cfg then
		return zhuanzhuanle_cfg
	end
	zhuanzhuanle_cfg = ActivityData.Instance:GetRandActivityConfig(cfg.yaoqianshu, ACTIVITY_TYPE.RAND_LOTTERY_TREE) or {}
	return zhuanzhuanle_cfg
end

function ZhuangZhuangLeData:SetZhuanZhuanLeInfo(protocol)
	self.money_tree_info = protocol
end

function ZhuangZhuangLeData:GetZhuanZhuanLeInfo()
	if self.money_tree_info  then
	   return  self.money_tree_info
	end
	return {}
end

function ZhuangZhuangLeData:SetMoneyTreeInfo(protocol)
	self.server_total_money_tree_times = protocol.money_tree_total_times
	self.server_total_money_tree_pool_gold = protocol.server_total_pool_gold
	self.money_tree_free_timestamp = protocol.money_tree_free_timestamp
	self.server_reward_has_fetch_reward_flag =  bit:d2b(protocol.server_reward_has_fetch_reward_flag)
end

function ZhuangZhuangLeData:SetMoneyTreeChouResultInfo(protocol)
	self.money_tree_reward_list = protocol.reward_req_list
	self.reward_req_list_count = protocol.reward_req_list_count
end

function ZhuangZhuangLeData:GetRewardList()
	 return self.money_tree_reward_list or {} 
end

function ZhuangZhuangLeData:GetServerMoneyTreeTimes()
	return self.server_total_money_tree_times or 0
end

function ZhuangZhuangLeData:GetServerMoneyTreePoolGold()
	return self.server_total_money_tree_pool_gold or 0
end

function ZhuangZhuangLeData:GetGridLotteryTreeData()
	local act_cfg = self:GetOtherCfg()
	if nil == act_cfg.money_tree then  return end

	local data_list = {}
	local index = 0
	for k,v in pairs(act_cfg.money_tree) do
		if index == 0 then
			local item = {}
			item.item_id = 65534
			item.num = 1
			item.is_bind = 1
			data_list[index] = item
			index = index + 1
		elseif 0 == v.cfg_type and 1 == v.show_item then
			data_list[index] = v.reward_item
			index = index + 1
		end
	end
	return data_list
end

function ZhuangZhuangLeData:GetGridLotteryTreeAllRewardData()
	local act_cfg = self:GetOtherCfg()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if nil == self.server_reward_has_fetch_reward_flag then return {} end
	local data_list = {}
	local index = 1
	for k,v in pairs(act_cfg) do
		if 1 == v.cfg_type and 1 == v.show_item and open_day <= v.opengame_day then
			local data = {}
			data.seq = v.seq
			data.item_id = v.reward_item.item_id
			data.is_bind = v.reward_item.is_bind
			data.num = v.reward_item.num
			if self.server_reward_has_fetch_reward_flag[32 - index + 1] then
				data.fetch_reward_flag = self.server_reward_has_fetch_reward_flag[32 - index + 1]
			end
			data.server_rock_times = v.server_rock_times
			data.vip_limit = v.vip_limit
			data_list[index] = data
			index = index + 1
		end
	end
	return data_list
end

function ZhuangZhuangLeData:GetGridLotteryTreeAllRewardSortData()			-- 上面的方法遍历了所有奖励，不知道为啥
	local leiji_reward = self:GetGridLotteryTreeAllRewardData()
	local reward_list = {}
	local sort_list = {}
	for i = 1,6 do
		if leiji_reward[i] then
			table.insert(reward_list, leiji_reward[i])
		end
	end
	for k,v in pairs(reward_list) do
		if v.fetch_reward_flag == 0 then
			table.insert(sort_list, v)
		end
	end
	for k,v in pairs(reward_list) do
		if v.fetch_reward_flag == 1 then
			table.insert(sort_list, v)
		end
	end
	return sort_list
end

function ZhuangZhuangLeData:GetGridLotteryTreeRewardData()
	local act_cfg = self:GetCurDayConfig()
	if nil == self.money_tree_reward_list then return end
	local data_list = {}
	local index = 1
	for i, m in pairs(self.money_tree_reward_list) do
		for k,v in pairs(act_cfg) do
			if v.seq == m and v.cfg_type == 0 then
				local data = {}
				data.item_id = v.reward_item.item_id
				data.num = v.reward_item.num
				data.is_bind = v.reward_item.is_bind
				if type(v.prize_pool_percent) == "number" and v.prize_pool_percent > 0 then
					data.item_id = 65534
					data.num = 1
					data.is_bind = 1
				end

				if self.is_use_lottery_tree_item == 1 then
					data.is_bind = 1
				end
				data_list[index] = data
				index = index + 1
				break
			end
		end
	end
	return data_list
end

-- 保持玩家领取累计奖励的seq
function ZhuangZhuangLeData:SetLinRewardSeq(seq_index)
	self.seq_index = seq_index
end

function ZhuangZhuangLeData:GetLinRewardSeq()
	return self.seq_index or 0
end

function ZhuangZhuangLeData:SetFreeTime(day_count)
	self.day_count = day_count
end

function ZhuangZhuangLeData:GetFreeTime()
	return self.day_count or 0
end

function ZhuangZhuangLeData:SetAniState(value)
	self.is_can_play_ani = not value
end

function ZhuangZhuangLeData:GetAniState(value)
	return self.is_can_play_ani
end

function ZhuangZhuangLeData:GetMianFeiTime()
	-- 下次免费时间
	local time = math.max(TimeCtrl.Instance:GetServerTime() - self.money_tree_free_timestamp, 0)
	time = math.floor(time)
	return time
end

function ZhuangZhuangLeData:GetRewardInfo()
	local allaTreeTime = self:GetServerMoneyTreeTimes()
	local reward_cfg = self:GetGridLotteryTreeAllRewardData()
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	for i = 1, 6 do
		if reward_cfg[i] and allaTreeTime >= reward_cfg[i].server_rock_times then
			if vip_level >= reward_cfg[i].vip_limit then
				if self.server_reward_has_fetch_reward_flag[32 - i + 1] == 0 then
					return 1
				end
			end
		end
	end
	return 0
end

function ZhuangZhuangLeData:GetZhuanCount()
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_LOTTERY_TREE) then
		return 0
	end
	
	local mianfei = self:GetMianFeiTime()
	local other_cfg =  ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1]
	local lengque_time = other_cfg.money_tree_free_interval
	local free_times = other_cfg.money_tree_free_times
	local used_times = self:GetFreeTime()
	local flag = self:GetRewardInfo()
	if lengque_time <= mianfei and used_times < free_times then
		return 1
	end
	if flag == 1 then
		return 1
	end 

	local key_remind = self:GetKeyRemind()
	if key_remind > 0 then
		return 1
	end

	return 0
end

function ZhuangZhuangLeData:ZhuanZhaunLePoindRemind()
	local remind_num = self:GetZhuanCount()
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_LOTTERY_TREE, remind_num > 0)
end

--返回活动结束时间 
function ZhuangZhuangLeData:GetActEndTime()
	local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_LOTTERY_TREE)
	if act_info then
		local next_time = act_info.next_time
		local time = math.max(next_time - TimeCtrl.Instance:GetServerTime() , 0)
		return time
	end
	return 0
end

function ZhuangZhuangLeData:GetKeyRemind()
	local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local item_id = randact_cfg.other[1].money_tree_consume_item
	local item_num = ItemData.Instance:GetItemNumInBagById(item_id)
	return item_num > 0 and 1 or 0
end
