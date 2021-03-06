require("game/kaifuactivity/kaifu_activity_data")
require("game/kaifuactivity/kaifu_activity_view")
require("game/kaifuactivity/touzi_activity_view")
require("game/kaifuactivity/san_sheng_prog_view")

local PaiHangBang_Index = {PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT, PERSON_RANK_TYPE.PERSON_RANK_TYPE_WING, PERSON_RANK_TYPE.PERSON_RANK_TYPE_HALO,
					PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENGONG, PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENYI,
						[9] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP, [10] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP,
		}

KaifuActivityCtrl = KaifuActivityCtrl or BaseClass(BaseController)

function KaifuActivityCtrl:__init()
	if KaifuActivityCtrl.Instance ~= nil then
		print_error("[KaifuActivityCtrl] Attemp to create a singleton twice !")
	end

	KaifuActivityCtrl.Instance = self
	
	self.data = KaifuActivityData.New()
	self.view = KaifuActivityView.New(ViewName.KaifuActivityView)
	self.touzi_view = TouziActivityView.New(ViewName.TouziActivityView)
	self.san_sheng_view = SanShengProgView.New(ViewName.SanShengProgView)

	self.scene_load_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.SceneLoadComplete, self))
	self.time_quest = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.ServerOpenDay, self))
	self:RegisterAllProtocols()

	self.activity_change = BindTool.Bind(self.ActivityChange, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_change)

	self.main_role_level_change = GlobalEventSystem:Bind(ObjectEventType.LEVEL_CHANGE, BindTool.Bind(self.MainRoleLevelChange, self))
end

function KaifuActivityCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.san_sheng_view then
		self.san_sheng_view:DeleteMe()
		self.san_sheng_view = nil
	end

	if self.scene_load_complete ~= nil then
		GlobalEventSystem:UnBind(self.scene_load_complete)
		self.scene_load_complete = nil
	end

	if self.time_quest ~= nil then
		GlobalEventSystem:UnBind(self.time_quest)
		self.time_quest = nil
	end

	if self.main_role_level_change then
		GlobalEventSystem:UnBind(self.main_role_level_change)
		self.main_role_level_change = nil
	end

	if self.activity_change ~= nil then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_change)
		self.activity_change = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	KaifuActivityCtrl.Instance = nil
end

function KaifuActivityCtrl:GetView()
	return self.view
end

function KaifuActivityCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAOpenServerInfo, "OnKaifuActivityInfo")
	self:RegisterProtocol(SCRAOpenServerUpgradeInfo, "OnActivityUpgradeInfo")
	self:RegisterProtocol(SCRAOpenServerRankInfo, "OnOpenServerRankInfo")
	self:RegisterProtocol(SCRAOpenServerBossInfo, "OnOpenServerBossInfo")
	self:RegisterProtocol(SCRAOpenServerBattleInfo, "OnOpenServerBattleInfo")
	self:RegisterProtocol(SCRATotalChargeInfo, "OnRATotalChargeInfo")
	self:RegisterProtocol(CSRandActivityOperaReq)

	-- ????????????(???????????????)
	self:RegisterProtocol(SCCollectSecondExchangeInfo, "OnCollectSecondExchangeInfo")

	-- ????????????
	self:RegisterProtocol(SCRADayActiveDegreeInfo, "OnRADayActiveDegreeInfo")

	-- ??????????????????
	self:RegisterProtocol(SCRADayChongzhiRankInfo, "OnRADayChongzhiRankInfo")

	-- ??????????????????
	self:RegisterProtocol(SCRADayConsumeRankInfo, "OnRADayConsumeRankInfo")

	-- ???????????????
	self:RegisterProtocol(SCRASpecialAppearanceInfo, "OnRASpecialAppearanceInfo")

	-- ???????????????
	self:RegisterProtocol(SCRASpecialAppearancePassiveInfo, "OnRASpecialAppearancePassiveInfo")

	-- ????????????????????????
	self:RegisterProtocol(SCRAOpenGameGiftShopBuyInfo, "OnRAOpenGameGiftShopBuyInfo")

	-- ????????????(????????????)
	self:RegisterProtocol(SCRAPersonalPanicBuyInfo, "OnRAPersonalPanicBuyInfo")

	-- ????????????
	self:RegisterProtocol(SCRALimitBuyInfo, "OnRALimitBuyInfo")

	-- ?????????
	self:RegisterProtocol(SCRACollectTreasureInfo, "OnRACollectTreasureInfo")
	self:RegisterProtocol(SCRACollectTreasureResult, "OnRACollectTreasureResult")

	-- ????????????????????????
	self:RegisterProtocol(SCCollectExchangeInfo, "OnCollectExchangeInfo")

	-- ???????????????
	self:RegisterProtocol(SCRAContinueChongzhiInfoChu, "OnRAContinueChongzhiInfoChu")

	-- ???????????????
	self:RegisterProtocol(SCRAContinueChongzhiInfoGao, "OnRAContinueChongzhiInfoGao")

	--????????????????????????
	self:RegisterProtocol(SCGoldenPigOperateInfo, "OnGoldenPigCallInfo")
	--????????????Boss??????
	self:RegisterProtocol(SCGoldenPigBossState, "OnGoldenPigCallBossInfo")

	self:RegisterProtocol(SCOpenServerInvestInfo, "OnReciveInvestInfo")

	--????????????
	self:RegisterProtocol(SCRATotalConsumeGoldInfo, "OnSCRATotalConsumeGoldInfo")

	--??????????????????
	self:RegisterProtocol(SCRADayConsumeGoldInfo, "OnScRADailyTotalConsumeInfo")

	--????????????
	self:RegisterProtocol(SCRADayChongZhiFanLiInfo, "OnSCRADayChongZhiFanLiInfo")

	self:RegisterProtocol(SCChargeRewardInfo, "OnSCChargeRewardInfo")

	--????????????
	self:RegisterProtocol(SCOpenGameActivityInfo, "OnSCOpenGameActivityInfo")

	--????????????
	self:RegisterProtocol(SCRANewTotalChargeInfo, "OnSCRANewTotalChargeInfo")

	-- ????????????-????????????
	self:RegisterProtocol(SCRAServerPanicBuyInfo, "OnSCRAServerPanicBuyInfo")

	-- ????????????
	self:RegisterProtocol(SCLoveDailyInfo, "OnSCLoveDailyInfo")

	-- ????????????
	self:RegisterProtocol(SCRAEverydayNiceGiftInfo,"OnSCRAEverydayNiceGiftInfo")

	-- ????????????
	self:RegisterProtocol(SCRAConsumeGoldFanliInfo, "OnGetRewardInfo")

	-- ??????????????????
	-- self:RegisterProtocol(SCRAPerfectLoverInfo, "OnRAPerfectLoverInfo")

	-- ??????????????????
	self:RegisterProtocol(SCQuanMinJinJieInfo, "OnSCQuanMinJinJieInfo")

	-- ?????????????????????
	self:RegisterProtocol(SCUpgradeGroupeInfo, "OnSCUpgradeGroupeInfo")

	-- ?????????
	self:RegisterProtocol(SCRACriticalStrikeInfo, "OnSCRACriticalStrikeInfo")

	-- ????????????
	-- self:RegisterProtocol(SCRAJinJieReturnInfo, "OnSCRAJinJieReturnInfo")

	-- ?????????2
	self:RegisterProtocol(SCRACriticalStrike2Info, "OnSCRACriticalStrike2Info")

	-- ????????????2
	-- self:RegisterProtocol(SCRAJinJieReturnInfo2, "OnSCRAJinJieReturnInfo2")

	-- ????????????
	self:RegisterProtocol(SCRAHappyCumulChongzhiInfo, "OnSCRAHappyRechargeInfo")

	-- ???????????????????????????
	self:RegisterProtocol(SCRAOfflineSingleChargeInfo0, "OnSCRAOfflineSingleChargeInfo0")

	-- ????????????
	self:RegisterProtocol(SCRADanbiChongzhiInfo, "OnRADanbiChongzhiInfo")

	---------------------????????????------------------------------
	self:RegisterProtocol(CSGetShengxingzhuliInfoReq)
	self:RegisterProtocol(CSGetShengxingzhuliRewardReq)
	-----------------------------------------------------------
	----------????????????--------------------------------------------
	self:RegisterProtocol(SCRAHuanLeYaoJiangTwoInfo, "OnSCRAMiJingXunBaoTwoInfo")
	self:RegisterProtocol(SCRAHuanLeYaoJiangTwoTaoResultInfo, "OnSCRAHappyErnieTaoResultTwoInfo")
	------------------------------------------------------------------
	-- ????????????
	self:RegisterProtocol(SCRAVersionContinueChongzhiInfo, "OnRAContinueChongzhiInfoZhongQiu")
end

-- ????????????
function KaifuActivityCtrl:OnRAContinueChongzhiInfoZhongQiu(protocol)
	self.data:SetChongZhiZhongQiu(protocol)
	FestivalActivityCtrl.Instance:FlushLianXuChongZhi()
end


