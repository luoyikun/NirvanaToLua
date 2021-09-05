
-----------------------一元夺宝---------------------
-- 夺宝
SCCloudPurchaseInfo = SCCloudPurchaseInfo or BaseClass(BaseProtocolStruct)
function SCCloudPurchaseInfo:__init()
	self.msg_type = 8900
	self.can_buy_timestamp_list = {}
	self.item_list = {}
end

function SCCloudPurchaseInfo:Decode()
	self.can_buy_timestamp_list = {}
	for i = 1, 32 do
		self.can_buy_timestamp_list[i] = MsgAdapter.ReadInt()
	end
	self.item_list = {}
	for i = 1, 32 do
		self.item_list[i] = {}
		self.item_list[i].total_buy_times = MsgAdapter.ReadInt()
		self.item_list[i].give_reward_timestamp = MsgAdapter.ReadInt()
	end
end

---------- 兑换

SCCloudPurchaseConvertInfo = SCCloudPurchaseConvertInfo or BaseClass(BaseProtocolStruct)
function SCCloudPurchaseConvertInfo:__init()
	self.msg_type = 8901
	self.score = 0
	self.record_count = 0
	self.convert_record_list = {}
end

function SCCloudPurchaseConvertInfo:Decode()
	self.score = MsgAdapter.ReadInt()
	self.record_count = MsgAdapter.ReadInt()
	self.convert_record_list = {}
	for i = 1, self.record_count do
		self.convert_record_list[i] = {}
		self.convert_record_list[i].item_id = MsgAdapter.ReadUShort()
		self.convert_record_list[i].convert_count = MsgAdapter.ReadShort()
	end
end

---------- 一元夺宝个人购买记录
SCCloudPurchaseBuyRecordInfo = SCCloudPurchaseBuyRecordInfo or BaseClass(BaseProtocolStruct)
function SCCloudPurchaseBuyRecordInfo:__init()
	self.msg_type = 8902
	self.record_count = 0
	self.buy_record_list = {}
end

function SCCloudPurchaseBuyRecordInfo:Decode()
	self.record_count = MsgAdapter.ReadInt()
	self.buy_record_list = {}
	for i = 1, self.record_count do
		self.buy_record_list[i] = {}
		self.buy_record_list[i].item_id = MsgAdapter.ReadUShort()
		self.buy_record_list[i].buy_count = MsgAdapter.ReadShort()
		self.buy_record_list[i].buy_timestamp = MsgAdapter.ReadUInt()
	end
end

---------- 一元夺宝记录(全服记录（中奖信息）)
SCCloudPurchaseServerRecord = SCCloudPurchaseServerRecord or BaseClass(BaseProtocolStruct)
function SCCloudPurchaseServerRecord:__init()
	self.msg_type = 8903
	self.count = 0
	self.cloud_reward_record_list = {}
end

function SCCloudPurchaseServerRecord:Decode()
	self.count = MsgAdapter.ReadInt()
	self.cloud_reward_record_list = {}
	for i = 1, self.count do
		self.cloud_reward_record_list[i] = {}
		self.cloud_reward_record_list[i].reward_server_id = MsgAdapter.ReadInt()
		self.cloud_reward_record_list[i].user_name = MsgAdapter.ReadInt(32)
		self.cloud_reward_record_list[i].reward_item_id = MsgAdapter.ReadUShort()
		self.cloud_reward_record_list[i].reserve_sh = MsgAdapter.ReadShort()
	end
end

SCCloudPurchaseUserInfo = SCCloudPurchaseUserInfo or BaseClass(BaseProtocolStruct)
function SCCloudPurchaseUserInfo:__init()
	self.msg_type = 8904
	self.score = 0
	self.ticket_num = 0
end

function SCCloudPurchaseUserInfo:Decode()
	self.score = MsgAdapter.ReadInt()
	self.ticket_num = MsgAdapter.ReadInt()
end

--跨服消费排行活动 
SCCrossRAConsumeRankConsumeInfo = SCCrossRAConsumeRankConsumeInfo or BaseClass(BaseProtocolStruct)
function SCCrossRAConsumeRankConsumeInfo:__init()
	self.msg_type = 8905
end

function SCCrossRAConsumeRankConsumeInfo:Decode()
	self.total_consume = MsgAdapter.ReadUInt()
end

-- 云游boss协议
CSYunyouBossInfo = CSYunyouBossInfo or BaseClass(BaseProtocolStruct)
function CSYunyouBossInfo:__init()
	self.msg_type = 8906
	self.operate_type = 0
	self.param = 0
end

function CSYunyouBossInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.operate_type)
	MsgAdapter.WriteInt(self.param)
end


SCYouyouBossInfo = SCYouyouBossInfo or BaseClass(BaseProtocolStruct)
function SCYouyouBossInfo:__init()
	self.msg_type = 8907
	self.scene_id = 0
	self.boss_count = 0
end

function SCYouyouBossInfo:Decode()
	self.nex_refresh_time = MsgAdapter.ReadUInt()
	self.scene_id = MsgAdapter.ReadInt()
	self.boss_count = MsgAdapter.ReadInt() or 0
	self.boss_info_list = {}
	for i = 1, self.boss_count do
		self.boss_info_list[i] = {}
		self.boss_info_list[i].scene_id = MsgAdapter.ReadInt()
		self.boss_info_list[i].boss_id = MsgAdapter.ReadInt()
		self.boss_info_list[i].born_pos_x = MsgAdapter.ReadInt()
		self.boss_info_list[i].born_pos_y = MsgAdapter.ReadInt()
	end
end

SCYouyouSceneInfo = SCYouyouSceneInfo or BaseClass(BaseProtocolStruct)
function SCYouyouSceneInfo:__init()
	self.msg_type = 8908 
end

function SCYouyouSceneInfo:Decode()
	self.scene_count = MsgAdapter.ReadInt()
	self.scene_info_list = {}
	for i = 1, self.scene_count do
		self.scene_info_list[i] = {}
		self.scene_info_list[i].scene_id = MsgAdapter.ReadInt()
		self.scene_info_list[i].boss_count = MsgAdapter.ReadInt()
	end
end


--神魔BOSS请求
CSGodmagicBossInfoReq = CSGodmagicBossInfoReq or BaseClass(BaseProtocolStruct)
function CSGodmagicBossInfoReq:__init()
	self.msg_type = 8910
	self.req_type = 0
	self.param_1 = 0
	self.param_2 = 0
end

function CSGodmagicBossInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.req_type)
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
end

--神魔BOSS信息 
SCGodmagicBossInfoAck = SCGodmagicBossInfoAck or BaseClass(BaseProtocolStruct)
function SCGodmagicBossInfoAck:__init()
	self.msg_type = 8911
end

