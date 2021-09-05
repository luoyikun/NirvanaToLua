MarryEquipSuitView = MarryEquipSuitView or BaseClass(BaseRender)
order = {
	"一",
	"二",
	"三",
	"四",
	"五",
	"六",
	"七",
	"八",
	"九",
	"十",
}
function MarryEquipSuitView:__init(instance, mother_view)
	self.main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	self.qingyuan_equip_handbook = MarryEquipData.Instance:GetCurrentHandBook()
	self.current_suit_index = 0

	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.item_cell_list = {}
	for i = 0, 3 do
		local equip_obj = self.node_list["EquipList"].transform:GetChild(i).gameObject
		local equip_cell = MarryEquipSuitEquipItem.New(equip_obj)
		equip_cell:SetSuitType(self.current_suit_index)
		equip_cell:SetIndex(i)
		equip_cell:SetSex(self.main_role_vo.sex)
		equip_cell:SetData(self.qingyuan_equip_handbook[self.current_suit_index][i + 1])
		table.insert(self.item_cell_list, equip_cell)
	end

	self.item_cell_list_1 = {}
	for i = 0, 3 do
		local equip_obj = self.node_list["EquipList1"].transform:GetChild(i).gameObject
		local equip_cell = LoverMarryEquipSuitEquipItem.New(equip_obj)
		equip_cell:SetSuitType(self.current_suit_index)
		equip_cell:SetIndex(i)
		equip_cell:SetSex(self.main_role_vo.sex == 0 and 1 or 0)
		equip_cell:SetData(self.qingyuan_equip_handbook[self.current_suit_index][i + 1])
		table.insert(self.item_cell_list_1, equip_cell)
	end

	self.contain_cell_list = {}
	self.node_list["ImgBg"].button:AddClickListener(BindTool.Bind(self.ClickHelp, self))
	self.node_list["BtnGirl"].button:AddClickListener(BindTool.Bind(self.ClickGetPere, self))
	self.node_list["BtnMan"].button:AddClickListener(BindTool.Bind(self.ClickGetPere, self))
end

function MarryEquipSuitView:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}

	for k,v in pairs(self.item_cell_list_1) do
		v:DeleteMe()
	end
	self.item_cell_list_1 = {}

	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}

	if nil ~= self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if nil ~= self.model_1 then
		self.model_1:DeleteMe()
		self.model_1 = nil
	end
end

function MarryEquipSuitView:OpenCallBack()
	self:FlushView()
end

function MarryEquipSuitView:FlushView()
	self.node_list["LoverMarryLevel2"].text.text = string.format(Language.Marriage.MarriageLevel, MarryEquipData.Instance:GetLoverMarryInfo().marry_level)
	self.node_list["LoverMarryLevel1"].text.text = string.format(Language.Marriage.MarriageLevel, MarryEquipData.Instance:GetMarryInfo().marry_level)
	self:FlushModel()
	self.main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	self:FlushLeftCell()
	self.node_list["ListView"].scroller:ReloadData(0)
end

function MarryEquipSuitView:GetNumberOfCells()
	return #self.qingyuan_equip_handbook + 1
end

function MarryEquipSuitView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = MarryEquipSuitViewItem.New(cell.gameObject)
		self.contain_cell_list[cell] = contain_cell
		contain_cell:SetClickCallBack(BindTool.Bind(self.OnClickSuit, self))
		contain_cell:SetToggleGroup(self.node_list["ListView"].toggle_group)
	end
	cell_index = cell_index + 1
	contain_cell:SetIndex(cell_index)
	contain_cell:SetSex(self.main_role_vo.sex)
	contain_cell:SetData(self.qingyuan_equip_handbook[cell_index - 1])
	if (cell_index - 1) ~= self.current_suit_index then
		contain_cell.node_list["bg_toggle"].toggle.isOn = false
	else
		contain_cell.node_list["bg_toggle"].toggle.isOn = true
	end
end

function MarryEquipSuitView:FlushFightPower()
	local power = 0
	local all_equip_info = self.qingyuan_equip_handbook[self.current_suit_index]
	for i = 0, 3 do
		if MarryEquipData.Instance:GetMarrySuitActive(self.current_suit_index, i) then
			power = power + CommonDataManager.GetCapability(all_equip_info[ i + 1])
		end
	end
	self.node_list["Count"].text.text = power

	self.node_list["TxtMarrytips"].text.text = string.format(Language.Marriage.MarriagePower, all_equip_info[1].banlv_add_per * 0.01)

	power = 0
	for i = 0, 3 do
		if MarryEquipData.Instance:GetLoverMarrySuitActive(self.current_suit_index, i) then
			power = power + CommonDataManager.GetCapability(all_equip_info[ i + 1])
		end
	end
 	self.node_list["Count1"].text.text = power
