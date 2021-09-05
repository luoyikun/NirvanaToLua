local _M = {}

local function openPanelByName(data, panel_name)
	if data and data.item_id == COMMON_CONSTS.GuildTanheItemId and PlayerData.Instance.role_vo.guild_id == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.PleaseJoinGuild)
		return
	end

	local item_id = nil
	if data then
		item_id = data.item_id
	end
	ViewManager.Instance:OpenByCfg(panel_name, data)
end

local function onOKCallBack(data, from_view, handle_type, handle_param_t, num)
	if nil == data then return end

	local item_num = tonumber(num)
	local maxnum = ItemData.Instance:GetItemNumInBagByIndex(data.index)

	if item_num > maxnum then
		item_num = maxnum
	end

	handle_param_t.num = item_num
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)

	if handle_type == TipsHandleDef.HANDLE_USE then
		PackageCtrl.Instance:SendUseItem(data.index, handle_param_t.num, data.sub_type, item_cfg.need_gold)
	elseif handle_type == TipsHandleDef.HANDLE_SALE then
		item_num = ItemData.Instance:GetItemNumInBagByIndex(data.index, data.item_id)
		PackageCtrl.Instance:SendDiscardItem(data.index, num, data.item_id, item_num, 0)
	elseif from_view == TipsFormDef.FROM_BAG_ON_GUILD_STORGE then
		if num == 1 then
			GuildCtrl.Instance:SendStorgetPutItem(data.index, num)
		else
			local ok_callback = function (out_num)
				GuildCtrl.Instance:SendStorgetPutItem(data.index, out_num)
			end
			TipsCtrl.Instance:OpenCommonInputView(ItemData.Instance:GetItemNumInBagByIndex(data.index), ok_callback, nil, num)
		end
	elseif from_view == TipsFormDef.FROM_STORGE_ON_GUILD_STORGE then
		if num == 1 then
			GuildCtrl.Instance:SendStorgetOutItem(data.index, num, data.item_id)
		else
			local ok_callback = function (out_num)
				GuildCtrl.Instance:SendStorgetOutItem(data.index, out_num, data.item_id)
			end
			TipsCtrl.Instance:OpenCommonInputView(ItemData.Instance:GetItemNumInBagByIndex(data.index), ok_callback, nil, num)
		end
	else
		if not PlayerCtrl.Instance.role_view:IsOpen() then
			PlayerCtrl.Instance.role_view:Open()
		end
		PlayerCtrl.Instance.role_view:HandleItemTipCallBack(data, handle_type, handle_param_t)
	end

end

local function onOpenPopNum(data, from_view, handle_type, handle_param_t)
	if nil == data then return end

	if nil == _M.pop_num_view then
		_M.pop_num_view = NumKeypad.New()
	end

	local maxnum = ItemData.Instance:GetItemNumInBagByIndex(data.index)

	if maxnum == 1 then  --数量为1时不弹
		onOKCallBack(data, from_view, handle_type, handle_param_t, maxnum)
	else
		if maxnum < 1 then
			maxnum = 1
		end
		_M.pop_num_view:Open()
		_M.pop_num_view:SetText(maxnum)
		_M.pop_num_view:SetMaxValue(maxnum)
		_M.pop_num_view:SetOkCallBack(BindTool.Bind(onOKCallBack, data, from_view, handle_type, handle_param_t))
	end

end

