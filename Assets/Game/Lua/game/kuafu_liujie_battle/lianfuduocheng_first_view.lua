LianFuDuoChengFirstView = LianFuDuoChengFirstView or BaseClass(BaseView)

function LianFuDuoChengFirstView:__init()
	self.ui_config = {{"uis/views/citycombatview_prefab", "LianFuDuoChengFirstView"}}
	self.play_audio = true

	self.act_id = ACTIVITY_TYPE.KF_GUILDBATTLE
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function LianFuDuoChengFirstView:__delete()

end

function LianFuDuoChengFirstView:ReleaseCallBack()
	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end
	if TitleData.Instance ~= nil then
		for i = 1, 5 do
			TitleData.Instance:ReleaseTitleEff(self.node_list["Title" .. i])
		end
	end
end

function LianFuDuoChengFirstView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnEnter"].button:AddClickListener(BindTool.Bind(self.ClickEnter, self))
end

function LianFuDuoChengFirstView:OpenCallBack()
	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
	self:Flush()
end

function LianFuDuoChengFirstView:CloseCallBack()
	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end
end

function LianFuDuoChengFirstView:CloseWindow()
	self:Close()
end

function LianFuDuoChengFirstView:ClickTitle(index)
	local title_cfg = {}
	title_cfg = ActivityData.Instance:GetXianMoItemCfg()
	if title_cfg and title_cfg[index] then
		local data = {item_id = title_cfg[index].item_id, is_bind = 0, num = 1}
		TipsCtrl.Instance:OpenItem(data)
	end
end

function LianFuDuoChengFirstView:ClickEnter()
	self:Close()
	if IS_ON_CROSSSERVER or not OpenFunData.Instance:CheckIsHide("kf_battle") then
		return
	end
	ViewManager.Instance:Open(ViewName.KuaFuBattle)
end

function LianFuDuoChengFirstView:FlushTuanZhangModel(uid, info)
	if self.tuanzhang_uid == uid then
		if self.role_model then
			if info then
				local part_cfg = ConfigManager.Instance:GetAutoConfig("cross_guildbattle_auto")
				local base_prof = PlayerData.Instance:GetRoleBaseProf(info.prof)
				local shizhuang_image_id = part_cfg.own_reward[1].index_1 or 0
				local weapon_image_id = part_cfg.own_reward[1].index_0 or 0
				local role_res_id = 0
				local weapon_id = 0
				if shizhuang_image_id ~= 0 then
					local fashion_cfg = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").shizhuang_special_img
					if fashion_cfg[shizhuang_image_id] then
						for k, v in pairs(fashion_cfg[shizhuang_image_id]) do 
							if k == "resouce" .. base_prof .. info.sex then
								role_res_id = v
							end
						end
					end
				end
				if weapon_image_id ~= 0 then
					local weapon_cfg = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").weapon_special_img
					if weapon_cfg[weapon_image_id] then
						for k, v in pairs(weapon_cfg[weapon_image_id]) do
							if k == "resouce" .. base_prof .. info.sex then
								weapon_id = v
								if base_prof == 3 then
									local t = Split(weapon_id,",")
									weapon_id = t[1]
									weapon_id2 = t[2]
									self.role_model:SetWeapon2Resid(weapon_id2)
								end
							end
						end
					end
				end
				self.role_model:SetWeaponResid(weapon_id)
				self.role_model:SetRoleResid(role_res_id)
				self.role_model:SetTrigger(ANIMATOR_PARAM.FIGHT)
			end
		end
	end
end

function LianFuDuoChengFirstView:OnFlush()
	local act_info = ActivityData.Instance:GetActivityInfoById(self.act_id)
	if not next(act_info) then return end

	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	self.tuanzhang_uid = game_vo.role_id
	if not self.role_model then
		self.role_model = RoleModel.New()
		self.role_model:SetDisplay(self.node_list["RoleDisplay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	end
	self:FlushTuanZhangModel(self.tuanzhang_uid, game_vo)

	for i = 1, 5 do
		self.node_list["Title" .. i]:SetActive(true)
		local current_title_id = KuafuGuildBattleData.Instance:GetOwnReward(i - 1).title_name
		local bundle, asset = ResPath.GetTitleIcon(current_title_id)
		if self.node_list["Title" .. i].image then
			self.node_list["Title" .. i].image:LoadSprite(bundle, asset, function()
				self.node_list["Title" .. i].image:SetNativeSize()
			end)
			TitleData.Instance:LoadTitleEff(self.node_list["Title" .. i], current_title_id, true)
		end
	end

	if act_info then
		local temp_act_id = ACTIVITY_TYPE.KF_GUILDBATTLE_READYACTIVITY
		local time_des = ActivityData.Instance:GetCurServerOpenDayText(temp_act_id, act_info)
		self.node_list["TxtDescTime"].text.text = time_des
	end
end

function LianFuDuoChengFirstView:ActivityCallBack(activity_type)
	if activity_type == self.act_id then
		self:Flush()
	end
end