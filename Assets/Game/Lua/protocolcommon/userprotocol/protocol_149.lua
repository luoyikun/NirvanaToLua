--跨服随机活动统一请求协议
CSCrossRAChongzhiRankGetRank = CSCrossRAChongzhiRankGetRank or BaseClass(BaseProtocolStruct)
function CSCrossRAChongzhiRankGetRank:__init()
	self.msg_type = 14901
end

function CSCrossRAChongzhiRankGetRank:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--跨服统一请求协议
CSCrossCommonOperaReq = CSCrossCommonOperaReq or BaseClass(BaseProtocolStruct)
function CSCrossCommonOperaReq:__init()
	self.msg_type = 14902

	self.req_type = 0
	self.param_1 = 0
	self.param_2 = 0
end

function CSCrossCommonOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.req_type)
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
end


SCCrossRAChongzhiRankGetRankACK = SCCrossRAChongzhiRankGetRankACK or BaseClass(BaseProtocolStruct)
function SCCrossRAChongzhiRankGetRankACK:__init()
	self.msg_type = 14907
end

function SCCrossRAChongzhiRankGetRankACK:Decode()
	self.rank_count = MsgAdapter.ReadInt()
	self.rank_list = {}
	for i = 1, self.rank_count  do
		local vo = {}
		vo.total_chongzhi = MsgAdapter.ReadLL()
		vo.mvp_name = MsgAdapter.ReadStrN(32)
		vo.mvp_server_id = MsgAdapter.ReadInt()
		vo.mvp_plat_type = MsgAdapter.ReadInt()
		self.rank_list[i] = vo
	end
end

---------------------跨服消费排行------------------------
--请求排行
CSCrossRAConsumeRankGetRank = CSCrossRAConsumeRankGetRank or BaseClass(BaseProtocolStruct)
function CSCrossRAConsumeRankGetRank:__init()
	self.msg_type = 14908
	self.modify_id = 0
end

function CSCrossRAConsumeRankGetRank:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.modify_id)
end

--返回排行
SCCrossRAConsumeRankGetRankACK = SCCrossRAConsumeRankGetRankACK or BaseClass(BaseProtocolStruct)
function SCCrossRAConsumeRankGetRankACK:__init()
	self.msg_type = 14909
end

function SCCrossRAConsumeRankGetRankACK:Decode()
	self.modify_id = MsgAdapter.ReadInt()
	self.rank_count = MsgAdapter.ReadInt()
	self.rank_list = {}
	for i = 1, self.rank_count do
		local vo = {}
		vo.total_consume = MsgAdapter.ReadLL()
		vo.mvp_name = MsgAdapter.ReadStrN(32)
		vo.mvp_server_id = MsgAdapter.ReadInt()
		vo.mvp_plat_type = MsgAdapter.ReadInt()
		self.rank_list[i] = vo
	end
end



