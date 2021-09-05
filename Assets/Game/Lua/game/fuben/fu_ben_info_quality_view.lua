FuBenInfoQualityView = FuBenInfoQualityView or BaseClass(BaseView)

function FuBenInfoQualityView:__init()
	self.ui_config = {{"uis/views/fubenview_prefab", "QualityFBInFoView"}}

	self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER,
		BindTool.Bind(self.OnChangeScene, self))
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE,
		BindTool.Bind(self.Flush, self))

	self.item_data = {}
	self.item_cells = {}
	self.item_list = {}
	self.is_first_open = true
	self.is_open_finish = false
	self.active_close = false
	self.fight_info_view = true
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true						-- IphoneX适配
end

function FuBenInfoQualityView:LoadCallBack()
	self.temp_time = 0
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
	for i=1, 3 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["Item" .. i])
	end

	self:Flush()
end

function FuBenInfoQualityView:__delete()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	self.is_first_open = nil
	self.is_open_finish = nil

	if self.delay_set_attached then
		GlobalTimerQuest:CancelQuest(self.delay_set_attached)
		self.delay_set_attached = nil
	end


	if self.main_view_complete ~= nil then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end

	if self.scene_load_enter ~= nil then
		GlobalEventSystem:UnBind(self.scene_load_enter)
		self.scene_load_enter = nil
	end
	if self.close_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.close_timer)
		self.close_timer = nil
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function FuBenInfoQualityView:ReleaseCallBack()
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	if self.obj_del_event ~= nil then
		GlobalEventSystem:UnBind(self.obj_del_event)
		self.obj_del_event = nil
	end

	if self.star_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.star_count_down)
		self.star_count_down = nil
	end

	if self.delay_move_panel then
		GlobalTimerQuest:CancelQuest(self.delay_move_panel)
		self.delay_move_panel = nil
	end

	if self.delay_set_attached then
		GlobalTimerQuest:CancelQuest(self.delay_set_attached)
		self.delay_set_attached = nil
	end

	if self.item_list then
		for k, v in pairs(self.item_list) do
			v:DeleteMe()
		end
	end
	self.item_list = {}

	-- 清理变量和对象
	self.kill_monster = nil
	self.monster_name = nil

	self.show_panel = nil
	if self.next_countdown ~= nil then
		CountDown.Instance:RemoveCountDown(self.next_countdown)
		self.next_countdown = nil
	end
	GlobalTimerQuest:CancelQuest(self.next_countdown)
end

function FuBenInfoQualityView:AutoNextPalyer()
	GlobalTimerQuest:CancelQuest(self.delay_set_attached)
	self.delay_set_attached = GlobalTimerQuest:AddDelayTimer(function ()
		for k, v in pairs(Scene.Instance:GetObjListByType(SceneObjType.Door)) do
			local door_x, door_y = v:GetLogicPos()
			local scene_id = Scene.Instance:GetSceneId()
			GuajiCtrl.Instance:MoveToPos(scene_id, door_x, door_y)
			break
		end
	end, 1)
end

function FuBenInfoQualityView:OnObjDelete(obj)
	local fall_item_list = Scene.Instance:GetObjListByType(SceneObjType.FallItem)
	if not next(fall_item_list) then
		self:AutoNextPalyer()
		if self.delay_auto_move then
			GlobalTimerQuest:CancelQuest(self.delay_auto_move)
			self.delay_auto_move = nil
		end
	else
		GlobalTimerQuest:CancelQuest(self.delay_auto_move)
		self.delay_auto_move = GlobalTimerQuest:AddDelayTimer(function ()
			self:AutoNextPalyer()
		end, 1)
	end
end

function FuBenInfoQualityView:DoPanelTweenPlay()
	local fb_scene_info = FuBenData.Instance:GetChallengeInfoList()
	if self.node_list["GradePanle"] == nil or fb_scene_info == nil or fb_scene_info.fight_layer > 0 then return end

	local start_pos = Vector3(1334, 50, 0)
	local mid_pos = Vector3(500, 50, 0)
	local end_pos = Vector3(0, 185, 0)
	local function func()
		GlobalTimerQuest:CancelQuest(self.delay_move_panel)
		self.delay_move_panel = GlobalTimerQuest:AddDelayTimer(function ()
			UITween.MoveToShowPanel(self.node_list["GradePanle"], mid_pos, end_pos, 1)
		end, 2)
	end
	UITween.MoveToShowPanel(self.node_list["GradePanle"], start_pos, mid_pos, 1, nil, func)
end

