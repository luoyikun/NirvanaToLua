ShenGeSelectView = ShenGeSelectView or BaseClass(BaseView)

local COLUMN = 2
local PAGE_NUM = 4		-- 一页格子数
local FROM_INLAY = "from_inlay"
local FROM_COMPOSE = "from_compose"

function ShenGeSelectView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/shengeview_prefab", "ShenGeSelectView"},
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

function ShenGeSelectView:ReleaseCallBack()
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function ShenGeSelectView:LoadCallBack()
	self.cell_list = {}
	self.node_list["Txt"].text.text = Language.ShenGe.XuanZhe
	self.node_list["Bg"].rect.sizeDelta = Vector3(850,550,0)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	--self.node_list["ListView"].scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChanged, self))
	self.node_list["EnoughToggle"].toggle:AddValueChangedListener(BindTool.Bind(self.OnSelectToggleChange, self))
	self.cur_page =	0
	self.max_page =	0
end

function ShenGeSelectView:OpenCallBack()
	if self.from_view == FROM_COMPOSE then
		self.node_list["EnoughToggle"].toggle.isOn = true
		self.list_data = ShenGeData.Instance:GetCanComposeDataList(self.had_data_list, self.node_list["EnoughToggle"].toggle.isOn)
	elseif self.from_view == FROM_INLAY then
		self.list_data = ShenGeData.Instance:GetSameQuYuDataList(self.had_data_list[1], self.have_data)
	end
	--self:SetPageData()
	self.node_list["EnoughToggle"]:SetActive(self.from_view == FROM_COMPOSE)
	if self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:ReloadData(0)
		--self.node_list["ListView"].list_view:Reload()
		--self.node_list["ListView"].list_page_scroll2:JumpToPageImmidateWithoutToggle(0)
	end
end
function ShenGeSelectView:SetGrade()
	if self.from_view == FROM_COMPOSE then
		self.node_list["EnoughToggle"].toggle.isOn = true
		self.list_data = ShenGeData.Instance:GetCanComposeDataList(self.had_data_list, self.node_list["EnoughToggle"].toggle.isOn)
	elseif self.from_view == FROM_INLAY then
		self.list_data = ShenGeData.Instance:GetSameQuYuDataList(self.had_data_list[1])
	end
	--self:SetPageData()
	self.node_list["EnoughToggle"]:SetActive(self.from_view == FROM_COMPOSE)
	if self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:ReloadData(0)
		-- self.node_list["ListView"].list_view:Reload()
		-- self.node_list["ListView"].list_page_scroll2:JumpToPageImmidateWithoutToggle(0)
	end
end
function ShenGeSelectView:CloseCallBack()
	if self.call_back ~= nil then
		self.call_back()
		self.call_back = nil
	end
	self.had_data_list = {}
	self.list_data = {}
end

function ShenGeSelectView:SetSelectCallBack(call_back)
	self.call_back = call_back
end

function ShenGeSelectView:SetHadSelectData(data_list)
	self.had_data_list = data_list or {}
end

function ShenGeSelectView:SetFromView(from_view, have_data)
	self.have_data = have_data
	self.from_view = from_view or ""
end

