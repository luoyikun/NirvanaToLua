-- 通知客户端进入隐藏服
SCCrossEnterServer = SCCrossEnterServer or BaseClass(BaseProtocolStruct)

function SCCrossEnterServer:__init()
	self.msg_type = 5700
end

function SCCrossEnterServer:Decode()
	self.cross_activity_type = MsgAdapter.ReadInt()
	self.login_server_ip = MsgAdapter.ReadStrN(64)
	self.login_server_port = MsgAdapter.ReadInt()
	self.pname = MsgAdapter.ReadStrN(64)
	self.login_time = MsgAdapter.ReadUInt()
	self.login_str = MsgAdapter.ReadStrN(32)
	self.anti_wallow = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	self.server = MsgAdapter.ReadShort()
end

-- 跨服修罗塔个人活动信息
SCCrossXiuluoTowerSelfActivityInfo = SCCrossXiuluoTowerSelfActivityInfo or BaseClass(BaseProtocolStruct)

function SCCrossXiuluoTowerSelfActivityInfo:__init()
	self.msg_type = 5701
end

function SCCrossXiuluoTowerSelfActivityInfo:Decode()
	self.cur_layer = MsgAdapter.ReadShort()
	self.max_layer = MsgAdapter.ReadShort()
	self.immediate_realive_count = MsgAdapter.ReadShort()
	self.boss_num = MsgAdapter.ReadShort()
	self.total_kill_count = MsgAdapter.ReadInt()
	self.kill_role_count = MsgAdapter.ReadInt()
	self.cur_layer_kill_count = MsgAdapter.ReadInt()
	self.reward_cross_honor = MsgAdapter.ReadInt()
	self.score = MsgAdapter.ReadInt()
	self.score_reward_flag = MsgAdapter.ReadInt()
	self.refresh_boss_time = MsgAdapter.ReadUInt()
	self.gather_buff_end_timestamp = MsgAdapter.ReadUInt()
end

--  跨服修罗塔排行榜信息
SCCrossXiuluoTowerRankInfo = SCCrossXiuluoTowerRankInfo or BaseClass(BaseProtocolStruct)

function SCCrossXiuluoTowerRankInfo:__init()
	self.msg_type = 5702
end

function SCCrossXiuluoTowerRankInfo:Decode()
	local count = MsgAdapter.ReadInt()
	self.rank = {}
	for i = 1, count do
		local vo  = {}
		vo.user_name = MsgAdapter.ReadStrN(32)

		vo.finish_time = MsgAdapter.ReadUShort()
		vo.max_layer = (MsgAdapter.ReadShort() + 1)
		vo.prof = MsgAdapter.ReadChar()
		vo.camp = MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()
		self.rank[i] = vo
	end
end

--  跨服修罗塔改变层提示
SCCrossXiuluoTowerChangeLayerNotice = SCCrossXiuluoTowerChangeLayerNotice or BaseClass(BaseProtocolStruct)

function SCCrossXiuluoTowerChangeLayerNotice:__init()
	self.msg_type = 5703
end

function SCCrossXiuluoTowerChangeLayerNotice:Decode()
	self.is_drop_layer = MsgAdapter.ReadInt()
end

-- 跨服修罗塔结果
SCCrossXiuluoTowerUserResult = SCCrossXiuluoTowerUserResult or BaseClass(BaseProtocolStruct)

function SCCrossXiuluoTowerUserResult:__init()
	self.msg_type = 5704
end

function SCCrossXiuluoTowerUserResult:Decode()
	self.result_info = {}
	self.result_info.max_layer = MsgAdapter.ReadChar()
	self.result_info.rank_pos = MsgAdapter.ReadChar()
	self.result_info.kill_role_count = MsgAdapter.ReadShort()
	self.result_info.reward_cross_honor = MsgAdapter.ReadInt()
end

-- 跨服修罗塔属性加成
SCCrossXiuluoTowerInfo = SCCrossXiuluoTowerInfo or BaseClass(BaseProtocolStruct)

function SCCrossXiuluoTowerInfo:__init()
	self.msg_type = 5705
end

function SCCrossXiuluoTowerInfo:Decode()
	self.buy_realive_count = MsgAdapter.ReadInt()
	self.add_gongji_per = MsgAdapter.ReadShort()
	self.add_hp_per = MsgAdapter.ReadShort()
end

-- 跨服荣誉值改变
SCCrossHonorChange = SCCrossHonorChange	or BaseClass(BaseProtocolStruct)

function SCCrossHonorChange:__init()
	self.msg_type = 5706
end

function SCCrossHonorChange:Decode()
	self.honor = MsgAdapter.ReadInt()
	self.delta_honor = MsgAdapter.ReadInt()
end

-- 跨服1v1活动信息
SCCrossActivity1V1SelfInfo = SCCrossActivity1V1SelfInfo	or BaseClass(BaseProtocolStruct)

function SCCrossActivity1V1SelfInfo:__init()
	self.msg_type = 5707
end

function SCCrossActivity1V1SelfInfo:Decode()
	self.cross_score_1v1 = MsgAdapter.ReadInt()
	self.cross_day_join_1v1_count = MsgAdapter.ReadInt()

	self.cross_1v1_join_time_reward_flag = MsgAdapter.ReadShort()
	self.cross_1v1_fetch_score_reward_flag = MsgAdapter.ReadShort()

	self.today_buy_times = MsgAdapter.ReadShort()
	self.cur_season = MsgAdapter.ReadShort()

	self.cross_1v1_curr_activity_add_score = MsgAdapter.ReadInt()

	self.cross_lvl_total_join_times = MsgAdapter.ReadShort() 
	self.cross_1v1_total_win_times = MsgAdapter.ReadShort()
	self.cross_1v1_gongxun = MsgAdapter.ReadInt()

	self.cross_1v1_dur_win_times = MsgAdapter.ReadShort()	
	MsgAdapter.ReadShort()
	self.cross_1v1_use_ring = {}
	for i = 1, 4 do
		self.cross_1v1_use_ring[i] = MsgAdapter.ReadChar()
	end

	self.cross_1v1_have_ring ={}
	for i = 1, GameEnum.CROSS_1V1_SEASON_MAX do
		local data = MsgAdapter.ReadChar()
		self.cross_1v1_have_ring[i] = data
	end
