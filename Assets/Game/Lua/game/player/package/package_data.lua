 GUILD_CHAT_LEVEL = 300 -- 公会取出装备，聊天界面发出信息最大等级
local CHECK_PACK_LEVEL = 100

ItemDataKnapsackId = {
	Id = 26914
}

ItemDataStorageId = {
	Id = 26915
}

PackageData = PackageData or BaseClass()
function PackageData:__init()
	if PackageData.Instance then
		print_error("[PackageData] Attemp to create a singleton twice !")
	end

	PackageData.Instance = self

	self.recycle_data_list = {}
	self.online_auto_recycle = false
	self.open_cell_cost = nil
	self.warehouse_open_cell_cost = nil
	self.colddown_info_list = {}
	self.rand_gift_info = {}
	self.rand_gift_list = {}
	self.new_item_list = {}
	self.next_key = 1
	self.num_value = nil
	self.auto_extend_need_online_time = 0			--开启当前锁定格子所需要的时间
	self.before_auto_extend_need_online_time = 0	--开启上一个解锁的格子所需要的时间
	self.first_online_recycl = true					--上线自动分解

	self.knapsack_grid_extend_cfg = ConfigManager.Instance:GetAutoConfig("otherconfig_auto").bag_cfg
	self.knapsack_grid_auto_add_cfg = ConfigManager.Instance:GetAutoConfig("otherconfig_auto").knapsack_grid_auto_add_cfg
	-- 特殊处理，紫色珍惜道具，从右往左飞动画展示
	self.knapsack_grid_zhenxi_zise_cfg = ConfigManager.Instance:GetAutoConfig("other_config_auto").zhenxi_zise

	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	RemindManager.Instance:Register(RemindName.PlayerPackage, BindTool.Bind(self.GetPlayerPackageRemind, self))
end

function PackageData:__delete()
	RemindManager.Instance:UnRegister(RemindName.PlayerPackage)
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
	self.num_value = nil
	PackageData.Instance = nil
end

function PackageData:ItemDataChangeCallback(item_id, index, change_reason, put_reason, old_num, new_num, param_change, old_data)
	if change_reason ~= DATALIST_CHANGE_REASON.REMOVE then
		local data = ItemData.Instance:GetGridData(index)
		self:NoticeEffectOnGetItem(data, old_num, put_reason)
	end

	-- W3仙盟仓库已经屏蔽
	-- self:CheckTakeOutFromGuildStoreHandler(item_id, index, change_reason, put_reason, old_num, new_num, old_data)
end

function PackageData:EmptyRecycleList()
	self.recycle_data_list = {}
end

function PackageData:SetRecycleItemDataList(is_add, data_list, color)
	if is_add then
		for k,v in pairs(data_list) do
			table.insert(self.recycle_data_list, v)
		end
	else
		for i = #self.recycle_data_list ,1 ,-1 do
			local item_cfg, item_type = ItemData.Instance:GetItemConfig(self.recycle_data_list[i].item_id)
			if item_cfg.color == color then
				table.remove(self.recycle_data_list, i )
				
			end
		end
	end
end

function PackageData:SetRecyleDataList(enable)
	self.online_auto_recycle = enable or false
	self.recycle_data_list = {}
	local common_order_list = SettingData.Instance:GetCommonRecycleTable()
	local zhuanzhi_order_list = SettingData.Instance:GetRecycleTable()
	for k, v in pairs(common_order_list) do
		if v == 1 then
			self:GetEquipDataListByOrder(32 - k + 1)
		end
	end
	for k, v in pairs(zhuanzhi_order_list) do
		if v == 1 then
			self:GetEquipDataListByOrder(32 - k + 1, true)
		end
	end
end

function PackageData:GetEquipDataListByOrder(index, is_zhuanzhi)
	local order_data_list = {}
	local data_list = self:GetRecycleDataList(is_zhuanzhi)
	for k , v in pairs(data_list) do
		if v ~= nil then
			local item_cfg, item_type = ItemData.Instance:GetItemConfig(v.item_id)
			-- if nil ~= item_cfg and (item_cfg.order == index or item_cfg.color == color)then
			if nil ~= item_cfg then
				local color = 1
				if item_cfg.color <= 2 then
					color = 1
				elseif item_cfg.color == 3 then
					color = 2
				elseif item_cfg.color == 4 then
					color = 3
				else
					color = 4
				end
				if color == index then
					table.insert(self.recycle_data_list, v)
				end
			end
		end
	end

	if self.online_auto_recycle then
		self:OnLineAutoRecycle()
	end
