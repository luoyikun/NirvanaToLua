-- 锻造 附灵（洗练）
ForgeClearView = ForgeClearView or BaseClass(BaseRender)

function ForgeClearView:__init(instance, parent_view)
	self.node_list["BtnClear"].button:AddClickListener(BindTool.Bind(self.OnBtnClear, self))
	self.node_list["ButtonHelp"].button:AddClickListener(BindTool.Bind(self.OnButtonHelp, self))
	self.node_list["UseHighMaterial"].button:AddClickListener(BindTool.Bind(self.OnUseHighMaterial, self))
	self.node_list["MaterialCell2"].button:AddClickListener(BindTool.Bind(self.OnUseHighMaterial, self))
	-- self.node_list["UseMoneyClear"].button:AddClickListener(BindTool.Bind(self.OnUseMoneyClear, self))

	for i = 1, 3 do
		self.node_list["BtnLock" .. i].button:AddClickListener(BindTool.Bind(self.OnBtnLock, self, i))
		self.node_list["BtnOpenLock" .. i].button:AddClickListener(BindTool.Bind(self.OnBtnOpenLock, self, i))
	end

	self.equip_cell = ItemCell.New()
	self.equip_cell:SetInstanceParent(self.node_list["EquipItem"])
	self.equip_cell:SetFromView(TipsFormDef.FROM_BAG_EQUIP)

	self.material_cell = ItemCell.New()
	self.material_cell:SetInstanceParent(self.node_list["MaterialCell"])

	self.high_material = nil
	-- self.use_money_clear = false
	
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightNum"])

	-- ForgeData.Instance:SetFuLingStoneNum()
	RemindManager.Instance:Fire(RemindName.ForgeDeityIntersify)
end

function ForgeClearView:__delete()
	if self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil
	end

	if self.material_cell then
		self.material_cell:DeleteMe()
		self.material_cell = nil
	end
	self.fight_text = nil
end

function ForgeClearView:CloseCallBack()
	-- ForgeData.Instance:SetFuLingStoneNum()
end

function ForgeClearView:ClickEquipListCallBack(index)
	self.select_index = index
	self:Flush()
end

