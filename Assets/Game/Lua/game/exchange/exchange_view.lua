require("game/exchange/exchange_content_view")
ExchangeView = ExchangeView or BaseClass(BaseView)

SHOW_EXCHANGE_TAB =
{
	[TabIndex.exchange_shengwang] = 2, 		--RONG_YU
	[TabIndex.exchange_rongyao] = 8,		--RONG_YAO
	[TabIndex.exchange_guanghui] = 9, 		--GUANGHUI
	[TabIndex.exchange_yihuo] = 15, 		--YIHUO
	[TabIndex.exchange_yushi] = 19, 		--YUSHI
	[TabIndex.exchange_jingling] = 6, 		--仙宠
	[TabIndex.exchange_hunjing] = 20,		--魂晶
	[TabIndex.exchange_guildcontribute] = 21,		--仙盟贡献
	[TabIndex.exchange_weiji] = 22,			--仙盟微计
}

icon_img_path = {
	[TabIndex.exchange_shengwang] = "RongYu",
	[TabIndex.exchange_rongyao] = "RongYao",
	[TabIndex.exchange_guanghui] = "GuangHui",
	[TabIndex.exchange_yihuo] = "YiHuo",
	[TabIndex.exchange_yushi] = "YuShi",
	[TabIndex.exchange_jingling] = "LingChong",
	[TabIndex.exchange_hunjing] = "HunJing",
	[TabIndex.exchange_guildcontribute] = "Guild",
	[TabIndex.exchange_weiji] = "WeiJi1",
}

icon_id = {
	[TabIndex.exchange_shengwang] = 90003,
	[TabIndex.exchange_rongyao] = 90004,
	[TabIndex.exchange_yihuo] = 90021,
	[TabIndex.exchange_yushi] = 90574,
	[TabIndex.exchange_jingling] = 90000,
	[TabIndex.exchange_hunjing] = 90797,
	[TabIndex.exchange_guildcontribute] = 90009,
	[TabIndex.exchange_weiji] = 26617,
}

function ExchangeView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_1"},
		{"uis/views/exchangeview_prefab", "NewExchangeContent"},
		{"uis/views/exchangeview_prefab", "Content",{TabIndex.exchange_shengwang, TabIndex.exchange_rongyao, TabIndex.exchange_yihuo, TabIndex.exchange_yushi, TabIndex.exchange_jingling, TabIndex.exchange_hunjing, TabIndex.exchange_guildcontribute, TabIndex.exchange_weiji,}},--TabIndex.exchange_yushi , TabIndex.exchange_yihuo
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_3"},
	}
	self.full_screen = false
	self.play_audio = true
	self.is_first = true
	self.click_shengwang = false
	self.click_rongyao = false
	
	self.is_modal = true
	self.def_index = TabIndex.exchange_shengwang
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function ExchangeView:__delete()

end

function ExchangeView:ReleaseCallBack()
	if self.exchange_content_view ~= nil then
		self.exchange_content_view:DeleteMe()
		self.exchange_content_view = nil
	end
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.Exchange)
	end

	if self.tabbar then 
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	self.cur_index = nil

	-- 清理变量和对象
	self.show_block = nil
	self.title_name = nil
	self.show_add_money = nil
	self.toggle_list = nil
end

function ExchangeView:LoadCallBack()
    self.cur_index = TabIndex.exchange_shengwang
	self.node_list["TitleText"].text.text = Language.Title.DuiHuan
	local tab_cfg = {
		{name =	Language.Exchange.TabbarName.ShengWang, tab_index = TabIndex.exchange_shengwang, func = "shengwang"},
		{name = Language.Exchange.TabbarName.WuXun, tab_index = TabIndex.exchange_rongyao, func = "raoyao"},
		-- {name = Language.Exchange.TabbarName.YiHuo, tab_index = TabIndex.exchange_yihuo, func = "exchange_yihuo"},
		-- {name = Language.Exchange.TabbarName.YuShi, tab_index = TabIndex.exchange_yushi, func = "exchange_yushi"},
		{name = Language.Exchange.TabbarName.XianChong, tab_index = TabIndex.exchange_jingling, func = "exchange_jingling"},
		-- {name = Language.Exchange.TabbarName.HunJing, tab_index = TabIndex.exchange_hunjing, func = "exchange_hunjing"},
		{name = Language.Exchange.TabbarName.Guild, tab_index = TabIndex.exchange_guildcontribute, func = "guild_contribute"},
		{name = Language.Exchange.TabbarName.WeiJi, tab_index = TabIndex.exchange_weiji, func = "exchange_huiji"},
	}

	self.tabbar = TabBarTwo.New()
	self.tabbar:Init(self, self.node_list["TabPanel"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))


	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.OnCloseBtnClick, self))
	self.node_list["BtnAdd"].button:AddClickListener(BindTool.Bind(self.AddMoneyClick, self))
	self.node_list["ImgIcon"].button:AddClickListener(BindTool.Bind(self.OnClickMoney, self))

	local value = ExchangeData.Instance:GetScoreList()[2] or 0
	self.node_list["TextNum"].text.text = self:FormatMoney(value)

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Exchange, BindTool.Bind(self.GetUiCallBack, self))
end

