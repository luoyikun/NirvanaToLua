MAX_RANK_COUNT = 17

RankKind = {
	Person = 1,										-- 个人排行
	Guild = 2,										-- 仙盟排行
	Cross = 3,										-- 跨服排名
	Peakathletics = 4,								-- 巅峰竞技
	MultiPlayer = 5,								-- 团队竞技
}

PERSON_RANK_TYPE = {
	PERSON_RANK_TYPE_CAPABILITY_ALL = 0,						-- 综合战力榜
	PERSON_RANK_TYPE_LEVEL = 1,									-- 等级榜
	PERSON_RANK_TYPE_XIANNV_CAPABILITY = 2,						-- 女神战力榜
	PERSON_RANK_TYPE_EQUIP = 3,									-- 装备战力榜
	PERSON_RANK_TYPE_ALL_CHARM = 4,								-- 魅力总榜
	PERSON_RANK_TYPE_MOUNT = 8,									-- 坐骑战力榜
	PERSON_RANK_TYPE_WING = 11,									-- 羽翼战力榜
	PERSON_RANK_TYPE_QINGYUAN = 13,								-- 情缘属性战斗力
	PERSON_RANK_TYPE_RAND_RECHARGE = 19,						-- 充值排行
	PERSON_RANK_TYPE_RA_CONSUME_GOLD = 20,						-- 消费排行
	PERSON_RANK_TYPE_BABY = 27,									-- 宝宝属性战斗力
	PERSON_RANK_TYPE_RA_DAY_CHONGZHI_NUM = 42,					-- 随机活动每日充值
	PERSON_RANK_TYPE_RA_DAY_XIAOFEI_NUM = 43,					-- 随机活动每日充值
	PERSON_RANK_TYPE_HALO = 44,									-- 光环战力榜
	PERSON_RANK_TYPE_FIGHT_MOUNT = 52,							-- 战骑战力榜
	PERSON_RANK_TYPE_SHENGONG = 45,								-- 神弓战力榜
	PERSON_RANK_TYPE_SHENYI = 46,								-- 神翼战力榜
	PERSON_RANK_TYPE_LITTLE_PET = 47,							-- 小宠物战力
	PERSON_RANK_TYPE_CAPABILITY_JINGLING = 48,					-- 精灵战力榜
	PERSON_RANK_TYPE_EQUIP_STRENGTH_LEVEL = 50,					-- 全身装备强化总等级榜
	PERSON_RANK_TYPE_STONE_TOTAL_LEVEL = 51,					-- 全身宝石总等级榜
	PERSON_RANK_TYPE_WORLD_RIGHT_ANSWER = 53, 					-- 世界题目对题榜
	PERSON_RANK_TYPE_FIGHTING_CHALLENGE = 54,					-- 挖矿里的挑衅排行榜
	PERSON_RANK_TYPE_DAY_CHARM = 55,							-- 每日魅力榜
	PERSON_RANK_TYPE_DAY_CHARM = 55,							-- 每日魅力榜
	PERSON_RANK_FISH_PLACE = 56,								-- 钓鱼名次
	PERSON_RANK_STEAL_FISH_PLACE = 57,							-- 偷鱼名次
	PERSON_RANK_TYPE_PLANTING_TREE_PLANTING = 58,				-- 植树活动植树次数排行
	PERSON_RANK_TYPE_PLANTING_TREE_WATERING = 59,				-- 植树活动浇水次数排行
	PERSON_RANK_CRYSTA_DALARAN_STEAL_NUM = 60,					-- 达拉然水晶偷取榜
	PERSON_RANK_CRYSTA_DALARAN_BE_STEALED_NUM = 61,				-- 达拉然水晶被偷榜
	PERSON_RANK_TYPE_FABAO = 62,								-- 法宝
	PERSON_RANK_TYPE_SHIZHUANG = 63,							-- 时装
	PERSON_RANK_TYPE_SHIZHUANG_WUQI = 64,						-- 神兵
	PERSON_RANK_TYPE_FOOTPRINT = 65,							-- 足迹
	PERSON_RANK_TYPE_JINGJIE = 66,								-- 境界
	PERSON_RANK_TYPE_RUNE_TOWER_LAYER = 67,						-- 符文塔层数榜
	PERSON_RANK_TYPE_YAOSHI = 68,								-- 腰饰战力榜
	PERSON_RANK_TYPE_TOUSHI = 69,								-- 头饰战力榜
	PERSON_RANK_TYPE_QILINBI = 70,								-- 麒麟臂战力榜
	PERSON_RANK_TYPE_MASK = 71,									-- 面具战力榜
	PERSON_RANK_TYPE_LINGZHU = 72,								-- 灵珠战力榜
	PERSON_RANK_TYPE_XIANBAO = 73,								-- 仙宝战力榜
	PERSON_RANK_TYPE_LINGTONG = 74,								-- 灵童战力榜
	PERSON_RANK_TYPE_LINGGONG = 75,								-- 灵弓战力榜
	PERSON_RANK_TYPE_LINGQI = 76,								-- 灵骑战力榜
	PERSON_RANK_TYPE_WEIYAN = 77,								-- 尾焰战力榜
	PERSON_RANK_TYPE_SHOUHUAN = 78,								-- 手环战力榜
	PERSON_RANK_TYPE_TAIL = 79,									-- 尾巴战力榜
	PERSON_RANK_TYPE_FLYPET = 80,								-- 飞宠战力榜
	PERSON_RANK_TYPE_ClOAk = 81,								-- 披风战力榜
	PERSON_RANK_TYPE_LINGREN = 82,								-- 灵刃战力榜
	PERSON_RANK_TYPE_ROLE_PATA_LAYER = 83,						-- 个人爬塔本层数榜
	PERSON_RANK_TYPE_RA_PROFESS_MALE = 84,						-- 表白排行男榜
	PERSON_RANK_TYPE_RA_PROFESS_FEMALE = 85,					-- 表白排行女榜
	PERSON_RANK_TYPE_IMAGE_COMPETITION = 86,					-- 随机活动比拼排行
	PERSON_RANK_TYPE_RA_CHONGZHI2 = 87,							-- 至尊充值排行榜2
}

