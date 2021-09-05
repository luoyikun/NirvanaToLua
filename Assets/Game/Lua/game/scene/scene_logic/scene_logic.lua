require("game/scene/scene_logic/base_scene_logic")
require("game/scene/scene_logic/common_scene_logic")
require("game/scene/scene_logic/base_fb_logic")
require("game/scene/scene_logic/common_act_logic")
require("game/scene/scene_logic/crossserver_scene_logic")
require("game/scene/scene_logic/phase_fb_logic")
require("game/scene/scene_logic/exp_fb_logic")
require("game/scene/scene_logic/story_fb_logic")
require("game/scene/scene_logic/tower_fb_logic")
require("game/scene/scene_logic/vip_fb_logic")
require("game/scene/scene_logic/quality_fb_logic")
require("game/scene/scene_logic/push_fb_logic")
require("game/scene/scene_logic/hunyan_fb_logic")
require("game/scene/scene_logic/qingyuan_fb_logic")
require("game/scene/scene_logic/kf_onevone_scene_logic")
require("game/scene/scene_logic/kf_xiuluo_tower_scene_logic")
require("game/scene/scene_logic/sky_money_fb_logic")
require("game/scene/scene_logic/guild_battle_scene_logic")
require("game/scene/scene_logic/clash_territory_scene_logic")
require("game/scene/scene_logic/element_scene_logic")
require("game/scene/scene_logic/tomb_explore_fb_logic")
require("game/scene/scene_logic/kf_hot_spring_scene_logic")
require("game/scene/scene_logic/city_combat_scene_logic")
require("game/scene/scene_logic/team_equip_fb_logic")
require("game/scene/scene_logic/team_special_fb_logic")
require("game/scene/scene_logic/team_tower_fb_logic")
require("game/scene/scene_logic/guild_station_logic")
require("game/scene/scene_logic/cross_boss_scene_logic")
require("game/scene/scene_logic/zhongkui_scene_logic")
require("game/scene/scene_logic/weapon_materials_fb_logic")
require("game/scene/scene_logic/tower_armor_fb_scene_logic")
require("game/scene/scene_logic/defense_fb_scene_logic")
require("game/scene/scene_logic/guild_mijing_scene_logic")
require("game/scene/scene_logic/cross_crystal_scene_logic")
require("game/scene/scene_logic/base_guide_fb_logic")
require("game/scene/scene_logic/wing_story_fb_logic")
require("game/scene/scene_logic/mount_story_fb_logic")
require("game/scene/scene_logic/xiannv_story_fb_logic")
require("game/scene/scene_logic/fun_guide_fb_logic")
require("game/scene/scene_logic/rune_tower_fb_logic")
require("game/scene/scene_logic/dafuhao_scene_logic")
require("game/scene/scene_logic/daily_task_fb_scene_logic")
require("game/scene/scene_logic/xing_zuo_yi_ji_scene_logic")
require("game/scene/scene_logic/tower_defend_fb_scene_logic")
require("game/scene/scene_logic/yizhandaodi_scene_logic")
require("game/scene/scene_logic/arena_scene_logic")
require("game/scene/scene_logic/kf_arena_scene_logic")
require("game/scene/scene_logic/mining_scene_logic")
require("game/scene/scene_logic/shengdi_fb_logic")
require("game/scene/scene_logic/farmhunting_scene_logic")
require("game/scene/scene_logic/kf_guild_battle_scene_logic")
require("game/scene/scene_logic/combine_server_boss_logic")
require("game/scene/scene_logic/kf_tuanzhan_logic")
require("game/scene/scene_logic/kf_month_black_wind_high_scene_logic")
require("game/scene/scene_logic/sg_boss_scene_logic")
require("game/scene/scene_logic/baby_fb_logic")
require("game/scene/scene_logic/fishing_sence_logic")
require("game/scene/scene_logic/personal_boss_scene_logic")
require("game/scene/scene_logic/luandou_battle_scene_logic")
require("game/scene/scene_logic/guild_answer_scnec_logic")
require("game/scene/scene_logic/zhuanzhi_fb_logic")
require("game/scene/scene_logic/kf_pvp_scene_logic")
require("game/scene/scene_logic/kf_ling_kun_battle_scene_logic")
require("game/scene/scene_logic/single_party_fb_scene_logic")
require("game/scene/scene_logic/cross_youming_boss_scene_logic")
require("game/scene/scene_logic/cross_mizang_boss_scene_logic")
require("game/scene/scene_logic/godmagic_boss_scene_logic")
require("game/scene/scene_logic/gift_harvest_scene_logic")
require("game/scene/scene_logic/kf_borderland_scene_logic")
require("game/scene/scene_logic/audit_version_longcheng_scene_logic")
require("game/scene/scene_logic/crystal_escort_scene_logic")

