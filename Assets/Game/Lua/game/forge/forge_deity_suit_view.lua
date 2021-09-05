-- 锻造 套装
ForgeDeitySuit = ForgeDeitySuit or BaseClass(BaseRender)

function ForgeDeitySuit:__init(instance, parent_view)
	self.node_list["ToggleXian"].toggle:AddClickListener(BindTool.Bind(self.SetSuitType, self, 0))
	self.node_list["ToggleShen"].toggle:AddClickListener(BindTool.Bind(self.SetSuitType, self, 1))
	self.node_list["BtnSuit"].button:AddClickListener(BindTool.Bind(self.OnBtnSuit, self))
	self.node_list["ButtonShouGou"].button:AddClickListener(BindTool.Bind(self.OnButtonShouGou, self))

	self.equip_data = {}
	self.equip_list_cell = {}
	local list_view_delegate = self.node_list["EquipList"].list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetEquipCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshEquipListView, self)

	self.suit_attr_data = {}
	self.suit_attr_list = {}
	self:LoadCell()
	-- local list_view_delegate = self.node_list["SuitAttrList"].list_simple_delegate
	-- list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	-- list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshListView, self)

	self.equip_cell = ItemCell.New()
	self.equip_cell:SetInstanceParent(self.node_list["EquipItem"])
	self.equip_cell:SetFromView(TipsFormDef.FROM_BAG_EQUIP)

	self.material_cells = {}
	for i = 1, 3 do
		local cell = ItemCell.New()
		cell:SetInstanceParent(self.node_list["MaterialCell" .. i])
		self.material_cells[i] = cell
	end

	self.suit_type = 0

	self:FlushEquipDataList(true)
end

function ForgeDeitySuit:__delete()
	for k,v in pairs(self.equip_list_cell) do
		v:DeleteMe()
	end
	self.equip_list_cell = {}

	for k,v in pairs(self.suit_attr_list) do
		v:DeleteMe()
	end
	self.suit_attr_list = {}
	
	for k,v in pairs(self.material_cells) do
		v:DeleteMe()
	end
	self.material_cells = {}

	if self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil
	end

end

-- 装备列表
function ForgeDeitySuit:GetEquipCells()
	return #self.equip_data or 0
end

function ForgeDeitySuit:RefreshEquipListView(cell, cell_index)
	local item_cell = self.equip_list_cell[cell]
	if nil == item_cell then
		item_cell = DeitySuitEquipCell.New(cell.gameObject)
		item_cell:SetToggleGroup(self.node_list["EquipList"].toggle_group)
		item_cell:SetClickCallBack(BindTool.Bind(self.ClickEquipListCallBack, self))
		self.equip_list_cell[cell] = item_cell
	end

	local data = self.equip_data[cell_index + 1]
	item_cell:SetSuitType(self.suit_type)
	item_cell:SetIndex(cell_index)
	item_cell:SetData(data)
	item_cell:SetSelectHL(self.select_index == data.data_index)
end
----------------------------

-- 属性列表
function ForgeDeitySuit:GetNumberOfCells()
	-- for i = 1, #self.suit_attr_data do
		-- self:LoadCell(1)
	-- end
	return #self.suit_attr_data or 0
end

function ForgeDeitySuit:RefreshListView(cell, cell_index)
	cell_index = cell_index + 1
	local item_cell = self.suit_attr_list[cell]
	if nil == item_cell then
		item_cell = SuitAttrCell.New(cell.gameObject)
		self.suit_attr_list[cell] = item_cell
	end

	if self.suit_attr_data then
		local data = self.suit_attr_data[cell_index]
		item_cell:SetHLCondition(self.had_equip_num)
		item_cell:SetIndex(cell_index)
		item_cell:SetData(data)
	end
end

