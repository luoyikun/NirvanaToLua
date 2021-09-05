FuBenView = FuBenView or BaseClass(BaseView)

function FuBenView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/fubenview_prefab", "AdvanceFBContent", {TabIndex.fb_phase}},	-- 进阶
		{"uis/views/fubenview_prefab", "ExpFBContent2", {TabIndex.fb_exp}},			-- 经验
		-- {"uis/views/fubenview_prefab", "GuardContent", {TabIndex.fb_guard}},		-- 守护
		{"uis/views/fubenview_prefab", "TeamFBContent", {TabIndex.fb_team_tower}},	-- 组队副本
		{"uis/views/fubenview_prefab", "DefenseFBContent", {TabIndex.fb_defense}},	-- 塔防
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},

		-- {"uis/views/fubenview_prefab", "PushContent", {TabIndex.fb_push}},			--血战
		-- {"uis/views/fubenview_prefab", "VipFBContent", {TabIndex.fb_vip}},		--VIP 已经干掉
		-- {"uis/views/fubenview_prefab", "StoryFBContent", {TabIndex.fb_story}},	--剧情 已经干掉
	}

	self.def_index = TabIndex.fb_phase

	self.full_screen = true
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
end

function FuBenView:LoadCallBack(index, index_nodes)
	self.tab_cfg = {
		{name = Language.FuBen.TabbarName[1],  bundle = "uis/images_atlas", asset = "tab_icon_advance", func = BindTool.Bind(self.IsOpenFuBenPhase, self), tab_index = TabIndex.fb_phase, remind_id = RemindName.FuBen_JinJie},
		{name = Language.FuBen.TabbarName[2],  bundle = "uis/images_atlas", asset = "tab_icon_exp", func = "fb_exp", tab_index = TabIndex.fb_exp, remind_id = RemindName.FuBen_Exp},
		-- {name = Language.FuBen.TabbarName[4],  bundle = "uis/images_atlas", asset = "tab_icon_shouhu", func = "fb_guard", tab_index = TabIndex.fb_guard, remind_id = RemindName.FuBen_ShouHu},
		{name = Language.FuBen.TabbarName[8],  bundle = "uis/images_atlas", asset = "tab_icon_team", func = "fb_team_tower", tab_index = TabIndex.fb_team_tower, remind_id = RemindName.FuBen_Team},
		{name = Language.FuBen.TabbarName[7],  bundle = "uis/images_atlas", asset = "tab_icon_defense", func = "fb_defense", tab_index = TabIndex.fb_defense, remind_id = RemindName.FuBen_Defense},
	}

	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], self.tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))
	self.node_list["TxtTitle"].text.text = Language.FuBen.TitleName

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.HandleClose, self))
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.ClickRecharge, self))
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.FuBen, BindTool.Bind(self.GetUiCallBack, self))
	self:SetBg()
	BossCtrl.Instance:RequestDropLog(DROP_LOG_TYPE.DOPE_LOG_TYPE_FB)
	-- BossCtrl.Instance:SendCrossBossBossInfoReq(CROSS_BOSS_OPERATE_TYPE.DROP_RECORD)
	self:FlushPhaseChallengeTab()
end

function FuBenView:FlushPhaseChallengeTab()
	local tab_button = self.tabbar:GetTabButton(TabIndex.fb_phase)
	if tab_button then
		local bundle,asset = ResPath.GetImages("label_status_xianshichallengetab")
		local left_time = FuBenData.Instance:GetLastTime()
		tab_button:ShowBiPin(left_time > 0, bundle, asset, true, true)
	end
end

function FuBenView:SetBg(index)
	if index ~= self:GetShowIndex() then
		return
	end
	local call_back = function ()
		self.node_list["UnderBg"]:SetActive(true)
		self.node_list["TaiZi"]:SetActive(false)
	end
	if index == TabIndex.fb_exp then
		self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/fubenexpbg", "FuBenExpBg.jpg", call_back)
	elseif index == TabIndex.fb_defense then
		self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/bg_defense", "bg_defense.jpg", call_back)
	else
		self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/zhuanzhi_bg_1", "zhuanzhi_bg_1.jpg", call_back)
	end
end

