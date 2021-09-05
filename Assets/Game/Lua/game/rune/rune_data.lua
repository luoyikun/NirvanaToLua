RuneData = RuneData or BaseClass()
--百分比属性表
RuneData.PercentList = {
	[1] = false,
	[2] = false,
	[3] = false,
	[4] = false,
	[5] = true,
	[6] = false,
	[7] = false,
	[8] = false,
	[9] = true,
	[10] = true,
	[11] = true,
	[12] = true,
	[13] = true,
	[14] = true,
	[15] = true,
	[16] = true,
	[17] = true,
	[18] = true,
	[19] = true,
	[20] = true,
	[21] = false,
}

--防具索引列表
RuneData.FJIndexList = {
	GameEnum.EQUIP_INDEX_TOUKUI,
	GameEnum.EQUIP_INDEX_YIFU,
	GameEnum.EQUIP_INDEX_KUZI,
	GameEnum.EQUIP_INDEX_XIEZI,
	GameEnum.EQUIP_INDEX_HUSHOU,
	GameEnum.EQUIP_INDEX_YAODAI,
}
--首饰索引列表
RuneData.SSIndexList = {
	GameEnum.EQUIP_INDEX_XIANGLIAN,
	GameEnum.EQUIP_INDEX_JIEZHI,
	GameEnum.EQUIP_INDEX_YUPEI,
	GameEnum.EQUIP_INDEX_SHOUZHUO,
}
RuneData.SoltCenter = 1
local MaxNum = 200

function RuneData:__init()
	if RuneData.Instance then
		print_error("[RuneData] Attemp to create a singleton twice !")
	end
	RuneData.Instance = self
	local rune_system_cfg = ConfigManager.Instance:GetAutoConfig("rune_system_cfg_auto") or {}
	self.role_goal_cfg = ConfigManager.Instance:GetAutoConfig("role_big_small_goal_auto") or {}
	self.goal_item_cfg = ListToMap(self.role_goal_cfg.item_cfg, "reward_type", "system_type")
	self.goal_attr_cfg = ListToMap(self.role_goal_cfg.attr_cfg, "system_type")
	self.rune_slot_open_list = rune_system_cfg.rune_slot_open or {}
	self.rune_attr_cfg = ListToMapList(rune_system_cfg.rune_attr, "types", "quality")
	self.real_id_cfg = rune_system_cfg.real_id_list or {}
	self.rune_fetch_cfg = rune_system_cfg.rune_fetch or {}
	self.rune_compose = rune_system_cfg.rune_compose or {}
	self.compose_show = rune_system_cfg.compose_show or {}
	self.other_cfg = rune_system_cfg.other[1] or {}
	self.awaken_type = rune_system_cfg.awaken_type or {}
	self.awaken_limit = rune_system_cfg.awaken_limit or {}
 	self.awaken_item = rune_system_cfg.other or {}
 	self.awaken_cost_cfg = rune_system_cfg.awaken_cost or {}
 	self.fuwen_zhuling_slot_cfg = rune_system_cfg.fuwen_zhuling_slot or {}
 	self.fuwen_zhuling_grade_cfg = ListToMap(rune_system_cfg.fuwen_zhuling, "index", "grade")
 	self.rune_level_open_cfg = rune_system_cfg.rune_level_open					--等级上限

 	self.is_first = 0

	self.bag_list = {}
	self.treasure_list = {}
	self.baoxiang_list = {}
	self.setting_list = {}
	self.pass_layer = 0
	self.rune_jinghua = 0
	self.rune_suipian = 0
	self.old_magic_crystal = 0
	self.magic_crystal = 0
	self.suipian_list = {}
	self.next_free_xunbao_timestamp = 0
	self.rune_slot_open_flag_list = {}
	self.free_xunbao_times = 0
	self.is_need_recalc = 0
	self.awaken_seq = 0
	self.rune_awaken_times = 0

	self.slot_list = {}
	-- self.have_attr_list = {}
	self.have_attr_list_1 = {}
	self.have_attr_list_2 = {}

	self.rune_list = {}
	self.rune_rank_info = {}
	self.num_list = {}
	self:SetRuneList()

	self.baoxiang_id = 0

	self.red_point_list = {
		["Inlay"] = false,
		["Treasure"] = false,
		["Compose"] = false,
	}

	self.zhuling_info = {}
	self.rune_reward_list = {}
	self.tower_rank_info = {}

	RemindManager.Instance:Register(RemindName.RuneInlay, BindTool.Bind(self.CalcInlayRedPoint, self))
	RemindManager.Instance:Register(RemindName.RuneAwake, BindTool.Bind(self.CalcAwakeRedPoint, self))
	RemindManager.Instance:Register(RemindName.RuneAnalyze, BindTool.Bind(self.CalcAnalyzeRedPoint, self))
	RemindManager.Instance:Register(RemindName.RuneTreasure, BindTool.Bind(self.CalcTreasureRedPoint, self))
	RemindManager.Instance:Register(RemindName.RuneCompose, BindTool.Bind(self.CalcComposeRedPoint, self))

	--觉醒用
	self.cell_index = 0

	self.all_goal_info = {}
end

function RuneData:__delete()
	RemindManager.Instance:UnRegister(RemindName.RuneInlay)
	RemindManager.Instance:UnRegister(RemindName.RuneAwake)
	RemindManager.Instance:UnRegister(RemindName.RuneAnalyze)
	RemindManager.Instance:UnRegister(RemindName.RuneTreasure)
	RemindManager.Instance:UnRegister(RemindName.RuneCompose)

	RuneData.Instance = nil
end

function RuneData:GetCommonAwakenItemID()
	if self.awaken_cost_cfg then
		return self.awaken_cost_cfg[1].common_awaken_item.item_id 
	end

	return 0
end

