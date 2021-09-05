OrangeSuitCollect = OrangeSuitCollect or BaseClass(BaseRender)

function OrangeSuitCollect:__init(instance)
	self.node_list["BtnGotoGet"].button:AddClickListener(BindTool.Bind(self.OnBtnGotoGet, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnBtnHelp, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightPower"])

	-- 套装激活属性

	self.suit_attr_data = {}
	self.attr_cell_list = {}

	-- 装备
	self.equip_item_list = {}
	for i = 0, 9 do
		local item_cell = OrangeEquipItemCell.New(self.node_list["EquipItem" .. (i + 1)])
		item_cell:SetIndex(i)
		item_cell:SetToggleGroup(self.node_list["EquipItems"].toggle_group)
		self.equip_item_list[i] = item_cell
	end

	self.suit_type_data = {}
	self.suit_cell_list = {}
	local suit_list_delegate = self.node_list["SuitList"].list_simple_delegate
	suit_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetTypeCellNumber, self)
	suit_list_delegate.CellRefreshDel = BindTool.Bind(self.TypeCellRefresh, self)

	self.suit_type_data = SuitCollectionData.Instance:GetOrangeItemNum()
	self.choose_type_data = self.suit_type_data[1]
	self.node_list["SuitList"].scroller:ReloadData(0)

	self.progress = ProgressBar.New(self.node_list["ProgressBG"])

	SuitCollectionData.Instance:SetOrangeRemindFlag()
	RemindManager.Instance:Fire(RemindName.OrangeSuitCollection)
	self:Flush()
end

function OrangeSuitCollect:__delete()
	for k, v in pairs(self.equip_item_list) do
		v:DeleteMe()
	end
	self.equip_item_list = {}

	for k, v in pairs(self.suit_cell_list) do
		v:DeleteMe()
	end
	self.suit_cell_list = {}


	if self.progress then
		self.progress:DeleteMe()
		self.progress = nil
	end
	self.fight_text = nil

	for k,v in pairs(self.attr_cell_list) do
		v:DeleteMe()
	end
	self.attr_cell_list = {}
end

function OrangeSuitCollect:LoadCallBack()

end

-- 属性列表
function OrangeSuitCollect:LoadCell()
	local res_async_loader = AllocResAsyncLoader(self, "loader")
	res_async_loader:Load("uis/views/suitcollection_prefab", "OrangeSuitAttrCell", nil, function (prefab)
		if nil == prefab then
			return
		end
		for i = 1, #self.suit_attr_data do
			if nil == self.attr_cell_list[i] then
				local obj = ResMgr:Instantiate(prefab)
				local obj_transform = obj.transform
				obj_transform:SetParent(self.node_list["AttrGroup"].transform, false)

				local item_cell = OrangeSuitAttrCell.New(obj)
				if self.suit_attr_data then
					local data = self.suit_attr_data[i]
					item_cell:SetIndex(i)
					item_cell:SetData(data)
				end
				self.attr_cell_list[i] = item_cell
			end
		end
	end)
end

---------------------------
-- 左边套装类型列表
function OrangeSuitCollect:GetTypeCellNumber(value)
	return #self.suit_type_data
end

function OrangeSuitCollect:TypeCellRefresh(cell, index)
	index = index + 1
	local suit_cell = self.suit_cell_list[cell]
	if nil == suit_cell then
		suit_cell = OrangeSuitTypeItemCell.New(cell.gameObject)
		suit_cell:SetClickCallBack(BindTool.Bind(self.ClickSuitTypeCallBack, self))
		self.suit_cell_list[cell] = suit_cell
	end

	local data = self.suit_type_data[index]
	suit_cell:SetIndex(data.seq)
	suit_cell:SetData(data)

	if self.choose_type_data and self.choose_type_data.seq == data.seq then
		suit_cell:FlushHL(true)
	else
		suit_cell:FlushHL(false)
	end

end
-----------------End-------------------

function OrangeSuitCollect:ClickSuitTypeCallBack(cell_data)
	self.choose_type_data = cell_data
	self:Flush()

	local level = GameVoManager.Instance:GetMainRoleVo().level
	if cell_data.active_role_level > level then
		-- local zhuan = math.floor(cell_data.active_role_level / 100) or 0
		-- local level = cell_data.active_role_level - (zhuan * 100) or 0
		local show_tip = string.format(Language.SuitCollect.SuitCollectTips3, cell_data.active_role_level, cell_data.order)
		TipsCtrl.Instance:ShowSystemMsg(show_tip)
	end

	for k, v in pairs(self.suit_cell_list) do
		if v:GetIndex() == cell_data.seq then
			v:FlushHL(true)
		else
			v:FlushHL(false)
		end
	end
end

function OrangeSuitCollect:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "ui_tween" then
			local ui_cfg = SuitCollectionData.Instance:GetUITweenCfg(TabIndex.orange_suit_collect)
			UITween.MoveShowPanel(self.node_list["ListPanel"] , ui_cfg["ListPanel"], ui_cfg["MOVE_TIME"])
			UITween.MoveShowPanel(self.node_list["RightPanel"] , ui_cfg["RightPanel"], ui_cfg["MOVE_TIME"])
			-- UITween.AlpahShowPanel(self.node_list["UpPanel"] , ui_cfg["UpPanel"], ui_cfg["MOVE_TIME"], DG.Tweening.Ease.InExpo)
		end
	end
	if not self.choose_type_data or not next(self.choose_type_data) then
		return
	end
	local data = self.choose_type_data

	for k, v in pairs(self.suit_cell_list) do
		v:FlushTypeRemind()
	end

	local star_info = SuitCollectionData.Instance:GetOrangeStarsInfo(data.seq)
	self.active_equip_num = star_info and star_info.item_count or 0



	self.suit_attr_data = SuitCollectionData.Instance:GetOrangeCollectAttr(data.seq) or {}
	self:LoadCell()
	for k, v in pairs(self.suit_attr_data) do
		local data = self.suit_attr_data[k]
		if self.attr_cell_list[k] then 
			self.attr_cell_list[k]:SetData(data)
		end
	end

	local temp_attr_tab = CommonStruct.AttributeNoUnderline()
	for k, v in pairs(self.suit_attr_data) do
		if self.active_equip_num >= v.collect_count then
			local temp_attr = CommonDataManager.GetAttributteNoUnderline(v)
			temp_attr_tab = CommonDataManager.AddAttributeAttrNoUnderLine(temp_attr_tab, temp_attr)
		end
	end

	local power = CommonDataManager.GetCapability(temp_attr_tab)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = power
	end

	self.progress:SetValue(self.active_equip_num / 10)
	self.node_list["ProgressBGText"].text.text = self.active_equip_num .. "/10" 

	--装备列表
	local equip_list = SuitCollectionData.Instance:GetOrangeEquipCollect(data.seq)
	local equip_collect_cfg = SuitCollectionData.Instance:GetOrangeCollectEquipCfg(data.seq)
	if nil == equip_list or nil == equip_collect_cfg then 
		return
	end

	local equip_id_tab = Split(equip_collect_cfg.equip_items, "|")
	local virtual_id_tab = Split(equip_collect_cfg.ts_virtual, "|")
	for k, v in pairs(self.equip_item_list) do
		-- if equip_list[k] and equip_list[k].item_id and equip_list[k].item_id > 0 then
		-- end
		if equip_id_tab[k + 1] and virtual_id_tab[k + 1] then
			v:SetEquipIdAndVirtualId(equip_id_tab[k + 1], virtual_id_tab[k + 1], data.seq)
		end

		if equip_list[k] then
			v:SetData(equip_list[k])
		end
	end
end

function OrangeSuitCollect:GetAttrTab(attr_tab)
	local attr_tab = CommonDataManager.GetAttributteNoUnderline(attr_tab)
	local total_attr = {}
	local count = 1
	for k, v in pairs(attr_tab) do
		if v > 0 then
			total_attr[count] = {}
			total_attr[count].name = CommonDataManager.GetAttrName(k)
			total_attr[count].value = v
			count = count + 1
		end
	end
	return total_attr
end

function OrangeSuitCollect:OnBtnGotoGet()
	-- if not ViewManager.Instance:IsOpen(ViewName.Boss) then
	-- 	ViewManager.Instance:OpenByCfg(self.choose_type_data.get_way)
	-- end
	local data = {
		from_view = "orange_suit",
		select_seq = self.choose_type_data.seq
	}
	ChatCtrl.Instance:OpenWantEquipView(SPECIAL_CHAT_ID.GUILD, data)
end

function OrangeSuitCollect:OnBtnHelp()
	local tips_id = 298
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end




----------------------------------------
----套装类型 OrangeSuitTypeItemCell
OrangeSuitTypeItemCell = OrangeSuitTypeItemCell or BaseClass(BaseCell)
function OrangeSuitTypeItemCell:__init()
	self.root_node.button:AddClickListener(BindTool.Bind(self.ClickTypeItem, self))

	self.equip_cell = ItemCell.New()
	self.equip_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.equip_cell:ListenClick(BindTool.Bind(self.ClickCellItem, self))
end

function OrangeSuitTypeItemCell:__delete()
	if self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil
	end
end

function OrangeSuitTypeItemCell:ClickCellItem()
	self.equip_cell:SetHighLight(false)
	if self.click_callback then
		self.click_callback(self.data)
	end
end

function OrangeSuitTypeItemCell:ClickTypeItem()
	if self.click_callback then
		self.click_callback(self.data)
	end
end

function OrangeSuitTypeItemCell:OnFlush()
	if nil == self.data then return end

	self.node_list["SuitName"].text.text = self.data.name
	
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if level < self.data.active_role_level then
		self.node_list["Lock"]:SetActive(true)
	else
		self.node_list["Lock"]:SetActive(false)
	end

	local equip_id_tab = SuitCollectionData.Instance:GetOrangeCollectEquipCfg(self.data.seq)
	if nil == equip_id_tab then 
		return
	end

	local equip_id_tab = Split(equip_id_tab.equip_items, "|")
	self.equip_cell:SetData({item_id = tonumber(equip_id_tab[2])})
	self.equip_cell:ShowEquipGrade(false)

	self:FlushTypeRemind()
end

-- function OrangeSuitTypeItemCell:SetActive(enable)
-- 	self.root_node:SetActive(enable)
-- end

function OrangeSuitTypeItemCell:FlushTypeRemind()
	if SuitCollectionData.Instance:GetOrangeRemindBySeq(self.data.seq) then
		self.node_list["Remind"]:SetActive(true)
	else
		self.node_list["Remind"]:SetActive(false)
	end
end

function OrangeSuitTypeItemCell:FlushHL(value)
	if self.node_list["HL"] then
		self.node_list["HL"]:SetActive(value)
	end
end


------------------------------------
------ 装备格子 OrangeEquipItemCell
OrangeEquipItemCell = OrangeEquipItemCell or BaseClass(BaseCell)
function OrangeEquipItemCell:__init(instance, is_next)
	self.equip_cell = ItemCell.New()
	self.equip_cell:SetInstanceParent(self.node_list["EquipItem"])

	self.equip_cell:ListenClick(BindTool.Bind(self.ClickItem, self))
	self.root_node.button:AddClickListener(BindTool.Bind(self.ClickItem, self))
end

function OrangeEquipItemCell:__delete()
	if self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil
	end

	self.equip_id = nil
	self.virtual_id = nil
end

-- 设置可装备的装备ID和虚拟物品ID
function OrangeEquipItemCell:SetEquipIdAndVirtualId(equip_id, virtual_id, seq)
	self.equip_id = tonumber(equip_id)
	self.virtual_id = tonumber(virtual_id)
	self.curr_seq = tonumber(seq)
end

function OrangeEquipItemCell:ClickItem()
	local suit_type_cfg = SuitCollectionData.Instance:GetOrangeItemType(self.curr_seq)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if suit_type_cfg and level < suit_type_cfg.active_role_level then
		local show_tip = string.format(Language.SuitCollect.SuitCollectTips3, suit_type_cfg.active_role_level, suit_type_cfg.order)
		TipsCtrl.Instance:ShowSystemMsg(show_tip)
		return
	end


	if nil == self.data or nil == self.data.item_id or self.data.item_id <= 0 then
		local bag_item = SuitCollectionData.Instance:GetEquipByItemId(self.equip_id)
		if next(bag_item) and self.curr_seq then
			local function ok_callback()
				SuitCollectionCtrl.Instance:SendReqCommonOpreate(COMMON_OPERATE_TYPE.COT_REQ_ORANGE_EQUIP_COLLECT_TAKEON, 
					self.curr_seq, self.index, bag_item[1].index)
			end
			if self.is_show_tip then
				local des = Language.SuitCollect.TipConfirmDesc
				TipsCtrl.Instance:ShowCommonAutoView("orange_suitcollect", des, ok_callback, nil, nil, nil, nil, nil, nil, false)
			else
				ok_callback()
			end
		else
			if self.virtual_id then
				local item_data = {item_id = self.virtual_id}
				TipsCtrl.Instance:OpenItem(item_data)	
			end
		end
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.SuitCollect.SuitEquipJiqiText3)
	end
