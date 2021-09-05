-----------------------------------聊天对象列表---------------------------------
ChatTargetItem = ChatTargetItem or BaseClass(BaseCell)
function ChatTargetItem:__init()

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.ClickClose, self))
	self.node_list["ChatTargetItem"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))

	self.remind_change = BindTool.Bind(self.GuildRemindChangeCallBack, self)
	ChatData.Instance:NotifyGuildUnreadNumRemindCallBack(self.remind_change)
end

function ChatTargetItem:__delete()
	self:UnBindIsOnlineEvent()
	self:UnBindRemind()
	if ChatData.Instance then
		ChatData.Instance:UnNotifyGuildUnreadNumRemindCallBack(self.remind_change)
	end
end

function ChatTargetItem:UnBindRemind()
	if RemindManager.Instance and self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
	end
end

function ChatTargetItem:RoleIsOnlineChange(role_id, is_online)
	if role_id == self.data.role_id then
		if self.node_list["IconImage"] and self.node_list["RawImage"] then
			UI:SetGraphicGrey(self.node_list["IconImage"], (is_online == 1))
			UI:SetGraphicGrey(self.node_list["RawImage"], (is_online == 1))
		end
	end
end

function ChatTargetItem:ClickClose()
	local role_id = self.data.role_id

	if role_id ~= SPECIAL_CHAT_ID.GUILD and role_id ~= SPECIAL_CHAT_ID.TEAM then
		local index = ChatData.Instance:GetPrivateIndex(role_id)
		ChatCtrl.Instance:DelPriviteObjOnLocal(role_id)
		ChatData.Instance:RemovePrivateObjByIndex(index)
	end

	if self.root_node.toggle.isOn then
		ChatData.Instance:SetCurrentId(-1)
	end

	--当前删除的频道类型
	local channel_type = CHANNEL_TYPE.PRIVITE
	if role_id == SPECIAL_CHAT_ID.GUILD then
		channel_type = CHANNEL_TYPE.GUILD
	elseif role_id == SPECIAL_CHAT_ID.TEAM then
		channel_type = CHANNEL_TYPE.TEAM
	end

	ViewManager.Instance:FlushView(ViewName.ChatGuild, "select_traget", {false, channel_type})
end

function ChatTargetItem:SetToggleIsOn(ison)
	local now_ison = self.root_node.toggle.isOn
	if ison == now_ison then
		return
	end
	self.root_node.toggle.isOn = ison
end

function ChatTargetItem:SetRemind(state)
	self.node_list["Notify"]:SetActive(state)
end

function ChatTargetItem:LoadAvatarCallBack(role_id, path)
	if self:IsNil() then
		return
	end

	if role_id ~= self.data.role_id then
		self.node_list["IconImage"]:SetActive(true)
		self.node_list["RawImage"]:SetActive(false)
		return
	end

	if path == nil then
		path = AvatarManager.GetFilePath(role_id, false)
	end

	self.node_list["IconImage"]:SetActive(false)
	self.node_list["RawImage"]:SetActive(true)

	GlobalTimerQuest:AddDelayTimer(function()
		self.node_list["RawImage"].raw_image:LoadURLSprite(path)
	end, 0)
end

function ChatTargetItem:UnBindIsOnlineEvent()
	if self.role_event_system then
		GlobalEventSystem:UnBind(self.role_event_system)
		self.role_event_system = nil
	end
end

function ChatTargetItem:BindIsOnlineEvent()
	--监听玩家上下线
	-- self.role_event_system = GlobalEventSystem:Bind(OtherEventType.ROLE_ISONLINE_CHANGE, BindTool.Bind(self.RoleIsOnlineChange, self))
end

function ChatTargetItem:GuildRemindChangeCallBack(remind_name, num)
	if SPECIAL_CHAT_ID.GUILD == self.data.role_id then
	-- if remind_name == RemindName.GuildChatRed or remind_name == RemindName.GuildSignin then
		local guild_unread_msg = ChatData.Instance:GetGuildUnreadMsg()
		-- local guild_chat_remind = GuildChatData.Instance:GetGuildChatRemind()
		-- local guild_sing_remind = GuildData.Instance:GetSigninRemind()
		local is_show = nil ~= guild_unread_msg and nil ~= next(guild_unread_msg) --or guild_sing_remind > 0
		self:SetRemind(is_show)
		if guild_unread_msg then
			local num = #guild_unread_msg
			if num <= 0 then
				num = ""
			elseif num > 99 then
				num = "99"
			end
			self.node_list["Text"].text.text = num
		end
		
	end
end

--刷新红点（公会有绑定不需要刷新）
function ChatTargetItem:FlushRemind()
	local role_id = self.data.role_id
	local function remind_change(msg_count)
		if msg_count > 0 and not self.root_node.toggle.isOn then
			self:SetRemind(true)
			self.node_list["Text"].text.text = msg_count
		else
			self:SetRemind(false)
		end
	end

	if role_id == SPECIAL_CHAT_ID.TEAM then
		local unread_msg_count = ChatData.Instance:GetTeamUnreadCount()
		remind_change(unread_msg_count)
	elseif role_id > SPECIAL_CHAT_ID.ALL then
		local unread_msg_count = ChatData.Instance:GetPrivateUnreadMsgCountById(role_id)
		remind_change(unread_msg_count)
	end
end