--??????????????????
function KaifuActivityCtrl:OnRADayActiveDegreeInfo(protocol)
	self.data:SetDayActiveDegreeInfo(protocol)
	if self.view:IsOpen() then
		FestivalActivityCtrl.Instance:FlushLianXuChongZhi()
	end
end

--?????????
function KaifuActivityCtrl:OnSCRACriticalStrikeInfo(protocol)
	self.data:SetBaojiDayActType(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

--?????????2
function KaifuActivityCtrl:OnSCRACriticalStrike2Info(protocol)
	self.data:SetBaojiDayActType2(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

function KaifuActivityCtrl:OnRADayChongzhiRankInfo(protocol)
	self.data:SetDayChongzhiRankInfo(protocol)
	if self.view:IsOpen() then
		self.view:FlushDayChongZhi()
		self.view:FlushDanBiChongZhi()
	end
end

function KaifuActivityCtrl:OnSCChargeRewardInfo(protocol)
	self.data:SetChargeRewardInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	self.data:FlushLeiJiChargeRewardRedPoint()
end

function KaifuActivityCtrl:OnSCRAServerPanicBuyInfo(protocol)
	self.data:SetFullServerSnapInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.QuanFuBuy)
	
end

function KaifuActivityCtrl:OnRADayConsumeRankInfo(protocol)
	self.data:SetDayConsumeRankInfo(protocol)
	if self.view:IsOpen() then
		self.view:FlushDayXiaoFei()
	end
end

function KaifuActivityCtrl:OnRASpecialAppearancePassiveInfo(protocol)
	self.data:SetSpecialAppearancePassiveInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

function KaifuActivityCtrl:OnRASpecialAppearanceInfo(protocol)
	self.data:SetSpecialAppearanceInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

-- ????????????
function KaifuActivityCtrl:OnKaifuActivityInfo(protocol)
	self.data:SetActivityInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.KaiFu)
	RemindManager.Instance:Fire(RemindName.BiPin)
	if ViewManager.Instance:IsOpen(ViewName.CompetitionActivity) then
		ViewManager.Instance:FlushView(ViewName.CompetitionActivity)
	end
end

-- ??????????????????????????????
function KaifuActivityCtrl:OnGoldenPigCallInfo(protocol)
	self.data:SetGoldenPigCallInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.KaiFu)
end
--------------????????????---------------
function KaifuActivityCtrl:OnSCRAMiJingXunBaoTwoInfo(protocol)
	local server_time = TimeCtrl.Instance:GetServerTime()
	self.data:SetRAHappyErnieInfo(protocol)							-- ?????????????????????
	--FestivalActivityCtrl.Instance:FlushView("autumnhappyerniebiew")
	if ViewManager.Instance:IsOpen(ViewName.FestivalView) then 
		FestivalActivityCtrl.Instance:FlushFengKuangYaoJiang()
	end
	RemindManager.Instance:Fire(RemindName.ZhongQiuHappyErnieFree)				-- ??????????????????
	RemindManager.Instance:Fire(RemindName.ZhongQiuHappyErnieGroup)				-- ??????????????????
	if server_time < protocol.ra_huanleyaojiang_next_free_tao_timestamp then
		RemindManager.Instance:AddNextRemindTime(RemindName.ZhongQiuHappyErnieFree, protocol.ra_huanleyaojiang_next_free_tao_timestamp - server_time)
	end
end

function KaifuActivityCtrl:OnSCRAHappyErnieTaoResultTwoInfo(protocol)
	self.data:SetRAHappyErnieTaoResultInfo(protocol)									-- ?????????????????????
	TipsCtrl.Instance:ShowTreasureView(self.data:GetChestShopMode())					-- ????????????????????????
	if ViewManager.Instance:IsOpen(ViewName.FestivalView) then 
		self.view:Flush()
		FestivalActivityCtrl.Instance:FlushFengKuangYaoJiang()
	end
	--FestivalActivityCtrl.Instance:FlushView("autumnhappyerniebiew")
	RemindManager.Instance:Fire(RemindName.ZhongQiuHappyErnieRemind)				-- ??????		
end
-------------------??????????????????------------------------------------------------------------
-- ????????????boss????????????
function KaifuActivityCtrl:OnGoldenPigCallBossInfo(protocol)
	self.data:SetGoldenPigCallBossInfo(protocol.boss_state)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.KaiFu)
end

function KaifuActivityCtrl:SendGetKaifuActivityInfo(rand_activity_type, opera_type, param_1, param_2)
	if IS_ON_CROSSSERVER then
		return
	end
	local protocol = ProtocolPool.Instance:GetProtocol(CSRandActivityOperaReq)
	protocol.rand_activity_type = rand_activity_type or 0
	protocol.opera_type = opera_type or 0
	protocol.param_1 = param_1 or 0
	protocol.param_2 = param_2 or 0
	protocol:EncodeAndSend()
