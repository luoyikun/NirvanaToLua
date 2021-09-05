require("game/chat/chat_cell")
require("game/chat/guild_maze_chat_cell")
require("game/chat/chat_data")
require("game/chat/chat_view")
require("game/chat/guild_chat_view")
require("game/chat/guild_chat_data")
require("game/chat/chat_filter")
require("game/chat/voice_setting_view")
require("game/chat/chat_notice_view")
require("game/chat/want_equip_view")
require("game/chat/guild_enemy_view")
require("game/chat/guild_skill_tip")

ChatCtrl = ChatCtrl or BaseClass(BaseController)

function ChatCtrl:__init()
	if ChatCtrl.Instance then
		print_error("[ChatCtrl]:Attempt to create singleton twice!")
	end
	ChatCtrl.Instance = self

	self.data = ChatData.New()
	self.view = ChatView.New(ViewName.Chat)
	self.filter = ChatFilter.New()
	self.guild_chat_view = GuildChatView.New(ViewName.ChatGuild)
	self.guild_chat_data = GuildChatData.New()
	self.want_equip_view = WantEquipView.New()
	self.guild_enemy_view = TipsGuildEnemyView.New()
	self.guild_skill_tip = GuildSkillTip.New()

	self.voice_setting_view = VoiceSettingView.New(ViewName.VoiceSetting)
	self.chat_notice_view = ChatNoticeView.New()

	self:RegisterAllProtocols()

	self.interval = 1							--添加消息间隔
	self.question_interval = 0.5				--添加答题消息间隔
	self.next_send_system_time = 0 				--下次发系统送消息时间
	self.next_send_world_time = 0 				--下次发世界送消息时间
	self.next_send_question_time = 0 			--下次发送答题消息时间

	self.world_time_quest = nil				--世界聊天计时器
	self.system_time_quest = nil			--系统聊天计时器

	self.auto_play_voice_list = {}			--自动播放语音队列

	self.client_hearsay_time_quest = {}

	self.hear_say_event = GlobalEventSystem:Bind(SettingEventType.CLOSE_HEARSAY, BindTool.Bind(self.ChangeHearSayState, self))
	self.role_attr_change_callback = BindTool.Bind(self.ListenRoleAttrChange, self)
	PlayerData.Instance:ListenerAttrChange(self.role_attr_change_callback)
	
	-- self.connect_login_server = GlobalEventSystem:Bind(LoginEventType.LOGIN_SERVER_CONNECTED, BindTool.Bind(self.OnConnectLoginServer, self))

	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
	self:BindGlobalEvent(SceneEventType.SCENE_LOADING_STATE_ENTER, BindTool.Bind1(self.EnterScene, self))
	-- self:BindGlobalEvent(SceneEventType.CLOSE_LOADING_VIEW, BindTool.Bind1(self.OnCloseSceneLoadingView, self))
end

function ChatCtrl:GetView()
	return self.view
end

function ChatCtrl:__delete()
	self:DelPriviteList()

	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil

	self.filter:DeleteMe()
	self.filter = nil

	self.want_equip_view:DeleteMe()
	self.want_equip_view = nil

	self.guild_enemy_view:DeleteMe()
	self.guild_enemy_view = nil

	ChatCtrl.Instance = nil
	if self.hear_say_event then
		GlobalEventSystem:UnBind(self.hear_say_event)
		self.hear_say_event = nil
	end

	if self.guild_chat_view then
		self.guild_chat_view:DeleteMe()
		self.guild_chat_view = nil
	end

	if self.guild_chat_data then
		self.guild_chat_data:DeleteMe()
		self.guild_chat_data = nil
	end

	if self.voice_setting_view then
		self.voice_setting_view:DeleteMe()
		self.voice_setting_view = nil
	end

	if self.chat_notice_view then
		self.chat_notice_view:DeleteMe()
		self.chat_notice_view = nil
	end

	if self.chat_measuring then
		self.chat_measuring:DeleteMe()
		self.chat_measuring = nil
	end

	if self.chuanwen_measuring then
		self.chuanwen_measuring:DeleteMe()
		self.chuanwen_measuring = nil
	end

	if self.purchase_measuring then
		self.purchase_measuring:DeleteMe()
		self.purchase_measuring = nil
	end

	if self.fall_item_measuring then
		self.fall_item_measuring:DeleteMe()
		self.fall_item_measuring = nil
	end

	if self.guild_skill_tip then
		self.guild_skill_tip:DeleteMe()
		self.guild_skill_tip = nil
	end

	if self.connect_login_server then
		GlobalEventSystem:UnBind(self.connect_login_server)
		self.connect_login_server = nil
	end

	for k,v in pairs(self.client_hearsay_time_quest) do
		GlobalTimerQuest:CancelQuest(v)
	end
	self.client_hearsay_time_quest = {}

	--清空所有语音缓存
	ChatRecordMgr.Instance:RemoveAllRecord()

	self:ClearWorldTimeQuest()
	self:ClearSystemTimeQuest()

	PlayerData.Instance:UnlistenerAttrChange(self.role_attr_change_callback)

	if self.delay_rich_text_timer then
		GlobalTimerQuest:CancelQuest(self.delay_rich_text_timer)
		self.delay_rich_text_timer = nil
	end

	self.role_attr_change_callback = nil
end

function ChatCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSChannelChatReq)					--请求频道聊天
	self:RegisterProtocol(CSSingleChatReq)					--请求私人聊天
	self:RegisterProtocol(CSSpeaker)						--发送喇叭
	self:RegisterProtocol(CSSingleChatOnlineStatusReq)
	self:RegisterProtocol(CSGuildEnemyRankList)

	self:RegisterProtocol(SCChannelChatAck, "OnChannelChat")
	self:RegisterProtocol(SCSingleChatAck, "OnSingleChat")
	self:RegisterProtocol(SCSingleChatUserNotExist, "OnSingleChatUserNotExist")
	self:RegisterProtocol(SCFakePrivateChat, "OnFakePrivateChat")
	self:RegisterProtocol(SCSpeaker, "OnSpeaker")
	self:RegisterProtocol(SCSystemMsg, "OnSystemMsg")
	self:RegisterProtocol(SCOpenLevelLimit, "OnOpenLevelLimit")
	self:RegisterProtocol(SCForbidChatInfo, "OnForbidChatInfo")
	self:RegisterProtocol(SCForbidUserInfo, "OnForbidUserInfo")
	self:RegisterProtocol(SCChatBoardListInfo, "OnChatBoardListInfo")
	self:RegisterProtocol(SCSingleChatOnlineStatus, "OnSingleChatOnlineStatus")
	self:RegisterProtocol(SCGuildEnemyRankLis, "OnGuildEnemyRankLis")
end

function ChatCtrl:OpenWantEquipView(current_id, other_data)
	self.want_equip_view:SetCurrentChannelType(current_id, other_data)
	self.want_equip_view:Open()
end

function ChatCtrl:OpenGuildEnemyView()
	self.guild_enemy_view:Open()
	self.guild_enemy_view:Flush()
end

function ChatCtrl:CloseGuildEnemyView()
	self.guild_enemy_view:Close()
end

function ChatCtrl:SetStartPlayVoiceState(state)
	self.start_play_voice = state
end

function ChatCtrl:ClearPlayVoiceList()
	self.auto_play_voice_list = {}
end

--开始自动播放语音
function ChatCtrl:StartAutoPlayVoice()
	if self.start_play_voice then
		return
	end
	self.start_play_voice = true
	if not next(self.auto_play_voice_list) then
		self.start_play_voice = false
		return
	end
	local function paly_call_back()
		if not next(self.auto_play_voice_list) then
			self.start_play_voice = false
			return
		end

		local play_world = self.data:GetAutoWorldVoice()
		local play_team = self.data:GetAutoTeamVoice()
		local play_guild = self.data:GetAutoGuildVoice()
		local play_privite = self.data:GetAutoPriviteVoice()

		if not play_world and not play_team and not play_guild and not play_privite then
			self.auto_play_voice_list = {}
			self.start_play_voice = false
			return
		end

		local max_count = #self.auto_play_voice_list
		for i = max_count, 1, -1 do
			local data = self.auto_play_voice_list[i]
			if not play_world and data.channel_type == CHANNEL_TYPE.WORLD then
				table.remove(self.auto_play_voice_list, i)
			elseif not play_team and data.channel_type == CHANNEL_TYPE.TEAM then
				table.remove(self.auto_play_voice_list, i)
			elseif not play_guild and data.channel_type == CHANNEL_TYPE.GUILD then
				table.remove(self.auto_play_voice_list, i)
			elseif not play_privite and data.channel_type == CHANNEL_TYPE.PRIVATE then
				table.remove(self.auto_play_voice_list, i)
			end
		end

		if not next(self.auto_play_voice_list) then
			self.start_play_voice = false
			return
		end

		local new_voice_path = self.auto_play_voice_list[1].path
		local new_voice_content_type = self.auto_play_voice_list[1].content_type
		table.remove(self.auto_play_voice_list, 1)
		GlobalTimerQuest:AddDelayTimer(function()
			if new_voice_content_type == CHAT_CONTENT_TYPE.AUDIO then
				ChatRecordMgr.Instance:PlayVoice(new_voice_path, nil, paly_call_back)
			elseif new_voice_content_type == CHAT_CONTENT_TYPE.FEES_AUDIO then
				local content_t = Split(new_voice_path, "_")
				if #content_t == 3 then
					AudioService.Instance:PlayFeesAudio(content_t[1], paly_call_back)
				end
			end
		end, 0)
	end

	paly_call_back()
end

function ChatCtrl:ClearWorldTimeQuest()
	if self.world_time_quest then
		GlobalTimerQuest:CancelQuest(self.world_time_quest)
		self.world_time_quest = nil
	end
end

