require("game/chat/chat_team_view")
require("game/chat/chat_world_view")
require("game/chat/chat_system_view")
require("game/chat/chat_compre_view")
require("game/chat/chat_question_view")

ChatView = ChatView or BaseClass(BaseView)

local SPEED = 50

local MOVE_TIME = 0.3
local MOVE_DISTANCE = -800
local UILayer = GameObject.Find("GameRoot/UILayer")

function ChatView:__init()
	self.ui_config = {{"uis/views/chatview_prefab", "ChatView"}}
	self.close_mode = CloseMode.CloseVisible
	self.curr_send_channel = CHANNEL_TYPE.ALL	-- 发送频道
	self.curr_show_channel = CHANNEL_TYPE.ALL	-- 显示频道

	self.last_flush_redpoint_time = 0
	self.open_tween = self.ShowFadeUp
	self.close_tween = self.HideFadeUp
end

function ChatView:ReleaseCallBack()
	if self.team_view then
		self.team_view:DeleteMe()
		self.team_view = nil
	end
	if self.world_view then
		self.world_view:DeleteMe()
		self.world_view = nil
	end
	if self.system_view then
		self.system_view:DeleteMe()
		self.system_view = nil
	end
	if self.compre_view then
		self.compre_view:DeleteMe()
		self.compre_view = nil
	end

	if self.question_view then
		self.question_view:DeleteMe()
		self.question_view = nil
	end

	if self.chat_measuring then
		ResMgr:Destroy(self.chat_measuring.root_node.gameObject)
		self.chat_measuring:DeleteMe()
		self.chat_measuring = nil
	end

	if self.switch_handle ~= nil then
		GlobalEventSystem:UnBind(self.switch_handle)
		self.switch_handle = nil
	end

	self:RemoveDelayTime()
end

function ChatView:LoadCallBack()


	local event_trigger = self.node_list["ListenTrigger"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnTriggerChange, self))

	-- 监听UI事件
	self.node_list["Block"].button:AddClickListener(BindTool.Bind(self.HandleClose, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.HandleClose, self))

	self.node_list["BtnSpeaker"].button:AddClickListener(BindTool.Bind(self.HandleOpenSpeaker, self))
	self.node_list["BtnBlack"].button:AddClickListener(BindTool.Bind(self.HandleOpenBlackList, self))
	self.node_list["BtnItem"].button:AddClickListener(BindTool.Bind(self.HandleOpenItem, self))
	self.node_list["BtnShop"].button:AddClickListener(BindTool.Bind(self.HandleOpenShop, self))
	self.node_list["BtnLocation"].button:AddClickListener(BindTool.Bind(self.HandleInsertLocation, self))

	local etl = self.node_list["BtnVoice"]:GetOrAddComponent(typeof(EventTriggerListener))
	etl:AddPointerDownListener(BindTool.Bind(self.HandleVoiceStart, self))
	etl:AddPointerUpListener(BindTool.Bind(self.HandleVoiceStop, self))
	self.switch_handle = GlobalEventSystem:Bind(ChatEventType.VOICE_SWITCH, BindTool.Bind(self.UpdateVoiceSwitch, self))
	self:UpdateVoiceSwitch()


	self.node_list["BtnRedPackage"].button:AddClickListener(BindTool.Bind(self.HandleOpenRedPackage, self))
	self.node_list["WorldTipsPanel"].button:AddClickListener(BindTool.Bind(self.ClickChatChannelUnreadTip, self, CHANNEL_TYPE.WORLD))
	self.node_list["TeamTipsPanel"].button:AddClickListener(BindTool.Bind(self.ClickChatChannelUnreadTip, self, CHANNEL_TYPE.TEAM))
	--self.node_list["Channel"].dropdown.onValueChanged:AddListener(BindTool.Bind(self.HandleChangeChannel, self))
	self.node_list["BtnEmoji"].button:AddClickListener(BindTool.Bind(self.HandleOpenEmoji, self))
	self.node_list["BtnSend"].button:AddClickListener(BindTool.Bind(self.HandleSend, self))
	self.node_list["BtnVoiceSetting"].button:AddClickListener(BindTool.Bind(self.VoiceSettingClick, self))
	self.node_list["BtnNotice"].button:AddClickListener(BindTool.Bind(self.OpenNotice, self))
	self.node_list["TabAll"].toggle:AddClickListener(BindTool.Bind(self.HandleSwitchCompre, self))
	self.node_list["TabWorld"].toggle:AddClickListener(BindTool.Bind(self.HandleSwitchWorld, self))
	self.node_list["TabTeam"].toggle:AddClickListener(BindTool.Bind(self.HandleSwitchTeam, self))
	self.node_list["TabSystem"].toggle:AddClickListener(BindTool.Bind(self.HandleSwitchSystem, self))
	self.node_list["TabQuestion"].toggle:AddClickListener(BindTool.Bind(self.HandleSwitchQuestion, self))
	self.node_list["TabChat"].toggle:AddClickListener(BindTool.Bind(self.HandleChat, self))
	-- self.node_list["ChatInput"].input_field.onValueChanged:AddListener(BindTool.Bind(self.OnChangeInputText, self))	-- 没光标先屏蔽
	self.node_list["ChatInput"].input_field.onEndEdit:AddListener(BindTool.Bind(self.HandleSend, self))			-- 输入完直接发送内容

	self.node_list["VoiceToggle"].toggle:AddClickListener(BindTool.Bind(self.ToggleOnClick, self))

	self.team_view = ChatTeamView.New(self.node_list["ContentTeam"])
	self.world_view = ChatWorldView.New(self.node_list["ContentWorld"])
	self.system_view = ChatSystemView.New(self.node_list["ContentSystem"])
	self.compre_view = ChatCompreView.New(self.node_list["ContentAll"])
	self.question_view = ChatQuestionView.New(self.node_list["ContentQuestion"])

	if self.node_list["LockAni"].animator then
		self.node_list["LockAni"].animator:ListenEvent("LockState", BindTool.Bind(self.LockState, self))
	end

	if self.world_view then
		self.world_view:SetListenerCallBack(BindTool.Bind(self.RefreshWorldUnreadTips, self))
	end

	if self.team_view then
		self.team_view:SetListenerCallBack(BindTool.Bind(self.RefreshTeamUnreadTips, self))
	end
