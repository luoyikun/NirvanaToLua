require("game/rune/rune_inlay_view")
require("game/rune/rune_analyze_view")
require("game/rune/rune_exchange_view")
require("game/rune/rune_treasure_view")
require("game/rune/rune_compose_view")
require("game/rune/rune_tower_view")
require("game/rune/rune_zhuling_view")
require("game/rune/rune_totalshow_view")

RuneView = RuneView or BaseClass(BaseView)
function RuneView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/rune_prefab", "TowerContent", {TabIndex.rune_tower}},
		{"uis/views/rune_prefab", "TotalShowContent", {TabIndex.rune_totalshow}},
		{"uis/views/rune_prefab", "AnalyzeContent", {TabIndex.rune_analyze}},
		{"uis/views/rune_prefab", "ExchangeContent", {TabIndex.rune_exchange}},
		{"uis/views/rune_prefab", "InlayContent", {TabIndex.rune_inlay}},
		{"uis/views/rune_prefab", "TreasureContent", {TabIndex.rune_treasure}},
		{"uis/views/rune_prefab", "ZhuLingContent", {TabIndex.rune_zhuling}},
		-- {"uis/views/rune_prefab", "ComposeContent", {TabIndex.rune_compose}},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
	}
	self.full_screen = true
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.FlushTabbar, self))
end

function RuneView:__delete()
	GlobalEventSystem:UnBind(self.open_trigger_handle)
end

function RuneView:ReleaseCallBack()
	if self.inlay_view then
		self.inlay_view:DeleteMe()
		self.inlay_view = nil
	end
	if self.analyze_view then
		self.analyze_view:DeleteMe()
		self.analyze_view = nil
	end
	if self.exchange_view then
		self.exchange_view:DeleteMe()
		self.exchange_view = nil
	end
	if self.treasure_view then
		self.treasure_view:DeleteMe()
		self.treasure_view = nil
	end
	if self.compose_view then
		self.compose_view:DeleteMe()
		self.compose_view = nil
	end
	if self.tower_view then
		self.tower_view:DeleteMe()
		self.tower_view = nil
	end
	if self.totalshow_view then
		self.totalshow_view:DeleteMe()
		self.totalshow_view = nil
	end
	if self.zhuling_view then
		self.zhuling_view:DeleteMe()
		self.zhuling_view = nil
	end

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.Rune)
	end
	-- 清理变量和对象
end

function RuneView:LoadCallBack()
	local tab_cfg = {
		{name = Language.Rune.TabbarName[1],  bundle = "uis/images_atlas", asset = "tab_icon_tower", func = "runetower", tab_index = TabIndex.rune_tower, remind_id = RemindName.RuneTower},
		{name = Language.Rune.TabbarName[2],  bundle = "uis/images_atlas", asset = "tab_icon_inlay", func = "runeinlay", tab_index = TabIndex.rune_inlay, remind_id = RemindName.RuneInlay},
		{name = Language.Rune.TabbarName[3],  bundle = "uis/images_atlas", asset = "tab_icon_analyze", func = "runeanalyze", tab_index = TabIndex.rune_analyze, remind_id = RemindName.RuneAnalyze},
		{name = Language.Rune.TabbarName[5],  bundle = "uis/images_atlas", asset = "tab_icon_treasure", func = "runetreasure", tab_index = TabIndex.rune_treasure, remind_id = RemindName.RuneTreasure},
		{name = Language.Rune.TabbarName[4],  bundle = "uis/images_atlas", asset = "tab_icon_exchange", func = "runeexchange", tab_index = TabIndex.rune_exchange},
		{name = Language.Rune.TabbarName[6],  bundle = "uis/images_atlas", asset = "tab_icon_zhuling", func = "rune_zhuling", tab_index = TabIndex.rune_zhuling},
		{name = Language.Rune.TabbarName[8],  bundle = "uis/images_atlas", asset = "tab_icon_totalshow", func = "runetotalshow", tab_index = TabIndex.rune_totalshow,},
		-- {name = Language.Rune.TabbarName[7],  bundle = "uis/images_atlas", asset = "tab_icon_compose", func = "runecompose", tab_index = TabIndex.rune_compose, remind_id = RemindName.RuneCompose},
	}
	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))
	local bundle, asset = "uis/views/rune/images_atlas", "icon_runepieces"
	self.node_list["ImgBindGold"].image:LoadSprite(bundle, asset, function()
		self.node_list["ImgBindGold"].image:SetNativeSize() 
	end)
	self.node_list["ImgBindGold"].image.transform.localPosition = Vector3(-80, 1.5, 0)
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.OnClickAddGold, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["TxtTitle"].text.text = Language.Rune.TitleName
	self.node_list["TaiZi"]:SetActive(false)
	self.node_list["UnderBg"]:SetActive(false)
	self:SetBg()

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Rune, BindTool.Bind(self.GetUiCallBack, self))
end

function RuneView:FlushTabbar()
	if not self:IsOpen() then return end
	self.tabbar:FlushTabbar()
end

