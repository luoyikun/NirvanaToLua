FbIconView = FbIconView or BaseClass(BaseView)
function FbIconView:__init()
	self.ui_config = {{"uis/views/fubenview_prefab", "FBIconsView"}}
	self.view_layer = UiLayer.MainUILow
	self.camera_mode = UICameraMode.UICameraLow
	self.fb_time = 0
	self.active_close = false
	self.fight_info_view = true
	self.is_safe_area_adapter = true
	self.monster_diff_time_list = {[1] = 0, [2] = 0}
	self.monster_variable_list = {}
	self.montser_count_down_list = {}
	self.click_call_back_list = {}
	self.monster_id = 0
	self.is_show_skymoney_text = false
	self.show_monster_had_flush = {}
	self.show_monster_gray = {}
	self.guaji_tag_list = {}
	self.role_attr_change_event = BindTool.Bind1(self.OnRoleAttrValueChange, self)
end

function FbIconView:LoadCallBack()
	self.is_all_buy = true
	self.potion_flag = true
	self.buff_flag = true
	self.shuijing_buff_flag = true
	self.xiuluo_buff_flag = true
	self.tomb_explore_buff_flag = true
	self.fk_borderland_buff_flag = true
	self.is_open = true
	self.node_list["TimeTxt"]:SetActive(true)
	self.node_list["ImgTimeTxt"]:SetActive(true)
	self.node_list["QuestionNode"]:SetActive(false)
	self.node_list["ThisRewardNode"]:SetActive(false)
	self.node_list["BtnRewardnight"]:SetActive(false)
	self.node_list["HotSpringFish"]:SetActive(false)
	self.node_list["ExitFbBtn"].button:AddClickListener(BindTool.Bind(self.OnClickExit, self))
	self.node_list["Explain"].button:AddClickListener(BindTool.Bind(self.OnClicExplain, self))
	self.node_list["BuyBuff"].button:AddClickListener(BindTool.Bind(self.OnClickExpBuff, self))
	self.node_list["BuyShuijingBuff"].button:AddClickListener(BindTool.Bind(self.OnClickShuijingBuff, self))
	self.node_list["BuyPotion"].button:AddClickListener(BindTool.Bind(self.OnClickExpPotion, self))
	self.node_list["GuildBoss"].button:AddClickListener(BindTool.Bind(self.OnClickGuildBoss, self))
	self.node_list["GuildMoneyTree"].button:AddClickListener(BindTool.Bind(self.OpenMoneyTree, self))
	self.node_list["MonsterIcon1"].button:AddClickListener(BindTool.Bind(self.OnClickBossIcon, self, 1))
	self.node_list["MonsterIcon2"].button:AddClickListener(BindTool.Bind(self.OnClickBossIcon, self, 2))
	self.node_list["BtnRewardnight"].button:AddClickListener(BindTool.Bind(self.OnClickNuZhanList, self))

	self.node_list["AutoBtn"].toggle:AddClickListener(BindTool.Bind(self.OnClickAutoBtn, self))
	self.node_list["GuildFightIcon"].button:AddClickListener(BindTool.Bind(self.OnClickGuildFightRank, self))
	self.node_list["BtnZhaoJi"].button:AddClickListener(BindTool.Bind(self.OnClickZhaoJi, self))
	self.node_list["ExitFB"].button:AddClickListener(BindTool.Bind(self.OnClickRewardIcon, self))
	self.node_list["BtnGCZhaoJi"].button:AddClickListener(BindTool.Bind(self.OnClickGuildCall, self))
	self.node_list["BtnReward"].button:AddClickListener(BindTool.Bind(self.OnClickReward, self))
	self.node_list["ZhiZun"].button:AddClickListener(BindTool.Bind(self.OnClickGoToShuiJing, self))
	self.node_list["XiuLuoTaRank"].button:AddClickListener(BindTool.Bind(self.OnClickOpenXiuLuoTaRank, self))
	self.node_list["BtnDrop"].button:AddClickListener(BindTool.Bind(self.OnClickOpenDrop, self))
	self.node_list["ShowItemBtn"].button:AddClickListener(BindTool.Bind(self.OnClickBossShowItemTips, self))
	self.node_list["ShowItemBtn2"].button:AddClickListener(BindTool.Bind(self.OnClickBossShowItemTips, self))

	self.node_list["BtnLiuJieZhaoJi"].button:AddClickListener(BindTool.Bind(self.OnClickLiuJieGuildCall, self))

	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)

	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE,
		BindTool.Bind(self.MainOpenComlete, self))
	self:Flush()
	self.show_menu = false

	if self.monster_id > 0 then
		self:SetMonsterInfo(self.monster_id)
		self.monster_id = 0
	else
		self:SetMo_LongIcon()
	end

	--跨服珍宝秘境BOSS按钮打开
	local scene_type = Scene.Instance:GetSceneType()
	-- if scene_type == SceneType.MonthBlackWindHigh  then
	--	self.node_list["MonsterIcon1"]:SetActive(true)
	-- else
		self.node_list["MonsterIcon1"]:SetActive(false)
	-- end
	-- if scene_type == SceneType.LuandouBattle then
	-- 	self.node_list["MonsterIcon1"]:SetActive(scene_type == SceneType.LuandouBattle)
	-- end
	self.node_list["HP"]:SetActive(scene_type == SceneType.LuandouBattle)
	self.node_list["MonsterIconTxt"]:SetActive(not (scene_type == SceneType.LuandouBattle))
	self.node_list["ImgTextBg"]:SetActive(not (scene_type == SceneType.LuandouBattle))
	-- self.node_list["MonsterIconTimeTxt1"]:SetActive(not (scene_type == SceneType.LuandouBattle))
	self.node_list["BossImageTxt"]:SetActive(not (scene_type == SceneType.LuandouBattle))

	if scene_type == SceneType.MonthBlackWindHigh then
		self:InitBossScrollList()
	else
		self.node_list["BossListPanel"]:SetActive(false)
		self.node_list["HideBossList"]:SetActive(false)
	end
	self.boss_cell_list = {}
	self.can_tween = true
	-- if scene_type == SceneType.Kf_XiuLuoTower then
	-- 	self.node_list["MonsterIcon2"]:SetActive(true)
	-- else
	-- 	self.node_list["MonsterIcon2"]:SetActive(false)
	-- end
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.FbIconView, BindTool.Bind(self.GetUiCallBack, self))
end

function FbIconView:__delete()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.boss_text_timer then
		GlobalTimerQuest:CancelQuest(self.boss_text_timer)
		self.boss_text_timer = nil
	end

	if self.flush_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.flush_count_down)
		self.flush_count_down = nil
	end	
end

function FbIconView:ReleaseCallBack()
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end
	if self.main_view_complete ~= nil then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end
	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end
	self.click_call_back_list = {}

	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.FbIconView)
	end

	if self.shuijing_count_down then
		CountDown.Instance:RemoveCountDown(self.shuijing_count_down)
		self.shuijing_count_down = nil
	end

	if self.xiuluo_count_down then
		CountDown.Instance:RemoveCountDown(self.xiuluo_count_down)
		self.xiuluo_count_down = nil
	end

	if self.tomb_explore_count_down then
		CountDown.Instance:RemoveCountDown(self.tomb_explore_count_down)
		self.tomb_explore_count_down = nil
	end

	if self.time_quest then
		CountDown.Instance:RemoveCountDown(self.time_quest)
		self.time_quest = nil
	end
	
	if self.boss_text_timer then
		GlobalTimerQuest:CancelQuest(self.boss_text_timer)
		self.boss_text_timer = nil
	end

	if self.time_quest_month then
		CountDown.Instance:RemoveCountDown(self.time_quest_month)
		self.time_quest_month = nil
	end

	if self.hot_spring_count_down then
		CountDown.Instance:RemoveCountDown(self.hot_spring_count_down)
		self.hot_spring_count_down = nil
	end

	if nil == self.buff_timer_delay then
		GlobalTimerQuest:CancelQuest(self.buff_timer_delay)
		self.buff_timer_delay = nil
	end

	for k, v in pairs(self.boss_cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.boss_cell_list = nil

	if next(self.guaji_tag_list) ~= nil then
		self.guaji_tag_list = {}
	end

	self:RemoveQuestionCountDown()
	self:RemoveUniversalCountDown()
	-- 清理变量和对象
	self.guild_boss_icon = nil
	self.exit_fb_btn = nil
	self.time_text = nil
	self.show_text = nil
	self.show_btn_potion = nil
	self.show_btn_buff = nil
	self.buy_buff = nil
	self.buy_potion = nil
	self.is_on_potion = nil
	self.is_on_buff = nil
	self.exit_btn_vis = nil

	self.show_btn_time = nil

	self.show_btn_reward = nil
	self.list_view_delegate = nil
	self.show_guildfight_rank_icon = nil
	self.guild_now_rank_des = nil
	self.monster_variable_list = {}
	self.buy_shuijing_buff = nil
	self.show_btn_shuijing_buff = nil
	self.is_on_shuijing_buff = nil
	self.shui_jing_buff_text = nil
	self.on_buff_des = nil
	self:CanCelKFBorderlandBossFlushTimer()
	self:CancelStandyCountTimer()
end

function FbIconView:ExitWithTips(str)
	local yes_func = function ()
		FuBenCtrl.Instance:SendExitFBReq()
		FuBenData.Instance:ClearFBDropInfo()
		local scene_type = Scene.Instance:GetSceneType()
		if scene_type == SceneType.PhaseFb or scene_type == SceneType.TowerDefend or scene_type == SceneType.WeaponMaterialsFb then
			GlobalTimerQuest:AddDelayTimer(function()
				ViewManager.Instance:Open(ViewName.FBFailFinishView)
			end, 1)
		end

		if scene_type == SceneType.CrossFB then
			CrossServerData.Instance:SetLeaveCrossFbState(true)
		end
	end
	TipsCtrl.Instance:ShowCommonAutoView("", str or Language.Common.ExitCurrentScene, yes_func)
end

function FbIconView:OnClickExit()
	local scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if scene_cfg.fight_cant_exit and 1 == scene_cfg.fight_cant_exit then
		local main_role = Scene.Instance:GetMainRole()
		if main_role:IsFightStateByRole() or (main_role:IsFightState() and main_role.vo.attack_mode ~= GameEnum.ATTACK_MODE_PEACE) then
			SysMsgCtrl.Instance:ErrorRemind(Language.Activity.FightingCantExitFb)
			return
		end
	end
	local scene_id = Scene.Instance:GetSceneId()
	if BossData.Instance:IsWorldBossScene(scene_id)
	or AncientRelicsData.IsAncientRelics(scene_id)
	or RelicData.Instance:IsRelicScene(scene_id) then
		GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
		local scene_logic = Scene.Instance:GetSceneLogic()
		local x, y = scene_logic:GetTargetScenePos(scene_id)
		if x == nil or y == nil then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotToTarget)
			return
		end
		GuajiCtrl.Instance:MoveToPos(scene_id, x, y, 0, 0)
		return
	end
	if BossData.Instance:IsDabaoBossScene(scene_id)
	or BossData.Instance:IsFamilyBossScene(scene_id)
	or BossData.Instance:IsMikuBossScene(scene_id)
	or BossData.Instance:IsActiveBossScene(scene_id)
	or BossData.Instance:IsSecretBossScene(scene_id) then
		local func = function()
			if IS_ON_CROSSSERVER and BossData.Instance:IsBossFamilyKfScene() then

				BossCtrl.Instance:SendEnterBossFamily(BOSS_ENTER_TYPE.LEAVE_BOSS_SCENE)
				CrossServerCtrl.Instance:GoBack()
			else
				BossCtrl.Instance:SendEnterBossFamily(BOSS_ENTER_TYPE.LEAVE_BOSS_SCENE)
			end
			--BossCtrl.Instance:SendEnterBossFamily(BOSS_ENTER_TYPE.LEAVE_BOSS_SCENE)
		end
		TipsCtrl.Instance:ShowCommonAutoView("", Language.Common.ExitCurrentScene, func)
		return
	end
	
	if scene_cfg.out_ui == 1 then
		--如果当前场景为跨服钓鱼
		local scene_type = Scene.Instance:GetSceneType()
		if scene_type == SceneType.KF_Fish and CrossFishingData.Instance:IsCanExchange() then
			local ok_fun = function()
				FishingCtrl.Instance:OnOpenCreelHandler()
		 	end
		 	local cancel_fun = function()
		 		FuBenCtrl.Instance:SendExitFBReq()
		 	end
			-- TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, Language.Fishing.ExitTips, nil, cancel_fun, false, nil, nil, nil, nil, nil, true, nil, nil, Language.Common.ExitScene, nil, nil, nil, true)
			TipsCtrl.Instance:ShowCommonAutoView("", Language.Fishing.ExitTips, ok_fun, cancel_fun, nil , nil, Language.Common.ExitScene)
			return
		elseif scene_type == SceneType.CrossLieKun_FB then
			local flag = LingKunBattleData.Instance:IsDoorClose() and Scene.Instance:GetSceneId() == 1150 		--鲲王大陆的
			local str = flag and Language.LingKunBattle.ExitCurrentScene or Language.LingKunBattle.ExitWaiHaiScene 
			self:ExitWithTips(str)
			return
		end
		self:ExitWithTips(scene_cfg.ui_instructions)
	 	return
	end
	FuBenCtrl.Instance:SendExitFBReq()