local common_operationstate_func = function(data, item_cfg, big_type, t, from_view)
	if from_view == TipsFormDef.FROM_BAG_EQUIP or
		from_view == TipsFormDef.FROM_CAMP_EQUIP or
		from_view == TipsFormDef.FROM_PLAYER_INFO then
		if MojieData.IsMojie(data.item_id) then
			if data.mojie_level and data.mojie_level > 0 then
				t[#t+1] = TipsHandleDef.HANDLE_SHENGJI
			else
				t[#t+1] = TipsHandleDef.HANDLE_JIHUO
			end
		elseif EquipData.IsMarryEqType(item_cfg.sub_type) then
			t[#t+1] = TipsHandleDef.HANDLE_TAKEOFF
		elseif EquipData.IsXiaoguiEqType(item_cfg.sub_type) then
			t[#t+1] = TipsHandleDef.HANDLE_XUFEI_EQUIP
			if data.index and data.index == 1 then
				local is_overdue = EquipData.Instance:GetGuoQiExpXiaoGui()
				if is_overdue then
					t[#t+1] = TipsHandleDef.HANDLE_TAKEOFF_EQUIP
				end
			else
				local is_overdue = EquipData.Instance:GetGuoQiGuardXiaoGui()
				if is_overdue then
					t[#t+1] = TipsHandleDef.HANDLE_TAKEOFF_EQUIP
				end
			end
		elseif item_cfg.sub_type ~= GameEnum.EQUIP_TYPE_GOUYU
			and not EquipData.Instance:IsBaiZhanEquipType(item_cfg.sub_type)
			and not CampData.IsCampEquip(item_cfg.sub_type)
			and item_cfg.sub_type ~= GameEnum.WQUIP_TYPE_SUPER1
			and item_cfg.sub_type ~= GameEnum.WQUIP_TYPE_SUPER2 then
			t[#t+1] = TipsHandleDef.HANDLE_FORGE
			-- t[#t+1] = TipsHandleDef.HANDLE_TAKEOFF
		end
		if from_view == TipsFormDef.FROM_PLAYER_INFO and EquipData.Instance:IsBaiZhanEquipType(item_cfg.sub_type) then
			t[#t+1] = TipsHandleDef.BAIZHANEQUIP_TAKEOFF
		end
	elseif from_view == TipsFormDef.FROM_SPIRIT_BAG then
		t[#t+1] = TipsHandleDef.HANDLE_TAKEOFF
	end
end

local common_doclickhandler_func = function(data, item_cfg, handle_type, from_view, handle_param_t)
	if from_view == TipsFormDef.FROM_SJ_JC_OFF then
		return
	end

	if handle_type == TipsHandleDef.HANDLE_BACK_BAG then 	--取出 从仓库取回到背包
		local index = -1
		local max_bag_grid_num = ItemData.Instance:GetMaxKnapsackValidNum()
		for i = 0, max_bag_grid_num - 1 do
			if nil == ItemData.Instance:GetGridData(i) then
				index = i
				break
			end
		end

		if index < 0 then
			TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
			return
		end
		if from_view == TipsFormDef.FROM_STORGE_ON_SPRITRT_STORGE then--item_cfg.sub_type == GameEnum.EQUIP_TYPE_JINGLING and
			SpiritCtrl.Instance:SendTakeOutJingLingReq(data.server_grid_index, 0, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING)
		elseif from_view == TipsFormDef.FROM_STORGE_ON_GUILD_STORGE then
			if data.num == 1 then
				GuildCtrl.Instance:SendStorgetOutItem(data.index, data.num, data.item_id)
			else
				local ok_callback = function (out_num)
					GuildCtrl.Instance:SendStorgetOutItem(data.index, out_num, data.item_id)
				end
				TipsCtrl.Instance:OpenCommonInputView(ItemData.Instance:GetItemNumInBagByIndex(data.index), ok_callback, nil, data.num)
			end


		else
			PackageCtrl.Instance:SendRemoveItem(data.index, index)-- + COMMON_CONSTS.MAX_BAG_COUNT
			print("取出  从仓库取回到背包==========", "index =========",index, "data.index =========", c)
		end
	elseif handle_type == TipsHandleDef.HANDLE_TAKEOFF then
		if CampData.IsCampEquip(item_cfg.sub_type) then
			CampCtrl.Instance:SendCampEquipOperate(CAMPEQUIP_OPERATE_TYPE.CAMPEQUIP_OPERATE_TYPE_TAKEOFF, handle_param_t.fromIndex)
		elseif from_view == TipsFormDef.FROM_SPIRIT_BAG then
			SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_TAKEOFF,
				data.index, 0, 0, 0, item_cfg.name)
		elseif EquipData.IsMarryEqType(item_cfg.sub_type) then
			MarryEquipCtrl.SendTakeOffQingyuanEquip(handle_param_t.fromIndex)
		elseif DouQiData.Instance:IsDouqiEqupi(data.item_id) then
			local douqi_equip_cfg = DouQiData.Instance:GetDouqiEquipCfg(data.item_id)
			if douqi_equip_cfg then
				DouQiCtrl.Instance:SendCSCrossEquipOpera(CROSS_EQUIP_REQ_TYPE.CROSS_EQUIP_REQ_TAKEOFF, douqi_equip_cfg.equip_index)
			end
		else
			PlayerCtrl.Instance:HandleItemTipCallBack(data, handle_type, handle_param_t, item_cfg)
		end
	end
end

local operationState =
{	-- func(data, item_cfg, big_type, handler_types, from_view) ITEM_BIGTYPE_EXPENSE
	--在背包界面中（没有打开仓库和出售）
	[TipsFormDef.FROM_BAG] = function(data, item_cfg, big_type, t)
		local prof = PlayerData.Instance:GetRoleBaseProf() or 0
		if data then
			if big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and math.floor(item_cfg.sub_type / 100) < 9 and not EquipData.IsXiaoguiEqType(item_cfg.sub_type)
				or (item_cfg.sub_type and EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type))
				or (item_cfg.sub_type and EquipData.Instance:IsBaiZhanEquipType(item_cfg.sub_type))
				or EquipData.IsMarryEqType(item_cfg.sub_type) then	--装备类型
				if prof == item_cfg.limit_prof or item_cfg.limit_prof == 5 then
					if item_cfg.sub_type == GameEnum.EQUIP_TYPE_JINGLING then
						t[#t+1] = TipsHandleDef.HANDLE_USE
					else
						t[#t+1] = TipsHandleDef.HANDLE_EQUIP
					end
				end
				if EquipData.IsXiaoguiEqType(item_cfg.sub_type) and t[#t] then
					local invalid_time = data.invalid_time - TimeCtrl.Instance:GetServerTime()
					if invalid_time > 0 then
						t[#t] = TipsHandleDef.HANDLE_EQUIP
					else
						t[#t] = TipsHandleDef.HANDLE_XUFEI_EQUIP
					end
				end
				if (item_cfg.sub_type and EquipData.Instance:IsBaiZhanEquipType(item_cfg.sub_type)) and ComposeData.Instance:GetProductCfg(data.item_id) then
					t[#t+1] = TipsHandleDef.HANDLE_COMPOSE
				end				
				if 0 == data.is_bind and not EquipData.IsMarryEqType(item_cfg.sub_type) then
					local is_open = OpenFunData.Instance:CheckIsHide("sendgift")
					if is_open then
						t[#t+1] = TipsHandleDef.HANDLE_SEND_GIFT
					end					
					t[#t+1] = TipsHandleDef.HANDLE_SALE
				end
				if item_cfg.cansell == 1 or EquipData.IsMarryEqType(item_cfg.sub_type) then
					if not EquipData.IsJLType(item_cfg.sub_type) and not EquipData.Instance:IsCommonEquipType(item_cfg.sub_type) and not EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type) then
						t[#t+1] = TipsHandleDef.HANDLE_RECOVER_SPIRIT
					end
				end
				-- 转生装备分解
				if EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type) then
					t[#t+1] = TipsHandleDef.HANDLE_DECOMPOSE
				end
			elseif big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and math.floor(item_cfg.sub_type / 100) == 9 then
				t[#t+1] = TipsHandleDef.HANDLE_USE
				t[#t+1] = TipsHandleDef.HANDLE_RECOVER_SPIRIT
			elseif PlayerData.Instance:GetItemIsSealByItemId(item_cfg.id) then 
				t[#t+1] = TipsHandleDef.HANDLE_USE
				if 0 == data.is_bind then
					local is_open = OpenFunData.Instance:CheckIsHide("sendgift")
					if is_open then
						t[#t+1] = TipsHandleDef.HANDLE_SEND_GIFT
					end					
					t[#t+1] = TipsHandleDef.HANDLE_SALE
				end				
			elseif EquipData.IsLittlePetToyType(item_cfg.sub_type) then
				t[#t+1] = TipsHandleDef.HANDLE_USE
				if 0 == data.is_bind then
					local is_open = OpenFunData.Instance:CheckIsHide("sendgift")
					if is_open then
						t[#t+1] = TipsHandleDef.HANDLE_SEND_GIFT
					end					
					t[#t+1] = TipsHandleDef.HANDLE_SALE
				end				
				-- t[#t+1] = TipsHandleDef.HANDLE_RECOVER_SPIRIT
			elseif EquipData.IsShengXiaoEqType(item_cfg.sub_type) then
				t[#t+1] = TipsHandleDef.HANDLE_EQUIP
				if 0 == data.is_bind then
					local is_open = OpenFunData.Instance:CheckIsHide("sendgift")
					if is_open then
						t[#t+1] = TipsHandleDef.HANDLE_SEND_GIFT
					end					
					t[#t+1] = TipsHandleDef.HANDLE_SALE
				end				
			elseif EquipData.IsBianShenEquipType(item_cfg.sub_type) then
				t[#t+1] = TipsHandleDef.HANDLE_EQUIP
				if 0 == data.is_bind then
					local is_open = OpenFunData.Instance:CheckIsHide("sendgift")
					if is_open then
						t[#t+1] = TipsHandleDef.HANDLE_SEND_GIFT
					end					
					t[#t+1] = TipsHandleDef.HANDLE_SALE
				end				
				-- t[#t+1] = TipsHandleDef.HANDLE_RECOVER
			elseif EquipData.IsLongQiEqType(item_cfg.sub_type) then
				t[#t+1] = TipsHandleDef.HANDLE_EQUIP
				if 0 == data.is_bind then
					local is_open = OpenFunData.Instance:CheckIsHide("sendgift")
					if is_open then
						t[#t+1] = TipsHandleDef.HANDLE_SEND_GIFT
					end					
					t[#t+1] = TipsHandleDef.HANDLE_SALE
				end				
			elseif EquipData.IsLittlePetEqType(item_cfg.sub_type) then
				t[#t+1] = TipsHandleDef.HANDLE_EQUIP
				-- t[#t+1] = TipsHandleDef.HANDLE_RECOVER_SPIRIT
			elseif EquipData.IsXiaoguiEqType(item_cfg.sub_type) then
				t[#t+1] = TipsHandleDef.HANDLE_EQUIP
				t[#t+1] = TipsHandleDef.HANDLE_RECOVER
			else
				if item_cfg.click_use >= 1 or (item_cfg.click_use == 0 and item_cfg.open_panel ~= "" and item_cfg.open_panel ~= 0) then
					t[#t+1] = TipsHandleDef.HANDLE_USE
				end
				if ComposeData.Instance:GetProductCfgEnoughLevel(data.item_id) then
					t[#t+1] = TipsHandleDef.HANDLE_COMPOSE
				end
				if 0 == data.is_bind then
					local is_open = OpenFunData.Instance:CheckIsHide("sendgift")
					if is_open then
						t[#t+1] = TipsHandleDef.HANDLE_SEND_GIFT
					end					
					t[#t+1] = TipsHandleDef.HANDLE_SALE
				end
				-- if SpiritData.Instance:CanReCyWuXing(data.item_id) then
				-- 	t[#t+1] = TipsHandleDef.HANDLE_RECOVER_SPIRIT
				-- end
				
				if SymbolData.Instance:CanDecomposeItem(data.item_id) then
					t[#t+1] = TipsHandleDef.HANDLE_YUANZHUANG
				end

				if item_cfg.recycltype ~= 0 and item_cfg.recyclget > 0 then
					t[#t+1] = TipsHandleDef.HANDLE_SELL
				elseif item_cfg.cansell == 1 then
					t[#t+1] = TipsHandleDef.HANDLE_RECOVER
				end
			end
		end
	end,
	--打开仓库界面时，来自背包
	[TipsFormDef.FROM_BAG_ON_BAG_STORGE] = function(data, item_cfg, big_type, t)
		t[#t+1] = TipsHandleDef.HANDLE_STORGE
	end,
	--打开仓库界面时，来自仓库
	[TipsFormDef.FROM_STORGE_ON_BAG_STORGE] = function(data, item_cfg, big_type, t)
		t[#t+1] = TipsHandleDef.HANDLE_BACK_BAG
	end,
	--打开售卖界面时，来自背包
	[TipsFormDef.FROM_BAG_ON_BAG_SALE] = function(data, item_cfg, big_type, t)
		if item_cfg.recycltype ~= 0 and big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT then
			t[#t+1] = TipsHandleDef.HANDLE_RECOVER
		end
	end,
	--打开售卖界面时，来自背包
	[TipsFormDef.FROM_BAG_ON_BAG_SALE_JL] = function(data, item_cfg, big_type, t)
		if item_cfg.recycltype ~= 0 and big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT then
			t[#t+1] = TipsHandleDef.HANDLE_RECOVER
		end
	end,
	[TipsFormDef.CANGKUEQUIP_EXCHANGE] = function(data, item_cfg, big_type, t)
		local spec_id = GuildData.Instance:GetGuildConfig().storage_constant_item_id or 22703
		if EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type) or data.item_id == spec_id then
			t[#t+1] = TipsHandleDef.CANGKUEQUIP_EXCHANGE
		end
	end,
	--打开装备界面时，来自装备
	-- [TipsFormDef.FROM_BAG_EQUIP] = common_operationstate_func,
	[TipsFormDef.FROM_SJ_JC_OFF] = common_operationstate_func,
	[TipsFormDef.FROM_PLAYER_INFO] = common_operationstate_func,
	[TipsFormDef.FROM_CAMP_EQUIP] = common_operationstate_func,
	--打开宝箱界面时，来自宝箱
	[TipsFormDef.FROM_BAOXIANG] = function(data, item_cfg, big_type, t)
		t[#t+1] = TipsHandleDef.BAOXIANG_QUCHU
	end,
	[TipsFormDef.FROM_MARKET_JISHOU] = function(data, item_cfg, big_type, t)
		t[#t + 1] = TipsHandleDef.SHICHANG_CHEHUI
	end,
	[TipsFormDef.FROME_MARKET_GOUMAI] = function(data, item_cfg, big_type, t)
		t[#t + 1] = TipsHandleDef.SHICHANG_GOUMAI
	end,

	--来自生肖背包
	[TipsFormDef.FROM_SHENGXIAO_BAG] = function(data, item_cfg, big_type, t)
		t[#t+1] = TipsHandleDef.HANDLE_EQUIP
		-- t[#t+1] = TipsHandleDef.HANDLE_COMPOSE
	end,
	--来自仙盟背包
	[TipsFormDef.FROM_BAG_ON_GUILD_STORGE] = function(data, item_cfg, big_type, t)
		t[#t + 1] = TipsHandleDef.HANDLE_TAKEON
	end,
	--来自卡牌升级
	[TipsFormDef.FROM_CARD_UP] = function(data, item_cfg, big_type, t)
		t[#t+1] = TipsHandleDef.HANDLE_RECOVER
	end,
	--来自仙盟仓库
	[TipsFormDef.FROM_STORGE_ON_GUILD_STORGE] = function(data, item_cfg, big_type, t)
		t[#t + 1] = TipsHandleDef.HANDLE_BACK_BAG
	end,
	[TipsFormDef.FROM_SHENZHOU_EQUIP] = function(data, item_cfg, big_type, t)
	end,
	[TipsFormDef.FROM_MAGICCARD_JIHUO] = function(data, item_cfg, big_type, t)
	end,
	--来自寻宝取出
	[TipsFormDef.FROM_XUNBAO_QUCHU] = function(data, item_cfg, big_type, t)
		t[#t + 1] = TipsHandleDef.HANDLE_TAKEOFF
	end,
	-- 精灵背包
	[TipsFormDef.FROM_SPIRIT_BAG] = function(data, item_cfg, big_type, t)
		if big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT then
			t[#t + 1] = TipsHandleDef.HANDLE_EQUIP
		else
			t[#t + 1] = TipsHandleDef.HANDLE_USE
		end
		if 0 == data.is_bind then
			local is_open = OpenFunData.Instance:CheckIsHide("sendgift")
			if is_open then
				t[#t+1] = TipsHandleDef.HANDLE_SEND_GIFT
			end			
			t[#t+1] = TipsHandleDef.HANDLE_SALE
		end
		if 1 == item_cfg.cansell then
			-- t[#t+1] = TipsHandleDef.HANDLE_RECOVER_SPIRIT
		end
	end,
	-- 来自精灵仓库
	[TipsFormDef.FROM_STORGE_ON_SPRITRT_STORGE] = function(data, item_cfg, big_type, t)
		t[#t+1] = TipsHandleDef.HANDLE_BACK_BAG
		if 1 == item_cfg.cansell then
			-- t[#t+1] = TipsHandleDef.HANDLE_RECOVER_SPIRIT
		end
	end,
	-- 来自快速使用
	[TipsFormDef.FROM_QUICK_USE] = function(data, item_cfg, big_type, t)
		t[#t+1] = TipsHandleDef.HANDLE_USE end,
	-- 来自转生装备
	[TipsFormDef.FROM_ZHUANSHENG_VIEW] = function(data, item_cfg, big_type, t)
		t[#t+1] = TipsHandleDef.HANDLE_TAKEOFF
	end,

	[TipsFormDef.FROM_SHENYIN_BAG] = function(data, item_cfg, big_type, t)
		if ShenYinData.Instance:GetIsShenYinRecycleItem(data.item_id) then
			t[#t+1] = TipsHandleDef.HANDLE_SHENYIN_RECOVER
		end
	end,

	[TipsFormDef.FROM_SHENYIN_LIEHUN] = function(data, item_cfg, big_type, t)
		if ShenYinData.Instance:GetIsShenYinRecycleItem(data.item_id) then
			t[#t+1] = TipsHandleDef.HANDLE_SHENYIN_LIEHUN_TAKBON
			t[#t+1] = TipsHandleDef.HANDLE_SHENYIN_LIEHUN_RECOVER
		end
	end,

	[TipsFormDef.FROM_TALENT_EQUIP] = function(data, item_cfg, big_type, t)
		if ImageFuLingData.Instance:IsBagTalentBookItems(data.item_id) then
			t[#t+1] = TipsHandleDef.HANDLE_TALENT_EQUIP
		end
	end,

	[TipsFormDef.FORM_CHONG_WU_WAREHOUSE] = function(data, item_cfg, big_type, t)
		t[#t+1] = TipsHandleDef.HANDLE_CHONGWU end,
	--来自生肖装备
	[TipsFormDef.FROM_SHENGXIAO_EQUIP] = function(data, item_cfg, big_type, t)
		t[#t+1] = TipsHandleDef.HANDLE_REPLACE
		t[#t+1] = TipsHandleDef.HANDLE_SHENGXIAO_TAKEOFF
	end,
	-- 来自变身装备
	[TipsFormDef.FROM_BIANSHEN_EQUIP] = function(data, item_cfg, big_type, t)
		t[#t+1] = TipsHandleDef.HANDLE_REPLACE
		t[#t+1] = TipsHandleDef.HANDLE_BIANSHEN_TAKEOFF
	end,
	-- 来自周末装备
	[TipsFormDef.TIANSHENHUTI_BAG] = function(data, item_cfg, big_type, t)
		t[#t+1] = TipsHandleDef.HANDLE_EQUIP
	end,
	-- 来自周末装备穿戴身上的
	[TipsFormDef.TIANSHENHUTI_EQUIP_ITEM] = function(data, item_cfg, big_type, t)
		t[#t+1] = TipsHandleDef.TIANSHENHUTI_EQUIP_TAKEOFF
	end,
	-- 来自斗气界面
	[TipsFormDef.FROM_DOUQI_VIEW] = function(data, item_cfg, big_type, t)
		t[#t+1] = TipsHandleDef.HANDLE_EQUIP
	end,
	[TipsFormDef.FROM_DOUQI_VIEW_TAKEOFF] = function(data, item_cfg, big_type, t)
		t[#t+1] = TipsHandleDef.HANDLE_TAKEOFF
	end,
}

local doClickHandler =
{
	--装备

	[TipsHandleDef.HANDLE_EQUIP] = function (data, item_cfg, handle_type, from_view)
		if data.item_id == 12100 then
		-- 结婚戒指
			if MarriageData.Instance:GetRingHadActive() then
				local item = MarriageData.Instance.decompose_item
				if item == nil then
					return
				end
				local describe = string.format(Language.Marriage.Ring_Fenjie, item.num)
				local fun = function()
					PackageCtrl.Instance:SendDiscardItem(data.index, 1, data.item_id, 1, 1)
				end
				TipsCtrl.Instance:ShowCommonAutoView(nil, describe, fun, nil, nil, nil, nil, nil, true, false)
			else
				PackageCtrl.Instance:SendUseItem(data.index, 1, data.sub_type, item_cfg.need_gold)
				return
			end
		end
		if item_cfg.sub_type and item_cfg.sub_type < 200 and item_cfg.sub_type ~= GameEnum.EQUIP_TYPE_JINGLING then
			local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
			if equip_index ~= -1 then
				local yes_func = function ()
					PackageCtrl.Instance:SendUseItem(data.index, 1, equip_index, item_cfg.need_gold)
				end
				local equip_suit_type = ForgeData.Instance:GetCurEquipSuitType(equip_index)
				if equip_suit_type ~= 0 then
					local equip_list = EquipData.Instance:GetDataList()
					local equip_suit_id = ForgeData.Instance:GetSuitIdByItemId(equip_list[equip_index].item_id)
					local item_suit_id = ForgeData.Instance:GetSuitIdByItemId(item_cfg.id)
					if equip_suit_id ~= 0 and item_suit_id ~= 0 and equip_suit_id == item_suit_id then
						PackageCtrl.Instance:SendUseItem(data.index, 1, equip_index, item_cfg.need_gold)
					else
						TipsCtrl.Instance:ShowCommonAutoView("", Language.Forge.ReturnSuitRock, yes_func)
					end
				else
					PackageCtrl.Instance:SendUseItem(data.index, 1, equip_index, item_cfg.need_gold)
				end
			end
		elseif item_cfg.sub_type == GameEnum.EQUIP_TYPE_JINGLING_SOUL then
			ViewManager.Instance:Open(ViewName.SpiritView, TabIndex.spirit_soul)
		elseif item_cfg.sub_type == GameEnum.EQUIP_TYPE_JINGLING then
			if from_view == TipsFormDef.FROM_SPIRIT_BAG then
				PackageCtrl.Instance:SendUseItem(data.index, 1, SpiritData.Instance:GetSpiritItemIndex(), item_cfg.need_gold)
			else
				ViewManager.Instance:Close(ViewName.Player)
				ViewManager.Instance:Open(ViewName.SpiritView, TabIndex.spirit_spirit)
				PackageCtrl.Instance:SendUseItem(data.index, 1, SpiritData.Instance:GetSpiritItemIndex(), item_cfg.need_gold)
			end
		elseif EquipData.IsMarryEqType(item_cfg.sub_type) then
			PackageCtrl.Instance:SendUseItem(data.index, 1, MarryEquipData.GetMarryEquipIndex(item_cfg.sub_type), item_cfg.need_gold)
		elseif EquipData.IsXiaoguiEqType(item_cfg.sub_type) then
			if EquipData.IsBetterExchangeXiaoGui(data) then
				PackageCtrl.Instance:SendUseItem(data.index, 1, equip_index, item_cfg.need_gold)
			else
				TipsCtrl.Instance:ShowSystemMsg(Language.Tip.BetterEquipXiaogui)
			end
		elseif EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type) or EquipData.Instance:IsBaiZhanEquipType(item_cfg.sub_type) then
			PackageCtrl.Instance:SendUseItem(data.index, 1, data.sub_type, item_cfg.need_gold)
		elseif EquipData.IsLongQiEqType(item_cfg.sub_type) then -- 龙器装备
			ViewManager.Instance:Open(ViewName.ShenShou, TabIndex.shenshou_equip)
		elseif EquipData.IsLittlePetEqType(item_cfg.sub_type) then
			ViewManager.Instance:Open(ViewName.LittlePetView, TabIndex.little_pet_home)
		elseif EquipData.IsShengXiaoEqType(item_cfg.sub_type) then
			local role_vo = GameVoManager.Instance:GetMainRoleVo()
			if item_cfg.limit_level > role_vo.level then
				local str = string.format(Language.Common.FunOpenRoleLevelLimit, item_cfg.limit_level)
				return SysMsgCtrl.Instance:ErrorRemind(str)
			end
			if from_view == TipsFormDef.FROM_BAG then
				ViewManager.Instance:Open(ViewName.ShengXiaoView, TabIndex.shengxiao_equip)
			else
				local equip_index = ShengXiaoData.Instance:GetEquipListByindex()
				PackageCtrl.Instance:SendUseItem(data.index, 1, equip_index - 1)
			end
		elseif EquipData.IsBianShenEquipType(item_cfg.sub_type) and from_view == TipsFormDef.FROM_BAG then
			ViewManager.Instance:Open(ViewName.BianShenView, TabIndex.bian_shen_equip)
		elseif item_cfg.use_type == GameEnum.TIANSHENHUTI_EQUIP_USE_TYPE then
			TianshenhutiCtrl.SendTianshenhutiPutOn(data.index)
		elseif DouQiData.Instance:IsDouqiEqupi(data.item_id) then
			PackageCtrl.Instance:SendUseItem(data.index, 1, data.sub_type, item_cfg.need_gold)
		end
	end,
	--合成
	[TipsHandleDef.HANDLE_COMPOSE] = function(data, item_cfg, handle_type)
		local cfg = ComposeData.Instance:GetProductCfg(data.item_id)
		if cfg then
			local index = TabIndex.compose_stone
			if 2 == cfg.type then
				index = TabIndex.compose_jinjie
			elseif 3 == cfg.type then
				index = TabIndex.compose_other
			elseif 4 == cfg.type then
				index = TabIndex.compose_shengqi
			elseif 5 == cfg.type then
				index = TabIndex.compose_shenmo
			end
			ComposeData.Instance:SetToProductId(data.item_id)
			ViewManager.Instance:Open(ViewName.Compose, index, "all", data)
		end
	end,
	--兑换
	[TipsHandleDef.HANDLE_EXCHANGE] = function(data, item_cfg, handle_type)
	end,
	--存放
	[TipsHandleDef.HANDLE_STORGE] = function(data, item_cfg, handle_type)
		local index = -1
		local storage_index_max = ItemData.Instance:GetMaxStorageValidNum() + COMMON_CONSTS.MAX_BAG_COUNT - 1
		for i = COMMON_CONSTS.MAX_BAG_COUNT , storage_index_max do
			if nil == ItemData.Instance:GetGridData(i) then
				index = i
				break
			end
		end

		if index < 0 then
			TipsCtrl.Instance:ShowSystemMsg(Language.Role.StorgeFull)
			return
		end

		PackageCtrl.Instance:SendRemoveItem(data.index, index)
	end,
	[TipsHandleDef.HANDLE_SEND_GIFT] = function(data, item_cfg, handle_type)
		if IS_ON_CROSSSERVER then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.CantOpenInCross)
			return
		end	
		local is_open = OpenFunData.Instance:CheckIsHide("sendgift")
		if is_open then
			ViewManager.Instance:Open(ViewName.SendGiftView)
		end
	end,
	[TipsHandleDef.BAIZHANEQUIP_TAKEOFF] = function(data, item_cfg, handle_type)
		if EquipData.Instance:IsBaiZhanEquipType(item_cfg.sub_type) then
			local index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
			if index then
				ForgeCtrl.Instance:SendBaiZhanOpera(BAIZHAN_EQUIP_OPERATE_TYPE.BAIZHAN_EQUIP_OPERATE_TYPE_TAKE_OFF, index)
			end
		end
	end,
	[TipsHandleDef.CANGKUEQUIP_EXCHANGE] = function(data, item_cfg, big_type, t)
		if data.guild_warehouse_index and data.item_id and EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type) then
			GuildCtrl.Instance:SendStorgeOperate(GUILD_STORGE_OPERATE.GUILD_STORGE_OPERATE_TAKE_ITEM, data.guild_warehouse_index, 1, data.item_id)
		end
	end,
	[TipsHandleDef.HANDLE_SALE] = function(data, item_cfg, handle_type)
		if IS_ON_CROSSSERVER then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.CantOpenInCross)
			return
		end	
		ViewManager.Instance:Open(ViewName.QuickSell, nil, "all", data)
	end,
	--取出 从仓库取回到背包
	[TipsHandleDef.HANDLE_BACK_BAG] = common_doclickhandler_func,
	--取下
	[TipsHandleDef.HANDLE_TAKEOFF] = common_doclickhandler_func,
	--使用
	[TipsHandleDef.HANDLE_USE] = function(data, item_cfg, handle_type, from_view, handle_param_t)	
		local prof = PlayerData.Instance:GetRoleBaseProf() or 0
		if item_cfg.limit_prof and item_cfg.limit_prof ~= 5 and item_cfg.limit_prof ~= prof then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.ProfDif)
			return
		end
		if PlayerData.Instance.role_vo.level >= item_cfg.limit_level then
			-- 仙盟物资
			if item_cfg.id == 26909 then
				local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
				if guild_id < 1 then
					SysMsgCtrl.Instance:ErrorRemind(Language.Common.PleaseJoinGuild)
				else
					ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_info)
				end
				return
			-- 弹劾令牌
			elseif item_cfg.id == 26911 then
				local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
				if guild_id < 1 then
					SysMsgCtrl.Instance:ErrorRemind(Language.Common.PleaseJoinGuild)
					return
				end
				local post = GuildData.Instance:GetGuildPost()
				if post == GuildDataConst.GUILD_POST.TUANGZHANG then
					SysMsgCtrl.Instance:ErrorRemind(Language.Guild.GuildTanHeZiJi)
					return
				end
				local describe = Language.Guild.ConfirmTanHeMengZhuTip
				local yes_func = function() GuildCtrl.Instance:SendGuildCheckCanDelateReq() end
				TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
				return
			-- 仙盟增员卡
			elseif item_cfg.id == 26913 then
				local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id or 0
				if guild_id < 1 then
					SysMsgCtrl.Instance:ErrorRemind(Language.Common.PleaseJoinGuild)
					return
				else
					ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_info)
				end
				return
			elseif item_cfg.use_type == 87 and item_cfg.param1 >= 31 and item_cfg.param1 <= 34 then
				ViewManager.Instance:Open(ViewName.ShenShou, TabIndex.shenshou_fuling)
				return
			elseif item_cfg.id == 26617 or item_cfg.id == 26618 then
				ViewManager.Instance:Open(ViewName.Exchange, TabIndex.exchange_weiji)
				return
			-- 建会令牌
			elseif item_cfg.id == 26910 then
				local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
				if guild_id < 1 then
					ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_request, "CreateGuild", {true})
					return
				end
				ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_info)

			-- 公会改名卡
			elseif item_cfg.id == 26922 then
				local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
				if guild_id < 1 then
					SysMsgCtrl.Instance:ErrorRemind(Language.Common.PleaseJoinGuild)
					return
				end
				local post = GuildData.Instance:GetGuildPost()
				if post ~= GuildDataConst.GUILD_POST.TUANGZHANG then
					SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoPower)
					return
				end
				local describe = Language.Role.RenameGuildTxt
				local yes_func = function(new_name) GuildCtrl.Instance:SendResetNameReq(guild_id, new_name) end
				TipsCtrl.Instance:ShowRename(yes_func, nil, 26922, nil, describe)
				return
			-- 角色改名卡
			elseif item_cfg.id == PlayerDataReNameItemId.ItemId then
				local callback = function (new_name)
					PlayerCtrl.Instance:SendRoleResetName(1, new_name)
				end
				TipsCtrl.Instance:ShowRename(callback, true, PlayerDataReNameItemId.ItemId)
				return
			-- -- 气泡框
			-- elseif item_cfg.id >= 27703 and item_cfg.id <= 27707 then
			-- 	ViewManager.Instance:Open(ViewName.CoolChat, TabIndex.bubble, "bubble", {index = item_cfg.id - 27703 + 1})
			-- 	return
			-- 铭纹
			elseif item_cfg.use_type == 88 and not ViewManager.Instance:IsOpen(ViewName.ShenYinView) then
				ViewManager.Instance:Open(ViewName.ShenYinView, TabIndex.shenyin_shenyin)
				return
			-- 圣印
			elseif item_cfg.use_type == 96 and not ViewManager.Instance:IsOpen(ViewName.Player) then
				ViewManager.Instance:Open(ViewName.Player, TabIndex.role_shengyin)
				return
			--婚戒材料
			elseif item_cfg.id == 27406 then
				local lover_uid = GameVoManager.Instance:GetMainRoleVo().lover_uid
				if lover_uid <= 0 then
					SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.NotMarryToRingDes)
					return
				end
			elseif item_cfg.open_panel == "BaoBaoLongFengTipsView" then
				local is_open = BaobaoData.Instance:ShowLongFengTab()
				if is_open then
					ViewManager.Instance:Open(item_cfg.open_panel)
				else
					SysMsgCtrl.Instance:ErrorRemind(Language.MarryBaoBao.GetLongFenTips)
					return
				end
			elseif ForgeData.Instance:CheckIsSuitRock(data.item_id) then
			--使用套装石（跳转到锻造套装界面）
				ViewManager.Instance:Open(ViewName.Forge, TabIndex.forge_suit)
				return
			elseif data.item_id == 27689 then
			--使用套装石碎片
				print_log("使用套装石碎片")
				ViewManager.Instance:Open(ViewName.Compose)
			elseif data.item_id == 27800 or data.item_id == 27801 or data.item_id == 27802 or data.item_id == 27803 then
				-- 开服集字活动
				if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION) then
					TipsCtrl.Instance:ShowSystemMsg(Language.OpenServer.RollActivityEnd)
					return
				elseif not ActivityData.Instance:GetIsOpenLevel(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION) then
					TipsCtrl.Instance:ShowSystemMsg(Language.OpenServer.ActivateNotOpen)
					return
				end

				if from_view == TipsFormDef.FROM_BAG then
					if ViewManager.Instance:IsOpen(ViewName.Player) then
						ViewManager.Instance:Close(ViewName.Player)
					end
				end
				ViewManager.Instance:Open(ViewName.KaifuActivityView, TabIndex.kaifu_jizi)
			elseif item_cfg.is_show_gift and item_cfg.is_show_gift == 1 then
				--符文宝箱
				RuneData.Instance:SetBaoXiangId(data.item_id)
				PackageCtrl.Instance:SendUseItem(data.index, handle_param_t.num, data.sub_type, item_cfg.need_gold)
				return
			elseif item_cfg.gift_type and item_cfg.gift_type == 4 then
				MojieData.Instance:SetModelGiftBagIndex(data.index)
				MojieData.Instance:SetModelGiftId(data.item_id)
				MojieData.Instance:SetModelGiftData(nil)
				MojieData.Instance:SetFromView(nil)
				ViewManager.Instance:Open(ViewName.ModelGift)
				return				
			elseif item_cfg.gift_type and item_cfg.gift_type == 3 then
				MojieData.Instance:SetMojieGiftBagIndex(data.index)
				MojieData.Instance:SetMojieGiftNum(data.num)
				MojieData.Instance:SetMojieGiftId(data.item_id)
				ViewManager.Instance:Open(ViewName.MojieGift)
				return
				--直升丹(太恶心了)
			elseif (data.item_id == 23237 and ShengongData.Instance:GetShengongInfo().grade < 6)
				or (data.item_id == 23238 and ShenyiData.Instance:GetShenyiInfo().grade < 6)
				or (data.item_id == 23234 and MountData.Instance:GetMountInfo().grade < 6)
				or (data.item_id == 23235 and WingData.Instance:GetWingInfo().grade < 6)
				or (data.item_id == 23236 and HaloData.Instance:GetHaloInfo().grade < 6) then
				local max_use_lv = ItemData.Instance:GetItemConfig(data.item_id).param2 - 1
				max_use_lv = CommonDataManager.GetDaXie(max_use_lv)
				local describe = string.format(Language.Competition.BiPin_text, max_use_lv)
				local call_back = function ()
					PackageCtrl.Instance:SendUseItem(data.index, handle_param_t.num, data.sub_type, item_cfg.need_gold)
				end
				TipsCtrl.Instance:ShowCommonAutoView("", describe, call_back, nil, nil)
				return
			-- BOSS刷新卡
			elseif data.item_id == 24605 then
				local scene_id = Scene.Instance:GetSceneId()
				BossData.Instance:UseFlushCard(scene_id)
			elseif item_cfg.use_type == GameEnum.USE_TYPE_LITTLE_PET then
				-- 超级小宠物直接使用，放在宠物位置第6位
				-- if data.item_id == LittlePetData.Instance:GetSpecialLittlePetItemID() then
				-- 	LittlePetCtrl.Instance:SendLittlePetREQ(LITTLE_PET_REQ_TYPE.LITTLE_PET_PUTON, GameEnum.LITTLE_PET_SPECIAL_INDEX - 1, data.index)
				-- 	return
				-- end
				if IS_ON_CROSSSERVER then
					SysMsgCtrl.Instance:ErrorRemind(Language.Common.CantOpenInCross)
					return
				end
				ViewManager.Instance:Open(ViewName.LittlePetView, TabIndex.little_pet_home)
				ViewManager.Instance:Close(ViewName.Player)
				return
			elseif EquipData.IsLittlePetToyType(item_cfg.sub_type) then
				if IS_ON_CROSSSERVER then
					SysMsgCtrl.Instance:ErrorRemind(Language.Common.CantOpenInCross)
					return
				end
				ViewManager.Instance:Open(ViewName.LittlePetView, TabIndex.little_pet_toy)
				ViewManager.Instance:Close(ViewName.Player)
				return
			elseif PlayerData.Instance:GetItemIsSealByItemId(item_cfg.id) then 
				PackageCtrl.Instance:SendUseItem(data.index, handle_param_t.num, data.sub_type, item_cfg.need_gold)
				return 
			elseif DouQiData.Instance:IsDouqiEqupi(data.item_id) then
				if not OpenFunData.Instance:CheckIsHide("douqi_view") then
					SysMsgCtrl.Instance:ErrorRemind(Language.Douqi.NoOpenSystem)
				else
					if IS_ON_CROSSSERVER then
						SysMsgCtrl.Instance:ErrorRemind(Language.Common.CantOpenInCross)
						return
					end
					-- ViewManager.Instance:Open(ViewName.DouQiView)
					PackageCtrl.Instance:SendUseItem(data.index, 1, data.sub_type, item_cfg.need_gold)
				end
				return
			end
			if item_cfg.click_use == 1 then
				--背包,仓库,扩展格子，特殊处理
				if item_cfg.id == 26914 or item_cfg.id == 26915 then
					local storage_type = (item_cfg.id == 26914) and GameEnum.STORAGER_TYPE_BAG or GameEnum.STORAGER_TYPE_STORAGER
					local type_name = (storage_type == GameEnum.STORAGER_TYPE_BAG) and Language.Role.BeiBao or Language.Role.CangKu
					local item_num = ItemData.Instance:GetItemNumInBagById(item_cfg.id) or 0
					local can_open_num, need_number, old_need_num = PackageData.Instance:GetCanOpenHowManySlot(storage_type, item_num)
					--if item_cfg.id == 26915 then
						--can_open_num, need_number, old_need_num = ItemData.Instance:GetWareHouseCellOpenNeedCount(storage_type, item_num)
					--end
					if can_open_num < 0 then
						SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Role.NoMoreSlot, type_name))
						return
					elseif can_open_num < 1 then
						SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Role.NeedOpenSlotItem, type_name, need_number, item_cfg.name))
						return
					end
					local label_str = string.format(Language.Role.IfOpenSlotWithItem, old_need_num, item_cfg.name, can_open_num, type_name)
					local ok_func = function()
						PackageCtrl.Instance:SendKnapsackStorageExtendGridNum(storage_type, can_open_num, 0)
					end
					TipsCtrl.Instance:ShowCommonAutoView(nil, label_str, ok_func)
					return
				end

				if KuafuPVPData.Instance:CheckLingPaiID(item_cfg.id) then
					PackageCtrl.Instance:SendUseItem(data.index, handle_param_t.num, data.sub_type, item_cfg.need_gold)
					ViewManager.Instance:Open(ViewName.ZhiZunLingPaiView)
					if KuafuPVPData.Instance:CheckIsCanWear() then
						local lingpai_cfg = KuafuPVPData.Instance:GetLingPaiCfgByID(item_cfg.id)
						GlobalTimerQuest:AddDelayTimer(function() 
							ZhiZunLingPaiCtrl.Instance:SendCross3v3LingPai(CROSS_RING_CARD_OPER_TYPE.CROSS_RING_CARD_OPER_WEAR, lingpai_cfg.seq)
							end, 0.5)
					end
					return
				end

				if KuaFu1v1Data.Instance:CheckJieZhiID(item_cfg.id) then
					PackageCtrl.Instance:SendUseItem(data.index, handle_param_t.num, data.sub_type, item_cfg.need_gold)
					ViewManager.Instance:Open(ViewName.WangZheZhiJieView)
					if KuaFu1v1Data.Instance:CheckIsCanWear() then
						local jiezhi_cfg = KuaFu1v1Data.Instance:GetJieZhiCfgByID(item_cfg.id)
						GlobalTimerQuest:AddDelayTimer(function() 
							WangZheZhiJieCtrl.Instance:SendCrossMatch1V1Req(CROSS_RING_CARD_OPER_TYPE.CROSS_RING_CARD_OPER_WEAR, jiezhi_cfg.seq)
							end, 0.5)
					end
					return
				end

				if data.is_from_shengxiao then
					local bag_index = ItemData.Instance:GetItemIndex(data.item_id)
					PackageCtrl.Instance:SendUseItem(bag_index, handle_param_t.num, data.sub_type, item_cfg.need_gold)
					return
				end
				if item_cfg.id ~= 24605 then
					PackageCtrl.Instance:SendUseItem(data.index, handle_param_t.num, data.sub_type, item_cfg.need_gold)
				end
				if item_cfg.open_panel ~= "" then
					openPanelByName(data, item_cfg.open_panel)
				end
			elseif item_cfg.click_use == 2 then					--批量使用
				-- 我不管 反正这好恶心的，我就直接这么写了。以后新项目果断重写这东西。
				if item_cfg.need_gold and item_cfg.need_gold > 0 then
					local function tips_callback()
						if ItemData.Instance:GetItemNumInBagByIndex(data.index) == 1 then
							PackageCtrl.Instance:SendUseItem(data.index, handle_param_t.num, data.sub_type, item_cfg.need_gold)
						else
							local ok_callback = function (num)
								PackageCtrl.Instance:SendUseItem(data.index, num, data.sub_type, item_cfg.need_gold)
							end
							TipsCtrl.Instance:OpenCommonInputView(ItemData.Instance:GetItemNumInBagByIndex(data.index), ok_callback, nil,
								ItemData.Instance:GetItemNumInBagByIndex(data.index))
						end
						if item_cfg.open_panel ~= "" then
							openPanelByName(data, item_cfg.open_panel)
						end
					end
					TipsCtrl.Instance:ShowCommonAutoView("", string.format(Language.Common.ConsumeGold, item_cfg.need_gold), tips_callback)
					return
				end

				if ItemData.Instance:GetItemNumInBagByIndex(data.index) == 1 then
					PackageCtrl.Instance:SendUseItem(data.index, handle_param_t.num, data.sub_type, item_cfg.need_gold)
				else
					local ok_callback = function (num)
						PackageCtrl.Instance:SendUseItem(data.index, num, data.sub_type, item_cfg.need_gold)
					end
					TipsCtrl.Instance:OpenCommonInputView(ItemData.Instance:GetItemNumInBagByIndex(data.index), ok_callback, nil,
						ItemData.Instance:GetItemNumInBagByIndex(data.index))
				end
				if item_cfg.open_panel ~= "" then
					openPanelByName(data, item_cfg.open_panel)
				end
			elseif item_cfg.click_use == 0 and item_cfg.open_panel ~= "" and nil ~= item_cfg.open_panel then
				-- 进阶装备特殊处理
				local t = Split(item_cfg.open_panel, "#")
				local view_name = t[1]
				local tab_index = t[2]
				if view_name == ViewName.AdvanceEquipView then
					local is_active, activite_grade = AdvanceData.Instance:IsOpenEquip(TabIndex[tab_index])
					if not is_active then
						local name = Language.Advance.PercentAttrNameList[TabIndex[tab_index]] or ""
						TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Advance.OnOpenEquipTip, name, CommonDataManager.GetDaXie(activite_grade), name))
						return
					end

					ViewManager.Instance:CloseAll()
					if TabIndex[tab_index] == TabIndex.goddess_shengong or TabIndex[tab_index] == TabIndex.goddess_shenyi then
						ViewManager.Instance:Open(ViewName.Goddess, TabIndex[tab_index])
					else
						ViewManager.Instance:Open(ViewName.Advance, TabIndex[tab_index])
					end
				end
				if view_name == ViewName.AppearacneEquipView then
					local is_active, activite_grade = AppearanceData.Instance:IsOpenEquip(TabIndex[tab_index])
					if not is_active then
						local name = Language.MultiMount.PercentAttrNameList[TabIndex[tab_index]] or ""
						TipsCtrl.Instance:ShowSystemMsg(string.format(Language.MultiMount.OnOpenEquipTip, name, CommonDataManager.GetDaXie(activite_grade), name))
						return
					end
				end

				if view_name == ViewName.Mojie then
					MojieCtrl.Instance:OpenMoJieView(tab_index)
					return
				end
				openPanelByName(data, item_cfg.open_panel)
			elseif item_cfg.click_use == 0 and item_cfg.sub_type == GameEnum.EQUIP_TYPE_JINGLING then
				ViewManager.Instance:Close(ViewName.Player)
				ViewManager.Instance:Open(ViewName.SpiritView)
			elseif item_cfg.click_use == 0 and item_cfg.sub_type <= GameEnum.E_TYPE_ZHUANZHI_YUPEI and item_cfg.sub_type >= GameEnum.E_TYPE_ZHUANZHI_WUQI then
				PackageCtrl.Instance:SendUseItem(data.index, handle_param_t.num, data.sub_type)
			end
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.UseLevelLimit)
		end
	end,
	--从寻宝仓库取出
	[TipsHandleDef.BAOXIANG_QUCHU] = function(data, item_cfg, handle_type)
		local pack_empty_num = ItemData.Instance:GetMaxKnapsackValidNum() - #ItemData.Instance:GetBagItemDataList()
		if pack_empty_num > 0 then
			local grid_index = TreasureData.Instance:GetGridIndexById(data.item_id)
			TreasureCtrl.Instance:SendQuchuItemReq(grid_index , CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP, 0)
		end
	end,
--撤回寄售的物品
	[TipsHandleDef.SHICHANG_CHEHUI] = function(data, item_cfg, handle_type)
	    if nil == _M.alert_window then
			_M.alert_window = Alert.New(nil, nil, nil, nil, false)
		end
		_M.alert_window:SetContent(Language.Market.AlerTips)
		_M.alert_window:SetOkFunc(BindTool.Bind2(MarketCtrl.Instance.SendRemovePublicSaleItem, MarketCtrl.Instance, data.sale_index))
		_M.alert_window:Open()
	end,
	--从市场中购买
	[TipsHandleDef.SHICHANG_GOUMAI] = function(data, item_cfg, handle_type)
		local cost_gold = data.gold_price
		print("*****************gold_price",cost_gold)
		print("*****************price_type",data.price_type)
		MarketCtrl.Instance:SendBuyPublicSaleItem(data.seller_uid, data.sale_index, data.item_id, data.num, data.gold_price, data.sale_value, data.sale_item_type, data.price_type)
	end,
	--融合
	[TipsHandleDef.RONGHE] = function(data, item_cfg, handle_type)

	end,
	--锻造s
	[TipsHandleDef.HANDLE_FORGE] = function(data, item_cfg, handle_type, from_view, handle_param_t)
		ForgeCtrl.Instance:OpenViewToIndex(data.index, item_cfg.sub_type)
		return true
	end,
	--回收 \ 丢弃
	[TipsHandleDef.HANDLE_RECOVER] = function(data, item_cfg, handle_type, from_view, handle_param_t)
		if from_view == TipsFormDef.FROM_CARD_UP then
			onOpenPopNum(data, from_view, handle_type, handle_param_t)
		elseif(from_view == TipsFormDef.FROM_BAG_ON_BAG_SALE and item_cfg.sub_type ~= GameEnum.EQUIP_TYPE_JINGLING)
			or (from_view == TipsFormDef.FROM_BAG_ON_BAG_SALE_JL and item_cfg.sub_type == GameEnum.EQUIP_TYPE_JINGLING) then
			onOpenPopNum(data, from_view, handle_type, handle_param_t)
		elseif from_view == TipsFormDef.FROM_STORGE_ON_SPRITRT_STORGE then -- 从精灵仓库丢弃
		else
			local str = item_cfg.sub_type == GameEnum.EQUIP_TYPE_JINGLING and Language.Tip.IsSureRecoverJl
				or (item_cfg.sub_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and Language.Tip.IsSureRecover or Language.Tip.IsSureRecoverProp)
			local ok_func = function()
				PackageCtrl.Instance:SendDiscardItem(data.index, data.num, data.item_id, data.num, 1)
			end
			TipsCtrl.Instance:ShowCommonAutoView(nil, str, ok_func)
		end
	end,
	--出售（实际上是回收）
	[TipsHandleDef.HANDLE_SELL] = function(data, item_cfg, handle_type, from_view, handle_param_t)
		local ok_func = function()
			PackageCtrl.Instance:SendDiscardItem(data.index, data.num, data.item_id, data.num, 1)
		end
		TipsCtrl.Instance:ShowCommonAutoView(nil, Language.Common.ItemDecomposeTip, ok_func)
	end,
	--放入
	[TipsHandleDef.HANDLE_TAKEON] = function(data, item_cfg, handle_type, from_view, handle_param_t)
		if from_view == TipsFormDef.FROM_SJ_JC_ON then
			ForgeCtrl.Instance:TakeOnSjJcCell(data, handle_param_t)
		elseif from_view == TipsFormDef.FROM_BAG_ON_GUILD_STORGE then
			if data.num == 1 then
				GuildCtrl.Instance:SendStorgetPutItem(data.index, data.num)
			else
				local ok_callback = function (out_num)
					GuildCtrl.Instance:SendStorgetPutItem(data.index, out_num)
				end
				TipsCtrl.Instance:OpenCommonInputView(ItemData.Instance:GetItemNumInBagByIndex(data.index), ok_callback, nil, data.num)
			end
		end
	end,
	--情缘
	[TipsHandleDef.HANDLE_QINGYUSN] = function(data, item_cfg, handle_type)
	end,
	-- 神州六器鉴定
	[TipsHandleDef.HANDLE_SHENZHOU_JIANDING] = function(data, item_cfg, handle_type)
	end,
	-- 神州六器取出
	[TipsHandleDef.HANDLE_SHENZHOU_QUCHU] = function(data, item_cfg, handle_type)
	end,
	-- 神州六器使用
	[TipsHandleDef.HANDLE_SHENZHOU_SHIYONG] = function(data, item_cfg, handle_type)
	end,
	-- 神州六器熔炼
	[TipsHandleDef.HANDLE_SHENZHOU_SMELT] = function(data, item_cfg, handle_type)
	end,
	-- 激活
	[TipsHandleDef.HANDLE_JIHUO] = function(data, item_cfg, handle_type)
		if data and MojieData.IsMojie(data.item_id) then
			ViewManager.Instance:Open(ViewName.Mojie, data.index)
		end
	end,
	-- 进阶装备升级
	[TipsHandleDef.HANDLE_SHENGJI] = function(data, item_cfg, handle_type)
		if data and MojieData.IsMojie(data.item_id) then
			ViewManager.Instance:Open(ViewName.Mojie, data.index)
		-- else
		-- 	local index = nil
		-- 	ViewManager.Instance:Close(ViewName.Player, TabIndex.role_bag)
		end
	end,
	--回收 \ 丢弃
	[TipsHandleDef.HANDLE_RECOVER_SPIRIT] = function(data, item_cfg, handle_type, from_view, handle_param_t)
		if from_view == TipsFormDef.FROM_CARD_UP then
			onOpenPopNum(data, from_view, handle_type, handle_param_t)
		elseif SpiritData.Instance:CanReCyWuXing(data.item_id) then
			local str = Language.Tip.IsSureRecoverThing
			local ok_func = function()
				PackageCtrl.Instance:SendDiscardItem(data.index, data.num, data.item_id, data.num, 1)
			end
			TipsCtrl.Instance:ShowCommonAutoView(nil, str, ok_func)
		elseif(from_view == TipsFormDef.FROM_BAG_ON_BAG_SALE and item_cfg.sub_type ~= GameEnum.EQUIP_TYPE_JINGLING)
			or (from_view == TipsFormDef.FROM_BAG_ON_BAG_SALE_JL and item_cfg.sub_type == GameEnum.EQUIP_TYPE_JINGLING) then
			onOpenPopNum(data, from_view, handle_type, handle_param_t)
		elseif (from_view == TipsFormDef.FROM_BAG and item_cfg.recycltype == 6) or (item_cfg.recycltype == 5 and EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type)) then
			local str = item_cfg.sub_type == GameEnum.EQUIP_TYPE_JINGLING and SpiritData.Instance:GetRecycleText(data.param.param1 or 0) or Language.Tip.IsSureRecover
			local ok_func = function()
				PackageCtrl.Instance:SendDiscardItem(data.index, data.num, data.item_id, data.num, 1)
			end
			TipsCtrl.Instance:ShowCommonAutoView(nil, str, ok_func)
		elseif EquipData.IsMarryEqType(item_cfg.sub_type) then
			local str = Language.Tip.IsSureRecover
			local ok_func = function()
				PackageCtrl.Instance:SendDiscardItem(data.index, data.num, data.item_id, data.num, 1)
			end
			TipsCtrl.Instance:ShowCommonAutoView(nil, str, ok_func)
		elseif from_view == TipsFormDef.FROM_STORGE_ON_SPRITRT_STORGE then
			local str = item_cfg.sub_type == GameEnum.EQUIP_TYPE_JINGLING and SpiritData.Instance:GetRecycleText(data.param.param1 or 0) or Language.Tip.IsSureRecover
			local ok_func = function()
				SpiritCtrl.Instance:SendRecoverySpirit(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING, 0, 0, data.server_grid_index)
			end
			TipsCtrl.Instance:ShowCommonAutoView(nil, str, ok_func)
		else
			local str = item_cfg.sub_type == GameEnum.EQUIP_TYPE_JINGLING and SpiritData.Instance:GetRecycleText(data.param.param1 or 0)
			or (item_cfg.sub_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and SpiritData.Instance:GetRecycleText(data.param.param1 or 0) or Language.Tip.IsSureRecoverProp)
			if item_cfg.sub_type == GameEnum.EQUIP_TYPE_XIAOGUI then
				str = Language.Tip.IsSureRecoverImp
			end
			local ok_func = function()
				PackageCtrl.Instance:SendDiscardItem(data.index, data.num, data.item_id, data.num, 1)
			end
			TipsCtrl.Instance:ShowCommonAutoView(nil, str, ok_func)
		end
	end,
	-- 放生（宠物）
	[TipsHandleDef.HANDLE_FREE_PET] = function(data, item_cfg, handle_type, from_view, handle_param_t)
		local ok_func = function()
			PackageCtrl.Instance:SendDiscardItem(data.index, data.num, data.item_id, data.num, 1)
		end
		TipsCtrl.Instance:ShowCommonAutoView(nil, Language.Common.PetReliveTip, ok_func)
	end,
	-- 分解转生装备
	[TipsHandleDef.HANDLE_DECOMPOSE] = function(data, item_cfg, handle_type, from_view, handle_param_t)
		local ok_func = function()
			PackageCtrl.Instance:SendDiscardItem(data.index, data.num, data.item_id, data.num, 1)
		end
		TipsCtrl.Instance:ShowCommonAutoView(nil, Language.Common.ZhuanShengDecomposeTip, ok_func)
	end,
	-- 替换
	[TipsHandleDef.HANDLE_REPLACE] = function(data, item_cfg, handle_type, from_view, handle_param_t)
		if from_view == TipsFormDef.FROM_SHENGXIAO_EQUIP then
			ViewManager.Instance:Open(ViewName.ShengXiaoEquipBag)
		elseif from_view == TipsFormDef.FROM_BIANSHEN_EQUIP then
			ViewManager.Instance:Open(ViewName.BianShenEquipBag)
		end
	end,
	--神印回收
	[TipsHandleDef.HANDLE_SHENYIN_RECOVER] = function(data, item_cfg, handle_type, from_view, handle_param_t)
		ShenYinCtrl.SendTianXiangOperate(CS_SHEN_YIN_TYPE.IMPRINT_RECYCLE, data.param1, data.num)
	end,

	--元素装备分解
	[TipsHandleDef.HANDLE_YUANZHUANG] = function(data, item_cfg, handle_type, from_view, handle_param_t)
		SymbolCtrl.Instance:SendEquipRecycle(data.index, data.num)
	end,

	--神印-召印（猎魂）放入背包和回收
	[TipsHandleDef.HANDLE_SHENYIN_LIEHUN_TAKBON] = function(data, item_cfg, handle_type, from_view, handle_param_t)
		ShenYinCtrl.SendTianXiangOperate(CS_SHEN_YIN_TYPE.PUT_BAG, data.index)	--index从0开始
	end,
	[TipsHandleDef.HANDLE_SHENYIN_LIEHUN_RECOVER] = function(data, item_cfg, handle_type, from_view, handle_param_t)
		ShenYinCtrl.SendTianXiangOperate(CS_SHEN_YIN_TYPE.SINGLE_CONVERT_TO_EXP, data.index)	 --index从0开始
	end,
	--天赋 装备
	[TipsHandleDef.HANDLE_TALENT_EQUIP] = function(data, item_cfg, handle_type, from_view, handle_param_t)
		ImageFuLingCtrl.Instance:SendTalentOperaReq(TALENT_OPERATE_TYPE.TALENT_OPERATE_TYPE_PUTON, handle_param_t.talent_type,  handle_param_t.grid_index, data.index)
		ViewManager.Instance:Close(ViewName.TalentBagView)
	end,
	--小鬼 续费
	[TipsHandleDef.HANDLE_XUFEI_EQUIP] = function(data, item_cfg, handle_type, from_view, handle_param_t)
		local bind_gold = GameVoManager.Instance:GetMainRoleVo().bind_gold
		local item_id = data.item_id
		if data.item_id == 64101 then	--对限时免费小鬼拿64100的配置
			item_id = 64100
		end
		local xiaogui_cfg = EquipData.GetXiaoGuiCfgById(item_id)
		local is_use_bind_gold = xiaogui_cfg.is_bind_gold or 0
		if (is_use_bind_gold == 1 and bind_gold < xiaogui_cfg.gold_price) or is_use_bind_gold == 0 then
			is_use_bind_gold = 0
		end
		if xiaogui_cfg == nil then return end
		local ok_fun = function ()
			if data.index then
				PlayerCtrl.Instance:SendImpGuardOperaReq(IMP_GUARD_REQ_TYPE.IMP_GUARD_REQ_TYPE_RENEW_PUTON , data.index - 1, is_use_bind_gold)
			else
				PlayerCtrl.Instance:SendImpGuardOperaReq(IMP_GUARD_REQ_TYPE.IMP_GUARD_REQ_TYPE_RENEW_PUTON , nil, is_use_bind_gold)
			end
		end

		local cfg = string.format(Language.Player.XuFeiText[is_use_bind_gold], xiaogui_cfg.imp_guard_name, xiaogui_cfg.gold_price)
		TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, cfg)
	end,
	[TipsHandleDef.HANDLE_TAKEOFF_EQUIP] = function(data, item_cfg, handle_type, from_view, handle_param_t)
		local item_id = data.item_id
		if data.item_id == 64101 then	--对限时免费小鬼拿64100的配置
			item_id = 64100
		end
		local xiaogui_cfg = EquipData.GetXiaoGuiCfgById(item_id)
		if xiaogui_cfg == nil then
			return
		end
		local ok_fun = function ()
			if data.index then
				PlayerCtrl.Instance:SendImpGuardOperaReq(IMP_GUARD_REQ_TYPE.IMP_GUARD_REQ_TYPE_TAKEOFF , data.index - 1, xiaogui_cfg.is_bind_gold)
			else
				PlayerCtrl.Instance:SendImpGuardOperaReq(IMP_GUARD_REQ_TYPE.IMP_GUARD_REQ_TYPE_TAKEOFF , nil, xiaogui_cfg.is_bind_gold)
			end
		end
		local cfg = string.format(Language.Player.TakeOffText, xiaogui_cfg.imp_guard_name)
		TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, cfg)
	end,
	--小宠物仓库取出
	[TipsHandleDef.HANDLE_CHONGWU] = function (data)
		TreasureCtrl.Instance:SendQuchuItemReq(data.server_grid_index, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP, 0)
	end,
	--生肖装备卸下
	[TipsHandleDef.HANDLE_SHENGXIAO_TAKEOFF] = function (data, item_cfg, handle_type)
		local shengxiao_type = ShengXiaoData.Instance:GetEquipListByindex()
		local index = item_cfg.sub_type % GameEnum.EQUIP_TYPE_SHENGXIAO_1
		ShengXiaoCtrl.Instance:SendZodiacTakeOffEquipRequest(shengxiao_type - 1, index)
	end,

	-- 周末装备卸下
	[TipsHandleDef.TIANSHENHUTI_EQUIP_TAKEOFF] = function (data, item_cfg, handle_type)
		TianshenhutiCtrl.SendTianshenhutiTakeOff(data.index)
	end,

	--变身装备卸下
	[TipsHandleDef.HANDLE_BIANSHEN_TAKEOFF] = function (data, item_cfg, handle_type)
		BianShenCtrl.Instance:SendRequest(GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_PUTOFF_EQUIPMENT, data.seq, data.slot_index, nil)
	end,
}

function _M.GetOperationState(from_view, data, item_cfg, big_type)
	local handler_types = {}
	local func = operationState[from_view]
	if func == nil or item_cfg == nil or data == nil then
		return handler_types
	end
	func(data, item_cfg, big_type, handler_types, from_view)
	return handler_types
end

function _M.DoClickHandler(data, item_cfg, handle_type, from_view, handle_param_t)
	local func = doClickHandler[handle_type]
	if func == nil or data == nil or item_cfg == nil then
		return false
	end
	func(data, item_cfg, handle_type, from_view, handle_param_t)
	return true
end

function _M.IsShowSellViewState(from_view)
	local salestate = true
	if from_view == TipsFormDef.FROM_BAG then							--在背包界面中（没有打开仓库和出售）
		salestate = true
	elseif from_view == TipsFormDef.FROM_BAG_ON_BAG_STORGE then			--打开仓库界面时，来自背包
		salestate = true
	elseif from_view == TipsFormDef.FROM_STORGE_ON_BAG_STORGE then		--打开仓库界面时，来自仓库
		salestate = true
	elseif from_view == TipsFormDef.FROM_BAG_ON_BAG_SALE then			--打开售卖界面时，来自背包
		salestate = true
	elseif from_view == TipsFormDef.FROM_BAG_ON_BAG_SALE_JL then		--打开精灵售卖界面时，来自背包
		salestate = true
	elseif from_view == TipsFormDef.FROM_BAG_EQUIP then					--打开装备界面时，来自装备
		salestate = true
	elseif from_view == TipsFormDef.FROM_CAMP_EQUIP then				--打开阵营装备界面时，来自阵营装备
		salestate = true
	elseif from_view == TipsFormDef.FROM_BAOXIANG then					--打开宝箱界面时，来自宝箱
		salestate = false
	elseif from_view == TipsFormDef.FROM_MARKET_JISHOU then
		salestate = false
	elseif from_view == TipsFormDef.FROME_MARKET_GOUMAI then
		salestate = false
	else
		salestate = false
	end
	return salestate
end

function _M.DeleteMe(self)
	if _M.pop_num_view ~= nil then
		_M.pop_num_view:DeleteMe()
		_M.pop_num_view = nil
	end
	if _M.alert ~= nil then
		_M.alert:DeleteMe()
		_M.alert = nil
	end
end

return _M