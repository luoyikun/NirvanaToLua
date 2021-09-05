-- 完成并掉落
CSFbGuideFinish = CSFbGuideFinish or BaseClass(BaseProtocolStruct)
function CSFbGuideFinish:__init()
	self.msg_type = 8400
end

function CSFbGuideFinish:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.pos_x)
	MsgAdapter.WriteInt(self.pos_y)
	MsgAdapter.WriteInt(0)
end

-- 创建采集物
CSFbGuideCreateGather = CSFbGuideCreateGather or BaseClass(BaseProtocolStruct)
function CSFbGuideCreateGather:__init()
	self.msg_type = 8401
end

function CSFbGuideCreateGather:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.pos_x)
	MsgAdapter.WriteInt(self.pos_y)
	MsgAdapter.WriteInt(self.gather_id)
	MsgAdapter.WriteInt(self.gather_time)
end

-- 我们结婚吧
SCRAMarryMeAllInfo = SCRAMarryMeAllInfo or BaseClass(BaseProtocolStruct)

function SCRAMarryMeAllInfo:__init()
	self.msg_type = 8416
end

function SCRAMarryMeAllInfo:Decode()
	self.cur_couple_count = MsgAdapter.ReadInt()
	self.couple_list = {}
	local count = math.min(self.cur_couple_count, GameEnum.RA_MARRY_SHOW_COUPLE_COUNT_MAX)
	for i = 1, count do
		self.couple_list[i] = {}
		self.couple_list[i].propose_id = MsgAdapter.ReadInt()						-- 求婚者id
		self.couple_list[i].propose_name = MsgAdapter.ReadStrN(32)					-- 求婚者名字
		self.couple_list[i].accept_proposal_id = MsgAdapter.ReadInt()				-- 被求婚者id
		self.couple_list[i].accept_proposal_name = MsgAdapter.ReadStrN(32)			-- 被求婚者名字
		self.couple_list[i].proposer_sex = MsgAdapter.ReadChar()					-- 求婚者性别
		self.couple_list[i].accept_proposal_sex = MsgAdapter.ReadChar()				-- 被求婚者性别
		self.couple_list[i].reserve_sh = MsgAdapter.ReadShort()
	end
end

SCOpenServerInvestInfo = SCOpenServerInvestInfo or BaseClass(BaseProtocolStruct)

function SCOpenServerInvestInfo:__init()
	self.msg_type = 8417
end

function SCOpenServerInvestInfo:Decode()
	self.reward_flag = MsgAdapter.ReadInt()
	self.time_limit = {}
	self.finish_param = {}
	for i = 1, 3 do
		self.time_limit[i] = MsgAdapter.ReadUInt()
	end
	for i = 1, 3 do
		self.finish_param[i] = MsgAdapter.ReadChar()
	end
	self.reserve_ch = MsgAdapter.ReadChar()
end

-- 开服红包
SCRARedEnvelopeGiftInfo = SCRARedEnvelopeGiftInfo or BaseClass(BaseProtocolStruct)
function SCRARedEnvelopeGiftInfo:__init()
	self.msg_type = 8410

	self.consume_gold_num = 0
	self.reward_flag = 0
end

function SCRARedEnvelopeGiftInfo:Decode()
	self.consume_gold_num_list = {}
	for i = 1 , 7 do
		self.consume_gold_num_list[i] = MsgAdapter.ReadInt()
	end
	self.reward_flag = MsgAdapter.ReadInt()
end

SCRAOfflineSingleChargeInfo0 = SCRAOfflineSingleChargeInfo0 or BaseClass(BaseProtocolStruct)
function SCRAOfflineSingleChargeInfo0:__init()
	self.msg_type = 8488
	self.reward_times = {}
	self.act_id = 0
	self.charge_max_value = 0
end

function SCRAOfflineSingleChargeInfo0:Decode()
	self.act_id = MsgAdapter.ReadInt()
	self.charge_max_value = MsgAdapter.ReadInt()
	for i = 1, 10 do
		self.reward_times[i] = MsgAdapter.ReadInt()
	end
end


-- 开服七天充值18元档次
CSChongZhi7DayFetchReward = CSChongZhi7DayFetchReward or BaseClass(BaseProtocolStruct)
function CSChongZhi7DayFetchReward:__init()
	self.msg_type = 8420
end

function CSChongZhi7DayFetchReward:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 神格操作请求
CSShengeSystemReq = CSShengeSystemReq or BaseClass(BaseProtocolStruct)
function CSShengeSystemReq:__init()
	self.msg_type = 8421
	self.info_type = 0
	self.param1 = 0
	self.param2 = 0
	self.param3 = 0
	self.param4 = 0

	self.count = 0
	self.virtual_inde_list = {}
	self.select_slot_list = {}
end

function CSShengeSystemReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.info_type)
	MsgAdapter.WriteShort(self.param1)
	MsgAdapter.WriteShort(self.param2)
	MsgAdapter.WriteShort(self.param3)
	MsgAdapter.WriteUInt(self.param4)

	MsgAdapter.WriteInt(self.count)
	for i = 1, self.count do
		MsgAdapter.WriteInt(self.virtual_inde_list[i])
	end
end

-- 神格信息
SCShengeSystemBagInfo = SCShengeSystemBagInfo or BaseClass(BaseProtocolStruct)
function SCShengeSystemBagInfo:__init()
	self.msg_type = 8422
end

function SCShengeSystemBagInfo:Decode()
	self.info_type = MsgAdapter.ReadChar()
	self.param1 = MsgAdapter.ReadChar()
	self.count = MsgAdapter.ReadShort()
	self.param3 = MsgAdapter.ReadUInt()

	self.bag_list = {}
	for i = 0, self.count - 1 do
		local vo = {}
		vo.quality = MsgAdapter.ReadChar()
		vo.type = MsgAdapter.ReadChar()
		vo.level = MsgAdapter.ReadUChar()
		vo.index = MsgAdapter.ReadUChar()
		self.bag_list[i] = vo
	end
end

