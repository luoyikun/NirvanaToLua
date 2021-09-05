require("game/chat/chat_guild_view")
require("game/chat/guild_chat_hongbao_cell")
require("game/chat/guild_rank_cell")
require("game/chat/guild_member_cell")
require("game/chat/guild_pawn_rank_cell")
require("game/chat/chat_target_item_cell")
require("game/chat/team_member_cell")

local LayoutRebuilder = UnityEngine.UI.LayoutRebuilder

GUILD_TOP_TOGGLE_NAME = {
	SHAI_ZI = 1,
	QUESTION = 2,
	SHEN_YU = 3,
}

GuildChatView = GuildChatView or BaseClass(BaseView)

local OperaCount = 6		 --聊天操作按钮最大个数
local ANSWER_TIME_LIMIT = 5  --剩余5s答题则不打开界面
local UILayer = GameObject.Find("GameRoot/UILayer")
-- 一页显示的红包数量
local HongBaoCount = 3
local FIX_EXIT_TIME = 3

function GuildChatView:__init()
	GuildChatView.Instance = self
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel"},
		{"uis/views/chatview_prefab", "ChatGuildView"}
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	
	-- self.role_list_data = {}
	-- self.select_target_index = 1

	self.activity_call_back = BindTool.Bind(self.ActivityChange, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
end

function GuildChatView:__delete()
	GuildChatView.Instance = nil
	if self.zhunbei_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.zhunbei_count_down)
		self.zhunbei_count_down = nil
	end

	if self.question_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.question_count_down)
		self.question_count_down = nil
	end

	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end	
end

function GuildChatView:ActivityChange(activity_type, status, next_time, open_type)
	if activity_type == ACTIVITY_TYPE.GUILD_ANSWER and (ACTIVITY_STATUS.CLOSE or ACTIVITY_STATUS.OPEN) then
		if ViewManager.Instance:IsOpen(ViewName.ChatGuild) then
			self:FlushSelectTarget(true)
		end
	end
end

function GuildChatView:ReleaseCallBack()
	if self.guild_view then
		self.guild_view:DeleteMe()
		self.guild_view = nil
	end

	if self.chat_measuring then
		ResMgr:Destroy(self.chat_measuring.root_node.gameObject)
		self.chat_measuring:DeleteMe()
		self.chat_measuring = nil
	end

	for k, v in pairs(self.activity_cell_list) do
		v:DeleteMe()
	end
	self.activity_cell_list = {}

	for k, v in pairs(self.member_list_view) do
		v:DeleteMe()
	end
	self.member_list_view = {}

	for k, v in pairs(self.chuanwen_cell_list) do
		v:DeleteMe()
	end
	self.chuanwen_cell_list = {}

	for k, v in pairs(self.pwan_score_list_view) do
		v:DeleteMe()
	end
	self.pwan_score_list_view = {}

	self.red_point_list = {}

	if RemindManager.Instance and self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	for _, v in pairs(self.static_cell_list) do
		v:DeleteMe()
	end
	self.static_cell_list = {}

	for _, v in pairs(self.dynamic_cell_list) do
		v:DeleteMe()
	end
	self.dynamic_cell_list = {}

	for k, v in pairs(self.team_cell_list) do
		v:DeleteMe()
	end
	self.team_cell_list = {}

	self.answer_list = {}

	self.top_toggle_hl_list = {}

	if self.next_timer then
		GlobalTimerQuest:CancelQuest(self.next_timer)
		self.next_timer = nil
	end

	self:StopPawnTimes()

	if self.delay_shou_qipao then
		GlobalTimerQuest:CancelQuest(self.delay_shou_qipao)
		self.delay_shou_qipao = nil
	end

	for k,v in pairs(self.rank_cell_list) do
		v:DeleteMe()
	end
	self.rank_cell_list = nil

	if self.zhunbei_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.zhunbei_count_down)
		self.zhunbei_count_down = nil
	end

	if self.question_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.question_count_down)
		self.question_count_down = nil
	end

	if self.countdown_time then
		CountDown.Instance:RemoveCountDown(self.countdown_time)
		self.countdown_time = nil
	end

	if self.timer_request then
		GlobalTimerQuest:CancelQuest(self.timer_request)
		self.timer_request = nil
	end

	self.dynamic_list = nil
	self.dynamic_list_view = nil
	self.static_list = nil
	self.static_list_view = nil
	self.target_list_content = nil

	if self.switch_handle ~= nil then
		GlobalEventSystem:UnBind(self.switch_handle)
		self.switch_handle = nil
	end

	self:DelPriviteList()
end

function GuildChatView:DelPriviteList()
	if ChatData  and ChatData.Instance then
		for k,v in pairs(ChatData.Instance:GetDelPriviteList()) do
			ChatCtrl.Instance:DelPriviteObjOnLocal(v)
			ChatData.Instance:RemoveNormalChatList(v)
		end
		RemindManager.Instance:Fire(RemindName.GuildChatRed)
	end
end

function GuildChatView:LoadCallBack()
	self.rank_cell_list = {}
	self.node_list["TitleText"].text.text = Language.Chat.GuildChatViewName
	self.node_list["TitleText"].text.lineSpacing = 1
	self.select_dynamic_index = 1
	self.record_top_toggle_state = {}
	self.activity_type = 0
	
	self.show_guild_question = false 	-- 公会答题
	self.channel_type = 1
	self.is_open_maze = false 			-- 迷宫功能开启
	self.is_on_cross_server = false
	self.is_show_btn = false 			-- 按钮显示

	self.top_toggle_list = {}
	self.top_toggle_hl_list = {}
	self.private_chat_is_online = 0

	self.switch_handle = GlobalEventSystem:Bind(ChatEventType.VOICE_SWITCH, BindTool.Bind(self.UpdateVoiceSwitch, self))
	self:UpdateVoiceSwitch()

	--总消息列表
	self.normal_chat_list = ChatData.Instance:GetNormalChatList()

	--江湖传闻信息
	self.guild_event_list_data = GuildData.Instance:GetGuildEventList()

	--左边静态聊天对象列表
	self.static_list = self.node_list["StaticList"]
	self.static_list_width = self.static_list.rect.rect.width
	self.static_list_data = {}
	self.static_list_view = self.node_list["StaticListView"]
	self.static_cell_list = {}
	local list_delegate = self.static_list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetStaticTargetNum, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.StaticListRefreshCell, self)

	--左边动态聊天对象列表
	self.dynamic_list = self.node_list["DynamicList"]
	self.dynamic_list_width = self.dynamic_list.rect.rect.width
	self.dynamic_list_data = {}
	self.dynamic_list_view = self.node_list["RoleList"]
	self.dynamic_cell_list = {}
	list_delegate = self.dynamic_list_view.list_simple_delegate
	self.dynamic_cell_height = list_delegate:GetCellViewSize(self.dynamic_list_view.scroller, 0)					--单个cell的大小（根据排列顺序对应高度或宽度）
	self.dynamic_list_view_spacing = self.dynamic_list_view.scroller.spacing										--间距
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetDynamicTargetNum, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.DynamicListRefreshCell, self)

	self.target_list_content = self.node_list["TargetListContent"]

	--队伍列表
	self.team_cell_list = {}
	self.team_data = {}
	local team_simple_delegate = self.node_list["TeamMemberList"].list_simple_delegate
	team_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetTeamMemberNum, self)
	team_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshTeamMenberList, self)

	self.node_list["BtnRedPackage"].button:AddClickListener(BindTool.Bind(self.HandleOpenRedPackage, self))
	self.node_list["BtnLocation"].button:AddClickListener(BindTool.Bind(self.HandleInsertLocation, self))
	self.node_list["BtnItem"].button:AddClickListener(BindTool.Bind(self.HandleOpenItem, self))
	self.node_list["BtnEmoji"].button:AddClickListener(BindTool.Bind(self.HandleOpenEmoji, self))
	self.node_list["BtnSend"].button:AddClickListener(BindTool.Bind(self.HandleSend, self))
	self.node_list["ChatInput"].input_field.onEndEdit:AddListener(BindTool.Bind(self.HandleSend, self))			-- 输入完直接发送内容
	
	self.node_list["BtnVoice"].event_trigger_listener:AddPointerDownListener(BindTool.Bind(self.HandleVoiceStart, self))
	self.node_list["BtnVoice"].event_trigger_listener:AddPointerUpListener(BindTool.Bind(self.HandleVoiceStop, self))

	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.HandleClose, self))
	self.node_list["Tips_pop_bt"].toggle:AddClickListener(BindTool.Bind(self.OnTipsPopClick, self))

	self.node_list["BtnChat"].button:AddClickListener(BindTool.Bind(self.GoCoolShop, self))
	self.node_list["Btn_fast_chat"].button:AddClickListener(BindTool.Bind(self.OpenNotice, self))
	
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))

	self.node_list["BtnRight"].button:AddClickListener(BindTool.Bind(self.OnClickRight, self))
	self.node_list["BtnLeft"].button:AddClickListener(BindTool.Bind(self.OnClickLeft, self))

	self.node_list["Help"].button:AddClickListener(BindTool.Bind(self.OnBtnHelp, self))

	self.node_list["Btn1"].button:AddClickListener(BindTool.Bind(self.FriendClick, self))
	self.node_list["Btn2"].button:AddClickListener(BindTool.Bind(self.TeamClick, self))
	self.node_list["Btn3"].button:AddClickListener(BindTool.Bind(self.CheckClick, self))
	self.node_list["Btn4"].button:AddClickListener(BindTool.Bind(self.TradeClick, self))
	--加入黑名单
	-- self.node_list["Btn5"].button:AddClickListener(BindTool.Bind(self.BlackClick, self))

	self.node_list["Btn5"].button:AddClickListener(BindTool.Bind(self.MarryClick, self))
	self.node_list["Btn6"].button:AddClickListener(BindTool.Bind(self.TrackClick, self))
	self.node_list["AddBtn"].button:AddClickListener(BindTool.Bind(self.OnShowBtn, self))
	
	self.node_list["ActivityIcon"].button:AddClickListener(BindTool.Bind(self.OnClickActvitiyIcon, self))

	for i = 1, 3 do
		self.node_list["GuildToggle" .. i].toggle.onValueChanged:AddListener(BindTool.Bind(self.OnTopTabClick, self, i))
	end

	self.node_list["BtnTips"].button:AddClickListener(BindTool.Bind(self.NoOpen,self))
	self.node_list["BtnTips_DaTi"].button:AddClickListener(BindTool.Bind(self.OnButtonHelp, self))

	self.node_list["PlayPawnBtn"].button:AddClickListener(BindTool.Bind(self.PlayPawn, self))
	--self.node_list["BtnNotice"].button:AddClickListener(BindTool.Bind(self.ClickQuick, self))
	self.node_list["BtnleaveTeam"].button:AddClickListener(BindTool.Bind(self.ClickLeaveTeam, self))
	self.node_list["BtnInvite"].button:AddClickListener(BindTool.Bind(self.ClickInvite, self))

	--self.node_list["BtnSignin"].button:AddClickListener(BindTool.Bind(self.OnClickSignin, self))
	self.node_list["BtnMaze"].button:AddClickListener(BindTool.Bind(self.OpenGuildMaze, self))
	self.node_list["BtnWantEquip"].button:AddClickListener(BindTool.Bind(self.OpenWantEquip, self))
	self.node_list["BtnMarket"].button:AddClickListener(BindTool.Bind(self.OpenMarket, self))
	self.node_list["GuildWage"].button:AddClickListener(BindTool.Bind(self.OpenGuildWage, self))
	self.node_list["GuildEnemy"].button:AddClickListener(BindTool.Bind(self.OpenGuildEnemy, self))
	self.node_list["BtnGuildWarehouse"].button:AddClickListener(BindTool.Bind(self.OpenGuildWarehouse, self))
	self.node_list["btn_member"].button:AddClickListener(BindTool.Bind(self.ChangeListActive, self))
	self.node_list["VoiceToggle"].toggle:AddClickListener(BindTool.Bind(self.ToggleOnClick, self))
	self.node_list["JumpKuang"]:SetActive(false)


	--仙盟答题答题榜按钮
	local scene_type = Scene.Instance:GetSceneType()
	-- local is_show = scene_type == SceneType.GUILD_ANSWER_FB
	local is_show = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GUILD_ANSWER)
	if is_show and self.node_list["EndText"].text.text == "" and self.node_list["QuestionTxt"].text.text == "" then
		is_show = false
	end
	local is_not_finish = GuildData.Instance:CheckIsShowGuildQuestion()
	local special_type = ChatData.Instance:GetCurIsLiaoOrSystem()
	self.node_list["ImgGuildQuestion"]:SetActive(is_show and self.channel_type == 1 and special_type ~= SPECIAL_CHAT_ID.FALLITEM)
	self:ChangeRect(is_show)
	if is_show and is_not_finish then
		self.node_list["Time"]:SetActive(false)
		self.node_list["bg_num"]:SetActive(false)
		self.node_list["EndText"].text.text = Language.GuildDaTi.DaTiHasFinish
		self.node_list["EndText"]:SetActive(true)
		self.node_list["QuestionTxt"]:SetActive(false)
	end
	self.node_list["BtnTips"]:SetActive(not is_show)

	
	if scene_type == SceneType.GUILD_ANSWER_FB then
		self.node_list["NameTxt"].text.text = ""
	end

	self:InitTreasureBoxScroller()
	self:InitShenYuRankScroller()
	--------------
	self.guild_view = ChatGuildView.New(self.node_list["ContentGuild"])

	self.red_point_list = {
		[RemindName.CoolChat] = self.node_list["ImgRedChat"],
		[RemindName.GuildMaze] = self.node_list["ImgMaze"], -- 迷宫小红点
	}
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

	-- 活动list
	self.activity_cell_list = {}

	-- 成员list
	self.member_list_view = {}

	-- 传闻list
	self.chuanwen_cell_list = {}

	-- 骰子积分list
	self.pwan_score_list_view = {}

	self.max_boss_count = GuildData.Instance:GetMaxGuildBossCount()
	if nil == self.max_boss_count or self.max_boss_count <= 0 then
		self.max_boss_count = 1
	end
	self.percent = 1 / self.max_boss_count
	self:InitMemberListView()
	self:InitChuanWenListView()
	self:InitPawnListView()
	self:FlushCanPawnNextTime()

	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local other_cfg = GuildData.Instance:GetOtherConfig()
	local is_show_shen_yu_day = 0
	if other_cfg then
		is_show_shen_yu_day = other_cfg.cross_boss_show_day
	end
	self.node_list["GuildToggle3"]:SetActive(cur_day >= is_show_shen_yu_day)
	self.node_list["ShenYuRankList"]:SetActive(cur_day >= is_show_shen_yu_day)
	self.node_list["Help"]:SetActive(cur_day >= is_show_shen_yu_day)

	self.node_list["GuildToggle1"]:SetActive(cur_day < is_show_shen_yu_day)
	self.node_list["PawnRankListObj"]:SetActive(cur_day < is_show_shen_yu_day)