function SCGodmagicBossInfoAck:Decode()
	self.scene_count = MsgAdapter.ReadInt()
	self.scene_list = {}
	for i = 1, self.scene_count do
		local temp_scene_list = {}
		temp_scene_list.layer = MsgAdapter.ReadShort()
		temp_scene_list.left_treasure_crystal_count = MsgAdapter.ReadShort()
		temp_scene_list.left_monster_count = MsgAdapter.ReadShort()
		temp_scene_list.boss_count = MsgAdapter.ReadShort()
		temp_scene_list.boss_list = {}
		for i = 1, temp_scene_list.boss_count do
			temp_scene_list.boss_list[i] = {}
			temp_scene_list.boss_list[i].boss_id = MsgAdapter.ReadInt()
			temp_scene_list.boss_list[i].next_flush_time = MsgAdapter.ReadUInt()
		end
		table.insert(self.scene_list, temp_scene_list)
	end
end

-- 神魔BOSS玩家信息
SCGodmagicBossPlayerInfo = SCGodmagicBossPlayerInfo or BaseClass(BaseProtocolStruct)
function SCGodmagicBossPlayerInfo:__init()
	self.msg_type = 8912

	self.left_ordinary_crystal_gather_times = 0
	self.left_can_kill_boss_num = 0
	self.left_treasure_crystal_gather_times = 0
	self.concern_flag = {}
end

function SCGodmagicBossPlayerInfo:Decode()
	self.left_can_kill_boss_num = MsgAdapter.ReadShort()
	self.left_treasure_crystal_gather_times = MsgAdapter.ReadShort()
	self.left_ordinary_crystal_gather_times = MsgAdapter.ReadInt()
end

-- 神魔boss场景里的玩家信息
SCGodmagicBossSceneInfo = SCGodmagicBossSceneInfo or BaseClass(BaseProtocolStruct)
function SCGodmagicBossSceneInfo:__init()
	self.msg_type = 8913
end

function SCGodmagicBossSceneInfo:Decode()
	self.left_monster_count = MsgAdapter.ReadShort()						-- 剩余小怪数量
	self.left_treasure_crystal_num = MsgAdapter.ReadShort()					-- 剩余珍惜水晶数量
	self.layer = MsgAdapter.ReadShort()
	self.treasure_crystal_gather_id = MsgAdapter.ReadShort()				-- 珍惜水晶采集物id
	self.monster_next_flush_timestamp = MsgAdapter.ReadUInt()				-- 小怪下次刷新时间
	self.treasure_crystal_next_flush_timestamp = MsgAdapter.ReadUInt()		-- 珍惜水晶下次刷新时间
	self.boss_list = {}
	for i = 1, GameEnum.MAX_CROSS_MIZANG_BOSS_PER_SCENE do
		local vo = {}
		vo.boss_id = MsgAdapter.ReadInt()
		vo.is_exist = MsgAdapter.ReadInt()
		vo.next_flush_time = MsgAdapter.ReadUInt()
		if vo.boss_id > 0 then
			table.insert(self.boss_list,vo)
		end
	end
end


------------神魔BOSS击杀历史-----------------
SCGodmagicBossKillRecord = SCGodmagicBossKillRecord or BaseClass(BaseProtocolStruct)
function SCGodmagicBossKillRecord:__init()
	self.msg_type = 8914

	self.record_count = 0
	self.killer_record_list = {}
end

function SCGodmagicBossKillRecord:Decode()
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

SCGodmagicBossDropRecord = SCGodmagicBossDropRecord or BaseClass(BaseProtocolStruct)
function SCGodmagicBossDropRecord:__init()
	self.msg_type = 8915
	self.dorp_record_list = {}
end

function SCGodmagicBossDropRecord:Decode()
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


-- 今日主题
CSTodayThemeRewardReq = CSTodayThemeRewardReq or BaseClass(BaseProtocolStruct)
function CSTodayThemeRewardReq:__init()
	self.msg_type = 8916
	self.seq = 0
end

function CSTodayThemeRewardReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.seq)
end

SCTodayThemeRewardFlagInfo = SCTodayThemeRewardFlagInfo or BaseClass(BaseProtocolStruct)
function SCTodayThemeRewardFlagInfo:__init()
	self.msg_type = 8917
end

function SCTodayThemeRewardFlagInfo:Decode()
	self.fetch_flag = {}
	for i = 0, 15 do
		self.fetch_flag[i] = MsgAdapter.ReadUChar()
	end
end


SCBaiBeiFanLi2Info = SCBaiBeiFanLi2Info or BaseClass(BaseProtocolStruct)
function SCBaiBeiFanLi2Info:__init()
	self.msg_type = 8918
	self.is_buy = 0
	self.close_time = 0
end

function SCBaiBeiFanLi2Info:Decode()
	self.is_buy = MsgAdapter.ReadInt()
	self.close_time = MsgAdapter.ReadUInt()
end

--百倍返利购买
CSBaiBeiFanLi2Buy = CSBaiBeiFanLi2Buy or BaseClass(BaseProtocolStruct)
function CSBaiBeiFanLi2Buy:__init()
	self.msg_type = 8919
end

function CSBaiBeiFanLi2Buy:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--限购礼包信息
SCRAOpenGameGiftShopBuy2Info = SCRAOpenGameGiftShopBuy2Info or BaseClass(BaseProtocolStruct)
function SCRAOpenGameGiftShopBuy2Info:__init()
	self.msg_type = 8920
end

function SCRAOpenGameGiftShopBuy2Info:Decode()
	self.buy_flag = MsgAdapter.ReadInt()
end

--  限购礼包2
CSRAOpenGameGiftShopBuy2 = CSRAOpenGameGiftShopBuy2 or BaseClass(BaseProtocolStruct)
function CSRAOpenGameGiftShopBuy2:__init()
	self.msg_type = 8921
	self.opera_type = 0
	self.seq = 0
end

function CSRAOpenGameGiftShopBuy2:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opera_type)
	MsgAdapter.WriteInt(self.seq)
end

-- 随机活动-至尊充值排行
SCRAChongzhiRank2Info = SCRAChongzhiRank2Info or BaseClass(BaseProtocolStruct)
function SCRAChongzhiRank2Info:__init()
	self.msg_type = 8982
	self.chongzhi_num = 0
end

function SCRAChongzhiRank2Info:Decode()
	self.chongzhi_num = MsgAdapter.ReadInt()
end

CSBaizhanEquipOpera = CSBaizhanEquipOpera or BaseClass(BaseProtocolStruct)
function CSBaizhanEquipOpera:__init()
	self.msg_type = 8926
	self.operate = 0
	self.param1 = 0
	self.param2 = 0
end

function CSBaizhanEquipOpera:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.operate)
	MsgAdapter.WriteShort(self.param1)
	MsgAdapter.WriteInt(self.param2)
end

-- 返回百战装备
SCBaizhanEquipAllInfo = SCBaizhanEquipAllInfo or BaseClass(BaseProtocolStruct)
function SCBaizhanEquipAllInfo:__init()
	self.msg_type = 8927
end

