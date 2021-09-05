ScoietyTeamView = ScoietyTeamView or BaseClass(BaseRender)
function ScoietyTeamView:__init()
	self.member_list = {}
	self.node_list["BtnCreateTeam"].button:AddClickListener(BindTool.Bind(self.ClickCreateTeam, self))
	self.node_list["BtnFoundTeam"].button:AddClickListener(BindTool.Bind(self.ClickNearTeam, self))
	self.node_list["BtnTeamInvite"].button:AddClickListener(BindTool.Bind(self.ClickTeamInvite, self))

	self.node_list["AutoTeam"].toggle:AddClickListener(BindTool.Bind(self.ClickAutoJoin, self))
	self.node_list["FreePick"].toggle:AddClickListener(BindTool.Bind(self.ClickFreePick, self))
	self.node_list["AutoReceive"].toggle:AddClickListener(BindTool.Bind(self.ClickAutoTeam, self))

	self:CreateTeamList()
end

function ScoietyTeamView:__delete()
	for _, v in ipairs(self.member_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.member_list = {}
end

function ScoietyTeamView:ClearTeam()
	for k, v in ipairs(self.member_list) do
		v:SetData(nil)
	end
end

function ScoietyTeamView:CreateTeam()

end

function ScoietyTeamView:CreateTeamList()

	for i = 1, GameEnum.TEAM_MAX_COUNT do
		self["member" .. i] = RoleModelCell.New(self.node_list["Member" .. i])
		self["member" .. i]:SetIndex(i)
		self["member" .. i].scoiety_team_view = self
		table.insert(self.member_list, self["member" .. i])
	end

end

--点击自动接受组队邀请
function ScoietyTeamView:ClickAutoTeam()
	if self.node_list["AutoReceive"].toggle.isOn then
		ScoietyData.Instance:SetIsAutoJoinTeam(1)
		ScoietyCtrl.Instance:AutoApplyJoinTeam(1)
	else
		ScoietyData.Instance:SetIsAutoJoinTeam(0)
		ScoietyCtrl.Instance:AutoApplyJoinTeam(0)
	end
end

--点击自动接受入队邀请
function ScoietyTeamView:ClickAutoJoin()
	if self.node_list["AutoTeam"].toggle.isOn then
		ScoietyCtrl.Instance:ChangeMustCheckReq(0)
	else
		ScoietyCtrl.Instance:ChangeMustCheckReq(1)
	end
end

--点击自由拾取
function ScoietyTeamView:ClickFreePick()
	local main_role = Scene.Instance:GetMainRole()
	local is_leader = ScoietyData.Instance:IsLeaderById(main_role:GetRoleId())
	if not is_leader then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.IsLeaderChangeDes)
		local team_info = ScoietyData.Instance:GetTeamInfo()
		self.node_list["FreePick"].toggle.isOn = team_info.assign_mode == 2 and true or false
		return
	end
	if self.node_list["FreePick"].toggle.isOn then
		ScoietyCtrl.Instance:ChangeAssignModeReq(TEAM_ASSIGN_MODE.TEAM_ASSIGN_MODE_RANDOM)
	else
		ScoietyCtrl.Instance:ChangeAssignModeReq(TEAM_ASSIGN_MODE.TEAM_ASSIGN_MODE_KILL)
	end
end


function ScoietyTeamView:ClickCreateTeam()
	local team_state = ScoietyData.Instance:GetTeamState()
	if team_state then return end

	local param_t = {}
	param_t.must_check = 0
	param_t.assign_mode = 1
	ScoietyCtrl.Instance:CreateTeamReq(param_t, true)
end

function ScoietyTeamView:ClickNearTeam()
	ScoietyCtrl.Instance:ShowNearTeamView()
end

function ScoietyTeamView:ClickTeamInvite()
	local main_role_id = Scene.Instance:GetMainRole():GetRoleId()
	local team_state = ScoietyData.Instance:GetTeamState()
	if not team_state then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.CreateTeam)
		return
	end
	if not ScoietyData.Instance:IsLeaderById(main_role_id) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.DontInviety)
		return
	end
	TipsCtrl.Instance:ShowInviteView()
end