end

function GuildChatView:OnButtonHelp()
	TipsCtrl.Instance:ShowHelpTipView(309)
end

function GuildChatView:OpenCallBack()
	self.node_list["GuildEnemy"]:SetActive(GuildData.Instance:IsGuildEnemyFunOpen())
	
	RemindManager.Instance:SetImmdiateRemind(RemindName.GuildChatRed)
	self:FlushActivityIcon()
	self.guild_view:ChangeChannelType()
	self:RefeshSetting()
	self.open_trigger = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.ShowOrHideTab, self))
	--把主界面私聊头像隐藏
	ChatData.Instance:SetHavePriviteChat(false)
	MainUICtrl.Instance:FlushView("privite_visible", {false})

	local flag = OpenFunData.Instance:CheckIsHide("guild_gongzi")
	self.node_list["GuildWage"]:SetActive(flag)
	local is_open_guild_warehouse = OpenFunData.Instance:CheckIsHide("guild_warehouse")
	self.node_list["BtnGuildWarehouse"]:SetActive(is_open_guild_warehouse)
	local is_show_wage_red_point = GuildData.Instance:IsCanShowGongZiRedPoint()
	self.node_list["ImgWageRedPoint"]:SetActive(is_show_wage_red_point)

	self.node_list["TxtSendbtn"].text.text = Language.Guild.Send
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id

	local current_id = ChatData.Instance:GetCurrentId()
	if current_id == SPECIAL_CHAT_ID.GUILD then
		GuildCtrl.Instance:SendGuildEventListReq(guild_id)
	end

	RankCtrl.Instance:SendGetGuildRankListReq(GUILD_RANK_TYPE.GUILD_RANK_TYPE_KILL_CROSS_BOSS)

	--GuildCtrl.Instance:SendGuildEventListReq(guild_id)
	if not IS_ON_CROSSSERVER then
		GuildCtrl.Instance:SendGuildInfoReq()
		GuildCtrl.Instance:SendAllGuildMemberInfoReq()
		--GuildCtrl.Instance:SendGuildEventListReq(guild_id)
	end
	MainUICtrl.Instance:FlushView("show_guildchat_redpt", {false})
	self:FlushHongBao()
	RemindManager.Instance:Fire(RemindName.CoolChat)
	RemindManager.Instance:Fire(RemindName.GuildChatRed)

	self:FlushSelectTarget(true)

	--监听好友列表改变
	self.friend_callback = GlobalEventSystem:Bind(OtherEventType.FRIEND_INFO_CHANGE, BindTool.Bind(self.FriendListChange, self))

	--监听黑名单列表变化
	self.black_callback = GlobalEventSystem:Bind(OtherEventType.BLACK_LIST_CHANGE, BindTool.Bind(self.BlackListChange, self))

	--监听特殊聊天对象变化
	self.special_change_callback = GlobalEventSystem:Bind(ChatEventType.SPECIAL_CHAT_TARGET_CHANGE, BindTool.Bind(self.SpecialTargetChange, self))

	--停止主界面聊天按钮抖动效果
	MainUICtrl.Instance:GetView():ShakeGuildChatBtn(false)
	self:ShowOrHideTab()

	-- 是否在跨服
	self.is_on_cross_server = IS_ON_CROSSSERVER
	if self.channel_type > 100 then
		self.node_list["PlayPawnBtn"]:SetActive(false)
	else
		local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
		local other_cfg = GuildData.Instance:GetOtherConfig()
		local is_show_shen_yu_day = 0
		if other_cfg then
			is_show_shen_yu_day = other_cfg.cross_boss_show_day
		end
		self.node_list["PlayPawnBtn"]:SetActive(not self.is_on_cross_server and self.channel_type ~= 2 and cur_day < is_show_shen_yu_day)
	end
	self.node_list["BtnMaze"]:SetActive(self.is_open_maze and self.channel_type == 1 and (not self.is_on_cross_server))
	local is_show = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GUILD_ANSWER)
	if is_show then
		self:SetTopToggleIsOn(2, true)
	end
	self.change_chuanwen_list_active = true
	self:ChangeListActive()
	self:Flush()
end

function GuildChatView:ShowOrHideTab()
	local maze_is_open = OpenFunData.Instance:CheckIsHide("guild_maze")
	self.is_open_maze = maze_is_open
	self.node_list["BtnMaze"]:SetActive(self.is_open_maze and self.channel_type == 1 and (not IsOnCrossServer))
end

function GuildChatView:ChangeListActive()
	if self.change_chuanwen_list_active == nil then
		self.change_chuanwen_list_active = true
	end
	local str = ""
	str = self.change_chuanwen_list_active and Language.Chat.ChuanWenTitleText or Language.Chat.MemberTitleText
	self.node_list["Txt_ListName"].text.text = str
	local bundle, asset = nil, nil

	if self.change_chuanwen_list_active then
		bundle, asset = ResPath.GetChatRes("mengyou_bg")
	else
		bundle, asset = ResPath.GetChatRes("chuanwen_bg")
	end

	local str2 = ""
	str2 = self.change_chuanwen_list_active and Language.Chat.MemberName or Language.Chat.ChuanWenName
	self.node_list["ListTxt"].text.text = str2
	self.node_list["btn_member"].image:LoadSprite(bundle, asset)
	self.node_list["ChuanwenList"]:SetActive(self.change_chuanwen_list_active)
	self.node_list["member_list_view"]:SetActive(not self.change_chuanwen_list_active)
	self.change_chuanwen_list_active = not self.change_chuanwen_list_active
end

function GuildChatView:OnShowBtn()
	if self.is_show_btn == true then
		self.node_list["JumpKuang"]:SetActive(false)
		self.is_show_btn = false
		return
	end
	self.node_list["JumpKuang"]:SetActive(true)
	self.is_show_btn = true
end

local SPECIAL_GUILD_ACTIVITY_LIST = {
	[6] = ACTIVITY_TYPE.GONGCHENGZHAN,
	[21] = ACTIVITY_TYPE.GUILDBATTLE,
	[3082] = ACTIVITY_TYPE.KF_GUILDBATTLE,
	[3087] = ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_LIEKUN_FB,
}

function GuildChatView:OnClickActvitiyIcon()
	if self.activity_type > 0 then
		local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
		local cur_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
		local in_open_day = PlayerPrefsUtil.GetInt(main_role_id .. self.activity_type .. "activity_remind")
		if in_open_day ~= cur_open_day then
			local num = math.random(1, 6)
			local name = ActivityData.Instance:GetActivityNameByType(self.activity_type) or ""
			local des = string.format(Language.Activity.ActivityMessageInChat[num], name)
			ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, des, CHAT_CONTENT_TYPE.TEXT)
			PlayerPrefsUtil.SetInt(main_role_id .. self.activity_type .. "activity_remind", cur_open_day)
		end
		if SPECIAL_GUILD_ACTIVITY_LIST[self.activity_type] then
			TipsCtrl.Instance:ShowTipsGuildActivityReward(self.activity_type)
		else
			ActivityCtrl.Instance:ShowDetailView(self.activity_type, true)
		end
	end
end

function GuildChatView:ToggleOnClick()
	local state = ChatData.Instance:GetAutoGuildVoice()
	local ani_state = self.node_list["VoiceToggle"].toggle.isOn

	local new_state = not state
	ChatData.Instance:SetAutoGuildVoice(new_state)
	self.node_list["VoiceToggle"].toggle.isOn = new_state
end

function GuildChatView:RefeshSetting()
	local state = ChatData.Instance:GetAutoGuildVoice()
	self.node_list["VoiceToggle"].toggle.isOn = state
	ChatData.Instance:SetAutoGuildVoice(state)
end

function GuildChatView:CloseCallBack()
	self:UnBindFriend()
	self:UnBindBlack()
	self:UnBindSpecialTarget()
	if nil ~= self.dynamic_cell_list then
		for _, v in pairs(self.dynamic_cell_list) do
			v:UnBindIsOnlineEvent()
			v:UnBindRemind()
		end
	end

	if nil ~= self.static_cell_list then
		for _, v in pairs(self.static_cell_list) do
			v:UnBindIsOnlineEvent()
			v:UnBindRemind()
		end
	end

	self:CancelQuestionCountDown()
	local guild_result_list = WorldQuestionData.Instance:GetGuildResultList()
	if guild_result_list and next(guild_result_list) then
		WorldQuestionData.Instance:ClearGuildList()
	end

	if self.open_trigger then
		GlobalEventSystem:UnBind(self.open_trigger)
		self.open_trigger = nil
	end

	self.private_chat_is_online = 0

	ChatCtrl.Instance:SingleChatOnlineStatusReq(SINGLE_CHAT_REQ.SINGLE_CHAT_REQ_DELETE_ALL)
