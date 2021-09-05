LuoShuData = LuoShuData or BaseClass()

LUOSHU_TYPE ={
	LUOSHU = 0,
	SHENHUA = 1,
}

local BAG_PAGE_COUNT = 8				-- 每页个数

local LUO_MAX = 200

local CUR_MAX_TYPE = 4 		--当前只有四个类型
local INDEX_MAX_TYPE = 16 	--一个类型有十六种卡片

function LuoShuData:__init()
	if LuoShuData.Instance then
		print_error("[LuoShuData] 尝试创建第二个单例模式")
		return
	end
	LuoShuData.Instance = self

	self.all_info = {
		data = {},
		upgrade_data = {
		level = 0,
		exp = 0
		},
	}

	self.heshen_luoshu_cfg_auto = ConfigManager.Instance:GetAutoConfig("heshen_luoshu_cfg_auto")
	self.luoshu_upgrade_star = self.heshen_luoshu_cfg_auto.upgrade_star

	self.upgrade_star = ListToMap(self.heshen_luoshu_cfg_auto.upgrade_star, "seq", "index", "star_level")
	self.luoshu_open_day = ListToMap(self.heshen_luoshu_cfg_auto.luoshu_open_day, "seq", "index")
	
	self.hesh_max_level = 200 --河神洛书升华卡片最高等级

	RemindManager.Instance:Register(RemindName.HeSheLuoShu, BindTool.Bind(self.RemindHeShenLuoShuAll, self))
	RemindManager.Instance:Register(RemindName.LuoShu, BindTool.Bind(self.RemindHeShenLuoShuActive, self))
	RemindManager.Instance:Register(RemindName.ShenHua, BindTool.Bind(self.RemindHeShenLuoShuUpgrade, self))
end

function LuoShuData:__delete()
	LuoShuData.Instance = nil

	RemindManager.Instance:UnRegister(RemindName.HeSheLuoShu)
	RemindManager.Instance:UnRegister(RemindName.LuoShu)
	RemindManager.Instance:UnRegister(RemindName.ShenHua)
end

-----------------河神洛书-------------------------
function LuoShuData:SetHeShenLuoShuAllInfo(protocol)
	self.all_info.data = protocol.data
	self.all_info.upgrade_data = protocol.upgrade_data
end

function LuoShuData:SetHeShenLuoShuChangeInfo(protocol)
	self.all_info.data[protocol.param1][protocol.param2][protocol.param3] = protocol.param4
	self.all_info.upgrade_data[protocol.param1][protocol.param2].level = protocol.param5
	self.all_info.upgrade_data[protocol.param1][protocol.param2].exp = protocol.param6
end

function LuoShuData:GetLuoShuStarCount(luoshu_type, seq, index)
	local luoshu_type = luoshu_type or 0
	seq = seq or 0
	index = index or 0
	if self.all_info.data[luoshu_type] and self.all_info.data[luoshu_type][seq] and self.all_info.data[luoshu_type][seq][index] then
		return self.all_info.data[luoshu_type][seq][index]
	end
end

function LuoShuData:SetHeShenLuoShuShowIndex(index)
	self.show_index = index
end

function LuoShuData:GetHeShenLuoShuShowIndex()
	return self.show_index
end

function LuoShuData:SetHeShenLuoShuSelectType(index)
	self.select_type = index
end

function LuoShuData:GetHeShenLuoShuSelectType()
	return self.select_type
end

function LuoShuData:SetHeShenLuoShuSelectSeq(index)
	self.select_seq = index
end

function LuoShuData:GetHeShenLuoShuSelectSeq()
	return self.select_seq
end

function LuoShuData:SetHeShenLuoShuSelectIndex(index)
	self.select_index = index
end

function LuoShuData:GetHeShenLuoShuSelectIndex()
	return self.select_index
