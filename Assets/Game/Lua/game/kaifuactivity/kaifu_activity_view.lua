require("game/kaifuactivity/kaifu_activity_panel_one")
require("game/kaifuactivity/kaifu_activity_panel_three")
require("game/kaifuactivity/kaifu_activity_panel_six")
require("game/kaifuactivity/kaifu_activity_panel_seven")
require("game/kaifuactivity/kaifu_activity_panel_eight")
require("game/kaifuactivity/kaifu_activity_panel_two")
require("game/kaifuactivity/kaifu_activity_panel_ten")
require("game/kaifuactivity/kaifu_activity_panel_twelve")
require("game/kaifuactivity/kaifu_activity_panel_personal_buy")
require("game/kaifuactivity/kaifu_activity_panel_everyday_buy")
require("game/welfare/welfare_level_reward_view")
require("game/kaifuactivity/kaifu_activity_panel_fifteen")
require("game/kaifuactivity/kaifu_activity_panel_congzhi_rank")
require("game/kaifuactivity/kaifu_activity_panel_xiaofei_rank")
require("game/kaifuactivity/kaifu_activity_panel_bianshen_rank")
require("game/kaifuactivity/kaifu_activity_panel_beibianshen_rank")
require("game/kaifuactivity/kaifu_activity_panel_danbichongzhi")
require("game/kaifuactivity/kaifu_activity_panel_lianchongtehui_gao")
require("game/kaifuactivity/kaifu_activity_panel_lianchongtehui_chu")
require("game/kaifuactivity/kaifu_activity_goldenpigcall_view")
require("game/kaifuactivity/kaifu_activity_7day_redpacket")
require("game/kaifuactivity/kaifu_activity_panel_total_consume")
require("game/kaifuactivity/kaifu_activity_panel_leiji_reward")
require("game/kaifuactivity/kaifu_activity_panel_total_charge")
require("game/kaifuactivity/kaifu_activity_panel_guild_fight")
require("game/kaifuactivity/kaifu_activity_panel_recharge_rebate")
require("game/kaifuactivity/kaifu_activity_panel_snap")
require("game/kaifuactivity/kaifu_activity_panel_singledaychongzhi")
require("game/kaifuactivity/kaifu_activety_panel_jubaopen")
require("game/kaifuactivity/kaifu_activity_panel_lianxuchongzhi")
require("game/kaifuactivity/daily_love_view")
require("game/kaifuactivity/daily_gift_view")
require("game/kaifuactivity/getreward_view")
require("game/kaifuactivity/supreme_members_view")
require("game/hefuactivity/hefu_activity_panel_boss_loot")
require("game/hefuactivity/hefu_activity_panel_city_contend")
require("game/hefuactivity/hefu_activity_panel_rush_to_purchase")
require("game/hefuactivity/hefu_activity_panel_luckly_turntable")
require("game/hefuactivity/hefu_activity_panel_snap")
require("game/hefuactivity/hefu_activity_panel_snap_person")
require("game/hefuactivity/combine_server_chongzhi_rank_view")
require("game/hefuactivity/combine_server_consube_rank_view")
require("game/hefuactivity/combine_server_dan_bi_chong_zhi_view")
require("game/hefuactivity/combine_server_login_jiangli_view")
require("game/hefuactivity/haifu_activity_panel_boss")
require("game/hefuactivity/combine_server_boss_view")
require("game/hefuactivity/hefu_activity_touzi_plan_view")
require("game/hefuactivity/hefu_activity_jijin_view")
require("game/kaifuactivity/san_sheng_san_shi_view")
require("game/kaifuactivity/baojiday_view")
require("game/kaifuactivity/baojiday_view2")
require("game/kaifuactivity/quan_min_group_view")
require("game/kaifuactivity/quan_min_jin_jie_view")
require("game/serveractivity/expense_gift/expense_gift_view")
require("game/kaifuactivity/meiri_activity_happy_recharge_view")
require("game/kaifuactivity/activity_degree_reward_view")
require("game/kaifuactivity/activity_degree_reward2_view")
require("game/kaifuactivity/quan_min_chong_bang_view")
require("game/kaifuactivity/make_mooncake_view")
require("game/kaifuactivity/kaifu_activity_dialy_total_consume")
require("game/kaifuactivity/dan_bi_chong_zhi_view")
require("game/kaifuactivity/autumn_activity_panel_happy_ernie_view")
require("game/kaifuactivity/kaifu_activity_panel_dailydanbi")
require("game/kaifuactivity/activity_login_reward/activity_login_reward_view")
require("game/vip/level_investment_view")					-- 等级投资
require("game/vip/month_investment_view")					-- 周卡投资/月卡投资
require("game/kaifuactivity/kaifu_activity_touziplan_view")	-- 成长基金
require("game/kaifuactivity/kaifu_activity_fubentouzi_view")-- 副本投资
require("game/kaifuactivity/kaifu_activity_bosstouzi_view")	-- boss投资

local Act_Title_Name = {
	--活动标题
	[ACTIVITY_TYPE.OPEN_SERVER] = "bg_activity_title",
	[ACTIVITY_TYPE.COMBINE_SERVER] = "bg_activity_title2",
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_GIFT] = "bg_activity_title1",
}

local OpenNameList = {
	ViewName.Advance,
	ViewName.Advance,
	ViewName.Advance,
	ViewName.Advance,
	ViewName.Advance,
	ViewName.Advance,
	ViewName.Advance,
	ViewName.Goddess,
	ViewName.Goddess,
	ViewName.FuBen,
	ViewName.FuBen,
	ViewName.Forge,
	ViewName.Forge,
}

local Table_Index = {
	TabIndex.mount_jinjie,
	TabIndex.wing_jinjie,
	TabIndex.fashion_jinjie,
	TabIndex.role_shenbing,
	TabIndex.fabao_jinjie,
	TabIndex.foot_jinjie,
	TabIndex.halo_jinjie,
	TabIndex.goddess_shengong,
	TabIndex.goddess_shenyi,
	TabIndex.fb_tower,
	TabIndex.fb_exp,
	TabIndex.forge_strengthen,
	TabIndex.forge_baoshi,
	-- TabIndex.helper_upgrade,
}

local PaiHangBang_Index = {
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT,
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_WING,
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHIZHUANG,
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHIZHUANG_WUQI,
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_FABAO,
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_FOOTPRINT,
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_HALO,
}



local NODE_NAME_LIST = {
	[1] = "Panel1",
	[2] = "Panel3",
	[3] = "Panel6",
	[4] = "Panel7",
	[5] = "Panel8",
	[6] = "Panel9",
	-- [7] = "Panel10",
	[8] = "Panel12",
	[9] = "Panel11",
	[10] = "WelfareLevel",
	[11] = "7DayRedPackets",
	[12] = "GoldenPigCall",
	[13] = "Panel13",
	[14] = "Panel14",
	[15] = "Panel15",
	[16] = "Panel19",

	[18] = "DayChongZhiRank",
	[19] = "DayXiaoFeiRank",

	[22] = "TotalComsume",
	[23] = "LeijiReward",
	[24] = "DanBiChongZhi",
	[25] = "RechargeRebate",
	[26] = "TotalCharge",
	[27] = "FullServiceSnap",
	[28] = "DailyLove",
	[29] = "DialyTotalComsume",
	[30] = "GetReward",
	[31] = "hefu_panel_1",
	[32] = "hefu_panel_2",
	[33] = "hefu_panel_3",
	[34] = "hefu_panel_5",
	[35] = "hefu_panel_6",
	[36] = "hefu_panel_7",
	[37] = "hefu_panel_8",
	[38] = "hefu_panel_9",
	[39] = "hefu_panel_10",
	[40] = "hefu_panel_11",
	[41] = "hefu_panel_14",
	[42] = "hefu_panel_15",
	[43] = "hefu_panel_16",

	[45] = "SupremeMembers",
	[46] = "SingleDayChongZhi",
	[47] = "SanShengSanShiView",
	[48] = "BaojiDay",
	[49] = "DegreeRewardsView",
	[50] = "Happy_Recharge",
	[51] = "EverydayBuy",

	[53] = "QuanMinChongBangView",
	[54] = "QuanMinJinJieView",
	[55] = "QuanMinGroupView",
	[56] = "ExpenseNiceGiftContent",
	[57] = "JuBaoPen",

	[58] = "HappyDanBiChongZhi",
	[59] = "LoginRewardContent",

	[60] = "MakeMoonCakeContent",
	[61] = "DailyDanBi",
	[62] = "DailyGiftView",

	[63] = "LevelInvestment",
	[64] = "MonthCardInvestment",
	[65] = "TouZiPlanContent",
	[66] = "FuBenTouZiView",
	[67] = "BossTouZiView",
			
	[69] = "LianXuChongZhi",
	[70] = "AutumnHappyErnieContent",
	[71] = "DegreeRewardsView",
	[72] = "BaojiDay",
}

