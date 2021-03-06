require("game/boss/boss_view")
require("game/boss/boss_data")
require("game/boss/world_boss_fight_view")
require("game/boss/dabao_fam_fight_view")
require("game/boss/boss_family_fight_view")
require("game/boss/boss_family_fight_view_two")
require("game/boss/active_fam_fight_view")
require("game/boss/baby_boss_fight_view")
require("game/boss/dabao_enter_consum_view")
require("game/boss/shanggu_boss_fight_view")
require("game/boss/tipsreward_bosstujian_view")
require("game/boss/cross_fam_fight_view")
require("game/boss/drop_view")
require("game/boss/active_boss_rand_reward_view")
require("game/fuben/fu_ben_view")
require("game/boss/tips_boss_enter")
-- require("game/boss/secret_boss_fight_view")
BossCtrl = BossCtrl or  BaseClass(BaseController)

-- local TIPSHIDETIME = 7200
-- local TIPSHIDETIME3 = 1800
local SEND_REASON = false
function BossCtrl:__init()
	self.is_first = true
	if BossCtrl.Instance ~= nil then
		print_error("[BossCtrl] attempt to create singleton twice!")
		return
	end
	BossCtrl.Instance = self

	self:RegisterAllProtocols()

	self.view = BossView.New(ViewName.Boss)
	self.fu_ben_view = FuBenView.New(ViewName.FuBen)
	self.data = BossData.New()
	self.world_boss_fight_view = WorldBossFightView.New()
	self.dabao_fam_fight_view = DabaoFamFightView.New(ViewName.DabaoBossInfoView)
	self.active_fam_fight_view = ActiveFamFightView.New(ViewName.ActiveBossInfoView)
	self.boss_family_fight_view = BossFamilyFightView.New(ViewName.BossFamilyInfoView)
	self.boss_family_fight_view_two = BossFamilyFightViewTwo.New(ViewName.BossFamilyFightViewTwo)
	self.baby_boss_fight_view = BabyBossFightView.New(ViewName.BabyBossFightView)
	self.shanggu_fight_view = ShangguBossFightView.New(ViewName.ShangguBossFightView)
	self.cross_fam_fight_view = CrossFamFightView.New(ViewName.CrossBossFightView)
	self.dabao_enter_view = DabaoEnterConsumView.New()
	self.tips_reward_bosstujian_view = TipsRewardBossTujianView.New()
	self.drop_view = DropContentView.New(ViewName.DropView)
	self.active_boss_rand_reward_view = ActiveBossRankRewardView.New(ViewName.ActiveBossRankRewardView)
	self.boss_enter_tips = BossEnterTips.New()
	-- self.secret_boss_fight_view = SecretBossFightView.New(ViewName.SecretBossFightView)
	-- self.is_show_spirit_meet_tips = false

	--????????????boss?????????(???????????????????????????????????????)
	self.miku_elite_tips_call_back = BindTool.Bind(self.MiKuEliteTipsCallBack, self)
end

function BossCtrl:GetView()
	return self.view
end

function BossCtrl:__delete()
	self.is_first = nil
	self.last_role_obj_id = nil
	
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.fu_ben_view ~= nil then
		self.fu_ben_view:DeleteMe()
		self.fu_ben_view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.world_boss_fight_view then
		self.world_boss_fight_view:DeleteMe()
		self.world_boss_fight_view = nil
	end

	if self.dabao_fam_fight_view ~= nil then
		self.dabao_fam_fight_view:DeleteMe()
		self.dabao_fam_fight_view = nil
	end

	if self.boss_family_fight_view ~= nil then
		self.boss_family_fight_view:DeleteMe()
		self.boss_family_fight_view = nil
	end

	if self.boss_family_fight_view_two ~= nil then
		self.boss_family_fight_view_two:DeleteMe()
		self.boss_family_fight_view_two = nil
	end

	if self.active_fam_fight_view ~= nil then
		self.active_fam_fight_view:DeleteMe()
		self.active_fam_fight_view = nil
	end

	if self.baby_boss_fight_view ~= nil then
		self.baby_boss_fight_view:DeleteMe()
		self.baby_boss_fight_view = nil
	end

	if self.shanggu_fight_view ~= nil then
		self.shanggu_fight_view:DeleteMe()
		self.shanggu_fight_view = nil
	end

	if self.boss_enter_tips ~= nil then
		self.boss_enter_tips:DeleteMe()
		self.boss_enter_tips = nil
	end

	if nil ~= self.dabao_enter_view then 
		self.dabao_enter_view:DeleteMe()
		self.dabao_enter_view = nil
	end

	if self.boss_timer then
		GlobalTimerQuest:CancelQuest(self.boss_timer)
		self.boss_timer = nil
	end

	if self.miku_elite_time_quest then
		GlobalTimerQuest:CancelQuest(self.miku_elite_time_quest)
		self.miku_elite_time_quest = nil
	end

	-- self:CancelCountDown2()
	if self.login_server_call then
		GlobalEventSystem:UnBind(self.login_server_call)
	end

	if self.send_status then
		GlobalTimerQuest:CancelQuest(self.send_status)
		self.send_status = nil
	end

	BossCtrl.Instance = nil
end

function BossCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCWorldBossInfo, "OnWorldBossInfo")
	self:RegisterProtocol(SCWorldBossBorn, "OnWorldBossBorn")
	self:RegisterProtocol(SCWorldBossSendPersonalHurtInfo, "OnWorldBossSendPersonalHurtInfo")
	self:RegisterProtocol(SCWorldBossSendGuildHurtInfo, "OnWorldBossSendGuildHurtInfo")
	self:RegisterProtocol(SCWorldBossWeekRankInfo, "OnWorldBossWeekRankInfo")
	self:RegisterProtocol(SCWorldBossCanRoll, "OnWorldBossCanRoll")
	self:RegisterProtocol(SCWorldBossRollInfo, "OnWorldBossRollInfo")
	self:RegisterProtocol(SCWorldBossRollTopPointInfo, "OnWorldBossRollTopPointInfo")

	self:RegisterProtocol(SCDabaoBossInfo, "OnDabaoBossInfo")			--??????boss??????
	self:RegisterProtocol(SCFamilyBossInfo, "OnFamilyBossInfo")			--boss??????boss??????
	self:RegisterProtocol(SCMikuBossInfo, "OnMikuBossInfo")			--??????boss??????
	self:RegisterProtocol(SCMikuMonsterInfo, "OnMikuMonsterInfo")			--????????????????????????????????????????????????????????????????????????????????????
	self:RegisterProtocol(SCBossRoleInfo, "OnSCBossRoleInfo")			--?????????????????????
	self:RegisterProtocol(SCDabaoBossNextFlushInfo, "OnSCDabaoBossNextFlushInfo")			--????????????
	self:RegisterProtocol(SCBossInfoToAll, "OnSCBossInfoToAll")				--??????boss??????
	self:RegisterProtocol(SCWorldBossInfoToAll, "OnSCWorldBossInfoToAll")	--????????????boss??????
	self:RegisterProtocol(SCBossKillerList, "OnSCBossKillerList")			--??????boss??????
	self:RegisterProtocol(SCWorldBossKillerList, "OnSCWorldBossKillerList")				--????????????boss??????
	self:RegisterProtocol(SCFollowBossInfo, "OnSCFollowBossInfo")				--boss??????????????????
	self:RegisterProtocol(SCWorldBossWearyInfo, "SCWorldBossWearyInfo")				--boss?????????????????????
	self:RegisterProtocol(SCActiveBossNextFlushInfo, "OnSCActiveBossNextFlushInfo")				--??????boss??????????????????
	self:RegisterProtocol(SCActiveBossInfo, "OnActiveBossInfo")				--??????boss??????
	self:RegisterProtocol(SCActiveBossHurtRank, "OnActiveBossHurtRank")				--??????boss????????????
	self:RegisterProtocol(SCActiveBossLeaveInfo, "OnActiveBossLeaveInfo")				--????????????boss??????????????????
	self:RegisterProtocol(SCMikuBossHurtRankInfo, "OnMikuBossHurtRankInfo")				--??????boss????????????
	self:RegisterProtocol(SCMikuBossLeaveInfo, "OnMikuBossLeaveInfo")				--????????????boss??????????????????
	self:RegisterProtocol(SCPersonBossInfo, "OnPersonBossInfo")				--??????Boss??????
	self:RegisterProtocol(CSPersonBossInfoReq)											--??????Boss????????????


	-- ---------------------??????boss--------------------------

	self:RegisterProtocol(SCCrossBossPlayerInfo, "OnCrossBossPlayerInfo")        -- ????????????
	self:RegisterProtocol(SCCrossBossSceneInfo, "OnCrossBossSceneInfo")	         -- ???????????????
	self:RegisterProtocol(SCCrossBossBossKillRecord, "OnCrossBossBossKillRecord")-- ????????????
	self:RegisterProtocol(SCCrossBossDropRecord, "OnCrossBossDropRecord")        -- ????????????
	self:RegisterProtocol(SCReliveTire, "OnCrossBossReliveTire")        -- ????????????
	self:RegisterProtocol(SCCrossBossBossInfoAck, "OnCrossBossBossInfoAck")        -- ??????boss??????
	self:RegisterProtocol(CSCrossBossBossInfoReq) 
	-------------------------boss??????--------------------------
	self:RegisterProtocol(CSBossCardReq)
	self:RegisterProtocol(SCBossCardAllInfo, "OnSCBossCardAllInfo")

	-- ---------------??????Boss-----------------------------
	-- self:RegisterProtocol(SCPreciousBossTaskInfo, "OnBossTaskInfo")
	-- self:RegisterProtocol(SCPreciousBossInfo, "OnPreciousBossInfo")
	-- self:RegisterProtocol(SCPreciousPosInfo, "OnPreciousPosInfo")
	-- ---------------??????Boss end ------------------------

		--??????boss
	self:RegisterProtocol(CSBabyBossOperate)
	self:RegisterProtocol(SCBabyBossRoleInfo, "OnBabyBossRoleInfo")						--??????boss????????????
	self:RegisterProtocol(SCAllBabyBossInfo, "OnBabyBossAllInfo")						--??????boss??????
	self:RegisterProtocol(SCSingleBabyBossInfo, "OnBabyBossSingleInfo")					--????????????boss??????

	self:RegisterProtocol(CSGetWorldBossInfo)							--????????????boss??????

	self.login_server_call = GlobalEventSystem:Bind(LoginEventType.GAME_SERVER_CONNECTED, BindTool.Bind(self.LoginCallBack, self))

	self:RegisterProtocol(SCBossDpsFlag, "OnBossDpsInfo")
	self:RegisterProtocol(SCBossDpsFlagInfo, "OnSCBossDpsFlagInfo")
	self:RegisterProtocol(SCBossFirstHurtInfo, "OnBossFirstHurtInfo")
	self:RegisterProtocol(SCMonsterFirstHitInfo, "OnMonsterFirstHitInfo")

	self:RegisterProtocol(CSWorldBossHPInfoReq)
	self:RegisterProtocol(SCWorldBossHPInfo, "OnBossHpInfo")

		--????????????
	self:RegisterProtocol(CSGetDropLog)
	self:RegisterProtocol(SCDropLogRet, "OnDropLogRet")

	---------------------????????????--------------------------
	self:RegisterProtocol(CSShangGuBossEnterReq)
	self:RegisterProtocol(SCShangGuBossAllInfo, "OnShangGuBossAllInfo")
	self:RegisterProtocol(SCShangGuBossLayerInfo, "OnShangGuBossLayerInfo")
	self:RegisterProtocol(SCShangGuBossSceneInfo, "OnShangGuBossSceneInfo")
	self:RegisterProtocol(SCShangGuBossSceneOtherInfo, "OnShangGuBossSceneOtherInfo")

	-- ????????????BOSS
	self:RegisterProtocol(CSJingLingAdvantageBossEnter)
	self:RegisterProtocol(SCJingLingAdvantageBossInfo, "OnEncounterBossInfo")

	self:RegisterProtocol(SCNoticeBossDead, "OnNoticeBossDead")
