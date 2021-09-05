FestivalActivityData = FestivalActivityData or BaseClass()


--这里面存放对应的版本活动ID号、节日更换根据需求需要屏蔽在这里处理相关活动
FESTIVAL_ACTIVITY_ID = {
	RAND_ACTIVITY_TYPE_TOTAL_CHARGE_FIVE = 2224,			 -- 吉祥三宝
	RAND_ACTIVITY_TYPE_SPECIAL_IMG_SUIT = 2226,				 -- 限定套装
	RAND_ACTIVITY_TYPE_VERSIONS_GRAND_TOTAL_CHARGE = 2213,
}



BANBEN_OPEN_SERVER_ACTIVITY_TYPE = {
	-- RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE = 2091,			-- 7天累积充值(开服活动))
	-- RAND_ACTIVITY_TYPE_ROLE_UPLEVEL = 2128,					-- 冲级大礼(开服活动)
	
}
--版本活动排序
local FST_SORT_INDEX_LIST = {
	
	[1] = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_VERSIONS_CONTINUE_CHARGE,
	[2] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAKE_MOONCAKE,
	[3] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FENGKUANG_YAOJIANG,
	[4] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EVERYDAY_NICE_GIFT,
	[5] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_0,
	[6] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT,
	[7] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DANBI_CHONGZHI,
	[8] = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PRINT_TREE,
	[9] = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FANGFEI_QIQIU,
	[10] = FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_TOTAL_CHARGE_FIVE,
	[11] = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HOLIDAY_GUARD,
	[12] = FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_SPECIAL_IMG_SUIT,
	[13] = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXTREME_CHALLENGE,
	[14] = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_VERSIONS_GRAND_TOTAL_CHARGE,
	[15] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_RANK,
	[16] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_PASSIVE_RANK,
	[17] = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_KUANG_HAI_QING_DIAN,
	[18] = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LIWUSHOUGE,
}

FST_ACT_TYPE_INDEX = {
	
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_VERSIONS_CONTINUE_CHARGE] = 1,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAKE_MOONCAKE] = 2,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FENGKUANG_YAOJIANG] = 3,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EVERYDAY_NICE_GIFT] = 4,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_0] = 5,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT] = 6,
	-- [RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DANBI_CHONGZHI] = 7,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PRINT_TREE] = 8,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FANGFEI_QIQIU] = 9,
	[FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_TOTAL_CHARGE_FIVE] = 10,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HOLIDAY_GUARD] = 11,
	[FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_SPECIAL_IMG_SUIT] = 12,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXTREME_CHALLENGE] = 13,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_VERSIONS_GRAND_TOTAL_CHARGE] = 14,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_RANK] = 15,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_PASSIVE_RANK] = 16,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_KUANG_HAI_QING_DIAN] = 17,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LIWUSHOUGE] = 18,
}

function FestivalActivityData:__init()
	if FestivalActivityData.Instance ~= nil then
		print_error("[FestivalActivityData] Attemp to create a singleton twice !")
		return
	end

	FestivalActivityData.Instance = self
	self.info = {}
	self.banben_cfg = ConfigManager.Instance:GetAutoConfig("versions_activity_auto").banben_activity
	self.selectindex = 1
	self.default_fest_act_type = -1
	RemindManager.Instance:Register(RemindName.Festival_Act, BindTool.Bind(self.GetBanBenActivityRemind, self))
end

function FestivalActivityData:__delete()
		FestivalActivityData.Instance = nil
end

function FestivalActivityData:GetActivityOpenCfgById(act_id)
	if nil == self.banben_cfg then return nil end
	for k, v in pairs(self.banben_cfg) do
		if v.activity_type == act_id then
			return v
		end
	end
	return nil
end

function FestivalActivityData:GetBanBenActOpenCfg()
	if not self.banben_cfg then
		self.banben_cfg = ConfigManager.Instance:GetAutoConfig("versions_activity_auto").banben_activity
	end
	return self.banben_cfg
end

