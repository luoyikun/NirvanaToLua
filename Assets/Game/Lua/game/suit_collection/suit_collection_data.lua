SuitCollectionData = SuitCollectionData or BaseClass()

function SuitCollectionData:__init()
	if SuitCollectionData.Instance ~= nil then
		print_error("[SuitCollectionData] attempt to create singleton twice!")
		return
	end
	SuitCollectionData.Instance = self

	self.suit_auto_cfg = ConfigManager.Instance:GetAutoConfig("shenbing_tulu_config_auto")
	-- 橙装
	self.orange_suit_type_cfg = ListToMap(self.suit_auto_cfg.orange_equip_collect_other, "seq")
	self.orange_collect_attr_cfg = ListToMapList(self.suit_auto_cfg.orange_equip_collect_attr, "seq")
	self.orange_equip_collect_cfg = ListToMap(self.suit_auto_cfg.orange_equip_collect, "seq", "prof")

	-- 红装
	self.red_suit_type_cfg = ListToMap(self.suit_auto_cfg.red_equip_collect_other, "prof", "seq")
	self.red_collect_attr_cfg = ListToMapList(self.suit_auto_cfg.red_equip_collect_attr, "seq")
	self.red_equip_collect_cfg = ListToMap(self.suit_auto_cfg.red_equip_collect, "seq", "prof")



	self.orange_equip_list = {}
	self.orange_active_flag = {}
	self.orange_act_reward_can_fetch_flag = {}
	self.orange_active_reward_flag = {}
	self.orange_stars_info = {}
	self.red_equip_list = {}
	self.red_active_flag = {}
	self.red_act_reward_can_fetch_flag = {}
	self.red_active_reward_flag = {}
	self.red_stars_info = {}

	RemindManager.Instance:Register(RemindName.OrangeSuitCollection, BindTool.Bind(self.GetOrangeSuitCollectionRemind, self))
	RemindManager.Instance:Register(RemindName.RedSuitCollection, BindTool.Bind(self.GetRedSuitCollectionRemind, self))
end

function SuitCollectionData:__delete()
	RemindManager.Instance:UnRegister(RemindName.OrangeSuitCollection)
	RemindManager.Instance:UnRegister(RemindName.RedSuitCollection)

	self.orange_is_remind = nil
	self.red_is_remind = nil
	
	SuitCollectionData.Instance = nil
end

-----------------------
-- 共用
function SuitCollectionData:GetUITweenCfg(panel_tab_index)
	local tween_cfg = {
		[TabIndex.orange_suit_collect] = {["ListPanel"] = Vector3(-130, -30, 0), ["RightPanel"] = Vector3(850, -30, 0), ["MoveTime"] = 0.5},
		[TabIndex.red_suit_collect] = {["ListPanel"] = Vector3(-130, -30, 0), ["RightPanel"] = Vector3(850, -30, 0), ["MoveTime"] = 0.5},
	}

	return tween_cfg[panel_tab_index]
end

function SuitCollectionData:GetEquipByItemId(equip_id)
	local bag_list = ItemData.Instance:GetBagItemDataList()
	local item_tab = {}
	local count = 1
	for k, v in pairs(bag_list) do
		if equip_id == v.item_id then
			item_tab[count] = v
			count = count + 1
		end
	end
	return item_tab
end

------------------------
-- 橙装
function SuitCollectionData:SetOrangeEquipCollect(protocol)
	self.orange_equip_list[protocol.seq] = protocol.equip_slot
end

function SuitCollectionData:SetOrangeEquipCollectOther(protocol)
	self.orange_active_flag = bit:d2b(protocol.seq_active_flag)
	self.orange_collect_count = protocol.collect_count
	self.orange_act_reward_can_fetch_flag = bit:d2b(protocol.act_reward_can_fetch_flag)
	self.orange_active_reward_flag = bit:d2b(protocol.active_reward_flag)
	self.orange_stars_info = protocol.stars_info
end

-- 橙装装备
function SuitCollectionData:GetOrangeEquipCollect(seq)
	return self.orange_equip_list[seq]
end

