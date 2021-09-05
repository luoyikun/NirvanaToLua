FanFanZhuanData = FanFanZhuanData or BaseClass()

function FanFanZhuanData:__init()
	if FanFanZhuanData.Instance then
		print_error("[FanFanZhuanData] Attemp to create a singleton twice !")
	end
	FanFanZhuanData.Instance = self
	-- 先转成二阶数组

	self.fanfanzhuan_info = {}
	self.return_reward_list = {}
	self.cur_level = 0
	self.treasuer_item_list = {}
	self.draw_times = {}
	self.return_reward_flag = 0
	RemindManager.Instance:Register(RemindName.RemindFanFanZhuan, BindTool.Bind(self.GetFanFanZhuanRemind, self))
end

function FanFanZhuanData:__delete()
	RemindManager.Instance:UnRegister(RemindName.RemindFanFanZhuan)
	FanFanZhuanData.Instance = nil
end

function FanFanZhuanData:SetKingDrawInfoInfo(protocol)
	self.fanfanzhuan_info = protocol.card_list
	self.draw_times = protocol.draw_times
	self.return_reward_flag = protocol.return_reward_flag
end

function FanFanZhuanData:GetKingDrawInfoInfo()
	return self.fanfanzhuan_info
end

function FanFanZhuanData:GetDrawTimesByLevel(level)
	return self.draw_times[level] or 0
end

function FanFanZhuanData:GetRewardFlag()
	return self.return_reward_flag
end

function FanFanZhuanData:GetinfoByLevelAndIndex(level, index)
	if nil == self.fanfanzhuan_info[level] then
		return -1
	end

	return self.fanfanzhuan_info[level][index] or -1
end

function FanFanZhuanData:GetRewardByLevelAndIndex(level, index)
	if nil == self.config then
		self.config = {}
		local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().king_draw
		config = ActivityData.Instance:GetRandActivityConfig(config, ACTIVITY_TYPE.RAND_ACTIVITY_FANFANZHUAN)
		for k,v in pairs(config) do
			if nil == self.config[v.level] then
				self.config[v.level] = {}
			end
			self.config[v.level][v.seq] = v
		end
	end

	if nil == self.config[level] then
		return {}
	end

	return self.config[level][index] or {}
end

-- 获得要展示的物品
function FanFanZhuanData:GetShowRewardCfgByOpenDay()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().king_draw
	local show_list = {}
	local day_flag = -1
	for k,v in ipairs(config) do
		if open_day <= v.opengame_day and v.is_onshow == 1 then
			if day_flag ~= -1 and v.opengame_day ~= day_flag then
				break
			end
			table.insert(show_list, v.reward_item)

			day_flag = v.opengame_day
		end
	end

	return show_list
end

-- 获得稀有展示的物品
function FanFanZhuanData:GetRareRewardCfgByOpenDay(cur_level)
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().king_draw
	local show_list = {}
	local day_flag = -1
	for k,v in ipairs(config) do
		if open_day <= v.opengame_day and v.level == cur_level and v.is_rare == 1 then
			if day_flag ~= -1 and v.opengame_day ~= day_flag then
				break
			end
			table.insert(show_list, v.reward_item)

			day_flag = v.opengame_day
		end
	end

	return show_list
end

function FanFanZhuanData:ClearReturnRewardList()
	self.return_reward_list = {}
end

-- 销毁界面的时候会调用ClearReturnRewardList清除self.return_reward_list表
function FanFanZhuanData:GetReturnRewardByLevel(level)
	local return_reward_list = {}
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().king_draw_return_reward
	local day_flag = -1
	for i,v in pairs(config) do
		if v.level == level and open_day <= v.opengame_day then
			if day_flag ~= -1 and v.opengame_day ~= day_flag then
				break
			end
			table.insert(return_reward_list, v)

			day_flag = v.opengame_day
		end
	end

	return return_reward_list
end

function FanFanZhuanData:GetReturnRewardByLevelSort(level)
	local return_reward_list = {}
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().king_draw_return_reward
	local day_flag = -1
	for i,v in pairs(config) do
		if v.level == level and open_day <= v.opengame_day then
			if day_flag ~= -1 and v.opengame_day ~= day_flag then
				break
			end
			table.insert(return_reward_list, TableCopy(v))

			day_flag = v.opengame_day
		end
	end

	local draw_times = FanFanZhuanData.Instance:GetDrawTimesByLevel(level)
	for k, v in pairs(return_reward_list) do
		if v.draw_times <= draw_times then
			local reward_flag = FanFanZhuanData.Instance:GetIsGetReward(level, k)
			if reward_flag == 1 then
				v.get_reward = 2
			else
				v.get_reward = 0
			end
		else
			v.get_reward = 1
		end
		v.index_cfg = k
	end

	table.sort(return_reward_list, SortTools.KeyLowerSorter("get_reward", "index_cfg"))

	return return_reward_list
end

-- function FanFanZhuanData:GetReturnReward(level)
-- 	local return_reward_list = self:GetReturnRewardByLevel(level)
-- 	local return_reward_flag = bit:d2b(self.return_reward_flag)
-- 	local sort_list = {}
-- 	local return_list = {}
-- 	for k,v in pairs(return_reward_list) do
-- 		local temp_list = {}
-- 		temp_list.cfg = v
-- 		temp_list.fetch_flag = return_reward_flag[32 - k + 1]
-- 		table.insert(return_list, temp_list)
-- 	end
-- 	for k,v in pairs(return_list) do
-- 		if v.fetch_flag == 0 then
-- 			table.insert(sort_list, v)
-- 		end
-- 	end
-- 	for k,v in pairs(return_list) do
-- 		if v.fetch_flag == 1 then
-- 			table.insert(sort_list, v)
-- 		end
-- 	end
-- 	return sort_list
-- end



function FanFanZhuanData:SetCurLevel(level)
	self.cur_level = level
end

function FanFanZhuanData:GetCurLevel()
	return self.cur_level
end

function FanFanZhuanData:SetTreasureItemList(list)
	self.treasuer_item_list = list
end

function FanFanZhuanData:GetTreasureItemList()
	return self.treasuer_item_list
end

function FanFanZhuanData:GetIsGetReward(level, index)
	local reward_flag_t = bit:d2b(self.return_reward_flag)
	-- 三个级别用一个return_reward_flag， 1~10为初级，11~20为中极，21~30为高级
	local flag_index = level * 10 + index
	local flag_t = {}
	return reward_flag_t[33 - flag_index]
end

function FanFanZhuanData:GetFanFanZhuanRemind()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_FANFANZHUAN)
	if not is_open then return 0 end

	local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local item_num = ItemData.Instance:GetItemNumInBagById(randact_cfg.other[1].king_draw_gaoji_consume_item)
	local is_red = false
	for i = 0, 2 do
		is_red = self:GetCastRemind(i)
		if is_red then
			break
		end
	end

	if is_red then
		item_num = 1
	end

	return item_num > 0 and 1 or 0
end

function FanFanZhuanData:GetCastRemind(cur_level)
	local is_red = false
	local return_reward_list = self:GetReturnRewardByLevel(cur_level)
	local draw_times = self:GetDrawTimesByLevel(cur_level)
	for i,v in ipairs(return_reward_list) do
		local is_reward = self:GetIsGetReward(cur_level, i)
		if draw_times >= v.draw_times and is_reward == 0 then
			is_red = true
			break
		end
	end
	return is_red
end
