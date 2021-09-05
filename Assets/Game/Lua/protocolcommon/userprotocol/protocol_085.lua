-------------------------- 推图副本 --------------------------
--请求
CSTuituFbOperaReq = CSTuituFbOperaReq or BaseClass(BaseProtocolStruct)
function CSTuituFbOperaReq:__init()
	self.msg_type = 8430
	self.opera_type = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
end

function CSTuituFbOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opera_type)							--请求信息
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
	MsgAdapter.WriteInt(self.param_3)
end

--推图副本信息
SCTuituFbInfo = SCTuituFbInfo or BaseClass(BaseProtocolStruct)
function SCTuituFbInfo:__init()
	self.msg_type = 8431
end

function SCTuituFbInfo:Decode()
	self.fb_info_list = {}											--副本信息， 数组长度2
	for i = 1, 2 do
		local one_vo = {}
		one_vo.pass_chapter = MsgAdapter.ReadShort() + 1			--已通过最大章节
		one_vo.pass_level = MsgAdapter.ReadShort() + 1				--已通过最大关卡等级
		one_vo.today_join_times = MsgAdapter.ReadShort()			--今日进入次数
		one_vo.buy_join_times = MsgAdapter.ReadShort()				--购买次数
		one_vo.chapter_info_list = {}								--章节列表，数组长度50

		for j = 1, 50 do
			local chatper_info = {}
			chatper_info.is_pass_chapter = MsgAdapter.ReadChar()	--是否章节通关(一章里面所有关卡通关)
			MsgAdapter.ReadChar()
			MsgAdapter.ReadShort()
			chatper_info.total_star = MsgAdapter.ReadShort()		--章节总星数
			chatper_info.star_reward_flag = MsgAdapter.ReadShort()	--章节星数奖励拿取标记，按位与
			chatper_info.level_info_list = {}						--关卡列表，数组大小20
			for k = 1 , 20 do
				local level_info = {}
				level_info.pass_star = MsgAdapter.ReadChar()		--关卡通关星数
				level_info.reward_flag = MsgAdapter.ReadChar()		--关卡奖励拿取标记（0或1）
				MsgAdapter.ReadShort()
				chatper_info.level_info_list[k] = level_info
			end
			one_vo.chapter_info_list[j] = chatper_info
		end
		self.fb_info_list[i] = one_vo
	end
	-- print_error(self.fb_info_list[1].pass_chapter, self.fb_info_list[1].pass_level, self.fb_info_list[1].chapter_info_list[3].level_info_list)
end

SCTuituFbResultInfo = SCTuituFbResultInfo or BaseClass(BaseProtocolStruct)
function SCTuituFbResultInfo:__init()
	self.msg_type = 8432
end

function SCTuituFbResultInfo:Decode()
	self.star = MsgAdapter.ReadChar()				-- 通关星级 star > 0则成功 否则失败
	MsgAdapter.ReadChar()
	self.item_count = MsgAdapter.ReadShort()
	self.reward_item_list = {}
	for i = 1, self.item_count do
		local vo = {}
		vo.item_id = MsgAdapter.ReadUShort()
		vo.num = MsgAdapter.ReadShort()
		vo.is_bind = MsgAdapter.ReadChar()
		MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()
		self.reward_item_list[i] = vo
	end
end

SCTuituFbSingleInfo = SCTuituFbSingleInfo or BaseClass(BaseProtocolStruct)
function SCTuituFbSingleInfo:__init()
	self.msg_type = 8433
end

function SCTuituFbSingleInfo:Decode()
	self.fb_type = MsgAdapter.ReadShort()						-- 副本类型
	self.chatper = MsgAdapter.ReadChar()					    -- 副本章节
	self.level = MsgAdapter.ReadChar()				    		-- 副本关卡等级
	self.cur_chapter = MsgAdapter.ReadShort()					-- 当前进行章节
	self.cur_level = MsgAdapter.ReadShort()						-- 当前进行关卡等级
	self.today_join_times = MsgAdapter.ReadShort()				-- 今日进入副本次数
	self.buy_join_times = MsgAdapter.ReadShort()				-- 购买次数
	self.total_star = MsgAdapter.ReadShort()			        -- 章节总星数
	self.star_reward_flag = MsgAdapter.ReadShort()		        -- 章节星数奖励标记
	self.layer_info = {}										-- 关卡信息
	self.layer_info.pass_star = MsgAdapter.ReadChar()
	self.layer_info.reward_flag = MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
	-- print_error(self.total_star, self.buy_join_times, self.star_reward_flag)
end

--新装备本信息返回
SCNeqFBInfo = SCNeqFBInfo or BaseClass(BaseProtocolStruct)
function SCNeqFBInfo:__init()
	self.msg_type = 8501
end

function SCNeqFBInfo:Decode()
	local NEQFB_MAX_LEVEL_PER_CHAPTER = 8
	local NEQFB_MAX_CHAPTER = 24								-- 章列表 24

	self.info_type = MsgAdapter.ReadShort()
	self.reverse_sh = MsgAdapter.ReadShort()
	self.neqfb_score = MsgAdapter.ReadInt()						-- 积分
	self.today_buy_times = MsgAdapter.ReadShort()				-- 今日购买次数(已更改位保留字段)
	self.today_fight_all_times = MsgAdapter.ReadShort()			-- 今天战斗次数
	self.today_vip_buy_times = MsgAdapter.ReadShort()			-- vip购买次数
	self.today_item_buy_times = MsgAdapter.ReadShort()			-- 物品购买次数
	self.chapter_list = {}
	for i = 1, NEQFB_MAX_CHAPTER do
		local vo = {}
		vo.index = i
		vo.reward_flag = MsgAdapter.ReadChar()					-- 奖励标记 flag & reward_seq != 0 表示领过此奖励
		MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()
		vo.level_list = {}
		self.chapter_list[i] = vo
		for j = 1, NEQFB_MAX_LEVEL_PER_CHAPTER do
			local lev_vo = {}
			lev_vo.index = j
			lev_vo.times_used = MsgAdapter.ReadChar()
			lev_vo.max_star = MsgAdapter.ReadChar()				-- 本关卡最大星数
			MsgAdapter.ReadShort()
			vo.level_list[j] = lev_vo
		end
	end