end

function BossCtrl:SetRewardTips(str, has_got)
	self.tips_reward_bosstujian_view:SetData(str, has_got)
end

function BossCtrl:SetBossHpInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSWorldBossHPInfoReq)
	protocol:EncodeAndSend()
end

function BossCtrl:OnBossHpInfo(protocol)
	self.data:SetBossHpInfo(protocol)
	self.world_boss_fight_view:Flush()
end

function BossCtrl:OnBossDpsInfo(protocol)
	local monster_obj = Scene.Instance:GetObj(protocol.monster_obj_id)
	if monster_obj and monster_obj:IsMonster() then
		monster_obj:SetDpsTargetName(protocol.owner_user_name or "")
	end
end
function BossCtrl:OnSCBossDpsFlagInfo(protocol)
	local role_obj = Scene.Instance:GetObj(protocol.obj_id)
	if role_obj and role_obj:IsRole() then
		role_obj:SetAttr("top_dps_flag", protocol.dps_flag)
	end
end

function BossCtrl:OnBossFirstHurtInfo(protocol)
	local role_obj = Scene.Instance:GetObj(protocol.obj_id)
	if role_obj and role_obj:IsRole() then
		role_obj:SetAttr("first_hurt_flag", protocol.first_hurt_flag)
	end
end

function BossCtrl:OnMonsterFirstHitInfo(protocol)
	local monster_obj = Scene.Instance:GetObj(protocol.obj_id)
	if monster_obj and monster_obj:IsMonster() and protocol.is_show == 1 then
		monster_obj:SetDpsTargetName(protocol.first_hit_user_name or "")
	end
	if monster_obj and monster_obj:IsMonster() and protocol.is_show == 0 then
		monster_obj:SetDpsTargetName("")
	end
end

function BossCtrl:CancelDpsFlag()
	local main_role = Scene.Instance:GetMainRole()
	main_role:SetAttr("top_dps_flag", 0)
	main_role:SetAttr("first_hurt_flag", 0)
end

function BossCtrl:SetPersonalBossEnterInfo(num)
	self.data:SetPersonalBossEnterInfo(num)
	if self.view.personal_boss_view and self.view.personal_boss_view:IsOpen() then
		self.view.personal_boss_view:Flush()
	end
end

function BossCtrl:OnSetPersonalBossBuyInfo(count)
	self.data:SetPersonalBossBuyTimes(count)
	if self.view.personal_boss_view and self.view.personal_boss_view:IsOpen() then
		self.view.personal_boss_view:Flush()
	end
end

function BossCtrl:SetDaBaoBossEnterInfo(num)
	self.data:SetDaBaoBossEnterInfo(num)
	self.view:Flush("dabao_boss_text")
end

 --??????BOSS??????
function BossCtrl:SendGetWorldBossInfo(boss_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetWorldBossInfo)
	protocol.boss_type = boss_type
	protocol:EncodeAndSend()
end

function BossCtrl:LoginCallBack()
	SEND_REASON = true
	self:SendGetWorldBossInfo(1)
	self:SendPosInfo(1)
	self:SendGetBossInfoReq(BOSS_ENTER_TYPE.TYPE_BOSS_MIKU)
	self:SendGetBossInfoReq(BOSS_ENTER_TYPE.TYPE_BOSS_PRECIOUS)
	if self.send_status then
		GlobalTimerQuest:CancelQuest(self.send_status)
		self.send_status = nil
	end
	if self.send_status == nil then
		self.send_status = GlobalTimerQuest:AddDelayTimer(function() SEND_REASON = false end, 10)
	end
end

--????????????boss??????
function BossCtrl:OnWorldBossInfo(protocol)
	local cur_flush_time = self.data:GetBossNextReFreshTime()
	--????????????tips
	if not SEND_REASON then
		self:CheckOpenWelfareTips(cur_flush_time, protocol.next_refresh_time)
	end
	self.data:SetBossInfo(protocol)
	self.view:Flush("boss_list")
	self.world_boss_fight_view:Flush()
end

-- boss??????
function BossCtrl:OnWorldBossBorn(protocol)
	self:SendGetWorldBossInfo(1)
end

 --??????boss????????????????????????
function BossCtrl:SendWorldBossPersonalHurtInfoReq(boss_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSWorldBossPersonalHurtInfoReq)
	protocol.boss_id = boss_id or 0
	protocol:EncodeAndSend()
end

 --??????boss????????????????????????
function BossCtrl:SendWorldBossGuildHurtInfoReq(boss_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSWorldBossGuildHurtInfoReq)
	protocol.boss_id = boss_id or 0
	protocol:EncodeAndSend()
end

 --??????boss??????????????????????????????
function BossCtrl:SendWorldBossWeekRankInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSWorldBossWeekRankInfoReq)
	protocol:EncodeAndSend()
end

-- ????????????boss??????????????????
function BossCtrl:OnWorldBossSendPersonalHurtInfo(protocol)
	self.data:SetBossPersonalHurtInfo(protocol)
	if self.world_boss_fight_view:IsOpen() then
		self.world_boss_fight_view:Flush()
	end
end

-- ????????????boss????????????????????????
function BossCtrl:OnWorldBossSendGuildHurtInfo(protocol)
	self.data:SetBossGuildHurtInfo(protocol)
	if self.world_boss_fight_view:IsOpen() then
		self.world_boss_fight_view:Flush()
	end
end