function SCBaizhanEquipAllInfo:Decode()
	self.baizhan_equip = {}
	self.baizhan_part_order_list = {}
	self.baizhan_order_count_list = {}
	for i = 0, COMMON_CONSTS.BAIZHAN_E_INDEX_MAX do
		local equip_tab = ProtocolStruct.ReadItemDataWrapper()
		equip_tab.index = i 	-- 给装备下标
		self.baizhan_equip[i] = equip_tab
	end
	for i = 0, COMMON_CONSTS.BAIZHAN_E_INDEX_MAX do
		self.baizhan_part_order_list[i] = MsgAdapter.ReadChar()
	end
	for i = 0, COMMON_CONSTS.BAIZHAN_E_INDEX_MAX do
		self.baizhan_order_count_list[self.baizhan_part_order_list[i]] = self.baizhan_order_count_list[self.baizhan_part_order_list[i]] or 0
		self.baizhan_order_count_list[self.baizhan_part_order_list[i]] = self.baizhan_order_count_list[self.baizhan_part_order_list[i]] + 1
	end
	MsgAdapter.ReadShort()		
end

SCFirstRechargeBuffFlag = SCFirstRechargeBuffFlag or BaseClass(BaseProtocolStruct)
function SCFirstRechargeBuffFlag:__init()
	self.msg_type = 8933
	self.ra_is_has_first_recharge_attr_add = 0
end

function SCFirstRechargeBuffFlag:Decode()
	self.ra_is_has_first_recharge_attr_add = MsgAdapter.ReadShort()
    MsgAdapter.ReadShort()
end

------------------------
-----四阶神装
SCZeroGiftGodCostumeInfo = SCZeroGiftGodCostumeInfo or BaseClass(BaseProtocolStruct)
function SCZeroGiftGodCostumeInfo:__init()
	self.msg_type = 8922
end

function SCZeroGiftGodCostumeInfo:Decode()
	self.zero_gift_god_costume_info = {}
	for i = 1, 5 do
		self.zero_gift_god_costume_info[i] = {}
		
		self.zero_gift_god_costume_info[i].buy_state = MsgAdapter.ReadInt() 	--购买状态
		self.zero_gift_god_costume_info[i].reward_flag = MsgAdapter.ReadInt() --领取奖励标记
	end
end

------单笔返利-------
SCLoveDaily2Info = SCLoveDaily2Info or BaseClass(BaseProtocolStruct)
function SCLoveDaily2Info:__init()
	self.msg_type = 8923
end

function SCLoveDaily2Info:Decode()
	self.flag = MsgAdapter.ReadInt() 				--单笔返利 充值标记
end

SCEquipUplevelSuitInfo = SCEquipUplevelSuitInfo or BaseClass(BaseProtocolStruct)
function SCEquipUplevelSuitInfo:__init()
	self.msg_type = 8924 
end

function SCEquipUplevelSuitInfo:Decode()
	self.suit_level = MsgAdapter.ReadInt()
	self.suit_active_flag = MsgAdapter.ReadInt()
end

-----部分玩法活动奖励展示
SCSceneActivityRewardInfo = SCSceneActivityRewardInfo or BaseClass(BaseProtocolStruct)
function SCSceneActivityRewardInfo:__init()
	self.msg_type = 8925
end

function SCSceneActivityRewardInfo:Decode()
	self.activity_id = MsgAdapter.ReadInt()
	self.reward_type = MsgAdapter.ReadInt()
	self.reward_id = MsgAdapter.ReadInt()
	self.param = MsgAdapter.ReadInt()
end


------装备觉醒-----------------------------------
SCZhuanzhiEquipAwakeningAllInfo = SCZhuanzhiEquipAwakeningAllInfo or BaseClass(BaseProtocolStruct)
function SCZhuanzhiEquipAwakeningAllInfo:__init()
	self.msg_type = 8928
end

function SCZhuanzhiEquipAwakeningAllInfo:Decode()
	self.zhuanzhi_all_equip_awakening_lock_flag = {}
	for i = 0, 3 do
		self.zhuanzhi_all_equip_awakening_lock_flag[i] = MsgAdapter.ReadUChar()
	end
	self.zhuanzhi_all_equip_awakening_list = {}
	for i = 0, GameEnum.MAX_ZHUANZHI_EQUIP_COUNT - 1 do
		self.zhuanzhi_all_equip_awakening_list[i] = {}
		local vo = {}
		for j = 1, GameEnum.MAX_ZHUANZHI_EQUIP_AWAKENING_COUNT do
			vo[j] = {}
			vo[j].type = MsgAdapter.ReadUShort()
			vo[j].level = MsgAdapter.ReadUShort()
			
		end
		self.zhuanzhi_all_equip_awakening_list[i].awakening_in_equip = vo

		local vo1 = {}
		for j = 1, GameEnum.MAX_ZHUANZHI_EQUIP_AWAKENING_COUNT do
			vo1[j] = {}
			vo1[j].type = MsgAdapter.ReadUShort()
			vo1[j].level = MsgAdapter.ReadUShort()
		end
		self.zhuanzhi_all_equip_awakening_list[i].awakening_in_displacement = vo1
	end
end

SCZhuanzhiEquipAwakeningInfo = SCZhuanzhiEquipAwakeningInfo or BaseClass(BaseProtocolStruct)
function SCZhuanzhiEquipAwakeningInfo:__init()
	self.msg_type = 8929
end

function SCZhuanzhiEquipAwakeningInfo:Decode()
	self.zhuanzhi_equip_index = MsgAdapter.ReadInt()

	self.zhuanzhi_equip_awakening_lock_flag = {}
	for i = 0, 3 do
		self.zhuanzhi_equip_awakening_lock_flag[i] = MsgAdapter.ReadUChar()
	end

	self.zhuanzhi_equip_awakening_list = {}
	local vo = {}
	for j = 1, GameEnum.MAX_ZHUANZHI_EQUIP_AWAKENING_COUNT do
		vo[j] = {}
		vo[j].type = MsgAdapter.ReadUShort()
		vo[j].level = MsgAdapter.ReadUShort()
		
	end
	self.zhuanzhi_equip_awakening_list.awakening_in_equip = vo

	local vo1 = {}
	for j = 1, GameEnum.MAX_ZHUANZHI_EQUIP_AWAKENING_COUNT do
		vo1[j] = {}
		vo1[j].type = MsgAdapter.ReadUShort()
		vo1[j].level = MsgAdapter.ReadUShort()
	end
	self.zhuanzhi_equip_awakening_list.awakening_in_displacement = vo1
end

---------------------------------------------------

-- 珍稀掉落请求同步日志
CSGetGuildRareLog = CSGetGuildRareLog or BaseClass(BaseProtocolStruct)
function CSGetGuildRareLog:__init()
	self.msg_type = 8930
end

function CSGetGuildRareLog:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 珍稀日志信息
SCGuildRareLogRet = SCGuildRareLogRet or BaseClass(BaseProtocolStruct)
function SCGuildRareLogRet:__init()
	self.msg_type = 8931
end

