--攻城准备战
SCZhuXieUserInfo = SCZhuXieUserInfo or BaseClass(BaseProtocolStruct)
function SCZhuXieUserInfo:__init()
	self.msg_type = 5200
end

function SCZhuXieUserInfo:Decode()
	self.boss_next_flush_time_list = {}
	self.taskinfo_list = {}

	for i = 0, 4 do
		local vo = {}
		vo.index = i
		vo.next_time = MsgAdapter.ReadUInt()
		table.insert(self.boss_next_flush_time_list, vo)
	end

	for i = 1, 4 do
		local task_info = {}
		task_info.task_id = MsgAdapter.ReadShort()
		task_info.param_value = MsgAdapter.ReadShort()
		task_info.max_value = MsgAdapter.ReadShort()
		task_info.is_fetch_reward = MsgAdapter.ReadShort()
		table.insert(self.taskinfo_list, task_info)
	end
end

-- 大富豪形象广播
SCTurnTableMillionaireView = SCTurnTableMillionaireView or BaseClass(BaseProtocolStruct)
function SCTurnTableMillionaireView:__init()
	self.msg_type = 5201
end

function SCTurnTableMillionaireView:Decode()
	self.obj_id =  MsgAdapter.ReadUShort()
	self.is_millionaire =  MsgAdapter.ReadShort()
end

-- 转盘奖励下发
SCTurnTableReward = SCTurnTableReward or BaseClass(BaseProtocolStruct)
function SCTurnTableReward:__init()
	self.msg_type = 5204
end

function SCTurnTableReward:Decode()
	self.type =  MsgAdapter.ReadChar()
	self.rewards_index =  MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
end

-- 转盘基本信息
SCTurnTableInfo = SCTurnTableInfo or BaseClass(BaseProtocolStruct)
function SCTurnTableInfo:__init()
	self.msg_type = 5205
end

function SCTurnTableInfo:Decode()
	self.lucky_list = {}
	for i = 0, GameEnum.TURNTABLE_TYPE_MAX_COUNT - 1 do
		self.lucky_list[i] = MsgAdapter.ReadShort()
	end
end

-- 挖宝信息
SCWabaoInfo = SCWabaoInfo or BaseClass(BaseProtocolStruct)
function SCWabaoInfo:__init()
	self.msg_type = 5206

	self.baozang_scene_id = 0
	self.baozang_pos_x = 0
	self.baozang_pos_y = 0
	self.baotu_count = 0
	self.wabao_reward_type = 0
	self.wabao_reward_list = {}
	self.shouhuzhe_time = 0
	self.is_quick_complete = 0
end

function SCWabaoInfo:Decode()
	self.baozang_scene_id = MsgAdapter.ReadInt()
	self.baozang_pos_x = MsgAdapter.ReadInt()
	self.baozang_pos_y = MsgAdapter.ReadInt()
	self.baotu_count = MsgAdapter.ReadInt()
	self.wabao_reward_type = MsgAdapter.ReadInt()
	local count = MsgAdapter.ReadInt()
	self.shouhuzhe_time = MsgAdapter.ReadUInt()
	if self.wabao_reward_type ~= 0 then
		self.wabao_reward_list = {}
		for i = 1, GameEnum.MAX_REWARD_LIMIT do
			self.wabao_reward_list[i] = MsgAdapter.ReadShort()
		end
	else
		for i = 1, GameEnum.MAX_REWARD_LIMIT do
			MsgAdapter.ReadShort()
		end
	end
	self.is_quick_complete = MsgAdapter.ReadInt()
end

-- QTE信息
SCQTEInfo = SCQTEInfo or BaseClass(BaseProtocolStruct)
function SCQTEInfo:__init()
	self.msg_type = 5209

	self.qte_type = 0
	self.is_already_double = 0
	self.qte_loss_time = 0
end

function SCQTEInfo:Decode()
	self.qte_type = MsgAdapter.ReadChar()
	self.is_already_double = MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
	self.qte_loss_time = MsgAdapter.ReadUInt()
end

-- 聚宝盆信息
SCRACornucopiaFetchInfo = SCRACornucopiaFetchInfo or BaseClass(BaseProtocolStruct)
function SCRACornucopiaFetchInfo:__init()
	self.msg_type = 5212
end

