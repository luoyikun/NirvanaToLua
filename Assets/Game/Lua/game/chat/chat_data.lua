ChatData = ChatData or BaseClass()

MAX_CHANNEL_MSG_NUM	= 50							-- 频道消息最大数量
MAX_PRESERVE_MSG_NUM = 50							-- 私聊消息最大数量
MAX_TRANSMIT_MSG_NUM = 10							-- 喇叭消息最大数量

CHAT_EDIT_MAX = 90									-- 聊天输入最大字符限制

CHAT_POS_MAX = 1									-- 发送坐标最大数量
CHAT_ITEM_MAX = 3									-- 发送道具最大数量
CHAT_FACE_MAX = 5									-- 发送表情最大数量

local CacheMsgMaxCount = 20							-- 聊天缓存队列最大长度
local CacheWorldMaxCount = 100						-- 世界聊天缓存队列最大长度

NO_FILTER_LIST =
{
	QUESTION_ANSWER = "{question_answer}",
}

QUICK_CHAT_TYPE = {
	NORMAL = 1,
	GUILD = 2,
}

--特殊聊天id
SPECIAL_CHAT_ID = {
	GUILD = 1,
	TEAM = 2,
	SYSTEM = 3,

	FALLITEM = 90, 				--掉落信息
	ALL = 100,					--100之后的都默认为私聊id
}

local FilterReport = {			-- 过滤上报的内容(某些渠道要求不想上传自动聊天的内容)
	"{point;",
	"未来的日子，我想和你一房二人三餐四季",
	"硝烟弥漫，贪婪失心！加入我的队伍，一起守护秘宝吧！",
	"组队攀天殿，人多更强！加入我的队伍，一起创造神话！",
	"我这里刚好有{eq",
	"谢谢你出现，够我心动好多年",
	"有大佬带带萌新吗",
	"我觉得你不适合谈恋爱，适合结婚",
	"新人求罩,有一起玩的吗？",
	"诚邀各位勇士加入我的队伍，齐心协力，共创辉煌。",
	"组队经验副本，豪享经验加成！加入我的队伍，一起战斗吧！",
	"可以认识你吗？我觉得你的未来和我有关",
	"我想你一定很忙，所以只用看前三个字就好",
	"你是我的今天，以及所有的明天",
	"除了恋爱，我跟你没什么好谈的",
}

function ChatData:__init()
	if ChatData.Instance then
		print_error("[ChatData]:Attempt to create singleton twice!")
	end
	ChatData.Instance = self

	self.face_tab = {}								-- 表情列表，每次添加表情的时候插入这个列表，发送之前进行校验
	self.item_tab = {}								-- 物品列表，每次添加物品的时候插入这个列表，发送之前进行校验
	self.point_tab = {}								-- 坐标列表，每次添加坐标的时候插入这个列表，发送之前进行校验

	self.transmit_msg_list = {}						-- 喇叭消息列表

	self.msg_id_inc = 0
	self.channel_list = {}							-- 频道列表

	self.private_id_inc = 0							-- 私聊增长id
	self.private_obj_map = {}						-- 私聊对象map
	self.private_obj_list = {}						-- 私聊对象list
	self.private_unread_list = {}					-- 私聊未读列表

	self.team_unread_list = {}						-- 组队未读列表
	self.team_unread_count = 0						-- 组队未读消息数目
	self.blacklist = {}

	self.headsay_state = false						-- 是否屏蔽传闻

	self.chat_channel_size_list = {}				--记录不同频道item的高度
	self.chat_chuanwen_size_list = {}				--记录不同传闻的高度
	self.chat_purchase_size = {}					--记录不同市场收购记录的高度
	self.chat_fall_size = {}						--记录不同物品掉落记录的高度

	self.is_lock = false							--是否锁定界面
	self.is_pop_guild_chat = false					--是否弹出公会气泡框

	self.temp_world_list = {}						--世界缓存列表
	self.temp_system_list = {}						--系统缓存列表
	self.temp_question_list = {}					--答题缓存列表

	self.world_voice_state = false					--自动播放世界语音
	self.team_voice_state = false					--自动播放队伍语音
	self.guild_voice_state = false					--自动播放公会语音
	self.privite_voice_state = false				--自动播放私聊语音

	self.has_unread_guild_msg = false			-- 是否有未读的仙盟聊天消息
	self.is_show_type = true 						-- 区分仙盟里面的聊天和系统

	self.normal_chat_list_map = {}					--总聊天列表（以聊天id为key的表）
	self.normal_chat_list = {}						--总聊天列表（数组表）
	self.unread_num = 0
	self.chat_channel_unread_msg = {}

	self.history_msg_list = {}						--历史信息列表

	self.ignore_level_limit = 99999999
	self.chat_open_level = {}
	self.vip_level_list = {}
	self.notify_guild_unread_count_change_callback_list = {}
	self.guild_enemy_list = {}
	self.del_privite_list = {}
	self:Init()
end

function ChatData:__delete()
	ChatData.Instance = nil
	self.notify_guild_unread_count_change_callback_list = {}
end

function ChatData:Init()
	for k, v in pairs(CHANNEL_TYPE) do
		if v ~= CHANNEL_TYPE.PRIVATE then
			self.channel_list[v] = ChatData.CreateChannel()
		end
		self.chat_channel_size_list[v] = {}
	end
end

function ChatData:ClearChannelMsg()
	for k, v in pairs(CHANNEL_TYPE) do
		if v ~= CHANNEL_TYPE.PRIVATE and v ~= CHANNEL_TYPE.TEAM and v ~= CHANNEL_TYPE.WORLD and v ~= CHANNEL_TYPE.MAINUI then
		-- if v then
			self:RemoveMsgToChannel(v)
			self:ClearChannelItemHeight(v)
		end
	end
end

-- 公会气泡框数据
function ChatData:GetIsPopChat()
	return self.is_pop_guild_chat
end

function ChatData:SetIsPopChat(is_pop)
	self.is_pop_guild_chat = is_pop
end
-----------------------------------------

function ChatData:GetMsgId()
	self.msg_id_inc = self.msg_id_inc + 1
	return self.msg_id_inc
end

----------------------------------------------------
-- 频道begin
----------------------------------------------------
-- 创建频道
function ChatData.CreateChannel()
	return {
		is_pingbi = false,							-- 是否屏蔽
		cd_end_time = 0,							-- CD结束时间
		unread_num = 0,								-- 未读数量
		msg_list = {},								-- 消息列表
	}
end

