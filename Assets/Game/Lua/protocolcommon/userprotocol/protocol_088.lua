
----------------------夜战王城--------------------
SCNightFightAllRoleScoreInfo = SCNightFightAllRoleScoreInfo or BaseClass(BaseProtocolStruct)
function SCNightFightAllRoleScoreInfo:__init()
	self.msg_type = 8800
	self.role_count = 0
end

function SCNightFightAllRoleScoreInfo:Decode()
	self.score_info_list = {}
	self.role_count = MsgAdapter.ReadInt()
	for i = 1, self.role_count do
		self.score_info_list[MsgAdapter.ReadUShort()] = MsgAdapter.ReadShort()
	end
end

-- 夜战坐标信息
SCNightFightPlayerPosi = SCNightFightPlayerPosi or BaseClass(BaseProtocolStruct)
function SCNightFightPlayerPosi:__init()
	self.msg_type = 8801
	self.rank = 0
	self.obj_id = 0
	self.pos_x = 0
	self.pos_y = 0
end

function SCNightFightPlayerPosi:Decode()
	self.rank = MsgAdapter.ReadShort()
	self.obj_id = MsgAdapter.ReadUShort()
	self.pos_x = MsgAdapter.ReadInt()
	self.pos_y = MsgAdapter.ReadInt()
end

SCNightFightBossRankInfo = SCNightFightBossRankInfo or BaseClass(BaseProtocolStruct)
function SCNightFightBossRankInfo:__init()
	self.msg_type = 8802
	self.boss_left_hp_per = 0
	self.boss_rank_count = 0
	self.user_key = 0
	self.is_red_side = 0
	self.reserve_ch = 0
	self.reserve_sh = 0
	self.user_name = ""
	self.hurt_val = 0
end

function SCNightFightBossRankInfo:Decode()
	self.boss_left_hp_per = MsgAdapter.ReadInt()				 -- boss剩余血量万分比
	self.boss_rank_count = MsgAdapter.ReadInt()
	self.boss_rank_info_list = {}
	for i = 1, self.boss_rank_count do
		local data = {}
		data.user_key = MsgAdapter.ReadLL()
		data.is_red_side = MsgAdapter.ReadChar()				-- 阵营
		data.reserve_ch = MsgAdapter.ReadChar()
		data.reserve_sh = MsgAdapter.ReadShort()
		data.user_name = MsgAdapter.ReadStrN(32)
		data.hurt_per = MsgAdapter.ReadInt()					-- 玩家伤害万分比
		data.hurt_val = MsgAdapter.ReadLL()						-- 玩家伤害值
		self.boss_rank_info_list[i] = data
	end
end

SCNightFightTotalScoreRank = SCNightFightTotalScoreRank or BaseClass(BaseProtocolStruct)
function SCNightFightTotalScoreRank:__init()
	self.msg_type = 8803
	self.role_count = 0
end

function SCNightFightTotalScoreRank:Decode()
	self.score_info_list = {}
	self.role_count = MsgAdapter.ReadInt()
	for i = 1, self.role_count do
		local data = {}
		data.total_score = MsgAdapter.ReadInt()
		data.user_name = MsgAdapter.ReadStrN(32)
		data.user_key = MsgAdapter.ReadLL()
		self.score_info_list[i] = data
	end
end

--大小目标请求
CSRoleBigSmallGoalOper = CSRoleBigSmallGoalOper or BaseClass(BaseProtocolStruct)
function CSRoleBigSmallGoalOper:__init()
	self.msg_type = 8821
	self.opera_type = 0
	self.param1 = 0
	self.param2 = 0
end

function CSRoleBigSmallGoalOper:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opera_type)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
end

SCRoleBigSmallGoalInfo = SCRoleBigSmallGoalInfo or BaseClass(BaseProtocolStruct)
function SCRoleBigSmallGoalInfo:__init()
	self.msg_type = 8822
	self.system_type = 0
	self.open_system_timestamp = 0

end

function SCRoleBigSmallGoalInfo:Decode()
	self.system_type = MsgAdapter.ReadShort()
	MsgAdapter.ReadChar()
	self.active_special_attr_flag = MsgAdapter.ReadChar()
	self.open_system_timestamp = MsgAdapter.ReadUInt()
	self.active_flag = {}
	self.fetch_flag = {}
	for i = 0, 1 do
		self.active_flag[i] = MsgAdapter.ReadChar()
		self.fetch_flag[i] = MsgAdapter.ReadChar()
	end
end

--------------------夜战王城-------------------------

-- 小鬼守护请求
CSImpGuardOperaReq = CSImpGuardOperaReq or BaseClass(BaseProtocolStruct)
function CSImpGuardOperaReq:__init()
	self.msg_type = 8805
end

function CSImpGuardOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.opera_type)
	MsgAdapter.WriteShort(self.param1)
	MsgAdapter.WriteShort(self.param2)
end

-- 小鬼守护信息
SCImpGuardInfo = SCImpGuardInfo or BaseClass(BaseProtocolStruct)
function SCImpGuardInfo:__init()
	self.msg_type = 8806
end

function SCImpGuardInfo:Decode()
	self.imp_guard_list = {}
	for i = 1, ImpGuardData.IMP_GUARD_GRID_INDEX_MAX do
		self.imp_guard_list[i] = {}
		self.imp_guard_list[i].grid_index = MsgAdapter.ReadChar()
		self.imp_guard_list[i].used_imp_type = MsgAdapter.ReadChar()
		self.imp_guard_list[i].is_expire = MsgAdapter.ReadChar()	-- 是否过期。 1过期，0没有
		MsgAdapter.ReadChar()
		self.imp_guard_list[i].item_wrapper = ProtocolStruct.ReadItemDataWrapper()
	end
end

-- 小鬼守护外观变换通知范围内的玩家
SCRoleImpAppeChange = SCRoleImpAppeChange or BaseClass(BaseProtocolStruct)
function SCRoleImpAppeChange:__init()
	self.msg_type = 8807
end

function SCRoleImpAppeChange:Decode()
	self.objid = MsgAdapter.ReadUShort()
	self.appe_index = MsgAdapter.ReadShort()
	self.appe_image_id = MsgAdapter.ReadUShort()
end

