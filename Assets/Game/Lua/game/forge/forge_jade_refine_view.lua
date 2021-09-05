-- 锻造 玉石精炼
ForgeJadeRefine = ForgeJadeRefine or BaseClass(BaseRender)

function ForgeJadeRefine:__init(instance, parent_view)
	self.node_list["BtnJadeRefine"].button:AddClickListener(BindTool.Bind(self.OnBtnJadeRefine, self))
	self.node_list["BtnAuto"].button:AddClickListener(BindTool.Bind(self.OnBtnAuto, self))
	self.node_list["BtnStopAuto"].button:AddClickListener(BindTool.Bind(self.OnBtnStopAuto, self))
	self.node_list["ButtonHelp"].button:AddClickListener(BindTool.Bind(self.OnButtonHelp, self))

	self.jade_list_data = {}
	self.jade_list = {}
	local list_view_delegate = self.node_list["StoneList"].list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshListView, self)

	self.equip_cell = ItemCell.New()
	self.equip_cell:SetInstanceParent(self.node_list["EquipItem"])
	self.equip_cell:SetFromView(TipsFormDef.FROM_BAG_EQUIP)

	self.material_cells = {}
	for i = 1, 3 do
		local cell = ItemCell.New()
		cell:SetInstanceParent(self.node_list["MaterialCell" .. i])
		cell:SetToggleGroup(self.node_list["MaterialCellList"].toggle_group)
		cell:ListenClick(BindTool.Bind(self.ClickMaterialCell, self, i))
		self.material_cells[i] = cell
	end
	self.material_cells[1]:SetHighLight(true)
	self.material_index = 1

	self.progress = ProgressBar.New(self.node_list["ProgressBG"])
end

function ForgeJadeRefine:__delete()
	for k,v in pairs(self.jade_list) do
		v:DeleteMe()
	end
	self.jade_list = {}

	for k,v in pairs(self.material_cells) do
		v:DeleteMe()
	end
	self.material_cells = {}

	if self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil
	end

	self.jade_list_data = {}

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	self.material_index = 1

	if self.progress then
		self.progress:DeleteMe()
		self.progress = nil
	end
end

function ForgeJadeRefine:GetNumberOfCells()
	return #self.jade_list_data or 0
end

function ForgeJadeRefine:RefreshListView(cell, cell_index)
	cell_index = cell_index + 1
	local item_cell = self.jade_list[cell]
	if nil == item_cell then
		item_cell = EquipJadeCell.New(cell.gameObject)
		self.jade_list[cell] = item_cell
	end

	local data = self.jade_list_data[cell_index]
	item_cell:SetIndex(cell_index)
	item_cell:SetRefineLevel(self.jade_info.refine_level)
	item_cell:SetData(data)
end

function ForgeJadeRefine:ClickEquipListCallBack(index)
	self:OnBtnStopAuto()
	self.select_index = index
	self:Flush()
end

