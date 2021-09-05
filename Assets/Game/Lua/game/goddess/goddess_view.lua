require("game/goddess/goddess_info_view")					--信息 GoddessContent
require("game/goddess/shengong/advance_shengong_view")		--仙环 ShenGongContent
require("game/goddess/shenyi/advance_shenyi_view")			--仙阵 ShenYiContent
require("game/goddess/goddess_shengwu_view")				--仙器 ShengWuContent 仙器
-- require("game/goddess/goddess_gongming_view")				--共鸣 GongMingContent

-- 女神
GoddessView = GoddessView or BaseClass(BaseView)

function GoddessView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/goddess_prefab", "ModelDragLayer"},
		{"uis/views/goddess_prefab", "GoddessContent", {TabIndex.goddess_info}},			--信息
		{"uis/views/goddess_prefab", "HaloContent", {TabIndex.goddess_shengong}},			--仙环
		{"uis/views/goddess_prefab", "FaZhenContent", {TabIndex.goddess_shenyi}},			--仙阵
		{"uis/views/goddess_prefab", "ShengWuContent", {TabIndex.goddess_shengwu}},			--仙器
		-- {"uis/views/goddess_prefab", "GongMingContent", {TabIndex.goddess_gongming}},		--共鸣
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
	}

	self.camera_mode = UICameraMode.UICameraMid
	self.full_screen = true
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true

	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].OpenGoddess)
	end

	self.def_index = TabIndex.goddess_info
	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.FlushTabbar, self))
	self.prefab_preload_id = 0
	self.effect_cd = 0
end

function GoddessView:LoadCallBack(index, index_nodes)
	self.tab_cfg = {
		{name = Language.Goddess.TabbarName[1], bundle = "uis/images_atlas", asset = "tab_icon_goddess_info", func = "goddess_info", tab_index = TabIndex.goddess_info, remind_id = RemindName.Goddess},					--信息
		{name = Language.Goddess.TabbarName[2], bundle = "uis/images_atlas", asset = "tab_icon_goddess_halo", func = "goddess_shengong", tab_index = TabIndex.goddess_shengong, remind_id = RemindName.Goddess_Shengong},   --仙环
		{name = Language.Goddess.TabbarName[3], bundle = "uis/images_atlas", asset = "tab_icon_goddess_fazheng", func = "goddess_shenyi", tab_index = TabIndex.goddess_shenyi, remind_id = RemindName.Goddess_Shenyi},		--仙阵
		{name = Language.Goddess.TabbarName[4], bundle = "uis/images_atlas", asset = "tab_icon_goddess_shengwu", func = "goddess_shengwu", tab_index = TabIndex.goddess_shengwu, remind_id = RemindName.Goddess_ShengWu},	--仙器
		-- {name = Language.Goddess.TabbarName[5], bundle = "uis/images_atlas", asset = "tab_icon_goddess_gongming", func = "goddess_gongming", tab_index = TabIndex.goddess_gongming, remind_id = RemindName.Goddess_GongMing},--共鸣
	}
	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], self.tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeTabIndex, self))
	self:SetTuPoTabButtonIcon()
	self.node_list["TxtTitle"].text.text = Language.Goddess.TitleName
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.HandleClose, self))
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.ClickRecharge, self))
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Goddess, BindTool.Bind(self.GetUiCallBack, self))

	self.node_list["RotateEventTrigger"].event_trigger_listener:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))
	-- self.node_list["TaiZi"].rect.anchoredPosition3D = Vector3(-138, -272, 0)
	self.is_scene_load = false								-- 是否加载场景
	
	if self.player_data_change == nil then
		self.player_data_change = BindTool.Bind1(self.PlayerDataChangeCallback, self)
		PlayerData.Instance:ListenerAttrChange(self.player_data_change)
		self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo.gold)
		self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo.bind_gold)
	end

	-- 一折抢购跳转
	local is_open, index, data = DisCountData.Instance:IsOpenYiZheBySystemId(Sysetem_Id_Jump.Xian_Nv)
	if is_open then
		local callback = function(node_list)
				node_list["BtnYiZhe"].button:AddClickListener(function()
				ViewManager.Instance:CloseAll()
				ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {index})
			end)
				node_list["TextYiZhe"].text.text = data.button_name
				self:StartCountDown(data, node_list)
		end
		CommonDataManager.SetYiZheBtnJump(self, self.node_list["BtnYiZheJump"], callback)
	end