end

-- 跨服1V1战斗开始
SCCross1v1FightStart = SCCross1v1FightStart	or BaseClass(BaseProtocolStruct)

function SCCross1v1FightStart:__init()
	self.msg_type = 5708
	self.pk_start_timestamp = 0
end

function SCCross1v1FightStart:Decode()
	self.timestamp_type = MsgAdapter.ReadInt()
	self.pk_start_timestamp = MsgAdapter.ReadUInt()
	self.fight_start_timestmap = MsgAdapter.ReadUInt()
end


-- 跨服3v3主角信息刷新
SCCrossMultiuserChallengeSelfInfoRefresh = SCCrossMultiuserChallengeSelfInfoRefresh	or BaseClass(BaseProtocolStruct)

function SCCrossMultiuserChallengeSelfInfoRefresh:__init()
	self.msg_type = 5709
end

function SCCrossMultiuserChallengeSelfInfoRefresh:Decode()
	self.self_side = MsgAdapter.ReadInt()
	self.kills = MsgAdapter.ReadInt()
	self.assist = MsgAdapter.ReadInt()
	self.dead = MsgAdapter.ReadInt()
end


-- 跨服3v3信息刷新
SCCrossMultiuserChallengeMatchInfoRefresh = SCCrossMultiuserChallengeMatchInfoRefresh or BaseClass(BaseProtocolStruct)

function SCCrossMultiuserChallengeMatchInfoRefresh:__init()
	self.msg_type = 5710
end

function SCCrossMultiuserChallengeMatchInfoRefresh:Decode()
	self.strong_hold_rate_info = MsgAdapter.ReadInt()
	self.side_score_list = {}
	for i = 0, 1 do
		self.side_score_list[i] = MsgAdapter.ReadInt()
	end
end

-- 跨服3v3匹配状态
SCCrossMultiuserChallengeMatchState = SCCrossMultiuserChallengeMatchState or BaseClass(BaseProtocolStruct)

function SCCrossMultiuserChallengeMatchState:__init()
	self.msg_type = 5711
end

function SCCrossMultiuserChallengeMatchState:Decode()
	self.match_state = MsgAdapter.ReadShort()
	self.win_side = MsgAdapter.ReadShort()
	self.next_state_time = MsgAdapter.ReadUInt()
	self.user_info_list = {}
	for i = 1, GameEnum.CROSS_MULTIUSER_CHALLENGE_SIDE_MEMBER_COUNT * 2 do
		local vo ={}
		vo.plat_type = MsgAdapter.ReadShort()
		vo.obj_id = MsgAdapter.ReadUShort()
		vo.role_id = MsgAdapter.ReadInt()
		vo.name = MsgAdapter.ReadStrN(32)
		vo.prof = MsgAdapter.ReadShort()
		vo.sex = MsgAdapter.ReadShort()
		vo.kills = MsgAdapter.ReadShort()
		vo.assist = MsgAdapter.ReadShort()
		vo.dead = MsgAdapter.ReadShort()
		vo.occupy = MsgAdapter.ReadShort()
		vo.origin_score = MsgAdapter.ReadInt()
		vo.add_score = MsgAdapter.ReadInt()
		vo.add_honor = MsgAdapter.ReadInt()
		vo.add_gongxun = MsgAdapter.ReadInt()
		vo.is_mvp = MsgAdapter.ReadInt()
		vo.index = i
		if self.win_side == 1 then 					--把胜利方放到前面
			if i <= 3 then
				vo.team = 1
				self.user_info_list[i + 3] = vo
			else
				vo.team = 0
				self.user_info_list[i - 3] = vo
			end
		else
			if i <= 3 then
				vo.team = 1
			else
				vo.team = 0
			end
			self.user_info_list[i] = vo
		end
	end
end

-- 跨服3v3基本信息
SCCrossMultiuserChallengeBaseSelfSideInfo = SCCrossMultiuserChallengeBaseSelfSideInfo or BaseClass(BaseProtocolStruct)

function SCCrossMultiuserChallengeBaseSelfSideInfo:__init()
	self.msg_type = 5712
end

function SCCrossMultiuserChallengeBaseSelfSideInfo:Decode()
	local user_count = MsgAdapter.ReadInt()
	self.user_list = {}
	for i = 1, user_count do
		local vo = {}
		vo.plat_type = MsgAdapter.ReadInt()
		vo.server_id = MsgAdapter.ReadInt()
		vo.uid = MsgAdapter.ReadInt()
		vo.user_name = MsgAdapter.ReadStrN(32)
		MsgAdapter.ReadChar()
		vo.sex = MsgAdapter.ReadChar()
		vo.prof = MsgAdapter.ReadChar()
		vo.camp = MsgAdapter.ReadChar()
		vo.level = MsgAdapter.ReadInt()
		vo.challenge_score = MsgAdapter.ReadInt()
		vo.win_percent = MsgAdapter.ReadInt()
		vo.mvp_count = MsgAdapter.ReadInt()
		vo.capability = MsgAdapter.ReadLL()
		self.user_list[i] = vo
	end
end

-- 跨服3v3角色活动信息
SCCrossMultiuserChallengeSelfActicityInfo = SCCrossMultiuserChallengeSelfActicityInfo or BaseClass(BaseProtocolStruct)

function SCCrossMultiuserChallengeSelfActicityInfo:__init()
	self.msg_type = 5713
end

