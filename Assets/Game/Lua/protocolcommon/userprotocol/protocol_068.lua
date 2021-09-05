--仙女守护信息
SCXiannvShouhuInfo =  SCXiannvShouhuInfo or BaseClass(BaseProtocolStruct)
function SCXiannvShouhuInfo:__init()
	self.msg_type = 6825
	self.star_level = 0
	self.grade = 0
	self.used_imageid = 0
	self.reserve = 0
	self.active_image_flag = 0
	self.grade_bless_val = 0
end

function SCXiannvShouhuInfo:Decode()
	self.star_level = MsgAdapter.ReadShort()
	self.grade = MsgAdapter.ReadShort()
	self.used_imageid = MsgAdapter.ReadShort()
	self.reserve = MsgAdapter.ReadShort()
	self.active_image_flag = MsgAdapter.ReadInt()
	self.grade_bless_val = MsgAdapter.ReadInt()
end

--请求使用形象
CSUseXiannvShouhuImage = CSUseXiannvShouhuImage or BaseClass(BaseProtocolStruct)
function CSUseXiannvShouhuImage:__init()
	self.msg_type = 6801
	self.reserve_sh = 0
	self.image_id = 0
end

function CSUseXiannvShouhuImage:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.reserve_sh)
	MsgAdapter.WriteShort(self.image_id)
end

--请求仙女守护信息
CSXiannvShouhuGetInfo = CSXiannvShouhuGetInfo or BaseClass(BaseProtocolStruct)
function CSXiannvShouhuGetInfo:__init()
	self.msg_type = 6802
end

function CSXiannvShouhuGetInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--升星级请求
CSXiannvShouhuUpStarLevel = CSXiannvShouhuUpStarLevel or BaseClass(BaseProtocolStruct)
function CSXiannvShouhuUpStarLevel:__init()
	self.msg_type = 6800
	self.stuff_index = 0
	self.is_auto_buy = 0
end

function CSXiannvShouhuUpStarLevel:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.stuff_index)
	MsgAdapter.WriteShort(self.is_auto_buy)
end

--精灵光环升星请求
CSJinglingGuanghuanUpStarLevel =  CSJinglingGuanghuanUpStarLevel or BaseClass(BaseProtocolStruct)
function CSJinglingGuanghuanUpStarLevel:__init()
	self.msg_type = 6850
	self.is_auto_buy = 0
end

function CSJinglingGuanghuanUpStarLevel:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.is_auto_buy)
end

--请求使用精灵法阵形象
CSUseJinglingGuanghuanImage =  CSUseJinglingGuanghuanImage or BaseClass(BaseProtocolStruct)
function CSUseJinglingGuanghuanImage:__init()
	self.msg_type = 6851
	self.image_id = 0
end

function CSUseJinglingGuanghuanImage:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(0)
	MsgAdapter.WriteShort(self.image_id)
end

--请求精灵光环信息
CSJinglingGuanghuanGetInfo =  CSJinglingGuanghuanGetInfo or BaseClass(BaseProtocolStruct)
function CSJinglingGuanghuanGetInfo:__init()
	self.msg_type = 6852
end

function CSJinglingGuanghuanGetInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--请求使用精灵光环特殊形象
CSJinglingGuanghuanSpecialImgUpgrade =  CSJinglingGuanghuanSpecialImgUpgrade or BaseClass(BaseProtocolStruct)
function CSJinglingGuanghuanSpecialImgUpgrade:__init()
	self.msg_type = 6853
	self.special_image_id = 0
end

function CSJinglingGuanghuanSpecialImgUpgrade:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.special_image_id)
	MsgAdapter.WriteShort(0)
end

-- 仙尊卡请求
CSFairyBuddhaCardActivateReq = CSFairyBuddhaCardActivateReq or BaseClass(BaseProtocolStruct)
function CSFairyBuddhaCardActivateReq:__init()
	self.msg_type = 6855
	self.card_type = 0
end

function CSFairyBuddhaCardActivateReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.card_type)
	MsgAdapter.WriteShort(0)
end

-- 仙尊卡信息
SCFairyBuddhaCardActivateInfo =  SCFairyBuddhaCardActivateInfo or BaseClass(BaseProtocolStruct)
function SCFairyBuddhaCardActivateInfo:__init()
	self.msg_type = 6856
end

function SCFairyBuddhaCardActivateInfo:Decode()
	self.bronze_timestamp = MsgAdapter.ReadInt()
	self.silver_timestamp = MsgAdapter.ReadInt()
	self.jewel_timestamp = MsgAdapter.ReadInt()
	self.is_forever_open = MsgAdapter.ReadShort()
	self.fairy_buddha_card_is_activate = MsgAdapter.ReadShort()
	self.gold_bind_is_get_flage = MsgAdapter.ReadInt()
