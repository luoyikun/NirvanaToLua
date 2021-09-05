RuneBagView = RuneBagView or BaseClass(BaseView)
local COLUMN = 2
function RuneBagView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/rune_prefab", "RuneBagView"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
	self.slot_index = 0
end

function RuneBagView:__delete()
end

function RuneBagView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.select_length = nil

end

function RuneBagView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["Bg"].rect.sizeDelta = Vector3(840,608,0)
	self.node_list["Txt"].text.text = Language.Rune.TitleName2

	self.list_data = {}
	-- self.list_data = RuneData.Instance:GetBagList()
	self.cell_list = {}
	local scroller_delegate = self.node_list["ListView"].list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCellNumber, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.CellRefresh, self)
end

--设置打开的格子
function RuneBagView:SetSlotIndex(slot)
	self.slot_index = slot
	RuneData.Instance:ResetBagList(slot)
end

function RuneBagView:OpenCallBack()
	self:FlushView()
end

function RuneBagView:CloseCallBack()
	
end

function RuneBagView:FlushView()
	self.list_data = RuneData.Instance:GetBagList()
	self.select_list = {}
	self.select_length = 0
	for k, v in pairs(self.list_data) do
		if self.slot_index == RuneData.SoltCenter and v.type == GameEnum.RUNE_WUSHIYIJI_TYPE then
			self.select_length = self.select_length + 1
			self.select_list[self.select_length] = v
		elseif self.slot_index ~= RuneData.SoltCenter and self.slot_index ~= 0 then
			if v.type ~= GameEnum.RUNE_WUSHIYIJI_TYPE and v.type ~= GameEnum.RUNE_JINGHUA_TYPE then
				self.select_length = self.select_length + 1
				self.select_list[self.select_length] = v
			end
		elseif self.slot_index == 0 then 			--背包进来
			self.select_length = self.select_length + 1
			self.select_list[self.select_length] = v
		end
	end

	local count_des = string.format(Language.Exchange.Expend, self.select_length, GameEnum.RUNE_SYSTEM_BAG_MAX_GRIDS)
	self.node_list["FrameText"].text.text = string.format(Language.Rune.BagCount, count_des)
	self.node_list["ListView"].scroller:ReloadData(0)
end

function RuneBagView:CloseWindow()
	self.slot_index = 0
	self:Close()
end

function RuneBagView:GetCellNumber()
	return math.ceil(self.select_length/COLUMN)
end

function RuneBagView:CellRefresh(cell, data_index)
	local group_cell = self.cell_list[cell]
	if not group_cell then
		group_cell = RuneBagGroupCell.New(cell.gameObject)
		group_cell:SetToggleGroup(self.node_list["ListView"].toggle_group)
		self.cell_list[cell] = group_cell
	end

	for i = 1, COLUMN do
		local index = (data_index)*COLUMN + i
		group_cell:SetIndex(i, index)
		local data = self.select_list[index]
		group_cell:SetActive(i, data ~= nil)
		group_cell:SetData(i, data)
		group_cell:SetClickCallBack(i, BindTool.Bind(self.ItemCellClick, self))
	end
end

function RuneBagView:ItemCellClick(cell)
	local data = cell:GetData()
	if not data or not next(data) then
		return
	end
	if self.slot_index < 0 then
		local function callback()
			if not cell:IsNil() then
				cell:SetHighLight(false)
			end
		end
		RuneCtrl.Instance:SetTipsData(data)
		RuneCtrl.Instance:SetTipsCallBack(callback)
		ViewManager.Instance:Open(ViewName.RuneItemTips)
	else
		if data.type == GameEnum.RUNE_JINGHUA_TYPE then
			SysMsgCtrl.Instance:ErrorRemind(Language.Rune.JingHuaNotEquip)
			return
		end
		-- if data.is_repeat then
		-- 	SysMsgCtrl.Instance:ErrorRemind(Language.Rune.IsRepeatAttr)
		-- 	return
		-- end
		
		local index = data.index
		RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_SET_RUAN, index, self.slot_index - 1)
		self:Close()
	end