end

--新装备本通关信息
SCNeqPass = SCNeqPass or BaseClass(BaseProtocolStruct)
function SCNeqPass:__init()
	self.msg_type = 8502
end

function SCNeqPass:Decode()
	self.pass_result = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.pass_sec = MsgAdapter.ReadInt()
	self.pass_star = MsgAdapter.ReadShort()
	self.reward_score = MsgAdapter.ReadShort()
end

SCNeqRollPool = SCNeqRollPool or BaseClass(BaseProtocolStruct)
function SCNeqRollPool:__init()
	self.msg_type = 8503
end

function SCNeqRollPool:Decode()
	self.roll_item_list = {}
	for i = 1, COMMON_CONSTS.NEQFB_ROLLPOOL_TOTAL_COUNT do
		self.roll_item_list[i] = {}
		self.roll_item_list[i].item_id = MsgAdapter.ReadUShort()
		self.roll_item_list[i].is_bind = MsgAdapter.ReadChar()
		self.roll_item_list[i].num = MsgAdapter.ReadChar()
	end
end

--翻牌信息
SCNeqRollInfo = SCNeqRollInfo or BaseClass(BaseProtocolStruct)
function SCNeqRollInfo:__init()
	self.msg_type = 8504
end

function SCNeqRollInfo:Decode()
	self.reason = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.max_free_roll_times = MsgAdapter.ReadChar()
	self.free_roll_times = MsgAdapter.ReadChar()
	self.gold_roll_times = MsgAdapter.ReadChar()
	self.hit_seq = MsgAdapter.ReadChar()
end

--新装备本请求领奖
CSNeqFBStarRewardReq = CSNeqFBStarRewardReq or BaseClass(BaseProtocolStruct)
function CSNeqFBStarRewardReq:__init()
	self.msg_type = 8511

	self.chapter = 0
	self.seq = 0
end

function CSNeqFBStarRewardReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.chapter)
	MsgAdapter.WriteShort(self.seq)
end

--新装备本请求兑换
CSNeqFBExchangeReq = CSNeqFBExchangeReq or BaseClass(BaseProtocolStruct)
function CSNeqFBExchangeReq:__init()
	self.msg_type = 8512

	self.item_id = 0
end

function CSNeqFBExchangeReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.item_id)
end

--新装备本请求购买次数
CSNeqFBBuyTimesReq = CSNeqFBBuyTimesReq or BaseClass(BaseProtocolStruct)
function CSNeqFBBuyTimesReq:__init()
	self.msg_type = 8513
end

function CSNeqFBBuyTimesReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--新装备本请求扫荡
CSNeqFBAutoReq = CSNeqFBAutoReq or BaseClass(BaseProtocolStruct)
function CSNeqFBAutoReq:__init()
	self.msg_type = 8514

	self.chapter = 0
	self.level = 0
end

function CSNeqFBAutoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.chapter)
	MsgAdapter.WriteShort(self.level)
end

--查询新装备本关卡信息
CSNeqInfoReq = CSNeqInfoReq or BaseClass(BaseProtocolStruct)
function CSNeqInfoReq:__init()
	self.msg_type = 8515
end

function CSNeqInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--请求翻牌
CSNeqRollReq = CSNeqRollReq or BaseClass(BaseProtocolStruct)
function CSNeqRollReq:__init()
	self.msg_type = 8516
	self.end_roll = 0
end

function CSNeqRollReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.end_roll)
	MsgAdapter.WriteShort(0)
end

-------------------------boss掉落日志-------------------------------
--请求日志信息
CSGetDropLog = CSGetDropLog or BaseClass(BaseProtocolStruct)
function CSGetDropLog:__init()
	self.msg_type = 8521
	self.type = 0
end

function CSGetDropLog:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.type)
	MsgAdapter.WriteShort(self.param)
end

--日志信息返回
SCDropLogRet = SCDropLogRet or BaseClass(BaseProtocolStruct)
function SCDropLogRet:__init()
	self.msg_type = 8522
end

function SCDropLogRet:Decode()
	self.type = MsgAdapter.ReadUShort()
	local count = MsgAdapter.ReadUShort()

	self.log_list = {}
	for i = 1, count do
		local log_info = {}
		log_info.uid = MsgAdapter.ReadInt()
		log_info.role_name = MsgAdapter.ReadStrN(32)
		log_info.monster_id = MsgAdapter.ReadInt()
		log_info.item_id = MsgAdapter.ReadUShort()
		log_info.item_num = MsgAdapter.ReadShort()
		log_info.timestamp = MsgAdapter.ReadUInt()
		log_info.scene_id = MsgAdapter.ReadInt()
		log_info.color = MsgAdapter.ReadShort()
		log_info.reserve_sh = MsgAdapter.ReadShort()
		log_info.xianpin_type_list = {}
		for i = 1, COMMON_CONSTS.XIANPIN_MAX_NUM do
			local xianpin_type = MsgAdapter.ReadUShort()
			if xianpin_type > 0 then
				table.insert(log_info.xianpin_type_list, xianpin_type)
			end
		end
		log_info.is_cross = 0
		table.insert(self.log_list, 1, log_info)
	end
end

