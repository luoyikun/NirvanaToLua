ForgeComposeView = ForgeComposeView or BaseClass(BaseRender)

function ForgeComposeView:__init()
	self.need_flush_accord = true
	self.cur_grade = 0
	self.list_index = 1
	self.purpose_equip_id = 0
	self.leftBarList = {}
	self.item_list = {}
	self.item_cell_list = {}
	self.select_solt = -1
	self.stuff_data_list = {}
	self.selcet_bag_list = {}
	self.scroller_data = {}
	self.index_select_list = {}

	self.node_list["ComposeEffect"]:SetActive(not has_select)
	self.node_list["ComposeEffect"]:SetActive(false)

	self.effect_obj = nil
	self.is_load_effect = false

	self:InitLeftAccordion()
	self:InitRedEquipList()
	self:InitOneEquipView()
	self:InitScollList()
end

function ForgeComposeView:InitLeftAccordion()
	for i = 1, 2 do
		self.leftBarList[i] = {}
	end
	for i = 1, 2 do
		self:LoadCell(i)
	end
end

function ForgeComposeView:LoadCell(index)
	local compose_item_list = ForgeData.Instance:GetTypeListByIndex(index)

	local res_async_loader = AllocResAsyncLoader(self, "type_res_async_loader")
	res_async_loader:Load("uis/views/forgeview_prefab", "ForgeItemType", nil, function (prefab)
		if nil == prefab then
			return
		end
		for i = 1, #compose_item_list do
			local obj = ResMgr:Instantiate(prefab)
			local obj_transform = obj.transform
			obj_transform:SetParent(self.node_list["list_" .. index].transform, false)
			obj:GetComponent("Toggle").group = self.node_list["list_" .. index].toggle_group
			local item_cell = ForgeComposeItem.New(obj)
			item_cell:InitCell(index, compose_item_list[i].compound_order, self)
			self.item_list[#self.item_list + 1] = obj_transform
			self.item_cell_list[#self.item_cell_list + 1] = item_cell

			if index == 1 and i == 1 then
				item_cell:OnItemClick(true)
				item_cell:SetHighLight()
			end
		end
	end)

	self.delaytime = GlobalTimerQuest:AddDelayTimer(function()
			self.node_list["select_btn_" .. self.list_index].accordion_element.isOn = true
			GlobalTimerQuest:CancelQuest(self.timer_quest)
			self.delaytime = nil
		end, 0.1)
end

function ForgeComposeView:InitOneEquipView()
	self.stuff_list = {}
	for i= 1, 5 do
		self.stuff_list[i] = StuffCell.New(self.node_list["stuff_cell_" .. i])
		self.stuff_list[i]:SetParentView(self)
		self.stuff_data_list[i] = {}
		self.stuff_list[i]:SetData(self.stuff_data_list[i])
	end

	self.stuff_cell_item = ItemCell.New()
	self.stuff_cell_item:SetInstanceParent(self.node_list["stuff_cell_item"])
	self.stuff_cell_item:ShowHighLight(false)

	self.node_list["BtnClickCompose"].button:AddClickListener(BindTool.Bind(self.OnClickCompose, self))
	self.node_list["BtnClickOneKeyAdd"].button:AddClickListener(BindTool.Bind(self.OnClickOneKeyAdd, self))
	self.node_list["BtnBlackBG"].button:AddClickListener(BindTool.Bind(self.CloseEquipBagList, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseEquipBagList, self))
	self.node_list["NewEquipImg"].event_trigger_listener:AddPointerClickListener(BindTool.Bind(self.OpenEquipDetail, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))


			

end

function ForgeComposeView:InitRedEquipList()
	self.name_list = {}
	self.red_equip_list = {}
	self.icon_list = {}
	for i = 1, 6 do
		self.node_list["red_equip_" .. i].toggle:AddClickListener(BindTool.Bind(self.OnClickRedEquip, self, i))
	end
end

function ForgeComposeView:InitScollList()
	self.node_list["EquipBagList"]:SetActive(false)

	self.node_list["BtnInlay"].button:AddClickListener(BindTool.Bind(self.OnClickAddStuff, self))
	self.cell_list = {}
	--self.node_list["Scroller"]

	self.list_view_delegate = ListViewDelegate()

	local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader")
	res_async_loader:Load("uis/views/forgeview_prefab", "BagEquipItem", nil, function (obj)
		if nil == obj then
			return
		end
		self.enhanced_cell_type = obj:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))
		self.node_list["Scroller"].scroller.Delegate = self.list_view_delegate
		self.list_view_delegate.numberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
		self.list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
		self.list_view_delegate.cellViewDel = BindTool.Bind(self.GetCellView, self)
	end)
end