end
--菜单列表
function LuoShuData:GetTableIndex()
	function GetChild(type_index)
		local config = {}
		for k,v in pairs(self.heshen_luoshu_cfg_auto.small_table) do
			if type_index == v.type then
				config[k] = {}
				config[k].type = v.type
				config[k].seq_type = v.seq_type
				config[k].seq_name = v.seq_name
			end
		end
		return config
	end
	local config = {}
	for k,v in ipairs(self.heshen_luoshu_cfg_auto.menu_table) do
		local vo = {}
		vo.type  = v.type 
		vo.name = v.type_name
		vo.child = GetChild(vo.type)
		config[#config + 1]  = vo
	end
	return config
end
--获取河神洛书激活数量
function LuoShuData:GettHeShenLuoShuActiveNum()
	local num = 0
	for i,v in pairs(self:GetHeShenLuoShuDataByTypeAndSeq()) do
		if v >= 0 then
			num = num + 1
		end
	end
	return num
end
--获取河神洛书套装属性
function LuoShuData:GetHeShenLuoShuSuitAttrList()
	for i,v in ipairs(self.heshen_luoshu_cfg_auto.suite_attr) do
		if v.type == self.select_type and v.seq == self.select_seq and self:GettHeShenLuoShuActiveNum() >= v.suit_num then
			return v
		end
	end
end

--获取河神洛书所有套装数据
function LuoShuData:GetAllHeShenLuoShuSuitData()
	local data_list = {}
	if self.all_info.data[0]then
		local data = self.all_info.data[0]
		for i = 0,CUR_MAX_TYPE - 1 do
			if data[i] then
				for k,v in pairs(data[i]) do
					if self.upgrade_star[i] and self.upgrade_star[i][k] and self.upgrade_star[i][k][v+1] then
						local data = self.upgrade_star[i][k][v+1]
						if self:HeShenLuoShuIsOpen(0,i,k) then
							table.insert(data_list, data)
						end
					end
				end
			end
		end
	end
	return data_list
end

--获取河神洛书套装数据
function LuoShuData:GetHeShenLuoShuSuitData()
	local data_list = {}
	local data = self.all_info.data
	if next(data) then
		for k,v in ipairs(self.luoshu_upgrade_star) do
			if data[v.type] and data[v.type][v.seq] and data[v.type][v.seq][v.index] and
				v.seq == self.select_seq and data[v.type][v.seq][v.index] == v.star_level then
				if self:HeShenLuoShuIsOpen(v.type, v.seq, v.index) then
					table.insert(data_list, v)
				end
			end
		end
	end
	return data_list
end

function LuoShuData:GetOpenMaxIndex()
	local data_list = self:GetHeShenLuoShuSuitData()
	local max_index = 0
	for k, v in pairs(data_list) do
		if v.index > max_index then
			max_index = v.index
		end
	end
	return max_index
end

--判断洛书是否开启
function LuoShuData:HeShenLuoShuIsOpen(luoshu_type, luoshu_seq, luoshu_index)
	if nil == luoshu_type or nil == luoshu_seq or nil == luoshu_index then
		return false
	end
	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local role_level = PlayerData.Instance:GetRoleLevel()
	if self.luoshu_open_day[luoshu_seq] and self.luoshu_open_day[luoshu_seq][luoshu_index] then
		local info = self.luoshu_open_day[luoshu_seq][luoshu_index]
		if open_server_day >= info.open_day and role_level >= info.open_level then
			return true
		end
	end
	return false
end

function LuoShuData:GetHeShenLuoShuTotalData()
	local data_list = {}
	local data = self.all_info.data
	for k,v in ipairs(self.luoshu_upgrade_star) do
		if data[v.type] and data[v.type][v.seq] and data[v.type][v.seq][v.index] and 
			data[v.type][v.seq][v.index] == v.star_level then
			table.insert(data_list, v)
		end
	end
	return data_list
end

function LuoShuData:GetHeShenLuoShuSeqData()
	local data_list = {}
	local data = self.all_info.data
	for k,v in ipairs(self.luoshu_upgrade_star) do
		if data[v.type] and data[v.type][v.seq] and data[v.type][v.seq][v.index] and 
			v.seq == self.select_seq and data[v.type][v.seq][v.index] == v.star_level then
			table.insert(data_list, v)
		end
	end
	return data_list
end

function LuoShuData:GetHeShenLuoShuDataListByIndex(index)
	local data_list = self:GetHeShenLuoShuSuitData()
	local luoshu_list = {}
	for k, v in ipairs(data_list) do
		if v.index == index then
			table.insert(luoshu_list, v)
		end
	end
	return luoshu_list[1] or {}
end

function LuoShuData:GetHeShenLuoShuSeqAttr()
	local total_attr = CommonStruct.Attribute()
	for k,v in pairs(self:GetHeShenLuoShuSeqData()) do
		total_attr = CommonDataManager.AddAttributeAttr(total_attr, CommonDataManager.GetAttributteByClass(v))
	end
	return total_attr
end

function LuoShuData:GetHeShenLuoShuSuitAttr()
	local suit_attr = CommonStruct.Attribute()
	suit_attr = CommonDataManager.AddAttributeAttr(suit_attr, CommonDataManager.GetAttributteByClass(self:GetHeShenLuoShuSuitAttrList()))
	for k, v in pairs(self:GetHeShenLuoShuSuitData()) do
		suit_attr = CommonDataManager.AddAttributeAttr(suit_attr, CommonDataManager.GetAttributteByClass(v))
	end
	return suit_attr
end

function LuoShuData:GetHeShenLuoShuTotalAttr()
	local total_attr = CommonStruct.Attribute()
	for k,v in pairs(self:GetHeShenLuoShuTotalData()) do
		total_attr = CommonDataManager.AddAttributeAttr(total_attr, CommonDataManager.GetAttributteByClass(v))
	end
	return total_attr
end

function LuoShuData:GetHeShenLuoShuSingleAttr(index, next_level)
	local single_attr = CommonStruct.Attribute()
	local other = self.heshen_luoshu_cfg_auto.other
	local level = next_level and self:GetHeShenLuoShuDataByIndex(index) + 1 or self:GetHeShenLuoShuDataByIndex(index)
	if level > other[1].max_star_level then
		single_attr = {}
		return single_attr
	end
	for k,v in ipairs(self.luoshu_upgrade_star) do
		if v.type == self.select_type and v.seq == self.select_seq and v.index == index and v.star_level == level then
			single_attr = CommonDataManager.AddAttributeAttr(single_attr, CommonDataManager.GetAttributteByClass(v))
		end
	end
	return single_attr
end


--根据类型和索引获取河神洛书数据
function LuoShuData:GetHeShenLuoShuDataByTypeAndSeq()
	local data = {}
	if self.all_info.data[self.select_type] and self.all_info.data[self.select_type][self.select_seq] then
		data = self.all_info.data[self.select_type][self.select_seq]
	end
	return data
end

function LuoShuData:GetHeShenLuoShuDataByIndex(index)
	if self.all_info.data[self.select_type] and self.all_info.data[self.select_type][self.select_seq] then
		return self.all_info.data[self.select_type][self.select_seq][index] or 0
	end
	return 0
end

function LuoShuData:GetHeShenLuoShuUpgradeDataByTypeAndSeq()
	if self.all_info.upgrade_data[self.select_type] and self.all_info.upgrade_data[self.select_type][self.select_seq] then
		return self.all_info.upgrade_data[self.select_type][self.select_seq]
	end
end

--根据类型和索引获取河神洛书数据
function LuoShuData:GetHeShenLuoShuAllDataByTypeAndSeq(next_level)
	local data_list = {}
	for k,v in ipairs(self.luoshu_upgrade_star) do

		if v.type == self.select_type and v.seq == self.select_seq then
			for i = 0, 15 do
				local level = next_level and self:GetHeShenLuoShuDataByIndex(i) + 1 or self:GetHeShenLuoShuDataByIndex(i)
				level = level > LUO_MAX and LUO_MAX or level
				if v.index == i and v.star_level == level then
					table.insert(data_list, v)
				end
			end
		end
	end
	return data_list
end
--根据类型和索引获取河神洛书升级数据
function LuoShuData:GetHeShenLuoShuAllUpgradeDataByTypeAndSeq()
	local data_list = {}
	for k,v in ipairs(self.luoshu_upgrade_star) do
		if v.type == self.select_type and v.seq == self.select_seq then
			for i = 0, 15 do
				if v.index == i and self:GetHeShenLuoShuDataByIndex(i) == LUO_MAX and v.star_level == self:GetHeShenLuoShuDataByIndex(i) then
					table.insert(data_list, v)
				end
			end
		end
	end
	return data_list
end

function LuoShuData:GetHeShenLuoShuUpgradeIsOpen()
	local data = self.all_info.data[0]
	if data and next(data) then
		for i = 0, 2 do
			for k, v in pairs(data[i]) do
				if v == 0 then
					return true
				end
			end
		end
	end
	return false
end

function LuoShuData:GetHeShenLuoShuUpgradeIsOpenBySeq(seq)
	local data = self.all_info.data[0]
	if data and next(data) then
		for k, v in pairs(data[seq]) do
			if v == 0 then
				return true
			end
		end
	end
	return false
end

function LuoShuData:GetHeShenLuoShuNextUpgradeData(next_level)
	local cfg = self.heshen_luoshu_cfg_auto.shenhua_add
	local data_list = {}
	for i,v in ipairs(cfg) do
		if v.type == self.select_type and v.seq == self.select_seq then
			table.insert(data_list, v)
		end
	end
	if self:GetHeShenLuoShuUpgradeDataByTypeAndSeq() then
		return 0
	end
	local level = next_level and self:GetHeShenLuoShuUpgradeDataByTypeAndSeq().level + 1 or self:GetHeShenLuoShuUpgradeDataByTypeAndSeq().level
	if level == 0 then
		return 0
	elseif level > #data_list then
		level = #data_list
	end
	for k,v in pairs(data_list) do
		if v.level == level then
			return v.per_add / 10000, v.exp
		end
	end
end
--获取河神洛书单个满级数据
function LuoShuData:GetHeShenLuoShuSingleMaxUpgradeData()
	local data_list = {}
	for i,v in ipairs(self.heshen_luoshu_cfg_auto.shenhua_add) do
		if v.type == self.select_type and v.seq == self.select_seq then
			table.insert(data_list, v)
		end
	end
	return #data_list,data_list
end

-----套装属性
function LuoShuData:GetHeShenLuoShuSuitAttrCfg(suit_num)
	local curr_cfg = nil
	local next_cfg = nil
	local cfg = {}
	for k,v in ipairs(self.heshen_luoshu_cfg_auto.suite_attr) do
		if v.type == self.select_type and v.seq == self.select_seq then
			table.insert(cfg, v)
		end
	end
	for i = #cfg, 1, -1 do
		if cfg[i].suit_num <= suit_num then
			curr_cfg = cfg[i]
			if suit_num ~= cfg[#cfg].suit_num then
				next_cfg = cfg[i + 1]
			else
				next_cfg = nil
			end
			break
		end
		if i == 1 then
			curr_cfg = nil
			next_cfg = cfg[i]
		end
	end
	return curr_cfg, next_cfg
end

function LuoShuData:SetHeShenLuoShuSuitAttrSelectIndex(index)
	self.attr_index = index
end

function LuoShuData:GetHeShenLuoShuSuitAttrSelectIndex()
	return self.attr_index
end
function LuoShuData:SetHeShenLuoShuSuitOpenIndex(child, tree, index)
	self.hsls_child_index = child
	self.hsls_tree_index = tree
	self.hsls_item_index = index
end

function LuoShuData:GetHeShenLuoShuSuitOpenIndex()
	return self.hsls_child_index, self.hsls_tree_index, self.hsls_item_index
end

function LuoShuData:GetHeShenLuoShuRemindItem()
	local item_list = {}
	local list = {}
	for k,v in pairs(self.luoshu_upgrade_star) do
		if item_list[v.item_id] == nil then
			item_list[v.item_id] = v.item_id
			table.insert(list, v.item_id)
		end
	end
	return list
end

function LuoShuData:RemindHeShenLuoShuAll()
	if self:RemindHeShenLuoShuActive() > 0 then
		return 1
	end
	return 0
end 
function LuoShuData:RemindHeShenLuoShuActive()
	local prof = PlayerData.Instance:GetRoleBaseProf()
	local data_list = self:GetAllHeShenLuoShuSuitData()
	for k,v in pairs(data_list) do
		if next(self.all_info.data) then
			local item_count = ItemData.Instance:GetItemNumInBagById(v["item_id_" .. prof]) or 0
			local need_num = 999
			if self.all_info.data[v.type][v.seq][v.index] < 1 then
				need_num = 1
			elseif self.all_info.data[v.type] and self.all_info.data[v.type][v.seq] and self.all_info.data[v.type][v.seq][v.index] 
				and v.star_level == self.all_info.data[v.type][v.seq][v.index] + 1 then
				need_num = v.consume_jinghua
			end
			if item_count >= need_num then
				return 1
			end
		end
	end
	return 0
end

function LuoShuData:RemindHeShenLuoShuUpgrade()
	for k,v in pairs(self.luoshu_upgrade_star) do
		if next(self.all_info.data) and self.all_info.data[v.type][v.seq][v.index] >= 0 then
			local item_count = ItemData.Instance:GetItemNumInBagById(v.item_id)
			local next_need_exp = self:GetUpgradeExp(v.type,v.seq)
			local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
			local item_need_exp_data = self.heshen_luoshu_cfg_auto.item_decompose[item_cfg.color]
			if item_count *item_need_exp_data.obtain_num >= next_need_exp and self.all_info.upgrade_data[v.type][v.seq].level < self.hesh_max_level then
				return 1
			end
		end
	end
	return 0
end

function LuoShuData:RemindHeShenLuoShu(select_seq)
	local prof = PlayerData.Instance:GetRoleBaseProf()
	local data_list = self:GetAllHeShenLuoShuSuitData()
	if not data_list and not next(data_list) then return 0 end
	for k,v in pairs(data_list) do
		if next(self.all_info.data) and v.seq == select_seq and self.all_info.data[v.type][v.seq][v.index] < LUO_MAX then
			local item_count = ItemData.Instance:GetItemNumInBagById(v["item_id_" .. prof]) or 0
			local need_num = 999
			if self.all_info.data[v.type][v.seq][v.index] < 1 then
				need_num = 1
			elseif v.star_level == self.all_info.data[v.type][v.seq][v.index] + 1 then
				need_num = v.consume_jinghua
			end
			if item_count >= need_num then
				return 1
			end
		end
	end
	return 0
end

function LuoShuData:RemindHeShenLuoShuPageRed(select_seq, Page)
	local select_seq = select_seq or self.select_seq
	local prof = PlayerData.Instance:GetRoleBaseProf()
	local Page = Page or 0
	local count1 = BAG_PAGE_COUNT*Page
	local count2 = BAG_PAGE_COUNT*(Page + 1)
	local data_list = self:GetHeShenLuoShuSuitData()
	if not data_list and not next(data_list) then return 0 end
	for k,v in pairs(data_list) do
		if next(self.all_info.data) and v.seq == select_seq and self.all_info.data[v.type][v.seq][v.index] < LUO_MAX and k > count1 and k <= count2 then
			local item_count = ItemData.Instance:GetItemNumInBagById(v["item_id_" .. prof]) or 0
			local need_num = 999
			if self.all_info.data[v.type][v.seq][v.index] < 1 then
				need_num = 1
			elseif v.star_level == self.all_info.data[v.type][v.seq][v.index] then
				need_num = v.consume_jinghua
			end
			if item_count >= need_num then
				return 1
			end
		end
	end
	return 0
end

function LuoShuData:RemindHeShenShenHua(select_seq)
	local prof = PlayerData.Instance:GetRoleBaseProf()
	for k,v in pairs(self.luoshu_upgrade_star) do
		if next(self.all_info.data) and v.seq == select_seq and self.all_info.data[v.type][v.seq][v.index] >= 0 then
			local item_count = ItemData.Instance:GetItemNumInBagById(v[item_id_ .. prof]) or 0
			local next_need_exp = self:GetUpgradeExp(select_type, select_seq)
			local item_cfg = ItemData.Instance:GetItemConfig(v[item_id_ .. prof])
			local item_need_exp_data = self.heshen_luoshu_cfg_auto.item_decompose[item_cfg.color]
			if item_count * item_need_exp_data.obtain_num >= next_need_exp and self.all_info.upgrade_data[v.type][v.seq].level ~= self.hesh_max_level then
				return 1
			end
		end
	end
	return 0
end

--根据类型索引获取升华所需经验
function LuoShuData:GetUpgradeExp(type_s, seq)
	type_s = type_s or 0
	local cur_card_data = self.all_info.upgrade_data[type_s] and self.all_info.upgrade_data[type_s][seq]
	if nil == cur_card_data or nil == next(cur_card_data) then
		return 0
	end
	if cur_card_data.level == 0 then
		for k, v in pairs(self.heshen_luoshu_cfg_auto.shenhua_add) do 
			if v.type == type_s and v.seq == seq and v.level == 1 then
				return self.heshen_luoshu_cfg_auto.shenhua_add[1].exp
			end
		end
	elseif cur_card_data.level < self.hesh_max_level then 
		for i2, v2 in pairs(self.heshen_luoshu_cfg_auto.shenhua_add) do 
			if v2.type == type_s and v2.seq == seq and cur_card_data.level == v2.level then
				return self.heshen_luoshu_cfg_auto.shenhua_add[i2 + 1].exp - cur_card_data.exp
			end
		end
	end
	return 0
end

--洛书天书神化itemcell红点显示
function LuoShuData:HeShenLuoShuShenHuaRemindShow(item_data)
	-- local num = ItemData.Instance:GetItemNumInBagById(item_data.item_id)
	-- local level = nil
	-- if self.all_info.upgrade_data[0] and self.all_info.upgrade_data[0][item_data.seq] then
	-- 	level = self.all_info.upgrade_data[0][item_data.seq].level
	-- end
	-- if level and num ~= 0 and level < self.hesh_max_level then 
	-- 	return true
	-- end
	-- return false
end

--洛书天书itemcell红点显示
function LuoShuData:HeShenLuoShuRemindShow(item_data)
	if nil == item_data or nil == next(item_data) then
		return false
	end
	local prof = PlayerData.Instance:GetRoleBaseProf()
	if not self.luoshu_upgrade_star and not next(self.luoshu_upgrade_star) then return 0 end

	for i ,v in pairs (self.luoshu_upgrade_star) do 
		if v["item_id_" .. prof] == item_data.item_id_prof and v.star_level  == item_data.star_level + 1 and item_data.index == v.index  then 
			local num = ItemData.Instance:GetItemNumInBagById(v["item_id_" .. prof])
			if num ~= 0 and num >= v.consume_jinghua then 
				return true
			end
		end
	end
	return false
end

--获取总战力
function LuoShuData:GetTotalCapability(data_type)
	local level_list = self.all_info.data[0] and self.all_info.data[0][data_type]
	local total_zhanli = 0

	for k1,v1 in pairs(level_list) do 
		if v1 >= 0 then 
			for k2,v2 in pairs(self.luoshu_upgrade_star) do 
				if v2.seq == data_type and v2.star_level == v1 and v2.index == k1 then 
					local attribute = CommonDataManager.GetAttributteByClass(v2)
					local capability = CommonDataManager.GetCapability(attribute)
					total_zhanli = total_zhanli + capability
				end
			end
		end
	end
	return total_zhanli
end
--获取河神洛书卡片满级
function LuoShuData:GetHeShenLuoShuMaxLevel()
	return self.hesh_max_level
end

function LuoShuData:IsLuoShuItem(item_id)
	for i = 0, CUR_MAX_TYPE - 1 do
		for y = 0, INDEX_MAX_TYPE - 1 do
			if self.upgrade_star[i] and self.upgrade_star[i][y] and self.upgrade_star[i][y][1] then
				local upgrade_info = self.upgrade_star[i][y][1]
				if item_id == upgrade_info.item_id_1 or item_id == upgrade_info.item_id_2 or item_id == upgrade_info.item_id_3 or item_id == upgrade_info.item_id_4 then
					return true
				end
			end
		end
	end
	return false
end