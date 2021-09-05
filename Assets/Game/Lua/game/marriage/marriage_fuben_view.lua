MarriageFuBenView = MarriageFuBenView or BaseClass(BaseRender)

function MarriageFuBenView:__init(instance, mother_view)
	self.node_list["Turntable"]:SetActive(false)
	self.mother_view = mother_view
	self.turntable_info = TurntableInfoCell.New()

	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	self.lover_model = RoleModel.New()
	self.lover_model:SetDisplay(self.node_list["LoverDisplay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	local event_trigger = self.node_list["RotateEventTriggerSelf"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDragSelf, self))

	local event_trigger = self.node_list["RotateEventTriggerLover"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDragLover, self))

	local call_back = function (obj)
		if obj then
			self.load_tag = true 	--延迟加载成功
		end
	end
	self.turntable_info:LoadAsset("uis/views/welfare_prefab", "Turntable", self.node_list["Turntable"].transform, call_back)
	self.reward_list = {}
	self.reward_node_list = {}
	local child_number = self.node_list["ObjGroup"].transform.childCount
	local count = 1
	local obj = self.node_list["ObjGroup"].transform:GetChild(0).gameObject
	if string.find(obj.name, "ItemCell") ~= nil then
		self.reward_node_list[count] = obj
		self.reward_list[count] = ItemCellReward.New()
		self.reward_list[count]:SetInstanceParent(obj)
	end
	self.fight_text1 = CommonDataManager.FightPower(self, self.node_list["TxtPowerNum"], "FightPower3")
	self.fight_text2 = CommonDataManager.FightPower(self, self.node_list["TxtLovePower"], "FightPower3")

	self.node_list["Btn1"].button:AddClickListener(BindTool.Bind(self.ButtonClick, self))
	self.node_list["Btn3"].button:AddClickListener(BindTool.Bind(self.BuyClick, self))
	self.node_list["Button1"].button:AddClickListener(BindTool.Bind(self.ExitClick, self))
	self.node_list["BtnNotInTeam"].button:AddClickListener(BindTool.Bind(self.InviteClick, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OpenHelp, self))

	local condition = MarriageData.Instance:GetMarriageConditions()
	self.max_buy_times = condition ~= nil and condition.fb_buy_times_limit or 0
	self.node_list["Txt"].text.text = condition ~= nil and condition.fb_buy_times_gold_cost or 0
	for k,v in pairs(self.reward_node_list) do
		v:SetActive(false)
	end

	local rewards = MarriageData.Instance:GetQingYuanFBReward()[count].stuff_id
	self.reward_node_list[count]:SetActive(true)
	self.reward_list[count]:SetData({item_id = rewards})
	self.call = GlobalEventSystem:Bind(OtherEventType.RoleInfo, BindTool.Bind(self.LoverInfoChange, self))
	self.call2 = GlobalEventSystem:Bind(OtherEventType.TEAM_INFO_CHANGE, BindTool.Bind(self.TeamChage, self))

	MarriageData.Instance:SetFuBenOpenState(true)
	RemindManager.Instance:Fire(RemindName.MarryFuBen)
	FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.REQ_ROOM_LIST, FuBenTeamType.TEAM_TYPE_MARRY_FB)

end

function MarriageFuBenView:OnRoleDragSelf(data)
	if self.model then
		self.model:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function MarriageFuBenView:OnRoleDragLover(data)
	if self.lover_model then
		self.lover_model:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function MarriageFuBenView:ShowOrHideTab()
end

function MarriageFuBenView:TeamChage()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local list = ScoietyData.Instance:GetTeamUserList()
	for k,v in pairs(list) do
		if v ~= main_role_vo.role_id then
			self.current_info = ScoietyData.Instance:GetMemberInfoByRoleId(v)
			break
		end
	end
	local lover_in_team = false
	local list = ScoietyData.Instance:GetTeamUserList()
	local role_id = self.current_info and (self.current_info.user_id or self.current_info.role_id) or 0
	for k,v in pairs(list) do
		if v == role_id then
			lover_in_team = true
			break
		end
	end
	-- if #list > 1 then
		-- lover_in_team = true
	-- end
	self.node_list["NoteInTeam"]:SetActive(lover_in_team)
	self.node_list["BtnNotInTeam"]:SetActive(not lover_in_team)
	if lover_in_team then
		CheckCtrl.Instance:SendQueryRoleInfoReq(role_id)
	end

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	self.node_list["TextName"].text.text = main_role_vo.name
	if self.fight_text1 and self.fight_text1.text then
		self.fight_text1.text.text = string.format("%s", main_role_vo.capability)
	end

	data = {}
	data.id = main_role_vo.role_id
	data.prof = main_role_vo.prof
	data.sex = main_role_vo.sex
	data.avatar_key_big = main_role_vo.avatar_key_big
	data.avatar_key_small = main_role_vo.avatar_key_small
	local is_leader = self:CheckIsTeamLeader(main_role_vo.role_id)
	if is_leader ~= nil then
		self.node_list["tab_duizhang1"]:SetActive(is_leader)
		UI:SetButtonEnabled(self.node_list["Button1"], true)
	else
		self.node_list["tab_duizhang1"]:SetActive(false)
		UI:SetButtonEnabled(self.node_list["Button1"], false)
	end
