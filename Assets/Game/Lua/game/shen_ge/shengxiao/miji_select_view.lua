MiJiSelectView = MiJiSelectView or BaseClass(BaseView)

local COLUMN = 2
function MiJiSelectView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/shengeview_prefab", "MiJiSelectView"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
	self.fight_info_view = true
	self.had_data_list = {}
	self.list_data = {}
	self.from_view = ""
	self.max_pagg_count = 0
	self.now_page = 1
end

function MiJiSelectView:ReleaseCallBack()
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.ehough_toggle = nil
end

function MiJiSelectView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(830, 570, 0)
	self.node_list["Txt"].text.text = Language.ShengXiao.MiJiXuanZe

	self.cell_list = {}
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))

	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	
	self.node_list["ListView"].scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChanged, self))
	self.node_list["EnoughToggle"].toggle:AddValueChangedListener(BindTool.Bind(self.OnSelectToggleChange, self))
end

function MiJiSelectView:OpenCallBack()
	self.list_data = MiJiComposeData.Instance:GetMiJiItemListByBag(self.had_data_list)
	self.node_list["ListView"].scroller:ReloadData(0)
end

function MiJiSelectView:CloseCallBack()
	if self.call_back ~= nil then
		self.call_back()
		self.call_back = nil
	end
	self.had_data_list = {}
	self.list_data = {}
end

function MiJiSelectView:SetSelectCallBack(call_back)
	self.call_back = call_back
end

function MiJiSelectView:SetHadSelectData(data_list)
	self.had_data_list = data_list or {}
end

function MiJiSelectView:SetFromView(from_view)
	self.from_view = from_view or ""
end

function MiJiSelectView:GetNumberOfCells()
	return math.ceil(#self.list_data / 2)
end

function MiJiSelectView:OnSelectToggleChange(is_on)
	if self.had_data_list.count > 0 then
		return
	end
end

function MiJiSelectView:SetPageData()
end

function MiJiSelectView:OnValueChanged(normalizedPosition)
end

function MiJiSelectView:RefreshCell(cellObj, data_index)
	local cell = self.cell_list[cellObj]
	if nil == cell then
		cell = MiJiSelectGroup.New(cellObj.gameObject)
		cell:SetToggleGroup(self.node_list["ListView"].toggle_group)
		self.cell_list[cellObj] = cell
	end

	for i = 1, COLUMN do
		local index = (data_index)*COLUMN + i
		cell:SetIndex(i, index)
		local data = self.list_data[index]
		cell:SetActive(i, (data ~= nil and data.bag_info.item_id > 0))
		cell:SetData(i, data)
		cell:SetClickCallBack(i, BindTool.Bind(self.ItemCellClick, self))
	end
end

function MiJiSelectView:ItemCellClick(cell)
	if self.call_back ~= nil then
		self.call_back(cell.data)
		self.call_back = nil
	end
	self:Close()
end

function MiJiSelectView:CloseWindow()
	self:Close()
end

function MiJiSelectView:OnFlush(param_list)
end

-------------------MiJiSelectGroup-----------------------
MiJiSelectGroup = MiJiSelectGroup or BaseClass(BaseRender)
function MiJiSelectGroup:__init()
	self.item_list = {}
	for i = 1, COLUMN do
		local bag_item = MiJiSelectCell.New(self.node_list["Item" .. i])
		table.insert(self.item_list, bag_item)
	end
end

function MiJiSelectGroup:__delete()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function MiJiSelectGroup:SetActive(i, state)
	self.item_list[i]:SetActive(state)
end

function MiJiSelectGroup:SetData(i, data)
	self.item_list[i]:SetData(data)
end

function MiJiSelectGroup:SetToggleGroup(group)
	for k, v in ipairs(self.item_list) do
		v:SetToggleGroup(group)
	end
end

function MiJiSelectGroup:SetIndex(i, index)
	self.item_list[i]:SetIndex(index)
end

function MiJiSelectGroup:SetClickCallBack(i, callback)
	self.item_list[i]:SetClickCallBack(callback)
end

-------------------MiJiSelectCell-----------------------
MiJiSelectCell = MiJiSelectCell or BaseClass(BaseCell)
function MiJiSelectCell:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.item_cell:ShowHighLight(false)
	self.item_cell:ListenClick(BindTool.Bind(self.OnClick, self))

	self.node_list["PanelBagItem"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtNumber"])
end

function MiJiSelectCell:__delete()
	self.fight_text = nil
	
	if nil ~= self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function MiJiSelectCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function MiJiSelectCell:SetHighLight(state)
	self.root_node.toggle.isOn = state
end

function MiJiSelectCell:OnFlush()
	if not self.data or not next(self.data) then
		return
	end
	self.item_cell:SetData(self.data.bag_info)

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	local miji_cfg = ShengXiaoData.Instance:GetMijiCfgByItemId(self.data.item_id)
	local name_str = "<color=" .. SOUL_NAME_COLOR[item_cfg.color] .. ">" .. item_cfg.name .. "</color>"

	self.node_list["TxtLevelDes"].text.text = name_str
	self.node_list["TxtAttrDes1"].text.text = miji_cfg.type_name
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = miji_cfg.capacity
	end
	if miji_cfg.type < 10 then
		local data = {}
		data[SHENGXIAO_MIJI_TYPE[miji_cfg.type]] = miji_cfg.value
		self.fight_text.text.text = CommonDataManager.GetCapabilityCalculation(data)
	end
	self.node_list["ImgRepeat"]:SetActive(self.data.have_type == 0)
end