function ScoietyTeamView:FlushTeamView()
	--不是队长无法执行后两项操作
	local main_role = Scene.Instance:GetMainRole()
	local is_leader = ScoietyData.Instance:IsLeaderById(main_role:GetRoleId())
	local is_auto_join_team_state = ScoietyData.Instance:GetIsAutoJoinTeam()
	self.node_list["AutoReceive"].toggle.isOn = is_auto_join_team_state == 1 and true or false
	self.node_list["Check2"]:SetActive(is_leader)

	--已有队伍置灰按钮
	local team_state = ScoietyData.Instance:GetTeamState()

	self.node_list["Check1"]:SetActive(not team_state)
	self.node_list["Check3"]:SetActive(false)--策划需求隐藏
	UI:SetButtonEnabled(self.node_list["BtnCreateTeam"], not team_state)
	UI:SetGraphicGrey(self.node_list["CreateTeamText"], not team_state)
	UI:SetButtonEnabled(self.node_list["BtnTeamInvite"], true)

	local team_info = ScoietyData.Instance:GetTeamInfo()
	self.node_list["AutoTeam"].toggle.isOn = team_info.must_check == 0 and true or false
	self.node_list["FreePick"].toggle.isOn = team_info.assign_mode == 2 and true or false

	local team_user_list = ScoietyData.Instance:GetTeamUserList()
	if not next(team_user_list) then self:ClearTeam() return end
	--开始创建人员
	if team_info.member_count >= GameEnum.TEAM_MAX_COUNT then
		UI:SetButtonEnabled(self.node_list["BtnTeamInvite"], true)
	end
	local leader_index = team_info.team_leader_index or 0
	local my_index = 0
	for i = 1, GameEnum.TEAM_MAX_COUNT do
		local role_id = team_user_list[i]
		local member_info = ScoietyData.Instance:GetMemberInfoByRoleId(role_id)
		if next(member_info) then
			self["member" .. i]:SetData(member_info)
			if member_info.role_id == main_role:GetRoleId() then
				self["member" .. i]:SetRoleStateText(true)
				self["member" .. i]:SetRoleStateVisible(true)
				my_index = i
			else
				self["member" .. i]:SetRoleStateText(false)
				self["member" .. i]:SetRoleStateVisible(my_index == 1)
			end
		else
			self["member" .. i]:SetData(nil)
		end

	end
end

function ScoietyTeamView:UpdateAppearByIndex(role_id)
	local team_user_list = ScoietyData.Instance:GetTeamUserList()
	for k, v in ipairs(team_user_list) do
		if role_id == v then
			if self["member" .. k] then
				self["member" .. k]:UpdateAppearance()
			end
			break
		end
	end
end

---------------------------------------------------------------
RoleModelCell = RoleModelCell or BaseClass(BaseCell)

