PlayerShenEquipView = PlayerShenEquipView or BaseClass(BaseRender)

local EFFECT_CD = 1

function PlayerShenEquipView:__init(instance, parent_view)

	PlayerShenEquipView.Instance = self
	self.parent_view = parent_view

	self.cur_select_index = 0
	self.equip_item_list = {}
	self.is_show_up_arrow = {}

	for i = 1, EquipmentShenData.SHEN_EQUIP_NUM do
		self.equip_item_list[i] = ItemCell.New()
		self.equip_item_list[i]:SetInstanceParent(self.node_list["Item" .. i])
		self.equip_item_list[i]:SetToggleGroup(self.root_node.toggle_group)
		self.equip_item_list[i]:ListenClick(BindTool.Bind(self.OnClickItem, self, i - 1))
		self.equip_item_list[i].root_node.toggle.isOn = (self.cur_select_index == i - 1)
		self.equip_item_list[i]:SetInteractable(true)
		self.is_show_up_arrow[i] = self.node_list["BtnImprove" .. i]
	end
	self.cur_equip_item = ItemCell.New()
	self.cur_equip_item:SetInstanceParent(self.node_list["EquipItem"])

	self.consume_item = ItemCell.New()
	self.consume_item:SetInstanceParent(self.node_list["ConsumeItem"])

	self.node_list["BtnSwitchEquip"].button:AddClickListener(BindTool.Bind(self.OnSwitchToEquip, self))
	self.node_list["BtnOpenTianShiEquip"].button:AddClickListener(BindTool.Bind(self.OnSwitchToEquip, self))
	self.node_list["BtnUp"].button:AddClickListener(BindTool.Bind(self.OnClickUpLevel, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelpBtn, self))

end

function PlayerShenEquipView:__delete()


	

	for k, v in pairs(self.equip_item_list) do
		v:DeleteMe()
	end
	self.equip_item_list = {}
	self.is_show_up_arrow = {}
	self.parent_view = nil

	self.capability_text = nil
	self.is_show_next_level = nil
	self.equip_level = nil
	self.maxhp = nil
	self.add_maxhp = nil
	self.gongji = nil
	self.add_gongji = nil
	self.fangyu = nil
	self.add_fangyu = nil
	self.item_num = nil
	if self.consume_item then
		self.consume_item:DeleteMe()
		self.consume_item = nil
	end

	if self.cur_equip_item then
		self.cur_equip_item:DeleteMe()
		self.cur_equip_item = nil
	end

end

function PlayerShenEquipView:OpenCallBack()
	if self.is_opening then
		return
	end
	self.is_opening = true
	self:Flush()
end

function PlayerShenEquipView:OnSwitchToEquip()
	self.parent_view:OnSwitchToShenEquip(false)
end

function PlayerShenEquipView:OnClickUpLevel()
	EquipmentShenCtrl.Instance:SendShenzhuangUpLevel(self.cur_select_index)
end

function PlayerShenEquipView:OnClickHelpBtn()
	local tips_id = 220
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function PlayerShenEquipView:OnClickItem(index)
	self.cur_select_index = index
	for k,v in pairs(self.equip_item_list) do
		v:ShowHighLight(index == self.cur_select_index)
	end
	self:FlushRightPanel()
end

function PlayerShenEquipView:OnFlush(param_t)
	self:FlushLeftEquipList()
	self:FlushRightPanel()
end

