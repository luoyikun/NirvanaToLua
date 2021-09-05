require("game/mainui/mainui_view_player")
require("game/mainui/mainui_view_target")
require("game/mainui/mainui_view_skill")
require("game/mainui/mainui_view_map")
require("game/mainui/mainui_view_task")
require("game/mainui/mainui_view_team")
require("game/mainui/mainui_view_notify")
require("game/mainui/mainui_view_chat")
require("game/mainui/mainui_view_joystick")
require("game/mainui/mainui_view_exp")
require("game/mainui/mainui_view_reminder")
require("game/mainui/mainui_function_trailer")
require("game/mainui/mainui_beatk_icon")
require("game/mainui/mainui_icon_list")
require("game/mainui/mainui_res_icon_list")
require("game/mainui/mainui_icon_group")
require("game/mainui/goddess_skill_tips_view")
require("game/mainui/general_skill_view")
require("game/mainui/mainui_auditversion_view")

local SHOW_REDPOINT_LIMIT_LEVEL = 80
local BTN_WIDTH = 72
local LOWBLOODWARNING = 0.3
local LianFuDuoChengOpenDay = 5 			--连服夺城-开服第几天

MainUIView = MainUIView or BaseClass(BaseView)

function MainUIView:__init()

	self.ui_config = {
		{"uis/views/mainui_prefab", "MainTargetInfoPanel"},
		{"uis/views/mainui_prefab", "MainTopButtonsPanel"},
		{"uis/views/mainui_prefab", "MainTaskPanel"},
		{"uis/views/mainui_prefab", "MainBottomPanel"},
		{"uis/views/mainui_prefab", "MainRemindingPanel"},
		{"uis/views/mainui_prefab", "MainExpInfoPanel"},
		{"uis/views/mainui_prefab", "MainPlayerInfoPanel"},
		{"uis/views/mainui_prefab", "MainFunctionTrailerPanel"},
		{"uis/views/mainui_prefab", "MainAuditVersionView"},
		{"uis/views/mainui_prefab", "RedBloodEffect"},
	}

	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUI
	self.is_safe_area_adapter = true
	self.active_close = false
	self.is_async_load = true

	self.tmp_activity_list = {}
	self.main_icon_group_list = {}
	self.flush_icon_list = {}
	self.flush_icon_time = 0
	self.at_once_flush_icon = nil
	
	self.top_button_ani_state = 1
	self.right_button_ani_state = 1
	self.seek_target_num = 0
	self.strength_shake_status = true
	self.auto_chargechange = true

	self.show_switch = true
	self.can_show_cap_change = true 										-- 是否显示主界面战力变化提示
	self.delay_show_cap_change_time = 6 									-- 屏蔽战力变化提示时间（目前用于进去跨服）

	self.is_qinggong_guide_callby_auto = false
	self.qinggong_guide_index = 0

	self.res_icon_list = MainuiResIconListView.New(ViewName.MainUIResIconList)
	self.goddess_skill_tips_view = GoddessSkillTipsView.New(ViewName.MainUIGoddessSkillTip)
	self.goddess_skill_tips_view:SetCloseCallBack(BindTool.Bind(self.GoddessSkillTipsClose, self))

	Runner.Instance:AddRunObj(self)
end

function MainUIView:__delete()
	self.flush_icon_list = {}
	self.flush_icon_time = 0
	self.at_once_flush_icon = nil
	self.qinggong_btn = nil
	self.qinggong_down_btn = nil
	self.qinggong_guide_index = 0

	Runner.Instance:RemoveRunObj(self)
end

function MainUIView:LoadCallBack()
	-- 立即刷新Icon
	self.at_once_flush_icon = true

	local LEFT_ICON_GROUP = {
		{name = "shopview", icon = "Icon_System_Shop", remind = RemindName.Shop, guide = GuideUIName.MainUIShop, func = BindTool.Bind(self.IsOpenFunction, self, "shopview"), call = BindTool.Bind(self.OnClickShop, self)},
		{name = "exchange", icon = "Icon_System_Exchange", remind = RemindName.Echange, guide = GuideUIName.MainUIEchange, func = BindTool.Bind(self.IsOpenFunction, self, "exchange"), call = BindTool.Bind(self.OnClickExchange, self)},
		{name = "compose", icon = "Icon_System_Compose", remind = RemindName.Compose, guide = GuideUIName.MainUICompose, func = BindTool.Bind(self.IsOpenFunction, self, "compose"), call = BindTool.Bind(self.OpenCompose, self)},
		{name = "scoiety", icon = "Icon_System_Social", remind = RemindName.Scoiety, guide = GuideUIName.MainUIScoiety, func = BindTool.Bind(self.IsOpenFunction, self, "scoiety"), call = BindTool.Bind(self.OpenScoiety, self)},
	}

	local DOWN_ICON_GROUP = {
		{name = "player", icon = "Icon_System_Player", remind = RemindName.PlayerView, guide = ViewName.Player, func = BindTool.Bind(self.IsOpenFunction, self, "player"), call = BindTool.Bind(self.OnClickPlayer, self)},
		{name = "forge", icon = "Icon_System_Forge", remind = RemindName.Forge, guide = ViewName.Forge, func = BindTool.Bind(self.IsOpenFunction, self, "forge"), call = BindTool.Bind(self.OnClickForge, self)},
		{name = "advance", icon = "Icon_System_Iconic", remind = RemindName.Advance, guide = GuideUIName.MainUIAdvance, func = BindTool.Bind(self.IsOpenFunction, self, "advance"), call = BindTool.Bind(self.OnClickAdvance, self)},
		{name = "bianshen", icon = "Icon_System_BianShen", remind = RemindName.BianShen, guide = ViewName.BianShenView, func = BindTool.Bind(self.IsOpenFunction, self, "bianshen"), call = BindTool.Bind(self.OpenBianShen, self)},
		{name = "goddess", icon = "Icon_System_Goddress", remind = RemindName.Goddess_Ground, guide = ViewName.Goddess, func = BindTool.Bind(self.IsOpenFunction, self, "goddess"), call = BindTool.Bind(self.OnClickGoddess, self)},
		{name = "spiritview", icon = "Icon_System_Spirit", remind = RemindName.Spirit, guide = ViewName.SpiritView, func = BindTool.Bind(self.IsOpenFunction, self, "spiritview"), call = BindTool.Bind(self.OpenSpirit, self)},
		-- {name = "rune", icon = "Icon_System_RUNE", remind = RemindName.Rune, guide = ViewName.Rune, func = BindTool.Bind(self.IsOpenFunction, self, "rune"), call = BindTool.Bind(self.OpenRuneView, self)},
		{name = "clothespress", icon = self:ChangeHuanYuIcon(), remind = RemindName.ShenYu, func = BindTool.Bind(self.IsOpenFunction, self, "rune"), call = BindTool.Bind(self.OnClickShenGe, self)},
		{name = "guild", icon = "Icon_System_Guild", remind = RemindName.Guild, guide = ViewName.Guild, func = BindTool.Bind(self.IsOpenFunction, self, "guild"), call = BindTool.Bind(self.OnClickGuild, self)},
		{name = "marriage", icon = "Icon_System_Marrage", remind = RemindName.MarryGroup, guide = GuideUIName.MainUIMarriage, func = BindTool.Bind(self.IsOpenFunction, self, "marriage"), call = BindTool.Bind(self.OnClickMarry, self)},
		-- {name = "suitcollect", icon = "Icon_System_SuitCollect", remind = RemindName.SuitCollection, guide = ViewName.SuitCollection, func = BindTool.Bind(self.IsOpenFunction, self, "suitcollect"), call = BindTool.Bind(self.OpenSuitCollectView, self)},
		-- {name = "market", icon = "Icon_System_Market", remind = RemindName.Market, guide = GuideUIName.MainUIMarket, func = BindTool.Bind(self.IsOpenFunction, self, "market"), call = BindTool.Bind(self.OnClickMarket, self)},
		-- {name = "ranking", icon = "Icon_System_Ranking", remind = RemindName.Rank, guide = GuideUIName.MainUIRank, func = BindTool.Bind(self.IsOpenFunction, self, "ranking"), call = BindTool.Bind(self.OpenRank, self)},
	}

	local TOP_ICON_GROUP_1 = {
		{name = "molongmibaoview", is_tween = false, move_and_show = true, icon = "Icon_LeiJi_Recharge", guide = ViewName.MolongMibaoView, remind = RemindName.MoLongMiBao, func = BindTool.Bind(self.IsOpenMoLongMibao, self,"molongmibaoview"), call = BindTool.Bind(self.OpenJiaNianHua, self)},
		{name = "treasure", is_tween = false, move_and_show = true, icon = "Icon_System_TreasureHunt", guide = ViewName.Treasure, remind = RemindName.XunBaoGroud, func = BindTool.Bind(self.IsOpenFunction, self, "treasure"), call = BindTool.Bind(self.OnClickTreasure, self)},
		{name = "crossrank", icon = "Icon_CrossRank", guide = GuideUIName.MainUICorssRank, func = BindTool.Bind(self.IsOpenFunction, self, "crossrankview"), call = BindTool.Bind(self.OpenCrossRank, self)},
		{name = "DayTrailer", icon = "DayTrailer", func = BindTool.Bind(self.ShowDayOpenTrailer, self), call = BindTool.Bind(self.OpenDayTrailer, self)},
		{name = "ActivityHall", icon = "Icon_System_AxtivityHall", guide = GuideUIName.MainUIShop,remind = RemindName.ActivityHall, func = BindTool.Bind(self.IsOpenFunction, self, "activity"), call = BindTool.Bind(self.OpenActivity, self)},
		-- {name = "douqiview", is_tween = false, move_and_show = true, icon = "Icon_System_Douqi", remind = RemindName.DouQiView, func = BindTool.Bind(self.IsOpenDouQiView, self), call = BindTool.Bind(self.OpenDouQiView, self)},
		{name = "ShenYuBoss", is_tween = false, icon = "Icon_System_ShenYuBoss", remind = RemindName.ShenYuBoss, func = BindTool.Bind(self.IsOpenFunction, self,"shenyubossview"), call = BindTool.Bind(self.OpenShenYuBossView, self)},
		{name = "kf_battle", is_tween = false, icon = "Icon_Kf_Battle", remind = RemindName.KuFuLiuJie, func = BindTool.Bind(self.IsOpenFunction, self, "kf_battle"), call = BindTool.Bind(self.OpenKuafuView, self)},
		{name = "arenaactivityview", is_tween = false, icon = "Icon_System_JingJi", remind = RemindName.Arena, func = BindTool.Bind(self.IsOpenArenaFunction, self), call = BindTool.Bind(self.OpenJingJi, self)},
		{name = "kfarenaactivityview", is_tween = false, icon = "Icon_System_KFJingJi", remind = RemindName.KFArena, func = BindTool.Bind(self.IsOpenKFArenaFunction, self), call = BindTool.Bind(self.OpenKFJingJi, self)},
		{name = "fuben", is_tween = false, icon = "Icon_System_Instance", remind = RemindName.FuBenSingle, guide = ViewName.FuBen, func = BindTool.Bind(self.IsOpenFunction, self, "fuben"), call = BindTool.Bind(self.OpenFuBen, self)},
		{name = "gaozhanfuben", is_tween = false, icon = "Icon_System_GaoZhanFuBen", remind = RemindName.GaoZhanFuBen, guide = ViewName.GaoZhanFuBen, func = BindTool.Bind(self.IsOpenFunction, self, "fuben_gaozhan"), call = BindTool.Bind(self.OpenGaoZhanFuBen, self)},
		-- {name = "Daily", icon = "Icon_System_Daily", remind = RemindName.Baoju, func = BindTool.Bind(self.IsOpenFunction, self, "daily"), call = BindTool.Bind(self.OnClickButtonDaily, self)},
	}

	local TOP_ICON_GROUP_2 = {
		{name = "ActHall", is_tween = false, move_and_show = true, icon = "Icon_System_Act_Hall2", remind = RemindName.ACTIVITY_JUAN_ZHOU, func = BindTool.Bind(self.IsOpenActHall, self), call = BindTool.Bind(self.OpenActivityHall, self)},
		-- {name = "yule", icon = "Icon_System_YuLe", remind = RemindName.YuLe, func = BindTool.Bind(self.IsShowGroup2Act, self, "yule", 2), call = BindTool.Bind(self.ClickYuLe, self)},
		{name = "kaifuactivityview", is_tween = false, move_and_show = true, icon = "Icon_System_ActivityNewServer", remind = RemindName.KaiFu, func = BindTool.Bind(self.IsOpenKaifuAct, self), call = BindTool.Bind(self.OpenNewServer, self)},
		-- {name = "TouziActivityView", is_tween = false, move_and_show = true, icon = "Icon_Touzi_Activity", remind = RemindName.TouziActivity, func = BindTool.Bind(self.IsOpenBossFbTouziAct, self), call = BindTool.Bind(self.OpenBossFbTouziActView, self)},
		{name = "advanced_act", is_tween = false, move_and_show = true, icon = "Icon_System_ActivityWonderfulServer", remind = RemindName.JingCai_Act, func = BindTool.Bind(self.IsOpenExpense, self), call = BindTool.Bind(self.OpenNewServer, self)},
		{name = "GiftLimitBuy", icon = "Icon_Gift_Limit_Buy", func = BindTool.Bind(self.IsOpenGiftLimitBuy, self), call = BindTool.Bind(self.OpenGiftLimitBuy, self)},
		{name = "ZeroGift", is_tween = false, move_and_show = true, icon = "Icon_ZeroGift", remind = RemindName.ZeroGift, func = BindTool.Bind(self.IsOpenZeroGift, self), call = BindTool.Bind(self.OpenZeroGift, self)},
		{name = "OneYuanBuy", is_tween = false, move_and_show = true, icon = "Icon_Activity_2241", remind = RemindName.OneYuanBuy, func = BindTool.Bind(self.IsOpenOneYuanBuy, self), call = BindTool.Bind(self.OpenOneYuanBuyView, self)},
		{name = "FourGradeEquipView", is_tween = false, move_and_show = true, icon = "Icon_Four_Grade_Equip", remind = RemindName.FourGradeEquip, func = BindTool.Bind(self.IsOpenFourGradeEquipView, self), call = BindTool.Bind(self.OpenFourGradeEquipView, self)},
		{name = "rebateview", is_tween = false, move_and_show = true, icon = "Icon_System_Rebate", func = BindTool.Bind(self.IsOpenRebate, self), call = BindTool.Bind(self.OpenRebate, self)},
		{name = "imageskillview", is_tween = false, move_and_show = true, icon = "Icon_System_ImageSkill", func = BindTool.Bind(self.IsOpenImageSkill, self), call = BindTool.Bind(self.OpenImageSkill, self)},
		{name = "Immortal", icon = "Icon_System_ImmortalCard", remind = RemindName.ImmortalCard, func = BindTool.Bind(self.IsOpenImmortal, self), call = BindTool.Bind(self.OnOpenImmortalCard, self)},
		-- {name = "logingift7view", icon = "Icon_System_7Login", remind = RemindName.SevenLogin, func = BindTool.Bind(self.IsOpenSevenDayLogin, self), call = BindTool.Bind(self.OpenSevenLogin, self)},
		-- {name = "ActBiPin", icon = "Icon_bipin_1", remind = "", func = BindTool.Bind(self.ActChangeBiPinBtn, self), call = BindTool.Bind(self.ActOpenBiPin, self)},
		-- {name = "TotalRecharge", icon = "TotalRecharge", remind = RemindName.KfLeichong, func = BindTool.Bind(self.IsOpenRechargeIcon, self, 1), call = BindTool.Bind(self.OpenLeiJiChargeView, self)},
		-- {name = "DepositThreeTime", icon = "Icon_System_DepositThreeTime", func = BindTool.Bind(self.IsOpenRechargeIcon, self, 3), remind = RemindName.ThirdCharge, call = BindTool.Bind(self.OpenThreeRechargeView, self)},
		-- {name = "DepositTwoTime", icon = "Icon_System_DepositTwoTime", func = BindTool.Bind(self.IsOpenRechargeIcon, self, 2), remind = RemindName.SecondCharge, call = BindTool.Bind(self.OpenRechargeView, self)},
		{name = "festivalactivityview", is_tween = false, move_and_show = true, icon = "BanbenActivity_icon", remind = RemindName.Festival_Act, func = BindTool.Bind(self.IsOpenBanBenAct, self), call = BindTool.Bind(self.OpenBanBenServer, self)},
		{name = "Welfare", icon = "Icon_System_Welfare", remind = RemindName.Welfare, func = BindTool.Bind(self.IsShowGroup2Act, self, "welfare", 2), call = BindTool.Bind(self.OnOpenWelfare, self)},
		{name = "tianshuview", is_tween = false, icon = "Icon_TianShu", remind = RemindName.TianShu, func = BindTool.Bind(self.IsOpenTianShuView, self), call = BindTool.Bind(self.OpenTianShuView, self)},
	}

	local TOP_ICON_GROUP_3 = {
		{name = "CrossGolb", icon = "Icon_CrossGoal", remind = RemindName.KuaFuTarget, func = BindTool.Bind(self.ShowCrossGolb, self), call = BindTool.Bind(self.OpenCrossGolb, self)},
		{name = "Recharge7view", icon = "total_chongzhi", remind = RemindName.KfLeichong, func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.RAND_TOTAL_CHONGZHI), call = BindTool.Bind(self.OpenSevenRecharge, self)},
		{name = "BiPin",act_id = 2143, is_tween = false, move_and_show = true, icon = self:ChangeBiPinIcon(), remind = RemindName.BiPin, func = BindTool.Bind(self.ChangeBiPinBtn, self), call = BindTool.Bind(self.OpenBiPin, self)},
		{name = "FanHuanTwo",act_id = 2229, is_tween = false, move_and_show = true, icon = self:ChangeFanHuanIcon(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPLEVEL_RETURN_2), remind = RemindName.FanHuanTwo, func = BindTool.Bind(self.ChangeFanHuanTwoBtn, self), call = BindTool.Bind(self.OpenFanHuanTwo, self)},
		{name = "FanHuan", act_id = 2199, is_tween = false, move_and_show = true, icon = self:ChangeFanHuanIcon(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_RETURN), remind = RemindName.FanHuan, func = BindTool.Bind(self.ChangeFanHuanBtn, self), call = BindTool.Bind(self.OpenFanHuan, self)},
		{name = "TreasureBowl", is_tween = false, move_and_show = true, icon = "Icon_System_Treasure_Bowl", func = BindTool.Bind(self.IsOpenRandActivity, self, ACTIVITY_TYPE.RAND_CORNUCOPIA), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.RAND_CORNUCOPIA)},
		--{name = "GuildBoss", act_id = 24, is_tween = false, icon = "Icon_Activity_24", func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.GUILD_BOSS), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.GUILD_BOSS)},
		
		{name = "DaFuHao", act_id = 25, is_tween = false, move_and_show = true, icon = "Icon_Activity_25", func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.BIG_RICH), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.BIG_RICH)},
		{name = "FallGold", act_id = 20, is_tween = false, move_and_show = true, icon = "Icon_Activity_20", func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.TIANJIANGCAIBAO), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.TIANJIANGCAIBAO)},
		-- {name = "YiZhanFengShen", act_id = 9, is_tween = false, icon = "Icon_Activity_9", func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.CHAOSWAR), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.CHAOSWAR)},
		-- {name = "MarryMe", icon = "Icon_System_MarryMe", func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.MARRY_ME), call = BindTool.Bind(self.OpenMarryMeView, self)},
		{name = "NormalNightFight", act_id = 23, is_tween = false, move_and_show = true, icon = "Icon_Activity_23", func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.NIGHT_FIGHT_FB), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.NIGHT_FIGHT_FB)},
		{name = "Charging", act_id = 2181, is_tween = false, move_and_show = true, icon = "FastCharging", remind = RemindName.SingleChange, func = BindTool.Bind(self.IsOpenActivityShowEffect, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_2, "Charging", 3), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_2, "Charging", 3)},
		{name = "IncreaseCapability", act_id = 2182, is_tween = false, move_and_show = true, icon = "IncreaseCapability", remind = RemindName.IncreaseCapability, func = BindTool.Bind(self.IsOpenActivityShowEffect, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_GIFT, "IncreaseCapability", 3), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_GIFT, "IncreaseCapability", 3)},
		{name = "IncreaseSuperior", act_id = 2183, is_tween = false, move_and_show = true, icon = "IncreaseSuperior", remind = RemindName.IncreaseSuperior, func = BindTool.Bind(self.IsOpenActivityShowEffect, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_3, "IncreaseSuperior", 3), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_3, "IncreaseSuperior", 3)},
		{name = "Recharge", act_id = 2184, is_tween = false, move_and_show = true, icon = "RechargeCapacity", remind = RemindName.RechargeCapacity, func = BindTool.Bind(self.IsOpenActivityShowEffect, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RECHARGE_CAPACITY, "Recharge", 3), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RECHARGE_CAPACITY, "Recharge", 3)},
		{name = "LuanDouBattle", act_id = 31, is_tween = false, move_and_show = true, icon = "Icon_Activity_3086",func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.LUANDOUBATTLE), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.LUANDOUBATTLE)},
		
		{name = "ShenMiShop", act_id = 2209, is_tween = false, move_and_show = true, icon = "Icon_Activity_2209", func = BindTool.Bind(self.IsOpenActivityShowEffect, self, ACTIVITY_TYPE.RAND_ACTIVITY_RMB_BUY_COUNT_SHOP, "ShenMiShop", 3), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.RAND_ACTIVITY_RMB_BUY_COUNT_SHOP, "ShenMiShop", 3)},
		-- {name = "GuildMoneyTree", act_id = 33, is_tween = false, icon = "Icon_Activity_33",func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.GUILD_MONEYTREE), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.GUILD_MONEYTREE)},
		{name = "HuanZhuangShop", is_tween = false, move_and_show = true, act_id = 2188, icon = "Icon_HuanZhuangShop", remind = RemindName.ShowHuanZhuangShopPoint, func = BindTool.Bind(self.IsOpenActivityShowEffect, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP, "HuanZhuangShop", 3), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP, "HuanZhuangShop", 3)},
		{name = "LoopChargeView", is_tween = false, move_and_show = true, act_id = 2205, icon = "Icon_System_LoopCharge", remind = RemindName.LoopCharge, func = BindTool.Bind(self.IsOpenActivityShowEffect, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOOP_CHARGE_2, "LoopChargeView", 3), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOOP_CHARGE_2, "LoopChargeView", 3)},
		-- {name = "NiChongWoSong", is_tween = false, act_id = 2227, icon = "Icon_NiChongWoSong", remind = RemindName.NiChongWoSong, func = BindTool.Bind(self.IsOpenNiChongWoSong, self), call = BindTool.Bind(self.OpenTitleShopView, self)},
		{name = "NiChongWoSong", is_tween = false, act_id = 2227, move_and_show = true, icon = "Icon_NiChongWoSong", remind = RemindName.NiChongWoSong, func = BindTool.Bind(self.IsOpenActivityShowEffect, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_NICHONGWOSONG, "NiChongWoSong", 3), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_NICHONGWOSONG, "NiChongWoSong", 3)},
		{name = "JuBaoPen", is_tween = false, move_and_show = true, act_id = 2083, icon = "Icon_System_Treasure_Bowl", func = BindTool.Bind(self.IsOpenActivityShowEffect, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CORNUCOPIA, "JuBaoPen", 3), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CORNUCOPIA,"JuBaoPen", 3)},
		{name = "BiaoBaiRank", act_id = 2228, icon = "Icon_Activity_2228",func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PROFESS_RANK), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PROFESS_RANK)},
		{name = "OneYuanDuoBao", act_id = 4001, is_tween = false, icon = "Icon_Activity_4001",func = BindTool.Bind(self.IsOpenCrossActivity, self, ACTIVITY_TYPE.KF_ONEYUANSNATCH), call = BindTool.Bind(self.OpenOneYuanSnatchView, self)},
		{name = "LianFuDuoCheng", act_id = 11000, is_tween = false, icon = "Icon_Kf_Battle", func = BindTool.Bind(self.IsOpenLianFuDuoCheng, self, ACTIVITY_TYPE.KF_GUILDBATTLE_READYACTIVITY), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.KF_GUILDBATTLE_READYACTIVITY)},
		{name = "MeiRiDanBi", act_id = 2085, is_tween = false, icon = "Icon_act_MeiRiDanBi", remind = RemindName.MeiRiDanBi, func = BindTool.Bind(self.IsOpenMeiRiDanBi, self, ACTIVITY_TYPE.RAND_DAY_DANBI_CHONGZHI), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.RAND_DAY_DANBI_CHONGZHI)},
		
		{name = "SuitTanMi", is_tween = false, act_id = 2100, icon = "ZhenBaoGe", remind = RemindName.ZhenBaoge, func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT), call = BindTool.Bind(self.OpenZhenBaoGeView, self)},
		{name = "WeekendHappy", is_tween = false, act_id = 2239, icon = self:ChangeWeekendIcon(), remind = RemindName.WeekendHappyRemind, func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WEEKENDHAPPY), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WEEKENDHAPPY)},
		{name = "DoubleHuSong", act_id = 3, is_tween = false, icon = "Icon_Activity_3", func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.HUSONG), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.HUSONG)},
		{name = "YuanSuZhanChang", is_tween = false, act_id = 5, icon = "Icon_Activity_5", func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.QUNXIANLUANDOU), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.QUNXIANLUANDOU)},
		{name = "GongChengZhan", act_id = 6, is_tween = false, icon = "Icon_Activity_6", func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.GONGCHENGZHAN), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.GONGCHENGZHAN)},
		{name = "ShuiJingHuanJing", act_id = 14, is_tween = false, icon = "Icon_Activity_14", func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.SHUIJING), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.SHUIJING)},
		{name = "GuildFight", act_id = 21, is_tween = false, icon = "Icon_Activity_21", func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.GUILDBATTLE), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.GUILDBATTLE)},
		{name = "WangLingTanXian", act_id = 26, is_tween = false, icon = "Icon_Activity_26", func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.TOMB_EXPLORE), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.TOMB_EXPLORE)},
		{name = "GoddessBless", act_id = 27, is_tween = false, icon = "Icon_Activity_27", func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.GUILD_BONFIRE), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.GUILD_BONFIRE)},
		{name = "MarryWedding", act_id = 29, is_tween = false, icon = "Icon_MarryWedding", func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.WEDDING), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.WEDDING)},
		{name = "GuildQuestion", act_id = 30, is_tween = false, icon = "Icon_Activity_30", func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.GUILD_ANSWER), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.GUILD_ANSWER)},
		{name = "GuildShiLian", act_id = 34, is_tween = false, icon = "Icon_Activity_34", func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.GUILD_SHILIAN), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.GUILD_SHILIAN)},
		{name = "CrossXiuLuoTa", act_id = 3073, is_tween = false, icon = "Icon_Activity_3073", func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.KF_XIULUO_TOWER), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.KF_XIULUO_TOWER)},
		{name = "Cross1V1", act_id = 3074, is_tween = false, icon = "Icon_Activity_3074", func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.KF_ONEVONE), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.KF_ONEVONE)},
		{name = "Cross3V3", act_id = 3075, is_tween = false, icon = "Icon_Activity_3075", func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.KF_PVP), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.KF_PVP)},
		{name = "YuanSuRongLu", act_id = 3077, is_tween = false, move_and_show = true, icon = "Icon_Activity_3077", func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.KF_FARMHUNTING), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.KF_FARMHUNTING)},
		{name = "SpringAnswer", act_id = 3080, is_tween = false, icon = "Icon_Activity_3080", func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.KF_HOT_SPRING), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.KF_HOT_SPRING)},
		{name = "ZhenBaoMiJing", act_id = 3083, is_tween = false, icon = "Icon_Activity_3083", func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.KF_MONTH_BLACK_WIND_HIGHT), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.KF_MONTH_BLACK_WIND_HIGHT)},
		{name = "KuaFuFish", act_id = 3084, is_tween = false, icon = "Icon_Activity_3084",func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_FISHING), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_FISHING)},
		{name = "ShenMoZhiZhan", act_id = 3085, is_tween = false, icon = "Icon_Activity_3085", func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.KF_TUANZHAN), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.KF_TUANZHAN)},
		{name = "LuanDouBattle", act_id = 3086, is_tween = false, icon = "Icon_Activity_3086",func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.KF_LUANDOUBATTLE), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.KF_LUANDOUBATTLE)},
		{name = "LingKunBattle", act_id = 3087, is_tween = false, icon = "Icon_Activity_3087", func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_LIEKUN_FB), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_LIEKUN_FB)},
		{name = "DanBiChongZhi", act_id = 2082, is_tween = false, icon = "DanBiChongZhi",func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.RAND_SINGLE_CHARGE), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.RAND_SINGLE_CHARGE)},
		{name = "MoBaiChengZhu", act_id = 32, is_tween = false, icon = "Icon_Activity_32",func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.GONGCHENG_WORSHIP), call = BindTool.Bind(self.StartGoWorship, self, ACTIVITY_TYPE.GONGCHENG_WORSHIP)},
		{name = "ChristmaGiftButton", act_id = 2245, is_tween = false, icon = "Icon_Activity_2245",func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LIWUSHOUGE), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LIWUSHOUGE)},
		{name = "KuaFuBorderland", act_id = 3092, is_tween = false, icon = "Icon_Activity_3092",func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_BIANJING_ZHIDI), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_BIANJING_ZHIDI)},
		{name = "CrystalEscort", act_id = 3094, is_tween = false, icon = "Icon_Activity_3094",func = BindTool.Bind(self.IsOpenActivity, self, ACTIVITY_TYPE.JINGHUA_HUSONG), call = BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.JINGHUA_HUSONG)},
		{name = "CrazyHappyView", is_tween = false, icon = "CrazyHappyView", remind = RemindName.CrazyHappyView, func = BindTool.Bind(self.ShowCrazyHappyActivity, self), call = BindTool.Bind(self.OpenCrazyHappyView, self)},
	}

	--按钮组
	self.left_icon_group = MainuiIconGroup.New()
	self.left_icon_group:Init(self.node_list["LeftButtonGroup"], LEFT_ICON_GROUP, MAIN_UI_ICON_TYPE.BIG)
	self.down_icon_group = MainuiIconGroup.New()
	self.down_icon_group:Init(self.node_list["DownButtonGroup"], DOWN_ICON_GROUP, MAIN_UI_ICON_TYPE.BIG)
	self.top_icon_group_1 = MainuiIconGroup.New()
	self.top_icon_group_1:Init(self.node_list["TopButtonGroup1"], TOP_ICON_GROUP_1, MAIN_UI_ICON_TYPE.NORMAL)
	self.top_icon_group_2 = MainuiIconGroup.New()
	self.top_icon_group_2:Init(self.node_list["TopButtonGroup2"], TOP_ICON_GROUP_2, MAIN_UI_ICON_TYPE.NORMAL)
	self.top_icon_group_3 = MainuiIconGroup.New()
	self.top_icon_group_3:Init(self.node_list["TopButtonGroup3"], TOP_ICON_GROUP_3, MAIN_UI_ICON_TYPE.NORMAL)

	self.main_icon_group_list = {self.left_icon_group, self.down_icon_group, self.top_icon_group_1, self.top_icon_group_2, self.top_icon_group_3}

	-- 创建子View
	self.player_view = MainUIViewPlayer.New(self.node_list["PlayerInfo"])
	self.target_view = MainUIViewTarget.New(self.node_list["TargetInfo"])
	self.skill_view = MainUIViewSkill.New(self.node_list["SkillControl"], self)
	self.map_view = MainUIViewMap.New(self.node_list["MapInfo"])
	self.task_view = MainUIViewTask.New(self.node_list["TaskInfo"])
	self.team_view = MainUIViewTeam.New(self.node_list["TeamInfo"])
	self.chat_view = MainUIViewChat.New(self.node_list["ChatWindow"])
	self.joystick_view = MainUIViewJoystick.New(self.node_list["Joystick"])
	self.exp_view = MainUIViewExp.New(self.node_list["ExpInfo"])
	self.reminding_view = MainUIViewReminding.New(self.node_list["Reminding"])
	self.function_trailer = MainUIFunctiontrailer.New(self.node_list["FunctionTrailer"])
	self.first_recharge_view = MainUIFirstCharge.New(self.node_list["ButtonFirstCharge"])
	self.general_skill_view = GeneralSkillView.New(self.node_list["GeneralSkill"], self)

	self.main_auditversion_view = MainUIAuditVersionView.New(self.node_list["MainAuditVersionView"])
	self.main_auditversion_skill_control = MainUIAuditVersionSkillView.New(self.node_list["MainAuditVersionSkillControl"], self)

	local IS_AUDIT_VERSION_1 = IS_AUDIT_VERSION
	self.is_audit_hide = IS_AUDIT_VERSION_1
	self.node_list["AuditVersionBg"]:SetActive(IS_AUDIT_VERSION_1)
	self.player_view:SetActive(not IS_AUDIT_VERSION_1)
	self.node_list["TopCount"]:SetActive(not IS_AUDIT_VERSION_1)
	self.node_list["LeftButtons"]:SetActive(not IS_AUDIT_VERSION_1)
	self.node_list["RightButtons"]:SetActive(not IS_AUDIT_VERSION_1)
	self.node_list["MainRemindingPanel"]:SetActive(not IS_AUDIT_VERSION_1)
	self.node_list["Menu"]:SetActive(not IS_AUDIT_VERSION_1)
	self.node_list["Market"]:SetActive(not IS_AUDIT_VERSION_1)
	self.node_list["OnlineContent"]:SetActive(not IS_AUDIT_VERSION_1)
	self.node_list["RightBtn"]:SetActive(not IS_AUDIT_VERSION_1)
	self.node_list["HideChatContenet"]:SetActive(not IS_AUDIT_VERSION_1)
	self.node_list["ChatIconGroup"]:SetActive(not IS_AUDIT_VERSION_1)
	self.node_list["JumpContent"]:SetActive(not IS_AUDIT_VERSION_1)
	self.node_list["MainBottomBg"]:SetActive(not IS_AUDIT_VERSION_1)
	self.node_list["ExpImage"]:SetActive(not IS_AUDIT_VERSION_1)
	self.exp_view:SetActive(not IS_AUDIT_VERSION_1)
	self.node_list["FunctionBG"]:SetActive(not IS_AUDIT_VERSION_1)

	self.shield_others = GlobalEventSystem:Bind(SettingData.Instance:GetGlobleType(SETTING_TYPE.SHIELD_OTHERS), BindTool.Bind(self.UpdateShieldMode, self))
	self.shield_camp = GlobalEventSystem:Bind(SettingData.Instance:GetGlobleType(SETTING_TYPE.SHIELD_SAME_CAMP), BindTool.Bind(self.UpdateShieldMode, self))
	self.task_change_handle = GlobalEventSystem:Bind(OtherEventType.TASK_CHANGE,BindTool.Bind(self.OnTaskChange, self))
	self.person_glal_change_handle = GlobalEventSystem:Bind(OtherEventType.VIRTUAL_TASK_CHANGE,BindTool.Bind(self.OnPersonGoalChange, self))
	self.shrink_btn_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_SHRINK_BUTTON,BindTool.Bind(self.OnShowOrHideShrinkBtn, self))
	self.menu_toggle_change = GlobalEventSystem:Bind(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, BindTool.Bind(self.PortraitToggleChange, self))
	self.scene_load_complete = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_QUIT, BindTool.Bind(self.SceneLoadComplete, self))
	self.right_up_button_show = GlobalEventSystem:Bind(SceneEventType.SHOW_MAINUI_RIGHT_UP_VIEW, BindTool.Bind(self.ChangeMenuState, self))
	self.main_role_level_change = GlobalEventSystem:Bind(ObjectEventType.LEVEL_CHANGE, BindTool.Bind(self.MainRoleLevelChange, self))
	self.main_role_exp_change = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_EXP_CHANGE, BindTool.Bind(self.OnMainRoleEXPChange, self))
	self.main_role_realive = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_REALIVE, BindTool.Bind1(self.OnMainRoleRevive, self))
	self.camera_mode_change = GlobalEventSystem:Bind(SettingEventType.MAIN_CAMERA_MODE_CHANGE, BindTool.Bind(self.CameraModeChange, self))
	self.guaji_change = GlobalEventSystem:Bind(OtherEventType.GUAJI_TYPE_CHANGE, BindTool.Bind(self.OnGuajiTypeChange, self))
	self.change_fight_state_toggle = GlobalEventSystem:Bind(MainUIEventType.CHNAGE_FIGHT_STATE_BTN, BindTool.Bind(self.ChangeFightStateToggle, self))
	self.show_rebate_change = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_REBATE_BUTTON, BindTool.Bind(self.ShowRebateButton, self))

	self.show_image_skill_change = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_IMAGESKILL_BUTTON, BindTool.Bind(self.ShowImageSkillButton, self))

	self.change_mainui_button = GlobalEventSystem:Bind(MainUIEventType.CHANGE_MAINUI_BUTTON, BindTool.Bind(self.SetButtonVisible, self))
	self.view_open_event = GlobalEventSystem:Bind(OtherEventType.VIEW_OPEN, BindTool.Bind(self.HasViewOpen, self))
	self.view_close_event = GlobalEventSystem:Bind(OtherEventType.VIEW_CLOSE, BindTool.Bind(self.HasViewClose, self))
	self.cross_server_event = GlobalEventSystem:Bind(LoginEventType.CROSS_SERVER_CONNECTED, BindTool.Bind(self.OnConnectLoginServer, self))
	self.login_server_event = GlobalEventSystem:Bind(LoginEventType.LOGIN_SERVER_CONNECTED, BindTool.Bind(self.OnConnectLoginServer, self))
	self.pass_day_handle = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.OnDayChange, self))
	self.world_level_change_handle = GlobalEventSystem:Bind(OtherEventType.WORLD_LEVEL_CHANGE, BindTool.Bind(self.WorldLevelChangeHandle, self))
	self.role_level_change_handle = GlobalEventSystem:Bind(OtherEventType.ROLE_LEVEL_UP, BindTool.Bind(self.RoleLevelChangeHandle, self))
	self.hefu_activity_change_handle = GlobalEventSystem:Bind(OtherEventType.ACTIVITY_CHANGE,BindTool.Bind(self.HefuActivityChangeHandle,self))

	self.activity_change_handle = BindTool.Bind(self.ActivityChangeCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_change_handle)

	self.role_attr_value_change = BindTool.Bind1(self.OnRoleAttrValueChange, self)
	PlayerData.Instance:ListenerAttrChange(self.role_attr_value_change)

	self.territory_change_handle = BindTool.Bind(self.ClashTerritoryDataChangeCallback, self)
	ClashTerritoryData.Instance:AddListener(ClashTerritoryData.INFO_CHANGE, self.territory_change_handle)

	self.task_shrink_button_animator = self.node_list["TaskShrinkButton"].animator
	self.left_track_animator = self.node_list["TrackInfo"].animator
	self.left_track_animator:ListenEvent("IsVisible", BindTool.Bind(self.LeftTrackIsVisible, self))
	self.task_tab_btn_animator = self.node_list["TabButtons"].animator
	self.act_hongbao_ani = self.node_list["ActHongBaoBtn"].animator
	self.act_hongbao_down_ani = self.node_list["ImageDiamon"].animator

	self.left_buttons_animator = self.node_list["LeftButtons"].animator
	self.left_buttons_animator:ListenEvent("TopListVisible", BindTool.Bind(self.TopRightVisible, self))
	self.top_buttons_animator = self.node_list["TopButtons"].animator
	self.top_buttons_animator:ListenEvent("TopListVisible", BindTool.Bind(self.TopRightVisible, self))
	self.right_Buttons_animator = self.node_list["RightButtons"].animator
	self.right_Buttons_animator:ListenEvent("RightButtons", BindTool.Bind(self.RightButtonsVisible, self))
	self.top_group2_animator = self.node_list["TopButtonGroup2"].animator

	self.playerinfo_animator = self.node_list["MainPlayerInfoPanel"].animator
	self.trailer_animator = self.node_list["MainFunctionTrailerPanel"].animator
	self.targetInfo_animator = self.node_list["MainTargetInfoPanel"].animator
	self.maintask_animator = self.node_list["MainTaskPanel"].animator
	self.topButtons_animator = self.node_list["MainTopButtonsPanel"].animator
	self.bottom_animator = self.node_list["PanelBottom"].animator

	self.node_list["ButtonPackage"].button:AddClickListener(BindTool.Bind(self.OnClickPackage, self))
	self.node_list["AutoButton"].toggle.onValueChanged:AddListener(BindTool.Bind(self.OnAutoChanged, self))
	self.node_list["BtnAuto"].button:AddClickListener(BindTool.Bind(self.OnYewaiGuaji, self))
	self.node_list["BtnShield_All"].button:AddClickListener(BindTool.Bind(self.OnShieldModeChanged2, self))
	self.node_list["ImmortalBtn"].button:AddClickListener(BindTool.Bind(self.OnOpenImmortalCard, self))
	self.node_list["BtnShield_Friend"].button:AddClickListener(BindTool.Bind(self.OnShieldModeChanged1, self))
	self.node_list["BtnShield_Nothing"].button:AddClickListener(BindTool.Bind(self.OnShieldModeChanged0, self))
	self.node_list["BtnCurrentMap"].button:AddClickListener(BindTool.Bind(self.OpenMap, self))
	self.node_list["BtnBoss"].button:AddClickListener(BindTool.Bind(self.OpenBossView, self))
	self.node_list["TeamButton"].toggle:AddClickListener(BindTool.Bind(self.TeamButtonClick, self))
	self.node_list["PriviteRemind"].button:AddClickListener(BindTool.Bind(self.OpenPrivite, self))
	self.node_list["BtnSwitch"].toggle.onValueChanged:AddListener(BindTool.Bind(self.ClickSwitch, self))
	self.node_list["OnlineRewardBtn"].button:AddClickListener(BindTool.Bind(self.OpenOnlineRewardView, self))
	self.node_list["BtnLineView"].button:AddClickListener(BindTool.Bind(self.OpenLineView, self))
	self.node_list["BtnSavePower"].button:AddClickListener(BindTool.Bind(self.OnClickSavePower, self))
	self.node_list["FightStateBtn"].toggle:AddClickListener(BindTool.Bind(self.FightStateClick, self))
	self.node_list["ExpBottleButton"].button:AddClickListener(BindTool.Bind(self.OpenExpBottle, self))
	self.node_list["BtnDaily"].button:AddClickListener(BindTool.Bind(self.OnClickButtonDaily, self))
	self.node_list["BtnChangeCameraMode"].button:AddClickListener(BindTool.Bind(self.OnClickCameraMode, self))
	self.node_list["BtnPhotoShot"].button:AddClickListener(BindTool.Bind(self.OnClickPhotoShot, self))
	self.node_list["Group2Button"].toggle:AddClickListener(BindTool.Bind(self.OnClickGroup2Button, self))
	self.node_list["ButtonFirstCharge"].button:AddClickListener(BindTool.Bind(self.OpenFirstCharge, self))
	self.node_list["Setting"].button:AddClickListener(BindTool.Bind(self.OnClickSetting, self))
	self.node_list["BtnChargeArrow1"].toggle:AddClickListener(BindTool.Bind(self.ClickChargeChange, self, 1))
	self.node_list["BtnChargeArrow2"].toggle:AddClickListener(BindTool.Bind(self.ClickChargeChange, self, 2))

	self.node_list["ServerHongBaoBtn"].button:AddClickListener(BindTool.Bind(self.OpenServerHongBao, self))
	self.node_list["Buttonmarket"].button:AddClickListener(BindTool.Bind(self.OnClickMarket, self))
	self.node_list["ButtonRank"].button:AddClickListener(BindTool.Bind(self.OpenRank, self))

	self.is_team_tab_on = false
	self.record_guild_shake = false
	self.is_in_special_scene = true
	self.is_show_task = true
	self.is_show_charge_panel = true
	self.is_show_map_info = true
	self.map_view:SetShowTopBg(self.is_show_map_info)

	self.node_list["ListChargeButton"]:SetActive(false)
	self.node_list["ButtonFirstCharge"]:SetActive(false)
	self.node_list["NodeTaskParent"]:SetActive(self.is_show_task and self.is_in_special_scene and not self.is_audit_hide)
	self.node_list["RightPanel"]:SetActive(self.is_show_task and self.is_in_special_scene and not IS_ON_CROSSSERVER)
	
	local open_chongzhi = GLOBAL_CONFIG.param_list.switch_list.open_chongzhi
	self.node_list["AuditVersion"]:SetActive(IS_AUDIT_VERSION and open_chongzhi)
	self.node_list["PanelChargeButton"]:SetActive(self.is_show_map_info and not IS_AUDIT_VERSION and open_chongzhi)

	self.node_list["TopButtons"]:SetActive(self.is_show_map_info)
	self.node_list["ShrinkButton"]:SetActive(self.is_show_map_info)
	self.node_list["RedBloodEffect"]:SetActive(false)
	self.node_list["TxtLineName"].text.text = string.format(Language.Common.Line, (PlayerData.Instance:GetAttr("scene_key") or 0) + 1)
	
	self.is_show_shrink_btns = true
	self.node_list["ShrinkButton"].toggle.isOn = self.is_show_shrink_btns
	self.node_list["ShrinkButton"].toggle:AddValueChangedListener(BindTool.Bind(self.OnShrinkBtnValueChange, self))

	self.MenuIconToggle = self.node_list["MenuIcon"].toggle
	self.MenuIconToggle:AddValueChangedListener(BindTool.Bind(self.OnMenuIconToggleChange, self))

	self.node_list["TeamButton"].toggle:AddValueChangedListener(BindTool.Bind(self.TeamTabChange, self))
	self.node_list["TaskShrinkButton"].toggle:AddValueChangedListener(BindTool.Bind(self.OnTaskShrinkToggleChange, self))
	self.node_list["FightStateBtn"].toggle:AddValueChangedListener(BindTool.Bind(self.OnFightStateToggleChange, self))

	self:CheckMenuRedPoint()
	self:SetPriviteRemindVisible(false)
	self:CheckJuBaoPenIcon()
	self:UpdateShieldMode()
	self:ShowRebateButton()
	self:ShowImageSkillButton()
	self:MainRoleLevelChange()
	self:OnDayChange()
	self:OnGuajiTypeChange(GuajiCache.event_guaji_type)
	self:CameraModeChange()
	self:SetViewState(self.is_in_special_scene)
	self:ChangeGeneralState()
	self:SetShowExpBottle(false)
	self:UpdateGuildOpenTips()
	self:ShowXianShiDuiHuan()
	self:ShowTeHuiDiscountShop()
	self.player_view:FlushTempVip()
	self:FlushOnlineReward()
	self:FlushImmortalIcon()

	self.qinggong_btn = self.skill_view:GetQingGongBtn()
	self.qinggong_down_btn = self.skill_view:GetQingGongDown()

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.Baoju)
	RemindManager.Instance:Bind(self.remind_change, RemindName.Main_Boss)
	RemindManager.Instance:Bind(self.remind_change, RemindName.ChargeGroup)
	RemindManager.Instance:Bind(self.remind_change, RemindName.MenuIcon)
	RemindManager.Instance:Bind(self.remind_change, RemindName.MainTop)
	RemindManager.Instance:Bind(self.remind_change, RemindName.Rank)
	RemindManager.Instance:Bind(self.remind_change, RemindName.GuildChatRed)

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Main, BindTool.Bind(self.GetUiCallBack, self))

	if nil ~= FontTextureReBuild then
		FontTextureReBuild.Instance:SetIsOpen(true)
		FontTextureReBuild.Instance:SetCanRefresh(true)
	end