end

function GuildChatView:GetTeamMemberNum()
	return #self.team_data
end

function GuildChatView:RefreshTeamMenberList(cell, data_index)
	data_index = data_index + 1
	local member_cell = self.team_cell_list[cell]
	if nil == member_cell then
		member_cell = ChatTeamMemberCell.New(cell.gameObject)
		member_cell:SetToggleGroup(self.node_list["TeamMemberList"].toggle_group)
	end
	member_cell:SetIndex(data_index)
	member_cell:SetData(self.team_data[data_index])
end

function GuildChatView:FlushTeamList(is_init)
	if self.node_list["TeamMemberList"].scroller.isActiveAndEnabled then
		if is_init then
			self.node_list["TeamMemberList"].scroller:ReloadData(0)
		else
			self.node_list["TeamMemberList"].scroller:RefreshAndReloadActiveCellViews(true)
		end
	end
end

--设置选择的对象位置
function GuildChatView:RefreshDynamicSelectIndex()
	self.select_dynamic_index = 1

	local current_id = ChatData.Instance:GetCurrentId()
	for k, v in ipairs(self.dynamic_list_data) do
		if v.role_id == current_id then
			self.select_dynamic_index = k
			break
		end
	end

	--取消监听玩家在线状态
	ChatCtrl.Instance:SingleChatOnlineStatusReq(SINGLE_CHAT_REQ.SINGLE_CHAT_REQ_DELETE_ALL)
	local target_data = ChatData.Instance:GetTargetDataByRoleId(current_id)
	if current_id > SPECIAL_CHAT_ID.ALL and nil ~= target_data then
		--监听玩家在线状态
		local plat_type = target_data.plat_type > 0 and target_data.plat_type or GameVoManager.Instance:GetMainRoleVo().plat_type
		ChatCtrl.Instance:SingleChatOnlineStatusReq(SINGLE_CHAT_REQ.SINGLE_CHAT_REQ_ADD, plat_type, target_data.role_id)
	end
end

--刷新选择的对象
function GuildChatView:FlushSelectTarget(is_init, n_channel_type)
	--如果没有任何聊天对象则关闭界面
	if #self.normal_chat_list <= 0 then
		ChatData.Instance:SetCurrentId(-1)
		self:Close()
		return
	end

	local current_id = ChatData.Instance:GetCurrentId()
	-- local t_channel_type = self.guild_view:GetChannelType()

	--判断该聊天对象是否有效
	local target_data = ChatData.Instance:GetTargetDataByRoleId(current_id)
	local current_id_is_change = false
	if nil == target_data then
		--重新选择第一个聊天对象
		current_id = self.normal_chat_list[1].role_id
		--记录当前聊天对象
		ChatData.Instance:SetCurrentId(current_id)
		current_id_is_change = true
	end
	
	if self.private_chat_is_online == 1 then
		ChatData.Instance:SetPrivateObjRemoveOutLineMsg(current_id)
	end

	self.channel_type = current_id
	self:JudgeStage(self.channel_type, self.show_guild_question)

	--重新获取静态列表数据
	self.static_list_data = ChatData.Instance:GetStaticChatList()

	--刷新静态列表
	self:FlushStaticListView()

	self:FlushWantEquip()

	--重新获取动态列表数据
	self.dynamic_list_data = ChatData.Instance:GetDynamicChatList()

	--刷新动态列表选中index
	self:RefreshDynamicSelectIndex()

	--改变左边列表的高度
	self:ChangeListHeight()

	if is_init or current_id_is_change then
		--self:StopPawnTimes()
		self:StartPawnTimes()
		if current_id == SPECIAL_CHAT_ID.GUILD then
			ChatData.Instance:ClearGuildUnreadMsg()
			ChatData.Instance:SetNewLockState(false)
			-- self:StartPawnTimes()
			self:FlushPawnScoreView()
			local scene_type = Scene.Instance:GetSceneType()
			local is_show = scene_type == SceneType.GUILD_ANSWER_FB
			local is_show_tip = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GUILD_ANSWER)
			if is_show then
				-- self:SetTopToggleIsOn(2, true)
				self.node_list["BtnTips"]:SetActive(false)
			else
				self.node_list["BtnTips"]:SetActive(not is_show_tip)
				-- self:SetTopToggleIsOn(2, true)
			end
			if is_show_tip then
				-- self:SetTopToggleIsOn(2, true)
				self.node_list["BtnTips_Effect"]:SetActive(true)
			else
				-- self:SetTopToggleIsOn(2, true)
				self.node_list["BtnTips_Effect"]:SetActive(false)
			end
			
		elseif current_id == SPECIAL_CHAT_ID.TEAM then
			ChatData.Instance:ClearTeamUnreadMsg()
			-- self.node_list["TxtTisPawn"]:SetActive(false)
			self:FlushTeamView(true)
		else
			ChatData.Instance:RemPrivateUnreadMsg(current_id)
			-- self.node_list["TxtTisPawn"]:SetActive(false)
			self:FlushPriviteRoleInfo()
		end
		--刷新聊天信息
		self:InitDynamicListView()
	else
		self:FlushDynamicListView()
		self:FlushPriviteRoleInfo()
		-- if t_channel_type == n_channel_type then
		-- 	self:FlushChatList()

		-- 	--私聊直接清除对应未读消息
		-- 	if n_channel_type == CHANNEL_TYPE.PRIVATE then
		-- 		ChatData.Instance:RemPrivateUnreadMsg(current_id)
		-- 	end
		-- end
	end
	local is_show = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GUILD_ANSWER)
	if is_show and self.node_list["EndText"].text.text == "" and self.node_list["QuestionTxt"].text.text == "" then
		is_show = false
	end
	local is_not_finish = GuildData.Instance:CheckIsShowGuildQuestion()
	if is_show and is_not_finish then
		self.node_list["Time"]:SetActive(false)
		self.node_list["bg_num"]:SetActive(false)
		self.node_list["EndText"].text.text = Language.GuildDaTi.DaTiHasFinish
		self.node_list["EndText"]:SetActive(true)
		self.node_list["QuestionTxt"]:SetActive(false)
	end
	local special_type = ChatData.Instance:GetCurIsLiaoOrSystem()
	self.node_list["ImgGuildQuestion"]:SetActive(is_show and self.channel_type == 1  and special_type ~= SPECIAL_CHAT_ID.FALLITEM)
	self:ChangeRect(is_show)

	self:FlushChatList(true)
	self:FlushAllRemind()
end

function GuildChatView:ChangeRect(is_show)
	local rect = self.node_list["CharList"].rect
	rect.anchorMin = Vector2(0, 0)
	rect.anchorMax = Vector2(1, 1)
	rect.anchoredPosition3D = Vector3(0, (is_show and self.channel_type == 1) and -55 or 0, 0)
	rect.sizeDelta = Vector2(0, (is_show and self.channel_type == 1) and -110 or 0)
end

function GuildChatView:ChangeListHeight()
	local static_list_height = #self.static_list_data * (self.dynamic_cell_height + self.dynamic_list_view_spacing)
	self.static_list.rect.sizeDelta = Vector2(self.static_list_width, static_list_height)
	--强制刷新
	LayoutRebuilder.ForceRebuildLayoutImmediate(self.static_list.rect)

	local dynamic_list_height = self.target_list_content.rect.rect.height - static_list_height
	self.dynamic_list.rect.sizeDelta = Vector2(self.dynamic_list_width, dynamic_list_height)
	--强制刷新
	LayoutRebuilder.ForceRebuildLayoutImmediate(self.dynamic_list.rect)
end

function GuildChatView:FlushAllRemind()
	for _, v in pairs(self.static_cell_list) do
		v:FlushRemind()
	end

	for _, v in pairs(self.dynamic_cell_list) do
		v:FlushRemind()
	end
end

function GuildChatView:GetStaticTargetNum()
	return #self.static_list_data
end

function GuildChatView:StaticListRefreshCell(cell, data_index)
	data_index = data_index + 1
	local static_cell = self.static_cell_list[cell]
	if nil == static_cell then
		static_cell = ChatTargetItem.New(cell.gameObject)
		static_cell.root_node.toggle.group = self.target_list_content.toggle_group
		static_cell:SetClickCallBack(BindTool.Bind(self.TargetCellClick, self))
		self.static_cell_list[cell] = static_cell
	end

	static_cell:SetIndex(data_index)

	local data = self.static_list_data[data_index]

	local current_id = ChatData.Instance:GetCurrentId()

	--设置高亮展示
	local role_id = data.role_id
	if role_id == current_id then
		static_cell:SetToggleIsOn(true)
	else
		static_cell:SetToggleIsOn(false)
	end

	static_cell:SetData(data)

	static_cell:FlushRemind()

	static_cell:UnBindIsOnlineEvent()
end

function GuildChatView:GetDynamicTargetNum()
	return #self.dynamic_list_data
end

function GuildChatView:DynamicListRefreshCell(cell, data_index)
	data_index = data_index + 1
	local target_cell = self.dynamic_cell_list[cell]
	if nil == target_cell then
		target_cell = ChatTargetItem.New(cell.gameObject)
		target_cell.root_node.toggle.group = self.target_list_content.toggle_group
		target_cell:SetClickCallBack(BindTool.Bind(self.TargetCellClick, self))
		self.dynamic_cell_list[cell] = target_cell
	end

	target_cell:SetIndex(data_index)

	local data = self.dynamic_list_data[data_index]

	local current_id = ChatData.Instance:GetCurrentId()

	--设置高亮展示
	local role_id = data.role_id
	if role_id == current_id then
		target_cell:SetToggleIsOn(true)
	else
		target_cell:SetToggleIsOn(false)
	end

	target_cell:SetData(data)

	target_cell:FlushRemind()

	target_cell:UnBindIsOnlineEvent()
	target_cell:BindIsOnlineEvent()
end

--点击聊天对象后回调
function GuildChatView:TargetCellClick(cell)
	local data = cell:GetData()
	if not data then
		return
	end
	self.guild_view:ChangeChannelType()
	cell.root_node.toggle.isOn = true

	local current_id = ChatData.Instance:GetCurrentId()
	if current_id == data.role_id then
		return
	end

	current_id = data.role_id
	
	--记录聊天id
	ChatData.Instance:SetCurrentId(current_id)
	self:FlushWantEquip()
	self:RefreshDynamicSelectIndex()
	self.channel_type = current_id
	self:JudgeStage(self.channel_type, self.show_guild_question)
	--self:StopPawnTimes()
	if current_id == SPECIAL_CHAT_ID.GUILD then
		ChatData.Instance:ClearGuildUnreadMsg()
		ChatData.Instance:SetNewLockState(false)
		self:StartPawnTimes()
		self:FlushPawnScoreView()
		self:SetTopToggleIsOn(1, true)
	elseif current_id == SPECIAL_CHAT_ID.TEAM then
		ChatData.Instance:ClearTeamUnreadMsg()
		-- self.node_list["TxtTisPawn"]:SetActive(false)
		self:FlushTeamView(true)
	else
		ChatData.Instance:RemPrivateUnreadMsg(current_id)
		-- self.node_list["TxtTisPawn"]:SetActive(false)
		self:FlushPriviteRoleInfo()
	end
	
	cell:FlushRemind()

	--刷新聊天信息
	self:FlushChatList(true)

	RemindManager.Instance:Fire(RemindName.GuildChatRed)
end

function GuildChatView:FlushStaticListView()
	self.static_list_view.scroller:ReloadData(0)
end

function GuildChatView:InitDynamicListView()
	local list_view_height = self.dynamic_list.rect.rect.height
	local max_hight = (self.dynamic_cell_height + self.dynamic_list_view_spacing) * #self.dynamic_list_data - self.dynamic_list_view_spacing
	local not_see_height = math.max(max_hight - list_view_height, 0)
	local bili = 0
	if not_see_height > 0 then
		bili = math.min(((self.dynamic_cell_height + self.dynamic_list_view_spacing) * (self.select_dynamic_index - 1)) / not_see_height, 1)
	end
	self.dynamic_list_view.scroller:ReloadData(bili)