--获取当前符文限制等级
function RuneData:GetRuneLevelLimitInfo(is_next)
	for i = #self.rune_level_open_cfg, 1, -1 do
		if self.rune_level_open_cfg[i].need_rune_tower_layer <= self.pass_layer then
			if is_next then
				return self.rune_level_open_cfg[i+1]
			else
				return self.rune_level_open_cfg[i]
			end
		end
	end
	return nil
end

function RuneData:GetNextNeedPassLayer(level)
	if self.rune_level_open_cfg then
		for k,v in pairs(self.rune_level_open_cfg) do
			if v.rune_level == level then
				if self.rune_level_open_cfg[k + 1] then
					return self.rune_level_open_cfg[k + 1]
				end
			end
		end
	end
end

function RuneData:GetAwakenCostInfo()
	return self.awaken_cost_cfg
end

function RuneData:GetAwakenTypeInfoByIndex(index)
	if nil == self.awaken_type then
		return
	end
	local data = nil
	for k,v in pairs(self.awaken_type) do
		if index == k then
			data = v
		end
	end
	return data
end

function RuneData:GetIsPropertyByIndex(index)
	local data = self:GetAwakenTypeInfoByIndex(index)
	if data then
		return data.is_property
	else
		return 0
	end
end

function RuneData:SetAwakenTypeIndex(index)
	self.awaken_type_index = index
end

function RuneData:GetAwakenTypeIndex()
	return self.awaken_type_index
end


function RuneData:GetAwakenLimitByLevel(level)
	if nil == self.awaken_limit then
		return
	end
	local data = nil
	for k,v in pairs(self.awaken_limit) do
		if v.max_level >= level and v.min_level <= level then
			data = v
			break
		end
	end
	return data
end

function RuneData:GetNextLimitLayer(level)
	for k,v in pairs(self.awaken_limit) do
	 	if level < v.min_level then
	 		return v.min_level or 0
	 	end
	end 
end

function RuneData:SetCellIndex(value)
	if 1 > value then
		value = 1
	end
	self.cell_index = value
end

function RuneData:GetCellIndex()
	return self.cell_index
end

--是否百分比属性
function RuneData:IsPercentAttr(key)
	return RuneData.PercentList[key]
end

--获取对应等级的符文属性
function RuneData:GetAttrInfo(quality, types, level)
	local attr_info = {}
	quality = quality or -1
	types = types or -1
	level = level or 0
	if nil == self.rune_attr_cfg[types] or nil == self.rune_attr_cfg[types][quality] then
		return attr_info
	end
	return self.rune_attr_cfg[types][quality][level] or {}
end

function RuneData:GetOtherCfg()
	return self.other_cfg
end

function RuneData:GetRuneMaxLevel()
	return self.other_cfg.rune_level_max or 0
end

--获取对应的物品id
function RuneData:GetRealId(quality, types)
	local item_id = 0
	quality = quality or -1
	types = types or -1
	for k, v in ipairs(self.real_id_cfg) do
		if quality == v.quality and types == v.type then
			item_id = v.rune_id
			break
		end
	end
	return item_id
end

--获取对应品质和类型
function RuneData:GetQualityTypeByItemId(item_id)
	local quality = -1
	local types = -1
	for k, v in ipairs(self.real_id_cfg) do
		if item_id == v.rune_id then
			quality = v.quality
			types = v.type
			break
		end
	end
	return quality, types
end

--获取对应名字
function RuneData:GetNameByItemId(item_id)
	for k, v in ipairs(self.real_id_cfg) do
		if item_id == v.rune_id then
			return v.fu_name
		end
	end
	return ""
end

--设置其他信息
function RuneData:SetOtherInfo(info)
	if self.is_first == 0 then
		self.is_first = self.is_first + 1
	else
		self.is_first = 2
	end
	self.pass_layer = info.pass_layer                                 	-- 层数
	self.rune_jinghua = info.rune_jinghua								-- 精华
	self.rune_suipian = info.rune_suipian							    -- 碎片
	self.old_magic_crystal = self.magic_crystal 						-- 旧的水晶数量
	self.magic_crystal = info.magic_crystal								-- 水晶
	self.suipian_list = info.suipian_list								-- 寻宝获得碎片
	self.next_free_xunbao_timestamp = info.next_free_xunbao_timestamp	-- 下次免费时间戳
	self.total_xunbao_times = info.total_xunbao_times 					-- 总寻宝次数
	local rune_slot_open_flag = info.rune_slot_open_flag				-- 符文槽开启标记 （0-7）  符文合成开启标记（15）
	self.rune_slot_open_flag_list = bit:d2b(rune_slot_open_flag)
	self.free_xunbao_times = info.free_xunbao_times						-- 免费寻宝次数
	self.rune_awaken_times = info.rune_awaken_times						-- 当前觉醒次数
end

function RuneData:GetAwakenTimes()
	return self.rune_awaken_times
end

function RuneData:GetXunBaoTimes()
	return self.total_xunbao_times or 0
end

--获取下次免费寻宝刷新时间
function RuneData:GetNextFreeXunBaoTimestamp()
	return self.next_free_xunbao_timestamp
end

--获取可免费寻宝的次数
function RuneData:GetFreeTimes()
	return self.free_xunbao_times
end

--获取现有的精华
function RuneData:GetJingHua()
	return self.rune_jinghua
end

--获取现有的魔晶
function RuneData:GetMagicCrystal()
	return self.magic_crystal
end

--获取已通过的层数
function RuneData:GetPassLayer()
	return self.pass_layer or 0
end

--获取现有碎片数量
function RuneData:GetSuiPian()
	return self.rune_suipian
end

function RuneData:SetPlayTreasureAni(state)
	self.is_stop_play_ani = state
end

function RuneData:IsStopPlayAni()
	return self.is_stop_play_ani
end

--根据物品id获取需要通关的层数
function RuneData:GetPassLayerByItemId(item_id)
	local pass_layer = 0
	for k, v in ipairs(self.rune_fetch_cfg) do
		if item_id == v.rune_id then
			pass_layer = v.in_layer_open
			break
		end
	end
	return pass_layer
end

