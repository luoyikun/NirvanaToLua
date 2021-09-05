DisCountData = DisCountData or BaseClass()

-- 系统id，用于系统跳转到一折抢购, 对应配置表的-system_id
Sysetem_Id_Jump = 
{
	Xian_Nv = 1,
	Sheng_Mo = 2,
	Spirit = 3,
	Zhan_Hun = 4,
	Yi_Huo = 5,
	Long_Qi = 6,
	Sheng_Qi = 7,
	Xing_Hui = 8,
	Duan_Zao = 9,
	Sheng_Xiao = 10,
	Ming_Wen = 11,
}

function DisCountData:__init()
	if DisCountData.Instance ~= nil then
		ErrorLog("[DisCountData] Attemp to create a singleton twice !")
	end
	self.phase_list = {}
	self.new_phase_list = {}
	self.discount_cfg = ConfigManager.Instance:GetAutoConfig("discountbuycfg_auto") or {}
	self.phase_cfg = self.discount_cfg.phase_cfg or {}
	self.item_cfg = self.discount_cfg.item_cfg or {}

	self.discount_list = {}
	self.old_phase_list = {}

	self.can_active = false
	self.active_state = false
	self.have_new_discount = false      --是否有新的一折抢购
	self.is_first_enter = true
	self.is_first_fresh = true
	self.is_close_tips_right_view = true

	DisCountData.Instance = self
	RemindManager.Instance:Register(RemindName.DisCount, BindTool.Bind(self.SetMainViewRedPoint, self))
end


function DisCountData:Sort(data)
	local temp_data = data
	local sort_list = {}
	-- for k,v in pairs(temp_data) do
	-- 	if v.buy_count < v.buy_limit_count then
	-- 		table.insert(sort_list,v)
	-- 	end
	-- end

	-- for k,v in pairs(temp_data) do
	-- 	if v.buy_count >= v.buy_limit_count then
	-- 		table.insert(sort_list,v)
	-- 	end
	-- end
	if temp_data then
		for k,v in pairs(temp_data) do
			if v then
			-- 	v.is_all_buy_flag = v.buy_count < v.buy_limit_count and 0 or 1
			-- 	v.is_free = v.price <= 0 and 0 or 1
				table.insert(sort_list,v)
			end
		end
	end
	table.sort(sort_list, SortTools.KeyLowerSorters("is_all_buy_flag", "is_free", "item_seq"))
	return sort_list
end

function DisCountData:__delete()
	RemindManager.Instance:UnRegister(RemindName.DisCount)
	DisCountData.Instance = nil
	self.is_first_enter = true
end

--获取阶段数
function DisCountData:GetPaseCount()
	return #self.phase_cfg
end

--获取阶段名字
function DisCountData:GetPhaseNameByPhase(phase)
	local name = ""
	for _, v in ipairs(self.phase_cfg) do
		if v.phase == phase then
			name = v.name
			break
		end
	end
	return name
end

-- 根据系统类型，获取跳转index, 大小目标系统类型
function DisCountData:GetJumpIndexBySystemType(system_type)
	for i = 1, #self.new_phase_list do
		if self.new_phase_list[i].class_a_jump ~= nil and system_type == self.new_phase_list[i].class_a_jump then
			return i
		end
	end
	return -1
end

-- 根据系统类型，获取跳转index, 进阶类型
function DisCountData:GetJumpIndexBySystemTypeAdvance(system_type)
	for i = 1, #self.new_phase_list do
		if self.new_phase_list[i].show_title ~= nil and system_type == self.new_phase_list[i].show_title then
			return i
		end
	end
	return -1
end

-- 根据系统id判断是否开启一折抢购
function DisCountData:IsOpenYiZheBySystemId(system_id)
	for i = 1, #self.new_phase_list do
		if self.new_phase_list[i].system_id ~= nil and system_id == self.new_phase_list[i].system_id then
			return true, i, self.new_phase_list[i]
		end
	end
	return false, 1, nil
end

-- 根据系统获取一折的数据
function DisCountData:IsOpenYiZheAllBySystemId(system_id)
	local is_open, _, data_list = false, 1, {}
	data_list.system_index = {}
	for i = 1, #self.new_phase_list do
		if self.new_phase_list[i].system_id ~= nil and system_id == self.new_phase_list[i].system_id then
			is_open = true
			if self.new_phase_list[i].system_index then
				table.insert(data_list.system_index, self.new_phase_list[i].system_index)
			end
		end
	end
	return is_open, _, data_list