function ForgeComposeView:OnClickAddStuff()
	if next(self.index_select_list) then
		for k,v in pairs(self.index_select_list) do
			for k1,v1 in pairs(self.scroller_data) do
				if v == v1.index then
					for i = 1, 5 do
						if not next(self.stuff_data_list[i]) then
							self.stuff_data_list[i] = v1
							break
						end
					end
				end
			end
		end
	end
	self:CloseEquipBagList()
	self:FlushRightView()
end

--滚动条格子数量
function ForgeComposeView:GetNumberOfCells()
	return #self.scroller_data
end

--滚动条格子大小
function ForgeComposeView:GetCellSize()
	return 110
end

--滚动条刷新
function ForgeComposeView:GetCellView(scroller, data_index, cell_index)
	local cell = scroller:GetCellView(self.enhanced_cell_type)

	data_index = data_index + 1
	local scroller_cell = self.cell_list[cell]
	if nil == scroller_cell then
		self.cell_list[cell] = ComposeScrollerCell.New(cell.gameObject)
		scroller_cell = self.cell_list[cell]
		scroller_cell.mother_view = self
	end
	self.scroller_data[data_index].data_index = data_index
	scroller_cell:SetData(self.scroller_data[data_index])
	return cell
end

function ForgeComposeView:__delete()
	self.select_solt = -1
	self.need_flush_accord = true
	for i = 1, 5 do
		self.stuff_data_list[i] = {}
	end
	for k,v in pairs(self.stuff_list) do
		v:DeleteMe()
	end
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end

	if self.stuff_cell_item then
		self.stuff_cell_item:DeleteMe()
		self.stuff_cell_item = nil
	end

	if self.effect_obj then
		ResMgr:Destroy(self.effect_obj)
		self.effect_obj = nil
	end
	self.is_load_effect = nil
end

function ForgeComposeView:OnClickRedEquip(index)
	local slot_type = ForgeData.Instance:GetSlotTypeByIndex(index)
	self.select_solt = slot_type
	self:FlushRightView()
end

function ForgeComposeView:FlushBtn()
	for i = 1, 2 do
		self.node_list["select_btn_" .. i].select_btn.accordion_element:Refresh()
	end
end

function ForgeComposeView:FlushRightView()
	if self.need_flush_accord then
		self:FlushBtn()
		self.need_flush_accord = false
	end
	if self.select_solt == -1 then
		self.node_list["EquipList"]:SetActive(true)
		self.node_list["OneEquip"]:SetActive(false)
		self:FlushEquipList()
	else
		self.node_list["EquipList"]:SetActive(false)
		self.node_list["OneEquip"]:SetActive(true)
		self:FlushOneEquipCompose()
	end
end

function ForgeComposeView:FlushOneEquipCompose()
	self.node_list["Star3"]:SetActive(self.list_index == 2)
	local p_icon_id ,p_item_id = ForgeData.Instance:GetItemIdByGrade(self.select_solt, self.cur_grade)
	 self.purpose_equip_id = p_item_id
	self.node_list["NewEquipImg"].image:LoadSprite(ResPath.GetItemIcon(p_icon_id))
	for i = 1 , 5 do
		self.stuff_list[i]:SetData(self.stuff_data_list[i])
	end
	local need_stuff_cfg = ForgeData.Instance:GetComposeNeedStuff(self.cur_grade, self.list_index)
	if need_stuff_cfg.stuff_count > 0 then
		self.stuff_cell_item:SetData({item_id = need_stuff_cfg.stuff_id})
		self.node_list["LockImg"]:SetActive(false)
		local bag_stuff_num = ItemData.Instance:GetItemNumInBagById(need_stuff_cfg.stuff_id)
		local had_item_text = ""
		if bag_stuff_num < need_stuff_cfg.stuff_count then
			had_item_text = ToColorStr(bag_stuff_num,COLOR.RED)
		else
			had_item_text = ToColorStr(bag_stuff_num,TEXT_COLOR.BLUE_2)
		end
		self.node_list["StuffNumTxt"].text.text = had_item_text .. " / " .. need_stuff_cfg.stuff_count
	else
		self.node_list["LockImg"]:SetActive(true)
		self.stuff_cell_item:SetData({})
		self.node_list["StuffNumTxt"].text.text = ""
	end
	local now_stuff_count = 0
	local is_lock = false
	for k,v in pairs(self.stuff_data_list) do
		if next(v) then
			now_stuff_count = now_stuff_count + 1
			if v.is_bind == 1 then
				is_lock = true
			end
		end
	end
	self.node_list["BindLock"]:SetActive(is_lock)
	local succ_rate = 0
	if now_stuff_count >= 3 then
		succ_rate = need_stuff_cfg["prob" .. now_stuff_count]
	end
	local show_rate = string.format(Language.Forge.SuccRate, succ_rate)
	self.node_list["SuccRateTxt"].text.text = show_rate .. " %"