function SCGuildRareLogRet:Decode()
	self.count = MsgAdapter.ReadInt()

	self.data_list = {}
	for i = 1, self.count do
		local data = {}
		data.role_id = MsgAdapter.ReadUInt()
		data.plat_id = MsgAdapter.ReadUInt()
		data.role_name = MsgAdapter.ReadStrN(32)
		data.item_id = MsgAdapter.ReadUShort()
		data.item_num = MsgAdapter.ReadShort()
		data.is_from_gift = MsgAdapter.ReadShort()
		data.gift_item_id = MsgAdapter.ReadUShort()
		data.timestamp = MsgAdapter.ReadUInt()
		data.scene_id = MsgAdapter.ReadInt()
		data.monster_id = MsgAdapter.ReadInt()
		data.xianpin_type_list = {}
		for i = 1, COMMON_CONSTS.XIANPIN_MAX_NUM do
			local xianpin_type = MsgAdapter.ReadUShort()
			if xianpin_type > 0 then
				table.insert(data.xianpin_type_list, xianpin_type)
			end
		end
		table.insert(self.data_list, data)
	end
end


--小助手请求完成
CSLittleHelperOpera = CSLittleHelperOpera or BaseClass(BaseProtocolStruct)
function CSLittleHelperOpera:__init()
	self.msg_type = 8932
	self.type = 0
	self.param_0 = 0
	self.param_1 = 0
	self.param_2 = 0
end

function CSLittleHelperOpera:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.type)
	MsgAdapter.WriteShort(self.param_0)
	MsgAdapter.WriteShort(self.param_1)
	MsgAdapter.WriteShort(self.param_2)
end
 
local TIANSHU_XUNZHU_MAX_TYPE_COUNT = 8
SCTianShuXZInfo = SCTianShuXZInfo or BaseClass(BaseProtocolStruct)
function SCTianShuXZInfo:__init()
	self.msg_type = 8935
end

function SCTianShuXZInfo:Decode()
	self.fetch_flag_list = {}		--目标领取标记列表
	self.act_flag_list = {}		--目标激活标记列表
	self.equip_level_50 = MsgAdapter.ReadShort()
	self.equip_level_100 = MsgAdapter.ReadShort()
	self.zhuanzhi_equip_fangyu = MsgAdapter.ReadLL()
	for i = 1, TIANSHU_XUNZHU_MAX_TYPE_COUNT do
		self.fetch_flag_list[i] = MsgAdapter.ReadUInt()
	end
	for i = 1, TIANSHU_XUNZHU_MAX_TYPE_COUNT do
		self.act_flag_list[i] = MsgAdapter.ReadUInt()
	end
	self.baizhan_equip_num = MsgAdapter.ReadShort()
	self.reserve_sh = MsgAdapter.ReadShort()
end

CSTianShuXZFetchReward = CSTianShuXZFetchReward or BaseClass(BaseProtocolStruct)
function CSTianShuXZFetchReward:__init()
	self.msg_type = 8936
	self.type = 0
	self.tianshu_type = 0
	self.seq = 0
end

function CSTianShuXZFetchReward:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.type)
	MsgAdapter.WriteShort(self.tianshu_type)
	MsgAdapter.WriteShort(self.seq)
end

CSEquipUplevelSuitActive = CSEquipUplevelSuitActive or BaseClass(BaseProtocolStruct)
function CSEquipUplevelSuitActive:__init()
	self.msg_type = 8937
end

function CSEquipUplevelSuitActive:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.active_suit_level)
end

-- 经验buff信息
SCExpBuffInfo = SCExpBuffInfo or BaseClass(BaseProtocolStruct)
function SCExpBuffInfo:__init()
	self.msg_type = 8938
end

function SCExpBuffInfo:Decode()
	self.exp_buff_list = {}
	for i = 1, 4 do
		local temp_list = {}
		temp_list.exp_buff_left_time_s = MsgAdapter.ReadInt()
		temp_list.exp_buff_rate = MsgAdapter.ReadShort()
		temp_list.exp_buff_level  = MsgAdapter.ReadChar()
		temp_list.reserve_ch = MsgAdapter.ReadChar()
		table.insert(self.exp_buff_list, temp_list)
	end
end

SCLittleHelperItemInfo = SCLittleHelperItemInfo or BaseClass(BaseProtocolStruct)
function SCLittleHelperItemInfo:__init()
	self.msg_type = 8939 
end

function SCLittleHelperItemInfo:Decode()
	self.item_count = MsgAdapter.ReadInt()
	if self.item_count > 400 then 							--400是最多物品掉落数量
		self.item_count = 400
	end
	self.reward_list = {}
	if self.item_count > 0 then
		for i = 1, self.item_count do
			local temp_list = {}
			temp_list.item_id = MsgAdapter.ReadUShort()
			temp_list.is_bind = MsgAdapter.ReadShort()
			temp_list.num = MsgAdapter.ReadInt()
			temp_list.xianpin_type_list = {}
			for j = 1, 6 do
				temp_list.xianpin_type_list[j] = MsgAdapter.ReadUShort()
			end
			table.insert(self.reward_list, temp_list)
		end
	end
end

CSCrossChallengeFieldOpera = CSCrossChallengeFieldOpera or BaseClass(BaseProtocolStruct)
function CSCrossChallengeFieldOpera:__init()
	self.msg_type = 8940
	self.req_type = 0
	self.param1 = 0
	self.param2 = 0
	self.param3 = 0
end

function CSCrossChallengeFieldOpera:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.req_type)
	MsgAdapter.WriteShort(self.param1)
	MsgAdapter.WriteShort(self.param2)
	MsgAdapter.WriteShort(self.param3)
end

SCCrossChallengeFieldStatus = SCCrossChallengeFieldStatus or BaseClass(BaseProtocolStruct)
function SCCrossChallengeFieldStatus:__init()
	self.msg_type = 8941
	self.status = 0
	self.side_info_list = {}
end

function SCCrossChallengeFieldStatus:Decode()
	self.status = MsgAdapter.ReadInt()
	self.next_status_timestamp = MsgAdapter.ReadUInt()
	for i=1, 2 do
		local role_vo = {}
		role_vo.role_id = MsgAdapter.ReadUInt()
		role_vo.plat_type = MsgAdapter.ReadUInt()
		role_vo.obj_id = MsgAdapter.ReadUShort()
		role_vo.level = MsgAdapter.ReadShort()
		role_vo.name = MsgAdapter.ReadStrN(32)
		role_vo.camp = MsgAdapter.ReadChar()
		role_vo.prof = MsgAdapter.ReadChar()
		role_vo.avatar = MsgAdapter.ReadChar()
		role_vo.sex = MsgAdapter.ReadChar()
		role_vo.hp = MsgAdapter.ReadLL()
		role_vo.max_hp = MsgAdapter.ReadLL()
		role_vo.mp = MsgAdapter.ReadLL()
		role_vo.max_mp = MsgAdapter.ReadLL()
		role_vo.speed = MsgAdapter.ReadLL()
		role_vo.pos_x = MsgAdapter.ReadShort()
		role_vo.pos_y = MsgAdapter.ReadShort()
		role_vo.dir = MsgAdapter.ReadFloat()
		role_vo.distance = MsgAdapter.ReadFloat()
		role_vo.capability = MsgAdapter.ReadInt()
		role_vo.guild_id = MsgAdapter.ReadInt()
		role_vo.guild_name = MsgAdapter.ReadStrN(32)
		role_vo.guild_post = MsgAdapter.ReadChar()
		MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()

		self.side_info_list[i] = role_vo
	end