end

function DisCountData:SetPhaseList(list)
	self.phase_list = list
	self:SetNewPhaseList(list)
end

function DisCountData:GetPhaseList()
	return self.phase_list
end

function DisCountData:GetNewPhaseList()
	return self.new_phase_list
end

--清除缓存表
function DisCountData:ClearDiscountList()
	self.discount_list = {}
end

function DisCountData:GetHaveNewDiscount()
	return self.have_new_discount
end

function DisCountData:SetHaveNewDiscount(state)
	self.have_new_discount = state
end

function DisCountData:GetListNumByItemId(item_id)
	local select_list = {}
	local index = 0
	if self.new_phase_list then
		for k,v in pairs(self.new_phase_list) do
			if v and v.phase then
				local list = DisCountData.Instance:GetItemListByPhase(v.phase)
				if list then
					for m,n in pairs(list) do
						if n and n.reward_item and n.reward_item.item_id == item_id then
							table.insert(select_list, n)
							index = k
						end
					end
				end
			end
		end
	end

	if select_list and next(select_list) then
		table.sort(select_list, SortTools.KeyLowerSorters("is_all_buy_flag", "is_free", "item_seq"))
	end

	if self:IsAllBuyInList(select_list) and self.is_close_tips_right_view then
		select_list = {}
		index = 0
	end

	return select_list, index
end

function DisCountData:GetListNumByItemIdTwo(item_id)
	local select_list = {}
	local index = 0
	local phase = nil
	if self.new_phase_list then
		for k,v in pairs(self.new_phase_list) do
			if v and v.phase then
				local list = DisCountData.Instance:GetItemListByPhase(v.phase, true)
				if list then
					for m,n in pairs(list) do
						if n and n.reward_item and n.reward_item.item_id == item_id then
							table.insert(select_list, n)
							index = k
							phase = v.phase
						end
					end
				end
			end
		end
	end

	return select_list, index, phase
end

function DisCountData:IsAllBuyInList(list)
	if list then
		for k,v in pairs(list) do
			if v.is_all_buy_flag <= 0 then
				return false
			end
		end
	end
	return true
end

function DisCountData:IsCloseTipsRightView(enble)
	self.is_close_tips_right_view = enble
end

function DisCountData:SetNewPhaseList(list)
	--记录旧的表
	self.old_phase_list = self.new_phase_list
	self.new_phase_list = {}
	local server_time = TimeCtrl.Instance:GetServerTime()
	--先保存服务器发送过来的表
	for k1, v1 in ipairs(list) do
		if server_time < v1.close_timestamp then
			local temp_data1 = {}
			temp_data1.close_timestamp = v1.close_timestamp
			temp_data1.phase = k1 - 1
			temp_data1.show_title = -1
			temp_data1.phase_item_list = {}
			for k2, v2 in ipairs(v1.buy_count_list) do
				table.insert(temp_data1.phase_item_list, {buy_count = v2})
			end
			table.insert(self.new_phase_list, temp_data1)
		end
	end

	--在添加本地表
	for k, v in ipairs(self.new_phase_list) do
		local stage_list = self.phase_cfg[v.phase + 1]
		if nil ~= stage_list then
			v.phase = stage_list.phase
			v.active_level = stage_list.active_level
			v.last_time = stage_list.last_time
			v.phase_desc = stage_list.phase_desc
			v.model_show = stage_list.model_show
			v.special_show = stage_list.special_show
			v.effect_bundle = stage_list.effect_bundle
			v.effect_asset = stage_list.effect_asset
			v.effect_pos = stage_list.effect_pos
			v.effect_scale = stage_list.effect_scale
			v.show_title = stage_list.show_title
			v.icon = stage_list.icon
			v.system_id = stage_list.system_id
			v.system_index = stage_list.system_index
			v.button_name = stage_list.button_name
 			v.class_a_jump = stage_list.class_a_jump
 			v.tab_act_icon = stage_list.tab_act_icon
		end
	end

	local value = DailyChargeData.Instance:GetLeiJiChongZhiValue()
	--添加每个物品的数据
	for k1, v1 in ipairs(self.new_phase_list) do
		for k2, v2 in pairs(self.item_cfg) do
			if v2.phase == v1.phase then
				local phase_item_list = v1.phase_item_list
				if phase_item_list[v2.item_seq+1] and value >= v2.limit_charge_min and (
					value < v2.limit_charge_max or v2.limit_charge_max == -1) then
					local data = phase_item_list[v2.item_seq+1]
					data.seq = v2.seq
					data.item_seq = v2.item_seq
					data.price = v2.price
					data.show_price = v2.show_price
					data.buy_limit_count = v2.buy_limit_count
					data.reward_item = v2.reward_item
				end
			end
		end
	end

	--清空每个阶段不存在的物品
	for k, v in ipairs(self.new_phase_list) do
		local phase_item_list = v.phase_item_list
		for i = #phase_item_list, 1, -1 do
			local data = phase_item_list[i]
			if nil == data.buy_limit_count then
				table.remove(phase_item_list, i)
			end
		end
	end

	--清除已经卖完的阶段
	for i = #self.new_phase_list, 1, -1 do
		local temp_phase_info = self.new_phase_list[i]
		if nil ~= temp_phase_info then
			for k, v in pairs(temp_phase_info) do
				if k == "phase_item_list" then
					local sell_out_count = 0
					for k1, v1 in ipairs(v) do
						if v1.buy_count >= v1.buy_limit_count then
							sell_out_count = sell_out_count + 1
						end
					end
					if sell_out_count >= #v then
						table.remove(self.new_phase_list, i)
						break
					end
				end
			end
		end
	end
	--判断是否有新的一折抢购
	self.have_new_discount = false
	if not self.is_first_enter and #self.old_phase_list < #self.new_phase_list then
		self.have_new_discount = true
	end

	-- RemindManager.Instance:Fire(RemindName.DisCount)