end

function PackageData:GetRecycleItemDataList()
	return self.recycle_data_list
end

--获取可回收的装备列表
function PackageData:GetRecycleDataList(is_zhuanzhi)
	local data_list = {}
	local equip_type_list = ItemData.Instance:GetItemListByBigType(GameEnum.ITEM_BIGTYPE_EQUIPMENT)

	local gamevo = GameVoManager.Instance:GetMainRoleVo()
	for k , v in pairs(equip_type_list) do
		local is_add = true
		local item_cfg, item_type = ItemData.Instance:GetItemConfig(v.item_id)
		for k1,v1 in pairs(self.recycle_data_list) do
			if v1.index == v.index and v1.item_id == v.item_id then
				is_add = false
			end
		end
		if item_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and (item_cfg.recycltype == 6 or item_cfg.recycltype == 9 or item_cfg.recycltype == 10) and is_add and not DouQiData.Instance:IsDouqiEqupi(v.item_id) then
			local is_zhuanzhi_type = EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type)
			if is_zhuanzhi then
				if is_zhuanzhi_type then
					local base_prof, zhuan = PlayerData.Instance:GetRoleBaseProf()
					if (item_cfg.limit_prof ~= 5 and item_cfg.limit_prof ~= base_prof) then
						table.insert(data_list, v)
					else
						if not EquipData.Instance:CheckIsAutoEquip(v.item_id, v.index) then
							table.insert(data_list, v)
						end
					end
				end
			else
				if not is_zhuanzhi_type then
					table.insert(data_list, v)
				end
			end
		end
	end
	return data_list
end

function PackageData:AddItemToRecycleList(data)
	table.insert(self.recycle_data_list, data)
end

function PackageData:RemoveRecycData(data)
	if not data then return end
	for k, v in pairs(self.recycle_data_list) do
		if data.index == v.index then
			table.remove(self.recycle_data_list, k)
			break
		end
	end
end