end

function FbIconView:SetDownTimeActive(enable)
	self.node_list["TxtTimeShow"]:SetActive(enable)
end

-- 玩法说明
function FbIconView:OnClicExplain()
	if self.tip_id then
		TipsCtrl.Instance:ShowHelpTipView(self.tip_id)
		return
	end
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if fb_scene_cfg then
		TipsCtrl.Instance:ShowHelpTipView(fb_scene_cfg.fb_desc)
	end
end

function FbIconView:OnClickOpenFuBenView()
	TipsCtrl.Instance:OpenFuBenShowTip()
end

function FbIconView:OnClickGoToShuiJing()
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	GuajiCtrl.SetAtkValid(false)
	local ZhiZun_cfg = CrossCrystalData.Instance:GetMaxBigShuiJingInfoList()
	local other_cfg = CrossCrystalData.Instance:GetOtherCfg()
	local x, y = other_cfg.crystal_pos_x, other_cfg.crystal_pos_y

	local main_role = Scene.Instance:GetMainRole()
	local self_x, self_y = main_role:GetLogicPos()
	if x - 2 <= self_x and x + 2 >= self_x then
		if y - 2 <= self_y and y + 2 >= self_y then
			MoveCache.param1 = ZhiZun_cfg[1].gather_id
			MoveCache.x = x
			MoveCache.y = y
			GuajiCache.target_obj_id = ZhiZun_cfg[1].gather_id
			GuajiCtrl.Instance:OnOperateGatherById()
			return 
		end
	end
	MoveCache.end_type = MoveEndType.GatherById
	MoveCache.param1 = ZhiZun_cfg[1].gather_id
	GuajiCache.target_obj_id = ZhiZun_cfg[1].gather_id
	GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), x, y, 2, 3)
end

function FbIconView:OnClickOpenXiuLuoTaRank()
	KuaFuXiuLuoTowerCtrl.Instance:OpenTimeRankList()
end

function FbIconView:OnClickOpenDrop()
	local num = FuBenData.Instance:GetFBDropInfoItemNum()
	if num <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.NotDropItem)
		return
	end
	-- if self.is_open then
		TipsCtrl.Instance:OpenFBDropView()
	-- else
	-- 	TipsCtrl.Instance:CloseFBDropView()
	-- end
	-- self.is_open = not self.is_open
end

function FbIconView:OnClickZhaoJi()
	GuildFightCtrl.Instance:QiuJiuHandler()
end

function FbIconView:SetBuffBubbles()
	self.node_list["ImageBuff"]:SetActive(false)
end

function FbIconView:SetShuijingBuffBubbles()
	self.node_list["BtnIsOnShuijingBuff"]:SetActive(false)
end

function FbIconView:SetShuijingBuffBubblesText()
	local crystal_info =  CrossCrystalData.Instance:GetCrystalInfo()
	local seconds = math.floor(crystal_info.gather_buff_time - TimeCtrl.Instance:GetServerTime())
	if seconds > 0 then
		self.node_list["ShuiJingBuffTxt"].text.text = TimeUtil.FormatSecond(seconds, seconds > 3600 and 3 or 2)
		if self.shuijing_count_down then
			CountDown.Instance:RemoveCountDown(self.shuijing_count_down)
			self.shuijing_count_down = nil
		end
		self.shuijing_count_down = CountDown.Instance:AddCountDown(seconds, 1, BindTool.Bind(self.ShuijingBuffTimeCountDown, self))
	end
end

function FbIconView:ShuijingBuffTimeCountDown(elapse_time, total_time)
	self.node_list["BuyShuijingBuff"].animator:SetBool("shake", false)
	local diff_timer = total_time - elapse_time
	self.node_list["ShuiJingBuffTxt"].text.text = TimeUtil.FormatSecond(diff_timer, diff_timer > 3600 and 3 or 2)
	if diff_timer <= 0 then
		self.node_list["ShuiJingBuffTxt"].text.text = ""
	end
end

function FbIconView:SetXiuLuoBuffBubblesText()
	local gather_buff_time = KuaFuXiuLuoTowerData.Instance:GetBossGatherEndTime() or 0
	local seconds = math.floor(gather_buff_time - TimeCtrl.Instance:GetServerTime())
	if seconds > 0 then
		self.node_list["ShuiJingBuffTxt"].text.text = TimeUtil.FormatSecond(seconds, seconds > 3600 and 3 or 2)
		if self.xiuluo_count_down then
			CountDown.Instance:RemoveCountDown(self.xiuluo_count_down)
			self.xiuluo_count_down = nil
		end
		self.xiuluo_count_down = CountDown.Instance:AddCountDown(seconds, 1, BindTool.Bind(self.ShuijingBuffTimeCountDown, self))
	end
end

function FbIconView:SetTombExploreBuffTime()
	local gather_buff_time = TombExploreData.Instance:GetTombFbBuffTime()
	local seconds = math.floor(gather_buff_time - TimeCtrl.Instance:GetServerTime())
	if seconds > 0 then
		self.node_list["ShuiJingBuffTxt"].text.text = TimeUtil.FormatSecond(seconds, seconds > 3600 and 3 or 2)
		if self.tomb_explore_count_down then
			CountDown.Instance:RemoveCountDown(self.tomb_explore_count_down)
			self.tomb_explore_count_down = nil
		end
		self.tomb_explore_count_down = CountDown.Instance:AddCountDown(seconds, 1, BindTool.Bind(self.ShuijingBuffTimeCountDown, self))
	end
end

function FbIconView:SetKFBorderlandBuffTime()
	local gather_buff_time = KuaFuBorderlandData.Instance:GetKFBorderlandBuffTime()
	local seconds = math.floor(gather_buff_time - TimeCtrl.Instance:GetServerTime())
	if seconds > 0 then
		self.node_list["ShuiJingBuffTxt"].text.text = TimeUtil.FormatSecond(seconds, seconds > 3600 and 3 or 2)
		if self.tomb_explore_count_down then
			CountDown.Instance:RemoveCountDown(self.tomb_explore_count_down)
			self.tomb_explore_count_down = nil
		end
		self.tomb_explore_count_down = CountDown.Instance:AddCountDown(seconds, 1, BindTool.Bind(self.ShuijingBuffTimeCountDown, self))
	end
end

-- function FbIconView:XiuLuoBuffTimeCountDown(elapse_time, total_time)
-- 	self.node_list["BuyShuijingBuff"].animator:SetBool("shake", false)
-- 	local diff_timer = total_time - elapse_time
-- 	self.node_list["ShuiJingBuffTxt"].text.text = TimeUtil.FormatSecond(diff_timer, diff_timer > 3600 and 3 or 2)
-- 	if diff_timer <= 0 then
-- 		self.node_list["ShuiJingBuffTxt"].text.text = ""
-- 	end
-- 	-- -- 无敌称号时间小于20秒开始闪烁
-- 	-- if diff_timer <= 20 and self.xiuluo_wudi_title then
-- 	-- 	Scene.Instance:GetSceneLogic():ChangeTitle()
-- 	-- 	self.xiuluo_wudi_title = false
-- 	-- end
-- end

function FbIconView:SetPotionBubbles()
	self.node_list["PotionImage"]:SetActive(false)
end

function FbIconView:OnClickExpBuff()
	self:SetBuffBubbles()
	-- if self.buff_flag == true then
	-- 	self.node_list["BuyBuff"].animator:SetBool("shake", false)
	-- 	self.buff_flag = false
	-- end
	local user_info = YiZhanDaoDiData.Instance:GetYiZhanDaoDiUserInfo()
	if user_info.gongji_guwu_per == 50 then
		SysMsgCtrl.Instance:ErrorRemind(Language.YiZhanDaoDi.MaxGuWu)
		return
	end
	
	if Scene.Instance:GetSceneType() == SceneType.ExpFb then 	-- 经验副本，鼓舞提示框特殊处理
		TipsCtrl.Instance:TipsExpFuBenGuWuView()
	else
		TipsCtrl.Instance:TipsExpInSprieFuBenView()
	end
end

function FbIconView:OnClickShuijingBuff()
	local scene_type = Scene.Instance:GetSceneType()
	self:SetShuijingBuffBubbles()
	if self.shuijing_buff_flag == true then
		self.node_list["BuyShuijingBuff"].animator:SetBool("shake", false)
		self.shuijing_buff_flag = false
	elseif scene_type == SceneType.Kf_XiuLuoTower then
		if self.xiuluo_buff_flag then
			self.node_list["BuyShuijingBuff"].animator:SetBool("shake", false)
			self.xiuluo_buff_flag = false
		end
	elseif scene_type == SceneType.TombExplore then
		if self.tomb_explore_buff_flag then
			self.node_list["BuyShuijingBuff"].animator:SetBool("shake", false)
			self.tomb_explore_buff_flag = false
		end
	elseif scene_type == SceneType.KF_Borderland then
		if self.fk_borderland_buff_flag then
			self.node_list["BuyShuijingBuff"].animator:SetBool("shake", false)
			self.fk_borderland_buff_flag = false
		end
	end

	local func = function()
		CrossCrystalCtrl.OnShuijingBuyBuff()
	end

	local func2 = function()
		--self.xiuluo_wudi_title = true
		ActivityCtrl.Instance:OnKFtowerBuff()
	end

	local func3 = function()
		TombExploreCtrl.Instance:OnTombBuyGatherBuff()
	end

	local func4 = function()
		KuaFuBorderlandCtrl.Instance:SendCSCrossBianJingZhiDiBuyBuff()
	end

	local other_cfg = ConfigManager.Instance:GetAutoConfig("activityshuijing_auto").other[1]
	local xiuluo_cfg = ConfigManager.Instance:GetAutoConfig("kuafu_rongyudiantang_auto").other[1]
	if scene_type == SceneType.Kf_XiuLuoTower and xiuluo_cfg then
		local gather_buff_time =  KuaFuXiuLuoTowerData.Instance:GetBossGatherEndTime() or 0
		if gather_buff_time - TimeCtrl.Instance:GetServerTime() > 0 then
			local time = TimeUtil.FormatSecond(gather_buff_time - TimeCtrl.Instance:GetServerTime(), 7)
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.XiuLuo.HasBuyBuff, time))
			return
		end
		TipsCtrl.Instance:ShowCommonAutoView(nil, string.format(Language.CrossCrystal.BuyBuffTips, xiuluo_cfg.buff_gold, xiuluo_cfg.buff_time / 60), func2)
	elseif scene_type == SceneType.ShuiJing or scene_type == SceneType.CrossShuijing then
		TipsCtrl.Instance:ShowCommonAutoView(nil, string.format(Language.CrossCrystal.BuyBuffTips, other_cfg.gather_buff_gold, other_cfg.gather_max_times), func)
	elseif scene_type == SceneType.TombExplore then
		local gather_buff_time = TombExploreData.Instance:GetTombFbBuffTime() or 0
		if gather_buff_time - TimeCtrl.Instance:GetServerTime() > 0 then
			local time = TimeUtil.FormatSecond(gather_buff_time - TimeCtrl.Instance:GetServerTime(), 7)
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.XiuLuo.HasBuyBuff, time))
			return
		end
		local tomb_config = TombExploreData.Instance:GetTombActivityOtherCfg()
		if tomb_config then
			local time = tomb_config.gather_buff_time / 60 or 0
			TipsCtrl.Instance:ShowCommonAutoView(nil, string.format(Language.CrossCrystal.BuyBuffTips, tomb_config.gather_buff_gold, time), func3)
		end
	elseif scene_type == SceneType.KF_Borderland then
		local gather_buff_time = KuaFuBorderlandData.Instance:GetKFBorderlandBuffTime() or 0
		if gather_buff_time - TimeCtrl.Instance:GetServerTime() > 0 then
			local time = TimeUtil.FormatSecond(gather_buff_time - TimeCtrl.Instance:GetServerTime(), 7)
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.XiuLuo.HasBuyBuff, time))
			return
		end
		local kf_borderland_config = KuaFuBorderlandData.Instance:GetKFBorderlandActivityOtherCfg()
		if kf_borderland_config then
			local time = kf_borderland_config.gather_buff_time / 60 or 0
			TipsCtrl.Instance:ShowCommonAutoView(nil, string.format(Language.CrossCrystal.BuyBuffTips, kf_borderland_config.gather_buff_gold, time), func4)
		end
	end
end

function FbIconView:OnClickRewardIcon()
	CityCombatCtrl.Instance:OpenRewardView()
end

function FbIconView:OnClickExpPotion()
	self:SetPotionBubbles()
	-- if self.potion_flag == true then
	-- 	self.node_list["BuyPotion"].animator:SetBool("shake", false)
	-- 	self.potion_flag = false
	-- end
	TipsCtrl.Instance:ShowTipExpFubenView()
end