---------------------防具材料副本-------------------------------------
CSArmorDefendRoleReq = CSArmorDefendRoleReq or BaseClass(BaseProtocolStruct)
function CSArmorDefendRoleReq:__init()
	self.msg_type = 8535
	self.req_type = 0
	self.parm1 = 0
end

function CSArmorDefendRoleReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.req_type)
	MsgAdapter.WriteShort(self.parm1)
end

SCArmorDefendRoleInfo = SCArmorDefendRoleInfo or BaseClass(BaseProtocolStruct)
function SCArmorDefendRoleInfo:__init()
	self.msg_type = 8536
end

function SCArmorDefendRoleInfo:Decode()
	self.personal_join_times = MsgAdapter.ReadChar()
	self.personal_buy_join_times = MsgAdapter.ReadChar()
	self.personal_max_pass_level = MsgAdapter.ReadChar()
	self.personal_auto_fb_free_times = MsgAdapter.ReadChar()
	self.personal_item_buy_join_times = MsgAdapter.ReadShort()
	self.reserve_sh = MsgAdapter.ReadShort()
end

SCArmorDefendResult = SCArmorDefendResult or BaseClass(BaseProtocolStruct)
function SCArmorDefendResult:__init()
	self.msg_type = 8537
end

function SCArmorDefendResult:Decode()
	self.is_passed = MsgAdapter.ReadChar()
	self.clear_wave_count = MsgAdapter.ReadChar()
	self.use_time = MsgAdapter.ReadShort()
	self.get_coin = MsgAdapter.ReadInt()
	self.get_item_count = MsgAdapter.ReadInt()
	self.item_list = {}
	for i = 1, self.get_item_count do
		self.item_list[i] = {}
		self.item_list[i].num = MsgAdapter.ReadShort()
		self.item_list[i].item_id = MsgAdapter.ReadUShort()
	end
end

SCArmorDefendInfo = SCArmorDefendInfo or BaseClass(BaseProtocolStruct)
function SCArmorDefendInfo:__init()
	self.msg_type = 8538
end

function SCArmorDefendInfo:Decode()
	self.reason = MsgAdapter.ReadShort()
	self.reserve_ch = MsgAdapter.ReadShort()
	self.escape_monster_count = MsgAdapter.ReadInt()		--逃跑数
	self.curr_wave = MsgAdapter.ReadShort()					--当前波
	self.energy = MsgAdapter.ReadShort()					--能量
	self.next_wave_refresh_time = MsgAdapter.ReadInt()		--下一波到来时间
	self.clear_wave_count = MsgAdapter.ReadShort()			--清理怪物波数
	self.refresh_when_clear = MsgAdapter.ReadShort()
end

SCArmorDefendWarning = SCArmorDefendWarning or BaseClass(BaseProtocolStruct)
function SCArmorDefendWarning:__init()
	self.msg_type = 8539
end

function SCArmorDefendWarning:Decode()
	self.escape_num = MsgAdapter.ReadShort()
	self.reserve_ch = MsgAdapter.ReadShort()
end

SCArmorDefendPerformSkill = SCArmorDefendPerformSkill or BaseClass(BaseProtocolStruct)
function SCArmorDefendPerformSkill:__init()
	self.msg_type = 8540
end

function SCArmorDefendPerformSkill:Decode()
	self.skill_index = MsgAdapter.ReadInt()
	self.next_time_list = {}
	for i = 1, 2 do
		self.next_time_list[i] = MsgAdapter.ReadUInt()
	end
end

--------------------- 上古遗迹 -----------------------------------------
CSShangGuBossEnterReq = CSShangGuBossEnterReq or BaseClass(BaseProtocolStruct)
function CSShangGuBossEnterReq:__init()
	self.msg_type = 8545
	self.opera_type = 0
	self.param1 = 0
	self.param2 = 0
	self.param3 = 0
end

function CSShangGuBossEnterReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(self.param1)
	MsgAdapter.WriteShort(self.param2)
	MsgAdapter.WriteShort(self.param3)
end

SCShangGuBossAllInfo = SCShangGuBossAllInfo or BaseClass(BaseProtocolStruct)
function SCShangGuBossAllInfo:__init()
	self.msg_type = 8546
end

function SCShangGuBossAllInfo:Decode()
	self.tire_value = MsgAdapter.ReadInt()
	self.enter_times = MsgAdapter.ReadShort()
	self.layer_list = {}
	self.layer_list.layer_count = MsgAdapter.ReadShort()
	for i = 1, self.layer_list.layer_count do
		local layer_vo = {}
		MsgAdapter.ReadShort()
		layer_vo.boss_count = MsgAdapter.ReadShort()
		layer_vo.boss_info_list = {}
		for j = 1, layer_vo.boss_count do
			local boss_vo = {}
			boss_vo.boss_id = MsgAdapter.ReadInt()
			boss_vo.next_refresh_time = MsgAdapter.ReadUInt()
			boss_vo.is_concern = MsgAdapter.ReadChar()
			MsgAdapter.ReadChar()
			MsgAdapter.ReadShort()
			layer_vo.boss_info_list[j] = boss_vo
		end
		MsgAdapter.ReadStrN(12 * (10 - layer_vo.boss_count))
		self.layer_list[i] = layer_vo
	end
end

SCShangGuBossLayerInfo = SCShangGuBossLayerInfo or BaseClass(BaseProtocolStruct)
function SCShangGuBossLayerInfo:__init()
	self.msg_type = 8547
end

function SCShangGuBossLayerInfo:Decode()
	self.cur_layer = MsgAdapter.ReadShort()
	local boss_count = MsgAdapter.ReadShort()
	self.boss_info_list = {}
	for i = 1, boss_count do
		local boss_vo = {}
		boss_vo.boss_id = MsgAdapter.ReadInt()
		boss_vo.next_refresh_time = MsgAdapter.ReadUInt()
		boss_vo.is_concern = MsgAdapter.ReadChar()
		MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()
		self.boss_info_list[i] = boss_vo
	end
