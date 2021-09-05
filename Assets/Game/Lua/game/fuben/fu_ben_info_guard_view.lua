FuBenInfoGuardView = FuBenInfoGuardView or BaseClass(BaseView)

function FuBenInfoGuardView:__init()
	self.ui_config = {{"uis/views/fubenview_prefab", "GuardFBInFoView"}}
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE,
		BindTool.Bind(self.Flush, self))

	self.active_close = false
	self.fight_info_view = true
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true						-- IphoneX适配
	self.out_time = 0
end

function FuBenInfoGuardView:LoadCallBack()

	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,BindTool.Bind(self.SwitchButtonState, self))
	self.main_role_revive = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_REALIVE, BindTool.Bind(self.MainRoleRevive, self))

	self.node_list["ButtonOpenTeam"].button:AddClickListener(BindTool.Bind(self.OnClickRefresh, self))
	self.node_list["AutoToggle"].toggle:AddClickListener(BindTool.Bind(self.OnToggleChange, self))

end

function FuBenInfoGuardView:__delete()
	if self.main_view_complete ~= nil then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end
end

function FuBenInfoGuardView:ReleaseCallBack()
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	if self.main_role_revive ~= nil then
		GlobalEventSystem:UnBind(self.main_role_revive)
		self.main_role_revive = nil
	end

	self.out_time = 0
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function FuBenInfoGuardView:OpenCallBack()
	self.node_list["AutoToggle"].toggle.isOn = true
	self:Flush()
end

function FuBenInfoGuardView:CloseCallBack()

end

function FuBenInfoGuardView:OnClickRefresh()
	FuBenCtrl.SendTowerDefendNextWave()
end


function FuBenInfoGuardView:OnToggleChange(is_on)
	if self.node_list["AutoToggle"].toggle.isOn then
		FuBenCtrl.SendTowerDefendNextWave()
	end
end

function FuBenInfoGuardView:SwitchButtonState(enable)
	self.node_list["PanelInfo"]:SetActive( enable)
end

function FuBenInfoGuardView:MainRoleRevive()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end

	if self.delay_time == nil then
		-- 延迟是因为主角复活后有可能坐标还没有reset
		self.delay_time = GlobalTimerQuest:AddDelayTimer(function() GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto) end, 0.5)
	end
end

function FuBenInfoGuardView:OnFlush(param_t)
	local info = FuBenData.Instance:GetTowerDefendInfo()
	if nil == next(info) then return end
	-- local cur_level = FuBenData.Instance:GetArmorSelectLevel()
	local cfg = FuBenData.Instance:GetTowerWaveCfg(info.curr_level)
	local curr_wave = info.curr_wave >= #cfg - 1 and ToColorStr(info.curr_wave + 1, TEXT_COLOR.GREEN) or ToColorStr(info.curr_wave + 1, TEXT_COLOR.RED)

	self.node_list["TextWave1"].text.text = string.format(Language.FuBen.CurWaveNumber, curr_wave, #cfg)
	local clear_wave_count = info.clear_wave_count >= #cfg and ToColorStr(info.clear_wave_count, TEXT_COLOR.GREEN) or ToColorStr(info.clear_wave_count, TEXT_COLOR.RED)
	self.node_list["TextWave2"].text.text = string.format(Language.FuBen.KillWaveNumber, clear_wave_count .. " / " .. #cfg)

	local pro = info.life_tower_left_hp / info.life_tower_left_maxhp
	self.node_list["ProgressBg"].slider.value = pro
	local pro_txt = math.ceil(pro * 100) .. "%"
	self.node_list["PropTxt"].text.text = pro_txt
	self.out_time = info.next_wave_refresh_time
	if nil == self.timer_quest then
		self:TimerCallback()
		self.timer_quest = GlobalTimerQuest:AddRunQuest(function() self:TimerCallback() end, 1)
	end
	if self.node_list["AutoToggle"].toggle.isOn and info.curr_wave + 1 == info.clear_wave_count and info.curr_wave + 1 < #cfg then
		FuBenCtrl.SendTowerDefendNextWave()
	end
end

function FuBenInfoGuardView:TimerCallback()
	local time = math.max(self.out_time - TimeCtrl.Instance:GetServerTime(), 0)
	if time > 3600 then
		self.node_list["TextWave3"].text.text = string.format(Language.FuBen.NextTime,TimeUtil.FormatSecond(time, 1) )
	else
		self.node_list["TextWave3"].text.text = string.format(Language.FuBen.NextTime,TimeUtil.FormatSecond(time, 2) )
	end
	if time <= 0 then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end