end

SCCrossChallengeFieldOpponentInfo = SCCrossChallengeFieldOpponentInfo or BaseClass(BaseProtocolStruct)
function SCCrossChallengeFieldOpponentInfo:__init()
	self.msg_type = 8943
	self.role_info = {}
end

function SCCrossChallengeFieldOpponentInfo:Decode()
	self.role_info = {}
	local role_count = MsgAdapter.ReadInt()
	for i = 1, role_count do
		local role_vo = GameVoManager.Instance:CreateVo(RoleVo)
		role_vo.server_id = MsgAdapter.ReadInt()
		role_vo.user_id = MsgAdapter.ReadUInt()
		role_vo.plat_type = MsgAdapter.ReadUInt()
		role_vo.avatar_key_big = MsgAdapter.ReadUInt()
		role_vo.avatar_key_small = MsgAdapter.ReadUInt()
		role_vo.camp = MsgAdapter.ReadChar()
		role_vo.prof = MsgAdapter.ReadChar()
		role_vo.sex = MsgAdapter.ReadChar()
		role_vo.avatar = MsgAdapter.ReadChar()
		role_vo.capability = MsgAdapter.ReadInt()
		role_vo.best_rank_break_level = MsgAdapter.ReadInt()
		
		role_vo.name = MsgAdapter.ReadStrN(32)
		role_vo.appearance = ProtocolStruct.ReadRoleAppearance()
		table.insert(self.role_info, role_vo)
	end
end

SCCrossChallengeFieldUserInfo = SCCrossChallengeFieldUserInfo or BaseClass(BaseProtocolStruct)
function SCCrossChallengeFieldUserInfo:__init()
	self.msg_type = 8942
	self.user_info = {}
end

function SCCrossChallengeFieldUserInfo:Decode()
	self.user_info = {}

	self.user_info.rank_pos = MsgAdapter.ReadInt()
	self.user_info.rank = self.user_info.rank_pos + 1
	self.user_info.curr_opponent_idx = MsgAdapter.ReadInt()
	self.user_info.join_times = MsgAdapter.ReadInt()
	self.user_info.buy_join_times = MsgAdapter.ReadInt()
	self.user_info.jifen = MsgAdapter.ReadInt()
	local flag = MsgAdapter.ReadInt()

	self.user_info.jifen_reward_flag = {}
	for i = 0, 31 do
		self.user_info.jifen_reward_flag[i] = (bit:_and(flag, bit:_lshift(1, i))) == 0
	end

	self.user_info.reward_guanghui = MsgAdapter.ReadInt()
	self.user_info.reward_bind_gold = MsgAdapter.ReadInt()
	self.user_info.liansheng = MsgAdapter.ReadInt()
	self.user_info.buy_buff_times = MsgAdapter.ReadInt()
	local best_rank_pos = MsgAdapter.ReadInt()
	self.user_info.best_rank_pos = best_rank_pos + 1
	self.user_info.free_day_times = MsgAdapter.ReadInt()

	self.user_info.item_list = {}
	for i = 1, 3 do
		local data = {}
		data.item_id = MsgAdapter.ReadUShort()
		data.num = MsgAdapter.ReadShort()
		if data.item_id > 0 then
			table.insert(self.user_info.item_list, data)
		end
	end

	self.user_info.rank_list = {}

	for i = 1, 4 do
		local data = {}
		data.user_id = MsgAdapter.ReadUInt()
		data.plat_type = MsgAdapter.ReadUInt()
		data.rank_pos = MsgAdapter.ReadInt()
		data.index = i - 1 						-- 真实索引与服务端对应
		data.rank = data.rank_pos + 1 			-- 界面显示排名用这个
		table.insert(self.user_info.rank_list, 1, data)
	end

	for k,v in pairs(self.user_info.rank_list) do
		if v.user_id ==  GameVoManager.Instance:GetMainRoleVo().role_id then
			self.user_info.rank_list[k] = nil
		end
	end
end

--跨服排位变化通知
SCCrossChallengeFieldOpponentRankPosChange =  SCCrossChallengeFieldOpponentRankPosChange or BaseClass(BaseProtocolStruct)
function SCCrossChallengeFieldOpponentRankPosChange:__init()
	self.msg_type = 8948
	self.user_id = 0
	self.rank_pos = 0
end

function SCCrossChallengeFieldOpponentRankPosChange:Decode()
	self.user_id = MsgAdapter.ReadLL()
	self.rank_pos = MsgAdapter.ReadInt()
end

--跨服战报
SCCrossChallengeFieldReportInfo =  SCCrossChallengeFieldReportInfo or BaseClass(BaseProtocolStruct)
function SCCrossChallengeFieldReportInfo:__init()
	self.msg_type = 8946
	self.report_info = {}
end

function SCCrossChallengeFieldReportInfo:Decode()
	self.report_info = {}
	local report_count = MsgAdapter.ReadInt()
	for i = 1, report_count do
		local data = {}
		data.challenge_time = MsgAdapter.ReadUInt()
		data.target_uid = MsgAdapter.ReadUInt()
		data.plat_type = MsgAdapter.ReadUInt()
		data.target_name = MsgAdapter.ReadStrN(32)
		data.is_sponsor = MsgAdapter.ReadChar()
		data.is_win = MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()
		data.old_rankpos = MsgAdapter.ReadUShort()
		data.new_rankpos = MsgAdapter.ReadUShort()
		table.insert(self.report_info, data)
	end
	function SortFun(a, b)
		return a.challenge_time > b.challenge_time
	end
	if #self.report_info ~= 0 then
		table.sort(self.report_info, SortFun)
	end
end

--跨服英雄榜
SCCrossChallengeFieldRankInfo =  SCCrossChallengeFieldRankInfo or BaseClass(BaseProtocolStruct)
function SCCrossChallengeFieldRankInfo:__init()
	self.msg_type = 8947
	self.rank_info = {}
end

function SCCrossChallengeFieldRankInfo:Decode()
	self.rank_info = {}
	for i = 1, 100 do
		local data = {}
		data.server_id = MsgAdapter.ReadInt()
		data.user_id = MsgAdapter.ReadUInt()
		data.plat_type = MsgAdapter.ReadUInt()
		data.capability = MsgAdapter.ReadInt()
		data.target_name = MsgAdapter.ReadStrN(32)
		data.sex = MsgAdapter.ReadChar()
		data.is_robot = MsgAdapter.ReadChar()
		data.prof = MsgAdapter.ReadChar()
		MsgAdapter.ReadChar()
		data.role_level = MsgAdapter.ReadInt()
		data.rank = i
		data.appearance = ProtocolStruct.ReadRoleAppearance()
		if data.user_id ~= 0 then
			table.insert(self.rank_info, data)
		end
	end
end

--跨服竞技场被打败通知
SCCrossChallengeFieldBeDefeatNotice =  SCCrossChallengeFieldBeDefeatNotice or BaseClass(BaseProtocolStruct)
function SCCrossChallengeFieldBeDefeatNotice:__init()
	self.msg_type = 8944