function FuBenView:IsOpenFuBenPhase()
	if not OpenFunData.Instance:CheckIsHide("fb_phase") then
		return false
	end

	local num_list = FuBenData.Instance:GetOpenToggleNum()
	if num_list and #num_list <= 0 then
		return false
	end
	return true
end

function FuBenView:SetTeamFuBenBg(index)
	if index == FuBenTeamType.TEAM_TYPE_TEAM_TOWERDEFEND then
		self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/team_tower_bg", "team_tower_bg.jpg")
	elseif index == FuBenTeamType.TEAM_TYPE_EQUIP_TEAM_FB then
		self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/team_equip_bg", "team_equip_bg.jpg")
	end
end

function FuBenView:HandleClose()
	self:Close()
end

function FuBenView:ClickRecharge()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function FuBenView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.Tab then
		local index = TabIndex[ui_param]
		if index == self.show_index then
			return NextGuideStepFlag
		else
			local button = self.tabbar:GetTabButton(index)
			if button then
				local root_node = button.root_node
				local callback = BindTool.Bind(self.ChangeToIndex, self, index)
				return root_node, callback
			end
		end
	elseif ui_name == GuideUIName.MountAttrBtn then
		if self.advance_view then
			return self.advance_view:GetChallengeButton()
		end
	-- elseif ui_name == GuideUIName.QhallengeFbBtn then
	-- 	if self.guard_view then
	-- 		return self.guard_view:Challenge()
	-- 	end
	elseif ui_name == GuideUIName.ExpZhuduiBtn then
		if self.exp_view then
			return self.exp_view:GetBtnZuDui()
		end
	elseif self.node_list[ui_name] then
		if self.node_list[ui_name].gameObject.activeInHierarchy then
			return self.node_list[ui_name]
		end
	end
end

function FuBenView:ReleaseCallBack()
	if self.advance_view then
		self.advance_view:DeleteMe()
		self.advance_view = nil
	end

	if self.exp_view then
		self.exp_view:DeleteMe()
		self.exp_view = nil
	end

	-- if self.guard_view then
	-- 	self.guard_view:DeleteMe()
	-- 	self.guard_view = nil
	-- end

	if self.push_all_view then
		self.push_all_view:DeleteMe()
		self.push_all_view = nil
	end

	if self.defense_view then
		self.defense_view:DeleteMe()
		self.defense_view = nil
	end

	if self.team_tower_view then
		self.team_tower_view:DeleteMe()
		self.team_tower_view = nil
	end

	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.FuBen)
	end

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
end

function FuBenView:CloseCallBack()
	FunctionGuide.Instance:DelWaitGuideListByName("push_yuansu")
	FunctionGuide.Instance:DelWaitGuideListByName("push_special")
	MainUICtrl.Instance:FlushView("show_market")

	PlayerData.Instance:UnlistenerAttrChange(self.player_data_change)
	self.player_data_change = nil

	SettingData.Instance:SetCommonTipkey("chongzhi", false)

	if self.advance_view then
		self.advance_view:CloseCallBack()
	end

	if self.push_all_view then
		self.push_all_view:CloseCallBack()
	end

	if self.exp_view then
		self.exp_view:CloseCallBack()
	end
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_callback)
end

function FuBenView:OpenCallBack()
	RemindManager.Instance:Fire(RemindName.FuBenSingle)
	-- RemindManager.Instance:Fire(RemindName.FuBen_Defense)
	-- RemindManager.Instance:Fire(RemindName.FuBen_Exp)
	--开始引导
	FunctionGuide.Instance:TriggerGuideByName("push_yuansu")
	FunctionGuide.Instance:TriggerGuideByName("push_special")
	FuBenData.Instance:SetIsNotClickFuBen(false)
	local main_view = MainUICtrl.Instance:GetView()
	if main_view then
		main_view:ShowXianShiChallenge()
	end

	-- 监听系统事件
	self.player_data_change = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.player_data_change)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])

	self.item_change_callback = BindTool.Bind(self.OnItemDataChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change_callback)

	FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.REQ_ROOM_LIST, FuBenTeamType.TEAM_TYPE_TEAM_DAILY_FB)
end

function FuBenView:OnItemDataChange()
	self:Flush("exp")
end

function FuBenView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(vo.gold)
	end

	if attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(vo.bind_gold)
	end
end

