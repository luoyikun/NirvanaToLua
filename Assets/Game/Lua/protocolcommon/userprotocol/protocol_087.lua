
----------------------头饰--------------------------------------------------------
--头饰数据
SCTouShiInfo = SCTouShiInfo or BaseClass(BaseProtocolStruct)
function SCTouShiInfo:__init()
	self.msg_type = 8740
end

function SCTouShiInfo:Decode()
	self.toushi_info = {}
	self.toushi_info.toushi_level = MsgAdapter.ReadShort()								-- 等级
	self.toushi_info.grade = MsgAdapter.ReadShort()										-- 阶
	self.toushi_info.star_level = MsgAdapter.ReadShort()								-- 星级
	self.toushi_info.used_imageid = MsgAdapter.ReadShort()								-- 使用的形象
	self.toushi_info.grade_bless_val = MsgAdapter.ReadInt()								-- 进阶祝福值
	
	self.toushi_info.active_image_flag = {}							-- 形象激活标记
	for i = 0, GameEnum.UPGRADE_MAX_IMAGE_BYTE - 1 do 					
		self.toushi_info.active_image_flag[i] = MsgAdapter.ReadUChar()
	end

	self.toushi_info.active_special_image_flag = {}						-- 特殊形象激活标记
	for i = 0, GameEnum.UPGRADE_MAX_IMAGE_BYTE - 1 do 					
		self.toushi_info.active_special_image_flag[i] = MsgAdapter.ReadUChar()
	end

	self.toushi_info.clear_upgrade_time = MsgAdapter.ReadInt()							-- 清空祝福值的时间
	self.toushi_info.temporary_imageid = MsgAdapter.ReadShort()							-- 当前使用临时形象
	self.toushi_info.temporary_imageid_has_select = MsgAdapter.ReadShort()				-- 已选定的临时形象
	self.toushi_info.temporary_imageid_invalid_time = MsgAdapter.ReadInt()				-- 临时形象有效时间

	self.toushi_info.shuxingdan_list = {}												-- 头饰属性丹列表
	for i = 0, GameEnum.JINJIE_SHUXINGDAN_MAX_TYPE - 1 do
		self.toushi_info.shuxingdan_list[i] = MsgAdapter.ReadShort()
	end

	self.toushi_info.skill_level_list = {}												-- 头饰技能等级列表
	for i = 0, GameEnum.SKILL_COUNT - 1  do
		self.toushi_info.skill_level_list[i] = MsgAdapter.ReadShort()
	end

	self.toushi_info.special_img_grade_list = {}
	for i = 0, GameEnum.MAX_MOUNT_SPECIAL_IMAGE_ID_TWO - 1 do
		self.toushi_info.special_img_grade_list[i] = MsgAdapter.ReadChar()
	end
end

-- 头饰外观改变
SCTouShiAppeChange = SCTouShiAppeChange or BaseClass(BaseProtocolStruct)
function SCTouShiAppeChange:__init()
	self.msg_type = 8741
end

function SCTouShiAppeChange:Decode()
	self.obj_id = MsgAdapter.ReadShort()
	self.toushi_appeid = MsgAdapter.ReadShort()
end

-- 头饰请求操作
CSTouShiOperaReq = CSTouShiOperaReq or BaseClass(BaseProtocolStruct)
function CSTouShiOperaReq:__init()
	self.msg_type = 8742
	self.opera_type = 0
	self.param1 = 0
	self.param2 = 0
	self.param3 = 0
end

function CSTouShiOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(self.param1)
	MsgAdapter.WriteShort(self.param2)
	MsgAdapter.WriteShort(self.param3)
end

--------------------头饰End-------------------------------------------------------------

----------------------面饰--------------------------------------------------------------
--面饰数据
SCMaskInfo = SCMaskInfo or BaseClass(BaseProtocolStruct)
function SCMaskInfo:__init()
	self.msg_type = 8760
end

function SCMaskInfo:Decode()
	self.mask_info = {}
	self.mask_info.mask_level = MsgAdapter.ReadShort()									-- 等级
	self.mask_info.grade = MsgAdapter.ReadShort()										-- 阶
	self.mask_info.star_level = MsgAdapter.ReadShort()									-- 星级
	self.mask_info.used_imageid = MsgAdapter.ReadShort()								-- 使用的形象
	self.mask_info.grade_bless_val = MsgAdapter.ReadInt()								-- 进阶祝福值

	self.mask_info.active_image_flag = {}							-- 形象激活标记
	for i = 0, GameEnum.UPGRADE_MAX_IMAGE_BYTE - 1 do 					
		self.mask_info.active_image_flag[i] = MsgAdapter.ReadUChar()
	end

	self.mask_info.active_special_image_flag = {}						-- 特殊形象激活标记
	for i = 0, GameEnum.UPGRADE_MAX_IMAGE_BYTE - 1 do 					
		self.mask_info.active_special_image_flag[i] = MsgAdapter.ReadUChar()
	end

	self.mask_info.clear_upgrade_time = MsgAdapter.ReadInt()							-- 清空祝福值的时间
	self.mask_info.temporary_imageid = MsgAdapter.ReadShort()							-- 当前使用临时形象
	self.mask_info.temporary_imageid_has_select = MsgAdapter.ReadShort()				-- 已选定的临时形象
	self.mask_info.temporary_imageid_invalid_time = MsgAdapter.ReadInt()				-- 临时形象有效时间

	self.mask_info.shuxingdan_list = {}													-- 面饰属性丹列表
	for i = 0, GameEnum.JINJIE_SHUXINGDAN_MAX_TYPE - 1 do
		self.mask_info.shuxingdan_list[i] = MsgAdapter.ReadShort()
	end

	self.mask_info.skill_level_list = {}												-- 面饰技能等级列表
	for i = 0, GameEnum.SKILL_COUNT - 1 do
		self.mask_info.skill_level_list[i] = MsgAdapter.ReadShort()
	end

	self.mask_info.special_img_grade_list = {}
	for i = 0, GameEnum.MAX_MOUNT_SPECIAL_IMAGE_ID_TWO - 1 do
		self.mask_info.special_img_grade_list[i] = MsgAdapter.ReadChar()
	end
end

-- 面饰外观改变
SCMaskAppeChange = SCMaskAppeChange or BaseClass(BaseProtocolStruct)
function SCMaskAppeChange:__init()
	self.msg_type = 8761
end

function SCMaskAppeChange:Decode()
	self.obj_id = MsgAdapter.ReadShort()
	self.mask_appeid = MsgAdapter.ReadShort()
end

-- 面饰请求操作
CSMaskOperaReq = CSMaskOperaReq or BaseClass(BaseProtocolStruct)
function CSMaskOperaReq:__init()
	self.msg_type = 8762
	self.opera_type = 0
	self.param1 = 0
	self.param2 = 0
	self.param3 = 0