end

function GuildChatView:CountDown(elapse_time, total_time)
	self.node_list["TxtTime"].text.text = ToColorStr(math.ceil(total_time - elapse_time), TEXT_COLOR.GREEN)
	if elapse_time >= total_time then
		self.show_guild_question = false
		self:JudgeStage(self.channel_type, self.show_guild_question)
	end
end

function GuildChatView:JudgeStage(ChannelType, ShowGuildQuestion)
	--self.node_list["TxtPanel"]:SetActive(ChannelType == 1)
	self.node_list["ImgGuildTips"]:SetActive( ChannelType == 1 and (not ShowGuildQuestion) )
	self.node_list["ImgPriviteTips"]:SetActive(false)
	-- self.node_list["BtnChat"]:SetActive((not ShowGuildQuestion) and ChannelType == 1)
	--self.node_list["BtnNotice"]:SetActive((not ShowGuildQuestion) and ChannelType == 1)
	--self.node_list["BtnSignin"]:SetActive(ChannelType == 1 and (not ShowGuildQuestion))
	self.node_list["GuildChat"]:SetActive(ChannelType == 1)
	self.node_list["SingleChat"]:SetActive(ChannelType > 100)
	self.node_list["TeamChat"]:SetActive(ChannelType == 2)
	self.node_list["Equip"]:SetActive(not (ChannelType > 100))

	local is_show = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GUILD_ANSWER)
	if is_show and self.node_list["EndText"].text.text == "" and self.node_list["QuestionTxt"].text.text == "" then
		is_show = false
	end
	local special_type = ChatData.Instance:GetCurIsLiaoOrSystem()
	self.node_list["ImgGuildQuestion"]:SetActive(is_show and ChannelType == 1 and special_type ~= SPECIAL_CHAT_ID.FALLITEM)
	self:ChangeRect(is_show)

	if ChannelType > 100 then
		self.node_list["PlayPawnBtn"]:SetActive(false)
	else
		local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
		local other_cfg = GuildData.Instance:GetOtherConfig()
		local is_show_shen_yu_day = 0
		if other_cfg then
			is_show_shen_yu_day = other_cfg.cross_boss_show_day
		end
		self.node_list["PlayPawnBtn"]:SetActive(not ShowGuildQuestion and ChannelType ~= 2 and cur_day < is_show_shen_yu_day)
	end
	

end

function GuildChatView:UnBindFriend()
	if self.friend_callback then
		GlobalEventSystem:UnBind(self.friend_callback)
		self.friend_callback = nil
	end
end

function GuildChatView:UnBindBlack()
	if self.black_callback then
		GlobalEventSystem:UnBind(self.black_callback)
		self.black_callback = nil
	end
end

function GuildChatView:UnBindSpecialTarget()
	if self.special_change_callback then
		GlobalEventSystem:UnBind(self.special_change_callback)
		self.special_change_callback = nil
	end
end

function GuildChatView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then

		if RemindName.CoolChat == remind_name then
				self.node_list["ImgRedChat"]:SetActive(num > 0)
		elseif RemindName.GuildMaze == remind_name then
			self.node_list["ImgMaze"]:SetActive(num > 0)
		end

	end
end

function GuildChatView:OnTipsPopClick()
end

function GuildChatView:GoCoolShop()
	ViewManager.Instance:Open(ViewName.CoolChat)
	self:Close()
end

function GuildChatView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(163)
end

function GuildChatView:OnClickHongBao(index)
	if GuildData.Instance:IsGetGuildHongBao(index) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.HasGetHongBao)
		return
	end
	if not GuildData.Instance:IsCanGetGuildHongBao(index) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.CannotGetHongBao)
		return
	end
	GuildCtrl.Instance:SendFetchGuildBossRedbagReq(index)
end

--刷新聊天对象列表
function GuildChatView:FlushDynamicListView()
	if self.dynamic_list_view and self.dynamic_list_view.scroller.isActiveAndEnabled  then
		self.dynamic_list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function GuildChatView:FlushMemberList()
	if self.node_list["member_list_view"].scroller.isActiveAndEnabled then
		self.node_list["member_list_view"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function GuildChatView:FlushPawnScoreView()
	if self.node_list["PwanRankListView"].scroller.isActiveAndEnabled then
		self.node_list["PwanRankListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end
	self:OnFlushPawnTime()
	self:FlushRolePwanPank()
end
function GuildChatView:GetChatMeasuring(delegate)
	if not delegate then
		return
	end
	if not self.chat_measuring then
		local cell = delegate:CreateCell()
		cell.transform:SetParent(UILayer.transform, false)
		cell.transform.localPosition = Vector3(9999, 0, 0)			--直接放在界面外
		GameObject.DontDestroyOnLoad(cell.gameObject)
		self.chat_measuring = ChatCell.New(cell.gameObject)
	end
	return self.chat_measuring
end

function GuildChatView:HandleClose()
	self:Close()
end

function GuildChatView:HandleOpenItem()
	TipsCtrl.Instance:ShowPropView()
end

--获取人物当前坐标
function GuildChatView:GetMainRolePos()
	local main_role = Scene.Instance.main_role

	local msg = ""
	if nil ~= main_role then
		local x, y = main_role:GetLogicPos()
		if AStarFindWay:IsBlock(x, y) then
			SysMsgCtrl.Instance:ErrorRemind(Language.Chat.PositionInValid)
			return
		end
		
		local scene_key = PlayerData.Instance:GetAttr("scene_key") or 0
		local open_line = PlayerData.Instance:GetAttr("open_line") or 0
		-- 如果此场景不能分线
		if open_line <= 0 then
			scene_key = -1
		end
		--直接发出去
		local scene_id = Scene.Instance:GetSceneId()
		msg = "{point;" ..  Scene.Instance:GetSceneName() .. ";" .. x .. ";" .. y .. ";" .. scene_id .. ";" .. scene_key .. "}"
	end
	if msg == "" then
		return
	end

	local current_id = ChatData.Instance:GetCurrentId()
	if current_id == SPECIAL_CHAT_ID.GUILD then
		if not ChatData.Instance:IsCanChat(CHAT_OPENLEVEL_LIMIT_TYPE.GUILD) then
			return
		end
		ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, msg, CHAT_CONTENT_TYPE.TEXT)
	elseif current_id == SPECIAL_CHAT_ID.TEAM then
		ChatCtrl.SendChannelChat(CHANNEL_TYPE.TEAM, msg, CHAT_CONTENT_TYPE.TEXT)
	elseif current_id > SPECIAL_CHAT_ID.ALL then
		--有私聊对象
		if not ChatData.Instance:IsCanChat(CHAT_OPENLEVEL_LIMIT_TYPE.SINGLE) then
			return
		end

		local msg_info = ChatData.CreateMsgInfo()
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		msg_info.from_uid = main_vo.role_id
		local real_role_id = CrossServerData.Instance:GetRoleId()				--获取真实id，防止在跨服聊天出问题
		real_role_id = real_role_id > 0 and real_role_id or main_vo.role_id
		msg_info.role_id = real_role_id
		msg_info.username = main_vo.name
		msg_info.sex = main_vo.sex
		msg_info.camp = main_vo.camp
		msg_info.prof = main_vo.prof
		msg_info.authority_type = main_vo.authority_type
		msg_info.avatar_key_small = main_vo.avatar_key_small
		msg_info.level = main_vo.level
		msg_info.vip_level = main_vo.vip_level
		msg_info.channel_type = CHANNEL_TYPE.PRIVATE
		msg_info.content = msg
		msg_info.send_time_str = TimeUtil.FormatTable2HMS(TimeCtrl.Instance:GetServerTimeFormat())
		msg_info.content_type = CHAT_CONTENT_TYPE.TEXT
		msg_info.tuhaojin_color = CoolChatData.Instance:GetTuHaoJinCurColor() or 0			--土豪金
		msg_info.channel_window_bubble_type = CoolChatData.Instance:GetSelectSeq()					--气泡框
		local immor_active_list = ImmortalData.Instance:GetActiveList()
		msg_info.has_xianzunka_flag = immor_active_list[3] and 4 or 0
		msg_info.is_read = 1

		ChatData.Instance:AddPrivateMsg(current_id, msg_info)
		ChatCtrl.SendSingleChat(current_id, msg, CHAT_CONTENT_TYPE.TEXT)
		self:FlushChatList(false, current_id)
	end
end

function GuildChatView:HandleInsertLocation()
	self:GetMainRolePos()
end

function GuildChatView:HandleVoiceStart()
	--先判断是否在私聊
	local private_id = ChatData.Instance:GetCurrentId()
	if private_id > SPECIAL_CHAT_ID.ALL then
		AutoVoiceCtrl.Instance:ShowVoiceView()
	else
		--是否有公会
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		if main_vo.guild_id <= 0 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NotEnterGuild)
			return
		end
		AutoVoiceCtrl.Instance:ShowVoiceView(CHANNEL_TYPE.GUILD)
	end
end

function GuildChatView:HandleVoiceStop()
	AutoVoiceCtrl.Instance:Close()
end

--添加物品
function GuildChatView:SetData(data, is_equip)
	if not data or not next(data) then
		return
	end
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if not item_cfg then
		return
	end

	local text = self.node_list["ChatInput"].input_field.text
	if ChatData.ExamineEditText(text, 2) then
		self.node_list["ChatInput"].input_field.text = text .. "[" .. item_cfg.name .. "]"
		local cell_data = {}
		if is_equip then
			cell_data = ForgeData.Instance:GetZhuanzhiEquip(data.index)
		else
			cell_data = ItemData.Instance:GetGridData(data.index)
		end
		ChatData.Instance:InsertItemTab(cell_data, is_equip)
	end
end

function GuildChatView:HandleOpenRedPackage()
	local main_role = GameVoManager.Instance:GetMainRoleVo()
	if main_role.guild_id <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NotEnterGuild)
		return
	end
	HongBaoCtrl.Instance:ShowHongBaoView(GameEnum.HONGBAO_SEND, RED_PAPER_TYPE.RED_PAPER_TYPE_COMMON)
end

-- 添加表情
function GuildChatView:SetFace(index)
	local face_id = string.format("%03d", index)
	local edit_text = self.node_list["ChatInput"].input_field
	if edit_text and ChatData.ExamineEditText(edit_text.text, 3) then
		self.node_list["ChatInput"].input_field.text = edit_text.text .. "/" .. face_id
		ChatData.Instance:InsertFaceTab(face_id)
	end
end

function GuildChatView:HandleOpenEmoji()
	local function callback(face_id)
		if self:IsOpen() then
			self:SetFace(face_id)
		end
	end
	TipsCtrl.Instance:ShowExpressView(callback)
end

--发送消息
function GuildChatView:HandleSend()
	local text = self.node_list["ChatInput"].input_field.text
	if text == "" then
		-- 屏蔽弹提示
		-- SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NilContent)
		self.node_list["ChatInput"].input_field.text = ""
		return
	end
	--格式化字符串
	text = ChatData.Instance:FormattingMsg(text, content_type)
	self:SendText(text)
end

