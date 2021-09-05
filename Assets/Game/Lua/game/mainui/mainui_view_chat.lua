MainUIViewChat = MainUIViewChat or BaseClass(BaseRender)

MainUIViewChat.ViewState = {
	Short = 0,
	Length = 1,
}

MainUIViewChat.ChannelType = {
	0,				-- 世界
	3,				-- 队伍
	4,				-- 公会
}

--主界面聊天小图标
MainUIViewChat.IconList = {
	Strength = "strength",						--变强
	JuBaoPen = "jubaopen_icon",					--聚宝盆
	MAIL_REC = "mail_rec",						--邮件通知
	FRIEND_REC = "friend_rec",					--好友请求
	JOIN_REQ = "join_req",						--入队申请
	TEAM_REQ = "team_req",						--组队邀请
	TRADE_REQ = "trade_req",					--交易请求
	WEEDING_GET_INVITE = "weeding_get_invite",	--婚宴列表
	GIFT_BTN = "gift_btn",						--送礼提醒
	HONGBAO = "hongbao",						--红包提醒
	SERVER_HONGBAO = "server_hongbao",			--全服红包提醒
	SOS_REQ = "sos_req",						--运镖求救信息
	GUILD_YAO = "guild_yao",					--公会邀请
	OFF_LINE = "off_line",						--离线经验
	LOVE_CONTENT = "love_content",				--爱情契约
	GUILD_GODDESS = "guild_goddess",			--公会女神祝福
	GUILD_INVITE = "guild_invite",				--公会邀请
	BAG_FULL = "bag_full",						--背包已满
	DisCount = "discount",						--特惠豪礼
	DisCountRed = "discount_red",				--特惠豪礼红点
	DisCountAni = "discount_ani",				--特惠豪礼动画
	GuildHongBao = "guild_hongbao",				--公会红包
	Congratulate = "Congratulate",				--好友祝贺
	MarryBlessing = "MarryBlessing",			--结婚祝贺
	GuildMemberFull = "GuildMemberFull",		--公会满员
	MarryInvite = "MarryInvite",				--婚宴请帖
	SendFashion = "SendFashion", 				--送时装
	AddFriend = "AddFriend", 					--加队友
	ExpRefine = "exp_refine",					--经验炼制
	DailyLove = "daily_love",					--每日一爱
	ReturnRecharge = "return_recharge",
	CRAZY_TREE = "crazy_rec",					--疯狂摇钱树
	ChengZhangJiJing = "chengzhangjijing",		--成长基金
	BuyExp = "BuyExp",							--合服经验
	SmallImmortal = "SmallImmortal",			--仙尊卡
	TodayTheme = "TodayTheme",					-- 今日主题
	GongGao = "GongGao",						-- 公告
	BiaoBaiQiang = "BiaoBaiQiang",				-- 表白墙
	SingleRebate = "SingleRebate",				-- 单笔返利
	ActivityReward = "ActivityReward",			-- 玩法奖励展示
	SmallHelper = "SmallHelper",				-- 小助手
	SINGLE_CHONGZHI = "singlechongzhi",			--单返豪礼
	DoubluGold = "doublegold",					--双倍元宝
}

local UILayer = GameObject.Find("GameRoot/UILayer")