--神格掌控
SCShengeZhangkongInfo = SCShengeZhangkongInfo or BaseClass(BaseProtocolStruct)
function SCShengeZhangkongInfo:__init()
	self.msg_type = 8423
end

function SCShengeZhangkongInfo:Decode()
	self.zhangkong_list = {}
	for i = 0, 3 do
		local zk = {}
		zk.level =  MsgAdapter.ReadInt()
		zk.exp = MsgAdapter.ReadInt()
		self.zhangkong_list[i] = zk
	end
end

SCZhangkongSingleChange = SCZhangkongSingleChange or BaseClass(BaseProtocolStruct)
function SCZhangkongSingleChange:__init()
	self.msg_type = 8424
end

function SCZhangkongSingleChange:Decode()
	self.grid = MsgAdapter.ReadInt()
	self.level = MsgAdapter.ReadInt()
	self.exp = MsgAdapter.ReadInt()
	self.add_exp = MsgAdapter.ReadInt()
end

--元宝转盘
CSYuanBaoZhuanpanInFo = CSYuanBaoZhuanpanInFo or BaseClass(BaseProtocolStruct)
function CSYuanBaoZhuanpanInFo:__init()
	self.msg_type = 8425
end

function CSYuanBaoZhuanpanInFo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.operate_type)
end

--元宝转盘奖品信息
SCYuanBaoZhuanpanSenditem = SCYuanBaoZhuanpanSenditem or BaseClass(BaseProtocolStruct)
function SCYuanBaoZhuanpanSenditem:__init()
	self.msg_type = 8426
end

function SCYuanBaoZhuanpanSenditem:Decode()
	self.index = MsgAdapter.ReadInt() 			--奖励索引
end

--元宝奖池砖石数
SCYuanBaoZhuanPanInfo = SCYuanBaoZhuanPanInfo or BaseClass(BaseProtocolStruct)
function SCYuanBaoZhuanPanInfo:__init()
	self.msg_type = 8427
end

function SCYuanBaoZhuanPanInfo:Decode()
	self.zhuanshinum = MsgAdapter.ReadLL() 		--奖池砖石数刷新时CS发协议
	self.chou_jiang_times = MsgAdapter.ReadInt()
end

-- 金猪召唤请求协议
CSGoldenPigOperateReq = CSGoldenPigOperateReq or BaseClass(BaseProtocolStruct)
function CSGoldenPigOperateReq:__init()
	self.msg_type = 8428
	self.operate_type = 0
	self.param = 0
end

function CSGoldenPigOperateReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.operate_type)
	MsgAdapter.WriteShort(self.param)
end


--极限挑战任务
SCRAExtremeChallengeTaskInfo = SCRAExtremeChallengeTaskInfo or BaseClass(BaseProtocolStruct)
function SCRAExtremeChallengeTaskInfo:__init()
	self.msg_type = 8489
end

function SCRAExtremeChallengeTaskInfo:Decode()
	self.task_list = {}
	for i = 1, GameEnum.RA_EXREME_CHALLENGE_PERSON_TASK_MAX_NUM do
		local info = {}
		info.task_id = MsgAdapter.ReadChar()
		info.task_type = MsgAdapter.ReadChar()
		info.is_finish = MsgAdapter.ReadChar()
		info.is_already_fetch = MsgAdapter.ReadChar()
		info.task_plan = MsgAdapter.ReadUInt()
		self.task_list[i] = info
	end
	self.is_have_fetch_ultimate_reward = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
end


-- 吉祥三宝
CSRATotalChargeFiveInfo  = CSRATotalChargeFiveInfo  or BaseClass(BaseProtocolStruct)
function CSRATotalChargeFiveInfo:__init()
	self.msg_type = 8497
end

function CSRATotalChargeFiveInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

SCRATotalChargeFiveInfo   = SCRATotalChargeFiveInfo   or BaseClass(BaseProtocolStruct)
function SCRATotalChargeFiveInfo:__init()
	self.msg_type = 8491

	self.cur_total_charge = 0
	self.cur_total_charge_has_fetch_flag = 0
end

function SCRATotalChargeFiveInfo:Decode()
	self.cur_total_charge = MsgAdapter.ReadInt()  --累计充值数
	self.cur_total_charge_has_fetch_flag = MsgAdapter.ReadInt()  --已领取过的奖励标记
end

--金猪召唤积分信息
SCGoldenPigOperateInfo = SCGoldenPigOperateInfo or BaseClass(BaseProtocolStruct)
function SCGoldenPigOperateInfo:__init()
	self.msg_type = 8429
end

function SCGoldenPigOperateInfo:Decode()
	self.summon_credit = MsgAdapter.ReadInt()		--召唤积分
	self.current_chongzhi = MsgAdapter.ReadInt()	--当前充值
end

--金猪召唤boss状态
SCGoldenPigBossState = SCGoldenPigBossState or BaseClass(BaseProtocolStruct)
function SCGoldenPigBossState:__init()
	self.msg_type = 8435
end

function SCGoldenPigBossState:Decode()					--boss状态 0不存在,1存在
	self.boss_state = {}
	for i = 1, GameEnum.GOLDEN_PIG_SUMMON_TYPE_MAX do
		self.boss_state[i] = MsgAdapter.ReadChar()
	end
	self.reserve_ch = MsgAdapter.ReadChar()
end

SCTuituFbFetchResultInfo = SCTuituFbFetchResultInfo or BaseClass(BaseProtocolStruct)
function SCTuituFbFetchResultInfo:__init()
	self.msg_type = 8434
end

function SCTuituFbFetchResultInfo:Decode()
	self.is_success = MsgAdapter.ReadShort()
	self.fb_type = MsgAdapter.ReadShort()
	self.chapter = MsgAdapter.ReadShort()
	self.seq = MsgAdapter.ReadShort()
end

-- 神格神躯信息
SCShengeShenquAllInfo = SCShengeShenquAllInfo or BaseClass(BaseProtocolStruct)
function SCShengeShenquAllInfo:__init()
	self.msg_type = 8440
end

