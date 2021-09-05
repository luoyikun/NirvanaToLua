KaifuActivityData = KaifuActivityData or BaseClass()

-- 开服活动操作类型
RA_OPEN_SERVER_OPERA_TYPE = {
	RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO = 0,			-- 请求信息
	RA_OPEN_SERVER_OPERA_TYPE_FETCH = 1,			-- 领取奖励
	RA_OPEN_SERVER_OPERA_TYPE_REQ_BOSS_INFO = 2,	-- 获取boss猎手信息
	RA_OPEN_SERVER_OPERA_TYPE_FETCH_BOSS = 3,		-- 领取boss猎手奖励
	RA_OPEN_SERVER_OPERA_TYPE_FETCH_BATTE_INFO = 4,	-- 请求开服争霸信息
}
--单身伴侣(集月饼活动)
RA_ITEM_COLLECTION_SECOND_OPERA_TYPE = {
	RA_ITEM_COLLECTION_SECOND_OPERA_TYPE_QUERY_INFO = 0,        --请求活动的信息
	RA_ITEM_COLLECTION_SECOND_OPERA_TYPE_EXCHANGE = 1,              --请求兑换
	RA_ITEM_COLLECTION_SECOND_OPERA_TYPE_MAX = 2,
}
--进阶返还类型
TYPE_UPGRADE_RETURN = {
	MOUNT_UPGRADE_RETURN = 1, 		 --坐骑返还
	WING_UPGRADE_RETURN = 2, 		 --羽翼返还
	FABAO_UPGRADE_RETURN = 3, 		 --法宝返还
	WUQI_UPGRADE_RETURN = 4, 		 --神兵返还
	FOOT_UPGRADE_RETURN = 5, 		 --足迹返还
	HALO_UPGRADE_RETURN = 6, 		 --光环返还
	FASHION_UPGRADE_RETURN = 7, 	 --时装返还
	FIGHTMOUNT_UPGRADE_RETURN = 8, 	 --战骑返还
	TOUSHI_UPGRADE_RETURN = 9, 		 --头饰返还
	MASK_UPGRADE_RETURN = 10, 		 --面饰返还
	WAIST_UPGRADE_RETURN = 11, 		 --腰饰返还
	QILINBI_UPGRADE_RETURN = 12, 	 --麒麟臂返还
	LINGCHONG_UPGRADE_RETURN = 13, 	 --灵童返还
	LINGGONG_UPGRADE_RETURN = 14, 	 --灵弓返还
	LINGQI_UPGRADE_RETURN = 15, 	 --灵骑返还
	SHENGONG_UPGRADE_RETURN = 16, 	 --仙环返还

	SHENYI_UPGRADE_RETURN = 17,      --仙阵返还
	FLYPET_UPGRADE_RETURN = 18,      --飞宠返还
	WEIYAN_UPGRADE_RETURN = 19,      --尾焰返还
}


-- 百倍商城(个人抢购)
RA_PERSONAL_PANIC_BUY_OPERA_TYPE = {
	RA_PERSONAL_PANIC_BUY_OPERA_TYPE_QUERY_INFO = 0,
	RA_PERSONAL_PANIC_BUY_OPERA_TYPE_BUY_ITEM = 1,
}

RA_LIMIT_BUY_OPERA_TYPE = {
	RA_LIMIT_BUY_OPERA_TYPE_INFO = 0,				--信息
	RA_LIMIT_BUY_OPERA_TYPE_BUY = 1,					--购买
}

RA_HAPPY_CUMUL_CHONGZHI_OPERA_TYPE = {
	RA_HAPPY_CUMUL_CHONGZHI_OPERA_TYPE_INFO = 0,  -- 信息
	RA_HAPPY_CUMUL_CHONGZHI_OPERA_TYPE_FETCH,     -- 领奖   seq
}

--连续充值
RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE = {
	RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE_QUERY_INFO = 0,			-- 请求活动信息
	RA_VERSION_CONTINUE_CHONGZHI_OPEAR_TYPE_FETCH_REWARD = 1,		-- 获取奖励
}

-- 版本累计充值
RA_VERSION_TOTAL_CHARGE_OPERA_TYPE ={
	RA_VERSION_TOTAL_CHARGE_OPERA_TYPE_QUERY_INFO = 0,		-- 请求活动信息
	RA_VERSION_TOTAL_CHARGE_OPERA_TYPE_FETCH_REWARD = 1,	-- 获取奖励

	RA_VERSION_TOTAL_CHARGE_OPERA_TYPE_MAX = 3,
}

RA_OPEN_SERVER_ACTIVITY_TYPE = {
	RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE = 2091,			-- 7天累积充值(开服活动))
	RAND_ACTIVITY_TYPE_ROLE_UPLEVEL = 2128,					-- 冲级大礼(开服活动)
	RAND_ACTIVITY_TYPE_PATA = 2129,							-- 勇者之塔(开服活动)
	RAND_ACTIVITY_TYPE_EXP_FB = 2130,						-- 经验副本(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_MOUNT = 2131,				-- 坐骑进阶(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_HALO = 2132,					-- 光环进阶(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_WING = 2133,					-- 羽翼进阶(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_SHENGONG = 2134,				-- 神弓进阶(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_SHENYI = 2135,				-- 神翼进阶(开服活动)
	RAND_ACTIVITY_TYPE_FIRST_CHARGE_TUAN = 2136,			-- 首充团购(开服活动)
	RAND_ACTIVITY_TYPE_DAY_TOTAL_CHARGE = 2137,				-- 每日累计充值(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_MOUNT_TOTAL = 2138,			-- 全服坐骑进阶(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_HALO_TOTAL = 2139,			-- 全服光环进阶(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_WING_TOTAL = 2140,			-- 全服羽翼进阶(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_SHENGONG_TOTAL = 2141,		-- 全服神弓进阶(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_SHENYI_TOTAL = 2142,			-- 全服神翼进阶(开服活动)

	-- 开服比拼活动(目前只开14个，后面两个暂时不用)
	RAND_ACTIVITY_TYPE_UPGRADE_MOUNT_RANK = 2143,			-- 坐骑进阶榜(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_WING_RANK = 2145,			-- 羽翼进阶榜(开服活动)
	RAND_ACTIVITY_TYPE_FIGHT_MOUNT_RANK = 2156,				-- 战骑战力榜(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_LINGTONG_RANK = 2161,		-- 灵童进阶榜(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_FABAO_RANK = 2138,			-- 法宝进阶榜(开服活动)
  	RAND_ACTIVITY_TYPE_UPGRADE_FLYPET_RANK = 2164,          -- 飞宠进阶榜(开服活动)
  	RAND_ACTIVITY_TYPE_UPGRADE_HALO_RANK = 2144,			-- 光环进阶榜(开服活动)
  	RAND_ACTIVITY_TYPE_UPGRADE_LINGQI_RANK = 2163,			-- 灵骑进阶榜(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_WEIYAN_RANK = 2165,          -- 尾焰进阶榜(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_QILINBI_RANK = 2158,         -- 麒麟臂进阶榜(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_SHENGONG_RANK = 2146,		-- 神弓仙环进阶榜(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_FOOT_RANK = 2139,			-- 足迹进阶榜(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_LINGGONG_RANK = 2162,		-- 灵弓进阶榜(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_SHENYI_RANK = 2147,			-- 神翼仙阵进阶榜(开服活动) 	 		
	RAND_ACTIVITY_TYPE_UPGRADE_FASHION_RANK = 2131,			-- 时装进阶榜(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_WUQI_RANK = 2132,			-- 神兵进阶榜(开服活动)

	RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN = 2148,				-- 装备强化(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE = 2149,				-- 宝石升级(开服活动)
	RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN_RANK = 2150,		-- 装备强化冲榜(开服活动)
	RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE_RANK = 2151,		-- 宝石等级冲榜(开服活动)
	RAND_ACTIVITY_TYPE_BOSS_LIESHOU = 2152,					-- boss猎手(开服活动)
	RAND_ACTIVITY_TYPE_ZHENG_BA = 2153,						-- 开服争霸(开服活动)
	RAND_ACTIVITY_TYPE_GODDES = 2154,						-- 女神战力榜
	RAND_ACTIVITY_TYPE_SPIRIT = 2155,						-- 精灵战力榜
	RAND_ACTIVITY_TYPE_PERSON_CAPABILITY = 2157,			-- 个人总战力榜
	RAND_ACTIVITY_TYPE_SUPPER_GIFT = 2171,					-- 开服礼包限购(开服活动)
	RAND_ACTIVITY_TYPE_HUNDER_TIMES_SHOP = 2056,			-- 开服百倍商城(开服活动)
	RAND_ACTIVITY_TYPE_MARRY_ME = 2169,						-- 我们结婚吧

	RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI = 2115,			-- 连充特惠
	RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU = 2174,		-- 连充特惠初
	RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO = 2175,		-- 连充特惠高

	RAND_ACTIVITY_TYPE_KAIFU_INVEST = 2176,                 -- 开服投资
	RAND_ACTIVITY_TYPE_GOLDEN_PIG =	2173,					-- 金猪召唤(龙神夺宝)
	RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU = 2174,		-- 连充特惠初(开服活动)
	RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO = 2175,		-- 连充特惠高(开服活动)

	RAND_ACTIVITY_TYPE_HONG_BAO = 2170, 					-- 7日红包
	RAND_ACTIVITY_TYPE_RARE_CHANGE = 2177,					-- 珍宝兑换(开服活动)
	RAND_ACTIVITY_TYPE_SINGLE_CHARGE_2 = 2182,				-- 冲战达人
	RAND_ACTIVITY_TYPE_SINGLE_CHARGE_3 = 2183,				-- 冲战高手
	RAND_ACTIVITY_TYPE_DAY_ACTIVIE_DEGREE = 2052, 			-- 日常活跃奖励
	RAND_ACTIVITY_TYPE_DAY_CHONGZHI_RANK = 2089, 			-- 每日充值排行榜
	RAND_ACTIVITY_TYPE_DAY_XIAOFEI_RANK = 2090, 			-- 每日消费排行榜
	RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_PASSIVE_RANK = 2107, 			-- 被动变身榜
	RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_RANK = 2108, 			-- 变身榜
	RAND_ACTIVITY_TYPE_TOTAL_CONSUME = 2051, 	  	      	-- 累计消费
	RAND_ACTIVITY_TYPE_CHARGE_REPALMENT = 2081,							-- 累充回馈
	RAND_ACTIVITY_TYPE_DANBI_CHONGZHI = 2082,				-- 单笔充值
	RAND_DAY_CHONGZHI_FANLI = 2049,                         -- 充值返利
	RAND_ACTIVITY_TYPE_TOTAL_CHARGE = 2187, 	  	      	-- 累计充值
	RAND_ACTIVITY_TYPE_FULL_SERVER_SNAP = 2055,				-- 全服抢购
	RAND_ACTIVITY_TYPE_DAY_CONSUME_GOLD = 2050,				-- 每日累计消费
	RAND_ACTIVITY_TYPE_GETREWARD = 2057,				    -- 消费返利
	RAND_SINGLE_DAY_CHARGE = 2137,							-- 单日累充
	RAND_ACTIVITY_TYPE_SAN_SHENG_SAN_SHI = 2193,			-- 三生三世
	RAND_ACTIVITY_TYPE_EVERY_DAY_SNAP = 2195,				-- 每日限购
	RAND_ACTIVITY_TYPE_JUBAOPEN = 2196,						-- 聚宝盆
	RAND_ACTIVITY_TYPE_BAOJI_DAY = 2197,					-- 暴击日
	RAND_ACTIVITY_TYPE_HAPPY_RECHARGE = 2198,				-- 欢乐累充
	RAND_ACTIVITY_TYPE_UPGRADE_RETURN = 2199,				-- 进阶返还
	RAND_ACTIVITY_TYPE_QUAN_MIN_JIN_JIE = 2200,				-- 全民进阶
	RAND_ACTIVITY_TYPE_QUAN_MIN_UPGRADE_GROUPE = 2201,		-- 全民总动员(全服人的主题阶达到指定阶数)
	RAND_ACTIVITY_TYPE_LOGIN_GIFT = 2217, 					-- 登陆豪礼
	RAND_ACTIVITY_TYPE_EVERYDAY_NICE_GIFT = 2218,			-- 每日好礼	
	RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_0 = 2215,		-- 狂欢单笔充值
	RAND_ACTIVITY_TYPE_FENGKUANG_YAOJIANG = 2214,			-- 疯狂摇奖
	RAND_ACTIVITY_TYPE_DAY_DANBI_CHONGZHI = 2085,			-- 每日单笔充值
	RAND_ACTIVITY_TYPE_MAKE_MOONCAKE = 2211,                --集月饼活动(单身伴侣)
	RAND_ACTIVEIY_TYPE_LIANXUCHONGZHI = 2212,				-- 连续充值
	RAND_ACTIVITY_TYPE_PROFESS_RANK = 2228,					-- 表白排行榜
	RAND_ACTIVITY_TYPE_UPLEVEL_RETURN_2 = 2229,				-- 进阶返还2
	RAND_ACTIVITY_TYPE_CRITICAL_STRIKE_DAY_2 = 2230,		-- 暴击日2
	RAND_ACTIVEIY_TYPE_CONSUMPTION_AWARD = 2194,			-- 消费领奖
	RAND_ACTIVITY_TYPE_DISCOUNT_BUY_HOME = 2234,			-- 折扣买房(夫妻家园)
	RAND_ACTIVITY_TYPE_DISCOUNT_BUY_FURNITURE = 2235,		-- 买一送一(夫妻家园)
}

IS_CLOSE_ACTIVITY = {
	-- 开服比拼活动(目前只开14个，后面两个暂时不用)
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_MOUNT_RANK] = true, 			-- 坐骑进阶榜(开服活动)
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING_RANK] = true,			    -- 羽翼进阶榜(开服活动)
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIGHT_MOUNT_RANK] = true,              -- 战骑战力榜(开服活动)
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_LINGTONG_RANK] = true, 		-- 灵童进阶榜(开服活动)
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FABAO_RANK] = true, 			-- 法宝进阶榜(开服活动)
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FLYPET_RANK] = true, 			-- 飞宠进阶榜(开服活动)
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_HALO_RANK] = true, 			-- 光环进阶榜(开服活动)
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_LINGQI_RANK] = true, 		    -- 灵骑进阶榜(开服活动)
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WEIYAN_RANK] = true,			-- 尾焰进阶榜(开服活动)
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_QILINBI_RANK] = true,			-- 麒麟臂进阶榜(开服活动)
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENGONG_RANK] = true,			-- 神弓仙环进阶榜(开服活动)
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FOOT_RANK] = true,			    -- 足迹进阶榜(开服活动)
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_LINGGONG_RANK] = true,			-- 灵弓进阶榜(开服活动)
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENYI_RANK] = true,			-- 神翼仙阵进阶榜(开服活动)
	-- [RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FASHION_RANK] = true,			-- 时装进阶榜(开服活动)
	-- [RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WUQI_RANK] = true,			    -- 神兵进阶榜(开服活动)				 
}

OPEN_SERVER_RA_ACTIVITY_TYPE = {
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_ACTIVIE_DEGREE,
	-- RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_RANK,
	-- RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_PASSIVE_RANK,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CONSUME,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHARGE_REPALMENT,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBI_CHONGZHI,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_DAY_CHONGZHI_FANLI,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CHARGE,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FULL_SERVER_SNAP,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GETREWARD,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_SINGLE_DAY_CHARGE,
	-- RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SAN_SHENG_SAN_SHI,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_JUBAOPEN,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BAOJI_DAY,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CRITICAL_STRIKE_DAY_2,
	-- RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAKE_MOONCAKE,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QUAN_MIN_JIN_JIE,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QUAN_MIN_UPGRADE_GROUPE,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EVERY_DAY_SNAP,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPY_RECHARGE,
	-- RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_RETURN,
	-- RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPLEVEL_RETURN_2,
	--RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EVERYDAY_NICE_GIFT,
	--RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_0,
	--RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FENGKUANG_YAOJIANG,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DANBI_CHONGZHI,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CHONGZHI_RANK,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_XIAOFEI_RANK,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPPER_GIFT,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVEIY_TYPE_CONSUMPTION_AWARD,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUNDER_TIMES_SHOP,
}

AdvanceType = {
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_MOUNT,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_HALO,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENGONG,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENYI,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_MOUNT_TOTAL,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_HALO_TOTAL,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENGONG_TOTAL,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENYI_TOTAL,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING_TOTAL,
}

ChongzhiType = {
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIRST_CHARGE_TUAN,
	-- RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_TOTAL_CHARGE,
	-- RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE,
}

RankType = {
	-- 开服比拼活动(目前只开14个，后面两个暂时不用)
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_MOUNT_RANK, 			-- 坐骑进阶榜(开服活动)
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING_RANK,			    -- 羽翼进阶榜(开服活动)
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIGHT_MOUNT_RANK,              -- 战骑战力榜(开服活动)
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_LINGTONG_RANK, 		-- 灵童进阶榜(开服活动)
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FABAO_RANK, 			-- 法宝进阶榜(开服活动)
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FLYPET_RANK, 			-- 飞宠进阶榜(开服活动)
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_HALO_RANK, 			-- 光环进阶榜(开服活动)
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_LINGQI_RANK, 		    -- 灵骑进阶榜(开服活动)
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WEIYAN_RANK,			-- 尾焰进阶榜(开服活动)
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_QILINBI_RANK,			-- 麒麟臂进阶榜(开服活动)
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENGONG_RANK,			-- 神弓仙环进阶榜(开服活动)
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FOOT_RANK,			    -- 足迹进阶榜(开服活动)
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_LINGGONG_RANK,			-- 灵弓进阶榜(开服活动)
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENYI_RANK,			-- 神翼仙阵进阶榜(开服活动)
	-- RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FASHION_RANK,			-- 时装进阶榜(开服活动)
	-- RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WUQI_RANK,			    -- 神兵进阶榜(开服活动)	
}

StrengthenType = {
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN_RANK,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE_RANK,
}

NormalType = {
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ROLE_UPLEVEL,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PATA,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_FB,
}

BossType = {
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BOSS_LIESHOU,
}

BattleType = {
	YUAN_SU_ZHANCHANG = 1,			-- 元素战场
	GUILD_BATTLE  =2,				-- 公会争霸
	GONG_CHENG_ZHAN = 3,			-- 攻城战
	TERRITORYWARU = 4,				-- 领土战
}

-- 开服争霸每个子活动ID
BattleActivityId = {
	[BattleType.YUAN_SU_ZHANCHANG] = 5,		-- 元素战场
	[BattleType.GUILD_BATTLE] = 21,			-- 公会争霸
	[BattleType.GONG_CHENG_ZHAN] = 6,		-- 攻城战
	[BattleType.TERRITORYWARU] = 19,		-- 领土战
}

TEMP_ADD_ACT_TYPE = {
	WELFARE_LEVEL_ACTIVITY_TYPE = 9000,		-- 冲级豪礼
	SUPREME_MEMBERS = 9001,					-- 至尊会员
	RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU = 2174,		-- 连充特惠初
	RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO = 2175,		-- 连充特惠高
	RAND_ACTIVITY_LEVEL_INVESTMENT = 9003,					-- 等级投资
	RAND_ACTIVITY_MONTHCARDINVESTMENT = 9004,				-- 月卡投资/周卡投资
	RAND_ACTIVITY_GROWUP_INVESTMENT = 9005,					-- 成长基金
	RAND_ACTIVITY_FuBenTouZi = 9006,					    -- 副本投资
	RAND_ACTIVITY_BossTouZi = 9007,	                        -- boss投资
	RAND_ACTIVITY_ShenYuBossTouZi = 9008,					-- 神域BOSS投资
}

TempAddActivityType = {
	{activity_type = TEMP_ADD_ACT_TYPE.WELFARE_LEVEL_ACTIVITY_TYPE, name = Language.Activity.WelfareLevel},
	{activity_type = TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU, name = Language.Activity.LianChongTeHuiChu},
	{activity_type = TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO, name = Language.Activity.LianChongTeHuiGao},
	{activity_type = TEMP_ADD_ACT_TYPE.SUPREME_MEMBERS, name = Language.Activity.SupremeMembers},
	{activity_type = TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_LEVEL_INVESTMENT, name = Language.Activity.LevelInvestment},
	{activity_type = TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_MONTHCARDINVESTMENT, name = Language.Activity.MonthCardInvestment},
	{activity_type = TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_GROWUP_INVESTMENT, name = Language.Activity.GrowupInvestment},
	{activity_type = TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_FuBenTouZi, name = Language.Activity.FuBenTouZi},
	{activity_type = TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_BossTouZi, name = Language.Activity.BossTouZi},
	{activity_type = TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_ShenYuBossTouZi, name = Language.Activity.ShenYuBossTouZi},
}

-- 在开服活动界面和精彩活动界面都要显示的随机活动
RandActivityInKaifuView = {
	{activity_type = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GOLDEN_PIG, name = Language.Activity.GoldenPigCall},
	{activity_type = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_KAIFU_INVEST, name = Language.Activity.KaiFuInvest},
	{activity_type = ACTIVITY_TYPE.RAND_DAILY_LOVE, name = Language.Activity.DailyLove},
	{activity_type = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CONSUME_GOLD, name = Language.Activity.DailyTotalConsume},
	{activity_type = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EVERY_DAY_SNAP, name = Language.Activity.EveryDayBuy},
	-- {activity_type = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BAOJI_DAY},
	-- {activity_type = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAKE_MOONCAKE, name = Language.Activity.MakeMoonCake},
	-- {activity_type = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EVERYDAY_NICE_GIFT, name = Language.Activity.EveryDayNiceGift},
	{activity_type = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPY_RECHARGE, name = Language.Activity.HuanLeLeiChong},
	-- {activity_type = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_RETURN},
	{activity_type = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_JUBAOPEN, name = Language.Activity.JuBaoPen}
}


SYSTEM_TYPE = {
	MOUNT = 0,
	WING = 1,
	FABAO = 2,
	SHENBING = 3,
	FOOT = 4,
	HALO = 5,
	FASIHON = 6,
}

local MAX_ACTIVITY_TYPE = 29 	-- 最大活动数

local ONE_DAY = 24 * 60 * 60

-- 开服活动排序
local ACTIVITY_SORT_INDEX_LIST = {
	-- [1] = ACTIVITY_TYPE.RAND_DAILY_LOVE,
	[1] = TEMP_ADD_ACT_TYPE.WELFARE_LEVEL_ACTIVITY_TYPE, 						--冲级豪礼
	[2] = TEMP_ADD_ACT_TYPE.SUPREME_MEMBERS,								-- 至尊会员
	[3] = TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_LEVEL_INVESTMENT,						-- 等级投资.
	[4] = TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_GROWUP_INVESTMENT,					-- 成长基金
	[5] = TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_MONTHCARDINVESTMENT,					-- 周卡投资
	-- [6] = TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_FuBenTouZi,					-- 副本投资
	-- [7] = TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_BossTouZi,					-- boss投资
	[8] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIRST_CHARGE_TUAN,	-- 首充团购
	[9]	= TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU,			-- 连充特惠
	[10] = TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO,			-- 连充特惠高
	[11] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CHONGZHI_RANK, 	-- 每日充值榜
	[12] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_XIAOFEI_RANK, 	-- 每日消费榜
	[13] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPPER_GIFT,			-- 礼包限购
	[14] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUNDER_TIMES_SHOP,	-- 个人抢购
	[15] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_JUBAOPEN,			-- 点石成金
	[16] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVEIY_TYPE_CONSUMPTION_AWARD, 	-- 消费领奖
	[17] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QUAN_MIN_JIN_JIE, 	-- 每日进阶
	[18] = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION,					-- 集字活动
	-- [5]	= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GOLDEN_PIG,			-- 龙神召唤（原金猪召唤）
	-- [9] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BOSS_LIESHOU,			-- Boo猎手
	-- [11] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_KAIFU_INVEST,		-- 活跃投资
	-- [12] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HONG_BAO,			-- 红包好礼
	-- [13] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RARE_CHANGE,			-- 珍宝兑换
}

local ACTIVITY_TYPE_TO_INDEX = {
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN] = 1,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE] = 1,
	-- [RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_TOTAL_CHARGE] = 1,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ROLE_UPLEVEL] = 1,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PATA] = 1,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_FB] = 1,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_MOUNT] = 1,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_HALO] = 1,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENGONG] = 1,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENYI] = 1,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING] = 1,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_MOUNT_TOTAL] = 1,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_HALO_TOTAL] = 1,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENGONG_TOTAL] = 1,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENYI_TOTAL] = 1,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING_TOTAL] = 1,

	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIRST_CHARGE_TUAN] = 2,

	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_MOUNT_RANK] = 9,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING_RANK] = 9,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FASHION_RANK] = 9,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WUQI_RANK] = 9,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FABAO_RANK] = 9,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FOOT_RANK] = 9,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_HALO_RANK] = 9,

	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENGONG_RANK] = 3,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENYI_RANK] = 3,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN_RANK] = 3,

	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ZHENG_BA] = 4,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BOSS_LIESHOU] = 5,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION] = 6,
	-- [RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE] = 7,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPPER_GIFT] = 8,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUNDER_TIMES_SHOP] = 9,
	[TEMP_ADD_ACT_TYPE.WELFARE_LEVEL_ACTIVITY_TYPE] = 10,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HONG_BAO] = 11,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GOLDEN_PIG] = 12,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO] = 13,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU] = 14,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_KAIFU_INVEST] = 15,
	-- [RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RARE_CHANGE] = 16,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GUILD_FIGHT] = 16,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_ACTIVIE_DEGREE] = 17,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CHONGZHI_RANK] = 18,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_XIAOFEI_RANK] = 19,
	-- [RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_RANK] = 20,
	-- [RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_PASSIVE_RANK] = 21,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CONSUME] = 22,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHARGE_REPALMENT] = 23,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBI_CHONGZHI] = 24,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_DAY_CHONGZHI_FANLI] = 25,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CHARGE] = 26,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FULL_SERVER_SNAP] = 27,
	[ACTIVITY_TYPE.RAND_DAILY_LOVE] = 28,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CONSUME_GOLD] = 29,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GETREWARD] = 30,

	[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_RANK_QIANGGOU] = 31,
	[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_ROLL] = 32,
	[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_GONGCHENGZHAN] = 33,
	[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_CHONGZHI_RANK] = 34,
	[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_CONSUME_RANK] = 35,
	[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_KILL_BOSS] = 36,
	[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_SINGLE_CHARGE] = 37,
	[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_LOGIN_Gift] = 38,
	[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_PERSONAL_PANIC_BUY] = 39,
	[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_SERVER_PANIC_BUY] = 40,
	[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BOSS] = 41,
	[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_TOUZI] = 42,
	[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_JIJIN] = 43,
	[TEMP_ADD_ACT_TYPE.SUPREME_MEMBERS] = 45,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_SINGLE_DAY_CHARGE] = 46,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SAN_SHENG_SAN_SHI] = 47,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BAOJI_DAY] = 48,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_RETURN] = 49,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPY_RECHARGE] = 50,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EVERY_DAY_SNAP] = 51,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QUAN_MIN_JIN_JIE] = 54,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QUAN_MIN_UPGRADE_GROUPE] = 55,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_GIFT] = 56,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_JUBAOPEN] = 57,
	--[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_0] = 58,
	--[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FENGKUANG_YAOJIANG] = 70,
	
	--[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT] = 59,
	
	--[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAKE_MOONCAKE] = 60,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DANBI_CHONGZHI] = 61,
	--[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EVERYDAY_NICE_GIFT] = 62,
	[TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_LEVEL_INVESTMENT] = 63,
	[TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_MONTHCARDINVESTMENT] = 64,
	[TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_GROWUP_INVESTMENT] = 65,
	[TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_FuBenTouZi] = 66,
	[TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_BossTouZi] = 67,
	[TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_ShenYuBossTouZi] = 68,
	
	--[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVEIY_TYPE_LIANXUCHONGZHI] = 69,
	-- [RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPLEVEL_RETURN_2] = 71,
	[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CRITICAL_STRIKE_DAY_2] = 72,
}