function ForgeClearView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "ui_tween" then
			local ui_cfg = ForgeData.Instance:GetUITweenCfg(TabIndex.forge_deity_intersify)
			UITween.MoveShowPanel(self.node_list["DownPanel"] , ui_cfg["DownPanel"], ui_cfg["MOVE_TIME"])
			UITween.AlpahShowPanel(self.node_list["UpPanel"] , ui_cfg["UpPanel"], ui_cfg["MOVE_TIME"], DG.Tweening.Ease.InExpo)
		end
	end
	
	if self.select_index == nil then return end
	self.cell_data = ForgeData.Instance:GetZhuanzhiEquip(self.select_index)
	if nil == self.cell_data or self.cell_data.item_id <= 0 then 
		return 
	end

	self.equip_cell:SetData(self.cell_data)
	self.equip_cell:ShowStrengthLable(false)

	local clear_data = ForgeData.Instance:GetClearPartInfo(self.select_index)
	local open_flag_list = ForgeData.Instance:GetOpenSlotFlag(self.select_index)
	local lock_flag_list = ForgeData.Instance:GetLockSlotFlag(self.select_index)

	-- print_error("select_index", self.select_index)
	-- print_error("clear_data", clear_data)
	-- print_error("open_flag_list", open_flag_list)
	-- print_error("lock_flag_list", lock_flag_list)

	local lock_num = 0
	local color_list = {}
	local attr_list = {}
	for i = 1, 3 do
		local open_flag = open_flag_list and open_flag_list[33 - i] or 0
		local lock_flag = lock_flag_list and lock_flag_list[33 - i] or 0
		local attr_value = clear_data.baptize_list and clear_data.baptize_list[i] or 0
		local attr_seq = clear_data.attr_seq_list and clear_data.attr_seq_list[i] or 0
		local attr_cfg = ForgeData.Instance:GetClearAttrBySeq(attr_seq)
		local attr_color_seq = ForgeData.Instance:GetClearAttrColorSeq(attr_seq, attr_value)
		-- print_error("i:",i, attr_value, attr_seq, open_flag, lock_flag, attr_cfg)

		if open_flag == 1 then
			if attr_value > 0 and attr_cfg then
				color_list[i] = attr_color_seq
				attr_list[attr_cfg.attr_type] = attr_value
				if lock_flag == 1 then
					self.node_list["LockToggle" .. i]:SetActive(true)
					lock_num = lock_num + 1
				else
					self.node_list["LockToggle" .. i]:SetActive(false)
				end
				self.node_list["Lock" .. i]:SetActive(true)

				local slider = attr_value / attr_cfg["red_value_high"]
				-- self.node_list["AttrName" .. i].text.text = attr_cfg.attr_name

				self.node_list["Attr" .. i].text.text = ToColorStr(attr_cfg.attr_name .. "+" .. attr_value, ORDER_COLOR[attr_color_seq + 1])

				local color_limit_seq = {
					[1] = {"white_value_low", "white_value_high"},
					[2] = {"blue_value_low", "blue_value_high"},
					[3] = {"purple_value_low", "purple_value_high"},
					[4] = {"orange_value_low", "orange_value_high"},
					[5] = {"red_value_low", "red_value_high"},
				}
				local color_cfg = color_limit_seq[attr_color_seq + 1] or color_limit_seq[1]
				local low_limit, up_limit = color_cfg[1], color_cfg[2]
				local limit_text = ToColorStr(string.format("%s-%s", attr_cfg[low_limit], attr_cfg[up_limit]), ORDER_COLOR[attr_color_seq + 1])
				self.node_list["Limit" .. i].text.text = "(" .. limit_text .. ")"
				self.node_list["ZWSX" .. i]:SetActive(false)
			else
				self.node_list["Lock" .. i]:SetActive(false)
				self.node_list["LockToggle" .. i]:SetActive(false)
				self.node_list["Attr" .. i].text.text = ""
				self.node_list["Limit" .. i].text.text = ""
				-- self.node_list["AttrName" .. i].text.text = ""
				self.node_list["ZWSX" .. i]:SetActive(true)
			end
			self.node_list["BtnOpenLock" .. i]:SetActive(false)
		else
			self.node_list["Attr" .. i].text.text = ""
			self.node_list["Limit" .. i].text.text = ""
			self.node_list["Lock" .. i]:SetActive(false)
			self.node_list["BtnOpenLock" .. i]:SetActive(true)
			self.node_list["ZWSX" .. i]:SetActive(true)
			-- self.node_list["AttrName" .. i].text.text = ""
		end
	end
	-- print_error(attr_list)
	local fight_capacity = CommonDataManager.GetCapabilityCalculation(attr_list)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = fight_capacity
	end

	self.lock_cfg = ForgeData.Instance:GetLockNumConsumeCfg(lock_num)
	local curr_suit_cfg, next_suit_cfg = ForgeData.Instance:GetClearSuitCfg(self.select_index, color_list)
	if not next_suit_cfg then
		--没激活									
		local desc = string.format(Language.Forge.BaptizeSuitDesc, Language.Forge.BaptizeColor[curr_suit_cfg.baptize_color])
		self.node_list["NextSuitAttrDesc"].text.text = desc
		self.node_list["NextSuitAttr"].text.text = curr_suit_cfg.show_shuxing
		self.node_list["CurrSuitAttrDesc"].text.text = ""
		self.node_list["CurrSuitAttr"].text.text = ""
	elseif next_suit_cfg and type(next_suit_cfg) == "table" then 
		--激活可升级	
		local desc = string.format(Language.Forge.BaptizeSuitDesc2, Language.Forge.BaptizeColor[next_suit_cfg.baptize_color])
		self.node_list["NextSuitAttrDesc"].text.text = desc
		self.node_list["NextSuitAttr"].text.text = next_suit_cfg.show_shuxing
		self.node_list["CurrSuitAttrDesc"].text.text = Language.Forge.BaptizeSuitDesc4
		self.node_list["CurrSuitAttr"].text.text = curr_suit_cfg.show_shuxing
	else
		--满级													
		self.node_list["NextSuitAttrDesc"].text.text = Language.Forge.BaptizeSuitDesc4
		self.node_list["NextSuitAttr"].text.text = curr_suit_cfg.show_shuxing
		self.node_list["CurrSuitAttrDesc"].text.text = ""
		self.node_list["CurrSuitAttr"].text.text = ""	
	end

	self:FlushHighMaterialCell()
	-- self:FlushMoneyClearToggle()
end