function FbIconView:PotionEffectState()

	if FightData.Instance:GetMainRoleDrugAddExp() ~= 0 then
		self.node_list["BuyPotion"].animator:SetBool("shake", false)
	end

	local other_cfg = FuBenData.Instance:GetExpFBOtherCfg()
	local guwu_count = FuBenData.Instance:GetExpFuBenGuWuCount()
	if guwu_count >= other_cfg.max_buff_time then
		self.node_list["BuyBuff"].animator:SetBool("shake", false)
		self.node_list["ImageBuff"]:SetActive(false)
	else
		self.node_list["BuyBuff"].animator:SetBool("shake", true)
	end
end

function FbIconView:OpenCallBack()
	self.show_monster_gray = {}
	--先把按钮都隐藏掉
	self.node_list["GuildFightIcon"]:SetActive(false)
	self.node_list["BtnShowPotion"]:SetActive(false)
	self.node_list["BtnBuff"]:SetActive(false)
	self.node_list["BtnShuijingBuff"]:SetActive(false)
	self.node_list["BtnZhaoJi"]:SetActive(false)
	self.node_list["BtnGCZhaoJi"]:SetActive(false)
	self.node_list["XiuLuoTaRank"]:SetActive(false)
	for i = 1, 2  do
		--self.node_list["ImgMaskIcon" .. i]:SetActive(true)
		self.show_monster_gray[i] = false
	end

	GlobalTimerQuest:AddDelayTimer(function()
		GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)
		end, 0.1)
	self:Flush()
	local scene_id = Scene.Instance:GetSceneId()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.ExpFb then
		self.node_list["BtnShowPotion"]:SetActive(true)
		self.node_list["BtnBuff"]:SetActive(true)
		local role_level = PlayerData.Instance.role_vo.level
		if not SettingData.Instance:HasEnterFb(scene_type, scene_id) then
			self.node_list["PotionImage"]:SetActive(true)
			self.node_list["ImageBuff"]:SetActive(true)
			self.node_list["BuffDesTxt"].text.text = Language.FuBen.IconViewBuffDefaultDes
		else
			self.node_list["PotionImage"]:SetActive(false)
			self.node_list["ImageBuff"]:SetActive(false)
		end
	elseif scene_type == SceneType.ShuiJing then -- 水晶
		self.node_list["BtnShuijingBuff"]:SetActive(true)
		-- local crystal_info =  CrossCrystalData.Instance:GetCrystalInfo()
		-- local seconds = math.floor(crystal_info.gather_buff_time - TimeCtrl.Instance:GetServerTime())
		-- if seconds <= 0 then
		-- 	self.node_list["BtnIsOnShuijingBuff"]:SetActive(true)
		-- end
		self.node_list["ZhiZun"]:SetActive(not ActivityData.Instance:GetActivityIsReady(ACTIVITY_TYPE.SHUIJING))
		self:SetShuijingBuffBubblesText()
	elseif scene_type == SceneType.Kf_XiuLuoTower then -- 跨服修罗塔
		local cur_layer = KuaFuXiuLuoTowerData.Instance:GetCurrentLayer()
		if cur_layer == 10 then
			self.node_list["BtnShuijingBuff"]:SetActive(true)
			self.node_list["ZhiZun"]:SetActive(false)
			--self.node_list["MonsterIcon2"]:SetActive(true)
			-- local gather_buff_time =  KuaFuXiuLuoTowerData.Instance:GetBossGatherEndTime() or 0
			-- local seconds = math.floor(gather_buff_time - TimeCtrl.Instance:GetServerTime())
			-- self.node_list["BtnIsOnShuijingBuff"]:SetActive(seconds <= 0)
			self:SetXiuLuoBuffBubblesText()
		else
			self.node_list["BtnShuijingBuff"]:SetActive(false)
		end
	elseif scene_type == SceneType.ChaosWar then	-- 一战到底
		self:SetBuffBtnInYiZhanDaoDiScene()
	elseif scene_type == SceneType.LingyuFb then
		self.node_list["GuildFightIcon"]:SetActive(true)

		local role = GameVoManager.Instance:GetMainRoleVo()
		local tuanzhang_uid = GuildDataConst.GUILDVO.tuanzhang_uid or 0
		if role and role.role_id then
			self.node_list["BtnZhaoJi"]:SetActive(tuanzhang_uid == role.role_id)
		else
			self.node_list["BtnZhaoJi"]:SetActive(false)
		end
		local time = GuildFightData.Instance:GetRemindZhaojiTimes() or 0
		self.node_list["TxtZhaoJi"].text.text = Language.Guild.ZhaojiRestTime .. time
	elseif scene_type == SceneType.GongChengZhan then
		local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
		local vis = mainrole_vo.guild_post == GuildDataConst.GUILD_POST.TUANGZHANG
		self.node_list["BtnGCZhaoJi"]:SetActive(vis)
	elseif scene_type == SceneType.LuandouBattle or scene_type == SceneType.KF_NightFight then
		self.node_list["BtnReward"]:SetActive(true)
	elseif scene_type == SceneType.CrossGuild then
		local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
		local vis = mainrole_vo.guild_post == GuildDataConst.GUILD_POST.TUANGZHANG
		self.node_list["BtnLiuJieZhaoJi"]:SetActive(vis)
		self:FlushLiuJieZhaoJiRestTime()
	elseif scene_type == SceneType.KF_Borderland then
		self:FlushKFBorderlandZhaoJiRestTime()
		self.node_list["BtnLiuJieZhaoJi"]:SetActive(true)
	end
	self.node_list["AutoBtnImage"]:SetActive(PlayerData.Instance.role_vo.vip_level < 3)

	PlayerData.Instance:ListenerAttrChange(self.role_attr_change_event)

	local scene_id = Scene.Instance:GetSceneId()
	if not BossData.Instance:IsWorldBossScene(scene_id) then
		self.node_list["TimeTxt"]:SetActive(true)
		self.node_list["ImgTimeTxt"]:SetActive(true)
	end
	self.node_list["ImgTimeTxt"]:SetActive(false)
	self.node_list["QuestionNode"]:SetActive(false)
	-- self.node_list["ThisRewardNode"]:SetActive(false)
	if scene_type == SceneType.KF_NightFight or scene_type == SceneType.LuandouBattle then
		self.node_list["BtnRewardnight"]:SetActive(true)
	end

	if scene_type == SceneType.GuildStation then -- 军团驻地
		self:FlushMoneyTree()
		self:ShowGuildBossButton()
	end
	if scene_type == SceneType.LuandouBattle or scene_type == SceneType.KF_NightFight or scene_type == SceneType.MonthBlackWindHigh then
		self.node_list["ExitFB1TimeTxt_1"]:SetActive(true)
		self.node_list["TimeTxt"]:SetActive(false)
	end

	local cur_layer = KuaFuXiuLuoTowerData.Instance:GetCurrentLayer() or 0
	local is_show_item_tips = (scene_type == SceneType.Kf_XiuLuoTower and cur_layer == 10 ) or scene_type == SceneType.ShuiJing or scene_type == SceneType.TombExplore
	self.node_list["ShowItemBtn"]:SetActive(is_show_item_tips)
	if is_show_item_tips then
		self:FlushImgShuiJingBuff()
	end

	self.is_boss_active = false
end

function FbIconView:OnClickGuildCall()
	local times, cost = CityCombatData.Instance:GetGuildCallCost()
	if times < 0 or cost < 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.CityCombat.TimesLack)
		return
	end

	local func = function ()
		GuildCtrl.Instance:SendSendGuildSosReq(GUILD_SOS_TYPE.GUILD_SOS_TYPE_GONGCHENGZHAN)
	end
	local describe = times > 0 and string.format(Language.CityCombat.GuildCall_1, cost) or Language.CityCombat.GuildCall_2
	if cost <= 0 then
		TipsCtrl.Instance:ShowCommonAutoView("", describe, func)
	else
		TipsCtrl.Instance:ChangeAutoViewAuto(false)
		TipsCtrl.Instance:ShowCommonAutoView("citycombat_sos_auto_buy", describe, func, nil, nil, nil,nil,nil,true,false, nil)
	end
end

function FbIconView:OnClickLiuJieGuildCall()
	-- KuafuGuildBattleCtrl.Instance:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_SOS)
	if SceneType.KF_Borderland == Scene.Instance:GetSceneType() then
		if PlayerData.Instance.role_vo.guild_post ~= GuildDataConst.GUILD_POST.TUANGZHANG then
			TipsCtrl.Instance:ShowSystemMsg(Language.KFBorderland.NoZhaoJi)
			return
		end
		local max_time = KuaFuBorderlandData.Instance:GetZhaoJiMaxCost() + 1
		if max_time == KuaFuBorderlandData.Instance:GetKFBorderlandSosTimes() then
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.ZhaoJiTimesZero)
			return			
		end
		local cost = KuaFuBorderlandData.Instance:GetZhaoJiCost()
		local yes_func = function()
			GuildCtrl.Instance:SendSendGuildSosReq(GUILD_SOS_TYPE.GUILD_SOS_TYPE_CROSS_BIANJINGZHIDI) 
		end
		local describe = string.format(Language.Guild.TuanZhanZhaoji) or ""

		if cost > 0 then
			describe = string.format(Language.Guild.TuanZhanCost, cost) or ""
			TipsCtrl.Instance:ChangeAutoViewAuto(false)
			TipsCtrl.Instance:ShowCommonAutoView("kf_borderland_sos_auto_buy", describe, yes_func, nil, nil, nil,nil,nil,true,false, nil)
			return
		end
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)		
	else
		if not self.is_all_buy then
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.ZhaoJiTimesZero)
			return
		end
		local cost = KuafuGuildBattleData.Instance:GetZhaoJiCost()
		local yes_func = function()
			GuildCtrl.Instance:SendSendGuildSosReq(GUILD_SOS_TYPE.GUILD_SOS_TYPE_CROSS_GUILD_BATTLE) 
		end
		local describe = string.format(Language.Guild.TuanZhanZhaoji) or ""

		if cost > 0 then
			describe = string.format(Language.Guild.TuanZhanCost, cost) or ""
			TipsCtrl.Instance:ChangeAutoViewAuto(false)
			TipsCtrl.Instance:ShowCommonAutoView("cross_guild_sos_auto_buy", describe, yes_func, nil, nil, nil,nil,nil,true,false, nil)
			return
		end
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	end
end

function FbIconView:FlushGuildCallTimes()
	local left_times = CityCombatData.Instance:GetGuildCallLeftTimes()
	self.node_list["TxtGCTimes"].text.text = string.format(Language.CityCombat.LeftTimes, left_times)
end

function FbIconView:SetBuffBtnInYiZhanDaoDiScene()

	self.node_list["BtnBuff"]:SetActive(true)

	self.node_list["ImageBuff"]:SetActive(true)
	self.node_list["BuffDesTxt"].text.text = Language.FuBen.IconViewBuffYiZhanDaoDiDes
end

function FbIconView:OnRoleAttrValueChange(key, new_value, old_value)
	if key == "vip_level" then
		self.node_list["AutoBtnImage"]:SetActive(new_value < 3)

	end
end

function FbIconView:CloseCallBack()
	self.monster_diff_time_list = {}
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.reward_count_down then
		CountDown.Instance:RemoveCountDown(self.reward_count_down)
		self.reward_count_down = nil
	end
	for k, v in pairs(self.montser_count_down_list) do
		CountDown.Instance:RemoveCountDown(v)
	end
	self.montser_count_down_list = {}

	self.tip_id = nil
	if self.node_list["MonsterIcon1"] then
		self.node_list["MonsterIcon1"]:SetActive(false)
	end
	if self.node_list["MonsterIcon2"] then
		self.node_list["MonsterIcon2"]:SetActive(false)
	end

	self.is_show_skymoney_text = false
	self.is_complete = false

	self.auto_click_callback = nil
	--self.click_call_back_list = {}
	PlayerData.Instance:UnlistenerAttrChange(self.role_attr_change_event)
	self.is_countdown_leave = false
	if self.node_list["TimeTxt"] ~= nil then
		self.node_list["TimeTxt"]:SetActive(false)
		self.node_list["ImgTimeTxt"]:SetActive(false)
		self.node_list["ImgTimeTxt"]:SetActive(false)
	end
	self.shuijing_buff_flag = true
	self.xiuluo_buff_flag = true

	if self.boss_text_timer then
		GlobalTimerQuest:CancelQuest(self.boss_text_timer)
		self.boss_text_timer = nil
	end

	if next(self.guaji_tag_list) ~= nil then
		self.guaji_tag_list = {}
	end

	CityCombatCtrl.Instance:CloseRewardView()
	FuBenData.Instance:SetFuBenSceneLeftTime(nil)
	self:CanCelKFBorderlandBossFlushTimer()
	self:CancelStandyCountTimer()
end