-------------------------河神洛书-------------------------
CSHeShenLuoShuReq = CSHeShenLuoShuReq or BaseClass(BaseProtocolStruct)
function CSHeShenLuoShuReq:__init()
	self.msg_type = 8808
end

function CSHeShenLuoShuReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(self.param1)
	MsgAdapter.WriteShort(self.param2)
	MsgAdapter.WriteShort(self.param3)
end

--河神洛书全部信息
SCHeShenLuoShuAllInfo = SCHeShenLuoShuAllInfo or BaseClass(BaseProtocolStruct)
function SCHeShenLuoShuAllInfo:__init()
	self.msg_type = 8809
end

function SCHeShenLuoShuAllInfo:Decode()
	self.data = {}
	for type = 0, GameEnum.HESHENLUOSHU_MAX_TYPE - 1 do
		self.data[type] = {}
		for seq = 0, GameEnum.HESHENLUOSHU_MAX_SEQ - 1 do
			self.data[type][seq] = {}
			for index = 0, GameEnum.HESHENLUOSHU_MAX_INDEX - 1 do
				self.data[type][seq][index] = MsgAdapter.ReadShort()
			end
		end
	end
	self.upgrade_data = {}
	 for type = 0, GameEnum.HESHENLUOSHU_MAX_TYPE - 1 do
		self.upgrade_data[type] = {}
		for seq = 0, GameEnum.HESHENLUOSHU_MAX_SEQ - 1 do
			self.upgrade_data[type][seq] = {}
			self.upgrade_data[type][seq].level = MsgAdapter.ReadShort()
			self.upgrade_data[type][seq].exp = MsgAdapter.ReadShort()
		end
	end
end

--河神洛书改变信息
SCHeShenLuoShuChangeInfo = SCHeShenLuoShuChangeInfo or BaseClass(BaseProtocolStruct)
function SCHeShenLuoShuChangeInfo:__init()
	self.msg_type = 8810
end

function SCHeShenLuoShuChangeInfo:Decode()
	self.param1 = MsgAdapter.ReadShort()                   --type
	self.param2 = MsgAdapter.ReadShort()                   --seq
	self.param3 = MsgAdapter.ReadShort()                   --index
	self.param4 = MsgAdapter.ReadShort()                   --level
	self.param5 = MsgAdapter.ReadShort()                   --shenghua_level
	self.param6 = MsgAdapter.ReadShort()                   --shenghua_exp
end

-- -- 通知小鬼到期
-- SCRoleImpExpireTime = SCRoleImpExpireTime or BaseClass(BaseProtocolStruct)
-- function SCRoleImpExpireTime:__init()
-- 	self.msg_type = 8811
-- end

-- function SCRoleImpExpireTime:Decode()
-- 	self.grid_index = MsgAdapter.ReadShort()           -- 发生变化的小鬼index   0或1
--     self.res_sh = MsgAdapter.ReadShort()
-- end

-- 转职
CSRoleZhuanZhiReq = CSRoleZhuanZhiReq or BaseClass(BaseProtocolStruct)
function CSRoleZhuanZhiReq:__init()
	self.msg_type = 8812
end

function CSRoleZhuanZhiReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(self.param1)
	MsgAdapter.WriteShort(self.param2)
	MsgAdapter.WriteShort(self.param3)
end

SCRoleZhuanZhiInfo = SCRoleZhuanZhiInfo or BaseClass(BaseProtocolStruct)
function SCRoleZhuanZhiInfo:__init()
	self.msg_type = 8813
end

function SCRoleZhuanZhiInfo:Decode()
	self.zhuanzhi_level_fire = MsgAdapter.ReadChar()
	self.zhuanzhi_level_six = MsgAdapter.ReadChar()
	self.zhuanzhi_level_seven = MsgAdapter.ReadChar()
	self.zhuanzhi_level_eight = MsgAdapter.ReadChar()
	self.zhuanzhi_level_nine = MsgAdapter.ReadChar()
	self.zhuanzhi_level_ten = MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
end

-- 转职技能释放广播
SCZhuanzhiSkillTrigger = SCZhuanzhiSkillTrigger or BaseClass(BaseProtocolStruct)
function SCZhuanzhiSkillTrigger:__init()
	self.msg_type = 8814
end

function SCZhuanzhiSkillTrigger:Decode()
	self.skill_id = MsgAdapter.ReadShort()						-- 技能id
	MsgAdapter.ReadShort()
	self.target_obj_id = MsgAdapter.ReadUShort()				-- 目标obj_id
	self.deliver_obj_id = MsgAdapter.ReadUShort()				-- 释放obj_id
	self.injure = MsgAdapter.ReadLL()							-- 伤害值
end

-- 三生三世信息
SCRAPerfectLoverInfo = SCRAPerfectLoverInfo or BaseClass(BaseProtocolStruct)
function SCRAPerfectLoverInfo:__init()
	self.msg_type = 8815
	self.my_rank = 0
	self.perfect_lover_type_record_flag = 0
	self.ra_perfect_lover_count = 0
end

function SCRAPerfectLoverInfo:Decode()
	self.my_rank = MsgAdapter.ReadInt()
	self.lover_name = MsgAdapter.ReadStrN(32)
	self.perfect_lover_type_record_flag = MsgAdapter.ReadShort()
	self.ra_perfect_lover_count = MsgAdapter.ReadShort()
	local count = math.min(self.ra_perfect_lover_count / 2, GameEnum.RA_PERFECT_LOVE_COUPLE_COUNT_MAX)
	self.ra_perfect_lover_name_list = {}
	for i = 1, count do
		self.ra_perfect_lover_name_list[i] = {}
		self.ra_perfect_lover_name_list[i].propose_name = MsgAdapter.ReadStrN(32)
		self.ra_perfect_lover_name_list[i].accept_proposal_name = MsgAdapter.ReadStrN(32)
		-- table.insert(self.ra_perfect_lover_name_list[i], MsgAdapter.ReadStrN(32))
		-- table.insert(self.ra_perfect_lover_name_list[i], MsgAdapter.ReadStrN(32))
	end
end

--全民进阶信息 活动号：2200
SCQuanMinJinJieInfo = SCQuanMinJinJieInfo or BaseClass(BaseProtocolStruct)
function SCQuanMinJinJieInfo:__init()
	self.msg_type = 8816
	self.reward_flag = 0
	self.grade = 0
