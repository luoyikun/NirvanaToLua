require("game/boss/world_boss_view")
require("game/boss/kf_boss_view")
require("game/boss/dabao_boss_view")
require("game/boss/miku_boss_view")
require("game/boss/boss_family_view")
require("game/boss/boss_active_view")
require("game/boss/boss_personal_view")
require("game/boss/boss_shanggu_view")
require("game/boss/boss_tujian_view")
-- require("game/boss/secret_boss_view")
require("game/boss/baby_boss_view")
require("game/boss/suit_collect_icon_view")

BossView = BossView or BaseClass(BaseView)

function BossView:__init()

	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/bossview_prefab", "DragPanel"},
		{"uis/views/bossview_prefab", "SuitCollectIcon", {TabIndex.miku_boss, TabIndex.active_boss, TabIndex.vip_boss, TabIndex.personal_boss}},
		{"uis/views/bossview_prefab", "BossPanel", {TabIndex.world_boss}},
		{"uis/views/bossview_prefab", "MikuPanel", {TabIndex.miku_boss}},
		{"uis/views/bossview_prefab", "BabyPanel", {TabIndex.baby_boss}},
		{"uis/views/bossview_prefab", "PersonalPanel", {TabIndex.personal_boss}},
		{"uis/views/bossview_prefab", "ActivePanel", {TabIndex.active_boss}},
		-- {"uis/views/bossview_prefab", "SecretBossPanel", {TabIndex.secret_boss}},
		{"uis/views/bossview_prefab", "FamilyPanel", {TabIndex.vip_boss}},
		{"uis/views/bossview_prefab", "DabaoPanel", {TabIndex.dabao_boss}},
		-- {"uis/views/bossview_prefab", "DropPanel", {TabIndex.drop}},
		-- {"uis/views/bossview_prefab", "SgPanel", {TabIndex.shanggu_boss}},
		{"uis/views/bossview_prefab", "TuJianPanel", {TabIndex.tujian_boss}},
		-- {"uis/views/bossview_prefab", "KfPanel", {TabIndex.kf_boss}},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
		-- {"uis/views/bossview_prefab", "DisPlayPanel"},
		-- {"uis/views/bossview_prefab", "TurntablePanel"},
	}

	self.camera_mode = UICameraMode.UICameraMid

	self.full_screen = true								-- 是否是全屏界面
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].OpenBoss)
	end
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
end

function BossView:ReleaseCallBack()
	if self.world_boss_view then
		self.world_boss_view:DeleteMe()
		self.world_boss_view = nil
	end

	-- if self.kf_boss_view then
	-- 	self.kf_boss_view:DeleteMe()
	-- 	self.kf_boss_view = nil
	-- end

	if self.dabao_boss_view then
		self.dabao_boss_view:DeleteMe()
		self.dabao_boss_view = nil
	end

	if self.boss_family_view then
		self.boss_family_view:DeleteMe()
		self.boss_family_view = nil
	end

	if self.miku_boss_view then
		self.miku_boss_view:DeleteMe()
		self.miku_boss_view = nil
	end

	if self.active_boss_view then
		self.active_boss_view:DeleteMe()
		self.active_boss_view = nil
	end

	-- if self.drop_view then
	-- 	self.drop_view:DeleteMe()
	-- 	self.drop_view = nil
	-- end

	-- if self.shanggu_view then
	-- 	self.shanggu_view:DeleteMe()
	-- 	self.shanggu_view = nil
	-- end

	if self.baby_boss_view then
		self.baby_boss_view:DeleteMe()
		self.baby_boss_view = nil
	end

	if self.personal_boss_view then
		self.personal_boss_view:DeleteMe()
		self.personal_boss_view = nil
	end

	if self.tujian_view then
		self.tujian_view:DeleteMe()
		self.tujian_view = nil
	end

	if self.suit_collect_icon_view then
		self.suit_collect_icon_view:DeleteMe()
		self.suit_collect_icon_view = nil
	end

	-- if self.secret_boss_view then
	-- 	self.secret_boss_view:DeleteMe()
	-- 	self.secret_boss_view = nil
	-- end

	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.Boss)
	end

	if self.turntable_info then
		self.turntable_info:DeleteMe()
	end

	if self.tabbar then 
		self.tabbar:DeleteMe()
	end

	-- if nil ~= self.model_view then
	-- 	self.model_view:DeleteMe()
	-- 	self.model_view = nil
	-- end

	if nil ~= self.tujian_model_view then
		self.tujian_model_view:DeleteMe()
		self.tujian_model_view = nil
	end

	-- 清理变量和对象
	self.fatigue_guide = nil

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

