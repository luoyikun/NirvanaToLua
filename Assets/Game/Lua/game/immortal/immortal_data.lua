ImmortalData = ImmortalData or BaseClass()
XIANZUNKA_TYPE_MAX = 3
function ImmortalData:__init()
	if ImmortalData.Instance then
		print_error("[ImmortalData] attempt to create singleton twice!")
		return
	end

	ImmortalData.Instance = self
	self.user_info = {}
	self.open_remind_num = 0
	self.forever_active_flag = 0
	self.first_active_reward_flag = 0
	self.daily_reward_fetch_flag = 0
	self.temporary_valid_end_timestamp_list = {}

	-- self.card_cfg = ConfigManager.Instance:GetAutoConfig("fairybuddhacardcfg_auto").fairy_buddha_card
	-- self.card_desc_cfg = ConfigManager.Instance:GetAutoConfig("fairybuddhacardcfg_auto").fairy_description
	-- self.card_desc_cfg = ListToMap(desc_cfg, "card_type")
	self.xianzunka_addition_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("xianzunka_auto").xianzunka_addition_cfg, "card_type")
	RemindManager.Instance:Register(RemindName.ImmortalCard, BindTool.Bind1(self.GetXianzunkaRemind, self))
	RemindManager.Instance:Register(RemindName.ImmortalLabel, BindTool.Bind(self.RemindLabel, self))


	self.small_icon_open_level = {
		[140] = true, [190] = true, [210] = true
	}
	self.count_down = {}
	if self.xianzunka_addition_cfg ~= nil then
		for k, v in pairs(self.xianzunka_addition_cfg) do
			self.count_down[k] = nil
		end
	end

	self.player_data_change = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.player_data_change)
end

function ImmortalData:__delete()
	if self.player_data_change then
		PlayerData.Instance:UnlistenerAttrChange(self.player_data_change)
		self.player_data_change = nil
	end

	self.card_cfg = nil
	self.card_desc_cfg = nil
	RemindManager.Instance:UnRegister(RemindName.ImmortalCard)
	RemindManager.Instance:UnRegister(RemindName.ImmortalLabel)
	ImmortalData.Instance = nil

	for k, v in pairs(self.count_down) do 
		if v ~= nil then
			GlobalTimerQuest:CancelQuest(v)
			v = nil
		end
	end
	self.count_down = nil
end

function ImmortalData:GetAdditionCfg(card_type)
	return self.xianzunka_addition_cfg[card_type]
end

function ImmortalData:GetImmortalCfg()
	return ConfigManager.Instance:GetAutoConfig("xianzunka_auto").xianzunka_base_cfg
end

function ImmortalData:SetXianZunKaInfo(protocol)
	self.forever_active_flag = protocol.forever_active_flag
	self.first_active_reward_flag = protocol.first_active_reward_flag
	self.daily_reward_fetch_flag = protocol.daily_reward_fetch_flag
	self.temporary_valid_end_timestamp_list = protocol.temporary_valid_end_timestamp_list
	self:OverFlushTimer()
end

function ImmortalData:GetCardEndTimestamp(card_type)
	return self.temporary_valid_end_timestamp_list[card_type] or 0
end

function ImmortalData:OverFlushTimer()
	local timestamp = {}
	if self.xianzunka_addition_cfg ~= nil then
		for k, v in pairs(self.xianzunka_addition_cfg) do
			timestamp[k] = self:GetCardEndTimestamp(k)
		end
	end
	local server_time = TimeCtrl.Instance:GetServerTime()
	for k, v in pairs(timestamp) do
		if v - server_time > 0 then
			self:SetCountDown(k, v - server_time)
		end
	end
end

function ImmortalData:SetCountDown(card_type, timestamp)
	if card_type ~= nil and timestamp ~= nil then
		self:CancelCoutDown(card_type)
		self.count_down[card_type] = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.CountDownTime, self, card_type), timestamp)
	end
end

function ImmortalData:CountDownTime(card_type)
	self:CancelCoutDown(card_type)
	local active_list = self:GetActiveList()
	if active_list[card_type] then
		self:SetCountDown(card_type, 2)
	end
	MainUICtrl.Instance:FlushImmortalIcon()
end

function ImmortalData:CancelCoutDown(card_type)
	if self.count_down[card_type] ~= nil then
		GlobalTimerQuest:CancelQuest(self.count_down[card_type])
		self.count_down[card_type] = nil
	end