function PlayerShenEquipView:FlushRightPanel()
	local equip_info = EquipmentShenData.Instance:GetEquipData(self.cur_select_index)
	if nil == equip_info then return end

	self.cur_equip_item.image:LoadSprite(ResPath.GetPlayerImage("equipshen_" .. self.cur_select_index))
	self.cur_equip_item:ShowStrengthLable(equip_info.level > 0)
	self.cur_equip_item:SetStrength(equip_info.level)

	local color = math.ceil(equip_info.level / 5)
	color = color <= 6 and color or 6
	color = color > 0 and color or 1
	self.cur_equip_item:SetQualityByColor(color > 0 and color or 1)
	self.cur_equip_item:ShowQuality(color > 0)

	local cfg = EquipmentShenData.Instance:GetShenzhuangCfg(self.cur_select_index, equip_info.level)
	local attr = CommonDataManager.GetAttributteByClass(cfg)
	self.node_list["TxtHPContenValue"].text.text = attr.max_hp
	self.node_list["TxtAtkContentValue"].text.text = attr.gong_ji
	self.node_list["TxtDefContentValue"].text.text = attr.fang_yu
	self.node_list["TxtMZContentValue"].text.text = attr.ming_zhong
	self.node_list["TxtSBContentValue"].text.text = attr.shan_bi
	self.node_list["TxtBJContentValue"].text.text = attr.bao_ji
	self.node_list["TxtJRContentValue"].text.text = attr.jian_ren

	for i = 1, 4 do
		local cur_value
		if i < 4 then
			cur_value = (cfg and cfg["red_ratio_" .. i] or 0) / 100
		else
			cur_value = (cfg and cfg["pink_ratio"] or 0) / 100
		end

	self.node_list["TxtSpcAttrContent1"].text.text = string.format(Language.Player.Equip1,  cur_value)
	self.node_list["TxtSpcAttrContent2"].text.text = string.format(Language.Player.Equip2, cur_value)
	self.node_list["TxtSpcAttrContent3"].text.text = string.format(Language.Player.Equip3, cur_value)
	self.node_list["TxtSpcAttrContentText"].text.text = string.format(Language.Player.Equip4, equip_index_name, cur_value)
	end
	
	local next_cfg = EquipmentShenData.Instance:GetShenzhuangCfg(self.cur_select_index, equip_info.level + 1)
	local next_attr = CommonDataManager.GetAttributteByClass(next_cfg)

	local name = nil ~= cfg and cfg.name or next_cfg.name
	local name_str = "<color=" .. SOUL_NAME_COLOR[color] .. ">" .. name .. "</color>"
	self.node_list["TxtName"].text.text = name_str
	self.node_list["TxtLevel"].text.text = equip_info.level > 0 and  "+" .. equip_info.level or ""
	self.node_list["TxtSpcAttrContent1"].text.text = string.format(Language.Player.Equip1,  Language.Forge.EquipName[self.cur_select_index])
	self.node_list["TxtSpcAttrContent2"].text.text = string.format(Language.Player.Equip2, Language.Forge.EquipName[self.cur_select_index])
	self.node_list["TxtSpcAttrContent3"].text.text = string.format(Language.Player.Equip3, Language.Forge.EquipName[self.cur_select_index])
	self.node_list["TxtSpcAttrContentText"].text.text = string.format(Language.Player.Equip4, equip_index_name, Language.Forge.EquipName[self.cur_select_index])

	self.node_list["NoteHPAddContent"]:SetActive(nil ~= next_cfg)
	self.node_list["NoteAtkAddContent"]:SetActive(nil ~= next_cfg)
	self.node_list["NoteDefAddContent"]:SetActive(nil ~= next_cfg)
	self.node_list["NoteMZAddContent"]:SetActive(nil ~= next_cfg)
	self.node_list["NoteSBAddContent"]:SetActive(nil ~= next_cfg)
	self.node_list["NoteBJAddContent"]:SetActive(nil ~= next_cfg)
	self.node_list["NoteJRAddContent"]:SetActive(nil ~= next_cfg)
	self.node_list["NoteSPecAddContent1"]:SetActive(nil ~= next_cfg)
	self.node_list["NoteSPecAddContent2"]:SetActive(nil ~= next_cfg)
	self.node_list["NoteSPecAddContent3"]:SetActive(nil ~= next_cfg)
	self.node_list["NoteSPecAddContent4"]:SetActive(nil ~= next_cfg)
	self.node_list["PanelLower"]:SetActive(nil ~= next_cfg)

	self.node_list["NoteHPContent"]:SetActive(attr.max_hp > 0 or next_attr.max_hp > 0)
	self.node_list["is_show_gongji"]:SetActive(attr.gong_ji > 0 or next_attr.gong_ji > 0)
	self.node_list["NoteDefContent"]:SetActive(attr.fang_yu > 0 or next_attr.fang_yu > 0)
	self.node_list["NoteMZContent"]:SetActive(attr.ming_zhong > 0 or next_attr.ming_zhong > 0)
	self.node_list["NoteSBContent"]:SetActive(attr.shan_bi > 0 or next_attr.shan_bi > 0)
	self.node_list["NoteBJContent"]:SetActive(attr.bao_ji > 0 or next_attr.bao_ji > 0)
	self.node_list["NoteJRContent"]:SetActive(attr.jian_ren > 0 or next_attr.jian_ren > 0)
	if nil == next_cfg then
		return
	end

	local dif_attr = CommonDataManager.LerpAttributeAttr(attr, next_attr)
	self.node_list["TxtHPContentUpvalue"].text.text = dif_attr.max_hp
	self.node_list["TxtAtkContentUpvalue"].text.text = dif_attr.gong_ji
	self.node_list["TxtDefContentUpvalue"].text.text = dif_attr.fang_yu
	self.node_list["TxtMZContentUpvalue"].text.text = dif_attr.ming_zhong
	self.node_list["TxtSBContentUpvalue"].text.text = dif_attr.shan_bi
	self.node_list["TxtBJContentUpvalue"].text.text = dif_attr.bao_ji
	self.node_list["TxtJRContentUpvalue"].text.text = dif_attr.jian_ren

	for i = 1, 4 do
		local dif, to_level = EquipmentShenData.Instance:GetNextUpSpecialAttr(self.cur_select_index, equip_info.level, i)


		self.node_list["NoteSPecAddContent1"]:SetActive(dif > 0)
		self.node_list["NoteSPecAddContent2"]:SetActive(dif > 0)
		self.node_list["NoteSPecAddContent3"]:SetActive(dif > 0)
		self.node_list["NoteSPecAddContent4"]:SetActive(dif > 0)
		local str = "<color=#33E45DFF>".. dif / 100 .. "%</color>" .. "（" .. "<color=" .. TEXT_COLOR.RED .. ">" .. equip_info.level .. "</color>" ..  "/" .. to_level .. Language.Common.Ji .."）"
		self.node_list["TxtSpcAttrContent1Value"].text.text = str
		self.node_list["TxtSpcAttrContent2Value"].text.text = str
		self.node_list["TxtSpcAttrContent3Value"].text.text = str
		self.node_list["TxtSpcAttrContentValue"].text.text = str
	end

	local data = {}
	data.item_id = cfg and cfg.stuff_id or next_cfg.stuff_id
	data.num = 0
	local num = ItemData.Instance:GetItemNumInBagById(data.item_id)
	self.consume_item:SetShowNumTxtLessNum(0)
	self.consume_item:SetData(data)

	local txt_color = num >= next_cfg.stuff_num and TEXT_COLOR.GREEN or TEXT_COLOR.RED
	self.node_list["TxtUpButton"].text.text = equip_info.level > 0 and Language.Common.Up or Language.Common.Activate
	self.node_list["TxtNum"].text.text = "(" .. "<color=" .. txt_color .. ">" .. num .. "</color>" .. "/" .. next_cfg.stuff_num .. ")"