end

function OrangeEquipItemCell:OnFlush()
	self.node_list["BtnImprove"]:SetActive(false)
	local suit_type_cfg = SuitCollectionData.Instance:GetOrangeItemType(self.curr_seq)
	if not suit_type_cfg then return end

	local level = GameVoManager.Instance:GetMainRoleVo().level
	self.is_show_tip = false
	if nil == self.data or nil == self.data.item_id or self.data.item_id <= 0 then
		self.equip_cell:SetItemActive(false)
		if self.equip_id then
			local bag_item = SuitCollectionData.Instance:GetEquipByItemId(self.equip_id)
			if next(bag_item) then
				local item_cfg = ItemData.Instance:GetItemConfig(self.equip_id)
				local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
				local wear_equip = ForgeData.Instance:GetZhuanzhiEquip(equip_index)
				if wear_equip and wear_equip.item_id > 0 then
					local wear_item_cfg = ItemData.Instance:GetItemConfig(wear_equip.item_id)
					local bag_equip_cap = EquipData.Instance:GetEquipCapacityPower(item_cfg)
					local wear_equip_cap = EquipData.Instance:GetEquipCapacityPower(wear_equip)
					if bag_equip_cap <= wear_equip_cap and suit_type_cfg.active_role_level <= level then
						self.node_list["BtnImprove"]:SetActive(true)
					else
						self.is_show_tip = true
					end
				else
					self.is_show_tip = true
				end
			end
		end
		return
	else
		self.equip_cell:SetItemActive(true)
	end

	self.equip_cell:SetData(self.data)
