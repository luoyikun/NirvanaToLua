TipsBossFocusView = TipsBossFocusView or BaseClass(BaseView)

function TipsBossFocusView:__init()
	self.ui_config = {{"uis/views/bossview_prefab", "FocusBossTips"}}
	self.view_layer = UiLayer.Pop
	self.is_Boss_type = false
end

function TipsBossFocusView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseClick, self))
	self.node_list["BtnGo"].button:AddClickListener(BindTool.Bind(self.GoClick, self))
	self.node_list["Toggle_focus"].toggle:AddValueChangedListener(BindTool.Bind(self.ClickToggle, self))
end

function TipsBossFocusView:CloseClick()
	self:Close()
end

function TipsBossFocusView:GoClick()
	local main_role = Scene.Instance:GetMainRole()
	if main_role and main_role:IsQingGong() then
		SysMsgCtrl.Instance:ErrorRemind(Language.QingGong.NoDeliveryQingGong)
		return
	end
	if self.ok_call_back then
		self.ok_call_back()
	end
	self:Close()
end

function TipsBossFocusView:CloseCallBack()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.is_Boss_type = false

	if self.delay_to_close then
		GlobalTimerQuest:CancelQuest(self.delay_to_close)
		self.delay_to_close = nil
	end
end

function TipsBossFocusView:SetBossTypeBool(is_Boss_type)
	self.is_Boss_type = is_Boss_type
end

function TipsBossFocusView:ClickToggle(isOn)
	local scene_type = BossData.Instance:GetSceneTypeByBossID(self.boss_id)
	BossData.Instance:SetDelayTimeNoBossTip(scene_type, isOn)
	if isOn then
		if self.delay_to_close then
			GlobalTimerQuest:CancelQuest(self.delay_to_close)
			self.delay_to_close = nil
		end

		if self.delay_to_close == nil then
			self.delay_to_close = GlobalTimerQuest:AddDelayTimer(function()
				self:Close()
			end, 1)
		end
	end
end

function TipsBossFocusView:SetData(boss_id, ok_call_back,type)
	self.boss_id = boss_id
	self.ok_call_back = ok_call_back
	self.type = type
	self:Flush()
end

function TipsBossFocusView:OnFlush()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.node_list["Toggle_bg"]:SetActive(false)
	if self.boss_id then
		local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto")
		if nil ~= monster_cfg and nil ~= monster_cfg.monster_list then
			monster_cfg = monster_cfg.monster_list[self.boss_id]
		end
		if monster_cfg then
			local bundle, asset = ResPath.GetBoss("boss_item_" .. monster_cfg.headid)
			self.node_list["BossIcon"].raw_image:LoadSprite(bundle, asset)
		end

		if self.is_Boss_type then
			self.node_list["Toggle_bg"]:SetActive(true)
			local scene_type = BossData.Instance:GetSceneTypeByBossID(self.boss_id)
			if scene_type then
				local title_bundle, title_asset = ResPath.GetBossTypeTag(scene_type)
				self.node_list["Title"].image:LoadSprite(title_bundle, title_asset)
			end
			self.node_list["Txt_Desc"].text.text = string.format(Language.Boss.BossFocusDesc, monster_cfg.level, monster_cfg.name)
		else
			self.node_list["Txt_Desc"].text.text = Language.Boss.CommonBossFlushDesc
		end
	else
		self.node_list["BossIcon"]:SetActive(true)
		self.node_list["Txt_Desc"].text.text = Language.Boss.BossFlushDesc
		local title_bundle, title_asset = ResPath.GetBossTypeTag(4)
		self.node_list["Title"].image:LoadSprite(title_bundle, title_asset)
		local bundle, asset = ResPath.GetBoss("icon_system_boss")
		self.node_list["BossIcon"].raw_image:LoadSprite(bundle, asset)
	end

	self.node_list["TxtTime"].text.text = string.format(Language.FocusTips.Time2, "15")
	self.count_down = CountDown.Instance:AddCountDown(15, 1, BindTool.Bind(self.CountDown, self))
end

function TipsBossFocusView:CountDown(elapse_time, total_time)
	local str_tmp = math.ceil(total_time - elapse_time)
	self.node_list["TxtTime"].text.text = string.format(Language.FocusTips.Time2, str_tmp)
	if elapse_time >= total_time then
		if self.count_down then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		self:Close()
	end
end