function ForgeJadeRefine:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "ui_tween" then
			local ui_cfg = ForgeData.Instance:GetUITweenCfg(TabIndex.forge_jade_refine)
			UITween.MoveShowPanel(self.node_list["DownPanel"] , ui_cfg["DownPanel"], ui_cfg["MOVE_TIME"])
			UITween.MoveShowPanel(self.node_list["UpPanel"] , ui_cfg["UpPanel"], ui_cfg["MOVE_TIME"])
		end
	end
	if self.select_index == nil then return end

	self.cell_data = ForgeData.Instance:GetZhuanzhiEquip(self.select_index)
	if nil == self.cell_data or self.cell_data.item_id <= 0 then 
		return 
	end

	self.jade_info = ForgeData.Instance:GetEquipJadeInfo(self.cell_data.index)
	self.material_cfg = ForgeData.Instance:GetJadeRefineMaterialCfg(self.cell_data.index)
	local max_level = ForgeData.Instance:GetJadeRefineMaxLevel()
	self.is_max_level = max_level <= self.jade_info.refine_level

	self.equip_cell:SetData(self.cell_data)
	self.equip_cell:ShowStrengthLable(false)
	self.node_list["RefineLevelText"].text.text = string.format(Language.Forge.EquipRefineLevel, self.jade_info.refine_level)

	for k, v in pairs(self.material_cfg) do
		local num = ItemData.Instance:GetItemNumInBagById(v.stuff_id)
		self.material_cells[k]:SetData({item_id = v.stuff_id, num = num})
	end

	self:FLushMaterialMsg(self.material_index)
	self:FlushProgress()
	self:FlushJadeList()

	local select_material_num = ItemData.Instance:GetItemNumInBagById(self.material_cfg[self.material_index].stuff_id)
	if select_material_num <= 0 or self.is_max_level then
		self.no_auto = true
		self:OnBtnStopAuto()
	else
		self.no_auto = false
	end

	if self.is_max_level then
		UI:SetButtonEnabled(self.node_list["BtnJadeRefine"], false)
		UI:SetGraphicGrey(self.node_list["BtnJadeRefine"], true)

		self.node_list["BtnAuto"]:SetActive(false)
		self.node_list["BtnJadeRefineText"].text.text = Language.Common.YiManJi
	else
		UI:SetButtonEnabled(self.node_list["BtnJadeRefine"], not self.is_auto_refine)
		UI:SetGraphicGrey(self.node_list["BtnJadeRefine"], self.is_auto_refine)

		self.node_list["BtnAuto"]:SetActive(not self.is_auto_refine)
		self.node_list["BtnJadeRefineText"].text.text = Language.Forge.JadeRefine
	end
end

function ForgeJadeRefine:FlushProgress()
	if self.is_max_level then
		-- self.node_list["ProgressBG"].slider.value = 1
		self.progress:SetValue(1)
		self.node_list["ProgressText"].text.text = ""
	else
		local refine_cfg = ForgeData.Instance:GetJadeRefineCfg(self.jade_info.refine_level)
		self.node_list["ProgressText"].text.text = self.jade_info.refine_val .. "/" .. refine_cfg.consume_refine_val
		-- self.node_list["ProgressBG"].slider.value = self.jade_info.refine_val / refine_cfg.consume_refine_val
		self.progress:SetValue(self.jade_info.refine_val / refine_cfg.consume_refine_val)
	end
end

function ForgeJadeRefine:FlushJadeList()
	self.jade_list_data = {}
	for k, v in pairs(self.jade_info.slot_list) do
		if v.stone_id > 0 then
			table.insert(self.jade_list_data, v)
		end
	end
	self.node_list["StoneList"].scroller:ReloadData(0)
end

function ForgeJadeRefine:ClickMaterialCell(material_index)
	if self.material_index == material_index then
		self.material_cells[material_index]:OnClickItemCell()
	end
	self:OnBtnStopAuto()
	self.material_index = material_index
	self.material_cells[material_index]:SetHighLight(true)
	self:FLushMaterialMsg(material_index)
end

function ForgeJadeRefine:FLushMaterialMsg(material_index)
	if self.material_cfg and self.material_cfg[material_index] then
		local data = self.material_cfg[material_index]
		local item_cfg = ItemData.Instance:GetItemConfig(data.stuff_id)
		local select_material_num = ItemData.Instance:GetItemNumInBagById(data.stuff_id)
		self.node_list["MaterialText"].text.text = string.format(Language.Forge.UseMaterial, item_cfg.name)

		if select_material_num <= 0 or self.is_max_level then
			self.no_auto = true
		else
			self.no_auto = false
		end
	end
end

function ForgeJadeRefine:OnBtnJadeRefine()
	if nil == self.cell_data then 
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NoSelectEquip)
		return
	end

	ForgeCtrl.Instance:SendCSZhuanzhiEquipOpe(ZHUANZHI_EQUIP_OPERATE_TYPE.ZHUANZHI_EQUIP_OPERATE_TYPE_REFINE_STONE, self.cell_data.index, (self.material_index - 1), false)