local RENDER_NAME_LIST = {
	[1] = KaifuActivityPanelOne,
	[2] = KaifuActivityPanelThree,
	[3] = KaifuActivityPanelSix,
	[4] = KaifuActivityPanelSeven,
	[5] = KaifuActivityPanelEight,
	[6] = KaifuActivityPanelTwo,
	-- [7] = KaifuActivityPanelTen,
	[8] = KaifuActivityPanelTwelve,
	[9] = KaifuActivityPanelPersonBuy,
	[10] = LevelRewardView,

	[11] = KaifuActivity7DayRedpacket,
	[12] = KaifuActivityGoldenPigCallView,
	[13] = LianXuChongZhiGao,
	[14] = LianXuChongZhiChu,
	[15] = KaifuActivityPanelFifteen,
	[16] = KfGuildFightView,

	[18] = CongZhiRank,
	[19] = XiaoFeiRank,

	[22] = OpenActTotalConsume,
	[23] = LeiJiRewardView,
	[24] = KaifuActivityPanelDanBiChongZhi,
	[25] = KaifuActivityRechargeRebate,
	[26] = TotalCharge,
	[27] = FullServerSnapView,
	[28] = DailyLoveView,
	[29] = DailyTotalConsume,
	[30] = GetRewardView,

	[31] = RushToPurchase,
	[32] = LucklyTurntable,
	[33] = CityContend,
	[34] = CombineServerChongZhiRank,
	[35] = CombineServerConsubeRank,
	[36] = BossLoot,
	[37] = CombineServerDanBiChongZhi,
	[38] = LoginjiangLiView,
	[39] = PersonFullServerSnapView,
	[40] = HeFuFullServerSnapView,

	[41] = HeFuBossView,
	[42] = HeFuTouZiView,
	[43] = HeFuJiJinView,

	[45] = SupremeMembersView,
	[46] = KaifuActivityPanelSingleDayChongZhi,
	[47] = SanShengSanShiView,
	[48] = BaojidayView,
	[49] = DegreeRewardsView,
	[50] = HuanLeLeiChong,

	[51] = KaifuActivityPanelEveryDayBuy,
	[53] = QuanMinChongBangView,
	[54] = QuanMinJinJieView,
	[55] = QuanMinGroupView,
	[56] = ExpenseNiceGift,
	[57] = KaifuActivityJuBaoPen,
	[58] = DanBiChongZhiView,
	[59] = ActivityPanelLogicRewardView,
	[60] = MakeMoonCakeView,

	[61] = OpenActDailyDanBi,
	[62] = DailyGiftView,
	[63] = LevelInvestmentView,
	[64] = MonthCardInvestmentView,
	[65] = OpenActTouZiPlan,
	[66] = FuBenTouZiView,
	[67] = BossTouZiView,	

	[69] = LianXuChongZhi,
	[70] = AutumnHappyErnieView,
	[71] = DegreeRewardsView2,
	[72] = BaojidayView2,
}

KaifuActivityView = KaifuActivityView or BaseClass(BaseView)

-- 现在开服活动跟合服活动公用这个面板
function KaifuActivityView:__init()
	self.ui_config = {
		{"uis/views/kaifuactivity/childpanel_prefab", "KaiFuAcitivityPanel_1"},

		{"uis/views/kaifuactivity/childpanel_prefab", "NodeBackground"},
		{"uis/views/kaifuactivity/childpanel_prefab", "LeftToggleGroup"},

		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[1], {1}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[2], {2}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[3], {3}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[4], {4}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[5], {5}},

		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[6], {6}},
		-- {"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[7], {7}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[8], {8}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[9], {9}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[10], {10}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[11], {11}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[12], {12}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[13], {13}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[14], {14}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[15], {15}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[16], {16}},

		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[18], {18}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[19], {19}},

		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[22], {22}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[23], {23}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[24], {24}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[25], {25}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[26], {26}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[27], {27}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[28], {28}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[29], {29}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[30], {30}},
		{"uis/views/hefuactivity/childpanel_prefab", NODE_NAME_LIST[31], {31}},
		{"uis/views/hefuactivity/childpanel_prefab", NODE_NAME_LIST[32], {32}},
		{"uis/views/hefuactivity/childpanel_prefab", NODE_NAME_LIST[33], {33}},
		{"uis/views/hefuactivity/childpanel_prefab", NODE_NAME_LIST[34], {34}},
		{"uis/views/hefuactivity/childpanel_prefab", NODE_NAME_LIST[35], {35}},
		{"uis/views/hefuactivity/childpanel_prefab", NODE_NAME_LIST[36], {36}},
		{"uis/views/hefuactivity/childpanel_prefab", NODE_NAME_LIST[37], {37}},
		{"uis/views/hefuactivity/childpanel_prefab", NODE_NAME_LIST[38], {38}},
		{"uis/views/hefuactivity/childpanel_prefab", NODE_NAME_LIST[39], {39}},
		{"uis/views/hefuactivity/childpanel_prefab", NODE_NAME_LIST[40], {40}},
		{"uis/views/hefuactivity/childpanel_prefab", NODE_NAME_LIST[41], {41}},
		{"uis/views/hefuactivity/childpanel_prefab", NODE_NAME_LIST[42], {42}},
		{"uis/views/hefuactivity/childpanel_prefab", NODE_NAME_LIST[43], {43}},

		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[45], {45}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[46], {46}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[47], {47}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[48], {48}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[49], {49}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[50], {50}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[51], {51}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[53], {53}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[54], {54}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[55], {55}},
		{"uis/views/serveractivity/expensenicegift_prefab", NODE_NAME_LIST[56], {56}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[57], {57}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[58], {58}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[59], {59}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[60], {60}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[61], {61}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[62], {62}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[63], {63}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[64], {64}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[65], {65}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[66], {66}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[67], {67}},

		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[69], {69}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[70], {70}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[71], {71}},
		{"uis/views/kaifuactivity/childpanel_prefab", NODE_NAME_LIST[72], {72}},
		{"uis/views/kaifuactivity/childpanel_prefab", "KaiFuAcitivityPanel_2"},
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp

	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.cur_index = 1
	self.cell_list = {}
	self.panel_list = {}
	self.panel_obj_list = {}
	self.kaifu_open_data_list = {}

	self.cur_type = -1
	self.last_type = -1

	self.cur_tab_list_length = 0
	-- 开服活动里面要加合服活动，拿合服活动的sub_type当作activity_type
	-- 这里规定activity_type小于100的为合服活动
	self.combine_server_max_type = 100

	-- self.hefu_script_list = {
	-- 	[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_RANK_QIANGGOU] = RushToPurchase,
	-- 	[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_ROLL] = LucklyTurntable,
	-- 	[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_GONGCHENGZHAN] = CityContend,
	-- 	[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_KILL_BOSS] = BossLoot,
	-- 	[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_CHONGZHI_RANK] = CombineServerChongZhiRank,
	-- 	[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_CONSUME_RANK] = CombineServerConsubeRank,
	-- 	[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_PERSONAL_PANIC_BUY] = PersonFullServerSnapView,
	-- 	[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_SERVER_PANIC_BUY] = HeFuFullServerSnapView,
	-- 	[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_SINGLE_CHARGE] = CombineServerDanBiChongZhi,
	-- 	[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_LOGIN_Gift] = LoginjiangLiView,
	-- 	[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BOSS] = HeFuBossView,
	-- }

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function KaifuActivityView:__delete()
	self.hefu_script_list = {}