end

function MainUIView:ReleaseCallBack()
	if self.left_icon_group then
		self.left_icon_group:DeleteMe()
		self.left_icon_group = nil
	end

	if self.down_icon_group then
		self.down_icon_group:DeleteMe()
		self.down_icon_group = nil
	end

	if self.top_icon_group_1 then
		self.top_icon_group_1:DeleteMe()
		self.top_icon_group_1 = nil
	end

	if self.top_icon_group_2 then
		self.top_icon_group_2:DeleteMe()
		self.top_icon_group_2 = nil
	end

	if self.top_icon_group_3 then
		self.top_icon_group_3:DeleteMe()
		self.top_icon_group_3 = nil
	end

	if self.player_view ~= nil then
		self.player_view:DeleteMe()
		self.player_view = nil
	end

	if self.target_view ~= nil then
		self.target_view:DeleteMe()
		self.target_view = nil
	end

	if self.skill_view ~= nil then
		self.skill_view:DeleteMe()
		self.skill_view = nil
	end

	if self.map_view ~= nil then
		self.map_view:DeleteMe()
		self.map_view = nil
	end

	if self.task_view ~= nil then
		self.task_view:DeleteMe()
		self.task_view = nil
	end

	if self.team_view ~= nil then
		self.team_view:DeleteMe()
		self.team_view = nil
	end

	if self.chat_view ~= nil then
		self.chat_view:DeleteMe()
		self.chat_view = nil
	end

	if self.joystick_view ~= nil then
		self.joystick_view:DeleteMe()
		self.joystick_view = nil
	end

	if self.exp_view ~= nil then
		self.exp_view:DeleteMe()
		self.exp_view = nil
	end

	if self.reminding_view ~= nil then
		self.reminding_view:DeleteMe()
		self.reminding_view = nil
	end

	if self.function_trailer ~= nil then
		self.function_trailer:DeleteMe()
		self.function_trailer = nil
	end

	if self.first_recharge_view ~= nil then
		self.first_recharge_view:DeleteMe()
		self.first_recharge_view = nil
	end

	if self.general_skill_view ~= nil then
		self.general_skill_view:DeleteMe()
		self.general_skill_view = nil
	end

	if self.main_auditversion_skill_control ~= nil then
		self.main_auditversion_skill_control:DeleteMe()
		self.main_auditversion_skill_control = nil
	end

	if self.main_auditversion_view ~= nil then
		self.main_auditversion_view:DeleteMe()
		self.main_auditversion_view = nil
	end

	if self.res_icon_list ~= nil then
		self.res_icon_list:DeleteMe()
		self.res_icon_list = nil
	end

	if self.goddess_skill_tips_view ~= nil then
		self.goddess_skill_tips_view:DeleteMe()
		self.goddess_skill_tips_view = nil
	end

	if self.qinggong_guide_timer then
		GlobalTimerQuest:CancelQuest(self.qinggong_guide_timer)
		self.qinggong_guide_timer = nil
	end

	if self.role_attr_value_change and PlayerData.Instance then
		PlayerData.Instance:UnlistenerAttrChange(self.role_attr_value_change)
		self.role_attr_value_change = nil
	end

	if self.activity_change_handle and ActivityData.Instance then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_change_handle)
		self.activity_change_handle = nil
	end

	if self.territory_change_handle and ClashTerritoryData.Instance then
		ClashTerritoryData.Instance:RemoveListener(ClashTerritoryData.INFO_CHANGE, self.territory_change_handle)
		self.territory_change_handle = nil
	end

	if self.pass_day_handle then
		GlobalEventSystem:UnBind(self.pass_day_handle)
		self.pass_day_handle = nil
	end

	if self.world_level_change_handle then
		GlobalEventSystem:UnBind(self.world_level_change_handle)
		self.world_level_change_handle = nil
	end

	if self.role_level_change_handle then
		GlobalEventSystem:UnBind(self.role_level_change_handle)
		self.role_level_change_handle = nil
	end

	if self.hefu_activity_change_handle then
		GlobalEventSystem:UnBind(self.hefu_activity_change_handle)
		self.hefu_activity_change_handle = nil
	end

	if self.change_fight_state_toggle then
		GlobalEventSystem:UnBind(self.change_fight_state_toggle)
		self.change_fight_state_toggle = nil
	end

	if self.view_open_event then
		GlobalEventSystem:UnBind(self.view_open_event)
		self.view_open_event = nil
	end

	if self.cross_server_event then
		GlobalEventSystem:UnBind(self.cross_server_event)
		self.cross_server_event = nil
	end

	if self.login_server_event then
		GlobalEventSystem:UnBind(self.login_server_event)
		self.login_server_event = nil
	end

	if self.view_close_event then
		GlobalEventSystem:UnBind(self.view_close_event)
		self.view_close_event = nil
	end

	if nil ~= self.guaji_change then
		GlobalEventSystem:UnBind(self.guaji_change)
		self.guaji_change = nil
	end

	if nil ~= self.show_rebate_change then
		GlobalEventSystem:UnBind(self.show_rebate_change)
		self.show_rebate_change = nil
	end

	if nil ~= self.show_image_skill_change then
		GlobalEventSystem:UnBind(self.show_image_skill_change)
		self.show_image_skill_change = nil
	end

	if nil ~= self.change_mainui_button then
		GlobalEventSystem:UnBind(self.change_mainui_button)
		self.change_mainui_button = nil
	end

	if self.menu_toggle_change ~= nil then
		GlobalEventSystem:UnBind(self.menu_toggle_change)
		self.menu_toggle_change = nil
	end

	if self.scene_load_complete ~= nil then
		GlobalEventSystem:UnBind(self.scene_load_complete)
		self.scene_load_complete = nil
	end

	if self.right_up_button_show ~= nil then
		GlobalEventSystem:UnBind(self.right_up_button_show)
		self.right_up_button_show = nil
	end

	if self.main_role_exp_change ~= nil then
		GlobalEventSystem:UnBind(self.main_role_exp_change)
		self.main_role_exp_change = nil
	end

	if self.main_role_realive ~= nil then
		GlobalEventSystem:UnBind(self.main_role_realive)
		self.main_role_realive = nil
	end

	if self.shrink_btn_event ~= nil then
		GlobalEventSystem:UnBind(self.shrink_btn_event)
		self.shrink_btn_event = nil
	end

	if nil ~= self.shield_others then
		GlobalEventSystem:UnBind(self.shield_others)
		self.shield_others = nil
	end

	if nil ~= self.shield_camp then
		GlobalEventSystem:UnBind(self.shield_camp)
		self.shield_camp = nil
	end

	if nil ~= self.task_change_handle then
		GlobalEventSystem:UnBind(self.task_change_handle)
		self.task_change_handle = nil
	end

	if self.person_glal_change_handle then
		GlobalEventSystem:UnBind(self.person_glal_change_handle)
		self.person_glal_change_handle = nil
	end

	if self.main_role_level_change then
		GlobalEventSystem:UnBind(self.main_role_level_change)
		self.main_role_level_change = nil
	end

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	if self.camera_mode_change then
		GlobalEventSystem:UnBind(self.camera_mode_change)
		self.camera_mode_change = nil
	end

	if self.delay_text_timer then
		GlobalTimerQuest:CancelQuest(self.delay_text_timer)
		self.delay_text_timer = nil
	end

	if self.mlmb_timer then
		GlobalTimerQuest:CancelQuest(self.mlmb_timer)
		self.mlmb_timer = nil
	end

	if self.exp_bottle_shake_timer then
		GlobalTimerQuest:CancelQuest(self.exp_bottle_shake_timer)
		self.exp_bottle_shake_timer = nil
	end

	if self.marry_me_count_down then
		CountDown.Instance:RemoveCountDown(self.marry_me_count_down)
		self.marry_me_count_down = nil
	end

	if self.rising_star_countdown then
		CountDown.Instance:RemoveCountDown(self.rising_star_countdown)
		self.rising_star_countdown = nil
	end

	if self.mark_down then
		GlobalTimerQuest:CancelQuest(self.mark_down)
		self.mark_down = nil
	end

	if nil ~= self.get_exp_efficiency_timer then
		GlobalTimerQuest:CancelQuest(self.get_exp_efficiency_timer)
		self.get_exp_efficiency_timer = nil
	end

	if nil ~= self.delay_init_open_fun_timer then
		GlobalTimerQuest:CancelQuest(self.delay_init_open_fun_timer)
		self.delay_init_open_fun_timer = nil
	end

	if self.strengthen_remind_timer_quest then
		GlobalTimerQuest:CancelQuest(self.strengthen_remind_timer_quest)
		self.strengthen_remind_timer_quest = nil
	end

	if self.seek_target_time then
		GlobalTimerQuest:CancelQuest(self.seek_target_time)
		self.seek_target_time = nil
	end

	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
	end
	
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.Main)
	end

	self:StopOnlineCountDown()
	self:ClearManualTime()
	self:RemoveFightToggleTimeQuest()
	self:StopWeddingTime()

	self.task_shrink_button_animator = nil
	self.left_track_animator = nil
	self.task_tab_btn_animator = nil
	self.act_hongbao_ani = nil
	self.act_hongbao_down_ani = nil

	self.left_buttons_animator = nil
	self.top_buttons_animator = nil
	self.right_Buttons_animator = nil
	self.top_group2_animator = nil

	self.playerinfo_animator = nil
	self.trailer_animator = nil
	self.targetInfo_animator = nil
	self.maintask_animator = nil
	self.topButtons_animator = nil
	self.bottom_animator = nil

	self.MenuIconToggle = nil
	self.main_icon_group_list = {}

	self.flush_icon_list = {}
	self.flush_icon_time = 0
	self.at_once_flush_icon = nil