-- 创建消息
function ChatData.CreateMsgInfo()
	return {
		plat_id = 0,								-- 平台ID
		msg_id = 0,									-- 消息id
		-- msg_type = 0,								-- 消息类型
		from_uid = 0,								-- 发送者id
		username = "",								-- 发送者名字
		sex = 0,									-- 性别
		camp = 0,									-- 阵营
		prof = 0,									-- 职业
		authority_type = 0,							-- 权限类型，GM、新手指导员之类
		content_type = 0,							-- 内容类型
		tuhaojin_color = 0,							-- 发消息字体颜色(土豪金)
		bigchatface_status = 0,						-- 大表情
		level = 0,									-- 等级
		vip_level = 0,								-- vip等级
		channel_type = 0,							-- 频道类型
		send_time = 0,
		send_time_str = "",							-- 发送时间
		content = "",								-- 消息内容
		origin_type = 0,							-- 消息内容类型
	}
end

-- 获取频道
function ChatData:GetChannel(channel_type)
	return self.channel_list[channel_type]
end

-- 获取CD结束时间
function ChatData:GetChannelCdEndTime(channel_type)
	if nil ~= self.channel_list[channel_type] then
		return self.channel_list[channel_type].cd_end_time
	end
	return 0
end

-- 设置CD结束时间
function ChatData:SetChannelCdEndTime(channel_type)
	if nil ~= self.channel_list[channel_type] then
		self.channel_list[channel_type].cd_end_time = Status.NowTime + 10
		return self.channel_list[channel_type].cd_end_time
	end
end

-- 获取CD是否结束时间
function ChatData:GetChannelCdIsEnd(channel_type)
	if nil ~= self.channel_list[channel_type] then
		return (self.channel_list[channel_type].cd_end_time - Status.NowTime) <= 0
	end
	return false
end

-- 添加频道消息
function ChatData:AddChannelMsg(msg_info)
	msg_info.msg_id = self:GetMsgId()

	local channel_type = msg_info.channel_type
	if channel_type == CHANNEL_TYPE.SPEAKER or channel_type == CHANNEL_TYPE.CROSS then
		channel_type = CHANNEL_TYPE.WORLD

	end
	if CHANNEL_TYPE.WORLD == channel_type or CHANNEL_TYPE.TEAM == channel_type then
		self:AddUnReadChatMsg(msg_info, channel_type)
	end
	local channel = self:GetChannel(channel_type)
	if nil ~= channel then
		self:InsertMsgToChannel(channel, msg_info)
	end
	--场景频道和公会不插入全部
	if channel_type ~= CHANNEL_TYPE.SCENE and channel_type ~= CHANNEL_TYPE.GUILD and not NOT_ADD_MAIN_CHANNEL_TYPE[channel_type] then
		self:InsertMsgToChannel(self.channel_list[CHANNEL_TYPE.ALL], msg_info)
		-- 中间弹出消息加到主界面聊天列表中
		if (ADD_MAIN_SYS_MSG_TYPE[msg_info.msg_type] and channel_type == CHANNEL_TYPE.SYSTEM) or channel_type == CHANNEL_TYPE.WORLD then
			self:InsertMsgToChannel(self.channel_list[CHANNEL_TYPE.MAINUI], msg_info)
		end
	end

	self.personalize_channel_window_bubble_type = msg_info.personalize_channel_window_bubble_type
	self.personalize_speaker_window_bubble_type = msg_info.personalize_speaker_window_bubble_type
end

function ChatData:SetLastReadGuildMsg()
	if not self.has_unread_guild_msg then
		return
	end

	if self.guild_unread_msg then
		for i = #self.guild_unread_msg, 1, -1 do
			local last_msg = self.guild_unread_msg[i]
			if last_msg and last_msg.origin_type == ORIGIN_TYPE.ORIGIN_TYPE_NORMAL_CHAT then
				local real_role_id = CrossServerData.Instance:GetRoleId()
				real_role_id = real_role_id > 0 and real_role_id or GameVoManager.Instance:GetMainRoleVo().role_id

				local LAST_GUILD_CHAT_MSG_ROLE = real_role_id .. "last_read_guild_msg_role"
				PlayerPrefsUtil.SetInt(LAST_GUILD_CHAT_MSG_ROLE, tonumber(last_msg.role_id))

				local LAST_GUILD_CHAT_MSG_TIME = real_role_id .. "last_read_guild_msg_time"
				PlayerPrefsUtil.SetInt(LAST_GUILD_CHAT_MSG_TIME, tonumber(last_msg.send_time))

				self.has_unread_guild_msg = false
				break
			end
		end
	else
		self.has_unread_guild_msg = false
	end
end

function ChatData:HasUnreadGuildMsg()
	if self.has_unread_guild_msg then
		return self.has_unread_guild_msg
	end

	local real_role_id = CrossServerData.Instance:GetRoleId()
	real_role_id = real_role_id > 0 and real_role_id or GameVoManager.Instance:GetMainRoleVo().role_id

	local LAST_GUILD_CHAT_MSG_ROLE = real_role_id .. "last_read_guild_msg_role"
	local role_id = PlayerPrefsUtil.GetInt(LAST_GUILD_CHAT_MSG_ROLE)

	local LAST_GUILD_CHAT_MSG_TIME = real_role_id .. "last_read_guild_msg_time"
	local send_time = PlayerPrefsUtil.GetInt(LAST_GUILD_CHAT_MSG_TIME)

	if self.guild_unread_msg then
		for i = #self.guild_unread_msg, 1, -1 do
			local last_msg = self.guild_unread_msg[i]
			if last_msg.origin_type == ORIGIN_TYPE.ORIGIN_TYPE_NORMAL_CHAT then
				if tonumber(last_msg.role_id == tonumber(role_id)) and tonumber(last_msg.send_time) == tonumber(send_time) then
					return false
				elseif tonumber(last_msg.send_time) > tonumber(send_time) then
					self.has_unread_guild_msg = true
					return true
				end
			end
		end
	end
	return false
end

function ChatData:GetUnReadMsgNum()
	if self.unread_num and self.unread_num > 99 then
		return
	end

	local real_role_id = CrossServerData.Instance:GetRoleId()
	real_role_id = real_role_id > 0 and real_role_id or GameVoManager.Instance:GetMainRoleVo().role_id

	local LAST_GUILD_CHAT_MSG_ROLE = real_role_id .. "last_read_guild_msg_role"
	local role_id = PlayerPrefsUtil.GetInt(LAST_GUILD_CHAT_MSG_ROLE)

	local LAST_GUILD_CHAT_MSG_TIME = real_role_id .. "last_read_guild_msg_time"
	local send_time = PlayerPrefsUtil.GetInt(LAST_GUILD_CHAT_MSG_TIME)

	self.unread_num = 0 
	if self.guild_unread_msg then
		for i = #self.guild_unread_msg, 1, -1 do
			local last_msg = self.guild_unread_msg[i]
			if last_msg.origin_type == ORIGIN_TYPE.ORIGIN_TYPE_NORMAL_CHAT then
				if tonumber(last_msg.role_id == tonumber(role_id)) and tonumber(last_msg.send_time) == tonumber(send_time) then
					break
				elseif tonumber(last_msg.send_time) > tonumber(send_time) then
					self.unread_num = self.unread_num + 1
				end
			end
		end
	end