--	LeiJiRechargeCtrl.Instance:LeiJiRechargeFlush()
end

-- ??????????????????
function KaifuActivityCtrl:OnActivityUpgradeInfo(protocol)
	self.data:SetActivityUpgradeInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.KaiFu)
end

function KaifuActivityCtrl:OnOpenServerRankInfo(protocol)
	self.data:SetOpenServerRankInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.KaiFu)
end

-- ????????????boss??????????????????
function KaifuActivityCtrl:OnOpenServerBossInfo(protocol)
	self.data:SetBossLieshouInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.KaiFu)

	if not self.data:IsShowKaifuIcon() and self.view:IsOpen() then
		self.view:Close()
	end
end

-- ??????????????????????????????
function KaifuActivityCtrl:OnRATotalChargeInfo(protocol)
	self.data:SetLeiJiChongZhiInfo(protocol)
	self.view:Flush()
	LeiJiRechargeCtrl.Instance:LeiJiRechargeFlush()
	RemindManager.Instance:Fire(RemindName.KaiFu)
	RemindManager.Instance:Fire(RemindName.KfLeichong)
	ViewManager.Instance:FlushView(ViewName.Main, "leiji_charge")
end

-- ??????????????????????????????
function KaifuActivityCtrl:OnOpenServerBattleInfo(protocol)
	self.data:SetBattleUidInfo(protocol)
	if protocol.yuansu_uid > 0 then
		CheckCtrl.Instance:SendQueryRoleInfoReq(protocol.yuansu_uid)
	end
	if protocol.guildbatte_uid > 0 then
		CheckCtrl.Instance:SendQueryRoleInfoReq(protocol.guildbatte_uid)
	end
	if protocol.gongchengzhan_uid > 0 then
		CheckCtrl.Instance:SendQueryRoleInfoReq(protocol.gongchengzhan_uid)
	end
	if protocol.territorywar_uid > 0 then
		CheckCtrl.Instance:SendQueryRoleInfoReq(protocol.territorywar_uid)
	end
	self.view:Flush()
end

function KaifuActivityCtrl:GetKaiFuHuoDongTime()
	self.view:GetKaiFuTime()
end

-- ??????????????????????????????
function KaifuActivityCtrl:SetBattleRoleInfo(uid, protocol)
	local uid_info = self.data:GetBattleUidInfo()
	if uid_info then
		for k, v in pairs(uid_info) do
			if v == uid and v > 0 and not self.data:GetBattleRoleInfo()[k] then
				self.data:SetBattleRoleInfo(k, protocol)
				CollectiveGoalsCtrl.Instance:GetView():Flush()
				if self.view:IsOpen() then
					self.view:Flush()
				end
				break
			end
		end
	end
end

-- ????????????????????????
function KaifuActivityCtrl:OnRAOpenGameGiftShopBuyInfo(protocol)
	self.data:SetGiftShopFlag(protocol)

	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.LiBaoBuy)
end

-- ????????????
function KaifuActivityCtrl:SendRAOpenGameGiftShopBuy(seq)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRAOpenGameGiftShopBuy)
	protocol.seq = seq or 0
	protocol:EncodeAndSend()
end

-- ??????????????????
function KaifuActivityCtrl:SendRAOpenGameGiftShopBuyInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSRAOpenGameGiftShopBuyInfoReq)
	protocol:EncodeAndSend()
end

--????????????????????????
function KaifuActivityCtrl:SendGoldenPigCallInfoReq(operate_type, param)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGoldenPigOperateReq)
	send_protocol.operate_type = operate_type or 0
	send_protocol.param = param or 0

	send_protocol:EncodeAndSend()
end

-- ??????????????????????????????
function KaifuActivityCtrl:OnRAPersonalPanicBuyInfo(protocol)
	self.data:SetPersonalBuyInfo(protocol.buy_numlist)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.PersonBuy)
	ViewManager.Instance:FlushView(ViewName.TipsCommonBuyView)
end

-- ??????????????????
function KaifuActivityCtrl:OnRALimitBuyInfo(protocol)
	self.data:SetEverydayBuyInfo(protocol.had_buy_count)
	self.data:SetEverydayBuyActType(protocol.act_type)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.EveryDayBuy)
	ViewManager.Instance:FlushView(ViewName.TipsCommonBuyView)
end

