-- 经验副本
FuBenNewExpView = FuBenNewExpView or BaseClass(BaseRender)

function FuBenNewExpView:__init(instance)

	self.node_list["BtnStart"].button:AddClickListener(BindTool.Bind(self.OnClickTeamEnter, self))
	self.node_list["SoloBtn"].button:AddClickListener(BindTool.Bind(self.OnClickSoloEnter, self))
	self.node_list["ImgAdd"].button:AddClickListener(BindTool.Bind(self.OnClickAddTime, self))
	self.node_list["BtnZuDui"].button:AddClickListener(BindTool.Bind(self.OnClickZuDui, self))
	self.node_list["BtnZuDui2"].button:AddClickListener(BindTool.Bind(self.OnClickZuDui, self))
	self.node_list["BtnExit"].button:AddClickListener(BindTool.Bind(self.OnClickExit, self))
	self.node_list["BtnChouJiang"].button:AddClickListener(BindTool.Bind(self.OnClickChonJiang, self))
	self.node_list["BtnTips"].button:AddClickListener(BindTool.Bind(self.OnClickTips))
	
	ScoietyData.Instance:GetTeamInfo()
	self.reward_item = ItemCell.New()
	self.reward_item:SetInstanceParent(self.node_list["ItemCell"])

	--引导用按钮
	self.exp_solo_btn = self.node_list["SoloBtn"]
	self.get_ui_callback = BindTool.Bind(self.GetUiCallBack, self)
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.FuBen, self.get_ui_callback)

	self.cur_times = 0
	self:InitTeamRoom()
	self:InitRoomScroller()
end

function FuBenNewExpView:__delete()
	if self.reward_item then
		self.reward_item:DeleteMe()
		self.reward_item = nil
	end
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUiByFun(ViewName.FuBen, self.get_ui_callback)
	end
	self.teammates = {}
	for k, v in pairs(self.team_cell_list) do
		v:DeleteMe()
	end
	if self.cap_info then
		self.cap_info:DeleteMe()
		self.cap_info = nil
	end

	if self.team_member_list then
		for k, v in pairs(self.team_member_list) do
			v:DeleteMe()
		end
	end
	self.team_member_list = {}
	self.team_cell_list = {}
	self:CancelRequest()
end

function FuBenNewExpView:LoadCallBack()
	FuBenCtrl.Instance:SetExpRemind()
end

function FuBenNewExpView:GetBtnZuDui()
	return self.node_list["BtnZuDui"], BindTool.Bind(self.OnClickZuDui, self)
end

function FuBenNewExpView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["RightFrame"], FuBenTweenData.Right)
	FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.REQ_ROOM_LIST, FuBenTeamType.TEAM_TYPE_TEAM_DAILY_FB)
end

