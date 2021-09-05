TeamFBType = {
	[1] = FuBenTeamType.TEAM_TYPE_EQUIP_TEAM_FB,
	[2] = FuBenTeamType.TEAM_TYPE_TEAM_TOWERDEFEND,				--组队塔防
	-- [3] = FuBenTeamType.TEAM_TYPE_YAOSHOUJITANG,
}

--------- 功能划分 ---------
-- 点击事件
-- 房间列表
-- 房间相关
-- 副本格子
-- 奖励显示

TeamFBContent = TeamFBContent or BaseClass(BaseRender)

function TeamFBContent:__init()

	self:InitRoomScroller()

	self:InitTeamRoom()

	self.item_cell_list = self.node_list["Content"]

	self.fuben_scroller = self.node_list["LeftFrame"]
	local scroller_delegate = self.fuben_scroller.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetFubenNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.FlushFuBenCellView, self)

	self.node_list["ButtonStart"].button:AddClickListener(BindTool.Bind(self.OnClickTeamEnter, self))
	self.node_list["ButtonZuDui"].button:AddClickListener(BindTool.Bind(self.OnClickZuDui, self))
	self.node_list["ButtonZuDui2"].button:AddClickListener(BindTool.Bind(self.OnClickZuDui, self))
	self.node_list["ButtonExit"].button:AddClickListener(BindTool.Bind(self.OnClickExit, self))
	self.node_list["ButtonHelp"].button:AddClickListener(BindTool.Bind(self.OnButtonHelp, self))
	self.node_list["BtnReward"].button:AddClickListener(BindTool.Bind(self.OnButtonReward, self))
	-- self.node_list["OnClickHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.fuben_cell_list = {}
	self.fuben_list_info = FuBenData.Instance:GetFubenCellInfo()
	self.reward_cell_list = {}
	self.monster_model = RoleModel.New()
	self.monster_model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	self:ChangeIndexBySeq()
	-- TeamFbCtrl.Instance:SetInfoCallBack(BindTool.Bind(self.RemainTimeChanges,self))
	-- self:RemainTimeChanges()
end

function TeamFBContent:__delete()
	for k,v in pairs(self.fuben_cell_list) do
		v:DeleteMe()
	end
	self.fuben_cell_list = {}

	for k,v in pairs(self.reward_cell_list) do
		v:DeleteMe()
	end
	self.fuben_cell_list = {}

	for k,v in pairs(self.team_cell_list) do
		v:DeleteMe()
	end
	self.team_cell_list = {}
	if self.cap_info then
		self.cap_info:DeleteMe()
		self.cap_info = nil
	end
	if self.monster_model ~= nil then
		self.monster_model:DeleteMe()
		self.monster_model = nil
	end

	if self.request_timer then
		GlobalTimerQuest:CancelQuest(self.request_timer)
		self.request_timer = nil
	end
end

function TeamFBContent:LoadCallBack()
	FuBenCtrl.Instance:SetTeamRemind()
end

function TeamFBContent:ChangeIndexBySeq()
	self.default_choose = FuBenData.Instance:GetDefaultChoose() or 1
	self.cur_choose = self.default_choose or 1
	self:ChangeIndex(self.default_choose)
end

function TeamFBContent:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["LeftFrame"], Vector3(-100, -27, 0))
	UITween.MoveShowPanel(self.node_list["RightFrame"], Vector3(250, -27, 0))
	FuBenCtrl.Instance:SetTeamFuBenBg(TeamFBType[self.cur_choose])
end