function ForgeClearView:FlushHighMaterialCell()
	if self.high_material then
		local item_cfg = ItemData.Instance:GetItemConfig(self.high_material)
		if item_cfg then
			local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
			local bundle1, asset1 = ResPath.GetQualityIcon(item_cfg.color)
			self.node_list["ItemIcon"].image:LoadSprite(bundle, asset .. ".png")
			self.node_list["ItemQuality"].image:LoadSprite(bundle1, asset1)
		end

		if self.lock_cfg then
			local had_material = ItemData.Instance:GetItemNumInBagById(self.high_material)
			local need_material = 0
			if self.high_color_seq == 1 then
				need_material = self.lock_cfg.orange_stuff_num
			elseif self.high_color_seq == 2 then
				need_material = self.lock_cfg.red_stuff_num
			else
				need_material = self.lock_cfg.purple_stuff_num
			end

			local need_mat_text = ToColorStr(need_material, TEXT_COLOR.GREEN_4)
			local had_mat_text = ToColorStr(had_material, (had_material < need_material and COLOR.RED or TEXT_COLOR.GREEN_4))
			self.node_list["ItemNumber"].text.text = had_mat_text .. " / " .. need_mat_text
		end

		self.node_list["UseHighMaterial"]:SetActive(false)
		self.node_list["ItemIcon"]:SetActive(true)
		self.node_list["ItemQuality"]:SetActive(true)
		local color_seq = self.high_color_seq == 3 and self.high_color_seq - 1  or self.high_color_seq + 2 --(self.high_color_seq == EQUIP_BAPTIZE_SPECIAL_TYPE.EQUIP_BAPTIZE_SPECIAL_TYPE_ORANGE) and 3 or 4
		local color_desc = ToColorStr(Language.Forge.BaptizeColor[color_seq], ORDER_COLOR[color_seq + 1])
		
		local desc = string.format(Language.Forge.ClearHighAttrDesc, ToColorStr(item_cfg.name, ORDER_COLOR[color_seq + 1]), color_desc)
		self.node_list["UseHighDesc"].text.text = desc
		self.node_list["UseHighDesc"]:SetActive(true)
		self.node_list["UseHighDesc"]:SetActive(true)
		-- self.node_list["UseMoneyClearFrame"]:SetActive(false)
	else
		self.node_list["UseHighMaterial"]:SetActive(true)
		self.node_list["ItemIcon"]:SetActive(false)
		self.node_list["ItemQuality"]:SetActive(false)
		self.node_list["UseHighDesc"]:SetActive(false)
		-- self.node_list["UseMoneyClearFrame"]:SetActive(true)
		self.node_list["ItemNumber"].text.text = ""
	end

	if self.lock_cfg then
		-- local material_cfg = ItemData.Instance:GetItemConfig(self.lock_cfg.consume_stuff_id)
		local had_material = ItemData.Instance:GetItemNumInBagById(self.lock_cfg.consume_stuff_id)
		local need_material = self.lock_cfg.consume_stuff_num
		self.material_cell:SetData({item_id = self.lock_cfg.consume_stuff_id})

		local need_mat_text = ToColorStr(need_material, TEXT_COLOR.GREEN_4)
		local had_mat_text = ToColorStr(had_material, (had_material < need_material and COLOR.RED or TEXT_COLOR.GREEN_4))
		self.node_list["MaterialName1"].text.text = had_mat_text .. " / " .. need_mat_text
	else
		self.node_list["MaterialName1"].text.text = ""
	end
end

function ForgeClearView:FlushMoneyClearToggle()
	-- self.node_list["MoneyClearToggle"]:SetActive(self.use_money_clear)

	-- local desc = string.format(Language.Forge.ClearZiSeAttrDesc, self.lock_cfg and self.lock_cfg.has_purple_use_gold or 0)
	-- self.node_list["UseMoneyDesc"].text.text = desc
end