INVEST_STATE = {outtime = 1, no_finish = 2, finish = 3, complete = 4, no_invest = 5}

INVEST_TYPE_TYPE_POSION = {BOSS = 32, ACTIVE = 24, COMPETITION = 16}

KAIFU_INVEST_TYPE = {
	["BOSS"] = 0,
	["ACTIVE"] = 1,
	["COMPETITION"] = 2,
}

KaifuActivityType = {TYPE = 1025}

function KaifuActivityData:__init()
	if KaifuActivityData.Instance ~= nil then
		print_error("[KaifuActivityData] Attemp to create a singleton twice !")
		return
	end

	KaifuActivityData.Instance = self
	self.touzi_min_level = 2000
	self.active_open_list_id = {}
	self.info = {}
	self.upgrade_info = {}
	self.rank_info = {}
	self.boss_lieshou_info = {}
	self.battle_uid_info = {}
	self.battle_role_info = {}
	self.battle_activity_info = {}
	self.act_change_callback = {}
	self.personal_buy_info = {}
	self.everyday_buy_info = {}
	self.collect_exchange_info = {}
	self.collect_moon_exchange_info = {}
	self.golden_pig_call_info = {}
	self.golden_pig_boss_info = {}
	self.golden_pig_monster_list = {}
	self.fetch_reward_flag = 0
	self.everyday_buy_act_type = 0
	self.reward_fetch_flag = {}
	self.reward_active_flag = {}
	self.final_list = {}
	self.default_open_act_type = -1

	self.role_change_times = 0
	self.rank_count = 0
	self.bei_bianshen_rank_list = {}

	self.total_consume_info = {}
	self.recharge_rebate_info = {}

	self.total_charge_info = {}

	self.special_appearance_role_change_times = 0
	self.special_appearance_rank_count = 0

	self.open_cfg = ConfigManager.Instance:GetAutoConfig("randactivityopencfg_auto").open_cfg

	self.opengameactivity_cfg = ConfigManager.Instance:GetAutoConfig("opengameactivity_auto")


	self.leiji_chongzhi_info = {}
	self.upgrade_return_info = {}
	self.upgrade_return_info2 = {}

	self.happy_recharge_info = {}

	self.special_tab_name = self:GetSpecialName()

	self.zhengba_red_point_state = true
	self.lianchong_1_point = true
	self.lianchong_2_point = true
	self.daily_show_icon_flag = 0

	self.rsing_star_info = {}
	self.rsing_star_info.is_get_reward_today = 0
	self.rsing_star_info.chognzhi_today = 0
	self.rsing_star_info.func_level = 0
	self.rsing_star_info.func_type = 0
	self.rsing_star_info.is_max_level = 0
	self.rsing_star_info.stall = 0
	self.selectindex = 1

	self.perfect_lover_info = {}
	self.perfect_lover_info.perfect_lover_type_record_flag = 0
	self.perfect_lover_info.ra_perfect_lover_count = 0
	self.perfect_lover_info.ra_perfect_lover_name_list = {}

	self.quanmin_jinjie_info = {}
	self.quanmin_jinjie_info.reward_flag = 0
	self.quanmin_jinjie_info.grade = 0

	self.quanmin_group_info = {}
	self.quanmin_group_info.ra_upgrade_group_reward_flag = 0
	self.quanmin_group_info.count_list = {}

	-- 红点点击后消失，重新登录再次提醒（标志）
	self.click_sign = false
	self.click_go_sign = false
	self.click_jbp = false
	self.qitian_sign = false
	self.chongzhi_rank_sign = false
	self.xiaofei_rank_sign = false
	self.dan_bi_chong_zhi_sign = false
	self.lei_chong_sign = false
	self.chong_zhi_fan_li_sign = false
	self.total_consume_sign = false
	self.daily_consume_sign = false
	self.click_czjj = false
	self.click_sctg = false
	self.huan_le_lei_chong_sign = false
	self.long_shen_zhao_huan_sign = false
	self.dan_ri_chong_zhi_sign = false

------狂欢的单笔充值
	local time = bit:d2b(0)
	
	self.single_info = {
		[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_0] = {},
		-- [RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_1] = {},
		-- [RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_2] = {},
	}

	self.cfg_list = {
		[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_0] = {cfg = {}},
		-- [RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_1] = {cfg = {}},
		-- [RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_2] = {cfg = {}},
	}

	self.is_open = false

	for k,v in pairs(self.single_info) do
		local temp = {charge_max_value = 0, reward_times = time, reward_type = 0, cfg = {}}
		self.single_info[k] = temp
	end

	---------------疯狂摇奖-------------------------------------
	self.count = -1
	self.chest_shop_mode = -1
	self.chou_times = 0
	---------------------------------------------------------

	RemindManager.Instance:Register(RemindName.JingCai_Act_Delay, BindTool.Bind(self.JingCaiActivityPoint, self))

	RemindManager.Instance:Register(RemindName.KaiFu, BindTool.Bind(self.GetNewServerRemind, self))
	RemindManager.Instance:Register(RemindName.TouziActivity, BindTool.Bind(self.GetTouziActivityRemind, self))
	RemindManager.Instance:Register(RemindName.KfLeichong, BindTool.Bind(self.GetKfLeichongRemind, self))
	RemindManager.Instance:Register(RemindName.HappyLeichong, BindTool.Bind(self.GetHuanLeLeichongRemind, self))
	RemindManager.Instance:Register(RemindName.LianChongTeHuiChu, BindTool.Bind(self.LianChongTeHuiChuHongDian, self))
	RemindManager.Instance:Register(RemindName.LianChongTeHuiGao, BindTool.Bind(self.LianChongTeHuiGaoHongDian, self))
	RemindManager.Instance:Register(RemindName.QuanFuBuy, BindTool.Bind(self.GetQuanFuBuyRemind, self))
	RemindManager.Instance:Register(RemindName.PersonBuy, BindTool.Bind(self.GetQuanFuBuyRemind, self))
	RemindManager.Instance:Register(RemindName.LiBaoBuy, BindTool.Bind(self.GetQuanFuBuyRemind, self))
	RemindManager.Instance:Register(RemindName.EveryDayBuy, BindTool.Bind(self.GetQuanFuBuyRemind, self))
	RemindManager.Instance:Register(RemindName.MeiRiDanBi, BindTool.Bind(self.GetDailyDanBiRedPoint, self))
	self.pass_day_kaifu = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.OnDayChangeCallBack, self))
end


function KaifuActivityData:OnDayChangeCallBack()
		if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FULL_SERVER_SNAP) then
			 KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FULL_SERVER_SNAP, RA_CHARGE_REPAYMENT_OPERA_TYPE.RA_SERVER_PANIC_BUY_OPERA_TYPE_QUERY_INFO)
		end
		if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUNDER_TIMES_SHOP) then
			 KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUNDER_TIMES_SHOP, RA_CHARGE_REPAYMENT_OPERA_TYPE.RA_SERVER_PANIC_BUY_OPERA_TYPE_QUERY_INFO)
		end
		if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPPER_GIFT) then
			KaifuActivityCtrl.Instance:SendRandActivityOperaReq(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPPER_GIFT, RA_SINGLE_CHONGZHI_OPERA_TYPE.RA_SINGLE_CHONGZHI_OPERA_TYPE_INFO, 0)
		end
		if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EVERY_DAY_SNAP) then
			 KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EVERY_DAY_SNAP, RA_CHARGE_REPAYMENT_OPERA_TYPE.RA_SERVER_PANIC_BUY_OPERA_TYPE_QUERY_INFO)
		end

end

function KaifuActivityData:GetQuanFuBuyRemind()
	return 1 
end


function KaifuActivityData:GetQuanFuBuyRemindRed()
	if not ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FULL_SERVER_SNAP) then
		return false
	end
	local cfg = RemindManager.Instance:RemindToday(RemindName.QuanFuBuy)
	if cfg then
		return false
	else
		return true
	end
end

function KaifuActivityData:GetPersonBuyRemindRed()
	if not ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUNDER_TIMES_SHOP) then
		return false
	end
	local cfg = RemindManager.Instance:RemindToday(RemindName.PersonBuy)
	if cfg then
		return false
	else
		return true
	end
end

function KaifuActivityData:GetLiBaoBuyRemindRed()
	if not ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPPER_GIFT) then
		return false
	end

	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	local flag = self:GetGiftShopFlag()
	local all_buy = true

	for k,v in pairs(self.opengameactivity_cfg.gift_shop) do
		if v and role_vo.vip_level then
			-- vip大于5的需要判断6个礼包，vip等级不足只需要判断后面4个礼包
			if role_vo.vip_level >= 5 then
				all_buy = flag[32 - v.seq] == 0
			else
				if k > 2 then 
					all_buy = flag[32 - v.seq] == 0
				end
			end
		end
	end
	
	if all_buy then
		local cfg = RemindManager.Instance:RemindToday(RemindName.LiBaoBuy)
		if cfg then
			return false
		else
			return true
		end
	end

	return false
end

function KaifuActivityData:GetEveryDayBuyRemindRed()
	if not ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EVERY_DAY_SNAP) then
		return false
	end
	local cfg = RemindManager.Instance:RemindToday(RemindName.EveryDayBuy)
	if cfg then
		return false
	else
		return true
	end
end



function KaifuActivityData:__delete()
	GlobalEventSystem:UnBind(self.pass_day_kaifu)
	RemindManager.Instance:UnRegister(RemindName.KaiFu)
	RemindManager.Instance:UnRegister(RemindName.KfLeichong)
	RemindManager.Instance:UnRegister(RemindName.HappyLeichong)
	RemindManager.Instance:UnRegister(RemindName.LianChongTeHuiChu)
	RemindManager.Instance:UnRegister(RemindName.LianChongTeHuiGao)
 	RemindManager.Instance:UnRegister(RemindName.QuanFuBuy)
	RemindManager.Instance:UnRegister(RemindName.PersonBuy)
	RemindManager.Instance:UnRegister(RemindName.LiBaoBuy)
	RemindManager.Instance:UnRegister(RemindName.JingCai_Act_Delay)
	RemindManager.Instance:UnRegister(RemindName.MeiRiDanBi)

	self.info = {}
	self.upgrade_info = {}
	self.rank_info = {}
	self.boss_lieshou_info = {}
	self.activity_reward_cfg = {}
	self.opengameactivity_cfg = {}
	self.battle_uid_info = {}
	self.open_cfg = {}
	self.battle_role_info = {}
	self.battle_activity_info = {}
	self.act_change_callback = {}
	self.leiji_chongzhi_info = {}
	self.golden_pig_call_info = {}
	self.golden_pig_boss_info = {}
	self.golden_pig_monster_list = {}
	self.total_consume_info = {}
	self.total_charge_info = {}
	self.recharge_rebate_info = {}
	self.perfect_lover_info = {}
	self.quanmin_jinjie_info = {}
	self.quanmin_group_info = {}
	self.happy_recharge_info = {}
	KaifuActivityData.Instance = nil
end

-- 描边解释
function KaifuActivityData:OutLineRichText(has_num, need_num, text, type)
	local str = ""
	if type == 1 then
		if has_num < need_num then
			str =  string.format(Language.OutLine.RedNumTxt1, has_num) .. string.format(Language.OutLine.GreenNumTxt1_2, need_num)
			return RichTextUtil.ParseRichText(text.rich_text, str, 22)
		end
		str = string.format(Language.OutLine.GreenNumTxt1_1, has_num) .. string.format(Language.OutLine.GreenNumTxt1_2, need_num)
		return RichTextUtil.ParseRichText(text.rich_text, str, 22)
	else
		if has_num < need_num then
			str = string.format(Language.OutLine.RedNumTxt, has_num) .. string.format(Language.OutLine.GreenNumTxt_2, need_num)
			return RichTextUtil.ParseRichText(text.rich_text, str, 22)
		end
		str = string.format(Language.OutLine.GreenNumTxt_1, has_num) .. string.format(Language.OutLine.GreenNumTxt_2, need_num)
		return RichTextUtil.ParseRichText(text.rich_text, str, 22)
	end
end


function KaifuActivityData:ClearActivityInfo()
	self.info = {}
	self.battle_uid_info = {}
	self.battle_role_info = {}
end

-- 开服活动信息
function KaifuActivityData:SetActivityInfo(protocol)
	local type_info = {}
	type_info.rand_activity_type = protocol.rand_activity_type
	type_info.reward_flag = protocol.reward_flag
	type_info.complete_flag = protocol.complete_flag
	type_info.today_chongzhi_role_count = protocol.today_chongzhi_role_count
	--  装备强化活动不要了 不接受数据
	if type_info.rand_activity_type ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN then
		self.info[type_info.rand_activity_type] = type_info
	end
end

function KaifuActivityData:GetActivityInfo(rand_activity_type)
	return self.info[rand_activity_type]
end

-- 开服进阶信息
function KaifuActivityData:SetActivityUpgradeInfo(protocol)
	local type_info = {}
	type_info.rand_activity_type = protocol.rand_activity_type
	type_info.total_upgrade_record_list = protocol.total_upgrade_record_list
	self.upgrade_info[type_info.rand_activity_type] = type_info
end

function KaifuActivityData:GetActivityUpgradeInfo(rand_activity_type)
	return self.upgrade_info[rand_activity_type]
end

-- 开服进阶排行榜信息
function KaifuActivityData:SetOpenServerRankInfo(protocol)
	local type_info = {}
	type_info.rand_activity_type = protocol.rand_activity_type
	type_info.myself_rank = protocol.myself_rank
	type_info.top1_uid = protocol.top1_uid
	type_info.role_name = protocol.top1_name
	type_info.role_sex = protocol.role_sex
	type_info.role_prof = protocol.role_prof
	type_info.capability = protocol.capability
	type_info.avatar_key_big = protocol.avatar_key_big
	type_info.avatar_key_small = protocol.avatar_key_small

	type_info.rank_info = protocol.rank_info
	self.rank_info[type_info.rand_activity_type] = type_info
	CompetitionActivityCtrl.Instance:FlushView()
end

function KaifuActivityData:GetOpenServerRankInfo(rand_activity_type)
	return self.rank_info[rand_activity_type]
end

-- 开服活动boss猎手信息
function KaifuActivityData:SetBossLieshouInfo(protocol)
	self.boss_lieshou_info.oga_kill_boss_reward_flag = protocol.oga_kill_boss_reward_flag
	self.boss_lieshou_info.oga_kill_boss_flag_hight = protocol.oga_kill_boss_flag_hight
	self.boss_lieshou_info.oga_kill_boss_flag_low = protocol.oga_kill_boss_flag_low
end

function KaifuActivityData:GetBossLieshouInfo()
	return self.boss_lieshou_info
end

-- 开服活动战场争霸信息
function KaifuActivityData:SetBattleUidInfo(protocol)
	self.battle_uid_info[BattleType.YUAN_SU_ZHANCHANG] = protocol.yuansu_uid
	self.battle_uid_info[BattleType.GUILD_BATTLE] = protocol.guildbatte_uid
	self.battle_uid_info[BattleType.GONG_CHENG_ZHAN] = protocol.gongchengzhan_uid
	self.battle_uid_info[BattleType.TERRITORYWARU] = protocol.territorywar_uid
end

function KaifuActivityData:GetBattleUidInfo()
	return self.battle_uid_info
end

-- 开服活动战场争霸人物信息
function KaifuActivityData:SetBattleRoleInfo(ac_type, protocol)
	local temp_info = {}
	temp_info.role_name = protocol.role_name
	temp_info.appearance = protocol.appearance
	temp_info.wing_info = protocol.wing_info
	temp_info.prof = protocol.prof
	temp_info.sex = protocol.sex

	self.battle_role_info[ac_type] = protocol
end

function KaifuActivityData:GetBattleRoleInfo()
	return self.battle_role_info
end

-- 累计充值活动信息
function KaifuActivityData:SetLeiJiChongZhiInfo(protocol)
	self.leiji_chongzhi_info = protocol
end

function KaifuActivityData:GetLeiJiChongZhiInfo()
	return self.leiji_chongzhi_info
end

-- 礼包限购活动信息
function KaifuActivityData:SetGiftShopFlag(protocol)
	self.oga_gift_shop_flag = protocol.oga_gift_shop_flag
end

function KaifuActivityData:GetGiftShopFlag()
	return bit:d2b(self.oga_gift_shop_flag or 0) or {}
end

-- 百倍商城（个人抢购信息）
function KaifuActivityData:SetPersonalBuyInfo(buy_numlist)
	self.personal_buy_info = buy_numlist
end

function KaifuActivityData:GetPersonalBuyInfo()
	return self.personal_buy_info
end

-- 每日限购信息
function KaifuActivityData:SetEverydayBuyInfo(buy_numlist)
	self.everyday_buy_info = buy_numlist
end

function KaifuActivityData:GetEverydayBuyInfo()
	return self.everyday_buy_info
end

function KaifuActivityData:SetEverydayBuyActType(act_type)
	self.everyday_buy_act_type = act_type
end

function KaifuActivityData:GetEverydayBuyActType()
	return self.everyday_buy_act_type
end

-- 金猪召唤(召唤积分信息)
function KaifuActivityData:SetGoldenPigCallInfo(protocol)
	self.golden_pig_call_info = protocol

end

function KaifuActivityData:GetGoldenPigCallInfo()
	return self.golden_pig_call_info
end

-- 金猪召唤(召唤boss状态信息)
function KaifuActivityData:SetGoldenPigCallBossInfo(protocol)
	self.golden_pig_boss_info = protocol
end

function KaifuActivityData:GetGoldenPigCallBossInfo()
	return self.golden_pig_boss_info
end

-- 集字活动兑换次数
function KaifuActivityData:SetCollectExchangeInfo(exchange_times)
	self.collect_exchange_info = exchange_times
end

function KaifuActivityData:GetCollectExchangeInfo()
	return self.collect_exchange_info
end

--暴击日
function KaifuActivityData:SetBaojiDayActType(protocol)
	self.act_type = protocol.act_type
end

--暴击日2
function KaifuActivityData:SetBaojiDayActType2(protocol)
	self.act_type_2 = protocol.act_type
end

function KaifuActivityData:GetBaojiDayActType()
	return self.act_type
end

function KaifuActivityData:GetBaojiDay2ActType()
	return self.act_type_2
end

function KaifuActivityData:GetBaojiDayCfg()
	if not self.BaojiDayInfo then
		self.BaojiDayInfo = PlayerData.Instance:GetCurrentRandActivityConfig().baoji_day
	end
	return self.BaojiDayInfo
end

-- 配置表
function KaifuActivityData:GetKaifuActivityCfg()
	if not self.activity_reward_cfg then
		self.activity_reward_cfg = PlayerData.Instance:GetCurrentRandActivityConfig().openserver_reward
	end
	return self.activity_reward_cfg
end

-- 配置表2
function KaifuActivityData:GetKaifuActivityCfgList()
	if not self.activity_reward_cfg_list then
		self.activity_reward_cfg_list = ListToMapList(PlayerData.Instance:GetCurrentRandActivityConfig().openserver_reward, "activity_type")
	end
	return self.activity_reward_cfg_list
end

function KaifuActivityData:GetKaifuActivityOpenCfg()
	if not self.open_cfg then
		self.open_cfg = ConfigManager.Instance:GetAutoConfig("randactivityopencfg_auto").open_cfg
	end
	return self.open_cfg
end

-- 获取战场争霸称号配置
function KaifuActivityData:GetBattleTitleCfg()
	if not self.opengameactivity_cfg then
		self.opengameactivity_cfg = ConfigManager.Instance:GetAutoConfig("opengameactivity_auto")
	end
	return self.opengameactivity_cfg.zhanchang_zhengba
end

function KaifuActivityData:GetOpenGameActCfg()
	if not self.opengameactivity_cfg then
		self.opengameactivity_cfg = ConfigManager.Instance:GetAutoConfig("opengameactivity_auto")
	end
	return self.opengameactivity_cfg
end

function KaifuActivityData:GetPersonalActivityCfgBySeq(seq)
	local list = self:GetPersonalActivityCfg()

	for k, v in pairs(list) do
		if v.seq == seq then
			return v
		end
	end
	return nil
end

function KaifuActivityData:GetEverydayActivityCfgBySeq(seq)
	local list = self:GetEverydayBuyActivityCfg()

	for k, v in pairs(list) do
		if v.seq == seq then
			return v
		end
	end
	return nil
end

function KaifuActivityData:GetPersonalActivityCfgBuyItem(item_id)
	if not OpenFunData.Instance:CheckIsHide("kaifuactivityview") then
		return {}
	end

	local list = self:GetPersonalActivityCfg()
	local data_list = {}

	for k, v in pairs(list) do
		if ShenyiData.Instance:IsShenyiStuff(item_id) then
			for k1,v1 in pairs(ShenyiData.Instance:GetShenyiUpStarPropCfg()) do
				if v.reward_item.item_id == v1.up_star_item_id then
					table.insert(data_list, v)
				end
			end
		elseif ShengongData.Instance:IsShengongStuff(item_id) then
			for k1,v1 in pairs(ShengongData.Instance:GetShengongUpStarPropCfg()) do
				if v.reward_item.item_id == v1.up_star_item_id then
					table.insert(data_list, v)
				end
			end
		elseif v.reward_item.item_id == item_id then
			table.insert(data_list, v)
		end
	end

	return data_list
end

function KaifuActivityData:GetPersonalActivityCfg()
	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local list = {}
	if not self.personal_panic_buy_cfg then
		self.personal_panic_buy_cfg = PlayerData.Instance:GetCurrentRandActivityConfig().personal_panic_buy
	end

	for k, v in pairs(self.personal_panic_buy_cfg) do
		if v.opengame_day == server_day then
			table.insert(list, v)
		end
	end
	return list
end

-- 获取百倍商城当天配置
function KaifuActivityData:GetPersonalActivitySortCfg()
	local list = self:GetPersonalActivityCfg()

	local sort_list = {}
	local value = DailyChargeData.Instance:GetLeiJiChongZhiValue()
	for k, v in pairs(self.personal_buy_info) do
		if list[k] then
			local temp_cfg = {}
			temp_cfg.seq = list[k].seq
			if v >= list[k].limit_buy_count then
				temp_cfg.flag = 0
			else
				temp_cfg.flag = 1
			end
			if value >= list[k].limit_charge_min and value < list[k].limit_charge_max then
				table.insert(sort_list, temp_cfg)
			elseif list[k].limit_charge_max == -1 and value >= list[k].limit_charge_min then
				table.insert(sort_list, temp_cfg)
			end
		end
	end

	table.sort(sort_list, function(a, b)
		if a.flag ~= b.flag then
			return a.flag > b.flag
		end
		return a.seq < b.seq
	end)

	return sort_list
end

-- 获取每日限购当天配置
function KaifuActivityData:GetEveryDayBuyActivitySortCfg()
	local list = self:GetEverydayBuyActivityCfg()
	return list
end

function KaifuActivityData:GetEverydayBuyActivityCfg()
	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local list = {}
	if not self.everyday_buy_cfg then
		local cfg = PlayerData.Instance:GetCurrentRandActivityConfig()
		if next(cfg) then
			self.everyday_buy_cfg = cfg.daily_limit_buy
		end
	end
	local act_type = self:GetEverydayBuyActType()
	for k, v in pairs(self.everyday_buy_cfg) do
		if v.act_type == act_type then
			table.insert(list, v)
		end
	end
	return list
end

function KaifuActivityData:GetRealGiftShopCfg()
	if self.opengameactivity_cfg == nil then
		return {}
	end
	return self.opengameactivity_cfg.gift_shop or {}
end

-- 礼包限购配置
function KaifuActivityData:GetGiftShopCfg()
	local cfg = {}
	local flag = self:GetGiftShopFlag()
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	for k, v in pairs(self.opengameactivity_cfg.gift_shop) do
		if role_vo.level >= v.level and role_vo.level <= v.max_level and role_vo.vip_level >= v.vip_level then
			local temp_cfg = {}
			temp_cfg.reward_item_list = {}
			temp_cfg.sort_key = flag[32 - v.seq] == 1 and v.seq + 100 or v.seq
			temp_cfg.flag = flag[32 - v.seq]
			for k2, v2 in pairs(v) do
				if type(v2) == "table" and v2.item_id and v2.item_id > 0 then
					local data = {item_id = v2.item_id, num = v2.num, is_bind = v2.is_bind}
					local index = tonumber(string.sub(k2, -1))
					temp_cfg.reward_item_list[index + 1] = data
				else
					temp_cfg[k2] = v2
				end
			end
			table.insert(cfg, temp_cfg)
		end
	end

	table.sort(cfg, SortTools.KeyLowerSorter("sort_key"))

	return cfg
end