function FuBenNewExpView:OnClickTips()
	local tips_id = 310 	--经验副本
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function FuBenNewExpView:FlushInfo()
	local get_cfg = FuBenData.Instance:GetExpPotionCfg()
	local team_state = ScoietyData.Instance:GetTeamState()
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local is_leader = ScoietyData.Instance:IsLeaderById(role_id)
	local other_cfg = FuBenData.Instance:GetExpFBOtherCfg()

	local ItemNum = FuBenData.Instance:GetBagRewardNum()
	local RewardNum = other_cfg.item_stuff.num
	local had_item_text = ""
	if ItemNum < RewardNum then
		had_item_text = ToColorStr(ItemNum, COLOR.RED)
	else
		had_item_text = ToColorStr(ItemNum, TEXT_COLOR.GREEN)
	end
	self.node_list["ShowCardTxt"].text.text = string.format(Language.FuBen.CurAndTol, had_item_text, RewardNum)

	local pay_times = FuBenData.Instance:GetExpPayTimes()
	local enter_times = FuBenData.Instance:GetExpEnterTimes()

	self.cur_times = (pay_times + other_cfg.day_times - enter_times)
	local cfg = ""
	if self.cur_times < 1 then
		UI:SetButtonEnabled(self.node_list["BtnZuDui"], false)
		UI:SetGraphicGrey(self.node_list["TxtBtnZuDui"], true)
		UI:SetButtonEnabled(self.node_list["BtnZuDui2"], false)
		UI:SetGraphicGrey(self.node_list["TxtButtonZuDui2"], true)
		cfg = ToColorStr(self.cur_times, COLOR.RED)
	else
		UI:SetButtonEnabled(self.node_list["BtnZuDui"], true)
		UI:SetGraphicGrey(self.node_list["TxtBtnZuDui"], false)
		UI:SetButtonEnabled(self.node_list["BtnZuDui2"], true)
		UI:SetGraphicGrey(self.node_list["TxtButtonZuDui2"], false)
		cfg = ToColorStr(self.cur_times, TEXT_COLOR.GREEN)
	end
	cff = pay_times + other_cfg.day_times
	self.node_list["ShowTimeTxt"].text.text = string.format(Language.FuBen.CurAndTol, cfg, cff)

	if get_cfg then
		local data = {}
		data.item_id = get_cfg.drop_item_1
		self.reward_item:SetData(data)
	end
	local HasTeam = true
	local is_self_cap = ScoietyData.Instance:MainRoleIsCap()
	local IsCap = is_self_cap
	local ShowRoomList = true

	if team_state and self:CheckIsExpType() then
		HasTeam = true
	else
		HasTeam = false
	end
	self.node_list["SoloBtn"]:SetActive(not HasTeam)-- or (not IsCap))
	self.node_list["BtnZuDui"]:SetActive(not HasTeam)
	self.node_list["BtnExit"]:SetActive(HasTeam)

	if self:CheckIsNeedShowRoomList() then
		ShowRoomList = true
		self.node_list["TeamPanel"]:SetActive(HasTeam and (not ShowRoomList))
		self.node_list["NoTeamNode"]:SetActive((not HasTeam) or ShowRoomList)
		self.node_list["BtnZuDui2"]:SetActive(HasTeam and ShowRoomList and IsCap)
		self.node_list["BtnStart"]:SetActive(IsCap and HasTeam and (not ShowRoomList))
		self:FlushRoomList()
	else
		ShowRoomList = false
		self.node_list["TeamPanel"]:SetActive(HasTeam and (not ShowRoomList))
		self.node_list["NoTeamNode"]:SetActive((not HasTeam) or ShowRoomList)
		self.node_list["BtnZuDui2"]:SetActive(HasTeam and ShowRoomList and IsCap)
		self.node_list["BtnStart"]:SetActive(IsCap and HasTeam and (not ShowRoomList))
		self:FlushTeamRoom()
	end

	self:OpenGlobalTimer()

	local has_buy_times = FuBenData.Instance:GetExpPayTimes()
	local next_pay_money = FuBenData.Instance:GetExpNextPayMoney(has_buy_times)
	if next_pay_money == 0 then
		next_pay_money = 90
	end

	self:ShowChouJiangEffect()
end

-- 是否需要显示房间列表	
function FuBenNewExpView:CheckIsNeedShowRoomList()
	local flag = true
	if ScoietyData.Instance:GetTeamState() then
		if self:CheckIsExpType() then
			flag = false
		end
	end
	return flag
end

-- 队伍是否是经验副本类型
function FuBenNewExpView:CheckIsExpType()
	local team_info = ScoietyData.Instance:GetTeamInfo() or {}
	local team_type = team_info.team_type or 0
	if team_type == FuBenTeamType.TEAM_TYPE_TEAM_DAILY_FB then
		return true
	end
	return false
end

function FuBenNewExpView:OpenGlobalTimer()
	if nil == self.active_countdown then
		self.active_countdown = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.SetExpCountdown, self), 0.2)
	end
end

function FuBenNewExpView:CloseCallBack()
	if self.active_countdown then
		GlobalTimerQuest:CancelQuest(self.active_countdown)
		self.active_countdown = nil
	end
end

function FuBenNewExpView:OnClickInvite()
	TipsCtrl.Instance:ShowInviteView(ScoietyData.InviteOpenType.ExpFuBen)
end

function FuBenNewExpView:OnClickTeamEnter()
	local info = ScoietyData.Instance:GetTeamInfo()
	local open_level = FuBenData.Instance:GetExpOpenLevel()
	if info and info.team_member_list and open_level then
		for k,v in pairs(info.team_member_list) do
			if v and v.level < open_level then
				return SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.NotEnterFuBen)
			end
		end
	end
	self:CancelRequest()
	local exp_fb_info = FuBenData.Instance:GetExpFBInfo()
	local item_id = FuBenData.Instance:GetExpFBOtherCfg().item_stuff.item_id
	local item_num = FuBenData.Instance:GetBagRewardNum()
	local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
		end
	if item_num == 0 and exp_fb_info.expfb_history_enter_times > 0 then
		TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, 1)
		return
	end

	if self.cur_times <= 0 then
		self:OnClickAddTime()
		return
	end
	FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.START_ROOM)
