require("game/fuben/cross_button_view")

require("game/fuben/fu_ben_view")
require("game/fuben/fu_ben_phase_view")
-- require("game/fuben/fu_ben_exp_view")
require("game/fuben/fu_ben_exp_buy_view")
require("game/fuben/fu_ben_vip_view")
require("game/fuben/fu_ben_tower_view")
require("game/fuben/fu_ben_story_view")
require("game/fuben/fu_ben_data")
require("game/fuben/fu_ben_victory_finish_view")
require("game/fuben/fu_ben_fail_finish_view")
require("game/fuben/fu_ben_info_phase_view")
require("game/fuben/fu_ben_info_guard_view")
require("game/fuben/fu_ben_info_exp_view")
-- require("game/fuben/fu_ben_info_story_view")
require("game/fuben/fu_ben_info_tower_view")
require("game/fuben/fu_ben_info_vip_view")
require("game/fuben/fu_ben_info_quality_view")
require("game/fuben/fu_ben_info_push_view")
require("game/fuben/fu_ben_icon_view")
require("game/fuben/fu_ben_wing_story_view")
require("game/fuben/fu_ben_many_fb_view")
require("game/fuben/fu_ben_quality_view")
require("game/fuben/fu_ben_guard_view")
require("game/fuben/fu_ben_finish_star_view")
require("game/fuben/fu_ben_push_all_view")
require("game/fuben/fu_ben_push_common_view")
require("game/fuben/fu_ben_push_special_view")
require("game/fuben/fu_ben_armor_view")
require("game/fuben/fu_ben_armor_info_view")
require("game/fuben/fu_ben_finish_add_friend")
require("game/fuben/tips_phase_saodang_view")
require("game/fuben/fu_ben_get_view")

require("game/fuben/fu_ben_team/fu_ben_team_view")
require("game/fuben/fu_ben_team/fu_ben_tower_info")
require("game/fuben/fu_ben_team/fu_ben_tower_skill_view")
require("game/fuben/fu_ben_team/fu_ben_tower_select_view")
require("game/fuben/fu_ben_team/fu_ben_team_special_info")
require("game/fuben/fu_ben_defense/fu_ben_defense_tips")
require("game/fuben/fu_ben_defense/fu_ben_defense_view")
require("game/fuben/fu_ben_defense/fu_ben_defense_sweep")
require("game/fuben/fu_ben_defense/fu_ben_defense_info_view")
require("game/fuben/fu_ben_weapon_materials/weapon_materials_info_view")
require("game/fuben/fu_ben_weapon_materials/weapon_materials_roll_view")
require("game/fuben/tower_mojie_view")
require("game/fuben/fu_ben_new_exp_view")
require("game/fuben/fu_ben_many_view")
require("game/fuben/fu_ben_weapon_materials/weapon_materials_content")
require("game/fuben/fu_ben_weapon_materials/weapon_materials_cell")
require("game/fuben/fu_ben_tower_rank")
require("game/fuben/fu_ben_team/fu_ben_team_skill_explain_view")
require("game/fuben/fu_ben_team/fu_ben_team_skill_explain_view")
FuBenCtrl = FuBenCtrl or BaseClass(BaseController)

local FLUSH_REDPOINT_CD = 600
local OPEN_DELAY_TIME = 1.5

function FuBenCtrl:__init()
	if FuBenCtrl.Instance ~= nil then
		print_error("[FuBenCtrl] Attemp to create a singleton twice !")
		return
	end
	FuBenCtrl.Instance = self
	self.fu_ben_view = FuBenView.New(ViewName.FuBen)
	self.fu_ben_data = FuBenData.New()
	self.cross_button_view = CrossButtonView.New(ViewName.CrossButtonView)
	self.fu_ben_victory_view = FuBenVictoryFinishView.New(ViewName.FBVictoryFinishView)
	self.fu_ben_star_view = FuBenFinishStarView.New(ViewName.FBFinishStarView)
	self.fu_ben_fail_view = FuBenFailFinishView.New(ViewName.FBFailFinishView)
	self.fu_ben_add_friend_view = FuBenAddFriendView.New(ViewName.FBAddFriendView)
	self.phase_info_view = FuBenInfoPhaseView.New(ViewName.FuBenPhaseInfoView)
	self.guard_info_view = FuBenInfoGuardView.New(ViewName.FuBenGuardInfoView)
	self.exp_info_view = FuBenInfoExpView.New(ViewName.FuBenExpInfoView)
	self.exp_buy_view = TeamExpBuyTips.New()
	-- self.story_info_view = FuBenInfoStoryView.New(ViewName.FuBenStoryInfoView)
	self.tower_info_view = FuBenInfoTowerView.New(ViewName.FuBenTowerInfoView)
	self.vip_info_view = FuBenInfoVipView.New(ViewName.FuBenVipInfoView)
	self.quality_info_view = FuBenInfoQualityView.New(ViewName.FuBenQualityInfoView)	-- 幻境
	self.push_info_view = FuBenInfoPushView.New(ViewName.FuBenPushInfoView)
	self.armor_info_view = FuBenArmorInfoView.New(ViewName.FuBenArmorInfoView)
	self.weapon_info_view = FuBenInfoWeaponView.New(ViewName.FuBenWeaponInfoView)
	self.weapon_roll_view = FuBenWeaponRollView.New(ViewName.FBFinishView)
	self.defense_info_view = FuBenDefenseInfoView.New(ViewName.FuBenDefenseInfoView)
	self.defense_tips = FuBenDefenseTips.New() 					-- 建塔本
	self.defense_sweep = DefenseSweepView.New() 				-- 建塔本
	self.tower_select_view = TowerSelectView.New(ViewName.FuBenTowerSelectView)
	self.team_tower_info_view = TeamFuBenInfoView.New(ViewName.FuBenTeamInfoView)
	self.team_special_info_view = FuBenInfoTeamSpecialView.New(ViewName.FuBenSpecialInfoView)

	self.fu_ben_icon_view = FbIconView.New(ViewName.FbIconView)
	self.fu_ben_wing_story_view = FuBenWingStoryView.New(ViewName.FBWingStoryView)
	self.many_fb_view = ManyFbView.New()
	self.tower_mojie_view = TowerMojieView.New(ViewName.TowerMoJieView)			-- 魔戒/仙剑
	self.fu_ben_tower_rank = FuBenTowerRank.New(ViewName.TowerRank)				-- 爬塔排行榜
	self.fu_ben_team_skill_explain_view = TeamFBTowerSkillExplain.New(ViewName.FuBenTeamSkillExplain)

	self.fu_ben_phase_saodang_view = FuBenPhaseSaoDangView.New(ViewName.PhaseSaoDangView)
	self.fu_ben_get_view = FuBenGetView.New()

	self.scene_load_complete = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER, BindTool.Bind(self.SceneLoadComplete, self))
	self.task_change = GlobalEventSystem:Bind(OtherEventType.TASK_CHANGE, BindTool.Bind(self.OnTaskChange, self))
	self.fuben_quit = GlobalEventSystem:Bind(OtherEventType.FUBEN_QUIT, BindTool.Bind(self.FubenQuit, self))
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))

	self:RegisterAllProtocols()

	self.time_quest = {}
	self.can_move = true

	self.is_remind_weapon = true
	self.is_remind_armor = true
	self.is_remind_guard = true
	self.is_remind_fb_exp = true
	self.is_remind_fb_team = true
	self.is_remind_fb_defense = true
end