RANK_TAB_TYPE = {
	ZHANLI = 1,
	LEVEL = 2,
	EQUIP = 3,
	MOUNT = 4,
	WING = 5,
	HALO = 6,
	FIGHT_MOUNT = 7,
	SPIRIT = 8,
	GODDESS = 9,
	SHENGONG = 10,
	SHENYI = 11,
	FORGE = 12,
	BAOSHI = 13,
	FABAO = 14,
	FASHION = 15,
	SHENBING = 16,
	FOOT = 17,
	MEILI = 18,
	DATI = 19,
	MINGREN = 20 ,
	QINGYUAN = 21,
	BAOBAO = 22,
	LITTLEPET = 23,
	YAOSHI = 24,
	TOUSHI = 25,
	QILINBI = 26,
	MASK = 27,
	LINGZHU = 28,
	XIANBAO = 29,
	LINGTONG = 30,
	LINGGONG = 31,
	LINGQI = 32,
	WEIYAN = 33,
	SHOUHUAN = 34,
	TAIL = 35,
	FLYPET = 36,
	CLOAK = 37,
	LINGREN = 38,
	KUAFUZHANLI = 39,
	KUAFULEVEL = 40,
}

PERSON_RANK_TYPE_NEED_EXCHANGE = {
	[PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT] = true,
	[PERSON_RANK_TYPE.PERSON_RANK_TYPE_WING] = true,
	[PERSON_RANK_TYPE.PERSON_RANK_TYPE_HALO] = true,
	[PERSON_RANK_TYPE.PERSON_RANK_TYPE_FABAO] = true,
	[PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHIZHUANG] = true,
	[PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHIZHUANG_WUQI] = true,
	[PERSON_RANK_TYPE.PERSON_RANK_TYPE_FOOTPRINT] = true,
	[PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENGONG] = true,
	[PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENYI] = true,
	[PERSON_RANK_TYPE.PERSON_RANK_TYPE_FIGHT_MOUNT] = true,
	[PERSON_RANK_TYPE.PERSON_RANK_TYPE_YAOSHI] = true,
	[PERSON_RANK_TYPE.PERSON_RANK_TYPE_TOUSHI] = true,
	[PERSON_RANK_TYPE.PERSON_RANK_TYPE_QILINBI] = true,
	[PERSON_RANK_TYPE.PERSON_RANK_TYPE_MASK] = true,
	[PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGZHU] = true,
	[PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANBAO] = true,
	[PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGTONG] = true,
	[PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGGONG] = true,
	[PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGQI] = true,
	[PERSON_RANK_TYPE.PERSON_RANK_TYPE_WEIYAN] = true,
	[PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHOUHUAN] = true,
	[PERSON_RANK_TYPE.PERSON_RANK_TYPE_TAIL] = true,
	[PERSON_RANK_TYPE.PERSON_RANK_TYPE_FLYPET] = true,
	[PERSON_RANK_TYPE.PERSON_RANK_TYPE_ClOAk] = true,
	[PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGREN] = true,
}