function SCShengeShenquAllInfo:Decode()
	self.shenqu_list = {}
	for i = 0, GameEnum.SHENGE_SYSTEM_SHENGESHENQU_MAX_NUM - 1 do
		local shenqu_attr = {}
		for j = 1, GameEnum.SHENGE_SYSTEM_SHENGESHENQU_ATTR_MAX_NUM do
			local attr_info = {}
			for p = 1, GameEnum.SHENGE_SYSTEM_SHENGESHENQU_XILIAN_SLOT_MAX_NUM do
				local vo = {}
				vo.qianghua_times = MsgAdapter.ReadShort()
				vo.attr_point = MsgAdapter.ReadShort()
				vo.attr_value = MsgAdapter.ReadInt()
				attr_info[p] = vo
			end
			shenqu_attr[j] = attr_info
		end
		self.shenqu_list[i] = shenqu_attr
	end
	self.shenqu_history_max_cap = {}
	for i = 0, GameEnum.SHENGE_SYSTEM_SHENGESHENQU_MAX_NUM - 1 do
		self.shenqu_history_max_cap[i] = MsgAdapter.ReadInt()
	end
end

-- 单个神格神躯信息
SCShengeShenquInfo = SCShengeShenquInfo or BaseClass(BaseProtocolStruct)
function SCShengeShenquInfo:__init()
	self.msg_type = 8441
end

function SCShengeShenquInfo:Decode()
	self.shenqu_id = MsgAdapter.ReadInt()
	self.shenqu_attr = {}
	for j = 1, GameEnum.SHENGE_SYSTEM_SHENGESHENQU_ATTR_MAX_NUM do
		local attr_info = {}
		for p = 1, GameEnum.SHENGE_SYSTEM_SHENGESHENQU_XILIAN_SLOT_MAX_NUM do
			local vo = {}
			vo.qianghua_times = MsgAdapter.ReadShort()
			vo.attr_point = MsgAdapter.ReadShort()
			vo.attr_value = MsgAdapter.ReadInt()
			attr_info[p] = vo
		end
		self.shenqu_attr[j] = attr_info
	end
	self.shenqu_history_max_cap = MsgAdapter.ReadInt()
end

SCRuneSystemZhulingNotifyInfo = SCRuneSystemZhulingNotifyInfo or BaseClass(BaseProtocolStruct)
function SCRuneSystemZhulingNotifyInfo:__init()
	self.msg_type = 8442
end

function SCRuneSystemZhulingNotifyInfo:Decode()
	self.index = MsgAdapter.ReadInt()
	self.zhuling_slot_bless = MsgAdapter.ReadInt()
end

SCRuneSystemZhulingAllInfo = SCRuneSystemZhulingAllInfo or BaseClass(BaseProtocolStruct)
function SCRuneSystemZhulingAllInfo:__init()
	self.msg_type = 8443
end

function SCRuneSystemZhulingAllInfo:Decode()
	self.zhuling_slot_bless = MsgAdapter.ReadInt()
	self.run_zhuling_list = {}
	for i = 1, GameEnum.RUNE_SYSTEM_SLOT_MAX_NUM do
		self.run_zhuling_list[i] = {}
		self.run_zhuling_list[i].grade = MsgAdapter.ReadInt()
		self.run_zhuling_list[i].zhuling_bless = MsgAdapter.ReadInt()
	end
end

SCPastureSpiritImprintScoreInfo = SCPastureSpiritImprintScoreInfo or BaseClass(BaseProtocolStruct)
function SCPastureSpiritImprintScoreInfo:__init()
	self.msg_type = 8444
end

function SCPastureSpiritImprintScoreInfo:Decode()
	self.type =  MsgAdapter.ReadInt()         -- 0是增加兑换积分, 1是增加抽奖积分
	self.add_score =  MsgAdapter.ReadInt()
	self.score = MsgAdapter.ReadInt()		  --可用印记币积分
	self.chouhun_score = MsgAdapter.ReadInt()		--神印招印积分
end

-- 神印信息
SCPastureSpiritImprintBagInfo = SCPastureSpiritImprintBagInfo or BaseClass(BaseProtocolStruct)
function SCPastureSpiritImprintBagInfo:__init()
	self.msg_type = 8445
end

function SCPastureSpiritImprintBagInfo:Decode()
	self.type = MsgAdapter.ReadChar()	-- type 0 为背包索引  type 1 为印位
	local count = MsgAdapter.ReadChar()
	self.imprint_grade = MsgAdapter.ReadShort()

	self.grid_list = {}
	local item = {}
	for i = 1, count do
		item = {}
		item.param1 = MsgAdapter.ReadInt() -- type 0 为背包索引  type 1 为印位
		item.v_item_id = MsgAdapter.ReadShort()
		item.item_num = MsgAdapter.ReadShort()
		item.is_bind = MsgAdapter.ReadShort()
		item.level = MsgAdapter.ReadShort()
		item.grade = MsgAdapter.ReadInt()

		item.attr_param = {value_list = {}, type_list = {}}
		for i = 1, GameEnum.PASTURE_SPIRIT_MAX_IMPRINT_ATTR_COUNT do
			item.attr_param.value_list[i] = MsgAdapter.ReadInt()
		end
		for i = 1, GameEnum.PASTURE_SPIRIT_MAX_IMPRINT_ATTR_COUNT do
			item.attr_param.type_list[i] = MsgAdapter.ReadInt()
		end

		item.new_attr_param = {value_list = {}, type_list = {}}
		for i = 1, GameEnum.PASTURE_SPIRIT_MAX_IMPRINT_ATTR_COUNT do
			item.new_attr_param.value_list[i] = MsgAdapter.ReadInt()
		end
		for i = 1, GameEnum.PASTURE_SPIRIT_MAX_IMPRINT_ATTR_COUNT do
			item.new_attr_param.type_list[i] = MsgAdapter.ReadInt()
		end
		self.grid_list[i] = item
	end
end

SCPastureSpiritImprintShopInfo = SCPastureSpiritImprintShopInfo or BaseClass(BaseProtocolStruct)
function SCPastureSpiritImprintShopInfo:__init()
	self.msg_type = 8446