end

function  ChatData:UnreadGuildMsgNum()
	self:GetUnReadMsgNum()
	return self.unread_num
end

function ChatData:GetChannelBubbleType()
	return self.personalize_channel_window_bubble_type
end

function ChatData:GetSpeakerBubbleType()
	return self.personalize_speaker_window_bubble_type
end

function ChatData:RemoveMsgToChannel(channel_type)
	local channel = self:GetChannel(channel_type)
	if channel and next(channel) ~= nil then
		channel.msg_list = {}
	end
end

-- 插入消息到频道
function ChatData:InsertMsgToChannel(channel, msg_info, channel_type)
	table.insert(channel.msg_list, msg_info)
	channel.unread_num = math.min(channel.unread_num + 1, MAX_CHANNEL_MSG_NUM)
	if #channel.msg_list > MAX_CHANNEL_MSG_NUM then
		table.remove(channel.msg_list, 1)
	end
end

-- 是否屏蔽
function ChatData:IsPingBiChannel(channel_type)
	if nil ~= self.channel_list[channel_type] then
		return self.channel_list[channel_type].is_pingbi
	end

	return false
end

function ChatData:DelChannelList()
	for k, v in pairs(self.channel_list) do
		for i = #v.msg_list, 1, -1 do
			if v.msg_list[i] then
				if ScoietyData.Instance:IsBlack(v.msg_list[i].from_uid) then
					table.remove(v.msg_list, i)
				end
			end
		end
	end
end
----------------------------------------------------
-- 频道end
----------------------------------------------------

----------------------------------------------------
-- 私聊begin
----------------------------------------------------
-- 创建私聊对象
function ChatData.CreatePrivateObj()
	return {
		plat_type = 0,								-- 平台ID
		role_id = 0,								-- 角色id
		username = "",								-- 角色名字
		sex = 0,									-- 性别
		camp = 0,									-- 阵营
		prof = 0,									-- 职业
		authority_type = 0,							-- 权限类型，GM、新手指导员之类
		level = 0,									-- 等级
		vip_level = 0,								-- vip等级
		unread_num = 0,								-- 未读消息数量
		is_online = 1,								-- 是否在线
		create_time = 0,							-- 创建时间
		is_special = false,							-- 提示离线的消息
		msg_list = {},								-- 消息列表
	}
end

-- 添加私聊对象
function ChatData:AddPrivateObj(role_id, private_obj)
	if nil == self.private_obj_map[role_id] then
		self.private_obj_map[role_id] = private_obj
		table.insert(self.private_obj_list, private_obj)
		self:AddNormalChatList(private_obj)
	end
end

-- 移除私聊对象
function ChatData:RemovePrivateObj(private_obj)
	if nil ~= self.private_obj_map[private_obj.role_id] then
		self.private_obj_map[private_obj.role_id] = nil

		local index = self:GetPrivateIndex(private_obj.role_id)
		if index > 0 then
			table.remove(self.private_obj_list, index)
		end
		self:RemoveNormalChatList(private_obj.role_id)
	end
end

-- 根据索引移除私聊对象
function ChatData:RemovePrivateObjByIndex(index)
	local private_obj = self.private_obj_list[index]
	if nil ~= private_obj then
		table.remove(self.private_obj_list, index)
		self.private_obj_map[private_obj.role_id] = nil
		self:RemoveNormalChatList(private_obj.role_id)
	end
end

function ChatData:RemovePrivateObjById(role_id)
	role_id = role_id or 0
	if self.private_obj_map[role_id] then
		self.private_obj_map[role_id] = nil

		local index = self:GetPrivateIndex(role_id)
		if index > 0 then
			table.remove(self.private_obj_list, index)
		end

		self:RemoveNormalChatList(role_id)
	end
end

-- 移除黑名单对应私聊对象
function ChatData:RemovePrivateObjIsBlack()
	if not next(self.private_obj_list) then return end
	for i = #self.private_obj_list, 1, -1 do
		if self.private_obj_list[i] then
			local role_id = self.private_obj_list[i].role_id
			if ScoietyData.Instance:IsBlack(role_id) then
				table.remove(self.private_obj_list, i)
				self.private_obj_map[role_id] = nil
				self:RemoveNormalChatList(role_id)
			end
		end
	end
end

--改变私聊列表在线状态
function ChatData:ChangeIsOnlineInPrivite(role_id, is_online)
	for k, v in ipairs(self.private_obj_list) do
		if v.role_id == role_id then
			v.is_online = is_online
			break
		end
	end
end

-- 获取私聊列表
function ChatData:GetPrivateObjList()
	if nil ~= self.private_obj_list then
		return self.private_obj_list
	end
end

-- 获取私聊对象数量
function ChatData:GetPrivateObjCount()
	return #self.private_obj_list
end

-- 根据索引获取私聊对象
function ChatData:GetPrivateObjByIndex(index)
	return self.private_obj_list[index]
end

-- 根据角色id获取私聊对象
function ChatData:GetPrivateObjByRoleId(role_id)
	return self.private_obj_map[role_id]
end

-- 根据角色id移除离线消息提示
function ChatData:SetPrivateObjRemoveOutLineMsg(role_id)
	local private = self.private_obj_map[role_id]

	if private then 
		local mag_list = private.msg_list
		for i = #mag_list, 1, -1 do
			if mag_list[i].is_special then
				table.remove(mag_list, i)
			end
		end
	end
end

function ChatData:PrivateObjOutLineMsg(role_id)
	local private = self.private_obj_map[role_id]

	if private then 
		local mag_list = private.msg_list
		for i = #mag_list, 1, -1 do
			if mag_list[i].is_special then
				return true
			end
		end
	end
	return false
end

-- 获取私聊对象索引
function ChatData:GetPrivateIndex(role_id)
	for k, v in pairs(self.private_obj_list) do
		if role_id == v.role_id then
			return k
		end
	end

	return 0
end

-- 添加私聊消息
function ChatData:AddPrivateMsg(role_id, msg_info)
	if SHIELD_CROSS_CHAT and IS_ON_CROSSSERVER then
		return
	end

	local private_obj = self.private_obj_map[role_id]
	if nil == private_obj then
		private_obj = ChatData.CreatePrivateObj()
		private_obj.plat_type = msg_info.plat_id
		private_obj.role_id = msg_info.role_id
		private_obj.username = msg_info.username
		private_obj.sex = msg_info.sex
		private_obj.camp = msg_info.camp
		private_obj.prof = msg_info.prof
		private_obj.authority_type = msg_info.authority_type
		private_obj.level = msg_info.level
		private_obj.vip_level = msg_info.vip_level
		private_obj.is_special = msg_info.is_special
		private_obj.create_time = TimeCtrl.Instance:GetServerTime()
		self:AddPrivateObj(role_id, private_obj)
	end

	msg_info.msg_id = self:GetMsgId()

	table.insert(private_obj.msg_list, msg_info)
	private_obj.unread_num = private_obj.unread_num + 1

	if #private_obj.msg_list > MAX_PRESERVE_MSG_NUM then
		table.remove(private_obj.msg_list, 1)
	end

	self.private_window_bubble_type = msg_info.personalize_window_bubble_type