function FbIconView:SetCountDown()
	local scene_type = Scene.Instance:GetSceneType()
	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo() or {}
	local quality_fb_info = {}
	if scene_type == SceneType.ChallengeFB then
		quality_fb_info = FuBenData.Instance:GetPassLayerInfo()
	end
	if not next(fb_scene_info) and not next(quality_fb_info) then 
		return
	end

	-- flush_timestamp
	local role_hp = GameVoManager.Instance:GetMainRoleVo().hp
	self.node_list["TimeTxt"]:SetActive(not (scene_type == SceneType.ExpFb or scene_type == SceneType.ChallengeFB))
	self.node_list["ImgTimeTxt"]:SetActive(not (scene_type == SceneType.ExpFb or scene_type == SceneType.ChallengeFB or scene_type == SceneType.GuildStation))
	self.node_list["ExitFB1TimeTxt_1"]:SetActive(scene_type == SceneType.ExpFb)

	if nil ~= self.temp_wave then
		if next(fb_scene_info) and self.temp_wave  < fb_scene_info.param1 then
			Scene.SendGetAllObjMoveInfoReq()
			if self.count_down ~= nil then
				CountDown.Instance:RemoveCountDown(self.count_down)
				self.count_down = nil
			end
		end
	end

	if next(fb_scene_info) and role_hp <= 0 and fb_scene_info.is_finish == 1 then
		if self.count_down then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		return
	end
	if next(fb_scene_info) and fb_scene_info.is_pass == 1 and fb_scene_info.is_finish == 1 then
		if not self.is_countdown_leave then
			if not self.is_complete or scene_type ~= SceneType.CrossFB then
				if scene_type == SceneType.PataFB or scene_type == SceneType.RuneTower or scene_type == SceneType.TeamSpecialFB or scene_type == SceneType.PhaseFb then
					-- 去掉爬塔副本打完一关后的倒计时
					self.fb_time = 0
				else
					self.fb_time = TimeCtrl.Instance:GetServerTime() + 15
				end
			end
			if self.count_down then
				CountDown.Instance:RemoveCountDown(self.count_down)
				self.count_down = nil
			end
			self.is_complete = true
			self.is_countdown_leave = true
		end
	else
		self.is_countdown_leave = false
		if next(quality_fb_info) then
			self.fb_time = quality_fb_info.time_out_stamp or 0
		else
			self.fb_time = fb_scene_info.time_out_stamp or 0
		end
		if self.count_down then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
	end

	if scene_type == SceneType.ExpFb then
		self.temp_wave = fb_scene_info.param1
	end

	if self.count_down == nil then
		local function diff_time_func (elapse_time, total_time)
			local left_time = math.floor(self.fb_time - TimeCtrl.Instance:GetServerTime() + 0.5)

			if left_time <= 0 then
				self.node_list["ExitFB1TimeTxt_1"].text.text = "00:00"
				self.node_list["ExitFB1TimeTxt_1"]:SetActive(false)
				self.node_list["TimeTxt"].text.text = "00:00"
				self.node_list["SpecialTimeTxt"].text.text = "00:00"
				if next(fb_scene_info) and scene_type ~= SceneType.CrossFB and 
					scene_type ~= SceneType.Kf_XiuLuoTower and scene_type ~= SceneType.TeamSpecialFB then
					FuBenCtrl.Instance:SendExitFBReq()
				elseif self.is_complete and scene_type ~= SceneType.TeamSpecialFB then
					FuBenCtrl.Instance:SendExitFBReq()
				elseif next(fb_scene_info) and fb_scene_info.is_pass == 0 and fb_scene_info.is_finish == 0 and scene_type ~= SceneType.TeamSpecialFB then
					GlobalTimerQuest:AddDelayTimer(function()
						ViewManager.Instance:Open(ViewName.FBFailFinishView)
					end, 2)
				elseif scene_type == SceneType.ChallengeFB then
					if next(quality_fb_info) and quality_fb_info.is_pass == 0 then
						GlobalTimerQuest:AddDelayTimer(function()
							ViewManager.Instance:Open(ViewName.FBFailFinishView)
						end, 2)
					end
				end
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
			FuBenData.Instance:SetFuBenSceneLeftTime(left_time)
			local left_hour = math.floor(left_time / 3600)
			local left_min = math.floor((left_time - left_hour * 3600) / 60)
			local left_sec = math.floor(left_time - left_hour * 3600 - left_min * 60)
			local h_text = ""
			local m_text = ""
			local s_text = ""
			local the_time_text = ""
			if left_hour > 0 then
				if left_hour> 9 then
					h_text = left_hour..":"
				else
					h_text = "0".. left_hour .. ":"
				end
				the_time_text = the_time_text .. h_text
			end
			if left_min > 9 then
				m_text = left_min .. "" .. ":"
			else
				m_text = "0".. left_min .. ":"
			end
			if left_sec > 9 then
				s_text = left_sec .. ""
			else
				s_text = "0"..left_sec
			end
			the_time_text = the_time_text .. m_text .. s_text
			self.node_list["ExitFB1TimeTxt_1"].text.text = the_time_text
			self.node_list["TimeTxt"].text.text = the_time_text
			self.node_list["SpecialTimeTxt"].text.text = "00:00"
		end

		local diff_time = self.fb_time - TimeCtrl.Instance:GetServerTime()
		if diff_time > 0 then
			diff_time_func(0, diff_time)
			self.count_down = CountDown.Instance:AddCountDown(
				diff_time, 0.5, diff_time_func)
		else
			self.node_list["TimeTxt"]:SetActive(false)
			self.node_list["SpecialTimeTxt"]:SetActive(false)
			self.node_list["ImgTimeTxt"]:SetActive(false)
			self.node_list["ExitFB1TimeTxt_1"].text.text = ""
			self.node_list["TimeTxt"].text.text = "00:00"
			self.node_list["SpecialTimeTxt"].text.text = "00:00"
		end
	end
end

function FbIconView:SwitchButtonState(enable)
	self.show_menu = not enable
	self:Flush()
end

function FbIconView:MainOpenComlete()
	GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)
	self:Flush()
end

function FbIconView:FlushTWInfo()
	local next_reward_time = CityCombatData.Instance:GetTWRewardTime()
	self:FlushRewardTime(next_reward_time)
end

function FbIconView:FlushGBInfo()
	local next_reward_time = CityCombatData.Instance:GetGBRewardTime()
	self:FlushRewardTime(next_reward_time)
end

function FbIconView:FlushYiZhanDaoDiInfo()
	local next_reward_time = YiZhanDaoDiData.Instance:GetLuckyRewardNextFlushTime()
	self:FlushRewardTime(next_reward_time)
end

function FbIconView:FlushYiZhanDaoDiGuWu()
	local user_info = YiZhanDaoDiData.Instance:GetYiZhanDaoDiUserInfo()
	local other_cfg = YiZhanDaoDiData.Instance:GetOtherCfg()
	if nil ~= user_info and nil ~= other_cfg then
		local flag = user_info.gongji_guwu_per >= other_cfg.gongji_guwu_max_per
		self.node_list["BuyBuff"].animator:SetBool("shake", not flag)
	end
end

function FbIconView:FlushQXLDInfo()
	local next_reward_time = CityCombatData.Instance:GetQXLDRewardTime()
	self:FlushRewardTime(next_reward_time)
end

function FbIconView:FlushGongChenInfo()
	local next_reward_time = CityCombatData.Instance:GetZhanChangRewardTime()
	self:FlushRewardTime(next_reward_time)
end

function FbIconView:FlushRewardTime(next_reward_time)
	if self.reward_count_down then
		CountDown.Instance:RemoveCountDown(self.reward_count_down)
		self.node_list["ExitFB2TimeTxt"].text.text = ""
		self.reward_count_down = nil
	end
	if 0 == next_reward_time then return end
	local servre_time = TimeCtrl.Instance:GetServerTime()
	self.reward_count_down = CountDown.Instance:AddCountDown(next_reward_time - servre_time, 1, BindTool.Bind(self.RewardCountDown, self))
end

function FbIconView:RewardCountDown(elapse_time, total_time)
	if total_time - elapse_time <= 0 then
		self.node_list["ExitFB2TimeTxt"].text.text = ""
		return
	end
	local time_str = TimeUtil.FormatSecond(total_time - elapse_time, 2)
	self.node_list["ExitFB2TimeTxt"].text.text = time_str
end

function FbIconView:FlushGuildRank()
	local global_info = GuildFightData.Instance:GetGlobalInfo()
	local des = ""
	if global_info.guild_rank <= 0 then
		des = Language.Guild.NotGuildFightRank
	else
		des = string.format(Language.Guild.GuildFightRank, global_info.guild_rank)
	end
	self.node_list["GuildNowRankDesTxt"].text.text = des
end

function FbIconView:OnClickReward()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.LuandouBattle then
		LuanDouBattleCtrl.Instance:OpenLuandouBattleAllReward()
	elseif scene_type == SceneType.KF_NightFight then
		KuaFuTuanZhanCtrl.Instance:OpenBattleAllReward()
	end
end

function FbIconView:FlushXiuLuoTaWuDiCaiJi()
	local cur_layer = KuaFuXiuLuoTowerData.Instance:GetCurrentLayer()
	if cur_layer == 10 then
		self.node_list["BtnShuijingBuff"]:SetActive(true)
		self.node_list["ZhiZun"]:SetActive(false)
		-- local gather_buff_time =  KuaFuXiuLuoTowerData.Instance:GetBossGatherEndTime() or 0
		-- local seconds = math.floor(gather_buff_time - TimeCtrl.Instance:GetServerTime())
		-- self.node_list["BtnIsOnShuijingBuff"]:SetActive(seconds <= 0)
		self:SetXiuLuoBuffBubblesText()
	end
end

function FbIconView:FlushTombExploreWuDiGather()
	self.node_list["BtnShuijingBuff"]:SetActive(true)
	self.node_list["ZhiZun"]:SetActive(false)
	-- local gather_buff_time =  TombExploreData.Instance:GetTombFbBuffTime() or 0
	-- local seconds = math.floor(gather_buff_time - TimeCtrl.Instance:GetServerTime())
	-- self.node_list["BtnIsOnShuijingBuff"]:SetActive(seconds <= 0)
	self:SetTombExploreBuffTime()
end

-- 跨服边境
function FbIconView:FlushKFBorderlandWuDiGather()
	self.node_list["BtnShuijingBuff"]:SetActive(true)
	self.node_list["ZhiZun"]:SetActive(false)
	self:SetKFBorderlandBuffTime()
end

