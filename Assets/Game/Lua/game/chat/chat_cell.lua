ChatCell = ChatCell or BaseClass(BaseCell)

--可以展示频道标签
local CanShowChannel =
{
	[CHANNEL_TYPE.ALL] = true,
	[CHANNEL_TYPE.GUILD] = true,
	[CHANNEL_TYPE.WORLD] = true,
	[CHANNEL_TYPE.SYSTEM] = true,
	[CHANNEL_TYPE.WORLD_QUESTION] = true,
}

-- 设置ContentLeft,ContentRight,BubbleSlotLeft,BubbleSlotRight位置
-- 从对象池中拿出来的时候会被重置位置
local PrePosition = 
{
	ContentLeft = 95,
	ContentRight = -95,
	ContentHight = -50,
	BubbleSlotLeft = 95,
	BubbleSlotRight = -95,
	BubbleSlotHight = -55,
}


function ChatCell:__init()
	self.touch_down_time = 0
	self.avatar_key = 0
	self.old_msg_id = -1
	self.is_special_bubble = false
	self.is_easy = false 											--简单设置数据模式(计算高度用)
	self.main_chat_flag = false

	local ImgIconL = self.node_list["ImgIconL"].gameObject:GetOrAddComponent(typeof(EventTriggerListener))
	ImgIconL:AddPointerUpListener(BindTool.Bind(self.ClickRoleUp, self))
	ImgIconL:AddPointerDownListener(BindTool.Bind(self.ClickRoleDown, self))

	local ImgIconR = self.node_list["ImgIconR"].gameObject:GetOrAddComponent(typeof(EventTriggerListener))
	ImgIconR:AddPointerUpListener(BindTool.Bind(self.ClickRoleUp, self))
	ImgIconR:AddPointerDownListener(BindTool.Bind(self.ClickRoleDown, self))

end

function ChatCell:__delete()
	if self.pre_content_list then
		for k,v in pairs(self.pre_content_list) do
			ResPoolMgr:Release(v.gameObject)
		end
		self.pre_content_list = nil
	end

	if self.pre_bubble_list then
		for k,v in pairs(self.pre_bubble_list) do
			ResPoolMgr:Release(v.gameObject)
		end
		self.pre_bubble_list = nil
	end

	self.voice_obj = nil
	self.content_obj = nil
	self.voice_animator = nil
	self.avatar_key = 0
	self.old_msg_id = -1
end

--添加文本到聊天框
function ChatCell:AddChatToInput()
	GlobalTimerQuest:CancelQuest(self.icon_time_quest)
	self.icon_time_quest = nil
	if not self.data or not next(self.data) then
		return
	end
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local text = "@" .. self.data.username
	if self.data.from_uid == 0 or main_role_id == self.data.from_uid then
		return
	elseif self.data.channel_type == CHANNEL_TYPE.SCENE then
		HotStringChatCtrl.Instance:AddTextToInput(text)
	else
		ChatCtrl.Instance:AddTextToInput(text)
	end
end

function ChatCell:SetMainChatFlag()
	self.main_chat_flag = true
end

function ChatCell:GetMainChatFlag()
	return self.main_chat_flag
end

function ChatCell:ClickRoleDown()
	--记录点下的时间
	self.touch_down_time = Status.NowTime
	self.icon_time_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind1(self.AddChatToInput, self), 1)
end

function ChatCell:ClickRoleUp()
	GlobalTimerQuest:CancelQuest(self.icon_time_quest)
	self.icon_time_quest = nil
	if Status.NowTime - self.touch_down_time < 1 then
		self:ClickRoleIcon()
	end
end

function ChatCell:ClickRoleIcon()
	if not self.data or not next(self.data) or self.is_echo == 1 then
		return
	end
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if self.data.from_uid == 0 or (main_role_vo.plat_type == self.data.plat_id and main_role_vo.plat_role_id == self.data.role_id) then
		return
	elseif self.data.channel_type ~= CHANNEL_TYPE.SCENE then
		local open_type = ScoietyData.DetailType.Default
		local uuid = CommonStruct.UUID()
		uuid.role_id = self.data.role_id
		uuid.plat_type = self.data.plat_id
		ScoietyCtrl.Instance:ShowOperateListGlobal(open_type, uuid, nil, nil, nil, self.main_chat_flag)
	end