end

-- 一折抢购跳转
function GoddessView:StartCountDown(data, node_list)
	self:StopCountDown()
	if nil == data then
		return
	end

	local close_timestamp = data.close_timestamp
	local server_time = TimeCtrl.Instance:GetServerTime()
	local left_times = math.ceil(close_timestamp - server_time)
	local time_des = ""

	if left_times > 0 then
		time_des = TimeUtil.FormatSecond(left_times)

		local function time_func(elapse_time, total_time)
			if elapse_time >= total_time then
				self:StopCountDown()
				if self.node_list then
					self.node_list["BtnYiZheJump"]:SetActive(false)
				end
				return
			end

			left_times = math.ceil(total_time - elapse_time)
			time_des = TimeUtil.FormatSecond(left_times, 13)
			node_list["TextCountDown"].text.text = time_des
		end

		self.left_time_count_down = CountDown.Instance:AddCountDown(left_times, 1, time_func)
		
	end

	time_des = TimeUtil.FormatSecond(left_times, 13)		
	node_list["TextCountDown"].text.text = time_des
	node_list["TextCountDown"]:SetActive(left_times > 0)
end

-- 一折抢购跳转
function GoddessView:StopCountDown()
	if self.left_time_count_down then
		CountDown.Instance:RemoveCountDown(self.left_time_count_down)
		self.left_time_count_down = nil
	end
end

function GoddessView:__delete()
	if self.open_trigger_handle then
		GlobalEventSystem:UnBind(self.open_trigger_handle)
	end

	if self.time_runquest then
		GlobalTimerQuest:CancelQuest(self.time_runquest)
	end
	self.time_runquest = nil
	self.open_trigger_handle = nil
	self.effect_cd = nil

	self:StopCountDown()
end

function GoddessView:GetGoddessInfoView()
	return self.goddess_info_view
end

function GoddessView:ChangeTabIndex(index)
	AdvanceCtrl.Instance:OpenClearBlessView(ViewName.Goddess, self.show_index, BindTool.Bind(self.ChangeToIndex, self), index)
end
function GoddessView:GetGoddessShenGongView()
	return self.goddess_halo_view
end

function GoddessView:GetGoddessShenyiView()
	return self.goddess_fazhen_view
end

function GoddessView:GetGoddessShengWuAllView()
	return self.self.shengwu_content_view
end

function GoddessView:CancelSGPreviewToggle()
	if self.goddess_halo_view then
		self.goddess_halo_view:CancelPreviewToggle()
	end
end

function GoddessView:CancelSYPreviewToggle()
	if self.goddess_fazhen_view then
		self.goddess_fazhen_view:CancelPreviewToggle()
	end
end

function GoddessView:CloseCallBack()
	if self.time_runquest then
		GlobalTimerQuest:CancelQuest(self.time_runquest)
		self.time_runquest = nil
	end
	AdvanceCtrl.Instance:ClearBlessTipView()
	self:StopAutoAdvance()

	if self.advance_shenyi_view then
		self.advance_shenyi_view:CloseCallBack()
	end
	if self.advance_shengong_view then
		self.advance_shengong_view:CloseCallBack()
	end
end

function GoddessView:ReleaseCallBack()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.Goddess)
	end

	if PlayerData.Instance and self.player_data_change then
		PlayerData.Instance:UnlistenerAttrChange(self.player_data_change)
	end
	self.player_data_change = nil

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	if self.goddess_info_view ~= nil then
		self.goddess_info_view:DeleteMe()
		self.goddess_info_view = nil
	end

	if self.shengwu_content_view then
		self.shengwu_content_view:DeleteMe()
		self.shengwu_content_view = nil
	end

	if self.gongming_content_view then
		self.gongming_content_view:DeleteMe()
		self.gongming_content_view = nil
	end

	if self.goddess_fazhen_view then
		self.goddess_fazhen_view:DeleteMe()
		self.goddess_fazhen_view = nil
	end

	if self.goddess_halo_view then
		self.goddess_halo_view:DeleteMe()
		self.goddess_halo_view = nil
	end

	self:StopCountDown()