end

function CSMaskOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(self.param1)
	MsgAdapter.WriteShort(self.param2)
	MsgAdapter.WriteShort(self.param3)
end

--------------------面饰End-------------------------------------------------------------

----------------------腰饰--------------------------------------------------------------
--腰饰数据
SCYaoShiInfo = SCYaoShiInfo or BaseClass(BaseProtocolStruct)
function SCYaoShiInfo:__init()
	self.msg_type = 8730
end

function SCYaoShiInfo:Decode()
	self.yaoshi_info = {}
	self.yaoshi_info.yaoshi_level = MsgAdapter.ReadShort()								-- 等级
	self.yaoshi_info.grade = MsgAdapter.ReadShort()										-- 阶
	self.yaoshi_info.star_level = MsgAdapter.ReadShort()								-- 星级
	self.yaoshi_info.used_imageid = MsgAdapter.ReadShort()								-- 使用的形象
	self.yaoshi_info.grade_bless_val = MsgAdapter.ReadInt()								-- 进阶祝福值

	self.yaoshi_info.active_image_flag = {}							-- 形象激活标记
	for i = 0, GameEnum.UPGRADE_MAX_IMAGE_BYTE - 1 do 					
		self.yaoshi_info.active_image_flag[i] = MsgAdapter.ReadUChar()
	end

	self.yaoshi_info.active_special_image_flag = {}						-- 特殊形象激活标记
	for i = 0, GameEnum.UPGRADE_MAX_IMAGE_BYTE - 1 do 					
		self.yaoshi_info.active_special_image_flag[i] = MsgAdapter.ReadUChar()
	end

	self.yaoshi_info.clear_upgrade_time = MsgAdapter.ReadInt()							-- 清空祝福值的时间
	self.yaoshi_info.temporary_imageid = MsgAdapter.ReadShort()							-- 当前使用临时形象
	self.yaoshi_info.temporary_imageid_has_select = MsgAdapter.ReadShort()				-- 已选定的临时形象
	self.yaoshi_info.temporary_imageid_invalid_time = MsgAdapter.ReadInt()				-- 临时形象有效时间

	self.yaoshi_info.shuxingdan_list = {}												-- 腰饰属性丹列表
	for i = 0, GameEnum.JINJIE_SHUXINGDAN_MAX_TYPE - 1 do
		self.yaoshi_info.shuxingdan_list[i] = MsgAdapter.ReadShort()
	end

	self.yaoshi_info.skill_level_list = {}												-- 腰饰技能等级列表
	for i = 0, GameEnum.SKILL_COUNT - 1 do
		self.yaoshi_info.skill_level_list[i] = MsgAdapter.ReadShort()
	end

	self.yaoshi_info.special_img_grade_list = {}
	for i = 0, GameEnum.MAX_MOUNT_SPECIAL_IMAGE_ID_TWO - 1 do
		self.yaoshi_info.special_img_grade_list[i] = MsgAdapter.ReadChar()
	end
end

-- 腰饰外观改变
SCYaoShiAppeChange = SCYaoShiAppeChange or BaseClass(BaseProtocolStruct)
function SCYaoShiAppeChange:__init()
	self.msg_type = 8731
end

function SCYaoShiAppeChange:Decode()
	self.obj_id = MsgAdapter.ReadShort()
	self.yaoshi_appeid = MsgAdapter.ReadShort()
end

-- 腰饰请求
CSYaoShiOperaReq = CSYaoShiOperaReq or BaseClass(BaseProtocolStruct)
function CSYaoShiOperaReq:__init()
	self.msg_type = 8732
	self.opera_type = 0
	self.param1 = 0
	self.param2 = 0
	self.param3 = 0
end

function CSYaoShiOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(self.param1)
	MsgAdapter.WriteShort(self.param2)
	MsgAdapter.WriteShort(self.param3)
end

--------------------腰饰End-------------------------------------------------------------

----------------------麒麟臂-------------------------------------------------------------
--麒麟臂数据
SCQilinBiInfo = SCQilinBiInfo or BaseClass(BaseProtocolStruct)
function SCQilinBiInfo:__init()
	self.msg_type = 8750
end

function SCQilinBiInfo:Decode()
	self.qilinbi_info = {}
	self.qilinbi_info.qilinbi_level = MsgAdapter.ReadShort()							-- 等级
	self.qilinbi_info.grade = MsgAdapter.ReadShort()									-- 阶
	self.qilinbi_info.star_level = MsgAdapter.ReadShort()								-- 星级
	self.qilinbi_info.used_imageid = MsgAdapter.ReadShort()								-- 使用的形象
	self.qilinbi_info.grade_bless_val = MsgAdapter.ReadInt()							-- 进阶祝福值

	self.qilinbi_info.active_image_flag = {}							-- 形象激活标记
	for i = 0, GameEnum.UPGRADE_MAX_IMAGE_BYTE - 1 do 					
		self.qilinbi_info.active_image_flag[i] = MsgAdapter.ReadUChar()
	end

	self.qilinbi_info.active_special_image_flag = {}						-- 特殊形象激活标记
	for i = 0, GameEnum.UPGRADE_MAX_IMAGE_BYTE - 1 do 					
		self.qilinbi_info.active_special_image_flag[i] = MsgAdapter.ReadUChar()
	end

	self.qilinbi_info.clear_upgrade_time = MsgAdapter.ReadUInt()						-- 清空祝福值的时间
	self.qilinbi_info.temporary_imageid = MsgAdapter.ReadShort()						-- 当前使用临时形象
	self.qilinbi_info.temporary_imageid_has_select = MsgAdapter.ReadShort()				-- 已选定的临时形象
	self.qilinbi_info.temporary_imageid_invalid_time = MsgAdapter.ReadUInt()			-- 临时形象有效时间

	self.qilinbi_info.shuxingdan_list = {}												-- 麒麟臂属性丹列表
	for i = 0, GameEnum.JINJIE_SHUXINGDAN_MAX_TYPE - 1 do
		self.qilinbi_info.shuxingdan_list[i] = MsgAdapter.ReadShort()
	end

	self.qilinbi_info.skill_level_list = {}												-- 麒麟臂技能等级列表
	for i = 0, GameEnum.SKILL_COUNT - 1 do
		self.qilinbi_info.skill_level_list[i] = MsgAdapter.ReadShort()
	end

	self.qilinbi_info.special_img_grade_list = {}
	for i = 0, GameEnum.MAX_MOUNT_SPECIAL_IMAGE_ID_TWO - 1 do
		self.qilinbi_info.special_img_grade_list[i] = MsgAdapter.ReadChar()
	end

	self.qilinbi_info.equip_level_list = {}										-- 装备信息
	for i = 0, GameEnum.UPGRADE_EQUIP_COUNT - 1 do
		self.qilinbi_info.equip_level_list[i] = MsgAdapter.ReadShort()
	end