function SCRACornucopiaFetchInfo:Decode()
	self.reward_lun = MsgAdapter.ReadInt()				--当前是第几轮
	self.history_chongzhi = MsgAdapter.ReadLL()			--当前已充值数
	local count = MsgAdapter.ReadInt()
	self.record_list ={}
	for i = 1, count do
		local vo = {}
		vo.user_id = MsgAdapter.ReadInt()
		vo.user_name = MsgAdapter.ReadStrN(32)
		vo.reward_gold = MsgAdapter.ReadShort()
		vo.camp = MsgAdapter.ReadChar()
		MsgAdapter.ReadChar()
		vo.need_put_gold = MsgAdapter.ReadInt()
		self.record_list[i] = vo
	end
end

-- 聚宝盆获得元宝
SCRACornucopiaFetchReward = SCRACornucopiaFetchReward or BaseClass(BaseProtocolStruct)
function SCRACornucopiaFetchReward:__init()
	self.msg_type = 5213
	self.get_reward_gold = 0					--获得的奖励倍率（百分数）
end

function SCRACornucopiaFetchReward:Decode()
	self.get_reward_gold = MsgAdapter.ReadInt()
end

-- 天降财宝
SCTianJiangCaiBaoUserInfo = SCTianJiangCaiBaoUserInfo or BaseClass(BaseProtocolStruct)
function SCTianJiangCaiBaoUserInfo:__init()
	self.msg_type = 5214
end

function SCTianJiangCaiBaoUserInfo:Decode()
	self.big_money_flush_time = MsgAdapter.ReadUInt()
	self.small_money_flush_time = MsgAdapter.ReadUInt()
	self.cur_qianduoduo_num = MsgAdapter.ReadInt()
	self.cur_bigqianduoduo_num = MsgAdapter.ReadInt()
	self.get_total_gold = MsgAdapter.ReadInt()
	self.is_finish = MsgAdapter.ReadInt()
	self.curr_task_id = MsgAdapter.ReadInt()
	self.curr_task_param = MsgAdapter.ReadInt()
	self.has_finish_task_num = MsgAdapter.ReadInt()

	self.reward_count = MsgAdapter.ReadInt()
	self.item_info_list = {}
	for i = 1, self.reward_count do
		self.item_info_list[i] = {
			item_id = MsgAdapter.ReadUShort(),
			num = MsgAdapter.ReadShort(),
		}
	end
end

--聚宝盆
SCRANewCornucopiaInfo = SCRANewCornucopiaInfo or BaseClass(BaseProtocolStruct)

function SCRANewCornucopiaInfo:__init()
	self.msg_type = 5226
end

function SCRANewCornucopiaInfo:Decode()
	self.cornucopia_value = MsgAdapter.ReadInt()
	self.total_cornucopia_value = MsgAdapter.ReadInt()
	self.cornucopia_day_index = MsgAdapter.ReadShort()
	self.cornucopia_total_reward_flag = MsgAdapter.ReadShort()

	self.task_list = {}
	for i = 1, 13 do
		self.task_list[i] = MsgAdapter.ReadUChar()
	end
end

--集字活动兑换次数
SCCollectExchangeInfo = SCCollectExchangeInfo or BaseClass(BaseProtocolStruct)

function SCCollectExchangeInfo:__init()
	self.msg_type = 5230
	self.exchange_times = {}
end

function SCCollectExchangeInfo:Decode()
	self.exchange_times = {}
	for i = 1, 5 do
		self.exchange_times[i] = MsgAdapter.ReadInt()
	end
end


-- 欢乐摇奖
SCRAHuanLeYaoJiangInfo = SCRAHuanLeYaoJiangInfo or BaseClass(BaseProtocolStruct)
function SCRAHuanLeYaoJiangInfo:__init()
    self.msg_type = 5240

    self.ra_huanleyaojiang_next_free_tao_timestamp = 0
    self.chou_times = 0
    self.reward_flag = 0 
end 

function SCRAHuanLeYaoJiangInfo:Decode()
	self.ra_huanleyaojiang_next_free_tao_timestamp = MsgAdapter.ReadUInt()
	self.chou_times = MsgAdapter.ReadInt()
	self.reward_flag = MsgAdapter.ReadInt()
end

SCRAHuanLeYaoJiangTaoResultInfo = SCRAHuanLeYaoJiangTaoResultInfo or BaseClass(BaseProtocolStruct)
function SCRAHuanLeYaoJiangTaoResultInfo:__init()
    self.msg_type = 5241

    self.count = 0
    self.huanleyaojiang_tao_seq = {}
end

function SCRAHuanLeYaoJiangTaoResultInfo:Decode()
    self.count = MsgAdapter.ReadInt()
    -- local max_times = GameEnum.SC_HUANLE_YAOJIANG_MAX_TIMES
    self.huanleyaojiang_tao_seq = {}
    for i = 1, self.count do
    	self.huanleyaojiang_tao_seq[i] = MsgAdapter.ReadShort()
    end
    