end

function GoddessView:OpenCallBack()
	self.node_list["BaseFullPanel_1"]:SetActive(false)
	self.is_jump_open = true
	RuneCtrl.Instance:SendBigSmallGoalOper(ROLE_BIG_SMALL_GOAL_OPERA_TYPE.ROLE_BIG_SMALL_GOAL_OPERA_INFO, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANNV)
end

function GoddessView:FlushGoddessInfoView()
	if self.goddess_info_view then
		self.goddess_info_view:Flush()
		self.goddess_info_view:AllCellOnFlush()
	end
end

-- 切换标签调用
function GoddessView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)
	if nil ~= index_nodes then
		if index == TabIndex.goddess_info then
			self.goddess_info_view = GoddessInfoView.New(index_nodes["GoddessContent"])					--信息
		elseif index == TabIndex.goddess_shengong then
			self.goddess_halo_view = AdvanceShengongView.New(index_nodes["HaloContent"])				--仙环
		elseif index == TabIndex.goddess_shenyi then
			self.goddess_fazhen_view = AdvanceShenyiView.New(index_nodes["FaZhenContent"])				--仙阵
		elseif index == TabIndex.goddess_shengwu then
			self.shengwu_content_view = GoddessShengWuView.New(index_nodes["ShengWuContent"])			--仙器
		-- elseif index == TabIndex.goddess_gongming then
		-- 	self.gongming_content_view = GoddessGongMingView.New(index_nodes["GongMingContent"])		--共鸣
		end
	end

	self:StopAutoAdvance()

	self.node_list["BaseFullPanel_1"]:SetActive(false)
	if index == TabIndex.goddess_info and self.goddess_info_view then
		self.goddess_info_view:OpenCallBack()
		self.goddess_info_view:Flush()
		local callback = function()
			UIScene:SetBackground("uis/rawimages/bg_common1_under", "bg_common1_under.jpg")
			UIScene:SetTerraceBg(nil, nil, {position = Vector3(-176, -275, 0)}, nil)
			self.is_scene_load = true
			self:SetModel(index)

			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "goddess")
			UIScene:SetCameraTransform(transform, Vector2(-0.3, 0))
		end
		UIScene:ChangeScene(self, callback)

	elseif index == TabIndex.goddess_shengong and self.goddess_halo_view then
		self.goddess_halo_view:OpenCallBack()
		local callback = function()
			UIScene:SetBackground("uis/rawimages/bg_common1_under", "bg_common1_under.jpg")
			UIScene:SetTerraceBg(nil, nil, {position = Vector3(-176, -275, 0)}, nil)
			self.is_scene_load = true
			self:SetModel(index)
			self.goddess_halo_view:SetModle(true)
			
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "goddess")
			UIScene:SetCameraTransform(transform, Vector2(-0.3, 0))
		end
		UIScene:ChangeScene(self, callback)
		self.goddess_halo_view:FlushView()
	elseif index == TabIndex.goddess_shenyi and self.goddess_fazhen_view then
		self.goddess_fazhen_view:OpenCallBack()
		-- self.node_list["TaiZi"]:SetActive(true)
		-- self.goddess_fazhen_view:FlushView()
		local callback = function()
			-- self.node_list["UnderBg"]:SetActive(true)
			UIScene:SetBackground("uis/rawimages/bg_common1_under", "bg_common1_under.jpg")
			UIScene:SetTerraceBg(nil, nil, {position = Vector3(-176, -275, 0)}, nil)
			self.is_scene_load = true
			self:SetModel(index)
			self.goddess_fazhen_view:SetModle(true)
			

			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "goddess")
			UIScene:SetCameraTransform(transform, Vector2(-0.3, 0))
		end
		UIScene:ChangeScene(self, callback)

	elseif index == TabIndex.goddess_shengwu and self.shengwu_content_view then
		self.node_list["BaseFullPanel_1"]:SetActive(true)
		self.node_list["UnderBg"]:SetActive(true)
		self.node_list["TaiZi"]:SetActive(false)
		self.shengwu_content_view:OpenCallBack()
		UIScene:ChangeScene(nil)

	-- elseif index == TabIndex.goddess_gongming and self.gongming_content_view then
	-- 	-- self.node_list["TaiZi"]:SetActive(false)
	-- 	-- self.node_list["UnderBg"]:SetActive(true)
	-- 	local callback = function()
	-- 		UIScene:SetBackground("uis/rawimages/bg_common1_under", "bg_common1_under.jpg")
	-- 		UIScene:SetTerraceBg(nil, nil, {position = Vector3(-135, -275, 0)}, nil)
	-- 		UIScene:SetTerraceBgActive(false)
	-- 		self.is_scene_load = false
	-- 		self.gongming_content_view:OpenCallBack()
			
	-- 		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "goddess")
	-- 		UIScene:SetCameraTransform(transform, Vector2(-0.3, 0))
	-- 	end
	-- 	UIScene:ChangeScene(self, callback)
	end
