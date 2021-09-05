--跨服1v1匹配确认
SCCross1v1MatchAck = SCCross1v1MatchAck or BaseClass(BaseProtocolStruct)
function SCCross1v1MatchAck:__init()
	self.msg_type = 14100
end

function SCCross1v1MatchAck:Decode()
	self.result = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.match_end_left_time = MsgAdapter.ReadUInt()
end

--跨服1v1战斗记录
SCCross1v1WeekRecord = SCCross1v1WeekRecord or BaseClass(BaseProtocolStruct)
function SCCross1v1WeekRecord:__init()
	self.msg_type = 14101
end

function SCCross1v1WeekRecord:Decode()
	self.win_this_week = MsgAdapter.ReadShort()
	self.lose_this_week = MsgAdapter.ReadShort()
	local record_count = MsgAdapter.ReadInt()
	self.kf_1v1_news = {}
	for i = 1, record_count do
		local vo = {}
		vo.result = MsgAdapter.ReadShort()
		MsgAdapter.ReadShort()
		vo.oppo_plat_type = MsgAdapter.ReadInt()
		vo.oppo_server_id = MsgAdapter.ReadInt()
		vo.oppo_role_uid = MsgAdapter.ReadInt()
		vo.oppo_capability = MsgAdapter.ReadLL()
		vo.oppo_name = MsgAdapter.ReadStrN(32)
		vo.add_score = MsgAdapter.ReadInt()
		self.kf_1v1_news[i] = vo
	end
end

--跨服1v1展示排行
SCCross1V1RankList = SCCross1V1RankList or BaseClass(BaseProtocolStruct)
function SCCross1V1RankList:__init()
	self.msg_type = 14102
end

function SCCross1V1RankList:Decode()
	local count = MsgAdapter.ReadInt()
	self.kf_1v1_show_rank = {}
	for i = 1, count do
		local vo = {}
		vo.plat_type = MsgAdapter.ReadInt()
		vo.role_id = MsgAdapter.ReadInt()
		vo.name = MsgAdapter.ReadStrN(32)
		vo.level = MsgAdapter.ReadShort()
		vo.prof = MsgAdapter.ReadChar()
		vo.sex = MsgAdapter.ReadChar()
		vo.score = MsgAdapter.ReadInt()
		vo.capability = MsgAdapter.ReadLL()
		self.kf_1v1_show_rank[i] = vo
	end
end

--跨服1v1匹配结果
SCCross1v1MatchResult = SCCross1v1MatchResult or BaseClass(BaseProtocolStruct)
function SCCross1v1MatchResult:__init()
	self.msg_type = 14103
end

function SCCross1v1MatchResult:Decode()
	self.info = {}
	self.info.result = MsgAdapter.ReadShort()
	self.info.side = MsgAdapter.ReadShort()
	self.info.oppo_plat_type =  MsgAdapter.ReadInt()
	self.info.oppo_sever_id =  MsgAdapter.ReadInt()
	self.info.role_id = MsgAdapter.ReadInt()
	self.info.oppo_name = MsgAdapter.ReadStrN(32)
	self.info.fight_start_time = MsgAdapter.ReadUInt() + TimeCtrl.Instance:GetServerTime()
	self.info.prof = MsgAdapter.ReadChar()
	self.info.sex = MsgAdapter.ReadChar()
	self.info.camp = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	self.info.level = MsgAdapter.ReadInt()
	self.info.fight_end_time = MsgAdapter.ReadUInt() + TimeCtrl.Instance:GetServerTime()
	self.info.capability = MsgAdapter.ReadLL()
end

--跨服1v1挑战结果
SCCross1v1FightResult = SCCross1v1FightResult or BaseClass(BaseProtocolStruct)
function SCCross1v1FightResult:__init()
	self.msg_type = 14104
end

function SCCross1v1FightResult:Decode()
	self.result = MsgAdapter.ReadInt()
	self.award_score =  MsgAdapter.ReadInt()
end

-- 跨服1v1匹配查询
CSCross1v1MatchQuery = CSCross1v1MatchQuery or BaseClass(BaseProtocolStruct)
function CSCross1v1MatchQuery:__init()
	self.msg_type = 14115
end

function CSCross1v1MatchQuery:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteBegin(self.req_type)
end

-- 跨服1v1战斗记录查询
CSCross1v1WeekRecordQuery = CSCross1v1WeekRecordQuery or BaseClass(BaseProtocolStruct)
function CSCross1v1WeekRecordQuery:__init()
	self.msg_type = 14116
end

function CSCross1v1WeekRecordQuery:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 跨服1v1展示排行查询
CSGetCross1V1RankList = CSGetCross1V1RankList or BaseClass(BaseProtocolStruct)
function CSGetCross1V1RankList:__init()
	self.msg_type = 14117
end

