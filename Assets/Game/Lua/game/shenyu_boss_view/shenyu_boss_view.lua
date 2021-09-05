require("game/boss/kf_boss_view")
require("game/shenyu_boss_view/shenyu_boss_tujian_view")
require("game/shenyu_boss_view/shenyu_boss_secret_view")
require("game/shenyu_boss_view/shenyu_boss_youming_view")
require("game/shenyu_boss_view/shenyu_mijing_view")
require("game/shenyu_boss_view/shenyu_godmagic_boss_view")

ShenYuBossView = ShenYuBossView or BaseClass(BaseView)

function ShenYuBossView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/bossview_prefab", "DragPanel"},
		{"uis/views/shenyubossview_prefab", "SecretPanel", {TabIndex.shenyu_secret}},				-- 秘藏
		-- {"uis/views/shenyubossview_prefab", "YouMingPanel", {TabIndex.shenyu_youming}},				-- 幽冥
		{"uis/views/bossview_prefab", "KfPanel", {TabIndex.kf_boss}},									-- 跨服Boss
		{"uis/views/bossview_prefab", "GodMagicPanel", {TabIndex.shenyu_godmagic}},							-- 神魔Boss
		{"uis/views/shenyubossview_prefab", "TuJianPanel", {TabIndex.shenyu_boss_tujian}},				-- 图鉴
		{"uis/views/shenyubossview_prefab", "ActivityneMiBaoContent", {TabIndex.shenyu_zhengbao,TabIndex.nuzhan_jiuxiao,TabIndex.luandou_zhanchang}},		-- 珍宝秘境
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
	}
	self.camera_mode = UICameraMode.UICameraMid
	self.full_screen = true
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.is_first = true
	self.def_index = TabIndex.shenyu_godmagic

	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.FlushTabbar, self))
	
end

function ShenYuBossView:__delete()
	if self.open_trigger_handle then
		GlobalEventSystem:UnBind(self.open_trigger_handle)
	end
end

function ShenYuBossView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	if self.kf_boss_view then
		self.kf_boss_view:DeleteMe()
		self.kf_boss_view = nil
	end

	if self.godmagic_view then
		self.godmagic_view:DeleteMe()
		self.godmagic_view = nil
	end

	if self.shenyu_tujian then
		self.shenyu_tujian:DeleteMe()
		self.shenyu_tujian = nil
	end

	if self.shenyu_secret then
		self.shenyu_secret:DeleteMe()
		self.shenyu_secret = nil
	end
	if self.mijing_view then
		self.mijing_view:DeleteMe()
		self.mijing_view = nil
	end

	-- if self.shenyu_youming then
	-- 	self.shenyu_youming:DeleteMe()
	-- 	self.shenyu_youming = nil
	-- end

	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.ShenYuBossView)
	end
end