function FuBenView:GetFuBenExpView()
	return self.exp_view
end

function FuBenView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)
	if nil ~= index_nodes then
		if index == TabIndex.fb_phase then
			self.advance_view = FuBenPhaseView.New(index_nodes["AdvanceFBContent"])			--进阶
		elseif index == TabIndex.fb_exp then
			self.exp_view = FuBenNewExpView.New(index_nodes["ExpFBContent2"])				--经验
			RemindManager.Instance:Fire(RemindName.FuBen_Exp)
		-- elseif index == TabIndex.fb_guard then
		-- 	self.guard_view = FuBenGuardView.New(index_nodes["GuardContent"])				--守护
		elseif index == TabIndex.fb_defense then
			self.defense_view = FuBenDefenseView.New(index_nodes["DefenseFBContent"])		--塔防
			RemindManager.Instance:Fire(RemindName.FuBen_Defense)
		elseif index == TabIndex.fb_team_tower then
			self.team_tower_view = TeamFBContent.New(index_nodes["TeamFBContent"])			--组队守护
			FuBenData.Instance:FBTeamRedPointSign()
			RemindManager.Instance:Fire(RemindName.FuBen_Team)
		end
	end
	self:SetBg(index)

	-- if index == TabIndex.fb_push and self.push_all_view then
	-- 	-- self.push_all_view:UpdataView()
	-- 	-- FuBenData.Instance:SetShowPushIndex(index == TabIndex.fb_push and 1 or 0)
	-- 	-- self.push_all_view:ShowIndexCallBack()
	-- 	-- self.push_all_view:OpenCallBack()
	if index == TabIndex.fb_phase and self.advance_view then 
		self.advance_view:DoPanelTweenPlay()
		self.advance_view:Flush()
		self.advance_view:ShowIndex()

	elseif index == TabIndex.fb_exp and self.exp_view then
		self.exp_view:DoPanelTweenPlay()
		self.exp_view:FlushInfo()
		self.exp_view:OpenRequestTeamList()

	elseif index == TabIndex.fb_defense then
		self.defense_view:DoPanelTweenPlay()
		self.defense_view:Flush()

	elseif index == TabIndex.fb_team_tower then
		FuBenData.Instance:ClearTeamFbRoomList()
		RemindManager.Instance:SetRemindToday(RemindName.FuBen_Team)
		self.team_tower_view:DoPanelTweenPlay()
		self.team_tower_view:ChangeIndexBySeq()
		self.team_tower_view:OpenRequestTeamList()
		self.team_tower_view:Flush()
	end
	if index ~= TabIndex.fb_team_tower then
		if self.team_tower_view then
			self.team_tower_view:CancelRequest()
		end
	end
	if index ~= TabIndex.fb_exp then
		if self.exp_view then
			self.exp_view:CancelRequest()
		end
	end
end

function FuBenView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if value then
		self:ShowIndexCallBack(self.show_index)
	end
end

function FuBenView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "phase" then
			if self.advance_view then
				self.advance_view:Flush()
			end
			if self:IsOpen() then
				self:FlushPhaseChallengeTab()
			end
		elseif k == "exp" then
			if self.exp_view then
				self.exp_view:FlushInfo()
			end
		elseif k == "vip" then
			if self.vip_view then
				self.vip_view:FlushView()
			end

		elseif k == "story" then
			if self.story_view then
				self.story_view:FlushView()
			end

		-- elseif k == "tower_defend" then
		-- 	if self.guard_view then
		-- 		self.guard_view:OnFlush()
		-- 	end
		elseif k == "kaifu_to_exp" then
			if self.exp_view then
				self.exp_view:FlushInfo()
			end
			self.node_list["ExpToggle"].toggle.isOn = true
		elseif k == "manypeople" then
			if self.many_people_view then
				self.many_people_view:Flush()
			end
		elseif k == "defense" then
			if self.defense_view then
				self.defense_view:Flush()
			end
		elseif k == "team" then
			if self.team_tower_view then
				self.team_tower_view:Flush()
			end
		elseif k == "task_fb_phase" then
			if self.advance_view then
				self.advance_view:Flush(k, {v[1]})
			end
		elseif k == "click_next" then
			if self.advance_view then
				self.advance_view:Flush("click_next")
			end
		end
	end
end