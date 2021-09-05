--------------------------------------------------------
--玩家身上的装备数据管理
--------------------------------------------------------
EquipData = EquipData or BaseClass()


-- 万分比属性类型
local LEGEND_PER_TYPE = {
	["per_max_gongji"] = 0,
	["per_max_fangyu"] = 0,
	["per_max_maxhp"] = 0,
	["per_max_mingzhong"] = 0,
	["per_max_shanbi"] = 0,
	["per_max_baoji"] = 0,
	["per_max_jianren"] = 0,
}
-- 等级类型属性
local LEGEND_LEVEL_TYPE = {
	["max_gongji"] = 0,
	["max_fangyu"] = 0,
	["max_maxhp"] = 0,
	["max_mingzhong"] = 0,
	["max_shanbi"] = 0,
	["max_baoji"] = 0,
	["max_jianren"] = 0,
}

-- 全身装备属性百分比
local LEGEND_EQUIP_PER_TYPE = {
	["equip_per_fang_yu"] = 0,
	["equip_per_max_hp"] = 0,
	["equip_per_gong_ji"] = 0,
}

local LEGEND_TYPE_KEY = {
	[1] = "per_max_maxhp",
	[2] = "per_max_gongji",
	[3] = "per_max_fangyu",
	[4] = "per_max_mingzhong",
	[5] = "per_max_shanbi",
	[6] = "per_max_baoji",
	[7] = "per_max_jianren",
	[8] = "max_maxhp",
	[9] = "max_gongji",
	[10] = "max_fangyu",
	[11] = "max_mingzhong",
	[12] = "max_shanbi",
	[13] = "max_baoji",
	[14] = "max_jianren",
	[20] = "equip_per_fang_yu",
	[21] = "equip_per_max_hp",
	[22] = "equip_per_gong_ji",
}

local DEFAULT_EQUIP_ICON = {
	[0] = 100,
	[1] = 1100,
	[2] = 3100,
	[3] = 4100,
	[4] = 5100,
	[5] = 6100,
	[6] = {[1] = 8100, [2] = 8115, [3] = 8130, [4] = 8145},
	[7] = 9100,
	[8] = 2100,
	[9] = 10100,
	[10] = 11100,
}

local DEFAULT_Zhuanzhi_EQUIP_ICON = {
	[0] = {[1] = 57100, [2] = 57300, [3] = 57500, [4] = 57700},
	[1] = {[1] = 55100, [2] = 55300, [3] = 55500, [4] = 55700},
	[2] = {[1] = 59100, [2] = 59300, [3] = 59500, [4] = 59700},
	[3] = {[1] = 56100, [2] = 56300, [3] = 56500, [4] = 56700},
	[4] = {[1] = 54100, [2] = 54300, [3] = 54500, [4] = 54700},
	[5] = 60100,
	[6] = 63100,
	[7] = 61100,
	[8] = {[1] = 58100, [2] = 58300, [3] = 58500, [4] = 58700},
	[9] = 62100
}

local ONE_EQUIP_INDEX = { --第一套装备根据id获取装备位置
	[100] = 1,
	[1100] = 2,
	[2100] = 9,
	[3100] = 3,
	[4100] = 4,
	[5100] = 5,
	[6100] = 6,
	[9100] = 8,
	[10100] = 10,
	[11100] = 11,
	[8100] = 7,
	[8115] = 7,
	[8130] = 7,
	[8145] = 7,
}

local WAN_PERCENT = 10000
local MAX_SHUXING_TYPE = 14

function EquipData:__init()
	if nil ~= EquipData.Instance then
		print_error("[EquipData] attempt to create singleton twice!")
		return
	end
	EquipData.Instance = self

	self.grid_data_list = {}
	self.grid_info = {}

	self.notify_data_change_callback_list = {}		--身上装备有更新变化时进行回调
	self.notify_datalist_change_callback_list = {} 	--身上装备列表有变化时回调，一般是整理时，或初始化物品列表时
	self.notify_data_count_change_callback_list = {} 	--身上装备数量变化时回调

	self.min_eternity_level = 0
	self.use_eternity_level = 0

	self.is_set_equip_info = false

	self.is_take_off_equip = false
	local equipment_cfg = ConfigManager.Instance:GetAutoItemConfig("equipment_auto")
	self.equip_cfg_list = {}
	for k,v in pairs(equipment_cfg) do
		self.equip_cfg_list[v.limit_prof] = self.equip_cfg_list[v.limit_prof] or {}
		self.equip_cfg_list[v.limit_prof][v.order] = self.equip_cfg_list[v.limit_prof][v.order] or {}
		self.equip_cfg_list[v.limit_prof][v.order][v.sub_type] = self.equip_cfg_list[v.limit_prof][v.order][v.sub_type] or {}
		self.equip_cfg_list[v.limit_prof][v.order][v.sub_type][v.color] = v
	end	
	local config = ConfigManager.Instance:GetAutoConfig("other_config_auto").equip_skill
	self.other_config_equip_skill = ListToMap(config, "equip_item_id")
end

function EquipData:__delete()
	self.grid_data_list = nil
	self.imp_guard_info_list = nil
	self.notify_data_change_callback_list = nil
	self.notify_datalist_change_callback_list = nil
	self.notify_data_count_change_callback_list = nil
	EquipData.Instance = nil
end

--一开始同步所有装备信息
function EquipData:SetDataList(datalist)
	self.grid_data_list = datalist
	self:FlushGridData()
	for k,v in pairs(self.notify_datalist_change_callback_list) do  --物品有变化，通知观察者，不带消息体
		v()
	end
	RemindManager.Instance:Fire(RemindName.KaiFu)

	self.is_set_equip_info = true
end

--强化、神铸改变
function EquipData:SetEquipmentGridInfo(datalist)
	self.grid_info = datalist
	self:FlushGridData()
	for k,v in pairs(self.notify_data_change_callback_list) do  --物品有变化，通知观察者，带消息体
		v()
	end
end

function EquipData:FlushGridData()
	if self.grid_data_list == nil or next(self.grid_data_list) == nil then
		return
	end

	for k,v in pairs(self.grid_data_list) do
		if v.param == nil then
			v.param = {}
		end
		local data = self.grid_info[k]
		if data ~= nil then
			v.param.strengthen_level = data.strengthen_level
			v.param.shen_level = data.shenzhu_level
			v.param.star_level = data.star_level
			v.param.star_exp = data.star_exp
			v.param.eternity_level = data.eternity_level
		end
	end
	
	self:EquipSkill(self.grid_data_list)
end