end

function DisCountData:CheckCanActive()
	local can_active = false
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local level = main_vo.level
	local server_time = TimeCtrl.Instance:GetServerTime()
	for k, v in ipairs(self.new_phase_list) do
		if can_active then
			break
		end
		if level >= v.active_level then
			if v.close_timestamp > server_time then
				for k1, v1 in ipairs(v.phase_item_list) do
					if v1.buy_count < v1.buy_limit_count then
						can_active = true
						break
					end
				end
			end
		end
	end
	return can_active
end

function DisCountData.SortList(tbl1, tbl2)
	if tbl1.is_sell_out == tbl2.is_sell_out then
		return tbl1.seq < tbl2.seq
	else
		return tbl1.is_sell_out < tbl2.is_sell_out
	end
end

--先记录刷新的列表
function DisCountData:SetRefreshList()
	self.discount_list = self.new_phase_list
end

function DisCountData:SetIsFirstFresh(enble)
	self.is_first_fresh = enble
end

--获取刷新后的列表（数据量无变化）
function DisCountData:GetRefreshList()
	if self.discount_list then
		for k, v in ipairs(self.discount_list) do
			local temp_phase_info = self.phase_list[v.phase + 1]
			if nil ~= temp_phase_info and v.phase_item_list then
				-- for k1, v1 in ipairs(v.phase_item_list) do
				-- 	v1.buy_count = temp_phase_info.buy_count_list[k1]
				-- 	v1.is_all_buy_flag = v1.buy_count < v1.buy_limit_count and 0 or 1
				-- 	v1.is_free = v1.price <= 0 and 0 or 1
				-- end
				local list = v.phase_item_list
				for i = #list, 1, -1 do
					if list[i] then
						local index = list[i].item_seq and list[i].item_seq + 1 or 0
						list[i].buy_count = temp_phase_info.buy_count_list[index]
						list[i].is_all_buy_flag = list[i].buy_count < list[i].buy_limit_count and 0 or 1
						list[i].is_free = list[i].price <= 0 and 0 or 1
						local server_time = TimeCtrl.Instance:GetServerTime()
						local time = temp_phase_info.close_timestamp - server_time						
						list[i].has_time_out = time <= 0 and 1 or 0
						if list[i].is_free == 0 and list[i].is_all_buy_flag == 1 then
							table.remove(v.phase_item_list, i)
						end
					end
				end
			end
		end
	end
	return self.discount_list
end

function DisCountData:IsShowMainDiscountRedPoint()
	if self.is_first_fresh then
		self:SetRefreshList()
	end
	local list = self:GetRefreshList()
	if list then
		for k,v in pairs(list) do
			if v and v.phase_item_list then
				for k1,v1 in pairs(v.phase_item_list) do
					if v1 and v1.is_free <= 0 and v1.is_all_buy_flag <= 0 and v1.has_time_out == 0 then
						return true
					end
				end
			end
		end
	end
	return false
end

