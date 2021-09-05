ForgeExtremeSuit = ForgeExtremeSuit or BaseClass(BaseRender)

function ForgeExtremeSuit:__init(instance, parent_view)
	self.node_list["BtnForge"].button:AddClickListener(BindTool.Bind(self.OnBtnForge, self))
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
		item_tab["RedPoint"] = name_tab["RedPoint"]
		self.select_btn_list[i] = item_tab
	end

	-- 获得手风琴名字配置
	self.suit_type_cfg  = ForgeData.Instance:GetExtremeSuitCfg()
	local wai_name_cfg = {}
	local nei_name_cfg = {}
	for k, v in pairs(self.suit_type_cfg) do
		wai_name_cfg[k] = Language.Forge.ExtremeSuitName[k]
		nei_name_cfg[k] = {}
		for k1, v1 in pairs(v) do
			nei_name_cfg[k][k1] = v
		end
	end
	for i = 1, 3 do
		self.select_btn_list[i]["BtnText"].text.text = wai_name_cfg[i]
		local cfg = nei_name_cfg[i] or {}
		self:LoadCell(i, cfg)
	end

	self.material_cells = {}
	for i = 1, 3 do
		local cell = ItemCell.New()
		cell:SetInstanceParent(self.node_list["MaterialCell" .. i])
		self.material_cells[i] = cell
		self.material_cells[i]:SetFromView(TipsFormDef.FROM_BAG_EQUIP)
	end

	self.equip_cell = ItemCell.New()
	self.equip_cell:SetInstanceParent(self.node_list["EquipItem"])
	self.equip_cell:SetFromView(TipsFormDef.FROM_BAG_EQUIP)

	self.select_index = 1

end

function ForgeExtremeSuit:__delete()
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
end

