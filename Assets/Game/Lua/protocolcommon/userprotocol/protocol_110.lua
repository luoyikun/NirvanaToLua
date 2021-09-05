local BaseProtocolStruct = BaseProtocolStruct
local BaseClass = BaseClass
local MsgAdapter = MsgAdapter


CS_TIAN_XIANG_REQ_TYPE = {
    ALL_INFO                 = 0,	-- 请求所有信息
    CHANGE_BEAD_TYPE         = 1,	-- 请求改变珠子颜色，p1 = x , p2 = y， p3 = 要改的颜色
    CHANGE_BEAD              = 2,	-- 请求改变位置，p1 = x , p2 = y， p3 = 目标格子的x, p4 = 目标格子的y
    IMPRINT_UP_START         = 3,	-- 印位升星 p1 印位类型 p2 是否使用保护符 p3 是否自动购买
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
    BATCH_HUNSHOU            = 16,	-- 连抽 p1 是否使用积分
    PUT_BAG                  = 17,	-- 放入背包 p1 格子id
    CONVERT_TO_EXP           = 18,	-- 一键出售
    SINGLE_CONVERT_TO_EXP    = 19,	-- 出售 p1 格子id
    PUT_BAG_ONE_KEY          = 20,	-- 一键放入背包
};

-- 
CSTianxiangOperaReq = CSTianxiangOperaReq or BaseClass(BaseProtocolStruct)
function CSTianxiangOperaReq:__init()
    self.msg_type = 11000

    self.info_type = 0
    self.param1    = 0
    self.param2    = 0
    self.param3    = 0
    self.param4    = 0
end

function CSTianxiangOperaReq:Encode()
    MsgAdapter.WriteBegin(self.msg_type)
    MsgAdapter.WriteShort(self.info_type)
    MsgAdapter.WriteShort(self.param1)
    MsgAdapter.WriteShort(self.param2)
    MsgAdapter.WriteShort(self.param3)
    MsgAdapter.WriteShort(self.param4)
end


-- 组合
TianXiangCombineParam = TianXiangCombineParam or BaseClass(BaseProtocolStruct)
function TianXiangCombineParam:__init()
    self.x   = 0
    self.y   = 0
    self.seq = 0
end

function TianXiangCombineParam:Encode()
    MsgAdapter.WriteChar(self.x)
    MsgAdapter.WriteChar(self.y)
    MsgAdapter.WriteChar(self.seq)
end

function TianXiangCombineParam:Decode()
    self.x = MsgAdapter.ReadChar()
    self.y = MsgAdapter.ReadChar()
    self.seq = MsgAdapter.ReadChar()
end


-- 珠子
TianXiangBeadParam = TianXiangBeadParam or BaseClass(BaseProtocolStruct)
function TianXiangBeadParam:__init()
    self.x    = 0
    self.y    = 0
    self.type = 0
end

function TianXiangBeadParam:Encode()
    MsgAdapter.WriteChar(self.x)
    MsgAdapter.WriteChar(self.y)
    MsgAdapter.WriteChar(self.type)
end

function TianXiangBeadParam:Decode()
    self.x = MsgAdapter.ReadChar()
    self.y = MsgAdapter.ReadChar()
    self.type = MsgAdapter.ReadChar()
end


-- 全部信息列表
SCSendTianXiangAllInfo = SCSendTianXiangAllInfo or BaseClass(BaseProtocolStruct)
function SCSendTianXiangAllInfo:__init()
    self.msg_type = 11001

    self.grid_list    = {}
    self.combine_list = {}
end


function SCSendTianXiangAllInfo:Decode()
    local grid_list_count = MsgAdapter.ReadUShort()
    self.grid_list = {}
    for i = 1, grid_list_count do
        self.grid_list[i] = TianXiangBeadParam.New()
        self.grid_list[i]:Decode()
    end
    local combine_list_count = MsgAdapter.ReadUShort()
    self.combine_list = {}
    for i = 1, combine_list_count do
        self.combine_list[i] = TianXiangCombineParam.New()
        self.combine_list[i]:Decode()
    end
end

CS_FABAO_REQ_TYPE = {
    CS_FABAO_REQ_TYPE_UPGRADE                = 0,	-- 请求进阶,param1 = 是否自动购买,param2 = 重复升阶次数
    CS_FABAO_REQ_TYPE_ACTIVESPECIALIMG       = 1,	-- 请求激活特殊形象,param1 = 特殊形象id,param2 = 是否公布
    CS_FABAO_REQ_TYPE_UNACTIVESPECIALIMG     = 2,	-- 请求撤消特殊形象,激活后取消激活,param1 = 特殊形象id
    CS_FABAO_REQ_TYPE_USESPECIALIMG          = 3,	-- 请求使用特殊形象,param1 = 特殊形象id
    CS_FABAO_REQ_TYPE_UNUSESPECIALIMG        = 4,	-- 请求卸下特殊形象,脱下,param1 = 特殊形象id
    CS_FABAO_REQ_TYPE_FABAOSPECIALIMGUPGRADE = 5,	-- 特殊形象进阶,param1 = 特殊形象id
    CS_FABAO_REQ_TYPE_USEIMA                 = 6,	-- 使用形象,param1 = 形象id
    CS_FABAO_REQ_TYPE_UPLEVELSKILL           = 7,	-- 请求升级技能,param1 = 技能索引,param2 = 是否自动购买材料
    CS_FABAO_REQ_TYPE_UPLEVELEQUIP           = 8,	-- 请求升级装备,param1 = 装备索引
};

