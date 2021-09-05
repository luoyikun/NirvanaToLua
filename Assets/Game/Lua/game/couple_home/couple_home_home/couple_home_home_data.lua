CoupleHomeHomeData = CoupleHomeHomeData or BaseClass()

function CoupleHomeHomeData:__init()
	if CoupleHomeHomeData.Instance then
		print_error("[CoupleHomeHomeData] Attempt to create singleton twice!")
		return
	end

	local spouse_home_cfg = ConfigManager.Instance:GetAutoConfig("spouse_home_cfg_auto")
	self.buy_special_theme_cfg = spouse_home_cfg.buy_special_theme
	self.special_theme_type_cfg = ListToMap(spouse_home_cfg.buy_special_theme, "theme_type")
	self.furniture_base_attr_slot_cfg = ListToMapList(spouse_home_cfg.furniture_base_attr, "imprint_slot")
	self.furniture_base_attr_item_cfg = ListToMapList(spouse_home_cfg.furniture_base_attr, "item_id")
	self.theme_attr_cfg = ListToMap(spouse_home_cfg.room_attr, "theme_type")

	self.furniture_pos_cfg = ListToMap(spouse_home_cfg.furniture_pos, "item_id")

	self.house_uid = 0						--当前房子的主人role_id
	self.pet_id = -1						--当前房子的小宠物id
	self.max_furniture_count = 0			--当前家具最大数量

	CoupleHomeHomeData.Instance = self
end

function CoupleHomeHomeData:__delete()
	CoupleHomeHomeData.Instance = nil
end

function CoupleHomeHomeData:SetHouseUid(uid)
	self.house_uid = uid
end

function CoupleHomeHomeData:GetHouseUid()
	return self.house_uid
end

function CoupleHomeHomeData:SetPetId(pet_id)
	self.pet_id = pet_id
end

function CoupleHomeHomeData:GetPetId()
	return self.pet_id
end

function CoupleHomeHomeData:SetMaxFurnitureCount(max_furniture_count)
	self.max_furniture_count = max_furniture_count
end

function CoupleHomeHomeData:GetMaxFurnitureCount()
	return self.max_furniture_count
end

function CoupleHomeHomeData:SetHouseList(list)
	self.house_list = list
end

function CoupleHomeHomeData:GetHouseList()
	return self.house_list
end

--刷新当前房子列表数据
function CoupleHomeHomeData:UpdateHouseList(house_info)
	if self.house_list == nil then
		self.house_list = {}
		table.insert(self.house_list, house_info)
		return
	end

	local is_change = false
	for k, v in ipairs(self.house_list) do
		if v.house_index == house_info.house_index then
			self.house_list[k] = house_info
			is_change = true
			break
		end
	end

	if not is_change then
		table.insert(self.house_list, house_info)
	end
end

function CoupleHomeHomeData:GetHouseInfoByIndex(client_index)
	if self.house_list == nil then
		return nil
	end

	return self.house_list[client_index]
end

--当前已装备的家具数量
function CoupleHomeHomeData:GetNowFurnitureCount(house_client_index)
	local house_info = self:GetHouseInfoByIndex(house_client_index)
	if house_info == nil then
		return 0
	end

	local count = 0
	local furniture_list = house_info.furniture_list
	for _, v in pairs(furniture_list) do
		if v.item_id > 0 then
			count = count + 1
		end
	end

	return count
end

function CoupleHomeHomeData:GetFurnitureInfo(house_client_index, furniture_index)
	local house_info = self:GetHouseInfoByIndex(house_client_index)
	if house_info == nil then
		return nil
	end

	local furniture_list = house_info.furniture_list
	return furniture_list[furniture_index]
end

local function SortOtherList(a, b)
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local lover_uid = main_vo.lover_uid
	local order_a = 1000
	local order_b = 1000
	if a.uid == lover_uid then
		order_a = order_a + 100
	elseif b.uid == lover_uid then
		order_b = order_b + 100
	elseif a.room_count > b.room_count then
		order_a = order_a + 5
	elseif b.room_count > a.room_count then
		order_b = order_b + 5
	end

	return order_a > order_b