end

function ChatData:GetPrivateBubbleType()
	return self.private_window_bubble_type
end

-- 私聊未读列表
function ChatData:GetPrivateUnreadList()
	return self.private_unread_list
end

-- 添加私聊未读消息
function ChatData:AddPrivateUnreadMsg(msg_info)
	table.insert(self.private_unread_list, msg_info)
end

-- 移除私聊未读消息
function ChatData:RemPrivateUnreadMsg(uid)
	local i = 1
	while i <= #self.private_unread_list do
		if self.private_unread_list[i].role_id == uid then
			table.remove(self.private_unread_list, i)
		else
			i = i + 1
		end
	end
end

--获取是否有未读消息
function ChatData:GetIsHavePrivateUnreadMsg(uid)
	local is_have = false
	for k, v in ipairs(self.private_unread_list) do
		if uid == v.role_id then
			is_have = true
			break
		end
	end
	return is_have
end

--获取当前私聊id的未读消息数量
function ChatData:GetPrivateUnreadMsgCountById(role_id)
	local count = 0
	for _, v in ipairs(self.private_unread_list) do
		if role_id == v.role_id and count < COMMON_CONSTS.MAX_PRESERVE_MSG_NUM then
			count = count + 1
		end
	end
	return count
end

--设置是否有新的私聊消息
function ChatData:SetHavePriviteChat(value)
	self.have_privite_chat = value
end

function ChatData:GetHavePriviteChat()
	return self.have_privite_chat
end

--设置是否展示公会聊天对象
function ChatData:SetIsShowGuild(state)
	self.is_show_guild = state
end

function ChatData:GetIsShowGuild()
	return self.is_show_guild
end
----------------------------------------------------
-- 私聊end
----------------------------------------------------

-- 组队未读信息列表
function ChatData:GetTeamUnreaList()
	return self.team_unread_list
end

-- 添加组队未读消息
function ChatData:AddTeamUnreadMsg(msg_info)
	local main_role = Scene.Instance:GetMainRole()
	if msg_info.from_uid ~= main_role.vo.role_id then
		table.insert(self.team_unread_list, msg_info)
		self.team_unread_count = self.team_unread_count + 1
	end

end

-- 移除组队未读消息
function ChatData:ClearTeamUnreadMsg()
	self.team_unread_list = {}
	self.team_unread_count = 0
end

-- 获取组队未读消息数目
function ChatData:GetTeamUnreadCount()
	return self.team_unread_count
end

-- 添加喇叭消息
function ChatData:AddTransmitInfo(transmit_info)
	table.insert(self.transmit_msg_list, TableCopy(transmit_info))
	if #self.transmit_msg_list > MAX_TRANSMIT_MSG_NUM then
		table.remove(self.transmit_msg_list, 1)
	end
end

-- 弹出第一个喇叭消息
function ChatData:PopTransmit()
	return table.remove(self.transmit_msg_list, 1)
end

--向表情列表中插入表情
function ChatData:InsertFaceTab(face_id)
	table.insert(self.face_tab, "{face;".. face_id .."}")
end

function ChatData:InsertItemTab(item_data, is_equip)
	local mark = ""
	local param_str = ""
	local config, item_type = ItemData.Instance:GetItemConfig(item_data.item_id)
	if item_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT then
		mark = "myeq"
		local param = item_data.param or {}


		local star_level = 0
		local jade_infos = {}
		local clear_data = {}
		local zhuanzhi_suit_type_list = {}
		local zhuanzhi_order_list = {}
		local all_juexing_list = {}
		if is_equip then
			local equip_index = EquipData.Instance:GetEquipIndexByType(config.sub_type)
			star_level = ForgeData.Instance:GetUpStarLevelByIndex(equip_index)
			jade_infos = ForgeData.Instance:GetEquipJadeInfo(equip_index)
			clear_data = ForgeData.Instance:GetClearPartInfo(equip_index)
			zhuanzhi_suit_type_list, zhuanzhi_order_list = ForgeData.Instance:GetZhuanzhiSuitInfo()
			local zhuanzhi_all_equip_awakening_list = ForgeData.Instance:GetZhuanzhiEquipAwakeningAllInfoByIndex(equip_index)
			if zhuanzhi_all_equip_awakening_list then
				all_juexing_list = zhuanzhi_all_equip_awakening_list.awakening_in_equip
			end
		end
		local attr_value_list = clear_data.baptize_list or {}
		local attr_seq_list = clear_data.attr_seq_list or {}

		local param_data = {}
		table.insert(param_data, param.strengthen_level or 0)
		table.insert(param_data, param.quality or 0)
		table.insert(param_data, param.shen_level or 0)
		table.insert(param_data, param.fuling_level or 0)
		table.insert(param_data, param.has_lucky or 0)
		table.insert(param_data, star_level or 0)
		for i = 1, COMMON_CONSTS.XIANPIN_MAX_NUM do
			local xianpin_type = param.xianpin_type_list[i] or 0
			if xianpin_type > 0 then
				table.insert(param_data, xianpin_type)
			else
				table.insert(param_data, 0)
			end
		end

		for i = 1, COMMON_CONSTS.MAX_ZHUANZHI_STONE_SLOT do
			if jade_infos and jade_infos.slot_list and jade_infos.slot_list[i] then
				local stone = jade_infos.slot_list[i].stone_id
				table.insert(param_data, stone or 0)
			else
				table.insert(param_data, 0)
			end
		end

		for i = 1, COMMON_CONSTS.EQUIP_BAPTIZE_ONE_PART_MAX_BAPTIZE_NUM do
			table.insert(param_data, attr_seq_list[i] or 0)
		end
		for i = 1, COMMON_CONSTS.EQUIP_BAPTIZE_ONE_PART_MAX_BAPTIZE_NUM do
			table.insert(param_data, attr_value_list[i] or 0)
		end

		for i = 0, COMMON_CONSTS.E_INDEX_MAX do
			table.insert(param_data, zhuanzhi_suit_type_list[i] or 0)
		end
		for i = 0, COMMON_CONSTS.E_INDEX_MAX do
			table.insert(param_data, zhuanzhi_order_list[i] or 0)
		end

		for i = 1, 3 do
			if all_juexing_list[i] then
				for k = 1, 2 do
					if k == 1 then
						local chat_type = all_juexing_list[i].type or 0
						table.insert(param_data, chat_type)
					end
					if k == 2 then
						local chat_level = all_juexing_list[i].level or 0
						table.insert(param_data, chat_level)
					end
				end
			end
		end

		param_str = config.id
		for i, v in ipairs(param_data) do
			param_str = param_str .. ":" .. v
		end
	else
		mark = "myi"
	end
	table.insert(self.item_tab, "{" .. mark .. ";".. item_data.item_id .. ";" .. param_str .."}")