end

function FuBenNewExpView:OnClickSoloEnter()
	local item_id = FuBenData.Instance:GetExpFBOtherCfg().item_stuff.item_id
	local item_num = FuBenData.Instance:GetBagRewardNum()
	local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
		end
	if item_num == 0 then
		TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, 1)
		return
	end

	if self.cur_times <= 0 then
		self:OnClickAddTime()
		return
	end
	FuBenCtrl.Instance:SendEnterFBReq(1, 0, 0, param_3)
end

function FuBenNewExpView:OnClickAddTime()
	-- local totla_buy_times = VipPower:GetParam(VipPowerId.exp_fb_buy_times)
	-- local next_max_times = VipPower:GetParam(VipPowerId.exp_fb_buy_times, true)
	-- local has_buy_times =FuBenData.Instance:GetExpPayTimes()
	-- local next_pay_money = FuBenData.Instance:GetExpNextPayMoney(has_buy_times)
	-- local max_pay_time = FuBenData.Instance:GetExpMaxPayTime()
	-- local max_vip_level = FuBenData.Instance:GetExpMaxVipLevel()
	local ok_fun = function ()
		FuBenCtrl.Instance:SendAutoFBReq(GameEnum.FB_CHECK_TYPE.FBCT_DAILY_FB, 0, param_2, param_3, param_4)
	end
	local data_fun = function ()
		local data = {}
		data[2] = FuBenData.Instance:GetExpPayTimes()
		data[1] = FuBenData.Instance:GetExpNextPayMoney(data[2])
		data[3] = VipPower:GetParam(VipPowerId.exp_fb_buy_times)
		data[4] = VipPower:GetParam(VipPowerId.exp_fb_buy_times, true)
		return data
	end
	-- if max_pay_time > has_buy_times then
	-- 	if has_buy_times == totla_buy_times then
	-- 		TipsCtrl.Instance:ShowLockVipView(VIPPOWER.EXP_FB_BUY_TIMES)
	-- 		return
	-- 	end
		-- TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, cfg)
		FuBenCtrl.Instance:ShowExpBuyTip(next_pay_money, has_buy_times, totla_buy_times, next_max_times,VipPowerId.exp_fb_buy_times, ok_fun, data_fun)
	-- elseif vip_level == max_vip_level or has_buy_times == max_pay_time then
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.ExpFuBen.TipsText2)
	-- end
end

function FuBenNewExpView:SetExpCountdown()
	local add_time = FuBenData.Instance:GetExpFBOtherCfg().interval_time
	local last_time = FuBenData.Instance:GetExpLastTimes()
	local now_time = TimeCtrl.Instance:GetServerTime()
	local min, sec = nil
	local enter_time = ""
	if last_time + add_time > now_time then
		local temp_time = last_time + add_time - now_time - 1
		temp_time = os.date('*t', temp_time)
		enter_time = string.format(Language.ExpFuBen.Countdown, temp_time.min, temp_time.sec)
	end
	-- self.node_list["CountDownTxt"].text.text = enter_time
end

function FuBenNewExpView:GetUiCallBack(ui_name, ui_param)
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end

function FuBenNewExpView:OnClickZuDui()
	local exp_fb_info = FuBenData.Instance:GetExpFBInfo()
	local item_id = FuBenData.Instance:GetExpFBOtherCfg().item_stuff.item_id
	local item_num = FuBenData.Instance:GetBagRewardNum()
	local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
		end
	if item_num == 0 and exp_fb_info.expfb_history_enter_times > 0 then
		TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, 1)
		return
	end
	if ScoietyData.Instance:GetTeamState() then
		if ScoietyData.Instance:MainRoleIsCap() then
			FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.CHANGE_MODE, FuBenTeamType.TEAM_TYPE_TEAM_DAILY_FB)
		else
			local func = function()
				FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.EXIT_ROOM)
				FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.CREATE_ROOM, FuBenTeamType.TEAM_TYPE_TEAM_DAILY_FB)
			end
			TipsCtrl.Instance:ShowCommonAutoView("", Language.FuBen.IsLeaveTeam, func)
			-- SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.NoCap)
		end
	else
		self:CancelRequest()
		FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.CREATE_ROOM, FuBenTeamType.TEAM_TYPE_TEAM_DAILY_FB)
	end