--刷新聊天信息
function GuildChatView:SendText(text)
	local content_type = CHAT_CONTENT_TYPE.TEXT
	if text == "" then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NilContent)
		self.node_list["ChatInput"].input_field.text = ""
		return
	end
	--有非法字符直接不让发
	if ChatFilter.Instance:IsIllegal(text, false) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.IllegalContent)
		ChatData.Instance:ClearInput()
		return
	end

	-- 协议返回不过滤，改用发送的时候过滤
	text = ChatFilter.Instance:Filter(text)
	
	local current_id = ChatData.Instance:GetCurrentId()
	if current_id == SPECIAL_CHAT_ID.GUILD then
		if not ChatData.Instance:IsCanChat(CHAT_OPENLEVEL_LIMIT_TYPE.GUILD) then
			return
		end
		ChatData.Instance:AddToHistoryMsgList(text)
		ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, text, content_type)
	elseif current_id == SPECIAL_CHAT_ID.TEAM then
		ChatData.Instance:AddToHistoryMsgList(text)
		ChatCtrl.SendChannelChat(CHANNEL_TYPE.TEAM, text, content_type)
	elseif current_id > SPECIAL_CHAT_ID.ALL then
		if not ChatData.Instance:IsCanChat(CHAT_OPENLEVEL_LIMIT_TYPE.SINGLE) then
			return
		end
		local msg_info = ChatData.CreateMsgInfo()
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		msg_info.from_uid = main_vo.role_id
		local real_role_id = CrossServerData.Instance:GetRoleId()				--获取真实id，防止在跨服聊天出问题
		real_role_id = real_role_id > 0 and real_role_id or main_vo.role_id
		msg_info.role_id = real_role_id
		msg_info.username = main_vo.name
		msg_info.sex = main_vo.sex
		msg_info.camp = main_vo.camp
		msg_info.prof = main_vo.prof
		msg_info.authority_type = main_vo.authority_type
		msg_info.avatar_key_small = main_vo.avatar_key_small
		msg_info.level = main_vo.level
		msg_info.vip_level = main_vo.vip_level
		msg_info.channel_type = CHANNEL_TYPE.PRIVATE
		msg_info.content = text
		msg_info.send_time_str = TimeUtil.FormatTable2HMS(TimeCtrl.Instance:GetServerTimeFormat())
		msg_info.content_type = content_type
		msg_info.tuhaojin_color = CoolChatData.Instance:GetTuHaoJinCurColor() or 0			--土豪金
		msg_info.channel_window_bubble_type = CoolChatData.Instance:GetSelectSeq()					--气泡框
		local immor_active_list = ImmortalData.Instance:GetActiveList()
		msg_info.has_xianzunka_flag = immor_active_list[3] and 4 or 0
		msg_info.is_read = 1
		
		ChatData.Instance:AddPrivateMsg(current_id, msg_info)

		local msg_info = ChatData.CreateMsgInfo()
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		msg_info.from_uid = main_vo.role_id
		local real_role_id = CrossServerData.Instance:GetRoleId()
		real_role_id = real_role_id > 0 and real_role_id or main_vo.role_id
		msg_info.role_id = real_role_id
		msg_info.channel_type = CHANNEL_TYPE.PRIVATE
		msg_info.content = text
		-- msg_info.is_read = 1

		if self.private_chat_is_online == 0 then
			msg_info.is_special = true
			ChatData.Instance:AddPrivateMsg(current_id, msg_info)
		end

		ChatData.Instance:AddToHistoryMsgList(text)
		ChatCtrl.SendSingleChat(current_id, text, content_type)
		self:FlushChatList(false, current_id)
	end

	self.guild_view:ChangeChannelType()
	-- 发送文字信息
	self.node_list["ChatInput"].input_field.text = ""
	-- 屏蔽掉输入文字发送后不再继续弹出输入键盘
	-- self.node_list["ChatInput"].input_field:ActivateInputField()
	ChatData.Instance:ClearInput()
end

function GuildChatView:OpenNotice()
	local function callback(str)
		self:SendText(str)
	end
	ChatCtrl.Instance:OpenQuickChatView(QUICK_CHAT_TYPE.NORMAL, callback)
end

--刷新聊天信息
function GuildChatView:FlushChatList(is_force, role_id)
	local current_id = ChatData.Instance:GetCurrentId()
	if self.node_list["VoicePlay"] then
		self.node_list["VoicePlay"]:SetActive((not SHIELD_VOICE) and current_id == SPECIAL_CHAT_ID.GUILD)
	end
	if is_force then
		if role_id == CHANNEL_TYPE.GUILD_SYSTEM then
			self.guild_view:FlushGuildView(SPECIAL_CHAT_ID.SYSTEM)
			return
		elseif role_id == SPECIAL_CHAT_ID.FALLITEM then
			self.guild_view:FlushGuildView(SPECIAL_CHAT_ID.FALLITEM)
			return
		elseif role_id == SPECIAL_CHAT_ID.GUILD then
			self.guild_view:ChangeChannelType()
		end
		self.guild_view:FlushGuildView(current_id)
	else
		if current_id == role_id then
			self.guild_view:FlushGuildView(current_id)
		end
	end
end

function GuildChatView:FriendListChange(role_id)
	local current_id = ChatData.Instance:GetCurrentId()
	if role_id and current_id == role_id then
		self:FlushPriviteRoleInfo()
	end
end

function GuildChatView:BlackListChange(role_id)
	local current_id = ChatData.Instance:GetCurrentId()
	if current_id == role_id then
		self:FlushSelectTarget()
	end
end

--特殊聊天对象状态改变
function GuildChatView:SpecialTargetChange(special_chat_id, is_in)
	if not ViewManager.Instance:IsOpen(ViewName.ChatGuild) then
		return
	end
	self:FlushSelectTarget()
end

--刷新私聊对象数据
function GuildChatView:FlushPriviteRoleInfo()
	if not self:IsOpen() then
		return
	end
	
	local current_id = ChatData.Instance:GetCurrentId()
	if current_id > SPECIAL_CHAT_ID.ALL then
		local private_obj = ChatData.Instance:GetPrivateObjByRoleId(current_id)
		if nil == private_obj then
			return
		end
		--设置头像

		AvatarManager.Instance:SetAvatar(current_id, self.node_list["RawImageSingle"], self.node_list["ImgSingle"], private_obj.sex, private_obj.prof, false)

		--设置等级
		-- local lv, zhuan = PlayerData.GetLevelAndRebirth(private_obj.level)
		-- local level_des = string.format(Language.Common.LevelFormat, lv, zhuan)
		self.node_list["TxtLevel"].text.text = string.format(Language.Chat.LevelDesc, PlayerData.GetLevelString(private_obj.level))

		self.node_list["TxtProf"].text.text = string.format(Language.Chat.ProfDesc, PlayerData.GetProfNameByType(private_obj.prof))

		local btn_text = Language.Menu.AddFriend
		if ScoietyData.Instance:IsFriendById(current_id) then
			btn_text = Language.Menu.GiveFlower
		end
		self.node_list["TxtBtn1"].text.text = btn_text
		-- self:StopPawnTimes()
	end
end

--刷新队伍相关信息
function GuildChatView:FlushTeamView(is_init)
	self.team_data = ScoietyData.Instance:GetTeamUserList()
	self:FlushTeamList(is_init)

	local is_leader = ScoietyData.Instance:IsLeaderById(GameVoManager.Instance:GetMainRoleVo().role_id)
	self.node_list["BtnInvite"]:SetActive(is_leader)

	local team_list = ScoietyData.Instance:GetMemberList()
	if team_list and next(team_list) then
		for i = 1, 3 do
			UI:SetGraphicGrey(self.node_list["ImgPerson" .. i], not(i <= #team_list and team_list[i].is_online == 1))
		end
	end
	local add_exp = ScoietyData.Instance:GetTeamAddExp()
	self.node_list["TxtExpAdd"].text.text = string.format(Language.Chat.AddExpDesc, add_exp)
end

function GuildChatView:StopPawnTimes()
	if self.pawn_show_time then
		GlobalTimerQuest:CancelQuest(self.pawn_show_time)
		self.pawn_show_time = nil
	end
end

function GuildChatView:StartPawnTimes()
	-- 添加定时出现的骰子信息提示
	self:StopPawnTimes()
	self.pawn_show_time = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.ShowPawnUpade, self), 10)
	self:ShowPawnUpade()
end

-- 公会骰子气泡提示
function GuildChatView:ShowPawnUpade()
	-- 玩家是否剩余抛骰子次数
	local can_play = PlayPawnData.Instance:CanPlayPwan()
	-- 抛骰子冷却时间是否足够
	local play_cd = PlayPawnData.Instance:GetPlayCDTime()
	local state_question = not self.show_guild_question
	if can_play and state_question then
		if self.delay_shou_qipao then
			GlobalTimerQuest:CancelQuest(self.delay_shou_qipao)
			self.delay_shou_qipao = nil
		end
		self.node_list["TxtTisPawn"]:SetActive(true)
		self.delay_shou_qipao = GlobalTimerQuest:AddDelayTimer(function ()
			self.node_list["TxtTisPawn"]:SetActive(false)
		end,5)
	elseif not can_play and state_question then
		self:StopPawnTimes()
		self.node_list["TxtTisPawn"]:SetActive(false)
	elseif self.show_guild_question then
		self.node_list["TxtTisPawn"]:SetActive(false)
	end

end


function GuildChatView:CancelQuestionCountDown()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

--打开界面时设置一遍
function GuildChatView:SetTopToggleIsOn(index, is_on)
	if self.node_list["GuildToggle" .. index].gameObject.activeInHierarchy then
		self.node_list["GuildToggle" .. index].toggle.isOn = is_on
		self.record_top_toggle_state[index] = nil
	else
		self.record_top_toggle_state[index] = is_on
	end

	for i = 1, 3 do
		if i ~= index then
			self.record_top_toggle_state[i] = nil
		end
	end
end

--防止从私聊进入界面 设置toggle失效
function GuildChatView:CheckSetTopToggle(current_id)
	if current_id == SPECIAL_CHAT_ID.GUILD then
		for i = 1, 3 do
			if self.record_top_toggle_state[i] ~= nil then
				self.node_list["GuildToggle" .. i].toggle.isOn = not self.record_top_toggle_state[i]
				self:SetTopToggleIsOn(1, self.record_top_toggle_state[i])
			end
		end
		return
	end
end

function GuildChatView:FlushQuestionRank()

end

function GuildChatView:FlushHongBao()

end

function GuildChatView:InitHongBao()

end

function GuildChatView:OnValueChange(value)

end

function GuildChatView:JumpTo()
	local count = GuildData.Instance:GetMaxHongBaoCount() or 0
	local index = 0
	for i = 0, count - 1 do
		if GuildData.Instance:IsCanGetGuildHongBao(i) and not GuildData.Instance:IsGetGuildHongBao(i) then
			index = i
			break
		end
	end
	index = 6
	if index + HongBaoCount > count then
		index = math.max(count - HongBaoCount, 0)
	end
	
end

function GuildChatView:JumpToValue(value)
	
end

function GuildChatView:OnClickLeft()

end

function GuildChatView:FriendClick()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CantOpenInCross)
		return
	end

	local current_id = ChatData.Instance:GetCurrentId()
	if current_id > SPECIAL_CHAT_ID.ALL then
		if ScoietyData.Instance:IsFriendById(current_id) then
			local friend_info = ScoietyData.Instance:GetFriendInfoById(current_id)
			FlowersCtrl.Instance:SetFriendInfo(friend_info)
			ViewManager.Instance:Open(ViewName.Flowers)
		else
			ScoietyCtrl.Instance:AddFriendReq(current_id)
		end
	end
end

function GuildChatView:TeamClick()
	local current_id = ChatData.Instance:GetCurrentId()

	if self.private_chat_is_online == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.OnlineLimitDes)
		return
	end
	
	if current_id > SPECIAL_CHAT_ID.ALL then
		if not ScoietyData.Instance:GetTeamState() then
			if ViewManager.Instance:IsOpen(ViewName.Scoiety) then
				ScoietyCtrl.Instance.scoiety_view:ChangeToIndex(TabIndex.society_team)
			else
				ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
			end
			local param_t = {}
			param_t.must_check = 0
			param_t.assign_mode = 1
			ScoietyCtrl.Instance:CreateTeamReq(param_t)
		end

		local private_obj = ChatData.Instance:GetPrivateObjByRoleId(current_id) or {}
		ScoietyCtrl.Instance:InviteUniqueUserReq(current_id, private_obj.plat_type)
	end