end

--统一设置头像是否显示，太多setactive了
function ChatCell:JudgeState(result)
	if nil == result then
		result = true
	end

	self.node_list["ImgPorLeft"]:SetActive(result)
	self.node_list["ImgPorRight"]:SetActive(result)
	self.node_list["RawLeftImg"]:SetActive(not result)
	self.node_list["RawRightImg"]:SetActive(not result)
end

function ChatCell:SetEasy(state)
	self.is_easy = state
end

function ChatCell:OnFlush()
	if not self.data or not next(self.data) then
		return
	end

	self.old_role_id = self.role_id or 0
	self.role_id = self.data.role_id or 0
	self.from_uid = self.data.from_uid
	self.content = self.data.content
	self.content_type = self.data.content_type
	self.send_time_str = self.data.send_time_str
	self.channel_type = self.data.channel_type
	self.is_special = self.data.is_special or false
	self.is_echo = self.data.is_echo 						-- 用来区分杀人后私聊对话位置

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local main_role_id = main_role_vo.role_id
	local main_role_id_t = main_role_vo.main_role_id_t
	if self.data.origin_type ~= ORIGIN_TYPE.GUILD_ADDWAR_CHAT and self.data.origin_type ~= ORIGIN_TYPE.ORIGIN_TYPE_GUILD_SYSTEM_MSG then
		self.is_left = not (self.role_id == main_role_id or main_role_id_t[self.role_id]) and self.is_echo ~= 1
	else
		self.is_left = true
	end

	if self.is_easy then
		self:LoadWindow(main_role_id)
		self.is_easy = false
		return
	end

	self.node_list["SpecialView"]:SetActive(self.is_special)
	if self.is_special then
		self.node_list["LeftView"]:SetActive(false)
		self.node_list["RightView"]:SetActive(false)
		self.node_list["TxtSpecial"].text.text = Language.Society.ChatObjOutLine
		return
	end

	--设置发送时间
	self.node_list["TxtTimeL"].text.text = self.send_time_str
	self.node_list["TxtTimeR"].text.text = self.send_time_str

	--设置属性
	if self.data.origin_type ~= ORIGIN_TYPE.GUILD_ADDWAR_CHAT and self.data.origin_type ~= ORIGIN_TYPE.ORIGIN_TYPE_GUILD_SYSTEM_MSG then -- 仙盟增战传闻名字限制
		if self.is_echo == 1 then
			if self.data.sex == 1 then
				self.node_list["TxtNameL"].text.text = string.format("<color='#d0d8ff'>%s</color>", self.data.username)
				self.node_list["TxtNameR"].text.text = string.format("<color='#d0d8ff'>%s</color>", main_role_vo.name)
			elseif self.data.sex == 2 then
				self.node_list["TxtNameL"].text.text = string.format("<color='#cb74d0'>%s</color>", self.data.username)
				self.node_list["TxtNameR"].text.text = string.format("<color='#cb74d0'>%s</color>", main_role_vo.name)
			else
				self.node_list["TxtNameL"].text.text = self.data.username
				self.node_list["TxtNameR"].text.text = main_role_vo.name
			end
		else
			if self.data.sex == 1 then
				self.node_list["TxtNameL"].text.text = string.format("<color='#d0d8ff'>%s</color>", self.data.username)
				self.node_list["TxtNameR"].text.text = string.format("<color='#d0d8ff'>%s</color>", self.data.username)
			elseif self.data.sex == 2 then
				self.node_list["TxtNameL"].text.text = string.format("<color='#cb74d0'>%s</color>", self.data.username)
				self.node_list["TxtNameR"].text.text = string.format("<color='#cb74d0'>%s</color>", self.data.username)
			else
				self.node_list["TxtNameL"].text.text = self.data.username
				self.node_list["TxtNameR"].text.text = self.data.username
			end
		end
	else
		self.node_list["TxtNameL"].text.text = ""
	end
		
	local is_active_immt = false
	if self.data.has_xianzunka_flag ~= nil then
		is_active_immt = bit:_and(1, bit:_rshift(self.data.has_xianzunka_flag, 2)) ~= 0
	end
	--设置vip展示
	if self.is_echo == 1 then
		local vip_level = main_role_vo.vip_level or 0
		local is_show_vip = true
		vip_level = IS_AUDIT_VERSION and 0 or vip_level
		if vip_level <= 0 then
			is_show_vip = false
		end
		self.node_list["ImmortalL"]:SetActive(is_active_immt)
		self.node_list["ImmortalR"]:SetActive(is_active_immt)
		self.node_list["ImgVipL"]:SetActive(is_show_vip)
		self.node_list["ImgVipR"]:SetActive(is_show_vip)
		if is_show_vip then
			self.node_list["ImgVipL"].image:LoadSprite(ResPath.GetVipLevelIcon(vip_level))
			self.node_list["ImgVipR"].image:LoadSprite(ResPath.GetVipLevelIcon(vip_level))
		end
	else
		local vip_level = self.data.vip_level or 0
		local is_show_vip = true
		vip_level = IS_AUDIT_VERSION and 0 or vip_level
		if vip_level <= 0 then
			is_show_vip = false
		end

		self.node_list["ImgVipL"]:SetActive(is_show_vip and self.data.origin_type ~= ORIGIN_TYPE.GUILD_ADDWAR_CHAT and self.data.origin_type ~= ORIGIN_TYPE.ORIGIN_TYPE_GUILD_SYSTEM_MSG)
		self.node_list["ImgVipR"]:SetActive(is_show_vip)
		self.node_list["ImmortalL"]:SetActive(is_active_immt and self.data.origin_type ~= ORIGIN_TYPE.GUILD_ADDWAR_CHAT and self.data.origin_type ~= ORIGIN_TYPE.ORIGIN_TYPE_GUILD_SYSTEM_MSG)
		self.node_list["ImmortalR"]:SetActive(is_active_immt)
		if is_show_vip then
			self.node_list["ImgVipL"].image:LoadSprite(ResPath.GetVipLevelIcon(vip_level))
			self.node_list["ImgVipR"].image:LoadSprite(ResPath.GetVipLevelIcon(vip_level))
		end
	end
	

	local msg_id = self.data.msg_id
	--相同文本相同msg_id不处理
	if msg_id ~= self.old_msg_id then
		self.old_msg_id = msg_id
		self:LoadWindow(main_role_id)
	end

	local function SetIconImage(raw_img_obj, image_res)
		local base_prof = PlayerData.Instance:GetRoleBaseProf(self.data.prof)
		--先显示默认图片
		self.node_list["TouXiangKuang1"].image.enabled = false
		self.node_list["TouXiangKuang2"].image.enabled = false
		if not self.role_id or self.role_id == 0 then
			self.avatar_key = 0
			local bundle, asset = ResPath.GetRoleIconBig(100) -- 系统头像
			image_res.image:LoadSprite(bundle, asset)
			self:JudgeState(true)
			AvatarManager.Instance:CancelSetAvatar(raw_img_obj)
			return
		end

		if self.data.channel_type == CHANNEL_TYPE.SCENE then
			self.avatar_key = 0
			local bundle, asset = AvatarManager.GetDefAvatar(base_prof, false, self.data.sex)
			image_res.image:LoadSprite(bundle, asset)
			self:JudgeState(true)
			AvatarManager.Instance:CancelSetAvatar(raw_img_obj)
			return
		end
		if self.data.origin_type ~= ORIGIN_TYPE.GUILD_ADDWAR_CHAT and self.data.origin_type ~= ORIGIN_TYPE.ORIGIN_TYPE_GUILD_SYSTEM_MSG then --帮派增战传闻头像框限制
			if self.is_echo == 1 then
				AvatarManager.Instance:SetAvatar(main_role_id, raw_img_obj, image_res, main_role_vo.sex, main_role_vo.prof, false)
				CommonDataManager.SetAvatarFrame(main_role_id, self.node_list["TouXiangKuang1"], self.node_list["BgKuang1"])
				CommonDataManager.SetAvatarFrame(main_role_id, self.node_list["TouXiangKuang2"], self.node_list["BgKuang2"])
			else
				local avatar_key = AvatarManager.Instance:GetAvatarKey(self.role_id)
				if avatar_key == 0 then
					self.avatar_key = 0
					local bundle, asset = AvatarManager.GetDefAvatar(base_prof, false, self.data.sex)
					image_res.image:LoadSprite(bundle, asset)
					self:JudgeState(true)
					AvatarManager.Instance:CancelSetAvatar(raw_img_obj)
				else
					if avatar_key ~= self.avatar_key then
						self.avatar_key = avatar_key
						AvatarManager.Instance:SetAvatar(self.role_id, raw_img_obj, image_res, self.data.sex, self.data.prof, false)
					end
				end
				CommonDataManager.SetAvatarFrame(self.role_id, self.node_list["TouXiangKuang1"], self.node_list["BgKuang1"])
				CommonDataManager.SetAvatarFrame(self.role_id, self.node_list["TouXiangKuang2"], self.node_list["BgKuang2"])
			end
		end
		
		
	end

	--发送位置展示（左/右）
	local raw_img_obj = self.node_list["RawLeftImg"]
	local img_res = self.node_list["ImgPorLeft"]
	


	local post = GuildData.Instance:GetGuildPost(self.data.role_id)
	if not self.role_id or self.role_id == 0 then
		--系统展示
		self.is_left = true

		self.node_list["LeftView"]:SetActive(true)
		self.node_list["RightView"]:SetActive(false)
		self.node_list["SystemImageLeft"]:SetActive(true)
		self.node_list["SystemImageRight"]:SetActive(false)
		self.node_list["LeftBg"]:SetActive(false)
		self.node_list["LeftPoint"]:SetActive(false)
		self.node_list["RightPoint"]:SetActive(false)
		self.node_list["BgKuang1"]:SetActive(false)
	elseif self.data.origin_type == ORIGIN_TYPE.GUILD_ADDWAR_CHAT and post == GuildDataConst.GUILD_POST.TUANGZHANG or self.data.origin_type == ORIGIN_TYPE.ORIGIN_TYPE_GUILD_SYSTEM_MSG then
		self.is_left = true
		self.node_list["LeftView"]:SetActive(true)
		self.node_list["RightView"]:SetActive(false)
		self.node_list["SystemImageLeft"]:SetActive(true)
		self.node_list["SystemImageRight"]:SetActive(false)
		self.node_list["LeftBg"]:SetActive(false)
		self.node_list["LeftPoint"]:SetActive(false)
		self.node_list["RightPoint"]:SetActive(false)
		self.node_list["BgKuang1"]:SetActive(false)
	else
		self.node_list["LeftPoint"]:SetActive(true)
		self.node_list["RightPoint"]:SetActive(true)
		self.node_list["SystemImageLeft"]:SetActive(false)
		self.node_list["SystemImageRight"]:SetActive(false)
		if not self.is_left then
			self.is_left = false
			self.node_list["LeftView"]:SetActive(false)
			self.node_list["RightView"]:SetActive(true)
			self.node_list["RightBg"]:SetActive(true)
			raw_img_obj = self.node_list["RawRightImg"]
			img_res = self.node_list["ImgPorRight"]
		else
			self.is_left = true
			self.node_list["LeftView"]:SetActive(true)
			self.node_list["RightView"]:SetActive(false)
			self.node_list["LeftBg"]:SetActive(true)
		end
	end
	SetIconImage(raw_img_obj, img_res)

	--设置频道图片
	local curr_show_channel = ChatCtrl.Instance.view.curr_show_channel
	if self.channel_type ~= CHANNEL_TYPE.SCENE and CanShowChannel[curr_show_channel] then
		
		self.node_list["ImgL"]:SetActive(true)
		self.node_list["ImgR"]:SetActive(true)

		self.node_list["AnswerL"]:SetActive(false)
		self.node_list["AnswerR"]:SetActive(false)

		local bundle, asset = ResPath.GetA2ChatLableIcon("word")
		local title_text = Language.Channel[self.data.channel_type or 0]

		if self.data.channel_type == CHANNEL_TYPE.WORLD then
			bundle, asset = ResPath.GetA2ChatLableIcon("word")
		elseif self.data.channel_type == CHANNEL_TYPE.TEAM then
			bundle, asset = ResPath.GetA2ChatLableIcon("team")
		elseif self.channel_type == CHANNEL_TYPE.WORLD_QUESTION then
			bundle, asset = ResPath.GetA2ChatLableIcon("dati")
		elseif self.data.channel_type == CHANNEL_TYPE.GUILD then
			bundle, asset = ResPath.GetA2ChatLableIcon("guild")

			if self.data.is_answer_true == 1 then
				self.node_list["AnswerL"]:SetActive(true)
				self.node_list["AnswerR"]:SetActive(true)
			else
				self.node_list["AnswerL"]:SetActive(false)
				self.node_list["AnswerR"]:SetActive(false)
			end
			self.node_list["AnswerL"].transform:SetAsLastSibling()
			self.node_list["AnswerR"].transform:SetAsLastSibling()
		elseif self.data.channel_type == CHANNEL_TYPE.SYSTEM then
			bundle, asset = ResPath.GetA2ChatLableIcon("system")
		elseif self.channel_type == CHANNEL_TYPE.GUILD_SYSTEM then
			bundle, asset = ResPath.GetA2ChatLableIcon("system")
		elseif self.data.channel_type == CHANNEL_TYPE.PRIVATE then
			bundle, asset = ResPath.GetA2ChatLableIcon("private")
		elseif self.data.channel_type == CHANNEL_TYPE.SPEAKER then
			bundle, asset = ResPath.GetA2ChatLableIcon("speaker")
		elseif self.data.channel_type == CHANNEL_TYPE.CROSS then
			bundle, asset = ResPath.GetA2ChatLableIcon("cross")
		end
		if self.data.channel_type == CHANNEL_TYPE.GUILD and self.data.origin_type == ORIGIN_TYPE.GUILD_ADDWAR_CHAT then -- 工会聊天特殊处理
			bundle, asset = ResPath.GetA2ChatLableIcon("system")
		end
		if self.data.channel_type == CHANNEL_TYPE.GUILD_SYSTEM and self.data.origin_type == ORIGIN_TYPE.ORIGIN_TYPE_GUILD_SYSTEM_MSG then
			bundle, asset = ResPath.GetA2ChatLableIcon("system")
		end
		self.node_list["ImgL"].image:LoadSprite(bundle, asset)
		self.node_list["ImgR"].image:LoadSprite(bundle, asset)
	else
		self.node_list["ImgL"]:SetActive(false)
		self.node_list["ImgR"]:SetActive(false)

		self.node_list["AnswerL"]:SetActive(false)
		self.node_list["AnswerR"]:SetActive(false)
	end