local function AddTbl(data)
	local temp_data = {}
	temp_data.item_id = data.rune_id
	temp_data.in_layer_open = data.in_layer_open
	temp_data.convert_consume_rune_suipian = data.convert_consume_rune_suipian
	temp_data.treasure_show = data.treasure_show
	temp_data.pandect = data.pandect
	table.insert(RuneData.Instance.rune_list, temp_data)
end
--设置可在总览内展示符文列表（根据层数划分，只获取1级的符文）
function RuneData:SetRuneList()
	for k, v in ipairs(self.rune_fetch_cfg) do
		-- if v.pandect > 0 then
		AddTbl(v)
		-- end
	end
	for k, v in ipairs(self.rune_list) do
		local item_id = v.item_id
		local quality, types = self:GetQualityTypeByItemId(item_id)
		local base_data = self:GetAttrInfo(quality, types, 1)
		v.quality = base_data.quality
		v.type = base_data.types
		if v.type == GameEnum.RUNE_WUSHIYIJI_TYPE then
			v.spc_sort = 0
		elseif v.type == GameEnum.RUNE_JINGHUA_TYPE then
			v.spc_sort = 2
		else
			v.spc_sort = 1
		end
		v.level = base_data.level
		v.attr_type_0 = base_data.attr_type_0
		v.add_attributes_0 = base_data.add_attributes_0
		v.attr_type_1 = base_data.attr_type_1
		v.add_attributes_1 = base_data.add_attributes_1
		v.power = base_data.power
		v.dispose_fetch_jinghua = base_data.dispose_fetch_jinghua
	end
	table.sort(self.rune_list, SortTools.KeyLowerSorters("spc_sort", "in_layer_open", "type", "quality"))
end

--根据层数获取已开启的符文列表(层数为空时默认获取全部)
function RuneData:GetRuneListByLayer(layer)
	local temp_list = {}
	local layer_list = {}
	if layer then
		for k, v in ipairs(self.rune_list) do
			if layer >= v.in_layer_open then
				table.insert(temp_list, v)
			end
		end
	else
		temp_list = self.rune_list
	end
	return temp_list
end

--根据物品id获取符文数据(只能获取在符文总览下展示的符文)
function RuneData:GetRuneDataByItemId(item_id)
	local temp_data = {}
	for k, v in ipairs(self.rune_list) do
		if item_id == v.item_id then
			temp_data = v
			break
		end
	end
	return temp_data
end

local function SortExChangeList(a,b)
	local order_a = 100000
	local order_b = 100000

	if a.in_layer_open <= RuneData.Instance:GetPassLayer() then
		order_a = order_a + 200000
	end
	if b.in_layer_open <= RuneData.Instance:GetPassLayer() then
		order_b = order_b + 200000
	end
	if a.in_layer_open > RuneData.Instance:GetPassLayer() and b.in_layer_open > RuneData.Instance:GetPassLayer() then
		if a.in_layer_open < b.in_layer_open then
			order_a = order_a + 100000
		elseif a.in_layer_open > b.in_layer_open then
			order_b = order_b + 100000
		end
	end
	-- if a.power > b.power then
	-- 	order_a = order_a + 15000
	-- elseif a.power < b.power then
	-- 	order_b = order_b + 15000
	-- end
	if a.quality > b.quality then
		order_a = order_a - 100
	elseif a.quality < b.quality then
		order_b = order_b - 100
	end

	if a.type > b.type then
		order_a = order_a + 1000
	elseif a.type < b.type then
		order_b = order_b + 1000
	end
	-- if a.type == GameEnum.RUNE_JINGHUA_TYPE then
	-- 	order_a = 1
	-- elseif b.type == GameEnum.RUNE_JINGHUA_TYPE then
	-- 	order_b = 1
	-- end
	return order_a > order_b
end

--获取兑换列表
function RuneData:GetExchangeList()
	local exchange_list = {}
	for k, v in ipairs(self.rune_list) do
		if v.convert_consume_rune_suipian > 0 then
			table.insert(exchange_list, v)
		end
	end
	table.sort(exchange_list, SortExChangeList )
	-- local time2 = UnityEngine.Time.realtimeSinceStartup * 1000
	-- print_error(time2-time1)
	return exchange_list
end

--改变镶嵌红点
function RuneData:CalcInlayRedPoint()
	if not OpenFunData.Instance:CheckIsHide("rune") then
		return 0
	end

	local goal_info =  self:GetGoalInfo()
	if goal_info ~= nil and goal_info.active_flag ~= nil and goal_info.fetch_flag ~= nil then
		if (goal_info.active_flag[0] == 1 and goal_info.fetch_flag[0] == 0) or (goal_info.fetch_flag[0] == 1 and goal_info.active_flag[1] == 1 and goal_info.fetch_flag[1] == 0) then
			return 1
		end
	end

	local limit_cfg = RuneData.Instance:GetRuneLevelLimitInfo()
	local pass_level = (limit_cfg and next(limit_cfg)) and limit_cfg.rune_level or 0

	local flag = 0
	-- local time1 = UnityEngine.Time.realtimeSinceStartup * 1000
	--先判断是否存在可升级的
	for i = 1, #self.rune_slot_open_list do
		local slot_data = self.slot_list[i]
		if slot_data then
			--判断是否有可升级的格子
			if slot_data.quality >= 0 then
				local uplevel_need_jinghua = slot_data.uplevel_need_jinghua
				local now_level = slot_data.level
				if now_level < self:GetRuneMaxLevel() and uplevel_need_jinghua > 0 and self.rune_jinghua >= uplevel_need_jinghua and now_level < pass_level then
					flag = 1
					break
				end
			end
		end
	end
	--再判断是否存在可替换的符文
	if flag == 0 then
		for k, v in ipairs(self.bag_list) do
			if flag == 1 then
				break
			end
			if v.type ~= GameEnum.RUNE_JINGHUA_TYPE then
				for i = 1, #self.rune_slot_open_list do
					local slot_data = self.slot_list[i]
					if slot_data then
						if slot_data.type == v.type and slot_data.quality < v.quality then
							flag = 1
							break
						end
					end
				end
			end
		end
	end
	if flag == 0 then
		--再判断是否存在可镶嵌的符文
		local is_same = self:GetIsSameRune()
		for k, v in ipairs(self.bag_list) do
			if flag == 1 then
				break
			end
			if not v.is_repeat and v.type == GameEnum.RUNE_WUSHIYIJI_TYPE then
				local slot_data = self.slot_list[1]
				local is_lock = self.rune_slot_open_flag_list[32] == 0
				if slot_data and not is_lock then
					if slot_data.quality == -1 then
						flag = 1
						break
					end
				end
			end
			if not v.is_repeat and v.type ~= GameEnum.RUNE_JINGHUA_TYPE then
				for i = 2, #self.rune_slot_open_list do
					local slot_data = self.slot_list[i]
					local is_lock = self.rune_slot_open_flag_list[32-(i-1)] == 0
					if slot_data and not is_lock and not is_same then
						--判断是否存在未镶嵌的格子
						if slot_data.quality == -1 then
							flag = 1
							break
						end
					end
				end
			end
		end
	end
	return flag
	-- local time2 = UnityEngine.Time.realtimeSinceStartup * 1000