end

function ForgeComposeView:FlushEquipList()
	local equip_count = ForgeData.Instance:GetNumOfSlot()
	for i = 1, equip_count do
		local slot_type = ForgeData.Instance:GetSlotTypeByIndex(i)
		self.node_list["RedEquipItemTxt" .. i].text.text = Language.Forge.EquipName[slot_type]
		local equip_id = ForgeData.Instance:GetItemIdByGrade(slot_type, self.cur_grade)
		self.node_list["RedEquipItemIcon" .. i].image:LoadSprite(ResPath.GetItemIcon(equip_id))
		self.node_list["red_equip_" .. i]:SetActive(true)
	end
	if equip_count == 6 then return end
	for i = equip_count + 1, 6 do
		self.node_list["red_equip_" .. i]:SetActive(false)
	end
end

function ForgeComposeView:AfterComposeResult()
	local is_suc = ForgeData.Instance:GetIsComposeSucc()

	for i = 1, 5 do
		self.stuff_data_list[i]  = {}
	end
	self.node_list["ComposeEffect"]:SetActive(true)

	if is_suc then
		local bundle_name, asset_name = ResPath.GetMiscEffect("UI_ChengGongTongYong")
		TipsCtrl.Instance:OpenEffectView(bundle_name, asset_name, 1.5)
	end

	self:FlushRightView()
end


function ForgeComposeView:OnClickCompose()
	local need_stuff_cfg = ForgeData.Instance:GetComposeNeedStuff(self.cur_grade, self.list_index)
	local req_equip_list = {}
	for k,v in pairs(self.stuff_data_list) do
		if next(v) then
			table.insert(req_equip_list, v.index)
		end
	end
	if #req_equip_list < 3 or not next(req_equip_list)then
		SysMsgCtrl.Instance:ErrorRemind(Language.Forge.MinStuff)
		return
	end
end

function ForgeComposeView:OnClickOneKeyAdd()
	self.scroller_data = ForgeData.Instance:GetBagComposeStuff(self.cur_grade, self.list_index)
	if next(self.scroller_data) then
		for i=#self.scroller_data,1,-1 do
			for k,v in pairs(self.stuff_data_list) do
				if self.scroller_data[i] and next(v) and self.scroller_data[i].index == v.index then
					table.remove(self.scroller_data, i)
				end
			end
		end
	end

	if next(self.scroller_data) then
		local cell_index = 1
		for k,v in pairs(self.stuff_data_list) do
			if not next(v) and nil ~= self.scroller_data[cell_index] then
				self.stuff_data_list[k] = self.scroller_data[cell_index]
				cell_index = cell_index + 1
			end
		end
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Forge.NoStuff)
	end
	self:FlushRightView()
end

function ForgeComposeView:CloseEquipBagList()
	self.node_list["EquipBagList"]:SetActive(false)
	self.index_select_list = {}
end

function ForgeComposeView:OpenEquipDetail()
	TipsCtrl.Instance:OpenItem({item_id = self.purpose_equip_id, show_star_num = self.list_index + 1, speacal_from = true})
end

function ForgeComposeView:OnClickHelp()
	local tips_id = 158
	if self.list_index == 2 then
		tips_id = 159
	end
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ForgeComposeView:ClearPurposeEquip()
	self.select_solt = -1
	for i = 1, 5 do
		self.stuff_data_list[i] = {}
	end
end

function ForgeComposeView:SetCurStarAndGrade(star, grade)
	self.cur_grade = grade
	self.list_index = star
end

function ForgeComposeView:GetCurStar()
	return self.list_index
end

function ForgeComposeView:GetCurGrade()
	return self.cur_grade
end

function ForgeComposeView:ClickTakeOffEquip(bag_index)
	for k,v in pairs(self.stuff_data_list) do
		if v.index == bag_index then
			self.stuff_data_list[k] = {}
		end
	end
	self:FlushRightView()
end

function ForgeComposeView:OpenBagEquipList()
	self.scroller_data = ForgeData.Instance:GetBagComposeStuff(self.cur_grade, self.list_index)
	if next(self.scroller_data) then
		for i=#self.scroller_data,1,-1 do
			for k,v in pairs(self.stuff_data_list) do
				if self.scroller_data[i] and next(v) and self.scroller_data[i].index == v.index then
					table.remove(self.scroller_data, i)
				end
			end
		end
	end
	if next(self.scroller_data) then
		self.node_list["EquipBagList"]:SetActive(true)
		self.node_list["Scroller"].scroller:ReloadData(0)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Forge.NoStuff)

	end