function FbIconView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "zhanchan_info" then
			self:FlushGongChenInfo()
		elseif k == "tw_info" then
			self:FlushTWInfo()
		elseif k == "gb_info" then
			self:FlushGBInfo()
		elseif k == "qxld_info" then
			self:FlushQXLDInfo()
		elseif k == "xzyj_info" then
			self:SetConditionData()
		elseif k == "luandou_info" then
			self:FlushLuanDouHP()
		elseif k == "question" then
			self:CheckQuestionPrepare()
		elseif k == "guild_boss" then
			self:FlushGuildBossIcon()
		elseif k == "yizhandaodi_info" then
			self:FlushYiZhanDaoDiInfo()
		elseif k == "yizhandaodiguwu_animator" then
			self:FlushYiZhanDaoDiGuWu()
		elseif k == "xiuluota_wudi" then
			self:FlushXiuLuoTaWuDiCaiJi()
		elseif k == "tomb_explore_wudi" then
			self:FlushTombExploreWuDiGather()
		elseif k == "kf_borderland_wudi" then
			self:FlushKFBorderlandWuDiGather()
		elseif k == "guild_rank" then
			self:FlushGuildRank()
			--不return掉的话界面会一直刷很奇怪
			if not self.isnot_return then
				return
			end
		elseif k == "guild_call" then
			self:FlushGuildCallTimes()
			if not self.isnot_return then
				return
			end
		elseif k == "boss_list" then
			self:FlushBossList()
		elseif k == "reset_count_down" then
			self:CancelStandyCountTimer()
			self.isnot_return = true
			if self.count_down then
				CountDown.Instance:RemoveCountDown(self.count_down)
				self.count_down = nil
			end

			if Scene.Instance:GetSceneType() == SceneType.LuandouBattle or Scene.Instance:GetSceneType() == SceneType.KF_NightFight then
				local obj_list = Scene.Instance:GetObjList()
				for k, v in pairs(obj_list) do
					if v:GetType() == SceneObjType.Role or v:GetType() == SceneObjType.MainRole then
						v:ReloadSpecialImage()
					end
				end
			end
		end
	end
	self.isnot_return = nil

	self.node_list["PanelNode"]:SetActive(not self.show_menu)
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local name_list_t = Split(fb_scene_cfg.show_fbicon, "#")
	local btn_outfb_vis = false
	local dec_btn_vis = false
	for k,v in pairs(name_list_t) do
		if v == "btn_outfb" then
			btn_outfb_vis = true
		elseif v == "btn_fbdesc" then
			dec_btn_vis = true
		end
	end

	--世界boss
	local scene_id = Scene.Instance:GetSceneId()
	if BossData.Instance:IsWorldBossScene(scene_id) then
		btn_outfb_vis = true
		dec_btn_vis = true
		self.tip_id = 140
	elseif BossData.Instance:IsDabaoBossScene(scene_id) then
		btn_outfb_vis = true
		dec_btn_vis = true
		self.tip_id = 267
	elseif BossData.Instance:IsFamilyBossScene(scene_id) then
		btn_outfb_vis = true
		dec_btn_vis = true
		self.tip_id = 141
	-- elseif BossData.Instance:IsMikuPeaceBossScene(scene_id) then
	-- 	btn_outfb_vis = true
	-- 	dec_btn_vis = true
	-- 	self.tip_id = 321
	elseif BossData.Instance:IsMikuBossScene(scene_id) then
		btn_outfb_vis = true
		dec_btn_vis = true
		self.tip_id = 142
	elseif BossData.Instance:IsCrossBossScene(scene_id) then
		btn_outfb_vis = true
		dec_btn_vis = true
		self.tip_id = 144
	elseif BossData.Instance:IsActiveBossScene(scene_id) then
		btn_outfb_vis = true
		dec_btn_vis = true
		self.tip_id = 160
	elseif BossData.Instance:IsSecretBossScene(scene_id) then
		btn_outfb_vis = true
		dec_btn_vis = true
		self.tip_id = 214
	elseif AncientRelicsData.IsAncientRelics(scene_id) then
		btn_outfb_vis = true
		dec_btn_vis = true
		self.tip_id = 165
	elseif RelicData.Instance:IsRelicScene(scene_id) then
		btn_outfb_vis = true
		dec_btn_vis = true
		self.tip_id = 174
	elseif Scene.Instance:GetSceneType() == SceneType.CrossGuild and not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.KF_GUILDBATTLE) then
		self.tip_id = 294
		btn_outfb_vis = true
		dec_btn_vis = true
	end
	self.node_list["ExitFbBtn"]:SetActive(btn_outfb_vis)
	self.node_list["Explain"]:SetActive(dec_btn_vis)
	local scene_type = Scene.Instance:GetSceneType()
	local scene_id = Scene.Instance:GetSceneId()
	self.node_list["ExitFB"]:SetActive(scene_type == SceneType.GongChengZhan or
		scene_type == SceneType.ClashTerritory or
		scene_type == SceneType.LingyuFb or
		scene_type == SceneType.QunXianLuanDou
		or scene_type == SceneType.ChaosWar)

	if btn_outfb_vis then
		if scene_type == SceneType.GongChengZhan then
			self:DoActivityCountDown(ACTIVITY_TYPE.GONGCHENGZHAN)
			self:FlushGongChenInfo()
		elseif scene_type == SceneType.HunYanFb then
			GlobalTimerQuest:AddDelayTimer(function()
				local total_time = MarriageData.Instance:GetWeedingTime()
				self:SetCountDownByTotalTime(total_time)
			end, 1)
		elseif scene_type == SceneType.TombExplore then
			self:DoActivityCountDown(ACTIVITY_TYPE.TOMB_EXPLORE)
			self.node_list["MonsterIcon1"]:SetActive(not ActivityData.Instance:GetActivityIsReady(ACTIVITY_TYPE.TOMB_EXPLORE))
		elseif scene_type == SceneType.ShuiJing then
			local act_is_ready = ActivityData.Instance:GetActivityIsReady(ACTIVITY_TYPE.SHUIJING)
			self:DoActivityCountDown(ACTIVITY_TYPE.SHUIJING)
			self.node_list["ZhiZun"]:SetActive(not ActivityData.Instance:GetActivityIsReady(ACTIVITY_TYPE.SHUIJING))
		elseif scene_type == SceneType.Kf_XiuLuoTower then
			self.node_list["XiuLuoTaRank"]:SetActive(true)
			self:DoActivityCountDown(ACTIVITY_TYPE.KF_XIULUO_TOWER)
			local cur_layer = KuaFuXiuLuoTowerData.Instance:GetCurrentLayer() or 0
			local is_show_item_tips = cur_layer == 10
			self.node_list["ShowItemBtn"]:SetActive(is_show_item_tips)
			if is_show_item_tips then
				self:FlushImgShuiJingBuff()
			end
		elseif scene_type == SceneType.ClashTerritory then
			self:DoActivityCountDown(ACTIVITY_TYPE.CLASH_TERRITORY)
			self:FlushTWInfo()
		elseif scene_type == SceneType.QunXianLuanDou then
			self:DoActivityCountDown(ACTIVITY_TYPE.QUNXIANLUANDOU)
			self:FlushQXLDInfo()
		elseif scene_type == SceneType.GUILD_ANSWER_FB then
			self:DoActivityCountDown(ACTIVITY_TYPE.GUILD_ANSWER)
		elseif scene_type == SceneType.TianJiangCaiBao then
			self:DoActivityCountDown(ACTIVITY_TYPE.TIANJIANGCAIBAO)
		elseif scene_type == SceneType.GuildMiJingFB then
			self:DoActivityCountDown(ACTIVITY_TYPE.GUILD_SHILIAN)
		elseif scene_type == SceneType.HotSpring then
			self:DoActivityCountDown(ACTIVITY_TYPE.KF_HOT_SPRING)
			self:CheckQuestionPrepare()
		elseif scene_type == SceneType.LingyuFb then
			self:DoActivityCountDown(ACTIVITY_TYPE.GUILDBATTLE)
			self:FlushGBInfo()
		elseif scene_type == SceneType.ChaosWar then		-- 一战到底
			self:DoActivityCountDown(ACTIVITY_TYPE.CHAOSWAR)
			self:FlushYiZhanDaoDiInfo()
		elseif scene_type == SceneType.FarmHunting then		-- 跨服牧場
			self:DoActivityCountDown(ACTIVITY_TYPE.KF_FARMHUNTING)
		elseif scene_type == SceneType.DaFuHao then
			self:DoActivityCountDown(ACTIVITY_TYPE.BIG_RICH)
		elseif scene_type == SceneType.GuildStation then
			-- 屏蔽仙盟灵兽
			-- self:DoActivityCountDown(ACTIVITY_TYPE.GUILD_BOSS)
			--
			-- if not GuildData.Instance:GetMoneyTreeState() then
			-- 	self.node_list["Explain"]:SetActive(false)
			-- end
		elseif scene_type == SceneType.MonthBlackWindHigh then
			self:DoActivityCountDown(ACTIVITY_TYPE.KF_MONTH_BLACK_WIND_HIGHT)
			self:CheckThisRewardTime()
		elseif scene_type == SceneType.KF_Fish then
			self:DoActivityCountDown(ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_FISHING)
		elseif scene_type == SceneType.LuandouBattle then
			self.node_list["MonsterIconTimeTxt1"]:SetActive(false)
			if LuanDouBattleData.Instance:GetIsCrossServerState() == 1 then
				self.node_list["MonsterIcon1"]:SetActive(not ActivityData.Instance:GetActivityIsReady(ACTIVITY_TYPE.KF_LUANDOUBATTLE))
				self:DoActivityCountDown(ACTIVITY_TYPE.KF_LUANDOUBATTLE)
			else
				self.node_list["MonsterIcon1"]:SetActive(not ActivityData.Instance:GetActivityIsReady(ACTIVITY_TYPE.LUANDOUBATTLE))
				self:DoActivityCountDown(ACTIVITY_TYPE.LUANDOUBATTLE)
			end
			self:CheckThisRewardTime()
		elseif scene_type == SceneType.KF_NightFight then
			self.node_list["MonsterIcon1"]:SetActive(not ActivityData.Instance:GetActivityIsReady(ACTIVITY_TYPE.KF_TUANZHAN))
			if KuaFuTuanZhanData.Instance:GetIsCrossServerState() == 1 then
				self:DoActivityCountDown(ACTIVITY_TYPE.KF_TUANZHAN)
			else
				self:DoActivityCountDown(ACTIVITY_TYPE.NIGHT_FIGHT_FB)
			end
			self:CheckThisRewardTime()		
		elseif scene_type == SceneType.CrossLieKun_FB then
			self:DoActivityCountDown(ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_LIEKUN_FB)
		elseif scene_type == SceneType.CrossGuild then
			self:FlushLiuJieZhaoJiRestTime()
			if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.KF_GUILDBATTLE) or ActivityData.Instance:GetActivityIsReady(ACTIVITY_TYPE.KF_GUILDBATTLE) then
				self:DoActivityCountDown(ACTIVITY_TYPE.KF_GUILDBATTLE)
			else
				self:SetCountDown()
			end
		elseif scene_type == SceneType.KF_Borderland then
			if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_BIANJING_ZHIDI) then
				self:FlushKFBorderlandZhaoJiRestTime()
			end
			self:DoActivityCountDown(ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_BIANJING_ZHIDI)
		elseif scene_type == SceneType.CrystalEscort then
			self:DoActivityCountDown(ACTIVITY_TYPE.JINGHUA_HUSONG)
		else
			self:SetCountDown()
		end
	end
	if dec_btn_vis and fb_scene_cfg.desc_open == 1 then
		if not SettingData.Instance:HasEnterFb(scene_type, scene_id) then
			SettingData.Instance:SetFbEnterFlag(scene_type, true, scene_id)
			self:OnClicExplain()
		end
	end

	self:FlushGuildBossIcon()

	for k, v in pairs(self.monster_diff_time_list) do
		if v > 0 then
			self:SetMonsterCountDown(k)
		end
	end

	self.node_list["MonsterIconTxt"]:SetActive(self.is_show_skymoney_text)

	if scene_type == SceneType.ExpFb then
		self:PotionEffectState()
	end
	self:SetMonsterCacheInfo()
	if self.node_list["BtnShuijingBuff"].gameObject.activeSelf then
		self:FlushShuiJingExist()
	end
	local flag = scene_type == SceneType.TeamTowerFB or scene_type == SceneType.TeamSpecialFB or scene_type == SceneType.ArmorDefensefb or scene_type == SceneType.ChallengeFB or scene_type == SceneType.TowerDefend
	self.node_list["BtnDrop"]:SetActive(flag)
end

function FbIconView:FlushLuanDouHP()
	local info = LuanDouBattleData.Instance:GetRoleInfo()
	if info then
		self.node_list["HP"]:SetActive(true)
		local txt = info.boss_hp_per <= 0 and "" or (math.floor(info.boss_cur_hp / info.boss_max_hp * 10000) / 100) .. "%"
		self.node_list["HPText"].text.text = txt
	end
end


function FbIconView:FlushGuildZhaoJiRestTime()
	local time = GuildFightData.Instance:GetRemindZhaojiTimes() or 0
	self.node_list["TxtZhaoJi"].text.text = Language.Guild.ZhaojiRestTime .. time
end

function FbIconView:FlushLiuJieZhaoJiRestTime()
	local notify_info = KuafuGuildBattleData.Instance:GetNotifyInfo()
	if notify_info and (notify_info.notify_type == SC_CROSS_GUILDBATTLE_INFO_TYPE.SC_CROSS_GUILDBATTLE_NOTIFY_TYPE_SOS 
		or notify_info.notify_type == SC_CROSS_GUILDBATTLE_INFO_TYPE.SC_CROSS_GUILDBATTLE_NOTIFY_TYPE_ENTER) then
		local max_num = KuafuGuildBattleData.Instance:GetZhaojiMaxTimes()
		local last_num = max_num - notify_info.param_2
		if last_num > 0 then
			self.node_list["TxtLiuJieZhaoji"]:SetActive(true)
			self.node_list["TxtLiuJieZhaoji"].text.text = Language.Guild.ZhaojiRestTime .. last_num
		else
			self.node_list["TxtLiuJieZhaoji"]:SetActive(false)
			self.is_all_buy = false
		end
	end
end

function FbIconView:FlushKFBorderlandZhaoJiRestTime()
	local sos_times = KuaFuBorderlandData.Instance:GetKFBorderlandSosTimes()
	if SceneType.KF_Borderland == Scene.Instance:GetSceneType() then
		local max_time = KuaFuBorderlandData.Instance:GetZhaoJiMaxCost() + 1
		local last_num = max_time - sos_times
		self.node_list["TxtLiuJieZhaoji"]:SetActive(true)
		self.node_list["TxtLiuJieZhaoji"].text.text = Language.Guild.ZhaojiRestTime .. last_num
	end

	if KuaFuBorderlandData.Instance:GetIsFlushBossFirst() then
		local reflush_boss_time = KuaFuBorderlandData.Instance:GetBossReflushTime()
		local tmp_time = reflush_boss_time - TimeCtrl.Instance:GetServerTime()

		if nil == self.kf_borderland_flush_boss_timer then
			self.node_list["TxtTimeShow"]:SetActive(false)
			self.node_list["KFBorderlandReward"]:SetActive(true)
			self.isnot_show_timer = true
			self.kf_borderland_flush_boss_timer = CountDown.Instance:AddCountDown(
				tmp_time, 1, function (elapse_time, total_time)
					if elapse_time >= total_time then
						self:CanCelKFBorderlandBossFlushTimer()
						self.node_list["KFBorderlandReward"]:SetActive(false)
						self.node_list["TxtTimeShow"]:SetActive(true)
						self.isnot_show_timer = nil
					else
						self.node_list["KFBorderlandRewardTimeTxt"].text.text = TimeUtil.FormatSecond(math.floor(total_time - elapse_time), 2)
					end
				end)
		end
	end
end

function FbIconView:CanCelKFBorderlandBossFlushTimer()
	if self.kf_borderland_flush_boss_timer then
		CountDown.Instance:RemoveCountDown(self.kf_borderland_flush_boss_timer)
		self.kf_borderland_flush_boss_timer = nil
	end
end