function FuBenInfoQualityView:OpenCallBack()
	self.is_first_open = true
	self.is_open_finish = false
	self.temp_time = 0
	self:SetStarCountDown()
	self:DoPanelTweenPlay()
	self:Flush()
	self.node_list["EndTime"].text.text = ""
	self.obj_del_event = GlobalEventSystem:Bind(ObjectEventType.OBJ_DELETE,
		BindTool.Bind(self.OnObjDelete, self))

	local diff_time = 9999
	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			else
				local monster_list = Scene.Instance:GetObjListByType(SceneObjType.Monster)
				local main_role = Scene.Instance:GetMainRole()
				if GetListNum(monster_list) == 0 then
					if GuajiCache.guaji_type ~= GuajiType.Auto and main_role:IsStand() then
						GuajiCache.guaji_type = GuajiType.Auto
					end
					if GuajiCache.guaji_type == GuajiType.Auto and main_role:IsStand() then
						self:AutoNextPalyer()
					end
				end
			end

		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 2, diff_time_func)
	end
end

function FuBenInfoQualityView:CloseCallBack()
	self.temp_time = 0
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.star_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.star_count_down)
		self.star_count_down = nil
	end
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
	if self.delay_auto_move then
		GlobalTimerQuest:CancelQuest(self.delay_auto_move)
		self.delay_auto_move = nil
	end

	if self.obj_del_event ~= nil then
		GlobalEventSystem:UnBind(self.obj_del_event)
		self.obj_del_event = nil
	end
	if self.next_countdown ~= nil then
		CountDown.Instance:RemoveCountDown(self.next_countdown)
		self.next_countdown = nil
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.delay_set_attached then
		GlobalTimerQuest:CancelQuest(self.delay_set_attached)
		self.delay_set_attached = nil
	end
end

function FuBenInfoQualityView:OnChangeScene()
	if Scene.Instance:GetSceneType() == SceneType.ChallengeFB then
		MainUICtrl.Instance:SetViewState(false)
	end
end

