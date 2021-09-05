TeamFuBenInfoView = TeamFuBenInfoView or BaseClass(BaseView)

function TeamFuBenInfoView:__init()
	self.ui_config = {{"uis/views/fubenview_prefab", "TeamFBTowerInfoView"}}
	
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE,
		BindTool.Bind(self.Flush, self))

	self.active_close = false
	self.fight_info_view = true
	self.is_safe_area_adapter = true
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	
	self.out_time = 0
end

function TeamFuBenInfoView:LoadCallBack()
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
	self.team_cell_group = {}
	for i = 1,3 do
		self.team_cell_group[i] = FuBenTeamInfoCell.New(self.node_list["People" ..i])
	end
	self.node_list["ButtonOpenTeam"].button:AddClickListener(BindTool.Bind(self.OnClickRefresh, self))
	self.node_list["AutoToggle"].toggle:AddClickListener(BindTool.Bind(self.OnToggleChange, self))
	local info = ScoietyData.Instance:GetTeamInfo()
	if info and info.team_member_list then
		local flag = GetListNum(info.team_member_list) > 1
		self.node_list["Line"]:SetActive(GetListNum(info.team_member_list) >= 3)
		self.node_list["TaskButton"]:SetActive(flag)
		self.node_list["TeamButton"]:SetActive(flag)
		self.node_list["TaskButton2"]:SetActive(not flag)
		self.node_list["ShrinkButton"].transform.localPosition = flag and Vector3(22, -120, 0) or Vector3(22, 0, 0)
	end
	self:FlushTeamInfo()
end

function TeamFuBenInfoView:__delete()
	if self.main_view_complete ~= nil then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end

	if self.skill_render then
		self.skill_render:DeleteMe()
		self.skill_render = nil
	end
end

function TeamFuBenInfoView:ReleaseCallBack()
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	self.out_time = 0

	if self.team_cell_group then
		for k,v in pairs(self.team_cell_group) do
			v:DeleteMe()
		end
	end
end

function TeamFuBenInfoView:OpenCallBack()
	self.node_list["AutoToggle"].toggle.isOn = true
	self:Flush()

	local loader = AllocAsyncLoader(self, "skill_button_loader")
	loader:Load("uis/views/fubenview_prefab", "TeamFBTowerSkill", function (obj)
		if IsNil(obj) then
			return
		end

		MainUICtrl.Instance:ShowActivitySkill(obj)
		if nil == self.skill_render then
			self.skill_render = TowerSkillRender.New(obj)
			self.skill_render:Flush()
		end
	end)
end

function TeamFuBenInfoView:CloseCallBack()
	MainUICtrl.Instance:ShowActivitySkill(false)
	if self.skill_render then
		self.skill_render:DeleteMe()
		self.skill_render = nil
	end
end

function TeamFuBenInfoView:FlushTeamInfo()
	local info = ScoietyData.Instance:GetTeamInfo()
	for i = 1, 3 do
		if info and info.team_member_list then
			if info.team_member_list[i] then
				self.team_cell_group[i]:SetData(info.team_member_list[i])
				local vo = GameVoManager.Instance:GetMainRoleVo()
				if vo and vo.role_id == info.team_member_list[i].role_id then
					self.node_list["People" .. i]:SetActive(false)
				else
					self.node_list["People" ..i]:SetActive(true)
				end
			else
				self.node_list["People" ..i]:SetActive(false)
			end
		end
	end
	if self.team_cell_group then
		for k,v in pairs(self.team_cell_group) do
			v:Flush()
		end
	end
end


function TeamFuBenInfoView:OnClickRefresh()
	FuBenCtrl.Instance:SendTeamTowerDefendSetAttrType(TEAM_TOWER_DEFEND_OPREAT_REQ_TYPE.TEAM_TOWER_DEFEND_NEXT_WAVE_REQ)
end

function TeamFuBenInfoView:OnToggleChange(is_on)
	if self.node_list["AutoToggle"].toggle.isOn then
		FuBenCtrl.SendTowerDefendNextWave()
	end
end

function TeamFuBenInfoView:SwitchButtonState(enable)
	self.node_list["PanelInfo"]:SetActive(enable)
end

