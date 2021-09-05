SCRoleMsgReply = SCRoleMsgReply or BaseClass(BaseProtocolStruct)

function SCRoleMsgReply:__init()
	self.msg_type = 4500
end

function SCRoleMsgReply:Decode()
	self.typ = MsgAdapter.ReadInt()
	self.value = MsgAdapter.ReadInt()
end