function FestivalActivityData:GetOpenActivityList()
	local list = {}
	for k, v in pairs(self:GetBanBenActOpenCfg()) do
		if ActivityData.Instance:GetActivityIsOpen(v.activity_type) or 
			-- 两个活动(2189、2289)公用一个活动id,客户端假的活动id-2289
			(v.activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FANGFEI_QIQIU and ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PRINT_TREE)) then
			list[v.activity_type] = v
		end
	end

	local temp_list = {}
	for _, v in ipairs(FST_SORT_INDEX_LIST) do
		local activity = list[v]
		if activity ~= nil then
			table.insert(temp_list, activity)
			list[v] = nil
		end
	end

	for _, v in pairs(list) do
		table.insert(temp_list, v)
	end

	return temp_list
end

function FestivalActivityData:SetSelect(index)
	self.selectindex = index
end

function FestivalActivityData:GetSelectIndex()
	return self.selectindex
end

function FestivalActivityData:GetActivityTypeToIndex(activity_type)
	if activity_type > 100000 then
		activity_type = activity_type - 100000
	end
	local index = FST_ACT_TYPE_INDEX[activity_type] or 1

	return index
end

function FestivalActivityData:GetExpenseNiceGiftCfg()
	if not self.expense_nice_gift_cfg then
		self.expense_nice_gift_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().expense_nice_gift
	end

	return self.expense_nice_gift_cfg
end

function FestivalActivityData:GetExpenseNiceGiftCfgLength()
	if not self.expense_nice_gift_cfg_length then
		local cfg = self:GetExpenseNiceGiftCfg()
		self.expense_nice_gift_cfg_length = #cfg
	end

	return self.expense_nice_gift_cfg_length
end

function FestivalActivityData:GetExpenseNiceGiftPageCount()
	if self.expense_nice_gift_page_count then
		return self.expense_nice_gift_page_count
	end

	local cfg = self:GetExpenseNiceGiftCfg()

	if cfg then
		local count = self:GetExpenseNiceGiftCfgLength()

		if count > 0 then
			local remainder = math.floor((count % 9))
			local divider = math.floor((count / 9))
			local num = remainder == 0 and divider or (1 + divider)
			self.expense_nice_gift_page_count = num

			return self.expense_nice_gift_page_count
		end
	end

	return 0
end

function FestivalActivityData:GetExpenseNiceGiftPageCfgByIndex(index)
	if not index or index < 0 then 
		return nil 
	end

	if not self.expense_nice_gift_page_cfg then 
		self.expense_nice_gift_page_cfg = {} 
	end

	if self.expense_nice_gift_page_cfg[index] then 
		return self.expense_nice_gift_page_cfg[index] 
	end

	local num = self:GetExpenseNiceGiftPageCount() or 0
	local cfg = self:GetExpenseNiceGiftCfg()
	local list = {}

	if num > 0 then
		local count = 0
		local max_range = index * 9
		local min_range = (max_range - 8) > 0 and (max_range - 8) or 1

		for i = min_range, max_range do
			if cfg[i] then
				table.insert(list, cfg[i])
				count = count + 1
			end
		end

		if count > 0 then
			self.expense_nice_gift_page_cfg[index] = list
			return self.expense_nice_gift_page_cfg[index]
		end
	end

	return nil
end

function FestivalActivityData:GetActivityTypeByIndex(open_index)
	for k, v in pairs(FST_ACT_TYPE_INDEX) do
		if open_index == v then
			return k
		end
	end
end

----------------------------以下为每个活动独立操作按模块-------------------

--匠心月饼红点
function FestivalActivityData:IsShowMoonCakeRedPoint()
	local can_get = 0
	can_get = MakeMoonCakeData.Instance:IsShowMakeMoonCakeRedPoint()
	return can_get
end

function FestivalActivityData:GetHolidayCfg()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().special_img_suit_special_id_cfg[1] or {}

	return cfg
end

-------------------------红点提示-----------------------------------
--极限挑战红点
function FestivalActivityData:IsShowExtremeChallengeRemind()
	local flag = 0
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXTREME_CHALLENGE) then
		return flag
	end
	local task_list = ExtremeChallengeData.Instance:GetTaskInfoList()
	if task_list == nil then
		return flag
	end
	for k,v in pairs(task_list) do
		if v.is_finish == 1 and v.is_already_fetch == 0 then 
			flag = 1 
			return flag
		end
	end
	local total_task_num = ExtremeChallengeData.Instance:GetTaskCount() or 0
	local complete_task_num = ExtremeChallengeData.Instance:GetCompleteTaskNum() or 0
	local had_fetch_flag = ExtremeChallengeData.Instance:GetFetchUltimateRewardFlag()
	if complete_task_num == total_task_num and had_fetch_flag == 0 then
		flag = 1
	end
	return flag
