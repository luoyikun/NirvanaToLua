DouQiData = DouQiData or BaseClass()

function DouQiData:__init()
	if DouQiData.Instance ~= nil then
		ErrorLog("[DouQiData] Attemp to create a singleton twice !")
	end

	DouQiData.Instance = self

	self.douqi_cfg = ConfigManager.Instance:GetAutoConfig("cross_equip_auto")

	self.douqi_grade_cfg = ListToMap(self.douqi_cfg.douqi_grade, "douqi_grade")
	self.equip_info_cfg = ListToMap(self.douqi_cfg.equip_info, "equip_id")
	self.equip_info_refine_cfg = ListToMap(self.douqi_cfg.equip_info, "order", "equip_index", "allow")
	self.suit_attr_cfg = ListToMapList(self.douqi_cfg.suit_attr, "order")
	self.equip_info_suit_cfg = ListToMap(self.douqi_cfg.equip_info, "order", "equip_index", "color")

	self.client_suit_attr_cfg = ListToMapList(self.douqi_cfg.client_suit_attr, "order")

	self.recovery_tab = {}
	self.recovery_index_tab = {}
	self.suit_data = {}

	RemindManager.Instance:Register(RemindName.DouqiGrade, BindTool.Bind(self.GetDouqiGradeRemind, self))
	RemindManager.Instance:Register(RemindName.DouqiEquip, BindTool.Bind(self.GetDouqiEquipRemind, self))
	RemindManager.Instance:Register(RemindName.DouqiRefine, BindTool.Bind(self.GetDouqiRefineRemind, self))
end

function DouQiData:__delete()
	RemindManager.Instance:UnRegister(RemindName.DouqiGrade)
	RemindManager.Instance:UnRegister(RemindName.DouqiEquip)
	RemindManager.Instance:UnRegister(RemindName.DouqiRefine)
	DouQiData.Instance = nil
end



-- 信息下发
function DouQiData:SetSCCrossEquipAllInfo(protocol)
	-- print_error(protocol)
	self.douqi_info = protocol
end

function DouQiData:GetSCCrossEquipAllInfo()
	return self.douqi_info
end

-- 抽奖返回
function DouQiData:SetSCCrossEquipRollResult(protocol)
	
end

-- 传世碎片改变 右下角显示
function DouQiData:SetSCCrossEquipChuanshiFragmentChange(protocol)
	
end

-- 斗气经验改变 右下角显示
function DouQiData:SetSCCrossEquipDouqiExpChange(protocol)
	
end

function DouQiData:IsDouqiEqupi(equip_id)
	return self.equip_info_cfg[equip_id] and true or false
end

function DouQiData:GetDouqiEquipCfg(equip_id)
	return self.equip_info_cfg[equip_id]
end

---------------------------------------
----------------阶段
function DouQiData:GetDouqiGradeCfg(grade)
	return self.douqi_grade_cfg[grade]
end