end

SCShangGuBossSceneInfo = SCShangGuBossSceneInfo or BaseClass(BaseProtocolStruct)
function SCShangGuBossSceneInfo:__init()
	self.msg_type = 8548
end

function SCShangGuBossSceneInfo:Decode()
	self.angry_value = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.kick_out_time = MsgAdapter.ReadUInt()
end

SCShangGuBossSceneOtherInfo = SCShangGuBossSceneOtherInfo or BaseClass(BaseProtocolStruct)
function SCShangGuBossSceneOtherInfo:__init()
	self.msg_type = 8549
end

function SCShangGuBossSceneOtherInfo:Decode()
	local layer_count = MsgAdapter.ReadInt()
	self.layer_info_list = {}
	for i = 1, layer_count do
		local vo = {}
		vo.gold_monster_num = MsgAdapter.ReadShort()
		vo.hide_boss_num = MsgAdapter.ReadShort()
		vo.max_boss_num = MsgAdapter.ReadShort()
		vo.min_boss_num = MsgAdapter.ReadShort()
		self.layer_info_list[i] = vo
	end
end

----------------- 宝宝Boss相关协议 ------------------------------------------------------
-- 请求信息协议
CSBabyBossOperate = CSBabyBossOperate or BaseClass(BaseProtocolStruct)
function CSBabyBossOperate:__init()
	self.msg_type = 8525
	self.operate_type = 0
	self.param_0 = 0
end

function CSBabyBossOperate:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.operate_type)
	MsgAdapter.WriteInt(self.param_0)
	MsgAdapter.WriteUShort(self.param_1)
	MsgAdapter.WriteShort(self.reserve_sh)
end

-- 宝宝Boss人物信息
SCBabyBossRoleInfo = SCBabyBossRoleInfo or BaseClass(BaseProtocolStruct)
function SCBabyBossRoleInfo:__init()
	self.msg_type = 8526
end

function SCBabyBossRoleInfo:Decode()
	self.enter_times = MsgAdapter.ReadShort()	 --进入次数
	self.angry_value = MsgAdapter.ReadShort()	 --愤怒值
	self.kick_time = MsgAdapter.ReadUInt()		 -- 踢出时间
end

-- 宝宝Boss信息
SCAllBabyBossInfo = SCAllBabyBossInfo or BaseClass(BaseProtocolStruct)
function SCAllBabyBossInfo:__init()
	self.msg_type = 8527
end

function SCAllBabyBossInfo:Decode()
	self.boss_count = MsgAdapter.ReadInt()
	self.boss_info_list = {}
	for i = 1, self.boss_count do
		local boss_info = {}
		boss_info.scene_id = MsgAdapter.ReadShort()
		boss_info.boss_id = MsgAdapter.ReadUShort()
		boss_info.next_refresh_time = MsgAdapter.ReadUInt()
		local killer_info = {}
		for j = 1, GameEnum.BABY_BOSS_KILLER_MAX_COUNT do
			local temp_killer_info = {}
			temp_killer_info.killer_uid = MsgAdapter.ReadInt()
			temp_killer_info.killier_time = MsgAdapter.ReadUInt()
			temp_killer_info.killer_name = MsgAdapter.ReadStrN(32)
			table.insert( killer_info, temp_killer_info )
		end
		boss_info.killer_info = killer_info
		self.boss_info_list[i] = boss_info
	end
end

-- 宝宝Boss信息(单个)
SCSingleBabyBossInfo = SCSingleBabyBossInfo or BaseClass(BaseProtocolStruct)
function SCSingleBabyBossInfo:__init()
	self.msg_type = 8528
end

function SCSingleBabyBossInfo:Decode()
	self.boss_info = {}
	self.boss_info.scene_id = MsgAdapter.ReadShort()
	self.boss_info.boss_id = MsgAdapter.ReadUShort()
	self.boss_info.next_refresh_time = MsgAdapter.ReadUInt()
	local killer_info = {}
	for i = 1, GameEnum.BABY_BOSS_KILLER_MAX_COUNT do
		local temp_killer_info = {}
		temp_killer_info.killer_uid = MsgAdapter.ReadInt()
		temp_killer_info.killier_time = MsgAdapter.ReadUInt()
		temp_killer_info.killer_name = MsgAdapter.ReadStrN(32)
		table.insert( killer_info, temp_killer_info )
	end
	self.boss_info.killer_info = killer_info
end
----------------- 宝宝Boss End----------------------------------------------------------

------------------------- 塔防副本 ----------------------------------
-- 塔防副本请求
CSBuildTowerReq = CSBuildTowerReq or BaseClass(BaseProtocolStruct)
function CSBuildTowerReq:__init()
	self.msg_type = 8570
	self.operate_type = 0
	self.param1 = 0
	self.param2 = 0
end

function CSBuildTowerReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.operate_type)
	MsgAdapter.WriteShort(self.param1)
	MsgAdapter.WriteShort(self.param2)
end

--塔防副本信息返回
SCBuildTowerFBSceneLogicInfo = SCBuildTowerFBSceneLogicInfo or BaseClass(BaseProtocolStruct)
function SCBuildTowerFBSceneLogicInfo:__init()
	self.msg_type = 8571
	self.data = {}
end

