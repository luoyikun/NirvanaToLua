-- 收礼记录
SCFriendGiftAllInfo = SCFriendGiftAllInfo or BaseClass(BaseProtocolStruct)
function SCFriendGiftAllInfo:__init()
	self.msg_type = 8350
end

function SCFriendGiftAllInfo:Decode()
	self.song_gift_count = MsgAdapter.ReadShort()
	self.shou_gift_count = MsgAdapter.ReadShort()
	self.shou_gift_list_count = MsgAdapter.ReadInt()

	self.gift_record_list = {}
	for i = 1, self.shou_gift_list_count do
		local gift_record_info = {}
		gift_record_info.role_name = MsgAdapter.ReadStrN(32)
		gift_record_info.role_id = MsgAdapter.ReadInt()
		gift_record_info.is_return = MsgAdapter.ReadInt()
		gift_record_info.shou_gift_time = MsgAdapter.ReadInt()
		local server_time = TimeCtrl.Instance:GetServerTime()
		local time = server_time - gift_record_info.shou_gift_time
		if time < 86400 * 3 then
			table.insert(self.gift_record_list, gift_record_info)
		end
	end
end

--送礼请求
CSFriendSongGift = CSFriendSongGift or BaseClass(BaseProtocolStruct)
function CSFriendSongGift:__init()
	self.msg_type = 8351
	self.target_id = 0
	self.is_yi_jian = 0
	self.is_return = 0			--是否回礼
end

function CSFriendSongGift:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.target_id)
	MsgAdapter.WriteInt(self.is_yi_jian)
	MsgAdapter.WriteInt(self.is_return)
end

--收礼记录请求
CSFriendGiftAllInfoReq = CSFriendGiftAllInfoReq or BaseClass(BaseProtocolStruct)
function CSFriendGiftAllInfoReq:__init()
	self.msg_type = 8352
end

function CSFriendGiftAllInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--收到礼物的提示
SCFriendGiftShouNotice = SCFriendGiftShouNotice or BaseClass(BaseProtocolStruct)
function SCFriendGiftShouNotice:__init()
	self.msg_type = 8353
end

function SCFriendGiftShouNotice:Decode()
end

---------------------我要脱单----------------------------
--请求全部脱单信息
CSGetAllTuodanInfo = CSGetAllTuodanInfo or BaseClass(BaseProtocolStruct)
function CSGetAllTuodanInfo:__init()
	self.msg_type = 8371
end

function CSGetAllTuodanInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--全部脱单信息
SCAllTuodanInfo = SCAllTuodanInfo or BaseClass(BaseProtocolStruct)
function SCAllTuodanInfo:__init()
	self.msg_type = 8372
end

function SCAllTuodanInfo:Decode()
	self.count = MsgAdapter.ReadInt()
	self.tuodan_list = {}
	for i = 1, self.count do
		local tuodan_info = {}
		tuodan_info.uid = MsgAdapter.ReadInt()
		tuodan_info.name = MsgAdapter.ReadStrN(32)
		tuodan_info.prof = MsgAdapter.ReadChar()
		tuodan_info.sex = MsgAdapter.ReadChar()
		tuodan_info.level = MsgAdapter.ReadShort()
		tuodan_info.capability = MsgAdapter.ReadInt()
		tuodan_info.avatar_key_big = MsgAdapter.ReadUInt()
		tuodan_info.avatar_key_small = MsgAdapter.ReadUInt()
		tuodan_info.create_time = MsgAdapter.ReadUInt()
		tuodan_info.notice = MsgAdapter.ReadStrN(64)
		table.insert(self.tuodan_list, tuodan_info)
	end
end

--操作请求
CSTuodanREQ = CSTuodanREQ or BaseClass(BaseProtocolStruct)
function CSTuodanREQ:__init()
	self.msg_type = 8373
	self.req_type = 0
	self.notice = 0
end

function CSTuodanREQ:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.req_type)
	MsgAdapter.WriteStrN(self.notice, 64)
end

--单个脱单信息
SCSingleTuodanInfo = SCSingleTuodanInfo or BaseClass(BaseProtocolStruct)
function SCSingleTuodanInfo:__init()
	self.msg_type = 8374
end