end

function SCCrossChallengeFieldBeDefeatNotice:Encode()
end


--跨服竞技场直接胜利
SCCrossChallengeFieldWin =  SCCrossChallengeFieldWin or BaseClass(BaseProtocolStruct)
function SCCrossChallengeFieldWin:__init()
	self.msg_type = 8945
end

function SCCrossChallengeFieldWin:Decode()
	self.old_rank_pos = MsgAdapter:ReadShort()
	self.new_rank_pos = MsgAdapter:ReadShort()
end

-- 装备合成
CSZhuanzhiEquipCompose = CSZhuanzhiEquipCompose or BaseClass(BaseProtocolStruct)
function CSZhuanzhiEquipCompose:__init()
	self.msg_type = 8952
end

function CSZhuanzhiEquipCompose:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteUShort(self.item_id)
	MsgAdapter.WriteShort(self.xianpin_num)
	MsgAdapter.WriteShort(self.bag_index_count)
	for k, v in pairs(self.bag_index_list) do
		MsgAdapter.WriteShort(v)
	end
end
---------------------------------------------------

CSDiscountShopBuy = CSDiscountShopBuy or BaseClass(BaseProtocolStruct)
function CSDiscountShopBuy:__init()
	self.msg_type = 8950
	self.seq = 0
	self.num = 0
end

function CSDiscountShopBuy:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.seq)
	MsgAdapter.WriteInt(self.num)
end

SCSendDiscounthopItemInfo = SCSendDiscounthopItemInfo or BaseClass(BaseProtocolStruct)
function SCSendDiscounthopItemInfo:__init()
	self.msg_type = 8951
	self.client_remind_flag = 0
	self.today_free_count = 0
end

function SCSendDiscounthopItemInfo:Decode()
	self.item_count = MsgAdapter.ReadInt()
	self.today_refresh_level = MsgAdapter.ReadInt()
	self.item_list = {}
	for i = 1, self.item_count do
		self.item_list[i] = {}
		self.item_list[i].seq = MsgAdapter.ReadInt()
		self.item_list[i].today_buy_count = MsgAdapter.ReadInt()
	end
end
SCLittleHelperInfo = SCLittleHelperInfo or BaseClass(BaseProtocolStruct)
function SCLittleHelperInfo:__init()
	self.msg_type = 8953
end

function SCLittleHelperInfo:Decode()
	self.type = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
end
---------------------------------------------------

-- 幸运云购基本信息
SCRALuckyCloudBuyInfo = SCRALuckyCloudBuyInfo or BaseClass(BaseProtocolStruct)
function SCRALuckyCloudBuyInfo:__init()
	self.msg_type = 8954
end

function SCRALuckyCloudBuyInfo:Decode()
	self.seq = MsgAdapter.ReadUShort()
	self.buy_self = MsgAdapter.ReadUShort()
end

-- 幸运云购购买记录
SCRALuckyCloudBuyBuyList = SCRALuckyCloudBuyBuyList or BaseClass(BaseProtocolStruct)
function SCRALuckyCloudBuyBuyList:__init()
	self.msg_type = 8955
end

function SCRALuckyCloudBuyBuyList:Decode()
	self.ret_timestamp = MsgAdapter.ReadUInt()
	self.total_buy = MsgAdapter.ReadUShort()
	local num = MsgAdapter.ReadUShort()
	self.name_list = {}
	for i = 1, num do
		self.name_list[i] = MsgAdapter.ReadStrN(32)
	end
end

-- 幸运云购开启通知
SCRALuckyCloudBuyOpenInfo = SCRALuckyCloudBuyOpenInfo or BaseClass(BaseProtocolStruct)
function SCRALuckyCloudBuyOpenInfo:__init()
	self.msg_type = 8956
end

function SCRALuckyCloudBuyOpenInfo:Decode()
	self.is_open = MsgAdapter.ReadUInt()
end

-- 装备合成
SCZhuanzhiEquipComposeSucceed = SCZhuanzhiEquipComposeSucceed or BaseClass(BaseProtocolStruct)
function SCZhuanzhiEquipComposeSucceed:__init()
	self.msg_type = 8957
end

function SCZhuanzhiEquipComposeSucceed:Decode()
	self.is_succeed = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
end

--小助手全部完成请求 
CSLittleHelperRepeatOpera = CSLittleHelperRepeatOpera or BaseClass(BaseProtocolStruct)
function CSLittleHelperRepeatOpera:__init()
	self.msg_type = 8958
	self.count = 0
end

function CSLittleHelperRepeatOpera:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.count)
	for i = 1, LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_MAX do
		local task_type = self.task_type_list[i] or -1
		MsgAdapter.WriteShort(task_type)
		local param0 = self.param_list0[i] or 0
		MsgAdapter.WriteShort(param0)
		local param1 = self.param_list1[i] or 0
		MsgAdapter.WriteShort(param1)
		MsgAdapter.WriteShort(0)
	end
end


------------------------------狂欢大乐购-----------------------------------
--疯狂抢购面板信息
SCRACrazyBuyAllInfo =  SCRACrazyBuyAllInfo or BaseClass(BaseProtocolStruct)
function SCRACrazyBuyAllInfo:__init()
	self.msg_type = 8959
end

function SCRACrazyBuyAllInfo:Decode()
	self.chongzhi = MsgAdapter.ReadInt()
	self.level = MsgAdapter.ReadInt()
end

--限购信息
SCRACracyBuyLimitInfo =  SCRACracyBuyLimitInfo or BaseClass(BaseProtocolStruct)
function SCRACracyBuyLimitInfo:__init()
	self.msg_type = 8960
end

function SCRACracyBuyLimitInfo:Decode()
	self.limit_list = {}
	for i = 1, GameEnum.RA_MAX_CRACY_BUY_NUM_LIMIT do
		local limit_info = {}
		limit_info.person_limit = MsgAdapter.ReadInt()
		limit_info.all_limit = MsgAdapter.ReadInt()
		
		table.insert(self.limit_list, limit_info)
	end
end
----------------------------------------------------------------------------
--==============================神话系统==============================
--====================================================================
-- 请求操作
CSMythOpera = CSMythOpera or BaseClass(BaseProtocolStruct)
function CSMythOpera:__init()
	self.msg_type = 8968
end

function CSMythOpera:Encode()
    MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opera_type)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
	MsgAdapter.WriteInt(self.param3)
	MsgAdapter.WriteInt(self.param4)
end

-- 篇章全部信息
SCMythChpaterInfo  = SCMythChpaterInfo  or BaseClass(BaseProtocolStruct)
function SCMythChpaterInfo:__init()
	self.msg_type = 8969
end