function SCCrossMultiuserChallengeSelfActicityInfo:Decode()
	self.info = {} 
	self.info.challenge_mvp_count = MsgAdapter.ReadInt()
	self.info.challenge_score = MsgAdapter.ReadInt()
	self.info.challenge_total_match_count = MsgAdapter.ReadInt()
	self.info.challenge_win_match_count = MsgAdapter.ReadInt()
	self.info.win_percent = MsgAdapter.ReadShort()
	self.info.today_match_count = MsgAdapter.ReadShort()
	self.info.matching_state = MsgAdapter.ReadInt()
	self.info.join_reward_fetch_flag = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
	self.info.cross_3v3_season_reward_use = {} 
	for i = 1, 4 do
		self.info.cross_3v3_season_reward_use[i] = MsgAdapter.ReadChar()
	end

	self.info.cross_3v3_season_reward = {} 
	for i = 1, GameEnum.CROSS_1V1_SEASON_MAX do
		self.info.cross_3v3_season_reward[i] = MsgAdapter.ReadChar()
	end

	self.info.gongxun_reward_fetch_flag = MsgAdapter.ReadInt()
	self.info.gongxun_value = MsgAdapter.ReadInt()

	self.info.season_count = MsgAdapter.ReadInt()
end

-- 跨服3v3获取队友位置信息
SCMultiuserChallengeTeamMemberPosList = SCMultiuserChallengeTeamMemberPosList or BaseClass(BaseProtocolStruct)

function SCMultiuserChallengeTeamMemberPosList:__init()
	self.msg_type = 5714
end

function SCMultiuserChallengeTeamMemberPosList:Decode()
	local member_count = MsgAdapter.ReadInt()
	self.team_member_list = {}
	for i = 1, member_count do
		local member_info = {}
		member_info.role_id = MsgAdapter.ReadInt()
		member_info.obj_id = MsgAdapter.ReadUShort()
		member_info.reserved = MsgAdapter.ReadChar()
		member_info.is_leave_scene = MsgAdapter.ReadChar()
		member_info.pos_x = MsgAdapter.ReadShort()
		member_info.pos_y = MsgAdapter.ReadShort()
		member_info.dir = MsgAdapter.ReadFloat()
		member_info.distance = MsgAdapter.ReadFloat()
		member_info.move_speed = MsgAdapter.ReadInt()
		self.team_member_list[i] = member_info
	end
end

-- 请求开始跨服
CSCrossStartReq = CSCrossStartReq or BaseClass(BaseProtocolStruct)
function CSCrossStartReq:__init()
	self.msg_type = 5750
	self.cross_activity_type = 0
	self.param = 0
	self.param_1 = 0
	self.param_2 = 0
end
function CSCrossStartReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.cross_activity_type)
	MsgAdapter.WriteUShort(self.param)
	MsgAdapter.WriteUShort(self.param_1)
	MsgAdapter.WriteUShort(self.param_2)
	MsgAdapter.WriteUShort(self.sos_pos_x)
	MsgAdapter.WriteUShort(self.sos_pos_y)
end

-- 跨服修罗塔报名
CSCrossXiuluoTowerJoinReq = CSCrossXiuluoTowerJoinReq or BaseClass(BaseProtocolStruct)
function CSCrossXiuluoTowerJoinReq:__init()
	self.msg_type = 5751
end
function CSCrossXiuluoTowerJoinReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 跨服修罗塔购买buff
CSCrossXiuluoTowerBuyBuff = CSCrossXiuluoTowerBuyBuff or BaseClass(BaseProtocolStruct)
function CSCrossXiuluoTowerBuyBuff:__init()
	self.msg_type = 5752
	self.is_buy_realive_count = 0
	self.is_use_gold_bind = 0

end
function CSCrossXiuluoTowerBuyBuff:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.is_buy_realive_count)
	MsgAdapter.WriteShort(self.is_use_gold_bind)
end

-- 跨服1v1匹配请求
CSCrossMatch1V1Req = CSCrossMatch1V1Req or BaseClass(BaseProtocolStruct)
function CSCrossMatch1V1Req:__init()
	self.msg_type = 5753

end
function CSCrossMatch1V1Req:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 跨服1v1战斗准备
CSCross1v1FightReady = CSCross1v1FightReady or BaseClass(BaseProtocolStruct)
function CSCross1v1FightReady:__init()
	self.msg_type = 5754

end
function CSCross1v1FightReady:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 跨服1v1领取奖励
CSCross1v1FetchRewardReq = CSCross1v1FetchRewardReq or BaseClass(BaseProtocolStruct)
function CSCross1v1FetchRewardReq:__init()
	self.msg_type = 5755
end

function CSCross1v1FetchRewardReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.fetch_type)
	MsgAdapter.WriteShort(self.seq)
end

-- 跨服1v1购买次数
CSCross1v1BuyTimeReq = CSCross1v1BuyTimeReq or BaseClass(BaseProtocolStruct)
function CSCross1v1BuyTimeReq:__init()
	self.msg_type = 5762
end

function CSCross1v1BuyTimeReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--穿戴戒指
CSCross1v1WearRingReq = CSCross1v1WearRingReq or BaseClass(BaseProtocolStruct)
function CSCross1v1WearRingReq:__init()
	self.msg_type = 5763
end

function CSCross1v1WearRingReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opr_type)
	MsgAdapter.WriteInt(self.ring_seq)
end

--穿戴令牌
CSCrossPVPWearCardReq = CSCrossPVPWearCardReq or BaseClass(BaseProtocolStruct)
function CSCrossPVPWearCardReq:__init()
	self.msg_type = 5765
end

function CSCrossPVPWearCardReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opr_type)
	MsgAdapter.WriteInt(self.ring_seq)
end

CSCross1v1MatchResultReq = CSCross1v1MatchResultReq or BaseClass(BaseProtocolStruct)
function CSCross1v1MatchResultReq:__init()
	self.msg_type = 5764
	self.req_type = 0
end

function CSCross1v1MatchResultReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.req_type)
end

--跨服3v3请求匹配（队长发起）
CSCrossMultiuserChallengeMatchgingReq = CSCrossMultiuserChallengeMatchgingReq or BaseClass(BaseProtocolStruct)
function CSCrossMultiuserChallengeMatchgingReq:__init()
	self.msg_type = 5756
