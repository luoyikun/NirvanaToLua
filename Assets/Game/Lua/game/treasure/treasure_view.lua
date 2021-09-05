require("game/treasure/treasure_content_view")
require("game/treasure/treasure_exchange_view")
require("game/treasure/treasure_warehouse_view")
TreasureView = TreasureView or BaseClass(BaseView)

function TreasureView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		--{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/treasureview_prefab", "TreasureContent", {TabIndex.treasure_choujiang}},
		{"uis/views/treasureview_prefab", "TreasureContent", {TabIndex.treasure_choujiang2}},
		{"uis/views/treasureview_prefab", "TreasureContent", {TabIndex.treasure_choujiang3}},
		{"uis/views/treasureview_prefab", "ExchangeContent", {TabIndex.treasure_exchange}},
		{"uis/views/treasureview_prefab", "WareContent", {TabIndex.treasure_warehouse}},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_XunBao"},
	}

	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].OpenTreasure)
	end
	self.play_audio = true
	self.full_screen = true
	self.is_bindgold_click = false
	self.money_change_callback = BindTool.Bind(self.PlayerDataChangeCallback, self)
end

function TreasureView:LoadCallBack()
	local language = Language.Treasure
	local tab_cfg = {
		{name = language.TabbarName[1], bundle = "uis/images_atlas", asset = "truesure_xunbao", func = "treasure",  tab_index = TabIndex.treasure_choujiang, remind_id = RemindName.XunBaoTreasure,},
		{name = language.TabbarName[2], bundle = "uis/images_atlas", asset = "truesure_duihuan", func = "treasure",  tab_index = TabIndex.treasure_exchange,},
		{name = language.TabbarName[3], bundle = "uis/images_atlas", asset = "truesure_cangku", func = "warehouse", tab_index = TabIndex.treasure_warehouse, remind_id = RemindName.XunBaoWarehouse,},
	}
	local sub_tab_cfg = {
		{
			{name = language.SubTabbarName[1], tab_index = TabIndex.treasure_choujiang, remind_id = RemindName.XunBaoTreasure1, func = "jp_treasure",},
			{name = language.SubTabbarName[2], tab_index = TabIndex.treasure_choujiang2, remind_id = RemindName.XunBaoTreasure2, func = "df_treasure",},
			{name = language.SubTabbarName[3], tab_index = TabIndex.treasure_choujiang3, remind_id = RemindName.XunBaoTreasure3, func = "zz_treasure",},
		},
		nil,
		nil,
	}
	self.view_list = {}

	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:InitSubTab(self.node_list["TopTabContent"], sub_tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))

	ExchangeCtrl.Instance:SendGetConvertRecordInfo()
	ExchangeCtrl.Instance:SendGetSocreInfoReq()
	TreasureCtrl.Instance:SendChestShopItemListReq(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP)

	local bundle, asset = ResPath.GetExchangeNewIcon("XunBao")
	self.node_list["ImgBindGold"].image:LoadSprite(bundle, asset .. ".png", function() 
			self.node_list["ImgBindGold"].image:SetNativeSize() 
		end)
	self.node_list["ImgBindGold"].button:AddClickListener(function ()
		TipsCtrl.Instance:OpenItem({item_id = ResPath.CurrencyToIconId["score"]})
	end)

	self.node_list["TxtTitle"].text.text = language.TitleTxt
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.HandleAddGold, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnCloseBtnClick, self))
	self.node_list["TaiZi"]:SetActive(false)
	self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/bg_xianchong", "bg_xianchong.jpg", function()
			-- self.node_list["UnderBg"].raw_image.color = Color(1, 1, 1, 0.44)
			self.node_list["UnderBg"]:SetActive(true)
		end)

	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	PlayerData.Instance:ListenerAttrChange(self.money_change_callback)
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Treasure, BindTool.Bind(self.GetUiCallBack, self))
	ExchangeCtrl.Instance:SendGetSocreInfoReq()

end

function TreasureView:OpenCallBack()

	RollingBarrageCtrl.Instance:SendChestShopRecordListReq(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP1)
	RollingBarrageCtrl.Instance:SendChestShopRecordListReq(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP2)
	self:Flush()
end