function BossView:LoadCallBack(index, index_nodes)
	self.node_list["TxtTitle"].text.text = Language.Title.BossTiaoZhan
	self.tab_cfg = {
		{name = Language.Boss.TabbarName[3],  bundle = "uis/images_atlas", asset = "tab_huoyue_default", func = "active_boss", tab_index = TabIndex.active_boss, remind_id = RemindName.Boss_Active},
		{name = Language.Boss.TabbarName[2],  bundle = "uis/images_atlas", asset = "tab_jingying_default", func = "miku_boss", tab_index = TabIndex.miku_boss, remind_id = RemindName.Boss_MiKu},
		-- {name = Language.Boss.TabbarName[4],  bundle = "uis/images_atlas", asset = "tab_mizang_default", func = "secret_boss", tab_index = TabIndex.secret_boss, remind_id = RemindName.Boss_Secret},
		{name = Language.Boss.TabbarName[5],  bundle = "uis/images_atlas", asset = "tab_zhuangbei_default", func = "vip_boss", tab_index = TabIndex.vip_boss, remind_id = RemindName.Boss_Family},
		{name = Language.Boss.TabbarName[8],  bundle = "uis/images_atlas", asset = "tab_personal_default", func = "personal_boss", tab_index = TabIndex.personal_boss, remind_id = RemindName.Boss_Personal},
		{name = Language.Boss.TabbarName[1],  bundle = "uis/images_atlas", asset = "tab_world_boss_default", func = "world_boss", tab_index = TabIndex.world_boss, remind_id = RemindName.Boss},
		{name = Language.Boss.TabbarName[6],  bundle = "uis/images_atlas", asset = "tab_taozhuang_default", func = "dabao_boss", tab_index = TabIndex.dabao_boss, remind_id = RemindName.Boss_DaBao},
		{name = Language.Boss.TabbarName[7],  bundle = "uis/images_atlas", asset = "tab_baby_default", func = "baby_boss", tab_index = TabIndex.baby_boss, remind_id = RemindName.Boss_Baby},
		-- {name = Language.Boss.TabbarName[9],  bundle = "uis/images_atlas", asset = "tab_shanggu_default", func = "shanggu_boss", tab_index = TabIndex.shanggu_boss, remind_id = RemindName.Boss_Shanggu},
		-- {name = Language.Boss.TabbarName[10],  bundle = "uis/images_atlas", asset = "tab_kf_default", func = "kf_boss", tab_index = TabIndex.kf_boss, remind_id = RemindName.Boss_Kf},
		{name = Language.Boss.TabbarName[11],  bundle = "uis/images_atlas", asset = "tab_tujian_default", func = "tujian_boss", tab_index = TabIndex.tujian_boss, remind_id = RemindName.Boss_Tujian},
		-- {name = Language.Boss.TabbarName[12],  bundle = "uis/images_atlas", asset = "tab_drop_default", func = "drop", tab_index = TabIndex.drop},
	}

	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], self.tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.HandleClose, self))
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.ClickRecharge, self))
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Boss, BindTool.Bind(self.GetUiCallBack, self))
	
	local event_trigger = self.node_list["ModelDragLayer"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end

	BossCtrl.Instance:LoginCallBack()
end

function BossView:ItemDataChangeCallback(item_id)
	if self:IsOpen() then
		if self.baby_boss_view then
			self.baby_boss_view:FlushTickNum()
		end
		-- if self.shanggu_view then
		-- 	self.shanggu_view:FlushBtnTxt()
		-- end
		if self.dabao_boss_view then
			self.dabao_boss_view:FlushBtnTxt()
		end

		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		if item_cfg and EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type) then
			self:Flush("suit_collect_remind")
		end
	end