function ShenYuBossView:LoadCallBack()
	local tab_cfg = {
		{name = Language.ShenYuBoss.TabbarName[8], bundle = "uis/images_atlas", asset = "tab_godmagic_default", func = "shenyu_godmagic", tab_index = TabIndex.shenyu_godmagic, remind_id = RemindName.ShenYu_Godmagic},
		-- {name = Language.ShenYuBoss.TabbarName[2], bundle = "uis/images_atlas", asset = "tab_shanggu_default", func = "", tab_index = TabIndex.shenyu_youming, remind_id = RemindName.ShenYu_YouMing},
		{name = Language.ShenYuBoss.TabbarName[3], bundle = "uis/images_atlas", asset = "tab_kf_default", func = "kf_boss", tab_index = TabIndex.kf_boss, remind_id = RemindName.Boss_Kf},
		{name = Language.ShenYuBoss.TabbarName[1], bundle = "uis/images_atlas", asset = "tab_jingying_default", func = "shenyu_secret", tab_index = TabIndex.shenyu_secret, remind_id = RemindName.ShenYu_Secret},
		{name = Language.ShenYuBoss.TabbarName[4], bundle = "uis/images_atlas", asset = "tab_tujian_default", func = "tujian_boss", tab_index = TabIndex.shenyu_boss_tujian, remind_id = RemindName.ShenYu_Tujian},
		{name = Language.ShenYuBoss.TabbarName[5], bundle = "uis/images_atlas", asset = "tab_baoxiang_default", func = "shenyu_zhengbao", tab_index = TabIndex.shenyu_zhengbao},
		{name = Language.ShenYuBoss.TabbarName[6], bundle = "uis/images_atlas", asset = "tab_jifen_default", func = "nuzhan_jiuxiao", tab_index = TabIndex.nuzhan_jiuxiao},
		{name = Language.ShenYuBoss.TabbarName[7], bundle = "uis/images_atlas", asset = "tab_shuijing_default", func = "luandou_zhanchang", tab_index = TabIndex.luandou_zhanchang},
	}

	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.OpenIndexCheck, self))

	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.OnClickAddGold, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["TxtTitle"].text.text = Language.ShenYuBoss.Title
	-- FunctionGuide.Instance:RegisteGetGuideUi(ViewName.ShenYuBossView, BindTool.Bind(self.GetUiCallBack, self))

	local event_trigger = self.node_list["ModelDragLayer"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))

	BossCtrl.Instance:SendCrossBossBossInfoReq(CROSS_BOSS_OPERATE_TYPE.GET_FLUSH_INFO, 0)
	ShenYuBossCtrl.Instance:SendGodMagicBossBossInfoReq(GODMAGIC_BOSS_OPERA_TYPE.GODMAGIC_BOSS_OPERA_TYPE_GET_FLUSH_INFO, 0)
	ShenYuBossCtrl.Instance:SendGodMagicBossBossInfoReq(GODMAGIC_BOSS_OPERA_TYPE.GODMAGIC_BOSS_OPERA_TYPE_PLAYER_INFO)
end

function ShenYuBossView:OnRoleDrag(data)
	if UIScene.role_model then
		UIScene:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function ShenYuBossView:OpenCallBack()
	RemindManager.Instance:SetImmdiateRemind(RemindName.ShenYuBoss)
	-- 监听系统事件
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	RemindManager.Instance:Fire(RemindName.ShenYu_Tujian)
	self:Flush()
end

-- 元宝
function ShenYuBossView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(vo.gold)
	end

	if attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(vo.bind_gold)
	end
end