function TreasureView:ReleaseCallBack()
	for k,v in pairs(self.view_list) do
		v:DeleteMe()
	end
	self.view_list = {}

	if PlayerData.Instance then
		PlayerData.Instance:UnlistenerAttrChange(self.money_change_callback)
	end
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.Treasure)
	end
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
	self.toggle_list = nil
	self.get_all_btn = nil
	self.one_times_btn = nil
end

function TreasureView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function TreasureView:GetTreasureExchange()
	return self.view_list[TabIndex.treasure_exchange]
end

function TreasureView:GetTreasureWareView()
	return self.view_list[TabIndex.treasure_warehouse]
end

function TreasureView:GetTreasureContentView()
	return self.view_list[TabIndex.treasure_choujiang]
end

function TreasureView:OpenRollingBarrageView()
	if RollingBarrageData.Instance:GetRecordBarrageState(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP) then
		return
	end

	self:CloseRollingBarrageView()
	local cur_index = self:GetShowIndex()
	if cur_index == TabIndex.treasure_choujiang then
		-- 打开弹幕
		RollingBarrageData.Instance:SetNowCheckType(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP)
		ViewManager.Instance:Open(ViewName.RollingBarrageView)
	elseif cur_index == TabIndex.treasure_choujiang2 then
		RollingBarrageData.Instance:SetNowCheckType(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP1)
		ViewManager.Instance:Open(ViewName.RollingBarrageView)
	elseif cur_index == TabIndex.treasure_choujiang3 then
		RollingBarrageData.Instance:SetNowCheckType(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP2)
		ViewManager.Instance:Open(ViewName.RollingBarrageView)
	end
end

function TreasureView:CloseRollingBarrageView()
	if ViewManager.Instance:IsOpen(ViewName.RollingBarrageView) then
		ViewManager.Instance:Close(ViewName.RollingBarrageView)
	end
end

function TreasureView:CloseCallBack()
	self:CloseRollingBarrageView()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function TreasureView:OnFlush(param)
	local show_index = self:GetShowIndex()
	if nil == self.view_list[show_index] then return end

	if index == TabIndex.treasure_choujiang then
		self.view_list[TabIndex.treasure_choujiang]:Flush("treasure1")
	elseif index == TabIndex.treasure_choujiang2 then
		self.view_list[TabIndex.treasure_choujiang]:Flush("treasure2")
	elseif index == TabIndex.treasure_choujiang3 then
		self.view_list[TabIndex.treasure_choujiang]:Flush("treasure3")
	else
		self.view_list[show_index]:Flush()
	end

	local xunbao_index = self:GetXunBaoIndex()
	if xunbao_index == TabIndex.treasure_choujiang then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(TreasureData.Instance:GetTreasureScore())
	elseif xunbao_index == TabIndex.treasure_choujiang2 then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(TreasureData.Instance:GetTreasureScore1())
	elseif xunbao_index == TabIndex.treasure_choujiang3 then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(TreasureData.Instance:GetTreasureScore2())
	elseif xunbao_index == TabIndex.treasure_exchange then
		self.node_list["DianFengText2"].text.text = CommonDataManager.ConverMoney(TreasureData.Instance:GetTreasureScore())
		self.node_list["DianFengText"].text.text = CommonDataManager.ConverMoney(TreasureData.Instance:GetTreasureScore1())
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(TreasureData.Instance:GetTreasureScore2())
	elseif xunbao_index == TabIndex.treasure_warehouse then
		self.node_list["DianFengText"].text.text = CommonDataManager.ConverMoney(TreasureData.Instance:GetTreasureScore1())
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(TreasureData.Instance:GetTreasureScore2())			
		self.node_list["DianFengText2"].text.text = CommonDataManager.ConverMoney(TreasureData.Instance:GetTreasureScore())
	end

	if not self:IsOpen() then return end
	self.tabbar:FlushTabbar()
	--self:CheckRedPoint()
	self:ShowXianShi()
end

-- function TreasureView:CheckRedPoint()
-- 	if self.node_list["ImgRemind3"] then
-- 		self.node_list["ImgRemind3"]:SetActive(TreasureData.Instance:GetRemindWareHouse() > 0)
-- 	end

-- 	if self.node_list["ImgRemind1"] then
-- 		self.node_list["ImgRemind1"]:SetActive(TreasureData.Instance:GetXunBaoRedPoint())
-- 	end
-- end

function TreasureView:OnCloseBtnClick()
	self:Close()
end