end

function ChatData:InsertPointTab(map_name, point_x, point_y, scene_id, scene_key)
	table.insert(self.point_tab, "{point;".. map_name .. ";" .. point_x .. ";" .. point_y .. ";" .. scene_id .. ";" .. scene_key .. "}")
end

function ChatData:CheckFaceAndItem(msg)
	local str = msg
	--格式化列表中的表情
	for _,v in ipairs(self.face_tab) do
		local params = self:GetSplitData(v)

		local i, j = 0, 0
		while true do
			i, j = string.find(str, "(%/[0-9][0-9][0-9])", j+1)
			if nil == i or nil == j then
				break
			elseif params[2] == string.sub(str, i+1, j) then
				local src = string.sub(str, i, j)

				str = string.gsub(str, src, v)
			end
		end
	end

	--格式化输入的表情
	local i, j = 0, 0
	while true do
		i, j = string.find(str, "(%/[0-9][0-9][0-9])", j + 1)
		if nil == i or nil == j then
			break
		else
			local num =  string.sub(str, i + 1, j) + 0
			if num >= 1 and num <= 32 then
				local src = string.sub(str, i, j)

				str = string.gsub(str, src, "{face;" .. string.format("%03d", num) .. "}")
			end
		end
	end

	--格式化坐标列表中的数据
	for _,v in ipairs(self.point_tab) do
		local params = self:GetSplitData(v)
		local match = params[2] .. "%(" .. params[3] .. "," .. params[4] .. "%)"

		i, j = 0, 0
		while true do
			i, j = string.find(str, match, j + 1)
			if nil == i or nil == j then
				break
			else
				local a, b = string.find(str, params[2], i)
				local src = string.sub(str, b + 1 , j - 1)

				str = string.gsub(str, params[2] .. "%(" .. src .. "%)", v)
			end
		end
	end

	--格式化物品列表中的物品
	for _,v in ipairs(self.item_tab) do
		local params = self:GetSplitData(v)

		i, j = 0, 0
		while true do
			i, j = string.find(str, "(%[.-%])", j + 1)
			if nil == i or nil == j then
				break
			elseif ItemData.Instance:GetItemName(params[2] + 0) == string.sub(str, i + 1, j - 1) then
				local src = string.sub(str, i + 1, j - 1)
				src = string.gsub(src, "%)", "%%%)")
				src = string.gsub(src, "%(", "%%%(")
				src = string.gsub(src, "%-", "%%%-")						--异火有字符-, 需要转义一下
				str = string.gsub(str, "%[" .. src .. "%]", v)
			end
		end
	end
	return str
end

-- 格式化，过滤文本
function ChatData:FormattingMsg(msg, content_type)
	if content_type == CHAT_CONTENT_TYPE.AUDIO then
		return msg
	end
	msg = string.gsub(msg, "{", "(")
	msg = string.gsub(msg, "}", ")")
	msg = string.match(msg,"%s*(.-)%s*$")
	local str = self:CheckFaceAndItem(msg)

	return str
end

function ChatData:GetSplitData(value)
	local mark
	mark = string.gsub(value, "{", "")
	mark = string.gsub(mark, "}", "")

	return Split(mark, ";")
end

function ChatData:ClearInput()
	self.face_tab = {}
	self.item_tab = {}
	self.point_tab = {}
end

-- 校验列表与输入框
function ChatData.ExamineListByEditText(msg, n)
	local lists =
	{
		ChatData.Instance.point_tab,
		ChatData.Instance.item_tab,
		ChatData.Instance.face_tab
	}
	local list = lists[n]
	local str = msg
	local find_str = ""
	local i, j = 1, 1
	local appear_num = 0
	for k,v in pairs(list) do
		local find_arr = Split(v, ";")
		if #find_arr > 0 then
			if n == 1 then
				find_str = find_arr[2] .. "%(" .. find_arr[3] .. "," .. find_arr[4] .. "%)"
			elseif n == 2 then
				find_str = "%[" .. ItemData.Instance:GetItemName(find_arr[2] + 0) .. "%]"
			elseif n == 3 then
				find_str = "%/" .. find_arr[2]
			end
			find_str = string.gsub(find_str, "}", "")
			find_str = string.gsub(find_str, "{", "")
			if 2 == n then
				find_str = string.gsub(find_str, "%)", "%%%)")
				find_str = string.gsub(find_str, "%(", "%%%(")
				find_str = string.gsub(find_str, "%-", "%%%-")
			end

			i, j = string.find(str, find_str, j)
			if j == nil then
				table.remove(list, k)
			else
				local m = 0
				msg, m = string.gsub(msg, find_str, "")
				appear_num = appear_num + m
			end
		end
	end
	return appear_num
end

-- 检查文本内容
function ChatData.ExamineEditText(msg, n)
	local num = n > 0 and 1 or 0
	local boolean = true
	local max_arr = {CHAT_POS_MAX, CHAT_ITEM_MAX, CHAT_FACE_MAX}
	for i = 1, 3 do
		local appear_num = num + ChatData.ExamineListByEditText(msg, i)
		if appear_num > max_arr[i] then
			if n == 0 or n == i then
				SysMsgCtrl.Instance:ErrorRemind(Language.Chat["TipMax" .. i])
				boolean = false
			end
		end
	end
	return boolean
end

-- 聊天输入最大字符限制，超出直接截断
function ChatData.ExamineEditTextNum(edit, num, e_type)
	local str = edit.input_field.text
	--local text_num = AdapterToLua:utf8FontCount(str)
	if string.len(str) > num then
		--str = AdapterToLua:utf8TruncateByFontCount(str, num)
		str = string.sub(str,1,num)
		edit.input_field.text = str
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.ContentToLong)
	end
end

-- 名字输入最大字符限制，去除空格，超出直接截断
function ChatData.ExamineEditNameNum(edit, num, e_type)
	if e_type == "return" then
		local text = edit:getText()
		text = string.gsub(text, "%s", "")			-- 空白符
		text = string.gsub(text, "　", "")			-- 全角空格
		edit:setText(text)
		ChatData.ExamineEditTextNum(edit, num, e_type)
	end
end

