ForgeAdvance = ForgeAdvance or BaseClass(BaseRender)

function ForgeAdvance:__init(instance, parent_view)
	self.is_max_level = false

	self.equimentsuit_remind_change = BindTool.Bind(self.EquimentSuitRemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.equimentsuit_remind_change, RemindName.EquimentSuit)

	self.node_list["AdvanceBtn"].button:AddClickListener(BindTool.Bind(self.OnClickAdvance, self))
	self.node_list["ButtonHelp"].button:AddClickListener(BindTool.Bind(self.OnButtonHelp, self))
	self.node_list["BtnEquitSuit"].button:AddClickListener(BindTool.Bind(self.OnOpenEquimentSuit, self))

	self.curr_state = AdvanceStateCell.New(self.node_list["LeftFrame"])
	self.next_state = AdvanceStateCell.New(self.node_list["RightFrame"], true)
	self.material_cell = ItemCell.New()
	self.material_cell:SetInstanceParent(self.node_list["MaterialCell"])
end

function ForgeAdvance:__delete()
	if self.curr_state then
		self.curr_state:DeleteMe()
		self.curr_state = nil
	end

	if self.next_state then
		self.next_state:DeleteMe()
		self.next_state = nil
	end

	if self.material_cell then
		self.material_cell:DeleteMe()
		self.material_cell = nil
	end

	self.is_max_level = nil
	self.advance_cfg = nil
	if nil ~= self.equimentsuit_remind_change then
		RemindManager.Instance:UnBind(self.equimentsuit_remind_change)
	end
end


function ForgeAdvance:ClickEquipListCallBack(index)
	self.select_index = index
	self:Flush()
end

function ForgeAdvance:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "ui_tween" then
			local ui_cfg = ForgeData.Instance:GetUITweenCfg(TabIndex.forge_advance)
			UITween.MoveShowPanel(self.node_list["DownPanel"] , ui_cfg["DownPanel"], ui_cfg["MOVE_TIME"])
			UITween.AlpahShowPanel(self.node_list["UpPanel"] , ui_cfg["UpPanel"], ui_cfg["MOVE_TIME"], DG.Tweening.Ease.InExpo)
			UITween.AlpahShowPanel(self.node_list["ButtonHelp"] , ui_cfg["UpPanel"], ui_cfg["MOVE_TIME"], DG.Tweening.Ease.InExpo)
		end
	end

	if self.select_index == nil then return end

	self.cell_data = EquipData.Instance:GetGridData(self.select_index)
	if nil == self.cell_data or nil == self.cell_data.item_id then 
		return 
	end

	self.advance_cfg = ForgeData.Instance:GetAdvanceCfg(self.cell_data.item_id)
	if nil == self.advance_cfg then
		local max_level_id = ForgeData.Instance:GetAdvanceIndexMaxLevelId(self.cell_data.index)
		if max_level_id and max_level_id == self.cell_data.item_id then
			self.is_max_level = true
		else
			return
		end
		self.limit_role_level = nil
	else
		self.limit_role_level = self.advance_cfg.equip_level
		self.is_max_level = false
	end

	local curr_equip_cfg = ItemData.Instance:GetItemConfig(self.cell_data.item_id)
	local next_equip_cfg = {}
	local next_cell_data = TableCopy(self.cell_data)
	if self.is_max_level then
		self.next_state:SetMaxLevel(true)
		next_equip_cfg = curr_equip_cfg

		self.node_list["MaterialNumTxt"].text.text = ""
		self.node_list["MaterialCell"]:SetActive(false)
		self.material_cell:SetData({})

		self.node_list["AdvanceBtnText"].text.text = Language.Forge.YiManJie
		UI:SetButtonEnabled(self.node_list["AdvanceBtn"], false)
		UI:SetGraphicGrey(self.node_list["AdvanceBtn"], true)

		self.node_list["LeftFrame"]:SetActive(false)
		self.node_list["Arrow"]:SetActive(false)
	else
		if self.advance_cfg then
			self.next_state:SetMaxLevel(false)
			next_equip_cfg = ItemData.Instance:GetItemConfig(self.advance_cfg.new_equip_id)
			next_cell_data.item_id = self.advance_cfg.new_equip_id

			local need_material = self.advance_cfg.stuff_count_2
			local had_material = ItemData.Instance:GetItemNumInBagById(self.advance_cfg.stuff_id_2)
			local need_mat_text = need_material
			local had_mat_text = ""
			need_mat_text = ToColorStr(need_material, TEXT_COLOR.GREEN_4)
			had_mat_text = ToColorStr(had_material, (had_material < need_material and COLOR.RED or TEXT_COLOR.GREEN_4))
			self.node_list["MaterialNumTxt"].text.text = had_mat_text .. " / " .. need_mat_text
			self.material_cell:SetData({item_id = self.advance_cfg.stuff_id_2})
			self.node_list["MaterialCell"]:SetActive(true)

			self.node_list["AdvanceBtnText"].text.text = Language.Forge.JinJie
			UI:SetButtonEnabled(self.node_list["AdvanceBtn"], true)
			UI:SetGraphicGrey(self.node_list["AdvanceBtn"], false)

			self.node_list["LeftFrame"]:SetActive(true)
			self.node_list["Arrow"]:SetActive(true)
		end
	end
	self.curr_state:SetEquipData(self.cell_data)
	self.next_state:SetEquipData(next_cell_data)
	self.curr_state:SetData(curr_equip_cfg)
	self.next_state:SetData(next_equip_cfg)