-- 礼包限购的装备礼包是否已经购买
function KaifuActivityData:GetIsBuyGiftShopEquipGift()
	local flag = self:GetGiftShopFlag()
	if flag[27] == 1 and flag[28] == 1 and flag[31] == 1 and flag[32] == 1 then --写死装备四个礼包
		return true
	else
		return false
	end
end

function KaifuActivityData:GetKaifuActivityCfgByType(activity_type)
	local list = {}
	if activity_type == nil then return list end
	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	-- for k, v in pairs(self:GetKaifuActivityCfg()) do
	-- 	if v.activity_type == activity_type and (tonumber(v.opengame_day) > 100 or tonumber(v.opengame_day) == server_day) then
	-- 		table.insert(list, v)
	-- 	end
	-- end
	
	local activity_cfg = self:GetKaifuActivityCfgList()[activity_type]

	if activity_cfg then
		if #activity_cfg > 1 then
			for k, v in pairs(activity_cfg) do
				if (tonumber(v.opengame_day) > 100 or tonumber(v.opengame_day) == server_day) then
					table.insert(list, v)
				end
			end
		else
			table.insert(list, activity_cfg[1])
		end
	end
	return list
end

function KaifuActivityData:GetKfGuildFightCfg()
	local list = {}
	for k,v in pairs(self:GetKaifuActivityCfg()) do
		if v.activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GUILD_FIGHT then
			table.insert(list, v)
		end
	end

	return list
end

function KaifuActivityData:IsKaifuActivity(activity_type)
	if not activity_type then return false end

	for k, v in pairs(self:GetKaifuActivityOpenCfg()) do
		if v.activity_type == activity_type and v.is_openserver == 1 then
			return true
		end
	end

	return false
end

-- 不需要在开服活动面板上显示的活动
function KaifuActivityData:IsIgnoreType(activity_type)
	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MARRY_ME
		--or activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HONG_BAO
		-- or activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE
		or self:IsAdvanceRankType(activity_type)
		or activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN_RANK
		or activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE_RANK
		or self:IsZhengBaType(activity_type)
		or activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CORNUCOPIA
		or activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_RETURN
		or activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPLEVEL_RETURN_2
		or activity_type == COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BUYEXP
		or activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GODDES
		or activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPIRIT
		or activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIGHT_MOUNT_RANK
		or activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DISCOUNT_BUY_HOME
		or activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DISCOUNT_BUY_FURNITURE
		or activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PERSON_CAPABILITY
		or activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SAN_SHENG_SAN_SHI then

		return true
	end

	return false
end

function KaifuActivityData:CacheActivityList(list)
	self.cache_open_activity_list = list
end

function KaifuActivityData:DelCacheActivityList()
	self.cache_open_activity_list = nil
end

-- activity_type 小于100的用作合服活动
function KaifuActivityData:GetOpenActivityList(day)
	local kaifu_view = KaifuActivityCtrl.Instance:GetView()
	if kaifu_view and kaifu_view:IsOpen() and #self.final_list > 0 then
		return self.final_list
	end
	
	if nil ~= self.cache_open_activity_list then
		return self.cache_open_activity_list
	end

	local list = {}
	for k, v in pairs(self:GetKaifuActivityOpenCfg()) do
		if v.activity_type ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HONG_BAO and (not IS_CLOSE_ACTIVITY[v.activity_type]) and  ActivityData.Instance:GetActivityIsOpen(v.activity_type) and v.is_openserver == 1 and not self:IsIgnoreType(v.activity_type) then
			if self:IsBossLieshouType(v.activity_type) then
				if self:IsShowBossTab() then
					--table.insert(list, v)
					list[v.activity_type] = v
				end
			elseif v.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO then
				local chongzhi_info = self:GetChongZhiGao()
				if chongzhi_info ~= nil then
					local can_fetch_flag_list = bit:d2b(chongzhi_info.can_fetch_reward_flag)
					local has_fetch_flag_list = bit:d2b(chongzhi_info.has_fetch_reward_falg)
					local cfg = self:ChongZhiTeHuiGao() or {}
					local flag = false
					for k1, v1 in pairs(cfg) do
						if v1 ~= nil and can_fetch_flag_list ~= nil and has_fetch_flag_list ~= nil and (can_fetch_flag_list[32 - v1.day_index] == 0 or has_fetch_flag_list[32 - v1.day_index] == 0) then
							flag = true
							break
						end
					end
					if flag then
						list[v.activity_type] = v
					end
				end 
			else
				list[v.activity_type] = v
			end
		elseif v.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HONG_BAO then
			if TimeCtrl.Instance:GetCurOpenServerDay() < 8 or (not ActiviteHongBaoData.Instance:IsGetAll() or ActiviteHongBaoData.Instance:IsRead()) then
				list[v.activity_type] = v
			end
		end
	end
	-- local open_day = KaifuActivityData.Instance:GetBaojiDayActType() or 1
	local reward_list = KaifuActivityData.Instance:GetKaifuActivityCfgByType(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QUAN_MIN_JIN_JIE)
	local jinjie_type = 1
	if reward_list and next (reward_list) then
		jinjie_type = reward_list[1].cond1 + 1
	end
	local baojiri_act_type = KaifuActivityData.Instance:GetBaojiDayActType() or 1
	local baojiri_act_type_2 = KaifuActivityData.Instance:GetBaojiDay2ActType() or 1
	local upgrade_return_info1 = KaifuActivityData.Instance:GetUpGradeReturnInfo()
	local act_type_1 = upgrade_return_info1.act_type or 1
	local upgrade_return_info2 = KaifuActivityData.Instance:GetUpGradeReturnInfo2()
	local act_type_2 = upgrade_return_info2.act_type or 1
	for i,v in ipairs(OPEN_SERVER_RA_ACTIVITY_TYPE) do		
		if ActivityData.Instance:GetActivityIsOpen(v) then
			if v == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BAOJI_DAY then
				list[v] = {activity_type = v, name = Language.Activity.BaojiDay[baojiri_act_type]}
			elseif v == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CRITICAL_STRIKE_DAY_2 then
				list[v] = {activity_type = v, name = Language.Activity.BaojiDay[baojiri_act_type_2]}
			elseif v == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QUAN_MIN_JIN_JIE then
				list[v] = {activity_type = v, name = Language.Activity.QUANMINGJJ[jinjie_type]}
			-- elseif v == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_RETURN then
				-- list[v] = {activity_type = v, name = Language.Activity.UpGradeReturnName[act_type_1]}
			-- elseif v == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPLEVEL_RETURN_2 then
			-- 	list[v] = {activity_type = v, name = Language.Activity.UpGradeReturnName[act_type_2]}
			else
				list[v] = {activity_type=v, name = Language.Activity.KaiFuActivityName[v]}
			end
			-- table.insert(list, {activity_type=v, name=Language.Activity.KaiFuActivityName[v]})
		end
	end
	for _, v in pairs(self:GetTempAddActivityTypeList()) do
		if v.activity_type == TEMP_ADD_ACT_TYPE.WELFARE_LEVEL_ACTIVITY_TYPE then
			local welfare_cfg = WelfareData.Instance:GetLevelRewardCfg()
			for k1, v1 in pairs(welfare_cfg) do
				if v1 ~= nil then
					local has_get_count = WelfareData.Instance:GetHasGetCountByIndex(v1.index)
					local left_count = v1.limit_num - has_get_count
					if WelfareData.Instance:GetLevelRewardFlag(v1.index) ~= 1 and (v1.is_limit_num ~= 1 or left_count > 0) then
						list[v.activity_type] = v
						break
					end
				end
			end
		elseif v.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO then
			local chongzhi_info = self:GetChongZhiGao()
			if chongzhi_info ~= nil then
				local can_fetch_flag_list = bit:d2b(chongzhi_info.can_fetch_reward_flag)
				local has_fetch_flag_list = bit:d2b(chongzhi_info.has_fetch_reward_falg)
				local cfg = self:ChongZhiTeHuiGao() or {}
				local flag = false
				for k1, v1 in pairs(cfg) do
					if v1 ~= nil and can_fetch_flag_list ~= nil and has_fetch_flag_list ~= nil and (can_fetch_flag_list[32 - v1.day_index] == 0 or has_fetch_flag_list[32 - v1.day_index] == 0) then
						flag = true
						break
					end
				end
				if flag then
					list[v.activity_type] = v
				end
			end
		elseif v.activity_type == TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_MONTHCARDINVESTMENT then
			local monthcardinvestment_cfg = ActivityData.Instance:GetClockActivityByID(v.activity_type)
			if monthcardinvestment_cfg and monthcardinvestment_cfg.opensever_day and monthcardinvestment_cfg.min_level then
				local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
				if (TimeCtrl.Instance:GetCurOpenServerDay() >= tonumber(monthcardinvestment_cfg.opensever_day)) and (main_role_vo.level >= monthcardinvestment_cfg.min_level) then
					list[v.activity_type] = v
				end
			end
		else
			list[v.activity_type] = v
		end
	end
	for k,v in pairs(RandActivityInKaifuView) do
		if ActivityData.Instance:GetActivityIsOpen(v.activity_type) then
			--if  v.activity_type ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BAOJI_DAY or v.activity_type ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BAOJI_DAY  then
				list[v.activity_type] = v
			--end
		end
	end

	-- 合服活动（他喵的这块代码贼恶心，真心不想往这里加代码）
	local hefu_list = HefuActivityData.Instance:GetCombineSubActivityList()
	for i,v in ipairs(hefu_list) do
		--合服经验,城主争夺,盟主争霸不在这显示
		if v.sub_type ~= COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BUYEXP 
			and v.sub_type ~= COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_GONGCHENGZHAN 
				and v.sub_type ~= COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_XIANMENGZHAN then 
			list[v.sub_type] = v
		end
	end

	local temp_list = {}
	for _, v in ipairs(ACTIVITY_SORT_INDEX_LIST) do 
		local activity = list[v]
		if activity ~= nil  then
			table.insert(temp_list, activity)
			list[v] = nil
		end
	end

	for _, v in pairs(list) do
		table.insert(temp_list, v)
	end
	-- 成长基金，等级超出并且领完返利则不显示该活动
	local today_recharge = DailyChargeData.Instance:GetChongZhiInfo().today_recharge
	for i = #temp_list, 1, -1 do
	-- for k, v in pairs(temp_list) do
		local v = temp_list[i]
		if v.activity_type == TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_GROWUP_INVESTMENT then
			if self:CanShowTouZiPlan() then
				table.remove(temp_list, i)
			end
		elseif v.activity_type == TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_FuBenTouZi then
			-- if self:IsAllFetchFBTouZi() == true then
				table.remove(temp_list, i)
			-- end
		elseif v.activity_type == TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_ShenYuBossTouZi then
			-- if self:IsAllFetchShenYuBossTouZi() == true then
				table.remove(temp_list, i)
			-- end
		elseif v.activity_type == TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_BossTouZi then--BOSS投资和副本投资分出去
			-- if self:IsAllFetchBossTouZi() == true then
				table.remove(temp_list, i)
			-- end
		elseif v.activity_type == ACTIVITY_TYPE.RAND_DAILY_LOVE then
			if today_recharge and today_recharge > 0 then
				table.remove(temp_list, i)
			end

		elseif v.activity_type == TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_LEVEL_INVESTMENT then
			if self:TouZiButtonInfo() then
				table.remove(temp_list, i)
			end
		elseif v.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RARE_CHANGE then
			--暂时不开启珍宝兑换活动
			table.remove(temp_list, i)
		elseif v.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE then
			table.remove(temp_list, i)
		elseif v.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_JUBAOPEN   then
			if self:JuBaoPanButtonInfo() then
				table.remove(temp_list, i)
			end
		end
	end

	local final_list = {}
	for k, v in ipairs(temp_list) do
		-- 主界面开服活动精彩活动面板里面的活动，去H-活动显示配置这张表取开启的最低等级
		if v.activity_type then
			if self:IsReachMinLevel(v.activity_type) == true then
				table.insert(final_list, v)
			end
		elseif v.sub_type then
			if self:IsReachCombineActMinLevel(v.sub_type) == true then
				table.insert(final_list, v)
			end			
		end
	end
	self.final_list = final_list
	return final_list
end

function KaifuActivityData:IsReachMinLevel(activity_type)
	local cfg = ActivityData.Instance:GetActivityConfig(activity_type)
	local min_level = 50
	if cfg and cfg.min_level then
		min_level = cfg.min_level
	end
	local role_level = PlayerData.Instance:GetRoleLevel()
	if role_level < min_level then
		return false
	end
	return true
end

function KaifuActivityData:IsReachCombineActMinLevel(sub_type)
	local cfg = HefuActivityData.Instance:GetKaifuActivityOpenCfg()
	for k, v in ipairs(cfg) do
		if v and v.sub_type and v.sub_type == sub_type then
			local min_level = 50
			if v and v.min_level then
				min_level = v.min_level
			end
			local role_level = PlayerData.Instance:GetRoleLevel()
			if role_level < min_level then
				return false
			end
			return true
		end
	end
end

-- 从别的地方加进来的，类似冲级豪礼
function KaifuActivityData:GetTempAddActivityTypeList()
	local list = {}
	local openchu_start, openchu_end = KaifuActivityData.Instance:GetActivityOpenDay(TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU)
	local opengao_start, opengao_end = KaifuActivityData.Instance:GetActivityOpenDay(TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO)
	local openchu_time = openchu_end - TimeCtrl.Instance:GetServerTime()
	local opengao_time = opengao_end - TimeCtrl.Instance:GetServerTime()

	for i = 1, #TempAddActivityType do
		local cfg = {}
		if opengao_time <= 0 and openchu_time > 0 then
			if TempAddActivityType[i].activity_type ~= TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO then
				cfg.activity_type = TempAddActivityType[i].activity_type
				cfg.name = TempAddActivityType[i].name
				table.insert(list, cfg)
			end
		elseif opengao_time > 0 and openchu_time <= 0 then
			if TempAddActivityType[i].activity_type ~= TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU then
				cfg.activity_type = TempAddActivityType[i].activity_type
				cfg.name = TempAddActivityType[i].name
				table.insert(list, cfg)
			end
		elseif opengao_time <= 0 and openchu_time <= 0 then
			if TempAddActivityType[i].activity_type ~= TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO and TempAddActivityType[i].activity_type ~= TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU then
				cfg.activity_type = TempAddActivityType[i].activity_type
				cfg.name = TempAddActivityType[i].name
				table.insert(list, cfg)
			end
		elseif opengao_time > 0 and openchu_time > 0 then
			cfg.activity_type = TempAddActivityType[i].activity_type
			cfg.name = TempAddActivityType[i].name
			table.insert(list, cfg)
		end
	end
	return list
end

function KaifuActivityData:GetTempActivityCfg(activity_type)
	if not activity_type then return nil end

	if activity_type == TEMP_ADD_ACT_TYPE.WELFARE_LEVEL_ACTIVITY_TYPE then
		return
	end

	return nil
end

function KaifuActivityData:IsTempAddType(activity_type)
	if activity_type == nil then return false end
	for k, v in pairs(TempAddActivityType) do
		if v.activity_type == activity_type then
			return true
		end
	end
	return false
end

function KaifuActivityData:IsAdvanceType(activity_type)
	if activity_type == nil then return false end
	for k, v in pairs(AdvanceType) do
		if RankType[k] and RankType[k] == activity_type then
			return true
		end
		if v == activity_type then
			return true
		end
	end
	return false
end

function KaifuActivityData:IsAdvanceRankType(activity_type)
	if activity_type == nil then return false end
	for k, v in pairs(RankType) do
		if v == activity_type then
			return true
		end
	end
	return false
end

function KaifuActivityData:IsNomalType(activity_type)
	if activity_type == nil then return false end
	for k, v in pairs(NormalType) do
		if NormalType[k] and NormalType[k] == activity_type then
			return true
		end
		if v == activity_type then
			return true
		end
	end
	return false
end
function KaifuActivityData:IsChongJiType(activity_type)
	if activity_type == nil then return false end
	if RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ROLE_UPLEVEL == activity_type then
		return true
	end
	return false
end

function KaifuActivityData:IsPaTaType(activity_type)
	if activity_type == nil then return false end
	if RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PATA == activity_type then
		return true
	end
	return false
end

function KaifuActivityData:IsExpChallengeType(activity_type)
	if activity_type == nil then return false end
	if RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_FB == activity_type then
		return true
	end
	return false
end

function KaifuActivityData:IsChongzhiType(activity_type)
	if activity_type == nil then return false end
	for k, v in pairs(ChongzhiType) do
		if v == activity_type then
			return true
		end
	end
	return false
end

function KaifuActivityData:IsStrengthenType(activity_type)
	if activity_type == nil then return false end
	for k, v in pairs(StrengthenType) do
		if v == activity_type then
			return true
		end
	end
	return false
end

function KaifuActivityData:IsBossLieshouType(activity_type)
	if activity_type == nil then return false end
	for k, v in pairs(BossType) do
		if v == activity_type then
			return true
		end
	end
	return false
end

function KaifuActivityData:IsZhengBaType(activity_type)
	if activity_type == nil then return false end

	if RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ZHENG_BA == activity_type then
		return true
	end
	return false
end

function KaifuActivityData:GetCondByType(activity_type)
	if activity_type == nil then return nil end
	local mount_grade = MountData.Instance:GetMountInfo().grade
	local mount_grade_cfg = MountData.Instance:GetMountGradeCfg(mount_grade)

	local wing_grade = WingData.Instance:GetWingInfo().grade
	local wing_grade_cfg = WingData.Instance:GetWingGradeCfg(wing_grade)

	local fashion_grade = FashionData.Instance:GetFashionInfo().grade
	local fashion_grade_cfg = FashionData.Instance:GetShiZhuangGradeCfg(fashion_grade)

	local wuqi_grade = FashionData.Instance:GetWuQiInfo().grade
	local wuqi_grade_cfg = FashionData.Instance:GetShenBingGradeCfg(wuqi_grade)

	local fabao_grade = FaBaoData.Instance:GetFaBaoInfo().grade
	local fabao_grade_cfg = FaBaoData.Instance:GetFaBaoGradeCfg(fabao_grade)

	local foot_grade = FootData.Instance:GetFootInfo().grade
	local foot_grade_cfg = FootData.Instance:GetFootGradeCfg(foot_grade)

	local halo_grade = HaloData.Instance:GetHaloInfo().grade
	local halo_grade_cfg = WingData.Instance:GetWingGradeCfg(halo_grade)

	local shengong_grade = ShengongData.Instance:GetShengongInfo().grade
	local shengong_grade_cfg = ShengongData.Instance:GetShengongGradeCfg(shengong_grade)

	local shenyi_grade = ShenyiData.Instance:GetShenyiInfo().grade
	local shenyi_grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(shenyi_grade)

	local game_vo = GameVoManager.Instance:GetMainRoleVo()

	local gemstone_level = ForgeData.Instance:GetGemTotalLevel()

	-- 坐骑进阶
	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_MOUNT then
		return mount_grade_cfg and mount_grade_cfg.show_grade or 0, 1

	-- 羽翼进阶
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING then
		return wing_grade_cfg and wing_grade_cfg.show_grade or 0, 2

	-- 光环进阶
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_HALO then
		return halo_grade_cfg and halo_grade_cfg.show_grade or 0, 7

	-- 神弓进阶
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENGONG then
		return shengong_grade_cfg and shengong_grade_cfg.show_grade or 0, 8

	-- 神翼进阶
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENYI then
		return shenyi_grade_cfg and shenyi_grade_cfg.show_grade or 0, 9

	-- 冲级大礼
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ROLE_UPLEVEL then
		return game_vo.level or 0, 6

	-- 爬塔副本
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PATA then
		local fb_info = FuBenData.Instance:GetTowerFBInfo()
		if fb_info then
			return fb_info.pass_level or 0, 10
		end
		return 0, 10

	-- 经验副本
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_FB then
		return FuBenData.Instance:GetExpFBInfo().expfb_pass_wave or 0, 11

	-- 每日累充
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_TOTAL_CHARGE then
		return DailyChargeData.Instance:GetChongZhiInfo().today_recharge

	-- 首充团购
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIRST_CHARGE_TUAN then
		if self.info[activity_type] and self.info[activity_type].rand_activity_type and self.info[activity_type].rand_activity_type == activity_type then
			return  DailyChargeData.Instance:GetChongZhiInfo().today_recharge, self.info[activity_type].today_chongzhi_role_count
		end
		return DailyChargeData.Instance:GetChongZhiInfo().today_recharge

	-- 累计充值
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE then
		if self.leiji_chongzhi_info and self.leiji_chongzhi_info.total_charge_value then
			return self.leiji_chongzhi_info.total_charge_value
		end
		return 0

	-- 全服坐骑进阶
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_MOUNT_TOTAL then
		if self.upgrade_info[activity_type] and self.upgrade_info[activity_type] and self.upgrade_info[activity_type].rand_activity_type == activity_type then
			return mount_grade_cfg and mount_grade_cfg.show_grade or 0, 1, self.upgrade_info[activity_type].total_upgrade_record_list
		end
		return mount_grade_cfg and mount_grade_cfg.show_grade or 0, 1

	-- 全服羽翼进阶
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING_TOTAL then
		if self.upgrade_info[activity_type] and self.upgrade_info[activity_type].rand_activity_type == activity_type then
			return wing_grade_cfg and wing_grade_cfg.show_grade or 0, 2, self.upgrade_info[activity_type].total_upgrade_record_list
		end
		return wing_grade_cfg and wing_grade_cfg.show_grade or 0, 2

	-- 全服光环进阶
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_HALO_TOTAL then
		if self.upgrade_info[activity_type] and self.upgrade_info[activity_type].rand_activity_type == activity_type then
			return halo_grade_cfg and halo_grade_cfg.show_grade or 0, 3, self.upgrade_info[activity_type].total_upgrade_record_list
		end
		return halo_grade_cfg and halo_grade_cfg.show_grade or 0, 3

	-- 全服神弓进阶
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENGONG_TOTAL then
		if self.upgrade_info[activity_type] and self.upgrade_info[activity_type].rand_activity_type == activity_type then
			return shengong_grade_cfg and shengong_grade_cfg.show_grade or 0, 4, self.upgrade_info[activity_type].total_upgrade_record_list
		end
		return shengong_grade_cfg and shengong_grade_cfg.show_grade or 0, 4

	-- 全服神翼进阶
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENYI_TOTAL then
		if self.upgrade_info[activity_type] and self.upgrade_info[activity_type].rand_activity_type == activity_type then
			return shenyi_grade_cfg and shenyi_grade_cfg.show_grade or 0, 5, self.upgrade_info[activity_type].total_upgrade_record_list
		end
		return shenyi_grade_cfg and shenyi_grade_cfg.show_grade or 0, 5

	-- 坐骑进阶排行榜
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_MOUNT_RANK then
		return mount_grade_cfg and mount_grade_cfg.show_grade or 0, 1

	-- 羽翼进阶排行榜
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING_RANK then
		return wing_grade_cfg and wing_grade_cfg.show_grade or 0, 2

	-- 时装进阶
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FASHION_RANK then
		return fashion_grade_cfg and fashion_grade_cfg.show_grade or 0, 3

	-- 神兵进阶
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WUQI_RANK then
		return wuqi_grade_cfg and wuqi_grade_cfg.show_grade or 0, 4

	-- 法宝进阶
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FABAO_RANK then
		return fabao_grade_cfg and fabao_grade_cfg.show_grade or 0, 5

	-- 足迹进阶
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FOOT_RANK then
		return foot_grade_cfg and foot_grade_cfg.show_grade or 0, 6


	-- 光环进阶排行榜
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_HALO_RANK then
		return halo_grade_cfg and halo_grade_cfg.show_grade or 0, 7

	-- 神弓进阶排行榜
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENGONG_RANK then
		return shengong_grade_cfg and shengong_grade_cfg.show_grade or 0, 8

	-- 神翼进阶排行榜
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENYI_RANK then
		return shenyi_grade_cfg and shenyi_grade_cfg.show_grade or 0, 9

	-- 装备强化
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN
			or activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN_RANK then
		return game_vo.total_strengthen_level or 0, 12

	-- 宝石升级
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE
			or activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE_RANK then
		return gemstone_level, 13
	end
	return nil
end

function KaifuActivityData:GetJinjieTypeShowGrade(jinjie_type, grade)
	if jinjie_type == nil then return nil end

	if jinjie_type == 1 then
		return (MountData.Instance:GetMountGradeCfg(grade) ~= nil) and MountData.Instance:GetMountGradeCfg(grade).show_grade or 0
	elseif jinjie_type == 2 then
		return (WingData.Instance:GetWingGradeCfg(grade) ~= nil) and WingData.Instance:GetWingGradeCfg(grade).show_grade or 0
	elseif jinjie_type == 3 then
		return (HaloData.Instance:GetHaloGradeCfg(grade) ~= nil) and HaloData.Instance:GetHaloGradeCfg(grade).show_grade or 0
	elseif jinjie_type == 4 then
		return (ShengongData.Instance:GetShengongGradeCfg(grade) ~= nil) and ShengongData.Instance:GetShengongGradeCfg(grade).show_grade or 0
	elseif jinjie_type == 5 then
		return (ShenyiData.Instance:GetShenyiGradeCfg(grade) ~= nil) and ShenyiData.Instance:GetShenyiGradeCfg(grade).show_grade or 0
	end
	return nil
end

function KaifuActivityData:JingCaiActivityPoint()
	if DelayOnceRemindList[RemindName.JingCai_Act_Delay] then
		return 0
	end
	if self:LianChongTeHuiChuHongDian() >= 1 then
		return 1
	end
	if self:LianChongTeHuiGaoHongDian() >= 1 then
		return 1
	end
	if self:GetNewServerRemind() >= 1 then
		return 1
	end
	return 0
end

function KaifuActivityData:GetTouziActivityRemind()
	if self:IsShowFuBenTouZiRedPoint() then
		--副本投资红点到最低等级才算
		if self:IsReachMinLevel(TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_FuBenTouZi) == true then
			return 1
		end
	end

	if self:IsShowBossTouZiRedPoint() then
		--Boss投资红点到最低等级才算
		if self:IsReachMinLevel(TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_BossTouZi) == true then
			return 1
		end
	end

	if self:IsShowShenYuBossTouZiRedPoint() then
		--Boss投资红点到最低等级才算
		if self:IsReachMinLevel(TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_ShenYuBossTouZi) == true then
			return 1
		end
	end
	return 0
