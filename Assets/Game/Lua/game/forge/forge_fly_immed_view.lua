
ForgeFlyImmed = ForgeFlyImmed or BaseClass(BaseRender)

ForgeFlyImmed.STATE = 
{
	ORANGE = 1,
	RED = 2,
}
function ForgeFlyImmed:__init()
	self.select_index = 0
	self.choose = 1
    self.cells_num = {}
    self.cell_list = {} 
    self.equip_cell_list = {} 
    self.equip_text_list = {}
    self.red_now_equip_txt_list = {}
    self.red_next_equip_txt_list = {}
    self.now_feixian_cell = 0
    self.feixian_role_prof = PlayerData.Instance:GetRoleBaseProf()
	self.role_prof = PlayerData.Instance:GetRoleBaseProf()
	self.node_list["BtnOrange"].button:AddClickListener(BindTool.Bind(self.OnClickOrangeBtn, self))
	self.node_list["BtnRed"].button:AddClickListener(BindTool.Bind(self.OnClickRedBtn, self))
	self.node_list["BtnClosePanel"].button:AddClickListener(BindTool.Bind(self.ClosePanel,self))
	self.node_list["BtnChoose"].button:AddClickListener(BindTool.Bind(self.OnClickChooseBtn,self))
	self.node_list["BtnTipBG"].button:AddClickListener(BindTool.Bind(self.ClosePanel,self))

	self.node_list["ToggleRed"].toggle.isOn = false
	self.node_list["ToggleOrange"].toggle.isOn = true
	self.node_list["ToggleRed"].toggle:AddValueChangedListener(BindTool.Bind(self.ChangeTab,self))
	self.node_list["ToggleOrange"].toggle:AddValueChangedListener(BindTool.Bind(self.ChangeTab,self))
	self.node_list["PanelEquipList"]:SetActive(false)

	self.panel_succ = FeixianSuccTip.New(self.node_list["PanelGetNewEquipSuccTip"])
	self.panel_succ:SetActive(false)

	self.cell_left = FeixianCell.New(self.node_list["CellLeft"])
	self.cell_right = FeixianCell.New(self.node_list["CellRight"])
	self.cell_left.parent_view =self
	self.cell_right.parent_view =self
	self.cell_left:SetIndex(1)
	self.cell_right:SetIndex(2)

	self.comsume = ItemCell.New() 
	self.comsume:SetInstanceParent(self.node_list["CellConsume"])

	self.trueEquip = ItemCell.New()
	self.trueEquip:SetInstanceParent(self.node_list["ImgTrueFeixian"])
	self.trueEquip:SetActive(false)

	self.now_red_equip = FeixianCell.New(self.node_list["CellNowRed"]) 
	self.now_red_equip.parent_view = self

	self.next_red_equip = ItemCell.New() 
	self.next_red_equip:SetInstanceParent(self.node_list["CellNextRed"])



    self.list_view_delegate = self.node_list["Scroller"].list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
    self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.GetDataOfCells, self)

    self.tips_list_delegate = self.node_list["ScrollEquipList"].list_simple_delegate
    self.tips_list_delegate.NumberOfCellsDel = BindTool.Bind(self.EquipNum, self)
    self.tips_list_delegate.CellRefreshDel = BindTool.Bind(self.EquipCell, self)

    self.list_text_delegate = self.node_list["TxtAttr"].list_simple_delegate
    self.list_text_delegate.NumberOfCellsDel =  BindTool.Bind(self.EquipInfoNum, self)
    self.list_text_delegate.CellRefreshDel = BindTool.Bind(self.EquipInfoCell, self)

    self.red_now_text_list = self.node_list["TxtNowAttrZone"].list_simple_delegate
    self.red_now_text_list.NumberOfCellsDel = BindTool.Bind(self.RedNowTxtNum,self)
    self.red_now_text_list.CellRefreshDel = BindTool.Bind(self.RedNowTxtInfo,self)

    self.red_next_text_list = self.node_list["TxtNextAttrZone"].list_simple_delegate
    self.red_next_text_list.NumberOfCellsDel = BindTool.Bind(self.RedNextTxtNum,self)
    self.red_next_text_list.CellRefreshDel = BindTool.Bind(self.RedNextTxtInfo,self)
    self:SetFeixianNeed()
    --self:CheckRedPoints()
    if self.item_data_event == nil then
    	self:SetNotifyDataChangeCallBack()
	end
	self.red_point_list = {
		[RemindName.ForgeFeixianEquipRed] = self.node_list["TrueRedPoint"],
		[RemindName.ForgeFeixianEquipOrange] = self.node_list["OrangeRedPoint"],
	}
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
end