--情缘类型
COUPLE_RANK_TYPE = {
	[13] = 0,	--战力榜
	[27] = 1,	--夫妻宝宝战力榜
	[47] = 2,	--夫妻小宠物战力榜
}

--排行榜顶部按钮页面
RANKPANEL = {
	GEREN = 1,
	MEILI = 2,
	QINGYUAN = 3,
	MINGREN = 4,
	KUAFU = 5,
}

ROLE_MODEL_1 = 1001001
ROLE_MODEL_2 = 1002001
ROLE_MODEL_3 = 1003001

ROLE_MODEL_1_WEAPON = 900100101
ROLE_MODEL_2_WEAPON = 910100101
ROLE_MODEL_3_WEAPON = 920100101
ROLE_MODEL_WING = 8001001

RankData = RankData or BaseClass()

function RankData:__init()
	if RankData.Instance then
		print_error("[RankData] Attemp to create a singleton twice !")
	end
	RankData.Instance = self
	self.last_snapshot_time = 0
	self.rank_type = 0
	self.rank_list = {}
	self.user_id = 0
	self.user_name =""
	self.sex = 0
	self.prof = 0
	self.camp = 0
	self.reserved = 0
	self.level = 0
	self.rank_value = 0
	self.world_level = 0
	self.top_user_level = 0
	self.world_level = 0
	self.top_user_level = 0
	self.current_user_index = 1
	self.text = Language.Rank.NotActive
	self.check_return_flag = false -- 从角色查看返回排行榜的标记
	self.rank_type_list = {--要跟 RANK_TAB_TYPE 吻合
		[1] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_ALL,			--战力榜
		[2] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_LEVEL,					--等级榜
		[3] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP,					--装备榜
		[4] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT,					--坐骑榜
		[5] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_WING,						--羽翼榜
		[6] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_HALO,						--光环榜
		[7] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_FIGHT_MOUNT,				--战骑
		[8] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_JINGLING,		--精灵总榜
		[9] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANNV_CAPABILITY,		--女神总榜
		[10] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENGONG,					--神弓榜
		[11] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENYI,					--神翼榜
		-- PERSON_RANK_TYPE.PERSON_RANK_TYPE_ALL_CHARM, 				--魅力总榜
		[12] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP_STRENGTH_LEVEL,		--强化总榜
		[13] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_STONE_TOTAL_LEVEL,		--宝石总榜
		[14] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_FABAO,					--法宝
		[15] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHIZHUANG,				--时装
		[16] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHIZHUANG_WUQI,			--神兵
		[17] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_FOOTPRINT,				--足迹
		[18] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_DAY_CHARM,				--魅力总榜
		[19] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_WORLD_RIGHT_ANSWER,		--答题
		[24] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_YAOSHI,					--腰饰
		[25] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_TOUSHI,					--头饰
		[26] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_QILINBI,					--麒麟臂
		[27] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_MASK,						--面具
		[28] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGZHU,					--灵珠
		[29] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANBAO,					--仙宝
		[30] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGTONG,					--灵童
		[31] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGGONG,					--灵弓
		[32] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGQI,					--灵骑
		[33] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_WEIYAN,					--尾焰
		[34] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHOUHUAN,					--手环
		[35] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_TAIL,						--尾巴
		[36] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_FLYPET,					--飞宠
		[37] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_ClOAk,					--披风
		[38] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGREN,					--灵刃
		[39] = CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_CAPABILITY_ALL,		--跨服战力
		[40] = CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_ROLE_LEVEL,			--跨服等级
	}
	self.mingren_info_list = {}
	self.mingren_index_flag = {}
	self.mingren_id_list = {}
	self.red_point_flag = true
	self.famous_list = {}
	self.couple = {}
	self.cur_top_type = RANKPANEL.GEREN
	RemindManager.Instance:Register(RemindName.Rank, BindTool.Bind(self.GetRemind, self))
end

function RankData:__delete()
	self.cur_top_type = RANKPANEL.GEREN
	RemindManager.Instance:UnRegister(RemindName.Rank)
	RankData.Instance = nil
end