end

function ForgeAdvance:GetAdvanceCall()
	return self.node_list["AdvanceBtn"], BindTool.Bind(self.OnClickAdvance, self)
end

function ForgeAdvance:OnClickAdvance()
	if not self.advance_cfg then
		return
	end

	if nil == self.cell_data then 
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NoSelectEquip)
		return 
	end

	if nil == self.limit_role_level then 
		if self.is_max_level then
			TipsCtrl.Instance:ShowSystemMsg(Language.Forge.YiManJie)
		end
		return
	end

	local role_level = PlayerData.Instance:GetRoleLevel()
	if role_level >= self.limit_role_level then
		local had_material = ItemData.Instance:GetItemNumInBagById(self.advance_cfg.stuff_id_2)
		if had_material >= self.advance_cfg.stuff_count_2 then
			ForgeCtrl.Instance:SendUpLevelReq(self.cell_data.index)
		else
			local func = function(item_id, item_num, is_bind, is_use)
				MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			end
			TipsCtrl.Instance:ShowCommonBuyView(func, self.advance_cfg.stuff_id_2, nil, 1)
		end
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NoEnoughRoleLevel)
	end
end


function ForgeAdvance:EquimentSuitRemindChangeCallBack(remind_name, num)
	if self.node_list and self.node_list["SuitRemind"] then
		self.node_list["SuitRemind"]:SetActive(num > 0)
	end
end
function ForgeAdvance:OnOpenEquimentSuit()
	ViewManager.Instance:Open(ViewName.EquimentSuitView)
end


function ForgeAdvance:OnButtonHelp()
	local tips_id = 253
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

--------------------------------------------------
------------- 装备状态 AdvanceStateCell
--------------------------------------------------
AdvanceStateCell = AdvanceStateCell or BaseClass(BaseCell)
function AdvanceStateCell:__init(instance, is_next)
	self.is_max_level = false

	self.equip_cell = ItemCell.New()
	self.equip_cell:SetInstanceParent(self.node_list["EquipItem"])
	if not is_next then
		self.equip_cell:SetFromView(TipsFormDef.FROM_BAG_EQUIP)
	else
		self.equip_cell:SetFromView(TipsFormDef.FROM_FORGE_COMPARE)
	end
	

	self.attr_list = {}
	local count = 1
	local child_number = self.node_list["AttrGroup"].transform.childCount
	for i = 0, child_number - 1 do
		local obj = self.node_list["AttrGroup"].transform:GetChild(i).gameObject
		if string.find(obj.name, "Attr") ~= nil then
			local variable_table = U3DNodeList(obj:GetComponent(typeof(UINameTable)))
			local item_tab = {}
			item_tab.obj = obj
			item_tab.attr_value = variable_table["Attr"]
			item_tab.attr_valueNumber = variable_table["AttrValueNumber"]
			self.attr_list[count] = item_tab
			count = count + 1
		end
	end

	self.is_next = is_next or false
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightNum"])
end