end

-- 麒麟臂外观改变
SCQilinBiAppeChange = SCQilinBiAppeChange or BaseClass(BaseProtocolStruct)
function SCQilinBiAppeChange:__init()
	self.msg_type = 8751
end

function SCQilinBiAppeChange:Decode()
	self.obj_id = MsgAdapter.ReadShort()
	self.qilinbi_appeid = MsgAdapter.ReadShort()
end

-- 麒麟臂请求
CSQiLinBiOperaReq = CSQiLinBiOperaReq or BaseClass(BaseProtocolStruct)
function CSQiLinBiOperaReq:__init()
	self.msg_type = 8752
	self.opera_type = 0
	self.param1 = 0
	self.param2 = 0
	self.param3 = 0
end

function CSQiLinBiOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(self.param1)
	MsgAdapter.WriteShort(self.param2)
	MsgAdapter.WriteShort(self.param3)
end

--------------------麒麟臂End-----------------------------------------------------------

--------------------进阶系统--------------------------------------------------------------
-- 进阶信息
SCUpgradeInfo = SCUpgradeInfo or BaseClass(BaseProtocolStruct)
function SCUpgradeInfo:__init()
	self.msg_type = 8733
end

function SCUpgradeInfo:Decode()
	self.upgrade_type = MsgAdapter.ReadShort()                 			-- 进阶系统类型
	self.info = {}
	self.info.fightout_flag = MsgAdapter.ReadShort()                	-- fightout_flag  -------- & 1 != 0 则出战状态
	self.info.level = MsgAdapter.ReadShort()                        	-- 等级
	self.info.grade = MsgAdapter.ReadShort()                        	-- 阶
	self.info.star_level = MsgAdapter.ReadShort()                   	-- 星级
	self.info.used_imageid = MsgAdapter.ReadShort()                 	-- 使用的形象
	self.info.grade_bless_val = MsgAdapter.ReadInt()                	-- 进阶祝福值
	self.info.clear_upgrade_time = MsgAdapter.ReadUInt()            	-- 清空祝福值的时间
	self.info.temporary_imageid = MsgAdapter.ReadShort()            	-- 当前使用临时形象
	self.info.temporary_imageid_has_select = MsgAdapter.ReadShort() 	-- 已选定的临时形象
	self.info.temporary_imageid_invalid_time = MsgAdapter.ReadUInt()	-- 临时形象有效时间
	self.info.equip_skill_level = MsgAdapter.ReadInt()              	-- 装备技能等级
	self.info.last_upgrade_time = MsgAdapter.ReadUInt()           		-- 上一次进阶成功时间

	self.info.shuxingdan_list = {}										-- 属性丹列表
	for i = 0, GameEnum.JINJIE_SHUXINGDAN_MAX_TYPE - 1 do
		self.info.shuxingdan_list[i] = MsgAdapter.ReadUShort()
	end

	self.info.equip_level_list = {}										-- 装备信息
	for i = 0, GameEnum.UPGRADE_EQUIP_COUNT - 1 do
		self.info.equip_level_list[i] = MsgAdapter.ReadShort()
	end

	self.info.skill_level_list = {}										-- 技能等级
	for i = 0, GameEnum.SKILL_COUNT - 1 do
		self.info.skill_level_list[i] = MsgAdapter.ReadShort()
	end
	 
	self.info.active_img_flag = {}
	for i = 0, GameEnum.UPGRADE_MAX_IMAGE_BYTE_TWO - 1 do 					-- 形象激活标记
		self.info.active_img_flag[i] = MsgAdapter.ReadUChar()
	end

	self.info.img_grade_list = {}										-- 形象阶数列表
	for i = 0, GameEnum.UPGRADE_IMAGE_MAX_COUNT_TWO - 1 do
		self.info.img_grade_list[i] = MsgAdapter.ReadUChar()
	end             
end

-- 进阶外观改变
SCUpgradeAppeChange = SCUpgradeAppeChange or BaseClass(BaseProtocolStruct)
function SCUpgradeAppeChange:__init()
	self.msg_type = 8734
end

function SCUpgradeAppeChange:Decode()
	self.upgrade_type = MsgAdapter.ReadShort()                      -- 进阶系统类型
	self.obj_id = MsgAdapter.ReadShort()                            -- 对象obj_id
	self.upgrade_appeid =  MsgAdapter.ReadUShort()                  -- 外观信息id
	MsgAdapter.ReadShort()
end

-- 进阶系统请求
CSUpgradeOperaReq = CSUpgradeOperaReq or BaseClass(BaseProtocolStruct)
function CSUpgradeOperaReq:__init()
	self.msg_type = 8735
	self.upgrade_type = 0
	self.opera_type = 0
	self.param1 = 0
	self.param2 = 0
	self.param3 = 0
	self.param4 = 0
end

function CSUpgradeOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.upgrade_type)
	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(self.param1)
	MsgAdapter.WriteShort(self.param2)
	MsgAdapter.WriteShort(self.param3)
	MsgAdapter.WriteShort(self.param4)
end
--------------------进阶系统End-----------------------------------------------------------

--------------------------升星助力-------------------------------------------------------
CSGetShengxingzhuliInfoReq = CSGetShengxingzhuliInfoReq or BaseClass(BaseProtocolStruct)
function CSGetShengxingzhuliInfoReq:__init()
	self.msg_type = 8700
end

function CSGetShengxingzhuliInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

SCGetShengxingzhuliInfoAck = SCGetShengxingzhuliInfoAck or BaseClass(BaseProtocolStruct)
function SCGetShengxingzhuliInfoAck:__init()
	self.msg_type = 8701
end

function SCGetShengxingzhuliInfoAck:Decode()
	self.is_get_reward_today = MsgAdapter.ReadInt()
	self.chognzhi_today = MsgAdapter.ReadInt()
	self.func_level = MsgAdapter.ReadInt()
	self.func_type = MsgAdapter.ReadInt()
	self.is_max_level = MsgAdapter.ReadInt()
	self.stall = MsgAdapter.ReadInt()
end

CSGetShengxingzhuliRewardReq = CSGetShengxingzhuliRewardReq or BaseClass(BaseProtocolStruct)
function CSGetShengxingzhuliRewardReq:__init()
	self.msg_type = 8702
end

function CSGetShengxingzhuliRewardReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

SCGetShengxingzhuliRewardAck = SCGetShengxingzhuliRewardAck or BaseClass(BaseProtocolStruct)
function SCGetShengxingzhuliRewardAck:__init()
	self.msg_type = 8703
end