function FuBenCtrl:__delete()
	if self.scene_load_complete ~= nil then
		GlobalEventSystem:UnBind(self.scene_load_complete)
		self.scene_load_complete = nil
	end
	
	if self.task_change ~= nil then
		GlobalEventSystem:UnBind(self.task_change)
		self.task_change = nil
	end

	if self.fuben_quit ~= nil then
		GlobalEventSystem:UnBind(self.fuben_quit)
		self.fuben_quit = nil
	end

	if self.fu_ben_view ~= nil then
		self.fu_ben_view:DeleteMe()
		self.fu_ben_view = nil
	end
	
	if self.cross_button_view ~= nil then
		self.cross_button_view:DeleteMe()
		self.cross_button_view = nil
	end

	if self.fu_ben_data ~= nil then
		self.fu_ben_data:DeleteMe()
		self.fu_ben_data = nil
	end

	if nil ~= self.many_fb_view then
		self.many_fb_view:DeleteMe()
		self.many_fb_view = nil
	end

	-- if self.story_info_view ~= nil then
	-- 	self.story_info_view:DeleteMe()
	-- 	self.story_info_view = nil
	-- end

	if self.phase_info_view ~= nil then
		self.phase_info_view:DeleteMe()
		self.phase_info_view = nil
	end

	if self.guard_info_view ~= nil then
		self.guard_info_view:DeleteMe()
		self.guard_info_view = nil
	end

	if self.tower_info_view ~= nil then
		self.tower_info_view:DeleteMe()
		self.tower_info_view = nil
	end

	if self.exp_info_view ~= nil then
		self.exp_info_view:DeleteMe()
		self.exp_info_view = nil
	end
	if self.exp_buy_view ~= nil then
		self.exp_buy_view:DeleteMe()
		self.exp_buy_view = nil
	end

	if self.vip_info_view ~= nil then
		self.vip_info_view:DeleteMe()
		self.vip_info_view = nil
	end

	if self.armor_info_view ~= nil then
		self.armor_info_view:DeleteMe()
		self.armor_info_view = nil
	end

	if self.weapon_info_view ~= nil then
		self.weapon_info_view:DeleteMe()
		self.weapon_info_view = nil
	end

	if self.defense_info_view ~= nil then
		self.defense_info_view:DeleteMe()
		self.defense_info_view = nil
	end

	if self.weapon_roll_view ~= nil then
		self.weapon_roll_view:DeleteMe()
		self.weapon_roll_view = nil
	end

	if self.fu_ben_fail_view ~= nil then
		self.fu_ben_fail_view:DeleteMe()
		self.fu_ben_fail_view = nil
	end

	if self.fu_ben_add_friend_view ~= nil then
		self.fu_ben_add_friend_view:DeleteMe()
		self.fu_ben_add_friend_view = nil
	end

	if self.fu_ben_victory_view ~= nil then
		self.fu_ben_victory_view:DeleteMe()
		self.fu_ben_victory_view = nil
	end

	if self.fu_ben_icon_view ~= nil then
		self.fu_ben_icon_view:DeleteMe()
		self.fu_ben_icon_view = nil
	end

	if self.fu_ben_wing_story_view ~= nil then
		self.fu_ben_wing_story_view:DeleteMe()
		self.fu_ben_wing_story_view = nil
	end

	if self.defense_tips ~= nil then
		self.defense_tips:DeleteMe()
		self.defense_tips = nil
	end

	if self.tower_select_view ~= nil then
		self.tower_select_view:DeleteMe()
		self.tower_select_view = nil
	end

	if self.team_tower_info_view ~= nil then
		self.team_tower_info_view:DeleteMe()
		self.team_tower_info_view = nil
	end

	if self.team_special_info_view ~= nil then
		self.team_special_info_view:DeleteMe()
		self.team_special_info_view = nil
	end

	if self.tower_mojie_view ~= nil then
		self.tower_mojie_view:DeleteMe()
		self.tower_mojie_view = nil
	end

	if self.fu_ben_phase_saodang_view ~= nil then
		self.fu_ben_phase_saodang_view:DeleteMe()
		self.fu_ben_phase_saodang_view = nil
	end

	if self.fu_ben_get_view ~= nil then
		self.fu_ben_get_view:DeleteMe()
		self.fu_ben_get_view = nil
	end

	for k, v in pairs(self.time_quest) do
		GlobalTimerQuest:CancelQuest(v)
	end
	self.time_quest = {}

	if self.open_delay then
		GlobalTimerQuest:CancelQuest(self.open_delay)
	end

	if self.fu_ben_tower_rank then
		self.fu_ben_tower_rank:DeleteMe()
		self.fu_ben_tower_rank = nil
	end

	if self.time_request then
		GlobalTimerQuest:CancelQuest(self.time_request)
	end

	FuBenCtrl.Instance = nil
end

function FuBenCtrl:RemoveOpenCountDown()
	if self.open_delay then
		GlobalTimerQuest:CancelQuest(self.open_delay)
	end
	self.open_delay = nil
end

function FuBenCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCPhaseFBInfo, "GetPhaseFBInfoReq")
	self:RegisterProtocol(SCFBSceneLogicInfo, "GetFBSceneLogicInfoReq")
	self:RegisterProtocol(SCDailyFBRoleInfo, "OnSCDailyFBRoleInfo")
	self:RegisterProtocol(SCStoryFBInfo, "GetStoryFBInfoReq")
	self:RegisterProtocol(SCVipFbAllInfo, "GetVipFBInfoReq")
	self:RegisterProtocol(SCPataFbAllInfo, "GetTowerFBInfoReq")
	self:RegisterProtocol(SCFunOpenWingInfo, "GetWingStoryInfoReq")
	self:RegisterProtocol(SCFbPickItemInfo, "OnFbPickItemInfoReq")
	self:RegisterProtocol(SCExpFbInfo, "OnExpFbInfo")
	self:RegisterProtocol(SCTeamEquipFbInfo, "OnTeamEquipFbInfo")
	self:RegisterProtocol(SCTeamEquipFbDropCountInfo, "OnTeamEquipFbDropCountInfo")
	self:RegisterProtocol(CSPhaseFBInfoReq)
	self:RegisterProtocol(SCTeamFbRoomList, "OnTeamFbRoomList")
	self:RegisterProtocol(SCTeamFbRoomEnterAffirm, "OnTeamFbRoomEnterAffirm")
	self:RegisterProtocol(CSChallengeFBOP)
	self:RegisterProtocol(SCChallengeFBInfo, "OnChallengeFBInfo")
	self:RegisterProtocol(SCChallengePassLevel, "OnChallengePassLevel")
	self:RegisterProtocol(SCChallengeLayerInfo, "OnChallengeLayerInfo")

	self:RegisterProtocol(SCTowerDefendRoleInfo, "OnTowerDefendRoleInfo")
	self:RegisterProtocol(SCAutoFBRewardDetail, "OnAutoFBRewardDetail")
	self:RegisterProtocol(SCTowerDefendWarning, "OnTowerDefendWarning")
	self:RegisterProtocol(SCTowerDefendInfo, "OnTowerDefendInfo")
	self:RegisterProtocol(SCFBDropInfo, "OnFBDropInfo")
	self:RegisterProtocol(SCTowerDefendResult, "OnTowerDefendResult")
	self:RegisterProtocol(SCFBFinish, "OnFBFinish")

	self:RegisterProtocol(CSTuituFbOperaReq)
	self:RegisterProtocol(SCTuituFbInfo, "OnTuituFbInfo")
	self:RegisterProtocol(SCTuituFbResultInfo, "OnTuituFbResultInfo")
	self:RegisterProtocol(SCTuituFbSingleInfo, "OnTuituFbSingleInfo")
	self:RegisterProtocol(SCTuituFbFetchResultInfo, "OnTuituFbFetchResultInfo")

	--装备材料副本
	self:RegisterProtocol(SCNeqFBInfo, "OnNeqFBInfo")
	self:RegisterProtocol(SCNeqPass, "OnNeqPassInfo")
	self:RegisterProtocol(SCNeqRollPool, "OnNeqRollPool")
	self:RegisterProtocol(SCNeqRollInfo, "OnNeqRollInfo")

	--防具材料副本
	self:RegisterProtocol(SCArmorDefendRoleInfo, "OnArmorDefendRoleInfo")
	self:RegisterProtocol(SCArmorDefendResult, "OnArmorDefendResult")
	self:RegisterProtocol(SCArmorDefendInfo, "OnArmorDefendInfo")
	self:RegisterProtocol(SCArmorDefendWarning, "OnArmorDefendWarning")
	self:RegisterProtocol(SCArmorDefendPerformSkill, "OnArmorDefendPerformSkill")

	--塔防副本(建塔)
	self:RegisterProtocol(SCBuildTowerFBSceneLogicInfo, "OnBuildTowerFBInfo")

	--组队守护
	-- self:RegisterProtocol(SCTeamFBUserInfo, "SCTeamFBUserInfo")
	self:RegisterProtocol(SCTeamTowerDefendInfo, "OnTeamTowerInfo")
	self:RegisterProtocol(SCTeamTowerDefendAttrType, "OnTeamTowerDefendAttrType")
	self:RegisterProtocol(SCTeamTowerDefendSkill, "OnTeamTowerDefendSkill")
	self:RegisterProtocol(SCTeamTowerDefendAllRole, "OnTeamTowerDefendAllRole")
	self:RegisterProtocol(SCTeamTowerDefendResult, "OnTeamTowerDefendResult")

	--组队爬塔
	self:RegisterProtocol(SCEquipFBResult, "OnEquipFBResult")

	--组队副本购买多倍奖励
	self:RegisterProtocol(SCFetchDoubleRewardResult, "OnFetchDoubleRewardResult")
