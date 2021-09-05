DouqiEquipSuitView = DouqiEquipSuitView or BaseClass(BaseView)

function DouqiEquipSuitView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab","BaseSecondPanel"},
		{"uis/views/douqiview_prefab", "DouqiSuitView"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
end

function DouqiEquipSuitView:__delete()
end

function DouqiEquipSuitView:ReleaseCallBack()
	for k, v in pairs(self.equip_item_list) do
		v:DeleteMe()
	end
	self.equip_item_list = {}

	for k, v in pairs(self.type_cell_list) do
		v:DeleteMe()
	end
	self.type_cell_list = {}

	for k, v in pairs(self.attr_text_list) do
		v:DeleteMe()
	end
	self.attr_text_list = {}

	if nil ~= self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end

	self.list_view_delegate = nil
	self.attr_text_list_del = nil
end

function DouqiEquipSuitView:LoadCallBack()
	-- self.node_list["AutoRecyc"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["TitleText"].text.text = Language.Douqi.DouqiSuitTitle2
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.Close, self))

	self.equip_item_list = {}
	for i = 1, 10 do
		local item_cell = SuitEquipItemCell.New(self.node_list["Item" .. i])
		item_cell:SetIndex(i)
		self.equip_item_list[i] = item_cell
	end

	self.choose_grade = 10
	self.suit_type_list = {}
	self.type_cell_list = {}
	self.list_view_delegate = self.node_list["List"].list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.RefreshSuitTypeCellNumber, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshSuitTypeCell, self)

	self.attr_data = {}
	self.attr_text_list = {}
	self.attr_text_list_del = self.node_list["TextContent"].list_simple_delegate
	self.attr_text_list_del.NumberOfCellsDel = BindTool.Bind(self.SuitInfoNum, self)
	self.attr_text_list_del.CellRefreshDel = BindTool.Bind(self.SuitInfoCell, self)
	self.attr_text_list_del.CellSizeDel = BindTool.Bind(self.GetCellSizeDel, self)

	self.model_view = RoleModel.New()
	self.model_view:SetDisplay(self.node_list["Display"].ui3d_display)
end

function DouqiEquipSuitView:OpenCallBack()
	if self.node_list["Display"].gameObject.activeInHierarchy then
		self.model_view:SetScale(Vector3(1.2, 1.2, 1.2))
		local role_vo = GameVoManager.Instance:GetMainRoleVo()
		self.model_view:ResetRotation()
		self.model_view:SetModelResInfo(role_vo, nil, nil, nil, nil, false)
	end

	self:Flush()
end

function DouqiEquipSuitView:CloseCallBack()

end

------------左边套装表类型列表
function DouqiEquipSuitView:RefreshSuitTypeCellNumber()
	return #self.suit_type_list
end

function DouqiEquipSuitView:RefreshSuitTypeCell(cell, data_index)
	local item_cell = self.type_cell_list[cell]
	if item_cell == nil then
		item_cell = DouqiSuitInfoCell.New(cell.gameObject)
		item_cell:SetClickCallBack(BindTool.Bind(self.OnClickSuitCell, self, item_cell))
		self.type_cell_list[cell] = item_cell
	end

	data_index = data_index + 1
	local data = self.suit_type_list[data_index] or {}
	item_cell:SetIndex(data_index)
	item_cell:SetData(data)

	item_cell:SetHL(11 - self.choose_grade == data_index)
end

function DouqiEquipSuitView:OnClickSuitCell(cell)
	local data = cell:GetData()
	if nil == data then return end

	self.choose_type_data = data
	self.choose_grade = data.douqi_grade
	self:FlushEquipCellList()
	self:FLushSuitCellHL()

	self.attr_data = DouQiData.Instance:GetDouqiEquipClientSuitAttr(self.choose_grade) or {}
	self.node_list["TextContent"].scroller:ReloadData(0)
end

function DouqiEquipSuitView:FLushSuitCellHL()
	if not self.choose_grade then return end

	for k, v in pairs(self.type_cell_list) do
		v:SetHL(11 - self.choose_grade == v:GetIndex())
	end
end

------------右边属性列表
function DouqiEquipSuitView:SuitInfoNum()
	return #self.attr_data
end

function DouqiEquipSuitView:SuitInfoCell(cell, data_index)
	local attr_cell = self.attr_text_list[cell]
	if attr_cell == nil then
		attr_cell = DouqiAttrCell.New(cell.gameObject)
		self.attr_text_list[cell] = attr_cell
	end

	data_index = data_index + 1
	local data = self.attr_data[data_index]
	attr_cell:SetIndex(data_index)
	attr_cell:SetData(data or {})
end

