
require("game/daycounter/daycounter_data")

DayCounterCtrl = DayCounterCtrl or BaseClass(BaseController)

function DayCounterCtrl:__init()
	if DayCounterCtrl.Instance ~= nil then
		ErrorLog("[DayCounterCtrl] attempt to create singleton twice!")
		return
	end
	DayCounterCtrl.Instance = self
	self.data = DayCounterData.New()
	self:RegisterAllProtocols()
end

function DayCounterCtrl:__delete()
	DayCounterCtrl.Instance = nil

	self.data:DeleteMe()
	self.data = nil
end

function DayCounterCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCDayCounterInfo, 'OnDayCounterInfo')
	self:RegisterProtocol(SCDayCounterItemInfo, 'OnDayCounterItemInfo')
end

function DayCounterCtrl:OnDayCounterInfo(protocol)
	for k, v in pairs(protocol.daycount_list) do
		self.data:SetDayCount(k, v)

		if (DAY_COUNT.DAYCOUNT_ID_ACCEPT_HUSONG_TASK_COUNT) == k then
			YunbiaoCtrl.Instance:OnLingQuCiShuChangeHandler(v)
		--elseif (DAY_COUNT.DAYCOUNT_ID_FREE_CHEST_BUY_1) == k then
			--XunbaoCtrl.Instance:OnMianfeiNum(v)
		--elseif (DAY_COUNT.DAYCOUNT_ID_MAZE_MOVE) == k then
		elseif (DAY_COUNT.DAYCOUNT_ID_HUSONG_TASK_VIP_BUY_COUNT) == k then
			YunbiaoCtrl.Instance:OnGouMaiCiShuChangeHandler(v)
		elseif (DAY_COUNT.DAYCOUNT_ID_HUSONG_REFRESH_COLOR_FREE_TIMES) == k then
			YunbiaoCtrl.Instance:OnChangeRefreshFreeTimeHandler(v)
		elseif (DAY_COUNT.DAYCOUNT_ID_BUY_MIKU_WERARY) == k then
			BossCtrl.Instance:OnBuyMikuWeraryChange(v)
		elseif (DAY_COUNT.DAYCOUNT_ID_JINGLING_SKILL_COUNT) == k then
			SpiritCtrl.Instance:OnSkillFreeRefreshTimesChange(v)
		elseif (DAY_COUNT.DAYCOUNT_ID_MONEY_TREE_COUNT) == k then
			ZhuanZhuanLeCtrl.Instance:OnDayTreeCount(v)
		elseif (DAY_COUNT.DAYCOUNT_ID_BUY_ACTIVE_WERARY) == k then
			BossCtrl.Instance:OnBuyActiveWeraryChange(v)
		elseif DAY_COUNT.DAYCOUNT_ID_PERSON_BOSS_ENTER_TIMES == k then
			BossCtrl.Instance:SetPersonalBossEnterInfo(v)
		elseif DAY_COUNT.DAYCOUNT_ID_BUILD_TOWER_FB_BUY_TIMES == k then
			FuBenData.Instance:SetBuildTowerTimes(v)
		elseif DAY_COUNT.DAYCOUNT_ID_BUILD_TOWER_FB_ENTER_TIMES == k then
			FuBenCtrl.Instance:SetBuildTowerEnterTimes(v)
		elseif DAY_COUNT.DAYCOUNT_ID_DABAO_BOSS_BUY_COUNT == k then
			BossCtrl.Instance:SetDaBaoBossEnterInfo(v)
		--elseif (DAY_COUNT.DAYCOUNT_ID_YAOSHOUJITAN_JOIN_TIMES) == k then
			--DailyData.Instance:SetTeamFbEnterTimes(TEAM_TYPE.YAOSHOUJITANG, v)
		--elseif (DAY_COUNT.DAYCOUNT_ID_VIP_FREE_REALIVE) == k then
		--elseif (DAY_COUNT.VAT_TOWERDEFEND_FB_FREE_AUTO_TIMES) == k then
		--elseif (DAY_COUNT.DAYCOUNT_ID_CHALLENGE_FREE_AUTO_FB_TIMES) == k then
		--elseif (DAY_COUNT.DAYCOUNT_ID_GCZ_DAILY_REWARD_TIMES) == k then
		--elseif (DAY_COUNT.DAYCOUNT_ID_XIANMENGZHAN_RANK_REWARD_TIMES) == k then
			--GuildCtrl.Instance:SetXianMengZhanRewardCounter(v)
		--elseif (DAY_COUNT.DAYCOUNT_ID_MOBAI_CHENGZHU_REWARD_TIMES) == k then
		--elseif (DAY_COUNT.DAYCOUNT_ID_FB_COIN) == k
		--		or (DAY_COUNT.DAYCOUNT_ID_FB_XIANNV) == k
		--		or (DAY_COUNT.DAYCOUNT_ID_FB_QIBING) == k
		--		or (DAY_COUNT.DAYCOUNT_ID_FB_WING) == k
		--		or (DAY_COUNT.DAYCOUNT_ID_FB_XIULIAN) == k then
		--elseif (DAY_COUNT.DAYCOUNT_ID_GUILD_ZHUFU_TIMES) == k then
			--GuildCtrl.Instance:FlushLuck()
		elseif DAY_COUNT.DAYCOUNT_ID_TEAM_TOWERDEFEND_JOIN_TIMES == k or 
			DAY_COUNT.DAYCOUNT_ID_TEAM_EQUIP_FB_JOIN_TIMES == k then
			FuBenCtrl.Instance:SCFBInfo(k, v)
		--elseif DAY_COUNT.DAYCOUNT_ID_MIGOGNXIANFU_JOIN_TIMES == k thenk
			--DailyData.Instance:SetTeamFbEnterTimes(TEAM_TYPE.MIGONGXIANFU, v)
		elseif DAY_COUNT.DAYCOUNT_ID_JINGLING_ADVANTAGE_BOSS_KILL_COUNT == k then
			BossCtrl.Instance:OnEncounterBossEnterTimesChange(v)
		elseif DAY_COUNT.DAYCOUNT_ID_PERSONAL_BUY_COUNT == k then
			BossCtrl.Instance:OnSetPersonalBossBuyInfo(v)
		end
	end
	GlobalEventSystem:Fire(OtherEventType.DAY_COUNT_CHANGE, -1)

	for _, v in ipairs(DayCounterChange) do
		RemindManager.Instance:Fire(v)
	end
