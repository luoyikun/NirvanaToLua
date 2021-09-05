
-- 服务器时间返回
SCTimeAck = SCTimeAck or BaseClass(BaseProtocolStruct)
function SCTimeAck:__init()
	self.msg_type = 9001

	self.server_time = 0
	self.server_real_start_time = 0
	self.open_days = 0
	self.server_real_combine_time = 0
end

function SCTimeAck:Decode()
	self.server_time = MsgAdapter.ReadUInt()
	self.server_real_start_time = MsgAdapter.ReadUInt()
	self.open_days = MsgAdapter.ReadInt()
	self.server_real_combine_time = MsgAdapter.ReadUInt()
end

-- 请求服务器时间
CSTimeReq = CSTimeReq or BaseClass(BaseProtocolStruct)
function CSTimeReq:__init()
	self.msg_type = 9051
end

function CSTimeReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

SCDisconnectNotice = SCDisconnectNotice or BaseClass(BaseProtocolStruct)
function SCDisconnectNotice:__init()
	self.msg_type = 9003
end

function SCDisconnectNotice:Decode()
	self.reason = MsgAdapter.ReadInt()
end
-- 婚礼类型礼包购买
CSQingYuanBuyWeddingGiftBagReq = CSQingYuanBuyWeddingGiftBagReq or BaseClass(BaseProtocolStruct)
function  CSQingYuanBuyWeddingGiftBagReq:__init()
	self.msg_type = 9033
	self.marry_type = 0
end

function CSQingYuanBuyWeddingGiftBagReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.marry_type)
end