end

function KaifuActivityData:GetNewServerRemind()
	local num = 0
	if self:IsShowJiZiRedPoint() then
		--集字活动红点到最低等级才算
		if self:IsReachMinLevel(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION) == true then
			return 1
		end
	end
	if WelfareData.Instance:GetLevelRewardRemind() > 0 then
		--冲级豪礼红点到最低等级才算
		if self:IsReachMinLevel(TEMP_ADD_ACT_TYPE.WELFARE_LEVEL_ACTIVITY_TYPE) == true then
			return 1
		end
	end

	if self.info ~= nil and next(self.info) ~= nil then
		for k, v in pairs(self.info) do
			-- 冲级豪礼上面有判断 WelfareData.Instance:GetLevelRewardRemind() ，故这里剔除
			if k ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ROLE_UPLEVEL and k ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BOSS_LIESHOU then
				local bit_reward_list = nil
				local bit_complete_list = nil
				if v.complete_flag and not self:IsIgnoreType(k) then
					if v.reward_flag then
						bit_reward_list = bit:d2b(v.reward_flag)
					end
					bit_complete_list = bit:d2b(v.complete_flag)
					if bit_complete_list and bit_reward_list then
						for k2, v2 in pairs(bit_complete_list) do
							if v2 == 1 and bit_reward_list[k2] ~= 1 then
								if k == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIRST_CHARGE_TUAN then
									--首充团购红点到最低等级才算
									if self:IsReachMinLevel(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIRST_CHARGE_TUAN) == true then
										return 1
									end
								else
									return 1
								end								
							end
						end
					end
				end
			end
		end
	end

	if self:IsShowBossRedPoint() then
		return 1
	end

	if self:IsShowQuanMinJinJieRedPoint() then
		--全民进阶红点到最低等级才算
		if self:IsReachMinLevel(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QUAN_MIN_JIN_JIE) == true then
			return 1
		end
	end

	if self:IsShowQuanMinZongDongRedPoint() then
		return 1
	end

	if self:IsShowSingleDayRedPoint() then
		--单日累充红点到最低等级才算
		if self:IsReachMinLevel(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_SINGLE_DAY_CHARGE) == true then
			return 1
		end
	end

	if RechargeData.Instance:IsCanGetReward() then
		--至尊会员红点到最低等级才算
		if self:IsReachMinLevel(TEMP_ADD_ACT_TYPE.SUPREME_MEMBERS) == true then
			return 1
		end
	end

	if self:GetLiBaoBuyRemindRed() then
		--礼包抢购红点到最低等级才算
		if self:IsReachMinLevel(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPPER_GIFT) == true then
			return 1
		end		
	end

	if self:LianChongTeHuiGaoRedPoint() then
		--连充特惠高红点到最低等级才算
		if self:IsReachMinLevel(TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO) == true then
			return 1
		end
	end

	if self:LianChongTeHuiChuRedPoint() then
		--连充特惠初红点到最低等级才算
		if self:IsReachMinLevel(TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU) == true then
			return 1
		end
	end

	-- if self:IsShowLeiJiChongZhiRedPoint() then
	-- 	num = num + 1
	-- end

	if self:IsShowJubaoPenRedPoint() then
		--点石成金红点到最低等级才算
		if self:IsReachMinLevel(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_JUBAOPEN) == true then
			return 1
		end
	end

	-- if self:IsShowUpGradeRedPoint() then
	-- 	--进阶返还1红点到最低等级才算
	-- 	if self:IsReachMinLevel(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_RETURN) == true then
	-- 		num = num + 1
	-- 	end
	-- end

	-- if self:IsShowUpGrade2RedPoint() then
	-- 	--进阶返还2红点到最低等级才算
	-- 	if self:IsReachMinLevel(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPLEVEL_RETURN_2) == true then
	-- 		num = num + 1
	-- 	end
	-- end

	if ActiviteHongBaoData.Instance:GetHongBaoRemind() then
		return 1
	end

	if self:ShowInvestRedPoint() then
		return 1
	end
	if self:IsShowDayActiveRedPoint() then
		return 1
	end

	if self:IsTotalConsumeRedPoint() then
		--累计消费红点到最低等级才算
		if self:IsReachMinLevel(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CONSUME) == true then
			return 1
		end
	end

	if self:IsDialyTotalConsumeRedPoint() then
		--每日消费红点到最低等级才算
		if self:IsReachMinLevel(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CONSUME_GOLD) == true then
			return 1
		end
	end

	if self:GetLeiJiChargeRewardRedPoint() then
		--充值回馈红点到最低等级才算
		if self:IsReachMinLevel(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHARGE_REPALMENT) == true then
			return 1
		end
	end

	if self:IsTotalChargeRedPoint() then
		if self:IsReachMinLevel(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CHARGE) == true then
			return 1
		end
	end

	if self:IsRechargeRebateRedPoint() then
		--充值返利红点到最低等级才算
		if self:IsReachMinLevel(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_DAY_CHONGZHI_FANLI) == true then
			return 1
		end
	end

	
	if self:IsShowKFGuildFightRedPoint() then
		return 1
	end

	-------------------合服的小红点---------------
	if self:IsHeFu(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_LOGIN_Gift) and
		HefuActivityData.Instance:GetShowRedPointBySubType(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_LOGIN_Gift) == true then
		--登录奖励红点到最低等级才算
		if self:IsReachCombineActMinLevel(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_LOGIN_Gift) == true then
			return 1
		end	
	end

	if HefuActivityData.Instance:IsShowHeFuJiJinRedPoint() then
		--合服基金红点到最低等级才算
		if self:IsReachCombineActMinLevel(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_JIJIN) == true then
			return 1
		end	
	end

	if HefuActivityData.Instance:IsShowHeFuTouZiRedPoint() then
		--合服投资红点到最低等级才算
		if self:IsReachCombineActMinLevel(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_TOUZI) == true then
			return 1
		end	
	end

	if self:IsHeFu(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_KILL_BOSS) and
		HefuActivityData.Instance:GetShowRedPointBySubType(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_KILL_BOSS) == true then
		--BOSS抢夺红点到最低等级才算
		if self:IsReachCombineActMinLevel(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_KILL_BOSS) == true then
			return 1
		end	
	end

	if HefuActivityData.Instance:IsShowOnceADayRedPoint(RemindName.QiangGou) then
		--抢购第一红点到最低等级才算
		if self:IsReachCombineActMinLevel(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_RANK_QIANGGOU) == true then
			return 1
		end	
	end

	if HefuActivityData.Instance:IsShowOnceADayRedPoint(RemindName.ChongZhiRank) then
		--充值排行红点到最低等级才算
		if self:IsReachCombineActMinLevel(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_CHONGZHI_RANK) == true then
			return 1
		end	
	end

	if HefuActivityData.Instance:GetLucklyTurnRedPoint() > 0 then
		--幸运转盘红点到最低等级才算
		if self:IsReachCombineActMinLevel(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_ROLL) == true then
			return 1
		end	
	end

	if HefuActivityData.Instance:IsShowBossLooyRedPoint(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_KILL_BOSS) then
		--BOSS抢夺红点到最低等级才算
		if self:IsReachCombineActMinLevel(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_KILL_BOSS) == true then
			return 1
		end	
	end

	if ExpenseGiftData.Instance:GetExpenseGiftRemind() > 0 then
		--消费领奖红点到最低等级才算
		if self:IsReachMinLevel(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVEIY_TYPE_CONSUMPTION_AWARD) == true then
			return 1
		end	
	end

	if self:IsHuanLeLeichongRemind() then
		--欢乐累充红点到最低等级才算
		if self:IsReachMinLevel(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPY_RECHARGE) == true then
			return 1
		end	
	end

	-- if self:DailyGiftRedPoint() > 0 then
	-- 	num = num + 1
	-- end

	if self:IsShowDanBiChongZhiRedPoint() then
		--单次充值红点到最低等级才算
		if self:IsReachMinLevel(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBI_CHONGZHI) == true then
			return 1
		end	
	end

	if self:IsShowChongZhiRankRedPoint() then
		--每日充值排行红点到最低等级才算
		if self:IsReachMinLevel(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CHONGZHI_RANK) == true then
			return 1
		end	
	end

	if self:IsShowXiaoFeiRankRedPoint() then
		--每日消费排行红点到最低等级才算
		if self:IsReachMinLevel(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_XIAOFEI_RANK) == true then
			return 1
		end	
	end

	if InvestData.Instance:GetMonthInvestRemind() > 0 then
		--周卡投资红点到最低等级才算
		if self:IsReachMinLevel(TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_MONTHCARDINVESTMENT) == true then
			return 1
		end		
	end

	if InvestData.Instance:GetNormalInvestRemind() > 0 then
		--等级投资红点到最低等级才算
		if self:IsReachMinLevel(TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_LEVEL_INVESTMENT) == true then
			return 1
		end	
	end

	if self:IsTouZiPlanRedPoint() then
		--成长基金红点到最低等级才算
		if self:IsReachMinLevel(TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_GROWUP_INVESTMENT) == true then
			return 1
		end
	end

	-- if self:IsShowFuBenTouZiRedPoint() then
	-- 	--副本投资红点到最低等级才算
	-- 	if self:IsReachMinLevel(TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_FuBenTouZi) == true then
	-- 		return 1
	-- 	end
	-- end

	-- if self:IsShowBossTouZiRedPoint() then
	-- 	--副本投资红点到最低等级才算
	-- 	if self:IsReachMinLevel(TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_BossTouZi) == true then
	-- 		return 1
	-- 	end
	-- end

	if self:GetQuanFuBuyRemindRed() then
		--全服抢购红点到最低等级才算
		if self:IsReachMinLevel(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FULL_SERVER_SNAP) == true then
			return 1
		end
	end

	if self:GetPersonBuyRemindRed() then
		--个人抢购红点到最低等级才算
		if self:IsReachMinLevel(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUNDER_TIMES_SHOP) == true then
			return 1
		end
	end

	if self:GetEveryDayBuyRemindRed() then
		--每日限购红点到最低等级才算
		if self:IsReachMinLevel(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EVERY_DAY_SNAP) == true then
			return 1
		end
	end

	if self:IsDailyDanBiRedPoint() then
		--每日单笔红点到最低等级才算
		if self:IsReachMinLevel(ACTIVITY_TYPE.RAND_DAY_DANBI_CHONGZHI) == true then
			return 1
		end
	end	

	----------------------------------------------
	return num
end

function KaifuActivityData:IsHeFu(sub_type)
	local data = self:GetOpenActivityList()
	for i,v in pairs(data) do
		if v.sub_type ~= nil and v.sub_type == sub_type then
			return true
		end
	end
	return false
end

function KaifuActivityData:IsGetReward(index, activity_type)
	if index == nil or activity_type == nil then return false end
	if self.info[activity_type] and self.info[activity_type].reward_flag then
		local bit_reward_list = bit:d2b(self.info[activity_type].reward_flag)
		if bit_reward_list then
			for k, v in pairs(bit_reward_list) do
				if v == 1 and (32 - k) == index then
					return true
				end
			end
		end
	end
	return false
end

function KaifuActivityData:IsComplete(index, activity_type)
	if index == nil or activity_type == nil then return false end
	local my_gold = DailyChargeData.Instance:GetChongZhiInfo().today_recharge or 0 
	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIRST_CHARGE_TUAN  and self.click_sctg  and my_gold < 388 then
		return self.click_sctg
	end
	if self.info[activity_type] and self.info[activity_type].complete_flag then
		local bit_complete_list = bit:d2b(self.info[activity_type].complete_flag)
		if bit_complete_list then
			for k, v in pairs(bit_complete_list) do
				if v == 1 and (32 - k) == index then
					return true
				end
			end
		end
	end
	return false
end

function KaifuActivityData:SortList(activity_type, cfg_list)
	if activity_type == nil then return nil end

	cfg_list = cfg_list or self:GetKaifuActivityCfgByType(activity_type)
	local temp_list = {}
	for k, v in pairs(cfg_list) do
		if self:IsGetReward(v.seq, activity_type) and self:IsComplete(v.seq, activity_type) then
			temp_list[k] = {}
			temp_list[k].sort_value = 2
			temp_list[k].seq = v.seq
			temp_list[k].k = k
		elseif not self:IsGetReward(v.seq, activity_type) and self:IsComplete(v.seq, activity_type) then
			temp_list[k] = {}
			temp_list[k].sort_value = 0
			temp_list[k].seq = v.seq
			temp_list[k].k = k
		elseif not self:IsGetReward(v.seq, activity_type) and not self:IsComplete(v.seq, activity_type) then
			temp_list[k] = {}
			temp_list[k].sort_value = 1
			temp_list[k].seq = v.seq
			temp_list[k].k = k
		elseif self:IsGetReward(v.seq, activity_type) and not self:IsComplete(v.seq, activity_type) then
			temp_list[k] = {}
			temp_list[k].sort_value = 2
			temp_list[k].seq = v.seq
			temp_list[k].k = k
		end
	end

	table.sort(temp_list, function (a, b)
		if a and b then
			return a.sort_value == b.sort_value and a.seq < b.seq or a.sort_value < b.sort_value
		end
	end)
	local sort_list = {}
	for k,v in ipairs(temp_list) do
		table.insert(sort_list, cfg_list[v.k])
	end
	return sort_list
end

-- 获取显示boss列表
-- is_show_reward 是否获取奖励配置,默认获取boss列表
function KaifuActivityData:GetShowBossList(index, is_show_reward)
	if not index then return {} end

	local all_list = {}

	-- index 从 0 开始
	for k, v in pairs(self:GetOpenGameActCfg().kill_boss_reward) do
		local list = {}

		for i = 1, 4 do
			if v["boss_seq_"..i] and self:GetOpenGameActCfg().kill_boss[v["boss_seq_"..i]] then
					table.insert(list, self:GetOpenGameActCfg().kill_boss[v["boss_seq_"..i]])
			end
		end
			all_list[v.seq + 1] = list
			all_list[v.seq + 1].seq = v.seq
	end

	for k, v in pairs(all_list) do
		local is_complete, count = self:GetBossIsComplete(k - 1)
		local is_get = self:GetBossRewardIsGet(k - 1)

		v.flag = 1

		if is_get and is_complete then
			v.flag = 0
		end
		if is_complete and not is_get then
			v.flag = 2
		end
		v.count = count
	end

	table.sort(all_list, function(a, b)
		if a.flag ~= b.flag then
			return a.flag > b.flag
		end

		if a.count ~= b. count then
			return a.count > b. count
		end

		return a.seq < b.seq
	end)


	for k, v in pairs(all_list) do
		if v.seq == index then
			if is_show_reward then
				return self:GetOpenGameActCfg().kill_boss_reward[index]
			else
				return v
			end
		end
	end

	return {}
end

function KaifuActivityData:MaxBossPageNum()
	local count = 0
	for k, v in pairs(self:GetOpenGameActCfg().kill_boss_reward) do
		count = count + 1
	end
	return count
end

-- 判断是否已经完成了boss猎手
function KaifuActivityData:GetBossIsComplete(index)
	if not index then return false, 0 end

	local count = 0
	local oga_kill_boss_flag_hight = self.boss_lieshou_info.oga_kill_boss_flag_hight
	local oga_kill_boss_flag_low = self.boss_lieshou_info.oga_kill_boss_flag_low

	if not oga_kill_boss_flag_hight or not oga_kill_boss_flag_low then return false end

	local sif_list = bit:ll2b(oga_kill_boss_flag_hight, oga_kill_boss_flag_low)

	-- index 从 0 开始
	for k, v in pairs(self:GetOpenGameActCfg().kill_boss_reward) do
		if v.seq == index then
			for i, j in ipairs(sif_list) do
				if 1 == j then
					local tem_index = (64 - i) - 4 * index
					if v["boss_seq_"..tem_index] then
						count = count + 1
					end
				end
			end
		end
	end
	if count >= 4 then
		return true, count
	end
	return false, count
end

-- 判断是否已经领取了boss猎手奖励
function KaifuActivityData:GetBossRewardIsGet(index)
	if not index then return false end

	local oga_kill_boss_reward_flag = self.boss_lieshou_info.oga_kill_boss_reward_flag

	if not oga_kill_boss_reward_flag then return false end

	local sif_list = bit:d2b(oga_kill_boss_reward_flag)

	-- index 从 0 开始
	for k, v in pairs(sif_list) do
		if 1 == v and index == (32 - k) then
			return true
		end
	end
	return false
end

function KaifuActivityData:BossIsKill(req_index)
	if not req_index then return false end

	local oga_kill_boss_flag_hight = self.boss_lieshou_info.oga_kill_boss_flag_hight
	local oga_kill_boss_flag_low = self.boss_lieshou_info.oga_kill_boss_flag_low

	if not oga_kill_boss_flag_hight or not oga_kill_boss_flag_low then return false end

	local sif_list = bit:ll2b(oga_kill_boss_flag_hight, oga_kill_boss_flag_low)

	for k, v in pairs(sif_list) do
		if 1 == v and (64 - k) == req_index then
			return true
		end
	end
	return false
end

function KaifuActivityData:IsShowBossRedPoint()
	for i = 0, 3 do
		local is_complete = self:GetBossIsComplete(i)
		local is_get = self:GetBossRewardIsGet(i)
		if is_complete and not is_get then
			return true
		end
	end
	return false
end

function KaifuActivityData:LianChongTeHuiGaoRedPoint()
	local chongzhi_info = self:GetChongZhiGao()
	local cfg = self:ChongZhiTeHuiGao() or {}
	local is_red = false
	if nil == chongzhi_info then
		return false
	end
	local can_fetch_flag_list = bit:d2b(chongzhi_info.can_fetch_reward_flag)
	local has_fetch_flag_list = bit:d2b(chongzhi_info.has_fetch_reward_falg)
	local flag = false
	for k, v in pairs(cfg) do
		if can_fetch_flag_list ~= nil and has_fetch_flag_list ~= nil and (can_fetch_flag_list[32 - v.day_index] == 0 or has_fetch_flag_list[32 - v.day_index] == 0) then
			flag = true
		end
	end
	if not flag then
		return false
	end
	if chongzhi_info.can_fetch_reward_flag ~= chongzhi_info.has_fetch_reward_falg then
		for k, v in pairs(cfg) do
			if self:GetChongZhiGaoDayFlag(v.day_index) then
				return true
			end
		end
	elseif chongzhi_info.can_fetch_reward_flag == chongzhi_info.has_fetch_reward_falg then
		-- 今日充值没达到指定额度提示红点
		if not self.lianchong_2_point then
			return false
		end

		if cfg[1] and chongzhi_info.today_chongzhi < cfg[1].need_chongzhi and self.click_go_sign then
			is_red = true
		else
			is_red = false
		end
	end

	return is_red
end

function KaifuActivityData:LianChongTeHuiChuRedPoint()
	local chongzhi_info = self:GetChongZhiChu()
	local cfg = self:ChongZhiTeHuiChu() or {}
	local is_red = false
	if nil == chongzhi_info then
		return false
	end

	if chongzhi_info.can_fetch_reward_flag ~= chongzhi_info.has_fetch_reward_falg then
		for k, v in pairs(cfg) do
			if v.day_index == chongzhi_info.continue_chongzhi_days then
				is_red = true
			end
		end
	elseif chongzhi_info.can_fetch_reward_flag == chongzhi_info.has_fetch_reward_falg then
		if not self.lianchong_1_point then
			return false
		end

		-- 今日充值没达到指定额度提示红点
		if cfg[1] and chongzhi_info.today_chongzhi < cfg[1].need_chongzhi and self.click_sign then
			is_red = true
		else
			is_red = false
		end
	end
	return is_red
end
function KaifuActivityData:LianChonTeHuiChuRemindSign()
	self.click_sign = false
end

function KaifuActivityData:LianChonTeHuiChuRemindSignGao()
	self.click_go_sign = false
end

function KaifuActivityData:LianChongTeHuiChuHongDian()
	local remind_num = self:LianChongTeHuiChuRedPoint() and 1 or 0
	return remind_num
end

function KaifuActivityData:LianChongTeHuiGaoHongDian()
	local remind_num = self:LianChongTeHuiGaoRedPoint() and 1 or 0
	return remind_num
end

function KaifuActivityData:IsShowGoldenPigRedPoint()

	local godlen_info = self:GetGoldenPigCallInfo()

	if nil ~= godlen_info.summon_credit and godlen_info.summon_credit == 0 and self.long_shen_zhao_huan_sign then
		return true
	end

	if ClickOnceRemindList[RemindName.LongShenZhaoHuan] == 0 then
		return false
	end


	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GOLDEN_PIG) then return false end
	local boss_state_info = KaifuActivityData.Instance:GetGoldenPigCallBossInfo()
	local level = GameVoManager.Instance:GetMainRoleVo().level
	for i,v in ipairs(boss_state_info) do
		--等级超过170级出现红点
		if v == 1 and level >= 170 then
			return true
		end
	end

	
	if nil ~= godlen_info.summon_credit and godlen_info.summon_credit > 0 and level >= 170 then
		return true
	end

	

	return false
end

function KaifuActivityData:LongShenZhaoHuanSign()
	self.long_shen_zhao_huan_sign = false
end


function KaifuActivityData:IsShowJiZiRedPoint()
	-- if ClickOnceRemindList[RemindName.JiZi] == 0 then
	-- 	return false
	-- end
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION) then return false end
	local can_get = nil
	local times_t = KaifuActivityData.Instance:GetCollectExchangeInfo()
	for k,v in pairs(PlayerData.Instance:GetCurrentRandActivityConfig().item_collection) do
		local times = times_t[v.seq + 1] or 0
		if times < v.exchange_times_limit then
			can_get = true
			for i = 1, 4 do
				if v["stuff_id" .. i].item_id > 0 then
					if ItemData.Instance:GetItemNumInBagById(v["stuff_id" .. i].item_id) < v["stuff_id" .. i].num then
						can_get = false
					end
				end
			end
			if can_get then
				return true
			end
		end
	end
	return false
end

function KaifuActivityData:IsShowSingleDayRedPoint()
	if not ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_SINGLE_DAY_CHARGE) then return false end
	local today_recharge = DailyChargeData.Instance:GetChongZhiInfo().today_recharge
	local singleday_chongzhi_reward = KaifuActivityData.Instance:GetKaifuActivityCfgByType(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_SINGLE_DAY_CHARGE)
	local max_seq = #KaifuActivityData.Instance:GetKaifuActivityCfgByType(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_SINGLE_DAY_CHARGE)
	if singleday_chongzhi_reward then
		for i = max_seq, 1, -1 do
			if not KaifuActivityData.Instance:IsGetReward(i, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_SINGLE_DAY_CHARGE) and
				singleday_chongzhi_reward[i] and singleday_chongzhi_reward[i].cond1 <= today_recharge then
				return true
			end
			if singleday_chongzhi_reward[i] and singleday_chongzhi_reward[i].cond1 > today_recharge and self.dan_ri_chong_zhi_sign then
				return true
			end
		end
	end
	
	return false
end

function KaifuActivityData:DanRiLeiChongSign()
	self.dan_ri_chong_zhi_sign = false
end


function KaifuActivityData:IsShowQuanMinZongDongRedPoint()
	local reward_list = KaifuActivityData.Instance:GetKaifuActivityCfgByType(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QUAN_MIN_UPGRADE_GROUPE)
	local max_seq = #KaifuActivityData.Instance:GetKaifuActivityCfgByType(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QUAN_MIN_UPGRADE_GROUPE)

	for i = max_seq, 1, -1 do
		if not KaifuActivityData.Instance:IsGetReward(i, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QUAN_MIN_UPGRADE_GROUPE)
		and KaifuActivityData.Instance:IsComplete(i, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QUAN_MIN_UPGRADE_GROUPE) then
			return true
		end
	end
	return false

end

function KaifuActivityData:IsShowQuanMinJinJieRedPoint()
	local reward_list = KaifuActivityData.Instance:GetKaifuActivityCfgByType(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QUAN_MIN_JIN_JIE)
	local max_seq = #KaifuActivityData.Instance:GetKaifuActivityCfgByType(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QUAN_MIN_JIN_JIE)

	for i = max_seq, 1, -1 do
		local count = KaifuActivityData.Instance:GetQuanMinJinJieInfo().grade - 1 or 0
		if not KaifuActivityData.Instance:IsGetReward(i, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QUAN_MIN_JIN_JIE)
		and count >= reward_list[i].cond2 then
			return true
		end
	end
	return false
end

--红点提示
function KaifuActivityData:GetHappyErnieRemind()
	local happy_ernie_activity_reward_cfg = self:GetHappyErnieRewardConfig()
	if nil == happy_ernie_activity_reward_cfg or nil == self.reward_flag then
		return 0
	end
	--是否有免费次数
	-- local next_free_tao_timestamp = KaifuActivityData.Instance:GetNextFreeTaoTimestamp()
	local next_free_tao_timestamp = self:GetNextFreeTaoTimestamp()
	local server_time = TimeCtrl.Instance:GetServerTime()

	if next_free_tao_timestamp ~= 0 then
		if next_free_tao_timestamp < server_time then
			return 1
		end
	end

	-- 是否有摇奖钥匙
	local key_num, key_cfg = self:GetHappyErnieKeyNum()
	if key_num > 0 then
		return 1
	end

	-- 是否有可领取奖励
	if self.reward_flag == nil then
		return 0
	end
	local get_reward_times = 0
	for k, v in pairs(self.reward_flag) do
		if v == 1 then
			get_reward_times = get_reward_times + 1
		end
	end
	local can_reward_times = 0
	for k, v in pairs(happy_ernie_activity_reward_cfg) do
		if self.chou_times >= v.choujiang_times then
			can_reward_times = v.index + 1
		end
	end
	return can_reward_times > get_reward_times and 1 or 0
end



function KaifuActivityData:GetBossInfoById(boss_id)
	if not boss_id then return end

	for k, v in pairs(self:GetOpenGameActCfg().kill_boss) do
		if v.boss_id == boss_id then
			return v
		end
	end

	return nil
end

function KaifuActivityData:SetZhengBaRedPointState(value)
	self.zhengba_red_point_state = value
end

function KaifuActivityData:SetLianchongRedPointState(value)
	self.lianchong_1_point = value
end

function KaifuActivityData:SetLianchongRedPointState2(value)
	self.lianchong_2_point = value
