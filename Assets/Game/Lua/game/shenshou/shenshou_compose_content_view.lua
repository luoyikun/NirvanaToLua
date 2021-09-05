ShenShouComposeView = ShenShouComposeView or BaseClass(BaseRender)
local MOVE_TIME = 0.5
function ShenShouComposeView:__init(instance)
	ShenShouComposeView.Instance = self

	self.node_list["BtnOnceUp"].button:AddClickListener(BindTool.Bind(self.OnClickAdd, self))
	self.node_list["btn_compose"].button:AddClickListener(BindTool.Bind(self.OnClickCompose, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))

	self.contain_cell_list = {}
	self.left_bar_list = {}
	for i = 1, 7 do
		self.left_bar_list[i] = {}
		self.left_bar_list[i].select_btn = self.node_list["select_btn_" .. i]
		self.left_bar_list[i].list = self.node_list["list_" .. i]
		self.left_bar_list[i].btn_text = self.node_list["TxtBtn" .. i]
		self.left_bar_list[i].red_state = self.node_list["ImgRedPoint" .. i]
		self.left_bar_list[i].btn_text_high = self.node_list["TxtBtnHigh" .. i]
		self.node_list["select_btn_" .. i].toggle:AddClickListener(BindTool.Bind(self.OnClickSelect, self, i))
	end

	self.sshecheng_target_item = ShenShouEquip.New()
	self.sshecheng_target_item:SetInstanceParent(self.node_list["target_item"])
	self.sshecheng_target_item:ListenClick(BindTool.Bind(self.CellClick, self))
	self.sshecheng_target_item:ShowHighLight(false)

	self.sshecheng_must_item = ItemCell.New()
	self.sshecheng_must_item:SetInstanceParent(self.node_list["must_item"])

	self.sshecheng_equipment_item = {}
	for i = 1, 5 do
		self.sshecheng_equipment_item[i] = ShenShouEquipStuff.New(self.node_list["item_cell_" .. i])
		self.sshecheng_equipment_item[i]:SetIndex(i)
	end

	self.list_index = 1
	self.item_list = {}
	self.item_cell_list = {}
	self.current_data = {}
	self.effect_cd = 0
	self.sshecheng_select_data = {}
	self.sshecheng_select_index = 0
	self.is_can_compose = true
end

function ShenShouComposeView:__delete()
	self.effect_cd = nil

	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end

	if self.sshecheng_target_item then
		self.sshecheng_target_item:DeleteMe()
		self.sshecheng_target_item = nil
	end

	if self.sshecheng_must_item then
		self.sshecheng_must_item:DeleteMe()
		self.sshecheng_must_item = nil
	end	
	self.contain_cell_list = {}

	if self.sshecheng_equipment_item then
		for k,v in pairs(self.sshecheng_equipment_item) do
			v:DeleteMe()
		end
		self.sshecheng_equipment_item = nil
	end

	if self.exchange_equip_view then
		self.exchange_equip_view:DeleteMe()
		self.exchange_equip_view = nil
	end
	self.sshecheng_select_index = 0
end

function ShenShouComposeView:OpenCallBack()
	self.list_index = 1
	self:OnShenShou()
	self:Flush()