function TeamFBContent:OnFlush()
	self.node_list["BtnReward"]:SetActive(true)
	local team_info = FuBenData.Instance:GetTeamFbRoomList()
	local team_state = ScoietyData.Instance:GetTeamState()
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id

	local is_self_cap = ScoietyData.Instance:MainRoleIsCap()
	self.node_list["ButtonStart"]:SetActive(is_self_cap)
	self.node_list["ButtonZuDui"]:SetActive(is_self_cap)
	
	local cur_state = team_state and self:CheckIsTrueType()
	self.node_list["TeamPanel2"]:SetActive(cur_state and not self:CheckIsNeedShowRoomList())
	self.node_list["NoTeam"]:SetActive(not (cur_state) and self:CheckIsNeedShowRoomList())
	self.node_list["ButtonZuDui"]:SetActive(not (cur_state)) 
	self.node_list["ButtonZuDui2"]:SetActive(cur_state and self:CheckIsNeedShowRoomList())
	self.node_list["ButtonStart"]:SetActive(cur_state and not self:CheckIsNeedShowRoomList())
	self.node_list["ButtonExit"]:SetActive(cur_state)

	if self:CheckIsNeedShowRoomList() then
		self:FlushRoomList()
	else
		self:FlushTeamRoom()
	end

	local is_grey = not (self.fuben_list_info[self.cur_choose].remain_times > 0)
	UI:SetButtonEnabled(self.node_list["ButtonStart"], not is_grey)
	UI:SetButtonEnabled(self.node_list["ButtonZuDui"], not is_grey)
	UI:SetButtonEnabled(self.node_list["ButtonZuDui2"], not is_grey)
	UI:SetGraphicGrey(self.node_list["TextZuDui"], is_grey)
	UI:SetGraphicGrey(self.node_list["TextZuDui2"], is_grey)
	UI:SetGraphicGrey(self.node_list["TextStart"], is_grey)

	UI:SetButtonEnabled(self.node_list["BtnReward"], is_grey)
	self.node_list["Tips"]:SetActive(false)
	self.node_list["Effect"]:SetActive(is_grey)

	self.node_list["BtnReward"].animator:SetBool("Shake", is_grey)

	local dec = ""
	-- local buy_time = FuBenData.Instance:GetFBTowerRewardInfo().today_buy_times or 0

	local info = FuBenData.Instance:GetFBTowerRewardInfo()
	local buy_time = 0 
	if TeamFBType[self.cur_choose] and info and info[TeamFBType[self.cur_choose]] then
		buy_time = info[TeamFBType[self.cur_choose]].today_buy_times or 0
	end
	if buy_time == 0 then
		dec = Language.FuBen.TeamFBRewardTxt1
	else
		dec = Language.FuBen.TeamFBRewardTxt2
	end
	self.node_list["BtnRewardTxt"].text.text = dec
	if buy_time == 2 then
		--UI:SetButtonEnabled(self.node_list["BtnReward"], false)
		self.node_list["BtnReward"]:SetActive(false)
		self.node_list["Effect"]:SetActive(false)
		self.node_list["Tips"]:SetActive(false)
		self.node_list["BtnReward"].animator:SetBool("Shake", false)
	end

	-- local help_reward_value = FuBenData.Instance:GetHelpReward()
	-- local max_help_value = FuBenData.Instance:GetMaxHelpValue()
	-- local help_string = string.format(Language.FuBen.TeamFbHelp, help_reward_value, max_help_value)
	self.node_list["HelpReward"].text.text = Language.FuBen.TeamFbHelp

	if self.fuben_scroller.scroller.isActiveAndEnabled then
		self.fuben_scroller.scroller:ReloadData(0)
	end
end

function TeamFBContent:CheckIsNeedShowRoomList()
	local flag = true
	if ScoietyData.Instance:GetTeamState() then
		if self:CheckIsTrueType() then
			flag = false
		end
	end
	return flag
end

function TeamFBContent:CheckIsTrueType()
	local team_info = ScoietyData.Instance:GetTeamInfo() or {}
	local team_type = team_info.team_type or 0
	if team_type == TeamFBType[self.cur_choose] then
		return true
	end
	return false
end

function TeamFBContent:CancelRequest()
	if self.request_timer then
		GlobalTimerQuest:CancelQuest(self.request_timer)
		self.request_timer = nil
	end
end

function TeamFBContent:OpenRequestTeamList()
		-- 请求房间列表
	if self.request_timer then
		GlobalTimerQuest:CancelQuest(self.request_timer)
		self.request_timer = nil
	end
	if nil == self.request_timer then
		self.request_timer = GlobalTimerQuest:AddRunQuest(function()
			FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.REQ_ROOM_LIST, TeamFBType[self.cur_choose])
		end, 5) 		-- 因为这个刷新导致加载图片闪烁
	end