function ExchangeView:GetExchangeContentView()
	return self.exchange_content_view
end

function ExchangeView:FormatMoney(value)
	return CommonDataManager.ConverMoney(value)
end

function ExchangeView:InitTabXianShi()
	-- self:DisAbleTabXianShi()
	local is_activity_open = ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RARE_CHANGE)
	if not is_activity_open then
		return
	end
	local prof = PlayerData.Instance:GetRoleBaseProf()
	for k, v in ipairs(SHOW_EXCHANGE_TAB) do
		local name = "ImgRemind_" .. k
		if self[name] then
			local itemid_list = ExchangeData.Instance:GetItemIdListByJobAndType(2, v, prof)
			for _, v2 in ipairs(itemid_list) do
				if v2[2] == 1 then
					self.node_list[name]:SetActive(true)
					break
				end
			end
		end
	end
end

function ExchangeView:SetRedPoint()
	local state = SettingData.Instance:GetRedPointState()
	local button = self.tabbar:GetTabButton(TabIndex.setting_notice)
	button:ShowRemind(state)
end

function ExchangeView:DisAbleTabXianShi()
	self.node_list["ImgRemind_1"]:SetActive(false)
	self.node_list["ImgRemind_2"]:SetActive(false)
	self.node_list["ImgRemind_3"]:SetActive(false)
	self.node_list["ImgRemind_4"]:SetActive(false)
	self.node_list["ImgRemind_5"]:SetActive(false)
end

function ExchangeView:ShowXianShi()
	if self.tabbar and ExchangeData and ExchangeData.Instance then
		local tab_button = self.tabbar:GetTabButton(TabIndex.exchange_shengwang)
		if tab_button then
			local is_shengwang_has_xianshi = ExchangeData.Instance:IsHasXianShi(2, 2)
			tab_button:ShowXianShiDuiHuan(is_shengwang_has_xianshi)
		end	
		local tab_button = self.tabbar:GetTabButton(TabIndex.exchange_rongyao)
		if tab_button then
			local is_rongyao_has_xianshi = ExchangeData.Instance:IsHasXianShi(2, 8)
			tab_button:ShowXianShiDuiHuan(is_rongyao_has_xianshi)
		end
	end		
end

function ExchangeView:OpenCallBack()
	if self.exchange_content_view then
		self.exchange_content_view:SetIsOpen(true)
	end
	self:InitTabXianShi()

	self.activity_change_call_back = BindTool.Bind1(self.ActivityChangeCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_change_call_back)

	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if cur_day > -1 then
		PlayerPrefsUtil.SetInt("exchange_remind_day", cur_day)
		RemindManager.Instance:Fire(RemindName.Echange)
	end
	local bundle, asset = ResPath.GetExchangeNewIcon(icon_img_path[self.cur_index])
	if self.cur_index == TabIndex.exchange_weiji then
		local vo = GameVoManager.Instance:GetMainRoleVo()
		if vo.sex == 0 then
			bundle, asset = ResPath.GetExchangeNewIcon("WeiJi0")
		end
	end
	self.node_list["ImgIcon"].image:LoadSprite(bundle, asset .. ".png")
	self.node_list["ImgIcon"].image:SetNativeSize()
	self:Flush("flush_list_view")

	self:ShowXianShi()
	MainUICtrl.Instance:GetView():ShowXianShiDuiHuan()	
end

function ExchangeView:OnClickMoney()
	local data = {item_id = icon_id[self.cur_index]}
	if self.cur_index == TabIndex.exchange_weiji then
		local vo = GameVoManager.Instance:GetMainRoleVo()
		if vo.sex == 0 then
			data = {item_id = 26618}
		end
	end
	TipsCtrl.Instance:OpenItem(data)
end

function ExchangeView:CloseCallBack()
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if cur_day > -1 and self.click_rongyao == true then
		PlayerPrefsUtil.SetInt("IsHasXianShi28", cur_day)
	end
	if cur_day > -1 and self.click_shengwang == true then
		PlayerPrefsUtil.SetInt("IsHasXianShi22", cur_day)
	end			
	self:ShowXianShi()
	MainUICtrl.Instance:GetView():ShowXianShiDuiHuan()	
	if self.exchange_content_view then
		self.exchange_content_view:SetIsOpen(false)
	end

	ActivityData.Instance:UnNotifyActChangeCallback(self.activity_change_call_back)
	self.activity_change_call_back = nil