end

function CSCrossMultiuserChallengeMatchgingReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 跨服3v3请求同队基本信息
CSCrossMultiuserChallengeGetBaseSelfSideInfo = CSCrossMultiuserChallengeGetBaseSelfSideInfo or BaseClass(BaseProtocolStruct)
function CSCrossMultiuserChallengeGetBaseSelfSideInfo:__init()
	self.msg_type = 5757
end

function CSCrossMultiuserChallengeGetBaseSelfSideInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 跨服3v3获取每日奖励
CSCrossMultiuserChallengeFetchDaycountReward = CSCrossMultiuserChallengeFetchDaycountReward or BaseClass(BaseProtocolStruct)
function CSCrossMultiuserChallengeFetchDaycountReward:__init()
	self.msg_type = 5758
end

function CSCrossMultiuserChallengeFetchDaycountReward:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.seq)
end

-- 跨服3v3取消匹配
CSCrossMultiuerChallengeCancelMatching = CSCrossMultiuerChallengeCancelMatching or BaseClass(BaseProtocolStruct)
function CSCrossMultiuerChallengeCancelMatching:__init()
	self.msg_type = 5759
end

function CSCrossMultiuerChallengeCancelMatching:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 跨服3v3，请求队友位置信息
CSMultiuserChallengeReqSideMemberPos = CSMultiuserChallengeReqSideMemberPos or BaseClass(BaseProtocolStruct)
function CSMultiuserChallengeReqSideMemberPos:__init()
	self.msg_type = 5760
end

function CSMultiuserChallengeReqSideMemberPos:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 领取积分奖励
CSCrossTuanzhanFetchReward = CSCrossTuanzhanFetchReward or BaseClass(BaseProtocolStruct)
function CSCrossTuanzhanFetchReward:__init()
	self.msg_type = 5761
end

function CSCrossTuanzhanFetchReward:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 比赛状态通知
SCCrossTuanzhanStateNotify = SCCrossTuanzhanStateNotify or BaseClass(BaseProtocolStruct)
function SCCrossTuanzhanStateNotify:__init()
	self.msg_type = 5715
end

function SCCrossTuanzhanStateNotify:Decode()
	self.fight_start_time = MsgAdapter.ReadUInt()					-- 战斗开始时间
	self.activity_end_time = MsgAdapter.ReadUInt()					-- 活动结束时间
	self.rand_side_time = MsgAdapter.ReadUInt()						-- 随机阵营时间
end

-- 玩家信息
SCCrossTuanzhanPlayerInfo = SCCrossTuanzhanPlayerInfo or BaseClass(BaseProtocolStruct)
function SCCrossTuanzhanPlayerInfo:__init()
	self.msg_type = 5716
end

function SCCrossTuanzhanPlayerInfo:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.is_broacast = MsgAdapter.ReadShort()
	self.side = MsgAdapter.ReadShort()						-- 所在阵营
	self.score_reward_fetch_seq = MsgAdapter.ReadShort()	-- 奖励领取档位
	self.score = MsgAdapter.ReadUInt()						-- 积分
	self.kill_num = MsgAdapter.ReadUInt() 					-- 击杀次数
	self.assist_kill_num = MsgAdapter.ReadUInt() 			-- 助攻次数
	self.dur_kill_num = MsgAdapter.ReadUInt()				-- 连杀次数
end

-- 排名信息
SCCrossTuanzhanRankInfo = SCCrossTuanzhanRankInfo or BaseClass(BaseProtocolStruct)
function SCCrossTuanzhanRankInfo:__init()
	self.msg_type = 5717
end

function SCCrossTuanzhanRankInfo:Decode()
	local rank_list_count = MsgAdapter.ReadInt()
	self.rank_list = {}
	for i = 1, rank_list_count do
		local vo = {}
		vo.rank = i
		vo.side = MsgAdapter.ReadShort()
		MsgAdapter.ReadShort()
		vo.score = MsgAdapter.ReadUInt()
		vo.name = MsgAdapter.ReadStrN(32)
		vo.kill = MsgAdapter.ReadShort()
		vo.assist = MsgAdapter.ReadShort()
		self.rank_list[i] = vo
	end
end

-- 阵营积分信息
SCCrossTuanzhanSideInfo = SCCrossTuanzhanSideInfo or BaseClass(BaseProtocolStruct)
function SCCrossTuanzhanSideInfo:__init()
	self.msg_type = 5718
end

function SCCrossTuanzhanSideInfo:Decode()
	self.side_score_list = {}
	for i = 1, CROSS_TUANZHAN_SIDE.CROSS_TUANZHAN_SIDE_MAX do
		self.side_score_list[i] = MsgAdapter.ReadUInt()
	end
end

-- 通天柱子信息
SCCrossTuanzhanPillaInfo = SCCrossTuanzhanPillaInfo or BaseClass(BaseProtocolStruct)
function SCCrossTuanzhanPillaInfo:__init()
	self.msg_type = 5719
end

function SCCrossTuanzhanPillaInfo:Decode()
	local pilla_list_count = MsgAdapter.ReadUShort()
	MsgAdapter.ReadShort()
	self.pilla_list = {}
	for i = 1, pilla_list_count do
		local vo= {}
		vo.monster_id = MsgAdapter.ReadUShort() 			-- 柱子怪物id
		vo.obj_id = MsgAdapter.ReadUShort()					-- 柱子的对象id
		vo.owner_side = MsgAdapter.ReadShort()				-- 占领柱子的阵营
		vo.index = MsgAdapter.ReadShort()					-- 柱子索引
		vo.owner_name = MsgAdapter.ReadStrN(32)				-- 占领柱子玩家名
		self.pilla_list[i] = vo
	end
end