function ChatCtrl:CheckToPlayVoice(msg_info)
	--判断是否自动播放语音
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if (msg_info.content_type == CHAT_CONTENT_TYPE.AUDIO or msg_info.content_type == CHAT_CONTENT_TYPE.FEES_AUDIO) and msg_info.from_uid ~= role_id then
		local data = {}
		local function add_data()
			data.from_uid = msg_info.from_uid
			data.msg_id = msg_info.msg_id
			data.channel_type = msg_info.channel_type
			data.content_type = msg_info.content_type
			data.path = msg_info.content
		end
		if msg_info.channel_type == CHANNEL_TYPE.WORLD and self.data:GetAutoWorldVoice() then
			--自动播放世界语音
			add_data()
		elseif msg_info.channel_type == CHANNEL_TYPE.TEAM and self.data:GetAutoTeamVoice() then
			--自动播放队伍语音
			add_data()
		elseif msg_info.channel_type == CHANNEL_TYPE.GUILD and self.data:GetAutoGuildVoice() then
			--自动播放公会语音
			add_data()
		elseif msg_info.channel_type == CHANNEL_TYPE.PRIVATE and self.data:GetAutoPriviteVoice() then
			--自动播放私聊语音
			add_data()
		end
		if next(data) then
			table.insert(self.auto_play_voice_list, data)
			self:StartAutoPlayVoice()
		end
	end
end

--连接本地服务器
function ChatCtrl:OnConnectLoginServer(is_succ)
	if is_succ then
		--连接成功清除本地缓存聊天消息
		self.data:ClearChannelMsg()
	end
end

--提前加载一个聊天cell做计算高度处理
function ChatCtrl:CreateChatCell()
	if nil ~= self.chat_measuring then
		return
	end

	local obj = ResPoolMgr:TryGetGameObject("uis/views/miscpreload_prefab", "ChatCell", true)
	if not obj then
		return
	end

	obj.transform:SetParent(GameObject.Find("GameRoot/UILayer").transform, false)
	obj.transform.localPosition = Vector3(9999, 0, 0)			--直接放在界面外
	self.chat_measuring = ChatCell.New(obj.gameObject)
end

--提前加载一个传闻cell做计算高度处理
function ChatCtrl:CreateChuanwenCell()
	if nil ~= self.chuanwen_measuring then
		return
	end

	local obj = ResPoolMgr:TryGetGameObject("uis/views/miscpreload_prefab", "GuildchuanwenItemText", true)
	if not obj then
		return
	end

	obj.transform:SetParent(GameObject.Find("GameRoot/UILayer").transform, false)
	obj.transform.localPosition = Vector3(9999, 0, 0)			--直接放在界面外
	self.chuanwen_measuring = ChuanwenCell.New(obj.gameObject)
end

function ChatCtrl:CreatePurchaseTextCell()
	if nil ~= self.purchase_measuring then
		return
	end

	local obj = ResPoolMgr:TryGetGameObject("uis/views/miscpreload_prefab", "PurchaseItemText", true)
	if not obj then
		return
	end

	obj.transform:SetParent(GameObject.Find("GameRoot/UILayer").transform, false)
	obj.transform.localPosition = Vector3(9999, 0, 0)			--直接放在界面外
	self.purchase_measuring = PurchaseCell.New(obj.gameObject)
end

function ChatCtrl:CreateFallItemTextCell()
	if nil ~= self.fall_item_measuring then
		return
	end

	local obj = ResPoolMgr:TryGetGameObject("uis/views/miscpreload_prefab", "FallItemText", true)
	if not obj then
		return
	end

	obj.transform:SetParent(GameObject.Find("GameRoot/UILayer").transform, false)
	obj.transform.localPosition = Vector3(9999, 0, 0)			--直接放在界面外
	self.fall_item_measuring = FallMessageCell.New(obj.gameObject)
end

--每次有聊天信息返回先计算高度(只计算chatcell的高度)
function ChatCtrl:CaleChatHeight(channel_type, msg_info)
	if nil == self.chat_measuring then
		return 0
	end
	local height = ChatData.Instance:GetChannelItemHeight(channel_type, msg_info.msg_id)
	if height > 0 then
		return height
	end

	self.chat_measuring:SetEasy(true)
	self.chat_measuring:SetData(msg_info)
	height = self.chat_measuring:GetContentHeight()
	ChatData.Instance:SetChannelItemHeight(channel_type, msg_info.msg_id, height)
	return height
end

--每次传闻信息返回先计算高度(只计算chatcell的高度)
function ChatCtrl:CaleChuanWenHeight(msg_info, content)
	if nil == self.chuanwen_measuring then
		return 0
	end
	local height = ChatData.Instance:GetChuanwenItemHeight(content)
	if height > 0 then
		return height
	end
	
	self.chuanwen_measuring:SetData(msg_info)
	height = self.chuanwen_measuring:GetContentHeight()
	ChatData.Instance:SetChuanwenItemHeight(content, height)
	return height
end

--每次传闻信息返回先计算高度(只计算chatcell的高度)
function ChatCtrl:CalePurchaseHeight(msg_info, content)
	if nil == self.purchase_measuring then
		return 0
	end
	local height = ChatData.Instance:GetPurchaseItemHeight(content)
	if height > 0 then
		return height
	end
	
	self.purchase_measuring:SetData(msg_info)
	height = self.purchase_measuring:GetContentHeight()
	ChatData.Instance:SetPurchaseItemHeight(content, height)
	return height
end

--每次掉落传闻信息返回先计算高度(只计算chatcell的高度)
function ChatCtrl:CaleFallItemHeight(msg_info, content)
	if nil == self.fall_item_measuring then
		return 0
	end
	local height = ChatData.Instance:GetFallItemHeight(content)
	if height > 0 then
		return height
	end
	
	self.fall_item_measuring:SetData(msg_info)
	height = self.fall_item_measuring:GetContentHeight()
	ChatData.Instance:SetFallItemHeight(content, height)
	return height
end

-- 处理答题频道
function ChatCtrl:QuestionChannelHandle(msg_info)
	if msg_info.channel_type == CHANNEL_TYPE.WORLD_QUESTION then
		--世界答题

		if self.view:IsOpen() then
			self.view:Flush(CHANNEL_TYPE.WORLD_QUESTION)
		end
	elseif msg_info.channel_type == CHANNEL_TYPE.GUILD_QUESTION then
		--公会答题

		if self.guild_chat_view:IsOpen() then
			self.guild_chat_view:Flush("new_chat", {CHANNEL_TYPE.GUILD_QUESTION, SPECIAL_CHAT_ID.GUILD})
		end
	end

	self.data:AddChannelMsg(msg_info)

	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if msg_info.from_uid ~= role_id then
		GlobalEventSystem:Fire(MainUIEventType.NEW_CHAT_CHANGE, msg_info)
	end
end

function ChatCtrl:ChangeChannelType(channel_type)
	if self.guild_chat_view:IsOpen() then
		self.guild_chat_view:ChangeChannelGuildSystem(channel_type)
	end
end

function ChatCtrl:ClearQuestionTimeQuest()
	if self.question_time_quest then
		GlobalTimerQuest:CancelQuest(self.question_time_quest)
		self.question_time_quest = nil
	end
end

function ChatCtrl:FlushViewActivityIcon()
	if self.guild_chat_view:IsOpen() then
		self.guild_chat_view:FlushActivityIcon()
	end
end