end


function ChatView.ShowFadeUp(self)
	self.root_parent.transform.anchoredPosition = Vector3(MOVE_DISTANCE, 0, 0)

	local tween = self.root_parent.transform:DOAnchorPosX(0, MOVE_TIME)
	tween:SetEase(DG.Tweening.Ease.Linear)

	return tween
end

function ChatView.HideFadeUp(self)
	self.root_parent.transform.anchoredPosition = Vector3(0, 0, 0)

	local tween = self.root_parent.transform:DOAnchorPosX(MOVE_DISTANCE, MOVE_TIME)
	tween:SetEase(DG.Tweening.Ease.Linear)

	return tween
end

function ChatView:ToggleOnClick()
	local state = ChatData.Instance:GetAutoWorldVoice()
	local ani_state = self.node_list["VoiceToggle"].toggle.isOn

	local new_state = not state
	ChatData.Instance:SetAutoWorldVoice(new_state)
	self.node_list["VoiceToggle"].toggle.isOn = new_state
end

function ChatView:RefeshSetting()
	local state = ChatData.Instance:GetAutoWorldVoice()
	self.node_list["VoiceToggle"].toggle.isOn = state
	ChatData.Instance:SetAutoWorldVoice(state)
end

function ChatView:HandleChat()
	if not OpenFunData.Instance:CheckIsHide("Chat") then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.ChatLevelOpen)
		return
	end

	local privateobj_list = ChatData.Instance:GetPrivateObjList()
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	local have_team = ScoietyData.Instance:GetTeamState()

	--没公会没队伍也没有私聊对象
	if guild_id <= 0 and not have_team and #privateobj_list <= 0 then
		ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_request)
		return
	end
	ViewManager.Instance:Open(ViewName.ChatGuild)
end

-- 根据渠道开启语音聊天
function ChatView:UpdateVoiceSwitch()
	if self.node_list["Voice"] then
		self.node_list["Voice"]:SetActive(not SHIELD_VOICE)
	end
	if self.node_list["VoicePlay"] then
		self.node_list["VoicePlay"]:SetActive(not SHIELD_VOICE)
	end
end

function ChatView:OnTriggerChange(data)
	if data.delta.y > 0 then
		ChatData.Instance:SetCanSendVoice(false)
	end
end

function ChatView:VoiceSettingClick()
	ViewManager.Instance:Open(ViewName.VoiceSetting)
