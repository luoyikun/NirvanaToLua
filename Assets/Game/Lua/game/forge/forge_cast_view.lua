-- --装备-天锻（神铸）
ForgeCast = ForgeCast or BaseClass(BaseRender)

function ForgeCast:__init()

	self.node_list["GoGet"].button:AddClickListener(BindTool.Bind(self.ClickGoGet, self))
	self.node_list["BtnUpgrade"].button:AddClickListener(BindTool.Bind(self.SendCast, self))
	-- self.node_list["BtnCastSuit"].button:AddClickListener(BindTool.Bind(self.OpenTotalCast, self))
	self.node_list["ButtonHelp"].button:AddClickListener(BindTool.Bind(self.OnButtonHelp, self))

	self.equip_cell = ItemCell.New()
	self.equip_cell:SetInstanceParent(self.node_list["EquipItemCell"])
	self.equip_cell:SetFromView(TipsFormDef.FROM_BAG_EQUIP)
	self.material_cell = ItemCell.New()
	self.material_cell:SetInstanceParent(self.node_list["MaterialCell"])

	self.star_list = {}
	for i = 1, 5 do
		self.star_list[i] = self.node_list["Star" .. i]
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
			item_tab.name = variable_table["AttrName"]
			item_tab.attr_value = variable_table["Value"]
			item_tab.up_diff = variable_table["UpDiffNum"]
			item_tab.up_img = variable_table["UpImg"]
			self.attr_list[count] = item_tab
			count = count + 1
		end
	end

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightPowerNum"])
end

function ForgeCast:__delete()
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

function ForgeCast:ClickEquipListCallBack(index)
	self.select_index = index
	self:Flush()
end

function ForgeCast:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "ui_tween" then
			local ui_cfg = ForgeData.Instance:GetUITweenCfg(TabIndex.forge_cast)
			UITween.MoveShowPanel(self.node_list["RightPanel"] , ui_cfg["RightPanel"], ui_cfg["MOVE_TIME"])
			UITween.AlpahShowPanel(self.node_list["LeftPanel"] , ui_cfg["LeftPanel"], ui_cfg["MOVE_TIME"], DG.Tweening.Ease.InExpo)
		end
	end

	if self.select_index == nil then 
		self:ClearData()
		return
	end

	local data_list = EquipData.Instance:GetDataList()
	self.cell_data = data_list[self.select_index]
	if nil == self.cell_data or nil == self.cell_data.item_id then 
		self:ClearData()
		return 
	end

	local data = self.cell_data
	local curr_level = data.param.shen_level
	self.equip_cell:SetData(self.cell_data)
	self.equip_cell:ShowEquipGrade(false)
	self.equip_cell:ShowStrengthLable(false)

	self.max_level = ForgeData.Instance:GetMaxShenOpLevel(data.index)
	local curr_cfg = ForgeData.Instance:GetShenOpSingleCfg(data.index, curr_level)
	local is_max_level = false
	if self.max_level > curr_level then
		self.next_cfg = ForgeData.Instance:GetShenOpSingleCfg(data.index, (curr_level + 1))
	else
		is_max_level = true
		self.next_cfg = curr_cfg
	end

	if nil == self.next_cfg then return end 

	if curr_level > 0 then
		local bundle, asset = ResPath.GetForgeItemName(curr_level)
		self.node_list["EquipName"].image:LoadSprite(bundle, asset)
		self.node_list["EquipName"]:SetActive(true)
	else
		self.node_list["EquipName"]:SetActive(false)
	end

	self.material_cell:SetData({item_id = self.next_cfg.stuff_id})
	local need_item_num = self.next_cfg.stuff_count
	local had_item_num = ItemData.Instance:GetItemNumInBagById(self.next_cfg.stuff_id)
	local need_item_text = " / " .. need_item_num
	local had_item_text = ""
	need_item_text = ToColorStr(need_item_text,TEXT_COLOR.GREEN_4)
	had_item_text = ToColorStr(had_item_num, (had_item_num < need_item_num and COLOR.RED or TEXT_COLOR.GREEN_4))
	self.node_list["MaterialNum"].text.text = had_item_text .. need_item_text

	local total_attr, fight_power = self:GetAttrTabAndFight(curr_cfg, self.next_cfg)
	for k, v in pairs(self.attr_list) do
		if k <= #total_attr then
			v.name.text.text = total_attr[k].name .. '：'
			v.attr_value.text.text = total_attr[k].value
			v.up_diff.text.text = total_attr[k].diff
			v.up_diff:SetActive(not is_max_level)
			v.up_img:SetActive(not is_max_level)
			v.obj:SetActive(true)
		else
			v.up_img:SetActive(false)
			v.obj:SetActive(false)
		end	
	end
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = fight_power
	end

	if curr_cfg then
		local curtext = string.format(Language.Forge.ShenZhuCurAttrDesc, Language.Forge.EquipName[data.index], curr_cfg.attr_percent)
		self.node_list["CurrSuitAttr"].text.text = curtext
	else
		local curtext = string.format(Language.Forge.ShenZhuCurAttrDesc, Language.Forge.EquipName[data.index], 0)
		self.node_list["CurrSuitAttr"].text.text = curtext
	end

	if is_max_level then
		self.node_list["NextSuitAttr"].text.text = ""
		self.node_list["MaterialNum"].text.text = Language.Common.MaxLevelDesc

		self.node_list["ButUpgradeText"].text.text = Language.Common.YiManJi
		UI:SetButtonEnabled(self.node_list["BtnUpgrade"], false)
	else
		local next_shen_level = ForgeData.Instance:GetNextUpAttrLevel(data.index, data.param.shen_level) or 0
		local next_attr_cfg = ForgeData.Instance:GetShenOpSingleCfg(data.index, next_shen_level)
		local next_attr_present_num = next_attr_cfg and next_attr_cfg.attr_percent or 0
		local next_attr_present = string.format(Language.Forge.ShenZhuNextAttrDesc, Language.Forge.EquipName[data.index], next_attr_present_num)
		local next_limit_text = "("..string.format("<color=#f9463b>%s</color>", curr_level .. "") .. "/" .. next_shen_level ..")"
		self.node_list["NextSuitAttr"].text.text = string.format("%s%s", next_attr_present, next_limit_text)

		self.node_list["ButUpgradeText"].text.text = Language.Forge.ShenZhu
		UI:SetButtonEnabled(self.node_list["BtnUpgrade"], true)
	end

	self:ShowStarByLevel(curr_level)