function FuBenInfoQualityView:SetCountDown()
	local fb_scene_info = FuBenData.Instance:GetChallengeInfoList()
	local layer_info = FuBenData.Instance:GetPassLayerInfo()
	if not next(fb_scene_info) or not next(layer_info) then return end
	local diff_time = 0
	if layer_info.is_finish == 1 and layer_info.is_pass == 0 then -- role_hp <= 0 and
		if self.count_down ~= nil then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		if not self.is_open_finish then
			if ViewManager.Instance:IsOpen(ViewName.CommonTips) then
				ViewManager.Instance:Close(ViewName.CommonTips)
			end
			FuBenCtrl.Instance:SendExitFBReq()
			GlobalTimerQuest:AddDelayTimer(function()
				FuBenData.Instance:ClearFBDropInfo()
				local capability = GameVoManager.Instance:GetMainRoleVo().capability
				PlayerPrefsUtil.SetInt("fubenquality_remind", capability)
				ViewManager.Instance:Open(ViewName.FBFailFinishView)
			end, 2)
		end
		self.is_open_finish = false
		return
	end

	diff_time = layer_info.time_out_stamp - TimeCtrl.Instance:GetServerTime()

	if fb_scene_info.is_pass == 1 then
		diff_time = 15
		if self.count_down ~= nil then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		if self.close_timer ~= nil then
			GlobalTimerQuest:CancelQuest(self.close_timer)
			self.close_timer = nil
		end
		if not self.is_open_finish then
			if ViewManager.Instance:IsOpen(ViewName.CommonTips) then
				ViewManager.Instance:Close(ViewName.CommonTips)
			end
			-- FuBenCtrl.Instance:SendExitFBReq()
			-- local item_data_list = FuBenData.Instance:GetChallengCfgByLevel(fb_scene_info.level)["star_reward_item_" .. fb_scene_info.reward_flag]
			local item_data_list = FuBenData.Instance:GetFBDropItemInfo()
			self.close_timer = GlobalTimerQuest:AddDelayTimer(function ()
				local func = function()
					local index = FuBenData.Instance:GetQualitySelectIndex()
					index = index or 0
					if index == 0 then
						index = 1
					end
					GaoZhanCtrl.Instance:FlushQualityFBIndex(index)
				end
				FuBenData.Instance:ClearFBDropInfo()
				ViewManager.Instance:Open(ViewName.FBFinishStarView, nil, "finish", {data = item_data_list, pass_time = fb_scene_info.pass_time, star = fb_scene_info.reward_flag, func = func})
				end, 3)
		end
		self.is_open_finish = true
	end

	if self.count_down == nil then
		local function diff_time_fun(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if fb_scene_info.is_pass == 0 and fb_scene_info.is_active_leave_fb == 0 then
					if not self.is_open_finish then
						GlobalTimerQuest:AddDelayTimer(function()
							FuBenData.Instance:ClearFBDropInfo()
							local capability = GameVoManager.Instance:GetMainRoleVo().capability
							PlayerPrefsUtil.SetInt("fubenquality_remind", capability)
							ViewManager.Instance:Open(ViewName.FBFailFinishView)
						end, 1)
					end
					self.is_open_finish = true
				end
				FuBenData.Instance:ClearFBDropInfo()
				FuBenCtrl.Instance:SendExitFBReq()
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
		end

		diff_time_fun(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_fun)
	end
end


function FuBenInfoQualityView:SetStarCountDown()
	local fb_scene_info = FuBenData.Instance:GetChallengeInfoList()
	if fb_scene_info == nil or not next(fb_scene_info) then return end
	local star_info = FuBenData.Instance:GetChallengStarInfo(fb_scene_info.level)

	self.cur_star = 0
	self.total_time = 0
	for i = 3, 1, -1 do
		if star_info and fb_scene_info.pass_time <= star_info[i] then
			self.cur_star = i
			self.total_time = star_info[i] - fb_scene_info.pass_time
			self.temp_time = self.total_time
			break
		end
	end

	if self.cur_star > 0 then
		for i = 1, 3 do
			if self.node_list["ImgStar" .. i] then
				UI:SetGraphicGrey(self.node_list["ImgStar" .. i], i > self.cur_star)
			end
		end
	end


	local function diff_time_fun(elapse_time, total_time)
		local left_time = math.floor(self.total_time - elapse_time + 0.5)
		local CountDownText = string.format(Language.ExpFuBen.GreenText, TimeUtil.FormatSecond(left_time, 2))
		local NextStar = self.cur_star - 1

		local star_text = self.cur_star <= 1 and string.format(Language.FuBen.StarFail, CountDownText) or string.format(Language.FuBen.NetStar, CountDownText, NextStar)
		if self.node_list["StarTxt"] and self.node_list["StarTxt"].text then
			self.node_list["StarTxt"].text.text = star_text
		end
		if self.cur_star > 0 then
			for i = 1, 3 do
				if self.node_list["ImgStar" .. i] then
					UI:SetGraphicGrey(self.node_list["ImgStar" .. i], i > self.cur_star)
				end
			end
		end
		if left_time <= 0 then
			if nil ~= self.star_count_down then
				CountDown.Instance:RemoveCountDown(self.star_count_down)
				self.star_count_down = nil
			end
			self.cur_star = self.cur_star - 1
			if self.cur_star > 0 then
				self.total_time = star_info[self.cur_star] - star_info[self.cur_star + 1]
			end
			
			if self.cur_star <= 1 then
				self.total_time = FuBenData.Instance:GetFuBenSceneLeftTime() or 0
			end
			for i = 1, 3 do
				if self.node_list["ImgStar" .. i] then
					UI:SetGraphicGrey(self.node_list["ImgStar" .. i], i > self.cur_star)
				end
			end
			self.star_count_down = CountDown.Instance:AddCountDown(self.total_time, 0.5, diff_time_fun)
		end
	end
	if self.star_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.star_count_down)
		self.star_count_down = nil
	end

	self.star_count_down = CountDown.Instance:AddCountDown(self.total_time, 0.5, diff_time_fun)
end