end

function TeamFBContent:ChangeIndex(index)
	FuBenCtrl.Instance:SendTeamTowerRewardInfo(TeamFBType[index], 0)
	self.cur_choose = index or self.cur_choose
	if index then
		for k,v in pairs(self.fuben_cell_list) do
			v.toggle.isOn = v.index == index
		end
	end
	FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.REQ_ROOM_LIST, TeamFBType[self.cur_choose])
	self:OpenRequestTeamList()
	if TeamFBType[self.cur_choose] == FuBenTeamType.TEAM_TYPE_TEAM_TOWERDEFEND then
		local function callback()
			self.monster_model:SetScale(Vector3(1.5, 1.5, 1.5))
			self.monster_model:SetLocalPosition(Vector3(-0.1, -0.95, 1))
		end
		local other_cfg = FuBenData.Instance:GetGuaJiPos()
		local bundle, asset = ResPath.GetMonsterModel(other_cfg.team_life_tower_monster_res)
		self.monster_model:SetMainAsset(bundle, asset, callback)
	end
	self.node_list["Display"]:SetActive(TeamFBType[self.cur_choose] == FuBenTeamType.TEAM_TYPE_TEAM_TOWERDEFEND)
	FuBenCtrl.Instance:SetTeamFuBenBg(TeamFBType[self.cur_choose])
	self:FlushReward()
end

function TeamFBContent:RemainTimeChanges()
	self.fuben_list_info = FuBenData.Instance:GetFubenCellInfo()
	for k,v in pairs(self.fuben_cell_list) do
		v:ChangeRemainTimes(self.fuben_list_info[v.index].remain_times)
	end
end

-- 副本格子
function TeamFBContent:GetFubenNumberOfCells()
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	local need_level = FuBenData.Instance:GetGuaJiPos()
	return  my_level >= need_level.open_level and #FuBenData.Instance:GetFubenCellInfo() or #FuBenData.Instance:GetFubenCellInfo() - 1
end

function TeamFBContent:FlushFuBenCellView(cellObj, cell_index, data_index)
	data_index = data_index + 1
	local cell = self.fuben_cell_list[cellObj]
	if cell == nil then
		self.fuben_cell_list[cellObj] = TeamFBItem.New(cellObj)
		cell = self.fuben_cell_list[cellObj]
		cell.toggle.group = self.fuben_scroller.toggle_group
	end
	cell:SetIndex(data_index)
	local data = self.fuben_list_info[data_index]
	if data then
		cell:SetData(data)
	end
	cell:SetClickCallBack(BindTool.Bind(self.ChangeIndex,self))
	if self.default_choose and data_index == self.default_choose then
		cell.toggle.isOn = true
		self.default_choose = nil
	end
end


----------------------------------------奖励物品相关-----------------------
function TeamFBContent:FlushReward()
	for k,v in pairs(self.reward_cell_list) do
		v:SetItemActive(false)
	end
	local reward_data = FuBenData.Instance:GetReward(self.cur_choose)

	for i = 1, #reward_data + 1 do
		if not self.reward_cell_list[i] then
			local cell = ItemCell.New()
			cell:SetInstanceParent(self.item_cell_list)
			cell:SetShowOrangeEffect(true)
			cell:SetData(reward_data[i - 1])
			self.reward_cell_list[i] = cell
		else
			self.reward_cell_list[i]:SetData(reward_data[i - 1])
		end
		if reward_data[i - 1] then
			self.reward_cell_list[i]:SetItemActive(true)
		end
	end

end