end

function FuBenNewExpView:OnClickExit()
	FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.EXIT_ROOM)
	FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.REQ_ROOM_LIST, FuBenTeamType.TEAM_TYPE_TEAM_DAILY_FB)
	self:OpenRequestTeamList()
end

function FuBenNewExpView:OpenRequestTeamList()
		-- 请求房间列表
	if self.request_timer then
		GlobalTimerQuest:CancelQuest(self.request_timer)
		self.request_timer = nil
	end
	if nil == self.request_timer then
		self.request_timer = GlobalTimerQuest:AddRunQuest(function()
			FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.REQ_ROOM_LIST, FuBenTeamType.TEAM_TYPE_TEAM_DAILY_FB)
		end, 5)		-- 因为这个刷新导致加载图片闪烁
	end
end

function FuBenNewExpView:CancelRequest()
	if self.request_timer then
		GlobalTimerQuest:CancelQuest(self.request_timer)
		self.request_timer = nil
	end
end

-- 打开抽奖面板
function FuBenNewExpView:OnClickChonJiang()
	ViewManager.Instance:Open(ViewName.Welfare, TabIndex.welfare_goldturn)
end

-- 转盘抽奖按钮特效显示
function FuBenNewExpView:ShowChouJiangEffect()
	if self.node_list["Effect"] then
		self.node_list["Effect"]:SetActive(WelfareData.Instance:GetTurnTableRewardCount() ~= 0)
	end
end

-- 房间信息 
function FuBenNewExpView:InitTeamRoom()
	self.cap_info = FuBenNewExpRoom.New(self.node_list["CaptainrInfo"])
	self.team_member_list = {}
	self.team_member_list[1] = FuBenNewExpRoom.New(self.node_list["MemberInfo1"])
	self.team_member_list[1]:LoadTeamShowMember(1)
	self.team_member_list[2] = FuBenNewExpRoom.New(self.node_list["MemberInfo2"])
	self.team_member_list[2]:LoadTeamShowMember(2)
end

function FuBenNewExpView:FlushTeamRoom()
	self:CancelRequest()
	local info = ScoietyData.Instance:GetTeamInfo()
	if info then
		local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
		local i = 1
		for k,v in pairs(self.team_member_list) do
			self.team_member_list[k]:InitRoomButton()
		end
		for k,v in pairs(info.team_member_list) do
			local teammate_info = v
			if teammate_info then
				-- 如果是队员
				if not ScoietyData.Instance:IsLeaderById(teammate_info.role_id) then
					--for k,v in pairs(self.team_member_list) do
						self.team_member_list[i]:FlushMemberInfo(teammate_info)
						i = i + 1
				end
			end
		end
	end
	self.cap_info:FlushInfo()

end

function FuBenNewExpView:OnClickKickOut(name, role_id)
	if ScoietyData.Instance:MainRoleIsCap() then
		local des = string.format(Language.Society.KickOutTeam, name)
		local ok_callback = function() FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.KICK_OUT, role_id) end
		TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback)
	end
end

function FuBenNewExpView:OnClickHead(name, role_id)
	if role_id == GameVoManager.Instance:GetMainRoleVo().role_id then
		return
	end
	ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, name)
end

----------------------------------------InitRoomScroller---------------------------------------------------

--初始化滚动条
function FuBenNewExpView:InitRoomScroller()
	self.team_cell_list = {}
	self.room_list_info = FuBenData.Instance:GetTeamFbRoomList()
	local scroller_delegate = self.node_list["TeamScroller"].list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetRoomNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.GetRoomCellView, self)
end

--滚动条数量
function FuBenNewExpView:GetRoomNumberOfCells()
	return self.room_list_info.count or 0
end

--滚动条刷新
function FuBenNewExpView:GetRoomCellView(cellObj, data_index)
	local cell = self.team_cell_list[cellObj]
	if cell == nil then
		self.team_cell_list[cellObj] = KuaFuFuBenRoomScrollCell.New(cellObj)
		cell = self.team_cell_list[cellObj]
	end
	cell:SetIndex(data_index)
	cell:SetTeamType(FuBenTeamType.TEAM_TYPE_TEAM_DAILY_FB)
	local data = self.room_list_info.room_list[data_index + 1]
	if data then
		cell:SetData(data)
	end
end