function ForgeFlyImmed:__delete()
	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end
	if nil ~= self.panel_succ then 
		self.panel_succ:DeleteMe()
	end
	self.panel_succ = nil
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	if self.now_red_equip then 
		self.now_red_equip:DeleteMe()
	end
	self.now_red_equip = nil
	if self.comsume then 
		self.comsume:DeleteMe()
	end
	self.comsume = nil
	if self.trueEquip then 
		self.trueEquip:DeleteMe()
	end
	self.trueEquip = nil
	if self.next_red_equip then 
		self.next_red_equip:DeleteMe()
	end
	self.next_red_equip = nil
	self.cells_num = {}
	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {} 
	for _,v in pairs(self.equip_cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.equip_cell_list = {} 

	for _,v in pairs(self.equip_text_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.equip_text_list = {} 
	for _,v in pairs(self.red_now_equip_txt_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.red_next_equip_txt_list = {}
	
	for _,v in pairs(self.red_next_equip_txt_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.red_next_equip_txt_list = {}
	if nil ~= self.cell_right then 
		self.cell_right:DeleteMe()
	end
	self.cell_right = nil
	if nil ~= self.cell_left then 
		self.cell_left:DeleteMe()
	end
	self.cell_left = nil
	self.red_point_list = nil
	self.equip_text = {}
	self.tip_equip_list = {}
	self.red_tip_equip_list = {}
	self.now_feixian_cell = 0

	
end
function ForgeFlyImmed:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetActive(num > 0)
	end
end
function ForgeFlyImmed:SetNotifyDataChangeCallBack()
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function ForgeFlyImmed:RemoveNotifyDataChangeCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end
function ForgeFlyImmed:ItemDataChangeCallback()
	if self:IsOpen() then
		self:SetFeixianNeed() 
		self:CleanState()
		self:Flush()
	end
end

function ForgeFlyImmed:SetFeixianNeed()
	if self.node_list["ToggleOrange"].toggle.isOn == true then 
		return ForgeData.Instance:SetFeixianNeed(0)
	elseif self.node_list["ToggleRed"].toggle.isOn == true then 
		return ForgeData.Instance:SetFeixianNeed(1)    
	end
end

function  ForgeFlyImmed:FritsFlushView()
	self:CheckSelect()
	self:Flush()
end

function ForgeFlyImmed:OnClickRedBtn()
	if self.now_red_equip.cell.data.item_id == nil then 
		return
	end
	local type_index = XIANYUAN_EQUIP_OPERATE_TYPE.FEIXIAN_EQUIP_OPERATE_TYPE_LEVELUP
	local num = 0
	local cells_one = {}
	if self.now_red_equip.choose_state == true then 
		if self.now_red_equip.cell.data.item_fei_immed_type == 1 then
			cells_one = self.now_red_equip.cell.data
			num = 1
		elseif self.now_red_equip.cell.data.item_fei_immed_type == 0 then
			cells_one = self.now_red_equip.cell.data
			num = 0
		end
		if nil ~= cells_one.item_id and nil ~= cells_one.index then 
			ForgeCtrl.Instance:SendFeixianEquipReq(type_index,cells_one.index,num)
			
		end
	end
	self:CleanState()
	self:CheckSelect()
	self:Flush()
end

function ForgeFlyImmed:FlushRedEquipUpLevel()
	local xianpin_type = ForgeData.Instance:GetFeiXianXianPinType()
	local have_comsume_num = 0
	local need_comsume_id = 0
	local local_item_id = self.now_red_equip.cell.data.item_id
	local fei_xian_cfg = ForgeData.Instance:GetFeixianRedEquipConsume()
	local equipment_auto_cfg = ForgeData.Instance:GetEquipmentCfg()
	if nil == fei_xian_cfg or nil == next(fei_xian_cfg) or nil == equipment_auto_cfg or nil == next(equipment_auto_cfg) then 
		return 
	end
	if nil == local_item_id or local_item_id == 0 then 
		self.comsume:SetActive(false)
		self.comsume:SetData()
		self.next_red_equip:SetActive(false)
		self.next_red_equip:SetData()
		self.node_list["TxtComsume"].text.text = string.format(Language.Forge.RedEquipComsumeGreen,0,0)
		self.node_list["TextNextName"].text.text = ""
		self.node_list["TxtTianShenAttr"].text.text = ""
	else
		if nil ~= fei_xian_cfg.levelupList then 
			if nil ~= fei_xian_cfg.levelupList[local_item_id] then
				if nil ~= fei_xian_cfg.levelupList[local_item_id].stuff_id_1 then 
					local comsume_data = {}
					comsume_data.item_id = fei_xian_cfg.levelupList[local_item_id].stuff_id_1
					self.comsume:SetActive(true)
					self.comsume:SetData(comsume_data)
					need_comsume_id = comsume_data.item_id
				end
				if nil ~= fei_xian_cfg.levelupList[local_item_id].dirid then 
					local next_dirid = {}
					next_dirid.item_id = fei_xian_cfg.levelupList[local_item_id].dirid
					next_dirid.param = {}
					next_dirid.param.really = 0
					self.next_red_equip:SetActive(true)
					self.next_red_equip:SetData(next_dirid)
					self.node_list["TextNextName"].text.text = equipment_auto_cfg[next_dirid.item_id].name
					self.node_list["TxtTianShenAttr"].text.text = xianpin_type[equipment_auto_cfg[next_dirid.item_id].god_attr].desc
				end
				if need_comsume_id ~= 0 then 
					have_comsume_num = ForgeData.Instance:GetFeixianRedComsumeCount(need_comsume_id)
				end
				if nil ~= fei_xian_cfg.levelupList[local_item_id].stuff_count_1  then
					local need = fei_xian_cfg.levelupList[local_item_id].stuff_count_1
					if have_comsume_num >= need then 
						self.node_list["TxtComsume"].text.text = string.format(Language.Forge.RedEquipComsumeGreen,have_comsume_num,need)
					else
						self.node_list["TxtComsume"].text.text = string.format(Language.Forge.RedEquipComsumeRed,have_comsume_num,need)
					end
				end
			end	
		end
	end
end

function ForgeFlyImmed:OnClickOrangeBtn()	
	local type_index = XIANYUAN_EQUIP_OPERATE_TYPE.FEIXIAN_EQUIP_OPERATE_TYPE_COMPOSE
	local num = 0
	local cells_one = {}
	local cells_two = {}
	if self.cell_left.choose_state == true and self.cell_right.choose_state == true then 
		if self.cell_left.cell.data.item_id ~= nil and self.cell_left.cell.data.item_fei_immed_type == 1 then
			cells_one = self.cell_left.cell.data
			cells_two = self.cell_right.cell.data
			num = 1
		elseif self.cell_right.cell.data.item_id ~= nil and self.cell_right.cell.data.item_fei_immed_type == 1 then
			cells_one = self.cell_right.cell.data
			cells_two = self.cell_left.cell.data
			num = 1
		end
		if nil ~= cells_one.item_id then 
			ForgeCtrl.Instance:SendFeixianEquipReq(type_index,cells_one.index,cells_two.index,num)
		else
			ForgeCtrl.Instance:SendFeixianEquipReq(type_index,self.cell_left.cell.data.index,self.cell_right.cell.data.index,num)
		end
	end
	self:CleanState()
	self:CheckSelect()
	self:Flush()
end
---------------------------- 装备格子的数据设置----------------------------

function ForgeFlyImmed:GetNumberOfCells()
	if self.node_list["ToggleOrange"].toggle.isOn == true then 
		return ForgeData.Instance:GetFeixianEquipCount(0)
	elseif self.node_list["ToggleRed"].toggle.isOn == true then 
		return ForgeData.Instance:GetFeixianEquipCount(1)    
	end
end

function ForgeFlyImmed:GetDataOfCells(cell,data_index)
	--data_index = data_index + 1
	local equip_cell = self.cell_list[cell]
	if equip_cell == nil then
		equip_cell = FeixianEquipCell.New(cell.gameObject)
		equip_cell.parent_view = self
		self.cell_list[cell] = equip_cell
	end
	equip_cell:SetIndex(data_index)
	local imgcfg, data = ForgeData.Instance:GetFeixianEquipList(self.feixian_role_prof)
	
	local item_data = {}
	local id = ForgeData.FORGE_FLY_ID[data[data_index].really_sort]
	if imgcfg then
		for k,v in pairs(imgcfg) do
			if k == ForgeData.FORGE_FLY_IMMED_EQUIP[id] then 
				item_data = v
			end
		end
	end
	equip_cell:SetData(item_data)
	if self.node_list["ToggleOrange"].toggle.isOn == true then
		if data[data_index].ison == true then 
			equip_cell.node_list["TxtStateText"].text.text = Language.Forge.FeixianOrgEquip
		else
			equip_cell.node_list["TxtStateText"].text.text = Language.Forge.FeixianNilEquip
		end
		equip_cell.node_list["TxtEquipName"].text.text = Language.Forge.FeixianEquip[data[data_index].really_sort]
		equip_cell.node_list["TxtEquipName"].text.text = Language.Forge.FeixianEquip[data[data_index].really_sort]
	elseif self.node_list["ToggleRed"].toggle.isOn == true then 
		if data[data_index].red_ison == true then 
			equip_cell.node_list["TxtStateText"].text.text = Language.Forge.FeixianRedEquip
		else
			equip_cell.node_list["TxtStateText"].text.text = Language.Forge.FeixianNilEquip
		end
		equip_cell.node_list["TxtEquipName"].text.text = Language.Forge.FeixianEquip[data[data_index].really_sort]
		equip_cell.node_list["TxtEquipName"].text.text = Language.Forge.FeixianEquip[data[data_index].really_sort]
	end
end

function ForgeFlyImmed:RedNextTxtNum()
	if false == self.now_red_equip.choose_state then
		return 0
	end
	local num = 0
	if nil == self.now_red_equip.cell.data or nil == self.now_red_equip.cell.data.item_id then 
		return 0
	end
	local item = self.now_red_equip.cell.data
	local item_next_id = 0
	local feixian_next_info = ForgeData.Instance:GetFeixianRedEquipConsume()
	if nil ~= feixian_next_info.levelupList then 
		if nil ~= feixian_next_info.levelupList[item.item_id] then 
			item_next_id = feixian_next_info.levelupList[item.item_id].dirid
		end
	else
		if nil ~= feixian_next_info.levelupList_default_table then 
			item_next_id = feixian_next_info.levelupList_default_table.dirid
		end
	end
	if item_next_id == 0 then 
		return 0
	end
	local equip_info = ForgeData.Instance:GetEquipmentCfg()
	local equip_table = {}
	self.red_next_equip_info = {}
	equip_table = equip_info[item_next_id]
	if nil == equip_table then 
		return 0
	end
	num,self.red_next_equip_info = self:SetattributeTool(equip_table,0)
	return num

end

function ForgeFlyImmed:RedNextTxtInfo(cell,data_index)
	if self.now_red_equip.cell.data == nil and nil == self.now_red_equip.cell.data.item_id then 
		return 0
	end
	data_index = data_index + 1
	local equip_text = self.red_next_equip_txt_list[cell]
	if nil == equip_text then 
		equip_text = FeixianTextList.New(cell.gameObject)
		equip_text.parent_view =self
		self.red_next_equip_txt_list[cell] = equip_text
	end
	equip_text.node_list["TextSelf"].text.text = self.red_next_equip_info[data_index]
end

function ForgeFlyImmed:RedNowTxtNum()
	if false == self.now_red_equip.choose_state then
		return 0
	end
	if nil == self.now_red_equip.cell.data or nil == self.now_red_equip.cell.data.item_id then
		return 0
	end

	local num = 0
	local item = self.now_red_equip.cell.data
	local equip_info = ForgeData.Instance:GetEquipmentCfg()
	local fei_xian_cfg = ForgeData.Instance:GetFeixianRedEquipConsume()
	local equip_need_id = item.item_id
	local equip_table = {}
	self.red_now_equip_info = {}
	equip_table = equip_info[item.item_id]
	if nil == equip_table then 
		return 0
	end
	local equip_attribute = ForgeData.Instance:GetFeixianRedEquipConsume()
	local equip_add_attr = 0
	if nil ~= equip_attribute and nil ~= next(equip_attribute)then 
		if nil ~= equip_attribute.composeList_default_table then
			if nil ~= equip_attribute.composeList_default_table.shuxing then 
				equip_add_attr = equip_attribute.composeList_default_table.shuxing * 0.0001
			end
		end
		if nil ~= equip_attribute.composeList then
			if nil ~= equip_attribute.composeList[equip_need_id] then 
				if nil ~= equip_attribute.composeList[equip_need_id].shuxing then 
					equip_add_attr = equip_attribute.composeList[equip_need_id].shuxing * 0.0001
				end
			end
		end
	end
	num,self.red_now_equip_info = self:SetattributeTool(equip_table,equip_add_attr)
	return num

end 

function ForgeFlyImmed:SetattributeTool(equip_table,Proportion)
	local num = 0
	local local_table = {}
	if nil == equip_table or nil == next(equip_table) then 
		return 0
	end
	if equip_table.hp ~= nil and equip_table.hp ~= 0 then 
		num = num +1 
		local text = equip_table.hp + math.ceil(Proportion * equip_table.hp)
		table.insert(local_table,string.format(Language.Forge.FeixianEquipText["hp"],text))
	end
	if equip_table.attack ~= nil and equip_table.attack ~= 0 then 
		num = num +1 
		local text = equip_table.attack +  math.ceil(Proportion * equip_table.attack)
		table.insert(local_table,string.format(Language.Forge.FeixianEquipText["gongji"],text))
	end
	if equip_table.fangyu ~= nil and equip_table.fangyu ~= 0 then 
		num = num +1 
		local text = equip_table.fangyu +  math.ceil(Proportion * equip_table.fangyu)
		table.insert(local_table,string.format(Language.Forge.FeixianEquipText["fangyu"],text))
	end
	if equip_table.mingzhong ~= nil and equip_table.mingzhong ~= 0 then 
		num = num +1 
		local text = equip_table.mingzhong +  math.ceil(Proportion * equip_table.mingzhong)
		table.insert(local_table,string.format(Language.Forge.FeixianEquipText["mingzhong"],text))
	end
	if equip_table.shanbi ~= nil and equip_table.shanbi ~= 0 then 
		num = num +1 
		local text = equip_table.shanbi +  math.ceil(Proportion * equip_table.shanbi)
		table.insert(local_table,string.format(Language.Forge.FeixianEquipText["shanbi"],text))
	end
	if equip_table.baoji ~= nil and equip_table.baoji ~= 0 then 
		num = num +1 
		local text = equip_table.baoji +  math.ceil(Proportion * equip_table.baoji)
		table.insert(local_table,string.format(Language.Forge.FeixianEquipText["baoji"],text))
	end
	if equip_table.jianren ~= nil and equip_table.jianren ~= 0 then 
		num = num +1 
		local text = equip_table.jianren + math.ceil(Proportion * equip_table.jianren)
		table.insert(local_table,string.format(Language.Forge.FeixianEquipText["jianren"],text))
	end
	return num ,local_table
end

function ForgeFlyImmed:RedNowTxtInfo(cell,data_index)
	if self.now_red_equip.cell.data == nil and nil == self.now_red_equip.cell.data.item_id then 
		return 0
	end
	data_index = data_index + 1
	local equip_text = self.red_now_equip_txt_list[cell]
	if nil == equip_text then 
		equip_text = FeixianTextList.New(cell.gameObject)
		equip_text.parent_view =self
		self.red_now_equip_txt_list[cell] = equip_text
	end
	equip_text.node_list["TextSelf"].text.text = self.red_now_equip_info[data_index]
end
--------------------------Function--------------------------------------------

function ForgeFlyImmed:ShowSucc(protocol,name)
	self.panel_succ:LoadSuccData(protocol.param1,name)
	--self:CheckRedPoints()
end

function ForgeFlyImmed:ChangeTab()
	self:SetFeixianNeed()
	self:CleanState()
	self:CheckSelect()
	self:Flush()
end

function ForgeFlyImmed:ClosePanel()
	self.node_list["PanelEquipList"]:SetActive(false)
	self.choose = 0
	self.now_feixian_cell = 0
	self:FlushItemActive()
end
function ForgeFlyImmed:SetSelectIndex(select_index)
	self.select_index = select_index
end

function ForgeFlyImmed:SetChoose(index)
	self.choose = index
end

function ForgeFlyImmed:GetSelectIndex()
	return self.select_index or 1
end

function ForgeFlyImmed:GetdataIndex()
	return self.choose or 1
end

function ForgeFlyImmed:OnFlush()
	self:SetEquipNameAndImage()
	self.node_list["TxtNextAttrZone"].scroller:ReloadData(0)
	self.node_list["TxtNowAttrZone"].scroller:ReloadData(0)
	self.node_list["Scroller"].scroller:ReloadData(0)
	self.node_list["TxtAttr"].scroller:ReloadData(0)
	self.node_list["ScrollEquipList"].scroller:ReloadData(0)
	self:FlushRedEquipUpLevel()
	--self:CheckRedPoints()
	
end

function ForgeFlyImmed:FlushAllActive()
	for k,v in pairs(self.cell_list) do
		v:FlushActive()
	end
end
function ForgeFlyImmed:FlushItemActive()
	for k,v in pairs(self.equip_cell_list) do
		v:FlushItemChoose()
	end
end
function ForgeFlyImmed:CheckEquipOnItem()
	local local_table = {}
	local num = 0
	local left_id = self.cell_left.cell.data.item_id 
	local right_id = self.cell_right.cell.data.item_id 
	for k,v in pairs(self.tip_equip_list) do
		if v ~= self.cell_left.cell.data and v ~= self.cell_right.cell.data then 
			if nil ~= left_id and self.now_feixian_cell ~= self.cell_left.index and nil == right_id then 
				if v.item_id == left_id then 
					num = num + 1
					local_table[num] = v
				end
			elseif nil ~= right_id and self.now_feixian_cell ~= self.cell_right.index and nil == left_id then 
				if v.item_id == right_id then 
					num = num + 1
					local_table[num] = v
				end
			else
				num = num + 1
				local_table[num] = v
			end	
		end
	end
	return num,local_table
end

function ForgeFlyImmed:CheckEquipOnNowEquipCell()
	local local_table = {}
	local num = 0
	for k,v in pairs(self.red_tip_equip_list) do
		if v ~= self.now_red_equip.cell.data then 
			num = num + 1
			local_table[num] = v		
		end
	end
	return num,local_table
end

function ForgeFlyImmed:CheckSelect()
	local imgcfg, data = ForgeData.Instance:GetFeixianEquipList(self.feixian_role_prof)
	if self.node_list["ToggleOrange"].toggle.isOn == true then 
		if data[self.select_index].ison == false then
			self.cell_left:SetState(ForgeData.FORGE_FLY_GUILD_STATE.UNCHECKED_NOT_HAVE)
			self.cell_right:SetState(ForgeData.FORGE_FLY_GUILD_STATE.UNCHECKED_NOT_HAVE)
		else	
			if self.cell_left.choose_state == false and self.cell_right.choose_state == false then 
				self.cell_left:SetState(ForgeData.FORGE_FLY_GUILD_STATE.UNCHECKED_HAVE)
				self.cell_right:SetState(ForgeData.FORGE_FLY_GUILD_STATE.UNCHECKED_HAVE)
				local seclet_index_feixian_equip_num = 0
				self.cell_left.auto_equip = false
				local equip_list = {}
				for k,v in pairs(data[self.select_index].cell) do
					if v.num == 2 then 
						seclet_index_feixian_equip_num = seclet_index_feixian_equip_num + 1
						equip_list["left"] = v.cell[1]
						equip_list["right"] = v.cell[2]
					elseif v.num >= 2 then 
						seclet_index_feixian_equip_num = seclet_index_feixian_equip_num + 1
					end
				end
				if seclet_index_feixian_equip_num == 1 and equip_list["left"] ~= nil and equip_list["right"] ~= nil then 
					self.cell_left.auto_equip = true
					self.cell_right.auto_equip = true
					self.cell_left:CheckSeclect(equip_list["left"])
					self.cell_right:CheckSeclect(equip_list["right"])				
				end
			elseif self.cell_left.choose_state == true and self.cell_right.choose_state == true then 
				self.cell_left:SetState(ForgeData.FORGE_FLY_GUILD_STATE.CHECKED_HAVE)
				self.cell_right:SetState(ForgeData.FORGE_FLY_GUILD_STATE.CHECKED_HAVE)
			end
		end
		self.cell_left:JudgeState()
		self.cell_right:JudgeState()
	elseif self.node_list["ToggleRed"].toggle.isOn == true then 
		if data[self.select_index].red_ison == false then 
			self.now_red_equip:SetState(ForgeData.FORGE_FLY_GUILD_STATE.UNCHECKED_NOT_HAVE)
		else
			if self.now_red_equip.choose_state == false then 
				self.now_red_equip:SetState(ForgeData.FORGE_FLY_GUILD_STATE.UNCHECKED_HAVE)
				local red_equip_num = 0
				self.now_red_equip.auto_equip = false
				local red_equip_list = {} 
				for k,v in pairs(data[self.select_index].cell) do
					if v.num == 1 then 
						red_equip_num = red_equip_num + 1
						red_equip_list["now"] = v.cell[1]
					elseif v.num >= 1 then 
						red_equip_num = red_equip_num + 1
					end
				end
				if red_equip_num == 1 and nil ~= red_equip_list["now"] then 
					self.now_red_equip.auto_equip = true
					self.now_red_equip:CheckSeclect(red_equip_list["now"])			
				end
			elseif self.now_red_equip.choose_state == true then 
				self.now_red_equip:SetState(ForgeData.FORGE_FLY_GUILD_STATE.CHECKED_HAVE)
			end
		end
		self.now_red_equip:JudgeState()

	end
end

function ForgeFlyImmed:OpenPanelEquipTips(index)
	self.choose = 0
	if nil ~= index then 
		self.now_feixian_cell = index
	end
	self.node_list["ScrollEquipList"].scroller:ReloadData(0)
	self.node_list["PanelEquipList"].gameObject:SetActive(true)
	
end
-- 点击选择
function ForgeFlyImmed:OnClickChooseBtn(cell)
	if self.choose == 0 then 
		return
	end
	if self.node_list["ToggleOrange"].toggle.isOn == true then 
		local num, list = self:CheckEquipOnItem()
		if self.now_feixian_cell == self.cell_left.index then 
			self:CheckElseItemCellActive(self.cell_right)
			self.cell_left.choose_state = true
			self.cell_left:SetCellData(list[self.choose])
			self.cell_left:Flush()
		elseif self.now_feixian_cell == self.cell_right.index then 
			self:CheckElseItemCellActive(self.cell_left)
			self.cell_right.choose_state = true
			self.cell_right:SetCellData(list[self.choose])
			self.cell_right:Flush()
		end
		self:ClosePanel()
		self.now_feixian_cell = 0
	elseif self.node_list["ToggleRed"].toggle.isOn == true then 
		local num, list = self:CheckEquipOnNowEquipCell()
		self.now_red_equip.choose_state = true
		self.now_red_equip:SetCellData(list[self.choose])
		self.now_red_equip:Flush()
		self:ClosePanel()
		self.now_feixian_cell = 0
	end
	self:Flush()
end

function ForgeFlyImmed:CheckElseItemCellActive(item_cell)
	-- body
	if nil ~= self.cell_right.cell.data.item_id and nil ~= self.cell_left.cell.data.item_id then 
		item_cell.choose_state = false
		item_cell:SetCellData()
		item_cell:Flush()
	end
end

-- 装备弹框数量
function ForgeFlyImmed:EquipNum()
	local _, data = ForgeData.Instance:GetFeixianEquipList(self.feixian_role_prof)
	if self.node_list["ToggleOrange"].toggle.isOn == true then  
		self.tip_equip_list = {}
		local num = 0
		if data[self.select_index].isOn == false then 
			return 0
		else

			for k,v in pairs(data[self.select_index].cell) do
				if v.num >= 2 then 
					for i = 1,v.num do
						self.tip_equip_list[num] = v.cell[i]
						num = num + 1
					end

				end
			end
			local num, list = self:CheckEquipOnItem()
			return num
		end
		return 0
	elseif self.node_list["ToggleRed"].toggle.isOn == true then 
		self.red_tip_equip_list = {}
		local num = 0

		if data[self.select_index].red_ison == false then 
			return 0
		else

			for k,v in pairs(data[self.select_index].cell) do
				if v.num >= 1 then 
					for i = 1,v.num do
						self.red_tip_equip_list[num] = v.cell[i]
						num = num + 1
					end

				end
			end
			local num, list = self:CheckEquipOnNowEquipCell()
			return num
		end
	end
end

function ForgeFlyImmed:EquipCell(cell,data_index)
	local equipment_auto_cfg = ForgeData.Instance:GetEquipmentCfg()
	data_index = data_index + 1
	local equip_cell = self.equip_cell_list[cell]
	if equip_cell == nil then
		equip_cell = FeixianTipEquipList.New(cell.gameObject)
		equip_cell.parent_view = self
		self.equip_cell_list[cell] = equip_cell
	end
	equip_cell:SetIndex(data_index)
	if self.node_list["ToggleOrange"].toggle.isOn == true then  
		local num, list = self:CheckEquipOnItem()
		equip_cell:SetData(list[data_index])
		local id = list[data_index].item_id
		if nil ~= equipment_auto_cfg[id] then 
			equip_cell:SetFeixianName(equipment_auto_cfg[id].name)
		end
	elseif self.node_list["ToggleRed"].toggle.isOn == true then 
		local num, list = self:CheckEquipOnNowEquipCell()
		equip_cell:SetData(list[data_index])
		local id = list[data_index].item_id
		if nil ~= equipment_auto_cfg[id] then 
			equip_cell:SetFeixianName(equipment_auto_cfg[id].name)
		end
	end
end

function ForgeFlyImmed:EquipInfoNum()
	local equip_need_id = self.cell_left.cell.data.item_id
	local equip_attribute = ForgeData.Instance:GetFeixianRedEquipConsume()
	local equip_add_attr = 0
	if nil ~= equip_attribute and nil ~= next(equip_attribute)then 
		if nil ~= equip_attribute.composeList_default_table then
			if nil ~= equip_attribute.composeList_default_table.shuxing then 
				equip_add_attr = equip_attribute.composeList_default_table.shuxing * 0.0001
			end
		end
		if nil ~= equip_attribute.composeList then
			if nil ~= equip_attribute.composeList[equip_need_id] then 
				if nil ~= equip_attribute.composeList[equip_need_id].shuxing then 
					equip_add_attr = equip_attribute.composeList[equip_need_id].shuxing * 0.0001
				end
			end
		end
	end
	if self.cell_left.cell.data == nil or self.cell_right.cell.data == nil then 
		return 0
	end
	if nil == self.cell_left.cell.data.item_id or nil == self.cell_right.cell.data.item_id then 
		return 0
	end
	if self.cell_left.cell.data.item_id == 0 or  self.cell_right.cell.data.item_id == 0 then 
		return 0
	end
	local num = 0
	self.equip_text = {}
	if self.cell_left.cell.data.item_id == self.cell_right.cell.data.item_id then 
		local index = self.cell_left.cell.data.item_id	
		local equip_info =  ForgeData.Instance:GetEquipmentCfg()
		local true_name = equip_info[index].name
		local show_true_equip = {}
		-- show_true_equip = self.cell_left.cell.data
		show_true_equip = DeepCopy(self.cell_left.cell.data)
		show_true_equip.param.really = 1
		self:SetEquipNameAndImage(true_name,show_true_equip)
		num,self.equip_text = self:SetattributeTool(equip_info[index],equip_add_attr)

	end
	return num 
end

function ForgeFlyImmed:EquipInfoCell(cell,data_index)
	if self.cell_left.cell.data == nil or self.cell_right.cell.data == nil then 
		return 
	end
	data_index = data_index + 1
	local equip_text = self.equip_text_list[cell]
	if nil == equip_text then 
		equip_text = FeixianTextList.New(cell.gameObject)
		equip_text.parent_view =self
		self.equip_text_list[cell] = equip_text
	end
	equip_text.node_list["TextSelf"].text.text = self.equip_text[data_index]
end

function ForgeFlyImmed:SetEquipNameAndImage(name,data)
	if nil ~= name then 
		self.node_list["TxtName"].text.text = name ..Language.Forge.TrueFeixian
	else
		self.node_list["TxtName"].text.text = ""
	end
	if nil ~= data then 
		self.trueEquip:SetData(data)
		self.trueEquip:SetActive(true)
	else
		self.trueEquip:SetActive(false)
	end
end
function ForgeFlyImmed:CleanState()
	self:SetEquipNameAndImage()
	if nil ~= self.cell_left  and nil ~= self.cell_right then 
		self.cell_left.choose_state = false
		self.cell_right.choose_state = false
	end
	if nil ~= self.now_red_equip then 
		self.now_red_equip.choose_state = false
	end
end

FeixianTextList = FeixianTextList or BaseClass(BaseCell)

-------------------------------------装备格子-----------------------------------------
FeixianEquipCell = FeixianEquipCell or BaseClass(BaseCell)

function FeixianEquipCell:__init()

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ImgEquipItem"])
	self.item_cell:ShowHighLight(false)
	self.item_cell:ListenClick(BindTool.Bind(self.ClickItem, self))
	self.node_list["ToggleSelf"].toggle:AddValueChangedListener(BindTool.Bind(self.ClickItem, self))

end

function FeixianEquipCell:__delete()
	if nil ~= self.item_cell then 
		self.item_cell:DeleteMe()
	end
	self.item_cell = nil 
end

function FeixianEquipCell:ClickItem()
	if self.index ~= self.parent_view.select_index then 
		self.parent_view:CleanState()
	end
	self.parent_view:SetSelectIndex(self.index)
	self.parent_view:CheckSelect()
	self.parent_view:FlushAllActive()
	self.parent_view:SetEquipNameAndImage()
	self.parent_view.node_list["TxtNextAttrZone"].scroller:ReloadData(0)
	self.parent_view.node_list["TxtNowAttrZone"].scroller:ReloadData(0)
	self.parent_view.node_list["TxtAttr"].scroller:ReloadData(0)
	self.parent_view.node_list["ScrollEquipList"].scroller:ReloadData(0)
	self.parent_view:FlushRedEquipUpLevel()
	self:Flush()
end

function FeixianEquipCell:OnFlush()
	local data = {}
	data.item_id =self.data.id 
	self.item_cell:SetData(data)
	self.parent_view:CheckSelect()
	self:FlushActive()
end

function FeixianEquipCell:FlushActive()
	local select_index = self.parent_view:GetSelectIndex()
	self.node_list["ImgEquipActive"].gameObject:SetActive(select_index == self.index)
end

----------------------------装备添加格子----------------------------------------------
FeixianCell = FeixianCell or BaseClass(BaseCell)

function FeixianCell:__init()
	self.choose_state = false
	self.cell = ItemCell.New()
	self.cell:SetInstanceParent(self.node_list["CellEquip"])
	self.cell:ShowHighLight(false)
	self.cell:SetActive(false)
	self.node_list["CellEquip"].button:AddClickListener(BindTool.Bind(self.OnClickItem, self))
	self.node_list["BtnSwitch"].button:AddClickListener(BindTool.Bind(self.OnClickItem, self))
	self.node_list["BtnSwitch"]:SetActive(false)
	self.anim = self.node_list["ImgAnim"].animator
	self.equipment_auto_cfg =  ForgeData.Instance:GetEquipmentCfg()

end

function FeixianCell:__delete()
	if nil ~= self.cell then 
		self.cell:DeleteMe()
	end
	self.cell = nil 
	self.anim = nil
	self.equipment_auto_cfg = nil
end

function FeixianCell:OnClickItem()
	local num = self.index
	self.parent_view:OpenPanelEquipTips(num)
end

function FeixianCell:CheckSeclect(data)
	
	if self.auto_equip == true then 
		self.data = data
		self.cell:SetData(data)
		self.cell:SetActive(true)
		self.node_list["BtnSwitch"]:SetActive(true)
		self.state = ForgeData.FORGE_FLY_GUILD_STATE.CHECKED_HAVE
		self.choose_state = true
		self.parent_view:Flush()
	end
end

function FeixianCell:SetState(value)
	self.state = value
end
function FeixianCell:JudgeState()
	local table = {y = 1 , x = 1 , z = 1}
	if self.state == ForgeData.FORGE_FLY_GUILD_STATE.UNCHECKED_NOT_HAVE then 
		--self.anim:SetFloat("Time",0)
		--self.anim:Play("icon_plus_anim",1,0)
		self.node_list["ImgAnim"].rect.localScale = table
		self.anim.enabled = false
		self.cell:SetActive(false)
		self.cell.data = {}
		self.node_list["BtnSwitch"]:SetActive(false)
		self:ChangeTextName(false)

	elseif self.state == ForgeData.FORGE_FLY_GUILD_STATE.UNCHECKED_HAVE then 
		self.anim.enabled = true
		self.cell:SetActive(false)
		self.cell.data = {}
		self.node_list["BtnSwitch"]:SetActive(false)
		self:ChangeTextName(false)
	elseif self.state == ForgeData.FORGE_FLY_GUILD_STATE.CHECKED_HAVE then 
		--self.anim:SetFloat("Time",0)
		--self.anim:Play("icon_plus_anim",1,0)
		self.node_list["ImgAnim"].rect.localScale = table
		self.anim.enabled = false
		self.cell:SetData(self.data)
		self.cell:SetActive(true)
		self.node_list["BtnSwitch"]:SetActive(true)
		self:ChangeTextName(true)
	end
end

function FeixianCell:ChangeTextName(bool)
	
	if self.node_list["TxtNowName"] ~= nil then 
		if nil == self.cell.data.item_id then 
			self.node_list["TxtNowName"].text.text = ""
			self.node_list["TxtNowName"]:SetActive(false)
		end
		if nil ~= self.equipment_auto_cfg[self.cell.data.item_id] then
			self.node_list["TxtNowName"].text.text = self.equipment_auto_cfg[self.cell.data.item_id].name
			self.node_list["TxtNowName"]:SetActive(bool)
		end
	end
end
function FeixianCell:OnFlush()
	self:JudgeState()
	--self.parent_view:CheckRedPoints()
end

function FeixianCell:SetCellData(data)
	if nil ~= data then 
		self.data = data
		self.state = ForgeData.FORGE_FLY_GUILD_STATE.CHECKED_HAVE
	else
		self.data = {}
		self.state = ForgeData.FORGE_FLY_GUILD_STATE.UNCHECKED_HAVE
	end
end
-----------------------------装备弹框---------------------------------------------
FeixianTipEquipList = FeixianTipEquipList or BaseClass(BaseCell)
function FeixianTipEquipList:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ImgEquipListItem"])
	self.item_cell:ShowHighLight(false)
	self.node_list["BtnClick"].button:AddClickListener(BindTool.Bind(self.OnClickItem, self))
end

function FeixianTipEquipList:__delete()
	if nil ~= self.item_cell then 
		self.item_cell:DeleteMe()
	end
	self.item_cell = nil
end

function FeixianTipEquipList:OnClickItem()
	self.parent_view:SetChoose(self.index)
	self.parent_view:FlushItemActive()
end

function FeixianTipEquipList:OnFlush()
	self.item_cell:SetData(self.data)
	self:FlushItemChoose()
end

function FeixianTipEquipList:FlushItemChoose()
	local choose_data = self.parent_view:GetdataIndex()
	self.node_list["ToggleSelfItem"].toggle.isOn = choose_data == self.index
end

function FeixianTipEquipList:SetFeixianName(name)
	self.node_list["TxtName"].text.text = name
end

FeixianSuccTip = FeixianSuccTip or BaseClass(BaseRender)

function FeixianSuccTip:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["CellItem"])
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClose,self))
	self.node_list["BtnClickBg"].button:AddClickListener(BindTool.Bind(self.OnClose,self))
	self.node_list["BtnSure"].button:AddClickListener(BindTool.Bind(self.OnClose,self))
end

function FeixianSuccTip:__delete()
	if nil ~= self.item_cell then 
		self.item_cell:DeleteMe()
	end
	self.item_cell = nil 
end

function FeixianSuccTip:OnClose()
	self.node_list["PanelSelf"]:SetActive(false)
end
function FeixianSuccTip:LoadSuccData(item_index,feixian_type)
	local equipment_auto_cfg = ForgeData.Instance:GetEquipmentCfg()
	local item_data_info = ItemData.Instance:GetBagItemDataList()
	
	local data = {}
	if nil ~= item_data_info[item_index] then 
		data.item_id = item_data_info[item_index].item_id
	else
		data.item_id = 0
	end
	if nil == equipment_auto_cfg or nil == equipment_auto_cfg[data.item_id] then 
		return
	end 

	if equipment_auto_cfg[data.item_id].sub_type >= 1100 and equipment_auto_cfg[data.item_id].sub_type <= 1109 and equipment_auto_cfg[data.item_id].name ~= nil and nil ~= equipment_auto_cfg[data.item_id].color then 	
		data.param = {}
		if equipment_auto_cfg[data.item_id].color == 5 then data.param.really = 0
		else data.param.really = 1
		end
		self.item_cell:SetData(data)
		self.node_list["TxtCellName"].text.text = equipment_auto_cfg[data.item_id].name

		if feixian_type == "Orange" then 
			self.node_list["TxtNameType"].text.text = Language.Forge.TypeFeixianOrange
		elseif feixian_type == "Red" then 

			self.node_list["TxtNameType"].text.text = Language.Forge.TypeFeixianRed
		end
		self.node_list["PanelSelf"]:SetActive(true)
	end

end

