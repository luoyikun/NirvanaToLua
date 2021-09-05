LoginGift7Data = LoginGift7Data or BaseClass()

function LoginGift7Data:__init()
	if LoginGift7Data.Instance ~= nil then
		print_error("[LoginGift7Data] Attemp to create a singleton twice !")
		return
	end
	LoginGift7Data.Instance = self

	self.gift_info = {}
	self.login_day_list = {}
	for i = 1, 7 do
		self.login_day_list[i] = 0
	end
	self.is_all_receive = false
	self.is_show_redpt = true

	-- 配置表数据
	self.reward_list = ConfigManager.Instance:GetAutoConfig("sevendaylogincfg_auto").reward
	RemindManager.Instance:Register(RemindName.SevenLogin, BindTool.Bind(self.GetSevenLoginRemind, self))
end

function LoginGift7Data:__delete()
	RemindManager.Instance:UnRegister(RemindName.SevenLogin)

	if LoginGift7Data.Instance ~= nil then
		LoginGift7Data.Instance = nil
	end
end

function LoginGift7Data:GetGiftRewardCfg()
	return self.reward_list
end

--通过天数获取对应的配置信息
function LoginGift7Data:GetDataByDay(day)
	local data = {}
	for k,v in pairs(self.reward_list) do
		if day == v.login_daycount then
			table.insert(data,v)
		end
	end

	return data[1]
end

function LoginGift7Data:GetGiftRewardByDay(day)
	local get_num = 0
	for k,v in pairs(self:GetGiftRewardCfg()) do
		if v.login_daycount == day then
			get_num = v.show_money
		end
	end
	return get_num
end


function LoginGift7Data:GetRewardList(gift_id)
	if gift_id == 0 then
		gift_id = 1
	end

	if gift_id > 7 then
		gift_id = 7
	end
	local gift_cfg = ItemData.Instance:GetItemConfig(self:GetDataByDay(gift_id).reward_item.item_id)
	local reward_list = {}
	for i = 1, 6 do
		local item_id = gift_cfg["item_" .. i .. "_id"]
		if nil ~= item_id and item_id > 0 then
			local t = {}
			t.item_id = item_id
			t.num = gift_cfg["item_" .. i .. "_num"]
			t.is_bind = gift_cfg["is_bind_"..i]

			local item_cfg, big_type = ItemData.Instance:GetItemConfig(t.item_id)
			local gamevo = GameVoManager.Instance:GetMainRoleVo()
			local flag = true
			if nil ~= item_cfg then
				if (gamevo.prof % 10) ~= item_cfg.limit_prof and item_cfg.limit_prof ~= 5 then
					flag = false
				end
			end

			if flag then
				table.insert(reward_list, t)
			end
		end
	end

	return reward_list
end

function LoginGift7Data:GetGiftInfo()
	return self.gift_info
end

function LoginGift7Data:OnFetchSevenDayLoginReward(protocol)
	self.gift_info.notify_reason = protocol.notify_reason
	self.gift_info.account_total_login_daycount = protocol.account_total_login_daycount
	self.gift_info.seven_day_login_fetch_reward_list = bit:d2b(protocol.seven_day_login_fetch_reward_mark)
	self:SetLoginDayList()
	self:GetLoginAllReward()
end

function LoginGift7Data:GetLoginDay()
	return self.gift_info.account_total_login_daycount or 0
end

function LoginGift7Data:GetLoginRewardFlag(fetch_day)
	if nil == self.gift_info.seven_day_login_fetch_reward_list then
		return false
	end

	local flag = self.gift_info.seven_day_login_fetch_reward_list[32 - fetch_day]

	if 0 == flag then
		return false
	else
		return true
	end
end

function LoginGift7Data:GetLoginAllReward()
	for i = 1, 7 do
		if not self:GetLoginRewardFlag(i) then
			return
		end
	end

	local main_view = MainUICtrl.Instance:GetView()
	if main_view then
		main_view:SetShowLoginGiftIcon(false)
	end
end

function LoginGift7Data:GetLoginDayList()
	return self.login_day_list
end

function LoginGift7Data:SetLoginDay(day,value)
	self.login_day_list[day] = value
end

function LoginGift7Data:SetLoginDayList()
	local day = self.gift_info.account_total_login_daycount
	if day > 7 then
		day = 7
	end

	for i = 1, day do
		if not self:GetLoginRewardFlag(i) then
			self.login_day_list[i] = 1
		end
	end
end

function LoginGift7Data:SetIsAllReceive(is_all_receive)
	self.is_all_receive = is_all_receive
end

function LoginGift7Data:GetIsAllReceive()
	return self.is_all_receive
end

function LoginGift7Data:SetIsShowRedpt(is_show_redpt)
	self.is_show_redpt = is_show_redpt
end

function LoginGift7Data:GetIsShowRedpt()
	return self.is_show_redpt
end

function LoginGift7Data:GetSevenLoginRemind()
	self:ShowRedpt()
	return self:GetIsShowRedpt() and 1 or 0
end

function LoginGift7Data:ShowRedpt()
	local day = self.gift_info.account_total_login_daycount or 0
	if day > 7 then
		day = 7
	end

	for i = 1, day do
		if not self:GetLoginRewardFlag(i) then
			self.is_show_redpt = true
			return
		end
	end
	self.is_show_redpt = false
end

function LoginGift7Data:IsCanReceive(cur_day)
	if cur_day > self.gift_info.account_total_login_daycount then
		return false
	end

	if not self:GetLoginRewardFlag(cur_day) then
		return true
	else
		return false
	end
end

function LoginGift7Data:GetWeaponTransform()
	local base_prof = PlayerData.Instance:GetRoleBaseProf()
	local cfg = {}
	if base_prof == 1 then
		cfg.position = Vector3(3.5, -3.5, -5)
		cfg.rotation = Vector3(0, 0, 50)
		cfg.scale = Vector3(4, 4, 4)
	elseif base_prof == 2 then
		cfg.position = Vector3(0, -5, -5)
		cfg.rotation = Vector3(0, 0, 10)
		cfg.scale = Vector3(3.5, 3.5, 3.5)
	elseif base_prof == 3 then
		cfg.position = Vector3(0, -4.5, -5)
		cfg.rotation = Vector3(0, 0, 10)
		cfg.scale = Vector3(4, 4, 4)
	end
	return cfg
end