-- 检查频道规则
function ChatData.ExamineChannelRule(channel)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	--判断等级是否足够
	if main_role_vo.level < ChatData.Instance:GetChatOpenLevel(CHAT_OPENLEVEL_LIMIT_TYPE.WORLD) then
		local level_str = PlayerData.GetLevelString(ChatData.Instance:GetChatOpenLevel(CHAT_OPENLEVEL_LIMIT_TYPE.WORLD))
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Chat.LevelDeficient, level_str))
		return false
	end

	--组队聊天是判断是否有队伍
	if channel == CHANNEL_TYPE.TEAM and not ScoietyData.Instance:GetTeamState() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NoTeam)
		return false
	end

	return true
end

-- 过滤消息，返回是否显示
function ChatData.FiltrationMsg(content)
	local is_show = true
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	local find_pos = string.find(content, "{team;")
	if nil ~= find_pos then
		local team_element = string.sub(content, find_pos, string.len(content))
		team_element = string.gsub(team_element, "{", "")
		team_element = string.gsub(team_element, "}", "")
		local params = Split(team_element, ";")
		local team_index = tonumber(params[3])
		local team_lev = tonumber(params[4]) or 0

		if team_index == ScoietyData.Instance:GetTeamIndex() then
			is_show = false
		end
		if role_vo.level < team_lev then
			is_show = false
		end
	end
	return is_show
end

function ChatData:SetHeadSayState(value)
	self.headsay_state = value
end

function ChatData:GetHeadSayState()
	return self.headsay_state
end

function ChatData:SetChannelItemHeight(channel_type, msg_id, height)
	local channel_list = self.chat_channel_size_list[channel_type]
	if channel_list then
		channel_list[msg_id] = height
	end
end

function ChatData:SetChuanwenItemHeight(data_index, height)
	self.chat_chuanwen_size_list[data_index] = height
end

function ChatData:GetChuanwenItemHeight(data_index)
	if self.chat_chuanwen_size_list[data_index] then
		return self.chat_chuanwen_size_list[data_index] or 0
	end
	return 0
end

function ChatData:SetPurchaseItemHeight(data_index, height)
	self.chat_purchase_size[data_index] = height
end

function ChatData:GetPurchaseItemHeight(data_index)
	if self.chat_purchase_size[data_index] then
		return self.chat_purchase_size[data_index] or 0
	end
	return 0
end

function ChatData:SetFallItemHeight(data_index, height)
	self.chat_fall_size[data_index] = height
end

function ChatData:GetFallItemHeight(data_index)
	if self.chat_fall_size[data_index] then
		return self.chat_fall_size[data_index] or 0
	end
	return 0
end

function ChatData:GetChannelItemHeight(channel_type, msg_id)
	local channel_list = self.chat_channel_size_list[channel_type]
	if channel_list then
		return channel_list[msg_id] or 0
	end
	return 0
end

--清除对应频道高度缓存
function ChatData:ClearChannelItemHeight(channel_type)
	self.chat_channel_size_list[channel_type] = {}
end

function ChatData:SetIsLockState(state)
	self.is_lock = state
end

function ChatData:GetIsLockState()
	return self.is_lock
end

function ChatData:SetNewLockState(state)
	self.new_lock_state = state
end

function ChatData:GetNewLockState()
	return self.new_lock_state
end

-- 获取中英混合字符串
function ChatData:SubStringUTF8(str, startIndex, endIndex)
    if startIndex < 0 then
        startIndex = self:SubStringGetTotalIndex(str) + startIndex + 1
    end

    if endIndex ~= nil and endIndex < 0 then
        endIndex = self:SubStringGetTotalIndex(str) + endIndex + 1
    end

    if endIndex == nil then
        return string.sub(str, self:SubStringGetTrueIndex(str, startIndex))
    else
        return string.sub(str, self:SubStringGetTrueIndex(str, startIndex), self:SubStringGetTrueIndex(str, endIndex + 1) - 1)
    end
end

--获取中英混合UTF8字符串的真实字符数量
function ChatData:SubStringGetTotalIndex(str)
    local curIndex = 0
    local i = 1
    local lastCount = 1
    repeat
        lastCount = self:SubStringGetByteCount(str, i)
        i = i + lastCount
        curIndex = curIndex + 1
    until(lastCount == 0)
    return curIndex - 1
end

function ChatData:SubStringGetTrueIndex(str, index)
    local curIndex = 0
    local i = 1
    local lastCount = 1
    repeat
        lastCount = self:SubStringGetByteCount(str, i)
        i = i + lastCount
        curIndex = curIndex + 1
    until(curIndex >= index)
    return i - lastCount
end

--返回当前字符实际占用的字符数
function ChatData:SubStringGetByteCount(str, index)
    local curByte = string.byte(str, index)
    local byteCount = 1
    if curByte == nil then
        byteCount = 0
    elseif curByte > 0 and curByte <= 127 then
        byteCount = 1
    elseif curByte>=192 and curByte<=223 then
        byteCount = 2
    elseif curByte>=224 and curByte<=239 then
        byteCount = 3
    elseif curByte>=240 and curByte<=247 then
        byteCount = 4
    end
    return byteCount
end

-- 添加系统缓存数据
function ChatData:AddTempSystemList(msg_info)
	if #self.temp_system_list >= CacheMsgMaxCount then
		table.remove(self.temp_system_list, 1)
	end
	table.insert(self.temp_system_list, msg_info)
end

function ChatData:RemoveTempSystemList(key)
	table.remove(self.temp_system_list, key)
end

function ChatData:GetTempSystemList()
	return self.temp_system_list
end

-- 添加世界缓存数据
function ChatData:AddTempWorldList(msg_info)
	if #self.temp_world_list >= CacheWorldMaxCount then
		table.remove(self.temp_world_list, 1)
	end
	table.insert(self.temp_world_list, msg_info)
end

function ChatData:RemoveTempWorldList(key)
	table.remove(self.temp_world_list, key)
end

function ChatData:GetTempWorldList()
	return self.temp_world_list
end

--添加答题缓存数据
function ChatData:AddTempQuestionList(msg_info)
	table.insert(self.temp_question_list, msg_info)
end

function ChatData:RemoveTempQuestionList(key)
	table.remove(self.temp_question_list, key)
end

function ChatData:GetTempQuestionList()
	return self.temp_question_list
end

--设置是否发送语音
function ChatData:SetCanSendVoice(state)
	self.can_send_voice = state
end

function ChatData:CanSendVoice()
	return self.can_send_voice
end

--设置是否播放世界语音
function ChatData:SetAutoWorldVoice(state)
	self.world_voice_state = state
end

function ChatData:GetAutoWorldVoice()
	return self.world_voice_state
end

--设置是否播放队伍语音
function ChatData:SetAutoTeamVoice(state)
	self.team_voice_state = state
end

function ChatData:GetAutoTeamVoice()
	return self.team_voice_state
end

--设置是否播放公会语音
function ChatData:SetAutoGuildVoice(state)
	self.guild_voice_state = state