--改变某个格中的数据
function EquipData:ChangeDataInGrid(data)
	if data == nil then
		return
	end
	local change_reason = 2
	local change_item_id = data.item_id
	local change_item_index = data.index
	local t = self:GetGridData(data.index)

	if t ~= nil and data.num == 0 then --delete
		change_reason = 0
		change_item_id = t.item_id
		self.grid_data_list[data.index] = {}
	elseif t == nil	 then			   --add
		change_reason = 1
		for k,v in pairs(self.notify_data_count_change_callback_list) do  --物品有变化，通知观察者，不带消息体
			v()
		end
	end
	if change_reason ~= 0 then
		self.grid_data_list[data.index] = data
	end

	self:FlushGridData()

	for k,v in pairs(self.notify_data_change_callback_list) do  --物品有变化，通知观察者，带消息体
		v(change_item_id, change_item_index, change_reason)
	end
end

function EquipData:GetDataList()
	return self.grid_data_list
end

--获取身上装备数量
function EquipData:GetDataCount()
	local count = 0
	for k,v in pairs(self.grid_data_list) do
		count = count + 1
	end
	return count
end

-- 装备类型
function EquipData:IsFangJuType(equip_type)
	return GameEnum.EQUIP_TYPE_TOUKUI == equip_type or GameEnum.EQUIP_TYPE_YIFU == equip_type or GameEnum.EQUIP_TYPE_YAODAI == equip_type or
			GameEnum.EQUIP_TYPE_HUTUI == equip_type or GameEnum.EQUIP_TYPE_XIEZI == equip_type or GameEnum.EQUIP_TYPE_HUSHOU == equip_type or
			GameEnum.EQUIP_TYPE_YUPEI == equip_type or GameEnum.EQUIP_TYPE_SHOUZHUO == equip_type
end

--小宠物玩具装备类型
function EquipData.IsLittlePetToyType(equip_type)
	return GameEnum.E_TYPE_LITTLEPET_1 == equip_type or GameEnum.E_TYPE_LITTLEPET_2 == equip_type
		or GameEnum.E_TYPE_LITTLEPET_3 == equip_type or GameEnum.E_TYPE_LITTLEPET_4 == equip_type
end

-- 武器类型
function EquipData.IsWQType(equip_type)
	return GameEnum.EQUIP_TYPE_WUQI == equip_type
end

-- 饰品类型
function EquipData.IsSPType(equip_type)
	return GameEnum.EQUIP_TYPE_JIEZHI == equip_type or GameEnum.EQUIP_TYPE_XIANGLIAN == equip_type or GameEnum.EQUIP_TYPE_GOUYU == equip_type
end

-- 护甲类型
function EquipData.IsHJType(equip_type)
	return GameEnum.EQUIP_TYPE_TOUKUI == equip_type or GameEnum.EQUIP_TYPE_YIFU == equip_type
end

-- 防具类型
function EquipData.IsFJType(equip_type)
	return GameEnum.EQUIP_TYPE_HUTUI == equip_type or GameEnum.EQUIP_TYPE_HUSHOU == equip_type or GameEnum.EQUIP_TYPE_XIEZI == equip_type
end

-- 是否普通装备
function EquipData:IsCommonEquipType(equip_type)
	return ((equip_type >= GameEnum.EQUIP_TYPE_TOUKUI) and (equip_type <= GameEnum.EQUIP_TYPE_SHOUZHUO))
end

-- 转职装备
function EquipData:IsZhuanzhiEquipType(equip_type)
	if not equip_type then return end
	return ((equip_type >= GameEnum.E_TYPE_ZHUANZHI_WUQI) and (equip_type <= GameEnum.E_TYPE_ZHUANZHI_YUPEI))
end

-- 百战装备
function EquipData:IsBaiZhanEquipType(equip_type)
	if not equip_type then return end
	return ((equip_type >= GameEnum.E_TYPE_BAIZHAN_WUQI) and (equip_type <= GameEnum.E_TYPE_BAIZHAN_YUPEI))
end

-- 转职装备首饰四件
function EquipData:IsZhuanzhiEquipShoushiType(equip_type)
	if not equip_type then return end
	return (equip_type == GameEnum.E_TYPE_ZHUANZHI_XIANGLIAN or equip_type == GameEnum.E_TYPE_ZHUANZHI_SHOUZHUO or 
		equip_type == GameEnum.E_TYPE_ZHUANZHI_JIEZHI or equip_type == GameEnum.E_TYPE_ZHUANZHI_YUPEI)
end

-- 转职装备首饰三件
function EquipData:IsZhuanzhiEquipShoushiType2(equip_type)
	if not equip_type then return end
	return (equip_type == GameEnum.E_TYPE_ZHUANZHI_XIANGLIAN or equip_type == GameEnum.E_TYPE_ZHUANZHI_SHOUZHUO or 
		equip_type == GameEnum.E_TYPE_ZHUANZHI_JIEZHI)
end

-- 转生装备
function EquipData.IsZhuanshnegEquipType(equip_type)
	if equip_type >= 900 and equip_type <= 909 then
		return true
	end
	return false
end

--飞仙装备类型
function EquipData.IsFeiXianEquipType(equip_type)
	if equip_type >= 1100 and equip_type <= 1109 then
		return equip_type
	end
	return -1
end

-- 精灵类型
function EquipData.IsJLType(equip_type)
	return GameEnum.EQUIP_TYPE_JINGLING == equip_type
end

function EquipData:SetImpGuardInfo(imp_guard_list)
	self.imp_guard_info_list = {}
	for i=1,ImpGuardData.IMP_GUARD_GRID_INDEX_MAX do
		self.imp_guard_info_list[i] = {}
		self.imp_guard_info_list[i].used_imp_type = imp_guard_list[i].used_imp_type or 0
		self.imp_guard_info_list[i].item_wrapper = imp_guard_list[i].item_wrapper
		self.imp_guard_info_list[i].is_expire = imp_guard_list[i].is_expire
	end
end

function EquipData:GetImpGuardInfo()
	return self.imp_guard_info_list
end

function EquipData:GetImpGuardActiveInfo()
	if self.imp_guard_info_list == nil then return false end
	local my_servertime = TimeCtrl.Instance:GetServerTime()
	for k,v in pairs(self.imp_guard_info_list) do
		if v.used_imp_type == 1 and v.item_wrapper.invalid_time > my_servertime then
			return true
		end
	end
	return false
end

function EquipData.GetXiaoGuiCfgType(imp_type)
	local impguard_auto = ConfigManager.Instance:GetAutoConfig("impguard_auto")
	local cfg = impguard_auto.imp
	for k,v in pairs(cfg) do
		if imp_type == v.imp_type then
			return v
		end
	end	
	return nil