end

function MainUIView:OpenCallBack()
	self:Flush()
	self:FlushChargeIcon()
	self:InitOpenFunctionIcon()
	self:ChangeFunctionTrailer()
	self:ShakeGuildChatBtn(GuildData.Instance:GetGuildChatShakeState())
	self:SetMountText()
	self.chat_view:FulshChatView()
	GlobalTimerQuest:AddDelayTimer(function() GlobalEventSystem:Fire(MainUIEventType.MAINUI_OPEN_COMLETE) end, 0)
end

function MainUIView:OnFlush(param_t)
	if self.skill_view then
		self.skill_view:OnFlush(param_t)
	end

	if self.main_auditversion_skill_control then
		self.main_auditversion_skill_control:OnFlush(param_t)
	end

	for k, v in pairs(param_t) do
		if k == "audit_task" and self.task_view then
			if v and nil ~= v[1] then
				self.task_view:OnClickAuditTask(v[1])
			end
			return
		elseif k == "audit_use_skill" and self.skill_view then
			if v and nil ~= v[1] then
				self.skill_view:OnClickAuditSkill(v[1])
			end
			return
		elseif k == "audit_click_joystick" and self.joystick_view then
			if v and v[1] and v[2] then
				local fx = tonumber(v[1]) or 0
				local fy = tonumber(v[2]) or 0
				local is_touch_move = v[3]
				self.joystick_view:UpdateAuditJoyStick(fx, fy, is_touch_move)
			end
			return
		end
		if v and nil ~= v[1] and self.chat_view then
			self:FlushTipsIcon(k, v[1])
		end

		if k == "hongbao_num" then
			self:FlushHongBaoNumValue()
		elseif k == "server_hongbao_num" then
			self:FlushServerHongBaoNumValue()
		elseif k == "activity_hongbao_ani" then
			self:ChangeActHongBaoAni(v[1], v[2])
		elseif k == "team_list" then
			self.team_view:ReloadData()
		elseif k == "wedding" then
			self:ChangeWeddingState()
		elseif k == "be_atk" then
			self:FlushBeAtkIconState(v[1])
		elseif k == "on_line" then
			self:FlushOnlineReward()
		elseif k == "temp_vip" then
			self.player_view:FlushTempVip()
		elseif k == "show_diamondown" then
			self:ShowDiamonDown()
		elseif k == "change_fight_enable" then
			self:ChangeFightStateEnable(v[1])
		elseif k == "general_bianshen" then
			self:ChangeGeneralState()
			self.general_skill_view:Flush(v[1])
		elseif k == "jubaopen" then
			self:CheckJuBaoPenIcon()
		elseif k == "trailerview" then
			self:ChangeFunctionTrailer()
		elseif k == "show_privite_remind" then
			self:ShowPriviteRemind(v[1])
		elseif k == "privite_visible" then
			self:SetPriviteRemindVisible(v[1])
		elseif k == "guild_shake" then
			self:ShakeGuildChatBtn(v[1])
		elseif k == "flush_guild_chat_icon" then
			self:ShowGuildChatIcon(v[1])
		elseif k == "flush_welfare_icon" then
			self:ShowWelfareBossIcon(v[1])
		elseif k == "reminder_charge" then
			self.reminding_view:FlushFirstCharge()
		elseif k == "mount_state" then
			self:SetMountText()
		elseif k == "recharge" then
			self:CheckRechargeIcon(v[1])
		elseif k == "leiji_charge" then
			self:FlushIconGroupThree()
			self:FlushIconGroupPlayer()
		elseif k == "auto_rotation" then
			self:FlushAutoRotation()
		elseif k == "flush_popchat_view" then
			self.chat_view:FlushPopChatView(v[1])
		elseif k == "rendering" then
			self:ChangeFunctionTrailer()
			self:OnGuajiTypeChange(GuajiCache.event_guaji_type)
			if self.menu_toggle_state ~= nil then
				self:PortraitToggleChange(self.menu_toggle_state)
				self.menu_toggle_state = nil
			end
		elseif k == "role_change_prof" then
			self:RoleChangeProf()
		elseif k == "molongmibao" then
			self:CheckMoLongIcon()
		elseif k == "fly_task_is_hide" then
			self:SetFlyTaskIsHideMainUi(v[1])
		
		elseif k == "jump_state" then
			self.skill_view:FlushJumpState(v[1])
		elseif k == "show_market" then
			self:IsShowMarket(true)
		elseif k == "guaji_manual_state" then
			self:SetGuajiManualState()
		elseif k == "show_double_icon" then
			self:ShowDoubleIcon(v[1])
		elseif k == "clear_manual_time" then
			self:ClearManualTime()
		elseif k == "icon_group_1" then
			self:FlushGroup1Icon()
		elseif k == "icon_group_3" then
			self:FlushIconGroupThree()
		elseif k == "icon_group_player" then
			self:FlushIconGroupPlayer()
		elseif k == "flush_charge_icon" then
			self:FlushChargeIcon()
		elseif k == "fulush_near_role" then
			self:FulushNearRole()
		end
	end
	self:CheckShouFirstChargeEff()
end

function MainUIView:FlushTipsIcon(icon_name, is_active, param_list)
	if nil ~= self.chat_view and nil ~= is_active then
		self.chat_view:FlushTipsIcon(icon_name, is_active, param_list)
	end
end

function MainUIView:FulushNearRole()
	if nil ~= self.chat_view then
		self.chat_view:FlushNearRoleView()
	end
end

function MainUIView:FlushImmortalIcon()
 	local active_list = ImmortalData.Instance:GetActiveList()
 	for i = 1, 3 do
 		if self.node_list and self.node_list["Star" .. i] then
 			UI:SetGraphicGrey(self.node_list["Star" .. i], not active_list[i])
 		end
 	end
 	self:FlushImmortalLabel()
end 

function MainUIView:FlushImmortalLabel()
	if self.top_icon_group_2 then
		local is_label = ImmortalData.Instance:RemindLabel()
		local bundle, asset = ResPath.GetImages("label_status_xianshi3")
		self.top_icon_group_2:ShowXianShiDuiHuan("Immortal", is_label > 0, bundle, asset)
	end
end

function MainUIView:FlushIconGroups()
	if not self:IsLoaded() then
		return
	end

	for k, v in pairs(self.main_icon_group_list) do
		self:AddToUpdateList(v)
	end
	if self.player_view then
		self:AddToUpdateList(self.player_view)
	end
end

function MainUIView:AddToUpdateList(icon_group)
	if self.at_once_flush_icon == nil or self.at_once_flush_icon then
		if icon_group then
			icon_group:FlushIconGroup()
		end
		return
	end

	for k, v in ipairs(self.flush_icon_list) do
		if v == icon_group then
			return
		end
	end
	table.insert(self.flush_icon_list, icon_group)
end

function MainUIView:Update(now_time, elapse_time)
	if self.at_once_flush_icon == nil then
		return
	end
	if self.at_once_flush_icon then
		if self.flush_icon_time <= 0 then
			self.flush_icon_time = now_time + 8
		elseif self.flush_icon_time < now_time then
			self.at_once_flush_icon = false
		end
		return
	end

	local flush_group = table.remove(self.flush_icon_list, 1)
	if flush_group then
		flush_group:FlushIconGroup()
		return
	end
end

function MainUIView:IsOpenSecretrShop()
	local activity_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_RMB_BUY_COUNT_SHOP)
	return ActivityData.Instance:GetIsOpenLevel(ACTIVITY_TYPE.RAND_ACTIVITY_RMB_BUY_COUNT_SHOP) and activity_info and activity_info.status ~= ACTIVITY_STATUS.CLOSE
end

--按钮显示隐藏条件
function MainUIView:IsOpenActivity(act_type)
	local activity_info = ActivityData.Instance:GetActivityStatuByType(act_type)
	if ActivityData.Instance:GetRealOpenDay(act_type) then
		local is_reach_limint = true
		local is_reach_vipexp = true
		-- if ACTIVITY_ENTER_LIMIT_LIST[act_type] then
		-- 	is_reach_limint = ActivityData.Instance:IsAchieveLevelInLimintConfigById(act_type)
		-- end

		if act_type == ACTIVITY_TYPE.RAND_TOTAL_CHONGZHI then
			local leiji_cfg = KaifuActivityData.Instance:GetLeiJiChongZhiCfg()[1] or {}
			local min_money = leiji_cfg.min_money or 0
			local vip_exp = VipData.Instance:GetCurrentVipExp() or 0
			is_reach_vipexp = vip_exp >= min_money
			local total_cfg = KaifuActivityData.Instance:GetLeijiChongZhiFlagCfg()
			if total_cfg ~= nil then
				is_reach_limint = false
				for k, v in pairs(total_cfg) do
					if v.flag > 0 then
						is_reach_limint = true
						break
					end
				end
			end
		elseif act_type == ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_BIANJING_ZHIDI then
			local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
			local open_act_day = KuaFuBorderlandData.Instance:GetKFBorderlandActivityOtherCfg().server_open_day or 0
			if open_day < open_act_day then
				is_reach_limint = false
			end
		elseif act_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LIWUSHOUGE then
			is_reach_limint = false
			if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LIWUSHOUGE) then
				is_reach_limint = false
			else
				local me_info = ChristmaGiftData.Instance:GetMeData()
				local time_cfg = nil
				local next_day = false
				if me_info and me_info.round then
					if me_info.round == 0 then
						me_info.round = 1
						next_day = true
					end
					time_cfg = ChristmaGiftData.Instance:GetRoundTime(me_info.round)
				end
				if time_cfg and time_cfg.round_start_time and time_cfg.round_end_time then
					local timr = time_cfg.round_start_time
					local h = math.floor(timr / 100)
					local m = math.floor(timr % 100)
					local open_time = TimeUtil.NowDayTimeStart(os.time()) + (h * 60 * 60) + (m * 60)
					local timr_end = time_cfg.round_end_time
					local h_end = math.floor(timr_end / 100)
					local m_end = math.floor(timr_end % 100)
					local end_time = TimeUtil.NowDayTimeStart(os.time()) + (h_end * 60 * 60) + (m_end * 60)
					if next_day then
						open_time = open_time + (24 * 60 * 60)
						end_time = end_time + (24 * 60 * 60)
					end
					if open_time > os.time() or end_time <= os.time() then
						is_reach_limint = false
					else
						is_reach_limint = true
					end
				else
					is_reach_limint = true
				end
			end

		end
		local flag = is_reach_limint and is_reach_vipexp and ActivityData.Instance:GetIsOpenLevel(act_type) and activity_info and activity_info.status ~= ACTIVITY_STATUS.CLOSE
		return flag
	end
end

function MainUIView:IsOpenLianFuDuoCheng(act_type)
	local time_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local residue_time = ActivityData.Instance:GetResidueTime(ACTIVITY_TYPE.KF_GUILDBATTLE)
	if time_day > LianFuDuoChengOpenDay + residue_time then
		return false
	end
	local activity_info = ActivityData.Instance:GetActivityStatuByType(act_type)
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.KF_GUILDBATTLE) then
		if activity_info then
			activity_info.status = ACTIVITY_STATUS.CLOSE
		end
		return false
	end
	if ActivityData.Instance:GetRealOpenDay(ACTIVITY_TYPE.KF_GUILDBATTLE) then
		return activity_info and activity_info.status ~= ACTIVITY_STATUS.CLOSE
	end
end

function MainUIView:IsOpenMeiRiDanBi(act_type)
	if ActivityData.Instance:GetActivityStatuByType(act_type) and ActivityData.Instance:GetActivityStatuByType(act_type).status == ACTIVITY_STATUS.OPEN then
		local act_info = ActivityData.Instance:GetActivityInfoById(act_type)
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		if act_info.min_level ~= nil and act_info.min_level <= main_role_vo.level then
			return true
		end
	end
	return false
end

function MainUIView:IsOpenCrossActivity(act_type)
	local activity_info = ActivityData.Instance:GetCrossRandActivityStatusByType(act_type)
	return activity_info and activity_info.status ~= ACTIVITY_STATUS.CLOSE
end

function MainUIView:OpenOneYuanSnatchView()
	ViewManager.Instance:Open(ViewName.OneYuanSnatchView)
end

function MainUIView:ShowXianShiDuiHuan()
	if self.left_icon_group and ExchangeData and ExchangeData.Instance then
		local is_shengwang_has_xianshi = ExchangeData.Instance:IsHasXianShi(2, 2)
		local is_rongyao_has_xianshi = ExchangeData.Instance:IsHasXianShi(2, 8)
		self.left_icon_group:ShowXianShiDuiHuan("exchange", is_shengwang_has_xianshi or is_rongyao_has_xianshi)
	end
end

function MainUIView:ShowArenaJueBanYuyi()
	if self.top_icon_group_1 then
		local is_show_arena = ArenaData.Instance:GetArenaMainuiShow()
		local bundle, asset = ResPath.GetImages("label_status_juebanwing")
		self.top_icon_group_1:ShowXianShiDuiHuan("arenaactivityview", is_show_arena, bundle, asset)
	end
end

function MainUIView:ShowGiftLimitBuyXianShi()
	if self.top_icon_group_2 then
		local is_show_xianshi = GiftLimitBuyData.Instance:GetGiftLimitBuyMainuiShow()
		local bundle, asset = ResPath.GetImages("label_status_xianshi3")
		self.top_icon_group_2:ShowXianShiDuiHuan("GiftLimitBuy",is_show_xianshi, bundle, asset)
	end
end

function MainUIView:ShowXianShiChallenge()
	if self.top_icon_group_1 then
		local rest_times = FuBenData.Instance:GetLastTime() or 0
		local bundle, asset = ResPath.GetImages("label_status_xianshichallenge")
		local is_not_click_fuben = FuBenData.Instance:GetIsNotClickFuBen()
		local flag = rest_times > 0 and is_not_click_fuben 
		self.top_icon_group_1:ShowXianShiDuiHuan("fuben", flag, bundle, asset)
	end
end

function MainUIView:ShowFreeGift()
	if self.top_icon_group_2 then
		local is_show_label = FreeGiftData.Instance:GetFreeGiftSign()
		local bundle, asset = ResPath.GetImages("label_status_xianshi2")
		self.top_icon_group_2:ShowXianShiDuiHuan("ZeroGift", is_show_label, bundle, asset)
	end
end

function MainUIView:ShowFourGradeEquipXianshi()
	if self.top_icon_group_2 then
		local is_show_label = FourGradeEquipData.Instance:GetFourGradeIconFirstOpen()
		local bundle, asset = ResPath.GetImages("label_status_xianshi3")
		self.top_icon_group_2:ShowXianShiDuiHuan("FourGradeEquipView", is_show_label, bundle, asset)
	end
end

function MainUIView:ShowOneYuanBuyXianShi()
	if self.top_icon_group_2 then
		local is_show_label = OneYuanBuyData.Instance:GetOneYuanBuyFirstOpen()
		local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ONEYUANBUYVIEW)
		local bundle, asset = ResPath.GetImages("label_status_xianshi2")
		self.top_icon_group_2:ShowXianShiDuiHuan("OneYuanBuy", is_show_label and is_open, bundle, asset)
	end
end

function MainUIView:ShowTeHuiDiscountShop()
	if not OpenFunData.Instance:CheckIsHide("shopview") then
		return
	end
	if self.left_icon_group then
		local is_show_label = ShopData.Instance:GetShopTeHuiRemind()
		local bundle, asset = ResPath.GetImages("label_status_tehui")
		self.left_icon_group:ShowXianShiDuiHuan("shopview", is_show_label > 0, bundle, asset)
	end
end

function MainUIView:ShowIconGroup2Effect(name, flag)
	if self.top_icon_group_2 then
		self.top_icon_group_2:ShowEffect(name, flag)
	end
end

--按钮显示隐藏条件（加特效）
function MainUIView:IsOpenActivityShowEffect(act_type, name, i)
	local TopIconGroup = {
		[1] = self.top_icon_group_1,
		[2] = self.top_icon_group_2,
		[3] = self.top_icon_group_3,
	}
	local activity_info = ActivityData.Instance:GetActivityStatuByType(act_type)
	local is_open = activity_info and activity_info.status ~= ACTIVITY_STATUS.CLOSE or false
	local is_show = MainuiActivityHallData.Instance:GetMainShowOnceEff(act_type)
	local remind_name = MainuiActivityHallData.DelayRemindList[act_type]

	local day_remind = false
	if act_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOOP_CHARGE_2 and LoopChargeData.Instance:CheckRemind() > 0 then
		is_show = true
	elseif act_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_NICHONGWOSONG and HuanzhuangShopData.Instance:ShowTitleShopPoint() > 0 then
		is_show = true
	elseif act_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CORNUCOPIA and JuBaoPenData.Instance:IsShowRedPoint() > 0 then
		is_show = true
	elseif act_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_2 and FastChargingData.Instance:ShowFastChargingPoint() > 0 then
		is_show = true
	elseif act_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_GIFT and IncreaseCapabilityData.Instance:GetIncreaseCapabilityRemind() > 0 then
		is_show = true
	elseif act_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_3 and IncreaseSuperiorData.Instance:ShowIncreaseSuperiorPoint() > 0 then
		is_show = true
	elseif act_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RECHARGE_CAPACITY and RechargeCapacityData.Instance:ShowRechargeCapacityPoint() > 0 then
		is_show = true
	elseif act_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP and HuanzhuangShopData.Instance:ShowHuanZhuangShopPoint() > 0 then
		is_show = true
	end
	if remind_name then
		day_remind = RemindManager.Instance:GetOnceADayRemindList(remind_name)
	end
	if TopIconGroup[i] then
		TopIconGroup[i]:ShowEffect(name, is_open and is_show and not day_remind)
	end

	if activity_info == nil then
		return
	end
	
	if act_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CORNUCOPIA and activity_info.status ~= ACTIVITY_STATUS.CLOSE then
		local cur_lun = JuBaoPenData.Instance:GetRewardLun()
		local price, max_gold = JuBaoPenData.Instance:GetNeedChargeByLun(cur_lun)

		if max_gold == 0 then
			is_open = false
		else
			is_open = true
		end
	end

	if act_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP then
		local current_vip_id = GameVoManager.Instance:GetMainRoleVo().vip_level
		local passlevel_consume = VipData.Instance:GetVipExp(current_vip_id - 1)
		local current_exp = VipData.Instance:GetVipInfo()
		local vip_other_cfg = VipData.Instance:GetVipWeekGiftCfg()
		if vip_other_cfg and vip_other_cfg.time_display_money and current_exp and current_exp.vip_exp and passlevel_consume then
			local vip_exp = passlevel_consume + current_exp.vip_exp
			if vip_exp < vip_other_cfg.time_display_money then
				return false
			end
		end
	end

	return ActivityData.Instance:GetIsOpenLevel(act_type) and is_open
end

function MainUIView:IsOpenRandActivity(act_type)
	return ActivityData.Instance:GetActivityIsOpen(act_type)
end

function MainUIView:IsOpenFunction(func_name)
	return OpenFunData.Instance:CheckIsHide(func_name) and not IS_AUDIT_VERSION
end

function MainUIView:IsOpenArenaFunction()
	local arena_show = ArenaData.Instance:GetArenaOpenOrNot()
	if not arena_show then
		return false
	end
	return OpenFunData.Instance:CheckIsHide("arenaactivityview")
end

function MainUIView:IsOpenKFArenaFunction()
	local arena_show = ArenaData.Instance:GetArenaOpenOrNot()
	if not arena_show then
		return OpenFunData.Instance:CheckIsHide("kfarenaactivityview")
	else
		return false
	end
end

function MainUIView:IsOpenMoLongMibao(func_name)
	if OpenFunData.Instance:CheckIsHide(func_name) then
		return MolongMibaoData.Instance:IsOpenMoLongMiBao()
	else
		return false
	end
end

function MainUIView:IsShowGroup2Act(func_name, index)
	return self:IsOpenFunction(func_name)
end

function MainUIView:IsOpenRechargeIcon(times)
	return DailyChargeData.Instance:GetThreeRechargeOpen(times)
end

function MainUIView:IsOpenZeroGift()
	return OpenFunData.Instance:CheckIsHide("zero_gift") and FreeGiftData.Instance:CanShowZeroGift()
end

function MainUIView:OpenOneYuanBuyView()
	ViewManager.Instance:Open(ViewName.OneYuanBuyView)
end

function MainUIView:IsOpenOneYuanBuy()
	local is_level_reach = ActivityData.Instance:GetIsOpenLevel(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ONEYUANBUYVIEW)
	if not is_level_reach then
		return false
	end
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ONEYUANBUYVIEW)
	local is_all_buy = OneYuanBuyData.Instance:GetIsShowOneYuanBuyData()
	if is_open then
		return is_all_buy
	else
		local is_no_buy = OneYuanBuyData.Instance:GetIsNoBuy()
		if is_no_buy then
			return false
		else
			return is_all_buy
		end
	end
end

function MainUIView:IsOpenRebate()
	local history_recharge = DailyChargeData.Instance:GetChongZhiInfo().history_recharge or 0
	local is_show = is_show or RebateCtrl.Instance:GetBuyState()
	local count_down_time = RebateCtrl.Instance:GetCloseTime() - TimeCtrl.Instance:GetServerTime()
	return history_recharge >= DailyChargeData.GetMinRecharge() and is_show and OpenFunData.Instance:CheckIsHide("rebateview") and count_down_time > 0
end

function MainUIView:IsOpenImageSkill()
	local history_recharge = DailyChargeData.Instance:GetChongZhiInfo().history_recharge or 0
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local is_show = is_show or ImageSkillCtrl.Instance:GetBuyState()
	local open_day_cfg = ImageSkillData.Instance:GetBaiBeiItemCfg()
	local open_day = open_day_cfg and open_day_cfg.baibeifanli_price_2_openday or 4
	local end_day = open_day_cfg and open_day_cfg.baibeifanli_end_time_2 or 7
	return (cur_day < end_day and cur_day >= open_day) and history_recharge >= DailyChargeData.GetMinRecharge() and is_show and OpenFunData.Instance:CheckIsHide("imageskillview")
end

function MainUIView:IsOpenGiftLimitBuy()
	local is_show = GiftLimitBuyData.Instance:IsOpenGiftLimitBuy()
	return is_show
end

function MainUIView:IsOpenTianShuView()
	local is_show = OpenFunData.Instance:CheckIsHide("tianshuview")
	local is_open = TianShuData.Instance:IsOpenTianShu()
	return is_show and is_open
end

function MainUIView:IsOpenImmortal()
	local is_show = OpenFunData.Instance:CheckIsHide("Immortal")
	-- self.node_list["ImmortalBtn"]:SetActive(is_show)
	return is_show
end

function MainUIView:IsOpenSevenDayLogin()
	if not self:IsOpenFunction("logingift7view") then
		return false
	end
	local gift_info = LoginGift7Data.Instance:GetGiftInfo()
	if gift_info and gift_info.account_total_login_daycount and gift_info.account_total_login_daycount < 7 then
		return true
	end

	local is_all_fetch_ed = true
	for i = 1, 7 do
		if not LoginGift7Data.Instance:GetLoginRewardFlag(i) then
			is_all_fetch_ed = false
			break
		end
	end
	return not is_all_fetch_ed
end

function MainUIView:IsOpenKaifuAct()
	local is_open_kaifu = OpenFunData.Instance:CheckIsHide("kaifuactivityview") and ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.OPEN_SERVER)
	local is_open_hefu = OpenFunData.Instance:CheckIsHide("kaifuactivityview") and ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.COMBINE_SERVER)

	return is_open_kaifu or is_open_hefu
end

function MainUIView:IsOpenFourGradeEquipView()
	return FourGradeEquipData.Instance:IsOpenFourGradeEquipView()
end

function MainUIView:IsOpenBossFbTouziAct()
	if KaifuActivityData and KaifuActivityData.Instance then
		local is_open_activity = OpenFunData.Instance:CheckIsHide("kaifuactivityview")
		local is_show = KaifuActivityData.Instance:IsShowTouZiIcon()
		return is_open_activity and is_show
	end