function DisCountData:GetIsFreeShowRedPointByPhase(phase)
	local list = self:GetRefreshList()
	if phase and list then
		for k,v in pairs(list) do
			if v.phase == phase then
				for k1,v1 in pairs(v.phase_item_list) do
					if v1 and v1.is_free <= 0 and v1.is_all_buy_flag <= 0 and v1.has_time_out == 0 then
						return true
					end
				end
			end
		end
	end
	return false
end

function DisCountData:GetDiscountInfoByType(phase, init)
	local data = self.new_phase_list
	if not init then
		data = self:GetRefreshList()
	end
	data = data or {}
	for k,v in ipairs(data) do
		if phase == v.phase then
			return v, k
		end
	end
	return nil
end

function DisCountData:GetDiscountInfoByTypeNoneRefresh(phase, init)
	local data = self.new_phase_list
	data = data or {}
	for k,v in ipairs(data) do
		if phase == v.phase then
			return v, k
		end
	end
	return nil
end

--获取每个阶段对应的物品列表
function DisCountData:GetItemListByPhase(phase, init)
	local data = self.new_phase_list
	if not init then
		data = self:GetRefreshList()
	end
	data = data or {}
	for k,v in ipairs(data) do
		if phase == v.phase then
			return v.phase_item_list
		end
	end
	return {}
end

function DisCountData:SetCanActive(enable)
	self.can_active = enable
end

function DisCountData:GetCanActive()
	return self.can_active
end


function DisCountData:GetActiveState()
	return self.active_state
end

--设置当前一折抢购状态
function DisCountData:SetActiveState(state)
	self.active_state = state
end

--传闻显示的一折阶段
function DisCountData:SetPhaseIndex(phase)
	self.phase_index = phase
end

--通过传闻跳转的一折阶段
function DisCountData:GetPhaseIndex()
	if nil ~= self.phase_index and nil ~= self:GetDiscountInfoByTypeNoneRefresh(self.phase_index) then
		local v, k = self:GetDiscountInfoByTypeNoneRefresh(self.phase_index)
		return k
	end
	if nil == next(self.new_phase_list) then
		return 0
	end
	return 1
end

function DisCountData:SetIsFirstEnter(is_show)
	self.is_first_enter = is_show
end

function DisCountData:GetIsFirstEnter()
	return self.is_first_enter
end

function DisCountData:SetMainViewRedPoint()
	local is_has_free_reward = self:IsShowMainDiscountRedPoint() 			--策划说只要有免费就要出现光圈
	if is_has_free_reward then
		return 1
	end

	self.is_first_enter = not RemindManager.Instance:RemindToday(RemindName.DisCount)
	if self.is_first_enter then
		return 1
	end

	if self:GetHaveNewDiscount() then
		return 1
	end

	return 0
end

function DisCountData:CalTabItemCellRedPoint(phase_desc)
	local is_show_remind = next(self.old_phase_list) ~= nil
	for k,v in pairs(self.old_phase_list) do
		if phase_desc == v.phase_desc then
			is_show_remind = false
		end
	end
	return is_show_remind
end

function DisCountData:GetClassASmallTargetInfo(system_type)
	local info = {}
	if system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_RUNE then
		-- 战魂
		info = RuneData.Instance:GetGoalInfo()

	elseif system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANNV then
		-- 仙女
		info = GoddessData.Instance:GetGoalInfo()

	elseif system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANCHONG then
		-- 仙宠
		info = SpiritData.Instance:GetGoalInfo()

	elseif system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENZHOU_WEAPON then
		-- 异火
		info = HunQiData.Instance:GetGoalInfo()

	elseif system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGE then
		-- 星辉
		info = ShenGeData.Instance:GetGoalInfo()

	elseif system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENSHOU then
		-- 龙器
		info = ShenShouData.Instance:GetGoalInfo()

	elseif system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENYIN then
		-- 铭纹
		info = ShenYinData.Instance:GetGoalInfo()

	elseif system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_CHINESE_ZODIAC then
		-- 生肖
		info = ShengXiaoData.Instance:GetGoalInfo()

	elseif system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGQI then
		-- 圣器
		info = ShenShouData.Instance:GetShengQiGoalInfo()

	elseif system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_GREATESOLDIER then
		-- 神魔
		info = BianShenData.Instance:GetGoalInfo()

	end

	return info
end

function DisCountData:GetPhaseListBySystemId(index)
	local phare_list = {}
	for k, v in pairs(self.phase_cfg) do
		if v.class_a_jump and v.class_a_jump == index then
			phare_list[#phare_list + 1] = v.phase
		end
	end
	return phare_list
end
