-- 名将信息
SCGreateSoldierItemInfo = SCGreateSoldierItemInfo or BaseClass(BaseProtocolStruct)
function SCGreateSoldierItemInfo:__init()
	self.msg_type = 8600

	self.seq = 0
	self.item_info = {}
end

function SCGreateSoldierItemInfo:Decode()
	self.seq = MsgAdapter.ReadInt()
	self.item_info.level = MsgAdapter.ReadShort()
	self.item_info.potential_level = MsgAdapter.ReadShort()					-- 潜能等级
	self.item_info.unactive_timestamp = MsgAdapter.ReadUInt()				-- 形象ID结束时间（0代表永久）

	-- 名将装备信息
	self.item_info.equipment_list = {}
	for i = 1, 4 do
		self.item_info.equipment_list[i] = {}
		self.item_info.equipment_list[i].item_id = MsgAdapter.ReadUShort()
		self.item_info.equipment_list[i].strength_level = MsgAdapter.ReadShort()
		self.item_info.equipment_list[i].shuliandu = MsgAdapter.ReadInt()
	end
end

--  名将其他信息
SCGreateSoldierOtherInfo = SCGreateSoldierOtherInfo or BaseClass(BaseProtocolStruct)
function SCGreateSoldierOtherInfo:__init()
	self.msg_type = 8601
	self.cur_used_seq = 0
	self.is_on_bianshen_trail = 0
	self.has_dailyfirst_draw_ten = 0
	self.bianshen_end_timestamp = 0
	self.bianshen_cd = 0
	self.bianshen_cd_reduce_s = 0
	self.is_bianshen_cd_end = 0
end

function SCGreateSoldierOtherInfo:Decode()
	self.cur_used_seq = MsgAdapter.ReadChar()					-- 当前使用的名将seq
	self.is_on_bianshen_trail = MsgAdapter.ReadChar()			-- 是否处于体验变身状态
	self.has_dailyfirst_draw_ten = MsgAdapter.ReadChar()		-- 名将抽奖每日是否已经十连抽
	self.use_huanhua_id = MsgAdapter.ReadChar()					-- 使用的幻化ID
	self.bianshen_end_timestamp = MsgAdapter.ReadUInt()			-- 变身结束时间
	self.bianshen_cd = MsgAdapter.ReadInt()						-- 变身剩余cd (ms)
	self.huanhua_flag = MsgAdapter.ReadUInt()					-- 幻化标记
	MsgAdapter.ReadUInt()
	self.bianshen_cd_reduce_s = MsgAdapter.ReadInt()			-- 变身CD缩短时间
	self.is_bianshen_cd_end = MsgAdapter.ReadInt()				-- 变身CD是否结束（1是 ，0否）
	self.seq_exchange_counts = {}
	for i = 1, 32 do
		self.seq_exchange_counts[i] = MsgAdapter.ReadShort()	-- 兑换信息
	end
end

-- 名将将位信息
SCGreateSoldierSlotInfo = SCGreateSoldierSlotInfo or BaseClass(BaseProtocolStruct)
function SCGreateSoldierSlotInfo:__init()
	self.msg_type = 8602

	self.slot_param = {}				-- 0是主将位
end

function SCGreateSoldierSlotInfo:Decode()
	self.slot_param = {}
	for i = 0, COMMON_CONSTS.GREATE_SOLDIER_SLOT_MAX_COUNT - 1 do
		local data = {}
		data.item_seq = MsgAdapter.ReadChar()						-- 名将seq
		MsgAdapter.ReadChar()
		data.level = MsgAdapter.ReadShort()							-- 等级
		data.level_val = MsgAdapter.ReadUInt()						-- 升级祝福值
		self.slot_param[i] = data
	end
end

-- 名将将位信息，8603
SCGreateSoldierFetchReward = SCGreateSoldierFetchReward or BaseClass(BaseProtocolStruct)
function SCGreateSoldierFetchReward:__init()
	self.msg_type = 8603

	self.draw_times = 0
	self.fetch_flag = 0