-- ????????????boss??????????????????????????????
function BossCtrl:OnWorldBossWeekRankInfo(protocol)
	self.data:SetBossWeekRankInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush("boss_list")
	end
end

function BossCtrl:OpenBossInfoView()
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id then
		if BossData.Instance:IsWorldBossScene(scene_id) then
			if self.world_boss_fight_view then
				self.world_boss_fight_view:Open()
			end
		end
	end
end

function BossCtrl:CloseBossInfoView()
	if self.world_boss_fight_view:IsOpen() then
		self.world_boss_fight_view:Close()
	end
end

 --??????????????????
function BossCtrl:SendWorldBossRollReq(boss_id, index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSWorldBossRollReq)
	protocol.boss_id = boss_id or 0
	protocol.index = index or 0
	protocol:EncodeAndSend()
end

function BossCtrl:OnWorldBossCanRoll(protocol)
	local boss_id = protocol.boss_id
	if boss_id then
		local scene_id = Scene.Instance:GetSceneId()
		if scene_id then
			if BossData.Instance:IsWorldBossScene(scene_id) then
				local temp_boss_id = self.data:GetWorldBossIdBySceneId(scene_id)
				if temp_boss_id == boss_id then
					if self.world_boss_fight_view:IsOpen() then
						self.world_boss_fight_view:SetCanRoll(protocol.index)
					end
				end
			end
		end
	end
end

function BossCtrl:OnWorldBossRollInfo(protocol)
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id then
		if BossData.Instance:IsWorldBossScene(scene_id) then
			if self.world_boss_fight_view:IsOpen() then
				self.world_boss_fight_view:SetRollResult(protocol.roll_point, protocol.hudun_index)
			end
		end
	end
end

function BossCtrl:OnWorldBossRollTopPointInfo(protocol)
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id then
		if BossData.Instance:IsWorldBossScene(scene_id) then
			if self.world_boss_fight_view:IsOpen() then
				self.world_boss_fight_view:SetRollTopPointInfo(protocol.boss_id, protocol.hudun_index, protocol.top_roll_point, protocol.top_roll_name)
			end
		end
	end
end

function BossCtrl:CloseView()
	if self.view:IsOpen() then
		self.view:Close()
	end
end

function BossCtrl:OnDabaoBossInfo(protocol)
	self.data:SetDabaoBossInfo(protocol)
	self.view:Flush("dabao_boss")
	self.dabao_fam_fight_view:Flush()
	RemindManager.Instance:Fire(RemindName.Boss)
	RemindManager.Instance:Fire(RemindName.Boss_DaBao)
	RemindManager.Instance:Fire(RemindName.Main_Boss)
end

function BossCtrl:OnActiveBossInfo(protocol)
	self.data:SetActiveBossInfo(protocol)
	self.view:Flush("active_boss_text")
	self.active_fam_fight_view:Flush()
	RemindManager.Instance:Fire(RemindName.Boss_Active)
	RemindManager.Instance:Fire(RemindName.Main_Boss)
end

function BossCtrl:OnActiveBossHurtRank(protocol)
	self.data:SetActiveBossPersonalHurtInfo(protocol)
	if self.active_boss_rand_reward_view then
		BossData.Instance:SetActiveBossRankMonsterID(protocol.monster_id)
		self.active_boss_rand_reward_view:SetData(protocol.monster_id)
	end
	self.active_fam_fight_view:Flush()
	local is_show = BossData.Instance:GetActiveHurtShow()
	if is_show then
		self.active_fam_fight_view:SetIsActiveBossRange(true)
	end
	BossData.Instance:SetActiveHurtShow(false)
end

function BossCtrl:OnMikuBossHurtRankInfo(protocol)
	self.data:SetMikuBossPersonalHurtInfo(protocol)
	self.boss_family_fight_view_two:FlushRankView()
	local is_show = BossData.Instance:GetMikuHurtShow()
	if is_show then
		self.boss_family_fight_view_two:SetIsMikuBossRange(true)
	end
	BossData.Instance:SetMikuHurtShow(false)
end

function BossCtrl:OnMikuBossLeaveInfo(protocol)
	BossData.Instance:ClearCache()
	self.boss_family_fight_view_two:SetIsMikuBossRange(false)
	BossData.Instance:SetMikuHurtShow(true)
end

function BossCtrl:OnActiveBossLeaveInfo(protocol)
	if self.active_fam_fight_view then
		self.active_fam_fight_view:SetIsActiveBossRange(false)
	end
	BossData.Instance:ClearCache()
	BossData.Instance:SetActiveHurtShow(true)
end

function BossCtrl:OnFamilyBossInfo(protocol)
	self.data:SetFamilyBossInfo(protocol)
	self.view:Flush("boss_family")
	self.boss_family_fight_view:Flush("boss_family")
	RemindManager.Instance:Fire(RemindName.Boss_Family)
	RemindManager.Instance:Fire(RemindName.Main_Boss)
end

function BossCtrl:OnMikuBossInfo(protocol)
	self.data:ChangeMikuEliteCount(protocol.scene_id, protocol.elite_count)
	self.data:SetMikuBossInfo(protocol)
	RemindManager.Instance:Fire(RemindName.Boss)
	RemindManager.Instance:Fire(RemindName.Boss_MiKu)
	RemindManager.Instance:Fire(RemindName.Main_Boss)
		
	self.view:Flush("miku_boss")
	self.boss_family_fight_view:Flush("miku_boss")
	self.boss_family_fight_view_two:Flush("miku_boss")
end

function BossCtrl:OnMikuMonsterInfo(protocol)
	self.data:ChangeMikuEliteCount(Scene.Instance:GetSceneId(), protocol.elite_count)
	if self.boss_family_fight_view:IsOpen() then
		self.boss_family_fight_view:Flush("elite")
		self.boss_family_fight_view_two:Flush("elite")
	end
end

