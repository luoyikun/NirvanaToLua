KFArenaActivityView = KFArenaActivityView or BaseClass(BaseView)

function KFArenaActivityView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
		{"uis/views/kfarenaview_prefab", "KFArenaView", {TabIndex.kf_arena_view},},
		{"uis/views/kfarenaview_prefab", "KFArenaRankView", {TabIndex.kf_arena_rank_view},},
		{"uis/views/arena_prefab", "ExchangeContent",{TabIndex.exchange_hunjing},},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/exchangeview_prefab", "ScoreExchangeContent"},
		
	}
	self.def_index = TabIndex.kf_arena_view
	self.full_screen = true								-- 是否是全屏界面
	self.play_audio = true

	self.click_guanghui = false
end

function KFArenaActivityView:__delete()

end

function KFArenaActivityView:ReleaseCallBack()
	if self.kf_arena_view then
		self.kf_arena_view:DeleteMe()
		self.kf_arena_view = nil
	end

	if self.kf_arena_rank_view then
		self.kf_arena_rank_view:DeleteMe()
		self.kf_arena_rank_view = nil
	end

	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.KFArenaActivityView)
	end

	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.exchange_content_view ~= nil then
		self.exchange_content_view:DeleteMe()
		self.exchange_content_view = nil
	end

	self.tabbar:DeleteMe()
	self.tabbar = nil
end

function KFArenaActivityView:LoadCallBack()
	local tab_cfg = {
		{name = Language.Arena.Among,  bundle = "uis/images_atlas", asset = "icon_tab_lunjian", func = "kf_arena_view", tab_index = TabIndex.kf_arena_view, remind_id = RemindName.KFArenaChallange},
		{name = Language.Arena.Rank,  bundle = "uis/images_atlas", asset = "icon_tab_ranking", func = "kf_arena_rank_view", tab_index = TabIndex.kf_arena_rank_view, remind_id = RemindName.KFArenaRank},
		{name = Language.Arena.Exchange,  bundle = "uis/images_atlas", asset = "icon_tab_exchange", func = "exchange_hunjing", tab_index = TabIndex.exchange_hunjing,},
	}

	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))

	self.node_list["TxtTitle"].text.text = Language.Title.KFArena
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.ClickRecharge, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.HandleClose, self))

	self.node_list["UnderBg"]:SetActive(false)
	self.node_list["TaiZi"]:SetActive(false)

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.KFArenaActivityView, BindTool.Bind(self.GetUiCallBack, self))
end

function KFArenaActivityView:ClickRecharge()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function KFArenaActivityView:OpenCallBack()
	RemindManager.Instance:SetImmdiateRemind(RemindName.Arena)
	--开始引导
	ArenaCtrl.Instance:SetIsRemind()
	FunctionGuide.Instance:TriggerGuideByName("arena")
	-- 监听系统事件
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold")
	self:PlayerDataChangeCallback("bind_gold")

	local bundle, asset = ResPath.GetExchangeNewIcon(icon_img_path[TabIndex.exchange_hunjing])
	self.node_list["ImgIcon"].image:LoadSprite(bundle, asset .. ".png")
	self.node_list["ImgIcon"].image:SetNativeSize()
	self.node_list["BindGoldNode"]:SetActive(false)
	self.node_list["ImgIcon"].button:AddClickListener(function ()
		TipsCtrl.Instance:OpenItem({item_id = ResPath.CurrencyToIconId["HunJing"]})
	end)

	ArenaData.Instance:SetArenaMainuiShow(false)
	self.tabbar:FlushTabbar()
	self:Flush()

	-- RemindManager.Instance:CreateIntervalRemindTimer(RemindName.Arena)
	ExchangeCtrl.Instance:SendGetConvertRecordInfo()

	-- self:ShowXianShi()
	MainUICtrl.Instance:GetView():ShowArenaJueBanYuyi()
end

function KFArenaActivityView:CloseCallBack()
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if cur_day > -1 and self.click_guanghui == true then
		PlayerPrefsUtil.SetInt("IsHasXianShi29", cur_day)
	end	
	-- self:ShowXianShi()
	MainUICtrl.Instance:GetView():ShowArenaJueBanYuyi()
	FunctionGuide.Instance:DelWaitGuideListByName("arena")

	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