end

function GoddessView:StopAutoAdvance()
	if self.goddess_halo_view and self.goddess_halo_view.is_auto then
		self.goddess_halo_view:OnAutomaticAdvance()
	end
	if self.goddess_fazhen_view and self.goddess_fazhen_view.is_auto then
		self.goddess_fazhen_view:OnAutomaticAdvance()
	end
	if index ~= TabIndex.goddess_shengwu and self.shengwu_content_view then
		self.shengwu_content_view:StopAutoQuest()
	end
end

function GoddessView:OnFlush(param_list)
	if self.show_index == TabIndex.goddess_info and self.goddess_info_view then
		self.goddess_info_view:Flush()
	elseif self.show_index == TabIndex.goddess_shengong and self.goddess_halo_view then
		self.goddess_halo_view:FlushView()
	elseif self.show_index == TabIndex.goddess_shenyi and self.goddess_fazhen_view then
		self.goddess_fazhen_view:FlushView()
	elseif self.show_index == TabIndex.goddess_shengwu and self.shengwu_content_view then
		self.shengwu_content_view:Flush()
	-- elseif self.show_index == TabIndex.goddess_gongming and self.gongming_content_view then
	-- 	self.gongming_content_view:Flush()
	end

	for k,v in pairs(param_list) do
		if k == TabIndex.goddess_info and self.goddess_info_view then
			self:SetModelAni(param_list)
			self.goddess_info_view:Flush()
		elseif k == TabIndex.goddess_shengong and self.goddess_halo_view then
			self.goddess_halo_view:FlushView()
		elseif k == TabIndex.goddess_shenyi and self.goddess_fazhen_view then
			self.goddess_fazhen_view:FlushView()
		elseif k == TabIndex.goddess_shengwu and self.shengwu_content_view then
			self.shengwu_content_view:Flush()
		elseif k == "info" and self.goddess_info_view then
			self.goddess_info_view:Flush()
		-- elseif k == TabIndex.goddess_gongming and self.gongming_content_view then
		-- 	self.gongming_content_view:Flush()
		end
	end
end

function GoddessView:FlushShengongModel()
	if self.goddess_halo_view then
		self.goddess_halo_view:FlushView()
		self.goddess_halo_view:SetArrowState(nil, true)
	end
end

function GoddessView:FlushShenyiModel()
	if self.goddess_fazhen_view then
		self.goddess_fazhen_view:FlushView()
		self.goddess_fazhen_view:SetArrowState(nil, true)
	end
end

function GoddessView:ShengongUpGradeResult(result)
	if self.goddess_halo_view then
		self.goddess_halo_view:ShengongUpGradeResult(result)
	end
