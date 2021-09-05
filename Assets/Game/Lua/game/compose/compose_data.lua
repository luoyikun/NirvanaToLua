ComposeData = ComposeData or BaseClass()

ComposeData.Type = {
	stone = 1,
	other = 2,
	jinjie = 3,
	shengqi = 4,
	shenmo = 5,
}

function ComposeData:__init()
	if ComposeData.Instance then
		print_error("[ComposeData] Attemp to create a singleton twice !")
	end
	ComposeData.Instance = self
	self.select_flag = 0

	-- RemindManager.Instance:Register(RemindName.ComposeStone, BindTool.Bind(self.CalcStoreRedPoint, self))
	-- RemindManager.Instance:Register(RemindName.ComposeOther, BindTool.Bind(self.CalcOtherRedPoint, self))
	-- RemindManager.Instance:Register(RemindName.ComposeJinjie, BindTool.Bind(self.CalcJinjieRedPoint, self))
	RemindManager.Instance:Register(RemindName.ComposeShengqi, BindTool.Bind(self.CalcShengqiRedPoint, self))
	RemindManager.Instance:Register(RemindName.ComposeShenmo, BindTool.Bind(self.CalcShenmoRedPoint, self))
end

function ComposeData:__delete()
	-- RemindManager.Instance:UnRegister(RemindName.ComposeStone)
	-- RemindManager.Instance:UnRegister(RemindName.ComposeOther)
	-- RemindManager.Instance:UnRegister(RemindName.ComposeJinjie)
	RemindManager.Instance:UnRegister(RemindName.ComposeShengqi)
	RemindManager.Instance:UnRegister(RemindName.ComposeShenmo)
	ComposeData.Instance = nil
end

--改变宝石红点
function ComposeData:CalcStoreRedPoint()
	local flag = 0
	local compose_list = self:GetTypeOfAllItem(ComposeData.Type.stone)
	for _,v in pairs(compose_list) do
		if v.sub_type == 16 then
			local can_compose_id = self:JudgeMatRich(v.product_id)
			if can_compose_id then
				flag = 1
			end
		end
	end
	return flag
end

--改变其他红点
function ComposeData:CalcOtherRedPoint()
	local flag = 0
	local compose_list = self:GetTypeOfAllItem(ComposeData.Type.other)
	local can_compose_id = self:CheckBagMat(compose_list)
	if can_compose_id > 0 then
		flag = 1
	end

	return flag
end

--改变锻造红点
function ComposeData:CalcJinjieRedPoint()
	local flag = 0
	local compose_list = self:GetTypeOfAllItem(ComposeData.Type.jinjie)
	local can_compose_id = self:CheckBagMat(compose_list)
	if can_compose_id > 0 then
		if self:IsJingJieCanComposeId(can_compose_id) then
			flag = 1
		end
	end

	return flag
end

function ComposeData:IsJingJieCanComposeId(id)
	local sub_type = 36 							-- 境界令牌的
	local list = self:GetComposeItemList(sub_type)
	if list then
		for k,v in pairs(list) do
			if v and v.product_id == id then
				return false
			end
		end
	end
	return true
end

--改变锻造红点
function ComposeData:CalcShengqiRedPoint()
	local flag = 0
	local compose_list = self:GetTypeOfAllItem(ComposeData.Type.shengqi)
	local can_compose_id = self:CheckBagMat(compose_list)
	if can_compose_id > 0 then
		flag = 1
	end

	return flag
end

--改变锻造红点
function ComposeData:CalcShenmoRedPoint()
	local flag = 0
	local compose_list = self:GetTypeOfAllItem(ComposeData.Type.shenmo)
	local can_compose_id = self:CheckBagMat(compose_list)
	if can_compose_id > 0 then
		flag = 1
	end

	return flag
end

--获取compose_menu配置
function ComposeData:GetComposeMenuList()
	return ConfigManager.Instance:GetAutoConfig("compose_auto").compose_menu
end

--获取compose_list配置
function ComposeData:GetComposeList()
	return ConfigManager.Instance:GetAutoConfig("compose_auto").compose_list
end

function ComposeData:GetComposeTypeOfCount(compose_type)
	local compose_menu_list = self:GetComposeMenuList()
	local count = 0
	for k,v in pairs(compose_menu_list) do
		if v.type == compose_type then
			count = count + 1
		end
	end
	return count
end

function ComposeData:GetShenShouComposeTypeOfCount()
	return #self:GetSSEquipHeChengAccordionDataList()
