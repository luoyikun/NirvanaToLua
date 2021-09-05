ShenYinSelectView = ShenYinSelectView or BaseClass(BaseView)

local COLUMN = 2		-- 列
local PAGE_NUM = 4		-- 一页格子数
local FROM_INLAY = "from_inlay"
local FROM_COMPOSE = "from_compose"

function ShenYinSelectView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/shenyinview_prefab", "ShenYinSelectView"},
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true

	self.fight_info_view = true
	self.data = {}
	self.list_data = {}
	self.max_pagg_count = 0
	self.now_page = 1
end

function ShenYinSelectView:ReleaseCallBack()
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function ShenYinSelectView:LoadCallBack()
	self.cell_list = {}
	self.node_list["Txt"].text.text = Language.ShenYin.ShenYinBag
	
	self.node_list["Bg"].rect.sizeDelta = Vector3(850,550,0)

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))

	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	--self.node_list["ListView"].scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChanged, self))
	self.cur_page =	0
	self.max_page =	0
end

function ShenYinSelectView:OpenCallBack()
	if nil == self.data then return end

	self.list_data = ShenYinData.Instance:GetShenYinBySlot(self.data.imprint_slot)
	--self:SetPageData()

	if self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:ReloadData(0)
		-- self.node_list["ListView"].list_view:Reload()
		-- self.node_list["ListView"].list_page_scroll2:JumpToPageImmidateWithoutToggle(0)
	end
end

function ShenYinSelectView:CloseCallBack()
	if self.call_back ~= nil then
		self.call_back()
		self.call_back = nil
	end
	self.data = {}
	self.list_data = {}
end

function ShenYinSelectView:SetSelectCallBack(call_back)
	self.call_back = call_back
end

function ShenYinSelectView:SetHadSelect(click_data)
	self.data = click_data or {}
end

function ShenYinSelectView:GetNumberOfCells()
	return math.ceil(#self.list_data / 2)
end

-- function ShenYinSelectView:SetPageData()
-- 	self.max_pagg_count = math.ceil(#self.list_data / COLUMN / PAGE_NUM)
-- 	self.node_list["ListView"].list_page_scroll2:SetPageCount(self.max_pagg_count)

-- 	self.now_page = 1
-- 	self.cur_page = 1
-- 	self.max_page = self.max_pagg_count
-- 	self.node_list["TxtPage"].text.text = string.format("%s/%s", self.cur_page, self.max_page)
-- end

-- function ShenYinSelectView:OnValueChanged(normalizedPosition)
-- 	local now_page = self.node_list["ListView"].list_page_scroll2:GetNowPage() + 1
-- 	if now_page ~= self.now_page then
-- 		self.cur_page = now_page
-- 		self.now_page = now_page
-- 		self.node_list["TxtPage"].text.text = string.format("%s/%s", self.cur_page, self.max_page)
-- 	end
-- end

function ShenYinSelectView:RefreshCell(cellObj, data_index)
	self.list_data = ShenYinData.Instance:GetShenYinBySlot(self.data.imprint_slot)
	local cell = self.cell_list[cellObj]
	if nil == cell then
		cell = ShenYinSelectGroup.New(cellObj)
		cell:SetToggleGroup(self.node_list["ListView"].toggle_group)
		self.cell_list[cellObj] = cell
	end

	for i = 1, COLUMN do
		local index = (data_index)*COLUMN + i
		cell:SetIndex(i, index)
		if self.list_data and self.list_data[index] then
			local data = self.list_data[index]

			cell:SetActive(i, (data ~= nil and data.item_id > 0))

			cell:SetData(i, data)
			cell:SetClickCallBack(i, BindTool.Bind(self.ItemCellClick, self))
		else
			cell:SetActive(i, false)
		end
	end
end

function ShenYinSelectView:ItemCellClick(cell)
	if cell ~= nil and cell.data ~= nil then
		PackageCtrl.Instance:SendUseItem(cell.data.bag_index, cell.data.num)
	end
	self:Close()
end

function ShenYinSelectView:OnFlush(param_list)

end


-------------------ShenGeSelectGroup-----------------------
ShenYinSelectGroup = ShenYinSelectGroup or BaseClass(BaseRender)
function ShenYinSelectGroup:__init()
	self.item_list = {}
	for i = 1, COLUMN do
		local bag_item = ShenYinSelectCell.New(self.node_list["Item" .. i])
		table.insert(self.item_list, bag_item)
	end
end

function ShenYinSelectGroup:__delete()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function ShenYinSelectGroup:SetActive(i, state)
	self.item_list[i]:SetActive(state)
end

function ShenYinSelectGroup:SetData(i, data)
	self.item_list[i]:SetData(data)
end

function ShenYinSelectGroup:SetToggleGroup(group)
	for k, v in ipairs(self.item_list) do
		v:SetToggleGroup(group)
	end
end

function ShenYinSelectGroup:SetIndex(i, index)
	self.item_list[i]:SetIndex(index)
end

function ShenYinSelectGroup:SetClickCallBack(i, callback)
	self.item_list[i]:SetClickCallBack(callback)
end

-------------------ShenGeSelectCell-----------------------
ShenYinSelectCell = ShenYinSelectCell or BaseClass(BaseCell)
function ShenYinSelectCell:__init()
	local item = ItemCell.New()
	item:SetInstanceParent(self.node_list["ItemCell"])
	item:ListenClick(BindTool.Bind(self.OnClick, self))
	item:ShowHighLight(false)
	self.item_cell = item
	item:ShowQuality(true)
	self.node_list["PamelBagItem"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtAttrDes1"], "FightPower3")
end

function ShenYinSelectCell:__delete()
	self.item_cell:DeleteMe()
	self.item_cell = nil
	self.fight_text = nil
end

function ShenYinSelectCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function ShenYinSelectCell:SetHighLight(state)
	self.root_node.toggle.isOn = state
end

function ShenYinSelectCell:OnFlush()
	if not self.data or not next(self.data) then
		return
	end
	self.item_cell:SetData(self.data)
	self.item_cell.node_list["Icon"].image.preserveAspect = true
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg then
		return
	end
	local level_str = item_cfg.name
	local level_to_color = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
	self.node_list["TxtLevelDes"].text.text = level_to_color
	local attr_cfg = ShenYinData.Instance:GetShenYinCapabilityByData(self.data, false)
	local power =  CommonDataManager.GetCapability(attr_cfg)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = power
	end
end