end

function EquipData.GetXiaoGuiCfgById(item_id)
	local impguard_auto = ConfigManager.Instance:GetAutoConfig("impguard_auto")
	local cfg = impguard_auto.imp
	local cur_item_id = item_id
	if cur_item_id and cur_item_id == 64101 then 	--特殊的经验熊猫，需要改成正常的id进行判断
		cur_item_id = 64100
	end

	for k,v in pairs(cfg) do
		if cur_item_id == v.item_id then
			return v
		end
	end	
	return nil
end

function EquipData.IsBetterExchangeXiaoGui(data)
	local impguard_cfg = EquipData.GetXiaoGuiCfgById(data.item_id)
	local xiaogui_type = impguard_cfg.imp_type or 0

	local xiaogui_info = EquipData.Instance:GetImpGuardInfo()
	if xiaogui_info and xiaogui_info[xiaogui_type] then
		local equip_time_left = xiaogui_info[xiaogui_type].item_wrapper.invalid_time or 0
		local bag_time_left
		if data.invalid_time then
			bag_time_left = data.invalid_time
		else
			local item_data = ItemData.Instance:GetGridData(data.index)
			bag_time_left = item_data and item_data.invalid_time or 0
		end
		return ((bag_time_left - equip_time_left) > 0)
	else
		return true
	end
end

-- 小鬼装备
function EquipData.IsXiaoguiEqType(equip_type)
	return GameEnum.EQUIP_TYPE_XIAOGUI == equip_type
end