SceneLogic = SceneLogic or {}

function SceneLogic.Create(scene_type, scene_id)
	local scene_logic = nil
	print_log("SceneLogic.Create, scene_type ==", scene_type)
	-- 根据场景类型创建场景逻辑
	if SceneType.Common == scene_type then
		scene_logic = CommonSceneLogic.New()
	elseif SceneType.CampGaojiDuobao == scene_type then
		scene_logic = BaseFbLogic.New()
	elseif SceneType.PhaseFb == scene_type then
		scene_logic = PhaseFbLogic.New()
	elseif SceneType.ExpFb == scene_type then
		scene_logic = ExpFbLogic.New()
	elseif SceneType.StoryFB == scene_type then
		scene_logic = StoryFbLogic.New()
	elseif SceneType.PataFB == scene_type then
		scene_logic = TowerFbLogic.New()
	elseif SceneType.VipFB == scene_type then
		scene_logic = VipFbLogic.New()
	elseif SceneType.HunYanFb == scene_type then
		scene_logic = HunYanFbLogic.New()
	elseif SceneType.QingYuanFB == scene_type then
		scene_logic = QingYuanFbLogic.New()
	elseif SceneType.ShengDiFB == scene_type then
		scene_logic = ShengDiFbLogic.New()
	elseif SceneType.Kf_OneVOne == scene_type then
		scene_logic = KfOneVOneSceneLogic.New()
	elseif SceneType.Kf_PVP == scene_type then
		scene_logic = KfPVPSceneLogic.New()
	elseif SceneType.Kf_XiuLuoTower == scene_type then
		scene_logic = KFXiuLuoTowerSceneLogic.New()
	elseif SceneType.TombExplore == scene_type then
		scene_logic = TombExploreFBLogic.New()
	elseif SceneType.TianJiangCaiBao == scene_type then
		scene_logic = SkyMoneySceneLogic.New()
	elseif SceneType.LingyuFb == scene_type then
		scene_logic = GuildBattleSceneLogic.New()
	elseif SceneType.HotSpring == scene_type then
		scene_logic = KfHotSpringSceneLogic.New()
	elseif SceneType.GongChengZhan == scene_type then
		scene_logic = CityCombatFBLogic.New()
	elseif SceneType.TeamEquipFb == scene_type then
		scene_logic = TeamEquipFBLogic.New()
	elseif SceneType.GuildStation == scene_type then
		scene_logic = GuildStationLogic.New()
	elseif SceneType.ClashTerritory == scene_type then
		scene_logic = ClashTerritoryLogic.New()
	elseif SceneType.QunXianLuanDou == scene_type then
		scene_logic = ElementSceneLogic.New()
	elseif SceneType.CrossBoss == scene_type then
		scene_logic = CrossBossSceneLogic.New()
	elseif SceneType.ZhongKui == scene_type then
		scene_logic = ZhongKuiSceneLogic.New()
	elseif SceneType.GuildMiJingFB == scene_type then
		scene_logic = GuildMiJingSceneLogic.New()
	elseif SceneType.ShuiJing == scene_type then
		scene_logic = CrossCrystalSceneLogic.New()
	elseif SceneType.WingStoryFb == scene_type then
		scene_logic = WingStorySceneLogic.New()
	elseif SceneType.MountStoryFb == scene_type then
		scene_logic = MountStoryFbLogic.New()
	elseif SceneType.XianNvStoryFb == scene_type then
		scene_logic = XianNvStoryFbLogic.New()
	elseif SceneType.GuideFb == scene_type then
		scene_logic = FunGuideFbLogic.New()
	elseif SceneType.RuneTower == scene_type then
		scene_logic = RuneTowerFbLogic.New()
	elseif SceneType.DaFuHao == scene_type then
		scene_logic = DafuhaoSceneLogic.New()
	elseif SceneType.DailyTaskFb == scene_type then
		scene_logic = DailyTaskFbSceneLogic.New()
	elseif SceneType.XingZuoYiJi == scene_type then
		scene_logic = XingZuoYiJiSceneLogic.New()
	elseif SceneType.ChaosWar == scene_type then
		scene_logic = YiZhanDaoDiSceneLogic.New()
	elseif SceneType.ChallengeFB == scene_type then
		scene_logic = QualityFbLogic.New()
	elseif SceneType.TowerDefend == scene_type then
		scene_logic = TowerDefendFbSceneLogic.New()
	elseif SceneType.ArmorDefensefb == scene_type then
		scene_logic = TowerArmorFbSceneLogic.New()
	elseif SceneType.TeamTowerFB == scene_type then
		scene_logic = TeamTowerSceneLogic.New()
	elseif SceneType.TeamSpecialFB == scene_type then
		scene_logic = TeamSpecialFbLogic.New()
	elseif SceneType.Defensefb == scene_type then
		scene_logic = DefenseFbSceneLogic.New()
	elseif SceneType.SingleParty == scene_type then
		scene_logic = SinglePartyFbSceneLogic.New()
	elseif SceneType.SCENE_TYPE_TUITU_FB == scene_type then
		scene_logic = PushFbLogic.New()
	elseif SceneType.Field1v1 == scene_type then
		scene_logic = ArenaSceneLogic.New()
	elseif SceneType.Mining == scene_type then
		scene_logic = MiningSceneLogic.New()
	elseif SceneType.CrossGuild == scene_type then
		scene_logic = KfGuildBattleSceneLogic.New()
	elseif SceneType.CombineServerBoss == scene_type then
		scene_logic = CombineServerBossLogic.New()
	elseif SceneType.FarmHunting == scene_type then
		scene_logic = FarmHuntingSceneLogic.New()
	elseif SceneType.WeaponMaterialsFb == scene_type then
		scene_logic = WeaponMaterialsFbLogic.New()
	elseif SceneType.MonthBlackWindHigh == scene_type then
		scene_logic = KFMonthBlackWindHighSceneLogic.New()
	elseif SceneType.CrossTuanZhan == scene_type then
		scene_logic = KfTuanZhanLogic.New()
	elseif SceneType.SG_BOSS == scene_type then
		scene_logic = SgBossSceneLogic.New()
	elseif SceneType.KF_Fish == scene_type then
		scene_logic = FishingSceneLogic.New()
	elseif SceneType.BabyBoss == scene_type then
		scene_logic = BabyFBLogic.New()
	elseif SceneType.GUILD_ANSWER_FB == scene_type then
		scene_logic = GuildAnswerSceneLogic.New()
	elseif SceneType.PersonalBoss == scene_type then
		scene_logic = PersonalBossSceneLogic.New()
	elseif SceneType.LuandouBattle == scene_type then
		scene_logic = LuanDouBattleSceneLogic.New()
	elseif SceneType.KF_NightFight == scene_type then
		scene_logic = KfTuanZhanLogic.New()
	elseif SceneType.ZhuanZhiFb == scene_type then
		scene_logic = ZhuanZhiFbLogic.New()
	elseif SceneType.CrossLieKun_FB == scene_type then
		scene_logic = KfLingKunBattleSceneLogic.New()
	elseif SceneType.KFMiZangBoss == scene_type then
		scene_logic = CrossMiZangBossSceneLogic.New()
	elseif SceneType.KFYouMingBoss == scene_type then
		scene_logic = CrossYouMingBossSceneLogic.New()
	elseif SceneType.GodMagicBoss == scene_type then
		scene_logic = GodMagicBossSceneLogic.New()
	elseif SceneType.GiftHarvest == scene_type then
		scene_logic = GiftHarvest.New()
	elseif SceneType.KF_Borderland == scene_type then
		scene_logic = KFBorderlandSceneLogin.New()
	elseif SceneType.KF_Arena == scene_type then
		scene_logic = KFArenaSceneLogic.New()
	elseif SceneType.CrystalEscort == scene_type then
		scene_logic = CrystalEscortSceneLogic.New()
	elseif SceneType.Audit_Version_LongCheng == scene_type then
		scene_logic = AuditVersionLongChengSceneLogic.New()
	else
		scene_logic = BaseSceneLogic.New()
	end
	if scene_logic ~= nil then
		scene_logic:SetSceneType(scene_type)
	end

	return scene_logic
end