function MainUIViewChat:__init()

	local CHAT_ICON_GROUP = {
		{name = MainUIViewChat.IconList.Strength, icon = "Icon_System_BianQiang", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.OpenStrength, self), lable = "变强"},
		{name = MainUIViewChat.IconList.SmallHelper, icon = "Icon_Small_Helper", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.OpenSmallHelperView, self), lable = "小助手"},
		{name = MainUIViewChat.IconList.DisCount, icon = "icon_hui", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.OpenDiscountView, self), lable = "一折", remind = RemindName.DisCount},
		-- {name = MainUIViewChat.IconList.JuBaoPen, icon = "Icon_System_Jubaopeng", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.OpenTreasureBowlView, self), lable = "聚宝盆"},
		{name = MainUIViewChat.IconList.ExpRefine, icon = "Icon_Activity_2159", openfun = "ExpRefine", func = BindTool.Bind(self.IsOpenTipsIcon, self),  call = BindTool.Bind(self.OpenExpRefineView, self), lable = "经验"},
		{name = MainUIViewChat.IconList.TodayTheme, icon = "today_icon", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.OpenTodayThemeTipsView, self), lable = "<size=18>今日主题</size>"},
		{name = MainUIViewChat.IconList.ChengZhangJiJing, icon = "ChengZhangJiJin", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.OpenChengZhangJijing, self), lable = "基金"},
		{name = MainUIViewChat.IconList.BuyExp, icon = "Icon_System_ExpBottle", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.OpenBuyExpView, self), word = "炼丹炉"},
		{name = MainUIViewChat.IconList.DailyLove, icon = "tips_icon_daily_love", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.OpenDailyLoveView, self), word = "",},
		{name = MainUIViewChat.IconList.SINGLE_CHONGZHI, icon = "tips_icon_bg", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.OpenSingleRechargeView, self), word = "返",},
		{name = MainUIViewChat.IconList.ReturnRecharge, icon = "tips_icon_bg", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.OpenReturnRechargeView, self), word = "返",},

		{name = MainUIViewChat.IconList.GIFT_BTN, icon = "icon_gift", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.OpenGiftRecordView, self)},
		{name = MainUIViewChat.IconList.WEEDING_GET_INVITE, icon = "icon_wed", openfun = "marriage", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.HandleOpenWeedingGetInvite, self), lable = "婚宴"},
		{name = MainUIViewChat.IconList.GongGao, icon = "icon_GongGao", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.OpenGongGaoView, self), lable = "公告"},
		{name = MainUIViewChat.IconList.MAIL_REC, icon = "tips_icon_bg", openfun = "scoiety", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.HandleOpenMail, self), word = "邮",},
		{name = MainUIViewChat.IconList.FRIEND_REC, icon = "tips_icon_bg", openfun = "scoiety", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.ShowApplyView, self), word = "友",},
		{name = MainUIViewChat.IconList.HONGBAO, icon = "icon_hongbao", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.OpenHongBao, self), lable = "红包"},
		{name = MainUIViewChat.IconList.TEAM_REQ, icon = "tips_icon_bg", openfun = "scoiety", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.ShowApplyView, self), word = "组",},
		{name = MainUIViewChat.IconList.JOIN_REQ, icon = "tips_icon_bg", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.ShowApplyView, self), word = "队",},
		{name = MainUIViewChat.IconList.TRADE_REQ, icon = "tips_icon_bg", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.HandleOpenTradeReqTips, self), word = "易",},
		{name = MainUIViewChat.IconList.GUILD_YAO, icon = "tips_icon_bg", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.GetGuildInvite, self), word = "邀",},
		{name = MainUIViewChat.IconList.GUILD_INVITE, icon = "tips_icon_bg", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.OpenGuildApply, self), word = "盟",},
		{name = MainUIViewChat.IconList.OFF_LINE, icon = "tips_icon_bg", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.OpenOfflineView, self), word = "离",},
		{name = MainUIViewChat.IconList.LOVE_CONTENT, icon = "tips_icon_bg", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.ClickLoveContent, self), word = "爱",},
		{name = MainUIViewChat.IconList.GUILD_GODDESS, icon = "tips_icon_bg", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.ClickGuildGoddess, self), word = "祝",},
		{name = MainUIViewChat.IconList.BAG_FULL, icon = "tips_icon_bg", openfun = "player", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.OpenBagRecyleView, self), word = "满",},
		{name = MainUIViewChat.IconList.GuildHongBao, icon = "icon_guild_hongbao2", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.OpenGuildHongBao, self), lable = "红包"},
		{name = MainUIViewChat.IconList.Congratulate, icon = "tips_icon_bg", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.OpenCongratulation, self), word = "贺",},
		{name = MainUIViewChat.IconList.AddFriend, icon = "tips_icon_bg", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.OpenAddFriendView, self), word = "副"},
		{name = MainUIViewChat.IconList.MarryBlessing, icon = "tips_icon_bg", openfun = "marryblessingview", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.OpenMarryBlessing, self), word = "婚",},
		{name = MainUIViewChat.IconList.GuildMemberFull, icon = "tips_icon_bg", openfun = "Guild",  func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.ClickMemberFull, self), word = "清",},
		{name = MainUIViewChat.IconList.MarryInvite, icon = "tips_icon_bg", openfun = "marriage", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.ClickInvite, self), word = "贴",},
		{name = MainUIViewChat.IconList.CRAZY_TREE, icon = "tips_icon_bg", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.ClickOpenCrazyTree, self), word = "摇",},
		{name = MainUIViewChat.IconList.DoubluGold, icon = "tips_icon_bg", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.ClickOpenDobuleGold, self), word = "返",},
		{name = MainUIViewChat.IconList.SingleRebate, icon = "tips_icon_bg", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.OpenSingleRebateView, self), word = "返",},
		{name = MainUIViewChat.IconList.ReturnRecharge, icon = "tips_icon_bg", openfun = "RechargeReturnReward", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.OpenReturnRechargeView, self), word = "返",},
		{name = MainUIViewChat.IconList.SmallImmortal, icon = "tips_icon_bg", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.OpenImmortalView, self), word = "仙",},
		{name = MainUIViewChat.IconList.BiaoBaiQiang, icon = "tips_icon_biaobai", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.OpenBiaoBaiView, self), word = "",},
		{name = MainUIViewChat.IconList.ActivityReward, icon = "tips_icon_bg", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.OpenActivityRewardView, self), word = "奖",},
	}
	local CROSS_CHAT_ICON_GROUP = {
		{name = MainUIViewChat.IconList.TEAM_REQ, icon = "tips_icon_bg", openfun = "scoiety", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.ShowApplyView, self), word = "组",},
		{name = MainUIViewChat.IconList.JOIN_REQ, icon = "tips_icon_bg", func = BindTool.Bind(self.IsOpenTipsIcon, self), call = BindTool.Bind(self.ShowApplyView, self), word = "队",},
	}

	self.chat_icon_group = MainuiIconGroup.New()
	self.chat_icon_group:Init(self.node_list["ChatButtons"], CHAT_ICON_GROUP, MAIN_UI_ICON_TYPE.SMALL, true)

	-- 跨服的时候用的
	self.cross_chat_icon_group = MainuiIconGroup.New()
	self.cross_chat_icon_group:Init(self.node_list["CrossChatButtonGroup"], CROSS_CHAT_ICON_GROUP, MAIN_UI_ICON_TYPE.SMALL, true)

	self.icon_list_view = MainuiIconListView.New(ViewName.MainUIIconList)

	self.cell_list = {}
	self.old_cell_height_list = {}
	self.name_cell_list = {}
	self.channel_state = 1
	self.curr_send_channel = 0
	self.state = MainUIViewChat.ViewState.Short
	self.can_remind_effect = true

	self.node_list["OnlyShowCanAtkToggle"].toggle:AddValueChangedListener(BindTool.Bind(self.OnNearRoleToggleChange, self))
	self.on_pass_day_handle = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.OnDayChange, self))

	self.switch_handle = GlobalEventSystem:Bind(ChatEventType.VOICE_SWITCH, BindTool.Bind(self.UpdateVoiceSwitch, self))
	self:UpdateVoiceSwitch()

	local near_role_list_delegate = self.node_list["NearRoleListView"].list_simple_delegate
	near_role_list_delegate.NumberOfCellsDel = BindTool.Bind(self.NearRoleNum, self)
	near_role_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshNearRoleView, self)

	self:BindGlobalEvent(SceneEventType.OBJ_ENTER_LEVEL_ROLE, BindTool.Bind(self.FlushNearRoleView, self))
	self:BindGlobalEvent(ObjectEventType.BE_SELECT, BindTool.Bind(self.OnSelectObjHead, self))
	self:BindGlobalEvent(ObjectEventType.OBJ_DELETE, BindTool.Bind(self.OnObjDeleteHead, self))
	self:BindGlobalEvent(ObjectEventType.OBJ_DEAD, BindTool.Bind(self.OnObjDeleteHead, self))
	self:BindGlobalEvent(MainUIEventType.OPEN_NEAR_VIEW, BindTool.Bind(self.OpenNearRole, self))
	self:BindGlobalEvent(MainUIEventType.NEW_CHAT_CHANGE, BindTool.Bind1(self.NewChatChange, self))

	self.data_listen = BindTool.Bind(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)

	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.OnFunOpenChange, self))

	-- 聊天list
	self.chat_list_content = self.node_list["ChatListContent"]

	-- 监听UI事件
	self.node_list["BtnChatContent"].button:AddClickListener(BindTool.Bind(self.HandleOpenChat, self))
	self.node_list["BtnArraw"].toggle:AddClickListener(BindTool.Bind(self.HandleChangeHeight, self))
	self.node_list["BtnSpeak"].event_trigger_listener:AddPointerDownListener(BindTool.Bind(self.OnClickSpeakDown, self))
	self.node_list["BtnSpeak"].event_trigger_listener:AddPointerUpListener(BindTool.Bind(self.OnClickSpeakUp, self))
	self.node_list["BtnGuildChat"].button:AddClickListener(BindTool.Bind(self.OpenGuildChat, self))
	self.node_list["BtnGuildOpen"].button:AddClickListener(BindTool.Bind(self.OpenGuildChat, self))
	self.node_list["BtnNearRole"].button:AddClickListener(BindTool.Bind(self.OpenNearRole, self))
	self.node_list["BtnBgClose"].button:AddClickListener(BindTool.Bind(self.CloseNearRoleView, self))
	self.node_list["BtnQuickChat"].button:AddClickListener(BindTool.Bind(self.ClickQuickChat, self))
	self.node_list["BtnLaBa"].button:AddClickListener(BindTool.Bind(self.ClickSpeaker, self))
	self.node_list["AllActivity"].button:AddClickListener(BindTool.Bind(self.AllActivityViewClick, self))
	self.node_list["ActivityName"].button:AddClickListener(BindTool.Bind(self.ClickActivityView, self))

	self.root_node.animator:ListenEvent("ToShort", BindTool.Bind(self.ToShortFinish, self))
	self.root_node.animator:ListenEvent("ToLength", BindTool.Bind(self.ToLengthFinish, self))

	self.root_node.animator:ListenEvent("StartToLength", BindTool.Bind(self.StartToLength, self))
	self.root_node.animator:ListenEvent("StartToShort", BindTool.Bind(self.StartToShort, self))

	self:BindGlobalEvent(MainUIEventType.CHAT_CHANGE, BindTool.Bind1(self.FulshChatView, self))

	--监听右下角收缩按钮事件
	self:BindGlobalEvent(MainUIEventType.FIGHT_STATE_BUTTON, BindTool.Bind1(self.CheckFlushChatView, self))

	--监听左下角收缩按钮
	self:BindGlobalEvent(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON, BindTool.Bind1(self.CheckFlushDiscoutIconShake, self))

	self.pop_chat_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.PopChatFinish, self), 2)

	self.item_data_change_callback = BindTool.Bind(self.ItemDataChangeCallBack, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_change_callback)

	self.delay_refresh_chat_view = BindTool.Bind(self.DelayRefreshChatView, self)

	self:FlushActivityPre()

	Runner.Instance:AddRunObj(self, 8)
end

-- 根据渠道开启语音聊天
function MainUIViewChat:UpdateVoiceSwitch()
	if self.node_list["BtnSpeak"] then
		self.node_list["BtnSpeak"]:SetActive(not SHIELD_VOICE)
	end
end