end

function FuBenCtrl:GetFuBenView()
	return self.fu_ben_view
end

function FuBenCtrl:GetCrossButtonView()
	return self.cross_button_view
end

function FuBenCtrl:GetFuBenIconView()
	return self.fu_ben_icon_view
end

function FuBenCtrl:SetBossTips(enable)
	return self.fu_ben_icon_view:SetBossTips(enable)
end

function FuBenCtrl:SetBossInfo(enable)
	return self.fu_ben_icon_view:SetBossInfo(enable)
end

function FuBenCtrl:FlushFbViewByParam(...)
	self.fu_ben_view:Flush(...)
end

function FuBenCtrl:ChangeLeader()
	if self.fu_ben_view then
		self.fu_ben_view:ChangeLeader()
	end
end

function FuBenCtrl:SetTeamFuBenBg(index)
	if self.fu_ben_view then
		self.fu_ben_view:SetTeamFuBenBg(index)
	end
end

-- 阶段副本信息请求
function FuBenCtrl:SendGetPhaseFBInfoReq(operate_type, fb_index)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSPhaseFBInfoReq)
	send_protocol.operate_type = operate_type or 0
	send_protocol.fb_index = fb_index or 0
	send_protocol:EncodeAndSend()
end

-- 阶段副本信息返回 进阶
function FuBenCtrl:GetPhaseFBInfoReq(protocol)
	self.fu_ben_data:SetPhaseFBInfo(protocol.info_list)
	self.fu_ben_view:Flush("phase")
	self.fu_ben_data:CheCkDataChangeRedPoint()
	self.phase_info_view:Flush()
	self:FlushMainUIRedPoint()
	if self.fu_ben_phase_saodang_view then
		self.fu_ben_phase_saodang_view:Flush()
	end
	local rest_time = FuBenData.Instance:GetLastTime()
	if rest_time <= 0 then
		FuBenData.Instance:SetIsNotClickFuBen(true)
	end
	MainUICtrl.Instance:GetView():ShowXianShiChallenge()
	RemindManager.Instance:Fire(RemindName.FuBen_JinJie)
end

-- 经验副本信息请求
function FuBenCtrl:SendGetExpFBInfoReq()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSDailyFBGetRoleInfo)
	send_protocol:EncodeAndSend()
end

-- 经验副本信息返回
function FuBenCtrl:OnSCDailyFBRoleInfo(protocol)
	-- self.fu_ben_data:SetSCDailyFBRoleInfo(protocol)
	self.fu_ben_data:OnSCDailyFBRoleInfo(protocol)
	self.fu_ben_view:Flush("exp")
	if self.exp_buy_view:IsOpen() then
		self.exp_buy_view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.FuBen_Exp)
end

function FuBenCtrl:ColseExpBuyFBRoleInfo()
	if self.exp_buy_view:IsOpen() then
		self.exp_buy_view:Close()
	end
end

-- 经验副本首通奖励领取
function FuBenCtrl:SendGetExpFBFirstRewardReq(fetch_reward_wave)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSExpFBRetchFirstRewardReq)
	send_protocol.fetch_reward_wave = fetch_reward_wave or 0
	send_protocol:EncodeAndSend()
end

-- 剧情副本信息请求
function FuBenCtrl:SendGetStoryFBGetInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSStoryFBGetInfo)
	send_protocol:EncodeAndSend()
end

-- 剧情副本信息返回
function FuBenCtrl:GetStoryFBInfoReq(protocol)
	self.fu_ben_data:SetStoryFBInfo(protocol.info_list)
	self.fu_ben_view:Flush("story")
	-- if ViewManager.Instance:IsOpen(ViewName.FuBenStoryInfoView) then
	-- 	self.story_info_view:Flush()
	-- end
	self:FlushMainUIRedPoint()
end

-- vip副本信息请求
function FuBenCtrl:SendGetVipFBGetInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSVipFbAllInfoReq)
	send_protocol:EncodeAndSend()
end

-- vip副本信息返回
function FuBenCtrl:GetVipFBInfoReq(protocol)
	self.fu_ben_data:SetVipFBInfo(protocol)
	self.fu_ben_view:Flush("vip")
	if ViewManager.Instance:IsOpen(ViewName.FuBenVipInfoView) then
		self.vip_info_view:Flush()
	end
	self:FlushMainUIRedPoint()
end

-- 爬塔副本信息请求
function FuBenCtrl:SendGetTowerFBGetInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSPataFbAllInfo)
	send_protocol:EncodeAndSend()
end

-- 爬塔副本信息返回 
function FuBenCtrl:GetTowerFBInfoReq(protocol)
	self.fu_ben_data:SetTowerFBInfo(protocol)
	-- self.fu_ben_view:Flush("tower")
	GaoZhanCtrl.Instance:FlushView("tower")
	
	if ViewManager.Instance:IsOpen(ViewName.FuBenTowerInfoView) then
		self.tower_info_view:Flush()
	end
	self:FlushMainUIRedPoint()
	RemindManager.Instance:Fire(RemindName.BeStrength)
	RemindManager.Instance:Fire(RemindName.FuBen_ShiLian)
end

function FuBenCtrl:GetWingStoryInfoReq(protocol)
	-- do delay
end

-- 副本结算物品奖励信息
function FuBenCtrl:OnFbPickItemInfoReq(protocol)
	self.fu_ben_data:SetFbPickItemInfo(protocol.item_list)
end

-- 经验副本信息
function FuBenCtrl:OnExpFbInfo(protocol)
	self.fu_ben_data:SetExpFbInfo(protocol)
	self.fu_ben_data:SetFBSceneLogicTime(protocol.time_out_stamp)
	self.exp_info_view:Flush()
	self.fu_ben_view:Flush("exp")
	TipsCtrl.Instance:GetInSprieFuBenView():Flush()
	TipsCtrl.Instance:GetExpFuBenGuWuView():Flush()
	TipsCtrl.Instance:GetExpFubenView():Flush()
	if ViewManager.Instance:IsOpen(ViewName.FuBenExpInfoView) then
		self.exp_info_view:Flush()
	end
	self.fu_ben_icon_view:Flush()
end

function FuBenCtrl:ShowExpBuyTip(pay_money, buy_times, max_times, show_next, vipid, callback, databack, text_type, desc)
	self.exp_buy_view:SetData(pay_money, buy_times, max_times, show_next, vipid, callback, databack, text_type, desc)
	self.exp_buy_view:Open()
end

-- 组队装备副本信息
function FuBenCtrl:OnTeamEquipFbInfo(protocol)
	self.fu_ben_data:SetManyFbInfo(protocol)
	if self.many_fb_view and self.many_fb_view:IsOpen() then
		self.many_fb_view:Flush()
	end

end