end

function ChatView:LockState(value)
	local is_lock = tonumber(value) == 1 and true or false
	ChatData.Instance:SetIsLockState(is_lock)

end

function ChatView:GetChatMeasuring(delegate)
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

function ChatView:ChangeLockState(state)

end

function ChatView:CloseCallBack()
	if self.item_call_back then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_call_back)
		self.item_call_back = nil
	end
	if self.role_attr_change_event then
		PlayerData.Instance:UnlistenerAttrChange(self.role_attr_change_event)
		self.role_attr_change_event = nil
	end

	self.str_list = {}
	AudioPlayer.Stop()		--停止播放语音
	AudioService.Instance:SetMasterVolume(1.0)
	self:ClearBtnCountDown()
	ChatData.Instance:SetIsLockState(false)
end

function ChatView:AddNotice(str)
	self.total_count = self.total_count + 1
	self.str_list[self.total_count] = str
end

function ChatView:ItemChangeCallBack(item_id)
	if self.last_flush_redpoint_time + 0.5 <= Status.NowTime then
		self:ChangeBubbleRedPoint()
		self.last_flush_redpoint_time = Status.NowTime
	else
		self:RemoveDelayTime()
		self.delay_time = GlobalTimerQuest:AddDelayTimer(function() self:ChangeBubbleRedPoint() end, 0.5)
	end
end

function ChatView:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

--清除按钮倒计时
function ChatView:ClearBtnCountDown()
	if self.button_count_down then
		CountDown.Instance:RemoveCountDown(self.button_count_down)
		self.button_count_down = nil
	end
end

function ChatView:ChangeBubbleRedPoint()
	--设置气泡红点
	if self.node_list and self.node_list["ImgBubbleRed"] then
		local state = CoolChatData.Instance:GetCoolChatRedPoint()
		self.node_list["ImgBubbleRed"]:SetActive(state)
	end
end

function ChatView:ChangeButtonEnable()
	self:ClearBtnCountDown()
	local function timer_func(elapse_time, total_time)
		if elapse_time >= total_time or (not self.node_list["TabWorld"].toggle.isOn and not self.node_list["TabAll"].toggle.isOn and not self.node_list["TabSystem"].toggle.isOn) then
			self:ClearBtnCountDown()
			self.node_list["TxtBtn"].text.text = Language.Chat.Send
			UI:SetButtonEnabled(self.node_list["BtnSend"], true)
			return
		end
		self.node_list["TxtBtn"].text.text = string.format(Language.Chat.ResetTimes, total_time - math.floor(elapse_time))
		UI:SetButtonEnabled(self.node_list["BtnSend"], false)
	end
	if (self.node_list["TabWorld"].toggle.isOn or self.node_list["TabAll"].toggle.isOn or self.node_list["TabSystem"].toggle.isOn or self.node_list["TabQuestion"].toggle.isOn) and
		(self.curr_send_channel == CHANNEL_TYPE.WORLD or self.curr_send_channel == CHANNEL_TYPE.ALL) then
		if not ChatData.Instance:GetChannelCdIsEnd(CHANNEL_TYPE.WORLD) then
			local time = ChatData.Instance:GetChannelCdEndTime(CHANNEL_TYPE.WORLD) - Status.NowTime
			time = math.ceil(time)
			UI:SetButtonEnabled(self.node_list["BtnSend"], false)
			self.node_list["TxtBtn"].text.text = string.format(Language.Chat.ResetTimes, time)
			self.button_count_down = CountDown.Instance:AddCountDown(time, 1, timer_func)
		else
			self.node_list["TxtBtn"].text.text = Language.Chat.Send
			UI:SetButtonEnabled(self.node_list["BtnSend"], true)
		end
	else
		self.node_list["TxtBtn"].text.text = Language.Chat.Send
		UI:SetButtonEnabled(self.node_list["BtnSend"], true)
	end
end

