ManyFuBenView = ManyFuBenView or BaseClass(BaseRender)

function ManyFuBenView:__init(instance)
	if instance == nil then
		return
	end

	self.item_cell = {}
	for i = 1, 5 do
		self.item_cell[i] = {}

		self.item_cell[i].cell = ItemCell.New()
		self.item_cell[i].cell:SetInstanceParent(self.node_list["ItemCell" .. i])
	end

	self.select_fb = 0
	self.last_select_fb = -1

	self.node_list["BtnStart"].button:AddClickListener(BindTool.Bind(self.OnClickStart, self))
	self.node_list["BtnExit"].button:AddClickListener(BindTool.Bind(self.OnClickExit, self))
	self.node_list["BtnHelp"].event_trigger_listener:AddPointerClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["BtnZuDui"].button:AddClickListener(BindTool.Bind(self.OnClickZuDui, self))
	self.node_list["BtnZuDui2"].button:AddClickListener(BindTool.Bind(self.OnClickZuDui, self))
	self.node_list["BtnPlus"].button:AddClickListener(BindTool.Bind(self.OnClickPlus, self))

	self:InitTeamRoom()
	self:InitInfoScroller()
	self:InitRoomScroller()
end

function ManyFuBenView:__delete()
	for k,v in pairs(self.item_cell) do
		if v.cell then
			v.cell:DeleteMe()
			v.cell = nil
		end
	end
	self.item_cell = {}

	for k, v in pairs(self.info_cell_list) do
		v:DeleteMe()
	end
	for k, v in pairs(self.team_cell_list) do
		v:DeleteMe()
	end
	self.info_cell_list = {}
	self.team_cell_list = {}
	self.teammates = {}
	self:RemoveDelayTime()
end

function ManyFuBenView:OpenCallBack()
	self.select_fb = self:FindFB()
	self:Flush()
	if self:CheckIsNeedShowRoomList() then
		FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.REQ_ROOM_LIST, FuBenTeamType.TEAM_TYPE_TEAM_EQUIP_FB, 0, self.select_fb)
	end
end

function ManyFuBenView:JumpToIndex(index)
	if self.node_list["Scroller"].scroller.isActiveAndEnabled then
		local jump_index = index
		local scrollerOffset = 0
		local cellOffset = 0
		local useSpacing = false
		local scrollerTweenType = self.node_list["Scroller"].scroller.snapTweenType
		local scrollerTweenTime = 0
		local scroll_complete = nil
		self.node_list["Scroller"].scroller:JumpToDataIndexForce(
			jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
	else
		self:RemoveDelayTime()
		self.delay_time = GlobalTimerQuest:AddDelayTimer(function() self:JumpToIndex(index) end, 0.1)
	end
end

function ManyFuBenView:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function ManyFuBenView:OnClickStart()
	if ScoietyData.Instance:MainRoleIsCap() then
		FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.START_ROOM)
	end
end

function ManyFuBenView:OnClickExit()
	FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.EXIT_ROOM)
	FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.REQ_ROOM_LIST, FuBenTeamType.TEAM_TYPE_TEAM_EQUIP_FB, 0, self.select_fb)
end

function ManyFuBenView:OnClickKickOut(name, role_id)
	if ScoietyData.Instance:MainRoleIsCap() then
		local des = string.format(Language.Society.KickOutTeam, name)
		local ok_callback = function() FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.KICK_OUT, role_id) end
		TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback)
	end
end

function ManyFuBenView:OnClickHead(name, role_id)
	if role_id == GameVoManager.Instance:GetMainRoleVo().role_id then
		return
	end
	ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, name)
end

function ManyFuBenView:OnClickInvite()
	local config = FuBenData.Instance:GetShowConfigByLayer(self.select_fb)
	local name = ""
	if config then
		name = config.name
	end
	local team_index = ScoietyData.Instance:GetTeamIndex()
	if team_index then
		FuBenData.Instance:SetSelectFuBenLayer(self.select_fb)
		TipsCtrl.Instance:ShowInviteView(ScoietyData.InviteOpenType.ManyFuBen)
	end
end

function ManyFuBenView:OnClickFuBen(layer)
	self.select_fb = layer
	if self:CheckIsNeedShowRoomList() then
		FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.REQ_ROOM_LIST, FuBenTeamType.TEAM_TYPE_TEAM_EQUIP_FB, 0, self.select_fb)
	end
	self:Flush()
end

