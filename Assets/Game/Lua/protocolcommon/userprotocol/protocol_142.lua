--跨服修罗塔掉落日志请求
CSCrossXiuluoTowerDropLog = CSCrossXiuluoTowerDropLog or BaseClass(BaseProtocolStruct)
function CSCrossXiuluoTowerDropLog:__init()
	self.msg_type = 14190
end

function CSCrossXiuluoTowerDropLog:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--跨服修罗塔掉落日志
SCCrossXiuluoTowerDropLog = SCCrossXiuluoTowerDropLog or BaseClass(BaseProtocolStruct)
function SCCrossXiuluoTowerDropLog:__init()
	self.msg_type = 14205
	self.log_count = 0
	self.item_list = {}
end

function SCCrossXiuluoTowerDropLog:Decode()
	self.item_list = {}
	self.log_count = MsgAdapter.ReadInt()
	for i = 1, self.log_count do
		local data = {}
		data.log_type = MsgAdapter.ReadInt()
		data.name = MsgAdapter.ReadStrN(32)
		data.timestamp = MsgAdapter.ReadUInt()
		data.item_id = MsgAdapter.ReadUShort()
		data.item_num = MsgAdapter.ReadShort()
		self.item_list[i] = data
	end
end


--跨服六界掉落日志请求
CSCrossGuildBattleDropLog = CSCrossGuildBattleDropLog or BaseClass(BaseProtocolStruct)
function CSCrossGuildBattleDropLog:__init()
	self.msg_type = 14220
end

function CSCrossGuildBattleDropLog:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--跨服六界精英怪请求
CSCrossGuildBattleGetMonsterInfoReq = CSCrossGuildBattleGetMonsterInfoReq or BaseClass(BaseProtocolStruct)
function CSCrossGuildBattleGetMonsterInfoReq:__init()
	self.msg_type = 14221
end

function CSCrossGuildBattleGetMonsterInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--跨服六界掉落日志
SCCrossGuildBattleDropLog = SCCrossGuildBattleDropLog or BaseClass(BaseProtocolStruct)
function SCCrossGuildBattleDropLog:__init()
	self.msg_type = 14235
	self.log_count = 0
	self.item_list = {}
end

function SCCrossGuildBattleDropLog:Decode()
	self.item_list = {}
	self.log_count = MsgAdapter.ReadInt()
	for i = 1, self.log_count do
		local data = {}
		data.name = MsgAdapter.ReadStrN(32)
		data.timestamp = MsgAdapter.ReadUInt()
		data.item_id = MsgAdapter.ReadUShort()
		data.item_num = MsgAdapter.ReadShort()
		self.item_list[i] = data
	end
end
-- 跨服组队本，房间信息改变
SCNoticeCrossTeamFBRoomInfoChange = SCNoticeCrossTeamFBRoomInfoChange or BaseClass(BaseProtocolStruct)
function SCNoticeCrossTeamFBRoomInfoChange:__init()
	self.msg_type = 14250

	self.layer = 0
	self.room = 0
	self.opera_uuid = 0
	self.opera_uid = 0
	self.opera_platform = 0
	self.opera_type = 0
end

function SCNoticeCrossTeamFBRoomInfoChange:Decode()
	self.layer = MsgAdapter.ReadInt()
	self.room = MsgAdapter.ReadInt()
	-- self.opera_uuid = MsgAdapter.ReadLL()
	self.opera_uid = MsgAdapter.ReadUInt()
	self.opera_platform = MsgAdapter.ReadUInt()
	self.opera_type = MsgAdapter.ReadInt()
	self.opera_uuid = self.opera_uid + (self.opera_platform * (2 ^ 32))
end

-- 跨服组队本，房间列表信息
SCCrossTeamFBRoomListInfo = SCCrossTeamFBRoomListInfo or BaseClass(BaseProtocolStruct)
function SCCrossTeamFBRoomListInfo:__init()
	self.msg_type = 14251

	self.room_count = 0
	self.room_info = {}
end

function SCCrossTeamFBRoomListInfo:Decode()
	self.room_info = {}
	self.room_count = MsgAdapter.ReadInt()
	for i = 1, self.room_count do
		self.room_info[i] = {}
		self.room_info[i].need_capability = MsgAdapter.ReadInt()
		self.room_info[i].password = MsgAdapter.ReadInt()
		self.room_info[i].is_auto_start = MsgAdapter.ReadInt()
		self.room_info[i].leader_name = MsgAdapter.ReadStrN(32)
		self.room_info[i].leader_prof = MsgAdapter.ReadChar()
		self.room_info[i].leader_sex = MsgAdapter.ReadChar()
		self.room_info[i].fb_state = MsgAdapter.ReadChar()
		self.room_info[i].user_count = MsgAdapter.ReadChar()
		self.room_info[i].room = MsgAdapter.ReadInt()
		self.room_info[i].layer = MsgAdapter.ReadInt()
	end
end

-- 跨服组队本，房间信息
SCCrossTeamFBRoomInfo = SCCrossTeamFBRoomInfo or BaseClass(BaseProtocolStruct)
function SCCrossTeamFBRoomInfo:__init()
	self.msg_type = 14252

	self.layer = 0
	self.room = 0
	self.is_auto_start = 0
	self.fb_state = 0
	self.user_count = 0
	self.user_info = {}
end

function SCCrossTeamFBRoomInfo:Decode()
	self.user_info = {}
	self.layer = MsgAdapter.ReadInt()
	self.room = MsgAdapter.ReadInt()
	self.is_auto_start = MsgAdapter.ReadShort()
	self.fb_state = MsgAdapter.ReadShort()
	self.user_count = MsgAdapter.ReadInt()
	for i = 1, self.user_count do
		self.user_info[i] = {}
		-- self.user_info[i].uuid = MsgAdapter.ReadLL()
		self.user_info[i].uid = MsgAdapter.ReadUInt()
		self.user_info[i].platform = MsgAdapter.ReadUInt()
		self.user_info[i].prof = MsgAdapter.ReadChar()
		self.user_info[i].sex = MsgAdapter.ReadChar()
		self.user_info[i].camp = MsgAdapter.ReadChar()
		self.user_info[i].user_state = MsgAdapter.ReadChar()
		self.user_info[i].name = MsgAdapter.ReadStrN(32)
		self.user_info[i].capability = MsgAdapter.ReadInt()
		self.user_info[i].index = MsgAdapter.ReadInt()
		self.user_info[i].uuid = self.user_info[i].uid + (self.user_info[i].platform * (2 ^ 32))
		self.user_info[i].server_id = UserVo.GetServerId(self.user_info[i].uid)
	end
end

--跨服边境
CSCrossServerBianJingZhiDiBossInfoReq = CSCrossServerBianJingZhiDiBossInfoReq or BaseClass(BaseProtocolStruct)
function CSCrossServerBianJingZhiDiBossInfoReq:__init()
	self.msg_type = 14285
end

function CSCrossServerBianJingZhiDiBossInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

SCCrossServerBianJingZhiDiBossInfo = SCCrossServerBianJingZhiDiBossInfo or BaseClass(BaseProtocolStruct)
function SCCrossServerBianJingZhiDiBossInfo:__init()
	self.msg_type = 14280
end

function SCCrossServerBianJingZhiDiBossInfo:Decode()
	self.boss_num = MsgAdapter.ReadShort()
	self.boss_total_num = MsgAdapter.ReadShort()
	self.left_boss_refresh_time = MsgAdapter.ReadInt()
end