end
function KaifuActivityData:IsShowZhengbaRedPoint()
	if not ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ZHENG_BA) then
		return false
	end

	for k, v in pairs(self.battle_activity_info) do
		if v.status == ACTIVITY_STATUS.OPEN and self.zhengba_red_point_state then
			return true
		end
	end
	return false
end

--累计充值(2091)配置
function KaifuActivityData:GetLeiJiChongZhiCfg()
	local list = ActivityData.Instance:GetRandActivityConfig(PlayerData.Instance:GetCurrentRandActivityConfig().rand_total_chongzhi, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE)
	return list
end

-- 2为可领取 1为需要充值 0为领取完毕 
function KaifuActivityData:GetLeijiChongZhiFlagCfg()
	local list = self:GetLeiJiChongZhiCfg()
	local total_charge_value = self.leiji_chongzhi_info.total_charge_value or 0
	local temp_list = {}
	for k, v in pairs(list) do
		local temp_data = {}
		if v.need_chognzhi <= total_charge_value and not self:IsGetLeiJiChongZhiReward(v.seq) then
			temp_data.flag = 2
		elseif v.need_chognzhi <= total_charge_value and self:IsGetLeiJiChongZhiReward(v.seq) then
			temp_data.flag = 0
		else
			temp_data.flag = 1
		end
		temp_data.seq = v.seq
		temp_list[v.seq] = temp_data
	end

	return temp_list
end

-- 2为可领取 1为需要充值 0为领取完毕 
function KaifuActivityData:GetLeiJiChongZhiSortFlag()
	local temp_data = self:GetLeijiChongZhiFlagCfg()
	local sort_flag_list = {}
	--先插值可以领取的以及需要充值的
	for k,v in pairs(temp_data) do
		if v.flag == 2 then
			table.insert(sort_flag_list, v)
		end
	end

	for k,v in pairs(temp_data) do
		if v.flag == 1 then
			table.insert(sort_flag_list, v)
		end
	end

	for k,v in pairs(temp_data) do
		if v.flag == 0 then
			table.insert(sort_flag_list, v)
		end
	end
	return sort_flag_list
end

function KaifuActivityData:GetLeijiChongZhiSortCfg()
	local flag_list = self:GetLeiJiChongZhiSortFlag()
	local leichong_cfg = self:GetLeiJiChongZhiCfg()
	local sort_list = {}
	for k,v in pairs(flag_list) do
		if v and v.seq then
			for m,n in pairs(leichong_cfg) do
				if n.seq == v.seq then
					local temp_list = {}
					temp_list.cfg = n
					temp_list.flag = v.flag
					table.insert(sort_list, temp_list)
				end
			end
		end
	end
	return sort_list
end

function KaifuActivityData:RechargeProgressValue()
	local chongzhi_cfg = self:GetLeiJiChongZhiCfg()
	local total_charge_value = self.leiji_chongzhi_info.total_charge_value or 0  -- 当前充值金额

	for i,v in ipairs(chongzhi_cfg) do
		if total_charge_value < chongzhi_cfg[1].need_chognzhi then
			return 0
		elseif total_charge_value >= chongzhi_cfg[#chongzhi_cfg].need_chognzhi then
				return #chongzhi_cfg
		elseif total_charge_value >= chongzhi_cfg[i].need_chognzhi and total_charge_value < chongzhi_cfg[i + 1].need_chognzhi then
			return i
		end
	end
	return 0
end

-- 进度条显示数值转换
function KaifuActivityData:GetLeiJiChongZhiDes(index)
	local chongzhi_cfg = self:GetLeiJiChongZhiCfg()
	for i,v in ipairs(chongzhi_cfg) do
		if v.seq == index then
			return v
		end
	end
end

-- 是否领取累计充值奖励
function KaifuActivityData:IsGetLeiJiChongZhiReward(seq)
	if not seq then return false end

	local reward_has_fetch_flag = self.leiji_chongzhi_info.reward_has_fetch_flag

	if not reward_has_fetch_flag then return false end

	local sif_list = bit:d2b(reward_has_fetch_flag)

	for k, v in pairs(sif_list) do
		if 1 == v and (32 - k) == seq then
			return true
		end
	end

	return false
end

function KaifuActivityData:GetKfLeichongRemind()
	return self:IsShowLeiJiChongZhiRedPoint2() and 1 or 0
end

function KaifuActivityData:IsShowLeiJiChongZhiRedPoint2()
	if not ActivityData.Instance:GetIsOpenLevel(ACTIVITY_TYPE.RAND_TOTAL_CHONGZHI) then
		return false
	end
	if not ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE) then return false end

	for k, v in pairs(self:GetLeijiChongZhiFlagCfg()) do
		if v.flag and v.flag == 2 then
			return true
		end
	end
	return false
end



function KaifuActivityData:IsShowLeiJiChongZhiRedPoint()
	if not ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE) then return false end

	for k, v in pairs(self:GetLeijiChongZhiFlagCfg()) do
		if v.flag and v.flag == 2 then
			return true
		end
		if self.qitian_sign and v.flag and v.flag == 1 then
			return true
		end
		
	end
	return false
end

function KaifuActivityData:LeiJiChongZhiSign()
	self.qitian_sign = false
end

function KaifuActivityData:IsShowChongZhiRankRedPoint()
	if not ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CHONGZHI_RANK) then return false end

	if self.chongzhi_rank_sign  then
		return true
	end

	return false
end

function KaifuActivityData:IsShowXiaoFeiRankRedPoint()
	if not ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_XIAOFEI_RANK) then return false end

	if self.xiaofei_rank_sign  then
		return true
	end

	return false
end

function KaifuActivityData:ChongZhiRankSign()
	self.chongzhi_rank_sign = false
end

function KaifuActivityData:XiaoFeiRankSign()
	self.xiaofei_rank_sign = false
end

function KaifuActivityData:IsShowDanBiChongZhiRedPoint()
	if not ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBI_CHONGZHI) then return false end

	if self.dan_bi_chong_zhi_sign  then
		return true
	end

	return false
end

function KaifuActivityData:DanBiChongZhiSign()
	self.dan_bi_chong_zhi_sign = false
end



-- 是否显示主界面图标
function KaifuActivityData:IsShowKaifuIcon()
	if ActivityData.Instance:GetActivityIsOpen(KaifuActivityType.TYPE) or
		(ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BOSS_LIESHOU) and self:IsShowBossTab())
		or #self:GetTempAddActivityTypeList() > 0 then
		return true
	end

	return false
end

-- 是否显示主界面图标
function KaifuActivityData:IsShowTouZiIcon()
	if #self:GetTouziActivityList() > 0 then
		return true
	end

	return false
end

function KaifuActivityData:GetTouziActivityList()
	local list = {}
	for k,v in pairs(TempAddActivityType) do
		if (v.activity_type == TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_FuBenTouZi and self:IsAllFetchFBTouZi() == false and self:ShowFbTouzi()) or 
			(v.activity_type == TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_BossTouZi and self:IsAllFetchBossTouZi() == false and self:ShowBossTouzi()) or
			(v.activity_type == TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_ShenYuBossTouZi and self:IsAllFetchShenYuBossTouZi() == false and self:ShowShenYuBossTouzi()) then
			table.insert(list, v)
		end
	end
	return list
end

function KaifuActivityData:GetDifferTimeOpenSever()
	local cur_time = TimeCtrl.Instance:GetServerTime()
	local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local differ_day = 4 - server_open_day
	local str = os.date("%X", cur_time)
	local time_tab = Split(str, ":")
	local time = tonumber(time_tab[1]) * 3600 + tonumber(time_tab[2]) * 60 + tonumber(time_tab[3])
	local diff_time = 86400 * differ_day - time
	return diff_time or 0
end

function KaifuActivityData:GetShenYuTouziDifferTimeOpenSever()
	local cur_time = TimeCtrl.Instance:GetServerTime()
	local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local differ_day = 0
	if server_open_day >= 4 then
		differ_day = 7 - server_open_day
	end
	local str = os.date("%X", cur_time)
	local time_tab = Split(str, ":")
	local time = tonumber(time_tab[1]) * 3600 + tonumber(time_tab[2]) * 60 + tonumber(time_tab[3])
	local diff_time = 86400 * differ_day - time
	return diff_time or 0
end

function KaifuActivityData:ShowFbTouzi()
	local differ_time = self:GetDifferTimeOpenSever()
	if differ_time > 0 then
		return true
	else
		if InvestData.Instance:CheckIsActiveFbByID(1) then
			return true
		end
	end
	return false
end

function KaifuActivityData:ShowBossTouzi()
	local differ_time = self:GetDifferTimeOpenSever()
	if differ_time > 0 then
		return true
	else
		if InvestData.Instance:CheckIsActiveBossByID(1) then
			return true
		end
	end
	return false
end

function KaifuActivityData:ShowShenYuBossTouzi()
	local differ_time = self:GetShenYuTouziDifferTimeOpenSever()
	if differ_time > 0 then
		return true
	else
		if InvestData.Instance:CheckIsActiveShenYuBossByID(1) then
			return true
		end
	end
	return false
end

function KaifuActivityData:IsShowBossTab()
	for k, v in pairs(self:GetOpenGameActCfg().kill_boss_reward) do
		if self:GetBossIsComplete(v.seq) and not self:GetBossRewardIsGet(v.seq) then
			return true
		end
		if not self:GetBossIsComplete(v.seq) and not self:GetBossRewardIsGet(v.seq) then
			return true
		end
	end
	return false
end
--------每日好礼------------------------------------
function KaifuActivityData:GetDailyGiftConfig()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local act_cfg = cfg and cfg.everyday_nice_gift[1]			--daily_love2 单笔返利表名
	return act_cfg
end

function KaifuActivityData:GetDailyGitfRewardConfig()
	local reward_cfg = {}
	local act_cfg = self:GetDailyGiftConfig()
	if act_cfg ~= nil and next(act_cfg) ~= nil then
		for k,v in pairs(act_cfg) do
			for i=1,7 do
				if k == "reward_item"..i and v.item_id ~= 0 then
					reward_cfg[i] = v
				end
			end
		end	
	end
	return reward_cfg
end

function KaifuActivityData:DailyGiftRedPoint()
	local flag = 0
	local data_list = self:GetDailyGitfRewardConfig()
	if data_list == nil then
		return flag
	end
	for i=1, #data_list do
		local index = i
		local can_flag = self:GetCanFetchRewardFlag(index) 
		local has_flag = self:GetHaveFetchRewardFlag(index) 
		if can_flag == true and has_flag == false then
			flag = 1
			return flag
		end
	end
	return flag
end

function KaifuActivityData:SetDailyGiftInfo(protocol)
	self.daily_data = {}
	self.daily_data.is_active = protocol.is_active
	self.daily_data.everyday_recharge = protocol.everyday_recharge
	self.daily_data.can_fetch_reward_flag = bit:d2b(protocol.can_fetch_reward_flag)
	self.daily_data.have_fetch_reward_flag = bit:d2b(protocol.have_fetch_reward_flag)
end

function KaifuActivityData:GetActiveFlag()
	if not self.daily_data then return false end
	if self.daily_data.is_active == 0 then 
		return false 
	else
		return  true
	end
end

function KaifuActivityData:GetDailyReChargeAmount()
	if not self.daily_data then return 0 end
	return self.daily_data.everyday_recharge or 0
end

function KaifuActivityData:GetCanFetchRewardFlag(index)
	if not self.daily_data then return false end
	return (1 == self.daily_data.can_fetch_reward_flag[33 - index]) and true or false
end

function KaifuActivityData:GetHaveFetchRewardFlag(index)
	if not self.daily_data then return false end
	return (1 == self.daily_data.have_fetch_reward_flag[33 - index]) and true or false
end

----------------------------------------------------
--金猪召唤相关配置（基础配置）
function KaifuActivityData:GetGoldenPigBasisCfg()
	if not self.golden_pig_summon_basis_cfg then
		self.golden_pig_summon_basis_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().golden_pig_summon_basis
	end

	return self.golden_pig_summon_basis_cfg
end

--（召唤配置）
function KaifuActivityData:GetGoldenPigCallCfg()
	if not self.golden_pig_call_cfg then
		self.golden_pig_call_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().golden_pig_reward
	end

	return self.golden_pig_call_cfg

end

--(召唤成功获取奖励坐标)
function KaifuActivityData:GetGoldenCallPositionCfg(id)
	local cfg = self:GetGoldenPigBasisCfg()
	local name_list = {
		[0] = "junior",
		[1] = "medium",
		[2] = "senior",
	}
	local pos_list = {}
	pos_list.scene_id = cfg[1].scene_id
	pos_list.pos_x = cfg[1][name_list[id] .. "_summon_pos_x"]
	pos_list.pos_y = cfg[1][name_list[id] .. "_summon_pos_y"]

	return pos_list
end

function KaifuActivityData:GetIsGoldenPigMonsterById(monster_id)
	if nil == monster_id then return false end

	if nil == next(self.golden_pig_monster_list) then
		local cfg = self:GetGoldenPigCallCfg()
		for k,v in pairs(cfg) do
			self.golden_pig_monster_list[v.monster_id] = 1
		end
	end

	return self.golden_pig_monster_list[monster_id] == 1

end

function KaifuActivityData:GetCurCallCfg()
	local call_cfg = self:GetGoldenPigCallCfg()
	local item_img_list = {}
	local cur_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	for i,v in ipairs(call_cfg) do
		if cur_server_day <= v.opengame_day then
			if nil ~= item_img_list[1] and v.opengame_day ~= item_img_list[1].opengame_day then
				break
			end
			item_img_list[v.summon_type + 1] = v
		end
	end
	return item_img_list
end

-- 我们结婚吧配置表
function KaifuActivityData:GetMarryMeCfg()
	if not self.marry_me_cfg then
		self.marry_me_cfg = PlayerData.Instance:GetCurrentRandActivityConfig().marry_me
	end
	return self.marry_me_cfg
end

-- 我们结婚吧配置表
function KaifuActivityData:GetZhenBaoGeCfg()
	if not self.zhenbaoge_cfg then
		self.zhenbaoge_cfg = PlayerData.Instance:GetCurrentRandActivityConfig().zhenbaoge
	end
	local config = ActivityData.Instance:GetRandActivityConfig(self.zhenbaoge_cfg, ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT)
	return config
end

-- 至尊豪礼
function KaifuActivityData:GetZhenBaoGe2Cfg()
	if not self.zhenbaoge2_cfg then
		local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().zhenbaoge2
		self.zhenbaoge2_cfg = ActivityData.Instance:GetRandActivityConfig(randact_cfg, ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_BUSINESSMAN)
	end
	return self.zhenbaoge2_cfg
end

function KaifuActivityData:ShowCurIndex()
	local chongzhi_cfg = self:GetLeijiChongZhiFlagCfg()
	if not chongzhi_cfg then return -1 end
	for i = 0, 9 do
		if chongzhi_cfg[i] and chongzhi_cfg[i].flag == 2 then
			return i
		end
	end
	for i = 0, 9 do
		if chongzhi_cfg[i] and chongzhi_cfg[i].flag == 1 then
			return i
		end
	end
	return -1
end

function KaifuActivityData:ShowCurSortIndex()
	local chongzhi_cfg = self:GetLeiJiChongZhiSortFlag()
	if not chongzhi_cfg then return -1 end
	local chongzhi_cfg_count = #chongzhi_cfg

	for i = 1, chongzhi_cfg_count do
		if chongzhi_cfg[i] and chongzhi_cfg[i].flag == 2 then
			return chongzhi_cfg[i].seq + 1
		end
	end

	for i = 1, chongzhi_cfg_count do
		if chongzhi_cfg[i] and chongzhi_cfg[i].flag == 1 then
			return chongzhi_cfg[i].seq + 1
		end
	end

	for i = 1, chongzhi_cfg_count do
		if chongzhi_cfg[i] and chongzhi_cfg[i].flag == 0 then
			return chongzhi_cfg[i].seq + 1
		end
	end

	return -1
end

-- 连充特惠高配置
function KaifuActivityData:ChongZhiTeHuiGao()
	local list_gao = {}
	local temp_table = {}
	local openday = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig() or {}
	local today = self:ChongZhiTeHuiGaoList()
	if nil == cfg then
		return
	end

	if ServerActivityData.Instance then
		for k, v in pairs(cfg.continue_chonghzi_gao) do
			if v.open_server_day == today then
				table.insert(temp_table, cfg.continue_chonghzi_gao[k])

			end
		end
		self.teihuigao = temp_table
	end

	if nil ~= self:GetChongZhiGao() then
		local has_reward_falg = bit:d2b(self:GetChongZhiGao().has_fetch_reward_falg)
		local can_reward = {}
		local has_reward = {}

		for i = #self.teihuigao, 1, -1  do
			if has_reward_falg[32 - self.teihuigao[i].day_index] == 1 then
				table.insert(list_gao, self.teihuigao[i])
			else
				table.insert(list_gao, 1, self.teihuigao[i])
			end
		end
	end
	return list_gao
end

function KaifuActivityData:ChongZhiTeHuiGaoList()
	local openday = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig() or {}
	for k, v in pairs(cfg.continue_chonghzi_gao) do
		if openday <= v.open_server_day then
			return v.open_server_day
		end
	end
end

-- 连充特惠初配置
function KaifuActivityData:ChongZhiTeHuiChu()
	local list_chu = {}
	local temp_table = {}
	local openday = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig() or {}
	local today = self:ChongZhiTeHuiChuList()
	if nil == cfg then
		return
	end

	if ServerActivityData.Instance then
		for k, v in pairs(cfg.continue_chonghzi_chu) do
			if v.open_server_day == today then
				table.insert(temp_table, cfg.continue_chonghzi_chu[k])
			end
		end
		self.teihuichu = temp_table
	end

	if nil ~= self:GetChongZhiChu() and nil ~= self.teihuichu then
		local has_reward_falg = bit:d2b(self:GetChongZhiChu().has_fetch_reward_falg)

		for i = #self.teihuichu, 1, -1  do
			if has_reward_falg[32 - self.teihuichu[i].day_index] == 1 then
				table.insert(list_chu, self.teihuichu[i])
			else
				table.insert(list_chu, 1, self.teihuichu[i])
			end
		end
	end

	return list_chu
end

function KaifuActivityData:ChongZhiTeHuiChuList()
	local openday = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig() or {}
	for k, v in pairs(cfg.continue_chonghzi_chu) do
		if openday <= v.open_server_day then
			return v.open_server_day
		end
	end
end

function KaifuActivityData:SetChongZhiChu(protocol)
	self.info_chu = protocol
end

function KaifuActivityData:SetChongZhiGao(protocol)
	self.info_gao = protocol
end

function KaifuActivityData:GetChongZhiChu()
	return self.info_chu
end

function KaifuActivityData:GetChongZhiGao()
	return self.info_gao
end

function KaifuActivityData:GetChongZhiGaoDayFlag(index)
	local can_reward_falg = bit:d2b(self:GetChongZhiGao().can_fetch_reward_flag)
	local has_reward_falg = bit:d2b(self:GetChongZhiGao().has_fetch_reward_falg)
	if can_reward_falg[32 - index] == 1 then
		return has_reward_falg[32 - index] == 0
	end
	return false
end

function KaifuActivityData:GetActivityOpenDay(openday_type)
	local openday_start = 0
	local openday_end = 0
	local openday_info = ActivityData.Instance:GetActivityStatus()
	if nil ~= openday_info[openday_type] then
		openday_start = openday_info[openday_type].start_time
		openday_end = openday_info[openday_type].end_time
	end
	return openday_start, openday_end

end

-----------------开服投资数据---------------------------

------------ 开服投资数据获取数据-------------------
function KaifuActivityData:GetInvestConfig()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().openserver_invest_basis
end

function KaifuActivityData:GetTargetConfig()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().openserver_return_reward
end

function KaifuActivityData:GetInvestCfgByType(invest_type)
	local  cfg = self:GetInvestConfig()
	for k,v in pairs(cfg) do
		if v.invest_type == invest_type then
			return v
		end
	end
end

function KaifuActivityData:GetInvestTargetInfoByType(invest_type)
	local  cfg = self:GetTargetConfig()
	local target_info_list = {}
	for k,v in pairs(cfg) do
		if v.invest_type == invest_type then
			table.insert(target_info_list,v)
		end
	end
	return target_info_list
end

function KaifuActivityData:GetInvestData()
	return self.invest_data
end

function KaifuActivityData:GetFinishNum(invest_type)
	local num = 0
	local cfg = self:GetTargetConfig()
	for k,v in pairs(cfg) do
		if v.invest_type == invest_type then
			if v.param <= self.invest_data.finish_param[invest_type + 1] then
				num = num + 1
			end
		end
	end
	return num
end

function KaifuActivityData:GetLeastTime(index)
	return self.invest_data.time_limit[index] - TimeCtrl.Instance:GetServerTime()
end

function KaifuActivityData:GetReciveNum()
	local type_recive_num = {boss=0, active=0, competition=0}
	local list = bit:d2b(self.invest_data.reward_flag)
	for i=9,32 do
		if i <= INVEST_TYPE_TYPE_POSION.COMPETITION  then
			if i ~= INVEST_TYPE_TYPE_POSION.COMPETITION and list[i] ~= 0 then
				type_recive_num.competition = type_recive_num.competition + 1
			end
		elseif i <= INVEST_TYPE_TYPE_POSION.ACTIVE  then
			if i ~= INVEST_TYPE_TYPE_POSION.ACTIVE and list[i] ~= 0 then
				type_recive_num.active = type_recive_num.active + 1
			end
		elseif i <= INVEST_TYPE_TYPE_POSION.BOSS then
			if i ~= INVEST_TYPE_TYPE_POSION.BOSS and list[i] ~= 0 then
				type_recive_num.boss = type_recive_num.boss + 1
			end
		end
	end
	return type_recive_num
end

function KaifuActivityData:GetParam(invest_type)
	if invest_type == KAIFU_INVEST_TYPE.ACTIVE then
		return ZhiBaoData.Instance:GetActiveDegreeInfo().total_degree
	end
	return self.invest_data.finish_param[invest_type + 1]
end

function KaifuActivityData:GetKaiFuName()
	for k,v in pairs(self.open_cfg) do
		if v.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_KAIFU_INVEST then
			return v.name
		end
	end
	return ""
end

function  KaifuActivityData:GetSpecialName()
	local special_tab_name = {}
	special_tab_name[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_KAIFU_INVEST] = self:GetKaiFuName()
	return special_tab_name
end

function KaifuActivityData:SetDailyActiveRewardInfo(protocol)
	local table_info = {}

end

function KaifuActivityData:GetDailyActiveRewardInfo()

end

-- 充值排行榜奖励
function KaifuActivityData:GetDayChongZhiRankInfoListByDay(day, opengameday)
	local table_data = {}
	local table_data_2 = {}
	local table_data_3 = {}
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().day_chongzhi_rank
	local data = ActivityData.Instance:GetRandActivityConfig(cfg, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CHONGZHI_RANK)

	for k,v in ipairs(data) do
		if day == v.activity_day then
			table.insert(table_data, v)
			table.insert(table_data_2, v.min_gold)
			table.insert(table_data_3, (v.rank + 1))
		end
	end
	return table_data, table_data_2, table_data_3
end

-- 消费排行榜奖励
function KaifuActivityData:GetDayConsumeRankRewardInfoListByDay(day)
	local data = {}
	local data_2 = {}
	local data_3 = {}
	local data_4 = {}
	local temp = 1
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().day_consume_rank
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_XIAOFEI_RANK)
	for k,v in ipairs(cfg) do
		if temp <= 5 and v.activity_day == day then
			--temp = temp + 1
			table.insert(data, v)
			table.insert(data_2, v.min_gold)
			table.insert(data_3, (v.rank + 1))
			table.insert(data_4, v.fanli_rate)
		end
	end
	return data, data_2, data_3, data_4
end
---------------开服投资数据判断数据------------


-- 开服活动-累计消费奖励
function KaifuActivityData:GetOpenActTotalConsumeReward()
	local info = KaifuActivityData.Instance:GetRATotalConsumeGoldInfo()
	local fetch_reward_t = info.fetch_reward_flag or {}
	
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().total_gold_consume
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CONSUME)
	local list = {}
	for i,v in ipairs(cfg) do
		fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
		local data = TableCopy(v)
		data.fetch_reward_flag = fetch_reward_flag
		table.insert(list, data)
	end
	table.sort(list, SortTools.KeyLowerSorter("fetch_reward_flag", "need_consume_gold"))
	return list
end

--每日累计消费
function KaifuActivityData:GetOpenActDailyTotalConsumeReward()
	local info = KaifuActivityData.Instance:GetDailyTotalConsumeInfo()
	local list = {}
	if nil == info or nil == next(info) then
		return list
	end
	local fetch_reward_t = info.fetch_reward_flag or {}
	local config = PlayerData.Instance:GetCurrentRandActivityConfig().day_gold_consume
	-- local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().day_gold_consume
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CONSUME_GOLD)
	for i, v in ipairs(cfg) do
		fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
		local data = TableCopy(v)
		data.fetch_reward_flag = fetch_reward_flag
		table.insert(list, data)
	end
	table.sort(list, SortTools.KeyLowerSorter("fetch_reward_flag", "need_consume_gold"))
	return list
end


-- 充值返利
function KaifuActivityData:GetKaifuActivityRechargeRebateReward()
	local info = KaifuActivityData.Instance:GetRARechargeRebateInfo()
	local fetch_reward_t = info.fetch_reward_flag or {}

	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().day_chongzhi_fanli
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_DAY_CHONGZHI_FANLI)
	local list = {}
	for i,v in ipairs(cfg) do
		fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
		local data = TableCopy(v)
		data.fetch_reward_flag = fetch_reward_flag
		table.insert(list, data)
	end
	table.sort(list, SortTools.KeyLowerSorter("fetch_reward_flag", "need_gold"))
	return list
end

function KaifuActivityData:ShowInvestRedPoint()
	for k,v in pairs(KAIFU_INVEST_TYPE) do
		if self:ShowInvestTypeRedPoint(v) then
			return true
		end
	end
	return false
end