function ChatCtrl:OnChatBoardListInfo(protocol)
	self:CreateChatCell()

	if protocol.msg_list and protocol.msg_list[0] and next(protocol.msg_list[0]) then
		for k,v in pairs(protocol.msg_list[0]) do
			if v.msg_type_id == 8100 then
				local msg_info = ChatData.CreateMsgInfo()
				msg_info.from_uid = v.from_uid
				msg_info.username = v.username
				msg_info.sex = v.sex
				msg_info.camp = v.camp
				msg_info.prof = v.prof
				msg_info.authority_type = v.authority_type
				msg_info.content_type = v.content_type
				msg_info.tuhaojin_color = v.tuhaojin_color
				msg_info.bigchatface_status = v.bigchatface_status
				msg_info.channel_window_bubble_type = v.personalize_window_bubble_type
				msg_info.level = v.level
				msg_info.vip_level = v.vip_level
				msg_info.channel_type = v.channel_type
				msg_info.guild_signin_count = v.guild_signin_count
				msg_info.content = v.content
				msg_info.role_id = v.role_id or 0
				msg_info.plat_id = v.plat_id or 0
				msg_info.uuid = v.uuid or 0
				msg_info.send_time = v.msg_timestamp
				msg_info.msg_timestamp = os.date("*t", v.msg_timestamp)
				msg_info.send_time_str = TimeUtil.FormatTable2HMS(msg_info.msg_timestamp)
				msg_info.use_head_frame = v.use_head_frame
				msg_info.is_answer_true = v.is_answer_true
				msg_info.has_xianzunka_flag = v.has_xianzunka_flag

				AvatarManager.Instance:SetAvatarKey(v.role_id, v.avatar_key_big, v.avatar_key_small)
				AvatarManager.Instance:SetAvatarFrameKey(v.role_id, v.use_head_frame)

				self.data:AddChannelMsg(msg_info)
				self:CheckToPlayVoice(msg_info)
			else
				local msg_info = ChatData.CreateMsgInfo()
				msg_info.from_uid = v.from_uid
				msg_info.plat_id = v.plat_id
				msg_info.role_id = v.role_id
				msg_info.username = v.username
				msg_info.sex = v.sex
				msg_info.camp = v.camp
				msg_info.prof = v.prof
				msg_info.authority_type = v.authority_type
				msg_info.content_type = v.content_type
				msg_info.level = v.level
				msg_info.vip_level = v.vip_level
				msg_info.plat_name = v.plat_name
				msg_info.server_id =  v.server_id
				msg_info.speaker_type =  v.speaker_type
				msg_info.tuhaojin_color = v.tuhaojin_color
				msg_info.bigchatface_status = v.bigchatface_status
				msg_info.personalize_window_type = v.personalize_window_type
				msg_info.channel_window_bubble_type = v.personalize_window_bubble_type
				msg_info.channel_type = CHANNEL_TYPE.SPEAKER
				msg_info.use_head_frame = v.use_head_frame
				msg_info.has_xianzunka_flag = v.has_xianzunka_flag
				if msg_info.speaker_type == SPEAKER_TYPE.SPEAKER_TYPE_CROSS then
					msg_info.channel_type = CHANNEL_TYPE.CROSS
				end
				msg_info.content = v.speaker_msg

				msg_info.send_time = v.send_time_stamp
				msg_info.msg_timestamp = os.date("*t", v.send_time_stamp)
				msg_info.send_time_str = TimeUtil.FormatTable2HMS(msg_info.msg_timestamp)

				AvatarManager.Instance:SetAvatarKey(v.from_uid, v.avatar_key_big, v.avatar_key_small)
				AvatarManager.Instance:SetAvatarFrameKey(v.from_uid, v.use_head_frame)

				if msg_info.from_uid ~= 0 then
					msg_info.content = ChatFilter.Instance:Filter(msg_info.content)
				end

				self.data:AddChannelMsg(msg_info)
				self.data:AddTransmitInfo(msg_info)
			end
		end
	elseif protocol.msg_list and protocol.msg_list[4] and next(protocol.msg_list[4]) then
		for k,v in pairs(protocol.msg_list[4]) do
			local msg_info = ChatData.CreateMsgInfo()
			msg_info.from_uid = v.from_uid
			msg_info.username = v.username
			msg_info.sex = v.sex
			msg_info.camp = v.camp
			msg_info.prof = v.prof
			msg_info.authority_type = v.authority_type
			msg_info.content_type = v.content_type
			msg_info.tuhaojin_color = v.tuhaojin_color
			msg_info.bigchatface_status = v.bigchatface_status
			msg_info.channel_window_bubble_type = v.personalize_window_bubble_type
			msg_info.level = v.level
			msg_info.vip_level = v.vip_level
			msg_info.channel_type = v.channel_type
			msg_info.guild_signin_count = v.guild_signin_count
			msg_info.content = v.content
			msg_info.role_id = v.role_id or 0
			msg_info.plat_id = v.plat_id or 0
			msg_info.uuid = v.uuid or 0
			msg_info.send_time = v.msg_timestamp
			msg_info.msg_timestamp = os.date("*t", v.msg_timestamp)
			msg_info.send_time_str = TimeUtil.FormatTable2HMS(msg_info.msg_timestamp)
			msg_info.use_head_frame = v.use_head_frame
			msg_info.is_answer_true = v.is_answer_true
			msg_info.origin_type = v.origin_type

			AvatarManager.Instance:SetAvatarKey(v.role_id, v.avatar_key_big, v.avatar_key_small)
			AvatarManager.Instance:SetAvatarFrameKey(v.role_id, v.use_head_frame)

			self.data:AddChannelMsg(msg_info)
			self:CheckToPlayVoice(msg_info)

			local uservo = GameVoManager.Instance:GetMainRoleVo()
			if msg_info.from_uid ~= uservo.role_id then
				if not self.guild_chat_view:IsOpen() then
					if not self.guild_chat_data:GetIsHidePopRect() then
						ChatData.Instance:SetIsPopChat(true)
						MainUICtrl.Instance:FlushView("show_guild_popchat", {true})
						MainUICtrl.Instance:FlushView("flush_popchat_view", {msg_info})
					end
					MainUICtrl.Instance:FlushView("show_guildchat_redpt", {true})
				end
				--添加公会未读消息
				ChatData.Instance:AddGuildUnreadMsg(msg_info)
				RemindManager.Instance:Fire(RemindName.GuildChatRed)
			else
				if not self.guild_chat_view:IsOpen() then
					if not self.guild_chat_data:GetIsHidePopRect() then
						ChatData.Instance:SetIsPopChat(true)
						MainUICtrl.Instance:FlushView("show_guild_popchat", {true})
						MainUICtrl.Instance:FlushView("flush_popchat_view", {msg_info})
					end
					MainUICtrl.Instance:FlushView("show_guildchat_redpt", {true})
				end
				ChatData.Instance:SetNewLockState(false)
			end
			if self.guild_chat_view:IsOpen() then
				self.guild_chat_view:Flush("new_chat", {CHANNEL_TYPE.GUILD, SPECIAL_CHAT_ID.GUILD})
			end
			if ViewManager.Instance:IsOpen(ViewName.Guild) then
				ViewManager.Instance:FlushView(ViewName.Guild, "guild_maze")
			end
		end
	elseif protocol.msg_list and protocol.msg_list[5] and next(protocol.msg_list[5]) then
		for k,v in pairs(protocol.msg_list[5]) do
			if SettingData.Instance:GetSettingData(SETTING_TYPE.STRANGER_CHAT) and
				not ScoietyData.Instance:IsFriendById(v.role_id) then		-- 拒绝陌生私聊
				return
			end

			if ScoietyData.Instance:IsBlack(v.role_id) then
				return
			end

			local msg_info = ChatData.CreateMsgInfo()
			msg_info.from_uid = v.from_uid or 0
			msg_info.role_id = v.role_id or 0
			msg_info.plat_id = v.plat_id or 0
			msg_info.uuid = v.uuid or 0
			msg_info.username = v.username
			msg_info.sex = v.sex
			msg_info.camp = v.camp
			msg_info.prof = v.prof
			msg_info.authority_type = v.authority_type
			msg_info.content_type = v.content_type
			msg_info.level = v.level
			msg_info.vip_level = v.vip_level
			msg_info.tuhaojin_color = v.tuhaojin_color
			msg_info.bigchatface_status = v.bigchatface_status
			msg_info.channel_window_bubble_type = v.personalize_window_bubble_type
			msg_info.channel_type = CHANNEL_TYPE.PRIVATE
			msg_info.has_xianzunka_flag = v.has_xianzunka_flag
			msg_info.content = v.content
			msg_info.msg_timestamp = v.msg_timestamp or 0
			local time = msg_info.msg_timestamp > 0 and os.date("*t", msg_info.msg_timestamp) or TimeCtrl.Instance:GetServerTimeFormat()
			msg_info.send_time_str = TimeUtil.FormatTable2HMS(time)
			msg_info.use_head_frame = v.use_head_frame
			AvatarManager.Instance:SetAvatarKey(v.role_id, v.avatar_key_big, v.avatar_key_small)
			AvatarManager.Instance:SetAvatarFrameKey(v.role_id, v.use_head_frame)
			if msg_info.role_id ~= 0 and msg_info.content_type ~= CHAT_CONTENT_TYPE.AUDIO then
				msg_info.content = ChatFilter.Instance:Filter(msg_info.content)
			end
			msg_info.is_echo = v.is_echo
			self.data:AddPrivateUnreadMsg(msg_info)
			RemindManager.Instance:Fire(RemindName.GuildChatRed)

			self.data:AddPrivateMsg(v.role_id, msg_info)

			local privite_obj = self.data:GetPrivateObjByRoleId(v.role_id)
			if privite_obj ~= nil then
				--记录最后聊天时间
				privite_obj.last_send_time = TimeCtrl.Instance:GetServerTime()
				privite_obj.username = v.username or ""
				privite_obj.level = v.level or 0
				self:AddPriviteObjOnLocal(privite_obj)
			end

			self:CheckToPlayVoice(msg_info)
			self.data:SetHavePriviteChat(true)
			if not self.guild_chat_view:IsOpen() then
				MainUICtrl.Instance:FlushView("show_privite_remind", {msg_info})
			end
		end
	end

	GlobalEventSystem:Fire(MainUIEventType.CHAT_CHANGE, nil)
end

--  监听玩家上下线的状态切换
function ChatCtrl:SingleChatOnlineStatusReq(req_type, plat_type, role_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSingleChatOnlineStatusReq)
	protocol.req_type = req_type or 0
	protocol.plat_type = plat_type or 0
	protocol.target_id = role_id or 0
	protocol:EncodeAndSend()
end

function ChatCtrl:SendGuildEnemyRankList()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildEnemyRankList)
	protocol:EncodeAndSend()
end

-- 仙盟仇人排行
function ChatCtrl:OnGuildEnemyRankLis(protocol)
	self.data:SetGuildEnemyList(protocol.guild_enemy_list)
	self.guild_enemy_view:Flush()
end

-- 已监听的玩家上下线的状态切换通知
function ChatCtrl:OnSingleChatOnlineStatus(protocol)
	if self.guild_chat_view:IsOpen() then
		self.guild_chat_view:Flush("single_chat_online", {protocol})
	end
end