function SCBuildTowerFBSceneLogicInfo:Decode()
	self.data.notify_reason = MsgAdapter.ReadChar()
	self.data.is_finish = MsgAdapter.ReadChar()
	self.data.is_pass = MsgAdapter.ReadChar()
	self.data.can_call_extra_monster = MsgAdapter.ReadChar()

	self.data.time_out_timestamp = MsgAdapter.ReadUInt()
	self.data.exp = MsgAdapter.ReadLL()
	self.data.douhun = MsgAdapter.ReadInt()
	self.data.cur_wave = MsgAdapter.ReadShort()
	self.data.escape_monster_count = MsgAdapter.ReadShort()
	self.data.next_wave_timestamp = MsgAdapter.ReadUInt()
	self.data.notify_next_wave_timestamp = MsgAdapter.ReadShort()
	self.data.item_count = MsgAdapter.ReadShort()
	self.data.special_monster_num = MsgAdapter.ReadInt()
	self.data.remain_buyable_monster_num = MsgAdapter.ReadInt()

	self.data.tower_info_list = {}
	for i = 0 , GameEnum.BUILD_TOWER_MAX_TOWER_POS_INDEX do
		self.data.tower_info_list[i] = {}
		self.data.tower_info_list[i].tower_type = MsgAdapter.ReadShort()
		self.data.tower_info_list[i].tower_level = MsgAdapter.ReadShort()
	end

	self.data.item_list = {}
	for i = 1, self.data.item_count do
		self.data.item_list[i] = {}
		self.data.item_list[i].item_id = MsgAdapter.ReadUShort()
		self.data.item_list[i].num = MsgAdapter.ReadShort()
	end
end

CSBuildTowerBuyTimes = CSBuildTowerBuyTimes or BaseClass(BaseProtocolStruct)
function CSBuildTowerBuyTimes:__init()
	self.msg_type = 8572
end

function CSBuildTowerBuyTimes:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--------------------------------组队守护-----------------------------------
-- 组队副本个人信息
SCTeamFBUserInfo = SCTeamFBUserInfo or BaseClass(BaseProtocolStruct)
function SCTeamFBUserInfo:__init()
		self.msg_type = 5444
end

function SCTeamFBUserInfo:Decode()
	self.team_tower_defend_fb_is_first = MsgAdapter.ReadChar()     -- 是否第一次组队塔防
	self.team_yaoshoujitan_fb_is_first = MsgAdapter.ReadChar()    -- 是否第一次组队妖兽祭坛
	self.team_equip_fb_is_first = MsgAdapter.ReadChar()      -- 是否第一次组精英须臾
end

-- 组队塔防信息
SCTeamTowerDefendInfo = SCTeamTowerDefendInfo or BaseClass(BaseProtocolStruct)

function SCTeamTowerDefendInfo:__init()
	self.msg_type = 8580
	self.reason = 0
	self.life_tower_left_hp = 0
	self.life_tower_left_maxhp = 0
	self.gongji_uid = 0
	self.fangyu_uid = 0
	self.assist_uid = 0
	self.curr_wave = 0
	self.next_wave_refresh_time = 0
	self.score = 0
	self.exp = 0
	self.clear_wave = 0
	self.skill_list = {}
end

function SCTeamTowerDefendInfo:Decode()
	local MAX_SKILL_COUNT = 4
	self.reason = MsgAdapter.ReadInt()
	self.life_tower_left_hp = MsgAdapter.ReadLL()
	self.life_tower_left_maxhp = MsgAdapter.ReadLL()
	self.gongji_uid = MsgAdapter.ReadInt()
	self.fangyu_uid = MsgAdapter.ReadInt()
	self.assist_uid = MsgAdapter.ReadInt()
	self.curr_wave = MsgAdapter.ReadInt()
	self.next_wave_refresh_time = MsgAdapter.ReadInt()
	self.score = MsgAdapter.ReadInt()
	self.exp = MsgAdapter.ReadInt()
	self.clear_wave = MsgAdapter.ReadInt()
	self.skill_list = {}
	for i = 1, MAX_SKILL_COUNT do
		self.skill_list[i] = {}
		self.skill_list[i].skill_id = MsgAdapter.ReadUShort()
		self.skill_list[i].skill_level = MsgAdapter.ReadShort()
		self.skill_list[i].last_perform_time = MsgAdapter.ReadUInt()
	end
end

-- 加成属性
SCTeamTowerDefendAttrType = SCTeamTowerDefendAttrType or BaseClass(BaseProtocolStruct)
function SCTeamTowerDefendAttrType:__init()
	self.msg_type = 8581
end

function SCTeamTowerDefendAttrType:Decode()
	self.team_attr_list = {}
	for i = 1, 3 do
		self.team_attr_list[i] = {}
		self.team_attr_list[i].uid = MsgAdapter.ReadInt()
		self.team_attr_list[i].attr_type = MsgAdapter.ReadInt()
	end
end

-- 塔防技能CD
SCTeamTowerDefendSkill = SCTeamTowerDefendSkill or BaseClass(BaseProtocolStruct)
function SCTeamTowerDefendSkill:__init()
	self.msg_type = 8582
	self.skill_index = 0
	self.skill_level = 0
	self.perform_time = 0
end

function SCTeamTowerDefendSkill:Decode()
	self.skill_index = MsgAdapter.ReadUShort()
	self.skill_level = MsgAdapter.ReadShort()
	self.perform_time = MsgAdapter.ReadUInt()
end

-- 设置防御塔加成属性
CSTeamTowerDefendOpreatReq = CSTeamTowerDefendOpreatReq or BaseClass(BaseProtocolStruct)
function CSTeamTowerDefendOpreatReq:__init()
	self.msg_type = 8583
	self.req_type = 0
	self.param1 = 0
	self.param2 = 0
end

function CSTeamTowerDefendOpreatReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.req_type)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
end

--组队守护血量
SCTeamTowerDefendAllRole = SCTeamTowerDefendAllRole or BaseClass(BaseProtocolStruct)
function SCTeamTowerDefendAllRole:__init()
	self.msg_type = 8584