end

function SCPastureSpiritImprintShopInfo:Decode()
	local count = MsgAdapter.ReadInt()
	self.shop_list = {}
	for i = 1, count do
		local item = {}
		item.index = MsgAdapter.ReadChar()
		item.buy_count = MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()
		item.timestamp = MsgAdapter.ReadUInt()		--兑换次数完的时间
		self.shop_list[i] = item
	end
end

SCShenYinLieMingBagInfo = SCShenYinLieMingBagInfo or BaseClass(BaseProtocolStruct)
function SCShenYinLieMingBagInfo:__init()
	self.msg_type = 8447
end

function SCShenYinLieMingBagInfo:Decode()
	self.liehun_color = MsgAdapter.ReadInt()
	self.liehun_pool = {}
	for i = 1, GameEnum.SHEN_YIN_LIEHUN_POOL_MAX_COUNT do
		self.liehun_pool[i] = MsgAdapter.ReadShort()	--猎魂物品的index
	end
end

--元素之心操作请求
CSElementHeartReq = CSElementHeartReq or BaseClass(BaseProtocolStruct)
function CSElementHeartReq:__init()
	self.msg_type = 8454
	self.info_type = 0
	self.param1 = 0
	self.param2 = 0
	self.param3 = 0
	self.param4 = 0
end

function CSElementHeartReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.info_type)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
	MsgAdapter.WriteInt(self.param3)
	MsgAdapter.WriteInt(self.param4)
end

--元素之心信息
SCElementHeartInfo = SCElementHeartInfo or BaseClass(BaseProtocolStruct)
function SCElementHeartInfo:__init()
	self.msg_type = 8455
end

function SCElementHeartInfo:Decode()
	self.pasture_score = MsgAdapter.ReadInt()
	self.info_type = MsgAdapter.ReadChar()
	self.free_chou_times = MsgAdapter.ReadChar()
	local count = MsgAdapter.ReadShort()
	self.element_list = {}
	for i = 1, count do
		local vo = {}
		vo.grade = MsgAdapter.ReadChar()							--阶级
		vo.wuxing_type = MsgAdapter.ReadChar()						--五行类型
		vo.id = MsgAdapter.ReadChar()
		vo.tartget_wuxing_type = MsgAdapter.ReadChar()				--即将转换的五行类型
		vo.wuxing_bless = MsgAdapter.ReadInt()						--五行祝福值
		vo.element_level = SymbolData.Instance:GetElementHeartLevel(vo.wuxing_bless)
		vo.bless = MsgAdapter.ReadInt()								--祝福值
		vo.next_product_timestamp = MsgAdapter.ReadUInt()			--下次产出时间
		vo.wuxing_food_feed_times_list = {}							--记录每个食物喂养次数
		for i = 1, GameEnum.ELEMENT_HEART_WUXING_TYPE_MAX do
			vo.wuxing_food_feed_times_list = MsgAdapter.ReadInt()
		end
		vo.equip_param = {}
		vo.equip_param.real_level = MsgAdapter.ReadShort()
		vo.equip_param.slot_flag = MsgAdapter.ReadShort()					--当前已激活的物品标记
		vo.equip_param.upgrade_progress = MsgAdapter.ReadShort()			--升级进度
		MsgAdapter.ReadShort()
		self.element_list[vo.id] = vo
	end
end

--商店信息
SCElementShopInfo = SCElementShopInfo or BaseClass(BaseProtocolStruct)
function SCElementShopInfo:__init()
	self.msg_type = 8460
end

function SCElementShopInfo:Decode()
	self.next_refresh_timestamp = MsgAdapter.ReadUInt()
	MsgAdapter.ReadShort()
	self.today_shop_flush_times = MsgAdapter.ReadShort() 		--当天商店刷新次数
	self.shop_item_list = {}
	for i = 0, GameEnum.ELEMENT_SHOP_ITEM_COUNT - 1 do
		local vo = {}
		vo.index = i
		vo.shop_seq = MsgAdapter.ReadShort()				 -- 商店配置seq
		vo.need_gold_buy = MsgAdapter.ReadChar()			 -- 是否需要元宝购买
		vo.has_buy = MsgAdapter.ReadChar()					 -- 是否已经购买过
		self.shop_item_list[i] = vo
	end
end

--元素之纹列表信息
SCElementTextureInfo = SCElementTextureInfo or BaseClass(BaseProtocolStruct)
function SCElementTextureInfo:__init()
	self.msg_type = 8456
end

function SCElementTextureInfo:Decode()
	self.charm_list = {}
	for i = 0, EquipmentShenData.SHEN_EQUIP_NUM - 1 do
		local vo = {}
		vo.wuxing_type = MsgAdapter.ReadChar()
		vo.grade = MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()
		vo.exp = MsgAdapter.ReadInt()
		self.charm_list[i] = vo
	end
end

--单个元素之纹信息
SCCharmGhostSingleCharmInfo = SCCharmGhostSingleCharmInfo or BaseClass(BaseProtocolStruct)
function SCCharmGhostSingleCharmInfo:__init()
	self.msg_type = 8457
end

function SCCharmGhostSingleCharmInfo:Decode()
	self.index = MsgAdapter.ReadInt()
	local vo = {}
	vo.wuxing_type = MsgAdapter.ReadChar()
	vo.grade = MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
	vo.exp = MsgAdapter.ReadInt()
	self.charm = vo
end

--抽奖奖品
SCElementHeartChouRewardListInfo = SCElementHeartChouRewardListInfo or BaseClass(BaseProtocolStruct)
function SCElementHeartChouRewardListInfo:__init()
	self.msg_type = 8458
end

function SCElementHeartChouRewardListInfo:Decode()
	self.free_chou_times = MsgAdapter.ReadShort()
	local count = MsgAdapter.ReadShort()
	self.reward_list = {}
	for i = 1, count do
		local vo = {}
		vo.item_id = MsgAdapter.ReadUShort()
		vo.num = MsgAdapter.ReadChar()
		vo.is_bind = MsgAdapter.ReadChar()
		self.reward_list[i] = vo
	end
