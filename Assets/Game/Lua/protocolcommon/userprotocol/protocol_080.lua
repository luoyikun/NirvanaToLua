LITTLEPET_QIANGHUAGRID_MAX_NUM = 5
LITTLE_PET_COUPLE_MAX_SHARE_NUM = 10 	--夫妻共享宠物最大数量
LITTLE_PET_MAX_CHOU_COUNT = 10 			--抽奖次数最大值
LITTLE_PET_SHARE_MAX_LOG_NUM = 20
MAX_FRIEND_NUM = 100 					--最大好友数量
LITTLEPET_QIANGHUAPOINT_CURRENT_NUM = 8 --当前强化点数量

local function LoadLittlePetGridValue()
	local t = {}
	t.arrt_type = MsgAdapter.ReadShort()					--强化格子的数值类型
	t.grid_index = MsgAdapter.ReadShort()					--格子索引
	t.attr_value = MsgAdapter.ReadInt()						--数值
	return t
end

local function LoadLittlePetPointValue()
	local t = {}
	t.gridvaluelist = {}
	for i = 1, LITTLEPET_QIANGHUAGRID_MAX_NUM  do
		t.gridvaluelist[i] = LoadLittlePetGridValue()
	end
	return t
end

local function LoadLittlePetReWarValue()
	local t = {}
	t.item_id = MsgAdapter.ReadInt()			--物品id
	t.item_num = MsgAdapter.ReadShort()			--物品数量
	t.is_bind = MsgAdapter.ReadShort()			--是否绑定
	return t
end

local function LoadLittlePetFriendInfo()
	local t = {}
	t.friend_uid = MsgAdapter.ReadInt()						--朋友id
	t.prof = MsgAdapter.ReadShort()							--头像
	t.sex = MsgAdapter.ReadShort()							--朋友的sex
	t.owner_name = MsgAdapter.ReadStrN(32)					--朋友的名字
	t.pet_num = MsgAdapter.ReadInt()						--宠物数量
	return t
end

local function LoadLittlePetFriendPet()
	local t = {}
	t.index = MsgAdapter.ReadInt()
	t.pet_id = MsgAdapter.ReadInt()
	t.info_type = MsgAdapter.ReadInt()
	t.pet_name = MsgAdapter.ReadStrN(32)
	t.interact_times = MsgAdapter.ReadShort()
	t.reserve = MsgAdapter.ReadShort()
	return t
end

local function LoadLittlePetInteractLogStruct()
	local t = {}
	t.name = MsgAdapter.ReadStrN(32)
	t.pet_id = MsgAdapter.ReadInt()
	t.timestamp = MsgAdapter.ReadUInt()
	t.pet_name = MsgAdapter.ReadStrN(32)
	return t
end

