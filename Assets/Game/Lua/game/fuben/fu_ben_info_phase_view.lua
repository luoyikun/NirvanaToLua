FuBenInfoPhaseView = FuBenInfoPhaseView or BaseClass(BaseView)

function FuBenInfoPhaseView:__init()
	self.ui_config = {{"uis/views/fubenview_prefab", "PhaseFBInFoView"}}
	self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER,
		BindTool.Bind(self.OnChangeScene, self))
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE,
		BindTool.Bind(self.Flush, self))
	self.item_data = {}
	self.fail_data = {}
	self.rewards = {}
	self.is_first_open = true
	self.is_open_finish = false
	self.active_close = false
	self.fight_info_view = true
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true						-- IphoneX适配
end

function FuBenInfoPhaseView:LoadCallBack()
	for i = 1, 3 do
		self.rewards[i] = ItemCell.New()
		self.rewards[i]:SetInstanceParent(self.node_list["Item"..i])
	end
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
	self:Flush()
end

function FuBenInfoPhaseView:__delete()
	self.item_data = {}
	self.fail_data = {}
	for k, v in pairs(self.rewards) do
		v:DeleteMe()
	end
	self.rewards = {}
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.is_first_open = nil
	self.is_open_finish = nil

	if self.main_view_complete ~= nil then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end
	if self.scene_load_enter ~= nil then
		GlobalEventSystem:UnBind(self.scene_load_enter)
		self.scene_load_enter = nil
	end
end

function FuBenInfoPhaseView:ReleaseCallBack()

	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	for k, v in pairs(self.rewards) do
		v:DeleteMe()
	end
	self.rewards = {}
end



function FuBenInfoPhaseView:OnChangeScene()
	if Scene.Instance:GetSceneType() == SceneType.PhaseFb then
		-- print("执行了 FuBenInFoView:OnChangeScene  ####", Scene.Instance:GetSceneType())
		FuBenCtrl.Instance:SendGetPhaseFBInfoReq(PHASE_FB_OPERATE_TYPE.PHASE_FB_OPERATE_TYPE_INFO)
	end
end



function FuBenInfoPhaseView:OpenCallBack()
	self.is_first_open = true
	self.is_open_finish = false
	self:Flush()
end

function FuBenInfoPhaseView:CloseCallBack()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
end