function CSGetCross1V1RankList:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 灵鲲之战请求
CSCrossLieKunFBReq = CSCrossLieKunFBReq or BaseClass(BaseProtocolStruct)
function CSCrossLieKunFBReq:__init()
	self.msg_type = 14160
	self.opera_type = 0
	self.param1 = 0
	self.param2 = 0
end

function CSCrossLieKunFBReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(self.param1)
	MsgAdapter.WriteInt(self.param2)
end

--灵鲲之战玩家信息
SCCrossLieKunFBPlayerInfo = SCCrossLieKunFBPlayerInfo or BaseClass(BaseProtocolStruct)
function SCCrossLieKunFBPlayerInfo:__init()
	self.msg_type = 14175
	self.is_enter_main_zone = 0
	-- self.char_reserve_ch
	-- self.short_reserve_sh
	self.role_num = {}
	for i = 1 , GameEnum.LIEKUN_ZONE_TYPE_COUNT do
		self.role_num[i] = 0		-- 区域玩家人数
	end
end

function SCCrossLieKunFBPlayerInfo:Decode()
	self.is_enter_main_zone = MsgAdapter.ReadChar()	-- 是否可以进入主区域
	MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
	for i = 1 , GameEnum.LIEKUN_ZONE_TYPE_COUNT do
		self.role_num[i] = MsgAdapter.ReadInt()		-- 区域玩家人数
	end
end

--跨服3V3匹配状态
SCCrossMultiuserChallengeMatchingState = SCCrossMultiuserChallengeMatchingState or BaseClass(BaseProtocolStruct)
function SCCrossMultiuserChallengeMatchingState:__init()
	self.msg_type = 14130
end

function SCCrossMultiuserChallengeMatchingState:Decode()
	self.matching_state = MsgAdapter.ReadInt()
	local user_count = MsgAdapter.ReadInt()
	self.user_list = {}
	for i = 1, user_count do
		local vo = {}
		vo.plat_type = MsgAdapter.ReadInt()
		vo.server_id = MsgAdapter.ReadInt()
		vo.role_id = MsgAdapter.ReadInt()
		vo.role_name = MsgAdapter.ReadStrN(32)
		MsgAdapter.ReadChar()
		vo.sex = MsgAdapter.ReadChar()
		vo.prof = MsgAdapter.ReadChar()
		vo.camp = MsgAdapter.ReadChar()
		vo.level = MsgAdapter.ReadInt()
		vo.challenge_score = MsgAdapter.ReadInt()
		vo.win_percent = MsgAdapter.ReadInt()
		vo.capability = MsgAdapter.ReadLL()
		vo.mvp_count = MsgAdapter.ReadInt()
		self.user_list[i] = vo
	end
end

--跨服3V3排行
SCMultiuserChallengeRankList = SCMultiuserChallengeRankList or BaseClass(BaseProtocolStruct)
function SCMultiuserChallengeRankList:__init()
	self.msg_type = 14131
end

function SCMultiuserChallengeRankList:Decode()
	self.rank_type = MsgAdapter.ReadShort()
	local count = MsgAdapter.ReadShort()
	self.rank_list = {}
	for i = 1, count do
		local vo = {}
		vo.plat_type = MsgAdapter.ReadInt()
		vo.server_id = MsgAdapter.ReadInt()
		vo.role_id = MsgAdapter.ReadInt()
		vo.user_name = MsgAdapter.ReadStrN(32)
		vo.level = MsgAdapter.ReadShort()
		vo.prof = MsgAdapter.ReadChar()
		vo.sex = MsgAdapter.ReadChar()
		vo.match_total_count = MsgAdapter.ReadShort()
		vo.win_percent = MsgAdapter.ReadShort()
		vo.rank_value = MsgAdapter.ReadInt()
		vo.capability = MsgAdapter.ReadInt()
		self.rank_list[i] = vo
	end
end

--跨服3V3匹配通知
SCMultiuserChallengeHasMatchNotice = SCMultiuserChallengeHasMatchNotice or BaseClass(BaseProtocolStruct)
function SCMultiuserChallengeHasMatchNotice :__init()
	self.msg_type = 14132
end

function SCMultiuserChallengeHasMatchNotice :Decode()
	self.has_match = MsgAdapter.ReadInt()
end

-- 请求跨服3v3排行榜
CSGetMultiuserChallengeRankList = CSGetMultiuserChallengeRankList or BaseClass(BaseProtocolStruct)
function CSGetMultiuserChallengeRankList:__init()
	self.msg_type = 14145
	self.rank_type = 0
end

function CSGetMultiuserChallengeRankList:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.rank_type)
end

-- 请求跨服3v3是否有
CSCheckMultiuserChallengeHasMatch = CSCheckMultiuserChallengeHasMatch or BaseClass(BaseProtocolStruct)
function CSCheckMultiuserChallengeHasMatch:__init()
	self.msg_type = 14146
end

function CSCheckMultiuserChallengeHasMatch:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end