function SCMythChpaterInfo:Decode()
	self.soul_essence = MsgAdapter.ReadInt()
	self.chpater_list = {}
	for i=1,MYTH_TYPE.MAX_MYTH_CHAPTER_ID do
		local chpater = {}
		chpater.level = MsgAdapter.ReadShort()
		chpater.digestion_level = MsgAdapter.ReadShort()
		chpater.digestion_level_val = MsgAdapter.ReadInt()

		-- 共鸣信息
		local resonance_list = {}
		local cur_level_resonance = {}
		for i1 = 1, MYTH_TYPE.MAX_MYTH_SOUL_SLOT do
			cur_level_resonance[i1] = MsgAdapter.ReadChar()
		end
		resonance_list.cur_level_resonance = cur_level_resonance
		resonance_list.reserver_sh_1 = MsgAdapter.ReadChar()
		resonance_list.resonance_level = MsgAdapter.ReadShort()
		resonance_list.reserver_sh_2 = MsgAdapter.ReadShort()
		chpater.resonance_list = resonance_list

		local soul_god_list = {}
		for i1=1,MYTH_TYPE.MAX_MYTH_SOUL_SLOT do
			local myth_soul_god_item = {}
			myth_soul_god_item.item_id = MsgAdapter.ReadUShort()
			myth_soul_god_item.reserve_sh = MsgAdapter.ReadChar()
			myth_soul_god_item.quality = MsgAdapter.ReadChar()
			local attr_list = {}
			for i2=1, MYTH_TYPE.MAX_MYTH_SOUL_RAND_ATTR_COUNT do
				local attr_item = {}
				attr_item.attr_type = MsgAdapter.ReadShort()
				attr_item.reserve_sh = MsgAdapter.ReadShort()
				attr_item.attr_value = MsgAdapter.ReadInt()
				attr_list[i2] = attr_item
			end
			myth_soul_god_item.attr_list = attr_list

			soul_god_list[i1] = myth_soul_god_item
		end
		chpater.soul_god_list = soul_god_list

		self.chpater_list[i] = chpater
	end
end

-- 背包信息
SCMythKnapaskInfo  = SCMythKnapaskInfo  or BaseClass(BaseProtocolStruct)
function SCMythKnapaskInfo:__init()
	self.msg_type = 8970
end

function SCMythKnapaskInfo:Decode()
	self.is_all = MsgAdapter.ReadShort()		--是否下发全部信息
	self.count = MsgAdapter.ReadShort()			--格子数据改变的数量
	self.list = {}
	for i=1, self.count do
		local grid_item = {}
		grid_item.index = MsgAdapter.ReadInt()

		local myth_soul_god_item = {}
		myth_soul_god_item.item_id = MsgAdapter.ReadUShort()
		myth_soul_god_item.num = MsgAdapter.ReadChar()
		myth_soul_god_item.quality = MsgAdapter.ReadChar()
		attr_list = {}
		for i1=1, MYTH_TYPE.MAX_MYTH_SOUL_RAND_ATTR_COUNT do
			local attr_item = {}
			attr_item.attr_type = MsgAdapter.ReadShort()
			attr_item.reserve_sh = MsgAdapter.ReadShort()
			attr_item.attr_value = MsgAdapter.ReadInt()
			attr_list[i1] = attr_item
		end
		myth_soul_god_item.attr_list = attr_list

		grid_item.item = myth_soul_god_item

		self.list[grid_item.index] = grid_item
	end
end

--单个篇章信息
SCMythChpaterSingleInfo  = SCMythChpaterSingleInfo  or BaseClass(BaseProtocolStruct)
function SCMythChpaterSingleInfo:__init()
	self.msg_type = 8971
end

function SCMythChpaterSingleInfo:Decode()
	self.soul_essence = MsgAdapter.ReadInt()
	self.chpater_id = MsgAdapter.ReadInt()
	self.chpater_list = {}
	self.chpater_list.level = MsgAdapter.ReadShort()
	self.chpater_list.digestion_level = MsgAdapter.ReadShort()
	self.chpater_list.digestion_level_val = MsgAdapter.ReadInt()

	local resonance_list = {}
	local cur_level_resonance = {}
	for i1 = 1, MYTH_TYPE.MAX_MYTH_SOUL_SLOT do
		cur_level_resonance[i1] = MsgAdapter.ReadChar()
	end
	resonance_list.cur_level_resonance = cur_level_resonance
	resonance_list.reserver_sh_1 = MsgAdapter.ReadChar()
	resonance_list.resonance_level = MsgAdapter.ReadShort()
	resonance_list.reserver_sh_2 = MsgAdapter.ReadShort()
	self.chpater_list.resonance_list = resonance_list

	local soul_god_list = {}
	for i1=1, MYTH_TYPE.MAX_MYTH_SOUL_SLOT do
		local myth_soul_god_item = {}
		myth_soul_god_item.item_id = MsgAdapter.ReadUShort()
		myth_soul_god_item.reserve_sh = MsgAdapter.ReadChar()
		myth_soul_god_item.quality = MsgAdapter.ReadChar()
		myth_soul_god_item.attr_list = {}

		local attr_list = {}
		for i2=1,MYTH_TYPE.MAX_MYTH_SOUL_RAND_ATTR_COUNT do
			local attr_item = {}
			attr_item.attr_type = MsgAdapter.ReadShort()
			attr_item.reserve_sh = MsgAdapter.ReadShort()
			attr_item.attr_value = MsgAdapter.ReadInt()
			attr_list[i2] = attr_item
		end
		myth_soul_god_item.attr_list = attr_list

		soul_god_list[i1] = myth_soul_god_item
	end
	self.chpater_list.soul_god_list = soul_god_list
end

--------------------------------
----------斗气
-- 操作请求
CSCrossEquipOpera = CSCrossEquipOpera or BaseClass(BaseProtocolStruct)
function CSCrossEquipOpera:__init()
	self.msg_type = 8961

	self.req_type = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
end

function CSCrossEquipOpera:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteUShort(self.req_type)
	MsgAdapter.WriteUShort(self.param_1)
	MsgAdapter.WriteUShort(self.param_2)
	MsgAdapter.WriteUShort(self.param_3)
end

-- 信息下发
SCCrossEquipAllInfo = SCCrossEquipAllInfo or BaseClass(BaseProtocolStruct)
function SCCrossEquipAllInfo:__init()
	self.msg_type = 8962

	self.douqi_grade = 0 	-- 当前斗气阶级
	self.xiulian_times = 0  -- 当天修炼次数
	self.douqi_exp = 0  -- 当前斗气经验
	self.chuanshi_frament = 0 --传世碎片
	self.douqidan_used_count = {}	
end

function SCCrossEquipAllInfo:Decode()
	self.douqi_grade = MsgAdapter.ReadUShort()
	self.xiulian_times = MsgAdapter.ReadUShort()
	self.douqi_exp = MsgAdapter.ReadLL()

	self.chuanshi_frament = MsgAdapter.ReadUInt()

	for i = 1, 3 do
		self.douqidan_used_count[i] = MsgAdapter.ReadUShort()
	end

	MsgAdapter.ReadUShort()
end

-- 抽奖返回
SCCrossEquipRollResult = SCCrossEquipRollResult or BaseClass(BaseProtocolStruct)
function SCCrossEquipRollResult:__init()
	self.msg_type = 8963
	self.chuanshi_score = 0
	self.reward_count = 0

	self.reward_list = {}
end