end

function ChatCell:GetContentHeight()
	local height = self.root_node:GetComponent(typeof(UnityEngine.RectTransform)).rect.height

	local rect = self.content_obj:GetComponent(typeof(UnityEngine.RectTransform))
	--强制刷新
	UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(rect)

	local y = rect.localPosition.y
	local des_height = rect.rect.height

	local transform = self.content_obj.transform:Find("ChatBg")
	local bg_size_y = 40
	if transform ~= nil then
		local bg_rect = transform:GetComponent(typeof(UnityEngine.RectTransform))
		bg_size_y = bg_rect.sizeDelta.y
	end

	-- print("原始默认高度=", height, "RichText高度=", des_height, "背景图高度(相对于RichText)=", bg_rect.sizeDelta.y, "文本=", self.content)

	local content_height = height/2 - y + des_height + bg_size_y / 2
	-- print("计算后的高度为=", content_height)
	return content_height
end

function ChatCell:ClickCallBack(callback, file_name)
	if callback then
		callback(file_name)
	end
end

function ChatCell:ChangeVoiceAni(state)
	if not IsNil(self.voice_animator) then
		self.voice_animator:SetBool("play", state)
	end
end

function ChatCell:AddVoiceBtn(rich_text, play_time, is_left, callback, file_name, fees_audio_content, parm_color)
	RichTextUtil.ClearRichText(rich_text)

	local time = 0
	if "table" == type(play_time) then
		time = play_time[3]
	else
		time = play_time
	end

	local btn_name = is_left and "VioceButtonLeft" or "VioceButtonRight"
	self.voice_obj = ResPoolMgr:TryGetGameObject("uis/views/miscpreload_prefab", btn_name)

	local name_table = self.voice_obj:GetComponent(typeof(UINameTable))

	
	local time_node = U3DObject(name_table:Find("TxtTime"))
	time_node.text.text = time
	rich_text:AddObject(self.voice_obj)

	local btn_node = U3DObject(name_table:Find("VioceButton"))
	if self.content_type == CHAT_CONTENT_TYPE.FEES_AUDIO then
		btn_node.button:AddClickListener(BindTool.Bind(self.ClickCallBack, self, callback, file_name))

		local color = ""
		if self.data and self.data.tuhaojin_color and self.data.tuhaojin_color > 0 then
			color = CoolChatData.Instance:GetTuHaoJinColorByIndex(self.data.tuhaojin_color)
		else
			color = parm_color or COLOR.WHITE
		end
		rich_text:AddText(ToColorStr(fees_audio_content, color))
	else
		btn_node.button:AddClickListener(BindTool.Bind(self.ClickCallBack, self, callback, file_name))
	end

	self.voice_animator = self.voice_obj:GetComponent(typeof(UnityEngine.Animator))
