OneYuanBuyData = OneYuanBuyData or BaseClass()
OnYuanBuyMaxType = 3
function OneYuanBuyData:__init()
	if OneYuanBuyData.Instance then
		print_error("[OneYuanBuyData] attempt to create singleton twice!")
		return
	end

	OneYuanBuyData.Instance = self
	self.zero_buy_return_buy_timestamp = {}
	self.zero_buy_return_day_fetch_flag_list = {}
	self.zero_buy_return_day_fetch_flag = {}
	self.is_first_open = true
	RemindManager.Instance:Register(RemindName.OneYuanBuy, BindTool.Bind1(self.GetOneYuanBuyRemind, self))
end

function OneYuanBuyData:__delete()
	RemindManager.Instance:UnRegister(RemindName.OneYuanBuy)
	OneYuanBuyData.Instance = nil
end

function OneYuanBuyData:GetOneYuanBuyShowCfg(tab_index)
	local zero_buy_cfg = self:GetOneYuanBuyCfg()
	local num = 0
	local cur_type = -1
	for i,v in ipairs(zero_buy_cfg) do
		if v.show_type == tab_index and v.buy_type and v.buy_type ~= cur_type then
			cur_type = v.buy_type 
			num = num + 1
		end
	end
	return num
end

function OneYuanBuyData:GetOneYuanBuyCfg()
	local rand_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	if rand_cfg then
		return rand_cfg.zero_buy_return
	end
	return {}
end

function OneYuanBuyData:GetOneYuanBuyShowCfgByTyp(buy_type)
	local cfg = self:GetOneYuanBuyCfg()
	local show_cfg = {}
	if buy_type and cfg then
		for k,v in pairs(cfg) do
			if v.buy_type == buy_type then
				table.insert(show_cfg, v)
			end
		end
	end
	return show_cfg
end

function OneYuanBuyData:GetOneYuanBuyShowCfgByTypeAndFetchDay(buy_type, fecth_day)
	local cfg = self:GetOneYuanBuyCfg()
	local show_cfg = {}
	if cfg then
		for k,v in pairs(cfg) do
			if v.buy_type and v.fecth_day then
				if buy_type == v.buy_type and v.fecth_day == fecth_day then
					show_cfg = v
				end
			end
		end
	end
	return show_cfg
end

function OneYuanBuyData:SetZeroBuyReturnInfo(protocol)
	self.zero_buy_return_buy_timestamp = protocol.zero_buy_return_buy_timestamp
	self.zero_buy_return_day_fetch_flag = protocol.zero_buy_return_day_fetch_flag

	if self.zero_buy_return_day_fetch_flag then
		for k,v in pairs(self.zero_buy_return_day_fetch_flag) do
			self.zero_buy_return_day_fetch_flag_list[k] = {}
			self.zero_buy_return_day_fetch_flag_list[k] = bit:d2b(v)
		end
	end
end

function OneYuanBuyData:GetZeroBuyReturnTimeStamp()
	return self.zero_buy_return_buy_timestamp
end

function OneYuanBuyData:GetZeroBuyReturnFetchList(index)
	if index and self.zero_buy_return_day_fetch_flag_list then
		return self.zero_buy_return_day_fetch_flag_list[index]
	end
	return nil
end

function OneYuanBuyData:GetZeroBuyFetchDayByIndex(index)
	local fetch_index = 0
	if self.zero_buy_return_buy_timestamp then
		local server_time = TimeCtrl.Instance:GetServerTime()
		for k,v in pairs(self.zero_buy_return_buy_timestamp) do
			if k == index then
				if v and v > 0 then
					if server_time - v >= 0 then
						local start_time = TimeUtil.NowDayTimeStart(v)
						local max_num = self:GetMaxRewardDay(index)
						fetch_index = math.floor((server_time - start_time) / 3600 / 24)
						if fetch_index >= max_num then
							fetch_index = max_num
						end
					end
				end
			end
		end
	end
	return fetch_index
end


function OneYuanBuyData:GetOneYuanBuyCanRewardNum(index, fecth_day)
	local num = 0
	if index and fecth_day then
		local cfg = self:GetOneYuanBuyShowCfgByTyp(index)
		if cfg then
			for k,v in pairs(cfg) do
				if v.fecth_day <= fecth_day then
					num = num + v.daily_reward_gold
				end
			end
		end
	end
	return num
end

function OneYuanBuyData:GetLeiJiRewardNumByIndex(index)
	local num = 0
	local day = 0
	if index then
		local show_cfg = self:GetOneYuanBuyShowCfgByTyp(index)
		if show_cfg then
			for k,v in pairs(show_cfg) do
				if v.fecth_day then
					if self.zero_buy_return_day_fetch_flag_list[index] then
						if self.zero_buy_return_day_fetch_flag_list[index][32 - v.fecth_day] >= 1 then
							num = num + v.daily_reward_gold
							day = day + 1
						end
					end
				end
			end
		end
	end
	return num, day