function DouQiData:GetDouqiMaxGrade()
	local cfg = self.douqi_cfg.douqi_grade
	return cfg[#cfg].douqi_grade
end

function DouQiData:GetUseItemList()
	local cfg = self.douqi_cfg.other
	local cfg2 = self.douqi_cfg.douqidan
	local list = {}
	for k, v in pairs(cfg) do
		for k2, v2 in pairs(cfg2) do
			if v.show_id == v2.douqidan_type + 1 then
				local temp_tab = {}
				temp_tab.douqidan_type = v2.douqidan_type
				temp_tab.reward_exp = v2.reward_exp
				temp_tab.day_used_limit = v2.day_used_limit
				temp_tab.item_id = v.item_id
				temp_tab.price = v.price
				temp_tab.go_to = v.go_to
				temp_tab.get_way = v.get_way
				temp_tab.had_use_times = self.douqi_info and self.douqi_info.douqidan_used_count[v.show_id] or 0
				table.insert(list, temp_tab)
			end
		end
	end

	return list
end

function DouQiData:GetDouqiGradeRemind()
	if not OpenFunData.Instance:CheckIsHide("douqi_view") then
		return 0
	end

	if self.douqi_info then
		if self:GetDouqiMaxGrade() == self.douqi_info.douqi_grade then
			return 0
		end

		local cur_douqi_cfg = self:GetDouqiGradeCfg(self.douqi_info.douqi_grade)
		if cur_douqi_cfg and self.douqi_info.douqi_exp >= cur_douqi_cfg.need_exp then
			return 1
		end

		local item_datas = self:GetUseItemList() or {}
		for k, v in pairs(item_datas) do
			local have_item = ItemData.Instance:GetItemNumInBagById(v.item_id)
			if 9999 <= v.day_used_limit and have_item > 0 then
				return 1
			else
				if v.had_use_times < v.day_used_limit and have_item > 0 then
					return 1
				end
			end
		end
	end
	return 0
end

---------------------------------------
----------------装备
-- 单个装备信息 -- 穿脱
function DouQiData:SetSCCrossEquipOneEquip(protocol)
	if self.equip_data then
		self.equip_data[protocol.index] = {}
		self.equip_data[protocol.index] = protocol.equipment
	end
	self:FlushSuitData()
end

-- 所有装备信息
function DouQiData:SetSCCrossEquipAllEquip(protocol)
	self.equip_data = protocol.equipment_list
	self:FlushSuitData()
end

function DouQiData:GetDouqiEquipByIndex(index)
	return self.equip_data and self.equip_data[index] or {}
end

function DouQiData:GetDouqiEquipInBag()
	local bag_items = ItemData.Instance:GetBagItemDataList()
	local douqi_items = {}

	for k, v in pairs(bag_items) do
		if self.equip_info_cfg[v.item_id] then
			table.insert(douqi_items, v)
		end
	end
	return douqi_items
end

function DouQiData:AddRecoveryTab(equip_data)
	self.recovery_index_tab[equip_data.index] = true
	table.insert(self.recovery_tab, equip_data)
end

function DouQiData:ClearRecoveryTab()
	self.recovery_index_tab = {}
	self.recovery_tab = {}
end

function DouQiData:RemoveRecoveryTab(equip_data)
	self.recovery_index_tab[equip_data.index] = nil
	for k, v in pairs(self.recovery_tab) do
		if v.index == equip_data.index then
			table.remove(self.recovery_tab, k)
			break
		end
	end
end

function DouQiData:GetRecoveryDataTab()
	return self.recovery_tab
end

function DouQiData:IsInRecoveryTab(bag_index)
	return self.recovery_index_tab[bag_index]
end

function DouQiData:SetRecoveryDataList()
	self.recovery_index_tab = {}
	self.recovery_tab = {}

	if not self.douqi_equip_list then
		self:InitRecoveryList()
	end

	local bag_items = ItemData.Instance:GetBagItemDataList()
	for k, v in pairs(bag_items) do
		if self:IsDouqiEqupi(v.item_id) then
			local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
			if item_cfg then
				local is_add = false
				if ((2 >= item_cfg.color and 1 == self:GetDouqiRecoveryFlag(1)) or (3 == item_cfg.color and 1 == self:GetDouqiRecoveryFlag(2)) or 
					(4 == item_cfg.color and 1 == self:GetDouqiRecoveryFlag(3))) and not EquipData.Instance:CheckIsAutoEquip(v.item_id, v.index) then
					is_add = true
				end
				if is_add then
					self.recovery_index_tab[v.index] = true
					table.insert(self.recovery_tab, v)
				end
			end
		end
	end
end

function DouQiData:SetIsOpenRecoveryView(is_open)
	self.is_open_recovery_view = is_open
end

function DouQiData:GetIsOpenRecoveryView()
	return self.is_open_recovery_view
end

function DouQiData:GetDouqiEquipRemind()
	if not OpenFunData.Instance:CheckIsHide("douqi_view") then
		return 0
	end

	local bag_items = ItemData.Instance:GetBagItemDataList()
	local douqi_info = self:GetSCCrossEquipAllInfo()
	local douqi_grade = douqi_info and douqi_info.douqi_grade or 10
	local temp_equip_power = {}
	for k, v in pairs(bag_items) do
		if self:IsDouqiEqupi(v.item_id) then
			local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
			if item_cfg then
				local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type) + 1
				local douqi_equip_cfg = self:GetDouqiEquipCfg(v.item_id)
				if douqi_equip_cfg and douqi_grade >= douqi_equip_cfg.order then
					local equip = self:GetDouqiEquipByIndex(equip_index)
					if equip and equip.item_id and equip.item_id <= 0 then
						return 1
					else
						if not temp_equip_power[equip_index] then
							temp_equip_power[equip_index] = EquipData.Instance:GetEquipCapacityPower(equip)
						end
						local cur_power = temp_equip_power[equip_index]
						local temp_power = EquipData.Instance:GetEquipCapacityPower(v)
						if cur_power < temp_power then
							return 1
						end
					end
				end
			end
		end
	end
	return 0
end

--------套装

function DouQiData:GetSuitTypeList()
	local cfg = self.douqi_cfg.douqi_grade
	local suit_type_list = {}
	for k, v in pairs(cfg) do
		if v.douqi_grade > 0 then
			table.insert(suit_type_list, v)
		end
	end
	table.sort(suit_type_list, function (a, b)
		return a.douqi_grade > b.douqi_grade
	end)
	return suit_type_list