function SCGetShengxingzhuliRewardAck:Decode()
	self.is_succ = MsgAdapter.ReadInt()
end
------------------------------升星助力End----------------------------------------------------------

--------------------------------圣器---------------------------------------------------------------
--圣器所有属性
SCShengqiInfo = SCShengqiInfo or BaseClass(BaseProtocolStruct)
function SCShengqiInfo:__init()
	self.msg_type = 8704
	self.shengqi_spirit_max_num = 4
end

function SCShengqiInfo:Decode()
	self.activate_flag = MsgAdapter.ReadInt()
	self.shengqi_item = {}
	for i = 0, SHENGQI_MAX_NUM do
		self.shengqi_item[i] = {}
		self.shengqi_item[i].level = MsgAdapter.ReadShort()
		MsgAdapter.ReadShort()
		self.shengqi_item[i].spirit_flag = MsgAdapter.ReadInt()
		self.shengqi_item[i].spirit_value = {}
		self.shengqi_item[i].per_spirit_value = {}
		for j = 1, SHENGQI_SPIRIT_MAX_NUM do
			self.shengqi_item[i].spirit_value[j] = MsgAdapter.ReadInt()
		end
		for j = 1, SHENGQI_SPIRIT_MAX_NUM do
			self.shengqi_item[i].per_spirit_value[j] = MsgAdapter.ReadInt()
		end
	end
end

--圣器操作
CSShengqiReq = CSShengqiReq or BaseClass(BaseProtocolStruct)
function CSShengqiReq:__init()
	self.msg_type = 8705
	self.req_type = 0
	self.param1 = 0
	self.param2 = 0
end

function CSShengqiReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.req_type)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
end

--------------------------------------------------------------------
--圣印类型
CSSealReq = CSSealReq or BaseClass(BaseProtocolStruct)
function CSSealReq:__init()
	self.msg_type = 8706
	self.req_type = 0
	self.param1 = 0
	self.param2 = 0
end
   
function CSSealReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.req_type)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
end
--圣印背包信息
SCSealBackpackInfo = SCSealBackpackInfo or BaseClass(BaseProtocolStruct)
function SCSealBackpackInfo:__init()
	self.msg_type = 8707
	self.grid_num = 0
end

function SCSealBackpackInfo:Decode()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	self.grid_num = MsgAdapter.ReadShort() -- 格子数量
	self.grid_list = {} --背包物品表
	for i = 0,self.grid_num -1 do 
		local item_list = {}
		item_list.index = MsgAdapter.ReadShort()
		item_list.slot_index = MsgAdapter.ReadShort()
		item_list.order = MsgAdapter.ReadShort()
		item_list.level = MsgAdapter.ReadShort()
		item_list.item_id = MsgAdapter.ReadUShort()	
		MsgAdapter.ReadUShort()
		self.grid_list[i] = item_list
	end
end
--圣印位置信息
SCSealSlotInfo = SCSealSlotInfo or BaseClass(BaseProtocolStruct)
function SCSealSlotInfo:__init()
	self.msg_type = 8708
end

function SCSealSlotInfo:Decode()
	self.grid_list = {} --圣印装备表
	for i = 0,9 do 
		local item_list = {} 
		item_list.slot_index = MsgAdapter.ReadShort()
		item_list.order = MsgAdapter.ReadShort()
		item_list.color = MsgAdapter.ReadShort()
		item_list.level = MsgAdapter.ReadShort()
		item_list.item_id = MsgAdapter.ReadUShort()
		item_list.is_bind = MsgAdapter.ReadUChar()
		MsgAdapter.ReadUChar()
		self.grid_list[i] = item_list
	end
end
--圣印基本信息
SCSealBaseInfo = SCSealBaseInfo or BaseClass(BaseProtocolStruct)
function SCSealBaseInfo:__init()
	self.msg_type = 8709
	self.hun_score = 0
end

function SCSealBaseInfo:Decode()
	self.hun_score = MsgAdapter.ReadInt()	--灵魂数
	self.soul_list = {}
	for i = 0,2 do 
		self.soul_list[i] = MsgAdapter.ReadInt()
	end
end

--圣印分解回收
CSSealReqRecycle = CSSealReqRecycle or BaseClass(BaseProtocolStruct)
function CSSealReqRecycle:__init()
	self.msg_type = 8710
	self.recycle_num = 0
	self.recycle_backpack_index_list = {}
	for i = 0,199 do	
		self.recycle_backpack_index_list[i] = 0
	end
end
   
function CSSealReqRecycle:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.recycle_num)
	for i = 0,199 do
		MsgAdapter.WriteInt(self.recycle_backpack_index_list[i])
	end
end


---------------------和服基金end-----------------
--城主特权
SCCSAGONGCHENGZHANInfo = SCCSAGONGCHENGZHANInfo or BaseClass(BaseProtocolStruct)
function SCCSAGONGCHENGZHANInfo:__init()
	self.msg_type = 8712
	self.win_times = 0
end

function SCCSAGONGCHENGZHANInfo:Decode()
	self.win_times = MsgAdapter.ReadInt()
end

--------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------

-- 请求所有天赋
CSTalentOperaReqAll = CSTalentOperaReqAll or BaseClass(BaseProtocolStruct)
function CSTalentOperaReqAll:__init()
	self.msg_type = 8720
	self.operate_type = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
end

function CSTalentOperaReqAll:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.operate_type)
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
	MsgAdapter.WriteInt(self.param_3)
end

-- 所有天赋
SCTalentAllInfo = SCTalentAllInfo or BaseClass(BaseProtocolStruct)
function SCTalentAllInfo:__init()
	self.msg_type = 8721
end

function SCTalentAllInfo:Decode()
	self.talent_info_list = {}
	for talent_type = 0, GameEnum.TALENT_TYPE_MAX - 1 do
		self.talent_info_list[talent_type] = {}
		for talent_index = 0, GameEnum.TALENT_SKILL_GRID_MAX_NUM - 1 do
			local info = {}
			info.is_open = MsgAdapter.ReadChar()		-- 格子是否开启
			info.skill_star = MsgAdapter.ReadChar()		-- 技能星级
			info.skill_id = MsgAdapter.ReadShort()		-- 技能星级
			self.talent_info_list[talent_type][talent_index] = info
		end
	end
end

-- 单个天赋格更新
SCTalentUpdateSingleGrid = SCTalentUpdateSingleGrid or BaseClass(BaseProtocolStruct)
function SCTalentUpdateSingleGrid:__init()
	self.msg_type = 8722
end

function SCTalentUpdateSingleGrid:Decode()
	self.talent_type = MsgAdapter.ReadShort()
	self.talent_index = MsgAdapter.ReadShort()

	self.grid_info = {}
	self.grid_info.is_open = MsgAdapter.ReadChar()			-- 格子是否开启
	self.grid_info.skill_star = MsgAdapter.ReadChar()		-- 技能星级
	self.grid_info.skill_id = MsgAdapter.ReadShort()		-- 技能星级