end

function MarriageFuBenView:LoverInfoChange(id, info)
	local lover_id = self.current_info and (self.current_info.user_id or self.current_info.role_id) or 0
	if lover_id == nil or lover_id == 0 then
		return
	end
	if id == lover_id then
		local name = self.current_info.gamename or self.current_info.name
		if self.current_info.is_online and self.current_info.is_online ~= 1 then
			name = name .. "(" .. Language.Common.OutLine .. ")"
		end
		self.node_list["TxtInTeam"].text.text = name
		if self.fight_text2 and self.fight_text2.text then
			self.fight_text2.text.text = string.format("%s", info.capability)
		end
		local data = {}
		data.id = lover_id
		data.prof = info.prof
		data.sex = info.sex
		data.avatar_key_big = info.avatar_key_big
		data.avatar_key_small = info.avatar_key_small
		local is_leader = self:CheckIsTeamLeader(lover_id)
		if is_leader ~= nil then
			self.node_list["tab_duizhang2"]:SetActive(is_leader)
		else
			self.node_list["tab_duizhang2"]:SetActive(false)
		end
		self:LoadHeadIcon(data, self.node_list["ImgDefIcon1"], self.node_list["LoverImage"])
		self.node_list["ImgDefIcon1"].button:AddClickListener(BindTool.Bind(self.OnClickHead, self, name, lover_id))
		self.node_list["LoverImage"].button:AddClickListener(BindTool.Bind(self.OnClickHead, self, name, lover_id))
	end
	self:Flush()
end

function MarriageFuBenView:__delete()
	GlobalEventSystem:UnBind(self.call)
	GlobalEventSystem:UnBind(self.call2)
	self.mother_view = nil
	
	if self.turntable_info ~= nil then
		self.turntable_info:DeleteMe()
	end
	self.turntable_info = nil

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	if self.lover_model then
		self.lover_model:DeleteMe()
		self.lover_model = nil
	end

	if self.reward_list then
		for k,v in pairs(self.reward_list) do
			v:DeleteMe()
		end
		self.reward_list = {}
	end
	self.fight_text1 = nil
	self.fight_text2 = nil
end

function MarriageFuBenView:ExitClick()
	FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.EXIT_ROOM, FuBenTeamType.TEAM_TYPE_MARRY_FB)
end

function MarriageFuBenView:InviteClick()
	if ScoietyData.Instance:GetTeamState() then
		ScoietyCtrl.Instance:ExitTeamReq()
	end
	local param_t = {}
	param_t.must_check = 0
	param_t.assign_mode = 1
	ScoietyCtrl.Instance:CreateTeamReq(param_t)
	self:OpenFriendList()
end

--打开帮助
function MarriageFuBenView:OpenHelp()
	local tips_id = 73		--策划随便定义的
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function MarriageFuBenView:OpenFriendList()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local sex = main_role_vo.sex == 1 and 0 or 1
	local callback = BindTool.Bind(self.SelectFriendCallBack, self)
	MarriageCtrl.Instance:ShowFriendListView(callback, sex)
end

function MarriageFuBenView:SelectFriendCallBack(role_info)
	self.current_info = role_info
	ScoietyCtrl.Instance:InviteUserReq(role_info.user_id)
end

function MarriageFuBenView:ButtonClick()
	local info = ScoietyData.Instance:GetTeamInfo()
	local open_level = OpenFunData.Instance:GetOpenLevel("marriage_fuben")
	if info and info.team_member_list and open_level > 1 then
		for k,v in pairs(info.team_member_list) do
			if v and v.level < open_level then
				return SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.NotEnterFuBen)
			end
		end
	end

	FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.CREATE_ROOM, FuBenTeamType.TEAM_TYPE_MARRY_FB)
	FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.CHANGE_MODE, FuBenTeamType.TEAM_TYPE_MARRY_FB)

	local data = MarriageData.Instance:GetQingYuanFBInfo()
	local list = ScoietyData.Instance:GetTeamUserList()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if data == nil then
		return
	end
	if data.join_fb_times <= 0 or data.buy_fb_join_times >= data.join_fb_times then
		--够次数
		if #list ~= 2 then
			TipsCtrl.Instance:ShowSystemMsg(Language.Society.TeamNotEnough)
			return
		end
		if self.current_info.sex == main_role_vo.sex then
			SysMsgCtrl.Instance:ErrorRemind(Language.Society.NotSex)
			return
		end
		FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.START_ROOM)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.NotEnterTime)
	end