end

function KaifuActivityView:ReleaseCallBack()
	self.cur_type = -1
	self.last_type = -1
	self.cur_index = 1
	self.cur_day = nil

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	self.right_combine_content = nil

	for k, v in pairs(self.panel_list) do
		v:DeleteMe()
	end
	self.panel_list = {}

	-- for k, v in pairs(self.combine_panel_list) do
	-- 	v:DeleteMe()
	-- end
	-- self.combine_panel_list = {}

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.model_2 then
		self.model_2:DeleteMe()
		self.model_2 = nil
	end
	if self.main_role_level_change then
		GlobalEventSystem:UnBind(self.main_role_level_change)
		self.main_role_level_change = nil
	end
	self.cell_list = {}
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.KaifuActivityView)
	end
	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	self.panel_obj_list = {}
end

function KaifuActivityView:LoadCallBack()
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["BtnRecharge"].button:AddClickListener(BindTool.Bind(self.OnClickChongzhi,self))
	self.node_list["BtnRechargePlus"].button:AddClickListener(BindTool.Bind(self.OnClickChongzhi,self))
	self.node_list["BtnJinjie"].button:AddClickListener(BindTool.Bind(self.OnClickJinjie, self))
	self.node_list["BtnRankJinJie"].button:AddClickListener(BindTool.Bind(self.OnClickJinjie, self))
	self.node_list["BtnPata"].button:AddClickListener(BindTool.Bind(self.OnClickPata, self))
	self.node_list["BtnExpChallenge"].button:AddClickListener(BindTool.Bind(self.OnClickExpChallenge, self))
	self.node_list["BtnEquipStrengthen"].button:AddClickListener(BindTool.Bind(self.OnClickStrengthen, self))
	-- 判断是否是开服活动
	-- self.node_list["TitleText"].text.text = Language.Mainui.NewServer
	-- if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.COMBINE_SERVER) then
	-- 	self.node_list["TitleText"].text.text = Language.Mainui.CombineServer
	-- end
	local title_name = ""
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.COMBINE_SERVER) then
		title_name = Act_Title_Name[ACTIVITY_TYPE.COMBINE_SERVER]
	elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.OPEN_SERVER) then
		title_name = Act_Title_Name[ACTIVITY_TYPE.OPEN_SERVER]
	else
		title_name = Act_Title_Name[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_GIFT]
	end
	local bundle, asset = ResPath.GetOpenGameActivityNoPackRes(title_name)
	if self.node_list["ImgTitle"] then
		self.node_list["ImgTitle"].image:LoadSprite(bundle, asset)
	end


	-- self.model = RoleModel.New()
	-- self.model:SetDisplay(self.node_list["DisplayLianChongChu"].ui3d_display)

	-- self.model_2 = RoleModel.New()
	-- self.model_2:SetDisplay(self.node_list["DisplayLianChongGao"].ui3d_display)

	-- 合服小面板都是保存成单个的预制体 跟原开服界面的做法不同，故区分开
	-- self.combine_panel_list = {}
	-- self.cur_type = -1
	self.last_type = -1

	local list_delegate = self.node_list["ScrollerToggleGroup"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	-- self:Flush()
	self.main_role_level_change = GlobalEventSystem:Bind(ObjectEventType.LEVEL_CHANGE, BindTool.Bind(self.MainRoleLevelChange, self))
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.KaifuActivityView, BindTool.Bind(self.GetUiCallBack, self))
	RemindManager.Instance:Bind(self.remind_change, RemindName.KaiFu)
	-- RemindManager.Instance:Bind(self.remind_change, RemindName.HappyLeichong)

end

function KaifuActivityView:MainRoleLevelChange()
	if self.node_list["ScrollerToggleGroup"] then
		self.node_list["ScrollerToggleGroup"].scroller:ReloadData(0)
	end
end

function KaifuActivityView:OnClickClose()
	self:Close()
	KaifuActivityData.Instance:ClearFinalList()
end

function KaifuActivityView:SetOrRefreshDataList()
	self.kaifu_open_data_list = KaifuActivityData.Instance:GetOpenActivityList()
end

function KaifuActivityView:GetNumberOfCells()
	return #self.kaifu_open_data_list
end