function ManyFuBenView:Flush()
	local IsCap = ScoietyData.Instance:MainRoleIsCap()
	local HasTeam = true
	local ShowRoomList = true
	if ScoietyData.Instance:GetTeamState() and self:CheckIsTeamEquipType() then
		HasTeam = true
	else
		HasTeam = false
	end

	if self:CheckIsNeedShowRoomList() then
		ShowRoomList = true
		self.node_list["TeamPanel"]:SetActive(HasTeam and (not ShowRoomList))
		self.node_list["NoTeam"]:SetActive((not HasTeam) or ShowRoomList)
		self.node_list["BtnZuDui2"]:SetActive(HasTeam and IsCap and ShowRoomList)
		self.node_list["BtnStart"]:SetActive(IsCap and HasTeam and (not ShowRoomList))

		self:FlushRoomList()
	else
		ShowRoomList = false
		self.node_list["TeamPanel"]:SetActive(HasTeam and (not ShowRoomList))
		self.node_list["NoTeam"]:SetActive((not HasTeam) or ShowRoomList)
		self.node_list["BtnZuDui2"]:SetActive(HasTeam and IsCap and ShowRoomList)
		self.node_list["BtnStart"]:SetActive(IsCap and HasTeam and (not ShowRoomList))
		self:FlushTeamRoom()
		if self.node_list["Scroller"].scroller.isActiveAndEnabled then
			for k,v in pairs(self.info_cell_list) do
				v:Flush()
			end
		end
	end
		self.node_list["RewardCount"]:SetActive(HasTeam)
		self.node_list["BtnZuDui"]:SetActive(not HasTeam)
		self.node_list["BtnExit"]:SetActive(HasTeam)

	self:FlushReward()
	local team_equip_fb_day_count = FuBenData.Instance:GetManyFBCount() or 0
	local total_count = FuBenData.Instance:GetManyFbTotalCount() or 0
	local rest_count = math.max(total_count - team_equip_fb_day_count, 0)
	if rest_count > 0 then
		local RewardCount = rest_count .. "/" .. total_count
		self.node_list["RewardCountTxt"].text.text = string.format(Language.FuBen.RewardTime, RewardCount)
	else
		local RewardCount = ToColorStr(rest_count, TEXT_COLOR.RED) .. "/" .. total_count
		self.node_list["RewardCountTxt"].text.text = string.format(Language.FuBen.RewardTime, RewardCount)
	end
end

function ManyFuBenView:FlushReward()
	if self.last_select_fb ~= self.select_fb then
		self.last_select_fb = self.select_fb
		local config = FuBenData.Instance:GetShowConfigByLayer(self.select_fb)
		if config then
			local reward_config = config.probability_falling
			for i = 1, 5 do
				local item = reward_config[i]
				self.item_cell[i].cell:SetParentActive(nil ~= item)
				if item then
					self.item_cell[i].cell:SetData(item)
					self.item_cell[i].cell:SetInteractable(true)
				end
			end
		end
	end
end

function ManyFuBenView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(130)
end

function ManyFuBenView:OnClickZuDui()
	if ScoietyData.Instance:GetTeamState() then
		FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.CHANGE_MODE, FuBenTeamType.TEAM_TYPE_TEAM_EQUIP_FB, 0, self.select_fb)
	else
		FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.CREATE_ROOM, FuBenTeamType.TEAM_TYPE_TEAM_EQUIP_FB, 0, 0, self.select_fb, 0)
	end
end

function ManyFuBenView:OnClickPlus()
	local price = FuBenData.Instance:GetManyFbPrice() or 0
	local des = string.format(Language.FuBen.BuyManyFB, price)
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level or 0
	local buy_count = FuBenData.Instance:GetManyFbBuyCount() or 0
	local can_buy_count = FuBenData.Instance:GetManyFbBuyCountByVip(vip_level) or 0
	local max_can_buy_count = FuBenData.Instance:GetManyFbBuyCountByVip(15) or 0
	if can_buy_count <= buy_count then
		TipsCtrl.Instance:ShowLockVipView(VIPPOWER.TEAM_EQUIP_COUNT)
		return
	end
	if buy_count >= max_can_buy_count then
		SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.MaxManyFB)
		return
	end
	local ok_callback = function()
		FuBenCtrl.Instance:SendTeamEquipFbBuyDropCountReq()
	end

	TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback)
end