function ChatView:OpenCallBack()
	ChatData.Instance:ClearChatChannelUnreadMsg(CHANNEL_TYPE.WORLD)
	ChatData.Instance:ClearChatChannelUnreadMsg(CHANNEL_TYPE.TEAM)
	self:ChangeButtonEnable()
	local is_lock = ChatData.Instance:GetIsLockState()
	self:ChangeLockState(is_lock)

	self:ChangeBubbleRedPoint()
	self:RefeshSetting()
	self:UpdateVoiceSwitch()

	--监听物品变化
	self.item_call_back = BindTool.Bind(self.ItemChangeCallBack, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_call_back)
	ChatCtrl.Instance:ChangeLockState(false)
	-- self.role_attr_change_event = BindTool.Bind1(self.OnRoleAttrValueChange, self)
	-- PlayerData.Instance:ListenerAttrChange(self.role_attr_change_event)
	-- self:OpenLevelLimitHorn()

	self.node_list["RightBar"]:SetActive(not IS_AUDIT_VERSION)
	self.node_list["FunctionRow"]:SetActive(not IS_AUDIT_VERSION)
end

-- 喇叭开启
-- function ChatView:OpenLevelLimitHorn()
	-- local level = PlayerData.Instance:GetRoleLevel()
	-- local is_can_speaker = ChatData.Instance:IsCanChat(CHAT_OPENLEVEL_LIMIT_TYPE.SPEAKER, true)
	-- if self.show_horn then
	-- 	self.show_horn:SetValue(is_can_speaker)
	-- 	if is_can_speaker then
	-- 		self:ChangePanelHeightMax()
	-- 	else
	-- 		self:ChangePanelHeightMin()
	-- 	end
	-- end
-- end

-- function ChatView:OnRoleAttrValueChange(key, new_value, old_value)
-- 	if key == "level" or key == "vip_level" then
-- 		self:OpenLevelLimitHorn()
-- 	end
-- end

function ChatView:ShowIndexCallBack(index)
	if index == TabIndex.chat_world then
		self.node_list["TabWorld"].toggle.isOn = true
		self:HandleSwitchWorld()
	elseif index == TabIndex.chat_team then
		self.node_list["TabTeam"].toggle.isOn = true
		self:HandleSwitchTeam()
	elseif index == TabIndex.chat_system then
		self.node_list["TabSystem"].toggle.isOn = true
		self:HandleSwitchSystem()
	elseif index == TabIndex.chat_compre then
		self.node_list["TabAll"].toggle.isOn = true
		self:HandleSwitchCompre()
	elseif index == TabIndex.chat_question then
		self.node_list["TabQuestion"].toggle.isOn = true
		self:HandleSwitchQuestion()
	else
		self:ChangeToIndex(TabIndex.chat_world)
	end
end

function ChatView:HandleClose()
	if AutoVoiceCtrl.Instance.view:IsOpen() then
		return
	end
	ViewManager.Instance:Close(ViewName.Chat)
end

function ChatView:HandleSwitchTeam()
	self.curr_show_channel = CHANNEL_TYPE.TEAM
	self.curr_send_channel = CHANNEL_TYPE.TEAM
	self:ChangeChannelRedPoint(self.curr_show_channel, false)
	-- self.node_list["Channel"].dropdown.value = 1				-- 干掉
	self.team_view:FlushTeamView()
	self:HandleChangeChannel(1)
end

function ChatView:HandleSwitchWorld()
	self.curr_show_channel = CHANNEL_TYPE.WORLD
	self.curr_send_channel = CHANNEL_TYPE.WORLD
	self:ChangeChannelRedPoint(self.curr_show_channel, false)
	-- self.node_list["Channel"].dropdown.value = 0				-- 干掉
	self.world_view:FlushWorldView()
	self:HandleChangeChannel(0)
end

function ChatView:HandleSwitchSystem()
	self.curr_show_channel = CHANNEL_TYPE.SYSTEM
	self.curr_send_channel = CHANNEL_TYPE.WORLD
	self.system_view:FlushSystemView()
end

function ChatView:HandleSwitchQuestion()
	self.curr_show_channel = CHANNEL_TYPE.WORLD_QUESTION
	self.curr_send_channel = CHANNEL_TYPE.WORLD
	self.question_view:FlushQuestionView()
	self:HandleChangeChannel(0)
end

function ChatView:HandleSwitchChat()
	--self.channel.dropdown.interactable = true
	self:HandleSwitchCompre()
end

function ChatView:HandleSwitchCompre()
	self.curr_show_channel = CHANNEL_TYPE.ALL
	self.curr_send_channel = CHANNEL_TYPE.WORLD
	self.compre_view:FlushCompreView()
end

function ChatView:HandleOpenSpeaker()
	TipsCtrl.Instance:ShowSpeakerView()
