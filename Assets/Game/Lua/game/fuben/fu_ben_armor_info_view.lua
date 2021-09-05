FuBenArmorInfoView = FuBenArmorInfoView or BaseClass(BaseView)

function FuBenArmorInfoView:__init()
	self.ui_config = {{"uis/views/fubenview_prefab", "ArmorFBInFoView"}}

	self.active_close = false
	self.fight_info_view = true
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.out_time = 0
	self.refresh_wave = 0
end

function FuBenArmorInfoView:LoadCallBack()
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE,
		BindTool.Bind(self.Flush, self))

	self.node_list["ButtonOpenTeam"].button:AddClickListener(BindTool.Bind(self.OnClickRefresh, self))
	self.node_list["AutoToggle"].toggle:AddClickListener(BindTool.Bind(self.OnToggleChange, self))
end

function FuBenArmorInfoView:__delete()
	if self.skill_render then
		self.skill_render:DeleteMe()
		self.skill_render = nil
	end
end

function FuBenArmorInfoView:ReleaseCallBack()
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end
	if self.main_view_complete ~= nil then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end
	self.out_time = 0
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end

	if self.deley_timer then
		GlobalTimerQuest:CancelQuest(self.deley_timer)
		self.deley_timer = nil
	end
end

function FuBenArmorInfoView:OpenCallBack()
	self.node_list["AutoToggle"].toggle.isOn = true
	if self.deley_timer then
		GlobalTimerQuest:CancelQuest(self.deley_timer)
		self.deley_timer = nil
	end
	if nil == self.deley_timer then
		self.deley_timer = GlobalTimerQuest:AddDelayTimer(function()
			FuBenCtrl.Instance:SendArmorDefendRoleReq(ARMOR_DEFEND_REQTYPE.ARMOR_DEFEND_AUTO_REFRESH, 1)
		end, 3)
	end
	self:Flush()

	-- local loader = AllocAsyncLoader(self, "skill_button_loader")
	-- loader:Load("uis/views/fubenview_prefab", "ArmorFBSkill", function (obj)
	-- 	MainUICtrl.Instance:ShowActivitySkill(obj)
	-- 	if nil == self.skill_render then
	-- 		self.skill_render = FuBenArmorSkillRnder.New(obj)
	-- 		self.skill_render:Flush()
	-- 	end
	-- end)
end

function FuBenArmorInfoView:CloseCallBack()
	MainUICtrl.Instance:ShowActivitySkill(false)
	if self.skill_render then
		self.skill_render:DeleteMe()
		self.skill_render = nil
	end
end

function FuBenArmorInfoView:OnClickRefresh()
	FuBenCtrl.Instance:SendArmorDefendRoleReq(ARMOR_DEFEND_REQTYPE.ARMOE_DEFEND_NEXT_WAVE_REQ)
end


function FuBenArmorInfoView:OnToggleChange(is_on)
	local refresh = self.node_list["AutoToggle"].toggle.isOn and 1 or 0
	FuBenCtrl.Instance:SendArmorDefendRoleReq(ARMOR_DEFEND_REQTYPE.ARMOR_DEFEND_AUTO_REFRESH, refresh)
end

function FuBenArmorInfoView:EscapeWarning(num)
	if self.skill_render then
		self.skill_render:EscapeWarning(num)
	end
end

function FuBenArmorInfoView:SwitchButtonState(enable)
	self.node_list["PanelInfo"]:SetActive(enable)
end