end

function RuneData:GetIsSameRune()
	local is_same = true
	for k, v in ipairs(self.bag_list) do
	-- 判断是否已经镶嵌同类型的符文
		is_same = false
		if not v.is_repeat and v.type ~= GameEnum.RUNE_JINGHUA_TYPE then
			for i = 2, #self.rune_slot_open_list do
				local slot_data = self.slot_list[i]
				if slot_data and slot_data.type == v.type then
					is_same = true
					break 
				end
			end
		end
	end

	return is_same
end

function RuneData:CalcAwakeRedPoint()
	local flag = 0
	-- if not OpenFunData.Instance:CheckIsHide("rune") then
	-- 	return flag
	-- end
	-- local num = ItemData.Instance:GetItemNumInBagById(self:GetCommonAwakenItemID())

	-- local index = self:GetCurrentSelect()
	-- local solt_list = RuneData.Instance:GetSlotList()
	-- local show_red_point = false
	-- if nil == solt_list[index] or 0 == solt_list[index].level then
	-- 	show_red_point = false
	-- else
	-- 	show_red_point = true
	-- end
	-- local pass_layer = RuneData.Instance:GetPassLayer()
	-- local other_cfg = RuneData.Instance:GetOtherCfg()
	-- local need_pass_layer = other_cfg.rune_awake_need_layer
	-- show_red_point = show_red_point and pass_layer >= need_pass_layer

	-- if num > 0 and show_red_point then
	-- 	flag = 1
	-- end

	
	return flag
end

--改变分解红点
function RuneData:CalcAnalyzeRedPoint()
	local flag = 0
	if not OpenFunData.Instance:CheckIsHide("rune") then
		return flag
	end
	--判断是否有符文精华可分解
	for k, v in ipairs(self.bag_list) do
		if v.type == GameEnum.RUNE_JINGHUA_TYPE then
			flag = 1
			break
		end
	end
	return flag
end

--改变寻宝红点
function RuneData:CalcTreasureRedPoint()
	if not OpenFunData.Instance:CheckIsHide("rune") then
		return 0
	end
	local flag = 0
	--先判断是否有免费次数
	if self.free_xunbao_times > 0 then
		flag = 1
	end

	--再判断是否有足够材料可寻宝
	if flag == 0 then
		local need_item_id = self.other_cfg.xunbao_consume_itemid
		local num = ItemData.Instance:GetItemNumInBagById(need_item_id)
		local min_need_num = self.other_cfg.xunbao_one_consume_num
		if num >= min_need_num then
			flag = 1
		end
	end
	return flag
end

--改变合成红点
function RuneData:CalcComposeRedPoint()
	if not OpenFunData.Instance:CheckIsHide("rune") then
		return 0
	end
	local flag = self:GetComposeReminder() and 1 or 0
	return flag
end

--背包物品排序
local function BagSort(a, b)
	if a.type ~= b.type and (a.type == GameEnum.RUNE_JINGHUA_TYPE or b.type == GameEnum.RUNE_JINGHUA_TYPE) then				--符文精华（直接放在最后）
		return not (a.type == GameEnum.RUNE_JINGHUA_TYPE)
	end
	if a.is_repeat == b.is_repeat then
		if a.replace == b.replace then
			if a.quality == b.quality then
				if a.type == b.type then
					return a.level > b.level
				end
				return a.type > b.type
			end
			return a.quality > b.quality
		end
		return a.replace > b.replace
	end
	return not a.is_repeat
end

--设置符文背包
function RuneData:SetBagList(list)
	self.bag_list = {}
	for k, v in ipairs(list) do
		local data = {}
		local quality = v.quality
		local types = v.type
		if quality >= 0 then
			data.index = v.index
			data.quality = quality
			data.type = types
			data.level = v.level
			data.is_repeat = false
			local slot_data = self:GetAttrInfo(data.quality, data.type, data.level)
			if self:IsRepeat(slot_data) then
				data.is_repeat = true
			end
			data.attr_type_0 = slot_data.attr_type_0
			data.add_attributes_0 = slot_data.add_attributes_0
			data.attr_type_1 = slot_data.attr_type_1
			data.add_attributes_1 = slot_data.add_attributes_1
			data.dispose_fetch_jinghua = slot_data.dispose_fetch_jinghua
			local item_id = RuneData.Instance:GetRealId(data.quality, data.type)
			data.item_id = item_id
			data.replace = 0
		end
		if next(data) then
			table.insert(self.bag_list, data)
		end
	end
	table.sort(self.bag_list, BagSort)
	self:ResetBagList()
	self:CollatingNum()
end