function FuBenNewExpView:FlushRoomList()
	self.room_list_info = FuBenData.Instance:GetTeamFbRoomList()
	if self.room_list_info and self.room_list_info.count then
		self.node_list["TxtNoTeam"]:SetActive(self.room_list_info.count <= 0)
		if self.node_list["TeamScroller"].scroller.isActiveAndEnabled then
			self.node_list["TeamScroller"].scroller:RefreshAndReloadActiveCellViews(true)
		end
	end
end


-----------------------------------------队长类-----------
FuBenNewExpRoom = FuBenNewExpRoom or BaseClass(BaseCell)

function FuBenNewExpRoom:__init()
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtCount"], "FightPower3")
end

function FuBenNewExpRoom:__delete()
	self.fight_text = nil
end

function FuBenNewExpRoom:FlushInfo()
	-- body
	local info = ScoietyData.Instance:GetTeamInfo()
	local leader_index = ScoietyData.Instance:GetTeamLeaderIndex() or 0
	leader_index = leader_index + 1
	local cap_info = info.team_member_list[leader_index]
	if cap_info then
		self.node_list["TxtName"].text.text = cap_info.name
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = cap_info.capability
		end
		-- 设置头像
		AvatarManager.Instance:SetAvatar(cap_info.role_id, self.node_list["portrait_raw"], self.node_list["portrait"], cap_info.sex, cap_info.prof, false)

		UI:SetGraphicGrey(self.node_list["portrait"], not (cap_info.is_online == 1))
		UI:SetGraphicGrey(self.node_list["portrait_raw"], not (cap_info.is_online == 1))
		self.node_list["ImgOffLine"]:SetActive(not (cap_info.is_online == 1))
		self.node_list["ImgIcon"].button:AddClickListener(BindTool.Bind(self.OnClickHead, self, cap_info.name, cap_info.role_id))
	end
end

function FuBenNewExpRoom:FlushMemberInfo(meminfo)
	if not meminfo then
		self.node_list["MemberInfoNode"]:SetActive(false)
		self.node_list["BtnShowMember"]:SetActive(true)
		self.node_list["ImgOffLine"]:SetActive(false)
		return
	end

	self.node_list["MemberInfoNode"]:SetActive(true)
	self.node_list["BtnShowMember"]:SetActive(false)
	self.node_list["ImgOffLine"]:SetActive(true)
	self.node_list["TxtName"].text.text = meminfo.name
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = meminfo.capability
	end

	UI:SetGraphicGrey(self.node_list["portrait"], not (meminfo.is_online == 1))
	UI:SetGraphicGrey(self.node_list["portrait_raw"], not (meminfo.is_online == 1))
	self.node_list["ImgOffLine"]:SetActive(not meminfo.is_online == 1)

	AvatarManager.Instance:SetAvatar(meminfo.role_id, self.node_list["portrait_raw"], self.node_list["portrait"], meminfo.sex, meminfo.prof, false)
	
	self.node_list["BtnShowKickOut"].button:AddClickListener(BindTool.Bind(self.OnClickKickOut, self, meminfo.name, meminfo.role_id))
	self.node_list["ImgSmallRole"].button:AddClickListener(BindTool.Bind(self.OnClickHead, self,meminfo.name, meminfo.role_id))
	if ScoietyData.Instance:MainRoleIsCap() then
		self.node_list["BtnShowKickOut"]:SetActive(true)
	else
		self.node_list["BtnShowKickOut"]:SetActive(false)
	end
end

function FuBenNewExpRoom:OnClickHead(name, role_id)
	if role_id == GameVoManager.Instance:GetMainRoleVo().role_id then
		return
	end
	ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, name)
end

function FuBenNewExpRoom:OnClickKickOut(name, role_id)
	if ScoietyData.Instance:MainRoleIsCap() then
		local des = string.format(Language.Society.KickOutTeam, name)
		local ok_callback = function() FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.KICK_OUT, role_id) end
		TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback)
	end
end

function FuBenNewExpRoom:LoadTeamShowMember(index)
	self.node_list["BtnShowMember"].button:AddClickListener(BindTool.Bind(self.OnClickInvite, self, index))
end

function FuBenNewExpRoom:OnClickInvite()
	TipsCtrl.Instance:ShowInviteView(ScoietyData.InviteOpenType.ExpFuBen)
end
function FuBenNewExpRoom:InitRoomButton( )
	self.node_list["MemberInfoNode"]:SetActive(false)
	self.node_list["BtnShowMember"]:SetActive(true)
	self.node_list["ImgOffLine"]:SetActive(false)
end