function SCCrossEquipRollResult:Decode()
	self.reward_list = {}
	self.chuanshi_score = MsgAdapter.ReadUInt()
	self.reward_count = MsgAdapter.ReadInt()

	for i = 1, self.reward_count do
		local item_id = MsgAdapter.ReadUShort()
		local reward_num = MsgAdapter.ReadShort()
		local reward = {item_id = item_id, num = reward_num}
		self.reward_list[i] = reward
	end
end

-- 单个装备信息 -- 穿脱
SCCrossEquipOneEquip = SCCrossEquipOneEquip or BaseClass(BaseProtocolStruct)
function SCCrossEquipOneEquip:__init()
	self.msg_type = 8964
	self.index = 0
	self.equipment = nil
end

function SCCrossEquipOneEquip:Decode()
	self.equipment = nil
	self.index = MsgAdapter.ReadInt()
	self.equipment = ProtocolStruct.ReadItemDataWrapper()
end

-- 所有装备信息
SCCrossEquipAllEquip = SCCrossEquipAllEquip or BaseClass(BaseProtocolStruct)
function SCCrossEquipAllEquip:__init()
	self.msg_type = 8965
	
	self.equipment_list = {}
end

function SCCrossEquipAllEquip:Decode()
	self.equipment_list = {}
	for i = 1, 10 do
		local equip_data = ProtocolStruct.ReadItemDataWrapper()
		self.equipment_list[i] = equip_data
	end
end

-- 传世碎片改变 右下角显示
SCCrossEquipChuanshiFragmentChange = SCCrossEquipChuanshiFragmentChange or BaseClass(BaseProtocolStruct)
function SCCrossEquipChuanshiFragmentChange:__init()
	self.msg_type = 8966
	self.change_type = 0
	self.change_fragment = 0
end

function SCCrossEquipChuanshiFragmentChange:Decode()
	self.change_type = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.change_fragment = MsgAdapter.ReadUInt()
end

-- 斗气经验改变 右下角显示
SCCrossEquipDouqiExpChange = SCCrossEquipDouqiExpChange or BaseClass(BaseProtocolStruct)
function SCCrossEquipDouqiExpChange:__init()
	self.msg_type = 8967
	self.add_exp = 0
end

function SCCrossEquipDouqiExpChange:Decode()
	self.add_exp = MsgAdapter.ReadInt()
end

--普通操作
 CSCrossHusongShuijingOpera =  CSCrossHusongShuijingOpera or BaseClass(BaseProtocolStruct)
function  CSCrossHusongShuijingOpera:__init()
	self.msg_type = 8979
	self.operate_type = 0 							--填2为请求精华护送信息，见枚举COMMON_OPERATE_TYPE，服务端发送SCCommonInfo
	self.param1 = 0
	self.param2 = 0
end

function  CSCrossHusongShuijingOpera:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.operate_type)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
end

--精华护送状态改变
SCCrossHusongShuijingInfo = SCCrossHusongShuijingInfo or BaseClass(BaseProtocolStruct)
function SCCrossHusongShuijingInfo:__init()
	self.msg_type = 8980
end
function SCCrossHusongShuijingInfo:Decode()
	-- self.obj_id = MsgAdapter.ReadUShort()						--视野内角色ID
	self.vip_buy_times = MsgAdapter.ReadShort() 				-- 购买次数
	self.rob_count = MsgAdapter.ReadShort() 					-- 截取成功次数
	self.gather_times = MsgAdapter.ReadShort() 					-- 采集次数
	self.commit_count = MsgAdapter.ReadUShort() 				-- 护送提交次数
	self.husong_type = MsgAdapter.ReadShort() 					-- 护送类型
	self.husong_status = MsgAdapter.ReadShort()					-- 护送状态
	self.invalid_time = MsgAdapter.ReadUInt()
	-- self.jinghua_husong_status = MsgAdapter.ReadShort()			--角色对应的护送状态
	-- self.jinghua_husong_type = MsgAdapter.ReadChar() 			--当前护送精华的类型，0为大灵石，1为小灵石
end

SCCrossHusongShuijingGatherInfo = SCCrossHusongShuijingGatherInfo or BaseClass(BaseProtocolStruct)
function SCCrossHusongShuijingGatherInfo:__init()
	self.msg_type = 8981
end
function SCCrossHusongShuijingGatherInfo:Decode()
	self.type = MsgAdapter.ReadShort()
	self.cur_remain_gather_time_big = MsgAdapter.ReadShort()
	self.next_refresh_time_big = MsgAdapter.ReadUInt()
end

-----生肖星图 --生肖信息------
SCZodiacInfo = SCZodiacInfo or BaseClass(BaseProtocolStruct)
function SCZodiacInfo:__init()
	self.msg_type = 8972
end

function SCZodiacInfo:Decode()
	self.zodiac_item = {}
	for i = 1 , GameEnum.ZODIAC_MAX_NUM do 
		self.zodiac_item[i] = {}
		self.zodiac_item[i].level = MsgAdapter.ReadShort()				-- 等级
		self.zodiac_item[i].activate_flag = MsgAdapter.ReadChar()		-- 碎片激活开启标志
		MsgAdapter.ReadChar()
	end
	-- PrintTable(self.zodiac_item)
end

-----生肖星图 --背包信息------
SCZodiacBackpackInfo = SCZodiacBackpackInfo or BaseClass(BaseProtocolStruct)
function SCZodiacBackpackInfo:__init()
	self.msg_type = 8973
end

function SCZodiacBackpackInfo:Decode()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	self.grid_num = MsgAdapter.ReadShort()
	self.grid_list = {}
	for i = 1 , self.grid_num do 
		self.grid_list[i] = {}
		self.grid_list[i].item_id = MsgAdapter.ReadUShort()	
		self.grid_list[i].zodiac_index = MsgAdapter.ReadShort() 
		self.grid_list[i].suipian_index = MsgAdapter.ReadShort()
		MsgAdapter.ReadShort()			
	end
end

-----生肖星图 --请求信息------
CSZodiacReq = CSZodiacReq or BaseClass(BaseProtocolStruct)
function CSZodiacReq:__init()
	self.msg_type = 8974
	self.req_type = 0
	self.param1 = 0
	self.param2 = 0
end

function CSZodiacReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.req_type)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
end

-----生肖星图 --分解信息------
CSZodiacDecomposeReq = CSZodiacDecomposeReq or BaseClass(BaseProtocolStruct)
function CSZodiacDecomposeReq:__init()
	self.msg_type = 8975
	self.decompose_num = 0
	self.decompose_backpack_index_list = {}
end

function CSZodiacDecomposeReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.decompose_num)
	for i = 1, 200 do 													-- 服务器说这里给他固定发200次
		local index = self.decompose_backpack_index_list[i] or 0
		MsgAdapter.WriteInt(index)
	end
end

SCZodiacBaseInfo = SCZodiacBaseInfo or BaseClass(BaseProtocolStruct)
function SCZodiacBaseInfo:__init()
	self.msg_type = 8976
end

function SCZodiacBaseInfo:Decode()
	self.jinghua_num = MsgAdapter.ReadInt()
end

