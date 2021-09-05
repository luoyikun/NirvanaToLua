HuanzhuangShopData = HuanzhuangShopData or BaseClass()

HuanzhuangShopData.OPERATE = {
	-- RECHARGE = 0,
	BUY = 0,
	ONE_KEY = 1,
}

function HuanzhuangShopData:__init()
	if HuanzhuangShopData.Instance then
		ErrorLog("[HuanzhuangShopData] attempt to create singleton twice!")
		return
	end
	HuanzhuangShopData.Instance = self

	self.first_login = true
	self.activity_info = {}
	self.title_shop_info = {}
	self.title_shop_info.magic_shop_fetch_reward_flag = 0
	self.activity_info.magic_shop_buy_flag = 0
	self.activity_info.activity_day = 0
	self.title_shop_info.activity_day = 0
    self.title_shop_info.magic_shop_chongzhi_value = 0

    RemindManager.Instance:Register(RemindName.ShowHuanZhuangShopPoint, BindTool.Bind(self.ShowHuanZhuangShopPoint, self))
    RemindManager.Instance:Register(RemindName.TitleShopTodayRemind, BindTool.Bind(self.TitleShopTodayRemind, self))
    RemindManager.Instance:Register(RemindName.NiChongWoSong, BindTool.Bind(self.ShowTitleShopPoint, self))
end

function HuanzhuangShopData:__delete()
	HuanzhuangShopData.Instance = nil
 	RemindManager.Instance:UnRegister(RemindName.NiChongWoSong)
 	RemindManager.Instance:UnRegister(RemindName.TitleShopTodayRemind)
 	RemindManager.Instance:UnRegister(RemindName.ShowHuanZhuangShopPoint)

	if self.act_time_countdown then
		GlobalTimerQuest:CancelQuest(self.act_time_countdown)
		self.act_time_countdown = nil
	end

	if self.act2_time_countdown then
		GlobalTimerQuest:CancelQuest(self.act2_time_countdown)
		self.act2_time_countdown = nil
	end
end

function HuanzhuangShopData:GetHuanZhuangShopCfg()
	local rand_act_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	return ActivityData.Instance:GetRandActivityConfig(rand_act_cfg.magic_shop, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP)
end

function HuanzhuangShopData:GetTitleShopCfg()
	local rand_act_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	return ActivityData.Instance:GetRandActivityConfig(rand_act_cfg.chongzhi_gift, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_NICHONGWOSONG)
end

function HuanzhuangShopData:GetHuanZhuangShopRewardCfgByShowType()
	local rand_act_cfg = {}
	-- if show_type == RA_HUANZHUANG_SHOP_TYPE.HUANZHUANG_SHOP_TYPE then
	-- 	rand_act_cfg = self:GetHuanZhuangShopCfg()
	-- end
	rand_act_cfg = self:GetHuanZhuangShopCfg()
	if rand_act_cfg == nil then
		return
	end
	local list = {}
	for i, v in ipairs(rand_act_cfg) do
		if v.activity_day == self.activity_info.activity_day then
			table.insert(list, v)
		end
	end
	return list
end

function HuanzhuangShopData:GetTitleShopRewardCfgByShowType()
	local rand_act_cfg = {}
	-- if show_type == RA_HUANZHUANG_SHOP_TYPE.TITLE_SHOP_TYPE then
	-- 	rand_act_cfg = self:GetTitleShopCfg()
	-- end
	local list = {}
	rand_act_cfg = self:GetTitleShopCfg()
	if rand_act_cfg == nil then
		return list
	end
	
	for i, v in ipairs(rand_act_cfg) do
		if v.activity_day == self.title_shop_info.activity_day then
			table.insert(list, v)
		end
	end
	return list
end

function HuanzhuangShopData:SetRAMagicShopAllInfo(protocol)
	self.activity_info.magic_shop_buy_flag = protocol.magic_shop_buy_flag or 0
	self.activity_info.activity_day = protocol.activity_day or 0
end

function HuanzhuangShopData:GetRAMagicShopAllInfo()
	return self.activity_info
end

function HuanzhuangShopData:SetRATitleShopAllInfo(protocol)
	self.title_shop_info.magic_shop_fetch_reward_flag = protocol.magic_shop_fetch_reward_flag
	self.title_shop_info.activity_day = protocol.activity_day
    self.title_shop_info.magic_shop_chongzhi_value = protocol.magic_shop_chongzhi_value
    -- RemindManager.Instance:Fire(RemindName.NiChongWoSong)
end

function HuanzhuangShopData:GetRATitleShopAllInfo()
	return self.title_shop_info
end

function HuanzhuangShopData:ShowTitleShopPoint()
	-- if MainuiActivityHallData.Instance:GetShowOnceEff(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_NICHONGWOSONG) then
	-- 	return 1
	-- end

	-- local num = 0
	local cfg = self:GetTitleShopRewardCfgByShowType()
	if cfg == nil then
		return 0
	end
	for i,v in ipairs(cfg) do
		if self.title_shop_info.magic_shop_chongzhi_value >= v.need_gold then
			
			local fetch = bit:d2b(self.title_shop_info.magic_shop_fetch_reward_flag)
			if 0 == fetch[32 - v.index] then
				return 1
			end
		end 
	end
	
	if RemindManager.Instance:RemindToday(RemindName.TitleShopTodayRemind) then
		return 0
	else
		return 1
	end
	-- return 0
end

function HuanzhuangShopData:TitleShopTodayRemind()
	return 0
end

function HuanzhuangShopData:ShowHuanZhuangShopPoint()
	if RemindManager.Instance:RemindToday(RemindName.ShowHuanZhuangShopPoint) then
		return 0
	else
		return 1
	end
end

function HuanzhuangShopData:SetLoginFlag(value)
	self.first_login = value
end

function HuanzhuangShopData:GetLoginFlag(value)
	return self.first_login
end