----------------------------------????????????-------------------------------------
function KaifuActivityCtrl:OnSCRAEverydayNiceGiftInfo(protocol)
	self.data:SetDailyGiftInfo(protocol)
	FestivalActivityCtrl.Instance:FlushDailyGiftView()
	-- RemindManager.Instance:Fire(RemindName.DailyGiftRemind)
end

-- ???????????????(????????????)
function KaifuActivityCtrl:OnCollectSecondExchangeInfo(protocol)
	self.data:SetCollectMoonExchangeInfo(protocol.collection_exchange_times)
	if ViewManager.Instance:IsOpen(ViewName.FestivalView) then 
		FestivalActivityCtrl.Instance:FlushMakeMoonCake()
	end
	RemindManager.Instance:Fire(RemindName.KaiFu)
end

-- ????????????????????????
function KaifuActivityCtrl:OnCollectExchangeInfo(protocol)
	self.data:SetCollectExchangeInfo(protocol.exchange_times)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.KaiFu)
end

function KaifuActivityCtrl:FlushKaifuView()
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

function KaifuActivityCtrl:ServerOpenDay(cur_day, is_new_day)
	if not is_new_day or IS_ON_CROSSSERVER then return end

	if not self.data:IsShowKaifuIcon() then
		if self.view:IsOpen() then
			self.view:Close()
		end
		return
	end
	if self.data:IsShowKaifuIcon() then

		self.data:ClearActivityInfo()

		local list = self.data:GetOpenActivityList()
		if list == nil or next(list) == nil then
			return
		end

		for k, v in pairs(list) do
			if self.data.info[v.activity_type] == nil then
				if self.data:IsBossLieshouType(v.activity_type) then
					self:SendGetKaifuActivityInfo(v.activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_BOSS_INFO)
				elseif self.data:IsZhengBaType(v.activity_type) then
					self:SendGetKaifuActivityInfo(v.activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH_BATTE_INFO)
				elseif v.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPPER_GIFT then 	--????????????????????????
					self:SendRAOpenGameGiftShopBuyInfo()
				elseif v.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUNDER_TIMES_SHOP then --??????????????????
					self:SendGetKaifuActivityInfo(v.activity_type, RA_PERSONAL_PANIC_BUY_OPERA_TYPE.RA_PERSONAL_PANIC_BUY_OPERA_TYPE_QUERY_INFO)
				elseif v.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EVERY_DAY_SNAP then --????????????
					self:SendGetKaifuActivityInfo(v.activity_type, RA_LIMIT_BUY_OPERA_TYPE.RA_LIMIT_BUY_OPERA_TYPE_INFO)
				elseif v.activity_type and v.activity_type > 0 then
					self:SendGetKaifuActivityInfo(v.activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
				end
			end

			if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.COMBINE_SERVER) then
				HefuActivityCtrl.Instance:SendCSAQueryActivityInfo()
				HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_INVALID)
				HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BOSS, CSA_BOSS_OPERA_TYPE.CSA_BOSS_OPERA_TYPE_INFO_REQ)
				HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BOSS, CSA_BOSS_OPERA_TYPE.CSA_BOSS_OPERA_TYPE_RANK_REQ)
				HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BOSS, CSA_BOSS_OPERA_TYPE.CSA_BOSS_OPERA_TYPE_ROLE_INFO_REQ)
			end
		end
		self.view:Flush()
	end
end