end

function GuildChatView:CheckClick()
	local current_id = ChatData.Instance:GetCurrentId()
	if current_id > SPECIAL_CHAT_ID.ALL then
		CheckData.Instance:SetCurrentUserId(current_id)
		-- CheckCtrl.Instance:SendQueryRoleInfoReq(current_id)
		local private_obj = ChatData.Instance:GetPrivateObjByRoleId(current_id) or {}
		CheckCtrl.Instance:SendCrossQueryRoleInfo(private_obj.plat_type, current_id)
		ViewManager.Instance:Open(ViewName.CheckEquip)
	end
end

function GuildChatView:TradeClick()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CantOpenInCross)
		return
	end

	local current_id = ChatData.Instance:GetCurrentId()
	if current_id > SPECIAL_CHAT_ID.ALL then
		TradeCtrl.Instance:SendTradeRouteReq(current_id)
	end
end

function GuildChatView:BlackClick()
	local current_id = ChatData.Instance:GetCurrentId()
	if current_id > SPECIAL_CHAT_ID.ALL then
		local private_obj = ChatData.Instance:GetPrivateObjByRoleId(current_id) or {}
		local function yes_func()
			ScoietyCtrl.Instance:AddBlackReq(current_id)
		end

		local describe = string.format(Language.Society.AddBlackDes, private_obj.username or "")
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	end
end

function GuildChatView:MarryClick()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CantOpenInCross)
		return
	end

	TipsCtrl.Instance:ShowCommonTip(BindTool.Bind(function ()
		local cfg = MarriageData.Instance:GetMarriageConditions()
		if nil == cfg then return end
		local npc_info = MarryMeData.Instance:GetNpcInfo(cfg.marry_npc_scene_id, cfg.marry_npc_id)
		if npc_info then
			MoveCache.end_type = MoveEndType.NpcTask
			MoveCache.param1 = cfg.marry_npc_id
			GuajiCtrl.Instance:MoveToPos(cfg.marry_npc_scene_id, npc_info.x, npc_info.y, 1, 1, false)
		end
	end, self), nil, Language.Marriage.GoToMarryTip[1])
end

function GuildChatView:TrackClick()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CantOpenInCross)
		return
	end

	local current_id = ChatData.Instance:GetCurrentId()
	if current_id <= SPECIAL_CHAT_ID.ALL then
		return
	end

	local private_obj = ChatData.Instance:GetPrivateObjByRoleId(current_id) or {}

	if private_obj.is_online ~= 1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.OnlineLimitDes)
		return
	end

	--当前场景无法传送
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type ~= SceneType.Common then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.CannotFindPath)
		return
	end

	local function ok_func()
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		local need_item_data = ShopData.Instance:GetShopItemCfg(27582)
		if not need_item_data then
			return
		end
		local item_num = ItemData.Instance:GetItemNumInBagById(27582)
		if main_vo.gold < need_item_data.gold then
			--元宝不足
			TipsCtrl.Instance:ShowLackDiamondView()
			return
		elseif item_num <= 0 then
			--材料不足，弹出购买
			local function close_call_back()
				PlayerCtrl.Instance:SendSeekRoleWhere(private_obj.username or "")
			end
			TipsCtrl.Instance:ShowShopView(27582, 2, close_call_back)
		else
			PlayerCtrl.Instance:SendSeekRoleWhere(private_obj.username or "")
		end
	end

	local str = string.format(Language.Role.TraceConfirm, private_obj.username or "")
	TipsCtrl.Instance:ShowCommonAutoView("", str, ok_func)
end

-- 公会骰子
function GuildChatView:PlayPawn()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CantOpenInCross)
		return
	end
	GuildChatData.Instance:SetRedShowSign(false)
	local show_sign = GuildChatData.Instance:GetRedShowSign()
	local current_id = ChatData.Instance:GetCurrentId()
	-- if  current_id ~= SPECIAL_CHAT_ID.SYSTEM then
	UI:SetButtonEnabled(self.node_list["PlayPawnBtn"], false)
	self.node_list["RedPoint"]:SetActive(show_sign)
	PlayPawnCtrl.Instance:OpenPlayPawnView()


	-- else
	-- 	TipsCtrl.Instance:ShowSystemMsg(Language.Guild.PawnTips)
	-- end
end

function GuildChatView:ChangeChannelGuildSystem(channel_type)
	if channel_type == CHANNEL_TYPE.CAMP then
		--self.guild_view:ChangeChannelType()
	end
end


function GuildChatView:ClickQuick()
	ChatCtrl.Instance:OpenQuickChatView(QUICK_CHAT_TYPE.GUILD)
end

function GuildChatView:ClickLeaveTeam()
	local function ok_func()
		ScoietyCtrl.Instance:ExitTeamReq()
	end
	local des = Language.Society.ExitTeam

	TipsCtrl.Instance:ShowCommonAutoView("leave_team", des, ok_func)
end

function GuildChatView:ClickInvite()
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

-- 刷新玩家公会骰子排名
function GuildChatView:FlushRolePwanPank()
	local role_info = PlayPawnData.Instance:CanCurrRoleInfo()
	if role_info then
	 	self.node_list["TxtRoleName"].text.text = role_info.name
	 	if role_info.rank_num == 0 then
			self.node_list["TxtRoleRank"].text.text = Language.Guild.NotRankStr
		else
			self.node_list["TxtRoleRank"].text.text = role_info.rank_num
	 	end
	 	self.node_list["TxtRoleCount"].text.text = role_info.score
	 	local guild_rank_reward = PlayPawnData.Instance:GetRankReward(role_info.rank_num)
		if guild_rank_reward and next(guild_rank_reward) then
			-- 奖励物品
			if guild_rank_reward.item_id then
				local item_cfg = ItemData.Instance:GetItemConfig(guild_rank_reward.item_id)
				if item_cfg and next(item_cfg) then
					self.node_list["Imgitem"].image:LoadSprite(ResPath.GetItemIcon(item_cfg.icon_id))
				end
			end
			if guild_rank_reward.num then
				self.node_list["TxtCount"].text.text = guild_rank_reward.num
			end
		end
	end
end

-- 下次抛骰子倒计时间
function GuildChatView:OnFlushPawnTime()
	if self.next_timer then
		GlobalTimerQuest:CancelQuest(self.next_timer)
		self.next_timer = nil
	end
	self.next_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushCanPawnNextTime, self), 0.5)
end

function GuildChatView:FlushCanPawnNextTime()
	-- 玩家是否剩余抛骰子次数
	local can_play = PlayPawnData.Instance:CanPlayPwan()
	-- 抛骰子冷却时间是否足够
	local play_cd = PlayPawnData.Instance:GetPlayCDTime()
	local show_sign =  GuildChatData.Instance:GetRedShowSign()
	-- 冷却中
	if can_play and show_sign then
		self.node_list["RedPoint"]:SetActive(true)
	end
	if play_cd > 0 then
		if can_play then
			self.node_list["TxtPawntip"].text.text = ""
			self.node_list["TxtPawTime"].text.text = TimeUtil.FormatSecond(play_cd,11)
		else
			self.node_list["TxtPawTime"].text.text = ""
			self.node_list["TxtPawntip"].text.text = ""
		end
		self.node_list["RedPoint"]:SetActive(false)
		
	else
		-- self.node_list["RedPoint"]:SetActive(true)
		if self.next_timer then
			GlobalTimerQuest:CancelQuest(self.next_timer)
			self.next_timer = nil
		end
		if can_play then
			local play_num = PlayPawnData.Instance:GetCanPlayPwanNum()
			self.node_list["TxtPawntip"].text.text = string.format(Language.Chat.CanPlayNum,play_num)
			UI:SetButtonEnabled(self.node_list["PlayPawnBtn"], true)
			self.node_list["TxtPawTime"].text.text = ""

		else
			self.node_list["TxtPawntip"].text.text = ""
			self.node_list["RedPoint"]:SetActive(false)
			UI:SetButtonEnabled(self.node_list["PlayPawnBtn"], false)
		end
	end
end

-- 根据渠道开启语音聊天
function GuildChatView:UpdateVoiceSwitch()
	if self.node_list["BtnVoice"] then
		self.node_list["BtnVoice"]:SetActive(not SHIELD_VOICE)
	end
	if self.node_list["VoicePlay"] then
		local current_id = ChatData.Instance:GetCurrentId()
		self.node_list["VoicePlay"]:SetActive((not SHIELD_VOICE) and current_id == SPECIAL_CHAT_ID.GUILD)
	end
end

function GuildChatView:OnClickRight()

end

function GuildChatView:NoOpen(is_show)
	SysMsgCtrl.Instance:ErrorRemind(Language.GuildDaTi.NoOpen)
end

function GuildChatView:OnTopTabClick(i, is_click)
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local other_cfg = GuildData.Instance:GetOtherConfig()
	local is_show_shen_yu_day = 0
	if other_cfg then
		is_show_shen_yu_day = other_cfg.cross_boss_show_day
	end
	
	if is_click then
		if i == GUILD_TOP_TOGGLE_NAME.QUESTION then
			-- 公会答题
			local is_show = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GUILD_ANSWER)
			if is_show then
				self.node_list["PawnRankListObj"]:SetActive(false)
				self.node_list["RankListObj"]:SetActive(true)
				self.node_list["ShenYuRankList"]:SetActive(false)
				self.node_list["DaTiRemind"]:SetActive(false)
			else
				SysMsgCtrl.Instance:ErrorRemind(Language.GuildDaTi.Time)
				self.node_list["DaTiRemind"]:SetActive(true)
			end
		elseif i == GUILD_TOP_TOGGLE_NAME.SHAI_ZI then
			-- 公会骰子
			self.node_list["RankListObj"]:SetActive(false)
			self.node_list["ShenYuRankList"]:SetActive(false)
			self.node_list["GuildToggle1"]:SetActive(cur_day < is_show_shen_yu_day)
			self.node_list["PawnRankListObj"]:SetActive(cur_day < is_show_shen_yu_day)
			--self.node_list["PawnRankListObj"]:SetActive(true)
			if self.node_list["PwanRankListView"].scroller.isActiveAndEnabled then
				self.node_list["PwanRankListView"].scroller:RefreshAndReloadActiveCellViews(true)
			end
		elseif i == GUILD_TOP_TOGGLE_NAME.SHEN_YU then
			self.node_list["RankListObj"]:SetActive(false)
			self.node_list["PawnRankListObj"]:SetActive(false)
			self.node_list["GuildToggle3"]:SetActive(cur_day >= is_show_shen_yu_day)
			self.node_list["ShenYuRankList"]:SetActive(cur_day >= is_show_shen_yu_day)
			-- self.node_list["ShenYuRankList"]:SetActive(true)
			if self.node_list["ShenYuRankListView"].scroller.isActiveAndEnabled then
				self.node_list["ShenYuRankListView"].scroller:RefreshAndReloadActiveCellViews(true)
			end
		end
		self.index = i

		for i = 1, 3 do
			self.node_list["ImgToggleHL" .. i]:SetActive(self.index == i)
		end
	end
end

function GuildChatView:GetCurIndex()
	return self.index
end

function GuildChatView:InitMemberListView()
	local list_delegate = self.node_list["member_list_view"].list_simple_delegate
	-- 有有多少个cell
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetMemberNumberOfCells, self)
	-- 更新cell
	list_delegate.CellRefreshDel = BindTool.Bind(self.MemberRefreshCell, self)
end

function GuildChatView:InitChuanWenListView()
	local list_delegate = self.node_list["ChuanwenList"].list_simple_delegate

	list_delegate.CellSizeDel = BindTool.Bind(self.GetCellSizeDel, self)
	-- 有有多少个cell
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetChuanWenNumberOfCells, self)
	-- 更新cell
	list_delegate.CellRefreshDel = BindTool.Bind(self.ChuanWenRefreshCell, self)