function FuBenInfoQualityView:SetQualityFBSceneData()
	local fb_scene_info = FuBenData.Instance:GetChallengeInfoList()
	if fb_scene_info == nil or not next(fb_scene_info) then return end
	local fb_cfg = FuBenData.Instance:GetChallengLayerCfgByLevelAndLayer(fb_scene_info.level, fb_scene_info.fight_layer)
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
	local total_layer = FuBenData.Instance:GetTotalLayerByLevel(fb_scene_info.level)
	local other_cfg = FuBenData.Instance:GetChallengOtherCfg()
	local effect_level = other_cfg and other_cfg.effect_show

	-- self.node_list["FBNameTxt"].text.text = fb_cfg.fb_name
	if fb_scene_info.fight_layer + 1 < total_layer then
		self.node_list["FBJinDuTxt"].text.text = string.format(Language.FuBen.JinDu, ToColorStr(fb_scene_info.fight_layer + 1, TEXT_COLOR.RED), total_layer)
	else
		self.node_list["FBJinDuTxt"].text.text = string.format(Language.FuBen.JinDu, ToColorStr(fb_scene_info.fight_layer + 1, TEXT_COLOR.GREEN), total_layer)
	end
	
	local capability = GameVoManager.Instance:GetMainRoleVo().capability
	local str_fight_power = string.format(Language.Mount.ShowGreenNum, fb_cfg.zhanli)
	if capability < fb_cfg.zhanli then
		str_fight_power = string.format(Language.Mount.ShowRedNum, fb_cfg.zhanli)
	end
	self.node_list["ZhanLiTxt"].text.text = string.format(Language.FuBen.RecommendCap, str_fight_power)

	local pass_layer_info = FuBenData.Instance:GetPassLayerInfo()
	if next(pass_layer_info) then
		if pass_layer_info.is_pass ~= 1 then
			self.node_list["JiBaiTxt"].text.text = string.format(Language.FuBen.KillNumber1, monster_cfg[fb_cfg.boss_id].name, ToColorStr(pass_layer_info.is_pass, TEXT_COLOR.RED), 1)
		else
			self.node_list["JiBaiTxt"].text.text = string.format(Language.FuBen.KillNumber1, monster_cfg[fb_cfg.boss_id].name, ToColorStr(pass_layer_info.is_pass, TEXT_COLOR.GREEN), 1)
		end
		
		if pass_layer_info.is_pass == 1 then
			if self.star_count_down ~= nil then
				CountDown.Instance:RemoveCountDown(self.star_count_down)
				self.star_count_down = nil
			end
		end
	end
	local new_fb_cfg = FuBenData.Instance:GetChallengCfgByLevel(fb_scene_info.level)
	if new_fb_cfg then
		for i,v in ipairs(self.item_list) do
			-- local equiment_quality = new_fb_cfg["item_quality" .. i] or 1
			local item_cfg = ItemData.Instance:GetItemConfig(tonumber(new_fb_cfg.item_list[i]))
			local equiment_quality = item_cfg and item_cfg.color or 1
			if new_fb_cfg.item_list[i] then
				self.item_list[i]:SetActive(true)
				self.item_list[i]:SetData({item_id = tonumber(new_fb_cfg.item_list[i])})
			else
				self.item_list[i]:SetData(nil)
				self.item_list[i]:SetActive(false)
			end
			-- self.item_list[i]:SetShowStar(new_fb_cfg.equiment_star)
			-- self.item_list[i]:SetQualityByColor(equiment_quality)
			local func = function()
				local item_data = {item_id = tonumber(new_fb_cfg.item_list[i])}
				TipsCtrl.Instance:OpenItem(item_data)
				-- GlobalTimerQuest:AddDelayTimer(function()
				-- 	TipsCtrl.Instance:SetQualityAndClor(equiment_quality)
				-- 	TipsCtrl.Instance:SetPropQualityAndClor(equiment_quality)
				-- 	TipsCtrl.Instance:SetOtherQualityAndClor(equiment_quality)
				-- 	end, 0.1)
			end
			self.item_list[i]:ShowEquipOrangeEffect(false)
			self.item_list[i]:ShowEquipRedEffect(false)
			self.item_list[i]:ShowEquipFenEffect(false)
			if effect_level ~= nil and tonumber(equiment_quality) ~= nil and equiment_quality >= effect_level then
				if equiment_quality == 4 then
					self.item_list[i]:ShowEquipOrangeEffect(true)
				elseif equiment_quality == 5 then
					self.item_list[i]:ShowEquipRedEffect(true)
				elseif equiment_quality == 6 then
					self.item_list[i]:ShowEquipFenEffect(true)
				end
			end
			self.item_list[i]:ShowHighLight(false)
			-- self.item_list[i]:ShowExtremeEffect(false)
			self.item_list[i]:ListenClick(func)
		end
	end
end

function FuBenInfoQualityView:SwitchButtonState(enable)
	self.node_list["TaskAnimator"]:SetActive(enable)
end

function FuBenInfoQualityView:OnFlush(param_t)
	if Scene.Instance:GetSceneType() == SceneType.ChallengeFB then
		MainUICtrl.Instance:SetViewState(false)
		self:SetQualityFBSceneData()
		self:SetCountDown()
		for k, v in pairs(param_t) do
			if k == "star_info" then
				self:SetStarCountDown()
			end
		end
	end
end

function FuBenInfoQualityView:OpenNextWaveCountDown()
	local end_time = FuBenData.Instance:GetPassLayerInfo()
	self.total_time_2 = math.floor(end_time.time_out_stamp - TimeCtrl.Instance:GetServerTime())
		local function diff_time_fun(elapse_time, total_time)
			local left_time = math.floor(total_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.next_countdown ~= nil then
					CountDown.Instance:RemoveCountDown(self.next_countdown)
					self.next_countdown = nil
				end
				if self.node_list then
					self.node_list["EndTime"]:SetActive(false)
				end
				return
			else
				if self.node_list then
					self.node_list["EndTime"]:SetActive(true)
					self.node_list["EndTime"].text.text = TimeUtil.FormatSecond(left_time, 2)
				end
			end
		end
	self.next_countdown = CountDown.Instance:AddCountDown(self.total_time_2, 0.5, diff_time_fun)
end