end

function OrangeEquipItemCell:SetToggleGroup(toggle_group)
	self.equip_cell:SetToggleGroup(toggle_group)
end



-----------------------------------------
-- 套装属性 OrangeSuitAttrCell  obj_name:OrangeSuitAttrCell
OrangeSuitAttrCell = OrangeSuitAttrCell or BaseClass(BaseCell)
function OrangeSuitAttrCell:__init()

end

function OrangeSuitAttrCell:__delete()
	
end

function OrangeSuitAttrCell:OnFlush()
	if self.data == nil then 
		self.root_node:SetActive(false)
		return 
	end
	self.root_node:SetActive(true)
	-- self.node_list["SuitCount"].text.text = string.format(Language.Forge.SuitCount, self.data.same_order_num)
	-- local color = (self.had_equip_num >= self.data.same_order_num) and TEXT_COLOR.GREEN or TEXT_COLOR.WHITE

	-- local count = 1
	-- for k, v in pairs(Language.Forge.SuitShowType) do
	-- 	if self.data[v] and self.data[v] > 0 then
	-- 		if string.find(k, "per") then
	-- 			self.node_list["Attr" .. count].text.text = ToColorStr(string.format(Language.Forge.SuitShowAttr[v], (self.data[v] / 100) .. "%"), color)
	-- 		else
	-- 			self.node_list["Attr" .. count].text.text = ToColorStr(string.format(Language.Forge.SuitShowAttr[v], self.data[v]), color)
	-- 		end
	-- 		self.node_list["Attr" .. count]:SetActive(true)
	-- 		count = count + 1
	-- 	end
	-- end

	-- for i = count, 6 do
	-- 	self.node_list["Attr" .. i].text.text = ""
	-- 	self.node_list["Attr" .. i]:SetActive(false)
	-- end

	local star_info = SuitCollectionData.Instance:GetOrangeStarsInfo(self.data.seq)
	local active_equip_num = star_info and star_info.item_count or 0
	local color = active_equip_num >= self.data.collect_count and TEXT_COLOR.GREEN or TEXT_COLOR.WHITE
	local count_color = active_equip_num >= self.data.collect_count and TEXT_COLOR.GREEN or TEXT_COLOR.LOWBLUE

	local attr_tab = self:GetAttrTabAndFight(self.data)
	local count = 1
	local function set_text(value)
		if self.node_list["Attr" .. count] then
			self.node_list["Attr" .. count].text.text = ToColorStr(value, color)
	 		self.node_list["Attr" .. count]:SetActive(true)
			count = count + 1
		end
	end
	for k, v in pairs(attr_tab) do
		set_text(v.name .. "+" .. v.value)
		if k == #attr_tab then
			set_text("")
		end
 	end

 	for i = count, 6, 1 do
 		self.node_list["Attr" .. i]:SetActive(false)
 	end

 	if count > 1 then
 		self.node_list["SuitCount"].text.text = ToColorStr(string.format(Language.Forge.SuitNumCout, self.data.collect_count), count_color)
 	end
end

function OrangeSuitAttrCell:GetAttrTabAndFight(cfg)
	local attr_tab = CommonDataManager.GetAttributteNoUnderline(cfg)
	local sort_attr = CommonDataManager.GetOrderAttributte(attr_tab)
	local total_attr = {}
	local count = 1
	for k, v in pairs(sort_attr) do
		if v.value > 0 then
			total_attr[count] = {}
			total_attr[count].name = CommonDataManager.GetAttrNameWithNoSpace(v.key)
			total_attr[count].value = v.value
			count = count + 1
		end
	end
	return total_attr
end