-- 个人排行返回
function RankData:OnGetPersonRankListAck(protocol)
	self.last_snapshot_time = protocol.last_snapshot_time
	self.rank_type = protocol.rank_type
	self.kuafu_rank_type = nil
	self.rank_list = protocol.rank_list
	for k, v in ipairs(self.rank_list) do
		--记录头像参数
		AvatarManager.Instance:SetAvatarKey(v.user_id, v.avatar_key_big, v.avatar_key_small)
	end

	if self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_DAY_CHONGZHI_NUM then
		local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
		local num = 0
		for k,v in pairs(self.rank_list) do
			if v.user_id == role_id then
				num = k
				break
			end
		end
		KaifuActivityData.Instance:SetRank(num)
		KaifuActivityData.Instance:SetDailyChongZhiRank(self.rank_list)
		KaifuActivityCtrl.Instance:FlushKaifuView()
	elseif self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_DAY_XIAOFEI_NUM then
		local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
		for k,v in pairs(self.rank_list) do
			if v.user_id == role_id then
				KaifuActivityData.Instance:SetRankLevel(k)
			end
		end
		
		KaifuActivityData.Instance:SetDailyXiaoFeiRank(self.rank_list)
		KaifuActivityCtrl.Instance:FlushKaifuView()
	elseif self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_RUNE_TOWER_LAYER then
		RuneData.Instance:SetRuneRankInfo(self.rank_list)
		RuneCtrl.Instance:FlushRankView()
	elseif self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_ROLE_PATA_LAYER then
		FuBenData.Instance:TowerRankInfo(self.rank_list)
		FuBenCtrl.Instance:FlushTowerRank()
	elseif self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_PROFESS_MALE then
		BiaoBaiQiangData.Instance:SetMaleRankInfo(self.rank_list)
		BiaoBaiQiangCtrl.Instance:FlushRankView()
		return
	elseif self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_PROFESS_FEMALE then
		BiaoBaiQiangData.Instance:SetFemaleRankInfo(self.rank_list)
		BiaoBaiQiangCtrl.Instance:FlushRankView()
		return
	elseif self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_IMAGE_COMPETITION then
		BiPingActivityData.Instance:SetImageRankCfg(self.rank_list)
		BiPingActivityCtrl.Instance:FlushRankView()
		BiPingActivityCtrl.Instance:FlushView()
	elseif CompetitionActivityData.Instance:GetBiPinRankType(self.rank_type) and CompetitionActivityData.Instance:GetBiPinRank() then
		self:SortRank(self.rank_type)
		CompetitionActivityData.Instance:SetRankData(self.rank_type)
	end
	self:SortRank(self.rank_type)
end

-- 仙盟排行返回
function RankData:OnGetGuildRankListAck(protocol)
	self.rank_type = protocol.rank_type
	self.kuafu_rank_type = nil
	self.rank_list = protocol.rank_list
end

-- 仙盟排行返回
function RankData:OnGetGuildWarRankListAck(protocol)
	self.guildwar_rank_list = protocol.rank_list
end

function RankData:GetGetGuildWarRankListAck()
	return self.guildwar_rank_list or {}
end

function RankData:GetGetGuildWarRankListAckInfo(index)
	return self.guildwar_rank_list[index]
end

--队伍排行返回
function RankData:OnGetTeamRankListAck(protocol)
	self.rank_type = protocol.rank_type
	self.kuafu_rank_type = nil
	self.rank_list = protocol.rank_list
end

function RankData:GetRankType()
	return self.rank_type
end

function RankData:GetIdByIndex(index)
	return self.mingren_id_list[index]
end

function RankData:SetMingrenData(data)
	local remove_key = 0
	local flag = false
	for k, v in pairs(self.mingren_id_list) do
		if v == data.role_id then
			self.mingren_info_list[k] = TableCopy(data)
			remove_key = k
			flag = true
			-- Scene.Instance:FlushMingRenList()
			break
		end
	end

	self.mingren_id_list[remove_key] = nil
	return flag
end

function RankData:GetMingrenData()
	return self.mingren_info_list
end

function RankData:SetFamousList(famous_list)
	self.famous_list = famous_list
	if self.red_point_flag == true then
		RemindManager.Instance:Fire(RemindName.Rank)
	end
end

function RankData:SetMingrenIdList(famous_list)
	for k, v in ipairs(famous_list) do
		self.mingren_id_list[k] = v
	end
end

function RankData:GetMingrenOtherCfg()
	return ConfigManager.Instance:GetAutoConfig("famousman_auto").other[1]
end

--排行榜暂不需要红点,名人堂使用了这个红点
function RankData:GetRemind()
	return 0
end

function RankData:ClearMingrenData()
	self.mingren_info_list = {}
	self.mingren_index_flag = {}
end

function RankData:SetRedPointFlag(flag)
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local get_time = PlayerPrefsUtil.GetInt("rank_mingren_redpoint_time" .. role_id, -1)
	local s_time = TimeCtrl.Instance:GetServerTime()
	PlayerPrefsUtil.SetInt("rank_mingren_redpoint_time" .. role_id, s_time)