-- 连杀信息变更
SCCrossTuanzhanPlayerDurKillInfo = SCCrossTuanzhanPlayerDurKillInfo or BaseClass(BaseProtocolStruct)
function SCCrossTuanzhanPlayerDurKillInfo:__init()
	self.msg_type = 5720
end

function SCCrossTuanzhanPlayerDurKillInfo:Decode()
	self.obj_id = MsgAdapter.ReadUShort()					-- 玩家对象id
	self.reserve_sh = MsgAdapter.ReadShort()
	self.dur_kill_num = MsgAdapter.ReadUInt()				-- 连杀次数
end

-- 比赛结果通知
SCCrossTuanzhanResultInfo = SCCrossTuanzhanResultInfo or BaseClass(BaseProtocolStruct)
function SCCrossTuanzhanResultInfo:__init()
	self.msg_type = 5721
end

function SCCrossTuanzhanResultInfo:Decode()
	self.personal_score = MsgAdapter.ReadUInt()								-- 个人积分
	self.side_score = MsgAdapter.ReadUInt()									-- 阵营积分
	self.result = MsgAdapter.ReadShort()									-- 比赛结果，0 失败，1 胜利
	self.reserve_sh = MsgAdapter.ReadShort()
end

-------跨服牧场，玩家信息通知
SCCrossPasturePlayerInfo = SCCrossPasturePlayerInfo or BaseClass(BaseProtocolStruct)
function SCCrossPasturePlayerInfo:__init()
	self.msg_type = 5722
	self.score = 0
	self.left_get_score_times = 0
	self.reserve = 0
	self.x = 0
	self.y = 0
	self.special_monster_refresh_time = 0
end

function SCCrossPasturePlayerInfo:Decode()
	self.score = MsgAdapter.ReadInt()							-- 当前积分
	self.left_get_score_times = MsgAdapter.ReadShort()			-- 剩余获取积分次数
	self.reserve = MsgAdapter.ReadShort()
	self.x = MsgAdapter.ReadInt()
	self.y = MsgAdapter.ReadInt()
	self.special_monster_refresh_time = MsgAdapter.ReadUInt()	-- 特殊怪物刷新时间戳
end

-- 服务器即将关闭通知
SCServerShutdownNotify = SCServerShutdownNotify or BaseClass(BaseProtocolStruct)
function SCServerShutdownNotify:__init()
	self.msg_type = 5726

	self.remain_second = 0
end

function SCServerShutdownNotify:Decode()
	self.remain_second = MsgAdapter.ReadInt()							-- 离关闭服务器剩余秒数
end

-- 跨服修罗塔BUFF信息
SCCrossXiuluoTowerBuffInfo = SCCrossXiuluoTowerBuffInfo or BaseClass(BaseProtocolStruct)
function SCCrossXiuluoTowerBuffInfo:__init()
	self.msg_type = 5727

	self.id = 0
	self.buff_num = 0
	self.next_send_reward_time = 0
end

function SCCrossXiuluoTowerBuffInfo:Decode()
	self.id = MsgAdapter.ReadUShort()
	self.buff_num = MsgAdapter.ReadShort()
	self.next_send_reward_time = MsgAdapter.ReadUInt()
end

-- 购买跨服修罗塔无敌BUFF
CSCrossXiuluoTowerBuyBuffReq = CSCrossXiuluoTowerBuyBuffReq or BaseClass(BaseProtocolStruct)
function CSCrossXiuluoTowerBuyBuffReq:__init()
	self.msg_type = 5735
end

function CSCrossXiuluoTowerBuyBuffReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 请求积分奖励
CSCrossXiuluoTowerScoreRewardReq = CSCrossXiuluoTowerScoreRewardReq or BaseClass(BaseProtocolStruct)
function CSCrossXiuluoTowerScoreRewardReq:__init()
	self.msg_type = 5728
	self.index = 0
end

function CSCrossXiuluoTowerScoreRewardReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.index)
end

-- 跨服修罗塔采集物信息
SCCrossXiuluoTowerGatherInfo = SCCrossXiuluoTowerGatherInfo or BaseClass(BaseProtocolStruct)
function SCCrossXiuluoTowerGatherInfo:__init()
	self.msg_type = 5729
	self.count = 0
	self.info_list = {}
end

function SCCrossXiuluoTowerGatherInfo:Decode()
	self.count = MsgAdapter.ReadInt()
	self.info_list = {}
	for i = 1, self.count do
		self.info_list[i] = {}
		self.info_list[i].gather_id = MsgAdapter.ReadInt()
		self.info_list[i].gather_count = MsgAdapter.ReadInt()
	end
end



-- 跨服牧场玩家吸引到怪物通知 5732
-- enum CROSS_PSATURE_ANIMAL_NOTIC_TYPE
--   {
--     CROSS_PSATURE_ANIMAL_NOTIC_TYPE_FOLLOW = 0,
--     CROSS_PSATURE_ANIMAL_NOTIC_TYPE_BE_ROBBED = 1,
--   };
SCCPPlayerHasAttachAnimalNotic = SCCPPlayerHasAttachAnimalNotic or BaseClass(BaseProtocolStruct)
function SCCPPlayerHasAttachAnimalNotic:__init()
	self.msg_type = 5732
	self.notic_reason = 0 --0跟随 1被抢
	self.robber_name = 0
end

function SCCPPlayerHasAttachAnimalNotic:Decode()
	self.notic_reason = MsgAdapter.ReadInt()
	self.robber_name = MsgAdapter.ReadStrN(32)
end

---------------------跨服六界三倍时间---------------------
SCCrossGuildBattleSpecialTimeNotice = SCCrossGuildBattleSpecialTimeNotice or BaseClass(BaseProtocolStruct)
function SCCrossGuildBattleSpecialTimeNotice:__init()
	self.msg_type = 5733
end

function SCCrossGuildBattleSpecialTimeNotice:Decode()
	self.status = MsgAdapter.ReadInt()
	self.act_end_timestamp = MsgAdapter.ReadUInt()
end
---------------------跨服六界三倍时间END---------------------