-- 组队装备副本掉落次数信息
function FuBenCtrl:OnTeamEquipFbDropCountInfo(protocol)
	self.fu_ben_data:SetTeamEquipFbDropCountInfo(protocol)
	if self.fu_ben_view and self.fu_ben_view:IsOpen() then
		self.fu_ben_view:Flush("manypeople")
	end
end

-- 购买经验副本次数
function FuBenCtrl:SendAutoFBReq(fb_type, param_1, param_2, param_3, param_4)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSAutoFB)
	send_protocol.fb_type = fb_type
	send_protocol.param_1 = param_1 or 0
	send_protocol.param_2 = param_2 or 0
	send_protocol.param_3 = param_3 or 0
	send_protocol.param_4 = param_4 or 0
	send_protocol:EncodeAndSend()
end

-- 进入副本时，返回信息
function FuBenCtrl:GetFBSceneLogicInfoReq(protocol)
	if SceneType.RuneTower == protocol.scene_type then
		if protocol.is_pass == 0 and protocol.is_finish == 1 then
			GlobalTimerQuest:AddDelayTimer(function()
				ViewManager.Instance:Open(ViewName.FBFailFinishView)
			end, 1)
			return
		end
	end
	self.fu_ben_data:SetFBSceneLogicInfo(protocol)
	if self.weapon_info_view then
		self.weapon_info_view:Flush()
	end
	
	self:FlushView(Scene.Instance:GetSceneType(), protocol)
	if self.team_special_info_view:IsOpen() then
		self.team_special_info_view:Flush()
	end 
end

-- 请求购买组队副本次数
function FuBenCtrl:SendTeamEquipFbBuyDropCountReq()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSTeamEquipFbBuyDropCount)
	send_protocol:EncodeAndSend()
end

-- 请求进入副本
function FuBenCtrl:SendEnterFBReq(fb_type, param_1, param_2, param_3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSEnterFB)
	send_protocol.fb_type = fb_type 	 --日常副本类型：1
	send_protocol.param_1 = param_1 or 0 --经验副本类型：0
	send_protocol.param_2 = param_2 or 0 --组队1，个人0
	send_protocol.param_3 = param_3 or 0
	send_protocol:EncodeAndSend()
	-- self.fu_ben_data:ClearFBDropInfo()
end

--经验副本购买鼓舞
function FuBenCtrl:SendExpFbPayGuwu(is_auto, reverse_sh)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSExpFbPayGuwu)
	send_protocol.is_auto = is_auto or 0
	send_protocol.reverse_sh = reverse_sh or 0
	send_protocol:EncodeAndSend()
end

-- 请求进入副本下一关
function FuBenCtrl:SendEnterNextFBReq()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFBReqNextLevel)
	send_protocol:EncodeAndSend()
	if self.weapon_roll_view and self.weapon_roll_view:IsOpen() then
	self.weapon_roll_view:Flush("reward")
	end
end

-- 离开副本
function FuBenCtrl:SendExitFBReq()
	-- if IS_ON_CROSSSERVER then
	-- 	-- 跨服修罗塔
	-- 	local scene_type = Scene.Instance:GetSceneType()
	-- 	if scene_type == SceneType.Kf_XiuLuoTower 
	-- 		or scene_type == SceneType.CrossGuild 
	-- 		or scene_type == SceneType.MonthBlackWindHigh 
	-- 		or scene_type == SceneType.KF_NightFight 
	-- 		or scene_type == SceneType.LuandouBattle 
	-- 		or scene_type == SceneType.CrossLieKun_FB 
	-- 		or scene_type == SceneType.KF_Fish then
	-- 		CrossServerCtrl.Instance:GoBack()
	-- 		return
	-- 	end
	-- end
	FuBenData.Instance:SetExpFbFlag(true)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSLeaveFB)
	send_protocol:EncodeAndSend()
end

function FuBenCtrl:FlushView(param, info)
	if param == SceneType.ExpFb then
		self.exp_info_view:Flush()
	-- elseif param == SceneType.StoryFB then
	-- 	self.story_info_view:Flush()
	elseif param == SceneType.VipFB then
		self.vip_info_view:Flush()
	elseif param == SceneType.PataFB then
		self.tower_info_view:Flush()
	elseif param == SceneType.PhaseFb then
		self.phase_info_view:Flush()
	elseif param == SceneType.RuneTower then
		ViewManager.Instance:FlushView(ViewName.RuneTowerFbInfoView)
	elseif param == SceneType.SCENE_TYPE_TUITU_FB then
		ViewManager.Instance:FlushView(ViewName.FuBenPushInfoView)
	elseif param == SceneType.DailyTaskFb then
		ViewManager.Instance:FlushView(ViewName.DailyTaskFb)
		if info.is_pass == 1 then
			local data = {}
			local reward_cfg = TaskData.Instance:GetTaskReward(TASK_TYPE.RI)
			if reward_cfg then
				data = {[1] = {item_id = FuBenDataExpItemId.ItemId, num = reward_cfg.exp}}
			end
			ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "finish", {data = data, leave_time = 5})
		end
	end
	self.fu_ben_icon_view:Flush()
end

function FuBenCtrl:SceneLoadComplete(scene_id)
	if nil == self.fu_ben_data or self.fu_ben_data.phase_info_list or nil == next(self.fu_ben_data.phase_info_list)
		or nil == self.fu_ben_data.expfb_pass_wave or nil == next(self.fu_ben_data.expfb_pass_wave) or
		nil ==self.fu_ben_data.story_info_list or nil == next(self.fu_ben_data.story_info_list) or
		nil == self.fu_ben_data.vip_info_list or nil == next(self.fu_ben_data.vip_info_list) or
		nil == self.fu_ben_data.tower_info_list or nil == next(self.fu_ben_data.tower_info_list) then
		self:SendGetPhaseFBInfoReq()
		self:SendGetExpFBInfoReq()
		self:SendGetStoryFBGetInfo()
		self:SendGetVipFBGetInfo()
		self:SendGetTowerFBGetInfo()
		self:ReqChallengeFbInfo()
		self:SendTuituFbOperaReq()
	end
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local name_list_t = Split(fb_scene_cfg.show_fbicon, "#")
	if #name_list_t > 0
		or BossData.Instance:IsWorldBossScene(scene_id)
		or BossData.Instance:IsDabaoBossScene(scene_id)
		or BossData.Instance:IsFamilyBossScene(scene_id)
		or BossData.Instance:IsMikuBossScene(scene_id)
		or BossData.Instance:IsActiveBossScene(scene_id)
		or BossData.Instance:IsSecretBossScene(scene_id)
		or AncientRelicsData.IsAncientRelics(scene_id)
		or RelicData.Instance:IsRelicScene(scene_id) then
		self.fu_ben_icon_view:Open()
	end
end

function FuBenCtrl:FubenQuit(scene_type)
	self.fu_ben_icon_view:Close()
	if scene_type ~= SceneType.PhaseFb then
		self.fu_ben_data:ClearFBSceneLogicInfo()
	end
	self.fu_ben_data:ClearFBIconCache()
end

function FuBenCtrl:MainuiOpenCreate()
	self:SendGetPhaseFBInfoReq(PHASE_FB_OPERATE_TYPE.PHASE_FB_OPERATE_TYPE_INFO)
	self:SendGetExpFBInfoReq()
	self:SendGetStoryFBGetInfo()
	self:SendGetVipFBGetInfo()
	self:SendGetTowerFBGetInfo()
end

function FuBenCtrl:FlushFbView()
	self.fu_ben_view:Flush("phase")
	self.fu_ben_view:Flush("exp")
	self.fu_ben_view:Flush("story")
	self.fu_ben_view:Flush("vip")
	-- self.fu_ben_view:Flush("tower")
	GaoZhanCtrl.Instance:FlushView("tower")
	self:FlushMainUIRedPoint()
end