end

-- 仙尊卡领取每日绑元
CSFairyBuddhaCardGoldBindReq = CSFairyBuddhaCardGoldBindReq or BaseClass(BaseProtocolStruct)
function CSFairyBuddhaCardGoldBindReq:__init()
	self.msg_type = 6857
	self.card_type = 0
end

function CSFairyBuddhaCardGoldBindReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.card_type)
	MsgAdapter.WriteShort(0)
end

------------------------------------------------------------------
---------------------------帮派答题------------------------------
--请求进入活动
CSGuildQuestionEnterReq = CSGuildQuestionEnterReq or BaseClass(BaseProtocolStruct)
function CSGuildQuestionEnterReq:__init()
	self.msg_type = 6860
end

function CSGuildQuestionEnterReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 玩家信息
SCGuildQuestionPlayerInfo = SCGuildQuestionPlayerInfo or BaseClass(BaseProtocolStruct)
function SCGuildQuestionPlayerInfo:__init()
	self.msg_type = 6861

	self.uid = 0
	self.answer_name = ""
	self.exp = 0												-- 经验
	self.guild_gongxian = 0										-- 帮派贡献
	self.guild_score = 0										-- 帮派积分
	self.is_gather = 0											-- 是否采集
	self.true_uid = 0											-- 大于0 答对
	self.true_name = ""											-- 答对人名字
end

function SCGuildQuestionPlayerInfo:Decode()
	self.uid = MsgAdapter.ReadInt()
	self.answer_name = MsgAdapter.ReadStrN(32)
	self.exp = MsgAdapter.ReadLL()
	self.guild_gongxian = MsgAdapter.ReadInt()
	self.guild_score = MsgAdapter.ReadInt()
	self.is_gather = MsgAdapter.ReadInt()
	self.true_uid = MsgAdapter.ReadInt()
	self.true_name = MsgAdapter.ReadStrN(32)
end

-- 帮派答题积分排行
SCGuildQuestionGuildRankInfo = SCGuildQuestionGuildRankInfo or BaseClass(BaseProtocolStruct)
function SCGuildQuestionGuildRankInfo:__init()
	self.msg_type = 6862

	self.rank_count = 0
end

function SCGuildQuestionGuildRankInfo:Decode()
	self.rank_count = MsgAdapter.ReadInt()
	self.guild_rank_list = {}
	for i = 1,self.rank_count do
		self.guild_rank_list[i] = {}
		self.guild_rank_list[i].guild_id = MsgAdapter.ReadInt()						-- 帮派id
		self.guild_rank_list[i].guild_name = MsgAdapter.ReadStrN(32)				-- 帮派名字
		self.guild_rank_list[i].guild_score = MsgAdapter.ReadInt()					-- 帮派积分
	end
end

-- 帮派答题题目
SCGuildQuestionQuestionInfo = SCGuildQuestionQuestionInfo or BaseClass(BaseProtocolStruct)
function SCGuildQuestionQuestionInfo:__init()
	self.msg_type = 6863

	self.question_state = 0							-- 0：准备中；1：开始了；2：将要结束
	self.question_state_change_timestamp = 0 		-- 状态切换时间戳
	self.question_index = 0 						-- 第几题
	self.question_id = 0 							-- 题目id
	self.question_str = ""							-- 题目内容
	self.question_end_timestamp = 0 				-- 回答问题倒计时
end

function SCGuildQuestionQuestionInfo:Decode()
	self.question_state = MsgAdapter.ReadInt()
	self.question_state_change_timestamp = MsgAdapter.ReadUInt()
	self.question_index = MsgAdapter.ReadInt()
	self.question_id = MsgAdapter.ReadInt()
	self.question_end_timestamp = MsgAdapter.ReadUInt()
	self.question_str = MsgAdapter.ReadStrN(128)
end


-- 精灵光环信息
SCJinglingGuanghuanInfo =  SCJinglingGuanghuanInfo or BaseClass(BaseProtocolStruct) or BaseClass(BaseProtocolStruct)

function SCJinglingGuanghuanInfo:__init()
	self.msg_type = 6875
end

function SCJinglingGuanghuanInfo:Decode()
	MsgAdapter.ReadShort()
	self.grade = MsgAdapter.ReadShort()
	self.used_imageid = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.active_image_flag = MsgAdapter.ReadInt()
	self.grade_bless_val = MsgAdapter.ReadInt()
	self.active_special_image_flag = MsgAdapter.ReadInt()

	self.special_img_grade_list = {}
	for i = 0, GameEnum.MAX_MOUNT_SPECIAL_IMAGE_ID - 1  do
		self.special_img_grade_list[i] = MsgAdapter.ReadChar()
	end
end