function FuBenArmorInfoView:OnFlush(param_t)
	local info = FuBenData.Instance:GetArmorDefendInfo()
	if nil == next(info) then
		return
	end
	
	local pass_level = FuBenData.Instance:GetArmorDefendRoleInfo()
	if info == "" or pass_level == "" then return end
	-- local cur_level = pass_level.max_pass_level + 1
	local cfg = FuBenData.Instance:GetArmorWaveCfg(1)
	local other_cfg = FuBenData.Instance:GetArmorDefendCfgOther()
	if cfg == nil or cfg == "" or other_cfg == nil or other_cfg == "" then return end
	if self.refresh_wave ~= info.curr_wave + 1 and info.curr_wave + 1 > 0 then
		self.refresh_wave = info.curr_wave + 1
		local str = string.format(Language.FuBen.RefreshWave, self.refresh_wave)
		SysMsgCtrl.Instance:ErrorRemind(str)
	end
	self.out_time = info.next_wave_refresh_time
	local max_num = #cfg
	if TaskData.Instance:GetIsArmorTask() then
		max_num = 3
	end
	local curr_wave = info.curr_wave >= max_num - 1 and ToColorStr(info.curr_wave + 1, TEXT_COLOR.GREEN) or ToColorStr(info.curr_wave + 1, TEXT_COLOR.RED)
	self.node_list["TextWave1"].text.text = string.format(Language.FuBen.CurWaveNumber, curr_wave, max_num)
	-- local clear_wave = info.escape_monster_count >= other_cfg.escape_num_to_failure and ToColorStr(info.escape_monster_count, TEXT_COLOR.GREEN) or ToColorStr(info.escape_monster_count, TEXT_COLOR.RED)

	-- local clear_wave = info.clear_wave_count >= max_num and ToColorStr(info.clear_wave_count, TEXT_COLOR.GREEN) or ToColorStr(info.clear_wave_count, TEXT_COLOR.RED)
	-- self.node_list["TextWave2"].text.text = string.format(Language.FuBen.KillWaveNumber, clear_wave .. " / " .. max_num)

	local pro = info.escape_monster_count / other_cfg.escape_num_to_failure
	self.node_list["ProgressBg"].slider.value = pro
	local pro_txt = info.escape_monster_count .. " / " .. other_cfg.escape_num_to_failure
	-- local pro_txt = math.ceil(pro * 100) .. "%"
	self.node_list["PropTxt"].text.text = pro_txt

	if nil == self.timer_quest then
		self:TimerCallback()
		self.timer_quest = GlobalTimerQuest:AddRunQuest(function() self:TimerCallback() end, 1)
	end
	
	if not self.node_list["AutoToggle"].toggle.isOn and info.refresh_when_clear == 1 then
		self.node_list["AutoToggle"].toggle.isOn = true
	end

	if self.skill_render then
		self.skill_render:Flush()
	end
end

function FuBenArmorInfoView:TimerCallback()
	local time = math.max(self.out_time - TimeCtrl.Instance:GetServerTime(), 0)
	if time > 3600 then
		self.node_list["TextWave3"].text.text = string.format(Language.FuBen.NextTime,TimeUtil.FormatSecond(time, 1))
	else
		self.node_list["TextWave3"].text.text = string.format(Language.FuBen.NextTime,TimeUtil.FormatSecond(time, 2))
	end
	if time <= 0 then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function FuBenArmorInfoView:PlaySkillAnim(target_obj)
	if self.skill_render then
		self.skill_render:PlaySkillAnim(target_obj)
	end
end

function FuBenArmorInfoView:SedUseSkill()
	if self.skill_render then
		self.skill_render:SedUseSkill()
	end
end


----------------------技能render----------------------
FuBenArmorSkillRnder = FuBenArmorSkillRnder or BaseClass(BaseRender)
function FuBenArmorSkillRnder:__init()
	self.is_warning = true
	self.warning_time = 0
	self.energy = 0
end

function FuBenArmorSkillRnder:__delete()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	self.target_obj = nil
end

function FuBenArmorSkillRnder:LoadCallBack()
	for i = 1, 2 do
		local cfg = FuBenData.Instance:GetArmorDefendSkillCfg(i - 1)
		self.node_list["TextCount" .. i].text.text = cfg.energy_cost
	end
	
	self.node_list["BtnStrengthen"].button:AddClickListener(BindTool.Bind(self.DoStrengthenSkill, self))
	self.node_list["BtnRange"].button:AddClickListener(BindTool.Bind(self.DoRangeSkill, self))
	self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateSkillCD, self), 0.1)
end

function FuBenArmorSkillRnder:DoStrengthenSkill()
	local index = 0
	local cfg = FuBenData.Instance:GetArmorDefendSkillCfg(index)
	if nil == cfg then
		return
	end

	local time_list = FuBenData.Instance:GetArmorPerformTimeList()
	local time = time_list and (time_list[1] - TimeCtrl.Instance:GetServerTime()) or 0
	if time > 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.SkillCD)
		return
	end

	if self.energy < cfg.energy_cost then
		SysMsgCtrl.Instance:ErrorRemind(Language.Dungeon.TowerEnergyNotEnough)
		return
	end

	local str = string.format(Language.Dungeon.StrengthAddPercent, cfg.param_a, cfg.param_b)
	SysMsgCtrl.Instance:ErrorRemind(str)

	local main_role = Scene.Instance:GetMainRole()
	local main_role_x, main_role_y = main_role:GetLogicPos()
	-- local x, y = Scene.Instance:GetMainRole():GetLogicPos()
	FightCtrl.SendPerformSkillReq(index, 0, 0, 0, main_role:GetObjId(), true, main_role_x, main_role_y)