end
function ShenShouComposeView:UIsMove()
	UITween.MoveShowPanel(self.node_list["LeftContent"] , Vector3(-100 , -20 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["RightContent"] , Vector3(60 , -50 , 0 ) , MOVE_TIME )
	UITween.AlpahShowPanel(self.node_list["RightContent"] , true , MOVE_TIME , DG.Tweening.Ease.InExpo)
	UITween.ScaleShowPanel(self.node_list["RightContent"] , Vector3(0.7, 0.7, 0.7) , MOVE_TIME)
end
function ShenShouComposeView:CellClick()
	local cell = self.sshecheng_target_item
	ShenShouCtrl.Instance:SetDataAndOepnEquipTip(cell:GetData(), ShenShouEquipTip.FromView.ShenShouComposeView)
end

function ShenShouComposeView:OnFlush()
	local index_list = self:GetEquipSSHeChengSacrificeList()
	self.is_can_compose = true
	if #index_list < 3 then
		self.is_can_compose = false
	end
	if next(self.sshecheng_select_data) then
		local data = self.sshecheng_select_data
		local demand_data = ShenShouData.Instance:GetSSEquinHechengItemData(data.compose_equip_best_attr_num, data.item_id)
		if demand_data == nil then return end

		if demand_data.item_id ~= 0 then
			self.sshecheng_must_item:SetData({item_id = demand_data.item_id})
			local stuff_item_num = ItemData.Instance:GetItemNumInBagById(demand_data.item_id)
			self.sshecheng_must_item:SetItemActive(true)
			local color = stuff_item_num >= demand_data.item_num and COLOR.GREEN or COLOR.RED
			self.node_list["TxtCell"].text.text = ToColorStr(stuff_item_num, color) .. "<color=#89F201>" .. " / " .. demand_data.item_num .. "</color>"

			local item_cfg = ItemData.Instance:GetItemConfig(demand_data.item_id)
			self.node_list["TxtTitle"].text.text = ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color])

			if stuff_item_num < demand_data.item_num then
				self.is_can_compose = false
			end
		else
			self.sshecheng_must_item:SetItemActive(false)
			self.sshecheng_must_item:SetData()
		end

		self.node_list["ImgIconLock"]:SetActive(demand_data.item_id == 0)
		self.node_list["TxtCell"]:SetActive(demand_data.item_id ~= 0)
		self.node_list["ImgTitle"]:SetActive(demand_data.item_id ~= 0)
	end

	UI:SetButtonEnabled(self.node_list["btn_compose"], self.is_can_compose)

	self:FlushBtn()
	self:FlushSubNum()
	for i = 1, 7 do
		self.node_list["BtnRightActive" .. i]:SetActive(false)
	end
	if nil ~= self.list_index then 
		self.node_list["BtnRightActive" .. self.list_index]:SetActive(true)
	end
end

