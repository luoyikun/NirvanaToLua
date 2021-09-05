SinglePartyInfoGuardView = SinglePartyInfoGuardView or BaseClass(BaseView)

local MOVE_TIME = 0.2

function SinglePartyInfoGuardView:__init()
	self.ui_config = {{"uis/views/festivalactivity/childpanel_prefab", "SinglePartyInFoView"},}


	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE,
		BindTool.Bind(self.Flush, self))
	self.is_show_content = true
	self.active_close = false
	self.fight_info_view = true
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.out_time = 0
end

function SinglePartyInfoGuardView:LoadCallBack()
	-- self.cur_count = self:FindVariable("CurCunt")
	-- self.kill_count = self:FindVariable("KillCount")
	-- self.next_time = self:FindVariable("NextTime")
	-- self.progess = self:FindVariable("Progress")
	-- self.pre_txt = self:FindVariable("ProTxt")
	-- self.auto_toggle = self:FindObj("AutoToggle")

	-- self.show_panel = true
	-- self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
	-- 	BindTool.Bind(self.SwitchButtonState, self))
	self.node_list["Button"].button:AddClickListener(BindTool.Bind(self.OnClickRefresh, self))
	self.node_list["ShrinkButton"].button:AddClickListener(BindTool.Bind(self.SwitchButtonState, self))
	self.progess = ProgressBar.New(self.node_list["Progress"])
	-- self.progess:SetValue(1)
	-- self:ListenEvent("OnToggleChange",BindTool.Bind(self.OnToggleChange, self))
end

function SinglePartyInfoGuardView:__delete()
	if self.main_view_complete ~= nil then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end
	
end

function SinglePartyInfoGuardView:ReleaseCallBack()
	-- if self.show_or_hide_other_button ~= nil then
	-- 	GlobalEventSystem:UnBind(self.show_or_hide_other_button)
	-- 	self.show_or_hide_other_button = nil
	-- end
	-- self.cur_count = nil
	-- self.kill_count = nil
	-- self.next_time = nil
	-- self.progess = nil
	-- self.pre_txt = nil
	-- -- self.show_panel = nil
	-- self.auto_toggle = nil
	if self.progess ~= nil then
		self.progess:DeleteMe()
		self.progess = nil
	end
	self.out_time = 0
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function SinglePartyInfoGuardView:OpenCallBack()
	self:Flush()
end

function SinglePartyInfoGuardView:CloseCallBack()

end

function SinglePartyInfoGuardView:OnClickRefresh()
	FestivalSinglePartyCtrl.Instance:SendHolidayGuardRoleReq(HOLIDAI_GUARD_REQ.HOLIDAY_GUARD_NEXT_WAVE)
end


function SinglePartyInfoGuardView:OnToggleChange(is_on)

end

function SinglePartyInfoGuardView:SwitchButtonState()
	-- self.node_list["Content"].gameObject:SetActive(enable)
	local pos = self.node_list["Content"].transform.anchoredPosition
	if self.is_show_content then
		UITween.MoveToShowPanel(self.node_list["Content"], pos, Vector3(-238, pos.y, pos.z), MOVE_TIME)
    else
    	UITween.MoveToShowPanel(self.node_list["Content"], pos, Vector3(42, pos.y, pos.z), MOVE_TIME)
    end
    self.node_list["Arrow"].transform:Rotate(0, 0, 180)
    self.is_show_content = not self.is_show_content
end

function SinglePartyInfoGuardView:OnFlush(param_t)
	local info = FestivalSinglePartyData.Instance:GetSinglePartyDefendInfo()
	if nil == next(info) then return end
	local wave_cfg = FestivalSinglePartyData.Instance:GetSinglePartyWaveCfg()
	if wave_cfg == nil then return end
	self.node_list["CurCunt"].text.text = string.format(Language.SingleParty.CurWave, info.curr_wave + 1 .. "/" .. #wave_cfg) 
	self.node_list["KillCount"].text.text = string.format(Language.SingleParty.KillCount, info.total_kill_monster_count or 0) 
	
	local pro = info.life_tower_left_hp / info.life_tower_left_maxhp
	self.progess:SetValue(pro)
	local pro_txt = math.ceil(pro * 100) .. "%"
	self.node_list["ProTxt"].text.text = pro_txt
	self.out_time = info.next_wave_refresh_time
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	if nil == self.timer_quest then
		self:TimerCallback()
		self.timer_quest = GlobalTimerQuest:AddRunQuest(function() self:TimerCallback() end, 1)
	end
	if self.node_list["AutoToggle"].toggle.isOn and info.curr_wave + 1 == info.clear_wave_count and info.curr_wave + 1 < #wave_cfg then
		FestivalSinglePartyCtrl.Instance:SendHolidayGuardRoleReq(HOLIDAI_GUARD_REQ.HOLIDAY_GUARD_NEXT_WAVE)
	end
end

function SinglePartyInfoGuardView:TimerCallback()
	local time = math.max(self.out_time - TimeCtrl.Instance:GetServerTime(), 0)
	local time_txt = 0
	if time > 3600 then
		time_txt = TimeUtil.FormatSecond(time, 1)
	else
		time_txt = TimeUtil.FormatSecond(time, 2)
	end
	self.node_list["NextTime"].text.text = string.format(Language.SingleParty.NextWaveTime, time_txt) 
	if time <= 0 then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end