function SCSingleTuodanInfo:Decode()
	self.operate_type = MsgAdapter.ReadInt()			--0:更新, 1:删除
	self.tuodan_info = {}
	self.tuodan_info.uid = MsgAdapter.ReadInt()
	self.tuodan_info.name = MsgAdapter.ReadStrN(32)
	self.tuodan_info.prof = MsgAdapter.ReadChar()
	self.tuodan_info.sex = MsgAdapter.ReadChar()
	self.tuodan_info.level = MsgAdapter.ReadShort()
	self.tuodan_info.capability = MsgAdapter.ReadInt()
	self.tuodan_info.avatar_key_big = MsgAdapter.ReadUInt()
	self.tuodan_info.avatar_key_small = MsgAdapter.ReadUInt()
	self.tuodan_info.create_time = MsgAdapter.ReadUInt()
	self.tuodan_info.notice = MsgAdapter.ReadStrN(64)
end


--------------------情缘装备-----------------------------
-- 情缘装备进阶
CSQingyuanUpQuality = CSQingyuanUpQuality or BaseClass(BaseProtocolStruct)

function CSQingyuanUpQuality:__init()
	self.msg_type = 8391
	self.slot = 0
end

function CSQingyuanUpQuality:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.slot)
	MsgAdapter.WriteShort(0)
end

-- 情缘装备操作
CSQingyuanEquipOperate = CSQingyuanEquipOperate or BaseClass(BaseProtocolStruct)

function CSQingyuanEquipOperate:__init()
	self.msg_type = 8392
end

function CSQingyuanEquipOperate:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.operate_type)
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
	MsgAdapter.WriteInt(self.param_3)
end

-- 情缘装备信息请求
CSQingyuanEquipInfo = CSQingyuanEquipInfo or BaseClass(BaseProtocolStruct)

function CSQingyuanEquipInfo:__init()
	self.msg_type = 8393
end

function CSQingyuanEquipInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 情缘装备信息
SCQingyuanEquipInfo = SCQingyuanEquipInfo or BaseClass(BaseProtocolStruct)
function SCQingyuanEquipInfo:__init()
	self.msg_type = 8394
end

function SCQingyuanEquipInfo:Decode()
	self.is_self = MsgAdapter.ReadInt()
	self.marry_level = MsgAdapter.ReadInt()
	self.marry_level_exp = MsgAdapter.ReadInt()
	self.qingyuan_suit_flag = {}
	for i = 0, 9 do
		self.qingyuan_suit_flag[i] = MsgAdapter.ReadUChar()
	end
	self.buy_gift_flag = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	self.qy_equip_list = {}
	for i = 0, 3 do
		self.qy_equip_list[i] = ProtocolStruct.ReadItemDataWrapper()
	end
	self.qy_equip_list_2 = {}
	for i = 0, 3 do
		self.qy_equip_list_2[i] = {}
		self.qy_equip_list_2[i].level = MsgAdapter.ReadUShort()
		MsgAdapter.ReadShort()
		MsgAdapter.ReadInt()
	end
	self.special_baby_list = {}
	for i = 1,GameEnum.SPECIAL_BABY_TYPE_MAX do
		self.special_baby_list[i] = {}
		self.special_baby_list[i].special_baby_level = MsgAdapter.ReadUShort()
		self.special_baby_list[i].quality = MsgAdapter.ReadChar()
		MsgAdapter.ReadChar()
	end
end

-- 坐骑副本信息
SCFunOpenMountInfo = SCFunOpenMountInfo or BaseClass(BaseProtocolStruct)
function SCFunOpenMountInfo:__init()
	self.msg_type = 8300
end

function SCFunOpenMountInfo:Decode()
	self.is_finish = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
	self.cur_step_monster_total_num = MsgAdapter.ReadInt()
	self.cur_step_monster_kill_num = MsgAdapter.ReadInt()
	self.cur_step_gather_total_num = MsgAdapter.ReadInt()
	self.cur_step_gather_num = MsgAdapter.ReadInt()
end

-- 羽翼副本信息
SCFunOpenWingInfo = SCFunOpenWingInfo or BaseClass(BaseProtocolStruct)
function SCFunOpenWingInfo:__init()
	self.msg_type = 8301
end

function SCFunOpenWingInfo:Decode()
	self.is_finish = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
	self.cur_step_monster_total_num = MsgAdapter.ReadInt()
	self.cur_step_monster_kill_num = MsgAdapter.ReadInt()
end

-- 女神副本信息
SCFunOpenXiannvInfo = SCFunOpenXiannvInfo or BaseClass(BaseProtocolStruct)
function SCFunOpenXiannvInfo:__init()
	self.msg_type = 8302
end

function SCFunOpenXiannvInfo:Decode()
	self.is_finish = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
	self.cur_step_monster_total_num = MsgAdapter.ReadInt()
	self.cur_step_monster_kill_num = MsgAdapter.ReadInt()
end