function PackageData:OnLineAutoRecycle()
	local recycle_list = self.recycle_data_list

	local index_list = {}
	local index_list2 = {}
	for k,v in pairs(recycle_list) do
		if k <= 200 then
			table.insert(index_list, v)
		else
			table.insert(index_list2, v)
		end
	end

	if #recycle_list <= 0 then
		return 0
	end

	if next(index_list) then
		PackageCtrl.Instance:SendBatchDiscardItem(#index_list, index_list)
	elseif next(index_list2) then
		PackageCtrl.Instance:SendBatchDiscardItem(#index_list2, index_list2)
	end

	self.online_auto_recycle = false
	self.recycle_data_list = {}
end

function PackageData:GetWarehouseGridData(index)
	local data = ItemData.Instance:GetGridData(index + COMMON_CONSTS.MAX_BAG_COUNT)
	if data then
		return TableCopy(data)
	end

	return nil
end

function PackageData:GetCellData(client_cell_index , toggle_type)

	if toggle_type == GameEnum.TOGGLE_INFO.MATERIAL_TOGGLE then
		local list = ItemData.Instance:GetPackageItemListByBigType(GameEnum.PACKAGE_BIGTYPE_OTHER)
		return list and list[client_cell_index + 1] or nil

	elseif toggle_type == GameEnum.TOGGLE_INFO.EQUIP_TOGGLE then
		local list = ItemData.Instance:GetPackageItemListByBigType(GameEnum.PACKAGE_BIGTYPE_EQUIP)
		return list and list[client_cell_index + 1] or nil

	elseif toggle_type == GameEnum.TOGGLE_INFO.CONSUME_TOGGLE then
		local list = ItemData.Instance:GetPackageItemListByBigType(GameEnum.PACKAGE_BIGTYPE_EXCHANGE)
		return list and list[client_cell_index + 1] or nil

	elseif toggle_type == GameEnum.TOGGLE_INFO.ALL_TOGGLE then
		return ItemData.Instance:GetGridData(client_cell_index) 
	end
	return nil
end

function PackageData:GetWareCellData(client_cell_index , toggle_type)
	if toggle_type == GameEnum.TOGGLE_INFO.MATERIAL_TOGGLE then
		local list = ItemData.Instance:GetCKListByBigType(GameEnum.PACKAGE_BIGTYPE_OTHER)
		return list and list[client_cell_index + 1] or nil

	elseif toggle_type == GameEnum.TOGGLE_INFO.EQUIP_TOGGLE then
		local list = ItemData.Instance:GetCKListByBigType(GameEnum.PACKAGE_BIGTYPE_EQUIP)
		return list and list[client_cell_index + 1] or nil

	elseif toggle_type == GameEnum.TOGGLE_INFO.CONSUME_TOGGLE then
		local list = ItemData.Instance:GetCKListByBigType(GameEnum.PACKAGE_BIGTYPE_EXCHANGE)
		return list and list[client_cell_index + 1] or nil

	elseif toggle_type == GameEnum.TOGGLE_INFO.ALL_TOGGLE then
		return self:GetWarehouseGridData(client_cell_index)
	end

	return nil
end

function PackageData:GetPlayerPackageRemind()
	return self:IsShowBagRedPoint() and 1 or 0
end

function PackageData:IsShowBagRedPoint()
	return EquipmentShenData.Instance:GetShenEquipRemind() > 0
end

-- 背包扩展
function PackageData:GetCellOpenNeedCount(index)
	local len = #self.knapsack_grid_extend_cfg
	for i=len, 1, -1 do
		if self.knapsack_grid_extend_cfg[i] and index >= self.knapsack_grid_extend_cfg[i].min_extend_index then
			return self.knapsack_grid_extend_cfg[i].need_item_count
		end
	end
	return 0
end

--获取物品可以开启多少背包格子
function PackageData:GetCanOpenHowManySlot(storage_type, num)
	local now_index = 0
	local max_gird_num = 0

	if storage_type == GameEnum.STORAGER_TYPE_BAG then
		now_index = ItemData.Instance:GetMaxKnapsackValidNum()
		max_gird_num = GameEnum.ROLE_BAG_SLOT_NUM
	elseif storage_type == GameEnum.STORAGER_TYPE_STORAGER then

		now_index = ItemData.Instance:GetMaxStorageValidNum()
		max_gird_num = GameEnum.STORAGER_SLOT_NUM
	end

	if now_index == max_gird_num then
		return -1, 0, 0
	end

	local need_number = 0
	local can_open_num = 0
	local old_need_num = 0
	for try_index = now_index, max_gird_num - 1 do
		local open_one_need = self:GetCellOpenNeedCount(try_index)
		if storage_type == GameEnum.STORAGER_TYPE_STORAGER then
			open_one_need = self:GetCellOpenNeedCount(try_index)
		end
		old_need_num = need_number
		need_number = need_number + open_one_need
		can_open_num = can_open_num + 1

		if need_number > num then
			return can_open_num - 1, need_number, old_need_num
		end
	end

	return can_open_num, need_number, old_need_num
end

function PackageData:GetWareHouseCellOpenNeedCount(index)
	if self.warehouse_open_cell_cost == nil then   --开格子配置直接写在这
		self.warehouse_open_cell_cost = {
			{min_extend_index = 0, need_item_count = 1},
			{min_extend_index = 15, need_item_count = 1},
			{min_extend_index = 25, need_item_count = 2},
			{min_extend_index = 30, need_item_count = 3},
			{min_extend_index = 35, need_item_count = 4},
			{min_extend_index = 40, need_item_count = 6},
			{min_extend_index = 45, need_item_count = 8},
			{min_extend_index = 50, need_item_count = 10},
			{min_extend_index = 55, need_item_count = 15},
		}
	end

	local len = #self.warehouse_open_cell_cost
	for i=len, 1, -1 do
		if index >= self.warehouse_open_cell_cost[i].min_extend_index then
			return self.warehouse_open_cell_cost[i].need_item_count
		end
	end
	return 0
end

function PackageData:GetOpenCellNeedItemNum(item_id, need_index)
	local num = 0
	if item_id == ItemDataKnapsackId.Id then
		for i = ItemData.Instance:GetMaxKnapsackValidNum(), need_index do
			num =  num + self:GetCellOpenNeedCount(i)
		end
	else
		-- 这个是仓库的免费20个需要加80匹配背包
		for i = ItemData.Instance:GetMaxStorageValidNum() + 80, need_index + 80 do
			num =  num + self:GetCellOpenNeedCount(i)
		end
	end
	return num
end

-- 获取背包整理时快速的使用物品，默认获取背包的
function PackageData:GetQuickUseItem(data_list)
	local item_list = {}
	local data_list = data_list or ItemData.Instance:GetBagItemDataList()
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	for k, v in pairs(data_list) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg and role_level >= item_cfg.limit_level and item_cfg.choose_use and 1 == item_cfg.choose_use then
			local temp_v = TableCopy(v)
			table.insert(item_list, temp_v)
			temp_v.color = item_cfg.color
		end
	end
	table.sort(item_list, function (a, b)
		if a.color ~= b.color then
			return a.color > b.color
		else
			return a.item_id > b.item_id
		end
	end)
	return item_list
end

-- 检查背包是否有更好装备
function PackageData:CheckBagBatterEquip()
	local gamevo = GameVoManager.Instance:GetMainRoleVo()
	if gamevo.level < CHECK_PACK_LEVEL then
		return 0, 0
	end
	local data_list = ItemData.Instance:GetBagItemDataList()
	for k, v in pairs(data_list) do
		if self:IsBetterEquip(v) then
			return v.item_id, v.index
		end
	end
	return 0, 0
end

function PackageData:IsBetterEquip(item_data)
	local gamevo = GameVoManager.Instance:GetMainRoleVo()
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(item_data.item_id)
	if item_cfg and big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT then
		if gamevo.level >= item_cfg.limit_level and ((gamevo.prof % 10) == item_cfg.limit_prof or item_cfg.limit_prof == 5) then
			if EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type) and not EquipData.IsMarryEqType(item_cfg.sub_type or -1) then
				local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
				local zhuanzhi_info = ForgeData.Instance:GetZhuanzhiEquipInfo(equip_index, item_cfg.order)
				if zhuanzhi_info and zhuanzhi_info.role_need_min_prof_level <= math.floor(gamevo.prof / 10) then
					if EquipData.Instance:CheckIsAutoEquip(item_data.item_id, item_data.index) then
						return true
					end
				end
			end
		end
	end
	return false
end

function PackageData:AutoRecyclEquip()
	local gamevo = GameVoManager.Instance:GetMainRoleVo()
	if CHECK_PACK_LEVEL >= gamevo.level then
		return
	end
	local auto_pick_equip = SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_RECYCLE_EQUIP)
	if not auto_pick_equip then
		return
	end

	local data_list = ItemData.Instance:GetBagItemDataList()
	local common_recycle_tab = SettingData.Instance:GetCommonRecycleTable()
	local zhuanzhi_recycle_tab =  SettingData.Instance:GetRecycleTable()

	for k, v in pairs(data_list) do
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
		if k < COMMON_CONSTS.MAX_BAG_COUNT and big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type) >= 0 then
			if EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type) then
				local color = item_cfg.color - 1 <= 1 and 1 or item_cfg.color - 1 				-- 转职装备回收从阶数修改为品质
				if zhuanzhi_recycle_tab[33 - color] == 1 then
					local base_prof, zhuan = PlayerData.Instance:GetRoleBaseProf()
					if (item_cfg.limit_prof ~= 5 and item_cfg.limit_prof ~= base_prof) then
						PackageCtrl.Instance:SendDiscardItem(v.index, v.num, v.item_id, v.num, 1)
					else
						if not EquipData.Instance:CheckIsAutoEquip(v.item_id, v.index, 0) then
							PackageCtrl.Instance:SendDiscardItem(v.index, v.num, v.item_id, v.num, 1)
						end
					end
				end
			-- else
				-- if common_recycle_tab[33 - item_cfg.order] == 1 then
					-- PackageCtrl.Instance:SendDiscardItem(v.index, v.num, v.item_id, v.num, 1)
				-- end
			end
		end
	end