-- 频道消息处理
function ChatCtrl:OnChannelChat(protocol)
	self:CreateChatCell()

	local server_time = TimeCtrl.Instance:GetServerTime()
	if self.next_send_world_time < server_time then
		self.next_send_world_time = server_time + self.interval
	end
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if self.data:IsPingBiChannel(protocol.channel_type) and main_role_id ~= protocol.from_uid then
		return
	end

	if ScoietyData.Instance:IsBlack(protocol.from_uid) then
		return
	end

	local msg_info = ChatData.CreateMsgInfo()
	msg_info.from_uid = protocol.from_uid
	msg_info.username = protocol.username
	msg_info.sex = protocol.sex
	msg_info.camp = protocol.camp
	msg_info.prof = protocol.prof
	msg_info.authority_type = protocol.authority_type
	msg_info.content_type = protocol.content_type
	msg_info.tuhaojin_color = protocol.tuhaojin_color
	msg_info.bigchatface_status = protocol.bigchatface_status
	msg_info.channel_window_bubble_type = protocol.personalize_window_bubble_type
	msg_info.level = protocol.level
	msg_info.vip_level = protocol.vip_level
	msg_info.channel_type = protocol.channel_type
	msg_info.guild_signin_count = protocol.guild_signin_count
	msg_info.content = protocol.content
	msg_info.role_id = protocol.role_id or 0
	msg_info.plat_id = protocol.plat_id or 0
	msg_info.uuid = protocol.uuid or 0
	msg_info.send_time = protocol.msg_timestamp
	msg_info.msg_timestamp = os.date("*t", protocol.msg_timestamp)
	msg_info.send_time_str = TimeUtil.FormatTable2HMS(msg_info.msg_timestamp)
	msg_info.use_head_frame = protocol.use_head_frame
	msg_info.is_answer_true = protocol.is_answer_true
	msg_info.origin_type = protocol.origin_type
	msg_info.has_xianzunka_flag = protocol.has_xianzunka_flag

	AvatarManager.Instance:SetAvatarKey(protocol.role_id, protocol.avatar_key_big, protocol.avatar_key_small)
	AvatarManager.Instance:SetAvatarFrameKey(protocol.role_id, protocol.use_head_frame)

	local server_time = TimeCtrl.Instance:GetServerTime()
	--优先处理答题频道
	if msg_info.channel_type == CHANNEL_TYPE.WORLD_QUESTION or msg_info.channel_type == CHANNEL_TYPE.GUILD_QUESTION then
		--缓存答题消息
		local now_time = Status.NowTime
		if self.next_send_question_time < now_time then
			self.next_send_question_time = now_time + self.question_interval
		end
		local temp_question_list = self.data:GetTempQuestionList()
		if #temp_question_list > 0 or (self.next_send_question_time - now_time < self.question_interval and self.next_send_question_time - now_time > 0) then

			self.data:AddTempQuestionList(msg_info)
			if self.question_time_quest then
				return
			end
			self.question_time_quest = GlobalTimerQuest:AddRunQuest(function()
				local new_now_time = Status.NowTime
				if self.next_send_question_time > new_now_time then
					return
				end
				if self.data == nil then
					return
				end
				local question_list = self.data:GetTempQuestionList()
				if #question_list <= 0 then
					self:ClearQuestionTimeQuest()
					return
				end
				local new_msg_info = question_list[1]
				self:QuestionChannelHandle(new_msg_info)
				--移除表头
				self.data:RemoveTempQuestionList(1)
				--重新记录下次发送时间
				self.next_send_question_time = new_now_time + self.question_interval
			end, 0.1)
			return
		end
		self:QuestionChannelHandle(msg_info)
		return
	end

	-- 协议返回不过滤，改用发送的时候过滤
	-- local need_filter = self.filter:MatchStr(msg_info.content)
	-- if msg_info.from_uid ~= 0 and msg_info.content_type ~= CHAT_CONTENT_TYPE.AUDIO and need_filter then
	-- 	msg_info.content = self.filter:Filter(msg_info.content)
	-- end

	-- 缓存世界聊天
	if msg_info.channel_type == CHANNEL_TYPE.WORLD then
		local temp_world_list = self.data:GetTempWorldList()
		if next(temp_world_list) or (self.next_send_world_time - server_time > 0 and self.next_send_world_time - server_time < self.interval) then
			self.data:AddTempWorldList(msg_info)
			if self.world_time_quest then
				return
			end
			self.world_time_quest = GlobalTimerQuest:AddRunQuest(function()
				local new_server_time = TimeCtrl.Instance:GetServerTime()
				if self.next_send_world_time > new_server_time then
					return
				end
				if not next(temp_world_list) then
					self:ClearWorldTimeQuest()
					return
				end
				local new_msg_info = temp_world_list[1]
				self.data:AddChannelMsg(new_msg_info)
				self:CheckToPlayVoice(new_msg_info)
				if self.view:IsOpen() then
					if self.view.curr_show_channel ~= new_msg_info.channel_type then
						if self.view:IsLoaded() then
							self.view:ChangeChannelRedPoint(new_msg_info.channel_type, true)
						end
						if self.view.curr_show_channel == CHANNEL_TYPE.ALL then
							self.view:Flush(CHANNEL_TYPE.ALL)
						end
					else
						self.view:Flush(new_msg_info.channel_type)
					end
				end
				GlobalEventSystem:Fire(MainUIEventType.CHAT_CHANGE, new_msg_info)
				--移除表头
				self.data:RemoveTempWorldList(1)
				--重新记录下次发送时间
				self.next_send_world_time = new_server_time + self.interval
			end, 0.1)
			return
		end
	end

	self.data:AddChannelMsg(msg_info)
	self:CheckToPlayVoice(msg_info)

	if msg_info.channel_type == CHANNEL_TYPE.TEAM then
		self.data:AddTeamUnreadMsg(msg_info)
		RemindManager.Instance:Fire(RemindName.GuildChatRed)
		if self.guild_chat_view:IsOpen() then
			self.guild_chat_view:Flush("new_chat", {CHANNEL_TYPE.TEAM, SPECIAL_CHAT_ID.TEAM})
		end
		MainUICtrl.Instance:FlushView("show_guild_popchat", {true})
		MainUICtrl.Instance:FlushView("flush_popchat_view", {msg_info})
	end

	if msg_info.channel_type == CHANNEL_TYPE.PRIVATE then
		if msg_info.from_uid ~= uservo.role_id then
			MainUICtrl.Instance:FlushView("flush_popchat_view", {msg_info})
		end
	end

	if msg_info.channel_type == CHANNEL_TYPE.SCENE then
		if Scene.Instance:GetSceneType() == SceneType.HotSpring then
			HotStringChatCtrl.Instance.view:Flush("chat_list")
		end
	elseif msg_info.channel_type ~= CHANNEL_TYPE.GUILD then
		if self.view:IsOpen() then
			if self.view.curr_show_channel ~= msg_info.channel_type then
				if self.view:IsLoaded() then
					self.view:ChangeChannelRedPoint(msg_info.channel_type, true)
				end
				if self.view.curr_show_channel == CHANNEL_TYPE.ALL then
					self.view:Flush(CHANNEL_TYPE.ALL)
				end
			else
				self.view:Flush(msg_info.channel_type)
			end
		end
		GlobalEventSystem:Fire(MainUIEventType.CHAT_CHANGE, msg_info)
	end



	if msg_info.channel_type == CHANNEL_TYPE.GUILD then
		local uservo = GameVoManager.Instance:GetMainRoleVo()
		if msg_info.from_uid ~= uservo.role_id then
			if not self.guild_chat_view:IsOpen() then
				if not self.guild_chat_data:GetIsHidePopRect() then
					ChatData.Instance:SetIsPopChat(true)
					MainUICtrl.Instance:FlushView("show_guild_popchat", {true})
					MainUICtrl.Instance:FlushView("flush_popchat_view", {msg_info})
				end
				MainUICtrl.Instance:FlushView("show_guildchat_redpt", {true})
			end
			--添加公会未读消息
			ChatData.Instance:AddGuildUnreadMsg(msg_info)
			RemindManager.Instance:Fire(RemindName.GuildChatRed)
		else
			if not self.guild_chat_view:IsOpen() then
				if not self.guild_chat_data:GetIsHidePopRect() then
					ChatData.Instance:SetIsPopChat(true)
					MainUICtrl.Instance:FlushView("show_guild_popchat", {true})
					MainUICtrl.Instance:FlushView("flush_popchat_view", {msg_info})
				end
				MainUICtrl.Instance:FlushView("show_guildchat_redpt", {true})
			end
			ChatData.Instance:SetNewLockState(false)
		end
		if self.guild_chat_view:IsOpen() then
			self.guild_chat_view:Flush("new_chat", {CHANNEL_TYPE.GUILD, SPECIAL_CHAT_ID.GUILD})
		end
		if ViewManager.Instance:IsOpen(ViewName.Guild) then
			ViewManager.Instance:FlushView(ViewName.Guild, "guild_maze")
		end

		GlobalEventSystem:Fire(MainUIEventType.CHAT_CHANGE, msg_info)
	end
	ViewManager.Instance:FlushView(ViewName.Main, "flush_guild_chat_icon")

end

