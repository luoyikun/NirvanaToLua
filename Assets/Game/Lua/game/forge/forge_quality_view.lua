ForgeQuality = ForgeQuality or BaseClass(BaseRender)

function ForgeQuality:__init(instance, parent_view)

	self.node_list["PromoteBtn"].button:AddClickListener(BindTool.Bind(self.OnClickPromote, self))
	self.node_list["ButtonHelp"].button:AddClickListener(BindTool.Bind(self.OnButtonHelp, self))

	self.curr_state = QualityStateCell.New(self.node_list["LeftFrame"])
	self.next_state = QualityStateCell.New(self.node_list["RightFrame"], true)
	self.material_cell = ItemCell.New()
	self.material_cell:SetInstanceParent(self.node_list["MaterialCell"])

end

function ForgeQuality:__delete()
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

	self.attr_list = {}
end

-- 功能引导按钮
function ForgeQuality:GetPromoteBtn()
	return self.node_list["PromoteBtn"], BindTool.Bind(self.OnClickPromote, self)
end

function ForgeQuality:ClickEquipListCallBack(index)
	self.select_index = index
	self:Flush()
end

function ForgeQuality:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "ui_tween" then
			local ui_cfg = ForgeData.Instance:GetUITweenCfg(TabIndex.forge_quality)
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

	local data = self.cell_data
	local next_data = TableCopy(data)
	local max_quality = ForgeData.Instance:GetMaxColorQuality(self.cell_data.index)
	if max_quality and max_quality == data.param.quality then
		self.is_max_level = true
	else
		self.is_max_level = false
	end

	if self.is_max_level then
		self.next_state:SetMaxLevel(true)
		self.node_list["MaterialNumTxt"].text.text = ""
		self.node_list["MaterialCell"]:SetActive(false)
		self.material_cell:SetData({})
		
		self.node_list["PromoteBtnText"].text.text = Language.Forge.YiManPin
		UI:SetButtonEnabled(self.node_list["PromoteBtn"], false)
		UI:SetGraphicGrey(self.node_list["PromoteBtn"], true)

		self.node_list["LeftFrame"]:SetActive(false)
		self.node_list["Arrow"]:SetActive(false)
	else
		self.next_state:SetMaxLevel(false)
		next_data.param.quality = next_data.param.quality + 1

		local next_cfg = ForgeData.Instance:GetForgeQualityCfg(next_data.index, next_data.param.quality)
		if next_cfg then
			local need_material = next_cfg.stuff_count
			local had_material = ItemData.Instance:GetItemNumInBagById(next_cfg.stuff_id)
			local need_mat_text = need_material
			local had_mat_text = ""
			need_mat_text = ToColorStr(need_material, TEXT_COLOR.GREEN_4)
			had_mat_text = ToColorStr(had_material, (had_material < need_material and COLOR.RED or TEXT_COLOR.GREEN_4))
			self.node_list["MaterialNumTxt"].text.text = had_mat_text .. " / " .. need_mat_text
			self.node_list["MaterialCell"]:SetActive(true)
			self.material_cell:SetData({item_id = next_cfg.stuff_id})

			self.node_list["PromoteBtnText"].text.text = Language.Forge.JinSheng
			UI:SetButtonEnabled(self.node_list["PromoteBtn"], true)
			UI:SetGraphicGrey(self.node_list["PromoteBtn"], false)

			self.node_list["LeftFrame"]:SetActive(true)
			self.node_list["Arrow"]:SetActive(true)
		end
	end
	self.curr_state:SetData(data)
	self.next_state:SetData(next_data)
end

function ForgeQuality:OnClickPromote()
	if nil == self.cell_data then 
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NoSelectEquip)
		return
	end
	ForgeCtrl.Instance:SendUpQualityReq(self.cell_data.index)
end

function ForgeQuality:OnButtonHelp()
	local tips_id = 256
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

--------------------------------------------------
------------- 装备状态 QualityStateCell
--------------------------------------------------
QualityStateCell = QualityStateCell or BaseClass(BaseCell)
function QualityStateCell:__init(instance, is_next)
	self.is_max_level = false
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightNum"])
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
end

function QualityStateCell:__delete()
	if nil ~= self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil
	end

	self.parent_view = nil
	self.item_cfg = nil
	self.strength_cfg = nil
	self.fight_text = nil
end

function QualityStateCell:OnFlush()
	if nil == self.data then return end
	
	if self.is_max_level then
		self.equip_cell:SetFromView(TipsFormDef.FROM_BAG_EQUIP)
	else
		self.equip_cell:SetFromView(TipsFormDef.FROM_FORGE_COMPARE)
	end

	local data = self.data
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if nil == item_cfg then return end

	local quality_cfg = ForgeData.Instance:GetForgeQualityCfg(data.index, data.param.quality)
	local attr_percent = quality_cfg and quality_cfg.attr_percent or 0
	local total_attr, fight_power = self:GetAttrTabAndFight(item_cfg, attr_percent)


	local str = ""
	if self.is_next and quality_cfg then
		str = self.is_max_level and Language.Forge.YiManPin or ToColorStr(quality_cfg.pre, ORDER_COLOR[quality_cfg.c_quality])
		self.node_list["LabelTitle"]:SetActive(not self.is_max_level)
		self.node_list["LabelTitleDesc"].text.text = self.is_max_level and Language.Forge.YiManPin or Language.Forge.NextState[3]
		if self.is_max_level then
			self.node_list["LabelTitleDesc"].transform.localPosition = Vector3(-45, 18, 0)
		else
			self.node_list["LabelTitleDesc"].transform.localPosition = Vector3(-54, 18, 0)
		end
	else
		if quality_cfg then
			str = ToColorStr(quality_cfg.pre, ORDER_COLOR[quality_cfg.c_quality])
		else
			str = Language.Common.No
		end
	end

	self.node_list["EquipName"].text.text = data.name
	self.node_list["LabelTitle"].text.text = str
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = fight_power
	end
	self.equip_cell:SetData(self.data)
	self.equip_cell:ShowEquipGrade(false)
	self.equip_cell:ShowStrengthLable(false)

	for k, v in pairs(self.attr_list) do
		if k <= #total_attr then
			v.attr_value.text.text = total_attr[k].name .. '：'
			v.attr_valueNumber.text.text = math.ceil(total_attr[k].value)
			v.obj:SetActive(true)
		else
			v.obj:SetActive(false)
		end	
	end
end

function QualityStateCell:SetMaxLevel(is_max)
	self.is_max_level = is_max
end

function QualityStateCell:GetAttrTabAndFight(euqip_cfg, up_percent)
	local curr_attr_tab = CommonDataManager.GetAttributteNoUnderline(euqip_cfg)
	if nil ~= up_percent then
		curr_attr_tab = CommonDataManager.MulAttributeNoUnderline(curr_attr_tab, (up_percent / 10000))
	end
	local fight_power = CommonDataManager.GetCapabilityCalculation(curr_attr_tab)
	local total_attr = {}
	local count = 1
	for k, v in pairs(curr_attr_tab) do
		if v > 0 then
			total_attr[count] = {}
			total_attr[count].name = CommonDataManager.GetAttrName(k)
			total_attr[count].value = v
			-- total_attr[count].diff = diff_attr_tab[k] or nil
			count = count + 1
		end
	end
	return total_attr, fight_power
end