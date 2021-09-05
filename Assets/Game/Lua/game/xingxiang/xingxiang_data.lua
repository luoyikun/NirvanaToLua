XingXiangData = XingXiangData or BaseClass()

function XingXiangData:__init()
	if XingXiangData.Instance then
		print_error("[XingXiangData] Attemp to create a singleton twice !")
	end
	XingXiangData.Instance = self
	self.jinghua_num = 0
	self.xingxiang_list = {}
	for i = 1 , GameEnum.ZODIAC_MAX_NUM do
		self.xingxiang_list[i] = {}
		self.xingxiang_list[i].level = -1
		self.xingxiang_list[i].activate_flag = -1
	end

	self.zodiac_cfg = ConfigManager.Instance:GetAutoConfig("zodiac_cfg_auto")
	self.zodiac_liebiao_list = ListToMap(self.zodiac_cfg.liebiao, "shengxiao")
	self.stuff_id_list = ListToMap(self.zodiac_cfg.real_id_list, "zodiac_index", "suipian_index")
	self.levelup_cfg = ListToMap(self.zodiac_cfg.levelup, "zodiac_index", "level")
	self.other_cfg = self.zodiac_cfg.other[1]


	self.shengxiao_bag_list = {
		item_id = -1,
		zodiac_index = -1,
		suipian_index = -1,
	}
	self.xingxiang_activate_cfg = ConfigManager.Instance:GetAutoConfig("zodiac_cfg_auto").activate
	RemindManager.Instance:Register(RemindName.XingXiangView, BindTool.Bind(self.GetShengXiaoRemind, self))
end

function XingXiangData:__delete()
	RemindManager.Instance:UnRegister(RemindName.XingXiangView)
	XingXiangData.Instance = nil
end

function XingXiangData:GetListData()
	return self.zodiac_liebiao_list
end

function XingXiangData:GetTxtColor(data_index)
	if self.zodiac_liebiao_list and data_index > 1 and self.zodiac_liebiao_list[data_index - 2] then
		return self.zodiac_liebiao_list[data_index - 2].color
	end
	return 0
end

function XingXiangData:SetJingHuangNum(protocol)
	self.jinghua_num = protocol.jinghua_num or 0
end

function XingXiangData:GetStuffIdByIndex(zodiac_index, suipian_index)
	if self.stuff_id_list and self.stuff_id_list[zodiac_index] and self.stuff_id_list[zodiac_index][suipian_index] then
		return self.stuff_id_list[zodiac_index][suipian_index].suipian_id
	end
end

function XingXiangData:GetZodiacMaxLevel(zodiac_index)
	return GetListNum(self.levelup_cfg[zodiac_index]) - 1
end

function XingXiangData:GetJingHuangNum()
	return self.jinghua_num
end

--分解背包信息
function XingXiangData:SetXingXiangBagData(item)
	self.xingxiang_bag_list = item
end

function XingXiangData:GetXingXiangBagData()
	return self.xingxiang_bag_list
end

function XingXiangData:GetJingHuaByIndex(zodiac_index, suipian_index)
	if self.zodiac_cfg == nil or self.zodiac_cfg.decompose == nil then
		return 0
	end
	for k, v in pairs(self.zodiac_cfg.decompose) do
		if v.zodiac_index == zodiac_index and v.suipian_index == suipian_index then
			return v.jinghua_num
		end
	end
	return 0
end

function XingXiangData:GetMaxLevel()
	return self.other_cfg.max_level or 50
end

function XingXiangData:GetXingXiangLevelCfg(cur_index)
	local level_cfg = ConfigManager.Instance:GetAutoConfig("zodiac_cfg_auto").levelup
	local level_data = {}
	for k,v in pairs(level_cfg) do
		if cur_index - 1 == v.zodiac_index then
			table.insert(level_data, v)
		end
	end
	return level_data
end

--生肖信息
function XingXiangData:SetXingXiangData(zodiac_item)
	self.xingxiang_list = zodiac_item
end

function XingXiangData:GetXingXiangData()
	return self.xingxiang_list
end