function ForgeDeitySuit:LoadCell()
	local res_async_loader = AllocResAsyncLoader(self, "loader")
	res_async_loader:Load("uis/views/forgeview_prefab", "SuitAttrCell", nil, function (prefab)
		if nil == prefab then
			return
		end
		for i = 1, #self.suit_attr_data do
			if nil == self.suit_attr_list[i] then
				local obj = ResMgr:Instantiate(prefab)
				local obj_transform = obj.transform
				obj_transform:SetParent(self.node_list["List"].transform, false)

				local item_cell = SuitAttrCell.New(obj)
				-- item_cell:FlushFontSize(sub_type)
				if self.suit_attr_data then
					local data = self.suit_attr_data[i]
					item_cell:SetHLCondition(self.had_equip_num)
					item_cell:SetIndex(i)
					item_cell:SetData(data)
				end
				-- self.suit_attr_list[#self.suit_attr_list + 1] = obj_transform
				self.suit_attr_list[i] = item_cell
			end
		end
	end)
end
----------------------------

function ForgeDeitySuit:FlushCellHL(index)
	for k, v in pairs(self.equip_list_cell) do
		v:SetSelectHL(index == v:GetDataIndex())
	end
end

function ForgeDeitySuit:ClickEquipListCallBack(cell)
	local index = cell:GetDataIndex()
	self:FlushCellHL(index)
	self.select_index = index
	self:Flush()
end

function ForgeDeitySuit:JumpToIndexByIndex(index)
	for k, v in pairs(self.equip_list_cell) do
		if index and v:GetDataIndex() == index then
			self:ClickEquipListCallBack(v)
		end
	end
end

function ForgeDeitySuit:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "ui_tween" then
			local ui_cfg = ForgeData.Instance:GetUITweenCfg(TabIndex.forge_deity_suit)
			UITween.MoveShowPanel(self.node_list["RightPanel"] , ui_cfg["RightPanel"], ui_cfg["MOVE_TIME"])
			UITween.MoveShowPanel(self.node_list["LeftPanel"] , ui_cfg["LeftPanel"], ui_cfg["MOVE_TIME"])
			UITween.AlpahShowPanel(self.node_list["MidPanel"] , ui_cfg["MidPanel"], ui_cfg["MOVE_TIME"], DG.Tweening.Ease.InExpo)
		end
	end
	if self.select_index == nil then return end
	self.cell_data = ForgeData.Instance:GetZhuanzhiEquip(self.select_index)
	if nil == self.cell_data or self.cell_data.item_id <= 0 then 
		return 
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.cell_data.item_id)
	self.equip_cell:SetData(self.cell_data)
	self.equip_cell:ShowStrengthLable(false)
	self.node_list["EquipName"].text.text = item_cfg.name

	local equip_suit_type = ForgeData.Instance:GetZhuanzhiSuitType(self.cell_data.index)
	local suit_cfg = ForgeData.Instance:GetZhuanzhiSuitTypeCfg(self.cell_data.index, self.suit_type, item_cfg.order)
	if not suit_cfg or not equip_suit_type then return end

	local function change_btn_state(is_active)
		UI:SetGraphicGrey(self.node_list["BtnSuit"], not is_active)
		UI:SetButtonEnabled(self.node_list["BtnSuit"], is_active)
	end
	local is_show_attr = false
	local is_show_material = false
	local min_order, min_color = ForgeData.Instance:GetSuitMinOrder(self.suit_type)
	if item_cfg.order >= min_order and item_cfg.color >= min_color then
		UI:SetButtonEnabled(self.node_list["BtnSuit"], true)
		UI:SetGraphicGrey(self.node_list["BtnSuit"], false)
		if self.suit_type == 0 then
			is_show_material = equip_suit_type < self.suit_type
			if equip_suit_type < 0 then
				self.node_list["SuitStateDesc"].text.text = ""
				change_btn_state(true)
			elseif equip_suit_type >= 1 then
				self.node_list["SuitStateDesc"].text.text = Language.Forge.DeitySuitTip[2]
				change_btn_state(false)
			else
				self.node_list["SuitStateDesc"].text.text = Language.Forge.DeitySuitTip[3]
				change_btn_state(false)
			end
		else
			is_show_material = equip_suit_type < self.suit_type and equip_suit_type >= 0
			if equip_suit_type < 0 then
				self.node_list["SuitStateDesc"].text.text = Language.Forge.DeitySuitTip[4]
				change_btn_state(true)
			elseif equip_suit_type < 1 then
				self.node_list["SuitStateDesc"].text.text = ""
				change_btn_state(true)
			else
				self.node_list["SuitStateDesc"].text.text = Language.Forge.DeitySuitTip[2]
				change_btn_state(false)
			end
		end
		-- if self.suit_type == 0 and equip_suit_type >= 1 then
		-- 	is_show_attr = false
		-- else
		is_show_attr = true
		-- end
	else
		local need_desc = Language.Forge.SuitMinOrder[min_order - 1] .. Language.Forge.SuitMinColor[min_color]
		self.node_list["SuitStateDesc"].text.text = string.format(Language.Forge.SuitNeedOrder, need_desc)
		UI:SetButtonEnabled(self.node_list["BtnSuit"], false)
		UI:SetGraphicGrey(self.node_list["BtnSuit"], true)
	end

	-- 材料
	for k, v in pairs(self.material_cells) do
		local id = suit_cfg["stuff_" .. k .. "_id"]
		local num = suit_cfg["stuff_" .. k .. "_num"]
		if is_show_material and id > 0 and num > 0 then
			v:SetData({item_id = id})
			local had_num = ItemData.Instance:GetItemNumInBagById(id)
			local color = had_num >= num and TEXT_COLOR.GREEN or TEXT_COLOR.RED
			local num_str = ToColorStr(had_num .. "/" ..  num, color)
			v:SetItemNumVisible(true, num_str)
			v:SetActive(true)
			v:SetCellLock(false)
			v:ListenClick()
		else
			if is_show_material then
				v:SetData({})
				v:SetActive(true)
				v:SetCellLock(true)
				v:ListenClick(function ()
					v:SetHighLight(false)
				end)
			else
				v:SetActive(false)
			end
		end
	end

	-- 属性List
	local total_equip_num, had_equip_num = ForgeData.Instance:GetSuitCount(self.cell_data.index, self.suit_type, item_cfg.order)
	local str = ""
	if is_show_attr then
		self.node_list["List"]:SetActive(true)
		self.suit_attr_data = ForgeData.Instance:GetSuitAttrList(self.cell_data.index, self.suit_type, item_cfg.order)
		self.had_equip_num = had_equip_num
		-- print_error("self.suit_attr_data",self.suit_attr_data)
		-- print_error("self.suit_attr_list",self.suit_attr_list)
		-- self.node_list["SuitAttrList"].scroller:ReloadData(0)
		-- self.node_list["SuitAttrList"]:SetActive(true)
		self:LoadCell()
		for k, v in pairs(self.suit_attr_data) do
			local data = self.suit_attr_data[k]
			if self.suit_attr_list[k] then 
				self.suit_attr_list[k]:SetHLCondition(self.had_equip_num)
				self.suit_attr_list[k]:SetData(data)
			end
		end

		local suit_name = ""
		if self.cell_data.index >= 5 and self.cell_data.index <= 7 then
			suit_name = Language.Forge.ShouShiSuitName
		else
			suit_name = ToColorStr(Language.Forge.SuitOrderName[item_cfg.order], TEXT_COLOR.WHITE)
		end
		str = Language.Forge.SuitTypeName[self.suit_type] .. suit_name
		str = str .. "(" .. had_equip_num .. "/" .. total_equip_num .. ")"
	else
		self.node_list["List"]:SetActive(false)
	end
	self.node_list["SuitName"].text.text = str


	self:FlushEquipDataList()
	self:FlushToggleRepoint()
	self:ShowStrengthenEffect()