end

function ImmortalData:GetLimitTimestamp()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local start_time = main_role_vo.create_role_time or 0
	local cfg = self:GetImmortalCfg()
	local limit_time = cfg.free_time_limit or 5400
	local limit_timestamp = start_time + limit_time
	return limit_timestamp or 0
end

function ImmortalData:IsActiveForever(card_type)
	return bit:_and(1, bit:_rshift(self.forever_active_flag, card_type)) ~= 0
end

function ImmortalData:GetForeverGold(card_type)
	local cfg = self:GetImmortalCfg()
	if cfg and cfg[card_type + 1] then
		return cfg[card_type + 1].active_chong_zhi
	end
	return 0
end

function ImmortalData:GetForeverActivityIsOpen()
	return ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_IMMORTAL_FOREVER)
end

function ImmortalData:RemindLabel()
	if self:GetForeverActivityIsOpen() and not RemindManager.Instance:RemindToday(RemindName.ImmortalLabel) then
		for i = 0, 2 do
			if not self:IsActiveForever(i) then
				return 1
			end
		end
	end
	return 0
end

function ImmortalData:IsActive(card_type)
	local timestamp = self.temporary_valid_end_timestamp_list[card_type] or 0
	return timestamp > TimeCtrl.Instance:GetServerTime()
end

function ImmortalData:IsActiveAll()
	for i = 0, 2 do
		if not self:IsActive(i) then
			return false
		end
	end
	return true
end

function ImmortalData:IsFirstActive(card_type)
	return bit:_and(1, bit:_rshift(self.first_active_reward_flag, card_type)) ~= 0
end

function ImmortalData:IsDailyReward(card_type)
	return bit:_and(1, bit:_rshift(self.daily_reward_fetch_flag, card_type)) ~= 0
end

function ImmortalData:GetXianzunkaRemind()
	-- for k,v in pairs(ConfigManager.Instance:GetAutoConfig("xianzunka_auto").xianzunka_base_cfg) do
	-- 	if (self:IsActive(v.card_type) or self:IsActiveForever(v.card_type)) and not self:IsDailyReward(v.card_type) then
	-- 		return 1
	-- 	end
	-- 	if self:IsActive(v.card_type) and not self:IsActiveForever(v.card_type) then
	-- 		if ItemData.Instance:GetItemNumInBagById(v.active_item_id) > 0 then
	-- 			return 1
	-- 		end
	-- 	end
	-- end
	-- return 0
	if OpenFunData and OpenFunData.Instance and OpenFunData.Instance:CheckIsHide("Immortal") == true then
		local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
		local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
		local remind_day = PlayerPrefsUtil.GetInt("Immortal" .. main_role_id) or cur_day
		if cur_day ~= -1 and cur_day ~= remind_day then
			if not self:IsActiveAll() then
				return 1
			end
		end
	end
	return 0		
end

function ImmortalData:GetActiveList()
	local active_list = {false, false, false}
	local index = 1
	if self.xianzunka_addition_cfg ~= nil then
		for k, v in pairs(self.xianzunka_addition_cfg) do
			if self:IsActive(k) or self:IsActiveForever(k) then 
				active_list[index] = true
			end
			index = index + 1
		end
	end
	return active_list
end

function ImmortalData:GetCardDescCfg(type)
	return self.xianzunka_addition_cfg[type]
end

function ImmortalData:PlayerDataChangeCallback(attr_name)
	if attr_name == "level" then
		local role_level = GameVoManager.Instance:GetMainRoleVo().level
		if self.small_icon_open_level[role_level] then
			self:SetIsShowSmallImmortalBtn(true)
		end

		if role_level > 210 then
			if self.player_data_change then
				PlayerData.Instance:UnlistenerAttrChange(self.player_data_change)
				self.player_data_change = nil
				self.small_icon_open_level = nil
			end
		end
	end
end

function ImmortalData:SetIsShowSmallImmortalBtn(is_show)
	MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.SmallImmortal, is_show)
	if is_show then
		local main_chat_view = MainUICtrl.Instance:GetMainChatView()
		if main_chat_view then
			local immortal_btn = main_chat_view:GetChatButton(MainUIViewChat.IconList.SmallImmortal)
			if immortal_btn then
				immortal_btn:ShowEffect(is_show)
			end
		end
	end
end