function AdvanceStateCell:__delete()
	if nil ~= self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil
	end

	self.parent_view = nil
	self.item_cfg = nil
	self.strength_cfg = nil
	self.fight_text = nil
end

function AdvanceStateCell:OnFlush()
	if nil == self.data then return end

	if self.is_max_level then
		self.equip_cell:SetFromView(TipsFormDef.FROM_BAG_EQUIP)
	elseif self.is_next then
		self.equip_cell:SetFromView(TipsFormDef.FROM_FORGE_COMPARE)
	end
	
	local data = self.data
	local total_attr, fight_power = self:GetAttrTabAndFight(self.data)

	local str = ""
	if self.is_next then
		str = self.is_max_level and Language.Forge.YiManJie or (data.limit_level .. Language.Common.Ji)
		self.node_list["LabelTitle"]:SetActive(not self.is_max_level)
		self.node_list["LabelTitleDesc"].text.text = self.is_max_level and Language.Forge.YiManJie or Language.Forge.NextState[1]
		if self.is_max_level then
			self.node_list["LabelTitleDesc"].transform.localPosition = Vector3(-46, 18, 0)
		else
			self.node_list["LabelTitleDesc"].transform.localPosition = Vector3(-65, 18, 0)
		end
	else
		str = data.limit_level .. Language.Common.Ji
	end

	local color_index = ForgeData.Instance:GetEquipColorIndex(self.equip_data.index, self.equip_data.param.quality)
	self.node_list["EquipName"].text.text = ToColorStr(data.name, ORDER_COLOR[color_index])
	self.node_list["LabelTitle"].text.text = str
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = fight_power
	end
	self.equip_cell:SetData(self.equip_data)
	self.equip_cell:ShowStrengthLable(false)

	for k, v in pairs(self.attr_list) do
		if k <= #total_attr then
			v.attr_value.text.text = total_attr[k].name .. '：'
			v.attr_valueNumber.text.text = total_attr[k].value
			v.obj:SetActive(true)
		else
			v.obj:SetActive(false)
		end	
	end
end

function AdvanceStateCell:SetEquipData(equip_data)
	self.equip_data = equip_data
end

function AdvanceStateCell:ClearData()
	self.equip_cell:SetData({})
	self.node_list["EquipName"].text.text = ""
	self.node_list["LabelTitle"].text.text = ""
	self.node_list["FightNum"].text.text = ""
	for k, v in pairs(self.attr_list) do
		v.obj:SetActive(false)
	end
end

function AdvanceStateCell:SetMaxLevel(is_max)
	self.is_max_level = is_max
end

function AdvanceStateCell:GetAttrTabAndFight(item_cfg)
	local attr_tab = CommonDataManager.GetAttributteNoUnderline(item_cfg)
	local fight_power = CommonDataManager.GetCapabilityCalculation(attr_tab)
	local sort_attr = CommonDataManager.GetOrderAttributte(attr_tab)
	local total_attr = {}
	local count = 1
	for k, v in pairs(sort_attr) do
		if v.value > 0 then
			total_attr[count] = {}
			total_attr[count].name = CommonDataManager.GetAttrName(v.key)
			total_attr[count].value = v.value
			count = count + 1
		end
	end
	return total_attr, fight_power
end

