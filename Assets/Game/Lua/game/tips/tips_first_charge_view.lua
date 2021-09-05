TipsFirstChargeView = TipsFirstChargeView or BaseClass(BaseView)

function TipsFirstChargeView:__init()
	self.ui_config = {
		{"uis/views/tips/firstchargetip_prefab", "FirstChargeTips"}
	}
	self.view_layer = UiLayer.MainUI
	self.play_audio = true
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/voice/firstchargeguide", self.audio_config.other[1].FirstchargeGuide)
	end
end

function TipsFirstChargeView:__delete()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	
	if self.data_listen and PlayerData.Instance then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
	self.old_level = nil
	self.res_id = nil
end

function TipsFirstChargeView:ReleaseCallBack()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	self.fight_text = nil
end

function TipsFirstChargeView:SetDataChangeCallback()
	if not self.data_listen then
		self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
		PlayerData.Instance:ListenerAttrChange(self.data_listen)
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		self.old_level = main_role_vo.level
	end
end

function TipsFirstChargeView:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "level" then
		if self.old_level then
			local fun_cfg = OpenFunData.Instance:OpenFunCfg() or {}
			local history_recharge = DailyChargeData.Instance:GetChongZhiInfo().history_recharge or 0
			if history_recharge < CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10 and fun_cfg.first_charge_tip and value >= fun_cfg.first_charge_tip.trigger_param and self.old_level < fun_cfg.first_charge_tip.trigger_param then
				self.old_level = value
				self:Open()
				if not self.upgrade_timer_quest then
					self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(function()
						self:Close()
					end, fun_cfg.first_charge_tip.with_param)
				end
			end
		end
	end
end

function TipsFirstChargeView:LoadCallBack()
	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display)
	self.node_list["BtnYes"].button:AddClickListener(BindTool.Bind(self.OnClickCharge, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["Frame"].button:AddClickListener(BindTool.Bind(self.OnBgClick, self))
	self.node_list["Block"].button:AddClickListener(BindTool.Bind(self.OnBgClick, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtCount"], "FightPower3")
end

function TipsFirstChargeView:OpenCallBack()
	self:Flush()
end

function TipsFirstChargeView:CloseCallBack()
	self.res_id = nil
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
end

function TipsFirstChargeView:OnClickCharge()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
	self:Close()
end

function TipsFirstChargeView:OnClickClose()
	self:Close()
end

function TipsFirstChargeView:OnBgClick()
	self:Close()
	ViewManager.Instance:Open(ViewName.SecondChargeView)
end

function TipsFirstChargeView:OnFlush(param_list)
	if self.model and not self.res_id then
		local reward_cfg =DailyChargeData.Instance:GetFirstRewardByWeek()
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local num_str = string.format("%02d", reward_cfg.wepon_index)
		local prof = (main_role_vo.prof % 10)
		-- if prof == 4 then
		-- 	prof = 3
		-- end

		local pox_x, pox_y, pox_z = 0, 0, 0
		if prof == 1 then
			pox_x, pox_y, pox_z = -0.12, 1.03, 0.58
		elseif prof == 2 then
			pox_x, pox_y, pox_z = 0, 0, 0.2
		elseif prof == 3 then
			pox_x, pox_y, pox_z = 0, 0, -0.97
		elseif prof == 4 then
			pox_x, pox_y, pox_z = 0, 0.3, 1.06
		end
		local weapon_show_id = "100" .. prof .. num_str
		local bundle, asset = ResPath.GetWeaponShowModel(weapon_show_id)
		self.model:SetMainAsset(bundle, asset, function()
				self.model:SetLocalPosition(Vector3(pox_x, pox_y, pox_z))
			end)

		self.res_id = weapon_show_id
		local cfg = DailyChargeData.Instance:GetThreeRechargeAuto()
		local fight_power = cfg[1].power_left
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = fight_power
		end
	end
end
