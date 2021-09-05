
ModulesController = ModulesController or BaseClass()

function ModulesController:__init(is_quick_login)
	if ModulesController.Instance ~= nil then
		print_error("[ModulesController] attempt to create singleton twice!")
		return
	end
	ModulesController.Instance = self

	self:CreateCoreModule()
	self.is_quick_login = is_quick_login
	if not is_quick_login then
		self:CreateLoginModule()
	end

	self.ctrl_list = {}
	self.push_list = {}
	self.cur_index = 0

	if is_quick_login then
		self:CreateGameModule()
	end
end

function ModulesController:__delete()
	self:DeleteLoginModule()
	self:DeleteGameModule()

	OpenFunCtrl.Instance:DeleteMe()
	ClientCmdCtrl.Instance:DeleteMe()
	TimeCtrl.Instance:DeleteMe()
	ChatRecordMgr.Instance:DeleteMe()
	AudioService.Instance:DeleteMe()
	LoadingPriorityManager.Instance:DeleteMe()
	AvatarManager.Instance:DeleteMe()
	ViewManager.Instance:DeleteMe()
	GameVoManager.Instance:DeleteMe()

	ModulesController.Instance = nil
	self.state_callback = nil
end

function ModulesController:Start(call_back)
	self.state_callback = call_back
	self.ctrl_list = {}
	self.cur_index = 0
	-- 把需要创建的Ctrl加在这里
	self.push_list = {

		RemindManager,
		SettingCtrl,
		FightCtrl,
		Scene,
		PrefabPreload,
		QueueLoader,
		RenderBudget,
		SysMsgCtrl,
		OtherCtrl,
		TitleCtrl,
		GuideCtrl,
		TipsCtrl,
		GuajiCtrl,
		StoryCtrl,
		TaskCtrl,
		TianShuCtrl,
		PackageCtrl,
		PlayerCtrl,
		MainUICtrl,
		ActivityCtrl,
		BossCtrl,
		ShenYuBossCtrl,
		ChatCtrl,
		CoolChatCtrl,
		AutoVoiceCtrl,
		HongBaoCtrl,
		PlayPawnCtrl,
		BaoJuCtrl,
		FashionCtrl,
		WingCtrl,
		FootCtrl,
		HappyHitEggCtrl,
		-- FootHuanHuaCtrl,
		
		SkillCtrl,
		ZhuanZhiCtrl,
		LuoShuCtrl,
		MojieCtrl,
		ExchangeCtrl,
		ForgeCtrl,
		KuaFuXiuLuoTowerCtrl,
		GoddessCtrl,
		WelfareCtrl,
		AchieveCtrl,
		ArenaCtrl,
		KFArenaCtrl,
		ZhiBaoCtrl,
		JingJieCtrl,
		MedalCtrl,
		AdvanceCtrl,
		CampCtrl,
		MountCtrl,
		JinJieRewardCtrl,
		MythCtrl,
		-- AdvanceEquipUpCtrl,
		-- MountHuanHuaCtrl,
		GuildCtrl,
		GoddessHuanHuaCtrl,
		MarketCtrl,
		MarriageCtrl,
		BaobaoCtrl,
		-- WingHuanHuaCtrl,
		RankCtrl,
		FuBenCtrl,
		GaoZhanCtrl,
		HaloCtrl,
		-- HaloHuanHuaCtrl,
		ScoietyCtrl,
		SendGiftCtrl,
		TreasureBowlCtrl,

		ShengongCtrl,
		CityCombatCtrl,
		ShengongHuanHuaCtrl,
		ShenyiCtrl,
		ShenyiHuanHuaCtrl,
		CheckCtrl,
		ComposeCtrl,
		LeiJiRechargeCtrl,
		FreeGiftCtrl,
		FriendExpBottleCtrl,

		GuildFightCtrl,
		ClashTerritoryCtrl,
		ElementBattleCtrl,
		DaFuHaoCtrl,
		ShopCtrl,
		TreasureCtrl,
		TipsTriggerCtrl,
		TradeCtrl,
		MapCtrl,
		ReviveCtrl,
		SpiritCtrl,
		RechargeCtrl,
		VipCtrl,
		KuaFu1v1Ctrl,
		KuafuPVPCtrl,
		CrossCrystalCtrl,
		CrossServerCtrl,
		HelperCtrl,
		YunbiaoCtrl,
		DayCounterCtrl,
		SkyMoneyCtrl,
		FlowersCtrl,
		FlowerRemindCtrl,
		AncientRelicsCtrl,
		ZhuaGuiCtrl,
		HotStringChatCtrl,
		LoginGift7Ctrl,
		DailyChargeCtrl,
		RebateCtrl,
		DaLeGouCtrl,
		ImageSkillCtrl,
		DailyTaskFbCtrl,
		TombExploreCtrl,
		FirstChargeCtrl,
		LuanDouBattleCtrl,
		XianShiLianChongCtrl,
		--MoLongCtrl,
		-- MagicWeaponCtrl,
		--GoddessShouhuCtrl,
		GuildBonfireCtrl,
		GuildMijingCtrl,
		HuashenCtrl,
		-- PetCtrl,
		ZhuanShengCtrl,
		FightMountCtrl,
		ReincarnationCtrl,
		BiaoBaiQiangCtrl,
		HpBagCtrl,
		-- FightMountHuanHuaCtrl,
		-- ExpresionFuBenCtrl,
		WelcomeCtrl,
		MolongMibaoCtrl,
		MarryMeCtrl,
		CompetitionActivityCtrl,
		BiPingActivityCtrl,
		KuaFuTargetCtrl,
		-- PersonalGoalsCtrl,
		RuneCtrl,
		SymbolCtrl,
		GuaJiTaCtrl,
		RandSystemCtrl,
		LingRenCtrl,
		ShenGeCtrl,
		ExtremeChallengeCtrl,
		WaBaoCtrl,
		RelicCtrl,
		HunQiCtrl,
		PuzzleCtrl,
		ShengXiaoCtrl,
		ShenShouCtrl,
		MiJiComposeCtrl,
		LeiJiRDailyCtrl,
		BuyOneGetOneCtrl,
		ConsunmForGiftCtrl,
		ConsumeDiscountCtrl,
		ClothespressCtrl,
		CrossRankCtrl,
		
		--夫妻家园
		CoupleHomeCtrl,
		CoupleHomeHomeCtrl,
		CoupleHomeShopCtrl,

		AppearanceCtrl,
		MultiMountCtrl,
		TouShiCtrl,
		MaskCtrl,
		WaistCtrl,
		QilinBiCtrl,
		UpgradeCtrl,
		TianshenhutiCtrl,

		BianShenCtrl,

		RollingBarrageCtrl,
		KillRoleCtrl,
		ShenYinCtrl,

		YewaiGuajiCtrl,
		CongratulationCtrl,
		MarryNoticeCtrl,
		YuLeCtrl,
		ScreenShotCtrl,
		BuyExpCtrl,
		-- 随机活动专用
		ServerActivityCtrl,
		AdvancedReturnCtrl,
		AdvancedReturnTwoCtrl,
		KaifuActivityCtrl,
		ActiviteHongBaoCtrl,
		RechargeRankCtrl,
		ConsumeRankCtrl,
		JuHuaSuanCtrl,
		FastChargingCtrl,
		GoldMemberCtrl,
		DisCountCtrl,
		ThreePieceCtrl,
		ExpRefineCtrl,
		CollectiveGoalsCtrl,
		JuBaoPenCtrl,
		LimitedFeedbackCtrl,
		YiZhanDaoDiCtrl,
		WorldQuestionCtrl,
		TreasureLoftCtrl,
		TimeLimitGiftCtrl,
		TreasureBusinessmanCtrl,
		FanFanZhuanCtrl,
		RepeatRechargeCtrl,
		LuckWishingCtrl,
		CrazyMoneyTreeCtrl,
		DoubleGoldCtrl,
		ScratchTicketCtr,
		LuckyShoppingCtrl,
		-- MiningController,
		JinYinTaCtrl,
		IncreaseCapabilityCtrl,
		IncreaseSuperiorCtrl,
		TimeLimitSaleCtrl,
		LuckyChessCtrl,
		TimeLimitBigGiftCtrl,
		ResetDoubleChongzhiCtrl,
		HefuActivityCtrl,
		-- PlantingCtrl,
		HuanzhuangShopCtrl,
		VersionsActivityCtrl,
		XingXiangCtrl,
		ActivityPanelLoginRewardCtrl,
		HappyErnieCtrl,
		ZhuanZhuanLeCtrl,
		GoldHuntCtrl,
		RareDialCtrl,
		MapFindCtrl,
		SingleRechargeCtrl,
		RechargeCapacityCtrl,
		DailyRebateCtrl,
		LongXingCtrl,
		LuckyDrawCtrl,
		CloakCtrl,
		KuafuGuildBattleCtrl,
		EquipmentShenCtrl,
		TulongEquipCtrl,
		FarmHuntingCtrl,
		BlackMarketCtrl,
		RechargeReturnRewardCtrl,
		OneYuanSnatchCtrl,
		KuaFuConsumeRankCtrl,
		SmallHelperCtrl,
		HappyRechargeCtrl,
		ImageFuLingCtrl,
		KuaFuTuanZhanCtrl,
		CornucopiaCtrl,
		FaBaoCtrl,
		LoopChargeCtrl,
		SingleRebateCtrl,
		-- FaBaoHuanHuaCtrl,
		-- WuQiHuanHuaCtrl,
		WangZheZhiJieCtrl,
		ZhiZunLingPaiCtrl,
		InvestCtrl,
		FishingCtrl,
		WeekendHappyCtrl,
		ImmortalCtrl,
		OneYuanBuyCtrl,
		KFMonthBlackWindHighCtrl,
		LittlePetCtrl,
		GroupPurchaseCtrl,
		LingKunBattleCtrl,
		ExpenseGiftCtrl,
		SecretrShopCtrl,
		ConsumeRewardCtrl,
		FestivalActivityCtrl,
		SecretTreasureHuntingCtrl,
		FestivalActivityQiQiuCtrl,
		FestivalSinglePartyCtrl,
		ShenqiCtrl,
		SuitCollectionCtrl,
		FourGradeEquipCtrl,
		GiftLimitBuyCtrl,
		CrazyHiCelebrationCtrl,
		ChristmaGiftCtrl,
		KuaFuBorderlandCtrl,
		EquimentSuitCtrl,
		PefectLoverCtrl,
		DouQiCtrl,
		CrazyHappyCtrl,
		ZhiZunRechargeRankCtrl,
		JingHuaHuSongCtrl,
	}
	if not self.is_quick_login then
		PushCtrl(self)
	end