---------------------跨服元素熔炉---------------------
SCCrossPastureRankInfo = SCCrossPastureRankInfo or BaseClass(BaseProtocolStruct)
function SCCrossPastureRankInfo:__init()
	self.msg_type = 5734
end

function SCCrossPastureRankInfo:Decode()
	self.rank_list = {}
	self.rank_count = MsgAdapter:ReadInt()
	for i = 1, self.rank_count do
		self.rank_list[i] = {}
		self.rank_list[i].uid = MsgAdapter:ReadInt()
		self.rank_list[i].name = MsgAdapter.ReadStrN(32)
		self.rank_list[i].score = MsgAdapter:ReadInt()
	end
end
---------------------跨服元素熔炉END---------------------

--穿戴令牌
CSMultiuserChallengeWearCardReq = CSMultiuserChallengeWearCardReq or BaseClass(BaseProtocolStruct)
function CSMultiuserChallengeWearCardReq:__init()
	self.msg_type = 5736
end

function CSMultiuserChallengeWearCardReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opr_type)
	MsgAdapter.WriteInt(self.card_seq)
end


CSCrossMultiuserChallengeFetchGongxunReward  = CSCrossMultiuserChallengeFetchGongxunReward  or BaseClass(BaseProtocolStruct)
function CSCrossMultiuserChallengeFetchGongxunReward:__init()
	self.msg_type = 5737
end

function CSCrossMultiuserChallengeFetchGongxunReward:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.seq)
	MsgAdapter.WriteShort(0)
end

SCCrossTianjiangBossStatusInfo = SCCrossTianjiangBossStatusInfo or BaseClass(BaseProtocolStruct)
function SCCrossTianjiangBossStatusInfo:__init()
	self.msg_type = 5738
	self.scene_id = 0
	self.boss_count = 0
	self.boss_list = {}
end

function SCCrossTianjiangBossStatusInfo:Decode()
	self.scene_id = MsgAdapter.ReadShort()
	self.boss_count = MsgAdapter.ReadShort()
	self.boss_list = {}
	for i = 1, self.boss_count do
		local vo = {}
		vo.scene_id = MsgAdapter.ReadShort()
		vo.monster_id = MsgAdapter.ReadUShort()
		vo.status = MsgAdapter.ReadInt()
		vo.next_refresh_timestamp = MsgAdapter.ReadUInt()
		vo.kill_info_count = MsgAdapter.ReadInt()
		local kill_vo = {}
		for k = 1, 5 do
			kill_vo[k] = {}
			kill_vo[k].killer_uid = MsgAdapter.ReadInt()
			kill_vo[k].killer_name = MsgAdapter.ReadStrN(32)
			kill_vo[k].killier_time = MsgAdapter.ReadUInt()
		end
		vo.killer_info = kill_vo
		self.boss_list[vo.monster_id] = vo
	end
end

--跨服神武boss请求
CSCrossShenwuOperatorReq = CSCrossShenwuOperatorReq or BaseClass(BaseProtocolStruct)
function CSCrossShenwuOperatorReq:__init()
	self.msg_type = 5739
	self.opera_type = 0
	self.param_1 = 0
end

function CSCrossShenwuOperatorReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opera_type)
	MsgAdapter.WriteInt(self.param_1)
end


-- 跨服神武boss信息
SCCrossShenwuBossInfo = SCCrossShenwuBossInfo or BaseClass(BaseProtocolStruct)
function SCCrossShenwuBossInfo:__init()
	self.msg_type = 5740
	self.weary_val_info = {}
end

function SCCrossShenwuBossInfo:Decode()
	self.weary_val_info.weary_val_limit = MsgAdapter.ReadShort()	--疲劳值上限
	self.weary_val_info.weary_val = MsgAdapter.ReadShort()			--当前疲劳值
end

-- SCCrossShenwuBossStatusInfo = SCCrossShenwuBossStatusInfo or BaseClass(BaseProtocolStruct)
-- function SCCrossShenwuBossStatusInfo:__init()
-- 	self.msg_type = 5741
-- 	self.scene_id = 0
-- 	self.boss_count = 0
-- 	self.boss_list = {}
-- end

-- function SCCrossShenwuBossStatusInfo:Decode()
-- 	self.scene_id = MsgAdapter.ReadShort()
-- 	self.boss_count = MsgAdapter.ReadShort()
-- 	self.boss_list = {}
-- 	for i = 1, self.boss_count do
-- 		local vo = {}
-- 		vo.scene_id = MsgAdapter.ReadShort()
-- 		vo.monster_id = MsgAdapter.ReadUShort()
-- 		vo.status = MsgAdapter.ReadInt()
-- 		vo.next_refresh_timestamp = MsgAdapter.ReadUInt()
-- 		vo.kill_info_count = MsgAdapter.ReadInt()
-- 		local kill_vo = {}
-- 		for k = 1, 5 do
-- 			kill_vo[k] = {}
-- 			kill_vo[k].killer_uid = MsgAdapter.ReadInt()
-- 			kill_vo[k].killer_name = MsgAdapter.ReadStrN(32)
-- 			kill_vo[k].killier_time = MsgAdapter.ReadUInt()
-- 		end
-- 		vo.killer_info = kill_vo
-- 		self.boss_list[vo.monster_id] = vo
-- 	end
-- end

  --修罗塔上10层
SCCossXiuluoTowerRankTitleInfo = SCCossXiuluoTowerRankTitleInfo or BaseClass(BaseProtocolStruct)
function SCCossXiuluoTowerRankTitleInfo:__init()
	self.msg_type = 5741
end

function SCCossXiuluoTowerRankTitleInfo:Decode()
	self.rank_count = MsgAdapter.ReadInt()
	self.rank_list = {}
	for i = 1, self.rank_count do
		local rank_list = {}
		rank_list.uuid = MsgAdapter.ReadLL()
		rank_list.name = MsgAdapter.ReadStrN(32)
		rank_list.finish_time = MsgAdapter.ReadUInt()
		self.rank_list[i] = rank_list
	end