end

function SCQuanMinJinJieInfo:Decode()
	self.reward_flag = MsgAdapter.ReadInt()
	self.grade = MsgAdapter.ReadInt()
end

--全民总动员信息 活动号：2201
SCUpgradeGroupeInfo = SCUpgradeGroupeInfo or BaseClass(BaseProtocolStruct)
function SCUpgradeGroupeInfo:__init()
	self.msg_type = 8817
	self.ra_upgrade_group_reward_flag = 0
	self.count_list = {}
	for i = 1 , GameEnum.MAX_UPGRADE_RECORD_COUNT do 
		self.count_list[i] = 0
	end
end

function SCUpgradeGroupeInfo:Decode()
	self.ra_upgrade_group_reward_flag = MsgAdapter.ReadInt()
	for i = 1 , GameEnum.MAX_UPGRADE_RECORD_COUNT do 
		self.count_list[i] = MsgAdapter.ReadInt()
	end
end

-- 消费领奖
SCRAConsumGiftRollRewardTen = SCRAConsumGiftRollRewardTen or BaseClass(BaseProtocolStruct)
function SCRAConsumGiftRollRewardTen:__init()
	self.msg_type = 8834
	self.seq_list = {}
	self.decade_list = {}
	self.units_digit_list = {}
end

function SCRAConsumGiftRollRewardTen:Decode()
	for i = 1 , GameEnum.MAX_COUNT do 
		self.seq_list[i] = MsgAdapter.ReadChar()
	end

	for i = 1 , GameEnum.MAX_COUNT do 
		self.decade_list[i] = MsgAdapter.ReadChar()
	end

	for i = 1 , GameEnum.MAX_COUNT do 
		self.units_digit_list[i] = MsgAdapter.ReadChar()
	end
end


----------------------------------------组合团购--------------------------------------------
-- 购物车信息
SCRACombineBuyBucketInfo = SCRACombineBuyBucketInfo or BaseClass(BaseProtocolStruct)
function SCRACombineBuyBucketInfo:__init()
	self.msg_type = 8835
end

function SCRACombineBuyBucketInfo:Decode()
	self.seq_list = {}
	for i = 0, GameEnum.RA_COMBINE_BUY_BUCKET_ITEM_COUNT - 1 do
		self.seq_list[i] = MsgAdapter.ReadInt()
	end	
end

-- 物品已购买数量信息
SCRACombineBuyInfo = SCRACombineBuyInfo or BaseClass(BaseProtocolStruct)
function SCRACombineBuyInfo:__init()
	self.msg_type = 8836
end

function SCRACombineBuyInfo:Decode()
	self.buy_item_num = {}
	for i = 0, GameEnum.RA_COMBINE_BUY_MAX_ITEM_COUNT - 1 do
		self.buy_item_num[i] = MsgAdapter.ReadUChar()
	end	
end

SCRuneTowerPassRewardInfo = SCRuneTowerPassRewardInfo or BaseClass(BaseProtocolStruct)
function SCRuneTowerPassRewardInfo:__init()
	self.msg_type = 8818
end

function SCRuneTowerPassRewardInfo:Decode()
	self.reward_count = MsgAdapter.ReadInt()
	self.reward_list = {}
	for i = 1, self.reward_count do
		local vo = {}
		vo.item_id = MsgAdapter.ReadUShort()
		vo.num = MsgAdapter.ReadChar()
		vo.is_bind = MsgAdapter.ReadChar()
		self.reward_list[i] = vo
	end
end

--登录豪礼
SCRALoginGiftInfo = SCRALoginGiftInfo or BaseClass(BaseProtocolStruct)
function SCRALoginGiftInfo:__init()
	self.msg_type = 8819

	self.login_days = 0
	self.has_login = 0
	self.has_fetch_accumulate_reward = 0
	self.fetch_common_reward_flag = 0
	self.fetch_vip_reward_flag = 0
end

function SCRALoginGiftInfo:Decode()
	self.login_days =  MsgAdapter.ReadShort()
	self.has_login = MsgAdapter.ReadChar()
	self.has_fetch_accumulate_reward = MsgAdapter.ReadChar()
	self.fetch_common_reward_flag = MsgAdapter.ReadInt()
	self.fetch_vip_reward_flag = MsgAdapter.ReadInt()
end

--每日好礼
SCRAEverydayNiceGiftInfo = SCRAEverydayNiceGiftInfo or BaseClass(BaseProtocolStruct)
function SCRAEverydayNiceGiftInfo:__init()
	self.msg_type = 8820
	self.is_active = 0
	self.everyday_recharge = 0
	self.can_fetch_reward_flag = 0
	self.have_fetch_reward_flag = 0
end

function SCRAEverydayNiceGiftInfo:Decode()
	self.is_active = MsgAdapter.ReadShort()
	self.reserver_sh = MsgAdapter.ReadShort()
	self.everyday_recharge = MsgAdapter.ReadInt()
	self.can_fetch_reward_flag = MsgAdapter.ReadInt()
	self.have_fetch_reward_flag = MsgAdapter.ReadInt()
end

--吃鸡盛宴 请求操作
CSHolidayGuardRoleReq = CSHolidayGuardRoleReq or BaseClass(BaseProtocolStruct)
function CSHolidayGuardRoleReq:__init()
	self.msg_type = 8825
end

function CSHolidayGuardRoleReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.req_type)
end

--吃鸡盛宴 个人信息
SCHolidayGuardRoleInfo = SCHolidayGuardRoleInfo or BaseClass(BaseProtocolStruct)
function SCHolidayGuardRoleInfo:__init()
	self.msg_type = 8826
	self.personal_join_times = 0
	self.personal_kill_monster_count = 0
	self.reserve_ch = 0
end

function SCHolidayGuardRoleInfo:Decode()
	self.personal_join_times = MsgAdapter.ReadInt()
	self.personal_kill_monster_count = MsgAdapter.ReadShort()
	self.reserve_ch = MsgAdapter.ReadShort()
end