end

function KFArenaActivityView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		local count = vo.gold
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(count)
	end
	if attr_name == "bind_gold" then
		local count = vo.bind_gold
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(count)
	end
end

function KFArenaActivityView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)
	self:ChangeUnderBG(index)
	if nil ~= index_nodes then
		if index == TabIndex.kf_arena_view then
			self.kf_arena_view = KFArenaView.New(index_nodes["KFArenaView"])
		elseif index == TabIndex.exchange_hunjing then
			self.exchange_content_view = ExchangeContentView.New(index_nodes["ExchangeContent"])
		elseif index == TabIndex.kf_arena_rank_view then
			self.kf_arena_rank_view = KFArenaRankView.New(index_nodes["KFArenaRankView"])
		end
	end

	if index == TabIndex.kf_arena_view then
		self.kf_arena_view:OpenCallBack()
		self.kf_arena_view:DoPanelTweenPlay()
		self.kf_arena_view:Flush()
	elseif index == TabIndex.kf_arena_rank_view then
		self.kf_arena_rank_view:OpenCallBack()
		self.kf_arena_rank_view:DoPanelTweenPlay()
		self.kf_arena_rank_view:SetReMainTime()
		self.kf_arena_rank_view:Flush()
	end

	if self.exchange_content_view then
		self.exchange_content_view:DoPanelTweenPlay()
		self.exchange_content_view:SetCurrentPriceType(SHOW_EXCHANGE_TAB[index])
		self.exchange_content_view:OnFlushListView()
		self.exchange_content_view:FlushCoin()
		self.exchange_content_view:SetArenaReMainTime()
	end

	self.cur_index = index
end

function KFArenaActivityView:GetExchangeContentView()
	return self.exchange_content_view
end

function KFArenaActivityView:ShowXianShi()
	if self.tabbar and ExchangeData and ExchangeData.Instance then
		local tab_button = self.tabbar:GetTabButton(TabIndex.exchange_hunjing)
		if tab_button then
			local is_guanghui_has_xianshi = ExchangeData.Instance:IsHasXianShi(11, 20)
			tab_button:ShowXianShiDuiHuan(is_guanghui_has_xianshi)
		end
	end	
end

function KFArenaActivityView:ChangeUnderBG(index)
	if index == TabIndex.kf_arena_view then
		local bundle, asset = ResPath.GetRawImage("bg_kfarena_lunjian",true)
		local fun = function()
			self.node_list["UnderBg"]:SetActive(true)
		end
		self.node_list["UnderBg"].raw_image:LoadSprite(bundle, asset, fun)
	elseif index == TabIndex.exchange_hunjing then
		self.node_list["UnderBg"]:SetActive(false)
	elseif index == TabIndex.kf_arena_rank_view then
		self.node_list["UnderBg"]:SetActive(false)
		local bundle, asset = ResPath.GetRawImage("Arena_rank_bg",true)
		local fun = function()
			self.node_list["UnderBg"]:SetActive(true)
		end
		self.node_list["UnderBg"].raw_image:LoadSprite(bundle, asset, fun)
	end
end

function KFArenaActivityView:HandleClose()
	ViewManager.Instance:Close(ViewName.KFArenaActivityView)
end

function KFArenaActivityView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "kfarena" and self.cur_index == TabIndex.kf_arena_view then
			if self.kf_arena_view then
				-- self.kf_arena_view:Flush()
				self.kf_arena_view:FlushKFArenaView()
			end
		elseif k == "kfarena_rank" and self.cur_index == TabIndex.kf_arena_rank_view then
			if self.kf_arena_rank_view then
				self.kf_arena_rank_view:Flush()
			end
		end
	end

	self.node_list["TextNum"].text.text = self:FormatMoney(ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.HUNJING))
end

function KFArenaActivityView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.Tab then
		local index = TabIndex[ui_param]
		if index == self.show_index then
			return NextGuideStepFlag
		end
		return self.tabbar:GetTabButton(index), BindTool.Bind(self.ChangeToIndex, self, index)
	elseif self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end

function KFArenaActivityView:FormatMoney(value)
	return CommonDataManager.ConverMoney(value)
end