function MainUIViewChat:__delete()
	Runner.Instance:RemoveRunObj(self)

	if self.icon_list_view ~= nil then
		self.icon_list_view:DeleteMe()
		self.icon_list_view = nil
	end

	if nil ~= self.chat_icon_group then
		self.chat_icon_group:DeleteMe()
		self.chat_icon_group = nil
	end
	if nil ~= self.cross_chat_icon_group then
		self.cross_chat_icon_group:DeleteMe()
		self.cross_chat_icon_group = nil
	end

	if self.item_data_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_change_callback)
		self.item_data_change_callback = nil
	end

	if nil ~= self.delay_refresh_chat_view_timer then
		GlobalTimerQuest:CancelQuest(self.delay_refresh_chat_view_timer)
		self.delay_refresh_chat_view_timer = nil
	end

	if self.act_preview_time_time_quest then
		GlobalTimerQuest:CancelQuest(self.act_preview_time_time_quest)
		self.act_preview_time_time_quest = nil
	end

	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.old_cell_height_list = {}

	if self.on_pass_day_handle ~= nil then
		GlobalEventSystem:UnBind(self.on_pass_day_handle)
		self.on_pass_day_handle = nil
	end

	if self.switch_handle ~= nil then
		GlobalEventSystem:UnBind(self.switch_handle)
		self.switch_handle = nil
	end

	if self.open_trigger_handle then
		GlobalEventSystem:UnBind(self.open_trigger_handle)
		self.open_trigger_handle = nil
	end

	if self.pop_chat_quest then
		GlobalTimerQuest:CancelQuest(self.pop_chat_quest)
	end
	
	for _, v in pairs(self.name_cell_list) do
		v:DeleteMe()
	end
	self.name_cell_list = {}

	PlayerData.Instance:UnlistenerAttrChange(self.data_listen)

	self:ClearChatCDTimer()

	if self.delay_guild_shake then
		GlobalTimerQuest:CancelQuest(self.delay_guild_shake)
		self.delay_guild_shake = nil
	end

	if self.strengthen_remind_timer_quest then
		GlobalTimerQuest:CancelQuest(self.strengthen_remind_timer_quest)
		self.strengthen_remind_timer_quest = nil
	end

	if self.discount_delay_timer then
		GlobalTimerQuest:CancelQuest(self.discount_delay_timer)
		self.discount_delay_timer = nil
	end
end

function MainUIViewChat:FlushIconGroup()
	if IS_ON_CROSSSERVER then
		self.cross_chat_icon_group:FlushIconGroup()
	else
		self.chat_icon_group:FlushIconGroup()
	end
end

function MainUIViewChat:GetChatButton(name)
	if IS_ON_CROSSSERVER and name ~= MainUIViewChat.IconList.ActivityReward then
		return self.cross_chat_icon_group:GetIconByName(name)
	end

	return self.chat_icon_group:GetIconByName(name)
end

function MainUIViewChat:OnFunOpenChange(openfun)
	if self.fun_open_delay_flush and self.fun_open_delay_flush[openfun] then
		local key = self.fun_open_delay_flush[openfun].key
		local is_active = self.fun_open_delay_flush[openfun].is_active
		local param_list = self.fun_open_delay_flush[openfun].param_list

		self:FlushTipsIcon(key, is_active, param_list)
		self.fun_open_delay_flush[openfun] = nil
	end
end

-- 统一刷新方法!!! 逻辑都写这里
function MainUIViewChat:FlushTipsIcon(key, is_active, param_list)
	local icon = self:GetChatButton(key)
	if nil == icon then return end

	local icon_cfg = icon:GetConfig()
	if icon_cfg and icon_cfg.openfun then
		self.fun_open_delay_flush = self.fun_open_delay_flush or {}
		if not OpenFunData.Instance:CheckIsHide(icon_cfg.openfun) then
			self.fun_open_delay_flush[icon_cfg.openfun] = {key = key, is_active = is_active, param_list = param_list}
			return
		else
			self.fun_open_delay_flush[icon_cfg.openfun] = nil
		end
	end
	icon:SetActive(is_active and self:IsOpenTipsIcon(icon_name))

	if key == MainUIViewChat.IconList.ExpRefine then
		if RemindManager.Instance:RemindToday(RemindName.ExpRefineBubble) then
			icon:ShowEffect(false)
			icon:SetPromptShow(false)
			return
		end
		local is_show_eff = ExpRefineData.Instance:GetIsShowEff()
		icon:ShowEffect(is_show_eff)
		local is_show_bubble = ExpRefineData.Instance:GetIsShowBubble()
		icon:SetPromptShow(is_show_bubble)
		local exp_refine_cfg = ExpRefineData.Instance:GetRAExpRefineCfgBySeq(param_list or 0)
		if exp_refine_cfg then
			local main_vo = GameVoManager.Instance:GetMainRoleVo()
			local role_exp = exp_refine_cfg.reward_exp
			local level = PlayerData.Instance:GetRoleLevelByExp(role_exp) or 0
			local up_level = level - main_vo.level
			if up_level >= 3 then
				icon:SetPromptTxt(string.format(Language.ExpRefine.BubbleTxt2, up_level))
			else
				icon:SetPromptTxt(string.format(Language.ExpRefine.BubbleTxt, CommonDataManager.ConverExp2(exp_refine_cfg.reward_exp)))
			end
		end
	elseif key == MainUIViewChat.IconList.SmallHelper then
		local is_eff = SmallHelperData.Instance:GetRemind() > 0
		if RemindManager.Instance:RemindToday(RemindName.SmallHelper) then
			icon:ShowEffect(false)
		else
			icon:ShowEffect(is_eff)
		end
		
		icon:SetActive(is_eff)
	elseif key == MainUIViewChat.IconList.WEEDING_GET_INVITE then
		local is_show_eff = MarriageData.Instance:GetIsShowEff()
		icon:ShowEffect(is_show_eff)
		local is_show_bubble = MarriageData.Instance:GetIsShowBubble()
		icon:SetPromptShow(is_show_bubble)

		if HUNYAN_STATUS.XUNYOU == MarriageData.Instance:GetActiveState() then 
			local hunyan_info = MarriageData.Instance:GetHunYanCurAllInfo()
			if hunyan_info.role_name and hunyan_info.lover_role_name and "" ~= hunyan_info.role_name and  "" ~= hunyan_info.lover_role_name then
				icon:SetPromptTxt(string.format(Language.Marriage.MarryXunYou2, hunyan_info.role_name, hunyan_info.lover_role_name))
			else
				icon:SetPromptTxt(Language.Marriage.MarryXunYou)
			end 
		elseif HUNYAN_STATUS.OPEN == MarriageData.Instance:GetActiveState() then 
			local hunyan_info = MarriageData.Instance:GetHunYanCurAllInfo()
			if hunyan_info.role_name and hunyan_info.lover_role_name and "" ~= hunyan_info.role_name and  "" ~= hunyan_info.lover_role_name then
				icon:SetPromptTxt(string.format(Language.Marriage.MarryHunYan2, hunyan_info.role_name, hunyan_info.lover_role_name))
			else
				icon:SetPromptTxt(Language.Marriage.MarryHunYan)
			end 
		end
		
	elseif key == MainUIViewChat.IconList.JuBaoPen then
		icon:ShowEffect(JuBaoPenData.Instance:IsShowRedPoint() > 0)
	elseif key == MainUIViewChat.IconList.Strength then
		self:FlushStrengthEff()
	elseif key == MainUIViewChat.IconList.TodayTheme then
		icon:ShowEffect(TipsTodayThemeData.Instance:IsShowTodayThemeEff())
	elseif key == MainUIViewChat.IconList.DisCount then
		local num = DisCountData.Instance:SetMainViewRedPoint()
		icon:SetIconShake(is_active and num > 0 and MainUIData.GetIsShowLevelRed(RemindName.DisCount))	
	end
end

function MainUIViewChat:FlushDiscoutIconShake()
	local icon = self:GetChatButton(MainUIViewChat.IconList.DisCount)
	if icon then
		local num = DisCountData.Instance:SetMainViewRedPoint()
		icon:SetIconShake(num > 0 and MainUIData.GetIsShowLevelRed(RemindName.DisCount))	
	end
end

function MainUIViewChat:OpenSmallHelperView()
	SmallHelperData.Instance:ResetAllData()
	ViewManager.Instance:Open(ViewName.SmallHelper)
end