--吃鸡盛宴 塔防信息 
SCHolidayGuardInfo = SCHolidayGuardInfo or BaseClass(BaseProtocolStruct)
function SCHolidayGuardInfo:__init()
	self.msg_type = 8827
	self.reason = 0
	self.reserve = 0

	self.time_out_stamp = 0
	self.is_finish = 0
	self.is_pass = 0
	self.pass_time_s = 0

	self.life_tower_left_hp = 0				--生命塔HP
	self.life_tower_left_maxhp = 0			--生命塔最大HP
	self.curr_wave = 0						-- 当前波
	self.reserve_1 = 0						
	self.next_wave_refresh_time = 0			-- 下一波到来时间
	self.clear_wave_count = 0				-- 清理怪物波数
	self.total_kill_monster_count = 0		-- 击杀怪物数量

	self.get_coin = 0
	self.get_item_count = 0
end

function SCHolidayGuardInfo:Decode()
	self.reason = MsgAdapter.ReadShort()
	self.reserve = MsgAdapter.ReadShort()

	self.time_out_stamp = MsgAdapter.ReadInt()
	self.is_finish = MsgAdapter.ReadShort()
	self.is_pass = MsgAdapter.ReadShort()
	self.pass_time_s = MsgAdapter.ReadInt()

	self.life_tower_left_hp = MsgAdapter.ReadLL()				--生命塔HP
	self.life_tower_left_maxhp = MsgAdapter.ReadLL()			--生命塔最大HP
	self.curr_wave = MsgAdapter.ReadShort()						-- 当前波
	self.reserve_1 = MsgAdapter.ReadShort()						
	self.next_wave_refresh_time = MsgAdapter.ReadInt()			-- 下一波到来时间
	self.clear_wave_count = MsgAdapter.ReadShort()				-- 清理怪物波数
	self.total_kill_monster_count = MsgAdapter.ReadShort()		-- 击杀怪物数量

	self.get_coin = MsgAdapter.ReadInt()
	self.get_item_count = MsgAdapter.ReadInt()

	self.pick_drop_list = {}
	for i = 1, self.get_item_count do
		local v = {}
		v.num = MsgAdapter.ReadShort()
		v.item_id = MsgAdapter.ReadUShort()
		self.pick_drop_list[i] = v
	end
end

--吃鸡盛宴 副本怪物掉落统计
SCHolidayGuardFBDropInfo = SCHolidayGuardFBDropInfo or BaseClass(BaseProtocolStruct)
function SCHolidayGuardFBDropInfo:__init()
	self.msg_type = 8828
	self.get_coin = 0
	self.get_item_count = 0
end

function SCHolidayGuardFBDropInfo:Decode()
	self.get_coin = MsgAdapter.ReadInt()
	self.get_item_count = MsgAdapter.ReadInt()
	self.item_list = {}

	for i = 1, self.get_item_count do
		local v = {}
		v.num = MsgAdapter.ReadShort()
		v.item_id = MsgAdapter.ReadUShort()
		self.item_list[i] = v
	end
end

--吃鸡盛宴 通关结果
SCHolidayGuardResult = SCHolidayGuardResult or BaseClass(BaseProtocolStruct)
function SCHolidayGuardResult:__init()
	self.msg_type = 8829
	self.is_passed = 0
	self.clear_wave_count = 0
	self.resertotal_kill_monster_countve_sh = 0
end

function SCHolidayGuardResult:Decode()
	self.is_passed = MsgAdapter.ReadChar()
	self.clear_wave_count = MsgAdapter.ReadChar()
	self.resertotal_kill_monster_countve_sh = MsgAdapter.ReadShort()
end

--吃鸡盛宴 生命塔被攻击预警
SCHolidayGuardWarning = SCHolidayGuardWarning or BaseClass(BaseProtocolStruct)
function SCHolidayGuardWarning:__init()
	self.msg_type = 8830
	self.warning_type = 1
	self.percent = 0
end

function SCHolidayGuardWarning:Decode()
	self.warning_type = MsgAdapter.ReadShort()
	self.percent = MsgAdapter.ReadShort()
end

--吃鸡盛宴 节日守护击杀排行信息
SCRAHolidayGuardRanKInfo = SCRAHolidayGuardRanKInfo or BaseClass(BaseProtocolStruct)
function SCRAHolidayGuardRanKInfo:__init()
	self.msg_type = 8831
end

function SCRAHolidayGuardRanKInfo:Decode()
	self.kill_rank = {}
	for i = 1, GameEnum.RAND_ACTIVITY_HOLIDAYGUARD_PERSON_RANK_MAX do
		local v = {}
		v.uid = MsgAdapter.ReadInt()
		v.user_name = MsgAdapter.ReadStrN(32)
		v.kill_monster_count = MsgAdapter.ReadInt()
		v.total_capablity = MsgAdapter.ReadInt()
		v.sex = MsgAdapter.ReadChar()				
		v.prof = MsgAdapter.ReadChar()			
		v.reserve_sh = MsgAdapter.ReadShort()					
		v.pass_time = MsgAdapter.ReadInt()		
		self.kill_rank[i] = v
	end
end

--吃鸡盛宴 节日守护请求排行下发
CSRAHolidayGuardRankInfoReq = CSRAHolidayGuardRankInfoReq or BaseClass(BaseProtocolStruct)
function CSRAHolidayGuardRankInfoReq:__init()
	self.msg_type = 8832
end

function CSRAHolidayGuardRankInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--吃鸡盛宴
SCRAExtremeChallengeNpcInfo = SCRAExtremeChallengeNpcInfo or BaseClass(BaseProtocolStruct)
function SCRAExtremeChallengeNpcInfo:__init()
	self.msg_type = 8833
end

function SCRAExtremeChallengeNpcInfo:Decode()
	self.npc_list = {}
	for i = 1, GameEnum.HOLIDAYGUARD_NPC_CFG_MAX_COUNT do
		local v = {}
		v.npc_index = MsgAdapter.ReadInt()
		v.scene_id = MsgAdapter.ReadInt()
		v.npc_id = MsgAdapter.ReadInt()
		v.npc_x = MsgAdapter.ReadInt()
		v.npc_y = MsgAdapter.ReadInt()
		self.npc_list[i] = v
	end
end

