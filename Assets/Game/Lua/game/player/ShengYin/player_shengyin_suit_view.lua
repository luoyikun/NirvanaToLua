ShengYinSuitView = ShengYinSuitView or BaseClass(BaseView)

SUIT_CELL_COUNT = 10
local EFFECTSIZE = Vector2(0.7, 0.7, 1)				-- 特效大小
local LASTEFFECTSIZE = Vector2(0.9, 0.9, 1)			-- 最后一个特效大小
local COLORNUM = 2  									-- 不显示特效的最高颜色索引
local CELL_TEXT_LINE_HEIGHT = 25

function ShengYinSuitView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab","BaseSecondPanel"},
		{"uis/views/player/shengyin_prefab", "ShengYinSuit"}
	}
	self.play_audio = true
	self.is_any_click_close = false
	self.is_modal = true
	-- self.item_count = 0
	-- self.last_item_count = 0
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.equip_cell_list = {} 
	self.pos_list = {}
	self.attr_text_list = {}
end

function ShengYinSuitView:LoadCallBack()
	self.node_list["TitleText"].text.text = Language.Player.ShengHunSuit
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["Button"].button:AddClickListener(BindTool.Bind(self.GetSeal, self))
	self.list_view_delegate = self.node_list["List"].list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.EquipSuitNum, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.EquipSuitCell, self)
	self.pos_list = {}
	for i = 1, SUIT_CELL_COUNT do
		self.pos_list[i] = ShengYinPos.New(self.node_list["Pos" .. i])
		if i == SUIT_CELL_COUNT then
			self.pos_list[i].item_cell.root_node.rect.sizeDelta = Vector2(135, 135)
		end
	end
	self.attr_text_list_del = self.node_list["TextContent"].list_simple_delegate
	self.attr_text_list_del.NumberOfCellsDel = BindTool.Bind(self.SuitInfoNum, self)
	self.attr_text_list_del.CellRefreshDel = BindTool.Bind(self.SuitInfoCell, self)
	self.attr_text_list_del.CellSizeDel = BindTool.Bind(self.GetCellSizeDel, self)
end

function ShengYinSuitView:__delete()

end

function ShengYinSuitView:GetSeal()
	ViewManager.Instance:Open(ViewName.LingKunBattleDetailView)
end

-- 自适应高度
function ShengYinSuitView:GetCellSizeDel(data_index)
	local suit_data_list = PlayerData.Instance:GetSuitDataByItemSuitType(self.item_data.suit_type)
	local suit_attr_info_list = PlayerData.Instance:GetTotalAttrKey()
	local data = suit_data_list[data_index + 1] or {}
	local show_attri_num = 0
	for k, v in pairs(suit_attr_info_list) do
		if data[v] ~= nil and data[v] > 0 then
			show_attri_num = show_attri_num + 1
		end
	end
	return CELL_TEXT_LINE_HEIGHT * (show_attri_num + 1)
end
	
function ShengYinSuitView:SuitInfoNum()
	if self.item_data then 
		local suit_data_list = PlayerData.Instance:GetSuitDataByItemSuitType(self.item_data.suit_type)
		return #suit_data_list
	end
	return 0
end

function ShengYinSuitView:SuitInfoCell(cell, data_index)
	data_index = data_index + 1
	local equip_cell = self.attr_text_list[cell]
	if equip_cell == nil then
		equip_cell = ShengYinAttri.New(cell.gameObject)
		self.attr_text_list[cell] = equip_cell
	end
	if self.item_data then 
		local suit_data_list = PlayerData.Instance:GetSuitDataByItemSuitType(self.item_data.suit_type)	
		equip_cell:SetNeedData(suit_data_list[data_index])
		-- self.item_count = equip_cell:GetItemCount()
	end
end