end

function ForgeJadeRefine:OnBtnAuto()
	if nil == self.cell_data then 
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NoSelectEquip)
		return
	end
	
	if self.is_max_level then
		SysMsgCtrl.Instance:ErrorRemind(Language.Forge.StarMaxLevel)
		return
	end
	UI:SetButtonEnabled(self.node_list["BtnJadeRefine"], false)
	UI:SetGraphicGrey(self.node_list["BtnJadeRefine"], true)
	self.node_list["BtnStopAuto"]:SetActive(true)
	self.node_list["BtnAuto"]:SetActive(false)
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	self.is_auto_refine = true

	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		self:AutoUpgrade()
	end, 0.2)
end

function ForgeJadeRefine:AutoUpgrade()
	if self.no_auto then
		self:OnBtnStopAuto()
	end
	ForgeCtrl.Instance:SendCSZhuanzhiEquipOpe(ZHUANZHI_EQUIP_OPERATE_TYPE.ZHUANZHI_EQUIP_OPERATE_TYPE_REFINE_STONE, self.cell_data.index, (self.material_index - 1), false)
end

function ForgeJadeRefine:OnBtnStopAuto()
	if self.is_max_level then
		UI:SetButtonEnabled(self.node_list["BtnJadeRefine"], false)
		UI:SetGraphicGrey(self.node_list["BtnJadeRefine"], true)
	else
		UI:SetButtonEnabled(self.node_list["BtnJadeRefine"], true)
		UI:SetGraphicGrey(self.node_list["BtnJadeRefine"], false)
	end
	self.node_list["BtnStopAuto"]:SetActive(false)
	self.node_list["BtnAuto"]:SetActive(true)

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	self.is_auto_refine = false
end

function ForgeJadeRefine:OnButtonHelp()
	local tips_id = 261
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end




-----------------------------------------
-- 装备玉石 EquipJadeCell  obj_name:JadeRefineListCell
EquipJadeCell = EquipJadeCell or BaseClass(BaseCell)
function EquipJadeCell:__init()
	self.refine_level = 0
end

function EquipJadeCell:__delete()
	
end

function EquipJadeCell:SetRefineLevel(refine_level)
	self.refine_level = refine_level
end

function EquipJadeCell:OnFlush()
	if not self.data or self.data.stone_id <= 0 then 
		self.Reset()
		return 
	end

	local jade_cfg = ForgeData.Instance:GetJadeAttr(self.data.stone_id)
	local str = ""
	for k, v in pairs(jade_cfg) do
		str = str .. ToColorStr(v.attr_name, "#D0D8FFFF") .. "+" .. v.attr_value .. "  "
	end
	self.node_list["Attr"].text.text = str
	self.node_list["JadeIcon"].image:LoadSprite(ResPath.GetItemIcon(self.data.stone_id))

	local refine_cfg = ForgeData.Instance:GetJadeRefineCfg(self.refine_level)
	local next_refine_cfg = ForgeData.Instance:GetJadeRefineCfg(self.refine_level + 1)

	self.node_list["CurrPrecent"].text.text = refine_cfg.per_attr_add / 100 .. "%"
	if nil ~= next_refine_cfg then
		self.node_list["Arrow"]:SetActive(true)
		self.node_list["UpPrecent"].text.text = next_refine_cfg.per_attr_add / 100 .. "%"
	else
		self.node_list["Arrow"]:SetActive(false)
		self.node_list["UpPrecent"].text.text = ""
	end
end

function EquipJadeCell:Reset()
	self.node_list["Arrow"]:SetActive(false)
	self.node_list["Attr"].text.text = ""
	self.node_list["CurrPrecent"].text.text = ""
	self.node_list["UpPrecent"].text.text = ""
end