end

local function SortGuildList(a, b)
	local order_a = 1000
	local order_b = 1000
	local a_post = GuildData.Instance:GetGuildPost(a.uid)
	local b_post = GuildData.Instance:GetGuildPost(b.uid)

	if GuildDataConst.GUILD_POST_WEIGHT[a_post] > GuildDataConst.GUILD_POST_WEIGHT[b_post] then
		order_a = order_a + 100
	elseif GuildDataConst.GUILD_POST_WEIGHT[b_post] > GuildDataConst.GUILD_POST_WEIGHT[a_post] then
		order_b = order_b + 100
	end

	return order_a > order_b
end

function CoupleHomeHomeData:SetFriendList(list)
	self.friend_list = list
	table.sort(self.friend_list, SortOtherList)
end

function CoupleHomeHomeData:GetFriendList()
	return self.friend_list
end

function CoupleHomeHomeData:SetGuildList(list)
	self.guild_list = list
	table.sort(self.guild_list, SortGuildList)
end

function CoupleHomeHomeData:GetGuildList()
	return self.guild_list
end

function CoupleHomeHomeData:GetThemeCfgInfoByThemeType(theme_type)
	return self.special_theme_type_cfg[theme_type]
end

--获取所有主题列表
function CoupleHomeHomeData:GetSpecialThemeCfg()
	return self.buy_special_theme_cfg
end

--获取对应家具槽位的物品列表数据（根据槽位index）
function CoupleHomeHomeData:GetFurnitureItemListByIndex(furniture_index)
	return self.furniture_base_attr_slot_cfg[furniture_index]
end

--获取对应家具槽位的物品列表数据（根据物品id）
function CoupleHomeHomeData:GetFurnitureItemListById(item_id)
	return self.furniture_base_attr_item_cfg[item_id]
end

local function SortPacketList(furniture_index)
	return function(a, b)
		local sort_a = 10000
		local sort_b = 10000

		if a.imprint_slot ~= b.imprint_slot then
			if a.imprint_slot == furniture_index then
				sort_a = sort_a + 1000
			elseif b.imprint_slot == furniture_index then
				sort_b = sort_b + 1000
			elseif a.imprint_slot > b.imprint_slot then
				sort_a = sort_a + 100
			elseif b.imprint_slot > a.imprint_slot then
				sort_b = sort_b + 100
			end
		else
			--品质优先
			local item_a_cfg = ItemData.Instance:GetItemConfig(a.item_id)
			local item_b_cfg = ItemData.Instance:GetItemConfig(b.item_id)
			if item_a_cfg and item_b_cfg then
				if item_a_cfg.color > item_b_cfg.color then
					sort_a = sort_a + 10
				elseif item_b_cfg.color > item_a_cfg.color then
					sort_b = sort_b + 10
				end
			end
		end

		return sort_a > sort_b
	end
end

--从背包中获取所有的物品列表数据
function CoupleHomeHomeData:GetAllItemListInBag(furniture_index)
	furniture_index = furniture_index or -1

	local item_list = nil
	local temp_item_map = {}
	for _, v1 in pairs(self.furniture_base_attr_slot_cfg) do
		for _, v2 in ipairs(v1) do
			if not temp_item_map[v2.item_id] then
				local num = ItemData.Instance:GetItemNumInBagById(v2.item_id)
				if num > 0 then
					if item_list == nil then
						item_list = {}
					end

					temp_item_map[v2.item_id] = true

					for i = 1, num do
						table.insert(item_list, v2)
					end
				end
			end
		end
	end

	if item_list then
		table.sort(item_list, SortPacketList(furniture_index))
	end

	return item_list
end