-- 私聊消息处理
function ChatCtrl:OnSingleChat(protocol)
	self:CreateChatCell()
	self:AddPriviteMsgInData()

	-- print("私聊消息处理==========")
	if SettingData.Instance:GetSettingData(SETTING_TYPE.STRANGER_CHAT) and
		not ScoietyData.Instance:IsFriendById(protocol.role_id) then		-- 拒绝陌生私聊
		return
	end

	if ScoietyData.Instance:IsBlack(protocol.role_id) then
		return
	end

	local msg_info = ChatData.CreateMsgInfo()
	msg_info.from_uid = protocol.from_uid or 0
	msg_info.role_id = protocol.role_id or 0
	msg_info.plat_id = protocol.plat_id or 0
	msg_info.uuid = protocol.uuid or 0
	msg_info.username = protocol.username
	msg_info.sex = protocol.sex
	msg_info.camp = protocol.camp
	msg_info.prof = protocol.prof
	msg_info.authority_type = protocol.authority_type
	msg_info.content_type = protocol.content_type
	msg_info.special_param = protocol.special_param
	msg_info.level = protocol.level
	msg_info.vip_level = protocol.vip_level
	msg_info.tuhaojin_color = protocol.tuhaojin_color
	msg_info.bigchatface_status = protocol.bigchatface_status
	msg_info.channel_window_bubble_type = protocol.personalize_window_bubble_type
	msg_info.has_xianzunka_flag = protocol.has_xianzunka_flag
	msg_info.channel_type = CHANNEL_TYPE.PRIVATE
	msg_info.content = protocol.content
	msg_info.msg_timestamp = protocol.msg_timestamp or 0
	local time = msg_info.msg_timestamp > 0 and os.date("*t", msg_info.msg_timestamp) or TimeCtrl.Instance:GetServerTimeFormat()
	msg_info.send_time_str = TimeUtil.FormatTable2HMS(time)
	msg_info.use_head_frame = protocol.use_head_frame
	AvatarManager.Instance:SetAvatarKey(protocol.role_id, protocol.avatar_key_big, protocol.avatar_key_small)
	AvatarManager.Instance:SetAvatarFrameKey(protocol.role_id, protocol.use_head_frame)
	if msg_info.role_id ~= 0 and msg_info.content_type ~= CHAT_CONTENT_TYPE.AUDIO then
		msg_info.content = ChatFilter.Instance:Filter(msg_info.content)
	end
	msg_info.is_echo = protocol.is_echo
	self.data:AddPrivateUnreadMsg(msg_info)
	RemindManager.Instance:Fire(RemindName.GuildChatRed)
	ViewManager.Instance:FlushView(ViewName.Main, "flush_guild_chat_icon")

	self.data:AddPrivateMsg(protocol.role_id, msg_info)
	self.data:SetDelPriviteList(protocol.role_id, protocol.special_param or 0)

	local privite_obj = self.data:GetPrivateObjByRoleId(protocol.role_id)
	if privite_obj ~= nil then
		--记录最后聊天时间
		privite_obj.last_send_time = TimeCtrl.Instance:GetServerTime()
		privite_obj.username = protocol.username or ""
		privite_obj.level = protocol.level or 0
		self:AddPriviteObjOnLocal(privite_obj)
	end

	self:CheckToPlayVoice(msg_info)

	self.data:SetHavePriviteChat(true)
	if not self.guild_chat_view:IsOpen() then
		MainUICtrl.Instance:FlushView("show_privite_remind", {msg_info})
	else
		ViewManager.Instance:FlushView(ViewName.ChatGuild, "select_traget", {false, CHANNEL_TYPE.PRIVATE})
	end
end

function ChatCtrl:OnSingleChatUserNotExist(protocol)

end

--偶遇消息处理
function ChatCtrl:OnFakePrivateChat(protocol)
	-- print("偶遇消息处理")
end

-- 喇叭消息处理
function ChatCtrl:OnSpeaker(protocol)
	self:CreateChatCell()
	-- print("喇叭消息处理", protocol.speaker_type)
	local msg_info = ChatData.CreateMsgInfo()

	msg_info.from_uid = protocol.from_uid
	msg_info.plat_id = protocol.plat_id
	msg_info.role_id = protocol.role_id
	msg_info.username = protocol.username
	msg_info.sex = protocol.sex
	msg_info.camp = protocol.camp
	msg_info.prof = protocol.prof
	msg_info.authority_type = protocol.authority_type
	msg_info.content_type = protocol.content_type
	msg_info.level = protocol.level
	msg_info.vip_level = protocol.vip_level
	msg_info.plat_name = protocol.plat_name
	msg_info.server_id =  protocol.server_id
	msg_info.speaker_type =  protocol.speaker_type
	msg_info.tuhaojin_color = protocol.tuhaojin_color
	msg_info.bigchatface_status = protocol.bigchatface_status
	msg_info.personalize_window_type = protocol.personalize_window_type
	msg_info.channel_window_bubble_type = protocol.personalize_window_bubble_type
	msg_info.channel_type = CHANNEL_TYPE.SPEAKER
	msg_info.use_head_frame = protocol.use_head_frame
	if msg_info.speaker_type == SPEAKER_TYPE.SPEAKER_TYPE_CROSS then
		msg_info.channel_type = CHANNEL_TYPE.CROSS
	end
	msg_info.content = protocol.speaker_msg
	msg_info.send_time_str = TimeUtil.FormatTable2HMS(TimeCtrl.Instance:GetServerTimeFormat())

	AvatarManager.Instance:SetAvatarKey(protocol.from_uid, protocol.avatar_key_big, protocol.avatar_key_small)
	AvatarManager.Instance:SetAvatarFrameKey(protocol.from_uid, protocol.use_head_frame)

	if msg_info.from_uid ~= 0 then
		msg_info.content = ChatFilter.Instance:Filter(msg_info.content)
	end

	self.data:AddChannelMsg(msg_info)

	self.data:AddTransmitInfo(msg_info)

	if self.view:IsOpen() then
		if self.view.curr_show_channel ~= CHANNEL_TYPE.WORLD then
			if self.view:IsLoaded() then
				self.view:ChangeChannelRedPoint(CHANNEL_TYPE.WORLD, true)
			end
			if self.view.curr_show_channel == CHANNEL_TYPE.ALL then
				self.view:Flush(CHANNEL_TYPE.ALL)
			end
		else
			self.view:Flush(CHANNEL_TYPE.WORLD)
		end
	end

	local str = string.format("{wordcolor;ffff00;%s}: {wordcolor;00ff00;%s}", msg_info.username, msg_info.content)
	TipsCtrl.Instance:ShowSpeakerNotice(str, msg_info.speaker_type)

	GlobalEventSystem:Fire(MainUIEventType.CHAT_CHANGE, msg_info)
end

function ChatCtrl:IsShieldSystemMsg(content)
	local is_shield = false
	local i, j = string.find(content, "({.-})")
	if i and j then
		local str = string.sub(content, i+1, j-1)
		local tbl = Split(str, ";")
		if tbl[1] == "visible_level" then
			--等级限制
			local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
			if main_role_vo.level < tonumber(tbl[2] or 0) then
				is_shield = true
			end
		end
	end
	return is_shield
end

-- 系统消息处理
function ChatCtrl:OnSystemMsg(protocol)
	if IS_AUDIT_VERSION then
		return
	end
	self:CreateChatCell()
	--屏蔽一些对应限制的传闻
	if self:IsShieldSystemMsg(protocol.content) then
		return
	end

	if protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_ONLY_WORLD_QUESTION or protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_ONLY_GUILD_QUESTION then
		local msg_info = ChatData.CreateMsgInfo()
		msg_info.msg_type = protocol.msg_type
		msg_info.from_uid = 0
		msg_info.username = ""
		msg_info.sex = 0
		msg_info.camp = 0
		msg_info.prof = 0
		msg_info.authority_type = 0
		msg_info.level = 0
		msg_info.vip_level = 0
		--msg_info.channel_type = CHANNEL_TYPE.GUILD
		msg_info.channel_type = protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_ONLY_WORLD_QUESTION and CHANNEL_TYPE.WORLD_QUESTION or CHANNEL_TYPE.GUILD_QUESTION
		msg_info.content = protocol.content
		msg_info.msg_timestamp = protocol.send_time
		msg_info.send_time_str = TimeUtil.FormatTable2HMS(os.date("*t", protocol.send_time))
		self:QuestionChannelHandle(msg_info)
		return
	end

	--仙盟驻地屏蔽公告。
	if Scene.Instance:GetSceneType() == SceneType.GUILD_ANSWER_FB then
		if protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_CENTER_AND_ROLL or
			protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_CENTER_NOTICE or
			protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_CENTER_PERSONAL_NOTICE or
			protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_CENTER_NOTICE_NOT_CHAT or
			protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_CENTER_ROLL_2 or
			protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_CENTER_NOTICE_2 or
			protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_CENTER_NOTICE_3 then
			return
		end
	end

	if protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_ONLY_CHAT_GUILD then
		local msg_info = ChatData.CreateMsgInfo()
		msg_info.from_uid = 0
		msg_info.username = ""
		msg_info.sex = 0
		msg_info.camp = 0
		msg_info.prof = 0
		msg_info.authority_type = 0
		msg_info.level = 0
		msg_info.vip_level = 0
		msg_info.channel_type = CHANNEL_TYPE.GUILD_SYSTEM
		msg_info.content =protocol.content
		msg_info.msg_timestamp =protocol.send_time
		msg_info.send_time_str = TimeUtil.FormatTable2HMS(os.date("*t", protocol.send_time))
		self.data:AddChannelMsg(msg_info)
		if self.guild_chat_view:IsOpen() then
			self.guild_chat_view:Flush("new_chat", {CHANNEL_TYPE.GUILD_SYSTEM, SPECIAL_CHAT_ID.GUILD})
		end
		GlobalEventSystem:Fire(MainUIEventType.CHAT_CHANGE, msg_info)
	elseif protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_CHAT_GUILD_PERSONAL then	--添加到聊天仙盟频道个人
		local msg_info = ChatData.CreateMsgInfo()
		msg_info.from_uid = 0
		msg_info.username = ""
		msg_info.sex = 0
		msg_info.camp = 0
		msg_info.prof = 0
		msg_info.authority_type = 0
		msg_info.level = 0
		msg_info.vip_level = 0
		msg_info.channel_type = CHANNEL_TYPE.GUILD
		msg_info.content =protocol.content
		msg_info.msg_timestamp =protocol.send_time
		msg_info.send_time_str = TimeUtil.FormatTable2HMS(os.date("*t", protocol.send_time))
		self.data:AddChannelMsg(msg_info)
		if self.guild_chat_view:IsOpen() then
			self.guild_chat_view:Flush("new_chat", {CHANNEL_TYPE.GUILD, SPECIAL_CHAT_ID.GUILD})
		end
		GlobalEventSystem:Fire(MainUIEventType.CHAT_CHANGE, msg_info)
	elseif protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_ACTIVE_NOTICE then			-- 活动公告
		TipsCtrl.Instance:ShowActivityNoticeMsg(protocol.content)
	elseif protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_EVENT_TYPE_SPECIAL_NOTICE then
		TipsCtrl.Instance:ShowEventNoticeMsg(protocol.content, TIPSEVENTTYPES.SPECIAL)
	elseif protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_EVENT_TYPE_COMMON_NOTICE then
		TipsCtrl.Instance:ShowEventNoticeMsg(protocol.content, TIPSEVENTTYPES.COMMON)
	elseif protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_CENTER_NOTICE or protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_CENTER_NOTICE_NOT_CHAT
	or protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_CENTER_NOTICE_2 or protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_CENTER_NOTICE_3 then			-- 屏幕中央弹出消息
		self:AddSystemMsg(protocol.content, protocol.send_time, protocol.msg_type)
		if not self.data:GetHeadSayState() and not IS_AUDIT_VERSION then
			TipsCtrl.Instance:ShowNewSystemNotice(protocol.content)
		end
	elseif protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_CENTER_AND_ROLL or protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_CENTER_ROLL_2 then		-- 屏幕中央滚动消息
		self:AddSystemMsg(protocol.content, protocol.send_time, protocol.msg_type)
		if not self.data:GetHeadSayState() and not IS_AUDIT_VERSION then
			TipsCtrl.Instance:ShowSystemNotice(protocol.content)
		end
	elseif protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_ONLY_CHAT_WORLD then		-- 只添加到聊天世界频道
		self:AddSystemMsg(protocol.content, protocol.send_time, protocol.msg_type)
	elseif protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_CENTER_PERSONAL_NOTICE then
		TipsCtrl.Instance:ShowSystemMsg(protocol.content)
	-- elseif protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_CENTER_NOTICE_2 or protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_CENTER_PERSONAL_NOTICE then			-- 添加到系统频道+屏幕中央弹出
	-- 	self:AddSystemMsg(protocol.content, protocol.send_time, protocol.msg_type)
	-- 	if not self.data:GetHeadSayState() then
	-- 		TipsCtrl.Instance:ShowNewSystemNotice(protocol.content)
	-- 	end
	elseif protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_ACTIVITY_SPECIAL  then			-- 战场播报
		-- self:AddSystemMsg(protocol.content, protocol.send_time)
		if not self.data:GetHeadSayState() then
			TipsCtrl.Instance:OpenZhanChangBroacast(protocol.content)
		end
	end


