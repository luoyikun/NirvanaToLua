MainuiActivityHallData = MainuiActivityHallData or BaseClass()

-- 活动卷轴、每次上线显示特效用的
MainuiActivityHallData.SCROLL_CLICK_EFF = {
	[ACTIVITY_TYPE.RAND_CHONGZHI_RANK] = false,
	[ACTIVITY_TYPE.RAND_CONSUME_GOLD_RANK] = false,
	[ACTIVITY_TYPE.RAND_JINYINTA] = false,
	[ACTIVITY_TYPE.RAND_NIUEGG] = false,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT] = false,
	[ACTIVITY_TYPE.RAND_LOTTERY_TREE] = false,
	[ACTIVITY_TYPE.RAND_ACTIVITY_FANFANZHUAN] = false,
	[ACTIVITY_TYPE.RAND_ACTIVITY_MINE] = false,
	[ACTIVITY_TYPE.RAND_ACTIVITY_DINGGUAGUA] = false,
	[ACTIVITY_TYPE.RAND_ACTIVITY_LUCKYDRAW] = false,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FANFAN] = false,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CONSUME] = false,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_REPEAT_RECHARGE] = false,
	[ACTIVITY_TYPE.RAND_ACTIVITY_SUPER_LUCKY_STAR] = false,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DAY_UP] = false,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHONGZHI] = false,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIANYUAN_TREAS] = false,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAP_HUNT] = false,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LIMITTIME_REBATE] = false,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHAKE_MONEY] = false,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_GOLD_FANLI] = false,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHONGZHI_CRAZY_REBATE] = false,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BUYONE_GETONE] = false,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_FOR_GIFT] = false,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MIJINGXUNBAO3] = false,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_ZADAN] = false,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPYERNIE] = false,
	-- [ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_NICHONGWOSONG] = false,
	-- [ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_JUBAOPEN] = false,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_BIG_GIFT] = false,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GROUP_PURCHASE] = false,
}

MainuiActivityHallData.MAINUI_CLICK_EFF = {
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOOP_CHARGE_2] = false,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_BUSINESSMAN] = false,
	
}

MainuiActivityHallData.DelayRemindList = {
	-- [ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_BIG_GIFT] = RemindName.LimitBigGift,
	-- [ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BUYONE_GETONE] = RemindName.BuyOneGetOneRemind,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_NICHONGWOSONG] = RemindName.NiChongWoSong,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_BUSINESSMAN] = RemindName.ZhenBaoge2,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP] = RemindName.ShowHuanZhuangShopPoint,
	-- [ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIANYUAN_TREAS] = RemindName.JuHuaSuan,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_FOR_GIFT] = RemindName.CousumeForGiftRemind,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_2] = RemindName.SingleChange,
}

function MainuiActivityHallData:__init()
	if MainuiActivityHallData.Instance ~= nil then
		ErrorLog("[MainuiActivityHallData] Attemp to create a singleton twice !")
	end

	MainuiActivityHallData.Instance = self
	self.flag_shouw = {}
	self.act_times = {}

	-- RemindManager.Instance:CreateIntervalRemindTimer(RemindName.LimitBigGift)
end

function MainuiActivityHallData:__delete()
	MainuiActivityHallData.Instance = nil
end

-- 设置主界面活动按钮特效出现
function MainuiActivityHallData:SetMainShowOnceEff(act_type, flag_shouw)
	MainuiActivityHallData.MAINUI_CLICK_EFF[act_type] = flag_shouw
end

function MainuiActivityHallData:GetMainShowOnceEff(act_type)
	if nil ~= MainuiActivityHallData.MAINUI_CLICK_EFF[act_type] then
		return MainuiActivityHallData.MAINUI_CLICK_EFF[act_type]
	end
	return false
end

-- 设置活动特效出现次数
function MainuiActivityHallData:SetShowOnceEff(act_type,flag_shouw)
	MainuiActivityHallData.SCROLL_CLICK_EFF[act_type] = flag_shouw
end

function MainuiActivityHallData:GetShowOnceEff(act_type)
	if nil ~= MainuiActivityHallData.SCROLL_CLICK_EFF[act_type] then
		return MainuiActivityHallData.SCROLL_CLICK_EFF[act_type]
	end
	return false
end

-- 随机活动倒计时
function MainuiActivityHallData:SetActTime(act_type,act_time)
	self.act_times[act_type] = act_time
end

function MainuiActivityHallData:GetActTime(act_type)
	if nil ~= self.act_times[act_type] then
		return self.act_times[act_type]
	end
	return 0
end

function MainuiActivityHallData:FlushActRedPoint()
	local data_list = ActivityData.Instance:GetActivityHallDatalist()
	for k,v in pairs(data_list) do
		if v.type == ACTIVITY_TYPE.RAND_JINYINTA then
			-- 金银塔
			JinYinTaData.Instance:FlushHallRedPoindRemind()
		elseif v.type == ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT then

		end
	end

end