end

function DayCounterCtrl:OnDayCounterItemInfo(protocol)
	self.data:SetDayCount(protocol.day_counter_id, protocol.day_counter_value)

	if DAY_COUNT.DAYCOUNT_ID_ACCEPT_HUSONG_TASK_COUNT == protocol.day_counter_id then
		YunbiaoCtrl.Instance:OnLingQuCiShuChangeHandler(protocol.day_counter_value)
	--elseif DAY_COUNT.DAYCOUNT_ID_FREE_CHEST_BUY_1 == protocol.day_counter_id then
		--XunbaoCtrl.Instance:OnChangeMianfeiNum(protocol.day_counter_value)
	--elseif DAY_COUNT.DAYCOUNT_ID_MAZE_MOVE == protocol.day_counter_id then
	elseif DAY_COUNT.DAYCOUNT_ID_HUSONG_TASK_VIP_BUY_COUNT == protocol.day_counter_id then
		YunbiaoCtrl.Instance:OnGouMaiCiShuChangeHandler(protocol.day_counter_value)
	elseif DAY_COUNT.DAYCOUNT_ID_HUSONG_REFRESH_COLOR_FREE_TIMES == protocol.day_counter_id then
		YunbiaoCtrl.Instance:OnChangeRefreshFreeTimeHandler(protocol.day_counter_value)
	elseif (DAY_COUNT.DAYCOUNT_ID_GUILD_TASK_COMPLETE_COUNT) == protocol.day_counter_id or (DAY_COUNT.DAYCOUNT_ID_COMMIT_DAILY_TASK_COUNT) == protocol.day_counter_id then
		TipsCtrl.Instance:FlushTaskRewardView()
	elseif (DAY_COUNT.DAYCOUNT_ID_BUY_MIKU_WERARY) == protocol.day_counter_id then
			BossCtrl.Instance:OnBuyMikuWeraryChange(protocol.day_counter_value)
	elseif (DAY_COUNT.DAYCOUNT_ID_BUY_ACTIVE_WERARY) == protocol.day_counter_id then
			BossCtrl.Instance:OnBuyActiveWeraryChange(protocol.day_counter_value)
	elseif (DAY_COUNT.DAYCOUNT_ID_JINGLING_SKILL_COUNT) == protocol.day_counter_id then
			SpiritCtrl.Instance:OnSkillFreeRefreshTimesChange(protocol.day_counter_value)
	elseif (DAY_COUNT.DAYCOUNT_ID_MONEY_TREE_COUNT) == protocol.day_counter_id then
			ZhuanZhuanLeCtrl.Instance:OnDayTreeCount(protocol.day_counter_value)
	elseif DAY_COUNT.DAYCOUNT_ID_PERSON_BOSS_ENTER_TIMES == protocol.day_counter_id then
			BossCtrl.Instance:SetPersonalBossEnterInfo(protocol.day_counter_value)
	elseif DAY_COUNT.DAYCOUNT_ID_DABAO_BOSS_BUY_COUNT == protocol.day_counter_id then
			BossCtrl.Instance:SetDaBaoBossEnterInfo(protocol.day_counter_value)
	elseif DAY_COUNT.DAYCOUNT_ID_BUILD_TOWER_FB_BUY_TIMES == protocol.day_counter_id then
			FuBenCtrl.Instance:SetBuildTowerBuyTimes(protocol.day_counter_value)
	elseif DAY_COUNT.DAYCOUNT_ID_BUILD_TOWER_FB_ENTER_TIMES == protocol.day_counter_id then
			FuBenCtrl.Instance:SetBuildTowerEnterTimes(protocol.day_counter_value)
	--elseif DAY_COUNT.DAYCOUNT_ID_YAOSHOUJITAN_JOIN_TIMES == protocol.day_counter_id then
		--DailyData.Instance:SetTeamFbEnterTimes(TEAM_TYPE.YAOSHOUJITANG, v)
	--elseif DAY_COUNT.DAYCOUNT_ID_VIP_FREE_REALIVE == protocol.day_counter_id then
	--elseif DAY_COUNT.VAT_TOWERDEFEND_FB_FREE_AUTO_TIMES == protocol.day_counter_id then
	--elseif DAY_COUNT.DAYCOUNT_ID_CHALLENGE_FREE_AUTO_FB_TIMES == protocol.day_counter_id then
	--elseif (DAY_COUNT.DAYCOUNT_ID_GCZ_DAILY_REWARD_TIMES) == protocol.day_counter_id then
	--elseif (DAY_COUNT.DAYCOUNT_ID_XIANMENGZHAN_RANK_REWARD_TIMES) == protocol.day_counter_id then
		--GuildCtrl.Instance:SetXianMengZhanRewardCounter(protocol.day_counter_value)
	--elseif (DAY_COUNT.DAYCOUNT_ID_MOBAI_CHENGZHU_REWARD_TIMES) == protocol.day_counter_id then
	--elseif DAY_COUNT.DAYCOUNT_ID_FB_COIN  == protocol.day_counter_id
	--		or DAY_COUNT.DAYCOUNT_ID_FB_XIANNV == protocol.day_counter_id
	--		or DAY_COUNT.DAYCOUNT_ID_FB_QIBING == protocol.day_counter_id
	--		or DAY_COUNT.DAYCOUNT_ID_FB_WING == protocol.day_counter_id
	--		or DAY_COUNT.DAYCOUNT_ID_FB_XIULIAN == protocol.day_counter_id then
	--elseif (DAY_COUNT.DAYCOUNT_ID_GUILD_ZHUFU_TIMES) == protocol.day_counter_id then
		--GuildCtrl.Instance:FlushLuck()
	elseif DAY_COUNT.DAYCOUNT_ID_TEAM_TOWERDEFEND_JOIN_TIMES == protocol.day_counter_id or 
		DAY_COUNT.DAYCOUNT_ID_TEAM_EQUIP_FB_JOIN_TIMES == protocol.day_counter_id then
		FuBenCtrl.Instance:SCFBInfo(protocol.day_counter_id, protocol.day_counter_value)
	--elseif DAY_COUNT.DAYCOUNT_ID_MIGOGNXIANFU_JOIN_TIMES == protocol.day_counter_id then
		--DailyData.Instance:SetTeamFbEnterTimes(TEAM_TYPE.MIGONGXIANFU, protocol.day_counter_value)
	elseif DAY_COUNT.DAYCOUNT_ID_JINGLING_ADVANTAGE_BOSS_KILL_COUNT == protocol.day_counter_id then
		BossCtrl.Instance:OnEncounterBossEnterTimesChange(protocol.day_counter_value)
	elseif DAY_COUNT.DAYCOUNT_ID_PERSONAL_BUY_COUNT == protocol.day_counter_id then
		BossCtrl.Instance:OnSetPersonalBossBuyInfo(protocol.day_counter_value)
	end

	GlobalEventSystem:Fire(OtherEventType.DAY_COUNT_CHANGE, protocol.day_counter_id)

	for _, v in ipairs(DayCounterChange) do
		RemindManager.Instance:Fire(v)
	end
end