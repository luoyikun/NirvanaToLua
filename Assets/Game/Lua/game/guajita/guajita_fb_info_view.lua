GuajiTaFbInfoView = GuajiTaFbInfoView or BaseClass(BaseView)

local RuneNomal = 0 			--正常奖励
local RuneType = 1 				--开启的符文类型
local RuneSlot = 2 				--开启的符文槽
local RuneLevel = 3 			--开启的符文等级
function GuajiTaFbInfoView:__init()
	self.ui_config = {{"uis/views/guajitaview_prefab", "GuajiTaFbInfoView"}}

	self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER,
		BindTool.Bind(self.OnChangeScene, self))
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE,
		BindTool.Bind(self.Flush, self))

	self.item_data = {}
	self.item_cells = {}
	self.temp_level = nil
	self.temp_change_level = nil
	self.is_first_open = true
	self.is_open_finish = false
	self.active_close = false
	self.fight_info_view = true
	self.upgrade_timer_quest = nil
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.is_show = false
	self.pass_layer = 0
end

function GuajiTaFbInfoView:LoadCallBack()

	for i = 1, 3 do
		self.item_cells[i] = ItemCell.New()
		self.item_cells[i]:SetInstanceParent(self.node_list["Item"..i])
	end

	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))

	self.node_list["FuwenImg"].button:AddClickListener(BindTool.Bind(self.ShowPanelOpenItem, self))
end

function GuajiTaFbInfoView:ReleaseCallBack()
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	for k, v in pairs(self.item_cells) do
		v:DeleteMe()
	end
	self.item_cells = {}
	self.is_show = nil 
	self.pass_layer = 0
end

function GuajiTaFbInfoView:__delete()
	self.item_data = nil
	self.fail_data = nil
	self:RemoveDelayTime()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	for k, v in pairs(self.item_cells) do
		v:DeleteMe()
	end
	self.item_cells = {}

	self.temp_level = nil
	self.temp_change_level = nil
	self.is_first_open = nil
	self.is_open_finish = nil

	if self.scene_load_enter ~= nil then
		GlobalEventSystem:UnBind(self.scene_load_enter)
		self.scene_load_enter = nil
	end
	if self.main_view_complete ~= nil then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end
	self.pass_layer = 0
end

function GuajiTaFbInfoView:ShowPanelOpenItem()
	TipsCtrl.Instance:OpenItem(self.panel_show_data)
end

function GuajiTaFbInfoView:OpenCallBack()
	self.is_open_finish = false
	self:Flush()
	self.node_list["Effect"]:SetActive(false)
	local fb_info = GuaJiTaData.Instance:GetRuneTowerInfo()
	if fb_info.pass_layer then
		local special_level_cfg = GuaJiTaData.Instance:GetSpecialRewardCfg(fb_info.pass_layer + 1)
		if special_level_cfg then
			self.node_list["Effect"]:SetActive(true)
		end
	end
end

function GuajiTaFbInfoView:CloseCallBack()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.temp_level = nil
end

function GuajiTaFbInfoView:OnChangeScene()
	if Scene.Instance:GetSceneType() == SceneType.RuneTower then
		self.is_first_open = true
	end
end

function GuajiTaFbInfoView:RemoveDelayTime()
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
end

