FuBenInfoTeamSpecialView = FuBenInfoTeamSpecialView or BaseClass(BaseView)

function FuBenInfoTeamSpecialView:__init()
	self.ui_config = {{"uis/views/fubenview_prefab", "TeamSpecialFBInfoView"}}

	self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER,
		BindTool.Bind(self.OnChangeScene, self))
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE,
		BindTool.Bind(self.Flush, self))
	self.item_data = {}
	self.rewards = {}
	self.is_open_finish = false
	self.fight_info_view = true
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.personal_or_team = 1
end

function FuBenInfoTeamSpecialView:LoadCallBack()
	for i = 1, 3 do
		self.rewards[i] = ItemCell.New()
		self.rewards[i]:SetInstanceParent(self.node_list["Item"..i])
	end

	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
	self:Flush()
end

function FuBenInfoTeamSpecialView:__delete()
	self.item_data = {}
	for k, v in pairs(self.rewards) do
		v:DeleteMe()
	end
	self.rewards = {}
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
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

function FuBenInfoTeamSpecialView:ReleaseCallBack()
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end

	for k, v in pairs(self.rewards) do
		v:DeleteMe()
	end
	self.rewards = {}
end

function FuBenInfoTeamSpecialView:OnChangeScene()
	if Scene.Instance:GetSceneType() == SceneType.TeamSpecialFb then
		print("执行了 FuBenInFoView:OnChangeScene  ####", Scene.Instance:GetSceneType())
		-- FuBenCtrl.Instance:SendGetPhaseFBInfoReq()
	end
end

function FuBenInfoTeamSpecialView:OpenCallBack()
	self.is_open_finish = false
	self:Flush()
end

function FuBenInfoTeamSpecialView:CloseCallBack()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
	if self.obj_del_event ~= nil then
		GlobalEventSystem:UnBind(self.obj_del_event)
		self.obj_del_event = nil
	end
end

function FuBenInfoTeamSpecialView:SetCountDown()
	local fb_info = FuBenData.Instance:GetFBSceneLogicInfo()
	if nil == fb_info or nil == next(fb_info) then return end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if ViewManager.Instance:IsOpen(ViewName.CommonTips) then
		ViewManager.Instance:Close(ViewName.CommonTips)
	end
	-- local call_back = function ()
		if not self.upgrade_timer_quest then
			self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(function()
				ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "finish", {data = self.item_data})
			end, 2)
		end
	-- end
	-- TimeScaleService.StartTimeScale(call_back)
end

function FuBenInfoTeamSpecialView:SetPhaseFBSceneData()

	local len_cfg = FuBenData.Instance:GetTeamSpecialCfglen()
	local scene_id = Scene.Instance:GetSceneId() or 0
	FuBenData.Instance:SetLastLayerId(scene_id)
	local scene_cfg = FuBenData.Instance:GetTeamSpecialCfg(self.personal_or_team, scene_id)
	if scene_cfg == nil then
		return
	end
	local show_layer = scene_cfg.show_layer >= len_cfg and ToColorStr(scene_cfg.show_layer, TEXT_COLOR.GREEN) or ToColorStr(scene_cfg.show_layer, TEXT_COLOR.RED)
	local str = string.format(show_layer  .. ToColorStr((" / " .. len_cfg), TEXT_COLOR.GREEN))
	self.node_list["TextCustomsPass"].text.text = str

	for k, v in pairs(self.rewards) do
		local data = scene_cfg.drop_items[k - 1]
		v:SetData(data)
		self.item_data[k] = data
	end
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
	local fb_info = FuBenData.Instance:GetFBSceneLogicInfo()
	if fb_info and next(fb_info) then
		local total_monster = fb_info.total_allmonster_num - fb_info.total_boss_num
		local total_kill_monster = fb_info.kill_allmonster_num - fb_info.kill_boss_num
		local total_kill = total_kill_monster >= total_monster and total_kill_monster or ToColorStr(total_kill_monster, TEXT_COLOR.RED)
		local str1 = string.format(Language.FuBen.KillNumber1, monster_cfg[scene_cfg.monster_id].name, total_kill, total_monster)
		local kill_boss_num = fb_info.kill_boss_num >= fb_info.total_boss_num and fb_info.kill_boss_num or ToColorStr(fb_info.kill_boss_num, TEXT_COLOR.RED)
		local str2 = string.format(Language.FuBen.KillNumber2, monster_cfg[scene_cfg.boss_id].name, kill_boss_num, fb_info.total_boss_num)	
		self.node_list["JiBaiTxt1"].text.text = str1
		self.node_list["JiBaiTxt2"].text.text = str2
	end
end

function FuBenInfoTeamSpecialView:SwitchButtonState(enable)
	self.node_list["ShowPanel"]:SetActive(enable)
end

function FuBenInfoTeamSpecialView:OnFlush(param_t)
	if self:IsOpen() then
		self:SetPhaseFBSceneData()
		-- self:SetCountDown()
	end
end