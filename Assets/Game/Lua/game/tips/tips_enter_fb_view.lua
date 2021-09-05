TipsEnterFbView = TipsEnterFbView or BaseClass(BaseView)
local TIME = 15
function TipsEnterFbView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/tips/enterfbtips_prefab", "EnterFbTip"},
	}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self.is_modal = true
end

function TipsEnterFbView:__delete()

end

function TipsEnterFbView:LoadCallBack()
	-- self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClose, self))
	self.node_list["BtnYes"].button:AddClickListener(BindTool.Bind(self.OnClickYes, self))
	self.node_list["BtnNo"].button:AddClickListener(BindTool.Bind(self.OnClickNo, self))

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClose, self))
	self.node_list["Bg"].rect.sizeDelta = Vector3(728,444,0)

	self.head_list = {}
	for i = 1, 3 do
		self.head_list[i] = TipsEnterFbHeadCell.New(self.node_list["Head" .. i])
	end
end

function TipsEnterFbView:ReleaseCallBack()
	for k,v in pairs(self.head_list) do
		v:DeleteMe()
	end
	self.head_list = {}
	self:RemoveCountDown()
	if self.tweener then
		self.tweener:Pause()
		self.tweener = nil
	end
end

function TipsEnterFbView:OpenCallBack()
	self:Flush()
	self:StartCountDown()
end

function TipsEnterFbView:CloseCallBack()
	self:RemoveCountDown()
	if self.tweener then
		self.tweener:Pause()
		self.tweener = nil
	end
end

function TipsEnterFbView:OnClose()
	self:OnClickNo()
end

function TipsEnterFbView:StartCountDown()
	self:RemoveCountDown()
	self.count_down = CountDown.Instance:AddCountDown(
		TIME, 1, BindTool.Bind(self.CountDown, self))
	self.node_list["TxtAgreeValue"].text.text = string.format(Language.EnterFbTip.Time,TIME)
	self.node_list["Slider"].slider.value = 0
	self.tweener = self.node_list["Slider"].slider:DOValue(1, TIME, false)
	self.tweener:SetEase(DG.Tweening.Ease.Linear)
end

function TipsEnterFbView:RemoveCountDown()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function TipsEnterFbView:CountDown(elapse_time, total_time)
	self.node_list["TxtAgreeValue"].text.text = string.format(Language.EnterFbTip.Time,math.ceil(total_time - elapse_time))
	if total_time - elapse_time <= 0 then
		self:OnClickYes()
		self:Close()
	end
end

function TipsEnterFbView:OnClickYes()
	if Scene.Instance:GetMainRole():IsQingGong() then
		self:OnClickNo()
		SysMsgCtrl.Instance:ErrorRemind(Language.QingGong.NoDeliveryQingGong)
		return
	end
	FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.ENTER_AFFIRM, TeamMemberState.AGREE_STATE)
end

function TipsEnterFbView:OnClickNo()
	FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.ENTER_AFFIRM, TeamMemberState.REJECT_STATE)
	self:Close()
end

function TipsEnterFbView:OnFlush()
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local fb_info = FuBenData.Instance:GetTeamFbRoomEnterAffirm()
	local fb_name = ""
	if fb_info.team_type == FuBenTeamType.TEAM_TYPE_TEAM_DAILY_FB then
		fb_name = Language.FuBen.ExpFuBen
	elseif fb_info.team_type == FuBenTeamType.TEAM_TYPE_TEAM_EQUIP_FB then
		local config = FuBenData.Instance:GetShowConfigByLayer(fb_info.layer)
		if config then
			fb_name = config.name or ""
		end
	elseif fb_info.team_type == FuBenTeamType.TEAM_TYPE_MARRY_FB then
		fb_name = Language.Marriage.MarryFuben
	elseif fb_info.team_type == FuBenTeamType.TEAM_TYPE_EQUIP_TEAM_FB then
		fb_name = Language.FuBen.TeamFbName[1]
	elseif fb_info.team_type == FuBenTeamType.TEAM_TYPE_TEAM_TOWERDEFEND then
		fb_name = Language.FuBen.TeamFbName[2]
	end
	self.node_list["Txt"].text.text = fb_name
	UI:SetButtonEnabled(self.node_list["BtnYes"] , true)

	if ScoietyData.Instance:GetTeamState() then
		local info = ScoietyData.Instance:GetTeamInfo()
		if info and next(info) then
			for i = 1, 3 do
				local head = self.head_list[i]
				if head then
					local data = info.team_member_list[i]
					head:SetData(data)
					if data then
						-- 有人拒绝
						if data.fbroom_read == TeamMemberState.REJECT_STATE then
							SysMsgCtrl.Instance:ErrorRemind(string.format(Language.FuBen.Refuse, data.name))
							self:Close()
							return
						elseif role_id == data.role_id and data.fbroom_read == TeamMemberState.AGREE_STATE then
							UI:SetButtonEnabled(self.node_list["BtnYes"] , false)
						end
					end
				end
			end
		end
	else
		for k,v in pairs(self.head_list) do
			v:SetActive(false)
		end
	end
end

-------------------------------------------------玩家信息------------------------------------------------

TipsEnterFbHeadCell = TipsEnterFbHeadCell or BaseClass(BaseCell)

function TipsEnterFbHeadCell:__init()
	self:SetGray(false) --false 为置灰

	-- self.portrait_raw = self:FindObj("")

end

function TipsEnterFbHeadCell:__delete()

end

function TipsEnterFbHeadCell:OnFlush()
	if self.data then
		self:SetActive(true)
	
		AvatarManager.Instance:SetAvatar(self.data.role_id, self.node_list["portrait_raw"], self.node_list["portrait"], self.data.sex, self.data.prof, false)

		self.node_list["TxtName"].text.text = self.data.name
		self.node_list["ImgReady"]:SetActive(self.data.fbroom_read == TeamMemberState.AGREE_STATE)
		self:SetGray(self.data.fbroom_read == TeamMemberState.AGREE_STATE)
	else
		self:SetActive(false)
	end
end

-- 设置图标是否置灰
function TipsEnterFbHeadCell:SetGray(is_gray)
	-- UI:SetGraphicGrey(self.node_list["ImgBg"], is_gray)
	-- UI:SetGraphicGrey(self.node_list["portrait"], is_gray)
	-- UI:SetGraphicGrey(self.node_list["portrait_raw"], is_gray)
	-- UI:SetGraphicGrey(self.node_list["TxtName"], is_gray)
end