--boss死亡通知同场景有输出的玩家
SCNoticeBossDead = SCNoticeBossDead or BaseClass(BaseProtocolStruct)
function SCNoticeBossDead:__init()
	self.msg_type = 8824
	self.boss_id = 0
	self.killer_uid = 0
	self.killer_avatar_timestamp = 0
end

function SCNoticeBossDead:Decode()
	self.boss_id = MsgAdapter.ReadInt()
	self.killer_uid = MsgAdapter.ReadInt()
	self.killer_avatar_timestamp = MsgAdapter.ReadLL()
end

------------------------------天天返利--------------------------------
CSDayChongzhiRewardReq = CSDayChongzhiRewardReq or BaseClass(BaseProtocolStruct)
function CSDayChongzhiRewardReq:__init()
	self.msg_type = 8837
end

function CSDayChongzhiRewardReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(self.param)
end

SCDayChongzhiRewardInfo = SCDayChongzhiRewardInfo or BaseClass(BaseProtocolStruct)
function SCDayChongzhiRewardInfo:__init()
	self.msg_type = 8838
end

function SCDayChongzhiRewardInfo:Decode()
	self.day_count = MsgAdapter.ReadInt()
	self.reward_flag_list = {}
	for i = 1, GameEnum.DAY_CHONGZHI_REWARD_FLAG_LIST_LEN do
		self.reward_flag_list[i] = MsgAdapter.ReadUInt()
	end

	self.rare_reward_flag_list = {}
	for i = 1, GameEnum.DAY_CHONGZHI_REWARD_FLAG_LIST_LEN do
		self.rare_reward_flag_list[i] = MsgAdapter.ReadUInt()
	end
end
------------------------------天天返利END------------------------------

--仙尊卡
CSXianZunKaOperaReq = CSXianZunKaOperaReq or BaseClass(BaseProtocolStruct)
function CSXianZunKaOperaReq:__init()
	self.msg_type = 8839
end

function CSXianZunKaOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.opera_req_type)
	MsgAdapter.WriteShort(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
end

-- 仙尊卡返回
SCXianZunKaAllInfo = SCXianZunKaAllInfo or BaseClass(BaseProtocolStruct)
function SCXianZunKaAllInfo:__init()
	self.msg_type = 8840
	self.forever_active_flag = 0
	self.first_active_reward_flag = 0
	self.daily_reward_fetch_flag = 0
	self.temporary_valid_end_timestamp_list = {}
end

function SCXianZunKaAllInfo:Decode()
	self.forever_active_flag = MsgAdapter.ReadShort()
	self.first_active_reward_flag = MsgAdapter.ReadChar()
	self.daily_reward_fetch_flag = MsgAdapter.ReadChar()
	self.temporary_valid_end_timestamp_list = {}
	for i=0, XIANZUNKA_TYPE_MAX - 1 do
		self.temporary_valid_end_timestamp_list[i] = MsgAdapter.ReadUInt()
	end
end

-- 转职装备武器颜色（首充武器相关）
SCRoleAppeChange = SCRoleAppeChange or BaseClass(BaseProtocolStruct)
function SCRoleAppeChange:__init()
	self.msg_type = 8841
end

function SCRoleAppeChange:Decode()
	self.appe_type = MsgAdapter.ReadInt()
	self.obj_id = MsgAdapter.ReadInt()
	self.param = MsgAdapter.ReadInt()
end

--====================================================================
--==============================夫妻家园==============================
--====================================================================
--夫妻家园请求
CSSpouseHomeOperaReq = CSSpouseHomeOperaReq or BaseClass(BaseProtocolStruct)
function CSSpouseHomeOperaReq:__init()
	self.msg_type = 8842
	self.opera_type = 0
	self.param1 = 0
	self.param2 = 0
	self.param3 = 0
end

function CSSpouseHomeOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opera_type)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
	MsgAdapter.WriteInt(self.param3)
	MsgAdapter.WriteInt(self.param4)
end

-- 夫妻家园房子信息列表
SCSpouseHomeRoomInfo = SCSpouseHomeRoomInfo or BaseClass(BaseProtocolStruct)
function SCSpouseHomeRoomInfo:__init()
	self.msg_type = 8843
end

function SCSpouseHomeRoomInfo:Decode()
	self.uid = MsgAdapter.ReadInt()
	local count = MsgAdapter.ReadShort()
	self.pet_id = MsgAdapter.ReadShort()
	self.room_furniture_limit = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.house_list = {}
	for i = 1, count do
		self.house_list[i] = {}
		self.house_list[i].house_index = MsgAdapter.ReadShort()
		self.house_list[i].theme_type = MsgAdapter.ReadShort()

		local furniture_list = {}
		for j = 0, GameEnum.SPOUSE_HOME_FURNITURE_MAX_ITEM_SLOT_SERVER - 1 do
			if j >= self.room_furniture_limit then
				MsgAdapter.ReadUShort()
			else
				furniture_list[j] = {}
				furniture_list[j].item_id = MsgAdapter.ReadUShort()
			end
		end

		self.house_list[i].furniture_list = furniture_list
	end
end

-- 夫妻家园好友信息列表
SCSpouseHomeFirendInfo = SCSpouseHomeFirendInfo or BaseClass(BaseProtocolStruct)
function SCSpouseHomeFirendInfo:__init()
	self.msg_type = 8844
end

function SCSpouseHomeFirendInfo:Decode()
	local firend_count = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.firend_info_list = {}
	for i = 1, firend_count do
		self.firend_info_list[i] = {}
		self.firend_info_list[i].uid = MsgAdapter.ReadInt()
		self.firend_info_list[i].room_count = MsgAdapter.ReadChar()
		self.firend_info_list[i].sex = MsgAdapter.ReadChar()
		self.firend_info_list[i].prof = MsgAdapter.ReadChar()
		MsgAdapter.ReadChar()
		self.firend_info_list[i].role_name = MsgAdapter.ReadStrN(32)
	end
end

-- 夫妻家园盟友信息列表
SCSpouseHomeGuildMemberInfo = SCSpouseHomeGuildMemberInfo or BaseClass(BaseProtocolStruct)
function SCSpouseHomeGuildMemberInfo:__init()
	self.msg_type = 8845
end

