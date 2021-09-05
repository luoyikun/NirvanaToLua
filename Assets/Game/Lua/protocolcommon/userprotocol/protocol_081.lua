
-- 8100 频道聊天返回  --0：世界，1：阵营，2：场景，3：组队，4：仙盟
SCChannelChatAck = SCChannelChatAck or BaseClass(BaseProtocolStruct)

function SCChannelChatAck:__init()
	self.msg_type = 8100
end

function SCChannelChatAck:Decode()
	self.from_uid = MsgAdapter.ReadInt()
	self.username = MsgAdapter.ReadStrN(32)
	self.sex = MsgAdapter.ReadChar()
	self.camp = MsgAdapter.ReadChar()
	self.prof = MsgAdapter.ReadChar()
	self.authority_type = MsgAdapter.ReadChar()
	self.content_type = MsgAdapter.ReadChar()
	self.tuhaojin_color = MsgAdapter.ReadChar()                     -- 土豪金颜色，0 表示未激活
	self.bigchatface_status = MsgAdapter.ReadChar()                 -- 聊天大表情，0 表示未激活
	self.personalize_window_bubble_type = MsgAdapter.ReadChar()     -- 气泡框，0 表示未激活
	
	self.avatar_key_big = MsgAdapter.ReadUInt()
	self.avatar_key_small = MsgAdapter.ReadUInt()
	self.role_id = MsgAdapter.ReadUInt()
	self.plat_id = MsgAdapter.ReadUInt()
	self.uuid = self.role_id + (self.plat_id * (2 ^ 32))
	self.level = MsgAdapter.ReadShort()
	self.vip_level = MsgAdapter.ReadChar()
	self.channel_type = MsgAdapter.ReadChar()

	self.guild_signin_count = MsgAdapter.ReadShort()
	self.is_msg_record = MsgAdapter.ReadChar()
	self.use_head_frame = MsgAdapter.ReadChar()

	-- 新增仙盟答题图片
	self.is_answer_true = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	self.origin_type = MsgAdapter.ReadShort()
	self.has_xianzunka_flag = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.msg_timestamp = MsgAdapter.ReadUInt()
	self.msg_length = MsgAdapter.ReadUInt()
	self.content = MsgAdapter.ReadStrN(self.msg_length)
end

--8101  私人聊天返回
SCSingleChatAck = SCSingleChatAck or BaseClass(BaseProtocolStruct)

function SCSingleChatAck:__init()
	self.msg_type = 8101
end

function SCSingleChatAck:Decode()
	self.from_uid = MsgAdapter.ReadInt()
	self.role_id = MsgAdapter.ReadUInt()
	self.plat_id = MsgAdapter.ReadUInt()
	self.uuid = self.role_id + (self.plat_id * (2 ^ 32))
	self.username = MsgAdapter.ReadStrN(32)
	self.sex = MsgAdapter.ReadChar()
	self.camp = MsgAdapter.ReadChar()
	self.vip_level = MsgAdapter.ReadChar()
	self.prof = MsgAdapter.ReadChar()
	self.authority_type = MsgAdapter.ReadChar()
	self.content_type = MsgAdapter.ReadChar()
	self.level = MsgAdapter.ReadShort()
	self.tuhaojin_color = MsgAdapter.ReadChar()                     -- 土豪金颜色，0 表示未激活
	self.bigchatface_status = MsgAdapter.ReadChar()                 -- 聊天大表情，0 表示未激活
	self.personalize_window_bubble_type = MsgAdapter.ReadChar()     -- 气泡框，0 表示未激活
	self.use_head_frame = MsgAdapter.ReadChar()                     -- 聊天框（头像），0 表示未激活
	self.is_echo = MsgAdapter.ReadChar()
	self.special_param = MsgAdapter.ReadChar()						--1服务器代发的仇人私聊
	self.has_xianzunka_flag = MsgAdapter.ReadShort()
	self.avatar_key_big = MsgAdapter.ReadUInt()
	self.avatar_key_small = MsgAdapter.ReadUInt()
	self.msg_timestamp = MsgAdapter.ReadUInt()
	self.msg_length = MsgAdapter.ReadUInt()
	self.content = MsgAdapter.ReadStrN(self.msg_length)