end

-- 抽奖页所有数据
SCTalentChoujiangPage = SCTalentChoujiangPage or BaseClass(BaseProtocolStruct)
function SCTalentChoujiangPage:__init()
	self.msg_type = 8723
end

function SCTalentChoujiangPage:Decode()
	self.free_chou_count = MsgAdapter.ReadInt()
	self.cur_count = MsgAdapter.ReadShort()
	self.choujiang_grid_skill = {}
	for i = 1, GameEnum.TALENT_CHOUJIANG_GRID_MAX_NUM do
		self.choujiang_grid_skill[i] = MsgAdapter.ReadShort()
	end
end

-- 天赋技能关注
SCTalentAttentionSkillID = SCTalentAttentionSkillID or BaseClass(BaseProtocolStruct)
function SCTalentAttentionSkillID:__init()
	self.msg_type = 8724
	self.count = 0
	self.save_skill_id = {}
end

function SCTalentAttentionSkillID:Decode()
	self.save_skill_id = {}
	self.count = MsgAdapter.ReadInt()
	for i = 1, self.count do
		local info = MsgAdapter.ReadShort()
		table.insert(self.save_skill_id, info)
	end
end

-- 红装套装收集
SCRedEquipCollect = SCRedEquipCollect or BaseClass(BaseProtocolStruct)
function SCRedEquipCollect:__init()
	self.msg_type = 8766
	self.seq = 0
	self.equip_slot = {}
end

function SCRedEquipCollect:Decode()
	self.seq = MsgAdapter.ReadInt()
	self.equip_slot = {}
	for i = 0, 11 do
		local itemdata = ProtocolStruct.ReadItemDataWrapper()
		self.equip_slot[i] = itemdata
	end
end

-- 红装套装收集-其他信息
SCRedEquipCollectOther = SCRedEquipCollectOther or BaseClass(BaseProtocolStruct)
function SCRedEquipCollectOther:__init()
	self.msg_type = 8767
	self.seq_active_flag = 0
	self.collect_count = 0
	self.act_reward_can_fetch_flag = 0
	self.active_reward_flag = 0
	self.stars_info = {}
end

function SCRedEquipCollectOther:Decode()
	self.info = {}
	self.seq_active_flag = MsgAdapter.ReadUInt()					-- 套装激活标记（已激活才可穿戴）
	self.collect_count = MsgAdapter.ReadInt()						-- 已集齐的套装数
	self.act_reward_can_fetch_flag = MsgAdapter.ReadUInt()			-- 开服活动可领取标记
	self.active_reward_flag = MsgAdapter.ReadUInt()					-- 称号领取标记
	for i = 0, 17 do
		local vo = {}
		vo.item_count = MsgAdapter.ReadInt()
		vo.stars = MsgAdapter.ReadInt()
		self.stars_info[i] = vo
	end
end
-- 橙装套装收集
SCOrangeEquipCollect = SCOrangeEquipCollect or BaseClass(BaseProtocolStruct)
function SCOrangeEquipCollect:__init()
	self.msg_type = 8768
	self.seq = 0
	self.equip_slot = {}
end

function SCOrangeEquipCollect:Decode()
	self.seq = MsgAdapter.ReadInt()
	self.equip_slot = {}
	for i = 0, 11 do
		local itemdata = ProtocolStruct.ReadItemDataWrapper()
		self.equip_slot[i] = itemdata
	end
end

-- 橙装套装收集-其他信息
SCOrangeEquipCollectOther = SCOrangeEquipCollectOther or BaseClass(BaseProtocolStruct)
function SCOrangeEquipCollectOther:__init()
	self.msg_type = 8769
	self.seq_active_flag = 0
	self.collect_count = 0
	self.act_reward_can_fetch_flag = 0
	self.active_reward_flag = 0
	self.stars_info = {}
end

function SCOrangeEquipCollectOther:Decode()
	self.info = {}
	self.seq_active_flag = MsgAdapter.ReadUInt()					-- 套装激活标记（已激活才可穿戴）
	self.collect_count = MsgAdapter.ReadInt()						-- 已集齐的套装数
	self.act_reward_can_fetch_flag = MsgAdapter.ReadUInt()			-- 开服活动可领取标记
	self.active_reward_flag = MsgAdapter.ReadUInt()					-- 称号领取标记
	for i = 0, 17 do
		local vo = {}
		vo.item_count = MsgAdapter.ReadInt()
		vo.stars = MsgAdapter.ReadInt()
		self.stars_info[i] = vo
	end
end


--------------------------------------------------------------------------------------------------------------------

-- 转职装备操作 操作类型ZHUANZHI_EQUIP_OPERATE_TYPE
CSZhuanzhiEquipOpe = CSZhuanzhiEquipOpe or BaseClass(BaseProtocolStruct)
function CSZhuanzhiEquipOpe:__init()
	self.msg_type = 8770
end

function CSZhuanzhiEquipOpe:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.operate_type)
	MsgAdapter.WriteShort(self.param_1)
	MsgAdapter.WriteShort(self.param_2)
	MsgAdapter.WriteShort(self.param_3)
	MsgAdapter.WriteShort(self.param_4)
	MsgAdapter.WriteShort(self.param_5)
end

-- 返回转职装备
SCZhuanzhiEquipInfo = SCZhuanzhiEquipInfo or BaseClass(BaseProtocolStruct)
function SCZhuanzhiEquipInfo:__init()
	self.msg_type = 8771
end

function SCZhuanzhiEquipInfo:Decode()
	self.zhuanzhi_equip_data = {}

	self.zhuanzhi_equip_data.star_level_tab = {}
	self.zhuanzhi_equip_data.star_exp_tab = {}
	self.zhuanzhi_equip_data.equip_tab = {}
	self.zhuanzhi_equip_data.fuling_count_list = {}
	for i = 0, COMMON_CONSTS.E_INDEX_MAX do
		local star_level = MsgAdapter.ReadUShort()
		MsgAdapter.ReadShort()
		local star_exp = MsgAdapter.ReadUInt()
		local equip_data = ProtocolStruct.ReadItemDataWrapper()
		local fuling_count_list = {}
		for i = 1, 4 do
			fuling_count_list[i] = MsgAdapter.ReadUShort()
		end
		equip_data.index = i 	-- 给装备下标
		self.zhuanzhi_equip_data.star_level_tab[i] = star_level
		self.zhuanzhi_equip_data.star_exp_tab[i] = star_exp
		self.zhuanzhi_equip_data.equip_tab[i] = equip_data
		self.zhuanzhi_equip_data.fuling_count_list[i] = fuling_count_list
	end