-- 法宝信息
SCSendFabaoInfo = SCSendFabaoInfo or BaseClass(BaseProtocolStruct)
function SCSendFabaoInfo:__init()
    self.msg_type = 11002

    self.grade                     = 0	-- 阶级
    self.used_imageid              = 0	-- 使用的形象
    self.used_special_id           = 0	-- 使用的特殊形象
    self.active_image_flag         = 0	-- 激活的形象
    self.active_special_image_flag = 0	-- 激活的特殊形象
    self.grade_bless_val           = 0	-- 进阶祝福值
    self.special_img_grade_list    = {}	-- 特殊形象阶数
    self.shuxingdan_count          = 0	-- 使用的属性丹数量
    self.clear_bless_time          = 0	-- 进阶祝福值清零时间
    self.last_upgrade_succ_time    = 0	-- 上一次进阶成功的时间
    self.skill_level_list          = {}	-- 技能等级列表，下标为技能索引
    self.equip_level_list          = {}	-- 装备等级列表，下标为技能索引
    self.equip_skill_level         = 0	-- 装备技能等级
    self.is_used_special_img       = 0	-- 是否使用幻化形象
end


function SCSendFabaoInfo:Decode()
    self.grade = MsgAdapter.ReadShort()
    self.used_imageid = MsgAdapter.ReadShort()
    self.used_special_id = MsgAdapter.ReadShort()

    local active_image_flag_count = MsgAdapter.ReadUShort()
    self.active_image_flag = {}
    for i = 0, active_image_flag_count - 1 do                   -- 形象激活标记
        self.active_image_flag[i] = MsgAdapter.ReadUChar()
    end

    local active_special_image_flag_count =  MsgAdapter.ReadUShort()
    self.active_special_image_flag = {}
    for i = 0, active_special_image_flag_count - 1 do                   -- 特殊形象激活标记
        self.active_special_image_flag[i] = MsgAdapter.ReadUChar()
    end

    self.grade_bless_val = MsgAdapter.ReadInt()
    local special_img_grade_list_count = MsgAdapter.ReadUShort()
    self.special_img_grade_list = {}
    for i = 1, special_img_grade_list_count do
        self.special_img_grade_list[i] = MsgAdapter.ReadChar()
    end
    self.shuxingdan_count = MsgAdapter.ReadShort()
    self.clear_bless_time = MsgAdapter.ReadInt()
    self.last_upgrade_succ_time = MsgAdapter.ReadInt()
    local skill_level_list_count = MsgAdapter.ReadUShort()
    self.skill_level_list = {}
    for i = 1, skill_level_list_count do
        self.skill_level_list[i] = MsgAdapter.ReadShort()
    end
    local equip_level_list_count = MsgAdapter.ReadUShort()
    self.equip_level_list = {}
    for i = 1, equip_level_list_count do
        self.equip_level_list[i] = MsgAdapter.ReadShort()
    end
    self.equip_skill_level = MsgAdapter.ReadInt()
    self.is_used_special_img = MsgAdapter.ReadInt()
end


-- 法宝相关操作请求
CSFabaoOperateReq = CSFabaoOperateReq or BaseClass(BaseProtocolStruct)
function CSFabaoOperateReq:__init()
    self.msg_type = 11003

    self.req_type = 0	-- 请求类型
    self.param1   = 0
    self.param2   = 0
    self.param3   = 0
end

function CSFabaoOperateReq:Encode()
    MsgAdapter.WriteBegin(self.msg_type)
    MsgAdapter.WriteShort(self.req_type)
    MsgAdapter.WriteShort(self.param1)
    MsgAdapter.WriteShort(self.param2)
    MsgAdapter.WriteShort(self.param3)
end


-- 时装和神兵技能升级
CSShizhuangSkillUplevelReq = CSShizhuangSkillUplevelReq or BaseClass(BaseProtocolStruct)
function CSShizhuangSkillUplevelReq:__init()
    self.msg_type = 11004

    self.skill_idx      = 0	-- 请求序号
    self.auto_buy       = 0
    self.shizhuang_type = 0
end

function CSShizhuangSkillUplevelReq:Encode()
    MsgAdapter.WriteBegin(self.msg_type)
    MsgAdapter.WriteInt(self.skill_idx)
    MsgAdapter.WriteShort(self.auto_buy)
    MsgAdapter.WriteShort(self.shizhuang_type)
end


-- 时装和神兵装备进阶
CSShizhuangUplevelEquip = CSShizhuangUplevelEquip or BaseClass(BaseProtocolStruct)
function CSShizhuangUplevelEquip:__init()
    self.msg_type = 11005

    self.shizhuang_type = 0	-- 请求类型
    self.equip_idx      = 0
end

function CSShizhuangUplevelEquip:Encode()
    MsgAdapter.WriteBegin(self.msg_type)
    MsgAdapter.WriteShort(self.shizhuang_type)
    MsgAdapter.WriteShort(self.equip_idx)
end