end

function ChatCtrl:LocalNotifyGuild(content)
	local time = TimeCtrl.Instance:GetServerTime()
	local msg_info = ChatData.CreateMsgInfo()
	msg_info.from_uid = 0
	msg_info.username = ""
	msg_info.sex = 0
	msg_info.camp = 0
	msg_info.prof = 0
	msg_info.authority_type = 0
	msg_info.level = 0
	msg_info.vip_level = 0
	msg_info.channel_type = CHANNEL_TYPE.GUILD
	msg_info.origin_type = ORIGIN_TYPE.GUILD_ADDWAR_CHAT
	msg_info.content = content
	msg_info.msg_timestamp = time
	msg_info.send_time_str = TimeUtil.FormatTable2HMS(os.date("*t", time))
	self.data:AddChannelMsg(msg_info)
	if self.guild_chat_view:IsOpen() then
		self.guild_chat_view:Flush("new_chat", {CHANNEL_TYPE.GUILD, SPECIAL_CHAT_ID.GUILD})
	end
	GlobalEventSystem:Fire(MainUIEventType.CHAT_CHANGE, msg_info)
end

function ChatCtrl:OnOpenLevelLimit(protocol)
	self.data:SetChatOpenLevelLimit(protocol)
	self.data:SetChatOpenVipLevelLimit(protocol)
	self.data:SetForbidTimeInfoList(protocol.forbid_time_info_list)

	-- 是否屏蔽语音聊天
	SHIELD_VOICE = protocol.is_forbid_audio_chat ~= 0 or IS_ON_CROSSSERVER
	GlobalEventSystem:Fire(ChatEventType.VOICE_SWITCH)
	--是否禁止更换头像
	OtherData.Instance:SetForbidChangeAvatarState(protocol.is_forbid_change_avatar == 1)
	GlobalEventSystem:Fire(AvaterType.FORBID_AVATER_CHANGE)

	--是否屏蔽跨服喇叭
	TipsData.Instance:SetKuaFuLaBaState(protocol.is_forbid_cross_speaker ~= 1)
	GlobalEventSystem:Fire(ChatEventType.KF_LABA)
end

function ChatCtrl:ClearSystemTimeQuest()
	if self.system_time_quest then
		GlobalTimerQuest:CancelQuest(self.system_time_quest)
		self.system_time_quest = nil
	end
end

-- 添加一条系统消息
function ChatCtrl:AddSystemMsg(content, time, msg_type)
	local server_time = TimeCtrl.Instance:GetServerTime()
	if self.next_send_system_time < server_time then
		self.next_send_system_time = server_time + self.interval
	end
	time = time or server_time
	local msg_info = ChatData.CreateMsgInfo()
	msg_info.msg_type = msg_type or -1
	msg_info.channel_type = CHANNEL_TYPE.SYSTEM
	msg_info.username = ""
	msg_info.content = content
	msg_info.send_time_str = TimeUtil.FormatTable2HMS(os.date("*t", time))

	local function AddMsgInfo(new_msg_info)
		self.data:AddChannelMsg(new_msg_info)
		if self.view:IsOpen() then
			if self.view.curr_show_channel == CHANNEL_TYPE.ALL then
				self.view:Flush(CHANNEL_TYPE.ALL)
			else
				self.view:Flush(CHANNEL_TYPE.SYSTEM)
			end
		end
		if new_msg_info.msg_type ~= SYS_MSG_TYPE.SYS_MSG_CENTER_NOTICE_NOT_CHAT then
			GlobalEventSystem:Fire(MainUIEventType.NEW_CHAT_CHANGE, new_msg_info)
		end
		GlobalEventSystem:Fire(MainUIEventType.CHAT_CHANGE, new_msg_info)
	end

	local temp_system_list = self.data:GetTempSystemList()
	if next(temp_system_list) or (self.next_send_system_time - server_time > 0 and self.next_send_system_time - server_time < self.interval) then
		self.data:AddTempSystemList(msg_info)
		if self.system_time_quest then
			return
		end
		self.system_time_quest = GlobalTimerQuest:AddRunQuest(function()
			local new_server_time = TimeCtrl.Instance:GetServerTime()
			if self.next_send_system_time > new_server_time then
				return
			end
			if not next(temp_system_list) then
				self:ClearSystemTimeQuest()
				return
			end
			local new_msg_info = temp_system_list[1]
			AddMsgInfo(new_msg_info)
			--移除表头
			self.data:RemoveTempSystemList(1)
			--重新记录下次发送时间
			self.next_send_system_time = new_server_time + self.interval
		end, 0.1)
	else
		AddMsgInfo(msg_info)
	end
end

-- 发送频道消息
function ChatCtrl.SendChannelChat(channel_type, content, content_type)
	print("channel_type===", channel_type, content, content_type)
	if "" == content then
		return
	end

	if channel_type ~= CHANNEL_TYPE.WORLD_QUESTION and channel_type ~= CHANNEL_TYPE.GUILD_QUESTION then
		-- 被禁言不发送
		if ChatData.Instance:IsJinYan() then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.BannedToPost)
			return
		end
	end

	local protocol = ProtocolPool.Instance:GetProtocol(CSChannelChatReq)
	protocol.content_type = content_type or 0
	protocol.channel_type = channel_type
	protocol.content = content
	protocol:EncodeAndSend()

	if channel_type ~= CHANNEL_TYPE.WORLD_QUESTION and channel_type ~= CHANNEL_TYPE.GUILD_QUESTION then
		-- 是否过滤上报内容
		if ChatData.Instance:IsFilterReportContent(content) then
			return
		end

		-- 准备上报聊天记录，或者服务器来记录
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		ReportManager:Step(Report.CHAT_PRIVATE,
			main_role_vo.level,
			main_role_vo.gold,
			channel_type,
			tostring(mime.b64(content)),
			nil)

		-- 渠道聊天推送
		ReportManager:ReportChatPush(main_role_vo.server_id, main_role_vo.role_id, main_role_vo.role_name, main_role_vo.level, main_role_vo.gold, 
			channel_type, content)

		ReportManager:ReportChatMsgToSQ(main_role_vo.server_id, main_role_vo.role_name, main_role_vo.role_id, main_role_vo.level, main_role_vo.gold,
			channel_type, content, "")

		ReportManager:ReportChatMsgToAgent(main_role_vo.server_id, main_role_vo.role_name, main_role_vo.role_id, main_role_vo.level, main_role_vo.gold,
			channel_type, content, "")
	end
end

-- 发送私聊消息
function ChatCtrl.SendSingleChat(to_uid, content, content_type)
	-- print("发送私聊消息===",to_uid, content, content_type)

	local privite_obj = ChatData.Instance:GetPrivateObjByRoleId(to_uid)
	if privite_obj ~= nil then
		privite_obj.last_send_time = TimeCtrl.Instance:GetServerTime()
		ChatCtrl.Instance:AddPriviteObjOnLocal(privite_obj)
	end

	-- 被禁言不发送
	if ChatData.Instance:IsJinYan() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.BannedToPost)
		return
	end

	local protocol = ProtocolPool.Instance:GetProtocol(CSSingleChatReq)
	protocol.to_uid = to_uid
	protocol.plat_type = GameVoManager.Instance:GetMainRoleVo().plat_type -- 默认只有同服的才可以私聊
	protocol.content = content
	protocol.content_type = content_type or 0
	protocol:EncodeAndSend()


	-- 准备上报聊天记录，或者服务器来记录
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	ReportManager:Step(Report.CHAT_PRIVATE,
		main_role_vo.level,
		main_role_vo.gold,
		CHANNEL_TYPE.PRIVATE,
		tostring(mime.b64(content)),
		to_uid)


	-- 渠道聊天推送
	ReportManager:ReportChatPush(main_role_vo.server_id, main_role_vo.role_id, main_role_vo.role_name, main_role_vo.level, main_role_vo.gold, 
		CHANNEL_TYPE.PRIVATE, content, to_uid)
	


	-- 上报给神起
	-- ReportManager:ReportChatMsgToSQ(main_role_vo.server_id, main_role_vo.role_name, main_role_vo.role_id, main_role_vo.level, main_role_vo.gold,
	-- 								CHANNEL_TYPE.PRIVATE, content, to_uid)

	-- ReportManager:ReportChatMsgToAgent(main_role_vo.server_id, main_role_vo.role_name, main_role_vo.role_id, main_role_vo.level, main_role_vo.gold,
	-- 								CHANNEL_TYPE.PRIVATE, content, to_uid)