end

function ForgeDeitySuit:StopShowEffect()
	self.node_list["DzEffect"]:SetActive(false)
end

function ForgeDeitySuit:ShowStrengthenEffect()
	self:StopShowEffect()
	local is_show = ForgeData.Instance:GetChangeInlaySuccess()
	self.node_list["DzEffect"]:SetActive(is_show)
	if is_show then
		ForgeData.Instance:SetForgeDeitySuitCfg()
	end
	ForgeData.Instance:SetChangeInlaySuccess(false)
end

function ForgeDeitySuit:SetSuitType(suit_type)
	self.suit_type = suit_type
	self:Flush()
end

function ForgeDeitySuit:OnButtonShouGou()
	MarketData.Instance:SetPurchaseItemId(3)
	ViewManager.Instance:Open(ViewName.Market, TabIndex.market_purchase, "select_purchase", {select_index == 3})
end

-- 装备List
function ForgeDeitySuit:FlushEquipDataList(is_first)
	self.equip_data = {}
	local sort_tab = {
		[1] = 1, [2] = 2, [3] = 3, 
		[4] = 4, [5] = 8, [6] = 5, 
		[7] = 6, [8] = 7,
	}
	local equip_data = ForgeData.Instance:GetZhuanzhiEquipAll()
	local count = 1
	for k, v in pairs(sort_tab) do
		if equip_data[v] and equip_data[v].item_id > 0 then
			self.equip_data[count] = {}
			self.equip_data[count].data_index = v
			count = count + 1
			if is_first and not self.click_index then
				self.click_index = v
			end
		end
	end
	if is_first then
		self.node_list["EquipList"].scroller:ReloadData(0)
		for k, v in pairs(self.equip_list_cell) do
			if self.click_index and v:GetDataIndex() == self.click_index then
				self:ClickEquipListCallBack(v)
			end
		end
	else
		self.node_list["EquipList"].scroller:RefreshActiveCellViews()
	end