-- 设置经验副本、爬塔副本红点
function FuBenCtrl:SetRedPointCountDown(str_param)
	if not self.time_quest[str_param] then
		self.fu_ben_data:SetRedPointCd(str_param)
		self.time_quest[str_param] = GlobalTimerQuest:AddRunQuest(function()
			RemindManager.Instance:Fire(RemindName.FuBenSingle)
			-- if self.fu_ben_view:IsOpen() then
			-- else
			-- 	self.fu_ben_view:Flush(str_param)
			-- end
			if self.time_quest[str_param] then
				GlobalTimerQuest:CancelQuest(self.time_quest[str_param])
				self.time_quest[str_param] = nil
			end
		end, FLUSH_REDPOINT_CD)
	end
end

function FuBenCtrl:FlushMainUIRedPoint()
	RemindManager.Instance:Fire(RemindName.FuBenSingle)
end

function FuBenCtrl:SetMonsterDiffTime(diff_time, index)
	self.fu_ben_icon_view:SetMonsterDiffTime(diff_time, index)
end

function FuBenCtrl:SetMonsterInfo(monster_id, index)
	self.fu_ben_icon_view:SetMonsterInfo(monster_id, index)
end

function FuBenCtrl:ShowMonsterHadFlush(enable, flush_text, index)
	self.fu_ben_icon_view:ShowMonsterHadFlush(enable, flush_text, index)
end

function FuBenCtrl:SetBossHpPercentValue(enable, str)
	self.fu_ben_icon_view:SetBossHpPercentValue(enable, str)
end

function FuBenCtrl:SetMonsterIconState(enable, index)
	self.fu_ben_icon_view:SetMonsterIconState(enable, index)
end

function FuBenCtrl:SetMonsterIconGray(enable, index)
	self.fu_ben_icon_view:SetMonsterIconGray(enable, index)
end

function FuBenCtrl:SetMonsterClickCallBack(call_back, index)
	self.fu_ben_icon_view:SetClickCallBack(call_back, index)
end

function FuBenCtrl:ClearMonsterClickCallBack()
	self.fu_ben_icon_view:ClearClickCallBack()
end

function FuBenCtrl:SetCountDownByTotalTime(time)
	self.fu_ben_icon_view:SetCountDownByTotalTime(time)
end

function FuBenCtrl:SetSkyMoneyTextState(value)
	self.fu_ben_icon_view:SetSkyMoneyTextState(value)
end

function FuBenCtrl:SetAutoBtnClickCallBack(call_back)
	self.fu_ben_icon_view:SetAutoBtnClickCallBack(call_back)
end

function FuBenCtrl:SetExitArrowState()
	self.fu_ben_icon_view:SetExitArrowState()
end

function FuBenCtrl:FlushFbIconView()
	self.fu_ben_icon_view:Flush()
end

function FuBenCtrl:SendMoneyTreeTime()
	if self.fu_ben_icon_view:IsOpen() then
		self.fu_ben_icon_view:FlushMoneyTree()
	end
end

function FuBenCtrl:FlushGuildBossButton()
	if self.fu_ben_icon_view:IsOpen() then
		self.fu_ben_icon_view:ShowGuildBossButton()
	end
end

function FuBenCtrl:CloseView()
	if self.fu_ben_view:IsOpen() then
		self.fu_ben_view:Close()
	end
end

-- 刷新乱斗bossHP
function FuBenCtrl:FlushLuanDouHP()
	self.fu_ben_icon_view:Flush("luandou_info")
end

-- 刷新多人副本
function FuBenCtrl:FlushManyPeopleView()
	if self.fu_ben_view and self.fu_ben_view:IsOpen() then
		self.fu_ben_view:Flush("manypeople")
	end
end

-- 打开多人副本副本场景
function FuBenCtrl:OpenManyFbView()
	if self.many_fb_view then
		self.many_fb_view:Open()
	end
end

-- 关闭多人副本副本场景
function FuBenCtrl:CloseManyFbView()
	if self.many_fb_view then
		self.many_fb_view:Close()
	end
end

-- 组队副本房间请求操作
function FuBenCtrl:SendTeamFbRoomOperateReq(operate_type, param1, param2, param3, param4, param5)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSTeamFbRoomOperate)
	send_protocol.operate_type = operate_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol.param3 = param3 or 0
	send_protocol.param4 = param4 or 0
	send_protocol.param5 = param5 or 0
	send_protocol:EncodeAndSend()

	if send_protocol.operate_type == TeamFuBenOperateType.START_ROOM and ScoietyData.Instance:GetTeamNum() > 2 then
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.AddFriend, true)
	end
end

-- 副本房间列表
function FuBenCtrl:OnTeamFbRoomList(protocol)
	self.fu_ben_data:SetTeamFbRoomList(protocol)
	if self.fu_ben_view and self.fu_ben_view:IsOpen() then
		if protocol.team_type == FuBenTeamType.TEAM_TYPE_TEAM_DAILY_FB then
		-- self.fu_ben_view:Flush("manypeople")
			self.fu_ben_view:Flush("exp")
		elseif protocol.team_type == FuBenTeamType.TEAM_TYPE_TEAM_TOWERDEFEND or protocol.team_type == FuBenTeamType.TEAM_TYPE_EQUIP_TEAM_FB then
			self.fu_ben_view:Flush("team")
		end
	end
end

-- 副本房间进入确认通知
function FuBenCtrl:OnTeamFbRoomEnterAffirm(protocol)
	self.fu_ben_data:SetTeamFbRoomEnterAffirm(protocol)
	TipsCtrl.Instance:ShowEnterFbView()
end

-- 品质本信息下发 幻境
function FuBenCtrl:OnChallengeFBInfo(protocol)
	self.fu_ben_data:SetChallengeFbInfo(protocol)
	self.fu_ben_view:Flush("quality")
	GaoZhanCtrl.Instance:FlushView("quality")
	RemindManager.Instance:Fire(RemindName.FuBen_HuanJing)
end

-- 品质副本内信息
function FuBenCtrl:OnChallengePassLevel(protocol)
	self.fu_ben_data:SetChallengeInfoList(protocol)
	if ViewManager.Instance:IsOpen(ViewName.FuBenQualityInfoView) then
		self.quality_info_view:Flush("star_info")
	end
end

-- 品质每层协议下来
function FuBenCtrl:OnChallengeLayerInfo(protocol)
	self.fu_ben_data:SetPassLayerInfo(protocol)
	Scene.Instance:CreateDoorList()
	if ViewManager.Instance:IsOpen(ViewName.FuBenQualityInfoView) then
		self.quality_info_view:Flush()
	end
	self.fu_ben_icon_view:Flush()
end


-- 品质本信息请求
function FuBenCtrl:SendChallengeFBReq(fb_type, fb_level)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSChallengeFBOP)
	send_protocol.type = fb_type or 0
	send_protocol.level = fb_level or 0
	send_protocol:EncodeAndSend()
end

function FuBenCtrl:ReqChallengeFbInfo()
	self:SendChallengeFBReq(CHALLENGE_FB_OPERATE_TYPE.CHALLENGE_FB_OPERATE_TYPE_SEND_INFO_REQ)
end

-----------------
--单人塔防
----
-------------
--个人塔防角色信息 守护
function FuBenCtrl:OnTowerDefendRoleInfo(protocol)
	self.fu_ben_data:SetTowerDefendRoleInfo(protocol)
	-- GaoZhanCtrl.Instance:FlushView("tower_defend")
	local enble = self.fu_ben_data:GetAromrBuyTimes()
	if enble then
		GaoZhanCtrl.Instance:FlushView("times")
	else
		GaoZhanCtrl.Instance:FlushView("armor")
	end
	self.guard_info_view:Flush()
	if self.exp_buy_view:IsOpen() then
		self.exp_buy_view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.FuBen_Armor)
	RemindManager.Instance:Fire(RemindName.FuBen_ShouHu)
end