end

function GuildChatView:GetMemberNumberOfCells()
	return GuildDataConst.GUILD_MEMBER_LIST.count
end

function GuildChatView:MemberRefreshCell(cell, data_index)
	data_index = data_index + 1
	local icon_cell = self.activity_cell_list[cell]
	if icon_cell == nil then
		icon_cell = MemberCell.New(cell.gameObject)
		icon_cell.root_node.toggle.group = self.node_list["member_list_view"].toggle_group
		self.activity_cell_list[cell] = icon_cell
	end
	local data = {}
	local icon_cell_index = icon_cell.index
	data = GuildDataConst.GUILD_MEMBER_LIST.list[data_index]
	
	icon_cell:SetIndex(data_index)
	icon_cell:SetData(data)
	if icon_cell_index ~= data_index then 
		icon_cell.root_node.toggle.isOn = false
	end
end

function GuildChatView:GetCellSizeDel(data_index)
	local data = {}
	local height = 0
	data = self.guild_event_list_data[data_index + 1]
	if data then
		data.content = GuildData.Instance:ExplainChuanWenText(data)
		height = ChatCtrl.Instance:CaleChuanWenHeight(data, data.content)
	end
	
	return height or 0
end

function GuildChatView:GetChuanWenNumberOfCells()
	local count = GuildData.Instance:GetGuildEventCount()
	return count or 0
end

function GuildChatView:CreateChatContent(assetbundle, prefab_name)
	local gameobj = ResPoolMgr:TryGetGameObject(assetbundle, prefab_name)
	local obj = U3DObject(
		gameobj,
		gameobj.transform, 
		self
	)
	return obj
end

function GuildChatView:ChuanWenRefreshCell(cell, data_index)
	data_index = data_index + 1
	local icon_cell = self.chuanwen_cell_list[cell]
	if icon_cell == nil then
		icon_cell = ChuanwenCell.New(cell.gameObject)
		self.chuanwen_cell_list[cell] = icon_cell
	end
	local data = {}
	data = self.guild_event_list_data[data_index]
	if data then
		data.content = GuildData.Instance:ExplainChuanWenText(data)
		local icon_cell_index = icon_cell.index
		icon_cell:SetIndex(data_index)
		icon_cell:SetData(data)
		icon_cell:Flush()
	end

end

function GuildChatView:InitPawnListView()
	local list_delegate = self.node_list["PwanRankListView"].list_simple_delegate
	-- 有有多少个cell
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCurrScoreOfCells, self)
	-- 更新cell
	list_delegate.CellRefreshDel = BindTool.Bind(self.ScoreRefreshCell, self)
end

function GuildChatView:GetCurrScoreOfCells()
	return PlayPawnData.Instance:GetGuildPawnRankNum()
end

function GuildChatView:ScoreRefreshCell(cell, data_index)
	data_index = data_index + 1
	local score_cell = self.pwan_score_list_view[cell]
	if score_cell == nil then
		score_cell = GuildPawnRankCell.New(cell.gameObject)
		score_cell.root_node.toggle.group = self.node_list["PwanRankListView"].toggle_group
		score_cell:SetClickCallBack(BindTool.Bind(self.ScoreCellClick, self))
		self.pwan_score_list_view[cell] = score_cell
	end

	local rank_info = PlayPawnData.Instance:GetGuildPawnRankInfoByScore()
	if rank_info then
		local data = rank_info[data_index]
		score_cell:SetIndex(data_index)
		score_cell:SetData(data)
	end

	--设置高亮展示
	if data_index == self.select_score_index then
		score_cell:SetSorceToggleIsOn(true)
	else
		score_cell:SetSorceToggleIsOn(false)
	end
end

function GuildChatView:ScoreCellClick(cell)
	local index = cell:GetIndex()
	self.select_score_index = index
end

function GuildChatView:FlushWantEquip()
	local prof, zhuan = PlayerData.Instance:GetRoleBaseProf()
	local current_id = ChatData.Instance:GetCurrentId()
	self.node_list["BtnWantEquip"]:SetActive(zhuan > 0 and current_id == SPECIAL_CHAT_ID.GUILD)
end

function GuildChatView:OnFlush(params_t)
	self.guild_event_list_data = GuildData.Instance:GetGuildEventList()

	self:JudgeStage(self.channel_type, self.show_guild_question)
	self:FlushWantEquip()
	local current_id = ChatData.Instance:GetCurrentId()
	for k, v in pairs(params_t) do
		if k == "view" then
			if current_id == SPECIAL_CHAT_ID.GUILD then
				self:FlushMemberList()
				self:FlushGuildDaTiRankInfo()
				self:FlushTreasureScor()
				self:FlushShenYuRankList()
				self:FlushChuanWenList()
			end
			-- local remind_num = GuildData.Instance:GetSigninRemind()
			-- self.node_list["BtnRedSignin"]:SetActive(remind_num >= 1)
		elseif k == "new_chat" then
			if v[2] and v[2] ~= current_id and v[2] ~= SPECIAL_CHAT_ID.FALLITEM then
				self:FlushAllRemind()
			else
				if v[1] == CHANNEL_TYPE.GUILD_SYSTEM then
					local channel_type = ChatData.Instance:GetCurIsLiaoOrSystem()
					if channel_type == CHANNEL_TYPE.GUILD then
						self:FlushChatList(true, v[2])
					elseif channel_type == CHANNEL_TYPE.GUILD_SYSTEM then
						self:FlushChatList(true, v[1])
					elseif channel_type == SPECIAL_CHAT_ID.FALLITEM then
						self:FlushChatList(true, v[2])
					end
					return
				end
				self:FlushChatList(v[1], v[2])
			end
		elseif k == "hongbao" then
			if current_id == SPECIAL_CHAT_ID.GUILD then
				self:FlushHongBao()
			end
		elseif k == "flush_pawn_scoreview" then
			self:FlushPawnScoreView()
		elseif k == "select_traget" then
			self:FlushSelectTarget(v[1], v[2])
		elseif k == "flush_team_view" then
			if current_id == SPECIAL_CHAT_ID.TEAM then
				self:FlushTeamView()
			end
		elseif k == "flush_dati_view" then
			if current_id == SPECIAL_CHAT_ID.GUILD then
				self:FlushGuildDaTiRankInfo()
				self:FlushTreasureScor()
			end
		elseif k == "flush_shenyu_view" then
			if current_id == SPECIAL_CHAT_ID.GUILD then
				self:FlushShenYuRankList()
			end
		elseif k == "single_chat_online" then
			self:FlushPrivateChatOnlineStatus(v[1])
		else
			self:FlushMemberList()
		end
	end
end

function GuildChatView:FlushGuildDaTiRankInfo()
	local guild_player_info = GuildData.Instance:GetQuestionPlayerInfo()
	local question_info = GuildData.Instance:GetQuestionInfo()
	if guild_player_info == nil or question_info == nil then return end
	local guild_exp =  CommonDataManager.ConverExp(guild_player_info.exp)
	-- 准备倒计时
	if question_info.question_state == 0 then
		self.node_list["bg_num"]:SetActive(false)
		self.node_list["Time"]:SetActive(false)
		local left_time = question_info.question_state_change_timestamp - TimeCtrl.Instance:GetServerTime()
		local function diff_time_fun(elapse_time, total_time)
			local zhunbei_time = math.floor(total_time - elapse_time + 0.5)
			local count_down_text = TimeUtil.FormatSecond(zhunbei_time, 8)
			if zhunbei_time > 0 then
				local is_show = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GUILD_ANSWER)
				local special_type = ChatData.Instance:GetCurIsLiaoOrSystem()
				if is_show then
					self.node_list["ImgGuildQuestion"]:SetActive(is_show and self.channel_type == 1 and special_type ~= SPECIAL_CHAT_ID.FALLITEM)
					self:ChangeRect(is_show)
				end
				self.node_list["QuestionTxt"]:SetActive(false)
				self.node_list["EndText"]:SetActive(true)
				self.node_list["EndText"].text.text = string.format(Language.GuildDaTi.Tips, count_down_text)
			end
		end
		if self.zhunbei_count_down ~= nil then
			CountDown.Instance:RemoveCountDown(self.zhunbei_count_down)
			self.zhunbei_count_down = nil
		end
		if self.question_count_down ~= nil then
			CountDown.Instance:RemoveCountDown(self.question_count_down)
			self.question_count_down = nil
		end
		self.zhunbei_count_down = CountDown.Instance:AddCountDown(left_time, 0.5, diff_time_fun)

	-- 开始答题题目倒计时
	elseif question_info.question_state == 1 then
		local left_time = question_info.question_end_timestamp - TimeCtrl.Instance:GetServerTime()
		local other_cfg = GuildData.Instance:GetGuildQuestionOtherCfg()
		local total_num = other_cfg.question_total_num or 0
		if other_cfg and question_info.question_index <= total_num then
			self.node_list["Txt_question_num"].text.text = Language.GuildDaTi.DaTiNum .. question_info.question_index .. " / " .. total_num
		end
		local function diff_time_fun(elapse_time, total_time)
			local dati_time = math.floor(total_time - elapse_time + 0.5)
			local question_timer = TimeUtil.FormatSecond(dati_time, 9)
			if dati_time > 0 then
				if question_info.question_index == total_num then
					self.total_to_close = true
				end
				local is_show = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GUILD_ANSWER)
				local special_type = ChatData.Instance:GetCurIsLiaoOrSystem()
				if is_show then
					self.node_list["ImgGuildQuestion"]:SetActive(is_show and self.channel_type == 1  and special_type ~= SPECIAL_CHAT_ID.FALLITEM)
					self:ChangeRect(is_show)
				end
				self.node_list["bg_num"]:SetActive(true)
				self.node_list["Time"]:SetActive(true)
				self.node_list["TxtTime"].text.text = ToColorStr(question_timer, TEXT_COLOR.GREEN)
				self.node_list["QuestionTxt"].text.text = string.format(Language.GuildDaTi.Question, question_info.question_str)
				self.node_list["QuestionTxt"]:SetActive(true)
				self.node_list["EndText"]:SetActive(false)
				if guild_player_info.true_name ~= "" then
					self.node_list["NameTxt"]:SetActive(false)
					self.node_list["NameTxt"].text.text = string.format(Language.GuildDaTi.GongXi, guild_player_info.true_name, guild_player_info.guild_score)
				else
					self.node_list["NameTxt"]:SetActive(false)
				end
			else
				if self.total_to_close then
					self.node_list["Time"]:SetActive(false)
					self.node_list["bg_num"]:SetActive(false)
					self.node_list["EndText"].text.text = Language.GuildDaTi.DaTiHasFinish
					self.node_list["EndText"]:SetActive(true)
					self.node_list["QuestionTxt"]:SetActive(false)
					self.guild_view:ChangeChannelGuildSystem()
					self:FlushChatList(true, CHANNEL_TYPE.GUILD_SYSTEM)
					self.total_to_close = false
				end
			end
		end
		if self.zhunbei_count_down ~= nil then
			CountDown.Instance:RemoveCountDown(self.zhunbei_count_down)
			self.zhunbei_count_down = nil
		end
		if self.question_count_down ~= nil then
			CountDown.Instance:RemoveCountDown(self.question_count_down)
			self.question_count_down = nil
		end
		if self.question_count_down == nil then
			self.question_count_down = CountDown.Instance:AddCountDown(left_time, 0.5, diff_time_fun)
		end
	end
end

function GuildChatView:OnClickSignin()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CantOpenInCross)
		return
	end
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	if guild_id <= 0  then
		local shake_state = GuildData.Instance:GetGuildChatShakeState()
		if shake_state == true then
			self:ShakeGuildChatBtn(false)
		end
			ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_request)
	else
		GuildCtrl.Instance:OpenSigninView()
	end
end

function GuildChatView:OpenGuildMaze()
	ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_maze)
end