function KaifuActivityData:GetInvestStateByType(invest_type)
	local state = 1
	if self.invest_data then
		local list = bit:d2b(self.invest_data.reward_flag)

		if invest_type == 0 and list[INVEST_TYPE_TYPE_POSION.BOSS] == 1 then
			state = self:IsFinish("boss",KAIFU_INVEST_TYPE.BOSS)
		elseif invest_type == 1 and list[INVEST_TYPE_TYPE_POSION.ACTIVE] == 1 then
			state = self:IsFinish("active",KAIFU_INVEST_TYPE.ACTIVE)
		elseif invest_type == 2 and list[INVEST_TYPE_TYPE_POSION.COMPETITION] == 1 then
			state =  self:IsFinish("competition",KAIFU_INVEST_TYPE.COMPETITION)
		elseif self:GetLeastTime(invest_type + 1) <= 0 then
			state =  INVEST_STATE.outtime
		else
			state = INVEST_STATE.no_invest
		end
	end
	return state
end

function KaifuActivityData:IsFinish(invest_type,index)
	if self.invest_data == nil then return end
	if self:GetReciveNum()[invest_type] < self:GetFinishNum(index) then
		return INVEST_STATE.finish
	elseif self:GetReciveNum()[invest_type] == 7 then
		return INVEST_STATE.complete
	else
		return INVEST_STATE.no_finish
	end
end

function KaifuActivityData:ShowInvestTypeRedPoint(invest_type)
	local state = self:GetInvestStateByType(invest_type)
	return state == INVEST_STATE.finish
end


---------------开服投资数据处理数据------------
function KaifuActivityData:FlushInvestData(protocol)
	self.invest_data = {}
	self.invest_data.max_type = protocol.max_type
	self.invest_data.reward_flag = protocol.reward_flag
	self.invest_data.time_limit = protocol.time_limit
	self.invest_data.finish_param = protocol.finish_param
	ViewManager.Instance:FlushView(ViewName.KaifuActivityView)
end
--------------开服投资数据部分结束--------------------

--------------------每日排行-----------------------
function KaifuActivityData:SetDayChongzhiRankInfo(protocol)
	self.day_chongzhi = protocol.gold_num
end

function KaifuActivityData:GetDayChongZhiCount()
	return self.day_chongzhi or 0
end

function KaifuActivityData:SetDailyChongZhiRank(rank_list)
	if rank_list then
		self.rank_list = rank_list
	end
end

function KaifuActivityData:GetDailyChongZhiRank()
	return self.rank_list or {}
end

function KaifuActivityData:SetRank(rank)
	self.rank_level = rank
end

function KaifuActivityData:GetRank()
	return self.rank_level or 0
end
------------------------每日消费排行----------------------
function KaifuActivityData:SetDayConsumeRankInfo(protocol)
	self.day_xiaofei = protocol.gold_num
end


function KaifuActivityData:SetRATotalConsumeGoldInfo(protocol)
	self.total_consume_info.consume_gold = protocol.consume_gold
	self.total_consume_info.fetch_reward_flag = bit:d2b(protocol.fetch_reward_flag)
end

function KaifuActivityData:GetRATotalConsumeGoldInfo()
	return self.total_consume_info
end

function KaifuActivityData:SetRARechargeRebateInfo(protocol)
	self.recharge_rebate_info.chongzhi_gold = protocol.chongzhi_gold
	self.recharge_rebate_info.fetch_reward_flag = bit:d2b(protocol.fetch_reward_flag)
end

function KaifuActivityData:GetRARechargeRebateInfo()
	return self.recharge_rebate_info
end

function KaifuActivityData:GetDayConsumeRankInfo()
	return self.day_xiaofei or 0
end

function KaifuActivityData:SetDailyXiaoFeiRank(rank_list)
	if rank_list then
		self.xiaofei_rank_list = rank_list
	end
end

function KaifuActivityData:GetDailyXiaoFeiRank()
	return self.xiaofei_rank_list or {}
end

function KaifuActivityData:SetRankLevel(rank)
	self.xiaofei_rank_level = rank
	-- ViewManager.Instance:FlushView(ViewName.KaifuActivityView)
end

function KaifuActivityData:GetRankLevel()
	return self.xiaofei_rank_level or 0
end

---------------------------变身排行 被动变身榜---------------
function KaifuActivityData:SetSpecialAppearanceInfo(protocol)
	self.special_appearance_role_change_times = protocol.role_change_times
	self.special_appearance_rank_count = protocol.rank_count
	self.special_appearance_rank_list = protocol.rank_list

	if self.special_appearance_rank_count > 10 then
		self.special_appearance_rank_count = 10
	end

	table.sort(self.special_appearance_rank_list, function(a, b)
		return a.change_num > b.change_num
	end)
end

function KaifuActivityData:SetSpecialAppearancePassiveInfo(protocol)
	self.role_change_times = protocol.role_change_times
	self.rank_count = protocol.rank_count
	self.bei_bianshen_rank_list = protocol.rank_list

	if self.rank_count > 10 then
		self.rank_count = 10
	end

	table.sort(self.bei_bianshen_rank_list, function(a, b)
		return a.change_num > b.change_num
	end)
end

function KaifuActivityData:GetSpecialAppearanceRankJoinRewardCfg()
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().other
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_RANK)
	return cfg[1].special_appearance_rank_join_reward
end

function KaifuActivityData:GetSpecialAppearanceRewardCfg()
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().other
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GETREWARD)
	return cfg[1].fanli_rate
end

function KaifuActivityData:GetSpecialAppearancePassiveRankJoinRewardCfg()
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().other
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_PASSIVE_RANK)
	return cfg[1].special_appearance_passive_rank_join_reward
end

function KaifuActivityData:GetSpecialAppearanceRankCfg()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().special_appearance_rank
end

function KaifuActivityData:GetSpecialAppearancePassiveRankCfg()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().special_appearance_passive_rank
end

function KaifuActivityData:GetSpecialAppearanceRoleChangeTimes()
	return self.special_appearance_role_change_times
end

function KaifuActivityData:GetSpecialAppearancePassiveRoleChangeTimes()
	return self.role_change_times
end

function KaifuActivityData:GetSpecialAppearanceRankCount()
	return self.special_appearance_rank_count
end

function KaifuActivityData:GetSpecialAppearancePassiveRankCount()
	return self.rank_count
end

function KaifuActivityData:GetSpecialAppearanceRankList()
	return self.special_appearance_rank_list
end

function KaifuActivityData:GetSpecialAppearancePassiveRankList()
	return self.bei_bianshen_rank_list
end

----------------------活跃奖励--------------------------
function KaifuActivityData:SetDayActiveDegreeInfo(protocol)
	self.active_degree = protocol.active_degree
	self.fetch_reward_flag = protocol.fetch_reward_flag
end

function KaifuActivityData:GetFetchRewardFlag()
	if self.fetch_reward_flag == 3 then
		return 2
	end
	if self.fetch_reward_flag == 7 then
		return 3
	end
	return self.fetch_reward_flag
end

function KaifuActivityData:GetCurrentActive()
	return self.active_degree or 0
end

function KaifuActivityData:GetDayActiveDegreeInfoList(opengameday)
	local table_data = {}
	local table_data_2 = {}
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().day_active_degree
	local data = ActivityData.Instance:GetRandActivityConfig(cfg, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_ACTIVIE_DEGREE)

	for k,v in ipairs(data) do
		if day == v.activity_day then
			table.insert(table_data, v.reward_item)
			table.insert(table_data_2, v.need_active)
		end
	end
	return table_data, table_data_2
end

function KaifuActivityData:IsShowDayActiveRedPoint()
	local fetch_reward_flag =  KaifuActivityData.Instance:GetFetchRewardFlag()
	local opengameday = TimeCtrl.Instance:GetCurOpenServerDay()
	local reward_list, coset_list = self:GetDayActiveDegreeInfoList(opengameday)
	local current_active = self:GetCurrentActive()
	for k,v in pairs(coset_list) do
		if fetch_reward_flag < k then
			if current_active >= v then
				return true
			end
		end
	end
	return false
end

function KaifuActivityData:IsTotalConsumeRedPoint()
	if not ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CONSUME) then
		return false
	end

	local info = KaifuActivityData.Instance:GetRATotalConsumeGoldInfo()
	local fetch_reward_t = info.fetch_reward_flag or {}

	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().total_gold_consume
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CONSUME)
	local flag = false
	for i,v in ipairs(cfg) do
		fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
		if 0 == fetch_reward_flag and info.consume_gold and info.consume_gold >= v.need_consume_gold then
			flag = true
			return flag
		end
		if info.consume_gold and info.consume_gold < v.need_consume_gold and self.total_consume_sign then
			flag = true
			return flag
		end
	end
	return flag
end

function KaifuActivityData:TotalConsumeSign()
	self.total_consume_sign = false
end

function KaifuActivityData:IsDialyTotalConsumeRedPoint()
	if not ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CONSUME_GOLD) then
		return false
	end

	local info = KaifuActivityData.Instance:GetDailyTotalConsumeInfo()
	if info == nil or next(info) == nil then return end
	local fetch_reward_t = info.fetch_reward_flag or {}

	local config = PlayerData.Instance:GetCurrentRandActivityConfig().day_gold_consume
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CONSUME_GOLD)
	local flag = false
	for i, v in ipairs(cfg) do
		fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
		if 0 == fetch_reward_flag and info.consume_gold and info.consume_gold >= v.need_consume_gold then
			flag = true
			return flag
		end
		if info.consume_gold and info.consume_gold < v.need_consume_gold and self.daily_consume_sign then
			flag = true
			return flag
		end
	end
	return flag
end

function KaifuActivityData:DailyConsumeSign()
	self.daily_consume_sign = false
end

function KaifuActivityData:IsRechargeRebateRedPoint()
	if not ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_DAY_CHONGZHI_FANLI) then
		return false
	end

	local info = KaifuActivityData.Instance:GetRARechargeRebateInfo()
	local fetch_reward_t = info.fetch_reward_flag or {}

	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().day_chongzhi_fanli
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_DAY_CHONGZHI_FANLI)
	local flag = false
	for i,v in ipairs(cfg) do
		fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
		if 0 == fetch_reward_flag and info.chongzhi_gold and info.chongzhi_gold >= v.need_gold then
			flag = true
			return flag
		end
		if info.chongzhi_gold and info.chongzhi_gold < v.need_gold and self.chong_zhi_fan_li_sign then
			flag = true
			return flag
		end
	end
	return flag
end

function KaifuActivityData:RechargeRebateSign()
	self.chong_zhi_fan_li_sign = false
end

function KaifuActivityData:IsShowLeiJiRechargeIcon()
	if not DailyChargeData.Instance:GetIsThreeRecharge() then
		return false
	end

	local list = self:GetLeiJiChongZhiCfg()
	local total_charge_value = self.leiji_chongzhi_info.total_charge_value or 0
	for i = 1, 10 do
		if not (list[i].need_chognzhi <= total_charge_value and self:IsGetLeiJiChongZhiReward(list[i].seq)) then
			return true
		end
	end
	return false
end

function KaifuActivityData:FlushTotalConsumeHallRedPoindRemind()
	local remind_num = self:IsTotalConsumeRedPoint() and 1 or 0
	ActivityData.Instance:SetActivityRedPointState(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CONSUME, remind_num > 0)
end

function KaifuActivityData:FlushDialyTotalConsumeRedPoindRemind()
	local remind_num = self:IsDialyTotalConsumeRedPoint() and 1 or 0
	-- ActivityData.Instance:SetActivityRedPointState(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CONSUME_GOLD, remind_num > 0)

end

function KaifuActivityData:SetChargeRewardInfo(protocol)
	self.reward_active_flag = bit:d2b(protocol.can_fetch_reward_flag)
	self.reward_fetch_flag = bit:d2b(protocol.fetch_reward_flag)
	self.history_charge_during_act = protocol.charge_value
end

function KaifuActivityData:GetLeiJiChargeRewardCfg()
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().charge_repayment
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHARGE_REPALMENT)
	local list = {}
	for k,v in pairs(cfg) do
		local data = {}
		data = TableCopy(v)
		data.reward_fetch = self:GetLeiJiChargeRewardIsFetch(v.seq)
		table.insert(list, data)
	end
	table.sort(list, SortTools.KeyLowerSorters("reward_fetch", "charge_value"))
	return list
end

function KaifuActivityData:GetLeiJiChargeValue()
	return self.history_charge_during_act or 0
end

function KaifuActivityData:GetLeiJiChargeRewardIsActive(seq)
	return self.reward_active_flag[32 - seq] or 0
end

function KaifuActivityData:GetLeiJiChargeRewardIsFetch(seq)
	return self.reward_fetch_flag[32 - seq] or 0
end

function KaifuActivityData:GetLeiJiChargeRewardRedPoint()
	local config = self:GetLeiJiChargeRewardCfg()
	for k,v in pairs(config) do
		if self:GetLeiJiChargeRewardIsActive(v.seq) == 1 and self:GetLeiJiChargeRewardIsFetch(v.seq) == 0 then
			return true
		end
		if self.lei_chong_sign and self:GetLeiJiChargeRewardIsActive(v.seq) == 1 then
			return true
		end
	end
	return false
end

function KaifuActivityData:IsShowLeiChongSign()
	self.lei_chong_sign = false
end

function KaifuActivityData:FlushLeiJiChargeRewardRedPoint()
	local remind_num = self:GetLeiJiChargeRewardRedPoint() and 1 or 0
	ActivityData.Instance:SetActivityRedPointState(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHARGE_REPALMENT, remind_num > 0)
end

--------------------------------单笔充值---------------------------------
function KaifuActivityData:GetDanBiChongZhiRankInfoListByDay()
	local table_data = {}
	local table_data_2 = {}
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().single_charge
	local data = ActivityData.Instance:GetRandActivityConfig(cfg, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBI_CHONGZHI)
	for k,v in pairs(data) do
		table.insert(table_data, v.reward_item)
		table.insert(table_data_2, v.charge_value)
	end
	return table_data, table_data_2
end

------------------------------累计充值--------------------------------------------

function KaifuActivityData:SetRANewTotalChargeInfo(protocol)
	self.total_charge_info.total_charge_value = protocol.total_charge_value or 0
	self.total_charge_info.reward_has_fetch_flag = bit:d2b(protocol.reward_has_fetch_flag)
end

function KaifuActivityData:GetOpenActTotalChargeRewardCfg()
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().new_rand_total_chongzhi
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CHARGE)

	local fetch_reward_t = self.total_charge_info.reward_has_fetch_flag or {}
	local list = {}
	for i,v in ipairs(cfg) do
		fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
		local data = TableCopy(v)
		data.fetch_reward_flag = fetch_reward_flag
		table.insert(list, data)
	end
	table.sort(list, SortTools.KeyLowerSorter("fetch_reward_flag", "need_chognzhi"))
	return list
end

function KaifuActivityData:GetTotalChargeInfo()
	return self.total_charge_info
end


function KaifuActivityData:FlushTotalChargeHallRedPoindRemind()
	local remind_num = self:IsTotalChargeRedPoint() and 1 or 0
	ActivityData.Instance:SetActivityRedPointState(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CHARGE, remind_num > 0)
end

function KaifuActivityData:IsTotalChargeRedPoint()
	if not ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CHARGE) then
		return false
	end

	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().new_rand_total_chongzhi
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CHARGE)
	local flag = false

	local fetch_reward_t = self.total_charge_info.reward_has_fetch_flag or {}
	for i,v in ipairs(cfg) do
		fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
		if 0 == fetch_reward_flag and self.total_charge_info.total_charge_value and self.total_charge_info.total_charge_value >= v.need_chognzhi then
			flag = true
			return flag
		end
	end
	return flag
end

function KaifuActivityData:SetFullServerSnapInfo(protocol)
	self.user_buy_numlist = protocol.user_buy_numlist or {}
	self.server_buy_numlist = protocol.server_buy_numlist or {}
end

function KaifuActivityData:GetSnapUserBuyNumlist()
	return self.user_buy_numlist or {}
end

function KaifuActivityData:GetSnapServerBuyNumlist()
	return self.server_buy_numlist or {}
end

function KaifuActivityData:GetSnapServerItemlist()
	if self.server_buy_numlist == nil or self.user_buy_numlist == nil then return end
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().server_panic_buy or {}
	local list = ActivityData.Instance:GetRandActivityConfig(cfg, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FULL_SERVER_SNAP)
	local temp_list = {}
	for i = 1, #list do
		local data = TableCopy(list[i])
		data.is_no_item = 0
		data.server_limit_buy_count = (list[i].server_limit_buy_count - self.server_buy_numlist[i]) or 0
		data.personal_limit_buy_count = (list[i].personal_limit_buy_count - self.user_buy_numlist[i]) or 0
		if (data.server_limit_buy_count <= 0 or data.personal_limit_buy_count <= 0) then
			data.is_no_item = 1
		end
		table.insert(temp_list, data)
	end
	table.sort(temp_list, SortTools.KeyLowerSorters("is_no_item", "seq") )
	return temp_list
end

function KaifuActivityData:GetSnapServerItemlistLimit()
	local temp_list = self:GetSnapServerItemlist()
	local temp_list_two = {}
	local history_money = DailyChargeData.Instance:GetLeiJiChongZhiValue()	-- 玩家历史充值金额，总金额减去当天充值的
	for k, v in pairs(temp_list) do
		if v.limit_charge_max == -1 and history_money >= v.limit_charge_min then
			table.insert(temp_list_two, v)
		elseif history_money >= v.limit_charge_min and history_money < v.limit_charge_max then
			table.insert(temp_list_two, v)
		end
	end
	return temp_list_two
end

function KaifuActivityData:SetDailyLoveFlag(flag)
	self.daily_show_icon_flag = flag
end

function KaifuActivityData:GetDailyLoveFlag()
	return self.daily_show_icon_flag
end

function KaifuActivityData:SetDailyTotalConsumeInfo(protocol)
	self.daily_total_consume_info = {}
	self.daily_total_consume_info.consume_gold = protocol.consume_gold
	self.daily_total_consume_info.fetch_reward_flag = bit:d2b(protocol.fetch_reward_flag)
end

function KaifuActivityData:GetDailyTotalConsumeInfo()
	return self.daily_total_consume_info
end

function KaifuActivityData:SetRewardFlag(protocol)
	self.reward_consume_gold = protocol.consume_gold
end

function KaifuActivityData:GetRewardConsumeGold()
	return self.reward_consume_gold or 0
end

-----------------------升星助力----------------------
function KaifuActivityData:SetShengxingzhuliInfo(protocol)
	self.rsing_star_info.is_get_reward_today = protocol.is_get_reward_today
	self.rsing_star_info.chognzhi_today = protocol.chognzhi_today
	self.rsing_star_info.func_level = protocol.func_level
	self.rsing_star_info.func_type = protocol.func_type
	self.rsing_star_info.is_max_level = protocol.is_max_level
	self.rsing_star_info.stall = protocol.stall
end

function KaifuActivityData:GetShengxingzhuliInfo()
	return self.rsing_star_info
end

function KaifuActivityData:GetRisingStarCfg()
	if not self.rising_star_cfg then
		self.rising_star_cfg = ConfigManager.Instance:GetAutoConfig("shengxingzhuli_config_auto").other[1]
	end
	return self.rising_star_cfg
end

-- 根据系统类型获取相应的系统配置
function KaifuActivityData:GetSystemConfigByType(system_type, star_level)
	local res_id, grade, level = 0
	local is_max = false
	grade = math.floor(star_level / 10) + 1
	level = star_level % 10
	if SYSTEM_TYPE.MOUNT == system_type then 					--坐骑
		local image_cfg = MountData.Instance:GetMountImageCfg()
		local mount_grade_cfg = MountData.Instance:GetMountGradeCfg(grade)
		res_id = image_cfg[mount_grade_cfg.image_id].res_id
		if grade >= MountData.Instance:GetMaxGrade() then
			is_max = true
		end
		grade = mount_grade_cfg.gradename
	elseif SYSTEM_TYPE.WING == system_type then 				--羽翼
		local image_cfg = WingData.Instance:GetWingImageCfg()
		local wing_grade_cfg = WingData.Instance:GetWingGradeCfg(grade)
		res_id = image_cfg[wing_grade_cfg.image_id].res_id
		if grade >= WingData.Instance:GetMaxGrade() then
			is_max = true
		end
		grade = wing_grade_cfg.gradename
	elseif SYSTEM_TYPE.FIGHT_MOUNT == system_type then 			--战斗坐骑
		local mount_grade_cfg = FightMountData.Instance:GetMountGradeCfg(grade)
		local image_cfg = FightMountData.Instance:GetMountImageCfg()
		res_id = image_cfg[mount_grade_cfg.image_id].res_id
		if grade >= FightMountData.Instance:GetMaxGrade() then
			is_max = true
		end
		grade = mount_grade_cfg.gradename
	elseif SYSTEM_TYPE.HALO == system_type then 				--光环
		local halo_grade_cfg = HaloData.Instance:GetHaloGradeCfg(grade)
		local image_cfg = HaloData.Instance:GetHaloImageCfg()
		res_id = image_cfg[halo_grade_cfg.image_id].res_id
		if grade >= HaloData.Instance:GetMaxGrade() then
			is_max = true
		end
		grade = halo_grade_cfg.gradename
	elseif SYSTEM_TYPE.FOOT == system_type then 				--足迹
		local foot_grade_cfg = FootData.Instance:GetFootGradeCfg(grade)
		local image_cfg = FootData.Instance:GetFootImageCfg()
		res_id = image_cfg[foot_grade_cfg.image_id].res_id
		if grade >= FootData.Instance:GetMaxGrade() then
			is_max = true
		end
		grade = foot_grade_cfg.gradename
	elseif SYSTEM_TYPE.SHEN_GONG == system_type then 			--神弓
		local shengong_grade_cfg = ShengongData.Instance:GetShengongGradeCfg(grade)
		local image_list = ShengongData.Instance:GetShengongImageCfg()
		res_id = image_list[shengong_grade_cfg.image_id].res_id
		if grade >= ShengongData.Instance:GetMaxGrade() then
			is_max = true
		end
		grade = shengong_grade_cfg.gradename	
	elseif SYSTEM_TYPE.SHEN_YI == system_type then 				--神翼
		local image_list = ShenyiData.Instance:GetShenyiImageCfg()
		local shenyi_grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(grade)
		res_id = image_list[shenyi_grade_cfg.image_id].res_id
		if grade >= ShenyiData.Instance:GetMaxGrade() then
			is_max = true
		end
		grade = shenyi_grade_cfg.gradename	
	end
	return res_id, grade, level, is_max
end

-- 根据系统类型和形象ID获取相应的形象列表
function KaifuActivityData:GetImageListByImageId(system_type, image_id)
	local image_list = {}
	if SYSTEM_TYPE.MOUNT == system_type then
		image_list = MountData.Instance:GetImageListInfo(image_id)
		return image_list
	elseif SYSTEM_TYPE.WING == system_type then
		image_list = WingData.Instance:GetImageListInfo(image_id)
		return image_list
	elseif SYSTEM_TYPE.FIGHT_MOUNT == system_type then
		image_list = FightMountData.Instance:GetImageListInfo(image_id)
		return image_list
	elseif SYSTEM_TYPE.HALO == system_type then
		image_list = HaloData.Instance:GetImageListInfo(image_id)
		return image_list
	elseif SYSTEM_TYPE.FOOT == system_type then
		image_list = FootData.Instance:GetImageListInfo(image_id)
		return image_list
	elseif SYSTEM_TYPE.SHEN_GONG == system_type then
		image_list = ShengongData.Instance:GetImageListInfo(image_id)
		return image_list
	elseif SYSTEM_TYPE.SHEN_YI == system_type then
		image_list = ShenyiData.Instance:GetImageListInfo(image_id)
		return image_list
	else
		return image_list
	end
end

--升星助力红点
function KaifuActivityData:CheckRisindRed()
	if self.rsing_star_info.is_get_reward_today == 1 or self.rsing_star_info.func_level <= 0 then return 0 end

	local cfg = self:GetRisingStarCfg()
	if self.rsing_star_info.chognzhi_today >= cfg.need_chongzhi then
		return 1
	else
		return 0
	end
end

function KaifuActivityData:DailyLoveRedPoint()
	-- if ClickOnceRemindList[RemindName.DailyLove] == 0 then
	-- 	return false
	-- end

	local today_recharge = DailyChargeData.Instance:GetChongZhiInfo().today_recharge
	if today_recharge == nil then
		return true
	end
	if today_recharge <= 0 then
		return true
	end
	return false
end

function KaifuActivityData:GetNeedChongzhiByStage(stage)
	local chongzhi = 0
	local cfg = self:GetRisingStarCfg()

	for i = 1, stage < 3 and stage or 3  do
		chongzhi = chongzhi + cfg["need_chongzhi_" .. i - 1]
	end

	if stage > 3 then
		chongzhi = chongzhi +  (stage - 3) * cfg.add_valus
	end

	return chongzhi
end

--升星助力
function KaifuActivityData:GetIsShowUpStarBtn(index)
	local system_type = self.rsing_star_info.func_type
	if ((index == TabIndex.mount_jinjie and SHENGXINGZHULI_SYSTEM_TYPE.SHENGXINGZHULI_SYSTEM_TYPE_MOUNT == system_type)				--坐骑进阶
		or (index == TabIndex.wing_jinjie and SHENGXINGZHULI_SYSTEM_TYPE.SHENGXINGZHULI_SYSTEM_TYPE_WING == system_type)			--羽翼进阶
		or (index == TabIndex.halo_jinjie and SHENGXINGZHULI_SYSTEM_TYPE.SHENGXINGZHULI_SYSTEM_TYPE_HALO == system_type)		--足迹进阶
		or (index == TabIndex.foot_jinjie and SHENGXINGZHULI_SYSTEM_TYPE.SHENGXINGZHULI_SYSTEM_TYPE_FOOT_PRINT == system_type)			--光环进阶
		or (index == TabIndex.fight_mount and SHENGXINGZHULI_SYSTEM_TYPE.SHENGXINGZHULI_SYSTEM_TYPE_FIGHT_MOUNT == system_type)		--战斗坐骑
		or (index == TabIndex.goddess_shengong and SHENGXINGZHULI_SYSTEM_TYPE.SHENGXINGZHULI_SYSTEM_TYPE_SHENGONG == system_type)	--神弓进阶
		or (index == TabIndex.goddess_shenyi and SHENGXINGZHULI_SYSTEM_TYPE.SHENGXINGZHULI_SYSTEM_TYPE_SHENYI == system_type)) then	--神翼进阶
		return index
	else
		return false
	end
end