function ForgeExtremeSuit:LoadCell(index, sub_type)
	local res_async_loader = AllocResAsyncLoader(self, "loader_" .. index)
	res_async_loader:Load("uis/views/forgeview_prefab", "ExtremeSuitCell", nil, function (prefab)
		if nil == prefab then
			return
		end
		for i = 1, #sub_type do
			local obj = ResMgr:Instantiate(prefab)
			local obj_transform = obj.transform
			obj_transform:SetParent(self.node_list["List" .. index].transform, false)
			obj:GetComponent("Toggle").group = self.node_list["List" .. index].toggle_group

			local item_cell = AccordionItem.New(obj)
			item_cell:SetData(sub_type[i][i])
			item_cell:SetIndex(#self.item_cell_list + 1)
			item_cell:SetClickCallBack(BindTool.Bind(self.ClickCellCallBack, self))

			self.item_list[#self.item_list + 1] = obj_transform
			self.item_cell_list[#self.item_cell_list + 1] = item_cell

			if #self.item_cell_list == 6 then
				self.node_list["SelectBtn1"].accordion_element.isOn = true
				self.item_list[1].gameObject:GetComponent("Toggle").isOn = true
			end
		end
	end)
end

function ForgeExtremeSuit:ClickCellCallBack(cell)
	self.select_index = cell:GetIndex()
	for k, v in pairs(self.item_list) do
		if self.item_cell_list[k]:GetIndex() ~= self.select_index  then
			v.gameObject:GetComponent("Toggle").isOn = false
		end
	end
	
	self:Flush()
end

function ForgeExtremeSuit:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "ui_tween" then
			local ui_cfg = ForgeData.Instance:GetUITweenCfg(TabIndex.forge_extreme_suit)
			UITween.MoveShowPanel(self.node_list["LeftPanel"] , ui_cfg["LeftPanel"], ui_cfg["MOVE_TIME"])
			UITween.MoveShowPanel(self.node_list["DownPanel"] , ui_cfg["DownPanel"], ui_cfg["MOVE_TIME"])
			UITween.AlpahShowPanel(self.node_list["UpPanel"] , ui_cfg["UpPanel"], ui_cfg["MOVE_TIME"], DG.Tweening.Ease.InExpo)
		end
	end
	if nil == self.select_index then return end

	local num1 = math.ceil(self.select_index / 2)
	local num2 = self.select_index % 2
	num2 = (num2 == 0) and 2 or num2
	if self.suit_type_cfg[num1] then
		self.compose_data = self.suit_type_cfg[num1][num2]
	end
	local data = self.compose_data or {}

	if next(data) then
		self.equip_cell:SetData({item_id = data.compose_equip_id, is_from_extreme = data.compose_equip_best_attr_num})
		local had_num = ItemData.Instance:GetItemNumInBagById(data.stuff1_id)
		local str = had_num .. "/" .. data.stuff1_num
		self.material_cells[3]:SetData({item_id = data.stuff1_id})
		self.material_cells[3]:SetItemNumVisible(true, str)

		local item_cfg = ItemData.Instance:GetItemConfig(self.compose_data.equip1_id)
		self.equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
		local equip_data = ForgeData.Instance:GetZhuanzhiEquip(self.equip_index) or {}
		local role_equip = equip_data.item_id or 0
		local need_num = role_equip == self.compose_data.equip1_id and 1 or 2
		local bag_equip = ItemData.Instance:GetItems(self.compose_data.equip1_id, need_num)
		if need_num == 1 then
			self.material_cells[1]:SetData({item_id = data["equip" .. 1 .. "_id"], is_from_extreme = data.compose_equip_best_attr_num})
			self.material_cells[1]:SetItemNumVisible(true, "1/1")

			local str2 = #bag_equip >= 1 and "1/1" or "0/1"
			self.material_cells[2]:SetData({item_id = data["equip" .. 2 .. "_id"], is_from_extreme = data.compose_equip_best_attr_num})
			self.material_cells[2]:SetItemNumVisible(true, str2)
		else
			self.material_cells[1]:SetData({item_id = data["equip" .. 1 .. "_id"], is_from_extreme = data.compose_equip_best_attr_num})
			self.material_cells[2]:SetData({item_id = data["equip" .. 2 .. "_id"], is_from_extreme = data.compose_equip_best_attr_num})

			local str1 = #bag_equip >= 1 and "1/1" or "0/1"
			local str2 = #bag_equip >= 2 and "1/1" or "0/1"
			self.material_cells[1]:SetItemNumVisible(true, str1)
			self.material_cells[2]:SetItemNumVisible(true, str2)
		end

		self.node_list["MaterialText"].text.text = data.equip_number
	end
end

function ForgeExtremeSuit:OnBtnForge()
	if not self.compose_data then return end
	
	local equip_data = ForgeData.Instance:GetZhuanzhiEquip(self.equip_index) or {}
	local role_equip = equip_data.item_id or 0
	local need_num = role_equip == self.compose_data.equip1_id and 1 or 2
	local bag_equip = ItemData.Instance:GetItems(self.compose_data.equip1_id, need_num)
	if #bag_equip < need_num then
			SysMsgCtrl.Instance:ErrorRemind(Language.Forge.NoEnoughMaterial)
		return
	end
	if need_num == 1 then
		ForgeCtrl.Instance:SendCSZhuanzhiEquipOpe(ZHUANZHI_EQUIP_OPERATE_TYPE.ZHUANZHI_EQUIP_OPERATE_TYPE_ZHIZUN_COMPOSE, self.compose_data.compose_equip_id, 
			self.compose_data.compose_equip_best_attr_num, self.equip_index, bag_equip[1].index)
	else
		ForgeCtrl.Instance:SendCSZhuanzhiEquipOpe(ZHUANZHI_EQUIP_OPERATE_TYPE.ZHUANZHI_EQUIP_OPERATE_TYPE_ZHIZUN_COMPOSE, self.compose_data.compose_equip_id, 
			self.compose_data.compose_equip_best_attr_num, -1, bag_equip[1].index, bag_equip[2].index)
	end
end

function ForgeExtremeSuit:OnButtonHelp()
	local tips_id = 264
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end


-------------------
AccordionItem = AccordionItem or BaseClass(BaseCell)

function AccordionItem:__init(instance)
	self.equip_cell = ItemCell.New()
	self.equip_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.equip_cell:SetFromView(TipsFormDef.FROM_BAG_EQUIP)
	
	self.node_list["BaseEquipCell"].toggle:AddClickListener(handler or BindTool.Bind(self.OnClickItemCell, self))
end

function AccordionItem:__delete()
	if nil ~= self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil
	end
end

function AccordionItem:OnClickItemCell()
	self.click_callback(self)
end

function AccordionItem:OnFlush()
	if nil == self.data then return end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.compose_equip_id)
	self.equip_cell:SetData({item_id = self.data.compose_equip_id, is_from_extreme = self.data.compose_equip_best_attr_num}) 
	self.node_list["Name"].text.text = item_cfg.name
end