function TreasureView:PlayerDataChangeCallback(attr_name, value)
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(value)
	end
end

function TreasureView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then return end
	if ui_name == GuideUIName.Tab then
		local index = TabIndex[ui_param]
		local root_node = self.tabbar:GetTabButton(index).root_node
			local callback = BindTool.Bind(self.ChangeToIndex, self, index)
		if index == self.show_index then
			return NextGuideStepFlag
		else
			return root_node, callback
		end
	elseif ui_name == GuideUIName.OneTimesBtn then
		if self:GetTreasureContentView() then
		 	return self:GetTreasureContentView():GetGuideOneTimesBtn()
		end
	elseif ui_name == GuideUIName.GetAllBtn then
		if self:GetTreasureWareView() then
		 	return self:GetTreasureWareView():GetGuideAllBtn()
		end	
	elseif self.node_list[ui_name] then
		if self.node_list[ui_name].gameObject.activeInHierarchy then
			return self.node_list[ui_name]
		end
	end
end

function TreasureView:SetXunBaoIndex(xunbao_index)
	self.xunbao_index = xunbao_index
end

function TreasureView:GetXunBaoIndex()
	return self.xunbao_index or TabIndex.treasure_choujiang
end

function TreasureView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)

	local score_id = 90006
	local bundle, asset = ResPath.GetItemIcon(score_id)
	local score_id_dianfeng = 90089
	local bundle_dianfeng, asset_dianfeng = ResPath.GetItemIcon(score_id_dianfeng)
	local score_id_dianfeng2 = 90006
	local bundle_dianfeng2, asset_dianfeng2 = ResPath.GetItemIcon(score_id_dianfeng2)

	if index == TabIndex.treasure_choujiang then
		self.view_list[index] = self.view_list[index] or TreasureContentView.New(index_nodes["TreasureContent"])
		self.view_list[index]:Flush("treasure1")
		score_id = 90006
		bundle, asset = ResPath.GetItemIcon(score_id)
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(TreasureData.Instance:GetTreasureScore())
		self:SetXunBaoIndex(TabIndex.treasure_choujiang)
		self.node_list["BindGoldNode"]:SetActive(true)
		self.node_list["DianFengXunBaoLable"]:SetActive(false)
		self.node_list["DianFengXunBaoLable2"]:SetActive(false)
	elseif index == TabIndex.treasure_choujiang2 then
		--local view_index = TabIndex.treasure_choujiang
		self.view_list[index] = self.view_list[index] or TreasureContentView.New(index_nodes["TreasureContent"])
		self.view_list[index]:Flush("treasure2")
		score_id = 90089
		bundle, asset = ResPath.GetItemIcon(score_id)
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(TreasureData.Instance:GetTreasureScore1())
		self:SetXunBaoIndex(TabIndex.treasure_choujiang2)
		self.node_list["BindGoldNode"]:SetActive(true)
		self.node_list["DianFengXunBaoLable"]:SetActive(false)
		self.node_list["DianFengXunBaoLable2"]:SetActive(false)
	elseif index == TabIndex.treasure_choujiang3 then
		--local view_index = TabIndex.treasure_choujiang
		self.view_list[index] = self.view_list[index] or TreasureContentView.New(index_nodes["TreasureContent"])
		self.view_list[index]:Flush("treasure3")
		score_id = 90090
		bundle, asset = ResPath.GetItemIcon(score_id)
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(TreasureData.Instance:GetTreasureScore2())
		self:SetXunBaoIndex(TabIndex.treasure_choujiang3)
		self.node_list["BindGoldNode"]:SetActive(true)
		self.node_list["DianFengXunBaoLable"]:SetActive(false)
		self.node_list["DianFengXunBaoLable2"]:SetActive(false)
	elseif index == TabIndex.treasure_exchange then
		self.view_list[index] = self.view_list[index] or TreasureExchangeView.New(index_nodes["ExchangeContent"])
		self.view_list[index]:Flush()
		score_id_dianfeng = 90089
		bundle, asset = ResPath.GetItemIcon(score_id_dianfeng)
		self.node_list["DianFengText"].text.text = CommonDataManager.ConverMoney(TreasureData.Instance:GetTreasureScore1())
		score_id = 90090
		bundle, asset = ResPath.GetItemIcon(score_id)
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(TreasureData.Instance:GetTreasureScore2())
		self.node_list["DianFengText2"].text.text = CommonDataManager.ConverMoney(TreasureData.Instance:GetTreasureScore())
		self:SetXunBaoIndex(TabIndex.treasure_exchange)
		local fun_is_open1 = OpenFunData.Instance:CheckIsHide("treasure")
		local fun_is_open2 = OpenFunData.Instance:CheckIsHide("df_treasure")
		local fun_is_open3 = OpenFunData.Instance:CheckIsHide("zz_treasure")
		self.node_list["BindGoldNode"]:SetActive(fun_is_open3)
		self.node_list["DianFengXunBaoLable"]:SetActive(fun_is_open2)
		self.node_list["DianFengXunBaoLable2"]:SetActive(fun_is_open1)
	elseif index == TabIndex.treasure_warehouse then
		self.view_list[index] = self.view_list[index] or TreasureWarehouseView.New(index_nodes["WareContent"])
		self.view_list[index]:Flush()
		score_id_dianfeng = 90089
		bundle, asset = ResPath.GetItemIcon(score_id_dianfeng)
		self.node_list["DianFengText"].text.text = CommonDataManager.ConverMoney(TreasureData.Instance:GetTreasureScore1())
		self.node_list["DianFengText2"].text.text = CommonDataManager.ConverMoney(TreasureData.Instance:GetTreasureScore())
		score_id = 90090
		bundle, asset = ResPath.GetItemIcon(score_id)
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(TreasureData.Instance:GetTreasureScore2())
		self:SetXunBaoIndex(TabIndex.treasure_warehouse)
		local fun_is_open1 = OpenFunData.Instance:CheckIsHide("treasure")
		local fun_is_open2 = OpenFunData.Instance:CheckIsHide("df_treasure")
		local fun_is_open3 = OpenFunData.Instance:CheckIsHide("zz_treasure")
		self.node_list["BindGoldNode"]:SetActive(fun_is_open3)
		self.node_list["DianFengXunBaoLable"]:SetActive(fun_is_open2)
		self.node_list["DianFengXunBaoLable2"]:SetActive(fun_is_open1)
	end

	self.node_list["ImgBindGold"].image:LoadSprite(bundle, asset .. ".png", function() 
			self.node_list["ImgBindGold"].image:SetNativeSize()
			self.node_list["ImgBindGold"].transform.localScale = Vector3(0.5, 0.5, 0.5)
		end)
	self.node_list["ImgBindGold"].button:AddClickListener(function ()
		TipsCtrl.Instance:OpenItem({item_id = score_id})
	end)

	self.node_list["DianFengIcon"].image:LoadSprite(bundle_dianfeng, asset_dianfeng .. ".png", function() 
			self.node_list["DianFengIcon"].image:SetNativeSize()
			self.node_list["DianFengIcon"].transform.localScale = Vector3(0.5, 0.5, 0.5)
		end)
	self.node_list["DianFengIcon"].button:AddClickListener(function ()
		TipsCtrl.Instance:OpenItem({item_id = score_id_dianfeng})
	end)

	self.node_list["DianFengIcon2"].image:LoadSprite(bundle_dianfeng2, asset_dianfeng2 .. ".png", function() 
			self.node_list["DianFengIcon2"].image:SetNativeSize()
			self.node_list["DianFengIcon2"].transform.localScale = Vector3(0.5, 0.5, 0.5)
		end)
	self.node_list["DianFengIcon2"].button:AddClickListener(function ()
		TipsCtrl.Instance:OpenItem({item_id = score_id_dianfeng2})
	end)

	if self.view_list[index] then
		self.view_list[index]:OpenCallBack()
	end
	-- 弹幕的屏蔽，不要删了
	-- self:OpenRollingBarrageView()
end

function TreasureView:ShowXianShi()
	if self.tabbar and ExchangeData and ExchangeData.Instance then
		local tab_button = self.tabbar:GetTabButton(TabIndex.treasure_exchange)
		if tab_button then
			if ExchangeData.Instance:GetIsHasNewLimitExchange() then
				local end_act_time = ExchangeData.Instance:GetIsHasNewLimitExchange() - TimeCtrl.Instance:GetServerTime()
				local bundle, asset = ResPath.GetTreasureItemIcon("xianshiduizhuangbei")		
				tab_button:ShowXianShiDuiHuan(end_act_time >  0, bundle, asset)
			end
		end
	end		
end