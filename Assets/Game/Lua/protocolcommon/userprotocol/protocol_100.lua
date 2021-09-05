-- 请求个人排行返回
SCGetPersonRankListAck = SCGetPersonRankListAck or BaseClass(BaseProtocolStruct)
function SCGetPersonRankListAck:__init()
	self.msg_type = 10000
	self.last_snapshot_time = 0
	self.rank_type = 0
	self.rank_list = {}
end

function SCGetPersonRankListAck:Decode()
	self.last_snapshot_time = MsgAdapter.ReadUInt()
	self.rank_type = MsgAdapter.ReadInt()

	local count = MsgAdapter.ReadInt()
	self.rank_list = {}
	for i = 1, count do
		local rank_info = {}
		rank_info.index = i
		rank_info.user_id = MsgAdapter.ReadInt()
		rank_info.user_name = MsgAdapter.ReadStrN(32)
		rank_info.flexible_name = MsgAdapter.ReadStrN(32)
		rank_info.sex = MsgAdapter.ReadChar()
		rank_info.prof = MsgAdapter.ReadChar()
		rank_info.camp = MsgAdapter.ReadChar()
		rank_info.vip_level = MsgAdapter.ReadChar()
		rank_info.jingjie_level = MsgAdapter.ReadShort()
		rank_info.record_index = MsgAdapter.ReadShort()
		rank_info.exp = MsgAdapter.ReadLL()
		rank_info.level = MsgAdapter.ReadInt()
		if PERSON_RANK_TYPE_NEED_EXCHANGE[self.rank_type] then
			rank_info.flexible_int = MsgAdapter.ReadLL()
			rank_info.rank_value = MsgAdapter.ReadInt() 
		else
			rank_info.rank_value = MsgAdapter.ReadLL()
			rank_info.flexible_int= MsgAdapter.ReadInt()     	  --精灵榜时表示 精灵幻化id    表白榜表示 最新表白时间
		end
		rank_info.flexible_ll = MsgAdapter.ReadLL()		 	  --精灵榜时表示 精灵id        表白榜表示 总的表白次数(表白+被表白)
		rank_info.avatar_key_big = MsgAdapter.ReadUInt()
		rank_info.avatar_key_small = MsgAdapter.ReadUInt()
		table.insert(self.rank_list, rank_info)
	end
end

-- 仙盟排行返回
SCGetGuildRankListAck = SCGetGuildRankListAck or BaseClass(BaseProtocolStruct)
function SCGetGuildRankListAck:__init()
	self.msg_type = 10001
	self.rank_type = 0
	self.rank_list = {}
end

function SCGetGuildRankListAck:Decode()
	self.rank_type = MsgAdapter.ReadInt()
	local count = MsgAdapter.ReadInt()
	self.rank_list = {}
	for i = 1, count do
		local rank_info = {}
		rank_info.guild_id = MsgAdapter.ReadInt()
		rank_info.guild_name = MsgAdapter.ReadStrN(32)
		rank_info.tuan_zhang_uid = MsgAdapter.ReadInt()
		rank_info.tuan_zhang_name = MsgAdapter.ReadStrN(32)
		rank_info.guild_level = MsgAdapter.ReadShort()
		rank_info.max_member_count = MsgAdapter.ReadShort()
		rank_info.camp = MsgAdapter.ReadShort()
		rank_info.member_count = MsgAdapter.ReadShort()

		if self.rank_type == GUILD_RANK_TYPE.GUILD_RANK_TYPE_GUILDBATTLE then
			rank_info.crate_time = MsgAdapter.ReadUInt()
			rank_info.member_count = MsgAdapter.ReadShort()
			rank_info.rank_value = MsgAdapter.ReadShort()
		elseif self.rank_type == GUILD_RANK_TYPE.GUILD_RANK_TYPE_CAPABILITY then
			rank_info.level = MsgAdapter.ReadInt()
			rank_info.zhan_li = MsgAdapter.ReadInt()
		else
			rank_info.rank_value = MsgAdapter.ReadLL()
		end

		table.insert(self.rank_list, rank_info)
	end
end

-- 队伍排行返回
SCGetTeamRankListAck = SCGetTeamRankListAck or BaseClass(BaseProtocolStruct)
function SCGetTeamRankListAck:__init()
	self.msg_type = 10002
	self.rank_type = 0
	self.rank_list = {}
end

function SCGetTeamRankListAck:Decode()
	self.rank_type = MsgAdapter.ReadInt()
	local count = MsgAdapter.ReadInt()
	for i = 1, count do
		local rank_info = {}
		local member_list = {}
			for j = 1, 5 do
				local member = {}
				member.uid = MsgAdapter.ReadInt()
				member.user_name = MsgAdapter.ReadStrN(32)
				member.camp = MsgAdapter.ReadInt()
				table.insert(member_list, member)
			end
		rank_info.member_list = member_list
		rank_info.rank_value = MsgAdapter.ReadLL()
		rank_info.flexible_int = MsgAdapter.ReadInt()
		rank_info.flexible_ll = MsgAdapter.ReadLL()

		table.insert(self.rank_list, rank_info)
	end
end

-- 顶级玩家信息返回
SCGetPersonRankTopUserAck = SCGetPersonRankTopUserAck or BaseClass(BaseProtocolStruct)
function SCGetPersonRankTopUserAck:__init()
	self.msg_type = 10003
	self.rank_type = 0
	self.user_id = 0
	self.user_name =""
	self.sex = 0
	self.prof = 0
	self.camp = 0
	self.reserved = 0
	self.level = 0
	self.rank_value = 0