end

function MarryEquipSuitView:FlushModel()
	if nil == self.model then
		self.model = RoleModel.New()
		self.model:SetDisplay(self.node_list["ModelDisplay"].ui3d_display)
	end

	local role_vo = {}
	role_vo.prof = self.main_role_vo.prof
	role_vo.sex = self.main_role_vo.sex
	role_vo.appearance = {}
	role_vo.appearance.fashion_body = 2
	self.model:SetModelResInfo(role_vo, true, true, true, true)	
	-- if role_vo.prof == 4 then
	-- 	self.model.display.transform:FindHard("UICamera").transform.localPosition = MarriageData.Instance:GetDisplayPosition("loliCommon").position
	-- 	self.model.display.transform:FindHard("UICamera").transform.eulerAngles = MarriageData.Instance:GetDisplayPosition("loliCommon").rotation
	-- else
	-- 	self.model.display.transform:FindHard("UICamera").transform.localPosition = MarriageData.Instance:GetDisplayPosition("personCommon").position
	-- 	self.model.display.transform:FindHard("UICamera").transform.eulerAngles = MarriageData.Instance:GetDisplayPosition("personCommon").rotation
	-- end

		--有伴侣才加载伴侣模型
	if self.main_role_vo.lover_uid > 0 then
		self.node_list["ModelDisplay1"]:SetActive(true)
		self.node_list["Note"]:SetActive(false)
		if nil == self.model_1 then
			self.model_1 = RoleModel.New()
			self.model_1:SetDisplay(self.node_list["ModelDisplay1"].ui3d_display)
		end
		local lover_vo = {}
		lover_vo.prof = MarriageData.Instance:GetLoverProf()
		lover_vo.sex = self.main_role_vo.sex == 0 and 1 or 0
		lover_vo.appearance = {}
		lover_vo.appearance.fashion_body = 2
		self.model_1:SetModelResInfo(lover_vo, true, true, true, true)
		-- if lover_vo.prof == 4 then
		-- 	self.model_1.display.transform:FindHard("UICamera").transform.localPosition = MarriageData.Instance:GetDisplayPosition("loliCommon").position
		-- 	self.model_1.display.transform:FindHard("UICamera").transform.eulerAngles = MarriageData.Instance:GetDisplayPosition("loliCommon").rotation
		-- else
		-- 	self.model_1.display.transform:FindHard("UICamera").transform.localPosition = MarriageData.Instance:GetDisplayPosition("personCommon").position
		-- 	self.model_1.display.transform:FindHard("UICamera").transform.eulerAngles = MarriageData.Instance:GetDisplayPosition("personCommon").rotation
		
		-- end
	else
		local is_man = self.main_role_vo.sex == 1
		self.node_list["ImgGirl"]:SetActive(is_man)
		self.node_list["ImgMan"]:SetActive(not is_man)
		self.node_list["ModelDisplay1"]:SetActive(false)
		self.node_list["Note"]:SetActive(true)
	end
end

function MarryEquipSuitView:OnFlush()
	self:FlushView()
end

function MarryEquipSuitView:OnClickSuit(suit_cell)
	self.current_suit_index = suit_cell:GetIndex() - 1
	self:FlushLeftCell()
	if not suit_cell:GetActive() then
		local str = string.format(Language.Marriage.SuitTips1, order[self.current_suit_index + 1])
		SysMsgCtrl.Instance:ErrorRemind(str)
	end
end

function MarryEquipSuitView:FlushLeftCell()
	for k,v in pairs(self.item_cell_list) do
		v:SetSuitType(self.current_suit_index)
		v:SetIndex(k)
		v:SetSex(self.main_role_vo.sex)
		v:SetData(self.qingyuan_equip_handbook[self.current_suit_index][k])
	end
	for k,v in pairs(self.item_cell_list_1) do
		v:SetSuitType(self.current_suit_index)
		v:SetIndex(k)
		v:SetSex(self.main_role_vo.sex == 0 and 1 or 0)
		v:SetData(self.qingyuan_equip_handbook[self.current_suit_index][k])
	end
	self:FlushFightPower()
end

function MarryEquipSuitView:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(218)
end

function MarryEquipSuitView:ClickGetPere()
	MarriageCtrl.Instance:ShowMonomerView()
end
----------------------------MarryEquipSuitEquipItem-----------------------------------
MarryEquipSuitEquipItem = MarryEquipSuitEquipItem or BaseClass(BaseCell)
function MarryEquipSuitEquipItem:__init()
	self.node_list["Img"].button:AddClickListener(BindTool.Bind(self.ClickEquipQuick, self))
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["item"])
	self.item_cell:ListenClick(BindTool.Bind(self.OnClick, self))
end

function MarryEquipSuitEquipItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
	end