----------------------------点击事件相关--------------------
-- 组队进入按钮
function TeamFBContent:OnClickTeamEnter()
	if Scene.Instance:GetSceneType() ~= SceneType.Common then
		return SysMsgCtrl.Instance:ErrorRemind(Language.Map.DontEnterFB)
	end
	local info = ScoietyData.Instance:GetTeamInfo()
	local open_list = FuBenData.Instance:GetOpenList()
	if info and info.team_member_list and open_list then
		for k,v in pairs(info.team_member_list) do
			if v and v.level < open_list[self.cur_choose] then
				return SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.NotEnterFuBen)
			end
		end
	end
	self:CancelRequest()
	ViewManager.Instance:CloseAll()
	FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.START_ROOM)
end

-- 组队（创建房间）
function TeamFBContent:OnClickZuDui()
	if ScoietyData.Instance:GetTeamState() then
		if ScoietyData.Instance:MainRoleIsCap() then
			FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.CHANGE_MODE, TeamFBType[self.cur_choose])
		else
			-- SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.NoCap)
			local func = function()
				FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.EXIT_ROOM)
				FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.CREATE_ROOM, TeamFBType[self.cur_choose])
			end
			TipsCtrl.Instance:ShowCommonAutoView("", Language.FuBen.IsLeaveTeam, func)
		end
	else
		self:CancelRequest()
		FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.CREATE_ROOM, TeamFBType[self.cur_choose])
	end

end

-- 退出房间
function TeamFBContent:OnClickExit()
	FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.EXIT_ROOM)
	FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.REQ_ROOM_LIST, TeamFBType[self.cur_choose])
	self:OpenRequestTeamList()
end

function TeamFBContent:OnButtonHelp()
	local tips_id = 0
	if self.cur_choose == FuBenTeamType.TEAM_TYPE_TEAM_TOWERDEFEND then
		tips_id = 297
	else
		tips_id = 296
	end
	
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

-- 踢出
function TeamFBContent:OnClickKickOut(name, role_id)
	if ScoietyData.Instance:MainRoleIsCap() then
		local des = string.format(Language.Society.KickOutTeam, name)
		local ok_callback = function() FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.KICK_OUT, role_id) end
		TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback)
	end
end

-- 点击头像
function TeamFBContent:OnClickHead(name, role_id, click_obj)
	if role_id == GameVoManager.Instance:GetMainRoleVo().role_id then
		return
	end
	ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, name)
end

function TeamFBContent:OnClickHelp()
	local tips_list = {[1] = 245,[3] = 246, [2] = 247}
	TipsCtrl.Instance:ShowHelpTipView(tips_list[self.cur_choose])
end

function TeamFBContent:OnButtonReward()
	if FuBenData.Instance:GetIsInFuBenScene() then
		SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.FuBenNotSaoDang)
		return
	end
	local cfg = FuBenData.Instance:GetFBTowerEquipRewardCfg(TeamFBType[self.cur_choose])
	if cfg == nil then return end
	local role_info = GameVoManager.Instance:GetMainRoleVo()
	if role_info and role_info.vip_level < cfg.double_reward_need_vip_level then
		local error_dec = string.format(Language.FuBen.TeamFBRewardError, cfg.double_reward_need_vip_level)
		SysMsgCtrl.Instance:ErrorRemind(error_dec)
		return
	end
	local info = FuBenData.Instance:GetFBTowerRewardInfo()
	local buy_time = 0 
	if TeamFBType[self.cur_choose] and info and info[TeamFBType[self.cur_choose]] then
		buy_time = info[TeamFBType[self.cur_choose]].today_buy_times or 0
	end
	local function ok_func()
		FuBenCtrl.Instance:SendTeamTowerRewardInfo(TeamFBType[self.cur_choose], buy_time + 1)
	end
	
	local cost_num = 0
	local is_buy_1 = role_info.vip_level >= cfg.double_reward_need_vip_level and role_info.vip_level <= cfg.triple_reward_need_vip_level
	local is_buy_2 = role_info.vip_level > cfg.triple_reward_need_vip_level
	if (is_buy_1 or is_buy_2) and buy_time == 0  then
		cost_num = cfg.buy_double_reward_gold
	else
		cost_num = cfg.buy_triple_reward_gold
	end
	local des = string.format(Language.FuBen.TeamFBReward, cost_num)
	TipsCtrl.Instance:ShowCommonAutoView("", des, ok_func)