end

-- 8772 转职玉石信息
SCZhuanzhiStoneInfo = SCZhuanzhiStoneInfo or BaseClass(BaseProtocolStruct)
function SCZhuanzhiStoneInfo:__init()
	self.msg_type = 8772
end

function SCZhuanzhiStoneInfo:Decode()
	self.stone_score = MsgAdapter.ReadUInt()
	self.stone_list = {}
	for i = 0, COMMON_CONSTS.E_INDEX_MAX do
		local data = {}
		data.slot_open_flag = MsgAdapter.ReadUChar()	--开孔标记
		data.reserve_ch = MsgAdapter.ReadUChar()
		data.refine_level = MsgAdapter.ReadUShort() 	--精炼等级
		data.refine_val = MsgAdapter.ReadUInt() 		--精炼值

		data.slot_list = {}
		for i = 1, COMMON_CONSTS.MAX_ZHUANZHI_STONE_SLOT do
			data.slot_list[i] = {}
			data.slot_list[i].stone_id = MsgAdapter.ReadUShort() 	--宝石id
			data.slot_list[i].is_bind = MsgAdapter.ReadChar()		--是否绑定
			data.slot_list[i].reserve_ch = MsgAdapter.ReadChar()
			data.slot_list[i].reserve1 = MsgAdapter.ReadShort()
			data.slot_list[i].reserve2 = MsgAdapter.ReadShort()
		end
		self.stone_list[i] = data
	end
end

-- 8772 转职玉石信息
SCZhuanzhiSuitInfo = SCZhuanzhiSuitInfo or BaseClass(BaseProtocolStruct)
function SCZhuanzhiSuitInfo:__init()
	self.msg_type = 8773
end

function SCZhuanzhiSuitInfo:Decode()
	self.part_suit_type_list = {} 				-- 套装类型列表
	self.part_order_list = {}  					-- 阶数列表
	for i = 0, COMMON_CONSTS.E_INDEX_MAX do
		self.part_suit_type_list[i] = MsgAdapter.ReadChar()
	end
	for i = 0, COMMON_CONSTS.E_INDEX_MAX do
		self.part_order_list[i] = MsgAdapter.ReadChar()
	end
end
------------------------------------------------------------------------------

------------------------------钓鱼--------------------------------------
-- 钓鱼通用请求
CSFishingOperaReq = CSFishingOperaReq or BaseClass(BaseProtocolStruct)
function CSFishingOperaReq:__init()
	self.msg_type = 8777
	self.opera_type = 0
	self.param1 = 0
	self.param2 = 0
end

function CSFishingOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opera_type)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
end

-- 钓鱼用户信息
SCFishingUserInfo = SCFishingUserInfo or BaseClass(BaseProtocolStruct)
function SCFishingUserInfo:__init()
	self.msg_type = 8778
end

function SCFishingUserInfo:Decode()
	self.role_id = MsgAdapter.ReadUInt()
	self.plat_id = MsgAdapter.ReadUInt()
	self.uuid = self.role_id + (self.plat_id * (2 ^ 32))                -- 主角跨服id
	self.fishing_status = MsgAdapter.ReadChar()							-- 钓鱼状态


	self.special_status_flag = MsgAdapter.ReadUChar()					-- 特殊状态标记
	self.least_count_cfg_index = MsgAdapter.ReadChar()					-- 双倍积分配置索引
	self.is_fish_event = MsgAdapter.ReadChar()							-- 是否鱼上钩
	self.is_consumed_auto_fishing = MsgAdapter.ReadChar()				-- 是否消耗过元宝自动钓鱼
	MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	self.auto_pull_timestamp = MsgAdapter.ReadUInt()					-- 自动拉杆时间戳，没有触发事件则为0
	self.special_status_oil_end_timestamp = MsgAdapter.ReadUInt()		-- 特殊状态香油结束时间戳

	self.fish_num_list = {}												-- 当前钓上的各类鱼的数量
	for i = 1, GameEnum.FISHING_FISH_TYPE_MAX_COUNT do
		self.fish_num_list[i] = MsgAdapter.ReadInt()
	end

	self.gear_num_list = {}												-- 当前拥有的法宝数量
	for i = 1, GameEnum.FISHING_GEAR_MAX_COUNT do
		self.gear_num_list[i] = MsgAdapter.ReadInt()
	end

	self.steal_fish_count = MsgAdapter.ReadUInt()						-- 偷鱼次数
	self.be_stealed_fish_count = MsgAdapter.ReadUInt()					-- 被偷鱼次数
	self.buy_steal_count = MsgAdapter.ReadUInt()						-- 购买偷鱼次数

	self.news_count = MsgAdapter.ReadUInt()								-- 日志数量
	self.news_list = {}													-- 日志
	for i = 1, self.news_count do
		local vo = {}
		vo.news_type = MsgAdapter.ReadShort()							-- 钓鱼日志类型
		vo.fish_type = MsgAdapter.ReadShort()							-- 鱼种类
		vo.fish_num = MsgAdapter.ReadShort()							-- 鱼数量
		MsgAdapter.ReadShort()
		vo.user_name = MsgAdapter.ReadStrN(32)							-- 玩家名字
		self.news_list[i] = vo
	end
end

-- 检查事件结果
SCFishingCheckEventResult = SCFishingCheckEventResult or BaseClass(BaseProtocolStruct)
function SCFishingCheckEventResult:__init()
	self.msg_type = 8779
end

function SCFishingCheckEventResult:Decode()
	self.event_type = MsgAdapter.ReadShort()
	self.param1 = MsgAdapter.ReadShort()
	self.param2 = MsgAdapter.ReadShort()
	self.param3 = MsgAdapter.ReadShort()
end

-- 钓鱼法宝使用结果
SCFishingGearUseResult = SCFishingGearUseResult or BaseClass(BaseProtocolStruct)
function SCFishingGearUseResult:__init()
	self.msg_type = 8780
end

function SCFishingGearUseResult:Decode()
	self.gear_type = MsgAdapter.ReadShort()								-- 使用法宝类型
	self.param1 = MsgAdapter.ReadShort()								-- 获得鱼的类型
	self.param2 = MsgAdapter.ReadShort()								-- 获得鱼的数量
	self.param3 = MsgAdapter.ReadShort()
end

SCFishingEventBigFish = SCFishingEventBigFish or BaseClass(BaseProtocolStruct)
function SCFishingEventBigFish:__init()
	self.msg_type = 8781
end

function SCFishingEventBigFish:Decode()
	self.owner_uid = MsgAdapter.ReadInt()								-- 拥有者role_id
end

-- 钓鱼队伍信息
SCFishingTeamMemberInfo = SCFishingTeamMemberInfo or BaseClass(BaseProtocolStruct)
function SCFishingTeamMemberInfo:__init()
	self.msg_type = 8782
