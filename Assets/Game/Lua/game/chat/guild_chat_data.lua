GuildChatData = GuildChatData or BaseClass()

-- local SHOWTIME = 12
function GuildChatData:__init()
	if GuildChatData.Instance ~= nil then
		print_error("[MagicCardData] Attemp to create a singleton twice !")
	end
	GuildChatData.Instance = self

	self.chat_num = 0
	self.is_lock = false   --是否锁定滚动条,锁定不会自动跳到底部
	self.is_hide_pop_rect = false -- 是否屏蔽气泡框
	self.show_sign = false

	-- 配置表数据
	self.guild_chats = ConfigManager.Instance:GetAutoConfig("guild_active_auto").guild_chats
	RemindManager.Instance:Register(RemindName.GuildChatRed, BindTool.Bind(self.GetGuildChatRemind, self))
	-- self:SetCountDown2()

end

function GuildChatData:__delete()
	RemindManager.Instance:UnRegister(RemindName.GuildChatRed)
	GuildChatData.Instance = nil
	self.show_sign = false

end

function GuildChatData:GetGuildChatActivityData()
	local activity_list = TableCopy(self.guild_chats)
	table.sort(activity_list, function(a, b)
		local a_id = a.activity_id
		local b_id = b.activity_id
		local a_is_open = 0
		if a_id ~= "" then
			a_is_open = ActivityData.Instance:GetActivityIsOpen(a_id) and 1 or 0
		else
			a_is_open = 1
		end
		local b_is_open = 0
		if b_id ~= "" then
			b_is_open = ActivityData.Instance:GetActivityIsOpen(b_id) and 1 or 0
		else
			b_is_open = 1
		end
		if a_is_open == b_is_open then
			local a_is_over = 0
			if a_id == "" then
				local have_num = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_GUILD_TASK_COMPLETE_COUNT) or 0
				a_is_over = have_num >= a.guild_actnum and 1 or 0
			else
				a_is_over = ActivityData.Instance:GetActivityIsOver(a_id) and 1 or 0
			end
			local b_is_over = 0
			if b_id == "" then
				local have_num = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_GUILD_TASK_COMPLETE_COUNT) or 0
				b_is_over = have_num >= b.guild_actnum and 1 or 0
			else
				b_is_over = ActivityData.Instance:GetActivityIsOver(b_id) and 1 or 0
			end
			if a_is_over == b_is_over then
				local a_is_open_today = 1
				local b_is_open_today = 1
				if a_id ~= "" then
					a_is_open_today = ActivityData.Instance:GetActivityIsInToday(a_id) and 1 or 0
				end
				if b_id ~= "" then
					b_is_open_today = ActivityData.Instance:GetActivityIsInToday(b_id) and 1 or 0
				end
				if a_is_open_today == b_is_open_today then
					local a_next_open_time = 99999999
					if a_id ~= "" then
						a_next_open_time = ActivityData.Instance:GetNextOpenTime(a_id)
					end
					local b_next_open_time = 99999999
					if b_id ~= "" then
						b_next_open_time = ActivityData.Instance:GetNextOpenTime(b_id)
					end
					return a_next_open_time < b_next_open_time
				else
					return a_is_open_today > b_is_open_today
				end
			else
				return a_is_over < b_is_over
			end
		else
			return a_is_open > b_is_open
		end
	 end)
	return activity_list
end

-- function GuildChatData:SetCountDown2()
-- 	if self.count_down2 == nil then
-- 		self:CountDownTime2(0, SHOWTIME)
-- 		self.count_down2 = CountDown.Instance:AddCountDown(SHOWTIME, 1, BindTool.Bind(self.CountDownTime2, self))
-- 	end
-- end

-- function GuildChatData:CountDownTime2(elapse_time, total_time)
-- 	local dis_time = total_time - elapse_time
-- 	if dis_time <= 0 then
-- 		self.show_sign = true
-- 		ViewManager.Instance:FlushView(ViewName.Main, "flush_guild_chat_icon")
-- 		if self.count_down2 then
-- 			if CountDown.Instance:HasCountDown(self.count_down2) then
-- 				CountDown.Instance:RemoveCountDown(self.count_down2)
-- 			end
-- 			self.count_down2 = nil
-- 		end
-- 	end
-- end

function GuildChatData:GetIsHidePopRect()
	return self.is_hide_pop_rect
end

function GuildChatData:SetIsHidePopRect(is_hide)
	self.is_hide_pop_rect = is_hide
end

function GuildChatData:GetChatNum()
	return self.chat_num
end

function GuildChatData:AddChatNum(num)
	self.chat_num = self.chat_num + num
end

function GuildChatData:SetChatNum(num)
	self.chat_num = num
end

function GuildChatData:SetIsLock(is_lock)
	self.is_lock = is_lock
end

function GuildChatData:GetIsLock()
	return self.is_lock
end

-- 通知主界面
function GuildChatData:GetGuildChatRemind()
	local num = 0
	if GameVoManager.Instance:GetMainRoleVo().guild_id <= 0 then
		--没有公会
		return num
	end

	if ChatData.Instance:HasUnreadGuildMsg() then
		num = num + 1
	end

	local unread_tream_msg_count = ChatData.Instance:GetTeamUnreadCount()
	if unread_tream_msg_count > 0 then
		num = num + 1
	end

	local private_list = ChatData.Instance:GetDynamicChatList()
	for k,v in pairs(private_list) do
		local unread_msg_count = ChatData.Instance:GetPrivateUnreadMsgCountById(v.role_id)
		if unread_msg_count > 0 then
			num = num + 1
			break
		end
	end

	return num
end

function GuildChatData:GetGuildChatUnReadNum()
	local num = 0
	if GameVoManager.Instance:GetMainRoleVo().guild_id <= 0 then
		--没有公会
		return num
	end

	local guild_unread_msg = ChatData.Instance:UnreadGuildMsgNum()
	if guild_unread_msg then
		num = guild_unread_msg
	end

	local unread_tream_msg_count = ChatData.Instance:GetTeamUnreadCount()

	num = num + unread_tream_msg_count

	local unread_private_msg_num = #ChatData.Instance:GetPrivateUnreadList()
	num = num + unread_private_msg_num

	return num
end

function GuildChatData:CheckRedPoint()
	RemindManager.Instance:Fire(RemindName.GuildChatRed)
end

function GuildChatData:SetRedShowSign(sign)
	self.show_sign = sign
end

function GuildChatData:GetRedShowSign()
	return self.show_sign
end