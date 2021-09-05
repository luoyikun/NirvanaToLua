-- 捕捉仙宠奇遇BOSS-FocusEncounterBossTips
TipsFocusBossEncounterView = TipsFocusBossEncounterView or BaseClass(BaseView)

function TipsFocusBossEncounterView:__init()
	self.ui_config = {
		{"uis/views/tips/focustips_prefab", "FocusEncounterBossTips"},
	}
	
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.view_layer = UiLayer.Pop
end

function TipsFocusBossEncounterView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnGo"].button:AddClickListener(BindTool.Bind(self.GoClick, self))
end

function TipsFocusBossEncounterView:ReleaseCallBack()

end

function TipsFocusBossEncounterView:OpenCallBack()
	self:Flush()
end

function TipsFocusBossEncounterView:SetCloseCallBack(close_callback)
	self.close_callback = close_callback
end

function TipsFocusBossEncounterView:GoClick()
	if not FuBenData.Instance:GetIsInCommonScene() then
		SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.CanNotGo)
		return
	end	
	if self.ok_call_back then
		self.ok_call_back()
	end
	self:Close()
end

function TipsFocusBossEncounterView:CloseCallBack()
	-- local is_not_remind = self.node_list["Toggle"].toggle.isOn
	-- BossCtrl.Instance:SetCountDown2(is_not_remind)

	self.ok_call_back = nil

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.close_callback then
		self.close_callback = nil
	end
end

function TipsFocusBossEncounterView:OnFlush()
	-- self.node_list["Toggle"].toggle.isOn = BossCtrl.Instance:GetHiedSpiritMeetTips()
	self:SetPanelValue()
end

function TipsFocusBossEncounterView:SetPanelValue()
	local encounter_boss_info = BossData.Instance:GetEncounterBossData()
	self:ReFlushInfo()
	self:SetCountDown(encounter_boss_info.close_count_down)
end

function TipsFocusBossEncounterView:ReFlushInfo()
	local encounter_boss_info = BossData.Instance:GetEncounterBossData()
	self.ok_call_back = encounter_boss_info.ok_callback

	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[encounter_boss_info.boss_id]
	if monster_cfg then
		local bundle, asset = ResPath.GetBossRawIcon(monster_cfg.headid)
		self.node_list["BossIcon"].raw_image:LoadSprite(bundle, asset)
	end

	local enter_times = BossData.Instance:GetEncounterBossEnterTimes()
	self.node_list["RoleName"].text.text = encounter_boss_info.role_name
	local scene_cfg = ConfigManager.Instance:GetSceneConfig(encounter_boss_info.scene_id)
	local map_name = scene_cfg and scene_cfg.name or ""
	self.node_list["TxtDes1"].text.text = string.format(Language.JingLing.EncounterBossTips1, map_name)
	self.node_list["TxtDes2"].text.text = string.format(Language.JingLing.EncounterBossTips2, enter_times)
end

function  TipsFocusBossEncounterView:SetCountDown(count_down_time)
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	self.node_list["TxtTime"].text.text = string.format(Language.JingLing.MeetBossTip, count_down_time)
	self.count_down = CountDown.Instance:AddCountDown(count_down_time, 1, BindTool.Bind(self.CountDown, self))
end

function TipsFocusBossEncounterView:CountDown(elapse_time, total_time)
	self.node_list["TxtTime"].text.text = string.format(Language.JingLing.MeetBossTip, math.ceil(total_time - elapse_time))
	if elapse_time >= total_time then
		if self.count_down then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		self:Close()
	end
end