function FbIconView:CheckThisRewardTime()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.LuandouBattle then
		local info = LuanDouBattleData.Instance:GetRoleInfo()
		if info and info.next_redistribute_time then
			local time = info.next_redistribute_time - TimeCtrl.Instance:GetServerTime()
			self:RemoveUniversalCountDown()
			if time > 0 then
				self.node_list["ThisRewardNode"]:SetActive(true)
				self:SetUniversalTime(time, self.node_list["ThisRewardTimeTxt"])
			else
				self.node_list["ThisRewardNode"]:SetActive(false)
			end
		end
	elseif scene_type == SceneType.KF_NightFight then
		local act_info = KuaFuTuanZhanData.Instance:GetRoleInfo()
		if act_info and act_info.next_redistribute_time then
			local time = act_info.next_redistribute_time - TimeCtrl.Instance:GetServerTime()
			if time > 0 then
				self.node_list["ThisRewardNode"]:SetActive(true)
				self:SetUniversalTime(time, self.node_list["ThisRewardTimeTxt"])
			else
				self.node_list["ThisRewardNode"]:SetActive(false)
			end
		end
	elseif scene_type == SceneType.MonthBlackWindHigh then
		local next_check_reward_timestamp = KFMonthBlackWindHighData.Instance:GetNextCheckRewardTimestamp()
		local next_time = next_check_reward_timestamp - TimeCtrl.Instance:GetServerTime()

		self:RemoveUniversalCountDown()
		if next_time > 0 then
			self.node_list["ThisRewardNode"]:SetActive(true)
			self:SetUniversalTime(next_time, self.node_list["ThisRewardTimeTxt"])
		else
			self.node_list["ThisRewardNode"]:SetActive(false)
		end
		-- local boss_info = KFMonthBlackWindHighData.Instance:GetBossInfo()
		local boss_info = KFMonthBlackWindHighData.Instance:GetTargetBossInfo()
		local boss_list_cfg = KFMonthBlackWindHighData.Instance:GetCrossDarkNightBossCfg()
		if not boss_info or not boss_list_cfg then return end
		local index, boss_cfg = KFMonthBlackWindHighData.Instance:GetBossCfgById(boss_info.monster_id)
		if next_check_reward_timestamp > 0 and index >= GameEnum.CROSS_DARK_NIGHT_MONSTER_MAX_COUNT then
			self.node_list["TxtTimeShow"]:SetActive(false)
			self.node_list["ThisRewardNode"]:SetActive(true)
			local info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.KF_MONTH_BLACK_WIND_HIGHT)
			local end_time = info.next_time or 0
			local total_time = end_time - TimeCtrl.Instance:GetServerTime()
			self:SetUniversalTime(total_time, self.node_list["ThisRewardTimeTxt"])
		else
			self.node_list["TxtTimeShow"]:SetActive(false)
		end
	end
end

function FbIconView:RemoveUniversalCountDown()
	if self.universal_count_down then
		CountDown.Instance:RemoveCountDown(self.universal_count_down)
		self.universal_count_down = nil
	end
end

function FbIconView:SetUniversalTime(total_time, time_text, callback)
	if self.universal_count_down == nil then
		local function diff_time_func(elapse_time, total_time2)
			if elapse_time >= total_time2 then
				local time = "00:00"
				time_text.text.text = time
				self:RemoveUniversalCountDown()
				if callback then
					callback()
				end
				return
			end
			local left_time = math.floor(total_time2 - elapse_time + 0.5)
			local the_time_text = TimeUtil.FormatSecond(left_time, 7)
			time_text.text.text = the_time_text
		end
		diff_time_func(0, total_time)
		self.universal_count_down = CountDown.Instance:AddCountDown(
			total_time, 1, diff_time_func)
	end
end


function FbIconView:ActivityCallBack()
	self:FlushGuildBossIcon()
end

function FbIconView:FlushShuiJingExist()
	local crystal_scene_info = CrossCrystalData.Instance:GetCrystalSceneInfo()
	if nil == crystal_scene_info then
		return
	end

	local complete_func = function()
		UI:SetGraphicGrey(self.node_list["ImgShuiJing"], false)
		self.node_list["EffectShuiJing"]:SetActive(true)
		self.node_list["ImgFlushShuiJing"]:SetActive(false)
		self.node_list["TxtShuijing"].text.text = Language.CrossCrastal.Exit
		if self.time_quest then
			CountDown.Instance:RemoveCountDown(self.time_quest)
			self.time_quest = nil
		end
	end

	local flush_time = crystal_scene_info.big_shuijing_next_flush_time or 0
	local total_time_s = flush_time - TimeCtrl.Instance:GetServerTime()
	if total_time_s <= 0 then
		complete_func()
	else
		local update_func = function(elapse_time, total_time)
			local time = math.floor(total_time - elapse_time + 0.5)
			self.node_list["TxtShuijing"].text.text = TimeUtil.FormatSecond(time, 2)
			self.node_list["EffectShuiJing"]:SetActive(false)
			self.node_list["ImgFlushShuiJing"]:SetActive(true)
			UI:SetGraphicGrey(self.node_list["ImgShuiJing"], true)
		end
		if self.time_quest == nil then
			update_func(0, total_time_s)
			self.time_quest = CountDown.Instance:AddCountDown(total_time_s, 1, update_func, complete_func)
		end
	end
end


function FbIconView:FlushGuildBossIcon()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.GuildStation then
		self.node_list["ImgGuildbg"]:SetActive(false) 					--策划要求屏蔽召唤按钮
		-- local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GUILD_BOSS)
		-- local boss_info = GuildData.Instance:GetBossInfo() or {}
		-- local boss_normal_call_count = boss_info.boss_normal_call_count or 0
		-- -- 如果今天还没有召唤过boss
		-- if is_open and boss_normal_call_count <= 0 then
		-- 	self.node_list["GuildBoss"].animator:SetBool("Flash", true)
		-- else
		-- 	self.node_list["GuildBoss"].animator:SetBool("Flash", false)
		-- end
	else
		self.node_list["ImgGuildbg"]:SetActive(false)
	end
end

function FbIconView:DoActivityCountDown(activity_type)
	local info = ActivityData.Instance:GetActivityStatuByType(activity_type)
	if info then
		local end_time = info.next_time or 0
		local total_time = end_time - TimeCtrl.Instance:GetServerTime()
		if info.status == ACTIVITY_STATUS.OPEN then
			if not self.guaji_tag_list[activity_type] then
				GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
				self.guaji_tag_list[activity_type] = true
			end
			self:SetCountDownByTotalTime(total_time, activity_type)
		elseif info.status == ACTIVITY_STATUS.STANDY then
			GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
			self:SetCountDownByStandyTotalTime(total_time)
		end
	end
end

function FbIconView:SetCountDownByTotalTime(total_time, activity_type)
	if self:IsLoaded() then
		if total_time <= 0 then
			self.node_list["TimeTxt"]:SetActive(false)
			self.node_list["SpecialTimeTxt"]:SetActive(false)
			self.node_list["ImgTimeTxt"]:SetActive(false)
			self.node_list["TxtTimeShow"]:SetActive(false)
			if self.count_down then
				CountDown.Instance:RemoveCountDown(self.count_down)
				self.count_down = nil
			end
			return
		end
		--self.node_list["TimeTxt"]:SetActive(true)
		self.node_list["StandyTimeCountNode"]:SetActive(false)
		-- if ACTIVITY_TYPE.SHUIJING == activity_type then
		-- 	self.node_list["TxtTimeShow"]:SetActive(false)
		-- 	return
		-- end

		self.node_list["TxtTimeShow"]:SetActive(true and not self.isnot_show_timer)
		if self.count_down == nil then
			local function diff_time_func(elapse_time, total_time2)
				if elapse_time >= total_time2 then
					local time = "00:00"
					if self.node_list then
						self.node_list["ExitFB1TimeTxt_1"].text.text = time
						--self.node_list["TimeTxt"].text.text = time
						self.node_list["TimeTxt"].text.text = 00
						self.node_list["Timebefore"].text.text = 00
					end
					if self.count_down then
						CountDown.Instance:RemoveCountDown(self.count_down)
						self.count_down = nil
					end
					return
				end
				local left_time = math.floor(total_time2 - elapse_time + 0.5)
				local h, m, s = WelfareData.Instance:TimeFormat(left_time)
				local h_text = ""
				local m_text = ""
				local s_text = ""
				local the_time_text = ""
				if h > 0 then
					if h>9 then
						h_text = h..":"
					else
						h_text = "0".. h .. ":"
					end
				end
				local tempm
				
				
				if m > 9 then
					tempm = m
					m_text = m .. "" .. ":"
				else
					tempm = "0" .. m
					m_text = "0".. m .. ":"
				end
				if s > 9 then
					s_text = s .. ""
				else
					s_text = "0"..s
				end
				if self.node_list then
					self.node_list["Timebefore"].text.text = s_text
					the_time_text = h_text .. m_text .. s_text
					self.node_list["ExitFB1TimeTxt_1"].text.text = the_time_text
					self.node_list["TimeTxt"].text.text = the_time_text
					self.node_list["SpecialTimeTxt"].text.text = the_time_text
					self.node_list["ImgTimeTxt"]:SetActive(true)
				end
			end
			diff_time_func(0, total_time)
			self.count_down = CountDown.Instance:AddCountDown(
				total_time, 0.5, diff_time_func)
		end
	end
end

function FbIconView:SetCountDownByStandyTotalTime(total_time)
	if self:IsLoaded() then
		self.node_list["TxtTimeShow"]:SetActive(TxtTimeShow)
		if self.standy_count_down == nil then
			local function diff_time_func(elapse_time, total_time2)
				if elapse_time >= total_time2 then
					local time = "00:00"
					if self.node_list then
						self.node_list["StandyTimeCountTimeTxt"].text.text = time
					end
					if self.standy_count_down then
						CountDown.Instance:RemoveCountDown(self.standy_count_down)
						self.standy_count_down = nil
					end
					return
				end
				local left_time = math.floor(total_time2 - elapse_time + 0.5)
				local h, m, s = WelfareData.Instance:TimeFormat(left_time)
				local h_text = ""
				local m_text = ""
				local s_text = ""
				local the_time_text = ""
				if h > 0 then
					if h>9 then
						h_text = h..":"
					else
						h_text = "0".. h .. ":"
					end
				end
				local tempm
				
				
				if m > 9 then
					tempm = m
					m_text = m .. "" .. ":"
				else
					tempm = "0" .. m
					m_text = "0".. m .. ":"
				end
				if s > 9 then
					s_text = s .. ""
				else
					s_text = "0"..s
				end
				if self.node_list then
					the_time_text = h_text .. m_text .. s_text
					self.node_list["StandyTimeCountTimeTxt"].text.text = the_time_text
					self.node_list["StandyTimeCountNode"]:SetActive(true)
				end
			end
			diff_time_func(0, total_time)
			self.standy_count_down = CountDown.Instance:AddCountDown(
				total_time, 0.5, diff_time_func)
		end
	end
end

function FbIconView:CancelStandyCountTimer()
	if self.standy_count_down then
		CountDown.Instance:RemoveCountDown(self.standy_count_down)
		self.standy_count_down = nil
	end
end

function FbIconView:OnClickGuildBoss()
	ViewManager.Instance:Open(ViewName.GuildBoss)
end

function FbIconView:OpenMoneyTree()
	local info = PlayerData.Instance:GetRoleVo()
	local yes_func = function()
		GuildCtrl.Instance:OpenGuildMoneyTree(GUILD_TIANCITONGBI_REQ_TYPE.GUILD_TIANCITONGBI_REQ_TYPE_OPEN, info.guild_id, info.role_id)
	end

	TipsCtrl.Instance:ShowCommonAutoView("", Language.Guild.OpenMoneyTree, yes_func)
end

function FbIconView:ShowGuildBossButton()
	if nil == self.node_list["GuildBoss"] or nil == self.node_list["GuildMoneyTree"] then
		return
	end

	local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.GUILD_BOSS)
	local scene_type = Scene.Instance:GetSceneType()

	self.node_list["GuildBoss"]:SetActive(false)
	self.node_list["GuildMoneyTree"]:SetActive(true)
	-- if act_info and scene_type == SceneType.GuildStation then
	-- 	if act_info.status == ACTIVITY_STATUS.OPEN or act_info.status == ACTIVITY_STATUS.STANDY then
	-- 		--  屏蔽仙盟boss设为false
	-- 		self.node_list["GuildBoss"]:SetActive(false)
	-- 		--
	-- 		self.node_list["GuildMoneyTree"]:SetActive(false)
	-- 	end
	-- end
end

function FbIconView:SetMonsterInfo(monster_id, index)
	local index = index or 1
	if self:IsLoaded() then
		local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[monster_id]
		if not monster_cfg then return end
		local bundle, asset = ResPath.GetBossIcon(monster_cfg.headid)
		self.node_list["ImgMaskIcon" .. index].image:LoadSprite(bundle, asset)
	else
		self.monster_id = monster_id
	end
end

function FbIconView:SetMo_LongIcon()
	local index = 1
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[8402]
	local bundle, asset = ResPath.GetBossIcon(monster_cfg.headid)
	self.node_list["ImgMaskIcon" .. index].image:LoadSprite(bundle, asset)
end


function FbIconView:SetBossTips(enable)
	self.node_list["BossTipsNode"]:SetActive(enable)
	self.node_list["BossTips"].text.text = Language.LuanDouBattle.BossTips