function SuitCollectionData:GetOrangeStarsInfo(seq)
	return self.orange_stars_info[seq]
end

-- 橙装套装类型数量
function SuitCollectionData:GetOrangeItemNum()
	local level = GameVoManager.Instance:GetMainRoleVo().level
	local num_tab = {}
	count = 1
	for k, v in pairs(self.orange_suit_type_cfg) do
		if level < v.active_role_level then
			-- num_tab[count] = v
			-- count = count + 1
			break
		end
		num_tab[count] = v
		count = count + 1
	end

	return num_tab
end

function SuitCollectionData:GetOrangeItemType(seq)
	return self.orange_suit_type_cfg[seq]
end

-- 橙装属性
function SuitCollectionData:GetOrangeCollectAttr(seq)
	return self.orange_collect_attr_cfg[seq]
end

-- 获得橙装装备回收的装备ID
function SuitCollectionData:GetOrangeCollectEquipCfg(seq)
	if self.orange_equip_collect_cfg[seq] then
		local prof = PlayerData.Instance:GetRoleBaseProf()
		return self.orange_equip_collect_cfg[seq][prof]
	end
end

function SuitCollectionData:SetOrangeRemindFlag()
	self.orange_is_remind = true
end

-- 橙装红点
function SuitCollectionData:GetOrangeSuitCollectionRemind()
	-- if self.orange_is_remind then return 0 end

	local level = GameVoManager.Instance:GetMainRoleVo().level
	local collect_type_tab = self:GetOrangeItemNum()
	for k, v in pairs(collect_type_tab) do
		if v.active_role_level <= level then
			if self:GetOrangeRemindBySeq(v.seq) then
				return 1
			end
		end
	end
	return 0
end

-- 橙装红点2
function SuitCollectionData:GetOrangeRemindBySeq(seq)
	local equip_list = self:GetOrangeEquipCollect(seq)
	local equip_collect_cfg = self:GetOrangeCollectEquipCfg(seq)
	local star_info = self:GetOrangeStarsInfo(seq)
	local active_equip_num = star_info and star_info.item_count or 0
	if equip_list and equip_collect_cfg and active_equip_num < 10 then 
		local equip_id_tab = Split(equip_collect_cfg.equip_items, "|")
		for k, v in pairs(equip_id_tab) do
			if equip_list[k - 1] and equip_list[k - 1].item_id <= 0 then
				local equip_id = tonumber(v)
				local item_cfg = ItemData.Instance:GetItemConfig(equip_id)
				if item_cfg and EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type) then
					local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
					local wear_equip = ForgeData.Instance:GetZhuanzhiEquip(equip_index)
					if wear_equip and wear_equip.item_id > 0 then
						local bag_list = ItemData.Instance:GetBagItemDataList()
						for k2, v2 in pairs(bag_list) do
							if v2.item_id == equip_id then
								local bag_equip_cap = EquipData.Instance:GetEquipCapacityPower(v2)
								local wear_equip_cap = EquipData.Instance:GetEquipCapacityPower(wear_equip)
								if bag_equip_cap <= wear_equip_cap then
									return true
								end
							end
						end
					end
				end				
			end
		end
	end
	return false
end



------------------------
-- 红装

function SuitCollectionData:SetRedEquipCollect(protocol)
	self.red_equip_list[protocol.seq] = protocol.equip_slot
end

function SuitCollectionData:SetRedEquipCollectOther(protocol)
	self.red_active_flag = bit:d2b(protocol.seq_active_flag)
	self.red_collect_count = protocol.collect_count
	self.red_act_reward_can_fetch_flag = bit:d2b(protocol.act_reward_can_fetch_flag)
	self.red_active_reward_flag = bit:d2b(protocol.active_reward_flag)
	self.red_stars_info = protocol.stars_info
	-- self:SetActiveMax()
end

function SuitCollectionData:GetRedEquipCollect(seq)
	return self.red_equip_list[seq]
end

function SuitCollectionData:GetRedStarsInfo(seq)
	return self.red_stars_info[seq]
end