function KaifuActivityView:RefreshCell(cell, data_index)
	local list = self.kaifu_open_data_list
	if not list or not next(list) then return end

	local activity_type = list[data_index + 1] and list[data_index + 1].activity_type or list[data_index + 1].sub_type or 0
	local data = {}
	data.activity_type = activity_type

	local tab_btn = self.cell_list[cell]
	if tab_btn == nil then
		tab_btn = LeftTableButton.New(cell.gameObject)
		self.cell_list[cell] = tab_btn
	end
	tab_btn:SetToggleGroup(self.node_list["ScrollerToggleGroup"].toggle_group)

	tab_btn:SetHighLight(self.cur_type == activity_type)
	tab_btn:AddClickCallback(BindTool.Bind(self.OnClickTabButton, self, activity_type, data_index + 1))

	data.is_show = false
	data.is_show_effect = false
	data.is_show_btn_eff = false

	local reward_cfg = KaifuActivityData.Instance:GetKaifuActivityCfgByType(activity_type)
	local activity_info = KaifuActivityData.Instance:GetActivityInfo(activity_type)

	if activity_info then
		for k, v in pairs(reward_cfg) do
			if data.is_show then
				break
			end
			if not KaifuActivityData.Instance:IsGetReward(v.seq, activity_type) and
				KaifuActivityData.Instance:IsComplete(v.seq, activity_type) then
				data.is_show = true
				break
			end
		end
	end

	if KaifuActivityData.Instance:IsBossLieshouType(activity_type) then
		data.is_show = KaifuActivityData.Instance:IsShowBossRedPoint()
		data.is_show_effect = true
	end

	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QUAN_MIN_JIN_JIE then
		data.is_show = KaifuActivityData.Instance:IsShowQuanMinJinJieRedPoint()
	end

	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QUAN_MIN_UPGRADE_GROUPE then
		data.is_show = KaifuActivityData.Instance:IsShowQuanMinZongDongRedPoint()
	end

	if activity_type == ACTIVITY_TYPE.RAND_SINGLE_DAY_CHARGE then
		data.is_show = KaifuActivityData.Instance:IsShowSingleDayRedPoint()
	end

	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION then
		data.is_show = KaifuActivityData.Instance:IsShowJiZiRedPoint()
	end

	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GOLDEN_PIG then
		data.is_show = KaifuActivityData.Instance:IsShowGoldenPigRedPoint()
	end

	if activity_type == TEMP_ADD_ACT_TYPE.WELFARE_LEVEL_ACTIVITY_TYPE then 			--冲级豪礼
		data.is_show = WelfareData.Instance:GetLevelRewardRemind() > 0
	end

	if activity_type == TEMP_ADD_ACT_TYPE.SUPREME_MEMBERS then
		data.is_show = RechargeData.Instance:IsCanGetReward()
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPPER_GIFT then
		data.is_show_effect = true
		data.is_show_btn_eff = true
		data.is_show = KaifuActivityData.Instance:GetLiBaoBuyRemindRed()
	end

	if activity_type == TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO then
		data.is_show = KaifuActivityData.Instance:LianChongTeHuiGaoRedPoint()
	end

	if activity_type == TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU then
		data.is_show = KaifuActivityData.Instance:LianChongTeHuiChuRedPoint()
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HONG_BAO then
		data.is_show = ActiviteHongBaoData.Instance:GetHongBaoRemind()
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_KAIFU_INVEST then
		data.is_show = KaifuActivityData.Instance:ShowInvestRedPoint()
		data.is_show_effect = true
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CONSUME_GOLD then
		data.is_show = KaifuActivityData.Instance:IsDialyTotalConsumeRedPoint()
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CONSUME then
		data.is_show = KaifuActivityData.Instance:IsTotalConsumeRedPoint()
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHARGE_REPALMENT then
		data.is_show = KaifuActivityData.Instance:GetLeiJiChargeRewardRedPoint()
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CHARGE then
		data.is_show = KaifuActivityData.Instance:IsTotalChargeRedPoint()
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_DAY_CHONGZHI_FANLI then
		data.is_show = KaifuActivityData.Instance:IsRechargeRebateRedPoint()
	end

	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GUILD_FIGHT then
		data.is_show = KaifuActivityData.Instance:IsShowKFGuildFightRedPoint()
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE then
		data.is_show = KaifuActivityData.Instance:IsShowLeiJiChongZhiRedPoint()
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_JUBAOPEN then
		data.is_show = KaifuActivityData.Instance:IsShowJubaoPenRedPoint()
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_RETURN then
		data.is_show = KaifuActivityData.Instance:IsShowUpGradeRedPoint()
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPLEVEL_RETURN_2 then
		data.is_show = KaifuActivityData.Instance:IsShowUpGrade2RedPoint()
	end

	--合服--登录奖励
	if activity_type == COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_LOGIN_Gift then
		data.is_show = HefuActivityData.Instance:GetShowRedPointBySubType(activity_type)
	end

	if activity_type == COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_RANK_QIANGGOU then
		data.is_show = HefuActivityData.Instance:IsShowOnceADayRedPoint(RemindName.QiangGou)
	end

	if activity_type == COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_CHONGZHI_RANK then
		data.is_show = HefuActivityData.Instance:IsShowOnceADayRedPoint(RemindName.ChongZhiRank)
	end

	if activity_type == COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_ROLL then
		data.is_show = HefuActivityData.Instance:GetLucklyTurnRedPoint() > 0
	end

	if activity_type == COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_KILL_BOSS then
		data.is_show = HefuActivityData.Instance:IsShowBossLooyRedPoint(activity_type)
	end
	
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_GIFT then
		data.is_show = ExpenseGiftData.Instance:GetExpenseGiftRemind() > 0
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPY_RECHARGE then
		data.is_show = KaifuActivityData.Instance:IsHuanLeLeichongRemind()
	end

	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EVERYDAY_NICE_GIFT then
		data.is_show = KaifuActivityData.Instance:DailyGiftRedPoint() > 0
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBI_CHONGZHI then
		data.is_show = KaifuActivityData.Instance:IsShowDanBiChongZhiRedPoint()
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CHONGZHI_RANK then
		data.is_show = KaifuActivityData.Instance:IsShowChongZhiRankRedPoint()
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_XIAOFEI_RANK then
		data.is_show = KaifuActivityData.Instance:IsShowXiaoFeiRankRedPoint()
	end

	if activity_type == TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_MONTHCARDINVESTMENT then 	-- 周卡投资
		data.is_show = InvestData.Instance:GetMonthInvestRemind() > 0
	end

	if activity_type == TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_LEVEL_INVESTMENT then 		-- 等级投资
		data.is_show = InvestData.Instance:GetNormalInvestRemind() > 0
	end

	if activity_type == TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_GROWUP_INVESTMENT then 		-- 成长基金
		data.is_show = KaifuActivityData.Instance:IsTouZiPlanRedPoint()
	end

	if activity_type == TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_FuBenTouZi then 		-- 副本投资
		data.is_show = KaifuActivityData.Instance:IsShowFuBenTouZiRedPoint()
	end

	if activity_type == TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_BossTouZi then 		-- boss投资
		data.is_show = KaifuActivityData.Instance:IsShowBossTouZiRedPoint()
	end		

	if activity_type == COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_JIJIN then 		--合服基金
		data.is_show = HefuActivityData.Instance:IsShowHeFuJiJinRedPoint()
	end
	
	if activity_type == COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_TOUZI then 		--合服投资
		data.is_show = HefuActivityData.Instance:IsShowHeFuTouZiRedPoint()
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FULL_SERVER_SNAP then 		-- 全服抢购
		data.is_show = KaifuActivityData.Instance:GetQuanFuBuyRemindRed()
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUNDER_TIMES_SHOP then 		-- 个人抢购
		data.is_show = KaifuActivityData.Instance:GetPersonBuyRemindRed()
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EVERY_DAY_SNAP then 		-- 每日抢购
		data.is_show = KaifuActivityData.Instance:GetEveryDayBuyRemindRed()
	end

	if activity_type == ACTIVITY_TYPE.RAND_DAY_DANBI_CHONGZHI then							-- 每日单笔
		data.is_show = KaifuActivityData.Instance:IsDailyDanBiRedPoint()
	end

	-- 默认放在第一位，做不到红点点击消失需求
	-- if activity_type == ACTIVITY_TYPE.RAND_DAILY_LOVE then 										-- 每日一爱
	-- 	data.is_show = KaifuActivityData.Instance:DailyLoveRedPoint()
	-- end

	data.name = list[data_index + 1].name
	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_KAIFU_INVEST then
		if KaifuActivityData.Instance:IsKaifuActivity(activity_type) then
			data.name = KaifuActivityData.Instance.special_tab_name[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_KAIFU_INVEST]
		end
	end
	tab_btn:SetData(data)
end