function TeamFuBenInfoView:OnFlush(param_t)
	local team_info = FuBenData.Instance:GetTeamTowerInfo() or {}
	if nil == next(team_info) then return end
	
	local wave_num = FuBenData.Instance:GetTeamTowerWaveNum()
	local curr_wave = team_info.curr_wave >= wave_num - 1 and ToColorStr(team_info.curr_wave + 1, TEXT_COLOR.GREEN) or ToColorStr(team_info.curr_wave + 1, TEXT_COLOR.RED)
	self.node_list["TextWave1"].text.text = string.format(Language.FuBen.CurWaveNumber, curr_wave, wave_num)
	FuBenData.Instance:SetFuBenTeamWave(team_info.clear_wave)
	local clear_wave = team_info.clear_wave >= wave_num and ToColorStr(team_info.clear_wave, TEXT_COLOR.GREEN) or ToColorStr(team_info.clear_wave, TEXT_COLOR.RED)
	self.node_list["TextWave2"].text.text = string.format(Language.FuBen.KillWaveNumber, clear_wave .. " / " .. wave_num)
	local pro = team_info.life_tower_left_hp / team_info.life_tower_left_maxhp
	self.node_list["ProgressBg"].slider.value = pro
	local pro_txt = math.ceil(pro * 100) .. "%"
	self.node_list["PropTxt"].text.text = pro_txt
	self.out_time = team_info.next_wave_refresh_time

	if nil == self.timer_quest then
		self:TimerCallback()
		self.timer_quest = GlobalTimerQuest:AddRunQuest(function() self:TimerCallback() end, 1)
	end

	if self.node_list["AutoToggle"].toggle.isOn and team_info.curr_wave + 1 == team_info.clear_wave and team_info.curr_wave + 1 < wave_num then
		FuBenCtrl.Instance:SendTeamTowerDefendSetAttrType(TEAM_TOWER_DEFEND_OPREAT_REQ_TYPE.TEAM_TOWER_DEFEND_NEXT_WAVE_REQ)
	end

	if self.skill_render then
		self.skill_render:Flush()
	end
end

function TeamFuBenInfoView:TimerCallback()
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

---------------------FuBenTeamInfoCell---------------
FuBenTeamInfoCell = FuBenTeamInfoCell or BaseClass(BaseCell)

function FuBenTeamInfoCell:__init()
	self.data = {}
end

function FuBenTeamInfoCell:__delete()

end

function FuBenTeamInfoCell:OnFlush()

end

function FuBenTeamInfoCell:OnFlush()
	if nil == self.data then
		return
	end
	AvatarManager.Instance:SetAvatar(self.data.role_id, self.node_list["RawImage"], self.node_list["ImgIcon"], self.data.sex, self.data.prof, false)

	self.node_list["TxtName"].text.text = self.data.name

	-- local attr_type = FuBenData.Instance:GetTeamTowerDefendInfoAttrById(self.data.role_id)
	local attr_type = 1
	local team_info = FuBenData.Instance:GetTeamTowerInfo()
	if team_info then
		if team_info.gongji_uid == self.data.role_id then
			attr_type = 2
		elseif team_info.fangyu_uid == self.data.role_id then
			attr_type = 3
		elseif team_info.assist_uid == self.data.role_id then
			attr_type = 4
		end
	end
	self.node_list["TextSkill"].text.text = Language.TowerDefend.SkillName[attr_type]

	local team_list = FuBenData.Instance:GetFuBenHp(self.data.role_id)
	if team_list then
		self.node_list["Progress"].slider.value = team_list.hp / team_list.max_hp
		self.node_list["LeftValue"].text.text = math.ceil((team_list.hp / team_list.max_hp) * 100) .. "%"
	end
	self.node_list["ImgGongJi"]:SetActive(false)
	self.node_list["ImgFangYu"]:SetActive(false)
	self.node_list["ImgWuDi"]:SetActive(false)
	self.node_list["ImgZengYi"]:SetActive(false)
	local buff_list = FuBenData.Instance:GetFuBenBuffList(self.data.role_id)
	if buff_list then
		for k,v in pairs(buff_list) do
			if v == BUFF_TYPE.EBT_ADD_GONGJI then
				self.node_list["ImgGongJi"]:SetActive(true)
			elseif v == BUFF_TYPE.EBT_ADD_FANGYU then
				self.node_list["ImgFangYu"]:SetActive(true)
			elseif v == BUFF_TYPE.WUDI_PROTECT then
				self.node_list["ImgWuDi"]:SetActive(true)
			elseif v == BUFF_TYPE.EBT_ADD_MULTI_ATTR then
				self.node_list["ImgZengYi"]:SetActive(true)
			end
		end
	end
end