end

function SCFishingTeamMemberInfo:Decode()
	self.member_count = MsgAdapter.ReadInt()							-- 队伍人数

	self.member_uid_1 = MsgAdapter.ReadInt()							-- 队伍玩家1 role_id
	self.least_count_cfg_index_1 = MsgAdapter.ReadInt()					-- 玩家1的双倍积分配置下标
	self.fish_num_list_1 = {}											-- 玩家1的鱼数量，以鱼类型左右数组下标
	for i = 1, GameEnum.FISHING_FISH_TYPE_MAX_COUNT do
		self.fish_num_list_1[i] = MsgAdapter.ReadInt()
	end

	self.member_uid_2 = MsgAdapter.ReadInt()							-- 队伍玩家2 role_id
	self.least_count_cfg_index_2 = MsgAdapter.ReadInt()					-- 玩家2的双倍积分配置下标
	self.fish_num_list_2 = {}											-- 玩家2的鱼数量，以鱼类型左右数组下标
	for i = 1, GameEnum.FISHING_FISH_TYPE_MAX_COUNT do
		self.fish_num_list_2[i] = MsgAdapter.ReadInt()
	end

	self.member_uid_3 = MsgAdapter.ReadInt()							-- 队伍玩家3 role_id
	self.least_count_cfg_index_3 = MsgAdapter.ReadInt()					-- 玩家3的双倍积分配置下标
	self.fish_num_list_3 = {}											-- 玩家3的鱼数量，以鱼类型左右数组下标
	for i = 1, GameEnum.FISHING_FISH_TYPE_MAX_COUNT do
		self.fish_num_list_3[i] = MsgAdapter.ReadInt()
	end
end

-- 钓鱼信息-玩家信息（发给队伍）
SCFishingFishInfo = SCFishingFishInfo or BaseClass(BaseProtocolStruct)
function SCFishingFishInfo:__init()
	self.msg_type = 8783
end

function SCFishingFishInfo:Decode()
	self.uid = MsgAdapter.ReadInt()										-- 玩家role_id
	self.least_count_cfg_index = MsgAdapter.ReadInt()					-- 双倍积分配置下标
	self.fish_num_list = {}												-- 鱼数量，以鱼类型左右数组下标

end

-- 钓鱼随机展示角色-随机玩家信息
SCFishingRandUserInfo = SCFishingRandUserInfo or BaseClass(BaseProtocolStruct)
function SCFishingRandUserInfo:__init()
	self.msg_type = 8784
end

function SCFishingRandUserInfo:Decode()
	self.user_count = MsgAdapter.ReadInt()								-- 玩家个数
	self.user_info_list = {}											-- 鱼数量，以鱼类型左右数组下标
	for i = 1, GameEnum.FISHING_RAND_ROLE_NUM do
		local vo = {}
		vo.uid = MsgAdapter.ReadInt()									-- 玩家role_id
		vo.user_name = MsgAdapter.ReadStrN(32)							-- 名字
		vo.prof = MsgAdapter.ReadShort()								-- 职业
		vo.least_count_cfg_index = MsgAdapter.ReadShort()				-- 双倍积分配置下标

		vo.fish_num_list = {}											-- 鱼数量，以鱼类型左右数组下标
		for j = 1, GameEnum.FISHING_FISH_TYPE_MAX_COUNT do
			vo.fish_num_list[j] = MsgAdapter.ReadInt()
		end
		self.user_info_list[i] = vo
	end

end

-- 钓鱼积分信息
SCFishingScoreInfo = SCFishingScoreInfo or BaseClass(BaseProtocolStruct)
function SCFishingScoreInfo:__init()
	self.msg_type = 8785
end

function SCFishingScoreInfo:Decode()
	self.fishing_score = MsgAdapter.ReadInt()							-- 钓鱼积分
end

-- 钓鱼偷窃结果
SCFishingStealResult = SCFishingStealResult or BaseClass(BaseProtocolStruct)
function SCFishingStealResult:__init()
	self.msg_type = 8786
end

function SCFishingStealResult:Decode()
	self.is_succ = MsgAdapter.ReadShort()								-- 结果
	self.fish_type = MsgAdapter.ReadShort()								-- 获得鱼类型
	self.fish_num = MsgAdapter.ReadInt()								-- 获得鱼数量
end

-- 钓鱼广播
SCFishingGetFishBrocast = SCFishingGetFishBrocast or BaseClass(BaseProtocolStruct)
function SCFishingGetFishBrocast:__init()
	self.msg_type = 8787
end

function SCFishingGetFishBrocast:Decode()
	self.uid = MsgAdapter.ReadInt()										-- 获得鱼的玩家role_id
	self.get_fish_type = MsgAdapter.ReadInt()							-- 获得鱼类型
end

-- 钓鱼积分榜信息
SCCrossFishingScoreRankList = SCCrossFishingScoreRankList or BaseClass(BaseProtocolStruct)
function SCCrossFishingScoreRankList:__init()
	self.msg_type = 8788
end

function SCCrossFishingScoreRankList:Decode()
	-- self.self_rank = MsgAdapter.ReadInt()								-- 自己的排行名次，未上榜为-1
	-- self.self_rank_item = {}											-- 自己的信息
	-- fish_rank_item(self.self_rank_item)

	self.fish_rank_count = MsgAdapter.ReadInt()							-- 排行榜个数
	self.fish_rank_list = {}
	for i = 1, self.fish_rank_count do
		self.fish_rank_list[i] = {}
		self.fish_rank_list[i].rank_index = i							-- 排名
		self.fish_rank_list[i].user_name = MsgAdapter.ReadStrN(32)		-- 名字
		self.fish_rank_list[i].role_id = MsgAdapter.ReadUInt()
		self.fish_rank_list[i].plat_id = MsgAdapter.ReadUInt()
		self.fish_rank_list[i].uid = self.fish_rank_list[i].role_id + (self.fish_rank_list[i].plat_id * (2 ^ 32))	-- 玩家id
		self.fish_rank_list[i].total_score = MsgAdapter.ReadInt()		-- 总积分
	end
end

-- 钓鱼积分信息 (新增钓鱼积分协议，以前的积分协议在钓鱼场景不适用了可以不用了)
SCFishingScoreStageInfo = SCFishingScoreStageInfo or BaseClass(BaseProtocolStruct)
function SCFishingScoreStageInfo:__init()
	self.msg_type = 8789
end

function SCFishingScoreStageInfo:Decode()
	self.cur_score_stage = MsgAdapter.ReadInt()							-- 当前阶段
	self.fishing_score = MsgAdapter.ReadInt()							-- 当前钓鱼积分
end