function KaifuActivityView:OnClickTabButton(activity_type, index)
	if self.cur_type == activity_type then
		return
	end

	self.is_auto_jump = false

	self.last_type = self.cur_type
	self.cur_type = activity_type
	self.cur_index = index
	HefuActivityData.Instance:SetLucklyTurnClick(false)
	KaifuActivityData.Instance:SetSelect(self.cur_index)
	self:ChangeToIndex(KaifuActivityData.Instance:GetActivityTypeToIndex(self.cur_type))
	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU then 
		-- if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU) then
		-- 	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU, RA_CONTINUE_CHONGZHI_OPERA_TYPE.RA_CONTINUE_CHONGZHI_OPERA_TYPE_QUERY_INFO)
		-- end
		KaifuActivityData.Instance:LianChonTeHuiChuRemindSign()
	end
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_GIFT then 
		if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_GIFT) then
			KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_GIFT, RA_CONSUM_GIFT_OPERA_TYPE.RA_CONSUM_GIFT_OPERA_TYPE_INFO)
		end
		-- ExpenseGiftData.Instance:ExpenseGiftRemindSign()
		RemindManager.Instance:SetRemindToday(RemindName.ExpenseGift)
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_JUBAOPEN then 
		if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_JUBAOPEN) then
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_JUBAOPEN, RA_COLLECT_TREASURE_OPERA_TYPE.RA_COLLECT_TREASURE_OPERA_TYPE_INFO)
		end
		KaifuActivityData.Instance:JuBaoPenRemindSign()
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CHONGZHI_RANK then
		KaifuActivityData.Instance:ChongZhiRankSign()
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_XIAOFEI_RANK then
		KaifuActivityData.Instance:XiaoFeiRankSign()
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBI_CHONGZHI then
		KaifuActivityData.Instance:DanBiChongZhiSign()
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_DAY_CHONGZHI_FANLI then 
		if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_DAY_CHONGZHI_FANLI) then
			KaifuActivityCtrl.Instance:SendRandActivityOperaReq(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_DAY_CHONGZHI_FANLI, RA_SINGLE_CHONGZHI_OPERA_TYPE.RA_SINGLE_CHONGZHI_OPERA_TYPE_INFO, 0)
		end
		KaifuActivityData.Instance:RechargeRebateSign()
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHARGE_REPALMENT then 
		if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHARGE_REPALMENT) then
			KaifuActivityCtrl.Instance:SendRandActivityOperaReq(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHARGE_REPALMENT, RA_CONTINUE_CHONGZHI_OPERA_TYPE.RA_CONTINUE_CHONGZHI_OPERA_TYPE_QUERY_INFO)
		end
		
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO then 
		KaifuActivityData.Instance:LianChonTeHuiChuRemindSignGao()
		if self.panel_list and self.panel_list[13] then
			self.panel_list[13]:InitListView()
		end
		RemindManager.Instance:Fire(RemindName.KaiFu)
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE then 
		if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE) then
			KaifuActivityCtrl.Instance:SendRandActivityOperaReq(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
		end
		KaifuActivityData.Instance:LeiJiChongZhiSign()
	end

	if activity_type == TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_GROWUP_INVESTMENT then
		KaifuActivityData.Instance:ChengZhangJiJingRemind()
		--MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.ChengZhangJiJing, false)
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CONSUME then 
		if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CONSUME) then
			KaifuActivityCtrl.Instance:SendRandActivityOperaReq(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CONSUME, RA_SINGLE_CHONGZHI_OPERA_TYPE.RA_SINGLE_CHONGZHI_OPERA_TYPE_INFO, 0)
		end
		KaifuActivityData.Instance:TotalConsumeSign()
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FULL_SERVER_SNAP then
		if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FULL_SERVER_SNAP) then
			 KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FULL_SERVER_SNAP, RA_CHARGE_REPAYMENT_OPERA_TYPE.RA_SERVER_PANIC_BUY_OPERA_TYPE_QUERY_INFO)
		end
		RemindManager.Instance:SetRemindToday(RemindName.QuanFuBuy)
	end
	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIRST_CHARGE_TUAN then
		if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIRST_CHARGE_TUAN) then
			 	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIRST_CHARGE_TUAN, RA_CHARGE_REPAYMENT_OPERA_TYPE.RA_SERVER_PANIC_BUY_OPERA_TYPE_QUERY_INFO)
		end
		KaifuActivityData.Instance:ShouChongTuanGouRemind()
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUNDER_TIMES_SHOP then
		if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUNDER_TIMES_SHOP) then
			 KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUNDER_TIMES_SHOP, RA_CHARGE_REPAYMENT_OPERA_TYPE.RA_SERVER_PANIC_BUY_OPERA_TYPE_QUERY_INFO)
		end
		RemindManager.Instance:SetRemindToday(RemindName.PersonBuy)
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EVERY_DAY_SNAP then
		if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EVERY_DAY_SNAP) then
			 KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EVERY_DAY_SNAP, RA_CHARGE_REPAYMENT_OPERA_TYPE.RA_SERVER_PANIC_BUY_OPERA_TYPE_QUERY_INFO)
		end
		RemindManager.Instance:SetRemindToday(RemindName.EveryDayBuy)
	end


	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CONSUME_GOLD then 
		if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CONSUME_GOLD) then
			KaifuActivityCtrl.Instance:SendRandActivityOperaReq(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CONSUME_GOLD, RA_SINGLE_CHONGZHI_OPERA_TYPE.RA_SINGLE_CHONGZHI_OPERA_TYPE_INFO, 0)
		end
		KaifuActivityData.Instance:DailyConsumeSign()
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPY_RECHARGE then 
		if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPY_RECHARGE) then
			KaifuActivityCtrl.Instance:SendRandActivityOperaReq(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPY_RECHARGE, RA_SINGLE_CHONGZHI_OPERA_TYPE.RA_SINGLE_CHONGZHI_OPERA_TYPE_INFO, 0)
		end
		KaifuActivityData.Instance:HuanLeLeichongSign()
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPPER_GIFT then 
		if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPPER_GIFT) then
			KaifuActivityCtrl.Instance:SendRandActivityOperaReq(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPPER_GIFT, RA_SINGLE_CHONGZHI_OPERA_TYPE.RA_SINGLE_CHONGZHI_OPERA_TYPE_INFO, 0)
		end
		RemindManager.Instance:SetRemindToday(RemindName.LiBaoBuy)
	end

	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GOLDEN_PIG then 
		if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GOLDEN_PIG) then
			KaifuActivityCtrl.Instance:SendGoldenPigCallInfoReq(GOLDEN_PIG_OPERATE_TYPE.GOLDEN_PIG_OPERATE_TYPE_REQ_INFO)
		end
		KaifuActivityData.Instance:LongShenZhaoHuanSign()
	end

	if activity_type == ACTIVITY_TYPE.RAND_SINGLE_DAY_CHARGE then 
		if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_SINGLE_DAY_CHARGE) then
			KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_SINGLE_DAY_CHARGE, RA_SINGLE_CHONGZHI_OPERA_TYPE.RA_SINGLE_CHONGZHI_OPERA_TYPE_INFO, 0)
		end
		KaifuActivityData.Instance:DanRiLeiChongSign()
	end

	if activity_type == ACTIVITY_TYPE.RAND_DAY_DANBI_CHONGZHI then 
		if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_DAY_DANBI_CHONGZHI) then
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_DAY_DANBI_CHONGZHI, RA_DANBI_CHONGZHI_OPERA_TYPE.RA_DANBI_CHONGZHI_OPERA_TYPE_QUERY_INFO)
		end
	end

	-- self:OpenPanel()
	--self:CloseChildPanel()
	RemindManager.Instance:Fire(RemindName.KaiFu)
	-- self:Flush()
end

function KaifuActivityView:OpenPanel()
	-- if self.cur_type ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FULL_SERVER_SNAP then
	-- 	self.panel_list[27]:CloseCallBack()
	-- end
	if KaifuActivityData.Instance:IsZhengBaType(self.cur_type) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.cur_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH_BATTE_INFO)
	elseif KaifuActivityData.Instance:IsBossLieshouType(self.cur_type) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.cur_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_BOSS_INFO)
	elseif self.cur_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GOLDEN_PIG then
	-- 金猪召唤
		KaifuActivityCtrl.Instance:SendGoldenPigCallInfoReq(GOLDEN_PIG_OPERATE_TYPE.GOLDEN_PIG_OPERATE_TYPE_REQ_INFO)
	elseif self.cur_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HONG_BAO then
		ActiviteHongBaoData.Instance:TurnIsRead()
	-- elseif self.cur_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_KAIFU_INVEST then
	-- 	self.panel_list[15]:OpenCallBack()
	-- elseif self.cur_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CHONGZHI_RANK then
	-- 	self.panel_list[18]:OpenCallBack()
	-- elseif self.cur_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_XIAOFEI_RANK then
	-- 	self.panel_list[19]:OpenCallBack()
	-- elseif self.cur_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_RANK then
	-- 	self.panel_list[20]:OpenCallBack()
	-- elseif self.cur_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_PASSIVE_RANK then
	-- 	self.panel_list[21]:OpenCallBack()
	-- elseif self.cur_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CONSUME then
	-- 	self.panel_list[22]:OpenCallBack()
	-- elseif self.cur_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHARGE_REPALMENT then
	-- 	self.panel_list[23]:OpenCallBack()
	-- elseif self.cur_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBI_CHONGZHI then
	-- 	self.panel_list[24]:OpenCallBack()
	-- elseif self.cur_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_DAY_CHONGZHI_FANLI then
	-- 	self.panel_list[25]:OpenCallBack()
	-- elseif self.cur_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CHARGE then
	-- 	self.panel_list[26]:OpenCallBack()
	-- elseif self.cur_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FULL_SERVER_SNAP then
	-- 	self.panel_list[27]:OpenCallBack()
	elseif self.cur_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU then
		KaifuActivityData.Instance:SetLianchongRedPointState(false)
		self.node_list["ScrollerToggleGroup"].scroller:RefreshAndReloadActiveCellViews(true)
		RemindManager.Instance:Fire(RemindName.LianChongTeHuiChu)
	-- elseif self.cur_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GETREWARD then
	-- 	self.panel_list[30]:OpenCallBack()
	elseif self.cur_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO then
		KaifuActivityData.Instance:SetLianchongRedPointState2(false)
		self.node_list["ScrollerToggleGroup"].scroller:RefreshAndReloadActiveCellViews(true)
		RemindManager.Instance:Fire(RemindName.LianChongTeHuiGao)
	-- elseif self.cur_type > 0 and self.cur_type < self.combine_server_max_type then
	-- 	self:OpenCombineChildPanel()
	else
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.cur_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	end
	-- self.node_list["NodeRightCont"]:SetActive(not(self.cur_type > 0 and self.cur_type < self.combine_server_max_type))
	-- self.node_list["NodeRightCombineContent"]:SetActive(self.cur_type > 0 and self.cur_type < self.combine_server_max_type)
end