function KaifuActivityCtrl:SceneLoadComplete()
	-- ?????????
	if IS_ON_CROSSSERVER then return end

	if self.data:IsShowKaifuIcon() then
		local list = self.data:GetOpenActivityList(TimeCtrl.Instance:GetCurOpenServerDay())
		if list == nil or next(list) == nil then return end
		for k, v in pairs(list) do
			if self.data.info[v.activity_type] == nil then
				if self.data:IsBossLieshouType(v.activity_type) then
					self:SendGetKaifuActivityInfo(v.activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_BOSS_INFO)
				elseif self.data:IsZhengBaType(v.activity_type) then
					self:SendGetKaifuActivityInfo(v.activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH_BATTE_INFO)
				elseif v.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPPER_GIFT then 	--????????????????????????
					self:SendRAOpenGameGiftShopBuyInfo()
				elseif v.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUNDER_TIMES_SHOP then --??????????????????
					self:SendGetKaifuActivityInfo(v.activity_type, RA_PERSONAL_PANIC_BUY_OPERA_TYPE.RA_PERSONAL_PANIC_BUY_OPERA_TYPE_QUERY_INFO)
				elseif v.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EVERY_DAY_SNAP then --????????????
					self:SendGetKaifuActivityInfo(v.activity_type, RA_LIMIT_BUY_OPERA_TYPE.RA_LIMIT_BUY_OPERA_TYPE_INFO)
				elseif v.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GOLDEN_PIG then 	--??????????????????
					self:SendGoldenPigCallInfoReq(GOLDEN_PIG_OPERATE_TYPE.GOLDEN_PIG_OPERATE_TYPE_REQ_INFO)
				elseif v.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_ACTIVIE_DEGREE then	--????????????
					self:SendGetKaifuActivityInfo(v.activity_type, RA_DAY_ACTIVE_DEGREE_OPERA_TYPE.RA_DAY_ACTIVE_DEGREE_OPERA_TYPE_QUERY_INFO)
				elseif v.activity_type and v.activity_type > 0 then
					self:SendGetKaifuActivityInfo(v.activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
				end
			end
		end
	end
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.COMBINE_SERVER) then
		HefuActivityCtrl.Instance:SendCSAQueryActivityInfo()
		HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_INVALID)
		HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BOSS, CSA_BOSS_OPERA_TYPE.CSA_BOSS_OPERA_TYPE_INFO_REQ)
		HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BOSS, CSA_BOSS_OPERA_TYPE.CSA_BOSS_OPERA_TYPE_RANK_REQ)
		HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BOSS, CSA_BOSS_OPERA_TYPE.CSA_BOSS_OPERA_TYPE_ROLE_INFO_REQ)
	end	
	RemindManager.Instance:Fire(RemindName.LiBaoBuy)
	RemindManager.Instance:Fire(RemindName.PersonBuy)
	RemindManager.Instance:Fire(RemindName.QuanFuBuy)
	RemindManager.Instance:Fire(RemindName.EveryDayBuy)

	self:MainRoleLevelChange()
end

function KaifuActivityCtrl:OnSCOpenGameActivityInfo(protocol)
	self.data:SetOpenGameActivityInfo(protocol)
	self.view:FlushGuildFight()
end

--????????????????????????????????????
function KaifuActivityCtrl:CloseKaiFuView()
	self.view:Close()
end

function KaifuActivityCtrl:MainRoleLevelChange()
	local is_act_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_DAILY_LOVE)
	local level_open = ActivityData.Instance:GetIsOpenLevel(ACTIVITY_TYPE.RAND_DAILY_LOVE)
	local today_charge = RechargeData.Instance:GetTodayRecharge()
	if today_charge <= 0 and is_act_open and level_open then
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.DailyLove, ClickOnceRemindList[RemindName.DailyLove] == 1)
	end
end