end

function DouQiData:GetSuitEquip(order, equip_index, color)
	local cfg = self.equip_info_suit_cfg[order]
	return cfg[equip_index] and cfg[equip_index][color]
end

function DouQiData:GetDouqiEquipSuitAttr(equip_order)
	return self.suit_attr_cfg[equip_order]
end

function DouQiData:GetDouqiEquipClientSuitAttr(equip_order)
	return self.client_suit_attr_cfg[equip_order]
end

function DouQiData:GetDouqiEquipSuitAttrCfg(equip_order, suit_type)
	local cfg = self.suit_attr_cfg[equip_order]
	for k, v in pairs(cfg) do
		if v.need_count == suit_type then
			return v
		end
	end
	return nil
end

function DouQiData:GetDouqiEquipClientSuitAttrCfg(equip_order, suit_type)
	local cfg = self.client_suit_attr_cfg[equip_order]
	for k, v in pairs(cfg) do
		if v.need_count == suit_type then
			return v
		end
	end
	return nil
end

function DouQiData:FlushSuitData()
	local wear_equip_order_tab = {}
	local equip_count = 0
	for k, v in pairs(self.equip_data) do
		if v.item_id > 0 then
			local equip_cfg = self:GetDouqiEquipCfg(v.item_id)
			if equip_cfg and equip_cfg.color == 5 then
				if not wear_equip_order_tab[equip_cfg.order] then
					wear_equip_order_tab[equip_cfg.order] = {}
				end
				table.insert(wear_equip_order_tab[equip_cfg.order], k)
				equip_count = equip_count + 1
			end
		end
	end

	local suit_data = {}
	local suit_type_list = self:GetSuitTypeList()
	local last_equip_number = 0
	for k, v in pairs(suit_type_list) do
		if wear_equip_order_tab[v.douqi_grade] then

			local suit_cfg = self:GetDouqiEquipSuitAttr(v.douqi_grade)
			local suit_type_num = #wear_equip_order_tab[v.douqi_grade]
			local suit_num = 0
			for i = #suit_cfg, 1, -1 do
				if (suit_type_num + last_equip_number) >= suit_cfg[i].need_count then
					suit_num = suit_cfg[i].need_count
					for k2, v2 in pairs(wear_equip_order_tab[v.douqi_grade]) do
						local temp_tab = {suit_order = v.douqi_grade, suit_type = suit_cfg[i].need_count} 	--douqi_grade 多少阶套 suit_type 多少件套
						suit_data[v2] = temp_tab
					end
					break
				end
			end
			last_equip_number = last_equip_number + suit_type_num - suit_num 	-- 上次凑剩多少件（高阶能凑低阶）
		end
	end
	self.suit_data = suit_data
end

function DouQiData:GetSuitAllAttr()
	return self.suit_data
end

function DouQiData:GetSuitDataBtIndex(equip_index)
	return self.suit_data[equip_index]
end

---------------------------------------
----------------炼制
function DouQiData:GetEquipRefineCfg(douqi_grade, equip_index, is_allow)
	local cfg = self.equip_info_refine_cfg[douqi_grade]
	return cfg[equip_index] and cfg[equip_index][is_allow]
end

function DouQiData:GetDouqiRefineRemind()
	if not OpenFunData.Instance:CheckIsHide("douqi_view") then
		return 0
	end
end

--------------------------------
-- 保存toggle设置属性
function DouQiData:InitRecoveryList()
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if not PlayerPrefsUtil.HasKey("douqi" .. role_id) then
		PlayerPrefsUtil.SetInt("douqi" .. role_id, 0)
	end

	local value = PlayerPrefsUtil.GetInt("douqi" .. role_id)
	self.douqi_equip_list = bit:d2b(value)
end

function DouQiData:SetDouqiRecoveryFlag(index, flag)
	if not self.douqi_equip_list then
		self:InitRecoveryList()
	end

	index = index - 1
	self.douqi_equip_list[32 - index] = flag
	value = bit:b2d(self.douqi_equip_list)
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	PlayerPrefsUtil.SetInt("douqi" .. role_id, value)
end

function DouQiData:GetDouqiRecoveryFlag(index)
	if not self.douqi_equip_list then
		self:InitRecoveryList()
	end

	index = index - 1
	local value = self.douqi_equip_list[32 - index]
	return value or 0
end

function DouQiData:GetDouqiRecoveryTab()
	if not self.douqi_equip_list then
		self:InitRecoveryList()
	end

	return self.douqi_equip_list or nil
end