end

function ChatCell:SetContent(rich_text, is_left, parm_color)
	--是否语音
	if self.content_type == CHAT_CONTENT_TYPE.AUDIO then
		local str = self.content
		local tbl = {}
		for i = 1, 3 do
			local j, k = string.find(str, "(%d+)")
			local num = string.sub(str, j, k)
			str = string.gsub(str, num, "num")
			table.insert(tbl, num)
		end

		local callback = BindTool.Bind(self.PlayOrStopVoice, self)
		self:AddVoiceBtn(rich_text, tbl, is_left, callback, self.content)
		return
	elseif self.content_type == CHAT_CONTENT_TYPE.FEES_AUDIO then
		local content_t = Split(self.content, "_")
		if #content_t ~= 3 then
			return
		end
		local callback = BindTool.Bind(self.PlayOrStopFeesVoice, self)
		self:AddVoiceBtn(rich_text, content_t[3], is_left, callback, content_t[1], content_t[2], parm_color)
		return
	end

	local color = ""
	if self.data and self.data.tuhaojin_color and self.data.tuhaojin_color > 0 then
		color = CoolChatData.Instance:GetTuHaoJinColorByIndex(self.data.tuhaojin_color)
	else
		color = parm_color or COLOR.WHITE
	end
	RichTextUtil.ParseRichText(rich_text, self.content, nil, color)