end

function SCTeamTowerDefendAllRole:Decode()
	self.role_count = MsgAdapter.ReadInt()					-- 队伍人员数量
	self.team_list = {}
	for i = 1, self.role_count do
		local temp_list ={}
		temp_list.uid = MsgAdapter.ReadInt()
		temp_list.user_name = MsgAdapter.ReadStrN(32)
		temp_list.hp_low = MsgAdapter.ReadUInt()
		temp_list.hp_high = MsgAdapter.ReadUInt()
		temp_list.hp = temp_list.hp_low + (temp_list.hp_high * (2 ^ 32))
		temp_list.max_hp_low = MsgAdapter.ReadUInt()
		temp_list.max_hp_high = MsgAdapter.ReadUInt()
		temp_list.max_hp = temp_list.max_hp_low + (temp_list.max_hp_high * (2 ^ 32))
		temp_list.attr_type = MsgAdapter.ReadChar()
		temp_list.buff_count = MsgAdapter.ReadChar()
		temp_list.buff = {}
		for i = 1, 6 do
			temp_list.buff[i] = MsgAdapter.ReadChar()
		end
		table.insert(self.team_list, temp_list)
	end
end

SCTeamTowerDefendResult = SCTeamTowerDefendResult or BaseClass(BaseProtocolStruct)
function SCTeamTowerDefendResult:__init()
	self.msg_type = 8585
end

function SCTeamTowerDefendResult:Decode()
	self.is_passed = MsgAdapter.ReadChar()
	self.clear_wave_count = MsgAdapter.ReadChar()
	self.use_time = MsgAdapter.ReadShort()
	self.xiannv_shengwu = MsgAdapter.ReadInt()
	self.item_count = MsgAdapter.ReadInt()
	self.item_list = {}
	for i = 1, self.item_count do
		local item_data = {}
		item_data.item_id = MsgAdapter.ReadUShort()
		item_data.num = MsgAdapter.ReadShort()
		table.insert(self.item_list, item_data)
	end
end

--------------------------------乱斗战场-----------------------------------
-- 乱斗战场人物信息
SCMessBattleRoleInfo = SCMessBattleRoleInfo or BaseClass(BaseProtocolStruct)
function SCMessBattleRoleInfo:__init()
	self.msg_type = 8560
	self.is_finish = 0
end

function SCMessBattleRoleInfo:Decode()
	self.turn = MsgAdapter.ReadInt()					-- 第几轮
	self.score = MsgAdapter.ReadInt()					-- 积分
	self.rank = MsgAdapter.ReadInt()					-- 排行
	self.total_score = MsgAdapter.ReadInt()
	self.total_rank = MsgAdapter.ReadInt()
	self.boss_hp_per = MsgAdapter.ReadInt()				-- boss血量百分比
	self.next_redistribute_time = MsgAdapter.ReadUInt()	--下次发奖励 并 重新分配时间戳
	self.next_get_score_time = MsgAdapter.ReadUInt()	--下次获取积分时间戳
	self.next_update_rank_time = MsgAdapter.ReadUInt()	--下次更新排行时间戳
	self.kick_out_time = MsgAdapter.ReadUInt()			-- 延迟踢出时间
	self.is_finish = MsgAdapter.ReadInt()
	self.boss_max_hp = MsgAdapter.ReadLL()				-- Boss最大血量
	self.boss_cur_hp = MsgAdapter.ReadLL()				-- Boss当前血量
end

-- 乱斗战场进入请求
CSMessBattleEnterReq = CSMessBattleEnterReq or BaseClass(BaseProtocolStruct)
function CSMessBattleEnterReq:__init()
	self.msg_type = 8561
end

function CSMessBattleEnterReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 乱斗战场积分排行信息
SCMessBattleRankInfo = SCMessBattleRankInfo or BaseClass(BaseProtocolStruct)
function SCMessBattleRankInfo:__init()
	self.msg_type = 8562
end

function SCMessBattleRankInfo:Decode()
	self.rank_count = MsgAdapter.ReadInt()
	self.rank_info_list = {}
	for i = 1, self.rank_count do
		local data = {}
		data.score = MsgAdapter.ReadInt()
		data.user_name = MsgAdapter.ReadStrN(32)
		data.user_key = MsgAdapter.ReadLL()
		table.insert(self.rank_info_list, data)
	end
end

-- 乱斗战场奖励信息
SCMessBattleReward = SCMessBattleReward or BaseClass(BaseProtocolStruct)
function SCMessBattleReward:__init()
	self.msg_type = 8563
	self.item_id_list = {}
end

function SCMessBattleReward:Decode()
	for i = 0, GameEnum.MAX_RANK_COUNT - 1 do
		self.item_id_list[i] = MsgAdapter.ReadInt()
	end
end

-- 乱斗战场伤害排行信息
SCMessBattleHurtRankInfo = SCMessBattleHurtRankInfo or BaseClass(BaseProtocolStruct)
function SCMessBattleHurtRankInfo:__init()
	self.msg_type = 8564
end

function SCMessBattleHurtRankInfo:Decode()
	self.rank_count = MsgAdapter.ReadInt()
	self.rank_info_list = {}
	for i = 1, self.rank_count do
		local data = {}
		data.hurt_per = MsgAdapter.ReadInt()
		data.user_name = MsgAdapter.ReadStrN(32)
		data.user_key = MsgAdapter.ReadLL()
		table.insert(self.rank_info_list, data)
	end
end

-- 乱斗战场人员积分信息
SCMessBattleAllRoleScoreInfo = SCMessBattleAllRoleScoreInfo or BaseClass(BaseProtocolStruct)
function SCMessBattleAllRoleScoreInfo:__init()
	self.msg_type = 8565