local function LoadLittlePetSingleInfo()
	-- local t = {}
	-- t.index = MsgAdapter.ReadInt()					--宠物索引
	-- t.id = MsgAdapter.ReadShort()					--宠物id
	-- t.info_type = MsgAdapter.ReadShort()			--自己的，伴侣的 1: 0
	-- t.pet_name = MsgAdapter.ReadStrN(32)			--小宠物名字
	-- t.maxhp = MsgAdapter.ReadInt()					--属性
	-- t.gongji = MsgAdapter.ReadInt()
	-- t.fangyu = MsgAdapter.ReadInt()
	-- t.mingzhong = MsgAdapter.ReadInt()
	-- t.shanbi = MsgAdapter.ReadInt()
	-- t.baoji = MsgAdapter.ReadInt()
	-- t.kangbao = MsgAdapter.ReadInt()
	-- t.baoshi_active_time = MsgAdapter.ReadUInt()	--上次饱食度满的时间戳
	-- t.feed_degree = MsgAdapter.ReadShort()			--饱食度
	-- t.interact_times = MsgAdapter.ReadShort()
	-- t.point_list = {}
	-- for i = 1, LITTLEPET_QIANGHUAPOINT_CURRENT_NUM do
	-- 	t.point_list[i] = LoadLittlePetPointValue()
	-- end
	-- return t
	local single_pet = {}
	single_pet.index = MsgAdapter.ReadInt()					--宠物索引
	single_pet.id = MsgAdapter.ReadShort()						--宠物id
	single_pet.info_type = MsgAdapter.ReadShort()				--自己的，伴侣的 1: 0
	single_pet.pet_name = MsgAdapter.ReadStrN(32)				--小宠物名字
	local attr_list = {}
	attr_list.maxhp = MsgAdapter.ReadInt()							--属性(生命)
	attr_list.gongji = MsgAdapter.ReadInt()							--属性(攻击)
	attr_list.fangyu = MsgAdapter.ReadInt()							--属性(防御)
	attr_list.mingzhong = MsgAdapter.ReadInt()						--属性(命中)
	attr_list.shanbi = MsgAdapter.ReadInt()							--属性(闪避)
	attr_list.baoji = MsgAdapter.ReadInt()							--属性(暴击)
	attr_list.jianren = MsgAdapter.ReadInt()						--属性(抗暴)
	single_pet.attr_list = attr_list
	single_pet.baoshi_active_time = MsgAdapter.ReadUInt()		--上次饱食度满的时间戳
	single_pet.feed_degree = MsgAdapter.ReadShort()			--饱食度
	single_pet.interact_times = MsgAdapter.ReadShort()			--互动次数
	single_pet.feed_level = MsgAdapter.ReadShort()				--喂养等级
	single_pet.reserve_sh = MsgAdapter.ReadShort()

	single_pet.point_list = {}									--强化点列表
	for i = 1, GameEnum.LITTLEPET_QIANGHUAPOINT_CURRENT_NUM do
		local grid_value_list = {}
		for i = 1, GameEnum.LITTLEPET_QIANGHUAGRID_MAX_NUM  do
			local qiang_hua_item = {}
			qiang_hua_item.arrt_type = MsgAdapter.ReadShort()		--强化格子的数值类型
			qiang_hua_item.grid_index = MsgAdapter.ReadShort()		--格子索引
			qiang_hua_item.attr_value = MsgAdapter.ReadInt()		--数值
			grid_value_list[i] = qiang_hua_item
		end
		single_pet.point_list[i] = grid_value_list
	end

	single_pet.equipment_llist = {}							--装备列表(玩具)
	for i = 1, GameEnum.LITTLEPET_EQUIP_INDEX_MAX_NUM do
		local single_equip = {}
		single_equip.equipment_id = MsgAdapter.ReadUShort()				--玩具id
		single_equip.level = MsgAdapter.ReadShort()						--玩具积分(等级)
		single_pet.equipment_llist[i] = single_equip
	end

	return single_pet
end

CSLittlePetREQ = CSLittlePetREQ or BaseClass(BaseProtocolStruct)
--操作请求
function CSLittlePetREQ:__init()
	self.msg_type = 8001
	self.opera_type = 0
	self.param1 = 0
	self.param2 = 0
	self.param3 = 0
end

function CSLittlePetREQ:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opera_type)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
	MsgAdapter.WriteInt(self.param3)
end

SCLittlePetAllInfo = SCLittlePetAllInfo or BaseClass(BaseProtocolStruct)
function SCLittlePetAllInfo:__init()
	self.msg_type = 8050
end

function SCLittlePetAllInfo:Decode()
	self.score = MsgAdapter.ReadInt() 						--积分
	self.last_free_chou_timestamp = MsgAdapter.ReadUInt(32)		--免费抽奖次数
	self.interact_times = MsgAdapter.ReadShort()			--玩家互动次数
	self.pet_count = MsgAdapter.ReadShort()

	self.pet_list = {}
	if self.pet_count == 0 then
		return
	end
	for i = 1, self.pet_count do
		self.pet_list[i] = LoadLittlePetSingleInfo()
	end
end

SCLittlePetSingleInfo = SCLittlePetSingleInfo or BaseClass(BaseProtocolStruct)
function SCLittlePetSingleInfo:__init()
	self.msg_type = 8051
end

function SCLittlePetSingleInfo:Decode()
	self.pet_single = LoadLittlePetSingleInfo()
end

SCLittlePetChangeInfo = SCLittlePetChangeInfo or BaseClass(BaseProtocolStruct)
function SCLittlePetChangeInfo:__init()
	self.msg_type = 8052
end

function SCLittlePetChangeInfo:Decode()
	self.pet_index = MsgAdapter.ReadChar()		--宠物索引
	self.is_self = MsgAdapter.ReadChar()		--自己：伴侣 1:0
	self.point_type = MsgAdapter.ReadChar()		--强化点
	self.grid_index = MsgAdapter.ReadChar()		--格子索引
	self.gridvalue = LoadLittlePetGridValue()	--格子的数值
end

SCLittlePetChouRewardList = SCLittlePetChouRewardList or BaseClass(BaseProtocolStruct)
function SCLittlePetChouRewardList:__init()
	self.msg_type = 8053
end