end


  --修罗塔Boss血量
SCCossXiuluoTowerBossInfo = SCCossXiuluoTowerBossInfo or BaseClass(BaseProtocolStruct)
function SCCossXiuluoTowerBossInfo:__init()
	self.msg_type = 5742
	self.monster_id = 0
	self.max_hp = 0
	self.cur_hp = 0
end

function SCCossXiuluoTowerBossInfo:Decode()
	self.monster_id = MsgAdapter.ReadInt()
	self.max_hp = MsgAdapter.ReadLL()
	self.cur_hp = MsgAdapter.ReadLL()
end

SCCrossShenwuBossSceneInfo = SCCrossShenwuBossSceneInfo or BaseClass(BaseProtocolStruct)
function SCCrossShenwuBossSceneInfo:__init()
	self.msg_type = 5743
	self.act_end_timestamp = 0	  --天将BOSS活动结束时间
end

function SCCrossShenwuBossSceneInfo:Decode()
	self.act_end_timestamp = MsgAdapter.ReadUInt()
end

SCCrossShenwuBossCanEnterNotice = SCCrossShenwuBossCanEnterNotice or BaseClass(BaseProtocolStruct)
function SCCrossShenwuBossCanEnterNotice:__init()
	self.msg_type = 5744
	self.monster_id = 0
end

function SCCrossShenwuBossCanEnterNotice:Decode()
	self.monster_id = MsgAdapter.ReadInt()
end
-----------------------跨服天将----END-(合w2)---------

---------------------跨服月黑风高---------------------
SCCrossDarkNightUserInfo = SCCrossDarkNightUserInfo or BaseClass(BaseProtocolStruct)
function SCCrossDarkNightUserInfo:__init()
	self.msg_type = 5770
end

function SCCrossDarkNightUserInfo:Decode()
	self.score = MsgAdapter:ReadInt()
	self.box_count = MsgAdapter:ReadInt()
	self.total_reward_box_count = MsgAdapter:ReadInt()
	self.is_finish = MsgAdapter:ReadShort()
	self.reward_count = MsgAdapter:ReadShort()
	self.reward_list = {}
	for i = 1, self.reward_count do
		local item_list = {}
		for i = 1,2 do
			local temp_list = {}
			temp_list.item_id = MsgAdapter:ReadUShort()
			temp_list.num = MsgAdapter:ReadShort()
			table.insert(item_list, temp_list)
		end
		table.insert(self.reward_list, item_list)
	end
end

SCCrossDarkNightRankInfo = SCCrossDarkNightRankInfo or BaseClass(BaseProtocolStruct)
function SCCrossDarkNightRankInfo:__init()
	self.msg_type = 5771
	self.rank_list = {}
end

function SCCrossDarkNightRankInfo:Decode()
	self.rank_list = {}
	self.rank_count = MsgAdapter:ReadInt()
	for i = 1, self.rank_count do
		self.rank_list[i] = {}
		self.rank_list[i].name = MsgAdapter.ReadStrN(32)
		self.rank_list[i].rank_val = MsgAdapter:ReadInt()
	end
end

SCCrossDarkNightBossInfo = SCCrossDarkNightBossInfo or BaseClass(BaseProtocolStruct)
function SCCrossDarkNightBossInfo:__init()
	self.msg_type = 5772
	self.boss_info = {}
	self.boss_info_num = GameEnum.CROSS_DARK_NIGHT_BOSS_POS_INDEX_MAX
end

function SCCrossDarkNightBossInfo:Decode()
	for i = 1, GameEnum.CROSS_DARK_NIGHT_BOSS_POS_INDEX_MAX do
		self.boss_info[i] = {}
		self.boss_info[i].monster_id = MsgAdapter:ReadInt()
		self.boss_info[i].pos_x = MsgAdapter:ReadInt()
		self.boss_info[i].pos_y = MsgAdapter:ReadInt()
		self.boss_info[i].max_hp = MsgAdapter:ReadLL()
		self.boss_info[i].cur_hp = MsgAdapter:ReadLL()
		self.boss_info[i].boss_status = MsgAdapter:ReadShort()
		MsgAdapter:ReadShort()
	end
end

SCCrossDarkNightPlayerInfoBroadcast = SCCrossDarkNightPlayerInfoBroadcast or BaseClass(BaseProtocolStruct)
function SCCrossDarkNightPlayerInfoBroadcast:__init()
	self.msg_type = 5773
	self.obj_id = 0
	self.box_count = 0
end

function SCCrossDarkNightPlayerInfoBroadcast:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.box_count = MsgAdapter:ReadShort()
end

SCCrossDarkNightRewardTimestampInfo = SCCrossDarkNightRewardTimestampInfo or BaseClass(BaseProtocolStruct)
function SCCrossDarkNightRewardTimestampInfo:__init()
	self.msg_type = 5774
	self.next_check_reward_timestamp = 0
end

function SCCrossDarkNightRewardTimestampInfo:Decode()
	self.next_check_reward_timestamp = MsgAdapter:ReadUInt()
end
---------------------跨服月黑风高END---------------------


--------------月黑风高榜首信息-----------------
CSCrossDarkNightRankOpera = CSCrossDarkNightRankOpera or BaseClass(BaseProtocolStruct)
function CSCrossDarkNightRankOpera:__init()
	self.msg_type = 5776
	self.opera_type = 0
end

function CSCrossDarkNightRankOpera:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opera_type)
end

SCCrossDarkNightTopPlayerPosi =  SCCrossDarkNightTopPlayerPosi or BaseClass(BaseProtocolStruct)
function SCCrossDarkNightTopPlayerPosi:__init()
	self.msg_type = 5775
	self.obj_id = -1
	self.pos_x = 0
	self.pos_y = 0
end

function SCCrossDarkNightTopPlayerPosi:Decode()
	self.obj_id = MsgAdapter.ReadInt()
	self.pos_x = MsgAdapter.ReadInt()
	self.pos_y = MsgAdapter.ReadInt()