end

function BossView:HandleClose()
	self:Close()
end

function BossView:ClickRecharge()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function BossView:OnToggleChange(index, is_click)
	if is_click then
		if self.show_index ~= index then
			self:ChangeToIndex(index)
		end
	end
end

function BossView:Open(index)
	BaseView.Open(self, index)
end

function BossView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if (k == "boss" or k == "boss_list") and self.show_index == TabIndex.world_boss then
			if self.world_boss_view then

				self.world_boss_view:Flush()
			end
		elseif k == "dabao_boss" and self.show_index == TabIndex.dabao_boss then
			if self.dabao_boss_view then
				self.dabao_boss_view:Flush()
			end
		elseif k == "active_boss" and self.show_index == TabIndex.active_boss then
			if self.active_boss_view then
				self.active_boss_view:Flush()
			end
		elseif k == "boss_family" and self.show_index == TabIndex.vip_boss then
			if self.boss_family_view then
				self.boss_family_view:Flush()
			end
		elseif k == "miku_boss" and self.show_index == TabIndex.miku_boss then
			if self.miku_boss_view then
				self.miku_boss_view:Flush()
			end
		elseif k == "baby_boss" and self.show_index == TabIndex.baby_boss then
			if self.baby_boss_view then
				self.baby_boss_view:Flush()
			end
		elseif k == "personal_boss" and self.show_index == TabIndex.personal_boss then
			if self.personal_boss_view then
				self.personal_boss_view:Flush()
			end
		-- elseif k == "shanggu_boss" and self.show_index == TabIndex.shanggu_boss then
		-- 	if self.shanggu_view then
		-- 		self.shanggu_view:Flush()
		-- 	end
		elseif k == "tujian_boss" and self.show_index == TabIndex.tujian_boss then
			if self.tujian_view then
				self.tujian_view:Flush()
			end
		elseif k == "dabao_boss_text" and self.show_index == TabIndex.dabao_boss then
			if self.dabao_boss_view then
				self.dabao_boss_view:FlushBtnTxt()
			end
		elseif k == "active_boss_text" and self.show_index == TabIndex.active_boss then
			if self.active_boss_view then
				self.active_boss_view:FlushTextInfo()
			end
		elseif k == "suit_collect_remind" and self.suit_collect_icon_view then
			self.suit_collect_icon_view:Flush("remind")
		end
	end
end

function BossView:IsShowSuitCollectIconView(index)
	return (index == TabIndex.personal_boss or index == TabIndex.active_boss 
			or index == TabIndex.miku_boss or index == TabIndex.vip_boss)
end