function KaifuActivityCtrl:ActivityChange(activity_type, status, next_time, open_type)
	-- ?????????
	if IS_ON_CROSSSERVER then return end

	if not self.data:IsShowKaifuIcon() and (KaifuActivityType.TYPE == activity_type and status ~= ACTIVITY_STATUS.OPEN) then
		if self.view:IsOpen() then
			self.view:Close()
		end
		return
	end

	if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ZHENG_BA) then
		local act_info = ActivityData.Instance:GetActivityStatuByType(activity_type) or {}
		if act_info.status ~= status then
			self:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ZHENG_BA,
				RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH_BATTE_INFO)
		end
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FULL_SERVER_SNAP and status == ACTIVITY_STATUS.OPEN then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FULL_SERVER_SNAP, RA_CHARGE_REPAYMENT_OPERA_TYPE.RA_SERVER_PANIC_BUY_OPERA_TYPE_QUERY_INFO)
	end

	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EVERYDAY_NICE_GIFT and status == ACTIVITY_STATUS.OPEN then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EVERYDAY_NICE_GIFT, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	end

	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_YAOJIANG2 and status == ACTIVITY_STATUS.OPEN then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_YAOJIANG2, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	end

	if activity_type == ACTIVITY_TYPE.RAND_ACTIVEIY_TYPE_LIANXUCHONGZHI and status == ACTIVITY_STATUS.OPEN then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVEIY_TYPE_LIANXUCHONGZHI, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	end

	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAKE_MOONCAKE and status == ACTIVITY_STATUS.OPEN then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAKE_MOONCAKE, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	end

	if activity_type == ACTIVITY_TYPE.RAND_DAY_DANBI_CHONGZHI and status == ACTIVITY_STATUS.OPEN then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_DAY_DANBI_CHONGZHI, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	end

	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_VERSIONS_GRAND_TOTAL_CHARGE and status == ACTIVITY_STATUS.OPEN then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_VERSIONS_GRAND_TOTAL_CHARGE, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	end
	
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXTREME_CHALLENGE and status == ACTIVITY_STATUS.OPEN then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXTREME_CHALLENGE, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	end
	
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_SUPER_LUCKY_STAR and status == ACTIVITY_STATUS.OPEN then
		RareDialCtrl.Instance:SendInfo(RA_EXTREME_LUCKY_OPERA_TYPE.RA_EXTREME_LUCKY_OPERA_TYPE_QUERY_INFO)
	end

	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAP_HUNT and status == ACTIVITY_STATUS.OPEN then
		MapFindCtrl.Instance:SendInfo()
	end

	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHONGZHI_CRAZY_REBATE then
		local level = PlayerData.Instance.role_vo.level
		local act_cfg = ActivityData.Instance:GetActivityConfig(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHONGZHI_CRAZY_REBATE)
		if status == ACTIVITY_STATUS.OPEN then
			if act_cfg ~= nil and level >= act_cfg.min_level then
				MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.ReturnRecharge, true)
			end
		elseif status == ACTIVITY_STATUS.CLOSE then
			MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.ReturnRecharge, false)
		end
	end

	-- ???????????????????????????b?????????????????????????????????????????????????????????
	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_RETURN and status == ACTIVITY_STATUS.OPEN then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_RETURN, RA_JINJIE_RETURN_OPERA_TYPE.RA_JINJIE_RETURN_OPERA_TYPE_INFO)
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPLEVEL_RETURN_2 and status == ACTIVITY_STATUS.OPEN then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPLEVEL_RETURN_2, RA_JINJIE_RETURN_OPERA_TYPE.RA_JINJIE_RETURN_OPERA_TYPE_INFO)
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BAOJI_DAY and status == ACTIVITY_STATUS.OPEN then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BAOJI_DAY, RA_JINJIE_RETURN_OPERA_TYPE.RA_JINJIE_RETURN_OPERA_TYPE_INFO)
	end
	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CRITICAL_STRIKE_DAY_2 and status == ACTIVITY_STATUS.OPEN then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CRITICAL_STRIKE_DAY_2, RA_JINJIE_RETURN_OPERA_TYPE.RA_JINJIE_RETURN_OPERA_TYPE_INFO)
	end

	if activity_type == ACTIVITY_TYPE.RAND_DAILY_LOVE then
		if status == ACTIVITY_STATUS.CLOSE then
			MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.DailyLove, false)
		else
			local is_today_charge = RechargeData.Instance:GetTodayRecharge()
			local is_visible = is_today_charge <= 0
			MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.DailyLove, is_visible)
		end
	end
end

function KaifuActivityCtrl:OnRAContinueChongzhiInfoChu(protocol)
	self.data:SetChongZhiChu(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.LianChongTeHuiChu)
end

function KaifuActivityCtrl:OnRAContinueChongzhiInfoGao(protocol)
	self.data:SetChongZhiGao(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.LianChongTeHuiGao)
end

function KaifuActivityCtrl:SendRandActivityOperaReq(rand_activity_type, opera_type, param_1, param_2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRandActivityOperaReq)
	protocol.rand_activity_type = rand_activity_type
	protocol.opera_type = opera_type
	protocol.param_1 = param_1 or 0
	protocol.param_2 = param_2 or 0
	protocol:EncodeAndSend()
end


function KaifuActivityCtrl:OnReciveInvestInfo(protocol)
	self.data:FlushInvestData(protocol)
	local info = ActivityData.Instance:GetActivityStatuByType(2176)
	info.status = ACTIVITY_STATUS.CLOSE

	for k,v in pairs(KAIFU_INVEST_TYPE) do
		local invest_statu = KaifuActivityData.Instance:GetInvestStateByType(v)
		if invest_statu ~= INVEST_STATE.outtime and invest_statu ~= INVEST_STATE.complete then
			info.status = ACTIVITY_STATUS.OPEN
		end
	end
end

function KaifuActivityCtrl:OnSCRATotalConsumeGoldInfo(protocol)
	self.data:SetRATotalConsumeGoldInfo(protocol)
	self.view:FlushTotalConsume()
	self.data:FlushTotalConsumeHallRedPoindRemind()
end

function KaifuActivityCtrl:OnScRADailyTotalConsumeInfo(protocol)
	self.data:SetDailyTotalConsumeInfo(protocol)
	self.view:FlushDialyTotalConsume()
	self.data:FlushDialyTotalConsumeRedPoindRemind()
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

function KaifuActivityCtrl:OnSCRANewTotalChargeInfo(protocol)
	self.data:SetRANewTotalChargeInfo(protocol)
	self.view:FlushTotalCharge()
	-- self.data:FlushTotalChargeHallRedPoindRemind()
