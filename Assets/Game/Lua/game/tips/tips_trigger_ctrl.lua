TipsTriggerCtrl = TipsTriggerCtrl or BaseClass(BaseController)

function TipsTriggerCtrl:__init()
	-- 监听系统事件
	self.player_data_change_callback = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.player_data_change_callback)

	self.item_data_change_callback = BindTool.Bind1(self.OnItemDataChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_change_callback)
end

function TipsTriggerCtrl:__delete()
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_change_callback)
	self.item_data_change_callback = nil
	PlayerData.Instance:UnlistenerAttrChange(self.player_data_change_callback)
	self.player_data_change_callback = nil
end

--玩家数据改变时
function TipsTriggerCtrl:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "capability" and old_value > 0 then				--战斗力
		if value == nil or old_value == nil or value == old_value or math.floor(value - old_value) == 0 then
			return
		end
		-- 策划叫屏蔽战力下降提醒
		if value and value < old_value then
			return
		end
		if MainUICtrl.Instance:CanShowCapChange() then
			TipsCtrl.Instance:ShowPowerChange(value, old_value)
		end
		
		-- if not IS_ON_CROSSSERVER then
		-- 	TipsCtrl.Instance:ShowPowerChange(value, old_value)
		-- else
		-- 	-- 跨服的时候保留旧战力，避免回到本服的时候弹出战力变化
		-- 	local gamevo = GameVoManager.Instance:GetMainRoleVo()
		-- 	gamevo.capability = old_value
		-- end
	end
end

--物品数据改变时
function TipsTriggerCtrl:OnItemDataChange(item_id, index, reason, put_reason, old_num, new_num)
	-- if IS_ON_CROSSSERVER then 				-- 策划说屏蔽跨服不能快速使用
	-- 	return
	-- end

	local is_get = false
	new_num = new_num or 0
	old_num = old_num or 0

	if new_num > old_num then
		is_get = true
	end
	local is_tip_use = false
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(item_id)
	if big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT
		and nil ~= put_reason
		and ((put_reason == 0 and reason == 0) or put_reason == 2 or put_reason == 3 or put_reason == 4 or put_reason == PUT_REASON_TYPE.PUT_REASON_COMPOSE or put_reason == 6 or
			put_reason == 198 or put_reason == 8 or put_reason == 219 or put_reason == 7 or put_reason == 101 or put_reason == 375)
		and item_cfg.sub_type ~= 202 and item_cfg.sub_type ~= 201 then

		local gamevo = GameVoManager.Instance:GetMainRoleVo()
		-- if gamevo.level>= 20 and gamevo.level < 85 and ((gamevo.prof % 10) == item_cfg.limit_prof or item_cfg.limit_prof == 5) then
		-- 	local is_equip = EquipData.Instance:CheckIsAutoEquip(item_id, index)
		-- 	if is_equip then
		-- 		--装备物品
		-- 		local equip_cfg = ItemData.Instance:GetItemConfig(item_id)
		-- 		local bag_data = ItemData.Instance:GetItem(item_id)
		-- 		local equip_index = EquipData.Instance:GetEquipIndexByType(equip_cfg.sub_type)
		-- 		PackageCtrl.Instance:SendUseItem(bag_data.index, 1, equip_index, equip_cfg.need_gold)
		-- 	end
		-- elseif item_cfg and (gamevo.prof % 10) == item_cfg.limit_prof or item_cfg.limit_prof == 5 then
		-- 	TipsCtrl.Instance:ShowShorCutEquipView(item_id, index)
		-- end
		if item_cfg and (gamevo.prof % 10) == item_cfg.limit_prof or item_cfg.limit_prof == 5 then
			TipsCtrl.Instance:ShowShorCutEquipView(item_id, index)
		end
		return
	end

	if item_cfg ~= nil then
		if item_cfg.is_tip_use == 1 then
			is_tip_use = true
		end
	end

	local shenge_quality = ShenGeData.Instance:GetShenGeQualityByItemId(item_id)
	if is_get and shenge_quality and shenge_quality ~= -1 and shenge_quality <= 2 then
		PackageCtrl.Instance:SendUseItem(index, 1)
		return
	end 

	if item_cfg and item_cfg.is_diruse == 1 then 						 -- 宠物蛋采集特殊处理，立即使用,对奇遇一件完成会影响只好写死礼包id
		local index = ItemData.Instance:GetItemIndex(item_id)
		if index >= 0 and  old_num >= 0 and  new_num > 0 and item_id == 28871 and new_num > old_num then 
			PackageCtrl.Instance:SendUseItem(index, 1)
		end
	elseif is_tip_use and is_get then
		if put_reason and put_reason ~= PUT_REASON_TYPE.PUT_REASON_INVALID and put_reason ~= PUT_REASON_TYPE.PUT_REASON_NO_NOTICE then
			TipsCtrl.Instance:ShowGetNewItemView(item_id, new_num)
		end
	end
	local rune_id = OpenFunData.Instance:GetNoticeItemIdById(12) 				-- 符文功能预告物品直接使用
	if rune_id > 0 and rune_id == item_id then
		local data = ItemData.Instance:GetItem(rune_id)
		if data then
			PackageCtrl.Instance:SendUseItem(data.index, 1, data.sub_type)
		end
	end
end