end

function FbIconView:SetBossInfo(enable)
	self.node_list["ImgFlushing2"]:SetActive(enable)
	self.node_list["BossEffect"]:SetActive(not enable)
	UI:SetGraphicGrey(self.node_list["ImgMaskIcon1"], enable)
end

-- BOSS提示倒计时
local BossTextTimer = 5
-- 设置 已刷新 文本 Active
function FbIconView:ShowMonsterHadFlush(enable, flush_text, index)
	local index = index or 1
	local boss_list_cfg = {}
	local boss_info = {}
	local seq, boss_cfg = 0, {}
	if self:IsLoaded() then
		-- 怪物刷新后文本的显示，默认显示“已刷新”
		local flush_text = flush_text or Language.Boss.HadFlush
		self.show_monster_had_flush[index] = enable
		--self.node_list["ImgMaskIcon" .. index]:SetActive( enable)
		--local GradActive = (not self.show_monster_gray[index] or true) and self.show_monster_had_flush[index]
		local boss_active = not self.show_monster_gray[index]  and self.show_monster_had_flush[index]
		UI:SetGraphicGrey(self.node_list["ImgMaskIcon" .. index], not boss_active)
		if index == 1 then
			self.node_list["BossEffect"]:SetActive(boss_active)
		else
			self.node_list["BossEffect"]:SetActive(false)
		end
		--文字提示
		local scene_type = Scene.Instance:GetSceneType()
		if scene_type == SceneType.MonthBlackWindHigh then
			boss_list_cfg = KFMonthBlackWindHighData.Instance:GetCrossDarkNightBossCfg()
			-- boss_info = KFMonthBlackWindHighData.Instance:GetBossInfo()
			boss_info = KFMonthBlackWindHighData.Instance:GetTargetBossInfo()
			seq, boss_cfg = KFMonthBlackWindHighData.Instance:GetBossCfgById(boss_info.monster_id)
			if self.is_boss_active ~= boss_active then
				self.is_boss_active = boss_active
				self.node_list["BossImageTxt"]:SetActive(boss_active)
				if boss_active then
					local delay_callback = function()
						self.node_list["BossImageTxt"]:SetActive(false)
						if self.boss_text_timer then
							GlobalTimerQuest:CancelQuest(self.boss_text_timer)
							self.boss_text_timer = nil
						end
					end
					if self.boss_text_timer then
						GlobalTimerQuest:CancelQuest(self.boss_text_timer)
						self.boss_text_timer = nil
					end
					self.boss_text_timer = GlobalTimerQuest:AddDelayTimer(delay_callback, BossTextTimer)
				end
			end

			if not self.is_boss_active then
				self.node_list["BossImageTxt"]:SetActive(false)
			end
		else
			self.node_list["BossImageTxt"]:SetActive(false)
		end
		

		self.node_list["MonsterIconTimeTxt" .. index]:SetActive(not enable)
		self.node_list["HadFlushTxt" .. index]:SetActive(enable)

		if SceneType.FarmHunting == scene_type then
			local info = FarmHuntingData.Instance:GetFarmHountingInfo()
			if info then
				self:SetMonsterDiffTime(info.special_monster_refresh_time, index)
			end
		end

		if scene_type == SceneType.Kf_XiuLuoTower then
			local boss_num = KuaFuXiuLuoTowerData.Instance:GetBossNum()
			local cur_layer = KuaFuXiuLuoTowerData.Instance:GetCurrentLayer()
			if cur_layer ~= 10 then
				self.node_list["HadFlushTxt1"]:SetActive(not enable and boss_num > 0)
				self.node_list["ImgTextBg"]:SetActive(not enable)
				self.node_list["BossImageTxt"]:SetActive(false)
			else
				self.node_list["HadFlushTxt1"]:SetActive(enable)
				self.node_list["ImgTextBg"]:SetActive(true)
				self.node_list["BossImageTxt"]:SetActive(enable)
			end
			self.node_list["XiuLuoTaLayer"]:SetActive(enable and cur_layer ~= 10)
		end

		if scene_type == SceneType.MonthBlackWindHigh then
			if not enable then
				self.node_list["ImgBossNum"]:SetActive(true)
				self.node_list["ImgFlushing"]:SetActive(false)
				self.node_list["TxtNum"].text.text = seq .. " / " .. GameEnum.CROSS_DARK_NIGHT_MONSTER_MAX_COUNT

				local next_reward_times = KFMonthBlackWindHighData.Instance:GetNextCheckRewardTimestamp()
				if nil == self.time_quest_month then
					local function diff_time_func(elapse_time, total_time2)
						local left_time = math.floor(total_time2 - elapse_time + 0.5)
						local the_time_text = TimeUtil.FormatSecond(left_time, 7)
						if the_time_text then
							self.node_list["MonsterIconTimeTxt" .. index].text.text = the_time_text
						end
					end
					self.time_quest_month = CountDown.Instance:AddCountDown(next_reward_times - TimeCtrl.Instance:GetServerTime(), 
						1, diff_time_func)
				end
			else
				if self.time_quest_month then
					CountDown.Instance:RemoveCountDown(self.time_quest_month)
					self.time_quest_month = nil
				end
				self.node_list["ImgBossNum"]:SetActive(false)
				self.node_list["ImgFlushing"]:SetActive(true)
			end
		end
		if enable then
			self.node_list["MonsterIcon" .. index]:SetActive(true)
			self.node_list["HadFlushTxt" .. index].text.text = flush_text

				--跨服珍宝秘境BOSS按钮打开
				local scene_type = Scene.Instance:GetSceneType()
				if scene_type == SceneType.MonthBlackWindHigh then
					-- if boss_info.monster_id == 0 then
					-- 	self.node_list["MonsterIcon1"]:SetActive(false)
					-- end
					self.node_list["MonsterIcon1"]:SetActive(false)
				else
					self.node_list["MonsterIcon1"]:SetActive(true)
				end

			if self.montser_count_down_list[index] ~= nil then
				CountDown.Instance:RemoveCountDown(self.montser_count_down_list[index])
				self.montser_count_down_list[index] = nil
			end
		end
	else
		FuBenData.Instance:SaveShowMonsterHadFlush(enable, flush_text, index)
	end
end



-- 设置右侧怪物倒计时
function FbIconView:SetMonsterDiffTime(diff_time, index)
	local index = index or 1
	self.monster_diff_time_list[index] = diff_time
	if self:IsLoaded() then
		self:SetMonsterCountDown(index)
	end
end

function FbIconView:SetMonsterIconState(enable, index)
	local index = index or 1
	if self:IsLoaded() then
		self.node_list["MonsterIcon" .. index]:SetActive(enable)
	else
		FuBenData.Instance:SaveMonsterIconState(enable, index)
	end
end

function FbIconView:SetMonsterIconGray(enable, index)
	local index = index or 1
	if self:IsLoaded() then
		--self.show_monster_had_flush[index] = not enable
		self.show_monster_gray[index] = enable
		--self.node_list["ImgMaskIcon" .. index]:SetActive(not enable)
	else
		FuBenData.Instance:SaveMonsterIconGray(enable, index)
	end
end

function FbIconView:SetBossHpPercentValue(enable, str)
	if self.node_list["BossHpValue"] then
		self.node_list["BossHpValue"]:SetActive(enable)
		self.node_list["BossHpValue"].text.text = str or ""
	end
end

function FbIconView:SetMonsterCountDown(index)
	local index = index or 1
	if not self.montser_count_down_list[index] and self.monster_diff_time_list[index] and tonumber(self.monster_diff_time_list[index]) > 0 then
		local diff_time = 0 --self.monster_diff_time_list[index]
		local scene_type = Scene.Instance:GetSceneType() 
		if scene_type == SceneType.KF_NightFight then
			local act_info = KuaFuTuanZhanData.Instance:GetRoleInfo()
			local server_time = TimeCtrl.Instance:GetServerTime()
			diff_time = act_info.next_redistribute_time  - server_time
		else
			diff_time = self.monster_diff_time_list[index]
		end
		self.node_list["MonsterIcon" .. index]:SetActive(true)

		if nil == self.montser_count_down_list[index] then
			local function diff_time_func (elapse_time, total_time)
				local left_time = math.floor(diff_time - elapse_time + 0.5)
				if left_time <= 0.5 then
					if self.montser_count_down_list[index] ~= nil then
						CountDown.Instance:RemoveCountDown(self.montser_count_down_list[index])
						self.montser_count_down_list[index] = nil
						self.monster_diff_time_list = {}
					end
					return
				end
				local left_hour = math.floor(left_time / 3600)
				local left_min = math.floor((left_time - left_hour * 3600) / 60)
				local left_sec = math.floor(left_time - left_hour * 3600 - left_min * 60)

				self.node_list["MonsterIconTimeTxt"..index].text.text = string.format(Language.Common.XXHXXM, left_min, left_sec)
			end

			diff_time_func(0, diff_time)
			self.montser_count_down_list[index] = CountDown.Instance:AddCountDown(
				diff_time, 0.5, diff_time_func)
		end
	end
end

function FbIconView:SetClickCallBack(call_back, index)
	local index = index or 1
	self.click_call_back_list[index] = call_back
end

function FbIconView:ClearClickCallBack()
	self.click_call_back_list = {}
end

function FbIconView:OnClickBossIcon(index)	
	local scene_type = Scene.Instance:GetSceneType()
	local cur_layer = KuaFuXiuLuoTowerData.Instance:GetCurrentLayer() or 0
	if scene_type == SceneType.Kf_XiuLuoTower and cur_layer < 10 then
		TipsCtrl.Instance:OpenFuBenShowTip()
	else
		self.node_list["BossImageTxt"]:SetActive(false)
		if self.click_call_back_list[index] then
			self.click_call_back_list[index]()
		end
		self:SetBossTips(false)
	end
end


function FbIconView:OnClickBossShowItemTips()
	TipsCtrl.Instance:OpenFuBenShowTip()
end


function FbIconView:SetSkyMoneyTextState(value)
	self.is_show_skymoney_text = value

	if self.node_list["MonsterIconTxt"] then
		self.node_list["MonsterIconTxt"]:SetActive(self.is_show_skymoney_text)
	end
end

function FbIconView:GetUiCallBack(ui_name, ui_param)
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
	return nil
end

function FbIconView:SetAutoBtnClickCallBack(call_back)
	self.auto_click_callback = call_back
end

function FbIconView:OnClickAutoBtn()
	if self.auto_click_callback then
		self.auto_click_callback(self.node_list["AutoBtn"].toggle)
	end
end

function FbIconView:OnClickGuildFightRank()
	GuildFightCtrl.Instance:OpenRank()
end

function FbIconView:SetExitArrowState()
	--if nil ~= self.show_exit_arrow then
	if nil ~= self.node_list["ImgExitFB_1"] then
		self.node_list["ImgExitFB_1"]:SetActive(DaFuHaoData.Instance:IsDaFuHaoScene() and DaFuHaoData.Instance:IsGatherTimesLimit())
	end
end

function FbIconView:SetConditionData()

	if nil == self.node_list["BtnShowCondition"] then
		return
	end
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type ~= SceneType.XingZuoYiJi then
		return
	end

	local info = RelicData.Instance:GetXingzuoYijiInfo()
	if nil == next(info) then return end

	self.node_list["BtnShowCondition"]:SetActive(true)
	local temp_str = ""
	if info.now_boss_num > 0 then
		temp_str = string.format(Language.ShengXiao.CurBossNum)
	else
		temp_str = string.format(Language.ShengXiao.CurBoxNum, info.now_box_num)
	end
	self.node_list["ConditionTxt"].text.text = temp_str
end

function FbIconView:CheckQuestionPrepare()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.KF_HOT_SPRING)
	if is_open then
		local activity_prepare_time = HotStringChatData.Instance:GetActivityPrepareTime()
		if activity_prepare_time > 0 then
			self.node_list["TimeTxt"]:SetActive(false)
			self.node_list["SpecialTimeTxt"]:SetActive(false)
			self.node_list["ImgTimeTxt"]:SetActive(false)
			self.node_list["QuestionNode"]:SetActive(true)
			self.node_list["HotSpringFish"]:SetActive(false)
			self:SetQuestionPrepareTime(activity_prepare_time)
		else
			local time = HotStringChatData.Instance:GetFlushGatherTime() or 0
			if time - TimeCtrl.Instance:GetServerTime() <= 0 then
				self.node_list["TimeTxt"]:SetActive(true)
				-- self.node_list["SpecialTimeTxt"]:SetActive(true)
				self.node_list["HotSpringFish"]:SetActive(true)
			else
				-- self.node_list["SpecialTimeTxt"]:SetActive(false)
				self.node_list["TimeTxt"]:SetActive(true)
				self.node_list["HotSpringFish"]:SetActive(false)
			end

			if time - TimeCtrl.Instance:GetServerTime() > 0 then
				if nil == self.hot_spring_count_down then
					local last_time = time - TimeCtrl.Instance:GetServerTime()
					local function diff_time_fun(elapse_time, total_time)
						if total_time <= elapse_time then
							self.node_list["TimeTxt"]:SetActive(true)
							-- self.node_list["SpecialTimeTxt"]:SetActive(true)
							self.node_list["HotSpringFish"]:SetActive(true)
							if self.hot_spring_count_down then
								CountDown.Instance:RemoveCountDown(self.hot_spring_count_down)
								self.hot_spring_count_down = nil
							end
							return
						end
						-- self.node_list["SpecialTimeTxt"]:SetActive(false)
						self.node_list["TimeTxt"]:SetActive(true)
						self.node_list["HotSpringFish"]:SetActive(false)
					end
					self.hot_spring_count_down = CountDown.Instance:AddCountDown(last_time, 1, diff_time_fun)
				end
			end
			self.node_list["ImgTimeTxt"]:SetActive(true)
			self.node_list["QuestionNode"]:SetActive(false)
		end
	end
