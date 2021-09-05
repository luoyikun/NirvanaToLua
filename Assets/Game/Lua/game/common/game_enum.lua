-----------------------------------------------------
-- 游戏中的枚举
-----------------------------------------------------
GameEnum =
{
	--背包分类Toggle类型
	TOGGLE_INFO ={
		ALL_TOGGLE ="all",
		EQUIP_TOGGLE = "equip",
		MATERIAL_TOGGLE = "material",
		CONSUME_TOGGLE = "consume",
		SPIRIT_TOGGLE = "spirit",
		MAGIC_WEAPON_TOGGLE = "magic_weapon",
		MAGIC_CARD_TOGGLE = "magic_card"
	},

	--不需要屏蔽怪物场景ID
	NOT_SHIELD_ENEMY_SCENE_ID = {
		QINGYUAN_FU_BEN = 520,
		GONG_HUI_ZHENG_BA = 1000,
		GONG_CHENG_ZHAN = 1002,
		LING_TU_ZHAN = 1003,
		DA_TI = 1100,
		WEN_QUAN = 1110,
		TIAN_JIANG_CAI_BAO = 1120,
		WANG_LING_TANG_XIAN = 1130,
		KUA_FU_ZU_DUI = 1140,
		JIE_DUAN_FU_BEN = 4001,
		JU_QING_FU_BEN = 4100,
		VIP_FU_BEN = 4400,
		-- JINGYAN_FU_BEN = 4501,
		KUA_FU_1V1 = 5002,
		YONG_SHI_ZHI_TA = 5101,
		HUN_YAN = 8050,
		XIU_LUO_TA = 7010,
	},

	--不显示别人掉落的场景
	SHIELD_OTHERS_FALLITEM_SCENE_ID = {
		[101] = true,
		[102] = true,
		[104] = true,
		[105] = true,
		[106] = true,
		[107] = true,
		[108] = true,
	},

	-- 属性顺序枚举
	AttrList = {
		[1] = "maxhp",
		[2] = "gongji",
		[3] = "fangyu",
	},

	-- 天降财宝最大任务
	TIANJIANGCAIBAO_TASK_MAX = 10,
	MAX_REWARD_ITEM_COUNT = 10,
	TIANJIANGCAIBAO_GOLD_RANK_MAX = 10,

	HOLIDAYGUARD_PERSON_RANK_MAX = 10,				-- 吃鸡盛宴排行榜最大人数
	RAND_ACTIVITY_HOLIDAYGUARD_PERSON_RANK_MAX = 10,
	HOLIDAYGUARD_NPC_CFG_MAX_COUNT = 200,
	FB_RECORD_DROP_ITEM_MAX_NUM = 7,

	NEW_SERVER_DAYS = 7,							-- 开服活动天数

	NOVICE_LEVEL = 150, 							--新手最大等级
	MULTI_ZHI_LEVEL = 130, 							--多个支线等级
	AVTAR_REMINDER_LEVEL = 120, 					--头像红点提示等级

	MINGREN_REMINDER_LEVEL = 150, 					--名人红点提示等级

	-- 转盘基本信息
	TURNTABLE_TYPE_MAX_COUNT = 16,
	TURNTABLE_OPERA_TYPE = 0,

	--婚宴操作
	HUNYAN_OPERA_TYPE_INVITE = 1,
	HUNYAN_OPERA_TYPE_HONGBAO = 2,
	HUNYAN_OPERA_TYPE_HUAYU = 3,
	HUNYAN_OPERA_TYPE_YANHUA = 4,
	HUNYAN_OPERA_TYPE_PAOHUAQIU = 5,
	HUNYAN_OPERA_TYPE_SAXIANHUA = 6,
	HUNYAN_OPERA_TYPE_INVITE_INFO = 7,

	--婚宴邀请类型
	HUNYAN_INVITE_TYPE_ALL_FRIEND = 0,				--邀请所有好友
	HUNYAN_INVITE_TYPE_ONE_FRIEND = 1,				--邀请单个好友
	HUNYAN_INVITE_TYPE_ALL_GUILD_MEMBER = 2,		--邀请所有公会成员
	HUNYAN_INVITE_TYPE_ONE_GUILD_MEMBER = 3,		--邀请单个公会成员

	ITEM_OPEN_TITLE = 3,							--背包打开称号面板
	--货币
	CURRENCY_COIN = 206003,								--金币（铜币）
	CURRENCY_BIND_COIN = 206004,						--绑定金币(绑定铜币)
	CURRENCY_BIND_GOLD = 206002,						--绑定钻石（绑定元宝）
	CURRENCY_GOLD = 206001,								--钻石（元宝）
	CURRENCY_NV_WA_SHI = 206005,						--水晶（女娲石）
	CURRENCY_KUA_FU = 206006,							--跨服
	CURRENCY_LING_JING = 206010,						--灵精

	NOVICE_WARM_TIP = 40,								--新手温馨提示

	--职业
	ROLE_PROF_1 = 1, 								--太渊
	ROLE_PROF_11 = 11,								--太初剑客
	ROLE_PROF_21 = 21,								--阴阳剑客
	ROLE_PROF_31 = 31,								--三清剑客
	ROLE_PROF_41 = 41,								--四象剑尊
	ROLE_PROF_51 = 51,								--五行剑尊
	ROLE_PROF_61 = 61,								--六合剑尊
	ROLE_PROF_71 = 71,								--七曜剑圣
	ROLE_PROF_81 = 81,								--八荒剑圣
	ROLE_PROF_91 = 91,								--九天剑圣
	ROLE_PROF_101 = 101,							--天地神尊
	ROLE_PROF_2 = 2, 								--孤影
	ROLE_PROF_12 = 12,								--太初剑姬
	ROLE_PROF_22 = 22,								--阴阳剑姬
	ROLE_PROF_32 = 32,								--三清剑姬
	ROLE_PROF_42 = 42,								--四象剑宗
	ROLE_PROF_52 = 52,								--五行剑宗
	ROLE_PROF_62 = 62,								--六合剑宗
	ROLE_PROF_72 = 72,								--七曜剑仙
	ROLE_PROF_82 = 82,								--八荒剑仙
	ROLE_PROF_92 = 92,								--九天剑仙
	ROLE_PROF_102 = 102,							--宇宙圣灵
	ROLE_PROF_3 = 3, 								--绝弦
	ROLE_PROF_13 = 13,								--太初琴师
	ROLE_PROF_23 = 23,								--阴阳琴师
	ROLE_PROF_33 = 33,								--三清琴师
	ROLE_PROF_43 = 43,								--四象琴绝
	ROLE_PROF_53 = 53,								--五行琴绝
	ROLE_PROF_63 = 63,								--六合琴绝
	ROLE_PROF_73 = 73,								--七曜琴魔
	ROLE_PROF_83 = 83,								--八荒琴魔
	ROLE_PROF_93 = 93,								--九天琴魔
	ROLE_PROF_103 = 103,							--洪荒祖灵
	ROLE_PROF_4 = 4, 								--无极
	ROLE_PROF_14 = 14,								--太初枪侠
	ROLE_PROF_24 = 24,								--阴阳枪侠
	ROLE_PROF_34 = 34,								--三清枪侠
	ROLE_PROF_44 = 44,								--四象枪灵
	ROLE_PROF_54 = 54,								--五行枪灵
	ROLE_PROF_64 = 64,								--六合枪灵
	ROLE_PROF_74 = 74,								--七曜枪神
	ROLE_PROF_84 = 84,								--八荒枪神
	ROLE_PROF_94 = 94,								--九天枪神
	ROLE_PROF_104 = 104,							--造化之主

	ROLE_PROF_MODEL = {
		[1] = 1101001,								--太渊职业对照模型ID
		[2] = 1102001,								--孤影职业对照模型ID
		[3] = 1003001,								--绝弦职业对照模型ID
		[4] = 1004001,								--无极职业对照模型ID
	},

	--性别
	FEMALE = 0,										--女性
	MALE = 1,										--男性

	--阵营
	ROLE_CAMP_0 = 0, 								--无
	ROLE_CAMP_1 = 1,								--昆仑
	ROLE_CAMP_2 = 2, 								--蓬莱
	ROLE_CAMP_3 = 3, 								--苍穹

	--物品颜色
	ITEM_COLOR_WHITE = 0,							-- 白
	ITEM_COLOR_GREEN = 1,							-- 绿
	ITEM_COLOR_BLUE = 2,							-- 蓝
	ITEM_COLOR_PURPLE = 3,							-- 紫
	ITEM_COLOR_ORANGE = 4,							-- 橙
	ITEM_COLOR_RED = 5,								-- 红
	ITEM_COLOR_GLOD = 7,							-- 金
	ITEM_COLOR_PINK = 6,							-- 粉

	--符文物品颜色
	RUNE_COLOR_WHITE = 0,							-- 白
	RUNE_COLOR_BLUE = 1,							-- 蓝
	RUNE_COLOR_PURPLE = 2,							-- 紫
	RUNE_COLOR_ORANGE = 3,							-- 橙
	RUNE_COLOR_RED = 4,								-- 红

	--装备品质颜色
	EQUIP_COLOR_GREEN = 0,							-- 绿
	EQUIP_COLOR_BLUE = 1,							-- 蓝
	EQUIP_COLOR_PURPLE = 2,							-- 紫
	EQUIP_COLOR_ORANGE = 3,							-- 橙
	EQUIP_COLOR_RED = 4,							-- 红
	EQUIP_COLOR_PINK = 5,							-- 粉

	--物品大类型
	ITEM_BIGTYPE_MEDICINE = 0, 						--回复药品类型
	ITEM_BIGTYPE_BUFF = 1, 							--buff类型
	ITEM_BIGTYPE_EXPENSE = 2, 						--消耗类型 能直接使用
	ITEM_BIGTYPE_GEMSTONE = 3, 						--宝石类型
	ITEM_BIGTYPE_POSITION = 4,						--坐标相关类型
	ITEM_BIGTYPE_OTHER = 5,							--被动使用类型 type value 最好不要直接实用
	ITEM_BIGTYPE_TASK = 6,							--人物类型
	ITEM_BIGTYPE_GIF = 7,							--礼包类型	能直接使用
	ITEM_BIGTYPE_SCENE_BUFF = 8,					--场景buff类型
	ITEM_BIGTYPE_EQUIPMENT = 100,					--装备类型
	ITEM_BIGTYPE_VIRTUAL = 101,						--虚拟类型 金币 铜币
	ITEM_BIGTYPE_JL = 102,							--精灵类型

	--背包类型
	PACKAGE_BIGTYPE_EQUIP = 0,						--背包装备
	PACKAGE_BIGTYPE_EXCHANGE = 1,					--背包交易
	PACKAGE_BIGTYPE_OTHER = 2,						--背包其他 

	EQUIP_TYPE_TOUKUI = 100,						--头盔
	EQUIP_TYPE_YIFU = 101,							--衣服
	EQUIP_KUZI = 102,								--裤子
	EQUIP_TYPE_XIEZI = 103,							--鞋子
	EQUIP_TYPE_HUSHOU = 104,						--护手
	EQUIP_TYPE_XIANGLIAN = 105,						--项链
	EQUIP_TYPE_WUQI = 106,							--武器
	EQUIP_TYPE_JIEZHI = 107,						--戒指
	EQUIP_TYPE_YAODAI = 108,						--腰带
	EQUIP_TYPE_YUPEI = 109,							--玉佩
	EQUIP_TYPE_SHOUZHUO = 110,						--手镯

	ZS_EQUIP_TYPE_TOUKUI = 900,						--转生头盔
	ZS_EQUIP_TYPE_YIFU = 901,						--转生衣服
	ZS_EQUIP_KUZI = 902,							--转生裤子
	ZS_EQUIP_TYPE_XIEZI = 903,						--转生鞋子
	ZS_EQUIP_TYPE_HUSHOU = 904,						--转生护手
	ZS_EQUIP_TYPE_XIANGLIAN = 905,					--转生项链
	ZS_EQUIP_TYPE_WUQI = 906,						--转生武器
	ZS_EQUIP_TYPE_JIEZHI = 907,						--转生戒指

	EQUIP_TYPE_JINGLING = 201,						-- 仙宠
	EQUIP_TYPE_JINGLING_SOUL = 204,					-- 仙宠灵魂装备子类型sub_type
	EQUIP_TYPE_HUNJIE = 202,						-- 婚戒
	EQUIP_TYPE_XIAOGUI = 203,						-- 小鬼

	TIANSHU_MAX_TYPE = 6,							    -- 天书寻主最大类型
	TIANSHU_CHENGZHANG_TYPE = 5,					    -- 天书寻主 成长天书类型 在普通天书之后

	E_TYPE_QINGYUAN_1 = 1000,						--结婚1
	E_TYPE_QINGYUAN_2 = 1001,						--结婚2
	E_TYPE_QINGYUAN_3 = 1002,						--结婚3
	E_TYPE_QINGYUAN_4 = 1003,						--结婚4
	E_TYPE_LITTLEPET_1 = 1200,						--小宠物玩具1
	E_TYPE_LITTLEPET_2 = 1201,						--小宠物玩具2
	E_TYPE_LITTLEPET_3 = 1202,						--小宠物玩具3
	E_TYPE_LITTLEPET_4 = 1203,						--小宠物玩具4
	BABY_MAX_COUNT = 10,							-- 最大可拥有的宝宝数量限制
	BABY_MAX_LEVEL = 10,							-- 宝宝最大等级
	BABY_MAX_GRADE = 12, 							-- 宝宝最大阶级
	BABY_SPIRIT_COUNT = 4,							-- 最大守护精灵数量
	MAX_SHENG_BABY_COUNT = 5,						-- 不超生最多生宝宝数量
	CAN_SHENG_BABY_LEVEL = 4,						-- 不超生最多生宝宝数量
	USE_TYPE_LITTLE_PET = 205,						-- 小宠物（Item使用类型）
	USE_TYPE_LITTLE_PET_FEED = 706,					-- 小宠物喂养道具
	EQUIP_TYPE_SHENGXIAO_1 = 1300,					-- 生肖装备1
	EQUIP_TYPE_SHENGXIAO_2 = 1301,					-- 生肖装备2
	EQUIP_TYPE_SHENGXIAO_3 = 1302,					-- 生肖装备3
	EQUIP_TYPE_SHENGXIAO_4 = 1303,					-- 生肖装备4
	EQUIP_TYPE_SHENGXIAO_5 = 1304,					-- 生肖装备4

	EQUIP_TYPE_LONGQI_1 = 1400,						-- 龙器装备1
	EQUIP_TYPE_LONGQI_2 = 1401,						-- 龙器装备2
	EQUIP_TYPE_LONGQI_3 = 1402,						-- 龙器装备3
	EQUIP_TYPE_LONGQI_4 = 1403,						-- 龙器装备4
	EQUIP_TYPE_LONGQI_5 = 1404,						-- 龙器装备5

	BIAN_SHEN_EQUIP_TYPE_1 = 1500,					-- 神魔装备1
	BIAN_SHEN_EQUIP_TYPE_2 = 1501,					-- 神魔装备2
	BIAN_SHEN_EQUIP_TYPE_3 = 1502,					-- 神魔装备3
	BIAN_SHEN_EQUIP_TYPE_4 = 1503, 					-- 神魔装备4
	--神州六器
	SHENZHOU_WEAPON_TYPE = 41,						 	--神州六器
	SHENZHOU_WEAPON_SLOT_COUNT = 6,						--神州六器槽数量
	SHENZHOU_WEAPON_BACKPACK_COUNT = 30,				--神州六器背包数量
	EQUIP_MAX_LEVEL = 50,								--神州六器最大等级
	MELT_MAX_LEVEL = 100,								--神州六器熔炼最大等级
	IDENTIFY_MAX_LEVEL = 10,							--神州六器鉴定最大等级
	IDENTIFY_STAR_MAX_LEVEL = 10,						--神州六器鉴定最大星级

	SEND_REASON_DEFAULT = 0,						-- 单个装备信息返回,默认
	SEND_REASON_COMPOUND = 1,						-- 单个装备信息返回,合成

	--转生装备使用类型
	ZHUANSHENG_SUB_TYPE_MIN = 900,
	ZHUANSHENG_SUB_TYPE_MAX = 907,

	E_TYPE_CAMP_MIN = 300,
	E_TYPE_CAMP_TOUKUI = 301,						-- 军团头盔
	E_TYPE_CAMP_YIFU = 302,							-- 军团衣服
	E_TYPE_CAMP_HUTUI = 303,						-- 军团护腿
	E_TYPE_CAMP_XIEZI = 304,						-- 军团鞋子
	E_TYPE_CAMP_HUSHOU = 305,						-- 军团护手
	E_TYPE_CAMP_XIANGLIAN = 306,					-- 军团项链
	E_TYPE_CAMP_WUQI = 307,							-- 军团武器
	E_TYPE_CAMP_JIEZHI = 308,						-- 军团戒指

	-- 装备位置索引
	EQUIP_INDEX_TOUKUI = 0,							--头盔
	EQUIP_INDEX_YIFU = 1,							--衣服
	EQUIP_INDEX_KUZI = 2,							--裤子
	EQUIP_INDEX_XIEZI = 3,							--鞋子
	EQUIP_INDEX_HUSHOU = 4,							--护手
	EQUIP_INDEX_XIANGLIAN = 5,						--项链
	EQUIP_INDEX_WUQI = 6,							--武器
	EQUIP_INDEX_JIEZHI = 7,							--戒指
	EQUIP_INDEX_YAODAI = 8,							--腰带
	EQUIP_INDEX_YUPEI = 9,							--玉佩
	EQUIP_INDEX_SHOUZHUO = 10,						--手镯
	EQUIP_INDEX_JIEZHI_2 = 11,						--戒指2

	EQUIP_INDEX_JINGLING = 21,						--精灵
	EQUIP_INDEX_HUNJIE = 22,						--婚戒

	--军团装备位置索引
	E_INDEX_CAMP_TOUKUI = 0,						--军团头盔
	E_INDEX_CAMP_YIFU = 1,							--军团衣服
	E_INDEX_CAMP_HUTUI = 2,							--军团护腿
	E_INDEX_CAMP_XIEZI = 3,							--军团鞋子
	E_INDEX_CAMP_HUSHOU = 4,						--军团护手
	E_INDEX_CAMP_XIANGLIAN = 5,						--军团项链
	E_INDEX_CAMP_WUQI = 6,							--军团武器
	E_INDEX_CAMP_JIEZHI = 7,						--军团戒指

	E_TYPE_ZHUANSHENG_1 = 900,						-- 转生武器
	E_TYPE_ZHUANSHENG_2 = 901,						-- 转生衣服
	E_TYPE_ZHUANSHENG_3 = 902,						-- 转生项链
	E_TYPE_ZHUANSHENG_4 = 903,						-- 转生吊坠
	E_TYPE_ZHUANSHENG_5 = 904,						-- 转生戒指
	E_TYPE_ZHUANSHENG_6 = 905,						-- 转生头盔
	E_TYPE_ZHUANSHENG_7 = 906,						-- 转生护肩
	E_TYPE_ZHUANSHENG_9 = 907,						-- 转生护腕
	E_TYPE_ZHUANSHENG_9 = 908,						-- 转生护腿
	E_TYPE_ZHUANSHENG_10 = 909,						-- 转生鞋子

	--飞升装备位置索引
	FS_EQUIP_INDEX_WUQI = 0,						--飞升武器
	FS_EQUIP_INDEX_YIFU = 1,						--飞升衣服
	FS_EQUIP_INDEX_HUSHOU = 2,						--飞升护手	
	FS_EQUIP_INDEX_YAODAI = 3,						--飞升腰带
	FS_EQUIP_INDEX_TOUKUI = 4,						--飞升头盔
	FS_EQUIP_INDEX_XIANGLIAN = 5,					--飞升项链
	FS_EQUIP_INDEX_SHOUZHUO = 6,					--飞升手镯
	FS_EQUIP_INDEX_JIEZHI = 7,						--飞升戒指
	FS_EQUIP_INDEX_XIEZI = 8,						--飞升鞋子
	FS_EQUIP_INDEX_YUPEI = 9,						--飞升玉佩

	FS_EQUIP_TYPE_WUQI = 1100,						--飞升武器
	FS_EQUIP_TYPE_YIFU = 1101,						--飞升衣服
	FS_EQUIP_TYPE_HUSHOU = 1102,					--飞升护手	
	FS_EQUIP_TYPE_YAODAI = 1103,					--飞升腰带
	FS_EQUIP_TYPE_TOUKUI = 1104,					--飞升头盔
	FS_EQUIP_TYPE_XIANGLIAN = 1105,					--飞升项链
	FS_EQUIP_TYPE_SHOUZHUO = 1106,					--飞升手镯
	FS_EQUIP_TYPE_JIEZHI = 1107,					--飞升戒指
	FS_EQUIP_TYPE_XIEZI = 1108,						--飞升鞋子
	FS_EQUIP_TYPE_YUPEI	 = 1109,					--飞升玉佩

	E_TYPE_ZHUANZHI_WUQI = 1100, 					-- 转职武器
	E_TYPE_ZHUANZHI_YIFU = 1101,                    -- 转职铠甲
	E_TYPE_ZHUANZHI_HUSHOU = 1102,                  -- 转职护手
	E_TYPE_ZHUANZHI_YAODAI = 1103,                  -- 转职腰带
	E_TYPE_ZHUANZHI_TOUKUI = 1104,                  -- 转职头盔
	E_TYPE_ZHUANZHI_XIANGLIAN = 1105,               -- 转职项链
	E_TYPE_ZHUANZHI_SHOUZHUO = 1106,                -- 转职手镯
	E_TYPE_ZHUANZHI_JIEZHI = 1107,                  -- 转职戒指
	E_TYPE_ZHUANZHI_XIEZI = 1108,                   -- 转职鞋子
	E_TYPE_ZHUANZHI_YUPEI = 1109,                   -- 转职玉佩

	E_TYPE_BAIZHAN_WUQI = 1600, 					-- 百战武器
	E_TYPE_BAIZHAN_YIFU = 1601,                    -- 百战铠甲
	E_TYPE_BAIZHAN_HUSHOU = 1602,                  -- 百战护手
	E_TYPE_BAIZHAN_YAODAI = 1603,                  -- 百战腰带
	E_TYPE_BAIZHAN_TOUKUI = 1604,                  -- 百战头盔
	E_TYPE_BAIZHAN_XIANGLIAN = 1605,               -- 百战项链
	E_TYPE_BAIZHAN_SHOUZHUO = 1606,                -- 百战手镯
	E_TYPE_BAIZHAN_JIEZHI = 1607,                  -- 百战戒指
	E_TYPE_BAIZHAN_XIEZI = 1608,                   -- 百战鞋子
	E_TYPE_BAIZHAN_YUPEI = 1609,                   -- 百战玉佩

	E_TYPE_DOUQI_WUQI = 1701, 						-- 斗气武器
	E_TYPE_DOUQI_TOUKUI = 1702,						-- 斗气头盔
	E_TYPE_DOUQI_YIFU = 1703,						-- 斗气衣服
	E_TYPE_DOUQI_HUSHOU = 1704,						-- 斗气护手
	E_TYPE_DOUQI_FUWU = 1705,						-- 斗气副武
	E_TYPE_DOUQI_HUTUI = 1706,						-- 斗气护腿
	E_TYPE_DOUQI_XIEZI = 1707,						-- 斗气鞋子
	E_TYPE_DOUQI_SHOUZHUO = 1708,					-- 斗气手镯
	E_TYPE_DOUQI_XIANGLIANG = 1709,					-- 斗气项链
	E_TYPE_DOUQI_YJIEZHI = 1710,					-- 斗气戒指	

	-- 宝石类型
	STONE_FANGYU = 1,								-- 防御类型宝石
	STONE_GONGJI = 2,								-- 攻击类型宝石
	STONE_HP = 3,									-- 血气类型的宝石

	--人物属性类型
	FIGHT_CHARINTATTR_TYPE_GLOBAL_COOLDOWN = 1,			--全局cooldown时间
	FIGHT_CHARINTATTR_TYPE_HP = 2,						--血量
	FIGHT_CHARINTATTR_TYPE_MP = 3,						--魔法
	FIGHT_CHARINTATTR_TYPE_MAXHP = 4,					--最大血量
	FIGHT_CHARINTATTR_TYPE_MAXMP = 5,					--最大魔法
	FIGHT_CHARINTATTR_TYPE_GONGJI = 6,					--攻击
	FIGHT_CHARINTATTR_TYPE_FANGYU = 7,					--防御
	FIGHT_CHARINTATTR_TYPE_MINGZHONG = 8,				--命中
	FIGHT_CHARINTATTR_TYPE_SHANBI = 9,					--闪避
	FIGHT_CHARINTATTR_TYPE_BAOJI = 10,					--暴击
	FIGHT_CHARINTATTR_TYPE_JIANREN = 11,				--坚韧（抗暴）
	FIGHT_CHARINTATTR_TYPE_MOVE_SPEED = 12,				--移动速度
	FIGHT_CHARINTATTR_TYPE_FUJIA_SHANGHAI = 13,			--附加伤害（女神攻击）
	FIGHT_CHARINTATTR_TYPE_DIKANG_SHANGHAI = 14,		--抵抗伤害（废弃）
	FIGHT_CHARINTATTR_TYPE_PER_JINGZHUN = 15,			--精准（破甲率）
	FIGHT_CHARINTATTR_TYPE_PER_BAOJI = 16,				--暴击（废弃）
	FIGHT_CHARINTATTR_TYPE_PER_KANGBAO = 17,			--抗暴（抵抗幸运一击）
	FIGHT_CHARINTATTR_TYPE_PER_POFANG = 18,				--破防百分比（增伤率）
	FIGHT_CHARINTATTR_TYPE_PER_MIANSHANG = 19,			--免伤百分比（免伤率）
	FIGHT_CHARINTATTR_TYPE_CONSTANT_ZENGSHANG = 20, 	--固定增伤
	FIGHT_CHARINTATTR_TYPE_CONSTANT_MIANSHANG = 21, 	--固定免伤
	FIGHT_CHARINTATTR_TYPE_HUIXINYIJI = 22,				--会心一击
	FIGHT_CHARINTATTR_TYPE_HUIXINYIJI_HURT_PER = 23,	--会心一击伤害率
	FIGHT_CHARINTATTR_TYPE_ZHUFUYIJI_PER = 24,	 		-- 祝福一击率
	FIGHT_CHARINTATTR_TYPE_GEDANG_PER = 25,				-- 格挡率
	FIGHT_CHARINTATTR_TYPE_GEDANG_DIKANG_PER = 26,		-- 格挡抵抗率
	FIGHT_CHARINTATTR_TYPE_GEDANG_JIANSHANG_PER = 27,	-- 格挡减伤万分比
	FIGHT_CHARINTATTR_TYPE_SKILL_ZENGSHANG = 28,		-- 技能增伤
	FIGHT_CHARINTATTR_TYPE_SKILL_JIANSHANG = 29,		-- 技能减伤
	FIGHT_CHARINTATTR_TYPE_MINGZHONG_PER = 30,			-- 命中率
	FIGHT_CHARINTATTR_TYPE_SHANBI_PER = 31,				-- 闪避率

	BASE_CHARINTATTR_TYPE_MAXHP = 41,					-- 基础最大血量
	BASE_CHARINTATTR_TYPE_MAXMP = 42,					-- 基础最大魔法
	BASE_CHARINTATTR_TYPE_GONGJI = 43,					-- 基础攻击
	BASE_CHARINTATTR_TYPE_FANGYU = 44,					-- 基础防御
	BASE_CHARINTATTR_TYPE_MINGZHONG = 45,				-- 基础命中
	BASE_CHARINTATTR_TYPE_SHANBI = 46,					-- 基础闪避
	BASE_CHARINTATTR_TYPE_BAOJI = 47,					-- 基础暴击
	BASE_CHARINTATTR_TYPE_JIANREN = 48,					-- 基础坚韧（抗暴）
	BASE_CHARINTATTR_TYPE_MOVE_SPEED = 49,				-- 基础移动速度
	BASE_CHARINTATTR_TYPE_FUJIA_SHANGHAI = 50,			-- 附加伤害（女神攻击）
	BASE_CHARINTATTR_TYPE_DIKANG_SHANGHAI = 51,			-- 抵抗伤害（女神抵抗）
	BASE_CHARINTATTR_TYPE_PER_JINGZHUN = 52,			-- 精准（破甲率）
	BASE_CHARINTATTR_TYPE_PER_BAOJI = 53,				-- 暴击（暴击伤害率）
	BASE_CHARINTATTR_TYPE_PER_KANGBAO = 54,				-- 抗暴（废弃）
	BASE_CHARINTATTR_TYPE_PER_BAOJI_HURT = 55,			-- 暴击伤害万分比
	BASE_CHARINTATTR_TYPE_PER_KANGBAO_HURT = 56,		-- 暴击伤害抵抗万分比
	BASE_CHARINTATTR_TYPE_PER_POFANG = 57,				-- 破防百分比（增伤率）
	BASE_CHARINTATTR_TYPE_PER_MIANSHANG = 58,			-- 免伤百分比（免伤率）
	BASE_CHARINTATTR_TYPE_CONSTANT_ZENGSHANG = 59,		-- 固定增伤
	BASE_CHARINTATTR_TYPE_CONSTANT_MIANSHANG = 60,		-- 固定免伤
	BASE_CHARINTATTR_TYPE_HUIXINYIJI = 61,				-- 会心一击
	BASE_CHARINTATTR_TYPE_HUIXINYIJI_HURT_PER = 62, 	-- 会心一击伤害率
	BASE_CHARINTATTR_TYPE_ZHUFUYIJI_PER = 63,			-- 祝福一击率
	BASE_CHARINTATTR_TYPE_GEDANG_PER = 64,				-- 格挡率
	BASE_CHARINTATTR_TYPE_GEDANG_DIKANG_PER = 65,		-- 格挡抵抗率
	BASE_CHARINTATTR_TYPE_GEDANG_JIANSHANG_PER = 66,	-- 格挡减伤万分比
	BASE_CHARINTATTR_TYPE_SKILL_ZENGSHANG = 67,			-- 技能增伤
	BASE_CHARINTATTR_TYPE_SKILL_JIANSHANG = 68,			-- 技能减伤
	BASE_CHARINTATTR_TYPE_MINGZHONG_PER = 69,			-- 基础命中率
	BASE_CHARINTATTR_TYPE_SHANBI_PER = 70,				-- 基础闪避率

	SPEICAL_CHARINTATTR_TYPE_PVP_JIANSHANG_PER = 71, --pvp减伤万分比
	SPEICAL_CHARINTATTR_TYPE_PVP_ZENGSHANG_PER = 72, --pvp增伤万分比
	SPEICAL_CHARINTATTR_TYPE_PVE_JIANSHANG_PER = 73, --pve减伤万分比
	SPEICAL_CHARINTATTR_TYPE_PVE_ZENGSHANG_PER = 74, --pve增伤万分比
	SPEICAL_CHARINTATTR_TYPE_SKILL_CAP_PER = 75, 	 --技能百分比

	JUMP_ROLE_LEVEL = 10,							--跳跃的最小角色等级
	JUMP_MAX_COUNT = 4,								--最大跳跃次数
	JUMP_RECOVER_TIME = 5,							--跳跃恢复时间
	JUMP_RANGE = 17,								--跳跃的距离

	--切换攻击模式
	SET_ATTACK_MODE_SUCC = 0,						-- 成功
	SET_ATTACK_MODE_PROTECT_LEVEL = 1,				-- 新手保护期
	SET_ATTACK_MODE_NO_CAMP = 2,					-- 没有加入阵营
	SET_ATTACK_MODE_NO_GUILD = 3,					-- 没有加入军团
	SET_ATTACK_MODE_NO_TEAM = 4,					-- 没有组队
	SET_ATTACK_MODE_PEACE_INTERVAL = 5,				-- 小于和平模式切换时间间隔
	SET_ATTACK_MODE_NO_GUILD_UNION = 6,				-- 没有军团联盟
	SET_ATTACK_MODE_STATUS_LIMIT = 7,				-- 当前状态下不允许切换攻击模式
	SET_ATTACK_MODE_MAX = 8,

	HESHENLUOSHU_MAX_TYPE = 5,											-- 河神洛图最大类型
	HESHENLUOSHU_MAX_SEQ = 10,											-- 河神洛图最大索引
	HESHENLUOSHU_MAX_INDEX = 16,										-- 河神洛图最大数量

	--攻击模式
	ATTACK_MODE_PEACE = 0,							-- 和平模式
	ATTACK_MODE_TEAM = 1,							-- 组队模式
	ATTACK_MODE_GUILD = 2,							-- 战盟模式
	ATTACK_MODE_ALL = 3,							-- 全体模式
	ATTACK_MODE_NAMECOLOR = 4,						-- 善恶模式
	ATTACK_MODE_CAMP = 5,							-- 阵营模式
	ATTACK_MODE_SREVER = 6,							-- 本服模式
	ATTACK_MODE_HATRED = 7,							-- 仇恨模式

	--名字颜色
	NAME_COLOR_WHITE = 0,							-- 白名
	NAME_COLOR_RED_1 = 1,							-- 红名
	NAME_COLOR_RED_2 = 2,							-- 红名
	NAME_COLOR_RED_3 = 3,							-- 红名
	NAME_COLOR_MAX = 0,

	MAX_FB_NUM = 60,								-- 副本数量
	FB_PHASE_MAX_COUNT = 32,						-- 阶段副本最大数量
	FB_STORY_MAX_COUNT = 20,						-- 剧情副本长度
	FB_VIP_MAX_COUNT = 16,							-- VIP副本长度
	FB_TOWER_MAX_COUNT = 100,						-- 爬塔副本长度

	FB_CHECK_TYPE = {
		FBCT_DAILY_FB = 1,							-- 日常副本
		FBCT_STORY_FB = 2,							-- 剧情副本
		FBCT_CHALLENGE = 3,							-- 挑战副本
		FBCT_PHASE = 4,								-- 阶段副本
		FBCT_FUN_MOUNT_FB = 5,						-- 功能开启副本坐骑
		FBCT_TOWERDEFEND_PERSONAL  = 6,				-- 单人塔防
		FBCT_YAOSHOUJITANG_TEAM = 8,				-- 妖兽祭坛组队本
		FBCT_QINGYUAN = 9,							-- 情缘副本
		FBCT_ZHANSHENDIAN = 10,						-- 战神殿副本
		FBCT_HUNYAN = 11,							-- 婚宴副本
		FBCT_TOWERDEFEND_TEAM = 12,					-- 组队塔防
		FBCT_ZHUANZHI_PERSONAL = 13,				-- 个人转职副本
		FBCT_MIGONGXIANFU_TEAM = 14,				-- 迷宫仙府副本
		FBCT_WUSHUANG = 15,							-- 无双副本
		FBCT_PATAFB = 16,							-- 爬塔副本
		FBCT_CAMPGAOJIDUOBAO = 17,					-- 师门高级夺宝
		FBCT_VIPFB = 18,							-- VIP副本
		FBCT_GUIDE = 21,							-- 引导副本
		FBCT_GUAJI_TA = 22,							-- 挂机塔
		FBCT_TEAM_EQUIP_FB = 23,					-- 组队装备副本
		FBCT_DAILY_TASK_FB = 24,					-- 支线副本
		FBCT_TUITU_NORMAL_FB = 25,					-- 推图副本
		FBCT_SHENGDI_FB = 26,						-- 圣地副本
		FBCT_NEQ_FB = 27,							-- 武器材料副本
		FBCT_PERSON_BOSS = 28,						-- 个人boss副本
		FBCT_ARMOR_FB = 29,				 			-- 个人装备本 防具材料
		FBCT_DEFENSE_FB = 30,				 		-- 塔防副本
		FBCT_ZHUANZHI_FB = 32,						-- 转职心魔副本
	},
	FIELD_GOAL_SKILL_TYPE_MAX = 8,					-- 技能数量

	FIELD_GOAL_SKILL_TYPE = {
		FIELD_GOAL_INVALID_SKILL_TYPE = 0,			--
		FIELD_GOAL_HURT_MONSTER_ADD = 1, 			-- 压制
		FIELD_GOAL_KILL_MONSTER_EXP_ADD = 2,		-- 盛宴
		FIELD_GOAL_ABSORB_BLOOD = 3,				-- 血祭
		FIELD_GOAL_MAX_SKILL_TYPE = 4,
	},

	-- 购买类型
	CONSUME_TYPE_BIND = 1,							--绑定元宝
	CONSUME_TYPE_NOTBIND = 2,						--元宝

	-- 商店类型
	SHOP = 1,										--商城
	SECRET_SHOP = 2,								--神秘商店

	--存储类型
	STORAGER_TYPE_BAG = 0,							--背包
	STORAGER_TYPE_STORAGER = 1,						--仓库

	DISCOUNT_BUY_PHASE_MAX_COUNT = 256,				--一折抢购数量
	DISCOUNT_BUY_ITEM_PER_PHASE = 16, 				--一折抢购阶段

	RA_MAX_CRACY_BUY_NUM_LIMIT = 21,				--狂欢大乐购最大物品数量

	STORAGER_SLOT_NUM = 125,						--仓库格子个数
	ROLE_BAG_SLOT_NUM = 125, 						--背包格子个数

	WORLD_EVENT_TYPE_MAX = 7, 						--世界事件类型数

	DAY_CHONGZHI_REWARD_FLAG_LIST_LEN = 4,			--天天返利奖励标志数量

	CARD_MAX = 12, 									--卡牌数
	NEW_BOSS_COUNT = 3, 							--镜像boss数

	MENTALITY_SHUXINGDAN_MAX_TYPE = 3, 				--属性丹种类

	ZODIAC_MAX_NUM = 12, 							-- 生肖最大数

	RA_EXREME_CHALLENGE_PERSON_TASK_MAX_NUM = 5,        -- 极限任务最大任务数

	--随机活动的常量
	RAND_ACTIVITY_SERVER_PANIC_BUY_ITEM_MAX_COUNT = 16, 	--全民疯抢
	RAND_ACTIVITY_PERSONAL_PANIC_BUY_ITEM_MAX_COUNT = 8,	--个人疯抢
	RAND_ACTIVITY_DAILY_LIMIT_BUY_MAX_SEQ = 4,				--每日限购

	MAX_ZHUANZHI_EQUIP_AWAKENING_COUNT = 3, 				--单件装备觉醒个数
	MAX_ZHUANZHI_EQUIP_COUNT = 10, 							--最大装备数
	HONGBAO_SEND = 0,							--发送红包
	HONGBAO_GET = 1,							--领取红包

	WUXINGGUAJI_STUFF_MAX = 5,						-- 材料个数
	WUXINGGUAJI_TARGET_MAX = 5,						-- 目标个数
	WUXINGGUAJI_BOSS_NUM = 1,						-- BOSS的最大数量

	BABY_BOSS_KILLER_MAX_COUNT = 5,			--宝宝boss击杀信息最大条数

	MENTALITY_WUXING_MAX_COUNT = 35,				-- 五行个数

	NOTIFY_REASON_GET = 0,							--仙盟运势 所有人
	NOTIFY_REASON_CHANGE = 1,						--仙盟运势 改变的人

	RA_COMBINE_BUY_MAX_ITEM_COUNT = 96, 			--组合团购物品数量最大值
	RA_COMBINE_BUY_BUCKET_ITEM_COUNT = 6,			--组合团购购物车可容纳物品数量最大值

	--------------------符文系统------------------------------
	RUNE_SYSTEM_BAG_MAX_GRIDS = 200,				--背包最大格子数量不可变 数据库
	RUNE_SYSTEM_SLOT_MAX_NUM = 10,					--符文槽最大数
	RUNE_SYSTEM_XUNBAO_RUNE_MAX_COUNT = 10,			--寻宝得符文最大数量
	RUNE_JINGHUA_TYPE = 19,							--符文精华类型
	RUNE_WUSHIYIJI_TYPE = 20,						--符文无视一击类型
	RUNE_MAX_LEVEL = 200,							--符文最大等级
	------------------------------------------------------------

		-----------------------小宠物相关-------------------------------
	LITTLEPET_QIANGHUAGRID_MAX_NUM = 5,
	LITTLE_PET_COUPLE_MAX_SHARE_NUM = 10, 				--夫妻共享宠物最大数量
	LITTLE_PET_MAX_CHOU_COUNT = 10, 					--抽奖次数最大值
	LITTLE_PET_SHARE_MAX_LOG_NUM = 20,
	MAX_FRIEND_NUM = 100, 								--最大好友数量
	LITTLEPET_QIANGHUAPOINT_CURRENT_NUM = 8, 			--当前强化点数量
	LITTLEPET_EQUIP_INDEX_MAX_NUM = 4, 					--小宠物玩具装备下标数
	--------------------------------------------------------------

	TEAM_MAX_COUNT = 3,								--组队最大人数

	-- RA_LIGHT_TOWER_EXPLORE_MAX_LAYER = 5,

	MOUNT_EQUIP_COUNT = 4,							--坐骑装备数量
	EQUIP_UPGRADE_PERCENT = 0.00006,				-- 装备升级乘以的百分比
	MOUNT_EQUIP_ATTR_COUNT = 3,						--坐骑装备属性数量
	MOUNT_EQUIP_MAX_LEVEL = 200,					--坐骑装备最大等级
	MAX_MOUNT_LEVEL = 100,							--坐骑最大等级
	MAX_MOUNT_GRADE = 30,							--坐骑最大阶数
	MAX_MOUNT_SPECIAL_IMAGE_ID = 64,                --可进阶坐骑特殊形象ID
	MAX_MOUNT_SPECIAL_IMAGE_ID_TWO = 128,                --可进阶坐骑特殊形象ID
	MAX_UPGRADE_LIMIT = 10,							--坐骑特殊形象进阶最大等级
	MOUNT_SKILL_COUNT = 4,							--坐骑技能数量
	MOUNT_SKILL_MAX_LEVEL = 100,					--坐骑技能最大等级
	MOUNT_SPECIAL_IMA_ID = 1000,					--坐骑特殊形象ID换算
	MAX_MOUNT_SPECIAL_IMAGE_COUNT = 16,                --坐骑特殊形象数量

	MAX_TOUSHI_SPECIAL_IMAGE_COUNT = 64,			-- 头饰特殊形象数量
	MAX_WAIST_SPECIAL_IMAGE_COUNT = 64,				-- 腰饰特殊形象数量
	MAX_QILINBI_SPECIAL_IMAGE_COUNT = 64,			-- 麒麟臂特殊形象数量
	MAX_MASK_SPECIAL_IMAGE_COUNT = 64,				-- 面饰特殊形象数量
	SKILL_COUNT = 4,								-- 头饰、面饰、腰饰、麒麟臂技能数量
	JINJIE_SHUXINGDAN_MAX_TYPE = 2,					-- 进阶类型属性丹的最大类型数量				
	UPGRADE_EQUIP_COUNT = 4,						-- 进阶系统装备数量
	UPGRADE_MAX_IMAGE_BYTE = 16,					-- 进阶系统的形象激活标记数量
	UPGRADE_IMAGE_MAX_COUNT = 128,					-- 进阶系统阶数列表
	UPGRADE_SYS_COUNT = 9,							-- 进阶系统数量
	UPGRADE_MAX_IMAGE_BYTE_TWO = 32,				-- 九个合在一起的进阶协议
	UPGRADE_IMAGE_MAX_COUNT_TWO = 256,				-- 九个合在一起的进阶协议

	MAX_XIANJIAN_COUNT = 8,							--仙剑把数（原先是8）
	JIANXIN_SLOT_PER_XIANJIAN = 7,					--每把剑的剑心孔数

	CSA_RANK_TYPE_MAX = 4,									--合服活动-排行榜MAX
	COMBINE_SERVER_ACTIVITY_RANK_REWARD_ROLE_NUM = 3,		--合服排行前几
	COMBINE_SERVER_RANK_QIANGOU_ITEM_MAX_TYPE = 3,			--合服抢购第一
	COMBINE_SERVER_SERVER_PANIC_BUY_ITEM_MAX_COUNT = 16,	--合服疯狂抢购全服物品数量
	COMBINE_SERVER_PERSONAL_PANIC_BUY_ITEM_MAX_COUNT = 8,	--合服疯狂抢购个人物品数量
	COMBINE_SERVER_MAX_FOUNDATION_TYPE = 10, 				--合服基金

	WUSHUANG_EQUIP_MAX_COUNT = 8,				-- 无双装备数量
	WUSHUANG_JINGLIAN_ATTR_COUNT = 3,			-- 武装精炼属性数量
	WUSHUANG_FUMO_SLOT_COUNT = 3,				-- 无双附魔槽数量
	WUSHUANG_FUHUN_SLOT_COUNT = 5,				-- 无双附魂槽数量
	WUSHUANG_FUHUN_COLOR_COUNT = 5,				-- 无双附魂颜色
	WUSHUANG_LIEHUN_POOL_MAX_COUNT = 18,		-- 猎魂池
	WUSHUANG_HUNSHOU_BAG_GRID_MAX_COUNT = 36,	-- 魂兽背包格子最大数
	HUNSHOU_EXP_ID = 30000,						-- 经验魂兽ID

	ZHUANSHENG_EQUIP_TYPE_MAX = 8,				-- 转生装备最大数量

	CARDZU_MAX_CARD_ID = 177,					-- 卡牌最大卡牌ID
	CARDZU_MAX_ZUHE_ID = 63,					-- 卡牌组合最大数量
	CARDZU_TYPE_MAX_COUNT = 4,					-- 卡牌类型最大数量

	QINGYUAN_CARD_MAX_ID = 19,					-- 情缘卡牌最大卡号

	WEDDING_GUESTS_MAX_NUM = 30,				-- 婚宴宾客最大数
	WEDDING_BLESSSING_MAX_RECORD_NUM = 30,		-- 祝福记录最大数
	HUNYAN_MARRY_USER_COUNT = 2,

	JUHUN_MAX_COLOR = 5, 								--聚魂的颜色
	BUILD_TOWER_MAX_TOWER_POS_INDEX = 19,				--塔防副本最大的塔数

	CHINESE_ZODIAC_SOUL_MAX_TYPE_LIMIT = 12,				-- 生肖精魄类型数量限制
	CHINESE_ZODIAC_LEVEL_MAX_LIMIT = 100,					-- 生肖精魄等级上限
	CHINESE_ZODIAC_EQUIP_SLOT_MAX_LIMIT = 8,				-- 生肖装备槽数量上限
	MIJI_KONG_NUM = 8,										-- 秘籍空数
	CHINESE_ZODIAC_XINGHUN_LEVEL_MAX = 12,					-- 生肖星魂等级最大值
	CHINESE_ZODIAC_XINGHUN_TITLE_COUNT_MAX = 6,			    -- 星魂称号最大数量
	CHINESE_ZODIAC_MAX_EQUIP_LEVEL = 80,					-- 装备最高等级
	TIAN_XIANG_COMBINE_MEX_BEAD_NUM = 15, 					-- 每个组合最多的珠子数


	TIAN_XIANG_TABEL_ROW_COUNT = 7,			-- 行
	TIAN_XIANG_TABEL_MIDDLE_GRIDS = 7,		-- 列
	TIAN_XIANG_ALL_CHAPTER_COMBINE = 3,		-- 每个章节的组合数
	TIAN_XIANG_CHAPTER_NUM = 10,			-- 章节最大数
	TIAN_XIANG_SPIRIT_CHAPTER_NUM = 5,		-- 星灵章节最大数

	CROSS_MULTIUSER_CHALLENGE_SIDE_MEMBER_COUNT = 3, 	-- 跨服3v3一方参赛人数
	CROSS_MULTIUSER_CHALLENGE_STRONGHOLD_NUM = 3, 		-- 跨服3V3据点数量
	MAX_XIANJIAN_SOUL_SKILL_SLOT_COUNT = 8,				-- 剑魂格子总数
	MAX_XIANJIAN_SOUL_COUNT = 14,				-- 剑魂技能总数
	SUOYAOTA_TASK_MAX = 4,						-- 锁妖塔任务数
	LIFESKILL_COUNT = 4,						-- 生活技能数量
	MAX_TEAM_MEMBER_NUM = 4,					-- 钟馗捉鬼最大人数
	NEW_FB_REWARD_ITEM_SC_MAX = 30,					-- 钟馗捉鬼最大物品数
	TIME_LIMIT_EXCHANGE_ITEM_COUNT = 10, 		-- 随机活动兑换数组长度
	SHUXINGDAN_MAX_TYPE = 3, 					-- 属性丹最大类型
	JINGLING_PTHANTOM_MAX_TYPE = 128, 			-- 精灵幻化升级最大等级
	JINGLING_EQUIP_MAX_PART = 8,
	JINGLING_CARD_MAX_TYPE = 16,

	JING_LING_SKILL_COUNT_MAX = 12,				-- 精灵技能最大数量
	JING_LING_SKILL_REFRESH_ITEM_MAX = 4,		-- 技能刷新最大格子数
	JING_LING_SKILL_REFRESH_SKILL_MAX = 11,		-- 技能刷新最大技能数量

	LIEMING_FUHUN_SLOT_COUNT = 8,				-- 精灵命魂曹数量
	LIEMING_LIEHUN_POOL_MAX_COUNT = 18,			-- 精灵命魂猎取池
	LIEMING_HUNSHOU_BAG_GRID_MAX_COUNT = 36,	-- 精灵命魂背包最大格子数量
	RAND_ACTIVITY_ZHENBAOGE_ITEM_COUNT = 9,				--珍宝阁格子数量
	RAND_ACTIVITY_TREASURE_BUSINESSMAN_REWARD_COUNT = 6, --秘宝商人奖励物品数量
	BIG_CHATFACE_GRID_COUNT = 9,						--表情拼图数目
	SC_RA_MONEYTREE_CHOU_MAX_COUNT_LIMIT = 10,			-- 摇钱树奖励最大数量
	RA_KING_DRAW_LEVEL_COUNT = 3,						--陛下请翻牌最大牌组数
	RA_KING_DRAW_MAX_SHOWED_COUNT = 9,					-- 陛下请翻牌最大牌数

	CS_CROSS_RA_CONSUME_RANK_REQ_TYPE_INFO = 0,			-- 跨服排行消费请求活动期间玩家消费信息

	RA_MINE_MAX_TYPE_COUNT = 12,				--当前挖到的矿石数
	RA_MINE_MAX_REFRESH_COUNT = 8,              --当前矿场的矿石
	RA_MINE_REFRESH_MAX_COUNT = 4,				-- 一次刷新出的最大矿石数目
	RA_MINE_TYPE_MAX_COUNT = 12,				-- 矿石类型最大数目
	RA_MINE_SERVER_REWARD_MAX_COUNT = 6,		-- 全服礼包最大数

	RA_GUAGUA_REWARD_AREA_COUNT = 5,			--刮奖区域数目
	RA_GUAGUA_AREA_ICON_COUNT = 3,				--刮奖区域的图标数

	RA_TIANMING_LOT_COUNT = 6,							--天命卜卦可加注标签数量
	RA_TIANMING_ADD_LOT_TIMES = 10,							--天命卜卦可加注次数
	RA_TIANMING_REWARD_HISTORY_COUNT = 20,				--天命卜卦奖励历史记录数量

	HUASHEN_MAX_ID = 10,                                 --化神最大数量
	HUASHEN_SPIRIT_MAX_ID_LIMIT = 5,					-- 化神守护精灵数量限制

	MAX_WING_FUMO_TYPE = 4,							--羽翼附魔数
	MAX_WING_FUMO_LEVEL = 100,						--羽翼附魔最大等级
	WING_SPECIAL_UPGRADE_COUNT = 16,             --特殊羽翼进阶最大数
	QINGYUAN_COUPLE_HALO_MAX_COUNT = 16, 				--情缘夫妻光环当前数量
	QINGYUAN_COUPLE_HALO_MAX_TYPE = 15,					--情缘夫妻光环最大数量
	QINGYUAN_COUPLE_HALO_MAX_ACTIVE_LIMIT = 8,			--一个夫妻光环需激活图标数量
	QINGYUAN_COUPLE_HALO_MAX_LEVEL = 10,                --夫妻光环最大升级数

	MULTIMOUNT_MAX_ID = 63, 							--双人坐骑最大数量
	COUPLEMOUNT_SPECIAL_IMG_MAX_ID_LIMIT = 31, 			--双人坐骑特殊形象最大数量
	MULTIMOUNT_EQUIP_TYPE_NUM = 8,						--双人坐骑装备数量

	RA_FANFAN_MAX_ITEM_COUNT = 50,						-- 最大奖励数量
	RA_FANFAN_MAX_WORD_COUNT = 10,						-- 最大字组数量
	RA_FANFAN_CARD_COUNT = 40,							-- 可翻牌数
	RA_FANFAN_CARD_COLUMN = 8,							-- 可翻牌列数
	RA_FANFAN_CARD_ROW = 5,								-- 可翻牌行数
	RA_FANFAN_LETTER_COUNT_PER_WORD = 4,				-- 每个字组字数
	RA_FANFAN_MAX_WORD_ACTIVE_COUNT = 99,				-- 最多激活字组数量
	CROSS_TUANZHAN_PILLA_MAX_COUNT = 6,					-- 柱子最大数量

	PASTURE_SPIRIT_MAX_COUNT = 12,						--牧场精灵最大数量
	SC_PASTURE_SPIRIT_LUCKY_DRAW_RESULT_MAX_COUNT = 50, --牧场抽奖数量

	GODDESS_ANIM_SHORT_TIME = 2,						--女神动画短间隔时间
	GODDESS_ANIM_LONG_TIME = 8,							--女神动画播放完是三个动画后的时间间隔

	PERSONALIZE_WINDOW_MAX_TYPE = 2,					--个性化聊天窗口类型
	PERSONALIZE_WINDOW_MAX_INDEX = 31,					--单个个性化聊天窗口数量

	RA_EXTREME_LUCKY_REWARD_COUNT = 10,                 -- 至尊幸运星每次抽奖物品数量

	GOLDEN_PIG_SUMMON_TYPE_MAX = 3,						--金猪召唤boss类型

	SHENGE_SYSTEM_SHENGESHENQU_MAX_NUM = 10,
	SHENGE_SYSTEM_SHENGESHENQU_ATTR_MAX_NUM = 7,
	SHENGE_SYSTEM_SHENGESHENQU_XILIAN_SLOT_MAX_NUM = 3,

	WUSHANGEQUIP_MAX_TYPE_LIMIT = 4,					--跨服神器类型最大限制
	KUAFU_STRENGTH_LEVEL = 20,							--跨服强化等级
	KUAFU_STAT_LEVEL = 10,								--跨服升星等级
	RARE_CHEST_SHOP_MODE = 10,                       	--至尊寻宝十连抽
	MITAMA_MAX_MITAMA_COUNT = 5,						--御魂最大数量
	MITAMA_MAX_SPIRIT_COUNT = 5,						--御魂等级
	HOT_SPRING_MONSTER_COUNT = 9,                       --温泉里面怪物三消的怪物数量
	BLACK_MARKET_MAX_ITEM_COUNT = 3, 					-- 黑市竞拍物品数量
	MAGIC_EQUIP_MAX_COUNT = 5,			                -- 魔器装备最大数量
	MAGIC_EQUIP_STONE_SLOT_COUNT = 6,		            -- 魔器能镶嵌的宝石孔个数

	MAX_XIANNV_ID = 6,								--最大仙女id
	MIN_XIANNV_ID = 0, 								--最小仙女id
	ZHUZHAN_XIANNV_SHANGHAI_PRECENT = 0.8,      	--助战仙女伤害百分比
	WEI_ZHUZHAN_XIANNV_SHANGHAI_PRECENT = 1, --0.2,      --未出战仙女伤害百分比
	ACTIVE_ITEM_NUM	= 1,							--激活仙女需要物品数量

	FISHING_FISH_TYPE_MAX_COUNT = 8,		-- 鱼的种类数
	FISHING_GEAR_MAX_COUNT = 3,				-- 法宝种类数
	FISHING_BE_STEAL_NEWS_MAX = 5,			-- 钓鱼被偷日志数量
	FISHING_SCORE_MAX_RANK = 10,			-- 钓鱼积分排行榜最大数量

	MAX_RANK_COUNT = 16,					-- 乱斗战场奖励排行

	RAND_ACTIVITY_ITEM_COLLECTION_SECOND_REWARD_MAX_COUNT = 5, --月饼活动数量
	
	BAG_INFO = {
		BAG_CELL_WIDTH =91, 				-- 背包一个cell单元的宽度
		BAG_MAX_GRID_NUM = 100,				-- 背包格子总数
		BAG_MAX_GRID_NUM_125 = 125,          -- 背包格子总数 125
		BAG_ROW = 4,						-- 背包一页行数
		BAG_ROW_FIVE = 5,					-- 背包一页 5 行
		BAG_COLUMN = 5,						-- 背包一页列数
		BAG_PAGE_COUNT = 5, 				-- 背包页数
	},
	--市场寄售的背包
	MARKET_INFO = {
		BAG_CELL_WIDTH = 80, 				-- 背包一个cell单元的宽度
		BAG_MAX_GRID_NUM = 100,				-- 背包格子总数
		BAG_ROW = 5,						-- 背包一页行数
		BAG_COLUMN = 4,						-- 背包一页列数
		BAG_PAGE_COUNT = 5, 				-- 背包页数

	},
	MAIL_BAG_INFO = {						-- 邮件中的背包
		BAG_CELL_WIDTH = 85, 				-- 背包一个cell单元的宽度
		BAG_MAX_GRID_NUM = 100,				-- 背包格子总数
		BAG_ROW = 5,						-- 背包一页行数
		BAG_COLUMN = 4,						-- 背包一页列数
		BAG_PAGE_COUNT = 5, 				-- 背包页数
	},

	GRID_TYPE_BAG = "bag", 					-- 格子类型(背包)
	GRID_TYPE_STORAGE = "storge",			-- 格子类型(仓库)

	CARD_INFO = {
		CARD_CELL_WIDTH = 220, 				-- 怪物图鉴一个cell单元的宽度
		CARD_MAX_GRID_NUM = 16,				-- 怪物图鉴格子总数
		CARD_ROW = 4,						-- 怪物图鉴一页个数
		CARD_PAGE_COUNT = 4, 				-- 怪物图鉴页数

		CARD_MAX_ITEM_NUM = 64,				-- 怪物图鉴碎片格子总数
		CARD_ITEM_ROW = 4,					-- 怪物图鉴碎片一页行数
		CARD_ITEM_COLUMN = 4,				-- 怪物图鉴碎片一页列数
		CARD_ITEM_PAGE_COUNT = 4, 			-- 怪物图鉴碎片页数
		CARD_ITEM_CELL_WIDTH = 91,			-- 怪物图鉴碎片一个cell单元的宽度
	},

	TIANSHENHUTI_EQUIP_MAX_COUNT = 8,             -- 装备部位数量
	TIANSHENHUTI_BACKPACK_MAX_COUNT = 100,        -- 背包格子数量
	TIANSHENHUTI_BATCH_ROLL_TIMES = 5,
	TIANSHENHUTI_EQUIP_USE_TYPE = 118, 			-- 周末装备使用类型
	
	XING_MAI_SLIDER_TIME = 3,				-- x星脉冷却条充满时间
	MAX_CROSS_BOSS_PER_SCENE = 20,			-- 场景内最大boss数量

	ROLE_TALENT_OPERATE_TYPE = {
		ROLE_TALENT_OPERATE_TYPE_INFO = 0,    -- 请求天赋信
		ROLE_TALENT_OPERATE_TYPE_UPLEVEL = 1, -- 升级天赋
		ROLE_TALENT_OPERATE_TYPE_RESET = 2,   -- 重置天赋点
	},

	MAX_TELENT_TYPE_COUT = 4,							-- 人物天赋成长路线
	MAX_TELENT_INDEX_COUT = 20,							-- 人物天赋路线技能个数

	MAX_NOTICE_COUNT = 30,					-- 爱情契约聊天最大数

	PERSONAL_GOAL_COND_MAX = 3,				-- 个人目标条件

	XIAN_ZHEN_HUN_YU_TYPE_MAX = 3, 			-- 仙镇魂玉类型

	SHENSHOU_MAX_BACKPACK_COUNT = 200,					-- 龙器背包容量个数
	SHENSHOU_MAX_EQUIP_SLOT_INDEX = 4, 					-- 龙器装备最大部位index
	SHENSHOU_MAX_ID = 32,								-- 龙器最大ID
	SHENSHOU_MAX_EQUIP_ATTR_COUNT = 3,					-- 龙器装备最大随机属性个数
	SHENSHOU_EQ_MAX_LV = 300,							-- 龙器装备最大等级

	-------------------福利---------------------------
	MAX_GROWTH_VALUE_GET_TYPE = 4,				--欢乐果树成长值最大数量
	MAX_CHONGJIHAOLI_RECORD_COUNT = 30,			--冲级豪礼最大数量

	----------------------夫妻家园-----------------------------
	COUPLE_HOME_SEARCH_TYPE = 713,								-- 市场搜索类型
	COUPLE_HOME_FURNITURE_TYPE = 800,							-- 市场家具商店类型
	SPOUSE_HOME_MAX_ROOM_NUM = 6,								-- 最大房子数量
	SPOUSE_HOME_FURNITURE_MAX_ITEM_SLOT_SERVER = 20,			-- 服务器最大可放置的道具数量

	SALE_TYPE_COUNT_MAX = 100,				-- 拍卖种类
	Lock_Time = 120,							-- 自动锁屏时间

	JING_LING_HOME_REWARD_ITEM_MAX = 40, 	-- 精灵家园列表长度
	JINGLING_MAX_TAKEON_NUM = 4, 			-- 放养精灵最大数目

	MAX_GUILD_BOX_COUNT = 8,				-- 公会铸剑最大可铸剑数量
	GUILD_BATTLE_NEW_POINT_NUM = 5,			-- 公会争霸据点数量
	FIGHTING_CHALLENGE_OPPONENT_COUNT = 4,	-- 挖矿挑战角色人数
	MAX_CAMERA_MODE = 3,					-- 摄像机模式
	JING_LING_EXPLORE_LEVEL_COUNT = 6, 		-- 精灵探险关卡数量

	RA_MARRY_SHOW_COUPLE_COUNT_MAX = 10,	-- 我们结婚吧最多显示对数
	RA_PERFECT_LOVE_COUPLE_COUNT_MAX = 50,	-- 完美情人排行最大对数

	SPIRIT_MEET_SCENE_COUNT = 9,			-- 精灵奇遇场景数
	SHENSHOU_MAX_RERFESH_ITEM_COUNT = 14,	-- 唤灵物品显示数量

	IMG_FULING_JINGJIE_TYPE_MAX = 8,		-- 赋灵种类最大数量
	IMG_FULING_SLOT_COUNT = 7,				-- 赋灵格子数
	TALENT_TYPE_MAX = 8,					-- 天赋种类数量
	TALENT_CHOUJIANG_GRID_MAX_NUM = 9,		-- 天赋抽奖最大格子数量
	TALENT_SKILL_GRID_MAX_NUM = 13,			-- 天赋技能最大格子数量

	COMBINE_SERVER_BOSS_MAX_COUNT = 15,  	-- 合服boss最大数量
	COMBINE_SERVER_BOSS_RANK_NUM = 10,		-- 合服boss排行榜显示最大数量

	ELEMENT_HEART_WUXING_TYPE_MAX = 5,		-- 元素之心五行最大数量
	ELEMENT_HEART_MAX_COUNT = 5,			-- 元素之心槽最大数量
	ELEMENT_HEART_MAX_XILIAN_SLOT = 8,		-- 元素之心洗练最大数量
	ELEMENT_HEART_MAX_GRID_COUNT = 100, 	-- 元素之涌背包格子数
	ELEMENT_SHOP_ITEM_COUNT = 10,			-- 商店当前刷新出来的物品数量
	ELEMENT_MAX_EQUIP_SLOT = 6,				-- 元素之心最大装备格子数量

	MAX_REWARD_LIMIT = 400, 				-- 挖宝奖励最大个数
	PASTURE_SPIRIT_MAX_IMPRINT_ATTR_COUNT = 5,	-- 印记附加属性最大条数
	SHEN_YIN_LIEHUN_POOL_MAX_COUNT = 20,	-- 神印猎魂池最大数量

	SC_HUANLE_YAOJIANG_MAX_TIMES = 30,

	CROSS_MIZANG_BOSS_MAX_HISTROY_RECROD = 8,						--跨服秘藏boss最大击杀记录
	CROSS_MIZANG_BOSS_SCENE_MAX = 5,								--跨服秘藏boss场景最大个数
	CROSS_MIZANG_BOSS_MAX_ORDINARY_CRYSTAL = 60,					--跨服秘藏boss最大普通水晶
	MAX_CROSS_MIZANG_BOSS_PER_SCENE = 20,							--每个场景boss最大个数
	CROSS_MIZANG_BOSS_MAX_MONSTER_NUM = 200,						--跨服秘藏boss小怪最大数量
	CROSS_MIZANG_BOSS_MAX_TREASURE_CRYSTAL_POS_NUM = 60,			--跨服秘藏boss最大珍惜水晶

	SEASONS_MIN = 8,
	SEASONS_MAX = 11,
	BOLL_GROUP_MAX_NUM = 14,				-- 天象组合需要最多珠子数量
	CROSS_DARK_NIGHT_MONSTER_MAX_COUNT = 5, 	--月黑风高BOSS最大波数
	CROSS_DARK_NIGHT_BOSS_POS_INDEX_MAX = 5, 	--月黑风高一波boss数量(读协议用)
	CROSS_1V1_SEASON_MAX = 32,				--跨服1v1赛季戒指最大数量
	MAX_UPGRADE_RECORD_COUNT = 10,			-- 全民总动员数组长度
	MAX_COUNT = 10, 						-- 消费领奖
	LIEKUN_ZONE_TYPE_COUNT = 5, 			-- 猎鲲地带区域数
	LIEKUN_BOSS_TYPE_COUNT = 5, 			-- 猎鲲boss数量

	SHENQI_SUIT_NUM_MAX = 64,				-- 对应神兵的下标，总共64种神兵
	SHENQI_PART_TYPE_MAX = 4,

	ZHUAN_ZHI_SKILL1 = 180,					-- 转职技能1
	ZHUAN_ZHI_SKILL2 = 181,					-- 转职技能2
	KILL_SKILL_ID = 5,						-- 必杀技
	SPECIAL_BUFF_MAX_BYTE = 16,				-- 特殊BUFF标记字节数
	SPECIAL_BABY_TYPE_MAX = 2, 				-- 特殊宝宝信息
	YUNYOU_BOSS_MAX_SCENE_NUM = 20,			-- 云游boss最大数量
	PACKAGEEXPANSIANSION = 0,				-- 背包消耗材料扩展类型
}

GAME_DISPLAY_TYPE = {ALL_TITLE = 0,XIAN_NV = 1, MOUNT = 2, WING = 3, FASHION = 4, HALO = 5, SPIRIT = 6, FIGHT_MOUNT = 7, SHENGONG = 8, SHENYI = 9,
				SPIRIT_HALO = 10, SPIRIT_FAZHEN = 11, NPC = 12, BUBBLE = 13, ZHIBAO = 14, MONSTER = 15, ROLE = 16, DAILY_CHARGE = 17,
				TITLE = 18, XUN_ZHANG = 19, ROLE_WING = 20, WEAPON = 21, SHENGONG_WEAPON = 22, FORGE = 23, GATHER = 24, STONE = 25,
				SHEN_BING = 26, BOX = 27, HUNQI = 28, ZEROGIFT = 29, FOOTPRINT = 30, TASKDIALOG = 31, CLOAK = 32, COUPLE_HALO = 33, GENERAL = 34, HEAD_FRAME = 35,
				TOU_SHI = 36, MIAN_SHI = 37, YAO_SHI = 38, QIN_LIN_BI = 39, SUPER_BABY = 40, TAIL = 41, FLYPET = 42, SHOUHUAN = 43,
				LING_ZHU = 44, LING_QI = 45, LING_GONG = 46, XIAN_BAO = 47, WEI_YAN = 48, LING_CHONG = 49,}

LIEMING_BAG_NOTIFY_REASON = {
	LIEMING_BAG_NOTIFY_REASON_INVALID = 0,
	LIEMING_BAG_NOTIFY_REASON_BAG_MERGE = 1,
	LIEMING_BAG_NOTIFY_REASON_MAX = 2,
}

RA_KUANG_HAI_OPERA_TYPE =
{
	RA_KUANG_HAI_OPERA_TYPE_INFO = 0,			    -- 请求信息
	RA_KUANG_HAI_OPERA_TYPE_FETCH_REWARD = 1,	    -- 兑换奖励，param_1 = 奖励索引
}

-- 每日次数
DAY_COUNT = {
	DAYCOUNT_ID_FB_START = 0,						--  副本开始
	DAYCOUNT_ID_FB_XIANNV = 1,						-- 仙女
	DAYCOUNT_ID_FB_COIN = 2, 						-- 铜币
	DAYCOUNT_ID_FB_WING = 3,						-- 羽翼
	DAYCOUNT_ID_FB_XIULIAN = 4,						-- 修炼
	DAYCOUNT_ID_FB_QIBING = 5,						-- 骑兵

	DAYCOUNT_ID_FB_END = GameEnum.MAX_FB_NUM - 1,	-- 副本结束

	VAT_TOWERDEFEND_FB_FREE_AUTO_TIMES = 18,

	DAYCOUNT_ID_EVALUATE = 61,											-- 评价次数
	DAYCOUNT_ID_JILIAN_TIMES = 62,										-- 祭炼次数
	DAYCOUNT_ID_ACCEPT_HUSONG_TASK_COUNT = 63,							-- 护送任务 领取个数
	DAYCOUNT_ID_SHUIJING_GATHER = 64,									-- 采集物
	DAYCOUNT_ID_YAOSHOUJITAN_JOIN_TIMES = 65,							-- 妖兽祭坛参加次数
	DAYCOUNT_ID_FREE_CHEST_BUY_1 = 66,									-- 一次寻宝免费次数
	DAYCOUNT_ID_COMMIT_DAILY_TASK_COUNT = 67,							-- 日常任务 提交个数
	DAYCOUNT_ID_HUSONG_ROB_COUNT = 68,									-- 护送抢劫次数
	DAYCOUNT_ID_HUSONG_TASK_VIP_BUY_COUNT = 69,							-- 护送任务 vip购买次数
	DAYCOUNT_ID_HUSONG_REFRESH_COLOR_FREE_TIMES = 70,					-- 护送任务 免费刷新次数
	DAYCOUNT_ID_CAMP_TASK_COMPLETE_COUNT = 71,							-- 阵营任务完成次数
	DAYCOUNT_ID_GUILD_TASK_COMPLETE_COUNT = 72,							-- 仙盟任务完成次数
	DAYCOUNT_ID_FETCH_DAILY_COMPLETE_TASK_REWARD_TIMES = 73,			-- 日常领取全部任务完成奖励次数
	DAYCOUNT_ID_ANSWER_QUESTION_COUNT = 74,								-- 答题次数
	DAYCOUNT_ID_VIP_FREE_REALIVE = 75,									-- vip免费复活次数
	DAYCOUNT_ID_CHALLENGE_BUY_JOIN_TIMES = 76,							-- 挑战副本购买参与次数
	DAYCOUNT_ID_CHALLENGE_FREE_AUTO_FB_TIMES = 77,						-- 挑战副本免费扫荡次数
	DAYCOUNT_ID_BUY_ENERGY_TIMES = 78,									-- 购买体力次数
	DAYCOUNT_KILL_OTHER_CAMP_COUNT,										-- 击杀其他阵营玩家 双倍奖励次数
	DAYCOUNT_ID_GONGCHENGZHAN_REWARD,									-- 攻城战奖励
	DAYCOUNT_ID_TEAM_TOWERDEFEND_JOIN_TIMES = 82,						-- 组队塔防参与次数
	DAYCOUNT_ID_GCZ_DAILY_REWARD_TIMES = 83,							-- 攻城战领取每日奖励次数
	DAYCOUNT_ID_XIANMENGZHAN_RANK_REWARD_TIMES = 84,					-- 仙盟战排名奖励次数
	DAYCOUNT_ID_MOBAI_CHENGZHU_REWARD_TIMES = 85,						-- 膜拜城主次数
	DAYCOUNT_ID_GUILD_ZHUFU_TIMES = 86,									-- 仙盟运势祝福次数
	DAYCOUNT_ID_MIGOGNXIANFU_JOIN_TIMES = 92,							-- 迷宫仙府参与次数
	DAYCOUNT_ID_JOIN_YAOSHOUGUANGCHANG = 93,       						-- 参加妖兽广场每日次数
	DAYCOUNT_ID_JOIN_SUOYAOTA = 94,       								-- 参加锁妖塔每日次数
	DAYCOUNT_ID_GATHER_SELF_BONFIRE = 95,       						-- 采集自己仙盟篝火每日次数
	DAYCOUNT_ID_BONFIRE_TOTAl = 96,       								-- 采集仙盟篝火总次数
	DAYCOUNT_ID_DABAO_BOSS_BUY_COUNT = 97,       						-- 购买打宝地图进入次数
	DAYCOUNT_ID_DABAO_ENTER_COUNT = 98,       							-- 打宝地图进入次数
	DAYCOUNT_ID_JINGHUA_GATHER_COUNT = 101,								-- 精华采集次数
	DAYCOUNT_ID_CAMP_GAOJIDUOBAO = 102,									-- 军团高级夺宝
	DAYCOUNT_ID_GUILD_REWARD = 104,										-- 仙盟奖励
	DAYCOUNT_ID_GUILD_BONFIRE_ADD_MUCAI = 105,							-- 仙盟篝火捐献木材次数
	DAYCOUNT_ID_JINGLING_SKILL_COUNT = 107,								-- 精灵技能免费刷新次数
	DAYCOUNT_ID_BUY_MIKU_WERARY = 108,									-- 精英BOSS疲劳购买次数
	DAYCOUNT_ID_MONEY_TREE_COUNT = 109,									-- 摇钱树转转转乐免费抽将次数
	DAYCOUNT_ID_JING_LING_HOME_ROB_COUNT = 110, 						-- 精灵家园掠夺次数								-- 夺宝购买次数
	DAYCOUNT_ID_JING_LING_EXPLORE = 111, 								-- 精灵探险次数
	DAYCOUNT_ID_JING_LING_EXPLORE_RESET = 112, 							-- 精灵探险重置次数
	DAYCOUNT_ID_BUY_ACTIVE_WERARY = 114, 								-- 活跃BOSS疲劳购买次数
	DAYCOUNT_ID_PERSON_BOSS_ENTER_TIMES = 116,								-- 个人BOSS每天进入次数
	DAYCOUNT_ID_BUILD_TOWER_FB_BUY_TIMES = 117,							-- 建塔本购买次数
	DAYCOUNT_ID_BUILD_TOWER_FB_ENTER_TIMES = 118,						-- 建塔本进入次数
	DAYCOUNT_ID_TEAM_EQUIP_FB_JOIN_TIMES = 120,							-- 精英组队副本参与次数
	DAYCOUNT_ID_TEAM_FB_ASSIST_TIMES = 999,								-- 组队副本协助次数
	DAYCOUNT_ID_JINGLING_ADVANTAGE_BOSS_KILL_COUNT = 121,				-- 仙宠奇遇boss击杀次数
	DAYCOUNT_ID_PERSONAL_BUY_COUNT = 122,								-- 个人BOSS购买次数
}

MONSTER_TYPE = {
	MONSTER = 0,
	BOSS = 1,
}

GUAI_JI_TYPE = {
	NOT = 0,										-- 不挂机
	ROLE = 1,										-- 挂机打人
	MONSTER = 2,									-- 挂机打怪
}

SERVER_TYPE = {
	RECOMMEND = 1,
	ALL = 2,
}

--攻城战传送类型
CITY_COMBAT_MOVE_TYPE ={
	ATTACK_PLACE = 0,
	DEFENCE_PLACE = 1,
	ZHIYUAN_PLACE = 2,
}

MAINUI_TIP_TYPE = {
	FRIEND = 1,
	GUILD = 2,
	TEAM_INVITE = 3,								-- 仙盟邀请
	TEAM_APPLY = 4,									-- 队伍申请与邀请
	TEAM = 5,										-- 队伍
	HU = 6,
	JIU = 7,
	YUAN = 8,
	WABAO = 9,
	JILIAN = 10,
	MAIL = 11, 										-- 充值返利邮件
	Trade = 14,										-- 交易
	FIELD1V1_FAIL = 15,								-- 斗法封神失败提醒
	BLESSWISH = 16,									-- 祝福邀请提醒
	WEDDING = 17,									-- 婚宴提醒
	REDENVELOPES = 18,								-- 红包提醒
	MI_JING = 19,									-- 仙盟秘境
	YUNSHI = 20,									-- 仙盟运势提醒图标
	REDNAME = 21,									-- 红名提示
	PRIVILEGE = 22,									-- 一折抢购提示
	TEAM_FB = 23,									-- 团队副本
	XIONGSHOU = 24,									-- 仙盟凶兽
	BONFIRE = 25,									-- 仙盟篝火
	SPACE_GIFT = 26,								-- 空间送礼
	SPACE_LIUYAN = 27,								-- 空间浏览
	CLEAR_BAG = 28,									-- 清理背包
	GONGGAO = 29,									-- 公告栏
	DAILYLOVE = 30, 								-- 每日一爱提示
}

TUMO_NOTIFY_REASON_TYPE = {
	TUMO_NOTIFY_REASON_DEFALUT = 0,					--屠魔默认通知类型
	TUMO_NOTIFY_REASON_ADD_TASK = 1,				--增加任务
	TUMO_NOTIFY_REASON_REMOVE_TASK = 2,				--移除任务

	TUMO_ONE_KEY_COMPLETION = 4,					--一键完成
}

--进阶属性丹类型
SHUXINGDAN_TYPE = {
	SHUXINGDAN_TYPE_INVALID = 0,
	SHUXINGDAN_TYPE_XIANNV = 1,						--精灵
	SHUXINGDAN_TYPE_MOUNT = 2,						--坐骑
	SHUXINGDAN_TYPE_XIULIAN = 3,					--修炼
	SHUXINGDAN_TYPE_WING = 4,						--羽翼
	SHUXINGDAN_TYPE_CHANGJIU = 5,					--成就
	SHUXINGDAN_TYPE_SHENGWANG = 6,					--声望

	SHUXINGDAN_TYPE_MAX = 6,
}
--进阶类型屏蔽
ADVANCE_HIDE_TYPE = {
	WING = 1,							--羽翼
	FABAO = 2,							--法宝
	FOOT = 3,							--足迹
	HALO = 4,							--光环
	CLOAK = 5,							--披风
	TOUSHI = 6,							--头饰
	MASK = 7,							--面饰
	WAIST = 8,							--腰饰
	QILINBI = 9,						--麒麟臂
	SHOUHUAN = 10,						--手环
	TAIL = 11,							--尾巴
	FLYPET = 12,						--飞宠
}

TUHAOJIN_REQ_TYPE = {
	TUHAOJIN_MAX_JINGHUA_COUNT = 7,							-- 土豪金精华最大数量
	TUHAOJIN_MAX_LEVEL = 50,								-- 土豪金最大等级
}

RA_CHONGZHI_MIJINGXUNBAO_CHOU_TYPE = {
		RA_CHONGZHI_MIJINGXUNBAO_CHOU_TYPE_1 = 0,			--淘宝一次
		RA_CHONGZHI_MIJINGXUNBAO_CHOU_TYPE_10 = 1,			--淘宝十次
		RA_CHONGZHI_MIJINGXUNBAO_CHOU_TYPE_50 = 2,			--淘宝五十次
		RA_CHONGZHI_MIJINGXUNBAO_CHOU_TYPE_MAX = 3,
}

RA_CHONGZHI_MIJINGXUNBAO_OPERA_TYPE = {
	RA_MIJINGXUNBAO_OPERA_TYPE_QUERY_INFO = 0,				-- 请求活动信息
	RA_MIJINGXUNBAO_OPERA_TYPE_TAO = 1,						-- 淘宝
	RA_MIJINGXUNBAO_OPERA_TYPE_MAX = 2,
}

SHENZHOU_WEAPON_REQ_TYPE = {
	SHENZHOU_WEAPON_REQ_TYPE_UPGRADE_WEAPON = 0,			-- 提升神器等级
	SHENZHOU_WEAPON_REQ_TYPE_UPGRADE_IDENTIFY = 1,			-- 提升鉴定等级
	SHENZHOU_WEAPON_REQ_TYPE_INDENTIFY = 2,					-- 鉴定物品 param1 背包物品下标
	SHENZHOU_WEAPON_REQ_TYPE_TAKE_OUT = 3,					-- 取出物品到背包 param1 背包物品下标
	SHENZHOU_WEAPON_REQ_TYPE_RECYCLE = 4,					-- 垃圾熔炼 param1 背包物品下标
	SHENZHOU_WEAPON_REQ_TYPE_ONE_KEY_RECYCLE = 5,			-- 一键垃圾熔炼
	SHENZHOU_WEAPON_REQ_TYPE_EXCHANGE_IDENTIFY_EXP = 6,		-- 兑换鉴定经验
}

-- 礼物收割
RA_GIFT_HARVEST_OPERA_TYPE = {
	RA_GIFT_HARVEST_OPERA_TYPE_INFO = 0,	-- 请求个人信息
	RA_GIFT_HARVEST_OPERA_TYPE_RANK_INFO = 1,	-- 请求个人信息
	RA_GIFT_HARVEST_OPERA_TYPE_ENTER_SCENE = 2,	-- 请求进入
	RA_GIFT_HARVEST_OPERA_TYPE_ACT_TIME = 3,	-- 请求轮次是否开启
}

XUNBAO_TYPE = {
	JINGLING_TYPE = 2      									-- 精灵类型寻宝展示
}

-- 活跃度类型
ACTIVEDEGREE_TYPE = {
	ADD_EXP = 0,									-- 帮派捐献
	SHENSHOU = 1,									-- 帮派神兽
	--MOUNT_UPGRADE = 2,							-- 坐骑进阶

	CHALLENGE_FB = 2,								-- 挑战副本
	EQUIP_FB = 3,									-- 装备副本
	EXP_FB = 4,										-- 经验副本
	TEAM_TOWERDEFEND = 5,							-- 塔防
	PHASE_FB = 6,									-- 阶段副本

	QUNXIANLUANDOU = 7,								-- 三界战场
	XIANMENGZHAN = 8,								-- 仙盟战
	GONGCHENGZHAN = 9,								-- 攻城战
	PVP = 10,										-- 排名竞技场
	ZHUXIE = 11,									-- 诛邪战场
	NATIONAL_BOSS = 12,								-- 全服Boss

	HUSONG_TASK = 13,								-- 运镖
	QUESTION = 14,									-- 答题
	TUMO_TASK = 15,									-- 日常任务
	GUILD_TASK = 16,								-- 仙盟任务

	ACTIVEDEGREE_TYPE_NUM = 17,
}

-- 活动类型
ACTIVITY_TYPE = {
	INVALID = -1,									-- 无效类型
	ZHUXIE = 1,										-- 攻城准备战
	QUESTION = 2,									-- 答题活动（旧版）
	HUSONG = 3,										-- 护送活动
	MONSTER_INVADE = 4,								-- 怪物入侵
	QUNXIANLUANDOU = 5,								-- 三界战场
	GONGCHENGZHAN = 6,								-- 攻城战
	XIANMENGZHAN = 7,								-- 仙盟战
	NATIONAL_BOSS = 8,								-- 神兽禁地(全民boss)
	CHAOSWAR = 9,							 		-- 一战到底
	MOSHEN = 10,							 		-- 魔神降临
	CAMPTASK = 11,							 		-- 阵营刺杀
	LUCKYGUAJI = 12,							 	-- 幸运挂机
	WUXINGGUAJI = 13,							 	-- 五行挂机
	SHUIJING = 14,									-- 水晶幻境
	HUANGCHENGHUIZHAN = 15,							-- 皇城会战
	CAMP_DEFEND1 = 16,								-- 守卫雕像1
	CAMP_DEFEND2 = 17,								-- 守卫雕像2
	CAMP_DEFEND3 = 18,								-- 守卫雕像3
	CLASH_TERRITORY = 19,							-- 领土战
	TIANJIANGCAIBAO = 20,							-- 天降财宝
	GUILDBATTLE = 21,								-- 公会争霸
	HAPPYTREE_GROW_EXCHANGE = 22,					-- 欢乐果树成长值兑换
	NIGHT_FIGHT_FB = 23,							-- 非跨服夜战王城
	GUILD_BOSS = 24,								-- 公会Boss
	BIG_RICH = 25,									-- 大富豪
	TOMB_EXPLORE = 26,								-- 皇陵探险
	GUILD_BONFIRE = 27,								-- 仙盟运镖
	ACTIVITY_TYPE_XINGZUOYIJI = 28,					-- 星座遗迹
	WEDDING = 29,									-- 婚宴
	GUILD_ANSWER = 30,								-- 仙盟答题
	LUANDOUBATTLE = 31,								-- 乱斗战场
	GONGCHENG_WORSHIP = 32, 						-- 膜拜城主
	GUILD_MONEYTREE = 33,							-- 仙盟摇钱树
	GUILD_SHILIAN = 34,								-- 仙盟试炼


	-- 客户端定义的活动类型
	PAIMINGJINGJICHANG = 101,						-- 排名竞技场(1V1)
	MarryFB = 100,									-- 情缘副本
	XIANMENGRENWU = 102,							-- 仙盟任务
	XIANMENGSHENSHOU = 103,							-- 仙盟神兽
	MIGONGXUNBAO = 104,								-- 迷宫寻宝
	TEAMFB = 105,									-- 多人副本
	WABAO = 106,									-- 挖宝(仙女掠夺)
	Alchemy = 108, 									-- 炼丹
	GuaJi = 109,									-- 挂机
	MANYTOWER = 110,								-- 多人塔防
	XIONGSHOU = 112,
	ZHUAGUI = 113,									-- 秘境降魔

	--充值活动类型
	OPEN_SERVER = 1025,								-- 开服活动
	CLOSE_BETA = 1026,								-- 封测活动
	BANBEN_ACTIVITY = 1027,							-- 版本活动
	COMBINE_SERVER = 1028,							-- 合服活动
	Act_Roller = 2048,								-- 随机活动转盘

	--随机活动
	RAND_ACT = 2000,								--客户端用于泛指随机活动类型
	RAND_DAY_CHONGZHI_FANLI = 2049,					-- 单日充值返利
	RAND_DAY_CONSUME_GOLD = 2050,					-- 单日消费
	RAND_TOTAL_CONSUME_GOLD = 2051,					-- 累计消费
	RAND_DAY_ACTIVIE_DEGREE = 2052,					-- 单日活跃奖励
	RAND_CHONGZHI_RANK = 2053,						-- 充值豪礼
	RAND_ZHIZUN_CHONGZHI_RANK = 2256,						-- 至尊充值
	RAND_CONSUME_GOLD_RANK = 2054,					-- 消费返利
	RAND_SERVER_PANIC_BUY = 2055,					-- 全服疯狂抢购
	RAND_PERSONAL_PANIC_BUY = 2056,					-- 个人疯狂抢购
	RAND_CONSUME_GOLD_FANLI = 2057,					-- 消费返利
	RAND_EQUIP_STRENGTHEN = 2058,					-- 装备强化
	RAND_CHESTSHOP = 2059,							-- 奇珍异宝
	RAND_STONE_UPLEVEL = 2060,						-- 宝石升级
	RAND_XN_CHANMIAN_UPLEVEL = 2061,				-- 仙女缠绵
	RAND_MOUNT_UPGRADE = 2062,						-- 坐骑进阶
	RAND_QIBING_UPGRADE = 2063,						-- 骑兵升级
	RAND_MENTALITY_TOTAL_LEVEL = 2064,				-- 根骨全身等级
	RAND_WING_UPGRADE = 2065,						-- 羽翼进化
	RAND_QUANMIN_QIFU = 2066,						-- 全民祈福
	RAND_SHOUYOU_YUXIANG = 2067,					-- 手有余香
	RAND_XIANMENG_JUEQI = 2068,						-- 仙盟崛起
	RAND_XIANMENG_BIPIN = 2069,						-- 仙盟比拼
	RAND_DAY_ONLINE_GIFT = 2070,					-- 每日在线好礼
	RAND_KILL_BOSS = 2071,							-- BOSS击杀
	RAND_DOUFA_KUANGHUAN = 2072,					-- 斗法狂欢
	RAND_ZHANCHANG_FANBEI = 2073,					-- 战场翻倍
	RAND_LOGIN_GIFT = 2074,							-- 登录奖励
	RAND_HAPPY_RECHARGE = 2096,						-- 充值大乐透(充值乐翻天)
	XIAN_SHI_LIAN_CHONG = 2237,						-- 限时连充
	RAND_ACTIVITY_TYPE_DALEGOU = 2247,				-- 狂欢大乐购

	RAND_ACTIVITY_TYPE_BP_CAPABILITY_WING = 2080,		-- 比拼羽翼战力
	RAND_ACTIVITY_TYPE_BP_CAPABILITY_MOUNT = 2079,		-- 比拼坐骑战力
	RAND_ACTIVITY_TYPE_BP_CAPABILITY_JINGLING = 2098,	-- 比拼精灵战力
	RAND_ACTIVITY_TYPE_BP_CAPABILITY_EQUIPSHEN = 2097,	-- 比拼神装战力
	RAND_ACTIVITY_TYPE_BP_CAPABILITY_EQUIP = 2076,		-- 比拼装备战力
	RAND_ACTIVITY_TYPE_BP_CAPABILITY_JINGLIAN = 2099,	-- 比拼精炼战力
	RAND_ACTIVITY_TYPE_BP_CAPABILITY_TOTAL = 2075,		-- 比拼综合战力
	RAND_CHARGE_REPALMENT = 2081,					-- 充值回馈
	RAND_SINGLE_CHARGE = 2082,						-- 单笔充值
	RAND_ACTIVITY_TYPE_CORNUCOPIA = 2083,			-- 聚宝盆
	RAND_CHONGZHI_DOUBLE = 2084,					-- 双倍充值
	RAND_DAY_DANBI_CHONGZHI = 2085, 				-- 单笔充值
	RAND_TOTAL_CHARGE_DAY = 2086,					-- 随机活动每日累充
	RAND_TOMORROW_REWARD = 2087,					-- 次日福利活动
	RAND_SEVEN_DOUBLE = 2088,						-- 七日双倍活动
	RAND_DAILY_CHONGZHI_RANK = 2089,				-- 每日充值排行
	RAND_DAILY_CONSUME_RANK = 2090,					-- 每日消费排行
	RAND_TOTAL_CHONGZHI = 2091,						-- 活动累计充值
	RAND_DOUBLE_XUNBAO_JIFEN = 2092,				-- 双倍寻宝积分
	RAND_EQUIP_EXCHANGE = 2093,						-- 装备积分兑换
	RAND_SPRITE_EXCHANGE = 2094,					-- 精灵积分兑换
	RAND_JINYINTA = 2095,							-- 金银塔 (六道仙塔)
	RAND_NIUEGG = 2096,								--充值扭蛋
	RAND_ACTIVITY_TREASURE_LOFT = 2100, 			-- 珍宝阁
	RAND_ACTIVITY_MIJINGXUNBAO = 2101,              -- 秘境淘宝
	-- RAND_ACTIVITY_TYPE_SINGLE_CHARGE_2 = 2102, 		-- 极速冲战
	RAND_LOTTERY_TREE = 2103,						-- 摇钱树(神帝转盘)
	RAND_DAILY_LOVE = 2104,							-- 每日一爱活动
	RAND_SINGLE_DAY_CHARGE = 2137,					-- 单日累充
	RAND_ACTIVITY_FANFANZHUAN = 2105,				-- 翻翻转
	RAND_ACTIVITY_SANJIANTAO = 2106, 				-- 三件套
	RAND_ACTIVITY_BEIZHENGDAREN = 2107,				-- 被整达人
	RAND_ACTIVITY_ZHENGGUZJ = 2108,					-- 整蛊专家
	RAND_ACTIVITY_ZONGYE = 2109,					-- 粽叶飘香
	RAND_ACTIVITY_NEW_THREE_SUIT = 2110,			-- 奇珍三重奏
	RAND_ACTIVITY_MINE = 2111,						-- 开心矿场(黄金猎场)
	RAND_ACTIVITY_DINGGUAGUA = 2112,				-- 刮刮乐
	RAND_ACTIVITY_LUCKYDRAW = 2113,				    -- 神隐占卜屋
	RAND_ACTIVITY_TYPE_FANFAN = 2114,				-- 翻翻转活动 (寻字好礼，w3为翻翻乐 )
	RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI = 2115,	-- 连充特惠
	RAND_ACTIVITY_TYPE_CONTINUE_CONSUME = 2116,		-- 连续消费
	RAND_ACTIVITY_QIXI = 2118,						-- 七夕情缘
	RAND_ACTIVITY_TYPE_REPEAT_RECHARGE = 2119,		 -- 循环充值
	RAND_ACTIVITY_SUPER_LUCKY_STAR = 2120,			-- 至尊幸运星
	RAND_ACTIVITY_LINGXUBAOZANG= 2121,				-- 灵虚宝藏
	RAND_ACTIVITY_BLESS_WATER = 2122,				-- 天泉祈福
	RAND_ACTIVITY_NATIONALDAY = 2123,				-- 国庆活动
	RAND_ACTIVITY_TREASURE_BUSINESSMAN = 2124,		-- 至尊豪礼
	RAND_ACTIVITY_TYPE_DAY_DAY_UP = 2125,			-- 步步高升
	RAND_ACTIVITY_TYPE_BLACKMARKET_AUCTION = 2126,	-- 黑市拍卖
	RAND_ACTIVITY_TYPE_TREASURE_MALL = 2127, 		-- 珍宝商城
	RAND_CORNUCOPIA = 2167,							-- 聚宝盆
	RAND_ACTIVITY_TYPE_GOLDEN_PIG =	2173,			-- 金猪召唤(龙神夺宝)
	RAND_ACTIVITY_TYPE_ITEM_COLLECTION = 2168,		-- 集字活动   （统一的那个活动协议）
	MARRY_ME = 2169,		-- 我们结婚吧
	RAND_ACTIVITY_TYPE_HONG_BAO = 2170,				-- 开服红包(红包好礼)
	RAND_ACTIVITY_TYPE_EXP_REFINE = 2172,			-- 经验炼制
	RAND_ACTIVITY_TYPE_SINGLE_CHONGZHI = 2178,		-- 单返豪

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
	RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU = 2174,		-- 连充特惠初(开服活动)
	RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO = 2175,		-- 连充特惠高(开服活动)
	RAND_ACTIVITY_TYPE_KAIFU_INVEST = 2176,					-- 开服投资
	RAND_ACTIVITY_TYPE_XIANYUAN_TREAS = 2179, 				-- 聚划算
	RAND_ACTIVITY_TYPE_SINGLE_CHARGE_2 = 2181,				-- 极速冲战
	RAND_ACTIVITY_TYPE_SINGLE_GIFT = 2182,					--单充好礼
	RAND_ACTIVITY_TYPE_SINGLE_CHARGE_3 = 2183,				-- 冲战高手
	RAND_ACTIVITY_TYPE_RUSH_BUYING = 2180, 					-- 限时拍卖
	RAND_ACTIVITY_TYPE_RECHARGE_CAPACITY = 2184,			-- 冲战先锋
	RAND_ACTIVITY_TYPE_MAP_HUNT = 2185,						-- 地图寻宝
	-- RAND_ACTIVITY_TYPE_LIGHT_TOWER_EXPLORE = 2186,		-- 极品宝塔
	RAND_ACTIVITY_TYPE_MAGIC_SHOP = 2188,					-- 幻装商店

	RAND_ACTIVITY_TYPE_FISHING = 2190,						-- 钓鱼
	RAND_ACTIVITY_TYPE_CRYSTAL_DALARAN = 2191,				-- 达拉然水晶
	RAND_ACTIVITY_TYPE_CHONGZHI_CRAZY_REBATE = 2192,		-- 狂返元宝
	RAND_ACTIVITY_TYPE_SAN_SHENG_SAN_SHI = 2193,			-- 三生三世
	RAND_ACTIVITY_TYPE_EXPENSE_GIFT = 2194,					-- 消费好礼
	RAND_ACTIVITY_RMB_BUY_COUNT_SHOP = 2209,				-- 奇珍商城（神秘商店）
	RAND_ACTIVITY_TYPE_LIMITTIME_REBATE = 2203,				-- 限时大回馈
	RAND_ACTIVITY_TYPE_TIME_LIMIT_GIFT = 2204, 				-- 限时礼包
	RAND_ACTIVITY_TYPE_CONSUME_GOLD_FANLI = 2210, 			-- 消费返礼
	RAND_ACTIVITY_TYPE_HUANLE_YAOJIANG2 = 2214,             -- 中秋祈福
	RAND_ACTIVITY_TYPE_QUAN_MIN_JIN_JIE = 2200,				-- 全民进阶
	RAND_ACTIVITY_TYPE_QUAN_MIN_UPGRADE_GROUPE = 2201,		-- 全民总动员(全服人的主题阶达到指定阶数)
	RAND_ACTIVITY_TYPE_GUILD_FIGHT = 2202,					-- 开服帮派争霸

	RAND_ACTIVITY_TYPE_LOOP_CHARGE_2 = 2205,				-- 循环充值2(送装备)
	RAND_ACTIVITY_TYPE_SHAKE_MONEY = 2206,					-- 疯狂摇钱树
	RAND_ACTIVITY_TYPE_TIME_LIMIT_BIG_GIFT = 2207, 			-- 限时豪礼
	RAND_ACTIVITY_REST_DOUBLE_CHONGZHI = 2208,				-- 普天同庆
	RAND_ACTIVITY_TYPE_MAKE_MOONCAKE = 2211,                --集月饼活动(单身伴侣)
	RAND_ACTIVEIY_TYPE_LIANXUCHONGZHI = 2212,				-- 连续充值
	RAND_ACTIVITY_TYPE_VERSIONS_CONTINUE_CHARGE = 2212,		-- 循环充值
	RAND_ACTIVITY_TYPE_VERSIONS_GRAND_TOTAL_CHARGE = 2213,	-- 版本累计充值
	RAND_ACTIVITY_TYPE_BUYONE_GETONE = 2219,				-- 买一送一
	RAND_ACTIVITY_TYPE_CONSUME_FOR_GIFT = 2220,				-- 消费有礼
	RAND_ACTIVITY_TYPE_HUANLE_ZADAN = 2222,					-- 欢乐砸蛋
	RAND_ACTIVITY_FLAG = 2117,								-- 军歌嘹亮
	RAND_ACTIVITY_TYPE_LOGIN_GIFT = 2217, 					-- 登陆豪礼
	RAND_ACTIVITY_TYPE_EVERYDAY_NICE_GIFT = 2218,			-- 每日好礼
	RAND_ACTIVITY_TYPE_MIJINGXUNBAO3 = 2221,                -- 秘境寻宝3
	RAND_ACTIVITY_TYPE_HAPPYERNIE = 2223, 					-- 欢乐摇奖
	RAND_ACTIVITY_TYPE_HOLIDAY_GUARD = 2225,  				-- 节日守护(吃鸡盛宴)
	RAND_ACTIVITY_TYPE_NICHONGWOSONG = 2227,				-- 你充我送
	RAND_ACTIVITY_TYPE_GROUP_PURCHASE = 2231,				-- 组合团购
	RAND_ACTIVITY_TYPE_LUCKY_WISH = 2232,					-- 幸运许愿
	RAND_ACTIVITY_TYPE_BiPin_ACTIVITY = 2233, 				-- 随机活动比拼
	RAND_ACTIVITY_TYPE_SUPPER_GIFT2 = 2241,					-- 限购礼包

	RAND_ACTIVITY_TYPE_PRINT_TREE = 2189,					-- (吹气球)排行榜
	RAND_ACTIVITY_TYPE_PROFESS_RANK = 2228,					-- 表白排行榜
	RAND_ACTIVITY_TYPE_FANGFEI_QIQIU = 2289,				-- (放飞气球)排行榜 (客户端自己定的活动ID)

	RAND_ACTIVITY_TYPE_DISCOUNT_BUY_HOME = 2234,			-- 折扣买房(夫妻家园)
	RAND_ACTIVITY_TYPE_DISCOUNT_BUY_FURNITURE = 2235,		-- 买一送一(夫妻家园)

	RAND_ACTIVITY_TYPE_MARRIAGEHALOBUY = 2236,				-- 随机活动夫妻光环特购
	RAND_ACTIVITY_TYPE_WEST_WEDDING = 2238,                	-- 欧式婚礼半价
	RAND_ACTIVITY_TYPE_WEEKENDHAPPY = 2239,					-- 周末狂欢
	RAND_ACTIVITY_TYPE_BABYHALDOFF = 2240,					-- 五折抱娃
	RAND_ACTIVITY_TYPE_ONEYUANBUYVIEW = 2242,				-- 零元购
	RAND_ACTIVITY_TYPE_SINGLE_REBATE = 2243,				-- 单笔返利
	RAND_ACTIVITY_TYPE_KUANG_HAI_QING_DIAN = 2244,          -- 狂嗨庆典
	RAND_ACTIVITY_TYPE_LIWUSHOUGE = 2245,                 	-- 礼物收割
	RAND_ACTIVITY_TYPE_LUCKY_SHOPPING = 2246,				-- 幸运云购
	RAND_ACTIVITY_TYPE_IMMORTAL_FOREVER = 2248,				-- 仙尊永久激活
	RAND_ACTIVITY_TYPE_DANBICHONGZHIONE = 2249,				-- 单笔充值1
	RAND_ACTIVITY_TYPE_DANBICHONGZHITWO = 2250,				-- 单笔充值2
	RAND_ACTIVITY_TYPE_DANBICHONGZHITHREE = 2251,			-- 单笔充值3
	RAND_ACTIVITY_TYPE_LEIJICHONGZHIONE = 2252,				-- 累计充值1
	RAND_ACTIVITY_TYPE_LEIJICHONGZHITWO = 2253,				-- 累计充值2
	RAND_ACTIVITY_TYPE_LEIJICHONGZHITHREE = 2254,			-- 累计充值3
	RAND_ACTIVITY_TYPE_DOUBLE_GOLD = 2255, 					-- 双倍元宝

	KF_XIULUO_TOWER = 3073, 						-- 跨服修罗塔
	KF_ONEVONE = 3074, 								-- 跨服1V1
	KF_PVP = 3075, 									-- 跨服3V3
	KF_COMMON_BOSS = 3088,						-- 跨服VIPBoss
	-- KF_TUANZHAN = 3076,									-- 跨服神魔战
	KF_FARMHUNTING = 3077,									-- 牧场
	KF_BOSS = 3078,											-- 跨服boss
	KF_FB = 3079,											-- 跨服副本
	KF_HOT_SPRING = 3080,									-- 跨服温泉
	-- CROSS_SHUIJING = 3080,									-- 跨服水晶
	KF_GUILDBATTLE = 3082,									-- 跨服六界
	KF_MONTH_BLACK_WIND_HIGHT = 3083,						-- 跨服月黑风高
	CROSS_ACTIVITY_TYPE_FISHING = 3084, 					-- 跨服钓鱼
	KF_TUANZHAN = 3085,										-- 夜战王城 CROSS_ACTIVITY_TYPE_NIGHT_FIGHT_FB
	KF_LUANDOUBATTLE = 3086,								-- 跨服乱斗战场
	CROSS_ACTIVITY_TYPE_LIEKUN_FB = 3087,					-- 跨服灵鲲之战
	CROSS_ACTIVITY_TYPE_CROSS_MIZANG_BOSS = 3089,			-- 跨服秘藏Boss
	CROSS_ACTIVITY_TYPE_CROSS_YOUMING_BOSS = 3090,			-- 跨服幽冥Boss
	CROSS_ACTIVITY_TYPE_LIUJIE_BOSS = 3091,					-- 六界BOSS
	CROSS_ACTIVITY_TYPE_BIANJING_ZHIDI = 3092,				-- 边境之地
	CROSS_ACTIVITY_TYPE_CROSS_CHALLENGEFIELD = 3093,		-- 跨服论剑
	JINGHUA_HUSONG = 3094, 									-- 跨服水晶护送
	RAND_ACTIVITY_TYPE_EXTREME_CHALLENGE = 2216, 			-- 极限挑战
	RAND_ACTIVITY_TYPE_JUBAOPEN = 2196,						-- 聚宝盆

	KF_ONEYUANSNATCH = 4001,								-- 跨服一元夺宝
	KF_KUAFUCONSUME = 4002,									-- 跨服消费排行榜

	--手动添加活动
	HUN_YAN = 10001, 								-- 婚宴
	SUOYAOTA = 10002,								-- 锁妖塔
	YAOSHOUPLAZA = 10003,							-- 妖兽广场
	ACTIVITY_HALL = 10006,
	IMMORTAL = 10012,								-- 仙尊卡

	REWARD_SOURCE_ID_CROSS_ADD_CAP = 10000,					--跨服增战榜
	REWARD_SOURCE_ID_CROSS_ADD_CHARM = 10001,				--跨服增魅榜
	REWARD_SOURCE_ID_CROSS_QINGYUAN_CAP = 10002,			--跨服情缘榜
	REWARD_SOURCE_ID_CROSS_GUILD_KILL_BOSSP = 10003,		--跨服公会击杀榜
	REWARD_SOURCE_ID_CHALLENGEFIELD = 10004,				--开服竞技场


	FUNC_TYPE_LONGXING = 100001,							-- 活动卷轴中的功能 龙行天下
	EVERYDAY_BACK_GOLD = 100002,							-- 活动卷轴 天天返利
	FUNC_TYPE_CLOTHE = 100003,								-- 活动卷轴 衣橱

	KF_GUILDBATTLE_READYACTIVITY = 11000,					-- 跨服6界准备活动
}

--一个活动号对应两个活动
ONE_ID_DOUBLE_ACTIVITY = {
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PRINT_TREE] = 2289,
}

RA_PLANTING_TREE_RANK_TYPE = {
	PERSON_RANK_TYPE_PLANTING_TREE_PLANTING = 58, -- 吹气球/虐狗排行榜
	PERSON_RANK_TYPE_PLANTING_TREE_WATERING = 59, -- 放飞气球/单身狗排行榜
}

-- 跨服排行榜类型
CROSS_PERSON_RANK_TYPE = {
  CROSS_PERSON_RANK_TYPE_CAPABILITY_ALL = 0,				-- 跨服战力榜
  CROSS_PERSON_RANK_TYPE_WEEK_ADD_CHARM = 1,				-- 跨服魅力榜
  CROSS_PERSON_RANK_TYPE_XIULUO_TOWER = 2,					-- 跨服修罗塔
  CROSS_PERSON_RANK_TYPE_1V1_SCORE = 3,						-- 跨服1v1积分排行榜

  CROSS_PERSON_RANK_TYPE_3V3_SCORE = 4 ,					-- 跨服3v3积分排行榜
  CROSS_PERSON_RANK_TYPE_ROLE_LEVEL = 5,					-- 跨服等级排行榜
  CROSS_PERSON_RANK_TYPE_ADD_CAPABILITY = 6,				-- 跨服增加战力榜
  CROSS_PERSON_RANK_TYPE_ADD_CHARM = 7,						-- 跨服增加魅力榜
  CROSS_PERSON_RANK_TYPE_GUILD_KILL_BOSS = 8,				-- 跨服公会击杀榜
  CROSS_PERSON_RANK_TYPE_COUPLE_RANK = 1000,				-- 跨服情侣榜
  CROSS_PERSON_RANK_TYPE_MAX,                  
}

CROSS_COUPLE_RANK_TYPE = {
  CROSS_COUPLE_RANK_TYPE_QINGYUAN_CAP = 0,					-- 跨服情缘榜
  CROSS_COUPLE_RANK_TYPE_MAX
}

MAIL_TYPE = {
	MAIL_TYPE_PERSONAL = 1,			-- 私人邮件
	MAIL_TYPE_SYSTEM = 2,			-- 系统邮件
	MAIL_TYPE_GUILD = 3,			-- 公会邮件
	MAIL_TYPE_CHONGZHI = 4,			-- 官方邮件
}

RA_ZHENBAOGE_OPERA_TYPE = {
	RA_ZHENBAOGE_OPERA_TYPE_QUERY_INFO = 0,					-- 请求活动信息
	RA_ZHENBAOGE_OPERA_TYPE_BUY = 1,						-- 单个购买请求
	RA_ZHENBAOGE_OPEAR_TYPE_BUY_ALL = 2,					-- 全部购买请求
	RA_ZHENBAOGE_OPEAR_TYPE_FLUSH = 3,						-- 刷新请求
	RA_ZHENBAOGE_OPEAR_TYPE_RARE_FLUSH = 4,					-- 稀有刷新请求
	RA_ZHENBAOGE_OPERA_TYPE_FETCH_SERVER_GIFT = 5,			-- 领取全服礼包
	RA_ZHENBAOGE_OPERA_TYPE_MAX = 6,
}

RA_KING_DRAW_OPERA_TYPE = {
	RA_KING_DRAW_OPERA_TYPE_QUERY_INFO = 0,				-- 请求活动的信息
	RA_KING_DRAW_OPERA_TYPE_PLAY_ONCE = 1,				-- 只玩一次请求，发level和翻牌下标
	RA_KING_DRAW_OPERA_TYPE_PLAY_TIMES = 2,				-- 玩多次请求，发level和翻牌次数
	RA_KING_DRAW_OPERA_TYPE_REFRESH_CARD = 3,			-- 请求重置
	RA_KING_DRAW_OPERA_TYPE_FETCH_REWARD = 4,			-- 领取奖励
	RA_KING_DRAW_OPERA_TYPE_MAX = 5,
}


SIGN_GET_REWARD_STATUS = {
	ONE_SIGN = 1,			--领取签到一天奖励
	TOTAL_SIGN = 2, 		--领取累计签到奖励
}

NEQ_CARD_STATUS =  -- 卡牌状态
{
	DEFAULT = 1, 			--初始
	PREVIEW = 2, 			--预览
	SHUFFLE = 3, 			--洗牌
	COMPLETE_SHUFFLE = 4, 	--完成洗牌
	OPEN_ING = 5, 			--开启中
	OPEN = 6, 				--已开启
}

FU_BEN_TYPE = {
	FB_XIANNV = 1,									--仙女本
	FB_COIN = 2,									--铜币本
	FB_WING = 3,									--羽翼本
	FB_XIULIAN = 4,									--修练本
	FB_QIBING = 5,									--骑兵本
}

-- 活动状态
ACTIVITY_STATUS = {
	CLOSE = 0,										-- 活动关闭状态
	STANDY = 1,										-- 活动准备状态
	OPEN = 2,										-- 活动进行中
}

HUNYAN_STATUS = {
	CLOSE = 0,
	STANDY = 1,										-- 活动准备状态
	OPEN = 2,										-- 活动进行中
	XUNYOU = 3,										-- 巡游
}
ACTIVITY_ROOM_STATUS = {
	CLOSE = 0,										-- 活动房间关闭
	OPEN = 1,										-- 活动房间开启
}

CHAT_TYPE = {
	CHANNEL = 1,									-- 频道聊天
	PRIVATE = 2,									-- 私聊
	GUILD = 3,										-- 帮会聊天
}

-- 提示事件类型
TIPSEVENTTYPES = {
	SPECIAL = 0,
	COMMON = 1,
	OTHER = 2,
}

CHAT_CONTENT_TYPE = {
	TEXT = 0,										-- 文本
	AUDIO = 1,										-- 语音
	FEES_AUDIO = 2,									-- 收费语音
}

BIAOCHE_OPERA_TYPE = {
	BIAOCHE_OPERA_TYPE_START = 0, 					-- 开始护送
	BIAOCHE_OPERA_TYPE_TRANS = 1, 					-- 传送到镖车
	BIAOCHE_OPERA_TYPE_BIAOCHE_POS = 2,				-- 镖车当时位置
}

UILD_YUNBIAO_RESULT_TYPE = {
	GUILD_YUNBIAO_RESULT_TYPE_FAIL = 0,				-- 运镖失败
	GUILD_YUNBIAO_RESULT_TYPE_SUCC = 1,				-- 运镖成功
	GUILD_YUNBIAO_RESULT_TYPE_ROB_SUCC = 2,			-- 运镖抢劫成功
}

SYS_MSG_TYPE = {
	SYS_MSG_ONLY_CHAT_WORLD = 0,					-- 只添加到聊天世界频道(C)
	SYS_MSG_ONLY_CHAT_GUILD = 1,	 				-- 只添加到聊天仙盟频道系统
	SYS_MSG_CENTER_AND_ROLL = 2,					-- 屏幕中央, 滚动播放
	SYS_MSG_CENTER_NOTICE = 3,						-- 屏幕中央, 弹出播放
	SYS_MSG_ACTIVE_NOTICE = 4, 						-- 活动公告，只在活动场景弹出播放
	SYS_MSG_CENTER_PERSONAL_NOTICE = 5, 			-- 屏幕中央, 个人信息弹出播放
	SYS_MSG_ONLY_WORLD_QUESTION = 6,				-- 只添加到世界答题
	SYS_MSG_ONLY_GUILD_QUESTION = 7,				-- 只添加到公会答题
	SYS_MSG_CENTER_NOTICE_2 = 8, 					-- 添加到系统频道+屏幕中央弹出
	SYS_MSG_EVENT_TYPE_COMMON_NOTICE = 9,			-- 系统普通事件提醒
	SYS_MSG_EVENT_TYPE_SPECIAL_NOTICE = 10,			-- 系统特殊事件提醒(中间战场传闻，不可叠加)
	SYS_MSG_CHAT_GUILD_PERSONAL = 11,				-- 添加到聊天仙盟频道个人
	SYS_MSG_CENTER_NOTICE_NOT_CHAT = 12,			-- 屏幕中央, 弹出播放，不添加到聊天频道
	SYS_MSG_ACTIVITY_SPECIAL  = 13,					-- 战场播报传闻，专用框弹出（右下方弹出）
	SYS_MSG_CENTER_ROLL_2 = 14,						-- 屏幕中央, 滚动播放(A类传闻)
	SYS_MSG_CENTER_NOTICE_3 = 15,					-- 屏幕中央, 弹出播放(B类传闻)
}

ITEM_CHANGE_TYPE = {
	ITEM_CHANGE_TYPE_SNEAKY_IN = -4,				-- 偷偷的放入 不需要通知玩家获得 当脱下装备和宝石镶嵌惩罚时使用这个
	ITEM_CHANGE_TYPE_CHANGE = -3,	 				-- 发生改变
	ITEM_CHANGE_TYPE_OUT = -2,	 					-- 从背包进入外部
	ITEM_CHANGE_TYPE_IN = -1,	 					-- 从外部进入背包
	-- 0以上表示是从背包/仓库的其他格子里移动过来/去 值表示原来的下标
}

PRODUCT_ID_TRIGGER = {
	PRODUCT_ID_TRIGGER_SPECIAL_DICI = 1200,				-- 地刺
	PRODUCT_ID_TRIGGER_SPECIAL_BEILAO = 1201,			-- 焙烙
	PRODUCT_ID_TRIGGER_SPECIAL_BANMASUO = 1202,			-- 绊马索
	PRODUCT_ID_TRIGGER_SPECIAL_ICE_LANDMINE = 1203,		-- 冰霜地雷
	PRODUCT_ID_TRIGGER_SPECIAL_FIRE_LANDMINE = 1204,	-- 火焰地雷


	CLIENT_SHANDIANXIAN_LINE = 100001,					-- 闪电线
}

RED_PAPER_TYPE = {					--红包类型
	RED_PAPER_TYPE_INVALID = 0,
	RED_PAPER_TYPE_COMMON = 1, 		--普通
	RED_PAPER_TYPE_RAND = 2,		--拼手气
	RED_PAPER_TYPE_GLOBAL = 3,		--全服
	RED_PAPER_TYPE_GUILD = 4,		--公会
	RED_PAPER_TYPE_COMMAND_SPEAKER = 5,		--口令

	RED_PAPER_TYPE_MAX,
}
CHALLENGE_FB_OPERATE_TYPE = {
	CHALLENGE_FB_OPERATE_TYPE_AUTO_FB = 0,								-- 扫荡
	CHALLENGE_FB_OPERATE_TYPE_RESET_FB = 1,								-- 重置
	CHALLENGE_FB_OPERATE_TYPE_SEND_INFO_REQ = 2,						-- 请求发送协议
	CHALLENGE_FB_OPERATE_TYPE_BUY_TIMES = 3, 							-- 购买次数
}

TUITU_FB_OPERA_REQ_TYPE = {
	TUITU_FB_OPERA_REQ_TYPE_ALL_INFO = 0,					-- 请求信息
	TUITU_FB_OPERA_REQ_TYPE_BUY_TIMES = 1,					-- 购买进入副本次数 param_1 购买副本类型 param_2, 购买次数
	TUITU_FB_OPERA_REQ_TYPE_FETCH_STAR_REWARD = 2,			-- 拿取星级奖励 param_1:章节  param_2:配置表seq
	TUITU_FB_OPERA_REQ_TYPE_SAODANG = 3 ,					-- 扫荡 param_1:副本类型 param_2:章节 param_3:关卡
	TUITU_FB_OPERA_REQ_TYPE_MAX = 4,
}

RA_TOTAL_CHARGE_OPERA_TYPE    = {							-- 金银塔活动请求类型 (六道仙塔)
	RA_LEVEL_LOTTERY_OPERA_TYPE_QUERY_INFO          = 0,	-- 请求记录信息
	RA_LEVEL_LOTTERY_OPERA_TYPE_DO_LOTTERY          = 1,	-- 发起抽奖请求 param_1 次数
	RA_LEVEL_LOTTERY_OPERA_TYPE_FETCHE_TOTAL_REWARD = 2,	-- 领取累计抽奖次数奖励 param_1 次数
	RA_LEVEL_LOTTERY_OPERA_TYPE_ACTIVITY_INFO       = 3,	-- 请求活动信息
	RA_LEVEL_LOTTERY_OPERA_TYPE_MAX                 = 4,
}
CHARGE_OPERA = {
	CHOU_ONE = 1,
	CHOU_TEN = 10,
	CHOU_THIRTY = 30,
}


PUT_REASON_TYPE = {
	PUT_REASON_INVALID = 0,							-- 无效
	PUT_REASON_NO_NOTICE = 1,						-- 不通知
	PUT_REASON_GM = 2,								-- GM命令
	PUT_REASON_PICK = 3,							-- 捡取掉落
	PUT_REASON_GIFT = 4,							-- 礼包打开
	PUT_REASON_COMPOSE = 5,							-- 合成产生
	PUT_REASON_TASK_REWARD = 6,						-- 任务奖励
	PUT_REASON_MAIL_RECEIVE = 7,					-- 邮件
	PUT_REASON_CHEST_SHOP = 8,						-- 宝箱
	PUT_REASON_RANDOM_CAMP = 9,						-- 听天由命礼包
	PUT_REASON_SHOP_BUY = 10,						-- 商城购买
	PUT_REASON_WELFARE = 11,						-- 福利
	PUT_REASON_ACTIVE_DEGREE = 12,					-- 活跃度
	PUT_REASON_CONVERT_SHOP = 13,					-- 兑换商店
	PUT_REASON_ZHUXIE_ACTIVITY_REWARD = 14,			-- 诛邪战场奖励
	PUT_REASON_FB_TOWERDEFEND_TEAM = 15,			-- 多人塔防副本
	PUT_REASON_SEVEN_DAY_LOGIN_REWARD = 16,			-- 七天登录活动奖励
	PUT_REASON_YAOJIANG = 17,						-- 摇奖
	PUT_REASON_ACTIVITY_FIND = 18,					-- 活动找回
	PUT_REASON_NEQ_STAR_REWARD = 19,				-- 新装备本星星奖励
	PUT_REASON_NEQ_AUTO = 20,						-- 新装备本扫荡
	PUT_REASON_NEQ_ROLL = 21,						-- 新装备本翻牌
	PUT_REASON_MAZE = 22,							-- 迷宫寻宝
	PUT_REASON_EXP_FB = 23,							-- 经验副本
	PUT_REASON_CHALLENGE_FB = 24,					-- 挑战副本
	PUT_REASON_VIP_LEVEL_REWARD = 25,				-- VIP等级奖励
	PUT_REASON_QIFU_TIMES_REWARD = 26,				-- 祈福次数奖励
	PUT_REASON_GUILD_TASK_REWARD = 27,				-- 仙盟任务奖励
	PUT_REASON_CHONGZHI_ACTIVITY = 28,				-- 充值活动
	PUT_REASON_OPENGAME_ACTIVITY = 29,				-- 开服活动
	PUT_REASON_DISCOUNT_BUY = 30,					-- 一折抢购
	PUT_REASON_LUCKYROLL = 39,						-- 幸运转盘
	-- PUT_REASPN_PHASE_AUTO = 39,						-- 阶段本扫荡奖励

	PUT_REASON_LUCKYROLL_EXTRAL = 40,			 	-- 幸运转盘额外奖励
	PUT_REASON_LUCKYROLL_CS = 79,			 		-- 合服活动幸运转盘
	PUT_REASON_ZHUXIE_GATHER = 96,					-- 诛邪采集获得
	PUT_REASON_EXP_BOTTLE = 97,						-- 凝聚经验
	PUT_REASON_GCZ_DAILY_REWARD = 98,				-- 攻城战每日奖励
	PUT_REASON_LIFE_SKILL_MAKE= 99,					-- 生活技能制造
	PUT_REASON_PAOHUAN_ROLL = 100,					-- 跑环任务翻牌
	PUT_REASON_GUILD_STORE = 101,					-- 从公会仓库取出
	PUT_REASON_RA_LEVEL_LOTTERY = 105,				-- 金银塔活动奖励 (六道仙塔)
	PUT_REASON_ONLINE_REWARD = 139,					-- 在线奖励
	PUT_REASON_MOVE_CHESS = 150,					-- 走棋子奖励
	PUT_REASON_LITTLE_PET_CHOUJIANG_ONE = 162,		--小宠物抽奖1连
	PUT_REASON_LITTLE_PET_CHOUJIANG_TEN = 163,		--小宠物抽奖10连
	PUT_REASON_GUILD_BOX_REWARD = 186,				-- 开启公会宝箱奖励
	PUT_REASON_SZLQ_OPEN_BOX_REWARD = 191,			-- 魂器打开宝藏
	PUT_REASON_ZODIAC_GGL_REWARD = 193,				-- 星座摇奖机
	PUT_REASON_WABAO = 32,							-- 挖宝
	PUT_REASON_ZHIXIAN_TASK_REWARD = 198,			-- 支线任务
	PUT_REASON_GOLDEN_PIG_RANDOM_REWARD = 216,		-- 金猪召唤随机奖励
	PUT_REASON_RA_MONEY_TREE_REWARD= 111,			-- 转转乐随机奖励
	PUT_REASON_YUANBAO_ZHUANPAN = 205,				-- 转盘奖励
	PUT_REASON_MAP_HUNT_BAST_REWARD = 225,			-- 地图寻宝最终奖励
	PUT_REASON_MAP_HUNT_BASE_REWARD = 226,			-- 地图寻宝基础奖励
	PUT_REASON_SHENSHOU_HUANLING_REWARD = 234,  	-- 神兽唤灵抽奖
}
--固定的错误码，直接在收到错误码时处理，简单粗暴
FIX_ERROR_CODE =
{
	EN_GET_ACCOUNT_GOLD_TOO_FAST = 100000,			--从账号提取元宝间隔时间不足
	EN_COIN_NOT_ENOUGH = 100001,					--铜币不足
	EN_GOLD_NOT_ENOUGH = 100002,					--您元宝不足，请前往充值！
	EN_BIND_GOLD_NOT_ENOUGH = 100003,				--绑定元宝不足
	EN_MONEY_IS_LOCK = 100004,						--金钱已经锁定
	EN_ROLE_ZHENQI_NOT_ENOUGH = 100005,				--仙魂不足
	EN_XIANNV_EXP_DAN_LIMIT = 100006,				--仙女经验丹不足
	EN_CONVERTSHOP_BATTLE_FIELD_HONOR_LESS = 100007, --战场荣誉不足
	EN_SHENGWANG_SHENGWANG_NOT_ENOUGH = 100010, 		--竞技场声望不足
}

--传闻链接类型
CHAT_LINK_TYPE = {
	GUILD_APPLY = 0,								-- 申请加入 仙盟申请
	EQUIP_QIANG_HUA = 3,							-- 我要强化 装备强化
	MOUNTJINJIE = 4,								-- 我要进阶 坐骑进阶
	HUSONG = 5,										-- 我要护送
	EQUIP_UP_STAR =6,								-- 我要升星 装备升星
	GUILD_JUANXIAN =7,								-- 我要捐献
	EQUIP_FULING = 8,								-- 我要附灵 装备附灵
	MOUNT_LIEHUN = 9,								-- 我要猎魂 坐骑猎魂
	JINGLING_UPLEVEL = 10,							-- 我要升级 精灵升级
	ACHIEVE_UP = 11,								-- 我要提升 成就提升
	EQUIP_JICHENG = 12,								-- 我要继承 装备继承
	XIANJIE_UP = 13,								-- 我要提升 仙阶提升
	PaTa = 14,										-- 我要挑战 爬塔
	GENGU = 15,										-- 我要提升根骨
	JINGMAI = 16,									-- 我要提升经脉
	SPRITE_FLY = 17,								-- 我要精灵进阶
	EQUIP_UPLEVEL =18,								-- 我要进阶 装备进阶
	FORGE_EQUIP_UPLEVEL =19,						-- 我要升级 神铸装备升级
	ROLE_BAOSHI = 20,								-- 我要镶嵌 宝石镶嵌
	SHEN_GRADE = 21,								-- 我要神装进阶
	ROLE_WINGUP =22,								-- 我要进阶 羽翼进阶
	HALO_UPGRADE = 23,								-- 我要进阶 光环进阶
	SHENGONG_UPGRADE = 24,							-- 我要进阶 神弓进阶
	VIP =25,										-- 成为vip
	SHENYI_UPGRADE = 26,							-- 我要进阶 神翼进阶
	FIGHT_MOUNT_UPGRADE = 27,						-- 我要进阶 战斗坐骑进阶
	KF_BOSS = 28,									-- 立即前往 kfboss
	BONFRIE = 29,									-- 立即前往 篝火
	BOSS_WORLD = 30,								-- 前往击杀 世界boss
	BOSS_JINGYING = 31,								-- 前往击杀 精英boss
	XUNBAO = 32,									-- 我要寻宝
	SPIRIT_XUNBAO = 33,								-- 精灵寻宝
	GUILD_WELLCOME = 34,							-- 公会入会欢迎语
	GUILD_MIJING = 36,								-- 公会试练
	MAGIC_WEAPON_VIEW = 37,							-- 魔器 前往夺宝
	ZHI_ZUN_YUE_KA = 38,							-- 变身至尊 至尊月卡
	SUI_JI_CHOU_JIANG = 39,							-- 我要抽奖 幸运转盘
	DA_FU_HAO = 40,									-- 立即前往 大富豪
	CAN_JIA_HUN_YAN = 41,							-- 我要参加 参加婚宴
	WO_QIUHUN = 42,									-- 我要求婚
	FAZHEN_UP = 43,									-- 我要进阶 法阵进阶
	GUILD_CALLIN = 44,								-- 公会邀请
	MOUNT_FLY = 45,									-- 我要飞升 坐骑飞升
	WO_CHONGZHI = 46,								-- 我要充值
	WO_HUNQI_DAMO = 47,								-- 我要铸魂
	DAY_DANBI = 48,									-- 查看活动 单笔充值
	ZHENBAOGE = 50,									-- 珍宝阁
	WO_LINGYU_FB = 51,								-- 灵玉副本 我要挑战
	MIJINGTAOBAO = 52,								-- 秘境淘宝
	WO_LOTTERYTREE = 53,							-- 摇一摇
	WO_KINGDRAW = 54,								-- 陛下请翻牌
	WO_LINGQI = 55,									-- 灵器
	WO_WAKUANG = 56,                                -- 开心矿场
	DIVINATION = 57,                                -- 天命卜卦
	WO_FANFANZHUAN = 58,                            -- 翻翻转
	WO_FARM_HUNT = 59,                              -- 牧场抽奖
	WO_MULTIMOUNT = 60,								-- 双人坐骑进阶
	WO_MAGIC_CARD = 61,                              -- 我要魔卡
	WO_JINGLING_HALO = 62,                          -- 精灵光环
	WO_TREASURE_BUSINESSMAN = 63,                   -- 仙宝商人
	WO_MOUNTJINGPO = 64,                  			-- 坐骑精魄
	CROSS_FB_TEAMMATE = 65,                  		-- 跨服组队招募队员
	TOMB_BOSS = 66,                  				-- 击杀皇陵探险BOSS
	SPIRIT_FAZHEN = 67,                  			-- 精灵法阵
	TIANSHEN_ZHUANGBEI = 68,                  		-- 天神装备
	MARRY_TUODAN = 69,                  			-- 我要脱单
	WO_COMPOSE = 70,                  				-- 我要合成
	WO_RUNE = 71,                  					-- 我要符文
	XING_ZUO_YI_JI = 74,                  			-- 星座遗迹 立即前往
	LEIJI_RECHARGE = 76,							-- 累计充值
	WO_DAILY_RECHARGE = 77,                  		-- 每日累冲 前往查看
	SHEN_BING = 78,                  				-- 神兵 我要升级
	SHEN_GE_BLESS = 79,                  			-- 神格 祈福
	SHEN_GE_COMPOSE = 80,                  			-- 神格 合成
	SHENGXIAO_TU = 81,                  			-- 生肖 拼图
	WO_LEVEL_TOUZHI = 82,                  			-- 等级投资 我要投资
	WO_YUE_TOUZHI = 83,                  			-- 月卡投资 我要投资
	WO_ZERO_GIFT = 84,                  			-- 零元礼包 我要领取
	WO_FENG_SHEN = 85,                  			-- 封神之路 我要封神
	WO_DISCOUNT = 86,                  				-- 一折抢购 我要抢购
	WO_TEMP_GIFT = 87,                  			-- 限时礼包 我要抢购
	WO_SELF_BUY = 88,                  				-- 个人抢购 我要特价
	WO_SHENGE_INLAY = 89,                  			-- 神格镶嵌 我要升级
	WO_SPIRIT_UPGRADE = 90,							-- 精灵悟性 我要提升
	SHENMI_SHOP = 91,								-- 神秘商店
	ADD_FRIEND = 92,								-- 加好友
	RED_EQUIP_JINJIE = 93,							-- 我要进阶 锻造红装进阶
	ARENA_SHENGLI = 94,								-- 竞技场胜利
	ZHANGKONG_SHENGJI = 95,							-- 点击打开掌控
	JUBAOPEN = 96,									-- 聚宝盆
	FORTE_ENTERNITY = 97,							-- 永恒装备
	GOLDEN_PIG_ACTIVITY = 100,						-- 金猪召唤（龙神夺宝），立即前往金猪召唤boss处
	GODDESS_SHENGWU = 98,			 				-- 女神圣物，我要升级
	GODDESS_GONGMING = 99,							-- 女神法则，我要升级

	KAIFU_INVEST = 101,                             -- 开服投资，我要投资
	DUIHUAN_SHOP = 102,								-- 兑换商店
	FOOTPRINT_UPGRADE = 103,						-- 足迹进阶
	MAP_FIND = 104,                                 -- 地图寻宝
	RUSH_BUY = 105,									-- 限时秒杀
	PIFENG_UPLEVEL = 106,							-- 披风提升
	SPIRIT_MEET = 107,							    -- 精灵奇遇
	SHENSHOU_HUANLING = 108,						-- 神兽唤灵
	SHENGE_GODBODY = 110,							-- 我要修炼
	IMG_FULING = 111,								-- 形象赋灵
	RUNE_ZHULING = 112,								-- 符文注灵
	HUNQI_XILIAN = 113,								-- 魂器洗练
	SYMBOL_XILIAN = 115,							-- 元素之心洗练
	SHENYIN_ZHAOYIN = 116,							-- 神印-招印
	FABAO_UPGRADE = 117,
	MARKET_BUY = 118,								-- 市场 我要购买
	YAOSHI_UPGRADE = 119,							-- 腰饰进阶
	TOUSHI_UPGRADE = 120,							-- 头饰进阶
	QILINBI_UPGRADE = 121,							-- 麒麟臂进阶
	MASK_UPGRADE = 122,								-- 面饰进阶
	ZhuanZhiUpStar = 123,							-- 转职装备升星
	Guild_Invite_Assist = 124,						-- 邀请协助
	LING_BOSS = 125,								-- 立即前往 灵鲲boss
	FASHION = 126,									-- 时装
	SECRET_TREASURE_HUNTING = 127,					-- 秘境寻宝
	HAPPY_HIT_EGG = 128,							-- 欢乐砸蛋
	HAPPY_ERNIE = 129,								-- 欢乐摇奖
	HUNYAN_QINGTIE = 130,							-- 婚宴请帖
	INSANE_ERNIE = 133,								-- 疯狂摇奖
	LEIJI_CHONGZHI = 134,
	HEFU_BOSS = 135,								-- 合服BOSS
	KUAFU_BOSSTIP = 136, 							-- 跨服boss刷新通知
	BIAOBAI = 137, 									-- 表白墙
	FUBEN_TOUZI = 138, 								-- 副本投资
	BOSS_TOUZI = 139, 								-- boss投资
	YUNYOUBOSS = 141,								-- 云游bos
	SHENYUBOSS_TOUZI = 142,							-- 神域Boss投资
	RAND_ACTIVITY_TYPE_TOTAL_CHARGE = 140, 			-- 累计充值
	GIFTLIMITBUY = 143,								-- 限购礼包
	TIANSHUSKILL = 144,								-- 天书技能
	FORGEEXCHANGE = 145,							-- 锻造合成
	LOOKCROSSRANK = 146,							-- 跨服增战榜
	LOOKCROSSRANKMEILI = 147,						-- 跨服增魅榜
	LOOKCROSSRANKQINYUAN = 148,						-- 跨服情缘榜
	FORGEJUEXING = 149,								-- 锻造觉醒
	LUCKY_SHOPPING = 150,							-- 幸运云购
	KFArena = 151,							-- 点击打开跨服竞技场
	MYTH_PIANZHAN = 152, 							-- 点击打开神话-篇章
	MYTH_GONGMING = 153, 							-- 点击打开神话-共鸣
	MYTH_COMPOSE = 154, 							-- 点击打开神话-合成
	DOUQI_GRADE = 155,								-- 点击打开斗气-阶段
	DOUQI_BAOXIANG = 156,							-- 点击打开斗气-宝箱
	DOUQI_REFINE = 157,								-- 点击打开斗气-炼制
	DALE_GOU = 158,									-- 狂欢大乐购
	RAND_ACTIVITY_TYPE_TOTAL_CHARGE_ONE = 159,		-- 狂欢活动的累计充值1
	RAND_ACTIVITY_TYPE_TOTAL_CHARGE_TWO = 160,		-- 狂欢活动的累计充值2
	RAND_ACTIVITY_TYPE_TOTAL_CHARGE_THREE = 161,	-- 狂欢活动的累计充值3
	UPGRADE_LINGZHU = 200,							-- 外观-灵珠
	UPGRADE_XIANBAO = 201,							-- 外观-仙宝
	UPGRADE_LINGTONG = 202,							-- 外观-灵童
	UPGRADE_LINGGONG = 203,							-- 外观-灵弓
	UPGRADE_LINGQI = 204,							-- 外观-灵骑
	UPGRADE_WEIYAN = 205,							-- 外观-尾焰
	UPGRADE_SHOUHUAN = 206,							-- 外观-手环
	UPGRADE_TAIL = 207,								-- 外观-尾巴
	UPGRADE_FLYPET = 208,							-- 外观-飞宠
	FORGE_BAPTIZE = 209,							-- 锻造-洗练
	SHENYUBOSS_SHENYU = 210,						-- 神域Boss-神域
	SHENYUBOSS_YOUMING = 211,						-- 神域Boss-幽冥
	-- 1000开头客户端自己的传闻
	GODDESS_INFO = 1000,							-- 女神假传闻
	GUILD_DATI = 1001,								-- 仙盟答题
	SEND_GTFT_RECORD = 1002,						-- 赠送记录(我要回礼)
	SEND_GTFT_RECORD_CONTINUE = 1003,				-- 赠送记录(继续赠送)
	CHATSINGLE = 1004,					 			-- 收购私聊
	GUILDYUNBIAO_TAKEPARK = 1005,					-- 我要参加
}

FLYING_PROCESS_TYPE = {
	NONE_FLYING = 0,
	FLYING_UP = 1,
	FLYING_IN_MAX_HEIGHT = 2,
	FLYING_DOWN = 3,
}

MOVE_MODE = {
	MOVE_MODE_NORMAL = 0,										--正常
	MOVE_MODE_FLY = 1,											--飞行
	MOVE_MODE_JUMP = 2,											--跳跃
	MOVE_MODE_JUMP2 = 3,										--跳跃2
	MOVE_MODE_MAX = 4,
}

MOVE_MODE_FLY_PARAM = {
	MOVE_MODE_FLY_PARAM_INVALID = 0,
	MOVE_MODE_FLY_PARAM_DRAGON = 1,								--龙
	MOVE_MODE_FLY_PARAM_QILIN = 2,								--麒麟
}

SPECIAL_APPEARANCE_TYPE = {
	SPECIAL_APPEARANCE_TYPE_NORMAL = 0,
	SPECIAL_APPERANCE_TYPE_WORD_EVENT_YURENCARD = 1,            -- 世界事件愚人卡外观
	SPECIAL_APPERANCE_TYPE_GREATE_SOLDIER = 2,					-- 变身/名将形象
	SPECIAL_APPERANCE_TYPE_HUASHENG = 3,						-- 化神外观
	SPECIAL_APPERANCE_TYPE_TERRITORYWAR = 4,					-- 领土战外观
	SPECIAL_APPERANCE_TYPE_CROSS_HOTSPRING = 5,					-- 跨服温泉外观
	SPECIAL_APPEARANCE_TYPE_CROSS_FISHING = 6,					-- 跨服钓鱼外观

	SPECIAL_APPEARANCE_TYPE_ZHUQUE = 101,						--朱雀
	SPECIAL_APPEARANCE_TYPE_XUANWU = 102,
	SPECIAL_APPEARANCE_TYPE_QINGLONG = 103,
	SPECIAL_APPEARANCE_TYPE_SHNEQI = 9,         --神器
	
}

HUNYAN_NOTIFY_REASON = {
	HUNYAN_NOTIFY_REASON_STATE_CHANGE = 0,				-- 状态改变
	HUNYAN_NOTIFY_REASON_ENTER_HUNYAN = 1,				-- 进入婚宴
	HUNYAN_NOTIFY_REASON_LOGIN = 2,						-- 上线
	HUNYAN_NOTIFY_REASON_INVITE_FRIEND = 3,				-- 邀请好友
	HUNYAN_NOTIFY_REASON_INVITE_GUILD = 4,				-- 邀请仙盟好友
	HUNYAN_NOTIFY_REASON_GATHER = 5,					-- 采集
	HUNYAN_NOTIFY_REASON_GIVE_HONGBAO = 6,				-- 发红包
}

TUODAN_OPERA_TYPE = {
	TUODAN_INSERT = 0,								--脱单信息插入(更新)
	TUODAN_DELETE = 1,								--脱单信息删除
}

SKILL_PERFOM_TYPE = {
	NONE = 0,											--不能释放
	AIM_TARGET = 1,										--瞄准目标
	DIRECT = 2,											--直接释放
}

SPEAKER_TYPE = {
	SPEAKER_TYPE_LOCAL = 0,								-- 本服喇叭
	SPEAKER_TYPE_CROSS = 1,								-- 跨服传音

	SPEAKER_TYPE_KOULING = 100,							-- 口令红包

	SSPEAKER_TYPE_MAX = 2,
}

LIEMING_HUNSHOU_OPERA_TYPE = {							-- 猎命操作类型
	INVALID = 0,
	CHOUHUN = 1,
	SUPER_CHOUHUN = 2,
	BATCH_HUNSHOU = 3,
	SPECIAL_BATCH_HUNSHOU = 4,
	PUT_BAG = 5,
	CONVERT_TO_EXP = 6,
	MERGE = 7,
	SINGLE_CONVERT_TO_EXP = 8,
	TAKEON = 9,
	TAKEOFF = 10,
	FUHUN_ADD_EXP = 11,
	PUT_BAG_ONE_KEY = 12,
	-- EXCHANGE = 13,										-- 把命魂池里面的命魂和命魂槽的交换
	LIEMING_HUNSHOU_OPERA_TYPE_AUTO_UPLEVEL = 13,

	OPERA_TYPE_MAX = 14,
}

JINGLING_OPER_TYPE = {						-- 精灵操作类型
	JINGLING_OPER_TAKEOFF = 0,				-- 取下
	JINGLING_OPER_CALLBACK = 1,				-- 召回
	JINGLING_OPER_FIGHTOUT = 2,				-- 出战
	JINGLING_OPER_UPLEVEL = 3,				-- 升级
	JINGLING_OPER_UPLEVELCARD = 4,			-- 升级卡牌
	JINGLING_OPER_RENAME = 5,				-- 精灵改名
	JINGLING_OPER_UPGRADE = 6,				-- 升阶
	JINGLING_OPER_STRENGTH = 7,				-- 强化装备
	JINGLING_OPER_USEIMAGE = 8,				-- 使用形象
	JINGLING_OPER_PHANTOM =	9,				-- 使用幻化形象
	JINGLING_OPER_UPPHANTOM = 10,			-- 幻化形象升级
	JINGLING_OPER_UPGRADESOUL = 11,         --聚灵升级
	JINGLING_OPER_UPGRADE_HALO = 12,		--精灵光环
	JINGLING_OPER_USE_HALO_IMG = 13,		--选择光环
	JINGLING_OPER_ONEKEY_RECYCL_BAG = 14,	-- 一键回收背包精灵
	JINGLING_OPER_UPLEVEL_WUXING = 15,		-- 升级悟性,param1 精灵索引,param2 是否使用保护符,param3 是否自动购买
	JINGLING_OPER_UPLEVEL_XIANZHEN = 16,	-- 升级仙阵
	JINGLING_OPER_UPLEVEL_HUNYU = 17,		-- 升级魂玉,param1 魂玉类型
	JINGLING_OPER_REMOVE_SKILL = 18,		-- 技能 遗忘,param1 精灵索引,param2 技能索引,param3 是否自动购买
	JINGLING_OPER_CHANGE_MOVE = 19,			-- 技能 变成可移动,param1 精灵索引,param2 技能索引,param3 是否自动购买
	JINGLING_OPER_PUT_ON_SKILL = 20,		-- 技能 穿戴,param1 精灵索引,param2 技能索引,param3 技能仓库索引
	JINGLING_OPER_TAKE_OFF_SKILL = 21,		-- 技能 脱下,param1 精灵索引,param2 技能索引,param3 技能仓库索引
	JINGLING_OPER_LEARN_SKILL = 22,			-- 技能 学习,param1 精灵索引,param2 技能索引,param3 物品索引
	JINGLING_OPER_REFRESH = 23,				-- 技能 刷新,param1 刷新索引,param2 是否10连刷
	JINGLING_OPER_GET = 24,					-- 技能 苏醒,param1 刷新索引,param2 技能索引
	JINGLING_OPER_OPEN_SKILL_SLOT = 26,		-- 技能槽开启 param1, 精灵索引, param2 技能索引
}

JINGLING_ADCANTAGE_OPER_TYPE = {
	JINGLING_ADCANTAGE_OPER_TYPE_BOSS = 0,        -- 奇遇boss   enter_bossid 为bossid
	JINGLING_ADCANTAGE_OPER_TYPE_EGG = 1,         -- 仙宠蛋位置 enter_bossid 为场景id
}


SHENGXIAO_MIJI_TYPE = {
	[0] = "maxhp",
	[1] = "gongji",
	[2] = "fangyu",
	[3] = "baoji",
	[4] = "jianren",
	[5] = "mingzhong",
	[6] = "shanbi",
	[7] = "goddess_gongji",
	[8] = "constant_zengshang",
	[9] = "constant_mianshang",
}

SHENGXIAO_MIJI_ATTR_NAME = {
	maxhp = "生命",
	gongji = "攻击",
	fangyu = "防御",
	baoji = "暴击",
	jianren = "抗暴",
	mingzhong = "命中",
	shanbi = "闪避",
	goddess_gongji = "女神攻击",
	constant_zengshang = "固定增伤",
	constant_mianshang = "固定免伤",
}

JINGLING_TALENT_TYPE = {
	[1] = "gongji",
	[2] = "fangyu",
	[3] = "maxhp",
	[4] = "mingzhong",
	[5] = "shanbi",
	[6] = "baoji",
	[7] = "jianren",
	[8] = "per_jingzhun",
	[9] = "per_baoji",
	[10] = "per_pofang",
	[11] = "per_mianshang",
}

JINGLING_TALENT_ATTR_NAME = {
	gongji = "攻击",
	fangyu = "防御",
	maxhp = "生命",
	mingzhong = "命中",
	shanbi = "闪避",
	baoji = "暴击",
	jianren = "抗暴",
	per_jingzhun = "破甲",
	per_baoji = "暴伤",
	per_pofang = "增伤",
	per_mianshang = "免伤",
}

TEAM_ASSIGN_MODE = {
	TEAM_ASSIGN_MODE_KILL = 1,					-- 谁击杀谁得
	TEAM_ASSIGN_MODE_RANDOM = 2,				-- 随机分配模式
}

SHENGWANG_OPERA_TYPE = {						-- 声望操作类型
	SHENGWANG_OPERA_REQ_INFO = 0,				-- 请求声望相关信息
	SHENGWANG_OPERA_XIANJIE_UPLEVEL = 1,		-- 仙阶升级
	SHENGWANG_OPERA_XIANDAN_UPLEVEL = 2,		-- 仙丹升级
}

CHENGJIU_OPER_TYPE = {
	CHENGJIU_REQ_INFO = 0,						-- 请求成就信息
	CHENGJIU_OPER_TITLE_UPLEVEL = 1,			-- 提升称号
	CHENGJIU_OPER_FETCH_REWARD = 2,				-- 领取奖励
	CHENGJIU_OPER_FUWEN_UPLEVEL = 3,	 		-- 提升符文
}

-- 寻宝类型
CHEST_SHOP_TYPE = {
	CHEST_SHOP_TYPE_INVALID = 0,
	CHEST_SHOP_TYPE_EQUIP = 1,					-- 装备寻宝
	CHEST_SHOP_TYPE_EQUIP1 = 2,					-- 装备寻宝1
	CHEST_SHOP_TYPE_EQUIP2 = 3,					-- 装备寻宝2
	CHEST_SHOP_TYPE_JINGLING = 4,				-- 精灵仓库请求
}

-- 仓库枚举
CHEST_SHOP_STOREHOUSE_TYPE = {
	CHEST_SHOP_STOREHOUSE_TYPE_INVALID = 0,
	CHEST_SHOP_STOREHOUSE_TYPE_EQUIP = 1,		-- 装备寻宝仓库
	CHEST_SHOP_STOREHOUSE_TYPE_JINGLING = 2,	-- 精灵仓库	
}

REALIVE_TYPE = {
	REALIVE_TYPE_BACK_HOME = 0,						-- 回城复活
	REALIVE_TYPE_HERE_GOLD = 1,						-- 使用元宝原地复活
	REALIVE_TYPE_HERE_ICON = 2,						-- 使用物品原地复活？（没用）
}

CS_TIANSHUXZ_SEQ_TYPE = {
	CS_TIANSHUXZ_SEQ_TYPE_INFO = 0,					--获取信息
	CS_TIANSHUXZ_SEQ_TYPE_FETCH = 1,				--领取奖励
}

--{第几次复活，所需铜币}
DAY_REVIVAL_TIMES = {
	{1, 200000},
	{6, 300000},
	{11, 400000},
	{16, 500000},
	{21, 600000},
	{26, 700000},
	{31, 800000},
	{36, 900000},
	{41, 1000000},
}

SCORE_TO_ITEM_TYPE = {
	INVALID = 0,
	GOUYU = 1,											-- 勾玉兑换
	NORMAL_ITEM = 2,									-- 道具兑换
	EQUIP = 3,											-- 装备兑换

	CS_EQUIP1 = 4,										-- 装备寻宝商店兑换1		 6仙品 幸运
	CS_EQUIP2 = 5,										-- 装备寻宝商店兑换2		 6仙品
	CS_EQUIP3 = 6,										-- 装备寻宝商店道具兑换3

	CS_JINGLING1 = 7,									-- 精灵寻宝商店兑换1
	CS_JINGLING2 = 8,									-- 精灵寻宝商店兑换2

	CS_MEDCHINE = 9,									-- 药店兑换购买

	CS_HUOLI = 10,										-- 活力

	MAX = 11,
}

TEAM_FB_OPERAT_TYPE = {
	REQ_ROOM_LIST = 1,			-- 请求房间列表
	CREATE_ROOM = 2,			-- 创建房间
	JOIN_ROOM = 3,				-- 加入指定房间
	START_ROOM = 4,				-- 开始
	EXIT_ROOM = 5,				-- 退出房间
	CHANGE_MODE = 6,			-- 改变模式
	KICK_OUT = 7,				-- T人
}

MIGONGXIANFU_LAYER_TYPE = {
	MGXF_LAYER_TYPE_NORMAL = 0,							-- 普通层
	MGXF_LAYER_TYPE_BOSS = 1,							-- Boss层
	MGXF_LAYER_TYPE_HIDE = 2,							-- 隐藏层
}

MIGONGXIANFU_STATUS_TYPE = {
	MGXF_DOOR_STATUS_NONE = 0,
	MGXF_DOOR_STATUS_TO_PRVE = 1,
	MGXF_DOOR_STATUS_TO_HERE = 2,
	MGXF_DOOR_STATUS_TO_NEXT = 3,
	MGXF_DOOR_STATUS_TO_HIDE = 4,
	MGXF_DOOR_STATUS_TO_BOSS = 5,
	MGXF_DOOR_STATUS_TO_FIRST = 6,
}

LIFE_SKILL_OPERAT_TYPE = {
	LIFE_SKILL_OPERAT_TYPE_REQ_INFO = 0,				-- 生活技能请求信息
	LIFE_SKILL_OPERAT_TYPE_UPLEVEL = 1,					-- 生活技能升级
	LIFE_SKILL_OPERAT_TYPE_MAKE = 2,					-- 生活技能制作物品
}

-- 精灵配置天赋
JL_GAY_WAY = {
	LIBAO = 1
}

CHAT_WIN_REQ_TYPE = {
	PERSONALIZE_WINDOW_ALL_INFO = 0,				--个性化窗口信息
	PERSONALIZE_WINDOW_CONSUME_ITEM = 1,
	PERSONALIZE_WINDOW_USE_RIM = 2,
	PERSONALIZE_WINDOW_ACTIVE_BUBBLE_RIM_SUIT = 3,	-- 激活气泡框一个套装部位，参数1套装seq，参数2套装部位part
	PERSONALIZE_WINDOW_ACTIVE_BUBBLE_RIM = 4,		-- 激活气泡框，参数1气泡框seq
	PERSONALIZE_WINDOW_USE_BUBBLE_RIM = 5,			-- 使用气泡框，参数1气泡框seq
}

-- 卡牌操作
CARD_OPERATE_TYPE = {
	REQ = 0,				-- 请求信息
	INLAY = 1,			-- 镶嵌
	UPLEVEL = 2,			-- 升级
	KEY_UPLEVEL = 3,		-- 一键升级
}

--跨服帮派战请求
CROSS_GUILDBATTLE_OPERATE = {
	CROSS_GUILDBATTLE_OPERATE_REQ_INFO = 0,
	CROSS_GUILDBATTLE_OPERATE_FETCH_REWARD = 1,
	CROSS_GUILDBATTLE_OPERATE_REQ_TASK_INFO = 2,
	CROSS_GUILDBATTLE_OPERATE_BOSS_INFO = 3,
	CROSS_GUILDBATTLE_OPERATE_SCENE_RANK_INFO = 4,
	CROSS_GUILDBATTLE_OPERATE_GOTO_SCENE = 5,			-- 飞到对应场景的随机复活点
	CROSS_GUILDBATTLE_OPERATE_GET_DAILY_REWARD = 6,		-- 获取占领的每天奖励
	CROSS_GUILDBATTLE_OPERATE_SOS = 7,					-- 召集
}

CROSS_GUILDBATTLE = {
	CROSS_GUILDBATTLE_MAX_FLAG_IN_SCENE = 3,		-- 最大旗子数在场景中
	CROSS_GUILDBATTLE_MAX_SCENE_NUM = 6,			-- 帮派场景个数
	CROSS_GUILDBATTLE_MAX_GUILD_RANK_NUM = 5,		-- 跨服帮派战前5
	CROSS_GUILDBATTLE_MAX_TASK_NUM = 6,
}

-- 战斗力类型
CAPABILITY_TYPE = {
	CAPABILITY_TYPE_INVALID = 0,
	CAPABILITY_TYPE_BASE = 1,					-- 基础属性战斗力
	CAPABILITY_TYPE_MENTALITY = 2,				-- 元神属性战斗力
	CAPABILITY_TYPE_EQUIPMENT = 3,				-- 装备属性战斗力
	CAPABILITY_TYPE_WING = 4,					-- 羽翼属性战斗力
	CAPABILITY_TYPE_MOUNT = 5,					-- 坐骑属性战斗力
	CAPABILITY_TYPE_TITLE = 6,					-- 称号属性战斗力
	CAPABILITY_TYPE_SKILL = 7,					-- 技能属性战斗力
	CAPABILITY_TYPE_XIANJIAN = 8,				-- 仙剑属性战斗力
	CAPABILITY_TYPE_XIANSHU = 9,				-- 仙盟仙术属性战斗力
	CAPABILITY_TYPE_GEM = 10,					-- 宝石战斗力
	CAPABILITY_TYPE_XIANNV = 11,				-- 仙女属性战斗力
	CAPABILITY_TYPE_FOOTPRINT = 12,				-- 足迹属性战斗力
	CAPABILITY_TYPE_QINGYUAN = 13,				-- 情缘属性战斗力
	CAPABILITY_TYPE_ZHANSHENDIAN = 14,			-- 战神殿属性战斗力
	CAPABILITY_TYPE_SHIZHUANG = 15,				-- 时装属性战斗力
	CAPABILITY_TYPE_ATTR_PER = 16,				-- 基础属性百分比加的战斗力
	CAPABILITY_TYPE_LIEMING = 17,				-- 猎命装备战力
	CAPABILITY_TYPE_JINGLING = 18,				-- 精灵战力
	CAPABILITY_TYPE_VIPBUFF = 19,				-- vipbuff战力
	CAPABILITY_TYPE_SHENGWANG = 20,				-- 声望
	CAPABILITY_TYPE_CHENGJIU = 21,				-- 成就
	CAPABILITY_TYPE_WASH = 22,					-- 洗练
	CAPABILITY_TYPE_SHENZHUANG = 23,			-- 神装
	CAPABILITY_TYPE_TUHAOJIN = 24,				-- 土豪金战力
	CAPABILITY_TYPE_BIG_CHATFACE = 25,			-- 大表情战力
	CAPABILITY_TYPE_SHENZHOU_WEAPON = 26,		-- 神州六器战斗力
	CAPABILITY_TYPE_BABY = 27,					-- 宝宝属性战斗力
	CAPABILITY_TYPE_PET = 28,					-- 宠物战力
	CAPABILITY_TYPE_ACTIVITY = 29,				-- 活动相关提升的战力
	CAPABILITY_TYPE_HUASHEN = 30,				-- 化神战力
	CAPABILITY_TYPE_MULTIMOUNT = 31, 			-- 双人坐骑战力
	CAPABILITY_TYPE_PERSONALIZE_WINDOW = 32,	-- 个性聊天框战力
	CAPABILITY_TYPE_MAGIC_CARD = 33,			-- 魔卡战斗力
	CAPABILITY_TYPE_MITAMA = 34,				-- 御魂战力
	CAPABILITY_TYPE_XUNZHANG = 35,				-- 勋章战力
	CAPABILITY_TYPE_ZHIBAO = 36,				-- 至宝战力
	CAPABILITY_TYPE_HALO = 37,					-- 光环属性战斗力
	CAPABILITY_TYPE_SHENGONG = 38,				-- 神弓属性战斗力
	CAPABILITY_TYPE_SHENYI = 39,				-- 神翼属性战斗力
	CAPABILITY_TYPE_GUILD = 40,					-- 仙盟战斗力
	CAPABILITY_TYPE_CHINESE_ZODIAC = 41,		-- 星座系统战斗力
	CAPABILITY_TYPE_XIANNV_SHOUHU = 42,			-- 仙女守护战斗力
	CAPABILITY_TYPE_JINGLING_GUANGHUAN = 43,	-- 精灵光环战斗力
	CAPABILITY_TYPE_JINGLING_FAZHEN = 44,		-- 精灵法阵战斗力
	CAPABILITY_TYPE_CARDZU = 45,				-- 卡牌组合战力
	CAPABILITY_TYPE_ZHUANSHENGEQUIP = 46,    	-- 转生属性战斗力
	CAPABILITY_TYPE_LITTLE_PET = 47,			-- 小宠物战力
	CAPABILITY_TYPE_ZHUANSHEN_RAND_ATTR = 48,	-- 转生装备随机属性
	CAPABILITY_TYPE_FIGHT_MOUNT = 49,			-- 战斗坐骑战斗力
	CAPABILITY_TYPE_MOJIE = 50,					-- 魔戒
	CAPABILITY_TYPE_LOVE_TREE = 51,				-- 相思树
	CAPABILITY_TYPE_EQUIPSUIT = 52,				-- 锻造套装战斗力
	CAPABILITY_TYPE_RUNE_SYSTEM = 53,			-- 符文系统
	CAPABILITY_TYPE_SHENGE_SYSTEM = 54,			-- 神格系统
	CAPABILITY_TYPE_SHENBING = 55,				-- 神兵系统
	CAPABILITY_TYPE_FABAO = 56, 				-- 法宝属性战斗力
	CAPABILITY_TYPE_ROLE_GOAL = 57,				-- 角色目标
	CAPABILITY_TYPE_CLOAK = 58, 				-- 披风属性战斗力
	CAPABILITY_TYPE_SHENSHOU = 59, 				-- 神兽战斗力
	CAPABILITY_TYPE_IMG_FULING = 60, 			-- 形象赋灵
	CAPABILITY_TYPE_CSA_EQUIP = 61, 			-- 合服装备
	CAPABILITY_TYPE_SHEN_YIN = 62, 				-- 神印
	CAPABILITY_TYPE_ELEMENT_HEART = 63, 		-- 元素之心战力
	CAPABILITY_TYPE_FEIXIAN = 64,				-- 飞仙战斗力
	CAPABILITY_TYPE_SHIZHUANG_WUQI = 65, 		-- 时装武器（神兵）属性战斗力

	CAPABILITY_TYPE_TOTAL = 66, 				-- 总战斗力，(战斗力计算方式改为所有属性算好后再套公式计算，取消各个模块分别计算再加起来的方式）

	CAPABILITY_TYPE_MAX = 67,

}	

-- 仙盟仓库操作
GUILD_STORGE_OPERATE = {
	GUILD_STORGE_OPERATE_PUTON_ITEM = 1, -- 放进仓库
	GUILD_STORGE_OPERATE_TAKE_ITEM = 2,  -- 取出仓库
	GUILD_STORGE_OPERATE_REQ_INFO = 3,	 -- 请求仓库信息
}
	
-- 红包
GUILD_RED_POCKET_OPERATE_TYPE = {
	GUILD_RED_POCKET_OPERATE_INFO_LIST = 0,                 -- 仙盟红包 请求红包列表信息
	GUILD_RED_POCKET_OPERATE_DISTRIBUTE	= 1,				-- 仙盟红包 请求分发红包
		GUILD_RED_POCKET_OPERATE_GET_POCKET	= 2,				-- 仙盟红包 请求获取红包
	GUILD_RED_POCKET_OPERATE_DISTRIBUTE_INFO = 3,			-- 仙盟红包 请求分发详情
}

-- 红包领取状态
GUILD_RED_POCKET_STATUS = {
	UN_DISTRIBUTED = 1,										-- 未发放
	DISTRIBUTED = 2,										-- 已发放
	DISTRIBUTE_OUT = 3,                                     -- 已抢的红包
}
NOTICE_REASON = {
	HAS_CAN_CREATE_RED_PAPER = 0,							-- 有可发
	HAS_CAN_FETCH_RED_PAPER = 1,							-- 有可领
}

-- 公会骰子
GUILD_PAWN = {
	MAX_MEMBER_COUNT = 60,									-- 公会人数上限

}

-- 客户端操作请求类型 (4-7套装收集)
COMMON_OPERATE_TYPE = {
	COT_JINGHUA_HUSONG_COMMIT = 1,						-- 精华护送提交
	COT_JINGHUA_HUSONG_COMMIT_OPE = 2,					-- 精华护送提交次数请求
	COT_KEY_ADD_FRIEND = 3,								-- 一键踩好友空间
	COT_REQ_RED_EQUIP_COLLECT_TAKEON = 4,				-- 红装收集，请求穿上，param1是红装seq，param2是红装槽index， param3是背包index
	COT_REQ_RED_EQUIP_COLLECT_FETCH_ATC_REWARD = 5,		-- 红装收集，领取开服活动奖励，param1是奖励seq
	COT_REQ_RED_EQUIP_COLLECT_FETCH_TITEL_REWARD = 6,	-- 红装收集领取称号奖励, param1是奖励seq
	COT_REQ_ORANGE_EQUIP_COLLECT_TAKEON = 7,			-- 橙装收集, 请求穿上，param1是红装seq，param2是红装槽index， param3是背包index
	PERSONAL_BUY_TIMES = 8,								-- 个人BOSS 进入次数购买
	COT_ACT_BUY_EQUIPMENT_GIFT = 1000,					-- 活动 购买装备礼包
}

-- 服务器通知客户端信息类型
SC_COMMON_INFO_TYPE = {
	SCIT_JINGHUA_HUSONG_INFO = 1,				-- 同步精华护送信息
	SCIT_RAND_ACT_ZHUANFU_INFO = 2,	            -- 随机活动专服信息
	SCIT_TODAY_FREE_RELIVE_NUM = 3,			    -- 复活信息
}

JH_HUSONG_STATUS = {
	NONE = 0,
	FULL = 1,
	LOST = 2,
}

SHENZHUANG_OPERATE_TYPE = {
	REQ = 0,					-- 神装请求信息
	UPLEVEL = 1,				-- 神装升级
	SHENZHUANG_OPREATE_JINJIE = 2,			-- 新增 进阶
	SHENZHUANG_OPERATE_SHENZHU = 3,			-- 新增 神铸
}

MYSTERIOUSSHOP_OPERATE_TYPE = {
	MYSTERIOUSSHOP_OPERATE_TYPE_REQINFO = 0,		--请求神秘商店信息
	MYSTERIOUSSHOP_OPERATE_TYPE_BUY = 1,			--购买
}

CAMPEQUIP_OPERATE_TYPE = {
	CAMPEQUIP_OPERATE_TYPE_REQ_INFO = 0,		-- 请求信息
	CAMPEQUIP_OPERATE_TYPE_TAKEOFF = 1,			-- 脱下
	CAMPEQUIP_OPERATE_TYPE_HUNLIAN = 2,			-- 魂炼
	CAMPEQUIP_OPERATE_TYPE_RECYLE = 3,			-- 军团装备回收（新增）
}

--温泉是否同意添加伙伴
ADD_PARTNER_STATE = {
	ADDPARTNER_REJECT = 0,						-- 拒绝
	ADDPARTNER_AGREE = 1,						-- 同意
}

--温泉双修协议类型
SHUANGXIU_MSG_TYPE =
{
	SHUANGXIU_MSG_TYPE_ENTER_SCENE = 0,		-- 进入场景
	SHUANGXIU_MSG_TYPE_ADD = 1,					-- 双休对数增加
	SHUANGXIU_MSG_TYPE_DCE = 2,					-- 双休对数减少
}

CAMP_NORMALDUOBAO_OPERATE_TYPE = {
	ENTER = 0,		-- 请求进入军团普通夺宝
	EXIT = 1,			-- 请求退出军团普通夺宝
}

ROLE_SHADOW_TYPE = {
	ROLE_SHADOW_TYPE_INVALID = -1,
	ROLE_SHADOW_TYPE_FOOL = 0,						-- 静止机器人 木头人
	ROLE_SHADOW_TYPE_CHALLENGE_FIELD = 1,			-- 竞技场
	ROLE_SHADOW_THPE_WORLD_EVENT = 2,				-- 世界事件
	ROLE_SHADOW_TYPE_ROLE_BOSS = 3,					-- 角色boss
	ROLE_SHADOW_TYPE_CAMPDEFEND = 4,				-- 守卫雕像
	ROLE_SHADOW_TYPE_ELEMENT_FILED = 5,				-- 元素战场
	ROLE_SHADOW_TYPE_CLONE_ROLE = 6,				-- 玩家分身
}

RA_CHONGZHI_NIU_EGG_OPERA_TYPE = {
	RA_CHONGZHI_NIU_EGG_OPERA_TYPE_QUERY_INFO = 0,				-- 请求活动信息
	RA_CHONGZHI_NIU_EGG_OPERA_TYPE_CHOU = 1,					-- 抽奖
	RA_CHONGZHI_NIU_EGG_OPERA_TYPE_FETCH_REWARD = 2,			-- 领取全服奖励

	RA_CHONGZHI_NIU_EGG_OPERA_TYPE_MAX = 3,
}


CHONGZHI_REWARD_TYPE = {
		CHONGZHI_REWARD_TYPE_SPECIAL_FIRST = 0,										-- 特殊首充
		CHONGZHI_REWARD_TYPE_DAILY_FIRST = 1,										-- 日常首充
		CHONGZHI_REWARD_TYPE_DAILY_TOTAL = 2,										-- 日常累充
		CHONGZHI_REWARD_TYPE_DIFF_WEEKDAY_TOTAL = 3,	--新增						-- 每日累冲(星期几区分奖励配置)

		CHONGZHI_REWARD_TYPE_MAX,
	}

LINGYU_FB_OPERA_TYPE = {
	REQINFO = 0,			-- 挑战副本请求信息
	BUYJOINTIMES = 1,		-- 挑战副本购买次数
	AUTO = 2,				-- 挑战副本扫荡
	RESETLEVEL = 3,			-- 挑战副本重置关卡
}

TAOZHUANG_TYPE =
{
	BAOSHI_TAOZHUANG = 0,
	STREGNGTHEN_TAOZHUANG =1,
	EQUIP_UP_STAR_TAPZHUANG = 2,
}


-- 宝宝系统
BABY_REQ_TYPE = {
	BABY_REQ_TYPE_INFO = 0,								-- 请求单个宝宝信息  参数1 宝宝ID
	BABY_REQ_TYPE_ALL_INFO = 1,							-- 请求所有宝宝信息
	BABY_REQ_TYPE_UPLEVEL = 2,							-- 升级请求	参数1 宝宝ID
	BABY_REQ_TYPE_QIFU = 3,								-- 祈福请求 参数1 祈福类型
	BABY_REQ_TYPE_QIFU_RET = 4,							-- 祈福答应请求 参数1 祈福类型，参数2 是否接受
	BABY_REQ_TYPE_CHAOSHENG = 5,						-- 宝宝超生
	BABY_REQ_TYPE_SPIRIT_INFO = 6,						-- 请求单个宝宝的守护精灵的信息，发baby_index
	BABY_REQ_TYPE_TRAIN_SPIRIT = 7,						-- 培育精灵请求，发baby_index(param1)，spirit_id（param2, 从0开始，0-3）
	BABY_REQ_TYPE_REMOVE_BABY = 8,						-- 遗弃宝宝请求
	BABY_REQ_TYPE_REMOVE_BABY_RET = 9,					-- 回应是否遗弃宝宝
	BABY_REQ_TYPE_WALK = 10,                			-- 溜宝宝 param1 玩家是否idle 0不是 1是
}

BABY_INFO_TYPE = {
	BABY_INFO_TYPE_REQUESET_CREATE_BABY = 0,						-- 祈福树 生宝宝请求
	BABY_INFO_TYPE_REMOVE_BABY_REQ = 1,							-- 遗弃宝宝请求
}

PET_INFO_TYPE = {
	SC_CHOU_PET_MAX_TIMES = 10;							-- 宠物最大十连抽

	PET_MAX_COUNT_LIMIT = 12,							-- 宠物最大数量限制
	PET_MAX_STORE_COUNT = 48,							-- 宠物抽奖背包最大数量
	PET_MAX_LEVEL_LIMIT = 100,							-- 宠物最大等级限制
	PET_MAX_GRADE_LIMIT = 15,							-- 宠物最大阶数限制
	PET_EGG_MAX_COUNT_LIMIT = 15,						-- 宠物蛋最大数限制
	PET_REWARD_CFG_COUNT_LIMIT = 100,					-- 宠物奖品配置最大数量先知
	PET_SKILL_CFG_MAX_COUNT_LIMIT = 12,					-- 宠物技能配置最大个数
	INVALID_PET_ID = -1,								-- 无效的宠物ID
	PET_SKILL_MAX_LEVEL = 3,							--宠物技能最大等级
}

PET_REQ_TYPE = {
	PET_REQ_TYPE_INFO = 0,								-- 宠物基础信息请求
	PET_REQ_TYPE_BACKPACK_INFO = 1,						-- 宠物背包信息请求
	PET_REQ_TYPE_SELECT_PET = 2,						-- 宠物出战请求
	PET_REQ_TYPE_CHANGE_NAME = 3,						-- 宠物改名请求
	PET_REQ_TYPE_UP_LEVEL = 4,							-- 宠物升级请求
	PET_REQ_TYPE_UP_GRADE = 5,							-- 宠物升阶请求
	PET_REQ_TYPE_CHOU = 6,								-- 宠物抽取请求
	PET_REQ_TYPE_RECYCLE_EGG = 7,						-- 宠物蛋回收请求
	PET_REQ_TYPE_PUT_REWARD_TO_KNAPSACK = 8,			-- 宠物领取奖励请求
	PET_REQ_TYPE_ACTIVE = 9,							-- 激活请求
	PET_REQ_TYPE_LEARN_SKILL = 10,						-- 学习技能请求
	PET_REQ_TYPE_UPGRADE_SKILL = 11,					-- 升级技能请求
	PET_REQ_TYPE_FORGET_SKILL = 12,						-- 遗忘技能请求
	PET_REQ_TYPE_QINMI_PROMOTE = 13,					-- 提升亲密度，传食物的index [0, 3)
	PET_REQ_TYPE_QINMI_AUTO_PROMOTE = 14,				-- 一键升亲密等级，无参数
	PET_REQ_TYPE_FOOD_MARKET_CHOU_ONCE = 15,			-- 吃货市场一次抽奖
	PET_REQ_TYPE_FOOD_MARKET_CHOU_TIMES = 16,			-- 吃货市场多次抽奖
	PET_REQ_TYPE_UPLEVL_SPECIAL_IMG = 17,				--  灵器幻化升级
}

PET_SKILL_SLOT_TYPE = {
	PET_SKILL_SLOT_TYPE_ACTIVE = 0,						-- 主动技能槽
	PET_SKILL_SLOT_TYPE_PASSIVE_1 = 1,					-- 被动技能槽1
	PET_SKILL_SLOT_TYPE_PASSIVE_2 = 2,					-- 被动技能槽2
	PET_SKILL_SLOT_TYPE_COUNT = 3,						-- 技能槽总数量
}

RA_MINE_OPERA_TYPE = {
		RA_MINE_OPERA_TYPE_QUERY_INFO = 0,				-- 请求活动的信息
		RA_MINE_OPERA_REFRESH = 1,						-- 换矿请求，发一个参数，1使用元宝，0不使用
		RA_MINE_OPERA_GATHER = 2,						-- 挖矿请求，发一个参数，下标，[0, 3]
		RA_MINE_OPERA_FETCH_SERVER_REWARD = 3,			-- 领取全服奖励请求，发一个参数，下标
		RA_MINE_OPERA_EXCHANGE_REWARD = 4,				-- 兑换锦囊，发一个参数，下标

		RA_MINE_OPERA_TYPE_MAX,
	}

--开心矿场
RA_MINE_TYPES = {
	RA_MINE_TYPES_INVALID = 0,
	RA_MINE_TYPES_BEGIN = 10,
	RA_MINE_TYPES_END = 10 + GameEnum.RA_MINE_TYPE_MAX_COUNT - 1,
}

--顶刮刮
RA_GUAGUA_OPERA_TYPE = {
	RA_GUAGUA_OPERA_TYPE_QUERY_INFO = 0,					-- 请求活动的信息
	RA_GUAGUA_OPERA_TYPE_PLAY_TIMES =1,						-- 刮奖多次

	RA_GUAGUA_OPERA_TYPE_MAX =2,
}

--神秘占卜屋
RA_TIANMING_DIVINATION_OPERA_TYPE = {
	RA_TIANMING_DIVINATION_OPERA_TYPE_QUERY_INFO = 0, 			--请求天命卜卦活动信息
	RA_TIANMING_DIVINATION_OPERA_TYPE_ADD_LOT_TIMES = 1, 		--竹签加注
	RA_TIANMING_DIVINATION_OPERA_TYPE_RESET_ADD_LOT_TIMES = 2, 	--重置竹签加注倍数
	RA_TIANMING_DIVINATION_OPERA_TYPE_START_CHOU = 3, 			--开始卜卦
	RA_TIANMING_DIVINATION_OPERA_TYPE_MAX = 4,
}

-----化神
HUASHEN_REQ_TYPE = {
	HUASHEN_REQ_TYPE_ALL_INFO = 0,						-- 所有信息
	HUASHEN_REQ_TYPE_CHANGE_IMAGE = 1,					-- 切换形象
	HUASHEN_REQ_TYPE_UP_LEVEL = 2,						-- 升级
	HUASHEN_REQ_TYPE_SPIRIT_INFO = 3,		            -- 请求化神精灵信息
	HUASHEN_REQ_TYPE_UPGRADE_SPIRIT = 4,	            -- 化神精灵升级
	HUASHEN_REQ_TYPE_UP_GRADE = 5,						-- 化神形象升级
	HUASHEN_REQ_TYPE_MAX = 6,
}

QINGYUAN_COUPLE_HALO_REQ_TYPE = {
	QINGYUAN_COUPLE_REQ_TYPE_INFO = 0,					-- 请求信息
	QINGYUAN_COUPLE_REQ_TYPE_ACTIVITE_ICON = 1,			-- 激活图标
	QINGYUAN_COUPLE_REQ_TYPE_EQUIP = 2,					-- 装备光环
	QINGYUAN_COUPLE_REQ_TYPE_UPGRADE = 3,				-- 光环升级
	QINGYUAN_COUPLE_REQ_TYPE_MAX = 4,
}

QINGYUAN_FB_OPERA_TYPE = {
	QINGYUAN_FB_OPERA_TYPE_BASE_INFO = 0,	-- 请求副本基本信息
	QINGYUAN_FB_OPERA_TYPE_BUY_TIMES = 1,	-- 购买进入次数
	QINGYUAN_FB_OPERA_TYPE_BUY_BUFF = 2,	-- 购买buff
	QINGYUAN_FB_OPERA_TYPE_BUY_DOUBLE_REWARD = 3,	--购买双倍奖励
}

RAND_ACTIVITY_OPEN_TYPE = {
	RAND_ACTIVITY_OPEN_TYPE_NORMAL = 0,                  --正常随机活动
	RAND_ACTIVITY_OPEN_TYPE_VERSION = 1,				--版本活动

}

--翻翻转
RA_FANFAN_OPERA_TYPE = {
	RA_FANFAN_OPERA_TYPE_QUERY_INFO = 0,		-- 请求活动信息
	RA_FANFAN_OPERA_TYPE_FAN_ONCE = 1,			-- 翻一次牌
	RA_FANFAN_OPERA_TYPE_FAN_ALL = 2,			-- 翻全部牌
	RA_FANFAN_OPERA_TYPE_REFRESH = 3,			-- 重置
	RA_FANFAN_OPERA_TYPE_WORD_EXCHANGE = 4,		-- 字组兑换
	RA_FANFAN_OPERA_TYPE_LEICHOU_EXCHANGE = 5,	-- 累抽兑换

	RA_FANFAN_OPERA_TYPE_MAX = 6,
}

RA_FANFAN_CARD_TYPE = {
	RA_FANFAN_CARD_TYPE_BEGIN = 0,

	RA_FANFAN_CARD_TYPE_HIDDEN = 0,			-- 隐藏卡牌类型
	RA_FANFAN_CARD_TYPE_ITEM_BEGIN = 100,	-- 物品卡牌类型起始值
	RA_FANFAN_CARD_TYPE_WORD_BEGIN = 200,	-- 字组卡牌类型起始值

	RA_FANFAN_CARD_TYPE_MAX = 5,
}

-- 连充特惠
RA_CONTINUE_CHONGZHI_OPERA_TYPE = {
	RA_CONTINUE_CHONGZHI_OPERA_TYPE_QUERY_INFO = 0,			-- 请求活动信息
	RA_CONTINUE_CHONGZHI_OPEAR_TYPE_FETCH_REWARD = 1,		-- 获取奖励
	RA_CONTINUE_CHONGZHI_OPEAR_TYPE_FETCH_EXTRA_REWARD = 2,	-- 获取额外奖励

	RA_CONTINUE_CHONGZHI_OPERA_TYPE_MAX = 3,
}

-- 连消特惠
RA_CONTINUE_CONSUME_OPERA_TYPE = {
	RA_CONTINUME_CONSUME_OPERA_TYPE_QUERY_INFO = 0,						-- 请求活动信息
	RA_CONTINUE_CONSUME_OPEAR_TYPE_FETCH_REWARD = 1,					-- 获取奖励
	RA_CONTINUE_CONSUME_OPEAR_TYPE_FETCH_EXTRA_REWARD = 2,				-- 获取额外奖励
}
-- 公会排行
GUILD_RANK_TYPE = {
	GUILD_RANK_TYPE_CAPABILITY,									-- 仙盟战力榜
	GUILD_RANK_TYPE_GUILDBATTLE = 6,							-- 公会争霸排行榜
	GUILD_RANK_TYPE_KILL_CROSS_BOSS = 8,						-- 击杀神域boss(神域+远古)
}

GUILD_WAR_TYPE = {
	TYPE_INFO_REQ = 0,						-- 请求公会争霸奖励信息
	TYPE_FETCH_REQ = 1,						-- 领取奖励
}

GiftShopBuy2_OPERA_TYPE = {
	GiftShopBuy2_OPERA_TYPE_INFO = 0,				--请求信息，opera_type = 0 
	GiftShopBuy2_OPERA_TYPE_BUY = 1,				--请求购买，opera_type = 1，seq
}

--军歌嘹亮枚举
RA_FLAG_TYPE = {
	RA_ARMY_DAY_ARMYINFO_NUM = 2,
	RA_ARMY_DAY_ARMY_SIDE_NUM = 3,
}

RA_PROMOTING_POSITION_CIRCLE_TYPE ={
	RA_PROMOTING_POSITION_CIRCLE_TYPE_OUTSIDE = 0,     --外圈
	RA_PROMOTING_POSITION_CIRCLE_TYPE_INSIDE = 1,       --内圈
}

RA_PROMOTING_POSITION_OPERA_TYPE ={
	RA_PROMOTING_POSITION_OPERA_TYPE_ALL_INFO = 0,		-- 请求发送协议
	RA_PROMOTING_POSITION_OPERA_TYPE_PLAY = 1,			-- 抽奖
	RA_PROMOTING_POSITION_OPERA_TYPE_MAX = 2,			-- 领取返利奖励
}

RA_FLAG_TYPE_CORPS_SIDE_TYPE = {
	BLUE_ARMY_SIDE = 0,
	RED_ARMY_SIDE = 1,
	YELLOW_ARMY_SIDE = 2,
}

RA_ARMY_DAY_OPERA_TYPE = {
	RA_ARMY_DAY_OPERA_TYPE_INFO = 0,						-- 请求活动信息
	RA_ARMY_DAY_OPERA_TYPE_EXCHANGE_FLAG = 1,				-- 兑换军旗
	RA_ARMY_DAY_OPERA_TYPE_EXCHANGE_ITEM = 2,				-- 兑换物品
}

MULTI_MOUNT_REQ_TYPE = {
	MULTI_MOUNT_REQ_TYPE_SELECT_MOUNT = 0,			-- 选择使用坐骑：param1 坐骑id
	MULTI_MOUNT_REQ_TYPE_UPGRADE = 1,				-- 坐骑进阶：param1 坐骑id
	MULTI_MOUNT_REQ_TYPE_RIDE = 2,					-- 上坐骑
	MULTI_MOUNT_REQ_TYPE_UNRIDE = 3,				-- 下坐骑
	MULTI_MOUNT_REQ_TYPE_INVITE_RIDE = 4,			-- 邀请骑乘：param1 玩家id
	MULTI_MOUNT_REQ_TYPE_INVITE_RIDE_ACK = 5,		-- 回应邀请骑乘：param1 玩家id，param2 是否同意
	MULTI_MOUNT_REQ_TYPE_USE_SPECIAL_IMG = 6,		-- 请求使用幻化形象：param1特殊形象ID
	-- MULTI_MOUNT_REQ_TYPE_UPGRADE_EQUIP = 7,			-- 请求升级坐骑装备：param1 装备类型（下标）
	MULTI_MOUNT_REQ_TYPE_UPLEVEL_SPECIAL_IMG = 7, 	-- 请求升级特殊形象：param1 特殊形象ID
}

MULTI_MOUNT_CHANGE_NOTIFY_TYPE = {
	MULTI_MOUNT_CHANGE_NOTIFY_TYPE_SELECT_MOUNT = 0,					-- 当前使用中的坐骑改变, param1 坐骑id
	MULTI_MOUNT_CHANGE_NOTIFY_TYPE_UPGRADE = 1,							-- 进阶数据改变, param1 坐骑id，param2 阶数，param3 祝福值
	MULTI_MOUNT_CHANGE_NOTIFY_TYPE_INVITE_RIDE = 2,						-- 收到别人坐骑邀请, param1 玩家ID，param2 坐骑ID
	MULTI_MOUNT_CHANGE_NOTIFY_TYPE_ACTIVE_SPECIAL_IMG = 3,				-- 激活双人坐骑特殊形象 param1特殊形象激活标记
	MULTI_MOUNT_CHANGE_NOTIFY_TYPE_USE_SPECIAL_IMG = 4,					-- 使用特殊形象 param1特殊形象id
	MULTI_MOUNT_CHANGR_NOTIFY_TYPE_UPGRADE_EQUIP = 5,					-- 坐骑装备数据改变
	MULTI_MOUNT_CHANGE_NOTIFY_TYPE_UPLEVEL_SPECIAL_IMG = 6,          	-- 升级特殊形象  param1 特殊形象id， param2 特殊形象等级（新增类型）
}

PASTURESPIRIT_REQ_TYPE = {
	PASTURE_SPIRIT_REQ_TYPE_ALL_INFO = 0,							-- 请求所有信息
	PASTURE_SPIRIT_REQ_TYPE_UPGRADE = 1,							-- 请求升级
	PASTURE_SPIRIT_REQ_TYPE_PROMOTE_QUALITY = 2,					-- 请求提示品质
	PASTURE_SPIRIT_REQ_TYPE_AUTO_PROMOTE_QUALITY = 3,				-- 请求一键提示品质
	PASTURE_SPIRIT_REQ_TYPE_FREE_DRAW_ONCE = 4,						-- 请求免费抽一次
	PASTURE_SPIRIT_REQ_TYPE_LUCKY_DRAW_ONCE = 5,					-- 请求抽奖一次
	PASTURE_SPIRIT_REQ_TYPE_LUCKY_DRAW_TIMES = 6,					-- 请求抽奖多次

	PASTURESPIRIT_REQ_TYPE_MAX = 7,
}

CROSS_MIZANG_BOSS_OPERA_TYPE = {
	CROSS_MIZANG_BOSS_OPERA_TYPE_GET_FLUSH_INFO = 0,				-- 刷新信息 param1 层数（为0则为所有层）
	CROSS_MIZANG_BOSS_OPERA_TYPE_BOSS_KILL_RECORD = 1,				-- 击杀记录 param1 层数 param2 boss_id
	CROSS_MIZANG_BOSS_OPERA_TYPE_DROP_RECORD = 2,					-- 掉落记录  
	CROSS_MIZANG_BOSS_OPERA_TYPE_CONCERN_BOSS = 3,					-- 关注boss  param1 层数 param2 boss_id
	CROSS_MIZANG_BOSS_OPERA_TYPE_UNCONCERN_BOSS = 4, 				-- 取消关注boss param1 层数 param2 boss_id
	CROSS_MIZANG_BOSS_OPERA_TYPE_FORENOTICE = 5,					-- boss通知
	CROSS_MIZANG_BOSS_OPERA_TYPE_MAX = 6,
}

CROSS_YOUMING_BOSS_OPERA_TYPE = {
	CROSS_YOUMING_BOSS_OPERA_TYPE_GET_FLUSH_INFO = 0,				-- 刷新信息 param1 层数（为0则为所有层）
	CROSS_YOUMING_BOSS_OPERA_TYPE_BOSS_KILL_RECORD = 1,				-- 击杀记录 param1 层数 param2 boss_id
	CROSS_YOUMING_BOSS_OPERA_TYPE_DROP_RECORD = 2,					-- 掉落记录  
	CROSS_YOUMING_BOSS_OPERA_TYPE_CONCERN_BOSS = 3,					-- 关注boss  param1 层数 param2 boss_id
	CROSS_YOUMING_BOSS_OPERA_TYPE_UNCONCERN_BOSS = 4, 				-- 取消关注boss param1 层数 param2 boss_id
	CROSS_YOUMING_BOSS_OPERA_TYPE_FORENOTICE = 5,					-- boss通知

	CROSS_YOUMING_BOSS_OPERA_TYPE_MAX = 6,
}

--经验药水类型
EXP_BUFF_TYPE = {
	EXP_BUFF_TYPE_INVALID = -1,
	EXP_BUFF_TYPE_1 = 0,
	EXP_BUFF_TYPE_2 = 1,
	EXP_BUFF_TYPE_3 = 2,
	EXP_BUFF_TYPE_4 = 3,
}

--循环充值
RA_CIRCULATION_CHONGZHI_OPERA_TYPE = {
	RA_CIRCULATION_CHONGZHI_OPERA_TYPE_QUERY_INFO = 0,			-- 请求活动信息
	RA_CIRCULATION_CHONGZHI_OPEAR_TYPE_FETCH_REWARD = 1,		-- 获取奖励
	RA_CIRCULATION_CHONGZHI_OPEAR_TYPE_FETCH_EXTRA_REWARD = 2,	-- 获取额外奖励

	RA_CIRCULATION_CHONGZHI_OPERA_TYPE_MAX = 3,
}

-- 抽奖类型
GREATE_SOLDIER_DRAW_TYPE =
{
	GREATE_SOLDIER_DRAW_TYPE_INVALID = 0,

	GREATE_SOLDIER_DRAW_TYPE_1_DRAW = 1,
	GREATE_SOLDIER_DRAW_TYPE_10_DRAW = 2,
	GREATE_SOLDIER_DRAW_TYPE_50_DRAW = 3,

	GREATE_SOLDIER_DRAW_TYPE_SPECIAL_10_DRAW = 10,
	GREATE_SOLDIER_DRAW_TYPE_SPECIAL_50_DRAW = 11,

	GREATE_SOLDIER_DRAW_TYPE_MAX
}
--幸运许愿
RA_LUCKY_WISH_OPERA_TYPE = {
	RA_LUCKY_WISH_OPERA_TYPE_ALL_INFO = 0,			--请求所有信息
	RA_LUCKY_WISH_OPERA_TYPE_WISH = 1,				--许愿  param_1  许愿次数
}

LUCKY_WISH_TYPE = {
	LUCKY_WISH_TYPE_ONLY_LUCKY_VALUE = 0,			--告诉客户端更新幸运值，无视item_id
	LUCKY_WISH_TYPE_COMMON_ITEM = 1,				--抽中普通物品
	LUCKY_WISH_TYPE_LUCKY_ITEM = 2,				--抽中了幸运物品
}

RA_CLOUDPURCHASE_OPERA_TYPE = {
	RA_CLOUDPURCHASE_OPERA_TYPE_INFO = 0,				--请求所有信息（所有物品购买次数、是否开奖）
	RA_CLOUDPURCHASE_OPERA_TYPE_BUY = 1,				--购买请求， param1:购买seq param2:购买次数
	RA_CLOUDPURCHASE_OPERA_TYPE_BUY_RECORD = 2,			--购买记录
	RA_CLOUDPURCHASE_OPERA_TYPE_CONVERT = 3,			--兑换请求(param1: seq, param2: 兑换次数)
	RA_CLOUDPURCHASE_OPERA_TYPE_CONVERT_INFO = 4, 		--兑换信息（积分、兑换相关的信息）
	RA_CLOUDPURCHASE_OPERA_TYPE_SERVER_RECORD_INFO = 5, --全服记录（中奖信息）
}

CHANNEL_TYPE = {
	WORLD = 0,										-- 世界
	CAMP = 1,										-- 阵营
	SCENE = 2,										-- 场景
	TEAM = 3,										-- 队伍
	GUILD = 4,										-- 公会
	PRIVATE = 5,									-- 私聊
	SYSTEM = 6,										-- 系统
	SPEAKER = 8,									-- 喇叭
	CROSS = 9,										-- 跨服
	WORLD_QUESTION = 10,							-- 世界答题
	GUILD_QUESTION = 11,							-- 仙盟答题
	GUILD_SYSTEM = 12,								-- 公会系统

	MAINUI = 99,									-- 主界面
	ALL = 100,										-- 全部
}


RA_GUAGUA_PLAY_MULTI_TYPES =               --刮奖多次的类型
{
  RA_GUAGUA_PLAY_ONE_TIME = 0,                    -- 刮奖1次
  RA_GUAGUA_PLAY_TEN_TIMES = 1,                    -- 刮奖10次
  RA_GUAGUA_PLAY_THIRTY_TIMES = 2,                    -- 刮奖30次
}

--不添加到主界面聊天的频道
NOT_ADD_MAIN_CHANNEL_TYPE = {
	-- [CHANNEL_TYPE.TEAM] = true,
	[CHANNEL_TYPE.GUILD] = true,
	[CHANNEL_TYPE.GUILD_SYSTEM] = true,
	[CHANNEL_TYPE.WORLD_QUESTION] = true,
	[CHANNEL_TYPE.GUILD_QUESTION] = true,
}

-- --不添加到主界面聊天的消息类型
-- NOT_ADD_MAIN_SYS_MSG_TYPE = {
-- 	[SYS_MSG_TYPE.SYS_MSG_CENTER_AND_ROLL] = true,
-- 	[SYS_MSG_TYPE.SYS_MSG_CENTER_NOTICE] = true,
-- 	[SYS_MSG_TYPE.SYS_MSG_CENTER_NOTICE_NOT_CHAT] = true,
-- 	[SYS_MSG_TYPE.SYS_MSG_ONLY_WORLD_QUESTION] = true,
-- 	[SYS_MSG_TYPE.SYS_MSG_ONLY_GUILD_QUESTION] = true,
-- }

-- 添加到主界面聊天信息那显示
ADD_MAIN_SYS_MSG_TYPE = {
	[SYS_MSG_TYPE.SYS_MSG_ONLY_CHAT_WORLD] = true,
	[SYS_MSG_TYPE.SYS_MSG_CENTER_AND_ROLL] = true,
	[SYS_MSG_TYPE.SYS_MSG_CENTER_NOTICE] = true,
}

CHAT_WIN_REQ_TYPE = {
	PERSONALIZE_WINDOW_ALL_INFO = 0,				--个性化窗口信息
	PERSONALIZE_WINDOW_CONSUME_ITEM = 1,
	PERSONALIZE_WINDOW_USE_RIM = 2,
	PERSONALIZE_WINDOW_ACTIVE_BUBBLE_RIM_SUIT = 3,	-- 激活气泡框一个套装部位，参数1套装seq，参数2套装部位part
	PERSONALIZE_WINDOW_ACTIVE_BUBBLE_RIM = 4,		-- 激活气泡框，参数1气泡框seq
	PERSONALIZE_WINDOW_USE_BUBBLE_RIM = 5,			-- 使用气泡框，参数1气泡框seq
}

MAGIC_CARD_REQ_TYPE = {
	MAGIC_CARD_REQ_TYPE_ALL_INFO = 0,						-- 请求所有信息
	MAGIC_CARD_REQ_TYPE_CHOU_CARD = 1,						-- 抽奖，parm1 抽卡类型
	MAGIC_CARD_REQ_TYPE_USE_CARD = 2,						-- 使用魔卡，param1 魔卡id
	MAGIC_CARD_REQ_TYPE_UPGRADE_CARD = 3,					-- 升级魔卡，param1 颜色， param2 卡槽下标， param3 魔卡id
	MAGIC_CARD_REQ_TYPE_EXCHANGE = 4,						-- 魔卡兑换，param1 魔卡id
	MAGIC_CARD_REQ_TYPE_SKILL_ACTIVE = 5,					-- 激活技能
}

MAGIC_CARD = {
	MAGIC_CARD_SLOT_TYPE_LIMIT_COUNT = 4,				-- 魔卡位置最大种类限制
	MAGIC_CARD_MAX_LIMIT_COUNT = 27,					-- 魔卡最大卡牌数量
	MAGIC_CARD_CHOU_CARD_LIMIT_REWARD_COUNT = 16,		-- 魔卡抽卡奖品最大数量
	MAGIC_CARD_LIMIT_STRENGTH_LEVEL_MAX = 10,			-- 魔卡最大强化等级
}

MAGIC_CARD_COLOR_TYPE = {
	MAGIC_CARD_COLOR_TYPE_BLUE = 0,						-- 蓝色
	MAGIC_CARD_COLOR_TYPE_PURPLE = 1,					-- 紫色
	MAGIC_CARD_COLOR_TYPE_ORANGE = 2,					-- 橙色
	MAGIC_CARD_COLOR_TYPE_RED = 3,						-- 红色

	MAGIC_CARD_COLOR_TYPE_COLOR_COUNT = 4,
}

CS_TIAN_XIANG_TYPE = {
	CS_TIAN_XIANG_TYPE_ALL_INFO = 0,        -- 请求所有信息
	CS_TIAN_XIANG_TYPE_CHANGE_BEAD = 1,  	-- 请求改变珠子颜色，p1 = x , p2 = y， p3 = x, p4 = y, p5 = chapter
	CS_TIAN_XIANG_TYPE_XIE_BEAD = 2,  		-- 卸载珠，p1 = x , p2 = y, p3 = chapter
	CS_TIAN_XIANG_TYPE_GUNGUN_LE_REQ = 3,	-- 滚滚乐抽奖 p1： 0是抽1次，1是抽10次
	CS_UNLOCK_REQ = 4,						-- 星座解开锁
	CS_TIAN_XIANG_TYPE_PUT_MIJI = 5,		-- 放秘籍  P1 = 星座类型， p2 = 秘籍index
	CS_TIAN_XIANG_TYPE_CALC_CAPACITY = 6,	-- 放置秘籍成功，重新计算战力
	CS_TIAN_XIANG_TYPE_MIJI_COMPOUND = 7,	-- 秘籍合成 p1：index1
	CS_TIAN_XIANG_PUT_BEAD = 8,				-- 手动放珠子 p1:x, p2:y, p3:type, p4:章节
	CS_TIAN_XIANG_TYPE_XINGLING = 9,		-- 升级星灵
	CS_TIAN_XIANG_UPLEVEL_XINGHUN = 10,		-- 升级星魂 p1:生肖类型, p2:是否自动购买, p3:是否使用保护符
	CS_TIAN_XIANG_TYPE_XINGHUN_UNLOCK = 11,	-- 点击开锁星魂
}

--神话系统类型
MYTH_TYPE = {
	MAX_MYTH_CHAPTER_ID = 16,					--篇章数量
	MAX_MYTH_CHPATER_LEVEL = 8,					--篇章最大等级
	MAX_MYTH_SOUL_SLOT = 3,						--神魂列表
	MAX_MYTH_SOUL_RAND_ATTR_COUNT = 3,			--神魂随机属性
	MAX_MYTH_KNAPSACK_GIRD_COUNT = 100,			--背包数量
}

--神话系统操作类型
MYTH_OPERA_TYPE = {
    MYTH_OPERA_TYPE_INFO = 0,          -- 请求全部信息
    MYTH_OPERA_TYPE_UPLEVEL = 1,       -- 篇章升级 p1: chpater_id
    MYTH_OPERA_TYPE_INLAY = 2,         -- 镶嵌神魂 p1: chpater_id; p2:背包index; p3:格子index
    MYTH_OPERA_TYPE_TAKE_OFF = 3,      -- 取下神魂 p1: chpater_id; p2:格子index
    MYTH_OPERA_TYPE_RESONANCE = 4,     -- 共鸣 p1:chpater_id
    MYTH_OPERA_TYPE_DIGESTION = 5,     -- 领悟 p1:chpater_id
    MYTH_OPERA_TYPE_DECOMPOSE = 6,     -- 萃取 p1:背包index
    MYTH_OPERA_TYPE_COMPOSE = 7,       -- 合成 p1:item_id; p2:背包index1; p3: 背包index2; p4:背包index3
}

--------- 随机活动 至尊幸运-----------------------------
RA_EXTREME_LUCKY_OPERA_TYPE = {
	RA_EXTREME_LUCKY_OPERA_TYPE_QUERY_INFO = 0,         -- 请求活动信息
	RA_EXTREME_LUCKY_OPERA_TYPE_GLOD_FLUSH = 1,                 -- 刷新
	RA_EXTREME_LUCKY_OPERA_TYPE_DRAW = 2,                   -- 抽奖
	RA_EXTREME_LUCKY_OPREA_TYPE_AUTO_FLUSH = 3,             -- 自动刷新(抽完9次)
	RA_EXTREME_LUCKY_OPREA_TYPE_FETCH_REWARD = 4,           -- 领取返利奖励

	RA_EXTREME_LUCKY_OPERA_TYPE_MAX = 5,
}

WUSHANG_EQUIP_REQ_TYPE =
{
	WUSHANG_REQ_TYPE_ALL_INFO = 0,						-- 所有信息请求
	WUSHANG_REQ_TYPE_PUT_ON_EQUIP = 1,					-- 穿装备
	WUSHANG_REQ_TYPE_TAKE_OFF_EQUIP = 2,				-- 脱装备
	WUSHANG_REQ_TYPE_JIFEN_EXCHANGE = 3,				-- 积分兑换
	WUSHANG_REQ_TYPE_STRENGTHEN = 4,					-- 强化
	WUSHANG_REQ_TYPE_UP_STAR = 5,						-- 升星
	WUSHANG_REQ_TYPE_GLORY_EXCHANGE = 6,				-- 荣耀兑换
}

--植树活动
RA_PLANTING_TREE_OPERA_TYPE = {
	RA_PLANTING_TREE_OPERA_TYPE_RANK_INFO = 0,							-- 请求排行榜信息
	RA_PLANTING_TREE_OPERA_TYPE_TREE_INFO = 1,							-- 请求植树信息
	RA_PLANTING_TREE_OPERA_MINI_TYPE_MAP_INFO = 2, 						-- 请求小地图树的信息
}

RA_CRACYBUY_TYPE = {
	RA_CRACYBUY_ALL_INFO = 0,							-- 请求充值信息
	RA_CRACYBUY_LIMIT_INFO = 1,							-- 请求限购信息
	RA_CRACYBUY_BUY = 2,								-- 购买请求 param1:物索引
}

--跨服BOSS
SCCORSS_BOSS_PLAYER_INFO_REASON = {
	SCCORSS_BOSS_PLAYER_INFO_REASON_DEFAULT = 0,
	SCCORSS_BOSS_PLAYER_INFO_REASON_CROSS_REWARD_SYNC = 1,  -- 跨服奖励结算

	SCCORSS_BOSS_PLAYER_INFO_REASON_MAX = 2
}

--至尊寻宝
SUPER_XUNBAO_TIMES = {
	ONE_TIME = 1,
	TEN_TIME = 10,
}

RA_HUANLE_YAOJIANG_OPERA_TYPE = {
	RA_HUANLEYAOJIANG_OPERA_TYPE_QUERY_INFO = 0,     		-- 请求活动信息
	RA_HUANLEYAOJIANG_OPERA_TYPE_TAO = 1,            		-- 淘宝
	RA_HUANLEYAOJIANG_OPERA_TYPE_FETCH_REWARD = 2,        	-- 领取个人累抽奖励 param_1 = 领取奖励的索引（0开始）

	RA_HUANLEYAOJIANG_OPERA_TYPE_MAX = 3,
}

-- 外观-头饰请求
TOUSHI_OPERA_TYPE = {
	TOUSHI_OPERA_TYPE_INFO = 0,						-- 头饰信息	
	TOUSHI_OPERA_TYPE_UPGRADE = 1,					-- 头饰进阶 p1:repeat_times p2:auto_buy
	TOUSHI_OPERA_TYPE_SPECIAL_IMAGE_UPGRADE = 2,	-- 特殊形象进阶 p1:special_image_id
	TOUSHI_OPERA_TYPE_USE_IMAGE = 3,				-- 使用形象 p1:image_id
	TOUSHI_OPERA_TYPE_SKILL_UPGRADE = 4,			-- 技能进阶 p1:skill_idx p2:is_auto_buy
}

-- 外观-面饰请求
MASK_OPERA_TYPE = {
	MASK_OPERA_TYPE_INFO = 0,						-- 面饰信息	
	MASK_OPERA_TYPE_UPGRADE = 1,					-- 进阶 p1:repeat_times p2:auto_buy
	MASK_OPERA_TYPE_SPECIAL_IMAGE_UPGRADE = 2,		-- 特殊形象进阶 p1:special_image_id
	MASK_OPERA_TYPE_USE_IMAGE = 3,					-- 使用形象 p1:image_id
	MASK_OPERA_TYPE_SKILL_UPGRADE = 4,				-- 技能进阶 p1:skill_idx p2:is_auto_buy
}

-- 外观-腰饰请求
YAOSHI_OPERA_TYPE = {
	YAOSHI_OPERA_TYPE_INFO = 0,				 		-- 腰饰信息	
	YAOSHI_OPERA_TYPE_UPGRADE = 1,					-- 进阶 p1:repeat_times p2:auto_buy
	YAOSHI_OPERA_TYPE_SPECIAL_IMAGE_UPGRADE = 2,	-- 特殊形象进阶 p1:special_image_id
	YAOSHI_OPERA_TYPE_USE_IMAGE = 3,				-- 使用形象 p1:image_id
	YAOSHI_OPERA_TYPE_SKILL_UPGRADE = 4,			-- 技能进阶 p1:skill_idx p2:is_auto_buy
}

-- 外观-麒麟臂请求
QILINBI_OPERA_TYPE = {
	QILINBI_OPERA_TYPE_INFO = 0,					-- 麒麟臂信息	
	QILINBI_OPERA_TYPE_UPGRADE = 1,					-- 进阶 p1:repeat_times p2:auto_buy
	QILINBI_OPERA_TYPE_SPECIAL_IMAGE_UPGRADE = 2,	-- 特殊形象进阶 p1:special_image_id
	QILINBI_OPERA_TYPE_USE_IMAGE = 3,				-- 使用形象 p1:image_id
	QILINBI_OPERA_TYPE_SKILL_UPGRADE = 4,			-- 技能进阶 p1:skill_idx p2:is_auto_buy
	QILINBI_OPERA_TYPE_EQUIP_UPGRADE = 5,			-- 装备升级 p1:equip_idx
}

-- 进阶属性丹
SHUXINGDAN_SLOT_TYPE = {
	SHUXINGDAN_SLOT_TYPE_ZIZHI = 0,    				-- 资质丹
	SHUXINGDAN_SLOT_TYPE_CHENGZHANG = 1,  			-- 成长丹
} 

ORIGIN_TYPE = {
	ORIGIN_TYPE_NORMAL_CHAT = 0,					-- 普通聊天
	ORIGIN_TYPE_FALLING_ITEM = 1,					-- 掉落物品后自动发的消息
	GUILD_ADDWAR_CHAT = 2,							-- 群聊仙盟中出系统消息处理
	ORIGIN_TYPE_GUILD_SYSTEM_MSG = 3,				-- 群聊仙盟系统频道系统消息
}


--奖励列表类型
NOTICE_REWARD_TYPE = {
	NOTICE_TYPE_INVAILD = 0,					--无效类型
	NOTICE_TYPE_SHENZHOU_WEAPON = 1,			--魂器
}

CHEST_SHOP_MODE = {									-- 宝箱商店
	CHEST_SHOP_MODE_1 = 1,							-- 极品寻宝抽1次
	CHEST_SHOP_MODE_10 = 2,							-- 极品寻宝抽10次
	CHEST_SHOP_MODE_50 = 3,							-- 极品寻宝抽50次
	CHEST_SHOP_MODE1_1 = 4,							-- 巅峰寻宝抽1次
	CHEST_SHOP_MODE1_10 = 5,						-- 巅峰寻宝抽10次
	CHEST_SHOP_MODE1_30 = 6,						-- 巅峰寻宝抽50次
	CHEST_SHOP_MODE2_1 = 7,							-- 至尊寻宝抽1次
	CHEST_SHOP_MODE2_10 = 8,						-- 至尊寻宝抽10次
	CHEST_SHOP_MODE2_30 = 9,						-- 至尊寻宝抽50次
	CHEST_SHOP_JL_MODE_1 = 10,						-- 精灵抽1次
	CHEST_SHOP_JL_MODE_10 = 11,						-- 精灵抽10次
	CHEST_SHOP_JL_MODE_50 = 12,						-- 精灵抽50次

	CHEST_PET_10 = 16,								-- 小宠物抽奖10次
	CHEST_SWORD_BIND_MODE_1 = 17,					-- 刀剑神域绑钻抽奖1次
	CHEST_SWORD_GOLD_MODE_1 = 18,					-- 刀剑神域钻石抽奖1次
	CHEST_SWORD_GOLD_MODE_10 = 19,					-- 刀剑神域钻石抽奖10次
	CHEST_RUNE_MODE_1 = 20,							-- 符文抽奖1次
	CHEST_RUNE_MODE_10 = 21,						-- 符文抽奖10次
	CHEST_RUNE_BAOXIANG_MODE = 22,					-- 符文宝箱
	CHEST_SHEN_GE_BLESS_MODE_1 = 23,				-- 神格祈福1次
	CHEST_SHEN_GE_BLESS_MODE_10 = 24,				-- 神格祈福10次
	CHEST_ERNIE_BLESS_MODE_1 = 25,					-- 摇奖机摇奖1次
	CHEST_ERNIE_BLESS_MODE_10 = 26,					-- 摇奖机摇奖10次
	CHEST_NORMAL_REWARD_MODE = 27,					-- 通用普通奖励(不需要再来一次的可以用这个类型)
	CHEST_RANK_JINYIN_TA_MODE_1 = 28,				-- 金银塔1次 (六道仙塔)
	CHEST_RANK_JINYIN_TA_MODE_10 = 29,				-- 金银塔10次 (六道仙塔)
	CHEST_RANK_JINYIN_GET_REWARD = 30,				-- 领取累计奖励
	CHEST_RANK_JINYIN_QUICK_REWARD = 31,			-- 精灵家园加速奖励
	CHEST_GUAJITA_REWARD = 32,						-- 符文塔扫荡
	CHEST_RANK_ZHUANZHUANLE_MODE_30 = 33,			-- 转转乐30次
	CHEST_RANK_ZHUANZHUANLE_MODE_1 = 34,			-- 转转乐1次
	CHEST_RANK_ZHUANZHUANLE_GET_REWARD = 35,		-- 领取累积奖励
	CHEST_PUSH_FB_STAR_REWARD = 36,					-- 推图本星星奖励
	CHEST_RANK_FANFANZHUANG_10 = 37,				-- 翻翻转10次
	CHEST_RANK_FANFANZHUANG_50 = 38,				-- 翻翻转50次
	CHEST_RANK_LUCK_CHESS_10 = 39,					-- 幸运棋10次
	HAPPY_RECHARGE_1 = 40,							-- 充值大乐透1次
	HAPPY_RECHARGE_10 = 41,							-- 充值大乐透10次
	LUCKLY_TURNTABLE_GET_REWARD = 42,				-- 转盘抽奖
	WA_BAO = 43, 									-- 挖宝
	CHEST_SYMBOL = 44, 								-- 元素之心
	CHEST_SYMBOL_NIUDAN = 45, 						-- 元素之心扭蛋
	CHEST_HUNQI_BAOZANG_1 = 46,						-- 魂器宝藏开启一次
	CHEST_HUNQI_BAOZANG_10 = 47,					-- 魂器宝藏开启十次
	CHEST_LITTLE_PET_MODE_1 = 48,					-- 小宠物商店1次
	CHEST_LITTLE_PET_MODE_10 = 49,					-- 小宠物商店10次
	
	CHEST_GENERAL_MODE_1 = 50,						-- 变身抽将x次
	CHEST_GENERAL_MODE_10 = 51,						-- 变身抽将x次
	CHEST_GENERAL_MODE_50 = 52,						-- 变身抽将x次
	
	CHEST_LUCKYWISHIN_MODE_1 = 53,					--幸运许愿1次
	CHEST_LUCKYWISHIN_MODE_30 = 54,					--幸运许愿30次

	CHEST_ZHONGQIU_HAPPY_ERNIE_MODE_1 = 60,			--中秋欢乐砸蛋10次
	CHEST_ZHONGQIU_HAPPY_ERNIE_MODE_10 = 61,		--中秋欢乐砸蛋20次
	CHEST_ZHONGQIU_HAPPY_ERNIE_MODE_30 = 62,		--中秋欢乐砸蛋30次

	CHEST_MIJINGXUNBAO3_MODE_1 = 65,				--秘境寻宝抽一次
	CHEST_MIJINGXUNBAO3_MODE_10 = 66,				--秘境寻宝抽十次
	CHEST_MIJINGXUNBAO3_MODE_30 = 67,				--秘境寻宝抽三十次
	CHEST_Weekend_HAPPY_MODE_1 = 68,				--周末狂欢抽1次
	CHEST_Weekend_HAPPY_MODE_10 = 69,				--周末狂欢抽10次
	CHEST_SHOP_MODE_MAX = 70,
	CHEST_HAPPY_ERNIE_MODE_1 = 71, 					--欢乐摇奖一次
	CHEST_HAPPY_ERNIE_MODE_10 = 72, 				--欢乐摇奖十次
	CHEST_HAPPY_ERNIE_MODE_30 = 73, 				--欢乐摇奖三十次
	CHEST_SMALL_HELPER_MODE = 74,					--小助手
	

	CHEST_GuaGuaLe_MODE_1 = 80,						-- 刮刮乐1次
	CHEST_GuaGuaLe_MODE_10 = 81,					-- 刮刮乐10次
	CHEST_GuaGuaLe_MODE_50 = 82,					-- 刮刮乐50次

	CHEST_HAPPYHITEGG_MODE_1 = 83,					--欢乐砸蛋1次
	CHEST_HAPPYHITEGG_MODE_10 = 84,				    --欢乐砸蛋10次
	CHEST_HAPPYHITEGG_MODE_30 = 85,				    --欢乐砸蛋30次

	CHEST_XIAOFEILINGJIANG_MODE_10 = 86,					-- 消费领奖

	TIAN_SHEN_HUTI_BOX_SCORE = 87,					-- 周末装备宝箱积分抽奖
	TIAN_SHEN_HUTI_BOX_GOID_1 = 88,					-- 周末装备宝箱元宝抽奖1次
	TIAN_SHEN_HUTI_BOX_GOID_10 = 89,				-- 周末装备宝箱元宝抽奖10次


	TIAN_SHEN_HUTI_BOX_GET_EQUIP = 1000,			-- 周末装备的合成和转化(自己定义的)
	TIAN_SHEN_HUTI_BOX_GET_EQUIP_ONE_KEY = 1001,	-- 周末装备一键合成(自己定义的)
}

-- 抽奖原因
DRAW_REASON = {
	DRAW_REASON_DEFAULT = 0,
	DRAW_REASON_BEAUTY = 1,			-- 美人抽奖
	DRAW_REASON_GREATE_SOLDIER = 2, -- 名将抽奖
	DRAW_REASON_HAPPY_DRAW = 3 		-- 欢乐抽
}

-- 御魂
MITAMA_REQ_TYPE = {
	MITAMA_REQ_TYPE_ALL_INFO = 0,						-- 请求所有信息
	MITAMA_REQ_TYPE_UPGRADE = 1,						-- 升级御魂
	MITAMA_REQ_TYPE_TASK_FIGHTING = 2,					-- 出征
	MITAMA_REQ_TYPE_TASK_AWARD = 3,						-- 领取出征奖励
	MITAMA_REQ_TYPE_EXCHANGE_ITEM = 4,					-- 兑换物品

	MITAMA_REQ_TYPE_MAX = 5,
}

-- 刀剑神域
CARDZU_REQ_TYPE = {
	CARDZU_REQ_TYPE_CHOU_CARD = 0,										-- 抽卡请求
	CARDZU_REQ_TYPE_HUALING = 1,										-- 化灵请求
	CARDZU_REQ_TYPE_LINGZHU = 2,										-- 灵铸请求
	CARDZU_REQ_TYPE_ACTIVE_ZUHE = 3,									-- 激活卡牌组合
	CARDZU_REQ_TYPE_UPGRADE_ZUHE = 4,									-- 升级卡牌组合
}

--黑市拍卖
RA_BLACK_MARKET_OPERA_TYPE =
{
	RA_BLACK_MARKET_OPERA_TYPE_ALL_INFO = 0, 		-- 请求所有信息
	RA_BLACK_MARKET_OPERA_TYPE_OFFER = 1,			-- 要价

	RA_BLACK_MARKET_OPERA_TYPE_MAX,
}

FAIRY_TREE_REQ_TYPE = {
	FAIRY_TREE_REQ_TYPE_ALL_INFO = 0,
	FAIRY_TREE_REQ_TYPE_FETCH_MONEY_REWARD = 1,			-- 领取在线金钱奖励
	FAIRY_TREE_REQ_TYPE_FETCH_GIFT_REWARD = 2,			-- 领取在线礼包奖励
	FAIRY_TREE_REQ_TYPE_UPLEVEL = 3,					-- 升级
	FAIRY_TREE_REQ_TYPE_UPGRADE = 4,					-- 进阶
	FAIRY_TREE_REQ_TYPE_DRAW_ONCE = 5,					-- 抽奖1次
	FAIRY_TREE_REQ_TYPE_DRAW_TEN_TIMES = 6,				-- 抽奖10次
	FAIRY_TREE_REQ_TYPE_GOLD = 7,						-- 元宝抽
}

MAGIC_EQUIPMENT_REQ_TYPE = {
	MAGIC_EQUIPMENT_REQ_TYPE_UPGRADE = 0,		--吞噬进阶：param1 魔器类型，param2 消耗数量
	MAGIC_EQUIPMENT_REQ_TYPE_STRENGTHEN = 1,	--锻造强化：param1 魔器类型，param2 是否自动强化， param3 是否自动购买
	MAGIC_EQUIPMENT_REQ_TYPE_EMBED = 2,		    --镶嵌魔石：param1 魔器类型，param2 镶嵌孔位，param3 魔石下标（配置里的）
	MAGIC_EQUIPMENT_REQ_TYPE_TAKE_OFF_STONE = 3,--卸下魔石： param1	魔器类型，param2 镶嵌孔位

	MAGIC_EQUIPMENT_REQ_TYPE_MAX = 4,
}

MAGIC_EQUIPMENT_CHANGE_NOTIFY_TYPE = {
	MAGIC_EQUIPMENT_CHANGE_NOTIFY_TYPE_QUALITY_LEVEL = 0,	   -- 品质等级改变：param1 魔器类型，param2 魔器品质等级， param3 吞噬进度
	MAGIC_EQUIPMENT_CHANGE_NOTIFY_TYPE_STRENGTHEN_LEVEL = 1,   -- 锻造等级改变：param1 魔器类型，param2 魔器锻造等级， param3 锻造值（祝福值）
	MAGIC_EQUIPMENT_CHANGE_NOTIFY_TYPE_EMBED = 2,			   -- 镶嵌魔石：param1 魔器类型，param2 魔石孔位， param3 魔石下标（配置里的）
	MAGIC_EQUIPMENT_CHANGE_NOTIFY_TYPE_TAKE_OFF = 3,		   -- 卸下魔石：param1 魔器类型，param2 魔石孔位， param3 魔石下标（配置里的）
}

RA_TREASURES_MALL_OPERA_TYPE = {
		RA_TREASURES_MALL_OPERA_TYPE_REQ_INFO = 0,	-- 珍宝商城所有信息
		RA_TREASURES_MALL_OPERA_TYPE_BUY = 1,		-- 珍宝商城购买
		RA_TREASURES_MALL_OPERA_TYPE_EXCHANGE = 2,	-- 珍宝商城兑换

		RA_TREASURES_MALL_OPERA_TYPE_MAX = 3,
}

CROSS_GOLB_OPERA_TYPE = {
	CROSS_GOAL_INFO_REQ = 0,
    FETCH_CROSS_GOAL_REWARD_REQ = 1,
    FETCH_GUILD_GOAL_REWAED_REQ = 2,
}

--转生装备
ZHUANSHENG_REQ_TYPE =
{
	ZHUANSHENG_REQ_TYPE_ALL_INFO = 0,

	ZHUANSHENG_REQ_TYPE_OTHER_INFO = 2,
	ZHUANSHENG_REQ_TYPE_UPLEVEL = 3,						-- 升级请求
	ZHUANSHENG_REQ_TYPE_CHANGE_XIUWEI = 4,					-- 兑换修为请求
	ZHUANSHENG_REQ_TYPE_TAKE_OFF_EQUIP = 6,					-- 脱装备
}

-- 伤害的飘字类型
FIGHT_TEXT_TYPE =
{
	NORMAL = 0,			-- 普通
	BAOJU = 1,			-- 宝具
	NVSHEN = 2,			-- 女神
	NVSHEN_FAN = 3,  	-- 女神反伤
	NVSHEN_SHA = 4,		-- 女神杀戮

	SHENSHENG = 10,		-- 神圣
}

-- 变身类型
BIANSHEN_EFEECT_APPEARANCE =
{
	APPEARANCE_NORMAL = 0,									-- 正常外观
	APPEARANCE_DATI_XIAOTU = 1,								-- 答题变身卡-小兔
	APPEARANCE_DATI_XIAOZHU = 2,							-- 答题变身卡-小猪
	APPEARANCE_MOJIE_GUAIWU = 3,							-- 魔戒技能-怪物形象
	APPEARANCE_YIZHANDAODI = 4,								-- 一站到底-树人
}

--零元购 请求类型
RA_ZERO_BUY_RETURN_OPERA_TYPE = 
{
	RA_ZERO_BUY_RETURN_OPERA_TYPE_INFO = 0,					-- 请求活动信息
	RA_ZERO_BUY_RETURN_OPERA_TYPE_BUY = 1,					-- 购买 p1购买类型
	RA_ZERO_BUY_RETURN_OPERA_TYPE_FETCH_YUANBAO = 2,		-- 领取元宝 p1购买类型
	RA_ZERO_BUY_RETURN_OPERA_TYPE_MAX = 3,
}

DISCONNECT_NOTICE_TYPE =
{
	INVALID = 0,
	LOGIN_OTHER_PLACE = 1,									-- 玩家在别处登录
	CLIENT_REQ = 2,											-- 客户端请求
}

--锻造
FORGE = {
	MAX_SUIT_EQUIP_PART = 10,
	EQUIPMENT_SUIT_OPERATE_TYPE =
	{
		EQUIPMENT_SUIT_OPERATE_TYPE_INFO_REQ = 1,			-- 信息请求
		EQUIPMENT_SUIT_OPERATE_TYPE_EQUIP_UP = 2,			-- 升级请求
	}
}

-- 坐骑
MOUNT_TYPE = {
	NORMAL_IMAGE = 0,										-- 使用普通形象
	TEMP_IMAGE = 1,											-- 使用临时形象
}

-- 转职
ZHUANZHI_OPERA_TYPE = {
	 ZHUANZHI_OPERA_TYPE_FIRE = 0,					-- 五转 点亮
	 ZHUANZHI_OPERA_TYPE_SIX = 1,
	 ZHUANZHI_OPERA_TYPE_SEVEN = 2,
	 ZHUANZHI_OPERA_TYPE_EIGHT = 3,
	 ZHUANZHI_OPERA_TYPE_NINE = 4,
	 ZHUANZHI_OPERA_TYPE_TEN = 5,					-- 以上转职点亮 参数一  为是否使用经验转职
	 ZHUANZHI_OPERA_TYPE_ONEKEY = 6,				-- 一键转职
	ZHUANZHI_OPERA_TYPE_PERFORM_SKILL = 7,          -- 释放技能 p1:vir_skill_seq p2:target_obj_id
}

ZHUANZHI_TIME = {
	ZHUANZHI_TIME_ONE = 1,
	ZHUANZHI_TIME_TWO = 2,
	ZHUANZHI_TIME_THREE = 3,
	ZHUANZHI_TIME_FOUR = 4,
	ZHUANZHI_TIME_FIVE = 5,
	ZHUANZHI_TIME_SIX = 6,
	ZHUANZHI_TIME_SEVEN = 7,
	ZHUANZHI_TIME_EIGHT = 8,
	ZHUANZHI_TIME_NINE = 9,
	ZHUANZHI_TIME_TEN = 10,
}

--表白墙
PROFESS_WALL_REQ_TYPE = {
	PROFESS_WALL_REQ_INFO = 0,		-- 表白墙信息（p1:0自己 1对方 2公共；p2:时间戳）
	PROFESS_WALL_REQ_LEVEL_INFO = 1,	-- 表白等级信息
	PROFESS_WALL_REQ_DELETE = 2,		-- 删除表白（p1:墙类型；p2:时间戳；p3:角色id） 结果由1145返回，operate为75(OP_DELETE_PROFESS = 75,			// 删除表白)
}

-- 引导副本类型
GUIDE_FB_TYPE = {
	HUSONG = 1,					-- 护送
	GONG_CHENG_ZHAN = 2,		-- 攻城战
	ROBERT_BOSS = 3,			-- 抢BOSS
	BE_ROBERTED_BOSS = 4,		-- 被抢boss
	SHUIJING = 5,				-- 水晶幻境
}

-- 黄金会员
GOLD_VIP_OPERA_TYPE = {
		OPERA_TYPE_ACTIVE = 0,               	-- 激活
		OPERA_TYPE_FETCH_RETURN_REWARD = 1,		-- 领取返还奖励
		OPERA_TYPE_CONVERT_SHOP = 2,            -- 兑换商店

		OPERA_TYPE_MAX = 3,
}

-- 经验炼制
RA_EXP_REFINE_OPERA_TYPE = {
	RA_EXP_REFINE_OPERA_TYPE_BUY_EXP = 0,					-- 炼制
	RA_EXP_REFINE_OPERA_TYPE_FETCH_REWARD_GOLD = 1,			-- 领取炼制红包
	RA_EXP_REFINE_OPERA_TYPE_GET_INFO = 2,					-- 获取信息
}

-- 目标系统
PERSONAL_GOAL_OPERA_TYPE = {
	PERSONAL_GOAL_INFO_REQ = 0,								-- 请求目标信息
	FETCH_PERSONAL_GOAL_REWARD_REQ = 1,						-- 领取个人目标奖励
	FETCH_BATTLE_FIELD_GOAL_REWARD_REQ = 2,					-- 领取集体目标奖励
	FINISH_GOLE_REQ = 3,									-- 完成目标
	UPLEVEL_SKILL = 4,										-- 升级技能
}

--个人塔防buff类型
BUFF_FALLING_APPEARAN_TYPE = {
	NSTF_BUFF_1 = 1,
	NSTF_BUFF_2 = 2,
	NSTF_BUFF_3 = 3,
	NSTF_BUFF_4 = 4,
	YZDD_BUFF = 5,
	}

BUFF_FALLING_APPEARAN_TYPE_EFF = {
	[1] = "DLW_nvshenzhufu",
	[2] = "DLW_nvshenzhiqiang",
	[3] = "DLW_nvshenzhinu",
	[4] = "DLW_nvshenzhidun",
	[5] = "DLW_nvshenzhinu",
}

--符文系统操作参数
RUNE_SYSTEM_REQ_TYPE = {
	RUNE_SYSTEM_REQ_TYPE_ALL_INFO = 0,					-- 请求所有信息
	RUNE_SYSTEM_REQ_TYPE_BAG_ALL_INFO = 1,				-- 请求背包所有信息
	RUNE_SYSTEM_REQ_TYPE_RUNE_GRID_ALL_INFO = 2,		-- 请求符文槽所有信息
	RUNE_SYSTEM_REQ_TYPE_ONE_KEY_DISPOSE = 3,			-- 一键分解		p1 虚拟背包索引
	RUNE_SYSTEM_REQ_TYPE_COMPOSE = 4,					-- 合成			p1 索引1 p2 非零（索引1是背包索引);零（索引1是格子索引）p3 索引2 p4 非零（索引2是背包索引);零（索引2是格子索引）
	RUNE_SYSTEM_REQ_TYPE_SET_RUAN = 5,					-- 装备符文		p1 虚拟背包索引	p2 符文槽格子索引
	RUNE_SYSTEM_REQ_TYPE_XUNBAO_ONE = 6,				-- 寻宝一次
	RUNE_SYSTEM_REQ_TYPE_XUNBAO_TEN = 7,				-- 寻宝十次
	RUNE_SYSTEM_REQ_TYPE_UPLEVEL = 8,					-- 升级符文		p1 符文槽格子索引
	RUNE_SYSTEM_REQ_TYPE_CONVERT = 9,					-- 符文兑换
	RUNE_SYSTEM_REQ_TYPE_OTHER_INFO = 10,				-- 其他信息
	RUNE_SYSTEM_REQ_TYPE_AWAKEN = 11,					-- 符文格觉醒			p1 格子， p2觉醒类型
	RUNE_SYSTEM_REQ_TYPE_AWAKEN_CALC_REQ = 12,			-- 符文格觉醒重算战力
	RUNE_SYSTEM_REQ_TYPE_RAND_ZHILING_SLOT = 13,		-- 随机注灵槽（新增）
	RUNE_SYSTEM_REQ_TYPE_ZHULING = 14,					-- 注灵，参数1 符文格子index
}

RUNE_SYSTEM_AWAKEN_TYPE = {
	RUEN_AWAKEN_TYPE_COMMON = 0,
	RUEN_AWAKEN_TYPE_DIAMOND = 1,
}

--符文系统列表参数
RUNE_SYSTEM_INFO_TYPE = {
	RUNE_SYSTEM_INFO_TYPE_INVAILD = 0,
	RUNE_SYSTEM_INFO_TYPE_ALL_BAG_INFO = 1,				-- 背包全部信息
	RUNE_SYSTEM_INFO_TYPE_RUNE_XUNBAO_INFO = 2,			-- 符文寻宝信息
	RUNE_SYSTEM_INFO_TYPE_OPEN_BOX_INFO = 3,			-- 打开符文宝箱
	RUNE_SYSTEM_INFO_TYPE_CONVERT_INFO = 4,				-- 符文兑换信息
}

--队员进入副本
TeamMemberState = {
	DEFAULT_STAE = 0,				-- 默认状态
	REJECT_STATE = 1,				-- 拒绝进入
	AGREE_STATE = 2,				-- 同意进入
}

FLOAT_VALUE_TYPE = {
	EFFECT_HPSTORE = 0,						-- EffectHpStore抵挡的伤害值
	EFFECT_UP_GRADE_SKILL = 1,				-- 进阶系统技能伤害
	EFFECT_REBOUNDHURT = 2, 				-- 反弹伤害
	EFFECT_RESTORE_HP = 3, 					-- 回血飘字
	EFFECT_NORMAL_HURT = 4, 				-- 通用伤害飘字
	EFFECT_JUST_SPECIAL_EFFECT = 5, 		-- 仅仅播放特效，不需要飘字
}

-- 飘雪附加技能特效
ATTATCH_SKILL_SPECIAL_EFFECT = {
	SPECIAL_EFFECT_NON = 0,
	SPECIAL_EFFECT_THUNDER = 1,				-- 雷电
	SPECIAL_EFFECT_STONE = 2,				-- 陨石
	SPECIAL_EFFECT_FIRE_TORNADO = 3,		-- 火龙卷
	SPECIAL_EFFECT_HAMMER = 4,				-- 雷神锤
	SPECIAL_EFFECT_WATER_TORNADO = 5,		-- 水龙卷
	SPECIAL_EFFECT_SWORD = 6,				-- 剑
	SPECIAL_EFFECT_FOOTPRINT = 7,			-- 足迹装备技能

	SPECIAL_EFFECT_XIANNV_SHENGWU_RESTORE_HP = 20, -- 仙女圣物回血技能
	SPECIAL_EFFECT_XIANNV_SHENGWU_HURT = 21, 	-- 仙女圣物直接伤害技能
	SPECIAL_EFFECT_JINGLING_REBOUNDHURT = 30,	-- 精灵反弹伤害
	SPECIAL_EFFECT_REBOUNDHURT = 40, 			-- 反弹伤害

	SPECIAL_EFFECT_MAX = 41,
}

AUTHORITY_TYPE = {
	INVALID = 0, 									-- 无任何权限
	GUIDER = 1, 									-- 新手指导员
	GM = 2, 										-- GM
	TEST = 3, 										-- 测试账号（内部号）
}

-- 这里面key与上面的类型对应
ATTATCH_SKILL_SPECIAL_EFFECT_RES = {
	[1] = "juese_jinlei_T",
	[2] = "tongyong_yunsi",
	[3] = "Boss_lqf",
	[4] = "T_zjjn_shuilonjuan",
	[5] = "T_zjjn_jian",
	[6] = "tongyong_leishenchui",
	[7] = "T_zjjn_shuilonjuan",
	[20] = "Buff_nvshenzhufu",
	[21] = "Effect_daji",
	[30] = "Effect_fantanhudun",
	[40] = "Effect_fantan",
}

-- 聚宝盆
RA_CORNUCOPIA_OPERA_TYPE = {
	RA_CORNUCOPIA_OPERA_TYPE_QUERY_INFO = 0,
	RA_CORNUCOPIA_OPERA_TYPE_FETCH_REWARD = 1,
	RA_CORNUCOPIA_OPERA_TYPE_FETCH_REWARD_INFO = 2,
}

-- 温泉技能类型
HOTSPRING_SKILL_TYPE = {
	HOTSPRING_SKILL_MASSAGE = 1,			-- 搓背
	HOTSPRING_SKILL_THROW_SNOWBALL = 2,		-- 扔雪球
}


-- 虚拟技能
VIRTUAL_SKILL_TYPE = {
	THROW_SNOW_BALL = 10001,				-- 温泉扔雪球
}

--好友祝贺消息类型
SC_FRIEND_HELI_REQ_YTPE = {
	SC_FRIEND_HELI_UPLEVEL_REQ = 0,					-- 升级贺礼          p1 = level
	SC_FRIEND_HELI_SKILL_BOSS_FETCH_EQUI_REQ = 1,	-- 杀boss获得好装备，p1 = bossid , p2 = 装备id
}

--好友祝贺送礼类型
CONGRATULATION_TYPE = {
	EGG = 1,
	FLOWER = 2,
}

-- 婚礼祝福
MARRY_ZHUHE_TYPE = {
	MARRY_ZHUHE_TYPE0 = 0,						-- 祝福
	MARRY_ZHUHE_TYPE1 = 1,						-- 送花
}

--仙阵魂玉类型
HUNYU_TYPE = {
	LIFE_HUNYU = 0,
	ATTACK_HUNYU = 1,
	DEFENSE_HUNYU = 2
}

--仙阵提升界面选择
SPIRITPROMOTETAB_TYPE = {
	TABXIANZHEN = 1,
	TABHUNYU = 2
}

-- 温泉动作
HOTSPRING_ACTION_TYPE = {
	SHUANG_XIU = 1,						-- 双修
	MASSAGE = 2,						-- 按摩
}

--元宝转盘
Yuan_Bao_Zhuanpan_OPERATE_TYPE = {
	SET_JC_ZhUANSHI_NUM = 0,		--SC请求CS发送奖池砖石数量
	CHOU_JIANG = 1,					--SC抽奖时发的协议
}

GUILD_MAZE_OPERATE_TYPE = {
	GUILD_MAZE_OPERATE_TYPE_GET_INFO = 0,		-- 请求信息
	GUILD_MAZE_OPERATE_TYPE_SELECT = 1,      	-- 选门
}

MYSTERIOUSSHOP_IN_MALL_OPERATE_TYPE = {
	OPERATE_TYPE_MONEY = 0,
	OPERATE_REQ = 2,
	OPERATE_TYPE_REFRESH = 1,
	OPERATE_OPEN_VIEW = 3,
}

-- 公会迷宫通知原因
GUILD_MAZE_INFO_REASON = {
	GUILD_MAZE_INFO_REASON_DEF = 0,
	GUILD_MAZE_INFO_REASON_FIRST_SUCC = 1,
	GUILD_MAZE_INFO_REASON_SUCC = 2,
	GUILD_MAZE_INFO_REASON_FAIL = 3,
}

--连充特惠
RA_CONTINUE_CHONGZHI_OPERA_TYPE = {

		RA_CONTINUE_CHONGZHI_OPERA_TYPE_QUERY_INFO = 0,		-- 请求活动信息
		RA_CONTINUE_CHONGZHI_OPEAR_TYPE_FETCH_REWARD = 1,		-- 获取奖励

		RA_CONTINUE_CHONGZHI_OPERA_TYPE_MAX = 2,
}

--限时豪礼活动
RA_TIMELIMIT_LUXURY_GIFT_BAG_OPERA_TYPE = {
	RA_TIMELIMIT_LUXURY_GIFT_BAG_OPERA_TYPE_QUERY_INFO = 0,			--请求物品的信息
	RA_TIMELIMIT_LUXURY_GIFT_BAG_OPERA_TYPE_BUY = 1,			    --请求购买的信息
}

--普天同庆活动
RA_REST_DOUBLE_CHATGE_OPERA_TYPE = {
	RA_RESET_DOUBLE_CHONGZHI_OPERA_TYPE_INFO = 0,			--请求物品的信息
 }

--金猪召唤
GOLDEN_PIG_OPERATE_TYPE = {
	GOLDEN_PIG_OPERATE_TYPE_REQ_INFO = 0,				--请求信息
	GOLDEN_PIG_OPERATE_TYPE_SUMMON = 1,					--召唤
}

GOLDEN_PIG_SUMMON_TYPE = {
	GOLDEN_PIG_SUMMON_TYPE_JUNIOR = 0,					-- 初级召唤
	GOLDEN_PIG_SUMMON_TYPE_MEDIUM = 1,					-- 中级召唤
	GOLDEN_PIG_SUMMON_TYPE_SENIOR = 2,					-- 高级召唤
}

JING_LING_HOME_OPER_TYPE = {
	JING_LING_HOME_OPER_TYPE_GET_INFO = 0,		-- 查询信息, 参数1 人物ID
	JING_LING_HOME_OPER_TYPE_PUT_HOME = 1,		-- 放入家园 param1 精灵索引，param2 家园索引
	JING_LING_HOME_OPER_TYPE_QUICK = 2,			-- 加快速度 param1 家园索引
	JING_LING_HOME_OPER_TYPE_GET_REWARD = 3,		-- 领取奖励 param1 家园索引
	JING_LING_HOME_OPER_TYPE_ROB = 4,			-- 掠夺 param1 精灵索引，param2 家园索引
	JING_LING_HOME_OPER_TYPE_OUT = 5, 			-- 取出, param1 家园索引
	JING_LING_HOME_OPER_TYPE_REFRESH_LIST = 6, 				-- 刷新列表
	JING_LING_HOME_OPER_TYPE_READ_ROB_RECORD = 7, -- 阅读被掠夺记录
}

----------------------天天返利-------------------------
DAY_CHONGZHI_REWARD_OPERA_TYPE = {
	DAY_CHONGZHI_REWARD_OPERA_TYPE_QUERY_INFO = 0,				--  请求信息
	DAY_CHONGZHI_REWARD_OPERA_TYPE_FETCH_REWARD = 1,			--  请求领取奖励	param_0  =  索引
	DAY_CHONGZHI_REWARD_OPERA_TYPE_FETCH_RARE_REWARD = 2,		--  请求领取珍稀奖励	param_0  =  索引
}
----------------------天天返利END----------------------


JING_LING_HOME_REASON = {
	JING_LING_HOME_REASON_DEF = 0,
	JING_LING_HOME_REASON_PUT = 1,
	JING_LING_HOME_REASON_QUICK = 2,
	JING_LING_HOME_REASON_GET_REWARD = 3,
	JING_LING_HOME_REASON_ROB_WIN = 4,
	JING_LING_HOME_REASON_ROB_LOST = 5,
}

--顶刮刮
RA_GUAGUA_OPERA_TYPE = {
	RA_GUAGUA_OPERA_TYPE_QUERY_INFO = 0,					-- 请求活动的信息
	RA_GUAGUA_OPERA_TYPE_PLAY_TIMES = 1,						-- 刮奖多次
	RA_GUAGUA_OPREA_TYPE_FETCH_REWARD = 2,
	RA_GUAGUA_OPERA_TYPE_MAX = 3,
}

SKIP_TYPE = {
	SKIP_TYPE_CHALLENGE = 0,						--决斗场，附近的人
	SKIP_TYPE_SAILING = 1,							--决斗场，航海
	SKIP_TYPE_MINE = 2,								--决斗场，挖矿
	SKIP_TYPE_FISH = 3,								--捕鱼
	SKIP_TYPE_JINGLING_ADVANTAGE = 4,				--精灵奇遇
	SKIP_TYPE_SHENZHOU_WEAPON = 5,					--上古遗迹
	SKIP_TYPE_XINGZUOYIJI = 6,						--星座遗迹
	SKIP_TYPE_QYSD = 7,								--情缘圣地
	SKIP_TYPE_PRECIOUS_BOSS = 8,					--秘藏boss
	SKIP_TYPE_PAOHUAN_TASK = 9,						--跑环任务
	SKIP_TYPE_CROSS_GUIDE = 10,						--跨服争霸
}

JING_LING_HOME_STATE = {
	MY = 0,
	OTHER = 1,
	MY_IN_OTHER = 2,
}

JING_LING_HOME_SEND_STATE = {
	SEND = 0,
	REPLACE = 1,
	TAKE_BACK = 2,
}

JL_EXPLORE_OPER_TYPE = {
	JL_EXPLORE_OPER_TYPE_SELECT_MODE = 0,		-- 选择模式, param1 模式 0简单 1普通 2困难
	JL_EXPLORE_OPER_TYPE_EXPLORE = 1,			-- 挑战
	JL_EXPLORE_OPER_TYPE_FETCH = 2,				-- 领取奖励, param1 关卡 0~5
	JL_EXPLORE_OPER_TYPE_RESET = 3,				-- 重置挑战
	JL_EXPLORE_OPER_TYPE_BUY_BUFF = 4, 			-- 购买BUFF
}

JL_EXPLORE_INFO_REASON = {
	JL_EXPLORE_INFO_REASON_DEF = 0,
	JL_EXPLORE_INFO_REASON_SELECT = 1,
	JL_EXPLORE_INFO_REASON_CHALLENGE_SUCC = 2,
	JL_EXPLORE_INFO_REASON_CHALLENGE_FAIL = 3,
	JL_EXPLORE_INFO_REASON_FETCH = 4,
	JL_EXPLORE_INFO_REASON_RESET = 5,
	JL_EXPLORE_INFO_REASON_BUY_BUFF = 6,
}

RA_CHONGZHI_MONEY_TREE_OPERA_TYPE ={
	RA_MONEY_TREE_OPERA_TYPE_QUERY_INFO = 0,			-- 请求活动信息
	RA_MONEY_TREE_OPERA_TYPE_CHOU = 1,						--抽奖：param_1 次数
	RA_MONEY_TREE_OPERA_TYPE_FETCH_REWARD = 2,				-- 领取全服奖励：param_1 seq
	RA_MONEY_TREE_OPERA_TYPE_MAX = 3,
}

SPIRIT_FIGHT_TYPE = {
	HOME = 0,
	EXPLORE = 1,
}

MiningChallengeType = {
	CHALLENGE_TYPE_NONE = 0,
	CHALLENGE_TYPE_MINING_ROB = 1,						-- 挖矿抢劫玩家，	param1 对手UID
	CHALLENGE_TYPE_MINING_ROB_ROBOT = 2,				-- 挖矿抢劫机器人，	param1 机器人index
	CHALLENGE_TYPE_MINING_REVENGE = 3,					-- 挖矿复仇，		param1 对手UID，param2 对应抢劫列表index
	CHALLENGE_TYPE_SAILING_ROB = 4,						-- 航海抢劫玩家，	param1 对手UID
	CHALLENGE_TYPE_SAILING_ROB_ROBOT = 5,				-- 航海抢劫机器人，	param1 机器人index
	CHALLENGE_TYPE_SAILING_REVENGE = 6,					-- 航海复仇，		param1 对手UID，param2 对应抢劫列表index
	CHALLENGE_TYPE_FIGHTING = 7,						-- 挑衅对战，		param1 对手下标
}

FUBEN_SCENE_ID ={
	SHUIJING = 1500,   --水晶
}

CHAT_OPENLEVEL_LIMIT_TYPE = {
	WORLD = 0,
	CAMP = 1,
	SCENE = 2,
	TEAM = 3,
	GUILD = 4,
	SINGLE = 5,
	SEND_MAIL = 6,
	SPEAKER = 7,
	
	MAX = 8,
}

RA_DAY_ACTIVE_DEGREE_OPERA_TYPE = {
	RA_DAY_ACTIVE_DEGREE_OPERA_TYPE_QUERY_INFO = 0,		-- 查询信息
	RA_DAY_ACTIVE_DEGREE_OPERA_TYPE_FETCH_REWARD = 1,	-- 领取奖励 param1,reward_seq
}

--新累计充值
RA_NEW_TOTAL_CHARGE_OPERA_TYPE ={
	RA_NEW_TOTAL_CHARGE_OPERA_TYPE_QUERY_INFO = 0,
	RA_NEW_TOTAL_CHARGE_OPERA_TYPE_FETCH_REWARD = 1,

	RA_NEW_TOTAL_CHARGE_OPERA_TYPE_MAX = 2,
}

--幻装商城
RA_HUANZHUANG_SHOP_TYPE =
{
	TITLE_SHOP_TYPE = 0;
	HUANZHUANG_SHOP_TYPE = 1;
}
--你充我送
CHONGZHI_GIFT_OPER_TYPE = 
{
   CHONGZHI_GIFT_OPER_TYPE_INFO = 0,               	--信息
   CHONGZHI_GIFT_OPER_TYPE_FETCH = 1,               --领取奖励
}
--情缘圣地
QYSD_OPERA_TYPE =
{
	QYSD_OPERA_TYPE_FETCH_TASK_REWARD = 0,				-- 领取任务奖励，param -> 任务索引
	QYSD_OPERA_TYPE_FETCH_OTHER_REWARD = 1,				-- 领取额外奖励
}

--欢乐砸蛋
RA_HUANLEZADAN_CHOU_TYPE =                            -- 淘宝类型
{
	RA_HUANLEZADAN_CHOU_TYPE_1 = 0,					-- 淘宝一次
	RA_HUANLEZADAN_CHOU_TYPE_10 = 1,				-- 淘宝十次
	RA_HUANLEZADAN_CHOU_TYPE_30 = 2,				-- 淘宝三十次
	RA_HUANLEZADAN_CHOU_TYPE_MAX = 3,
}

--欢乐砸蛋
RA_HUANLEZADAN_OPERA_TYPE =
{
	RA_HUANLEZADAN_OPERA_TYPE_QUERY_INFO = 0,					-- 请求活动信息
	RA_HUANLEZADAN_OPERA_TYPE_TAO = 1,							-- 淘宝
	RA_HUANLEZADAN_OPERA_TYPE_FETCH_REWARD = 2,					-- 领取个人累抽奖励 param_1 = 领取奖励的索引（0开始）
	RA_HUANLEZADAN_OPERA_TYPE_MAX = 3,
}

-- -- 秘境寻宝

RA_MIJINGXUNBAO3_OPERA_TYPE = {								-- 秘境寻宝
	RA_MIJINGXUNBAO3_OPERA_TYPE_QUERY_INFO = 0,				-- 请求活动信息
	RA_MIJINGXUNBAO3_OPERA_TYPE_TAO = 1,					-- 寻宝
	RA_MIJINGXUNBAO3_OPERA_TYPE_FETCH_REWARD = 2,			-- 领取个人累抽奖励 param_1 = 领取奖励的索引（0开始）
	RA_MIJINGXUNBAO3_OPERA_TYPE_MAX = 3,
}

RA_MIJINGXUNBAO3_CHOU_TYPE = {						-- 秘境寻宝
	RA_MIJINGXUNBAO3_CHOU_TYPE_1 = 0,				-- 寻宝一次
	RA_MIJINGXUNBAO3_CHOU_TYPE_10 = 1,				-- 寻宝十次
	RA_MIJINGXUNBAO3_CHOU_TYPE_30 = 2,				-- 寻宝三十次
	RA_MIJINGXUNBAO3_CHOU_TYPE_MAX = 3,
}
-- RA_MIJINGXUNBAO_OPERA_TYPE = {
-- 		RA_MIJINGXUNBAO_OPERA_TYPE_QUERY_INFO = 0,				-- 请求活动信息
-- 		RA_MIJINGXUNBAO_OPERA_TYPE_TAO = 1,							-- 淘宝
-- 		RA_MIJINGXUNBAO_OPERA_TYPE_MAX = 2,
-- }

-- RA_MIJINGXUNBAO_CHOU_TYPE = {
-- 		RA_MIJINGXUNBAO_CHOU_TYPE_1 = 0,				-- 淘宝一次
-- 		RA_MIJINGXUNBAO_CHOU_TYPE_10 = 1,				-- 淘宝十次
-- 		RA_MIJINGXUNBAO_CHOU_TYPE_50 = 2,				-- 淘宝五十次
-- 		RA_MIJINGXUNBAO_CHOU_TYPE_MAX = 3,
-- }

-- 欢乐摇奖
RA_HAPPYERNIE_CHOU_TYPE = {
		RA_HAPPYERNIE_CHOU_TYPE_1 = 0,				-- 淘宝一次
		RA_HAPPYERNIE_CHOU_TYPE_10 = 1,				-- 淘宝十次
		RA_HAPPYERNIE_CHOU_TYPE_30 = 2,				-- 淘宝三十次
}

-- --极品宝塔
-- RA_LIGHT_TOWER_EXPLORE_OPERA_TYPE = {
-- 	RA_LIGHT_TOWER_EXPLORE_OPERA_TYPE_INFO = 0,						--请求所有信息
-- 	RA_LIGHT_TOWER_EXPLORE_OPERA_TYPE_DRAW = 1,						--抽奖
-- 	RA_LIGHT_TOWER_EXPLORE_OPERA_TYPE_FETCH_EXTERN_REWARD = 2,		--拿取层额外奖励
-- 	RA_LIGHT_TOWER_EXPLORE_OPERA_TYPE_FETCH_SERVER_REWARD = 3,		--拿取返利奖励

-- 	RA_LIGHT_TOWER_EXPLORE_OPERA_TYPE_MAX = 4
-- }

-- 单笔充值2（单返豪礼）
RA_SINGLE_CHONGZHI_OPERA_TYPE =
{
	RA_SINGLE_CHONGZHI_OPERA_TYPE_INFO = 0,				-- 请求信息
	RA_SINGLE_CHONGZHI_OPERA_TYPE_FETCH_REWARD = 1,		-- 领取奖励

	RA_SINGLE_CHONGZHI_OPERA_TYPE_MAX = 2,
}

FOOTPRINT_OPERATE_TYPE = {
	FOOTPRINT_OPERATE_TYPE_INFO_REQ = 0,			-- 请求信息
	FOOTPRINT_OPERATE_TYPE_UP_GRADE = 1,			-- 请求进阶 param_1=>repeat_times  param_2=>auto_buy
	FOOTPRINT_OPERATE_TYPE_USE_IMAGE = 2,			-- 请求使用形象 param_1=>image_id
	FOOTPRINT_OPERATE_TYPE_UP_LEVEL_EQUIP = 3,		-- 请求升级装备 param_1=>equip_idx
	FOOTPRINT_OPERATE_TYPE_UP_STAR = 4,				-- 请求升星 param_1=>stuff_index param_2=>is_auto_buy param_3=>loop_times
	FOOTPRINT_OPERATE_TYPE_UP_LEVEL_SKILL = 5,		-- 请求升级技能 param_1=>skill_idx param_2=>auto_buy
	FOOTPRINT_OPERATE_TYPE_UP_SPECIAL_IMAGE = 6,	-- 请求升特殊形象进阶 param_1=>special_image_id
}

-- 神兽
SHENSHOU_REQ_TYPE ={
	SHENSHOU_REQ_TYPE_ALL_INFO = 0,					-- 请求所有信息
	SHENSHOU_REQ_TYPE_PUT_ON = 1,					-- 装备， param1 背包格子index，param2 神兽ID, param3 装备槽格子index
	SHENSHOU_REQ_TYPE_TAKE_OFF = 2,					-- 卸下， param1 神兽ID, param2 装备槽index
	SHENSHOU_REQ_TYPE_ZHUZHAN = 3,					-- 助战， param1 神兽ID，
	SHENSHOU_REQ_TYPE_ADD_ZHUZHAN = 4,				-- 扩展神兽助战位
	SHENSHOU_REQ_TYPE_COMPOSE = 5,					-- 合成， param_1 物品id ，param_2 背包格子index1 ，param_3 背包格子index2，param_4 背包格子index3

	SHENSHOU_REQ_TYPE_HUANLING_INFO = 6,			-- 请求唤灵信息,服务器发送2565
	SHENSHOU_REQ_TYPE_HUANLING_REFRESH = 7,			-- 唤灵刷新
	SHENSHOU_REQ_TYPE_HUANLING_DRAW = 8,			-- 唤灵抽奖
}

GUILD_SINGIN_REQ_TYPE = {
	GUILD_SINGIN_REQ_TYPE_SIGNIN = 0,               	-- 签到
	GUILD_SINGIN_REQ_TYPE_FETCH_REWARD = 1,             -- 拿奖励 p1 index
	GUILD_SINGIN_REQ_ALL_INFO = 2,                  	-- 请求所有信息
}

local UnityEngine_Animator = UnityEngine.Animator
ANIMATOR_PARAM = {
	STATUS = UnityEngine_Animator.StringToHash("status"),
	ATTACK1 = UnityEngine_Animator.StringToHash("attack1"),
	ATTACK2 = UnityEngine_Animator.StringToHash("attack2"),
	COMBO1_1 = UnityEngine_Animator.StringToHash("combo1_1"),
	COMBO1_2 = UnityEngine_Animator.StringToHash("combo1_2"),
	COMBO1_3 = UnityEngine_Animator.StringToHash("combo1_3"),
	HURT = UnityEngine_Animator.StringToHash("hurt"),
	REST = UnityEngine_Animator.StringToHash("rest"),
	REST1 = UnityEngine_Animator.StringToHash("rest1"),
	BJ_REST = UnityEngine_Animator.StringToHash("bj_rest"),
	SHOW = UnityEngine_Animator.StringToHash("show"),
	FIGHT = UnityEngine_Animator.StringToHash("fight"),
	COMBO1_1_BACK = UnityEngine_Animator.StringToHash("combo1_1_back"),
	COMBO1_2_BACK = UnityEngine_Animator.StringToHash("combo1_2_back"),
	COMBO1_3_BACK = UnityEngine_Animator.StringToHash("combo1_3_back"),

	SWIMMING_LAYER = 2,
	SWIMMINGACTION_LAYER = 3,

	BASE_LAYER = 0,
	FLY_LAYER = 1,
	MOUNT_LAYER = 2,
	FIGHTMOUNT_LAYER = 3,
	ACTION_LAYER = 4,
	DEATH_LAYER = 5,
	FISH_LAYER = 6,
	DANCE1_LAYER = 7,
	DANCE2_LAYER = 8,
	DANCE3_LAYER = 9,
	CHONGCI_LAYER = 10,
	MOUNT_LAYER2 = 11,
}

CLOAK_OPERATE_TYPE = {
	CLOAK_OPERATE_TYPE_INFO_REQ = 0,				-- 请求信息
	CLOAK_OPERATE_TYPE_UP_LEVEL = 1,				-- 请求升级 param_1=>stuff_index param_2=>is_auto_buy param_3=>loop_times
	CLOAK_OPERATE_TYPE_USE_IMAGE = 2,				-- 请求使用形象 param_1=>image_id
	CLOAK_OPERATE_TYPE_UP_SPECIAL_IMAGE = 3,		-- 请求升特殊形象进阶 param_1=>special_image_id
	CLOAK_OPERATE_TYPE_UP_LEVEL_EQUIP = 4,			-- 请求升级装备 param_1=>equip_idx
	CLOAK_OPERATE_TYPE_UP_LEVEL_SKILL = 5,			-- 请求升级技能 param_1=>skill_idx param_2=>auto_buy
}

-- 名将请求类型
GREATE_SOLDIER_REQ_TYPE =
{
	GREATE_SOLDIER_REQ_TYPE_INFO = 0,						-- 请求所有信息
	GREATE_SOLDIER_REQ_TYPE_LEVEL_UP = 1,					-- 升级请求，param1是seq
	GREATE_SOLDIER_REQ_TYPE_BIANSHEN = 2,					-- 变身请求
	GREATE_SOLDIER_REQ_TYPE_WASH = 3,						-- 洗练请求，param1是seq
	GREATE_SOLDIER_REQ_TYPE_PUTON = 4,						-- 装上将位请求，param1是名将seq，param2是将位槽seq
	GREATE_SOLDIER_REQ_TYPE_PUTOFF = 5,						-- 卸下将位请求，param1是将位槽seq
	GREATE_SOLDIER_REQ_TYPE_SLOT_LEVEL_UP = 6,				-- 升级将位请求，param1是将位槽seq,param2是次数
	GREATE_SOLDIER_REQ_TYPE_DRAW = 7,						-- 抽奖请求，param1是抽奖类型 param2是否自动购买 是:否 1:0
	GRAETE_SOLDIER_REQ_TYPE_CONFIRM_WASH = 8,				-- 确认洗练结果，param1是seq
	GRAETE_SOLDIER_REQ_TYPE_WASH_ATTR = 9,					-- 洗练属性请求，param1是seq
	GRAETE_SOLDIER_REQ_TYPE_BIANSHEN_TRIAL = 10,			-- 变身体验请求，param1是seq
	GRAETE_SOLDIER_REQ_TYPE_FETCH_REWARD = 11,				-- 名将抽奖累计领取，param1是seq
	GRAETE_SOLDIER_REQ_TYPE_FETCH_GOAL_REWARD = 12,			-- 领取目标奖励，param1是目标类型
	GRAETE_SOLDIER_REQ_TYPE_BUY_GOAL_REWARD = 13, 			-- 购买目标奖励，param1是目标类型
	GREATE_SOLDIER_REQ_TYPE_USE_HUANHUA_ID = 14,			-- 使用幻化形象，param1是形象ID
	GREATE_SOLDIER_REQ_TYPE_EXCHANGE = 15,					-- 名将兑换，param1是名将seq
	GREATE_SOLDIER_REQ_TYPE_PUTOFF_EQUIPMENT = 16,    		-- 卸下装备，param1是名将seq，param2是装备槽seq

	GREATE_SOLDIER_REQ_TYPE_MAX,
}

RA_CHARGE_REPAYMENT_OPERA_TYPE ={
	RA_CHARGE_REPAYMENT_OPERA_TYPE_QUERY_INFO = 0,		--请求信息
	RA_CHARGE_REPAYMENT_OPERA_TYPE_FETCH_REWARD = 1,	--领取奖励
	RA_CHARGE_REPAYMENT_OPERA_TYPE_MAX = 2,
}

ADVANCE_FULING_TYPE = {
	MOUNT = 1,
	WING = 2,
	Foot = 3,
	HALO = 4,
	FIGHT_MOUNT = 5,
	SHEN_BING = 6,
	CLOAK = 7,
}

RA_SERVER_PANIC_BUY_OPERA_TYPE = {
	RA_SERVER_PANIC_BUY_OPERA_TYPE_QUERY_INFO = 0,
	RA_SERVER_PANIC_BUY_OPERA_TYPE_BUY_ITEM = 1,

	RA_SERVER_PANIC_BUY_OPERA_TYPE_MAX = 2,
}


COMBINE_SERVER_ACTIVITY_SUB_TYPE = {
	CSA_SUB_TYPE_INVALID  =  0,
	CSA_SUB_TYPE_RANK_QIANGGOU = 1,	    				--  抢购
	CSA_SUB_TYPE_ROLL = 2,	     						--  转盘
	CSA_SUB_TYPE_GONGCHENGZHAN = 3,	    				--  攻城战
	CSA_SUB_TYPE_XIANMENGZHAN = 4,	    				--  仙盟战  				-- 暂时无用
	CSA_SUB_TYPE_CHONGZHI_RANK = 5,	    				--  充值排行
	CSA_SUB_TYPE_CONSUME_RANK = 6,	    				--  消费排行
	CSA_SUB_TYPE_KILL_BOSS = 7,	   						--  击杀boss
	CSA_SUB_TYPE_SINGLE_CHARGE = 8,	      				--  单笔充值
	CSA_SUB_TYPE_LOGIN_Gift = 9,	      				--  登录奖励
	CSA_SUB_TYPE_PERSONAL_PANIC_BUY = 10,	      		--  个人抢购
	CSA_SUB_TYPE_SERVER_PANIC_BUY = 11,	      			--  全服抢购
	CSA_SUB_TYPE_ZHANCHANG_FANBEI = 12,	      			--  战场翻倍
	CSA_SUB_TYPE_CHARGE_REWARD_DOUBLE = 13,	      		--  充值双倍返利
	CSA_SUB_TYPE_BOSS = 14,								--  合服boss
	CSA_SUB_TYPE_TOUZI = 15,							--  合服投资
	CSA_SUB_TYPE_JIJIN = 16, 							--	合服基金
	CSA_SUB_TYPE_BUYEXP = 17,							--	经验购买
	CSA_SUB_TYPE_MAX = 18,
}

CSA_LOGIN_GIFT_OPERA = {
	CSA_LOGIN_GIFT_OPERA_FETCH_COMMON_REWARD = 0,				-- 普通奖励
	CSA_LOGIN_GIFT_OPERA_FETCH_VIP_REWARD = 1,					-- vip奖励
	CSA_LOGIN_GIFT_OPERA_FETCH_ACCUMULATE_REWARD = 2,			-- 累计登录奖励

	CSA_LOGIN_GIFT_OPERA_MAX,
}

IMG_FULING_JINGJIE_TYPE = {
	IMG_FULING_JINGJIE_TYPE_MOUNT  =  0,			--坐骑
	IMG_FULING_JINGJIE_TYPE_WING  =  1,				--羽翼
	IMG_FULING_JINGJIE_TYPE_HALO  =  2,				--光环
	IMG_FULING_JINGJIE_TYPE_FIGHT_MOUNT  =  3,		--魔骑
	IMG_FULING_JINGJIE_TYPE_SHENGONG  =  4,			--神弓(时装)
	IMG_FULING_JINGJIE_TYPE_SHENYI  =  5,			--神翼(神兵)
	IMG_FULING_JINGJIE_TYPE_FOOT_PRINT  =  6,		--足迹
	IMG_FULING_JINGJIE_TYPE_FABAO  =  7,			--法宝
}

TALENT_TYPE = {
	TALENT_MOUNT = 0,			--坐骑
	TALENT_WING = 1,			--羽翼
	TALENT_HALO = 2,			--光环
	TALENT_FIGHTMOUNT = 3,		--魔骑
	TALENT_SHENGGONG = 4,		--神弓
	TALENT_SHENYI = 5,			--神翼
	TALENT_FOOTPRINT = 6,		--足记
	TALENT_FABAO = 7,			--法宝
}

--进阶奖励类型
JINJIE_TYPE =
{
	JINJIE_TYPE_CLOAK = 0,							-- 披风 --进阶
	JINJIE_TYPE_FIGHT_MOUNT = 1,					-- 战斗坐骑 --进阶
	JINJIE_TYPE_FOOTPRINT = 2,						-- 足迹 --进阶
	JINJIE_TYPE_HALO = 3,							-- 光环 --进阶
	JINJIE_TYPE_LINGZHU = 4,						-- 灵珠 --外观
	JINJIE_TYPE_MASK = 5,							-- 面饰 --外观)
	JINJIE_TYPE_MOUNT = 6,							-- 坐骑 --进阶
	JINJIE_TYPE_QILINBI = 7,						-- 麒麟臂 --外观
	JINJIE_TYPE_SHENGONG = 8,						-- 神弓
	JINJIE_TYPE_SHENYI = 9,							-- 神翼
	JINJIE_TYPE_TOUSHI = 10,						-- 头饰 --外观
	JINJIE_TYPE_WING = 11,							-- 羽翼 --进阶
	JINJIE_TYPE_XIANBAO = 12,						-- 仙宝 --外观
	JINJIE_TYPE_YAOSHI = 13,						-- 腰饰 --外观
	JINJIE_TYPE_LINGGONG = 14,						-- 灵弓 --外观
	JINJIE_TYPE_LINGQI = 15,						-- 灵骑 --外观
	JINJIE_TYPE_LINGCHONG = 16,						-- 灵宠 --外观
	JINJIE_TYPE_WEIYAN = 17,						-- 尾焰 --外观
	JINJIE_TYPE_SHOUHUAN = 18,						-- 手环 --外观
	JINJIE_TYPE_TALT = 19,							-- 尾巴 --外观
	JINJIE_TYPE_FLYPET = 20,						-- 飞宠 --外观
	JINJIE_TYPE_FABAO = 21,							-- 法宝 --进阶
	JINJIE_TYPE_FASHION = 22,						-- 时装 --进阶
	JINJIE_TYPE_SHENBING = 23,						-- 神兵 --进阶
	JINJIE_TYPE_MAX = 24,

}

--进阶奖励操作类型
JINJIESYS_REWARD_OPEAR_TYPE = {
	JINJIESYS_REWARD_OPEAR_TYPE_INFO = 0,			-- 获取信息
	JINJIESYS_REWARD_OPEAR_TYPE_BUY = 1,			-- 购买, param_1 = 进阶系统类型
	JINJIESYS_REWARD_OPEAR_TYPE_FETCH = 2,			-- 领取进阶奖励, param_1 = 进阶系统类型
}

WEDDING_TYPE ={
	MT_MARRY_INFO_SC = 6016,										-- 结婚信息
	MT_MARRY_HUNYAN_COMMON_INFO_SC = 6025,							-- 婚宴场景公共信息
	MT_MARRY_OPETATOR_CS = 6026,									-- 结婚操作
	MT_MARRY_OPE_RET_SC = 6027,										-- 结婚操作回馈
	MT_HUNYAN_STATE_INFO_SC = 6028,									-- 婚宴状态切换通知
	MT_QINGYUAN_OPERA_REQ_CS = 6029,								-- 情缘操作请求
	MT_QINGYUAN_ALL_INFO_SC = 6030,									-- 情缘信息
	MT_QINGYUAN_WEDDING_ALL_INFO_SC = 6031,							-- 情缘婚礼信息
	MT_WEDDING_BLESSING_RECORD_INFO_SC = 6032,						-- 祝福历史记录
	MT_WEDDING_APPLICANT_INFO_SC = 6033,							-- 申请者信息
	MT_HUNYAN_CUR_WEDDING_ALL_INFO_SC = 6034,						-- 当前婚礼信息
	MT_WEDDING_ROLE_INFO_SC = 6035,									-- 婚礼玩家个人信息
}

MARRY_REQ_TYPE = {
	MARRY_REQ_TYPE_PROPOSE = 0,    -- 求婚 p1:婚礼类型 p2: 对方uid
	MARRY_CHOSE_SHICI_REQ = 1,      --选誓词 p1:誓词类型
	MARRY_PRESS_FINGER_REQ = 2,         --摁手指
}

MARRY_RET_TYPE = {
	MARRY_AGGRE = 0,				-- 点击我愿意
	MARRY_CHOSE_SHICI = 1,			-- 选誓词
	MARRY_PRESS_FINGER = 2,			-- 摁手指
	MARRY_CANCEL = 3,				--取消结婚
}

LOVE_CONTRACT_REQ_TYPE = {
	LC_REQ_TYPE_INFO = 0,					-- 信息请求
	LC_REQ_TYPE_BUY_LOVE_CONTRACT = 1,			-- 购买爱情契约
	LC_REQ_TYPE_NOTICE_LOVER_BUY_CONTRACT = 2,	-- 提醒对方购买爱情契约
}

LOVE_CONTRACT_INFO_TYPE = {
	LOVE_CONTRACT_INFO_TYPE_NORMAL = 0,					--一般
	LOVE_CONTRACT_INFO_TYPE_NOTICE_BUY_CONTRACT = 1,	-- 提醒对方购买契约
}

RA_HUANLE_YAOJIANG_2_OPERA_TYPE = {
	RA_HUANLEYAOJIANG_OPERA_2_TYPE_QUERY_INFO = 0,      -- 请求活动信息
	RA_HUANLEYAOJIANG_OPERA_2_TYPE_TAO = 1,            -- 淘宝
	RA_HUANLEYAOJIANG_OPERA_2_TYPE_FETCH_REWARD = 2,       -- 领取个人累抽奖励 param_1 = 领取奖励的索引（0开始）
	RA_HUANLEYAOJIANG_OPERA_2_TYPE_MAX = 3,
}

HUNYAN_OPERA_TYPE = {
	HUNYAN_OPERA_TYPE_INVALID = 0,
	HUNYAN_OPERA_TYPE_JOIN_HUNYAN = 1,					-- 参加进入婚宴 param1 fb_key
	HUNYAN_OPERA_TYPE_INVITE = 2,					-- 婚宴邀请
	HUNYAN_OPERA_TYPE_YANHUA = 3,					-- 婚宴燃放烟花
	HUNYAN_OPERA_TYPE_RED_BAG = 4,					-- 婚宴送红包 param1 目标uid param2 seq
	HUNYAN_OPERA_TYPE_FOLWER = 5,					-- 婚宴送花 param1 目标uid param2 seq
	HUNYAN_OPERA_TYPE_USE_YANHUA = 6,					-- 婚宴用烟花 param1 seq param2 是否购买
	HUNYAN_OPERA_TYPE_BAITANG_REQ = 7,					-- 请求拜堂
	HUNUAN_OPERA_TYPE_BAITANG_RET = 8,					-- 收到拜堂 param1 1:同意 0:拒绝
	HUNYAN_OPERA_TYPE_APPLY = 9,					-- 申请参加婚礼
	HUNYAN_OPERA_APPLICANT_OPERA = 10,					-- 处理申请参加婚礼者操作 param1 目标uid param2 1:同意 0:拒绝
	HUNYAN_GET_BLESS_RECORD_INFO = 11,					-- 获取祝福历史
	HUNYAN_GET_APPLICANT_INFO = 12,					-- 获取申请者信息
	HUNYAN_GET_WEDDING_INFO = 13,					-- 获取婚宴信息
	HUNYAN_GET_WEDDING_ROLE_INFO = 14,					-- 获取婚宴个人信息
}

QINGYUAN_OPERA_TYPE ={
	QINGYUAN_OPERA_TYPE_WEDDING_YUYUE = 0,						-- 婚礼预约 param1 预约下标 param2 预约婚宴类型
	QINGYUAN_OPERA_TYPE_WEDDING_INVITE_GUEST = 1,				-- 邀请宾客 param1 宾客uid
	QINGYUAN_OPERA_TYPE_WEDDING_REMOVE_GUEST = 2,				-- 移除宾客 param1 宾客uid
	QINGYUAN_OPERA_TYPE_WEDDING_BUY_GUEST_NUM = 3,				-- 购买宾客数量
	QINGYUAN_OPERA_TYPE_WEDDING_GET_YUYUE_INFO = 4,				-- 获取预约信息
	QINGYUAN_OPERA_TYPE_WEDDING_GET_ROLE_INFO = 5,				-- 获取玩家信息
	QINGYUAN_OPERA_TYPE_WEDDING_YUYUE_FLAG = 6,					-- 获取婚礼预约标记
	QINGYUAN_OPERA_TYPE_WEDDING_YUYUE_RESULT = 7,				-- 是否同意婚礼预约时间 param1 seq param2 是否同意
	QINGYUAN_OPERA_TYPE_LOVER_INFO_REQ = 8,						-- 请求伴侣信息
	QINGYUAN_OPERA_TYPE_XUNYOU_ROLE_INFO = 9,					-- 获取玩家巡游信息
	QINGYUAN_OPERA_TYPE_XUNYOU_SA_HONGBAO = 10,					-- 巡游撒红包 param1:is_buy
	QINGYUAN_OPERA_TYPE_XUNYOU_GIVE_FLOWER = 11,				-- 巡游购买送花次数
	QINGYUAN_OPERA_TYPE_XUNYOU_OBJ_POS = 12,					-- 获取巡视对象坐标
}

QINGYUAN_INFO_TYPE = {
	QINGYUAN_INFO_TYPE_WEDDING_YUYUE = 0,							-- 婚礼预约
	QINGYUAN_INFO_TYPE_WEDDING_STANDBY = 1,							-- 婚礼准备
	QINGYUAN_INFO_TYPE_GET_BLESSING = 2,							-- 收到祝福 param_ch1 祝福类型 param2 参数
	QINGYUAN_INFO_TYPE_BAITANG_RET = 3,								-- 拜堂请求
	QINGYUAN_INFO_TYPE_BAITANG_EFFECT = 4,							-- 拜堂特效 param_ch1 是否已经拜堂
	QINGYUAN_INFO_TYPE_LIVENESS_ADD = 5,							-- 婚礼热度增加 param2 当前热度
	QINGYUAN_INFO_TYPE_HAVE_APPLICANT = 6,							-- 婚礼申请者 param2 申请者uid
	QINGYUAN_INFO_TYPE_APPLY_RESULT = 7,							-- 申请结果 param2 1:同意 0:拒绝
	QINGYUAN_INFO_TYPE_ROLE_INFO = 8,								-- 玩家信息 param_ch1 婚姻类型 param_ch2 是否有婚礼次数 param_ch3 当前婚礼状态 param_ch4 婚礼预约seq
	QINGYUAN_INFO_TYPE_WEDDING_YUYUE_FLAG = 9,						-- 婚礼预约标记
	QINGYUAN_INFO_TYPE_YUYUE_RET = 10,								-- 婚礼预约请求 param_ch1 seq
	QINGYUAN_INFO_TYPE_YUYUE_POPUP = 11,								-- 婚礼预约弹窗
	QINGYUAN_OPERA_TYPE_BUY_QINGYUAN_FB_RET = 12,					-- 收到购买次数请求
	QINGYUAN_INFO_TYPE_YUYUE_SUCC = 13,								-- 婚礼预约成功
	QINGYUAN_INFO_TYPE_LOVER_INFO = 14,								-- 伴侣信息 param2 伴侣uid param_ch1 伴侣阵营 role_name 伴侣名字
	QINGYUAN_INFO_TYPE_LOVER_TITLE_INFO = 15,						-- 仙侣称号信息 param_ch1 预约的婚礼类型 param2 领取flag
	--QINGYUAN_INFO_TYPE_REQ_LOVER_BUY_LOVE_BOX = 16,				-- 请求仙侣购买宝匣
	QINGYUAN_INFO_TYPE_WEDDING_BEGIN_NOTICE = 16,					-- 婚宴开启通知
	QINGYUAN_INFO_TYPE_XUNYOU_INFO = 17,      						-- 婚宴巡游信息
	QINGYUAN_INFO_TYPE_XUNYOU_OBJ_POS = 18,							-- 婚宴巡游对象坐标
}

--  操作类型
IMG_FULING_OPERATE_TYPE = {
	IMG_FULING_OPERATE_TYPE_INFO_REQ  =  0,			--  请求信息
	IMG_FULING_OPERATE_TYPE_LEVEL_UP = 1,			--  请求升级  param_1=>进阶系统类型    param_2=>花费物品索引
}

CSA_ROLL_OPERA =
 {
	CSA_ROLL_OPERA_ROLL = 0,       -- 抽奖
	CSA_ROLL_OPERA_BROADCAST = 1,  -- 传闻
 }

CSA_BOSS_OPERA_TYPE = {
	CSA_BOSS_OPERA_TYPE_ENTER  =  0,	--进入boss场景
	CSA_BOSS_OPERA_TYPE_INFO_REQ  =  1,	--请求boss信息
	CSA_BOSS_OPERA_TYPE_RANK_REQ  =  2,	--请求排行榜信息
	CSA_BOSS_OPERA_TYPE_ROLE_INFO_REQ = 3, --请求个人信息
}

ELEMENT_HEART_REQ_TYPE  =                    			-- 元素之心操作请求
  {
   ACTIVE_GHOST = 0,              			-- 激活元素之心 param1 元素之心id
   CHANGE_GHOST_WUXING_TYPE = 1,        	-- 改变元素之心五行 param1 元素之心id
   FEED_ELEMENT = 2,                		-- 喂养元素之心  param1 元素之心id param2 虚拟物品id param3 物品数量
   UPGRADE_GHOST = 3,              			-- 元素之心进阶  param1 元素之心id param2 是否一键  param3 是否自动购买
   GET_PRODUCT = 4,                			-- 元素之心采集  param1 元素之心id
   PRODUCT_UP_SEED = 5,              		-- 元素之心产出加速  param1 元素之心id
   UPGRADE_CHARM = 6,              			-- 元素之纹升级 para1 升级元素之纹下标 param2 消耗格子下标
   ALL_INFO = 7,                			-- 请求所有信息
   CHOUJIANG = 8,                			-- 元素之心抽奖 param1 次数
   FEED_GHOST_ONE_KEY = 9,            		-- 一键喂养元素之心  param1 id
   SET_GHOST_WUXING_TYPE = 10,          	-- 设置元素之心类型  param1 id
   SHOP_REFRSH = 11,                		-- 商店刷新 param 1是否使用积分刷新
   SHOP_BUY = 12,                			-- 商城购买 param 1 商品seq
   XILIAN = 13,                 			-- 洗练 param1 元素id， param2 锁洗标志 param3洗练颜色、 param4 是否自动购买
   PUTON_EQUIP = 14,               			-- 穿装备 param1元素id param2装备格子
   UPGRADE_EQUIP = 15,             			-- 装备升级 Parma1 元素id param2 是否一键升级
   EQUIP_RECYCLE = 16,						-- 装备分解 param1 背包索引 param 2 消耗数量
  }

SHENGXINGZHULI_SYSTEM_TYPE = {
	SHENGXINGZHULI_SYSTEM_TYPE_MOUNT = 	0,			-- 坐骑系统
	SHENGXINGZHULI_SYSTEM_TYPE_WING = 1,			-- 翅膀
	SHENGXINGZHULI_SYSTEM_TYPE_SHENGONG = 2,		-- 神弓
	SHENGXINGZHULI_SYSTEM_TYPE_HALO = 3,			-- 光环
	SHENGXINGZHULI_SYSTEM_TYPE_SHENYI = 4,			-- 神翼
	SHENGXINGZHULI_SYSTEM_TYPE_FIGHT_MOUNT = 5,		-- 战骑
	SHENGXINGZHULI_SYSTEM_TYPE_FOOT_PRINT = 6,		-- 足迹
	SHENGXINGZHULI_SYSTEM_TYPE_COUNT = 7,
}

TALENT_OPERATE_TYPE = {
	TALENT_OPERATE_TYPE_INFO = 0,
	TALENT_OPERATE_TYPE_CHOUJIANG_INFO = 1,
	TALENT_OPERATE_TYPE_CHOUJIANG_REFRESH = 2,				-- param1:0刷新一次/1刷新全部
	TALENT_OPERATE_TYPE_AWAKE = 3,							-- param1:抽奖格子索引
	TALENT_OPERATE_TYPE_PUTON = 4,							-- param1:天赋类型, param2:天赋格子序号, param3:背包格子索引
	TALENT_OPERATE_TYPE_PUTOFF = 5,							-- param1:天赋类型, param2:天赋格子序号
	TALENT_OPERATE_TYPE_SKILL_UPLEVEL = 6,					-- param1:天赋类型, param2:天赋格子序号
	TALENT_OPERATE_TYPE_SKILL_FOCUS = 7,					-- param1:技能id
	TALENT_OPERATE_TYPE_SKILL_CANCLE_FOCUS = 8,				-- param1:技能id
}

TALENT_SKILL_TYPE = {
  TALENT_SKILL_TYPE_0 = 0,  	--气血
  TALENT_SKILL_TYPE_1 = 1,      --攻击
  TALENT_SKILL_TYPE_2 = 2,      --防御
  TALENT_SKILL_TYPE_3 = 3,      --命中
  TALENT_SKILL_TYPE_4 = 4,      --闪避
  TALENT_SKILL_TYPE_5 = 5,      --暴击
  TALENT_SKILL_TYPE_6 = 6,      --抗暴
  TALENT_SKILL_TYPE_7 = 7,      --固定增伤
  TALENT_SKILL_TYPE_8 = 8,      --固定免伤
  TALENT_SKILL_TYPE_9 = 9,      --对应系统进阶属性百分比
  TALENT_SKILL_TYPE_10 = 10,      --本天赋页气血百分比+固定值
  TALENT_SKILL_TYPE_11 = 11,      --本天赋页攻击百分比+固定值
  TALENT_SKILL_TYPE_12 = 12,      --本天赋页防御百分比+固定值
  TALENT_SKILL_TYPE_13 = 13,      --本天赋页命中百分比+固定值
  TALENT_SKILL_TYPE_14 = 14,      --本天赋页闪避百分比+固定值
  TALENT_SKILL_TYPE_15 = 15,      --本天赋页暴击百分比+固定值
  TALENT_SKILL_TYPE_16 = 16,      --本天赋页抗暴百分比+固定值
  TALENT_SKILL_TYPE_17 = 17,      --本天赋页固定增伤百分比+固定值
  TALENT_SKILL_TYPE_18 = 18,      --本天赋页固定免伤百分比+固定值
  TALENT_SKILL_TYPE_19 = 19,      --坐骑终极技能
  TALENT_SKILL_TYPE_20 = 20,      --羽翼终极技能
  TALENT_SKILL_TYPE_21 = 21,      --光环终极技能
  TALENT_SKILL_TYPE_22 = 22,      --魔骑终极技能
  TALENT_SKILL_TYPE_23 = 23,      --神弓终极技能
  TALENT_SKILL_TYPE_24 = 24,      --神翼终极技能
  TALENT_SKILL_TYPE_25 = 25,      --足记终极技能
}

CS_SHEN_YIN_TYPE = {
	ALL_INFO                 = 0,	-- 请求所有信息
	CHANGE_BEAD_TYPE         = 1,	-- 请求改变珠子颜色，p1 = x , p2 = y， p3 = 要改的颜色
	CHANGE_BEAD              = 2,	-- 请求改变位置，p1 = x , p2 = y， p3 = 目标格子的x, p4 = 目标格子的y
	IMPRINT_UP_START         = 3,	-- 印位升星 p1 印位类型 p2 是否使用保护符
	IMPRINT_UP_LEVEL         = 4,	-- 印位突破
	IMPRINT_EQUIT            = 5,	-- 装备印记 p1 虚拟背包索引， p2 印位类型
	IMPRINT_TAKE_OFF         = 6,	-- 卸下印记 p1 印位类型
	IMPRINT_ADD_ATTR_COUNT   = 7,	-- 增加属性条数 p1 印位类型
	IMPRINT_FLUSH_ATTR_TYPE  = 8,	-- 印位洗练属性类型 p1 印位类型
	IMPRINT_FLUSH_ATTR_VALUE = 9,	-- 印位洗练属性值 p1 印位类型
	IMPRINT_APLY_FLUSH       = 10,	-- 应用洗练 p1 类型 0 属性类：1 属性值
	IMPRINT_RECYCLE          = 11,	-- 印记回收 p1 虚拟背包索引， p2 数量
	IMPRINT_EXCHANGE         = 12,	-- 印记兑换 p1 商店索引
	SORT                     = 13,	-- 背包整理
	CHOUHUN                  = 14,	-- 抽取 p1 是否使用积分
	SUPER_CHOUHUN            = 15,	-- 逆天改运
	BATCH_HUNSHOU            = 16,	-- 连抽（一键猎魂）
	PUT_BAG                  = 17,	-- 放入背包 p1 格子id
	CONVERT_TO_EXP           = 18,	-- 一键出售
	SINGLE_CONVERT_TO_EXP    = 19,	-- 出售 p1 格子id
	PUT_BAG_ONE_KEY          = 20,	-- 一键放入背包
}

CameraType = {
	Fixed = 0,		-- 固定视角
	Free = 1,		-- 自由视角
}

XIANYUAN_EQUIP_OPERATE_TYPE ={
	FEIXIAN_EQUIP_OPERATE_TYPE_RED_INFO = 0,	-- 请求信息
	FEIXIAN_EQUIP_OPERATE_TYPE_TAKE_OFF = 1,	-- 脱下
	FEIXIAN_EQUIP_OPERATE_TYPE_COMPOSE = 2,		-- 合成
	FEIXIAN_EQUIP_OPERATE_TYPE_LEVELUP = 3,		-- 升级
}
SEAL_OPERA_TYPE ={
	SEAL_OPERA_TYPE_ALL_INFO = 0,        		-- 请求所有信息
	SEAL_OPERA_TYPE_PUT_ON = 1,            		-- 装备， param1 背包格子index
	SEAL_OPERA_TYPE_UPLEVLE = 2,          		-- 升级， param1 圣印孔索引index
	SEAL_OPERA_TYPE_RECYCLE = 3,          		-- 分解单个， param1 分解数量，param2背包格子index
	SEAL_OPERA_TYPE_USE_SOUL = 4,          		-- 使用圣魂 param1 类型，param2 数量
	SEAL_OPERA_TYPE_MAX = 5,
}

CHANGE_MODE_TASK_TYPE = {
	INVALID = 0,
	GATHER = 1,									--采集物
	TALK_TO_NPC = 2,							-- NPC
	TALK_IMAGE = 3,								-- 变身
	CHANGE_MODE_TASK_TYPE_FLY = 4,				-- 飞天任务
}

BABY_BOSS_OPERATE_TYPE = {
	BABY_BOSS_INFO_REQ = 0,						-- 请求宝宝boss信息
	BABY_BOSS_ROLE_INFO_REQ = 1,				-- 请求人物相关信息
	BABY_BOSS_SCENE_ENTER_REQ = 2,				-- 请求进入宝宝boss
	BABY_BOSS_SCENE_LEAVE_REQ = 3,				-- 请求离开宝宝boss副本
}

GODMAGIC_BOSS_OPERA_TYPE = {
	GODMAGIC_BOSS_OPERA_TYPE_ENTER = 0,--进入param1 scene_id pararm2 boss_id
	GODMAGIC_BOSS_OPERA_TYPE_PLAYER_INFO = 1,--玩家信息
	GODMAGIC_BOSS_OPERA_TYPE_GET_FLUSH_INFO = 2,--刷新信息param1 层数（为0则为所有层）
}

CROSS_BOSS_OPERATE_TYPE = {
	GET_FLUSH_INFO = 0,
	BOSS_KILL_RECORD = 1,
	DROP_RECORD = 2,
	CONCERN_BOSS = 3,
	UNCONCERN_BOSS = 4,
}

-- 跨服修罗塔日志
CROSS_XIULUO_TOWER_DROP_LOG_TYPE = {
	CROSS_XIULUO_TOWER_DROP_LOG_TYPE_MONSTER = 1,				-- 怪物掉落
	CROSS_XIULUO_TOWER_DROP_LOG_TYPE_GOLD_BOX = 2,				-- 金箱子掉落

	CROSS_XIULUO_TOWER_DROP_LOG_TYPE_MAX = 3,
}

DROP_LOG_TYPE = {
	DOPE_LOG_TYPE_BOSS = 0,								-- Boss
	DOPE_LOG_TYPE_FB = 1,								-- 塔防
	DOPE_LOG_TYPE_OTHER = 2,							-- 神域(不是从同一条协议拿的值)
}

GUILD_SOS_TYPE = {
	GUILD_SOS_TYPE_DEFAULT = 0,							-- 默认求救
	GUILD_SOS_TYPE_HUSONG = 1,							-- 护送求救
	GUILD_SOS_TYPE_HUSONG_BE_ATTACK = 2,				-- 护送求救 - 被攻击
	GUILD_SOS_TYPE_GUILD_BATTLE = 3,					-- 公会争霸
	GUILD_SOS_TYPE_GONGCHENGZHAN = 4,					-- 攻城战
	GUILD_SOS_TYPE_CROSS_GUILD_BATTLE = 5,				-- 跨服六界-诛魔
	GUILD_SOS_TYPE_CROSS_BIANJINGZHIDI = 6,				-- 跨服边境
	GUILD_SOS_TYPE_CROSS_BOSS = 7,						-- 跨服远古BOSS
	GUILD_SOS_TYPE_CROSS_MIZANG_BOSS = 8,				-- 跨服神域BOSS
	GUILD_SOS_TYPE_CROSS_VIP_BOSS = 9,					-- 跨服VIPBOSS
}

GUILD_COMMON_REQ_TYPE = {
	GUILD_COMMON_REQ_TYPE_FETCH_REWARD = 0,				-- 领取每日奖励
	GUILD_COMMON_REQ_TYPE_GIVE_GONGZI = 1,				-- 发工资
}

SC_CROSS_GUILDBATTLE_INFO_TYPE = {
	SC_CROSS_GUILDBATTLE_NOTIFY_TYPE_SCORE = 0,			-- 个人积分
	SC_CROSS_GUILDBATTLE_NOTIFY_TYPE_END = 1,			-- 结束
	SC_CROSS_GUILDBATTLE_NOTIFY_TYPE_SOS = 2,			-- 召集 param2 次数
	SC_CROSS_GUILDBATTLE_NOTIFY_TYPE_ENTER = 3,			-- 进入场景
}

PHASE_FB_OPERATE_TYPE = {
	PHASE_FB_OPERATE_TYPE_INFO = 0,						-- 获取信息
	PHASE_FB_OPERATE_TYPE_BUY_TIMES = 1,				-- 购买次数
}


ZHUANZHI_EQUIP_OPERATE_TYPE = {
	ZHUANZHI_EQUIP_OPERATE_TYPE_EQUIP_INFO = 0,			-- 请求装备信息
	ZHUANZHI_EQUIP_OPERATE_TYPE_STONE_INFO = 1,			-- 请求玉石信息
	ZHUANZHI_EQUIP_OPERATE_TYPE_SUIT_INFO = 2,			-- 请求套装信息
	ZHUANZHI_EQUIP_OPERATE_TYPE_TAKE_OFF = 3,			-- 脱下 p1: part_index
	ZHUANZHI_EQUIP_OPERATE_TYPE_UP_STAR = 4,			-- 升星 p1: part_index
	ZHUANZHI_EQUIP_OPERATE_TYPE_FULING = 5,				-- 附灵 p1: part_index
	ZHUANZHI_EQUIP_OPERATE_TYPE_INLAY_STONE = 6,		-- 镶嵌玉石 p1: part_index p2: slot_index p3: bag_index
	ZHUANZHI_EQUIP_OPERATE_TYPE_UNINLAY_STONE = 7,		-- 卸下玉石 p1: part_index p2: slot_index 
	ZHUANZHI_EQUIP_OPERATE_TYPE_UP_LEVEL = 8,			-- 升级玉石	p1: part_index p2: slot_index 
	ZHUANZHI_EQUIP_OPERATE_TYPE_REFINE_STONE = 9,		-- 精炼玉石 p1: part_index p2: seq p3: is_autobuy
	ZHUANZHI_EQUIP_OPERATE_TYPE_FORGE_SUIT = 10,		-- 锻造套装	p1: suit_index p2: part_index
	ZHUANZHI_EQUIP_OPERATE_TYPE_ZHIZUN_COMPOSE  = 11,	-- 至尊装备合成  p1: compose_id p2: best_attr_num p3: equip_index (身上装备索引,-1为背包） p4:bag_index1 p5:bag_index2
	ZHUANZHI_EQUIP_OPERATE_TYPE_STONE_RESOLVE = 12,    	-- 玉石分解  p1: bag_index 
	ZHUANZHI_EQUIP_OPERATE_TYPE_STONE_CONVERT=13,    	-- 玉石兑换  p1: seq 

	ZHUANZHI_EQUIP_OPERATE_TYPE_AWAKENING_INFO = 14,	-- 请求觉醒信息
	ZHUANZHI_EQUIP_OPERATE_TYPE_AWAKENING_WAKE = 15,	-- 觉醒 p1: part_index p2: 自动购买(1是自动)
	ZHUANZHI_EQUIP_OPERATE_TYPE_AWAKENING_REPLACE = 16,	-- 替换 p1: part_index
	ZHUANZHI_EQUIP_OPERATE_TYPE_AWAKENING_LOCK = 17,	-- 加锁 p1: part_index, p2: lock_index
	ZHUANZHI_EQUIP_OPERATE_TYPE_AWAKENING_UNLOCK = 18,	-- 解锁 p1: part_index, p2: lock_index

}

BAIZHAN_EQUIP_OPERATE_TYPE = {
	BAIZHAN_EQUIP_OPERATE_TYPE_ALL_INFO = 0,    -- 请求装备所有信息
	BAIZHAN_EQUIP_OPERATE_TYPE_TAKE_OFF = 1,      -- 脱下 p1: part_index
	BAIZHAN_EQUIP_OPERATE_TYPE_UP_LEVEL = 2,      -- 升级装备  p1: part_index 
}

WEAPON_INFO_TYPE = {
	NEQ_FB_INFO_DEFAULT= 0,								-- 全部刷新
	NEQ_FB_INFO_VIP_BUY_TIME = 1,						-- VIP次数购买
	NEQ_FB_INFO_ITEM_BUY_TIME =2,						-- 普通购买次数
	NWQ_FB_INFO_REWARD = 3,								-- 领取奖励
}


ARMOR_DEFEND_REQTYPE = {
	ARMOR_DEFEND_ROLE_INFO_REQ = 0,					-- 请求防具材料副本信息
	ARMOR_DEFEND_BUY_JOIN_TIMES = 1,				-- 购买防具材料副本次数
	ARMOE_DEFEND_NEXT_WAVE_REQ = 2,
	ARMOR_DEFEND_AUTO_REFRESH = 3, 					-- 0不自动刷，1 清完自动刷新
}

BUILD_TOWER_OPERA_TYPE = {
	BUILD_TOWER_OPERA_TYPE_BUILD = 0,				-- 建造塔
	BUILD_TOWER_OPERA_TYPE_UPGRADE = 1,				-- 升级塔
	BUILD_TOWER_OPERA_TYPE_REMOVE = 2,				-- 移除塔
	BUILD_TOWER_OPERA_TYPE_FLUSH = 3,				-- 立即刷怪
	BUILD_TOWER_OPERA_TYPE_CALL = 4,				-- 召唤鬼蟾王
}

-- 吃鸡盛宴
BUILD_TOWER_NOTIFY_REASON = {
	NOTIFY_REASON_DEFAULT = 0, 
	NOTIFY_MONSTER_WAVE = 1, 
	NOTIFY_BOSS_FLUSH = 2,
	NOTIFY_EXTRA_BOSS = 3,
	NOTIFY_FB_END = 4,
	NOTIFY_WAVE_FLUSH_END = 5,						-- 怪刷完
	NOTIFY_PREPARE_TIME = 10,
}

HOLIDAI_GUARD_REQ = {
	HOLIDAY_GUARD_NEXT_WAVE = 0,
}

-- 吃鸡盛宴生命塔预警类型
WARNING_TYPE = {
	WARNING_TYPE_NORMAL = 1,
	WARNING_TYPE_LOW_PERCENT = 2, 
}

NOTIFY_REASON = {
	NOTIFY_REASON_DEFAULT = 0,
	NOTIFY_REASON_INIT = 1,
	NOTIFY_REASON_NEW_WAVE_START = 2,
	NOTIFY_REASON_KILL_MONSTER = 3,
}

--组队塔防
TEAM_TOWERDEFEND_ATTRTYPE = {
	TEAM_TOWERDEFEND_ATTRTYPE_INVALID = 0,
	TEAM_TOWERDEFEND_ATTRTYPE_GONGJI = 1,									-- 加攻 朱雀
	TEAM_TOWERDEFEND_ATTRTYPE_FANGYU = 2,									-- 加防 玄武
	TEAM_TOWERDEFEND_ATTRTYPE_ASSIST = 3,									-- 辅助 青龙
	TEAM_TOWERDEFEND_ATTRTYPE_MAX = 4,
}

TEAM_TOWER_DEFEND_OPREAT_REQ_TYPE = {
	TEAM_TOWER_DEFEND_SET_ATTR_TYPE = 0,									-- 请求改变守护职业
	TEAM_TOWER_DEFEND_NEXT_WAVE_REQ = 1,									-- 请求刷新怪物
}

SGBOSS_REQ_TYPE = {
	ENTER = 0,					--上古BOSS请求类型
	ALLINFO = 1,
	SINGLEINFO = 2,
	CONCERN = 3,
}

NOTIFY_INFO_TYPE = {
	NOTIFY_INFO_TYPE_SCENE  = 0,
	NOTIFY_INFO_TYPE_RANK  = 1,					--排行信息通知
	NOTIFY_INFO_TYPE_ROLE_INFO_CHANGE = 2,		--个人信息变化通知
	NOTIFY_INFO_TYPE_STAR_LEVEL_CHANGE = 3,		--星级变化通知
}

-------- 钓鱼枚举 --------------------------------------
-- 钓鱼类型
FISHING_OPERA_REQ_TYPE = {
	FISHING_OPERA_REQ_TYPE_START_FISHING = 0,			-- 开始钓鱼（进入钓鱼界面）
	FISHING_OPERA_REQ_TYPE_CASTING_RODS = 1,			-- 抛竿 param1是鱼饵类型
	FISHING_OPERA_REQ_TYPE_PULL_RODS = 2,				-- 收竿
	FISHING_OPERA_REQ_TYPE_CONFIRM_EVENT = 3,			-- 确认本次钓鱼事件
	FISHING_OPERA_REQ_TYPE_USE_GEAR = 4,				-- 使用法宝 param是法宝类型
	FISHING_OPERA_REQ_TYPE_BIG_FISH_HELP = 5,			-- 帮忙拉大鱼
	FISHING_OPERA_REQ_TYPE_STOP_FISHING = 6,			-- 停止钓鱼（离开钓鱼界面）
	FISHING_OPERA_REQ_TYPE_AUTO_FISHING = 7,			-- 自动钓鱼 param1:0取消状态1设置状态，param2状态类型
	FISHING_OPERA_REQ_TYPE_RAND_USER = 8,				-- 随机角色请求
	FISHING_OPERA_REQ_TYPE_BUY_STEAL_COUNT = 9,			-- 购买偷鱼次数
	FISHING_OPERA_REQ_TYPE_RANK_INFO = 10,				-- 请求钓鱼排行榜信息
	FISHING_OPERA_REQ_TYPE_STEAL_FISH = 11,				-- 偷鱼请求 param1 是被偷玩家rold_id
	FISHING_OPERA_REQ_TYPE_EXCHANGE = 12,				-- 兑换请求 param1：兑换组合下标
	FISHING_OPERA_REQ_TYPE_BUY_BAIT = 13,				-- 购买鱼饵 param1: 购买鱼饵类型 param2为购买数量
	FISHING_OPERA_REQ_TYPE_SCORE_REWARD = 14,			-- 领取积分奖励
}

-- 钓鱼日志类型
FISHING_NEWS_TYPE = {
	FISHING_NEWS_TYPE_INVALID = 0,
	FISHING_NEWS_TYPE_STEAL = 1,						-- 偷鱼日志
	FISHING_NEWS_TYPE_BE_STEAL = 2,						-- 被偷日志

	FISHING_NEWS_TYPE_MAX = 3
}

-- 钓鱼的状态
FISHING_STATUS = {
	FISHING_STATUS_IDLE = 0,							-- 未钓鱼，即不在钓鱼界面
	FISHING_STATUS_WAITING = 1,							-- 在钓鱼界面等待抛竿
	FISHING_STATUS_CAST = 2,							-- 已经抛竿，等待触发事件
	FISHING_STATUS_HOOKED = 3,							-- 已经触发事件，等待拉杆
	FISHING_STATUS_PULLED = 4,							-- 已经拉杆，等待玩家做选择
}

-- 特殊状态
SPECIAL_STATUS = {
	SPECIAL_STATUS_OIL = 0,								-- 使用香油中
	SPECIAL_STATUS_AUTO_FISHING = 1,					-- 自动钓鱼
	SPECIAL_STATUS_AUTO_FISHING_VIP = 2,				-- 自动钓鱼_vip
}

FISHING_EVENT_TYPE = {
	EVENT_TYPE_GET_FISH = 0,							-- 鱼类上钩 -- 事件类型为EVENT_TYPE_GET_FISH：param1为鱼的类型，param2为鱼的数量
	EVENT_TYPE_TREASURE = 1,							-- 破旧宝箱
	EVENT_TYPE_YUWANG = 2,								-- 渔网
	EVENT_TYPE_YUCHA = 3,								-- 渔叉
	EVENT_TYPE_OIL = 4,
	EVENT_TYPE_ROBBER = 5,								-- 盗贼偷鱼 -- 事件类型为EVENT_TYPE_ROBBER:param1为被偷的鱼类型， param2为被偷数量
	EVENT_TYPE_BIGFISH = 6,								-- 传说中的大鱼 -- 事件类型为EVENT_TYPE_BIGFISH: param1为的鱼类型， param2为数量

	EVENT_TYPE_COUNT = 7,
	EVENT_TYPE_NOTICE = 8,								-- 鱼被顶上的提示 --param1 1:被盯上, 0:没有
}

FISHING_GEAR = {
	FISHING_GEAR_NET = 0,								-- 渔网
	FISHING_GEAR_SPEAR = 1,								-- 鱼叉
	FISHING_GEAR_OIL = 2,								-- 香油

	FISHING_GEAR_COUNT = 3
}

IMP_GUARD_REQ_TYPE = {
	IMP_GUARD_REQ_TYPE_RENEW_PUTON = 0,                 -- 续费穿在身上的小鬼  param1:身上小鬼格子index    param2:是否使用绑元
	IMP_GUARD_REQ_TYPE_RENEW_KNAPSACK = 1,              -- 续费背包中的小鬼 param1:背包index param2:是否使用绑元
	IMP_GUARD_REQ_TYPE_TAKEOFF = 2,                     -- 脱下小鬼  param1:身上小鬼格子index    0  1
	IMP_GUARD_REQ_TYPE_ALL_INFO = 3,

	IMP_GUARD_REQ_TYPE_MAX = 4,
}

HESHENLUOSHU_REQ_TYPE = {
	HESHENLUOSHU_REQ_TYPE_ACTIVATION = 0,			-- 河神洛书激活 param1 item_id
	HESHENLUOSHU_REQ_TYPE_UPGRADELEVEL = 1,				-- 河神洛书升级 param1 item_id
	HESHENLUOSHU_REQ_TYPE_DECOMPOSE = 2,				-- 河神洛书分解 param1 param2 param3 分解物品背包index
}

------------------boss图鉴----------------------
 BOSS_CARD_OPERA_TYPE = {
	BOSS_CARD_OPERA_TYPE_ALL_INFO = 0,
	BOSS_CARD_OPERA_TYPE_ACTIVE = 1,            --激活  param1 序号seq
	BOSS_CARD_OPERA_TYPE_FETCH = 2,
	BOSS_CARD_OPERA_TYPE_MAX = 3,
}

CROSS_1V1_FETCH_REWARD_TYPE = {
	CROSS_1V1_FETCH_REWARD_TYPE_JOIN_TIMES = 1,			--跨服1v1参与奖励
	CROSS_1V1_FETCH_REWARD_TYPE_SCORE = 2,				--跨服1v1积分奖励
	CROSS_1V1_FETCH_REWARD_TYPE_HONOR = 3,				--跨服1v1荣耀奖励
	CROSS_1V1_FETCH_REWARD_TYPE_MAX,
}

--版本累计充值请求
RA_VERSION_TOTAL_CHARGE_OPERA_TYPE = {
	RA_VERSION_TOTAL_CHARGE_OPERA_TYPE_QUERY_INFO = 0,
	RA_VERSION_TOTAL_CHARGE_OPERA_TYPE_FETCH_REWARD = 1,

	RA_VERSION_TOTAL_CHARGE_OPERA_TYPE_MAX = 2,
}

CROSS_1V1_MATCH_REQ_TYPE = {
	CROSS_1V1_MATCH_REQ_RESULT = 0,                -- 匹配状态查询
	CROSS_1V1_MATCH_REQ_CANCEL = 1,                -- 取消匹配
}

NIGHT_FIGHT_OPERA_TYPE = {
	NIGHT_FIGHT_OPERA_TYPE_ENTER = 0,		-- 进入请求
	NIGHT_FIGHT_OPERA_TYPE_POSI_INFO = 1,	-- 获取坐标信息,param_1:rank
}

CROSS_RING_CARD_OPER_TYPE = {
	CROSS_RING_CARD_OPER_WEAR = 1,			-- 佩戴
	CROSS_RING_CARD_OPER_OFF = 2,			-- 脱下
}

-- 循环充值2(送装备)
CIRCULATION_CHONGZHI_OPERA_TYPE =
{
	CIRCULATION_CHONGZHI_OPERA_TYPE_QUERY_INFO = 0, -- 请求活动信息
	CIRCULATION_CHONGZHI_OPEAR_TYPE_FETCH_REWARD = 1, -- 获取奖励
	CIRCULATION_CHONGZHI_OPERA_TYPE_MAX = 2
}

--疯狂摇钱树
RA_SHAKEMONEY_OPERA_TYPE = {
	RA_SHAKEMONEY_OPERA_TYPE_QUERY_INFO = 0,				-- 请求信息
	RA_SHAKEMONEY_OPERA_TYPE_FETCH_GOLD = 1,				-- 领取元宝
	RA_SHAKEMONEY_OPERA_TYPE_MAX = 2,
}

-- 衣橱操作请求
DRESSING_ROOM_OPEAR_TYPE = {
	DRESSING_ROOM_OPEAR_TYPE_INFO = 0,						-- 请求信息
}

-- 生肖星图
ZODIAC_OPERA_TYPE = {
	ZODIAC_OPERA_TYPE_ALL_INFO = 0,				-- 十二生肖的所有信息
	ZODIAC_OPERA_TYPE_ACTIVATE = 1,					-- 激活 param1 碎片id 
	ZODIAC_OPERA_TYPE_LEVELUP = 2,					-- 升级 param1 碎片id
	ZODIAC_OPERA_TYPE_DECOMPOSE = 3,				-- 分解 param1 碎片id

	ZODIAC_OPERA_TYPE_MAX,
}


-- 衣橱套装部位类型
SPECIAL_IMG_TYPE = {
	SPECIAL_IMG_TYPE_MOUNT = 0,							-- 坐骑
	SPECIAL_IMG_TYPE_WING = 1,							-- 羽翼
	SPECIAL_IMG_TYPE_SHIZHUANG_PART_1 = 2,				-- 时装-部位1 时装
	SPECIAL_IMG_TYPE_SHIZHUANG_PART_0 = 3,				-- 时装-部位0 神兵
	SPECIAL_IMG_TYPE_FABAO = 4,							-- 法宝
	SPECIAL_IMG_TYPE_HALO = 5,							-- 光环
	SPECIAL_IMG_TYPE_FOOTPRINT = 6,						-- 足迹
	SPECIAL_IMG_TYPE_FIGHT_MOUNT = 7,					-- 战斗坐骑
	SPECIAL_IMG_TYPE_XIANNV = 8,						-- 仙女
	SPECIAL_IMG_TYPE_SHENGONG = 9,						-- 仙女光环
	SPECIAL_IMG_TYPE_SHENYI = 10,						-- 仙女法阵
	SPECIAL_IMG_TYPE_JINGLING = 11,						-- 仙宠
	SPECIAL_IMG_TYPE_TOUSHI = 12,						-- 头饰
	SPECIAL_IMG_TYPE_YAOSHI = 13,						-- 腰饰
	SPECIAL_IMG_TYPE_MASK = 14,							-- 面饰
	SPECIAL_IMG_TYPE_QILINBI = 15,						-- 麒麟臂
	SPECIAL_IMG_TYPE_MULIT_MOUNT = 16,					-- 双骑
	SPECIAL_IMG_TYPE_LINGGONG = 17,						-- 灵弓
	SPECIAL_IMG_TYPE_LINGQI = 18,						-- 灵骑
	SPECIAL_IMG_TYPE_WEIYAN = 19,						-- 尾焰
	SPECIAL_IMG_TYPE_SHOUHUAN = 20,						-- 手环
	SPECIAL_IMG_TYPE_TAIL = 21,							-- 尾巴
	SPECIAL_IMG_TYPE_FLYPET = 22,						-- 飞宠
	SPECIAL_IMG_TYPE_LINGZHU = 23,						-- 灵珠
	SPECIAL_IMG_TYPE_XIANBAO = 24,						-- 仙宝
	SPECIAL_IMG_TYPE_LINGTONG = 25,						-- 灵童
}

--小宠物操作类型
LITTLE_PET_REQ_TYPE = {
	LITTLE_PET_REQ_INTENSIFY_SELF = 0,						-- 强化自己宠物 param1 宠物索引 param2 强化点索引 param3格子索引 (ug05弃用)
	LITTLE_PET_REQ_INTENSIFY_LOVER = 1,						-- 强化爱人宠物 param1 宠物索引 param2 强化点索引 param3格子索引 (ug05弃用)
	LITTLE_PET_REQ_CHOUJIANG = 2,							-- 抽奖	param1  1:10
	LITTLE_PET_REQ_RECYCLE = 3,								-- 回收	param1 物品id param2 物品数量 param3 是否绑定 1:0 默认绑定 (ug05弃用)
	LITTLE_PET_REQ_RELIVE = 4,								-- 放生	param1 宠物索引(ug05弃用)
	LITTLE_PET_REQ_FEED = 5 ,                               -- 喂养自己宠物 param1 宠物索引 , param2 自己：伴侣 1：0 param3:是否自动购买
	LITTLE_PET_REQ_PET_FRIEND_INFO = 6,						-- 宠友信息
	LITTLE_PET_REQ_INTERACT = 7,							-- 互动 param1 宠物索引 param2 目标role uid param3 自己:伴侣 1:0 (ug05弃用)
	LITTLE_PET_REQ_EXCHANGE = 8,							-- 兑换 param1 兑换物品索引 param2 数量
	LITTLE_PET_REQ_CHANGE_PET = 9,							-- 换宠 param1 宠物索引 param2 使用的物品id (ug05弃用)
	LITTLE_PET_REQ_USING_PET = 10,							-- 使用形象 param1 形象id (暂时无用)
	LITTLE_PET_REQ_FRIEND_PET_LIST = 11,					-- 好友小宠物列表 param1 朋友uid
	LITTLE_PET_REQ_INTERACT_LOG = 12,						-- 互动记录 (ug05弃用)
	LITTLE_PET_PUTON = 13,									-- 装备小宠物 param1:宠物下标 param2:背包宠物index
	LITTLE_PET_TAKEOFF = 14,								-- 卸下小宠物 param1:宠物下标
	LITTLE_PET_REQ_EQUIPMENT_PUTON = 15,					-- 小宠物穿戴装备 param1:宠物下标 param2:背包index
	LITTLE_PET_REQ_EQUIPMENT_TAKEOFF = 16,					-- 小宠物脱下装备 param1:宠物下标 param2:装备index
	LITTLE_PET_REQ_EQUIPMENT_UPLEVEL_SELF = 17,				-- 自己小宠物装备升级  param1 宠物下标 param2 装备下标(从0开始) param3 是否自动购买
	LITTLE_PET_REQ_EQUIPMENT_UPLEVEL_LOVER = 18,			-- 爱人小宠物装备升级  param1 宠物下标 param2 装备下标(从0开始) param3 是否自动购买
	LITTEL_PET_REQ_WALK = 19,								-- 溜宠物 param1 玩家是否idle动作 0不是 1是
}

-- 跨服排行榜类型
KF_RANK_TYPE = {
	CROSS_PERSON_RANK_TYPE_1V1_SCORE = 3,					-- 跨服1v1积分排行榜
	CROSS_PERSON_RANK_TYPE_3V3_SCORE = 4,					-- 跨服3v3积分排行榜
}

--小宠物相关操作类型
LITTLE_PET_NOTIFY_INFO_TYPE ={
	LITTLE_PET_NOTIFY_INFO_SCORE = 0,											--param1 积分信息
	LITTLE_PET_NOTIFY_INFO_FREE_CHOU_TIMESTAMP = 1,								--param1 免费抽奖时间戳
	LITTLE_PET_NOTIFY_INFO_INTERACT_TIMES = 2,									--param1 玩家互动次数
	LITTLE_PET_NOTIFY_INFO_FEED_DEGREE = 3,										--param1 宠物索引, param2 饱食度, param3 自己:伴侣  1:0
	LITTLE_PET_NOTIFY_INFO_PET_INTERACT_TIMES = 4,					 			--param1 宠物互动次数
}

--职业对应预制体模型下标
PROF_ROLE = {
	[1] = 1,
	[2] = 1,
	[3] = 2,
	[4] = 2,
}

GUILD_TIANCITONGBI_REQ_TYPE = {
	GUILD_TIANCITONGBI_REQ_TYPE_OPEN = 0,			-- 开启 p1:guild_id p2:role_id
	GUILD_TIANCITONGBI_REQ_TYPE_USE_GATHER = 1,		-- 提交采集物
	GUILD_TIANCITONGBI_REQ_TYPE_RANK_INFO = 2,		-- 请求排名信息
}

-- 消费领奖
RA_CONSUM_GIFT_OPERA_TYPE ={
	RA_CONSUM_GIFT_OPERA_TYPE_INFO = 0,			--请求信息
	RA_CONSUM_GIFT_OPERA_TYPE_FETCH = 1,		--领取奖励    参数2  seq
	RA_CONSUM_GIFT_OPERA_TYPE_ROLL = 2,			--摇奖
	RA_CONSUM_GIFT_OPERA_TYPE_ROLL_REWARD = 3,			--摇奖
	RA_CONSUM_GIFT_OPERA_TYPE_ROLL_TEN = 4,				--开始摇奖十次
	RA_CONSUM_GIFT_OPERA_TYPE_ROLL_REWARD_TEN = 5,		--领取摇奖奖励10次
 }

 RA_JINJIE_RETURN_OPERA_TYPE ={
	RA_JINJIE_RETURN_OPERA_TYPE_INFO = 0,	-- 信息
	RA_JINJIE_RETURN_OPERA_TYPE_FETCH = 1,		-- 领奖
}

--买一送一活动请求
RA_BUY_ONE_GET_ONE_FREE_OPERA_TYPE = {
	RA_BUY_ONE_GET_ONE_FREE_OPERA_TYPE_INFO = 0,			--请求物品的信息
	RA_BUY_ONE_GET_ONE_FREE_OPERA_TYPE_BUY = 1,				--请求购买物品的索引
	RA_BUY_ONE_GET_ONE_FREE_OPERA_TYPE_FETCH_REWARD = 2,	--请求领取物品的索引
}

RA_CONSUME_FOR_GIFT_OPERA_TYPE = {
	RA_CONSUME_FOR_GIFT_OPERA_TYPE_ALL_INFO = 0,				-- 请求所有信息
	RA_CONSUME_FOR_GIFT_OPERA_TYPE_EXCHANGE_ITEM = 1,			-- 兑换物品

	RA_CONSUME_FOR_GIFT_OPERA_TYPE_MAX,
}

--限时礼包活动
RA_TIMELIMIT_GIFT_OPERA_TYPE = {
	RA_TIMELIMIT_GIFT_OPERA_TYPE_QUERY_INFO = 0,			--请求物品的信息
	RA_TIMELIMIT_GIFT_OPERA_TYPE_FETCH_REWARD = 1,			--请求领取物品的索引
	RA_TIMELIMIT_GIFT_OPERA_TYPE_MAX = 2,
}

--限时礼包领取操作
RA_TIMELIMIT_GIFT_FETCH_TYPE = {
	RA_TIMELIMIT_GIFT_FETCH_FIRST = 0,			--第一份奖励领取操作
	RA_TIMELIMIT_GIFT_FETCH_SECOND = 1,			--第二份奖励领取操作
	RA_TIMELIMIT_GIFT_FETCH_THIRDLY = 2,		--第三份奖励领取操作
}

--限时大反馈活动请求
RA_LIMIT_TIME_REBATE_OPERA_TYPE = {
	RA_LIMIT_TIME_REBATE_OPERA_TYPE_INFO = 0,     			--请求信息
	RA_LIMIT_TIME_REBATE_OPERA_TYPE_FETCH_REWARD = 1,		--请求领取信息
}

--组合团购操作类型
RA_COMBINE_BUY_OPERA_TYPE = {
	RA_COMBINE_BUY_OPERA_TYPE_INFO = 0,						-- 请求信息
	RA_COMBINE_BUY_OPERA_TYPE_ADD_IN_BUCKET = 1,			-- 加入购物车 param_1 = 物品索引
	RA_COMBINE_BUY_OPERA_TYPE_REMOVE_BUCKET = 2,			-- 移出购物车 param_1 = 购物车索引
	RA_COMBINE_BUY_OPERA_TYPE_BUY = 3,						-- 购买
}

--消费返利
 RA_CONSUME_GOLD_REWARD_OPERATE_TYPE = {
	RA_CONSUME_GOLD_REWARD_OPERATE_TYPE_INFO = 0,		-- 请求活动信息
	RA_CONSUME_GOLD_REWARD_OPERATE_TYPE_FETCH = 1,		-- 请求领取奖励
}

RA_LOGIN_GIFT_OPERA_TYPE = {
	RA_LOGIN_GIFT_OPERA_TYPE_INFO = 0,									-- 获取信息
	RA_LOGIN_GIFT_OPERA_TYPE_FETCH_COMMON_REWARD = 1,					-- 获取普通奖励
	RA_LOGIN_GIFT_OPERA_TYPE_FETCH_VIP_REWARD = 2,						-- 获取VIP奖励
	RA_LOGIN_GIFT_OPERA_TYPE_FETCH_ACCUMULATE_REWARD = 3,				-- 获取累计奖励
}
-- 中秋欢乐摇奖
RA_ZHONGQIUHAPPYERNIE_CHOU_TYPE = {
		RA_ZHONGQIUHAPPYERNIE_CHOU_TYPE_1 = 0,				-- 淘宝一次
		RA_ZHONGQIUHAPPYERNIE_CHOU_TYPE_10 = 1,				-- 淘宝十次
		RA_ZHONGQIUHAPPYERNIE_CHOU_TYPE_30 = 2,				-- 淘宝三十次
		RA_ZHONGQIUHAPPYERNIE_CHOU_TYPE_MAX = 3,
}

NEW_TOUZIJIHUA_OPERATE_TYPE = {
	NEW_TOUZIJIHUA_OPERATE_BUY = 0,					--购买月卡投资
	NEW_TOUZIJIHUA_OPERATE_FETCH = 1,				--获取月卡奖励
	NEW_TOUZIJIHUA_OPERATE_FIRST = 2,				--获取月卡立返
	NEW_TOUZIJIHUA_OPERATE_VIP_FETCH = 3,
	NEW_TOUZIJIHUA_OPERATE_FOUNDATION_FETCH = 4,	--领取成长基金
}

RA_LOTTERY_1_OPERA_TYPE = {
    RA_LOTTERY_1_OPERA_TYPE_INFO = 0,          			-- 请求活动信息
    RA_LOTTERY_1_OPERA_TYPE_DO_LOTTERY = 1,         	-- 发起抽奖请求 p1抽奖类型 (1:一抽 2：十抽)
    RA_LOTTERY_1_OPERA_TYPE_FETCH_PERSON_REWARD = 2,    -- 领取奖励请求 p1兑换序号
    RA_LOTTERY_1_OPERA_TYPE_MAX = 3,
  }

TOUZIJIHUA_FB_BOSS_OPERATE_TYPE = {
	TOUZIJIHUA_FB_BOSS_OPERATE_FB_BUY = 0,    -- 购买副本投资计划
	TOUZIJIHUA_FB_BOSS_OPERATE_FB_REWARD = 1,  -- 获取副本投资计划奖励，param：index
	TOUZIJIHUA_FB_BOSS_OPERATE_BOSS_BUY = 2,    -- 购买boss投资计划
	TOUZIJIHUA_FB_BOSS_OPERATE_BOSS_REWARD = 3,    -- 获取boss投资计划，param：index
	TOUZIJIHUA_FB_BOSS_OPERATE_SHENYU_BOSS_BUY = 4,		-- 购买神域BOSS投资计划
	TOUZIJIHUA_FB_BOSS_OPERATE_SHENYU_BOSS_REWARD  =5,	-- 获取神域BOSS投资计划，param：index
}

--单笔充值操作类型
 RA_DANBI_CHONGZHI_OPERA_TYPE = {
	RA_DANBI_CHONGZHI_OPERA_TYPE_QUERY_INFO = 0,
	RA_DANBI_CHONGZHI_OPERA_TYPE_FETCH_REWARD= 1,
}

 UPGRADE_OPERA_TYPE = {
	UPGRADE_OPERA_TYPE_INFO = 0,              -- 信息  
	UPGRADE_OPERA_TYPE_USE_IMAGE = 1,         -- 使用形象 p1:is_temporary_image p2:image_id
	UPGRADE_OPERA_TYPE_FIGHT_OUT = 2,         -- 是否出战 p1:is_fight_out 
	UPGRADE_OPERA_TYPE_UPGRADE = 3,           -- 进阶 p2:pack_num p2:is_auto_buy
	UPGRADE_OPERA_TYPE_IMAGE_UPGRADE = 4,     -- 形象进阶 p1:image_id
	UPGRADE_OPERA_TYPE_SKILL_UPGRADE = 5,     -- 技能进阶 p1:skill_idx p2:is_auto_buy
	UPGRADE_OPERA_TYPE_EQUIP_UPGRADE = 6,     -- 装备升级 p1:equip_idx
}

-- 巡游类型
CruiseType = {
	JuPai = 0,			-- 举牌
	HuaTong = 1,		-- 花童
	XinLang = 2,		-- 新郎
	HuaJiao = 3,		-- 花轿
	-- QiaoFu = 1,
	LaBa = 4,			-- 喇叭
	QiaoLuo = 5,		-- 敲锣
}


EXTREMECHALLENGE =
{
	EXTREMECHALLENGE_INFO = 0,                      -- 信息请求
	EXTREMECHALLENGE_REFRESH_TASK = 1,              -- 刷新任务
	EXTREMECHALLENGE_FETCH_REWARD = 2,              -- 领取奖励
	EXTREMECHALLENGE_INIT_TASK = 3,                 -- 初始任务
	EXTREMECHALLENGE_FETCH_ULTIMATE_REWARD = 4,     -- 领取终极奖励
}

--大小目标系统类型
ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE = {
	ROLE_BIG_SMALL_GOAL_SYSTEM_RUNE = 0,					--战魂
	ROLE_BIG_SMALL_GOAL_SYSTEM_XIANNV = 1,					--仙女
	ROLE_BIG_SMALL_GOAL_SYSTEM_XIANCHONG = 2,				--仙宠
	ROLE_BIG_SMALL_GOAL_SYSTEM_SHENZHOU_WEAPON = 3,			--异火
	ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGE = 4,					--星辉
	ROLE_BIG_SMALL_GOAL_SYSTEM_SHENSHOU = 5,				--龙器
	ROLE_BIG_SMALL_GOAL_SYSTEM_SHENYIN = 6,					--铭纹
	ROLE_BIG_SMALL_GOAL_SYSTEM_EQUIP_STRENGTHEN = 7, 		--锻造强化等级
	ROLE_BIG_SMALL_GOAL_SYSTEM_STONE = 8,					--锻造宝石等级
	ROLE_BIG_SMALL_GOAL_SYSTEM_CHINESE_ZODIAC = 9,			--生肖
	ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGQI = 10,				--圣器
	ROLE_BIG_SMALL_GOAL_SYSTEM_GREATESOLDIER = 11,			--神魔
	ROLE_BIG_SMALL_GOAL_SYSTEM_MAX = 12,
}

ROLE_BIG_SMALL_GOAL_OPERA_TYPE = {
	ROLE_BIG_SMALL_GOAL_OPERA_INFO = 0,			--请求信息
	ROLE_BIG_SMALL_GOAL_OPERA_FETCH = 1,		--领取
}

TIME_LIMIT_TITLE_CALL_TYPE = {
	Goal_FETCH = 0,				--进阶外的大小目标领取
	BUY = 1,					--直接购买
	FETCH = 2,					--领取
}

LINGCHONG_ANIMATOR_PARAM = {
	REST = UnityEngine.Animator.StringToHash("rest"),
	STATUS = UnityEngine.Animator.StringToHash("status"),
	FIGHT = UnityEngine.Animator.StringToHash("fight"),

	BASE_LAYER = 0,
	MOUNT_LAYER = 1,
}

CSA_FOUNDATION_OPERA = {
	CSA_FOUNDATION_INFO_REQ = 0,	-- 请求信息
	CSA_FOUNDATION_FETCH_REQ = 1,	-- 领取奖励，param_2填奖励索引
}

CSA_EXP_REFINE_OPERA_TYPE = {
	CSA_EXP_REFINE_OPERA_TYPE_BUY_EXP  =  0,			--  购买经验
	CSA_EXP_REFINE_OPERA_TYPE_GET_INFO = 1,				--  获取信息发送SCCSAExpRefineInfo
}

-- VIP Boss转向
VIP_BOSS_ROTATION = {
	[941] = 130,
	[942] = 180,
	[943] = 230,
	[944] = 90,
	[945] = -80,
	[946] = 45,
	[947] = 0,
	[948] = -45,
	[949] = 155,
	[950] = -180,
	[951] = -140,
	[952] = 90,
	[953] = -90,
	[954] = 45,
	[955] = 0,
	[956] = -45,
	[957] = 50,
	[958] = -90,
	[959] = 180,
	[960] = 0,
}

LIUJIE_CHUMO_BOSS_ROTATION = {
	[38000] = 90,
	[38001] = -180,
	[38002] = 180,
	[38003] = 0,
	[38004] = -27,
	[38005] = 90,
	[38006] = 90,
	[38007] = 90,
	[38008] = 90,
}

QUALITY_BOSS_ROTATION = {
	[30801] = -20,
	[30802] = -20,
	[30803] = 0,
	[30804] = 0,
	[30805] = -10,
	[30806] = 0,
	[30807] = -20,
	[30808] = -20,
	[30809] = -20,
	[30810] = -180,
	[30811] = -180,
	[30812] = -180,
	[30813] = 150,
	[30814] = 180,
	[30815] = 180,
	[30816] = -180,
	[30817] = -180,
	[30818] = 180,
	[30819] = 180,
	[30820] = -140,
	[30821] = -110,
	[30822] = -140,
	[30823] = -140,
	[30824] = -140,
	[30825] = -140,
	[30826] = -140,
	[30827] = -140,
	[30828] = -140,
	[30829] = -140,
	[30830] = 130,
	[30831] = 130,
	[30832] = 130,
	[30833] = 130,
	[30834] = 130,
	[30835] = 130,
	[30836] = 130,
	[30837] = 130,
	[30838] = 130,
	[30839] = 130,
	[30840] = 130,
	[30841] = 130,
	[30842] = 130,
	[30843] = 130,
	[30844] = 130,
	[30845] = 130,
	[30846] = 130,
	[30847] = 130,
	[30848] = 130,
	[30849] = 130,
	[30850] = -140,
	[30851] = -140,
	[30852] = -140,
	[30853] = -140,
	[30855] = -140,
	[30856] = -140,
	[30857] = -140,
	[30858] = -140,
	[30859] = -140,
}

WEAPON_BOSS_ROTATION = {
	[20000] = 90,
	[20001] = 100,
	[20002] = 130,
	[20003] = 130,
	[20004] = 130,
	[20005] = 130,
	[20006] = 130,
	[20007] = 130,
	[20010] = -140,
	[20010] = -140,
	[20011] = -140,
	[20012] = -140,
	[20013] = -140,
	[20014] = -140,
	[20015] = -140,
	[20016] = -140,
	[20017] = -140,
	[20020] = 140,
	[20021] = 140,
	[20022] = 140,
	[20023] = 150,
	[20024] = 140,
	[20025] = 140,
	[20026] = 140,
	[20027] = 140,
	[20030] = 140,
	[20031] = 150,
	[20032] = 160,
	[20033] = 170,
	[20034] = 160,
	[20035] = 170,
	[20036] = 170,
	[20037] = 170,
	[20040] = 130,
	[20041] = 130,
	[20042] = 130,
	[20043] = 130,
	[20044] = 130,
	[20045] = 130,
	[20046] = 130,
	[20047] = 130,
	[20050] = -140,
	[20051] = 180,
	[20052] = 180,
	[20053] = 180,
	[20054] = 180,
	[20055] = 180,
	[20056] = 180,
	[20057] = 180,
	[20060] = -170,
	[20061] = -150,
	[20062] = -150,
	[20063] = -130,
	[20064] = -160,
	[20065] = -130,
	[20066] = -150,
	[20067] = -140,
	[20070] = -130,
	[20071] = -140,
	[20072] = -140,
	[20073] = -140,
	[20074] = -140,
	[20075] = -140,
	[20076] = -140,
	[20077] = -140,
}

HeFu_BOSS_ROTATION = {
	[39000] = 170,
	[39001] = -80,
	[39002] = -50,
	[39003] = 90,
	[39005] = 180,
	[39006] = -90,
	[39007] = -20,
	[39008] = 90,
}

-- 神器请求类型
SHENQI_OPERA_REQ_TYPE =
{
	SHENQI_OPERA_REQ_TYPE_INFO = 0,							-- 请求所有信息
	SHENQI_OPERA_REQ_TYPE_DECOMPOSE = 1 ,					-- 分解 param_1:需要分解材料id	param_2:分解材料的个数
	SHENQI_OPERA_REQ_TYPE_SHENBING_INLAY = 2,				-- 神兵镶嵌请求 param_1:id  param_2:部位 param_3:品质
	SHENQI_OPERA_REQ_TYPE_SHENBING_UPLEVEL = 3,				-- 神兵升级请求 param_1:id  param_2:是否自动升级 param_3:一键发包数
	SHENQI_OPERA_REQ_TYPE_SHENBING_USE_IMAGE = 4,			-- 神兵更换使用形象 param_1:使用形象id(0取消使用)
	SHENQI_OPERA_REQ_TYPE_SHENBING_USE_TEXIAO = 5,			-- 神兵更换特效形象 param_1:使用特效id(0取消使用)
	SHENQI_OPERA_REQ_TYPE_BAOJIA_INLAY = 6,					-- 宝甲镶嵌请求 param_1:id  param_2:部位 param_3:品质
	SHENQI_OPERA_REQ_TYPE_BAOJIA_UPLEVEL = 7,				-- 宝甲升级请求 param_1:id  param_2:是否自动升级 param_3:一键发包数
	SHENQI_OPERA_REQ_TYPE_BAOJIA_USE_IMAGE = 8,				-- 宝甲更换使用形象 param_1:使用形象id(0取消使用)
	SHENQI_OPERA_REQ_TYPE_BAOJIA_USE_TEXIAO = 9,			-- 宝甲更换特效形象 param_1:使用特效id(0取消使用)
	SHENQI_OPERA_REQ_TYPE_SHENGBING_TEXIAO_ACTIVE = 10,		-- 激活神兵特效 param_1 神兵id
	SHENQI_OPERA_REQ_TYPE_BaoJia_TEXIAO_ACTIVE = 11,		-- 激活宝甲特效 param_1 宝甲id
	SHENQI_OPERA_REQ_TYPE_BAOJIA_OPEN_TEXIAO = 12, 			-- 宝甲特效显示
	SHENQI_OPERA_REQ_TYPE_MAX = 13,
}
SHENQI_SC_INFO_TYPE =										-- 神器下发信息类型
{
	SHENQI_SC_INFO_TYPE_SHENBING = 0,						-- 神兵
	SHENQI_SC_INFO_TYPE_BAOJIA = 1,							-- 宝甲
	SHENQI_SC_INFO_TYPE_MAX = 2,
}

ROLE_APPE_CHANGE_TYPE = {
	ROLE_APPE_CHANGE_TYPE_WUQICOLOR = 0,						 -- 转职装备武器颜色（首充武器相关）
}

XIANZUNKA_OPERA_REQ_TYPE = {
	XIANZUNKA_OPERA_REQ_TYPE_ALL_INFO = 0,						 -- 请求所有信息
	XIANZUNKA_OPERA_REQ_TYPE_BUY_CARD = 1,						 -- 购买仙尊卡 param_1 : 仙尊卡类型
	XIANZUNKA_OPERA_REQ_TYPE_FETCH_DAILY_REWARD = 2,			 -- 拿取每日奖励 param_1 :仙尊卡类型
	XIANZUNKA_OPERA_REQ_TYPE_ACTIVE = 3,						 -- 激活永久仙尊 param_1:仙尊卡类型

	XIANZUNKA_OPERA_REQ_TYPE_MAX
}

CS_SPOUSE_HOME_TYPE = {
	CS_SPOUSE_HOME_TYPE_ALL_INFO = 0,					-- 请求所有消息
	CS_SPOUSE_HOME_TYPE_FURNITURE_EQUIT = 1,			-- 装备家具 p1 房间索引 p2 槽位索引 p3 背包索引
	CS_SPOUSE_HOME_TYPE_FURNITURE_TAKE_OFF = 2,			-- 卸下家具 p1 房间索引 p2 槽位索引
	CS_SPOUSE_HOME_TYPE_BUY_THEME = 3,					-- 购买房间 p1 主题索引
	CS_SPOUSE_HOME_TYPE_VIEW_OTHER_PEOPLE_ROOM = 4,		-- 查看房间 p1 对方uid
	CS_SPOUSE_HOME_TYPE_BUY_FURNITURE_ITEM = 5,			-- 购买道具 p1 物品id   p2 物品数量
	CS_SPOUSE_HOME_TYPE_FRIEND_LIST_INFO = 6,			-- 请求下发好友信息
	CS_SPOUSE_HOME_TYPE_GUILD_MEMBER_INFO = 7,			-- 请求下发盟友信息
	CS_SPOUSE_HOME_TYPE_BUY_THEME_FOR_LOVER = 8,		-- 购买房间 p1 uid p2 主题索引
	CS_SPOUSE_HOME_TYPE_FURNITURE_EQUIT_FOR_LOVER = 9,	-- 装备家具 p1 uid p2 房间索引 p3 家具类型 p4 背包索引
}

AUDIT_VERSION_RAND_APPEARANCE_KEY = {
	[1] = {3, 6, 7, 5, 4},
	[2] = {6, 4, 5, 7, 3},
	[3] = {7, 5, 6, 3, 4},
	[4] = {5, 3, 7, 4, 6},
	[5] = {4, 6, 5, 3, 7},
}

--主题类型
SPOUSE_HOME_THEME_TYPE = {
	GARDEN = 0,					--温馨田园
	MANOR = 1,					--豪华庄园
}

--家具类型
SPOUSE_HOME_FURNITURE_MAX_IMPRINT_SLOT_TYPE = {
	FURNITURE_COUNT_BED = 0,						-- 床
	FURNITURE_COUNT_BLANKET = 1,					-- 毛毯
	FURNITURE_COUNT_WARDROBE = 2,					-- 衣柜
	FURNITURE_COUNT_SCREEN = 3,						-- 屏风
	FURNITURE_COUNT_MIRROR = 4,						-- 镜子
	FURNITURE_COUNT_CHAIR = 5,						-- 椅子
	FURNITURE_COUNT_PLANT_LEFT = 6,					-- 植物（左）
	FURNITURE_COUNT_PLANT_RIGHT = 7,				-- 植物（右）
	FURNITURE_COUNT_LAMP_LEFT = 8,					-- 灯（左）
	FURNITURE_COUNT_LAMP_RIGHT = 9,					-- 灯（右）
	FURNITURE_COUNT_DECORATION = 10,				-- 装饰
	FURNITURE_COUNT_CARPET = 11,					-- 地毯
	FURNITURE_COUNT_DESK = 12,						-- 书桌
	FURNITURE_COUNT_DINING_TABLE = 13,				-- 餐桌
}

--聚宝盆请求操作
RA_COLLECT_TREASURE_OPERA_TYPE = {
	RA_COLLECT_TREASURE_OPERA_TYPE_INFO = 0,	-- 信息
	RA_COLLECT_TREASURE_OPERA_TYPE_ROLL = 1,		-- 开始摇奖
	RA_COLLECT_TREASURE_OPERA_TYPE_REWARD = 2,		-- 获取奖励
}

LITTLE_HELPER_COMPLETE_TYPE = {
  LITTLE_HELPER_COMPLETE_TYPE_EASY_BOSS = 0,          --简单boss
  LITTLE_HELPER_COMPLETE_TYPE_DIFFICULT_BOSS = 1,        --困难boss
  LITTLE_HELPER_COMPLETE_TYPE_BABY_BOSS = 2,          --宝宝boss
  LITTLE_HELPER_COMPLETE_TYPE_SUIT_BOSS = 3,          --套装boss
  LITTLE_HELPER_COMPLETE_TYPE_DEMON_BOSS = 4,          --神魔boss
  LITTLE_HELPER_COMPLETE_TYPE_PET_ADVENTURE = 5,        --宠物奇遇
  LITTLE_HELPER_COMPLETE_TYPE_ESCORT_FAIRY = 6,        --护送仙女
  LITTLE_HELPER_COMPLETE_TYPE_EXP_FB = 7,            --经验副本
  LITTLE_HELPER_COMPLETE_TYPE_TOWER_DEFENSE_FB = 8,      --塔防副本
  LITTLE_HELPER_COMPLETE_TYPE_CYCLE_TASK = 9,          --跑环任务
  LITTLE_HELPER_COMPLETE_TYPE_EXP_TASK = 10,          --经验任务
  LITTLE_HELPER_COMPLETE_TYPE_GUILD_TASK = 11,        --仙盟任务

  LITTLE_HELPER_COMPLETE_TYPE_MAX = 12,
}

-- 挂机塔请求类型
RUNE_TOWER_FB_OPER_TYPE = {
	RUNE_TOWER_FB_OPER_AUTOFB = 0,
	RUNE_TOWER_FB_OPER_REFRESH_MONSTER = 1,
}

OFFEXP_NOTIFY_REASON = {							-- 通知原因
	WELFARE_INFO_DAFAULT = 0,
	ACCOUNT_LOGIN_INFO = 1,								-- 累计登陆信息
	OFFLINE_EXP_INFO = 2,								-- 离线经验信息
	ONLINE_GIFT_INFO = 3,								-- 在线礼物信息
	OFFLINE_EXP_NOTICE = 4,								-- 离线经验结算信息弹框提示
}

TUMO_OPERA_TYPE = {
	TUMO_OPERA_TYPE_GET_INFO = 0,					-- 获取任务信息
	TUMO_OPERA_TYPE_FETCH_COMPLETE_ALL_REWARD = 1,	-- 领取全部完成奖励
	TUMO_OPERA_TYPE_COMMIT_TASK = 2,				-- 提交任务 p1:index p2: 1 提交全部 0 单个
	TUMO_OPERA_TYPE_FETCH_REWARD = 3,				-- 领取奖励 p1:index p2: 1 普通 2 双倍 3 三倍
	TUMO_OPERA_TYPE_FETCH_EXP_BALL_REWARD = 4,		-- 领取经验球奖励
}

EQUIP_BAPTIZE_OPERA_TYPE = {
	EQUIP_BAPTIZE_OPERA_TYPE_ALL_INFO = 0,			-- 所有信息
	EQUIP_BAPTIZE_OPERA_TYPE_OPEN_SLOT = 1,			-- 开启槽 			param_1 装备部位   param_2  洗炼槽索引
	EQUIP_BAPTIZE_OPERA_TYPE_LOCK_OR_UNLOCK = 2,	-- 加锁 or 去锁		param_1 装备部位   param_2  洗炼槽索引
	EQUIP_BAPTIZE_OPERA_TYPE_BEGIN_BAPTIZE = 3,		-- 开始洗炼 		param_1 洗练位置   param_2  是否使用元宝   param_3  特殊洗练石
}

EQUIP_BAPTIZE_SPECIAL_TYPE = {
	EQUIP_BAPTIZE_SPECIAL_TYPE_NONE = 0,		-- 紫
	EQUIP_BAPTIZE_SPECIAL_TYPE_ORANGE = 1,		-- 橙
	EQUIP_BAPTIZE_SPECIAL_TYPE_RED = 2,			-- 红
	EQUIP_BAPTIZE_SPECIAL_TYPE_PURPLE = 3,		-- 紫
}


ADVANCE_NOTICE_OPERATE_TYPE = {
  ADVANCE_NOTICE_GET_INFO = 0,					--等级功能预告奖励信息
  ADVANCE_NOTICE_FETCH_REWARD = 1,				--等级功能预告领取奖励
  ADVANCE_NOTICE_DAY_GET_INFO = 2,				--天数功能预告奖励信息
  ADVANCE_NOTICE_DAY_FETCH_REWARD = 3,			--天数功能预告领取奖励
}

GIVE_ITEM_OPERA_TYPE = {
	GIVE_ITEM_OPERA_TYPE_INFO = 0,				--请求信息 P1: 1为赠送记录 0为收到记录
}

ADVANCE_NOTICE_TYPE = {
	ADVANCE_NOTICE_TYPE_LEVEL = 0,				--等级功能预告
	ADVANCE_NOTICE_TYPE_DAY = 1,				--天数功能预告
}

GIFT_BAG_TYPE = {
	GIFT_BAG_TYPE_DEF = 1,   				-- 固定礼包
	GIFT_BAG_TYPE_RAND = 2,  				-- 随机礼包
}

PURCHASE_NOTICE_TYPE = {				
	NOTICE_TYPE_ADD = 0,					-- 市场收购添加一条
	NOTICE_TYPE_ALL = 1,					-- 下发所有
}

ACTIVITY_REWARD_TYPE = {
	REWARD_TYPE_SHIZHUANG = 0,				-- 时装
	REWARD_TYPE_WEAPON = 1,					-- 武器
	REWARD_TYPE_MOUNT = 2,					-- 坐骑
	REWARD_TYPE_TITLE = 3,					-- 称号
	REWARD_TYPE_WING = 4,					-- 羽翼
}

JUMP_MODLE_TYPE = {
	WING_HUAN_HUA = 12,						--羽翼幻化
	MOUNT_HUAN_HUA = 13,					--坐骑幻化
	FASHION_HUAN_HUA = 18,					--时装幻化
	HALO_HUAN_HUA = 51,						--光环幻化
	FIGHT_MOUNT_HUAN_HUA = 60,				--战骑幻化
	GODDESS_HALO = 52,						--仙女光环幻化
	GODDESS_FRONT = 53,						--仙女仙阵幻化
	GODDESS_HUANHUA = 63,					--仙女幻化
	SPIRIT_HUANHUA = 66,					--宠物幻化
	FOOT_HUAN_HUA = 83, 					--足迹幻化
	FABAO_HUANHUA = 90,						--法宝幻化
	WAIST_HUANHUA = 101,					--腰饰幻化
	TOUSHI_HUANHUA = 102,					--头饰幻化
	MASK_HUANHUA = 103,						--面饰幻化
	QILINBI_HUANHUA = 104,					--麒麟臂幻化
	LING_HUANHUA = 106,						--灵童幻化
}

FASHION_SHOW_TYPE = {
	ROLE = 1,
	WEAPON = 2,
	MOUNT = 3,
	WING = 4,
	HALO = 5,
	FOOT = 6,
	FIGHTMOUNT = 7,
	GODDRESS = 8,
	GODDRESS_HALO = 9,
	GODDRESS_FAZHEN = 10,
	SPIRIT = 11,
	SHENG_WU = 12,
}

JUMP_PARAM1_TYPE = {
	LINGZHU = 0,							--灵珠
	XIANBAO= 1,								--仙宝
	LINGCHONG = 2,							--灵童
	LINGGONG = 3,							--灵弓			
	LINGQQ = 4,								--灵骑
	WEIYAN = 5,								--尾焰
	SHOUHUAN = 6,							--手环
	TAIl = 7,								--尾巴
	FLYPEt = 8,								--飞宠
}
YUNYOU_OPERATE_TYPE = {
	TYPE_BOSS_INFO_REQ = 0, 				--云游boss请求信息
	TYPE_BOSS_COUNT_ALL_SCENE = 1,			--云游所以boss信息
}

FIGHTBACK_TYPE = {
	NOTIFY_LIST_ADD = 1, 				--添加反击名单
	NOTIFY_LIST_DEL = 2,				--移除反击名单
}

CROSS_BINGJINGZHIDI_DEF = {
	MAP_ID = 8002,											-- 地图ID
	CROSS_BIANJINGZHIDI_TASK_MAX = 5,						-- 跨服边境之地 任务最大个数
	CROSS_BIANJINGZHIDI_MAX_REWARD_ITEM_COUNT = 10, 		-- 跨服边境之地 奖励物品最大数
	CROSS_BIANJINGZHIDI_MAX_BOSS_TYPE = 5, 					-- 跨服边境之地 Boss最大个数
	BOSS_HURT_INFO_RANK_MAX  = 6, 							-- 跨服边境之地 排行最大个数
}

CROSS_CHALLENGEFIELD_OPERA_REQ = {
	CROSS_CHALLENGEFIELD_OPERA_REQ_OPPONENT_INFO = 0,		--请求对手外观  p1:是否获取前几名(1/0)
	CROSS_CHALLENGEFIELD_OPERA_REQ_RANK_INFO = 1,			--请求英雄榜(前100名)
	CROSS_CHALLENGEFIELD_OPERA_REQ_FETCH_REWARD = 2,		--领取奖励
	CROSS_CHALLENGEFIELD_OPERA_REQ_SELFT_INFO = 3,			--获得自己信息和战报
	CROSS_CHALLENGEFIELD_OPERA_REQ_FIGHT = 4,		--挑战请求 p1:对手index p2:是否无视排名变化 p3:rank_pos
	CROSS_CHALLENGEFIELD_OPERA_REQ_REFRESH = 5,		--刷新挑战列表 
	CROSS_CHALLENGEFIELD_OPERA_REQ_READY = 6,		--请求准备正式开始战斗倒计时 
}

-- 幸运云购操作类型
RA_LUCKY_CLOUD_BUY_OPERA_TYPE = {
	RA_LUCKY_CLOUD_BUY_TYPE_INFO = 0,		-- 请求信息
	RA_LUCKY_CLOUD_BUY_TYPE_BUY = 1,		-- 购买
	RA_LUCKY_CLOUD_BUY_TYPE_OPEN = 2,		-- 打开面板（参数1 上次打开面板的时间戳）
	RA_LUCKY_CLOUD_BUY_TYPE_CLOSE = 3,		-- 关闭面板
	RA_LUCKY_CLOUD_BUY_TYPE_LUCKY = 4,		-- 幸运儿信息

	RA_LUCKY_CLOUD_BUY_TYPE_INFO
}

AUDIT_VERSION_ROLE_CAMERA_ROTATION = {
	[1] = {ROTATION_X = -10, ROTATION_Y = -90, DISTANCE = 2},
	[2] = {ROTATION_X = -10, ROTATION_Y = -90, DISTANCE = 2},
	[3] = {ROTATION_X = 0, ROTATION_Y = -90, DISTANCE = 1.5},
	[4] = {ROTATION_X = -10, ROTATION_Y = -90, DISTANCE = 1.5},
}

-- 私聊在线状态通知
SINGLE_CHAT_REQ = {
	SINGLE_CHAT_REQ_ADD = 0,		 	-- 添加监听对象在线状态 p1:plat_type p2:target_id
	SINGLE_CHAT_REQ_DELETE = 1,			-- 删除单个监听对象在线状态 p1:plat_type p2:target_id
	SINGLE_CHAT_REQ_DELETE_ALL = 2,		-- 删除全部监听对象在线状态 
}

ROLE_ONLINE_TYPE = {
	ROLE_ONLINE_TYPE_OFF = 0,    -- 离线
	ROLE_ONLINE_TYPE_ON = 1,      -- 在线
	ROLE_ONLINE_TYPE_CROSS = 2,    -- 跨服
}

CROSS_EQUIP_REQ_TYPE = 
{
	CROSS_EQUIP_REQ_TYPE_INFO = 0,					-- 请求所有信息
	CROSS_EQUIP_REQ_TYPE_DOUQI_GRADE_UP = 1,		-- 斗气进阶请求
	CROSS_EQUIP_REQ_TYPE_DOUQI_XIULIAN = 2,			-- 斗气修炼请求

	CROSS_EQUIP_REQ_TYPE_ROLL = 3,					-- 抽奖请求 param1--roll_type  param_2--roll_times_type

	CROSS_EQUIP_REQ_TAKEOFF  =  4,	--  脱下装备  param1--equipment_index(参考普通装备)
	CROSS_EQUIP_REQ_LIANZHI  =  5,	--  炼制装备  param1--equipment_index
	CROSS_EQUIP_REQ_ONE_EQUIP_INFO  =  6,	--  单个装备信息  param1--equipment_index
	CROSS_EQUIP_REQ_ALL_EQUIP_INFO  =  7,	--  所有装备信息

	CROSS_EQUIP_REQ_TYPE_MAX = 5,
}