function KaifuActivityView:ShowIndexCallBack(index, index_nodes)
	local default_open_act_type = KaifuActivityData.Instance:GetDefaultOpenActType()
	if -1 ~= default_open_act_type then
		self.cur_type = default_open_act_type < 100000 and default_open_act_type or (default_open_act_type - 100000)
		self:ChangeToIndex(KaifuActivityData.Instance:GetActivityTypeToIndex(self.cur_type))
		-- self.is_auto_jump = true
		-- self.cur_index = KaifuActivityData.Instance:GetActivityTypeToIndex(self.cur_type)
		KaifuActivityData.Instance:ClearDefaultOpenActType()
		-- self:Flush()
	else
		self.cur_type = KaifuActivityData.Instance:GetActivityTypeByIndex(index)
	end
	
	if self.cur_type == TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_GROWUP_INVESTMENT then
		--MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.ChengZhangJiJing, false)
	end

	if index_nodes then
		local prefab_name = NODE_NAME_LIST[index]
		self.panel_obj_list[index] = index_nodes[prefab_name]
		self.panel_list[index] = RENDER_NAME_LIST[index].New(self.panel_obj_list[index])
	end

	if self.panel_list[index] and self.panel_list[index].OpenCallBack then
		self.panel_list[index]:OpenCallBack()
	end

	local list = KaifuActivityData.Instance:GetOpenActivityList()
	for k,v in pairs(list) do
		if v.activity_type == self.cur_type then
			self.cur_index = k
		end
	end
	self:Flush()
end

function KaifuActivityView:OpenCallBack()
	RemindManager.Instance:SetImmdiateRemind(RemindName.JingCai_Act_Delay)
	self.is_auto_jump = true
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.COMBINE_SERVER) then
		HefuActivityCtrl.Instance:SendCSAQueryActivityInfo()
		HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_INVALID)
		HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BOSS, CSA_BOSS_OPERA_TYPE.CSA_BOSS_OPERA_TYPE_INFO_REQ)
		HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BOSS, CSA_BOSS_OPERA_TYPE.CSA_BOSS_OPERA_TYPE_RANK_REQ)
		HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BOSS, CSA_BOSS_OPERA_TYPE.CSA_BOSS_OPERA_TYPE_ROLE_INFO_REQ)
		HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_JIJIN, CSA_FOUNDATION_OPERA.CSA_FOUNDATION_INFO_REQ)
	end

	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_GIFT) then
		KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_GIFT, RA_CONSUM_GIFT_OPERA_TYPE.RA_CONSUM_GIFT_OPERA_TYPE_INFO)
	end
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO) then
		KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO, RA_CONTINUE_CHONGZHI_OPERA_TYPE.RA_CONTINUE_CHONGZHI_OPERA_TYPE_QUERY_INFO)
	end
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU) then
		KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU, RA_CONTINUE_CHONGZHI_OPERA_TYPE.RA_CONTINUE_CHONGZHI_OPERA_TYPE_QUERY_INFO)
	end
	RemindManager.Instance:Fire(RemindName.QiangGou)
	RemindManager.Instance:Fire(RemindName.ChongZhiRank)
	RemindManager.Instance:Fire(RemindName.LiBaoBuy)
	RemindManager.Instance:Fire(RemindName.PersonBuy)
	RemindManager.Instance:Fire(RemindName.QuanFuBuy)
	RemindManager.Instance:Fire(RemindName.EveryDayBuy)
end

function KaifuActivityView:CloseCallBack()
	RemindManager.Instance:Fire(RemindName.KaiFu)
	self.last_type = self.cur_type
	-- RemindManager.Instance:Fire(RemindName.KaiFu)
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.count_down_chu ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down_chu)
		self.count_down_chu = nil
	end
	if self.count_down_gao ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down_gao)
		self.count_down_gao = nil
	end
	self.cur_day = nil
	self.cur_index = 1
	

	for k,v in pairs(self.panel_list) do
		if v.CloseCallBack then
			v:CloseCallBack()
		end
	end

	self.cur_tab_list_length = 0
	
end

function KaifuActivityView:OnClickChongzhi()
	-- VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	-- ViewManager.Instance:Open(ViewName.VipView)
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
	-- self:Close()
end

function KaifuActivityView:OnClickJinjie()
	if KaifuActivityData.Instance:IsAdvanceType(self.cur_type) then
		local cond, jinjie_type = KaifuActivityData.Instance:GetCondByType(self.cur_type)
		if jinjie_type then
			ViewManager.Instance:Open(OpenNameList[jinjie_type], Table_Index[jinjie_type])
			self:Close()
		end
	end
end
-----打开小助手升级面板
function KaifuActivityView:OnClickShengJi()
	if KaifuActivityData.Instance:IsChongJiType(self.cur_type) then
		local cond, jinjie_type = KaifuActivityData.Instance:GetCondByType(self.cur_type)
		ViewManager.Instance:Open(OpenNameList[jinjie_type], Table_Index[jinjie_type])
		self:Close()
	end
end
-----打开勇者之塔副本面板
function KaifuActivityView:OnClickPata()
	if KaifuActivityData.Instance:IsPaTaType(self.cur_type) then
		local cond, jinjie_type = KaifuActivityData.Instance:GetCondByType(self.cur_type)
		ViewManager.Instance:Open(OpenNameList[jinjie_type], Table_Index[jinjie_type])
		self:Close()
	end
end
-----打开经验副本面板
function KaifuActivityView:OnClickExpChallenge()
	if KaifuActivityData.Instance:IsExpChallengeType(self.cur_type) then
		local cond, jinjie_type = KaifuActivityData.Instance:GetCondByType(self.cur_type)
		ViewManager.Instance:Open(OpenNameList[jinjie_type], Table_Index[jinjie_type])
		self:Close()
	end
end

function KaifuActivityView:OnClickStrengthen()
	local cond, jinjie_type = KaifuActivityData.Instance:GetCondByType(self.cur_type)
	ViewManager.Instance:Open(OpenNameList[jinjie_type], Table_Index[jinjie_type])
	self:Close()
end

function KaifuActivityView:RemindChangeCallBack(remind_name, num)
	self:Flush()
end

function KaifuActivityView:FlushDayChongZhi()
	if self.panel_list[18] then
		self.panel_list[18]:FlushChongZhi()
	end
end

function KaifuActivityView:FlushGuildFight()
	if self.panel_list[16] then
		self.panel_list[16]:Flush()
	end
end

function KaifuActivityView:FlushLeiJiChongZhi() 
	if self.panel_list[23] then
		self.panel_list[23]:Flush()
	end
end

function KaifuActivityView:FlushDayXiaoFei()
	if nil ~= self.panel_list[19] then
		self.panel_list[19]:FlushXiaoFei()
	end
end

function KaifuActivityView:FlushTotalConsume()
	if self.panel_list[22] then
		self.panel_list[22]:Flush()
	end
end

function KaifuActivityView:FlushDanBiChongZhi()
	if self.panel_list[24] then
		self.panel_list[24]:Flush()
	end
end

function KaifuActivityView:FlushRechargeRebate()
	if self.panel_list[25] then
		self.panel_list[25]:Flush()
	end
end

function KaifuActivityView:FlushTotalCharge()
	if self.panel_list[26] then
		self.panel_list[26]:Flush()
	end
end

function KaifuActivityView:FlushDialyTotalConsume()
	if self.panel_list[29] then
		self.panel_list[29]:Flush()
	end
end

function KaifuActivityView:FlushHeFuTouZiView()
	if self.panel_list[42] then
		self.panel_list[42]:Flush()
	end
end

function KaifuActivityView:FlushSanShengSanShi()
	if self.panel_list[47] then
		self.panel_list[47]:Flush()
	end
end

function KaifuActivityView:FlushUpGradeReturn()
	if self.panel_list[49] then
		self.panel_list[49]:Flush()
	end
end

function KaifuActivityView:FlushHappyRecharge()
	if self.panel_list[50] then
		self.panel_list[50]:Flush()
	end
end


function KaifuActivityView:FlushQuanMinChongBang()
	if self.panel_list[53] then
		self.panel_list[53]:Flush()
	end