function XingXiangData:CanRecycle(data)
	local index = data.zodiac_index + 1
	if self.xingxiang_list and self.xingxiang_list[index] and self.xingxiang_list[index].activate_flag then
		local flag_data = bit:d2b(self.xingxiang_list[index].activate_flag)
		if flag_data[32 -  data.suipian_index] ~= 1 then
			return false
		end
	end
	return true
end

--
function XingXiangData:GetCurAttr(cur_index)
	local cur_attr_list = {}
	for k,v in pairs(self.xingxiang_activate_cfg) do
		if cur_index - 1 == v.zodiac_index then
			table.insert(cur_attr_list, v)
		end
	end
	return cur_attr_list
end

function XingXiangData:GetCurDataList(cur_index)
	local data_list = {}
	local flag_data = bit:d2b(self.xingxiang_list[cur_index].activate_flag)
	local flag_num = 0
	local is_true = nil
	for i=1, 4 do
		is_true = flag_data[32 - i + 1] == 1 and true or false
		if is_true then
			flag_num = flag_num + 1
		end
	end
	for k,v in pairs(self.xingxiang_activate_cfg) do
		if cur_index - 1 == v.zodiac_index and flag_num >= v.activate_num then
			table.insert(data_list, v)
		end
	end
	return data_list
end



function XingXiangData:GetCurNeedNum(cur_index)
	local level_cfg = ConfigManager.Instance:GetAutoConfig("zodiac_cfg_auto").levelup
	local shengxiao_data = self:GetXingXiangData()
	if shengxiao_data then
		for k,v in pairs(level_cfg) do
			if shengxiao_data[cur_index].level == v.level and cur_index - 1 == v.zodiac_index then
				jinghua_data = v.jinghua_num
			end
		end
	end
	return jinghua_data or 0
end

-- 生肖红点提示
function XingXiangData:GetShengXiaoRemind()
	local shengxiao_list = self:GetXingXiangBagData()
	local jinghua_num = XingXiangData.Instance:GetJingHuangNum()
	local shengxiao_data = self:GetXingXiangData()

	for i = 1, GameEnum.ZODIAC_MAX_NUM do
		local jinghua_data = XingXiangData.Instance:GetCurNeedNum(i)
		local flag_num = XingXiangData.Instance:GetCurXingXiangFlagNum(i)
		local max_level = XingXiangData.Instance:GetZodiacMaxLevel(i - 1)
		local level = shengxiao_data[i].level
		if jinghua_num >= jinghua_data and flag_num >= 4 and level < max_level then
			return 1
		end
	end
	
	

	if shengxiao_list then
		if next(shengxiao_list) ~= nil then
			return 1
		end
		
	end
	return 0
end


function XingXiangData:GetShengxiaoTotalAttr()
	-- local total_attr = CommonStruct.Attribute()
	-- for i= 1, GameEnum.ZODIAC_MAX_NUM do
	-- 	total_attr = CommonDataManager.AddAttributeAttr(total_attr, self:GetOneShengXiaoAttr(i))
	-- end
	-- return total_attr

	local total_attr = CommonStruct.Attribute()
	
	for i= 1, GameEnum.ZODIAC_MAX_NUM do
		local level_cfg = self:GetXingXiangLevelCfg(i)
		local shengxiao_data = self:GetXingXiangData()
		local flag_num = self:GetCurXingXiangFlagNum(i)
		local data_list = self:GetCurDataList(i)

		local level_o = {}   -- 当前属性
		for k,v in pairs(level_cfg) do
			if v.level == shengxiao_data[i].level then
				table.insert(level_o , v)
			end
		end
		if flag_num < 4 and flag_num > 0 then
			level_o = data_list
		end

		local jihuo_list = self:GetAllAttrsData(level_o)
		total_attr = CommonDataManager.AddAttributeAttr(total_attr, jihuo_list)
	end
	return total_attr
end