end

function KaifuActivityCtrl:OnSCRADayChongZhiFanLiInfo(protocol)
	self.data:SetRARechargeRebateInfo(protocol)
	self.view:FlushRechargeRebate()
end

function KaifuActivityCtrl:FlushView(key)
	if self.view:IsOpen() then
		self.view:Flush(key)
	end
end

function KaifuActivityCtrl:OnSCLoveDailyInfo(protocol)
	self.data:SetDailyLoveFlag(protocol.flag)
end

function KaifuActivityCtrl:OnGetRewardInfo(protocol)
	self.data:SetRewardFlag(protocol)
	self.view:Flush()
end

function KaifuActivityCtrl:OnRAPerfectLoverInfo(protocol)
	self.data:SetPerfectLoverInfo(protocol)
	self.san_sheng_view:Flush()
	self.view:FlushSanShengSanShi()
end

function KaifuActivityCtrl:OnSCQuanMinJinJieInfo(protocol)
	self.data:SetQuanMinJinJieInfo(protocol)
	self.view:FlushQuanMinJinjie()
	self.view:Flush()
	
end

function KaifuActivityCtrl:OnSCUpgradeGroupeInfo(protocol)
	self.data:SetQuanMinGroupInfo(protocol)
	self.view:FlushQuanMinGroup()
	-- self.view:Flush()
end

function KaifuActivityCtrl:ExpenseViewStartRoll()
	self.view:ExpenseViewStartRoll()
end

function KaifuActivityCtrl:ExpenseViewStartTenRoll()
	self.view:ExpenseViewStartTenRoll()
end

function KaifuActivityCtrl:OnRACollectTreasureInfo(protocol)
	self.data:SetJuBaoPenInfo(protocol)
	self.view:FlushJuBaoPen()
	self.view:Flush()
end

function KaifuActivityCtrl:OnRACollectTreasureResult(protocol)
	self.data:SetJuBaoPenResult(protocol)
	self.view:FlushJuBaoPen()
	self.view:Flush()
end

function KaifuActivityCtrl:OnSCRAJinJieReturnInfo(protocol)
	self.data:SetUpGradeReturnInfo(protocol)
	self.view:Flush()
	self.view:FlushUpGradeReturn()
end

function KaifuActivityCtrl:OnSCRAJinJieReturnInfo2(protocol)
	self.data:SetUpGradeReturnInfo2(protocol)
	self.view:Flush()
	self.view:FlushUpGrade2Return()
end

function KaifuActivityCtrl:OnSCRAHappyRechargeInfo(protocol)
	self.data:SetHuanLeLeiChongInfo(protocol)
	self.view:Flush()
	self.view:FlushHappyRecharge()
end


function KaifuActivityCtrl:OnSCRAOfflineSingleChargeInfo0(protocol)
	self.data:SetSingleInfo(protocol)
	FestivalActivityCtrl.Instance:FlushHappyDanBiChongZhi()
end

-- ????????????
function KaifuActivityCtrl:OnRADanbiChongzhiInfo(protocol)
	self.data:SetDailyDanBiInfo(protocol)
	self.data:FlushDailyDanBiHallRedPoindRemind()
	self.view:Flush()
	self.view:FlushDailyDanBi()
	-- FestivalActivityCtrl.Instance:FlushDailyDanBi()
end

-- ????????????
function KaifuActivityCtrl:FlushLoginReward()
	self.view:Flush()
	self.view:FlushLoginReward()
end

function KaifuActivityCtrl:FlushTouZiPlan()
	if self.view:IsOpen() then
		self.view:Flush()
		self.view:FlushTouZiPlan()
	end
end

function KaifuActivityCtrl:FlushLevelInvestmentView()
	if self.view:IsOpen() then
		self.view:Flush()
		self.view:FlushLevelInvestmentView()
	end
end

function KaifuActivityCtrl:FlushFuBenTouZi()
	if self.touzi_view:IsOpen() then
		self.touzi_view:Flush()
		self.touzi_view:FlushFuBenTouZi()
	end
end

function KaifuActivityCtrl:FlushBossTouZi()
	if self.touzi_view:IsOpen() then
		self.touzi_view:Flush()
		self.touzi_view:FlushBossTouZi()
	end
end

function KaifuActivityCtrl:FlushShenYuBossTouZi()
	if self.touzi_view:IsOpen() then
		self.touzi_view:Flush()
		self.touzi_view:FlushShenYuBossTouZi()
	end
end

-- ????????????
function KaifuActivityCtrl:FlushHeFuTouZiView()
	self.view:FlushHeFuTouZiView()
end