--改变背包数据
function RuneData:ChangeBagList(list)
	for k, v in ipairs(list) do
		local quality = v.quality
		local types = v.type
		if quality < 0 then
			--减少物品
			for k1, v1 in ipairs(self.bag_list) do
				if v1.index == v.index then
					table.remove(self.bag_list, k1)
					break
				end
			end
		elseif quality >= 0 then
			--增加物品
			local data = {}
			data.index = v.index
			data.quality = quality
			data.type = types
			data.level = v.level
			data.is_repeat = false
			local slot_data = self:GetAttrInfo(data.quality, data.type, data.level)
			if self:IsRepeat(slot_data) then
				data.is_repeat = true
			end
			data.attr_type_0 = slot_data.attr_type_0
			data.add_attributes_0 = slot_data.add_attributes_0
			data.attr_type_1 = slot_data.attr_type_1
			data.add_attributes_1 = slot_data.add_attributes_1
			data.dispose_fetch_jinghua = slot_data.dispose_fetch_jinghua
			local item_id = RuneData.Instance:GetRealId(data.quality, data.type)
			data.item_id = item_id
			data.replace = 0
			table.insert(self.bag_list, data)
		end
	end
	table.sort(self.bag_list, BagSort)
	self:ResetBagList()
	self:CollatingNum()
end

--获取符文物品数量
function RuneData:GetBagNumByItemId(item_id)
	local num = self.num_list[item_id] or 0
	return num
end

--获取背包剩余数量
function RuneData:GetBagNum()
	local num = 0
	for k, v in pairs(self.num_list) do
		if v > 0 then
			num = num + v
		end
	end
	local count = MaxNum - num
	return count
end

--根据index获取背包符文属性
function RuneData:GetBagDataByIndex(index)
	local data_info = {}
	for k, v in ipairs(self.bag_list) do
		if v.index == index then
			data_info = v
			break
		end
	end
	return data_info
end

--根据item_id获取背包符文index(默认是找到的第一个)
function RuneData:GetBagIndexByItemId(item_id)
	local index = -1
	for k, v in ipairs(self.bag_list) do
		if v.item_id == item_id then
			index = v.index
			break
		end
	end
	return index
end

function RuneData:GetBagList()
	return self.bag_list
end

--获得分解列表
function RuneData:GetAnalyList()
	local analy_list = {}
	for k, v in ipairs(self.bag_list) do
		if v.type == GameEnum.RUNE_JINGHUA_TYPE then
			v.spc_sort = 0
		else
			v.spc_sort = 1
		end
		table.insert(analy_list, v)
	end
	table.sort(analy_list, SortTools.KeyUpperSorters("spc_sort", "quality", "level","type"))
	return analy_list
end

function RuneData:GetTreasureList()
	return self.treasure_list
end

--设置寻宝列表
function RuneData:SetTreasureList(list)
	self.treasure_list = {}
	local count = 0
	for k, v in ipairs(list) do
		count = count + 1
		local data = {}
		local item_id = self:GetRealId(v.quality, v.type)
		data.item_id = item_id
		data.num = 1
		data.is_bind = 1
		if v.type == GameEnum.RUNE_JINGHUA_TYPE then
			data.spc_sort = 0
		else
			data.spc_sort = 1
		end
		data.quality = v.quality
		table.insert(self.treasure_list, data)
	end
	table.sort(self.treasure_list, SortTools.KeyUpperSorters("spc_sort","quality"))
	--添加虚拟碎片物品
	local suipian_count = 0
	for k, v in ipairs(self.suipian_list) do
		suipian_count = suipian_count + v
	end
	local suipian_data = {}
	suipian_data.item_id = ResPath.CurrencyToIconId.rune_suipian
	suipian_data.num = suipian_count
	suipian_data.is_bind = 1
	table.insert(self.treasure_list, suipian_data)

	--添加虚拟水晶物品
	if self.pass_layer < self.other_cfg.rune_compose_need_layer then
		--未达到通关层数不处理
		return
	end
	local mojing_data = {}
	mojing_data.item_id = ResPath.CurrencyToIconId.magic_crystal
	local one_mojing_num = self.other_cfg.xunbao_one_magic_crystal
	mojing_data.num = one_mojing_num * count
	mojing_data.is_bind = 1
	table.insert(self.treasure_list, mojing_data)

end

function RuneData:GetBaoXiangList()
	return self.baoxiang_list
end

--设置宝箱列表
function RuneData:SetBaoXiangList(list)
	self.baoxiang_list = {}
	local count = 0
	for k, v in ipairs(list) do
		count = count + 1
		local data = {}
		local item_id = self:GetRealId(v.quality, v.type)
		data.item_id = item_id
		data.num = 1
		data.is_bind = 1
		table.insert(self.baoxiang_list, data)
	end

	--添加虚拟水晶物品
	if self.old_magic_crystal == self.magic_crystal or self.is_first == 1 then
		--数量没变化不处理
		return
	end
	local mojing_data = {}
	mojing_data.item_id = ResPath.CurrencyToIconId.magic_crystal
	local one_mojing_num = self.other_cfg.xunbao_one_magic_crystal
	mojing_data.num = self.magic_crystal - self.old_magic_crystal
	mojing_data.is_bind = 1
	table.insert(self.baoxiang_list, mojing_data)
end

function RuneData:SetMagic(num)
	if self.is_first == 0 then
		self.is_first = self.is_first + 1
	else
		self.is_first = 2
	end
	self.old_magic_crystal = self.magic_crystal
	self.magic_crystal = self.old_magic_crystal + num
end