--个人塔防奖励
function FuBenCtrl:OnAutoFBRewardDetail(protocol)
	self.fu_ben_data:SetAutoFBRewardDetail2(protocol)
	if protocol.fb_type == GameEnum.FB_CHECK_TYPE.FBCT_ARMOR_FB then
		TipsCtrl.Instance:ShowRewardView(protocol.item_list, true)
	end
	if protocol.fb_type == GameEnum.FB_CHECK_TYPE.FBCT_TOWERDEFEND_PERSONAL then
		ViewManager.Instance:Open(ViewName.FBFinishStarView, nil, "shouhu_finsh", {data = protocol.item_list, star = 3})
	end

	--品质本扫荡
	if protocol.fb_type == GameEnum.FB_CHECK_TYPE.FBCT_CHALLENGE then
		ViewManager.Instance:Open(ViewName.FBFinishStarView, nil, "finish", {data = protocol.item_list, star = 3})
	end
end

--个人塔防警告
function FuBenCtrl:OnTowerDefendWarning(protocol)
	if protocol.warning_type == 1 then
		self.fu_ben_data:SetTowerIsWarning(true)
		-- SysMsgCtrl.Instance:ErrorRemind(Language.TowerDefend.TowerBeHurt)
		local txt = Scene.Instance:GetSceneType() == 76 and Language.TowerDefend.TowerBeHurt1 or Language.TowerDefend.TowerBeHurt
		TipsCtrl.Instance:ShowEventNoticeMsg(txt, TIPSEVENTTYPES.OTHER)
	else
		self.fu_ben_data:SetTowerIsWarning(true)
		-- SysMsgCtrl.Instance:ErrorRemind(string.format(Language.TowerDefend.TowerHpTooLess, protocol.percent .. "%"))
		local str = Scene.Instance:GetSceneType() == 76 and string.format(Language.TowerDefend.TowerHpTooLess1, protocol.percent .. "%") or string.format(Language.TowerDefend.TowerHpTooLess, protocol.percent .. "%")
		TipsCtrl.Instance:ShowEventNoticeMsg(str, TIPSEVENTTYPES.SPECIAL)
	end
end

--个人塔防信息
function FuBenCtrl:OnTowerDefendInfo(protocol)
	self.fu_ben_data:SetTowerDefendInfo(protocol)
	self.guard_info_view:Flush()

	if protocol.is_finish == 1 then
		local function callback()
			if protocol.is_pass == 1 then
				self.time_request = GlobalTimerQuest:AddDelayTimer(function()
					local info = FuBenData.Instance:GetTowerDefendRoleInfo()
					if info then
						local star_num = 3
						ViewManager.Instance:Open(ViewName.FBFinishStarView, nil, "shouhu_finsh", {data = protocol.pick_drop_list, star = star_num})
						if ViewManager.Instance:IsOpen(ViewName.FBFailFinishView) then
							ViewManager.Instance:Close(ViewName.FBFailFinishView)
						end
					end
				end, 1)
			else
				ViewManager.Instance:Open(ViewName.FBFailFinishView)
			end
		end
		self:RemoveOpenCountDown()
		self.open_delay = GlobalTimerQuest:AddDelayTimer(callback, OPEN_DELAY_TIME)
	end
end

--个人塔防掉落
function FuBenCtrl:OnFBDropInfo(protocol)
	self.fu_ben_data:SetFBDropInfo(protocol)
	if ViewManager.Instance:IsOpen(ViewName.FBDropView) then
		ViewManager.Instance:FlushView(ViewName.FBDropView)
	end
end

--个人塔防结果
function FuBenCtrl:OnTowerDefendResult(protocol)
	-- local function callback()
	-- 	if 1 == protocol.is_passed then
	-- 		local time = TimeUtil.FormatSecond(protocol.use_time, 7) or 0
	-- 		if protocol.have_pass_reward == 1 then
	-- 			local data_list = {}
	-- 			local scene_cfg = FuBenData.Instance:GetReward(FuBenTeamType.TEAM_TYPE_TEAM_TOWERDEFEND)
	-- 			if scene_cfg then
	-- 				for i = 1, 3 do
	-- 					data_list[i] = scene_cfg[i - 1]
	-- 				end
	-- 			end
	-- 			ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "team_result", {data = data_list, time = time})
	-- 			FuBenData.Instance:SetDefaultChoose(ScoietyData.InviteOpenType.TeamTowerDefend)
	-- 		else
	-- 			ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "no_result", {time = time})
	-- 			FuBenData.Instance:SetDefaultChoose(ScoietyData.InviteOpenType.TeamTowerDefend)
	-- 		end
	-- 		ViewManager.Instance:Open(ViewName.FuBen, TabIndex.fb_team_tower)
	-- 	elseif 0 == protocol.is_passed then
	-- 		ViewManager.Instance:Open(ViewName.FBFailFinishView)
	-- 		FuBenData.Instance:SetDefaultChoose(ScoietyData.InviteOpenType.TeamTowerDefend)
	-- 		ViewManager.Instance:Open(ViewName.FuBen, TabIndex.fb_team_tower)
	-- 	end
	-- end
	-- self:RemoveOpenCountDown()
	-- self.open_delay = GlobalTimerQuest:AddDelayTimer(callback, OPEN_DELAY_TIME)
	self.fu_ben_data:SetTowerDefendResult(protocol)
end

--个人塔防结束
function FuBenCtrl:OnFBFinish(protocol)

end

--个人塔防购买次数
function FuBenCtrl.SendTowerDefendBuyJoinTimes()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSTowerDefendBuyJoinTimes)
	send_protocol:EncodeAndSend()
end

--个人塔防刷新下一波
function FuBenCtrl.SendTowerDefendNextWave()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSTowerDefendNextWave)
	send_protocol:EncodeAndSend()
end


-- 推图总协议下来
function FuBenCtrl:OnTuituFbInfo(protocol)
	self.fu_ben_data:SetTuituFbInfo(protocol)
	-- RemindManager.Instance:Fire(RemindName.FuBen_XueZhan)
	RemindManager.Instance:Fire(RemindName.BeStrength)
	self.fu_ben_view:Flush("push")
end

-- 推图通关协议
function FuBenCtrl:OnTuituFbResultInfo(protocol)
	self.fu_ben_data:SetTuituFbResultInfo(protocol)
	if ViewManager.Instance:IsOpen(ViewName.FuBenPushInfoView) then
		self.push_info_view:Flush()
	end
end

-- -- 推图信息变动
function FuBenCtrl:OnTuituFbSingleInfo(protocol)
	self.fu_ben_data:SetTuituFbSingleInfo(protocol)
	RemindManager.Instance:Fire(RemindName.BeStrength)
	self.fu_ben_view:Flush("push")
end

-- 领取奖励返回
function FuBenCtrl:OnTuituFbFetchResultInfo(protocol)
	if protocol.is_success == 1 and protocol.fb_type == PUSH_FB_TYPE.PUSH_FB_TYPE_NORMAL then
		FuBenData.Instance:OnPushFbFetchShowStarRewardSucc(protocol)
		-- TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_PUSH_FB_STAR_REWARD)
	end
end

-- 推图本信息请求
function FuBenCtrl:SendTuituFbOperaReq(opera_type, param_1, param_2, param_3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSTuituFbOperaReq)
	send_protocol.opera_type = opera_type or 0
	send_protocol.param_1 = param_1 or 0
	send_protocol.param_2 = param_2 or 0
	send_protocol.param_3 = param_3 or 0
	send_protocol:EncodeAndSend()
end

function FuBenCtrl:OnTaskChange()
	self:FlushMainUIRedPoint()
end

-- 请求领取奖励
function FuBenCtrl:SendNeqFBStarRewardReq(chapter, seq)
	local protocol = ProtocolPool.Instance:GetProtocol(CSNeqFBStarRewardReq)
	protocol.chapter = chapter or 0
	protocol.seq = seq or 0
	protocol:EncodeAndSend()
end

-- 新装备本请求购买次数
function FuBenCtrl:SendNeqFBBuyTimesReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSNeqFBBuyTimesReq)
	protocol:EncodeAndSend()
end

function FuBenCtrl:SendNeqInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSNeqInfoReq)
	protocol:EncodeAndSend()
end

function FuBenCtrl:SendSwipeFB(chapter, level)
	local protocol = ProtocolPool.Instance:GetProtocol(CSNeqFBAutoReq)
	protocol.chapter = chapter
	protocol.level = level
	protocol:EncodeAndSend()