end

function KaifuActivityView:FlushQuanMinJinjie()
	if self.panel_list[54] then
		self.panel_list[54]:Flush()
	end
end

function KaifuActivityView:FlushQuanMinGroup()
	if self.panel_list[55] then
		self.panel_list[55]:Flush()
	end
end

function KaifuActivityView:FlushJuBaoPen()
	if self.panel_list[57] then
		self.panel_list[57]:Flush()
	end
end

function KaifuActivityView:FlushHappyDanBiChongZhi()
	if self.panel_list[58] then
		self.panel_list[58]:Flush()
	end
end
function KaifuActivityView:FlushFengKuangYaoJiang()
	if self.panel_list[70] then
		self.panel_list[70]:Flush()
	end
end
function KaifuActivityView:FlushLoginReward()
	if self.panel_list[59] then
		self.panel_list[59]:Flush()
	end
end

function KaifuActivityView:FlushDailyDanBi()
	if self.panel_list[61] then
		self.panel_list[61]:Flush()
	end
end

function KaifuActivityView:FlushDailyGiftView()
	if self.panel_list[62] then
		self.panel_list[62]:Flush()
	end
end

-- 刷新等级投资
function KaifuActivityView:FlushLevelInvestmentView()
	if self.panel_list[63] then
		self.panel_list[63]:Flush()
	end
end

-- 刷新月卡投资
function KaifuActivityView:FlushMonthCardInvestmentView()
	if self.panel_list[64] then
		self.panel_list[64]:Flush()
	end
end

-- 刷新成长基金
function KaifuActivityView:FlushTouZiPlan()
	if self.panel_list[65] then
		self.panel_list[65]:Flush()
	end
end

-- 刷新fubentouzi
function KaifuActivityView:FlushFuBenTouZi()
	if self.panel_list[66] then
		self.panel_list[66]:Flush()
	end
end

-- 刷新bosstouzi
function KaifuActivityView:FlushBossTouZi()
	if self.panel_list[67] then
		self.panel_list[67]:Flush()
	end
end

--连续充值
function KaifuActivityView:FlushLianXuChongZhi()
	if self.panel_list[69] then
		self.panel_list[69]:Flush()
	end
end

-- 进阶返还2
function KaifuActivityView:FlushUpGrade2Return()
	if self.panel_list[71] then
		self.panel_list[71]:Flush()
	end
end

function KaifuActivityView:OnFlush(param_t)
	self.cur_tab_list_length = #self.kaifu_open_data_list or 0
	self:SetOrRefreshDataList()
	local list = self.kaifu_open_data_list
	if list and next(list) then
		self:FlushLeftTabListView(list)
		self:FlushRightPanel(list, param_t)
	end
	-- self.panel_list[11]:FlushView()

	-- if self.cur_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_XIAOFEI_RANK then
	-- 	self.panel_list[19]:OpenCallBack()
	-- end

	-- 自动跳到对应标签下
	if self.is_auto_jump and #self.cell_list > 0 then
		self.is_auto_jump = false
		self.node_list["ScrollerToggleGroup"].scroller:JumpToDataIndex(self.cur_index - 1)
	end
end

function KaifuActivityView:FlushLeftTabListView(list)
	if list == nil or next(list) == nil then return end

	if self.node_list["ScrollerToggleGroup"].scroller.isActiveAndEnabled then
		if self.cur_day ~= TimeCtrl.Instance:GetCurOpenServerDay() or self.cur_tab_list_length ~= #list then
			if not list[self.cur_index] or (self.cur_type ~= list[self.cur_index].activity_type) then
				self.cur_index = 1
				--self.cur_type = -1
			end
			self.cur_tab_list_length = #list
			self.node_list["ScrollerToggleGroup"].scroller:ReloadData(0)
		else
			self.node_list["ScrollerToggleGroup"].scroller:RefreshAndReloadActiveCellViews(true)
		end
	end

	self.cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
end

function KaifuActivityView:ExpenseViewStartRoll()
	if self.panel_list[56] then
		self.panel_list[56]:StartRoll()
	end
end

function KaifuActivityView:ExpenseViewStartTenRoll()
	if self.panel_list[56] then
		self.panel_list[56]:StartTenRoll()
	end
end

function KaifuActivityView:FlushRightPanel(list, param_t)
	local default_open_act_type = KaifuActivityData.Instance:GetDefaultOpenActType()
	if -1 ~= default_open_act_type then
		self.cur_type = default_open_act_type < 100000 and default_open_act_type or (default_open_act_type - 100000)
	else
		self.cur_type = self.cur_type or list[self.cur_index].activity_type
	end

	local cond, jinjie_type = KaifuActivityData.Instance:GetCondByType(self.cur_type)
	if cond then
		if KaifuActivityData.Instance:IsAdvanceType(self.cur_type) then
			if jinjie_type then
				if not KaifuActivityData.Instance:IsAdvanceRankType(self.cur_type) then
					local str = string.format(Language.OpenServer.JinjieTips, Language.Common.Jinjie_Type[jinjie_type], cond)
					self.node_list["TxtCurDayName"].text.text = str
				else
					local rank_info = KaifuActivityData.Instance:GetOpenServerRankInfo(self.cur_type) or {}
					local rank = rank_info.myself_rank or -1
					local str = (rank + 1 >= 1 and rank + 1 < 100) and
					Language.Common.Jinjie_Type[jinjie_type]..string.format(Language.Rank.OnRankNum, rank + 1)or Language.Rank.NoInRank
					self.node_list["TxtRankName"].text.text = str
				end
			end
		end
		if KaifuActivityData.Instance:IsChongzhiType(self.cur_type) then
			local cond = CommonDataManager.ConverMoney(cond)
			if self.cur_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE then
				self.node_list["TxtLeiJiDiamonds"].text.text = cond
			else
				self.node_list["TxtCurDiamonds"].text.text = "<color=#fde45c>" ..cond .. "</color>"
			end
		end
		if KaifuActivityData.Instance:IsNomalType(self.cur_type) then
			-- local level = GameVoManager.Instance:GetMainRoleVo().level
			-- local level_befor = math.floor(level % 100) ~= 0 and math.floor(level % 100) or 100
			-- local level_behind = math.floor(level % 100) ~= 0 and math.floor(level / 100) or math.floor(level / 100) - 1
			-- local level_zhuan = string.format(Language.Common.Zhuan_Level, level_befor, level_behind)
			local pata_tips_str = string.format(Language.OpenServer.PaTaTips, Language.Common.Jinjie_Type[jinjie_type], cond)
			local exp_challenge_str = string.format(Language.OpenServer.ExpChallengeTips, Language.Common.Jinjie_Type[jinjie_type], cond)
			self.node_list["TxtExpChallenge"] = exp_challenge_str
			self.node_list["TxtPatatips"].text.text = pata_tips_str
		end
		if KaifuActivityData.Instance:IsStrengthenType(self.cur_type) then
			local str = string.format(Language.OpenServer.StrengthTips,Language.Common.Jinjie_Type[jinjie_type],cond)
			self.node_list["TxtEquipName"].text.text = str
		end
	end

	-- 先关闭上一个面板（目前只适用合服界面）
	-- local last_panel = self.combine_panel_list[self.last_type]

	-- if last_panel then
	-- 	last_panel:SetActive(false)
	-- end

	-- for k, v in pairs(self.panel_obj_list) do
	-- 	v:SetActive(false)
	-- end

	-- local cur_panel = nil

	-- if self.cur_type > self.combine_server_max_type then
	-- 	cur_panel = self.panel_list[panel_index]
	-- else
	-- 	cur_panel = self.combine_panel_list[self.cur_type]
	-- end

	-- if cur_panel then
	-- 	cur_panel:SetActive(true)
	-- 	if cur_panel.Flush then
	-- 		for k,v in pairs(param_t) do
	-- 			if k == "luckly" then
	-- 				cur_panel:Flush(k)
	-- 				return
	-- 			else
	-- 				cur_panel:Flush(self.cur_type)
	-- 			end
	-- 		end
	-- 	end

	-- 	if cur_panel.FlushView then
	-- 		cur_panel:FlushView()
	-- 	end
	-- end

	local panel_index = self:ShowWhichPanelByType(self.cur_type) or 0
	if self.panel_list[panel_index] then
		self.panel_list[panel_index]:Flush(self.cur_type)
		if self.panel_list[panel_index].FlushView then
			self.panel_list[panel_index]:FlushView()
		end
	end

	local chongzhi_time_table = os.date('*t',TimeCtrl.Instance:GetServerTime())
	local chongzhi_cur_time = chongzhi_time_table.hour * 3600 + chongzhi_time_table.min * 60 + chongzhi_time_table.sec
	local chongzhi_reset_time_s = 24 * 3600 - chongzhi_cur_time
	self:SetRestTime(chongzhi_reset_time_s)

	self.node_list["NodeChongzhi"]:SetActive(KaifuActivityData.Instance:IsChongzhiType(self.cur_type)
											and self.cur_type ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE
											and self.cur_type ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIRST_CHARGE_TUAN
											and self.cur_type ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_SINGLE_DAY_CHARGE
											)
	self.node_list["NodeJinJie"]:SetActive(KaifuActivityData.Instance:IsAdvanceType(self.cur_type) and not KaifuActivityData.Instance:IsAdvanceRankType(self.cur_type))
	self.node_list["NodePaTa"]:SetActive(KaifuActivityData.Instance:IsPaTaType(self.cur_type))
	self.node_list["NodeExpChallenge"]:SetActive(KaifuActivityData.Instance:IsExpChallengeType(self.cur_type))
	self.node_list["NodeEquipStrengthen"]:SetActive(KaifuActivityData.Instance:IsStrengthenType(self.cur_type))
	self.node_list["NodeRankJinjie"]:SetActive(KaifuActivityData.Instance:IsAdvanceRankType(self.cur_type))

	local is_show_top_bg = true
	local not_show_top_bg_act = {
		[ACTIVITY_TYPE.RAND_DAILY_LOVE] = 1
	}

	is_show_top_bg = not KaifuActivityData.Instance:IsZhengBaType(self.cur_type) and nil == not_show_top_bg_act[self.cur_type]
	self.node_list["NodeBackground"]:SetActive(is_show_top_bg)
	self.node_list["NodeLeiJiChongzhi"]:SetActive(self.cur_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE)

	local is_show_normal_bg = self.cur_type ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUNDER_TIMES_SHOP and self.cur_type ~= ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION
	 and self.cur_type ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BOSS_LIESHOU

	local is_show_jizi_bg = self.cur_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION and self.cur_type ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BOSS_LIESHOU
	local is_show_no_bg = self.cur_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BOSS_LIESHOU or KaifuActivityData.Instance:IsTempAddType(self.cur_type)

	self.node_list["NodePersonalBuy"]:SetActive(not is_show_normal_bg and not is_show_jizi_bg and not is_show_no_bg)
	--self.node_list["NodeJiZiBg"]:SetActive(is_show_jizi_bg and not is_show_no_bg)