end

function ChatCell:PlayOrStopVoice(file_name)
	ChatCtrl.Instance:ClearPlayVoiceList()
	ChatCtrl.Instance:SetStartPlayVoiceState(false)
	local call_back = BindTool.Bind(self.ChangeVoiceAni, self)
	ChatRecordMgr.Instance:PlayVoice(file_name, call_back, call_back)
end

function ChatCell:PlayOrStopFeesVoice(file_id)
	ChatCtrl.Instance:ClearPlayVoiceList()
	ChatCtrl.Instance:SetStartPlayVoiceState(false)
	local call_back = BindTool.Bind(self.ChangeVoiceAni, self)
	AudioService.Instance:PlayFeesAudio(file_id, call_back)
end

--加载聊天框
function ChatCell:LoadWindow(main_role_id)
	self.content_obj = nil

	local assetbundle = "uis/views/chatview_prefab"
	local prefab_name = ""
	local left = self.is_left 
	local bubble_type = self.data.channel_window_bubble_type
	bubble_type = bubble_type or -1
	bubble_type = bubble_type + 1
	
	-- if main_role_id == self.role_id then
	-- 	left = false
	-- end
	if self.is_echo == 1 then
		bubble_type = CoolChatData.Instance:GetSelectSeq() + 1
	elseif self.data.origin_type == ORIGIN_TYPE.GUILD_ADDWAR_CHAT or self.data.origin_type == ORIGIN_TYPE.ORIGIN_TYPE_GUILD_SYSTEM_MSG then
		bubble_type = 0
	else
		bubble_type = bubble_type
	end
	if bubble_type == -1 then bubble_type = 0 end
	self.is_special_bubble = false
	local obj = nil
	local not_bubble = not bubble_type or bubble_type == 0
	local is_scene_channel = self.data.channel_type and self.data.channel_type == CHANNEL_TYPE.SCENE

	if nil ~= self.bubble_obj then
		ResMgr:Destroy(self.bubble_obj)
		self.bubble_obj = nil
	end

	if is_scene_channel or not_bubble then
		
		local left_content_obj = nil
		local right_content_obj = nil

		if nil == self.pre_content_list then
			assetbundle = "uis/views/miscpreload_prefab"
			left_content_obj = self:CreateChatContent(assetbundle, "ContentLeft")
			left_content_obj.transform:SetLocalPosition(PrePosition.ContentLeft, PrePosition.ContentHight, 0)
			left_content_obj.transform:SetParent(self.node_list["LeftView"].transform, false)
			right_content_obj = self:CreateChatContent(assetbundle, "ContentRight")
			right_content_obj.transform:SetLocalPosition(PrePosition.ContentRight, PrePosition.ContentHight, 0)
			right_content_obj.transform:SetParent(self.node_list["RightView"].transform, false)

			self.pre_content_list = {["ContentLeft"] = left_content_obj, ["ContentRight"] = right_content_obj}
		else
			left_content_obj = self.pre_content_list["ContentLeft"]
			right_content_obj = self.pre_content_list["ContentRight"]
		end

		-- 如果气泡框存在的情况，隐藏气泡框
		if nil ~= self.pre_bubble_list then
			for k,v in pairs(self.pre_bubble_list) do
				v:SetActive(false)
			end
		end

		left_content_obj:SetActive(left)
		right_content_obj:SetActive(not left)



		self.content_obj = left and left_content_obj or right_content_obj
	else  -- 特殊气泡框只加载容器
		local left_bubble_obj = nil
		local right_bubble_obj = nil

		if nil == self.pre_bubble_list then
			assetbundle = "uis/views/miscpreload_prefab"
			left_bubble_obj = self:CreateChatContent(assetbundle, "BubbleSlotLeft")
			left_bubble_obj.transform:SetLocalPosition(PrePosition.BubbleSlotLeft, PrePosition.BubbleSlotHight, 0)
			left_bubble_obj.transform:SetParent(self.node_list["LeftView"].transform, false)
			
			right_bubble_obj = self:CreateChatContent(assetbundle, "BubbleSlotRight")
			right_bubble_obj.transform:SetLocalPosition(PrePosition.BubbleSlotRight, PrePosition.BubbleSlotHight, 0)
			right_bubble_obj.transform:SetParent(self.node_list["RightView"].transform, false)

			self.pre_bubble_list = {["BubbleSlotLeft"] = left_bubble_obj, ["BubbleSlotRight"] = right_bubble_obj}
		else
			left_bubble_obj = self.pre_bubble_list["BubbleSlotLeft"]
			right_bubble_obj = self.pre_bubble_list["BubbleSlotRight"]
		end

		-- 如果普通聊天框存在的情况，隐藏普通聊天框
		if nil ~= self.pre_content_list then
			for k,v in pairs(self.pre_content_list) do
				v:SetActive(false)
			end
		end

		left_bubble_obj:SetActive(left)
		right_bubble_obj:SetActive(not left)

		self.content_obj = left and left_bubble_obj or right_bubble_obj
		self.is_special_bubble = true

	end
	self:SetContent(self.content_obj.rich_text, left)

	if self.is_easy then
		return
	end
	
	if self.is_special_bubble then
		assetbundle = "uis/chatres/bubbleres/bubble" .. bubble_type .. "_prefab"
		prefab_name = left and string.format("BubbleLeft%s", bubble_type) or string.format("BubbleRight%s", bubble_type)

		self.async_loader = self.async_loader or AllocAsyncLoader(self, "bubble")
		self.async_loader:Load(assetbundle, prefab_name, function(obj)
			if IsNil(obj) then
				return
			end

			if not self.is_special_bubble then
				return
			end
			if nil == self.bubble_obj then
				self.bubble_obj = obj
				self.bubble_obj.transform:SetParent(self.content_obj.transform, false)
				self.bubble_obj.transform:SetSiblingIndex(0)
			end
		end)
	end
end

function ChatCell:CreateChatContent(assetbundle, prefab_name)
	local gameobj = ResPoolMgr:TryGetGameObject(assetbundle, prefab_name)
	local obj = U3DObject(
		gameobj,
		gameobj.transform, 
		self
	)
	return obj
end