end

function ModulesController:Update(now_time, elapse_time)
	local total_count = #self.push_list
	for i = 1, 24 do
		if self.cur_index < total_count then
			self.cur_index = self.cur_index + 1
			if nil ~= self.push_list[self.cur_index] then
				table.insert(self.ctrl_list, self.push_list[self.cur_index].New())
			end
		end
		if self.cur_index >= total_count then
			PopCtrl(self)
			break
		end
	end

	if self.state_callback then
		self.state_callback(self.cur_index / total_count)
	end
end

function ModulesController:Stop()

end

function ModulesController:CreateCoreModule()
	GameVoManager.New()
	ViewManager.New()
	AvatarManager.New()
	LoadingPriorityManager.New()
	AudioService.New()
	ChatRecordMgr.New()
	TimeCtrl.New()
	ClientCmdCtrl.New()
	OpenFunCtrl.New()
end

function ModulesController:CreateLoginModule()
	LoginCtrl.New()
end

function ModulesController:CreateGameModule()
	self:Start()
	for k,v in ipairs(self.push_list) do
		table.insert(self.ctrl_list, v.New())
	end
end

function ModulesController:DeleteLoginModule()
	if nil ~= LoginCtrl.Instance then
		LoginCtrl.Instance:DeleteMe()
	end
end

function ModulesController:DeleteGameModule()
	local count = #self.ctrl_list
	for i = count, 1, -1 do
		self.ctrl_list[i]:DeleteMe()
	end
	self.ctrl_list = {}

	for k,v in ipairs(self.push_list) do
		if v.Instance then
			print_error("Forget to set Instance = nil int \"__delete()\"? Ctrl  ->>", getmetatable(v.Instance).__index)
			v.Instance = nil
		end
	end
	self.push_list = {}
	self.cur_index = 0
end