-- 钓鱼状态改变广播
SCFishingStatusNotify = SCFishingStatusNotify or BaseClass(BaseProtocolStruct)
function SCFishingStatusNotify:__init()
	self.msg_type = 8790
end

function SCFishingStatusNotify:Decode()
	self.role_id = MsgAdapter.ReadUInt()
	self.plat_id = MsgAdapter.ReadUInt()
	self.uuid = self.role_id + (self.plat_id * (2 ^ 32))				-- 主角跨服id
	self.obj_id = MsgAdapter.ReadInt()									-- 玩家的obj_id
	self.status = MsgAdapter.ReadInt()									-- 玩家状态 ： FISHING_STATUS_WAITING ： 钓鱼状态 FISHING_STATUS_CAST ： 抛竿  FISHING_STATUS_PULLED：拉杆
	self.be_stealed_fish_count = MsgAdapter.ReadInt()					-- 被偷鱼数量
	self.fish_num_list = {}												-- 当前钓上的各类鱼的数量
	for i = 1, GameEnum.FISHING_FISH_TYPE_MAX_COUNT do
		self.fish_num_list[i] = MsgAdapter.ReadInt()
	end
end

--被偷鱼信息
SCFishingStealInfo = SCFishingStealInfo or BaseClass(BaseProtocolStruct)
function SCFishingStealInfo:__init()
	self.msg_type = 8791
end

function SCFishingStealInfo:Decode()
	self.cur_score_stage = MsgAdapter.ReadStrN(32)							-- 盗贼名字
	self.be_stolen_name = MsgAdapter.ReadStrN(32)							-- 被偷名字
	self.fish_type = MsgAdapter.ReadShort()									-- 被偷鱼类型
	self.fish_num = MsgAdapter.ReadShort()									-- 被偷鱼的数量
end

-- 钓鱼确认结果信息
SCFishingConfirmResult = SCFishingConfirmResult or BaseClass(BaseProtocolStruct)
function SCFishingConfirmResult:__init()
	self.msg_type = 8792
end

function SCFishingConfirmResult:Decode()
	self.confirm_type = MsgAdapter.ReadShort()
	self.short_param_1 = MsgAdapter.ReadUShort()
	self.param_2 = MsgAdapter.ReadShort()
	self.param_3 = MsgAdapter.ReadShort()
end

--boss图鉴请求
CSBossCardReq = CSBossCardReq or BaseClass(BaseProtocolStruct)
function CSBossCardReq:__init()
	self.msg_type = 8775
end

function CSBossCardReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(self.param1)
	MsgAdapter.WriteShort(self.param2)
end

--boss图鉴下发协议
SCBossCardAllInfo =  SCBossCardAllInfo or BaseClass(BaseProtocolStruct)
function SCBossCardAllInfo:__init()
	self.msg_type = 8776 
end
function SCBossCardAllInfo:Decode()
	self.card_can_active_flag = {}
	self.card_has_active_flag = {}
	self.card_group_reward_fetch_flag = MsgAdapter.ReadLL()
	for i = 0, 63 do
		self.card_can_active_flag[i] = MsgAdapter.ReadUChar()
	end
	for i = 0, 63 do
		self.card_has_active_flag[i] = MsgAdapter.ReadUChar()
	end
end

-----------------------  夜战王城 ---------------------------------------

-- 夜战王城人物信息
SCNightFightRoleInfo = SCNightFightRoleInfo or BaseClass(BaseProtocolStruct)
function SCNightFightRoleInfo:__init()
	self.msg_type = 8795
end

function SCNightFightRoleInfo:Decode()
	self.turn = MsgAdapter.ReadInt()							-- 回合
	self.score = MsgAdapter.ReadInt()							-- 积分
	self.total_score = MsgAdapter.ReadInt()						-- 总积分
	self.is_red_side = MsgAdapter.ReadInt()						-- 是否是红方
	self.rank = MsgAdapter.ReadInt()							-- 排行
	self.total_rank = MsgAdapter.ReadInt()						-- 总排行
	self.kill_role_num = MsgAdapter.ReadInt()					-- 击杀其他玩家数量
	self.next_redistribute_time = MsgAdapter.ReadUInt()			-- 下次发奖励 重新分配阵营的时间戳
	self.next_get_score_time = MsgAdapter.ReadUInt()			-- 下次获取积分时间戳
	self.next_update_rank_time = MsgAdapter.ReadUInt()			-- 下次更新排行时间戳
	self.kick_out_time = MsgAdapter.ReadUInt()					-- 延迟踢出时间
	self.next_flush_boss_time = MsgAdapter.ReadUInt()			-- 下次刷新boss时间戳
	self.is_finish = MsgAdapter.ReadInt()						-- 结束标记
end

-- 夜战王城进入请求
CSNightFightEnterReq = CSNightFightEnterReq or BaseClass(BaseProtocolStruct)
function CSNightFightEnterReq:__init()
	self.msg_type = 8796
	self.opera_type = 0
	self.param1 = 0
end

function CSNightFightEnterReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(self.param1)
end

-- 夜战王城排行信息
SCNightFightRankInfo = SCNightFightRankInfo or BaseClass(BaseProtocolStruct)
function SCNightFightRankInfo:__init()
	self.msg_type = 8797
	self.rank_count = 0
end

function SCNightFightRankInfo:Decode()
	self.rank_count =  MsgAdapter.ReadInt()
	self.rank_info_list = {}
	for i = 1 , self.rank_count do 
		local data = {}
		data.score = MsgAdapter.ReadInt()
		data.user_name = MsgAdapter.ReadStrN(32)
		data.obj_id = MsgAdapter.ReadUShort()
		data.is_red_side = MsgAdapter.ReadShort()
		data.user_key = MsgAdapter.ReadLL()
		self.rank_info_list[i] = data
	end
end

-- 夜战王城排名奖励信息
SCNightFightReward = SCNightFightReward or BaseClass(BaseProtocolStruct)
function SCNightFightReward:__init()
	self.msg_type = 8798
end

function SCNightFightReward:Decode()
	self.reward_list = {}
	local MAX_RANK_COUNT = 16 			-- 服务器给的数组长度是16
	for i = 1, MAX_RANK_COUNT do
		self.reward_list[i] = MsgAdapter.ReadInt()
	end
end

-- 夜战王城魔方人物obj_id列表
SCNightFightRedSideListInfo = SCNightFightRedSideListInfo or BaseClass(BaseProtocolStruct)
function SCNightFightRedSideListInfo:__init()
	self.msg_type = 8799
	self.red_side_count = 0
end

function SCNightFightRedSideListInfo:Decode()
	self.red_side_list = {}
	self.red_side_count = MsgAdapter.ReadInt()
	for i = 1,self.red_side_count do
		self.red_side_list[MsgAdapter.ReadUShort()] = 1
	end
end