end

function FuBenCtrl:OnNeqFBInfo(protocol)
	self.fu_ben_data:SetNeqFBInfo(protocol)
	GaoZhanCtrl.Instance:FlushView("wptimes")
	GaoZhanCtrl.Instance:FlushView("weapon")
	local flush_type = protocol.info_type
	if flush_type == WEAPON_INFO_TYPE.NEQ_FB_INFO_VIP_BUY_TIME or flush_type == WEAPON_INFO_TYPE.NEQ_FB_INFO_ITEM_BUY_TIME then
		GaoZhanCtrl.Instance:FlushView("wptimes")
	elseif flush_type == WEAPON_INFO_TYPE.NWQ_FB_INFO_REWARD then
		GaoZhanCtrl.Instance:FlushView("wpreward")
	else
		GaoZhanCtrl.Instance:FlushView("weapon")
	end
	
	if self.exp_buy_view:IsOpen() then
		self.exp_buy_view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.FuBen_Weapon)
end

function FuBenCtrl:OnNeqPassInfo(protocol)
	self.fu_ben_data:SetNeqPassInfo(protocol)
	if 1 == protocol.pass_result then
		self.weapon_roll_view:Open()
		self.weapon_info_view:RemoveCountDown()
	elseif 0 == protocol.pass_result then
		GlobalTimerQuest:AddDelayTimer(function()
			ViewManager.Instance:Open(ViewName.FBFailFinishView)
		end, 1)
	end
end

-- 新装备本翻牌奖励池
function FuBenCtrl:OnNeqRollPool(protocol)
	self.fu_ben_data:SetNeqRollPool(protocol)
	self.weapon_roll_view:Flush("reward")
end

function FuBenCtrl:OnNeqRollInfo(protocol)
	self.fu_ben_data:SetNeqRollInfo(protocol)
	self.weapon_roll_view:Flush("rollreward")
end

-- 翻牌请求
function FuBenCtrl:SendNeqRollReq(end_roll)
	local protocol = ProtocolPool.Instance:GetProtocol(CSNeqRollReq)
	protocol.end_roll = end_roll
	protocol:EncodeAndSend()
end

---------------防具材料副本请求----------
function FuBenCtrl:SendArmorDefendRoleReq(req_type, parm1)
	local protocol = ProtocolPool.Instance:GetProtocol(CSArmorDefendRoleReq)
	protocol.req_type = req_type or 0
	protocol.parm1 = parm1 or 0
	protocol:EncodeAndSend()
end

--防具材料信息
function FuBenCtrl:OnArmorDefendRoleInfo(protocol)
	self.fu_ben_data:SetArmorDefendRoleInfo(protocol)
	GaoZhanCtrl.Instance:FlushView("tower_defend")
	-- self.fu_ben_view:Flush("armor")
	if self.exp_buy_view:IsOpen() then
		self.exp_buy_view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.FuBen_ShouHu)
	RemindManager.Instance:Fire(RemindName.FuBen_Armor)
end

function FuBenCtrl:OnArmorDefendResult(protocol)
	self:RemoveOpenCountDown()
	self.fu_ben_data:SetGuardPass(protocol)
	local function callback()
		if protocol.is_passed == 1 then
			local num = 0
			local time = 0
			local info = FuBenData.Instance:GetArmorDefendInfo()
			if info then
				num = info.escape_monster_count
				time = TimeUtil.FormatSecond(protocol.use_time, 7)
				local item_data = protocol.item_list
				if TaskData.Instance:GetIsArmorTask() then
					item_data[1] = FuBenData.Instance:GetArmorDefendCfgOther().guid_reward_item[0]
				end
				ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "armor_result", {data = item_data, time = time, num = num})--, func = func})
			end
		else
			ViewManager.Instance:Open(ViewName.FBFailFinishView)
		end
	end
	self.open_delay = GlobalTimerQuest:AddDelayTimer(callback, OPEN_DELAY_TIME)
	
end

--防具材料场景信息
function FuBenCtrl:OnArmorDefendInfo(protocol)
	self.fu_ben_data:SetArmorDefendInfo(protocol)
	self.armor_info_view:Flush()
end

function FuBenCtrl:OnArmorDefendWarning(protocol)
	self.armor_info_view:EscapeWarning(protocol.escape_num)
end

-- 使用群攻技能
function FuBenCtrl:ArmorSedUseSkill()
	self.armor_info_view:SedUseSkill()
end

function FuBenCtrl:ArmorPlaySkillAnim(target)
	self.armor_info_view:PlaySkillAnim(target)
end

function FuBenCtrl:OnArmorDefendPerformSkill(protocol)
	self.fu_ben_data:SetArmorDefendPerformSkill(protocol)
	if ViewManager.Instance:IsOpen(ViewName.FuBenArmorInfoView) then
		self.armor_info_view:Flush()
	end
end

----------------------塔防副本信息---------------------
function FuBenCtrl:SendBuildTowerReq(operate_type, param1, param2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSBuildTowerReq)
	protocol.operate_type = operate_type
	protocol.param1 = param1 or 0
	protocol.param2 = param2 or 0
	protocol:EncodeAndSend()
end

function FuBenCtrl:SendBuildTowerBuyTimes()
	local protocol = ProtocolPool.Instance:GetProtocol(CSBuildTowerBuyTimes)
	protocol:EncodeAndSend()
end

function FuBenCtrl:SetBuildTowerBuyTimes(num)
	self.fu_ben_data:SetBuildTowerBuyTimes(num)
	self.fu_ben_view:Flush("defense")
end

function FuBenCtrl:SetBuildTowerEnterTimes(num)
	self.fu_ben_data:SetBuildTowerEnterTimes(num)
	self.fu_ben_view:Flush("defense")
end

function FuBenCtrl:SetTargetObjData(target_obj)
	self.defense_tips:SetTargetObjData(target_obj)
end

function FuBenCtrl:SetBuildTargetObjData(target_obj)
	self.defense_tips:SetBuildTargetObjData(target_obj)
end

function FuBenCtrl:OpenDefenseTips(index)
	self.defense_tips:SetIndex(index)
end

function FuBenCtrl:CloseDefenseTips()
	self.defense_tips:Close()
end

function FuBenCtrl:OpenDefenseSweep()
	self.defense_sweep:Open()
end

function FuBenCtrl:OnBuildTowerFBInfo(protocol)
	self.fu_ben_data:SetBuildTowerFBInfo(protocol)
	self.defense_info_view:Flush()
	self.defense_tips:Flush("updata")
	self.defense_tips:Flush("update_reward")

	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic.FlushDefenseObjVisible then
		scene_logic:FlushDefenseObjVisible()
	end

	-- if protocol.data.notify_reason == BUILD_TOWER_NOTIFY_REASON.NOTIFY_MONSTER_WAVE then
	-- 	if protocol.data.cur_wave + 1 > 1 and TipsCtrl.Instance:GetCommonAutoCheck() then 
	-- 		self:SendBuildTowerReq(BUILD_TOWER_OPERA_TYPE.BUILD_TOWER_OPERA_TYPE_CALL)
	-- 		self:CloseDefenseTips()
	-- 	end
	-- end

	if protocol.data.is_pass == 1 and protocol.data.is_finish == 1 then
		local show_reward = FuBenData.Instance:GetBuildTowerShowReward()
		self:RemoveOpenCountDown()
		self.open_delay = GlobalTimerQuest:AddDelayTimer(function()
			ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "finish", {data = show_reward, leave_time = 5})
		end, OPEN_DELAY_TIME)
		self:CloseDefenseTips()
	end

	if protocol.data.is_pass == 0 and protocol.data.is_finish == 1 
		and protocol.data.notify_reason == BUILD_TOWER_NOTIFY_REASON.NOTIFY_FB_END then
		self:RemoveOpenCountDown()
		self.open_delay = GlobalTimerQuest:AddDelayTimer(function()
			ViewManager.Instance:Open(ViewName.FBFailFinishView)
		end, OPEN_DELAY_TIME)
	end