end

--产出列表
SCElementProductListInfo = SCElementProductListInfo or BaseClass(BaseProtocolStruct)
function SCElementProductListInfo:__init()
	self.msg_type = 8459
end

function SCElementProductListInfo:Decode()
	self.info_type = MsgAdapter.ReadShort()
	local count = MsgAdapter.ReadShort()
	self.product_list = {}
	for i = 0, count - 1 do
		self.product_list[i] = MsgAdapter.ReadUShort()
	end
end

--元素洗练单个信息
SCElementXiLianSingleInfo = SCElementXiLianSingleInfo or BaseClass(BaseProtocolStruct)
function SCElementXiLianSingleInfo:__init()
	self.msg_type = 8461
end

function SCElementXiLianSingleInfo:Decode()
	self.element_id = MsgAdapter.ReadInt()
	self.element_xl_info = {}
	self.element_xl_info.open_slot_flag = bit:d2b(MsgAdapter.ReadInt())
	self.element_xl_info.slot_list = {}
	for i = 1, GameEnum.ELEMENT_HEART_MAX_XILIAN_SLOT do
		local vo = {}
		vo.xilian_val = MsgAdapter.ReadInt()
		vo.element_attr_type = MsgAdapter.ReadChar()
		vo.open_slot = self.element_xl_info.open_slot_flag[33 - i]
		MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()
		self.element_xl_info.slot_list[i] = vo
	end
end


--元素洗练信息
SCElementXiLianAllInfo = SCElementXiLianAllInfo or BaseClass(BaseProtocolStruct)
function SCElementXiLianAllInfo:__init()
	self.msg_type = 8462
end

function SCElementXiLianAllInfo:Decode()
	self.xilian_list_info = {}
	for id = 0, GameEnum.ELEMENT_HEART_MAX_COUNT - 1 do
		local element_xl_info = {}
		element_xl_info.open_slot_flag = bit:d2b(MsgAdapter.ReadInt())
		element_xl_info.slot_list = {}
		for i = 1, GameEnum.ELEMENT_HEART_MAX_XILIAN_SLOT do
			local vo = {}
			vo.xilian_val = MsgAdapter.ReadInt()
			vo.element_attr_type = MsgAdapter.ReadChar()
			vo.open_slot = element_xl_info.open_slot_flag[33 - i]
			MsgAdapter.ReadChar()
			MsgAdapter.ReadShort()
			element_xl_info.slot_list[i] = vo
		end
		self.xilian_list_info[id] = element_xl_info
	end
end

--消费好礼
SCRAConsumGift = SCRAConsumGift or BaseClass(BaseProtocolStruct)
function SCRAConsumGift:__init()
	self.msg_type = 8467

	self.consum_gold = 0
	self.left_roll_times = 0
	self.reward_fetch_flag = 0
end

function SCRAConsumGift:Decode()
	self.consum_gold = MsgAdapter.ReadInt()
	self.act_theme = MsgAdapter.ReadShort()
	self.left_roll_times = MsgAdapter.ReadShort()
	self.reward_fetch_flag = MsgAdapter.ReadUInt()
end

SCRAConsumGiftRollReward = SCRAConsumGiftRollReward or BaseClass(BaseProtocolStruct)
function SCRAConsumGiftRollReward:__init()
	self.msg_type = 8469

	self.seq = 0
	self.decade = 0
	self.units_digit = 0
end

function SCRAConsumGiftRollReward:Decode()
	self.seq = MsgAdapter.ReadChar()
	self.decade = MsgAdapter.ReadChar()
	self.units_digit = MsgAdapter.ReadChar()
end

--暴击日
SCRACriticalStrikeInfo = SCRACriticalStrikeInfo or BaseClass(BaseProtocolStruct)
function SCRACriticalStrikeInfo:__init()
	self.msg_type = 8468
	self.act_type = 0
end

function SCRACriticalStrikeInfo:Decode()
	self.act_type = MsgAdapter.ReadInt()
end

--聚宝盆
SCRACollectTreasureInfo = SCRACollectTreasureInfo or BaseClass(BaseProtocolStruct)
function SCRACollectTreasureInfo:__init()
	self.msg_type = 8471
	self.left_roll_times = 0
	self.record_num = 0
	self.join_record_list = {}
end

function SCRACollectTreasureInfo:Decode()
	self.join_record_list = {}
	self.left_roll_times = MsgAdapter.ReadShort()
	self.record_num = MsgAdapter.ReadShort()
	self.had_join_times = MsgAdapter.ReadShort()
	self.res_sh = MsgAdapter.ReadShort()
	for i = 1, self.record_num do
		local data = {}
		data.uid = MsgAdapter.ReadInt()
		data.name = MsgAdapter.ReadStrN(32)
		data.roll_mul = MsgAdapter.ReadInt()
		table.insert(self.join_record_list, data)
	end
end

--摇奖结果下发
SCRACollectTreasureResult = SCRACollectTreasureResult or BaseClass(BaseProtocolStruct)
function SCRACollectTreasureResult:__init()
	self.msg_type = 8472
	self.seq = 0
end

function SCRACollectTreasureResult:Decode()
	self.seq = MsgAdapter.ReadInt()
end


--限时反馈活动
SCRALimitTimeRebateInfo = SCRALimitTimeRebateInfo or BaseClass(BaseProtocolStruct)
function SCRALimitTimeRebateInfo:__init()
	self.msg_type = 8475
	self.cur_day_chongzhi = 0
	self.chongzhi_days = 0
	self.reward_flag = 0
	self.chongzhi_day_list = {}
end

function SCRALimitTimeRebateInfo:Decode()
	self.cur_day_chongzhi = MsgAdapter.ReadInt()
	self.chongzhi_days = MsgAdapter.ReadInt()
	self.reward_flag = MsgAdapter.ReadInt()
	for i=1,9 do
		self.chongzhi_day_list[i] = MsgAdapter.ReadInt()
	end
end