function BossCtrl:OnBuyMikuWeraryChange(count)
	self.data:OnMiKuWearyChange(count)
	if self.view:IsOpen() then
		self.view:Flush("miku_boss")
	end
end

function BossCtrl:OnBuyActiveWeraryChange(count)
	self.data:OnActiveWearyChange(count)
	if self.view:IsOpen() then
		self.view:Flush("active_boss_text")
	end
end

function BossCtrl:OnSCBossRoleInfo(protocol)
	self.data:SetMikuPiLaoInfo(protocol)
	RemindManager.Instance:Fire(RemindName.Boss)
	RemindManager.Instance:Fire(RemindName.Main_Boss)
	self.view:Flush("miku_boss")
end

function BossCtrl:OnSCDabaoBossNextFlushInfo(protocol)
	self.data:OnSCDabaoBossNextFlushInfo(protocol)
	RemindManager.Instance:Fire(RemindName.Boss)
	RemindManager.Instance:Fire(RemindName.Main_Boss)
	self.dabao_fam_fight_view:Flush()
end

function BossCtrl:OnSCActiveBossNextFlushInfo(protocol)
	self.data:OnSCActiveBossNextFlushInfo(protocol)
	self.active_fam_fight_view:Flush()
end

function BossCtrl:OnSCBossKillerList(protocol)
	if protocol.killer_info_list ~= nil then
		TipsCtrl.Instance:OpenKillBossTip(protocol.killer_info_list)
	end
end

function BossCtrl:OnSCWorldBossKillerList(protocol)
	TipsCtrl.Instance:OpenKillBossTip(protocol.killer_info_list)
end

function BossCtrl:OnSCFollowBossInfo(protocol)
	self.data:OnSCFollowBossInfo(protocol)
end

function BossCtrl:SCWorldBossWearyInfo(protocol)
	self.data:SetWorldBossWearyInfo(protocol)
	ReviveCtrl.Instance.revive_view:Flush()
end

function BossCtrl:OnNoticeBossDead(protocol)
	if protocol.killer_uid > 0 and protocol.boss_id > 0 then
		TipsCtrl.Instance:TipsGarrottingBossView(protocol.boss_id, protocol.killer_uid)
	end
end

function BossCtrl:OnSCBossInfoToAll(protocol)
	self.data:OnSCBossInfoToAll(protocol)

	if protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY then
		self.view:Flush("boss_family")
		self.boss_family_fight_view:Flush("boss_family")
	elseif protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_MIKU then
		RemindManager.Instance:Fire(RemindName.Boss)
		RemindManager.Instance:Fire(RemindName.Main_Boss)
		self.view:Flush("miku_boss")
		self.boss_family_fight_view:Flush("miku_boss")
		self.boss_family_fight_view_two:Flush("miku_boss")
	elseif protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_DABAO then
		self.data:FlushDaBaoFlushInfo(protocol)
		self.view:Flush("dabao_boss")
		self.dabao_fam_fight_view:Flush()
	elseif protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_WORLD then
		self.view:Flush("boss_list")
		self.world_boss_fight_view:Flush()
	elseif protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE then
		self.data:FlushActiveFlushInfo(protocol)
		self.view:Flush("active_boss")
		self.active_fam_fight_view:Flush()
	elseif protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_SHANGGU then
		self.view:Flush("shanggu_boss")
		self.shanggu_fight_view:Flush()
	elseif protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_BAOBAO then
		self.view:Flush("baby_boss")
		self.baby_boss_fight_view:Flush()
	elseif protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_CROSS then
		local shenyu_boss_view = ShenYuBossCtrl.Instance:GetView()
		if shenyu_boss_view then
			shenyu_boss_view:Flush("kf_boss")
		end
		self.cross_fam_fight_view:Flush()
		-- self.data:TipKFBossFulsh(protocol)
	elseif protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_GODMAGIC then
		ShenYuBossData.Instance:FlushRefreshTimeByAllBossSC(protocol.boss_id, protocol.next_refresh_time)
		local shenyu_boss_view = ShenYuBossCtrl.Instance:GetView()
		if shenyu_boss_view then
			shenyu_boss_view:Flush("godmagic_boss")
		end
		ShenYuBossCtrl.Instance.godmagic_fight_view:Flush()
	end
	self.data:CalToRemind(protocol.boss_id, protocol.boss_type, protocol.notify_reason, protocol.scene_id)
end

function BossCtrl:OnSCWorldBossInfoToAll(protocol)
	self.data:FlushWorldBossInfo(protocol)
	self.view:Flush("world_boss")
	self.world_boss_fight_view:Flush()
end

--??????Boss????????????
function BossCtrl:SendEnterBossFamily(enter_type, scene_id, is_buy_dabao_times)
	if TaskData.Instance:GetTaskAcceptedIsBeauty() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotEnterFb)
		return
	end

	local protocol = ProtocolPool.Instance:GetProtocol(CSEnterBossFamily)
	protocol.enter_type = enter_type
	protocol.scene_id = scene_id or 0
	protocol.is_buy_dabao_times = is_buy_dabao_times or 0
	protocol:EncodeAndSend()
end

--boss????????????
function BossCtrl:SendBossFamilyOperate(operate_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSBossFamilyOperate)
	protocol.operate_type = operate_type
	protocol:EncodeAndSend()
end

--??????boss??????
function BossCtrl:SendGetBossInfoReq(enter_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetBossInfoReq)
	protocol.enter_type = enter_type
	protocol:EncodeAndSend()
end

--????????????boss??????
function BossCtrl:SendCrossBossBossInfoReq(opera_type, param1, param2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossBossBossInfoReq)
	protocol.opera_type = opera_type or 0
	protocol.param1 = param1 or 0
	protocol.param2 = param2 or 0
	protocol:EncodeAndSend()
end

--????????????boss??????
function BossCtrl:SendPersonalBossBossInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSPersonBossInfoReq)
	protocol:EncodeAndSend()
end

