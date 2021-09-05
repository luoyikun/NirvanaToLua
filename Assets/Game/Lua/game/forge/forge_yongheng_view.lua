--品质（永恒）   原本的品质ForgeQuality 屏蔽
ForgeYongHengView = ForgeYongHengView or BaseClass(BaseRender)

function ForgeYongHengView:__init(instance)
	self.node_list["BtnYongHeng"].button:AddClickListener(BindTool.Bind(self.OnClickYongHeng, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["BtnToJingJie"].button:AddClickListener(BindTool.Bind(self.OnBtnToJingJie, self))

	self.equip_item_list = {}
	for i = 0, 10 do
		local item_cell = YongHengEquipItemCell.New(self.node_list["EquipItem" .. (i + 1)])
		item_cell:SetIndex(i)
		item_cell:SetToggleGroup(self.node_list["ToggleGroup"].toggle_group)
		item_cell:SetClickCallBack(BindTool.Bind(self.ClcikEquipItemCell, self))
		self.equip_item_list[i] = item_cell

		UI:SetGraphicGrey(self.node_list["NormalImage" .. i], true)
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
			item_tab["Attr"] = variable_table["Attr"]
			item_tab["Arrow"] = variable_table["Arrow"]
			item_tab["AttrDiff"]= variable_table["AttrDiff"]
			self.attr_list[count] = item_tab
			count = count + 1
		end
	end

	self.next_equip = ItemCell.New()
	self.next_equip:SetInstanceParent(self.node_list["NextEquip"])

	self.material_cell = ItemCell.New()
	self.material_cell:SetInstanceParent(self.node_list["MaterialCell"])

	self:FlushLeftEquipPanel()
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["PowerTxt"])
end

function ForgeYongHengView:__delete()
	for k, v in pairs(self.equip_item_list) do
		v:DeleteMe()
	end
	self.equip_item_list = {}

	if self.material_cell then
		self.material_cell:DeleteMe()
		self.material_cell = nil
	end

	if self.next_equip then
		self.next_equip:DeleteMe()
		self.next_equip = nil
	end

	self.attr_list = {}
	self.fight_text = nil
end

function ForgeYongHengView:ClcikEquipItemCell(equip_index)
	for k, v in pairs(self.equip_item_list) do
		if v:GetIndex() == equip_index then
			v:SetItemCellHL(true)
		else
			v:SetItemCellHL(false)
		end
	end
	self.select_index = equip_index
	self:Flush()
end

function ForgeYongHengView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "ui_tween" then
			local ui_cfg = ForgeData.Instance:GetUITweenCfg(TabIndex.forge_yongheng)
			UITween.MoveShowPanel(self.node_list["LeftPanel"] , ui_cfg["LeftPanel"], ui_cfg["MOVE_TIME"])
			UITween.MoveShowPanel(self.node_list["FightPowerLabel"] , ui_cfg["FightPowerLabel"], ui_cfg["MOVE_TIME"])
			UITween.MoveShowPanel(self.node_list["RightPanel"] , ui_cfg["RightPanel"], ui_cfg["MOVE_TIME"])
		end
	end

	local equip_data = EquipData.Instance:GetDataList()
	self.cell_data = equip_data[self.select_index]
	if nil == self.cell_data or nil == self.cell_data.item_id then
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NoHaveEquip)
		-- local suit_cfg = ForgeData.Instance:GetSuitCfgByIndex(1)
		-- self.node_list["SuitNowTxt"].text.text = suit_cfg.name .. ":(0/11)"
		return 
	end

	local data = self.cell_data



	local curr_cfg = ForgeData.Instance:GetEternityEquipCfg(data.index, data.param.eternity_level)
	local next_cfg = ForgeData.Instance:GetEternityEquipCfg(data.index, data.param.eternity_level + 1)
	if nil == next_cfg then
		local max_level = ForgeData.Instance:GetEternityMaxLevel(data.index)
		if max_level and max_level == data.param.eternity_level then
			self.node_list["YiManJiText"]:SetActive(true)
			self.is_max_level = true
			self.next_equip:SetActive(false)
		else
			self.node_list["YiManJiText"]:SetActive(false)
			self.next_equip:SetActive(true)
			self.next_equip:SetData({})
			return
		end
	else
		self.next_cfg = next_cfg
		self.is_max_level = false

		self.next_equip:SetActive(true)
		self.node_list["YiManJiText"]:SetActive(false)
		local next_data = TableCopy(data)
		next_data.param = {}
		next_data.param.eternity_level = data.param.eternity_level + 1
		self.next_equip:SetData(next_data)
		self.next_equip:ShowEquipGrade(false)
	end

	if nil == curr_cfg then return end 

	self.material_cell:SetData({item_id = curr_cfg.stuff_id})
	self.node_list["MaterialNumTxt"]:SetActive(false)
	if self.is_max_level then
		self.node_list["MaterialNumTxt"].text.text = Language.Common.MaxLevelDesc
		self.node_list["BtnYongHengText"].text.text = Language.Common.YiManJi

		UI:SetButtonEnabled(self.node_list["BtnYongHeng"], false)
		UI:SetGraphicGrey(self.node_list["BtnYongHeng"], true)
	else
		local need_material = curr_cfg.stuff_count
		local had_material = ItemData.Instance:GetItemNumInBagById(curr_cfg.stuff_id)
		local need_mat_text = need_material
		local had_mat_text = ""
		need_mat_text = ToColorStr(need_material, TEXT_COLOR.GREEN_4)
		had_mat_text = ToColorStr(had_material, (had_material < need_material and COLOR.RED or TEXT_COLOR.GREEN_4))
		-- self.node_list["MaterialNumTxt"].text.text = 
		local num_str = had_mat_text .. "/" .. need_mat_text
		self.material_cell:SetItemNumVisible(true, num_str)
		self.node_list["BtnYongHengText"].text.text = Language.Title.Forge

		UI:SetButtonEnabled(self.node_list["BtnYongHeng"], true)
		UI:SetGraphicGrey(self.node_list["BtnYongHeng"], false)
	end

	local attr, fight_power = self:GetAttrTabAndFight(curr_cfg, next_cfg)
	for k, v in pairs(self.attr_list) do
		if attr[k] then
			v.obj:SetActive(true)
			v["Attr"].text.text = attr[k].name .. " : " .. ToColorStr(attr[k].value, TEXT_COLOR.WHITE) 
			if attr[k].diff and attr[k].diff > 0 then
				v["AttrDiff"].text.text = attr[k].diff
				v["Arrow"]:SetActive(true)
			else
				v["AttrDiff"].text.text = ""
				v["Arrow"]:SetActive(false)
			end
		else
			v.obj:SetActive(false)
		end
	end

	local suit_level = ForgeData.Instance:GetSelectSuitLevel(data.param.eternity_level)
	local next_suit_cfg = nil
	-- local suit_cfg = ForgeData.Instance:GetEternitySuitLevel(suit_level) or ForgeData.Instance:GetSuitCfgByIndex(1)
	local curr_suit_cfg =  ForgeData.Instance:GetCurrEternitySuitLevel()
	local suit_count = 0

	if curr_suit_cfg and suit_level < 10 and curr_suit_cfg.suit_level == suit_level then
		next_suit_cfg = ForgeData.Instance:GetSuitCfgByIndex(suit_level + 1) or ForgeData.Instance:GetSuitCfgByIndex(1)
	else
		next_suit_cfg = ForgeData.Instance:GetSuitCfgByIndex(suit_level) or ForgeData.Instance:GetSuitCfgByIndex(1)
	end

	for i = 0, 10 do
		if nil == equip_data[i] then 
			self.node_list["HighLightText" .. i]:SetActive(false)
			UI:SetGraphicGrey(self.node_list["NormalImage" .. i], true)
		else
			if equip_data[i].param.eternity_level >= next_suit_cfg.suit_level then
				self.node_list["HighLightText" .. i]:SetActive(true)
				UI:SetGraphicGrey(self.node_list["NormalImage" .. i], false)
				suit_count = suit_count + 1
			else
				self.node_list["HighLightText" .. i]:SetActive(false)
				UI:SetGraphicGrey(self.node_list["NormalImage" .. i], true)
			end
		end
	end

	self.node_list["SuitAttr1"].text.text = string.format(Language.Forge.YonghengCurPercent1, curr_suit_cfg and (curr_suit_cfg.hxyj / 100) or 0)
	self.node_list["SuitAttr2"].text.text = string.format(Language.Forge.YonghengCurPercent2, curr_suit_cfg and (curr_suit_cfg.hxyj_hurt_per / 100) or 0)

	local cur_hxyj = 0
	local cur_hxyj_hurt_per = 0
	if curr_suit_cfg then
		cur_hxyj = curr_suit_cfg.hxyj
		cur_hxyj_hurt_per = curr_suit_cfg.hxyj_hurt_per
	end

	if next_suit_cfg then
		self.node_list["UpArrow1"]:SetActive(true)
		self.node_list["UpArrow2"]:SetActive(true) 
		self.node_list["SuitNextAttr1"].text.text = (next_suit_cfg.hxyj - cur_hxyj) / 100 .. "%"
		self.node_list["SuitNextAttr2"].text.text = (next_suit_cfg.hxyj_hurt_per - cur_hxyj_hurt_per) / 100 .. "%"
	else
		self.node_list["UpArrow1"]:SetActive(false) 
		self.node_list["UpArrow2"]:SetActive(false) 
		self.node_list["SuitNextAttr1"].text.text = ""
		self.node_list["SuitNextAttr2"].text.text = ""
	end
	local suit_name = next_suit_cfg and next_suit_cfg.name or (curr_suit_cfg and curr_suit_cfg.name or "")
	self.node_list["CurrSuitName"].text.text = string.format(Language.Forge.MiddlesSuitName, suit_name, suit_count)

	local item_cfg = ItemData.Instance:GetItemConfig(self.cell_data.item_id)

	-- self.node_list["SuitNowTxt"].text.text = next_suit_cfg.name .. ":(" .. suit_count .. " / 11)"
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = fight_power
	end

	local next_name = next_cfg and next_cfg.name or curr_cfg.name
	self.node_list["EquipNameTxt"].text.text = next_name .. "·" .. item_cfg.name

	self:FlushLeftEquipPanel()
