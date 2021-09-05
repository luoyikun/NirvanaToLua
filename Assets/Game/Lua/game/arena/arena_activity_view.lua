ArenaActivityView = ArenaActivityView or BaseClass(BaseView)

function ArenaActivityView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/arena_prefab", "ArenaView", {TabIndex.arena_view},},
		{"uis/views/arena_prefab", "ArenaRankView",{TabIndex.arena_rank_view},},
		{"uis/views/arena_prefab", "ArenaTupoView",{TabIndex.arena_tupo_view},},
		{"uis/views/arena_prefab", "ExchangeContent",{TabIndex.exchange_guanghui},},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
		{"uis/views/exchangeview_prefab", "ScoreExchangeContent"},
		
	}
	self.def_index = TabIndex.arena_view
	self.full_screen = true								-- 是否是全屏界面
	self.play_audio = true

	self.click_guanghui = false
end

function ArenaActivityView:__delete()
end

function ArenaActivityView:ReleaseCallBack()
	if self.arena_view then
		self.arena_view:DeleteMe()
		self.arena_view = nil
	end

	if self.arena_rank_view then
		self.arena_rank_view:DeleteMe()
		self.arena_rank_view = nil
	end

	if self.arena_tupo_view then
		self.arena_tupo_view:DeleteMe()
		self.arena_tupo_view = nil
	end

	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.ArenaActivityView)
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

function ArenaActivityView:LoadCallBack()
	local tab_cfg = {
		{name = Language.Arena.Among,  bundle = "uis/images_atlas", asset = "icon_tab_lunjian", func = "arena_view", tab_index = TabIndex.arena_view, remind_id = RemindName.ArenaChallange},
		{name = Language.Arena.Rank,  bundle = "uis/images_atlas", asset = "icon_tab_ranking", func = "arena_rank_view", tab_index = TabIndex.arena_rank_view, remind_id = RemindName.ArenaRank},
		{name = Language.Arena.Tupo,  bundle = "uis/images_atlas", asset = "icon_tab_tupo", func = BindTool.Bind(self.IsOpenTuPo, self), tab_index = TabIndex.arena_tupo_view,remind_id = RemindName.ArenaTupo},
		{name = Language.Arena.Exchange,  bundle = "uis/images_atlas", asset = "icon_tab_exchange", func = "zhangong_exchange_view", tab_index = TabIndex.exchange_guanghui, nil},
	}

	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))
	-- self:SetTuPoTabButtonIcon("uis/images_atlas", "lablel_xianshi_icon.png")

	self.node_list["TxtTitle"].text.text = Language.Title.Arena
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.ClickRecharge, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.HandleClose, self))

	self.node_list["UnderBg"]:SetActive(false)
	self.node_list["TaiZi"]:SetActive(false)

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.ArenaActivityView, BindTool.Bind(self.GetUiCallBack, self))
end

function ArenaActivityView:ClickRecharge()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function ArenaActivityView:OpenCallBack()
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

	local bundle, asset = ResPath.GetExchangeNewIcon(icon_img_path[TabIndex.exchange_guanghui])
	self.node_list["ImgIcon"].image:LoadSprite(bundle, asset .. ".png")
	self.node_list["ImgIcon"].image:SetNativeSize()
	self.node_list["BindGoldNode"]:SetActive(false)
	self.node_list["ImgIcon"].button:AddClickListener(function ()
		TipsCtrl.Instance:OpenItem({item_id = ResPath.CurrencyToIconId["hunyu"]})
	end)

	ArenaData.Instance:SetArenaMainuiShow(false)
	self.tabbar:FlushTabbar()
	self:Flush()

	-- RemindManager.Instance:CreateIntervalRemindTimer(RemindName.Arena)
	ExchangeCtrl.Instance:SendGetConvertRecordInfo()

	-- self:ShowXianShi()
	MainUICtrl.Instance:GetView():ShowArenaJueBanYuyi()
end

function ArenaActivityView:CloseCallBack()
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

function ArenaActivityView:PlayerDataChangeCallback(attr_name, value, old_value)
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