--设置已有属性列表
function RuneData:SetHaveAttrList()
	self.have_attr_list_1 = {}
	-- self.have_attr_list_2 = {}
	for k, v in ipairs(self.slot_list) do
		if v then
			if v.type >= 0 and not self.have_attr_list_1[v.type] then
				self.have_attr_list_1[v.type] = v.type
			-- if v.type ~= GameEnum.RUNE_WUSHIYIJI_TYPE then
			-- 	local slot_data = self:GetAttrInfo(v.quality, v.type, v.level)
			-- 	if next(slot_data) then
			-- 		local attr_type_1 = slot_data.attr_type_0
			-- 		if attr_type_1 >= 0 and not self.have_attr_list_1[attr_type_1] then
			-- 			-- self.have_attr_list[attr_type_1] = slot_data.add_attributes_0
			-- 			self.have_attr_list_1[attr_type_1] = slot_data.add_attributes_0
			-- 		end
			-- 		local attr_type_2 = slot_data.attr_type_1
			-- 		if attr_type_2 >= 0 and not self.have_attr_list_2[attr_type_2] then
			-- 			-- self.have_attr_list[attr_type_2] = slot_data.add_attributes_1
			-- 			self.have_attr_list_2[attr_type_2] = slot_data.add_attributes_1
			-- 		end
			-- 	end
			end
		end
	end
	-- print_error("SetHaveAttrList", self.have_attr_list)
end

--刷新背包物品参数(是否有重复的属性, slot_index存在的话直接剔除相关属性)
function RuneData:ResetBagList(slot_index)
	local dis_attr_type_list = {}
	local dis_attr_quality_list = {}
	if slot_index then
		local slot_data = self:GetSlotDataByIndex(slot_index)
		if next(slot_data) then
			-- dis_attr_type_list[slot_data.attr_type_0] = true
			-- if slot_data.attr_type_1 > 0 then
			-- 	dis_attr_type_list[slot_data.attr_type_1] = true
			-- end
			dis_attr_type_list[slot_data.type] = true
			dis_attr_quality_list[slot_data.type] = slot_data.quality
		end
	end
	for k, v in ipairs(self.bag_list) do
		if v.type ~= GameEnum.RUNE_WUSHIYIJI_TYPE then
			if self:IsRepeat(v, dis_attr_type_list) then
				v.is_repeat = true
			else
				v.is_repeat = false
			end
		else
			v.is_repeat = false
		end
		if dis_attr_type_list[v.type] and dis_attr_quality_list[v.type] and v.quality > dis_attr_quality_list[v.type] then
			v.replace = 1
		end
	end
	table.sort(self.bag_list, BagSort)
end

--设置符文槽列表信息
function RuneData:SetSlotList(list)
	self.slot_list = {}
	for k, v in ipairs(list) do
		local data = {}
		if v.quality >= 0 then
			local base_data = self:GetAttrInfo(v.quality, v.type, v.level)
			data.quality = base_data.quality
			data.type = base_data.types
			data.level = base_data.level
			data.uplevel_need_jinghua = base_data.uplevel_need_jinghua
			data.attr_type_0 = base_data.attr_type_0
			data.add_attributes_0 = base_data.add_attributes_0
			data.attr_type_1 = base_data.attr_type_1
			data.add_attributes_1 = base_data.add_attributes_1
			data.power = base_data.power
			data.dispose_fetch_jinghua = base_data.dispose_fetch_jinghua
		else
			data.quality = v.quality
			data.type = v.type
			data.level = v.level
			data.uplevel_need_jinghua = -1
			data.attr_type_0 = -1
			data.add_attributes_0 = -1
			data.attr_type_1 = -1
			data.add_attributes_1 = -1
			data.power = 0
			data.dispose_fetch_jinghua = -1
		end
		table.insert(self.slot_list, data)
	end
	self:SetHaveAttrList()
	self:ResetBagList()
end

function RuneData:GetSlotList()
	return self.slot_list
end

--判断是否有重复属性(dis_attr_type_list为不考虑的属性列表)
function RuneData:IsRepeat(data, dis_attr_type_list)
	local is_repeat = false
	if not data or not next(data) then
		return is_repeat
	end
	dis_attr_type_list = dis_attr_type_list or {}

	-- local attr_type_0 = data.attr_type_0
	-- local attr_type_1 = data.attr_type_1
	-- if dis_attr_type_list[attr_type_0] then
	-- 	attr_type_0 = -1
	-- end
	-- if dis_attr_type_list[attr_type_1] then
	-- 	attr_type_1 = -1
	-- end
	-- if self.have_attr_list[attr_type_0] or self.have_attr_list[attr_type_1] then
	-- 	is_repeat = true
	-- end
	local attr_type = data.type
	if dis_attr_type_list[attr_type] then
		attr_type = -1
	end
	if self.have_attr_list_1[attr_type] then
		is_repeat = true
	end
	return is_repeat
end

function RuneData:GetSlotDataByIndex(index)			-- 1 开始
	return self.slot_list[index] or {}
end

--获取该格子是否锁定
function RuneData:GetIsLockByIndex(index)			-- 1 开始
	local flag = self.rune_slot_open_flag_list[32-(index - 1)] or 0
	return flag == 0
end

function RuneData:GetIsLock(index)
	for i = 1, index do
		local flag = self.rune_slot_open_flag_list[32-(i - 1)] or 0
		if flag == 0 then
			return i
		end
	end
	return nil
end

--获取槽开启的层级
function RuneData:GetSlotOpenLayerByIndex(index)			-- 1 开始
	local layer = 0
	for k, v in ipairs(self.rune_slot_open_list) do
		if v.open_rune_slot == index-1 then
			layer = v.need_pass_layer
			break
		end
	end
	return layer
end

--通过物品ID获取所需材料
function RuneData:GetMaterialByItemId(item_id)
	item_id = item_id or 0
	local tbl = {}
	for k,v in pairs(self.rune_compose) do
		if v.get_rune_id == item_id then
			tbl = v
			break
		end
	end
	return tbl
end

--通过类型获得合成显示配置
function RuneData:GetComposeShowByType(index)
	index = index or 0
	local tbl = {}
	for k,v in pairs(self.compose_show) do
		if v.type == index then
			tbl = v
			break
		end
	end
	return tbl
end

--获得合成显示配置
function RuneData:GetComposeShow()
	return self.compose_show
end