end

function RankData:GetRedPointFlag()
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if level < GameEnum.MINGREN_REMINDER_LEVEL then
		self.red_point_flag = false
		return false
	end

	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local s_time = TimeCtrl.Instance:GetServerTime()
	local get_time = PlayerPrefsUtil.GetInt("rank_mingren_redpoint_time" .. role_id, -1)

	if get_time == -1 then
		self.red_point_flag = true
		return self.red_point_flag
	end
	local get_time_table = os.date('*t', get_time)
	local sever_time_table = os.date('*t', s_time)

	if sever_time_table.day - get_time_table.day > 0
		or sever_time_table.month - get_time_table.month > 0
		or sever_time_table.year - get_time_table.year > 0 then

		self.red_point_flag = true
		return self.red_point_flag
	end

	self.red_point_flag = false
	return false
end

--顶级玩家信息返回
function RankData:OnGetPersonRankTopUserAck(protocol)
	self.rank_type = protocol.rank_type
	self.kuafu_rank_type = nil
	self.user_id = protocol.user_id
	self.user_name = protocol.user_name
	self.sex = protocol.sex
	self.prof = protocol.prof
	self.camp = protocol.camp
	self.reserved = protocol.reserved
	self.level = protocol.level
	self.rank_value = protocol.rank_value
end

--世界等级信息返回
function RankData:OnGetWorldLevelAck(protocol)
	self.world_level = protocol.world_level
	self.top_user_level = protocol.top_user_level
end

function RankData:GetWordLevel()
	return self.world_level
end

function RankData:GetRankList()
	return self.rank_list
end

--获取目前需要的排行榜类型 13种(+4)
function RankData:GetRankTypeList()
	return self.rank_type_list
end

function RankData:GetMyInfoList()
	local my_rank = -1
	local my_id = GameVoManager.Instance:GetMainRoleVo().role_id
	for k,v in pairs(self:GetRankList()) do
		if my_id == v.user_id then
			return k
		end
	end
	return my_rank
end 

function RankData:GetMyInfoListByType(type)
	local my_rank = -1
	if self.rank_type == type then
		local my_id = GameVoManager.Instance:GetMainRoleVo().role_id
		for k,v in pairs(self:GetRankList()) do
			if my_id == v.user_id then
				my_rank = k
			end
		end
	end
	return my_rank
end

function RankData:GetMyGradeInfoListByType(type)
	local grade = -1
	if self.rank_type == type then
		local my_id = GameVoManager.Instance:GetMainRoleVo().role_id
		for k,v in pairs(self:GetRankList()) do
			if my_id == v.user_id then
				grade = v.flexible_int
			end
		end
	end
	return grade
end

function RankData:SortRank(rank_type)
	function sortfun_capability(a, b)  --战力
		if a.rank_value > b.rank_value then
			return true
		elseif a.rank_value == b.rank_value then
			return a.level > b.level
		else
			return false
		end
	end

	function sortfun_level(a, b)  --等级
		if a.level > b.level then
			return true
		elseif a.level == b.level then
			return a.exp > b.exp
		else
			return false
		end
	end

	function sortfun_other(a, b) --其他
		if a.rank_value > b.rank_value then
			return true
		else
			return false
		end
	end

	function sortfun_advance(a, b) --坐骑
		if a.flexible_int > b.flexible_int then
			return true
		elseif  a.flexible_int == b.flexible_int then
			return a.rank_value > b.rank_value
		else
			return false
		end
	end

	function sortfun_rank_value(a, b)
		if a.flexible_int > b.flexible_int then
			return true
		end
		if a.flexible_int == b.flexible_int then
			return a.rank_value > b.rank_value
		end
	end


	if self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LEVEL then
		table.sort(self.rank_list, sortfun_level)
	elseif self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP or 
		self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_DAY_CHARM then
		table.sort(self.rank_list, sortfun_other)
	elseif self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_ALL or 
		self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANNV_CAPABILITY or
		self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_JINGLING then
		table.sort(self.rank_list, sortfun_capability)
	elseif PERSON_RANK_TYPE_NEED_EXCHANGE[self.rank_type] then

	else
		table.sort(self.rank_list, sortfun_rank_value)
	end
end