function SCSpouseHomeGuildMemberInfo:Decode()
	local guild_member_count = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.guild_member_info_list = {}
	for i = 1, guild_member_count do
		self.guild_member_info_list[i] = {}
		self.guild_member_info_list[i].uid = MsgAdapter.ReadInt()
		self.guild_member_info_list[i].room_count = MsgAdapter.ReadChar()
		self.guild_member_info_list[i].sex = MsgAdapter.ReadChar()
		self.guild_member_info_list[i].prof = MsgAdapter.ReadChar()
		MsgAdapter.ReadChar()
		self.guild_member_info_list[i].role_name = MsgAdapter.ReadStrN(32)
	end
end

-- 夫妻家园单个房子信息
SCSpouseHomeSingleRoomInfo = SCSpouseHomeSingleRoomInfo or BaseClass(BaseProtocolStruct)
function SCSpouseHomeSingleRoomInfo:__init()
	self.msg_type = 8846
end

function SCSpouseHomeSingleRoomInfo:Decode()
	self.pet_id = MsgAdapter.ReadShort()
	self.room_furniture_limit = MsgAdapter.ReadShort()
	self.house_info = {}
	self.house_info.house_index = MsgAdapter.ReadShort()
	self.house_info.theme_type = MsgAdapter.ReadShort()

	local furniture_list = {}
	for i = 0, self.room_furniture_limit - 1 do
		furniture_list[i] = {}
		furniture_list[i].item_id = MsgAdapter.ReadUShort()
	end

	self.house_info.furniture_list = furniture_list
end

----------------------- 装备洗炼 -------------------------------
CSEquipBaptizeOperaReq = CSEquipBaptizeOperaReq or BaseClass(BaseProtocolStruct)
function CSEquipBaptizeOperaReq:__init()
	self.msg_type = 8847
end

function CSEquipBaptizeOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.operate_type)
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
	MsgAdapter.WriteInt(self.param_3)	
end

SCEquipBaptizeAllInfo = SCEquipBaptizeAllInfo or BaseClass(BaseProtocolStruct)
function SCEquipBaptizeAllInfo:__init()
	self.msg_type = 8848
end

function SCEquipBaptizeAllInfo:Decode()
	self.part_info_list = {}
	for i = 0, COMMON_CONSTS.E_INDEX_MAX do
		self.part_info_list[i] = {}
		local baptize_list = {} 	-- 属性
		local attr_seq_list = {} 	-- 属性seq
		for i = 1, COMMON_CONSTS.EQUIP_BAPTIZE_ONE_PART_MAX_BAPTIZE_NUM do
			baptize_list[i] = MsgAdapter.ReadInt()
		end
		for i = 1, COMMON_CONSTS.EQUIP_BAPTIZE_ONE_PART_MAX_BAPTIZE_NUM do
			attr_seq_list[i] = MsgAdapter.ReadShort()
		end
		self.part_info_list[i].baptize_list = baptize_list
		self.part_info_list[i].attr_seq_list = attr_seq_list
	end

	self.open_flag = {}
	for i = 0, COMMON_CONSTS.E_INDEX_MAX do
		self.open_flag[i] = MsgAdapter.ReadUChar()
	end
	self.lock_flag = {}
	for i = 0, COMMON_CONSTS.E_INDEX_MAX do
		self.lock_flag[i] = MsgAdapter.ReadUChar()
	end
	self.used_free_times = MsgAdapter.ReadUChar()
	MsgAdapter.ReadUChar()
	MsgAdapter.ReadUShort()
end

-- 神格品质信息
SCShenggeSuitInfo = SCShenggeSuitInfo or BaseClass(BaseProtocolStruct)
function SCShenggeSuitInfo:__init()
	self.msg_type = 8849
	self.shenge_quality_info = {}
end

function SCShenggeSuitInfo:Decode()
	for i=1,6 do
		self.shenge_quality_info[i] = MsgAdapter.ReadInt()
	end
end

-------------------------秘藏Boss--------------------------
-- 秘藏复活疲劳
SCMiZangBossReliveTire = SCMiZangBossReliveTire or BaseClass(BaseProtocolStruct)
function SCMiZangBossReliveTire:__init()
	self.msg_type = 8860
end

function SCMiZangBossReliveTire:Decode()
	MsgAdapter.ReadShort()
	self.relive_tire_value = MsgAdapter.ReadShort()
	self.tire_buff_end_time = MsgAdapter.ReadUInt()
	self.tire_can_relive_time = MsgAdapter.ReadUInt()
end

local LUCKY_WISH_MAX_ITEM_COUNT = 30

--------------------------幸运许愿---------------------------
SCLuckyWishInfo = SCLuckyWishInfo or BaseClass(BaseProtocolStruct)
function SCLuckyWishInfo:__init()
	self.msg_type = 8861
	self.item_list_count = 0
end

function SCLuckyWishInfo:Decode()
	self.lucky_value = MsgAdapter.ReadInt()				--幸运值
	self.type = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	self.item_list_count = MsgAdapter.ReadShort()
	self.item_list = {}
	if self.type ~= 0 and self.item_list_count > 0 then
		for i = 1, self.item_list_count do
			self.item_list[i] = {}
			self.item_list[i].item_id = MsgAdapter.ReadUShort()					--物品id
			self.item_list[i].is_bind = MsgAdapter.ReadShort()
			self.item_list[i].num = MsgAdapter.ReadInt()
		end
	end
	
end

CSLuckyWishOpera = CSLuckyWishOpera or BaseClass(BaseProtocolStruct)
function CSLuckyWishOpera:__init()
	self.msg_type = 8862
	self.type = 0
	self.param_1 = 0
end

function CSLuckyWishOpera:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteChar(self.type)
	MsgAdapter.WriteChar(self.param_1)
end

----------------------- 请求跨服秘藏boss信息 -------------------------------
CSCrossMiZangBossBossInfoReq = CSCrossMiZangBossBossInfoReq or BaseClass(BaseProtocolStruct)
function CSCrossMiZangBossBossInfoReq:__init()
	self.msg_type = 8850
	self.opera_type = 0
	self.param_1 = 0
	self.param_2 = 0
end

function CSCrossMiZangBossBossInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opera_type)
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
end