end

function ExchangeView:ShowIndexCallBack(index, index_nodes)

	self.tabbar:ChangeToIndex(index)

	if nil ~= index_nodes then
		if index == TabIndex.exchange_shengwang 
		or index == TabIndex.exchange_rongyao or index == TabIndex.exchange_yushi or index == TabIndex.exchange_yihuo 
		or index == TabIndex.exchange_guanghui or index == TabIndex.exchange_jingling or index == TabIndex.exchange_hunjing		--or index == TabIndex.exchange_yushi 		or index == TabIndex.exchange_yihuo
		or index == TabIndex.exchange_guildcontribute or index == TabIndex.exchange_weiji then		--or index == TabIndex.exchange_yushi 		or index == TabIndex.exchange_yihuo
			self.exchange_content_view = ExchangeContentView.New(index_nodes["Content"])
		end
	end


	if index == TabIndex.exchange_shengwang then
		self:ChangeContent(TabIndex.exchange_shengwang)
		self.click_shengwang = true
	elseif index == TabIndex.exchange_rongyao then
		self:ChangeContent(TabIndex.exchange_rongyao)
		self.click_rongyao = true	
	elseif index == TabIndex.exchange_yihuo then
		self:ChangeContent(TabIndex.exchange_yihuo)
	elseif index == TabIndex.exchange_yushi then
		self:ChangeContent(TabIndex.exchange_yushi)
	elseif index == TabIndex.exchange_jingling then
		self:ChangeContent(TabIndex.exchange_jingling)
	elseif index == TabIndex.exchange_hunjing then
		self:ChangeContent(TabIndex.exchange_hunjing)
	elseif index == TabIndex.exchange_guildcontribute then
		self:ChangeContent(TabIndex.exchange_guildcontribute)
	elseif index == TabIndex.exchange_weiji then
		self:ChangeContent(TabIndex.exchange_weiji)
	end

	if self.exchange_content_view then
		self.exchange_content_view:SetCurrentPriceType(SHOW_EXCHANGE_TAB[index])
		self.exchange_content_view:OnFlushListView()
		self.exchange_content_view:FlushCoin()
	end
end

function ExchangeView:OnCloseBtnClick()
	ViewManager.Instance:Close(ViewName.Exchange)
end

function ExchangeView:AddMoneyClick()

	if self.cur_index == TabIndex.exchange_shengwang then
		ViewManager.Instance:Open(ViewName.Activity, TabIndex.activity_battle)
	elseif self.cur_index == TabIndex.exchange_rongyao then
		ViewManager.Instance:Open(ViewName.Activity, TabIndex.activity_kuafu_battle)
	elseif self.cur_index == TabIndex.exchange_yihuo then
		ViewManager.Instance:Open(ViewName.HunQiView, TabIndex.hunqi_bao)
	elseif self.cur_index == TabIndex.exchange_yushi then
		ViewManager.Instance:Open(ViewName.Forge,TabIndex.forge_jade)
	elseif self.cur_index == TabIndex.exchange_jingling then
		ViewManager.Instance:Open(ViewName.SpiritView, TabIndex.spirit_hunt)
	elseif self.cur_index == TabIndex.exchange_hunjing then
		ViewManager.Instance:Open(ViewName.KFArenaActivityView, TabIndex.kf_arena_view)
	elseif self.cur_index == TabIndex.exchange_guildcontribute then
		local vo = GameVoManager.Instance:GetMainRoleVo()
		if(vo.guild_id <= 0) then
			ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_request)
		else
			ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_box)
		end
		self:Close()
	elseif self.cur_index == TabIndex.exchange_weiji then
		ViewManager.Instance:Open(ViewName.FuBen, TabIndex.fb_team_tower)
	end

end