--是否是小鬼
function EquipData.GetIsXiaoGui(item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg == nil then
		return false
	end
	return item_cfg.sub_type == GameEnum.EQUIP_TYPE_XIAOGUI
end

-- 获得背包和身上的所有过期和未过期的小鬼
function EquipData:GetBagXiaoGuiList()
	local guoqi_list = {}
	local noguoqi_list = {}
	local bag_item_list = ItemData.Instance:GetBagItemDataList()
	for k,v in pairs(bag_item_list) do
		if EquipData.GetIsXiaoGui(v.item_id) then
			local time = math.max(v.invalid_time - TimeCtrl.Instance:GetServerTime(), 0)
			if time <= 0 then
				v.is_inbag = IMP_GUARD_REQ_TYPE.IMP_GUARD_REQ_TYPE_RENEW_KNAPSACK
				guoqi_list[#guoqi_list + 1] = v
			else
				noguoqi_list[#noguoqi_list + 1] = v
			end
		end
	end
	
	local imp_guard_info_list = self:GetImpGuardInfo()
	for i = 1, ImpGuardData.IMP_GUARD_GRID_INDEX_MAX do
		if imp_guard_info_list[i] then
			if imp_guard_info_list[i].is_expire == 1 then
				imp_guard_info_list[i].item_wrapper.is_inbag = IMP_GUARD_REQ_TYPE.IMP_GUARD_REQ_TYPE_RENEW_PUTON
				guoqi_list[#guoqi_list + 1] = imp_guard_info_list[i].item_wrapper
			else
				noguoqi_list[#noguoqi_list + 1] = imp_guard_info_list[i].item_wrapper
			end
		end
	end

	return guoqi_list, noguoqi_list
end

function EquipData:GetGuoQiExpXiaoGui()   --小鬼过期：如果身上有高级的两个小鬼，低级两个小鬼直接无视过期提示，身上过期小鬼中优先提示经验小鬼
	local is_guoqi = false
	local xiaogui_data = nil
	local xiaogui_1 = nil
	local xiaogui_2 = nil
	local xiaogui_3 = nil
	local xiaogui_4 = nil
	local guoqi_1 = nil
	local guoqi_2 = nil
	local guoqi_3 = nil
	local guoqi_4 = nil
	local guoqi_list, noguoqi_list = self:GetBagXiaoGuiList()

	if #guoqi_list == 0 then
		return false
	end

	if #noguoqi_list > 0 then
		for k,v in pairs(noguoqi_list) do
			local xiaogui_cfg = EquipData.GetXiaoGuiCfgById(v.item_id)
			if xiaogui_cfg then
				if xiaogui_cfg.imp_type == 3 then	--高级经验
					xiaogui_3 = v.item_id
				elseif xiaogui_cfg.imp_type == 1 then	--低级经验
					xiaogui_1 = v.item_id
				end
			end
		end
		-- if xiaogui_4 and xiaogui_2 then
		-- 	return false
		-- end
	end

	for k,v in pairs(guoqi_list) do
		local xiaogui_cfg = EquipData.GetXiaoGuiCfgById(v.item_id)
		if xiaogui_cfg then
			if xiaogui_cfg.imp_type == 3 then	--高级经验
				guoqi_3 = v
			elseif xiaogui_cfg.imp_type == 1 then	--低级经验
				guoqi_1= v
			end
		end
	end

	if guoqi_3 and nil == xiaogui_3 then
		is_guoqi = true
		xiaogui_data = guoqi_3
	elseif guoqi_1 and nil == xiaogui_1 then
		is_guoqi = true
		xiaogui_data = guoqi_1
	end

	return is_guoqi, xiaogui_data
end

function EquipData:GetGuoQiGuardXiaoGui()   --小鬼过期：如果身上有高级的两个小鬼，低级两个小鬼直接无视过期提示，身上过期小鬼中优先提示经验小鬼
	local is_guoqi = false
	local xiaogui_data = nil
	local xiaogui_2 = nil
	local xiaogui_4 = nil
	local guoqi_2 = nil
	local guoqi_4 = nil
	local guoqi_list, noguoqi_list = self:GetBagXiaoGuiList()

	if #guoqi_list == 0 then
		return false
	end

	if #noguoqi_list > 0 then
		for k,v in pairs(noguoqi_list) do
			local xiaogui_cfg = EquipData.GetXiaoGuiCfgById(v.item_id)
			if xiaogui_cfg then
				if xiaogui_cfg.imp_type == 4 then		--高级守护
					xiaogui_4 = v.item_id
				elseif xiaogui_cfg.imp_type == 2 then	--低级守护
					xiaogui_2 = v.item_id
				end
			end
		end
		if xiaogui_4 and xiaogui_2 then
			return false
		end
	end

	for k,v in pairs(guoqi_list) do
		local xiaogui_cfg = EquipData.GetXiaoGuiCfgById(v.item_id)
		if xiaogui_cfg then
			if xiaogui_cfg.imp_type == 4 then		--高级守护
				guoqi_4 = v
			elseif xiaogui_cfg.imp_type == 2 then	--低级守护
				guoqi_2 = v
			end
		end
	end

	if guoqi_4 and nil == xiaogui_4 then
		is_guoqi = true
		xiaogui_data = guoqi_4
	elseif guoqi_2 and nil == xiaogui_2 then
		is_guoqi = true
		xiaogui_data = guoqi_2
	end

	return is_guoqi, xiaogui_data
end

--情缘装备类型
function EquipData.IsMarryEqType(equip_type)
	return GameEnum.E_TYPE_QINGYUAN_1 == equip_type or GameEnum.E_TYPE_QINGYUAN_2 == equip_type
	or GameEnum.E_TYPE_QINGYUAN_3 == equip_type or GameEnum.E_TYPE_QINGYUAN_4 == equip_type
end

-- 生肖装备类型
function EquipData.IsShengXiaoEqType(equip_type)
	return GameEnum.EQUIP_TYPE_SHENGXIAO_1 == equip_type or GameEnum.EQUIP_TYPE_SHENGXIAO_2 == equip_type
	or GameEnum.EQUIP_TYPE_SHENGXIAO_3 == equip_type or GameEnum.EQUIP_TYPE_SHENGXIAO_4 == equip_type
	or GameEnum.EQUIP_TYPE_SHENGXIAO_5 == equip_type
end

-- 龙器类型
function EquipData.IsLongQiEqType(equip_type)
	return GameEnum.EQUIP_TYPE_LONGQI_1 == equip_type or GameEnum.EQUIP_TYPE_LONGQI_2 == equip_type
	or GameEnum.EQUIP_TYPE_LONGQI_3 == equip_type or GameEnum.EQUIP_TYPE_LONGQI_4 == equip_type
	or GameEnum.EQUIP_TYPE_LONGQI_5 == equip_type
end

-- 神魔/变身装备类型
function EquipData.IsBianShenEquipType(equip_type)
	return GameEnum.BIAN_SHEN_EQUIP_TYPE_1 == equip_type or GameEnum.BIAN_SHEN_EQUIP_TYPE_2 == equip_type
	or GameEnum.BIAN_SHEN_EQUIP_TYPE_3 == equip_type or GameEnum.BIAN_SHEN_EQUIP_TYPE_4 == equip_type
end

function EquipData.IsLittlePetEqType(equip_type)
	return GameEnum.USE_TYPE_LITTLE_PET == equip_type
end

function EquipData.IsJinglingSoul(equip_type)
	return GameEnum.EQUIP_TYPE_JINGLING_SOUL == equip_type
end
--通过装备类型获得可以放置的索引
function EquipData:GetEquipIndexByType(sub_type)
	if not sub_type then return -1 end
	-- 普通装备
	local sub_type_to_index = {
		[GameEnum.EQUIP_TYPE_TOUKUI] = 0,
		[GameEnum.EQUIP_TYPE_YIFU] = 1,
		[GameEnum.EQUIP_KUZI] = 2,
		[GameEnum.EQUIP_TYPE_XIEZI] = 3,
		[GameEnum.EQUIP_TYPE_HUSHOU] = 4,
		[GameEnum.EQUIP_TYPE_XIANGLIAN] = 5,
		[GameEnum.EQUIP_TYPE_WUQI] = 6,
		[GameEnum.EQUIP_TYPE_JIEZHI] = 7,
		[GameEnum.EQUIP_TYPE_YAODAI] = 8,
		[GameEnum.EQUIP_TYPE_YUPEI] = 9,
		[GameEnum.EQUIP_TYPE_SHOUZHUO] = 10,
	}

	if sub_type_to_index[sub_type] then
		return sub_type_to_index[sub_type]
	elseif sub_type >= GameEnum.E_TYPE_ZHUANZHI_WUQI and sub_type <= GameEnum.E_TYPE_ZHUANZHI_YUPEI then
		-- 转职装
		local zhuanzhi_sub_type_to_index = {
			[GameEnum.E_TYPE_ZHUANZHI_WUQI] = 0,
			[GameEnum.E_TYPE_ZHUANZHI_YIFU] = 1,
			[GameEnum.E_TYPE_ZHUANZHI_HUSHOU] = 2,
			[GameEnum.E_TYPE_ZHUANZHI_YAODAI] = 3,
			[GameEnum.E_TYPE_ZHUANZHI_TOUKUI] = 4,
			[GameEnum.E_TYPE_ZHUANZHI_XIANGLIAN] = 5,
			[GameEnum.E_TYPE_ZHUANZHI_SHOUZHUO] = 6,
			[GameEnum.E_TYPE_ZHUANZHI_JIEZHI] = 7,
			[GameEnum.E_TYPE_ZHUANZHI_XIEZI] = 8,
			[GameEnum.E_TYPE_ZHUANZHI_YUPEI] = 9,
		}
		return zhuanzhi_sub_type_to_index[sub_type]
	elseif sub_type >= GameEnum.E_TYPE_BAIZHAN_WUQI and sub_type <= GameEnum.E_TYPE_BAIZHAN_YUPEI then
		-- 百战装
		local baizhan_sub_type_to_index = {
			[GameEnum.E_TYPE_BAIZHAN_WUQI] = 0,
			[GameEnum.E_TYPE_BAIZHAN_YIFU] = 1,
			[GameEnum.E_TYPE_BAIZHAN_HUSHOU] = 2,
			[GameEnum.E_TYPE_BAIZHAN_YAODAI] = 3,
			[GameEnum.E_TYPE_BAIZHAN_TOUKUI] = 4,
			[GameEnum.E_TYPE_BAIZHAN_XIANGLIAN] = 5,
			[GameEnum.E_TYPE_BAIZHAN_SHOUZHUO] = 6,
			[GameEnum.E_TYPE_BAIZHAN_JIEZHI] = 7,
			[GameEnum.E_TYPE_BAIZHAN_XIEZI] = 8,
			[GameEnum.E_TYPE_BAIZHAN_YUPEI] = 9,
		}
		return baizhan_sub_type_to_index[sub_type]
	elseif sub_type >= GameEnum.E_TYPE_DOUQI_WUQI and sub_type <= GameEnum.E_TYPE_DOUQI_YJIEZHI then
		local douqi_sub_type_to_index = {
			[GameEnum.E_TYPE_DOUQI_WUQI] = 0,
			[GameEnum.E_TYPE_DOUQI_TOUKUI] = 1,
			[GameEnum.E_TYPE_DOUQI_YIFU] = 2,
			[GameEnum.E_TYPE_DOUQI_HUSHOU] = 3,
			[GameEnum.E_TYPE_DOUQI_FUWU] = 4,
			[GameEnum.E_TYPE_DOUQI_HUTUI] = 5,
			[GameEnum.E_TYPE_DOUQI_XIEZI] = 6,
			[GameEnum.E_TYPE_DOUQI_SHOUZHUO] = 7,
			[GameEnum.E_TYPE_DOUQI_XIANGLIANG] = 8,
			[GameEnum.E_TYPE_DOUQI_YJIEZHI] = 9,
		}
		return douqi_sub_type_to_index[sub_type]
	end
	return -1
end

--得到戒指索引
function EquipData:GetJieZhiEquipIndex()
	local equiplist = EquipData.Instance:GetDataList()
	if equiplist then
		if not equiplist[GameEnum.EQUIP_INDEX_JIEZHI] or equiplist[GameEnum.EQUIP_INDEX_JIEZHI].item_id == 0 then
			return GameEnum.EQUIP_INDEX_JIEZHI 
		end
		if not equiplist[GameEnum.EQUIP_INDEX_JIEZHI_2] or equiplist[GameEnum.EQUIP_INDEX_JIEZHI_2].item_id == 0 then
			return GameEnum.EQUIP_INDEX_JIEZHI_2
		end
		local capability1 = self:GetEquipLegendFightPowerByData(equiplist[GameEnum.EQUIP_INDEX_JIEZHI], true)
		local capability2 = self:GetEquipLegendFightPowerByData(equiplist[GameEnum.EQUIP_INDEX_JIEZHI_2], true)
		return capability2 < capability1 and GameEnum.EQUIP_INDEX_JIEZHI_2 or GameEnum.EQUIP_INDEX_JIEZHI
	end
	return GameEnum.EQUIP_INDEX_JIEZHI or GameEnum.EQUIP_INDEX_JIEZHI_2
end

--绑定数据改变时的回调方法.用于任意物品有更新时进行回调
function EquipData:NotifyDataChangeCallBack(callback, notify_datalist, notify_count_change)
	self:UnNotifyDataChangeCallBack(callback)
	if notify_datalist then
		self.notify_datalist_change_callback_list[#self.notify_datalist_change_callback_list + 1] = callback
	elseif notify_count_change then
		self.notify_data_count_change_callback_list[#self.notify_data_count_change_callback_list + 1] = callback
	else
		self.notify_data_change_callback_list[#self.notify_data_change_callback_list + 1] = callback
	end
end

--移除绑定回调
function EquipData:UnNotifyDataChangeCallBack(callback)
	for k,v in pairs(self.notify_data_change_callback_list) do
		if v == callback then
			self.notify_data_change_callback_list[k] = nil
			return
		end
	end
	for k,v in pairs(self.notify_datalist_change_callback_list) do
		if v == callback then
			self.notify_datalist_change_callback_list[k] = nil
			return
		end
	end
	for k,v in pairs(self.notify_data_count_change_callback_list) do
		if v == callback then
			self.notify_data_count_change_callback_list[k] = nil
			return
		end
	end
end

--获得某个格子的数据
function EquipData:GetGridData(index)
	return self.grid_data_list[index]
end

function EquipData.GetEquipBg(index)
	if index == GameEnum.EQUIP_INDEX_TOUKUI then
		return "HelmetBG"
	elseif index == GameEnum.EQUIP_INDEX_YIFU then
		return "ClothesBG"
	elseif index == GameEnum.EQUIP_INDEX_HUTUI then
		return "LegGuardBG"
	elseif index == GameEnum.EQUIP_INDEX_XIEZI then
		return "ShoesBG"
	elseif index == GameEnum.EQUIP_INDEX_HUSHOU then
		return "GlovesBG"
	elseif index == GameEnum.EQUIP_INDEX_XIANLIAN2 or index == GameEnum.EQUIP_INDEX_XIANLIAN1 then
		return "NecklaceBG"
	elseif index == GameEnum.EQUIP_INDEX_WUQI then
		return "WeaponsBG"
	elseif index == GameEnum.EQUIP_JIEZHI_2 or index == GameEnum.EQUIP_JIEZHI_1 then
		return "RingBG"
	end
end

function EquipData.GetFSEquipSubtype(index)
	if index == GameEnum.FS_EQUIP_INDEX_WUQI then
		return GameEnum.FS_EQUIP_TYPE_WUQI
	elseif index == GameEnum.FS_EQUIP_INDEX_YIFU then
		return GameEnum.FS_EQUIP_TYPE_YIFU
	elseif index == GameEnum.FS_EQUIP_INDEX_HUSHOU then
		return GameEnum.FS_EQUIP_TYPE_HUSHOU
	elseif index == GameEnum.FS_EQUIP_INDEX_YAODAI then
		return GameEnum.FS_EQUIP_TYPE_YAODAI
	elseif index == GameEnum.FS_EQUIP_INDEX_TOUKUI then
		return GameEnum.FS_EQUIP_TYPE_TOUKUI
	elseif index == GameEnum.FS_EQUIP_INDEX_XIANGLIAN then
		return GameEnum.FS_EQUIP_TYPE_XIANGLIAN
	elseif index == GameEnum.FS_EQUIP_INDEX_SHOUZHUO then
		return GameEnum.FS_EQUIP_TYPE_SHOUZHUO
	elseif index == GameEnum.FS_EQUIP_INDEX_JIEZHI then
		return GameEnum.FS_EQUIP_TYPE_JIEZHI
	elseif index == GameEnum.FS_EQUIP_INDEX_XIEZI then 
		return GameEnum.FS_EQUIP_TYPE_XIEZI
	elseif index == GameEnum.FS_EQUIP_INDEX_YUPEI then
		return GameEnum.FS_EQUIP_TYPE_YUPEI
	end
end

-- 获取装备基础和传说属性战力(人物基本装备)
-- is_from_equip 是否穿着在身上装备
-- is_single_fight_pwoer 是否计算单件装备
function EquipData:GetEquipLegendFightPowerByData(data, is_from_equip, is_single_fight_pwoer, vo)
	local fight_power = 0
	fight_power = self:CalculateEquipXianPinCapability(data, is_from_equip, is_single_fight_pwoer, vo)
	return fight_power
end

-- 当前选择装备的传奇属性加成
local select_equip_legend_list = {
		["equip_per_gong_ji"] = 0,
		["equip_per_fang_yu"]= 0,
		["equip_per_max_hp"] = 0,
}
-- 对应格子装备传奇属性加成
local grid_equip_legend_list = {
		["equip_per_gong_ji"] = 0,
		["equip_per_fang_yu"] = 0,
		["equip_per_max_hp"] = 0,
}
function EquipData:CalculateEquipXianPinCapability(data, is_from_equip, is_single_fight_pwoer, vo)
	for k, v in pairs(LEGEND_EQUIP_PER_TYPE) do
		LEGEND_EQUIP_PER_TYPE[k] = 0
		select_equip_legend_list[k] = 0
		grid_equip_legend_list[k] = 0
	end

	if not data then return 0 end

	local item_cfg, big_type = ItemData.Instance:GetItemConfig(data.item_id)
	if not item_cfg then return 0 end

	local vo = vo or GameVoManager.Instance:GetMainRoleVo()
	local capability = 0
	local legend_cfg = nil
	-- 身上装备总属性
	local total_attr_list = CommonDataManager.GetAttributteByClass()
	local type_key = ""
	local this_equip_index = is_from_equip and data.index or self:GetEquipIndexByType(item_cfg.sub_type)
	-- 当前选择装备的属性
	local select_equip_attr_list = CommonDataManager.GetAttributteByClass(item_cfg)
	-- 对应格子装备上的属性
	local grid_equip_attr_list = CommonDataManager.GetAttributteByClass()

	-- 身上装备
	for k, v in pairs(self.grid_data_list) do
		item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if this_equip_index == k then
			grid_equip_attr_list = CommonDataManager.GetAttributteByClass(item_cfg)
		end

		total_attr_list = CommonDataManager.AddAttributeAttr(total_attr_list, CommonDataManager.GetAttributteByClass(item_cfg))
		for k2, v2 in pairs(v.param.xianpin_type_list or {}) do
			legend_cfg = ForgeData.Instance:GetLegendCfgByType(v2)
			if nil ~= legend_cfg
				and nil ~= LEGEND_TYPE_KEY[legend_cfg.shuxing_type] then
				type_key = LEGEND_TYPE_KEY[legend_cfg.shuxing_type]

				if this_equip_index == k then
					grid_equip_legend_list[type_key] = legend_cfg.add_value
				end

				if nil ~= LEGEND_EQUIP_PER_TYPE[type_key] then
					LEGEND_EQUIP_PER_TYPE[type_key] = LEGEND_EQUIP_PER_TYPE[type_key] + legend_cfg.add_value
				end
			end
		end
	end

	-- 当前选择装备
	local temp_xianpin_list = data.param and data.param.xianpin_type_list or {}
	for k, v in pairs(temp_xianpin_list or {}) do
		legend_cfg = ForgeData.Instance:GetLegendCfgByType(v)
		if nil ~= legend_cfg
			and nil ~= LEGEND_TYPE_KEY[legend_cfg.shuxing_type] then
			type_key = LEGEND_TYPE_KEY[legend_cfg.shuxing_type]

			select_equip_legend_list[type_key] = legend_cfg.add_value
		end
	end

	-- 脱下当前格子装备的属性差值
	local diff_attr_list = CommonDataManager.GetAttributteByClass()
	diff_attr_list.gong_ji = total_attr_list.gong_ji * grid_equip_legend_list["equip_per_gong_ji"] / 10000
							+ grid_equip_attr_list.gong_ji *
							(LEGEND_EQUIP_PER_TYPE["equip_per_gong_ji"] / 10000 + 1 - grid_equip_legend_list["equip_per_gong_ji"] / 10000)

	diff_attr_list.fang_yu = total_attr_list.fang_yu * grid_equip_legend_list["equip_per_fang_yu"] / 10000
							+ grid_equip_attr_list.fang_yu *
							(LEGEND_EQUIP_PER_TYPE["equip_per_fang_yu"] / 10000 + 1 - grid_equip_legend_list["equip_per_fang_yu"] / 10000)

	diff_attr_list.max_hp = total_attr_list.max_hp * grid_equip_legend_list["equip_per_max_hp"] / 10000
							+ grid_equip_attr_list.max_hp *
							(LEGEND_EQUIP_PER_TYPE["equip_per_max_hp"] / 10000 + 1 - grid_equip_legend_list["equip_per_max_hp"] / 10000)

	total_attr_list.gong_ji = total_attr_list.gong_ji - grid_equip_attr_list.gong_ji
	total_attr_list.fang_yu = total_attr_list.fang_yu - grid_equip_attr_list.fang_yu
	total_attr_list.max_hp = total_attr_list.max_hp - grid_equip_attr_list.max_hp

	LEGEND_EQUIP_PER_TYPE["equip_per_gong_ji"] = LEGEND_EQUIP_PER_TYPE["equip_per_gong_ji"] - grid_equip_legend_list["equip_per_gong_ji"]
	LEGEND_EQUIP_PER_TYPE["equip_per_fang_yu"] = LEGEND_EQUIP_PER_TYPE["equip_per_fang_yu"] - grid_equip_legend_list["equip_per_fang_yu"]
	LEGEND_EQUIP_PER_TYPE["equip_per_max_hp"] = LEGEND_EQUIP_PER_TYPE["equip_per_max_hp"] - grid_equip_legend_list["equip_per_max_hp"]

	local final_attr_list = CommonDataManager.GetAttributteByClass()
	final_attr_list = CommonDataManager.AddAttributeBaseAttr(final_attr_list, vo)
	final_attr_list.gong_ji = vo.base_gongji - diff_attr_list.gong_ji
	final_attr_list.fang_yu = vo.base_fangyu - diff_attr_list.fang_yu
	final_attr_list.max_hp = vo.base_max_hp - diff_attr_list.max_hp
	final_attr_list.ming_zhong = vo.base_mingzhong - grid_equip_attr_list.ming_zhong
	final_attr_list.shan_bi = vo.base_shanbi - grid_equip_attr_list.shan_bi
	final_attr_list.bao_ji = vo.base_baoji - grid_equip_attr_list.bao_ji
	final_attr_list.jian_ren = vo.base_jianren - grid_equip_attr_list.jian_ren
	final_attr_list.per_jingzhun = vo.base_per_jingzhun - grid_equip_attr_list.per_jingzhun
	final_attr_list.per_baoji = vo.base_per_baoji - grid_equip_attr_list.per_baoji
	final_attr_list.per_mianshang = vo.base_per_mianshang - grid_equip_attr_list.per_mianshang
	final_attr_list.per_pofang = vo.base_per_pofang - grid_equip_attr_list.per_pofang
	final_attr_list.goddess_gongji = (vo.base_goddess_gongji or vo.base_fujia_shanghai) - grid_equip_attr_list.goddess_gongji

	-- bug...之前的代码没漏了这2个属性，导致计算战力错误。因为装备没有这两个属性，所以不加减。
	final_attr_list.constant_zengshang = vo.base_constant_zengshang
	final_attr_list.constant_mianshang = vo.base_constant_mianshang

	if is_from_equip then
		capability = vo.capability - CommonDataManager.GetCapabilityCalculation(final_attr_list) - vo.other_capability
	else
		diff_attr_list.gong_ji = total_attr_list.gong_ji * select_equip_legend_list["equip_per_gong_ji"] / 10000
								+ select_equip_attr_list.gong_ji *
								(LEGEND_EQUIP_PER_TYPE["equip_per_gong_ji"] / 10000 + 1 + select_equip_legend_list["equip_per_gong_ji"] / 10000)

		diff_attr_list.fang_yu = total_attr_list.fang_yu * select_equip_legend_list["equip_per_fang_yu"] / 10000
								+ select_equip_attr_list.fang_yu *
								(LEGEND_EQUIP_PER_TYPE["equip_per_fang_yu"] / 10000 + 1 + select_equip_legend_list["equip_per_fang_yu"] / 10000)

		diff_attr_list.max_hp = total_attr_list.max_hp * select_equip_legend_list["equip_per_max_hp"] / 10000
								+ select_equip_attr_list.max_hp *
								(LEGEND_EQUIP_PER_TYPE["equip_per_max_hp"] / 10000 + 1 + select_equip_legend_list["equip_per_max_hp"] / 10000)

		final_attr_list.gong_ji = final_attr_list.gong_ji + diff_attr_list.gong_ji
		final_attr_list.fang_yu = final_attr_list.fang_yu + diff_attr_list.fang_yu
		final_attr_list.max_hp = final_attr_list.max_hp + diff_attr_list.max_hp
		final_attr_list.ming_zhong = final_attr_list.ming_zhong + select_equip_attr_list.ming_zhong
		final_attr_list.shan_bi = final_attr_list.shan_bi + select_equip_attr_list.shan_bi
		final_attr_list.bao_ji = final_attr_list.bao_ji + select_equip_attr_list.bao_ji
		final_attr_list.jian_ren = final_attr_list.jian_ren + select_equip_attr_list.jian_ren
		final_attr_list.per_jingzhun = final_attr_list.per_jingzhun + select_equip_attr_list.per_jingzhun
		final_attr_list.per_baoji = final_attr_list.per_baoji + select_equip_attr_list.per_baoji
		final_attr_list.per_mianshang = final_attr_list.per_mianshang + select_equip_attr_list.per_mianshang
		final_attr_list.per_pofang = final_attr_list.per_pofang + select_equip_attr_list.per_pofang
		final_attr_list.goddess_gongji = final_attr_list.goddess_gongji + select_equip_attr_list.goddess_gongji

		if not is_single_fight_pwoer then
			capability = CommonDataManager.GetCapabilityCalculation(final_attr_list) + vo.other_capability
		else
			select_equip_attr_list.gong_ji = diff_attr_list.gong_ji
			select_equip_attr_list.fang_yu = diff_attr_list.fang_yu
			select_equip_attr_list.max_hp = diff_attr_list.max_hp
			capability = CommonDataManager.GetCapabilityCalculation(select_equip_attr_list)
		end
	end

	return capability
end

--获取武器战力
function EquipData:GetEquipCapacity(data)
	if nil == data or nil == data.item_id then
		return 0
	end

	local capability = EquipData.Instance:GetEquipLegendFightPowerByData(data)
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	capability = capability - game_vo.capability
	return capability
end

function EquipData:CheckIsAutoEquip(item_id, bag_index, compare_zhanli)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if nil == item_cfg or nil == item_cfg.sub_type then
		return
	end
	if item_cfg.sub_type == 202 then --婚戒
		return true
	end

	local equip_index = self:GetEquipIndexByType(item_cfg.sub_type)
	if not equip_index then return end

	local new_equip_data = ItemData.Instance:GetGridData(bag_index)
	local old_euqip_data = {}
	if ((item_cfg.sub_type >= GameEnum.E_TYPE_ZHUANZHI_WUQI) and (item_cfg.sub_type <= GameEnum.E_TYPE_ZHUANZHI_YUPEI)) and equip_index then
		old_euqip_data = ForgeData.Instance:GetZhuanzhiEquip(equip_index)
	elseif EquipData.Instance:IsBaiZhanEquipType(item_cfg.sub_type) then
		old_euqip_data = ForgeData.Instance:GetBaiZhanEquip(equip_index)
	elseif DouQiData.Instance:IsDouqiEqupi(item_id) then
		old_euqip_data = DouQiData.Instance:GetDouqiEquipByIndex(equip_index + 1)
	else
		old_euqip_data = self:GetGridData(equip_index)
	end

	local new_equip_power = self:GetEquipCapacityPower(new_equip_data)
	local old_equip_power = self:GetEquipCapacityPower(old_euqip_data)

	if compare_zhanli then
		return (new_equip_power - old_equip_power >= compare_zhanli)
	else
		return (new_equip_power - old_equip_power >= COMMON_CONSTS.COMPARE_MIN_POWER)
	end
end

function EquipData:GetTextColor1(the_color_1)
	local color_text_1 = ""
	if the_color_1 == 1 then
		color_text_1 = TEXT_COLOR.GREEN_2
	elseif the_color_1 == 2 then
		color_text_1 = TEXT_COLOR.BLUE_2
	elseif the_color_1 == 3 then
		color_text_1 = TEXT_COLOR.PURPLE_2
	elseif the_color_1 == 4 then
		color_text_1 = TEXT_COLOR.ORANGE_2
	elseif the_color_1 == 5 then
		color_text_1 = TEXT_COLOR.RED_2
	end
	return color_text_1
end

function EquipData:GetTextColor2(the_color_2)
	local color_text_2 = ""
	if the_color_2 == 1 then
		color_text_2 = TEXT_COLOR.GREEN_1
	elseif the_color_2 == 2 then
		color_text_2 = TEXT_COLOR.BLUE_1
	elseif the_color_2 == 3 then
		color_text_2 = TEXT_COLOR.PURPLE_1
	elseif the_color_2 == 4 then
		color_text_2 = TEXT_COLOR.ORANGE_1
	elseif the_color_2 == 5 then
		color_text_2 = TEXT_COLOR.RED_1
	end
	return color_text_2
end

function EquipData:IsSetEquipInfo()
	return self.is_set_equip_info
end

function EquipData:SetTakeOffFlag(value)
	self.is_take_off_equip = value
end

function EquipData:GetTakeOffFlag()
	return self.is_take_off_equip
end

function EquipData:SetMinEternityLevel(min_eternity_level)
	self.min_eternity_level = min_eternity_level or 0
end

function EquipData:GetMinEternityLevel()
	return self.min_eternity_level
end

function EquipData:SetUseEternityLevel(use_eternity_level)
	self.use_eternity_level = use_eternity_level or 0
end

function EquipData:GetUseEternityLevel()
	return self.use_eternity_level
end

--粉色装备技能
function EquipData:EquipSkill(data)
	self.equip_skill_list = {}
	for i = GameEnum.EQUIP_INDEX_HUSHOU, GameEnum.EQUIP_INDEX_WUQI do
		if nil ~= data[i] then
			local item_cfg = ItemData.Instance:GetItemConfig(data[i].item_id)
			local equip_cfg = self.other_config_equip_skill[data[i].item_id]
			if nil ~= equip_cfg then
				table.insert(self.equip_skill_list, equip_cfg.skill_id)	
				-- self.equip_skill_list[i - 3] = equip_cfg.skill_id
			end
		end
 	end

 	table.sort(self.equip_skill_list)
end

function EquipData:GetEquipSkilIdList()
	return self.equip_skill_list
end

function EquipData:GetEquipSkilId(item_id)
	return self.other_config_equip_skill[item_id]
end

function EquipData:GetOrderEquip(prof, order, sub_type, color)
	local cfg = self.equip_cfg_list[prof]
	if cfg and cfg[order] and cfg[order][sub_type] then
		return cfg[order][sub_type][color]
	end
	cfg = self.equip_cfg_list[5]
	if cfg and cfg[order] and cfg[order][sub_type] then
		return cfg[order][sub_type][color]
	end

	return nil
end

-- 普通装备默认icon
function EquipData:GetDefaultIcon(equip_index)
	local id = DEFAULT_EQUIP_ICON[equip_index]
	if id and type(id) == "table" then
		local prof = PlayerData.Instance:GetRoleBaseProf()
		id = id[prof]
	end
	return id
end

-- 是否是默认装备
function EquipData:GetNewEquipIndex(equip_id)
	return ONE_EQUIP_INDEX[equip_id]
end

-- 转职装备默认icon
function EquipData:GetZhuanzhiDefaultIcon(equip_index)
	local id = DEFAULT_Zhuanzhi_EQUIP_ICON[equip_index]
	if id and type(id) == "table" then
		local prof = PlayerData.Instance:GetRoleBaseProf()
		id = id[prof]
	end
	return id
end

-- 计算单件装备战斗力
function EquipData:GetEquipCapacityPower(equip_data)
	if not equip_data or not equip_data.item_id then 
		return 0 
	end
	local item_cfg = ItemData.Instance:GetItemConfig(equip_data.item_id)

	if nil == item_cfg then
		return 0
	end

	local base_capacity = 0
	local legend_capacity = 0

	-- 基础属性
	local base_attr = CommonDataManager.GetAttributteNoUnderline(item_cfg)
	base_capacity = CommonDataManager.GetCapabilityCalculation(base_attr)

	-- 传奇属性
	local equip_index = self:GetEquipIndexByType(item_cfg.sub_type)
	if self:IsZhuanzhiEquipType(item_cfg.sub_type) and equip_index then
		if equip_data.param and equip_data.param.xianpin_type_list then
			local zhuanzhi_equip = ForgeData.Instance:GetZhuanzhiEquipAll()
			local attr_tab = CommonStruct.Attribute()
			for k, v in pairs(zhuanzhi_equip) do
				if v.index == equip_index then
					local item_cfg = ItemData.Instance:GetItemConfig(equip_data.item_id)
					local temp_attr_tab = CommonDataManager.GetAttributteByClass(item_cfg)
					attr_tab = CommonDataManager.AddAttributeAttr(attr_tab, temp_attr_tab)
				elseif v and v.item_id > 0 then
					local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
					local temp_attr_tab = CommonDataManager.GetAttributteByClass(item_cfg)
					attr_tab = CommonDataManager.AddAttributeAttr(attr_tab, temp_attr_tab)
				end
			end

			-- 取出传奇属性
			local legend_list = {}
			for k, v in pairs(equip_data.param.xianpin_type_list) do
				local xianpin_cfg = ForgeData.Instance:GetLegendCfgByType(v)
				if xianpin_cfg then
					legend_list[xianpin_cfg.shuxing_type] = xianpin_cfg.add_value
				end
			end

			attr_tab = ForgeData.Instance:CalcLegendAttrCapacity(attr_tab, legend_list)
			legend_capacity = CommonDataManager.GetCapabilityCalculation(attr_tab)
		end
	end

	return (base_capacity + legend_capacity)
end


-- 操作装备快速使用
function EquipData:FlushBagEquipUse()
	local bag_list = ItemData.Instance:GetBagItemDataList()
	local gamevo = GameVoManager.Instance:GetMainRoleVo()
	local equip_sub_type = {}
	local power_list = {}
	for k, v in pairs(bag_list) do
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
		if big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT then
			if item_cfg and (gamevo.prof % 10) == item_cfg.limit_prof or item_cfg.limit_prof == 5 then
				local power = self:GetEquipCapacityPower(v)
				if not equip_sub_type[item_cfg.sub_type] or not power_list[item_cfg.sub_type] or 
					(power and power_list[item_cfg.sub_type] < power) then
					if self:IsBaiZhanEquipType(item_cfg.sub_type) then
						-- 如果是百战装备必须满足等级条件
						if gamevo.level >= item_cfg.limit_level then
							equip_sub_type[item_cfg.sub_type] = v
							power_list[item_cfg.sub_type] = power							
						end
					elseif self:IsZhuanzhiEquipType(item_cfg.sub_type) then
						-- 如果是转职装备必须满足等级条件和转职条件
						-- local prof, zhuan = PlayerData.Instance:GetRoleBaseProf()
						-- local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
						-- local zhuanzhi_info = ForgeData.Instance:GetZhuanzhiEquipInfo(equip_index, item_cfg.order)
						-- if gamevo.level >= item_cfg.limit_level and zhuan >= zhuanzhi_info.role_need_min_prof_level then
						-- 	equip_sub_type[item_cfg.sub_type] = v
						-- 	power_list[item_cfg.sub_type] = power							
						-- end						
					else
						equip_sub_type[item_cfg.sub_type] = v
						power_list[item_cfg.sub_type] = power				
					end
				end
			end
		end
	end

	for k, v in pairs(equip_sub_type) do
		TipsCtrl.Instance:ShowShorCutEquipView(v.item_id, v.index)
	end
end