-- 跨服秘藏boss信息
SCCrossMizangBossBossInfoAck = SCCrossMizangBossBossInfoAck or BaseClass(BaseProtocolStruct)
function SCCrossMizangBossBossInfoAck:__init()
	self.msg_type = 8851
end

function SCCrossMizangBossBossInfoAck:Decode()
	self.scene_count = MsgAdapter.ReadInt()
	self.scene_list = {}
	for i = 1, self.scene_count do
		local temp_scene_list = {}
		temp_scene_list.layer = MsgAdapter.ReadShort()
		temp_scene_list.left_treasure_crystal_count = MsgAdapter.ReadShort()
		temp_scene_list.left_monster_count = MsgAdapter.ReadShort()
		temp_scene_list.boss_count = MsgAdapter.ReadShort()
		temp_scene_list.boss_list = {}
		for i = 1, GameEnum.MAX_CROSS_MIZANG_BOSS_PER_SCENE do
			temp_scene_list.boss_list[i] = {}
			temp_scene_list.boss_list[i].boss_id = MsgAdapter.ReadInt()
			temp_scene_list.boss_list[i].next_flush_time = MsgAdapter.ReadUInt()
		end
		table.insert(self.scene_list, temp_scene_list)
	end
end

-- 跨服秘藏boss场景里的玩家信息
SCCrossMizangBossSceneInfo = SCCrossMizangBossSceneInfo or BaseClass(BaseProtocolStruct)
function SCCrossMizangBossSceneInfo:__init()
	self.msg_type = 8852
end

function SCCrossMizangBossSceneInfo:Decode()
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

-- 跨服秘藏boss场景里的玩家信息
SCCrossMiZangBossPlayerInfo = SCCrossMiZangBossPlayerInfo or BaseClass(BaseProtocolStruct)
function SCCrossMiZangBossPlayerInfo:__init()
	self.msg_type = 8853
end

function SCCrossMiZangBossPlayerInfo:Decode()
	self.left_can_kill_boss_num = MsgAdapter.ReadShort()					-- 剩余Boss数
	self.left_treasure_crystal_gather_times = MsgAdapter.ReadShort()		-- 剩余珍惜水晶采集次数
	self.left_ordinary_crystal_gather_times = MsgAdapter.ReadUInt()			-- 剩余普通水晶采集次数
	self.concern_flag = {}
	for i = 1, GameEnum.CROSS_MIZANG_BOSS_SCENE_MAX do
		self.concern_flag[i] = {}
		self.concern_flag[i] = MsgAdapter.ReadUInt()						-- 关注flag
	end
end


---------------跨服幽冥boss----------------------
-- 幽冥复活疲劳
SCYouMingBossReliveTire = SCYouMingBossReliveTire or BaseClass(BaseProtocolStruct)
function SCYouMingBossReliveTire:__init()
	self.msg_type = 8855
end

function SCYouMingBossReliveTire:Decode()
	MsgAdapter.ReadShort()
	self.relive_tire_value = MsgAdapter.ReadShort()
	self.tire_buff_end_time = MsgAdapter.ReadUInt()
	self.tire_can_relive_time = MsgAdapter.ReadUInt()
end

----------------------- 请求跨服幽冥boss信息 -------------------------------
CSCrossYouMingBossBossInfoReq = CSCrossYouMingBossBossInfoReq or BaseClass(BaseProtocolStruct)
function CSCrossYouMingBossBossInfoReq:__init()
	self.msg_type = 8856
	self.opera_type = 0
	self.param_1 = 0
	self.param_2 = 0
end

function CSCrossYouMingBossBossInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opera_type)
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
end

-- 跨服幽冥boss信息
SCCrossYouMingBossBossInfoAck = SCCrossYouMingBossBossInfoAck or BaseClass(BaseProtocolStruct)
function SCCrossYouMingBossBossInfoAck:__init()
	self.msg_type = 8857
end

function SCCrossYouMingBossBossInfoAck:Decode()
	self.scene_count = MsgAdapter.ReadInt()
	self.scene_list = {}
	for i = 1, self.scene_count do
		local temp_scene_list = {}
		temp_scene_list.layer = MsgAdapter.ReadShort()
		temp_scene_list.left_treasure_crystal_count = MsgAdapter.ReadShort()
		temp_scene_list.left_monster_count = MsgAdapter.ReadShort()
		temp_scene_list.boss_count = MsgAdapter.ReadShort()
		temp_scene_list.boss_list = {}
		for i = 1, GameEnum.MAX_CROSS_MIZANG_BOSS_PER_SCENE do
			temp_scene_list.boss_list[i] = {}
			temp_scene_list.boss_list[i].boss_id = MsgAdapter.ReadInt()
			temp_scene_list.boss_list[i].next_flush_time = MsgAdapter.ReadUInt()
		end
		table.insert(self.scene_list, temp_scene_list)
	end
end

-- 跨服幽冥boss场景里的玩家信息
SCCrossYouMingBossSceneInfo = SCCrossYouMingBossSceneInfo or BaseClass(BaseProtocolStruct)
function SCCrossYouMingBossSceneInfo:__init()
	self.msg_type = 8858
end

function SCCrossYouMingBossSceneInfo:Decode()
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

-- 跨服幽冥boss场景里的玩家信息
SCCrossYouMingBossPlayerInfo = SCCrossYouMingBossPlayerInfo or BaseClass(BaseProtocolStruct)
function SCCrossYouMingBossPlayerInfo:__init()
	self.msg_type = 8859
end

function SCCrossYouMingBossPlayerInfo:Decode()
	self.left_can_kill_boss_num = MsgAdapter.ReadShort()					-- 剩余Boss数
	self.left_treasure_crystal_gather_times = MsgAdapter.ReadShort()		-- 剩余珍惜水晶采集次数
	self.left_ordinary_crystal_gather_times = MsgAdapter.ReadUInt()			-- 剩余普通水晶采集次数
	self.concern_flag = {}
	for i = 1, GameEnum.CROSS_MIZANG_BOSS_SCENE_MAX do
		self.concern_flag[i] = {}
		self.concern_flag[i] = MsgAdapter.ReadUInt()						-- 关注flag
	end
end

SCImageCompetitionInfo = SCImageCompetitionInfo or BaseClass(BaseProtocolStruct)
function SCImageCompetitionInfo:__init()
	self.msg_type = 8863
