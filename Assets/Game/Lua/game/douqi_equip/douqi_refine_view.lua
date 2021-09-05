DouqiRefineView = DouqiRefineView or BaseClass(BaseRender)

function DouqiRefineView:__init(instance)
	self.node_list["BtnRefine"].button:AddClickListener(BindTool.Bind(self.OnBtnRefine, self))
	self.node_list["ButtonHelp"].button:AddClickListener(BindTool.Bind(self.OnButtonHelp, self))
	self.node_list["BtnChoose"].button:AddClickListener(BindTool.Bind(self.OnBtnChoose, self))
	self.node_list["BtnChooseFrame"].button:AddClickListener(BindTool.Bind(self.OnBtnChoose, self))

	self.equip_item = ItemCell.New()
	self.equip_item:SetInstanceParent(self.node_list["EquipItem"])


	self.is_open_list = false
	self.choose_data = {}
	self.choose_item_list = {}
	local list_view_delegate = self.node_list["ChooseList"].list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self.equip_item_list = {}
	for i = 1, 10 do
		local item_cell = RefineEquipItemCell.New(self.node_list["Item" .. i])
		item_cell:SetIndex(i)
		item_cell:SetClickCallBack(BindTool.Bind(self.ClcikRefineEquipItemCell, self))
		self.equip_item_list[i] = item_cell
	end

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TextFight"])
end

function DouqiRefineView:__delete()
	for k, v in pairs(self.equip_item_list) do
		v:DeleteMe()
	end
	self.equip_item_list = {}

	if self.equip_item then
		self.equip_item:DeleteMe()
		self.equip_item = nil
	end

	self.fight_text = nil
	self.max_grade = nil
end

----------选择格子
function DouqiRefineView:GetNumberOfCells()
	return self.max_grade
end

function DouqiRefineView:RefreshView(cell, data_index)
	local choose_cell = self.choose_item_list[cell]
	if nil == choose_cell then
		choose_cell = ChooseGradeItemRenderer.New(cell)
		choose_cell:SetClickCallBack(BindTool.Bind(self.ClickChooseItemCell, self))
		self.choose_item_list[cell] = choose_cell
	end

	data_index = (self.max_grade - data_index > 0) and (self.max_grade - data_index) or 1
	choose_cell:SetData(data_index)

	choose_cell:SetHL(data_index == self.choose_grade)
end

function DouqiRefineView:ClickChooseItemCell(cell)
	local data = cell:GetData()
	if nil == data then
		return
	end

	self.is_open_list = false
	self.choose_grade = (data > 0) and data or 1
	self.equip_data = DouQiData.Instance:GetEquipRefineCfg(self.choose_grade, 0, 1)
	self:FlushEquipCell()
	self:FlushEquipAttr()

	for k, v in pairs(self.choose_item_list) do
		v:SetHL(v:GetData() == self.choose_grade)
	end
	self.node_list["ChooseListBg"]:SetActive(false)
	self.node_list["BtnChooseFrame"]:SetActive(false)

	local douqi_cfg = DouQiData.Instance:GetDouqiGradeCfg(self.choose_grade)
	self.node_list["ChooseTxt"].text.text = douqi_cfg.grade_name .. Language.Douqi.ZhuangBei
end
--------- End

function DouqiRefineView:ResetFlag()
	self.max_grade = nil
end

function DouqiRefineView:ClcikRefineEquipItemCell(cell)
	local data = cell:GetData()
	if nil == data then return end

	self.equip_data = data
	self:FLushEquipCellHL()
	self:FlushEquipAttr()
end

function DouqiRefineView:OnFlush(param_t)
	if not self.max_grade then
		local douqi_info = DouQiData.Instance:GetSCCrossEquipAllInfo()
		self.max_grade = douqi_info and douqi_info.douqi_grade or 1

		local tab = {
			[1] = 55,
			[2] = 110,
			[3] = 165,
		}
		if tab[self.max_grade] then
			self.node_list["ChooseListBg"].rect.sizeDelta = Vector2(146, tab[self.max_grade])
		else
			self.node_list["ChooseListBg"].rect.sizeDelta = Vector2(146, 191)
		end
	end
	if not self.choose_grade then
		local douqi_info = DouQiData.Instance:GetSCCrossEquipAllInfo()
		self.choose_grade = douqi_info and douqi_info.douqi_grade or 1
	end
	self.node_list["ChooseList"].scroller:ReloadData(0)

	local douqi_cfg = DouQiData.Instance:GetDouqiGradeCfg(self.choose_grade)
	self.node_list["ChooseTxt"].text.text = douqi_cfg.grade_name .. Language.Douqi.ZhuangBei

	if not self.equip_data then
		self.equip_data = DouQiData.Instance:GetEquipRefineCfg(self.choose_grade, 0, 1)
		self:FlushEquipCell()
	end
	self:FlushEquipAttr()
end

function DouqiRefineView:FlushEquipCell()
	for k, v in pairs(self.equip_item_list) do
		local data = DouQiData.Instance:GetEquipRefineCfg(self.choose_grade, k - 1, 1)
		v:SetData(data)
	end
	self:FLushEquipCellHL()