function ShengYinSuitView:ReleaseCallBack()
	for _, v in pairs(self.attr_text_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.attr_text_list = {}	
	for _, v in pairs(self.pos_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.pos_list = {}	
	for _, v in pairs(self.equip_cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.equip_cell_list = {} 
	self.data_info = nil
	self.list_view_delegate = nil
	self.attr_text_list_del = nil
end

function ShengYinSuitView:CloseWindow()
	self:Close()
end

function ShengYinSuitView:EquipSuitNum()
	local suit_list = PlayerData.Instance:GetShengYinSuitCfg()
	return #suit_list
end

function ShengYinSuitView:EquipSuitCell(cell, data_index)
	local suit_list = PlayerData.Instance:GetShengYinSuitCfg()
	data_index = data_index + 1
	local equip_cell = self.equip_cell_list[cell]
	if equip_cell == nil then
		equip_cell = ShengYinSuitInfoCell.New(cell.gameObject)
		self.equip_cell_list[cell] = equip_cell
	end
	equip_cell:SetData(suit_list[data_index])
	equip_cell:SetClickCallBack(BindTool.Bind(self.OnClickSuitCell, self))
	equip_cell:SetIndex(data_index)
	if self.data_info == nil then 
		self.data_info = suit_list[data_index]
		self.data_index = data_index
		self:Flush()
	end

	if self.data_index == data_index then 
		equip_cell:SetHigh(true)
	else
		equip_cell:SetHigh(false)
	end
end

function ShengYinSuitView:OnClickSuitCell(data)
	local last_data_index = self.data_index
	self.data_info = data:GetData()
	self.data_index = data:GetIndex()
	for k, v in pairs(self.equip_cell_list) do
		v:SetHigh(false)
	end
	data:SetHigh(true)
	if last_data_index ~= self.data_index then 
		self:Flush()
	end
end

function ShengYinSuitView:OpenCallBack()
	local suit_list = PlayerData.Instance:GetShengYinSuitCfg()
	if suit_list then
		self.data_info = suit_list[1]
		self.data_index = 1
	end
	self:Flush()
end

function ShengYinSuitView:FlushInfo()
	if self.data_info ~= nil then 
		self.item_data = self.data_info
		local item_part_list = Split(self.item_data.equip_part, "|")
		local item_list = {}
		local grade_attr = CommonStruct.Attribute() 
		for i = 1, SUIT_CELL_COUNT do 
			item_list[i] = {}
		end

		for i, v in pairs(item_part_list) do
			local item_data = PlayerData.Instance:GetItemByOrderAndPart(self.item_data.equip_order, tonumber(v))
			item_list[tonumber(v)] = item_data
			
		end

		for k, v in pairs(item_list) do
			self.pos_list[k]:SetData(v)
		end
		--------------------计算未激活战力--------------------------------
		local seal_part_list = PlayerData.Instance:GetSealSuitCfg(self.item_data.suit_type)
		for i, v in pairs(seal_part_list) do
			for i1, v1 in pairs(v) do 
				local item_data = PlayerData.Instance:GetSealAttrData(v1.equip_part, v1.equip_order)
				local attribute = CommonDataManager.GetAttributteByClass(item_data)
				-- local scord = CommonDataManager.GetCapability(attribute)
				grade_attr = CommonDataManager.AddAttributeAttr(grade_attr, attribute)
				-- grade_attr = grade_attr + scord
			end
		end
		local suit_data_list = PlayerData.Instance:GetSuitDataByItemSuitType(self.item_data.suit_type)
		-- 属性列表
		--self.shengyin_info_attri:SetDataList(suit_data_list)
		
		for i = 1, #suit_data_list do
			local attribute = CommonDataManager.GetAttributteByClass(suit_data_list[i])
			grade_attr = CommonDataManager.AddAttributeAttr(grade_attr, attribute)
		end

		local grade_attr2 = CommonDataManager.AddAttributeAttr(grade_attr, CommonDataManager.GetMainRoleAttr())
		local grade_attr3 = CommonStruct.Attribute()
		-- for i = 1, #suit_data_list do
		-- 	local attribute = CommonDataManager.GetAttributteByClass(suit_data_list[i])
		-- 	grade_attr3.max_hp = grade_attr3.max_hp + grade_attr2.max_hp * (1 + suit_data_list[i]["per_maxhp"] / 10000) - grade_attr2.max_hp
		-- 	grade_attr3.gong_ji = grade_attr3.gong_ji + grade_attr2.gong_ji * (1 + suit_data_list[i]["per_gongji"] / 10000) - grade_attr2.gong_ji
		-- 	grade_attr3.fang_yu = grade_attr3.fang_yu + grade_attr2.fang_yu * (1 + suit_data_list[i]["per_fangyu"] / 10000) - grade_attr2.fang_yu
		-- end
		-- grade_attr.max_hp = grade_attr2.max_hp
		-- grade_attr.gong_ji = grade_attr2.gong_ji
		-- grade_attr.fang_yu = grade_attr2.fang_yu
		self.node_list["FightNumber"].text.text = CommonDataManager.GetCapabilityCalculation(grade_attr)
		-- self.node_list["FightNumber"].text.text = CommonDataManager.GetCapabilityCalculation(grade_attr) + CommonDataManager.GetCapabilityBCalculation(grade_attr, CommonDataManager.GetMainRoleAttr()) 
		-- self.attr_text_list_del:ReLoad()
		-- if self.item_count ~= self.last_item_count then
		-- 	self.last_item_count = self.item_count
		self.node_list["List"].scroller:RefreshActiveCellViews()
		self.node_list["TextContent"].scroller:ReloadData(0)
		-- else
		-- 	self.node_list["TextContent"].scroller:RefreshActiveCellViews()	
		-- end
		--self.node_list["TextContent"].scroller:JumpToDataIndex(0)
	end
end

function ShengYinSuitView:OnFlush()
	self:FlushInfo()
end

ShengYinSuitInfoCell = ShengYinSuitInfoCell or BaseClass(BaseCell)

function ShengYinSuitInfoCell:__init()
	self.node_list["BtnClick"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.name_outline = self.node_list["Name"].gameObject:GetComponent(typeof(UnityEngine.UI.Outline))
	self.count_outline = self.node_list["Count"].gameObject:GetComponent(typeof(UnityEngine.UI.Outline))
end

function ShengYinSuitInfoCell:__delete()
	self.name_outline = nil
	self.count_outline = nil
end

function ShengYinSuitInfoCell:SetHigh(is_high)
	if nil == self.data then
		return
	end
	self.node_list["High"]:SetActive(is_high)
	self.name_outline.enabled = is_high
	self.count_outline.enabled = is_high
	-- local str = is_high and ToColorStr(self.data.suit_name, "#000000") or ToColorStr(self.data.suit_name, SOUL_NAME_COLOR[self.data.color])
	-- local countstr = self:GetItemCountTxt() or ""
	-- local str1 = is_high and ToColorStr(countstr, "#000000") or ToColorStr(countstr, "#FFFFFF")
	-- self.node_list["Name"].text.text = str
	-- self.node_list["Count"].text.text = str1
end

function ShengYinSuitInfoCell:OnFlush()
	if self.data == nil then return end
	self.node_list["Name"].text.text = ToColorStr(self.data.suit_name, SOUL_NAME_COLOR[self.data.color]) or ""
	self.node_list["Count"].text.text = self:GetItemCountTxt()
	--self.node_list["High"]:SetActive(false)
end

function ShengYinSuitInfoCell:GetItemCountTxt()
	if self.data == nil then return "" end
	local item_part_list = Split(self.data.equip_part, "|")
	local item_list = {}
	for i, v in pairs(item_part_list) do
		local item_data = PlayerData.Instance:GetItemByOrderAndPart(self.data.equip_order, tonumber(v))
		table.insert(item_list,item_data)
	end
	local seal_solt_list = PlayerData.Instance:GetSealSlotItemList()
	local item_count = 0
	for i1, v1 in pairs(seal_solt_list) do 
		for i2, v2 in pairs(item_list) do 
			if v1.item_id ~= 0 and v1.item_id == v2.seal_id then 
				item_count = item_count + 1
				break
			end
		end
	end
	self.node_list["Gou"]:SetActive(item_count >= #item_part_list)
	return item_count.." / "..#item_part_list
end

ShengYinPos = ShengYinPos or BaseClass(BaseCell)

function ShengYinPos:__init()
	self.item_cell = ItemCell.New()
	self.item_cell.root_node.rect.sizeDelta = Vector2(105, 105)
	self.item_cell:SetInstanceParent(self.node_list["Item"])
	self.item_cell:SetBackground(false)
	self.item_cell:ShowQuality(false)
	self.item_cell:SetHighLight(false)
	self.item_cell:ListenClick(BindTool.Bind(self.PosOnClick, self))
	--self.item_cell:SetInteractable(false)
end

function ShengYinPos:PosOnClick()
	if self.data == nil then 
		return 
	end
	-- local close_callback = function ()
	-- 	self.item_cell:SetHighLight(false)
	-- end
	local item = {}
	item.item_id = self.data.seal_id or 0
	item.order = self.data.order or 0
	TipsCtrl.Instance:OpenItem(item, TipsFormDef.FROM_SHENGYIN_NOT_USE)
end

function ShengYinPos:__delete()
	if self.item_cell then 
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ShengYinPos:OnFlush()
	if self.data == nil then 
		self.item_cell:SetShengYinEffect(false)
		return 
	end
	local item = {}
	item.item_id = self.data.seal_id or 0
	self.item_cell:SetData(item)
	local seal_solt_list = PlayerData.Instance:GetSealSlotItemList()
	if item.item_id > 0 then
		self.item_cell:SetShengYinEffect(self.data.color > COLORNUM, self.data.color - COLORNUM, self.data.slot_index == SUIT_CELL_COUNT and LASTEFFECTSIZE or EFFECTSIZE)
		-- self.item_cell:SetShengYinGrade(self.data.order)
	end
	if self.data.slot_index ~= nil and seal_solt_list[self.data.slot_index - 1] ~= nil and item.item_id == seal_solt_list[self.data.slot_index - 1].item_id then 
		self.node_list["Effect"]:SetActive(true)

	else
		self.node_list["Effect"]:SetActive(false)
	end
	self.item_cell:ShowHighLight(false)
end

ShengYinAttri = ShengYinAttri or BaseClass(BaseRender)

function ShengYinAttri:__init()
end

function ShengYinAttri:__delete()
end

function ShengYinAttri:SetNeedData(data)
	self.data = data
	self:FlushAttr()
end

-- function ShengYinAttri:GetItemCount()
-- 	print("GetItemCount")
-- 	local count = 0
-- 	for k, v in pairs(self.data) do
-- 		count = count + 1
-- 	end
-- 	return count
-- end

function ShengYinAttri:FlushAttr()
	if self.data == nil then return end 

	local seal_solt_list = PlayerData.Instance:GetSealSlotItemList()
	local seal_part_list = PlayerData.Instance:GetSealSuitCfg(self.data.suit_type)
	local item_count = PlayerData.Instance:GetFinshSuitCountBySuitType(self.data.suit_type)
	
	local attr_key_color = 0
	local attr_value_color = 0  
	if item_count >= self.data.same_order_num then 
		attr_key_color = COLOR.WHITE
		attr_value_color = COLOR.GREEN
	else
		attr_key_color = COLOR.LightBlue
		attr_value_color = COLOR.WHITE
	end

	local str = string.format(Language.Player.SomePiece,self.data.same_order_num) 
	self.node_list["Txttitle"].text.text = str
	for i = 1, 4 do 
		RichTextUtil.ParseRichText(self.node_list["List" .. i].rich_text, "")
	end
	local show_attri_num = 0
	local suit_attr_info_list = PlayerData.Instance:GetTotalAttrKey()
	for k, v in ipairs(suit_attr_info_list)do
		if self.data[v] ~= nil and self.data[v] > 0 and show_attri_num < 5 then
			show_attri_num = show_attri_num + 1
			local split_attr = Split(v, "_")
			local is_per = split_attr[1] == "per" or split_attr[#split_attr] == "per"
			local attri_text = ""
			if is_per then 
				attri_text = string.format( Language.Player.SuitAtrrTipAll, Language.Player.AttrNameShengYin[v],attr_value_color, self.data[v] / 100 .. "%")
			else
				attri_text = string.format( Language.Player.SuitAtrrTipAll, Language.Player.AttrNameShengYin[v],attr_value_color, self.data[v])
			end
			RichTextUtil.ParseRichText(self.node_list["List" .. show_attri_num].rich_text, attri_text, 20, attr_key_color)
		end
	end
	-- local layout = self.root_node.transform:GetComponent(typeof(UnityEngine.UI.LayoutElement))
	-- if layout then 
	-- 	layout.minHeight = self.node_list["Txttitle"].rect.sizeDelta.y + self.node_list["List1"].rect.sizeDelta.y * show_attri_num
	-- end
end