end

-- Toggle红点 GetZhuanzhiSuitType
function ForgeDeitySuit:FlushToggleRepoint()
	local curr_equip_suit = ForgeData.Instance:GetZhuanzhiSuitType(self.cell_data.index)
	for i = 0, 1 do
		local is_set_visit = false
		if curr_equip_suit < i and (curr_equip_suit + 1) == i then
			local item_cfg = ItemData.Instance:GetItemConfig(self.cell_data.item_id)
			local cfg = ForgeData.Instance:GetZhuanzhiSuitTypeCfg(self.cell_data.index, i, item_cfg.order)
			local min_order, min_color = ForgeData.Instance:GetSuitMinOrder(self.suit_type)
			if cfg and item_cfg and item_cfg.order >= min_order and item_cfg.color >= min_color then
				local need_material = 0
				local had_material = 0
				for i = 1, 3 do
					if cfg["stuff_" .. i .. "_id"] > 0 then
						local material_num = ItemData.Instance:GetItemNumInBagById(cfg["stuff_" .. i .. "_id"])
						need_material = need_material + 1
						if material_num >= cfg["stuff_" .. i .. "_num"] then
							had_material = had_material + 1
						end
					end
				end
				if need_material == had_material then
					is_set_visit = true
				end
			end
		end
		self.node_list["RedPoint" .. i]:SetActive(is_set_visit)
	end
end

function ForgeDeitySuit:OnBtnSuit()
	if nil == self.cell_data then 
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NoSelectEquip)
		return
	end
	local equip_suit_type = ForgeData.Instance:GetZhuanzhiSuitType(self.cell_data.index) or 0
	local item_cfg = ItemData.Instance:GetItemConfig(self.cell_data.item_id)
	local min_order, min_color = ForgeData.Instance:GetSuitMinOrder(self.suit_type)
	
	if item_cfg.order < min_order and  item_cfg.order < min_color then
		local need_desc = Language.Forge.SuitMinOrder[min_order] .. Language.Forge.SuitMinColor[min_color]
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Forge.SuitNeedOrderNoColor, need_desc))
	elseif self.suit_type == 1 and equip_suit_type < 0 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NoActiveZhuxian)
	else
		ForgeData.Instance:SetForgeDeitySuitCfg()
		ForgeCtrl.Instance:SendCSZhuanzhiEquipOpe(ZHUANZHI_EQUIP_OPERATE_TYPE.ZHUANZHI_EQUIP_OPERATE_TYPE_FORGE_SUIT, self.suit_type, self.cell_data.index)

	end
end

-- 暂时没用
function ForgeDeitySuit:OnButtonHelp()
	local tips_id = 263
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