function ShenShouComposeView:GetNumberOfCells()
	local data_list = ComposeData.Instance:OnClickAccordionSSHechengChild(self.current_data)
	local num = math.ceil(#data_list / 3)
	return num
end

function ShenShouComposeView:RefreshCell(cell, cell_index)
	local data_list = ComposeData.Instance:OnClickAccordionSSHechengChild(self.current_data)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = ShenshouContain.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
		contain_cell:SetToggleGroup(self.node_list["equip_list"].toggle_group)
	end

	local equip_list = {}
	for i = 1 + cell_index * 3, 1 + cell_index * 3 + 2  do
		table.insert(equip_list, data_list[i])
	end
	cell_index = cell_index + 1
	contain_cell:SetDataList(equip_list)
	contain_cell:InitItems()
	contain_cell:SetIndex(cell_index)
end

function ShenShouComposeView:FlushBtn()
	local compose_data = ComposeData.Instance
	local count = compose_data:GetShenShouComposeTypeOfCount()
	for i = 1, count do
		self.left_bar_list[i].red_state:SetActive(self:GetBtnRedState(i) >= 1)
	end
end

function ShenShouComposeView:FlushSubNum()
	for k,v in pairs(self.item_cell_list) do
		v:SetNum(self:GetBtnRedState((k - 1) / 10))
	end
end

function ShenShouComposeView:GetBtnRedState(index)
	local compose_list = {{need_qualit = 4, need_start_num = 2}, {need_qualit = 4, need_start_num = 3}}
	local need_item_id, need_num = ShenShouData.Instance:GetIsNeedStuff(compose_list[index])
	local has_num = ItemData.Instance:GetItemNumInBagById(need_item_id)
	local equip_list = ShenShouData.Instance:GetShenshouComposeNum(compose_list[index])

	if need_item_id == 0 then
		return math.floor(equip_list / 3)
	else
		return math.min(math.floor(equip_list / 3), math.floor(has_num / need_num))
	end
end

function ShenShouComposeView:UpdateList(type)
	local compose_data = ComposeData.Instance

	self.left_bar_list[self.list_index].select_btn.accordion_element.isOn = false
	self.left_bar_list[self.list_index].list:SetActive(false)
	
	local name_list = compose_data:GetShenShouComposeTypeOfNameList()
	local sub_type_list = compose_data:GetSehnShouSubTypeList()
	self.item_list = {}
	self.item_cell_list = {}
	self.is_load = true

	local count = compose_data:GetShenShouComposeTypeOfCount()
	for i = 1, count do
		local sub_list = compose_data:GetComposeItemList(sub_type_list[i])
		local compose_id = compose_data:CheckBagMat(sub_list)
		self.left_bar_list[i].red_state:SetActive(compose_id > 0)
		self.left_bar_list[i].select_btn:SetActive(true)
		self.left_bar_list[i].btn_text.text.text = name_list[i]
		self.left_bar_list[i].btn_text_high.text.text = name_list[i]
		self:LoadCell(i, sub_type_list[i])
	end

	if count == 7 then
		return
	end

	for i = count + 1, 7 do
		self.left_bar_list[i].select_btn:SetActive(false)
	end
	self:Flush()
end

function ShenShouComposeView:CheckIsSelect()
	if self.left_bar_list[self.list_index].select_btn.accordion_element.isOn then --刷新
		self.left_bar_list[self.list_index].select_btn.accordion_element.isOn = false
		self.left_bar_list[self.list_index].select_btn.accordion_element.isOn = true
		return
	end
	self.left_bar_list[self.list_index].select_btn.accordion_element.isOn = true
	self:SetSelectItem()
end

function ShenShouComposeView:OnClickAdd()
	local data = self.sshecheng_select_data
	if self.sshecheng_equipment_item == nil or data == nil then return end
	local demand_data = ShenShouData.Instance:GetSSEquinHechengItemData(data.compose_equip_best_attr_num, data.item_id)
	local equip_list = ShenShouData.Instance:GetSSHechengEquipmentItemList(demand_data)
	for k,v in ipairs(self.sshecheng_equipment_item)do
		if v:GetData() == nil and #equip_list >= 1 and v:IsTouchEnabled() then
			v:SetData(table.remove(equip_list, 1))
		end
	end

	local num = #self:GetEquipSSHeChengSacrificeList()
	if num < 3 then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShenShou.ComposeStuffInsufficient)
	end
	self:Flush()
end

function ShenShouComposeView:OnClickCompose() 
	local data = self.sshecheng_select_data
	local index_list = self:GetEquipSSHeChengSacrificeList()
	local probability = #index_list == 3 and 100 or 0
	local function gotoHecheng()
		ShenShouCtrl.Instance:SendShenshouOperaReq(SHENSHOU_REQ_TYPE.SHENSHOU_REQ_TYPE_COMPOSE, data.item_id, index_list[1], index_list[2], index_list[3])
		self:FlushSSHechengEquipmentItem()
	end

	if next(index_list) ~= nil and data ~= nil and probability > 0 then
		gotoHecheng()
	end

	if self.is_can_compose then
		self:PlayUpStarEffect()
	end
	self:Flush()
end

function ShenShouComposeView:OnClickHelp()
	if 1 == self.list_index then
		TipsCtrl.Instance:ShowHelpTipView(222)
	else
		TipsCtrl.Instance:ShowHelpTipView(223)
	end 
end