function DouqiEquipSuitView:GetCellSizeDel(data_index)
	data_index = data_index + 1
	local data = self.attr_data[data_index] or {}
	return (data.attribute_quantity and (data.attribute_quantity * 25 + 35) or 0)
end
---- end

function DouqiEquipSuitView:OnFlush()
	self.suit_type_list = DouQiData.Instance:GetSuitTypeList()
	self.node_list["List"].scroller:RefreshActiveCellViews()

	self:FlushEquipCellList()
	self.attr_data = DouQiData.Instance:GetDouqiEquipClientSuitAttr(self.choose_grade) or {}
	self.node_list["TextContent"].scroller:ReloadData(0)
end

function DouqiEquipSuitView:FlushEquipCellList()
	for k, v in pairs(self.equip_item_list) do
		local equip_cfg = DouQiData.Instance:GetSuitEquip(self.choose_grade, k - 1, 5)				-- 这里套装只针对颜色5的
		v:SetData(equip_cfg or {})
	end
end







-----------------------------
------斗气套装列表
DouqiSuitInfoCell = DouqiSuitInfoCell or BaseClass(BaseCell)

function DouqiSuitInfoCell:__init()
	self.node_list["BtnClick"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function DouqiSuitInfoCell:__delete()

end

function DouqiSuitInfoCell:SetHL(is_hl)
	self.node_list["High"]:SetActive(is_hl)
end

function DouqiSuitInfoCell:OnFlush()
	if nil == self.data then return end

	local color = self.data.color and SOUL_NAME_COLOR[self.data.color] or "#FFFFFFFF"
	self.node_list["Name"].text.text = ToColorStr(self.data.grade_name .. Language.Douqi.TaoZhuang, color)
	self.node_list["HLName"].text.text = ToColorStr(self.data.grade_name .. Language.Douqi.TaoZhuang, color)
end

-------------------------------------
------ 装备格子 SuitEquipItemCell
SuitEquipItemCell = SuitEquipItemCell or BaseClass(BaseCell)
function SuitEquipItemCell:__init(instance, is_next)
	self.equip_cell = ItemCell.New()
	self.equip_cell:SetInstanceParent(self.node_list["EquipItem"])
end

function SuitEquipItemCell:__delete()
	if self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil
	end
end

function SuitEquipItemCell:ClickItem()

end

function SuitEquipItemCell:SetItemCellHL(enable)

end

function SuitEquipItemCell:SetFromView(from_view)
	if self.equip_cell then
		self.equip_cell:SetFromView(from_view)
	end
end

function SuitEquipItemCell:OnFlush()
	if nil == self.data or not next(self.data) then
		self.node_list["EquidSketch"]:SetActive(true)
		self.equip_cell:SetData({})
		return
	end

	self.node_list["EquidSketch"]:SetActive(false)
	self.equip_cell:SetData({item_id = self.data.equip_id})
end

---------------------------------
-------属性列表
DouqiAttrCell = DouqiAttrCell or BaseClass(BaseCell)

function DouqiAttrCell:__init()
end

function DouqiAttrCell:__delete()
end

function DouqiAttrCell:OnFlush()
	if nil == self.data then
		for i = 1, 7 do
			self.node_list["Attr" .. i]:SetActive(false)
		end
	end

	self.node_list["Txttitle"].text.text = string.format(Language.Douqi.SuitCount, self.data.need_count) 

	local attr_num = 0
	local attr_tab, fight_power = self:GetAttrTabAndFight(self.data)
	for k, v in pairs(attr_tab) do
		if 7 >= k then
			attr_num = attr_num + 1
			self.node_list["Attr" .. k].text.text = string.format("%s：%s", v.name, v.value)
			self.node_list["Attr" .. k]:SetActive(true)
		end
	end

	for i = attr_num + 1, 7, 1 do
		self.node_list["Attr" .. i]:SetActive(false)
	end
end

function DouqiAttrCell:GetAttrTabAndFight(suit_cfg)
	if nil == suit_cfg then 
		return {}, 0
	end
	
	local attr_tab = CommonDataManager.GetAttributteNoUnderline(suit_cfg)
	local fight_power = CommonDataManager.GetCapability(attr_tab)
	local sort_attr = CommonDataManager.GetOrderAttributte(attr_tab)
	local total_attr = {}
	local count = 1
	for k, v in pairs(sort_attr) do
		if v.value > 0 then
			total_attr[count] = {}
			total_attr[count].name = CommonDataManager.GetAttrName(v.key)
			if string.find(v.key, "per") or v.key == "skill_zengshang" or v.key == "skill_jianshang" then
				total_attr[count].value = string.format("%s%%", v.value / 100)
			else
				total_attr[count].value = v.value
			end
			count = count + 1
		end
	end
	return total_attr, fight_power
end