end

function ChatView:HandleOpenBlackList()
	ScoietyCtrl.Instance:ShowBlackListView()
end

function ChatView:HandleOpenItem()
	TipsCtrl.Instance:ShowPropView()
end

function ChatView:HandleOpenShop()
	if not OpenFunData.Instance:CheckIsHide("CoolChat") then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.ChatLevelOpen)
		return
	end
	ViewManager.Instance:Open(ViewName.CoolChat)
end

--获取人物当前坐标
function ChatView:GetMainRolePos()
	local main_role = Scene.Instance.main_role

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
		if self.curr_send_channel == CHANNEL_TYPE.WORLD then
		 	if not ChatData.Instance:IsCanChat(CHAT_OPENLEVEL_LIMIT_TYPE.WORLD) then
				ChatData.Instance:ClearInput()
				return
			end

			if not ChatData.Instance:GetChannelCdIsEnd(self.curr_send_channel) then
				local time = ChatData.Instance:GetChannelCdEndTime(self.curr_send_channel) - Status.NowTime
				SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Chat.CanNotChat, math.ceil(time)))
				return
			end
		
			local level = GameVoManager.Instance:GetMainRoleVo().level
			self.node_list["TabWorld"].toggle.isOn = true
			self:HandleSwitchWorld()
			ChatData.Instance:SetChannelCdEndTime(self.curr_send_channel)
			self:ChangeButtonEnable()
		elseif self.curr_send_channel == CHANNEL_TYPE.TEAM then
		
			--是否组队
			if not ScoietyData.Instance.have_team then
				SysMsgCtrl.Instance:ErrorRemind(Language.Society.CreateTeam)
				return
			else
				if not ChatData.Instance:IsCanChat(CHAT_OPENLEVEL_LIMIT_TYPE.TEAM) then
					ChatData.Instance:ClearInput()
					return
				end
				self.node_list["TabTeam"].toggle.isOn = true
				self:HandleSwitchTeam()
			end
		end

		local scene_id = Scene.Instance:GetSceneId()
		local msg = "{point;".. Scene.Instance:GetSceneName() .. ";" .. x .. ";" .. y .. ";" .. scene_id .. ";" .. scene_key .. "}"
		ChatCtrl.SendChannelChat(self.curr_send_channel, msg, CHAT_CONTENT_TYPE.TEXT)
		ChatCtrl.Instance:ChangeLockState(false)
	end
end

function ChatView:HandleInsertLocation()
	if not OpenFunData.Instance:CheckIsHide("Chat") then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.ChatLevelOpen)
		return
	end
	self:GetMainRolePos()
end

function ChatView:HandleVoiceStart()
	if not OpenFunData.Instance:CheckIsHide("Chat") then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.ChatLevelOpen)
		return
	end
	if self.curr_send_channel == CHANNEL_TYPE.WORLD then
		if not ChatData.Instance:GetChannelCdIsEnd(self.curr_send_channel) then
			local time = ChatData.Instance:GetChannelCdEndTime(self.curr_send_channel) - Status.NowTime
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Chat.CanNotChat, math.ceil(time)))
			return
		end

		local level = PlayerData.Instance:GetRoleLevel()
		--等级限制
		-- if level < ChatData.Instance:GetChatOpenLevel(CHAT_OPENLEVEL_LIMIT_TYPE.WORLD) then
		-- 	local level_str = PlayerData.GetLevelString(ChatData.Instance:GetChatOpenLevel(CHAT_OPENLEVEL_LIMIT_TYPE.WORLD))
		-- 	SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Chat.LevelDeficient, level_str))
		-- 	return
		-- else
			self.node_list["TabWorld"].toggle.isOn = true
			self:HandleSwitchWorld()
		-- end
	elseif self.curr_send_channel == CHANNEL_TYPE.TEAM then
		--是否组队
		if not ScoietyData.Instance:GetTeamState() then
			SysMsgCtrl.Instance:ErrorRemind(Language.Society.CreateTeam)
			return
		else
			self.node_list["TabTeam"].toggle.isOn = true
			self:HandleSwitchTeam()
		end
	else
		print_error("HandleChangeChannel with unknow index:", self.curr_send_channel)
		return
	end
	ChatData.Instance:SetCanSendVoice(true)
	AutoVoiceCtrl.Instance:ShowVoiceView(self.curr_send_channel)