function ShenShouComposeView:LoadCell(index, sub_type)
	local compose_item_list = ComposeData.Instance:GetShenShouComposeItemList(sub_type)

	local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader")
	res_async_loader:Load("uis/views/composeview_prefab", "ItemType", nil, function (prefab)
		if nil == prefab then
			return
		end
		for i = 1, #compose_item_list do
			local obj = ResMgr:Instantiate(prefab)
			local obj_transform = obj.transform
			obj_transform:SetParent(self.left_bar_list[index].list.transform, false)
			obj:GetComponent("Toggle").group = self.left_bar_list[index].list.toggle_group
			local item_cell = ShenshouComposeItem.New(obj)
			item_cell:InitCell(compose_item_list[i])
			self.item_list[#self.item_list + 1] = obj_transform
			self.item_cell_list[10 * index + i] = item_cell
		end

		self:CheckIsSelect()

		local list_delegate = self.node_list["equip_list"].list_simple_delegate
		list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
		list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
		self.node_list["equip_list"].scroller:ReloadData(0)

		self:Flush()
	end)
end

function ShenShouComposeView:SetSelectItem()
	self:OnFlushItem()
	if self.item_cell_list[10 * self.list_index + 1] then
		self.item_cell_list[10 * self.list_index + 1]:SetHighLight(true)
	end
end

function ShenShouComposeView:OnClickSelect(index)

	self.list_index = index
	self:SetSelectItem()
	for i = 1, 7 do
		self.node_list["BtnRightActive" .. i]:SetActive(false)
	end
	self.node_list["BtnRightActive" .. self.list_index]:SetActive(true)
end

function ShenShouComposeView:OnShenShou()
	self:DestoryGameObject()
	self:UpdateList()
end

function ShenShouComposeView:DestoryGameObject()
	if nil == next(self.item_list) then
		return
	end
	self.is_load = false
	for k,v in pairs(self.item_list) do
		ResMgr:Destroy(v.gameObject)
	end
	self.item_list = {}
	self.item_cell_list = {}
end


function ShenShouComposeView:OnFlushItem()
	if self.item_cell_list ~= nil then
		for k,v in pairs(self.item_cell_list) do
			v:SetHighLight(false)
		end
	end
end

function ShenShouComposeView:SetCurrentData(data)
	self.current_data = data
	self:SetShowSelectquip(true)
	self:SetShowExchangEquip(false)
	if self.node_list["equip_list"] then
		self.node_list["equip_list"].scroller:RefreshActiveCellViews()
	end
end

function ShenShouComposeView:SetShowExchangEquip(value)
	self.node_list["exchange_equip"]:SetActive(value)
end

function ShenShouComposeView:SetShowSelectquip(value)
	self.node_list["PanelSelectEquip"]:SetActive(value)
end

function ShenShouComposeView:PlayUpStarEffect()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		local bundle_name, asset_name = ResPath.GetUiEffect("UI_shengjichenggong")
		EffectManager.Instance:PlayAtTransformCenter(
			bundle_name,
			asset_name,
			self.node_list["effect_root"].transform,
			2.0)
		self.effect_cd = Status.NowTime + 1
	end
end

function ShenShouComposeView:GetSShechengSelectData()
	return self.sshecheng_select_data
end

function ShenShouComposeView:SetSShechengSelecIndex(index)
	self.sshecheng_select_index = index
end

function ShenShouComposeView:SetSShechengSelecIndexData(data)
	self.sshecheng_equipment_item[self.sshecheng_select_index]:SetData(data)
	local index_list = self:GetEquipSSHeChengSacrificeList()
	local probability = #index_list == 3 and 100 or 0
	UI:SetButtonEnabled(self.node_list["btn_compose"], 3 == #index_list)

	self:Flush()
end

function ShenShouComposeView:SelectCommonSSEquipment(data)
	self.sshecheng_select_data = data
	self:SetShowSelectquip(false)
	self:SetShowExchangEquip(true)

	local demand_data = ShenShouData.Instance:GetSSEquinHechengItemData(data.compose_equip_best_attr_num, data.item_id)
	if demand_data == nil then return end
	local param_t = {}
	param_t.star_level = data.compose_equip_best_attr_num
	self.sshecheng_target_item:SetData({item_id = data.item_id, strength_level = 0, param = param_t})
	self.sshecheng_target_item:Flush()
	if demand_data.item_id ~= 0 then
		self.sshecheng_must_item:SetData({item_id = demand_data.item_id})
		local stuff_item_num = ItemData.Instance:GetItemNumInBagById(demand_data.item_id)
		self.sshecheng_must_item:SetItemActive(true)
		local color = stuff_item_num >= demand_data.item_num and COLOR.GREEN or COLOR.RED
		self.node_list["TxtCell"].text.text = ToColorStr(stuff_item_num, color) .." <color=#89F201>" .. "/" .. demand_data.item_num .. "</color>"
	else
		self.sshecheng_must_item:SetItemActive(false)
	end

	self.node_list["ImgIconLock"]:SetActive(demand_data.item_id == 0)
	self.node_list["TxtCell"]:SetActive(demand_data.item_id ~= 0)
	self.node_list["ImgTitle"]:SetActive(demand_data.item_id ~= 0)

	self:Flush()
	self:FlushSSHechengEquipmentItem()
end

function ShenShouComposeView:FlushSSHechengEquipmentItem()
	if self.sshecheng_select_data ~= nil then
		for i,v in ipairs(self.sshecheng_equipment_item) do
			v:SetData()
		end
	end
end

function ShenShouComposeView:GetEquipSSHeChengSacrificeList()
	if self.sshecheng_equipment_item == nil then return {} end
	local index_list = {}
	for k,v in ipairs(self.sshecheng_equipment_item)do
		if v:GetData() ~= nil then
			index_list[#index_list + 1] = v:GetData().index
		end
	end
	return index_list
end

------------------------------------------------
ShenshouComposeItem = ShenshouComposeItem or BaseClass(BaseCell)
function ShenshouComposeItem:__init(instance)
	self.data = 0
	self.can_buy_num = 0
	self.name = ""
	self.root_node.toggle:AddValueChangedListener(BindTool.Bind(self.OnItemClick, self))
end

function ShenshouComposeItem:__delete()
	self.can_buy_num = nil
	self.name = nil
	self.data = nil
end

function ShenshouComposeItem:InitCell(data)
	self.data = data
	self.name = CommonDataManager.GetDaXie(data.compose_equip_best_attr_num) .. Language.Compose.HeChengItemFatherName[data.type]

	self.node_list["Name"].text.text = string.format("%s <color=#1eff00>%s</color>", self.name, self.can_buy_num)
	self.node_list["NameHL"].text.text = string.format("%s <color=#1eff00>%s</color>", self.name, self.can_buy_num)
end

function ShenshouComposeItem:OnFlush()

end

function ShenshouComposeItem:SetNum(num)
	self.can_buy_num = num <= 0 and "" or num

	self.node_list["Name"].text.text = string.format("%s <color=#1eff00>%s</color>", self.name, self.can_buy_num)
	self.node_list["NameHL"].text.text = string.format("%s <color=#1eff00>%s</color>", self.name, self.can_buy_num)
end

function ShenshouComposeItem:SetHighLight(value)
	if value then
		self:OnItemClick(true)
		self.root_node.toggle.isOn = true
	else
		self.root_node.toggle.isOn = false
	end
end

function ShenshouComposeItem:SetItemActive(is_active)
	self.root_node:SetActive(is_active)
end

function ShenshouComposeItem:OnItemClick(is_click)
	if is_click then
		local equip_ss_hecheng_list = ComposeData.Instance:OnClickAccordionSSHechengChild(self.data)
		ShenShouComposeView.Instance:SetCurrentData(self.data)
	end
end

function ShenshouComposeItem:GetItemId()
	return self.type
end

---------listview render
ShenshouContain = ShenshouContain  or BaseClass(BaseCell)

function ShenshouContain:__init()
	self.data_list = {}
	self.exchange_contain_list = {}
	for i = 1, 3 do
		self.exchange_contain_list[i] = {}
		self.exchange_contain_list[i] = ShenShouRenderItem.New(self.node_list["item_" .. i])
		self.exchange_contain_list[i]:SetIndex(i)
		self.node_list["item_" .. i].toggle:AddClickListener(BindTool.Bind(self.OnClick, self, i))
	end
end

function ShenshouContain:OnClick(i)
	ShenShouComposeView.Instance:SelectCommonSSEquipment(self.data_list[i])
end

function ShenshouContain:__delete()
	self.data_list = {}
	for i = 1, 3 do
		self.exchange_contain_list[i]:DeleteMe()
		self.exchange_contain_list[i] = nil
	end
end

function ShenshouContain:SetDataList(data_list)
	self.data_list = data_list
end

function ShenshouContain:InitItems()
	for i = 1, 3 do
		self.exchange_contain_list[i]:SetData(self.data_list[i])
		self.exchange_contain_list[i]:OnFlush()
	end
end

function ShenshouContain:SetToggleGroup(toggle_group)
	for i = 1, 3 do
		self.exchange_contain_list[i]:SetToggleGroup(toggle_group)
	end
end


ShenShouRenderItem = ShenShouRenderItem or BaseClass(BaseCell)

function ShenShouRenderItem:__init()
	self.item_cell = ShenShouEquip.New()
	self.item_cell:SetInstanceParent(self.node_list["item"])
	self.item_cell:ListenClick(BindTool.Bind(self.OnClick, self))
end

function ShenShouRenderItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ShenShouRenderItem:OnClick()
	ShenShouComposeView.Instance:SelectCommonSSEquipment(self.data)
end

function ShenShouRenderItem:OnFlush()
	if not self.data then
		self.root_node:SetActive(false)
		return
	end

	local shenshou_equip_cfg = ShenShouData.Instance:GetShenShouEqCfg(self.data.item_id)
	if nil == shenshou_equip_cfg then return end

	self.item_cell:SetData(self.data)
	self.item_cell:Flush()
	self.node_list["TxtItem"].text.text = ToColorStr(shenshou_equip_cfg.name, ITEM_COLOR[shenshou_equip_cfg.quality + 1])
	self.item_cell:SetHighLight(false)
end

function ShenShouRenderItem:SelectToggle()
	self.root_node.toggle.isOn = true
end

function ShenShouRenderItem:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
	self.root_node.toggle.isOn = false
end

ShenShouEquipStuff = ShenShouEquipStuff or BaseClass(BaseCell)

function ShenShouEquipStuff:__init()
	self.node_list["RootNode"].button:AddClickListener(BindTool.Bind(self.OpenBag, self))
	self.node_list["ImgBtnPlus"].button:AddClickListener(BindTool.Bind(self.OpenBag, self))

	self.item_cell = ShenShouEquip.New()
	self.item_cell:SetInstanceParent(self.node_list["item"])
	self.item_cell:ListenClick(BindTool.Bind(self.OpenBag, self))
end

function ShenShouEquipStuff:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ShenShouEquipStuff:OnFlush()
	if self.data then
		self.item_cell:SetActive(true)
		self.item_cell:SetData(self.data)
		self.item_cell:Flush()
	else
		self.item_cell:SetActive(false)
	end
	self.item_cell:SetHighLight(false)

	self.node_list["ImgIconLock"]:SetActive(self.index > 3)
	self.node_list["ImgBtnPlus"]:SetActive(self.index <= 3)
end

function ShenShouEquipStuff:IsTouchEnabled()
	return self.index <= 3
end

function ShenShouEquipStuff:OpenBag()
	if self.index > 3 then
		return 
	end
	if self.data then
		self:SetData()
		ShenShouComposeView.Instance:Flush()
		return 
	end
	ShenShouCtrl.Instance:SSHeChengUpLevelBagOpen(ShenShouComposeView.Instance:GetSShechengSelectData())
	ShenShouComposeView.Instance:SetSShechengSelecIndex(self.index)
end