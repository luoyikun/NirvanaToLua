TipGarrottingBossView = TipGarrottingBossView or BaseClass(BaseView)

function TipGarrottingBossView:__init()
	self.ui_config = {{"uis/views/tips/garrottingbosstips_prefab", "GarrottingBossTips"}}
	self.boss_id = 0
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].MonsterKill)
	end
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	-- self.is_modal = true
	-- self.is_any_click_close = true
end

function TipGarrottingBossView:ReleaseCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	self.boss_icon = nil
end

function TipGarrottingBossView:LoadCallBack()
end

function TipGarrottingBossView:SetData(boss_id, killer_id)
	self.boss_id = boss_id
	self.killer_id = killer_id
	self:Flush()
end

function TipGarrottingBossView:OpenCallBack()
	self:Flush()
	self:CalTime()
end

function TipGarrottingBossView:CloseCallBack()
	self.boss_id = 0
end

function TipGarrottingBossView:OnCloseClick()
	self:Close()
end

function TipGarrottingBossView:OnFlush()
	if self.boss_id ~= 0 then
		local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.boss_id]
		local bundle, asset = nil, nil
		if monster_cfg then
			bundle, asset = ResPath.GetBossIcon(monster_cfg.headid)
			self.node_list["Icon"].image:LoadSprite(bundle, asset)
			self.node_list["MonsterName"].text.text = monster_cfg.name
		end
	end
	if self.killer_id ~= 0 then
		CheckData.Instance:SetCurrentUserId(self.killer_id)
		CheckCtrl.Instance:SendQueryRoleInfoReq(self.killer_id)

		local info_call_back = function()
			local data = CheckData.Instance:GetRoleInfo()
			self.node_list["Name"].text.text = data.role_name
			AvatarManager.Instance:SetAvatar(self.killer_id, self.node_list["IconRoleRaw"], self.node_list["IconRole"], data.sex, data.prof, false)
		end
		CheckCtrl.Instance:SetInfoCallBack(self.killer_id, info_call_back)
	end
end

function TipGarrottingBossView:CalTime()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	-- self.time_quest = GlobalTimerQuest:AddRunQuest(function()
	-- 	GlobalTimerQuest:CancelQuest(self.time_quest)
	-- 	self:Close()
	-- end, 5)
	self.time_quest = GlobalTimerQuest:AddDelayTimer(function()
		self:Close()
	end, 4)
end