-- 统一检查方法!!!
function MainUIViewChat:IsOpenTipsIcon(icon_name)
	if MainUIViewChat.IconList.ReturnRecharge == icon_name then
		local is_act_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHONGZHI_CRAZY_REBATE)
		local level_open = self:GetActivityIsOpenByLevel(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHONGZHI_CRAZY_REBATE)
		return is_act_open and level_open

	elseif MainUIViewChat.IconList.JuBaoPen == icon_name then
		return JuBaoPenData.Instance:CheckIsShow()
		--[[
	elseif MainUIViewChat.IconList.HONGBAO == icon_name then
		for k,v in pairs(HongBaoData.Instance:GetCurHongBaoIdList()) do
			if v.id and v.id > 0 then
				return true
			end
		end
	elseif MainUIViewChat.IconList.FRIEND_REC == icon_name then
		return ScoietyData.Instance:GetFriendRectState()
	elseif MainUIViewChat.IconList.MAIL_REC == icon_name then
		return ScoietyData.Instance:GetMailState()
	elseif MainUIViewChat.IconList.WEEDING_GET_INVITE == icon_name then
		local invite_data = MarriageData.Instance:GetGetInviteData()
		return nil ~= invite_data and next(invite_data)
	elseif MainUIViewChat.IconList.LOVE_CONTENT == icon_name then
		local flag = KaifuActivityData.Instance:GetDailyLoveFlag()
		-- 0表示已经首充过（不知道为什么服务器就是这么定的）
		local has_first_recharge = flag == 0
		local is_act_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_DAILY_LOVE)
		local is_show = not has_first_recharge and is_act_open

		local level_open = self:GetActivityIsOpenByLevel(ACTIVITY_TYPE.RAND_DAILY_LOVE)
		return is_show and level_open
	elseif MainUIViewChat.IconList.ExpRefine == icon_name then
		ExpRefineData.Instance:GetExpRefineIsOpen()
	elseif MainUIViewChat.IconList.DisCount then
		DisCountData.Instance:GetActiveState()

		]]
	end
	return true
end

--以下是点击回调方法
function MainUIViewChat:OpenStrength()
	local list = MainUIData.Instance:GetStrengthButtonList()
	local btn = self:GetChatButton(MainUIViewChat.IconList.Strength)
	if btn then
		self.can_remind_effect = false
		self:FlushStrengthEff()

		self.icon_list_view:SetClickObj(btn.root_node, 2)
		self.icon_list_view:SetData(list)
		
		if self.strengthen_remind_timer_quest then
			GlobalTimerQuest:CancelQuest(self.strengthen_remind_timer_quest)
			self.strengthen_remind_timer_quest = nil
		end
		self.strengthen_remind_timer_quest = GlobalTimerQuest:AddDelayTimer(function()
			self.can_remind_effect = true
			self:FlushStrengthEff()
		end, 1800)
	end
end

function MainUIViewChat:CloseIconListView()
	if self.icon_list_view:IsOpen() then
		self.icon_list_view:Close()
	end
end

--监听变强晃动
function MainUIViewChat:FlushStrengthEff()
	local btn = self:GetChatButton(MainUIViewChat.IconList.Strength)
	if btn then
		local num = RemindManager.Instance:GetRemind(RemindName.BeStrength)
		btn:ShowEffect(self.can_remind_effect and num > 0)
	end
end

function MainUIViewChat:ClickInvite()
	ViewManager.Instance:Open(ViewName.WeddingInviteView, 2)
end

function MainUIViewChat:ClickOpenCrazyTree()
	ViewManager.Instance:Open(ViewName.CrazyMoneyTreeView)
end

function MainUIViewChat:ClickOpenDobuleGold()
	MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.DoubluGold, false)
	ViewManager.Instance:Open(ViewName.DoubleGoldView)
end

function MainUIViewChat:OpenTreasureBowlView()
	ViewManager.Instance:Open(ViewName.JuBaoPen)
end

--新增聊天消息
function MainUIViewChat:NewChatChange(msg_info)
	local channel_type = msg_info.channel_type
	if channel_type == CHANNEL_TYPE.TEAM or channel_type == CHANNEL_TYPE.GUILD or channel_type == CHANNEL_TYPE.WORLD_QUESTION or channel_type == CHANNEL_TYPE.GUILD_QUESTION then
		if channel_type == CHANNEL_TYPE.TEAM then
			self:FulshChatView()
		end
		self.pop_channel_type = channel_type
	else
		self:FulshChatView()
	end
end

function MainUIViewChat:PopChatFinish()
	if ChatData.Instance:GetIsPopChat() then
		ChatData.Instance:SetIsPopChat(false)
		self:ShowGuildPopChat(true)
	else
		self:ShowGuildPopChat(false)
	end
end

function MainUIViewChat:ShowGuildPopChat(is_show)
	if is_show then
		if self.pop_chat_quest then
			GlobalTimerQuest:CancelQuest(self.pop_chat_quest)
		end
		self.pop_chat_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.PopChatFinish, self), 2)
	end
	local is_in_shake = GuildData.Instance:GetGuildChatShakeState()
	local is_show2 = ChatData.Instance:HasUnreadGuildMsg()
	self.node_list["PopChatList"]:SetActive(is_show and is_show2 and not is_in_shake)
end

function MainUIViewChat:ShowGuildChatRedPt(is_show)
	self.node_list["ImgRedPoint"]:SetActive(is_show)
	local num = GuildChatData.Instance:GetGuildChatUnReadNum()
	if num > 99 then
		num = "99"
	elseif num <= 0 then
		num = ""
	end
	self.node_list["UnReadNum"].text.text = num
end

function MainUIViewChat:HandleChangeHeight()
	local bool = self.root_node.animator:GetBool("changeheight")
	self.root_node.animator:SetBool("changeheight", not bool)
end

--开始把聊天框变长
function MainUIViewChat:StartToLength()
	GlobalEventSystem:Fire(MainUIEventType.CHAT_VIEW_HIGHT_CHANGE, "to_length")
end

--开始把聊天框变短
function MainUIViewChat:StartToShort()
	GlobalEventSystem:Fire(MainUIEventType.CHAT_VIEW_HIGHT_CHANGE, "to_short")
end

function MainUIViewChat:ToShortFinish(param)
	if param == "1" then
		if self.state ~= MainUIViewChat.ViewState.Short then
			self.state = MainUIViewChat.ViewState.Short
			self:FulshChatView()
		end
	end
end

function MainUIViewChat:ToLengthFinish(param)
	if param == "1" then
		if self.state ~= MainUIViewChat.ViewState.Length then
			self.state = MainUIViewChat.ViewState.Length
			self:FulshChatView()
		end
	end
end

function MainUIViewChat:CheckFlushDiscoutIconShake(state)
	if state then
		if self.discount_delay_timer then
			GlobalTimerQuest:CancelQuest(self.discount_delay_timer)
			self.discount_delay_timer = nil
		end		
		self.discount_delay_timer = GlobalTimerQuest:AddDelayTimer(function()
			self:FlushDiscoutIconShake()
		end, 1)
	end	
end

function MainUIViewChat:CheckFlushChatView(state)
	if not state then
		GlobalTimerQuest:AddDelayTimer(function()
			self:FulshChatView()
		end, 0)
		if self.discount_delay_timer then
			GlobalTimerQuest:CancelQuest(self.discount_delay_timer)
			self.discount_delay_timer = nil
		end		
		self.discount_delay_timer = GlobalTimerQuest:AddDelayTimer(function()
			self:FlushDiscoutIconShake()
		end, 1)
	end
end

function MainUIViewChat:HandleOpenChat()
	ViewManager.Instance:Open(ViewName.Chat)
end

function MainUIViewChat:HandleOpenTradeReqTips()
	local role_info = TradeData.Instance:GetSendTradeRoleInfo()
	local content = string.format(Language.Trade.TradeTipContent, role_info.req_name)
	local func = function ()
		TradeCtrl.Instance:SendTradeStateReq(1, role_info.req_uid)
	end
	local no_func = function ()
		SysMsgCtrl.Instance:ErrorRemind(Language.Trade.NoTrade)
		TradeCtrl.Instance:SendTradeStateReq(0, role_info.req_uid)
	end
	TipsCtrl.Instance:ShowCommonTip(func, nil, content, nil, no_func, false)

	self:FlushTipsIcon(MainUIViewChat.IconList.TRADE_REQ, false)
end

function MainUIViewChat:HandleOpenMail()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return
	end
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_mail)
end