end

function ChatCtrl:SendCurrentTransmit(is_auto_buy, speaker_msg, content_type, speaker_type)
	-- 被禁言不发送
	if ChatData.Instance:IsJinYan() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.BannedToPost)
		return
	end

	local protocol = ProtocolPool.Instance:GetProtocol(CSSpeaker)
	protocol.is_auto_buy = is_auto_buy
	protocol.content_type = content_type or 0
	protocol.speaker_msg = speaker_msg
	protocol.speaker_type = speaker_type or 0
	protocol:EncodeAndSend()

	-- 准备上报聊天记录，或者服务器来记录
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	ReportManager:Step(Report.CHAT_PRIVATE,
		main_role_vo.level,
		main_role_vo.gold,
		CHANNEL_TYPE.SPEAKER,
		tostring(mime.b64(speaker_msg)),
		nil)
	-- 上报给神起
	ReportManager:ReportChatMsgToSQ(main_role_vo.server_id, main_role_vo.role_name, main_role_vo.role_id, main_role_vo.level, main_role_vo.gold,
									CHANNEL_TYPE.SPEAKER, speaker_msg, "")

	ReportManager:ReportChatMsgToAgent(main_role_vo.server_id, main_role_vo.role_name, main_role_vo.role_id, main_role_vo.level, main_role_vo.gold,
									CHANNEL_TYPE.SPEAKER, speaker_msg, "")
end

--发口令红包
function ChatCtrl:SendCreateCommandRedPaper(hb_msg)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCreateCommandRedPaper)
	protocol.hb_msg = hb_msg
	protocol:EncodeAndSend()

	-- 准备上报聊天记录，或者服务器来记录
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	ReportManager:Step(Report.CHAT_PRIVATE,
		main_role_vo.level,
		main_role_vo.gold,
		CHANNEL_TYPE.SPEAKER,
		tostring(mime.b64(hb_msg)),
		nil)

	-- 上报给神起
	ReportManager:ReportChatMsgToSQ(main_role_vo.server_id, main_role_vo.role_name, main_role_vo.role_id, main_role_vo.level, main_role_vo.gold,
									CHANNEL_TYPE.SPEAKER, hb_msg, "")

	ReportManager:ReportChatMsgToAgent(main_role_vo.server_id, main_role_vo.role_name, main_role_vo.role_id, main_role_vo.level, main_role_vo.gold,
									CHANNEL_TYPE.SPEAKER, hb_msg, "")

end

function ChatCtrl:SetChatViewData(data, is_equip)
	if self.view:IsOpen() then
		self.view:SetData(data, is_equip)
	end
end

function ChatCtrl:SetGuildViewData(data, is_equip)
	if self.guild_chat_view:IsOpen() then
		self.guild_chat_view:SetData(data, is_equip)
	end
end

function ChatCtrl:SetFace(index)
	if self.view:IsLoaded() then
		self.view:SetFace(index)
	end
end

function ChatCtrl:ChangeHearSayState(value)
	self.data:SetHeadSayState(value)
end

function ChatCtrl:ChangeLockState(state)
	ChatData.Instance:SetIsLockState(state)
	if self.view:IsLoaded() then
		self.view:ChangeLockState(state)
	end
end

function ChatCtrl:GetChatMeasuring(delegate)
	if self.view:IsOpen() then
		return self.view:GetChatMeasuring(delegate)
	end
end

function ChatCtrl:GetGuildMeasuring(delegate)
	if self.guild_chat_view:IsOpen() then
		return self.guild_chat_view:GetChatMeasuring(delegate)
	end
end

function ChatCtrl:AddTextToInput(text)
	if self.view:IsLoaded() then
		self.view:AddTextToInput(text)
	end
end

function ChatCtrl:ShowListenTrigger(state)
	if self.view:IsLoaded() then
		self.view:ShowListenTrigger(state)
	end
end

function ChatCtrl:FlushPawnView()
	if self.guild_chat_view:IsOpen() then
		self.guild_chat_view:Flush("flush_pawn_scoreview")
	end
end

--刷新群聊界面
function ChatCtrl:FlushGuildChatView( ... )
	if self.guild_chat_view:IsOpen() then
		self.guild_chat_view:Flush( ... )
	else
		local param = {...}
		if param[1] == "guild_answer" then
			MainUICtrl.Instance:FlushView("guild_shake", {true})
		elseif param[1] == "guild_qustion_result" then
			MainUICtrl.Instance:FlushView("guild_shake", {false})
			WorldQuestionData.Instance:ClearGuildList()
		end
	end
end
function ChatCtrl:FlushGuildChatViewGuildMemeberChange()
	if self.guild_chat_view:IsOpen() then
		self.guild_chat_view:Flush()
	end
end
function ChatCtrl:OpenQuickChatView(chat_type, call_back)
	if not OpenFunData.Instance:CheckIsHide("Chat") then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.ChatLevelOpen)
		return
	end
	
	self.chat_notice_view:SetQuickType(chat_type)
	self.chat_notice_view:SetCallBack(call_back)
	self.chat_notice_view:Open()
end

function ChatCtrl:ListenRoleAttrChange(key, value, old_value)
	if key == "guild_id" then
		if value <= 0 and old_value > 0 then
			--退出了公会
			self.data:RemoveNormalChatList(SPECIAL_CHAT_ID.GUILD)
			GlobalEventSystem:Fire(ChatEventType.SPECIAL_CHAT_TARGET_CHANGE, SPECIAL_CHAT_ID.GUILD, false)
			self.data:RemoveMsgToChannel(CHANNEL_TYPE.GUILD)
			self.data:ClearGuildUnreadMsg()
			MainUICtrl.Instance:FlushView("show_guildchat_redpt", {false})
			RemindManager.Instance:Fire(RemindName.GuildChatRed)
		elseif value > 0 and old_value <= 0 then
			--加入了公会
			self.data:AddNormalChatList({role_id = SPECIAL_CHAT_ID.GUILD})
			GlobalEventSystem:Fire(ChatEventType.SPECIAL_CHAT_TARGET_CHANGE, SPECIAL_CHAT_ID.GUILD, true)
		end
		ViewManager.Instance:FlushView(ViewName.Main, "flush_guild_chat_icon")
	end
end

-- 主界面创建
function ChatCtrl:MainuiOpenCreate()
	--判断是否有特殊聊天对象
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	if guild_id > 0 then
		self.data:AddNormalChatList({role_id = SPECIAL_CHAT_ID.GUILD})
		GlobalEventSystem:Fire(ChatEventType.SPECIAL_CHAT_TARGET_CHANGE, SPECIAL_CHAT_ID.GUILD, true)
	end
	local have_team = ScoietyData.Instance:GetTeamState()
	if have_team then
		self.data:AddNormalChatList({role_id = SPECIAL_CHAT_ID.TEAM})
		GlobalEventSystem:Fire(ChatEventType.SPECIAL_CHAT_TARGET_CHANGE, SPECIAL_CHAT_ID.TEAM, true)
	end
	self:CreateChatCell()
	self:CreateChuanwenCell()
	self:CreatePurchaseTextCell()
	self:CreateFallItemTextCell()
	self:CreateClientRichTex()
	self:AddPriviteMsgInData()

	--请求封禁列表
	self:ReqForbidChatInfo()
end

function ChatCtrl:EnterScene()
	TipsActivityNoticeManager.Instance:ClearCacheList()
	TipsEventNoticeManager.Instance:ClearCacheList()
end

-- function ChatCtrl:OnCloseSceneLoadingView()
-- 	if not self.first_enter_flag then
-- 		ChatData.Instance:SetAutoWorldVoice(true)
-- 		ChatData.Instance:SetAutoGuildVoice(true)
-- 		self.first_enter_flag = true
-- 	end
-- end

function ChatCtrl:FlushGuildChannel()
	if self.guild_chat_view:IsOpen() then
		self.guild_chat_view:Flush("flush_dati_view")
	end
end

function ChatCtrl:FlushGuildShenYuRank()
	if self.guild_chat_view:IsOpen() then
		self.guild_chat_view:Flush("flush_shenyu_view")
	end
end

function ChatCtrl:FlushGuildView()
	if self.guild_chat_view:IsOpen() then
		self.guild_chat_view:Flush("view")
	end
end

function ChatCtrl:OnForbidChatInfo(protocol)
	self:AddPriviteMsgInData()

	local can_refresh_guild_view = false
	for _, v in ipairs(protocol.forbid_uid_list) do
		--判断能否刷新群聊界面
		if self.guild_chat_view:IsOpen() and not can_refresh_guild_view and ChatData.Instance:GetTargetDataByRoleId(v) then
			can_refresh_guild_view = true
		end

		ChatData.Instance:ClearChannelMsgByRoleId(v)
		self:DelPriviteObjOnLocal(v)
	end

	if can_refresh_guild_view then
		self.guild_chat_view:Flush("select_traget", {true})
	end

	ViewManager.Instance:FlushView(ViewName.Main, "check_canhide_privite_remind")
end