function RankData:GetRankTitleDes(rank_type, kuafu_rank_type)
	local title = ""
	if kuafu_rank_type then
		if kuafu_rank_type == CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_CAPABILITY_ALL then
			title = Language.Rank.RankTitleName[1]
		elseif kuafu_rank_type == CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_ROLE_LEVEL then
			title = Language.Rank.RankTitleName[2]
		end
		return title
	end

	if rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_ALL
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANNV_CAPABILITY
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_JINGLING then
		title = Language.Rank.RankTitleName[1]
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LEVEL
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP_STRENGTH_LEVEL
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_STONE_TOTAL_LEVEL 
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_ClOAk 
		or rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGREN then
		title = Language.Rank.RankTitleName[2]
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_DAY_CHARM then
		title = Language.Rank.RankTitleName[3]
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WORLD_RIGHT_ANSWER then
		title = Language.Rank.RankTitleName[5]
	else
		title = Language.Rank.RankTitleName[4]
	end
	return title
end

function RankData:GetRankValue(rank)
	if self.kuafu_rank_type then
		if self.kuafu_rank_type == CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_CAPABILITY_ALL then
			return self.rank_list[rank].rank_value
		elseif self.kuafu_rank_type == CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_ROLE_LEVEL then
			return PlayerData.GetLevelString(self.rank_list[rank].rank_value)
		end
		return
	end

	if self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_ALL
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_LEVEL
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_DAY_CHARM
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANNV_CAPABILITY
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_JINGLING
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP_STRENGTH_LEVEL
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_STONE_TOTAL_LEVEL
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_WORLD_RIGHT_ANSWER
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_ClOAk
		and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGREN

		-- and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_FABAO
		-- and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_FASHION
		-- and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENBING
		-- and self.rank_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_FOOTMARK 

		then
		if self.rank_list[rank].flexible_int == 0 then
			return Language.Rank.NotActive
		end
		if MountData.Instance:GetGradeCfg(self.rank_list[rank].flexible_int)[self.rank_list[rank].flexible_int] == nil then
			return Language.Rank.NotActive
		else
			return MountData.Instance:GetGradeCfg(self.rank_list[rank].flexible_int)[self.rank_list[rank].flexible_int].gradename
		end
	elseif self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LEVEL then
		-- local lv, zhuan = PlayerData.GetLevelAndRebirth(self.rank_list[rank].rank_value)
		-- local level = string.format(Language.Common.ZhuanShneng, lv, zhuan)
		return PlayerData.GetLevelString(self.rank_list[rank].rank_value)
	elseif self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP_STRENGTH_LEVEL or self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_STONE_TOTAL_LEVEL then
		return self.rank_list[rank].rank_value
	elseif self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_ClOAk or self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGREN then
		return self.rank_list[rank].flexible_int
	end
	return self.rank_list[rank].rank_value
end

function RankData:GetRankValueByType(rank, type)
	if self.rank_type == type then
		if self.rank_list[rank] and self.rank_list[rank].flexible_int ~= 0 then
			if MountData.Instance:GetGradeCfg(self.rank_list[rank].flexible_int)[self.rank_list[rank].flexible_int] ~= nil then
				self.text = MountData.Instance:GetGradeCfg(self.rank_list[rank].flexible_int)[self.rank_list[rank].flexible_int].grade
			end
		end
	end
	return self.text
end

function RankData:GetGradeNumName(grade)
	if grade == 0 then
		return Language.Rank.NotActive
	end
	return MountData.Instance:GetGradeCfg(grade)[grade].gradename
end

function RankData:GetTabName(rank_type)
	local title = ""
	if Language.Rank.RankTabName[rank_type] then
		title = Language.Rank.RankTabName[rank_type]
	end
	return title
end

function RankData:GetModelId(prof, sex)
	local job_cfg = ConfigManager.Instance:GetAutoConfig("rolezhuansheng_auto").job
	local modle_list = {}
	for k,v in pairs(job_cfg) do
		if v.id == prof then
			modle_list.model = v["model" .. sex]
			modle_list.right_weapon = v["right_weapon" .. sex]
			modle_list.left_weapon = v["left_weapon" .. sex]
			return modle_list
		end
	end
end