function XingXiangData:GetOneShengXiaoAttr(zodiac_index)
	local shengxiao_cfg = self.zodiac_cfg.activate
	local data_list = {}

	local flag_data = bit:d2b(self.xingxiang_list[zodiac_index].activate_flag)
	local flag_num = 0
	local is_true = nil
	for i=1, 4 do
		is_true = flag_data[32 - i + 1] == 1 and true or false
		if is_true then
			flag_num = flag_num + 1
		end
	end

	for k,v in pairs(shengxiao_cfg) do
		if zodiac_index == v.zodiac_index and flag_num >= v.activate_num then
			table.insert(data_list, v)
		end
	end

	local one_attr = self:GetShengQiBasicsData(data_list)
	return one_attr
end

-- 某个星象的碎片激活数量
function XingXiangData:GetCurXingXiangFlagNum(zodiac_index)
	local flag_data = bit:d2b(self.xingxiang_list[zodiac_index].activate_flag)
	local flag_num = 0
	local is_true = nil
	for i=1, 4 do
		is_true = flag_data[32 - i + 1] == 1 and true or false
		if is_true then
			flag_num = flag_num + 1
		end
	end
	return flag_num
end

function XingXiangData:GetZhanDouLi(attr_list)
	local jihuo_list = self:GetShengQiBasicsData(attr_list)
	local attribute = CommonDataManager.GetAttributteByClass(jihuo_list)
	local capability = CommonDataManager.GetCapability(attribute)
	return capability
end


local Attribute = {
	[GameEnum.BASE_CHARINTATTR_TYPE_MAXHP] = "max_hp",
	[GameEnum.BASE_CHARINTATTR_TYPE_GONGJI] = "gong_ji",
	[GameEnum.BASE_CHARINTATTR_TYPE_FANGYU] = "fang_yu",
	[GameEnum.BASE_CHARINTATTR_TYPE_MINGZHONG] = "ming_zhong",
	[GameEnum.BASE_CHARINTATTR_TYPE_SHANBI] = "shan_bi",
	[GameEnum.BASE_CHARINTATTR_TYPE_BAOJI] = "bao_ji",
	[GameEnum.BASE_CHARINTATTR_TYPE_JIANREN] = "jian_ren",
	[GameEnum.BASE_CHARINTATTR_TYPE_MOVE_SPEED] = "move_speed",
	[GameEnum.BASE_CHARINTATTR_TYPE_FUJIA_SHANGHAI] = "goddess_gongji",
	[GameEnum.BASE_CHARINTATTR_TYPE_DIKANG_SHANGHAI] = "dikang_shanghai",
	[GameEnum.BASE_CHARINTATTR_TYPE_PER_JINGZHUN] = "per_jingzhun",
	[GameEnum.BASE_CHARINTATTR_TYPE_PER_BAOJI] = "per_baoji",
	[GameEnum.BASE_CHARINTATTR_TYPE_PER_KANGBAO] = "per_kang_bao",
	[GameEnum.BASE_CHARINTATTR_TYPE_PER_POFANG] = "per_pofang",
	[GameEnum.BASE_CHARINTATTR_TYPE_PER_MIANSHANG] = "per_mianshang",
	[GameEnum.BASE_CHARINTATTR_TYPE_CONSTANT_ZENGSHANG] = "constant_zengshang",
	[GameEnum.BASE_CHARINTATTR_TYPE_CONSTANT_MIANSHANG] = "constant_mianshang",
	[GameEnum.BASE_CHARINTATTR_TYPE_HUIXINYIJI] = "huixinyiji",
	[GameEnum.BASE_CHARINTATTR_TYPE_HUIXINYIJI_HURT_PER] = "huixinyiji_hurt_per",
	[GameEnum.SPEICAL_CHARINTATTR_TYPE_PVP_JIANSHANG_PER] = "pvp_jianshang",
	[GameEnum.SPEICAL_CHARINTATTR_TYPE_PVP_ZENGSHANG_PER] = "pvp_zengshang",
	[GameEnum.SPEICAL_CHARINTATTR_TYPE_PVE_JIANSHANG_PER] = "pve_jianshang",
	[GameEnum.SPEICAL_CHARINTATTR_TYPE_PVE_ZENGSHANG_PER] = "pve_zengshang",
	[GameEnum.BASE_CHARINTATTR_TYPE_ZHUFUYIJI_PER] = "zhufuyiji_per",
	[GameEnum.BASE_CHARINTATTR_TYPE_SKILL_ZENGSHANG] = "skill_zengshang",
	[GameEnum.BASE_CHARINTATTR_TYPE_SKILL_JIANSHANG] = "skill_jianshang",
	[GameEnum.BASE_CHARINTATTR_TYPE_MINGZHONG_PER] = "mingzhong_per",
	[GameEnum.BASE_CHARINTATTR_TYPE_SHANBI_PER] = "shanbi_per",
	[GameEnum.BASE_CHARINTATTR_TYPE_PER_BAOJI_HURT] = "per_baoji_hurt",
	[GameEnum.BASE_CHARINTATTR_TYPE_PER_KANGBAO_HURT] = "per_kangbao_hurt",
	[GameEnum.BASE_CHARINTATTR_TYPE_GEDANG_PER] = "gedang_per",
	[GameEnum.BASE_CHARINTATTR_TYPE_GEDANG_JIANSHANG_PER] = "gedang_jianshang",

}