function GuajiTaFbInfoView:SetCountDown()
	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
	if nil == fb_scene_info or fb_scene_info == "" or next(fb_scene_info) == nil then return end
	local fb_info = GuaJiTaData.Instance:GetRuneTowerInfo()
	local role_hp = GameVoManager.Instance:GetMainRoleVo().hp
	local diff_time = 0
	if fb_scene_info.is_finish == 1 and fb_scene_info.is_pass == 0 then -- role_hp <= 0 and
		if self.count_down ~= nil then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		if not self.is_open_finish then
			if ViewManager.Instance:IsOpen(ViewName.CommonTips) then
				ViewManager.Instance:Close(ViewName.CommonTips)
			end
			-- GlobalTimerQuest:AddDelayTimer(function()
			-- 	ViewManager.Instance:Open(ViewName.FBFailFinishView)
			-- end, 2)
		end
		self.is_open_finish = true
		return
	end
	diff_time = fb_scene_info.time_out_stamp - TimeCtrl.Instance:GetServerTime()
	if fb_info.fb_today_layer and fb_scene_info.is_finish == 1 and ((fb_info.fb_today_layer + 1) <= GuaJiTaData.Instance:GetRuneMaxLayer()) and fb_scene_info.is_pass == 1 then
		if ViewManager.Instance:IsOpen(ViewName.RuneTowerFbInfoView) then
			diff_time = 15
			if self.count_down ~= nil then
				CountDown.Instance:RemoveCountDown(self.count_down)
				self.count_down = nil
			end

			local no_func = function ()
				FuBenCtrl.Instance:SendExitFBReq()
			end
			local func = function ()
				FuBenCtrl.Instance:SendEnterNextFBReq()
			end

			if not self.is_first_open then
				if self.upgrade_timer_quest == nil then
					self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(function()
						local special_level_cfg = GuaJiTaData.Instance:GetSpecialRewardCfg(fb_info.fb_today_layer)
						local rune_reward_list = RuneData.Instance:GetRunePassRewardInfo()
						
						if fb_info.pass_layer <= fb_info.fb_today_layer and special_level_cfg then
							GuaJiTaCtrl.Instance:OpenRuneTowerUnlockView(special_level_cfg)
						else
							TipsCtrl.Instance:TipsPaTaRewardView(no_func, func, rune_reward_list)
						end
						self:RemoveDelayTime()
					end, 1)
				end
			else
				diff_time = fb_scene_info.time_out_stamp - TimeCtrl.Instance:GetServerTime()
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
			end
		else
			if ViewManager.Instance:IsOpen(ViewName.CommonTips) then
				ViewManager.Instance:Close(ViewName.CommonTips)
			end
		end
		return
	elseif fb_info.fb_today_layer and (fb_info.fb_today_layer + 1) > GuaJiTaData.Instance:GetRuneMaxLayer() then
		diff_time = 15
		if self.count_down ~= nil then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		if not self.is_open_finish then
			if ViewManager.Instance:IsOpen(ViewName.CommonTips) then
				ViewManager.Instance:Close(ViewName.CommonTips)
			end
			ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "finish", {data = self.item_data})
		end
		self.is_open_finish = true
		return
	end

	if self.count_down == nil and fb_scene_info.time_out_stamp ~= 0 then
		local function diff_time_fun(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if fb_scene_info.is_pass == 0 then
					if not self.is_open_finish then
						-- GlobalTimerQuest:AddDelayTimer(function()
						-- 	ViewManager.Instance:Open(ViewName.FBFailFinishView)
						-- end, 2)
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

		diff_time_fun(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_fun)
	end

	if next(fb_info) and fb_scene_info.is_finish then
		self.is_first_open = false
	end
end

function GuajiTaFbInfoView:SetTowerFBSceneData()
	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
	local tower_fb_info = GuaJiTaData.Instance:GetRuneTowerInfo()
	local fuben_cfg = GuaJiTaData.Instance:GetRuneTowerFBLevelCfg()
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
	if fb_scene_info == nil and fb_scene_info ~= "" and tower_fb_info ~= "" and fuben_cfg ~= "" and monster_cfg ~= "" then return end

	if fb_scene_info.is_finish == 1 then
		if self.is_first_open then
			if ViewManager.Instance:IsOpen(ViewName.CommonTips) then
				ViewManager.Instance:Close(ViewName.CommonTips)
			end
			FuBenCtrl.Instance:SendEnterNextFBReq()
		end
		local max_layer = GuaJiTaData.Instance:GetRuneMaxLayer()
		-- local today_pass = tower_fb_info.fb_today_layer == max_layer and tower_fb_info.fb_today_layer or tower_fb_info.fb_today_layer + 1
		local today_pass = tower_fb_info.fb_today_layer
		if fuben_cfg[today_pass] then
			local monster_name =  monster_cfg[fuben_cfg[today_pass].monster_id].name --保持任务完成后名字不变
			local kill_monster = fb_scene_info.kill_allmonster_num or 0
			local total_monster = fb_scene_info.total_allmonster_num or 0
			kill_monster = kill_monster < total_monster and ToColorStr(kill_monster, TEXT_COLOR.RED) or kill_monster
			self.node_list["KillText"].text.text = string.format(Language.FuBen.KillNumShow, monster_name, kill_monster, total_monster)
		end
		return
	end

	if tower_fb_info and next(tower_fb_info) ~= nil then
		local temp_td_level = tower_fb_info.fb_today_layer + 1
		-- local temp_level_str = ""
		-- for s in string.gmatch(temp_td_level, "%d") do
		-- 	temp_level_str = temp_level_str..s.."\n"
		-- end
		-- local name_str = string.format(Language.FB.CurLevel, temp_td_level)
		self.node_list["FbName"].text.text = temp_td_level

		local capability = GameVoManager.Instance:GetMainRoleVo().capability
		local str_fight_power = string.format(Language.Mount.ShowGreenStr, fuben_cfg[tower_fb_info.fb_today_layer + 1].capability)
		if capability < fuben_cfg[tower_fb_info.fb_today_layer + 1].capability then
			str_fight_power = string.format(ToColorStr(fuben_cfg[tower_fb_info.fb_today_layer + 1].capability, TEXT_COLOR.RED))
		end
		self.node_list["Capability"].text.text =  string.format(Language.Boss.RecommendCap, str_fight_power)

		if self.temp_change_level and self.temp_change_level ~= tower_fb_info.fb_today_layer then
			GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
		end

		local monster_name = monster_cfg[fuben_cfg[tower_fb_info.fb_today_layer + 1].monster_id].name
		local kill_monster = fb_scene_info.kill_allmonster_num or 0
		local total_monster = fb_scene_info.total_allmonster_num or 0
		kill_monster = kill_monster < total_monster and ToColorStr(kill_monster, TEXT_COLOR.RED) or kill_monster
		self.node_list["KillText"].text.text = string.format(Language.FuBen.KillNumShow, monster_name, kill_monster, total_monster)

		local is_show_jinghua = true
		local first_reward = Language.FB.FirstReward
		local first_reward_cfg = fuben_cfg[tower_fb_info.fb_today_layer + 1].first_reward_item
		if fuben_cfg[tower_fb_info.fb_today_layer + 1].sp_type == RuneType then
			first_reward = Language.Rune.UnLockText1
			local sp_show = fuben_cfg[tower_fb_info.fb_today_layer + 1].sp_show
			first_reward_cfg = {}
			sp_show = Split(sp_show, "#")
			for k, v in ipairs(sp_show) do
				first_reward_cfg[k - 1] = {item_id = tonumber(v)}
			end
			is_show_jinghua = false
		end

		local str = (fb_scene_info.param1 and fb_scene_info.param1 > 0) and first_reward or Language.FB.NormalReward
		self.node_list["TongGuanDesc"].text.text =  "【" .. str .. "】"
		local reward_cfg = first_reward_cfg -- fb_scene_info.param1 > 0 and first_reward_cfg --fuben_cfg[tower_fb_info.fb_today_layer + 1].first_reward_item
							--or fuben_cfg[tower_fb_info.fb_today_layer + 1].normal_reward_item
		local reward_count = 0
		self.item_data = {}
		for k, v in pairs(self.item_cells) do
			self.node_list["Item"..k]:SetActive(false)
			v:SetActive(false)
			if reward_cfg[k - 1] and reward_cfg[k - 1].item_id > 0 then
				reward_count = reward_count + 1
				v:SetActive(true)
				self.node_list["Item"..k]:SetActive(true)
				v:SetData(reward_cfg[k - 1])
				self.item_data[k] = reward_cfg[k - 1]
			end
		end
		if self.item_cells[reward_count + 1] then
			local exp_num = fuben_cfg[tower_fb_info.fb_today_layer + 1].first_reward_rune_exp  --fb_scene_info.param1 > 0 and fuben_cfg[tower_fb_info.fb_today_layer + 1].first_reward_rune_exp or fuben_cfg[tower_fb_info.fb_today_layer + 1].normal_reward_rune_exp
			local data = {item_id = ResPath.CurrencyToIconId.rune_jinghua, num = exp_num}
			-- self.item_cells[reward_count + 1]:SetActive(true)
			self.item_cells[reward_count + 1]:SetActive(is_show_jinghua)
			self.node_list["Item".. (reward_count + 1)]:SetActive(is_show_jinghua)
			self.item_cells[reward_count + 1]:SetData(data)
			self.item_data[reward_count + 1] = data
		end
		self.temp_change_level = tower_fb_info.fb_today_layer
	end
	local fb_info = GuaJiTaData.Instance:GetRuneTowerInfo()
		if fb_info.pass_layer ~= self.pass_layer then
			if fb_info.pass_layer then
				local special_level_cfg = GuaJiTaData.Instance:GetSpecialRewardCfg(fb_info.pass_layer + 1)
				if special_level_cfg then
					GuaJiTaCtrl.Instance:SetCanMove(false)
					GuaJiTaCtrl.Instance:OpenRuneJieSuoView(special_level_cfg)
				end
			end
		end
	self.pass_layer = GuaJiTaData.Instance:GetRuneTowerInfo().pass_layer

	self.node_list["Tiltlefuwen"]:SetActive(false)
	self.node_list["Itemslist"]:SetActive(true)
	local fb_info = GuaJiTaData.Instance:GetRuneTowerInfo()
	if fb_info.pass_layer then
		local special_level_cfg = GuaJiTaData.Instance:GetSpecialRewardCfg(fb_info.pass_layer + 1)
		if special_level_cfg then
			self.node_list["Tiltlefuwen"]:SetActive(true)
			self.node_list["Effect"]:SetActive(true)
			self.node_list["Itemslist"]:SetActive(false)
			if special_level_cfg.sp_type == GuaJiTaData.SP_TYPE.TYPE then
				local bundle, asset = ResPath.GetItemIcon(special_level_cfg.panel_show)
				self.node_list["FuwenImg"].image:LoadSprite(bundle, asset, function()
					self.node_list["FuwenImg"].image:SetNativeSize()
					end)
				self.node_list["FuwenImg"].button.interactable = true
				self.panel_show_data = {item_id = special_level_cfg.panel_show}
			elseif special_level_cfg.sp_type == GuaJiTaData.SP_TYPE.SLOT then
				self.node_list["FuwenImg"].image:LoadSprite("uis/views/guajitaview/images_atlas", "img_open_slot", function()
					self.node_list["FuwenImg"].image:SetNativeSize()
					end)
				self.node_list["FuwenImg"].button.interactable = false
			elseif special_level_cfg.sp_type == GuaJiTaData.SP_TYPE.LV then
				self.node_list["FuwenImg"].image:LoadSprite("uis/views/guajitaview/images_atlas", "img_uplevel", function()
					self.node_list["FuwenImg"].image:SetNativeSize()
					end)
				self.node_list["FuwenImg"].button.interactable = false
			end
		else
			self.is_show = false
			self.node_list["Effect"]:SetActive(false)
		end
	end
	if not self.is_show then
		self.node_list["FuwenImg"]:SetActive(false)
	end
end

function GuajiTaFbInfoView:FuwenImgState(is_show)
	self.is_show = is_show
	self.node_list["FuwenImg"]:SetActive(is_show)
end

function GuajiTaFbInfoView:SwitchButtonState(enable)
	self.node_list["PanelInfo"]:SetActive(enable)
end

function GuajiTaFbInfoView:OnFlush(param_t)
	if Scene.Instance:GetSceneType() == SceneType.RuneTower then
		MainUICtrl.Instance:SetViewState(false)
		self:SetTowerFBSceneData()
		self:SetCountDown()
	end
end