function KaifuActivityData:GetTodayOpenUpStarSystemType()
	local cfg = ConfigManager.Instance:GetAutoConfig("shengxingzhuli_config_auto")
	weekday_to_system_cfg = cfg.weekday_to_system[1]

	local system_type_list = {
		[0] = weekday_to_system_cfg.sunday_sys, 
		[1] = weekday_to_system_cfg.monday_sys, 
		[2] = weekday_to_system_cfg.tuesday_sys, 
		[3] = weekday_to_system_cfg.wednesday_sys, 
		[4] = weekday_to_system_cfg.thursday_sys, 
		[5] = weekday_to_system_cfg.friday_sys, 
		[6] = weekday_to_system_cfg.saturday_sys } 

	local server_time = TimeCtrl.Instance:GetServerTime()
	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()

	local system_type = 0
	if open_server_day < 7 then
		system_type = system_type_list[open_server_day]
	else
		local date_day = tonumber(os.date("%w", server_time))
		system_type = system_type_list[date_day]
	end

	return system_type
end

function KaifuActivityData:SetSelect(index)
	self.selectindex = index
end

function KaifuActivityData:GetSelectIndex()
	return self.selectindex
end

function KaifuActivityData:SetOpenGameActivityInfo(protocol)
	self.open_act_info = protocol.open_act_vo
end

function KaifuActivityData:GetOpenGameActivityInfo()
	return self.open_act_info
end

function KaifuActivityData:IsShowKFGuildFightRedPoint()
if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GUILD_FIGHT) then
		return false
	end
	if not self.open_act_info then return false end

	if self.open_act_info.oga_guild_battle_reward_type > 0 and self.open_act_info.oga_guild_battle_reward_flag == 0 then
		return true
	else
		return false
	end
end

function KaifuActivityData:GetActivityTypeToIndex(activity_type)
	if activity_type > 100000 then
		activity_type = activity_type - 100000
	end
	local index = ACTIVITY_TYPE_TO_INDEX[activity_type] or 1

	return index
end

function KaifuActivityData:GetActivityTypeByIndex(open_index)
	for k, v in pairs(ACTIVITY_TYPE_TO_INDEX) do
		if open_index == v then
			return k
		end
	end
end

function KaifuActivityData:SetDefaultOpenActType(act_type)
	self.default_open_act_type = act_type
end

function KaifuActivityData:ClearDefaultOpenActType()
	self.default_open_act_type = -1
end

function KaifuActivityData:GetDefaultOpenActType()
	return self.default_open_act_type
end

function KaifuActivityData:SetPerfectLoverInfo(protocol)
	self.perfect_lover_info.perfect_lover_type_record_flag = protocol.perfect_lover_type_record_flag or 0
	self.perfect_lover_info.ra_perfect_lover_count = protocol.ra_perfect_lover_count or 0
	self.perfect_lover_info.ra_perfect_lover_name_list = protocol.ra_perfect_lover_name_list or {}
end

function KaifuActivityData:GetPerfectLoverInfo()
	return self.perfect_lover_info
end

function KaifuActivityData:SetQuanMinJinJieInfo(protocol)
	self.quanmin_jinjie_info.reward_flag = protocol.reward_flag or 0
	self.quanmin_jinjie_info.grade = protocol.grade or 0
end

function KaifuActivityData:GetQuanMinJinJieInfo()
	return self.quanmin_jinjie_info
end

function KaifuActivityData:SetQuanMinGroupInfo(protocol)
	self.quanmin_group_info.ra_upgrade_group_reward_flag = protocol.ra_upgrade_group_reward_flag or 0
	for i = 1 , GameEnum.MAX_UPGRADE_RECORD_COUNT do
		self.quanmin_group_info.count_list[i] = protocol.count_list[i]
	end
end

function KaifuActivityData:GetQuanMinGroupInfo()
	return self.quanmin_group_info
end
-----------------------------------------------------

--进阶返还
function KaifuActivityData:SetUpGradeReturnInfo(protocol)
	self.upgrade_return_info.act_type = protocol.act_type
	self.upgrade_return_info.fetch_reward_flag = bit:d2b(protocol.fetch_reward_flag)
end

--进阶返还2
function KaifuActivityData:SetUpGradeReturnInfo2(protocol)
	self.upgrade_return_info2.act_type = protocol.act_type
	self.upgrade_return_info2.fetch_reward_flag = bit:d2b(protocol.fetch_reward_flag)
end

function KaifuActivityData:GetUpGradeReturnInfo()
	return self.upgrade_return_info
end

function KaifuActivityData:GetUpGradeReturnActType()
	return self.upgrade_return_info.act_type or 0
end

function KaifuActivityData:GetUpGradeReturnInfo2()
	return self.upgrade_return_info2
end

function KaifuActivityData:GetUpGradeReturnList()
	local info = self:GetUpGradeReturnInfo()
	local fetch_reward_t = info.fetch_reward_flag or {}
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().jinjie_return
	local cfg = ListToMapList(config, "act_type")
	local list = {}
	if cfg[self.upgrade_return_info.act_type] ~= nil then
		for i,v in ipairs(cfg[self.upgrade_return_info.act_type]) do
			fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
			local data = TableCopy(v)
			data.fetch_reward_flag = fetch_reward_flag
			table.insert(list, data)
		end
		table.sort(list, SortTools.KeyLowerSorter("fetch_reward_flag", "need_grade"))
	end
	return list
end

function KaifuActivityData:GetUpGradeReturnList2()
	local info = self:GetUpGradeReturnInfo2()
	local fetch_reward_t = info.fetch_reward_flag or {}
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().jinjie_return2
	local cfg = ListToMapList(config, "act_type")
	local list = {}
	if cfg[self.upgrade_return_info2.act_type] ~= nil then
		for i,v in ipairs(cfg[self.upgrade_return_info2.act_type]) do
			fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
			local data = TableCopy(v)
			data.fetch_reward_flag = fetch_reward_flag
			table.insert(list, data)
		end
		table.sort(list, SortTools.KeyLowerSorter("fetch_reward_flag", "need_grade"))
	end
	return list
end

-------------------------------------聚宝盆start--------------------------------------------
---------------------协议
function KaifuActivityData:SetJuBaoPenInfo(protocol)
	self.jubaopen_info = {}
	self.jubaopen_info.left_roll_times = protocol.left_roll_times
	self.jubaopen_info.join_record_list = protocol.join_record_list
	self.jubaopen_info.record_num = protocol.record_num
	self.jubaopen_info.had_join_times = protocol.had_join_times
end

function KaifuActivityData:SetJuBaoPenResult(protocol)
	self.jubaopen_seq = protocol.seq
end

function KaifuActivityData:GetJuBaoPenInfo()
	return self.jubaopen_info
end

function KaifuActivityData:GetJuBaoPenResult()
	return self.jubaopen_seq
end

-------------------配表
function KaifuActivityData:GetJuBaoPenCfg()
	if nil == self.jubaopen_cfg then
		local config = ServerActivityData.Instance:GetCurrentRandActivityConfig()
		self.jubaopen_cfg = config.collect_treasure
	end
	return self.jubaopen_cfg
end

--index(1-8)
function KaifuActivityData:GetJuBaoPenCfgByIndex(index)
	index = index or 1
	local cfg = self:GetJuBaoPenCfg()
	return cfg[index]
end


function KaifuActivityData:JuBaoPenRemindSign()
	self.click_jbp = false
end

-------------------红点
function KaifuActivityData:IsShowJubaoPenRedPoint()
	local recharge = DailyChargeData.Instance:GetChongZhiInfo().today_recharge or 0
	if self.jubaopen_info == nil then
		return false
	end
	if self.jubaopen_info.left_roll_times > 0 then
		return self.jubaopen_info.left_roll_times > 0
	elseif self.click_jbp  and recharge == 0 then
		return self.click_jbp
	end
	return self.jubaopen_info.left_roll_times > 0
end
---------------------------------------聚宝盆end---------------------------------------------

function KaifuActivityData:IsShowUpGradeRedPoint()
	local upgrade_return_info = self:GetUpGradeReturnInfo()
	if nil == upgrade_return_info or nil == next(upgrade_return_info) then
		return false
	end
	local act_type = upgrade_return_info.act_type or 0
	local info = {}
	if act_type == TYPE_UPGRADE_RETURN.MOUNT_UPGRADE_RETURN then
		info = MountData.Instance:GetMountInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.WING_UPGRADE_RETURN then
		info = WingData.Instance:GetWingInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.FABAO_UPGRADE_RETURN then
		info = FaBaoData.Instance:GetFaBaoInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.WUQI_UPGRADE_RETURN then
		info = FashionData.Instance:GetWuQiInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.FOOT_UPGRADE_RETURN then
		info = FootData.Instance:GetFootInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.HALO_UPGRADE_RETURN then
		info = HaloData.Instance:GetHaloInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.FASHION_UPGRADE_RETURN then
		info = FashionData.Instance:GetFashionInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.FIGHTMOUNT_UPGRADE_RETURN then
		info = FightMountData.Instance:GetFightMountInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.TOUSHI_UPGRADE_RETURN then
		info = TouShiData.Instance:GetTouShiInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.MASK_UPGRADE_RETURN then
		info = MaskData.Instance:GetMaskInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.WAIST_UPGRADE_RETURN then
		info = WaistData.Instance:GetYaoShiInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.QILINBI_UPGRADE_RETURN then
		info = QilinBiData.Instance:GetQilinBiInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.LINGCHONG_UPGRADE_RETURN then
		info = LingChongData.Instance:GetLingChongInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.LINGGONG_UPGRADE_RETURN then
		info = LingGongData.Instance:GetLingGongInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.LINGQI_UPGRADE_RETURN then
		info = LingQiData.Instance:GetLingQiInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.SHENGONG_UPGRADE_RETURN then
		info = ShengongData.Instance:GetShengongInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.SHENYI_UPGRADE_RETURN then
		info = ShenyiData.Instance:GetShenyiInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.FLYPET_UPGRADE_RETURN then
		info = FlyPetData.Instance:GetFlyPetInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.WEIYAN_UPGRADE_RETURN then
		info = WeiYanData.Instance:GetWeiYanInfo()
	end

	if nil == info or nil == next(info) or info.grade == nil then
		return false
	end
	local current_grade = info.grade - 1
	local list = self:GetUpGradeReturnList()
	if list ~= nil and next(list) ~= nil then
		for k,v in pairs(list) do
			if v.fetch_reward_flag == 0 and current_grade >= v.need_grade then
				return true
			end
		end
	end
	return false
end

function KaifuActivityData:IsShowUpGrade2RedPoint()
	local upgrade_return_info = self:GetUpGradeReturnInfo2()
	if nil == upgrade_return_info or nil == next(upgrade_return_info) then
		return false
	end
	local act_type = upgrade_return_info.act_type or 0
	local info = {}
	if act_type == TYPE_UPGRADE_RETURN.MOUNT_UPGRADE_RETURN then
		info = MountData.Instance:GetMountInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.WING_UPGRADE_RETURN then
		info = WingData.Instance:GetWingInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.FABAO_UPGRADE_RETURN then
		info = FaBaoData.Instance:GetFaBaoInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.WUQI_UPGRADE_RETURN then
		info = FashionData.Instance:GetWuQiInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.FOOT_UPGRADE_RETURN then
		info = FootData.Instance:GetFootInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.HALO_UPGRADE_RETURN then
		info = HaloData.Instance:GetHaloInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.FASHION_UPGRADE_RETURN then
		info = FashionData.Instance:GetFashionInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.FIGHTMOUNT_UPGRADE_RETURN then
		info = FightMountData.Instance:GetFightMountInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.TOUSHI_UPGRADE_RETURN then
		info = TouShiData.Instance:GetTouShiInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.MASK_UPGRADE_RETURN then
		info = MaskData.Instance:GetMaskInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.WAIST_UPGRADE_RETURN then
		info = WaistData.Instance:GetYaoShiInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.QILINBI_UPGRADE_RETURN then
		info = QilinBiData.Instance:GetQilinBiInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.LINGCHONG_UPGRADE_RETURN then
		info = LingChongData.Instance:GetLingChongInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.LINGGONG_UPGRADE_RETURN then
		info = LingGongData.Instance:GetLingGongInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.LINGQI_UPGRADE_RETURN then
		info = LingQiData.Instance:GetLingQiInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.SHENGONG_UPGRADE_RETURN then
		info = ShengongData.Instance:GetShengongInfo()		
	elseif act_type == TYPE_UPGRADE_RETURN.SHENYI_UPGRADE_RETURN then
		info = ShenyiData.Instance:GetShenyiInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.FLYPET_UPGRADE_RETURN then
		info = FlyPetData.Instance:GetFlyPetInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.WEIYAN_UPGRADE_RETURN then
		info = WeiYanData.Instance:GetWeiYanInfo()		
	end

	if nil == info or nil == next(info) or info.grade == nil then
		return false
	end
	local current_grade = info.grade - 1
	local list = self:GetUpGradeReturnList2()
	if list ~= nil and next(list) ~= nil then
		for k,v in pairs(list) do
			if v.fetch_reward_flag == 0 and current_grade >= v.need_grade then
				return true
			end
		end
	end
	return false
end

-- 欢乐累充(8473)配置
function KaifuActivityData:GetHuanLeLeiChongCfg()
	local list = PlayerData.Instance:GetCurrentRandActivityConfig().happy_cumul_chongzhi
	-- local list = ActivityData.Instance:GetRandActivityConfig(PlayerData.Instance:GetCurrentRandActivityConfig().happy_cumul_chongzhi, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPY_RECHARGE)
	local act_type = self:GetHuanLeLeiChongActType()
	local temp_list = {}
	for k, v in pairs(list) do
		if v ~= nil and v.act_type == act_type then
			table.insert(temp_list, v)
		end
	end
	return temp_list
end

-- 2为可领取 1为需要充值 0为领取完毕 
function KaifuActivityData:GetHuanLeLeiChongFlagCfg()
	local list = self:GetHuanLeLeiChongCfg()
	local total_charge_value = self.happy_recharge_info.chongzhi_num or 0
	local temp_list = {}
	for k, v in pairs(list) do
		local temp_data = {}
		if v.need_chongzhi <= total_charge_value and not self:IsGetHuanLeLeiChongReward(v.seq) then
			temp_data.flag = 2
		elseif v.need_chongzhi <= total_charge_value and self:IsGetHuanLeLeiChongReward(v.seq) then
			temp_data.flag = 0
		else
			temp_data.flag = 1
		end
		temp_data.seq = v.seq
		temp_list[v.seq] = temp_data
	end

	return temp_list
end

-- 2为可领取 1为需要充值 0为领取完毕 
function KaifuActivityData:GetHuanLeLeiChongSortFlag()
	local temp_data = self:GetHuanLeLeiChongFlagCfg()
	local sort_flag_list = {}
	--先插值可以领取的以及需要充值的
	for k,v in pairs(temp_data) do
		if v.flag == 2 then
			table.insert(sort_flag_list, v)
		end
	end

	for k,v in pairs(temp_data) do
		if v.flag == 1 then
			table.insert(sort_flag_list, v)
		end
	end

	for k,v in pairs(temp_data) do
		if v.flag == 0 then
			table.insert(sort_flag_list, v)
		end
	end
	return sort_flag_list
end

function KaifuActivityData:GetHuanLeLeiChongSortCfg()
	local flag_list = self:GetHuanLeLeiChongSortFlag()
	local leichong_cfg = self:GetHuanLeLeiChongCfg()
	local sort_list = {}
	for k,v in pairs(flag_list) do
		if v and v.seq then
			for m,n in pairs(leichong_cfg) do
				if n.seq == v.seq then
					local temp_list = {}
					temp_list.cfg = n
					temp_list.flag = v.flag
					table.insert(sort_list, temp_list)
				end
			end
		end
	end
	return sort_list
end

-- function KaifuActivityData:RechargeProgressValue()
-- 	local chongzhi_cfg = self:GetHuanLeLeiChongCfg()
-- 	local total_charge_value = self.leiji_chongzhi_info.total_charge_value or 0  -- 当前充值金额

-- 	for i,v in ipairs(chongzhi_cfg) do
-- 		if total_charge_value < chongzhi_cfg[1].need_chognzhi then
-- 			return 0
-- 		elseif total_charge_value >= chongzhi_cfg[#chongzhi_cfg].need_chognzhi then
-- 				return #chongzhi_cfg
-- 		elseif total_charge_value >= chongzhi_cfg[i].need_chognzhi and total_charge_value < chongzhi_cfg[i + 1].need_chognzhi then
-- 			return i
-- 		end
-- 	end
-- 	return 0
-- end

-- -- 进度条显示数值转换
-- function KaifuActivityData:GetLeiJiChongZhiDes(index)
-- 	local chongzhi_cfg = self:GetHuanLeLeiChongCfg()
-- 	for i,v in ipairs(chongzhi_cfg) do
-- 		if v.seq == index then
-- 			return v
-- 		end
-- 	end
-- end

function KaifuActivityData:SetHuanLeLeiChongInfo(protocol)
	self.happy_recharge_info = protocol
end

function KaifuActivityData:GetHuanLeLeiChongInfo()
	return self.happy_recharge_info
end

function KaifuActivityData:GetHuanLeLeiChongActType()
	return self.happy_recharge_info.act_type
end

-- 是否领取累计充值奖励
function KaifuActivityData:IsGetHuanLeLeiChongReward(seq)
	if not seq then return false end

	local reward_has_fetch_flag = self.happy_recharge_info.fetch_reward_flag

	if not reward_has_fetch_flag then return false end

	local sif_list = bit:d2b(reward_has_fetch_flag)

	for k, v in pairs(sif_list) do
		if 1 == v and (32 - k) == seq then
			return true
		end
	end
	return false
end

function KaifuActivityData:GetHuanLeLeichongRemind()

	return self:IsHuanLeLeichongRemind() and 1 or 0
end

function KaifuActivityData:IsHuanLeLeichongRemind()
	if not self.happy_recharge_info then return false end

	for k, v in pairs(self:GetHuanLeLeiChongFlagCfg()) do
		if v.flag and v.flag == 2 then
			return true
		end
		if v.flag and v.flag == 1 and self.huan_le_lei_chong_sign then
			return true
		end
	end
	return false
end

function KaifuActivityData:HuanLeLeichongSign()
	self.huan_le_lei_chong_sign = false
end


function KaifuActivityData:IsShowPersonBuyRedPoint()
	return true
end
------------------------------疯狂摇奖----------------------------------------------------------------

-- 其他配置
function KaifuActivityData:GetOtherCfgByOpenDay()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfigOtherCfg()
	return cfg
end

--根据开服时间获取欢乐摇奖配置  
function KaifuActivityData:GetOpenTakeTimeCfg()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local happy_ernie_cfg = {}
	if nil == cfg then
		return nil
	end

	happy_ernie_cfg = ActivityData.Instance:GetRandActivityConfig(cfg.huanleyaojiang2, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPY_ERNIE) or {}
	return happy_ernie_cfg
end

--获取欢乐摇奖的累计奖励配置表
function KaifuActivityData:GetHappyErnieRewardConfig()
	local reward_cfg = {}
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	if nil == cfg then
		return nil
	end

	reward_cfg = ActivityData.Instance:GetRandActivityConfig(cfg.huanleyaojiang2_reward, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPY_ERNIE)
	return reward_cfg
end

function KaifuActivityData:GetHappyErnieCfgByList()
	local cfg = self:GetOpenTakeTimeCfg()
	local list = {}
	if nil == next(cfg) then
		return nil
	end

	for k,v in pairs(cfg) do
		if v.is_show == 1 then
			table.insert(list, v)
		end
	end

	if nil == next(list) then
		return nil
	end

	return list
end

--获取抽取消耗金额
function KaifuActivityData:GetHappyErnieDrawCost()
	local happy_ernie_other_configs = self:GetOtherCfgByOpenDay()
	if nil == happy_ernie_other_configs then
		return nil
	end
	local draw_gold_list = {}
	draw_gold_list.once_gold = happy_ernie_other_configs.huanleyaojiang2_once_gold or 0
	draw_gold_list.tenth_gold = happy_ernie_other_configs.huanleyaojiang2_tentimes_gold or 0
	draw_gold_list.thirtieth_gold = happy_ernie_other_configs.huanleyaojiang2_thirtytimes_gold or 0

	return draw_gold_list
end

function KaifuActivityData:GetHappyErnieKeyNum()
	local happy_ernie_other_configs = self:GetOtherCfgByOpenDay()
	if nil == happy_ernie_other_configs then
		return 0
	end

	local key_id = happy_ernie_other_configs.huanleyaojaing2_thirtytimes_item_id or 0
	local key_num = ItemData.Instance:GetItemNumInBagById(key_id) or 0
	local key_cfg = ItemData.Instance:GetItemConfig(key_id)
	return key_num, key_cfg
end

--获取欢乐摇奖的累计奖励配置表
function KaifuActivityData:GetHappyErnieRewardItemConfig()
	local happy_ernie_activity_reward_cfg = self:GetHappyErnieRewardConfig()
	if nil == happy_ernie_activity_reward_cfg or nil == self.reward_flag then
		return {}
	end

	local has_got_data_list = {}
	local not_got_data_list = {}
	for i,v in ipairs(happy_ernie_activity_reward_cfg) do
		if self.reward_flag[33 - i] == 1 then
			table.insert(has_got_data_list, v)
		else
			table.insert(not_got_data_list, v)
		end
	end

	for i,v in ipairs(has_got_data_list) do
		table.insert(not_got_data_list, v)
	end

	return not_got_data_list
end

--获取协议下的数据
function KaifuActivityData:SetRAHappyErnieInfo(protocol)
	RemindManager.Instance:Fire(RemindName.Festival_Act)
	self.ra_huanleyaojiang_next_free_tao_timestamp = protocol.ra_huanleyaojiang_next_free_tao_timestamp
	self.chou_times = protocol.chou_times
	self.reward_flag = bit:d2b(protocol.reward_flag)
end

--获取协议下的数据
function KaifuActivityData:SetRAHappyErnieTaoResultInfo(protocol)
	self.count = protocol.count
	self.huanleyaojiang_tao_seq = protocol.huanleyaojiang_tao_seq
end

--获取服务器上的抽奖次数
function KaifuActivityData:GetChouTimes()
	return self.chou_times
end

--获取服务器上的下次免费的时间戳
function KaifuActivityData:GetNextFreeTaoTimestamp()
	return self.ra_huanleyaojiang_next_free_tao_timestamp or 0
end

--是否已领取
function KaifuActivityData:GetIsFetchFlag(index)
	return (1 == self.reward_flag[32 - index]) and true or false
end

--获取可获取奖励的抽奖次数
function KaifuActivityData:GetCanFetchFlagByIndex(index)
	local happy_ernie_activity_reward_cfg = self:GetHappyErnieRewardConfig()
	if nil == happy_ernie_activity_reward_cfg then
		return 0
	end

	for k,v in pairs(happy_ernie_activity_reward_cfg) do
		if index == v.index then
			return v.choujiang_times or 0
		end
	end

	return 0
end

--设置奖励展示框模式
function KaifuActivityData:SetChestShopMode(mode)
	self.chest_shop_mode = mode
end

--获取奖励展示框模式
function KaifuActivityData:GetChestShopMode()
	return self.chest_shop_mode
end

--获取奖励展示框的格子数量
function KaifuActivityData:GetChestCount()
	return self.count
end

--获取奖励展示框的信息
function KaifuActivityData:GetChestShopItemInfo()
	local happy_ernie_reward_item = self:GetOpenTakeTimeCfg()
	if nil == next(happy_ernie_reward_item) then
		return {}
	end

	local data = {}
	for k,v in pairs(self.huanleyaojiang_tao_seq) do
		if happy_ernie_reward_item[v] then
			table.insert(data, happy_ernie_reward_item[v].reward_item)
		end
	end

	if nil == next(data) then
		return nil
	end

	return data
end

-------------------------------------------------------------------------------------------------------
------------------------------ 狂欢的单笔充值------------------------------------------------------
function KaifuActivityData:InitSingleChargeOne()
	self.cfg_list[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_0].cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().offline_single_charge_0
	local cfg = self.cfg_list[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_0].cfg
	local data = self.single_info[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_0]
	data.reward_type = (cfg[1].reward_type == 0)
	data.cfg = ListToMap(cfg, "opengame_day", "seq")
end

function KaifuActivityData:InitSingleChargeTwo()
	self.cfg_list[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_1].cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().offline_single_charge_1
	local cfg = self.cfg_list[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_1].cfg
	local data = self.single_info[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_1]
	data.reward_type = (cfg[1].reward_type == 0)
	data.cfg = ListToMap(cfg, "opengame_day", "seq")
end

function KaifuActivityData:InitSingleChargeThree()
	self.cfg_list[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_2].cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().offline_single_charge_2
	local cfg = self.cfg_list[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_2].cfg
	local data = self.single_info[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_2]
	data.reward_type = (cfg[1].reward_type == 0)
	data.cfg = ListToMap(cfg, "opengame_day", "seq")
end

function KaifuActivityData:GetOpenTime(act_id)
	local start_time = ActivityData.Instance:GetActivityResidueTime(act_id)
	local now_time = TimeCtrl.Instance:GetServerTime()
	local dif = now_time - start_time
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	return open_day - (math.ceil(dif / ONE_DAY) - 1)
end

function KaifuActivityData:GetSingleCfgInfo(act_id)
	local data = self.single_info[act_id]
	if nil == data then
		return {}
	end

	local day = self:GetOpenTime(act_id)
	local cur_day = self:GetCurOpenDay(act_id, day)

	for k,v in pairs(data.cfg) do
		if cur_day == k then
			return v
		end
	end

	return {}
end

function KaifuActivityData:GetSingleRewardTime(act_id, index)
	local data = self.single_info[act_id]
	if nil == data then
		return 0
	end

	local times = data.reward_times
	if nil == times then
		return 0
	end

	local cfg = self:GetSingleCfgInfo(act_id)

	if nil == cfg or nil == cfg[index] then
		return 0
	end

	local cfg_time = cfg[index].reward_limit

	return cfg_time - times[index + 1]
end

function KaifuActivityData:SetSingleInfo(protocol)
	self.single_info[protocol.act_id].charge_max_value = protocol.charge_max_value
	self.single_info[protocol.act_id].reward_times = protocol.reward_times
end

function KaifuActivityData:GetSingleInfoById(act_id)
	return self.single_info[act_id]
end

function KaifuActivityData:GetRewardType(act_id)
	local cfg = self.single_info[act_id]
	if nil == cfg then
		return false
	end
	
	return cfg.reward_type
end

function KaifuActivityData:SetIsOpen(is_open)
	self.is_open = is_open
end

function KaifuActivityData:GetCurOpenDay(act_id, day)
	local data = self.cfg_list[act_id]

	if nil == data then
		return 999
	end

	for k,v in pairs(data.cfg) do
		if day <= v.opengame_day then
			return v.opengame_day
		end
	end

	return 999
end

------------------------end----------------------------------end
-- 每日好礼
function KaifuActivityData:GetActivityActTimeLeftById(act_id)
	if nil == self.active_open_list_id[act_id] then
		return 0
	end

	local time = self.active_open_list_id[act_id].next_time
	local time_left = time - TimeCtrl.Instance:GetServerTime()
	if time_left < 0 then
		return 0
	end

	return time_left
end

-- 单身伴侣 集月饼活动
function KaifuActivityData:SetCollectMoonExchangeInfo(collection_exchange_times)
	self.collect_moon_exchange_info = collection_exchange_times or {}
end

function KaifuActivityData:GetCollectMoonExchangeInfo()
	return self.collect_moon_exchange_info
end


--匠心月饼红点
function KaifuActivityData:IsShowMoonCakeRedPoint()
	local can_get = 0
	if not ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAKE_MOONCAKE) then
		return 0 
	end

	local rand_act_cfg = PlayerData.Instance:GetCurrentRandActivityConfig()
	if nil == rand_act_cfg or nil == rand_act_cfg.item_collection_2 then
		return 0
	end
	for k, v in pairs(rand_act_cfg.item_collection_2) do
		if v.seq then
			can_get = self:SingleMakeMoonCakeRedPoint(v.seq)
			if can_get then
				can_get = 1
				break
			end
		end
	end
	return can_get