end

function KaifuActivityView:GetTeHuiItemGao()
	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = KaifuActivityData.Instance:ChongZhiTeHuiGao()

	if nil == cfg then
		return
	end

	for k, v in pairs(cfg) do
		if open_server_day <= v.open_server_day then
			return v.show_item, v.model_name, v.power
		end
	end
end

function KaifuActivityView:GetTeHuiItemChu()
	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = KaifuActivityData.Instance:ChongZhiTeHuiChu()
	if nil == cfg then
		return
	end

	for k, v in pairs(cfg) do
		if open_server_day <= v.open_server_day then
			return v.show_item, v.model_name, v.power
		end
	end
end

function KaifuActivityView:SetRestTime(diff_time)
	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end

			local left_hour = math.floor(left_time / 3600)
			local left_min = math.floor((left_time - left_hour * 3600) / 60)
			local left_sec = math.floor(left_time - left_hour * 3600 - left_min * 60)
			--要设置的时间字符串
			local hour_str = ""
			local min_str = ""
			local sec_str = ""
			if left_hour < 10 then
				hour_str = 0 .. left_hour
			else
				hour_str = left_hour
			end
			if left_min < 10 then
				min_str = 0 .. left_min
			else
				min_str = left_min
			end
			if left_sec < 10 then
				sec_str = 0 .. left_sec
			else
				sec_str = left_sec
			end

			local time_str = TimeUtil.FormatSecond(left_time, 10)
			--self.node_list["TxtJiZiTime"].text.text = time_str
			--self.node_list["TxtNormalTime"].text.text = time_str
			--self.node_list["TxtLastOneDay"].text.text = time_str
			self.node_list["TxtPerSonalOneDay"].text.text = time_str
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end


function KaifuActivityView:FlushJinJieView()
	if not self:IsOpen() then return end
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.cur_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
end

function KaifuActivityView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end

function KaifuActivityView:OpenCombineChildPanel()
	if self.cur_type > self.combine_server_max_type then
		return
	end
	local cur_type = self.cur_type
	local panel = self.combine_panel_list[cur_type]
	if nil == panel then
		local async_loader = AllocAsyncLoader(self, "panel_loader_" .. cur_type)
		async_loader:Load(
			"uis/views/hefuactivity/childpanel_prefab",
			"hefu_panel_" .. cur_type,
			function(obj)
				if IsNil(obj) then
					return
				end

				obj.transform:SetParent(self.node_list["NodeRightCombineContent"].transform, false)
				obj = U3DObject(obj)
				if nil == self.hefu_script_list[cur_type] then
					print_error("没有对应的脚本文件！！！！, 活动号：", cur_type)
					return
				end
				panel = self.hefu_script_list[cur_type].New(obj)
				self.combine_panel_list[cur_type] = panel
				panel:SetActive(true)
				if panel.OpenCallBack then
					panel:OpenCallBack()
				end
			end)
	else
		panel:SetActive(true)

		if panel.OpenCallBack then
			panel:OpenCallBack()
		end
	end
end

function KaifuActivityView:CloseChildPanel()
	if self.cur_type == self.last_type then
		return
	end

	local panel = self.combine_panel_list[self.last_type]

	if nil == panel then
		return
	end

	if panel.CloseCallBack then
		panel:CloseCallBack()
	end
end

function KaifuActivityView:ShowWhichPanelByType(activity_type)
	if activity_type == nil then return nil end
	return KaifuActivityData.Instance:GetActivityTypeToIndex(activity_type)
end


LeftTableButton = LeftTableButton or BaseClass(BaseRender)

function LeftTableButton:__init(instance)

end

function LeftTableButton:SetData(data)
	if data == nil then return end
	self.data = data
	self.node_list["TxtLight"].text.text = data.name
	self.node_list["TxtHighLight"].text.text = data.name
	self.node_list["ImgRedPoint"]:SetActive(data.is_show)
	self.node_list["EffectInBtn"]:SetActive(data.is_show_btn_eff or false)
	self.node_list["ImgFlag"]:SetActive(data.is_show_effect or false)

	if self.data.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_RETURN then
		local info = KaifuActivityData.Instance:GetUpGradeReturnInfo()
		if nil ~= info and nil ~= next(info) then
			local act_type = info.act_type
			self.node_list["TxtLight"].text.text = Language.Activity.UpGradeReturnName[act_type]
			self.node_list["TxtHighLight"].text.text = Language.Activity.UpGradeReturnName[act_type]
		end
	end
	if self.data.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPLEVEL_RETURN_2 then
		local info = KaifuActivityData.Instance:GetUpGradeReturnInfo2()
		if nil ~= info and nil ~= next(info) then
			local act_type = info.act_type
			self.node_list["TxtLight"].text.text = Language.Activity.UpGradeReturnName[act_type]
			self.node_list["TxtHighLight"].text.text = Language.Activity.UpGradeReturnName[act_type]
		end
	end
end

function LeftTableButton:GetData()
	return self.data
end

function LeftTableButton:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function LeftTableButton:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end

function LeftTableButton:AddClickCallback(click_callback)
	self.node_list["TabButton"].toggle:AddClickListener(click_callback)
end