end

function MainUIView:IsOpenBanBenAct()
	local activity_num = #FestivalActivityData.Instance:GetOpenActivityList()
	if activity_num > 0 and self:IsOpenFunction("festivalactivityview") then 
		return true 
	else
		return false
	end
end

function MainUIView:IsOpenExpense()
	local is_open_kaifu = OpenFunData.Instance:CheckIsHide("kaifuactivityview") 
	local is_show_kaifu_icon = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.COMBINE_SERVER) or ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.OPEN_SERVER)
	return is_open_kaifu and not is_show_kaifu_icon
end

function MainUIView:IsOpenActHall(name)
	local hall_act = ActivityData.Instance:GetActivityHallDatalist()
	return #hall_act > 0 and self:IsOpenFunction("ActHall")
end

function MainUIView:IsOpenHuanZhuangShop()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP)
	return is_open and GameVoManager.Instance:GetMainRoleVo().level >= 130
end

function MainUIView:IsOpenNiChongWoSong()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_NICHONGWOSONG)
	return is_open and GameVoManager.Instance:GetMainRoleVo().level >= 130
end

function MainUIView:IsOpenWedding()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local lover_id = main_role_vo.lover_uid
	if lover_id and lover_id > 0 then
		local is_wedding = MarriageData.Instance:GetIsHoldingWeeding()
		if is_wedding then
			local is_marry_user = MarriageData.Instance:IsMarryUser()
			if is_marry_user then
				return true
			end
		end
	end
	return false
end

function MainUIView:IsOpenJinyinTa()
	return OpenFunData.Instance:CheckIsHide("JinYinTaView") and ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_JINYINTA)
end

function MainUIView:IsOpenZhenBaoGe()
	return OpenFunData.Instance:CheckIsHide("TreasureLoftView") and ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT)
end

function MainUIView:IsOpenZhuanZhuanLe()
	return OpenFunData.Instance:CheckIsHide("ZhuangZhuangLeView") and ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_LOTTERY_TREE)
end

-- 首冲、再充、三充面板
function MainUIView:OpenRechargeView()
	DailyChargeData.Instance:SetShowPushIndex(2)
	ViewManager.Instance:Open(ViewName.SecondChargeView)
end

-- 打开跨服六界界面
function MainUIView:OpenKuafuView()
	ViewManager.Instance:Open(ViewName.KuaFuBattle)
end

-- 跨服六界预览
function MainUIView:OpenKfLiuJiePreView()
	ViewManager.Instance:Open(ViewName.KuaFuLiuJiePre)
end

-- 跨服六界界面
function MainUIView:OpenThreeRechargeView()
	DailyChargeData.Instance:SetShowPushIndex(3)
	ViewManager.Instance:Open(ViewName.SecondChargeView)
end

-- 角色面板
function MainUIView:OnClickPlayer()
	ViewManager.Instance:Open(ViewName.Player, TabIndex.role_intro)
	TitleCtrl.Instance:SendCSGetTitleList()
end

-- 背包面板
function MainUIView:OnClickPackage()
	ViewManager.Instance:Open(ViewName.PackageView)
end

--宝具面板
function MainUIView:OnClickOpenMedal()
	--ViewManager.Instance:Open(ViewName.BaoJu, TabIndex.baoju_medal)
end

--锻造面板
function MainUIView:OnClickForge()
	ViewManager.Instance:Open(ViewName.Forge)
end

function MainUIView:OpenGiftLimitBuy()
	RemindManager.Instance:SetRemindToday(RemindName.GiftLimitBuy)
	ViewManager.Instance:Open(ViewName.GiftLimitBuy)
	self:ShowRebateButton()
end

--嘉年华
function MainUIView:OpenJiaNianHua()
	RemindManager.Instance:SetRemindToday(RemindName.MoLongMiBao2)
	-- self:ShowIconGroup2Effect("molongmibaoview", false)
	ViewManager.Instance:Open(ViewName.MolongMibaoView)
end

--天书寻主
function MainUIView:OpenTianShuView()
	ViewManager.Instance:Open(ViewName.TianShuView)
end

function MainUIView:OpenShenYuBossView()
	ViewManager.Instance:Open(ViewName.ShenYuBossView)
end

-- 形象面板
function MainUIView:OnClickAdvance()
	local default_open = AdvanceData.Instance:GetDefaultOpenView()
	if default_open == "mount_jinjie" then
		ViewManager.Instance:Open(ViewName.Advance,TabIndex.mount_jinjie)
	elseif default_open == "wing_jinjie" then
		ViewManager.Instance:Open(ViewName.Advance,TabIndex.wing_jinjie)
	elseif default_open == "fashion_jinjie" then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.fashion_jinjie)
	elseif default_open == "immortals_jinjie" then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.immortals_jinjie)
	elseif default_open == "weapon_jinjie" then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.weapon_jinjie)
	elseif default_open == "halo_jinjie" then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.halo_jinjie)
	elseif default_open == "fight_mount" then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.fight_mount)
	end
end

--女神面板
function MainUIView:OnClickGoddess()
	ViewManager.Instance:Open(ViewName.Goddess, TabIndex.goddess_info)
end

--公会面板
function MainUIView:OnClickGuild()
	local shake_state = GuildData.Instance:GetGuildChatShakeState()
	if shake_state then
		self:ShakeGuildChatBtn(false)
	end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if vo and vo.guild_id <= 0 then
		ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_request)
	else
		ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_info)
	end
end

--福利面板
function MainUIView:OnOpenWelfare()
	ViewManager.Instance:Open(ViewName.Welfare)
end

--福利面板
function MainUIView:OnOpenImmortalCard()
	ViewManager.Instance:Open(ViewName.ImmortalView)
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if cur_day > -1 then
		PlayerPrefsUtil.SetInt("Immortal" .. main_role_id, cur_day)
		self:ShowIconGroup2Effect("Immortal", false)
	end	
end

--神秘商店
function MainUIView:OnOpenSecretrShop()
	ViewManager.Instance:Open(ViewName.SecretrShopView)
end

--竞技场
function MainUIView:OpenJingJi()
	ViewManager.Instance:Open(ViewName.ArenaActivityView, TabIndex.arena_view)
end

--跨服竞技场
function MainUIView:OpenKFJingJi()
	ViewManager.Instance:Open(ViewName.KFArenaActivityView, TabIndex.kf_arena_view)
end

--告白墙面板
function MainUIView:OpenBiaoBaiQiang()
	ViewManager.Instance:Open(ViewName.BiaoBaiQiang)
end

-- 高战副本
function MainUIView:OpenGaoZhanFuBen()
	ViewManager.Instance:Open(ViewName.GaoZhanFuBen)
end

--排行榜面板
function MainUIView:OpenRank()
	local rank_ctrl = RankCtrl.Instance
	rank_ctrl:GetRankView():SetCurIndex(RANK_TAB_TYPE.ZHANLI)
	ViewManager.Instance:Open(ViewName.Ranking)
end

-- 打开副本面板
function MainUIView:OpenFuBen()
	local num = FuBenData.Instance:GetOpenToggleNum()
	if num and #num > 0 then
		ViewManager.Instance:Open(ViewName.FuBen, TabIndex.fb_phase)
	else
		ViewManager.Instance:Open(ViewName.FuBen, TabIndex.fb_exp)
	end
end

-- 打开累计充值面板
function MainUIView:OpenLeiJiChargeView()
	ViewManager.Instance:Open(ViewName.LeiJiRechargeView)
end

-- 打开活动卷轴
function MainUIView:OpenActivityHall()
	ViewManager.Instance:Open(ViewName.ActivityHall)
end

function MainUIView:OpenSevenRecharge()
	KaifuActivityData.Instance:LeiJiChongZhiSign()
	-- ViewManager.Instance:Open(ViewName.KaifuActivityView, 7)
	ViewManager.Instance:Open(ViewName.LeiJiRechargeView)
end

function MainUIView:OpenCrossGolb()
	KuaFuTargetCtrl.Instance:SendCrossGolbReq(CROSS_GOLB_OPERA_TYPE.CROSS_GOAL_INFO_REQ)
	ViewManager.Instance:Open(ViewName.KuaFuTargetView)
end

-- 打开社交面板
function MainUIView:OpenScoiety()
	if IS_ON_CROSSSERVER then
		ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
	else
		ViewManager.Instance:Open(ViewName.Scoiety)
	end
end

--市场
function MainUIView:OnClickMarket()
	ViewManager.Instance:Open(ViewName.Market)
end

--合成面板
function MainUIView:OpenCompose()
	ViewManager.Instance:Open(ViewName.Compose, TabIndex.compose_stone)
end

--活动面板
function MainUIView:OpenActivity()
	ViewManager.Instance:Open(ViewName.Activity, TabIndex.activity_daily)
end

--开服/合服活动面板
function MainUIView:OpenServerActiveView()
	ViewManager.Instance:Open(ViewName.HefuActivityView)
end

-- 幻装商城
function MainUIView:OpenHuanZhuangShopView()
	ViewManager.Instance:Open(ViewName.HuanZhuangShopView)
	HuanzhuangShopData.Instance:SetLoginFlag(false)
end

-- 你充我送
function MainUIView:OpenTitleShopView()
	ViewManager.Instance:Open(ViewName.TitleShopView)
	HuanzhuangShopData.Instance:SetLoginFlag(false)
end

--Boss
function MainUIView:OpenBossView()
	ViewManager.Instance:Open(ViewName.Boss)
end

--每日必做
function MainUIView:OnClickButtonDaily()
	ViewManager.Instance:Open(ViewName.BaoJu, TabIndex.baoju_zhibao_active)
end

--轻功
function MainUIView:OnClickButtonQingGong()
	self.skill_view:OnClickJump()
end

--兑换面板
function MainUIView:OnClickExchange()
	ExchangeCtrl.Instance:SendGetConvertRecordInfo()
	ExchangeCtrl.Instance:SendGetSocreInfoReq()
	local tab_index = ExchangeData.Instance:GetCanOpenTabIndex()
	ViewManager.Instance:Open(ViewName.Exchange, tab_index)
end

--商城面板
function MainUIView:OnClickShop()
	ViewManager.Instance:Open(ViewName.Shop, TabIndex.shop_youhui)
end

--跨服排行面板
function MainUIView:OpenCrossRank()
	ViewManager.Instance:Open(ViewName.CrossRankView)
end

--设置面板
function MainUIView:OnClickSetting()
	ViewManager.Instance:Open(ViewName.Setting, TabIndex.setting_xianshi)
end

function MainUIView:OnShrinkBtnValueChange(ison)
	MOVE_DIS_ISON = ison
	local max_move = self.node_list["TopButtonGroup1"].rect.rect.width + BTN_WIDTH/2
	for i = 1, 3 do
		local btn_group_list = self["top_icon_group_" .. i]:GetButtonList()
		local max_notween = 0 	--一直显示的按钮总数
		local move_num = 0 		--一直显示的但需要移动的按钮
		for k,v in pairs(btn_group_list) do
			v:SetActive(true)
			if ison == true then
				v:GetRootNode().canvas_group.alpha = 0
			end
			if v.cfg and v.cfg.move_and_show then
				move_num = move_num + 1
			end
			if v.cfg and v.cfg.is_tween == false then
				max_notween = max_notween + 1
			end
		end
		self:PlayBtnGroupAni(max_notween, move_num, btn_group_list, ison, max_move)
	end

	if self.node_list["ShrinkButton"].toggle.isOn == false then
		RemindManager.Instance:Bind(self.remind_change, RemindName.MainTop)
	else
		self.node_list["ImgRedPoint2"]:SetActive(false)
	end
end

--http://robertpenner.com/easing/easing_demo.html
function MainUIView:PlayBtnGroupAni(max_notween, move_num, btn_group_list, ison, max_move, min_move, delay_time)
	if nil == btn_group_list then
		return
	end
	local max_notween = max_notween
	local move_num = move_num
	local time = #btn_group_list * 0.1
	local move_dis = ison and -1 or 1
	local max_move = move_dis == -1 and max_move or max_move - (max_notween - move_num) * BTN_WIDTH
	local delay_time = delay_time or 0
	local num = 0
	local i = 0
	for k, v in pairs(btn_group_list) do
		local btn_root = v:GetRootNode()
		local min_move = min_move
		if nil == min_move then
			min_move = max_move - BTN_WIDTH * (#btn_group_list - num)
		end
		num = num + 1
		time = time - 0.1
		local move_vaule = move_dis == 1 and max_move or min_move
		if move_dis ~= -1 and v.cfg and v.cfg.is_tween == false then
			if v.cfg.move_and_show then
				local tween = btn_root.rect:DOAnchorPosX(move_vaule - BTN_WIDTH* (move_num - i), time)
				tween:SetEase(DG.Tweening.Ease.OutBack)
				tween:SetDelay(delay_time)
				i = i + 1
				tween:OnComplete(function()
					if k == 1 then
						if move_dis == 1 then
							self:SetBtnIsShow(btn_group_list)
						end
					end
			end)
		end
	else
		btn_root.button.interactable = ison
		local tween = btn_root.rect:DOAnchorPosX(move_vaule, time)
		tween:SetEase(DG.Tweening.Ease.OutBack)
		tween:SetDelay(delay_time)
		tween:OnUpdate(function()
			v:GetRootNode().canvas_group.alpha = ((max_move - min_move) - (v:GetRootNode().rect.anchoredPosition.x - min_move)) / (max_move - min_move)
			end)
			tween:OnComplete(function()
				if k == 1 then
					if move_dis == 1 then
						self:SetBtnIsShow(btn_group_list)
					end
				end
			end)
		end
	end
end

function MainUIView:SetBtnIsShow(btn_group_list)
	for k,v in pairs(btn_group_list) do
		if nil == v.cfg.is_tween or v.cfg.is_tween == true then
			v:SetActive(MOVE_DIS_ISON)
		end
	end
end

--寻宝面板
function MainUIView:OnClickTreasure()
	local index = TabIndex.treasure_choujiang
	if OpenFunData.Instance:CheckIsHide("zz_treasure") then
		index = TabIndex.treasure_choujiang3
	elseif OpenFunData.Instance:CheckIsHide("df_treasure") then
		index = TabIndex.treasure_choujiang2
	elseif OpenFunData.Instance:CheckIsHide("jp_treasure") then
		index = TabIndex.treasure_choujiang
	end
	ViewManager.Instance:Open(ViewName.Treasure, index)
end

--零元礼包
function MainUIView:OpenZeroGift()
	ViewManager.Instance:Open(ViewName.FreeGiftView)
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if cur_day > -1 then
		PlayerPrefsUtil.SetInt("zerogifteff_remind_day", cur_day)
	end
end

--新手经验瓶
function  MainUIView:OpenExpBottle()
	ViewManager.Instance:Open(ViewName.FriendExpBottleView)
end

--福利boss
function  MainUIView:OpenWelfareBoss()
	ViewManager.Instance:Open(ViewName.Boss, TabIndex.world_boss)
end

--娱乐
function  MainUIView:ClickYuLe()
	ViewManager.Instance:Open(ViewName.YuLeView)
end

--地图面板
function MainUIView:OpenMap()
	local scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if scene_cfg.smallmap_open and 1 == scene_cfg.smallmap_open then
		SysMsgCtrl.Instance:ErrorRemind(Language.Map.UnOpenInThisScene)
		return
	end
	ViewManager.Instance:Open(ViewName.Map)
end

--精灵面板
function MainUIView:OpenSpirit()
	ViewManager.Instance:Open(ViewName.SpiritView, TabIndex.spirit_spirit)
	SpiritCtrl.Instance:SendGetSpiritWarehouseItemListReq(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING)
	SpiritCtrl.Instance:SendGetSpiritScore()
end

-- 变身面板
function MainUIView:OpenBianShen()
	ViewManager.Instance:Open(ViewName.BianShenView)
end

--野外挂机面板
function MainUIView:OnYewaiGuaji()
	ViewManager.Instance:Open(ViewName.YewaiGuajiView)
end

--走棋子
function MainUIView:OpenGoPown()
	ViewManager.Instance:Open(ViewName.GoPawnView)
end

--结婚面板
function MainUIView:OpenMarriage()
	ViewManager.Instance:Open(ViewName.Marriage, TabIndex.marriage_honey)
end

--打开活动面板
function MainUIView:OpenActivityView(activity_type, name, index)
	if activity_type == ACTIVITY_TYPE.RAND_CORNUCOPIA then
		ViewManager.Instance:Open(ViewName.TreasureBowlView)
	elseif activity_type == ACTIVITY_TYPE.CLASH_TERRITORY then
		ViewManager.Instance:Open(ViewName.ClashTerritory)
	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CORNUCOPIA then
		ViewManager.Instance:Open(ViewName.JuBaoPen)
	elseif activity_type == ACTIVITY_TYPE.WEDDING then 							-- 婚宴
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		if main_role_vo.level >= WEDDING_ACTIVITY_LEVEL then
			MarriageCtrl.Instance:OpenDemandView()
		-- else
		-- 	SysMsgCtrl.Instance:ErrorRemind(Language.CrossTeam.Levellimit)
		end
	-- elseif activity_type == ACTIVITY_TYPE.GUILD_SHILIAN then
	-- 	if ActivityData.Instance:GetActivityIsOpen(activity_type) then
	-- 		local yes_func = function ()
	-- 			GuildMijingCtrl.SendGuildFbEnterReq()
	-- 		end
	-- 		TipsCtrl.Instance:ShowCommonAutoView("", str or Language.Guild.GuildActivityTips[activity_type], yes_func)
	-- 	else
	-- 		local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	-- 		if guild_id > 0 then
	-- 			ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_activity)
	-- 		else
	-- 			ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_request)
	-- 		end
	-- 	end
	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_RMB_BUY_COUNT_SHOP then
		self:OnOpenSecretrShop()
	elseif activity_type == ACTIVITY_TYPE.RAND_DAY_DANBI_CHONGZHI then
		ViewManager.Instance:Open(ViewName.KaifuActivityView, 61)
	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WEEKENDHAPPY then
		ViewManager.Instance:Open(ViewName.Weekend_HappyView)
	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP then
		-- RemindManager.Instance:SetRemindToday(RemindName.ShowHuanZhuangShopPoint)
		self:OpenHuanZhuangShopView()
	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOOP_CHARGE_2 then
		ViewManager.Instance:Open(ViewName.LoopChargeView)
	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_2 then
		RemindManager.Instance:SetRemindToday(RemindName.SingleChange)
		ViewManager.Instance:Open(ViewName.FastCharging)
	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_GIFT then
		ViewManager.Instance:Open(ViewName.IncreaseCapabilityView)
	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_3 then
		ViewManager.Instance:Open(ViewName.IncreaseSuperiorView)
	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RECHARGE_CAPACITY then
		ViewManager.Instance:Open(ViewName.RechargeCapacity)
	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PROFESS_RANK then
		-- ViewManager.Instance:Open(ViewName.BiaoBaiQiang)
		BiaoBaiQiangCtrl.Instance:OpenNanShenRank()
	elseif activity_type == ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_LIEKUN_FB then	-- 灵鲲之战
		ViewManager.Instance:Open(ViewName.LingKunBattleDetailView)
	-- elseif activity_type == ACTIVITY_TYPE.GONGCHENG_WORSHIP then 				-- 膜拜城主
	-- 	ViewManager.Instance:Open(ViewName.CityCombatView)
	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_NICHONGWOSONG then	-- 你充我送
		self:OpenTitleShopView()
	elseif activity_type == ACTIVITY_TYPE.KF_MONTH_BLACK_WIND_HIGHT then
		ViewManager.Instance:Open(ViewName.ShenYuBossView, TabIndex.shenyu_zhengbao)
	elseif activity_type == ACTIVITY_TYPE.KF_TUANZHAN then
		ViewManager.Instance:Open(ViewName.ShenYuBossView, TabIndex.nuzhan_jiuxiao)
	elseif activity_type == ACTIVITY_TYPE.KF_LUANDOUBATTLE then
		ViewManager.Instance:Open(ViewName.ShenYuBossView, TabIndex.luandou_zhanchang)
	elseif activity_type == ACTIVITY_TYPE.RAND_SINGLE_CHARGE then
		ViewManager.Instance:Open(ViewName.KaifuActivityView, 24)
	elseif activity_type == ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_BIANJING_ZHIDI then
		ViewManager.Instance:Open(ViewName.Map, TabIndex.map_world)
	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LIWUSHOUGE then
		local panel_index = FestivalActivityData.Instance:GetActivityTypeToIndex(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LIWUSHOUGE)
		ViewManager.Instance:Open(ViewName.FestivalView, panel_index)	-- 礼物收割
		FestivalActivityCtrl.Instance:FlushChristmaGiftView()
	else
		ActivityCtrl.Instance:ShowDetailView(activity_type)
	end
	local is_show_special = true
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOOP_CHARGE_2 and LoopChargeData.Instance:CheckRemind() > 0 then
		is_show_special = false
	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_NICHONGWOSONG and HuanzhuangShopData.Instance:ShowTitleShopPoint() > 0 then
		is_show_special = false
	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CORNUCOPIA and JuBaoPenData.Instance:IsShowRedPoint() > 0 then
		is_show_special = false
	end

	if name then
	-- if name and activity_type ~= ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOOP_CHARGE_2 and activity_type ~= ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_NICHONGWOSONG then
		local TopIconGroup = {
			[1] = self.top_icon_group_1,
			[2] = self.top_icon_group_2,
			[3] = self.top_icon_group_3,
		}
		MainuiActivityHallData.Instance:SetMainShowOnceEff(activity_type, false)
		if TopIconGroup[index] and is_show_special then
			TopIconGroup[index]:ShowEffect(name, false)
		end
	end
end

function MainUIView:GetShenGeIconData()
	local data = {}

	if OpenFunData.Instance:CheckIsHide("rune") then
		table.insert(data, {
			func = "rune",
			res = "Icon_System_RUNE",
			callback = function ()
				ViewManager.Instance:Open(ViewName.Rune, TabIndex.rune_tower)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.Rune)
		})
	end


	-- if OpenFunData.Instance:CheckIsHide("img_fuling") then 				-- 屏蔽天赋
	-- 	table.insert(data, {
	-- 		func = "img_fuling",
	-- 		res = "Icon_System_ImageFuLing",
	-- 		callback = function ()
	-- 			ViewManager.Instance:Open(ViewName.ImageFuLing, TabIndex.img_fuling_talent)
	-- 		end,
	-- 		remind = RemindManager.Instance:GetRemind(RemindName.ImgFuLingGroup)
	-- 	})
	-- end
	if OpenFunData.Instance:CheckIsHide("appearance") then
		table.insert(data, {
			func = "appearance",
			res = "Icon_System_TheAppearance",
			callback = function ()
				ViewManager.Instance:Open(ViewName.AppearanceView)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.Appearance)
		})
	end

	-- if OpenFunData.Instance:CheckIsHide("bianshen") then
	-- 	table.insert(data, {
	-- 		func = "bianshen",
	-- 		res = "Icon_System_BianShen",
	-- 		callback = function ()
	-- 			ViewManager.Instance:Open(ViewName.BianShenView)
	-- 		end,
	-- 		remind = RemindManager.Instance:GetRemind(RemindName.BianShen)
	-- 	})
	-- end
	
	if OpenFunData.Instance:CheckIsHide("hunqi") then
		table.insert(data, {
			func = "hunqi",
			res = "Icon_System_HunQi",
			callback = function ()
				ViewManager.Instance:Open(ViewName.HunQiView)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.HunQi)

		})
	end

	if OpenFunData.Instance:CheckIsHide("shenbing") then
		table.insert(data, {
			func = "shenbing",
			res = "Icon_System_ShenBing",
			callback = function ()
				ViewManager.Instance:Open(ViewName.Shenqi, TabIndex.shenbing)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.ShenQi)
		})
	end

	if OpenFunData.Instance:CheckIsHide("shenshou") then
		table.insert(data, {
			func = "shenshou",
			res = "Icon_System_TheShenShou",
			callback = function ()
				ViewManager.Instance:Open(ViewName.ShenShou)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.ShenShouGroup)
		})
	end

	if OpenFunData.Instance:CheckIsHide("shengxiao_uplevel") then
		table.insert(data, {
			func = "shengxiao_uplevel",
			res = "Icon_System_XingZuo",
			callback = function ()
				ViewManager.Instance:Open(ViewName.ShengXiaoView, TabIndex.shengxiao_uplevel)
			end,
			remind = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.ACTIVITY_TYPE_XINGZUOYIJI) and RemindManager.Instance:GetRemind(RemindName.ShengXiao) + 1 or RemindManager.Instance:GetRemind(RemindName.ShengXiao)
		})
	end

	if OpenFunData.Instance:CheckIsHide("shengeview") then
		table.insert(data, {
			func = "shengeview",
			res = "Icon_System_TheShenGe",
			callback = function ()
				ViewManager.Instance:Open(ViewName.ShenGeView, TabIndex.shen_ge_inlay)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.ShenGe)

		})
	end
	
	if OpenFunData.Instance:CheckIsHide("shenyin") then
		table.insert(data, {
			func = "shenyin",
			res = "Icon_System_ShenYin",
			callback = function ()
				ViewManager.Instance:Open(ViewName.ShenYinView, TabIndex.shenyin_shenyin)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.ShenYin)
		})
	end

	if OpenFunData.Instance:CheckIsHide("TianshenhutiView") then
		table.insert(data, {
			func = "TianshenhutiView",
			res = "Icon_System_Tianshenhuti",
			callback = function ()
				ViewManager.Instance:Open(ViewName.TianshenhutiView, TabIndex.tianshenhuti_info)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.TianshenhutiGroud)
		})
	end

	if OpenFunData.Instance:CheckIsHide("mythview") then
		table.insert(data, {
			func = "mythview",
			res = "Icon_System_ShenHua",
			callback = function ()
				ViewManager.Instance:Open(ViewName.MythView, TabIndex.shenhua_pianzhang)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.MythView)
		})
	end

	if OpenFunData.Instance:CheckIsHide("symbol") then
		table.insert(data, {
			func = "symbol",
			res = "Icon_System_TheSymbol",
			callback = function ()
				ViewManager.Instance:Open(ViewName.Symbol, TabIndex.symbol_intro)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.Symbol)
		})
	end

	if OpenFunData.Instance:CheckIsHide("douqi_view") then
		table.insert(data, {
			func = "douqiview",
			res = "Icon_System_Douqi",
			callback = function ()
				ViewManager.Instance:Open(ViewName.DouQiView)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.DouQiView)
		})
	end

	if OpenFunData.Instance:CheckIsHide("xingxiang") then
		table.insert(data, {
			func = "xingxiang",
			res = "Icon_System_XingXiang",
			callback = function ()
				ViewManager.Instance:Open(ViewName.XingXiangView, TabIndex.xing_xiang)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.XingXiangGroud)
		})
	end
	return data
end

function MainUIView:GetButtonState()
	local state = false
	if self.node_list["ListChargeButton"] and self.node_list["ListChargeButton"].gameObject then
		state = self.node_list["ListChargeButton"].gameObject.activeInHierarchy
	end
	return state
end