end

function FestivalActivityData:IsShowExpenseNiceGiftRedPoint()
	if not ActivityData.Instance:GetActivityIsOpen(FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_EXPENSE_NICE_GIFT) then 
		return 0 
	end

	local flag = 0
	local length = self:GetExpenseNiceGiftTotalRwardCfgLength()
	local info = self:GetExpenseNiceGiftInfo()

	if info and info.yao_jiang_num then
		flag = (info.yao_jiang_num > 0) and 1 or 0
	end

	for i = 1, length do
		local can_fetch = self:ExpenseInfoRewardCanFetchFlagByIndex(i)
		local has_fetch = self:ExpenseInfoRewardHasFetchFlagByIndex(i)
		if can_fetch == 1 and has_fetch == 0 then
			flag = 1
			break
		end
	end

	return flag
end

--累计充值红点
function FestivalActivityData:IsShowVesLeiChongRedPoint()
	if not ActivityData.Instance:GetActivityIsOpen(FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_VERSIONS_GRAND_TOTAL_CHARGE) then 
		return 0 
	end

	local cfg = FestivalLeiChongData.Instance:GetVesTotalChargeCfg()
	local charge_value = FestivalLeiChongData.Instance:GetChargeValue()

	for k, v in pairs(cfg) do
		local has_fetch = FestivalLeiChongData.Instance:GetFetchFlag(v.seq)
		if charge_value >= v.need_chognzhi and has_fetch == 0 then
			return 1
		end
	end

	return 0
end

-----连续充值红点
function FestivalActivityData:IsShowLianXuChongRedPoint()
	if not ActivityData.Instance:GetActivityIsOpen(FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_VERSIONS_CONTINUE_CHARGE)
		then return 0
	end

    local reward_info = self:GetChongZhiZhongQiu()
    if nil == reward_info or next(reward_info) == nil then
		return 0
	end

    if self:ZhongQiuLianXuChongZhiCfg() == nil then
    	return 0
    end

    for i = 1, #self:ZhongQiuLianXuChongZhiCfg() do
		if self.can_fetch_reward_flag[32 - i] == 1 then
			if self.has_fetch_reward_flag[32 - i] == 0 then  --未领取
                return 1
			end
		end
	end

	return 0
end


function FestivalActivityData:GetBanBenActivityRemind()
	local num = 0
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EVERYDAY_NICE_GIFT) then 				-- 每日好礼
		if KaifuActivityData.Instance:DailyGiftRedPoint() > 0 then
			num = num +1
		end
	end
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVEIY_TYPE_LIANXUCHONGZHI) then			-- 连续充值
		if KaifuActivityData.Instance:IsShowRedPoint() > 0 then
			num = num +1
		end
	end
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAKE_MOONCAKE) then					--集月饼活动(单身伴侣)
		if KaifuActivityData.Instance:IsMakeMoonCakeRemind() > 0 then
			num = num +1
		end
	end
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_YAOJIANG2) then				-- 疯狂摇奖
		if KaifuActivityData.Instance:GetHappyErnieRemind() > 0 then
			num = num +1
		end
	end
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT) then					-- 登录豪礼
		if ActivityPanelLoginRewardData.Instance:GetLoginGiftRemind0() > 0 then
			num = num +1
		end
	end
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_DAY_DANBI_CHONGZHI) then							-- 充值返利
		if KaifuActivityData.Instance:IsDailyDanBiRedPoint() then
			num = num +1
		end
	end
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXTREME_CHALLENGE) then				-- 极限挑战
		if self:IsShowExtremeChallengeRemind() > 0 then
			num = num +1
		end
	end
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_VERSIONS_GRAND_TOTAL_CHARGE) then			-- 累计充值
		if self:IsShowVesLeiChongRedPoint() > 0 then
			num = num +1
		end
	end

	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_KUANG_HAI_QING_DIAN) then			-- 狂嗨庆典
		if CrazyHiCelebrationData.Instance:CrazyHiCelebrationRedPoint() > 0 then
			num = num + 1
		end
	end

	MainUICtrl.Instance:ShowIconGroup2Effect("festivalactivityview", num > 0)
	return num
end