end
---------------------------------------欢乐砸蛋-------------------------------------------
SCRAHuanLeZaDanInfo = SCRAHuanLeZaDanInfo or BaseClass(BaseProtocolStruct)
function SCRAHuanLeZaDanInfo:__init()
	self.msg_type = 5238
    self.ra_mijingxunbao_next_free_tao_timestamp = 0
    self.chou_times = 0
    self.reward_flag = 0
end

function SCRAHuanLeZaDanInfo:Decode()
	self.ra_mijingxunbao_next_free_tao_timestamp = MsgAdapter.ReadInt()
    self.chou_times = MsgAdapter.ReadInt()
    self.reward_flag = MsgAdapter.ReadInt()
end

SCRAHuanLeZaDanResultInfo = SCRAHuanLeZaDanResultInfo or BaseClass(BaseProtocolStruct)
function SCRAHuanLeZaDanResultInfo:__init()
	self.msg_type = 5239  
    self.count = 0
    self.mijingxunbao_tao_seq = {}
end

function SCRAHuanLeZaDanResultInfo:Decode()
	self.count = MsgAdapter.ReadInt()
    self.mijingxunbao_tao_seq = {}

    for i=1,self.count do
    	 self.mijingxunbao_tao_seq[i] = MsgAdapter.ReadShort()
    end
end-- 请求进入房间

CSActivityEnterReq = CSActivityEnterReq or BaseClass(BaseProtocolStruct)
function CSActivityEnterReq:__init()
	self.msg_type = 5253
	self.activity_type = 0
	self.room_index = -1
end

function CSActivityEnterReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.activity_type)
	MsgAdapter.WriteInt(self.room_index)
end

--请求提交任务
CSZhuXieFetchTaskReward = CSZhuXieFetchTaskReward or BaseClass(BaseProtocolStruct)
function CSZhuXieFetchTaskReward:__init()
	self.msg_type = 5254
	self.task_id = 0
end

function CSZhuXieFetchTaskReward:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.task_id)
end

-- 发送帮派求救信号请求
CSSendGuildSosReq = CSSendGuildSosReq or BaseClass(BaseProtocolStruct)
function CSSendGuildSosReq:__init()
	self.msg_type = 5255
	self.sos_type = 0
end

function CSSendGuildSosReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.sos_type)
end

-- 请求转盘转动
CSTurnTableReq = CSTurnTableReq or BaseClass(BaseProtocolStruct)
function CSTurnTableReq:__init()
	self.msg_type = 5257
	self.type = 0
	self.is_roll = 0
	self.reserve_sh = 0
end

function CSTurnTableReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteChar(self.type)
	MsgAdapter.WriteChar(self.is_roll)
	MsgAdapter.WriteShort(self.reserve_sh)
end

-- 挖宝操作请求
CSWabaoOperaReq = CSWabaoOperaReq or BaseClass(BaseProtocolStruct)
function CSWabaoOperaReq:__init()
	self.msg_type = 5258

	self.opera_type = 0
	self.is_killed = 0
end

function CSWabaoOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(self.is_killed)
end

-- QTE发送结果
CSQTEReq = CSQTEReq or BaseClass(BaseProtocolStruct)
function CSQTEReq:__init()
	self.msg_type = 5261

	self.qte_type = 0
	self.qte_result = 0
	self.reserve_sh = 0
end

function CSQTEReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteChar(self.qte_type)
	MsgAdapter.WriteChar(self.qte_result)
	MsgAdapter.WriteShort(self.reserve_sh)
end

-- 领取充值奖励请求
CSChongzhiFetchReward = CSChongzhiFetchReward or BaseClass(BaseProtocolStruct)
function CSChongzhiFetchReward:__init()
	self.msg_type = 5259
	self.type = 0
	self.param = 0  --seq
	self.param2 = 0 --CHONGZHI_REWARD_TYPE_DAILY时表示选择的奖励索引
end

function CSChongzhiFetchReward:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.type)
	MsgAdapter.WriteInt(self.param)
	MsgAdapter.WriteInt(self.param2)
end

-- 请求在充值
CSZaiChongzhiFetchReward = CSZaiChongzhiFetchReward or BaseClass(BaseProtocolStruct)
function CSZaiChongzhiFetchReward:__init()
	self.msg_type = 5264

	self.is_third = 0		--是否是第三次充值
end

function CSZaiChongzhiFetchReward:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.is_third)
end