end

function ChatData:GetAutoGuildVoice()
	return self.guild_voice_state
end

--设置是否播放私聊语音
function ChatData:SetAutoPriviteVoice(state)
	self.privite_voice_state = state
end

function ChatData:GetAutoPriviteVoice()
	return self.privite_voice_state
end

function ChatData:GetGuildUnreadMsg()
	return self.guild_unread_msg
end


--添加公会未读消息
function ChatData:AddGuildUnreadMsg(msg_info)
	if nil == self.guild_unread_msg then
		self.guild_unread_msg = {}
	end
	table.insert(self.guild_unread_msg, msg_info)
end

--清除对应的公会未读信息
function ChatData:RemoveGuildUnreadMsgByMsgId(msg_id)
	if nil == self.guild_unread_msg then
		return
	end

	for k, v in ipairs(self.guild_unread_msg) do
		if msg_id == v.msg_id then
			table.remove(self.guild_unread_msg, k)
			break
		end
	end
end

--清除公会未读消息
function ChatData:ClearGuildUnreadMsg()
	self:SetLastReadGuildMsg()
	self.unread_num = 0
	self.guild_unread_msg = nil
	RemindManager.Instance:Fire(RemindName.GuildChatRed)
end

--全服禁言时间限制
function ChatData:SetForbidTimeInfoList(forbid_time_info_list)
	self.forbid_time_info_list = forbid_time_info_list
end

function ChatData:IsInForbidTime(chat_type)
	if self.forbid_time_info_list == nil then
		return false, 0
	end

	chat_type = chat_type or 0
	local forbid_time_info_info = self.forbid_time_info_list[chat_type]
	if forbid_time_info_info == nil then
		return false, 0
	end

	local server_time = TimeCtrl.Instance:GetServerTime()
	local now_hour = tonumber(os.date("%H", server_time))
	if now_hour >= forbid_time_info_info.begin_hour and now_hour < forbid_time_info_info.end_hour then
		return true, forbid_time_info_info.end_hour
	end

	return false, 0
end

--设置聊天等级限制
function ChatData:SetChatOpenLevelLimit(protocol)
	self.ignore_level_limit = protocol.ignore_level_limit
	self.chat_open_level = protocol.open_level
	self.chat_limit_condition_type_flag_list = protocol.chat_limit_condition_type_flag_list
end

--设置聊天Vip等级限制
function ChatData:SetChatOpenVipLevelLimit(protocol)
	self.vip_level_list = protocol.vip_level_list
end

--获取聊天Vip等级限制
function ChatData:GetChatOpenVipLevelLimit(chat_type)
	return self.vip_level_list[chat_type] or 0
end

--获取聊天限制等级列表
function ChatData:GetChatOpenLevelLimit(type)
	return self.chat_open_level[type]
end

--获取聊天等级限制
function ChatData:GetIgnoreChatOpenLevelLimit()
	return self.ignore_level_limit
end

--获取聊天等级限制
function ChatData:GetChatOpenLevel(chat_type)
	return self.chat_open_level[chat_type] or COMMON_CONSTS.CHAT_LEVEL_LIMIT
end

-- 是否可以聊天
function ChatData:IsCanChat(chat_type, skip_remind)
	local remind_str = ""
	-- 当前渠道不允许跨服聊天
	if not OtherData.Instance:IsCanCrossChat() then
		if not skip_remind then
			SysMsgCtrl.Instance:ErrorRemind(Language.Chat.ForbidCrossChat)
		end
		return false
	end

	local is_in_forbid_time = self:IsInForbidTime(chat_type)
	if is_in_forbid_time then
		print_log(Language.Common.ForbidTime)
		return false
	end

	local check_vip = false
	local vip_level_limit = self:GetChatOpenVipLevelLimit(chat_type)
	if GameVoManager.Instance:GetMainRoleVo().vip_level >= vip_level_limit or chat_type == CHAT_OPENLEVEL_LIMIT_TYPE.SINGLE then
		check_vip = true
	else
		remind_str = string.format(Language.Chat.VipLimit, vip_level_limit)
	end

	local check_level = false
	local level_limit = self:GetChatOpenLevel(chat_type)
	if GameVoManager.Instance:GetMainRoleVo().level >= level_limit or chat_type == CHAT_OPENLEVEL_LIMIT_TYPE.SINGLE then
		check_level = true
	else
		local level_str = PlayerData.GetLevelString(level_limit)
		-- if chat_type == CHAT_OPENLEVEL_LIMIT_TYPE.SINGLE then
		-- 	remind_str = string.format(Language.Chat.LevelDeficientSingle, level_str)
		if chat_type == CHAT_OPENLEVEL_LIMIT_TYPE.WORLD then
			remind_str = string.format(Language.Chat.LevelDeficient, level_str)
		elseif chat_type == CHAT_OPENLEVEL_LIMIT_TYPE.GUILD then
			remind_str = string.format(Language.Chat.LevelDeficientGuild, level_str)
		else
			remind_str = Language.Common.ChatLevelNoOpen
		end
	end

	if self.chat_limit_condition_type_flag_list and self.chat_limit_condition_type_flag_list[32-chat_type] == 0 then
		if check_vip and check_level then
			return true
		end
	else
		if check_vip or check_level then
			return true
		end
		remind_str = string.format(Language.Chat.VipOrLevelLimit, level_limit, vip_level_limit)
	end

	if not skip_remind then
		SysMsgCtrl.Instance:ErrorRemind(remind_str)
	end

	return false
end

function ChatData.SortNormalChatList(a, b)
	local order_a = 1000
	local order_b = 1000
	if a.role_id == SPECIAL_CHAT_ID.GUILD or b.role_id == SPECIAL_CHAT_ID.GUILD then
		if a.role_id == SPECIAL_CHAT_ID.GUILD then
			order_a = order_a + 100
		else
			order_b = order_b + 100
		end
	elseif a.role_id == SPECIAL_CHAT_ID.TEAM or b.role_id == SPECIAL_CHAT_ID.TEAM then
		if a.role_id == SPECIAL_CHAT_ID.TEAM then
			order_a = order_a + 10
		else
			order_b = order_b + 10
		end
	elseif a.create_time < b.create_time then
		order_a = order_a + 1
	elseif a.create_time > b.create_time then
		order_b = order_b + 1
	end
	return order_a > order_b
 end

 -- 记录当前聊天对象id
 function ChatData:SetCurrentId(current_id)
 	if GameVoManager.Instance:GetMainRoleVo().current_id == current_id then
 		current_id = 0
 	end
 	self.current_id = current_id
 end

 function ChatData:GetCurrentId()
 	return self.current_id or 0
 end