end

function SCGreateSoldierFetchReward:Decode()
	self.draw_times = MsgAdapter.ReadInt()
	self.fetch_flag = MsgAdapter.ReadUInt()
end

-- 名将-功能目标信息
SCGreateSoldierGoalInfo = SCGreateSoldierGoalInfo or BaseClass(BaseProtocolStruct)
function SCGreateSoldierGoalInfo:__init()
	self.msg_type = 8604
end

function SCGreateSoldierGoalInfo:Decode()
	self.data_list = {}
	for i = 1, 4 do
		local vo = {}
		vo.index = i												-- 目标档次index
		vo.is_finish = MsgAdapter.ReadChar()						-- 目标是否已完成
		vo.is_reward_fetched = MsgAdapter.ReadChar()				-- 奖励是否已领取
		vo.is_purchased = MsgAdapter.ReadChar()						-- 是否已经购买过
		MsgAdapter.ReadChar()
		vo.end_time = MsgAdapter.ReadUInt()							-- 目标结束时间
		self.data_list[i] = vo
	end
end

------------通用日志协议------------------------

-- 请求日志协议
CSGetLuckyLog = CSGetLuckyLog or BaseClass(BaseProtocolStruct)
function CSGetLuckyLog:__init()
	self.msg_type = 8620
	self.activity_type = 0
end

function CSGetLuckyLog:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.activity_type)
end


-- 日志信息
SCLuckyLogRet = SCLuckyLogRet or BaseClass(BaseProtocolStruct)
function SCLuckyLogRet:__init()
	self.msg_type = 8621
	self.activity_type = 0
	self.count = 0
	self.log_item = {}
end

function SCLuckyLogRet:Decode()
	self.log_item = {}
	self.activity_type = MsgAdapter.ReadInt()
	self.count = MsgAdapter.ReadInt()
	for i = 1, self.count do
		local data = {}
		data.uid = MsgAdapter.ReadInt()
		data.role_name = MsgAdapter.ReadStrN(32)
		data.item_id = MsgAdapter.ReadUShort()
		data.item_num = MsgAdapter.ReadShort()
		data.timestamp = MsgAdapter.ReadUInt()
		self.log_item[i] = data
	end
end

-- 护国之力数据
SCHuguozhiliInfo = SCHuguozhiliInfo or BaseClass(BaseProtocolStruct)
function SCHuguozhiliInfo:__init()
	self.msg_type = 8610
end

function SCHuguozhiliInfo:Decode()
	self.today_die_times = MsgAdapter.ReadInt()
	self.today_active_times = MsgAdapter.ReadInt()
	self.active_buff_timestamp = MsgAdapter.ReadUInt()
end

-- 请求使用护国之力
CSHuguozhiliReq = CSHuguozhiliReq or BaseClass(BaseProtocolStruct)
function CSHuguozhiliReq:__init()
	self.msg_type = 8611
	self.opera_type = 0
end

function CSHuguozhiliReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opera_type)
end

-- 下发全服收购记
SCWorldAcquisitionLog = SCWorldAcquisitionLog or BaseClass(BaseProtocolStruct)
function SCWorldAcquisitionLog:__init()
	self.msg_type = 8612
	self.notice_type = 0
end

function SCWorldAcquisitionLog:Decode()
	self.notice_type = MsgAdapter.ReadShort()
	self.count = MsgAdapter.ReadShort()

	local plat_id = 0
	self.data_list = {}
	for i = 1, self.count do
		local data = {}
		data.log_type = MsgAdapter.ReadChar()
		data.log_str_id = MsgAdapter.ReadChar()
		data.item_id = MsgAdapter.ReadUShort()
		for i = 1, COMMON_CONSTS.XIANPIN_MAX_NUM do
			local xianpin_type = MsgAdapter.ReadUShort()
			-- if xianpin_type > 0 then
			-- 	table.insert(log_info.xianpin_type_list, xianpin_type)
			-- end
		end
		data.timestamp = MsgAdapter.ReadUInt()
		data.role_name = MsgAdapter.ReadStrN(32)
		data.role_id = MsgAdapter.ReadUInt()
		data.plat_id = MsgAdapter.ReadUInt()
		table.insert(self.data_list, data)
	end