function RankData:GetMyPowerValue(rank_type)
	local power = ""
	if rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_ALL then
		power = GameVoManager.Instance:GetMainRoleVo().capability
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LEVEL then
		local level = GameVoManager.Instance:GetMainRoleVo().level
		-- local lv, zhuan = PlayerData.GetLevelAndRebirth(level)
		-- power = string.format(Language.Common.ZhuanShneng, lv, zhuan)
		power = PlayerData.GetLevelString(level)
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP then
		local helper_data = HelperData.Instance
		power = helper_data:GetCurrentScore(HELPER_EVALUATE_TYPE.EQUIP)
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_DAY_CHARM then
		power = GameVoManager.Instance:GetMainRoleVo().day_charm
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT then
		local cfg = MountData.Instance:GetGradeCfg()[MountData.Instance:GetMountInfo().grade]
		if cfg then
			power = cfg.gradename
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHIZHUANG then
		local cfg = MountData.Instance:GetGradeCfg()[FashionData.Instance:GetWuQiInfo().grade]		--时装
		if cfg then
			power = cfg.gradename
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FABAO then
		local cfg = MountData.Instance:GetGradeCfg()[FaBaoData.Instance:GetFaBaoInfo().grade]		--法宝
		if cfg then
			power = cfg.gradename
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHIZHUANG_WUQI then
		local cfg = MountData.Instance:GetGradeCfg()[FashionData.Instance:GetWuQiInfo().grade]		--神兵
		if cfg then
			power = cfg.gradename
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FOOTPRINT then
		local cfg = MountData.Instance:GetGradeCfg()[FootData.Instance:GetFootInfo().grade]		--足迹
		if cfg then
			power = cfg.gradename
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WING then
		local cfg = MountData.Instance:GetGradeCfg()[WingData.Instance:GetWingInfo().grade]
		if cfg then
			power = cfg.gradename
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_HALO then
		local cfg = MountData.Instance:GetGradeCfg()[HaloData.Instance:GetHaloInfo().grade]
		if cfg then
			power = cfg.gradename
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENGONG then
		local cfg = MountData.Instance:GetGradeCfg()[ShengongData.Instance:GetShengongInfo().grade]
		if cfg then
			power = cfg.gradename
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENYI then
		local cfg = MountData.Instance:GetGradeCfg()[ShenyiData.Instance:GetShenyiInfo().grade]
		if cfg then
			power = cfg.gradename
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FIGHT_MOUNT then
		local cfg = MountData.Instance:GetGradeCfg()[FightMountData.Instance:GetFightMountInfo().grade]
		if cfg then
			power = cfg.gradename
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANNV_CAPABILITY then
		power = GoddessData.Instance:GetAllPower()
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP_STRENGTH_LEVEL then
		power = ForgeData.Instance:GetTotalStrengthLevel()
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_STONE_TOTAL_LEVEL then
		local level = ForgeData.Instance:GetTotalGemCfg()
		power = level
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_QINGYUAN then							--情缘
		--相思树去掉了
		power = PlayerData.Instance:GetCapByType(CAPABILITY_TYPE.CAPABILITY_TYPE_QINGYUAN)
		-- local power_2 = PlayerData.Instance:GetCapByType(CAPABILITY_TYPE.CAPABILITY_TYPE_LOVE_TREE)
		local lover_power = PlayerData.Instance:GetRoleVo().lover_qingyuan_capablity or 0
		-- if power_2 == nil then
		-- 	power_2 = 0
		-- end
		if power == nil then
			power = 0
		end
		power = tostring(power + lover_power)
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_BABY then								--宝宝
		local lover_power = PlayerData.Instance:GetRoleVo().lover_baby_capablity or 0
		power = PlayerData.Instance:GetCapByType(CAPABILITY_TYPE.CAPABILITY_TYPE_BABY) + lover_power
		if power == nil then
			power = "0"
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LITTLE_PET then						--小宠物
		local lover_power = PlayerData.Instance:GetRoleVo().lover_little_pet_capablity or 0
		power = PlayerData.Instance:GetCapByType(CAPABILITY_TYPE.CAPABILITY_TYPE_LITTLE_PET) + lover_power
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_YAOSHI then 							--腰饰
		local cfg = WaistData.Instance:GetWaistGradeCfgInfoByGrade()
		if cfg then
			power = cfg.gradename
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_TOUSHI then 							--头饰
		local cfg = TouShiData.Instance:GetTouShiGradeCfgInfoByGrade()
		if cfg then
			power = cfg.gradename
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_QILINBI then 							--麒麟臂
		local cfg = QilinBiData.Instance:GetQilinBiGradeCfgInfoByGrade()
		if cfg then
			power = cfg.gradename
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_MASK then 							--面饰
		local cfg = MaskData.Instance:GetMaskGradeCfgInfoByGrade()
		if cfg then
			power = cfg.gradename
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGZHU then 							--灵珠
		local cfg = LingZhuData.Instance:GetLingZhuGradeCfgInfoByGrade()
		if cfg then
			power = cfg.gradename
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANBAO then 							--仙宝
		local cfg = XianBaoData.Instance:GetXianBaoGradeCfgInfoByGrade()
		if cfg then
			power = cfg.gradename
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGTONG then 						--灵童
		local cfg = LingChongData.Instance:GetLingChongGradeCfgInfoByGrade()
		if cfg then
			power = cfg.gradename
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGGONG then 						--灵弓
		local cfg = LingGongData.Instance:GetLingGongGradeCfgInfoByGrade()
		if cfg then
			power = cfg.gradename
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGQI then 							--灵骑
		local cfg = LingQiData.Instance:GetLingQiGradeCfgInfoByGrade()
		if cfg then
			power = cfg.gradename
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WEIYAN then 							--尾焰
		local cfg = WeiYanData.Instance:GetWeiYanGradeCfgInfoByGrade()
		if cfg then
			power = cfg.gradename
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHOUHUAN then 						--手环
		local cfg = ShouHuanData.Instance:GetShouHuanGradeCfgInfoByGrade()
		if cfg then
			power = cfg.gradename
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_TAIL then 							--尾巴
		local cfg = TailData.Instance:GetTailGradeCfgInfoByGrade()
		if cfg then
			power = cfg.gradename
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FLYPET then 							--飞宠
		local cfg = FlyPetData.Instance:GetFlyPetGradeCfgInfoByGrade()
		if cfg then
			power = cfg.gradename
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_ClOAk then 							--披风
		local cfg = MountData.Instance:GetGradeCfg()[CloakData.Instance:GetCloakInfo().grade]
		if cfg then
			power = cfg.gradename
		else
			power = Language.Rank.NotActive
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGREN then 							--灵刃
		local cfg = MountData.Instance:GetGradeCfg()[LingRenData.Instance:GetShenBingInfo().grade]
		if cfg then
			power = cfg.gradename
		else
			power = Language.Rank.NotActive
		end
	end
	return power