function ShenYuBossView:OnClickAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function ShenYuBossView:ShowIndexCallBack(index, index_nodes, is_jump)
	local act_id  = 0
	self.tabbar:ChangeToIndex(index, is_jump)
	self.node_list["UnderBg"]:SetActive(false)
	self.node_list["TaiZi"]:SetActive(false)
	self.node_list["BaseFullPanel_1"]:SetActive(index == TabIndex.shenyu_boss_tujian)
	UIScene:ChangeScene(nil)
	UIScene:SetTerraceBgActive(false)
	if index == TabIndex.shenyu_boss_tujian then
		self.node_list["BaseFullPanel_1"]:SetActive(true)
		local bundle_bg, asset_bg = ResPath.GetRawImage("bg_boss_tujian",true)
		self.node_list["UnderBg"]:SetActive(true)
		self.node_list["UnderBg"].raw_image:LoadSprite(bundle_bg, asset_bg, fun)
	end
	local callback = function()
		local bundle, asset = ResPath.GetRawImage("Bg_Boss",true)

		UIScene:SetBackground(bundle, asset)
		local transform = {position = Vector3(-0.3, 1.84, 9), rotation = Quaternion.Euler(0, 180, 0)}
		UIScene:SetCameraTransform(transform)
	end
	UIScene:ChangeScene(self, callback)

	if index == TabIndex.shenyu_boss_tujian then
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
		if index == TabIndex.shenyu_secret then
			-- RemindManager.Instance:SetRemindToday(RemindName.ShenYu_Secret)
			self.shenyu_secret = ShenYuBossSecretView.New(index_nodes["SecretPanel"])
		-- elseif index == TabIndex.shenyu_youming then
		-- 	RemindManager.Instance:SetRemindToday(RemindName.ShenYu_YouMing)
		-- 	self.shenyu_youming = ShenYuBossYouMingView.New(index_nodes["YouMingPanel"])
		elseif index == TabIndex.kf_boss then
			self.kf_boss_view = KuaFuBossView.New(index_nodes["KfPanel"])
			-- RemindManager.Instance:SetRemindToday(RemindName.Boss_Kf)
			RemindManager.Instance:Fire(RemindName.ShenYuBoss)
		elseif index == TabIndex.shenyu_godmagic then
			self.godmagic_view = GodMagicBossView.New(index_nodes["GodMagicPanel"])
		elseif index == TabIndex.shenyu_boss_tujian then
			self.shenyu_tujian = ShenYuBossTujianView.New(index_nodes["TuJianPanel"])
		elseif index == TabIndex.shenyu_zhengbao or index == TabIndex.nuzhan_jiuxiao or index == TabIndex.luandou_zhanchang  then
			self.mijing_view = ZhengBaoMiJingView.New(index_nodes["ActivityneMiBaoContent"])
		end
	end
	if index == TabIndex.kf_boss then
		self.boss_res_id = nil
		self.kf_boss_view:DoPanelTweenPlay()
		self.kf_boss_view:ShowIndex()
		self.kf_boss_view:SetReMainTime()
		BossCtrl.Instance:SendCrossBossBossInfoReq(CROSS_BOSS_OPERATE_TYPE.GET_FLUSH_INFO, 0)
		BossCtrl.Instance:SendCrossBossBossInfoReq(CROSS_BOSS_OPERATE_TYPE.DROP_RECORD)
		BossData.BossRemindPoint[RemindName.Boss_Kf] = false
		RemindManager.Instance:Fire(RemindName.Boss_Kf)
	elseif index == TabIndex.shenyu_godmagic then
		self.boss_res_id = nil
		self.godmagic_view:DoPanelTweenPlay()
		self.godmagic_view:ShowIndex()
	elseif index == TabIndex.shenyu_boss_tujian then
		self.shenyu_tujian:DoPanelTweenPlay()
		self.shenyu_tujian:ShowIndex()
		BossCtrl.Instance:SendBossTuJianReq(BOSS_CARD_OPERA_TYPE.BOSS_CARD_OPERA_TYPE_ALL_INFO)
		self.boss_res_id = nil
	elseif index == TabIndex.shenyu_secret then
		self.boss_res_id = nil
		self.shenyu_secret:DoPanelTweenPlay()
		self.shenyu_secret:ShowIndex()
		ShenYuBossCtrl.Instance:SendCrossMiZangBossBossInfoReq(CROSS_MIZANG_BOSS_OPERA_TYPE.CROSS_MIZANG_BOSS_OPERA_TYPE_GET_FLUSH_INFO, 0)
		ShenYuBossCtrl.Instance:SendCrossMiZangBossBossInfoReq(CROSS_MIZANG_BOSS_OPERA_TYPE.CROSS_MIZANG_BOSS_OPERA_TYPE_DROP_RECORD)
		BossData.BossRemindPoint[RemindName.ShenYu_Secret] = false
		RemindManager.Instance:Fire(RemindName.ShenYu_Secret)
	elseif index == TabIndex.shenyu_zhengbao then
		self.mijing_view:DoPanelTweenPlay()
		 act_id = ACTIVITY_TYPE.KF_MONTH_BLACK_WIND_HIGHT
		self.mijing_view:ShowIndex(act_id)
		local bundle, asset = ResPath.GetRawImage("img_zhengbao",true)
		UIScene:SetBackground(bundle, asset)
	elseif index == TabIndex.nuzhan_jiuxiao then
		self.mijing_view:DoPanelTweenPlay()
		act_id = ACTIVITY_TYPE.NIGHT_FIGHT_FB
		if not ActivityData.Instance:GetActivityIsOpen(act_id) then
			act_id = ACTIVITY_TYPE.KF_TUANZHAN
		end
		self.mijing_view:ShowIndex(act_id)
		local bundle, asset = ResPath.GetRawImage("img_nuzhan",true)
		UIScene:SetBackground(bundle, asset)
	elseif index == TabIndex.luandou_zhanchang then
		self.mijing_view:DoPanelTweenPlay()
		act_id = ACTIVITY_TYPE.LUANDOUBATTLE
		if not ActivityData.Instance:GetActivityIsOpen(act_id) then
			act_id = ACTIVITY_TYPE.KF_LUANDOUBATTLE
		end
		self.mijing_view:ShowIndex(act_id)
		local bundle, asset = ResPath.GetRawImage("img_luandou",true)
		UIScene:SetBackground(bundle, asset)
	-- elseif index == TabIndex.shenyu_youming then
	-- 	self.shenyu_youming:DoPanelTweenPlay()
	-- 	self.shenyu_youming:ShowIndex()
	-- ShenYuBossCtrl.Instance:SendCrossYouMingBossBossInfoReq(CROSS_YOUMING_BOSS_OPERA_TYPE.CROSS_YOUMING_BOSS_OPERA_TYPE_GET_FLUSH_INFO, 0)
	end
