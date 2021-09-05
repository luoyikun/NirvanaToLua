ThreeOtherFirstView = ThreeOtherFirstView or BaseClass(BaseView)

function ThreeOtherFirstView:__init()
	self.ui_config = {{"uis/views/citycombatview_prefab", "ThreeOtherFirstView"}}
	self.play_audio = true

	self.act_id = ACTIVITY_TYPE.QUNXIANLUANDOU
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function ThreeOtherFirstView:__delete()

end

function ThreeOtherFirstView:ReleaseCallBack()
	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end
	if TitleData.Instance ~= nil then
		for i = 1, 3 do
			TitleData.Instance:ReleaseTitleEff(self.node_list["ImgTitle" .. i])
		end
	end
end

function ThreeOtherFirstView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnEnter"].button:AddClickListener(BindTool.Bind(self.ClickEnter, self))
	-- self.node_list["TxtDescTime"].text.text = Language.Activity.ThreeOtherFirstDesc

	for i = 1, 3 do
		self.node_list["ImgTitle" .. i].button:AddClickListener(BindTool.Bind(self.ClickTitle, self, i))
	end
end

function ThreeOtherFirstView:OpenCallBack()
	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
	self:Flush()
end

function ThreeOtherFirstView:CloseCallBack()
	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end
end

function ThreeOtherFirstView:CloseWindow()
	self:Close()
end

function ThreeOtherFirstView:ClickTitle(index)
	local title_cfg = {}
	title_cfg = ActivityData.Instance:GetXianMoItemCfg()
	if title_cfg and title_cfg[index] then
		local data = {item_id = title_cfg[index].item_id, is_bind = 0, num = 1}
		TipsCtrl.Instance:OpenItem(data)
	end
end

function ThreeOtherFirstView:ClickEnter()
	self:Close()
	local detail_view = ActivityCtrl.Instance:GetDetailView()
	if detail_view then
		detail_view:SetActivityId(ACTIVITY_TYPE.QUNXIANLUANDOU)
		detail_view:Open()
		detail_view:Flush()
	end
end

function ThreeOtherFirstView:FlushTuanZhangModel(uid, info)
	if self.tuanzhang_uid == uid then
		if self.role_model then
			if info then
				self.role_model:SetModelResInfo(info, false, true, true, nil, nil, nil, true)
			end
		end
	end
end

function ThreeOtherFirstView:OnFlush()
	local act_info = ActivityData.Instance:GetActivityInfoById(self.act_id)
	if not next(act_info) then return end

	local time_des = ActivityData.Instance:GetCurServerOpenDayText(self.act_id, act_info)
	self.node_list["TxtDescTime"].text.text = time_des

	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	self.tuanzhang_uid = game_vo.role_id
	if not self.role_model then
		self.role_model = RoleModel.New()
		self.role_model:SetDisplay(self.node_list["RoleDisplay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	end
	self:FlushTuanZhangModel(self.tuanzhang_uid, game_vo)

	local title_cfg = ElementBattleData.Instance:GetTitleCfg()
	for i = 1, 3 do
		local res_id = title_cfg[i].title_id
		local bundle, asset = ResPath.GetTitleIcon(res_id)
		self.node_list["ImgTitle" .. i].image:LoadSprite(bundle, asset, function()
			self.node_list["ImgTitle" .. i].image:SetNativeSize()
			end)
		TitleData.Instance:LoadTitleEff(self.node_list["ImgTitle" .. i], res_id, true)
		self.node_list["TxtZhenYing" .. i].text.text = Language.Activity.XianMoZhenYing[i]

		local first_info = ActivityData.Instance:GetQunxianLuandouFirstRankInfo()
		if first_info == nil or first_info[i] == nil or "" == first_info[i] then
			self.node_list["TxtName" .. i].text.text = Language.Competition.NoRank
		else
			self.node_list["TxtName" .. i].text.text = Language.Activity.LastGame .. first_info[i]
		end
	end
end

function ThreeOtherFirstView:ActivityCallBack(activity_type)
	if activity_type == self.act_id then
		self:Flush()
	end
end