-- 找到合适等级的副本
function ManyFuBenView:FindFB()
	local main_role_level = GameVoManager.Instance:GetMainRoleVo().level
	local layer = 0
	for i = FuBenData.Instance:GetCrossFBCount(), 1, -1 do
		local cfg = FuBenData.Instance:GetConfigByLayer(i) or {}
		if cfg and next(cfg) then
			if cfg.level_limit <= main_role_level then
				layer = cfg.layer
				break
			end
		end
	end
	if ScoietyData.Instance:GetTeamState() then
		local team_info = ScoietyData.Instance:GetTeamInfo()
		local team_layer = team_info.teamfb_layer or 0
		local team_type = team_info.team_type or 0
		if team_type == FuBenTeamType.TEAM_TYPE_TEAM_EQUIP_FB then
			layer = math.min(layer, team_layer)
		end
	end
	return layer
end

-- 是否需要显示房间列表
function ManyFuBenView:CheckIsNeedShowRoomList()
	local flag = true
	if ScoietyData.Instance:GetTeamState() then
		if self:CheckIsTeamEquipType() then
			flag = false
		end
	end
	return flag
end

-- 队伍是否是组队副本类型
function ManyFuBenView:CheckIsTeamEquipType()
	local team_info = ScoietyData.Instance:GetTeamInfo() or {}
	local team_type = team_info.team_type or 0
	if team_type == FuBenTeamType.TEAM_TYPE_TEAM_EQUIP_FB then
		return true
	end
	return false
end

--------------------------------------- 房间信息 ----------------------------------------------

function ManyFuBenView:InitTeamRoom()
	self.cap_info = {}
	self.cap_info.obj = self.node_list["CaptainrInfo"]
	local uiname_table = self.cap_info.obj:GetComponent(typeof(UINameTable))
	local name_table = U3DNodeList(uiname_table)
	self.cap_info.head = name_table["ImgIcon"]
	self.cap_info.name = name_table["NameTxt"]
	self.cap_info.fp = name_table["CountTxt"]
	self.cap_info.is_online = name_table["ImgOffLine"]
	self.cap_info.portrait = name_table["portrait"]
	self.cap_info.portrait_raw = name_table["portrait_raw"]

	self.teammates = {}
	for i = 1, 2 do
		self.teammates[i] = {}
		self.teammates[i].obj = self.node_list["MemberInfo" .. i]
		uiname_table = self.teammates[i].obj:GetComponent(typeof(UINameTable))
		local node_list = U3DNodeList(uiname_table)
		self.teammates[i].head = node_list["portrait"]
		self.teammates[i].name = node_list["NameTxt"]
		self.teammates[i].fp = node_list["CountTxt"]
		self.teammates[i].show_member_info1 = node_list["MemberInfoTxt"]
		self.teammates[i].show_member_info2 = node_list["BtnShowMember"]
		self.teammates[i].show_kick_out = node_list["BtnShowKickOut"]
		self.teammates[i].is_online = node_list["ImgOffLine"]

		self.teammates[i].portrait = node_list["portrait"]
		self.teammates[i].portrait_raw = node_list["portrait_raw"]

		node_list["BtnShowMember"].button:AddClickListener(BindTool.Bind(self.OnClickInvite, self))
		self.teammates[i].btnShowKickOut = node_list["BtnShowKickOut"]
		self.teammates[i].ImgIcon = node_list["ImgIcon"]
	end
end

