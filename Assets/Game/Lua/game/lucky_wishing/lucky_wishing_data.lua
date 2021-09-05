LuckWishingData = LuckWishingData or BaseClass()

function LuckWishingData:__init()
	if LuckWishingData.Instance ~= nil then
		print("[LuckWishingData] attempt to create singleton twice!")
		return		
	end
	LuckWishingData.Instance = self
	self.lucky_info = {}
	self.is_shield = false
	self.chest_shop_mode = -1

	RemindManager.Instance:Register(RemindName.LuckWishing, BindTool.Bind(self.GetLuckyWishRemind, self))
end

function LuckWishingData:__delete()
	RemindManager.Instance:UnRegister(RemindName.LuckWishing)
	LuckWishingData.Instance = nil
	self.chest_shop_mode = nil
end

function LuckWishingData:UpdateInfoData(protocol)
	self.lucky_info.item_id_list = protocol.item_list
	self.lucky_info.lucky_value = protocol.lucky_value
end

function LuckWishingData:GetLuckyInfo()
	return self.lucky_info
end

--获取奖励展示框的信息
function LuckWishingData:GetChestShopItemInfo()
	local data = {}
	for k, v in pairs(self.lucky_info.item_id_list) do
		if v and v.item_id ~= 0 then
			local color = 0
			local cfg = ItemData.Instance:GetItemConfig(v.item_id)
			if cfg and cfg.color then
				color = cfg.color 
			end
			local item = DeepCopy(v)
			item.color = color
			table.insert(data, item)
		end
	end
	-- table.sort(data, SortTools.KeyUpperSorter("color"))		--暂时屏蔽排序
	return data
end

function LuckWishingData:GetEveryDayRewardShowData()
	local day = nil
	local rand_t = {}
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	if randact_cfg.lucky_wish_everyday == nil then return end
	local cfg = randact_cfg.lucky_wish_everyday
	for k,v in ipairs(cfg) do
		if v.opengame_day and open_day <= v.opengame_day then
			table.insert(rand_t, v)
		end
	end

	return rand_t
end

function LuckWishingData:GetBigRewardShowData()
	local day = nil
	local rand_t = {}
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	if randact_cfg.lucky_wish_big_reward == nil then return end
	local cfg = randact_cfg.lucky_wish_big_reward 
	if cfg and next(cfg) then
		local active_day = open_day % #cfg
		active_day = active_day == 0 and #cfg or active_day
		for k,v in ipairs(cfg) do
			if active_day and v.opengame_day == active_day then
				table.insert(rand_t, v)
			end
		end
	end
	return rand_t[0] or rand_t[1] 
end

--设置奖励展示框模型
function LuckWishingData:SetChestShopMode(mode)
	self.chest_shop_mode = mode
end

--获取奖励展示框模型
function LuckWishingData:GetChestShopMode()
	return self.chest_shop_mode
end

function LuckWishingData:GetIsShield()
	return self.is_shield
end

function LuckWishingData:SetIsShield(is_shield)
	self.is_shield = is_shield
end


function LuckWishingData:GetActivitytimes()
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LUCKY_WISH) then
		local chongzhi_time_table = os.date('*t', TimeCtrl.Instance:GetServerTime())
		local chongzhi_cur_time = chongzhi_time_table.hour * 3600 + chongzhi_time_table.min * 60 + chongzhi_time_table.sec
		local time = 24 * 3600 - chongzhi_cur_time
		return time
	end
	return 0
end

function LuckWishingData:GetLuckyWishRemind()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LUCKY_WISH)
	if not is_open then return 0 end

	local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local item_num = ItemData.Instance:GetItemNumInBagById(randact_cfg.other[1].lucky_wish_30_times_use_item)
	if item_num > 0 then
		return 1
	end
	return 0
end