end

function OneYuanBuyData:GetMaxLeiJiRewardNumByIndex(index)
	local num = 0
	if index then
		local show_cfg = self:GetOneYuanBuyShowCfgByTyp(index)
		if show_cfg then
			for k,v in pairs(show_cfg) do
				num = num + v.daily_reward_gold
			end
		end
	end
	return num
end

function OneYuanBuyData:GetOneYuanBuyRemind()
	if self.zero_buy_return_buy_timestamp then
		for k,v in pairs(self.zero_buy_return_buy_timestamp) do
			local server_time = TimeCtrl.Instance:GetServerTime()
			local fetch_index = 0
			if v and v > 0 then
				local start_time = TimeUtil.NowDayTimeStart(v)
				fetch_index = math.floor((server_time - start_time) / 3600 / 24)
				local fetch_list = self:GetZeroBuyReturnFetchList(k)
				local max_index = self:GetMaxRewardDay(k)
				if fetch_index > max_index then
					fetch_index = max_index
				end
				if fetch_list then
					if fetch_list[32 - fetch_index] <= 0 then
						return 1
					end
				end
			end
		end
	end
	return 0
end

function OneYuanBuyData:GetMaxRewardDay(index)
	local max_num = 0
	local cur_list = {}
	if index then
		local show_cfg = self:GetOneYuanBuyCfg()
		if show_cfg then
			for k,v in ipairs(show_cfg) do
				if v.buy_type == index then
					table.insert(cur_list, v)
				end
			end
		end
	end
	if #cur_list > 0 then
		max_num = cur_list[#cur_list].fecth_day
	end
	return max_num
end

function OneYuanBuyData:GetIsNoBuy()
	if self.zero_buy_return_buy_timestamp then
		for k,v in pairs(self.zero_buy_return_buy_timestamp) do
			if v and v > 0 then
				return false
			end
		end
	end
	return true
end

function OneYuanBuyData:IsNotAllBuy()
	if self.zero_buy_return_buy_timestamp then
		for k,v in pairs(self.zero_buy_return_buy_timestamp) do
			if k <= OnYuanBuyMaxType then
				if v and v <= 0 then
					return true
				end
			end
		end
	end
	return false
end

function OneYuanBuyData:GetIsShowOneYuanBuyData()
	if self.zero_buy_return_buy_timestamp then
		local server_time = TimeCtrl.Instance:GetServerTime()
		local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ONEYUANBUYVIEW)
		for k,v in pairs(self.zero_buy_return_buy_timestamp) do
			if v then
				if v <= 0 and is_open then
					return true
				elseif v > 0 then
					if server_time - v >= 0 then
						local start_time = TimeUtil.NowDayTimeStart(v)
						local fetch_index = math.floor((server_time - start_time) / 3600 / 24)
						local max_num = self:GetMaxRewardDay(k)
						if fetch_index > max_num then
							fetch_index = max_num
						end
						if fetch_index < max_num then
							return true
						elseif fetch_index == max_num then
							if self.zero_buy_return_day_fetch_flag_list[k] then
								if self.zero_buy_return_day_fetch_flag_list[k][32- fetch_index] <= 0 then
									return true
								end
							end
						end
					end
				end
			end
		end
	end
	return false
end


function OneYuanBuyData:GetLeiJiRewardNum(index, fecth_day)
	local num = 0
	if index and fecth_day then
		local cfg = self:GetOneYuanBuyCfg()
		if cfg then
			for k,v in pairs(cfg) do
				if v.buy_type and v.buy_type == index then
					if v.fecth_day and v.fecth_day <= fecth_day then
						num = num + v.daily_reward_gold
					end
				end
			end
		end
	end
	return num
end

function OneYuanBuyData:SetOneYuanBuyFirstOpen(enabled)
	self.is_first_open = enabled
end

function OneYuanBuyData:GetOneYuanBuyFirstOpen()
	local is_not_any_buy = self:IsNotAllBuy()
	return self.is_first_open and is_not_any_buy
end

function OneYuanBuyData:GetShowTabRemind()
	for i=0,2 do
		if 1 == self:GetIsShowTabRemind(i) then
			return 1
		end
	end
	return 0
end

function OneYuanBuyData:GetIsShowTabRemind(index)
	local fetch_day = self:GetZeroBuyFetchDayByIndex(index)
	local timestamp_list = self:GetZeroBuyReturnTimeStamp()
	local timestamp = timestamp_list and timestamp_list[index] or 0
	local can_reward_num = self:GetOneYuanBuyCanRewardNum(index, fetch_day)
	local num = 0
	if timestamp <= 0 then
		num = self:GetMaxLeiJiRewardNumByIndex(index) or 0
	else
		num = self:GetLeiJiRewardNumByIndex(index) or 0
	end
	if can_reward_num - num > 0 then
		return 1
	end
	return 0
end