function GuildChatView:OpenWantEquip()
	local current_id = ChatData.Instance:GetCurrentId()
	ChatCtrl.Instance:OpenWantEquipView(current_id)
end

function GuildChatView:OpenMarket()
	if ViewManager.Instance:IsOpen(ViewName.Market) then
		ViewManager.Instance:PopViewToFront(ViewName.Market)
	else
		ViewManager.Instance:Open(ViewName.Market)
	end
end

function GuildChatView:OpenGuildWage()
	ViewManager.Instance:Open(ViewName.GuildWageView)
end

function GuildChatView:OpenGuildEnemy()
	ChatCtrl.Instance:OpenGuildEnemyView()
end

function GuildChatView:OpenGuildWarehouse()
	if IS_ON_CROSSSERVER then
		ViewManager.Instance:Open(ViewName.GuildWarehouseView)
	else
		ViewManager.Instance:Open(ViewName.GuildWarehouseView)
		GuildCtrl.Instance:SendStorgeOperate(GUILD_STORGE_OPERATE.GUILD_STORGE_OPERATE_REQ_INFO)
	end
end

-- 排行榜
function GuildChatView:InitTreasureBoxScroller()
	local list_delegate = self.node_list["InfoScroller"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshTreasureBoxCell, self)
end

function GuildChatView:GetNumberOfCells()
	--排行信息
	local rank_list = GuildData.Instance:GetGuildRankInfoList()
	return #rank_list
end

function GuildChatView:RefreshTreasureBoxCell(cell, cell_index)
	local rank_cell = self.rank_cell_list[cell]
	if rank_cell == nil  then
		rank_cell = DaTiRankItem.New(cell.gameObject, self)
		self.rank_cell_list[cell] = rank_cell
	end
	cell_index = cell_index + 1
	rank_cell:SetIndex(cell_index)
	rank_cell:Flush()
end


-- 神域击杀榜排行榜
function GuildChatView:InitShenYuRankScroller()
	local list_delegate = self.node_list["ShenYuRankListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetShenYuRankNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshShenYuRankCell, self)
end

function GuildChatView:GetShenYuRankNumberOfCells()
	--排行信息
	local rank_list = RankData.Instance:GetGetGuildWarRankListAck()
	return #rank_list or 0
end

function GuildChatView:RefreshShenYuRankCell(cell, cell_index)
	local rank_cell = self.rank_cell_list[cell]
	if rank_cell == nil  then
		rank_cell = ShenYuRankItem.New(cell.gameObject, self)
		self.rank_cell_list[cell] = rank_cell
	end
	cell_index = cell_index + 1
	rank_cell:SetIndex(cell_index)
	rank_cell:Flush()
end

function GuildChatView:FlushTreasureScor()
	if self.node_list["InfoScroller"] and self.node_list["InfoScroller"].scroller and self.node_list["InfoScroller"].scroller.isActiveAndEnabled then
		self.node_list["InfoScroller"].scroller:RefreshAndReloadActiveCellViews(true)
	end
	self.node_list["InfoScroller"]:SetActive(self:GetNumberOfCells() > 0)
end

function GuildChatView:FlushShenYuRankList()
	if self.node_list["ShenYuRankListView"] and self.node_list["ShenYuRankListView"].scroller and self.node_list["ShenYuRankListView"].scroller.isActiveAndEnabled then
		self.node_list["ShenYuRankListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end
	self.node_list["ShenYuRankListView"]:SetActive(self:GetShenYuRankNumberOfCells() > 0)
end


function GuildChatView:FlushChuanWenList()
	if self.node_list["ChuanwenList"].scroller.isActiveAndEnabled then
		--self.node_list["ChuanwenList"].scroller:RefreshAndReloadActiveCellViews(true)
		self.node_list["ChuanwenList"].scroller:ReloadData(0)
	end
end

function GuildChatView:FlushPrivateChatOnlineStatus(protocol)
	if self.node_list["OnlineStatus"] then
		self.node_list["OnlineStatus"].text.text = ""
	end

	local current_id = ChatData.Instance:GetCurrentId()
	if current_id <= SPECIAL_CHAT_ID.ALL then
		return
	end
	local target_data = ChatData.Instance:GetTargetDataByRoleId(current_id)
	if target_data.plat_type ~= protocol.plat_type or target_data.role_id ~= protocol.role_id then
		return
	end

	if self.node_list["OnlineStatus"] and self.node_list["OnlineStatus"].gameObject.activeInHierarchy then
		local str = protocol.is_online > 0 and Language.Common.OnLine or Language.Common.OutLine
		str = "（" .. str .. "）"
		str = ToColorStr(str, protocol.is_online > 0 and COLOR.GREEN or COLOR.RED)
		self.node_list["OnlineStatus"].text.text = str
	end

	if protocol.is_online == 1 then
		ChatData.Instance:SetPrivateObjRemoveOutLineMsg(current_id)
		self:FlushChatList(false, current_id)
	end

	self.private_chat_is_online = protocol.is_online
end

function GuildChatView:FlushActivityIcon()
	if self.node_list then
		local activity_cfg = ActivityData.Instance:GetNearGuildActivity()
		if activity_cfg and activity_cfg.act_id and activity_cfg.open_time_stamp then
			if self.activity_type ~= activity_cfg.act_id then
				if self.countdown_time then
					CountDown.Instance:RemoveCountDown(self.countdown_time)
					self.countdown_time = nil
				end
			end
			self.node_list["ActivityPanel"]:SetActive(true)
			self.activity_type = activity_cfg.act_id
			local image_name = "Icon_Activity_" .. activity_cfg.act_id
			local bundle, asset = ResPath.GetMainIcon(image_name)
			self.node_list["ImgIcon"].image:LoadSpriteAsync(bundle,asset, function()
				self.node_list["ActivityIcon"]:SetActive(true)
			end)

			local bundle_name ,asset_name = ResPath.GetMainIcon(image_name .. "Name")
			self.node_list["ImgIconName"].image:LoadSpriteAsync(bundle_name ,asset_name, function()
				self.node_list["ImgIconName"]:SetActive(true)
				self.node_list["ImgIconName"].image:SetNativeSize()
			end)
			local server_time = TimeCtrl.Instance:GetServerTime()
			local last_time = activity_cfg.open_time_stamp - server_time
			self:FlushCountDownTime(last_time, activity_cfg)
		else
			self.activity_type = 0
			self.node_list["ActivityPanel"]:SetActive(false)
		end
	end
end

function GuildChatView:OnBtnHelp()
	local tips_id = 329
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function GuildChatView:FlushCountDownTime(time, activity_cfg)
	if time > 0 then
		if nil == self.countdown_time then
			local diff_time = function(elapse_time, total_time)
				if elapse_time >= total_time then
					if self.countdown_time then
						CountDown.Instance:RemoveCountDown(self.countdown_time)
						self.countdown_time = nil
					end
					if self.node_list and self.node_list["TxtRestTime"] then
						self.node_list["TxtRestTime"]:SetActive(false)
					end
					self:FlushActivityIcon()
					return
				end
				if self.node_list and self.node_list["TxtRestTime"] then
					local last_time = math.floor(total_time - elapse_time + 0.5)
					self.node_list["TxtRestTime"].text.text = TimeUtil.FormatSecond(last_time, 10)
				end
			end
			local complete_func = function()
				if self.countdown_time then
					CountDown.Instance:RemoveCountDown(self.countdown_time)
					self.countdown_time = nil
				end
				self:FlushActivityIcon()
			end
			diff_time(0, time)
			self.countdown_time = CountDown.Instance:AddCountDown(time, 1, diff_time, complete_func)
		end
	else
		if nil == self.timer_request then
			self.timer_request = GlobalTimerQuest:AddRunQuest(function()
				local end_time = activity_cfg.end_time_stamp - TimeCtrl.Instance:GetServerTime()
				if end_time <= 0 then
					if self.timer_request then
						GlobalTimerQuest:CancelQuest(self.timer_request)
						self.timer_request = nil
					end
					self:FlushActivityIcon()
					return
				end
			end, 1)
		end
		if self.node_list and self.node_list["TxtRestTime"] then
			self.node_list["TxtRestTime"].text.text = Language.Activity.ActivityIsOn
		end
	end
end


--答题排名滚动条格子------------------------------------------------------
DaTiRankItem = DaTiRankItem or BaseClass(BaseCell)

function DaTiRankItem:__init(instance, view)
	self.parent = view
end

function DaTiRankItem:__delete()
	self.parent = nil
end

function DaTiRankItem:OnFlush()
	local is_show = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GUILD_ANSWER)
	self.node_list["Name"]:SetActive(is_show) 
	self.node_list["Rank"]:SetActive(is_show and self.index > 3)
	self.node_list["No1"]:SetActive(is_show and self.index == 1)
	self.node_list["No2"]:SetActive(is_show and self.index == 2)
	self.node_list["No3"]:SetActive(is_show and self.index == 3)

	self.node_list["FenShu"]:SetActive(is_show)
	local rank_info = GuildData.Instance:GetGuildRankInfo(self.index)
	self:SetActive(rank_info and rank_info.guild_name ~= "")
	if not rank_info then return end
	self.node_list["Name"].text.text = rank_info.guild_name
	self.node_list["Rank"].text.text = string.format(Language.GuildDaTi.Rank, self.index)
	self.node_list["FenShu"].text.text = string.format(Language.GuildDaTi.Score, rank_info.guild_score)

	local guild_name = GameVoManager.Instance:GetMainRoleVo().guild_name or ""
	self.node_list["HighLight"]:SetActive(is_show and guild_name == rank_info.guild_name)
end

--神域击杀榜排名滚动条格子------------------------------------------------------
ShenYuRankItem = ShenYuRankItem or BaseClass(BaseCell)

function ShenYuRankItem:__init(instance, view)
	self.parent = view
	self.node_list["Skill"].button:AddClickListener(BindTool.Bind(self.OnSkillTips, self))
end

function ShenYuRankItem:__delete()
	self.parent = nil
end

function ShenYuRankItem:OnFlush()
	self.node_list["Rank"]:SetActive(self.index > 3)
	self.node_list["No1"]:SetActive(self.index == 1)
	self.node_list["No2"]:SetActive(self.index == 2)
	self.node_list["No3"]:SetActive(self.index == 3)
	self.node_list["Skill"]:SetActive(self.index == 1)

	local rank_info = RankData.Instance:GetGetGuildWarRankListAckInfo(self.index)
	self:SetActive(rank_info and rank_info.guild_name ~= "")
	if not rank_info then return end
	self.node_list["Name"].text.text = rank_info.guild_name
	self.node_list["Rank"].text.text = string.format(Language.GuildDaTi.Rank, self.index)
	self.node_list["JiShaShu"].text.text = rank_info.rank_value

	local guild_name = GameVoManager.Instance:GetMainRoleVo().guild_name or ""
	self.node_list["HighLight"]:SetActive(guild_name == rank_info.guild_name)
end

function ShenYuRankItem:OnSkillTips()
	ChatCtrl.Instance:OpenGuildSkillTips()
end

--江湖传闻
ChuanwenCell = ChuanwenCell or BaseClass(BaseCell)

function ChuanwenCell:__init()
	
end

function ChuanwenCell:__delete()
	
end

function ChuanwenCell:OnFlush()
	if self.data == nil then
		return
	end
	if self.node_list["GuildchuanwenItem"] then
		RichTextUtil.ParseRichText(self.node_list["GuildchuanwenItem"].rich_text, self.data.content)
	end
end

function ChuanwenCell:GetContentHeight()
	if self.node_list["GuildchuanwenItem"] then
		local rect = self.node_list["GuildchuanwenItem"]:GetComponent(typeof(UnityEngine.RectTransform))
		--强制刷新
		LayoutRebuilder.ForceRebuildLayoutImmediate(rect)
		local des_height = rect.rect.height

		local height = des_height / 8 + des_height
		return height
	end
	return 0
end