end



----------------------------------------房间列表---------------------------------------------------

--初始化滚动条
function TeamFBContent:InitRoomScroller()
	self.team_scroller = self.node_list["TeamScroller"]
	self.team_cell_list = {}
	self.room_list_info = {}
	local scroller_delegate = self.team_scroller.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetRoomNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.GetRoomCellView, self)
end

--滚动条数量
function TeamFBContent:GetRoomNumberOfCells()
	return self.room_list_info.count or 0
end

--滚动条刷新
function TeamFBContent:GetRoomCellView(cellObj, data_index)
	local cell = self.team_cell_list[cellObj]
	if cell == nil then
		self.team_cell_list[cellObj] = KuaFuFuBenRoomScrollCell.New(cellObj)
		cell = self.team_cell_list[cellObj]
	end
	cell:SetIndex(data_index)
	cell:SetTeamType(TeamFBType[self.cur_choose])
	local data = self.room_list_info.room_list[data_index + 1]
	if data then
		cell:SetData(data)
	end
end

function TeamFBContent:FlushRoomList()
	self.room_list_info = FuBenData.Instance:GetTeamFbRoomList()
	if self.room_list_info and self.room_list_info.count then
		self.node_list["TextNoteam"]:SetActive(self.room_list_info.count <= 0)
		if self.team_scroller.scroller.isActiveAndEnabled then
			self.team_scroller.scroller:RefreshAndReloadActiveCellViews(true)
		end
	end
end

-- 房间信息 
function TeamFBContent:InitTeamRoom()
	self.cap_info = FuBenTeamTowerRoom.New(self.node_list["CaptainrInfo"])
	self.team_member_list = {}
	self.team_member_list[1] = FuBenTeamTowerRoom.New(self.node_list["MemberInfo1"])
	self.team_member_list[1]:LoadTeamShowMember(1)
	self.team_member_list[2] = FuBenTeamTowerRoom.New(self.node_list["MemberInfo2"])
	self.team_member_list[2]:LoadTeamShowMember(2)
end

function TeamFBContent:FlushTeamRoom()
	self:CancelRequest()
	local info = ScoietyData.Instance:GetTeamInfo()
	if info and info.team_member_list then
		local i = 1
		for k,v in pairs(self.team_member_list) do
			self.team_member_list[k]:InitRoomButton()
			self.team_member_list[k]:SetTeamIndex(self.cur_choose)
		end
		for k,v in pairs(info.team_member_list) do
			local teammate_info = v
			if teammate_info then
				-- 如果是队员
				if not ScoietyData.Instance:IsLeaderById(teammate_info.role_id) then
					self.team_member_list[i]:FlushMemberInfo(teammate_info, info.team_type)
					i = i + 1
				end
			end
		end
		self.cap_info:FlushInfo()
	end
end

--------------------------------------- 房间信息 ----------------------------------------------
FuBenTeamTowerRoom = FuBenTeamTowerRoom or BaseClass(BaseCell)

function FuBenTeamTowerRoom:__init()
	self.cur_index = 0
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtCount"], "FightPower3")
end

function FuBenTeamTowerRoom:__delete()
	self.fight_text = nil
end