end

--8102  通知私聊对象不在线
SCSingleChatUserNotExist = SCSingleChatUserNotExist or BaseClass(BaseProtocolStruct)

function SCSingleChatUserNotExist:__init()
	self.msg_type = 8102
end

function SCSingleChatUserNotExist:Decode()
	self.to_uid = MsgAdapter.ReadInt()
end

--8103  通知私聊对象不在线
SCOpenLevelLimit = SCOpenLevelLimit or BaseClass(BaseProtocolStruct)

function SCOpenLevelLimit:__init()
	self.msg_type = 8103
	self.ignore_level_limit = 0
	self.is_forbid_audio_chat = 0

	self.open_level = {}
	self.vip_level_list = {}
end

function SCOpenLevelLimit:Decode()
	self.ignore_level_limit = MsgAdapter.ReadInt()
	self.is_forbid_audio_chat = MsgAdapter.ReadShort()
	self.is_forbid_change_avatar = MsgAdapter.ReadShort()
	-- （区分频道）聊天限制条件类型 0:同时满足角色等级和vip等级，1:满足其中一个条件
	self.chat_limit_condition_type_flag_list = bit:d2b(MsgAdapter.ReadInt())
	self.open_level = {}
	for i = 0, CHAT_OPENLEVEL_LIMIT_TYPE.MAX - 1 do
		self.open_level[i] = MsgAdapter.ReadInt()
	end
	for i = 0, CHAT_OPENLEVEL_LIMIT_TYPE.MAX - 1 do
		self.vip_level_list[i] = MsgAdapter.ReadShort()
	end

	--全服禁言时间限制
	self.forbid_time_info_list = {}
	for i = 0, CHAT_OPENLEVEL_LIMIT_TYPE.MAX - 1 do
		self.forbid_time_info_list[i] = {}
		self.forbid_time_info_list[i].begin_hour = MsgAdapter.ReadShort()
		self.forbid_time_info_list[i].end_hour = MsgAdapter.ReadShort()
	end

	self.is_forbid_cross_speaker = MsgAdapter.ReadShort()
	self.reserve_sh = MsgAdapter.ReadShort()
end

--8150  请求频道聊天
CSChannelChatReq = CSChannelChatReq or BaseClass(BaseProtocolStruct)

function CSChannelChatReq:__init()
	self.msg_type = 8150

	self.content_type = 0
	self.channel_type = 0
	self.content = ""
end

function CSChannelChatReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteChar(self.content_type)
	MsgAdapter.WriteChar(0)
	MsgAdapter.WriteShort(self.channel_type)
	MsgAdapter.WriteStr(self.content)
end

--8151  请求私人聊天
CSSingleChatReq = CSSingleChatReq or BaseClass(BaseProtocolStruct)

function CSSingleChatReq:__init()
	self.msg_type = 8151

	self.content_type = 0
	self.to_uid = 0
	self.plat_type = 0
	self.content = ""
end

function CSSingleChatReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteChar(self.content_type)
	MsgAdapter.WriteChar(0)
	MsgAdapter.WriteShort(0)
	MsgAdapter.WriteInt(self.to_uid)
	MsgAdapter.WriteInt(self.to_uid)
	MsgAdapter.WriteInt(self.plat_type)
	MsgAdapter.WriteStr(self.content)
end

--8104  通知有玩家被封禁
SCForbidChatInfo = SCForbidChatInfo or BaseClass(BaseProtocolStruct)
function SCForbidChatInfo:__init()
	self.msg_type = 8104
end

function SCForbidChatInfo:Decode()
	local forbid_uid_count = MsgAdapter.ReadInt()

	self.forbid_uid_list = {}
	for i = 1, forbid_uid_count do
		table.insert(self.forbid_uid_list, MsgAdapter.ReadInt())
	end
end

-- 8105个人禁言信息
SCForbidUserInfo = SCForbidUserInfo or BaseClass(BaseProtocolStruct)
function SCForbidUserInfo:__init()
	self.msg_type = 8105
end

function SCForbidUserInfo:Decode()
	self.forbid_talk_end_timestamp = MsgAdapter.ReadUInt()
end