function XingXiangData:GetShengQiBasicsData(table_data)
	local strength_data = table_data
	local value = CommonStruct.Attribute()
	if next(strength_data) == nil then
		return value
	end

	for k,v in pairs(strength_data) do
		if v.attr_type then
			local type_value = value[Attribute[v.attr_type]] or 0
			if type_value > 0 then
				type_value = type_value + v.attr_value
			else
				type_value = v.attr_value
			end
			value[Attribute[v.attr_type]] = type_value
		end

		if v.attr_type_0 then
			local type_value = value[Attribute[v.attr_type_0]] or 0
			if type_value > 0 then
				type_value = type_value + v.attr_value_0
			else
				type_value = v.attr_value_0
			end
			value[Attribute[v.attr_type_0]] = type_value
		end

		if v.attr_type_1 then
			local type_value = value[Attribute[v.attr_type_1]] or 0
			if type_value > 0 then
				type_value = type_value + v.attr_value_1
			else
				type_value = v.attr_value_1
			end
			value[Attribute[v.attr_type_1]] = type_value
		end

		if v.attr_type_2 then
			local type_value = value[Attribute[v.attr_type_2]] or 0
			if type_value > 0 then
				type_value = type_value + v.attr_value_2
			else
				type_value = v.attr_value_2
			end
			value[Attribute[v.attr_type_2]] = type_value
		end

		if v.attr_type_3 then
			local type_value = value[Attribute[v.attr_type_3]] or 0
			if type_value > 0 then
				type_value = type_value + v.attr_value_3
			else
				type_value = v.attr_value_3
			end
			value[Attribute[v.attr_type_3]] = type_value
		end
	end
	return value 
end

function XingXiangData:GetAllAttrsData(table_data)
	local strength_data = table_data
	local value = CommonStruct.Attribute()
	if next(strength_data) == nil then
		return value
	end

	for k,v in pairs(strength_data) do
		if v.attr_type then
			local type_value = value[Attribute[v.attr_type]] or 0
			if type_value > 0 then
				type_value = type_value + v.attr_value
			else
				type_value = v.attr_value
			end
			value[Attribute[v.attr_type]] = type_value
		end

		if v.attr_type_0 then
			local type_value = value[Attribute[v.attr_type_0]] or 0
			if type_value > 0 then
				type_value = type_value + v.attr_value_0
			else
				type_value = v.attr_value_0
			end
			value[Attribute[v.attr_type_0]] = type_value
		end

		if v.attr_type_1 then
			local type_value = value[Attribute[v.attr_type_1]] or 0
			if type_value > 0 then
				type_value = type_value + v.attr_value_1
			else
				type_value = v.attr_value_1
			end
			value[Attribute[v.attr_type_1]] = type_value
		end

		if v.attr_type_2 then
			local type_value = value[Attribute[v.attr_type_2]] or 0
			if type_value > 0 then
				type_value = type_value + v.attr_value_2
			else
				type_value = v.attr_value_2
			end
			value[Attribute[v.attr_type_2]] = type_value
		end
	end
	return value 
end