-- 求救传送请求
CSReplyGuildSosReq = CSReplyGuildSosReq or BaseClass(BaseProtocolStruct)
function CSReplyGuildSosReq:__init()
	self.msg_type = 5265
	self.sos_type = 0
	self.pos_x = 0
	self.pos_y = 0
	self.scene_id = 0
end

function CSReplyGuildSosReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.sos_type)
	MsgAdapter.WriteInt(self.pos_x)
	MsgAdapter.WriteInt(self.pos_y)
	MsgAdapter.WriteInt(self.scene_id)
end

--------------------
-- 我要元宝(变元宝)
--------------------
SCTotalChongzhiWantMoneyFetchInfo = SCTotalChongzhiWantMoneyFetchInfo or BaseClass(BaseProtocolStruct)
function SCTotalChongzhiWantMoneyFetchInfo:__init()
	self.msg_type = 5210
	self.reward_state = 0
	self.history_chongzhi = 0
end

function SCTotalChongzhiWantMoneyFetchInfo:Decode()
	self.reward_state = MsgAdapter.ReadInt()			-- 当前要领的阶段
	self.history_chongzhi = MsgAdapter.ReadLL()			-- 当前已充值数
end

--请求获取领取的阶段和已充值数
CSTotalChongzhiWantMoneyFetchInfo = CSTotalChongzhiWantMoneyFetchInfo or BaseClass(BaseProtocolStruct)
function CSTotalChongzhiWantMoneyFetchInfo:__init()
	self.msg_type = 5262
end

function CSTotalChongzhiWantMoneyFetchInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

SCTotalChongzhiWantMoneyFetchReward = SCTotalChongzhiWantMoneyFetchReward or BaseClass(BaseProtocolStruct)
function SCTotalChongzhiWantMoneyFetchReward:__init()
	self.msg_type = 5211
	self.get_gold_bind = 0
end

function SCTotalChongzhiWantMoneyFetchReward:Decode()
	self.get_gold_bind = MsgAdapter.ReadInt()			-- 随机获得的元宝数量
end

CSTotalChongzhiWantMoneyFetchReward = CSTotalChongzhiWantMoneyFetchReward or BaseClass(BaseProtocolStruct)
function CSTotalChongzhiWantMoneyFetchReward:__init()
	self.msg_type = 5263
end

function CSTotalChongzhiWantMoneyFetchReward:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--请求重置
CSMoveChessResetReq = CSMoveChessResetReq or BaseClass(BaseProtocolStruct)
function CSMoveChessResetReq:__init()
	self.msg_type = 5221
end

function CSMoveChessResetReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- （修改）
--请求摇骰子
CSMoveChessShakeReq = CSMoveChessShakeReq or BaseClass(BaseProtocolStruct)
function CSMoveChessShakeReq:__init()
	self.msg_type = 5222
	self.is_use_item = 0
	self.reserve = 0
end

function CSMoveChessShakeReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.is_use_item)
	MsgAdapter.WriteShort(self.reserve)
end

-- （修改）
--获取走棋子信息
CSMoveChessFreeInfo = CSMoveChessFreeInfo or BaseClass(BaseProtocolStruct)
function CSMoveChessFreeInfo:__init()
	self.msg_type = 5223
	-- self.is_reqinfo = 0
end

function CSMoveChessFreeInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	-- MsgAdapter.WriteInt(self.is_reqinfo)
end

-- 增加
-- 5524摇骰子摇到点数
SCMoveChessShakePoint = SCMoveChessShakePoint or BaseClass(BaseProtocolStruct)
function SCMoveChessShakePoint:__init()
	self.msg_type = 5224
	self.shake_point = 0
end

function SCMoveChessShakePoint:Decode()
	self.shake_point = MsgAdapter.ReadInt()
end

--消费有礼
SCRAConsumeForGiftAllInfo = SCRAConsumeForGiftAllInfo or BaseClass(BaseProtocolStruct)
function SCRAConsumeForGiftAllInfo:__init()
	self.msg_type = 5235
	self.total_consume_gold = 0
	self.cur_points = 0
	self.item_count = 0
	self.item_exchange_times = {}
end

function SCRAConsumeForGiftAllInfo:Decode()
	self.total_consume_gold = MsgAdapter.ReadInt()             --累计消费
	self.cur_points =  MsgAdapter.ReadInt()                    --上次领奖到现在的消费	
	self.item_count =  MsgAdapter.ReadInt()
	self.item_exchange_times = {}

	for i = 1, self.item_count do
		self.item_exchange_times[i] = MsgAdapter.ReadUChar()
	end	
end