end

-- 斗气自动分解去掉
function PackageData:AutoRecyclDouqiEquip()
	-- local gamevo = GameVoManager.Instance:GetMainRoleVo()
	-- if CHECK_PACK_LEVEL >= gamevo.level then
	-- 	return
	-- end
	-- if not OpenFunData.Instance:CheckIsHide("douqi_view") then
	-- 	return
	-- end

	-- local auto_pick_equip = DouQiData.Instance:GetDouqiRecoveryFlag(4)
	-- if 0 == auto_pick_equip then
	-- 	return
	-- end

	-- local data_list = ItemData.Instance:GetBagItemDataList()
	-- for k, v in pairs(data_list) do
	-- 	if DouQiData.Instance:IsDouqiEqupi(v.item_id) then
	-- 		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
	-- 		if item_cfg then
	-- 			if ((2 >= item_cfg.color and 1 == DouQiData.Instance:GetDouqiRecoveryFlag(1)) or (3 == item_cfg.color and 1 == DouQiData.Instance:GetDouqiRecoveryFlag(2)) or 
	-- 				(4 == item_cfg.color and 1 == DouQiData.Instance:GetDouqiRecoveryFlag(3))) and not EquipData.Instance:CheckIsAutoEquip(v.item_id, v.index, 0) then
	-- 				PackageCtrl.Instance:SendDiscardItem(v.index, v.num, v.item_id, v.num, 1)
	-- 			end		
	-- 		end
	-- 	end
	-- end