end

function MarriageFuBenView:BuyClick()
	local data = MarriageData.Instance:GetQingYuanFBInfo()
	if data == nil then
		return
	end
	if data.buy_fb_join_times >= self.max_buy_times then
		--不能买
		TipsCtrl.Instance:ShowSystemMsg(Language.Marriage.RestToOnly .. ToColorStr(self.max_buy_times, TEXT_COLOR.GREEN) .. Language.Common.TimesNumber)
	else
		--能买
		local other_cfg = MarriageData.Instance:GetMarriageConditions()
		local reset_cost = 0
		if other_cfg ~= nil then
			reset_cost = other_cfg.first_buy_cost
			if data.buy_fb_join_times >= 2 then
				reset_cost = other_cfg.third_buy_cost
			elseif data.buy_fb_join_times >= 1 then
				reset_cost = other_cfg.second_buy_cost
			end
		end

		local str = string.format(Language.Marriage.ResetFuBen, ToColorStr(reset_cost, CHAT_COLOR.GREEN))
		local click_func = function ()
			MarriageCtrl.Instance:SendQingYuanFBInfoReq(QINGYUAN_FB_OPERA_TYPE.QINGYUAN_FB_OPERA_TYPE_BUY_TIMES)
		end
		TipsCtrl.Instance:ShowCommonAutoView("marriage_fuben", str, click_func, nil, true, nil, nil, Language.FB.ExpFbResetTimesRedStr, nil, false)
	end
end

function MarriageFuBenView:OnFlush()
	local data = MarriageData.Instance:GetQingYuanFBInfo()
	local cond_cfg = MarriageData.Instance:GetMarriageConditions()
	local count = cond_cfg ~= nil and cond_cfg.fb_free_times_limit or 0
	if data == nil then
		return
	end
	self:FlushDisPlay()
	if data.join_fb_times <= 0 then
		self.node_list["FbCount"].text.text = data.buy_fb_join_times + count
	else
		local des = data.buy_fb_join_times + count - data.join_fb_times
		if des >= 0 then
			self.node_list["FbCount"].text.text = des
		else
			self.node_list["FbCount"].text.text = 0
		end
	end

	local level_count = self.max_buy_times - data.buy_fb_join_times
	if level_count >= 0 then
		self.node_list["BuyCount"].text.text = level_count
	else
		self.node_list["BuyCount"].text.text = 0
	end
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	AvatarManager.Instance:SetAvatar(role_vo.role_id, self.node_list["SelfImage"],self.node_list["ImgDefIcon"], role_vo.sex, role_vo.prof, false)

	self:TeamChage()
	if self.load_tag then
		self.turntable_info:SetShowEffect(WelfareData.Instance:GetTurnTableRewardCount() ~= 0)
	end
	
end

function MarriageFuBenView:FlushDisPlay()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local role_vo = {}
	role_vo.prof = main_role_vo.prof
	role_vo.sex = main_role_vo.sex
	role_vo.appearance = {}
	role_vo.appearance.fashion_body = 2
	self.model:SetModelResInfo(role_vo, true, true, true, true)	

		--有伴侣才加载伴侣模型
	GlobalTimerQuest:AddDelayTimer(function()
		if main_role_vo.lover_uid > 0 and self.lover_model then
			local lover_vo = {}
			lover_vo.prof = MarriageData.Instance:GetLoverProf()
			lover_vo.sex = main_role_vo.sex == 0 and 1 or 0
			lover_vo.appearance = {}
			lover_vo.appearance.fashion_body = 2
			self.lover_model:SetModelResInfo(lover_vo, true, true, true, true)
		end
	end, 0)
	local sex = GameVoManager.Instance:GetMainRoleVo().sex ~= 0
	self.node_list["Img1"]:SetActive(sex)
	self.node_list["Img2"]:SetActive(not sex)
	self.node_list["ImgLover"]:SetActive(not (main_role_vo.lover_uid > 0))	
end

function MarriageFuBenView:LoadHeadIcon(data, def_icon, sp_icon)
		AvatarManager.Instance:SetAvatar(data.id, sp_icon,def_icon, data.sex, data.prof, false)
end

function MarriageFuBenView:OnClickHead(name, role_id)
	if role_id == GameVoManager.Instance:GetMainRoleVo().role_id then
		return
	end
	ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, name)
end

function MarriageFuBenView:CheckIsTeamLeader(role_id)
	local leader_index = ScoietyData.Instance:GetTeamLeaderIndex()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local list = ScoietyData.Instance:GetTeamUserList()
	for k,v in pairs(list) do
		-- if leader_index == k - 1 then
		if k == 1 then
			return v == role_id
		end
	end
end