end

-- 请求添加收购记录
CSWorldAcquisitionLogReq = CSWorldAcquisitionLogReq or BaseClass(BaseProtocolStruct)
function CSWorldAcquisitionLogReq:__init()
	self.msg_type = 8613
end

function CSWorldAcquisitionLogReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteChar(self.log_type)
	MsgAdapter.WriteChar(self.log_str_id)
	MsgAdapter.WriteUShort(self.item_id)

	for i = 1, COMMON_CONSTS.XIANPIN_MAX_NUM do
		MsgAdapter.WriteUShort(0)
	end
end

-- 下发反击列表玩家uid
SCFightBackRoleList = SCFightBackRoleList or BaseClass(BaseProtocolStruct)
function SCFightBackRoleList:__init()
	self.msg_type = 8615
end

function SCFightBackRoleList:Decode()
	self.notify = MsgAdapter.ReadShort()
	self.count = MsgAdapter.ReadShort()
	self.role_uid_list = {}
	for i = 1, self.count do
		self.role_uid_list[i] = MsgAdapter.ReadInt()
	end
end

--跨服目标请求
CSCrossGoalOperaReq = CSCrossGoalOperaReq or BaseClass(BaseProtocolStruct)
function CSCrossGoalOperaReq:__init()
	self.msg_type = 8625
end

function CSCrossGoalOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opera_type)
	MsgAdapter.WriteInt(self.param)
end

--跨服目标信息
SCCrossGoalInfo = SCCrossGoalInfo or BaseClass(BaseProtocolStruct)
function SCCrossGoalInfo:__init()
	self.msg_type = 8626
	self.max_task_num = 16
	self.fetch_reward_flag = {}
	self.fetch_reward_flag2 = {}
end

function SCCrossGoalInfo:Decode()
	for i = 1, self.max_task_num do
		self.fetch_reward_flag[i] = MsgAdapter.ReadChar()
	end
	self.kill_cross_boss_num = MsgAdapter.ReadUShort()
	self.cross_boss_role_killer = MsgAdapter.ReadUShort()
	self.kill_baizhan_boss_num = MsgAdapter.ReadUShort()
	self.finish_baizhan_task_num = MsgAdapter.ReadUShort()
	for i = 1, self.max_task_num do
		self.fetch_reward_flag2[i] = MsgAdapter.ReadChar()
	end
	self.guild_kill_cross_boss = MsgAdapter.ReadUShort()
	self.guild_kill_baizhan_boss = MsgAdapter.ReadUShort()
	self.guild_notify_cur_finish = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
end

--跨服目标通知
SCCrossGoalGuildNotify = SCCrossGoalGuildNotify or BaseClass(BaseProtocolStruct) --8627
function SCCrossGoalGuildNotify:__init()
	self.msg_type = 8627
end

function SCCrossGoalGuildNotify:Decode()
	self.flag = MsgAdapter.ReadInt()
	self.guild_kill_cross_boss = MsgAdapter.ReadUShort()
	self.guild_kill_baizhan_boss = MsgAdapter.ReadUShort()
end

--周末装备装备信息
SCTianshenhutiALlInfo = SCTianshenhutiALlInfo or BaseClass(BaseProtocolStruct)
function SCTianshenhutiALlInfo:__init()
	self.msg_type = 8628
	self.equip_list = {}				-- 每个部位对应装备ID
	self.free_flag = 0					-- 免费标记
	-- self.backpack_num = 0				-- 背包里装备数量（有效数组长度）
	self.backpack_list = {}				-- 背包里拥有的所有装备列表
	self.roll_score = 0