--获得合成红点
function RuneData:GetComposeReminder()
	local flag = false
	if self.pass_layer < self.other_cfg.rune_compose_need_layer then
		return flag
	end
	local magic_crystal_num = self:GetMagicCrystal() or 0
	for k,v in ipairs(self.rune_compose) do
		if v.magic_crystal_num <= magic_crystal_num then
			local has_num1 = self.num_list[v.rune1_id] or 0
			local has_num2 = self.num_list[v.rune2_id] or 0
			if has_num1 > 0 and has_num2 > 0 then
				flag = true
				break
			end
		end
	end

	return flag
end

-- 对符文数量进行排序整理
function RuneData:CollatingNum()
	self.num_list = {}
	for k, v in ipairs(self.bag_list) do
		if nil == self.num_list[v.item_id] then
			self.num_list[v.item_id] = 1
		else
			self.num_list[v.item_id] = self.num_list[v.item_id] + 1
		end
	end
end

--记录符文宝箱最后使用item_id
function RuneData:SetBaoXiangId(item_id)
	self.baoxiang_id = item_id
end

function RuneData:GetBaoXiangId()
	return self.baoxiang_id
end

function RuneData:CalcAttr(attr_info, attr_type, add_attributes)
	if attr_type == "weapon_gongji" or attr_type == "weapon_baoji" then				--武器攻击百分比
		local equip_data = EquipData.Instance:GetGridData(GameEnum.EQUIP_INDEX_WUQI) or {}
		local item_id = equip_data.item_id or 0
		if item_id > 0 then
			local item_cfg = ItemData.Instance:GetItemConfig(item_id)
			if nil ~= item_cfg then
				if attr_type == "weapon_gongji" then
					local gongji = item_cfg.attack or 0
					gongji = gongji * (add_attributes/10000)
					attr_info["gongji"] = attr_info["gongji"] + gongji
				elseif attr_type == "weapon_baoji" then
					local baoji = item_cfg.baoji or 0
					baoji = baoji * (add_attributes/10000)
					attr_info["baoji"] = attr_info["baoji"] + baoji
				end
			end
		end
	elseif attr_type == "armor_hp" or attr_type == "armor_shanbi" or attr_type == "armor_fangyu" or attr_type == "armor_jianren" then					--防具
		for _, v in ipairs(RuneData.FJIndexList) do
			local equip_data = EquipData.Instance:GetGridData(v) or {}
			local item_id = equip_data.item_id or 0
			if item_id > 0 then
				local item_cfg = ItemData.Instance:GetItemConfig(item_id)
				if nil ~= item_cfg then
					if attr_type == "armor_hp" then
						local hp = item_cfg.hp or 0
						hp = hp * (add_attributes/10000)
						attr_info["maxhp"] = attr_info["maxhp"] + hp
					elseif attr_type == "armor_shanbi" then
						local shanbi = item_cfg.shanbi or 0
						shanbi = shanbi * (add_attributes/10000)
						attr_info["shanbi"] = attr_info["shanbi"] + shanbi
					elseif attr_type == "armor_fangyu" then
						local fangyu = item_cfg.fangyu or 0
						fangyu = fangyu * (add_attributes/10000)
						attr_info["fangyu"] = attr_info["fangyu"] + fangyu
					elseif attr_type == "armor_jianren" then
						local jianren = item_cfg.jianren or 0
						jianren = jianren * (add_attributes/10000)
						attr_info["jianren"] = attr_info["jianren"] + jianren
					end
				end
			end
		end
	elseif attr_type == "jewelry_gongji" or attr_type == "jewelry_baoji" then	
		for _, v in ipairs(RuneData.SSIndexList) do
			local equip_data = EquipData.Instance:GetGridData(v) or {}
			local item_id = equip_data.item_id or 0
			if item_id > 0 then
				local item_cfg = ItemData.Instance:GetItemConfig(item_id)
				if nil ~= item_cfg then
					if attr_type == "weapon_gongji" then
						local gongji = item_cfg.attack or 0
						gongji = gongji * (add_attributes/10000)
						attr_info["gongji"] = attr_info["gongji"] + gongji
					elseif attr_type == "weapon_baoji" then
						local baoji = item_cfg.baoji or 0
						baoji = baoji * (add_attributes/10000)
						attr_info["baoji"] = attr_info["baoji"] + baoji
					end
				end
			end
		end
	elseif attr_type == "all_equip_gongji" then
		local temp_gongji = 0
		local equip_tab = EquipData.Instance:GetDataList()
		for k, v in pairs(equip_tab) do
			if v.item_id > 0 then
				local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
				if item_cfg then
					temp_gongji = temp_gongji + item_cfg.attack
				end
			end
		end
		temp_gongji = temp_gongji * (add_attributes/10000)
		attr_info["gongji"] = attr_info["gongji"] + temp_gongji
	else
		if attr_info[attr_type] then
			attr_info[attr_type] = attr_info[attr_type] + add_attributes
		end
	end
end

function RuneData:GetBagHaveRuneGift()
	for i = 23400, 23417 do
		if ItemData.Instance:GetItemNumInBagById(i) > 0 then
			return true
		end
	end
	return false
end

function RuneData:SetAwakenList(list)
	self.awaken_list = list
end

function RuneData:SetAwakenSeq(awaken_seq)
	self.awaken_seq = awaken_seq
end

function RuneData:GetAwakenSeq()
	return self.awaken_seq
end

function RuneData:SetIsNeedRecalc(is_need_recalc)
	self.is_need_recalc = is_need_recalc
end

function RuneData:GetIsNeedRecalc()
	return self.is_need_recalc
end

function RuneData:GetAwakenAttrInfoByIndex(index)
	local awaken_attr_info = nil
	if nil == self.awaken_list then
		return awaken_attr_info
	end
	for k, v in ipairs(self.awaken_list) do
		if k == index then
			awaken_attr_info = v
			break
		end
	end
	return awaken_attr_info
end