function RuneView:OnClickAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function RuneView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)

	if nil ~= index_nodes then
		if index == TabIndex.rune_inlay then
			self.inlay_view = RuneInlayView.New(index_nodes["InlayContent"])
			RuneCtrl.Instance:SendBigSmallGoalOper(ROLE_BIG_SMALL_GOAL_OPERA_TYPE.ROLE_BIG_SMALL_GOAL_OPERA_INFO, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_RUNE)
		elseif index == TabIndex.rune_analyze then
			self.analyze_view = RuneAnalyzeView.New(index_nodes["AnalyzeContent"])
		elseif index == TabIndex.rune_exchange then
			self.exchange_view = RuneExchangeView.New(index_nodes["ExchangeContent"])
		elseif index == TabIndex.rune_treasure then
			self.treasure_view = RuneTreasureView.New(index_nodes["TreasureContent"])
		elseif index == TabIndex.rune_tower then
			self.tower_view = RuneTowerView.New(index_nodes["TowerContent"])
		elseif index == TabIndex.rune_totalshow then
			self.totalshow_view = RuneTotalShowView.New(index_nodes["TotalShowContent"])
		elseif index == TabIndex.rune_zhuling then
			self.zhuling_view = RuneZhuLingView.New(index_nodes["ZhuLingContent"])
		-- elseif index == TabIndex.rune_compose then
		-- 	self.compose_view = RuneComposeView.New(index_nodes["ComposeContent"])
		end
	end
	self:SetBg(index)
	self:InitMoney()
	if index == TabIndex.rune_inlay then
		self.inlay_view:InitView()
		self.inlay_view:Flush()
		self.inlay_view:UIsMove()
		self:ChangeIcon("gold")
	elseif index == TabIndex.rune_analyze then
		self.analyze_view:InitView()
		self.analyze_view:UIsMove()
		self.analyze_view:Flush()
		self:ChangeIcon("gold")
	elseif index == TabIndex.rune_exchange then
		self.exchange_view:InitView()
		self.exchange_view:Flush()
		self.exchange_view:UIsMove()
		self:ChangeIcon("suipian")
		self:FlushSuiPian()
	elseif index == TabIndex.rune_treasure then
		self.treasure_view:InitView()
		self.treasure_view:Flush()
		self.treasure_view:UIsMove()
		self:ChangeIcon("suipian")
		self:FlushSuiPian()
	elseif index == TabIndex.rune_tower then
		self.tower_view:InitView()
		self.tower_view:Flush()
		ClickOnceRemindList[RemindName.RuneTower] = 0
		self:ChangeIcon("gold")
	elseif index == TabIndex.rune_totalshow then
		self.totalshow_view:InitView()
		self.totalshow_view:Flush()
		self:ChangeIcon("gold")
	elseif index == TabIndex.rune_zhuling then
		self.zhuling_view:InitView()
		self.zhuling_view:Flush()
		self.zhuling_view:UIsMove()
		self:ChangeIcon("gold")
	-- elseif index == TabIndex.rune_compose then
	-- 	self.compose_view:InitView()
	-- 	self.compose_view:Flush()
	-- 	self.compose_view:UIsMove()
	-- 	self:ChangeIcon("gold")
	-- 	self.node_list["BindGoldText"].text.text = 0
	end
	if self.zhuling_view and index ~= TabIndex.rune_zhuling then
		self.zhuling_view:CloseCallBack()
	end
end

function RuneView:SetBg(index)
	local call_back = function ()
		self.node_list["UnderBg"]:SetActive(true)
	end
	if index == TabIndex.rune_tower or index == TabIndex.rune_totalshow then
		self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/rune_tower_bg", "rune_tower_bg.jpg", call_back)
	elseif index == TabIndex.rune_inlay or index == TabIndex.rune_analyze then
		self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/inlaycontent_bg2", "InlayContent_BG2.jpg", call_back)
	elseif index == TabIndex.rune_zhuling then
		self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/bg_rune_full", "bg_rune_full.jpg", call_back)
	elseif index == TabIndex.rune_treasure then
		self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/rune_bg_xunbao", "rune_bg_xunbao.jpg", call_back)
	else 
		self.node_list["UnderBg"]:SetActive(false)
	end
end

function RuneView:ChangeIcon(flag)
	local item_id = COMMON_CONSTS.VIRTUAL_ITEM_BINDGOL
	if flag == "suipian" then
		local bundle, asset = ResPath.GetItemIcon(90012)
		self.node_list["ImgBindGold"].image:LoadSprite(bundle, asset, function()
			-- self.node_list["ImgBindGold"].image:SetNativeSize() 
		end)
		self.node_list["ImgBindGold"].rect.sizeDelta = Vector2(44, 44)
		item_id = ResPath.CurrencyToIconId["rune_suipian"]
	elseif flag == "gold" then
		local bundle, asset = "uis/images_atlas", "icon_gold_5_bind"
		self.node_list["ImgBindGold"].image:LoadSprite(bundle, asset, function()
			self.node_list["ImgBindGold"].image:SetNativeSize()
		end)
	end

	self.node_list["ImgBindGold"].button:AddClickListener(function ()
		TipsCtrl.Instance:OpenItem({item_id = item_id})
	end)