end

function ChatView:HandleVoiceStop()
	if AutoVoiceCtrl.Instance.view:IsOpen() then
		AutoVoiceCtrl.Instance.view:Close()
	end
end

function ChatView:ShowListenTrigger(state)
	self.node_list["ListenTrigger"]:SetActive(state)
end

function ChatView:HandleOpenRedPackage()
	local main_role = GameVoManager.Instance:GetMainRoleVo()
	if main_role.guild_id <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NotEnterGuild)
		return
	end
	HongBaoCtrl.Instance:ShowHongBaoView(GameEnum.HONGBAO_SEND, RED_PAPER_TYPE.RED_PAPER_TYPE_COMMON)
end

function ChatView:HandleChangeChannel(index)
	if index == 0 then
		self.curr_send_channel = CHANNEL_TYPE.WORLD
	elseif index == 1 then
		self.curr_send_channel = CHANNEL_TYPE.TEAM
	else
		print_error("HandleChangeChannel with unknow index:", index)
	end
	self:ChangeButtonEnable()
end

function ChatView:AddTextToInput(text)
	if text and self.node_list["ChatInput"] and self.node_list["ChatInput"].gameObject.activeInHierarchy then
		local edit_text = self.node_list["ChatInput"].input_field.text
		self.node_list["ChatInput"].input_field.text = edit_text .. text
	end
end

function ChatView:HandleOpenEmoji()
	local function callback(face_id)
		self:SetFace(face_id)
	end
	TipsCtrl.Instance:ShowExpressView(callback)
end

function ChatView:OpenNotice()
	local function callback(str)
		if self.curr_send_channel == CHAT_OPENLEVEL_LIMIT_TYPE.TEAM then
			if not ScoietyData.Instance.have_team then
				SysMsgCtrl.Instance:ErrorRemind(Language.Society.CreateTeam)
				self.node_list["ChatInput"].input_field.text = ""
				ChatData.Instance:ClearInput()
				return
			else
				if not ChatData.Instance:IsCanChat(CHAT_OPENLEVEL_LIMIT_TYPE.TEAM) then
					ChatData.Instance:ClearInput()
					return
				end
				self.node_list["TabTeam"].toggle.isOn = true
				self:HandleSwitchTeam()
			end
			ChatData.Instance:AddToHistoryMsgList(str)
			ChatCtrl.SendChannelChat(self.curr_send_channel, str, CHAT_CONTENT_TYPE.TEXT)
		else
			if not ChatData.Instance:GetChannelCdIsEnd(CHANNEL_TYPE.WORLD) then
				SysMsgCtrl.Instance:ErrorRemind(Language.Chat.WorldChatCD)
				return 
			end
			local level = GameVoManager.Instance:GetMainRoleVo().level
			self.node_list["TabWorld"].toggle.isOn = true
			self:HandleSwitchWorld()
			
			if not ChatData.Instance:IsCanChat(CHAT_OPENLEVEL_LIMIT_TYPE.WORLD) then
				return
			end
			--设置世界聊天冷却时间
			ChatData.Instance:SetChannelCdEndTime(self.curr_send_channel)
			self:ChangeButtonEnable()
			ChatData.Instance:AddToHistoryMsgList(str)
			ChatCtrl.SendChannelChat(self.curr_send_channel, str, CHAT_CONTENT_TYPE.TEXT)
			ChatCtrl.Instance:ChangeLockState(false)
		end

	end
	ChatCtrl.Instance:OpenQuickChatView(QUICK_CHAT_TYPE.NORMAL, callback)
end