function FuBenTeamTowerRoom:FlushInfo()
	-- body
	local info = ScoietyData.Instance:GetTeamInfo()
	-- local player_info = FuBenData.Instance:GetTeamTowerDefendInfo()
	local leader_index = ScoietyData.Instance:GetTeamLeaderIndex() or 0

	leader_index = leader_index + 1
	local cap_info = info.team_member_list[leader_index]
	if cap_info then
		self.node_list["TxtName"].text.text = cap_info.name
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = cap_info.capability
		end
		self.node_list["TeamType"]:SetActive(info.team_type == FuBenTeamType.TEAM_TYPE_TEAM_TOWERDEFEND)
		local attr_type = FuBenData.Instance:GetTeamTowerDefendInfoAttrById(cap_info.role_id) or 0
		self.node_list["BtnIcon"].image:LoadSprite(ResPath.GetTowerSkillTypeIcon(attr_type))
		self.node_list["SkillName"].text.text = Language.FuBen.TeamFbSkillNameTwo[attr_type]

		AvatarManager.Instance:SetAvatar(cap_info.role_id, self.node_list["portrait_raw"], self.node_list["portrait"], cap_info.sex, cap_info.prof, false)

		UI:SetGraphicGrey(self.node_list["portrait"], not (cap_info.is_online == 1))
		UI:SetGraphicGrey(self.node_list["portrait_raw"], not (cap_info.is_online == 1))
		-- self.node_list["ImgOffLine"]:SetActive(not (cap_info.is_online == 1))
		self.node_list["ImgIcon"].button:AddClickListener(BindTool.Bind(self.OnClickHead, self, cap_info.name, cap_info.role_id))
		self.node_list["TeamType"].button:AddClickListener(BindTool.Bind(self.OnSkillClick, self, cap_info.name, 
			cap_info.role_id))--, self.node_list["TxtName"].gameObject.transform.position))
	end
end

function FuBenTeamTowerRoom:FlushMemberInfo(meminfo, team_type)
	if not meminfo then
		self.node_list["MemberInfoNode"]:SetActive(false)
		self.node_list["BtnShowMember"]:SetActive(true)
		-- self.node_list["ImgOffLine"]:SetActive(false)
		self.node_list["TeamType"]:SetActive(false)
		return
	end
	self.node_list["MemberInfoNode"]:SetActive(true)
	self.node_list["BtnShowMember"]:SetActive(false)
	-- self.node_list["ImgOffLine"]:SetActive(true)
	self.node_list["TxtName"].text.text = meminfo.name
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = meminfo.capability
	end
	self.node_list["TeamType"]:SetActive(team_type == FuBenTeamType.TEAM_TYPE_TEAM_TOWERDEFEND)

	local attr_type = FuBenData.Instance:GetTeamTowerDefendInfoAttrById(meminfo.role_id) or 0
	self.node_list["BtnIcon"].image:LoadSprite(ResPath.GetTowerSkillTypeIcon(attr_type))
	self.node_list["SkillName"].text.text = Language.FuBen.TeamFbSkillNameTwo[attr_type]
	UI:SetGraphicGrey(self.node_list["portrait"], not (meminfo.is_online == 1))
	UI:SetGraphicGrey(self.node_list["portrait_raw"], not (meminfo.is_online == 1))
	-- self.node_list["ImgOffLine"]:SetActive(not meminfo.is_online == 1)

	AvatarManager.Instance:SetAvatar(meminfo.role_id, self.node_list["portrait_raw"], self.node_list["portrait"], meminfo.sex, meminfo.prof, false)
	
	self.node_list["BtnShowKickOut"].button:AddClickListener(BindTool.Bind(self.OnClickKickOut, self, meminfo.name, meminfo.role_id))
	self.node_list["BtnTower"].button:AddClickListener(BindTool.Bind(self.OnClickKickOut, self, meminfo.name, meminfo.role_id))
	self.node_list["ImgSmallRole"].button:AddClickListener(BindTool.Bind(self.OnClickHead, self,meminfo.name, meminfo.role_id))
	self.node_list["TeamType"].button:AddClickListener(BindTool.Bind(self.OnSkillClick, self, meminfo.name, 
		meminfo.role_id))--, self.node_list["TxtName"].gameObject.transform.position))
	if ScoietyData.Instance:MainRoleIsCap() then
		self.node_list["BtnTower"]:SetActive(team_type == FuBenTeamType.TEAM_TYPE_TEAM_TOWERDEFEND)
		self.node_list["BtnShowKickOut"]:SetActive(team_type ~= FuBenTeamType.TEAM_TYPE_TEAM_TOWERDEFEND)
	else
		self.node_list["BtnTower"]:SetActive(false)
		self.node_list["BtnShowKickOut"]:SetActive(false)
	end
end

function FuBenTeamTowerRoom:OnClickHead(name, role_id)
	if role_id == GameVoManager.Instance:GetMainRoleVo().role_id then
		return
	end
	ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, name)