-------------------------------------------------------
-- local function LoadChessItemInfo()
-- 	local t = {}
-- 	t.item_id = MsgAdapter.ReadUShort()
-- 	t.num = MsgAdapter.ReadShort()
-- 	t.is_bind = MsgAdapter.ReadShort()
-- 	t.reserve = MsgAdapter.ReadShort()
-- 	return t
-- end
-- (删除)
--返回每次摇骰得到的物品
-- SCMoveChessRewarInfo = SCMoveChessRewarInfo or BaseClass(BaseProtocolStruct)
-- function SCMoveChessRewarInfo:__init()
-- 	self.msg_type = 5224
-- 	self.item_list = {}
-- end

-- function SCMoveChessRewarInfo:Decode()
-- 	local count = MsgAdapter.ReadInt()
-- 	for i = 1, count do
-- 		self.item_list[i] = LoadChessItemInfo()
-- 	end
-- end

--获取摇骰点数
-- CSGetPointReq = CSGetPointReq or BaseClass(BaseProtocolStruct)
-- function CSGetPointReq:__init()
-- 	self.msg_type = 5225
-- end

-- function CSGetPointReq:Encode()
-- 	MsgAdapter.WriteBegin(self.msg_type)
-- end

---------------------------------------秘境寻宝-------------------------------------------
SCRAMiJingXunBaoInfo3 = SCRAMiJingXunBaoInfo3 or BaseClass(BaseProtocolStruct)
function SCRAMiJingXunBaoInfo3:__init()
	self.msg_type = 5236  
	self.ra_mijingxunbao3_next_free_tao_timestamp = 0
	self.chou_times = 0
	self.reward_flag = 0
end

function SCRAMiJingXunBaoInfo3:Decode()
	self.ra_mijingxunbao3_next_free_tao_timestamp = MsgAdapter.ReadInt()
	self.chou_times = MsgAdapter.ReadInt()
	self.reward_flag = MsgAdapter.ReadInt()
end


SCRAMiJingXunBaoTaoResultInfo3 = SCRAMiJingXunBaoTaoResultInfo3 or BaseClass(BaseProtocolStruct)
function SCRAMiJingXunBaoTaoResultInfo3:__init()
	self.msg_type = 5237 
	self.count = 0
	self.mijingxunbao3_tao_seq = {}
end
	
function SCRAMiJingXunBaoTaoResultInfo3:Decode()
	self.count = MsgAdapter.ReadInt()
	self.mijingxunbao3_tao_seq = {}

	for i=1,self.count do
		self.mijingxunbao3_tao_seq[i] = MsgAdapter.ReadShort()
	end
end

----------------------------------衣橱-------------------------------------
--衣橱操作请求
CSDressingRoomOpera = CSDressingRoomOpera or BaseClass(BaseProtocolStruct)
function CSDressingRoomOpera:__init()
	self.msg_type = 5245
	self.opera_type = 0
end

function CSDressingRoomOpera:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opera_type)
end

--所有套装部位激活信息
SCDressingRoomInfo = SCDressingRoomInfo or BaseClass(BaseProtocolStruct)
function SCDressingRoomInfo:__init()
	self.msg_type = 5246
end

function SCDressingRoomInfo:Decode()
	self.single_img_count = MsgAdapter.ReadInt() 						--套装数量
	-- self.single_img_count = 4
	self.info_list = {}													-- 套装部件激活情况列表
	if self.single_img_count == 0 then return end

	for i = 1, self.single_img_count do
		 self.info_list[i] = MsgAdapter.ReadInt()							
	end
end

--单个套装部位激活信息变化
SCDressingRoomSingleInfo = SCDressingRoomSingleInfo or BaseClass(BaseProtocolStruct)
function SCDressingRoomSingleInfo:__init()
	self.msg_type = 5247
end

function SCDressingRoomSingleInfo:Decode()
	self.is_active = MsgAdapter.ReadInt()				-- 1:0  激活:取消激活
	self.info = {}										-- 单个信息变化
	self.info.suit_index = MsgAdapter.ReadShort() 		-- 套装索引
	self.info.img_index = MsgAdapter.ReadShort()		-- 套装部位
end

-- 衣橱兑换操作请求
CSDressingRoomExchange = CSDressingRoomExchange or BaseClass(BaseProtocolStruct)
function CSDressingRoomExchange:__init()
	self.msg_type = 5248
	self.suit_index = -1 				-- 套装id 从0开始
	self.sub_index = -1 				-- 部位id 从0开始
end

function CSDressingRoomExchange:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.suit_index)
	MsgAdapter.WriteInt(self.sub_index)
end

--------------------------------衣橱结束-------------------------------------