function BossView:ShowIndexCallBack(index, index_nodes)
	if self:IsShowSuitCollectIconView(index) and nil == self.suit_collect_icon_view and index_nodes["SuitCollectIcon"] then
		self.suit_collect_icon_view = SuitCollecIconView.New(index_nodes["SuitCollectIcon"])
	end

	if nil ~= self.suit_collect_icon_view and self:IsShowSuitCollectIconView(index) then
		self.suit_collect_icon_view:Flush("ui_tween")
	end

	self.tabbar:ChangeToIndex(index)

	self.node_list["UnderBg"]:SetActive(false)
	self.node_list["TaiZi"]:SetActive(false)
	self.node_list["BaseFullPanel_1"]:SetActive(index == TabIndex.tujian_boss)
	UIScene:ChangeScene(self, nil)
	local callback = function()
		self.boss_res_id = nil
		local bundle, asset = ResPath.GetRawImage("Bg_Boss",true)
		UIScene:SetBackground(bundle, asset)
		local transform = {position = Vector3(-0.3, 1.84, 9), rotation = Quaternion.Euler(0, 180, 0)}
		UIScene:SetCameraTransform(transform)
	end
	UIScene:ChangeScene(self, callback)

	
	if index == TabIndex.tujian_boss then
		local bundle_bg, asset_bg = ResPath.GetRawImage("bg_boss_tujian",true)
		local fun = function()
			self.node_list["UnderBg"]:SetActive(true)
		end
		self.node_list["UnderBg"].raw_image:LoadSprite(bundle_bg, asset_bg, fun)

		self.tujian_boss_res_id = nil
		local callback = function()
			local bundle, asset = ResPath.GetRawImage("bg_boss_tujian",true)

			UIScene:SetBackground(bundle, asset)
			local transform = {position = Vector3(-0.3, 1.84, 9), rotation = Quaternion.Euler(0, 180, 0)}
			UIScene:SetCameraTransform(transform)
			
		end
		UIScene:ChangeScene(self, callback)
	end

	if nil ~= index_nodes then
		if index == TabIndex.world_boss then
			self.world_boss_view = WorldBossView.New(index_nodes["BossPanel"])
		elseif index == TabIndex.miku_boss then
			self.miku_boss_view = MikuBossView.New(index_nodes["MikuPanel"])
		elseif index == TabIndex.active_boss then
			self.active_boss_view = BossActiveView.New(index_nodes["ActivePanel"])
		elseif index == TabIndex.vip_boss then
			BossCtrl.Instance:SendGetBossInfoReq(BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY)
			self.boss_family_view = BossFamilyView.New(index_nodes["FamilyPanel"])
			BossData.BossRemindPoint[RemindName.Boss_Family] = false
			RemindManager.Instance:Fire(RemindName.Boss_Family)
		elseif index == TabIndex.dabao_boss then
			self.dabao_boss_view = DabaoBossView.New(index_nodes["DabaoPanel"])
			RemindManager.Instance:SetRemindToday(RemindName.Boss_DaBao)
		elseif index == TabIndex.baby_boss then
			self.baby_boss_view = BabyBossView.New(index_nodes["BabyPanel"])
			RemindManager.Instance:SetRemindToday(RemindName.Boss_Baby)
		elseif index == TabIndex.personal_boss then
			self.personal_boss_view = PersonalBossView.New(index_nodes["PersonalPanel"])
			BossData.BossRemindPoint[RemindName.Boss_Personal] = false
			RemindManager.Instance:Fire(RemindName.Boss_Personal)

		-- elseif index == TabIndex.shanggu_boss then
		-- 	self.shanggu_view = ShangguBossView.New(index_nodes["SgPanel"])
		-- 	RemindManager.Instance:SetRemindToday(RemindName.Boss_Shanggu)

		elseif index == TabIndex.tujian_boss then
			self.tujian_view = BossTujianView.New(index_nodes["TuJianPanel"])

		end
	end

	if index == TabIndex.world_boss then
		self.world_boss_view:DoPanelTweenPlay()
		self.world_boss_view:Flush()

	elseif index == TabIndex.miku_boss then 
		self.miku_boss_view:DoPanelTweenPlay()
		self.miku_boss_view:SetReMainTime()
		self.miku_boss_view:Flush()

	elseif index == TabIndex.active_boss then
		self.active_boss_view:DoPanelTweenPlay()
		self.active_boss_view:Flush()

	elseif index == TabIndex.vip_boss then 
		self.boss_family_view:DoPanelTweenPlay()
		self.boss_family_view:Flush()

	elseif index == TabIndex.dabao_boss then
		self.dabao_boss_view:DoPanelTweenPlay()
		self.dabao_boss_view:Flush()

	elseif index == TabIndex.baby_boss then
		self.baby_boss_view:DoPanelTweenPlay()
		self.baby_boss_view:Flush()

	elseif index == TabIndex.personal_boss then
		self.personal_boss_view:DoPanelTweenPlay()
		self.personal_boss_view:Flush()

	-- elseif index == TabIndex.shanggu_boss then
	-- 	self.shanggu_view:DoPanelTweenPlay()
	-- 	self.shanggu_view:Flush()

	elseif index == TabIndex.tujian_boss then
		self.tujian_view:DoPanelTweenPlay()
		self.tujian_view:ShowIndex()
		self.boss_res_id = nil

	end