local input_text_list = {}
local input_index = 0
local input_cur_text = ""
function ChatView:HandleSend()
	local text = self.node_list["ChatInput"].input_field.text
	local content_type = CHAT_CONTENT_TYPE.TEXT
	if text == "" then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NilContent)
		self.node_list["ChatInput"].input_field.text = ""
		ChatData.Instance:ClearInput()
		return
	end

	local len = string.len(text)
	if len > 1 and string.sub(text, 1, 1) == "/" and (string.find(text, "gm") or string.find(text, "cmd")) then
		if len >= 3 and string.sub(text, 1, 3) == "/gm" then
			local blank_begin, blank_end = string.find(text, " ")
			local colon_begin, colon_end = string.find(text, ":")
			if blank_begin and blank_end and colon_begin and colon_end then
				local cmd_type = string.sub(text, blank_end + 1, colon_begin - 1)
				local command = string.sub(text, colon_end + 1, -1)
				SysMsgCtrl.SendGmCommand(cmd_type, command)
			end
		elseif len >= 4 and string.sub(text, 1 , 5) == "/cmd " then
			local blank_begin, blank_end = string.find(text, " ")
			if blank_begin and blank_end then
				ClientCmdCtrl.Instance:Cmd(string.sub(text, blank_end + 1, len))
			end
		end
	else
		if not OpenFunData.Instance:CheckIsHide("Chat") then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.ChatLevelOpen)
			return
		end
		--格式化字符串
		text = ChatData.Instance:FormattingMsg(text, content_type)

		-- 有非法字符直接不让发
		if ChatFilter.Instance:IsIllegal(text, false) then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.IllegalContent)
			ChatData.Instance:ClearInput()
			return
		end

		-- 协议返回不过滤，改用发送的时候过滤
		text = ChatFilter.Instance:Filter(text)

		if self.curr_send_channel == CHANNEL_TYPE.WORLD then
			if not ChatData.Instance:IsCanChat(CHAT_OPENLEVEL_LIMIT_TYPE.WORLD) then
				ChatData.Instance:ClearInput()
				return
			end
			self.node_list["TabWorld"].toggle.isOn = true
			self:HandleSwitchWorld()

			--设置世界聊天冷却时间
			ChatData.Instance:SetChannelCdEndTime(self.curr_send_channel)
			self:ChangeButtonEnable()
		elseif self.curr_send_channel == CHANNEL_TYPE.TEAM then
			--是否组队
			if not ScoietyData.Instance.have_team then
				SysMsgCtrl.Instance:ErrorRemind(Language.Society.CreateTeam)
				self.node_list["ChatInput"].input_field.text = ""
				ChatData.Instance:ClearInput()
				return
			else
				if not ChatData.Instance:IsCanChat(CHAT_OPENLEVEL_LIMIT_TYPE.TEAM) then
					ChatData.Instance:ClearInput()
					return
				end
				self.node_list["TabTeam"].toggle.isOn = true
				self:HandleSwitchTeam()
			end
		else
			print_error("HandleChangeChannel with unknow index:", self.curr_send_channel)
			self.node_list["ChatInput"].input_field.text = ""
			ChatData.Instance:ClearInput()
			return
		end

		-- 发送文字信息
		self:ChangeLockState(false)
		ChatCtrl.SendChannelChat(self.curr_send_channel, text, content_type)
		ChatData.Instance:AddToHistoryMsgList(text)
		ChatCtrl.Instance:ChangeLockState(false)
		self.node_list["ChatInput"].input_field.text = ""
		ChatData.Instance:ClearInput()
		return
	end

	self.node_list["ChatInput"].input_field.text = ""
	input_index = 0

	if text ~= "" and text ~= input_text_list[1] then
		for i,v in ipairs(input_text_list) do
			if text == v then
				table.remove(input_text_list, i)
				break
			end
		end
		table.insert(input_text_list, 1, text)
	end

	if #input_text_list > 10 then
		table.remove(input_text_list)
	end

	-- 屏蔽掉输入文字发送后不再继续弹出输入键盘
	-- self.node_list["ChatInput"].input_field:ActivateInputField()
	ChatData.Instance:ClearInput()
end

function ChatView:HandleInputUp()
	if input_index == 0 then
		input_cur_text = self.node_list["ChatInput"].input_field.text
	end

	if nil ~= input_text_list[input_index + 1] then
		input_index = input_index + 1
		self.node_list["ChatInput"].input_field.text = input_text_list[input_index]
	end
end

function ChatView:HandleInputDown()
	if nil ~= input_text_list[input_index - 1] then
		input_index = input_index - 1
		self.node_list["ChatInput"].input_field.text = input_text_list[input_index]
	else
		input_index = 0
		self.node_list["ChatInput"].input_field.text = input_cur_text
	end
end

--添加物品
function ChatView:SetData(data, is_equip)
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

-- 添加表情
function ChatView:SetFace(index)
	local face_id = string.format("%03d", index)
	local edit_text = self.node_list["ChatInput"].input_field
	if edit_text and ChatData.ExamineEditText(edit_text.text, 3) then
		self.node_list["ChatInput"].input_field.text = edit_text.text .. "/" .. face_id
		ChatData.Instance:InsertFaceTab(face_id)
	end
