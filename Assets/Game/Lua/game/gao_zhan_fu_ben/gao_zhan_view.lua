GaoZhanView = GaoZhanView or BaseClass(BaseView)

function GaoZhanView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/fubenview_prefab", "WeaponContent", {TabIndex.fb_weapon}},		-- 武器材料
		{"uis/views/fubenview_prefab", "QualityFBContent", {TabIndex.fb_quality}},	-- 品质
		{"uis/views/fubenview_prefab", "GuardContent", {TabIndex.fb_guard}},		-- 守护
		{"uis/views/fubenview_prefab", "TowerFBContent", {TabIndex.fb_tower}},		-- 爬塔
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
		{"uis/views/fubenview_prefab", "ArmorContent", {TabIndex.fb_armor}},		-- 防具材料
	}

	self.full_screen = true
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.def_index = TabIndex.fb_weapon

	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.FlushTabbar, self))

end

function GaoZhanView:__delete()
	if self.open_trigger_handle then
		GlobalEventSystem:UnBind(self.open_trigger_handle)
	end
end

function GaoZhanView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	if self.weapon_view then
		self.weapon_view:DeleteMe()
		self.weapon_view = nil
	end

	if self.armor_view then
		self.armor_view:DeleteMe()
		self.armor_view = nil
	end

	if self.quality_view then
		self.quality_view:DeleteMe()
		self.quality_view = nil
	end

	if self.tower_view then
		self.tower_view:DeleteMe()
		self.tower_view = nil
	end
	if self.guard_view then
		self.guard_view:DeleteMe()
		self.guard_view = nil
	end

	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.GaoZhanFuBen)
	end
end

function GaoZhanView:LoadCallBack()
	local tab_cfg = {
		{name = Language.FuBen.TabbarName[5],  bundle = "uis/images_atlas", asset = "tab_icon_weapon", func = "fb_weapon", tab_index = TabIndex.fb_weapon, remind_id = RemindName.FuBen_Weapon, func = "fb_weapon"},
		{name = Language.FuBen.TabbarName[6],  bundle = "uis/images_atlas", asset = "tab_icon_armor", func = "fb_armor", tab_index = TabIndex.fb_armor, remind_id = RemindName.FuBen_Armor, func = "fb_armor"},
		{name = Language.FuBen.TabbarName[3],  bundle = "uis/images_atlas", asset = "tab_icon_huanjing", func = "fb_quality", tab_index = TabIndex.fb_quality, remind_id = RemindName.FuBen_HuanJing, func = "fb_quality"},
		{name = Language.FuBen.TabbarName[4],  bundle = "uis/images_atlas", asset = "tab_icon_shouhu", func = "fb_guard", tab_index = TabIndex.fb_guard, remind_id = RemindName.FuBen_ShouHu},
		{name = Language.FuBen.TabbarName[9],  bundle = "uis/images_atlas", asset = "tab_icon_fb_tower", func = "fb_tower", tab_index = TabIndex.fb_tower, remind_id = RemindName.FuBen_ShiLian, func = "fb_tower"},
	}

	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.OpenIndexCheck, self))

	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.OnClickAddGold, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["TxtTitle"].text.text = Language.GaoZhanFuBen.Title
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.GaoZhanFuBen, BindTool.Bind(self.GetUiCallBack, self))
	self:SetBg()
end

function GaoZhanView:SetBg(index)
	local call_back = function ()
		self.node_list["UnderBg"]:SetActive(true)
		self.node_list["TaiZi"]:SetActive(false)
	end
	if index == TabIndex.fb_armor then
		self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/armor_fuben_bg", "armor_fuben_bg.jpg", call_back)
	elseif index == TabIndex.fb_tower then
		self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/bg_common1_under", "bg_common1_under.jpg", call_back)
	else
		self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/zhuanzhi_bg_1", "zhuanzhi_bg_1.jpg", call_back)
	end
end

function GaoZhanView:OpenCallBack()
	RemindManager.Instance:SetImmdiateRemind(RemindName.GaoZhanFuBen)
	-- 监听系统事件
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	self:Flush()
	FuBenCtrl.Instance:SendArmorDefendRoleReq(ARMOR_DEFEND_REQTYPE.ARMOR_DEFEND_ROLE_INFO_REQ)
	FuBenCtrl.Instance:SendNeqInfoReq()
end

function GaoZhanView:CloseCallBack()
	RemindManager.Instance:Fire(RemindName.GaoZhanFuBen)
	MainUICtrl.Instance:FlushView("show_market")
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	if self.tower_view then
		self.tower_view:CloseCallBack()
	end

	if self.weapon_view then
		self.weapon_view:CloseCallBack()
	end
end