end

function FuBenTeamTowerRoom:OnSkillClick(name, id)--, pos)
	local is_self_cap = ScoietyData.Instance:MainRoleIsCap()
	local pos = self.node_list["TxtName"].gameObject.transform.position 		--不能直接传是因为button取的是是动画开始时的位置
	if is_self_cap and pos then
		FuBenData.Instance:SendID(id)
		FuBenData.Instance:SendPos(pos)
		ViewManager.Instance:Open(ViewName.FuBenTowerSelectView)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.CantSelectSkill)
	end
end

function FuBenTeamTowerRoom:OnClickKickOut(name, role_id)
	if ScoietyData.Instance:MainRoleIsCap() then
		local des = string.format(Language.Society.KickOutTeam, name)
		local ok_callback = function() FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.KICK_OUT, role_id) end
		TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback)
	end
end

function FuBenTeamTowerRoom:SetTeamIndex(index)
	self.cur_index = index
end

function FuBenTeamTowerRoom:LoadTeamShowMember(index)
	self.node_list["BtnShowMember"].button:AddClickListener(BindTool.Bind(self.OnClickInvite, self))
end

-- 点击邀请
function FuBenTeamTowerRoom:OnClickInvite(index)
	if self.cur_index == 1 then
		TipsCtrl.Instance:ShowInviteView(ScoietyData.InviteOpenType.EquipTeamFbNew)
	elseif self.cur_index == 2 then
		TipsCtrl.Instance:ShowInviteView(ScoietyData.InviteOpenType.TeamTowerDefend)
	-- elseif self.cur_choose == 3 then
	-- 	TipsCtrl.Instance:ShowInviteView(ScoietyData.InviteOpenType.TeamYaoshouInvite)
	end
end

function FuBenTeamTowerRoom:InitRoomButton( )
	self.node_list["MemberInfoNode"]:SetActive(false)
	self.node_list["BtnShowMember"]:SetActive(true)
	self.node_list["ImgOffLine"]:SetActive(false)
	self.node_list["TeamType"]:SetActive(false)
end

----------------副本格子------------
TeamFBItem = TeamFBItem or BaseClass(BaseCell)

function TeamFBItem:__init()
	self.toggle = self.root_node.toggle
	self.is_open_value = true
	self.node_list["ItemBtn"].button:AddClickListener(BindTool.Bind(self.OnClick,self))
end

function TeamFBItem:__delete()

end

function TeamFBItem:OnFlush()
	self.node_list["Name"].text.text = Language.FuBen.TeamFbName[self.index]
	local bundle, asset = ResPath.GetFuBenTypeBg(self.index)
	self.node_list["ItemBtn"].image:LoadSprite(bundle, asset)
	if self.data then
		self:ChangeRemainTimes(self.data.remain_times)
	end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local open_list = FuBenData.Instance:GetOpenList()
	local open_level = open_list[self.index]
	if open_level then
		if vo.level >= open_level then
			self.is_open_value = true
			self.node_list["Count"]:SetActive(true)
			self.node_list["LimitText"]:SetActive(false)
			self.toggle.interactable = true
		else
			self.is_open_value = false
			self.toggle.interactable = false
			self.node_list["Count"]:SetActive(false)
			self.node_list["LimitText"]:SetActive(true)
			local limit_level = PlayerData.GetLevelString(open_level, false)
			self.node_list["LimitText"].text.text = string.format(Language.FuBen.TeamFbOpen, limit_level)
		end
	end
end

function TeamFBItem:ChangeRemainTimes(remain_times)
	if remain_times < 0 then
		remain_times = 0
	end

	local color = remain_times > 0 and COLOR.GREEN or COLOR.RED
	self.node_list["Count"].text.text = string.format(Language.FuBen.TeamFbRemainTimes, ToColorStr(remain_times, color))
end

function TeamFBItem:SetClickCallBack(click_callback)
	self.click_callback = click_callback
end

function TeamFBItem:OnClick()
	if self.click_callback and self.is_open_value then
		self.click_callback(self.index)
	end
end