function MainUIViewChat:OpenGuildApply()
	ViewManager.Instance:Open(ViewName.GuildApply)
end

function MainUIViewChat:OpenHongBao()
	HongBaoCtrl.Instance:RecHongBao(HongBaoData.Instance:GetCurHongBaoIdList()[1].id)
end

function MainUIViewChat:OpenGuildChat()
	-- 关闭仙盟答题提示框
	if self.node_list and self.node_list["GuildOpenTips"] then
		self.node_list["GuildOpenTips"]:SetActive(false)
	end

	local privateobj_list = ChatData.Instance:GetPrivateObjList()
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	local have_team = ScoietyData.Instance:GetTeamState()

	--没公会没队伍也没有私聊对象
	if guild_id <= 0 and not have_team and #privateobj_list <= 0 then
		ViewManager.Instance:Open(ViewName.Guild,  TabIndex.guild_request)
		return
	end
	ViewManager.Instance:Open(ViewName.ChatGuild)
end

function MainUIViewChat:OpenOfflineView()
	ViewManager.Instance:Open(ViewName.OffLineExp)
end

--爱情契约
function MainUIViewChat:ClickLoveContent()
	local function ok_callback()
		ViewManager.Instance:Open(ViewName.Marriage, TabIndex.marriage_love_contract)
	end
	local can_receive_day_num = MarriageData.Instance:GetQingyuanLoveContractInfo().can_receive_day_num + 1		-- 服务器天数从0开始 所以在这客户端显示要+1
	local des = string.format(Language.Marriage.ContentMianTips, can_receive_day_num)
	local yes_des = Language.Common.LingQuJiangLi
	local canel_des = Language.Common.AfterLater
	TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback, nil, nil, yes_des, canel_des)
end

--公会女神祝福
function MainUIViewChat:ClickGuildGoddess()
	local function ok_callback()
		GuildBonfireCtrl.SendGuildBonfireGotoReq()
	end
	local des = Language.Guild.GoToGuildBonfire
	TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback)
end

function MainUIViewChat:OpenBagRecyleView()
	ViewManager.Instance:Open(ViewName.PackageView)
end

--打开特惠豪礼界面
function MainUIViewChat:OpenDiscountView()
	local have_new_discount = DisCountData.Instance:GetHaveNewDiscount()
	if have_new_discount then
		ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {"all"})
	else
		ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {1})
	end
end

function MainUIViewChat:OpenExpRefineView()
	ViewManager.Instance:Open(ViewName.ExpRefine)
end

function MainUIViewChat:OpenCongratulation()
	ViewManager.Instance:Open(ViewName.CongratulationView)
end

function MainUIViewChat:OpenAddFriendView()
	ViewManager.Instance:Open(ViewName.FBAddFriendView)
end

function MainUIViewChat:OpenGuildHongBao()
	ViewManager.Instance:Open(ViewName.GuildRedPacket)
end

function MainUIViewChat:OpenDailyLoveView()
	ViewManager.Instance:Open(ViewName.KaifuActivityView, 28)
end

function MainUIViewChat:OpenSingleRebateView()
	ViewManager.Instance:Open(ViewName.SingleRebateView)
end

function MainUIViewChat:GetActivityIsOpenByLevel(activity_type)
	local act_info = ActivityData.Instance:GetActivityConfig(activity_type)
	if not act_info then return false end

	local level = GameVoManager.Instance:GetMainRoleVo().level
	return level >= act_info.min_level
end

function MainUIViewChat:OpenReturnRechargeView()
	ViewManager.Instance:Open(ViewName.RechargeReturnReward)
end

function MainUIViewChat:OpenImmortalView()
	ViewManager.Instance:Open(ViewName.ImmortalView)
end

function MainUIViewChat:OpenBiaoBaiView()
	BiaoBaiQiangCtrl.Instance:OpenMySelfBiaoBai()
end

function MainUIViewChat:OpenActivityRewardView()
	TipsCtrl.Instance:ShowActivityRewardView()
end

function MainUIViewChat:OpenSingleRechargeView()
	ViewManager.Instance:Open(ViewName.SingleRechargeView)
end

function MainUIViewChat:OpenTodayThemeTipsView()
	ViewManager.Instance:Open(ViewName.TodayThemeView)
end

function MainUIViewChat:OpenGongGaoView()    --打开公告面板
	ViewManager.Instance:Open(ViewName.TipsGongGaoView)
end

function MainUIViewChat:OpenChengZhangJijing()
	ViewManager.Instance:Open(ViewName.KaifuActivityView, 65)
	KaifuActivityData.Instance:ChengZhangJiJingRemind()
	MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.ChengZhangJiJing, false)
	InvestData.Instance:SetShowTouZiSign(1)
end

function MainUIViewChat:OpenBuyExpView()
	ViewManager.Instance:Open(ViewName.BuyExpView)
end

function MainUIViewChat:ShowApplyView(icon_name)
	local open_type = nil
	if icon_name == MainUIViewChat.IconList.FRIEND_REC then
		open_type = APPLY_OPEN_TYPE.FRIEND
	elseif icon_name == MainUIViewChat.IconList.TEAM_REQ then
		open_type = APPLY_OPEN_TYPE.TEAM
	elseif icon_name == MainUIViewChat.IconList.JOIN_REQ then
		open_type = APPLY_OPEN_TYPE.JOIN
	else
		return
	end
	ScoietyCtrl.Instance:ShowApplyView(open_type)
end

function MainUIViewChat:HandleOpenWeedingGetInvite()
	MarriageCtrl.Instance:SendMarryOpera(HUNYAN_OPERA_TYPE.HUNYAN_GET_WEDDING_INFO)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo and main_role_vo.level >= WEDDING_ACTIVITY_LEVEL then
		MarriageCtrl.Instance:OpenDemandView()
	end
end

function MainUIViewChat:GetGuildInvite()
	local data = GuildData.Instance:GetInviteGuild()
	local guild_id = data.guild_id
	local invite_name = data.invite_name
	local guild_name = data.guild_name
	local invite_uid = data.invite_uid
	local describe = string.format(Language.Guild.InviteJionGuild, ToColorStr(invite_name, TEXT_COLOR.GREEN), ToColorStr(guild_name, TEXT_COLOR.YELLOW))
	local ok_des = Language.Common.Agree
	local canel_des = Language.Common.UnWilling
	local yes_func = function()
		GuildCtrl.Instance:OnInviteGuildAck(guild_id, invite_uid, 0)
		self:FlushTipsIcon(MainUIViewChat.IconList.GUILD_YAO, false)
	end
	local no_func = function()
		GuildCtrl.Instance:OnInviteGuildAck(guild_id, invite_uid, 1)
		self:FlushTipsIcon(MainUIViewChat.IconList.GUILD_YAO, false)
	end
	TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func, nil, nil, ok_des, canel_des, nil, nil, nil, no_func)
end

function MainUIViewChat:FulshChatView()
	if nil ~= self.delay_refresh_chat_view_timer then
		return
	end

	self.delay_refresh_chat_view_timer = GlobalTimerQuest:AddDelayTimer(self.delay_refresh_chat_view, 0)
end

function MainUIViewChat:DelayRefreshChatView()
	self.delay_refresh_chat_view_timer = nil
	local channel_list = ChatData.Instance:GetChannel(CHANNEL_TYPE.MAINUI)
	local msg_list = channel_list.msg_list or {}

	self.cell_act_count = 0
	self.cell_list_dirty = true

	local max_pos_y = 0
	if self.state == MainUIViewChat.ViewState.Short then
		max_pos_y = 100
	else
		max_pos_y = 180
	end

	self.list_height = 0
	for i = #msg_list, 1, -1 do
		self.cell_act_count = self.cell_act_count + 1
		local chat_cell = self.cell_list[self.cell_act_count]
		if nil == chat_cell then
			local sync_loader = AllocSyncLoader(self, "chat_cell" .. self.cell_act_count)
			sync_loader:Load("uis/views/mainui_prefab", "ChatInfo", function(obj)
				chat_cell = MainUIChatCell.New(obj)
				self.cell_list[self.cell_act_count] = chat_cell
			end)
		end

		if nil ~= chat_cell then
			chat_cell:SetData(msg_list[i])
			chat_cell:SetActive(true)
			chat_cell:GetRootNode().transform:SetParent(self.chat_list_content.transform, false)
			self.list_height = self.list_height + chat_cell:GetContentHeight(true) + 5
		end
		
		if self.list_height >= max_pos_y then
			break
		end
	end

	for i = self.cell_act_count + 1, #self.cell_list do
		self.cell_list[i]:SetActive(false)
	end

	self:RefreshLayout()