function BossCtrl:OnPersonBossInfo(protocol)
	self.data:SetPersoanlBossEnterTimes(protocol.info_list)
	self.view:Flush("personal_boss")
end

--???????????????boss??????, ??????,
function BossCtrl:SendBossKillerInfoReq(boss_type, boss_id, scene_id)
	if boss_id == nil or scene_id == nil then
		return
	end
	local protocol = ProtocolPool.Instance:GetProtocol(CSBossKillerInfoReq)
	protocol.boss_type = boss_type
	protocol.boss_id = boss_id
	protocol.scene_id = scene_id
	protocol:EncodeAndSend()
end

--????????????boss????????????
function BossCtrl:SendWorldBossKillerInfoReq(boss_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSWorldBossKillerInfoReq)
	protocol.boss_id = boss_id
	protocol:EncodeAndSend()
end

--??????????????????(??????boss,??????)
function BossCtrl:SendFollowBossReq(opera_type, boss_type, boss_id, scene_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSFollowBossReq)
	protocol.opera_type = opera_type
	protocol.boss_type = boss_type
	protocol.boss_id = boss_id
	protocol.scene_id = scene_id
	protocol:EncodeAndSend()
end

--????????????????????????boss??????tips
function BossCtrl:CheckOpenWelfareTips(cur_flush_time, next_flush_time)
	local ok_callback = function ()
		ViewManager.Instance:Open(ViewName.Boss, TabIndex.world_boss)
	end

	if cur_flush_time ~= 0 then
		TipsCtrl.Instance:OpenBossFocusTip(nil, ok_callback, false, false, "world_boss")
		return
	end
	 --??????cur_flush_time??????0,??????????????????????????????????????????
	local server_time = TimeCtrl.Instance:GetServerTime()
	if server_time > next_flush_time or server_time < next_flush_time then
		return
	end

	TipsCtrl.Instance:OpenBossFocusTip(nil, ok_callback, false, false, "world_boss")
end

function BossCtrl:MiKuEliteTipsCallBack()
	ViewManager.Instance:Open(ViewName.Boss, TabIndex.miku_boss)
end

function BossCtrl:MikuEliteTimeQuest()
	if not OpenFunData.Instance:CheckIsHide("miku_boss") or Scene.Instance:GetSceneType() ~= SceneType.Common then
		--???????????????????????????????????????????????????
		return
	end

	local server_time = TimeCtrl.Instance:GetServerTime()
	server_time = math.floor(server_time)
	local h = tonumber(os.date("%H", server_time))
	local m = tonumber(os.date("%M", server_time))
	local s = tonumber(os.date("%S", server_time))
	local now_second = h * 3600 + m * 60 + s
	local start_refresh_time, end_refresh_time, refresh_interval = BossData.Instance:GetMiKuEliteReFreshSection()
	local remainder = 1
	if now_second >= start_refresh_time and now_second <= end_refresh_time then
		--???????????????????????????
		remainder = (now_second - start_refresh_time) % refresh_interval
	end
	if remainder == 0 then
		--??????????????????S
		TipsCtrl.Instance:OpenBossFocusTip(nil, self.miku_elite_tips_call_back, false, false, true)
	end

end

function BossCtrl:OnBossTaskInfo(protocol)
	self.data:SetSecretTaskData(protocol)
	-- if self.secret_boss_fight_view:IsOpen() then
	-- 	self.secret_boss_fight_view:Flush()
	-- end
	if self.view:IsOpen() then
		self.view:Flush("secret_boss")
	end
end

function BossCtrl:OnPreciousBossInfo(protocol)
	self.data:SetSecretBossInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush("secret_boss")
	end
	-- if self.secret_boss_fight_view:IsOpen() then
	-- 	self.secret_boss_fight_view:Flush()
	-- end
	if self.is_first then
		local boss_list,dead_list = self.data:GetSecretBossList()
		if #boss_list ~= #dead_list then
			self.data:SecretBossRedPointTimer(true)
		else
			self.data:SecretBossRedPointTimer(false)
		end
		self.is_first = false
	end
end

function BossCtrl:OnPreciousPosInfo(protocol)

	if self.kill_boss then
		-- self.secret_boss_fight_view:KillBoss(protocol.pos_x,protocol.pos_y)
	else
		self.data:SetTargetPos(protocol)
		-- self.secret_boss_fight_view:AutoDoTask()
	end

end

function BossCtrl:SendPosInfo(ctype, param, param_2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSPreciousPosReq)
	protocol.type = ctype or 0
	protocol.param = param or 0
	protocol.param_2 = param_2 or 0
	protocol:EncodeAndSend()
end

function BossCtrl:KillBoss(param)
	self.kill_boss = param
end

function BossCtrl:SetTimer()
	if not OpenFunData.Instance:CheckIsHide("secret_boss") or Scene.Instance:GetSceneType() ~= SceneType.Common then
		return
	end
	if self.boss_timer then
		return
	end
	local server_time = TimeCtrl.Instance:GetServerTime()
	self.boss_timer = GlobalTimerQuest:AddDelayTimer(function()
		local boss_list,dead_list = self.data:GetSecretBossList()
		if #boss_list ~= #dead_list then
			self.data:SecretBossRedPointTimer(true)
		else
			self.data:SecretBossRedPointTimer(false)
		end
		self.view:Flush()
		RemindManager.Instance:Fire(RemindName.Boss)
		RemindManager.Instance:Fire(RemindName.Main_Boss)
		if self.boss_timer then
			self.boss_timer = nil
		end
	end,3600)
end

function BossCtrl:RequestDropLog(open_type, param)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetDropLog)
	protocol.type = open_type or 0
	protocol.param = param or 0
	protocol:EncodeAndSend()
end

function BossCtrl:OnDropLogRet(protocol)
	self.data:SetDropLog(protocol)
	if self.drop_view:IsOpen() then
		self.drop_view:Flush()
	end
	if self.fu_ben_view then
		self.fu_ben_view:Flush("defense")
	end