end


function PackageData:GetFirstOnlineAutoRecycl()
	return self.first_online_recycl
end

function PackageData:SetFirstOnlineAutoRecycl(first_online_recycl)
	self.first_online_recycl = first_online_recycl
end

function PackageData:SetColddownInfo(colddown_id, end_time)
	self.colddown_info_list[colddown_id] = end_time
	GlobalEventSystem:Fire(KnapsackEventType.KNAPSACK_COLDDOWN_CHANGE, colddown_id, end_time)
end

function PackageData:GetColddownEndTime(colddown_id)
	return self.colddown_info_list[colddown_id] or 0
end

function PackageData:NoticeEffectOnGetItem(data, old_num, put_reason)
	if data == nil or nil == old_num or nil == put_reason then return end

	if data.num > old_num and put_reason ~= PUT_REASON_TYPE.PUT_REASON_INVALID and put_reason ~= PUT_REASON_TYPE.PUT_REASON_NO_NOTICE then
		local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
		if item_cfg ~= nil then
			local item_name = ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color])
			local str = string.format(Language.SysRemind.AddItem, item_name, data.num - old_num)
			if put_reason == PUT_REASON_TYPE.PUT_REASON_LITTLE_PET_CHOUJIANG_ONE then
				self:DeyToShowFloatingLabel(str)
			elseif put_reason == PUT_REASON_TYPE.PUT_REASON_SHENSHOU_HUANLING_REWARD then
				ShenShouData.Instance:SetFloatingLabel(str)
			else
				TipsCtrl.Instance:ShowFloatingLabel(str)
			end
		end
	end
end

-- 从公会仓库取出装备后，在公会聊天那里发句话
function PackageData:CheckTakeOutFromGuildStoreHandler(change_item_id, change_item_index, change_reason, put_reason, old_num, new_num, data)
	if put_reason == PUT_REASON_TYPE.PUT_REASON_GUILD_STORE and nil ~= data then
		local gamevo = GameVoManager.Instance:GetMainRoleVo()
		if gamevo.level >= GUILD_CHAT_LEVEL then
			return
		end

		local xianpin_type_list = data.param.xianpin_type_list

		local type_1 = xianpin_type_list[1] or 0
		local type_2 = xianpin_type_list[2] or 0
		local type_3 = xianpin_type_list[3] or 0

		local cur_data_power = EquipData.Instance:GetEquipLegendFightPowerByData(data, false, true)
		local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
		local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
		local equip_data = EquipData.Instance:GetGridData(equip_index)
		local equip_data_power = 0
		local content = string.format(Language.Guild.TakeOutFromGuildStore, gamevo.role_id, gamevo.name, change_item_id, change_item_id, type_1, type_2, type_3)

		if nil ~= equip_data and nil ~= equip_data.item_id and equip_data.item_id > 0 then
			equip_data_power = EquipData.Instance:GetEquipLegendFightPowerByData(equip_data, false, true)
		end
		if cur_data_power > equip_data_power then
			content = content..string.format(Language.Guild.FightPowerUp, (cur_data_power - equip_data_power))
		end

		ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, content)
	end
end