end

function SCImageCompetitionInfo:Decode()
	 self.opengame_day = MsgAdapter.ReadInt()
end
----------------------- 请求组队副本购买多倍奖励 -------------------------------
CSFetchDoubleRewardReq = CSFetchDoubleRewardReq or BaseClass(BaseProtocolStruct)
function CSFetchDoubleRewardReq:__init()
	self.msg_type = 8873
	self.fuben_type = 0 													-- 副本类型
	self.fb_time = 0 														-- 请求标志信息，times = 0
end

function CSFetchDoubleRewardReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.fuben_type)
	MsgAdapter.WriteInt(self.fb_time)
end

SCFetchDoubleRewardResult = SCFetchDoubleRewardResult or BaseClass(BaseProtocolStruct)
function SCFetchDoubleRewardResult:__init()
	self.msg_type = 8874
	self.fb_type = 0 
	self.today_buy_times = 0 
	self.item_count = 0
end

function SCFetchDoubleRewardResult:Decode()
	self.fb_type = MsgAdapter.ReadInt() 									-- 副本类型
	self.today_buy_times = MsgAdapter.ReadChar() 								-- 购买次数，0：今天天未购买；1：购买了一次；2：购买了两次
	self.reserve_sh =  MsgAdapter.ReadChar()
	self.item_count = MsgAdapter.ReadShort()
	self.xiannv_shengwu = MsgAdapter.ReadInt()
	self.item_list = {}
	for i = 1, self.item_count do 											-- 奖励
		local item_data = {}
		item_data.num = MsgAdapter.ReadShort()
		item_data.item_id = MsgAdapter.ReadUShort()
		table.insert(self.item_list, item_data)
	end
end

-- 随机礼包开出的物品信息
SCRandGiftItemInfo = SCRandGiftItemInfo or BaseClass(BaseProtocolStruct)
function SCRandGiftItemInfo:__init()
	self.msg_type = 8875
	self.item_count = 0
end

function SCRandGiftItemInfo:Decode()
	self.gift_type = MsgAdapter.ReadInt()
	self.item_count = MsgAdapter.ReadInt()
	self.item_list = {}
	for i = 1, self.item_count do 											-- 奖励
		local item_data = {}
		item_data.item_id = MsgAdapter.ReadInt()
		item_data.num = MsgAdapter.ReadInt()
		item_data.is_bind = MsgAdapter.ReadInt()
		item_data.color = 0
		table.insert(self.item_list, item_data)
	end
end

--个人BOSS信息请求
CSPersonBossInfoReq = CSPersonBossInfoReq or BaseClass(BaseProtocolStruct)
function CSPersonBossInfoReq:__init()
	self.msg_type = 8876
end

function CSPersonBossInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

SCPersonBossInfo = SCPersonBossInfo or BaseClass(BaseProtocolStruct)
function SCPersonBossInfo:__init()
	self.msg_type = 8877
	self.info_list = {}
end

function SCPersonBossInfo:Decode()
	local boss_scene_cfg = BossData.Instance:GetPersonBossSceneCfg()
	local layer_num = GetListNum(boss_scene_cfg)
	for i=1, layer_num do
		self.info_list[i] = {}
		self.info_list[i].layer = MsgAdapter.ReadShort()
		self.info_list[i].times = MsgAdapter.ReadShort()
	end
end

SCUpgradeCardBuyInfo = SCUpgradeCardBuyInfo or BaseClass(BaseProtocolStruct)
function SCUpgradeCardBuyInfo:__init()
	self.msg_type = 8878
end

function SCUpgradeCardBuyInfo:Decode()
	self.activity_id = MsgAdapter.ReadShort()
	self.grade = MsgAdapter.ReadShort()
	self.is_already_buy = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
end

CSUpgradeCardBuyReq = CSUpgradeCardBuyReq or BaseClass(BaseProtocolStruct)
function CSUpgradeCardBuyReq:__init()
	self.msg_type = 8879
	self.activity_id = 0
	self.item_id = 0
end

function CSUpgradeCardBuyReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.activity_id)
	MsgAdapter.WriteUShort(self.item_id)
end

-- 请求轻功快速降落
CSRolePersonAreaMsgInfo = CSRolePersonAreaMsgInfo or BaseClass(BaseProtocolStruct)
function CSRolePersonAreaMsgInfo:__init()
	self.msg_type = 8888

end

function CSRolePersonAreaMsgInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	for i = 1, 8 do
		MsgAdapter.WriteInt(0)
	end
end

SCRolePersonAreaMsgInfo = SCRolePersonAreaMsgInfo or BaseClass(BaseProtocolStruct)
function SCRolePersonAreaMsgInfo:__init()
	self.msg_type = 8889
	self.obj_id = 0x10000
end

function SCRolePersonAreaMsgInfo:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	MsgAdapter.ReadShort()
end

-- 跨服随机活动统一请求
CSCrossRandActivityRequest  = CSCrossRandActivityRequest or BaseClass(BaseProtocolStruct)
function CSCrossRandActivityRequest:__init()
	self.msg_type = 8895
end

function CSCrossRandActivityRequest:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.activity_type)
	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
	MsgAdapter.WriteInt(self.param_3)
end

--跨服随机活动
SCCrossRandActivityStatus = SCCrossRandActivityStatus or BaseClass(BaseProtocolStruct)
function SCCrossRandActivityStatus:__init()
	self.msg_type = 8896
end

function SCCrossRandActivityStatus:Decode()
	self.activity_type = MsgAdapter.ReadShort()
	self.status = MsgAdapter.ReadShort()
	self.begin_time = MsgAdapter.ReadUInt()
	self.end_time = MsgAdapter.ReadUInt()
end

-- 活动期间玩家充值信息
SCCrossRAChongzhiRankChongzhiInfo = SCCrossRAChongzhiRankChongzhiInfo  or BaseClass(BaseProtocolStruct)
function SCCrossRAChongzhiRankChongzhiInfo:__init()
	self.msg_type = 8897
end

function SCCrossRAChongzhiRankChongzhiInfo:Decode()
	self.total_chongzhi = MsgAdapter.ReadUInt()
end


