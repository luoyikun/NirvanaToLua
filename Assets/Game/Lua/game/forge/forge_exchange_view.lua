ForgeExchangeView = ForgeExchangeView or BaseClass(BaseRender)

local SelectEquipRow = 4
function ForgeExchangeView:__init(instance, parent_view)
	self.node_list["BtnExchange"].button:AddClickListener(BindTool.Bind(self.OnBtnExchange, self))
	self.node_list["BtnAutoAdd"].button:AddClickListener(BindTool.Bind(self.OnBtnAutoAdd, self))
	self.node_list["ButtonHelp"].button:AddClickListener(BindTool.Bind(self.OnButtonHelp, self))

	self.item_list = {}
	self.item_cell_list = {}
	
	self.select_btn_list = {}
	for i = 1, 3 do
		local obj = self.node_list["SelectBtn" .. i]
		local name_tab = U3DNodeList(obj.transform:GetComponent(typeof(UINameTable)))
		local item_tab = {}
		item_tab["SelectBtn"] = obj
		item_tab["BtnText"] = name_tab["BtnText"]
		item_tab["HLBtnText"] = name_tab["HLBtnText"]
		item_tab["RedPoint"] = name_tab["RedPoint"]
		self.select_btn_list[i] = item_tab
	end

	-- 获得手风琴名字配置
	self.exchange_cfg  = ForgeData.Instance:GetEquipExchangeCfg()
	self.min_order, self.max_order = ForgeData.Instance:GetExchangeShowOrder()
	local wai_name_cfg = {}
	local nei_name_cfg = {}


	for k, v in pairs(self.exchange_cfg) do
		local temp_wai = k + 1
		wai_name_cfg[temp_wai] = Language.Forge.ExchangeEquipName[temp_wai]
		nei_name_cfg[temp_wai] = {}
		local index = 1
		for k1, v1 in pairs(v) do
			if v1.order >= self.min_order and v1.order <= self.max_order then
				nei_name_cfg[temp_wai][index] = v
				index = index + 1
			end
		end
	end
	for i = 1, 3 do
		self.select_btn_list[i]["BtnText"].text.text = wai_name_cfg[i]
		self.select_btn_list[i]["HLBtnText"].text.text = wai_name_cfg[i]
		local cfg = nei_name_cfg[i] or {}
		self:LoadCell(i, cfg)
	end

	-- 选择List
	self.exchange_equip_show_data = {}
	self.exchange_select_equip_cell = {}
	local list_view_delegate = self.node_list["ComposeSelectList"].list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetSelectNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshSelectListView, self)

	self.material_cell_data = {}
	self.material_cells = {}
	for i = 1, 5 do
		local cell = ItemCell.New()
		cell:SetInstanceParent(self.node_list["MaterialCell" .. i])
		cell:ListenClick(BindTool.Bind(self.OnClickMaterialCallBack, self, i))
		cell:SetFromView(TipsFormDef.FROM_FORGE_EXCHANGE)
		self.material_cells[i] = cell

		self.node_list["ClickMaterial" .. i].button:AddClickListener(BindTool.Bind(self.OnClickMaterialCallBack, self, i))
	end

	self.equip_cell = ItemCell.New()
	self.equip_cell:SetInstanceParent(self.node_list["EquipItem"])
	self.equip_cell:SetFromView(TipsFormDef.FROM_FORGE_EXCHANGE)
	-- self.equip_cell:SetFromView(TipsFormDef.FROM_BAG_EQUIP)

	-- self.select_index = 1
	self.is_first_time = true
	self:Flush("flush_list")
end

function ForgeExchangeView:__delete()
	for k,v in pairs(self.item_list) do
		ResMgr:Destroy(v.gameObject)
	end

	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}

	for k,v in pairs(self.material_cells) do
		v:DeleteMe()
	end
	self.material_cells = {}

	if self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil
	end

	self.select_index = 1
	self.exchange_equip_show_data = {}
	self.is_first_time = true
end