----------------------------------限时礼包活动------------------------------------------
SCRATimeLimitGiftInfo = SCRATimeLimitGiftInfo or BaseClass(BaseProtocolStruct)
function SCRATimeLimitGiftInfo:__init()
	self.msg_type = 8476
	self.reward_can_fetch_flag1 = 0
	self.reward_fetch_flag1 = 0
	self.reward_can_fetch_flag2 = 0
	self.reward_fetch_flag2 = 0
	self.open_flag = 0
	self.join_vip_level = 0
	self.begin_timestamp = 0
	self.reward_can_fetch_flag3 = 0
	self.reward_fetch_flag3 = 0
end

function SCRATimeLimitGiftInfo:Decode()
	self.reward_can_fetch_flag1 = MsgAdapter.ReadInt()					--第一档 能领取:不能领取  非1:0
	self.reward_fetch_flag1 = MsgAdapter.ReadInt()						--第一档 已领取:未领取  非1:0
	self.reward_can_fetch_flag2 = MsgAdapter.ReadInt()					--第二档 能领取:不能领取  非1:0
	self.reward_fetch_flag2 = MsgAdapter.ReadInt()						--第二档 已领取:未领取  非1:0
	self.join_vip_level = MsgAdapter.ReadShort()						--参与时vip等级
	self.open_flag = MsgAdapter.ReadShort()								--是否面板显示标志
	self.begin_timestamp = MsgAdapter.ReadInt()							--角色进入活动的时间
	self.reward_can_fetch_flag3 = MsgAdapter.ReadInt()					--第三档 能领取:不能领取  非1:0
	self.reward_fetch_flag3 = MsgAdapter.ReadInt()						--第三档 已领取:未领取  非1:0
end


------------------------植树---------------------
SCPlantingTreeRankInfo = SCPlantingTreeRankInfo or BaseClass(BaseProtocolStruct)
function SCPlantingTreeRankInfo:__init()
	self.msg_type = 8448

	self.rank_type = 0
	self.opera_times = 0
	self.rank_list_count = 0
	self.rank_list = {}
end

function SCPlantingTreeRankInfo:Decode()
	self.rank_type = MsgAdapter.ReadInt()
	self.opera_times = MsgAdapter.ReadInt()
	self.rank_list_count = MsgAdapter.ReadInt()
	self.rank_list = {}
	for i = 1, self.rank_list_count do
		local data = {}
		data.uid = MsgAdapter.ReadInt()
		data.role_name = MsgAdapter.ReadStrN(32)
		data.opera_times = MsgAdapter.ReadInt()
		data.prof = MsgAdapter.ReadChar()
		data.sex = MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()
		self.rank_list[i] = data
	end
end

SCPlantingTreeTreeInfo = SCPlantingTreeTreeInfo or BaseClass(BaseProtocolStruct)
function SCPlantingTreeTreeInfo:__init()
	self.msg_type = 8449

	self.owner_name = ""
	self.vanish_time = 0 		--消失时间
	self.watering_times = 0
end

function SCPlantingTreeTreeInfo:Decode()
	self.owner_name = MsgAdapter.ReadStrN(32)
	self.vanish_time = MsgAdapter.ReadUInt()
	self.watering_times = MsgAdapter.ReadInt()
end

SCPlantingTreeMiniMapInfo = SCPlantingTreeMiniMapInfo or BaseClass(BaseProtocolStruct)
function SCPlantingTreeMiniMapInfo:__init()
	self.msg_type = 8450
	self.tree_info_list = {}
end

function SCPlantingTreeMiniMapInfo:Decode()
	local count = MsgAdapter.ReadInt()

	for i = 1, count do
		local temp = {}
		temp.obj_id = MsgAdapter.ReadInt()
		temp.pos_x = MsgAdapter.ReadShort()
		temp.pos_y = MsgAdapter.ReadShort()
		
		self.tree_info_list[i] = temp
	end
end
---------------------------植树 End -----------------------------------


-- 循环充值2(送装备)
SCCirculationChongzhiInfo = SCCirculationChongzhiInfo or BaseClass(BaseProtocolStruct)
function SCCirculationChongzhiInfo:__init()
	self.msg_type = 8477

	self.total_chongzhi = 0 		-- 累计充值
	self.cur_chongzhi = 0 		-- 上次领奖到现在的充值
end

function SCCirculationChongzhiInfo:Decode()
	self.total_chongzhi = MsgAdapter.ReadUInt()
	self.cur_chongzhi = MsgAdapter.ReadUInt()
end

-- 疯狂摇钱树
SCRAShakeMoneyInfo = SCRAShakeMoneyInfo or BaseClass(BaseProtocolStruct)
function SCRAShakeMoneyInfo:__init()
	self.msg_type = 8478

	self.total_chongzhi_gold = 0
	self.chongzhi_gold = 0
end

function SCRAShakeMoneyInfo:Decode()
	self.total_chongzhi_gold = MsgAdapter.ReadInt()
	self.chongzhi_gold = MsgAdapter.ReadInt()
	self.seq = MsgAdapter.ReadInt()
end

-- 限时豪礼
SCRATimeLimitLuxuryGiftBagInfo = SCRATimeLimitLuxuryGiftBagInfo or BaseClass(BaseProtocolStruct)
function SCRATimeLimitLuxuryGiftBagInfo:__init()
	self.msg_type = 8479

	self.is_already_buy = 0
	self.join_vip_level = 0
	self.begin_timestamp = 0
	self.time_limit_luxury_gift_open_flag = 0
end

function SCRATimeLimitLuxuryGiftBagInfo:Decode()
	self.is_already_buy = MsgAdapter.ReadShort()
	self.join_vip_level = MsgAdapter.ReadShort()
	self.begin_timestamp = MsgAdapter.ReadInt()
    self.time_limit_luxury_gift_open_flag = MsgAdapter.ReadInt()
end

--随机活动 普天同庆
SCRAResetDoubleChongzhi = SCRAResetDoubleChongzhi or BaseClass(BaseProtocolStruct)
function SCRAResetDoubleChongzhi:__init()
	self.msg_type = 8480

	self.chongzhi_reward_flag = 0
	self.open_flag = 0
end