end

function RuneBagView:OnFlush(params_t)
	self:FlushView()
end


-------------------RuneBagGroupCell-----------------------
RuneBagGroupCell = RuneBagGroupCell or BaseClass(BaseRender)
function RuneBagGroupCell:__init()

	self.item_list = {}
	for i = 1, COLUMN do
		local bag_item = RuneBagItemCell.New(self.node_list["Item" .. i])
		table.insert(self.item_list, bag_item)
	end
end

function RuneBagGroupCell:__delete()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function RuneBagGroupCell:SetActive(i, state)
	self.item_list[i]:SetActive(state)
end

function RuneBagGroupCell:SetData(i, data)
	self.item_list[i]:SetData(data)
end

function RuneBagGroupCell:SetToggleGroup(group)
	for k, v in ipairs(self.item_list) do
		v:SetToggleGroup(group)
	end
end

function RuneBagGroupCell:SetIndex(i, index)
	self.item_list[i]:SetIndex(index)
end

function RuneBagGroupCell:SetClickCallBack(i, callback)
	self.item_list[i]:SetClickCallBack(callback)
end

-------------------RuneBagItemCell-----------------------
RuneBagItemCell = RuneBagItemCell or BaseClass(BaseCell)
function RuneBagItemCell:__init()
	self.node_list["BagItem"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function RuneBagItemCell:__delete()

end

function RuneBagItemCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function RuneBagItemCell:SetHighLight(state)
	self.root_node.toggle.isOn = state
end

function RuneBagItemCell:OnFlush()
	if not self.data or not next(self.data) then
		return
	end

	if self.data.item_id > 0 then
		self.node_list["ImageRes"].image:LoadSprite(ResPath.GetItemIcon(self.data.item_id))
	end
	self.node_list["Repeat"]:SetActive(self.data.is_repeat)

	local level_color = RUNE_COLOR[self.data.quality] or TEXT_COLOR.WHITE
	local level_name = Language.Rune.AttrTypeName[self.data.type] or ""
	local level_str = string.format(Language.Rune.LevelDes, level_color, level_name, self.data.level)
	self.node_list["LevelDes"].text.text = level_str

	local attr_type_name = ""
	local attr_value = 0
	if self.data.type == GameEnum.RUNE_JINGHUA_TYPE then
		--符文精华特殊处理
		attr_type_name = Language.Rune.JingHuaAttrName
		attr_value = self.data.dispose_fetch_jinghua
		local str = string.format(Language.Rune.AttrDes, attr_type_name, attr_value)
		self.node_list["AttrDes1"].text.text = str
		self.node_list["AttrDes2"].text.text = ""
		return
	end

	attr_type_name = Language.Rune.AttrName[self.data.attr_type_0] or ""
	attr_value = self.data.add_attributes_0
	if RuneData.Instance:IsPercentAttr(self.data.attr_type_0) then
		attr_value = (self.data.add_attributes_0/100.00) .. "%"
	end
	local attr_des = string.format(Language.Rune.AttrDes, attr_type_name, attr_value)
	self.node_list["AttrDes1"].text.text = attr_des

	if self.data.attr_type_1 and self.data.attr_type_1 > 0 then
		attr_type_name = Language.Rune.AttrName[self.data.attr_type_1] or ""
		attr_value = self.data.add_attributes_1
		if RuneData.Instance:IsPercentAttr(self.data.attr_type_1) then
			attr_value = (self.data.add_attributes_1/100.00) .. "%"
		end
		attr_des = string.format(Language.Rune.AttrDes, attr_type_name, attr_value)
		self.node_list["AttrDes2"].text.text = attr_des
	else
		self.node_list["AttrDes2"].text.text = ""
	end
end