function ShenGeSelectView:GetNumberOfCells()
	if self.from_view == FROM_COMPOSE and (self.had_data_list.count > 0 or self.node_list["EnoughToggle"].toggle.isOn) then
		return math.ceil(#self.list_data / 2)
	end
	if self.from_view == FROM_INLAY then
		return math.ceil(#ShenGeData.Instance:GetSameQuYuDataList(self.had_data_list[1]) / 2)
	end
	return math.ceil(ShenGeData.Instance:GetBagListCount() / 2)
end

function ShenGeSelectView:OnSelectToggleChange(is_on)
	if self.had_data_list.count > 0 then
		return
	end
	self.list_data = ShenGeData.Instance:GetCanComposeDataList(self.had_data_list, is_on)
	if self.node_list["ListView"].scroller.isActiveAndEnabled then
		--self:SetPageData()
		self.node_list["ListView"].scroller:ReloadData(0)
		--self.node_list["ListView"].list_page_scroll2:JumpToPageImmidateWithoutToggle(0)
	end
end

function ShenGeSelectView:RefreshCell(cellObj, data_index)
	local cell = self.cell_list[cellObj]
	if nil == cell then
		cell = ShenGeSelectGroup.New(cellObj)
		cell:SetToggleGroup(self.node_list["ListView"].toggle_group)
		self.cell_list[cellObj] = cell
	end
	for i = 1, COLUMN do
		local index = (data_index)*COLUMN + i
		cell:SetIndex(i, index)
		local data = self.list_data[index]
		cell:SetActive(i, (data ~= nil and data.item_id > 0))
		cell:SetData(i, data)
		cell:SetClickCallBack(i, BindTool.Bind(self.ItemCellClick, self))
	end
end

function ShenGeSelectView:ItemCellClick(cell)
	if self.call_back ~= nil then
		self.call_back(cell.data)
		self.call_back = nil
	end
	self:Close()
end

-- function ShenGeSelectView:CloseWindow()
-- 	self:Close()
-- end

function ShenGeSelectView:OnFlush(param_list)
end


-------------------ShenGeSelectGroup-----------------------
ShenGeSelectGroup = ShenGeSelectGroup or BaseClass(BaseRender)
function ShenGeSelectGroup:__init()
	self.item_list = {}
	for i = 1, COLUMN do
		local bag_item = ShenGeSelectCell.New(self.node_list["Item" .. i])
		table.insert(self.item_list, bag_item)
	end
end

function ShenGeSelectGroup:__delete()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function ShenGeSelectGroup:SetActive(i, state)
	self.item_list[i]:SetActive(state)
end

function ShenGeSelectGroup:SetData(i, data)
	self.item_list[i]:SetData(data)
end

function ShenGeSelectGroup:SetToggleGroup(group)
	for k, v in ipairs(self.item_list) do
		v:SetToggleGroup(group)
	end
end

function ShenGeSelectGroup:SetIndex(i, index)
	self.item_list[i]:SetIndex(index)
end

function ShenGeSelectGroup:SetClickCallBack(i, callback)
	self.item_list[i]:SetClickCallBack(callback)
end

-------------------ShenGeSelectCell-----------------------
ShenGeSelectCell = ShenGeSelectCell or BaseClass(BaseCell)
function ShenGeSelectCell:__init()
	local item = ItemCell.New()
	item:SetInstanceParent(self.node_list["ItemCell"])
	item:ListenClick(BindTool.Bind(self.OnClick, self))
	item:ShowHighLight(false)
	self.item_cell = item
	item:ShowQuality(true)
	self.node_list["PamelBagItem"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function ShenGeSelectCell:__delete()
	self.item_cell:DeleteMe()
	self.item_cell = nil
end

function ShenGeSelectCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function ShenGeSelectCell:SetHighLight(state)
	self.root_node.toggle.isOn = state
end

function ShenGeSelectCell:OnFlush()
	if not self.data or not next(self.data) then
		return
	end
	self.item_cell:SetData(self.data)
	self.item_cell.node_list["Icon"].image.preserveAspect = true

	local shen_ge_data = self.data.shen_ge_data
	if nil == shen_ge_data then
		return
	end

	local attr_cfg = ShenGeData.Instance:GetShenGeAttributeCfg(shen_ge_data.type, shen_ge_data.quality, shen_ge_data.level)
	if nil == attr_cfg then
		return
	end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg then
		return
	end
	local level_str = attr_cfg.name
	local level_to_color = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..level_str.."</color>"
	self.node_list["TxtLevelDes"].text.text = level_to_color

	for i = 0, 1 do
		local attr_value = attr_cfg["add_attributes_"..i]
		local attr_type = attr_cfg["attr_type_"..i]
		if attr_value > 0 then
			if attr_type == 8 or attr_type == 9 then
				self.node_list["TxtAttrDes" .. (i + 1)].text.text = Language.ShenGe.AttrTypeName[attr_type].."  +"..(attr_value / 100).."%"
			else
				self.node_list["TxtAttrDes" .. (i + 1)].text.text = Language.ShenGe.AttrTypeName[attr_type].."  +"..attr_value
			end
		else
			self.node_list["TxtAttrDes" .. (i + 1)].text.text = ""
		end
	end
end