end

function SCTianshenhutiALlInfo:Decode()
	self.equip_list = {}
	for i=0, GameEnum.TIANSHENHUTI_EQUIP_MAX_COUNT - 1 do
		local vo = {}
		vo.index = i
		vo.item_id = MsgAdapter.ReadUShort()
		if vo.item_id > 0 then
			self.equip_list[i] = vo
		end
	end
	self.free_flag = MsgAdapter.ReadShort()
	local backpack_num = MsgAdapter.ReadUShort()
	self.roll_score = MsgAdapter.ReadInt()
	self.next_free_roll_time = MsgAdapter.ReadUInt()
	self.accumulate_roll_times  = MsgAdapter.ReadShort()                  		--累计抽奖次数
    MsgAdapter.ReadShort()                          							-- 预留位
	self.backpack_list = {}
	for i = 1, backpack_num do
		self.backpack_list[i] = {}
		self.backpack_list[i].index = i - 1
		self.backpack_list[i].item_id = MsgAdapter.ReadUShort()
	end
end

--周末装备抽奖结果
SCTianshenhutiRollResult = SCTianshenhutiRollResult or BaseClass(BaseProtocolStruct)
function SCTianshenhutiRollResult:__init()
	self.msg_type = 8629
	self.reward_list = {}
end

function SCTianshenhutiRollResult:Decode()
	self.reward_list = {}
	local index = 1
	local reward_count = MsgAdapter.ReadShort()
	for i=1, reward_count do
		local item_id =  MsgAdapter.ReadUShort()
		if item_id > 0 then
			self.reward_list[index] = {}
			self.reward_list[index].item_id = item_id
			index = index + 1
		end
	end
end

--周末装备相关请求结果
SCTianshenhutiReqResult = SCTianshenhutiReqResult or BaseClass(BaseProtocolStruct)
function SCTianshenhutiReqResult:__init()
	self.msg_type = 8630
	self.req_type = 0
	self.param_1 = 0
end

function SCTianshenhutiReqResult:Decode()
	self.req_type = MsgAdapter.ReadUShort()
	self.param_1 = MsgAdapter.ReadUShort()
	self.new_equip = {}
	local vo = {}
	vo.item_id = MsgAdapter.ReadUShort()
	table.insert(self.new_equip, vo)
	MsgAdapter.ReadUShort()
end

-- 周末装备装备请求
CSTianshenhutiReq = CSTianshenhutiReq or BaseClass(BaseProtocolStruct)
function CSTianshenhutiReq:__init()
	self.msg_type = 8631
	self.req_type = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
	self.param_4 = 0
end

function CSTianshenhutiReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteUShort(self.req_type)
	MsgAdapter.WriteUShort(self.param_1)
	MsgAdapter.WriteUShort(self.param_2)
	MsgAdapter.WriteUShort(self.param_3)
	MsgAdapter.WriteUShort(self.param_4)
	MsgAdapter.WriteUShort(0)
end

--周末装备积分变动
SCTianshenhutiScoreChange = SCTianshenhutiScoreChange or BaseClass(BaseProtocolStruct)
function SCTianshenhutiScoreChange:__init()
	self.msg_type = 8632
	self.roll_score = 0
end

function SCTianshenhutiScoreChange:Decode()
	self.roll_score = MsgAdapter.ReadInt()
end

--周末装备一键合成结果
SCTianshenhutiCombineOneKeyResult = SCTianshenhutiCombineOneKeyResult or BaseClass(BaseProtocolStruct)
function SCTianshenhutiCombineOneKeyResult:__init()
	self.msg_type = 8633
	self.new_equip = {}
end

function SCTianshenhutiCombineOneKeyResult:Decode()
	local combine_count = MsgAdapter.ReadInt()
	self.new_equip = {}
	for i=1, combine_count do
		local item_id = MsgAdapter.ReadUShort()
		self.new_equip[i] = {}
		self.new_equip[i].item_id = item_id
	end
end