--8152  请求封禁列表
CSForbidChatInfo = CSForbidChatInfo or BaseClass(BaseProtocolStruct)

function CSForbidChatInfo:__init()
	self.msg_type = 8152
end

function CSForbidChatInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 8106  上线下发历史聊天内容列表
SCChatBoardListInfo = SCChatBoardListInfo or BaseClass(BaseProtocolStruct)
function SCChatBoardListInfo:__init()
	self.msg_type = 8106
end

function SCChatBoardListInfo:Decode()
	self.channel_type = MsgAdapter.ReadShort()
	self.list_count = MsgAdapter.ReadShort()

	self.msg_list = {} 
	self.msg_list[self.channel_type] = {} 
	for i = 1, self.list_count do
		local msg_info = {}
		MsgAdapter.ReadInt()
		msg_info.msg_type_id = MsgAdapter.ReadShort()
		MsgAdapter.ReadShort()
		if msg_info.msg_type_id == 8100 then
			msg_info.from_uid = MsgAdapter.ReadInt()
			msg_info.username = MsgAdapter.ReadStrN(32)
			msg_info.sex = MsgAdapter.ReadChar()
			msg_info.camp = MsgAdapter.ReadChar()
			msg_info.prof = MsgAdapter.ReadChar()
			msg_info.authority_type = MsgAdapter.ReadChar()
			msg_info.content_type = MsgAdapter.ReadChar()
			msg_info.tuhaojin_color = MsgAdapter.ReadChar()                     -- 土豪金颜色，0 表示未激活
			msg_info.bigchatface_status = MsgAdapter.ReadChar()                 -- 聊天大表情，0 表示未激活
			msg_info.personalize_window_bubble_type = MsgAdapter.ReadChar()     -- 气泡框，0 表示未激活 
			msg_info.avatar_key_big = MsgAdapter.ReadUInt()
			msg_info.avatar_key_small = MsgAdapter.ReadUInt()
			msg_info.role_id = MsgAdapter.ReadUInt()
			msg_info.plat_id = MsgAdapter.ReadUInt()
			msg_info.uuid = msg_info.role_id + (msg_info.plat_id * (2 ^ 32))
			msg_info.level = MsgAdapter.ReadShort()
			msg_info.vip_level = MsgAdapter.ReadChar()
			msg_info.channel_type = MsgAdapter.ReadChar()
			msg_info.guild_signin_count = MsgAdapter.ReadShort()
			msg_info.is_msg_record = MsgAdapter.ReadChar()
			msg_info.use_head_frame = MsgAdapter.ReadChar()

			-- 新增仙盟答题图片
			msg_info.is_answer_true = MsgAdapter.ReadChar()
			MsgAdapter.ReadChar()
			msg_info.origin_type = MsgAdapter.ReadShort()

			msg_info.has_xianzunka_flag = MsgAdapter.ReadShort()
			MsgAdapter.ReadShort()

			msg_info.msg_timestamp = MsgAdapter.ReadUInt()
			local msg_length = MsgAdapter.ReadUInt()
			msg_info.content = MsgAdapter.ReadStrN(msg_length)

			table.insert(self.msg_list[self.channel_type], msg_info)
		elseif msg_info.msg_type_id == 8101 then
			msg_info.from_uid = MsgAdapter.ReadInt()
			msg_info.role_id = MsgAdapter.ReadUInt()
			msg_info.plat_id = MsgAdapter.ReadUInt()
			msg_info.uuid = msg_info.role_id + (msg_info.plat_id * (2 ^ 32))
			msg_info.username = MsgAdapter.ReadStrN(32)
			msg_info.sex = MsgAdapter.ReadChar()
			msg_info.camp = MsgAdapter.ReadChar()
			msg_info.vip_level = MsgAdapter.ReadChar()
			msg_info.prof = MsgAdapter.ReadChar()
			msg_info.authority_type = MsgAdapter.ReadChar()
			msg_info.content_type = MsgAdapter.ReadChar()
			msg_info.level = MsgAdapter.ReadShort()
			msg_info.tuhaojin_color = MsgAdapter.ReadChar()                     -- 土豪金颜色，0 表示未激活
			msg_info.bigchatface_status = MsgAdapter.ReadChar()                 -- 聊天大表情，0 表示未激活
			msg_info.personalize_window_bubble_type = MsgAdapter.ReadChar()     -- 气泡框，0 表示未激活
			msg_info.use_head_frame = MsgAdapter.ReadChar()                     -- 聊天框（头像），0 表示未激活
			msg_info.is_echo = MsgAdapter.ReadChar()
			MsgAdapter.ReadChar()
			MsgAdapter.ReadShort()
			msg_info.avatar_key_big = MsgAdapter.ReadUInt()
			msg_info.avatar_key_small = MsgAdapter.ReadUInt()
			msg_info.msg_timestamp = MsgAdapter.ReadUInt()
			msg_info.msg_length = MsgAdapter.ReadUInt()
			msg_info.content = MsgAdapter.ReadStrN(msg_info.msg_length)
			table.insert(self.msg_list[self.channel_type], msg_info)
		else
			msg_info.from_uid = MsgAdapter.ReadInt()
			msg_info.role_id = MsgAdapter.ReadUInt()
			msg_info.plat_id = MsgAdapter.ReadUInt()
			msg_info.uuid = msg_info.role_id + (msg_info.plat_id * (2 ^ 32))
			msg_info.username = MsgAdapter.ReadStrN(32)
			msg_info.sex = MsgAdapter.ReadChar()
			msg_info.camp = MsgAdapter.ReadChar()
			msg_info.content_type = MsgAdapter.ReadChar()
			msg_info.camp_post = MsgAdapter.ReadChar()
			msg_info.guild_post = MsgAdapter.ReadChar()
			msg_info.prof = MsgAdapter.ReadChar()
			msg_info.authourity_type = MsgAdapter.ReadChar()
			msg_info.vip_level = MsgAdapter.ReadChar()
			msg_info.avatar_key_big = MsgAdapter.ReadUInt()
			msg_info.avatar_key_small = MsgAdapter.ReadUInt()
			msg_info.plat_name = MsgAdapter.ReadStrN(64)
			msg_info.server_id = MsgAdapter.ReadInt()
			msg_info.speaker_type = MsgAdapter.ReadChar()
			msg_info.tuhaojin_color = MsgAdapter.ReadChar()         -- 土豪金颜色，0 表示未激活
			msg_info.bigchatface_status = MsgAdapter.ReadShort()    -- 聊天大表情，0 表示未激活
			msg_info.personalize_window_type = MsgAdapter.ReadChar()
			msg_info.personalize_window_bubble_type = MsgAdapter.ReadChar()
			msg_info.is_msg_record = MsgAdapter.ReadChar()
			msg_info.use_head_frame = MsgAdapter.ReadChar()
			msg_info.send_time_stamp = MsgAdapter.ReadUInt()

			msg_info.speaker_msg_length = MsgAdapter.ReadUInt()
			msg_info.speaker_msg = MsgAdapter.ReadStrN(msg_info.speaker_msg_length)
			table.insert(self.msg_list[self.channel_type], msg_info)
		end
	end
end

--8153  请求监听玩家是否在线
CSSingleChatOnlineStatusReq = CSSingleChatOnlineStatusReq or BaseClass(BaseProtocolStruct)
function CSSingleChatOnlineStatusReq:__init()
	self.msg_type = 8153
	self.req_type = 0
	self.plat_type = 0
	self.target_id = 0
end

function CSSingleChatOnlineStatusReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.req_type)
	MsgAdapter.WriteShort(0)
	MsgAdapter.WriteInt(self.plat_type)
	MsgAdapter.WriteInt(self.target_id)
end

--8107 返回玩家在线信息
SCSingleChatOnlineStatus = SCSingleChatOnlineStatus or BaseClass(BaseProtocolStruct)
function SCSingleChatOnlineStatus:__init()
	self.msg_type = 8107
	self.role_id = 0
	self.plat_type = 0
	self.uuid = 0
	self.is_online = 0
end

function SCSingleChatOnlineStatus:Decode()
	self.role_id = MsgAdapter.ReadUInt()
	self.plat_type = MsgAdapter.ReadUInt()
	self.uuid = self.role_id + (self.plat_type * (2 ^ 32))
	self.is_online = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
end