----------------------------------------------------------
-----------装备格子 EquipCell
----------------------------------------------------------
DeitySuitEquipCell = DeitySuitEquipCell or BaseClass(BaseCell)
function DeitySuitEquipCell:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.item_cell:SetFromView(TipsFormDef.FROM_BAG_EQUIP)
	self.node_list["BaseEquipCell"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function DeitySuitEquipCell:SetParentView(parent_view)
	self.parent_view = parent_view
end

function DeitySuitEquipCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function DeitySuitEquipCell:OnFlush()
	local equip_data = {}
	equip_data = ForgeData.Instance:GetZhuanzhiEquip(self.data.data_index)

	if nil == equip_data or nil == equip_data.item_id then
		return
	end

	self.item_cell:SetData(equip_data)
	self.item_cell:ShowStrengthLable(false)
	local item_cfg = ItemData.Instance:GetItemConfig(equip_data.item_id)
	if nil == item_cfg then return end

	local equip_suit_type = ForgeData.Instance:GetZhuanzhiSuitType(self.data.data_index)
	local min_order, min_color = ForgeData.Instance:GetSuitMinOrder(self.suit_type)
	-- if item_cfg.order < min_order or item_cfg.color < min_color then
	-- 	self.node_list["Level"].text.text = Language.Forge.SuitNeedOrder
	-- elseif self.suit_type == 0 then -- 诛仙
	-- 	if equip_suit_type < 0 then
	-- 		self.node_list["Level"].text.text = Language.Forge.DeitySuitTip[1]
	-- 	elseif equip_suit_type >= 1 then
	-- 		self.node_list["Level"].text.text = Language.Forge.DeitySuitTip[2]
	-- 	else
	-- 		self.node_list["Level"].text.text = Language.Forge.DeitySuitTip[3]
	-- 	end
	-- elseif self.suit_type == 1 then -- 诛神
	-- 	if equip_suit_type < 0 then
	-- 		self.node_list["Level"].text.text = Language.Forge.DeitySuitTip[4]
	-- 	elseif equip_suit_type < 1 then
	-- 		self.node_list["Level"].text.text = Language.Forge.DeitySuitTip[5]
	-- 	else
	-- 		self.node_list["Level"].text.text = Language.Forge.DeitySuitTip[2]
	-- 	end
	-- end

	if equip_suit_type == 0 or equip_suit_type == 1 then
		self.item_cell:SetDeitySuitText(Language.Forge.SuitTypeName3[equip_suit_type])
	end
	
	-- local first_name = Language.Forge.SuitTypeName2[equip_suit_type] or ""
	local first_name = ""
	self.node_list["Name"].text.text = first_name ..  item_cfg.name
	self.node_list["HLName"].text.text = first_name ..  item_cfg.name

	local can_improve = ForgeData.Instance:CheckFunIsCanImprove(equip_data, TabIndex.forge_deity_suit)
	if can_improve == 0 then
		self.node_list["RedPoint"]:SetActive(true)
	else
		self.node_list["RedPoint"]:SetActive(false)
	end

	if self.data.data_index == 5 or self.data.data_index == 6 or self.data.data_index == 7 then
		self.node_list["Desc"].text.text = Language.Forge.ShouShi
		self.node_list["Desc"]:SetActive(true)
	else
		self.node_list["Desc"]:SetActive(false)
	end
end

function DeitySuitEquipCell:OnClick(is_bool)
	BaseCell.OnClick(self)
end

function DeitySuitEquipCell:SetSuitType(suit_type)
	self.suit_type = suit_type
end

function DeitySuitEquipCell:SetSelectHL(is_hl)
	self.node_list["HLBg"]:SetActive(is_hl)
end

function DeitySuitEquipCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function DeitySuitEquipCell:GetDataIndex()
	return self.data.data_index
end


-----------------------------------------
-- 套装属性 SuitAttrCell  obj_name:SuitAttrCell
SuitAttrCell = SuitAttrCell or BaseClass(BaseCell)
function SuitAttrCell:__init()

end

function SuitAttrCell:__delete()
	
end

function SuitAttrCell:SetHLCondition(had_equip_num)
	self.had_equip_num = had_equip_num or 0
end

function SuitAttrCell:OnFlush()
	if self.data == nil then 
		self.root_node:SetActive(false)
		return 
	end
	self.root_node:SetActive(true)
	self.node_list["SuitCount"].text.text = string.format(Language.Forge.SuitCount, self.data.same_order_num)
	local color = (self.had_equip_num >= self.data.same_order_num) and TEXT_COLOR.GREEN or TEXT_COLOR.WHITE

	local count = 1
	for k, v in pairs(Language.Forge.SuitShowType) do
		if self.data[v] and self.data[v] > 0 then
			if string.find(v, "per") then
				self.node_list["Attr" .. count].text.text = ToColorStr(string.format(Language.Forge.SuitShowAttr[v], (self.data[v] / 100) .. "%"), color)
			else
				self.node_list["Attr" .. count].text.text = ToColorStr(string.format(Language.Forge.SuitShowAttr[v], self.data[v]), color)
			end
			self.node_list["Attr" .. count]:SetActive(true)
			count = count + 1
		end
	end

	for i = count, 6 do
		self.node_list["Attr" .. i].text.text = ""
		self.node_list["Attr" .. i]:SetActive(false)
	end
end