-- 激活套装个数
function SuitCollectionData:GetRedActiveSuitCount()
	return self.suit_auto_cfg.other[1].red_equip_collect_active_puton_count
end

-- 红装套装类型数量
function SuitCollectionData:GetRedItemNum()
	local level = GameVoManager.Instance:GetMainRoleVo().level
	local prof = PlayerData.Instance:GetRoleBaseProf()
	local red_type_cfg = self.red_suit_type_cfg[prof]

	local num_tab = {}
	count = 1
	for k, v in pairs(red_type_cfg) do
		if level < v.level then
			-- num_tab[count] = v
			-- count = count + 1
			break
		end
		num_tab[count] = v
		count = count + 1
	end

	return num_tab
end

function SuitCollectionData:GetRedItemType(seq)
	local prof = PlayerData.Instance:GetRoleBaseProf()
	local red_type_cfg = self.red_suit_type_cfg[prof]
	return red_type_cfg[seq]
end

-- 红装属性
function SuitCollectionData:GetRedCollectAttr(seq)
	return self.red_collect_attr_cfg[seq]
end

-- 获得橙装装备回收的装备ID
function SuitCollectionData:GetRedCollectEquipCfg(seq)
	if self.red_equip_collect_cfg[seq] then
		local prof = PlayerData.Instance:GetRoleBaseProf()
		return self.red_equip_collect_cfg[seq][prof]
	end
end

-- 获取是否激活套装
function SuitCollectionData:GetRedIsActive(seq)
	return self.red_active_reward_flag[32 - seq]
end

function SuitCollectionData:SetRedRemindFlag()
	self.red_is_remind = true
end

-- 红装红点
function SuitCollectionData:GetRedSuitCollectionRemind()
	-- if self.red_is_remind then return 0 end

	local level = GameVoManager.Instance:GetMainRoleVo().level
	local collect_type_tab = self:GetRedItemNum()
	for k, v in pairs(collect_type_tab) do
		if v.level <= level then
			if self:GetRedRemindBySeq(v.seq) then
				return 1
			end
		end
	end
	return 0
end

-- 红装红点2
function SuitCollectionData:GetRedRemindBySeq(seq)
	local equip_list = self:GetRedEquipCollect(seq)
	local equip_collect_cfg = self:GetRedCollectEquipCfg(seq)
	local star_info = self:GetRedStarsInfo(seq)
	local active_equip_num = star_info and star_info.item_count or 0
	if equip_list and equip_collect_cfg and active_equip_num < 10 then
		local equip_id_tab = Split(equip_collect_cfg.equip_items, "|")
		for k, v in pairs(equip_id_tab) do
			local equip_id = tonumber(v)
			local item_cfg = ItemData.Instance:GetItemConfig(equip_id)
			if item_cfg and EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type) then
				local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
				local wear_equip = ForgeData.Instance:GetZhuanzhiEquip(equip_index)
				if wear_equip and wear_equip.item_id > 0 then
					local wear_item_cfg = ItemData.Instance:GetItemConfig(wear_equip.item_id)
					if equip_list[k - 1] and equip_list[k - 1].item_id then
						local bag_list = ItemData.Instance:GetBagItemDataList()

						if equip_list[k - 1].item_id <= 0 then --判断可装备
							for k2, v2 in pairs(bag_list) do
								if equip_id == v2.item_id then
									local bag_equip_cap = EquipData.Instance:GetEquipCapacityPower(v2)
									local wear_equip_cap = EquipData.Instance:GetEquipCapacityPower(wear_equip)									
									if bag_equip_cap <= wear_equip_cap then
										return true
									end
								end
							end
						else 									-- 判断可替换
							for k2, v2 in pairs(bag_list) do
								if equip_id == v2.item_id then
									if v2.param and wear_equip.param and equip_list[k - 1].param and
										#v2.param.xianpin_type_list <= #wear_equip.param.xianpin_type_list and
										#equip_list[k - 1].param.xianpin_type_list < #v2.param.xianpin_type_list then --星数小于等于穿的，大于当前收集的
										return true
									end
								end
							end
						end
					end
				end
			end
		end
	end
	return false
end