function FuBenInfoPhaseView:SetCountDown()
	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
	local role_hp = GameVoManager.Instance:GetMainRoleVo().hp

	if nil == fb_scene_info or nil == next(fb_scene_info) then return end

	local diff_time = nil
	if role_hp <= 0 and fb_scene_info.is_finish == 1 then
		if self.count_down ~= nil then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		if not self.is_open_finish then
			if ViewManager.Instance:IsOpen(ViewName.CommonTips) then
				ViewManager.Instance:Close(ViewName.CommonTips)
			end
			GlobalTimerQuest:AddDelayTimer(function()
				ViewManager.Instance:Open(ViewName.FBFailFinishView)
			end, 2)
		end
		self.is_open_finish = true
		return
	end
	if fb_scene_info.is_pass == 1 then
		if self.count_down ~= nil then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		diff_time = 7
		if not self.is_open_finish then
			if ViewManager.Instance:IsOpen(ViewName.CommonTips) then
				ViewManager.Instance:Close(ViewName.CommonTips)
			end
			if not self.upgrade_timer_quest then
				self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(function()
					ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "finish", {data = self.item_data, leave_time = 2})
				end, 1)
			end
		end
		self.is_open_finish = true
	else
		diff_time = fb_scene_info.time_out_stamp - TimeCtrl.Instance:GetServerTime()
	end
	if self.count_down == nil then
		local function diff_time_func (elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if fb_scene_info.is_pass == 0 then
					if not self.is_open_finish then
						if ViewManager.Instance:IsOpen(ViewName.CommonTips) then
							ViewManager.Instance:Close(ViewName.CommonTips)
						end
						GlobalTimerQuest:AddDelayTimer(function()
							ViewManager.Instance:Open(ViewName.FBFailFinishView)
						end, 2)
					end
					self.is_open_finish = true
				else
					FuBenCtrl.Instance:SendExitFBReq()
				end
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

function FuBenInfoPhaseView:SetPhaseFBSceneData()
	MainUICtrl.Instance:SetViewState(false)

	self.node_list["FBNameTxt"].text.text = Scene.Instance:GetSceneName()

	-- local index = PlayerPrefsUtil.GetInt("phaseindex")
	-- local fuben_cfg = FuBenData.Instance:GetCurFbCfgByIndex(index)

	local layer = FuBenData.Instance:GetSelectLayer() or 1
	local cur_page = FuBenData.Instance:GetSelectCurPage() or 1
	local fuben_cfg = FuBenData.Instance:GetCurFbCfgByIndex(layer - 1, cur_page)
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
	local monster_name =""
	local boss_name = ""
	if fuben_cfg and monster_cfg then
		if monster_cfg[fuben_cfg.monster_id1].type == 0 then
			monster_name = monster_cfg[fuben_cfg.monster_id1].name
			boss_name = monster_cfg[fuben_cfg.monster_id2].name
			self.node_list["JiBaiTxt1"].text.text = string.format(Language.FuBen.KillNumber1, monster_name, "", "")
			self.node_list["JiBaiTxt2"].text.text = string.format(Language.FuBen.KillNumber2, boss_name, "", "")
		else

			monster_name = monster_cfg[fuben_cfg.monster_id2].name
			boss_name = monster_cfg[fuben_cfg.monster_id1].name
			self.node_list["JiBaiTxt1"].text.text = string.format(Language.FuBen.KillNumber1, monster_name, "", "")
			self.node_list["JiBaiTxt2"].text.text = string.format(Language.FuBen.KillNumber2, boss_name, "", "")
		end

		local phase_fb_info = FuBenData.Instance:GetPhaseFBInfo()
		if phase_fb_info and next(phase_fb_info) and fuben_cfg then
			local reward = (phase_fb_info[layer - 1].is_pass + 1 >= cur_page) and fuben_cfg.first_reward or fuben_cfg.reset_reward
			local tongguandes = (phase_fb_info[layer - 1].is_pass + 1 >= cur_page) and Language.FB.FirstReward or Language.FB.NormalReward
			self.node_list["TongGuanDesTxt"].text.text = string.format(Language.FuBen.TongGuanDes, tongguandes)
			if self.is_first_open then
				local is_set_exp = false
				for k, v in pairs(self.rewards) do
					if reward[k - 1] then
						v:SetData(reward[k - 1])
						self.item_data[k] = reward[k - 1]
						v:SetParentActive(true)
					else
						v:SetParentActive(false)
						if not is_set_exp then
							local data = {item_id = FuBenDataExpItemId.ItemId, num = fuben_cfg.reward_exp}
							if fuben_cfg.reward_exp > 0 then
								v:SetData(data)
								self.item_data[k] = data
								is_set_exp = true
								v:SetParentActive(true)
							end
						end
					end
				end
			end
			self.is_first_open = false
		end
	end

	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
	if fb_scene_info and next(fb_scene_info) then
		local killmonster = fb_scene_info.kill_allmonster_num - fb_scene_info.kill_boss_num
		local totalmonster = fb_scene_info.total_allmonster_num - fb_scene_info.total_boss_num
		local killboss = fb_scene_info.kill_boss_num
		local totalboss = fb_scene_info.total_boss_num
		local monster_num = killmonster < totalmonster and string.format("（%s / %s）", ToColorStr(killmonster, TEXT_COLOR.RED), totalmonster) or string.format("（%s / %s）", killmonster, totalmonster)
		local boss_num = killboss < totalboss and string.format("（%s / %s）", ToColorStr(killboss, TEXT_COLOR.RED), totalboss) or string.format("（%s / %s）", killboss, totalboss)
		self.node_list["JiBaiTxt1"].text.text = string.format(Language.FuBen.KillNumber3, monster_name, monster_num)
		self.node_list["JiBaiTxt2"].text.text = string.format(Language.FuBen.KillNumber3, boss_name, boss_num)
	end
end

function FuBenInfoPhaseView:SwitchButtonState(enable)
	self.node_list["ShowPanel"]:SetActive(enable)
end

function FuBenInfoPhaseView:OnFlush(param_t)
	if Scene.Instance:GetSceneType() == SceneType.PhaseFb and self:IsOpen() then
		self:SetPhaseFBSceneData()
		self:SetCountDown()
	end
end