end

function RankData:GetJingLingPower(id, level)
	local power = 0
	local attr = SpiritData.Instance:GetSpiritUpLevelCfg(id, level)
	if attr then
		power = CommonDataManager.GetCapability(attr)
	end
	return power
end

function RankData:GetJingLingPower(id, level)
	local power = 0
	local attr = SpiritData.Instance:GetSpiritUpLevelCfg(id, level)
	if attr then
		power = CommonDataManager.GetCapability(attr)
	end
	return power
end

function RankData:GetRedPoint()
	local temp_list = {}
	for k,v in pairs(self.famous_list) do
		if v > 0 then
			table.insert(temp_list, v)
		end
	end
	return #temp_list < 6 and self:GetRedPointFlag()
end

function RankData:CheckInRank(role_id)
	for k,v in pairs(self.rank_list) do
		if v.user_id == role_id then
			return true, k
		end
	end
	return false
end

--获得respath name
function RankData:GetRankResName(rank_type)
	if rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_DAY_CHARM then
		return "meili"
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WORLD_RIGHT_ANSWER then
		return "answer"
	end
	return ""
end

function RankData:GetMingCfg()
	local mingren_cfg = ConfigManager.Instance:GetAutoConfig("rankconfig_auto").mingrentang_coordinates
	return mingren_cfg
end

function RankData:GetMingCfgByType(mingren_type)
	for k,v in pairs(self:GetMingCfg()) do
		if mingren_type == v.mingrentang_type then
			return v
		end
	end
end

function RankData:SetCurrentUserIndex(current_user_index)
	self.current_user_index = current_user_index or 1
end

function RankData:GetCurrentUserIndex()
	return self.current_user_index
end

--排行榜顶部按钮页面
function RankData:SetCurTopType(cur_type)
	self.cur_top_type = cur_type
end
function RankData:GetCurTopType()
	return self.cur_top_type
end

---------------------------------情缘start---------------------------------
function RankData:OnGetCoupleRankListAck(protocol)
	for k, v in pairs(COUPLE_RANK_TYPE) do
		if protocol.rank_type == v then
			local couple_list = {}
			couple_list.couple_item_count = protocol.item_count
			couple_list.couple_rank_item_list = protocol.rank_item_list
			self.couple[v] = couple_list
			break
		end
	end
end

function RankData:GetRankListBytype(cur_type)
	if cur_type and self.couple and self.couple[cur_type] then
		return self.couple[cur_type].couple_rank_item_list
	end
end

function RankData:GetName(index)
	return Language.Rank.RankTabItemName[index] or ""
end
---------------------------------情缘end---------------------------------

-----------------------------跨服排行榜--------------------------------
--跨服排行榜返回
function RankData:OnGetKuaFuRankListAck(protocol)
	self.kuafu_rank_type = protocol.rank_type
	self.rank_list = protocol.rank_list
end

-----------------------------跨服排行榜End--------------------------------