function ChatTargetItem:OnFlush()
	self:UnBindRemind()
	if not self.data then
		return
	end

	local good_opinion = ScoietyData.Instance:GetFriendGoodOpinion(self.data.role_id)
	if good_opinion > 0 then
		self.node_list["HaoGanDu"]:SetActive(true)
		local level, favorable_impression_show, need_favorable_impression,next_level = ScoietyData.Instance:GetFriendHaoGanDu(good_opinion)
		local star_num = ScoietyData.Instance:GetFriendStarNum(level)
		for i = 1, 3 do
			local bundle, asset = ResPath.GetChatRes("img_haodandu".. favorable_impression_show)
			local bundle1, asset1 =  ResPath.GetChatRes("img_prohaogandu".. favorable_impression_show)
			self.node_list["img_haodandu" .. i].image:LoadSprite(bundle, asset, function()
						self.node_list["img_haodandu" .. i].image:SetNativeSize()
					end)
			self.node_list["pro_fill" .. i].image:LoadSprite(bundle1, asset1, function()
						-- self.node_list["pro_fill" .. i].image:SetNativeSize()
					end)
		end
		if star_num == 1 then
			self.node_list["GoodSlider1"].slider.value = ((good_opinion - need_favorable_impression) / (next_level - need_favorable_impression))
			self.node_list["GoodSlider2"].slider.value = 0
			self.node_list["GoodSlider3"].slider.value = 0
		elseif star_num == 2  then
			self.node_list["GoodSlider1"].slider.value = 1
			self.node_list["GoodSlider2"].slider.value = ((good_opinion - need_favorable_impression )/(next_level- need_favorable_impression))
			self.node_list["GoodSlider3"].slider.value = 0
		elseif star_num ==  3 then
			self.node_list["GoodSlider1"].slider.value = 1
			self.node_list["GoodSlider2"].slider.value = 1
			self.node_list["GoodSlider3"].slider.value = ((good_opinion - need_favorable_impression )/(next_level- need_favorable_impression))
		elseif star_num == 4 then
			self.node_list["GoodSlider1"].slider.value = 1
			self.node_list["GoodSlider2"].slider.value = 1
			self.node_list["GoodSlider3"].slider.value = 1
	end
	else
		self.node_list["HaoGanDu"]:SetActive(false)
	end

	if nil ~= self.data.is_online then
		UI:SetGraphicGrey(self.node_list["IconImage"], (is_online == 1))
		UI:SetGraphicGrey(self.node_list["RawImage"], (is_online == 1))
	else
		UI:SetGraphicGrey(self.node_list["IconImage"], (is_online == 1))
		UI:SetGraphicGrey(self.node_list["RawImage"], (is_online == 1))
	end

	local name = ""
	self.node_list["BtnClose"]:SetActive(false)
	local role_id = self.data.role_id
	if role_id == SPECIAL_CHAT_ID.GUILD then

		--增加红点绑定
		RemindManager.Instance:Bind(self.remind_change, RemindName.GuildChatRed)
		RemindManager.Instance:Bind(self.remind_change, RemindName.GuildSignin)

		local guild_unread_msg = ChatData.Instance:GetGuildUnreadMsg()
		local guild_remind = RemindManager.Instance:GetRemind(RemindName.GuildChatRed)
		if nil == guild_unread_msg and guild_remind == 0 and self.root_node.toggle.isOn then
			self:SetRemind(false)
		else
			self:SetRemind(true)
		end
		local vo = GameVoManager.Instance:GetMainRoleVo()
		if AvatarManager.Instance:isDefaultImg(vo.guild_id, true) == 0 then 
			local bundle, asset = ResPath.GetChatGuildBadgeIcon()
			self.node_list["IconImage"].image:LoadSprite(bundle, asset)
			self.node_list["IconImage"]:SetActive(true)
			self.node_list["RawImage"]:SetActive(false)
			AvatarManager.Instance:CancelSetAvatar(self.node_list["RawImage"])

		elseif AvatarManager.Instance:isDefaultImg(vo.guild_id,true) ~= 0 then 
			local path = AvatarManager.GetFilePath(vo.guild_id, true, true)
			self.node_list["RawImage"].raw_image:LoadURLSprite(path)
			self.node_list["IconImage"]:SetActive(false)
			self.node_list["RawImage"]:SetActive(true)
			AvatarManager.Instance:CancelSetAvatar(self.node_list["RawImage"])
		end	

		name = GameVoManager.Instance:GetMainRoleVo().guild_name
	elseif role_id == SPECIAL_CHAT_ID.TEAM then
		--队伍
		self.node_list["IconImage"]:SetActive(true)
		self.node_list["RawImage"]:SetActive(false)
		self.node_list["IconImage"].image:LoadSprite(ResPath.GetChatRes("left_info_team"))
		name = Language.Society.TeamDes
		AvatarManager.Instance:CancelSetAvatar(self.node_list["RawImage"])
	else

		self.node_list["BtnClose"]:SetActive(true)

		AvatarManager.Instance:SetAvatar(role_id, self.node_list["RawImage"], self.node_list["IconImage"], self.data.sex, self.data.prof, false)
	
		name = self.data.username
		CommonDataManager.SetAvatarFrame(role_id, self.node_list["TouXiangKuang"], self.node_list["BgKuang"])
	end
	local good_opinion = ScoietyData.Instance:GetFriendGoodOpinion(self.data.role_id)


	self.node_list["TxtName"].text.text = name

	--好感度

end