--从背包中获取对应的物品列表数据
function CoupleHomeHomeData:GetItemListInBagByIndex(furniture_index)
	local need_item_list = self:GetFurnitureItemListByIndex(furniture_index)
	if need_item_list == nil then
		return nil
	end

	local item_list = nil
	for _, v in ipairs(need_item_list) do
		local num = ItemData.Instance:GetItemNumInBagById(v.item_id)
		if num > 0 then
			if item_list == nil then
				item_list = {}
			end

			for i = 1, num do
				table.insert(item_list, v)
			end
		end
	end

	if item_list then
		table.sort(item_list, SortPacketList(furniture_index))
	end

	return item_list
end

--对应房子家具槽位是否有可装备家具
function CoupleHomeHomeData:HaveFurnitureEquipByIndex(house_client_index, furniture_index)
	local furniture_info = self:GetFurnitureInfo(house_client_index, furniture_index)
	if furniture_info == nil or furniture_info.item_id > 0 then
		return false
	end

	local need_item_list = self:GetFurnitureItemListByIndex(furniture_index)
	if need_item_list == nil then
		return false
	end

	for _, v in ipairs(need_item_list) do
		local num = ItemData.Instance:GetItemNumInBagById(v.item_id)
		if num > 0 then
			return true
		end
	end

	return false
end

function CoupleHomeHomeData:GetThemeAttrCfgInfoByThemeType(theme_type)
	return self.theme_attr_cfg[theme_type]
end

--获取家具位置
function CoupleHomeHomeData:GetFurniturePosByItemId(item_id)
	local pos_cfg = self.furniture_pos_cfg[item_id]
	if pos_cfg then
		return pos_cfg.pos_x, pos_cfg.pos_y
	end

	return 0, 0
end

--获取所有房子总属性
function CoupleHomeHomeData:GetTotalAttr()
	local attr_info = CommonStruct.AttributeNoUnderline()
	if self.house_list == nil then
		return attr_info
	end

	for k, _ in ipairs(self.house_list) do
		local single_attr = self:GetSingleAttr(k)
		attr_info = CommonDataManager.AddTotalAttributeAttrNoUnder(attr_info, single_attr)
	end

	return attr_info
end

--获取对应房子属性
function CoupleHomeHomeData:GetSingleAttr(client_index)
	local attr_info = CommonStruct.AttributeNoUnderline()
	local house_info = self:GetHouseInfoByIndex(client_index)
	if house_info == nil then
		return attr_info
	end

	local theme_type = house_info.theme_type
	local theme_attr = self:GetThemeAttrCfgInfoByThemeType(theme_type)
	attr_info = CommonDataManager.AddTotalAttributeAttrNoUnder(attr_info, theme_attr)

	local furniture_list = house_info.furniture_list
	for _, v in pairs(furniture_list) do
		if v.item_id > 0 then
			local item_list = self:GetFurnitureItemListById(v.item_id)
			if item_list then
				local item_info = item_list[1]
				attr_info = CommonDataManager.AddTotalAttributeAttrNoUnder(attr_info, item_info)
			end
		end
	end

	return attr_info
end

--获取总战力
function CoupleHomeHomeData:GetTotalHousePower()
	if self.house_list == nil then
		return 0
	end

	local power = 0
	for k, _ in ipairs(self.house_list) do
		local single_power = self:GetHousePowerByHouseIndex(k)
		power = power + single_power
	end

	return power
end

--获取房子的战力
function CoupleHomeHomeData:GetHousePowerByHouseIndex(client_index)
	local house_info = self:GetHouseInfoByIndex(client_index)
	if house_info == nil then
		return 0
	end

	local power = 0

	local theme_type = house_info.theme_type
	local theme_attr = self:GetThemeAttrCfgInfoByThemeType(theme_type)
	power = power + CommonDataManager.GetCapabilityCalculation(theme_attr)

	local furniture_list = house_info.furniture_list
	for _, v in pairs(furniture_list) do
		if v.item_id > 0 then
			local item_list = self:GetFurnitureItemListById(v.item_id)
			if item_list then
				local item_info = item_list[1]
				power = power + CommonDataManager.GetCapabilityCalculation(item_info)
			end
		end
	end

	return power
end