end

function MainUIViewChat:Update(now_time, elapse_time)
	self:RefreshLayout()
end

function MainUIViewChat:RefreshLayout()
	local pos_y = 0
	local max_pos_y = 0
	if self.state == MainUIViewChat.ViewState.Short then
		max_pos_y = 100
	else
		max_pos_y = 180
	end

	local need_layout = self.cell_list_dirty
	self.cell_list_dirty = false

	for i,v in ipairs(self.cell_list) do
		local now_height = v:GetContentHeight(false)
		if now_height ~= self.old_cell_height_list[i] then
			need_layout = true
			self.old_cell_height_list[i] = now_height
		end
	end

	if need_layout then
		local is_down_to_up = self.list_height >= max_pos_y
		if is_down_to_up then  -- 从下往上
			for i=1, self.cell_act_count do
				pos_y = pos_y + self.old_cell_height_list[i] + 5
				self.cell_list[i]:GetRootNode().transform.anchoredPosition = Vector2(0, pos_y)
			end
		else  -- 从上往下
			for i = self.cell_act_count, 1, -1 do
				self.cell_list[i]:GetRootNode().transform.anchoredPosition = Vector2(0, max_pos_y - pos_y)
				pos_y = pos_y + self.old_cell_height_list[i] + 5
			end
		end

		self.chat_list_content.rect.sizeDelta = Vector2(406, pos_y)
	end
end

function MainUIViewChat:FlushPopChatView(msg_info)
	if nil == msg_info then
		return
	end

	self:SetContent(self.node_list["PopChatList"].rich_text, msg_info)
end

function MainUIViewChat:SetContent(rich_text,last_msg)
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if last_msg.from_uid and last_msg.from_uid == role_id then
		return
	end
	local color = ""
	if last_msg.tuhaojin_color > 0 then
		color = COLOR.GOLD
	else
		color = COLOR.WHITE
	end
	local content = last_msg.content
	if last_msg.content_type == CHAT_CONTENT_TYPE.AUDIO then
		content = string.format(Language.Chat.Audio, last_msg.username or "")
	end

	if last_msg.from_uid > 0 then
		local name_str = string.format("{wordcolor;ffff00;%s}", last_msg.username)
		content = name_str .. ": " .. content
	end

	local msg = self:GetCutPopChatStr(content)
	RichTextUtil.ParseRichText(rich_text, msg, nil, color)
end

function MainUIViewChat:GetCutPopChatStr(content)
	-- 字符串分段
	local i, j = 0, 0
	local element_list = {}
	local last_pos = 1
	for loop_count = 1, 100 do
		i, j = string.find(content, "({.-})", j + 1)-- 匹配规则{face;20} {item;26000}
		if nil == i or nil == j then
			if last_pos <= #content then
				table.insert(element_list, {0, string.sub(content, last_pos, -1)})
			end
			break
		else
			if 1 ~= i and last_pos ~= i then
				table.insert(element_list, {0, string.sub(content, last_pos, i - 1)})
			end
			table.insert(element_list, {1, string.sub(content, i, j)})
			last_pos = j + 1
		end
	end

	-- 统计表情、字符等数量
	local all_length = 0
	local rest_length = 0
	local msg = ""
	local max_length = 16
	for i = 1, #element_list do
		if element_list[i][1] == 1 then
			if string.find(element_list[i][2], "face") ~= nil then
				-- 表情按2个字符算
				all_length = all_length + 2
				if all_length > max_length then
					msg = msg.."..."
					return msg
				else
					msg = msg..ChatData.Instance:SubStringUTF8(element_list[i][2],1,-1)
				end
			else
				-- 坐标等按8个字符算
				all_length = all_length + 8
				if all_length > max_length then
					msg = msg.."..."
					return msg
				else
					msg = msg..ChatData.Instance:SubStringUTF8(element_list[i][2],1,-1)
				end
			end
		else
			rest_length = max_length - all_length
			all_length = all_length + string.utf8len(element_list[i][2])
			if all_length > max_length then
				msg = msg..ChatData.Instance:SubStringUTF8(element_list[i][2],1,rest_length)
				msg = msg.."..."
				return msg
			else
				msg = msg..ChatData.Instance:SubStringUTF8(element_list[i][2],1,-1)
			end
		end
	end

	return msg
end

function MainUIViewChat:OnClickSpeakDown()
	if not OpenFunData.Instance:CheckIsHide("Chat") then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.ChatLevelOpen)
		return
	end
	local function start_voice()
		if self.channel_state > 3 then
			self.channel_state = 1
		end
		local curr_send_channel = MainUIViewChat.ChannelType[self.channel_state]
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		if curr_send_channel == CHANNEL_TYPE.WORLD then
			if not ChatData.Instance:IsCanChat(CHAT_OPENLEVEL_LIMIT_TYPE.WORLD) then
				return
			end
			if not ChatData.Instance:GetChannelCdIsEnd(curr_send_channel) then
				local time = ChatData.Instance:GetChannelCdEndTime(curr_send_channel) - Status.NowTime
				SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Chat.CanNotChat, math.ceil(time)))
				return
			end

			--设置世界聊天冷却时间
			ChatData.Instance:SetChannelCdEndTime(curr_send_channel)
		elseif curr_send_channel == CHANNEL_TYPE.TEAM then
			--是否组队
			if not ScoietyData.Instance:GetTeamState() then
				SysMsgCtrl.Instance:ErrorRemind(Language.Society.CreateTeam)
				return
			end
		elseif curr_send_channel == CHANNEL_TYPE.GUILD then
			if main_vo.guild_id <= 0 then
				SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NotEnterGuild)
				return
			end
		else
			print_error("HandleChangeChannel with unknow index:", curr_send_channel)
			return
		end
		AutoVoiceCtrl.Instance:ShowVoiceView(curr_send_channel)
	end
	GlobalTimerQuest:AddDelayTimer(start_voice, 0)
end

function MainUIViewChat:OpenGiftRecordView()
	ScoietyCtrl.Instance:ShowFriendRecordView()
end

function MainUIViewChat:OnClickSpeakUp()
	if AutoVoiceCtrl.Instance.view:IsOpen() then
		AutoVoiceCtrl.Instance.view:Close()
	end
end

-- 附近玩家面板
function MainUIViewChat:OpenNearRole()
	self.node_list["NodeNearRoleView"]:SetActive(true)
	self.near_role_toggle_is_on = true
	self.node_list["OnlyShowCanAtkToggle"].toggle.isOn = true
	if self.node_list["NearRoleListView"] and self.node_list["NearRoleListView"].scroller.isActiveAndEnabled then
		self.node_list["NearRoleListView"].scroller:ReloadData(0)
	end
end

-- 取消
function MainUIViewChat:OnObjDeleteHead(obj)
	if SceneObj.select_obj == nil or SceneObj.select_obj == obj then
		self:FlushNearRoleView()
	end
end

function MainUIViewChat:OnSelectObjHead(target_obj, select_type)
	self:FlushNearRoleView()