function RuneData:SetCurrentSelect(index)
	index = index or 0
	if index == 0 then
		index = 1 
	end
	self.current_select = index 
end

function RuneData:GetCurrentSelect()
	return self.current_select or 1
end

function RuneData:SetRuneRankInfo(rank)
	self.rune_rank_info = TableCopy(rank)
end

function RuneData:GetRuneRankInfo()
	return self.rune_rank_info
end

function RuneData:GetMyRankInfo(role_id)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	for k,v in pairs(self.rune_rank_info) do
		if vo.role_id == v.user_id then
			v.rank = k
			return v
		end
	end

	local pass_layer = GuaJiTaData.Instance:GetRuneTowerInfo().pass_layer
	local my_rank = {}
	my_rank.rank = 999
	my_rank.user_name = vo.name
	my_rank.vip_level = vo.vip_level
	my_rank.rank_value = pass_layer
	my_rank.flexible_int = vo.capability
	return my_rank
end

function RuneData:SetRuneZhulingInfo(protocol)
	self.zhuling_info.zhuling_slot_bless = protocol.zhuling_slot_bless
	self.zhuling_info.run_zhuling_list = protocol.run_zhuling_list
end

function RuneData:SetRuneZhulingSlotBless(zhuling_slot_bless)
	self.zhuling_info.zhuling_slot_bless = zhuling_slot_bless
end

function RuneData:GetRuneZhulingInfo()
	return self.zhuling_info
end

function RuneData:SetRunePassRewardInfo(protocol)
	self.rune_reward_list = protocol.reward_list
	if self.rune_reward_list ~= "" then
		SortTools.SortDesc(self.rune_reward_list, "item_id")
	end
end

function RuneData:GetRunePassRewardInfo()
	return self.rune_reward_list
end

function RuneData:GetRuneZhulingSlotCfg()
	return self.fuwen_zhuling_slot_cfg
end

function RuneData:GetRuneZhulingGradeCfg(index, grade)
	if self.fuwen_zhuling_grade_cfg[index] then
		if self.fuwen_zhuling_grade_cfg[index][grade] then
			return self.fuwen_zhuling_grade_cfg[index][grade]
		elseif grade == nil then
			return self.fuwen_zhuling_grade_cfg[index]
		end
	end
end

function RuneData:GetItemGoalInfo(goal_type, sys_type)
	if self.goal_item_cfg and self.goal_item_cfg[goal_type] and self.goal_item_cfg[goal_type][sys_type] then
		return self.goal_item_cfg[goal_type][sys_type]
	end
end

function RuneData:GetGoalAttr(goal_type)
	if self.goal_attr_cfg and self.goal_attr_cfg[goal_type] then
		return self.goal_attr_cfg[goal_type].add_per
	end
end

function RuneData:GetGoalCfg(goal_type)
	if self.goal_attr_cfg then
		return self.goal_attr_cfg[goal_type]
	end
end

function RuneData:SetGoalInfo(protocol)
	self.goal_info = {}
	self.goal_info.open_system_timestamp = protocol.open_system_timestamp
	self.goal_info.active_flag = protocol.active_flag
	self.goal_info.fetch_flag = protocol.fetch_flag
	self.goal_info.active_special_attr_flag = protocol.active_special_attr_flag
end

function RuneData:GetGoalInfo()
	return self.goal_info
end

function RuneData:SetAllGoalInfo(protocol)
	if protocol.system_type then
		local temp_data = {}
		temp_data.system_type = protocol.system_type
		temp_data.open_system_timestamp = protocol.open_system_timestamp
		temp_data.active_flag = protocol.active_flag
		temp_data.fetch_flag = protocol.fetch_flag
		temp_data.active_special_attr_flag = protocol.active_special_attr_flag
		self.all_goal_info[protocol.system_type] = {}
		self.all_goal_info[protocol.system_type] = temp_data
	end
end

function RuneData:GetGoalInfoInAll(system_type)
	return self.all_goal_info[system_type]
end

-- 是否大小目标的物品
function RuneData:IsRolrGoalItem(item_id)
	for k, v in pairs(self.role_goal_cfg.item_cfg) do
		if v.reward_type == 1 and v.reward_item[0].item_id == item_id then
			return v
		end
	end
	return false
end

-- 相关系统是否显示大小目标奖励图标
function RuneData:IsShowJGoalRewardIcon(target_type, system_type)
	local is_show_icon = false
	if nil == system_type then
		return is_show_icon
	end

	local cur_open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local cur_level = PlayerData.Instance:GetRoleLevel()
	local reward_type_cfg = self:GetItemGoalInfo(target_type, system_type)
	if reward_type_cfg then
		if cur_level >= reward_type_cfg.open_level and cur_open_server_day >= reward_type_cfg.openserver_day then
			is_show_icon = true
		end
	end
	return is_show_icon
end

function RuneData:GetGoalData(cfg)
	if nil == cfg then return end

	local data = {}
	data.item_id = cfg.reward_item[0].item_id
	data.cost = cfg.cost
	local goal_info = self:GetGoalInfoInAll(cfg.system_type)
	if not goal_info then return end

	data.can_fetch = goal_info.active_flag[1] == 1
	data.left_time = goal_info.open_system_timestamp - TimeCtrl.Instance:GetServerTime() + cfg.free_time_since_open * 3600
	return data
end

-- 获取全身属性
function RuneData:GetAllBaseAttr()
	local slot_list = self:GetSlotList()
	local attr_info = CommonStruct.AttributeNoUnderline()
	for k, v in ipairs(self.slot_list) do
		local attr_type_1 = Language.Rune.AttrType[v.attr_type_0]
		local attr_type_2 = Language.Rune.AttrType[v.attr_type_1]

		if attr_type_1 then
			self:CalcAttr(attr_info, attr_type_1, v.add_attributes_0)
		end
		if attr_type_2 then
			self:CalcAttr(attr_info, attr_type_2, v.add_attributes_1)
		end
	end
	return attr_info
end