end

function SCGetPersonRankTopUserAck:Decode()
	self.rank_type = MsgAdapter.ReadInt()
	self.user_id = MsgAdapter.ReadInt()
	self.user_name = MsgAdapter.ReadStrN(32)
	self.sex = MsgAdapter.ReadChar()
	self.prof = MsgAdapter.ReadChar()
	self.camp = MsgAdapter.ReadChar()
	self.reserved = MsgAdapter.ReadChar()
	self.level = MsgAdapter.ReadInt()
	self.rank_value = MsgAdapter.ReadLL()
end

-- 世界等级信息返回
SCGetWorldLevelAck = SCGetWorldLevelAck or BaseClass(BaseProtocolStruct)
function SCGetWorldLevelAck:__init()
	self.msg_type = 10004
	self.world_level = 0
	self.top_user_level = 0
end

function SCGetWorldLevelAck:Decode()
	self.world_level = MsgAdapter.ReadInt()
	self.top_user_level = MsgAdapter.ReadInt()
end

SCGetCoupleRankListAck = SCGetCoupleRankListAck or BaseClass(BaseProtocolStruct)
function SCGetCoupleRankListAck:__init()
	self.msg_type = 10005
	self.rank_type = 0
	self.item_count = 0
	self.rank_item_list = {}
end

function SCGetCoupleRankListAck:Decode()
	self.rank_item_list = {}
	self.rank_type = MsgAdapter.ReadInt()
	self.item_count = MsgAdapter.ReadInt()
	for i = 1, self.item_count do
		local rank_info = {}
		rank_info.male_uid = MsgAdapter.ReadInt()
		rank_info.female_uid = MsgAdapter.ReadInt()
		rank_info.male_name = MsgAdapter.ReadStrN(32)
		rank_info.female_name = MsgAdapter.ReadStrN(32)
		rank_info.male_prof = MsgAdapter.ReadChar()
		rank_info.female_prof = MsgAdapter.ReadChar()
		rank_info.reserve_sh = MsgAdapter.ReadShort()
		rank_info.male_avatar = MsgAdapter.ReadLL()
		rank_info.female_avatar = MsgAdapter.ReadLL()
		rank_info.male_rank_value = MsgAdapter.ReadInt()
		rank_info.female_rank_value = MsgAdapter.ReadInt()
		table.insert(self.rank_item_list, rank_info)
	end
end

-- 请求个人排行
CSGetPersonRankListReq = CSGetPersonRankListReq or BaseClass(BaseProtocolStruct)
function CSGetPersonRankListReq:__init()
	self.msg_type = 10050
	self.rank_type = 0
end

function CSGetPersonRankListReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.rank_type)
end

--请求军团排行
CSGetGuildRankListReq = CSGetGuildRankListReq or BaseClass(BaseProtocolStruct)
function CSGetGuildRankListReq:__init()
	self.msg_type = 10051
	self.rank_type = 0
end

function CSGetGuildRankListReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.rank_type)
end

-- 请求队伍排行
CSGetTeamRankListReq = CSGetTeamRankListReq or BaseClass(BaseProtocolStruct)
function CSGetTeamRankListReq:__init()
	self.msg_type = 10052
	self.rank_type = 0
end

function CSGetTeamRankListReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.rank_type)
end

-- 请求顶级玩家信息
CSGetPersonRankTopUserReq = CSGetPersonRankTopUserReq or BaseClass(BaseProtocolStruct)
function CSGetPersonRankTopUserReq:__init()
	self.msg_type = 10053
	self.rank_type = 0
end

function CSGetPersonRankTopUserReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.rank_type)
end


CSGetCoupleRankList = CSGetCoupleRankList or BaseClass(BaseProtocolStruct)
function CSGetCoupleRankList:__init()
	self.msg_type = 10054
	self.rank_type = 0
end

function CSGetCoupleRankList:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.rank_type)
end

-- 广播世界boss
SCWorldBossInfoToAll = SCWorldBossInfoToAll or BaseClass(BaseProtocolStruct)
function SCWorldBossInfoToAll:__init()
	self.msg_type = 10100
	self.boss_id = 0
	self.scene_id = 0
	self.status = 0
	self.next_refresh_time = 0
	self.killer_uid = 0
end

function SCWorldBossInfoToAll:Decode()
	self.boss_id = MsgAdapter.ReadInt()
	self.scene_id = MsgAdapter.ReadInt()
	self.status = MsgAdapter.ReadInt()
	self.next_refresh_time = MsgAdapter.ReadUInt()
	self.killer_uid = MsgAdapter.ReadInt()
end

--------------------------- 跨服排行榜个人信息 ---------------------------
-- 请求查询跨服排行榜个人信息
CSGetSpecialRankValue = CSGetSpecialRankValue or BaseClass(BaseProtocolStruct)
function CSGetSpecialRankValue:__init()
	self.msg_type = 10055
end

function CSGetSpecialRankValue:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.rank_type)		-- 排行榜类型(情侣榜加1000)
end

-- 跨服排行榜个人信息返回
SCGetSpecialRankValueAck = SCGetSpecialRankValueAck or BaseClass(BaseProtocolStruct)
function SCGetSpecialRankValueAck:__init()
	self.msg_type = 10006
end

function SCGetSpecialRankValueAck:Decode()
	self.rank_type = MsgAdapter.ReadInt()		-- 排行榜类型(情侣榜加1000)
	self.rank_value = MsgAdapter.ReadInt()		-- 排行榜值
end