end
--------------月黑风高榜首信息END-----------------



------------跨服BOSS-----------------
SCCrossBossBossKillRecord = SCCrossBossBossKillRecord or BaseClass(BaseProtocolStruct)
function SCCrossBossBossKillRecord:__init()
	self.msg_type = 5738

	self.record_count = 0
	self.killer_record_list = {}
end

function SCCrossBossBossKillRecord:Decode()
	self.record_count = MsgAdapter.ReadInt()
	self.killer_record_list = {}
	for i = 1, self.record_count do
		local vo = {}
		vo.uuid = MsgAdapter.ReadLL()
		vo.killier_time = MsgAdapter.ReadUInt()
		vo.killer_name = MsgAdapter.ReadStrN(32)
		self.killer_record_list[i] = vo
	end
end

SCCrossBossDropRecord = SCCrossBossDropRecord or BaseClass(BaseProtocolStruct)
function SCCrossBossDropRecord:__init()
	self.msg_type = 5739
	self.dorp_record_list = {}
end

function SCCrossBossDropRecord:Decode()
	local record_count = MsgAdapter.ReadInt()
	self.dorp_record_list = {}
	for i = 1, record_count do
		local vo = {}
		vo.uuid = MsgAdapter.ReadLL()
		vo.role_name = MsgAdapter.ReadStrN(32)
		vo.timestamp = MsgAdapter.ReadUInt()
		vo.scene_id = MsgAdapter.ReadInt()
		vo.monster_id = MsgAdapter.ReadUShort()
		vo.item_id = MsgAdapter.ReadUShort()
		vo.item_num = MsgAdapter.ReadInt()
		vo.xianpin_type_list = {}
		for i = 1, COMMON_CONSTS.XIANPIN_MAX_NUM do
			local xianpin_type = MsgAdapter.ReadUShort()
			if xianpin_type > 0 then
				table.insert(vo.xianpin_type_list, xianpin_type)
			end
		end
		vo.is_cross = 1
		self.dorp_record_list[i] = vo
	end
end

-- 跨服boss场景里的玩家信息
SCCrossBossSceneInfo = SCCrossBossSceneInfo or BaseClass(BaseProtocolStruct)
function SCCrossBossSceneInfo:__init()
	self.msg_type = 5725
end

function SCCrossBossSceneInfo:Decode()
	self.left_monster_count = MsgAdapter.ReadShort()
	self.left_treasure_crystal_num = MsgAdapter.ReadShort()
	self.layer = MsgAdapter.ReadShort()
	self.treasure_crystal_gather_id = MsgAdapter.ReadShort()
	self.monster_next_flush_timestamp = MsgAdapter.ReadUInt()
	self.treasure_crystal_next_flush_timestamp = MsgAdapter.ReadUInt()
	self.boss_list = {}
	for i = 1, 20 do
		local vo = {}
		vo.boss_id = MsgAdapter.ReadInt()
		vo.is_exist = MsgAdapter.ReadInt()
		vo.next_flush_time = MsgAdapter.ReadUInt()
		if vo.boss_id > 0 then
			table.insert(self.boss_list,vo)
		end
	end
end

-- 跨服BOSS玩家信息
SCCrossBossPlayerInfo = SCCrossBossPlayerInfo or BaseClass(BaseProtocolStruct)
function SCCrossBossPlayerInfo:__init()
	self.msg_type = 5724

	self.left_ordinary_crystal_gather_times = 0
	self.left_can_kill_boss_num = 0
	self.left_treasure_crystal_gather_times = 0
	self.concern_flag = {}
end

function SCCrossBossPlayerInfo:Decode()
	self.left_can_kill_boss_num = MsgAdapter.ReadShort()
	self.left_treasure_crystal_gather_times = MsgAdapter.ReadShort()
	self.left_ordinary_crystal_gather_times = MsgAdapter.ReadInt()
	for i = 1, 5 do
		self.concern_flag[i] = MsgAdapter.ReadUInt()
	end
end

-- 请求跨服boss信息
CSCrossBossBossInfoReq = CSCrossBossBossInfoReq or BaseClass(BaseProtocolStruct)
function CSCrossBossBossInfoReq:__init()
	self.msg_type = 5730
	self.opera_type = 0
	self.param1 = 0
	self.param2 = 0
end

function CSCrossBossBossInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opera_type)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
end

-- 跨服boss信息
SCCrossBossBossInfoAck = SCCrossBossBossInfoAck or BaseClass(BaseProtocolStruct)
function SCCrossBossBossInfoAck:__init()
	self.msg_type = 5731
	self.scene_list = {}
end

function SCCrossBossBossInfoAck:Decode()
	local scene_count = MsgAdapter.ReadInt()
	for i = 1, scene_count do
		self.scene_list[i] = {}
		self.scene_list[i].layer = MsgAdapter.ReadShort()
		self.scene_list[i].left_treasure_crystal_count = MsgAdapter.ReadShort()
		self.scene_list[i].left_monster_count = MsgAdapter.ReadShort()
		self.scene_list[i].boss_count = MsgAdapter.ReadShort()
		self.scene_list[i].boss_list = {}
		for k = 1, 20 do
			self.scene_list[i].boss_list[k] = {}
			self.scene_list[i].boss_list[k].boss_id = MsgAdapter.ReadInt()
			self.scene_list[i].boss_list[k].next_refresh_time = MsgAdapter.ReadUInt()
		end
	end
end

SCReliveTire = SCReliveTire or BaseClass(BaseProtocolStruct)
function SCReliveTire:__init()
	self.msg_type = 5740
end

function SCReliveTire:Decode()
	MsgAdapter.ReadShort()
	self.relive_tire_value = MsgAdapter.ReadShort()
	self.tire_buff_end_time = MsgAdapter.ReadUInt()
	self.tire_can_relive_time = MsgAdapter.ReadUInt()
end
--------------跨服BOSSEND-----------------