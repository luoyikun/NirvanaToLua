--通知返回原服
SCReturnOriginalServer = SCReturnOriginalServer or BaseClass(BaseProtocolStruct)
function SCReturnOriginalServer:__init()
	self.msg_type = 14000
end

function SCReturnOriginalServer:Decode()

end

--下发跨服排行榜列表
SCGetCrossPersonRankListAck = SCGetCrossPersonRankListAck or BaseClass(BaseProtocolStruct)
function SCGetCrossPersonRankListAck:__init()
	self.msg_type = 14001
	self.rank_list = {}
end

function SCGetCrossPersonRankListAck:Decode()
	self.rank_list = {}
	self.rank_type = MsgAdapter.ReadInt()
	local count = MsgAdapter.ReadInt()
	for i = 1, count do
		local role = {}
		role.plat_type = MsgAdapter.ReadInt()
		role.user_id = MsgAdapter.ReadInt()
		role.user_name = MsgAdapter.ReadStrN(32)
		role.level = MsgAdapter.ReadInt()
		role.prof = MsgAdapter.ReadChar()
		role.sex = MsgAdapter.ReadChar()
		role.camp = MsgAdapter.ReadChar()
		role.reserved = MsgAdapter.ReadChar()
		role.exp = MsgAdapter.ReadLL()
		role.rank_value = MsgAdapter.ReadLL()
		if self.rank_type == CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_GUILD_KILL_BOSS then
			role.avatar_key_big = MsgAdapter.ReadUInt()
			role.avatar_key_small = MsgAdapter.ReadUInt()
			role.flexible_ll = 0
		else
			role.flexible_ll = MsgAdapter.ReadLL()
		end
		
		role.flexible_name = MsgAdapter.ReadStrN(32)
		role.server_id = MsgAdapter.ReadInt()
		role.vip_level = MsgAdapter.ReadInt()
		role.flexible_int = MsgAdapter.ReadInt()
		self.rank_list[i] = role
	end
end

-- 获取跨服排行榜列表
CSCrossGetPersonRankList = CSCrossGetPersonRankList or BaseClass(BaseProtocolStruct)
function CSCrossGetPersonRankList:__init()
	self.msg_type = 14010
	self.rank_type = 0
end

function CSCrossGetPersonRankList:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.rank_type)
end

-- 跨服情侣排行榜
SCGetCrossCoupleRankListAck = SCGetCrossCoupleRankListAck or BaseClass(BaseProtocolStruct)
function SCGetCrossCoupleRankListAck:__init()
	self.msg_type = 14002
end

function SCGetCrossCoupleRankListAck:Decode()
	self.couple_rank_list = {}
	self.rank_type = MsgAdapter.ReadInt()
	local count = MsgAdapter.ReadInt()
	for i = 1, count do
		local couple_info = {}
		couple_info.plat_type = MsgAdapter.ReadInt()			-- 平台类型
		couple_info.server_id = MsgAdapter.ReadInt()			-- 服务器id
		couple_info.male_uid = MsgAdapter.ReadInt()				-- 男方uid
		couple_info.female_uid = MsgAdapter.ReadInt()			-- 女方uid
		couple_info.male_name = MsgAdapter.ReadStrN(32)			-- 男方姓名
		couple_info.female_name = MsgAdapter.ReadStrN(32)		-- 女方姓名
		couple_info.male_prof = MsgAdapter.ReadChar()			-- 男方职业
		couple_info.female_prof = MsgAdapter.ReadChar()			-- 女方职业
		couple_info.reserve_sh = MsgAdapter.ReadShort()
		couple_info.male_rank_value = MsgAdapter.ReadInt()		-- 男排行值
		couple_info.female_rank_value = MsgAdapter.ReadInt()	-- 女排行值
		self.couple_rank_list[i] = couple_info
	end
end

-- 通知玩家进入跨服
SCNoticeCanEnterCross = SCNoticeCanEnterCross or BaseClass(BaseProtocolStruct)
function SCNoticeCanEnterCross:__init()
	self.msg_type = 14003

	self.activity_type = 0
end

function SCNoticeCanEnterCross:Decode()
	self.activity_type = MsgAdapter.ReadInt()
end