end

function ChatView:FlushNowView()
	if self.node_list["TabWorld"].toggle.isOn then
		self.world_view:FlushWorldView()
	elseif self.node_list["TabTeam"].toggle.isOn then
		self.team_view:FlushTeamView()
	elseif self.node_list["TabSystem"].toggle.isOn then
		self.system_view:FlushSystemView()
	elseif self.node_list["TabAll"].toggle.isOn then
		self.compre_view:FlushCompreView()
	end
end

function ChatView:ChangeChannelRedPoint(channel_type, value)
	if channel_type == CHANNEL_TYPE.WORLD then
		self.node_list["ImgWorldRed"]:SetActive(value)
	elseif channel_type == CHANNEL_TYPE.TEAM then
		self.node_list["ImgTeamdRed"]:SetActive(value)
	end
end

function ChatView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == CHANNEL_TYPE.WORLD then
			if self.node_list["TabWorld"].toggle.isOn then
				self.world_view:FlushWorldView()
			end
		elseif k == CHANNEL_TYPE.TEAM then
			if self.node_list["TabTeam"].toggle.isOn then
				self.team_view:FlushTeamView()
			end
		elseif k == CHANNEL_TYPE.SYSTEM then
			if self.node_list["TabSystem"].toggle.isOn then
				self.system_view:FlushSystemView()
			end
		elseif k == CHANNEL_TYPE.ALL then
			if self.node_list["TabAll"].toggle.isOn then
				self.compre_view:FlushCompreView()
			end
		elseif k == CHANNEL_TYPE.WORLD_QUESTION then
			if self.node_list["TabQuestion"].toggle.isOn then
				self.question_view:FlushQuestionView()
			end
		end
	end
end

function ChatView:OnChangeInputText()
	local text = self:PackageeText(self.node_list["ChatInput"].input_field.text)
	RichTextUtil.ParseRichText(self.node_list["InpuntContent"].rich_text, text, nil)
end

-- 封装Text
function ChatView:PackageeText(text)
	local face_tab = {}
	local function pack_face(str)
		face_tab[#face_tab + 1] = {}
		local i, j = string.find(text, str)
		face_tab[#face_tab].str = str
		face_tab[#face_tab].face_id = string.sub(str, 2, 4)
	end

	string.gsub(text, "/%d%d%d", pack_face)
	for k, v in pairs(face_tab) do
		text = string.gsub(text, v.str, "{face;" .. v.face_id .. "}")
	end

	return text
end

function ChatView:RefreshWorldUnreadTips()
	local unread_msg_count = ChatData.Instance:GetChatChannelUnreadMsg(CHANNEL_TYPE.WORLD) or {}

	if #unread_msg_count <= 0 then
		self.node_list["WorldTipsPanel"]:SetActive(false)
		self.node_list["WorldTipsText"].text.text = ""
		ChatData.Instance:ClearChatChannelUnreadMsg(CHANNEL_TYPE.WORLD)
	else
		self.node_list["WorldTipsPanel"]:SetActive(true)
		self.node_list["WorldTipsText"].text.text = string.format(Language.Chat.WeiDu, #unread_msg_count)
	end
end

function ChatView:RefreshTeamUnreadTips()
	local unread_msg_count = ChatData.Instance:GetChatChannelUnreadMsg(CHANNEL_TYPE.TEAM) or {}

	if #unread_msg_count <= 0 then
		self.node_list["TeamTipsPanel"]:SetActive(false)
		self.node_list["TeamTipsText"].text.text = ""
		ChatData.Instance:ClearChatChannelUnreadMsg(CHANNEL_TYPE.TEAM)
	else
		self.node_list["TeamTipsPanel"]:SetActive(true)
		self.node_list["TeamTipsText"].text.text = string.format(Language.Chat.WeiDu, #unread_msg_count)
	end
end

function ChatView:ClickChatChannelUnreadTip(channel_type)
	ChatData.Instance:ClearChatChannelUnreadMsg(channel_type)
	if CHANNEL_TYPE.WORLD == channel_type and self.world_view then
		self.world_view:FlushUnreadState()
	elseif CHANNEL_TYPE.TEAM == channel_type and self.team_view then
		self.team_view:FlushUnreadState()
	end
end