-- 元宝
function GaoZhanView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(vo.gold)
	end

	if attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(vo.bind_gold)
	end
end

function GaoZhanView:OnClickAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function GaoZhanView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)
	if nil ~= index_nodes then
		if index == TabIndex.fb_weapon then
			self.weapon_view = WeaponMaterialsContent.New(index_nodes["WeaponContent"])		--武器
			RemindManager.Instance:Fire(RemindName.FuBen_Weapon)
		elseif index == TabIndex.fb_armor then
			self.armor_view = FuBenArmorView.New(index_nodes["ArmorContent"])				--防具材料
			RemindManager.Instance:Fire(RemindName.FuBen_Armor)
		elseif index == TabIndex.fb_quality then
			self.quality_view = FuBenQualityView.New(index_nodes["QualityFBContent"])		--幻境
			RemindManager.Instance:Fire(RemindName.FuBen_HuanJing)
		elseif index == TabIndex.fb_guard then
			self.guard_view = FuBenGuardView.New(index_nodes["GuardContent"])				--守护
			RemindManager.Instance:Fire(RemindName.FuBen_ShouHu)
		elseif index == TabIndex.fb_tower then
			self.tower_view = FuBenTowerView.New(index_nodes["TowerFBContent"])				--试炼/爬塔
			RemindManager.Instance:Fire(RemindName.FuBen_ShiLian)
		end
	end

	if index == TabIndex.fb_weapon then
		self.weapon_view:DoPanelTweenPlay()
		self.weapon_view:SetReMainTime()
		self.weapon_view:Flush()
	elseif index == TabIndex.fb_armor then
		self.armor_view:DoPanelTweenPlay()
		self.armor_view:Flush()
	elseif index == TabIndex.fb_quality and self.quality_view then
		ClickOnceRemindList[RemindName.FuBen_HuanJing] = 0
		RemindManager.Instance:CreateIntervalRemindTimer(RemindName.FuBen_HuanJing)
		self.quality_view:DoPanelTweenPlay()
		self.quality_view:Flush()
	elseif index == TabIndex.fb_guard and self.guard_view then
		self.guard_view:DoPanelTweenPlay()
		self.guard_view:SetCurPage()
		self.guard_view:Flush()
	elseif index == TabIndex.fb_tower and self.tower_view then 
		self.tower_view:UITween()
		self.tower_view:Flush()
		ClickOnceRemindList[RemindName.FuBen_ShiLian] = 0
		RemindManager.Instance:CreateIntervalRemindTimer(RemindName.FuBen_ShiLian)
	end

	self:SetBg(index)
end

function GaoZhanView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "tower" then
			if self.tower_view then
				self.tower_view:Flush()
			end
		elseif k == "quality" then
			if self.quality_view then
				self.quality_view:FlushInfo()
			end
		elseif k == "armor" or k == "times" then
			if self.armor_view then
				self.armor_view:Flush(k)
			end
		elseif k == "tower_defend" then
			if self.guard_view then
				self.guard_view:OnFlush()
			end
		elseif k == "weapon" then
			if self.weapon_view then
				self.weapon_view:Flush(k)
			end
		elseif k == "wptimes" or k == "wpreward" then
			if self.weapon_view then
				self.weapon_view:FlushInfo(k)
			end
		end
	end
end

function GaoZhanView:FlushTabbar()	
	if not self:IsOpen() then return end

	self.tabbar:FlushTabbar()
end

function GaoZhanView:OpenIndexCheck(to_index)
	self:ChangeToIndex(to_index)
end

function GaoZhanView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.Tab then
		local index = TabIndex[ui_param]
		if index and self.tabbar:GetTabButton(index) then
			local root_node = self.tabbar:GetTabButton(index).root_node
				local callback = BindTool.Bind(self.ChangeToIndex, self, index)
			if index == self.show_index then
				return NextGuideStepFlag
			else
				return root_node, callback
			end
		end
		return NextGuideStepFlag
	elseif ui_name == GuideUIName.QualityFbBtn then
		if self.quality_view then
			return self.quality_view:GetBtnCanChallenge()
		end
	elseif ui_name == GuideUIName.QhallengeFbBtn then
		if self.guard_view then
			return self.guard_view:Challenge()
		end
	elseif ui_name == GuideUIName.WeaponChallenge then
		if self.weapon_view then
			return self.weapon_view:GetChallenge()
		end
	elseif ui_name == GuideUIName.ButtonChallenge then
		if self.armor_view then
			return self.armor_view:GetGuideChallenge()
		end
	elseif self.node_list[ui_name] then
		if self.node_list[ui_name].gameObject.activeInHierarchy then
			return self.node_list[ui_name]
		end
	end
end