end

function FuBenArmorSkillRnder:DoRangeSkill()
	local index = 1
	local cfg = FuBenData.Instance:GetArmorDefendSkillCfg(index)
	if nil == cfg then
		return
	end

	local time_list = FuBenData.Instance:GetArmorPerformTimeList()
	local time = time_list and (time_list[2] - TimeCtrl.Instance:GetServerTime()) or 0
	if time > 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.SkillCD)
		return
	end

	if self.energy < cfg.energy_cost then
		SysMsgCtrl.Instance:ErrorRemind(Language.Dungeon.TowerEnergyNotEnough)
		return
	end

	local target_obj = GuajiCtrl.Instance:SelectAtkTarget(false)
	if nil == target_obj then
		SysMsgCtrl.Instance:ErrorRemind(Language.Dungeon.TowerEnergyNotTarget)
		return
	end
	self.select_obj = target_obj
	local target_x, target_y = target_obj:GetLogicPos()

	if not GuajiCtrl.CheckRange(target_x, target_y, 10) then
		-- TipsCtrl.Instance:ShowSystemMsg(Language.Role.AttackDistanceFar)
		local scene_id = Scene.Instance:GetSceneId()
		MoveCache.end_type = MoveEndType.UseAoeSkill
		GuajiCtrl.Instance:MoveToPos(scene_id, target_x, target_y, 9, 0)
		return
	end
	self:SedUseSkill()
end

function FuBenArmorSkillRnder:SedUseSkill()
	local main_role = Scene.Instance:GetMainRole()
	local main_role_x, main_role_y = main_role:GetLogicPos()
	local target_x, target_y = self.select_obj:GetLogicPos()

	FightCtrl.SendPerformSkillReq(1, 0, target_x, target_y, self.select_obj:GetObjId(), true, main_role_x, main_role_y)
end

function FuBenArmorSkillRnder:PlaySkillAnim(target_obj)
	if self.select_obj == nil then return end

	local pos = self.select_obj:GetLuaPosition()
	local bundle_name, asset_name = ResPath.GetMiscEffect("tongyong_JN_zhendi")
	EffectManager.Instance:PlayControlEffect(self.select_obj, bundle_name, asset_name, Vector3(pos.x, pos.y + 1, pos.z), nil)
		-- 播放动作
	local main_role = Scene.Instance:GetMainRole()
	if nil ~= main_role.draw_obj then
		local main_part = main_role.draw_obj:GetPart(SceneObjPart.Main)
		if nil ~= main_part then
			main_part:SetTrigger("attack16")
		end
	end
end

function FuBenArmorSkillRnder:UpdateSkillCD()
	local skill_cfg = FuBenData.Instance:GetArmorDefendSkillCfg()
	local time_list = FuBenData.Instance:GetArmorPerformTimeList()
	local next_time = TimeCtrl.Instance:GetServerTime() - self.warning_time
	if skill_cfg and time_list then
		for i = 1, 2 do
			local time = time_list[i] - TimeCtrl.Instance:GetServerTime()
			if time > 0 then
				-- UI:SetGraphicGrey(self.node_list["Icon" .. i], true)
				self.node_list["CDText" .. i]:SetActive(true)
				self.node_list["CDText" .. i].text.text = math.ceil(time)
				if skill_cfg[i].cd_s > 0 then
					self.node_list["CDMask" .. i]:SetActive(true)
					self.node_list["CDMask" .. i]:GetComponent(typeof(UnityEngine.UI.Image)).fillAmount = time / skill_cfg[i].cd_s
				end
			else
				-- UI:SetGraphicGrey(self.node_list["Icon"], false)
				self.node_list["CDText" .. i].text.text = 0
				self.node_list["CDText" .. i]:SetActive(false)
				self.node_list["CDMask" .. i]:SetActive(false)
			end	
		end
	end
	if next_time >= 30 and not self.is_warning then
		self.is_warning = true
	end
end


function FuBenArmorInfoView:EscapeWarning(num)
	if self.is_warning and num then
		local str = string.format(Language.FuBen.EscapeWaring, num)
		SysMsgCtrl.Instance:ErrorRemind(str)
		self.is_warning	= false
		self.warning_time = TimeCtrl.Instance:GetServerTime()
	end
end
	
function FuBenArmorSkillRnder:OnFlush()
	local info = FuBenData.Instance:GetArmorDefendInfo()
	self.node_list["Slider"].slider.value = info.energy / 100
	self.node_list["TextEnergy"].text.text = info.energy .. "/" .. 100

	self.energy = info.energy
end