-- 请求服务器执行第N步骤
CSFunOpenStoryStep = CSFunOpenStoryStep or BaseClass(BaseProtocolStruct)
function CSFunOpenStoryStep:__init()
	self.msg_type = 8325
end

function CSFunOpenStoryStep:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.step)
end

-- 重置obj位置请求
CSFunOpenSetObjToPos = CSFunOpenSetObjToPos or BaseClass(BaseProtocolStruct)
function CSFunOpenSetObjToPos:__init()
	self.msg_type = 8326
end

function CSFunOpenSetObjToPos:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteUShort(self.obj_id)
	MsgAdapter.WriteShort(0)
	MsgAdapter.WriteInt(self.pos_x)
	MsgAdapter.WriteInt(self.pos_y)
end

-- 服务器返回第N步骤完成
SCFunOpenStoryStepEnd = SCFunOpenStoryStepEnd or BaseClass(BaseProtocolStruct)
function SCFunOpenStoryStepEnd:__init()
	self.msg_type = 8327
end

function SCFunOpenStoryStepEnd:Decode()
	self.step = MsgAdapter.ReadInt()
end

---好友贺礼 可以送贺礼给好友的通知
SCFriendHeliNotice = SCFriendHeliNotice or BaseClass(BaseProtocolStruct)
function SCFriendHeliNotice:__init()
	self.msg_type = 8354
end

function SCFriendHeliNotice:Decode()
	self.heli_type = MsgAdapter.ReadInt()
	self.uid =  MsgAdapter.ReadInt()
	self.param1 = MsgAdapter.ReadInt()
	self.param2 = MsgAdapter.ReadInt()
end

CSFriendHeliSendReq = CSFriendHeliSendReq or BaseClass(BaseProtocolStruct)
function CSFriendHeliSendReq:__init()
	self.msg_type = 8355
	self.uid = 0
	self.type = 0
end

function CSFriendHeliSendReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.uid)
	MsgAdapter.WriteInt(self.type)
end

SCFriendHeliSend = SCFriendHeliSend or BaseClass(BaseProtocolStruct)
function SCFriendHeliSend:__init()
	self.msg_type = 8356
end

function SCFriendHeliSend:Decode()
	self.uid =  MsgAdapter.ReadInt()
	self.type = MsgAdapter.ReadInt()
end

CSGiveItemOpera = CSGiveItemOpera or BaseClass(BaseProtocolStruct)
function CSGiveItemOpera:__init()
	self.msg_type = 8357
	self.opera_type = 0
	self.param_1 = 0
end

function CSGiveItemOpera:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(self.param_1)
end

CSGiveItemReq = CSGiveItemReq or BaseClass(BaseProtocolStruct)
function CSGiveItemReq:__init()
	self.msg_type = 8358
	self.target_uid = 0
	self.item_count = 0
	self.send_cell_list_data = {}
end

function CSGiveItemReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.target_uid)
	MsgAdapter.WriteInt(self.item_count)

	for i = 1, self.item_count do
		local list_data = self.send_cell_list_data[i]
		if list_data then
			if list_data.in_bag_index then
				MsgAdapter.WriteInt(list_data.in_bag_index)
			else
				MsgAdapter.WriteInt(-1)
			end
			if list_data.num then
				MsgAdapter.WriteShort(list_data.num)
			else
				MsgAdapter.WriteShort(0)
			end
			MsgAdapter.WriteShort(0)
		else
			MsgAdapter.WriteInt(-1)
			MsgAdapter.WriteShort(0)
			MsgAdapter.WriteShort(0)
		end
	end
end

--收礼记录
SCGiveItemRecord = SCGiveItemRecord or BaseClass(BaseProtocolStruct)
function SCGiveItemRecord:__init()
	self.msg_type = 8359
	self.is_give = 0
	self.record_count = 0
	self.temp_list = {}
	self.record_list = {}	
end

function SCGiveItemRecord:Decode()
	self.is_give = MsgAdapter.ReadChar()
	self.reserve_ch = MsgAdapter.ReadChar()
	self.record_count = MsgAdapter.ReadShort()
	self.temp_list = {}
	self.record_list = {}
	for i = 1, self.record_count do
		local record_list = {}
		record_list.uid = MsgAdapter.ReadInt()
		record_list.role_name = MsgAdapter.ReadStrN(32)
		record_list.item_id = MsgAdapter.ReadUShort()
		record_list.item_num = MsgAdapter.ReadUShort()
		record_list.timestamp = MsgAdapter.ReadUInt()
		table.insert(self.temp_list, record_list)
	end
	for k = self.record_count, 1, -1 do
		if self.temp_list[k] then
			table.insert(self.record_list, self.temp_list[k])
		end
	end
end