end

function BossView:CloseCallBack()
	RemindManager.Instance:Fire(RemindName.Main_Boss)
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
	if self.world_boss_view then
		self.world_boss_view:CloseBossView()
	end
	if self.dabao_boss_view then
		self.dabao_boss_view:CloseBossView()
	end
	if self.boss_family_view then
		self.boss_family_view:CloseBossView()
	end
	if self.miku_boss_view then
		self.miku_boss_view:CloseBossView()
	end
	if self.active_boss_view then
		self.active_boss_view:CloseBossView()
	end
	if self.baby_boss_view then
		self.baby_boss_view:CloseBossView()
	end
	if self.personal_boss_view then
		self.personal_boss_view:CloseBossView()
	end
	-- if self.shanggu_view then
	-- 	self.shanggu_view:CloseBossView()
	-- end
	if self.tujian_view then
		self.tujian_view:CloseBossView()
	end

	if self.event_quest then
		GlobalEventSystem:UnBind(self.event_quest)
	end

	self.boss_res_id = nil
	self.tujian_boss_res_id = nil
end

function BossView:OpenCallBack()
	RemindManager.Instance:SetImmdiateRemind(RemindName.Main_Boss)
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold")
	self:PlayerDataChangeCallback("bind_gold")

	self:Flush("suit_collect_remind")

	--请求一遍boss数据
	
	BossCtrl.Instance:SendGetBossInfoReq(BOSS_ENTER_TYPE.TYPE_BOSS_MIKU)
	BossCtrl.Instance:SendGetBossInfoReq(BOSS_ENTER_TYPE.TYPE_BOSS_PRECIOUS)
	BossCtrl.Instance:SendShangGuBossReq(SGBOSS_REQ_TYPE.ALLINFO)
	BossCtrl.Instance:SendBabyBossRequest(BABY_BOSS_OPERATE_TYPE.BABY_BOSS_ROLE_INFO_REQ)
	BossCtrl.Instance:SendBabyBossRequest(BABY_BOSS_OPERATE_TYPE.BABY_BOSS_INFO_REQ)
	BossCtrl.Instance:SendBossTuJianReq(BOSS_CARD_OPERA_TYPE.BOSS_CARD_OPERA_TYPE_ALL_INFO)
	BossCtrl.Instance:SendPersonalBossBossInfoReq()
end

function BossView:JumpToDaBaoLayer(layer)
	if self.show_index == TabIndex.dabao_boss then
		if self.dabao_boss_view then
			self.dabao_boss_view:ClickScene(layer, true)
		end
	end
end

function BossView:JumpToBabyLayer(layer)
	if self.show_index == TabIndex.baby_boss then
		if self.baby_boss_view then
			self.baby_boss_view:ClickBoss(layer, true)
		end
	end
end

function BossView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(vo.gold)
	end
	if attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(vo.bind_gold)
	end
end

function BossView:OnChangeToggle(index)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if index == TabIndex.miku_boss then
		self.node_list["TabMiku"].toggle.isOn = true
	end
end