function SCRAResetDoubleChongzhi:Decode()
	self.chongzhi_reward_flag = MsgAdapter.ReadInt()
	self.open_flag = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
end

---连续充值
SCRAVersionContinueChongzhiInfo = SCRAVersionContinueChongzhiInfo or BaseClass(BaseProtocolStruct)

function SCRAVersionContinueChongzhiInfo:__init()
	self.msg_type = 8485

    self.today_chongzhi = 0           --今日充值数
    self.can_fetch_reward_flag = 0           -- 奖励激活标记
    self.has_fetch_reward_flag = 0           -- 奖励领取标记
    self.continue_chongzhi_days = 0           -- 连续充值天数
    self.reserve1 = 0
    self.reserve2 = 0
end

function SCRAVersionContinueChongzhiInfo:Decode()
	self.today_chongzhi = MsgAdapter.ReadUInt()           --今日充值数
    self.can_fetch_reward_flag = MsgAdapter.ReadShort()           -- 奖励激活标记
    self.has_fetch_reward_flag = MsgAdapter.ReadShort()           -- 奖励领取标记
    self.continue_chongzhi_days = MsgAdapter.ReadChar()           -- 连续充值天数
    self.reserve1 = MsgAdapter.ReadChar()
    self.reserve2 = MsgAdapter.ReadShort()
end

-- 狂返元宝
SCRaCrazyRebateChongInfo = SCRaCrazyRebateChongInfo or BaseClass(BaseProtocolStruct)
function SCRaCrazyRebateChongInfo:__init()
	self.msg_type = 8463
	self.chongzhi_count = 0
end

function SCRaCrazyRebateChongInfo:Decode()
	self.chongzhi_count = MsgAdapter.ReadInt()
end

-- 每日一爱主界面图标标志
SCLoveDailyInfo = SCLoveDailyInfo or BaseClass(BaseProtocolStruct)
function SCLoveDailyInfo:__init()
	self.msg_type = 8464
	self.flag = 0
end

function SCLoveDailyInfo:Decode()
	self.flag = MsgAdapter.ReadInt()
end

-- 神印回收
CSShenYinOneKeyRecyleReq = CSShenYinOneKeyRecyleReq or BaseClass(BaseProtocolStruct)
function CSShenYinOneKeyRecyleReq:__init()
	self.msg_type = 8465
	self.count = 0
	self.virtual_bag_list = {}
end

function CSShenYinOneKeyRecyleReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.count)

	for i = 1, 100 do
		-- MsgAdapter.WriteInt(self.virtual_bag_list[i].param1)
		-- MsgAdapter.WriteInt(self.virtual_bag_list[i].num)
		if self.virtual_bag_list[i] then
			MsgAdapter.WriteShort(self.virtual_bag_list[i])
		else
			MsgAdapter.WriteShort(-1)
		end
	end
end

-- 每日限购
SCRALimitBuyInfo = SCRALimitBuyInfo or BaseClass(BaseProtocolStruct)
function SCRALimitBuyInfo:__init()
	self.msg_type = 8470
	self.act_type = 0
end

function SCRALimitBuyInfo:Decode()
	self.act_type = MsgAdapter.ReadInt()
	self.had_buy_count = {}
	for i = 1, GameEnum.RAND_ACTIVITY_DAILY_LIMIT_BUY_MAX_SEQ do
		table.insert(self.had_buy_count, MsgAdapter.ReadChar())
	end
end

-- 欢乐累充
SCRAHappyCumulChongzhiInfo = SCRAHappyCumulChongzhiInfo or BaseClass(BaseProtocolStruct)    
function SCRAHappyCumulChongzhiInfo:__init()
  	self.msg_type = 8473
  	self.chongzhi_num = 0        -- 充值数量
    self.act_type = 0         -- 主题
    self.res_sh = 0
    self.fetch_reward_flag = 0 
end
  
function SCRAHappyCumulChongzhiInfo:Decode()
	self.chongzhi_num = MsgAdapter.ReadInt()        -- 充值数量
    self.act_type = MsgAdapter.ReadShort()         -- 主题
    self.res_sh = MsgAdapter.ReadShort()
    self.fetch_reward_flag = MsgAdapter.ReadUInt()
end

--------臻品城/神秘商店-----
SCRARmbBugChestShopInfo = SCRARmbBugChestShopInfo or BaseClass(BaseProtocolStruct)
function SCRARmbBugChestShopInfo:__init()
	self.msg_type = 8481
	self.buy_count_list = {}
end

function SCRARmbBugChestShopInfo:Decode()
	self.buy_count_list = {}
	for i = 1, 64 do
		self.buy_count_list[i] = MsgAdapter.ReadChar()
	end
end

--消费返利
SCRAConsumeGoldRewardInfo = SCRAConsumeGoldRewardInfo or BaseClass(BaseProtocolStruct)
function SCRAConsumeGoldRewardInfo:__init()
	self.msg_type = 8482

    self.consume_gold = 0
    self.fetch_reward_flag =0
    self.vip_level = 0
    self.activity_day = 0
end

function SCRAConsumeGoldRewardInfo:Decode()
    self.consume_gold = MsgAdapter.ReadInt()
    self.fetch_reward_flag = MsgAdapter.ReadChar()
    self.vip_level = MsgAdapter.ReadChar()
    self.activity_day = MsgAdapter.ReadShort()
end

-- 买一送一活动
SCBuyOneGetOneFreeInfo = SCBuyOneGetOneFreeInfo or BaseClass(BaseProtocolStruct)
function SCBuyOneGetOneFreeInfo:__init()
	self.msg_type = 8483
	self.buy_flag = 0
	self.free_reward_flag = 0
end

function SCBuyOneGetOneFreeInfo:Decode()
	self.buy_flag = MsgAdapter.ReadLL()
	self.free_reward_flag = MsgAdapter.ReadLL()
end

-- 版本累计充值
SCRAVersionTotalChargeInfo = SCRAVersionTotalChargeInfo or BaseClass(BaseProtocolStruct)
function SCRAVersionTotalChargeInfo:__init()
	self.msg_type = 8484

	self.total_charge_value = 0
	self.reward_has_fetch_flag = 0
