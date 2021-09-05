CityCombatFirstView = CityCombatFirstView or BaseClass(BaseView)

function CityCombatFirstView:__init()
	self.ui_config = {{"uis/views/citycombatview_prefab", "CityCombatFirstView"}}
	self.play_audio = true

	self.act_id = ACTIVITY_TYPE.GONGCHENGZHAN
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function CityCombatFirstView:__delete()

end

function CityCombatFirstView:ReleaseCallBack()
	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end
	if self.wife_model then
		self.wife_model:DeleteMe()
		self.wife_model = nil
	end
	TitleData.Instance:ReleaseTitleEff(self.node_list["ImgTitle"])
	TitleData.Instance:ReleaseTitleEff(self.node_list["WifeTitle"])
end

function CityCombatFirstView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.ClickHelp, self))
	self.node_list["BtnEnter"].button:AddClickListener(BindTool.Bind(self.ClickEnter, self))

	local other_config = CityCombatData.Instance:GetOtherConfig()
	if other_config then
		self.node_list["ImgTitle"].image:LoadSprite(ResPath.GetTitleIcon(other_config.cz_chenghao))
		TitleData.Instance:LoadTitleEff(self.node_list["ImgTitle"], other_config.cz_chenghao, true)
		local game_vo = GameVoManager.Instance:GetMainRoleVo()
		local title_id = GameEnum.FEMALE ~= game_vo.sex and other_config.cz_wife_title_id or other_config.cz_husband_title_id
		self.node_list["WifeTitle"].image:LoadSprite(ResPath.GetTitleIcon(title_id))
		TitleData.Instance:LoadTitleEff(self.node_list["WifeTitle"], other_config.cz_chenghao, true)
	end
	-- self.node_list["TxtDescTime"].text.text = Language.Activity.CityCombatFirstDesc

	local event_trigger = self.node_list["EventTriggerSelf"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))

	local event_trigger_wife = self.node_list["EventTriggerWife"].event_trigger_listener
	event_trigger_wife:AddDragListener(BindTool.Bind(self.OnRoleWifeDrag, self))
end

function CityCombatFirstView:OpenCallBack()
	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
	self:Flush()
end

function CityCombatFirstView:CloseCallBack()
	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end
end

function CityCombatFirstView:CloseWindow()
	self:Close()
end

function CityCombatFirstView:OnRoleDrag(data)
	if self.role_model then
		self.role_model:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function CityCombatFirstView:OnRoleWifeDrag(data)
	if self.wife_model then
		self.wife_model:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function CityCombatFirstView:ClickHelp()
	local act_info = ActivityData.Instance:GetClockActivityByID(self.act_id)
	if not next(act_info) then return end
	TipsCtrl.Instance:ShowHelpTipView(act_info.play_introduction)
end

function CityCombatFirstView:ClickEnter()
	self:Close()
	ViewManager.Instance:Open(ViewName.CityCombatView)
end

function CityCombatFirstView:FlushTuanZhangModel(uid, info)
	if self.tuanzhang_uid == uid then
		if self.role_model then
			local other_cfg = CityCombatData.Instance:GetOtherConfig()
			for k, v in pairs(FashionData.Instance:GetShizhuangImgCfg()) do
				if v.item_id == other_cfg.cz_fashion_yifu_id then
					local base_prof = PlayerData.Instance:GetRoleBaseProf(info.prof)
					local res_id = v["resouce" .. base_prof .. info.sex]
					self.role_model:SetRoleResid(res_id)
					local transform = {position = Vector3(0.0, 1.9, 4.9), rotation = Quaternion.Euler(6, 180, 0)}
					self.role_model:SetCameraSetting(transform)
					self.role_model:SetRotation(Vector3(0, -15, 0))
					break
				end
			end
		end
		if self.wife_model then
			local other_cfg = CityCombatData.Instance:GetOtherConfig()
			for k, v in pairs(FashionData.Instance:GetShizhuangImgCfg()) do
				if v.item_id == other_cfg.cz_fashion_yifu_id then
					local base_prof = PlayerData.Instance:GetRoleBaseProf(info.prof)
					local sex = info.sex == 0 and 1 or 0
					local prof = info.sex == 0 and 1 or 3
					local res_id = v["resouce" .. prof .. sex]
					self.wife_model:SetRoleResid(res_id)
					local transform = {position = Vector3(0.0, 1.9, 4.9), rotation = Quaternion.Euler(6, 180, 0)}
					self.wife_model:SetCameraSetting(transform)
					self.wife_model:SetRotation(Vector3(0, -15, 0))
					break
				end
			end
		end
	end
end

function CityCombatFirstView:OnFlush()
	local act_info = ActivityData.Instance:GetActivityInfoById(self.act_id)
	if not next(act_info) then return end

	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	self.tuanzhang_uid = game_vo.role_id
	self.node_list["TxtName"].text.text = game_vo.name
	if not self.role_model then
		self.role_model = RoleModel.New()
		self.role_model:SetDisplay(self.node_list["RoleDisplay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	end
	if not self.wife_model then
		self.wife_model = RoleModel.New()
		self.wife_model:SetDisplay(self.node_list["WifeDisplay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	end
	self:FlushTuanZhangModel(self.tuanzhang_uid, game_vo)

	local time_des = ActivityData.Instance:GetCurServerOpenDayText(self.act_id, act_info)
	self.node_list["TxtDescTime"].text.text = time_des
end

function CityCombatFirstView:ActivityCallBack(activity_type)
	if activity_type == self.act_id then
		self:Flush()
	end
end