function BossView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.Tab then
		local index = TabIndex[ui_param]
		if self.tabbar:GetTabButton(index) then
			local root_node = self.tabbar:GetTabButton(index).root_node
			local callback = BindTool.Bind(self.OnToggleChange, self, index, true)
			if index == self.show_index then
				return NextGuideStepFlag
			else
				return root_node, callback
			end
		end
	elseif ui_name == GuideUIName.BtnToAttach then
		if self.active_boss_view then
			return self.active_boss_view:GetBtnToAttach()
		end
	elseif ui_name == GuideUIName.BossPersonalCha then
		if self.personal_boss_view then
			return self.personal_boss_view:GetToActtackBtn()
		end
	elseif ui_name == GuideUIName.BossGuideFatigue then
		if self.fatigue_guide and self.fatigue_guide.gameObject.activeInHierarchy then
			return self.fatigue_guide
		end
	elseif self.node_list[ui_name] then
		if self.node_list[ui_name].gameObject.activeInHierarchy then
			return self.node_list[ui_name]
		end
	end
end

function BossView:FlushDisPlayModel(boss_data)
	if boss_data and self.boss_res_id ~= boss_data.resid and self.show_index ~= TabIndex.tujian_boss then
		self.boss_res_id = boss_data.resid
		local bundle, asset = ResPath.GetMonsterModel(boss_data.resid)
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)
		UIScene:SetRoleModelScale(boss_data.ui_scale)
		UIScene:SetRoleModelLocalPostion(0, boss_data.ui_position_y, 0)
		UIScene:ResetRotate()
		if boss_data.resid == 3014001 then
			UIScene:Rotate(0, -15, 0)
		else
			UIScene:Rotate(0, -30, 0)
		end
		if UIScene.role_model then
			UIScene.role_model:SetTrigger(ANIMATOR_PARAM.REST1)
		end
	end
end

function BossView:FlushDisPlayModelBox(bundle, asset, res_id)
	if self.boss_res_id ~= res_id and self.show_index ~= TabIndex.tujian_boss then
		self.boss_res_id = res_id
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)
		UIScene:SetRoleModelScale(1)
		UIScene:SetRoleModelLocalPostion(0, 0, 0)
		UIScene:ResetRotate()
		if res_id ~= nil and res_id == 6018001 then		--灿金圣龙
			UIScene:SetRoleModelScale(0.6)
			UIScene:Rotate(0, -45, 0)
		elseif res_id ~= nil and res_id == 6017001 then		--灿金凤凰
			UIScene:SetRoleModelScale(0.9)
			UIScene:Rotate(0, -65, 0)
		elseif res_id ~= nil and res_id == 6019001 then		--上古珍宝
			UIScene:SetRoleModelLocalPostion(0, 0, 0)
			UIScene:SetRoleModelScale(2)
			UIScene:Rotate(0, -30, 0)
		end
	end
end

function BossView:FlushTuJianDisPlayModel(boss_data)
	if boss_data and self.tujian_boss_res_id ~= boss_data.resid and self.show_index == TabIndex.tujian_boss then
		self.tujian_boss_res_id = boss_data.resid

		local callback = function ()
			UIScene:SetRoleModelScale(boss_data.ui_scale * 0.7)
			UIScene:SetRoleModelLocalPostion(0, boss_data.ui_position_y, 0)
			UIScene:ResetRotate()
			if boss_data.resid == 3014001 then
				UIScene:Rotate(0, -15, 0)
			else
				UIScene:Rotate(0, -30, 0)
			end
			if UIScene.role_model then
				UIScene.role_model:SetTrigger(ANIMATOR_PARAM.REST1)
			end
		end
		UIScene:SetModelLoadCallBack(callback)

		local bundle, asset = ResPath.GetMonsterModel(boss_data.resid)
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)
		local transform = {position = Vector3(-0.3, 1.84, 9), rotation = Quaternion.Euler(10, 180, 0)}
		UIScene:SetCameraTransform(transform)
	end
end

function BossView:OnRoleDrag(data)
	if UIScene.role_model then
		UIScene:Rotate(0, -data.delta.x * 0.25, 0)
	end
end