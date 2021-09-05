GuildFirstView = GuildFirstView or BaseClass(BaseView)

function GuildFirstView:__init()
	self.ui_config = {{"uis/views/citycombatview_prefab", "GuildFirstView"}}
	self.play_audio = true

	self.act_id = ACTIVITY_TYPE.GUILDBATTLE
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function GuildFirstView:__delete()

end

function GuildFirstView:ReleaseCallBack()
	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end
	TitleData.Instance:ReleaseTitleEff(self.node_list["Title"])
end

function GuildFirstView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.ClickHelp, self))
	self.node_list["BtnEnter"].button:AddClickListener(BindTool.Bind(self.ClickEnter, self))

	local title_id = TitleData.Instance:GetActivityTitleByType(ACTIVITY_TYPE.GUILDBATTLE)
	if title_id then
		self.node_list["Title"].image:LoadSprite(ResPath.GetTitleIcon(title_id))
		TitleData.Instance:LoadTitleEff(self.node_list["Title"], title_id, true)
	end

end

function GuildFirstView:OpenCallBack()
	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
	self:Flush()
end

function GuildFirstView:CloseCallBack()
	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end
end

function GuildFirstView:CloseWindow()
	self:Close()
end

function GuildFirstView:ClickHelp()
	local act_info = ActivityData.Instance:GetClockActivityByID(self.act_id)
	if not next(act_info) then return end
	TipsCtrl.Instance:ShowHelpTipView(act_info.play_introduction)
end

function GuildFirstView:FlushTuanZhangModel()
	local info = GameVoManager.Instance:GetMainRoleVo()
	if not self.role_model then
		self.role_model = RoleModel.New()
		self.role_model:SetDisplay(self.node_list["RoleDisplay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	end
	local act_info = ActivityData.Instance:GetActivityInfoById(ACTIVITY_TYPE.GUILDBATTLE)

	local time_des = ActivityData.Instance:GetCurServerOpenDayText(self.act_id, act_info)
	self.node_list["Text"].text.text = time_des

	self.role_model:SetModelResInfo(info, false, true, true)
	if act_info and act_info.reward_item1 and act_info.reward_item1.item_id then
		for k, v in pairs(MountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == act_info.reward_item1.item_id then
				self.role_model:SetMountResid(v.res_id, nil, true)
				self.role_model:SetCameraSetting(RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "mount"))
				self.role_model:SetRotation(Vector3(0, -55, 0))
			end
		end
	end
end

function GuildFirstView:OnFlush()
	self:FlushTuanZhangModel()
end

function GuildFirstView:ActivityCallBack(activity_type)
	if activity_type == self.act_id then
		self:Flush()
	end
end

function GuildFirstView:ClickEnter()
	self:Close()
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	if guild_id > 0 then
		ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_war)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.PleaseJoinGuild)
		ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_request)
	end
end