end

function ForgeYongHengView:FlushLeftEquipPanel()
	local equip_data = EquipData.Instance:GetDataList()
	for i = 0, 10 do
		self.equip_item_list[i]:SetData(equip_data[i])
	end
end

function ForgeYongHengView:GetAttrTabAndFight(curr_equip_cfg, next_equip_cfg)
	local curr_attr_tab = CommonDataManager.GetAttributteByClass(curr_equip_cfg)
	local next_attr_tab = {}
	local diff_attr_tab = {}
	if next_equip_cfg and next(next_equip_cfg) then
		next_attr_tab = CommonDataManager.GetAttributteByClass(next_equip_cfg)
		diff_attr_tab = CommonDataManager.LerpAttributeAttr(curr_attr_tab, next_attr_tab)
	end
	local sort_curr_attr= CommonDataManager.GetOrderAttributte(curr_attr_tab)
	local sort_next_attr= CommonDataManager.GetOrderAttributte(next_attr_tab)
	local sort_diff_attr = CommonDataManager.GetOrderAttributte(diff_attr_tab)

	local fight_power = CommonDataManager.GetCapabilityCalculation(curr_attr_tab)
	local total_attr = {}
	local count = 1
	for k, v in pairs(sort_curr_attr) do
		if v.value > 0 or (sort_next_attr[k] and sort_next_attr[k].value and sort_next_attr[k].value > 0) then
			total_attr[count] = {}
			total_attr[count].name = CommonDataManager.GetAttrName(v.key)
			total_attr[count].value = v.value
			total_attr[count].diff = sort_diff_attr[k].value or nil 
			count = count + 1
		end
	end
	return total_attr, fight_power
