DailyTaskFbView = DailyTaskFbView or BaseClass(BaseView)

function DailyTaskFbView:__init()
	self.ui_config = {{"uis/views/dailytaskfb_prefab", "DailyTaskFbInfoView"}}

	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.active_close = false
	self.fight_info_view = true
	self.is_safe_area_adapter = true
end

function DailyTaskFbView:LoadCallBack()
	self.max_score = 0
	self.cur_color = 0
	self.cur_score = 0

	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
end

function DailyTaskFbView:__delete()

end

function DailyTaskFbView:ReleaseCallBack()
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end
end

function DailyTaskFbView:OpenCallBack()
	self:Flush()
end

function DailyTaskFbView:CloseCallBack()

end

function DailyTaskFbView:SwitchButtonState(enable)
	self.node_list["AncientRelicsInfoView"]:SetActive(enable)
end

function DailyTaskFbView:OnFlush(param_t)
	local fb_info = FuBenData.Instance:GetFBSceneLogicInfo()
	if nil == fb_info then return end
	if fb_info.is_pass == 1 then
		GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	end
	local show_score_view = fb_info.param1 == 1

	self.node_list["Plane1"]:SetActive(show_score_view)
	self.node_list["Plane2"]:SetActive(not show_score_view)
	local cfg = DailyTaskFbData.Instance:GetFbCfg(fb_info.param1)
	if nil == cfg then return end
	self.node_list["TxtTitle"].text.text = cfg.fb_name
	if show_score_view then
		self:FlushScoreView(fb_info, cfg)
	else
		self:FlushBossView(fb_info, cfg)
	end

	local reward_cfg = TaskData.Instance:GetTaskReward(TASK_TYPE.RI)
	if reward_cfg then
		self.node_list["KillTxt1"].text.text = string.format(Language.DailyTaskFb.GetExpText, reward_cfg.exp)
		self.node_list["KillTxt2"].text.text = string.format(Language.DailyTaskFb.GetExpText, reward_cfg.exp)
	end
end

function DailyTaskFbView:FlushScoreView(fb_info, cfg)
	for i = 1, 3 do
		local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[cfg["monster_" .. i]]
		if monster_cfg then
			self.node_list["TxtMonster" .. i].text.text = string.format(Language.FuBen.MonsterCredit, monster_cfg.name, cfg["param_" .. i])
		end
	end
	self.cur_color = fb_info.param2 < cfg.finish_param and "#ff0000" or "#32d45e"
	self.cur_score = fb_info.param2
	self.max_score = cfg.finish_param
	self.node_list["TxtCurScore"].text.text = string.format(Language.FuBen.ProgressText, self.cur_color, self.cur_score, self.max_score)
	self.node_list["TxtScore"].text.text = string.format(Language.FuBen.TargetText, self.max_score)
end

function DailyTaskFbView:FlushBossView(fb_info, cfg)
	for i = 1, 2 do
		if i == 1 then
			local monster_id = cfg.boss_monster > 0 and cfg.boss_monster or cfg.monster_1
			local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[monster_id]
			local name = monster_cfg and monster_cfg.name or ""
			local cur_count = fb_info["param" .. (i + 1)] or 0
			local color = cur_count < cfg.finish_param and "#ff0000" or "#32d45e"
			local str = string.format(Language.DailyTaskFb.KillMonsterText, name, color, cur_count, cfg.finish_param)
			self.node_list["TxtKill" .. i].text.text = str
		else
			self.node_list["TxtKill" .. i].text.text = ""
		end
	end
	self.node_list["TxtMonster3Hide"].text.text = cfg.fb_desc
end