function ManyFuBenView:FlushTeamRoom()
	local ShowMemberInfo = {}
	for i = 1, 2 do
		self.teammates[i].show_member_info1:SetActive(false)
		self.teammates[i].show_member_info2:SetActive(true)
		ShowMemberInfo[i] = false
	end
	local info = ScoietyData.Instance:GetTeamInfo()
	if info then
		local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
		local i = 1
		for k,v in pairs(info.team_member_list) do
			local teammate_info = v
			if teammate_info and self.teammates[i] then
				-- 如果是队员
				if not ScoietyData.Instance:IsLeaderById(teammate_info.role_id) then
					ShowMemberInfo[i] = true
					self.teammates[i].show_member_info1:SetActive(true)
					self.teammates[i].show_member_info2:SetActive(false)
					self.teammates[i].name.text.text = teammate_info.name
					self.teammates[i].fp.text.text = teammate_info.capability
					UI:SetGraphicGrey(self.teammates[i].portrait, teammate_info.is_online == 1)
					UI:SetGraphicGrey(self.teammates[i].portrait_raw, teammate_info.is_online == 1)
					self.teammates[i].is_online:SetActive((not teammate_info.is_online == 1) and ShowMemberInfo[i])
					-- 设置头像
					if AvatarManager.Instance:isDefaultImg(teammate_info.role_id) == 0 then
						self.teammates[i].portrait.gameObject:SetActive(true)
					else
						local callback = function (path)
							if not self.teammates[i] then
								return
							end

							local portrait = self.teammates[i].portrait
							if portrait and not IsNil(portrait.gameObject) then
								portrait.gameObject:SetActive(false)
							end
						end
					end
					AvatarManager.Instance:SetAvatar(teammate_info.role_id, self.teammates[i].portrait_raw, self.teammates[i].head, teammate_info.sex, teammate_info.prof, false)

					self.teammates[i].btnShowKickOut.button:AddClickListener(BindTool.Bind(self.OnClickKickOut, self))
					self.teammates[i].event_trigger_listener:AddPointerClickListener(BindTool.Bind(self.OnClickHead, self))

					if ScoietyData.Instance:MainRoleIsCap() then
						self.teammates[i].show_kick_out:SetActive(true)
					else
						self.teammates[i].show_kick_out:SetActive(false)
					end
					i = i + 1
				end
			end
		end
		local leader_index = ScoietyData.Instance:GetTeamLeaderIndex() or 0
		leader_index = leader_index + 1
		local cap_info = info.team_member_list[leader_index]
		if cap_info then
			self.cap_info.name.text.text = cap_info.name
			self.cap_info.fp.text.text = cap_info.capability
			-- 设置头像
			AvatarManager.Instance:SetAvatar(cap_info.role_id, self.cap_info.portrait_raw, self.cap_info.head, cap_info.sex, cap_info.prof, false)
			UI:SetGraphicGrey(self.cap_info.portrait, cap_info.is_online == 1)
			UI:SetGraphicGrey(self.cap_info.portrait_raw, cap_info.is_online == 1)
			self.cap_info.is_online:SetActive(not (cap_info.is_online == 1))
			self.name_table["ImgIcon"].event_trigger_listener:AddPointerClickListener(BindTool.Bind(self.OnClickHead, self,cap_info.name, cap_info.role_id))
		end
	end
end

----------------------------------------InitInfoScroller---------------------------------------------------

--初始化滚动条
function ManyFuBenView:InitInfoScroller()
	self.toggle_group = self.node_list["Scroller"]:GetComponent("ToggleGroup")
	self.info_cell_list = {}
	local scroller_delegate = self.node_list["Scroller"].list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.GetCellView, self)
	self.scroller_is_load = false
end

--滚动条数量
function ManyFuBenView:GetNumberOfCells()
	return FuBenData.Instance:GetCrossFBCount()
end

--滚动条刷新
function ManyFuBenView:GetCellView(cellObj, data_index)
	local cell = self.info_cell_list[cellObj]
	if cell == nil then
		self.info_cell_list[cellObj] = KuaFuFuBenScrollCell.New(cellObj)
		cell = self.info_cell_list[cellObj]
		cell:ListenAllEvent(self)
		cell:SetToggleGroup(self.toggle_group)
	end
	local config = FuBenData.Instance:GetShowConfigByLayer(data_index)
	if config then
		cell:SetIndex(data_index)
		cell:SetData(config)
	end
	if not self.scroller_is_load and FuBenData.Instance:GetCrossFBCount() > 3 and self.node_list["Scroller"].scroller.isActiveAndEnabled then
		self.scroller_is_load = true
		GlobalTimerQuest:AddDelayTimer(function() self:JumpToIndex(self.select_fb) end, 0)
	end
end

--------------------------------------- 动态生成副本信息 ----------------------------------------------
KuaFuFuBenScrollCell = KuaFuFuBenScrollCell or BaseClass(BaseCell)

function KuaFuFuBenScrollCell:__init()
	self.root_node.list_cell.refreshCell = BindTool.Bind(self.Flush, self)
end

function KuaFuFuBenScrollCell:__delete()

end