end

function GoddessView:ShenyiUpGradeResult(result)
	if self.goddess_fazhen_view then
		self.goddess_fazhen_view:ShenyiUpGradeResult(result)
	end
end

function GoddessView:HandleClose()
	AdvanceCtrl.Instance:OpenClearBlessView(ViewName.Goddess, self.show_index)
end

function GoddessView:ClickRecharge()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function GoddessView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.Tab then
		local index = TabIndex[ui_param]
		if index == self.show_index then
			return NextGuideStepFlag
		end
		if index == TabIndex.goddess_info then
			if self.toggle_list[1].gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.goddess_info)
				return self.toggle_list[1], callback
			end
		end
	elseif ui_name == GuideUIName.GodessUpBtn then
		if self.goddess_info_view then
			return self.goddess_info_view:GetActiveBtn(), self.goddess_info_view:GetActiveClickfun()
		end
	elseif ui_name == GuideUIName.CloseBtn then
		if self.node_list["BtnClose"] then
			return self.node_list["BtnClose"], BindTool.Bind(self.HandleClose, self)
		end
	elseif ui_name == GuideUIName.GodessIcon1 then
		if self[ui_name].gameObject.activeInHierarchy then
			local callback = BindTool.Bind(self.GodessIcon1Click, self)
			return self[ui_name], callback
		end
	elseif self.node_list[ui_name] then
		if self.node_list[ui_name].gameObject.activeInHierarchy then
			return self.node_list[ui_name]
		end
	end
end

-- 玩家元宝改变时
function GoddessView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(vo.gold)
	end

	if attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(vo.bind_gold)
	end
end

function GoddessView:FlushTabbar()	
	if not self:IsOpen() then return end
	self.tabbar:FlushTabbar()
end

--控制模型动画
function GoddessView:SetModelAni(param_list)
	local the_xiannv_id = -1
	if param_list.all.item_id then
		the_xiannv_id = GoddessData.Instance:GetXianIdByActiveId(param_list.all.item_id)
	end
	if self.is_jump_open == true then
		if the_xiannv_id > -1 then
			self.goddess_info_view:SetToIconIndex(the_xiannv_id)
			self.is_jump_open = false
			self:SetModel()
		else
			local jump_xn_id = GoddessData.Instance:GetCanActiveXiannvId()
			if jump_xn_id ~= -1 then
				self.goddess_info_view:SetToIconIndex(jump_xn_id)
				self.is_jump_open = false
			else
				self.goddess_info_view:ReloadData()
				self:SetModel()
			end
		end
	end
end

local TypeGameObjectAttach = typeof(Game.GameObjectAttach)

function GoddessView:SetModel(index)
	if not self.is_scene_load then return end
	local xiannv_id = self.goddess_info_view and self.goddess_info_view:GetCurrentXiannvID() or 0
	
	local call_back = function(model, obj)
		if self.time_runquest then
			GlobalTimerQuest:CancelQuest(self.time_runquest)
			self.time_runquest = nil
		end
		local call_back_1 = function()
			if UIScene.role_model then
				local part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
				if part ~= nil then
					local part_obj = part:GetObj()
					if nil ~= part_obj then
						local eff_obj = part_obj.transform:Find("GameObject") -- 隐藏仙女脚下默认的法阵特效
						if eff_obj ~= nil and nil ~= eff_obj:GetComponent(TypeGameObjectAttach) then
							eff_obj.gameObject:SetActive(index ~= TabIndex.goddess_shenyi)
						end
					end
				end
				part:SetTrigger(GoddessData.Instance:GetShowTriggerName(1))
			end
		end
		call_back_1()
		self.time_runquest = GlobalTimerQuest:AddRunQuest(call_back_1, 15)
	end
	UIScene:SetModelLoadCallBack(call_back)

	if self.goddess_info_view and self:GetShowIndex() == TabIndex.goddess_info then
		local bundle, asset = ResPath.GetGoddessModel(GoddessData.Instance:GetXianNvCfg(xiannv_id).resid)
		-- local bundle, asset = ResPath.GetGoddessModel(GoddessData.Instance:GetShowInfoRes(xiannv_id))
		-- local wing_res_id = ShenyiData.Instance:GetCurShenyiRes()
		-- local bundle2, asset2 = "", ""
		-- if wing_res_id then
		-- 	bundle2, asset2 = ResPath.GetGoddessFaZhenModel(wing_res_id)
		-- end

		PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
		-- UIScene:LoadSceneEffect(bundle, asset)
		local load_list = {{bundle, asset}}
		self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
				local bundle_list = {}
				local asset_list = {}
				-- if wing_res_id == -1 then
				bundle_list = {[SceneObjPart.Main] = bundle}
				asset_list = {[SceneObjPart.Main] = asset}
				-- else
				-- 	bundle_list = {[SceneObjPart.Main] = bundle, [SceneObjPart.Wing] = bundle2}
				-- 	asset_list = {[SceneObjPart.Main] = asset, [SceneObjPart.Wing] = asset2}
				-- end
				UIScene:ModelBundle(bundle_list, asset_list)
			end)
	end

	if nil ~= self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
	end