end

function ShenYuBossView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "KFJumpToIndex" and self.show_index == TabIndex.shenyu_secret then
			if self.shenyu_secret then
				if v then
					for k1,v1 in pairs(v) do
						self.shenyu_secret:JumpToLayerIndex(v1)
					end
				end
			end
		elseif k == "kf_boss" and self.show_index == TabIndex.kf_boss then
			if self.kf_boss_view then
				self.kf_boss_view:Flush()
			end
		elseif k == "godmagic_boss" and self.show_index == TabIndex.shenyu_godmagic then
			if self.godmagic_view then
				self.godmagic_view:Flush()
			end
		elseif k == "tujian_boss" and self.show_index == TabIndex.shenyu_boss_tujian then
			if self.shenyu_tujian then
				self.shenyu_tujian:Flush()
			end
		elseif k == "secret_boss" then--and self.show_index == TabIndex.shenyu_secret then
			if self.shenyu_secret then
				self.shenyu_secret:Flush()
			end
		elseif k == "youming_boss" and self.show_index == TabIndex.shenyu_youming then
			if self.shenyu_youming then
				self.shenyu_youming:Flush()
			end
		elseif k == "shenyu_zhengbao" and self.show_index == TabIndex.shenyu_zhengbao then
			if self.mijing_view then
				self.mijing_view:Flush()
			end
		elseif k == "nuzhan_jiuxiao" and self.show_index == TabIndex.nuzhan_jiuxiao then
			if self.mijing_view then
				self.mijing_view:Flush()
			end
		end
	end
end

function ShenYuBossView:CloseCallBack()
	RemindManager.Instance:Fire(RemindName.ShenYuBoss)
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
	if self.kf_boss_view then
		self.kf_boss_view:CloseBossView()
	end

	if self.godmagic_view then
		self.godmagic_view:CloseBossView()
	end
	
	if self.shenyu_tujian then
		self.shenyu_tujian:CloseBossView()
	end
	if self.shenyu_secret then
		self.shenyu_secret:CloseBossView()
	end
	
	-- if self.shenyu_youming then
	-- 	self.shenyu_youming:CloseBossView()
	-- end
	self.tujian_boss_res_id = nil
	self.boss_res_id = nil
end

function ShenYuBossView:FlushTabbar()
	if not self:IsOpen() then return end
	self.tabbar:FlushTabbar()
end

function ShenYuBossView:OpenIndexCheck(to_index)
	self:ChangeToIndex(to_index)
end

function ShenYuBossView:GetUiCallBack(ui_name, ui_param)
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
	elseif self.node_list[ui_name] then
		if self.node_list[ui_name].gameObject.activeInHierarchy then
			return self.node_list[ui_name]
		end
	end
end

function ShenYuBossView:OnToggleChange(index, is_click)
	if is_click then
		if self.show_index ~= index then
			self:ChangeToIndex(index)
		end
	end
end

function ShenYuBossView:FlushDisPlayModel(boss_data)
	if boss_data and self.boss_res_id ~= boss_data.resid and self.show_index ~= TabIndex.shenyu_boss_tujian then
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

function ShenYuBossView:FlushDisPlayModelBox(bundle, asset, res_id)
	if self.boss_res_id ~= res_id and self.show_index ~= TabIndex.shenyu_boss_tujian then
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

function ShenYuBossView:FlushTuJianDisPlayModel(boss_data)
	if boss_data and self.tujian_boss_res_id ~= boss_data.resid and self.show_index == TabIndex.shenyu_boss_tujian then
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