end

function SCMessBattleAllRoleScoreInfo:Decode()
	self.role_count = MsgAdapter.ReadInt()
	self.role_info_list = {}
	for i = 1, self.role_count do
		local data = {}
		data.obj_id = MsgAdapter.ReadUShort()
		data.score = MsgAdapter.ReadShort()
		table.insert(self.role_info_list, data)
	end
end

-- 乱斗战场总积分排行榜
SCMessBattleToalScoreRank = SCMessBattleToalScoreRank or BaseClass(BaseProtocolStruct)
function SCMessBattleToalScoreRank:__init()
	self.msg_type = 8566
end

function SCMessBattleToalScoreRank:Decode()
	self.role_count = MsgAdapter.ReadInt()
	self.role_info_list = {}
	for i = 1, self.role_count do
		local data = {}
		data.total_score = MsgAdapter.ReadInt()
		data.user_name = MsgAdapter.ReadStrN(32)
		data.user_key = MsgAdapter.ReadLL()
		table.insert(self.role_info_list, data)
	end
end



-------------------------------跨服猎鲲地带场景信息---------------------------
-- 跨服猎鲲地带场景信息
SCCrossLieKunFBSceneInfo = SCCrossLieKunFBSceneInfo or BaseClass(BaseProtocolStruct)
function SCCrossLieKunFBSceneInfo:__init()
	self.msg_type = 8575
	self.is_main_live_flag = 0
	self.boss_list = {}
	self.guild_id = {}
	self.boss_next_flush_timestamp = {}
end

function SCCrossLieKunFBSceneInfo:Decode()

	self.zone = MsgAdapter.ReadShort()				-- 区域

	MsgAdapter.ReadShort()
	self.boss_list = {}								-- 区域BOSSid刷新
	for i = 1, GameEnum.LIEKUN_BOSS_TYPE_COUNT do
		self.boss_list[i] = {}
		self.boss_list[i].index = i
		self.boss_list[i].boss_id = MsgAdapter.ReadInt()
		self.boss_list[i].boss_obj_id = MsgAdapter.ReadUShort()
		MsgAdapter.ReadShort()
	end

	self.guild_id = {}								-- 猎鲲BOSS击杀归属帮派id
	for i = 1, GameEnum.LIEKUN_BOSS_TYPE_COUNT do
		self.guild_id[i] = MsgAdapter.ReadInt()
	end

	self.boss_next_flush_timestamp = {} 			-- boss下次刷新时间
	for i = 1, GameEnum.LIEKUN_BOSS_TYPE_COUNT do
		self.boss_next_flush_timestamp[i] = MsgAdapter.ReadUInt()
	end

end

-- 跨服猎鲲地带帮派传闻信息
SCCrossLieKunFBGuildMsgInfo = SCCrossLieKunFBGuildMsgInfo or BaseClass(BaseProtocolStruct)
function SCCrossLieKunFBGuildMsgInfo:__init()
	self.msg_type = 8576
	self.zone = 0 							-- 区域
	self.is_main_live_flag = 0 				-- 主boss存活标记
end

function SCCrossLieKunFBGuildMsgInfo:Decode()
	self.zone = MsgAdapter.ReadShort()
	self.is_main_live_flag =  MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
end

-------------------------------跨服猎鲲地带场景信息----------END--------------

-- 请求神兵和宝甲操作类型
CSShenqiOperaReq = CSShenqiOperaReq or BaseClass(BaseProtocolStruct)
function CSShenqiOperaReq:__init()
	self.msg_type = 8586
end

function CSShenqiOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.opera_type)
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
	MsgAdapter.WriteInt(self.param_3)
end


-- 返回神器所有信息
SCShenqiAllInfo = SCShenqiAllInfo or BaseClass(BaseProtocolStruct)
function SCShenqiAllInfo:__init()
	self.msg_type = 8587
end

function SCShenqiAllInfo:Decode()
	self.shenbing_image_flag_low = MsgAdapter.ReadUInt() or 0			-- 神兵形象激活标记
	self.shenbing_image_flag_high = MsgAdapter.ReadUInt() or 0			-- 神兵形象激活标记
	self.shenbing_texiao_flag_low = MsgAdapter.ReadUInt() or 0			-- 神兵特效激活标记
	self.shenbing_texiao_flag_high = MsgAdapter.ReadUInt() or 0			-- 神兵特效激活标记
	self.baojia_image_flag_low = MsgAdapter.ReadUInt() or 0			-- 宝甲形象激活标记
	self.baojia_image_flag_high = MsgAdapter.ReadUInt() or 0			-- 宝甲形象激活标记
	self.baojia_texiao_flag_low = MsgAdapter.ReadUInt() or 0			-- 宝甲特效激活标记
	self.baojia_texiao_flag_high = MsgAdapter.ReadUInt() or 0		-- 宝甲特效激活标记

	self.shenbing_cur_image_id = MsgAdapter.ReadChar()		-- 当前使用神兵形象id
	self.shenbing_cur_texiao_id = MsgAdapter.ReadChar()		-- 当前使用神兵特效id
	self.baojia_cur_image_id = MsgAdapter.ReadChar()		-- 当前使用宝甲形象id
	self.baojia_cur_texiao_id = MsgAdapter.ReadChar()		-- 当前使用宝甲特效id

	self.shenbing_list = {}									-- 神兵列表
	for i = 0,GameEnum.SHENQI_SUIT_NUM_MAX - 1 do 			-- 对应神兵的下标，总共64种神兵,SHENQI_SUIT_NUM_MAX = 64
		local vo = {}
		vo.level = MsgAdapter.ReadShort()
		MsgAdapter.ReadShort()
		vo.exp = MsgAdapter.ReadInt()

		vo.quality_list = {}								-- 神兵的部位的最大个数
		for j = 1, GameEnum.SHENQI_PART_TYPE_MAX do 	-- SHENQI_PART_TYPE_MAX = 4
			vo.quality_list[j] = MsgAdapter.ReadChar()
		end
		self.shenbing_list[i] = vo
	end
	-- table.remove(self.shenbing_list, 1)		--第一个不需要使用，直接从表内剔除

	self.baojia_list = {}									-- 宝甲列表
	for i = 0, GameEnum.SHENQI_SUIT_NUM_MAX - 1 do
		local vo = {}
		vo.level = MsgAdapter.ReadShort()
		MsgAdapter.ReadShort()
		vo.exp = MsgAdapter.ReadInt()

		vo.quality_list = {}
		for j = 1, GameEnum.SHENQI_PART_TYPE_MAX do
			vo.quality_list[j] = MsgAdapter.ReadChar()
		end
		self.baojia_list[i] = vo
	end
	-- table.remove(self.baojia_list, 1)		--第一个不需要使用，直接从表内剔除