function ArenaActivityView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)
	self:ChangeUnderBG(index)
	if nil ~= index_nodes then
		if index == TabIndex.arena_view then
			self.arena_view = ArenaView.New(index_nodes["ArenaView"])
		elseif index == TabIndex.exchange_guanghui then
			self.exchange_content_view = ExchangeContentView.New(index_nodes["ExchangeContent"])
		elseif index == TabIndex.arena_rank_view then
			self.arena_rank_view = ArenaRankView.New(index_nodes["ArenaRankView"])
		elseif index == TabIndex.arena_tupo_view then
			self.arena_tupo_view = ArenaTupoView.New(index_nodes["ArenaTupoView"])
		end
	end

	if index == TabIndex.arena_view then
		self.arena_view:OpenCallBack()
		self.arena_view:DoPanelTweenPlay()
		self.arena_view:Flush()
		-- ClickOnceRemindList[RemindName.ArenaChallange] = 0
		RemindManager.Instance:CreateIntervalRemindTimer(RemindName.ArenaChallange)
		
	elseif index == TabIndex.exchange_guanghui then
	elseif index == TabIndex.arena_rank_view then
		self.arena_rank_view:OpenCallBack()
		self.arena_rank_view:DoPanelTweenPlay()
		self.arena_rank_view:Flush()
	elseif index == TabIndex.arena_tupo_view then
		self.arena_tupo_view:OpenCallBack()
		self.arena_tupo_view:DoPanelTweenPlay()
		self.arena_tupo_view:Flush()
	end

	if self.exchange_content_view then
		self.click_guanghui = true
		self.exchange_content_view:DoPanelTweenPlay()
		self.exchange_content_view:SetCurrentPriceType(SHOW_EXCHANGE_TAB[index])
		self.exchange_content_view:OnFlushListView()
		self.exchange_content_view:FlushCoin()
		self.exchange_content_view:SetArenaReMainTime()
	end

	self.cur_index = index
end

function ArenaActivityView:GetExchangeContentView()
	return self.exchange_content_view
end

function ArenaActivityView:ShowXianShi()
	if self.tabbar and ExchangeData and ExchangeData.Instance then
		local tab_button = self.tabbar:GetTabButton(TabIndex.exchange_guanghui)
		if tab_button then
			local is_guanghui_has_xianshi = ExchangeData.Instance:IsHasXianShi(2, 9)
			tab_button:ShowXianShiDuiHuan(is_guanghui_has_xianshi)
		end
	end	
end

function ArenaActivityView:ChangeUnderBG(index)
	if index == TabIndex.arena_view then
		local bundle, asset = ResPath.GetRawImage("bg_arena_lunjian",false)
		local fun = function()
			self.node_list["UnderBg"]:SetActive(true)
		end
		self.node_list["UnderBg"].raw_image:LoadSprite(bundle, asset, fun)
	elseif index == TabIndex.exchange_guanghui then
		self.node_list["UnderBg"]:SetActive(false)
	elseif index == TabIndex.arena_rank_view then
		self.node_list["UnderBg"]:SetActive(false)
		local bundle, asset = ResPath.GetRawImage("Arena_rank_bg",true)
		local fun = function()
			self.node_list["UnderBg"]:SetActive(true)
		end
		self.node_list["UnderBg"].raw_image:LoadSprite(bundle, asset, fun)
	elseif index == TabIndex.arena_tupo_view then
		self.node_list["UnderBg"]:SetActive(false)
		local bundle, asset = ResPath.GetRawImage("Arena_tupo_bg",true)
		local fun = function()
			self.node_list["UnderBg"]:SetActive(true)
		end
		self.node_list["UnderBg"].raw_image:LoadSprite(bundle, asset, fun)
	end
end

function ArenaActivityView:HandleClose()
	ViewManager.Instance:Close(ViewName.ArenaActivityView)
end

function ArenaActivityView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "arena" and self.cur_index == TabIndex.arena_view then
			if self.arena_view then
				self.arena_view:Flush()
				-- self.arena_view:FlushArenaView()
			end
		elseif k == "arena_rank" and self.cur_index == TabIndex.arena_rank_view then
			if self.arena_rank_view then
				self.arena_rank_view:Flush()
			end
		elseif k == "arena_tupo" and self.cur_index == TabIndex.arena_tupo_view then
			if self.arena_tupo_view then
				self.arena_tupo_view:Flush()
			end
		end
	end

	self.node_list["TextNum"].text.text = self:FormatMoney(ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.GUANGHUI))
end

function ArenaActivityView:GetUiCallBack(ui_name, ui_param)
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

function ArenaActivityView:FormatMoney(value)
	return CommonDataManager.ConverMoney(value)
end


---------------------- 竞技场突破的特殊处理----------------------
-- 是否开启突破，开服第四天关闭
function ArenaActivityView:IsOpenTuPo()
	local visible = true
 -- 	local curr_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
 -- 	local open_day = ArenaData.Instance:GetArenaTupoOpenDay()
	-- if curr_server_day > open_day then
	-- 	visible = false
	-- 	local arena_tupo = RemindManager.Instance:GetRegisterCallback(RemindName.ArenaTupo)
	-- 	if arena_tupo then
	-- 		RemindManager.Instance:UnRegister(RemindName.ArenaTupo)
	-- 	end
 -- 	end
 	return visible
end

-- 设置竞技场突破角标
function ArenaActivityView:SetTuPoTabButtonIcon(bundle, asset)
	local tab_button = self.tabbar:GetTabButton(TabIndex.arena_tupo_view)
	if tab_button then
		tab_button:ShowBiPin(true, bundle, asset, true)
	end
end
---------------------------------------------------------------------