end
function MainUIViewChat:FlushNearRoleView()
	if self.node_list["NearRoleListView"] and self.node_list["NearRoleListView"].scroller.isActiveAndEnabled then
		self.node_list["NearRoleListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function MainUIViewChat:CloseNearRoleView()
	self.node_list["NodeNearRoleView"]:SetActive(false)
end

function MainUIViewChat:OnNearRoleToggleChange(is_on)
	self.near_role_toggle_is_on = is_on
	if self.node_list["NearRoleListView"] and self.node_list["NearRoleListView"].scroller.isActiveAndEnabled then
		self.node_list["NearRoleListView"].scroller:ReloadData(0)
	end
end

function MainUIViewChat:NearRoleNum()
	return #self:GetCanAtkRole()
end

function MainUIViewChat:GetCanAtkRole()
	local list = {}
	for k, v in pairs(Scene.Instance:GetRoleList()) do
		if not v:IsMainRole() then
			if not self.near_role_toggle_is_on then
				table.insert(list, v)
			elseif self.near_role_toggle_is_on and Scene.Instance:IsEnemy(v) then
				table.insert(list, v)
			end
		end
	end
	return list
end

function MainUIViewChat:RefreshNearRoleView(cell, data_index)
	local name_cell = self.name_cell_list[cell]
	if not name_cell then
		name_cell = NearRoleNameCell.New(cell.gameObject)
		self.name_cell_list[cell] = name_cell
	end
	local list = self:GetCanAtkRole()
	name_cell:ListenClick(BindTool.Bind(self.OnClickRoleName, self, list[data_index + 1]))
	name_cell:SetData(list[data_index + 1])
end

function MainUIViewChat:OnClickRoleName(obj)
	if not obj then return end
	obj:OnClicked()
end

function MainUIViewChat:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "level" then

	end
end

function MainUIViewChat:ItemDataChangeCallBack()
	local empty_num = ItemData.Instance:GetEmptyNum()
	MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.BAG_FULL, 0 == empty_num)
end

function MainUIViewChat:SetGuildOpenTipsActive(flag)	
	if self.node_list and self.node_list["GuildOpenTips"] and self.node_list["GuildChatBtnEffect"] and self.node_list["GuildOpenTag"] then
		self.node_list["GuildOpenTips"]:SetActive(flag)
		self.node_list["GuildChatBtnEffect"]:SetActive(flag)
		self.node_list["GuildOpenTag"]:SetActive(flag)
	end
	self:SetGuildShake(flag)
end

function MainUIViewChat:SetGuildShake(flag)
	if self.node_list["BtnGuildChat"] and self.node_list["BtnGuildChat"].animator and self.node_list["BtnGuildChat"].animator.isActiveAndEnabled then
		if flag == true then
			self.node_list["BtnGuildChat"].animator:SetBool("shake", true)
			if nil ~= self.delay_guild_shake then
				GlobalTimerQuest:CancelQuest(self.delay_guild_shake)
				self.delay_guild_shake = nil
			end
			self.delay_guild_shake = GlobalTimerQuest:AddDelayTimer(function()
				self.node_list["BtnGuildChat"].animator:SetBool("shake", false)
			end, 2)				
		else
			self.node_list["BtnGuildChat"].animator:SetBool("shake", false)
		end
	end
end

function MainUIViewChat:OpenMarryBlessing()
	ViewManager.Instance:Open(ViewName.MarryBlessingView)
	MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.MarryBlessing, false)
end

function MainUIViewChat:ClickMemberFull()
	GuildCtrl.Instance:CleanFullMember()
	MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.GuildMemberFull, false)
end

function MainUIViewChat:ClickQuickChat()
	if not ChatData.Instance:GetChannelCdIsEnd(CHANNEL_TYPE.WORLD) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.WorldChatCD)
		return
	end
	local function callback(str)
		local level = GameVoManager.Instance:GetMainRoleVo().level
		--等级限制
		if not ChatData.Instance:IsCanChat(CHAT_OPENLEVEL_LIMIT_TYPE.WORLD) then
			return
		end
		--设置世界聊天冷却时间
		ChatData.Instance:SetChannelCdEndTime(CHANNEL_TYPE.WORLD)
		ChatData.Instance:AddToHistoryMsgList(str)
		ChatCtrl.SendChannelChat(CHANNEL_TYPE.WORLD, str, CHAT_CONTENT_TYPE.TEXT)
		self:UpdateChatCD()
	end
	ChatCtrl.Instance:OpenQuickChatView(QUICK_CHAT_TYPE.NORMAL, callback)
end

function MainUIViewChat:UpdateChatCD()
	self:ClearChatCDTimer()
	local function timer_func(elapse_time, total_time)
		if elapse_time >= total_time then
			self:ClearChatCDTimer()
			self.node_list["TxtChatCD"].text.text = ""
			return
		end
		self.node_list["TxtChatCD"].text.text = math.ceil(total_time - elapse_time)
	end
	local time = ChatData.Instance:GetChannelCdEndTime(CHANNEL_TYPE.WORLD) - Status.NowTime
	time = math.ceil(time)
	self.node_list["TxtChatCD"].text.text = time
	self.chat_cd_count_down = CountDown.Instance:AddCountDown(time, 1, timer_func)
end

function MainUIViewChat:ClearChatCDTimer()
	if self.chat_cd_count_down then
		CountDown.Instance:RemoveCountDown(self.chat_cd_count_down)
		self.chat_cd_count_down = nil
	end
end

function MainUIViewChat:ClickSpeaker()
	TipsCtrl.Instance:ShowSpeakerView()
end

function MainUIViewChat:SetChatButtons(value)
	self.node_list["ChatButtons"]:SetActive(value)
end

function MainUIViewChat:AllActivityViewClick()
	local main_view = MainUICtrl.Instance:GetView()
	if main_view then
		main_view:OpenActivityPreview()
	end
end

function MainUIViewChat:ClickActivityView()
	local cfg = ActivityData.Instance:GetCurActOpenInfo()
	if not cfg then
		cfg = ActivityData.Instance:GetNextActOpenInfo()
	end
	if cfg then
		if cfg.act_id == ACTIVITY_TYPE.MOSHEN then 											--世界boss活动跳转到boss界面
			ViewManager.Instance:Open(ViewName.Boss, TabIndex.world_boss)
		elseif cfg.act_id == ACTIVITY_TYPE.KF_GUILDBATTLE then
			ViewManager.Instance:Open(ViewName.KuaFuBattle)
		elseif cfg.act_id == ACTIVITY_TYPE.Triple_LiuJie then
			ViewManager.Instance:Open(ViewName.KuaFuBattle)
		else
			ActivityCtrl.Instance:ShowDetailView(cfg.act_id)
		end
	end
 end

function MainUIViewChat:OnDayChange()
	self:FlushActivityPre()
end

function MainUIViewChat:FlushActivityPre()
	self:OnFlushActPreviewTimer()
	self:SetActiveName()
end

function MainUIViewChat:OnFlushActPreviewTimer()
	if nil == self.act_preview_time_time_quest then
		local timer_func = function()
			local time_str = ActivityData.Instance:GetCurActivityCountDownStr()
			if self.node_list["OpenTime"] then
				if time_str and time_str ~= "" then
					time_str = ToColorStr(time_str, TEXT_COLOR.GREEN)
					time_str = Language.Activity.ActivityIsOn .. "：" .. time_str
				end
				if not time_str or time_str == "" then
					local info = ActivityData.Instance:GetNextActOpenInfo()
					if info then
						time_str = ToColorStr(info.open_time, TEXT_COLOR.GREEN)
						time_str = Language.Activity.ActivityOpenTime .. time_str
					end
				end
				self.node_list["OpenTime"].text.text = time_str
			end
			self:SetActiveName()

			if time_str == "" then 					--今天是否已经没有活动
				self.node_list["AllActivityName"]:SetActive(false)
				if self.act_preview_time_time_quest then
					GlobalTimerQuest:CancelQuest(self.act_preview_time_time_quest)
					self.act_preview_time_time_quest = nil
				end
			else
				self.node_list["AllActivityName"]:SetActive(true and not IS_AUDIT_VERSION)
			end
		end
		self.act_preview_time_time_quest = GlobalTimerQuest:AddRunQuest(timer_func, 1)
	end
end

function MainUIViewChat:SetActiveName()
	local cfg = ActivityData.Instance:GetCurActOpenInfo()
	if not cfg then
		cfg = ActivityData.Instance:GetNextActOpenInfo()
	end
	if cfg and self.node_list["ActivityNameText"] then
		self.node_list["ActivityNameText"].text.text = cfg.act_name
	end
end

------------------------------------------------------------------------------------------
-- NearRoleNameCell
------------------------------------------------------------------------------------------