end

function SCRAVersionTotalChargeInfo:Decode()
	self.total_charge_value = MsgAdapter.ReadInt()  --累计充值数
	self.reward_has_fetch_flag = MsgAdapter.ReadInt()  --已领取过的奖励标记
end

SCRAJinJieReturnInfo = SCRAJinJieReturnInfo or BaseClass(BaseProtocolStruct)
function SCRAJinJieReturnInfo:__init()
	self.msg_type = 8474
	self.act_type = 0
	self.fetch_reward_flag = {}
end

function SCRAJinJieReturnInfo:Decode()
	self.act_type = MsgAdapter.ReadInt()
	self.fetch_reward_flag = MsgAdapter.ReadUInt()
end

--中秋欢乐摇奖信息
SCRAHuanLeYaoJiangTwoInfo = SCRAHuanLeYaoJiangTwoInfo or BaseClass(BaseProtocolStruct)
function SCRAHuanLeYaoJiangTwoInfo:__init()
	self.msg_type = 8486
    self.ra_huanleyaojiang_next_free_tao_timestamp = 0
    self.chou_times = 0
    self.reward_flag = 0
end

function SCRAHuanLeYaoJiangTwoInfo:Decode()
	self.ra_huanleyaojiang_next_free_tao_timestamp = MsgAdapter.ReadUInt()
    self.chou_times = MsgAdapter.ReadInt()
    self.reward_flag = MsgAdapter.ReadInt()
end

-- 中秋欢乐摇奖结果信息
SCRAHuanLeYaoJiangTwoTaoResultInfo = SCRAHuanLeYaoJiangTwoTaoResultInfo or BaseClass(BaseProtocolStruct)
function SCRAHuanLeYaoJiangTwoTaoResultInfo:__init()
	self.msg_type = 8487
    self.count = 0
    self.huanleyaojiang_tao_seq = {}
end

function SCRAHuanLeYaoJiangTwoTaoResultInfo:Decode()

	self.count = MsgAdapter.ReadInt()
    self.huanleyaojiang_tao_seq = {}

    for i = 1, self.count do
		self.huanleyaojiang_tao_seq[i] = MsgAdapter.ReadShort()
    end
end
-- 单身伴侣 集月饼活动
SCCollectSecondExchangeInfo = SCCollectSecondExchangeInfo or BaseClass(BaseProtocolStruct)
function SCCollectSecondExchangeInfo:__init()

	self.msg_type = 8490
	self.collection_exchange_times = {}
end

function SCCollectSecondExchangeInfo:Decode()
	self.collection_exchange_times = {}
	for i = 1, GameEnum.RAND_ACTIVITY_ITEM_COLLECTION_SECOND_REWARD_MAX_COUNT do
		self.collection_exchange_times[i] = MsgAdapter.ReadInt()
	end
end

--你充我送
SCRAChongZhiGiftInfo = SCRAChongZhiGiftInfo or BaseClass(BaseProtocolStruct)
function SCRAChongZhiGiftInfo:__init()
 	self.msg_type = 8492

 	self.activity_day = 0
 	self.magic_shop_chongzhi_value = 0
 end 

 function SCRAChongZhiGiftInfo:Decode()
 	self.magic_shop_fetch_reward_flag = MsgAdapter.ReadChar()
 	MsgAdapter.ReadChar()
 	self.activity_day = MsgAdapter.ReadShort()
 	self.magic_shop_chongzhi_value = MsgAdapter.ReadUInt()
 end

 ---------------------合服投资-----------------
SCCSATouzijihuaInfo = SCCSATouzijihuaInfo or BaseClass(BaseProtocolStruct)
function SCCSATouzijihuaInfo:__init()
	self.msg_type = 8493
end

function SCCSATouzijihuaInfo:Decode()
	self.csa_touzijihua_buy_flag = MsgAdapter.ReadChar()
	self.csa_touzijihua_reserve_sh = MsgAdapter.ReadChar()
	self.csa_touzjihua_login_day = MsgAdapter.ReadUShort()
	self.csa_touzijihua_total_fetch_flag = MsgAdapter.ReadUInt()
end
---------------------合服投资end-----------------
---------------------合服基金-----------------
SCCSAFoundationInfo = SCCSAFoundationInfo or BaseClass(BaseProtocolStruct)
function SCCSAFoundationInfo:__init()
	self.msg_type = 8494
	self.reward_flag = {}
end

function SCCSAFoundationInfo:Decode()
	for i = 1, GameEnum.COMBINE_SERVER_MAX_FOUNDATION_TYPE do
		local temp = {}
		temp.buy_level = MsgAdapter.ReadShort()
		temp.reward_phase = MsgAdapter.ReadShort()
		self.reward_flag[i] = temp
	end
end

---------------------合服经验购买-----------------
SCCSAExpRefineInfo = SCCSAExpRefineInfo or BaseClass(BaseProtocolStruct)
function SCCSAExpRefineInfo:__init()
	self.msg_type = 8495
end

function SCCSAExpRefineInfo:Decode()
	self.had_buy = MsgAdapter.ReadChar()	--  是否购买过
	MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
end

--------------------进阶返还2--------------------------
SCRAJinJieReturnInfo2 = SCRAJinJieReturnInfo2 or BaseClass(BaseProtocolStruct)
function SCRAJinJieReturnInfo2:__init()
	self.msg_type = 8498
	self.act_type = 0
	self.fetch_reward_flag = {}
end

function SCRAJinJieReturnInfo2:Decode()
	self.act_type = MsgAdapter.ReadInt()
	self.fetch_reward_flag = MsgAdapter.ReadUInt()
end

--··················暴击日2·····························
SCRACriticalStrike2Info = SCRACriticalStrike2Info or BaseClass(BaseProtocolStruct)
function SCRACriticalStrike2Info:__init()
	self.msg_type = 8499
	self.act_type = 0
end

function SCRACriticalStrike2Info:Decode()
	self.act_type = MsgAdapter.ReadInt()
end