end

function ForgeYongHengView:OnClickYongHeng()
	if nil == self.cell_data then 
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NoSelectEquip)
		return
	end

	if self.next_cfg then
		local cur_jingjie_level = JingJieData.Instance:GetjingjieLevel()
		if self.next_cfg.jingjie_level and self.next_cfg.jingjie_level > cur_jingjie_level then
			TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Forge.NoJingJieLevel, self.next_cfg.name))
			return
		end
	end

	ForgeCtrl.Instance:SendEquipUpEternityReq(self.select_index)
end

function ForgeYongHengView:OnClickHelp()
	local tips_id = 257
  	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ForgeYongHengView:OnBtnToJingJie()
	if not ViewManager.Instance:IsOpen(ViewName.BaoJu) then
		ViewManager.Instance:Open(ViewName.BaoJu, TabIndex.baoju_jingjie)
	else
		ViewManager.Instance:Close(ViewName.Forge)
	end
end

function ForgeYongHengView:GetYongHengBtn()
	return self.node_list["BtnYongHeng"], BindTool.Bind(self.OnClickYongHeng, self)
end

-------------------------------------
------ 装备格子 YongHengEquipItemCell
YongHengEquipItemCell = YongHengEquipItemCell or BaseClass(BaseCell)
function YongHengEquipItemCell:__init(instance, is_next)
	self.equip_cell = ItemCell.New()
	self.equip_cell:SetInstanceParent(self.node_list["EquipItem"])

	self.equip_cell:ListenClick(BindTool.Bind(self.ClickItem, self))
end

function YongHengEquipItemCell:__delete()
	if self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil
	end
end

function YongHengEquipItemCell:ClickItem()
	if self.click_callback then
		self.click_callback(self.index)
	end
end

function YongHengEquipItemCell:SetItemCellHL(enable)
	if self.data then
		self.equip_cell:ShowHighLight(enable)
	end
end

function YongHengEquipItemCell:OnFlush()
	if nil == self.data then 
		self:SetDefaultIcon()
		return 
	end

	self.equip_cell:SetData(self.data)
	local is_can_up = ForgeData.Instance:GetEquipEternityCanImprove(self.data)
	self.node_list["BtnImprove"]:SetActive(0 == is_can_up)

	local yongheng_cfg = ForgeData.Instance:GetEternityEquipCfg(self.data.index, self.data.param.eternity_level)
	self.equip_cell:ShowStrengthLable(true)
	self.equip_cell:ShowEquipGrade(false)
	self.equip_cell:SetIconGrayScale(false)
	if yongheng_cfg then
		self.equip_cell:SetStrength(yongheng_cfg.name)
	end
end

function YongHengEquipItemCell:SetDefaultIcon()
	local item_id = EquipData.Instance:GetDefaultIcon(self.index)
	local asset, bundle = ResPath.GetItemIcon(item_id)
	self.equip_cell:SetAsset(asset, bundle)
	self.equip_cell:SetIconGrayScale(true)
	self.equip_cell:SetIconGrayVisible(false)
	self.equip_cell:SetInteractable(false)
end

function YongHengEquipItemCell:SetToggleGroup(toggle_group)
	-- self.root_node.toggle.group = toggle_group
	self.equip_cell:SetToggleGroup(toggle_group)
end