function MainUIView:ClickChargeChange(index)
	local state = self.node_list["ListChargeButton"].gameObject.activeSelf
	self:PlayChargeChange(not state, index)
end

local charge_sequence = nil
function MainUIView:PlayChargeChange(state, index)
	if charge_sequence then
		charge_sequence:Kill()
	end
	charge_sequence = DG.Tweening.DOTween.Sequence()

	local tween = nil
	local tween2 = nil
	local tween3 = nil

	local times = 0.3

	local first_charge_unsee_x = -300
	local first_charge_see_x = -200
	local max_first_charge_move_x = 100

	local charge_button_group_unsee_x = -100
	local charge_button_group_see_x = 50
	local max_charge_button_move_x = 170

	local canvas_group1 = self.node_list["ButtonFirstCharge"].canvas_group
	local canvas_group2 = self.node_list["ChargeGroup"].canvas_group

	if index == 1 then
		if state then
			tween = self.node_list["ImgChargeIcon"].rect:DORotate(Vector3(0, 0, 90), times)
			tween2 = self.node_list["ButtonFirstCharge"].rect:DOAnchorPosX(first_charge_unsee_x, times)
			tween3 = self.node_list["ChargeGroup"].rect:DOAnchorPosX(charge_button_group_see_x, times)
		else
			tween = self.node_list["ImgChargeIcon"].rect:DORotate(Vector3(0, 0, 0), times)
			tween2 = self.node_list["ButtonFirstCharge"].rect:DOAnchorPosX(first_charge_see_x, times)
			tween3 =self.node_list["ChargeGroup"].rect:DOAnchorPosX(charge_button_group_unsee_x, times)
		end

		charge_sequence:Append(tween)
		charge_sequence:Insert(0, tween2)
		charge_sequence:Insert(0, tween3)

		charge_sequence:SetEase(DG.Tweening.Ease.Linear)
		charge_sequence:SetUpdate(true)

		charge_sequence:OnUpdate(function()
			canvas_group1.alpha = math.abs(first_charge_unsee_x - self.node_list["ButtonFirstCharge"].rect.anchoredPosition.x) / max_first_charge_move_x
			canvas_group2.alpha = math.abs(charge_button_group_unsee_x - self.node_list["ChargeGroup"].rect.anchoredPosition.x) / max_charge_button_move_x
		end)

		charge_sequence:OnComplete(function()
			canvas_group1.alpha = canvas_group1.alpha > 0.5 and 1 or 0
			canvas_group2.alpha = canvas_group2.alpha > 0.5 and 1 or 0
			self.node_list["ButtonFirstCharge"]:SetActive(not state)
			self.node_list["ListChargeButton"]:SetActive(state)
			RemindManager.Instance:Fire(RemindName.ChargeGroup)
		end)
	else
		if state then
			tween3 = self.node_list["ChargeGroup"].rect:DOAnchorPosX(charge_button_group_see_x, times)
		else
			tween3 =self.node_list["ChargeGroup"].rect:DOAnchorPosX(charge_button_group_unsee_x, times)
		end
		charge_sequence:Insert(0, tween3)
		charge_sequence:Append(tween)
		charge_sequence:SetEase(DG.Tweening.Ease.Linear)
		charge_sequence:SetUpdate(true)

		charge_sequence:OnUpdate(function()
			canvas_group2.alpha = math.abs(charge_button_group_unsee_x - self.node_list["ChargeGroup"].rect.anchoredPosition.x) / max_charge_button_move_x
		end)

		charge_sequence:OnComplete(function()
			canvas_group2.alpha = canvas_group2.alpha > 0.5 and 1 or 0
			self.node_list["ListChargeButton"]:SetActive(state)
			RemindManager.Instance:Fire(RemindName.ChargeGroup)
		end)
	end
end

function MainUIView:GetMarryIconData()
	local data = {}
	if OpenFunData.Instance:CheckIsHide("marriage") then
		table.insert(data, {
			name = "marriage",
			res = "Icon_System_Marrage",
			callback = function ()
				ViewManager.Instance:Open(ViewName.Marriage, TabIndex.marriage_honey)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.Marry)
		})
	end

	local is_has_xianshi = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BABYHALDOFF)
	if OpenFunData.Instance:CheckIsHide("MarryBaby") and MarriageData.Instance:IsMarred() then
		table.insert(data, {
			name = "MarryBaby",
			res = "Icon_System_BaoBao",
			limit = is_has_xianshi,
			callback = function ()
				if IS_ON_CROSSSERVER then
					SysMsgCtrl.Instance:ErrorRemind(Language.Common.CantOpenInCross)
					return
				end
				local baby_list = BaobaoData.Instance:GetListBabyData() or {}
				local count = #baby_list
				local index = TabIndex.marriage_baobao_bless
				if count > 0 then 
					index = TabIndex.marriage_baobao_att
				end
				ViewManager.Instance:Open(ViewName.MarryBaby , index)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.MarryBaoBao)
		})
	end

	if OpenFunData.Instance:CheckIsHide("petview") then
		table.insert(data, {
			name = "littlepet",
			res = "Icon_System_SmallPet",
			callback = function ()
				if IS_ON_CROSSSERVER then
					SysMsgCtrl.Instance:ErrorRemind(Language.Common.CantOpenInCross)
					return
				end
				ViewManager.Instance:Open(ViewName.LittlePetView)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.LittlePet)
		})
	end

	if OpenFunData.Instance:CheckIsHide("biaobaiqiang") then
		table.insert(data, {
			name = "biaobaiqiang", 
			res = "Icon_System_BiaoBaiQiang", 
			callback = function ()
				ViewManager.Instance:Open(ViewName.BiaoBaiQiang)
			end
			})
	end

	if OpenFunData.Instance:CheckIsHide("couplehomeview") then
		table.insert(data, {
			name = "spousehome", 
			res = "Icon_System_CoupleHomeView", 
			callback = function ()
				ViewManager.Instance:Open(ViewName.CoupleHomeView, TabIndex.couple_home_home)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.MarryHome)
		})
	end

	return data
end

--神域
function MainUIView:OnClickShenGe()
	local data = self:GetShenGeIconData()
	if data and #data > 1 then
		local btn = self.down_icon_group:GetIconByName("clothespress")
		self.res_icon_list:SetClickObj(btn.root_node, 2)
		self.res_icon_list:SetData(data)
	else
		if data[1] then
			data[1].callback()
		end
	end
end

-- 结婚组
function MainUIView:OnClickMarry()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CantOpenInCross)
		return
	end
	local data = self:GetMarryIconData()
	if #data > 1 then
		local btn = self.down_icon_group:GetIconByName("marriage")
		self.res_icon_list:SetClickObj(btn.root_node, 3)
		self.res_icon_list:SetData(data)
	else
		if data[1] then
			data[1].callback()
		end
	end
end

--充值
function MainUIView:OpenRecharge()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

--战场大厅
function MainUIView:OpenBattleField()
	ViewManager.Instance:Open(ViewName.BattleField)
end

-- 开服活动
function MainUIView:OpenNewServer()
	local list = KaifuActivityData.Instance:GetOpenActivityList()
	if nil == list[1] then
		return
	end 
	local activity_type = list[1].activity_type or 0
	local panel_index = KaifuActivityData.Instance:GetActivityTypeToIndex(activity_type)
	ViewManager.Instance:Open(ViewName.KaifuActivityView, panel_index)
end

function MainUIView:OpenCrazyHappyView()
	local list = CrazyHappyData.Instance:GetOpenActivityList()
	if nil == list[1] then
		return
	end
	local activity_type = list[1].activity_type or 0
	local panel_index = CrazyHappyData.Instance:GetActivityTypeToIndex(activity_type)
	ViewManager.Instance:Open(ViewName.CrazyHappyView, panel_index)
end

-- 斗气
function MainUIView:OpenDouQiView()
	ViewManager.Instance:Open(ViewName.DouQiView)
end

function MainUIView:IsOpenDouQiView()
	return OpenFunData.Instance:CheckIsHide("douqi_view") and not IS_AUDIT_VERSION
end

-- 四阶神装
function MainUIView:OpenFourGradeEquipView()
	ViewManager.Instance:Open(ViewName.FourGradeEquip)
end

-- BOSS、副本投资活动
function MainUIView:OpenBossFbTouziActView()
	local list = KaifuActivityData.Instance:GetTouziActivityList()
	if nil == list[1] then
		return
	end 
	local activity_type = list[1].activity_type or 0
	local panel_index = KaifuActivityData.Instance:GetActivityTypeToIndex(activity_type)
	ViewManager.Instance:Open(ViewName.TouziActivityView, panel_index)
end


-- 版本活动
function MainUIView:OpenBanBenServer()
	local list = FestivalActivityData.Instance:GetOpenActivityList()
	if nil == list[1] then
		return
	end
	local activity_type = list[1].activity_type or 0
	local panel_index = FestivalActivityData.Instance:GetActivityTypeToIndex(activity_type)
	ViewManager.Instance:Open(ViewName.FestivalView, panel_index)
end

--每日首充
function MainUIView:OpenDailyCharge()
	ViewManager.Instance:Open(ViewName.DailyChargeView)
end

--首充
function MainUIView:OpenFirstCharge()
	local active_flag1, fetch_flag1 = DailyChargeData.Instance:GetThreeRechargeFlag(1)
	local active_flag2, fetch_flag2 = DailyChargeData.Instance:GetThreeRechargeFlag(2)
	local active_flag3, fetch_flag3 = DailyChargeData.Instance:GetThreeRechargeFlag(3)
	--点击首冲到达哪一级别
	local show_push_index = 0
	if active_flag1 ~= 1 or fetch_flag1 ~= 1 then
		show_push_index = 1
	elseif active_flag2 ~= 1 or fetch_flag2 ~= 1 then
		show_push_index = 2
	elseif active_flag3 ~= 1 or fetch_flag3 ~= 1 then
		show_push_index = 3
	end
	DailyChargeData.Instance:SetShowPushIndex(show_push_index)
	ViewManager.Instance:Open(ViewName.SecondChargeView)
end

--百倍返利
function MainUIView:OpenRebate()
	ViewManager.Instance:Open(ViewName.RebateView)
	RemindManager.Instance:Fire(RemindName.Rebate)
	RebateData.Instance:SetFirstOpenTag(false)
	self.top_icon_group_2:ShowXianShiDuiHuan("rebateview", false)

	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if cur_day > -1 then
		PlayerPrefsUtil.SetInt("rebateview" .. main_role_id, cur_day)
		self:ShowIconGroup2Effect("rebateview", false)
	end
end

--形象秒杀
function MainUIView:OpenImageSkill()
	ViewManager.Instance:Open(ViewName.ImageSkillView)
	RemindManager.Instance:Fire(RemindName.ImageSkill)
	ImageSkillData.Instance:SetFirstOpenTag(false)
	self.top_icon_group_2:ShowXianShiDuiHuan("imageskillview", false)

	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if cur_day > -1 then
		UnityEngine.PlayerPrefs.SetInt("imageskillview" .. main_role_id, cur_day)
		self:ShowIconGroup2Effect("imageskillview", false)
	end
end

-- 转生
function MainUIView:OpenReincarnation()
	ViewManager.Instance:Open(ViewName.Player, TabIndex.role_reincarnation)
end

-- 进入婚宴
function MainUIView:EnterWedding()
	local fb_key = MarriageData.Instance:GetFbKey()
	MarriageCtrl.Instance:SendMarryOpera(HUNYAN_OPERA_TYPE.HUNYAN_OPERA_TYPE_JOIN_HUNYAN, 1)
end

--打开在线奖励
function MainUIView:OpenOnlineRewardView()
	ViewManager.Instance:Open(ViewName.OnLineReward)
end

--打开分线面板
function MainUIView:OpenLineView()
	ViewManager.Instance:Open(ViewName.Map)
end

function MainUIView:OpenBiPin()
	ViewManager.Instance:Open(ViewName.CompetitionActivity)
	RemindManager.Instance:Fire(RemindName.BiPin)
end
function MainUIView:OpenFanHuan()
		ViewManager.Instance:Open(ViewName.AdvancedReturn)
end
function MainUIView:OpenFanHuanTwo()
		ViewManager.Instance:Open(ViewName.AdvancedReturnTwo)
end

-- function MainUIView:ActOpenBiPin()
-- 	ViewManager.Instance:Open(ViewName.BiPingActivity)
-- end


function MainUIView:OpenRuneView()
	ViewManager.Instance:Open(ViewName.Rune, TabIndex.rune_tower)
end

function MainUIView:OpenSuitCollectView()
	ViewManager.Instance:Open(ViewName.SuitCollection, TabIndex.orange_suit_collect)
end

function MainUIView:OpenMarryMeView()
	ViewManager.Instance:Open(ViewName.MarryMe)
end

function MainUIView:OpenZhuanZhuanLe()
	ViewManager.Instance:Open(ViewName.ZhuangZhuangLe)
end

function MainUIView:OnClickSavePower()
	if not IS_AUDIT_VERSION then
		ViewManager.Instance:Open(ViewName.Unlock)
	end
end

function MainUIView:OpenJinYinTyView()
	ViewManager.Instance:Open(ViewName.JinYinTaView)
end

function MainUIView:OpenZhenBaoGeView()
	ViewManager.Instance:Open(ViewName.TreasureLoftView)
end

--屏蔽模式改变Nothing
function MainUIView:OnShieldModeChanged0()
	SettingData.Instance:SetSettingData(SETTING_TYPE.SHIELD_OTHERS, true, true)
	SettingData.Instance:SetSettingData(SETTING_TYPE.SHIELD_SAME_CAMP, false, true)
end

--屏蔽模式改变friend
function MainUIView:OnShieldModeChanged1()
	SettingData.Instance:SetSettingData(SETTING_TYPE.SHIELD_SAME_CAMP, true, true)
	SettingData.Instance:SetSettingData(SETTING_TYPE.SHIELD_OTHERS, false, true)
end

--屏蔽模式改变all
function MainUIView:OnShieldModeChanged2()
	SettingData.Instance:SetSettingData(SETTING_TYPE.SHIELD_OTHERS, false, true)
	SettingData.Instance:SetSettingData(SETTING_TYPE.SHIELD_SAME_CAMP, false, true)
end

-- 更新攻击模式
function MainUIView:UpdateAttackMode(mode)
	if self.player_view ~= nil then
		self.player_view:UpdateAttackMode(mode)
	end

	if self.main_auditversion_view ~= nil then
		self.main_auditversion_view:UpdateAttackMode(mode)
	end

end

-- 更新职业显示
function MainUIView:RoleChangeProf()
	if self.player_view ~= nil then
		self.player_view:RoleChangeProf()
	end
	if self.main_auditversion_view ~= nil then
		self.main_auditversion_view:RoleChangeProf(mode)
	end
end

-- 任务激活状态改变
function MainUIView:OnTaskRefreshActiveCellViews()

end

function MainUIView:ClearManualTime()
	if self.manual_guaji_timer then
		GlobalTimerQuest:CancelQuest(self.manual_guaji_timer)
		self.manual_guaji_timer = nil
	end
end

function MainUIView:SetGuajiManualState()
	self:ClearManualTime()
	self.manual_guaji_timer = GlobalTimerQuest:AddDelayTimer(function()
		local main_role = Scene.Instance:GetMainRole()
		if main_role and GuajiType.IsManualState and main_role.vo.move_mode ~= MOVE_MODE.MOVE_MODE_JUMP2 and not main_role:IsMove() then
			GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
		end
	end, 1)
end

-- 挂机模式改变
function MainUIView:OnAutoChanged(on)

	GuildCtrl.Instance:SetIsStopYunBiaoFollow(true)


	-- 不可以取消挂机
	local logic = Scene.Instance:GetSceneLogic()
	if logic and not logic:CanCancleAutoGuaji() then
		GuajiCache.guaji_type = GuajiType.Auto
		self:SetShowGuaJi()
		TipsCtrl.Instance:ShowSystemMsg(Language.Rune.CanNotCancleGuaji)
		return
	end

	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	if on and role_vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		self.node_list["AutoButton"].toggle.isOn = false
		self:SetShowGuaJi()
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CanNotGuajiInJump)
		return
	end
	if GuajiCache.guaji_type == GuajiType.Auto or GuajiType.IsManualState then
		GuajiType.IsManualState = false
		GuajiCtrl.Instance:StopGuaji()
	elseif GuajiCache.guaji_type == GuajiType.None then
		GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	else
		GuajiCtrl.Instance:StopGuaji()
	end
	self:SetShowGuaJi()
	GlobalEventSystem:Fire(MainUIEventType.MAINUI_CLEAR_TASK_TOGGLE)
end

function MainUIView:SetShowGuaJi()
	if self.node_list["Nodelsgj"] and self.node_list["NodeGuaji"] and self.node_list["NodeQuxiaoguaji"] then
		local none_bool = GuajiCache.guaji_type == GuajiType.Auto or GuajiCache.guaji_type == GuajiType.Monster
		-- self.node_list["Nodelsgj"]:SetActive(not none_bool and GuajiType.IsManualState)

		local show_guaji = not none_bool and not GuajiType.IsManualState
		-- local show_quxiaoguaji = none_bool or GuajiType.IsManualState

		self.node_list["Nodelsgj"]:SetActive(false)
		self.node_list["NodeGuaji"]:SetActive(show_guaji)
		self.node_list["NodeQuxiaoguaji"]:SetActive(not show_guaji)
	end
end

--显示或隐藏挂机按钮
function MainUIView:SetAutoVisible(state)
	self.node_list["AutoButton"]:SetActive(state)
end

function MainUIView:OnGuajiTypeChange(guaji_type)
	if self:IsRendering() then
		-- 不可以取消挂机
		local logic = Scene.Instance:GetSceneLogic()
		if logic and not logic:CanCancleAutoGuaji() then
			GuajiCache.guaji_type = GuajiType.Auto

			self:SetShowGuaJi()
			self.exp = 0
			self.exp_t = {}
			if self.get_exp_efficiency_timer == nil then
				self.get_exp_efficiency_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.OnGuajiGetEXP, self), 10)
			end
			return
		end
		self:SetShowGuaJi()
	end
	if guaji_type == GuajiType.Auto then
		self.exp = 0
		self.exp_t = {}
		if self.get_exp_efficiency_timer == nil then
			self.get_exp_efficiency_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.OnGuajiGetEXP, self), 10)
		end
	else
		if nil ~= self.get_exp_efficiency_timer then
			GlobalTimerQuest:CancelQuest(self.get_exp_efficiency_timer)
			self.get_exp_efficiency_timer = nil
		end
		self.node_list["ExpImage"]:SetActive(false)
	end
end

function MainUIView:OnGuajiGetEXP()
	if not OpenFunData.Instance:CheckIsHide("fb_exp") then
		return
	end

	if not self:IsOpen() or not self:IsLoaded() then
		return
	end

	local scene_id = Scene.Instance:GetSceneId()
	local scene_type = Scene.Instance:GetSceneType()
	if self.exp > 0 and (scene_type == SceneType.Common or scene_type == SceneType.RuneTower or scene_type == SceneType.ExpFb)
		and not BossData.Instance:IsSecretBossScene(scene_id) then
		table.insert(self.exp_t, self.exp)
		if #self.exp_t > 6 then
			table.remove(self.exp_t, 1)
		end

		local total_exp = 0
		for i = 1, 6 do
			total_exp = total_exp + (self.exp_t[i] or self.exp)
		end
		local result, unit = CommonDataManager.ConverNum2(total_exp)

		self.node_list["ExpImage"]:SetActive(true and not self.is_audit_hide)
		self.node_list["ExpText"].text.text = result
		self.node_list["WanText"].text.text = unit

		self.exp = 0
	else
		self.node_list["ExpImage"]:SetActive(false)
	end
end

function MainUIView:OnMainRoleEXPChange(reason, delta)
	if GuajiCache.guaji_type == GuajiType.Auto and reason == 1 then
		if self.exp then
			self.exp = self.exp + delta
		end
	end
end

function MainUIView:OnMainRoleRevive()
	HpBagData.Instance:SetIsShowRepdt(true)
	RemindManager.Instance:Fire(RemindName.HpBag)
end

function MainUIView:TeamTabChange(ison)
	if ison then
		if self.is_team_tab_on then
			ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
		end
	end
	self.is_team_tab_on = ison
end

function MainUIView:LeftTrackIsVisible()
	self.team_view:ReloadData()
end

function MainUIView:TeamButtonClick()
	self.team_view:ReloadData()
end

-- 切换信息面板显示
function MainUIView:ClickSwitch()
	if ViewManager.Instance:IsOpen(ViewName.DaFuHao) then
		self:SetViewState(true)
		self.MenuIconToggle.isOn = false

		if self.left_track_animator.isActiveAndEnabled then
			self.left_track_animator:SetBool("fade", false)
			self.task_tab_btn_animator:SetBool("fade", false)
			self.task_shrink_button_animator:SetBool("fade", false)
		end
		ViewManager.Instance:Close(ViewName.DaFuHao)
	else
		self:SetViewState(false)
		ViewManager.Instance:Open(ViewName.DaFuHao)
		if self.MenuIconToggle.isOn then
			self.MenuIconToggle.isOn = false
		end
	end
end

function MainUIView:GetMenuToggleState()
	if self.MenuIconToggle then
		return self.MenuIconToggle.isOn
	end
	return false
end

function MainUIView:UpdateShieldMode()
	local others = SettingData.Instance:GetSettingData(SETTING_TYPE.SHIELD_OTHERS)
	local camp = SettingData.Instance:GetSettingData(SETTING_TYPE.SHIELD_SAME_CAMP)
	local shield_mode_node_list = {
		self.node_list["BtnShield_Nothing"], 
		self.node_list["BtnShield_Friend"], 
		self.node_list["BtnShield_All"]
	}
	for i = 1, 3 do
		if not others and not camp then
			shield_mode_node_list[i]:SetActive(i == 3)
		elseif others then
			shield_mode_node_list[i]:SetActive(i == 1)
		else
			shield_mode_node_list[i]:SetActive(i == 2)
		end
	end
end

--显示或隐藏私聊提醒
function MainUIView:SetPriviteRemindVisible(value)
	self.is_private_remind = value
	self.node_list["PriviteRemind"]:SetActive(not IS_ON_CROSSSERVER and value)
end

-- 登录服
function MainUIView:OnConnectLoginServer()
	if IS_ON_CROSSSERVER then
		self.node_list["PriviteRemind"]:SetActive(false)
	end
	-- 进出跨服要在一定时间内屏蔽战力改变提醒（策划需求）
	self.can_show_cap_change = false 										-- 是否显示主界面战力变化提示
	if nil == self.delay_show_cap_timer then
		local function delay_function()
			self.can_show_cap_change = true
			self.delay_show_cap_timer = nil
		end
		self.delay_show_cap_timer = GlobalTimerQuest:AddDelayTimer(delay_function, self.delay_show_cap_change_time)
	end
end

function MainUIView:SetPriviteHead(info)
	if info then
		self.privite_id = info.role_id
		AvatarManager.Instance:SetAvatar(info.role_id, self.node_list["PriviteRaw"], self.node_list["PriviteRole"], info.sex, info.prof, false)
	end
end

function MainUIView:ShowPriviteRemind(info)
	self:SetPriviteRemindVisible(true)
	GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.SetPriviteHead, self, info), 0.1)
end

function MainUIView:OpenPrivite()
	if self.privite_id then
		ChatData.Instance:SetCurrentId(self.privite_id)
	end
	ViewManager.Instance:Open(ViewName.ChatGuild)
end

--七天登录奖励
function MainUIView:OpenSevenLogin()
	ViewManager.Instance:Open(ViewName.LoginGift7View)
end

function MainUIView:OnMenuIconToggleChange(is_on)
	if not is_on then
		if self.res_icon_list:IsOpen() then
			self.res_icon_list:Close()
		end
		
		self.chat_view:CloseIconListView()
		self.player_view:CloseActivityPreView()

		self:CheckRecordGuildShake()
		self:CheckExpBottleShake()
	end
	self.is_show_charge_panel = not self.MenuIconToggle.isOn
	self:CheckShouFirstChargeEff()
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON, not is_on)

	if ViewManager.Instance:IsOpen(ViewName.FbIconView) then
		self.is_show_map_info = is_on and not IS_ON_CROSSSERVER
		self.player_view:ShowRightBtns(is_on)
		self.target_view:ChangeToHigh(is_on)
		self.node_list["ShrinkButton"]:SetActive(self.is_show_map_info)
		self.node_list["RightPanel"]:SetActive(is_on and FuBenData.Instance:GetFbIsShowBossBtn() and not IS_ON_CROSSSERVER)
		self.map_view:SetShowTopBg(self.is_show_map_info)
	else
		self.node_list["ShrinkButton"].toggle.isOn = is_on
	end
	self.maintask_animator:SetBool("Show", not is_on)
	-- if self.skill_view then
	-- 	self.skill_view:SetJumpButIsShow(not is_on)
	-- end
	self.is_show_shrink_btns = self.show_switch and not is_on

	self.node_list["TopButtons"]:SetActive(self.is_show_map_info)
	self:SetJoystickIsShow(is_on)

	self:IsShowMarket()
end

--如果记录了self.record_guild_shake 为 true 就需要播放颤抖或停止颤抖
function MainUIView:CheckRecordGuildShake()
	if self.record_guild_shake == true then
		if self.guild_chat_count_down ~= nil then
			CountDown.Instance:RemoveCountDown(self.guild_chat_count_down)
			self.guild_chat_count_down = nil
		end
		self.guild_chat_count_down = CountDown.Instance:AddCountDown(0.1, 0.1, BindTool.Bind(self.GuildChatCountDown, self))
	end
end


function MainUIView:GuildChatCountDown(elapse_time, total_time)
	if total_time - elapse_time <= 0 then
		self.record_guild_shake = false
		self:ShakeGuildChatBtn(GuildData.Instance:GetGuildChatShakeState())
	end
end

function MainUIView:PortraitToggleChange(state, from_move, is_guide)
	if FunctionGuide.Instance:GetIsGuide() and not is_guide then
		--引导期间不接收任何处理（除引导外）
		return
	end
	if from_move and self.MenuIconToggle.isOn == state then
		return
	end
	if not self:IsRendering() then
		self.menu_toggle_state = state
		return
	end
	self.MenuIconToggle.isOn = state
	local scene_type = Scene.Instance:GetSceneType()
	if ViewManager.Instance:IsOpen(ViewName.FbIconView) or scene_type == SceneType.Kf_OneVOne then
		self.is_show_map_info = self.MenuIconToggle.isOn and not IS_ON_CROSSSERVER
		if scene_type == SceneType.Kf_OneVOne then
			self.is_show_map_info = false
		end
		self.node_list["TopButtons"]:SetActive(self.is_show_map_info)
		self.node_list["ShrinkButton"]:SetActive(self.is_show_map_info)
		self.map_view:SetShowTopBg(self.is_show_map_info)
		self.player_view:ShowRightBtns(self.MenuIconToggle.isOn)
		self.target_view:ChangeToHigh(self.MenuIconToggle.isOn)
	end
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON, not self.MenuIconToggle.isOn)
end