end

function MarryEquipSuitEquipItem:OnClick()
	if not self.is_active then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.MarryEquipGetTips)
		self.item_cell:ShowHighLight(false)
	else
		self.item_cell:OnClickItemCell()
	end
end

function MarryEquipSuitEquipItem:SetSuitType(suit_type)
	self.suit_type = suit_type
end

function MarryEquipSuitEquipItem:SetSex(sex)
	self.sex = sex
end

function MarryEquipSuitEquipItem:OnFlush()
	self.data = self:GetData()
	if not next(self.data) then
		return 
	end
	self.item_id = 0
	if self.sex == 1 then
		self.item_id = self.data.man_item
	else
		self.item_id = self.data.woman_item
	end
	self.item_cell:SetData({item_id = self.item_id,})
	self.is_active = MarryEquipData.Instance:GetMarrySuitActive(self.suit_type,self.data.slot)
	self.item_cell:ShowQuality(self.is_active)
	self.item_cell:SetIconGrayScale(not self.is_active)
	self.node_list["Img"]:SetActive(MarryEquipData.Instance:CanBeUpGrade(self.suit_type, self.data.slot))
end

function MarryEquipSuitEquipItem:ClickEquipQuick()
	local index_in_bag = ItemData.Instance:GetItemIndex(self.item_id)
	MarryEquipCtrl.Instance.SendActiveQingyuanSuit(self.suit_type, self.data.slot, index_in_bag)
end

--------------------------------------------------------------------------
LoverMarryEquipSuitEquipItem = LoverMarryEquipSuitEquipItem or BaseClass(BaseCell)
function LoverMarryEquipSuitEquipItem:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["item"])
	self.item_cell:ListenClick(BindTool.Bind(self.OnClick, self))
end

function LoverMarryEquipSuitEquipItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
	end
end

function LoverMarryEquipSuitEquipItem:OnClick()
	if not self.is_active then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.SuitTips)
		self.item_cell:ShowHighLight(false)
	else
		self.item_cell:OnClickItemCell()
	end
end

function LoverMarryEquipSuitEquipItem:SetSuitType(suit_type)
	self.suit_type = suit_type
end

function LoverMarryEquipSuitEquipItem:SetSex(sex)
	self.sex = sex
end

function LoverMarryEquipSuitEquipItem:OnFlush()
	self.data = self:GetData()
	if not next(self.data) then
		return 
	end
	self.item_id = 0
	if self.sex == 1 then
		self.item_id = self.data.man_item
	else
		self.item_id = self.data.woman_item
	end
	self.item_cell:SetData({item_id = self.item_id,})
	self.is_active = MarryEquipData.Instance:GetLoverMarrySuitActive(self.suit_type,self.data.slot)
	self.item_cell:ShowQuality(self.is_active)
	self.item_cell:SetIconGrayScale(not self.is_active)
end

----------------------------MarryEquipSuitViewItem------------------------------------
MarryEquipSuitViewItem = MarryEquipSuitViewItem or BaseClass(BaseCell)

function MarryEquipSuitViewItem:__init()
	self.node_list["bg_toggle"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["item"])

	self.is_active = false
end

function MarryEquipSuitViewItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	self.is_active = nil
end

function MarryEquipSuitViewItem:SetSex(sex)
	self.sex = sex
end

function MarryEquipSuitViewItem:SetIndex(index)
	self.index = index
end

function MarryEquipSuitViewItem:GetActive()
	 return self.is_active
end

function MarryEquipSuitViewItem:OnFlush()
	self.node_list["Img"]:SetActive(false)
	self.node_list["Txt"].text.text = string.format("%s阶", order[self.index])
	self.data = self:GetData()
	if next(self.data) then
		self.node_list["Text"].text.text = self.data[1].name
		self.item_cell:SetData({item_id = self.data[1].res,})
		local count = 0
		for i = 0, 3 do
			if MarryEquipData.Instance:GetMarrySuitActive(self.index - 1, i) then
				count = count + 1
			end
		end
		self.is_active = MarryEquipData.Instance:IsSuitActive(self.index - 1)
		self.node_list["Txt1"]:SetActive(self.is_active)
		self.node_list["Text3"]:SetActive(not self.is_active)

		self.node_list["Text2"].text.text = count.."/4"
		self.node_list["Img"]:SetActive(false)
		for i = 0, 3 do
			if MarryEquipData.Instance:CanBeUpGrade(self.index - 1, i) then
				self.node_list["Img"]:SetActive(true)
				return
			end
		end	
	end
end

function MarryEquipSuitViewItem:SetToggleGroup(toggle_group)
	if self.node_list["bg_toggle"].toggle then
		self.node_list["bg_toggle"].toggle.group = toggle_group
	end
end