end

function FbIconView:RemoveQuestionCountDown()
	if self.question_count_down then
		CountDown.Instance:RemoveCountDown(self.question_count_down)
		self.question_count_down = nil
	end
end

function FbIconView:SetQuestionPrepareTime(total_time)
	if self.question_count_down == nil then
		local function diff_time_func(elapse_time, total_time2)
			if elapse_time >= total_time2 then
				local time = "00:00"
				self.node_list["QuestionPrepareTimeTxt"].text.text = time
				self:CheckQuestionPrepare()
				self:RemoveQuestionCountDown()
				self.node_list["TimeTxt"]:SetActive(true)
				self.node_list["ImgTimeTxt"]:SetActive(true)

				self.node_list["QuestionNode"]:SetActive(false)
				return
			end
			local left_time = math.floor(total_time2 - elapse_time + 0.5)
			local h, m, s = WelfareData.Instance:TimeFormat(left_time)
			local h_text = ""
			local m_text = ""
			local s_text = ""
			local the_time_text = ""
			if h > 0 then
				if h>9 then
					h_text = h..":"
				else
					h_text = "0".. h .. ":"
				end
			end
			if m > 9 then
				m_text = m .. "" .. ":"
			else
				m_text = "0".. m .. ":"
			end
			if s > 9 then
				s_text = s .. ""
			else
				s_text = "0"..s
			end
			the_time_text = h_text .. m_text .. s_text
			self.node_list["QuestionPrepareTimeTxt"].text.text = the_time_text
		end
		diff_time_func(0, total_time)
		self.question_count_down = CountDown.Instance:AddCountDown(
			total_time, 1, diff_time_func)
	end
end

function FbIconView:SetMonsterCacheInfo()
	local icon_state_cache = FuBenData.Instance:GetMonsterIconStateCache()
	for k, v in pairs(icon_state_cache) do
		if self.node_list["MonsterIcon" .. k] then
			self.node_list["MonsterIcon" .. k]:SetActive(v)
		end
	end

	-- local icon_gray_cache = FuBenData.Instance:GetMonsterIconGrayCache()
	-- for k, v in pairs(icon_gray_cache) do
	-- 		if self.node_list["ImgMaskIcon" .. k] then
	-- 			self.show_monster_gray[index] = v
	-- 		--self.node_list["ImgMaskIcon" .. k]:SetActive(not v)
	-- 	end
	-- end

	local icon_flush_cache = FuBenData.Instance:GetShowMonsterHadFlushCache()
	local flush_text = Language.Boss.HadFlush
	for k, v in pairs(icon_flush_cache) do
			flush_text = v.flush_text or flush_text
			--self.show_monster_gray[index] = not v.enable
			-- self.show_monster_had_flush[index] = v.enable
			--self.node_list["ImgMaskIcon" .. k]:SetActive( v.enable)
			self.node_list["MonsterIconTimeTxt" .. k]:SetActive(not v.enable)
			self.node_list["HadFlushTxt" .. k]:SetActive( v.enable)
			self.node_list["HadFlushTxt" .. k].text.text = flush_text
		--end
	end

	FuBenData.Instance:ClearFBIconCache()
end

function FbIconView:FlushMoneyTree()
	if nil == self.node_list["ExitFB1TimeTxt_1"] then
		return
	end

	local state = GuildData.Instance:GetMoneyTreeState()
	local now_time = TimeCtrl.Instance:GetServerTime()
	local moneytree_info = GuildData.Instance:GetMoneyTreeTimeInfo()
	local next_time = moneytree_info.tianci_tongbi_close_time or 0
	local time = next_time - now_time
	local moneytree_pos = GuildData.Instance:GetMoneyTreePosInfo()
	local npc_id = GuildData.Instance:GetMoneyTreeID()
	local vo = {}

	self.node_list["ExitFB1TimeTxt_1"]:SetActive(state)
	self.node_list["Explain"]:SetActive(state)

	if state then
		self.node_list["TimeTxt"]:SetActive(false)
		self.node_list["ImgTimeTxt"]:SetActive(false)
		self:SetCountDownByTotalTime(time)
		if nil == moneytree_pos or nil == next(moneytree_pos) then
			return
		end

		vo.npc_id = npc_id or 0
		vo.pos_x = moneytree_pos.npc_x	or 0
		vo.pos_y = moneytree_pos.npc_y	or 0
		self:CreatMoneyTree(vo.npc_id, vo.pos_x, vo.pos_y, 0)
	end
end

function FbIconView:CreatMoneyTree(npc_id, x, y, rotation_y)
	local npc = Scene.Instance:GetNpcByNpcId(npc_id)
	if npc then
		return
	end

	local vo =	NpcVo.New()
	vo.npc_id = npc_id
	vo.pos_x = x
	vo.pos_y = y
	vo.rotation_y = rotation_y
	Scene.Instance:CreateNpc(vo)
	local npc_obj = Scene.Instance:GetNpcByNpcId(npc_id)
	npc_obj:GetFollowUi():SetName("")
end

function FbIconView:OnClickNuZhanList()
	if Scene.Instance:GetSceneType() == SceneType.LuandouBattle then
		ViewManager.Instance:Open(ViewName.LuanDouBattleRewardView)
	else
		ViewManager.Instance:Open(ViewName.KuaFuTuanZhanRewardView)
	end
end

function FbIconView:InitBossScrollList()
	self.is_hide_boss_list = false
	self.list_view_delegate = self.node_list["BossList"].list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetBossListNum, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshBossListCell, self)
	self.node_list["BossListPanel"]:SetActive(true)
	self.node_list["HideBossList"]:SetActive(true)
	self.node_list["HideBossBtn"].button:AddClickListener(BindTool.Bind(self.HideBossList, self))
end

function FbIconView:GetBossListNum()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.MonthBlackWindHigh then
		local boss_data_list, boss_num = KFMonthBlackWindHighData.Instance:GetBossInfo()
		-- return #boss_data_list
		return boss_num
	end
	return 0
end

function FbIconView:RefreshBossListCell(cell, index)
	local boss_data_list = KFMonthBlackWindHighData.Instance:GetBossInfo()
	local data_index = index + 1
	local boss_cell = self.boss_cell_list[cell]
	if boss_cell == nil then
		boss_cell = BossInfoCell.New(cell.gameObject)
		self.boss_cell_list[cell] = boss_cell
	end
	boss_cell:SetData(boss_data_list[data_index])
	boss_cell:SetToggleGroup(self.node_list["BossList"].toggle_group)
	boss_cell:SetCallBack(BindTool.Bind(self.FlushBossList, self))
	-- boss_cell:SetClickCallBack(BindTool.Bind(self.OnClickBossCell, self))
	-- boss_cell:SetIndex(data_index)
end

function FbIconView:FlushBossList()
	if self.node_list["BossList"] then
		self.node_list["BossList"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function FbIconView:HideBossList()
	
	if self.can_tween then
		self.can_tween = false
		local size = self.node_list["BossListPanel"].rect.sizeDelta
		local local_pos = self.node_list["BossListPanel"].transform.position
		local pos = Vector3(local_pos.x, 0, 0)
		local tween_callback = function ()
			self.can_tween = true
		end
		if self.is_hide_boss_list then
			UITween.AlpahShowPanel(self.node_list["BossListPanel"], true, 0.6)
			UITween.MoveToShowPanel(self.node_list["BossListPanel"], Vector3(size.x + 100, 0, 0), Vector3(0, 0, 0), 0.6, nil, tween_callback)
		else
			UITween.AlpahShowPanel(self.node_list["BossListPanel"], false, 0.6)
			UITween.MoveToShowPanel(self.node_list["BossListPanel"], pos, Vector3(size.x + 100, 0, 0), 0.6, nil, tween_callback)
		end
		self.is_hide_boss_list = not self.is_hide_boss_list
		self.node_list["BossListArrow1"]:SetActive(self.is_hide_boss_list)
		self.node_list["BossListArrow2"]:SetActive(not self.is_hide_boss_list)
	end
end

function FbIconView:FlushImgShuiJingBuff()
	local scene_type = Scene.Instance:GetSceneType()
	local is_open_buff = FuBenData.Instance:GetIsOpenBuffType(scene_type)
	if is_open_buff then
		if nil == self.buff_timer_delay then
			self.buff_timer_deley = GlobalTimerQuest:AddDelayTimer(function()
				if self.node_list then
					self.node_list["BtnIsOnShuijingBuff"]:SetActive(false)
				end
				FuBenData.Instance:SetIsOpenBuffType(scene_type, false)
			end, 15)
		end
	else
		self.node_list["BtnIsOnShuijingBuff"]:SetActive(false)
	end
end

BossInfoCell = BossInfoCell or BaseClass(BaseCell)
function BossInfoCell:__init()
	self.ProgressBar = ProgressBar.New(self.node_list["Slider"])
	self.root_node.toggle:AddClickListener(BindTool.Bind(self.OnClickToggle, self))
	self.callback = nil
	self.count_down = nil
end

function BossInfoCell:__delete()
	if nil ~= self.ProgressBar then
		self.ProgressBar:DeleteMe()
		self.ProgressBar = nil
	end

	if CountDown.Instance:HasCountDown(self.count_down) then
		CountDown.Instance:RemoveCountDown(self.count_down)
	end
	self.count_down = nil
	self.callback = nil
end

function BossInfoCell:OnFlush()
	if self.data == nil then return end
	
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.monster_id]

	if not monster_cfg then return end
	local bundle, asset = ResPath.GetBossIcon(monster_cfg.headid)
	self.node_list["Icon"].image:LoadSprite(bundle, asset)
	self.node_list["TxtName"].text.text = monster_cfg.name
	self.node_list["ImgHighLight"]:SetActive(self.root_node.toggle.isOn)
	if self.data.cur_hp <= 0 then
		self.node_list["Slider"]:SetActive(false)
		local seq = KFMonthBlackWindHighData.Instance:GetBossCfgById(self.data.monster_id)
		if seq >= GameEnum.CROSS_DARK_NIGHT_MONSTER_MAX_COUNT then
			self.node_list["Time"].text.text = Language.MonthBlackWindHigh.HasAllKilled
		else
			self:SetFlushCountDown()
		end
		self.node_list["Time"]:SetActive(true)
	elseif self.data.cur_hp == self.data.max_hp then
		self.node_list["Slider"]:SetActive(false)
		self.node_list["Time"].text.text = Language.MonthBlackWindHigh.HasFlush
		self.node_list["Time"]:SetActive(true)
	else
		self.node_list["Time"]:SetActive(false)
		local bool_num = self.data.cur_hp / self.data.max_hp
		bool_num = math.floor(bool_num * 100)
		self.node_list["Blood"].text.text = bool_num .. "%"
		bool_num = bool_num / 100
		self.ProgressBar:SetValue(bool_num)
		
		self.node_list["Slider"]:SetActive(true)
	end
end

function BossInfoCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function BossInfoCell:SetCallBack(callback)
 	self.callback = callback
 end 

function BossInfoCell:OnClickToggle()
	self.root_node.toggle.isOn = true
	if self.data == nil then return end
	KFMonthBlackWindHighData.Instance:SetTargetBossInfo(self.data)
	KFMonthBlackWindHighCtrl.Instance:MoveToBoss()
	if self.callback then
		self.callback()
	end
end

function BossInfoCell:SetFlushCountDown()
	-- if CountDown.Instance:HasCountDown(self.count_down) then
	-- 	CountDown.Instance:RemoveCountDown(self.count_down)
	-- 	self.count_down = nil
	-- end
	if self.count_down == nil then
		local next_check_reward_timestamp = KFMonthBlackWindHighData.Instance:GetNextCheckRewardTimestamp()
		local next_time = next_check_reward_timestamp - TimeCtrl.Instance:GetServerTime()
		self:CountDownTime(0, next_time)
		self.count_down = CountDown.Instance:AddCountDown(next_time, 1, BindTool.Bind(self.CountDownTime, self))
	end
end

function BossInfoCell:CountDownTime(elapse_time, total_time)
	local dis_time = total_time - elapse_time
	local the_time_text = TimeUtil.FormatSecond(dis_time, 7)
	self.node_list["Time"].text.text = the_time_text
	if dis_time <= 0 then
		self.node_list["Time"].text.text = Language.MonthBlackWindHigh.HasFlush
		if self.count_down then
			if CountDown.Instance:HasCountDown(self.count_down) then
				CountDown.Instance:RemoveCountDown(self.count_down)
			end
			self.count_down = nil
		end
	end
end