function MainUIView:HideMap(state)
	self.node_list["PanelMapContent"]:SetActive(not state)
end

function MainUIView:ShowGuildChatIcon(is_show)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local active = (is_show or true) and OpenFunData.Instance:CheckIsHide("chatguild")
	-- local guild_unread_msg = ChatData.Instance:GetGuildUnreadMsg()
	-- local guild_chat_remind = GuildChatData.Instance:GetGuildChatRemind()
	local is_show_remind = RemindManager.Instance:GetRemind(RemindName.GuildChatRed) or 0
	local is_show_point = active and is_show_remind >= 1
	self.node_list["ButtonGuildChat"]:SetActive(active)
	-- self.node_list["ImgRedPoint56"]:SetActive(is_show)
	self.chat_view:ShowGuildChatRedPt(is_show_point)
end

function MainUIView:ShowWelfareBossIcon(is_show)
	self.node_list["BtnBoss"]:SetActive(is_show)
end

function MainUIView:CheckRechargeIcon(is_show)
	self:AddToUpdateList(self.top_icon_group_2)
	self:AddToUpdateList(self.top_icon_group_3)
	self.player_view:FlushSetActiveMaayMe()
	self:AddToUpdateList(self.player_view)
end

function MainUIView:FlushGroup1Icon()
	if self.top_icon_group_1 then
		self:AddToUpdateList(self.top_icon_group_1)
	end
end

function MainUIView:CheckMoLongIcon()
	if self.top_icon_group_1 then
		self:AddToUpdateList(self.top_icon_group_1)
	end
end

function MainUIView:FlushIconGroupThree()
	if self.top_icon_group_3 then
		self:AddToUpdateList(self.top_icon_group_3)
	end
end

function MainUIView:FlushIconGroupPlayer()
	if self.player_view then
		self:AddToUpdateList(self.player_view)
	end
end

function MainUIView:MainRoleLevelChange()
	local main_role_lv = GameVoManager.Instance:GetMainRoleVo().level
	if main_role_lv < 60 then
		self.node_list["ShrinkButton"].toggle.isOn = true
	end
	self.node_list["BtnSavePower"]:SetActive(OpenFunData.Instance:CheckIsHide("SavePower"))
	self:RoleLevelChangeHandle()
end


--是否显示功能预告
function MainUIView:ChangeFunctionTrailer()
	if self.function_trailer then
		self.function_trailer:Flush()
	end
end

function MainUIView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if value then
		self:Flush("rendering")
	end
end

function MainUIView:SetRootNodeActive(value)
	if not value then
		self.old_root_node_pos = self.root_parent.transform.localPosition
		self.root_parent.transform.localPosition = Vector3(-100000, -100000, 0)
	else
		if nil ~= self.old_root_node_pos then
			self.root_parent.transform.localPosition = self.old_root_node_pos
			self.old_root_node_pos = nil
		end
	end
end

function MainUIView:FlushBeAtkIconState(role_vo)
	if self.reminding_view then
		self.reminding_view:SetBeAtkIconState(role_vo)
	end
end

function MainUIView:SetvisibleGath()
	if self.reminding_view then
		self.reminding_view:OnSetVisibleGath()
	end
end

function MainUIView:FlushAutoRotation(is_auto)
	if self.reminding_view then
		self.reminding_view:SetAutoRotation(is_auto)
	end
end

function MainUIView:SetFunctionTrailerState(state)
	
end

function MainUIView:TopRightVisible(state)
	state = tonumber(state)
	self.top_button_ani_state = state
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_TOP_RIGHT_BUTTON, state == 1)

	if state == 1 then
		if self.mark_down then
			GlobalTimerQuest:CancelQuest(self.mark_down)
			self.mark_down = nil
		end
		self.mark_down = GlobalTimerQuest:AddDelayTimer(function ()
			self:IsShowMarket(true)
		end, 0.25)
	else
		self:IsShowMarket(false)
	end
end

function MainUIView:GetPlayerButtonAniState()
	return self.top_button_ani_state
end

function MainUIView:RightButtonsVisible(state)
	state = tonumber(state)
	self.right_button_ani_state = state
end

function MainUIView:GetRightButtonsVisible()
	return self.right_button_ani_state
end

function MainUIView:ShowRebateButton(is_show)
	if self.top_icon_group_2 then
		self.top_icon_group_2:FlushIconGroup()
	end
end

function MainUIView:ShowImageSkillButton(is_show)
	if self.top_icon_group_2 then
		self.top_icon_group_2:FlushIconGroup()
	end
end


function MainUIView:SceneLoadComplete(old_scene_type, new_scene_type)
	self:ChangeMenuState()
	self.node_list["NodeSwithcBtn"]:SetActive(true)

	local open_line = PlayerData.Instance:GetAttr("open_line") or 0
	self.node_list["NodeLineButton"]:SetActive(open_line > 0)

	local scene_key = PlayerData.Instance:GetAttr("scene_key") or 0
	scene_key = scene_key + 1
	self.node_list["TxtLineName"].text.text = string.format(Language.Common.Line, scene_key)

	if self.delay_timer == nil then
		self.delay_timer = GlobalTimerQuest:AddDelayTimer(function()
			if SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_RECYCLE_EQUIP) then
				PackageData.Instance:SetRecyleDataList(true) -- 上线自动分解装备
			end
		end, 5)
	end

	self:ChangeFunctionTrailer()
end

function MainUIView:ChangeMenuState()
	if ViewManager.Instance:IsOpen(ViewName.FbIconView) then
		self.is_show_map_info = self.MenuIconToggle.isOn and not IS_ON_CROSSSERVER
		self.player_view:ShowRightBtns(self.MenuIconToggle.isOn)
		self.target_view:ChangeToHigh(self.MenuIconToggle.isOn)
	elseif ViewManager.Instance:IsOpen(ViewName.MountFuBenView)
		or ViewManager.Instance:IsOpen(ViewName.WingFuBenView)
		or ViewManager.Instance:IsOpen(ViewName.JingLingFuBenView) then
		self.is_show_map_info = false
	else
		self.is_show_map_info = true
		self.player_view:ShowRightBtns(true)
		self.target_view:ChangeToHigh(true)
	end
	local scene_type = Scene.Instance:GetSceneType()
	local show_chat_window = true
	if scene_type == SceneType.Kf_OneVOne or scene_type == SceneType.Field1v1 or scene_type == SceneType.KF_Arena then
		self.is_show_map_info = false
		show_chat_window = false
	end
	self.node_list["TopButtons"]:SetActive(self.is_show_map_info)
	self.node_list["ShrinkButton"]:SetActive(self.is_show_map_info)
	self.map_view:SetShowTopBg(self.is_show_map_info)
	self.node_list["ChatInfo"]:SetActive(show_chat_window)
	self.node_list["MenuIcon"]:SetActive(show_chat_window)

	self.skill_view:OnFlush({skill = true})
	self.main_auditversion_skill_control:OnFlush({skill = true})
end

function MainUIView:ClashTerritoryDataChangeCallback()
	self.skill_view:OnFlush({skill = true})
	self.main_auditversion_skill_control:OnFlush({skill = true})
end

function MainUIView:GetDaZhaoEffect()
	return self.node_list["DaZhaoEffect"]
end

function MainUIView:GetChengZhuSkill()
	return self.node_list["ChengZhuSkill"]
end

function MainUIView:GoddessSkillTipsClose()
	if self.skill_view then
		self.skill_view:OnFlush({goddess_skill_tips = true})
		self.main_auditversion_skill_control:OnFlush({goddess_skill_tips = true})
	end
end

function MainUIView:SetViewState(is_in)
	self.is_in_special_scene = is_in

	if self.node_list["NodeTaskParent"] and self.node_list["PanelChargeButton"] then
		self.node_list["NodeTaskParent"]:SetActive(self.is_show_task and (not self.is_in_task_talk) and self.is_in_special_scene and not self.is_audit_hide)
		if self.task_view and self.is_show_task and (not self.is_in_task_talk) and self.is_in_special_scene then
			self.task_view:DelaySortTask()
		end
		self.node_list["RightPanel"]:SetActive(self.is_show_task and (not self.is_in_task_talk) and self.is_in_special_scene and not IS_ON_CROSSSERVER)
		local open_chongzhi = GLOBAL_CONFIG.param_list.switch_list.open_chongzhi
		self.node_list["PanelChargeButton"]:SetActive(self.is_show_map_info and self.is_in_special_scene and not IS_AUDIT_VERSION and open_chongzhi)
	end

	if self.player_view then
		self.player_view:FlushSetActiveMaayMe(self.is_in_special_scene)
	end
	if self.left_track_animator and self.left_track_animator.isActiveAndEnabled then
		if self.MenuIconToggle then
			self.left_track_animator:SetBool("fade", false)
			self.task_tab_btn_animator:SetBool("fade", self.MenuIconToggle.isOn)
			self.task_shrink_button_animator:SetBool("fade", self.MenuIconToggle.isOn)
		else
			self.left_track_animator:SetBool("fade", false)
			self.task_tab_btn_animator:SetBool("fade", false)
			self.task_shrink_button_animator:SetBool("fade", false)
		end
	end
	if not is_in and self.MenuIconToggle then --临时修改!
		self.MenuIconToggle.isOn = not self.MenuIconToggle.isOn
		self.MenuIconToggle.isOn = not self.MenuIconToggle.isOn
	end
	if self.node_list["ShrinkButton"] then
		self.node_list["ShrinkButton"].toggle.isOn = true
	end
	if self.node_list["SmallButton"] then
		self.node_list["SmallButton"]:SetActive(not IS_ON_CROSSSERVER)
	end
	-- 跨服中上面的ChatButtonGroup隐藏了那么这开启用来队伍那块使用
	if self.node_list["CrossChatButtonGroup"] then
		self.node_list["CrossChatButtonGroup"]:SetActive(IS_ON_CROSSSERVER)
	end
	if self.node_list["ButtonRank"] then
		self.node_list["ButtonRank"]:SetActive(OpenFunData.Instance:CheckIsHide("ranking") and not IS_ON_CROSSSERVER)
	end
	if self.node_list["Buttonmarket"] and is_in then
		self.node_list["Buttonmarket"]:SetActive(not IS_ON_CROSSSERVER and not self.MenuIconToggle.isOn and not self:IsInArenaView())
	end
	if is_in then
		self:OnShrinkBtnValueChange(is_in)
	end

	-- 是否屏蔽神魔
	if self.skill_view then
		self.skill_view:FlushGeneralSkill(is_in)
	end

end
function MainUIView:IsShowMarket(is_on)
	if self.node_list["Buttonmarket"] and self.MenuIconToggle then
		local is_open = OpenFunData.Instance:CheckIsHide("market")
		self.node_list["Buttonmarket"]:SetActive(is_open and not IS_ON_CROSSSERVER and not self.MenuIconToggle.isOn and is_on and not self:IsInArenaView())
		if FuBenData.Instance and FuBenData.Instance:GetIsInFuBenScene() or BossData.IsBossScene() then
			self.node_list["Buttonmarket"]:SetActive(false)
		end
	end
end

function MainUIView:SetViewHideorShow(view_name, state)
	if not self.node_list[view_name] then return end

	self.node_list[view_name]:SetActive(state)
end

function MainUIView:SetShowTask(is_show)
	if self.task_view then
		self.is_show_task = is_show
		self.node_list["NodeTaskParent"]:SetActive(self.is_show_task and (not self.is_in_task_talk) and self.is_in_special_scene and not self.is_audit_hide)
		self.node_list["RightPanel"]:SetActive(self.is_show_task and (not self.is_in_task_talk) and self.is_in_special_scene and not IS_ON_CROSSSERVER)
		if is_show then
			self.task_view:DelaySortTask()
		end
	end
end

function MainUIView:SetAllViewState(switch)
	self:SetViewState(switch)
	if self.node_list["ButtonPackage"] then
		self.node_list["ButtonPackage"]:SetActive(switch)
	end
	if self.node_list["PlayerInfo"] then
		self.node_list["PlayerInfo"]:SetActive(switch)
	end
end

function MainUIView:SetPerfectEffct(bool)
	if self.player_view then
		self.player_view:IsPerfectLoverEffect(bool)
	end
end

function MainUIView:SetPlayerInfoState(switch)
	self.node_list["PlayerInfo"]:SetActive(switch)
end

function MainUIView:SetShowLoginGiftIcon(is_show)
	if self.node_list["ButtonSevenLogin"] then
		self.node_list["ButtonSevenLogin"]:SetActive(is_show)
	end
end

function MainUIView:SetShowExpBottle(is_show)
	self.node_list["ExpBottleButton"]:SetActive(false)
end

function MainUIView:SetWeddingTime()
	local leave_time = MarriageData.Instance:GetWeedingTime()
	if leave_time <= 0 then
		return
	end
	local function timer_func(elapse_time, total_time)
		if total_time - elapse_time <= 0 then
			self:StopWeddingTime()
			return
		end

		local icon = self.top_icon_group_3:GetIconByName("MarryWedding")
		if icon then
			local time_str = TimeUtil.FormatSecond(total_time - elapse_time, 2)
			icon:SetTimeText(time_str)
		end
	end
	self.wedding_count_down = CountDown.Instance:AddCountDown(leave_time, 1, timer_func)
end

function MainUIView:StopWeddingTime()
	if self.wedding_count_down then
		CountDown.Instance:RemoveCountDown(self.wedding_count_down)
		self.wedding_count_down = nil
	end
end

function MainUIView:ChangeWeddingState()
	self:StopWeddingTime()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local lover_id = main_role_vo.lover_uid
	if lover_id and lover_id > 0 then
		local is_wedding = MarriageData.Instance:GetIsHoldingWeeding()
		if is_wedding then
			local is_marry_user = MarriageData.Instance:IsMarryUser()
			if is_marry_user then
				self:SetWeddingTime()
			end
		end
	end
end

function MainUIView:WorldLevelChangeHandle()
	local is_show_btn = BuyExpData.Instance:GetExpRefineIsOpen()
	MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.BuyExp, is_show_btn)
end

function MainUIView:RoleLevelChangeHandle()
	local is_show_btn = BuyExpData.Instance:GetExpRefineIsOpen()
	MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.BuyExp, is_show_btn)
	self:FlushZhuZhan()
	RemindManager.Instance:Fire(RemindName.ShenmiShop)
end

function MainUIView:HefuActivityChangeHandle()
	local is_show_btn = BuyExpData.Instance:GetExpRefineIsOpen()
	MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.BuyExp, is_show_btn)
end

function MainUIView:GetSkillButtonPosition()
	if self.skill_view then
		return self.skill_view:GetSkillButtonPosition()
	end
end

function MainUIView:GetMainAuditSkillButtonPosition()
	if self.main_auditversion_skill_control then
		return self.main_auditversion_skill_control:GetSkillButtonPosition()
	end
end

function MainUIView:SetButtonVisible(key, is_show)
	if key == "zero_gift" or key == "four_grade_equip" or key == "oneyuan_buy" or key == "tianshuview" then
		if self.top_icon_group_2 then
			self.top_icon_group_2:FlushIconGroup()
		end
		return
	end

	if key == "GiftLimitBuy" then
		if self.top_icon_group_2 then
			self.top_icon_group_2:FlushIconGroup()
		end
		return
	end

	if key == MainUIData.RemindingName.MolongMibao then
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.SendFashion, OpenFunData.Instance:CheckIsHide("molongmibaoview") and (is_show or self:SpecActIsOpen(key)))
	end
end

function MainUIView:SpecActIsOpen(key)
	if key == MainUIData.RemindingName.ExpRefine then
		return ExpRefineData.Instance:GetExpRefineIsOpen()
	end
	return false
end

local ActRemindNameT = {
	[ACTIVITY_TYPE.GONGCHENGZHAN] = MainUIData.RemindingName.CityCombat,
	[ACTIVITY_TYPE.RAND_CORNUCOPIA] = MainUIData.RemindingName.TreasureBowl,
	[ACTIVITY_TYPE.TOMB_EXPLORE] = MainUIData.RemindingName.TombExplore,
	[ACTIVITY_TYPE.KF_XIULUO_TOWER] = MainUIData.RemindingName.XiuLuoTower,
	[ACTIVITY_TYPE.KF_HOT_SPRING] = MainUIData.RemindingName.Cross_Hot_Spring,
	[ACTIVITY_TYPE.KF_FARMHUNTING] = MainUIData.RemindingName.CrossFarmHunting,
	[ACTIVITY_TYPE.BIG_RICH] = MainUIData.RemindingName.Big_Rich,
	[ACTIVITY_TYPE.NIGHT_FIGHT_FB] = MainUIData.RemindingName.KFNightFight,
	[ACTIVITY_TYPE.HUSONG] = MainUIData.RemindingName.Double_Escort,
	[ACTIVITY_TYPE.KF_ONEVONE] = MainUIData.RemindingName.Cross_One_Vs_One,
	[ACTIVITY_TYPE.CLASH_TERRITORY] = MainUIData.RemindingName.Clash_Territory,
	[ACTIVITY_TYPE.GUILDBATTLE] = MainUIData.RemindingName.Guild_Battle,
	[ACTIVITY_TYPE.TIANJIANGCAIBAO] = MainUIData.RemindingName.Fall_Money,
	[ACTIVITY_TYPE.QUNXIANLUANDOU] = MainUIData.RemindingName.Element_Battle,
	[ACTIVITY_TYPE.GUILD_SHILIAN] = MainUIData.RemindingName.GuildMijing,
	[ACTIVITY_TYPE.GUILD_BONFIRE] = MainUIData.RemindingName.GuildBonfire,
	[ACTIVITY_TYPE.GUILD_BOSS] = MainUIData.RemindingName.GuildBoss,
	[ACTIVITY_TYPE.SHUIJING] = MainUIData.RemindingName.CrossCrystal,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_REFINE] = MainUIData.RemindingName.ExpRefine,
	[ACTIVITY_TYPE.MARRY_ME] = MainUIData.RemindingName.MarryMe,
	[ACTIVITY_TYPE.CHAOSWAR] = MainUIData.RemindingName.YiZhanDaoDi,
	[ACTIVITY_TYPE.RAND_LOTTERY_TREE] = MainUIData.RemindingName.ZhuanZhuanLe,
	[ACTIVITY_TYPE.RAND_JINYINTA] = MainUIData.RemindingName.JinYinTa,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT] = MainUIData.RemindingName.ZhenBaoGe,
	[ACTIVITY_TYPE.KF_TUANZHAN] = MainUIData.RemindingName.CrossTuanZhan,
	[ACTIVITY_TYPE.KF_MONTH_BLACK_WIND_HIGHT] = MainUIData.RemindingName.KFDarkNight,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOOP_CHARGE_2] = MainUIData.RemindingName.LoopCharge2,
	[ACTIVITY_TYPE.RAND_ACTIVITY_RMB_BUY_COUNT_SHOP] = MainUIData.RemindingName.SecretrShop,
}

function MainUIView:UpdateGuildOpenTips()
	if self.chat_view and ActivityData.Instance then
		local is_open_guild_answer = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GUILD_ANSWER)
		local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
		if guild_id and guild_id <= 0 then
			self.chat_view:SetGuildOpenTipsActive(false)
			return
		end
		self.chat_view:SetGuildOpenTipsActive(is_open_guild_answer)
	end	
end

function MainUIView:ActivityChangeCallBack(activity_type, status, next_time, open_type)
	if activity_type == ACTIVITY_TYPE.GUILD_ANSWER then
		self:UpdateGuildOpenTips()
	end

	local act_cfg = ActivityData.Instance:GetActivityConfig(activity_type)
	if act_cfg and act_cfg.is_inscroll == 1 then
		return 
	end
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_IMMORTAL_FOREVER then
		self:FlushImmortalLabel()
		return
	end
	if status ~= ACTIVITY_STATUS.CLOSE then
		local level = PlayerData.Instance.role_vo.level
		if act_cfg and level < act_cfg.min_level then
			self.tmp_activity_list[activity_type] = {activity_type = activity_type, status = status, next_time = next_time, open_type = open_type}
			return
		elseif self.tmp_activity_list[activity_type] then
			self.tmp_activity_list[activity_type] = nil
		end
	else
		if self.tmp_activity_list[activity_type] then
			self.tmp_activity_list[activity_type] = nil
		end
	end

	if ActRemindNameT[activity_type] then
		self:SetButtonVisible(ActRemindNameT[activity_type], status ~= ACTIVITY_STATUS.CLOSE)
		if activity_type == ACTIVITY_TYPE.MARRY_ME then
			self:SetButtonVisible(ActRemindNameT[activity_type], status ~= ACTIVITY_STATUS.CLOSE and GameVoManager.Instance:GetMainRoleVo().lover_uid <= 0)
		end
	end

	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CORNUCOPIA then
		RemindManager.Instance:Fire(RemindName.JuBaoPen)
		-- self:CheckJuBaoPenIcon()
	end

	if self.top_icon_group_2 and self.top_icon_group_3 then
		self.top_icon_group_2:FlushIconGroup()
		self.top_icon_group_3:FlushIconGroup()
		self.player_view:FlushSetActiveMaayMe()
	end
end

function MainUIView:CheckJuBaoPenIcon()
	MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.JuBaoPen, JuBaoPenData.Instance:CheckIsShow())
end

-- 提醒改变
function MainUIView:RemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.Baoju then
		self:OnFlushBaoJuRedPoint(num)
	end

	if remind_name == RemindName.Main_Boss then
		self:OnFlushBossRedPoint(num)
	end

	if remind_name == RemindName.ChargeGroup then
		self:OnFlushChargeRedPoint(num)
	end

	if remind_name == RemindName.MenuIcon then
		self:FlushMenuIconRed(num)
	end

	if remind_name == RemindName.MainTop then
		self:FlushMainTopRed(num)
	end

	if remind_name == RemindName.Rank then
		self:FlushMainRankRed(num)
	end

	if remind_name == RemindName.GuildChatRed then
		self:ShowGuildChatIcon()
	end
end

function MainUIView:FlushMainRankRed(num)
	if self.node_list["RankRemindTips"] then
		self.node_list["RankRemindTips"]:SetActive(num > 0)
	end
end

function MainUIView:FlushMainTopRed(num)
	if self.node_list["ImgRedPoint2"] then
		self.node_list["ImgRedPoint2"]:SetActive(num > 0 and self.node_list["ShrinkButton"].toggle.isOn == false)
	end
end

function MainUIView:FlushMenuIconRed(num)
	if self.node_list["ImgRedPoint4"] then
		self.node_list["ImgRedPoint4"]:SetActive(num > 0)
	end
end

function MainUIView:OnFlushChargeRedPoint(num)
	if self.node_list["ChargeRedPoint"] then
		self.node_list["ChargeRedPoint"]:SetActive(num > 0)
	end
end
function MainUIView:OnFlushBossRedPoint(num)
	if self.node_list["BossRedPoint"] then
		self.node_list["BossRedPoint"]:SetActive(num > 0)
	end
end

function MainUIView:OnFlushBaoJuRedPoint(num)
	if self.node_list then
		self.node_list["DailyRedPoint"]:SetActive(num > 0)
	end
end

function MainUIView:OnTaskChange(task_event_type, task_id)
	if task_event_type == "accepted_add" then
		local main_role = Scene.Instance:GetMainRole()
		if main_role then
			main_role:CheckQingGong()
		end
		self:OnOpenTrigger(1, task_id)
		self:FlushZhuZhan()
	end

	if task_event_type == "completed_list" then
		self:InitOpenFunctionIcon()
		return
	end
	if task_event_type == "completed_add" then
		self:OnOpenTrigger(2, task_id)
	end
end

function MainUIView:OnPersonGoalChange(value, flag)
	if flag then
		self:OnOpenTrigger(5, value)
	end
end

function MainUIView:GetPackageBtn()
	return self.node_list["ButtonPackage"]
end

function MainUIView:StartGoWorship()
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GONGCHENG_WORSHIP) then
		CityCombatCtrl.Instance:GoWorship()
	end
end
function MainUIView:OnOpenTrigger(trigger_type, value)
	if self.node_list["ShrinkButton"] == nil then 
		return
	end
	
	self:InitOpenFunctionIcon()

	local single_fun_cfg_list = OpenFunData.Instance:OnTheTrigger(trigger_type, value)
	if single_fun_cfg_list == nil then
		return
	end

	for k,v in pairs(single_fun_cfg_list) do
		GlobalEventSystem:Fire(OpenFunEventType.OPEN_TRIGGER, v.name)
		if v.open_type == FunOpenType.Fly then
			local view_manager = ViewManager.Instance
			view_manager:CloseAll()
			if view_manager:IsOpen(ViewName.TaskDialog) then
				view_manager:Close(ViewName.TaskDialog)
			end
			if not self.judge_icon_active_time_quest and not self.time_quest then
				GlobalEventSystem:Fire(OpenFunEventType.OPEN_PAUSE, true)

				self:SetButtonAlpha(OpenFunData.Instance:GetName(v.open_param), 0)
				if v.with_param == FunWithType.Up then
					if FuBenCtrl.Instance:GetFuBenIconView():IsOpen() then
						self.MenuIconToggle.isOn = true
					else
						self.node_list["ShrinkButton"].toggle.isOn = true
						self.MenuIconToggle.isOn = false
					end
				end

				if v.with_param == FunWithType.Down then
					self.node_list["ShrinkButton"].toggle.isOn = false
					self.MenuIconToggle.isOn = true
					self:MainRoleLevelChange()
				end

				self:CalToJuggeIconActive(v)
			else
				self:SetButtonAlpha(OpenFunData.Instance:GetName(v.open_param), 1)
			end
		elseif v.open_type == FunOpenType.OpenModel then
			ViewManager.Instance:CloseAll()
			GlobalEventSystem:Fire(OpenFunEventType.OPEN_PAUSE, true)
			TipsCtrl.Instance:ShowOpenFunctionView(v.name, v.res_type)

		elseif v.open_type == FunOpenType.OpenView then
			if v.name == ViewName.TempMount then
				ViewManager.Instance:Open(ViewName.TempMount)
			elseif v.name == ViewName.TempWing then
				ViewManager.Instance:Open(ViewName.TempWing)
			end
		end
	end

	--功能开启时需要判断的红点
	RemindManager.Instance:Fire(RemindName.RuneTreasure)
end

function MainUIView:FlyToDict(cfg)
	self:InitOpenFunctionIcon()
	local open_fun_data = OpenFunData.Instance
	if not self.judge_icon_active_time_quest and not self.time_quest then
		self:SetButtonAlpha(open_fun_data:GetName(cfg.open_param), 0)
		local chat_view = ChatCtrl.Instance:GetView()
		if chat_view:IsOpen() then
			chat_view:Close()
		end
		if not self.MenuIconToggle.isOn then
			 self.MenuIconToggle.isOn = true
		end

		if not self.node_list["ShrinkButton"].toggle.isOn then
			self.node_list["ShrinkButton"].toggle.isOn = true
		end
		self:CalToJuggeIconActive(cfg)
	else
		self:SetButtonAlpha(open_fun_data:GetName(cfg.open_param), 1)
	end
end