end

--判断单个月饼的红点出现
function KaifuActivityData:SingleMakeMoonCakeRedPoint(seq)
	if not ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAKE_MOONCAKE) then 
		return false 
	end
	local rand_act_cfg = PlayerData.Instance:GetCurrentRandActivityConfig()
	local times_t = KaifuActivityData.Instance:GetCollectMoonExchangeInfo()
	if nil == times_t or nil == rand_act_cfg or nil == rand_act_cfg.item_collection_2 then
		return false
	end
	local can_get = false
	for k, v in pairs(rand_act_cfg.item_collection_2) do	
		if seq == v.seq then
			local times = times_t[v.seq + 1] or 0
			if times < v.exchange_times_limit then
				can_get = true
				for i = 1, 4 do
					local num = ItemData.Instance:GetItemNumInBagById(v["stuff_id" .. i].item_id)
					if v["stuff_id" .. i].item_id > 0 and num < v["stuff_id" .. i].num then
						can_get = false
					end
				end
				if can_get then
					break
				end
			end
		end
	end
	return can_get
end

function KaifuActivityData:IsMakeMoonCakeRemind()
	local rand_act_cfg = PlayerData.Instance:GetCurrentRandActivityConfig()
	for i = 0, #rand_act_cfg.item_collection_2 - 1 do
		if self:SingleMakeMoonCakeRedPoint(i) then
			return 1
		end
	end
	return 0
end

function KaifuActivityData:GetDayTime()
	local active_time_table = os.date('*t',TimeCtrl.Instance:GetServerTime())
	local active_cur_time = active_time_table.hour * 3600 + active_time_table.min * 60 + active_time_table.sec
	local time_limit = 24 * 3600 - active_cur_time
	return time_limit
end------------------------end----------------------------------

----------------- 每日单笔 -------------------------

function KaifuActivityData:SetDailyDanBiInfo(protocol)
	self.daily_danbi_info = {}
	self.daily_danbi_info.can_fetch_reward_flag = bit:d2b(protocol.can_fetch_reward_flag)
	self.daily_danbi_info.fetch_reward_flag = bit:d2b(protocol.fetch_reward_flag)
	RemindManager.Instance:Fire(RemindName.MeiRiDanBi)
end

function KaifuActivityData:GetDailyDanBiInfo()
	return self.daily_danbi_info
end

function KaifuActivityData:FlushDailyDanBiHallRedPoindRemind()
	local remind_num = self:IsDailyDanBiRedPoint() and 1 or 0
	ActivityData.Instance:SetActivityRedPointState(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DANBI_CHONGZHI, remind_num > 0)
end

function KaifuActivityData:GetOpenActDailyDanBiReward()
	local info = KaifuActivityData.Instance:GetDailyDanBiInfo()
	local fetch_reward_t = info.fetch_reward_flag or {}
	local can_fetch_reward_t =  info.can_fetch_reward_flag or {}

	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().danbichongzhi
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DANBI_CHONGZHI)
	local day_index = ActivityData.Instance:GetActDayPassFromStart(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DANBI_CHONGZHI)

	local real_cfg = {}
	for k,v in pairs(cfg) do
		if day_index == v.activity_day then
			table.insert(real_cfg, v)
		end
	end

	local list = {}
	for i,v in ipairs(real_cfg) do
		fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
		local data = TableCopy(v)
		data.fetch_reward_flag = fetch_reward_flag
		data.can_fetch_reward_flag = can_fetch_reward_t[32 - v.seq]

		table.insert(list, data)
	end
	local list2 = {}
	for k, v in pairs(list) do
		if v.fetch_reward_flag == 0 and v.can_fetch_reward_flag == 1 then
			table.insert(list2, v)
		end
	end
	for k, v in pairs(list) do
		if v.fetch_reward_flag == 0 and v.can_fetch_reward_flag == 0 then
			table.insert(list2, v)
		end
	end
	for k, v in pairs(list) do
		if v.fetch_reward_flag == 1 then
			table.insert(list2, v)
		end
	end
	return list2
end

function KaifuActivityData:GetDailyDanBiRedPoint()
	if self:IsDailyDanBiRedPoint() then
		return 1
	end
	return 0
end

function KaifuActivityData:IsDailyDanBiRedPoint()
	if not ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DANBI_CHONGZHI) then
		return false
	end

	local info = KaifuActivityData.Instance:GetDailyDanBiInfo()
	if nil == info then
		return
	end

	local fetch_reward_t = info.fetch_reward_flag or {}
	local can_fetch_reward_t =  info.can_fetch_reward_flag or {}

	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().danbichongzhi
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DANBI_CHONGZHI)
	local day_index = ActivityData.Instance:GetActDayPassFromStart(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DANBI_CHONGZHI)
	local real_cfg = {}
	for k,v in pairs(cfg) do
		if day_index == v.activity_day then
			table.insert(real_cfg, v)
		end
	end
	local flag = false
	for i,v in ipairs(real_cfg) do
		fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
		if 0 == fetch_reward_flag and 1 == can_fetch_reward_t[32 - v.seq] then
			flag = true
			return flag
		end
	end
	return flag
end
----------------------------------END----------------------------------------
---------------------------成长基金------------------------------------------

function KaifuActivityData:GetTouZicfg()
	return ConfigManager.Instance:GetAutoConfig("touzijihua_auto").foundation
end

function KaifuActivityData:GetNewTouZicfg()
	local cfg = self:GetTouZicfg()
	local touzi_list = {}
	local touzi_list2 = {}
	local dec_num = 0

	for k, v in pairs(cfg) do
		if self:IsGuoQiOrLingQu(v) then
			table.insert(touzi_list2, v)
		else
			local role_level = PlayerData.Instance:GetRoleVo().level
			if v.active_level_min and role_level < v.active_level_min then
				dec_num = dec_num + 1
			else
				table.insert(touzi_list, v)
			end
		end
	end

	for k, v in ipairs(touzi_list2) do
		table.insert(touzi_list, v)
	end

	return touzi_list, dec_num / 3
end


function KaifuActivityData:GetTouZiState(index)
	local role_level = PlayerData.Instance:GetRoleVo().level
	local level_cfg = self:GetTouZicfg()
	local svr_info = InvestData.Instance:GetTouZiPlanInfo()

	if nil == index or nil == svr_info or nil == svr_info[index] or nil == level_cfg then
		return 0
	end
	if svr_info[index] == 4 then
		return 5
	end

 	-- return 0 代表可购买， 1 代表已购买可领取， 2 代表已购买不能领取， 3 代表未购买过期, 4 代表等级不够不能购买, 5 代表已经领完
 	for k, v in pairs(level_cfg) do
 		if v.seq == index - 1 then
 			if svr_info[index] == 0 then  -- 如果我没买
 				if role_level < v.active_level_min then
					return 4
				elseif role_level > v.active_level_max then
					return 3
				else
					return 0
				end
 			elseif svr_info[index] == 1 or svr_info[index] == 2 or svr_info[index] == 3 then -- 如果我买了，处于领取 1，2，3阶段
 				if v.sub_index == svr_info[index] - 1 then
 					if role_level >= v.reward_level then
						return 1
					else
						return 2
					end
 				end
 			end
 		end
 	end


	return 3
end

-- 是否过期或者是已经领取完
function KaifuActivityData:IsGuoQiOrLingQu(cfg)
	local svr_info = InvestData.Instance:GetTouZiPlanInfo()
	local svr_infonum = InvestData.Instance:GetTouZiPlanInfoNum() or 0
	local role_level = PlayerData.Instance:GetRoleVo().level
	local flag = false
	for i = 1, svr_infonum do
		if cfg.seq == i - 1 then
			if svr_info[i] >= 4 or (svr_info[i] == 0 and role_level > cfg.active_level_max) then
				flag = true
			end
			break
		end
	end

	return flag
end
function KaifuActivityData:ChengZhangJiJingRemind()
	self.click_czjj = false
end

-- 副本投资红点
function KaifuActivityData:IsShowFuBenTouZiRedPoint()
	if self:IsAllFetchFBTouZi() == true then
		return false
	end

	if not self:ShowFbTouzi() then
		return false
	end

	if not InvestData.Instance:GetActiveFbPlan() then
		local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
		local real_role_id = CrossServerData.Instance:GetRoleId()
		local remind_day = PlayerPrefsUtil.GetInt("FuBenTouZiView" .. real_role_id) or cur_day
		if cur_day ~= -1 and cur_day ~= remind_day then
			return true
		end
	end

	local data_list = self:GetFBTouZiDataList()
	for i, v in ipairs(data_list) do
		if not InvestData.Instance:CheckIsFetchedFbByID(v.index + 1) and InvestData.Instance:CheckIsActiveFbByID(v.index + 1) then
			return true
		end
	end

	return false
end

-- boss投资红点
function KaifuActivityData:IsShowBossTouZiRedPoint()
	if self:IsAllFetchBossTouZi() == true then
		return false
	end

	if not self:ShowBossTouzi() then
		return false
	end

	if not InvestData.Instance:GetActiveBossPlan() then
		local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
		local real_role_id = CrossServerData.Instance:GetRoleId()
		local remind_day = PlayerPrefsUtil.GetInt("BossTouZiView" .. real_role_id) or cur_day
		if cur_day ~= -1 and cur_day ~= remind_day then
			return true
		end
	end

	local data_list = self:GetBossTouZiDataList()
	for i, v in ipairs(data_list) do
		if not InvestData.Instance:CheckIsFetchedBossByID(v.index + 1) and InvestData.Instance:CheckIsActiveBossByID(v.index + 1) then
			return true
		end
	end

	return false
end

-- 神域boss投资红点
function KaifuActivityData:IsShowShenYuBossTouZiRedPoint()
	if self:IsAllFetchShenYuBossTouZi() == true then
		return false
	end

	if not self:ShowShenYuBossTouzi() then
		return false
	end

	if not InvestData.Instance:GetShenYuActiveBossPlan() then
		local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
		local real_role_id = CrossServerData.Instance:GetRoleId()
		local remind_day = UnityEngine.PlayerPrefs.GetInt("ShenYuBossTouZiView" .. real_role_id) or cur_day
		if cur_day ~= -1 and cur_day ~= remind_day then
			return true
		end
	end

	local data_list = self:GetShenYuBossTouZiDataList()
	for i, v in ipairs(data_list) do
		if not InvestData.Instance:CheckIsFetchedShenYuBossByID(v.index + 1) and InvestData.Instance:CheckIsFetchedShenYuBossByID(v.index + 1) then
			return true
		end
	end

	return false
end

-- 成长基金红点
function KaifuActivityData:IsTouZiPlanRedPoint()
	local svr_info = InvestData.Instance:GetTouZiPlanInfo()
	local cfg_num = InvestData.Instance:GetTouZiPlanInfoNum() or 0
	local level_cfg = self:GetTouZicfg()
	local role_level = PlayerData.Instance:GetRoleVo().level
	-- if self.click_czjj and not self:CanShowTouZiPlan() then
	-- 	return  self.click_czjj
	-- end
	if nil == svr_info then
		return false
	end

	if self:CanShowTouZiPlan() then
		return false
	end

	-- 如果等级在规定等级段，并且没有看过会给红点，在看过界面或者升级的时候去Fire一次
	if svr_info and cfg_num and level_cfg and role_level then
		for i = 1, cfg_num do
			for k, v in pairs(level_cfg) do
				if v.seq == i - 1 and v.sub_index == 0 then
					-- 在规定等级段
					if role_level >= v.active_level_min and role_level <= v.active_level_max then
						-- 这个等级段有没有点进界面看过
						local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
						local remind = PlayerPrefsUtil.GetInt(main_role_id .. "chengzhangjijin_remind_" .. i)
						if remind and remind ~= 1 then
							return true
						end
					end
				end
			end		
		end
	end

	for i = 1, cfg_num do
		if svr_info[i] == 1 then
			for k, v in pairs(level_cfg) do
				if v.seq == i - 1 and v.sub_index == 0 then
					if role_level >= v.reward_level then
						return true
					end
				end
			end

		elseif svr_info[i] == 2 then
			for k, v in pairs(level_cfg) do
				if v.seq == i - 1 and v.sub_index == 1 then
					if role_level >= v.reward_level then
						return true
					end
				end
			end

		elseif svr_info[i] == 3 then
			for k, v in pairs(level_cfg) do
				if v.seq == i - 1 and v.sub_index == 2 then
					if role_level >= v.reward_level then
						return true
					end
				end
			end
		end
	end
	return false
end

function KaifuActivityData:CanShowTouZiPlan()
	local cfg = InvestData.Instance:GetTouZiPlanInfo()
	local cfg_num = InvestData.Instance:GetTouZiPlanInfoNum() or 0
	local role_level = PlayerData.Instance:GetRoleVo().level
	if role_level < self.touzi_min_level then
		self.touzi_min_level = role_level
	end

	local level_cfg = self:GetTouZicfg()
	local state = false
	if nil == cfg then
		return false
	end

	for i = 1, cfg_num do
		if cfg[i] < 4 and cfg[i] > 0 then
			self.touzi_close_state = true
			return false
		end
	end

	if self.touzi_close_state then
		return false
	end

	for k, v in pairs(level_cfg) do
		if v.seq == cfg_num - 1 then
			if self.touzi_min_level > v.active_level_max then
				state = true
			end
		end
	end

	return state
end

function KaifuActivityData:GetTouZiPlanCfg()
	if self.plan_cfg == nil then
		self.plan_cfg = ConfigManager.Instance:GetAutoConfig("touzijihua_auto").plan
	end
	return self.plan_cfg
end

function KaifuActivityData:TouZiButtonInfo()
	local role_level = PlayerData.Instance:GetRoleVo().level
	local cfg_num = InvestData.Instance:GetTouZiPlanInfoNum() or 0
	local cur_plan = InvestData.Instance:GetNormalActivePlan()
	local all_reward = InvestData.Instance:GetAlsoHasReward(cur_plan)
	local max_level = InvestData.Instance:GetMaxLevel()
	local level_cfg = self:GetTouZiPlanCfg()

	for k, v in pairs(level_cfg) do
		if (role_level > max_level) and all_reward then
			return true
		end
	end

	return false
end

function KaifuActivityData:JuBaoPanButtonInfo()
	if self.jubaopen_info == nil or next(self.jubaopen_info) == nil then return false end

	if self.jubaopen_info.had_join_times == 1 then
		return true 
	end
	return false
end

-------------------------------------连续充值start--------------------------------------------
function KaifuActivityData:ZhongQiuLianXuChongZhiCfg()
	local temp_table = {}
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local today = self:ZhongQiuLianXuChongZhiDay()
	if cfg == nil then
		return nil
	end

	if ServerActivityData.Instance then
		for k, v in pairs(cfg.versions_continuous_charge) do
			if v.open_server_day == today then
				table.insert(temp_table, v)
			end
		end
	end

	return temp_table
end

function KaifuActivityData:ZhongQiuLianXuChongZhiDay()
	local openday = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	if cfg == nil then
		return 0
	end

	for k, v in pairs(cfg.versions_continuous_charge) do
		if v.open_server_day and openday <= v.open_server_day then
			return v.open_server_day
		end
	end

	return 0
end

function KaifuActivityData:SetChongZhiZhongQiu(protocol)
	self.info_zhongqiu = protocol

	if nil ~= protocol.has_fetch_reward_flag then
		self.has_fetch_reward_flag = bit:d2b(protocol.has_fetch_reward_flag)
	end

	if nil ~= protocol.can_fetch_reward_flag then
		self.can_fetch_reward_flag = bit:d2b(protocol.can_fetch_reward_flag)
	end
end

function KaifuActivityData:GetChongZhiZhongQiu()
	return self.info_zhongqiu
end

function KaifuActivityData:GetHasFetchRewardFlagByIndex(index)
	return self.has_fetch_reward_flag and self.has_fetch_reward_flag[32 - index] or 0
end

function KaifuActivityData:GetCanFetchRewardFlagByIndex(index)
	return self.can_fetch_reward_flag and self.can_fetch_reward_flag[32 - index] or 0
end

function KaifuActivityData:IsShowRedPoint()
	local reward_list = self:ZhongQiuLianXuChongZhiCfg()
	for i = 1, #reward_list do

		if self:GetCanFetchRewardFlagByIndex(i) == 1 then
			if self:GetHasFetchRewardFlagByIndex(i) == 0 then
				return 1
			end
		end
	end
	return 0
end
-------------------------------------连续充值end----------------------------------------------
function KaifuActivityData:ShouChongTuanGouRemind()
	self.click_sctg = false
end


---------------------------副本投资------------------------------------------
function KaifuActivityData:GetFBTouZiCfg()
	return ConfigManager.Instance:GetAutoConfig("touzijihua_auto").fb_plan
end

function KaifuActivityData:GetFBTouZiPrice()
	return ConfigManager.Instance:GetAutoConfig("touzijihua_auto").other[1].fb_plan_price or 200
end

function KaifuActivityData:GetFBTouZiDataList()
	local cfg = TableCopy(self:GetFBTouZiCfg())
	local data_list = {}
	for i, v in ipairs(cfg) do
		if v.index ~= 0 then
			local fetch_reward_flag = InvestData.Instance:CheckIsFetchedFbByID(v.index + 1) and 1 or 0
			v.fetch_reward_flag = fetch_reward_flag
			table.insert(data_list, v)
		end
	end
	table.sort(data_list, SortTools.KeyLowerSorter("fetch_reward_flag", "index"))
	return data_list
end

function KaifuActivityData:GetFBTouZiAfterGold()
	local hai_ke_fan_huan_txt = 0
	local yi_fan_huan_txt = 0
	local li_ji_ling_qu_txt = 0

	local cfg = TableCopy(self:GetFBTouZiCfg())
	local data_list = {}
	for i, v in ipairs(cfg) do
		local fetch_reward_flag = InvestData.Instance:CheckIsFetchedFbByID(v.index + 1)
		if fetch_reward_flag then
			yi_fan_huan_txt = yi_fan_huan_txt + v.reward_gold_bind
		else
			hai_ke_fan_huan_txt = hai_ke_fan_huan_txt + v.reward_gold_bind
		end

		local now_pass_level = InvestData.Instance:GetFuBenPassLevel()
		if now_pass_level >= v.pass_level then
			li_ji_ling_qu_txt = li_ji_ling_qu_txt + v.reward_gold_bind
		end
	end

	return hai_ke_fan_huan_txt, yi_fan_huan_txt, li_ji_ling_qu_txt
end

function KaifuActivityData:IsAllFetchFBTouZi()
	local data_list = self:GetFBTouZiDataList()
	for i, v in ipairs(data_list) do
		if not InvestData.Instance:CheckIsFetchedFbByID(v.index + 1) then
			return false
		end
	end
	return true
end

---------------------------Boss投资------------------------------------------
function KaifuActivityData:GetBossTouZiCfg()
	return ConfigManager.Instance:GetAutoConfig("touzijihua_auto").boss_plan
end

function KaifuActivityData:GetBossTouZiPrice()
	return ConfigManager.Instance:GetAutoConfig("touzijihua_auto").other[1].boss_plan_price or 500
end

function KaifuActivityData:GetBossTouZiDataList()
	local cfg = TableCopy(self:GetBossTouZiCfg())
	local data_list = {}
	for i, v in ipairs(cfg) do
		if v.index ~= 0 then
			local fetch_reward_flag = InvestData.Instance:CheckIsFetchedBossByID(v.index + 1) and 1 or 0
			v.fetch_reward_flag = fetch_reward_flag
			table.insert(data_list, v)
		end
	end
	table.sort(data_list, SortTools.KeyLowerSorter("fetch_reward_flag", "index"))
	return data_list
end

function KaifuActivityData:GetBossTouZiAfterGold()
	local hai_ke_fan_huan_txt = 0
	local yi_fan_huan_txt = 0
	local li_ji_ling_qu_txt = 0

	local cfg = TableCopy(self:GetBossTouZiCfg())
	local data_list = {}
	for i, v in ipairs(cfg) do
		local fetch_reward_flag = InvestData.Instance:CheckIsFetchedBossByID(v.index + 1)
		if fetch_reward_flag then
			yi_fan_huan_txt = yi_fan_huan_txt + v.reward_gold_bind
		else
			hai_ke_fan_huan_txt = hai_ke_fan_huan_txt + v.reward_gold_bind
		end

		local now_kill_num = InvestData.Instance:GetBossKillNum()
		if now_kill_num >= v.kill_num then
			li_ji_ling_qu_txt = li_ji_ling_qu_txt + v.reward_gold_bind
		end			
	end

	return hai_ke_fan_huan_txt, yi_fan_huan_txt, li_ji_ling_qu_txt
end

function KaifuActivityData:IsAllFetchBossTouZi()
	local data_list = self:GetBossTouZiDataList()
	for i, v in ipairs(data_list) do
		if not InvestData.Instance:CheckIsFetchedBossByID(v.index + 1) then
			return false
		end
	end
	return true
end

---------------------------神域Boss投资------------------------------------------
function KaifuActivityData:GetShenYuBossTouZiCfg()
	return ConfigManager.Instance:GetAutoConfig("touzijihua_auto").shenyu_plan
end

function KaifuActivityData:GetShenYuBossTouZiPrice()
	return ConfigManager.Instance:GetAutoConfig("touzijihua_auto").other[1].shenyu_plan_price or 500
end

function KaifuActivityData:GetShenYuBossTouZiDataList()
	local cfg = TableCopy(self:GetShenYuBossTouZiCfg())
	local data_list = {}
	for i, v in ipairs(cfg) do
		if v.index ~= 0 then
			local fetch_reward_flag = InvestData.Instance:CheckIsFetchedShenYuBossByID(v.index + 1) and 1 or 0
			v.fetch_reward_flag = fetch_reward_flag
			table.insert(data_list, v)
		end
	end
	table.sort(data_list, SortTools.KeyLowerSorter("fetch_reward_flag", "index"))
	return data_list
end

function KaifuActivityData:GetShenYuBossTouZiAfterGold()
	local hai_ke_fan_huan_txt = 0
	local yi_fan_huan_txt = 0
	local li_ji_ling_qu_txt = 0

	local cfg = TableCopy(self:GetShenYuBossTouZiCfg())
	local data_list = {}
	for i, v in ipairs(cfg) do
		local fetch_reward_flag = InvestData.Instance:CheckIsFetchedShenYuBossByID(v.index + 1)
		if fetch_reward_flag then
			yi_fan_huan_txt = yi_fan_huan_txt + v.reward_gold_bind
		else
			hai_ke_fan_huan_txt = hai_ke_fan_huan_txt + v.reward_gold_bind
		end

		local now_kill_num = InvestData.Instance:GetShenYuBossKillNum()
		if now_kill_num >= v.kill_num then
			li_ji_ling_qu_txt = li_ji_ling_qu_txt + v.reward_gold_bind
		end			
	end

	return hai_ke_fan_huan_txt, yi_fan_huan_txt, li_ji_ling_qu_txt
end

function KaifuActivityData:IsAllFetchShenYuBossTouZi()
	local data_list = self:GetShenYuBossTouZiDataList()
	for i, v in ipairs(data_list) do
		if not InvestData.Instance:CheckIsFetchedShenYuBossByID(v.index + 1) then
			return false
		end
	end
	return true
end


--------------进阶红点逻辑梳理-----------------
-- 进阶返还功能是否开启
function KaifuActivityData:IsOpenAdvanceReturnActivity()
	local is_open = false
	local cfg = ActivityData.Instance:GetActivityConfig(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_RETURN)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if (cfg and cfg.min_level <= level and level <= cfg.max_level) and ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_RETURN) then
		is_open = true
	end

	local cfg_two = ActivityData.Instance:GetActivityConfig(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPLEVEL_RETURN_2)
	if (cfg_two and cfg_two.min_level <= level and level <= cfg_two.max_level) and ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPLEVEL_RETURN_2) then
		is_open = true
	end
	return is_open
end

-- 根据进阶类型、获取是否开启进阶返还活动 0,未开启 1开启
function KaifuActivityData:GetOpenAdvanceType(advance_type)
	local open_advance_type = AdvancedReturnData.Instance:GetUpGradeReturnActType()
	if advance_type == open_advance_type then
		return 1
	end
	return 0
end

-- 根据进阶类型、获取是否开启进阶返还活动 0,未开启 1开启
function KaifuActivityData:GetOpenAdvanceTypeTwo(advance_type)
	local open_advance_type = AdvancedReturnTwoData.Instance:GetUpGradeReturnActType()
	if advance_type == open_advance_type then
		return 1
	end
	return 0
end
--------------进阶红点逻辑梳理-----------------

function KaifuActivityData:ClearFinalList()
	self.final_list = {}
end