function KuaFuFuBenScrollCell:OnFlush()
	self.node_list["NameTxt"].text.text = self.data.name
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if level < self.data.level then
		UI:SetGraphicGrey(self.node_list["ShowLevel1"], false)
		UI:SetGraphicGrey(self.node_list["ImgBg"], false)
		self.node_list["ShowLevel2"]:SetActive(true)
		-- local lv, zhuan = PlayerData.GetLevelAndRebirth(self.data.level)
		-- local Level = string.format(Language.Common.ZhuanShneng, lv, zhuan)
		self.node_list["LevelTxt"].text.text = string.format(Language.FuBen.OpenLevel, PlayerData.GetLevelString(self.data.level))
	else
		UI:SetGraphicGrey(self.node_list["ShowLevel1"], true)
		UI:SetGraphicGrey(self.node_list["ImgBg"], true)
		self.node_list["ShowLevel2"]:SetActive(false)
	end
	local bundle, asset = ResPath.CrossFBIcon(self.data.image_id)
	self.node_list["ImgBg"].raw_image:LoadSprite(bundle, asset)
	if self.handle.select_fb == self.index then
		self.root_node.toggle.isOn = true
	else
		if self.root_node.toggle.isOn then
			self.node_list["ImgLight"]:SetActive(true)
			GlobalTimerQuest:AddDelayTimer(function() self.node_list["ImgLight"]:SetActive(false) end, 0)
		end
		self.root_node.toggle.isOn = false
	end
end

function KuaFuFuBenScrollCell:ListenAllEvent(handle)
	self.handle = handle
	self.node_list["ManyFuBenItem"].toggle:AddClickListener(BindTool.Bind(function() handle:OnClickFuBen(self.index) end, self))
end

function KuaFuFuBenScrollCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

----------------------------------------InitRoomScroller---------------------------------------------------

--初始化滚动条
function ManyFuBenView:InitRoomScroller()
	self.team_cell_list = {}
	self.room_list_info = FuBenData.Instance:GetTeamFbRoomList()
	local scroller_delegate = self.node_list["TeamScroller"].list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetRoomNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.GetRoomCellView, self)
end

--滚动条数量
function ManyFuBenView:GetRoomNumberOfCells()
	return self.room_list_info.count or 0
end

--滚动条刷新
function ManyFuBenView:GetRoomCellView(cellObj, data_index)
	local cell = self.team_cell_list[cellObj]
	if cell == nil then
		self.team_cell_list[cellObj] = KuaFuFuBenRoomScrollCell.New(cellObj)
		cell = self.team_cell_list[cellObj]
	end
	cell:SetIndex(data_index)
	cell:SetTeamType(FuBenTeamType.TEAM_TYPE_TEAM_EQUIP_FB)
	local data = self.room_list_info.room_list[data_index + 1]
	if data then
		cell:SetData(data)
	end
end

function ManyFuBenView:FlushRoomList()
	self.room_list_info = FuBenData.Instance:GetTeamFbRoomList()
	self.node_list["NoRoomTxt"]:SetActive(self.room_list_info.count <= 0)
	if self.node_list["TeamScroller"].scroller.isActiveAndEnabled then
		self.node_list["TeamScroller"].scroller:ReloadData(0)
	end
end

--------------------------------------- 动态生成副本队伍信息 ----------------------------------------------
KuaFuFuBenRoomScrollCell = KuaFuFuBenRoomScrollCell or BaseClass(BaseCell)

function KuaFuFuBenRoomScrollCell:__init()
	self.root_node.list_cell.refreshCell = BindTool.Bind(self.Flush, self)
	self.node_list["ButtonJoin"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.team_type = 0
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["Capability"], "FightPower3")
end

function KuaFuFuBenRoomScrollCell:__delete()
	self.fight_text = nil
end

function KuaFuFuBenRoomScrollCell:SetTeamType(team_type)
	self.team_type = team_type or 0
end

function KuaFuFuBenRoomScrollCell:OnFlush()
	if self.data then
		self.node_list["Name"].text.text = string.format(Language.KuaFuFuBen.FangJian, self.data.leader_name)
		if self.data.menber_num >= 3 then
			self.node_list["Count"].text.text = string.format(Language.FuBen.TeamCountRoom, ToColorStr(self.data.menber_num, TEXT_COLOR.RED))
		else
			local Count = self.data.menber_num
			self.node_list["Count"].text.text = string.format(Language.FuBen.TeamCountRoom, Count)
		end
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = self.data.leader_capability
		end
		-- AvatarManager.Instance:SetAvatarKey(self.data.leader_uid, self.data.avatar_key_big, self.data.avatar_key_small)

		AvatarManager.Instance:SetAvatar(self.data.leader_uid, self.node_list["portrait_raw"], self.node_list["portrait"], self.data.leader_sex, self.data.leader_prof, false)
	end
end

function KuaFuFuBenRoomScrollCell:OnClick()
	-- if ScoietyData.Instance:GetTeamState() then
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.HasTeam)
	-- else
		FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.JOIN_ROOM, self.team_type, self.data.team_index, self.data.layer)
	-- end
end