function PackageData:DeyToShowFloatingLabel(str)
	local timer_cal = 2
	self.cal_time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer_cal = timer_cal - UnityEngine.Time.deltaTime
		if timer_cal < 0 then
			TipsCtrl.Instance:ShowFloatingLabel(str)
			GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		end
	end, 0)
end

function PackageData:GetXuNiWu()
	local item_list = {}
	local itemdata_cfg = ItemData.Instance:GetItemConfig(90002)
	if itemdata_cfg then
		table.insert(item_list, itemdata_cfg)
	end
	return item_list, self.num_value
end

function PackageData:SetKnapsackGridExtendAutoData(protocol)
	self.online_time = protocol.online_time						--在线时长
	self.auto_extend_times = protocol.auto_extend_times			--自动扩展格子数目
	self:ResetKnapsackAutoNeedTime()
end

function PackageData:SetOnlineTime(time)
	self.online_time = time
end

function PackageData:GetOnlineTime(time)
	return self.online_time or 0
end

--获取锁定格子的所需在线时间
function PackageData:GetNextKnapsackAutoAddTime()
	return self.auto_extend_need_online_time or 0 
end

--获取上一个已开启的格子的所需在线时间
function PackageData:GetBeforeKnapsackAutoAddTime()
	return self.before_auto_extend_need_online_time or 0
end

--重新从配置表获取开启格子所需在线时间
function PackageData:ResetKnapsackAutoNeedTime()
	if not self.auto_extend_times then return 0 end
	for k,v in pairs(self.knapsack_grid_auto_add_cfg) do
		if v.grid_index == self.auto_extend_times + 1 then
			self.auto_extend_need_online_time = v.online_time
		end
		if self.auto_extend_times > 0 then
			if v.grid_index == self.auto_extend_times then
				self.before_auto_extend_need_online_time = v.online_time
			end
		end
	end
end

function PackageData:SetRandGiftItemInfo(protocol)
	self.rand_gift_info = protocol.item_list
	for k,v in pairs(self.rand_gift_info) do
		local item_cfg, _ = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg and item_cfg.color then
			v.color = item_cfg.color
		end
	end

	table.sort(self.rand_gift_info, SortTools.KeyUpperSorter("color"))

	if next(self.rand_gift_list) == nil then 
		self.next_key = 1 	-- 首次展示的key，也是重置
		TipsCtrl.Instance:ShowGiftsRewardView(self.rand_gift_info)
	end

	table.insert(self.rand_gift_list, self.rand_gift_info)
	self.total_key = #self.rand_gift_list
end

function PackageData:GetRandGiftItemInfo()
	return self.rand_gift_info
end

function PackageData:GetRandGiftItemList()
	return #self.rand_gift_list or 0
end

function PackageData:SetNextRandGiftList()
	self.rand_gift_list = {}
end

function PackageData:SetNextRandGiftItem()
	self.next_key = self.next_key + 1
	if self.total_key and self.next_key <= self.total_key and self.rand_gift_list[self.next_key] then
		TipsCtrl.Instance:ShowGiftsRewardView(self.rand_gift_list[self.next_key])
	else
		self.rand_gift_list = {}
	end
end

-- 紫色珍惜道具，播放展示动画
function PackageData:IsCherishGoods(item_id)
	for _, v in pairs(self.knapsack_grid_zhenxi_zise_cfg) do
		if v.item_id == item_id then
			return true
		end
	end
	return false
end

function PackageData:IsNewItem(index)
	for _, v in pairs(self.new_item_list) do
		if v == index then
			return true
		end
	end
	return false
end

function PackageData:SetNewItemList(protocol)
	if nil == self.new_item_list[protocol.index] then
		self.new_item_list[protocol.index] = protocol.index
		local main_view = MainUICtrl.Instance:GetView()
		if main_view then
			local _, big_type = ItemData.Instance:GetNewItemConfig(protocol.item_id)
			if nil == big_type  then
				return
			end
			if big_type == GameEnum.PACKAGE_BIGTYPE_EXCHANGE and protocol.is_bind and protocol.is_bind == 0 then
				main_view:CheckPackageRedPoint(true)
			end
		end
	end
end

function PackageData:ClearNewItemList()
	self.new_item_list = {}
	local main_view = MainUICtrl.Instance:GetView()
	if main_view then
		main_view:CheckPackageRedPoint(false)
	end
end