function ForgeClearView:OnBtnClear()
	if nil == self.cell_data then 
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NoSelectEquip)
		return 
	end
	local is_flush = false
	local callback = function()
		if self.lock_cfg then
			local callback2 = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
				local func2 = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
					MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
					if is_buy_quick then
						self.node_list["ToggleAutoBuy"].toggle.isOn = true
					end
				end

				local had_high_material = ItemData.Instance:GetItemNumInBagById(self.high_material)
				local need_high_material = self.lock_cfg.purple_stuff_num
				local use_money_clear = self.node_list["ToggleAutoBuy"].toggle.isOn and 1 or 0
				if need_high_material > had_high_material and use_money_clear == 0 then
					if is_flush then 
						TipsCtrl.Instance:ShowCommonBuyViewAgain(func2, self.high_material, nil, need_high_material - had_high_material)
					else
						TipsCtrl.Instance:ShowCommonBuyView(func2, self.high_material, nil, need_high_material - had_high_material)
					end
				end
			end	

			local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
				MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)

				if self.high_color_seq and self.high_color_seq == 3 and self.high_material then --紫色也可购买
					is_flush = true
					callback2()
				else
					if is_buy_quick then
						self.node_list["ToggleAutoBuy"].toggle.isOn = true
					end
				end 
			end	


			local had_material = ItemData.Instance:GetItemNumInBagById(self.lock_cfg.consume_stuff_id)
			local need_material = self.lock_cfg.consume_stuff_num
			local use_money_clear = self.node_list["ToggleAutoBuy"].toggle.isOn and 1 or 0
			if need_material > had_material and use_money_clear == 0 then
				TipsCtrl.Instance:ShowCommonBuyView(func, self.lock_cfg.consume_stuff_id, nil, need_material - had_material)
			else
				if self.high_color_seq and self.high_color_seq == 3 and self.high_material and use_money_clear == 0 then --紫色也可购买
					local had_high_material = ItemData.Instance:GetItemNumInBagById(self.high_material)
					local need_high_material = self.lock_cfg.purple_stuff_num
					if need_high_material > had_high_material then
						is_flush = false
						callback2()
					else
						local high_color_seq = self.high_color_seq and self.high_color_seq or 0
						ForgeCtrl.Instance:SendCSEquipBaptizeOperaReq(EQUIP_BAPTIZE_OPERA_TYPE.EQUIP_BAPTIZE_OPERA_TYPE_BEGIN_BAPTIZE, self.select_index, use_money_clear, high_color_seq, is_auto)
					end
				else
					local high_color_seq = self.high_color_seq and self.high_color_seq or 0
					ForgeCtrl.Instance:SendCSEquipBaptizeOperaReq(EQUIP_BAPTIZE_OPERA_TYPE.EQUIP_BAPTIZE_OPERA_TYPE_BEGIN_BAPTIZE, self.select_index, use_money_clear, high_color_seq, is_auto)
				end
			end
		end

	end

	local clear_data = ForgeData.Instance:GetClearPartInfo(self.select_index)
	local lock_flag_list = ForgeData.Instance:GetLockSlotFlag(self.select_index)

	if clear_data and lock_flag_list then
		for i = 1, 3 do
			local attr_value = clear_data.baptize_list and clear_data.baptize_list[i] or 0
			local attr_seq = clear_data.attr_seq_list and clear_data.attr_seq_list[i] or 0
			local attr_color_seq = ForgeData.Instance:GetClearAttrColorSeq(attr_seq, attr_value)
			local lock_flag = lock_flag_list and lock_flag_list[33 - i] or 0
			if attr_color_seq > 2 and lock_flag ~= 1 then
				TipsCtrl.Instance:ShowCommonAutoView(nil, Language.Forge.HasGoddAttr, callback, nil, false, nil, nil, nil, nil, false)
				return
			end
		end
	end
	callback()
end

function ForgeClearView:OnUseHighMaterial()
	if self.high_material then
		self.high_material = nil
		self.high_color_seq = nil
		self:FlushHighMaterialCell()
	else
		ForgeCtrl.Instance:OpenClearItemListView(BindTool.Bind(self.OnClickMaterialListCallBack, self))
	end
end

function ForgeClearView:OnClickMaterialListCallBack(high_material, high_color_seq)
	self.high_material = high_material
	self.high_color_seq = high_color_seq
	self:FlushHighMaterialCell()
end

-- function ForgeClearView:OnUseMoneyClear()
	-- self.use_money_clear = not self.use_money_clear
	-- self:FlushMoneyClearToggle()
-- end

-- 锁定/解锁属性
function ForgeClearView:OnBtnLock(index)
	local open_flag_list = ForgeData.Instance:GetOpenSlotFlag(self.select_index)
	local lock_flag_list = ForgeData.Instance:GetLockSlotFlag(self.select_index)
	local open_num = 0
	local lock_num = 0
	for i = 1, 3 do
		local open_flag = open_flag_list and open_flag_list[33 - i] or 0
		local lock_flag = lock_flag_list and lock_flag_list[33 - i] or 0
		if open_flag == 1 then
			open_num = open_num + 1
			if lock_flag == 1 and index ~= i then
				lock_num = lock_num + 1
			end
		end
	end

	if open_num <= lock_num + 1 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.MustClearOneAttr)
		return
	end

	ForgeCtrl.Instance:SendCSEquipBaptizeOperaReq(EQUIP_BAPTIZE_OPERA_TYPE.EQUIP_BAPTIZE_OPERA_TYPE_LOCK_OR_UNLOCK, self.select_index, index - 1)
end

-- 开启槽
function ForgeClearView:OnBtnOpenLock(index)
	if nil == self.cell_data then 
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NoSelectEquip)
		return 
	end

	local function ok_callback()
		ForgeCtrl.Instance:SendCSEquipBaptizeOperaReq(EQUIP_BAPTIZE_OPERA_TYPE.EQUIP_BAPTIZE_OPERA_TYPE_OPEN_SLOT, self.select_index, index - 1)
	end	

	local consume = ForgeData.Instance:OpenLockConsume(index - 1)
	local des = string.format(Language.Forge.OpenSlotConsume, consume)

	TipsCtrl.Instance:ShowCommonAutoView("forge_clear", des, ok_callback, nil, nil, nil, nil, nil, nil, false)
end

function ForgeClearView:OnButtonHelp()
	local tips_id = 262
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end