end

function GoddessView:CalToShowAnim(is_change_tab)
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	local timer = GameEnum.GODDESS_ANIM_LONG_TIME
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer = timer - UnityEngine.Time.deltaTime
		if timer <= 0 or is_change_tab == true then
			if is_change_tab then
				self:PlayAnim(is_change_tab)
				is_change_tab = false
				timer = GameEnum.GODDESS_ANIM_LONG_TIME
				GlobalTimerQuest:CancelQuest(self.time_quest)
			else
				self:PlayAnim(is_change_tab)
				is_change_tab = false
				timer = GameEnum.GODDESS_ANIM_LONG_TIME
				GlobalTimerQuest:CancelQuest(self.time_quest)
			end
		end
	end, 0)
end

function GoddessView:PlayAnim(is_change_tab)
	local is_change_tab = is_change_tab
	if self.time_quest_2 then
		GlobalTimerQuest:CancelQuest(self.time_quest_2)
		self.time_quest_2 = nil
	end
	-- local timer = GameEnum.GODDESS_ANIM_SHORT_TIME
	-- local count = 1
	-- self.time_quest_2 = GlobalTimerQuest:AddRunQuest(function()
	-- 	timer = timer - UnityEngine.Time.deltaTime
	-- 	if timer <= 0 or is_change_tab == true then
	-- 		if UIScene.role_model then
	-- 			local part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
	-- 			if part then
	-- 				part:SetTrigger(GoddessData.Instance:GetShowTriggerName(1))
	-- 			end
	-- 			timer = GameEnum.GODDESS_ANIM_SHORT_TIME
	-- 			is_change_tab = false
	-- 			if count == 5 then
	-- 				GlobalTimerQuest:CancelQuest(self.time_quest_2)
	-- 				self.time_quest_2 = nil
	-- 				self:CalToShowAnim()
	-- 			end
	-- 		end
	-- 	end
	-- end, 0)
end

function GoddessView:OnRoleDrag(data)
	if UIScene.role_model then
		UIScene:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

-- 刷新法则
function GoddessView:UpdataShengWuView()
	if self.shengwu_content_view then
		self.shengwu_content_view:Flush()
	end
end

-- 刷新共鸣格子
function GoddessView:UpdataGongMingGrid()
	if self.gongming_content_view then
		self.gongming_content_view:UpdataGongMingGrid()
	end
end

function GoddessView:ShowShengWuViewFly()
	if self.shengwu_content_view then
		self.shengwu_content_view:ShowShengWuViewFly()
	end
end

function GoddessView:SetTuPoTabButtonIcon()
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local tab_index = COMPETITION_ACTIVITY_DAY_TO_TABINDEX[cur_day]
	if tab_index and self.tabbar then
		local tab_button = self.tabbar:GetTabButton(tab_index)
		if tab_button then
			tab_button:ShowBiPin(true)
		end
	end		
end