function MainUIView:CalToJuggeIconActive(cfg)
	local name = OpenFunData.Instance:GetName(cfg.open_param)
	self.seek_target_num = 0
	self:ShowOpenFunFlyView(cfg, name)
end

function MainUIView:ShowOpenFunFlyView(cfg, name)
	local target_obj = self:GetMainButton(name)
	self.seek_target_num = self.seek_target_num + 1
	if self.seek_target_num >= 40 then
		if self.seek_target_time then
			GlobalTimerQuest:CancelQuest(self.seek_target_time)
			self.seek_target_time = nil
		end
		return
	end
	if target_obj then
		if self.seek_target_time then
			GlobalTimerQuest:CancelQuest(self.seek_target_time)
			self.seek_target_time = nil
		end
		TipsCtrl.Instance:ShowOpenFunFlyView(cfg, target_obj:GetRootNode())
	else
		if nil == self.seek_target_time then
			self.seek_target_time = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.ShowOpenFunFlyView, self, cfg, name), 0.5)
		end
	end
end


function MainUIView:CameraModeChange()
	local guide_flag_list = SettingData.Instance:GetSettingDataListByKey(HOT_KEY.CAMERA_KEY_FLAG)
	local flag = guide_flag_list.item_id or 0

	-- if self.node_list["TxtCamerMode"] then
	-- 	self.node_list["TxtCamerMode"].text.text = flag == 1 and Language.Common.CamerModeFree or Language.Common.CamerModeLock
	-- end
	if self.node_list["BtnChangeCameraMode"] then
		self.node_list["BtnChangeCameraMode"].image:LoadSpriteAsync(ResPath.GetMainUI("Camera" .. (flag == 1 and 1 or 0)))
	end
end

function MainUIView:OnClickCameraMode()
	if PlayerData.Instance:IsHoldAngle() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Mainui.TaskNoCamera)
		return
	end
	local guide_flag_list = SettingData.Instance:GetSettingDataListByKey(HOT_KEY.CAMERA_KEY_FLAG)
	local flag = guide_flag_list.item_id or 0
	if flag == 1 then
		flag = 0
	else
		flag = 1
	end
	Scene.Instance:SetCameraMode(flag)
	if self.reminding_view then
		self.reminding_view:CameraModeChange()
	end
	-- if self.node_list["TxtCamerMode"] then
	-- 	self.node_list["TxtCamerMode"].text.text = flag == 1 and Language.Common.CamerModeFree or Language.Common.CamerModeLock
	-- end
	if self.node_list["BtnChangeCameraMode"] then
		self.node_list["BtnChangeCameraMode"].image:LoadSpriteAsync(ResPath.GetMainUI("Camera" .. (flag == 1 and 1 or 0)))
	end
	
	SettingCtrl.Instance:SendChangeHotkeyReq(HOT_KEY.CAMERA_KEY_FLAG, flag)
	SettingData.Instance:SetSettingDataListByKey(HOT_KEY.CAMERA_KEY_FLAG, flag)
end

function MainUIView:OnClickPhotoShot()
	BaseView.SetAllUICameraEnable(false)
	local path = UnityEngine.Application.persistentDataPath
	path = string.format("%s%s.jpg", path, os.time())
	local callback = function(result, new_path)
		if true == result then
			ScreenShotCtrl.Instance:OpenScreenView(new_path, function() BaseView.SetAllUICameraEnable(true) end)
		else
			BaseView.SetAllUICameraEnable(true)
		end
	end
	UtilU3d.Screenshot(path, callback)
end

function MainUIView:OnClickBtnMount()
	if self.MenuIconToggle.isOn then
		GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)
		return
	end
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local mount_appeid = main_role_vo.mount_appeid
	local multi_appeid = main_role_vo.multi_mount_res_id
	local fight_mount_appeid = main_role_vo.fight_mount_appeid
	local scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if scene_cfg and scene_cfg.pb_mount and 1 == scene_cfg.pb_mount then
		SysMsgCtrl.Instance:ErrorRemind(Language.Mount.NotMountScene)
		return
	end

	if Scene.Instance:GetMainRole():IsQingGong() then
		SysMsgCtrl.Instance:ErrorRemind(Language.QingGong.NotMount)
		return
	end

	if mount_appeid and fight_mount_appeid then
		if multi_appeid <= 0 and mount_appeid <= 0 and fight_mount_appeid <= 0 and FightMountData.Instance:IsActiviteMount() then
			FightMountCtrl.Instance:SendGoonFightMountReq(1)
		elseif mount_appeid <= 0 and multi_appeid <= 0 then
			MountCtrl.Instance:SendGoonMountReq(1)
			FightMountCtrl.Instance:SendGoonFightMountReq(0)
		else
			MultiMountCtrl.Instance:SendMultiModuleReq(MULTI_MOUNT_REQ_TYPE.MULTI_MOUNT_REQ_TYPE_UNRIDE)
			MountCtrl.Instance:SendGoonMountReq(0)
		end
	end
end

function MainUIView:SetMountText()
	local mount_state = MountData.Instance:GetCurMountState()
	-- self.node_list["MountText"].text.text = Language.Mount.MountState[mount_state]
	if self.node_list["MountStateImage"] then
		local bundle, asset = ResPath.GetMainUI("mount_state_" .. mount_state)
		self.node_list["MountStateImage"].image:LoadSpriteAsync(bundle,asset, function()
			self.node_list["MountStateImage"].image:SetNativeSize()
		end)
	end
end

function MainUIView:OnClickGroup2Button()
	if self.click_group2 or not MOVE_DIS_ISON then
		return
	end
	self.click_group2 = true
	if self.top_group2_animator.isActiveAndEnabled then
		self.top_group2_animator:SetInteger("State", 1)
		self.top_group2_animator:WaitEvent("HideExit", function(param)
			self.top_icon_group_2:FlushIconGroup()
			self.top_group2_animator:SetInteger("State", 2)
		end)
		self.top_group2_animator:WaitEvent("StateExit", function(param)
			self.click_group2 = false
		end)
	end
end

function MainUIView:SetShrinkToggle(isOn)
	if isOn then
		self.node_list["ShrinkButton"].toggle.isOn = isOn
	else
		if self.node_list["ShrinkButton"].toggle.isOn == false then
			self.node_list["ShrinkButton"].toggle.isOn = true
		end
	end
	RemindManager.Instance:Bind(self.remind_change, RemindName.MainTop)
end

function MainUIView:MoveMainIcon(cfg)
	local open_fun_data = OpenFunData.Instance
	local the_button = self:GetMainButton(open_fun_data:GetName(cfg.open_param))
	if not the_button then
		return
	end
	local timer = 0
	local width = 0
	if cfg.with_param == OPEN_FLY_DICT_TYPE.UP then
		width = 70
	else
		width = 92
	end
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer = timer + UnityEngine.Time.deltaTime
		if timer <= 0.5 then
			the_button.root_node.rect.sizeDelta = Vector2(width*timer * 2, width)
		elseif timer > 0.5 then
			the_button.root_node.rect.sizeDelta = Vector2(width, width)
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end, 0)
end

function MainUIView:GetButtonPos(name)
	local button = self:GetMainButton(name)
	if button then
		--获取指引按钮的屏幕坐标
		local uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))
		local obj_world_pos = button.root_node.transform:GetComponent(typeof(UnityEngine.RectTransform)).position
		local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(uicamera, obj_world_pos)

		--转换屏幕坐标为本地坐标
		local rect = self.root_node:GetComponent(typeof(UnityEngine.RectTransform))
		local _, local_pos_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, screen_pos_tbl, uicamera, Vector2(0, 0))
		return Vector3(local_pos_tbl.x, local_pos_tbl.y, 0)
	end
	return Vector3(0, 0, 0)
end

function MainUIView:GetCanvasGroupBlockRayCasts(name)
	if self:GetMainButton(name) and self:GetMainButton(name):GetRootNode().canvas_group then
		return self:GetMainButton(name):GetRootNode().canvas_group.blocksRaycasts
	end
end

function MainUIView:SetButtonAlpha(name, alpha)
	if self:GetMainButton(name) and self:GetMainButton(name):GetRootNode().canvas_group then
		self:GetMainButton(name):GetRootNode().canvas_group.alpha = alpha
	else
		print_warning("###########SetButtonAlpha has not canvas_group", name)
	end
end

function MainUIView:OnShowOrHideShrinkBtn(state)
	if not self:IsRendering() then return end
	self.node_list["ShrinkButton"].toggle.isOn = state
	if state == false then
		self:MainRoleLevelChange()
	end
end

function MainUIView:ShowEXPBottleText(num)
	if self.delay_text_timer then
		GlobalTimerQuest:CancelQuest(self.delay_text_timer)
		self.delay_text_timer = nil
	end
	if self.node_list["ExpBottleButton"].gameObject.activeSelf then
		self.node_list["NodeShowEXPText"]:SetActive(true)
		self.node_list["TtNeedFriendNum"].text.text = string.format(Language.Mainui.NeedFriendNum, num)
		self.delay_text_timer = GlobalTimerQuest:AddDelayTimer(function ()
			self.node_list["NodeShowEXPText"]:SetActive(false)
		end,3)
	end
end

function MainUIView:CloseExpBottleText()
	if self.node_list["NodeShowEXPText"] then
		self.node_list["NodeShowEXPText"]:SetActive(false)
	end
end

--初始化图标(这里的刷新有点猛的！！！要改)
function MainUIView:InitOpenFunctionIcon()
	if nil ~= self.delay_init_open_fun_timer then
		return
	end

	self.delay_init_fun_icon = BindTool.Bind(self.DelayInitOpenFunctionIcon, self)
	self.delay_init_open_fun_timer = GlobalTimerQuest:AddDelayTimer(self.delay_init_fun_icon, 0.8)
end

function MainUIView:DelayInitOpenFunctionIcon()
	self.delay_init_open_fun_timer = nil
	self:FlushIconGroups()
	self:FlushZhuZhan()

	for k,v in pairs(OpenFunData.Instance:OpenFunCfg()) do
		local is_show = OpenFunData.Instance:CheckIsHide(v.name)
		if v.name == "firstchargeview" then
			self:CheckShouFirstChargeEff()
		elseif v.name == "chongzhi" then
			self:CheckShouFirstChargeEff()
		elseif v.name == "jubaopen" then
			self:CheckJuBaoPenIcon()
		elseif v.name == "exp_bottle" then
			self:CheckExpBottleShake()
		elseif v.name == "threerecharge" then
			self:CheckShouFirstChargeEff()
		elseif v.name == "market" then
			if self.node_list["Buttonmarket"] then
				self:IsShowMarket(true)
			end
		elseif v.name == "boss" then
			if self.node_list["BtnBoss"] then
				self.node_list["BtnBoss"]:SetActive(is_show)
			end
		elseif v.name == "daily" then
			if self.node_list["BtnDaily"] then
				self.node_list["BtnDaily"]:SetActive(is_show)
			end
		elseif v.name == "ranking" then
			if self.node_list["ButtonRank"] then
				self.node_list["ButtonRank"]:SetActive(is_show and not IS_ON_CROSSSERVER)
			end
		elseif v.name == "BtnMount" then
			if self.node_list["MountStateImage"] then
				self.node_list["MountStateImage"]:SetActive(is_show)
			end
		elseif v.name == "shopview" then
			self:ShowTeHuiDiscountShop()
		end
	end
	
	for k,v in pairs(RemindFunName) do
		RemindManager.Instance:Fire(k)
	end
end

function MainUIView:IsInArenaView()					--是否在竞技场
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type and (scene_type == SceneType.Field1v1 or scene_type == SceneType.KF_Arenas) then
		return true
	end
	return false
end

--助战按钮
function MainUIView:FlushZhuZhan()
	local shenyu_btn = self:GetMainButton("clothespress")
	if shenyu_btn then
		local open_count  = 0
		local data = self:GetShenGeIconData()
		local shenyu_img = "Icon_System_RUNE"
		local shenyu_img2 = "Icon_System_ShenGe"

		if #data == 1 then
			shenyu_btn:SetImage(shenyu_img, true)
		else
			shenyu_btn:SetImage(shenyu_img2, true)
		end
	end
end

function MainUIView:FlushChargeIcon()
	if nil ~= DailyChargeData.Instance then
		self:ShowRebateButton()
		self:ShowImageSkillButton()
		self:CheckShouFirstChargeEff()
	end
end

function MainUIView:CheckShouFirstChargeEff()
	if not self:IsRendering() or not self:IsLoaded() or not DailyChargeData.Instance then return end
	if nil == DailyChargeData.Instance then
		return
	end

	-- 首充模型显示条件：没首充过 + 功能开启
	local active_flag1, fetch_flag1 = DailyChargeData.Instance:GetThreeRechargeFlag(1)
	local active_flag2, fetch_flag2 = DailyChargeData.Instance:GetThreeRechargeFlag(2)
	local active_flag3, fetch_flag3 = DailyChargeData.Instance:GetThreeRechargeFlag(3)
	local fetch_flag = fetch_flag1 ~= 1 or fetch_flag2 ~= 1 or fetch_flag3 ~= 1
	if nil ~= self.node_list["ButtonFirstCharge"].transform:FindHard("RedPoint") then
		local flag1 = active_flag1 == 1 and fetch_flag1 ~= 1
		local flag2 = active_flag2 == 1 and fetch_flag2 ~= 1
		local flag3 = active_flag3 == 1 and fetch_flag3 ~= 1
		local show_red = flag1 or flag2 or flag3
		self.node_list["ButtonFirstCharge"].transform:FindHard("RedPoint").gameObject:SetActive(show_red)
		-- self.node_list["ChargeRedPoint"]:SetActive(show_red)
	end
	self.node_list["ButtonFirstCharge"]:SetActive(fetch_flag)
	self.node_list["BtnChargeArrow2"]:SetActive(false)
	self.node_list["BtnChargeArrow1"]:SetActive(fetch_flag and active_flag1 == 1)

	if nil ~= self.node_list["ListChargeButton"].transform:FindHard("firstchargeview") then
		self.node_list["ListChargeButton"].transform:FindHard("firstchargeview").gameObject:SetActive(false)
	end

	local open_chongzhi = GLOBAL_CONFIG.param_list.switch_list.open_chongzhi
	self.node_list["PanelChargeButton"]:SetActive(self.is_in_special_scene and self.is_show_charge_panel and not IS_AUDIT_VERSION and open_chongzhi)

	if not fetch_flag then
		self.node_list["ChargeGroup"].rect.anchoredPosition = Vector3(50, 0, 0)
		self.node_list["ChargeGroup"].canvas_group.alpha = 1
		self.node_list["ListChargeButton"]:SetActive(true)
	end
	if self.auto_chargechange and nil ~= active_flag1 and nil ~= fetch_flag1 then
		if GameVoManager.Instance:GetMainRoleVo().level >= 160 and active_flag1 == 1 and fetch_flag1 == 1 then
			self:ClickChargeChange(1)
			self.auto_chargechange = false
		end
	end
	self.first_recharge_view:Flush()
end

function MainUIView:OnRoleAttrValueChange(key, new_value, old_value)
	if RemindByAttrChange[key] then
		for k,v in pairs(RemindByAttrChange[key]) do
			RemindManager.Instance:Fire(v)
		end
	end
	if key == "level" then
		self:ChangeFunctionTrailer()
		if math.abs(new_value - old_value) >= 1 and new_value ~= 1 then
			self:OnOpenTrigger(3, new_value)
		else
			self:InitOpenFunctionIcon()
		end
		for k,v in pairs(self.tmp_activity_list) do
			self:ActivityChangeCallBack(v.activity_type, v.status, v.next_time, v.open_type)
		end

		if self.chat_view then
			self.chat_view:FlushActivityPre()
		end
	elseif key == "special_appearance" and self.skill_view then
		self.skill_view:OnFlush({skill = true, special_appearance = new_value})
		self.main_auditversion_skill_control:OnFlush({skill = true, special_appearance = new_value})
	elseif key == "lover_uid" then
		self:SetButtonVisible(ActRemindNameT[ACTIVITY_TYPE.MARRY_ME], MarryMeData.Instance:GetMarryMeRemind(true))
	elseif key == "hp" then
		local max_hp = PlayerData.Instance:GetRoleVo().max_hp
		self:SetRedBloodEffect(new_value, max_hp)
	elseif key == "guild_id" then
		if new_value == 0 then
			MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.GuildHongBao, false)
		end
	end
end

function MainUIView:OnDayChange()
	if self.top_icon_group_2 then
		self:AddToUpdateList(self.top_icon_group_2)
	end
	RemindManager.Instance:Fire(RemindName.MoLongMiBao)
	RemindManager.Instance:Fire(RemindName.OneYuanBuy)
	RemindManager.Instance:Fire(RemindName.CoolChat_Head)
	RemindManager.Instance:Fire(RemindName.CoolChat_Bubble)
	RemindManager.Instance:Fire(RemindName.TodayTheme)

	RemindManager.Instance:Fire(RemindName.SingleChange)
	RemindManager.Instance:Fire(RemindName.RechargeCapacity)
	RemindManager.Instance:Fire(RemindName.IncreaseSuperior)
	RemindManager.Instance:Fire(RemindName.IncreaseCapability)

	self:InitOpenFunctionIcon()
	ShopCtrl.Instance:FlushTeHuiCountDown()
	TASK_GUILD_AUTO = false
	TASK_RI_AUTO = false
	TASK_HUAN_AUTO = false
	TASK_ZHUANZHI_AUTO = false
end

function MainUIView:SetRedBloodEffect(hp, max_hp)
	self.node_list["RedBloodEffect"]:SetActive(hp / max_hp <= LOWBLOODWARNING)

	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.KF_Fish then
		self.node_list["RedBloodEffect"]:SetActive(false)
	end
end

function MainUIView:ShakeGuildChatBtn(is_shake)
	GuildData.Instance:SetGuildChatShakeState(is_shake)

	if self.MenuIconToggle.isOn == false and self.node_list["FightStateBtn"].toggle.isOn == false then
		self.node_list["ButtonGuildChat"].animator:SetBool("shake", is_shake)
	else
		self.record_guild_shake = true --如果是隐藏状态下的话先记录好状态，在显示时再播放颤抖动画
	end
end
------------------在线奖励----------------------------
function MainUIView:StopOnlineCountDown()
	if self.online_time_quest then
		GlobalTimerQuest:CancelQuest(self.online_time_quest)
		self.online_time_quest = nil
	end
end

function MainUIView:SetExpBottleShakeState(enable)
	if self.node_list["ExpBottleButton"] and self.node_list["ExpBottleButton"].gameObject.activeInHierarchy then
		self.record_exp_bottle_shake = enable
		self.node_list["ExpBottleButton"].animator:SetBool("Shake", enable)
		self.node_list["EffectTiShi25"]:SetActive(enable)
	end
end

function MainUIView:CheckExpBottleShake()
	if self.record_exp_bottle_shake then
		self.exp_bottle_shake_timer = GlobalTimerQuest:AddDelayTimer(function ()
		if self.node_list["ExpBottleButton"] and self.node_list["ExpBottleButton"].gameObject.activeInHierarchy then
			self.node_list["ExpBottleButton"].animator:SetBool("Shake", self.record_exp_bottle_shake)
			self.node_list["EffectTiShi25"]:SetActive(self.record_exp_bottle_shake)
			if self.node_list["ExpBottleButton"].animator:GetBool("Shake") ~= self.record_exp_bottle_shake then
				self:CheckExpBottleShake()
			end
		end
		end, 5)
	end
end

function MainUIView:StarOnlineCountDown(target_time)
	local function timer_func()
		local online_time = WelfareData.Instance:GetTotalOnlineTime()
		local diff_sec = target_time - online_time
		if diff_sec <= 0 then
			self.node_list["EffectTiShi"]:SetActive(true)
			self.node_list["TxtOnlineTime"].text.text = Language.Common.KeLingQu
			self.node_list["OnlineRewardText"].text.text = ""
			self:FlushOnlineReward()
			-- bug:在线奖励有 在线奖励可领取，但是点进去是不能领取的
			-- 代码没分析出，先通过永不停止计时器观察一段时间（对性能影响不大)
			-- self:StopOnlineCountDown()
			return
		end

		local time_str = ""
		if diff_sec >= 3600 then
			--大于一小时的三位数
			time_str = TimeUtil.FormatSecond(diff_sec)
		else
			time_str = TimeUtil.FormatSecond(diff_sec, 2)
		end
		self.node_list["TxtOnlineTime"].text.text = time_str
		self.node_list["OnlineRewardText"].text.text = string.format("%s\n%s", Language.Mainui.OnlineReward, time_str)
	end

	self:StopOnlineCountDown()
	self.online_time_quest = GlobalTimerQuest:AddRunQuest(timer_func, 1)
end

function MainUIView:FlushOnlineReward()
	-- bug:在线奖励有 在线奖励可领取，但是点进去是不能领取的
	-- 代码没分析出，先通过永不停止计时器观察一段时间（对性能影响不大)
	-- self:StopOnlineCountDown()
	if not self.is_in_special_scene then
		self.node_list["OnlineRewardBtn"]:SetActive(false)
		return
	end
	local reward_data, is_all_get = WelfareData.Instance:GetOnlineReward()
	if nil == reward_data or nil == next(reward_data) then return end
	local scene_type = Scene.Instance:GetSceneType()
	local reward_need_sec = (reward_data.minutes) * 60
	if not OpenFunData.Instance:CheckIsHide("OnlineRewardBtn") or is_all_get or IS_ON_CROSSSERVER or scene_type ~= SceneType.Common then
		self.node_list["OnlineRewardBtn"]:SetActive(false)
	else
		self.node_list["OnlineRewardBtn"]:SetActive(true)
		local btn_text = ""
		local red_point_flag = false
		local online_time = WelfareData.Instance:GetTotalOnlineTime()
		local diff_sec = online_time - reward_need_sec
		if diff_sec >= 0 then
			btn_text = Language.Common.KeLingQu
			red_point_flag = true
		else
			diff_sec = math.abs(diff_sec)
			self:StarOnlineCountDown(reward_need_sec)
			local time_str = ""
			if diff_sec >= 3600 then
				--大于一小时的三位数
				time_str = TimeUtil.FormatSecond(diff_sec)
			else
				time_str = TimeUtil.FormatSecond(diff_sec, 2)
			end
			btn_text = time_str
		end
		self.node_list["TxtOnlineTime"].text.text = btn_text
		self.node_list["EffectTiShi"]:SetActive(red_point_flag)
	end
end
-----------------------------------------------------

--引导用函数
function MainUIView:MainMenuClick()
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end

	GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, true, false, true)
end

function MainUIView:RightShrinkClick()
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_SHRINK_BUTTON, true)
end

function MainUIView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.MainUIRoleHead then
		if ui_param == MainViewOperateState.AutoOpen then
			GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, true, false, true)
			return NextGuideStepFlag
		elseif ui_param == MainViewOperateState.AutoClose then
			GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false, false, true)
			return NextGuideStepFlag
		else
			if self.MenuIconToggle.isOn then
				return NextGuideStepFlag
			end
			local callback = BindTool.Bind(self.MainMenuClick, self)
			return self.node_list["MenuIcon"], callback
		end
	elseif ui_name == GuideUIName.MainUIRightShrink then
		if ui_param == MainViewOperateState.AutoOpen then
			GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_SHRINK_BUTTON, true)
			return NextGuideStepFlag
		elseif ui_param == MainViewOperateState.AutoClose then
			GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_SHRINK_BUTTON, false)
			return NextGuideStepFlag
		else
			if not self.node_list["ShrinkButton"].toggle.isOn then
				return NextGuideStepFlag
			end
			local callback = BindTool.Bind(self.RightShrinkClick, self)
			return self.node_list["ShrinkButton"], callback
		end
	elseif ui_name == GuideUIName.MainUIBossIcon then
		if self.node_list["BtnBoss"] then
			return self.node_list["BtnBoss"], BindTool.Bind(self.OpenBossView, self)
		end
	elseif ui_name == GuideUIName.MainUIButtonPackage then
		if self.node_list["ButtonPackage"] then
			return self.node_list["ButtonPackage"], BindTool.Bind(self.OnClickPackage, self)
		end
	elseif ui_name == GuideUIName.BaojuGotoDaily then
		if self.node_list["BtnDaily"] then
			return self.node_list["BtnDaily"], BindTool.Bind(self.OnClickButtonDaily, self)
		end
	elseif ui_name == GuideUIName.QingGongBtn or ui_name == GuideUIName.QingGongDownBtn then 			
		--轻功指引
		local main_role = Scene.Instance:GetMainRole()
		if ui_name == GuideUIName.QingGongBtn and self.qinggong_btn.gameObject.activeInHierarchy then
			return self.qinggong_btn, function()
				if not CgManager.Instance:IsCgIng() then
					if not self.is_qinggong_guide_callby_auto then
						if main_role then
							main_role:GetRoot().transform.localRotation = Quaternion.Euler(0, -9, 0)
							main_role:SetIsQingGongGuide(true)
						end
						-- self:ShowQingGongGuideSkillEffect(true, cur_guide_step == 5)
						self:QingGongCallBack()
						self:SetQingGongGuideClickCountDownState(false)
					end
				end
			end
		else
			return self.qinggong_down_btn, function()
				if not self.is_qinggong_guide_callby_auto then
					-- self:ShowQingGongGuideSkillEffect(true, cur_guide_step == 5)
					self:QingGongLandCallBack()
					self:SetQingGongGuideClickCountDownState(false)
				end
			end
		end
	elseif ui_name == GuideUIName.MainUiZuoqi then
		if self.node_list["thumb"] then
			return self.node_list["thumb"], BindTool.Bind(self.OnClickBtnMount, self)
		end
	elseif ui_name == GuideUIName.GoddessSkill then
		if self.skill_view then
			return self.skill_view:GetSkill6()
		end
	elseif ui_name == GuideUIName.BtnBianShen then
		if self.skill_view then
			return self.skill_view:GetMainBianShen()
		end
	elseif self:GetMainButton(ui_name) then
		local button = self:GetMainButton(ui_name)
		if button.root_node.gameObject.activeInHierarchy then
			local call = BindTool.Bind(self.OpenMainButton, self, button)
			if ui_name == "clothespress" then
				call = BindTool.Bind(self.OnClickShenGe, self)
			end
			return self:GetMainButton(ui_name):GetRootNode(), call
		end
	elseif self.node_list[ui_name] then
		if self.node_list[ui_name].gameObject.activeInHierarchy then
			return self.node_list[ui_name]
		end
	end
end

function MainUIView:OpenMainButton(button)
	if button.cfg then
		if button.cfg.name == "guild" then
			self:OnClickGuild()
		else
			if button.cfg.guide then
				ViewManager.Instance:Open(button.cfg.guide)
			end
		end
	end
end

function MainUIView:GetMainButton(name)
	for k, v in pairs(self.main_icon_group_list) do
		local button = v:GetIconByName(name)
		if button then
			return button
		end
	end
end

function MainUIView:GetMainChatView()
	return self.chat_view
end

function MainUIView:GetJoystickRegion() 	
	return self.node_list["JoystickRegion"]
end

function MainUIView:OnTaskShrinkToggleChange(isOn)
	self.show_switch = not isOn
	self.node_list["NodeSwithcBtn"]:SetActive(not isOn and not self.MenuIconToggle.isOn)