--添加总聊天列表
function ChatData:AddNormalChatList(data)
	if nil == self.normal_chat_list_map[data.role_id] then
		self.normal_chat_list_map[data.role_id] = data
		table.insert(self.normal_chat_list, data)
		table.sort(self.normal_chat_list, ChatData.SortNormalChatList)
	end
end

--移除总聊天列表
function ChatData:RemoveNormalChatList(role_id)
	if nil ~= self.normal_chat_list_map[role_id] then
		self.normal_chat_list_map[role_id] = nil

		for k, v in ipairs(self.normal_chat_list) do
			if v.role_id == role_id then
				table.remove(self.normal_chat_list, k)
				if self.del_privite_list[role_id] then
					table.remove(self.del_privite_list, role_id)
				end
			end
		end
	end
end

--获取聊天对象信息
function ChatData:GetTargetDataByRoleId(role_id)
	return self.normal_chat_list_map[role_id]
end

--获取固定聊天列表
function ChatData:GetStaticChatList()
	local static_chat_list = {}
	if self.normal_chat_list_map[SPECIAL_CHAT_ID.GUILD] then
		table.insert(static_chat_list, self.normal_chat_list_map[SPECIAL_CHAT_ID.GUILD])			--仙盟
	end
	if self.normal_chat_list_map[SPECIAL_CHAT_ID.TEAM] then
		table.insert(static_chat_list, self.normal_chat_list_map[SPECIAL_CHAT_ID.TEAM])				--组队
	end
	return static_chat_list
end

--获取动态聊天列表
function ChatData:GetDynamicChatList()
	local dynamic_chat_list = {}
	for k, v in ipairs(self.normal_chat_list) do
		if v.role_id ~= SPECIAL_CHAT_ID.GUILD and v.role_id ~= SPECIAL_CHAT_ID.TEAM then
			table.insert(dynamic_chat_list, v)
		end
	end
	return dynamic_chat_list
end

function ChatData:GetNormalChatList()
	return self.normal_chat_list
end

--强制对聊天列表进行排序
function ChatData:ForceSortNormalChatList()
	table.sort( self.normal_chat_list, ChatData.SortNormalChatList )
end


function ChatData:SetJinYanState(forbid_chat_time_stamp)
	self.forbid_chat_time_stamp = forbid_chat_time_stamp
	local server_time = TimeCtrl.Instance:GetServerTime()
	if server_time <= forbid_chat_time_stamp then
		self.is_jinyan = true
	else
		self.is_jinyan = false
	end
end

function ChatData:IsJinYan()
	if self.is_jinyan then
		local server_time = TimeCtrl.Instance:GetServerTime()
		if server_time > self.forbid_chat_time_stamp then
			self.is_jinyan = false
		end
	end
	return self.is_jinyan
end

--清除对应玩家的聊天消息（包括私聊消息）
function ChatData:ClearChannelMsgByRoleId(role_id)
	--清除频道消息
	for k, v in pairs(self.channel_list) do
		for i = #v.msg_list, 1, -1 do
			if v.msg_list[i] then
				if v.msg_list[i].from_uid == role_id then
					table.remove(v.msg_list, i)
				end
			end
		end
	end

	--清除私聊消息
	self:RemovePrivateObjById(role_id)
end

function ChatData:ZhangChangBoBaoNeedLevel()
	local data_list =  ConfigManager.Instance:GetAutoConfig("activity_msg_cfg_auto").other[1]
	if data_list then
		return data_list.level_limit
	end
end

function ChatData:SetCurIsLiaoOrSystem(state)
	self.is_show_type = state
end

function ChatData:GetCurIsLiaoOrSystem()
	return self.is_show_type
end

--聊天未读
function ChatData:AddUnReadChatMsg(msg_info, channel_type)
	if nil == self.chat_channel_unread_msg[channel_type] then
		self.chat_channel_unread_msg[channel_type] = {}
	end
	table.insert(self.chat_channel_unread_msg[channel_type], msg_info)
end

function ChatData:RemoveChatChannelUnreadMsgByMsgId(msg_id, channel_type)
	if nil == self.chat_channel_unread_msg[channel_type] then
		return
	end

	for k, v in ipairs(self.chat_channel_unread_msg[channel_type]) do
		if msg_id == v.msg_id then
			table.remove(self.chat_channel_unread_msg[channel_type], k)
			break
		end
	end
end

function ChatData:ClearChatChannelUnreadMsg(channel_type)
	self.chat_channel_unread_msg[channel_type] = nil
end

function ChatData:GetChatChannelUnreadMsg(channel_type)
	return self.chat_channel_unread_msg[channel_type]
end

------------------------
-- 群聊未读Num改变回调
function ChatData:NotifyGuildUnreadNumRemindCallBack(callback)
	if callback == nil then
		return
	end	

	self.notify_guild_unread_count_change_callback_list[#self.notify_guild_unread_count_change_callback_list + 1] = callback
end

function ChatData:UnNotifyGuildUnreadNumRemindCallBack(callback)
	if callback == nil then
		return
	end
	for k,v in pairs(self.notify_guild_unread_count_change_callback_list) do
		if v == callback then
			self.notify_guild_unread_count_change_callback_list[k] = nil
			return
		end
	end
end

function ChatData:RemindGuildUnreadNumChangeCallBack()
	for k,v in pairs(self.notify_guild_unread_count_change_callback_list) do
		v()
	end
end
------------------------
function ChatData:GetHistoryMsgList()
	return self.history_msg_list
end

function ChatData:AddToHistoryMsgList(msg)
	local same_key = 0
	for k,v in pairs(self.history_msg_list) do
		if v == msg then
			same_key = k
			break
		end
	end
	if same_key ~= 0 then
		table.remove(self.history_msg_list, same_key)
	end

	table.insert(self.history_msg_list, 1, msg)

	if #self.history_msg_list > 10 then
		table.remove(self.history_msg_list, 11)
	end

	return self.history_msg_list
end


function ChatData:SetGuildEnemyList(list)
	self.guild_enemy_list = list
end

-- 获取仙盟仇人排行
function ChatData:GetGuildEnemyList()
	return self.guild_enemy_list
end

function ChatData:SetDelPriviteList(role_id, special_param)
	if special_param == 1 then
		local chat_info = self:GetTargetDataByRoleId(role_id)
		if chat_info and chat_info.msg_list then
			local is_add = true
			for k,v in pairs(chat_info.msg_list) do
				if nil == v.special_param or v.special_param == 0 then
					is_add = false
				end
			end
			if is_add then
				self.del_privite_list[role_id] = role_id
			end
		end
	else
		if self.del_privite_list[role_id] then
			table.remove(self.del_privite_list, role_id)
		end
	end
end

function ChatData:GetDelPriviteList()
	return self.del_privite_list
end

-- 是否过滤上报内容
function ChatData:IsFilterReportContent(content)
	for k, v in pairs(FilterReport) do
		if string.find(content, v) then
			return true
		end
	end
	return false
end