--请求封禁列表
function ChatCtrl:ReqForbidChatInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSForbidChatInfo)
	send_protocol:EncodeAndSend()
end

-- 主角禁言时间戳
function ChatCtrl:OnForbidUserInfo(protocol)
	ChatData.Instance:SetJinYanState(protocol.forbid_talk_end_timestamp)
end

--把缓存的聊天对象存到data
function ChatCtrl:AddPriviteMsgInData()
	if not self.is_add_privite_in_data then
		self.is_add_privite_in_data = true

		self:DelAllOldPriviteObjOnLocal()

		--需要区分不同账号
		local real_role_id = CrossServerData.Instance:GetRoleId()				--获取真实id，防止在跨服聊天出问题
		real_role_id = real_role_id > 0 and real_role_id or GameVoManager.Instance:GetMainRoleVo().role_id

		--保存总聊天对象列表
		local all_list_key = real_role_id .. "_privite_obj_list"
		local privite_obj_list_json_str = PlayerPrefsUtil.GetString(all_list_key)
		if privite_obj_list_json_str == "" then
			return
		end

		--转化为表
		local privite_obj_list = cjson.decode(privite_obj_list_json_str)

		local privite_obj_json_str = ""
		local privite_obj = nil
		local msg_list = nil
		for role_key, _ in pairs(privite_obj_list) do
			privite_obj_json_str = PlayerPrefsUtil.GetString(role_key)
			if privite_obj_json_str ~= "" then
				privite_obj = cjson.decode(privite_obj_json_str)
				if not privite_obj or not next(privite_obj) then return end
				msg_list = privite_obj.msg_list or {}

				for k, v in ipairs(msg_list) do
					v.msg_id = self.data:GetMsgId()
					--设置头像key (先屏蔽，这个直接导致主界面角色自己的头像总是默认头像或者是旧的头像)
					-- AvatarManager.Instance:SetAvatarKey(v.from_uid, v.avatar_key_big or 0, v.avatar_key_small or 0, false)
				end
				self.data:AddPrivateObj(privite_obj.role_id, privite_obj)
			end
		end
		--对总聊天对象列表进行强制排序
		self.data:ForceSortNormalChatList()
	end
end

--保存私聊对象到本地
function ChatCtrl:AddPriviteObjOnLocal(privite_obj)
	if type(privite_obj) ~= "table" then
		print_error("存在错误聊天对象++++++++", privite_obj)
		return
	end

	--需要区分不同账号
	local real_role_id = CrossServerData.Instance:GetRoleId()				--获取真实id，防止在跨服聊天出问题
	real_role_id = real_role_id > 0 and real_role_id or GameVoManager.Instance:GetMainRoleVo().role_id

	--获取总聊天列表
	local all_list_key = real_role_id .. "_privite_obj_list"
	local privite_obj_list_json_str = PlayerPrefsUtil.GetString(all_list_key)
	--转化为表
	local privite_obj_list = privite_obj_list_json_str == "" and {} or cjson.decode(privite_obj_list_json_str)

	local count = 0
	local last_send_time = 9999999999
	local last_role_key = ""
	for k, v in pairs(privite_obj_list) do
		count = count + 1
		if v.last_send_time < last_send_time then
			--获取最早的聊天时间
			last_send_time = v.last_send_time
			last_role_key = k
		end
	end

	if count >= COMMON_CONSTS.MAX_PRIVITE_OBJ_NUM then
		--超过上限，把最早聊天的对象剔除掉
		privite_obj_list[last_role_key] = nil
	end

	local key = real_role_id .. "#" .. privite_obj.role_id
	privite_obj_list[key] = {num = #privite_obj.msg_list, last_send_time = privite_obj.last_send_time}

	--把聊天总索引列表转化为json字符串
	privite_obj_list_json_str = cjson.encode(privite_obj_list)
	PlayerPrefsUtil.SetString(all_list_key, privite_obj_list_json_str)										--保存总聊天对象列表

	local json_str = cjson.encode(privite_obj)
	PlayerPrefsUtil.SetString(key, json_str)																--保存单个聊天对象
end

--删除旧的缓存数据
function ChatCtrl:DelAllOldPriviteObjOnLocal()
	if not self.is_all_old_privite_obj_del then
		self.is_all_old_privite_obj_del = true

		--获取总聊天列表msg_id索引表
		local privite_obj_list_json_str = PlayerPrefsUtil.GetString("privite_obj_list")
		if privite_obj_list_json_str == "" then
			return
		end

		--转化为表
		local privite_obj_list = cjson.decode(privite_obj_list_json_str)

		for k, v in pairs(privite_obj_list) do
			PlayerPrefsUtil.DeleteKey(k)
		end
		PlayerPrefsUtil.DeleteKey("privite_obj_list")
	end
end

--删除本地私聊对象
function ChatCtrl:DelPriviteObjOnLocal(role_id)
	if nil == role_id then
		return
	end
	if nil == CrossServerData or nil == CrossServerData.Instance then
		return
	end
	--需要区分不同账号
	local real_role_id = CrossServerData.Instance:GetRoleId()				--获取真实id，防止在跨服聊天出问题
	real_role_id = real_role_id > 0 and real_role_id or GameVoManager.Instance:GetMainRoleVo().role_id

	local key = real_role_id .. "#" .. role_id
	if not PlayerPrefsUtil.HasKey(key) then
		--没有缓存该聊天对象
		return
	end

	--清除该聊天缓存对象
	PlayerPrefsUtil.DeleteKey(key)

	--获取总聊天列表msg_id索引表
	local all_list_key = real_role_id .. "_privite_obj_list"
	local privite_obj_list_json_str = PlayerPrefsUtil.GetString(all_list_key)
	if privite_obj_list_json_str == "" then
		--没有缓存不处理
		return
	end

	--转化为表
	local privite_obj_list = privite_obj_list_json_str == "" and {} or cjson.decode(privite_obj_list_json_str)
	privite_obj_list[key] = nil

	if nil == next(privite_obj_list) then
		PlayerPrefsUtil.SetString(all_list_key, "")
		return
	end

	--把聊天总索引列表转化为json字符串
	privite_obj_list_json_str = cjson.encode(privite_obj_list)
	PlayerPrefsUtil.SetString(all_list_key, privite_obj_list_json_str)
end

--客户端传闻列表（数字为秒数）
local ClientHearsayList = {
	-- [CHAT_LINK_TYPE.GODDESS_INFO] = 420,
	[CHAT_LINK_TYPE.WO_CHONGZHI] = 180,
}

function ChatCtrl:StopClientHearsayTimeQuest(key)
	for k, _ in pairs(ClientHearsayList) do
		if key == nil or key == k then
			local time_quest = self.client_hearsay_time_quest[k]
			if time_quest then
				GlobalTimerQuest:CancelQuest(time_quest)
				time_quest = nil
			end
		end
	end
end

-- 假传闻（审核服不显示）
function ChatCtrl:CreateClientRichTex()
	if not IS_AUDIT_VERSION then
		self:StopClientHearsayTimeQuest()
		for k, v in pairs(ClientHearsayList) do
			self:CreateOneClientRichText(k, v)
		end
	end
end
function ChatCtrl:CreateOneClientRichText(k, time)
	if k == CHAT_LINK_TYPE.GODDESS_INFO and TimeCtrl.Instance:GetCurOpenServerDay() > 7 then
		return
	end
	if k == CHAT_LINK_TYPE.WO_CHONGZHI and LoginGift7Data.Instance:GetLoginDay() > 7 then
		return
	end
	self.client_hearsay_time_quest[k] = GlobalTimerQuest:AddRunQuest(function()
		if k == CHAT_LINK_TYPE.GODDESS_INFO and TimeCtrl.Instance:GetCurOpenServerDay() > 7 then
			self:StopClientHearsayTimeQuest(k)
			return
		end
		if k == CHAT_LINK_TYPE.WO_CHONGZHI and LoginGift7Data.Instance:GetLoginDay() > 7 then
			self:StopClientHearsayTimeQuest(k)
			return
		end

		-- 随即名
		local rand_num = math.floor(math.random(1, 200))
		local rand_name = CommonDataManager.GetRandomName(rand_num)
		-- 随机传闻
		local rich_text = Language.ClientRichText[k]
		local content = ""
		if k == CHAT_LINK_TYPE.GODDESS_INFO then
			local xiannv_id_list = {1, 4}
			local index = math.floor(math.random(1, #xiannv_id_list))
			local id = xiannv_id_list[index]
			content = string.format(rich_text, rand_name, id, k)
		else
			content = string.format(rich_text, rand_name, k)
		end

		TipsCtrl.Instance:ShowNewSystemNotice(content)
		self:AddSystemMsg(content, TimeCtrl.Instance:GetServerTime())
	end, time)
end

function ChatCtrl:RefreshGuildFallMsg()
	if self.guild_chat_view:IsOpen() then
		self.guild_chat_view:Flush("new_chat", {CHANNEL_TYPE.GUILD_SYSTEM, SPECIAL_CHAT_ID.FALLITEM})
	end
end

function ChatCtrl:RefreshGuildChatMsg()
	if self.guild_chat_view:IsOpen() then
		self.guild_chat_view:Flush("new_chat", {CHANNEL_TYPE.GUILD_SYSTEM, SPECIAL_CHAT_ID.GUILD})
	end
end

function ChatCtrl:FulsHaoGanDu()
	if self.guild_chat_view then
		self.guild_chat_view:FlushDynamicListView()
	end
end

function ChatCtrl:OpenGuildSkillTips()
	self.guild_skill_tip:Open()
end

function ChatCtrl:DelPriviteList()
	if ChatData  and ChatData.Instance then
		for k,v in pairs(ChatData.Instance:GetDelPriviteList()) do
			ChatCtrl.Instance:DelPriviteObjOnLocal(v)
		end
	end
end