-- 手风琴
function ForgeExchangeView:LoadCell(index, sub_type)
	local res_async_loader = AllocResAsyncLoader(self, "loader_" .. index)
	res_async_loader:Load("uis/views/forgeview_prefab", "ComposeSelectListCell", nil, function (prefab)
		if nil == prefab then
			return
		end
		for i = 1, #sub_type do
			local obj = ResMgr:Instantiate(prefab)
			local obj_transform = obj.transform
			obj_transform:SetParent(self.node_list["List" .. index].transform, false)
			obj:GetComponent("Toggle").group = self.node_list["List" .. index].toggle_group

			local item_cell = ExchangeAccordionItem.New(obj)

			local cfg_length = self.max_order + 1

			item_cell:SetData(sub_type[i][cfg_length - i])
			item_cell:SetIndex(#self.item_cell_list + 1)
			item_cell:SetGroupIndex(4 - index)
			item_cell:SetClickCallBack(BindTool.Bind(self.ClickCellCallBack, self))

			self.item_list[#self.item_list + 1] = obj_transform
			self.item_cell_list[#self.item_cell_list + 1] = item_cell

			if #self.item_cell_list == #sub_type then
				self.node_list["SelectBtn1"].accordion_element.isOn = true
				self.item_list[1].gameObject:GetComponent("Toggle").isOn = true
			end
		end
	end)
end

function ForgeExchangeView:ClickCellCallBack(cell)
	self.select_index = cell:GetIndex()
	for k, v in pairs(self.item_list) do
		if self.item_cell_list[k]:GetIndex() ~= self.select_index  then
			v.gameObject:GetComponent("Toggle").isOn = false
		end
	end
	
	local cell_data = cell:GetData()
	self.select_group_index = cell:GetGroupIndex()
	self:FlushSelectEquipList(cell_data)
	self:Flush("flush_list")
end

function ForgeExchangeView:FlushSelectEquipList(cell_data)
	if nil == cell_data then return end

	for i = 1, 7 do
		local temp_id = cell_data["cao" .. i]
		local row = math.ceil(i / SelectEquipRow)
		local rel = math.floor((i - SelectEquipRow * (row - 1)) % (SelectEquipRow + 1))
		if not self.exchange_equip_show_data[row] then
			self.exchange_equip_show_data[row] = {}
		end

		self.exchange_equip_show_data[row]["equipid" .. rel] = temp_id
	end

	self:ShowSelectEquipListOrFrame(true)
end

---------------选择List
function ForgeExchangeView:GetSelectNumberOfCells()
	return #self.exchange_equip_show_data or 0
end

function ForgeExchangeView:RefreshSelectListView(cell, cell_index)
	local item_cell = self.exchange_select_equip_cell[cell]
	if nil == item_cell then
		item_cell = ExchangeSelectEquipItem.New(cell.gameObject)
		item_cell:SetClickCallBack(BindTool.Bind(self.OnClickSelectEquipItemCell, self))
		self.exchange_select_equip_cell[cell] = item_cell
	end

	cell_index = cell_index + 1
	-- local data = {}
	-- for i = 1, SelectEquipRow do
	-- 	local data_index = cell_index * SelectEquipRow + i
	-- 	local temp_data = self.exchange_equip_show_data[data_index] or {}
	-- 	table.insert(data, temp_data)
	-- end
	local data = self.exchange_equip_show_data[cell_index]
	item_cell:SetGourpIndex(self.select_group_index)
	item_cell:SetIndex(cell_index)
	item_cell:SetData(data)
	-- local select_index = self.view_click_index[self.role_view_index] or self.select_index
	-- item_cell:SetSelectHL(select_index == data.click_index)
end

function ForgeExchangeView:OnClickSelectEquipItemCell(equipid)
	if nil == equipid then return end

	self.target_exchange_equip_id = equipid
	self:ShowSelectEquipListOrFrame(false)

	for k, v in pairs(self.material_cells) do
		v:SetData({})
	end
	self.material_cell_data = {}
	ForgeData.Instance:ResetExchangeBagEquipIndexList()
	self:Flush("flush_target_equip")
end

-- 显示合成或者选择界面
function ForgeExchangeView:ShowSelectEquipListOrFrame(is_show)
	self.node_list["ComposeSelect"]:SetActive(is_show)
	self.node_list["ComposeFrame"]:SetActive(not is_show)
end

function ForgeExchangeView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if "flush_list" == k then
			if self.is_first_time then
				self.select_group_index = 3
				local temp_data = self.exchange_cfg[2][self.max_order]
				self:FlushSelectEquipList(temp_data)
				self.is_first_time = false
			end
			self.node_list["ComposeSelectList"].scroller:ReloadData(0)
		elseif "flush_target_equip" == k then
			if nil == self.target_exchange_equip_id or nil == self.select_group_index then
				return
			end

			local target_equip_cfg = ForgeData.Instance:GetTargetEquipExchangeCfg(self.target_exchange_equip_id, self.select_group_index)
			if nil == target_equip_cfg then return end
			local xianpin_type_list = {}
			local xianpin = {1, 2, 3}
			for i = 1, target_equip_cfg.compose_equip_best_attr_num do
				xianpin_type_list[i] = xianpin[i]
			end
			local equip_data = {item_id = self.target_exchange_equip_id, param = {xianpin_type_list = xianpin_type_list}}
			self.equip_cell:SetData(equip_data)

			local item_cfg = ItemData.Instance:GetItemConfig(self.target_exchange_equip_id)
			if item_cfg then
				self.node_list["EquipName"].text.text = item_cfg.name
			end
		elseif "item_change" == k then
			for k, v in pairs(self.material_cell_data) do
				local bag_item = ItemData.Instance:GetGridData(v.index)
				if not bag_item or bag_item.item_id ~= v.item_id then
					ForgeData.Instance:SetExchangeBagEquipIndexList(v.index, nil)
					self.material_cell_data[k] = nil
					self.material_cells[k]:SetData({})
				end
			end
			self:PlayIsSuccEff()
		end
	end

	if nil == self.target_exchange_equip_id or nil == self.select_group_index then
		return
	end
	local target_equip_cfg = ForgeData.Instance:GetTargetEquipExchangeCfg(self.target_exchange_equip_id, self.select_group_index)
	if nil == target_equip_cfg then return end

	self.node_list["MaterialText"].text.text = string.format(Language.Forge.ExchangeNeedMaterialDesc, target_equip_cfg.order - 1, target_equip_cfg.best_attr_count)

	local material_count = 0
	for i = 1, 5 do
		self.node_list["ClickMaterial" .. i]:SetActive(true)
	end
	for k, v in pairs(self.material_cell_data) do
		self.node_list["ClickMaterial" .. k]:SetActive(false)
		material_count = material_count + 1
	end
	local succ_rate_index = material_count - 3
	local succ_rate = target_equip_cfg["success_rate_" .. succ_rate_index] and (target_equip_cfg["success_rate_" .. succ_rate_index] / 100) or 0
	self.node_list["SuccRate"].text.text = string.format(Language.Forge.ExchangeSuccRate, succ_rate)


end

function ForgeExchangeView:OnClickMaterialCallBack(material_cell_index)
	self.select_material_index = material_cell_index

	if self.material_cell_data[material_cell_index] then
		local equip_data = self.material_cell_data[material_cell_index]
		ForgeData.Instance:SetExchangeBagEquipIndexList(equip_data.index, nil)
		self.material_cell_data[material_cell_index] = nil
		self.material_cells[material_cell_index]:SetData({})
		self:Flush()
	else
		ForgeCtrl.Instance:OpenExchangeEquipListView({
			target_equip = self.target_exchange_equip_id,
			target_attr_num = self.select_group_index,
			call_back = function (equip_data)
				if nil ~= equip_data then
					ForgeData.Instance:SetExchangeBagEquipIndexList(equip_data.index, true)
					self.material_cells[material_cell_index]:SetData(equip_data)
					self.material_cell_data[material_cell_index] = equip_data
					self:Flush()
				end
		end})
	end
end

function ForgeExchangeView:OnBtnExchange()
	if nil == self.target_exchange_equip_id or nil == self.select_group_index then
		return
	end
	local target_equip_cfg = ForgeData.Instance:GetTargetEquipExchangeCfg(self.target_exchange_equip_id, self.select_group_index)
	if nil == target_equip_cfg then return end

	local material_count = 0
	local bag_index_list = {}
	local is_bind = false
	for k, v in pairs(self.material_cell_data) do
		material_count = material_count + 1
		table.insert(bag_index_list, v.index)
		if v.is_bind == 1 then
			is_bind = true
		end
	end
	if material_count < 3 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.ExchangeNeedCount)
		return 
	end

	for i = (material_count + 1), 5 do
		table.insert(bag_index_list, -1)
	end 
	local ok_callback = function()
		ForgeCtrl.Instance:SendCSZhuanzhiEquipCompose(target_equip_cfg.compose_equip_id, target_equip_cfg.compose_equip_best_attr_num, material_count, bag_index_list)
	end

	if is_bind then
		local des = Language.Forge.ComposeBinde
		TipsCtrl.Instance:ShowCommonAutoView(nil, des, ok_callback)
	else
		ok_callback()
	end
end

function ForgeExchangeView:OnBtnAutoAdd()
	local target_equip_cfg = ForgeData.Instance:GetTargetEquipExchangeCfg(self.target_exchange_equip_id, self.select_group_index)
	local equip_cfg = ItemData.Instance:GetItemConfig(self.target_exchange_equip_id)
	if nil == target_equip_cfg or nil == equip_cfg then return end

	local target_equip_list = ForgeData.Instance:GetExchangeMaterialEquipList(target_equip_cfg.color, target_equip_cfg.best_attr_count, equip_cfg.order)
	if #target_equip_list <= 0 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.ExchangeHaveNoCount)
	end

	local count = 1
	for k, v in pairs(self.material_cells) do
		local equip_data = target_equip_list[count]
		if equip_data and not self.material_cell_data[k] then
			v:SetData(equip_data)
			self.material_cell_data[k] = equip_data
			count = count + 1
			ForgeData.Instance:SetExchangeBagEquipIndexList(equip_data.index, true)
		elseif not equip_data then
			break
		end
	end
	self:Flush()
end

function ForgeExchangeView:PlayIsSuccEff()
	local is_success = ForgeData.Instance:GetExchangeEquipIsSucc()
	if is_success then
		local bundle, asset
		if 1 == is_success then
			bundle, asset = ResPath.GetUiXEffect("UI_hccg_01")
		elseif 0 == is_success then
			bundle, asset = ResPath.GetUiXEffect("UI_hcsb_01")
		end

		local async_loader = AllocAsyncLoader(self, "exchange_effect")
		async_loader:Load(bundle, asset, 
			function (obj)
				if not IsNil(obj) then
					local transform = obj.transform
					transform:SetParent(self.node_list["EffPos"].transform, false)
				end
			end)

		ForgeData.Instance:SetExchangeEquipIsSucc(nil)
	end
end

function ForgeExchangeView:OnButtonHelp()
	local tips_id = 330
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end


-------------------
----手风琴Item
ExchangeAccordionItem = ExchangeAccordionItem or BaseClass(BaseCell)

function ExchangeAccordionItem:__init(instance)
	-- self.equip_cell = ItemCell.New()
	-- self.equip_cell:SetInstanceParent(self.node_list["ItemCell"])
	-- self.equip_cell:SetFromView(TipsFormDef.FROM_BAG_EQUIP)
	
	self.node_list["BaseEquipCell"].toggle:AddClickListener(handler or BindTool.Bind(self.OnClickItemCell, self))
end

function ExchangeAccordionItem:__delete()
	-- if nil ~= self.equip_cell then
	-- 	self.equip_cell:DeleteMe()
	-- 	self.equip_cell = nil
	-- end
end

function ExchangeAccordionItem:OnClickItemCell(is_on)
	if is_on then
		self.click_callback(self)
	end
end

function ExchangeAccordionItem:SetGroupIndex(group_index)
	self.group_index = group_index
end

function ExchangeAccordionItem:GetGroupIndex()
	return self.group_index
end

function ExchangeAccordionItem:OnFlush()
	if nil == self.data then return end

	-- local item_cfg = ItemData.Instance:GetItemConfig(self.data.compose_equip_id)
	-- self.equip_cell:SetData({item_id = self.data.compose_equip_id, is_from_extreme = self.data.compose_equip_best_attr_num}) 
	-- self.node_list["Name"].text.text = item_cfg.name

	self.node_list["Name"].text.text = string.format(Language.Forge.ExchangeEquipDesc ,self.data.order - 1)
	self.node_list["HLName"].text.text = string.format(Language.Forge.ExchangeEquipDesc ,self.data.order - 1)
end



-------------------
----选择装备Item
ExchangeSelectEquipItem = ExchangeSelectEquipItem or BaseClass(BaseCell)

function ExchangeSelectEquipItem:__init(instance)
	self.equip_cell_list = {}
	for i = 1, 4 do
		local equip_cell = ItemCell.New()
		equip_cell:SetInstanceParent(self.node_list["EquipItem" .. i])
		equip_cell:ListenClick(BindTool.Bind(self.OnButtonSelectEquip, self, i))
		-- equip_cell:SetFromView(TipsFormDef.FROM_BAG_EQUIP)
		self.equip_cell_list[i] = equip_cell

		self.node_list["ItemBG" .. i].button:AddClickListener(BindTool.Bind(self.OnButtonSelectEquip, self, i))
	end

end

function ExchangeSelectEquipItem:__delete()
	for k, v in pairs(self.equip_cell_list) do
		v:DeleteMe()
	end
	self.equip_cell_list = {}
end

function ExchangeSelectEquipItem:SetGourpIndex(group_index)
	self.group_index = group_index
end

function ExchangeSelectEquipItem:OnButtonSelectEquip(cell_index)
	if self.click_callback and self.data["equipid" .. cell_index] then
		self.click_callback(self.data["equipid" .. cell_index])
	end
end

function ExchangeSelectEquipItem:OnFlush()
	if nil == self.data or nil == next(self.data) then
		return
	end

	for k, v in pairs(self.equip_cell_list) do
		if self.data["equipid" .. k] then
			local xianpin_type_list = {}
			local xianpin = {1, 2, 3}
			for i = 1, self.group_index do
				xianpin_type_list[i] = xianpin[i]
			end
			local temp_data = {item_id = self.data["equipid" .. k], param = {xianpin_type_list = xianpin_type_list}}

			v:SetData(temp_data)
			self.node_list["ItemBG" .. k]:SetActive(true)

			local equip_cfg = ItemData.Instance:GetItemConfig(self.data["equipid" .. k])
			if equip_cfg then
				self.node_list["EquipName" .. k].text.text = equip_cfg.name
			else
				self.node_list["EquipName" .. k].text.text = ""
			end
		else
			self.node_list["ItemBG" .. k]:SetActive(false)
			self.node_list["EquipName" .. k].text.text = ""
		end
	end
end