end

------------------------组队守护
function FuBenCtrl:SendTeamTowerDefendSetAttrType(req_type, param1, param2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSTeamTowerDefendOpreatReq)
	protocol.req_type = req_type or 0
	protocol.param1 = param1 or 0
	protocol.param2 = param2 or 0
	protocol:EncodeAndSend()
end

function FuBenCtrl:OnTeamTowerInfo(protocol)
	self.fu_ben_data:TeamTowerInfo(protocol)
	self.team_tower_info_view:Flush()
end

function FuBenCtrl:OnTeamTowerDefendAttrType(protocol)
	self.fu_ben_data:TeamTowerDefendAttrType(protocol)
	self.fu_ben_view:Flush("team")
end

function FuBenCtrl:SCFBInfo(type_num, protocol)
	FuBenData.Instance:SetTeamFBInfo(type_num, protocol)
	if self.fb_info_callback then
		self.fb_info_callback()
	end

	if protocol <= 0 then
		if type_num == DAY_COUNT.DAYCOUNT_ID_TEAM_TOWERDEFEND_JOIN_TIMES then
			FuBenCtrl.Instance:SendTeamTowerRewardInfo(TeamFBType[2], 0)
		elseif type_num == DAY_COUNT.DAYCOUNT_ID_TEAM_EQUIP_FB_JOIN_TIMES then
			FuBenCtrl.Instance:SendTeamTowerRewardInfo(TeamFBType[1], 0)
		end
	end
	RemindManager.Instance:Fire(RemindName.FuBen_Team)
end

function FuBenCtrl:SetInfoCallBack(func)
	self.fb_info_callback = func
end

function FuBenCtrl:SCTeamFBUserInfo(protocol)
	self.fu_ben_data:IsFirstEnter(protocol)
end

function FuBenCtrl:OnTeamTowerDefendSkill(protocol)
	self.fu_ben_data:SetTeamTowerDefendSkill(protocol)
	self.team_tower_info_view:Flush("CD")
end

function FuBenCtrl:ShowFuBenTeamSkillExplain(index)
	if self.fu_ben_team_skill_explain_view then
		self.fu_ben_team_skill_explain_view:Open()
		self.fu_ben_team_skill_explain_view:SetIndex(index)
		self.fu_ben_team_skill_explain_view:Flush()
	end
end

function FuBenCtrl:OnTeamTowerDefendAllRole(protocol)
	self.fu_ben_data:SetTeamTowerDefendAllRole(protocol)
	if self.team_tower_info_view and self.team_tower_info_view:IsOpen() then
		self.team_tower_info_view:FlushTeamInfo()
	end
end

function FuBenCtrl:OnTeamTowerDefendResult(protocol)
	self.fu_ben_data:SetTeamTowerDefendResult(protocol)
end

----------------组队副本(须臾幻境)协议--------------
function FuBenCtrl:OnEquipFBResult(protocol)
	self.fu_ben_data:SetTeamSpecialResult(protocol)
	local team_special_is_passed = self.fu_ben_data:GetTeamSpecialIsPass()
	if team_special_is_passed and team_special_is_passed == 1 and protocol.is_all_over == 0 then
		Scene.Instance:CreateDoorList()
	else
		Scene.Instance:DeleteObjsByType(SceneObjType.Door)
	end

	if ViewManager.Instance:IsOpen(ViewName.FuBenSpecialInfoView) then
		self.team_special_info_view:Flush()
		Scene.Instance:CheckClientObj()
	end

	-- if (protocol.is_finish == 1 and protocol.is_all_over == 1) or (protocol.is_finish == 1 and protocol.is_passed == 0) then
	-- 	FuBenData.Instance:ClearFBDropInfo()
	-- 	ViewManager.Instance:Close(ViewName.FBDropView)
	-- 	self:RemoveOpenCountDown()
	-- 	local function callback()
	-- 		local time = TimeUtil.FormatSecond(protocol.use_time, 7) or 0
	-- 		if protocol.is_passed == 1 then
	-- 			if protocol.have_pass_reward == 1 then
	-- 				if protocol.is_leave == 0 then
	-- 					GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	-- 					ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "team_result", {data = protocol.item_list, time = time})
	-- 				end
	-- 			else
	-- 				if protocol.is_leave == 0 then
	-- 					FuBenCtrl.Instance:SendExitFBReq()
	-- 				else
	-- 					ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "no_result", {time = time})
	-- 				end
	-- 			end
	-- 		else
	-- 			ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "team_result", {data = protocol.item_list, time = time})
	-- 		end
	-- 		if protocol.is_leave == 1 then
	-- 			FuBenData.Instance:SetDefaultChoose(ScoietyData.InviteOpenType.EquipTeamFbNew)
	-- 			local role_level = PlayerData.Instance:GetRoleVo().level
	-- 			if role_level >= GameEnum.NOVICE_LEVEL then
	-- 				ViewManager.Instance:Open(ViewName.FuBen, TabIndex.fb_team_tower)
	-- 			end
	-- 		end
	-- 	end
	-- 	self.open_delay = GlobalTimerQuest:AddDelayTimer(callback, OPEN_DELAY_TIME)
	-- end
end


function FuBenCtrl:FlushTowerRank()
	self.fu_ben_tower_rank:Flush()
end
function FuBenCtrl:FulshEndTime()
	self.quality_info_view:OpenNextWaveCountDown()
end

function FuBenCtrl:SetPhaseLevle(index)
	self.phase_level = index
end

function FuBenCtrl:GetPhaseLevle()
	if self.phase_level then
		return self.phase_level
	end
end

function FuBenCtrl:SetCanMove(is_move)
		self.can_move = is_move
end

function FuBenCtrl:GetCanMove()
	return self.can_move
end

function FuBenCtrl:GetFuwenImgState(is_show)
	self.tower_info_view:FuwenImgState(is_show)
end

function FuBenCtrl:OpenFuBenGetView(data)
	if self.fu_ben_get_view then
		self.fu_ben_get_view:Open()
		self.fu_ben_get_view:SetData(data)
		self.fu_ben_get_view:Flush()
	end
end

function FuBenCtrl:SetWeaponRemind()
	self.is_remind_weapon = false
end

function FuBenCtrl:GetWeaponRemind()
	return self.is_remind_weapon
end

function FuBenCtrl:SetArmorRemind()
	self.is_remind_armor = false
end

function FuBenCtrl:GetArmorRemind()
	return self.is_remind_armor
end

function FuBenCtrl:SetGuardRemind()
	self.is_remind_guard = false
end

function FuBenCtrl:GetGuardRemind()
	return self.is_remind_guard
end

function FuBenCtrl:SetExpRemind()
	self.is_remind_fb_exp = false
end

function FuBenCtrl:GetExpRemind()
	return self.is_remind_fb_exp
end

function FuBenCtrl:SetTeamRemind()
	self.is_remind_fb_team = false
end

function FuBenCtrl:GetTeamRemind()
	return self.is_remind_fb_team
end

function FuBenCtrl:SetDefenseRemind()
	self.is_remind_fb_defense = false
end

function FuBenCtrl:GetDefenseRemind()
	return self.is_remind_fb_defense
end

---------------------------------组队副本奖励-------------------------------
function FuBenCtrl:SendTeamTowerRewardInfo(req_type, param1)
	local protocol = ProtocolPool.Instance:GetProtocol(CSFetchDoubleRewardReq)
	protocol.fuben_type = req_type or 0
	protocol.fb_time = param1 or 0
	protocol:EncodeAndSend()
end

function FuBenCtrl:OnFetchDoubleRewardResult(protocol)
	self.fu_ben_data:SetFBTowerRewardInfo(protocol)
	self.fu_ben_view:Flush("team")
end

function FuBenCtrl:FlushFBTeamInfo()
	if self.fu_ben_view then
		self.fu_ben_view:Flush("team")
	end
end


function FuBenCtrl:SetClickGoToShuiJing()
	if self.fu_ben_icon_view then
		self.fu_ben_icon_view:OnClickGoToShuiJing()
	end
end