end

function DouqiRefineView:FLushEquipCellHL()
	for k, v in pairs(self.equip_item_list) do
		local data = v:GetData()
		v:SetHighLight(data and data.equip_id == self.equip_data.equip_id)
	end
end

function DouqiRefineView:FlushEquipAttr()
	local douqi_info = DouQiData.Instance:GetSCCrossEquipAllInfo()
	if nil == self.equip_data or nil == douqi_info then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.equip_data.equip_id)
	if nil == item_cfg then return end

	self.equip_item:SetData({item_id = self.equip_data.equip_id})
	self.node_list["EquipName"].text.text = item_cfg.name

	local desc_color = douqi_info.chuanshi_frament >= self.equip_data.need_fragment and TEXT_COLOR.GREEN or TEXT_COLOR.RED
	self.node_list["Desc2"].text.text = string.format(Language.Douqi.NeedFragments, ToColorStr(douqi_info.chuanshi_frament, desc_color), self.equip_data.need_fragment)
	self.node_list["Desc1"].text.text = string.format(Language.Douqi.CurGrade, self.choose_grade)

	local attr_tab, fight_num = self:GetAttrTabAndFight(item_cfg)
	for i = 1, 3 do
		if attr_tab[i] then
			self.node_list["AttrName" .. i].text.text = attr_tab[i].name .. "："
			self.node_list["AttrNum" .. i].text.text = attr_tab[i].value
			self.node_list["AttrName" .. i]:SetActive(true)
			self.node_list["AttrNum" .. i]:SetActive(true)
		else
			self.node_list["AttrName" .. i]:SetActive(false)
			self.node_list["AttrNum" .. i]:SetActive(false)
		end
	end

	self.fight_text.text.text = fight_num
end

function DouqiRefineView:GetAttrTabAndFight(item_cfg)
	if nil == item_cfg then 
		return {}, 0
	end
	
	local attr_tab = CommonDataManager.GetAttributteNoUnderline(item_cfg)
	local fight_power = CommonDataManager.GetCapability(attr_tab)
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

function DouqiRefineView:OnBtnRefine()
	if nil == self.equip_data or nil == self.choose_grade then return end

	local douqi_info = DouQiData.Instance:GetSCCrossEquipAllInfo()
	if douqi_info.chuanshi_frament >= self.equip_data.need_fragment then
		DouQiCtrl.Instance:SendCSCrossEquipOpera(CROSS_EQUIP_REQ_TYPE.CROSS_EQUIP_REQ_LIANZHI, self.equip_data.equip_index, self.choose_grade)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Douqi.NoEnoughFragment)
	end
end

function DouqiRefineView:OnBtnChoose()
	self.is_open_list = not self.is_open_list
	self.node_list["ChooseListBg"]:SetActive(self.is_open_list)
	self.node_list["BtnChooseFrame"]:SetActive(self.is_open_list)
	if self.is_open_list then
		self.node_list["ChooseList"].scroller:ReloadData(0)
	end
end

function DouqiRefineView:OnButtonHelp()
	local tips_id = 339
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end







-------------------------------------
------ 装备格子 RefineEquipItemCell
RefineEquipItemCell = RefineEquipItemCell or BaseClass(BaseCell)
function RefineEquipItemCell:__init(instance, is_next)
	self.equip_cell = ItemCell.New()
	self.equip_cell:SetInstanceParent(self.node_list["EquipItem"])
	self.equip_cell:ListenClick(BindTool.Bind(self.ClickItem, self))
end

function RefineEquipItemCell:__delete()
	if self.equip_cell then
		self.equip_cell:DeleteMe()
	end
end

function RefineEquipItemCell:ClickItem()
	if nil == self.data then return end

	self.click_callback(self)
end

function RefineEquipItemCell:SetHighLight(enable)
	self.equip_cell:SetHighLight(enable)
end

function RefineEquipItemCell:OnFlush()
	if nil == self.data then 
		return 
	end

	self.equip_cell:SetData({item_id = self.data.equip_id})
end


----------------------------------
-----------选择item
ChooseGradeItemRenderer = ChooseGradeItemRenderer or BaseClass(BaseCell)

function ChooseGradeItemRenderer:__init()
	self.node_list["SelectItem"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function ChooseGradeItemRenderer:__delete()

end

function ChooseGradeItemRenderer:OnFlush()
	if nil == self.data then return end

	local douqi_cfg = DouQiData.Instance:GetDouqiGradeCfg(self.data)
	self.node_list["TxtBtn"].text.text = self.data .. Language.Douqi.Jie .. "·" .. douqi_cfg.grade_name .. Language.Douqi.ZhuangBei
	self.node_list["HLBtnText"].text.text = self.data .. Language.Douqi.Jie .. "·" .. douqi_cfg.grade_name .. Language.Douqi.ZhuangBei
end

function ChooseGradeItemRenderer:SetHL(is_hl)
	self.node_list["HL"]:SetActive(is_hl)
end