end

function RuneView:InitTab()
	if self:IsOpen() then 
		local pass_layer = RuneData.Instance:GetPassLayer()
		local other_cfg = RuneData.Instance:GetOtherCfg()
		local need_pass_layer = other_cfg.rune_compose_need_layer
		-- if need_pass_layer then
		-- 	if self.tabbar and self.tabbar.tab_button_list and next(self.tabbar.tab_button_list) then
		-- 		self.tabbar.tab_button_list[7]:SetActive(pass_layer >= need_pass_layer)
		-- 	end 
		-- end

		-- local rune_zhuling = OpenFunData.Instance:CheckIsHide("rune_zhuling")
		-- if self.tabbar and self.tabbar.tab_button_list and next(self.tabbar.tab_button_list) then
		-- 	local need_pass_layer = other_cfg.rune_lianhun_need_layer
		-- 	self.tabbar.tab_button_list[6]:SetActive(rune_zhuling and pass_layer >= need_pass_layer)
		-- end
	end
end

function RuneView:InitMoney()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(main_vo.gold)
	self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(main_vo.bind_gold)
end

function RuneView:FlushSuiPian()
	local index = self:GetShowIndex()
	if index == TabIndex.rune_treasure or index == TabIndex.rune_exchange then
		local suipian = RuneData.Instance:GetSuiPian()
		local suipian_str = CommonDataManager.ConverMoney(suipian)
		self.node_list["BindGoldText"].text.text = suipian_str
	end
end

function RuneView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(vo.gold)
	elseif attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(vo.bind_gold)
		self:FlushSuiPian()
	end
end

function RuneView:OpenCallBack()
	self:FlushTabbar()
	self:InitTab()
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	self:Flush()
	RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_RUNE_TOWER_LAYER)
end

function RuneView:CloseCallBack()
	MainUICtrl.Instance:FlushView("show_market")
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
	if self.tower_view then
		self.tower_view:CloseCallBack()
	end

	if self.zhuling_view then
		self.zhuling_view:CloseCallBack()
	end
end

function RuneView:OnFlush(params_t)
	for k, v in pairs(params_t) do
		if k == "inlay" then
			if self.inlay_view then
				self.inlay_view:FlushView()
			end
		elseif k == "analyze" then
			if self.analyze_view then
				self.analyze_view:PlayAni()
				self.analyze_view:FlushView()
			end
		elseif k == "exchange" then
			if self.exchange_view then
				self.exchange_view:FlushView()
				self:FlushSuiPian()
			end
		elseif k == "treasure" then
			if self.treasure_view then
				self.treasure_view:FlushView()
				self:FlushSuiPian()
			end
		elseif k == "tower" or k == "rank" then
			if self.tower_view then
				if k == "tower" then
					self.tower_view:FlushView()
				elseif k == "rank" then
					self.tower_view:FlushRank()
				end
			end
		elseif k == "zhuling" or k == "zhuling_bless" or k == "zhuling_effect" then
			if self.zhuling_view then
				if k == "zhuling" then
					self.zhuling_view:FlushView()
				elseif k == "zhuling_bless" then
					self.zhuling_view:OnRewardDataChange(v[1], v[2])
				elseif k == "zhuling_effect" then
					self.zhuling_view:Zhuling()
				end
			end
		elseif k == "compose" then
			if self.compose_view then
				self.compose_view:FlushView()
			end
		elseif k == "compose_effect" then
			if self.compose_view then
				self.compose_view:PlayUpEffect()
			end
		elseif k == "suipian" then
			self:FlushSuiPian()
		end
	end
end

function RuneView:FlushGoal()
	if self.inlay_view then
		if self.tabbar.cur_tab_index == TabIndex.rune_inlay then
			self.inlay_view:FlshGoalContent()
		end
	end
end

function RuneView:OtherOpenView()
	if self.show_index == TabIndex.rune_zhuling then
		if self.zhuling_view then
			self.zhuling_view.is_auto = false
		end
	end
end

function RuneView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.Tab then
		local index = TabIndex[ui_param]
		if index == TabIndex.rune_inlay then
			if self.tabbar:GetTabButton(TabIndex.rune_inlay) then
				local root_node = self.tabbar:GetTabButton(index).root_node
				local callback = BindTool.Bind(self.ChangeToIndex, self, TabIndex.rune_inlay)
				if index == self.show_index then
					return NextGuideStepFlag
				else
					return root_node, callback
				end
			end
		end
	elseif ui_name == GuideUIName.EnterButton then
		if self.tower_view then
			return self.tower_view:GetEnterBut()
		end
	elseif ui_name == GuideUIName.RuneSlot1 then
		if self.inlay_view then
			return self.inlay_view:GetGuideSlot(2)
		end
	elseif self.node_list[ui_name] then
		if self.node_list[ui_name].gameObject.activeInHierarchy then
			return self.node_list[ui_name]
		end
	end
end