function SCLittlePetChouRewardList:Decode()
	-- self.list_count = MsgAdapter.ReadInt()
	-- if self.list_count == 0 then
	-- 	return
	-- end
	-- self.reward_list = {}
	-- for i = 1, self.list_count do
	-- 	self.reward_list[i] = LoadLittlePetReWarValue()
	-- end
	self.list_count = MsgAdapter.ReadInt()
	self.final_reward_seq = MsgAdapter.ReadInt()
	self.reward_list = {}
	if self.list_count == 0 then return end

	for i = 1, self.list_count do
		local reward_item = {}
		reward_item.item_id = MsgAdapter.ReadInt()					-- 物品id
		reward_item.item_num = MsgAdapter.ReadShort()					-- 物品数量
		reward_item.is_bind = MsgAdapter.ReadShort()					-- 是否绑定
		self.reward_list[i] = reward_item
	end
end

SCLittlePetNotifyInfo = SCLittlePetNotifyInfo or BaseClass(BaseProtocolStruct)
function SCLittlePetNotifyInfo:__init()
	self.msg_type = 8054
end

function SCLittlePetNotifyInfo:Decode()
	self.param_type = MsgAdapter.ReadInt()
	self.param1 = MsgAdapter.ReadUInt()
	self.param2 = MsgAdapter.ReadInt()
	self.param3 = MsgAdapter.ReadInt()
	self.param4 = MsgAdapter.ReadUInt()
end

SCLittlePetFriendInfo = SCLittlePetFriendInfo or BaseClass(BaseProtocolStruct)
function SCLittlePetFriendInfo:__init()
	self.msg_type = 8055
end

function SCLittlePetFriendInfo:Decode()
	self.count = MsgAdapter.ReadInt()
	if self.count == 0 then
		return
	end
	self.pet_friend_list = {}
	for i = 1, self.count do
		self.pet_friend_list[i] = LoadLittlePetFriendInfo()
	end
end

SCLittlePetUsingImg = SCLittlePetUsingImg or BaseClass(BaseProtocolStruct)
function SCLittlePetUsingImg:__init()
	self.msg_type = 8056
end

function SCLittlePetUsingImg:Decode()
	self.role_id = MsgAdapter.ReadInt()
	self.using_pet_id = MsgAdapter.ReadInt()
	self.pet_name = MsgAdapter.ReadStrN(32)
end

SCLittlePetFriendPetListInfo = SCLittlePetFriendPetListInfo or BaseClass(BaseProtocolStruct)
function SCLittlePetFriendPetListInfo:__init()
	self.msg_type = 8057
end

function SCLittlePetFriendPetListInfo:Decode()
	self.count = MsgAdapter.ReadInt()
	if self.count == 0 then
		return
	end
	self.pet_list = {}
	for i = 1, self.count do
		self.pet_list[i] = LoadLittlePetFriendPet()
	end
end

SCLittlePetInteractLog = SCLittlePetInteractLog or BaseClass(BaseProtocolStruct)
function SCLittlePetInteractLog:__init()
	self.msg_type = 8058
end

function SCLittlePetInteractLog:Decode()
	self.count = MsgAdapter.ReadInt()
	if self.count == 0 then
		return
	end
	self.log_list = {}
	for i = 1, self.count do
		self.log_list[i] = LoadLittlePetInteractLogStruct()
	end
end

CSLittlePetRename = CSLittlePetRename or BaseClass(BaseProtocolStruct)
function CSLittlePetRename:__init()
	self.msg_type = 8002
	self.index = 0
	self.pet_name = ""
end

function CSLittlePetRename:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.index)
	MsgAdapter.WriteStrN(self.pet_name, 32)
end

SCLittlePetRename = SCLittlePetRename or BaseClass(BaseProtocolStruct)
function SCLittlePetRename:__init()
	self.msg_type = 8059
end

function SCLittlePetRename:Decode()
	self.index = MsgAdapter.ReadShort()
	self.info_type = MsgAdapter.ReadShort()
	self.pet_name = MsgAdapter.ReadStrN(32)
end
-- 溜宠物
SCLittlePetWalk = SCLittlePetWalk or BaseClass(BaseProtocolStruct)
function SCLittlePetWalk:__init()
	self.msg_type = 8060
end

function SCLittlePetWalk:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.reserve_sh = MsgAdapter.ReadShort()
	self.pet_id = MsgAdapter.ReadInt()				--id为0表示宠物消失
	self.pet_name = MsgAdapter.ReadStrN(32)	
end

-- 溜宝宝
SCBabyWalk = SCBabyWalk or BaseClass(BaseProtocolStruct)
function SCBabyWalk:__init()
	self.msg_type = 8061
end

function SCBabyWalk:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.is_special_baby = MsgAdapter.ReadShort()
	self.baby_index = MsgAdapter.ReadInt()				--id为0表示宝宝消失
	self.baby_name = MsgAdapter.ReadStrN(32)	
end