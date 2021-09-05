TipsBossInfoView = TipsBossInfoView or BaseClass(BaseView)

function TipsBossInfoView:__init()
	self.ui_config = {{"uis/views/tips/bossinfotips_prefab", "BossInfoTipView"}}
	self.boss_id = 0
	self.boss_info = {}
	self.play_audio = true
	self.monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
	self.view_layer = UiLayer.Pop
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.is_modal =  true
	self.is_any_click_close =  true
end

function TipsBossInfoView:ReleaseCallBack()
	self.boss_id = nil
	self.boss_info = {}
end

function TipsBossInfoView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["BtnGo"].button:AddClickListener(BindTool.Bind(self.OnClickMoveTo, self))
end

function TipsBossInfoView:OpenCallBack()
	if not self.scene_load_enter then
		self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER,
			BindTool.Bind(self.OnChangeScene, self))
	end
	self:Flush()
end

function TipsBossInfoView:CloseCallBack()
	self.boss_id = 0
	self.boss_info = {}
	if self.scene_load_enter ~= nil then
		GlobalEventSystem:UnBind(self.scene_load_enter)
		self.scene_load_enter = nil
	end
end

function TipsBossInfoView:OnClickClose()
	self:Close()
end

function TipsBossInfoView:OnClickMoveTo()
	if self.boss_info.boss_type > 0 then
		local free_vip_level, cost_gold = BossData.Instance:GetBossVipLismit(self.boss_info.scene_id)
		local vo_vip = GameVoManager.Instance:GetMainRoleVo().vip_level

		local ok_fun = function()
			BossData.Instance:SetCurInfo(self.boss_info.scene_id, self.boss_id)
			local is_buy = self.boss_info.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_DABAO and 1 or 0
			BossCtrl.Instance:SendEnterBossFamily(self.boss_info.boss_type, self.boss_info.scene_id, is_buy)
		end

		if vo_vip < free_vip_level then
			local str = string.format(Language.Boss.BossFamilyLimitStr, cost_gold)
			TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, str)
			return
		end

		if self.boss_info.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_DABAO then
			if not BossData.Instance:GetCanGoAttack() then
				TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
				return
			end
			local enter_count = BossData.Instance:GetDabaoBossCount()
			local max_count = BossData.Instance:GetDabaoFreeTimes()
			if enter_count >= max_count and BossData.Instance:GetDabaoEnterGold(enter_count - max_count) then
				local cost = BossData.Instance:GetDabaoEnterGold(enter_count - max_count)
				TipsCtrl.Instance:ShowCommonAutoView(nil, string.format(Language.Boss.BuyEnterDabao, cost), ok_fun, nil, true)
				return
			end
		end

		ok_fun()
	else
		GuajiCtrl.Instance:FlyToScenePos(self.boss_info.scene_id, self.boss_info.born_x, self.boss_info.born_y, true)
	end
end

function TipsBossInfoView:OnChangeScene()
	if self:IsOpen() then
		self:Close()
	end
end

function TipsBossInfoView:SetBossId(boss_id)
	self.boss_id = boss_id or 0
end

function TipsBossInfoView:OnFlush()
	local boss_info = KaifuActivityData.Instance:GetBossInfoById(self.boss_id)--BossData.Instance:GetWorldBossInfoById(self.boss_id) --

	if not boss_info then
		return
	end
	self.boss_info = boss_info
	local scene_config = ConfigManager.Instance:GetSceneConfig(boss_info.scene_id)
	self.node_list["TxtSceneName"].text.text = string.format(Language.BossInfoTipView.Map,scene_config.name)
	local boss_cfg = BossData.Instance:GetMonsterInfo(self.boss_id)
	local boss_level = 0
	if boss_cfg then
		boss_level = boss_cfg.level
	end
	self.node_list["TxtFightPower"].text.text = string.format(Language.BossInfoTipView.Boss,boss_level)

	if self.monster_cfg[self.boss_id] then
		self.node_list["TxtBossNam"].text.text = self.monster_cfg[self.boss_id].name
	end
end