end

-- 返回单个神器信息
SCShenqiSingleInfo = SCShenqiSingleInfo or BaseClass(BaseProtocolStruct)
function SCShenqiSingleInfo:__init()
	self.msg_type = 8588
end

function SCShenqiSingleInfo:Decode()
	self.info_type = MsgAdapter.ReadShort()						-- 神器信息类型
	self.item_index = MsgAdapter.ReadShort()					-- 神器信息对应下标

	self.shenqi_item = {}										-- 神器单个信息
	self.shenqi_item.level = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.shenqi_item.exp = MsgAdapter.ReadInt()
	self.shenqi_item.quality_list = {}

	for i = 1, GameEnum.SHENQI_PART_TYPE_MAX do
		self.shenqi_item.quality_list[i] = MsgAdapter.ReadChar()
	end
end

 -- 神器特效信息
SCShenqiImageInfo = SCShenqiImageInfo or BaseClass(BaseProtocolStruct)
function SCShenqiImageInfo:__init()
	self.msg_type = 8589
end

function SCShenqiImageInfo:Decode()
	self.info_type = MsgAdapter.ReadShort()						-- 神器信息类型
	self.cur_use_imgage_id = MsgAdapter.ReadChar()				-- 当前使用形象id
	self.cur_use_texiao_id = MsgAdapter.ReadChar()				-- 当前使用特效id


	self.image_active_flag_low = MsgAdapter.ReadUInt()				-- 形象激活标记
	self.image_active_flag_high = MsgAdapter.ReadUInt()				-- 形象激活标记

	self.texiao_active_flag_low = MsgAdapter.ReadUInt()				-- 特效激活标记
	self.texiao_active_flag_high = MsgAdapter.ReadUInt()				-- 特效激活标记
	self.texiao_open_flag = MsgAdapter.ReadChar()
end
-- 神器材料分解结果
SCShenqiDecomposeResult = SCShenqiDecomposeResult or BaseClass(BaseProtocolStruct)
function SCShenqiDecomposeResult:__init()
	self.msg_type = 8590
end

function SCShenqiDecomposeResult:Decode()
	self.item_count = MsgAdapter.ReadInt()

	self.item_list = {}
	for i = 1, self.item_count do
		local vo = {}
		vo.item_id = MsgAdapter.ReadInt()
		vo.num = MsgAdapter.ReadShort()
		vo.is_bind = MsgAdapter.ReadChar()
		vo.reserve_ch = MsgAdapter.ReadChar()
		self.item_list[i] = vo
	end
end

-- 名将/变身请求
CSGreateSoldierOpera = CSGreateSoldierOpera or BaseClass(BaseProtocolStruct)
function CSGreateSoldierOpera:__init()
	self.msg_type = 8595
	self.req_type = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
end

function CSGreateSoldierOpera:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	
	MsgAdapter.WriteUShort(self.req_type)
	MsgAdapter.WriteUShort(self.param_1)
	MsgAdapter.WriteUShort(self.param_2)
	MsgAdapter.WriteUShort(self.param_3)
end

-- 名将吞噬强化装备
CSGreateSoldierReqStrength = CSGreateSoldierReqStrength or BaseClass(BaseProtocolStruct)
function CSGreateSoldierReqStrength:__init()
	self.msg_type = 8596
	self.seq = 0			-- 名将seq
	self.equip_index = 0	-- 要强化的装备下标
	self.destroy_num = 0	-- 消耗物品个数
	self.destroy_backpack_index_list = {}	-- 消耗的物品下标列表
end

function CSGreateSoldierReqStrength:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.seq)
	MsgAdapter.WriteShort(self.equip_index)
	MsgAdapter.WriteInt(self.destroy_num)

	for i = 0, self.destroy_num - 1 do
		MsgAdapter.WriteShort(self.destroy_backpack_index_list[i])
	end
end

SCCrossLieKunFBBossHurtInfo = SCCrossLieKunFBBossHurtInfo or BaseClass(BaseProtocolStruct)
function SCCrossLieKunFBBossHurtInfo:__init()
	self.msg_type = 8577
end

function SCCrossLieKunFBBossHurtInfo:Decode()
	self.boss_id = MsgAdapter.ReadInt()
	self.own_guild_rank = MsgAdapter.ReadInt()
	self.own_guild_hurt = MsgAdapter.ReadLL()
	self.count = MsgAdapter.ReadInt()
	self.hurt_list = {}
	for i = 1,self.count do
		local list = {}
		list.guild_id = MsgAdapter.ReadLL()
		list.guild_name = MsgAdapter.ReadStrN(32)
		list.hurt = MsgAdapter.ReadLL()
		table.insert(self.hurt_list, list)
	end
end