end

function BossCtrl:ShowDropView(open_type)
	if self.drop_view then
		self.drop_view:Open()
		self.drop_view:SendRequest(open_type)
		self.drop_view:Flush()
	end
end

------------------ ??????Boss ------------------
function BossCtrl:SendBabyBossRequest(opera_type, param_0, param_1, reserve_sh)
	local protocol = ProtocolPool.Instance:GetProtocol(CSBabyBossOperate)
	protocol.operate_type = opera_type
	protocol.param_0 = param_0 or 0
	protocol.param_1 = param_1 or 0
	protocol.reserve_sh = reserve_sh or 0
	protocol:EncodeAndSend()
end

function BossCtrl:OnBabyBossRoleInfo(protocol)
	self.data:SetBabyBossRoleInfo(protocol)

	if self.baby_boss_fight_view:IsOpen() then
		self.baby_boss_fight_view:Flush()
	end

	if self.view:IsOpen() then
		self.view:Flush("baby_boss")
	end
	RemindManager.Instance:Fire(RemindName.Boss_Baby)
	RemindManager.Instance:Fire(RemindName.Main_Boss)
end

function BossCtrl:OnBabyBossAllInfo(protocol)
	self.data:SetBabyBossAllInfo(protocol)

	if self.baby_boss_fight_view:IsOpen() then
		self.baby_boss_fight_view:Flush()
	end

	if self.view:IsOpen() then
		self.view:Flush("baby_boss")
	end
	RemindManager.Instance:Fire(RemindName.Boss_Baby)
	RemindManager.Instance:Fire(RemindName.Main_Boss)
end

function BossCtrl:OnBabyBossSingleInfo(protocol)
	self.data:SetBabyBossSingleInfo(protocol)

	if self.baby_boss_fight_view:IsOpen() then
		self.baby_boss_fight_view:Flush()
	end

	if self.view:IsOpen() then
		self.view:Flush("baby_boss")
	end
	RemindManager.Instance:Fire(RemindName.Boss_Baby)
	RemindManager.Instance:Fire(RemindName.Main_Boss)
end

function BossCtrl:CloseBabyBossInfoView()
	if self.baby_boss_fight_view:IsOpen() then
		self.baby_boss_fight_view:Close()
	end
end

-------------------????????????---------------------------
function BossCtrl:SendShangGuBossReq(opera_type, param1, param2, param3)
	local protocol = ProtocolPool.Instance:GetProtocol(CSShangGuBossEnterReq)
	protocol.opera_type = opera_type
	protocol.param1 = param1 or 0
	protocol.param2 = param2 or 0
	protocol.param3 = param3 or 0
	protocol:EncodeAndSend()
end

function BossCtrl:OnShangGuBossAllInfo(protocol)
	BossData.Instance:SetSgBossAllInfo(protocol)
	self.view:Flush("shanggu_boss")
	self.shanggu_fight_view:Flush()
	RemindManager.Instance:Fire(RemindName.Boss_Shanggu)
	RemindManager.Instance:Fire(RemindName.Main_Boss)
	Scene.Instance:GetMainRole():SetAttr("special_param", protocol.tire_value)
end

function BossCtrl:OnShangGuBossLayerInfo(protocol)
	BossData.Instance:SetSgBossLayer(protocol.boss_info_list)
	self.view:Flush("shanggu_boss")
	RemindManager.Instance:Fire(RemindName.Boss_Shanggu)
	RemindManager.Instance:Fire(RemindName.Main_Boss)
end

function BossCtrl:OnShangGuBossSceneInfo(protocol)
	self.data:SetDabaoBossAngryValue(protocol)
	self.shanggu_fight_view:Flush()
	RemindManager.Instance:Fire(RemindName.Boss_Shanggu)
	RemindManager.Instance:Fire(RemindName.Main_Boss)
end

function BossCtrl:OnShangGuBossSceneOtherInfo(protocol)
	self.data:SetShangGuBossSceneOtherInfo(protocol)
	self.view:Flush("shanggu_boss")
	self.shanggu_fight_view:Flush()
	RemindManager.Instance:Fire(RemindName.Boss_Shanggu)
	RemindManager.Instance:Fire(RemindName.Main_Boss)
end

function BossCtrl:GetShangGuBossSelectLayerandBossID()
	if self.view.shanggu_view ~= nil then
		return self.view.shanggu_view.layer, self.view.shanggu_view.select_boss_id
	end
end

function BossCtrl:CloseShangguFightView()
	self.shanggu_fight_view:Close()
end

function BossCtrl:CloseCrossFamFightView()
	self.cross_fam_fight_view:Close()
end

-- ????????????????????????(??????)
function BossCtrl:SetEnterBossComsunData(tiky_item_id, enter_comsun, map_tip, consum_tip, ok_func)
	-- self.dabao_enter_view:SetEnterBossComsunData(tiky_item_id, enter_comsun, map_tip, consum_tip, ok_func)
	TipsCtrl.Instance:ShowCommonBuyView(ok_func, tiky_item_id, nil, enter_comsun, false)
end

function BossCtrl:SetBossDisPlay(boss_data)
	if self.view:IsOpen() then
		self.view:FlushDisPlayModel(boss_data)
	end
end

function BossCtrl:SetBoxDisPlay(bundle, asset, res_id)
	if self.view:IsOpen() then
		self.view:FlushDisPlayModelBox(bundle, asset, res_id)
	end
end

function BossCtrl:SetBossTujianDisPlay(boss_data)
	if self.view:IsOpen() then
		self.view:FlushTuJianDisPlayModel(boss_data)
	end
end

