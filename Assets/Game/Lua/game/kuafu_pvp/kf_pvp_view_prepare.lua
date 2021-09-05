TeamInfo = {
	TeamNoOne = 0, 				--队伍1
	TeamNoTwo = 1, 				--队伍2
}


KFPVPPrepareView = KFPVPPrepareView or BaseClass(BaseView)

function KFPVPPrepareView:__init()
	self.ui_config = {{"uis/views/kuafu3v3_prefab", "PreparePanel"}}
	
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUIHigh

	self.is_modal = true
end

function KFPVPPrepareView:LoadCallBack()
	self.node_list["TipsBtn"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
end

function KFPVPPrepareView:ReleaseCallBack()
	self:RemoveCountDown()
end

function KFPVPPrepareView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(291)
end

function KFPVPPrepareView:OpenCallBack()
	self:StartCountDown()
end

function KFPVPPrepareView:StartCountDown()
	if self.count_down then
		return
	end

	local time = KuafuPVPData.Instance:GetPrepareAndFightTime()
	local match_state = KuafuPVPData.Instance:GetPrepareInfo().match_state
	local start_time = time - TimeCtrl.Instance:GetServerTime()
	local user_list = KuafuPVPData.Instance:GetPrepareInfo().user_info_list
	local team_index = KuafuPVPData.Instance:GetRoleTeamIndex()
	if user_list == nil then
		return
	end
	for k, v in ipairs(user_list) do
		if team_index == TeamInfo.TeamNoOne then
			if k <= 3 then
				k = k + 3
			else
				k = k - 3
			end
		end
		self.node_list["Name" .. k].text.text = v.name
		local img = v.sex .. (v.prof % 10)
		local bundle, asset = ResPath.GetKf3V3FinishImg(img)
		self.node_list["RawImage" .. k].raw_image:LoadSprite(bundle, asset)
	end
	self.count_down = CountDown.Instance:AddCountDown(start_time, 1, BindTool.Bind(self.CountDown, self, self.node_list["StartTimer"]))
end

function KFPVPPrepareView:CountDown(time_obj, elapse_time, total_time)
	local time = math.ceil(total_time - elapse_time)
	if time <= 0 then
		local fight_view = KuafuPVPCtrl.Instance:GetFightView()
		-- self:StartFight()
		if fight_view and fight_view:IsOpen() then
			fight_view:StartFight()
		end
		self:RemoveCountDown()
		time = 0
		if callback then
			callback()
		end
	end
	if time_obj then
		time_obj.text.text = time
	end
end

function KFPVPPrepareView:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end