end

function ComposeData:GetShenShouComposeTypeOfNameList()
	local equipforge_cfg = ConfigManager.Instance:GetAutoConfig("shenshou_cfg_auto")
	local role_level = PlayerData.Instance:GetRoleLevel()
	local data_list = {}
	for k, v in ipairs(equipforge_cfg.equip_exchange) do
		if role_level >= v.level then
			local name = CommonDataManager.GetDaXie(v.compose_equip_best_attr_num) .. Language.Compose.HeChengItemFatherName[v.type]
			table.insert(data_list, name)
		end
	end
	return data_list
end

function ComposeData:GetShenShouComposeItemList(sub_type)
	local list = {}
	local equipforge_cfg = ConfigManager.Instance:GetAutoConfig("shenshou_cfg_auto")
	for k, v in ipairs(equipforge_cfg.equip_exchange) do
		if sub_type == v.type then
			table.insert(list, v)
			break
		end
	end
	return list
end

function ComposeData:GetSehnShouSubTypeList()
	local list = {}
	local equipforge_cfg = ConfigManager.Instance:GetAutoConfig("shenshou_cfg_auto")
	local role_level = PlayerData.Instance:GetRoleLevel()
	local data_list = {}
	for k, v in ipairs(equipforge_cfg.equip_exchange) do
		if role_level >= v.level then
			local type = v.type
			table.insert(list, type)
		end
	end
	return list
end

function ComposeData:OnClickAccordionSSHechengChild(data)
	local equip_ss_hecheng_list = {}
	if data and next(data) then
		for index = 1, 5 do
			if data["cao" .. index] ~= nil and data["cao" .. index] ~= 0 then
				local param_t = {}
				param_t.star_level = data.compose_equip_best_attr_num
				local data_vo = {item_id = data["cao" .. index], compose_equip_best_attr_num = data.compose_equip_best_attr_num, type = data.type, param = param_t}
				table.insert(equip_ss_hecheng_list, data_vo)
			end
		end
	end
	return equip_ss_hecheng_list
end

function ComposeData:GetSSEquipHeChengAccordionDataList()
	local equipforge_cfg = ConfigManager.Instance:GetAutoConfig("shenshou_cfg_auto")
	local role_level = PlayerData.Instance:GetRoleLevel()
	local data_list = {}
	for k, v in ipairs(equipforge_cfg.equip_exchange) do
		if role_level >= v.level then
			if data_list[v.type * 100 + v.compose_equip_best_attr_num] == nil then
				data_list[v.type * 100 + v.compose_equip_best_attr_num] = {}
			end
			table.insert(data_list[v.type * 100 + v.compose_equip_best_attr_num], v)
		end
	end

	local acc_data_list = {}
	for k, child_list in pairs(data_list)do
		local item_data = {}
		for k,v in ipairs(child_list)do
			table.insert(item_data, v)
		end
		table.insert(acc_data_list, {child = item_data, star_level = item_data[1].compose_equip_best_attr_num, name_type = item_data[1].type})
	end

	return acc_data_list
end