end

function ForgeComposeView:SetSelcetEquipStuff(state, list_cell_index)
	if state then
		self.index_select_list[#self.index_select_list + 1] = list_cell_index
	else
		for k,v in pairs(self.index_select_list) do
			if v == list_cell_index then
				table.remove(self.index_select_list, k)
			end
		end
	end
end

function ForgeComposeView:GetSelectList()
	return self.index_select_list
end

function ForgeComposeView:GetStuffDataLength()
	local length = 0
	for k,v in pairs(self.stuff_data_list) do
		if next(v)  then
			length = length + 1
		end
	end
	return length
end
---------------------------------------------------------------------------------
--- ForgeComposeItem
---------------------------------------------------------------------------------

ForgeComposeItem = ForgeComposeItem or BaseClass(BaseCell)
function ForgeComposeItem:__init(instance)
	self.star = 0
	self.grade = 0
	self.mother_view = nil
	self.root_node.toggle:AddValueChangedListener(BindTool.Bind(self.OnItemClick, self))
end

function ForgeComposeItem:__delete()
	self.mother_view = nil
end

function ForgeComposeItem:InitCell(star, grade, mother_view)
	self.mother_view = mother_view
	self.star = star
	self.grade = grade
	local des = string.format(Language.Forge.GradeEquip, CommonDataManager.GetDaXie(grade))
	self:SetHighLight()
end

function ForgeComposeItem:OnFlush()
end

function ForgeComposeItem:SetHighLight()
	if self.mother_view ~= nil then
		if self.mother_view:GetCurStar() == self.star and self.grade == self.mother_view:GetCurGrade() then
			self.root_node.toggle.isOn = true
		else
			self.root_node.toggle.isOn = false
		end
	end
end

function ForgeComposeItem:OnItemClick(is_click)
	if is_click and self.mother_view then
		self.mother_view:SetCurStarAndGrade(self.star, self.grade)
		self.mother_view:ClearPurposeEquip()
		ForgeCtrl.Instance:FlushView()
	end
end

---------------------------------------------------------------------------------
--- StuffCell
---------------------------------------------------------------------------------
StuffCell = StuffCell or BaseClass(BaseCell)
function StuffCell:__init()
	self.mother_view = nil
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.item_cell:ShowHighLight(false)
	self.item_cell:ListenClick(BindTool.Bind(self.ClickTakeOffEquip, self))

	--可镶嵌加号按钮
	self.btn_plus = self.node_list["PlusButton"]
	self.node_list["PlusButton"].button:AddClickListener(BindTool.Bind(self.PlusClick, self))
end

function StuffCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	self.mother_view = nil
end

function StuffCell:ShowEmpty()
	self.item_cell:SetData()
	self.btn_plus:SetActive(true)
end

function StuffCell:OnFlush()
	if self.data == nil or (not next(self.data)) or self.data.item_id == nil then
		self:ShowEmpty()
		return
	end
	self.btn_plus:SetActive(false)
	self.item_cell:SetData(self.data)
	self.item_cell:ListenClick(BindTool.Bind(self.ClickTakeOffEquip, self))
end

function StuffCell:PlusClick()
	if self.mother_view then
		self.mother_view:OpenBagEquipList()
	end
end

function StuffCell:ClickTakeOffEquip()
	if nil ~= self.mother_view then
		self.mother_view:ClickTakeOffEquip(self.data.index)
	end
	self.data = nil
end

function StuffCell:SetParentView(view)
	self.mother_view = view
end

-----------------------------------------
--可用宝石滚动条格子
ComposeScrollerCell = ComposeScrollerCell or BaseClass(BaseCell)

function ComposeScrollerCell:__init()
	self.item_cell = ItemCellReward.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])

end

function ComposeScrollerCell:__delete()
	self.item_cell:DeleteMe()
end

function ComposeScrollerCell:OnFlush()
	if nil == self.data then return end

	self.item_cell:SetData(self.data)

	local select_list = self.mother_view:GetSelectList()
	self.root_node.toggle.isOn = false
	if not next(select_list) then return end
	for k,v in pairs(select_list) do
		if self.data.index == v then
			self.root_node.toggle.isOn = false
			self.root_node.toggle.isOn = true
		end
	end
end

function ComposeScrollerCell:OnClick(state)
	if self.mother_view then
		if state then
			local select_list = self.mother_view:GetSelectList()
			local has_select_length = self.mother_view:GetStuffDataLength()
			if (#select_list + has_select_length) >= 5 then
				SysMsgCtrl.Instance:ErrorRemind(Language.Forge.MaxStuff)
				self:Flush()
				return
			end
		end
		self.mother_view:SetSelcetEquipStuff(state, self.data.index)
	end
end