function ExchangeView:ChangeContent(tab_index)
	local bundle, asset = ResPath.GetExchangeNewIcon(icon_img_path[tab_index])
	if tab_index == TabIndex.exchange_weiji then
		local vo = GameVoManager.Instance:GetMainRoleVo()
		if vo.sex == 0 then
			bundle, asset = ResPath.GetExchangeNewIcon("WeiJi0")
		end
	end
	if self.exchange_content_view then
		self.exchange_content_view:SetCurrentPriceType(SHOW_EXCHANGE_TAB[tab_index])
		self.exchange_content_view:OnFlushListView()
		self.exchange_content_view:FlushCoin()
	end
	self.node_list["ImgIcon"].image:LoadSprite(bundle, asset .. ".png")
	local score_type = 0
	if tab_index == TabIndex.exchange_shengwang then
		score_type = EXCHANGE_PRICE_TYPE.SHENGWANG
	elseif tab_index == TabIndex.exchange_rongyao then
		score_type = EXCHANGE_PRICE_TYPE.RONGYAO
	elseif tab_index == TabIndex.exchange_yihuo then
		score_type = EXCHANGE_PRICE_TYPE.SHENZHOU
	elseif tab_index == TabIndex.exchange_yushi then
		score_type = EXCHANGE_PRICE_TYPE.YUSHI
	elseif tab_index == TabIndex.exchange_jingling then
		score_type = EXCHANGE_PRICE_TYPE.JINGLING
	elseif tab_index == TabIndex.exchange_hunjing then
		score_type = EXCHANGE_PRICE_TYPE.HUNJING
	elseif tab_index == TabIndex.exchange_guildcontribute then
		score_type = EXCHANGE_PRICE_TYPE.GUILDCONTRIBUTE
	elseif tab_index == TabIndex.exchange_weiji then
		score_type = EXCHANGE_PRICE_TYPE.WEIJI
	end

	self.node_list["BtnAdd"]:SetActive(score_type ~= EXCHANGE_PRICE_TYPE.YUSHI)
	self.node_list["TextNum"].text.text = self:FormatMoney(ExchangeData.Instance:GetCurrentScore(score_type))
	self.cur_index = tab_index
	self:ShowsSpecialBG()
end

function ExchangeView:OnFlush(param_t)

		local score_type = 0
		if self.cur_index == TabIndex.exchange_shengwang then
			score_type = EXCHANGE_PRICE_TYPE.SHENGWANG
		elseif self.cur_index == TabIndex.exchange_rongyao then
			score_type = EXCHANGE_PRICE_TYPE.RONGYAO
		elseif self.cur_index == TabIndex.exchange_yihuo then
			score_type = EXCHANGE_PRICE_TYPE.SHENZHOU
		elseif self.cur_index == TabIndex.exchange_yushi then
			score_type = EXCHANGE_PRICE_TYPE.YUSHI
		elseif self.cur_index == TabIndex.exchange_jingling then
			score_type = EXCHANGE_PRICE_TYPE.JINGLING
		elseif self.cur_index == TabIndex.exchange_hunjing then
			score_type = EXCHANGE_PRICE_TYPE.HUNJING
		elseif self.cur_index == TabIndex.exchange_guildcontribute then
			score_type = EXCHANGE_PRICE_TYPE.GUILDCONTRIBUTE
		elseif self.cur_index == TabIndex.exchange_weiji then
			score_type = EXCHANGE_PRICE_TYPE.WEIJI
		end

		self.node_list["TextNum"].text.text = self:FormatMoney(ExchangeData.Instance:GetCurrentScore(score_type))
		self:ShowsSpecialBG()
end

function ExchangeView:ShowsSpecialBG()
	local is_show = ExchangeData.Instance:GetIsShowSpecialBg()
	self.node_list["BG"]:SetActive(is_show)
end

function ExchangeView:OnChangeToggle(index)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if index == TabIndex.exchange_mojing then
		self.node_list["toggle_content_1"].toggle.isOn = true
	end
end

function ExchangeView:SelectFirstItem()
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	for k, v in pairs(self.cell_list) do
		local index = v:GetIndex()
		if index == 1 then
			local first_cell = v:GetFirstCell()
			if first_cell then
				first_cell:SelectToggle()
			end
		end
	end
end

function ExchangeView:ActivityChangeCallBack(activity_type, status, next_time, open_type)
	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RARE_CHANGE and status == ACTIVITY_STATUS.CLOSE then
		self:DisAbleTabXianShi()
		if self.exchange_content_view then
			self.exchange_content_view:OnFlushListView()
		end
	end
end

function ExchangeView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.Tab then
		local index = TabIndex[ui_param]
		if index == TabIndex.exchange_mojing then
			local toggle_mojing = self.node_list["toggle_content_1"]
			if toggle_mojing.gameObject.activeInHierarchy then
				if toggle_mojing.toggle.isOn then
					return NextGuideStepFlag
				else
					local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.exchange_mojing)
					return toggle_mojing, callback
				end
			end
		end
	elseif ui_name == GuideUIName.ExchangeMoJingFirstItem then
		if self.cell_list and next(self.cell_list) then
			for k, v in pairs(self.cell_list) do
				local index = v:GetIndex()
				if index == 1 then
					local first_cell = v:GetFirstCell()
					if first_cell then
						local callback = BindTool.Bind(self.SelectFirstItem, self)
						return first_cell.root_node, callback
					end
				end
			end
		end
	end
end