function ComposeData:GetComposeTypeOfNameList(compose_type)
	local compose_menu_list = self:GetComposeMenuList()
	local name_list = {}
	for k,v in pairs(compose_menu_list) do
		if v.type == compose_type then
			name_list[#name_list + 1] = v.sub_name
		end
	end
	return name_list
end

--通过一级类型获取二级类型
function ComposeData:GetSubTypeList(compose_type)
	local compose_menu_list = self:GetComposeMenuList()
	local temp_list = {}
	for k,v in pairs(compose_menu_list) do
		if v.type == compose_type then
			temp_list[#temp_list + 1] = v.sub_type
		end
	end
	return temp_list
end

--通过二级类型获取二级类型的集合
function ComposeData:GetComposeItemList(sub_type)
	local compose_list = self:GetComposeList()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local temp_list = {}
	for k,v in pairs(compose_list) do
		if v.sub_type == sub_type and main_vo.level >= v.level then
			temp_list[#temp_list + 1] = v
		end
	end
	function sortfun(a, b)
		return a.producd_seq < b.producd_seq
	end
	table.sort(temp_list, sortfun)
	return temp_list
end

--得到一个composeItem
function ComposeData:GetComposeItem(product_id)
	local compose_list = self:GetComposeList()
	for k,v in pairs(compose_list) do
		if v.product_id == product_id then
			return v
		end
	end
end

--获得物品的资料
function ComposeData:GetItemInfo(product_id)
	return ConfigManager.Instance:GetAutoItemConfig("other_auto")[product_id]
end

function ComposeData:GetShowId(one_type)
	local the_list = self:GetTypeOfAllItem(one_type)
	for k,v in pairs(the_list) do
		if self:GetCanByNum(v.product_id) > 0 then
			return v.product_id
		end
	end
	return the_list[1].product_id
end

--该合成集合,背包是否有一个可合成
function ComposeData:CheckBagMat(the_compose_item_list)
	local compose_item_list = the_compose_item_list
	for k,v in pairs(compose_item_list) do
		local stuff_id_count = ItemData.Instance:GetItemNumInBagById(v.stuff_id_1)
		local stuff_need_count = v.stuff_count_1
		if stuff_need_count <= stuff_id_count then
			return v.product_id
		end
	end
	return 0
end

--一级类型的所有物品
function ComposeData:GetTypeOfAllItem(one_type)  --一级类型
	local list = self:GetComposeList()
	local new_list = {}
	for k,v in pairs(list) do
		if v.type == one_type then
			new_list[#new_list + 1] = v
		end
	end
	function sortfun(a, b)
		return a.producd_seq < b.producd_seq
	end
	table.sort(new_list, sortfun)
	return new_list
end

function ComposeData:SetToProductId(product_id)
	if product_id then
		local compose_cfg = self:GetComposeItem(self:GetProductIdByStuffId(product_id))
		if compose_cfg then
			self.to_product_id = compose_cfg.product_id
		end
	else
		self.to_product_id = product_id
	end
end

function ComposeData:GetToProductId()
	return self.to_product_id
end

--这一列sub_type是否有可合成的
function ComposeData:GetSubIsHaveCompose(sub_type)
	local the_list = self:GetComposeItemList(sub_type)
	for k,v in pairs(the_list) do
		if self:JudgeMatRich(v.product_id) then
			return true
		end
	end
	return false
end

--这一列sub_type可可合成的个数
function ComposeData:GetSubIsHaveComposeNum(sub_type)
	local the_list = self:GetComposeItemList(sub_type)
	local num = 0
	for k,v in pairs(the_list) do
		if self:JudgeMatRich(v.product_id) then
			num = num + 1
		end
	end
	return num
end

function ComposeData:GetProductIdByStuffId(stuff_id)
	local the_list = self:GetComposeList()
	for k,v in pairs(the_list) do
		if v.stuff_id_1 == stuff_id then
			return v.product_id
		end
	end
	return 0
end

function ComposeData:GetProductCfg(stuff_id)
	local the_list = self:GetComposeList()
	for k,v in pairs(the_list) do
		if v.stuff_id_1 == stuff_id then
			return v
		end
	end
	return nil
end

function ComposeData:GetProductCfgEnoughLevel(stuff_id)
	local the_list = self:GetComposeList()
	local role_level = PlayerData.Instance:GetRoleLevel()
	for k,v in pairs(the_list) do
		if v.stuff_id_1 == stuff_id and v.level <= role_level then
			return v
		end
	end
	return nil
end

function ComposeData:GetCurrentListIndex()
	local sub_type_list = self:GetSubTypeList(ComposeContentView.Instance:GetCurrentType())
	local compose_item_list = {}
	for k,v in pairs(sub_type_list) do
		compose_item_list[#compose_item_list + 1] = self:GetComposeItemList(v)
	end
	local list_index = 0
	for k,v in pairs(compose_item_list) do
		for m,n in pairs(v) do
			local cur_item_id = ComposeContentView.Instance:GetCurrentItemId()
			if self.to_product_id then
				cur_item_id = self.to_product_id
			end
			if n.product_id == cur_item_id then
				list_index = k
				return list_index
			end
		end
	end
	return list_index
end

----新data
function ComposeData:JudgeMatRich(product_id) --判断材料是否足够
	local compose_cfg = ComposeData.Instance:GetComposeItem(product_id)
	for i = 1, 3 do
		if compose_cfg["stuff_id_"..i] ~= 0 then
			if ItemData.Instance:GetItemNumInBagById(compose_cfg["stuff_id_"..i]) <  compose_cfg["stuff_count_"..i] then
				return false
			end
		end
	end
	return true
end

function ComposeData:GetCanByNum(product_id) --获得可合成数量
	local compose_cfg = ComposeData.Instance:GetComposeItem(product_id)
	local can_buy_num = nil
	for i = 1, 3 do
		if compose_cfg["stuff_id_"..i] ~= 0 then
			local my_count = ItemData.Instance:GetItemNumInBagById(compose_cfg["stuff_id_"..i])
			local cfg_count = compose_cfg["stuff_count_"..i]
			if my_count >= cfg_count then
				local temp_num = math.floor(my_count/cfg_count)
				if can_buy_num == nil then
					can_buy_num = temp_num
				else
					if temp_num <= can_buy_num then
						can_buy_num = temp_num
					end
				end
			end
		end
	end
	if can_buy_num == nil then
		can_buy_num = 0
	end
	return can_buy_num
end

--获得商城中是否有这些物品中的之一
function ComposeData:GetIsHaveItemOfShop(product_id)
	local compose_cfg = ComposeData.Instance:GetComposeItem(product_id)
	local shop_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item
	for k,v in pairs(shop_cfg) do
		if v.itemid == compose_cfg["stuff_id_"..1] or v.itemid == compose_cfg["stuff_id_"..2] or v.itemid == compose_cfg["stuff_id_"..3] then
			return true
		end
	end
	return false
end

--获得商城中是否有该单个物品
function ComposeData:GetIsHaveSingleItemOfShop(product_id, index)
	local compose_cfg = ComposeData.Instance:GetComposeItem(product_id)
	local shop_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item
	for k,v in pairs(shop_cfg) do
		if v.itemid == compose_cfg["stuff_id_"..1] or v.itemid == compose_cfg["stuff_id_"..2] or v.itemid == compose_cfg["stuff_id_"..3] then
			return true
		end
	end
	return false
end

--单个物品是否足够合成
function ComposeData:GetSingleMatRich(product_id,index)
	local compose_cfg = ComposeData.Instance:GetComposeItem(product_id)
	if compose_cfg["stuff_id_"..index] == 0 then
		return true
	end
	local my_count = ItemData.Instance:GetItemNumInBagById(compose_cfg["stuff_id_"..index])
	local cfg_count = compose_cfg["stuff_count_"..index]
	if my_count > cfg_count then
		return true
	else
		return false
	end
end

function ComposeData:GetEnoughMatEqualNeedCount(item_id)
	local compose_cfg = self:GetComposeItem(item_id)
	if compose_cfg == nil then return false end
	for i = 1, 3 do
		if compose_cfg["stuff_id_"..i] ~= 0 then
			local my_count = ItemData.Instance:GetItemNumInBagById(compose_cfg["stuff_id_"..i])
			local cfg_count = compose_cfg["stuff_count_"..i]
			if my_count ~= cfg_count then
				return false
			end
		end
	end
	return true
end

function ComposeData:GetShowItemId(the_type, sub_type)
	local first_list = self:GetComposeItemList(sub_type)
	for _,v in pairs(first_list) do
		if self:JudgeMatRich(v.product_id) then
			return v.product_id
		end
	end
	sub_type_list = self:GetSubTypeList(the_type)
	for k,v in pairs(sub_type_list) do  --移除遍历过的
		if v == sub_type then
			table.remove(sub_type_list, k)
			break
		end
	end
	for _,v in pairs(sub_type_list) do
		local the_list = self:GetComposeItemList(v)
		for _,v2 in pairs(the_list) do
			if self:JudgeMatRich(v2.product_id) then
				return v2.product_id
			end
		end
	end
	return -1
end

function ComposeData:GetCountText(product_id)
	local list = {}
	local compose_cfg = self:GetComposeItem(product_id)
	for i = 1, 3 do
		local text = ""
		if compose_cfg["stuff_id_"..i] ~= 0 then
			local my_count = ItemData.Instance:GetItemNumInBagById(compose_cfg["stuff_id_"..i])
			local cfg_count = compose_cfg["stuff_count_"..i]
			local green_text = ToColorStr(tostring(cfg_count), TEXT_COLOR.GREEN)
			local my_count_text = ""
			if my_count >= cfg_count then
				my_count_text = ToColorStr(tostring(my_count), TEXT_COLOR.GREEN)
				text = my_count_text .. " / " .. green_text
			else
				my_count_text = ToColorStr(tostring(my_count), TEXT_COLOR.RED)
				text = my_count_text .. " / " .. green_text
			end
		end
		table.insert(list, text)
	end
	return list
end

function ComposeData:SetSelectFlag(flag)
	self.select_flag = flag
end

function ComposeData:GetSelectFlag()
	return self.select_flag or 0
end