function RoleModelCell:__init()
	self.node_list["Member1"].toggle:AddClickListener(BindTool.Bind(self.ClickItem, self))
	self.node_list["State"].button:AddClickListener(BindTool.Bind(self.ClickState, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightPowerNumTxt"], "FightPower3")
end

function RoleModelCell:__delete()
	self.fight_text = nil
	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end
end

function RoleModelCell:OnFlush()
	if not self.data then
		self:SetActive(false)
		return
	end
	self:SetActive(true)
	self:SetRoleIcon()
	self:SetRoleInfo()

end

function RoleModelCell:SetRoleIcon()
	AvatarManager.Instance:SetAvatar(self.data.plat_role_id, self.node_list["RawImage"], self.node_list["RoleImage"], self.data.sex, self.data.prof, true)
end

function RoleModelCell:ClickState()
	local main_role = Scene.Instance:GetMainRole()
	local yes_button_text = Language.Common.Confirm
	local no_button_text = Language.Common.Cancel
	if self.data.role_id == main_role:GetRoleId() then
		local function ok_func()
			ScoietyCtrl.Instance:ExitTeamReq()
		end
		local des = Language.Society.ExitTeam

		TipsCtrl.Instance:ShowCommonAutoView("leave_team", des, ok_func)
	else
		local function ok_func()
			ScoietyCtrl.Instance:KickOutOfTeamReq(self.data.role_id)
		end
		local des = string.format(Language.Society.KickOutTeam, self.data.name)
		TipsCtrl.Instance:ShowCommonAutoView("kick_out_of_team", des, ok_func)
	end
	local is_kf_pvp_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.KF_PVP)
	if is_kf_pvp_open then
		KuafuPVPCtrl.Instance:SendCrossMultiuserChallengeGetBaseSelfSideInfo()
	end
	
end

function RoleModelCell:UpdateWingResId(vo)
	local index = vo.wing_info.used_imageid
	local wing_config = ScoietyData.Instance.wing_config
	self.wing_res_id = 0
	if wing_config then
		local image_list = wing_config.image_list[index]
		if image_list then
			self.wing_res_id = image_list.res_id
		end
	end
end

function RoleModelCell:UpdateAppearance()
	if not self.data or not next(self.data) then
		return
	end
	local vo = ScoietyData.Instance.role_vo_list[self.data.role_id]
	if not vo or not next(vo) then return end
	local prof = vo.prof % 10

	--清空缓存
	self.role_res_id = 0
	self.weapon_res_id = 0
	self.wing_res_id = 0
	-- 先查找时装的武器和衣服
	if vo.shizhuang_part_list ~= nil then
		local fashion_wuqi = vo.shizhuang_part_list[1].use_index
		local fashion_body = vo.shizhuang_part_list[2].use_index

		local fashion_cfg_list = FashionData.Instance.fashion_cfg_list
		if fashion_wuqi ~= 0 then
			local wuqi_cfg = FashionData.Instance:GetFashionConfig(fashion_cfg_list, SHIZHUANG_TYPE.WUQI, fashion_wuqi)
			local res_id = wuqi_cfg["resouce" .. prof]
			self.weapon_res_id = res_id
		end

		if fashion_body ~= 0 then
			local clothing_cfg = FashionData.Instance:GetFashionConfig(fashion_cfg_list, SHIZHUANG_TYPE.BODY, fashion_body)
			local res_id = clothing_cfg["resouce" .. prof]
			self.role_res_id = res_id
		end

		self:UpdateWingResId(vo)
	end

	-- 最后查找职业表
	local job_cfgs = ScoietyData.Instance.job_cfgs
	local role_job = job_cfgs[prof]
	if role_job ~= nil then
		if self.role_res_id == 0 then
			self.role_res_id = role_job.model
		end

		if self.weapon_res_id == 0 then
			self.weapon_res_id = role_job.weapon
		end

		if self.weapon2_res_id == 0 then
			self.weapon2_res_id = role_job.weapon2
		end
	else
		if self.role_res_id == 0 then
			self.role_res_id = 1001001
		end

		if self.weapon_res_id == 0 then
			self.weapon_res_id = 900100101
		end
	end
	self:UpdateRoleModel()
end

function RoleModelCell:UpdateRoleModel()
	if not self.role_model then
		self.role_model = RoleModel.New()
		self.role_model:SetDisplay(self.role_display.ui3d_display)
	end
	self.role_model:SetRoleResid(self.role_res_id)
	self.role_model:SetWeaponResid(self.weapon_res_id)
	self.role_model:SetWingResid(self.wing_res_id)
end

function RoleModelCell:CreateRole()
	local main_role = Scene.Instance:GetMainRole()
	if not self.role_model then
		self.role_model = RoleModel.New()
		self.role_model:SetDisplay(self.role_display.ui3d_display)
	end
	self.role_model:SetRoleResid(main_role:GetRoleResId())
	self.role_model:SetWeaponResid(main_role:GetWeaponResId())
	self.role_model:SetWingResid(main_role:GetWingResId())
end

function RoleModelCell:SetRoleInfo()
	local is_leader = ScoietyData.Instance:IsLeaderById(self.data.role_id)

	-- local lv, zhuan = PlayerData.GetLevelAndRebirth(self.data.level)
	-- local level_des = string.format(Language.Common.LevelFormat, lv, zhuan)
	self.node_list["LevelTxt"].text.text = PlayerData.GetLevelString(self.data.level)
	self.node_list["TitleDZ"]:SetActive(is_leader)
	self.node_list["TitleDY"]:SetActive(not is_leader)
	self.node_list["NameTxt"].text.text = self.data.name
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = self.data.capability
	end
	UI:SetGraphicGrey(self.node_list["RoleImage"], self.data.is_online ~= 1)
	UI:SetGraphicGrey(self.node_list["RawImage"], self.data.is_online ~= 1)
	self.node_list["SmallRoleImg"]:SetActive(self.data.is_online ~= 1)

	local prof, grade = PlayerData.Instance:GetRoleBaseProf(self.data.prof)
	local prof_str = ToColorStr(ZhuanZhiData.Instance:GetProfNameCfg(prof, grade) or "", PROF_COLOR[prof])
	self.node_list["ProfTxt"].text.text = prof_str
end

function RoleModelCell:SetRoleStateText(value)
	local text = ""
	if value then
		text = Language.Society.Leave
	else
		text = Language.Society.Kickout
	end
	self.node_list["StateTxt"].text.text = text 
end

function RoleModelCell:SetRoleStateVisible(value)
	self.node_list["State"]:SetActive(value)
end

function RoleModelCell:ClickItem()
	local function canel_callback()
		if self.root_node then
			self.root_node.toggle.isOn = false
		end
	end
	local main_role_id = GameVoManager.Instance.main_role_vo.role_id
	if main_role_id == self.data.role_id then
		self.root_node.toggle.isOn = false
	else
		ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, self.data.name, nil, canel_callback)
	end
end