end

function MainUIView:RemoveFightToggleTimeQuest()
	if self.fight_toggle_time_quest then
		GlobalTimerQuest:CancelQuest(self.fight_toggle_time_quest)
		self.fight_toggle_time_quest = nil
	end
end

function MainUIView:SetGuildStation(is_active)
	self.skill_view:SetGuildStation(is_active)
	self.skill_view:FlushGeneralSkill()
end

function MainUIView:ChangeFightStateToggle(state)
	if self.node_list["FightStateBtn"].toggle.isOn == state then
		return
	end
	self:RemoveFightToggleTimeQuest()
	self.fight_toggle_time_quest = GlobalTimerQuest:AddRunQuest(function()
		self:ChangeFightToggleState(state)
	end, 0)
end

function MainUIView:ChangeFightToggleState(state)
	if self.node_list["FightStateBtn"].gameObject.activeInHierarchy then
		self.node_list["FightStateBtn"].toggle.isOn = state
		self:RemoveFightToggleTimeQuest()
	end
end

function MainUIView:ChangeFightStateEnable(enable)
	self.node_list["FightStateBtn"]:SetActive(enable)
	self.node_list["FightStateBtn"].toggle.enabled = enable
end

function MainUIView:GetFightToggleState()
	if self.node_list["FightStateBtn"] then
		return self.node_list["FightStateBtn"].toggle.isOn
	end
	return false
end

function MainUIView:OnFightStateToggleChange(isOn)
	MainUIData.IsFightState = isOn
	GlobalEventSystem:Fire(MainUIEventType.FIGHT_STATE_BUTTON, isOn)
	ViewManager.Instance:CheckViewRendering()
	if isOn == false then
		self:CheckRecordGuildShake()
		self:CheckExpBottleShake()
	end
	self:SetIsShowMainUi(isOn)
	self:IsShowMarket(not isOn)
end

function MainUIView:SetIsShowMainUi(isOn)
	if self.playerinfo_animator.isActiveAndEnabled then
		self.playerinfo_animator:SetBool("Show", not isOn)
		self.trailer_animator:SetBool("Show", not isOn)
		-- self.targetInfo_animator:SetBool("Show", not isOn)
		self.maintask_animator:SetBool("Show", not isOn)
		self.topButtons_animator:SetBool("Show", not isOn)
		self.bottom_animator:SetBool("Show", not isOn)
	end
end

function MainUIView:SetFlyTaskIsHideMainUi(isOn)
	self:SetIsShowMainUi(isOn)
	self:SetViewHideorShow("RightBttomPanel", not isOn)
	self:SetJoystickIsShow(is_on)
	if self.node_list["OnlineContent"] then
		self.node_list["OnlineContent"]:SetActive(not isOn)
	end
	if self.node_list["MenuIcon"] then
		self.node_list["MenuIcon"]:SetActive(not isOn)
	end
	self:IsShowMarket(not isOn)
	if not isOn then
		self:ChangeFightToggleState(false)
	end
	if IsNil(MainCameraFollow) then
		return
	end
	if CAMERA_TYPE == CameraType.Fixed then
		MainCameraFollow.AllowXRotation = isOn
	end
	if isOn then
		if self.node_list["XunLu"] then
			self.node_list["XunLu"]:SetActive(false)
		end
		-- Scene.Instance:SetGuideFixedCamera(16, 180)
	end
end

function MainUIView:SetJoystickIsShow(is_on)
	local is_on = is_on
	local main_role = Scene.Instance:GetMainRole()
	if main_role:GetIsFlying() then
		is_on = true
	end
	self.joystick_view:SetActive(not is_on)
end

--右下角屏蔽按钮点击
function MainUIView:FightStateClick()
	if not self.node_list["FightStateBtn"].toggle.enabled then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotHandle)
	end
end

-- function MainUIView:ActChangeBiPinBtn()
-- 	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BiPin_ACTIVITY) then			-- 随机活动比拼
-- 		return true
-- 	end
-- 	return false

-- end

function MainUIView:ChangeBiPinBtn()
	local day = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = ActivityData.Instance:GetActivityConfig(COMPETITION_ACTIVITY_TYPE[day])
	local level = GameVoManager.Instance:GetMainRoleVo().level

	local can_show = day <= #COMPETITION_ACTIVITY_TYPE and (cfg and cfg.min_level <= level and level <= cfg.max_level) or false
	return can_show
end

function MainUIView:ChangeFanHuanBtn()
	local cfg = ActivityData.Instance:GetActivityConfig(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_RETURN)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if (cfg and cfg.min_level <= level and level <= cfg.max_level) and ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_RETURN) then
		return true
	else
		return false
	end
end

function MainUIView:ChangeFanHuanTwoBtn()
	local cfg = ActivityData.Instance:GetActivityConfig(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPLEVEL_RETURN_2)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if (cfg and cfg.min_level <= level and level <= cfg.max_level) and ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPLEVEL_RETURN_2) then
		return true
	else
		return false
	end
end

function MainUIView:ChangeWeekendIcon()
	local day = TimeCtrl.Instance:GetCurOpenServerDay()
	local icon = day <= 4 and "Icon_Activity_Weekend" or "Icon_Activity_2239"				--智扬说开服第四天开一次 名字叫首饰狂欢 以后开启的都加周末狂欢
	return icon
end

function MainUIView:ChangeBiPinIcon()
	local day = TimeCtrl.Instance:GetCurOpenServerDay()
	local icon = day <= #COMPETITION_ACTIVITY_TYPE and "Icon_bipin_" .. day or "Icon_bipin_1"
	return icon
end

function MainUIView:ChangeHuanYuIcon()
	local data = self:GetShenGeIconData()
	local icon = #data <= 1 and "Icon_System_RUNE" or "Icon_System_ShenGe"
	return icon
end

function MainUIView:ChangeFanHuanIcon(act_id)
	local day = TimeCtrl.Instance:GetCurOpenServerDay()
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().jinjie_act_theme
	local icon_nmae = 1
	if ActivityData.Instance:GetActivityIsOpen(act_id) then
		for k,v in pairs(config) do
			if v.act_id == act_id and day == v.opengame_day then
				icon_nmae = v.act_theme
			end
		end
	end
	
	local icon = icon_nmae > 0 and "Icon_back_" .. icon_nmae or "Icon_back_1"
	return icon
end

function MainUIView:ShowIndexCallBack()
	self:ChangeFunctionTrailer()
end

function MainUIView:ChangeActHongBaoAni(flag, is_loop)
	if self.act_hongbao_ani and self.act_hongbao_ani.isActiveAndEnabled then
		self.act_hongbao_ani:SetBool("Shake", flag)
	end
	if is_loop and not self.hongbao_shake_timer then
		self.hongbao_shake_timer =  GlobalTimerQuest:AddDelayTimer(function()
			if self.act_hongbao_ani.isActiveAndEnabled then
				self.act_hongbao_ani:SetBool("Shake", false)
			end
			self.hongbao_shake_timer = nil
		end, 1)
	end
end

function MainUIView:ShowDiamonDown()
	if self.hongbao_down_timer then return end
	if self.act_hongbao_down_ani then
		self.node_list["ImageDiamon"]:SetActive(true)
		if self.act_hongbao_down_ani.isActiveAndEnabled then
			self.act_hongbao_down_ani:SetBool("Down", true)
			self.hongbao_down_timer = GlobalTimerQuest:AddDelayTimer(function()
				self.act_hongbao_down_ani:SetBool("Down", false)
				self.hongbao_down_timer = nil
			end, 1)
		end
	end
end

function MainUIView:HasViewOpen(view)
	if view and view.view_name == ViewName.ActivityHall then
		self.top_icon_group_2:SetImage("ActHall", "Icon_System_Act_Hall")
	end
end

function MainUIView:HasViewClose(view)
	if view and view.view_name == ViewName.ActivityHall then
		self.top_icon_group_2:SetImage("ActHall", "Icon_System_Act_Hall2")
	end
end

function MainUIView:CheckMenuRedPoint()
	if self.node_list and self.node_list["NodeShowRedPoint"] then
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		self.node_list["NodeShowRedPoint"]:SetActive(main_role_vo.level >= SHOW_REDPOINT_LIMIT_LEVEL)
	end
end

function MainUIView:CheckPackageRedPoint(enable)
	if self.node_list and self.node_list["ImgRedPoint31"] then
		self.node_list["ImgRedPoint31"]:SetActive(enable)
	end
end

function MainUIView:CanShowCapChange()
	return self.can_show_cap_change
end

function MainUIView:ShowDoubleIcon(is_show)
	if self.player_view then
		self.player_view:ShowDoubleIcon(is_show)
	end
end

function MainUIView:FlushServerHongBaoNumValue()
	local num_text = ""
	local count = #HongBaoData.Instance:GetCurServerHongBaoIdList()
	if count == 0 then
		self.node_list["ServerHongBaoBtn"]:SetActive(false)
		self.node_list["ImgHongBaoTail"]:SetActive(false)
	end
end

function MainUIView:CreateServerHongBao(id, type)
	self.node_list["ServerHongBaoBtn"]:SetActive(true)
	self.node_list["ImgHongBaoTail"]:SetActive(true)
	self.node_list["ServerHongBao"].animator:SetBool("Shake", true)
	HongBaoData.Instance:SetoveCurServerHongBaoIdList(id, type)
	self:FlushServerHongBaoNumValue()
end

function MainUIView:OpenServerHongBao()
	HongBaoCtrl.Instance:RecHongBao(HongBaoData.Instance:GetCurServerHongBaoIdList()[1].id)
end

function MainUIView:FlushHongBaoNumValue()
	local count = #HongBaoData.Instance:GetCurHongBaoIdList()
	if count <= 0 then
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.HONGBAO, false)
	end
end

function MainUIView:OpenActivityPreview()
	self.player_view:OpenActivityPreView()
end

--活动技能/副本场景技能
function MainUIView:ShowActivitySkill(attach_obj)
	if self.skill_view then
		self.skill_view:OnShowActivitySkill(attach_obj)
	end
end

-- 改变变身技能状态
function MainUIView:ChangeGeneralState()
	local value = BianShenData.Instance:GetCurUseSeq()
	local has_general_skill = BianShenData.Instance:GetHasGeneralSkill()
	local is_show_general_skill = value ~= -1 or has_general_skill
	self.node_list["GeneralSkill"]:SetActive(is_show_general_skill)
	self.node_list["SkillControlNormal"]:SetActive(not is_show_general_skill)
end

function MainUIView:OpenDayTrailer()
	local data = self:GetDayTrailerList()
	if data then
		if #data > 1 then
			local btn = self.top_icon_group_1:GetIconByName("DayTrailer")
			if btn and btn:GetRootNode() then
				self.res_icon_list:SetClickObj(btn:GetRootNode(), 1)
				self.res_icon_list:SetData(data)
			end
		else
			if data[1] then
				data[1].callback()
			end
		end
	end
end

function MainUIView:GetDayTrailerList()
	local trailer_info = OpenFunData.Instance:GetNowDayOpenTrailerInfo()
	local data = {}
	if trailer_info.info_list then
		for k,v in pairs(trailer_info.info_list) do
			table.insert(data, {
				func = "TipsDayOpenTrailerView",
				res = v.res_icon,
				callback = function ()
					TipsCtrl.Instance:SetTipsDayOpenTrailer(v)
				end,
				show_eff = not trailer_info.is_tomorrow
			})
		end
	end
	return data
end

function MainUIView:ShowCrazyHappyActivity()
	local is_open = OpenFunData.Instance:CheckIsHide("CrazyHappyView")
	local open_list = CrazyHappyData.Instance:GetOpenActivityList()
	if is_open and #open_list > 0 then
		return true
	end
	return false
end

function MainUIView:ShowCrossGolb()
	local day = TimeCtrl.Instance:GetCurOpenServerDay()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local openday, endday = KuaFuTargetData.Instance:GetOpenAndEndDay()
	local openlevel = KuaFuTargetData.Instance:GetOpenLevel()
	if day > openday and day <= endday + 1 and vo.level >= openlevel then
		return true
	end
	return false
end

function MainUIView:ShowDayOpenTrailer()
	local trailer_info = OpenFunData.Instance:GetNowDayOpenTrailerInfo()
	if nil ~= trailer_info.num and trailer_info.num >= 1 and self:IsOpenFunction("DayTrailer") then
		return true
	end
	return false
end

-------------------------- 轻功指引相关 --------------------------

--轻功自动指引倒计时
function MainUIView:SetQingGongGuideClickCountDownState(state)
	if state then
		-- print_error("激活~~轻功自动指引倒计时")
		if self.qinggong_guide_click_count_down then
			GlobalTimerQuest:CancelQuest(self.qinggong_guide_click_count_down)
			self.qinggong_guide_click_count_down = nil
		end

		--自动点击时间
		if not self.qinggong_delay_auto_click_time then
			self.qinggong_delay_auto_click_time = ConfigManager.Instance:GetAutoConfig("other_config_auto").other[1].qinggong_delay_auto_click_time or 3
		end

		self.qinggong_guide_click_count_down = GlobalTimerQuest:AddDelayTimer(function()
			self.is_qinggong_guide_callby_auto = true
			local cur_guide_step = FunctionGuide.Instance:GetCurGuideStep() - 1
			if cur_guide_step <= 4 then
				self:QingGongCallBack()
				FunctionGuide.Instance.normal_guide_view:Flush("qinggongguide")
				-- print_error("时间到，触发自动指引1", cur_guide_step)
			else
				self:QingGongLandCallBack()
				FunctionGuide.Instance.normal_guide_view:Flush("qinggongguide")
				-- print_error("时间到，触发自动指引2", cur_guide_step)
			end
		end, self.qinggong_delay_auto_click_time)
	else
		-- print_error("已点击，清除轻功自动指引倒计时器")
		if self.qinggong_guide_click_count_down then
			GlobalTimerQuest:CancelQuest(self.qinggong_guide_click_count_down)
			self.qinggong_guide_click_count_down = nil
		end
	end
end

--轻功指引点击回调
function MainUIView:QingGongCallBack()
	if not self.qinggong_down_count_time then
		self.qinggong_down_count_time = {}
		self.qinggong_down_count_time[1] = ConfigManager.Instance:GetAutoConfig("other_config_auto").other[1].qinggong_guide_delay_1 or 1.5
		self.qinggong_down_count_time[2] = ConfigManager.Instance:GetAutoConfig("other_config_auto").other[1].qinggong_guide_delay_2 or 1.5
		self.qinggong_down_count_time[3] = ConfigManager.Instance:GetAutoConfig("other_config_auto").other[1].qinggong_guide_delay_3 or 1.5
		self.qinggong_down_count_time[4] = ConfigManager.Instance:GetAutoConfig("other_config_auto").other[1].qinggong_guide_delay_4 or 2.8
	end

	if self.qinggong_guide_index == 0 then
		self.qinggong_guide_index = 1
		FunctionGuide.Instance:SetQingGongGuideState(true)
		RobertMgr.Instance:ShieldAllRobert()
	else
		self.qinggong_guide_index = self.qinggong_guide_index + 1
	end
	
	MainUICtrl.Instance:ChangeFunctionTrailer(false)
	UnityEngine.Time.timeScale = 1
	Scene.Instance:GetMainRole():Jump()
	GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_ENTER_JUMP_STATE)
	self.skill_view:ShowQingGongGuideSkillEffect(false)
	-- print_error("指引UI点击回调事件  第" .. self.qinggong_guide_index .. "次点击")

	if self.qinggong_guide_timer then
		GlobalTimerQuest:CancelQuest(self.qinggong_guide_timer)
		self.qinggong_guide_timer = nil
	end

	if self.qinggong_guide_index <= 4 then
		self.qinggong_guide_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.QingGongGuideTimer, self)
			, self.qinggong_down_count_time[self.qinggong_guide_index])
	end

	if self.qinggong_guide_click_count_down then
		GlobalTimerQuest:CancelQuest(self.qinggong_guide_click_count_down)
		self.qinggong_guide_click_count_down = nil
	end
end

--轻功降落指引点击回调
function MainUIView:QingGongLandCallBack()
	-- print_error("指引UI点击回调事件  降落")
	Scene.Instance:GetMainRole():Landing()
	UnityEngine.Time.timeScale = 1
	self.qinggong_guide_index = 0
	self.is_qinggong_guide_callby_auto = false

	if self.qinggong_guide_timer then
		GlobalTimerQuest:CancelQuest(self.qinggong_guide_timer)
		self.qinggong_guide_timer = nil
	end
	FunctionGuide.Instance:SetQingGongGuideState(false)	--
	RobertMgr.Instance:UnShieldAllRobert()
	self:SetJoystickIsShow(false)		--显示摇杆
	Scene.Instance:LockCameraInQingGongGuide(false)		--解锁锁摄像机位置和角度
	self:ChangeFunctionTrailer(true)		--功能预告
	self.skill_view:ShowQingGongGuideSkillEffect(false)

	self.qinggong_guide_callback = nil
	
	if self.qinggong_guide_click_count_down then
		GlobalTimerQuest:CancelQuest(self.qinggong_guide_click_count_down)
		self.qinggong_guide_click_count_down = nil
	end
end

--暂停进入指引触发器
function MainUIView:QingGongGuideTimer()
	-- print_error("指引UI点击回调事件  暂停")
	FunctionGuide.Instance:GoNextQingGongGuideStep()
	self.is_qinggong_guide_callby_auto = false
	UnityEngine.Time.timeScale = 0
	self:SetQingGongGuideClickCountDownState(true)
	if self.qinggong_guide_timer then
		GlobalTimerQuest:CancelQuest(self.qinggong_guide_timer)
		self.qinggong_guide_timer = nil
	end
end

function MainUIView:ShowQingGongGuideSkillEffect(is_show, is_qinggong_down)
	is_qinggong_down = is_qinggong_down or false
	self.skill_view:ShowQingGongGuideSkillEffect(is_show, is_qinggong_down)
end

---------------------------------------------------------------------------------------------------------------------------
--MainUIFirstCharge
---------------------------------------------------------------------------------------------------------------------------

local ONE_TIME = 3600 * 1.5
local THREE_TIME = 3600 * 24
MainUIFirstCharge = MainUIFirstCharge or BaseClass(BaseRender)

function MainUIFirstCharge:__init()
end

function MainUIFirstCharge:__delete()
	if self.test_model_view then
		self.test_model_view:DeleteMe()
		self.test_model_view = nil
	end
end

function MainUIFirstCharge:LoadCallBack()
	self.bundle = 0
	self.asset = 0
end

function MainUIFirstCharge:ReleaseCallBack()
	self.bundle = nil
	self.asset = nil
end

function MainUIFirstCharge:OnFlush()
	if nil == self.test_model_view then
		self.test_model_view = RoleModel.New()
		self.test_model_view:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	end

	local reward_cfg = DailyChargeData.Instance:GetFirstRewardByWeek()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()

	local active_flag1, fetch_flag1 = DailyChargeData.Instance:GetThreeRechargeFlag(1)
	local active_flag2, fetch_flag2 = DailyChargeData.Instance:GetThreeRechargeFlag(2)
	local active_flag3, fetch_flag3 = DailyChargeData.Instance:GetThreeRechargeFlag(3)

	if nil == active_flag1 or nil == fetch_flag1 or 
		nil == active_flag2 or nil == fetch_flag2 or 
		nil == active_flag3 or nil == fetch_flag3 then
		return
	end

	local num_str = 0
	local show_id = 0
	local show_ka = false
	local prof = PlayerData.Instance:GetRoleBaseProf(main_role_vo.prof)
	local data = DailyChargeData.Instance:GetThreeRechargeAuto()
	self:SetGiveTimeShow()
	if active_flag1 ~= 1 or fetch_flag1 ~= 1 then
		num_str = string.format("%02d", reward_cfg.wepon_index2)
		show_id = "100" .. prof .. num_str
		local bundle, asset = ResPath.GetWeaponShowModel(show_id, "100" .. prof .. "01")
		-- if DailyChargeData.Instance:GetFirstChargeGiveTime(ONE_TIME, 1) > 0 then
		-- 	bundle, asset = "actors/forge/100022_prefab", 100022
		-- 	show_ka = true
		-- end
		if self.bundle ~= bundle or self.asset ~= asset then
			self.bundle = bundle
			self.asset = asset

			self.test_model_view:SetMainAsset(bundle, asset, function()
				local transform = nil
				if show_ka then
					transform = {position = Vector3(-0.1, 0.2, 2.2), rotation = Quaternion.Euler(0, 180, 30)}
				elseif prof == 1 then
					transform = {position = Vector3(0.0, 0.8, 3.2), rotation = Quaternion.Euler(0, 180, 75)}
				elseif prof == 2 then
					transform = {position = Vector3(0.0, 1.5, 3), rotation = Quaternion.Euler(0, 180, 30)}
				elseif prof == 3 or prof == 4 then
					transform = {position = Vector3(0.0, 1.3, 3), rotation = Quaternion.Euler(0, 180, 30)}
				end
				self.test_model_view:SetCameraSetting(transform)
			end)
			self.test_model_view:SetScale(Vector3(1, 1, 1))
			self.test_model_view:SetLoadComplete(BindTool.Bind(self.ModelLoadCompleteCallBack,self))
		end
		local bundle,asset = ResPath.GetSecondChargeViewMainUITitle(1) 
		self.node_list["ImgChargeTitle"].image:LoadSpriteAsync(bundle,asset, function ()
			self.node_list["ImgChargeTitle"].image:SetNativeSize()
		end)
		self.node_list["ImgChargeLevel"]:SetActive(false)
		return
	elseif active_flag2 ~= 1 or fetch_flag2 ~= 1 then
		show_id = data[2]["model".. prof]
		local bundle, asset = ResPath.GetWingModel(show_id)
		if self.bundle ~= bundle or self.asset ~= asset then
			self.bundle = bundle
			self.asset = asset
			self.test_model_view:SetMainAsset(bundle, asset,function()
				local part = self.test_model_view.draw_obj:GetPart(SceneObjPart.Main)
				part:SetTrigger("action")
				self.test_model_view:SetRotation(Vector3(0, 0, 0))
			end)
			self.test_model_view:SetScale(Vector3(1, 1, 1))
			self.test_model_view:SetLoadComplete(BindTool.Bind(self.ModelLoadCompleteCallBack,self))
		end
		local bundle,asset = ResPath.GetSecondChargeViewMainUITitle(2)
		self.node_list["ImgChargeTitle"].image:LoadSpriteAsync(bundle,asset, function ()
			self.node_list["ImgChargeTitle"].image:SetNativeSize()
		end)
		local bundle,asset = ResPath.GetSecondChargeViewMainUILevel(2) 
		self.node_list["ImgChargeLevel"].image:LoadSpriteAsync(bundle,asset, function ()
			self.node_list["ImgChargeLevel"].image:SetNativeSize()
			self.node_list["ImgChargeLevel"]:SetActive(false)
		end)		
		return
	elseif active_flag3 ~= 1 or fetch_flag3 ~= 1 then
		show_id = data[3]["model".. prof]
		local bundle, asset = ResPath.GetMountModel(show_id)
		if self.bundle ~= bundle or self.asset ~= asset then
			self.bundle = bundle
			self.asset = asset
			self.test_model_view:SetMainAsset(bundle, asset,function()
				self.test_model_view:SetLoopAnimal("rest")
				self.test_model_view:SetRotation(Vector3(0, -35, 0))
				local transform = {position = Vector3(0.0, 1.7, 8), rotation = Quaternion.Euler(0, 180, 0)}
				self.test_model_view:SetCameraSetting(transform)
			end)
			self.test_model_view:SetScale(Vector3(0.8, 0.8, 0.8))
			self.test_model_view:SetLoadComplete(BindTool.Bind(self.ModelLoadCompleteCallBack,self))
		end
		local bundle,asset = ResPath.GetSecondChargeViewMainUITitle(3)
		self.node_list["ImgChargeTitle"].image:LoadSpriteAsync(bundle,asset, function ()
			self.node_list["ImgChargeTitle"].image:SetNativeSize()
		end)
		local bundle,asset = ResPath.GetSecondChargeViewMainUILevel(3) 
		self.node_list["ImgChargeLevel"].image:LoadSpriteAsync(bundle,asset, function ()
			self.node_list["ImgChargeLevel"].image:SetNativeSize()
			self.node_list["ImgChargeLevel"]:SetActive(false)
		end)	
		return
	end
end

function MainUIFirstCharge:SetGiveTimeShow()
	local active_flag1, fetch_flag1 = DailyChargeData.Instance:GetThreeRechargeFlag(1)
	local is_show_one_time = false
	local is_show_three_time = false
	local one_give_time = DailyChargeData.Instance:GetFirstChargeGiveTime(ONE_TIME, 1)
	if self.one_give_timer then
		CountDown.Instance:RemoveCountDown(self.one_give_timer)
		self.one_give_timer = nil
	end
	if one_give_time > 0 and active_flag1 ~= 1 then
		is_show_one_time = true
		function ChangeGiveTime(elapse_time, total_time)
			local time = math.floor(total_time - elapse_time + 0.5)
			if self.node_list["OneTime"] then
				self.node_list["OneTime"].text.text = TimeUtil.FormatSecond(time)
			end
		end
		self.one_give_timer = CountDown.Instance:AddCountDown(one_give_time, 1, ChangeGiveTime, function ()
			if self.one_give_timer then
				CountDown.Instance:RemoveCountDown(self.one_give_timer)
				self.one_give_timer = nil
			end
			self:SetGiveTimeShow()
		end)
	else
		local three_give_time = DailyChargeData.Instance:GetFirstChargeGiveTime(THREE_TIME, 3)
		if self.three_give_timer then
			CountDown.Instance:RemoveCountDown(self.three_give_timer)
			self.three_give_timer = nil
		end
		if three_give_time > 0 then
			is_show_three_time = true
			function ChangeGiveTime(elapse_time, total_time)
			local time = math.floor(total_time - elapse_time + 0.5)
				if self.node_list["ThreeTime"] then
					self.node_list["ThreeTime"].text.text = TimeUtil.FormatSecond(time)
				end
			end
			self.three_give_timer = CountDown.Instance:AddCountDown(three_give_time, 1, ChangeGiveTime, function ()
				if self.three_give_timer then
					CountDown.Instance:RemoveCountDown(self.three_give_timer)
					self.three_give_timer = nil
				end
				self:SetGiveTimeShow()
			end)
		end
	end
	self.node_list["ImgChargeTitle"]:SetActive(not is_show_one_time and not is_show_three_time)
	self.node_list["OneImage"]:SetActive(is_show_one_time)
	self.node_list["ThreeImage"]:SetActive(not is_show_one_time and is_show_three_time)
end

function MainUIFirstCharge:ModelLoadCompleteCallBack(part, obj) 							-- 不知道W2写这个有什么用
	local move_root = obj.transform:FindHard("MoveRoot")
	if move_root then
		self.animator = obj.transform:FindHard("MoveRoot"):GetComponent(typeof(UnityEngine.Animator))
	end
	if self.animator then
		self.animator.enabled = false
	end
end