-- 附近玩家Cell
NearRoleNameCell = NearRoleNameCell or BaseClass(BaseRender)
function NearRoleNameCell:__init(instance)
	
end

function NearRoleNameCell:__delete()
	
end

function NearRoleNameCell:SetData(obj)
	local vo = obj and obj:GetVo() or {}
	local color = vo.name_color == EvilColorList.NAME_COLOR_WHITE and TEXT_COLOR.YELLOW or TEXT_COLOR.RED
	local name = "<color="..color..">"..(vo.name or "").."</color>"
	local cap = vo.total_capability or 0
	if cap > 0 then
		local bool_num = vo.hp / vo.max_hp
		name = name .. " <color=#00ff00>(".. math.floor(bool_num * 100).."%) "..Language.Common.ZhanLi ..":" .. CommonDataManager.ConverNum(cap) .."</color>"
	end
	self.node_list["TxtName"].text.text = name
	self.node_list["ImgSelect"]:SetActive(SceneObj.select_obj == obj)
end

function NearRoleNameCell:ListenClick(handler)
	self.node_list["NameCell"].toggle:AddClickListener(handler)
end

------------------------------------------------------------------------------------------
-- MainUIChatCell
------------------------------------------------------------------------------------------

MainUIChatCell = MainUIChatCell or BaseClass(BaseRender)

function MainUIChatCell:__init()
	self.old_height = 0
	self.height_change = false
end

function MainUIChatCell:__delete()
	self.voice_animator = nil
	self.voice_obj = nil
end

function MainUIChatCell:PlayOrStopVoice(file_name)
	ChatCtrl.Instance:ClearPlayVoiceList()
	ChatCtrl.Instance:SetStartPlayVoiceState(false)
	local call_back = BindTool.Bind(self.ChangeVoiceAni, self)
	ChatRecordMgr.Instance:PlayVoice(file_name, call_back, call_back)
end

function MainUIChatCell:PlayOrStopFeesVoice(file_id)
	ChatCtrl.Instance:ClearPlayVoiceList()
	ChatCtrl.Instance:SetStartPlayVoiceState(false)
	local call_back = BindTool.Bind(self.ChangeVoiceAni, self)
	AudioService.Instance:PlayFeesAudio(file_id, call_back)
end

function MainUIChatCell:ChangeVoiceAni(state)
	if self.voice_animator and not IsNil(self.voice_animator.gameObject) then
		self.voice_animator:SetBool("play", state)
	end
end

function MainUIChatCell:GetMsgId()
	if nil == self.data then return 0 end
	return self.data.msg_id
end

function MainUIChatCell:SetData(data)
	if data == nil or IsNil(self.node_list["Content"].gameObject) then
		return
	end

	self.data = data
	self:Step()
end

function MainUIChatCell:Step()
	local data = self.data
	local content = data.content
	local name = data.username
	local color = CHAT_TEXT_COLOR.GREEN
	if name and name ~= "" and data.username ~= Language.Channel[6] then
		local role_vo = GameVoManager.Instance:GetMainRoleVo()
		local str_name = ""
		if role_vo.role_id ~= data.from_uid then
			color = TEXT_COLOR.BLUE
		end
		str_name = string.format("{wordcolor;%s;%s:}", color, name)
		content = str_name .. content
	end

	local bundle, asset = ResPath.GetA2ChatLableIcon("word")
	local title_text = Language.Channel[data.channel_type or 0]
	if data.channel_type == CHANNEL_TYPE.WORLD then
		bundle, asset = ResPath.GetA2ChatLableIcon("word")
	elseif data.channel_type == CHANNEL_TYPE.TEAM then
		bundle, asset = ResPath.GetA2ChatLableIcon("team")
	elseif data.channel_type == CHANNEL_TYPE.GUILD then
		bundle, asset = ResPath.GetA2ChatLableIcon("guild")
	elseif data.channel_type == CHANNEL_TYPE.SYSTEM or data.channel_type == CHANNEL_TYPE.GUILD_SYSTEM then
		bundle, asset = ResPath.GetA2ChatLableIcon("system")
	elseif data.channel_type == CHANNEL_TYPE.SPEAKER then
		bundle, asset = ResPath.GetA2ChatLableIcon("speaker")
	elseif data.channel_type == CHANNEL_TYPE.CROSS then
		bundle, asset = ResPath.GetA2ChatLableIcon("cross")
	end

	local rich_text = self.node_list["Content"].rich_text

	self.node_list["ImgBgTitle"].image:LoadSpriteAsync(bundle, asset .. ".png")
	--是否语音
	if data.content_type == CHAT_CONTENT_TYPE.AUDIO then
		local temp_str = data.content
		local tbl = {}
		for i = 1, 3 do
			local j, k = string.find(temp_str, "(%d+)")
			local num = string.sub(temp_str, j, k)
			temp_str = string.gsub(temp_str, num, "num")
			table.insert(tbl, num)
		end
		local callback = BindTool.Bind(self.PlayOrStopVoice, self)
		self:AddVoiceBtn(rich_text, name, color, tbl, data.content_type, callback, data.content)
		return
	elseif data.content_type == CHAT_CONTENT_TYPE.FEES_AUDIO then
		local content_t = Split(data.content, "_")
		if #content_t ~= 3 then
			return
		end
		local callback = BindTool.Bind(self.PlayOrStopFeesVoice, self)
		self:AddVoiceBtn(rich_text, name, color, content_t[3], data.content_type, callback, content_t[1], content_t[2])
		return
	end

	if self.data.tuhaojin_color > 0 then
		color = CoolChatData.Instance:GetTuHaoJinColorByIndex(self.data.tuhaojin_color)
	else
		color = COLOR.WHITE
	end
	RichTextUtil.ParseRichText(rich_text, content, nil, color, true)

	--设置描边颜色
	-- local shadow_color = CHANEL_TEXT_OUTLINE_COLOR[data.channel_type] or CHANEL_TEXT_OUTLINE_COLOR[CHANNEL_TYPE.WORLD]
	-- self.node_list["ChanelText"].shadow.effectColor = shadow_color
end

function MainUIChatCell:GetData()
	return self.data or {}
end

function MainUIChatCell:SetIndex(index)
	self.index = index
end

function MainUIChatCell:GetIndex()
	return self.index
end

function MainUIChatCell:GetContentHeight(is_need_force_rebuild)
	local rect = self.node_list["Content"].rect
	if is_need_force_rebuild then
		UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(rect)
	end

	local hegiht = rect.rect.height < 30 and 30 or rect.rect.height
	return hegiht
end

function MainUIChatCell:ClickCallBack(callback, file_name)
	if callback then
		callback(file_name)
	end
end

function MainUIChatCell:AddVoiceBtn(rich_text, name, color, tbl, content_type, callback, file_name, fees_audio_content)
	rich_text:Clear()
	if name and color then
		rich_text:AddText(string.format("<color='%s'>%s</color>：", color, name))
	end
	local time = 0
	if "table" == type(tbl) then
		time = tbl[3]
	else
		time = tbl
	end

	local btn_name = "VioceButtonLeft"

	self.voice_obj = ResPoolMgr:TryGetGameObject("uis/views/miscpreload_prefab", btn_name)
	rich_text:AddObject(self.voice_obj)

	local name_table = self.voice_obj:GetComponent(typeof(UINameTable))
	if name_table then
		local node_list = U3DNodeList(name_table)
		node_list["TxtTime"].text.text = time
		if callback then
			if content_type == CHAT_CONTENT_TYPE.FEES_AUDIO then
				node_list["VioceButton"].button:AddClickListener(BindTool.Bind(self.ClickCallBack, self, callback, file_name))

				local fees_color
				if self.data.tuhaojin_color > 0 then
					fees_color = CoolChatData.Instance:GetTuHaoJinColorByIndex(self.data.tuhaojin_color)
				else
					fees_color = COLOR.WHITE
				end
				rich_text:AddText(ToColorStr(fees_audio_content, fees_color))
			else
				node_list["VioceButton"].button:AddClickListener(BindTool.Bind(self.ClickCallBack, self, callback, file_name))
			end
		end
	end
	self.voice_animator = self.voice_obj:GetComponent(typeof(UnityEngine.Animator))
end