-- ??????
function BossCtrl:OnSCBossCardAllInfo(protocol)
	self.data:SetAllBossInfo(protocol)
	self.view:Flush("tujian_boss")
	local shenyu_boss_view = ShenYuBossCtrl.Instance:GetView()
	if shenyu_boss_view then
		shenyu_boss_view:Flush("tujian_boss")
	end
	RemindManager.Instance:Fire(RemindName.Boss_Tujian)
	RemindManager.Instance:Fire(RemindName.Main_Boss)
	RemindManager.Instance:Fire(RemindName.ShenYu_Tujian)
	RemindManager.Instance:Fire(RemindName.ShenYuBoss)
end

function BossCtrl:SendBossTuJianReq(opera_type, param1, param2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSBossCardReq)
	protocol.opera_type = opera_type
	protocol.param1 = param1 or 0
	protocol.param2 = param2 or 0
	protocol:EncodeAndSend()
end

------------------------??????boss--------------------------------
function BossCtrl:SendCrossBossReq(opera_type, param1, param2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossBossReq)
	protocol.opera_type = opera_type or 0
	protocol.param1 = param1 or 0
	protocol.param2 = param2 or 0
	protocol:EncodeAndSend()
end

function BossCtrl:SendSYXuShiBossReq(opera_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossShengYinFbReq)
	protocol.opera_type = opera_type or 0
	protocol:EncodeAndSend()
end

function BossCtrl:OnCrossBossPlayerInfo(protocol)
	self.data:SetCrossBossPalyerInfo(protocol)
	-- self.view:Flush("kf_boss")
	local shenyu_boss_view = ShenYuBossCtrl.Instance:GetView()
	if shenyu_boss_view then
		shenyu_boss_view:Flush("kf_boss")
	end
	self.cross_fam_fight_view:Flush()
	RemindManager.Instance:Fire(RemindName.Boss_Kf)
	-- RemindManager.Instance:Fire(RemindName.Main_Boss)
	RemindManager.Instance:Fire(RemindName.ShenYuBoss)
end

function BossCtrl:OnCrossBossBossKillRecord(protocol)
	TipsCtrl.Instance:OpenKillBossTip(protocol.killer_record_list)
end

function BossCtrl:OnCrossBossDropRecord(protocol)
	self.data:SetCrossDropLog(protocol)
	if self.view:IsOpen() then
		self.view:Flush("drop")
	end
end

function BossCtrl:OnCrossBossSceneInfo(protocol)
	self.data:SetCrossBossSceneInfo(protocol)
	-- self.view:Flush("kf_boss")
	local shenyu_boss_view = ShenYuBossCtrl.Instance:GetView()
	if shenyu_boss_view then
		shenyu_boss_view:Flush("kf_boss")
	end
	self.cross_fam_fight_view:Flush()
end

function BossCtrl:OnCrossBossReliveTire(protocol)
	self.data:SetCrossBossWeary(protocol)
end

function BossCtrl:OnCrossBossBossInfoAck(protocol)
	self.data:SetCrossBossBossInfo(protocol)
	self.cross_fam_fight_view:Flush()
	local shenyu_boss_view = ShenYuBossCtrl.Instance:GetView()
	if shenyu_boss_view then
		shenyu_boss_view:Flush("kf_boss")
	end
end

------------------ ????????????BOSS ------------------
function BossCtrl:SendJingLingAdvantageBossEnter(opera_type, boss_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSJingLingAdvantageBossEnter)
	protocol.oper_type = opera_type or 0
	protocol.enter_bossid = boss_id or 0
	protocol:EncodeAndSend()
end

function BossCtrl:OnEncounterBossInfo(protocol)
	local boss_id = protocol.boss_id
	local role_name = protocol.role_name
	local main_role_name = GameVoManager.Instance:GetMainRoleVo().name or ""
	function ok_callback()
		GuajiCtrl.Instance:SetMoveToPosCallBack(nil)
		self:SendJingLingAdvantageBossEnter(JINGLING_ADCANTAGE_OPER_TYPE.JINGLING_ADCANTAGE_OPER_TYPE_BOSS, boss_id)
		GuajiCtrl.Instance:StopGuaji()
	end
	if main_role_name ~= role_name then
		self.data:SetEncounterBossData(protocol, ok_callback)
		-- TipsCtrl.Instance:ShowEncounterBossFocusTip("spirit_meet") 						--???????????????????????????boss???????????????
	end
end

-- function BossCtrl:SetCountDown2(is_not_remind)
-- 	self:CancelCountDown2()
-- 	if self.count_down2 == nil then
-- 		self.is_show_spirit_meet_tips = true
-- 		local time = is_not_remind and TIPSHIDETIME or TIPSHIDETIME3
-- 		self.count_down2 = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.CancelCountDown2, self), time)
-- 	end
-- end

-- function BossCtrl:CancelCountDown2()
-- 	if nil ~= self.count_down2 then
-- 		GlobalTimerQuest:CancelQuest(self.count_down2)
-- 		self.count_down2 = nil
-- 	end
-- 	self.is_show_spirit_meet_tips = false
-- end

-- function BossCtrl:GetHiedSpiritMeetTips()
-- 	return self.is_show_spirit_meet_tips
-- end

function BossCtrl:OnEncounterBossEnterTimesChange(time)
	self.data:SetEncounterBossEnterTimes(time)
end

-------------------????????????BOSS-------------------------

function BossCtrl:CheckCanShowBossTip(from_view)
	local is_show = OpenFunData.Instance:CheckIsHide(from_view)
	if not is_show then
		return false
	end
	return true
end

function BossCtrl:ShowExpBuyTip(pay_money, buy_times, max_times, show_next, vipid, callback, databack, text_type, desc)
	self.boss_enter_tips:SetData(pay_money, buy_times, max_times, show_next, vipid, callback, databack, text_type, desc)
	self.boss_enter_tips:Open()
	self.boss_enter_tips:Flush()
end

function BossCtrl:JumpToDaBaoLayer(layer)
	self.view:JumpToDaBaoLayer(layer)
end

function BossCtrl:JumpToBabyLayer(layer)
	self.view:JumpToBabyLayer(layer)
end