end

function PlayerShenEquipView:FlushLeftEquipList()
	for i = 1, EquipmentShenData.SHEN_EQUIP_NUM do
		local index = i - 1
		if self.equip_item_list[i] then

			self.equip_item_list[i].image:LoadSprite(ResPath.GetPlayerImage("equipshen_" .. i - 1))

			local equip_info = EquipmentShenData.Instance:GetEquipData(index)
			self.equip_item_list[i]:ShowStrengthLable(equip_info.level > 0)
			self.equip_item_list[i]:SetStrength(equip_info.level)

			local color = math.ceil(equip_info.level / 5)
			color = color <= 6 and color or 7
			self.equip_item_list[i]:SetQualityByColor(color > 0 and color or 1)
			self.equip_item_list[i]:ShowQuality(color > 0)
			self.equip_item_list[i]:SetIconGrayScale(equip_info.level <= 0)

			local next_cfg = EquipmentShenData.Instance:GetShenzhuangCfg(index, equip_info.level + 1)
			if nil ~= next_cfg then
				local num = ItemData.Instance:GetItemNumInBagById(next_cfg.stuff_id)
				self.is_show_up_arrow[i]:SetActive(num >= next_cfg.stuff_num)
			else
				self.is_show_up_arrow[i]:SetActive(false)
			end
		end
	end
	local capability = EquipmentShenData.Instance:GetShenEquipTotalCapability()

	self.node_list["TxtCount"].text.text = capability
	self.node_list["TxtFightPowerNum"].text.text = capability
end