end

function ForgeCast:ShowStarByLevel(star_level)
	if star_level <= 0 then 
		for i = 1, 5 do
			self.star_list[i]:SetActive(false)
		end
		return
	end

	local star_type = math.floor(star_level / 5)
	local star_count = star_level % 5

	for i = 1, 5 do
		local name = ""
		if i <= star_count then
			self.star_list[i]:SetActive(true)
			if star_type + 1 == 6 then
				name = ("cast_icon_star_big6")
			else
				name = ("icon_star_big" .. star_type + 1)
			end
		else
			if star_level < 5 then
				self.star_list[i]:SetActive(false)
			else
				self.star_list[i]:SetActive(true)
				if star_type == 6 then
					name = ("cast_icon_star_big6")
				else
					name = ("icon_star_big" .. star_type)
				end
			end
		end
		if name ~= "" then
			local bubble, asset = ResPath.GetImages(name)
			self.star_list[i].image:LoadSprite(bubble, asset)
		end
	end
end

function ForgeCast:GetAttrTabAndFight(curr_cfg, next_cfg)
	local curr_attr_tab = not curr_cfg and CommonStruct.Attribute() or  CommonDataManager.GetAttributteByClass(curr_cfg)
	local next_attr_tab = CommonDataManager.GetAttributteByClass(next_cfg)
	local diff_attr_tab = CommonDataManager.LerpAttributeAttr(curr_attr_tab, next_attr_tab)
	local fight_power = CommonDataManager.GetCapabilityCalculation(curr_attr_tab)
	local sort_curr_attr= CommonDataManager.GetOrderAttributte(curr_attr_tab)
	local sort_next_attr= CommonDataManager.GetOrderAttributte(next_attr_tab)
	local sort_diff_attr = CommonDataManager.GetOrderAttributte(diff_attr_tab)
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

--点击了神铸
function ForgeCast:SendCast()
	if self.cell_data == nil or self.cell_data.item_id == nil then
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NoSelectEquip)
		return
	end
	
	if self.is_max_level then
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.CastEndHighest)
		return
	end
	
	ForgeCtrl.Instance:SendCast(self.cell_data.index)
end

--点击了前往获取
function ForgeCast:ClickGoGet()
	ViewManager.Instance:Open(ViewName.Treasure)
end

-- 屏蔽
-- function ForgeCast:OpenTotalCast()
-- 	local level, current_cfg, next_cfg = ForgeData.Instance:GetFullCastLevel()
-- 	TipsCtrl.Instance:ShowTotalAttrView(Language.Forge.ForgeCastSuitAtt, level, current_cfg, next_cfg)
-- end

function ForgeCast:OnButtonHelp()
	local tips_id = 258
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ForgeCast:ClearData()
	self.material_cell:SetData({})
	self.equip_cell:SetData({})
	for i = 1, 5 do
		self.star_list[i]:SetActive(false)
	end
	for k, v in pairs(self.attr_list) do
		v.obj:SetActive(false)
	end

	self.node_list["EquipName"]:SetActive(false)
	self.node_list["CurrSuitAttr"].text.text = ""
	self.node_list["NextSuitAttr"].text.text = ""
	self.node_list["MaterialNum"].text.text = ""
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = ""
	end
end